Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem  NAME
Rem    catcon_kill_sess_gen.sql - Script to generate ALTER SYSTEM KILL SESSION 
Rem                               scripts
Rem
Rem  DESCRIPTION:
Rem    If a user terminates catcon session, we need to gracefully kill 
Rem    SQL*Plus processes that were spawned by it by issuing 
Rem    ALTER SYSTEM KILL SESSION statements.  These statements will be 
Rem    generated by getting each process to run this script
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catcon_kill_sess_gen.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catcon_kill_sess_gen.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    akruglik    11/08/16 - Bug 25061922: use force timeout 0 only for
Rem                           post-12.1 databases
Rem    jaeblee     08/15/16 - 24429978: use "force" with timeout 0 instead of
Rem                           "immediate"
Rem    akruglik    07/07/16 - Created
Rem

set echo off
set heading off
set verify off
spool &&1 append
select distinct 'ALTER SYSTEM KILL SESSION ''' || stat.sid || ',' || 
                sess.serial# || 
                decode(substr(inst.version, 1, 4), 
                         '12.1', ''' immediate ', ''' force timeout 0 ') || 
                '-- process &&2'
  from v$mystat stat, v$session sess, v$instance inst 
  where stat.sid=sess.sid
union all
select '/' from dual;
spool off
set verify on
set heading on
