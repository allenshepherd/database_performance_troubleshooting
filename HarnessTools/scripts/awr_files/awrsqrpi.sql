Rem
Rem $Header: rdbms/admin/awrsqrpi.sql /main/7 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrsqrpi.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrsqrpi.sql - Workload Repository SQL Report Instance
Rem
Rem    DESCRIPTION
Rem       SQL*Plus command file to report on differences between values
Rem       recorded in two snapshots
Rem       
Rem       This script requests the user for the dbid, instance number
Rem       and the sql id, before producing a report for a particular
Rem       sql statement in this instance.
Rem
Rem    NOTES
Rem      Run as SYSDBA.  Generally this script should be invoked by awrsqrpt,
Rem      unless you want to pick a database other than the default.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      without executing the script through awrrpt, then
Rem      do something similar to the following:
Rem
Rem   define  inst_num     = 1;
Rem   define  num_days     = 3;
Rem   define  inst_name    = 'Instance';
Rem   define  db_name      = 'Database';
Rem   define  dbid         = 4;
Rem   define  sql_id       = 'abcdefabcdefa'; 
Rem   define  con_dbid     = 5;
Rem   define  begin_snap   = 10;
Rem   define  end_snap     = 11;
Rem   define  report_type  = 'text';
Rem   define  report_name  = /tmp/awr_sql_report_10_11.txt
Rem   @@?/rdbms/admin/awrsqrpi.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrsqrpi.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrsqrpi.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    jraitto     03/29/17 - Fix RTI 20204635
Rem    kmorfoni    12/06/16 - specify con_dbid in AWR SQL report
Rem    kmorfoni    11/15/16 - Fix for select on AWR sqlstat view
Rem    arbalakr    09/08/16 - Bug 24625721: Fix empty report type error.
Rem    shiyadav    04/25/11 - change linesize to 8000 for html report
Rem    adagarwa    01/05/05 - adagarwa_awr_sql_rpt
Rem    adagarwa    09/08/04 - Created
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
-- define report_type='text';
--
-- Issue Report in HTML Format
--define report_type='html';

-- Optionally, set the snapshots for the report.  If you do not set them,
-- you will be prompted for the values.
-- define begin_snap = 10;
-- define end_snap   = 11;

-- Optionally, set the name for the report itself
-- define report_name = 'awrrpt_1_10_11.html'

-- Set the sqlid to be analyzed
-- define sql_id = 'abcdefabcdefa'

-- ***************************************************
--   End customer-customizable settings
-- ***************************************************


set verify off;
set feedback off;


variable rpt_options number;

-- Add new options here
-- option settings


Rem 
Rem Define report_type_def and view_loc_def and set NULL as default value if 
Rem they are not defined already. This will be used to determined if we
Rem should prompt the user for the report type and view location
Rem 
column report_type_def new_value report_type_def noprint;
select '' report_type_def from dual where rownum = 0;

column report_type new_value report_type noprint;

set serveroutput on format wrapped;
variable rpttype VARCHAR2(32);

--
-- Find out if we are going to print report to html or to text
BEGIN
  IF ('&report_type_def' IS NULL OR '&report_type_def' = '') THEN
    dbms_output.put_line('');
    dbms_output.put_line('Specify the Report Type');
    dbms_output.put_line('~~~~~~~~~~~~~~~~~~~~~~~');
    dbms_output.put_line('Would you like an HTML report, or' ||
                         ' a plain text report?');
    dbms_output.put_line('Enter ''html'' for an HTML report, or' ||
                         ' ''text'' for plain text');
    dbms_output.put_line('Defaults to ''html''');
  END IF;
END;
/

set heading off;
set newpage none

