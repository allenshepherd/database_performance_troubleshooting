Rem
Rem $Header: rdbms/admin/catrms.sql /main/2 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catrms.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrms.sql - CATalog script for transparent gateway for RMS
Rem
Rem    DESCRIPTION
Rem      Create utility package to be used in combination with Transparent
Rem      Gateway for RMS
Rem
Rem      Objects created by this script are:
Rem          dbms_tg4rms      Package containing prototypes for utility procs
Rem          dbms_tg4rms      Package body containing implementation
Rem          dbms_tg4rms      Public synonym for package
Rem                                    
Rem    NOTES
Rem      This script must be run while connected as SYS
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catrms.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catrms.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kpeyetti    09/14/01 - Merged kpeyetti_dbms_hs_errors
Rem    kpeyetti    09/11/01 - Created
Rem

-- 
--############################################################################# 
-- 
--############################################################################# 
--  

-- Install the dbms_tg4rms.package

@@dbmsrms
@@prvtrms.plb

commit;
