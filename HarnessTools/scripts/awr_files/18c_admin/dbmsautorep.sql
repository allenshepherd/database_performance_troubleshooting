Rem
Rem $Header: rdbms/admin/dbmsautorep.sql /main/9 2017/09/12 16:25:28 aarvanit Exp $
Rem
Rem dbmsautorep.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsautorep.sql - DBMS Automatic Report capture
Rem
Rem    DESCRIPTION
Rem      This file contains the package spec for the automatic report capture
Rem      feature
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsautorep.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsautorep.sql
Rem SQL_PHASE: DBMSAUTOREP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aarvanit    09/07/17 - RTI #16459874: finish_report_capture: do not
Rem                           run a last capture cycle
Rem    shjoshi     01/13/16 - rti 16459874: fix error number ERR_FIN_CAPTURE
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    kyagoub     08/21/12 - implement review comments
Rem    kyagoub     08/12/12 - report_repository_list_xml: add
Rem                           top_n_detail_count
Rem    shjoshi     04/11/12 - Add max_rows to list function
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     02/17/12 - Add start_report_capture and
Rem                           finish_report_capture
Rem    shjoshi     01/25/12 - Add report_repository_detail_xml
Rem    shjoshi     12/27/11 - Add report_repository_list_xml
Rem    shjoshi     08/28/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_auto_report AUTHID CURRENT_USER IS

  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------
  
  -- Custom Errors
  ERR_FIN_CAPTURE        CONSTANT NUMBER := -13991;


  ------------------------- report_repository_list_xml ------------------------
  -- NAME: 
  --     report_repository_list_xml
  --
  -- DESCRIPTION:
  --     This function generates an XML list report containing a list of all 
  --     reports from the repository that match the input criteria.
  -- 
  -- PARAMETERS:
  --     active_since        (IN)   - start of activity period
  --     active_upto         (IN)   - end of activity period
  --     snapshot_id         (IN)   - only reports captured during this snap 
  --                                - id to be part of the list
  --     dbid                (IN)   - only reports captured for this db to be
  --                                  part of the list
  --     inst_id             (IN)   - only reports captured for this instance
  --                                  to be part of the list
  --     con_dbid            (IN)   - only reports captured for this container
  --                                  dbid to be part of the list
  --     session_id          (IN)   - only reports captured for this session
  --                                  id to be part of the list
  --     session_serial      (IN)   - only reports captured for this session
  --                                  serial # to be part of the list
  --     component_name      (IN)   - name of component whose reports (only) 
  --                                  will be in the list
  --     key1                (IN)   - reports matching value of key1 to be in
  --                                  the list
  --     key2                (IN)   - reports matching value of key2 to be in
  --                                  the list
  --     key3                (IN)   - reports matching value of key3 to be in
  --                                  the list
  --     report_level        (IN)   - detail level of report
  --    
  --     base_path           (IN)   - this is the URL path for flex HTML 
  --                                  ressources since flex HTML format 
  --                                  requires to access external files
  --                                  (java scripts and the flash swf file 
  --                                   itself).
  --
  --     top_n_count         (IN)   - maximum no of reports that will be 
  --                                  fetched in the list xml. 
  --
  --     top_n_rankby        (IN)   - attribute (stats based) on which to 
  --                                  retrieve top N rows to limit size of XML.
  --                                  1 => elapsed_time, 2 => duration
  --                                  3 => cpu_time, 4 => io_requests, 
  --                                  5 => io_bytes
  --
  --     top_n_detail_count  (IN)   - decide if component (e.g., sql monitor) 
  --                                  detail report in the list should be part 
  --                                  of the list report. 
  --                                  A value (upto 10) indicates the number 
  --                                  of the component detail reports will be
  --                                  included in the list.
  --                                  If null, no detail report is included in
  --                                  the list. 
  --
  -- RETURN:
  --     xml list report of all reports from the repository selected based on
  --     the above criteria
  --
  -----------------------------------------------------------------------------
  FUNCTION report_repository_list_xml(
    active_since              in date     default NULL,
    active_upto               in date     default NULL,
    snapshot_id               in number   default NULL,
    dbid                      in number   default NULL,
    inst_id                   in number   default NULL,
    con_dbid                  in number   default NULL,
    session_id                in number   default NULL,
    session_serial            in number   default NULL,
    component_name            in varchar2 default NULL,
    key1                      in varchar2 default NULL,
    key2                      in varchar2 default NULL,
    key3                      in varchar2 default NULL,
    report_level              in varchar2 default 'TYPICAL',
    base_path                 in varchar2 default NULL,
    top_n_count               in number   default NULL,
    top_n_rankby              in varchar2 default 'db_time',
    top_n_detail_count        in number   default  NULL)
  RETURN xmltype;

  ------------------------ report_repository_detail_xml -----------------------
  -- NAME: 
  --     report_repository_detail_xml
  --
  -- DESCRIPTION:
  --     This function retrieves the stored XML report whose report_id is passed
  --     as an input. This report could belong to any of the components 
  --     registered with the report capture framework.
  -- 
  -- PARAMETERS:
  --     rid              (IN)   - id of the report to be returned
  --     base_path        (IN)   - this is the URL path for flex HTML 
  --                               resources since flex HTML format 
  --                               requires to access external files
  --                               (java scripts and the flash swf file itself).
  --                                
  -- RETURNS:
  --     xml report as xmltype
  -----------------------------------------------------------------------------
  FUNCTION report_repository_detail_xml(
    rid              in number    default NULL,
    base_path        in varchar2  default NULL)
  RETURN XMLTYPE;

  -------------------------- report_repository_detail -------------------------
  -- NAME: 
  --     report_repository_detail
  --
  -- DESCRIPTION:
  --     This function retrieves the stored report whose report_id is passed
  --     as an input. This report could belong to any of the components 
  --     registered with the report capture framework.
  -- 
  -- PARAMETERS:
  --     rid              (IN)   - id of the report to be returned
  --     type             (IN)   - desired format of the report.
  --                               Values can be 'XML', 'TEXT', 'HTML', 'EM' or
  --                               'ACTIVE'. The last two options generate a 
  --                               report in the same format called active HTML
  --     base_path        (IN)   - this is the URL path for flex HTML 
  --                               resources since flex HTML format 
  --                               requires to access external files
  --                               (java scripts and the flash swf file itself).
  --                                
  -- RETURNS:
  --     report as clob
  -----------------------------------------------------------------------------
  FUNCTION report_repository_detail(
    rid              in number    default NULL,
    type             in varchar2  default 'XML', 
    base_path        in varchar2  default NULL)
  RETURN CLOB;

  ----------------------------- start_report_capture --------------------------
  -- NAME: 
  --     start_report_capture
  --
  -- DESCRIPTION:
  --     This function changes the mode of execution of the auto report 
  --     capture service to a 'full capture'. This means that in every capture
  --     cycle, there is no dbtime budget constraint and the capture will run
  --     for as long as there are more reports to capture, (subject to the 
  --     time-out of the MMON slave). 
  --     This 'full capture' mode of execution can be seen by querying
  --     dba_hist_reports_control. The full capture mode of execution continues
  --     even if the db is bounced and will continue till it is explicitly 
  --     ended by running finish_report_capture.
  -- 
  -- PARAMETERS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE start_report_capture;

  ---------------------------- finish_report_capture --------------------------
  -- NAME: 
  --     finish_report_capture
  --
  -- DESCRIPTION:
  --     This function changes the mode of execution of the auto report 
  --     capture service back to a 'regular capture'. This means that every 
  --     capture cycle will run subject to a dbtime budget constraint.
  --
  -- PARAMETERS:
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE finish_report_capture;


  -----------------------------------------------------------------------------
  --                     INTERNAL UNDOCUMENTED FUNCTIONS                     --
  --                                                                         --
  -----------------------------------------------------------------------------

  ------------------------- finish_report_capture_helper ---------------------
  FUNCTION finish_report_capture_helper
  RETURN NUMBER;

  -------------------------- start_report_capture_helper ---------------------
  FUNCTION start_report_capture_helper
  RETURN NUMBER;

end;
/
show errors
/


CREATE OR REPLACE PUBLIC SYNONYM DBMS_AUTO_REPORT FOR DBMS_AUTO_REPORT
/

GRANT EXECUTE ON DBMS_AUTO_REPORT TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
