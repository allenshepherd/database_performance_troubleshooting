Rem
Rem $Header: rdbms/admin/sbdusr.sql /main/2 2017/05/28 22:46:09 stanaya Exp $
Rem
Rem sbdusr.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      sbdusr.sql - StandBy statspack Drop USeR
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to DROP user which contains the
Rem      standby statspack database objects.
Rem
Rem    NOTES
Rem      Must be run when connected to SYS (or internal)      
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/sbdusr.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/sbdusr.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      04/23/07 - Created
Rem

set echo off;

spool sbdusr.lis

Rem
Rem  Drop STDBYPERF user cascade
Rem

drop user stdbyperf cascade;

prompt
prompt NOTE:
prompt   SBDUSR complete. Please check sbdusr.lis for any errors.
prompt

spool off;
set echo on;


