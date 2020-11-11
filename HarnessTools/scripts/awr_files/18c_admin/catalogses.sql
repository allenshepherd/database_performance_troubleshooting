Rem
Rem $Header: rdbms/admin/catalogses.sql /main/3 2017/04/27 17:09:44 raeburns Exp $ catalogses.sql
Rem
Rem catalogses.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catalogses.sql - Catalog Upgrade Session script
Rem
Rem    DESCRIPTION
Rem      This script contains session initialization statements
Rem      for catalog.sql that perform per-session start up actions
Rem      when running catupgrd.sql in parallel processes.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catalogses.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catalogses.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/14/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    jerrede     10/29/11 - Fix Bug 13252372
Rem    jerrede     10/29/11 - Created
Rem

Rem =====================================================================
Rem Catalog.sql settings
Rem =====================================================================
set errorlogging on table sys.registry$error identifier 'CATALOG';

