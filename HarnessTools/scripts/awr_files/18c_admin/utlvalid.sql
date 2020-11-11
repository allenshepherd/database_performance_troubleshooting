rem 
Rem Copyright (c) 1990, 1995, 1996, 1998 by Oracle Corporation
Rem NAME
REM    UTLVALID.SQL
Rem  FUNCTION
Rem    Creates the default table for storing the output of the
Rem    analyze validate command on a partitioned table
Rem  NOTES
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlvalid.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlvalid.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem  MODIFIED
Rem     traney     04/05/11 - 35209: long identifiers dictionary upgrade
Rem     syeung     06/17/98 - add subpartition_name                            
Rem     mmonajje   05/21/96 - Replace timestamp col name with analyze_timestamp
Rem     sbasu      05/07/96 - Remove echo setting
Rem     ssamu      01/09/96 - new file utlvalid.sql
Rem

create table INVALID_ROWS (
  owner_name         varchar2(128),
  table_name         varchar2(128),
  partition_name     varchar2(128),
  subpartition_name  varchar2(128),
  head_rowid         rowid,
  analyze_timestamp  date
);

