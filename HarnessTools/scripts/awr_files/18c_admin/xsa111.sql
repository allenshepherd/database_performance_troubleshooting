Rem
Rem $Header: rdbms/admin/xsa111.sql /main/3 2017/05/28 22:46:13 stanaya Exp $
Rem
Rem xsa111.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsa111.sql - XS After reload 11.1 upgrade actions 
Rem
Rem    DESCRIPTION
Rem      The script runs after xsrelod.sql to perform upgrade
Rem      actions requiring XS packages and views
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xsa111.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xsa111.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    yiru        03/17/08 - add 11.2 upgrade
Rem    rburns      10/04/07 - post reload upgrade actions
Rem    rburns      10/04/07 - Created
Rem

Rem =======================================================
Rem Stage 1: upgrade from 11.1
Rem =======================================================



Rem =======================================================
Rem Stage 1: upgrade from next release
Rem =======================================================

-- uncomment for next release
@@xsa112
