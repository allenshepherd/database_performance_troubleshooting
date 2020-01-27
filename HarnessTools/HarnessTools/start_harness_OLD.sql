set echo off
set term off

store set default.env replace
prompt

rem $Header$
rem $Name$          start_harness.sql

rem Copyright (c); 2005-2007 by Hotsos Enterprises, Ltd.
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
accept htst_pipename prompt 'This name should be less than 10 characters in length: '

set termout on
set serveroutput on

rem Turn on capturing session by submitting background job to open the pipe
declare
  j             number := 1;
  p             varchar2(30) := '&htst_pipename';
  job_string    varchar2(200) ;
  v_sid         v$session.sid%type;
  v_serial#     v$session.serial#%type;
  v_program     v$session.program%type;
  v_module      v$session.module%type;
  v_action      v$session.action%type;
begin
  job_string := 'begin  snap_request_fulfill(''&htst_pipename'')';
  job_string := job_string || ';  end;' ;
  dbms_job.submit(j,job_string);
  commit ;
  update hconfig set capture_job_no = j, harness_pipe_name = p;
  commit ;

  dbms_output.put_line ('*************************************************' ) ;
  dbms_output.put_line ('The harness has been STARTED') ;
  dbms_output.put_line ('Harness pipe name: ' || trim(p) || ' Job#: ' || trim(to_char(j))) ;
  dbms_output.put_line ('*************************************************' ) ;

  -- Wait for a few seconds to allow the job to start.
  dbms_lock.sleep(4);

exception
   when others then
        dbms_output.put_line('Unexpected error occurred!  Run @chk_harness to verify harness startup.');
        raise;
end;
/

@hrmtempfile exec_config.lst

@chk_harness

rem Set harness environment
@hlogin
