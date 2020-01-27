set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on heading on feed off lines 300
accept htst_owner default user prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

column index_name format a30  word_wrapped heading 'Index Name'
column column_name format a30 word_wrapped heading 'Column Name'
column column_position format 999999999 heading 'Position'
column descend format a5 heading 'Order'
column column_expression format a40 heading 'Expression'
break on index_name skip 1

select b.index_name, b.column_position, b.column_name, b.descend, e.column_expression
  from all_ind_columns b, all_ind_expressions e
 where b.table_owner = UPPER('&htst_owner')
   and b.table_name = UPPER('&htst_table') 
   and b.index_name = e.index_name(+)
 order by b.index_name, b.column_position, b.column_name
/ 


set numwidth 15
column index_name format a25  word_wrapped heading 'Index Name'
column index_type format a4 heading 'Type'
column blevel heading 'BLevel'
column leaf_blocks format 99999999999 heading 'Leaf Blocks'
column distinct_keys format 99999999999 heading 'Distinct Keys'
column avg_leaf_blocks_per_key format 99999999999 heading 'Avg Leaf Blks/Key'
column avg_data_blocks_per_key format 99999999999 heading 'Avg Data Blks/Key'
column clustering_factor format 99999999999 heading 'Clustering Factor'
column degree format a8 heading 'Degree'
column zero  heading ''

select a.index_name, a.blevel, a.leaf_blocks, a.distinct_keys,
	   a.clustering_factor, a.avg_leaf_blocks_per_key, 
	   a.avg_data_blocks_per_key, '-' zero,
	   substr(a.index_type, 1, 4) index_type, 
	   to_char(a.last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed,
	   a.partitioned, a.degree
  from all_indexes a
 where a.table_owner = UPPER('&htst_owner')
   and a.table_name = UPPER('&htst_table') 
/

clear columns
undefine htst_owner
undefine htst_table

@henv
