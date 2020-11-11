Rem
Rem $Header: rdbms/admin/spauto.sql /main/5 2017/05/28 22:46:10 stanaya Exp $
Rem
Rem spauto.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spauto.sql
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file to automate the collection of STATPACK
Rem      statistics.
Rem
Rem    NOTES
Rem      Should be run as the STATSPACK owner, PERFSTAT.
Rem      Requires job_queue_processes init.ora parameter to be
Rem      set to a number >0 before automatic statistics gathering
Rem      will run.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/spauto.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/spauto.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    12/06/99 - 1059172, 1103031
Rem    cdialeri    08/13/99 - Created
Rem


spool spauto.lis

--
--  Schedule a snapshot to be run on this instance every hour, on the hour

variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;
  dbms_job.submit(:jobno, 'statspack.snap;', trunc(sysdate+1/24,'HH'), 'trunc(SYSDATE+1/24,''HH'')', TRUE, :instno);
  commit;
end;
/


prompt
prompt  Job number for automated statistics collection for this instance
prompt  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt  Note that this job number is needed when modifying or removing
prompt  the job:
print jobno

prompt
prompt  Job queue process
prompt  ~~~~~~~~~~~~~~~~~
prompt  Below is the current setting of the job_queue_processes init.ora
prompt  parameter - the value for this parameter must be greater 
prompt  than 0 to use automatic statistics gathering:
show parameter job_queue_processes
prompt

prompt
prompt  Next scheduled run
prompt  ~~~~~~~~~~~~~~~~~~
prompt  The next scheduled run for this job is:
select job, next_date, next_sec
  from user_jobs
 where job = :jobno;

spool off;
