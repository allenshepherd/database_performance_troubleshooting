col ERR_TIMESTAMP for a15 trunc
col message_TEXT for a150 wrap
col CNT for a5 trunc
--select substr(MESSAGE_TEXT, 1, 150) message_text,to_char(cast(ORIGINATING_TIMESTAMP as DATE), 'YYYY-MM-DD') err_timestamp,  count(*) cnt
--from V$DIAG_ALERT_EXT
--where /* (upper(MESSAGE_TEXT) like '%ORA-%' or upper(MESSAGE_TEXT) like '%ERROR%')and*/ cast(ORIGINATING_TIMESTAMP as DATE) > sysdate - 20                        
--group by substr(MESSAGE_TEXT, 1, 150), to_char(cast(ORIGINATING_TIMESTAMP as DATE), 'YYYY-MM-DD')
--order by to_char(cast(ORIGINATING_TIMESTAMP as DATE), 'YYYY-MM-DD');



set lines 220 pages 9000
col message_text for a170
col ADR_HOME for a30 trunc
select TO_CHAR(A.ORIGINATING_TIMESTAMP, 'dd.mm.yyyy hh24:mi') MESSAGE_TIME
,message_text
--,host_id
from V$DIAG_ALERT_EXT A
where A.ORIGINATING_TIMESTAMP > sysdate-1
and component_id='rdbms' order by 1 desc;