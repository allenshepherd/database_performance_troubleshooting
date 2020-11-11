Rem
Rem $Header: rdbms/admin/awrgdinp.sql /main/7 2017/07/28 16:56:56 yingzhen Exp $
Rem
Rem awrgdinp.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrgdinp.sql - AWR Glopal Compare Period Report Input variables
Rem
Rem    DESCRIPTION
Rem      This script gets the dbid,eid,filename,etc from the user
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrgdinp.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrgdinp.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    yingzhen    07/20/17 - Bug 26448963 check report_name extension
Rem    kmorfoni    01/03/17 - Bug 24673313: Fix typo
Rem    arbalakr    09/08/16 - Bug 24625721: Use view_loc variable correctly
Rem    arbalakr    07/19/16 - Use the awr_* views instead of dba_hist* views
Rem    yingzhen    05/25/16 - Bug 22604990, sort inst info of AWR report
Rem    osuro       06/20/14 - Bug 18997912 - Incorrect instance range for DB2
Rem    ilistvin    12/17/07 - Created
Rem


-- Script Parameters:
--   First Param (&1) : file prefix e.g. 'awrrpt_'
--   Second Param (&2) : file extension e.g. '.html', '.lst'
--     **** IMPORTANT - the second parameter must be non-null, or else SQL*Plus
--          adds an awkward prompt when we try to use it

-- After executing, this module leaves the substitution variable
-- &report_name defined.  Issue the command spool &report_name to
-- spool your report to a file, and then undefine report_name when you're
-- done with it.

-- The following list of SQL*Plus bind variables will be defined and assigned
--  a value by this SQL*Plus script:
-- First pair of snapshots
--    variable dbid      number   - Database id
--    variable instl     varchar2 - CSV list of instance numbers
--    variable bid       number   - Begin snapshot id 
--    variable eid       number   - End snapshot id
-- Second pair of snapshots
--    variable dbid2     number   - Database id 
--    variable instl2    varchar2 - CSV list of instance numbers
--    variable bid2      number   - Begin snapshot id
--    variable eid2      number   - End snapshot id




clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

--
-- Request the DB Id and Instance Number, if they are not specified

column instt_num  heading "Inst Num"  format 99999;
column instt_name heading "Instance"  format a12;
column dbb_name   heading "DB Name"   format a12;
column dbbid      heading "DB Id"     format a12 just c;
column host       heading "Host"      format a12;

Rem
Rem Check if we are inside a PDB. If so, choose the AWR 
Rem ===================================================
column view_loc_def new_value view_loc_def noprint;
select '' view_loc_def from dual where rownum = 0;

column script_viewloc new_value script_viewloc noprint;
select case when '&view_loc_def' IS NULL
            then '@getawrviewloc'
            else '@ashrptinoop' end as script_viewloc
from dual;
@&script_viewloc

set serveroutput on format wrapped;

prompt
prompt
prompt Instances in this Workload Repository schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECLARE
  dynsql     VARCHAR2(2048);
  cur        sys_refcursor;
  TYPE cur_row_type IS RECORD
  (
    dbbid        VARCHAR2(32),
    instt_num    AWR_PDB_DATABASE_INSTANCE.instance_number%type,
    dbb_name     AWR_PDB_DATABASE_INSTANCE.db_name%type,
    instt_name   AWR_PDB_DATABASE_INSTANCE.instance_name%type,
    host         AWR_PDB_DATABASE_INSTANCE.host_name%type
  );
  
  curi        cur_row_type;
  printhead   NUMBER;
BEGIN
  printhead := 1;
  dynsql :=
    'select distinct
            (case when cd.dbid = wr.dbid and 
                       cd.name = wr.db_name and
                       ci.instance_number = wr.instance_number and
                       ci.instance_name   = wr.instance_name
                  then ''* ''
                  else ''  ''
             end) || wr.dbid   dbbid
           , wr.instance_number instt_num
           , wr.db_name         dbb_name
           , wr.instance_name   instt_name
           , wr.host_name       host
     from ' || '&view_loc' || '_database_instance wr,
           v$database cd, v$instance ci
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
prompt Database Id and Instance Number for the First Pair of Snapshots
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Using &&dbid for Database Id for the first pair of snapshots
prompt Using instances &&instance_numbers_or_ALL for the first pair of snapshots

