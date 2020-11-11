set termout off
SET PAGESIZE 9999
SET VERIFY   ON


set markup html on spool on entmap off -
head '-
        <style type="text/css"> - 
  body {font:12pt Arial,Helvetica,sans-serif; color:black; background:C0BDD4;} -
  p {   font:12pt Arial,Helvetica,sans-serif; color:black; background:White;} -
        table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; -
        padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; white-space:nowrap;} -
  th {  font:bold 12pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; -
        padding:0px 0px 0px 0px;} -
  h1 {  font:15pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; -
        border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
  h2 {  font:bold 13pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; -
        margin-top:4pt; margin-bottom:0pt;} a {font:11pt Arial,Helvetica,sans-serif; color:#663300; -
        background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
</style>' -
        body 'text=black bgcolor=C0BDD4 align=center' -
        table 'align=center width=99% border=3 bordercolor=black bgcolor=C0BDD4'-

spool test.html append

set pagesize 250 linesize 250
select DB_UNIQUE_NAME, CREATED, DATABASE_ROLE from v$database;

Set lines 200
Set pages 200
col "SPFILEs in ASM" for a15
col "Multiplexed Control Files" for a20
col " Control Files Keep >7 Days" for a20
col value for 999
select
(CASE when
( select count (DISTINCT value) from gv$parameter where name ='spfile' and value like '%+DATA%' ) =1
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SPFILEs in ASM",
( select (CASE when count(value)=1 THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE</font>' END) from v$parameter
where name='control_files' AND VALUE like '%,%' AND  VALUE like '%+DATA%'
AND VALUE like '%+FRA%' AND VALUE not like '%/opt/oracle%' )
"Multiplexed Control Files",
( select (CASE when value <= 6 THEN CONCAT('<font size=4pt COLOR=RED>FALSE </font>', to_char(value,99)) ELSE 'TRUE' END)
from v$parameter where name='control_file_record_keep_time' )
"Control Files Keep >7 Days" 
from dual;


/*############### DB Files*/
col "total DB file Count" for a20
col "% Files Used" for 99.99
col "Sufficient Files Free" for a35
select (select a.value from v$parameter a where a.name='db_files') "total DB file Count",
(select count(FILE#) from  v$datafile) "DB files Used",
((select count(FILE#) from  v$datafile)/(select a.value from v$parameter a where a.name='db_files')) "% Files Used",
(case when ((1-((select count(FILE#) from  v$datafile)/(select a.value from v$parameter a where a.name='db_files')))) > .35 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Sufficient Files Free" from dual;

/*############### AWR Retention Policies*/
col "AWR Snapshot interval= 1hr" for a30
col "Retention = 1 month" for a25
Select 
(case 
when ( Select extract( day from snap_interval) *24*60+ extract( hour from snap_interval) *60+ extract( minute from snap_interval ) from dba_hist_wr_control ) =60
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "AWR Snapshot interval= 1hr" ,
(case
when (select extract( day from retention) + extract( hour from retention) *24+ extract( minute from retention ) *60*24 from dba_hist_wr_control) BETWEEN 28
AND 34 THEN 'TRUE'
ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Retention = 1 month" from dual;

/*################Sessions & Processes*/
col "Sessions" for a15
col "Processes" for a15
col "Correct Ratio" for a15
select (select value from v$parameter where name ='sessions') "Sessions",
(select value from v$parameter where name ='processes') "Processes",
(case when (((select value from v$parameter where name ='sessions')/ (select value from v$parameter where name ='processes'))) BETWEEN  1.09 AND 1.53
THEN 'TRUE' ELSE 'FALSE' END) "Correct Ratio" from dual;



/*################ ARCHIVE POLICIES*/
col "DB in Archive Mode" for a19
col "Average DAily GB Usage" for a25
col "Average DAily GB Usage" for 999999
col "Flasback Policy Off" for a20
col "FRA Location" for a15
col "FRA SiZE in GB" for a15
col "ARC Dest 1" for a20
col "ARC Dest 2" for a20
col "Force Log Switch time Enable" for a30
col "Archive Tracing Disabled" for a25
col "FRA GB Size" for a15
col "FRA GB Size" for 9999999
Select
(case
when (
select log_mode from v$database) ='ARCHIVELOG'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "DB in Archive Mode" ,
(case
when (select flashback_on from v$database) ='NO'
THEN 'TRUE'ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Flasback Policy Off",
(case when (select value from v$parameter where name='log_archive_trace')=0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Archive Tracing Disabled",
(case when (((select value from v$parameter where name='db_recovery_file_dest_size')/1024/1024/1024)) BETWEEN  1400 AND 1600
 THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "FRA SiZE in GB",
((select value from v$parameter where name='db_recovery_file_dest_size')/1024/1024/1024) "FRA GB Size",
(select ceil(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024/7) from gv$archived_log where first_time>sysdate-7 group by (TO_CHAR(FIRST_TIME,'yyyy'))) "Average DAily GB Usage",
(select value from v$parameter where name='db_recovery_file_dest') "FRA Location",
(select value from v$parameter where name='log_archive_dest_1') "ARC Dest 1"
from dual;





/*################ MEMORY PARAMETERS*/
set lines 200
col "SGA Size" for a10
col "Buffer Cache"for a11
col "SGA Target"for a15
col "PGA Size"for a10
col "Memory Max Target" for a15
col "Memory Target" for a15
col "Java Pool" for a11
col "Shared Pool" for a12
col "Streams Pool" for a15
col "Large Pool" for a14
col "SGA-PGA RATIO" for a23

Select
(case when ((( select value from v$parameter where name='sga_max_size')/1024/1024/1024)) > 3 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SGA SiZE",
(case when ((( select value from v$parameter where name='pga_aggregate_target')/1024/1024/1024)) > 1 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "PGA SiZE",
(case when (((( select value from v$parameter where name='pga_aggregate_target')/1024/1024/1024))/((( select value from v$parameter where name='sga_max_size')/1024/1024/1024)))
BETWEEN .24 AND .51 THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SGA-PGA RATIO",
(case when ((( select value from v$parameter where name='db_block_size')/1024/1024/1024*(select value from v$parameter where name='db_block_buffers') )) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Buffer Cache",
(case when ((( select value from v$parameter where name='sga_target')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SGA TARGET",
(case when ((( select value from v$parameter where name='memory_max_target')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Memory Max Target",
(case when ((( select value from v$parameter where name='memory_target')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Memory Target",
(case when ((( select value from v$parameter where name='java_pool_size')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Java Pool",
(case when ((( select value from v$parameter where name='shared_pool_size')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Shared Pool",
(case when ((( select value from v$parameter where name='streams_pool_size')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Streams Pool",
(case when ((( select value from v$parameter where name='large_pool_size')/1024/1024/1024)) = 0 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Large Pool"
from dual;


/*#####################LEGACY ALERTING*/

col "Legacy Dataguard Alert" for a25
col "Legacy Backup Alerts" for a25
col "Legacy Waiting Alert" for a25
select
(case when ( select count(PROGRAM_NAME)  from dbimgr.dbi_programs where PROGRAM_NAME='dbimgr.dbi_check_dg_lag' and ACTIVE_FLAG='Y') = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Legacy Dataguard Alert",
(case when ( select count(PROGRAM_NAME)  from dbimgr.dbi_programs where PROGRAM_NAME='dbimgr.dbi_alert_report_bkup_p' and ACTIVE_FLAG='Y') = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Legacy Backup Alerts" ,
(case when ( select count(PROGRAM_NAME)  from dbimgr.dbi_programs where PROGRAM_NAME='dbimgr.dbi_alert_report_p' and ACTIVE_FLAG='Y') = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Legacy Waiting Alert"
from dual;


/*#####################ORLs and SRLs */
col "REDO Size Equal" for a15
col "1 Thread per Inst" for a17
col "ORL/SRL: REDO Size Equal" for a20
col "ORL: =>2 Groups per Thread" for a20
col "ORL: Multiplexed" for a17
col "SRL: =>3 Groups per Thread" for a20
col "SRL: Multiplexed" for a17

select
(select max(bytes)/1024/1024/1024 from gv$log where status <> 'UNSUED') "Redo Size (GB)",
(case when (select count (THREAD#) from v$thread)= (select count (inst_id) from gv$database)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "1 Thread per Inst",
(case when (select count(distinct BYTES) from gv$log where status <>'UNUSED') =1 AND (select count(distinct BYTES) from gv$standby_log) = 1
THEN (case when (select count(distinct BYTES) from gv$log where status <>'UNUSED') = (select count(distinct BYTES) from gv$standby_log) 
        THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END)
ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO Size Equal",
(case when (select count (distinct groups) from v$thread where current_group# <>0) =1
THEN
        (case when (select distinct groups from v$thread where current_group# <>0) >=2
        THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END)
ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "ORL: =>2 Groups per Thread",
(case when (select count (distinct MEMBER) from v$logfile where type ='ONLINE' and member like '+DATA%')=(select count (distinct MEMBER) from v$logfile where type ='ONLINE' and member like '+FRA%')
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "ORL: Multiplexed",
(case when (select count(THREAD#) from v$log) =
((select count(THREAD#) from v$standby_log) + (select count(inst_id) from gv$database))
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SRL: =>3 Groups per Thread",
(case when (select count (distinct MEMBER) from v$logfile where type ='STANDBY' and member like '+DATA%')=(select count (distinct MEMBER) from v$logfile where type ='STANDBY' and member like '+FRA%')
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "SRL: Multiplexed"
from dual;




/*#####################DG SETTINGS*/

col "Broker Enabled" for a25
col "RTA Enabled" for a25
col "Real Time Apply" for a25
col "REDO: Service" for a25
col "FAL Client" for a25
col "FAL Server" for a25
col "REDO: LGWR Process" for a22
col "REDO: Async/No Affirm" for a22
col "REDO: No Delay" for a22
col "REDO: Max_Fail =0" for a25
col "REDO: Retry Wait =5 mins" for a25
col "REDO: Max Connect =1" for a22
col "REDO: DB Unique name" for a22
col "REDO: DEST_2 Status" for a22

Select
(case when (select DATAGUARD_BROKER from v$database) = 'ENABLED' 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Broker Enabled",
(case when (SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2) = 'MANAGED REAL TIME APPLY' 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Real Time Apply",
(case when ( select value from v$parameter where name = 'fal_client') = (select DB_UNIQUE_NAME from v$database)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "FAL Client",
(case when (select upper(value) from  v$parameter where name = 'fal_server') = 
(case when (select count(DB_UNIQUE_NAME) from v$database where DB_UNIQUE_NAME like '%E')=1 
THEN (select TRIM( 'E' from (select upper(DB_UNIQUE_NAME) from v$database)) from dual) ELSE concat((select upper(DB_UNIQUE_NAME) from v$database),'E') END)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "FAL Server",
(case when (select upper(destination)from V$ARCHIVE_DEST where dest_id=2) = 
(case when (select count(DB_UNIQUE_NAME) from v$database where DB_UNIQUE_NAME like '%E')=1 
THEN (select TRIM( 'E' from (select upper(DB_UNIQUE_NAME) from v$database)) from dual) ELSE concat((select upper(DB_UNIQUE_NAME) from v$database),'E') END)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Service",
(case when (select status from V$ARCHIVE_DEST where dest_id=2) = 'VALID'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: DEST_2 Status"
from dual;
Select
(case when (select process from V$ARCHIVE_DEST where dest_id=2) = 'LGWR' AND (select archiver from V$ARCHIVE_DEST where dest_id=2) = 'LGWR'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: LGWR Process",
(case when (select TRANSMIT_MODE from V$ARCHIVE_DEST where dest_id=2) = 'ASYNCHRONOUS' AND (select AFFIRM from V$ARCHIVE_DEST where dest_id=2) = 'NO'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Async/No Affirm",
(case when (select delay_mins from V$ARCHIVE_DEST where dest_id=2) = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: No Delay",
(case when (select max_failure from V$ARCHIVE_DEST where dest_id=2) = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Max_Fail =0",
(case when (select MAX_CONNECTIONS from V$ARCHIVE_DEST where dest_id=2) = 1
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Max Connect =1",
(case when (select REOPEN_SECS from V$ARCHIVE_DEST where dest_id=2) = 300
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Retry Wait =5 mins",
(case when (select upper(DB_unique_name) from V$ARCHIVE_DEST where dest_id=2) = 
(case when (select count(DB_UNIQUE_NAME) from v$database where DB_UNIQUE_NAME like '%E')=1 
THEN (select TRIM( 'E' from (select upper(DB_UNIQUE_NAME) from v$database)) from dual) ELSE concat((select upper(DB_UNIQUE_NAME) from v$database),'E') END)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: DB Unique name"
from dual;


/*
col "Broker Enabled" for a11
col "RTA Enabled" for a10
col "Real Time Apply" for a15
col "FAL Client" for a10
col "FAL Server" for a15
col "REDO: LGWR Process" for a15
col "REDO: Async/No Affirm" for a15
col "REDO: No Delay" for a12
col "REDO: Max_Fail =0" for a15
col "REDO: Retry Wait =5 mins" for a20
col "REDO: Max Connect =1" for a20
col "REDO: DB Unique name" for a19
col "REDO: DEST_2 Status" for a18

Select
(case when (select DATAGUARD_BROKER from v$database) = 'ENABLED' 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Broker Enabled",
(case when (SELECT RECOVERY_MODE FROM V$ARCHIVE_DEST_STATUS WHERE DEST_ID=2) = 'MANAGED REAL TIME APPLY' 
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "Real Time Apply",
(case when ( select value from v$parameter where name = 'fal_client') = (select DB_UNIQUE_NAME from v$database)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "FAL Client",
(case when (select upper(value) from  v$parameter where name = 'fal_server') = 
(case when (select count(DB_UNIQUE_NAME) from v$database where DB_UNIQUE_NAME like '%E')=1 
THEN (select upper(DB_UNIQUE_NAME) from v$database) ELSE concat((select upper(DB_UNIQUE_NAME) from v$database),'E') END)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "FAL Server",
(case when (select status from V$ARCHIVE_DEST where dest_id=2) = 'VALID'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: DEST_2 Status",
(case when (select process from V$ARCHIVE_DEST where dest_id=2) = 'LGWR' AND (select archiver from V$ARCHIVE_DEST where dest_id=2) = 'LGWR'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: LGWR Process",
(case when (select TRANSMIT_MODE from V$ARCHIVE_DEST where dest_id=2) = 'ASYNCHRONOUS' AND (select AFFIRM from V$ARCHIVE_DEST where dest_id=2) = 'NO'
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Async/No Affirm",
(case when (select delay_mins from V$ARCHIVE_DEST where dest_id=2) = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: No Delay",
(case when (select max_failure from V$ARCHIVE_DEST where dest_id=2) = 0
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Max_Fail =0",
(case when (select MAX_CONNECTIONS from V$ARCHIVE_DEST where dest_id=2) = 1
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Max Connect =1",
(case when (select REOPEN_SECS from V$ARCHIVE_DEST where dest_id=2) = 300
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: Retry Wait =5 mins",
(case when (select upper(DB_unique_name) from V$ARCHIVE_DEST where dest_id=2) = 
(case when (select count(DB_UNIQUE_NAME) from v$database where DB_UNIQUE_NAME like '%E')=1 
THEN (select upper(DB_UNIQUE_NAME) from v$database) ELSE concat((select upper(DB_UNIQUE_NAME) from v$database),'E') END)
THEN 'TRUE' ELSE '<font size=4pt COLOR=RED>FALSE </font>' END) "REDO: DB Unique name"
from dual;
*/


PROMPT **************************************************************************************************************************************************
PROMPT **************************************************************************************************************************************************

spool off
set markup html off
