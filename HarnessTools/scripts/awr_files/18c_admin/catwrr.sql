Rem
Rem $Header: rdbms/admin/catwrr.sql /main/6 2017/02/10 09:39:51 yberezin Exp $
Rem
Rem catwrr.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrr.sql - Catalog script for Workload Capture
Rem                   and Replay
Rem
Rem    DESCRIPTION
Rem      Creates tables, views, package for Workload Capture
Rem      and Replay
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrr.sql
Rem SQL_PHASE: CATWRR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    02/02/17 - compile dependent objects
Rem    qinwu       11/26/16 - bug 24923199: add prvtwrr_report.plb
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    kmorfoni    11/02/11 - Move creation of tables for workload intelligence
Rem                           from catwrr.sql to catwrrtb.sql
Rem    kmorfoni    06/15/11 - Create tables required for workload intelligence
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       02/01/06 - Created
Rem

Rem 
Rem Create all the dictionary tables
@@catwrrtb.sql

Rem
Rem Create all the dictionary views
@@catwrrvw.sql

Rem
Rem Create the DBA_WORKLOAD_ package definitions
@@dbmswrr.sql

Rem
Rem Create the DBA_WORKLOAD_ package bodys
@@prvtwrr_report.plb
@@prvtwrr.plb

-- packages and procedures that depend on our objects
alter package   DBMS_RAT_MASK             compile body;
alter package   DBMS_SWRF_REPORT_INTERNAL compile body;
alter package   PRVT_CPADDM               compile body;
alter procedure DBMS_FEATURE_WCR_CAPTURE  compile;
alter procedure DBMS_FEATURE_WCR_REPLAY   compile;
