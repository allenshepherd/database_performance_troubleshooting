set echo off

rem $Header$
rem $Name$		hnobind.sql

rem Copyright (c); 2001-2011 by Hotsos Enterprises, Ltd.
rem 
rem  Notes: Use this script to find candidate SQL statements that don't use bind
rem         variables. Statements that are most offensive appear at the beginning
rem         of the report. The user is prompted before each page is displayed.
rem         You'll probably be able to make a huge impact on 'shared pool' latch
rem         contention if you address the things on the first page of this report's
rem         output. Simply press ^C after the first page is displayed. Output is
rem         written to nobind.out.
rem 

accept plen prompt 'Enter the string length to use for binds comparison: '

set termout  on
set verify   off
set pause    on
set pause    'More: '
set pagesize 24

col sql_text format a35 word_wrap

select min(hash_value) min_hash_value ,
       max(hash_value) max_hash_value ,
       count(1)-1 ndups ,
       substr ( sql_text , 1 , &plen ) sql_text
  from v$sql
 group by substr ( sql_text , 1 , &plen )
having count(1) > 10
 order by ndups desc

spool nobind.out
/
spool off

set pause off

undefine plen
clear columns
@henv
