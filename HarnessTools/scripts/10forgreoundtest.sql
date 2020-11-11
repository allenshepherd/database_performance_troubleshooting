

--dba_hist_sys_time_model
select stat_name, sum(value) from dba_hist_sys_time_model e, dba_hist_snapshot s 
    where  e.snap_id = s.snap_id
    and    e.dbid = s.dbid
    and    e.instance_number = s.instance_number
    and    e.instance_number = (select instance_number from v$instance)
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
group by stat_name

select * from (
select e.EVENT_NAME ,e.WAIT_CLASS, sum(e.total_waits) from dba_hist_system_event e,  dba_hist_snapshot s  
    where  e.snap_id = s.snap_id
    and    e.dbid = s.dbid
    and    e.instance_number = s.instance_number
    and    e.instance_number = (select instance_number from v$instance)
    and s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')
    and s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss')
    and e.WAIT_CLASS <>'Idle' 
    and event_name not like 'SQL*Net%'
    and event_name not in ('pmon timer','rdbms ipc message','dispatcher timer','smon timer')
group by e.EVENT_NAME,e.WAIT_CLASS order by 3 desc )
where rownum <=10


WITH aa AS
(SELECT output, ROWNUM r
FROM table(DBMS_WORKLOAD_REPOSITORY.awr_report_text ((select dbid from v$database), 1, 
(select min(snap_id) from dba_hist_snapshot s where instance_number=1 and  s.end_interval_time >= to_date(trim('&&start_time'),'dd-mon-yyyy hh24:mi:ss')),
(select max(snap_id) from dba_hist_snapshot s where instance_number=1 and  s.begin_interval_time <= to_date(trim('&&end_time'),'dd-mon-yyyy hh24:mi:ss'))) ))
SELECT output top_five
FROM aa, (SELECT r FROM aa
WHERE output LIKE 'Top 10 Foreground Events%') bb
WHERE aa.r BETWEEN bb.r AND bb.r + 14
order by bb.r
/
