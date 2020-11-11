Rem
Rem $Header: rdbms/admin/dbmsperf.sql /main/5 2016/10/07 12:56:50 yxie Exp $
Rem
Rem dbmsperf.sql
Rem
Rem Copyright (c) 2012, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsperf.sql - DBMS Performance Reports
Rem
Rem    DESCRIPTION
Rem      Package specification for generating active reports
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsperf.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsperf.sql
Rem SQL_PHASE: DBMSPERF
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshastry    07/08/16 - pdb perfhub report from root
Rem    cgervasi    02/20/14 - bug18231785 - add base_path
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    kyagoub     08/11/12 - add report_addm_watchdog_xml
Rem    cgervasi    08/07/12 - add compress
Rem    cgervasi    08/02/12 - add report_session_xml
Rem    cgervasi    07/27/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- ------------------------------ dbms_emx --------------------------------
-- NAME:
--  dbms_emx
--
-- DESCRIPTION
--  package spec for EMX; used for active reports
--
CREATE OR REPLACE PACKAGE dbms_perf AUTHID CURRENT_USER
AS


  -- -------------------- report_perfhub_xml ------------------------------
  -- NAME:
  --     report_perfhub_xml
  --
  -- DESCRIPTION
  --     retrieves perfhub XML for all tabs
  --     should be used for generating active report
  --
  -- PARAMETERS
  --
  --     is_realtime (IN) - if 1 then realtime
  --                        if NULL (default) or 0, then historical mode
  --
  --     outer_start_time (IN) - start time of outer period shown in the
  --                        time selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, 24 hours before outer_end_time
  --                        . is_realtime=1, this is ignored
  --
  --     outer_end_time (IN) - end time of outer period show in the time 
  --                        selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, this is ignored
  --
  --     selected_start_time(IN) - time period of selection
  --                        if NULL (default)
  --                        . is_realtime=0, 1 hour before selected_end_time
  --                        . is_realtime=1, 5 minutes before selected_end_time
  --
  --     selected_end_time(IN) - end time of selection
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, current_time
  --
  --                       only valid if duration is not set
  --
  --     inst_id    (IN) - instance_id to retrieve data for 
  --                       if -1 then current instance
  --                       if number is specified, then for that instance
  --                       if NULL (default) all instances
  --
  --     dbid       (IN) - dbid to query (if NULL, then current dbid)
  --                       if is_realtime=1, dbid has to be the local dbid
  --
  --     monitor_list_detail (IN) - top N in sql monitor list to retrieve
  --                        sql monitor details
  --                        if NULL (default) will retrieve top 10
  --                        if 0, will not retrieve monitor list details
  --
  --     workload_sql_detail (IN) - top N in Workload Top SQL list to retrieve
  --                        sql details for
  --                        if NULL (default) will retrieve top 10
  --                        if 0, will not retrieve monitor list details
  --     
  --     addm_task_detail (IN) - maximum N latest ADDM tasks to retrieve
  --                        if NULL (default), will retrieve available data
  --                        but no more than N
  --                        if 0, will not retrieve addm task details
  --
  --     compress_xml     (IN) - if 1 or NULL (default) will compress xml
  --                        if 0 will not compress xml
  --                       
  --     report_reference (IN) - should be NULL when used from SQL*Plus
  --  
  --     report_level (IN) - 'typical' will get all tabs in perfhub
  --
  --     base_path    (IN) - the URL path for HTML resources since flex HTML
  --                         requires access to external files
  --
  FUNCTION report_perfhub_xml (
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    inst_id              IN number   default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    workload_sql_detail  IN number   default null,
    addm_task_detail     IN number   default null,
    compress_xml             IN binary_integer default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    base_path            IN varchar2 default null)
  RETURN xmltype;

  -- ---------------------------- report_perfhub ----------------------------
  -- see arguments in report_perfhub_xml
  -- 
  --    type - report type 
  --         - 'active' (default)
  --         - 'xml' - returns xml
  --
  FUNCTION report_perfhub(
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    inst_id              IN number   default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    workload_sql_detail  IN number   default null,
    addm_task_detail     IN number   default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    type                 IN varchar2 default 'ACTIVE',
    base_path            IN varchar2 default null,
    con_name             IN varchar2 default null)
  RETURN clob;


  -- -------------------- report_sql_xml ------------------------------
  -- NAME:
  --     report_sql_xml
  --
  -- DESCRIPTION
  --     retrieves SQL Details XML for all tabs
  --     should be used for generating active report
  --
  -- PARAMETERS
  --     sql_id      (IN) - sql_id to retrieve performance for
  --                        if null, will get sql details for last executed
  --                        SQL statement
  --
  --     is_realtime (IN) - if 1 then realtime
  --                        if NULL (default) or 0, then historical mode
  --
  --     outer_start_time (IN) - start time of outer period shown in the
  --                        time selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, 24 hours before outer_end_time
  --                        . is_realtime=1, this is ignored
  --
  --     outer_end_time (IN) - end time of outer period show in the time 
  --                        selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, this is ignored
  --
  --     selected_start_time(IN) - time period of selection
  --                        if NULL (default)
  --                        . is_realtime=0, 1 hour before selected_end_time
  --                        . is_realtime=1, 5 minutes before selected_end_time
  --
  --     selected_end_time(IN) - end time of selection
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, current_time
  --
  --                       only valid if duration is not set
  --
  --     inst_id    (IN) - instance_id to retrieve data for 
  --                       if -1 then current instance
  --                       if number is specified, then for that instance
  --                       if NULL (default) all instances
  --
  --     dbid       (IN) - dbid to query (if NULL, then current dbid)
  --                       if is_realtime=1, dbid has to be the local dbid
  --
  --     monitor_list_detail (IN) - top N in sql monitor list to retrieve
  --                        sql monitor details
  --                        if NULL (default) will retrieve top 10
  --                        if 0, will not retrieve monitor list details
  --
  --     compress_xml     (IN) - if 1 or NULL (default) will compress xml
  --                        if 0 will not compress
  --                       
  --     report_reference (IN) - should be NULL when used from SQL*Plus
  --  
  --     report_level (IN) - 'typical' will get all tabs in perfhub
  --
  --     base_path    (IN) - the URL path for HTML resources since flex HTML
  --                         requires access to external files
  --
  FUNCTION report_sql_xml (
    sql_id               IN varchar2 default null,
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    inst_id              IN number   default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    compress_xml         IN binary_integer default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    base_path            IN varchar2 default null)
  RETURN xmltype;

  -- ---------------------------- report_sql ----------------------------
  -- see parameters in report_perfhub_xml
  -- 
  --    type - report type 
  --         - 'ACTIVE' (default)
  --         - 'xml' - returns xml
  --
  FUNCTION report_sql(
    sql_id               IN varchar2 default null,
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    inst_id              IN number   default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    type                 IN varchar2 default 'ACTIVE',
    base_path            IN varchar2 default null)
  RETURN clob;

  -- -------------------- report_session_xml ------------------------------
  -- NAME:
  --     report_ssession_xml
  --
  -- DESCRIPTION
  --     retrieves Ssession Details XML for all tabs
  --     should be used for generating active report
  --
  --     a session is identified by inst_id, sid, serial_num
  --     if any of those parameters are missing, we will default to
  --     the currently connected session
  --
  -- PARAMETERS
  --     inst_id    (IN) - instance_id to retrieve data for 
  --                       if NULL (default), instance of current session
  --
  --     sid         (IN) - sql_id to retrieve performance for
  --                        if null, will use current session
  --
  --     serial_num  (IN) - serial# of session
  --                        if null, will use serial# of the specified sid
  --                        only if the session is still connected
  --
  --     is_realtime (IN) - if 1 then realtime
  --                        if NULL (default) or 0, then historical mode
  --
  --     outer_start_time (IN) - start time of outer period shown in the
  --                        time selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, 24 hours before outer_end_time
  --                        . is_realtime=1, this is ignored
  --
  --     outer_end_time (IN) - end time of outer period show in the time 
  --                        selector
  --                        Only applicable if is_realtime=0
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, this is ignored
  --
  --     selected_start_time(IN) - time period of selection
  --                        if NULL (default)
  --                        . is_realtime=0, 1 hour before selected_end_time
  --                        . is_realtime=1, 5 minutes before selected_end_time
  --
  --     selected_end_time(IN) - end time of selection
  --                        if NULL (default)
  --                        . is_realtime=0, latest AWR snapshot
  --                        . is_realtime=1, current_time
  --
  --     dbid       (IN) - dbid to query (if NULL, then current dbid)
  --                       if is_realtime=1, dbid has to be the local dbid
  --
  --     monitor_list_detail (IN) - top N in sql monitor list to retrieve
  --                        sql monitor details
  --                        if NULL (default) will retrieve top 10
  --                        if 0, will not retrieve monitor list details
  --
  --     compress_xml     (IN) - if 1 or NULL (default) will compress xml
  --                        if 0 will not compress
  --                       
  --     report_reference (IN) - should be NULL when used from SQL*Plus
  --  
  --     report_level (IN) - 'typical' will get all tabs in perfhub
  --
  --     base_path    (IN) - the URL path for HTML resources since flex HTML
  --                         requires access to external files
  --
  --
  FUNCTION report_session_xml (
    inst_id              IN number   default null,
    sid                  IN number   default null,
    serial               IN number   default null,
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    compress_xml         IN binary_integer default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    base_path            IN varchar2 default null)
  RETURN xmltype;

  -- ---------------------------- report_sql ----------------------------
  -- see parameters in report_perfhub_xml
  -- 
  --    type - report type 
  --         - 'ACTIVE' (default)
  --         - 'xml' - returns xml
  --
  FUNCTION report_session(
    inst_id              IN number   default null,
    sid                  IN number   default null,
    serial               IN number   default null,
    is_realtime          IN number   default null,
    outer_start_time     IN date     default null,
    outer_end_time       IN date     default null,
    selected_start_time  IN date     default null,
    selected_end_time    IN date     default null,
    dbid                 IN number   default null,
    monitor_list_detail  IN number   default null,
    report_reference     IN varchar2 default null,
    report_level         IN varchar2 default null,
    type                 IN varchar2 default 'ACTIVE',
    base_path            IN varchar2 default null)
  RETURN clob;

  -- ------------------- report_addm_watchdog_xml --------------------------
  -- NAME:
  --     report_addm_watchdog_xml
  --
  -- DESCRIPTION
  --     retrieves addm_watchdog_xml from the reporting framework 
  --     repository
  --
  -- PARAMETERS
  --    report_id (IN) - a valid report id in the report framework repository 
  --
  FUNCTION report_addm_watchdog_xml(report_id in number)
  RETURN xmltype;

END dbms_perf;
/
show errors;



------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_perf FOR
dbms_perf
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the dba role              --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_perf TO dba
/

--
-- NOTE: grant execute on dbms_perf to em_express_basic is in catemxv.sql
--
show errors;

@?/rdbms/admin/sqlsessend.sql
