set lines 230
set feedback off
col CPUP HEADING  "%CPU"
col CPUP for a4 trunc
col IOP HEADING "%IO"
col IOP for  a4 trunc

--DEFINE inst='1'
select 'Running below stats for instance number '||&&inst||'. For different instance, try @awr_top10 <instance_number>' as Instance_number from dual;

PROMPT _____________________________________________________________________________
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
PROMPT _____________________________________________________________________________

--undefine start_time
--undefine end_time
UNDEFINE inst
set feedback on
