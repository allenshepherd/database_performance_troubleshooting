rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Retrieve statistics information for a column of a table
rem
rem Usage:  SQL>@hhilo
rem

set echo off feed off termout on
accept htst_owner   prompt 'Enter the owner name : '
accept htst_table   prompt 'Enter the table name : '
accept htst_column  prompt 'Enter the column name: '

col lo_hi format a100
set lines 105

select 'LOW: '||trim(to_char(boil_raw(low_value,data_type)))||
       '  HIGH: '|| trim(to_char(boil_raw(high_value,data_type)))
       as "Column Low and Hi Values"
  from all_tab_columns
 where table_name = UPPER('&htst_table')
   and owner = UPPER('&htst_owner')
   and column_name = UPPER('&htst_column')
/

undefine tabname
undefine htst_owner
undefine htst_table
undefine htst_column

clear columns
clear breaks

@henv
