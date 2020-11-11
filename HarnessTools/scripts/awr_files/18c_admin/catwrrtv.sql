Rem
Rem $Header: rdbms/admin/catwrrtv.sql /main/2 2017/02/27 18:28:31 stanaya Exp $
Rem
Rem catwrrtv.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrtv.sql - Catalog script for Workload Capture
Rem                     and Replay
Rem
Rem    DESCRIPTION
Rem      Creates Workload Capture and Replays tables and views.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrtv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrtv.sql
Rem SQL_PHASE: CATWRRTV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    veeve       06/14/06 - Created
Rem

Rem 
Rem Create all the dictionary tables
@@catwrrtb.sql

Rem
Rem Create all the dictionary views
@@catwrrvw.sql

