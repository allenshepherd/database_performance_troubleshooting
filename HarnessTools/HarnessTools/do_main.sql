set echo off

rem $Header$
rem $Name$      do_main.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

rem This is the main body of the test script.  It is called from various headers that allow
rem input to either be accepted from prompts or entered from the command line.
rem
rem See do.sql, dosql.sql, doplsql.sql and docmd.sql.
rem

set termout on pause off autotrace off heading on

set echo &debug termout &debug
column termout_setting new_value htst_dotermout
select decode(UPPER('&htst_doterm'),'Y','ON','N','OFF','OFF') as termout_setting
  from dual ;

set echo off termout &debug heading off feedback off

rem Delete all old entries for this scenario
select '@_rmsc ' || id
from HSCENARIO
where UPPER(workspace)=UPPER('&htst_workspace')
and UPPER(name)=UPPER('&htst_scenario')

spool do&htst_workspace&htst_scenario..lst replace
/
spool off

set echo &debug

@do&htst_workspace&htst_scenario..lst

rem Get a new scenario id for this scenario
col newsc_scenario_id new_value htst_scenario_id
select to_char(nvl(max(id),0)+1) newsc_scenario_id from HSCENARIO;

insert into HSCENARIO (id, workspace, name, test_type)
select &htst_scenario_id, UPPER('&htst_workspace'), UPPER('&htst_scenario'), decode(UPPER('&htst_test_type'),'S','S','P','P','S')
  from dual
 where not exists
           (select null
              from HSCENARIO
             where UPPER(workspace) = UPPER('&htst_workspace')
               and UPPER(name) = UPPER('&htst_scenario')
            );

commit ;

rem Execute to get snapshots and 10046 trace data collection
rem Output will display if requested

alter session set max_dump_file_size=unlimited;
alter session set timed_statistics=true;
alter session set statistics_level=all;
alter session set tracefile_identifier = 'harness' ;

set heading on pagesize 66 termout &debug echo on

rem Set up bind variables and specific session settings
@binds

rem This executes the test code once prior to the actual test (i.e. for hard parse) if requested
set echo &debug
set termout off verify off heading off feed off

select '@&do_file' the_exec
  from dual
 where substr(upper('&htst_exec_init'), 1, 1) = 'Y'

spool exec_init&htst_scenario_id..lst replace
/
spool off

@exec_init&htst_scenario_id..lst

rollback ;

set echo on
set termout &debug

rem Capture session parameter settings for this scenario
rem If the hotsos_parameters view has been created and
rem user has permission on it, then this statement can
rem point to that view instead in order to get hidden
rem parameter settings
rem
insert into hscenario_sessparam (hscenario_id, hsessparam_id, value)
    select s.id, p.id, v.value
      from hscenario s, hsessparam p, v$parameter v -- sys.hotsos_parameters v
     where  UPPER(s.workspace) = UPPER('&htst_workspace')
       and  UPPER(s.name) = UPPER('&htst_scenario')
       and  p.id = v.num
/

commit ;

rem Taking first snapshot
set termout on echo &debug
exec snap_request(&htst_scenario_id, 1, &my_sid, 'N', '&htst_pipename')
set termout &debug echo &debug

rem Turn on 10046 level 12
alter session set events '10046 trace name context forever, level 12';

rem Executing test
set termout &htst_dotermout heading on
set echo &debug verify off feedback off  linesize 8000

@&do_file

set echo &debug termout &debug heading on feed off linesize 200

rem Taking second snapshot
set termout on echo &debug
exec snap_request(&htst_scenario_id, 2, &my_sid, 'N', '&htst_pipename')
set termout &debug echo on

rem Rolling back transaction
rollback ;

rem Turning off 10046 level 12
alter session set events '10046 trace name context off';

rem Capturing trace file
exec hotsos_pkg.capture_trace_files(&htst_scenario_id, 10046)

rem Establishing a new session
@hlogoffon

set heading off feed off termout &debug
column filename new_val f format a50

