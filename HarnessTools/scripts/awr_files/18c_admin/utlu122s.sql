Rem
Rem $Header: rdbms/admin/utlu122s.sql /main/4 2017/04/27 17:09:46 raeburns Exp $
Rem
Rem utlu122s.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
SET ECHO OFF
Rem    NAME
Rem      utlu122s.sql - UTiLity Upgrade Status 
Rem
Rem    DESCRIPTION
Rem      This script provides information about databases that have 
Rem      been upgraded to 12.2
Rem    NOTES
Rem      Connect AS SYSDBA 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlu122s.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlu122s.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UTILITY for SQL_PHASE
Rem    frealvar    07/30/16 - Bug 24332006 added missing metadata
Rem    jerrede     09/01/15 - Change to call catresults.sql
Rem    hvieyra     11/26/14 - post-upgrade status tool after db upgrade to 12.2 
Rem    hvieyra     11/26/14 - Created
Rem

--
-- Call catresults to do the work
--
@@catresults.sql

