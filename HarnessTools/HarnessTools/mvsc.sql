set echo off

rem $Header$
rem $Name$		mvsc.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set feedback off termout on heading off 

accept htst_workspace1 prompt 'Source WORKSPACE name: '
accept htst_scenario1  prompt 'Source SCENARIO name : '
accept htst_workspace2 prompt 'Destination WORKSPACE name: '
accept htst_scenario2  prompt 'Destination SCENARIO name : '

set term off

update hscenario 
   set workspace=upper('&htst_workspace2')
	  ,name=upper('&htst_scenario2')
 where workspace=upper('&htst_workspace1')
   and name=upper('&htst_scenario1');

undefine htst_workspace1
undefine htst_scenario1
undefine htst_workspace2
undefine htst_scenario2

@lsws
