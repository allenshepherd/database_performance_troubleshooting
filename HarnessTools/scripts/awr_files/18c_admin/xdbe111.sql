Rem
Rem $Header: rdbms/admin/xdbe111.sql /main/6 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem xdbe111.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbe111.sql - XDB downgrade to 11.1.0
Rem
Rem    DESCRIPTION
Rem      This script performs the downgrade actions to downgrade the 
Rem      current release to 11.1.0.  It is invoked by cmpdbdwg.sql and
Rem      xdbe102.sql 
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbe111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbe111.sql 
Rem    SQL_PHASE: DOWNGRADE 
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbdwgrd.sql 
Rem    END SQL_FILE_METADATA
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    raeburns    02/02/14 - rename eu scripts to ed
Rem    vmedi       05/06/10 - revert 9144511 changes
Rem    spetride    12/02/09 - 9144511: disable sch validation for XS
Rem    badeoti     11/19/08 - add dbms_registry.dowgrading
Rem    rburns      11/05/07 - add schema and XS; handle XMLIDXSTATSMETHODS
Rem    rburns      08/22/07 - add 11g XDB up/down scripts
Rem    rburns      08/22/07 - Created
Rem

Rem ================================================================
Rem BEGIN XS downgrade to 11.1.0
Rem ================================================================
@@xse111.sql

Rem ================================================================
Rem END XS downgrade to 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade to 11.1.0
Rem ================================================================

EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

Rem Common Downgrade actions
@@xdbeall.sql

Rem Downgrade XDB Dependent objects
@@xdbed111.sql

Rem Downgrade XDB Schemas
@@xdbes111.sql

Rem Downgrade XDB objects
@@xdbeo111.sql

Rem ================================================================
Rem END XDB downgrade to 11.1.0
Rem ================================================================

EXECUTE dbms_registry.downgraded('XDB','11.1.0');
