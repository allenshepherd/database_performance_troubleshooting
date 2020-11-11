Rem
Rem $Header: rdbms/admin/dbfusrpt.sql /main/2 2017/05/28 22:46:04 stanaya Exp $
Rem
Rem dbfusrpt.sql
Rem
Rem Copyright (c) 2005, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbfusrpt.sql - DB Feature Usage Report
Rem
Rem    DESCRIPTION
Rem      This script generates a DB Feature Usage report
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem      This script defaults the dbid and version to the local database.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbfusrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbfusrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      05/25/05 - mlfeng_track_cpu
Rem    mlfeng      05/10/05 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on;
column version   heading "Version"   new_value version   format a13;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Database
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.version         version
  from v$database d,
       v$instance i;

@@dbfusrpi

undefine report_type;
undefine report_name;
--
-- End of file


