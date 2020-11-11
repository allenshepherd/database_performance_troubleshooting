Rem
Rem $Header: rdbms/admin/awrsqrpt.sql /main/4 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrsqrpt.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrsqrpt.sql
Rem
Rem    DESCRIPTION
Rem      Script defaults the dbid and instance number to that of
Rem      the current intance connected-to and then calls awrsqrpi.sql
Rem      to produce a Workload report for a particular sql statement.      
Rem
Rem    NOTES
Rem      This report is based on the statspack sql report.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrsqrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrsqrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni    12/06/16 - specify con_dbid in AWR SQL report
Rem    adagarwa    01/05/05 - adagarwa_awr_sql_rpt
Rem    adagarwa    09/07/04 - Created
Rem


--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on verify off feedback off;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

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
column default_dbid new_value default_dbid noprint;

set termout off;

select '&&report_type' report_type_def from dual;

select '&&view_loc' view_loc_def from dual;

select (case when '&view_loc' = 'AWR_PDB' 
             then sys_context('userenv','con_dbid')
             else sys_context('userenv','dbid') end) default_dbid
from dual;

set termout on;
set newpage none;

prompt
prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select &default_dbid     dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

@@awrsqrpi.sql

undefine num_days;
undefine report_type;
undefine report_name;
undefine begin_snap;
undefine end_snap;
--
-- End of file





