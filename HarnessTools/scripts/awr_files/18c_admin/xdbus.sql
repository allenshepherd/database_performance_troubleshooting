Rem
Rem $Header: rdbms/admin/xdbus.sql /main/5 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbus.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbus.sql - XDB Upgrade Schemas
Rem
Rem    DESCRIPTION
Rem      This script invokes the script for the release being upgraded
Rem      based on the value of the XDB_VERSION variable.
Rem
Rem    NOTES
Rem      The xdbusNNN.sql scripts are stacked, so that each lower release 
Rem      invokes the script for the next release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbus.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbus.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    hxzhang     06/17/16 - bug#23085530, updates stats of XDB schema tables
Rem    raeburns    08/29/15 - bug 21383178: recompute xdb_version
Rem    raeburns    10/24/13 - upgrade restructure
Rem    raeburns    10/24/13 - Created

Rem ================================================================
Rem BEGIN XDB Schema Upgrades
Rem ================================================================


Rem Load XDB upgrade downgrade utilities (dbms_xdbmig_util)
@@prvtxudu.plb

-- DO NOT REMOVE THESE 6 CALLS
-- Fix corrupted complex type rows from prior releases. 

execute dbms_xdbmig_util.checkSchSchCfgKids;
execute dbms_xdbmig_util.fixSchSchCfgKids;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

execute dbms_xdbmig_util.fixCfgPDs;
execute dbms_xdbmig_util.checkCfgPDs;
execute dbms_xdbmig_util.checkSchSchCfgKids;
commit;

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
      :xdb_file := dbms_registry_server.XDB_path || 'xdbus' || xdb_version; 
   end if;
END;
/

Rem Invoke appropriate upgrade script
SELECT :xdb_file FROM DUAL;
@&xdbfile

Rem Drop dbms_xdbmig_util up/down utility package
@@dbmsxuducu.sql

/* bug#23085530, re-gather stats for XDB$ELEMENT                      */
/* so patchupschema during deleteschema could pick up the right plan  */
BEGIN
 dbms_stats.gather_table_stats('xdb', 'xdb$element');
 EXCEPTION WHEN OTHERS THEN NULL;
END;
/

Rem ================================================================
Rem END XDB Schema Upgrades
Rem ================================================================

