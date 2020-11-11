Rem
Rem $Header: rdbms/admin/dbmsxuducu.sql /main/2 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem dbmsxuducu.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxuducu.sql - XDB Upgrade/Downgrade Utilities Clean Up
Rem
Rem    DESCRIPTION
Rem      Cleanup XDB up/down utilities
Rem
Rem    NOTES
Rem      Run by xdbus.sql (and xdbes112.sql) to drop upgrade/downgrade utilitis
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsxuducu.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsxuducu.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbus.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    badeoti     12/15/09 - clean up private upgrade/downgrade utilities
Rem    badeoti     12/15/09 - Created
Rem

DROP PUBLIC SYNONYM dbms_xdbmig_util;
DROP PACKAGE xdb.dbms_xdbmig_util;

