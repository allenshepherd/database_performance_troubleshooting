set echo off

rem $Header$
rem $Name$		harness_dba_privs.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 
rem Some grants are specific to v9 or v10
rem 

define hotsos_dbaharness_user='&1'

rem Required Grants
grant execute on dbms_pipe to &hotsos_dbaharness_user with grant option;
grant execute on dbms_space to &hotsos_dbaharness_user with grant option;
grant select on v_$statname to &hotsos_dbaharness_user with grant option;
grant select on v_$latchname to &hotsos_dbaharness_user with grant option;
grant select on v_$process to &hotsos_dbaharness_user with grant option;
grant select on v_$session to &hotsos_dbaharness_user with grant option;
grant select on v_$instance to &hotsos_dbaharness_user with grant option;
grant select on v_$mystat to &hotsos_dbaharness_user with grant option;
grant select on v_$latch to &hotsos_dbaharness_user with grant option;
grant select on v_$timer to &hotsos_dbaharness_user with grant option;
grant select on v_$sesstat to &hotsos_dbaharness_user with grant option;
grant select on v_$sql_plan to &hotsos_dbaharness_user with grant option;
grant select on v_$sql_plan_statistics to &hotsos_dbaharness_user with grant option;
grant select on v_$sql_plan_statistics_all to &hotsos_dbaharness_user with grant option;
grant select on v_$session_wait to &hotsos_dbaharness_user with grant option;
grant select on v_$session_event to &hotsos_dbaharness_user with grant option;
grant select on v_$sql to &hotsos_dbaharness_user with grant option;
grant select on v_$sql_shared_cursor to &hotsos_dbaharness_user with grant option;
grant select on v_$sqltext to &hotsos_dbaharness_user with grant option;
grant select on v_$sqltext_with_newlines to &hotsos_dbaharness_user with grant option;
grant select on v_$sqlarea to &hotsos_dbaharness_user with grant option;
grant select on v_$sql_workarea to &hotsos_dbaharness_user with grant option;
grant select on v_$parameter to &hotsos_dbaharness_user with grant option;

undefine hotsos_dbaharness_user
