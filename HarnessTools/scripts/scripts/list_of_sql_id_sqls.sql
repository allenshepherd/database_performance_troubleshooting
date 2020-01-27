set lines 220 pages 50000
set feedback off
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT  DESCRIPTION AND USAGE
PROMPT  This sql will provide a list of tables and indexes used per sql_id across the last_n_days in AWR
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _________________________________________________________________________________________________________________________________________

select sql_count.sql_id,table_count.PLAN_HASH_VALUE, sql_count.executions, count(distinct(table_count.table1)) total_table_count, count(distinct(table_count.index1)) index_count, sql_count.msec_per_exec, sql_count.lio_per_exec,sql_count.pio_per_exec, sql_count.parsing_schema_name from  
		(
		select
		 sql_id
		, count(q.sql_id) frequency_over_snaps
		, sum(q.EXECUTIONS_DELTA) executions
		, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec
		, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec
		, parsing_schema_name
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
		) sql_count  join 
                (   select
                        t.sql_id,t.table1,t.index1,t.PLAN_HASH_VALUE,t.OBJECT_OWNER,t.OBJECT_TYPE,t.blocks,t.true_name
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
                        ) t where t.INDEX1 <> 'N/A'
                        group by t.sql_id, t.table1,t.index1,t.PLAN_HASH_VALUE, t.OBJECT_OWNER, t.OBJECT_TYPE,t.blocks, t.true_name order by 2
                ) table_count on sql_count.sql_id=table_count.sql_id
where sql_count.executions>500 
group by sql_count.sql_id, sql_count.executions,sql_count.msec_per_exec, sql_count.lio_per_exec,sql_count.pio_per_exec,table_count.PLAN_HASH_VALUE,sql_count.parsing_schema_name
order by 2
/
PROMPT _________________________________________________________________________________________________________________________________________
set define off
PROMPT To see a hash plan in greater detail, try the below query
PROMPT   - NOTE - Copy hash plan from above

PROMPT -         TO QUERY FROM MEMORY (CURSOR) - (Note, cursor has information regarding predicates and column assumptions)
PROMPT -              select * from table(dbms_Xplan.display_cursor('&sql_id1.',FORMAT=>'ADVANCED'));
PROMPT
PROMPT -         TO SEE TABLE Statistics, run the below:
PROMPT -             INDEX - @index_info  - Helpful index information
PROMPT -             TABLE - @hstats      - helpful table information (created by hotsos)
PROMPT _________________________________________________________________________________________________________________________________________
set define on
set feedback on
undefine sql_id