select (case when '&report_type_def' IS NULL
             then ( (case when lower('&&report_type') = 'text'
                                 then 'text'
                                 else 'html' end) )
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
column ext new_value ext noprint;
select '.html' ext from dual where lower('&&report_type') <> 'text';
select '.txt' ext from dual where lower('&&report_type') = 'text';
set termout on;

-- Get the common input
@@awrinput.sql

-- Get the SQL ID from the user
prompt Specify the SQL Id
prompt ~~~~~~~~~~~~~~~~~~
prompt SQL ID specified:  &&sql_id


-- Assign value to bind variable
variable sqlid  VARCHAR2(13);
begin
  :sqlid    := '&sql_id';
end;
/

whenever sqlerror exit;

variable condbid       NUMBER;
variable condbid_found NUMBER;
column script_name new_value script_name noprint;

declare
  dynsql         VARCHAR2(1024);
  cur            sys_refcursor;
  l_src_first    INTEGER;
  l_con_dbid     AWR_ROOT_SQLSTAT.con_dbid%type;
  l_pdb_name     AWR_ROOT_PDB_INSTANCE.pdb_name%type;
  header_printed BOOLEAN := FALSE;
  condbid_cnt    INTEGER;
begin
  
  -- Check if the sqlid is valid. It must contain an entry in the 
  -- AWR SQLSTAT view for the specified sqlid

  dynsql := 
    'select count(distinct con_dbid)
     from ' || '&view_loc' || '_sqlstat
     where snap_id > :bid
       and snap_id <= :eid
       and instance_number = :inst_num
       and dbid  = :dbid
       and sql_id  = :sqlid';
  
  execute immediate dynsql
    into  condbid_cnt
    using :bid, :eid, :inst_num, :dbid, :sqlid;

  if condbid_cnt = 0 then
    raise_application_error(-20025,
      'SQL ID '||:sqlid||' does not exist for this database/instance');
  end if;

  :condbid_found := 0;

  -- (a) Column src_first is not displayed. It is used for sorting purposes.
  -- (b) The outer join on 'pi' makes sure that we return rows even for versions
  --     before 12C. In such versions the views AWR_ROOT_PDB_INSTANCE and
  --     AWR_PDB_PDB_INSTANCE did not exist.
  dynsql := 
    'select distinct
              decode(sq.con_dbid, wr.src_dbid, 0, 1) src_first,
              sq.con_dbid,
              nvl(pi.pdb_name, ''** UNKNOWN **'') pdb_name
     from ' || '&view_loc' || '_sqlstat sq,
          ' || '&view_loc' || '_pdb_instance pi,
          ' || '&view_loc' || '_snapshot sn,
          ' || '&view_loc' || '_wr_control wr
     where sq.snap_id > :bid
       and sq.snap_id <= :eid
       and sq.instance_number = :inst_num
       and sq.dbid  = :dbid
       and sq.sql_id  = :sqlid
       and pi.dbid(+) = sq.dbid
       and pi.instance_number(+) = sq.instance_number
       and pi.con_dbid(+) = sq.con_dbid
       and pi.startup_time(+) = sn.startup_time
       and sn.snap_id = :bid
       and sn.dbid = sq.dbid
       and sn.instance_number = sq.instance_number
       and wr.dbid = sq.dbid
     order by src_first, pdb_name, sq.con_dbid';

  open cur for dynsql using :bid, :eid, :inst_num, :dbid, :sqlid, :bid;

  loop
    fetch cur into l_src_first, l_con_dbid, l_pdb_name;
    exit when cur%notfound;

    if header_printed = FALSE then
      header_printed := TRUE;
      :condbid := l_con_dbid;
      :condbid_found := 1;

      dbms_output.put_line('');
      dbms_output.put_line('Listing all available Container DB Ids for ' ||
                           'SQL Id ' || :sqlid);
      dbms_output.put_line('  Container DB Id Container Name');
      dbms_output.put_line('----------------- --------------');
      dbms_output.put_line('* ' || lpad(l_con_dbid, 15) || ' ' || l_pdb_name);
    else
      dbms_output.put_line('  ' || lpad(l_con_dbid, 15) || ' ' || l_pdb_name);
      :condbid_found := 0;
    end if;
  end loop;

  close cur;
end;
/

set termout off;
select case :condbid_found
         when 1 then 'awrrptinoop'
         else 'awrrptidc'
       end script_name
from dual;
set termout on;

@@&script_name :condbid

set termout off;
column con_dbid new_value con_dbid noprint;
select '' con_dbid from dual where rownum = 0;
set termout on;

begin
  if '&con_dbid' is not null then
    :condbid := to_number('&con_dbid');
  else
    dbms_output.put_line('');
  end if;

  dbms_output.put_line('Using Container DB Id ' || :condbid);
  dbms_output.put_line('');
end;
/

whenever sqlerror continue;

-- Get the name of the report.
@@awrinpnm.sql 'awrsqlrpt_' &&ext

set termout off;
-- set report function name and line size
column fn_name new_value fn_name noprint;
select 'awr_sql_report_text' fn_name from dual where lower('&report_type') = 'text';
select 'awr_sql_report_html' fn_name from dual where lower('&report_type') <> 'text';


column lnsz new_value lnsz noprint;
-- Line size for Text Reports: 120
select '120' lnsz from dual where lower('&report_type') = 'text';
-- Line size for HTML Reports: 8000
select '8000' lnsz from dual where lower('&report_type') <> 'text';

set linesize &lnsz;
set termout on;

spool &report_name;
prompt

DECLARE
  is_warning NUMBER;
  dynsql VARCHAR2(1024);
BEGIN
  is_warning  := 0;
  dynsql :=
   'select 1 
    from dual
    where not exists
    (select null
        from ' || '&view_loc' || '_parameter b, '
               || '&view_loc' || '_parameter e
       where b.snap_id         = :bid
         and e.snap_id         = :eid
         and b.dbid            = :dbid
         and e.dbid            = :dbid
         and b.instance_number = :inst_num
         and e.instance_number = :inst_num
         and b.parameter_hash  = e.parameter_hash
         and b.parameter_name = ''timed_statistics''
         and b.value           = e.value)';
  execute immediate dynsql 
  into is_warning
  using :bid, :eid, :dbid, :dbid, :inst_num, :inst_num;
  
  IF (is_warning = 1) THEN
    dbms_output.put_line ('WARNING: timed_statistics setting changed between ' ||
                          'begin/end snaps: TIMINGS ARE INVALID');
  END IF;  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    is_warning := 0;
  WHEN OTHERS THEN RAISE;
END;
/
select output from table(dbms_workload_repository.&fn_name( :dbid,
                                                            :inst_num,
                                                            :bid, :eid,
                                                            :sqlid,
                                                            :rpt_options,
                                                            :condbid ));

spool off;

prompt Report written to &report_name.

set termout off;
clear columns sql;
ttitle off;
btitle off;
repfooter off;
set linesize 78 termout on feedback 6 heading on;

-- Undefine script name
undefine script_name

-- Undefine con_dbid (created in awrrptidc.sql)
undefine con_dbid

-- Undefine report name (created in awrinpnm.sql)
undefine report_name

-- Undefine sql_id
undefine sql_id

undefine report_type
undefine ext
undefine fn_name
undefine lnsz

undefine NO_OPTIONS

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

undefine report_type_def
undefine view_loc_def

whenever sqlerror continue;
--
--  End of script file;
