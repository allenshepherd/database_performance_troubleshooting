col created for a30 trunc
set lines 220
select
  NVL(case when g.sql_id is not null then g.sql_id else s.sql_id end, 'AGED OUT OF AWR') sql_id, b.sql_handle,
  NVL(to_char(g.PLAN_HASH_VALUE),'NOT IN CURSOR CACHE') HASH_PLAN_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED, CREATED, ORIGIN
  FROM DBA_SQL_PLAN_BASELINES b
    left join DBA_HIST_SQLSTAT s on s.FORCE_MATCHING_SIGNATURE=b.SIGNATURE
    left join gv$sql g on g.EXACT_MATCHING_SIGNATURE=b.SIGNATURE --AND b.PLAN_NAME=g.SQL_PLAN_BASELINE
  group by case when g.sql_id is not null then g.sql_id else s.sql_id end, sql_handle, g.PLAN_HASH_VALUE, PLAN_NAME, ENABLED, ACCEPTED, FIXED,CREATED,ORIGIN
  order by 1,3
/
