Rem
Rem $Header: rdbms/admin/xrddwgrd.sql /main/4 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xrddwgrd.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrddwgrd.sql - XDB RDBMS Dependent DoWnGRaDe
Rem
Rem    DESCRIPTION
Rem      Downgrades RDBMS objects that are dependent on XDB
Rem
Rem    NOTES
Rem      Add release specific subscripts when and if needed
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrddwgrd.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrddwgrd.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE 
Rem    raeburns    11/15/16 - Bug 25035558: check for NULL xdb_version
Rem    raeburns    11/21/14 - Add per-release downgrade scripts
Rem    raeburns    09/25/14 - XDB RDBMS dependent downgrade
Rem    raeburns    09/25/14 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Downgrade XDB RDBMS Dependents
Rem

VARIABLE xrd_file VARCHAR2(256)
COLUMN :xrd_file NEW_VALUE xrdfile NOPRINT

BEGIN
   if :xdb_version = 'BYPASS' or :xdb_version IS NULL then
      :xrd_file := dbms_registry.nothing_script;
   else
      :xrd_file := dbms_registry_server.XDB_path || 'xrde' || :xdb_version; 
   end if;
END;
/
SELECT :xrd_file FROM DUAL;
@&xrdfile

@?/rdbms/admin/sqlsessend.sql
