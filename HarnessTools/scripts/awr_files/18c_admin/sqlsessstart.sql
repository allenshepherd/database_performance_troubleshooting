Rem
Rem $Header: rdbms/admin/sqlsessstart.sql /main/2 2017/05/28 22:46:11 stanaya Exp $
Rem
Rem sqlsessstart.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sqlsessstart.sql - SQL session start
Rem
Rem    DESCRIPTION
Rem      Any commands which should be run at the start of all oracle
Rem      supplied scripts.
Rem
Rem    NOTES
Rem      See sqlsessend.sql for the corresponding end script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sqlsessstart.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sqlsessstart.sql
Rem    SQL_PHASE: SQLSESSSTART
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      03/08/13 - 16462837: Common start and end scripts
Rem    surman      03/08/13 - Created
Rem

alter session set "_ORACLE_SCRIPT" = true;
