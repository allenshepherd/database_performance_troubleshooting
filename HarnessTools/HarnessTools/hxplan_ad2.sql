set echo off

rem $Header$
rem $Name$		hxplan.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Display explain plan output from plan_table
rem Display adaptive 
rem


set linesize 230 pagesize 0 pause off autotrace off termout on verify off

accept htst_dofile    prompt 'Enter .sql file name (without extension): ' 
accept display_level  default 'TYPICAL' prompt 'Enter the display level (TYPICAL, ALL, BASIC, SERIAL, +ADAPTIVE, +REPORT) [TYPICAL]  : '

define plan_file = '&htst_dofile'

set termout off heading off feedback off

get &plan_file

save explbig.tmp replace

col pid new_value explbig_statement_id

select userenv('sessionid') pid from dual;

get explbig.tmp

0 explain plan set statement_id='&explbig_statement_id' for
/

set termout on

select * from table(dbms_xplan.display_cursor('plan_table','&explbig_statement_id','&display_level'));

set termout off

set pagesize 60

@hrmtempfile explbig.tmp

undefine explbig_statement_id
undefine 1
undefine plan_file
undefine htst_dofile
undefine display_level

set termout on

clear columns
@henv
