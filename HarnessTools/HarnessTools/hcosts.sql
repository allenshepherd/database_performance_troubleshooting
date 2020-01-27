set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on

accept htst_workspace prompt 'Enter the workspace name: '

set echo off feedback off
set heading on termout on

col workspace    format a20 heading 'Workspace'
col name	     format a20 heading 'Scenario'
col cost	     format 999999999 heading 'Plan Cost'

select distinct cost, workspace, name
from hscenario_plan_table p, hscenario h
where p.hscenario_id = h.id
and UPPER(h.workspace) = UPPER('&htst_workspace')
and p.cost is not null
and p.id = 0
/

clear columns
undefine htst_workspace

@henv
