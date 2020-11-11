Rem
Rem $Header: rdbms/admin/xdbes122.sql /main/2 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem xdbes122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbes122.sql - XDB Schema Downgrade to 12.2.0 
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB schema to 12.2.0 
Rem
Rem    NOTES
Rem      It is invoked from xdbdwgrd.sql and from xdbes121.sql 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbes122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbes122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    qyu         11/10/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 13.1.0
Rem ================================================================

--uncomment for next release
--@@xdbes131.sql

Rem ================================================================
Rem END XDB Schema downgrade to 13.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Schema downgrade to 12.2.0
Rem ================================================================


Rem ================================================================
Rem END XDB Schema downgrade to 12.2.0
Rem ================================================================

@?/rdbms/admin/sqlsessend.sql
 
