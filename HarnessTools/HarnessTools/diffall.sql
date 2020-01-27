set echo off

rem $Header$
rem $Name$          diff.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Lists the resource statistics for two scenarios for
rem all statistics that have differences.
rem

set termout on heading off feedback off verify off

accept htst_workspace1 prompt '1st workspace: '
accept htst_scenario1  prompt '1st scenario : '
accept htst_workspace2 prompt '2nd workspace: '
accept htst_scenario2  prompt '2nd scenario : '

prompt

rem Get scenario IDs
define htst_ct_chk1 = 0
define htst_ct_chk2 = 0

col id1 new_val htst_id1
col id2 new_val htst_id2
col ct1 new_val htst_ct_chk1
col ct2 new_val htst_ct_chk2
col test_type new_val htst_ttype

set termout off verify off
whenever sqlerror continue;

select id id1, 1 ct1, test_type
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace1')
   and UPPER(name)=UPPER('&htst_scenario1');

select 0 id1
  from dual
 where &htst_ct_chk1 = 0;

 select id id2, 1 ct2
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace2')
   and UPPER(name)=UPPER('&htst_scenario2');

 select 0 id2
  from dual
 where &htst_ct_chk2 = 0;

set termout off verify off heading off feed off


set linesize 200 pages 200 autotrace off pause off termout on heading on
break on type nodup skip 1

select a.stat_type type, a.stat_name name,
       a.stat_diff as "&htst_workspace1:&htst_scenario1",
       b.stat_diff as "&htst_workspace2:&htst_scenario2",
       a.stat_diff - b.stat_diff difference
  from hscenario_snap_diff a, hscenario_snap_diff b
 where a.stat_name = b.stat_name(+)
   and a.stat_diff != b.stat_diff
   and a.hscenario_id = &htst_id1
   and b.hscenario_id = &htst_id2
 order by a.stat_type, lower(a.stat_name)
/

rem If this is a SQL test file, display STAT lines...else skip it
set termout off verify off heading off feed off

spool exec_sql.lst

select 'prompt' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/

select 'prompt &htst_workspace1:&htst_scenario1' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/

select '@hsctracecmd &htst_workspace1 &htst_scenario1 S ON' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/

select 'prompt' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/

select 'prompt &htst_workspace2:&htst_scenario2' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/

select '@hsctracecmd &htst_workspace2 &htst_scenario2 S ON' the_exec
  from dual
 where substr(upper('&htst_ttype'), 1, 1) = 'S'
/
spool off

set term on

@exec_sql.lst


clear columns
clear break

@hrmtempfile exec_sql.lst

undefine htst_workspace1
undefine htst_scenario1
undefine htst_workspace2
undefine htst_scenario2
undefine htst_id1
undefine htst_id2
undefine htst_ct_chk1
undefine htst_ct_chk2
undefine htst_ttype


@henv
