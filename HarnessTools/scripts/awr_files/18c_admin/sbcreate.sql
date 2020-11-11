Rem
Rem sbcreate.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbcreate.sql - StandBy statspack CREATion  
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which creates the STANDBY STATSPACK user, 
Rem      tables and package for the performance diagnostic tool STANDBY 
Rem      STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal (SYS).
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbcreate.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbcreate.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    zhefan      07/08/15 - bug 21393238: Add tests for standby statspack
Rem    pmurthy     03/27/14 - bug#18474488 - Remove connect; Use CURRENT_SCHEMA
Rem    sankejai    04/11/11 - set _oracle_script in session after connect
Rem    shsong      03/07/07 - Create stdbyperf user
Rem    wlohwass    12/04/06 - Created
Rem

-- Set this parameter for creating common objects in consolidated database
alter session set "_oracle_script" = TRUE;

--  Create user and required privileges
@@sbcusr

-- Next two scripts run as stdbyperf user
ALTER SESSION SET CURRENT_SCHEMA = STDBYPERF;

-- Create standby statspack tables
@@sbctab

-- Add a standby database instance to the configuration
@@sbaddins

