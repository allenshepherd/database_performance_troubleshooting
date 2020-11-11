Rem
Rem $Header: rdbms/admin/xrdud112.sql /main/2 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem xrdud112.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdud112.sql - XRD Upgrade Dependent objects from 11.2
Rem
Rem    DESCRIPTION
Rem      This script contains upgrade actions that make use of
Rem      objects loaded by catxrd.sql
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdud112.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdud112.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrdupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/21/17 - RTI 20225108: Cleanup SQL_METADATA
Rem    raeburns    12/11/14 - XRD dependent upgrade
Rem    raeburns    12/11/14 - Created
Rem

Rem ======================================================
Rem BEGIN XRD dependent upgrade from 11.2
Rem ======================================================



Rem ======================================================
Rem END XRD dependent upgrade from 11.2
Rem ======================================================

Rem ======================================================
Rem Upgrade from subsequent releases
Rem ======================================================

@@xrdud121.sql

