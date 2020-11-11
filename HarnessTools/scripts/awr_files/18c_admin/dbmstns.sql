Rem
Rem $Header: rdbms/admin/dbmstns.sql /main/3 2017/09/25 01:53:17 sshringa Exp $
Rem
Rem dbmstns.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstns.sql - Packages for TNS
Rem
Rem    DESCRIPTION
Rem      Declare packages and Procedures for TNS
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmstns.sql 
Rem    SQL_SHIPPED_FILE:rdbms/admin/dbmstns.sql
Rem    SQL_PHASE: DBMSTNS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    rajeekku    11/06/15 - Bug 21795431: Missing public synonym for dbms_tns
Rem    rajeekku    01/19/15 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql



CREATE OR REPLACE PACKAGE dbms_tns AS

FUNCTION resolve_tnsname ( tns_name IN VARCHAR2) RETURN VARCHAR2;

END dbms_tns;
/

SHOW ERRORS;

CREATE OR REPLACE PUBLIC SYNONYM dbms_tns for sys.dbms_tns;
/
GRANT EXECUTE ON dbms_tns to DBA;
/
@?/rdbms/admin/sqlsessend.sql
