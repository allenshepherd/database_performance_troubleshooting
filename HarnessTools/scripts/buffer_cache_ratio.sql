select BEGIN_TIME,END_TIME,INTSIZE,MINVAL,MAXVAL,AVERAGE from DBA_HIST_SYSMETRIC_SUMMARY where begin_time >sysdate-7 and metric_id=2000 order by begin_time;
--select metric_id,METRIC_NAME from DBA_HIST_METRIC_NAME where upper(metric_name) like '%CACHE%' order by 1;
