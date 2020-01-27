set echo off

rem $Header$
rem $Name$          lsscstat.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set termout on verify off heading off feed off

define htst_stats = 'C'

accept htst_workspace  prompt 'Enter the workspace name                  : '
accept htst_scenario   prompt 'Enter the scenario name                   : '
accept htst_stats      prompt 'Display? (S)tats/(L)atches/(A)ll/(C)ustom : '

set termout off

col id1 new_val htst_id1

select id id1
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace')
   and UPPER(name)=UPPER('&htst_scenario');

set termout on heading on linesize 132 pages 1000

col stat_name     format  a40           heading 'Statistic Name' word_wrapped
col stat_diff     format  9,999,999,990 heading 'Value'
col stat_type     format  a5            heading 'Type '

break on stat_type skip 1

@lsscstat_cmd

set termout off heading on

clear break
clear columns
undefine htst_workspace
undefine htst_scenario
undefine htst_id1
undefine htst_stats

@henv
