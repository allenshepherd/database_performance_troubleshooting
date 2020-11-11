Rem
Rem $Header: rdbms/admin/xrdupgrd.sql /main/5 2017/04/04 09:12:45 raeburns Exp $
Rem
Rem xrdupgrd.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdupgrd.sql - XDB RDBMS Dependents UPGRaDe
Rem
Rem    DESCRIPTION
Rem      This script upgrades RDBMS features that depend on XDB
Rem
Rem    NOTES
Rem      It is run as part of the XDB upgrade, after the XDB upgrade completes.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdupgrd.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdupgrd.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE UPGRADE
Rem    raeburns    09/03/15 - Bug 21383178: remove SQLPLUS variables spanning
Rem                           phases
Rem    raeburns    11/21/14 - Bug 18747400: upgrade to annotated XML schema
Rem    raeburns    09/02/14 - Upgrade XDB RDMS Dependents
Rem    raeburns    09/02/14 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

VARIABLE xrd_file VARCHAR2(256)
COLUMN :xrd_file NEW_VALUE xrdfile NOPRINT

-- Use progress value (set in xdbustr.sql) to set SQLPLUS variable
DECLARE
   xdb_version varchar2(10);
BEGIN
   xdb_version := sys.dbms_registry.get_progress_value('XDB','VERSION');
   if xdb_version = 'BYPASS' then
      :xrd_file := dbms_registry.nothing_script;
   else
      :xrd_file := dbms_registry_server.XDB_path || 'xrdu' || xdb_version; 
   end if;
END;
/

-- Upgrade Actions needed before catxrd.sql is run (xrduNNN.sql)
SELECT :xrd_file FROM DUAL;
@&xrdfile

Rem Run the XDB RDBMS Dependents load script
@@catxrd.sql

-- Need to run start script - will be left OFF after catxrd.sql
@?/rdbms/admin/sqlsessstart.sql

-- Use progress value (set in xdbustr.sql) to set SQLPLUS variable
DECLARE
   xdb_version varchar2(10);
BEGIN
   xdb_version := sys.dbms_registry.get_progress_value('XDB','VERSION');
   if xdb_version = 'BYPASS' then
      :xrd_file := dbms_registry.nothing_script;
   else
      :xrd_file := dbms_registry_server.XDB_path || 'xrdud' || xdb_version; 
   end if;
END;
/

-- Upgrade Actions needed after catxrd.sql is run (xrdudNNN.sql)
SELECT :xrd_file FROM DUAL;
@&xrdfile

@?/rdbms/admin/sqlsessend.sql
