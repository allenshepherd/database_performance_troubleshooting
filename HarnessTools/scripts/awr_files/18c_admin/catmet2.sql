Rem
Rem $Header: rdbms/admin/catmet2.sql /main/4 2014/02/20 12:45:37 surman Exp $
Rem
Rem catmet2.sql
Rem
Rem Copyright (c) 2004, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmet2.sql - Creates heterogeneous types for Data Pump's mdapi
Rem
Rem    DESCRIPTION
Rem      Creates heterogeneous type definitions for
Rem        TABLE_EXPORT
Rem        SCHEMA_EXPORT
Rem        DATABASE_EXPORT
Rem        TRANSPORTABLE_EXPORT
Rem      Also loads xsl stylesheets
Rem      All this must be delayed until the packages have been built.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmet2.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmet2.sql
Rem SQL_PHASE: CATMET2
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catdph.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    mjangir     09/21/12 - bug 14658090: run catmetx to enable diffing code
Rem    lbarton     06/22/04 - Bug 3695154: obsolete initmeta.sql 
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- create the types

exec dbms_metadata_build.set_debug(false);
exec DBMS_METADATA_DPBUILD.create_table_export;
exec DBMS_METADATA_DPBUILD.create_schema_export;
exec DBMS_METADATA_DPBUILD.create_database_export;
exec DBMS_METADATA_DPBUILD.create_transportable_export;

-- load XSL stylesheets

exec SYS.DBMS_METADATA_UTIL.LOAD_STYLESHEETS;

-- Bug 6603832: Run catmetx.sql if XDB is installed in the database
-- Bug 14658090: Run catmetx.sql to enable the diffing code 
COLUMN :xdb_metadata NEW_VALUE xdb_metadata_file NOPRINT
VARIABLE xdb_metadata VARCHAR2(50)

DECLARE
  xdb_version registry$.version%type;
  catalog_version registry$.version%type;
BEGIN
  :xdb_metadata := 'nothing.sql';    -- initialize for not running catmetx.sql
  select version into catalog_version from registry$ where cid = 'CATALOG';
  select version into xdb_version from registry$ where cid='XDB';
  IF xdb_version = catalog_version THEN
    :xdb_metadata := 'catmetx.sql';
  END IF;
EXCEPTION
  WHEN no_data_found THEN NULL;  --  XDB not loaded
END;
/

SELECT :xdb_metadata FROM DUAL;
@@&xdb_metadata_file



@?/rdbms/admin/sqlsessend.sql
