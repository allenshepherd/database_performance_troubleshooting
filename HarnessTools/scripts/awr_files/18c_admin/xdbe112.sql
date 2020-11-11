Rem
Rem $Header: rdbms/admin/xdbe112.sql /main/12 2017/05/28 22:45:59 stanaya Exp $
Rem
Rem xdbe112.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbe112.sql - XDB downgrade to 11.2.0
Rem
Rem    DESCRIPTION
Rem      This script performs the downgrade actions to downgrade the
Rem      current release to 11.2.0.  It is invoked by cmpdbdwg.sql and
Rem      xdbe111.sql
Rem
Rem    NOTES
Rem      In 11.2.0.x, performs patch downgrades
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbe112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbe112.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    raeburns    02/02/14 - rename eu scripts to ed
Rem    raeburns    11/26/13 - remove comments
Rem    yiru        02/01/12 - turn on xse112
Rem    juding      07/29/11 - split into xdbeu112, xdbes112, xdbeo112
Rem    srirkris    07/05/11 - remove on-deny
Rem    spetride    05/10/11 - downgrade for XDB export
Rem    juding      02/23/11 - bug 11071061: set KEY column to null for
Rem                           SXI leaf table
Rem    juding      02/01/11 - bug 11070995: set OID column to null for
Rem                           SXI table created for partitioned xmltype table
Rem    badeoti     08/21/10 - add schema changes during patch upgrade/downgrade
Rem    badeoti     03/09/10 - XDB downgrade to 11.2.0
Rem    badeoti     03/09/10 - Created
Rem

Rem ================================================================
Rem BEGIN XS downgrade to 11.2.0
Rem ================================================================

@@xse112.sql

Rem ================================================================
Rem END XS downgrade to 11.2.0 
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade to 11.2.0
Rem ================================================================
      
EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

Rem Downgrade XDB Dependent objects
@@xdbed112.sql

Rem Downgrade XDB Schemas
@@xdbes112.sql

Rem Downgrade XDB Objects
@@xdbeo112.sql

Rem ================================================================
Rem END XDB downgrade to 11.2.0
Rem ================================================================

EXECUTE dbms_registry.downgraded('XDB','11.2.0');
