

select sql_id, plan, executions from
(select q.SQL_ID,count(distinct(q.PLAN_HASH_VALUE)) plan,  sum(q.EXECUTIONS_DELTA) executions
 from dba_hist_sql_plan p, DBA_SEGMENTS sg, dba_hist_sqlstat q, dba_hist_snapshot s
                        where sg.owner=p.object_owner and sg.segment_name=p.OBJECT_NAME and OBJECT_OWNER not in ('SYSTEM','SYS','DBIMGR') and p.OBJECT_NAME is not null
                         and s.snap_id = q.snap_id
                         and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE
                         and s.instance_number = q.instance_number
                         and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
                         and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
group by q.sql_id order by 1) t
where t.executions >10000000 and t.plan>1 order by 2
/

