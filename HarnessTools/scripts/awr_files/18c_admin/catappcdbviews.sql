Rem
Rem $Header: rdbms/admin/catappcdbviews.sql /main/5 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem catappcdbviews.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappcdbviews.sql - Application related CDB Views
Rem
Rem    DESCRIPTION
Rem      Catalog script to create Application related CDB Views
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catappcdbviews.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catappcdbviews.sql 
Rem    SQL_PHASE: CATAPPCDBVIEWS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    thbaby      05/23/16 - Bug 21540980: add CDB_APP_PDB_STATUS
Rem    thbaby      11/06/15 - bug 22157044: catfedcdbviews -> catappcdbviews
Rem    thbaby      09/15/15 - 21841612: add CDB_APP_VERSIONS
Rem    pyam        06/10/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/*****************************************************************************/
/*************************** CDB_APPLICATIONS  *******************************/
/*****************************************************************************/

begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APPLICATIONS',
                        'CDB_APPLICATIONS');
end;
/

grant select on SYS.CDB_APPLICATIONS to select_catalog_role
/

create or replace public synonym CDB_APPLICATIONS for CDB_APPLICATIONS
/

/*****************************************************************************/
/**************************** CDB_APP_PATCHES  *******************************/
/*****************************************************************************/

begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APP_PATCHES',
                        'CDB_APP_PATCHES');
end;
/

grant select on SYS.CDB_APP_PATCHES to select_catalog_role
/

create or replace public synonym CDB_APP_PATCHES for CDB_APP_PATCHES
/

/*****************************************************************************/
/*************************** CDB_APP_VERSIONS  *******************************/
/*****************************************************************************/

begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APP_VERSIONS',
                        'CDB_APP_VERSIONS');
end;
/

grant select on SYS.CDB_APP_VERSIONS to select_catalog_role
/

create or replace public synonym CDB_APP_VERSIONS for CDB_APP_VERSIONS
/

/*****************************************************************************/
/*********************** CDB_APP_STATEMENTS **********************************/
/*****************************************************************************/
begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APP_STATEMENTS',
                        'CDB_APP_STATEMENTS');
end;
/

grant select on SYS.CDB_APP_STATEMENTS to select_catalog_role
/

create or replace public synonym CDB_APP_STATEMENTS
for CDB_APP_STATEMENTS
/

/*****************************************************************************/
/****************************** CDB_APP_ERRORS *******************************/
/*****************************************************************************/
begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APP_ERRORS',
                        'CDB_APP_ERRORS');
end;
/

grant select on SYS.CDB_APP_ERRORS to select_catalog_role
/

create or replace public synonym CDB_APP_ERRORS
for CDB_APP_ERRORS
/

/*****************************************************************************/
/***************************** CDB_APP_PDB_STATUS ****************************/
/*****************************************************************************/

begin
 CDBView.create_cdbview(false, 'SYS', 'DBA_APP_PDB_STATUS',
                        'CDB_APP_PDB_STATUS');
end;
/

grant select on SYS.CDB_APP_PDB_STATUS to select_catalog_role
/

create or replace public synonym CDB_APP_PDB_STATUS for CDB_APP_PDB_STATUS
/

@?/rdbms/admin/sqlsessend.sql
