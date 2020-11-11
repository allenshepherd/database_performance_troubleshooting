Rem
Rem $Header: rdbms/admin/xdbuo.sql /st_rdbms_18.0/1 2017/11/30 19:31:09 luisgarc Exp $
Rem
Rem xdbuo.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuo.sql - XDB Upgrade RDBMS Objects
Rem
Rem    DESCRIPTION
Rem      This script invokes the script for the release being upgraded
Rem      based on the value of the XDB_VERSION variable.
Rem
Rem    NOTES
Rem      The xdbuoNNN.sql scripts are stacked, so that each lower release 
Rem      invokes the script for the next release.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    luisgarc    11/28/17 - Bug 26650540: Mark XDB$RESOURCE_T as local in
Rem                           a PDB if there is a signature mismatch with ROOT
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    08/29/15 - bug 21383178: recompute xdb_version
Rem    raeburns    10/24/13 - upgrade restructure
Rem    raeburns    10/24/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuo.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuo.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade
Rem ================================================================

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
      :xdb_file := dbms_registry_server.XDB_path || 'xdbuo' || xdb_version; 
   end if;
END;
/

Rem Invoke appropriate upgrade script
SELECT :xdb_file FROM DUAL;
@&xdbfile

-- If we upgraded a PDB, XDB$RESOURCE_T can have a signature mismatch with the
-- ROOT, if that is the case convert the type to local. This check is not in
-- a xdbuoNNN script because the ROOT is upgraded first and then the PDBs.
-- We need to check for a signature mismatch once the XDB objects upgrade is
-- completed so we don't catch the mismatch too early.
begin                                                                        
 sys.dbms_pdb.convert_to_local('XDB', 'XDB$RESOURCE_T', 1, null, TRUE);      
 end;                                                                         
 /                                                                            
Rem ================================================================
Rem END XDB RDBMS Object Upgrade
Rem ================================================================

