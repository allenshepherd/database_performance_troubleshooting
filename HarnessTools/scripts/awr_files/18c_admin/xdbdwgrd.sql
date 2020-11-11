Rem
Rem $Header: rdbms/admin/xdbdwgrd.sql /main/4 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbdwgrd.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbdwgrd.sql - XDB DoWnGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB from the current release to
Rem      the release from which the DB was upgraded.
Rem
Rem    NOTES
Rem      It is invoked by cmpdwgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cmpdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         11/10/16 - downgrade to 12.2.0
Rem    raeburns    12/15/14 - xrddwgrd.sql after version set
Rem    raeburns    09/02/14 - XDB downgrade script
Rem    raeburns    09/02/14 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

VARIABLE xdb_version VARCHAR2(256)
VARIABLE xdb_file VARCHAR2(256)
COLUMN :xdb_file NEW_VALUE xdbfile NOPRINT

Rem
Rem Determine the correct script to run
Rem

DECLARE
  p_prv_version sys.registry$.prv_version%type;
BEGIN
  :xdb_file := dbms_registry.nothing_script;

  -- Get the previous version of the CATPROC component
  SELECT prv_version INTO p_prv_version
  FROM registry$ WHERE cid='XDB';

  IF p_prv_version IS NULL THEN      -- XDB was installed during the upgrade
     :xdb_file := dbms_registry_server.XDB_path || 'prvtnoqm.plb';
     :xdb_version := 'BYPASS';
  ELSIF substr(p_prv_version, 1, 6) = '11.2.0' THEN
     :xdb_file := dbms_registry_server.XDB_path || 'xdbe112.sql';
     :xdb_version := '112';
  ELSIF substr(p_prv_version, 1, 6) = '12.1.0' THEN
     :xdb_file := dbms_registry_server.XDB_path || 'xdbe121.sql';
     :xdb_version := '121';
  ELSIF substr(p_prv_version, 1, 6) = '12.2.0' THEN
     :xdb_file := dbms_registry_server.XDB_path || 'xdbe122.sql';
     :xdb_version := '122';
  END IF;

END;
/

Rem Downgrade XDB RDBMS Dependents first
Rem Uses xdb_version variable to identify the xrd script
@@xrddwgrd.sql

Rem Invoke appropriate XDB downgrade script
SELECT :xdb_file FROM DUAL;
@&xdbfile

@?/rdbms/admin/sqlsessend.sql
