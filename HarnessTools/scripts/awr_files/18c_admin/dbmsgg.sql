Rem
Rem $Header: rdbms/admin/dbmsgg.sql /main/9 2017/02/01 15:30:26 tchorma Exp $
Rem
Rem dbmsgg.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgg.sql - DBMS Goldengate Package
Rem
Rem    DESCRIPTION
Rem      This package contains the higher level APIs for GoldenGate 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsgg.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsgg.sql
Rem    SQL_PHASE: DBMSGG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dbmsgg.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tchorma     01/17/17 - Proj 47075 - procedure for iden hwm update
Rem    ygu         08/15/16 - XbranchMerge ygu_bug-24433551 from
Rem                           st_rdbms_12.2.0.1.0
Rem    ygu         08/09/16 - bug 24433551: add MANUAL pragma to 2 procedures
Rem                           in dbms_goldengate_auth
Rem    thoang      06/03/16 - Fix bug 23525819
Rem    huntran     02/11/16 - option to disable conflict resolution
Rem    huntran     12/03/15 - rename delta apis
Rem    huntran     11/02/15 - auto cdr parameters: record_conflicts and
Rem                           fetchcols
Rem    lzheng      08/06/15 - add function to detect if procedural replication
Rem                           for OGG is enabled
Rem    huntran     03/31/15 - auto cdr
Rem    lzheng      02/09/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_goldengate_adm AUTHID CURRENT_USER AS

  -- CONSTANTS
  use_custom_handlers_none    CONSTANT BINARY_INTEGER := 0;
  use_custom_handlers_all     CONSTANT BINARY_INTEGER := 1;

  PROCEDURE insert_procrep_exclusion_obj(
    package_owner     IN varchar2 default NULL,
    package_name      IN varchar2 default NULL,
    object_owner      IN varchar2 default NULL,
    object_name       IN varchar2 default NULL);

  PROCEDURE delete_procrep_exclusion_obj(
    package_owner     IN varchar2 default NULL,
    package_name      IN varchar2 default NULL,
    object_owner      IN varchar2 default NULL,
    object_name       IN varchar2 default NULL);

  -- Configures automatic CDR
  -- INPUT:
  --   schema_name          - owner of table
  --   table_name           - table name
  --   resolution_granularity - ROW or COLUMN granularity
  --   existing_data_timestamp- timestamp to assign existing rows
  --   tombstone_deletes      - track deletes in tombstone able?
  --   fetchcols              - fetch nonscalar columns
  --   record_conflicts       - record conflict info
  --   use_custom_handlers    - use custom handlers
  -- OUTPUT:
  -- NOTES:
  PROCEDURE add_auto_cdr(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        resolution_granularity  IN VARCHAR2 DEFAULT 'ROW',
	existing_data_timestamp IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
        tombstone_deletes       IN BOOLEAN DEFAULT TRUE,
        fetchcols               IN BOOLEAN DEFAULT TRUE,
        record_conflicts        IN BOOLEAN DEFAULT FALSE,
        use_custom_handlers     IN BINARY_INTEGER DEFAULT 0);

  -- Remove automatic CDR configuration
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  -- OUTPUT:
  -- NOTES:
  PROCEDURE remove_auto_cdr(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2);

  -- Alter automatic CDR configuration
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   tombstone_deletes    - track deletes in tombstone able?
  --   fetchcols            - fetch nonscalar columns
  --   record_conflicts     - record conflict info
  --   use_custom_handlers  - use custom handlers
  -- OUTPUT:
  -- NOTES:
  PROCEDURE alter_auto_cdr(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        tombstone_deletes       IN BOOLEAN DEFAULT NULL,
        fetchcols               IN BOOLEAN DEFAULT NULL,
        record_conflicts        IN BOOLEAN DEFAULT NULL,
        use_custom_handlers     IN BINARY_INTEGER DEFAULT NULL);

  -- Add automatic CDR delta resolution
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   column_name          - column name
  -- OUTPUT:
  -- NOTES:
  PROCEDURE add_auto_cdr_delta_res(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        column_name             IN VARCHAR2);

  -- Remove automatic CDR delta resolution
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   column_name          - column name
  -- OUTPUT:
  -- NOTES:
  PROCEDURE remove_auto_cdr_delta_res(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        column_name             IN VARCHAR2);

  -- Add automatic CDR column group
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   column_list          - column list
  --   column_group_name    - column group name
  --   existing_data_timestamp - timestamp for existing rows
  -- OUTPUT:
  -- NOTES:
  PROCEDURE add_auto_cdr_column_group(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        column_list             IN VARCHAR2,
        column_group_name       IN VARCHAR2 default NULL,
        existing_data_timestamp IN TIMESTAMP WITH TIME ZONE DEFAULT NULL);

  -- Remove automatic CDR column group
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   column_group_name    - column group name
  -- OUTPUT:
  -- NOTES:
  PROCEDURE remove_auto_cdr_column_group(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        column_group_name       IN VARCHAR2);

  -- Alter automatic CDR column group
  -- INPUT:
  --   schema_name          - table owner
  --   table_name           - table name
  --   column_group_name    - column group name
  --   add_column_list      - columns to add
  --   remove_column_list   - columns to remove
  -- OUTPUT:
  -- NOTES:
  PROCEDURE alter_auto_cdr_column_group(
	schema_name             IN VARCHAR2,	
	table_name              IN VARCHAR2,
        column_group_name       IN VARCHAR2,
        add_column_list         IN VARCHAR2,
        remove_column_list      IN VARCHAR2);

  -- Purge tombstone tables
  -- INPUT:
  --   purge_timestamp       - purge records before this timestamp
  -- OUTPUT:
  -- NOTES:
  PROCEDURE purge_tombstones(purge_timestamp IN TIMESTAMP WITH TIME ZONE);

  FUNCTION gg_procedure_replication_on RETURN NUMBER;

