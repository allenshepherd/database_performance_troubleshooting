Rem
Rem $Header: rdbms/admin/catnosodacoll.sql /main/4 2017/01/18 04:34:17 stanaya Exp $
Rem
Rem catnosodacoll.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnosodacoll.sql - CATalog script for removing JSON PL/SQL
Rem                      collection API
Rem
Rem    DESCRIPTION
Rem      This script drops the synonyms, tables, packages & views 
Rem      created for JSON PL/SQL collection API. This script must be 
Rem      invoked as sys.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    stanaya     01/18/17 - Bug 25213145: adding sql metadata
Rem    prthiaga    10/19/15 - Bug 22067651: Drop DBMS_SODA_DOM
Rem    prthiaga    05/18/15 - Remove SODA_APP role
Rem    prthiaga    07/29/14 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnosodacoll.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnosodacoll.sql
Rem    SQL_PHASE: CATNOSODACOLL
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA


@@?/rdbms/admin/sqlsessstart.sql

drop public synonym DBMS_SODA_ADMIN;

drop public synonym USER_SODA_COLLECTIONS;

drop public synonym DBMS_SODA_DOM;

drop package XDB.DBMS_SODA_ADMIN;

drop package SYS.DBMS_SODA_UTIL;

drop package XDB.DBMS_SODA_DOM;

drop package XDB.DBMS_SODA_DML;

drop view XDB.JSON$COLLECTION_METADATA_V;

drop view XDB.JSON$USER_COLLECTION_METADATA;

drop table XDB.JSON$COLLECTION_METADATA;

drop role SODA_APP;

@?/rdbms/admin/sqlsessend.sql
