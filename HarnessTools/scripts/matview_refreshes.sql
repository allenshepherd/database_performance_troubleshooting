set lines 270 pages 50000
col name for a20 trunc
col sql_text for a40 wrap
set feedback on
select * from (
select 
 q.sql_id
--, count(q.sql_id) frequency_over_snaps
, sum(q.EXECUTIONS_DELTA) executions
, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec
, parsing_schema_name as "NAME"
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) pio_per_exec
, round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  READ_BLOCKS
, round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  WRITE_BLOCKS
, round(sum(IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) Inter_bytes
, round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) ss_actual_blocks
, round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) ss_return_blocks
,  (select sql_text
            from dba_hist_sqltext
           where sql_id = q.sql_id)
             full_query
from dba_hist_sqlstat q, dba_hist_snapshot s, dba_hist_sqltext t
where
parsing_schema_name not in ('111')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and q.sql_id=t.sql_id
and t.sql_text like '%DENSE_RANK%'
and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
group by
 q.sql_id
, parsing_schema_name
order by executions, q.sql_id
) out
where out.executions >1 
/

set lines 220