set echo off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem

SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_REVOKE_PRIVS

define hotsos_testharness_user='&1'

revoke select on v_$statname from &hotsos_testharness_user;
revoke select on v_$latchname from &hotsos_testharness_user;
revoke select on v_$process from &hotsos_testharness_user;
revoke select on v_$session from &hotsos_testharness_user;
revoke select on v_$instance from &hotsos_testharness_user;
revoke select on v_$mystat from &hotsos_testharness_user;
revoke select on v_$latch from &hotsos_testharness_user;
revoke select on v_$timer from &hotsos_testharness_user;
revoke select on v_$sesstat from &hotsos_testharness_user;
revoke select on v_$sql_plan from &hotsos_testharness_user;
revoke select on v_$sql_plan_statistics from &hotsos_testharness_user;
revoke select on v_$sql_plan_statistics_all from &hotsos_testharness_user;
revoke select on v_$session_wait from &hotsos_testharness_user;
revoke select on v_$session_event from &hotsos_testharness_user;
revoke select on v_$sql from &hotsos_testharness_user;
revoke select on v_$sql_shared_cursor from &hotsos_testharness_user;
revoke select on v_$sqltext from &hotsos_testharness_user;
revoke select on v_$sqltext_with_newlines from &hotsos_testharness_user;
revoke select on v_$sqlarea from &hotsos_testharness_user;
revoke select on v_$sql_workarea from &hotsos_testharness_user;
revoke select on v_$parameter from &hotsos_testharness_user;

revoke execute on dbms_support from &hotsos_testharness_user;
revoke execute on dbms_monitor from &hotsos_testharness_user;
revoke execute on dbms_pipe from &hotsos_testharness_user;
revoke execute on dbms_space from &hotsos_testharness_user;
revoke execute on dbms_lock from &hotsos_testharness_user;
revoke execute on hotsos_pkg from &hotsos_testharness_user;

