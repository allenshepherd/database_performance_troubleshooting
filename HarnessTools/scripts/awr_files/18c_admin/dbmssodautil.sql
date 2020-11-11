Rem
Rem $Header: rdbms/admin/dbmssodautil.sql /st_rdbms_18.0/1 2018/04/11 10:34:37 sriksure Exp $
Rem
Rem dbmssodautil.sql
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssodautil.sql - utility functions to be used by 
Rem                         JSON Collections API
Rem
Rem    DESCRIPTION
Rem      These functions are only allowed to be invoked by
Rem      xdb.dbms_collections for accessing SYS objects.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssodautil.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssodautil.sql
Rem    SQL_PHASE: DBMSSODAUTIL 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catsodacoll.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sriksure    04/02/18 - Bug 27698424: Backport SODA bugs from main
Rem    morgiyan    04/30/17 - Bugs 25537626,25537633,25655779,25798355,25972801:
Rem                           various fixes and enhancements for SODA OCI/PLSQL
Rem                           first (12.2.0.2) release.
Rem    prthiaga    04/20/17 - Bug 25927228: Allow sys.dbms_soda
Rem    prthiaga    08/03/15 - Bug 24350036: Allow xdb.dbms_soda_dml
Rem    prthiaga    03/10/15 - Bug 22905133: Allow xdb.dbms_soda_dom
Rem    prthiaga    02/10/16 - Bug 22675745: Add raise_system_error
Rem    prthiaga    06/02/15 - Bug 21188761: Add getCharSet
Rem    prthiaga    05/20/15 - Bug 21116398: Remove SET stmts
Rem    prthiaga    03/17/15 - Bug 20703629: Add getSCN
Rem    prthiaga    10/02/14 - Add checkColumns
Rem    prthiaga    07/29/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package SYS.dbms_soda_util authid definer accessible by
(package xdb.dbms_soda_admin, package xdb.dbms_soda_dom,
 package xdb.dbms_soda_dml, package sys.dbms_soda)
is
  type VCTAB is table of varchar2(32767) index by binary_integer;
  procedure getLongStringEnabled(P_LONG_STRINGS out varchar2);
  procedure getNLSCharSet(P_CS out varchar2);
  procedure getCharSet(P_CS out varchar2);
  procedure checkCompat;
  procedure checkSequenceExists (P_SCHEMA IN VARCHAR2, P_SEQNAME IN VARCHAR2,
                                 P_FOUND OUT boolean);
  procedure checkTableExists (P_SCHEMA IN VARCHAR2, P_TABNAME IN VARCHAR2,
                              P_FOUND OUT boolean);
  procedure checkViewExists (P_SCHEMA IN VARCHAR2, P_VIEWNAME IN VARCHAR2,
                             P_FOUND OUT boolean);
  procedure checkColumns (P_SCHEMA in varchar2, P_OBJNAME in varchar,
                          P_NCOLS in binary_integer,
                          P_COLNAMES in VCTAB, P_COLTYPES in VCTAB,
                          P_FOUND out boolean);
  procedure getSCN(P_SCN out NUMBER);
  procedure raise_system_error(error_number IN INTEGER, arg1 IN VARCHAR2,
                               arg2 IN VARCHAR2, arg3 IN VARCHAR2);
  procedure raise_system_error(error_number IN INTEGER, arg1 IN VARCHAR2,
                               arg2 IN VARCHAR2);
  procedure raise_system_error(error_number IN INTEGER, arg1 IN VARCHAR2);
  procedure raise_system_error(error_number IN INTEGER);


end dbms_soda_util;
/
show errors;
/

@?/rdbms/admin/sqlsessend.sql
