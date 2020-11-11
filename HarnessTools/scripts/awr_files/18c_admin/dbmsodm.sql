Rem
Rem dbmsodm.sql
Rem
Rem Copyright (c) 1998, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsodm.sql - DBMS Data Mining Definitions
Rem
Rem    DESCRIPTION
Rem      This script compiles PL/SQL header files for Data Mining
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsodm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsodm.sql
Rem SQL_PHASE: DBMSODM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY) 
Rem    qinwan      09/17/14 - call dbmsrqmo.sql
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    xbarr       06/01/11 - Remove dbmsdmbl
Rem    xbarr       03/14/06 - Update dbmsdmxf  
Rem    mmcracke    03/10/06 - Creation 
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem set feedback off
Rem set echo off

Rem DBMS_DATA_MINING_TRANSFORM
@@dbmsdmxf.sql

Rem DBMS R Query MOdel
@@dbmsrqmo.sql

Rem DBMS Data Mining
@@dbmsdm.sql

Rem Load ODM Predictive package
@@dbmsdmpa.sql

SHOW ERRORS

@?/rdbms/admin/sqlsessend.sql
