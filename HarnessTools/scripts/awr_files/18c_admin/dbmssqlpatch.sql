Rem $Header: rdbms/admin/dbmssqlpatch.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem $Header: rdbms/admin/dbmssqlpatch.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem dbmssqlpatch.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssqlpatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      09/18/17 - 26281129: Support for new release model
Rem    surman      07/27/17 - 26517122: Make build_header a constant
Rem    surman      05/09/17 - Pass bundledata.xml to set_patch_metadata
Rem    surman      03/31/17 - 20353909: sql_registry-_state to table function
Rem    surman      03/08/17 - 25425451: Intelligent bootstrap
Rem    surman      10/10/16 - 23113885: Add event_value
Rem    surman      08/01/16 - 23170620: Rework set_patch_metadata and state
Rem                           table
Rem    surman      06/22/16 - 22694961: Application patches
Rem    surman      06/04/16 - 23113885: Add installed_bundleID
Rem    surman      04/11/16 - 23025340: Switching trains project
Rem    surman      01/07/16 - 22359063: Add get_opatch_lsinventory
Rem    surman      01/30/15 - 20348653: Add opatch_registry_state
Rem    surman      09/16/14 - 19547370: Add show errors
Rem    surman      08/18/14 - Always reload dbms_sqlpatch
Rem    surman      06/24/14 - 19051526: Add verify_queryable_inventory
Rem    surman      04/10/14 - More parameters
Rem    surman      10/31/13 - Creation for 17277459
Rem    surman      07/29/13 - Created
Rem
Rem  BEGIN SQL_FILE_METADATA 
Rem  SQL_SOURCE_FILE: rdbms/admin/dbmssqlpatch.sql 
Rem  SQL_SHIPPED_FILE: rdbms/admin/dbmssqlpatch.sql
Rem  SQL_PHASE: DBMSSQLPATCH
Rem  SQL_STARTUP_MODE: NORMAL 
Rem  SQL_IGNORABLE_ERRORS: NONE 
Rem  SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem  END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_sqlpatch AS

  -- 25425451: For intelligent bootstrap
  build_header CONSTANT VARCHAR2(200) := '$Header: rdbms/admin/dbmssqlpatch.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $';
  FUNCTION body_build_header RETURN VARCHAR2;

  -----------------------------------------------------------------------
  -- Public functions, meant to be called by users directly
  -----------------------------------------------------------------------

  -- The following cursors retreive information from the SQL registry in
  -- interesting ways.

  -- Returns the most recent entry for all patches in the registry.  Note that
  -- this includes entries for RU patches that may have been superseded by
  -- an install of a newer release, and hence those rows will not reflect the
  -- current RU status.
  CURSOR all_patches_cursor IS
    SELECT *
      FROM (SELECT dba_registry_sqlpatch.*, rowid registry_rowid,
                   RANK() OVER (PARTITION BY patch_id, patch_uid
                                ORDER BY install_id DESC, action_time DESC) r
            FROM dba_registry_sqlpatch)
      WHERE r = 1
      ORDER BY patch_id, patch_uid;

  -- Returns the most recent entry for all interim patches
  CURSOR all_interims_cursor IS
    SELECT *
      FROM (SELECT dba_registry_sqlpatch.*, rowid registry_rowid,
                   RANK() OVER (PARTITION BY patch_id, patch_uid
                                ORDER BY install_id DESC, action_time DESC) r
            FROM dba_registry_sqlpatch
            WHERE patch_type = 'INTERIM')
      WHERE r = 1
      ORDER BY patch_id, patch_uid;

  -- Returns the most recent release update entry, which is the
  -- current RU installed.  This could be any flavor of release update patch,
  -- i.e. an RU or RUR or CU.  Note that the most recent entry may not have
  -- been successful.
  CURSOR current_ru_cursor IS
    SELECT *
      FROM (SELECT dba_registry_sqlpatch.*, rowid registry_rowid,
                   RANK() OVER (ORDER BY install_id DESC, action_time DESC) r
            FROM dba_registry_sqlpatch
            WHERE patch_type != 'INTERIM')
      WHERE r = 1;

  -- Returns the most recent successful release update entry.  There may
  -- have been subsequent unsuccessful release update install attempts.
  CURSOR last_successful_ru_cursor IS
    SELECT *
      FROM (SELECT dba_registry_sqlpatch.*, rowid registry_rowid,
                   RANK() OVER (ORDER BY install_id DESC, action_time DESC) r
            FROM dba_registry_sqlpatch
            WHERE patch_type != 'INTERIM'
            AND status = 'SUCCESS')
      WHERE r = 1;

  -- Table functions to execute the above queries easily from SQL

  TYPE registry_record IS RECORD (
    install_id NUMBER,
    patch_id NUMBER,
    patch_uid NUMBER,
    patch_type VARCHAR2(10),
    flags VARCHAR2(10),
    action VARCHAR2(15),
    status VARCHAR2(25),
    action_time TIMESTAMP,
    description VARCHAR2(100),
    source_version VARCHAR2(15),
    source_build_description VARCHAR2(80),
    source_build_timestamp TIMESTAMP,
    target_version VARCHAR2(15),
    target_build_description VARCHAR2(80),
    target_build_timestamp TIMESTAMP,
    registry_rowid VARCHAR2(25)
  );

  TYPE registry_table IS TABLE of registry_record;

  -- Returns the current state of the SQL registry.  This is a union of 
  -- all_interims_cursor and current_ru_cursor.  The resulting data set will
  -- show which interim patches are currently applied or rolled back, as well
  -- as the most recent RU entry.
  -- SELECT * FROM TABLE(dbms_sqlpatch.installed_patches);
  FUNCTION installed_patches RETURN registry_table PIPELINED;

  -- Returns the most recent entry for all patches in the registry.
  -- This is just all_patches_cursor.  The resulting data set will
  -- show which interim patches are currently applied or rolled back, as well
  -- as which RU patches have been applied or rolled back.
  -- SELECT * FROM TABLE(dbms_sqlpatch.all_patches);
  FUNCTION all_patches RETURN registry_table PIPELINED;

  -- Returns the current RU installed.  This is just current_ru_cursor.
  -- SELECT patch_type, target_version, target_build_description,
  --        target_build_timestamp
  --   FROM TABLE(dbms_sqlpatch.current_ru_version);
  FUNCTION current_ru_version RETURN registry_table PIPELINED;

  -- Returns the most recent successful RU installed.  This is just
  -- last_successful_ru_cursor.
  -- SELECT * FROM TABLE(dbms_sqlpatch.last_successful_ru_version);
  FUNCTION last_successful_ru_version RETURN registry_table PIPELINED;

  -- Returns the current state of the SQL registry as an XML document.
  -- SELECT dbms_sqlpatch.sql_registry_state FROM dual;
  FUNCTION sql_registry_state RETURN XMLType;

  -----------------------------------------------------------------------
  -- Private functions, but declared in the package header so as to be
  -- visible outside the package.  These are meant to be called only by
  -- datapatch.
  -----------------------------------------------------------------------

  -- Wrapper around queryable inventory's get_pending_activity function.
  -- Returns an XML string representing the state of SQL patches installed
  -- in the opatch inventory.
  FUNCTION opatch_registry_state RETURN XMLType;

  -- Wrapper around queryable inventory's get_opatch_lsinventory function.
  -- Returns an XML string consisting of the entire inventory.  This function
  -- caches the result for performance.
  FUNCTION get_opatch_lsinventory RETURN XMLType;

  -- Performs session initialization.  Must be called before patch_initialize.
  -- 25425451: Pass nothing_script to remove the dependency on dbms_registry.
  PROCEDURE session_initialize(p_force IN BOOLEAN := FALSE,
                               p_debug IN BOOLEAN := FALSE,
                               p_app_mode IN BOOLEAN := FALSE,
                               p_nothing_sql IN VARCHAR2 := NULL,
                               p_attempt IN NUMBER := NULL);

  -- 23025340/26281129: Because patch_initialize is part of the generated
  -- apply and rollback scripts, we can't easily change its signature.  Also
  -- passing parameters via patch_initialize requires them to be passed as
  -- additional command line arguments to the install script.  Hence these
  -- procedures are called directly by datapatch prior to patch_initialize
  -- to store the patch and file metadata into persistent tables for later
  -- reference in patch_initialize, install_file, and patch_finalize.
  PROCEDURE set_patch_metadata(p_patch IN dba_registry_sqlpatch%ROWTYPE);

  PROCEDURE set_file_metadata(p_patch_id IN NUMBER,
                              p_patch_uid IN NUMBER,
                              p_install_file IN VARCHAR2,
                              p_actual_file IN VARCHAR2);
 
  PROCEDURE update_patch_metadata(p_patch_id IN NUMBER,
                                  p_patch_uid IN NUMBER,
                                  p_ru_logfile IN VARCHAR2 := NULL,
                                  p_flags IN VARCHAR2 := NULL);

  -- Performs any initialization necessary for the given patch, including
  -- the initial insert to the SQL registry.  Additional metadata is retreived
  -- from the state table.
  PROCEDURE patch_initialize(p_patch_id IN NUMBER,
                             p_patch_uid IN NUMBER,
                             p_logfile IN VARCHAR2);

  -- For the current patch and mode under consideration, returns the full path
  -- of the actual file to be run, based on the values passed to
  -- set_file_metadata.
  FUNCTION install_file(sql_file IN VARCHAR2)
    RETURN VARCHAR2;

  -- Performs any finalization necessary for the current patch.  This
  -- includes clearing the package state and updating the SQL registry.
  PROCEDURE patch_finalize;

  -- Tests the queryable inventory functionality.
  -- If QI is working properly, then the string 'OK' is returned, otherwise
  -- any errors are returned.
  FUNCTION verify_queryable_inventory RETURN VARCHAR2;



  -- Removes all saved state from the dbms_sqlptach_state table.
  PROCEDURE clear_state;

  -- 23113885: Returns the value of the specified event
  FUNCTION event_value(p_event IN NUMBER) RETURN NUMBER;

END dbms_sqlpatch;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_sqlpatch FOR sys.dbms_sqlpatch;

GRANT EXECUTE ON dbms_sqlpatch TO execute_catalog_role;

@?/rdbms/admin/sqlsessend.sql
