set lines 230
set feedback off
col CPUP HEADING  "%CPU"
col CPUP for a4 trunc
col IOP HEADING "%IO"
col IOP for  a4 trunc

--DEFINE inst='1'
select 'Running below stats for instance number '||&&inst||'. For different instance, try @awr_top10 <instance_number>' as Instance_number from dual;

PROMPT _____________________________________________________________________________
PROMPT  SQL ordered by Elapsed Time (standard query from AWR)
PROMPT   %CPU  CPU Time as a percentage of Elapsed Time
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _____________________________________________________________________________

WITH aa AS
(SELECT output, ROWNUM r
FROM table(DBMS_WORKLOAD_REPOSITORY.awr_report_text ((select dbid from v$database), (nvl(&&inst,(select instance_number from v$instance))),
(select min(snap_id) from dba_hist_snapshot s where instance_number=1 and  s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')),
(select max(snap_id) from dba_hist_snapshot s where instance_number=1 and  s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))) ))
SELECT output top_Foreground_waits
FROM aa, (SELECT r FROM aa
WHERE output LIKE 'Top 10 Foreground Events%') bb
WHERE aa.r BETWEEN bb.r AND bb.r + 14
order by bb.r
/

PROMPT _____________________________________________________________________________

PROMPT NOTE - SS stands for smart scans
PROMPT ___________________SQL ordered by Elapsed Time_______________________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
	  (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
	  (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
	)*86400) ),2)*100)||'%' CPUP,
         (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,        
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    order by elapsed_time desc
)
WHERE ROWNUM <= 10 and executions > 10
/

PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT __________________SQL ordered by CPU Time____________________________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
         (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    order by 8 desc
)
WHERE ROWNUM <= 10 and executions > 10
/
PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT __________________________SQL ordered by IO Time______________________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
         (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    order by 9 desc
)
WHERE ROWNUM <= 10 and executions > 10
/
PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT _____________SQL ordered by Logical IO BLOCKS PER EXEC_______________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        ( (round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1))*(sum(t.EXECUTIONS_DELTA))) total_lio_block_requests,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
--  and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    order by total_lio_block_requests desc
)
WHERE ROWNUM <= 10 and executions > 0
/

PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT _____________SQL ordered by PHYSICAL IO BLOCKS PER EXEC______________________
select * from (
    select 
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        (
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)
	)*(sum(t.EXECUTIONS_DELTA)) total_pio_block_requests,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
--    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    group  by t.sql_id
    order by total_pio_block_requests desc
)
WHERE ROWNUM <= 10 and executions >= 0
/


PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT __________________SQL ordered by FULL TABLE SCANS____________________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
        (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s, dba_segments o, dba_hist_sql_plan p
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.sql_id=p.sql_id
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    and   p.object_owner = o.owner
    and   p.object_name = o.segment_name
    and   o.blocks > 1000
    and   p.operation like '%TABLE ACCESS%'
    and   p.options = 'STORAGE FULL'
    and   t.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','SYSAUX')
    and   p.PLAN_HASH_VALUE=t.PLAN_HASH_VALUE
    and   p.sql_id = t.sql_id
    group  by t.sql_id 
    order by 2 desc
)
WHERE ROWNUM <= 10 
/

PROMPT _______________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT __________________SQL ordered by # OF ROWS RETURNED____________________________
select * from (
    select
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec,
        --round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
        (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s, dba_segments o, dba_hist_sql_plan p
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.sql_id=p.sql_id
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
	and	t.dbid = s.dbid
	and	t.sql_id=p.sql_id
	and	t.instance_number = s.instance_number
	and	t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
	and   s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
	and   s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
	and   p.object_owner = o.owner
	and   p.object_name = o.segment_name
	and   o.blocks > 100
	and (( p.operation like '%TABLE ACCESS%' and  p.options like '%STORAGE FULL%') or ( p.operation like '%INDEX ACCESS%' and  p.options like '%STORAGE FULL%') )
	and   p.sql_id = t.sql_id
    group  by t.sql_id 
    order by 8 desc
)
WHERE ROWNUM <= 10 and executions > 10
/

PROMPT _____________________________________________________________________________
PROMPT NOTE - SS stands for smart scans
PROMPT     NOTE - below query is for any sql that has run more than 10 times total...
PROMPT               If No results, then any query run more than 10 times was not eligible for smart scans.
PROMPT _____________SQL ordered by Eligible Smart Scan Blocks (Exadata Only)______________________
select * from (
    select  
        round((sum(t.ELAPSED_TIME_delta)/1000000),1) elapsed_time,
        sum(t.EXECUTIONS_DELTA) executions,
        round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_per_exec,
        round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec,
        round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)+ 
        round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,1)  pio_per_exec,
        round(sum(PHYSICAL_READ_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  READ_REQS,
        round(sum(PHYSICAL_WRITE_REQUESTS_DELTA)/greatest(sum(executions_delta),1),1)  WRITE_REQS,
        round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_elig_blocks,
        round(sum(CELL_UNCOMPRESSED_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_actual_blocks,
        round(sum(IO_OFFLOAD_RETURN_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0) ss_return_blocks,
        (round( ((sum(t.ELAPSED_TIME_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' CPUP,
        (round(((sum(t.iowait_delta)/1000000)/
          ((
          (sysdate - to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')) -
          (sysdate - to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))
        )*86400) ),2)*100)||'%' IOP,
        t.SQL_ID
    from   dba_hist_sqlstat t, dba_hist_snapshot s
    where  t.snap_id = s.snap_id
    and    t.dbid = s.dbid
    and    t.instance_number = s.instance_number
    and    t.instance_number = (nvl(&&inst,(select instance_number from v$instance)))
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    and t.EXECUTIONS_DELTA > 0
    and IO_OFFLOAD_ELIG_BYTES_DELTA >0
    group  by t.sql_id
    order by 8,2 desc
)
WHERE ROWNUM <= 10 and executions > 10
/

PROMPT _____________________________________________________________________________
PROMPT  for detailed information regarding a particular sql, run below query
PROMPT     @get_time_stats_sql_id.sql
PROMPT     @get_wait_stats_sql_id.sql
PROMPT _____________________________________________________________________________

--undefine start_time
--undefine end_time
UNDEFINE inst
set feedback on
