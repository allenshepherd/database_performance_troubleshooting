Rem
Rem $Header: rdbms/admin/xdbupgrd.sql /main/3 2017/05/26 05:12:29 raeburns Exp $
Rem
Rem xdbupgrd.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbupgrd.sql - Xml DB DataBase UPGRaDe
Rem
Rem    DESCRIPTION
Rem      Upgrade script for XDB from all supported prior releases
Rem      (both patch and major).
Rem
Rem    NOTES
Rem      This script replaces xdbdbmig.sql and is invoked
Rem      by cmpupgrd.sql via a CATCTL -CP annotation, and not
Rem      directly via @@ notation.   It contains all of the 
Rem      timestamps and error logging that had been in 
Rem      cmpupxdb.sql (now in xdbustr.sql and xdbuend.sql).

Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbupgrd.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbupgrd.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem    SQL_DRIVER_ONLY: YES
Rem    END SQL_FILE_METADATA

Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE UPGRADE
Rem    raeburns    09/02/14 - add RDBMS dependent feature upgrade
Rem    raeburns    08/20/14 - rename (was xdbdbmig.sql) 
Rem                         - and convert for parallel processing
Rem    raeburns    07/22/14 - use xdbload, not xdbrelod, for upgrade
Rem    raeburns    04/13/14 - run complete xdbrelod.sql
Rem    raeburns    10/20/13 - restructure upgrade
Rem    dkoppar     10/03/13 - #16763416 strict XDB validation
Rem    dalpern     02/15/12 - proj 32719: INHERIT PRIVILEGES privilege
Rem    sursridh    12/12/11 - bug 13425408: grant execute on dbms_pdb to xdb.
Rem    rpang       08/16/11 - Proj 32719: Grant inherit privileges
Rem    qyu         08/29/11 - xdb long identifier
Rem    juding      01/24/11 - bug 11070995: add xdbxtbix.sql
Rem    sidicula    12/21/10 - Reset package state
Rem    sidicula    12/12/10 - Get stats after reload
Rem    badeoti     09/30/10 - dump errorstack for intermittent ORA-31061
Rem    vmedi       05/06/10 - revert 9144511 changes
Rem    badeoti     04/30/10 - bug 9672801: remove echo off
Rem    spetride    12/09/09 - print acl index status
Rem    spetride    12/02/09 - 9144511: disable sch validation for XS
Rem    rburns      09/30/07 - add 11.1 upgrade
Rem    mrafiq      06/29/07 - fix for lrg 3019679
Rem    pthornto    10/04/06 - add call to xsdbmig.sql for eXtensible Security
Rem                           pkgs
Rem    spetride    10/13/06 - not mark XDB invalid, recovery checks
Rem                           run if invalid config/acl rows anyway
Rem    spetride    08/04/06 - enable validate during upgrade
Rem    vmedi       06/19/06 - tempfix: disable validate during upgrade 
Rem    mrafiq      05/23/06 - fixing status and version numbers 
Rem    petam       04/10/06 - upgrade Fusion Security after XDB fully upgraded
Rem    abagrawa    03/14/06 - 
Rem    vkapoor     01/25/05 - Adding 102 upgrade script 
Rem    mrafiq      02/23/06 - fix for lrg 2070764: default value for 
Rem                           script_name 
Rem    mrafiq      10/04/05 - adding 102 upgrade script 
Rem    fge         10/27/04 - add 10gr2 upgrade script 
Rem    vkapoor     02/15/05 - LRG 1830972. xdbreload needs to be called if upgrade
Rem                           is rerun.
Rem    pnath       01/19/05 - call xdbinst.sql instead of xdbinstlltab.sql 
Rem    vkapoor     12/16/04 - A new script for upgrade reload 
Rem    pnath       11/22/04 - delete all objects introduced in xdb 
Rem                           installation 
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    05/04/04 - drop xdbhi_idx and recreate later
Rem    thbaby      01/30/04 - adding 10GR1 upgrade 
Rem    spannala    10/20/03 - migrate status at the beginning of upgrade 
Rem                           should be set correctly as per release
Rem    spannala    06/18/03 - making xdbreload generic enough for all upgrades
Rem    spannala    06/09/03 - in 9201 upgd, call xdbptrl2 at the end
Rem    njalali     04/16/03 - removing ?/ notation
Rem    njalali     04/02/03 - not calling xdbrelod twice on 9.2.0.1 upgrade
Rem    njalali     03/27/03 - dropping xdb$patchupschema
Rem    njalali     02/10/03 - enabling upgrade from 9.2.0.3 to 10i
Rem    njalali     01/16/03 - bug 2744444
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/21/02 - Incorporated review comments
Rem    njalali     11/14/02 - Created
Rem

Rem ===============================================================
Rem  BEGIN XDB UPGRADE - XDBUPGRD.SQL
Rem ===============================================================

--Run initial steps in a single process
--CATCTL -S

-- Initial startup script - sets XDB_VERSION variable used by other scripts
@@xdbustr.sql

-- Upgrade base XDB Objects
@@xdbuo.sql

-- Upgrade XDB Schemas
@@xdbus.sql

-- Reload views, packages, package bodies, type bodies
-- Run reload with parallel processing

@@xdbload.sql --CATFILE -X

--CATCTL -S
-- Return to a single process for remainder of upgrade
-- Upgrade XDB Dependent Objects
@@xdbud.sql

-- Upgrade RDBMS features that depend on XDB
@@xrdupgrd.sql

-- Complete XDB Upgrade Operations
@@xdbuend.sql

Rem ===============================================================
Rem  END XDB UPGRADE - XDBUPGRD.SQL
Rem ===============================================================
