set echo off

rem $Header$
rem $Name$		hmobj.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 
rem Display basic object information

set termout on feedback off heading on verify off

select object_name , object_type, status,
	   to_char(created,'mm/dd/yyyy hh24:mi:ss') created, 
	   to_char(last_ddl_time,'mm/dd/yyyy hh24:mi:ss') last_ddl_time
from all_objects
where object_name like upper('&1%');

@henv
