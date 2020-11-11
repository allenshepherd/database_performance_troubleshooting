Rem
Rem $Header: rdbms/admin/dbmsmetu.sql /main/96 2017/09/28 21:35:06 tbhukya Exp $
Rem
Rem dbmsmetu.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     dbmsmetu.sql - Package header for DBMS_METADATA_UTIL.
Rem     NOTE - Package body is in:
Rem            /vobs/rdbms/src/server/datapump/ddl/prvtmetu.sql
Rem    DESCRIPTION
Rem     This file contains the package header for DBMS_METADATA_UTIL,
Rem     a definer's rights package that implements functions used by
Rem     both DBMS_METADATA and DBMS_METADATA_INT
Rem
Rem    FUNCTIONS / PROCEDURES
Rem     PUT_LINE        - Write debugging output.
Rem     PUT_BOOL        - Write debugging output.
Rem     VSN2NUM         - Convert version string to number.
Rem     GET_COMPAT_VSN  - Return the compatibility version number as a number.
Rem     GET_DB_VSN      - Return the database version number as a string
Rem     GET_CANONICAL_VSN - Convert user's VERSION param to canonical form.
Rem     CONVERT_TO_CANONICAL - Convert VERSION string to canonical form.
Rem     GET_LATEST_VSN  - Return a number for the latest version number.
Rem     GET_OPEN_MODE   - Return database open mode (read only, read write)
Rem     LONG2VARCHAR    - Convert a table LONG value to a VARCHAR2.
Rem     LONG2VCMAX      - Convert a table LONG value to a VARCHAR2 and each
Rem                       line max length is 2000.
Rem     LONG2VCNT       - Convert a table LONG value to a nested table of
Rem                        VARCHAR2.
Rem     LONG2CLOB       - Convert a table LONG value to a CLOB.
Rem     PARSE_CONDITION - Return a check condition as XML
Rem     PARSE_DEFAULT   - Return the default value of a virt col as XML
Rem     PARSE_QUERY     - Return a query as XML
Rem     NULLTOCHR0      - Replace \0 with CHR(0) in varchar
Rem     GET_SOURCE_LINES- Fetch/annotate lines from source$.
Rem     PARSE_TRIGGER_DEFINITION - Return annotated trigger definition.
Rem     GET_PROCOBJ_ERRORS - Get any errors raised by procedural object code
Rem     SAVE_PROCOBJ_ERRORS - Save errors raised by procedural object code
Rem     GET_AUDIT       - Return audit information for a schema object.
Rem     GET_AUDIT_DEFAULT - Return default object audit information setting.
Rem     GET_ANC         - Get the object number of the base table to which
Rem                        a nested table belongs
Rem     GET_ENDIANNESS  - Determine platform endianness.
Rem     SET_VERS_DPAPI  - Save DPAPI version.
Rem     GET_VERS_DPAPI  - Retrieve DPAPI version.
Rem     LOAD_STYLESHEETS- Load the XSL stylesheets into the database
Rem     ARE_STYLESHEETS_LOADED - Are the XSL stylesheets loaded?
Rem     SET_DEBUG       - Set the internal debug switch.
Rem     PATCH_TYPEID    - For transportable import, modify a type's typeid.
Rem     CHECK_TYPE      - For transportable import, check a type's definition
Rem                       and typeid.
Rem     WRITE_CLOB      - Write a CLOB to the trace file
Rem     IS_OMF          - determine if a name is a Oracle Managed File (OMF)
Rem     BLOB2CLOB       - Convert a column default blob value to a clob.
Rem     GET_BASE_INTCOL_NUM - Return intcol# of base column, i.e., the
Rem                           intcol# of the first column with this col#
Rem     GET_BASE_COL_TYPE - Return 1 if base column is udt, 
Rem                           2 if base column is XMLType stored OR or CSX
Rem                           3 if base column is XMLType stored as CLOB
Rem                           0 if (a) intcol = base column or
Rem                                (b) base column not udt or XMLType
Rem     REF_PAR_LEVEL   - return level of ref partitioned child table
Rem     REF_PAR_PARENT  - return object number of ref partitioned parent table
Rem     TABLE_TSNUM     - get canonical tablespace# a table
Rem     GET_EDITIONID   - return ID for specified edition
Rem     GET_INDEX_INTCOL - Get intcol# in table of column on which index is
Rem                        defined (need special handling for xmltype cols)
Rem     HAS_TSTZ_COLS - Determine whether a table has data of type DTYSTZ
Rem     DELETE_XMLSCHEMA
Rem     LOAD_XSD
Rem     GET_XMLHIERARCHY - return 'Y' if table is hierachy enabled, else null
Rem     GET_XMLCOLSET   - OR storage columns for xmltype
Rem     GET_BASE_COL_NAME - Return name of base_col, if xmltype
Rem     IS_SCHEMANAME_EXISTS - Returns 1 if schema name exists in trigger 
Rem                            definition otherwise 0.
Rem     GET_MARKER      - returns the current marker number
Rem     SET_MARKER      - sets the current marker number
Rem     GET_STRM_MINVER: Retrieve stream minor version based on job version
Rem     SET_BLOCK_ESTIMATE - set state for estimate phase
Rem     BLOCK_ESTIMATE - calculate bytes_allocated using BLOCKS method
Rem     FUNC_INDEX_DEFAULT - get col$.default$ as a valid VARCHAR with no nulls
Rem     FUNC_INDEX_DEFAULTC - get col$.default$ as a valid CLOB with no nulls
Rem     IS_ACTIVE_REGISTRATION - Should current imp. callout object be exported
Rem                              based on target import version?
Rem     GET_QA_LRG_TYPE - Return the value of _qa_lrg_type
Rem 
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsmetu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsmetu.sql
Rem SQL_PHASE: DBMSMETU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     tbhukya    09/24/17 - Bug 26744170: Add get_lost_write_protection func
Rem     jstenois   02/23/17 - 25410933: merge PARSE_* functions into prvtmeta
Rem     sdavidso   01/27/17 - bug25225293 have catmettypes.sql execute before
Rem                           dbmsmeta.sql
Rem     tbhukya    11/17/16 - Bug 24829009: Add check_constraint
Rem    jjanosik    08/22/16 - bug 24387072 - add get_qa_lrg_type
Rem    sdipirro    08/08/16 - XbranchMerge sdipirro_bug-24309190_12.2.0.1.0
Rem                           from st_rdbms_12.2.0.1.0
Rem    sdipirro    08/01/16 - XbranchMerge sdipirro_bug-24309190 from main
Rem    sdipirro    07/18/16 - Fix constant declarations to be constants
Rem    rapayne     02/22/16 - bug 22778159 - moved is_active_registration from
Rem                           prvtmetu to prvtmeta.
Rem    sogugupt    12/23/14 - Bug 17535230: impdp fails with ora-6502 / lpx-217
Rem    sdavidso    06/16/14 - Support metadata parallel
Rem    bwright     01/01/14 - Bug 17952171: Fix type versioning source lines
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    bwright     08/14/13 - Bug 17312600: Remove hard tabs from DP src code
Rem    gclaborn    07/31/13 - 17247965: Add version support for import callouts
Rem    lbarton     04/24/13 - bug 16716831: functional index expression as
Rem                           varchar or clob
Rem    lbarton     02/21/13 - bug 13386193: null byte in column default
Rem    sdavidso    02/18/13 - Bug16051676: transportable partitioned index
Rem                           export
Rem    sdavidso    12/24/12 - XbranchMerge sdavidso_bug14490576-2 from
Rem                           st_rdbms_12.1.0.1
Rem    sdavidso    12/14/12 - bug14490576: add table_tsnum
Rem    dgagne      10/24/12 - add fetch_stat for stat tables
Rem    dgagne      10/19/12 - bug12866600
Rem    rapayne     06/12/12 - add col$.property parameter to blob2clob function.
Rem    lbarton     05/02/12 - 36954_dpump_tabcluster_zonemap
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sdavidso    03/26/12 - bug-13844935: use function for part# frag#
Rem    ebatbout    10/17/11 - bug 12781157: Unpacked Opaque type column support
Rem     mjangir    07/26/11  - bug 12325243: Add GET_INDEX_INTCOL_PARSE
Rem                            function
Rem    lbarton     07/22/11 - bug 12780993: speed up estimate=stats
Rem    sdavidso    06/21/11 - for hierarchy enabled xmltype
Rem    ebatbout    06/09/11 - bug 9796431: Add rtn, get_strm_minver
Rem    ebatbout    04/22/11 - bug 9223960: Add new field, post_atname_off,
Rem                           to type, ku$_source_t
Rem    lbarton     03/16/11 - bug 10363497: performance of nested tables
Rem    gclaborn    02/02/11 - em -> Rem
Rem    sdavidso    01/24/11 - merge project 37216 bl1
Rem    sdavidso    09/29/10 - bug10107749: long 'replace null with' value
Rem    tbhukya     07/12/10 - BUG 9841333: Add IS_SCHEMANAME_EXISTS function
Rem    sdavidso    03/22/10 - Bug 8847153: reduce resources for xmlschema
Rem                           export
Rem    lbarton     03/23/09 - bug 8347514: parse read-only view query
Rem    sdavidso    02/27/09 - bug 7567327 - ORA-904 importing xmltype
Rem    sdavidso    03/06/09 - bug 8328108: add xml exclusion option to get_anc
Rem    lbarton     11/13/08 - TSTZ support
Rem    lbarton     12/30/08 - Bug 7354560: modify GET_SOURCE_LINES to trim
Rem                           trailing newline
Rem    sdavidso    12/16/08 - bug 7620558: problems w/xmltype,ADT,nested tables
Rem    lbarton     06/10/08 - add xmlschema load/unload routines
Rem    lbarton     04/22/08 - bug 6730161: move get_hashcode to dbmsmeta
Rem    msakayed    04/17/08 - compression/encryption feature tracking for 11.2
Rem    lbarton     02/05/08 - bug 6029076: query parsing; remove SET_PARSING
Rem    lbarton     01/31/08 - bug 5961283: get uncorrupted hashcode
Rem    lbarton     11/26/07 - bug 6454237: parse trigger definition
Rem    lbarton     10/31/07 - bug 6051635: domain index on xmltype col
Rem    htseng      04/23/07 - fix bug 5690152 - add post_keyw and pre_name_len 
Rem                           to source_t
Rem    msakayed    10/17/06 - Add UpdateFeatureTable for feature usage
Rem    sdavidso    09/22/06 - edition support
Rem    lbarton     07/18/06 - bug 5386908: get_xmltype_fmts 
Rem    sdavidso    07/20/06 - modify ref_par_parent 
Rem    lbarton     02/21/06 - PARSE_CONDITION, PARSE_DEFAULT, PARSE_QUERY
Rem    lbarton     10/05/05 - bug 4516042: xmlschemas and SB tables in Data 
Rem                           Pump 
Rem    htseng      05/30/06 - add binary2varchar 
Rem    sdavidso    05/12/06 - support for ref partitioning 
Rem    rapayne     10/24/05 - Bug 4675928: add convert_to_canonical.
Rem    sdavidso    12/08/05 - add function for attrname 
Rem    sdavidso    11/15/05 - Add routine to get fully qualified attrname 
Rem    sdavidso    08/22/05 - add function to check for OMF files 
Rem    rpfau       10/15/04 - bug 3599656 - Add check_type routine. 
Rem    rapayne     10/15/04 - add prototypes for get_col_property
Rem    lbarton     09/01/04 - Bug 3827736: add NULLTOCHR0 function 
Rem    lbarton     06/16/04 - Bug 3695154: add ARE_STYLESHEETS_LOADED 
Rem                           Modify LOAD_STYLESHEETS: dirpath not needed
Rem    lbarton     03/31/04 - Bug 3225530: use supplied version for domidx 
Rem    lbarton     01/07/04 - Bug 3358912: force lob big endian 
Rem    lbarton     11/04/03 - network debug 
Rem    lbarton     10/02/03 - Bug 3167541: run domain index metadata code as 
Rem                           cur user 
Rem    lbarton     09/16/03 - Bug 3121396: run procobj code as cur user
Rem    lbarton     08/12/03 - Bug 3082230: increase size of line_of_code 
Rem    lbarton     07/31/03 - Bug 3056720: change long2clob interface
Rem    lbarton     07/17/03 - Bug 3045926: restructure ku$_procobj_lines
Rem    lbarton     07/03/03 - Bug 3016951: add patch_typeid
Rem    lbarton     06/06/03 - Bug 2849559: report errors from proc. actions
Rem    lbarton     05/01/03 - Bug 2925579: set transportable state
Rem    gclaborn    05/20/03 - Remove select_mode
Rem    lbarton     04/10/03 - bug 2893918: add PARSE_TRIGGER_DEFINITION
Rem    lbarton     04/04/03 - bug 2844111: add GET_SOURCE_LINES function
Rem    nmanappa    12/27/02 - Adding get_audit_default
Rem    lbarton     11/08/02 - new types for procedural objects
Rem    lbarton     10/23/02 - Test for READ_ONLY database
Rem    gclaborn    11/12/02 - add write_clob
Rem    htseng      12/11/02 - fix long2varchar each line >2499
Rem    lbarton     08/02/02 - transportable export
Rem    htseng      06/25/02 - add post/pre table action support
Rem    lbarton     05/01/02 - domain index support
Rem    lbarton     04/25/02 - change CREATE SYNONYM to CREATE OR REPLACE
Rem    htseng      05/08/02 - add GET_PROCOBJ_GRANT.
Rem    htseng      05/02/02 - add procedural objects and actions API support.
Rem    lbarton     04/10/02 - add DPSTREAM_TABLE object
Rem    lbarton     03/21/02 - tweak select_mode
Rem    htseng      04/04/02 - add get_refresh_make and get_refresh_add function
Rem    lbarton     03/14/02 - add select_mode
Rem    htseng      12/07/01 - add java object support.
Rem    lbarton     11/27/01 - better error messages
Rem    lbarton     09/10/01 - Merged lbarton_mdapi_reorg
Rem    lbarton     09/05/01 - Split off from dbmsmeta.sql
Rem

