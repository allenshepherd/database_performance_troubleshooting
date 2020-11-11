Rem
Rem $Header: rdbms/admin/catsodacoll.sql /main/5 2017/02/13 00:01:01 prthiaga Exp $
Rem
Rem catsodacoll.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catsodacoll.sql - CATalog script for SODA
Rem
Rem    DESCRIPTION
Rem      Installs the packages/views required for using the JSON PL/SQL 
Rem      collection API
Rem
Rem    NOTES
Rem      Must be run as connected to SYS
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catsodacoll.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catsodacoll.sql
Rem    SQL_PHASE: CATSODACOLL
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prthiaga    01/31/17 - Bug 25477695: Add PL/SQL SODA stuff
Rem    prthiaga    10/19/15 - Bug 22067651: Add DBMS_SODA_ADMIN pkg spec
Rem    prthiaga    05/18/15 - Bug 21116398: Remove SET stmts
Rem    prthiaga    07/29/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--
-- Create tables & Views
--

@@catsodaddl.sql
@@catsodaview.sql

--
-- DBMS_SODA_ADMIN Package Specification
--

@@dbmssodacoll.sql

--
-- DBMS_SODA_DOM Package Specification
--

@@dbmssodadom.sql

--
-- SYS.DBMS_SODA_UTIL package Specification
--
@@dbmssodautil.sql
@@prvtsodautil.plb

--
-- DBMS_SODA_ADMIN Package Body
--
@@prvtsodadml.plb
@@prvtsodacoll.plb

--
-- DBMS_SODA_DOM Package Body
--
@@prvtsodadom.plb

--
-- DBMS_SODA body and types required for SODA PL/SQL
--
@@dbmssodapls.sql
@@prvtsodapls.plb

@?/rdbms/admin/sqlsessend.sql
