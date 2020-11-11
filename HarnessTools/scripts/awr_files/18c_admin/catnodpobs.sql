Rem
Rem $Header: rdbms/admin/catnodpobs.sql /main/1 2017/07/31 11:05:56 bwright Exp $
Rem
Rem catnodpobs.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     catnodpobs.sql - Drop obsolete/required DataPump components
Rem
Rem    DESCRIPTION 
Rem
Rem    NOTES
Rem     This script only gets executed from dpload.sql  
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem     SQL_SOURCE_FILE: rdbms/admin/catnodpobs.sql
Rem     SQL_SHIPPED_FILE: rdbms/admin/catnodpobs.sql
Rem     SQL_PHASE: UPGRADE
Rem     SQL_STARTUP_MODE: NORMAL
Rem     SQL_IGNORABLE_ERRORS: NONE
Rem     SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    bwright   06/21/17 - Bug 25651930: Add OBSOLETE, ALL script options
Rem    bwright   06/21/17 - Created
Rem

----------------------------------------------
--     Wipe out obsolete/required objects
----------------------------------------------
@@catnodp.sql OBSOLETE

