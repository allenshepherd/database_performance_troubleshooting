Rem
Rem $Header: rdbms/admin/xdbus122.sql /main/2 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbus122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbus122.sql - XDB Upgrade Schemas from 12.2.0 
Rem
Rem    DESCRIPTION
Rem      This script upgrades the XDB schemas from release 12.2.0
Rem      to the current release. 
Rem
Rem    NOTES
Rem      It is invoked by xdbus.sql, and invokes the xdbusNNN script for the
Rem      subsequent release. 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbus122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbus122.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbus.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         11/10/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem BEGIN XDB Schema Upgrade from 12.2.0
Rem ================================================================


Rem ================================================================
Rem END XDB Schema Upgrade from 12.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema Upgrade from the next release
Rem ================================================================

-- Uncomment for next release
--@@xdbus131.sql

@?/rdbms/admin/sqlsessend.sql
 
