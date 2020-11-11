Rem
Rem $Header: rdbms/admin/xdbud.sql /main/7 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbud.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbud.sql - XDB Upgrade Dependent Objects
Rem
Rem    DESCRIPTION
Rem      This script invokes the script for the release being upgraded
Rem      based on the value of the XDB_VERSION variable.
Rem
Rem    NOTES
Rem      The xdbudNNN.sql scripts are stacked, so that each lower release 
Rem      invokes the script for the next release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbud.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbud.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    08/27/15 - Bug 21383178: remove SQLPLUS variables spanning
Rem                           phases
Rem    raeburns    10/05/14 - move XS upgrade to be conditional on BYPASS
Rem    raeburns    04/13/14 - remove flushsession
Rem    raeburns    04/09/14 - add start/end scripts
Rem    raeburns    02/02/14 - rename script
Rem    raeburns    10/24/13 - upgrade restructure
Rem    raeburns    10/24/13 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Dependent Objects Upgrade
Rem ================================================================

-- Set session _ORACLE_SCRIPT for objects created during upgrade
@?/rdbms/admin/sqlsessstart.sql

Rem Clear XDB SGA so that any schema upgrade actions from prior scripts will be 
Rem re-initialized in SGA

-- exec xdb.dbms_xdbutil_int.flushsession;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

-- Define SQLPLUS variables
VARIABLE xdb_file VARCHAR2(256)
COLUMN :xdb_file NEW_VALUE xdbfile NOPRINT

-- Use progress value (set in xdbustr.sql) to set SQLPLUS variable
DECLARE
   xdb_version varchar2(10);
BEGIN
   xdb_version := sys.dbms_registry.get_progress_value('XDB','VERSION');
   if xdb_version = 'BYPASS' then
      :xdb_file := dbms_registry.nothing_script;
   else
      :xdb_file := dbms_registry_server.XDB_path || 'xdbud' || xdb_version; 
   end if;
END;
/

Rem Invoke appropriate upgrade script
SELECT :xdb_file FROM DUAL;
@&xdbfile

-- Upgrade Fusion Security after XDB is fully upgraded
-- Needed until upgrades from 11.2 are no longer supported

DECLARE
   xdb_version varchar2(10);
BEGIN
   xdb_version := sys.dbms_registry.get_progress_value('XDB','VERSION');
   if xdb_version = 'BYPASS' then
      :xdb_file := dbms_registry.nothing_script;
   else
      :xdb_file := dbms_registry_server.XDB_path || 'xsdbmig.sql';
   end if;
END;
/

Rem Invoke appropriate XS script
SELECT :xdb_file FROM DUAL;
@&xdbfile

-- Reset session _ORACLE_SCRIPT 
@?/rdbms/admin/sqlsessend.sql

Rem ================================================================
Rem END XDB Dependent Objects Upgrade
Rem ================================================================

