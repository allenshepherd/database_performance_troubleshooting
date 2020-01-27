set echo off

rem $Header$
rem $Name$			lsscexpl.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem

set linesize 132 pages 600 heading off verify off termout on feed off

accept htst_workspace  prompt 'Enter the workspace name: '
accept htst_scenario   prompt 'Enter the scenario name : '

define htst_ct_chk = 0
col id1 new_val htst_id1
col ct  new_val htst_ct_chk

set termout off
whenever sqlerror continue;

select id id1, 1 ct
  from hscenario 
 where UPPER(workspace)=UPPER('&htst_workspace') 
   and UPPER(name)=UPPER('&htst_scenario');

select 0 id1
  from dual 
 where &htst_ct_chk = 0;

set termout on

select p.plan_output
  from hscenario_plans p
 where p.hscenario_id = &htst_id1
   and &htst_ct_chk != 0
  order by p.line#
/

undefine htst_id1
undefine htst_ct_chk
undefine htst_workspace
undefine htst_scenario
undefine htst_id1

clear columns
@henv
