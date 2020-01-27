set echo off

rem $Header$
rem $Name$          chk_harness.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem 14JAN2011 RVD Modified to use DBMS_SCHEDULER instead of DBMS_JOB


set termout on verify off heading off feed off serveroutput on


declare
   v_job    hconfig.capture_job_no%type;
   v_pipe   hconfig.harness_pipe_name%type;
   v_jname  hconfig.capture_job_name%type;
   v_code   NUMBER;
   v_errm   VARCHAR2(64);
   v_sid        v$session.sid%type;
   v_serial#    v$session.serial#%type;
   v_program    v$session.program%type;
   v_module     v$session.module%type;
   v_action     v$session.action%type;
   
   v_user_schd_jobs   user_scheduler_jobs%rowtype;
   v_user_schd_running_jobs  user_scheduler_running_jobs%rowtype;
   

begin
   select capture_job_no, harness_pipe_name, capture_job_name
     into v_job, v_pipe, v_jname
     from hconfig ;


   if v_pipe is not null then
      dbms_output.put_line ('******************************' ) ;
      dbms_output.put_line ('The harness is running') ;
      dbms_output.put_line ('Harness Job Name    : ' || trim(v_jname));
      dbms_output.put_line ('Harness Pipe Name   : ' || trim(v_pipe)) ;
      dbms_output.put_line ('Capture Session Job#: ' || trim(to_char(v_job)) ) ;

      -- The Harness Jobs Session information
      begin
        select sid, serial#, program, module, action
          into v_sid, v_serial#, v_program, v_module, v_action
          from v$session
          where username = user and module = 'Hotsos Test Harness';
          dbms_output.put_line ('******************************' ) ;
          dbms_output.put_line ('Harness Capture Session Info ' ) ;
          dbms_output.put_line ('SID     : ' || v_sid ) ;
          dbms_output.put_line ('Serial# : ' || v_serial#) ;
          dbms_output.put_line ('Program : ' || v_program) ;
          dbms_output.put_line ('Module  : ' || v_module) ;
          dbms_output.put_line ('Action  : ' || v_action) ;
      exception
        when NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('----> Harness session information not found. <----');
      end;
         

      -- Getting information directly from the schedular job views 
      begin
        select * 
          into v_user_schd_jobs 
          from user_scheduler_jobs
          where job_name = upper(trim(v_jname));
          dbms_output.put_line ('******************************' ) ;
          dbms_output.put_line ('Data from USER_SCHEDULER_JOBS ' ) ;
          dbms_output.put_line ('Name            : ' || trim(v_user_schd_jobs.job_name));
          dbms_output.put_line ('Enabled         : ' || trim(v_user_schd_jobs.enabled));
          dbms_output.put_line ('State           : ' || trim(to_char(v_user_schd_jobs.state)));
          dbms_output.put_line ('Last Start Date : ' || trim(to_char(v_user_schd_jobs.last_start_date)));
          dbms_output.put_line ('End Date        : ' || trim(to_char(v_user_schd_jobs.end_date)));
          dbms_output.put_line ('Auto Drop       : ' || trim(to_char(v_user_schd_jobs.auto_drop)));
          dbms_output.put_line ('Comment         : ' || trim(v_user_schd_jobs.comments));
          dbms_output.put_line ('******************************' ) ;
         exception
        when NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('----> Harness job not found in user_scheduler_jobs<----');
      end;
     
      
      begin
        select * 
          into v_user_schd_running_jobs
          from user_scheduler_running_jobs
          where job_name = upper(trim(v_jname));
          dbms_output.put_line ('Data from USER_SCHEDULER_JOB_RUNNING_JOBS' ) ;
          dbms_output.put_line ('Name            : ' || trim(v_user_schd_running_jobs.job_name));
          dbms_output.put_line ('Elapsed Time    : ' || trim(v_user_schd_running_jobs.elapsed_time));
          dbms_output.put_line ('CPU Used        : ' || trim(v_user_schd_running_jobs.cpu_used));
          dbms_output.put_line ('******************************' ) ;
         exception
        when NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('----> Harness job not found in user_scheduler_job_running_jobs <----');
      end;


   else
      dbms_output.put_line ('******************************' ) ;
      dbms_output.put_line ('The harness is NOT running') ;
      dbms_output.put_line ('******************************' ) ;

   end if;

exception
   when others then
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1 , 64);
        DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
end;
/