@@?/rdbms/admin/sqlsessstart.sql



CREATE OR REPLACE PACKAGE dbms_metadata_util AUTHID DEFINER AS 
------------------------------------------------------------
-- Overview
-- This pkg implements utility functions of the mdAPI.
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS. It runs with definers, not invokers rights
-- because it needs to access dictionary tables.

-------------
-- EXCEPTIONS
--
  invalid_argval EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_argval, -31600);
    invalid_argval_num CONSTANT NUMBER := -31600;
-- "Invalid input value %s for parameter %s in function %s"
-- *Cause:  A NULL or invalid value was supplied for the parameter.
-- *Action: Correct the input value and try the call again.

  invalid_operation EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_operation, -31601);
    invalid_operation_num CONSTANT NUMBER := -31601;
-- "Function %s cannot be called now that fetch has begun"
-- *Cause:  The function was called after the first call to FETCH_xxx.
-- *Action: Correct the program.

  inconsistent_args EXCEPTION;
    PRAGMA EXCEPTION_INIT(inconsistent_args, -31602);
    inconsistent_args_num CONSTANT NUMBER := -31602;
-- "parameter %s value \"%s\" in function %s inconsistent with %s"
-- "Value \"%s\" for parameter %s in function %s is inconsistent with %s"
-- *Cause:  The parameter value is inconsistent with another value specified
--          by the program.  It may be not valid for the the object type
--          associated with the OPEN context, or it may be of the wrong
--          datatype: a boolean rather than a text string or vice versa.
-- *Action: Correct the program.

  object_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(object_not_found, -31603);
    object_not_found_num CONSTANT NUMBER := -31603;
