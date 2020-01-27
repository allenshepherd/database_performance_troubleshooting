set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Displays index CLUF for all indexes on specified table
rem

set termout on
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

column table_name noprint
column index_name noprint
column tabidx format a40 word_wrapped heading 'Table.Index Name'

break on table_name skip 1

select t.table_name, i.index_name, t.table_name||'.'||i.index_name tabidx,
       i.clustering_factor, t.blocks, t.num_rows
  from all_indexes i, all_tables t
 where i.table_name = t.table_name
   and t.table_name like UPPER('&htst_table')||'%'
   and t.owner = UPPER('&htst_owner')
 order by t.table_name, i.index_name
/

clear columns
clear breaks

undefine htst_owner
undefine htst_table

@henv
