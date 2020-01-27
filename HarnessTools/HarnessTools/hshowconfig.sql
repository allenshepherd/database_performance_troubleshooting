set echo off

rem $Header$
rem $Name$      hshowconfig.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem

set echo off
set termout off

col harness_user    new_value hotsos_testharness_user
col harness_pswd    new_value hotsos_testharness_passwd
col db_instance     new_value hotsos_testharness_instance
col editor          new_value _editor
col rm_cmd          new_value _rm
col host_cmd        new_value _hst
col capture_job_no  new_value htst_job
col harness_pipe_name new_value htst_pipename

select harness_user, harness_pswd, db_instance, editor, rm_cmd, host_cmd, capture_job_no, harness_pipe_name
  from hconfig ;

col udump new_value udump
col spid  new_value my_spid
col  sid  new_value my_sid
col  ser  new_value my_ser
col myid  new_value my_id

select value udump from v$parameter where name='user_dump_dest';

select p.spid, s.sid, s.serial# ser, s.sid || '_' || s.serial# myid
  from sys.v_$process p, sys.v_$session s
 where s.paddr = p.addr
   and s.sid = (select sid from sys.v_$mystat where rownum = 1);

set termout on
set serveroutput on
begin
  dbms_output.put_line ('========================================') ;
  dbms_output.put_line ('Harness User          : ' || '&hotsos_testharness_user') ;
  dbms_output.put_line ('Harness User Password : ' || '&hotsos_testharness_passwd') ;
  dbms_output.put_line ('Database Instance     : ' || '&hotsos_testharness_instance') ;
  dbms_output.put_line ('SQL*Plus HOST command : ' || '&_hst') ;
  dbms_output.put_line ('OS erase command      : ' || '&_rm') ;
  dbms_output.put_line ('Preferred Editor      : ' || '&_editor') ;
  dbms_output.put_line ('========================================') ;
end;
/

@chk_harness

clear columns

@henv