-- Update the High-watermark for all Identity column sequence objects in the 
-- database instance.  For every table having an identity column, this procedure
-- updates the high watermark of the corresponding system-generated sequence 
-- object to be higher than any value in the identity column (or lower in the 
-- case of a decreasing sequence).  Invoke this routine on an instance before
-- switching it from a target instance to a source instance, so that subsequent
-- identity column DMLs don't insert duplicate values.
  PROCEDURE update_identity_column_hwm;
END dbms_goldengate_adm;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_goldengate_adm FOR sys.dbms_goldengate_adm
/
GRANT EXECUTE ON sys.dbms_goldengate_adm TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_goldengate_auth AUTHID CURRENT_USER AS 

-- Grants the privileges needed by a user to be an administrator for OGG 
-- Integration with XStreamOut
-- INPUT:
--   grantee          - the user to whom privileges are granted
--   privilege_type   - CAPTURE, APPLY, both(*)
--   grant_select_privileges - should the select_catalog_role be granted?
--   do_grants        - should the privileges be granted ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   grant_optional_privileges - comma-separated list of optional prvileges
--                               to grant: XBADMIN, DV_XSTREAM_ADMIN,
--                               DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if grant_select_privileges = TRUE
--     grant select_catalog_role to grantee
--   if grant_select_privileges = FALSE
--     grant a min set of privileges to grantee
--   if do_grants = TRUE
--     the grant statements are to be executed.
--   if do_grants = FALSE
--     the grant statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grant is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE grant_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  grant_select_privileges IN BOOLEAN DEFAULT TRUE,
  do_grants        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  grant_optional_privileges IN VARCHAR2 DEFAULT NULL,
  container        IN VARCHAR2 DEFAULT 'CURRENT');
PRAGMA SUPPLEMENTAL_LOG_DATA(grant_admin_privilege, MANUAL_WITH_COMMIT);


-- Revokes the privileges needed by a user to be an administrator for OGG 
-- Integration with XStreamOut
-- INPUT:
--   grantee          - the user from whom privileges are revoked
--   privilege_type   - CAPTURE, APPLY, both(*)
--   revoke_select_privileges - should the select_catalog_role be revoked?
--   do_revokes       - should the privileges be revoked ?
--   file_name        - name of the file to which the script will be written
--   directory_name   - the directory where the file will be written
--   revoke_optional_privileges - comma-separated list of optional prvileges
--                                to revoke: XBADMIN, DV_XSTREAM_ADMIN,
--                                DV_GOLDENGATE_ADMIN
-- OUTPUT:
--   if revoke_select_privileges = TRUE
--     revoke select_catalog_role from grantee
--   if revoke_select_privileges = FALSE
--     revoke a min set of privileges from grantee
--   if do_revokes = TRUE
--     the revoke statements are to be executed.
--   if do_revokes = FALSE
--     the revoke statements are not executed.
--   If file_name is not NULL, 
--     then the script is written to it.
-- NOTES:
--   An error is raised if do_grants is false and file_name is null.
--   The file i/o is done using the package utl_file.
--   The file is opened in append mode.
--   The CREATE DIRECTORY command should be used to create directory_name.
--   If do_grants is true, each statement is appended to the script
--     only if it executed successfully.
PROCEDURE revoke_admin_privilege(
  grantee           IN VARCHAR2,
  privilege_type    IN VARCHAR2 DEFAULT '*',
  revoke_select_privileges IN BOOLEAN DEFAULT TRUE,
  do_revokes        IN BOOLEAN DEFAULT TRUE,
  file_name        IN VARCHAR2 DEFAULT NULL,
  directory_name   IN VARCHAR2 DEFAULT NULL,
  revoke_optional_privileges IN VARCHAR2 DEFAULT NULL,
  container        IN VARCHAR2 DEFAULT 'CURRENT');
PRAGMA SUPPLEMENTAL_LOG_DATA(revoke_admin_privilege, MANUAL_WITH_COMMIT);

END dbms_goldengate_auth;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_goldengate_auth FOR sys.dbms_goldengate_auth
/
@?/rdbms/admin/sqlsessend.sql
