set lines 240 pages 40000 
set feedback off
column sample_end format a13
col NAME for a10 trunc
--col plan_hash_value for a13
col HASH_PLAN for 999999999999
col executions for 9999999999 trunc
col SAMPLE_END for a11 trunc
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT  DESCRIPTION AND USAGE
PROMPT  Below is a query used for a particular SQL_ID that will look across the last_n_days in AWR for time based statistics 
PROMPT     which will include exections plan used, and average ms per execution. Pay attention to plan hash values that may change across different snap_ids
PROMPT     note - LIO=Buffer Gets/Consistent gets
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _________________________________________________________________________________________________________________________________________
select * from (
select to_char(min(s.end_interval_time),'MM/DD@HH24:MI') sample_end , q.plan_hash_value Hash_plan, parsing_schema_name as "NAME", sum(q.EXECUTIONS_DELTA) executions
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),0) msec_per_exec
, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),2) rows_per_exec
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),0) lio_per_exec
, round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0)+
	round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0)  pio_per_exec
, round(sum(OPTIMIZED_PHYSICAL_READS_DELTA)/greatest(sum(executions_delta),1),1)  FC_READS
, round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS
, round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS
--, round(sum(IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) Inter_blks
, round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blks
--, round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blks
, round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blks
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.SQL_ID=trim('&&sql_id.')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi:ss')
and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi:ss')
group by s.snap_id
, q.sql_id
, q.plan_hash_value
, parsing_schema_name 
order by s.snap_id, q.sql_id, q.plan_hash_value
)
where msec_per_exec>=0
/
define sql_id1 = &&sql_id
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT EXTRA DETAIL INFORMATION FOR &&sql_id
set define off
PROMPT To see a hash plan in greater detail, try the below query
PROMPT   - NOTE - Copy hash plan from above
PROMPT -         TO QUERY FROM AWR  -

PROMPT -              select * from table(dbms_Xplan.display_awr('&sql_id1.',plan_hash_value=> &COPY_PLAN_FROM_ABOVE ,FORMAT=>'ADVANCED'));
PROMPT   - 

PROMPT -         TO QUERY FROM MEMORY (CURSOR) - (Note, cursor has information regarding predicates and column assumptions)
PROMPT -              select * from table(dbms_Xplan.display_cursor('&sql_id1.',FORMAT=>'ADVANCED'));
PROMPT
PROMPT -         TO SEE TABLE Statistics, run the below:
PROMPT -             INDEX - @index_info  - Helpful index information
PROMPT -             TABLE - @hstats      - helpful table information (created by hotsos)
set define on
PROMPT _________________________________________________________________________________________________________________________________________
set feedback on

undefine sql_id
undef sql_id
