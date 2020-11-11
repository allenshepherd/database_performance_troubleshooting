Rem
Rem $Header: rdbms/admin/xdbustr.sql /main/7 2017/08/25 20:41:45 rtattuku Exp $
Rem
Rem xdbustr.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbustr.sql - XDB Ugrade STaRt script
Rem
Rem    DESCRIPTION
Rem      This script is the initialization script for the XDB upgrade.
Rem      It identifies the release to be upraded and sets the XDB_VERSION 
Rem      PL/SQL variable.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbustr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbustr.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    raeburns    04/08/17 - Change re-run version check for 18.0.0
Rem    qyu         11/16/16 - change for upgrade to 12.2.0.2
Rem    qyu         07/25/16 - add file metadata
Rem    raeburns    08/27/15 - Bug 21383178: remove SQLPLUS variables spanning
Rem                           phases
Rem    raeburns    04/09/14 - add start/end scripts and display version, status
Rem    raeburns    10/20/13 - upgrade restructure
Rem    raeburns    10/20/13 - Created

Rem ===============================================================
Rem BEGIN XDB Upgrade Initialization
Rem ===============================================================

-- Set session _ORACLE_SCRIPT for objects created during upgrade
@?/rdbms/admin/sqlsessstart.sql

Rem Clean up any shared memory taken by JavaVM or anyone else
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Set identifier for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XDB';

Rem Display Start Timestamp
SELECT dbms_registry_sys.time_stamp_display('XDB') AS timestamp FROM DUAL;

Rem Determine current version to be upgraded and store for subsequent phases
SET SERVEROUTPUT ON
DECLARE
  status      varchar2(50);
  version     sys.registry$.version%type;
  ful_version sys.registry$.version%type;
  prv_version sys.registry$.version%type;
  org_version sys.registry$.version%type;
  xdb_version sys.registry$.version%type;

BEGIN
  -- Bypass upgrade if version does not match supported upgrade version
  -- only upgrades from 11.1, 11.2, and 12.1 supported
  xdb_version := 'BYPASS';

  select substr(version,1,6), version, prv_version, org_version, 
         dbms_registry.status('XDB') 
  into version, ful_version, prv_version, org_version, status 
  from registry$ where cid = 'XDB';

  if version = '11.2.0' then
     xdb_version := '112';
  elsif version = '12.1.0' then
     xdb_version := '121';
  elsif version = '12.2.0' then 
     xdb_version := '122';
  else     -- check for rerun
     if substr(ful_version,1,7) = 
        substr(sys.dbms_registry.release_version,1,7) then
        -- current version, so rerun based on previous version
        if substr(prv_version,1,6) = '11.2.0' then
           xdb_version := '112';
        elsif substr(prv_version,1,6) = '12.1.0' then
           xdb_version := '121';
        elsif substr(prv_version,1,6) = '12.2.0' then
           xdb_version := '122';
        end if;
     end if;
  end if;

  -- set version value in registry$progress to preserve for use in subsequent scripts
  sys.dbms_registry.set_progress_value('XDB','VERSION',xdb_version);

  -- display version information
  dbms_output.put_line('XDB_VERSION variable: ' || xdb_version);  
  dbms_output.put_line('Current Status: ' || status);
  dbms_output.put_line('Current Version: ' || ful_version);
  dbms_output.put_line('Previous Version: ' || prv_version);
  dbms_output.put_line('Original Version: ' || org_version);
END;
/
SET SERVEROUTPUT OFF

Rem Set Status as UPGRADING
EXECUTE dbms_registry.upgrading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB');

Rem ===============================================================
Rem END XDB Upgrade Initialization
Rem ===============================================================

