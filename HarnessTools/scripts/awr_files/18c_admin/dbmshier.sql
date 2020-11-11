Rem
Rem $Header: rdbms/admin/dbmshier.sql /main/14 2017/09/25 01:53:16 sshringa Exp $
Rem
Rem dbmshier.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshier.sql - create the DBMS_HIERARCHY package
Rem
Rem    DESCRIPTION
Rem      create the DBMS_HIERARCHY package
Rem
Rem    NOTES
Rem      create the DBMS_HIERARCHY package
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    mstasiew    12/15/16 - Bug 24906682: is_numeric function
Rem    dmiramon    09/06/16 - Bug 23562823 Add column length error
Rem    mstasiew    06/16/16 - Bug 23017574: get_mv_sql_for_av_cache
Rem    mstasiew    05/31/16 - Bug 23494396: default to current user
Rem    mstasiew    01/07/16 - create_validate_log_table default owner
Rem    sfeinste    12/04/15 - Remove create_time_hier
Rem    mstasiew    11/12/15 - Bug 22195654: rename validate_cube analytic_view
Rem    mstasiew    08/21/15 - signal error for validate_check_success mismatch
Rem    mstasiew    07/27/15 - Bug 21510089 validate_hier return log_number,
Rem                           add VALIDATE_HIERARCHY_SUCCESS
Rem    mstasiew    07/23/15 - add validate_cube
Rem    sfeinste    04/14/15 - Remove dbms_hierarchy_log
Rem    mstasiew    04/01/15 - Bug 20785858 validate_hierarchy def to cur user
Rem    sfeinste    11/05/14 - Remove dbms_hierarchy.get_hier[_cube]_sql
Rem    sfeinste    09/15/14 - Rename MDS -> HCS
Rem    mstasiew    04/23/14 - add temporary logging table
Rem    sfeinste    03/07/14 - Remove get_unique_id
Rem    sfeinste    03/04/14 - Add get_unique_id
Rem    sfeinste    02/03/14 - Add get_hier_sql and get_hier_cube_sql
Rem    mstasiew    10/17/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/src/server/mds/admin/dbmshier.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: DBMSHIER
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE LIBRARY DBMS_HCS_LIB TRUSTED AS STATIC
/

-- define package interface
CREATE OR REPLACE PACKAGE dbms_hierarchy AUTHID CURRENT_USER IS

  -- Constants used for upgrade log table
  VERSION_12_2_0_1 CONSTANT NUMBER := 1;
  VERSION_12_2_0_2 CONSTANT NUMBER := 2;
  VERSION_NONE     CONSTANT NUMBER := 3;
  VERSION_LATEST   CONSTANT NUMBER := VERSION_12_2_0_2;

  TABLE_DOES_NOT_EXIST EXCEPTION;
       PRAGMA EXCEPTION_INIT(TABLE_DOES_NOT_EXIST, -942);
  NAME_ALREADY_USED EXCEPTION;
      PRAGMA EXCEPTION_INIT(NAME_ALREADY_USED, -955);
  MISMATCH_OBJ_LOGNUM EXCEPTION;
      PRAGMA EXCEPTION_INIT(MISMATCH_OBJ_LOGNUM, -18263);
  MISMATCH_COL_LENGTH EXCEPTION;
      PRAGMA EXCEPTION_INIT(MISMATCH_COL_LENGTH, -18275);
  LOG_TABLE_UPGRADE EXCEPTION;
      PRAGMA EXCEPTION_INIT(LOG_TABLE_UPGRADE, -18276);

  PROCEDURE upgrade_validate_log_table(
    table_name           IN VARCHAR2,
    owner_name           IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'));

  PROCEDURE create_validate_log_table (
    table_name           IN VARCHAR2, 
    owner_name           IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'),
    ignore_if_exists     IN BOOLEAN DEFAULT FALSE);

  FUNCTION validate_hierarchy (
    hier_name	 	 IN VARCHAR2,
    hier_owner_name	 IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'),
    log_table_name	 IN VARCHAR2 DEFAULT NULL,
    log_table_owner_name IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'))
  RETURN NUMBER;

  FUNCTION VALIDATE_CHECK_SUCCESS(
    topobj_name IN VARCHAR2,
    topobj_owner IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER'),
    log_number IN NUMBER,
    log_table_name IN VARCHAR2 DEFAULT NULL,
    log_table_owner_name IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'))
  RETURN VARCHAR2;

  FUNCTION validate_analytic_view (
    analytic_view_name	     IN VARCHAR2,
    analytic_view_owner_name IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'),
    log_table_name	     IN VARCHAR2 DEFAULT NULL,
    log_table_owner_name     IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'))
  RETURN NUMBER;

  FUNCTION get_mv_sql_for_av_cache (
    analytic_view_name       IN VARCHAR2,
    cache_idx                IN NUMBER, -- 0 based cache index
    analytic_view_owner_name IN VARCHAR2 DEFAULT
      SYS_CONTEXT('USERENV', 'CURRENT_USER'))
  RETURN CLOB;

  FUNCTION is_numeric(strnum VARCHAR2) RETURN NUMBER;

END dbms_hierarchy;
/

SHOW ERRORS;

-- Synonyms and grants
CREATE OR REPLACE PUBLIC SYNONYM DBMS_HIERARCHY FOR sys.DBMS_HIERARCHY;
GRANT EXECUTE ON DBMS_HIERARCHY TO PUBLIC;

@?/rdbms/admin/sqlsessend.sql