--
--  Set up the binds for dbid and instance number list
--
variable dbid       number;
variable instl      varchar2(1023);
variable inst_num   varchar2(3);
begin
  :dbid      :=  &dbid;
  :instl     :=  '&instance_numbers_or_ALL';
  if UPPER(:instl) = 'ALL' then
    :instl := '';
  end if;
  :inst_num  := '1st';
end;
/


--
--  Error reporting
--
whenever sqlerror exit;
variable max_snap_time char(10);
declare
  csnapid_str    varchar2(2048);
  csnapid_cur    sys_refcursor;
begin
  csnapid_str := 
    'select to_char(max(end_interval_time),''dd/mm/yyyy'')
     from  ' || '&view_loc' || '_snapshot
     where dbid            = :dbid';

  -- Check Snapshots exist for Database Id/Instance Number
  open csnapid_cur for csnapid_str using :dbid;
  fetch csnapid_cur into :max_snap_time;
  if csnapid_cur%notfound then
    raise_application_error(-20200,
      'No snapshots exist for database '||:dbid);
  end if;
  close csnapid_cur;
end;
/
whenever sqlerror continue;


--
--  Ask how many days of snapshots to display

set termout on;
column instart_fmt noprint;
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
set serveroutput on format wrapped;

DECLARE
  dynsql    VARCHAR2(2048);
  cur       sys_refcursor;
  TYPE cur_row_type IS RECORD
  (
    db_name       AWR_PDB_DATABASE_INSTANCE.db_name%type,
    snap_id       AWR_PDB_SNAPSHOT.snap_id%type,
    snapdat       VARCHAR2(32),
    lvl           AWR_PDB_SNAPSHOT.snap_level%type
  );
  
  prev_dbname   varchar2(32);
  rowcount number;
  curi cur_row_type;
  printhead number;
BEGIN
  rowcount := 0;
  printhead := 1;
  prev_dbname := '' ;
  
  dynsql := 
    'select  di.db_name                                        db_name
           , s.snap_id                                         snap_id
           , to_char(max(s.end_interval_time),''dd Mon YYYY HH24:mi'') snapdat
           , max(s.snap_level)                                      lvl
     from ' || '&view_loc' || '_snapshot s,
          ' || '&view_loc' || '_database_instance di
     where di.dbid             = :dbid
      and di.dbid             = s.dbid
      and di.instance_number  = s.instance_number
      and di.startup_time     = s.startup_time
      and s.end_interval_time >=
                     decode( &num_days
                        , 0   , to_date(''31-JAN-9999'',''DD-MON-YYYY'')
                        , 3.14, s.end_interval_time
                        , to_date(:max_snap_time,''dd/mm/yyyy'') - (&num_days-1))
     group by db_name, snap_id
     order by db_name, snap_id';
 
  OPEN cur FOR dynsql USING :dbid, :max_snap_time;
  LOOP
      FETCH cur INTO curi;
    EXIT when cur%NOTFOUND;
    if (printhead = 1 OR rowcount > 55 ) then
      dbms_output.put_line(rpad('DB Name', 12) || ' ' ||
                           rpad('Snap Id', 10) || ' ' ||
                           rpad('   Snap Started   ', 18) || ' ' ||
                           rpad('Snap Level', 10));
      dbms_output.put_line(rpad('------------', 12) || ' ' ||
                           rpad('----------', 10) || ' ' ||
                           rpad('------------------', 18) || ' ' ||
                           rpad('----------', 10));
      printhead := 0;
      rowcount := 0;
    end if;
    IF (rowcount = 0 OR 
        prev_dbname <> curi.db_name ) THEN
      dbms_output.put_line(' ');
      dbms_output.put_line(rpad(curi.db_name,12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));
    ELSE
      dbms_output.put_line(rpad(' ',12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));
    END IF;
    prev_dbname := curi.db_name;
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
prompt Specify the First Pair of Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt First Begin Snapshot Id specified: &&begin_snap
prompt
prompt First End   Snapshot Id specified: &&end_snap
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
  cspid_str VARCHAR2(1024);
  cspid_cur sys_refcursor;
 
  bsnapt  awr_pdb_snapshot.end_interval_time%type;
  bstart  awr_pdb_snapshot.startup_time%type;
  esnapt  awr_pdb_snapshot.end_interval_time%type;
  estart  awr_pdb_snapshot.startup_time%type;
  insts   AWRRPT_INSTANCE_LIST_TYPE;

