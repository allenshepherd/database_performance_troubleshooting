Rem
Rem $Header: emll/admin/scripts/dbmsocm.sql /main/3 2014/02/20 12:44:06 surman Exp $
Rem
Rem dbmsocm.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsocm.sql - Packages for MGMT_DB_LL_METRICS and MGMT_CONFIG
Rem
Rem    DESCRIPTION
Rem      These packages are use to create the database configuration
Rem      file for use by Oracle Configuration Manager (OCM).
Rem      MGMT_DB_LL_METRICS : Database configuration collection package
Rem      MGMT_CONFIG : The package for the job scheduling of the configuration
Rem                   collection.
Rem      Create User to the packages.
Rem    NOTES
Rem      This script should be run while connected as "SYS".
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: emll/admin/scripts/dbmsocm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsocm.sql
Rem SQL_PHASE: DBMSOCM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    dkapoor     06/06/06 - move directory creation after installing the 
Rem                           packages 
Rem    dkapoor     05/23/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Create the user 
@@catocm.sql
Rem Grant table access to user
@@grntocmtabaccess.sql
Rem Define the packages
@@ocmdbd.sql
@@ocmjd10.sql

@?/rdbms/admin/sqlsessend.sql
