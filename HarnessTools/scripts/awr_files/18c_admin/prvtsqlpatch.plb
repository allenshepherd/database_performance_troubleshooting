Rem $Header: rdbms/src/server/dict/plsicds/prvtsqlpatch.sql /st_rdbms_18.0/2 2018/02/23 11:47:57 surman Exp $
Rem
Rem prvtsqlpatch.sql
Rem
Rem Copyright (c) 2013, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      prvtsqlpatch.sql
Rem
Rem    DESCRIPTION
Rem      Package body for dbms_sqlpatch
Rem
Rem    NOTES
Rem      Used primarily by datpatch
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      02/21/18 - Backport surman_bug-27283029 from main
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      01/29/18 - 27283029: Diagnostics
Rem    surman      09/18/17 - 26281129: Support for new release model
Rem    surman      06/28/17 - 26365451: Always return in install_file
Rem    thbaby      06/18/17 - Bug 26270407: no statement redirect in Proxy PDB
Rem    surman      06/17/17 - 25425451: Query older bundledata if needed
Rem    surman      05/09/17 - Pass bundledata.xml to set_patch_metadata
Rem    surman      04/26/17 - 25512969: Pass debug to QI
Rem    surman      03/31/17 - 20353909: sql_registry-_state to table function
Rem    kquinn      03/27/17 - 25269042: set nls_length_semantics to byte
Rem    sanagara    03/11/17 - RTI 20162585: do not set _kolfuseslf for app patch
Rem    surman      03/09/17 - 24764876: Option off is still processed
Rem    surman      03/08/17 - 25425451: Intelligent bootstrap
Rem    sanagara    02/17/17 - 25303756: set _kolfuseslf to true
Rem    sanagara    02/11/17 - 25445168: check for container change
Rem    surman      12/08/16 - 25206864: Apply after rollback of bundle
Rem    surman      10/10/16 - 23113885: Add event_value
Rem    surman      07/30/16 - 23170620: Rework set_patch_metadata and state
Rem                           table
Rem    surman      07/27/16 - 23170620: Add patch_directory
Rem    surman      07/14/16 - 24292191: Skip component check for application
Rem                           patches
Rem    surman      07/01/16 - 22815955: Save and restore state
Rem    surman      06/30/16 - 21329039: Component check for all patches
Rem    surman      06/29/16 - 23113885: Add installed_bundleID
Rem    surman      06/22/16 - 22694961: Application patches
Rem    surman      05/23/16 - 23324000: Always run if switching trains
Rem    surman      04/11/16 - 23025340: Switching trains project
Rem    surman      01/07/16 - 22359063: Add get_opatch_lsinventory
Rem    surman      08/21/15 - 20772435: bundle_data back to XMLType
Rem    surman      07/10/15 - 21421886: Change component status check
Rem    surman      03/16/15 - 20711718: Use GetClobVal()
Rem    surman      01/30/15 - 20348653: Add opatch_registry_state
Rem    surman      10/08/14 - 19315691: bundle_data to CLOB
Rem    surman      09/16/14 - 19547370: Add show errors
Rem    surman      09/08/14 - 19521006: Patch specific force
Rem    surman      08/19/14 - 19189525: Initialize nothing_script after setting
Rem                           context
Rem    surman      07/08/14 - 19174521: Handle missing bundledata
Rem    surman      06/24/14 - 19051526: Add verify_queryable_inventory
Rem    surman      06/11/14 - 18961489: Use dbms_assert
Rem    surman      05/21/14 - 18491608: Return error patches
Rem    surman      04/10/14 - More parameters
Rem    surman      11/01/13 - Creation for 17277459
Rem    surman      07/29/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/src/server/dict/plsicds/prvtsqlpatch.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/prvtsqlpatch.plb
Rem    SQL_PHASE: PRVTSQLPATCH
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catxrd.sql
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

Rem 22831306: Create state table here so that whenever the package body is
Rem changed the state table will be created if needed first.
DECLARE
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM dba_tables
    WHERE table_name = 'DBMS_SQLPATCH_STATE';

  IF cnt = 1 THEN
    EXECUTE IMMEDIATE 'DROP TABLE dbms_sqlpatch_state CASCADE CONSTRAINTS';
  END IF;

  SELECT COUNT(*) INTO cnt FROM dba_tables
    WHERE table_name = 'DBMS_SQLPATCH_FILES';

  IF cnt = 1 THEN
    EXECUTE IMMEDIATE 'DROP TABLE dbms_sqlpatch_files CASCADE CONSTRAINTS';
  END IF;
END;
/

Rem 23170620: State table.  This is used for 2 purposes: to save and restore
Rem the PL/SQL state between calls to dbms_sqlpatch (see bug 22815955), as
Rem well as for communication between the Perl and catcon processes.
Rem All of the private package variables should have a corresponding column.

Rem There will be one row for each patch to be installed for this PDB for
Rem each datapatch invocation.  The Perl code calls set_patch_metadata
Rem to insert a row with active = 'N', passing the metadata that is not
Rem part of patch_initialize.  Then during patch_initialize we set active to
Rem 'Y' to indicate the currently active patch for use in save_state and
Rem restore_state.  active is set back to 'N' during patch_finalize.

Rem all columns need to be < 30 characters in case compatible < 12.2.  Sigh.

CREATE TABLE dbms_sqlpatch_state (
  active                        CHAR(1),
  s_current_patch_id            NUMBER,
  s_current_patch_uid           NUMBER,
  s_current_patch_type          VARCHAR2(10),
  s_current_patch_action        VARCHAR2(15),
  s_current_patch_description   VARCHAR2(100),
  s_current_patch_flags         VARCHAR2(10),
  s_current_patch_descriptor    XMLType,
  s_current_patch_directory     BLOB,
  s_current_source_version      VARCHAR2(15),
  s_current_source_build_desc   VARCHAR2(80),
  s_current_source_build_ts     TIMESTAMP,
  s_current_target_version      VARCHAR2(15),
  s_current_target_build_desc   VARCHAR2(80),
  s_current_target_build_ts     TIMESTAMP,
  s_current_ru_logfile          VARCHAR2(500),
  s_current_registry_rowid      ROWID,
  s_nothing_sql                 VARCHAR2(30),
  s_debug                       CHAR(1),
  s_force                       CHAR(1),
  s_init_complete               CHAR(1),
  s_cached_lsinventory          XMLType,
  s_session_install_id          NUMBER,
  s_app_mode                    CHAR(1),
  s_container_name              VARCHAR2(128),
  s_cached_pending_activity     XMLType,
  s_attempt                     NUMBER,
  CONSTRAINT dbms_sqlpatch_state_pk
    PRIMARY KEY (s_current_patch_id, s_current_patch_uid)
  )
  XMLType COLUMN s_cached_lsinventory STORE AS CLOB
  XMLType COLUMN s_cached_pending_activity STORE AS CLOB;

GRANT READ on dbms_sqlpatch_state TO datapatch_role;

CREATE TABLE dbms_sqlpatch_files (
  patch_id NUMBER,
  patch_uid NUMBER,
  install_file VARCHAR2(80),
  actual_file VARCHAR2(200),
  CONSTRAINT dbms_sqlpatch_files_fk
    FOREIGN KEY (patch_id, patch_uid) REFERENCES dbms_sqlpatch_state
  );

CREATE OR REPLACE PACKAGE BODY dbms_sqlpatch wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
61a2 1515
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

/

show errors

@?/rdbms/admin/sqlsessend.sql
