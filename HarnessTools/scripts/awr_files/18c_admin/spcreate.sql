Rem
Rem $Header: rdbms/admin/spcreate.sql /main/9 2017/05/28 22:46:10 stanaya Exp $
Rem
Rem spcreate.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      spcreate.sql - Statistics Create
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which creates the STATSPACK user, 
Rem      tables and package for the performance diagnostic tool STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/spcreate.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/spcreate.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kchou       01/12/17 - Bug# 25233027 - Set _oracle_script=FALSE at the
Rem                           end
Rem    zhefan      07/08/15 - bug 21393238: Add tests for standby statspack
Rem    krajaman    08/10/12 - bug#14407622 - Remove connect; Use CURRENT_SCHEMA
Rem    sankejai    04/11/11 - set _oracle_script in session after connect
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    12/06/99 - 1103031
Rem    cdialeri    08/13/99 - Created
Rem

-- Set this parameter for creating common objects in consolidated database
alter session set "_oracle_script" = TRUE;

--  Create PERFSTAT user and required privileges
@@spcusr

-- Next two scripts run as perfstat user
ALTER SESSION SET CURRENT_SCHEMA = PERFSTAT;

-- Create statspack tables
@@spctab

-- Create the statistics Package
@@spcpkg

-- Bug#25233027: xxx Set this parameter to FALSE for creating common objects in consolidated database
alter session set "_oracle_script" = FALSE;

