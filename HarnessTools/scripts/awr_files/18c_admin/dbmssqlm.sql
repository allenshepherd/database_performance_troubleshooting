Rem
Rem $Header: rdbms/admin/dbmssqlm.sql /main/8 2017/09/26 16:43:21 aarvanit Exp $
Rem
Rem dbmssqlm.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssqlm.sql - DBMS SQL Monitoring
Rem
Rem    DESCRIPTION
Rem      This package provides the APIs to monitor multiple SQLs.
Rem      It contains the procedure and function decalration of 
Rem      two main sql monitoring modules:
Rem         1- Miltiple SQL monitoring
Rem         2- Report the monitoring result
Rem
Rem    NOTES
Rem      None
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmssqlm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmssqlm.sql
Rem SQL_PHASE: DBMSSQLM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aarvanit    09/11/17 - bug #15863637: forced_tracking: fix allowed
Rem                           values, update note in end_operation
Rem    bhavenka    07/10/14 - support for dbop begin/end on target session
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    bhavenka    05/07/12 - fixed dbop bug in forced_tracking
Rem    msabesan    03/30/12 - con_name added to sql_monitor reports
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    hayu        09/28/11 - support DBOP report
Rem    hayu        06/08/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

------------------------------------------------------------------------------
--                   DBMS_SQLMON  FUNCTION DESCRIPTIONS                     --
------------------------------------------------------------------------------
--  Start/End monitoring
-----------------------------
--   begin_operation: start monitoring a session
--   end_operation: end monitoring a session
--
-----------------------------
--  Reporting
-----------------------------
--  report_sql_monitor
--  report_sql_monitor_xml
--  report_sql_monitor_list
--  report_sql_monitor_list_xml
--
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                  Library where 3GL callouts will reside                   --
-------------------------------------------------------------------------------
CREATE OR REPLACE LIBRARY dbms_sqlmon_lib trusted as static
/
show errors;