-- "object \"%s\" of type %s not found in schema \"%s\""
-- *Cause:  The specified object was not found in the database.
-- *Action: Correct the object specification and try the call again.

  invalid_object_param EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_object_param, -31604);
    invalid_object_param_num CONSTANT NUMBER := -31604;
-- "invalid %s parameter \"%s\" for object type %s in function %s"
-- *Cause:  The specified parameter value is not valid for this object type.
-- *Action: Correct the parameter and try the call again.

  inconsistent_operation EXCEPTION;
    PRAGMA EXCEPTION_INIT(inconsistent_operation, -31607);
    inconsistent_operation_num CONSTANT NUMBER := -31607;
-- "Function %s is inconsistent with transform."
-- *Cause:  Either (1) FETCH_XML was called when the "DDL" transform
--          was specified, or (2) FETCH_DDL was called when the
--          "DDL" transform was omitted.
-- *Action: Correct the program.

  object_not_found2 EXCEPTION;
    PRAGMA EXCEPTION_INIT(object_not_found2, -31608);
    object_not_found2_num CONSTANT NUMBER := -31608;
-- "specified object of type %s not found"
-- (Used by GET_DEPENDENT_xxx and GET_GRANTED_xxx.)
-- *Cause:  The specified object was not found in the database.
-- *Action: Correct the object specification and try the call again.

  stylesheet_load_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(stylesheet_load_error, -31609);
    stylesheet_load_error_num CONSTANT NUMBER := -31609;
-- "error loading file %s from file system directory \'%s\'"
-- *Cause:  The installation script initmeta.sql failed to load
--          the named file from the file system directory into the database.
-- *Action: Examine the directory and see if the file is present
--          and can be read.

  procobj_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(procobj_error, -39127);
    procobj_error_num CONSTANT NUMBER := -39127;
-- "Unexpected error from call to %s \n%s"
-- *Cause:  The exception was raised by the function invocation.
-- *Action: Record the accompanying messages and report this as a Data Pump
--          internal error to customer support. 

  bad_hashcode EXCEPTION;
    PRAGMA EXCEPTION_INIT(bad_hashcode, -39132);
    bad_hashcode_num CONSTANT NUMBER := -39132;
-- "Object type \"%s\".\"%s\" already exists with different hashcode"
-- *Cause:  An object type cannot be created because it already exists on the 
--          target system, but with a different hashcode.  Tables in the
--          transportable tablespace set which use this object type
--          cannot be read.
-- *Action: Drop the object type from the target system and retry the 
--          operation. 

  type_in_use EXCEPTION;
    PRAGMA EXCEPTION_INIT(type_in_use, -39133);
    type_in_use_num CONSTANT NUMBER := -39133;
-- "Object type \"%s\".\"%s\" already exists with different typeid"
-- *Cause:  An object type in a transportable tablespace set already exists
--          on the target system, but with a different typeid.  The typeid
--          cannot be changed because the type is used by an existing table.
--          Tables in the transportable tablespace set which use this object
--          type cannot be read.
-- *Action: Drop the object type from the target system and retry the 
--          operation. 

---------------------------

-- PACKAGE VARIABLES

---------------------------

