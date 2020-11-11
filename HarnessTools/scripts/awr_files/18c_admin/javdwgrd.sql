Rem
Rem $Header: rdbms/admin/javdwgrd.sql /main/2 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem javdwgrd.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      javdwgrd.sql - catJAVa DoWnGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script performs downgrade of CATJAVA from the
Rem      current release to the release from which the DB was upgraded.
Rem
Rem    NOTES
Rem      It is invoked by cmpdwgrd.sql.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/javdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/javdwgrd.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/cmpdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE 
Rem    welin       11/09/16 - Bug 25035541: Creation of CATJAVA downgrade
Rem                           script
Rem    welin       11/09/16 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE sys.dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
SET ERRORLOGGING ON IDENTIFIER 'CATJAVA';
SELECT sys.dbms_registry_sys.time_stamp_display('CATJAVA')
       AS timestamp FROM SYS.DUAL;


Rem Setup component script filename variable
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(100)

Rem Select downgrade script to run based on previous component version
DECLARE
  prv_version varchar2(100);
BEGIN
  prv_version := substr(sys.dbms_registry.prev_version('CATJAVA'), 1, 6);

  IF prv_version = '11.2.0' THEN
    :script_name := 'jave112.sql';
  ELSIF prv_version = '12.1.0' THEN
    :script_name := 'jave121.sql';
  ELSIF prv_version = '12.2.0' THEN
    :script_name := 'jave122.sql';
  ELSE
    :script_name := sys.dbms_registry.nothing_script;
  END IF;
END;
/

@@?/rdbms/admin/sqlsessstart.sql
SELECT :script_name FROM SYS.DUAL;
@@&comp_file
@?/rdbms/admin/sqlsessend.sql
 
 
