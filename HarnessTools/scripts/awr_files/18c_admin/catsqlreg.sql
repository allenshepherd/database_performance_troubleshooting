Rem
Rem $Header: rdbms/admin/catsqlreg.sql /st_rdbms_18.0/2 2018/02/23 11:47:57 surman Exp $
Rem
Rem catsqlreg.sql
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catsqlreg.sql - CAT SQLpatch REGistry
Rem
Rem    DESCRIPTION
Rem      Creates the registry$sqlpatch table and dba_registry_sqlpatch view
Rem      used by datapatch.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catsqlreg.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catsqlreg.sql
Rem    SQL_PHASE: CATSQLREG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catxrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      02/21/18 - Backport surman_bug-27283029 from main
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      02/05/18 - 27283029: Add dba_registry_sqlpatch_ru_info
Rem    surman      09/12/17 - 26281129: Support for new release model
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase input to create_cdbview
Rem    raeburns    05/31/17 - RTI 20258949: match DBA_REGISTRY_SQLPATCH text to
Rem                           bootstrap
Rem    surman      04/06/17 - 25425451: Status column to 25 characters
Rem    surman      07/20/16 - 23170620: Add patch_directory
Rem    surman      06/29/16 - 23113885: Post patching support
Rem    surman      06/14/16 - 22694961: Add datapatch_role
Rem    surman      04/01/16 - 23025340: Add install_id
Rem    surman      01/07/16 - 22359063: Add patch_descriptor
Rem    surman      10/01/15 - 20772435: Store as clob
Rem    surman      08/20/15 - 20772435: bundle_data back to XMLType
Rem    surman      10/08/14 - 19315691: bundle_data to CLOB
Rem    pyam        06/13/14 - fix table column ordering
Rem    surman      04/21/14 - Seperate script for SQL registry
Rem    surman      04/21/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem SQL Registry table
Rem This is used to record the SQL patches that are applied and rolled back
Rem for this database instance.  It is updated by the patch apply and rollback
Rem scripts.
Rem The flags column contains the following characters:
Rem  U: Patch requires upgrade mode
Rem  N: Patch requires normal mode
Rem  R: Patch installation has been retried
Rem  J: Patch is a OJVM patch
Rem  M: Patch installation was merged with another patch
Rem At least U or N must be present in flags.

Rem The source_* columns indicate the version fields on which the patch
Rem will be installed, the target_* columns indicate the version fields after 
Rem the patch has been successfully installed
CREATE TABLE registry$sqlpatch (
  install_id       NUMBER,         -- Unique ID per datapatch invocation
  patch_id         NUMBER,         -- Patch ID
  patch_uid        NUMBER,         -- Patch UID
  patch_type       VARCHAR2(10) NOT NULL,   -- INTERIM, RU, RUR, RUI, CU
  action           VARCHAR2(15),            -- APPLY or ROLLBACK
  status           VARCHAR2(25) NOT NULL,   -- BEGIN, END, SUCCESS, WITH ERRORS
  action_time      TIMESTAMP NOT NULL,      -- Time of action
  description      VARCHAR2(100),  -- Patch description
  logfile          VARCHAR2(500) NOT NULL,  -- Location of logfile
  ru_logfile       VARCHAR2(500),  -- Logfile location for RU specific commands
  flags            VARCHAR2(10),   -- Flags for this patch
  patch_descriptor XMLType NOT NULL,  -- XML descriptor for this patch
  patch_directory  BLOB,              -- Zipped contents of patch directory
  source_version   VARCHAR2(15),         -- Source 5 digit version
  source_build_description VARCHAR2(80), -- Source build description
  source_build_timestamp   TIMESTAMP,    -- Source build timestamp
  target_version           VARCHAR2(15), -- Target 5 digit version
  target_build_description VARCHAR2(80), -- Target build description
  target_build_timestamp   TIMESTAMP,    -- Target build timestamp
  CONSTRAINT registry$sqlpatch_pk
    PRIMARY KEY (install_id, patch_id, patch_uid, action, action_time)
  )
  XMLType COLUMN patch_descriptor STORE AS CLOB
;


Rem -------------------------------------------------------------------------
Rem SQL Registry view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_sqlpatch AS
SELECT install_id, patch_id, patch_uid, patch_type, action, status,
       action_time, description, logfile, ru_logfile, flags,
       patch_descriptor, patch_directory,
       source_version, source_build_description, source_build_timestamp,
       target_version, target_build_description, target_build_timestamp
  FROM registry$sqlpatch
/

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_sqlpatch
  FOR sys.dba_registry_sqlpatch;

GRANT SELECT ON dba_registry_sqlpatch TO select_catalog_role;

BEGIN
  CDBView.create_cdbview(FALSE, 'SYS', 'DBA_REGISTRY_SQLPATCH',
                         'CDB_REGISTRY_SQLPATCH');
END;
/

GRANT SELECT ON sys.cdb_registry_sqlpatch TO select_catalog_role;

CREATE OR REPLACE PUBLIC SYNONYM cdb_registry_sqlpatch
  FOR sys.cdb_registry_sqlpatch;

Rem -------------------------------------------------------------------------
Rem 27283029: registry$sqlpatch_ru_info and dba_registry_sqlpatch_ru_info
Rem This table/view is used to store information about release update patches
Rem found in the system.
Rem -------------------------------------------------------------------------

CREATE TABLE registry$sqlpatch_ru_info (
  patch_id             NUMBER,       -- Patch ID
  patch_uid            NUMBER,       -- Patch UID
  patch_descriptor     XMLType,      -- XML descriptor
  ru_version           VARCHAR2(15), -- 5 digit version
  ru_build_description VARCHAR2(80), -- Build description
  ru_build_timestamp   TIMESTAMP,    -- Build timestamp
  patch_directory      BLOB,         -- Zipped contents of patch dir
  CONSTRAINT registry$sqlpatch_ru_info_pk
    PRIMARY KEY (patch_id, patch_uid)
  )
  XMLType COLUMN patch_descriptor STORE AS CLOB
;

CREATE OR REPLACE VIEW dba_registry_sqlpatch_ru_info AS
  SELECT patch_id, patch_uid, patch_descriptor, ru_version,
         ru_build_description, ru_build_timestamp, patch_directory
  FROM registry$sqlpatch_ru_info;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_sqlpatch_ru_info
  FOR dba_registry_sqlpatch_ru_info;

GRANT SELECT ON dba_registry_sqlpatch_ru_info TO select_catalog_role;

BEGIN
  CDBView.create_cdbview(FALSE, 'SYS', 'DBA_REGISTRY_SQLPATCH_RU_INFO',
                         'CDB_REGISTRY_SQLPATCH_RU_INFO');
END;
/

GRANT SELECT ON sys.cdb_registry_sqlpatch_ru_info TO select_catalog_role;

CREATE OR REPLACE PUBLIC SYNONYM cdb_registry_sqlpatch_ru_info
  FOR sys.cdb_registry_sqlpatch_ru_info;


Rem -------------------------------------------------------------------------
Rem datapatch role
Rem -------------------------------------------------------------------------

DECLARE
  cnt NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO cnt
    FROM dba_roles
    WHERE role = 'DATAPATCH_ROLE';

  IF cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE ROLE datapatch_role';
  END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql

