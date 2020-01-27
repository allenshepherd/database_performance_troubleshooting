set echo off 

rem $Header$
rem $Name$			htabstats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Retrieve statisitics information for a table
rem


set verify off feed off numwidth 15 lines 500 heading on termout on

accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

  
prompt 
prompt 
prompt Table Information
prompt *****************

column table_name heading 'Table Name'
column degree heading 'Degree'
column partitioned format a5 heading 'Par?'
column num_rows format 999,999,999,990 heading '# Rows'
column blocks format 999,999,999,990 heading 'Blocks'
column avg_space format 999,999,999,990 heading 'Avg Space'
column empty_blocks format 999,999,999,990 heading 'Empty Blocks'
column avg_row_len format 999,999,999,990 heading 'Avg Row Len'
column last_analyzed heading 'Analyzed'
column monitoring format a10 heading 'Monitored?'

select table_name, to_char(last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed, 
	   num_rows, blocks, empty_blocks, avg_space, avg_row_len,
	   partitioned, degree, monitoring
 from all_tables
 where owner = UPPER('&htst_owner')
 and table_name = UPPER('&htst_table')
/

prompt 

column high_value format a30 heading 'Partition Bound'

select partition_name, high_value, last_analyzed, num_rows, chain_cnt, blocks, empty_blocks, avg_space, avg_row_len
 from all_tab_partitions
 where table_owner = UPPER('&htst_owner')
 and table_name = UPPER('&htst_table')
/

prompt 
prompt 
prompt Columns Information
prompt *******************

column column_name  format a20 word_wrapped heading 'Column Name'
column num_distinct format 99999999999 heading 'NDV'
column density      format 9.999999 heading 'Density'
column nullable     format a5 heading 'Nulls?'
column num_nulls	heading '# Nulls'
column lowval		format a20 word_wrapped heading 'Low Value'
column hival		format a20 word_wrapped heading 'High Value'
column sample_size  format 99999999999 heading 'Sample Size'
column histinfo     format a20 heading 'Histogram Info'
column num_buckets	heading '# Buckets'
column histogram    format a10 heading 'Histogram'
column avg_col_len  heading 'Avg Length'
column valrange		format a75 word_wrapped heading 'Lo-Hi Values'
column last_analyzed heading 'Last Analyzed'

select column_name, to_char(last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed, 
	   num_distinct, sample_size, nullable, num_nulls, 
	   num_buckets,density,avg_col_len,  
--	   boil_raw(low_value,DATA_TYPE) lowval , 
--	   boil_raw(high_value,DATA_TYPE) hival,
   	   boil_raw(low_value,DATA_TYPE) || ', ' ||  
	   boil_raw(high_value,DATA_TYPE) valrange
--	   case when histogram = 'NONE' then ' '
--	        else histogram || ' (' || to_char(num_buckets) || ')'
--	        end histinfo
  from all_tab_cols 
 where owner = UPPER('&htst_owner') and table_name = UPPER('&htst_table')
/

prompt 

column endpoint_number heading 'Endpoint Number'
column endpoint_value heading 'Endpoint Value'
column endpoint_actual_value format a40 heading 'Endpoint Actual Value'

break on column_name skip 1

select b.column_name, b.endpoint_number, 
--	   b.endpoint_value, 
	   b.endpoint_actual_value
  from all_tab_histograms b
 where b.owner = UPPER('&htst_owner')
   and b.table_name = UPPER('&htst_table') 
   and (exists (select 1 from all_tab_cols 
   	         where num_buckets > 1 
   	           and owner = b.owner 
   	           and table_name = b.table_name
   	           and column_name = b.column_name) 
   	or
   	exists (select 1 from all_tab_histograms
   	         where endpoint_number > 1
   	           and owner = b.owner
   	           and table_name = b.table_name
   	           and column_name = b.column_name)
   	)
 order by b.column_name, b.endpoint_number
/

clear breaks

prompt 
prompt 
prompt Index Definitions
prompt ******************

column index_name format a30  word_wrapped heading 'Index Name'
column column_position format 999999999 heading 'Position'
column descend format a5 heading 'Order'
column column_expression format a40 heading 'Expression'

rem break on index_name skip 1

select b.index_name, b.column_position, b.column_name, b.descend, e.column_expression
  from all_ind_columns b, all_ind_expressions e
 where b.table_owner = UPPER('&htst_owner')
   and b.table_name = UPPER('&htst_table') 
   and b.index_name = e.index_name(+)
 order by b.index_name, b.column_position, b.column_name
/ 

set numwidth 15
column index_name format a30  word_wrapped heading 'Index Name'
column index_type format a4 heading 'Type'
column blevel heading 'BLevel'
column leaf_blocks format 99999999999 heading 'Leaf Blocks'
column distinct_keys format 99999999999 heading 'Distinct Keys'
column avg_leaf_blocks_per_key format 99999999999 heading 'Avg Leaf Blks/Key'
column avg_data_blocks_per_key format 99999999999 heading 'Avg Data Blks/Key'
column clustering_factor format 99999999999 heading 'Clustering Factor'
column degree format a8 heading 'Degree'
column zero  heading ''

clear breaks

select a.index_name, a.blevel, a.leaf_blocks, a.distinct_keys,
	   a.clustering_factor, a.avg_leaf_blocks_per_key, 
	   a.avg_data_blocks_per_key, '-' zero,
	   substr(a.index_type, 1, 4) index_type, 
	   to_char(a.last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed,
	   a.partitioned, a.degree
  from all_indexes a
 where a.table_owner = UPPER('&htst_owner')
   and a.table_name = UPPER('&htst_table') 
 order by a.index_name
/

undefine htst_owner
undefine htst_table

clear columns
clear breaks

@henv
