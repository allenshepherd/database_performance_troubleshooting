set echo off

rem $Header$
rem $Name$			hsqlrunning.sql

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem 
rem Notes:  This script runs at the SQL prompt and gives the text 
rem of the SQL being currently run on the machine. Also gives the SID 
rem and Serial# which may be used to kill the session by using the 
rem following at the SQL prompt. 
rem
rem ALTER SYSTEM KILL SESSION 'SID,SERIAL#' 
rem 
rem Script does not display this SQL statement in the output.
rem


break on sid skip 1 on username 

column sid format 9999 
column username format a10 
column sql_text word_wrapped

select a.sid,a.serial#,a.username,b.address,b.hash_value,b.sql_text 
  from v$session a,v$sqltext b 
 where a.username is not null 
   and a.status = 'ACTIVE' 
   and a.sql_address = b.address 
   and a.sid != (select distinct sid from v$mystat)
 order by a.sid,a.serial#,b.piece; 

clear columns
clear breaks

@henv
