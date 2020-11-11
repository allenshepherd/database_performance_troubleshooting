set lines 220 pages 50000

PROMPT _____________________________________________________________________________
PROMPT  List of tables having unique SQL IDs along with the number of executions
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _____________________________________________________________________________


select table_count.OBJECT_OWNER||'.'||table_count.table1 TABLE_NAME, count(distinct(table_count.sql_id)) Distinct_number_of_sql_ids, sum(sql_count.executions) number_of_executions from
		(   select 
			t.sql_id,t.table1,t.OBJECT_OWNER,t.OBJECT_TYPE,t.blocks,t.true_name
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
                        where t.object_type='TABLE'
			group by t.sql_id, t.table1, t.OBJECT_OWNER, t.OBJECT_TYPE,t.blocks, t.true_name order by 2
		) table_count join 
		(
		select
		 sql_id
		, count(q.sql_id) frequency_over_snaps
		, sum(q.EXECUTIONS_DELTA) executions
		, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec
		, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec
		, parsing_schema_name as "NAME"
		, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec
		, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) pio_per_exec
		, round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  READ_BLOCKS
		, round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  WRITE_BLOCKS
		, round(sum(IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) Inter_bytes
		, round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) ss_actual_blocks
		, round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1) ss_return_blocks
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
		, parsing_schema_name
		--order by q.sql_id, sample_end
		order by executions, q.sql_id
		) sql_count on sql_count.sql_id=table_count.sql_id
where table_count.object_type='TABLE'
group by table_count.table1,OBJECT_OWNER
order by 3
/

PROMPT _________________________________________________________________________________________________________________________________________
PROMPT EXTRA DETAIL INFORMATION
PROMPT           TO SEE A TABLE'S SQL_IDs,run the below query
PROMPT -              - @table_sql_ids     
PROMPT
PROMPT           TO SEE SQL_IDs having access to multiple tables, ,run the below query
PROMPT -              - @list_of_sql_id_sqls
PROMPT
PROMPT _________________________________________________________________________________________________________________________________________
set define on
set feedback on

