Rem
Rem $Header: rdbms/admin/awrrpti.sql /main/17 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrrpti.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrrpti.sql - Workload Repository Report Instance
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to report on differences between
Rem      values recorded in two snapshots.
Rem
Rem      This script requests the user for the dbid and instance number
Rem      of the instance to report on, before producing the standard
Rem      Workload Repository report.
Rem
Rem    NOTES
Rem      Run as SYSDBA.  Generally this script should be invoked by awrrpt,
Rem      unless you want to pick a database other than the default.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      without executing the script through awrrpt, then
Rem      do something similar to the following:
Rem
Rem      define  inst_num     = 1;
Rem      define  num_days     = 3;
Rem      define  inst_name    = 'Instance';
Rem      define  db_name      = 'Database';
Rem      define  dbid         = 4;
Rem      define  begin_snap   = 10;
Rem      define  end_snap     = 11;
Rem      define  report_type  = 'text';
Rem      define  report_name  = /tmp/swrf_report_10_11.txt
Rem      @@?/rdbms/admin/awrrpti
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrrpti.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrrpti.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    yingzhen    05/11/17 - Bug 25801836 fix the pdb report size limit
Rem    jraitto     03/29/17 - Fix RTI 20204635
Rem    arbalakr    09/26/13 - Add some ASH sections to AWR report
Rem    myuin       09/13/13 - add active-html as an option in report format
Rem    cgervasi    06/27/13 - add option to disable exadata
Rem    cgervasi    04/04/13 - add active-html support
Rem    shiyadav    04/25/11 - change linesize to 8000 for html report
Rem    mlfeng      04/11/05 - move the warning for timed_statistics into the 
Rem                           procedure
Rem    pbelknap    08/04/04 - make awr html types bigger 
Rem    mlfeng      05/17/04 - default to prompt users for num_days 
Rem    pbelknap    12/11/03 - spelling fix 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    pbelknap    10/24/03 - swrfrpt to awrrpt 
Rem    pbelknap    10/14/03 - moving params to rpti 
Rem    pbelknap    10/06/03 - changing final comment 
Rem    pbelknap    10/02/03 - changing swrfinput to awrinput 
Rem    pbelknap    10/02/03 - adding non-interactive mode cmnts 
Rem    pbelknap    10/02/03 - adding filename echo at end of report
Rem    veeve       10/01/03 - moved back some SWRF specific variables
Rem    pbelknap    10/01/03 - unifying parameter code into input module
Rem    pbelknap    09/25/03 - removing spaces from top of report
Rem    pbelknap    09/22/03 - changing call to swrf_report for html table upd
Rem    pbelknap    09/10/03 - updating since HTML moved to prvtswrf, new
Rem                           swrf_report proto
Rem    mlfeng      09/04/03 - parameter# -> parameter_hash
Rem    mlfeng      08/11/03 - add options
Rem    mlfeng      08/04/03 - add instance number to default report name
Rem    mlfeng      07/23/03 - bind var logic
Rem    mlfeng      06/28/03 - convert to PL/SQL interface
Rem    mlfeng      06/05/03 - sqltext fix
Rem    mlfeng      05/16/03 - convert hash to sql_id
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      03/04/03 - Changing column format to prevent overflow
Rem    mlfeng      02/13/03 - change event logic to include event class
Rem    mlfeng      01/27/03 - mlfeng_swrf_reporting
Rem    mlfeng      01/16/03 - Adding top SQL and top Segment reporting logic
Rem                           to use statistics deltas.
Rem    mlfeng      01/13/03 - Update reporting for SWRF
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/12/02 - Created
Rem

set echo off;

-- ***************************************************
--   Customer-customizable report settings
--   Change these variables to run a report on different statistics
-- ***************************************************
-- The default number of days of snapshots to list when displaying the
-- list of snapshots to choose the begin and end snapshot Ids from.
--
--   List all snapshots
-- define num_days = '';
--
--   List no (i.e. 0) snapshots
-- define num_days = 0;
--
-- List past 3 day's snapshots
-- define num_days = 3;
--
-- Reports can be printed in text or html, and you must set the report_type
-- in addition to the report_name
--
-- Issue Report in Text Format
--define report_type='text';
--
-- Issue Report in HTML Format
--define report_type='html';

-- Optionally, set the snapshots for the report.  If you do not set them,
-- you will be prompted for the values.
--define begin_snap = 545;
--define end_snap   = 546;

-- Optionally, set the name for the report itself
--define report_name = 'awrrpt_1_545_546.html'

-- ***************************************************
--   End customer-customizable settings
-- ***************************************************


