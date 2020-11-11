Rem
Rem $Header: rdbms/admin/awrinput.sql /main/9 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrinput.sql
Rem
Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrinput.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      A chunk of common code used for SWRF reports and ADDM.
Rem      This script gets the dbid,eid,filename,etc from the user
Rem      for both components to use.
Rem
Rem    NOTES
Rem      This script could leave a few other SQL*Plus substitution and/or
Rem      bind variables defined at the end.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrinput.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrinput.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    yingzhen    01/31/17 - Bug 25471822 show correct inst name
Rem    kmorfoni    12/06/16 - specify con_dbid in AWR SQL report
Rem    arbalakr    07/18/16 - Use the awr_* views instead of dba_hist* views
Rem    yingzhen    05/25/16 - Bug 22604990, sort inst info of AWR report
Rem    mlfeng      12/06/05 - join on host name 
Rem    mlfeng      05/22/05 - remove leading blank from date conversion 
Rem    adagarwa    11/22/04 - Move code for obtaining report name to
Rem                           awrinpnm.sql
Rem    pbelknap    10/15/03 - swrf reporting to html in pl/sql module 
Rem    veeve       10/02/03 - 
Rem    pbelknap    10/02/03 - fixing for text reports
Rem    veeve       10/01/03 - show current instance and
Rem                           give default values for dbid and inst_num
Rem    pbelknap    10/01/03 - Created
Rem


-- The following list of SQL*Plus bind variables will be defined and assigned a value
-- by this SQL*Plus script:
--    variable dbid      number     - Database id
--    variable inst_num  number     - Instance number
--    variable bid       number     - Begin snapshot id
--    variable eid       number     - End snapshot id


clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

Rem
Rem Check if we are inside a PDB. If so, choose the AWR 
Rem ===================================================
set termout off;
column view_loc_def new_value view_loc_def noprint;
select '' view_loc_def from dual where rownum = 0;

column script_viewloc new_value script_viewloc noprint;
select case when '&view_loc_def' IS NULL
            then '@getawrviewloc'
            else '@ashrptinoop' end as script_viewloc
from dual;
set termout on;

@&script_viewloc

--
-- Request the DB Id and Instance Number, if they are not specified

column instt_num  heading "Inst Num"  format 99999;
column instt_name heading "Instance"  format a12;
column dbb_name   heading "DB Name"   format a12;
column dbbid      heading "DB Id"     format a12 just c;
column host       heading "Host"      format a12;

set serveroutput on format wrapped;

prompt
prompt
prompt Instances in this Workload Repository schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECLARE
  dynsql        VARCHAR2(2048);
  cur           sys_refcursor;
  TYPE cur_row_type IS RECORD
  (
    dbbid       VARCHAR2(32),
    instt_num   AWR_PDB_DATABASE_INSTANCE.instance_number%type,
    dbb_name     AWR_PDB_DATABASE_INSTANCE.db_name%type,
    instt_name  AWR_PDB_DATABASE_INSTANCE.instance_name%type,
    host       AWR_PDB_DATABASE_INSTANCE.host_name%type   
  );
  
  curi cur_row_type;
  printhead number;
BEGIN
  printhead := 1;
  dynsql := 
    'select distinct
           (case when cd.dbid = wr.dbid and 
                      cd.name = wr.db_name and
                      ci.instance_number = wr.instance_number and
                      ci.instance_name   = wr.instance_name   and
                      ci.host_name       = wr.host_name 
                 then ''* ''
                 else ''  ''
            end) || wr.dbid   dbbid
         , wr.instance_number instt_num
         , wr.db_name         dbb_name
         , wr.instance_name   instt_name
         , wr.host_name       host
      from ' || '&view_loc' || '_database_instance wr, v$database cd, v$instance ci
      order by dbbid, instt_num';

  open cur for dynsql;

  LOOP

    fetch cur into curi;
    exit when cur%notfound;
    
    if (printhead <> 0) then
      dbms_output.put_line(rpad('  DB Id  ' , 12) || ' ' ||
                           rpad('Inst Num', 10) || ' ' ||
                           rpad('DB Name', 12) || ' ' ||
                           rpad('Instance', 12) || ' ' ||
                           rpad('Host', 12));
      dbms_output.put_line(rpad('------------',12) || ' ' ||
                           rpad('----------', 10) || ' ' ||
                           rpad('---------', 12) || ' ' ||
                           rpad('----------', 12) || ' ' ||
                           rpad('------', 12));
      printhead := 0;
    end if;
    dbms_output.put_line(rpad(curi.dbbid,12) || ' ' ||
                         rpad(to_char(curi.instt_num,'9999'), 10) || ' ' ||
                         rpad(curi.dbb_name,12) || ' ' ||
                         rpad(curi.instt_name,12) || ' ' ||
                         rpad(curi.host,12));

  END LOOP; 
  close cur;
