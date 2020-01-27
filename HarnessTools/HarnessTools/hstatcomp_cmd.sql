set echo off

rem $Header$
rem $Name$      hstatcomp_cmd.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Command line version of hstatcomp.sql
rem This version also only retrieves a single specific statistic
rem and shows the value for all scenarios
rem
rem Usage:
rem define stat = "'consistent gets'"
rem @hstatcomp_cmd workspace &stat
rem

set feedback off heading on termout on

rem accept htst_workspace prompt 'Enter the workspace name: '
rem accept htst_stat_name prompt 'Enter the statistic name: '

define htst_workspace = &1
define htst_stat_name = '&2'

col name         format a20 heading 'Scenario'
col stat_diff    format 999,999,999,999 heading '&htst_stat_name'

select h.name, d.stat_diff
  from hscenario_snap_diff d, hscenario h
 where d.hscenario_id = h.id
   and UPPER(h.workspace) = UPPER('&htst_workspace')
   and lower(d.stat_name) =  lower('&htst_stat_name')
 order by d.stat_diff, h.name
/

clear columns
undefine htst_workspace
undefine htst_stat_name
undefine 1
undefine 2


@henv
