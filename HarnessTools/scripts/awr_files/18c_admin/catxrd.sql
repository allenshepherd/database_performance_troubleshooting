Rem
Rem $Header: rdbms/admin/catxrd.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem catxrd.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxrd.sql - CATalog creation for XDB RDBMS Dependents
Rem
Rem    DESCRIPTION
Rem      This script creates RDBMS objects that depend on XDB.
Rem
Rem    NOTES
Rem      catxrd.sql is run as part of the XDB install, after the
Rem      installation completes.  It is also run as part of an 
Rem      XDB upgrade, after the upgrade completes.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catxrd.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catxrd.sql 
Rem    SQL_PHASE: CATXRD
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      11/01/17 - 26281129: Support for new release model
Rem    dcolello    11/15/15 - move prvtgwm.sql to catxrd.sql
Rem    rpang       11/13/15 - Move EPG to catxrd.sql
Rem    surman      08/20/15 - 20772435: Move catsqlreg to catxrd
Rem    sramakri    02/19/15 - add catxmvrs.sql
Rem    raeburns    09/02/14 - Install XDB RDBMS Dependents
Rem    raeburns    09/02/14 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

@@catxlcr       -- Register XML schema definitions for LCRs
@@tsdpend.sql   -- Register Schemas for Transparent Sensitive Data Protection (TSDP)
@@catxmvrs      -- Catalog views for MV refresh stats 

Rem Sharding packages
@@prvtgwm.sql

Rem SQL registry table and view
@@catsqlreg

Rem Queryable patch inventory
@@prvtqopi.plb

Rem dbms_sqlpatch package header and body
@@dbmssqlpatch
@@prvtsqlpatch.plb

Rem Embedded PL/SQL Gateway catalog tables/views and package
@@catepg
@@dbmsepg
@@prvtepg.plb

@?/rdbms/admin/sqlsessend.sql
