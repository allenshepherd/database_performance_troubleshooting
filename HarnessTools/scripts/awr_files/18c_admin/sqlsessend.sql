Rem
Rem $Header: rdbms/admin/sqlsessend.sql /main/2 2017/05/28 22:46:11 stanaya Exp $
Rem
Rem sqlsessend.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sqlsessend.sql - SQL session end
Rem
Rem    DESCRIPTION
Rem      Any commands which should be run at the end of all oracle
Rem      supplied scripts.
Rem
Rem    NOTES
Rem      See sqlsessstart.sql for the corresponding start script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sqlsessend.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sqlsessend.sql
Rem    SQL_PHASE: SQLSESSEND
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      03/08/13 - 16462837: Common start and end scripts
Rem    surman      03/08/13 - Created
Rem

alter session set "_ORACLE_SCRIPT" = false;


