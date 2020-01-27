set lines 240 pages 40000 
set feedback off
column sample_end format a13
col NAME for a12 trunc
--col plan_hash_value for a13
col PLAN_HASH_VALUE for 999999999999999
col executions for 9999999999 trunc
col SAMPLE_END for a11 trunc
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT  DESCRIPTION AND USAGE
PROMPT  Below is a query used for a particular SQL_ID that will look across the last_n_days in AWR for wait events that may have happen during that time
PROMPT     note - LIO=Buffer Gets/Consistent gets
PROMPT     DATE FORMAT EXAMPLES
PROMPT           01-JAN-2017
PROMPT           01-JAN-2017 13:48
PROMPT _________________________________________________________________________________________________________________________________________
select to_char(min(s.end_interval_time),'MM/DD@HH24:MI') sample_end , q.plan_hash_value, parsing_schema_name as "NAME", sum(q.EXECUTIONS_DELTA) executions
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),0) msec_per_exec
, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),2) rows_per_exec
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),0) lio_per_exec
, round(sum(PHYSICAL_READ_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0)+
	round(sum(PHYSICAL_WRITE_BYTES_DELTA)/greatest(sum(executions_delta),1)/8192,0)  pio_per_exec
, round(sum(TEMP_SPACE_ALLOCATED)/greatest(sum(executions_delta),1)/8192,0)  temp_blks
, round(sum(PGA_ALLOCATED)/greatest(sum(executions_delta),1)/8192,0)  pga_blks
, s.snap_id
from dba_hist_sqlstat q, dba_hist_snapshot s, dba_hist_active_sess_history t
where q.SQL_ID=trim('&&sql_id.')
and s.snap_id = q.snap_id
and t.snap_id=s.snap_id
and t.instance_number=s.instance_number
and t.dbid = s.dbid
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi')
group by s.snap_id, s.instance_number
, q.sql_id
, q.plan_hash_value
, parsing_schema_name 
order by s.snap_id, q.sql_id, q.plan_hash_value
/
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT -         BE PATIENT: NEXT QUERY WILL TAKE A FEW MINS FOR LARGE TIME PERIODS.
PROMPT -                   - THIS WILL GIIVE YOU WAIT EVENTS FOR SQL_ID PER TIME PERIOD
PROMPT _________________________________________________________________________________________________________________________________________

select to_char(min(s.end_interval_time),'MM/DD@HH24:MI') sample_end, a.event,sum(a.time_waited) event_count,a.snap_id
--,NVL(round((sum(TEMP_SPACE_ALLOCATED)/8192),0),0)  temp_blks
--,NVL(round((sum(PGA_ALLOCATED)/8192),0),0)  pga_blks
from dba_hist_active_sess_history a, dba_hist_snapshot s 
      where a.sql_id = '&&sql_id' 
              and s.snap_id = a.snap_id
              and time_waited>0
              and a.snap_id < (select min(s.snap_id) from dba_hist_snapshot s where s.begin_interval_time >= to_date(trim('&&end_time.'),'dd-mon-yyyy hh24:mi'))
              and a.snap_id >= (select min(s.snap_id) from dba_hist_snapshot s where s.end_interval_time >= to_date(trim('&&start_time.'),'dd-mon-yyyy hh24:mi'))
      group by a.event,a.snap_id order by a.snap_id,event_count desc
/
define sql_id1 = &&sql_id
PROMPT _________________________________________________________________________________________________________________________________________
PROMPT EXTRA DETAIL INFORMATION FOR &&sql_id
set define off
PROMPT To see a hash plan in greater detail, try the below query
PROMPT   - NOTE - Copy hash plan from above
PROMPT -         TO QUERY FROM AWR  -

PROMPT -              select * from table(dbms_Xplan.display_awr('&sql_id1.',plan_hash_value=> &COPY_PLAN_FROM_ABOVE ,FORMAT=>'ADVANCED'));
PROMPT   - 

PROMPT -         TO QUERY FROM MEMORY (CURSOR) - (Note, cursor has information regarding predicates and column assumptions)
PROMPT -              select * from table(dbms_Xplan.display_cursor('&sql_id1.',FORMAT=>'ADVANCED'));
PROMPT
PROMPT -         TO SEE TABLE Statistics, run the below:
PROMPT -             INDEX - @index_info  - Helpful index information
PROMPT -             TABLE - @hstats      - helpful table information (created by hotsos)
PROMPT _________________________________________________________________________________________________________________________________________
set define on
set feedback on
--undefine sql_id
