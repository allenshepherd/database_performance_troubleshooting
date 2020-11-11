Rem
Rem $Header: rdbms/admin/xdbuo122.sql /main/6 2017/06/28 05:46:09 raeburns Exp $
Rem
Rem xdbuo122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuo122.sql - XDB Upgrade RDBMS Objects from 12.2.0 
Rem
Rem    DESCRIPTION
Rem      This script upgrades the base XDB objects from release 12.2.0
Rem      to the current release. 
Rem
Rem    NOTES
Rem      It is invoked by xdbuo.sql, and invokes the xdbuoNNN script for the
Rem      subsequent release. 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuo122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuo122.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbuo.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/13/17 - RTI 20258949: Drop objects removed from XDB
Rem                           install
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    prthiaga    02/17/16 - Bug 25577443: Move soda upgrade to xdbload
Rem    prthiaga    01/31/17 - Bug 25477695: Upgrade for SODA/PLSQL
Rem    raeburns    01/12/17 - RTI 20037449: remove ALTER TYPE for
Rem                           XMLIndexMethods
Rem    qyu         11/10/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from 12.2.0
Rem ================================================================

Rem RTI 20037449: drop XMLIndexMethods since was evolved in the past
Rem Will be recreated when catxidx.sql is run by xdbload.sql
DROP TYPE XDB.XMLIndexMethods FORCE;

-------------------------------------------------------------------
-- BEGIN RTI 12596835: Drop objects no longer installed
-------------------------------------------------------------------

drop table xdb_installation_tab;

-------------------------------------------------------------------
-- BEGIN RTI 12596835: Drop objects no longer installed
-------------------------------------------------------------------


Rem ================================================================
Rem END XDB RDBMS Object Upgrade from 12.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from the next release
Rem ================================================================

-- Uncomment for next release
--@@xdbuo131.sql

@?/rdbms/admin/sqlsessend.sql
 
