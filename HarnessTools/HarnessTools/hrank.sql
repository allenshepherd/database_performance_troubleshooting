set echo off

rem $Header$
rem $Name$          hrank.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem

set termout on linesize 200 pages 200 autotrace off pause off feedback off heading off

accept htst_workspace prompt 'Enter the workspace name: '

prompt
prompt
prompt Scenario ranking for workspace &htst_workspace by elapsed time
set heading on

col scenario_name format a40            heading 'Scenario Name'
col elapsed_time  format 9,999,999,990.000000   heading 'Elapsed Time (secs)'


select round(d.stat_diff/100,6) elapsed_time, substr(s.name,1,40) scenario_name
  from hscenario_snap_diff d, hscenario s
 where d.hscenario_id = s.id
   and upper(s.workspace)=upper('&htst_workspace')
   and d.stat_type = 'Time'
 order by d.stat_diff ;

undefine htst_workspace
clear columns
@henv
