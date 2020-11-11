Rem
Rem $Header: rdbms/admin/dbmshmgr.sql /main/4 2017/09/25 01:53:16 sshringa Exp $
Rem
Rem dbmshmgr.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshmgr.sql - dbms_hang_manager PL/SQL package
Rem
Rem    DESCRIPTION
Rem      With this package, the user is allowed to update Oracle Hang Manager
Rem      parameters.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    cqi         06/19/15 - change sensitivity levels
Rem    cqi         01/08/15 - fix bug 20327985: get rid of 'get' routine
Rem    cqi         07/03/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmshmgr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmshmgr.sql
Rem    SQL_PHASE: DBMSHMGR 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql 
Rem    END SQL_FILE_METADATA

@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE LIBRARY dbms_hang_manager_lib TRUSTED IS STATIC;
/

CREATE OR REPLACE PACKAGE dbms_hang_manager AS

  -- parameter names
  RESOLUTION_SCOPE           CONSTANT VARCHAR2(40) := 'resolution scope';
  SENSITIVITY                CONSTANt VARCHAR2(40) := 'sensitivity';
  BASE_FILE_SIZE_LIMIT       CONSTANT VARCHAR2(40) := 'base file size limit';
  BASE_FILE_SET_COUNT        CONSTANT VARCHAR2(40) := 'base file set count';
  LWS_FILE_SIZE_LIMIT
      CONSTANT VARCHAR2(40) := 'long waiting session file size limit';
  LWS_FILE_SET_COUNT
      CONSTANT VARCHAR2(40) := 'long waiting session file set count';

  -- resolution scope values
  RESOLUTION_SCOPE_OFF       CONSTANT VARCHAR2(20) := 'OFF';
  RESOLUTION_SCOPE_PROCESS   CONSTANT VARCHAR2(20) := 'PROCESS';
  RESOLUTION_SCOPE_INSTANCE  CONSTANT VARCHAR2(20) := 'INSTANCE';

  -- sensitivity values
  SENSITIVITY_NORMAL         CONSTANT VARCHAR2(20) := 'NORMAL';
  SENSITIVITY_HIGH           CONSTANT VARCHAR2(20) := 'HIGH';

  PROCEDURE set(pname IN VARCHAR2, pvalue IN VARCHAR2);

  -- Error code for invalid user input
  errnum_input_error                CONSTANT NUMBER := -32706;

  -- Error code when DB experiences errors when setting/retrieving a parameter
  errnum_internal_error             CONSTANT NUMBER := -32707;

  -- Error code for unsupported instance types
  errnum_unsupported_error          CONSTANT NUMBER := -32708;

  exception_input_error             EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception_input_error,         -32706);
  exception_internal_error          EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception_internal_error,      -32707);
  exception_unsupported_error       EXCEPTION;
  PRAGMA EXCEPTION_INIT(exception_unsupported_error,   -32708);

END dbms_hang_manager;
/

SHOW ERRORS;

-- Grant execution only to DBA role
GRANT EXECUTE ON dbms_hang_manager TO DBA
/
@?/rdbms/admin/sqlsessend.sql

