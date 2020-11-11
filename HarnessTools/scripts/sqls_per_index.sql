  select
                        t.sql_id,t.table1,y.command_type, y.sql_text
				--t.index1,t.OBJECT_OWNER,t.OBJECT_TYPE,t.blocks,t.true_name
                   from
                        (
                        select q.sql_id,p.PLAN_HASH_VALUE,
                        (case object_type when 'TABLE' then p.OBJECT_NAME else (select MAX(TABLE_NAME) from all_indexes where index_name=p.OBJECT_NAME and owner=p.object_owner) END) as "TABLE1",
                        (case object_type when 'TABLE' then 'N/A' else (select MAX(TABLE_NAME) from all_indexes where index_name=p.OBJECT_NAME and owner=p.object_owner) END) as "INDEX1",
                        p.OBJECT_OWNER, p.OBJECT_TYPE,sg.BLOCKS, p.OBJECT_NAME true_name
                        from dba_hist_sql_plan p, DBA_SEGMENTS sg, dba_hist_sqlstat q, dba_hist_snapshot s
                        where sg.owner=p.object_owner and sg.segment_name=p.OBJECT_NAME and OBJECT_OWNER not in ('SYSTEM','SYS','DBIMGR') and p.OBJECT_NAME is not null
                         and s.snap_id = q.snap_id
                         and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE
                         and s.instance_number = q.instance_number
                         and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
                         and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
                         and p.OBJECT_NAME='&index_name'
                        ) t
		join
		    (select sql_id, UPPER(translate(sql_text, chr(10)||chr(11)||chr(13), ' ')) sql_text,  command_type from DBA_HIST_SQLTEXT) y on t.sql_id=y.sql_id
        group by   t.sql_id,t.table1,y.command_type, y.sql_text
        order by 1,4
/