begin  
  
  cspid_str :=
    'select end_interval_time
          , startup_time
     from ' || '&view_loc' || '_snapshot
     where snap_id         = :snapid
      and dbid            = :dbid';


  -- Check Begin Snapshot id is valid, get corresponding instance startup time
  open cspid_cur for cspid_str using :bid, :dbid;
  fetch cspid_cur into bsnapt, bstart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'Begin Snapshot Id '||:bid||' does not exist for this database');
  end if;
  close cspid_cur;

  -- Check End Snapshot id is valid and get corresponding instance startup time
  open cspid_cur for cspid_str using :eid, :dbid;
  fetch cspid_cur into esnapt, estart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid||' does not exist for this database');
  end if;
  if :eid <= :bid then
    raise_application_error(-20200,
     'End Snapshot Id '||:eid||
     ' must be greater than Begin Snapshot Id '||:bid);
  end if;
  close cspid_cur;

 --
 -- Make sure at least one instance has not been re-started between
 -- begin and end snapshots
 --
 declare
   dynsql varchar2(1024);
 begin
   dynsql := 
     'select b.instance_number
      from ' || '&view_loc' || '_snapshot b, ' || '&view_loc' || '_snapshot e
      where b.dbid = :dbid
        and b.snap_id = :bid
        and e.dbid = :dbid
        and e.snap_id = :eid
        and e.startup_time = b.startup_time
        and e.instance_number = b.instance_number';

    execute immediate dynsql 
    bulk collect into insts
    using :dbid, :bid, :dbid, :eid;
 exception
  -- Check startup time is same for begin and end snapshot ids
  when no_data_found then
    raise_application_error(-20200,
      'All instances were shutdown between snapshots '||:bid||' and '||:eid);
  when others then raise;
 end;

end;
/
whenever sqlerror continue;



clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

--
-- Request the DB Id and Instance Number, if they are not specified
set serveroutput on format wrapped;

prompt
prompt
prompt Instances in this Workload Repository schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECLARE
  dynsql   VARCHAR2(2048);
  cur         sys_refcursor;

  TYPE cur_row_type IS RECORD
  (
    dbbid       VARCHAR2(32),
    instt_num   AWR_PDB_DATABASE_INSTANCE.instance_number%type,
    dbb_name    AWR_PDB_DATABASE_INSTANCE.db_name%type,
    instt_name  AWR_PDB_DATABASE_INSTANCE.instance_name%type,
    host        AWR_PDB_DATABASE_INSTANCE.host_name%type
  );

  curi        cur_row_type;
  printhead   NUMBER;

BEGIN

  printhead := 1;
  dynsql := 
    'select distinct
           (case when cd.dbid = wr.dbid and 
                      cd.name = wr.db_name and
                      ci.instance_number = wr.instance_number and
                      ci.instance_name   = wr.instance_name
                 then ''* ''
                 else ''  ''
            end) || wr.dbid   dbbid
          , wr.instance_number instt_num
          , wr.db_name         dbb_name
          , wr.instance_name   instt_name
          , wr.host_name       host
     from ' || '&view_loc' || '_database_instance wr, 
           (select sys_context(''userenv'',''dbid'') dbid,
                   sys_context(''userenv'',''db_name'') name
            from dual) cd, v$instance ci
     order by dbbid, instt_num';
  
  open cur for dynsql;

  LOOP
    fetch cur into curi;
    exit when cur%notfound;
    
    if (printhead = 1) then
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
--
-- Set up dbid and instance number for the first pair of snapshots
-- as defaults for the second pair of snapshots
--
column dbid1 new_value dbid1 noprint;
column instl1 new_value instnum1 noprint;
select :dbid as dbid1, :instl as instnum1 from dual;

prompt
prompt Database Id and Instance Number for the Second Pair of Snapshots
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Using &&dbid2 for Database Id for the second pair of snapshots
prompt Using instances &&instance_numbers_or_ALL2 for the second pair of snapshots

--
--  Set up the binds for dbid and instance number list
--
variable dbid2      number;
variable instl2     varchar2(1023);
variable inst_num2  varchar2(4);
begin
  :dbid2     :=  nvl(&dbid2,&dbid1);
  :instl2    :=  '&instance_numbers_or_ALL2';
  if UPPER(:instl2) = 'ALL' or UPPER(:instl2) = 'ALL2' then
    :instl2:= '';
  end if;
  :inst_num2 := '2nd';
