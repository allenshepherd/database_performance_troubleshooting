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
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
        (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s, dba_segments o, dba_hist_sql_plan p
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.sql_id=p.sql_id
    and    t.instance_number = s.instance_number
    and    t.instance_number = (select instance_number from v$instance)
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
        and     t.dbid = s.dbid
        and     t.sql_id=p.sql_id
        and     t.instance_number = s.instance_number
        and     t.instance_number = (select instance_number from v$instance)
        and   s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
        and   s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
        and   p.object_owner = o.owner
        and   p.object_name = o.segment_name
        and   o.blocks > 1000
        and   p.operation like '%TABLE ACCESS%'
        and   p.options like '%FULL%'
        and   p.sql_id = t.sql_id
    group  by t.sql_id
    order by 2 desc
)
WHERE ROWNUM <= 10 and executions > 10
/

