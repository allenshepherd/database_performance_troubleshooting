Rem
Rem $Header: rdbms/admin/awrgdrpt.sql /main/4 2017/05/28 22:46:00 stanaya Exp $
Rem
Rem awrgdrpt.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrgdrpt.sql - AWR Global Diff Report
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid to that of the
Rem      current instance connected-to, defaults instance list to all 
Rem      available instances and then calls awrgdrpi.sql to produce
Rem      the Workload Repository RAC Compare Periods report.
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem      This report is based on the Statspack report.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      see the 'customer-customizable report settings' section in
Rem      awrgdrpi.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrgdrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrgdrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    07/26/16 - Use AWR_* views instead of DBA_HIST_* views
Rem    ilistvin    04/27/09 - add semicolon
Rem    ilistvin    12/17/07 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on;
column instance_numbers_or_all  new_value instance_numbers_or_all  noprint;
column instance_numbers_or_all2 new_value instance_numbers_or_all2 noprint;
column db_name   heading "DB Name" new_value db_name  format a12;
column dbid      heading "DB Id"   new_value dbid     format 9999999999 just c;
column dbid2     heading "DB Id"   new_value dbid2    format 9999999999 just c;

--
-- Find out if we are going to print report to html or to text
prompt
prompt Specify the Report Type
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt Would you like an HTML report, or a plain text report?
prompt Enter 'html' for an HTML report, or 'text' for plain text
prompt  Defaults to 'html'

column report_type new_value report_type;
set heading off;
select 'Type Specified: ',lower(nvl('&&report_type','html')) report_type from dual;
set heading on;

Rem
Rem Check if we are inside a PDB. If so, choose the AWR 
Rem ===================================================

@@getawrviewloc

Rem Define variables report_type_def and view_loc_def
Rem These variables will be used in awrrpti.sql to check if report type 
Rem and view location has been specified already

column report_type_def new_value report_type_def noprint;
column view_loc_def new_value view_loc_def noprint;

set heading off;
select '&&report_type' report_type_def from dual;
select '&&view_loc' view_loc_def from dual;
set heading on;

prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

column default_dbid new_value default_dbid noprint;
select (case when '&view_loc' = 'AWR_PDB' 
             then sys_context('userenv','con_dbid')
             else sys_context('userenv','dbid') end) default_dbid
from dual;

select &default_dbid     dbid
     , &default_dbid     dbid2
     , d.name            db_name
     , 'ALL'             instance_numbers_or_all
     , 'ALL'             instance_numbers_or_all2
  from v$database d;

@@awrgdrpi

undefine num_days;
undefine report_type;
undefine report_name;
undefine begin_snap;
undefine end_snap;

undefine report_type_def;
undefine view_loc_def;
undefine default_dbid;

-- Undefine all variables declare in getawrviewloc
undefine default_view_location
undefine is_pdb
undefine view_loc
undefine awr_location

--
-- End of file
