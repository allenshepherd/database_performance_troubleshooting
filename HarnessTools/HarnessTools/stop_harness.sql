set echo off

rem $Header$
rem $Name$          start_harness.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem 14JAN2011 RVD Modified to use DBMS_SCHEDULER instead of DBMS_JOB


set termout on verify off heading off feed off serveroutput on

declare
  v_code   NUMBER;
  v_errm   VARCHAR2(64);
  v_rtn    NUMBER;
  v_job    hconfig.capture_job_no%type;
  v_pipe   hconfig.harness_pipe_name%type;
  v_jname  hconfig.capture_job_name%type;
  l_harness_nm   varchar2(30);

begin
   select capture_job_no, harness_pipe_name, capture_job_name
     into v_job, v_pipe, v_jname
     from hconfig ;
   dbms_output.put_line ('***************************************' ) ;
   dbms_output.put_line ('  Shutting Down Harness Capture Job');
   dbms_output.put_line ('    Pipe: ' || trim(v_pipe) );
   dbms_output.put_line ('    Job#: ' || trim(to_char(v_job))) ;
   dbms_output.put_line ('    Job Name: '|| trim(v_jname));
   dbms_output.put_line ('*** Removing job info from hconfig' ) ;
   update hconfig set capture_job_no = null, harness_pipe_name = null, capture_job_name = null;
   commit ;
    /* Dropping the job completely */
   dbms_output.put_line ('*** Dropping Job' ) ;
   DBMS_SCHEDULER.DROP_JOB (trim(v_jname),true);

   dbms_output.put_line ('***************************************' ) ;
   dbms_output.put_line ('The harness has been STOPPED') ;
   dbms_output.put_line ('***************************************' ) ;

exception
when others then
   update hconfig set capture_job_no = null, harness_pipe_name = null, capture_job_name = null;
   commit ;
   v_code := SQLCODE;
   v_errm := SUBSTR(SQLERRM, 1 , 64);
   DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
   DBMS_SCHEDULER.DROP_JOB (trim(v_jname),true);
   dbms_output.put_line ('*********** Exception handler' ) ;
   dbms_output.put_line ('The harness has been STOPPED') ;
   dbms_output.put_line ('*********** Exception handler' ) ;

end;
/

set term off

rem Reset harness environment
@default.env
@hlogin
