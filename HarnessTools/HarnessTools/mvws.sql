set echo off

rem $Header$
rem $Name$			mvws.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set heading off feedback off termout on

accept htst_workspace1 prompt 'Enter the old workspace name: '
accept htst_workspace2 prompt 'Enter the new workspace name: '

set termout on

update hscenario
	set workspace=upper('&htst_workspace2')
where workspace=upper('&htst_workspace1');

undefine htst_workspace1
undefine htst_workspace2

@lsws
