Rem
Rem $Header: rdbms/admin/dvdwgrd.sql /main/2 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dvdwgrd.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvdwgrd.sql - Database Vault Downgrade script
Rem
Rem    DESCRIPTION
Rem      This script performs downgrade of Database Vault from the
Rem      current release to the release from which the DB was upgraded.
Rem
Rem    NOTES
Rem      It is invoked by cmpdwgrd.sql.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dvdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dvdwgrd.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/cmpdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    jibyun      11/09/16 - Bug 25035115: Creation of Database Vault
Rem                           downgrade script
Rem    jibyun      11/09/16 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE sys.dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

EXECUTE sys.dbms_registry.downgrading('DV');

Rem Setup component script filename variable
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(100)

Rem Select downgrade script to run based on previous component version
DECLARE
  prv_version varchar2(100);
BEGIN
  prv_version := substr(sys.dbms_registry.prev_version('DV'), 1, 6);

  IF prv_version = '11.2.0' THEN
    :script_name := 'dve112.sql';
  ELSIF prv_version = '12.1.0' THEN
    :script_name := 'dve121.sql';
  ELSIF prv_version = '12.2.0' THEN
    :script_name := 'dve122.sql';
  ELSE
    :script_name := sys.dbms_registry.nothing_script;
  END IF;
END;
/

@@?/rdbms/admin/sqlsessstart.sql
SELECT :script_name FROM SYS.DUAL;
@@&comp_file
@?/rdbms/admin/sqlsessend.sql
 
