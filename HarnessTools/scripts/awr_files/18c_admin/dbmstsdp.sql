Rem
Rem $Header: rdbms/admin/dbmstsdp.sql /main/3 2014/02/20 12:45:45 surman Exp $
Rem
Rem dbmstsdp.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstsdp.sql - DBMS Transparent Sensitive Data Protection
Rem
Rem    DESCRIPTION
Rem      This file is the top level script that loads all TSDP packages.
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmstsdp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmstsdp.sql
Rem SQL_PHASE: DBMSTSDP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    dgraj       09/16/11 - Proj 32079, Transparent Sensitive Data
Rem                           Protection
Rem    dgraj       09/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Create DBMS_TSDP_MANAGE package
@@dbmstsdpm.sql


Rem Create DBMS_TSDP_PROTECT package
@@dbmstsdpe.sql


@?/rdbms/admin/sqlsessend.sql
