PROMPT _____________________________________________________________________________

set lines 220 pages 900
col sql_text for a50 trunc
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        (
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)
        )*(sum(t.EXECUTIONS_DELTA)) total_block_requests,
        t.SQL_ID, v.sql_text
    from   dba_hist_sqlstat t, dba_hist_snapshot s, v$sql v
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.sql_id=+v.sql_id
    and    t.instance_number = s.instance_number
--    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id, v.sql_text
    order by total_block_requests 
)
WHERE ROWNUM <= 200 and executions > 0
/

PROMPT _____________________________________________________________________________

PROMPT _____________________________________________________________________________
