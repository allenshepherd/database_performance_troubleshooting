set lines 240 pages 50000 feedback on timing on long 2000 serveroutput on
col module for a20 trunc
col sql_text for a40 wrap
set lines 240 pages 50000
col COMMAND_TYPE for a13 trunc
col TIME_IMPROVEMENTS for a13
 alter session set nls_date_format = 'mm/dd/yyyy hh24:mi:ss'; 
PROMPT _____________________________________________________________________________
PROMPT   Index statistics surrounding sql_ids with a hash plans using the index
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _____________________________________________________________________________

PROMPT  __________________________________________________________________________________________________________________________________________________________
PROMPT
PROMPT INDEX INFORMATION
PROMPT  __________________________________________________________________________________________________________________________________________________________

declare
tmpvar varchar2(64);
v_numirows number;
v_indlevel number;
v_numlblks number;
v_numdist number;
v_avglblk number;
v_avgdblk number;
v_clstfct number;
v_numrows number;
v_numblks number;
v_cachedblk number;
v_cachehit number;
v_status varchar2(256);
v_dstart date;
v_pname varchar2(256);
v_pvalue number;
begin
	    dbms_stats.GET_SYSTEM_STATS(status => v_status, dstart=> v_dstart, pname=> v_pname, pvalue => v_pvalue);
            dbms_stats.get_index_stats (ownname=> '&&index_owner', indname => '&&index_name', numrows => v_numirows, numlblks => v_numlblks,numdist => v_numdist, avglblk => v_avglblk,
					 avgdblk => v_avgdblk,clstfct => v_clstfct, indlevel => v_indlevel);
for row in ( select a.index_name, a.degree, a.PARTITIONED, a.visibility, a.table_name, a.ini_trans row_ini_trans, a.index_type, a.last_analyzed, a.PCT_FREE index_pct_free, a.STATUS, t.TABLESPACE_NAME, t.NUM_ROWS table_rows 
		, t.BLOCKS table_blocks, t.ini_trans table_ini_trans,t.LAST_ANALYZED table_analyzed,t.PARTITIONED table_partition,t.PCT_FREE table_pct_free,trim(t.degree) table_degree 
		from all_indexes a join all_tables t on a.table_name=t.table_name and a.table_owner=t.owner where a.index_name = UPPER('&&index_name') and a.owner = UPPER('&&index_owner')
	   ) loop 
            dbms_output.put_line ('   Index name       : ' || row.index_name||'			: Table name             : '|| row.table_name) ;
            dbms_output.put_line ('   Index Tablespace : ' || row.tablespace_name||'				: Table Tablespace       : '|| row.tablespace_name) ;
            dbms_output.put_line ('   Index init trans : ' || row.row_ini_trans||'					: Table ini trans        : '|| row.table_ini_trans) ;
            dbms_output.put_line ('   Index pct_free   : ' || row.index_pct_free||'					: Table pct_free         : '|| row.table_pct_free) ;
            dbms_output.put_line ('   Index analyzed   : ' || row.last_analyzed||'			: Table analyzed         : '|| row.table_analyzed) ;
            dbms_output.put_line ('   Index Degree(DOP): ' || row.degree||'					: Table degree (DOP)     : '|| row.table_degree) ;
            dbms_output.put_line ('   Partitioned      : ' || row.partitioned||'					: Table partitioned      : '|| row.table_partition) ;
            dbms_output.put_line ('   Rows             : ' || v_numirows||'				: Table Rows             : '|| row.table_rows) ;
            dbms_output.put_line ('Leaf Blocks      : ' || v_numlblks||'				: Table Blocks           : '|| row.table_blocks) ;
            dbms_output.put_line ('-----------');

            dbms_output.put_line ('Index type       : ' || row.index_type) ;
            dbms_output.put_line ('Visible          : ' || row.visibility) ;
            dbms_output.put_line ('Levels           : ' || v_indlevel ) ;
            dbms_output.put_line ('Distinct Keys    : ' || v_numdist) ;
            dbms_output.put_line ('Avg Leaf Blk/Key : ' || v_avglblk ) ;
            dbms_output.put_line ('Avg Data Blk/Key : ' || v_avgdblk ) ;
            dbms_output.put_line ('Clust. Factor    : ' || v_clstfct ) ;

            dbms_output.put_line ('System Status    : ' || v_status);
            dbms_output.put_line ('System Status    : ' || v_start);
            dbms_output.put_line ('System Status    : ' || v_pname);
            dbms_output.put_line ('System Status    : ' ||v_pvalue);
            dbms_output.put_line ('---------------------------------------------------------------------------------------------------------------------');
	end loop;
	
end;
/
PROMPT  __________________________________________________________________________________________________________________________________________________________

PROMPT  __________________________________________________________________________________________________________________________________________________________
 
