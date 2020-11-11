Rem
Rem $Header: rdbms/admin/xrde112.sql /main/3 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xrde112.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrde112.sql - XDB RDBMS Dependents Downgrade to 11.2
Rem
Rem    DESCRIPTION
Rem      This script contains action for downgrading to 11.2
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrde112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrde112.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrddwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    amunnoli    09/12/16 - Bug 24626291:Ignore exceptions for TSDP XML 
Rem                           schema deletion
Rem    raeburns    11/21/14 - XRD release-specific script
Rem    raeburns    11/21/14 - Created
Rem

Rem ========================================================================
Rem Downgrade from subsequent releases
Rem ========================================================================

@@xrde121.sql

Rem ========================================================================
Rem BEGIN Downgrade to 11.2
Rem ========================================================================

Rem ====================================
Rem BEGIN TSDP changes
Rem ====================================

-- Bug 24626291: Ignore the exception ORA-31000 while deleting the TSDP
-- XML schemas because we might have dropped these schemas during downgrade
-- to 12.1DB
DECLARE
  schema_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_not_exists,-31000);
BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
                 'http://xmlns.oracle.com/sdm/sensitivedata_12_1.xsd',
                 DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXCEPTION
  WHEN schema_not_exists THEN
    NULL;
END;
/

DECLARE
  schema_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_not_exists,-31000);
BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
                 'http://xmlns.oracle.com/sdm/sensitivetypes_12_1.xsd',
                 DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXCEPTION
  WHEN schema_not_exists THEN
    NULL;
END;
/

Rem ====================================
Rem END TSDP changes
Rem ====================================

Rem ========================================================================
Rem END Downgrade to 11.2
Rem ========================================================================


