set echo off

rem $Header$
rem $Name$		hsqlusers.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem   Usage: For a given hash value, this script will display sessions
rem          that have an open cursor for it. The 'running' column
rem          means that the session listed may be executing this
rem          statement or it might have just finished executing this
rem          statement and is either idle or getting ready to execute
rem          another statement.
rem
rem   Notes: This script will run on Oracle 7.3.4+.
rem

set termout on pause on pagesize 30 linesize 80 verify off
set pause     'More: '

accept hv prompt 'SQL Statement Hash Value: ' 

col running format a7

select s.sid, s.serial#, decode(s.sql_hash_value,&hv,'YES','NO') as running
  from v$session s, v$open_cursor o
 where o.sid = s.sid
   and o.hash_value = &hv
order by running desc
/

set pause off

clear columns
undefine hv
@henv
