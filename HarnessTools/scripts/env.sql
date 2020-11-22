set lines 220 pages 50000 timing on feedback on arraysize 5000 verify off serveroutput on 
col TRACE_FILE_NAME for a100 trunc
col trace_10046_on for a50 trunc
col trace_10046_off for a50 trunc
col trace_10053_on for a50 trunc
col trace_10053_off for a50 trunc
clear screen
PROMPT .________________________________________________________________________________________________________________________
PROMPT .________________________________________________________________________________________________________________________

set feedback off timing off
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select distinct(instance_number) from v$instance;
select sid, serial# from v$session where sid=sys_context('USERENV','SID');
select 'exec dbms_system.set_ev('||sid||','||serial#||',10053,8,'''');' trace_10053_on, 
'exec dbms_system.set_ev('||sid||','||serial#||',10053,0,'''');' trace_10053_off from v$session where sid=sys_context('USERENV','SID');

select 'exec dbms_system.set_ev('||sid||','||serial#||',10046,8,'''');' trace_10046_on,  
'exec dbms_system.set_ev('||sid||','||serial#||',10046,0,'''');' trace_10046_off from v$session where sid=sys_context('USERENV','SID');

select value Trace_file_name from v$diag_info where name= 'Default Trace File';
exec dbms_session.set_identifier(client_id=>'ALLEN1');
select 'exec dbms_monitor.client_id_trace_enable(client_id=>''ALLEN1'',waits=>true,binds=>false);' trace_parallel_query_on,
'exec dbms_monitor.client_id_trace_disable(client_id=>''ALLEN1'',waits=>true,binds=>false);' trace_parallel_query_off from dual;

PROMPT .
PROMPT .________________________________________________________________________________________________________________________
PROMPT NOTE :-> locate parallel trace files, issue grep command to locate files     :->   grep "CLIENT ID: (ALLEN1)" *.trc

PROMPT .

set feedback on timing on