END;
/

prompt
prompt Using &&dbid for database Id
prompt Using &&inst_num for instance number


--
--  Set up the binds for dbid and instance_number

variable dbid       number;
variable inst_num   number;
begin
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
end;
/

--
--  Error reporting

whenever sqlerror exit;
variable max_snap_time char(10);
declare
  cidnum_str   VARCHAR2(1024);
  csnapid_str  VARCHAR2(1024);
  
  cidnum_cur   sys_refcursor;
  csnapid_cur  sys_refcursor;
  vx     char(1);

begin
  cidnum_str :=
    'select ''X''
       from ' || '&view_loc' || '_database_instance
      where instance_number = :inst_num
        and dbid            = :dbid';

  csnapid_str :=
    'select to_char(max(end_interval_time),''dd/mm/yyyy'')
       from ' || '&view_loc' || '_snapshot
      where instance_number = :inst_num
        and dbid            = :dbid';


  -- Check Database Id/Instance Number is a valid pair
  open cidnum_cur for cidnum_str using :inst_num, :dbid;
  fetch cidnum_cur into vx;
  if cidnum_cur%notfound then
    raise_application_error(-20200,
      'Database/Instance ' || :dbid || '/' || :inst_num ||
      ' does not exist in ' || '&view_loc' || '_DATABASE_INSTANCE');
  end if;
  close cidnum_cur;

  -- Check Snapshots exist for Database Id/Instance Number
  open csnapid_cur for csnapid_str using :inst_num, :dbid;
  fetch csnapid_cur into :max_snap_time;
  if csnapid_cur%notfound then
    raise_application_error(-20200,
      'No snapshots exist for Database/Instance '||:dbid||'/'||:inst_num);
  end if;
  close csnapid_cur;

end;
/
whenever sqlerror continue;


--
--  Ask how many days of snapshots to display

set termout on;
column instart_fmt noprint;
column inst_name   format a12  heading 'Instance';
column db_name     format a12  heading 'DB Name';
column snap_id     format 99999990 heading 'Snap Id';
column snapdat     format a18  heading 'Snap Started' just c;
column lvl         format 99   heading 'Snap|Level';

prompt
prompt
prompt Specify the number of days of snapshots to choose from
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Entering the number of days (n) will result in the most recent
prompt (n) days of snapshots being listed.  Pressing <return> without
prompt specifying a number lists all completed snapshots.
prompt
prompt

set heading off;
column num_days new_value num_days noprint;
select    'Listing '
       || decode( nvl('&&num_days', 3.14)
                , 0    , 'no snapshots'
                , 3.14 , 'all Completed Snapshots'
                , 1    , 'the last day''s Completed Snapshots'
                , 'the last &num_days days of Completed Snapshots')
     , nvl('&&num_days', 3.14)  num_days
  from sys.dual;
set heading on;


--
-- List available snapshots

break on inst_name on db_name on host on instart_fmt skip 1;

ttitle off;
DECLARE
  dynsql VARCHAR2(2048);
  cur    sys_refcursor;
  TYPE cur_row_type IS RECORD
  (
    instart_fmt   VARCHAR2(32),
    inst_name     AWR_PDB_DATABASE_INSTANCE.instance_name%type,
    db_name       AWR_PDB_DATABASE_INSTANCE.db_name%type,
    snap_id       AWR_PDB_SNAPSHOT.snap_id%type,
    snapdat       VARCHAR2(32),
    lvl           AWR_PDB_SNAPSHOT.snap_level%type
  );
  
  prev_dbname   varchar2(32);
  prev_instname varchar2(32);
  rowcount number;
  curi cur_row_type;
  printhead number;
