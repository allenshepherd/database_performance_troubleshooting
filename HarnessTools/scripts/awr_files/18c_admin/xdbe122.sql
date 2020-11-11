Rem
Rem $Header: rdbms/admin/xdbe122.sql /main/2 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbe122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbe122.sql - XDB downgrade to 12.2.0 
Rem
Rem    DESCRIPTION
Rem      This script performs the downgrade actions to downgrade the
Rem      current release to 12.2.0. 
Rem
Rem    NOTES
Rem      It is invoked by xdbdwgrd.sql to downgrade to 12.2. First the User 
Rem      Data is downgraded to 12.2, then the XDB schemas, and 
Rem      finally the XDB base objects.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbe122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbe122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use DOWNGRADE for SQL_PHASE
Rem    qyu         11/10/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem BEGIN XDB downgrade to 12.2.0
Rem ================================================================

EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

Rem Downgrade XDB Dependent objects
@@xdbed122.sql

Rem Downgrade XDB Schemas
@@xdbes122.sql

Rem Downgrade XDB primitive Objects
@@xdbeo122.sql

Rem ================================================================
Rem END XDB downgrade to 12.2.0
Rem ================================================================

EXECUTE dbms_registry.downgraded('XDB','12.2.0');

@?/rdbms/admin/sqlsessend.sql
 
