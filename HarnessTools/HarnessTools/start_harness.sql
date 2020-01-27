set echo off
set term off

store set default.env replace
prompt

rem $Header$
rem $Name$          start_harness.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem 14JAN2011 RVD Modified to use DBMS_SCHEDULER instead of DBMS_JOB
rem               
rem 

set termout on verify off heading off feed off

@hshowconfig

prompt ******************************************
prompt This is your current harness configuration
prompt ******************************************

accept htst_yn prompt 'Do you wish to update any of these settings? (Y/N): '

set echo off
set termout off verify off heading off feed off

select '@hconfig' the_exec
  from dual
 where substr(upper('&htst_yn'), 1, 1) = 'Y'

spool exec_config.lst replace
/
spool off

@exec_config.lst

set termout on verify off heading off feed off
prompt

prompt Enter a unique name for your harness snapshot capturing session
accept htst_pipename prompt 'This name must be less than 10 characters in length: '

set termout on
set serveroutput on
rem Turn on capturing session by submitting background job to open the pipe
declare
  v_job_string    varchar2(200) ;
  v_code   NUMBER;
  v_errm   VARCHAR2(64);
  v_job    hconfig.capture_job_no%type := 1;
  v_pipe   hconfig.harness_pipe_name%type := '&htst_pipename';
  v_jname  hconfig.capture_job_name%type;
  v_job_chk    hconfig.capture_job_no%type;
  v_pipe_chk   hconfig.harness_pipe_name%type;
  v_jname_chk  hconfig.capture_job_name%type;

  v_user_schd_jobs   user_scheduler_jobs%rowtype;
  
  v_sid         v$session.sid%type;
  v_serial#     v$session.serial#%type;
  v_program     v$session.program%type;
  v_module      v$session.module%type;
  v_action      v$session.action%type;
begin
  -- First verify that a harness job isn't already running
   select capture_job_no, harness_pipe_name, capture_job_name
     into v_job_chk, v_pipe_chk, v_jname_chk
     from hconfig ;

  if v_jname_chk is not null -- a harness job is running
  then 
    dbms_output.put_line ('***************************************************************') ;
    dbms_output.put_line ('* A Harness job is already running. ') ;
    dbms_output.put_line ('* Harness Job Name    : ' || trim(v_jname_chk));
    dbms_output.put_line ('* There is no need to start another one.');
    dbms_output.put_line ('* Use CHK_HARNESS to see this Harness Job.');
    dbms_output.put_line ('* Use HARNESS_JOBS to see details on running all Harness jobs.');
    dbms_output.put_line ('* If you need to start a new one use STOP_HARNESS first.');   
    dbms_output.put_line ('***************************************************************') ;
  else -- Start a new capture job
    v_jname := 'HARNESS_'|| '&htst_pipename';
    v_job_string := 'begin  snap_request_fulfill(''&htst_pipename'')';
    v_job_string := v_job_string || ';  end;' ;  

    dbms_output.put_line ('*************************************************' ) ;
    dbms_output.put_line ('Creating the Harness Capture Job...') ;
    -- create the job with DBMS_SCHEDULER.
    begin
      dbms_scheduler.create_job
        (job_name => v_jname,
         job_type => 'PLSQL_BLOCK',
         job_action=> v_job_string,
         start_date => SYSDATE,
         enabled=>true,
         end_date=> null,
         auto_drop=> false,
         comments=>'Hotsos Harness Capture Job');
      -- set restartable attribute to TRUE this allows the job to be restarted after a shutdown
      dbms_scheduler.set_attribute(v_jname,'restartable',true);
      -- set logging level to FULL for debugging  
      dbms_scheduler.set_attribute(v_jname,'logging_level',DBMS_SCHEDULER.LOGGING_FULL);
    end;
    commit ;
    -- Set the job information in the hconfig table.
    update hconfig set capture_job_no = v_job, harness_pipe_name = v_pipe, capture_job_name = v_jname;
    commit ;
    -- Wait for a few seconds to allow the job to start.
    dbms_lock.sleep(4);
    -- Select job information  
    select * into v_user_schd_jobs from user_scheduler_jobs where job_name = upper(trim(v_jname)); 
    dbms_output.put_line ('*************************************************' ) ;
    dbms_output.put_line ('The Harness Capture Job has been STARTED') ;
    dbms_output.put_line ('* From HCONFIG:' ) ;
    dbms_output.put_line ('Harness Job Name    : ' || trim(v_jname));
    dbms_output.put_line ('Harness Pipe Name   : ' || trim(v_pipe)) ;
    dbms_output.put_line ('Capture Session Job#: ' || trim(to_char(v_job)) ) ;
    dbms_output.put_line ('*************************************************' ) ;
    dbms_output.put_line ('* From USER_SCHEDULER_JOBS:' ) ;
    dbms_output.put_line ('Scheduler Job Name  : ' || trim(v_user_schd_jobs.job_name));
    dbms_output.put_line ('Enabled             : ' || trim(v_user_schd_jobs.enabled));
    dbms_output.put_line ('State               : ' || trim(to_char(v_user_schd_jobs.state)));
    dbms_output.put_line ('Restartable         : ' || trim(to_char(v_user_schd_jobs.restartable)));
    dbms_output.put_line ('Logging Level       : ' || trim(to_char(v_user_schd_jobs.logging_level)));
    dbms_output.put_line ('Last Start Date     : ' || trim(to_char(v_user_schd_jobs.last_start_date)));
    dbms_output.put_line ('*************************************************' ) ;

  end if; -- v_jname is not null

exception
   when others then
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1 , 64);
        DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred!  Run @chk_harness to verify harness startup.');
        raise;
end;
/

@hrmtempfile exec_config.lst

rem Set harness environment
@hlogin
