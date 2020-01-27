select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        sum(BUFFER_GETS_delta)*(sum(t.EXECUTIONS_DELTA))  total_lio,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        ( (round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1))*(sum(t.EXECUTIONS_DELTA))) total_lio_block_requests,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
--  and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    --order by total_lio_block_requests desc
    order by total_lio desc
)
WHERE ROWNUM <= 40 and executions >= 0 and LIO_PER_EXEC >1000
/
