with hand1 as (select distinct(b.sql_handle) from DBA_HIST_SQLSTAT a, DBA_SQL_PLAN_BASELINES b where a.sql_id='&sql_id' and a.FORCE_MATCHING_SIGNATURE=b.signature)
        select plan_table_output from hand1, table(dbms_xplan.display_sql_plan_baseline(sql_handle =>hand1.sql_handle, format=>'typical'))
/
