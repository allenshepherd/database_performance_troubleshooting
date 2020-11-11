col time_Improvements for a15 trunc
col module for a20 trunc
col sql_text for a40 wrap
set lines 240 pages 50000
col COMMAND_TYPE for a13 trunc
set feedback on
PROMPT                          THE SHEPORT REPORT
PROMPT ___________________________________________________________________________________________________
PROMPT  The below data set compares two time periods for the change in avrage times
PROMPT    as well as resource utilization. The column TIME_DIFF shows the change in
PROMPT    in elapsed time (milliseconds) for the particular query along with column TIME_IMPROVEMENT
PROMPT    denoting the percentage of improvement. It's sorted in greatest time reduction
PROMPT    i.e., largest drop in time. Conversely, the bottom of the report highlights the increases
PROMPT    in time as well. Due to averaging, increases in time might not truly be increases
PROMPT    as it greatly depends on the data at time of executionalongwith frequency of executions
PROMPT    That said, any increase less than 300ms, I generally would not be overly concerned due to averaging.

PROMPT -
PROMPT TIME PERIOD : - (&&start_time1,&&end_time1) to (&&start_time2,&&end_time2)
PROMPT ____________________________________________________________________________________________________
set define on

select z.sql_id,
decode(y.command_type,1,'CREATE TABLE',2,'INSERT',3,'SELECT',6,'UPDATE',7,'DELETE',26,'LOCK TABLE',44,'COMMIT',47,'PL/SQL',170,'CALL',189,'MERGE','UNKNOWN') COMMAND_TYPE
, z.MODULE, z.executions execution_count, z.msec_per_exec1 before_time, z.msec_per_exec2 after_time, (z.msec_per_exec2-z.msec_per_exec1) time_diff,
round((1-(z.msec_per_exec1/decode(z.msec_per_exec2,0,.01,z.msec_per_exec2))),2)*100||'%' time_Improvements,
z.lio_per_exec2, (z.lio_per_exec2-z.lio_per_exec1) lio_diff, z.pio_per_exec2, (z.pio_per_exec2-z.pio_per_exec1) pio_diff, y.sql_text
from
( 
select b.sql_id, b.MODULE, sum(b.executions) executions, sum(a.msec_per_exec) msec_per_exec1, sum(b.msec_per_exec) msec_per_exec2,sum(a.lio_per_exec) lio_per_exec1, sum(b.lio_per_exec) lio_per_exec2,
sum(a.pio_per_exec) pio_per_exec1, sum(b.pio_per_exec) pio_per_exec2
from
(select
 sql_id
, sum(q.EXECUTIONS_DELTA) executions
, round(sum(q.ROWS_PROCESSED_DELTA)/greatest(sum(q.executions_delta),1),1) rows_per_exec
, round((sum(q.ELAPSED_TIME_delta)/greatest(sum(q.executions_delta),1)/1000),1) msec_per_exec
, round(sum(q.BUFFER_GETS_delta)/greatest(sum(q.executions_delta),1),1) lio_per_exec
, round(sum(q.DISK_READS_delta)/greatest(sum(q.executions_delta),1),1) pio_per_exec
, round(sum(q.PHYSICAL_READ_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  READ_BLOCKS
, round(sum(q.PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  WRITE_BLOCKS
, round(sum(q.IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) Inter_bytes
, round(sum(q.CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) ss_actual_blocks
, round(sum(q.IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) ss_return_blocks
from dba_hist_sqlstat q, dba_hist_snapshot s
where
parsing_schema_name not in ('SYS','SYSTEM','DBIMGR') 
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&start_time1.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&end_time1.'),'dd-mon-yyyy hh24:mi')
group by
 q.sql_id
order by executions, q.sql_id
) a join
(select
 sql_id
, sum(q.EXECUTIONS_DELTA) executions
, substr(MODULE,1,(decode(instr(module,'@',1),0,21,instr(module,'@',1)))-1) MODULE
, round(sum(q.ROWS_PROCESSED_DELTA)/greatest(sum(q.executions_delta),1),1) rows_per_exec
, round((sum(q.ELAPSED_TIME_delta)/greatest(sum(q.executions_delta),1)/1000),1) msec_per_exec
, round(sum(q.BUFFER_GETS_delta)/greatest(sum(q.executions_delta),1),1) lio_per_exec
, round(sum(q.DISK_READS_delta)/greatest(sum(q.executions_delta),1),1) pio_per_exec
, round(sum(q.PHYSICAL_READ_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  READ_BLOCKS
, round(sum(q.PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  WRITE_BLOCKS
, round(sum(q.IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) Inter_bytes,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks
from dba_hist_sqlstat q, dba_hist_snapshot s
where
parsing_schema_name not in ('SYS','SYSTEM','DBIMGR') 
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&start_time2.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&end_time2.'),'dd-mon-yyyy hh24:mi')
group by
 q.sql_id, MODULE
order by executions, q.sql_id
) b on a.sql_id=b.sql_id
where b.executions>10
group by b.sql_id, b.module
) z join (select sql_id, sql_text, command_type from DBA_HIST_SQLTEXT) y on z.sql_id=y.sql_id
order by time_diff
/

