set echo off

rem $Header$
rem $Name$          do_sqltest.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Usage:  called by do.sql to capture 10053 and plan data for SQL tests
rem 
rem
rem     Added 12c to checks for @do_v10r2.sql


set echo &debug

rem Reconnect to get a clean trace file
@hlogoffon

rem 10053 trace data collection
set termout &debug heading on echo &debug

delete from plan_table where statement_id = '&htst_stmt_id' ;
commit ;

rem Setup bind variables
@binds

rem Turn on 10053 event
alter session set tracefile_identifier = 'harness' ;
alter session set events '10053 trace name context forever, level 1';

get &do_file

0 explain plan set statement_id='&htst_stmt_id' for
/

rem Turn off 10053 event
alter session set events '10053 trace name context off';

set termout &debug verify off heading off feed off

exec hotsos_pkg.capture_trace_files(&htst_scenario_id, 10053)

@hlogoffon

set termout &debug heading off feed off
column filename new_val f format a50

select 'Optimizer Trace (10053) Filename =', filename
  from user_avail_trace_files
 where hscenario_id = &htst_scenario_id
   and trc_type = 10053
   and dt = ( select max(dt)
                from user_avail_trace_files
               where hscenario_id = &htst_scenario_id
                 and trc_type = 10053
            );

set termout &debug verify off heading off feed off

spool exec_10053_&htst_scenario_id..lst

rem Load 10053 if requested
select 'exec hotsos_pkg.trace_file_upload(' ||
       '''' || '&f' || '''' || ', &htst_scenario_id, 10053)' the_exec
  from dual
 where substr(upper('&htst_yn'), 1, 1) = 'Y'
/

select 'exec load_trace(&htst_scenario_id, 10053)' the_exec
  from dual
 where substr(upper('&htst_yn'), 1, 1) = 'Y'
/
spool off

set termout &debug verify off heading off feed off echo &debug
rem get Oracle version
@horaver
set termout &debug

rem Set up bind variables
@binds

rem Execute specific plan capture
select case when '&db_ver10' = '102' or substr('&db_ver10',1,2) = '11'  or substr('&db_ver10',1,2) = '12' then '@do_v10r2'
            when '&db_ver' = '9' then '@do_v9'
            else '@do_v10'
       end as the_exec
  from dual

spool exec_plan&htst_scenario_id..lst
/
spool off

@exec_plan&htst_scenario_id..lst

rem Execute the 10053 trace file load
@exec_10053_&htst_scenario_id..lst

set head off feed off term on

rem Display error message if trace file(s) didn't load
prompt
select 'Optimizer Trace (10053) file DID NOT load!' the_msg
  from dual
 where not exists (select null from hscenario_10053_line
                    where hscenario_id = &htst_scenario_id)
/


rem Prints output from hbldstatdtl.sql which was loaded into hscenario_statdetail
prompt
prompt Actual PARSE and STAT line data for &htst_workspace:&htst_scenario

@hsctracecmd &htst_workspace &htst_scenario P ON
@hsctracecmd &htst_workspace &htst_scenario S ON

/*  Pulled this section out to simplify do.sql screen output

set termout on head on linesize 500

col id format 99999 heading 'ID'
col pid format 99999 heading 'PID'
col cnt format 9999999999999 heading 'Rows'
col cr format 99999999999999 heading 'LIO'
col pr format 99999999999999 heading 'PIO'
col pw format 99999999999999 heading 'Writes'
col tim format 9999999999999999999999 heading 'Time'
col op format a50 heading 'Operation'

select id, pid, op, cnt, cr, tim, pr, pw
  from hscenario_statdetail
 where hscenario_id = &htst_scenario_id
/

prompt
prompt

col tots format a100 heading 'Statement Totals (portion of total statistics attributable to this test SQL statement)'

select decode(r,1, 'Total LIO   : '||to_char(tot_cr),
                2, 'Total PIO   : '||to_char(tot_pr),
                3, 'Total Writes: '||to_char(tot_pw),
                4, 'Total Time  : '||to_char(tot_tim)||' secs') tots
  from (select sum(cr) tot_cr, sum(pr) tot_pr, sum(pw) tot_pw, sum(tim) * .000001 tot_tim
          from hscenario_statdetail
         where pid = 0
           and hscenario_id = &htst_scenario_id) qry,
       (select rownum r from all_objects where rownum <= 4 )
/

*/

set termout on heading off
prompt
prompt
prompt Explain Plan for &htst_workspace:&htst_scenario

rem column plan_output heading 'Explain Plan for Scenario &htst_workspace:&htst_scenario'
select plan_output
  from hscenario_plans
 where hscenario_id = &htst_scenario_id ;

@hrmtempfile exec_plan&htst_scenario_id..lst
