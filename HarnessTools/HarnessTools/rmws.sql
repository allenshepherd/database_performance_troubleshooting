set echo off

rem $Header$
rem $Name$			rmws.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set termout on heading off feedback off
accept htst_workspace prompt 'Enter the workspace name to remove (* for all): '

Prompt removing workspace(s).......

set termout off heading off feedback off  verify off
col id new_val sc_id

spool rmws.lst

select  '@_rmsc ' || id||chr(10)||
		'exec hotsos_pkg.delete_trace_files(' || id || ', 10046)'||chr(10)||
		'exec hotsos_pkg.delete_trace_files(' || id || ', 10053)' sql_stmt
  from hscenario
 where UPPER(workspace) = case when '&htst_workspace'='*' 
							   then UPPER(workspace) 
							   else UPPER('&htst_workspace') 
						  end;


spool off
set termout on heading on 

@rmws.lst

Prompt Done.

@hrmtempfile rmws.lst

undefine htst_workspace
undefine sc_id
clear columns

@henv
