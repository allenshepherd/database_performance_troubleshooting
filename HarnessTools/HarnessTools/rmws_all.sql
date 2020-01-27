set echo off

rem $Header$
rem $Name$		rmws_all.sql

rem Copyright (c); 2004-2006 by Hotsos Enterprises, Ltd.
rem 

set term on
Prompt removing workspace(s).......

set termout off heading off feedback off  ver off
spool rmws.lst

select  '@_rmsc ' || id||chr(10)||
		'exec hotsos_pkg.delete_trace_files(' || id || ', 10046)'||chr(10)||
		'exec hotsos_pkg.delete_trace_files(' || id || ', 10053)' sql_stmt
  from  hscenario
/

spool off
set termout on heading on 

@rmws.lst
Prompt Done.

@hrmtempfile rmws.lst

clear columns
@henv
