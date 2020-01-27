set echo off

rem $Header$
rem $Name$		hrmtempfile.sql

rem Copyright (c); 2006 by Hotsos Enterprises, Ltd.
rem 

set termout off verify off heading off feed off

select '&_hst &_rm &1' as cmnd from dual

spool deltmpfile.cmd
/
spool off

@deltmpfile.cmd
