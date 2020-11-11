Rem
Rem $Header: rdbms/admin/xsa112.sql /main/5 2017/05/28 22:46:14 stanaya Exp $
Rem
Rem xsa112.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsa112.sql - XS After reload 11.2 upgrade actions
Rem
Rem    DESCRIPTION
Rem      The script runs after xsrelod.sql to perform upgrade
Rem      actions requiring XS packages and views
Rem
Rem    NOTES
Rem      
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsa112.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsa112.sql
Rem SQL_PHASE: UPGRADE 
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/xsdbmig.sql
Rem END SQL_FILE_METADATA
Rem
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/11/17 - Bug 25790192: Add SQL_METADATA
Rem    smierau     09/14/12 - move nacla112.sql to xsu112
Rem    rpang       02/21/12 - Network ACL Triton upgrade
Rem    yiru        03/13/08 - post-upgrade actions
Rem    yiru        03/13/08 - Created
Rem


Rem =======================================================
Rem Stage 1: upgrade from 11.2
Rem =======================================================

-- Migrate network ACLs from XDB
--@@nacla112.sql  moved to xsu112

Rem =======================================================
Rem Stage 2: upgrade from next release
Rem =======================================================
-- uncomment for next release
-- @@xsaNNN 
