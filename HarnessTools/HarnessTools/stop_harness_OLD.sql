set echo off

rem $Header$
rem $Name$          start_harness.sql

rem Copyright (c); 2005-2007 by Hotsos Enterprises, Ltd.
rem

set termout on verify off heading off feed off serveroutput on

declare
   v_pipe   varchar2(30) ;
   v_job    number       ;
begin
   select capture_job_no, harness_pipe_name
     into v_job, v_pipe
     from hconfig ;

   dbms_output.put_line ('Shutting down harness: ' || trim(v_pipe) || ' Job#: ' || trim(to_char(v_job))) ;

   dbms_job.remove(v_job);
   snap_request(0,0,0,'Y',v_pipe);

   dbms_output.put_line ('***************************************' ) ;
   dbms_output.put_line ('The harness has been STOPPED') ;

   update hconfig set capture_job_no = null, harness_pipe_name = null;
   commit ;

   dbms_output.put_line ('***************************************' ) ;

exception
when others then
   update hconfig set capture_job_no = null, harness_pipe_name = null;
   commit ;
   dbms_output.put_line ('***************************************' ) ;
   dbms_output.put_line ('The harness has been STOPPED') ;
   dbms_output.put_line ('***************************************' ) ;

end;
/

set term off

rem Reset harness environment
--@hrmtempfile *.lst

@default.env

@hlogin
