Rem
Rem $Header: rdbms/admin/catnowrrc.sql /main/9 2017/11/16 14:50:00 josmamar Exp $
Rem
Rem catnowrrc.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnowrrc.sql - Catalog script to delete the 
Rem                      Workload Capture schema
Rem
Rem    DESCRIPTION
Rem      Undo file for all objects created in catwrrtbc.sql
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnowrrc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnowrrc.sql
Rem SQL_PHASE: CATNOWRRC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    josmamar    11/13/17 - bug 26989795: long sql text support
Rem    qinwu       06/07/17 - bug 25975538: sql text and support for remapping
Rem    josmamar    05/12/17 - bug 22374149: drop capture files table
Rem    yberezin    02/02/17 - bug 25356940: drop views
Rem    quotran     07/17/15 - bug 21610276: support always-on capture
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    rcolle      05/08/08 - drop WRR$_CAPTURE_UC_GRAPH
Rem    veeve       07/13/06 - stop capture in catnowrr.sql
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       01/25/06 - Created

Rem =========================================================
Rem Dropping the Workload Capture Tables
Rem =========================================================

delete from PROPS$ where name = 'WORKLOAD_CAPTURE_MODE';
commit;

drop public synonym DBA_WORKLOAD_CAPTURES;
drop public synonym DBA_WORKLOAD_FILTERS;
drop public synonym DBA_WORKLOAD_CAPTURE_SQLTEXT;
drop public synonym DBA_WORKLOAD_LONG_SQLTEXT;

drop public synonym CDB_WORKLOAD_CAPTURES;
drop public synonym CDB_WORKLOAD_FILTERS;

drop view DBA_WORKLOAD_CAPTURES;
drop view DBA_WORKLOAD_FILTERS;
drop view DBA_WORKLOAD_CAPTURE_SQLTEXT;
drop view DBA_WORKLOAD_LONG_SQLTEXT;

drop view CDB_WORKLOAD_FILTERS;
drop view CDB_WORKLOAD_CAPTURES;

drop table WRR$_CAPTURES;
drop table WRR$_CAPTURE_BUCKETS;
drop table WRR$_CAPTURE_STATS;
drop table WRR$_CAPTURE_UC_GRAPH;
drop table WRR$_CAPTURE_FILES;
drop table WRR$_CAPTURE_SQL_TMP;
drop table WRR$_CAPTURE_SQLTEXT;
drop table WRR$_CAPTURE_LONG_SQLTEXT;

drop sequence WRR$_CAPTURE_ID;
