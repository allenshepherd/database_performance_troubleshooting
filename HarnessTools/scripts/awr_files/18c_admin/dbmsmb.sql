Rem
Rem $Header: rdbms/admin/dbmsmb.sql /main/2 2017/08/01 14:20:24 yberezin Exp $
Rem
Rem dbmsmb.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsmb.sql - DBMS Management Bootstap package for administrators
Rem
Rem    DESCRIPTION
Rem      Specification for dbms_management_bootstrap interface
Rem
Rem    NOTES
Rem      Package will include procedures that make Trusted Callouts
Rem      to the kernel
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsmb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsmb.sql
Rem    SQL_PHASE: DBMSMB
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    07/12/17 - clean up DB Replay objects
Rem    osuro       02/18/16 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

CREATE  OR REPLACE PACKAGE dbms_management_bootstrap AS

  -- modify_awr_view_settings();
  --   This procedure allows a Pluggable database to modify all DBA_HIST 
  --   views to obtain its data from a different source.
  -- Input arguments:
  --   view_location    
  --     Set of AWR views to be used as data source for DBA_HIST views. 
  --     Possible values:
  --        AWR_ROOT - Shows data stored in CDB$ROOT that is visible
  --                   to the current PDB.
  --        AWR_PDB  - Shows data stored in PDB local SYSAUX.
  --     The default view location is AWR_ROOT.
  --
  --   recomp_objs
  --     If TRUE, the procedure will recompile objects (packages, views,
  --     types, etc) in SYS and DBSNMP schemas that have become INVALID 
  --     after DBA_HIST view location was changed.
  --     
  --     If FALSE, no objects will be recompiled after DBA_HIST views are
  --     recreated. User will recompile the objects himself.
  --     
  -- Usage Notes:
  --   Recreating views is an operation that will INVALIDATE both Oracle 
  --   provided objects (packages, views, types, etc) and User objects that
  --   depend on DBA_HIST views. 
  --   Discretion is adviced when using this procedure, recompiling objects
  --   on an active database may affect sessions that are currently using 
  --   them.
  PROCEDURE modify_awr_view_settings(
                   view_location    IN VARCHAR2 DEFAULT 'AWR_ROOT',
                   recomp_objs      IN BOOLEAN  DEFAULT TRUE);

  -----------------------------------------------------------------------------
  -- The procedure drops the DB Replay objects. This will help with future
  -- backports, namely the patch apply and rollback.
  --
  PROCEDURE cleanup_DB_Replay_objects;

END dbms_management_bootstrap;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_management_bootstrap
FOR sys.dbms_management_bootstrap
/
GRANT EXECUTE ON dbms_management_bootstrap to DBA
/

@?/rdbms/admin/sqlsessend.sql
