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
