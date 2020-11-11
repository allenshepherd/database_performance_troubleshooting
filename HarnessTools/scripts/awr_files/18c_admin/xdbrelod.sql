Rem
Rem $Header: rdbms/admin/xdbrelod.sql /main/13 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem xdbrelod.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbrelod.sql - Xml DB RELOaD packages
Rem
Rem    DESCRIPTION
Rem      Replaces all XDB-related views and packages with the current versions.
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbrelod.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbrelod.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catrelod.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    raeburns    12/05/15 - bug 22322213: add catxrd.sql to xdbrelod.sql
Rem    raeburns    05/21/14 - restructure xdbrelod.sql for parallel upgrade
Rem    minx        09/27/12 - Remove xsrelod
Rem    rburns      01/08/08 - add xsrelod
Rem    rburns      10/05/07 - move acl_xidx enable
Rem    mrafiq      07/02/07 - fix for lrg-3019679
Rem    vkapoor     12/16/04 - Creating a new file for upgrade reload script
Rem    spannala    06/18/03 - removing xdbptrl1.sql
Rem    njalali     04/02/03 - using xdbvlo.sql
Rem    njalali     03/28/03 - compiling invalid stuff after upgrade
Rem    nmontoya    02/13/03 - move xdb$patchupdeleteschema comp FROM xdbu920
Rem    njalali     11/14/02 - Created
Rem

Rem ===============================================================
Rem  BEGIN XDB RELOAD - XDBRELOD.SQL
Rem ===============================================================

@@?/rdbms/admin/sqlsessstart.sql

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

EXECUTE dbms_registry.loading('XDB','Oracle XML Database');

-- Load the current versions of the XDB packages and views
@@xdbload.sql

-- Load current versions of dependent RDBMS packages and views
@@catxrd.sql

-- Indicated reload complete
EXECUTE dbms_registry.loaded('XDB');

-- Set status to VALID for dependent component reloads
-- XDB validation procedure will be run after utlrp.sql
execute sys.dbms_registry.valid('XDB');

@?/rdbms/admin/sqlsessend.sql

Rem ===============================================================
Rem  END XDB RELOAD - XDBRELOD.SQL
Rem ===============================================================

