Rem
Rem $Header: rdbms/admin/xsa102.sql /main/2 2017/05/28 22:46:13 stanaya Exp $
Rem
Rem xsa102.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsa102.sql - XS After reload upgrade actions
Rem
Rem    DESCRIPTION
Rem      The script runs after xsrelod.sql to perform upgrade
Rem      actions requiring XS packages and views
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xsa102.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xsa102.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      10/04/07 - post reload upgrade actions
Rem    rburns      10/04/07 - Created
Rem


Rem =======================================================
Rem Stage 1: upgrade from 10.2
Rem =======================================================



Rem =======================================================
Rem Stage 1: upgrade from next release
Rem =======================================================

@@xsa111