end;
/


--
--  Error reporting
--
whenever sqlerror exit;
variable max_snap_time char(10);
declare

  csnapid_str   VARCHAR2(1024);
  csnapid_cur   SYS_REFCURSOR;

begin

  csnapid_str := 
    'select to_char(max(end_interval_time),''dd/mm/yyyy'')
     from ' || '&view_loc' || '_snapshot
     where dbid            = :dbid2';

  -- Check Snapshots exist for Database Id/Instance Number
  open csnapid_cur for csnapid_str using :dbid2;
  fetch csnapid_cur into :max_snap_time;
  if csnapid_cur%notfound then
    raise_application_error(-20200,
      'No snapshots exist for database '||:dbid2);
  end if;
  close csnapid_cur;
end;
/
whenever sqlerror continue;


--
--  Ask how many days of snapshots to display

set termout on;
column instart_fmt noprint;
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
column num_days2 new_value num_days2 noprint;
select    'Listing '
       || decode( nvl('&&num_days2', 3.14)
                , 0    , 'no snapshots'
                , 3.14 , 'all Completed Snapshots'
                , 1    , 'the last day''s Completed Snapshots'
                , 'the last &num_days days of Completed Snapshots')
     , nvl('&&num_days', 3.14)  num_days2
  from sys.dual;
set heading on;


--
-- List available snapshots

break on inst_name on db_name on host on instart_fmt skip 1;

ttitle off;
set serveroutput on format wrapped;

DECLARE
  dynsql    VARCHAR2(2048);
  cur       sys_refcursor;
  TYPE cur_row_type IS RECORD
  (
    db_name       AWR_PDB_DATABASE_INSTANCE.db_name%type,
    snap_id       AWR_PDB_SNAPSHOT.snap_id%type,
    snapdat       VARCHAR2(32),
    lvl           AWR_PDB_SNAPSHOT.snap_level%type
  );
  
  prev_dbname   varchar2(32);
  rowcount number;
  curi cur_row_type;
  printhead number;
BEGIN
  rowcount := 0;
  printhead := 1;
  prev_dbname := '' ;

  dynsql := 
    'select  di.db_name                                        db_name
           , s.snap_id                                         snap_id
           , to_char(max(s.end_interval_time),''dd Mon YYYY HH24:mi'') snapdat
           , max(s.snap_level)                                      lvl
     from ' || '&view_loc' || '_snapshot s, 
          ' || '&view_loc' || '_database_instance di
     where di.dbid             = :dbid2
       and di.dbid             = s.dbid
       and di.instance_number  = s.instance_number
       and di.startup_time     = s.startup_time
       and s.end_interval_time >= 
                  decode( &num_days
                        , 0   , to_date(''31-JAN-9999'',''DD-MON-YYYY'')
                        , 3.14, s.end_interval_time
                        , to_date(:max_snap_time,''dd/mm/yyyy'') - (&num_days-1))
     group by db_name, snap_id
     order by db_name, snap_id';
  OPEN cur FOR dynsql USING :dbid, :max_snap_time;
  
  LOOP
    FETCH cur INTO curi;
    EXIT when cur%NOTFOUND;
    if (printhead = 1 OR rowcount > 55 ) then
      dbms_output.put_line(rpad('DB Name', 12) || ' ' ||
                           rpad('Snap Id', 10) || ' ' ||
                           rpad('   Snap Started   ', 18) || ' ' ||
                           rpad('Snap Level', 10));
      dbms_output.put_line(rpad('------------', 12) || ' ' ||
                           rpad('----------', 10) || ' ' ||
                           rpad('------------------', 18) || ' ' ||
                           rpad('----------', 10));
      printhead := 0;
      rowcount := 0;
    end if;
    IF (rowcount = 0 OR 
        prev_dbname <> curi.db_name ) THEN
      dbms_output.put_line(' ');
      dbms_output.put_line(rpad(curi.db_name,12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));
    ELSE
      dbms_output.put_line(rpad(' ',12) || ' ' ||
                           rpad(to_char(curi.snap_id,99999990),10) || ' ' ||
                           rpad(curi.snapdat,18) || ' ' ||
                           rpad(to_char(curi.lvl,99),10));
    END IF;
    prev_dbname := curi.db_name;
    rowcount := rowcount + 1;
  END LOOP;
  CLOSE cur;
