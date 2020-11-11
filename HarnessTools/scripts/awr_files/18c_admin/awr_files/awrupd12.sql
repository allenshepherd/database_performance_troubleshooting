Rem
Rem $Header: rdbms/admin/awrupd12.sql /main/3 2017/05/28 22:46:01 stanaya Exp $
Rem
Rem awrupd12.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrupd12.sql - AWR Update for version 12c
Rem
Rem    DESCRIPTION
Rem      This script updates AWR data to version 12c.
Rem
Rem      It only modifies AWR data that has been imported using awrload.sql,
Rem      or data from before changing the database DBID.
Rem
Rem      In other words, it doesn't modify AWR data for the local, active DBID.
Rem
Rem    NOTES
Rem      For performance reasons, this is a separate step, outside of the main
Rem      upgrade flow.
Rem
Rem      Until this script has been run for all DBIDs that require it, it will
Rem      not be possible to import additional AWR data into those DBIDs, and
Rem      the CON_DBID column in DBA_HIST views may show an incorrect value.
Rem
Rem      To process all DBIDs that need updating, just press ENTER when
Rem      prompted for a DBID.
Rem
Rem      To avoid being prompted for DBIDs, use the SQLPLUS DEFINE command:
Rem       define dbid = ''
Rem
Rem      In that case, the default behavior will be used.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrupd12.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrupd12.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    07/19/16 - Use the awr_* views instead of dba_hist* views
Rem    mfallen     09/18/12 - creation
Rem

clear break compute;
repfooter off;
ttitle off;
btitle off;

set heading on;
set timing off veri off space 1 flush on pause off termout on numwidth 10;
set echo off feedback off pagesize 60 linesize 80 newpage 1 recsep off;
set trimspool on trimout on define "&" concat "." serveroutput on;
set underline on;

set serveroutput on

--
-- Request DBID, if not specified

column dbb_name   heading "DB Name"   format a16;
column dbbid      heading "DB Id"     format a12 just c;

prompt
prompt DBIDs in this Workload Repository schema that require update
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select distinct
       '  ' || wr.dbid   dbbid
     , di.db_name        dbb_name
  from wrm$_wr_control wr,
       awr_pdb_database_instance di
 where wr.dbid in
  (select dbid
     from wrm$_wr_control
    where bitand(status_flag, 4) = 4)
      and wr.dbid = di.dbid(+)
 order by 1, 2;

prompt
prompt (Press ENTER to process all DBIDs displayed above)
prompt
prompt Using '&&dbid' for database Id

--
--  Set up the binds for dbid

variable dbid number;
begin
 :dbid := nvl('&dbid', 0);
end;
/

declare

 debug constant boolean := FALSE;

 in_dbid  number;
 l_dbid   number;
 dbid_cnt number;

 cursor wrh_tables is
  select *
    from x$kewrtb
   where table_name_kewrtb like 'WRH$%'
   order by table_id_kewrtb;

 cursor awr_dbids is
  select *
    from wrm$_wr_control
   where dbid != (select dbid from v$database)
     and bitand(status_flag, 4) = 4
   order by dbid;

 sqlstr varchar2(2000);

 upd_part1 varchar2(100);
 upd_part2 varchar2(200);

 btime timestamp;
 etime interval day(1) to second;

 curmaj varchar2(2);
 curmin varchar2(2);
 prvmaj varchar2(2);
 prvmin varchar2(2);

 invalid_for_version    exception;
 not_needed_for_version exception;
 no_cleanup_needed      exception;
 cannot_cleanup_active  exception;
 dbid_missing           exception;
 no_dbid_cleanup_needed exception;