-------------------------------------------------------------------------------
--                     dbms_sqltune package declaration                      --
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_sql_monitor AUTHID CURRENT_USER AS

  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------
 
  MONITOR_TYPE_SQL        CONSTANT NUMBER  :=  1;
  MONITOR_TYPE_DBOP       CONSTANT NUMBER  :=  2;
  MONITOR_TYPE_ALL        CONSTANT NUMBER  :=  3;

  --
  -- report type (possible values) constants  
  --
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := 'TEXT'       ; 
  TYPE_XML            CONSTANT   VARCHAR2(3) := 'XML'        ;
  TYPE_HTML           CONSTANT   VARCHAR2(4) := 'HTML'       ;

  --
  -- report level (possible values) constants  
  --
  LEVEL_TYPICAL       CONSTANT   VARCHAR2(7) := 'TYPICAL'    ; 
  LEVEL_BASIC         CONSTANT   VARCHAR2(5) := 'BASIC'      ;
  LEVEL_ALL           CONSTANT   VARCHAR2(3) := 'ALL'        ;
    
  --
  -- report section (possible values) constants  
  --
  SECTION_FINDINGS    CONSTANT   VARCHAR2(8) := 'FINDINGS'   ; 
  SECTION_PLANS       CONSTANT   VARCHAR2(5) := 'PLANS'      ;
  SECTION_INFORMATION CONSTANT   VARCHAR2(11):= 'INFORMATION';
  SECTION_ERRORS      CONSTANT   VARCHAR2(6) := 'ERRORS'     ;
  SECTION_ALL         CONSTANT   VARCHAR2(3) := 'ALL'        ;
  SECTION_SUMMARY     CONSTANT   VARCHAR2(7) := 'SUMMARY'    ; 

  -- some common date format
  DATE_FMT       constant varchar2(21)       :=  'mm/dd/yyyy hh24:mi:ss';

  -- constant for forced tracking
  FORCE_TRACKING              CONSTANT VARCHAR2(30) := 'Y';
  NO_FORCE_TRACKING           CONSTANT VARCHAR2(30) := 'N';

  -----------------------------------------------------------------------------
  --                    procedure / function declarations                    --
  -----------------------------------------------------------------------------

  --------------------------------- begin_operation ---------------------------
  -- NAME: 
  --     begin_operation
  --
  -- DESCRIPTION
  --     This function is called to start a composite database operation in 
  --     the current session. If a DBOP has already been started (and not
  --     ended) in the current session, this function is a NO-OP.
  --
  -- PARAMETERS:
  --     dbop_name       (IN) - the operation name
  --     dbop_eid        (IN) - unique ID for the current execution of a DBOP 
  --                            in the session.
  --     forced_tracking (IN) - used to force the DB operation to be tracked,
  --                            otherwise the operation will be tracked only if
  --                            it consumes more than 5 seconds of CPU or I/O
  --                            time. Allowed values are "Y" and "N" (default).
  --     attribute_list  (IN) - list of the user input attributes
  --                            it is s comma separated name-value pair.
  --                            For example, 'table_name=emp, operation=load'
  --     session_id      (IN) - Session Identifier for which DBOP is to be 
  --                            started. If omitted (or NULL), then the
  --                            current session is assumed.
  --     session_serial  (IN) - Session serial number for which DBOP is to be
  --                            started. If omitted (or NULL), only the
  --                            session ID is used to determine a session.
  --
  -- RETURNS:
  --     DB operation unique execution ID. If a database operation has already
  --     been started (and not ended) in the current session, the execution ID
  --     of the existing operation is returned.
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION begin_operation(
    dbop_name       IN VARCHAR2, 
    dbop_eid        IN NUMBER   := NULL,
    forced_tracking IN VARCHAR2 := NO_FORCE_TRACKING,
    attribute_list  In VARCHAR2 := NULL,
    session_id      IN NUMBER   := NULL,
    session_serial  IN NUMBER   := NULL)
  RETURN NUMBER;
  
  --------------------------------- end_operation -----------------------------
  -- NAME: 
  --     end_operation
  --
  -- DESCRIPTION
  --     This procedure is called to end the operation in the current session.
  --     If there is no operation, this will be NO-OP.
  --
  -- PARAMETERS:
  --     dbop_name       (IN) - the operation name
  --     dbop_eid        (IN) - the execution ID
  --
  -- EXCEPTIONS:
  --     To be done
  --
  -- NOTE:
  --     If the operation was created with forced_tracking = 'Y' or if it 
  --     consumed more than 5 seconds, then end_operation will set the operation
  --     status to 'DONE'. Otherwise, the operation will be removed from
  --     v$sql_monitor to reclaim space as new DBOPs and SQL statements are
  --     monitored.
  -----------------------------------------------------------------------------
  PROCEDURE end_operation(
    dbop_name       IN VARCHAR2,
    dbop_eid        IN NUMBER);  


  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                  -------------------------------------------            --
  --                  SQL MONITORING REPORT FUNCTIONS/PROCEDURE              --
  --                  -------------------------------------------            --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  ------------------------------- report_sql_monitor --------------------------
  -- NAME: 
  --     report_sql_monitor
  --
  -- DESCRIPTION:
  --
  --     This function builds a report (text, simple html, active html, xml) 
  --     for the monitoring  information collected on behalf of the targeted
  --     statement execution. 
  --
  --     The target SQL statement for this report can be:
  --
  --       - the last SQL monitored by Oracle (default, no parameter)
  --       - the last SQL executed by a specified session and monitored
  --         by Oracle. The session is identified by its session id and
  --         optionally it serial# (-1 is current session). For example, use
  --         sess_id=>-1 for the current session or sess_id=>20,
  --         sess_serial=>103 for session id 20, serial number 103.
  --       - the last execution of a specific statement identified by
  --         its sql_id.
  --       - a specific execution of a SQL statement identified by the
  --         triplet (sql_id, sql_exec_start and sql_exec_id).
  --
  -- PARAMETERS:
  --                       
  --      - sql_id:      SQL_ID for which monitoring information should be
  --                     displayed. Use NULL (the default) to display
  --                     monitoring information for the last statement
  --                     monitored by Oracle.
  --
  --      - dbop_name    DQOP_NAME for which DB operation should be displayed
  --
  --      - session_id:  Target only the sub-set of statements executed and
  --                     monitored on behalf of the specified session.
  --                     Default is NULL. Use -1 or USERENV('SID') for current
  --                     seesion.
  --
  --      - session_serial:
  --                     In addition to the above <session_id> parameter, one
  --                     can also specify its session serial to ensure that
  --                     the desired session incarnation is targeted. Ignored
  --                     when <session_id> is NULL.
  --
  --      - (sql_exec_start, sql_exec_id):
  --                     Only applicable when <sql_id> is also specified and
  --                     can be used to display monitoring information for a
  --                     particular execution of <sql_id>. When NULL (the
  --                     default), the last execution of <sql_id> is shown.
  -- 
  --      - inst_id:     Only look at queries started on the specified 
  --                     instance. Use -1 to target the current instance.
  --                     The default, NULL will target all instances.
  --
  --      - start_time_filter:
  --                     If non NULL, the report will show only activity
  --                     (from V$ACTIVE_SESSION_HISTORY) started after this
  --                     date. If NULL, the reported activity will start when
  --                     the targeted SQL statement has started.
  --
  --      - end_time_filter:
  --                     If non NULL, the report will show only activity
  --                     (from V$ACTIVE_SESSION_HISTORY) collected before this
  --                     date. If NULL, the reported activity will end when
  --                     the targeted SQL statement has ended or SYSDATE if the
  --                     statement is still executing.
  --
  --      - instance_id_filter:
  --                     Only look at activity for the specified instance. Use
  --                     NULL (the default) to target all instances. Only
  --                     relevant if the query runs parallel.
  --
  --      - parallel_filter:
  --                     Parallel filter applies only to parallel execution and
  --                     allows to select only a subset of the processes
  --                     involved in the parallel execution. The string
  --                     parallel_filter can be:
  --                     - NULL (target all parallel execution servers + the
  --                       query coordinator)
  --                     - ['qc'][servers(<svr_grp>[,] <svr_set>[,] <srv_num>)]
  --                        where any NULL value is interpreted as ALL.
  --
  --                      The following examples show how one can set
  --                      <parallel_filter> to target only a subset of the
  --                      parallel sessions:
  --                        - 'qc' to target only the query coordinator
  --                        - servers(1)': to target all px servers in group 1
  --                          servers(,2)': to target all px servers in set 1,
  --                                        any group
  --                        - servers(1,1)': group 1, set 1
  --                        - servers(1,2,4)': group 1, set 3, server number 4
  --                        - qc servers(1,2,4)': same as above by also
  --                          including QC
  -- 
  --      - plan_line_filter:
  --                     This filter selects activity and execution stats for
  --                     the specified line number in the plan of a SQL 
  -- 
  --      - event_detail:
  --                     When set to 'no', the activity is aggregated by
  --                     wait_class only. Use 'yes' (the default) to aggregate
  --                     by (wait_class, event_name)
  --
  --     The next 2 parameters are used to control the activity histogram. By
  --     default, the maximum number of buckets is set to 128 and we derive the
  --     bucket_interval based on this. Basically, <bucket_interval> (value is
  --     in seconds) is computed such that it is the smallest possible power of
  --     2 value (starting at 1s) without causing to exceed the maximum number
  --     of buckets. For example, if the query has executed for 600s, we will
  --     pick a bucket_interval of 8s (a power of two) since 600/8 = 74 which
  --     is less than 128 buckets maximum. Smaller than 8s would be 4s, but
  --     that would cause to have more buckets than the 128 maximum.
  --     If <bucket_interval> is specified, we will use that value instead of
  --     deriving it from bucket_max_count. 
  --     
  --      - bucket_max_count:
  --                     If specified, this should be the maximum number of
  --                     histogram buckets created in the report
  --
  --      - bucket_interval:
  --                     If specified, this represents the exact time interval
  --                     in seconds, of all histogram buckets. If specified,
  --                     bucket_max_count is ignored.
  --
  --      - base_path:  this is the URL path for flex HTML ressources since
  --                    flex HTML format requires to access external files
  --                    (java scripts and the flash swf file itself).
  --
  --      - last_refresh_time:
  --                     If not null (default is null), time when the
  --                     report was last retrieved (see sysdate attribute
  --                     of the report tag). Use this option when you want
  --                     to display the report of an running query and when
  --                     that report is refreshed on a regular basis. This
  --                     will optimize the size of the report since only
  --                     the new/changed information will be returned. In
  --                     particular, the following will be optimized:
  --                     - SQL text will not be returned when this option
  --                       is specified
  --                     - activity histogram will start at the bucket that
  --                       intersect that time. The entire content of the
  --                       bucket will be return, even if last_refresh_time
  --                       is after the start of that bucket
  --
  --      - report_level:
  --                     level of detail for the report, either 'none', 'basic',
  --                     'typical' or 'all'. Default assumes 'typical'. Their
  --                     meanings are explained below.
  --                     
  --                     In addition, individual report sections can also
  --                     be enabled/disabled by using a +/-<section_name>.
  --                     Several sections are defined: 'plan', 'xplan',
  --                     'parallel', 'sessions', 'instance', 'binds', 'activity',
  --                     'activity_histogram', 'plan_histogram', 'metrics',
  --                     'other'.
  --                     Their meanings are as follows:
  --                     xplan          :   Show explain plan, 
  --                                        ON by default
  --                     plan           :   Show plan monitoring stats, 
  --                                        ON by default
  --                     sessions       :   Show session details. Applies only
  --                                        to parallel queries
  --                                        ON by default
  --                     instance       :   Show instance details. Applies only
  --                                        to parallel and cross instance 
  --                                        queries
  --                                        ON by default      
  --                     parallel       :   An umbrella parameter for 
  --                                        specifying sessions+instance
  --                                        details
  --                     activity :         Show activity summary at global
  --                                        level, plan line level and session/
  --                                        instance level (if applicable). 
  --                                        ON by default
  --                     binds          :   Show bind information when available
  --                                        ON by default
  --                     metrics        :   Show metric data (CPU, IOs, ...)
  --                                        over time
  --                                        ON by default
  --                     activity_histogram :
  --                                        Show an histogram of the overall
  --                                        query activity
  --                                        ON by default
  --                     plan_histogram  :  Show activity histogram at plan
  --                                        line level 
  --                                        OFF by default
  --                     other           :  Other info
  --                                        ON by default
  --
  --                     In addition, SQL text can be specified at different
  --                     levels:
  --                     -sql_text      : No SQL text in report
  --                     +sql_text      : OK with partial SQL text, i.e. upto 
  --                                      the first 2000 chars as stored in 
  --                                      gv$sql_monitor 
  --                     -sql_fulltext  : No full SQL text, i.e +sql_text
  --                     +sql_fulltext  : Show full SQL text (default value)
  --
  --                     The meanings of the three top-level report levels are:
  --                     none    = the minimum possible
  --                     basic   = sql_text-plan-xplan-sessions-instance
  --                               -activity_histogram-plan_histogram
  --                               -metrics
  --                     typical = everything but plan_histogram
  --                     all     = everything
  --
  --                    Only one of these 4 levels can be specified and if it 
  --                    is, then it has to be at the start of the report_level 
  --                    string
  -- 
  --                     Examples:
  --                       Use 'basic+parallel' to show the basic
  --                       report with additional section reporting parallel
  --                       information. Use 'all-plan-instance' for full
  --                       report minus plan detail and instance information.
  --
  --      - type:
  --            Report TYPE. Can be either 'TEXT' (text report, the default),
  --            'HTML' (simple HTML report, 'ACTIVE' (database active reports),
  --            'XML' (raw data for the report). Some information (activity
  --            histogram, metrics, ...) are only shown when the ACTIVE report
  --            type is selected.
  --
  --      - sql_plan_hash_value:
  --                     Target only those with the specified plan_hash_value.
  --                      Default is NULL.
  --
  --      - con_name: container name
  --   
  -- RETURN:
  --     The SQL monitor report, an XML document
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR
  --       - GV$SQL_PLAN_MONITOR
  --       - GV$ACTIVE_SESSION_HISTORY
  --       - GV$SESSION_LONGOPS
  --       - GV$SQL if SQL fulltext is asked and its length is > 2K
  -----------------------------------------------------------------------------
  FUNCTION report_sql_monitor(
       sql_id                    in varchar2 default  NULL,
       dbop_name                 in varchar2 default  NULL,
       dbop_exec_id              in number   default  NULL,
       session_id                in number   default  NULL,
       session_serial            in number   default  NULL,
       sql_exec_start            in date     default  NULL,
       sql_exec_id               in number   default  NULL,
       inst_id                   in number   default  NULL,
       start_time_filter         in date     default  NULL,
       end_time_filter           in date     default  NULL,
       instance_id_filter        in number   default  NULL,
       parallel_filter           in varchar2 default  NULL,
       plan_line_filter          in number   default  NULL,
       event_detail              in varchar2 default  'yes',
       bucket_max_count          in number   default  128,
       bucket_interval           in number   default  NULL,
       base_path                 in varchar2 default  NULL,
       last_refresh_time         in date     default  NULL,
       report_level              in varchar2 default 'TYPICAL',
       type                      in varchar2 default 'TEXT',
       sql_plan_hash_value       in number   default  NULL,
       con_name                  in varchar2 default  NULL)
  RETURN clob;


  ------------------------------- report_sql_monitor_xml ----------------------
  -- NAME: 
  --     report_sql_monitor_xml
  --
  -- DESCRIPTION:
  --
  --     Same as above function (report_sql_monitor()) except that the result
  --     is only XML, hence the return type is xmltype. 
  --
  -----------------------------------------------------------------------------
  FUNCTION report_sql_monitor_xml(
       sql_id                    in varchar2 default  NULL,
       dbop_name                 in varchar2 default  NULL,
       dbop_exec_id              in number   default  NULL,
       session_id                in number   default  NULL,
       session_serial            in number   default  NULL,
       sql_exec_start            in date     default  NULL,
       sql_exec_id               in number   default  NULL,
       inst_id                   in number   default  NULL,
       start_time_filter         in date     default  NULL,
       end_time_filter           in date     default  NULL,
       instance_id_filter        in number   default  NULL,
       parallel_filter           in varchar2 default  NULL,
       plan_line_filter          in number   default  NULL,
       event_detail              in varchar2 default  'yes',
       bucket_max_count          in number   default  128,
       bucket_interval           in number   default  NULL,
       base_path                 in varchar2 default  NULL,
       last_refresh_time         in date     default  NULL,
       report_level              in varchar2 default 'TYPICAL',
       auto_refresh              in number   default  NULL,
       sql_plan_hash_value       in number   default  NULL,
       con_name                  in varchar2 default  NULL)
  return xmltype;


  ---------------------------- report_sql_monitor_list ------------------------
  -- NAME: 
  --     report_sql_monitor_list
  --
  -- DESCRIPTION:
  --
  --     This function builds a report for all or a sub-set of statements
  --     that have been monitored by Oracle. For each statement, it gives
  --     key information and associated global statistics.
  --
  --     Use report_sql_monitor() to get detail monitoring information for
  --     a single SQL statement
  --
  -- PARAMETERS:
  --                       
  --      - sql_id:      SQL_ID for which monitoring information should be
  --                     displayed. Use NULL (the default) to display
  --                     monitoring information for the last statement
  --                     monitored by Oracle.
  --
  --      - dbop_name    DQOP_NAME for which DB operation should be displayed
  --
  --      - monitor_type MONITOR_TYPE_SQL will only return SQLs
  --                     MONITOR_TYPE_DBOP will only return DB Operations
  --                     MONITOR_TYPE_ALL will return all types
  --
  --      - session_id:  Target only the sub-set of statements executed and
  --                     monitored on behalf of the specified session.
  --                     Default is NULL. Use -1 (or USERENV('SID')) for
  --                     current session.
  --
  --      - session_serial:
  --                     In addition to the above <session_id> parameter, one
  --                     can also specify its session serial to ensure that
  --                     the desired session incarnation is targeted. Ignored
  --                     when <session_id> is NULL.
  --
  --      - inst_id:     Only look at monitored statements originating from
  --                     the specified instance. Special value -1 can be used
  --                     to target the instance where the  report executed.
  --                     To target all instances, use NULL (the default).
  --
  --      - active_since_date:
  --                     If not null (default is null), only returns monitored
  --                     statements that have been active since specified
  --                     time. This includes all statements that are still
  --                     executing plus all statements that have completed
  --                     their execution after the specified date/time.
  --
  --      - active_since_sec:
  --                     Same as above but the date is specified relativelly
  --                     to the current sysdate minus specified number of
  --                     seconds. For example, use 3600 to limit the report
  --                     to all statements that have been active in the past
  --                     1 hour.
  --
  --      - last_refresh_time:
  --                     If not null (default is null), date/time when the
  --                     list report was last retrieved. This is to optimize
  --                     the case where an application shows the list and
  --                     refresh the report on a regular basis (say once every
  --                     5s). In this case, the report will only show detail
  --                     about the execution of monitored queries that have
  --                     been active since the specified <last_refresh_time>.
  --                     For other queries, the report will only return the
  --                     execution key (i.e. sql_id, sql_exec_start,
  --                     sql_exec_id). Also, for queries that have their
  --                     first refresh time after the specified date, only
  --                     the SQL execution key and statistics are returned.
  --
  --      - report_level:
  --                     level of detail for the report. The level can be
  --                     either basic (SQL text up to 200 character),
  --                     typical (include full SQL text assuming that cursor
  --                     has not aged out, in which case the SQL text is
  --                     included up to 2000 characters). report_level can
  --                     also be all which is the same as typical for now.
  --
  --      
  --      - con_name:    container name
  --
  -- RETURN:
  --     A report (xml, text, html) for the list of SQL statements that have
  --     been monitored. 
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR and GV$SQL
  -----------------------------------------------------------------------------
 FUNCTION report_sql_monitor_list(
    sql_id                    in varchar2 default  NULL,
    dbop_name                 in varchar2 default  NULL,
    monitor_type              in number   default  MONITOR_TYPE_ALL,
    session_id                in number   default  NULL,
    session_serial            in number   default  NULL,
    inst_id                   in number   default  NULL,
    active_since_date         in date     default  NULL,
    active_since_sec          in number   default  NULL,
    last_refresh_time         in date     default  NULL,
    report_level              in varchar2 default  'TYPICAL',
    auto_refresh              in number   default  NULL,
    base_path                 in varchar2 default  NULL,
    type                      in varchar2 default 'TEXT',
    con_name                  in varchar2 default  NULL)
  RETURN clob;


  ---------------------------- report_sql_monitor_list_xml -------------------
  -- NAME: 
  --     report_sql_monitor_list_xml
  --
  -- DESCRIPTION:
  --
  --     Same as above function (report_sql_monitor) except that the result
  --     is only XML, hence the return type is xmltype
  -- 
  --
  -- RETURN:
  --     An XML document for the list of SQL statements that have been
  --     monitored. 
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR and GV$SQL
  -----------------------------------------------------------------------------
 FUNCTION report_sql_monitor_list_xml(
    sql_id                    in varchar2 default  NULL,
    dbop_name                 in varchar2 default  NULL,
    monitor_type              in number    default  MONITOR_TYPE_ALL,
    session_id                in number   default  NULL,
    session_serial            in number   default  NULL,
    inst_id                   in number   default  NULL,
    active_since_date         in date     default  NULL,
    active_since_sec          in number   default  NULL,
    last_refresh_time         in date     default  NULL,
    report_level              in varchar2 default  'TYPICAL',
    auto_refresh              in number   default  NULL,
    base_path                 in varchar2 default  NULL,
    con_name                  in varchar2 default  NULL)
  RETURN xmltype;


END dbms_sql_monitor;
/
show errors;

------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_sql_monitor FOR dbms_sql_monitor
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the public role           --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_sql_monitor TO public
/
show errors;

@?/rdbms/admin/sqlsessend.sql
