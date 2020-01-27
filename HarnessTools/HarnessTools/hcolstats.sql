set echo off

rem $Header$
rem $Name$      hcolstats.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem

alter session set nls_date_format = 'mm/dd/yyyy hh24:mi:ss';

set termout on heading on feed off lines 300
accept htst_owner default user prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

column column_name  format a20 word_wrapped heading 'Column Name'
column num_distinct format 99999999999 heading 'NDV'
column density      format 9.999999 heading 'Density'
column nullable     format a5 heading 'Nulls?'
column num_nulls    heading '# Nulls'
column lowval       format a20 word_wrapped heading 'Low Value'
column hival        format a20 word_wrapped heading 'High Value'
column sample_size  format 99999999999 heading 'Sample Size'
column histinfo     format a20 heading 'Histogram Info'
column num_buckets  heading '# Buckets'
column histogram    format a10 heading 'Histogram'
column avg_col_len  heading 'Avg Length'
column valrange     format a75 word_wrapped heading 'Lo-Hi Values'
column last_analyzed heading 'Last Analyzed'

select column_name,
       num_distinct, sample_size, nullable, num_nulls,
       num_buckets, density, avg_col_len,
       last_analyzed,
--       to_char(last_analyzed,'mm/dd/yyyy hh24:mi:ss') last_analyzed,
--     boil_raw(low_value,DATA_TYPE) lowval ,
--     boil_raw(high_value,DATA_TYPE) hival,
       boil_raw(low_value,DATA_TYPE) || ', ' ||
       boil_raw(high_value,DATA_TYPE) valrange
--     case when histogram = 'NONE' then ' '
--          else histogram || ' (' || to_char(num_buckets) || ')'
--          end histinfo
  from all_tab_cols
 where owner = UPPER('&htst_owner') and table_name = UPPER('&htst_table')
/

clear columns
undefine htst_owner
undefine htst_table

@henv