-- PROCEDURES AND FUNCTIONS
--
-- PUT_LINE: Does a DBMS_OUTPUT.PUT_LINE regardless of string length; i.e,
--              works with strings > 255.

  PROCEDURE put_line(stmt IN VARCHAR2, pfx IN VARCHAR2 := NULL);

-- PUT_BOOL: Convenience function.

  PROCEDURE put_bool(
        stmt    IN VARCHAR2,
        value   IN BOOLEAN);


-- VSN2NUM: Convert a dot-separated version string (e.g., '8.1.6.0.0')
--   to a number (e.g., 8010600000).

  FUNCTION vsn2num (
                vsn             IN  VARCHAR2)
        RETURN NUMBER;

-- GET_COMPAT_VSN: return the compatibility version number as a number.
--       E.g., if compatibility='8.1.6', return 801060000.

  FUNCTION get_compat_vsn
        RETURN NUMBER;

-- GET_ATTRNAME: attrname for a table-column.

  FUNCTION get_attrname ( obj    IN NUMBER, 
                              intcol IN NUMBER)
        RETURN VARCHAR2;

-- GET_FULLATTRNAME: return fully qualified attrname, when attrname is a 
--                     system generated name.

  FUNCTION get_fullattrname ( obj    IN NUMBER, 
                              col    IN NUMBER, 
                              intcol IN NUMBER, 
                              type   IN NUMBER)
        RETURN VARCHAR2;

-- GET_DB_VSN: return the database version number as a string
--       in the format vv.vv.vv.vv.vv, e.g., '08.01.03.00.00'

  FUNCTION get_db_vsn
        RETURN VARCHAR2;

-- GET_CANONICAL_VSN: convert the user's VERSION param to a string
--       in the format vv.vv.vv.vv.vv, e.g., '08.01.03.00.00'
-- PARAMETERS:
--      version         - The version from DBMS_METADATA.OPEN.
--              Values can be 'COMPATIBLE' (default), 'LATEST' or a specific
--              version number.

  FUNCTION get_canonical_vsn(version IN VARCHAR2)
        RETURN VARCHAR2;

---------------------------------------------------------------------
-- CONVERT_TO_CANONICAL: Convert string to canonical form
--       vv.vv.vv.vv.vv, e.g., '08.01.03.00.00'
-- PARAMETERS:
--      version         - version string (e.g., 10.2.0.2)

  FUNCTION convert_to_canonical(version IN VARCHAR2)
        RETURN VARCHAR2;


-- GET_LATEST_VSN: return a number that will serve as the latest version number

  FUNCTION get_latest_vsn
        RETURN NUMBER;


-- GET_OPEN_MODE: return a number signifying the open mode of the database
-- RETURNS:     0 = MOUNTED
--              1 = READ WRITE
--              2 = READ ONLY

  FUNCTION get_open_mode
        RETURN NUMBER;

-- LONG2VARCHAR: Convert a LONG column value to a VARCHAR2
-- PARAMETERS:
--      length          - length of the LONG
--      tab             - table name
--      col             - column name
--      row             - rowid of the row
-- RETURNS:     LONG value converted to VARCHAR2 if length <= 4000
--              otherwise NULL

  FUNCTION long2varchar(
                length          IN  NUMBER,
                tab             IN  VARCHAR2,
                col             IN  VARCHAR2,
                row             IN  UROWID)
        RETURN VARCHAR2;

-- LONG2VCMAX: Convert a LONG column value to a VARCHAR2 and each line
--                  max length is 2000
-- PARAMETERS:
--      length          - length of the LONG
--      tab             - table name
--      col             - column name
--      row             - rowid of the row
-- RETURNS:     LONG value converted to VARCHAR2 
--              otherwise NULL


  FUNCTION long2vcmax(
                length          IN  NUMBER,
                tab             IN  VARCHAR2,
                col             IN  VARCHAR2,
                row             IN  UROWID)
        RETURN sys.ku$_vcnt;

-- LONG2VCNT: Convert a LONG column value to an array of VARCHAR2
-- PARAMETERS:
--      length          - length of the LONG
--      tab             - table name
--      col             - column name
--      row             - rowid of the row
-- RETURNS:     LONG value converted to array of VARCHAR2 if length > 4000
--              otherwise NULL

  FUNCTION long2vcnt(
                length          IN  NUMBER,
                tab             IN  VARCHAR2,
                col             IN  VARCHAR2,
                row             IN  UROWID)
        RETURN sys.ku$_vcnt;

-- LONG2CLOB: Convert a LONG column value to a CLOB
-- PARAMETERS:
--      length          - length of the LONG
--      tab             - table name
--      col             - column name
--      row             - rowid of the row
-- RETURNS:     LONG value converted to temporary CLOB if length > 4000
--              otherwise NULL

  FUNCTION long2clob(
                length          IN  NUMBER,
                tab             IN  VARCHAR2,
                col             IN  VARCHAR2,
                row             IN  ROWID)
        RETURN CLOB;