select z.sql_id,
decode(y.command_type,1,'CREATE TABLE',2,'INSERT',3,'SELECT',6,'UPDATE',7,'DELETE',26,'LOCK TABLE',44,'COMMIT',47,'PL/SQL',170,'CALL',189,'MERGE','UNKNOWN') COMMAND_TYPE
, z.MODULE, z.executions execution_count, z.msec_per_exec1 before_time, z.msec_per_exec2 after_time, (z.msec_per_exec2-z.msec_per_exec1) time_diff,
round((1-(z.msec_per_exec1/decode(z.msec_per_exec2,0,.01,z.msec_per_exec2))),2)*100||'%' time_Improvements,
z.lio_per_exec2, (z.lio_per_exec2-z.lio_per_exec1) lio_diff, z.pio_per_exec2, (z.pio_per_exec2-z.pio_per_exec1) pio_diff, y.sql_text
from
(
select b.sql_id, b.MODULE, sum(b.executions) executions, sum(a.msec_per_exec) msec_per_exec1, sum(b.msec_per_exec) msec_per_exec2,sum(a.lio_per_exec) lio_per_exec1, sum(b.lio_per_exec) lio_per_exec2,
sum(a.pio_per_exec) pio_per_exec1, sum(b.pio_per_exec) pio_per_exec2
from
(select
 sql_id
, sum(q.EXECUTIONS_DELTA) executions
, round(sum(q.ROWS_PROCESSED_DELTA)/greatest(sum(q.executions_delta),1),1) rows_per_exec
, round((sum(q.ELAPSED_TIME_delta)/greatest(sum(q.executions_delta),1)/1000),1) msec_per_exec
, round(sum(q.BUFFER_GETS_delta)/greatest(sum(q.executions_delta),1),1) lio_per_exec
, round(sum(q.DISK_READS_delta)/greatest(sum(q.executions_delta),1),1) pio_per_exec
, round(sum(q.PHYSICAL_READ_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  READ_BLOCKS
, round(sum(q.PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  WRITE_BLOCKS
, round(sum(q.IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) Inter_bytes
, round(sum(q.CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) ss_actual_blocks
, round(sum(q.IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) ss_return_blocks
from dba_hist_sqlstat q, dba_hist_snapshot s
where
parsing_schema_name not in ('SYS','SYSTEM','DBIMGR')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&before_start_time.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&before_end_time.'),'dd-mon-yyyy hh24:mi')
and sql_id in (
  select q.sql_id from dba_hist_sql_plan p,  dba_hist_sqlstat q, dba_hist_snapshot s
  where OBJECT_OWNER not in ('SYSTEM','SYS','DBIMGR') and p.OBJECT_NAME is not null
  and s.snap_id = q.snap_id
  and s.dbid = q.dbid and p.PLAN_HASH_VALUE= q.PLAN_HASH_VALUE
  and s.instance_number = q.instance_number
  and s.end_interval_time >= to_date(trim('&&after_start_time.'),'dd-mon-yyyy hh24:mi')
  and s.begin_interval_time <= to_date(trim('&&after_end_time.'),'dd-mon-yyyy hh24:mi')
  and p.OBJECT_NAME=upper('&&index_name') and p.OBJECT_OWNER=upper('&&index_owner')
  group by q.sql_id 
)
group by
 q.sql_id
order by executions, q.sql_id
) a join
(select
 sql_id
, sum(q.EXECUTIONS_DELTA) executions
, substr(MODULE,1,(decode(instr(module,'@',1),0,21,instr(module,'@',1)))-1) MODULE
, round(sum(q.ROWS_PROCESSED_DELTA)/greatest(sum(q.executions_delta),1),1) rows_per_exec
, round((sum(q.ELAPSED_TIME_delta)/greatest(sum(q.executions_delta),1)/1000),1) msec_per_exec
, round(sum(q.BUFFER_GETS_delta)/greatest(sum(q.executions_delta),1),1) lio_per_exec
, round(sum(q.DISK_READS_delta)/greatest(sum(q.executions_delta),1),1) pio_per_exec
, round(sum(q.PHYSICAL_READ_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  READ_BLOCKS
, round(sum(q.PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1)  WRITE_BLOCKS
, round(sum(q.IO_INTERCONNECT_BYTES_DELTA)/greatest(sum(q.executions_delta),1)/8192,1) Inter_bytes,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks
from dba_hist_sqlstat q, dba_hist_snapshot s
where
parsing_schema_name not in ('SYS','SYSTEM','DBIMGR')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&after_start_time.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&after_end_time.'),'dd-mon-yyyy hh24:mi')
group by
 q.sql_id, MODULE
order by executions, q.sql_id
) b on a.sql_id=b.sql_id
group by b.sql_id, b.module
) z join (select sql_id, sql_text, command_type from DBA_HIST_SQLTEXT) y on z.sql_id=y.sql_id
order by time_diff
/


--set define off
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT EXTRA DETAIL INFORMATION
PROMPT           TO SEE A SQL_ID's has plans across the time frame (&&before_start_time, &&after_end_time),run the below query
PROMPT -              - @get_time_stats_sql_id
PROMPT _________________________________________________________________________________________________________________________________________
set define on
define start_time='&&before_start_time'
define end_time='&&after_end_time'
undefin sql_id

