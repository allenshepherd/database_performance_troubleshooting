Rem
Rem $Header: rdbms/admin/execsch.sql /main/31 2017/04/13 18:51:02 prshanth Exp $
Rem
Rem execsch.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsch.sql - EXECute Scheduler PL/SQL
Rem
Rem    DESCRIPTION
Rem      Create Scheduler objects
Rem
Rem    NOTES
Rem      Run after schedule package loads, but before dependents
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execsch.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execsch.sql
Rem SQL_PHASE: EXECSCH
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpcnfg.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prshanth    04/10/17 - Bug 25832935: move fixes of 23039033 and 23030152
Rem                           to the ICD of cleanup_task
Rem    jnunezg     02/07/17 - bug 25422950: Modify file_watch_job
Rem    geadon      09/16/16 - bug 24515918: add parameters for global idx
Rem                           cleanup
Rem    thbaby      04/06/16 - Bug 23039033: skip app object check in
Rem                           cleanup_transient_type, cleanup_transient_pkg
Rem    thbaby      04/06/16 - Bug 23030152: skip app object check in
Rem                           cleanup_online_pmo
Rem    jnunezg     03/15/16 - Do not give grants with admin option
Rem    pxwong      11/26/14 - re-enable in-memory project 
Rem    richen      01/16/14 - 17974868: Create DEFAULT_JOB_CLASS if and only if
Rem                           it doesnt exist
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    gravipat    11/06/13 - 17709031: Use create_cdbview procedure to create
Rem                           cdb views
Rem    jnunezg     09/11/13 - Remove recompile calls
Rem    talliu      03/15/13 - Change FILE_SIZE_UPD to every 5 mins
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    talliu      01/14/13 - add one scheduler job to perform file size update
Rem    jerrede     01/09/13 - Fix lrg 6762378 Invalid scheduler object
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    surman      11/14/12 - 12876907: Add ORACLE_SCRIPT
Rem    geadon      10/18/12 - ignore dbms_part.cleanup_gidx errors
Rem    jnunezg     08/29/12 - Dont create SCHEDULER$_LOG_DIR object at DB
Rem                           creation time
Rem    thbaby      04/30/12 - create scheduler jobs for cleanup
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    pxwong      03/20/11 - disable project 25225 and 25227
Rem    gravipat    12/05/11 - Create cdbview using CDB$VIEW function
Rem    geadon      09/20/11 - add pmo deferred global idx maintenance job
Rem    paestrad    07/20/11 - Changes for new job types and external job output
Rem    rgmani      07/13/11 - Scheduler DB consolidation related views
Rem    rramkiss    11/09/09 - change email_server_ssl to
Rem                           email_server_encryption
Rem    rramkiss    10/20/09 - add new sched attribs for e-mail encryption/auth
Rem    evoss       04/01/09 - add local pseudo destinations
Rem    rgmani      03/14/08 - Add file watch job
Rem    rramkiss    03/13/08 - add new e-mail scheduler attributes
Rem    rburns      07/29/06 - create scheduler objects 
Rem    rburns      07/29/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create CDB views that are used by scheduler
execute CDBView.create_cdbview(false, 'SYS', 'JOB$_REDUCED', 'JOB$_CDB');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_JOB', 'SCHEDULER$_CDB_JOB');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_WINDOW', 'SCHEDULER$_CDB_WINDOW');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_LIGHTWEIGHT_JOB', 'SCHEDULER$_CDB_LIGHTWEIGHT_JOB');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_CLASS', 'SCHEDULER$_CDB_CLASS');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_PROGRAM', 'SCHEDULER$_CDB_PROGRAM');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_GLOBAL_ATTRIBUTE', 'SCHEDULER$_CDB_GLOBAL_ATTRIB');

execute CDBView.create_cdbview(false, 'SYS', 'SCHEDULER$_COMB_LW_JOB', 'SCHEDULER$_CDB_COMB_LW_JOB');

/* Scheduler admin role */
CREATE ROLE scheduler_admin
/
GRANT create job, create any job, execute any program, execute any class,
manage scheduler, create external job, create credential, create any credential
TO scheduler_admin WITH ADMIN OPTION
/
GRANT scheduler_admin TO dba
/

/* Create a default class and grant execute on it to PUBLIC */
DECLARE
  dummy varchar2(1);
BEGIN
  SELECT null INTO dummy
  FROM sys.obj$ o
  WHERE o.name = 'DEFAULT_JOB_CLASS'
  AND o.owner# = 0;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    --dbms_output.put_line('DEFAUTL_JOB_CLASS is not found! Create it...');
    dbms_scheduler.create_job_class(job_class_name => 'DEFAULT_JOB_CLASS',
      comments=>'This is the default job class.');
    dbms_scheduler.set_attribute('DEFAULT_JOB_CLASS','SYSTEM',TRUE);
    EXECUTE IMMEDIATE 'grant execute on sys.default_job_class to public with grant option';
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -27477 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

