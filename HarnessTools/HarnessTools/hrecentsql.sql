set echo off

rem $Header$
rem $Name$      hrecentsql.sql

rem Copyright (c); 2006-2011 by Hotsos Enterprises, Ltd.
rem
rem Usage: @hrecentsql &htst_user &htst_str
rem
rem Parameters:
rem &htst_user = user
rem &htst_str = SQL pattern to match on lookup
rem
rem Retrieve the SQL text and hash values for recently executed SQL
rem for a named user and which matches a specified pattern
rem

set verify off feed off lines 500 heading on termout on

accept htst_user prompt 'Enter the user name: '
accept htst_str prompt 'Enter a pattern to match (must be exact or blank for all): '


col sql_text for a150

select /* hrecentsql */ child_number, hash_value, address, executions, sql_text
  from v$sql
 where parsing_user_id = (select user_id
                            from all_users
                           where username = UPPER('&htst_user'))
   and command_type in (2,3,6,7,189)
   and UPPER(sql_text) like UPPER('%&htst_str%')
   and UPPER(sql_text) not like UPPER('%hrecentsql%')
/

undefine htst_user
undefine htst_str
clear columns
@henv
