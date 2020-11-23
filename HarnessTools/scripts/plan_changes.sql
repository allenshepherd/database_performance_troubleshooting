PROMPT _____________________________________________________________________________

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
          where     sp.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
                and sp.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
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


select sql_id, plan, executions from
(select q.SQL_ID,count(distinct(q.PLAN_HASH_VALUE)) plan,  sum(q.EXECUTIONS_DELTA) executions
 from dba_hist_sql_plan p, DBA_SEGMENTS sg, dba_hist_sqlstat q, dba_hist_snapshot s
                        where sg.owner=p.object_owner and sg.segment_name=p.OBJECT_NAME and p.OBJECT_NAME is not null
                         and s.snap_id = q.snap_id
                         and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE
                         and s.instance_number = q.instance_number
                         and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
                         and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
group by q.sql_id order by 1) t
where t.executions >1 and t.plan>1 order by 2
/


PROMPT _____________________________________________________________________________

PROMPT _____________________________________________________________________________