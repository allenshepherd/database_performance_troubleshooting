col SQL_TEXT for a120 wrap
select x.sql_id, y.executions, x.command_type, x.sql_text from
(select
distinct(t.sql_id),
decode(y.command_type,1,'CREATE TABLE',2,'INSERT',3,'SELECT',6,'UPDATE',7,'DELETE',26,'LOCK TABLE',44,'COMMIT',47,'PL/SQL',170,'CALL',189,'MERGE','UNKNOWN') COMMAND_TYPE, 
DBMS_LOB.substr(y.sql_text,4000) sql_text
 from
                        (
                        select q.sql_id,(case object_type when 'TABLE' then p.OBJECT_NAME
                                                          when 'INDEX' then  (select TABLE_NAME from all_indexes where index_name=p.OBJECT_NAME and owner=p.object_owner)
                                                          when 'INDEX (UNIQUE)' then  (select TABLE_NAME from all_indexes where index_name=p.OBJECT_NAME and owner=p.object_owner)
                                                          ELSE object_name END) as "TABLE1",
                                p.OBJECT_OWNER, nvl(p.OBJECT_TYPE,'TABLE') object_type ,sg.BLOCKS, p.OBJECT_NAME true_name
                        from dba_hist_sql_plan p, DBA_SEGMENTS sg, dba_hist_sqlstat q, dba_hist_snapshot s
                        where sg.owner=p.object_owner and sg.segment_name=p.OBJECT_NAME and OBJECT_OWNER not in ('SYSTEM','SYS','DBIMGR') and p.OBJECT_NAME is not null
                         and s.snap_id = q.snap_id
                         and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE
                         and s.instance_number = q.instance_number
                         and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
                         and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
                        ) t
join (select sql_id, sql_text, command_type from DBA_HIST_SQLTEXT --where (upper(sql_text) like upper('% &&table_name %')) or (upper(sql_text) like upper('%.&&table_name %')) 
) y on t.sql_id=y.sql_id
where t.OBJECT_OWNER='&table_owner' and t.object_type='TABLE' and t.table1='&&table_name'
) x join (
                select
                 sql_id
                , sum(q.EXECUTIONS_DELTA) executions
                from dba_hist_sqlstat q, dba_hist_snapshot s
                where
                parsing_schema_name not in ('SYS','SYSTEM','DBIMGR')
                and s.snap_id = q.snap_id
                and s.dbid = q.dbid
                and s.instance_number = q.instance_number
                and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
                and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
                group by
                 q.sql_id
) y on x.sql_id = y.sql_id
/
