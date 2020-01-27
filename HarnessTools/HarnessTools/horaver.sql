rem $Header$
rem $Name$		horaver.sql

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem 

rem Determine version for specific plan capture
rem oraver: 1 = v10
rem oraver: 8 = v8
rem oraver: 9 = v9

set termout off

column oraver new_val db_ver
column oraver10 new_val db_ver10

select substr(replace(version,'.',''),1,1) oraver, 
	   substr(replace(version,'.',''),1,3) oraver10
  from v$instance ;

set termout on