END;
/
clear break;
ttitle off;


--
--  Ask for the snapshots Id's which are to be compared

prompt
prompt
prompt Specify the Second Pair of Begin and End Snapshot Ids
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Second Begin Snapshot Id specified: &&begin_snap2
prompt
prompt Second End   Snapshot Id specified: &&end_snap2
prompt


--
--  Set up the snapshot-related binds

variable bid2       number;
variable eid2       number;
begin
  :bid2      :=  &begin_snap2;
  :eid2      :=  &end_snap2;
end;
/

--
--  Error reporting

whenever sqlerror exit;
declare
  cspid_str     VARCHAR2(1024);
  cspid_cur     sys_refcursor;

  bsnapt  awr_pdb_snapshot.end_interval_time%type;
  bstart  awr_pdb_snapshot.startup_time%type;
  esnapt  awr_pdb_snapshot.end_interval_time%type;
  estart  awr_pdb_snapshot.startup_time%type;
  insts   AWRRPT_INSTANCE_LIST_TYPE;

begin
   
  cspid_str :=
    'select end_interval_time, startup_time
       from ' || '&view_loc' || '_snapshot
      where snap_id         = :snapid
        and dbid            = :dbid2';

  
  -- Check Begin Snapshot id is valid, get corresponding instance startup time
  open cspid_cur for cspid_str using :bid2, :dbid2;
  fetch cspid_cur into bsnapt, bstart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'Begin Snapshot Id '||:bid2||' does not exist for this database');
  end if;
  close cspid_cur;

  -- Check End Snapshot id is valid and get corresponding instance startup time
  open cspid_cur for cspid_str using :eid2, :dbid2;
  fetch cspid_cur into esnapt, estart;
  if cspid_cur%notfound then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid2||' does not exist for this database');
  end if;
  if :eid <= :bid then
    raise_application_error(-20200,
      'End Snapshot Id '||:eid2||
      ' must be greater than Begin Snapshot Id '||:bid2);
  end if;
  close cspid_cur;

 --
 -- Make sure at least one instance has not been re-started between
 -- begin and end snapshots
 --
 declare
   dynsql varchar2(1024);
 begin
   dynsql :=
     'select b.instance_number
      from ' || '&view_loc' || '_snapshot b, ' || '&view_loc' || '_snapshot e
      where b.dbid = :dbid2
        and b.snap_id = :bid2
        and e.dbid = :dbid2
        and e.snap_id = :eid2
        and e.startup_time = b.startup_time
        and e.instance_number = b.instance_number';
   execute immediate dynsql 
   bulk collect into insts
   using :dbid2, :bid2, :dbid2, :eid2;
 exception
  -- Check startup time is same for begin and end snapshot ids
  when no_data_found then
    raise_application_error(-20200,
      'All instances were shutdown between snapshots '||:bid2||' and '||:eid2);
  when others then raise;
 end;

end;
/
whenever sqlerror continue;



clear break compute;
repfooter off;
ttitle off;
btitle off;



--
-- Use report name if specified, otherwise prompt user for output file
-- name (specify default), then begin spooling
--
set termout off;
column dflt_name new_value dflt_name noprint;
select '&&1'||:inst_num||'_'||:bid||'_'||:inst_num2||'_'||:bid2||'&&2' dflt_name from dual;
set termout on;

prompt
prompt Specify the Report Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~
prompt The default report file name is &dflt_name.  To use this name,
prompt press <return> to continue, otherwise enter an alternative.
prompt

set heading off;
column report_name new_value report_name noprint;
select 'Using the report name ' || nvl('&&report_name','&dflt_name')
     , nvl(decode(instr('&&report_name','.'),0,'&&report_name'||'&&2',
          '&&report_name'),'&dflt_name') report_name
  from sys.dual;

set heading off;
set pagesize 50000;
set echo off;
set feedback off;

undefine dbid
undefine inst_num
undefine num_days
undefine begin_snap
undefine end_snap

undefine dbid2
undefine inst_num2
undefine num_days2
undefine begin_snap2
undefine end_snap2


undefine dflt_name2

undefine 1
undefine 2

undefine view_loc_def
undefine script_viewloc

--
-- End of script
