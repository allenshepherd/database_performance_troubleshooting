Rem
Rem $Header: rdbms/admin/awrddrpt.sql /main/5 2017/05/28 22:46:00 stanaya Exp $
Rem
Rem awrddrpt.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrddrpt.sql
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid and instance number to that of the
Rem      current instance connected-to, then calls awrddrpi.sql to produce
Rem      the Workload Repository Compare Periods report.
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem      This report is based on the Statspack report.
Rem
Rem      If you want to use this script in an non-interactive fashion,
Rem      see the 'customer-customizable report settings' section in
Rem      awrrpti.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrddrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrddrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rmorant     07/05/16 - Bug23567371 enable pdb report
Rem    arbalakr    07/26/16 - Use AWR_* views instead of DBA_HIST_* views
Rem    ysarig      05/27/05 - Fix comments for compare period report 
Rem    mramache    06/17/04 - mramache_diff_diff
Rem    mramache    06/01/04 - rename awrddrpti to awrddrpi 
Rem    ilistvin    05/25/04 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_num2 heading "Inst Num"  new_value inst_num2 format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;
column dbid2     heading "DB Id"     new_value dbid2     format 9999999999 just c;

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
     , i.instance_number inst_num
     , i.instance_number inst_num2
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

@@awrddrpi

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

