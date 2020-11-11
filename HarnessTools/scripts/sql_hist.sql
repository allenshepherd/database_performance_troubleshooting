select dash.sql_exec_id,dash.SQL_PLAN_OPERATION||' '||dash.SQL_PLAN_OPTIONS as Operation,dsp.OBJECT_NAME,count(*)
  from dba_hist_active_sess_history dash, dba_hist_sql_plan dsp
  where dash.sql_id='&sql_id'
  and   dash.SQL_PLAN_LINE_ID=dsp.id
  and   dash.sql_id=dsp.sql_id
  and   dash.sql_plan_hash_value=dsp.plan_hash_value
group by dash.sql_exec_id,dash.SQL_PLAN_OPERATION,dash.SQL_PLAN_OPTIONS,dsp.OBJECT_NAME order by dash.sql_exec_id,count(*)
/
