Rem
Rem $Header: rdbms/admin/catnodpall.sql /main/1 2017/07/31 11:05:56 bwright Exp $
Rem
Rem catnodpall.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     catnodpall.sql - Drop all DataPump components
Rem
Rem    DESCRIPTION 
Rem
Rem    NOTES
Rem     This script only gets executed from downgrade scripts.  
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem     SQL_SOURCE_FILE: rdbms/admin/catnodpall.sql
Rem     SQL_SHIPPED_FILE: rdbms/admin/catnodpall.sql
Rem     SQL_PHASE: DOWNGRADE
Rem     SQL_STARTUP_MODE: DOWNGRADE
Rem     SQL_IGNORABLE_ERRORS: NONE
Rem     SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    bwright   06/21/17 - Bug 25651930: Add OBSOLETE, ALL script options
Rem    bwright   06/21/17 - Created
Rem

--------------------------------------------------
--     Start by dropping Data Pump's AQ tables
--------------------------------------------------
@@catnodpaq.sql

--------------------------------------------------
--     Wipe out all of Data Pump and Metadata API
--------------------------------------------------
@@catnodp.sql ALL

