Rem
Rem $Header: rdbms/admin/sbdrop.sql /main/2 2017/05/28 22:46:09 stanaya Exp $
Rem
Rem sbdrop.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbdrop.sql - StandBy statspack DROP user and tables
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file drop user and tables for readable standby
Rem      performance diagnostic tool STANDBY STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbdrop.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbdrop.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      04/24/07 - Created
Rem

--
--  Drop Standby Statspack's tables and indexes

@@sbdtab


--
--  Drop STDBYPERF user

@@sbdusr