BEGIN
  rowcount := 0;
  printhead := 1;
  prev_dbname := '' ;
  prev_instname := '';

  dynsql := 
    'select to_char(s.startup_time,''dd Mon "at" HH24:mi:ss'')  instart_fmt
           , di.instance_name                                  inst_name
           , di.db_name                                        db_name
           , s.snap_id                                         snap_id
           , to_char(s.end_interval_time,''dd Mon YYYY HH24:mi'') snapdat
           , s.snap_level                                      lvl
     from ' || '&view_loc' || '_snapshot s
          , ' || '&view_loc' || '_database_instance di
     where s.dbid              = :dbid
       and di.dbid             = :dbid
       and s.instance_number   = :inst_num
       and di.instance_number  = :inst_num
       and di.dbid             = s.dbid
       and di.instance_number  = s.instance_number
      and di.startup_time     = s.startup_time
      and s.end_interval_time >= decode( &num_days
                                   , 0   , to_date(''31-JAN-9999'',''DD-MON-YYYY'')
                                   , 3.14, s.end_interval_time
                                   , to_date(:max_snap_time,''dd/mm/yyyy'') - (&num_days-1))
     order by db_name, instance_name, snap_id';
  open cur for dynsql using :dbid, :dbid, :inst_num, :inst_num, :max_snap_time;
  LOOP
    FETCH cur INTO curi;
    exit when cur%notfound;
  
    IF (printhead = 1 OR rowcount > 55 ) THEN
      dbms_output.put_line(rpad('Instance' , 12) || ' ' ||
                           rpad('DB Name', 12) || ' ' ||
                           rpad('Snap Id', 10) || ' ' ||
                           rpad('   Snap Started   ', 18) || ' ' ||
                           rpad('Snap Level', 10));
      dbms_output.put_line(rpad('------------',12) || ' ' ||
                           rpad('------------', 12) || ' ' ||
                           rpad('----------', 10) || ' ' ||
                           rpad('------------------', 18) || ' ' ||
                           rpad('----------', 10));
      dbms_output.put_line(' ');

      printhead := 0;
      rowcount  := 0;
    END IF;
    IF (rowcount = 0) OR
       (prev_dbname <> curi.db_name) OR
       (prev_instname <> curi.inst_name) THEN
      dbms_output.put_line(rpad(curi.inst_name,12) || ' ' ||
                           rpad(curi.db_name,12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));

      /* Save dbname and instanace name if it is the first row of a new page,
       * or dbname/instance name has been changed.
       */
      prev_dbname   := curi.db_name;
      prev_instname := curi.inst_name;
    ELSE
      dbms_output.put_line(rpad(' ',12) || ' ' ||
                           rpad(' ',12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));
    END IF;
    rowcount := rowcount + 1;
  END LOOP;
  close cur;
END;
/

clear break;
ttitle off;


--
--  Ask for the snapshots Id's which are to be compared

prompt
prompt
prompt Specify the Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Begin Snapshot Id specified: &&begin_snap
prompt
prompt End   Snapshot Id specified: &&end_snap
prompt


--
--  Set up the snapshot-related binds

variable bid        number;
variable eid        number;
begin
  :bid       :=  &begin_snap;
  :eid       :=  &end_snap;
end;
/

prompt


--
--  Error reporting

whenever sqlerror exit;
declare
  cspid_cur    sys_refcursor;
  cspid_str    VARCHAR2(1024);

  bsnapt  awr_pdb_snapshot.end_interval_time%type;
  bstart  awr_pdb_snapshot.startup_time%type;
  esnapt  awr_pdb_snapshot.end_interval_time%type;
  estart  awr_pdb_snapshot.startup_time%type;

begin
  
  cspid_str := 
    'select end_interval_time, startup_time
     from ' || '&view_loc' || '_snapshot
     where snap_id         = :snapid
       and instance_number = :inst_num
       and dbid            = :dbid';

  -- Check Begin Snapshot id is valid, get corresponding instance startup time
  open cspid_cur for cspid_str using :bid, :inst_num, :dbid;
  fetch cspid_cur into bsnapt, bstart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'Begin Snapshot Id '||:bid||' does not exist for this database/instance');
  end if;
  close cspid_cur;

  -- Check End Snapshot id is valid and get corresponding instance startup time
  open cspid_cur for cspid_str using :eid, :inst_num, :dbid;

  fetch cspid_cur into esnapt, estart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid||' does not exist for this database/instance');
  end if;

  if esnapt <= bsnapt then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid||' must be greater than Begin Snapshot Id '||:bid);
  end if;

  close cspid_cur;

  -- Check startup time is same for begin and end snapshot ids
  if ( bstart != estart) then
    raise_application_error(-20200,
      'The instance was shutdown between snapshots '||:bid||' and '||:eid);
  end if;

end;
/
whenever sqlerror continue;


-- Undefine substitution variables
undefine dbid
undefine inst_num
undefine num_days
undefine begin_snap
undefine end_snap
undefine db_name
undefine inst_name

undefine view_loc_def
undefine script_viewloc
