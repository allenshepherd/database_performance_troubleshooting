set echo off

rem $Header$
rem $Name$      harness_grant_privs.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
rem Some grants are specific to v9 or v10
rem

SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_GRANT_PRIVS

define hotsos_testharness_user='&1'


rem Required Grants
grant execute on dbms_support to &hotsos_testharness_user;
grant execute on dbms_monitor to &hotsos_testharness_user;
grant execute on dbms_pipe to &hotsos_testharness_user;
grant execute on dbms_space to &hotsos_testharness_user;
grant execute on dbms_lock to &hotsos_testharness_user;
grant execute on hotsos_pkg to &hotsos_testharness_user;

grant read on directory udump_dir to &hotsos_testharness_user;

grant create session to &hotsos_testharness_user;
grant alter session to &hotsos_testharness_user;
grant create table to &hotsos_testharness_user;
grant create view to &hotsos_testharness_user;
grant create trigger to &hotsos_testharness_user;
grant create type to &hotsos_testharness_user;
grant create procedure to &hotsos_testharness_user;
grant create sequence to &hotsos_testharness_user;
grant select on sys.v_$statname to &hotsos_testharness_user;
grant select on sys.v_$latchname to &hotsos_testharness_user;
grant select on sys.v_$process to &hotsos_testharness_user;
grant select on sys.v_$session to &hotsos_testharness_user;
grant select on sys.v_$instance to &hotsos_testharness_user;
grant select on sys.v_$mystat to &hotsos_testharness_user;
grant select on sys.v_$latch to &hotsos_testharness_user;
grant select on sys.v_$timer to &hotsos_testharness_user;
grant select on sys.v_$sesstat to &hotsos_testharness_user;
grant select on sys.v_$sql_plan to &hotsos_testharness_user;
grant select on sys.v_$sql_plan_statistics to &hotsos_testharness_user;
grant select on sys.v_$sql_plan_statistics_all to &hotsos_testharness_user;
grant select on sys.v_$session_wait to &hotsos_testharness_user;
grant select on sys.v_$session_event to &hotsos_testharness_user;
grant select on sys.v_$sql to &hotsos_testharness_user;
grant select on sys.v_$sql_shared_cursor to &hotsos_testharness_user;
grant select on sys.v_$sqltext to &hotsos_testharness_user;
grant select on sys.v_$sqltext_with_newlines to &hotsos_testharness_user;
grant select on sys.v_$sqlarea to &hotsos_testharness_user;
grant select on sys.v_$sql_workarea to &hotsos_testharness_user;
grant select on sys.v_$parameter to &hotsos_testharness_user;
