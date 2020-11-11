Rem
Rem $Header: rdbms/admin/rtaddmrpt.sql /main/2 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem rtaddmrpt.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rtaddmrpt.sql
Rem
Rem    DESCRIPTION
Rem      This script default the dbid to that of the current database 
Rem      connected-to, then calls rtaddmrpti.sql to produce the
Rem      Real Time ADDM report
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/rtaddmrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/rtaddmrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    08/15/13 - Created
Rem

set echo off heading on underline on;
column dbid heading "DB Id" new_value dbid;

prompt
prompt Current Database
prompt ~~~~~~~~~~~~~~~~

select d.dbid from v$database d;

define begin_time = '';
define duration =  '';

Rem rtaddmrpti.sql now

@@rtaddmrpti

undefine dbid
undefine begin_time
undefine duration
