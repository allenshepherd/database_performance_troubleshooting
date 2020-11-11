Rem
Rem $Header: rdbms/admin/catwrrtb.sql /main/4 2014/02/20 12:45:38 surman Exp $
Rem
Rem catwrrtb.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrtb.sql - Catalog script for 
Rem                     the Workload Capture and Replay tables
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary tables for the 
Rem      Workload Capture and Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem      Almost all DML on the tables defined in 
Rem      this script comes from DBMS_WORKLOAD_CAPTURE.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrtb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrtb.sql
Rem SQL_PHASE: CATWRRTB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    kmorfoni    11/02/11 - Move creation of tables for workload intelligence
Rem                           from catwrr.sql to catwrrtb.sql
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - add REPLAY dict
Rem    veeve       01/25/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Create the common (shared by Capture and Replay) schema 
Rem and the Capture infrastructure tables 
@@catwrrtbc.sql

Rem
Rem Create the Replay infrastructure tables 
@@catwrrtbp.sql

Rem 
Rem Create all the tables required for workload intelligence
@@catwrrwitb.sql

@?/rdbms/admin/sqlsessend.sql
