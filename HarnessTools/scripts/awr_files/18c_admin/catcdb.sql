Rem
Rem $Header: rdbms/admin/catcdb.sql /main/8 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem catcdb.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcdb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      invoke catcdb.pl
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    PARAMETERS:
Rem      - log directory
Rem      - base for log file name
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catcdb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catcdb.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    akruglik    06/21/16 - Bug 22752041: pass --logDirectory and 
Rem                           --logFilename to catcdb.pl
Rem    akruglik    11/10/15 - use catcdb.pl to collect passowrds and pass them
Rem                           on to catcdb_int.sql using env vars
Rem    aketkar     04/30/14 - remove SQL file metadata
Rem    cxie        07/10/13 - 17033183: add shipped_file metadata
Rem    cxie        03/19/13 - create CDB with all options installed
Rem    cxie        03/19/13 - Created
Rem

set echo on

Rem The script relies on the caller to have connected to the DB

Rem This script invokes catcdb.pl that does all the work, so we just need to 
Rem construct strings for $ORACLE_HOME/rdbms/admin and 
Rem $ORACLE_HOME/rdbms/admin/catcdb.pl

Rem $ORACLE_HOME
column oracle_home new_value oracle_home noprint
select sys_context('userenv', 'oracle_home') as oracle_home from dual;

Rem OS-dependent slash
column slash new_value slash noprint
select sys_context('userenv', 'platform_slash') as slash from dual;

Rem $ORACLE_HOME/rdbms/admin
column rdbms_admin new_value rdbms_admin noprint
select '&&oracle_home'||'&&slash'||'rdbms'||'&&slash'||'admin' as rdbms_admin from dual;

Rem $ORACLE_HOME/rdbms/admin/catcdb.pl
column rdbms_admin_catcdb new_value rdbms_admin_catcdb noprint
select '&&rdbms_admin'||'&&slash'||'catcdb.pl' as rdbms_admin_catcdb from dual;

host perl -I &&rdbms_admin &&rdbms_admin_catcdb --logDirectory &&1 --logFilename &&2
