Rem
Rem $Header: oraolap/src/sql/dbmsawst.sql /main/6 2016/07/28 09:32:05 cchiappa Exp $
Rem
Rem dbmsawst.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsawst.sql - AW statistics package definition
Rem
Rem    DESCRIPTION
Rem      Gathers statistics for AWs, DIMENSIONS & CUBES
Rem
Rem    NOTES
Rem      none
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: olap/src/sql/dbmsawst.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsawst.sql
Rem SQL_PHASE: DBMSAWST
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/olappl.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cchiappa    07/18/16 - Bug#24309417
Rem    cchiappa    03/14/13 - Set _ORACLE_SCRIPT
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ckearney    04/28/08 - add clear
Rem    ckearney    10/12/06 - add mapping to xsanalyze callout
Rem    ckearney    06/05/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_aw_stats AUTHID CURRENT_USER AS

  --
  -- ERROR NUMBERS
  --
  -- Note : DBMS_OUTPUT, DBMS_DESCRIBE and DBMS_AW (maybe others) use
  -- the application error numbers -20001 to -20005 for there own purposes 
  --

  aw_error CONSTANT NUMBER := -20001;

  --
  -- PUBLIC INTERFACE
  --

  PROCEDURE analyze(inName IN VARCHAR2);
  PROCEDURE clear(inName IN VARCHAR2);
END dbms_aw_stats;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_aw_stats FOR sys.dbms_aw_stats
/
GRANT EXECUTE ON dbms_aw_stats TO PUBLIC
/

@@?/rdbms/admin/sqlsessend.sql
