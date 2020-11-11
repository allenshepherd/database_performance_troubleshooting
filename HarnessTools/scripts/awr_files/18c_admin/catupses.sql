Rem
Rem $Header: rdbms/admin/catupses.sql /main/5 2017/03/20 12:21:11 raeburns Exp $
Rem
Rem catupses.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupses.sql - CATalog UPgrade SESsion script
Rem
Rem    DESCRIPTION
Rem      This script contains session initialization statements
Rem      that perform per-session start up actions when running
Rem      catupgrd.sql in parallel processes.
Rem
Rem    NOTES
Rem      
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupses.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupses.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE:  rdbms/admin/catupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    jerrede     11/07/13 - Add Set Timing on by default
Rem    cmlim       05/15/13 - bug 16816410: remove errorlogging on table command
Rem                           because the sql here (without identifier) is too
Rem                           generic to be used throughout the upgrade
Rem    jerrede     10/29/11 - Fix Bug 13252372
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/23/06 - Created
Rem

Rem =====================================================================
Rem Call Common session settings
Rem =====================================================================

@@catpses.sql

Rem =====================================================================
Rem Turn off PL/SQL event used by APPS
Rem =====================================================================

ALTER SESSION SET EVENTS='10933 trace name context off';

Rem =====================================================================
Rem Set Time on Display Time with SQL Prompt
Rem =====================================================================

SET TIME ON;


Rem =====================================================================
Rem Set Timming on
Rem =====================================================================

SET TIMING ON;

