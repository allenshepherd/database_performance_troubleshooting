set lines 220 pages 50000 timing on feedback on arraysize 5000 verify off serveroutput on 
col TRACE_FILE_NAME for a100 trunc
col trace_10046_on for a50 trunc
col trace_10046_off for a50 trunc
col trace_10053_on for a50 trunc
col trace_10053_off for a50 trunc
col host_name for a35 trunc
col patch_description for a60 trunc
col ACTION_TIME for a19 trunc

clear screen
PROMPT .________________________________________________________________________________________________________________________
PROMPT .________________________________________________________________________________________________________________________

set feedback off timing off
select name, DB_UNIQUE_NAME, open_mode, CDB, CON_ID from v$database;
select instance_name, host_name, version , startup_time, INSTANCE_ROLE from v$instance;
select * from (select patch_type, action, status, action_time, description patch_description from dba_registry_sqlpatch where action='APPLY' and status='SUCCESS' order by action_time desc) where rownum<3 ;
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
alter session set NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH:MI:SS.FF';
--select sid, serial# from v$session where sid=sys_context('USERENV','SID');
select 'trace_10053_on' action,  'exec dbms_system.set_ev('||sid||','||serial#||',10053,1,'''');' command  from v$session where sid=sys_context('USERENV','SID')
union all 
select 'trace_10053_off' action,  'exec dbms_system.set_ev('||sid||','||serial#||',10053,0,'''');' command  from v$session where sid=sys_context('USERENV','SID')
union all
select 'trace_10046_on' action,  'exec dbms_system.set_ev('||sid||','||serial#||',10046,12,'''');' command  from v$session where sid=sys_context('USERENV','SID')
union all 
select 'trace_10046_off' action,  'exec dbms_system.set_ev('||sid||','||serial#||',10046,0,'''');' command  from v$session where sid=sys_context('USERENV','SID')
union all
select 'trace_parallel_query_on' action,   'exec dbms_monitor.client_id_trace_enable(client_id=>''ALLEN1'',waits=>true,binds=>false);' command from dual
union all 
select 'trace_parallel_query_off' action,  'exec dbms_monitor.client_id_trace_disable(client_id=>''ALLEN1'',waits=>true,binds=>false);' command from dual
/


select value Trace_file_name from v$diag_info where name= 'Default Trace File';
exec dbms_session.set_identifier(client_id=>'ALLEN1');

PROMPT .
PROMPT .________________________________________________________________________________________________________________________
PROMPT NOTE :-> locate parallel trace files, issue grep command to locate files     :->   grep -Ri "CLIENT ID: (ALLEN1)" *.trc

PROMPT .

clear screen
PROMPT .________________________________________________________________________________________________________________________
PROMPT .________________________________________________________________________________________________________________________
PROMPT .


set feedback on timing on
