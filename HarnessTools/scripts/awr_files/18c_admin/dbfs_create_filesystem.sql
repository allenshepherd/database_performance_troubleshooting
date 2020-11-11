Rem
Rem $Header: rdbms/admin/dbfs_create_filesystem.sql /main/6 2017/05/28 22:46:04 stanaya Exp $
Rem
Rem dbfs_create_filesystem.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbfs_create_filesystem.sql - DBFS create filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS create filesystem script
Rem      Usage: sqlplus <dbfs_user> @dbfs_create_filesystem.sql  
Rem             <tablespace_name> <table_name> 
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbfs_create_filesystem.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbfs_create_filesystem.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    xihua       14/10/10 - Bug 10104462: Improved method to drop filesystems
Rem    nmukherj    05/30/10 - changing default to non-partitioned SF segment
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

define ts_name      = &1
define fs_name      = &2

@@dbfs_create_filesystem_advanced.sql &ts_name &fs_name nocompress nodeduplicate noencrypt non-partition

undefine ts_name
undefine fs_name

