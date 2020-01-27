set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Notes: Gets variable definition from HVARIABLE table
rem        for use in SQL Test Harness
rem 

set termout off verify off heading off

col hdef_cmd fold_after

select 'define &1=''' || decode('&&hdef_tmp', '', value, upper('&&hdef_tmp')) || ''''
from hvariable
where name = upper('&1')

spool hdef.lst
/
spool off

@hdef.lst

update hvariable
	 set isnull='N'
	,value=upper('&&hdef_tmp')
where name=upper('&1')
and '&&hdef_tmp' is not null;

@hrmtempfile hdef.lst

set termout on heading on feedback off