/* Create a default class and grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'SCHED$_LOG_ON_ERRORS_CLASS',
 logging_level => DBMS_SCHEDULER.LOGGING_FAILED_RUNS,
 comments=>'This is the default job class if you want minimal logging.');
dbms_scheduler.set_attribute('SCHED$_LOG_ON_ERRORS_CLASS','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/

/* Create a default class for in-memory jobs and grant execute on it to PUBLIC */
/* This new default class logs the minimum in order to be the fastest, only failed
   runs are logged */
begin
dbms_scheduler.create_job_class(job_class_name => 'DEFAULT_IN_MEMORY_JOB_CLASS',
 logging_level => DBMS_SCHEDULER.LOGGING_FAILED_RUNS,
 comments=>'This is the default job class for in-memory jobs.');
dbms_scheduler.set_attribute('DEFAULT_IN_MEMORY_JOB_CLASS','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/


/* Create a job class for jobs created through DBMS_JOB api and 
   grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'DBMS_JOB$',
 logging_level=>DBMS_SCHEDULER.LOGGING_OFF,
 comments=>'This is the job class for jobs created through DBMS_JOB.');
dbms_scheduler.set_attribute('DBMS_JOB$','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/
grant execute on sys.dbms_job$ to public with grant option
/


-- Only set the 'MAX_JOB_SLAVE_PROCESSES', 'LOG_HISTORY','DEFAULT_TIMEZONE'
-- global attributes to their default values only if they do not already
-- exist in the table.  This is to retain their value on upgrades.

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'MAX_JOB_SLAVE_PROCESSES';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('MAX_JOB_SLAVE_PROCESSES', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'LOG_HISTORY';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('LOG_HISTORY', 30);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'DEFAULT_TIMEZONE';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('DEFAULT_TIMEZONE', 
                            dbms_scheduler.get_sys_time_zone_name);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER_ENCRYPTION';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER_ENCRYPTION', 'NONE');
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER_CREDENTIAL';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER_CREDENTIAL', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SENDER';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SENDER', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/


--Create pseudo local external destination
BEGIN
dbms_isched.create_agent_destination( 
  destination_name => 'sched$_local_pseudo_agent',
  hostname         => 'pseudo_host',
  port             => '0',
  comments         => 'Place holder for synonym LOCAL dest');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

--Create pseudo local db destination
BEGIN
dbms_scheduler.create_database_destination( 
  destination_name  => 'sched$_local_pseudo_db',
  agent             => 'sched$_local_pseudo_agent',
  tns_name          => 'pseudo_inst',
  comments          => 'Place holder for synonym LOCAL_DB dest');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

--Create purge log program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'purge_log_prog',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_scheduler.auto_purge',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'purge log program');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create daily schedule. 
BEGIN
dbms_scheduler.create_schedule(
   schedule_name=>'DAILY_PURGE_SCHEDULE',
   repeat_interval=>'freq=daily;byhour=3;byminute=0;bysecond=0');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create purge log job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'PURGE_LOG',
    program_name=>'purge_log_prog',
    schedule_name=>'DAILY_PURGE_SCHEDULE',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>TRUE,
    auto_drop=>FALSE,
    comments=>'purge log job');
  sys.dbms_scheduler.set_attribute('PURGE_LOG','FOLLOW_DEFAULT_TIMEZONE',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create file watcher program
BEGIN
  dbms_scheduler.create_program(
    program_name =>'FILE_WATCHER_PROGRAM',
    program_type=>'STORED_PROCEDURE',
    program_action =>'dbms_ischedfw.file_watch_job',
    number_of_arguments => 0,
    enabled => TRUE,
    comments => 'File Watcher program');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create FileWatcher Schedule
BEGIN
  dbms_scheduler.create_schedule(
    schedule_name => 'FILE_WATCHER_SCHEDULE',
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=10');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create file watcher job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'FILE_WATCHER',
    program_name=>'FILE_WATCHER_PROGRAM',
    schedule_name=>'FILE_WATCHER_SCHEDULE',
    job_class=>'SCHED$_LOG_ON_ERRORS_CLASS',
    enabled=>FALSE,
    auto_drop=>FALSE,
    comments=>'File watcher job');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

begin
  dbms_scheduler.set_scheduler_attribute('LAST_OBSERVED_EVENT', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('EVENT_EXPIRY_TIME', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('FILE_WATCHER_COUNT', '0');
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

-- create deferred global index maintenance schedule
BEGIN
  dbms_scheduler.create_schedule(
   schedule_name      => 'sys.pmo_deferred_gidx_maint_sched',
   repeat_interval    => 'FREQ=DAILY; BYHOUR=02; BYMINUTE=0; BYSECOND=0');

  EXCEPTION
    when others then
      if sqlcode = -27477 then NULL;
      else raise;
      end if;
END;
/

-- create deferred global index maintenance program
BEGIN
  BEGIN
    dbms_scheduler.disable('sys.pmo_deferred_gidx_maint', TRUE);
    dbms_scheduler.drop_program('sys.pmo_deferred_gidx_maint', TRUE);

    EXCEPTION
      when others then
        if sqlcode = -27476 then NULL;
        else raise;
        end if;
  END;

  dbms_scheduler.create_program(
    program_name        => 'sys.pmo_deferred_gidx_maint', 
    program_type        => 'STORED_PROCEDURE', 
    program_action      => 'dbms_part.cleanup_gidx_job',
    number_of_arguments => 2,
    enabled             => FALSE,
    comments
      => 'Oracle defined automatic index cleanup for partition maintenance '
      || 'operations with deferred global index maintenance ');

  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'sys.pmo_deferred_gidx_maint', 
    argument_position => 1,
    argument_name => 'parallel',
    argument_type => 'VARCHAR2',
    default_value => NULL);

  DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
    program_name => 'sys.pmo_deferred_gidx_maint', 
    argument_position => 2,
    argument_name => 'options',
    argument_type => 'VARCHAR2',
    default_value => NULL);

  SYS.DBMS_SCHEDULER.ENABLE('sys.pmo_deferred_gidx_maint');
END;
/

-- create deferred global index maintenance job
BEGIN
  dbms_scheduler.create_job(
    job_name           => 'sys.pmo_deferred_gidx_maint_job',
    program_name       => 'sys.pmo_deferred_gidx_maint', 
    schedule_name      => 'sys.pmo_deferred_gidx_maint_sched',
    job_class          => 'SCHED$_LOG_ON_ERRORS_CLASS',
    enabled            => TRUE,
    auto_drop          => FALSE,
    comments
      => 'Oracle defined automatic index cleanup for partition maintenance '
      || 'operations with deferred global index maintenance ');

  EXCEPTION
    when others then
      if sqlcode = -27477 then
          SYS.DBMS_SCHEDULER.ENABLE('sys.pmo_deferred_gidx_maint_job');
      else
        raise;
      end if;
END;
/

-- create scheduler job to remove non-existent objects
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_NON_EXIST_OBJ';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_NEXIST_OBJ
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(1); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(120, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 12',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE, 
             comments => 'Cleanup Non Existent Objects in obj$');
  end if;
end;
/

-- create scheduler job to perform online index build cleanup
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_ONLINE_IND_BUILD';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_ONLINE_IND
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(2); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(130, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 1', 
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Online Index Build');
  end if;
end;
/

-- create scheduler job to perform tab$ and tabpart$ cleanup
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TAB_IOT_PMO';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TAB
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(3); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(140, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 1',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Tables after IOT PMO');
  end if;
end;
/

-- create scheduler job to cleanup transient types
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_TYPE';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_TYP
             -- Bug 23039033: skip app object check by setting parameter
             -- Bug 25832935: move fix of 23039033 to ICD of cleanup_task
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(4); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(150, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Types');
  end if;
end;
/

-- create scheduler job to cleanup cursor transient packages
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_PKG';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_PKG
             -- Bug 23039033: skip app object check by setting parameter
             -- Bug 25832935: move fix of 23039033 to ICD of cleanup_task
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(5); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(160, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Packages');
  end if;
end;
/

-- create scheduler job to perform online PMO cleanup
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_ONLINE_PMO';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_ONLINE_PMOP
             -- Bug 23030152: skip app object check by setting parameter
             -- Bug 25832935: move fix of 23030152 to ICD of cleanup_task
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(6); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(170, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 1',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup after Failed PMO');
  end if;
end;
/


-- create scheduler job to perform file size update
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'FILE_SIZE_UPD';

  select count(*) into exist
  from   dba_scheduler_jobs
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_FILE_SIZE_UPD
             job_action =>
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(7); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(170, 'second'),
             repeat_interval => 'FREQ = MINUTELY; INTERVAL = 5',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS',
             enabled => TRUE,
             comments => 'Update file size periodically');
  end if;
end;
/

-- ***************************************************************************
-- This has to be the last thing executed in catsch.sql
-- Do not add anything after this
-- ***************************************************************************

begin
  dbms_scheduler.set_scheduler_attribute('CURRENT_OPEN_WINDOW', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/


@?/rdbms/admin/sqlsessend.sql
