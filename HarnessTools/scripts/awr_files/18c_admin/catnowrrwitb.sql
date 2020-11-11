Rem
Rem $Header: rdbms/admin/catnowrrwitb.sql /main/3 2017/02/10 09:39:51 yberezin Exp $
Rem
Rem catnowrrwitb.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnowrrwitb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnowrrwitb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnowrrwitb.sql
Rem SQL_PHASE: CATNOWRRWITB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    02/02/17 - bug 25356940: drop views
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    kmorfoni    06/24/11 - Created

Rem =========================================================
Rem Dropping the Workload Intelligence Tables
Rem =========================================================

drop public synonym DBA_WI_CAPTURE_FILES;
drop public synonym DBA_WI_JOBS;
drop public synonym DBA_WI_OBJECTS;
drop public synonym DBA_WI_PATTERNS;
drop public synonym DBA_WI_PATTERN_ITEMS;
drop public synonym DBA_WI_STATEMENTS;
drop public synonym DBA_WI_TEMPLATES;
drop public synonym DBA_WI_TEMPLATE_EXECUTIONS;

drop public synonym CDB_WI_CAPTURE_FILES;
drop public synonym CDB_WI_JOBS;
drop public synonym CDB_WI_OBJECTS;
drop public synonym CDB_WI_PATTERNS;
drop public synonym CDB_WI_PATTERN_ITEMS;
drop public synonym CDB_WI_STATEMENTS;
drop public synonym CDB_WI_TEMPLATES;
drop public synonym CDB_WI_TEMPLATE_EXECUTIONS;

drop view DBA_WI_CAPTURE_FILES;
drop view DBA_WI_JOBS;
drop view DBA_WI_OBJECTS;
drop view DBA_WI_PATTERNS;
drop view DBA_WI_PATTERN_ITEMS;
drop view DBA_WI_STATEMENTS;
drop view DBA_WI_TEMPLATES;
drop view DBA_WI_TEMPLATE_EXECUTIONS;

drop view CDB_WI_CAPTURE_FILES;
drop view CDB_WI_JOBS;
drop view CDB_WI_OBJECTS;
drop view CDB_WI_PATTERNS;
drop view CDB_WI_PATTERN_ITEMS;
drop view CDB_WI_STATEMENTS;
drop view CDB_WI_TEMPLATES;
drop view CDB_WI_TEMPLATE_EXECUTIONS;

drop table WI$_FREQUENT_PATTERN_METADATA;
drop table WI$_FREQUENT_PATTERN_ITEM;
drop table WI$_FREQUENT_PATTERN;
drop table WI$_EXECUTION_ORDER;
drop table WI$_CAPTURE_FILE;
drop table WI$_STATEMENT;
drop table WI$_OBJECT;
drop table WI$_TEMPLATE;
drop table WI$_JOB;

drop sequence WI$_JOB_ID;
