Rem
Rem $Header: rdbms/admin/xrdu112.sql /main/2 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem xrdu112.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdu112.sql - XDB RDBMS Dependent upgrade from 11.2
Rem
Rem    DESCRIPTION
Rem      This script contains actions for upgrading from 11.2
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdu112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdu112.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrdupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/21/17 - RTI 20225108: Cleanup SQL_METADATA
Rem    raeburns    12/05/14 - XRD release-specific script
Rem    raeburns    12/05/14 - Created
Rem

Rem ======================================================
Rem BEGIN XRD upgrade from 11.2
Rem ======================================================



Rem ======================================================
Rem END XRD upgrade from 11.2
Rem ======================================================

Rem ======================================================
Rem Upgrade from subsequent releases
Rem ======================================================

@@xrdu121.sql

