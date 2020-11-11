Rem
Rem $Header: rdbms/admin/awrgrpti.sql /main/8 2017/05/28 22:46:00 stanaya Exp $
Rem
Rem awrgrpti.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrgrpti.sql - Workload Repository RAC (Global) Report
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to report on RAC-wide differences between
Rem      values recorded in two snapshots.
Rem
Rem      This script requests the user for the dbid before 
Rem      producing the standard Workload Repository report.
Rem
Rem    NOTES
Rem      Run as SYSDBA.  Generally this script should be invoked by awrgrpt,
Rem      unless you want to pick a database other than the default.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      without executing the script through awrgrpt, then
Rem      do something similar to the following:
Rem
Rem      define  num_days     = 3;
Rem      define  db_name      = 'Database';
Rem      define  dbid         = 4;
Rem      define  begin_snap   = 10;
Rem      define  end_snap     = 11;
Rem      define  report_type  = 'text';
Rem      define  report_name  = /tmp/awrrac1.txt
Rem      define  instance_numbers_or_ALL = '1,2,3'
Rem      @@?/rdbms/admin/awrgrpti
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrgrpti.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrgrpti.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    jraitto     03/29/17 - Fix RTI 20204635
Rem    myuin       09/13/13 - add active-html as an option in report format
Rem    cgervasi    06/27/13 - add option to disable exadata
Rem    cgervasi    04/04/13 - add active-html support
Rem    shiyadav    04/25/11 - change linesize to 8000 for html report
Rem    ilistvin    11/26/07 - AWR RAC Report script
Rem    ilistvin    11/26/07 - Created
Rem

set echo off;

-- ***************************************************
--   Customer-customizable report settings
--   Change these variables to run a report on different statistics
-- ***************************************************
Rem
Rem top n events in the report summary (NULL uses package default, 10)
define top_n_events       = NULL;
Rem
Rem top n segments  (NULL uses package default, 5)
define top_n_segments     = NULL;
Rem
Rem top n services (NULL uses package default, 10)
define top_n_services     = NULL;
Rem
Rem top n SQL statements (NULL uses package default, 10)
define top_n_sql          = NULL;
-- The default number of days of snapshots to list when choosing begin
-- and end snapshots
--
-- List all snapshots
-- define num_days = '';
--
-- List no (i.e. 0) snapshots
-- define num_days = 0;
--
-- List past 3 day's snapshots
-- define num_days = 3;
--
-- Reports can be printed in text or html, and you must set the report_type
-- in addition to the report_name
--
-- Issue Report in Text Format
-- define report_type='text';
--
-- Issue Report in HTML Format
-- define report_type='html';

-- Optionally, set the snapshots for the report.  If you do not set them,
-- you will be prompted for the values.
-- define begin_snap = 545;
-- define end_snap   = 546;

-- Optionally, set the name for the report itself
--define report_name = 'awrrpt_1_545_546.html'

-- ***************************************************
--   End customer-customizable settings
-- ***************************************************

set veri off;
set feedback off;

variable rpt_options number;

-- option settings
define NO_OPTIONS   = 0;
define DISABLE_EXADATA = 2;
define ENABLE_ADDM  = 8; -- doesn't seem to work

-- set the report_options. To see the ADDM-specific sections,
-- set the rpt_options to the ENABLE_ADDM constant.
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
    dbms_output.put_line(' Specify the Report Type');
    dbms_output.put_line(' ~~~~~~~~~~~~~~~~~~~~~~~');
    dbms_output.put_line(' AWR reports can be generated in the following formats.  Please enter the');
    dbms_output.put_line(' name of the format at the prompt. Default value is ''html''.');
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
@@awrginp.sql 
-- Get the name of the report.
@@awrinpnm.sql 'awrrpt_' &&ext

set termout off;
-- set report function name and line size
column fn_name new_value fn_name noprint;
select 'awr_global_report_text' fn_name from dual
 where lower('&report_type') = 'text';
select 'awr_global_report_html' fn_name from dual
 where lower('&report_type') <> 'text';

column lnsz new_value lnsz noprint;
select '320' lnsz from dual where lower('&report_type') = 'text';
select '8000' lnsz from dual where lower('&report_type') <> 'text';

variable fn varchar2(100);
begin
  :fn := '&fn_name';
end;
/
variable tn_events   NUMBER;
variable tn_segments NUMBER;
variable tn_services NUMBER;
variable tn_sql      NUMBER;
begin
  :tn_events    := &top_n_events;
  :tn_segments  := &top_n_segments;
  :tn_services  := &top_n_services;
  :tn_sql       := &top_n_sql;
  dbms_workload_repository.awr_set_report_thresholds(:tn_events,
                                                     NULL,
                                                     :tn_segments,
                                                     :tn_services,
                                                     :tn_sql,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL);
end;
/

set linesize &lnsz;
set termout on;
spool &report_name;

-- call the table function to generate the report
 select output from table(dbms_workload_repository.&fn_name( :dbid,
                                                             :instl,
                                                             :bid, :eid,
                                                             :rpt_options ));

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
undefine ext
undefine fn_name
undefine lnsz

undefine NO_OPTIONS
undefine ENABLE_ADDM

undefine top_n_events
undefine num_days
undefine top_n_sql
undefine top_pct_sql
undefine sh_mem_threshold
undefine top_n_segstat

whenever sqlerror continue;
--
--  End of script file;
