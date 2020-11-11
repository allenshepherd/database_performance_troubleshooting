
Rem $Header: rdbms/admin/awrrpt.sql /main/6 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrrpt.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrrpt.sql
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid and instance number to that of the
Rem      current instance connected-to, then calls awrrpti.sql to produce
Rem      the Workload Repository report.
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
Rem    SQL_SOURCE_FILE: rdbms/admin/awrrpt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrrpt.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    07/21/16 - Use awr_* view instead of dba_hist_* views
Rem    arbalakr    06/17/16 - Remove the call to default_report_dbid
Rem    osuro       04/12/16 - Update dbid for pluggable databases 
Rem    ardesai     01/22/16 - bug[22334236] select proper default dbid
Rem    pbelknap    10/24/03 - swrfrpt to awrrpt 
Rem    pbelknap    10/14/03 - moving params to rpti 
Rem    pbelknap    10/02/03 - adding non-interactive mode cmnts 
Rem    mlfeng      09/10/03 - heading on 
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      01/27/03 - mlfeng_swrf_reporting
Rem    mlfeng      01/13/03 - Update comments
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/12/02 - Created
Rem

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column dbid      heading "DB Id"     new_value dbid   format 9999999999 just c;
column dbclmn                        new_value dbclmn noprint;
column rpti_script                   new_value rpti_script noprint;
column instance_numbers_or_all       new_value instance_numbers_or_all noprint;

variable    input_script     varchar2(10);
define      dflt_rpt='awrrpt'

prompt
prompt Specify the Report Type
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt AWR reports can be generated in the following formats.  Please enter the
prompt name of the format at the prompt.  Default value is 'html'.
prompt
prompt   'html'          HTML format (default)
prompt   'text'          Text format
prompt   'active-html'   Includes Performance Hub active report
prompt  

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

--
-- this script is called in two way
--   1. invoked through awrgrpt.sql
--      @@awrrpt.sql 
--   2. directly
--      SQL> awrrpt
-- these two cases are deferentiated through 'awrgrpt_rptv' variable 
-- in #1, awrgrpt.sql defines 'awrgrpt_rptv' indicating it is 'awrgrpt' 
-- in #2  'awrgrpt_rptv' will not be defined where we need to get the 
--        default value awrrpt
-- below logic will defines the varaible either through awrgrpt.sql
-- or in this script itself
--
set termout  off;
set feedback off;
set verify   off;
column awrgrpt_rptc new_value awrgrpt_rptv noprint;
select null awrgrpt_rptc from dual where 1 = 2;
select nvl('&awrgrpt_rptv','&dflt_rpt') awrgrpt_rptc from dual;
set termout on


set serveroutput on;
declare
  is_grpt      varchar(10) := '&awrgrpt_rptv';
  dbname       varchar(25);
  con_name     varchar(25);
  inst_number  number;
  inst_name    varchar(25);
  con_id       number;      -- container id
  rdbid        number;      -- root dbid
  cdbid        number;      -- current dbid
  awrdbid      number;      -- awr dbid
  is_cdb       varchar(4) := 'NO';
begin
  -- get the current db/instance information
  select d.con_dbid, d.name, sys_context('USERENV', 'CON_NAME')
        ,i.instance_number, i.instance_name
  into   cdbid, dbname, con_name, inst_number, inst_name 
  from   v$database d,
         v$instance i;

  if (is_grpt = 'awrgrpt') then -- global report generation
    dbms_output.put_line('Current Database');
    dbms_output.put_line('~~~~~~~~~~~~~~~~');
    dbms_output.put_line(rpad('DB Id', 15) || rpad('DB Name', 15) ||
                         rpad('Container Name', 15));
    dbms_output.put_line(rpad('-',14,'-') || rpad(' -',15,'-') || 
                         rpad(' -',15,'-'));
    dbms_output.put_line(rpad(to_char(cdbid, '9999999999'), 15) || ' ' ||
                         rpad(dbname, 15) || rpad(con_name, 15));
    dbms_output.put_line(chr(10));
    :input_script := 'awrgrpti';
  else
    dbms_output.put_line('Current Instance');
    dbms_output.put_line('~~~~~~~~~~~~~~~~');
    dbms_output.put_line(rpad('DB Id', 15) || rpad('DB Name', 15) ||
                         rpad('Inst Num', 15) || rpad('Instance', 15) ||
                         rpad('Container Name', 15));
    dbms_output.put_line(rpad('-',14,'-') || rpad(' -',15,'-') || 
                         rpad(' -',15,'-') || rpad(' -',15,'-') ||
                         rpad(' -',15,'-'));
    dbms_output.put_line(rpad(to_char(cdbid, '9999999999'), 16) || 
                         rpad(dbname, 15) || ' ' || 
                         rpad(to_char(inst_number, '999999999999'), 13) ||
                         ' ' || rpad(inst_name, 15) || rpad(con_name,15));
    dbms_output.put_line(chr(10));
    :input_script := 'awrrpti';
  end if;

  -- need to check whether connected to a pdb
  select upper(CDB), sys_context('USERENV','CON_ID')
  into   is_cdb, con_id
  from   v$database;

  -- in case of PDB, display more information
  if (is_cdb = 'YES') and (con_id <> 1) then
    -- display root dbid, current dbid and default awr dbid 
    select   vd.dbid, vd.con_dbid,
             wrs.local_awrdbid
    into     rdbid, cdbid, awrdbid
    from     v$database vd, awr_pdb_wr_control wr, awr_pdb_wr_settings wrs
    where    wr.dbid = vd.con_dbid;

    dbms_output.put_line(rpad('Root DB Id', 16) || 
                         rpad('Container DB Id', 16) ||
                         rpad('AWR DB Id', 16));
    dbms_output.put_line(rpad('-',15,'-') || rpad(' -',16,'-') || 
                         rpad(' -',16,'-'));
    dbms_output.put_line(rpad(to_char(rdbid, '999999999999'), 15) || ' ' ||
                         rpad(to_char(cdbid, '999999999999'), 16) || 
                         rpad(to_char(awrdbid, '999999999999'), 16));
  end if;
end;
/

set termout off;
-- populate the variables by selecting the associated columns

select :input_script rpti_script from dual;

select i.instance_number inst_num
     , 'ALL'             instance_numbers_or_all
FROM v$instance i;

select (case when '&view_loc' = 'AWR_PDB'
             then sys_context('userenv','con_dbid')
             else sys_context('userenv','dbid') end) dbid
from dual;

set termout on;
@@&rpti_script

undefine num_days;
undefine report_type;
undefine report_name;
undefine begin_snap;
undefine end_snap;
undefine dflt_rpt;
undefine inst_num;
undefine dbid;
undefine dbclmn;
undefine rpti_script;
undefine instance_numbers_or_all;
undefine awrgrpt_rptv;

undefine view_loc_def;
undefine report_type_def;
undefine report_type;

-- Undefine all variables declare in getawrviewloc
undefine default_view_location
undefine is_pdb
undefine view_loc
undefine awr_location

--
-- End of file
