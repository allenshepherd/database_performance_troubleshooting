Rem
Rem $Header: rdbms/admin/dbmstutl.sql /main/2 2017/05/28 22:46:05 stanaya Exp $
Rem
Rem dbmstutl.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstutl.sql - DBMS Trace UTiLity package
Rem
Rem    DESCRIPTION
Rem      This file provides utility packages for using KST traces
Rem      and viewing x$trace online.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmstutl.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmstutl.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    ilam        04/21/04 - ilam_trcldr_add_trc_support 
Rem    ilam        01/27/04 - Created
Rem

Rem Format the output of x$trace for a nicer reading
SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET UNDERLINE =

Rem formatting each column
COLUMN event        HEADING 'trace|event'     FORMAT 99999
COLUMN opcode       HEADING 'opcode'          FORMAT 999
COLUMN time         HEADING 'time'
COLUMN seq#         HEADING 'sequence|number'
COLUMN sid          HEADING 'sess|id'         FORMAT 9999
COLUMN pid          HEADING 'orapid'          FORMAT 99999
COLUMN instancename HEADING 'instance|name'   FORMAT A8
COLUMN procname     HEADING 'proc|name'       FORMAT A4
COLUMN ospid        HEADING 'ospid'           FORMAT 99999
COLUMN bugno        HEADING 'bug#'            FORMAT 99999999
COLUMN data         HEADING 'trace data'      FORMAT A80 WORD_WRAPPED 
