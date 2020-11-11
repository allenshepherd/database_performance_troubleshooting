Rem
Rem $Header: rdbms/admin/dve102.sql /main/5 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dve102.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dve102.sql - Downgrade from 11g to 10gR2
Rem
Rem    DESCRIPTION
Rem      This Script should be run as SYSDBA after Relinking
Rem    the executable with DV turned off.
Rem
Rem    NOTES
Rem   *** PLEASE SEE The document for the exact steps for DV upgrade/downgrade *****
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dve102.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dve102.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: DOWNGRADE 
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dvdwgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    vigaur      05/22/08 - LRG 3408867
Rem    vigaur      04/16/08 - Call 11.1->11.2 migrate script
Rem    mxu         12/19/06 - 
Rem    rvissapr    12/01/06 - downgrade from 11gR1 to 10gR2
Rem    rvissapr    12/01/06 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

Rem Put Upgrade metadata changes here. Please SET  the current schema correctly
Rem Before putting in any SQL commands


Rem Downgrade Complete

@@dve111.sql

ALTER SESSION SET CURRENT_SCHEMA = SYS;

DROP PROCEDURE SYS.validate_dv;

EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '10.2.0');

