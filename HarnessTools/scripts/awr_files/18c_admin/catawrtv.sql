Rem
Rem $Header: rdbms/admin/catawrtv.sql /st_rdbms_18.0/1 2017/12/03 13:39:32 osuro Exp $
Rem
Rem catawrtv.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catawrtv.sql - Catalog script for Automatic Workload Repository
Rem                   (AWR) Tables and Views
Rem
Rem    DESCRIPTION
Rem      Creates tables, views
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem      The newly created tables should be TRUNCATE in the downgrade script.
Rem      Any new views and their synonyms should be dropped in the downgrade
Rem      script.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catawrtv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catawrtv.sql
Rem SQL_PHASE: CATAWRTV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       11/28/17 - bug 27078828: Add AWR_CDB_* views
Rem    yingzhen    10/06/15 - Rename PDBA_HIST to AWR_PDB
Rem    ardesai     12/01/14 - Add catawrrtvw and catawrpdbvw
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ilistvin    06/11/22 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem The following script will create the WR tables
@@catawrtb

Rem The following script will create the AWR_ROOT views for the 
Rem Workload Repository
@@catawrrtvw

Rem The following script will create the AWR_PDB views for the
Rem Workload Repository
@@catawrpdbvw

Rem The following script will create the AWR_CDB views for the
Rem Workload Repository
@@catawrcdbvw


Rem The following script will create the DBA_HIST views for the 
Rem Workload Repository, except those that depend on packages
@@catawrvw


@?/rdbms/admin/sqlsessend.sql
