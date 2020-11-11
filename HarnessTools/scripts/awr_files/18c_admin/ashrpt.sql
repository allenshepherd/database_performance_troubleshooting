Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      ashrpt.sql
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid and instance number to that of the
Rem      current instance connected-to, then calls ashrpti.sql to produce
Rem      the ASH report.
Rem
Rem    NOTES
Rem      Run as select_catalog privileges.  
Rem
Rem      If you want to use this script in a non-interactive fashion do
Rem      something like the following:
Rem
Rem      Say for example you want to generate a TEXT ASH Report for the
Rem      past 30 minutes in /tmp/ashrpt.txt, use the following SQL*Plus script:
Rem
Rem        define report_type = 'text'; -- 'html' for HTML
Rem        define begin_time  = '-30';  -- Can specify both absolute and relative 
Rem                                     -- times. Look in ashrpti.sql for syntax.
Rem        define duration    = '';     -- NULL defaults to 'till' current time
Rem        define report_name = '/tmp/ashrpt.txt';
Rem        @?/rdbms/admin/ashrpt
Rem
Rem      If you want to generate a HTML ASH Report using AWR snapshots 
Rem      imported from other databases or AWR snapshots from other instances
Rem      in a cluster, use a SQL*Plus script similar to the following:
Rem
Rem        define dbid        = 1234567890; -- NULL defaults to current database
Rem        define inst_num    = 2;          -- NULL defaults to current instance
Rem        define report_type = 'html';     -- 'text' for TEXT
Rem        define begin_time  = '-30';
Rem        define duration    = '';         -- NULL defaults to 'till current time'
Rem        define report_name = '/tmp/ashrpt.txt';
Rem        define slot_width  = '';
Rem        define target_session_id   = '';
Rem        define target_sql_id       = '';
Rem        define target_wait_class   = '';
Rem        define target_service_hash = '';
Rem        define target_module_name  = '';
Rem        define target_action_name  = '';
Rem        define target_client_id    = '';
Rem        define target_plsql_entry  = '';
Rem        define target_container    = '';
Rem        @?/rdbms/admin/ashrpti
Rem
Rem      If you want to generate a HTML ASH Report for times between 9am-5pm today
Rem      in /tmp/sql_ashrpt.txt and want to target the report on a particular
Rem      SQL_ID 'abcdefghij123', use a script similar to the following:
Rem
Rem        define dbid        = '';       -- NULL defaults to current database
Rem        define inst_num    = '';       -- NULL defaults to current instance
Rem        define report_type = 'html';   -- 'text' for TEXT
Rem        define begin_time  = '09:00';
Rem        define duration    = 480;      -- 9-5 == 8 hrs or 480 mins
Rem        define report_name = '/tmp/sql_ashrpt.txt';
Rem        define slot_width  = '';
Rem        define target_session_id   = '';
Rem        define target_sql_id       = 'abcdefghij123';
Rem        define target_wait_class   = '';
Rem        define target_service_hash = '';
Rem        define target_module_name  = '';
Rem        define target_action_name  = '';
Rem        define target_client_id    = '';
Rem        define target_plsql_entry  = '';
Rem        define target_container    = '';
Rem        @?/rdbms/admin/ashrpti
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/ashrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/ashrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    06/15/16 - Fix the call to default_report_dbid.
Rem    arbalakr    05/04/16 - 23224051:Use default_report_dbid instead of
Rem                           get_current_owner_dbid
Rem    arbalakr    03/22/16 - Bug 22930439: Get the correct default dbid inside
Rem                           PDB
Rem    ushaft      03/13/12 - added container target
Rem    adagarwa    06/24/05 - added plsql_entry target
Rem    veeve       05/11/05 - add support for slot_width input
Rem    veeve       01/17/05 - add support for report targets
Rem    veeve       06/24/04 - added more NOTES
Rem    veeve       06/10/04 - veeve_ash_report_r2
Rem    veeve       06/04/04 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

define default_report_type = 'html';

prompt
prompt Specify the Report Type
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt Enter 'html' for an HTML report, or 'text' for plain text
prompt Defaults to '&&default_report_type'

column report_type new_value report_type;
set heading off
select 'Type Specified: ',
       lower( (case when '&&report_type' IS NULL 
                    then '&&default_report_type'
                    when '&&report_type' <> 'text'
                    then 'html'
                    else '&&report_type' end) ) report_type
from dual;
set heading on

Rem
Rem Check if we are inside a PDB. If so, choose the AWR 
Rem ===================================================

@@getawrviewloc


variable default_dbid number;
set termout off;

DECLARE
  dynsql VARCHAR2(256);
BEGIN
  dynsql := 
    'select local_awrdbid from ' || '&view_loc' || '_wr_settings';
  dbms_output.put_line(dynsql);
  execute immediate dynsql into :default_dbid;
END;
/
set termout on;


Rem Define variables report_type_def and view_loc_def
Rem These variables will be used in ashrpti.sql to check if report type 
Rem and view location has been specified already

column report_type_def new_value report_type_def noprint;
column view_loc_def new_value view_loc_def noprint;

set heading off;
select '&&report_type' report_type_def from dual;
select '&&view_loc' view_loc_def from dual;
set heading on;

prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select :default_dbid dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

Rem
Rem Define slot width and all report targets to be NULL here, 
Rem so that ashrpti can be used directly if one or more 
Rem report targets need to be specified.
define slot_width = '';
define target_session_id = '';
define target_sql_id = '';
define target_wait_class = '';
define target_service_hash = '';
define target_module_name = '';
define target_action_name = '';
define target_client_id = '';
define target_plsql_entry = '';
define target_container = '';

Rem ashrpti.sql now
@@ashrpti

-- Undefine all variables declared here
undefine inst_num
undefine inst_name
undefine db_name
undefine dbid
undefine default_report_type
undefine report_type
undefine report_type_def
undefine view_loc_def
undefine slot_width
undefine target_session_id
undefine target_sql_id
undefine target_wait_class
undefine target_service_hash
undefine target_module_name
undefine target_action_name
undefine target_client_id
undefine target_plsql_entry
undefine target_container

-- Undefine all variables declare in getawrviewloc
undefine default_view_location
undefine is_pdb
undefine view_loc
undefine awr_location

--
-- End of file