rem Getting trace file name
select 'Extended SQL Trace (10046) Filename =', filename
  from user_avail_trace_files
 where hscenario_id = &htst_scenario_id
   and trc_type = 10046
   and dt = (select max(dt)
               from user_avail_trace_files
              where hscenario_id = &htst_scenario_id
                and trc_type = 10046);

set termout &debug verify off heading off feed off

spool exec_10046_&htst_workspace&htst_scenario&htst_scenario_id..lst replace

rem Prepare to load 10046 if requested

select 'exec hotsos_pkg.trace_file_upload(' ||
       '''' || '&f' || '''' || ', &htst_scenario_id, 10046)' the_exec
  from dual
 where substr(upper('&htst_yn'), 1, 1) = 'Y'
/

rem Load 10046 trace file contents if requested
select 'exec load_trace(&htst_scenario_id, 10046)' the_exec
  from dual
 where substr(upper('&htst_yn'), 1, 1) = 'Y'
/
spool off

rem Execute the 10046 trace file load
@exec_10046_&htst_workspace&htst_scenario&htst_scenario_id..lst

set head off feed off term on

rem Display error message if trace file(s) didn't load
prompt
select 'Extended SQL Trace (10046) file DID NOT load!' the_msg
  from dual
 where not exists (select null from hscenario_10046_line
                    where hscenario_id = &htst_scenario_id)
/

rem If this is a SQL test file, must gather 10053 and plan data...else skip it
set termout &debug verify off heading off feed off

spool exec_sql&htst_scenario_id..lst replace

select '@hbldstatdtl &htst_scenario_id' the_test_type
  from dual
 where substr(upper('&htst_test_type'), 1, 1) = 'S'
/

select '@do_sqltest' the_test_type
  from dual
 where substr(upper('&htst_test_type'), 1, 1) = 'S'
/
spool off

@exec_sql&htst_scenario_id..lst

set term on
prompt
prompt
prompt Statistics Snapshot for &htst_workspace:&htst_scenario
prompt


set termout &debug verify off heading off
set feed off linesize 130 pagesize 0 echo &debug

set term &debug

rem Populate hscenario_snap_diff
rem

insert into hscenario_snap_diff
select  &htst_scenario_id hscenario_id
       ,decode(p.type, 'STAT', 'Stats', 'LATCH', 'Latch', 'CUST', 'Time', '?') stat_type
       ,decode(p.name,'elapsed time','elapsed time (centiseconds)',p.name) stat_name
       ,nvl(s2.value,0) - nvl(s1.value,0) stat_diff
       ,p.always_print
  from hstat p, hscenario_snap_stat s1, hscenario_snap_stat s2
 where s1.hscenario_id = &htst_scenario_id
   and s2.hscenario_id=s1.hscenario_id
   and s1.hstat_id=p.id
   and s2.hstat_id=s1.hstat_id
   and s1.snap_id=1
   and s2.snap_id=2
/

commit ;

define htst_id1 = &htst_scenario_id

-----------------------------------------
-- Display captured stats
-----------------------------------------

col stat_name     format  a40           heading 'Statistic Name' word_wrapped
col stat_diff     format  9,999,999,990 heading 'Value'
col stat_type     format  a5            heading 'Type '

set termout on heading on linesize 132 pages 1000
break on stat_type skip 1

@lsscstat_cmd

clear break
clear columns

undefine htst_dofile
undefine htst_workspace
undefine htst_scenario
undefine htst_dotermout
undefine htst_yn
undefine do_file
undefine htst_stmt_id
undefine htst_scenario_id
undefine f
undefine cur_id
undefine cur_val
undefine maxln
undefine 1
undefine 2
undefine 3
undefine v_nrows
undefine htst_id1
undefine htst_exec_init
undefine htst_stats
undefine htst_test_type

-- Remove all files created during test execution
-- Comment this out to save files for review
@hrmtempfile *.lst

-- Reset environment
@henv
@hlogin
