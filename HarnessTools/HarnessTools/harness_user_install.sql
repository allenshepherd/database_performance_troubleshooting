set echo off

rem $Header$
rem $Name$      harness_user_install.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem
SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_USER_INSTALL

rem Run this logged in as the user who will be running the SQL Test Harness

rem Create table to hold configuration info and variable definitions
@hconfigt

set echo off

rem Populate configuration information
@hconfig


rem The following section is used to call a version specific
rem script to create a plan_table and to create harness
rem plan_table copies.  You may change the version specific
rem script to remove the plan_table creation if desired
rem prior to executing.

set termout off verify off heading off feed off

rem Determine version for specific install scripts
rem db_ver: 1 digit, db_ver10: 4 digits
@horaver

rem Execute specific plan capture
select case when '&db_ver10' = '102' then '@harness_user_plan_v10r2'
            when '&db_ver10' = '101' then '@harness_user_plan_v10'
            when '&db_ver' = '9' then '@harness_user_plan_v9'
            else '@harness_user_plan_v10r2'
       end as the_exec
  from dual

spool exec.sql
/
spool off

spool harness_user_install.log

@exec
@hrmtempfile exec.sql

set termout on verify off feedback on serveroutput on size 1000000 echo on

spool harness_user_install.log append

rem Create sequence
@hseq

rem Create tables
@hscenario
@hsessparam
@hscenario_sessparam
@hstatt
@hscenario_snap_stat
@hscenario_snap_diff
@hscenario_10046_line
@hscenario_10053_line
@hscenario_statdetail
@hscenario_plans
@hscripts


rem Create procedures
@get_snap_remote
@snap_request
@snap_request_fulfill
@print_table
@hboilraw
@load_trace

set echo on feed on
spool harness_user_install.log append

rem Gather statistics
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HCONFIG', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_10046_LINE', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_10053_LINE', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_SESSPARAM', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_SNAP_STAT', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_SNAP_DIFF', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_STATDETAIL', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSESSPARAM', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_PLAN_TABLE', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_PLANS', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCRIPTS', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSTAT', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);
exec DBMS_STATS.GATHER_TABLE_STATS (user, 'HSCENARIO_V$SQL_ALL', method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);

spool off

set echo off
set feed off
set term on

prompt *****************************************************
prompt See harness_user_install.log for installation details
prompt *****************************************************
prompt

