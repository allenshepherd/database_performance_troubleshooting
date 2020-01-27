set echo off

rem $Header$
rem $Name$		hxplan.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Display explain plan output from plan_table
rem


set linesize 230 pagesize 0 pause off autotrace off termout on verify off

accept display_level  default 'TYPICAL' prompt 'Enter the display level (TYPICAL, ALL, BASIC, SERIAL) [TYPICAL]  : '

set termout off heading off feedback off

set termout on

select * from table(dbms_xplan.display_cursor(format=>'&display_level'));

set termout off

set pagesize 60

undefine explbig_statement_id
undefine 1
undefine plan_file
undefine htst_dofile
undefine display_level

set termout on

clear columns
@henv
