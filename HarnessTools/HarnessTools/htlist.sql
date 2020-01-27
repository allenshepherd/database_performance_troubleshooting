set echo off

rem $Header$
rem $Name$		htlist.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Display list of tables from USER_TABLES
rem


select table_name , num_rows, to_char(last_analyzed, 'yyyy/mm/dd hh24:mi:ss') last_analyzed
  from user_tables 
 order by table_name
/

@henv
