set echo off

rem $Header$
rem $Name$          chk_harness.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

set termout on verify off heading off feed off serveroutput on


declare
   v_job    hconfig.capture_job_no%type;
   v_pipe   hconfig.harness_pipe_name%type;

   v_sid        v$session.sid%type;
   v_serial#    v$session.serial#%type;
   v_program    v$session.program%type;
   v_module     v$session.module%type;
   v_action     v$session.action%type;

begin
   select capture_job_no, harness_pipe_name
     into v_job, v_pipe
     from hconfig ;

   if v_pipe is not null then
      dbms_output.put_line ('******************************' ) ;
      dbms_output.put_line ('The harness is running') ;
      dbms_output.put_line ('Harness Pipe Name   : ' || trim(v_pipe)) ;
      dbms_output.put_line ('Capture Session Job#: ' || trim(to_char(v_job)) ) ;

      select sid, serial#, program, module, action
        into v_sid, v_serial#, v_program, v_module, v_action
        from v$session
       where username = user
         and module = 'Hotsos Test Harness';

      dbms_output.put_line ('******************************' ) ;
      dbms_output.put_line ('Harness Capture Session Info ' ) ;
      dbms_output.put_line ('SID    : ' || v_sid ) ;
      dbms_output.put_line ('Serial#: ' || v_serial#) ;
      dbms_output.put_line ('Program: ' || v_program) ;
      dbms_output.put_line ('Module : ' || v_module) ;
      dbms_output.put_line ('Action : ' || v_action) ;
      dbms_output.put_line ('******************************' ) ;
   else
      dbms_output.put_line ('******************************' ) ;
      dbms_output.put_line ('The harness is NOT running') ;
--      dbms_output.put_line ('Execute @start_harness to activate the harness') ;
      dbms_output.put_line ('******************************' ) ;

   end if;

exception
   when others then null;
end;
/

