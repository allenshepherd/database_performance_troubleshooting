with
    flipper
    as
        (  select sql_id,
                  substr (module, 1, 10) module,
                  count (distinct plan_hash_value) plan_flip
             from (select sq.sql_id, plan_hash_value, sq.module
                     from dba_hist_sqlstat sq, dba_hist_snapshot sp
                    where     sp.begin_interval_time > sysdate - 7
                          and executions_delta <> 0
                          and sp.snap_id = sq.snap_id)
         group by sql_id, module
           having count (distinct plan_hash_value) > 1),
    history
    as
        (select sp.begin_interval_time,
                sq.sql_id,
                plan_hash_value,
                round (
                      buffer_gets_delta
                    / decode (executions_delta, 0, 1, executions_delta),
                    2)
                    buffer_gets,
                round (
                      disk_reads_delta
                    / decode (executions_delta, 0, 1, executions_delta),
                    2)
                    reads,
                round (
                      elapsed_time_delta
                    / decode (executions_delta, 0, 1, executions_delta)
                    / 1000000,
                    2)
                    elapsed_time,
                executions_delta,
                parsing_schema_name
           from dba_hist_sqlstat sq, dba_hist_snapshot sp
          where     sp.begin_interval_time > sysdate - 7
                and executions_delta <> 0
                and sp.snap_id = sq.snap_id)
  select f.module,
         f.sql_id,
         h.plan_hash_value,
         sum (h.executions_delta)
             executions,
         min (h.elapsed_time)
             min_exec_time,
         max (h.elapsed_time)
             max_exec_time,
		 round (avg (h.elapsed_time), 2)
             avg_exec_time,
         to_char (min (h.begin_interval_time), 'DD-MM-YY HH24:MI:SS')
             start_time,
         to_char (max (h.begin_interval_time), 'DD-MM-YY HH24:MI:SS')
             end_time,
         (select sql_text
            from dba_hist_sqltext
           where sql_id = f.sql_id)
             full_query
    from flipper f, history h
   where f.sql_id = h.sql_id
group by f.module, f.sql_id, h.plan_hash_value
order by 2,7;