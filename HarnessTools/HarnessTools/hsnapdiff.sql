set echo off

rem $Header$
rem $Name$          hsnapdiff.sql

rem Copyright (c); 2007-2011 by Hotsos Enterprises, Ltd.
rem

set termout on verify off heading off feed off

define htst_stats = 'C'

accept htst_workspace  prompt 'Enter the workspace name: '
accept htst_scenario   prompt 'Enter the scenario name : '
accept htst_stats      prompt 'Display? (A)ll/(C)ustom : '

set termout off

col id1 new_val htst_id1

select id id1
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace')
   and UPPER(name)=UPPER('&htst_scenario');

set termout on heading on linesize 132 pages 1000

select a.hstat_id stat#, n.name statname, a.value before_value, b.value after_value, b.value - a.value difference
  from hscenario_snap_stat a, hscenario_snap_stat b, hstat n
 where a.hstat_id = b.hstat_id
   and a.hscenario_id = &&htst_id1
   and b.hscenario_id = &htst_id1
   and a.snap_id = 1
   and b.snap_id = 2
   and a.hstat_id = n.id
   and b.hstat_id = n.id
   and (b.value - a.value) != 0
   and n.always_print = 1
   and upper('&htst_stats') = 'C'
 order by lower(n.name)
/


select a.hstat_id stat#, n.name statname, a.value before_value, b.value after_value, b.value - a.value difference
  from hscenario_snap_stat a, hscenario_snap_stat b, hstat n
 where a.hstat_id = b.hstat_id
   and a.hscenario_id = &&htst_id1
   and b.hscenario_id = &htst_id1
   and a.snap_id = 1
   and b.snap_id = 2
   and a.hstat_id = n.id
   and b.hstat_id = n.id
   and (b.value - a.value) != 0
   and upper('&htst_stats') != 'C'
 order by lower(n.name)
/



set termout off heading on

clear break
clear columns
undefine htst_workspace
undefine htst_scenario
undefine htst_id1
undefine htst_stats

@henv
