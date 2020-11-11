Rem
Rem $Header: rdbms/admin/xdbuend.sql /main/9 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbuend.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuend.sql - XDB Upgrade END 
Rem
Rem    DESCRIPTION
Rem      This script the final operations required to complete the
Rem      XDB upgrade to the new release
Rem
Rem    NOTES
Rem      It is invoked from xdbupgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuend.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuend.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbupgrd.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    qyu         03/03/16 - #22302350: fix GATHER_TABLE_STATS
Rem    raeburns    08/27/15 - use UPGRADED as final status
Rem    raeburns    12/18/14 - use dbms_registry pkg for errors
Rem    raeburns    08/29/14 - add timestamp
Rem    raeburns    05/16/14 - only change version if no upgrade errors, add end script
Rem    raeburns    04/13/14 - remove xdburl
Rem    raeburns    10/27/13 - restructure upgrade
Rem    raeburns    10/27/13 - Created

-- Set session _ORACLE_SCRIPT for objects created during upgrade
@?/rdbms/admin/sqlsessstart.sql

-- START MOVED FROM XDBDBMIG

-- drops error tables if  error tables for XDB$ACL or XDB$CONFIG empty
declare
  aclnoinv    number := 0;
  resnoinv    number := 0;
  stmtchk     varchar2(2000);
  stmtdrop    varchar2(2000);
begin
  begin
    stmtchk := 'select count(*) from XDB.INVALID_XDB$CONFIG';
    dbms_output.put_line(stmtchk);
    execute immediate stmtchk into resnoinv;
    if (resnoinv = 0) then
      stmtdrop := 'drop table XDB.INVALID_XDB$CONFIG'; 
      dbms_output.put_line(stmtdrop);     
      execute immediate stmtdrop;
      commit;
    end if;
  exception
    when others then
      -- table already dropped
      NULL;
  end;
  begin
    stmtchk := 'select count(*) from XDB.INVALID_XDB$ACL';
    dbms_output.put_line(stmtchk);
    execute immediate stmtchk into aclnoinv;
    if (aclnoinv = 0) then
      stmtdrop := 'drop table XDB.INVALID_XDB$ACL';   
      dbms_output.put_line(stmtdrop);
      execute immediate stmtdrop;
      commit;
    end if;
  exception
    when others then
      -- table already dropped
      NULL;
  end;
end;
/

-- check the ACL index status
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';

-- check status of xdb schema cache event
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
  -- set level 0x8000 
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                                utl_raw.cast_from_binary_integer(lev),
                                utl_raw.cast_from_binary_integer(32768)))), '0');
  -- make sure event is set
  execute immediate
    'alter session set events ''31150 trace name context forever, level ' ||
    newlvls || ''' ';
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
end;
/

-- additionally, trace any further lxs-0002x errors 
alter session set events '31061 trace name errorstack level 3, forever';

-- END MOVED FROM XDBDBMIG

Rem ===============================================================
Rem BEGIN XDB Upgrade Termination
Rem ===============================================================

Rem Clear session package state
execute dbms_session.reset_package;

-- Gather stats on xdb$resource so that further component upgrades 
-- that are based on resource_view will run fast
-- bug 22302350: remove estimate_percent for performance
begin
 DBMS_STATS.GATHER_TABLE_STATS (ownname => 'XDB', tabname => 'XDB$RESOURCE');
end;
/

Rem Use dbms_regisry package to check for upgrade errors
BEGIN
    dbms_registry.upgraded('XDB');
    IF (sys.dbms_registry.count_errors_in_registry('XDB') > 0) THEN 
       dbms_registry.invalid('XDB');
    END IF;
END;
/

-- Display final XDB timestamps
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

-- Reset session _ORACLE_SCRIPT 
@?/rdbms/admin/sqlsessend.sql

Rem ===============================================================
Rem END XDB Upgrade Termination
Rem ===============================================================
