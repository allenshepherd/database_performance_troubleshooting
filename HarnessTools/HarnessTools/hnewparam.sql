set echo off

rem $Header$
rem $Name$		hnewparam.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 

set pause off  verify off termout off

col hsessparam_val new_value hsessparam_max

select nvl(max(id),0)+1 hsessparam_val from HSESSPARAM;
insert into HSESSPARAM (id, name) values (&hsessparam_max+1, '_&1');
insert into HSESSPARAM (id, name) values (&hsessparam_max, '&1');

undefine hessparam_max
clear columns
@henv