-- *******************************************************
--  The report_options variable will be the options for
--  the AWR report.
--
--  Currently, only one option is available.
--
--  NO_OPTIONS -
--    No options. Setting this will not show the ADDM
--    specific portions of the report.
--    This is the default setting.
--
--  ENABLE_ADDM -
--    Show the ADDM specific portions of the report.
--    These sections include the Buffer Pool Advice,
--    Shared Pool Advice, PGA Target Advice, and
--    Wait Class sections.
--

set veri off;
set feedback off;

variable rpt_options number;

-- option settings
define NO_OPTIONS   = 0;
define DISABLE_EXADATA = 2;
define ENABLE_ASH = 4;

define ENABLE_ADDM  = 8; -- this doesn't seem to work

-- set the report_options. To see the ADDM sections,
-- set the rpt_options to the ENABLE_ADDM constant.
-- To see ASH sections for AWR reports for more than 8 hrs st the
-- rpt_options to ENABLE_ASH
-- to explicitly disable exadata sections set rpt_options to DISABLE_EXADATA
begin
  :rpt_options := &NO_OPTIONS;
end;
/

Rem 
Rem Define report_type_def and view_loc_def and set NULL as default value if 
Rem they are not defined already. This will be used to determined if we
Rem should prompt the user for the report type and view location
Rem 
column report_type_def new_value report_type_def noprint;
select '' report_type_def from dual where rownum = 0;


set serveroutput on format wrapped;

variable rpttype VARCHAR2(32);
--
-- Find out the format of the report.
BEGIN
  IF ('&report_type_def' IS NULL OR '&report_type_def' = '') THEN
    dbms_output.put_line('');
    dbms_output.put_line('Specify the Report Type');
    dbms_output.put_line('~~~~~~~~~~~~~~~~~~~~~~~');
    dbms_output.put_line('AWR reports can be generated in the following ' ||
                         'formats.  Please enter the');
    dbms_output.put_line('name of the format at the prompt. ' ||
                         'Default value is ''html''.');
    dbms_output.put_line('');
    dbms_output.put_line('   ''html''          HTML format (default)');
    dbms_output.put_line('   ''text''          Text format');
    dbms_output.put_line('   ''active-html''   Includes Performance Hub active report');
    dbms_output.put_line('  ');
  END IF;
END;
/

column report_type new_value report_type noprint;

set heading off;
select (case when '&report_type_def' IS NULL 
             then ( lower ( (case when lower('&&report_type') = 'text' 
                                  then 'text'
                                  when lower('&&report_type') = 'active-html'
                                  then 'active-html'
                                  else 'html' end) ) )
             else '&&report_type'
        end) report_type
from dual;

select (case when '&report_type_def' IS NULL
             then 'Type Specified: ' || '&report_type'
             else '' 
        end)
from dual;
set heading on;

set termout off;
-- Set the extension based on the report_type
column ext new_value ext;
select '.html' ext from dual where lower('&&report_type') <> 'text';
select '.txt' ext from dual where lower('&&report_type') = 'text';

-- set up the options
column rpt_options new_value rpt_options
select decode('&&report_type','active-html',1,0) rpt_options
  from dual;
begin
  :rpt_options := :rpt_options + &rpt_options;
end;
/
set termout on;

-- Get the common input!
-- awrinput will set up the bind variables we need to call the PL/SQL procedure
@@awrinput.sql 
-- Get the name of the report.
@@awrinpnm.sql 'awrrpt_' &&ext

set termout off;
-- set report line size
column lnsz new_value lnsz noprint;
select '80' lnsz from dual where lower('&report_type') = 'text';
select '8000' lnsz from dual where lower('&report_type') <> 'text';

set linesize &lnsz;
set termout on;
spool &report_name;
set long 10000000
set longchunksize 32767

-- call the table function to generate the report
select dbms_workload_repository.awr_report( :dbid,
                                            :inst_num,
                                            :bid, :eid,
                                            :rpt_options,
                                            '&report_type' ) from dual;

spool off;

prompt Report written to &report_name.

set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;
-- Undefine report name (created in awrinput.sql)
undefine report_name

undefine report_type
undefine report_type_def
undefine ext
undefine lnsz

undefine NO_OPTIONS
undefine ENABLE_ADDM

undefine top_n_events
undefine num_days
undefine top_n_sql
undefine top_pct_sql
undefine sh_mem_threshold
undefine top_n_segstat

-- Undefine all variables declare in getawrviewloc
undefine default_view_location
undefine is_pdb
undefine view_loc
undefine awr_location


whenever sqlerror continue;
--
--  End of script file;
