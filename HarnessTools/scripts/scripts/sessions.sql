set lines 220 pages 50000
col MACHINE for a40 trunc
col service_name for a20 trunc
select INST_ID,status,SCHEMANAME,SERVICE_NAME, OSUSER,  MACHINE, count(*) from gv$session where schemaname <>'PUBLIC' and SERVICE_NAME not like 'SYS%' group by inst_id,machine,osuser, service_name,schemaname,STATUS order by 3,5 desc
/

select SCHEMANAME,SERVICE_NAME, MACHINE, count(*) from gv$session where schemaname <>'PUBLIC' and SERVICE_NAME not like 'SYS%' group by machine, service_name,schemaname order by 4,1 desc
/
col SERVICES for a150 trunc
select inst_id, value "SERVICES" from gv$parameter where name='service_names'
/
