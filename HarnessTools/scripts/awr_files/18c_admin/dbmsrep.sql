Rem
Rem dbmsrep.sql
Rem
Rem Copyright (c) 2005, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrep.sql - DBMS_REPORT package spec
Rem
Rem    DESCRIPTION
Rem      This file serves as the package specification for the DBMS_REPORT
Rem      package, a framework for helping server components build XML from
Rem      within the kernel.
Rem
Rem      Implementation of this package is in svrman/report/prvtrep.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrep.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrep.sql
Rem SQL_PHASE: DBMSREP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cgervasi    06/16/15 - add get_awr_diff_context for cell diff-diff
Rem    kyagoub     03/27/14 - expose i_zlib2base64_clob
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jinhuo      11/20/13 - Fixed bug 16616443 - add functions to build
Rem                           report tag attributes from imported AWR data
Rem    kyagoub     08/07/12 - add transform_report_xml
Rem    kyagoub     06/17/12 - register swf files from featureSWF.js
Rem    kyagoub     06/15/12 - get_report: add compress argument
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     01/24/12 - Add get_report_with_summary
Rem    cgervasi    01/13/12 - get_param: add NULLABLE
Rem    bdagevil    01/09/12 - support for mandatory parameters in get_param
Rem    bdagevil    12/28/11 - add get_param()
Rem    kyagoub     12/20/11 - move get_swf from dbms_report to prvt_emx
Rem    shjoshi     09/06/11 - Expose lookup_component_id
Rem    bdagevil    08/19/11 - add format_message
Rem    cgervasi    07/21/11 - add date_fmt_mod
Rem    cgervasi    07/21/11 - add date_fmt_mod and date_fmt
Rem    yxie        04/26/11 - add functions to register and get swf files for
Rem                           each report
Rem    yxie        04/21/11 - remove file management to prvt_emx package
Rem    pbelknap    06/16/09 - remove urls
Rem    shjoshi     03/26/09 - Add setup_report_env and restore_report_env
Rem    bdagevil    11/12/08 - register common em xslt
Rem    pbelknap    07/13/06 - allow clearing of single component only 
Rem    kyagoub     07/08/06 - switch arguments of store_file 
Rem    pbelknap    04/24/06 - add drop shared directory 
Rem    pbelknap    02/08/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                     DBMS_REPORT FUNCTION DESCRIPTIONS                     --
-------------------------------------------------------------------------------
--  Component Mapping Service functions
----------------------------------------
--  register_component: register a new component with callback to framework
--  register_report:    register a new report (view of component data), same
--                      callback as passed to register_component
--
--  get_report:         fetch a report from a framework component
--
---------------------------------------------------
--  Transformation and Validation Engine functions
---------------------------------------------------
--  create_shared_directory: setup the directory object before storing files
--  drop_shared_directory:   drop the directory object after storing files
--  store_file:              keep a file in the reporting framework
--  register_XXX_format:     create an XSLT, text, or custom output format
--  format_report:           transform an XML document to a registered format 
--  validate_report:         apply an XML schema to XML data, check for 
--                           validity
--
---------------------------------------------------
--  General Utility functions
---------------------------------------------------
--  build_report_reference_xxx: build a report_ref string helper
--  parse_report_reference:     parse a report_ref string passed to the report
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_report AUTHID CURRENT_USER IS
  --=========================================================================--
  --                             GLOBAL TYPES                                --
  --=========================================================================--
  TYPE string_number_map IS TABLE OF NUMBER INDEX BY VARCHAR2(32767);  

  --=========================================================================--
  --                           GLOBAL CONSTANTS                              --
  --=========================================================================--

  -- date format from flex
  -- date_fmt_mod is used when generating/checking the URL parameters
  DATE_FMT_MOD          CONSTANT       varchar2(21) := 'mm:dd:yyyy hh24:mi:ss';
  -- date_fmt is used for any dates printed out and can be consumed
  -- by flex Formatter.dateXML()
  DATE_FMT              CONSTANT       varchar2(21) := 'mm/dd/yyyy hh24:mi:ss';

  -- Content type constants (used by servlet, stored in wri$_rept_formats)
  CONTENT_TYPE_XML      CONSTANT        NUMBER := 1;  
  CONTENT_TYPE_HTML     CONSTANT        NUMBER := 2;
  CONTENT_TYPE_TEXT     CONSTANT        NUMBER := 3;
  CONTENT_TYPE_BINARY   CONSTANT        NUMBER := 4;

  -- Directory name that clients use passing for their files
  SHARED_DIRECTORY_OBJECT       CONSTANT VARCHAR2(64) := 'ORAREP_DIR';

  --=========================================================================--
  --                                 TYPES                                   --
  --=========================================================================--
  TYPE ref_string_idspec IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32767);

  -- record for storing canonical values of certain parameters we wish to
  -- set before any report is generated. These parameters influence the way
  -- data is formatted in the reports and the canonical values will ensure
  -- consistent formatting irrespective of other umbrella parameter changes
  -- We set the following parameters:
  -- NLS_NUMERIC_CHARACTERS - to control how numbers are formatted (decimal 
  --                          and group separator characters)
  -- NLS_DATE_FORMAT        - to control date format
  -- NLS_TIMESTAMP_FORMAT, NLS_TIMESTAMP_TZ_FORMAT - to control timestamp 
  -- format
  TYPE format_param_value IS RECORD (
    param_num           NUMBER,
    param_value         VARCHAR2(32767)
  );

  TYPE format_param_values IS TABLE OF format_param_value;

  --=========================================================================--
  --                    COMPONENT MAPPING SERVICE FUNCTIONS                  --
  --=========================================================================--

  ------------------------------ register_component ---------------------------
  -- NAME: 
  --     register_component
  --
  -- DESCRIPTION:
  --     This procedure registers a new component with the XML reporting 
  --     framework.  It should be called at database startup from within the
  --     dbms_report_registry package.
  --
  -- PARAMETERS:
  --     component_name   (IN) - name of the component to register
  --                             (converted to lower case)
  --     component_desc   (IN) - description of the component to register
  --     component_object (IN) - object to store for this component, used for
  --                             requesting reports     
  --
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE register_component(
    component_name   IN VARCHAR2,
    component_desc   IN VARCHAR2,
    component_object IN wri$_rept_abstract_t);

  -------------------------------- register_report ----------------------------
  -- NAME: 
  --     register_report
  --
  -- DESCRIPTION:
  --     This procedure registers a report with the framework.  One components
  --     can have multiple reports but must have at least 1.  Having multiple
  --     reports is the best way for components to generate XML documents that
  --     link to each other through the <report_ref> mechanism.
  --
  -- PARAMETERS:
  --     component_name (IN)   - name of the component to register
  --     report_name    (IN)   - name of the report to register
  --                             (converted to lower case)
  --     report_desc    (IN)   - description of the report to register
  --     schema_id      (IN)   - file id of schema for this report, can be NULL
  --                             (returned from store_file)
  --
  -- RETURN:
  --     VOID 
  -----------------------------------------------------------------------------
  PROCEDURE register_report(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    report_desc      IN VARCHAR2,
    schema_id        IN NUMBER);

  ------------- build_report_reference - vararg and structure versions --------
  -- NAME: 
  --     build_report_reference _varg/_struct - vararg and structure versions
  --
  -- DESCRIPTION:
  --     This function builds a report ref string given the necessary inputs.
  --     The report_id is given as a variable-argument list of name/value 
  --     pairs, or as an instance of the ref_string_idspec type.
  --
  --     For example, to generate the reference for the string
  --     /orarep/cname/rname?foo=1AMPbar=2
  --     (substituting AMP for the ampersand in the ref string)
  --     call this function as
  --   
  --     build_report_reference_varg('cname','rname','foo','1','bar','2'); 
  --
  --     or as
  --
  --     build_report_reference_struct('cname','rname',params) where params
  --     has been initialized to hold 'foo' and 'bar'.
  --
  --     Parameter names and values are case-sensitive
  --
  -- NOTES:
  --     build_report_reference_vararg cannot be called from SQL due to a known
  --     limitation in the PL/SQL vararg implementation.  Clients can, however,
  --     create a PL/SQL non-vararg wrapper around it and call that in SQL if 
  --     they have the need.
  --
  --     The framework reserves some parameter names for internal use.  See
  --     dbms_report.get_report.
  --
  -- PARAMETERS:
  --     component_name (IN)   - name of the component for ref string
  --     report_name    (IN)   - name of the report for ref string
  --     id_param_val   (IN)   - list of parameter names and values for
  --                             the report_id portion of the string
  --
  -- RETURN:
  --     report reference string, as VARCHAR2
  -----------------------------------------------------------------------------
  FUNCTION build_report_reference_varg(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    id_param_val     ...)
  RETURN VARCHAR2;

  FUNCTION build_report_reference_struct(
    component_name   IN VARCHAR2,
    report_name      IN VARCHAR2,
    id_param_val     IN ref_string_idspec)
  RETURN VARCHAR2;

  ----------------------------- parse_report_reference ------------------------
  -- NAME: 
  --     parse_report_reference
  --
  -- DESCRIPTION:
  --     This function parses a report reference to reveal its constituent 
  --     parts.  Each one is returned as an OUT parameter, converted to lower 
  --     case.  Parameter names and values are case-sensitive.
  --
  -- PARAMETERS:
  --     report_reference (IN)   - report ref string to parse
  --     component_name   (OUT)  - name of the component for ref string
  --     report_name      (OUT)  - name of the report for ref string
  --     id_param_val     (OUT)  - parameter names and values for ref string
  --
  -- RETURN:
  --     report reference string, as VARCHAR2
  -----------------------------------------------------------------------------
  PROCEDURE parse_report_reference(
    report_reference IN  VARCHAR2,
    component_name   OUT VARCHAR2,
    report_name      OUT VARCHAR2,
    id_param_val     OUT ref_string_idspec);

  --------------------------------- get_param ---------------------------------
  -- NAME: 
  --     get_param
  --
  -- DESCRIPTION:
  --     Internal, get parameter from parsed report reference
  --
  -- PARAMETERS:
  --     param_val     (IN)  - parameter names and value pairs for ref string
  --     param_name    (IN)  - parameter name
  --     mandatory     (IN)  - TRUE if parameter is mandatory. Default is FALSE
  --     default_value (IN)  - Default value, null by default
  --     nullable      (IN)  - TRUE if null string should be interpreted as
  --                           a NULL value. Default is FALSE
  --
  -- RETURN:
  --     parameter value, a clob. null if parameter is null or does not exists
  -----------------------------------------------------------------------------
  FUNCTION get_param(
    param_val       IN ref_string_idspec,
    param_name      IN VARCHAR2,
    mandatory       IN BOOLEAN := FALSE,
    default_value   IN CLOB := null,
    nullable        IN BOOLEAN := FALSE)
  RETURN CLOB;

  ----------------------------------- get_report ------------------------------
  -- NAME: 
  --     get_report
  --
  -- DESCRIPTION:
  --     This procedure fetches a report from its component.
  --
  -- PARAMETERS:
  --     report_reference (IN) - report_ref string to use for fetching this
  --                             report, of the form
  --                             /orarep/component/report_name?<PARAMS>.
  --
  --                             Components can build a report reference by 
  --                             calling build_report_reference, or parse one
  --                             by calling parse_report_reference.
  --  
  --                             The following parameter names are reserved and
  --                             interpreted by this function.  They will be
  --                             removed from the reference string before 
  --                             dispatching the get_report call, and applied
  --                             to the XML returned by the component.  Add
  --                             them to your ref strings to get the related
  --                             functionality.
  --
  --                               + format: maps to format name.  When 
  --                                 specified, we will apply the format before
  --                                 returning the report
  --                               + validate: y/n according to whether 
  --                                 framework should validate the xml report.
  -- 
  --    compress_xml      (IN) - compress xml portion of the report 
  --
  -- RETURN:
  --     report
  --
  -- NOTES:
  --     See build_report_reference comments for sample ref strings.
  -----------------------------------------------------------------------------
  FUNCTION get_report(
    report_reference IN VARCHAR2, 
    compress_xml     IN BINARY_INTEGER := 0)
  RETURN CLOB;


  ------------------------------ get_report_with_summary ----------------------
  -- NAME: 
  --     get_report_with_summary
  --
  -- DESCRIPTION:
  --     This procedure fetches a report from its component.
  --
  -- PARAMETERS:
  --     report_reference (IN) - report_ref string to use for fetching this
  --                             report, of the form
  --                             /orarep/component/report_name?<PARAMS>.
  --
  --                             Components can build a report reference by 
  --                             calling build_report_reference, or parse one
  --                             by calling parse_report_reference.
  --  
  --                             The following parameter names are reserved and
  --                             interpreted by this function.  They will be
  --                             removed from the reference string before 
  --                             dispatching the get_report call, and applied
  --                             to the XML returned by the component.  Add
  --                             them to your ref strings to get the related
  --                             functionality.
  --
  --                               + format: maps to format name.  When 
  --                                 specified, we will apply the format before
  --                                 returning the report
  --                               + validate: y/n according to whether 
  --                                 framework should validate the xml report.
  --
  -- RETURN:
  --     report
  --
  -- NOTES:
  --     See build_report_reference comments for sample ref strings.
  -----------------------------------------------------------------------------
  FUNCTION get_report_with_summary(report_reference IN VARCHAR2)
  RETURN CLOB;

  --=========================================================================--
  --                  TRANSFORMATION AND VALIDATION FUNCTIONS                --
  --=========================================================================--
  
  ------------------------------ register_xslt_format -------------------------
  -- NAME: 
  --     register_xslt_format
  --
  -- DESCRIPTION:
  --     This function registers a format mapping for a report via XSLT.  Prior
  --     to calling this function the XSLT should have been stored in XDB by
  --     calling STORE_FILE.  After a format has been registered it can be
  --     used by calling format_report.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component that this format 
  --                                belongs to
  --     report_name         (IN) - name of report that this format belongs to
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     format_content_type (IN) - content type of format output, one of
  --                                 + CONTENT_TYPE_TEXT: plain text
  --                                 + CONTENT_TYPE_XML: xml
  --                                 + CONTENT_TYPE_HTML: html
  --                                 + CONTENT_TYPE_BINARY: other
  --     stylesheet_id       (IN) - File ID for the XSLT 
  --                                (returned by store_file)
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_xslt_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    format_content_type IN NUMBER := CONTENT_TYPE_HTML,
    stylesheet_id       IN NUMBER);

  ------------------------------ register_text_format -------------------------
  -- NAME: 
  --     register_text_format
  --
  -- DESCRIPTION:
  --     This function registers a format mapping for a text report.  Text 
  --     reports are created by first transforming an XML document to HTML
  --     using an XSLT provided by the component, and then turning the HTML to
  --     formatted text using the framework's own internal engine.  Prior
  --     to calling this function the XSLT should have been stored in XDB by
  --     calling STORE_FILE.  After a format has been registered it can be
  --     used by calling format_report.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component for this format
  --     report_name         (IN) - name of report for this format
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     html_stylesheet_id  (IN) - file id to the stylesheet that transforms
  --                                from XML to HTML (returned by store_file)
  --     text_max_linesize   (IN) - maximum linesize for text report
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_text_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    html_stylesheet_id  IN NUMBER,
    text_max_linesize   IN NUMBER := 80);

  ----------------------------- register_custom_format ------------------------
  -- NAME: 
  --     register_custom_format
  --
  -- DESCRIPTION:
  --     This function registers a custom format for an XML document. It allows
  --     components to format their document for viewing manually,by performing
  --     any kind of programmatic manipulation of the XML tree and outputting
  --     CLOB.
  --
  --     To apply custom formats, the framework will call the custom_format()
  --     member function in the object type for the component.
  --
  -- PARAMETERS:
  --     component_name      (IN) - name of component for this format
  --     report_name         (IN) - name of report for this format
  --     format_name         (IN) - format name (names are unique by report)
  --                                  note: the name 'em' is reserved
  --     format_desc         (IN) - format description
  --     format_content_type (IN) - content type of format output, one of
  --                                 + CONTENT_TYPE_TEXT: plain text
  --                                 + CONTENT_TYPE_XML: xml
  --                                 + CONTENT_TYPE_HTML: html
  --                                 + CONTENT_TYPE_BINARY: other
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_custom_format(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    format_name         IN VARCHAR2,
    format_desc         IN VARCHAR2,
    format_content_type IN NUMBER);

  ---------------------------------- register_swf -----------------------------
  -- NAME: 
  --     register_swf
  --
  -- DESCRIPTION:
  --     This function registers a swf file for a report.  Each report 
  --     corresponds to one swf file.  The swf file displays the report
  --     in flash UI.
  --     
  -- PARAMETERS:
  --     component_name      (IN) - name of component for this swf
  --     report_name         (IN) - name of report for this swf
  --     swf_id              (IN) - id of the swf file
  --
  -----------------------------------------------------------------------------
  PROCEDURE register_swf(
    component_name      IN VARCHAR2,
    report_name         IN VARCHAR2,
    swf_id              IN NUMBER);

  --------------------------------- format_report -----------------------------
  -- NAME: 
  --     format_report
  --
  -- DESCRIPTION:
  --     This function transforms an XML document into another format, as
  --     declared through one of the register_xxx_format calls above.
  --
  -- PARAMETERS:
  --     report              (IN) - document to format
  --     format_name         (IN) - format name to apply
  --     compress_xml        (IN) - compress xml 
  -----------------------------------------------------------------------------
  FUNCTION format_report(
    report       IN XMLTYPE,
    format_name  IN VARCHAR2, 
    compress_xml IN BINARY_INTEGER := 0)
  RETURN CLOB;

  ------------------------------- validate_report -----------------------------
  -- NAME: 
  --     validate_report
  --
  -- DESCRIPTION:
  --     This procedure applies the XML schema registered with the framework
  --     corresponding to the report specified to verify that it was built
  --     correctly.
  --
  -- PARAMETERS:
  --     report  (IN) - report to validate
  --
  -- RETURN:
  --     None
  --
  -- ERRORS:
  --     Raises error 31011 if document is not valid
  -----------------------------------------------------------------------------
  PROCEDURE validate_report(report IN XMLTYPE);

  ------------------------------ lookup_component_id --------------------------
  -- NAME: 
  --     lookup_component_id
  --
  -- DESCRIPTION:
  --     This function fetches a component id and returns it.  If the component
  --     does not exist, it signals ERR_UNKNOWN_OBJECT. Note that this function
  --     does the lookup in the view, so it can be called in an invoker rights
  --     situation by any user.
  --
  -- PARAMETERS:
  --     component_name (IN) - name of component to look up
  --
  -- RETURN:
  --     component id
  -----------------------------------------------------------------------------
  FUNCTION lookup_component_id(component_name IN VARCHAR2)
  RETURN NUMBER;

  ------------------------------- lookup_report_id ----------------------------
  -- NAME: 
  --     lookup_report_id
  --
  -- DESCRIPTION:
  --     This function fetches a report id and returns it.  If the report
  --     does not exist, it signals ERR_UNKNOWN_OBJECT. Note that this function
  --     does the lookup in the view, so it can be called in an invoker rights
  --     situation by any user.
  --
  -- PARAMETERS:
  --     component_name (IN) - name of component to look up
  --     report_name    (IN) - name of report to look up
  --
  -- RETURN:
  --     unique report id
  -----------------------------------------------------------------------------
  FUNCTION lookup_report_id(
    component_name IN VARCHAR2,
    report_name    IN VARCHAR2)
  RETURN NUMBER;


  --=========================================================================--
  --                       UNDOCUMENTED  FUNCTIONS                           --
  --                       ** INTERNAL USE ONLY **                           --
  --=========================================================================--
  PROCEDURE clear_framework(component_name IN VARCHAR2 := NULL);

  FUNCTION build_generic_tag(tag_name   IN VARCHAR2,
                             tag_inputs ...)
  RETURN XMLTYPE;

  FUNCTION get_report(report_reference IN  VARCHAR2,
                      content_type     OUT NUMBER, 
                      compress_xml     IN  BINARY_INTEGER := 0)
  RETURN CLOB;

  FUNCTION format_report(report              IN  XMLTYPE,
                         format_name         IN  VARCHAR2,
                         format_content_type OUT NUMBER,  
                         compress_xml        IN  BINARY_INTEGER := 0)   
  RETURN CLOB;

  FUNCTION transform_html_to_text(document     IN XMLTYPE,
                                  max_linesize IN POSITIVE)
  RETURN CLOB;

  -------------------------  zlib2base64_report_xml ---------------------------
  FUNCTION zlib2base64_report_xml(report_xml IN xmltype) RETURN XMLTYPE;

  --------------------------  transform_report_xml ---------------------------
  FUNCTION transform_report_xml(report_xml  IN xmltype, 
                                zlib2base64 IN binary_integer := 1) 
  RETURN XMLTYPE;

  -----------------------------  gzip_report_xml ------------------------------
  FUNCTION gzip_report_xml(report IN CLOB) RETURN BLOB;

  -------------------------------- zlib2base64_clob ---------------------------
  FUNCTION zlib2base64_clob(report IN CLOB) RETURN CLOB;

  ------------------------------- setup_report_env ----------------------------
  -- NAME: 
  --     setup_report_env
  --
  -- DESCRIPTION:
  --     This function sets canonical values for a few session parameters and
  --     also returns their original values as a record type. 
  --
  -- PARAMETERS:
  --
  -- RETURN:
  --     record containing original values of parameters
  ---------------------------------------------------------------------------- 
  FUNCTION setup_report_env(
   orig_env IN OUT NOCOPY format_param_values)
  RETURN BOOLEAN;

  ----------------------------- restore_report_env ----------------------------
  -- NAME: 
  --     restore_report_env
  --
  -- DESCRIPTION:
  --     This procedure reverts back the values of some session parameters 
  --     based on the input value.
  --
  -- PARAMETERS:
  --      orig_env   (IN)   names and values of session parameters
  --
  -- RETURN:
  --     void
  -----------------------------------------------------------------------------
  PROCEDURE restore_report_env(
    orig_env IN format_param_values);

  ------------------------------ get_timing_info ------------------------------
  -- NAME: 
  --     get_timing_info
  --
  -- DESCRIPTION:
  --     This function allows one to get elapsed and CPU timing information
  --     for a section of PL/SQL code
  --
  -- PARAMETERS:
  --     phase          (IN)      - When called: 0 for start, 1 for end
  --     elapsed_time  (IN/OUT)  - When "phase" is 0, OUT parameter storing
  --                               current timestamp. When "phase" is 1, used
  --                               both as IN/OUT to return elpased time.
  --     cpu_time      (IN/OUT)  - When "phase" is 0, OUT parameter storing
  --                               current cpu time. When "phase" is 1, used
  --                               both as IN/OUT to return cpu time.
  --
  -- DESCRIPTION
  --   Use this procedure to measure the elapsed/cpu time of a region of
  --   code:
  --     get_timing_info(0, elapsed, cpu_time);
  --     ...
  --     get_timing_info(1, elapsed, cpu_time);
  --
  -- RETURN:
  --     None
  --
  ---------------------------------------------------------------------------- 
  PROCEDURE get_timing_info(
    phase      IN      BINARY_INTEGER,
    elapsed    IN OUT  NUMBER,
    cpu        IN OUT  NUMBER);

  ------------------------------ format_message ------------------------------
  -- NAME: 
  --     format_message
  --
  -- DESCRIPTION:
  --     This function format an Oracle message, for example an error message.
  --
  -- PARAMETERS:
  --     message_number   (IN)     - message number (or error number)
  --     message_facility (IN)     - message facility
  --     language         (IN)     - nls language to use, null for session one
  --     arg1             (IN)     - argument 1 if any
  --     arg2             (IN)     - argument 2 if any
  --     arg3             (IN)     - argument 3 if any
  --     arg4             (IN)     - argument 4 if any
  --     arg5             (IN)     - argument 5 if any
  --     arg6             (IN)     - argument 6 if any
  --     arg7             (IN)     - argument 7 if any
  --     arg8             (IN)     - argument 8 if any
  --     arg9             (IN)     - argument 9 if any
  --     arg10            (IN)     - argument 10 if any
  --     arg11            (IN)     - argument 11 if any
  --     arg12            (IN)     - argument 12 if any
  --
  --
  -- DESCRIPTION
  --   Get the formatted message for the specified parameters
  --
  -- RETURN:
  --   Formatted message
  --
  ---------------------------------------------------------------------------- 
  FUNCTION format_message(
    message_number        IN      PLS_INTEGER,
    message_facility      IN      VARCHAR2 default 'ora',
    language              IN      VARCHAR2 default NULL,
    arg1                  IN      VARCHAR2 default NULL,
    arg2                  IN      VARCHAR2 default NULL,
    arg3                  IN      VARCHAR2 default NULL,
    arg4                  IN      VARCHAR2 default NULL,
    arg5                  IN      VARCHAR2 default NULL,
    arg6                  IN      VARCHAR2 default NULL,
    arg7                  IN      VARCHAR2 default NULL,
    arg8                  IN      VARCHAR2 default NULL,
    arg9                  IN      VARCHAR2 default NULL,
    arg10                 IN      VARCHAR2 default NULL,
    arg11                 IN      VARCHAR2 default NULL,
    arg12                 IN      VARCHAR2 default NULL)
  RETURN VARCHAR2 ;

  ----------------------- get_imported_report_attrs ---------------------
  --  NAME: get_imported_report_attrs
  --    This is the procedure that will return database 
  --    attributes from imported AWR data
  --
  -- PARAMETERS:  
  --    p_dbid           (IN)   - target database identifier
  --    p_inst_count     (OUT)  - number of instances in RAC
  --    p_cpu_cores      (OUT)  - number of CPU cores
  --    p_hyperthreaded  (OUT)  - 1 if target database is hyperthreaded
  --    p_con_id         (OUT)  - current container id if CDB
  --    p_con_name       (OUT)  - current container name if CDB
  --    p_is_exa         (OUT)  - 1 if target database is exadata
  --    p_timezone_offset(OUT)  - timezone off UTC,
  --    p_packs          (OUT)  - 2 if target database has diag+tunning
  --                              1 if diag pack only
  --                              0 no management packs installed
  --
  ----------------------------------------------------------------------- 
  PROCEDURE get_imported_report_attrs (
    p_dbid                  IN       NUMBER,
    p_inst_count            OUT      NUMBER,
    p_cpu_cores             OUT      NUMBER,
    p_hyperthreaded         OUT      NUMBER,
    p_con_id                OUT      NUMBER,
    p_con_name              OUT      VARCHAR2,
    p_is_exa                OUT      NUMBER,
    p_timezone_offset       OUT      NUMBER,
    p_packs                 OUT      NUMBER
   );

  -- -------------------- i_get_snap_id ---------------------------------
  -- NAME:
  --    i_get_snap_id
  --
  -- DESCRIPTION
  --    finds closest snap_id to specified time
  --
  -- PARAMETERS
  --    p_time (IN) - time for which to find the closest snap_id
  --    p_dbid (IN) - dbid to query n AWR
  -- NOTE:
  --
  -- RETURNS:
  --    snap_id
  -- --------------------------------------------------------------------
  FUNCTION get_snap_id(p_time IN date, p_dbid IN NUMBER)
  RETURN NUMBER;

  -- ----------------------- get_awr_context ----------------------------
  -- NAME:
  --    get_awr_context
  --
  -- DESCRIPTION
  --    gets up AWR begin/end snapshot for the report
  --
  -- PARAMETERS
  --    p_start_time     (IN) - start time for report
  --    p_end_time       (IN) - end time for report
  --    p_dbid       (IN/OUT) - dbid to query. If null default 
  --                            is current dbid
  --    p_begin_snap (IN/OUT) - sets begin snap for report
  --    p_end_snap   (IN/OUT) - sets end snap for report
  -- -------------------------------------------------------------------
  PROCEDURE get_awr_context(
    p_start_time IN     DATE,
    p_end_time   IN     DATE,
    p_dbid       IN OUT NUMBER,
    p_begin_snap IN OUT NUMBER,
    p_end_snap   IN OUT NUMBER);

  -- ----------------------- get_awr_diff_context ----------------------------
  -- NAME:
  --    get_awr_diff_context
  --
  -- DESCRIPTION
  --    gets AWR begin/end snapshot for base and comparison period
  --    for the diff report
  --
  -- PARAMETERS
  --    p_begin_snap1 (IN/OUT) - sets begin snap for first period
  --    p_end_snap1   (IN/OUT) - sets end snap for first period
  --    p_dbid1       (IN)     - dbid for first period
  --    p_begin_snap2 (IN/OUT) - sets begin snap for second period
  --    p_end_snap2   (IN/OUT) - sets end snap for second period
  --    p_dbid2       (IN)     - dbid for second period

  -- -------------------------------------------------------------------
  PROCEDURE get_awr_diff_context(
    p_begin_snap1 IN OUT NUMBER,
    p_end_snap1   IN OUT NUMBER,
    p_dbid1       IN     NUMBER,
    p_begin_snap2 IN OUT NUMBER,
    p_end_snap2   IN OUT NUMBER,
    p_dbid2       IN     NUMBER);

end;
/

show errors
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_REPORT FOR DBMS_REPORT
/

GRANT EXECUTE ON DBMS_REPORT TO PUBLIC
/

CREATE OR REPLACE LIBRARY DBMS_REPORT_LIB trusted as static
/

@?/rdbms/admin/sqlsessend.sql
