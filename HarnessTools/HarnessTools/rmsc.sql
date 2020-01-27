set echo off

rem $Header$
rem $Name$			rmsc.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on heading off feedback off verify off

accept htst_workspace prompt 'Enter the workspace name: '
accept htst_scenario  prompt 'Enter the scenario name : '

set termout off 

spool rmsc.lst
select '@_rmsc ' || id
  from hscenario
 where UPPER(workspace)=UPPER('&htst_workspace') 
   and UPPER(name)=UPPER('&htst_scenario');
spool off

@rmsc.lst
Prompt Done.

@hrmtempfile rmsc.lst

undefine htst_workspace
undefine htst_scenario

@henv