-- NULLTOCHR0 - Replace \0 with CHR(0) in varchar
-- PARAMETERS:
--      value           - varchar value
--      replace_quote   - TRUE = replace ' with ''
-- RETURNS: varchar value with substitutions made

  FUNCTION nulltochr0(
                value           IN  VARCHAR2,
                replace_quote   IN  BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2;

-- GET_SOURCE_LINES: Get records from source$ for the object
-- and annotate them to make xsl processing easier.
-- PARAMETERS:
--      obj_name        - name of object
--      obj_num         - obj# of object
--      type_num        - type# of object
-- RETURNS:     Nested table containing the source lines

  FUNCTION get_source_lines(
                obj_name        IN  VARCHAR2,
                obj_num         IN  NUMBER,
                type_num        IN  NUMBER)
        RETURN sys.ku$_source_list_t;

-- PARSE_TRIGGER_DEFINITION: Return "annotated" trigger definition
--  to make xsl processing easier.
-- PARAMETERS:
--      owner           - owner name
--      obj_name        - trigger name
--      definition      - the definition from trigger$
-- RETURNS:     The annotated definition 

  FUNCTION  parse_trigger_definition(
                owner           IN  VARCHAR2,
                obj_name        IN  VARCHAR2,
                definition      IN  VARCHAR2)
        RETURN sys.ku$_source_t;

-- SAVE_PROCOBJ_ERRORS: Construct a text string for a raised exception
-- and store it in the package variable 'procobj_errors'.

  PROCEDURE save_procobj_errors(
                sql_stmt        IN  VARCHAR2 );

-- GET_PROCOBJ_ERRORS: Retrieve saved errors and reset state.
-- PARAMETERS:
--              err_list        - the saved errors
-- RETURN VALUE:
--              error count

  PROCEDURE get_procobj_errors(
                err_list        OUT sys.ku$_vcnt);

-- GET_AUDIT: Return audit information for a schema object.
-- PARAMETERS:
--      obj_num         - object number
--      type_num        - object type
-- RETURNS: nested table of audit settings

 FUNCTION get_audit(
                obj_num         IN  NUMBER,
                type_num        IN  NUMBER )
        RETURN sys.ku$_audit_list_t;

-- GET_AUDIT_DEFAULT: Return default object audit information setting.
-- PARAMETERS:
--      obj_num         - object number
-- RETURNS: nested table of default audit settings

 FUNCTION get_audit_default(
                obj_num         IN  NUMBER)
        RETURN sys.ku$_audit_default_list_t;


-- GET_ANC: Get the object number of the base table to which
--      a nested table belongs
-- PARAMETERS:
--      nt              - obj# of the nested table
--      exclude_xml     - 0 - return anc for all NTs
--                        1 - exclude NTs for XMLtype OR storage 
--                        2 - include only NTs for XMLtype OR storage 
-- RETURNS:
--      obj# of the base table

 FUNCTION get_anc(
                nt              IN NUMBER,
                exclude_xml     IN NUMBER := 1)
        RETURN NUMBER;


-- GET_ENDIANNESS: function to determine endianness:
-- RETURNS:
--      1 = big_endian
--      2 = little_endian

 FUNCTION get_endianness
        RETURN NUMBER;

-- SET_VERS_DPAPI: Save Direct Path API version.
-- PARAMETERS:
--      version         - version number

 PROCEDURE set_vers_dpapi (
                version         IN  NUMBER);

-- GET_VERS_DPAPI: Retrieve saved Direct Path API version.
-- RETURNS: version number

 FUNCTION get_vers_dpapi
        RETURN NUMBER;

-- SET_FORCE_LOB_BE: Save the 'force_lob_be' switch.
-- PARAMETERS:
--      value          - switch value

 PROCEDURE set_force_lob_be (
                value           IN  BOOLEAN);

-- SET_FORCE_NO_ENCRYPT: Save the 'force_no_encrypt' switch.
-- PARAMETERS:
--      value          - switch value

 PROCEDURE set_force_no_encrypt (
                value           IN  BOOLEAN);


-- GET_LOB_PROPERTY: Return lob$.property (but clear bit 0x0200 if
--    force_lob_be is set; 0x0200 = LOB data in little endian format).
-- PARAMETERS:
--      objnum         - obj# of table
--      intcol_num     - intcol# of column
-- RETURNS: lob$.property, maybe with bit 0x0200 cleared

 FUNCTION get_lob_property (
                objnum          IN  NUMBER,
                intcol_num      IN  NUMBER)
        RETURN NUMBER;

-- GET_COL_PROPERTY: Return col$.property (but clear encryption bits if
--    force_no_encrypt flag is set:
--           0x04000000 =  67108864 = Column is encrypted
--           0x20000000 = 536870912 = Column is encrypted without salt
--           This is necessary when users do not specify an 
--           encryption_password and the data is written to the dumpfile 
--           in clear text although the col properity retains the 
--           encrypt property.
-- PARAMETERS:
--      objnum         - obj# of table
--      intcol_num     - intcol# of column
-- RETURNS: col$.property, maybe with encryption bits cleared
 FUNCTION get_col_property (
                objnum          IN  NUMBER,
                intcol_num      IN  NUMBER)
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_REFRESH_MAKE_USER: Return refresh group dbms_refresh.make execute string
-- PARAMETERS:
--      group_id        - refresh group id 
-- RETURNS: executing string 

 FUNCTION get_refresh_make_user (
                group_id        IN  NUMBER)
        RETURN varchar2;

---------------------------------------------------------------------
-- GET_REFRESH_ADD_USER: Return refresh group dbms_refresh.add execute string
-- PARAMETERS:
--      owner   - snapshot owner
--      child   - snapshot name
--      type    - type name
--      instsite - site id 
-- RETURNS: executing string 
  FUNCTION get_refresh_add_user (               
                owner           IN  VARCHAR2,
                child           IN  VARCHAR2,
                type            IN  VARCHAR2,
                instsite        IN VARCHAR2
                )
        RETURN varchar2;

---------------------------------------------------------------------
-- GET_REFRESH_MAKE_DBA: Return refresh group dbms_irefresh.make execute string
-- PARAMETERS:
--      group_id        - refresh group id 
-- RETURNS: executing string 

 FUNCTION get_refresh_make_dba (
                group_id        IN  NUMBER)
        RETURN varchar2;

---------------------------------------------------------------------
-- GET_REFRESH_ADD_DBA: Return refresh group dbms_irefresh.add execute string
-- PARAMETERS:
--      owner   - snapshot owner
--      child   - snapshot name
--      type    - type name
--      instsite - site id 
-- RETURNS: executing string 
  FUNCTION get_refresh_add_dba (                
                owner           IN  VARCHAR2,
                child           IN  VARCHAR2,
                type            IN  VARCHAR2,
                instsite        IN VARCHAR2
                )
        RETURN varchar2;

---------------------------------------------------------------------
-- LOAD_STYLESHEETS: Load the XSL stylesheets into the database

  PROCEDURE load_stylesheets;

---------------------------------------------------------------------
-- ARE_STYLESHEETS_LOADED: Are the XSL stylesheets loaded?
-- RETURNS: FALSE = definitely not

  FUNCTION are_stylesheets_loaded
        RETURN BOOLEAN;

---------------------------------------------------------------------
-- SET_DEBUG: Set the internal debug switch.
-- PARAMETERS:
--      on_off          - new switch state.

  PROCEDURE set_debug(
                on_off          IN BOOLEAN,
                force_trace     IN BOOLEAN DEFAULT FALSE);

-----------------------------------------------------------------------
-- PATCH_TYPEID: For transportable import, modify a type's typeid.
-- PARAMETERS:
--      schema   - the type's schema
--      name     - the type's name
--      typeid   - the type's typeid
--      hashcode - the type's hashcode

  PROCEDURE patch_typeid (
                schema          IN VARCHAR2,
                name            IN VARCHAR2,
                typeid          IN VARCHAR2,
                hashcode        IN VARCHAR2);

-----------------------------------------------------------------------
-- CHECK_TYPE: For transportable import, check a type's definition (using the
--             hashcode) and typeid for a match against the one from the
--             export source database. This will catch differences in
--             a pre-existing type with the same name which already exists on
--             the import target database. This routine is called for each
--             referenced type right before a create table call is made.
--             If any of these calls raises an exception, then the table
--             is not created.
-- PARAMS:
--      schema     - schema of type
--      type_name  - type name
--      version    - internal stored verson of type
--      hashcode   - hashcode of the type defn
--      typeid     - subtype typeid ('' if no subtypes)
-- RETURNS: Nothing, returns if the hashcode and version match. Raises an
--          nnn exception if the type does not exist in the db or if the
--          type exists but the hash code and/or the version number does 
--          not match.
--          
PROCEDURE check_type    (schema     IN VARCHAR2,
                         type_name  IN VARCHAR2,
                         version    IN VARCHAR2,
                         hashcode   IN VARCHAR2,
                         typeid     IN VARCHAR2);


-----------------------------------------------------------------------
-- WRITE_CLOB : Write a CLOB to the trace file

  PROCEDURE write_clob(xml IN CLOB);

---------------------------------------------------------------------
-- IS_OMF: return 1 if name is an OMF, 0 otherwise.
-- PARAMETERS:
--      name    - a file name 
-- RETURNS: number 0 or 1

  FUNCTION is_omf (
                name            IN  VARCHAR2
                )
        RETURN number;

---------------------------------------------------------------------
-- table_tsnum: get canonical tablespace# for a table
-- 
-- PARAMETERS:
--      objnum    - object number of table
-- RETURNS: default tablespace for [root] parent table

  FUNCTION table_tsnum(
                objnum          IN NUMBER
                ) 
        RETURN number;

---------------------------------------------------------------------
-- ref_par_level: returns the level number of a reference partitioned
--      child table.
-- PARAMETERS:
--      objnum    - object number of target table
-- RETURNS: number 1 or greater

  FUNCTION ref_par_level (
                objnum          IN NUMBER
                ) 
        RETURN number;

  FUNCTION ref_par_level (
                objnum          IN NUMBER,
                properties      IN NUMBER
                ) 
        RETURN number;

  FUNCTION ref_par_parent (
                objnum          IN NUMBER
                ) 
        RETURN NUMBER;

----------------------------------------------------------------------------
-- GET_XMLTYPE_FMTS: Return formats of XMLType columns in a table
-- PARAMETERS:
--      objnum          - table object number
-- RETURNS:  0x01 = table has XMLType stored as CLOB
--           0x02 = table has XMLType stored OR or binary

  FUNCTION get_xmltype_fmts(
                objnum          IN number)
         RETURN NUMBER; 

----------------------------------------------------------------------------
-- BLOB2CLOB: Convert a column default replace null blob  to a clob
-- PARAMETERS:
--      tabobj          - tab object num 
--      incolnum        - incolumn num
--      property        - col$.property
-- RETURNS:     clob ( this is hex value to pass to hextoraw as argument) 

  FUNCTION blob2clob(
                tabobj          IN  NUMBER,
                incolnum        IN  NUMBER,
                property        IN  NUMBER)
        RETURN CLOB;

-----------------------------------------------------------------------
-- GET_BASE_INTCOL_NUM - Return intcol# of base column.
--                       For lobs associated with XMLType columns,
--                       this is the intcol# of the XMLType column;
--                       otherwise, intcol# of the first column with this col#
-- PARAMETERS:
--    objnum  - table obj#
--    colnum  - col# of this column
--    intcol  - intcol# of this column
--    typenum - type# of this column

  FUNCTION get_base_intcol_num (                
                objnum          IN  NUMBER,
                colnum          IN  NUMBER,
                intcol          IN  NUMBER,
                typenum         IN  NUMBER
                )
        RETURN NUMBER;

-----------------------------------------------------------------------
-- GET_BASE_COL_TYPE - Return 1 if base column is udt, 
--                            2 if base column is XMLType stored OR or CSX
--                            3 if base column is XMLType stored as LOB
--                            0 if intcol = base column or base column not
--                                  udt or XMLType
-- PARAMETERS:
--    objnum  - table obj#
--    colnum  - col# of this column
--    intcol  - intcol# of this column
--    typenum - type# of this column

  FUNCTION get_base_col_type (                
                objnum          IN  NUMBER,
                colnum          IN  NUMBER,
                intcol          IN  NUMBER,
                typenum         IN  NUMBER
                )
        RETURN NUMBER;

-----------------------------------------------------------------------
-- GET_BASE_COL_NAME - return name of base xmltype column
-- PARAMETERS:
--    objnum  - table obj#
--    colnum  - col# of this column
--    intcol  - intcol# of this column
--    typenum - type# of this column

  FUNCTION get_base_col_name (                
                objnum          IN  NUMBER,
                colnum          IN  NUMBER,
                intcol          IN  NUMBER,
                typenum         IN  NUMBER
                )
        RETURN VARCHAR2;

-----------------------------------------------------------------------
-- GET_EDITIONID        - Return the ID of a specified edition 
--                        an exception will be raised on a non-existent editn
-- PARAMETERS:
--    edition   - edition name

  FUNCTION get_editionid (                
                edition         IN  VARCHAR2
                )
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_INDEX_INTCOL_PARSE - Parse default_val_clob and get intcol# in table
--                        - of column on which index is defined
-- PARAMETERS:
--    obj_num             - base table object #
--    intcol_num          - intcol# from icol$
--    default_val_clob    - default_val from col$
--

  FUNCTION get_index_intcol_parse(obj_num IN NUMBER,
                                  intcol_num in NUMBER,
                                  default_val_clob in CLOB)
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_INDEX_INTCOL - Get intcol# in table of column on which index is
--                    defined (need special handling for xmltype cols)
-- PARAMETERS:
--      obj_num         - base table object #
--      intcol_num      - intcol# from icol$
--

  FUNCTION get_index_intcol(obj_num IN NUMBER,
                            intcol_num in NUMBER)
        RETURN NUMBER;

---------------------------------------------------------------------
-- HAS_TSTZ_COLS - Determine whether a table has data of type DTYSTZ
--                 (type# = 181): "TIMESTAMP WITH TIME ZONE"
--                 If so, data pump may have to convert the data.
--                 The data may be in a top-level column, an object column,
--                 or a varray.
-- PARAMETERS:
--      obj_num         - table object #
-- RETURNS:
--      'Y' - it does
--      'N' - it does not

  FUNCTION has_tstz_cols(obj_num IN NUMBER)
        RETURN CHAR;

---------------------------------------------------------------------
-- HAS_TSTZ_ELEMENTS - Determine whether a varray type has TSTZ elements.
--                 This is a jacket function around utl_xml.haststz
-- PARAMETERS:
--      type_schema
--      type_name
-- RETURNS:
--      'Y' - it does
--      'N' - it does not

  FUNCTION has_tstz_elements(type_schema IN VARCHAR2,
                             type_name   IN VARCHAR2)
        RETURN CHAR;

---------------------------------------------------------------------
-- DELETE_XMLSCHEMA: call dbms_xmlschema.deleteSchema
--  to delete the named schema

  PROCEDURE DELETE_XMLSCHEMA(name varchar2);

---------------------------------------------------------------------
-- LOAD_XSD: call dbms_xmlschema.registerSchema 
--  to register the named schema

  PROCEDURE LOAD_XSD(filename varchar2);

---------------------------------------------------------------------
-- GET_XMLCOLSET - return nested table of intcol numbers for OR storage 
--              columns for xmltypes in table
--
-- PARAMETERS:
--    obj_num   - object number of table

  FUNCTION get_xmlcolset (obj_num IN NUMBER)
        RETURN  ku$_XmlColSet_t;

---------------------------------------------------------------------
--  GET_XMLHIERARCHY   - return 'Y' if table is hierachy enabled, else null
--
-- PARAMETERS:
--    schema    - owner of table
--    name      - name of table

  FUNCTION get_xmlhierarchy ( schema IN VARCHAR2, name IN VARCHAR2)
        RETURN  CHAR;

---------------------------------------------------------------------
-- isXml - return number indicating if intcol is OR storage 
--              column of an xmltype column in table
-- PARAMETERS:
--    obj_num   - object number of table
--    intcol    - column to be tested
-- RETURNS
--    0 = not part of xmltype column
--    1 = is part of xmltype column

  FUNCTION isXml (obj_num IN NUMBER, intcol IN NUMBER) return NUMBER;

---------------------------------------------------------------------
-- isXml - another variant, starting with nested table
--              column of an xmltype column in table
-- PARAMETERS:
--    nt_num    - nt number of nested table
-- RETURNS
--    0 = not part of xmltype column
--    1 = is part of xmltype column

  FUNCTION isXml (nt_num IN NUMBER) return NUMBER;

---------------------------------------------------------------------
-- IS_SCHEMANAME_EXISTS - Return 1 if schema name exists in trigger definition
--                               0 other wise
-- PARAMETERS:
--    tdefinition   - Trigger definition

  FUNCTION is_schemaname_exists(tdefinition varchar2)
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_MARKER - Return the current marker number
-- PARAMETERS:
--    none 

  FUNCTION get_marker
        RETURN NUMBER;

---------------------------------------------------------------------
-- SET_MARKER - Sets the current marker number
-- PARAMETERS:
--    new_marker    - New marker value 

  PROCEDURE set_marker(
                   new_marker NUMBER) 
                   ACCESSIBLE BY (PACKAGE sys.dbms_metadata_int);

-- GET_STRM_MINVER: Retrieve stream minor version based on job version
-- RETURNS: version number

 FUNCTION get_strm_minver
        RETURN CHAR;

---------------------------------------------------------------------
-- SET_BLOCK_ESTIMATE - set state for estimate phase
-- PARAMETERS:
--      value - TRUE  = estimate=blocks
--              FALSE = estimate=statistics

  PROCEDURE set_block_estimate(value IN BOOLEAN);


---------------------------------------------------------------------
-- GET_ANYDATA_COLSET - return nested table of type names for unpacked
--              ADT columns contained in an opaque column 
--
-- PARAMETERS:
--    objnum    - object number of table
--    colnum    - number of current column (c.col#)
--    colcnt    - number of columns in the input column list
--    col_list  - list of intcol#s of columns storing unpacked ADT cols - each
--                intcol# is stored as a ub2
--
-- OUTPUT:
--    This function returns an AnyData Type list to the caller.  Each element
--    in the list contains one or more type names.  This list will be used to
--    generate the Alter table statements for unpacked types.  One Alter table
--    statement will be generated for each item in the list.  The reason for
--    multiple Alters instead of just one statement is to duplicate exactly
--    the way that the types were unpacked when the table was created.  This
--    is especially important for transportable tablespaces so that the 
--    dictionary tables will accurately reflect the table layout in the table-
--    space.
--              
FUNCTION get_anydata_colset(objnum IN NUMBER, colnum IN NUMBER, 
                            colcnt IN NUMBER, col_list RAW)
       RETURN ku$_Unpacked_AnyData_t;


---------------------------------------------------------------------
-- GET_ATTRNAME2 - Another attribute name for underlying columns of an
--                 unpacked opaque type column.
--
-- DESCRIPTION: This purpose for generating another attribute name for such
--              columns is due to the fact that these columns (even their
--              attribute names) are system generated.  This new alternate
--              name removes the system generated part of the name and
--              replaces it with the type name and its owner.  This will
--              allow the differ (if needed) to match the columns based on
--              this name.
--
-- PARAMETERS:
--    obj_num   - object number of table
--    intcolnum - currrent column's intcol#
--    colnum    - current column's col#

FUNCTION get_attrname2(objnum IN NUMBER, intcolnum IN NUMBER, colnum IN NUMBER)
       RETURN VARCHAR2;

---------------------------------------------------------------------
-- LOAD_TEMP_TABLE - copy sys.x$ktfbue into a temporary table
--  for subsequent use in computing bytes allocated.
--  Using the temporary table is much faster.

  PROCEDURE load_temp_table;

---------------------------------------------------------------------
-- BLOCK_ESTIMATE - calculate bytes_allocated using BLOCKS method
-- PARAMETERS:
--      o_num           - object #
--      view_num        - which view to use
--                         1 = ku$_htable_bytes_alloc_view
--                         2 = ku$_htpart_bytes_alloc_view
--                         3 = ku$_htspart_bytes_alloc_view
--                         4 = ku$_iotable_bytes_alloc_view
--                         5 = ku$_iotpart_bytes_alloc_view
--                         6 = ku$_ntable_bytes_alloc_view
--                         7 = ku$_eqntable_bytes_alloc_view

  FUNCTION block_estimate(o_num IN NUMBER,
                          view_num IN NUMBER)
        RETURN NUMBER;

-- BYTES_ALLOC - calculate bytes allocated from x$ktfbue
--  using the temporary table if it has been initialized.
-- PARAMETERS:
--    ts_num            - tablespace # for this segment
--    file_num          - segment header file number 
--    block_num         - segment header block number 
--    block_size        - blocksize
-- RETURNS:
--    bytes allocated

  FUNCTION bytes_alloc(ts_num       IN NUMBER,
                       file_num     IN NUMBER,
                       block_num    IN NUMBER,
                       block_size   IN NUMBER)
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_TABPART_TS - get a ts# for a table (sub)partition
--   (used by dbms_metadata.in_tsnum_2
-- PARAMETERS:
--    obj_num    - obj# for table

  FUNCTION get_tabpart_ts ( 
                OBJ_NUM  IN NUMBER )
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_INDPART_TS - get a ts# for an index (sub)partition
--   (used by ku$_index_view
-- PARAMETERS:
--    obj_num    - obj# for table

  FUNCTION get_indpart_ts ( 
                OBJ_NUM  IN NUMBER )
        RETURN NUMBER;

---------------------------------------------------------------------
-- GET_PART_LIST         - get ordered list of partition numbers,
--                         or partition base object numbers
--
-- PARAMETERS: 
--      PARTYPE - 1 - tabpart
--                2 - tabcompart
--                3 - tabsubpart
--                4 - indpart
--                5 - indcompart
--                6 - indsubpart
--                7 - lobfrag
--                8 - lobcomppart
--                Values above +100 are used to fetch the set of base
--                 object numbers for the corresponds type.
--      BOBJ_NUM - base object number of which this is for partitions
--      CNT      - (OUT) number of partitions in base objectrows returned
--
-- return t_num_coll - ordered list o partition number



  FUNCTION get_part_list ( 
                PARTYPE  IN NUMBER,
                BOBJ_NUM IN NUMBER,
                CNT     OUT NUMBER  )
        RETURN dbms_metadata_int.t_num_coll;

---------------------------------------------------------------------
-- GLO
--
-- Description: See bug 12866600.
--
-- Input:
--      raw
--
-- Return:
--      raw
--
  FUNCTION glo (inval IN raw)
        RETURN raw;

--+
-- Fetch_Stat
--
-- Description: This procedure will fetch the XML from the metadata api for
--              the SYS.IMPDP_STATS table
--
-- Caller:      This procedure is called from PREPARE_DATA_IMP if the XML
--              needs to be refetched.
--
--  Implicit Inputs:
--      None
--
-- Inputs:
--      None
--
--  Implicit Outputs:
--      None
--
-- Outputs:
--      xml_clob for sys.impdp_stats
--+
PROCEDURE FETCH_STAT
  (stat_clob    IN OUT   CLOB);

---------------------------------------------------------------------
-- FUNC_INDEX_DEFAULT  - get default$ from col$ for a func index 
--                       converting any null bytes to 'CHR(0)'
-- PARAMETERS:
--      length          - value of col$.deflength
--      row             - rowid of the row in COL$
-- RETURNS:     LONG value converted to VARCHAR2
--              with any null byte converted to the string 'CHR(0)'
--              if length <= 32000, otherwise NULL
-- NOTE: This routine is adapted from 'func_index_default' in
--       prvtpexp.sql (used by original exp).  It is required
--       for bug 13386193.

  FUNCTION func_index_default(
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN VARCHAR2;

-- FUNC_INDEX_DEFAULTC  - get default$ from col$ for a func index 
--                       converting any null bytes to 'CHR(0)'
--   (This is the same as the above routine with a different return datatype)
-- PARAMETERS:
--      length          - value of col$.deflength
--      row             - rowid of the row in COL$
-- RETURNS:     LONG value converted to temporary CLOB
--              with any null byte converted to the string 'CHR(0)'
--              if length <= 32000, otherwise NULL
-- NOTE: This routine is adapted from 'func_index_default' in
--       prvtpexp.sql (used by original exp).  It is required
--       for bug 13386193.

  FUNCTION func_index_defaultc(
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN CLOB;

---------------------------------------------------------------------
-- CHECK_CONSTRAINT - Check whether constraint exists or not
--
-- PARAMETER :
--     obj_num    - obj# of index
--
-- Returns 1 if constraint exists
--
  FUNCTION check_constraint (
                OBJ_NUM IN NUMBER )
        RETURN NUMBER;

------------------------------------------------------------------------------

-- FUNC_VIEW_DEFAULT  - get TEXT from view$ for a func view 
--                      removing null bytes from view$.TEXT
-- PARAMETERS:
--      length        - value of view$.TEXT
--      row           - rowid of the row in VIEW$
-- RETURNS:     LONG value converted to VARCHAR2

   FUNCTION func_view_default(
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN VARCHAR2;

-- FUNC_VIEW_DEFAULTC  - get TEXT from view$ for a func view 
--                        removing null bytes to from view$.TEXT
-- (This is the same as the above routine with a different return datatype)
-- PARAMETERS:
--      length          - value of VIEW$.TEXT
--      row             - rowid of the row in VIEW$
-- RETURNS:     LONG value converted to temporary CLOB

  FUNCTION func_view_defaultc(
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN CLOB;

-- GET_QA_LRG_TYPE: return the value of qa_lrg_type, which can be used
--  to determine that the database is being used for testing

  FUNCTION get_qa_lrg_type
        RETURN NUMBER;

-- GET_LOST_WRITE_PROTECTION: Returns TRUE when LOST WRITE PROTECTION is
--                            enabled, else FALSE
  FUNCTION get_lost_write_protection
        RETURN BOOLEAN;

END DBMS_METADATA_UTIL;
/
GRANT EXECUTE ON sys.dbms_metadata_util TO EXECUTE_CATALOG_ROLE;


@?/rdbms/admin/sqlsessend.sql
