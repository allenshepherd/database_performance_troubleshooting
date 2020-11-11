Rem
Rem $Header: rdbms/admin/xdbe121.sql /main/6 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbe121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbe121.sql - XDB downgrade to 12.1.0 
Rem
Rem    DESCRIPTION
Rem      This script performs the downgrade actions to downgrade the
Rem      current release to 12.1.0.  
Rem
Rem    NOTES
Rem      It is invoked by cmpdbdwg.sql to downgrade to 12.1.  First the User Data
Rem      is downgraded to 12.1, then the XDB schemas, and finally the XDB base objects.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbe121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbe121.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use DOWNGRADE for SQL_PHASE
Rem    qyu         07/28/16 - fix metadata info
Rem    dmelinge    02/14/14 - Sethttpconfigrealm fix, bug 18174584
Rem    raeburns    02/02/14 - rename eu scripts to ed
Rem    raeburns    11/04/13 - activate XDB downgrade to 12.1
Rem    dmelinge    07/05/13 - Realm from sys.props, bug 16278103 (moved to xdbeo121.sql)
Rem    dmelinge    07/05/13 - Realm from sys.props, bug 16278103
Rem    qyu         06/24/13 - Created


Rem ================================================================
Rem BEGIN XDB downgrade to 12.1.0
Rem ================================================================

EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

Rem Downgrade XDB Dependent objects
@@xdbed121.sql

Rem Downgrade XDB Schemas
@@xdbes121.sql

Rem Downgrade XDB primitive Objects
@@xdbeo121.sql

Rem ================================================================
Rem END XDB downgrade to 12.1.0
Rem ================================================================

EXECUTE dbms_registry.downgraded('XDB','12.1.0');
