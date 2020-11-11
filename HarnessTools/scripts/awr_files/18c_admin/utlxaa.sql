Rem
Rem $Header: rdbms/admin/utlxaa.sql /main/3 2017/05/28 22:46:13 stanaya Exp $
Rem
Rem utlxaa.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlxaa.sql - Table layout for SQL Access Advisor
Rem
Rem    DESCRIPTION
Rem      Defines a user-defined workload table for SQL Access Advisor
Rem
Rem    NOTES
Rem      The table is used as workload source for SQL Access Advisor.  The
Rem      user will insert desirable SQL statements into the table and then
Rem      specify the table as a workload source within SQL Access Advisor.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlxaa.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlxaa.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    gssmith     07/27/04 - gssmith_bug-3765588
Rem    gssmith     07/20/04 - Created
Rem

Rem
Rem     Create the table
Rem

SET ECHO ON

CREATE TABLE user_workload
  (
    username              varchar2(128),       /* User who executes statement */
    module                varchar2(64),           /* Application module name */
    action                varchar2(64),           /* Application action name */
    elapsed_time          number,                  /* Elapsed time for query */
    cpu_time              number,                      /* CPU time for query */
    buffer_gets           number,           /* Buffer gets consumed by query */
    disk_reads            number,            /* Disk reads consumed by query */
    rows_processed        number,       /* Number of rows processed by query */
    executions            number,          /* Number of times query executed */
    optimizer_cost        number,                /* Optimizer cost for query */
    priority              number,                /* User-priority (1,2 or 3) */
    last_execution_date   date,                  /* Last time query executed */
    stat_period           number,        /* Window execution time in seconds */
    sql_text              clob                              /* Full SQL Text */
  );
