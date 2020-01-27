rem $Header$
rem $Name$          harness_jobs.sql

rem Copyright (c); 2011 by Hotsos Enterprises, Ltd.
rem
rem 14JAN2011 RVD Initial Creation 
rem               This script selects from the DBA views

exec dbms_output.put_line ('***********************************' ) ;
exec dbms_output.put_line ('*      Current Harness jobs       *' ) ;
exec dbms_output.put_line ('***********************************' ) ;
column owner           heading "Owner"                 format a8
column job_name        heading "Job Name"              format a20
column enabled         heading "Enabled"               format a7
column state           heading "State"                 format a15
column restartable     heading "Restartable"           format a11
column log_id          heading "Log ID"                format 99999
column ld              heading "Log Date" 
column status          heading "Status"                format a10
column additional_info heading "Additional Infomation" format a30 wrap
column elapsed_time    heading "Elapsed Time"          format a20
column cpu_used        heading "CPU Used"              format a20
column session_id      heading "Session ID"            format 9999
set heading on
break on owner on job_name skip 2

exec dbms_output.put_line ('From DBA_SCHEDULER_JOBS' ) ;
select owner, job_name, enabled, state, restartable, logging_level
  from dba_scheduler_jobs
  where job_name like 'HARNESS%'
  order by owner, job_name;

exec dbms_output.put_line ('***********************************' ) ;
exec dbms_output.put_line ('From DBA_SCHEDULER_RUNNING_JOBS:' ) ;
select owner, job_name, session_id, elapsed_time, cpu_used 
  from dba_scheduler_running_jobs
  where job_name like 'HARNESS%' 
  order by owner, job_name;

exec dbms_output.put_line ('***********************************' ) ;
exec dbms_output.put_line ('From DBA_SCHEDULER_JOB_RUN_DETAILS:' ) ;
select owner, job_name, log_id, to_char(log_date, 'DD-MON-YYYY hh24:mi:ss') LD, status, additional_info 
  from dba_scheduler_job_run_details
  where job_name like 'HARNESS%' 
  order by owner, job_name, log_id desc; 

exec dbms_output.put_line ('***********************************' ) ;
exec dbms_output.put_line ('*  End Current Harness jobs       *' ) ;
exec dbms_output.put_line ('***********************************' ) ;
  
clear columns

  