begin

 select regexp_substr(version, '[0-9]*'),
        regexp_substr(version, '[0-9]*', instr(version, '.') + 1),
        regexp_substr(prv_version, '[0-9]*'),
        regexp_substr(prv_version, '[0-9]*', instr(prv_version, '.') + 1)
    into curmaj,
         curmin,
         prvmaj,
         prvmin
    from registry$
   where cid='CATPROC';

 prvmaj := nvl(prvmaj, '99');
 prvmin := nvl(prvmin, '99');

 if (curmaj < '12') then
  raise invalid_for_version;
 end if;

 if (prvmaj >= '12') then
  raise not_needed_for_version;
 end if;

 in_dbid := nvl(:dbid, 0);

 if (debug) then
  if (in_dbid = 0) then
   dbms_output.put_line('Processing all DBIDs that require cleanup');
  else
   dbms_output.put_line('Processing DBID ' || in_dbid);
  end if;
 end if;

 -- get current, local DBID
 select dbid into l_dbid from v$database;

 -- if no DBID specified, verify there are DBIDs to clean up
 if (in_dbid = 0) then
  select count(*)
    into dbid_cnt
    from wrm$_wr_control
   where dbid != l_dbid
     and bitand(status_flag, 4) = 4;

  if (dbid_cnt = 0) then
   raise no_cleanup_needed;
  end if;

 end if;

 -- verify specified DBID is not the local AWR (which shouldn't need cleanup)
 if (in_dbid = l_dbid) then
  raise cannot_cleanup_active;
 end if;

 -- verify that DBID actually exists
 if (in_dbid != 0) then
  select count(1)
    into dbid_cnt
    from sys.wrm$_wr_control
   where dbid = in_dbid;

  if dbid_cnt = 0 then
    raise dbid_missing;
  end if;
 end if;

 -- verify that DBID actually needs cleanup
 if (in_dbid != 0) then
  select count(1)
    into dbid_cnt
    from sys.wrm$_wr_control
   where dbid = in_dbid
     and bitand(status_flag, 4) = 4;

  if dbid_cnt = 0 then
    raise no_dbid_cleanup_needed;
  end if;
 end if;

  -- print what we're going to do
 if (in_dbid != 0) then
  dbms_output.put_line('Cleaning up data for DBID ' || in_dbid);
 else 
  dbms_output.put_line('Cleaning up data for the following DBIDs in AWR:');
  for rec in awr_dbids loop
   dbms_output.put_line(rec.dbid);
  end loop;
 end if; 

 -- setup sql strings
 upd_part1 := 'update sys.';
 upd_part2 := ' set con_dbid=dbid ' ||
              ' where con_dbid != dbid ' ||
              '   and dbid in (';

 if (in_dbid != 0) then
  upd_part2 := upd_part2 || in_dbid || ')';
 else
  upd_part2 := upd_part2 ||
              ' select dbid ' ||
              '   from sys.wrm$_wr_control ' ||
              '  where bitand(status_flag, 4) = 4)';
 end if;

 -- go through all wrh$ tables
 for rec in wrh_tables loop

  -- assemble update string
  sqlstr := upd_part1 || rec.table_name_kewrtb || upd_part2;

  if (debug) then
   dbms_output.put_line('sqlstr: ' || sqlstr);
  end if;

  dbms_output.put_line('Processing table ' || rec.table_name_kewrtb);

  -- execute update
  btime := systimestamp;
  execute immediate sqlstr;
  etime := systimestamp - btime;

  dbms_output.put_line('Updated ' || sql%rowcount || ' rows');
  dbms_output.put_line('Elapsed ' || etime);

  commit;

 end loop;

 -- update WR_CONTROL
 sqlstr :=
 'update wrm$_wr_control
    set status_flag = status_flag - 4
  where bitand(status_flag, 4) = 4
    and dbid != ' || l_dbid;

 if (in_dbid != 0) then
  sqlstr := sqlstr || ' and dbid in (' || in_dbid || ')';
 end if;

 if (debug) then
  dbms_output.put_line('sqlstr: ' || sqlstr);
 end if;

 -- execute update
 execute immediate sqlstr;
 commit;

exception

 when invalid_for_version then
  dbms_output.put_line('Script cannot be run for this version, terminating.');
  return;

 when not_needed_for_version then
  dbms_output.put_line('No need to run script for this version, terminating.');
  return;

 when no_cleanup_needed then
  dbms_output.put_line('No DBIDs require cleanup, terminating.');
  return;

 when cannot_cleanup_active then
  dbms_output.put_line('Cannot cleanup currently active AWR, terminating.');
  return;

 when dbid_missing then
  dbms_output.put_line('Specified DBID missing from AWR, terminating.');
  return;

 when no_dbid_cleanup_needed then
  dbms_output.put_line('Specified DBID does not require cleanup, terminating.');
  return;

 when others then
  raise;

end;
/
