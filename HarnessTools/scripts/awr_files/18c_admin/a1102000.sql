Rem
Rem $Header: rdbms/admin/a1102000.sql /main/45 2017/10/23 10:08:24 hosu Exp $
Rem
Rem a1102000.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      a1102000.sql - additional ANONYMOUS BLOCK dictionary upgrade
Rem                     making use of PL/SQL packages installed by
Rem                     catproc.sql.
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      11.2.0 database to the new 11.2.0.x patch release.
Rem
Rem      This script is called from catupgrd.sql and a1101000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes  
Rem      that must be performed before catalog.sql and catproc.sql go 
Rem      in c1102000.sql
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 11.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/a1102000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/a1102000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupprc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hosu        10/15/17 - rti 20648269: move optimizer related code
Rem                           to c1102000.sql
Rem    hosu        09/29/17 - 26657382: stats history table upgrading moved
Rem                           from c1102000.sql
Rem    hosu        08/10/17 - 26614959: only exchange synopsis partition that
Rem                           exists
Rem    yingzhen    07/31/17 - Bug 26452420: remove partition WRH$_MVPARAMETER
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    hosu        03/03/16 - 22865331: do not insert entries of dropped
Rem                           tables during synopsis upgrade 
Rem    hosu        08/26/15 - lrg 16660989: synopsis upgrade to 12.2
Rem    hosu        05/26/15 - 21073559: drop residue synopsis staging table
Rem                           from previous upgrade failure
Rem    jiayan      03/06/15 - Proj 44162: skip fast inserting synopsis for 12.2
Rem    maba        02/02/15 - remove create_base_view to catuppst.sql
Rem    abrown      12/23/14 - bug 20105469 : move inoperative to logmnr cache
Rem                           cleanout to a1201000.sql
Rem    svivian     09/16/14 - bug 19630651: fix upgrade of spill from 11.2
Rem    sagrawal    02/18/14 - bug 18220091
Rem    sagrawal    11/20/13 - bug 17436936
Rem    hosu        02/09/13 - #16246179 fast upgrade of synopsis$
Rem    ssubrama    01/11/13 - lrg 8755441 remove add_buffer call to scheduler
Rem                           queue
Rem    ssubrama    01/07/13 - lrg 8553081 add buffer after migrate
Rem    cdilling    12/07/12 - invoke 12.1 patch upgrade script
Rem    mfallen     11/17/12 - create missing WRH$_MVPARAMETER partition
Rem    amadan      11/19/12 - Bug 14840762:migrate only sys queue tables created
Rem                           without any queue compatibility
Rem    svivian     05/11/12 - Bug 13887570: SQL injection with LOGMINING
Rem                           privilege
Rem    hosu        05/10/12 - 13911389: drop synopsis tables
Rem    yunkzhan    05/07/12 - Bug 13894794 clean out the cache of the objects
Rem                           currently stored in frontier table.
Rem    shjoshi     03/28/12 - bug13110154: Do not truncate
Rem                           wri$_sqltext_refcount
Rem    desingh     02/15/12 - add upgrade to deq hash table view
Rem    bmccarth    02/10/12 - Fix enquote usage
Rem    bmccarth    09/29/11 - long ident
Rem    kmorfoni    08/23/11 - Fix for lrg 5759823
Rem    rpang       07/25/11 - Proj 32719: Grant inherit privileges
Rem    paestrad    06/24/11 - Changes for DBMS_CREDENTIAL package
Rem    jnunezg     06/28/11 - Update for Scheduler RESTARTABLE flag.
Rem    huntran     05/03/11 - streams auth select privileges
Rem    huntran     01/30/11 - grant xstream view privileges
Rem    yurxu       04/21/11 - Add connect_user for in xstream$_server
Rem    yurxu       03/25/11 - Bug-11922716: 2-level privilege model
Rem    huntran     02/01/11 - grant select privs for xstream table stats
Rem    amozes      07/01/10 - ODM upgrade for 12g
Rem    spetride    06/09/10 - add DBA_DIGEST_VERIFIERS
Rem    jawilson    05/04/10 - Change aq$_replay_info address format
Rem    pbelknap    03/23/10 - #8710750: add WRI$_SQLTEXT_REFCOUNT
Rem    ilistvin    12/05/09 - bug8811401: populate wrh_tablespace
Rem    shbose      11/05/09 - Bug 9068654: upgrade changes for 8764375
Rem    alui        10/28/09 - add alerts tables for wlm
Rem    cdilling    08/03/09 - Created
Rem

Rem *************************************************************************
Rem BEGIN a1102000.sql
Rem *************************************************************************

Rem ================================
Rem Begin Inherit Privileges changes
Rem ================================

declare

  procedure grant_inherit_any_privileges(grantee in varchar2) as
  begin
    execute immediate 'grant inherit any privileges to '||
                        dbms_assert.enquote_name(grantee,FALSE);
  exception
    when others then
      dbms_system.ksdwrt(dbms_system.alert_file,
        'a1102000.sql: grant inherit any privileges to '||grantee||
        ' failed: '||sqlerrm);
  end;

  procedure grant_inherit_privileges(user in varchar2) as
  begin
    execute immediate 'grant inherit privileges on user '||
                        dbms_assert.enquote_name(user,FALSE)||' to public';
  exception
    when others then
      dbms_system.ksdwrt(dbms_system.alert_file,
        'a1102000.sql: grant inherit privileges on user '||user||' to public'||
        ' failed: '||sqlerrm);
  end;

begin
  -- 1. Grant INHERIT ANY PRIVILEGES system privilege to these users who have
  --    invoker rights routines that other users may invoke.
  for r in (select username from dba_users
             where username in ('DBSNMP',
                                'SYS',
                                'TSMSYS')) loop
    grant_inherit_any_privileges(r.username);
  end loop;

  -- 2. Grant INHERIT PRIVILEGES privilege on the user to PUBLIC for those
  --    users other than these Oracle-defined, core RDBMS users. If there are
  --    additional users outside core RDBMS that this privilege does not need
  --    to be granted to PUBLIC, the privilege will be revoked in their
  --    individual component upgrade scripts (xxxdbmig.sql) run at a later
  --    point.
  for r in (select username from dba_users
             where username not in ('APPQOSSYS',
                                    'DBSNMP',
                                    'OUTLN',
                                    'SYS',
                                    'SYSTEM',
                                    'TSMSYS')) loop
    grant_inherit_privileges(r.username);
  end loop;
end;
/

Rem ==============================
Rem End Inherit Privileges changes
Rem ==============================

Rem =====================
Rem Begin XStream changes
Rem =====================
Rem Grant SELECT on dictionary views to XStream and GG apply and * users
DECLARE
  user_names_xs_and_gg       dbms_sql.varchar2s;
  select_privs_xs_and_gg     dbms_sql.varchar2s;
  user_names_gg              dbms_sql.varchar2s;
  i                          PLS_INTEGER;
BEGIN
  SELECT username, grant_select_privileges
  BULK COLLECT INTO user_names_xs_and_gg, select_privs_xs_and_gg
  FROM (SELECT username, grant_select_privileges FROM dba_goldengate_privileges
          WHERE privilege_type IN ('APPLY', '*')
        UNION
        SELECT username, grant_select_privileges
          FROM dba_xstream_administrator);

  SELECT username
  BULK COLLECT INTO user_names_gg
  FROM dba_goldengate_privileges;

  -- privs for both xs and gg
  FOR i IN 1 .. user_names_xs_and_gg.count 
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names_xs_and_gg(i) <> 'SYS' AND
        user_names_xs_and_gg(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'grant select on sys.gv_$xstream_table_stats to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);
      EXECUTE IMMEDIATE 'grant select on sys.v_$xstream_table_stats to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_DML_CONF_HANDLERS to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_DML_CONF_COLUMNS to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_HANDLE_COLLISIONS to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_REPERROR_HANDLERS to ' || 
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      IF (select_privs_xs_and_gg(i) = 'YES') THEN
        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_DML_CONF_HANDLERS to ' || 
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_DML_CONF_COLUMNS to ' || 
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_HANDLE_COLLISIONS to ' || 
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_REPERROR_HANDLERS to ' || 
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);
      END IF;
    END IF;
  END LOOP;

  -- privs for gg
  FOR i IN 1 .. user_names_gg.count 
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names_gg(i) <> 'SYS' AND user_names_gg(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'grant select on sys.gv_$goldengate_table_stats to '|| 
        dbms_assert.enquote_name(user_names_gg(i), FALSE);
      EXECUTE IMMEDIATE 'grant select on sys.v_$goldengate_table_stats to '|| 
        dbms_assert.enquote_name(user_names_gg(i), FALSE);
    END IF;
  END LOOP;
END;
/

Rem Move xstream users from streams$_privileged_user to xstream$_privileges
DECLARE
  user_names_xs     dbms_sql.varchar2s;
  cnt               NUMBER;
BEGIN
  SELECT u.name
  BULK COLLECT INTO user_names_xs
  FROM sys.streams$_privileged_user pu, sys.user$ u
  WHERE (bitand(pu.flags, 1) = 1) AND u.user# = pu.user#;

  FOR i IN 1 .. user_names_xs.count 
  LOOP 
    -- delete from streams$_privileged_user
    DELETE FROM sys.streams$_privileged_user
     WHERE user# IN
       (SELECT u.user#
        FROM sys.user$ u
        WHERE u.name = user_names_xs(i));

    -- insert into xstream$_privileges
    SELECT count(*) into cnt 
     FROM sys.xstream$_privileges xp
     WHERE user_names_xs(i) = xp.username;

    IF (cnt = 0) THEN
      INSERT INTO sys.xstream$_privileges(username, privilege_type,
                                          privilege_level)
       VALUES (user_names_xs(i), 3, 1);
    END IF;
  END LOOP;
END;
/

Rem Add connect_user in xstream$_server
DECLARE
  CURSOR server_cur IS SELECT xo.server_name, xo.capture_user
                       FROM dba_xstream_outbound xo;
BEGIN
  FOR server_cur_rec in server_cur LOOP
    UPDATE sys.xstream$_server SET connect_user = server_cur_rec.capture_user
    WHERE  server_name =  server_cur_rec.server_name;
  END LOOP;
END;
/


Rem =====================
Rem End XStream changes
Rem =====================

Rem =====================
Rem Begin AQ changes
Rem =====================

alter session set events '10866 trace name context forever, level 4';

DECLARE
CURSOR s_c IS   SELECT  s.oid, s.destination
                FROM    sys.aq$_schedules s ;
at_pos          BINARY_INTEGER;
dest_q          BINARY_INTEGER := 0;
BEGIN

  -- Update Destq column of aq$_schedules table.

  FOR s_c_rec in s_c LOOP

  -- determine whether destination queue is specified
  at_pos := INSTRB(s_c_rec.destination, '@', 1, 1);
  IF (at_pos = LENGTHB(s_c_rec.destination)) THEN
    dest_q := 0;
  ELSE
    dest_q := 1;
  END IF;

  UPDATE sys.aq$_schedules SET destq = dest_q
  WHERE oid = s_c_rec.oid AND DESTINATION = s_c_rec.destination;

  commit;

  END LOOP;
END;
/   

alter session set events '10866 trace name context off';

DECLARE
CURSOR s_c IS   SELECT  r.eventid, r.agent.address as address
                from sys.aq$_replay_info r where r.agent.address IS NOT NULL;
dot_pos         BINARY_INTEGER;
at_pos          BINARY_INTEGER;
db_domain       VARCHAR2(1024);
new_address     VARCHAR2(1024);
BEGIN

  SELECT UPPER(value) INTO db_domain FROM v$parameter WHERE name = 'db_domain';

  IF db_domain IS NOT NULL THEN
    FOR s_c_rec in s_c LOOP
      at_pos := INSTRB(s_c_rec.address, '@', 1, 1);
      IF (at_pos != 0) THEN
        dot_pos := INSTRB(s_c_rec.address, '.', at_pos, 1);
      ELSE
        dot_pos := INSTRB(s_c_rec.address, '.', 1, 1);
      END IF;
      IF (dot_pos = 0) THEN
        new_address := s_c_rec.address || '.' || db_domain;
        UPDATE sys.aq$_replay_info r set r.agent.address = new_address WHERE
          r.eventid = s_c_rec.eventid AND r.agent.address = s_c_rec.address;
      END IF;

      COMMIT;
    END LOOP;
  END IF;
END;
/

--NOTE
--Migrate only Oracle sys queue tables that were created without specifying
--the compatibility to 10.0.0 for PDB plugin to work correctly.Please note that
--user queues could be defined in SYS and there is no need to migrate them as
--it is not required for PDB plugin and it could also contain millions of msgs.
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt where qt.schema ='SYS' AND
       qt.name in ('SCHEDULER$_EVENT_QTAB', 'SCHEDULER$_REMDB_JOBQTAB', 
                   'SCHEDULER_FILEWATCHER_QT', 'ALERT_QT', 'AQ$_MEM_MC',
                   'AQ_PROP_TABLE', 'SYS$SERVICE_METRICS_TAB');
BEGIN
  FOR qt_rec IN qt_cur LOOP
    BEGIN
      -- convert to 10.0 compatible i.e KWQI_QT_10IQ=8192 defined in kwqi.h
      IF (bitand(qt_rec.flags, 8192) != 8192) THEN
        dbms_aqadm.migrate_queue_table(qt_rec.schema||'.'||qt_rec.name, '10.0.0');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'migrate_queue_table failed: '|| 
                           qt_rec.schema || '.' || qt_rec.name || SQLERRM);
    END;
  END LOOP;
END;
/

Rem =====================
Rem End AQ changes
Rem =====================

Rem =================
Rem Begin WLM changes
Rem =================

ALTER SESSION SET CURRENT_SCHEMA = APPQOSSYS;

CREATE TABLE wlm_mpa_stream
(
   name               VARCHAR2(4000),
   serverorpool       VARCHAR2(8),
   risklevel          NUMBER
)
/

CREATE TABLE wlm_violation_stream
(
   timestamp         DATE,
   serverpool        VARCHAR2(4000),
   violation         VARCHAR2(4000)
)
/

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_MPA_STREAM
  FOR APPQOSSYS.WLM_MPA_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_mpa_stream TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_VIOLATION_STREAM
  FOR APPQOSSYS.WLM_VIOLATION_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_violation_stream TO DBSNMP;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

Rem =================
Rem End WLM changes
Rem =================

Rem =======================================================================
Rem  Begin Changes for Logminer
Rem =======================================================================

  /*
   * bug-9038074
   * ComplexTypeCols is supposed to have
   *   bit 0x01 set IFF table contains XMLCLOB column
   *   bit 0x04 set IFF table contains Binary XML
   * Prior versions would incorrectly set bot 0x01 and 0x04 for binary XML.
   * Note1: The setting of both 0x01 and 0x05 is legitimate IFF the table
   * contains at least one XMLCLOB AND one Binary XML column.
   * Note2: On upgrade the max(objv#) entrys in logmnrc_gtcs and _gtlo will
   * be refreshed, so the upgrade steps below are primarily to benefit
   * older objv#s.
   * Note3: Though unlikely, if logmnr_gtcs has not been populated for a given
   * entry in logmnr_gtlo, the nvl function is used to leave results, though
   * not correct, as they were.  In most cases this is the best option.
   */
update system.logmnrc_gtlo tlo
  set tlo.complextypecols = nvl
  (
    (
      select
/* lob     */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 68), 4, 1, 0)) +
/* object  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 1), 1, 2, 0)) +
/* binary  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 68), 68, 4, 0)) +
/* schema  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 2), 2, 8, 0)) +
/* hierach */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 512), 512, 16, 0))
      from system.logmnrc_gtcs tcs
      where tcs.logmnr_uid = tlo.logmnr_uid AND
            tcs.XopqTypeType = 1 AND
            tcs.obj# = tlo.BASEOBJ# AND
            tcs.objv# = tlo.BASEOBJV#
    ), tlo.complextypecols
  )
  where 5 = bitand(tlo.complextypecols, 5);
commit;

/*
 *  bug-9038074
 *  logmnrtloflags is supposed to have
 *    bit 0x02 set for XMLTYPE table stored as CLOB
 *    bit 0x04 set for XMLTYPE table stored as OR
 *    bit 0x08 set for XMLTYPE table stored as Binary XML
 *  Because of this bug XMLTYPE table stored as Binary XML would incorrectly
 *  be identified as XMLTYPE table stored as CLOB.  This upgrade change
 *  corrects the error.  Note2 and Note3 above for complextypecols upgrade
 *  are also relevant to this upgrade.
 *
 *  Note: 4294967281 is 0xFFFFFFF1.  This is to keep all current logmnrtloflags
 *        except the possible problematic setting of flags related to
 *        CLOB, OR, or Binary XML XMLTYPE tables.
 */
update system.logmnrc_gtlo tlo
  set tlo.logmnrtloflags = nvl
  (
    (
      (bitand(4294967281, tlo.logmnrtloflags)) +
      (
        select case 
          when bitand(tcs.XopqTypeFlags, 1) = 1 /* XMLOR */
            then 4 /* KRVX_OA_TLO_XMLTYPEOR */
          when bitand(tcs.XopqTypeFlags, 64) = 64 /* Binary XML */
            then 8 /* KRVX_OA_TLO_XMLTYPECSX */
          when bitand(tcs.XopqTypeFlags, 4) = 4 /* clob */
            then 2 /* KRVX_OA_TLO_XMLTYPECLOB */
          else 0
          end
        from system.logmnrc_gtcs tcs
        where tcs.logmnr_uid = tlo.logmnr_uid AND
              tcs.XopqTypeType = 1 AND
              tcs.obj# = tlo.BASEOBJ# AND
              tcs.objv# = tlo.BASEOBJV# AND
              tcs.colname = 'SYS_NC_ROWINFO$' AND
              tcs.type# = 58
      )
    ), tlo.logmnrtloflags
  )
  where 2 = bitand(tlo.logmnrtloflags, 2) AND
        1 = bitand(tlo.property, 1);
commit;

/*
 *  bug-9038074
 *    With the above changes to complextypecols the MCV must be recalculated
 *    for the modified rows.
 *    Also 11.1 contained a flaw with the logic that determined the MCV for
 *    tables containing ADTs that contained an XMLOR attribute.  These would
 *    incorrectly be given an MCV of 11.0.0. when the correct MCV should have
 *    been 99.99.99 (i.e. not supported).
 *    Here we try to selectively recalculate all MCVs that are potentially
 *    incorrect.
 *    Note: The Streams MVDD does not maintain LOGMNRMCV.  Presumably
 *          gtlo.logmnrmcv will be NULL for MVDDs and not be updated by
 *          this statement.
 */
update system.logmnrc_gtlo gtlo
    set gtlo.LOGMNRMCV = '99.9.9.9.9'
    where gtlo.logmnrmcv = '11.0.0.0.0' AND
          (4 = bitand(GTLO.complextypecols, 4) /* KRVX_OA_XMLCSX column pres */
           OR                               /* Unsupported ADT present */
           0 <> bitand(GTLO.UnsupportedCols, /* KRVX_OA_ADT */ 32 +
                                             /* KRVX_OA_NTB */ 64 +
                                             /* KRVX_OA_NAR */ 128 ));
commit;

/* new LOGMINING privilege must be granted to users */
DECLARE   
  stmt          CLOB;
  TYPE          refcurs IS REF CURSOR;
  curs          refcurs;
  name          VARCHAR2(255);
  admin         VARCHAR2(3);
BEGIN
  stmt := 'select grantee,admin_option from dba_sys_privs where privilege=' ||
        '''' || 'SELECT ANY TRANSACTION' || '''';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO name,admin;
    EXIT WHEN curs%NOTFOUND;
    IF admin = 'YES' OR name = 'SYS' THEN
      EXECUTE IMMEDIATE 'GRANT LOGMINING TO ' || 
        DBMS_ASSERT.ENQUOTE_NAME(name,FALSE) || ' WITH ADMIN OPTION';
    ELSE
      EXECUTE IMMEDIATE 'GRANT LOGMINING TO ' || 
        DBMS_ASSERT.ENQUOTE_NAME(name,FALSE);
    END IF;
  END LOOP;
END;
/

Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================

Rem=========================================================================
Rem BEGIN Logical Standby upgrade items
Rem=========================================================================
Rem
Rem BUG 19630651
Rem Convert Logical Standby Ckpt data from 11.2.0.4 format to 12.1 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_11204to121;
end;
/

Rem =======================================================================
Rem  End Changes for Logical Standby
Rem =======================================================================

Rem ==========================
Rem Begin Bug 8811401 changes
Rem ==========================
create index WRH$_SEG_STAT_OBJ_INDEX on WRH$_SEG_STAT_OBJ(dbid, snap_id)
  tablespace SYSAUX
/

begin
insert into wrh$_tablespace
        (snap_id, dbid, ts#, tsname, contents, segment_space_management,
         extent_management)
  select 0, (select dbid from v$database), ts.ts#, ts.name as tsname,
        decode(ts.contents$, 0, (decode(bitand(ts.flags, 16), 16, 'UNDO',
               'PERMANENT')), 1, 'TEMPORARY')            as contents,
        decode(bitand(ts.flags,32), 32,'AUTO', 'MANUAL') as segspace_mgmt,
        decode(ts.bitmapped, 0, 'DICTIONARY', 'LOCAL')   as extent_management
   from sys.ts$ ts
  where ts.online$ != 3
    and bitand(ts.flags, 2048) != 2048
    and not exists (select 1 from wrh$_tablespace t
                     where dbid = (select dbid from v$database)
                       and t.ts# = ts.ts#);
  commit;
end;
/

Rem ==========================
Rem End Bug 8811401 changes
Rem ==========================

Rem ===========================================================================
Rem Begin Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

alter table WRI$_SQLTEXT_REFCOUNT disable constraint 
WRI$_SQLTEXT_REFCOUNT_PK
/

declare
  num_rows number;
begin

  select count(*) 
  into num_rows
  from wri$_sqltext_refcount;

  -- insert in wri$_sqltext_refcount only if it was not done before, i.e 
  -- this is not a re-upgrade attempt 
  if (num_rows = 0) then

    insert into WRI$_SQLTEXT_REFCOUNT(dbid, sql_id, ref_count)
      select dbid, sql_id, ref_count
      from   wrh$_sqltext
      where  ref_count > 0;

    commit;
  end if;

end;
/


alter table WRI$_SQLTEXT_REFCOUNT enable constraint
WRI$_SQLTEXT_REFCOUNT_PK
/

Rem ===========================================================================
Rem End Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

Rem =============================================================================
Rem Advanced Queuing related upgrade changes
Rem =============================================================================

Rem =============================================================================
Rem Bug #10637224 - recreate the dequeue by condition view to fix the join clause
Rem =============================================================================

DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
BEGIN
  FOR qt_rec IN qt_cur LOOP
  
    BEGIN
      IF dbms_aqadm_sys.mcq_8_1(qt_rec.flags) THEN
        sys.dbms_prvtaqim.create_deq_view(qt_rec.schema, qt_rec.name,
                                          qt_rec.flags); 
      END IF;

    EXCEPTION
      when others then
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'a1102000.sql:  recreate deq view ' ||
                           'failed for ' || qt_rec.schema || '.' ||
                           qt_rec.name);
    END;
  END LOOP;
END;
/

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem  ODM model upgrades
exec dmp_sys.upgrade_models('12.0.0');
/

Rem =====================
Rem End ODM changes
Rem =====================


Rem ================================================================
Rem Begin Digest verifiers for XML DB HTTP server  changes
Rem ================================================================

create or replace view DBA_DIGEST_VERIFIERS 
  (USERNAME, HAS_DIGEST_VERIFIERS, DIGEST_TYPE) as 
select u.name, 'YES', 'MD5' from user$ u where instr(spare4, 'H:')>0
union
select u.name, 'NO', NULL from user$ u where not(instr(spare4, 'H:')>0) or spare4 is null
/

create or replace public synonym DBA_DIGEST_VERIFIERS for DBA_DIGEST_VERIFIERS
/
grant select on DBA_DIGEST_VERIFIERS to select_catalog_role
/

comment on table DBA_DIGEST_VERIFIERS is 
'Information about which users have Digest verifiers and the verifier types'
/

comment on column DBA_DIGEST_VERIFIERS.USERNAME is
'Name of the user'
/

comment on column DBA_DIGEST_VERIFIERS.HAS_DIGEST_VERIFIERS is
'YES if Digest verifier exist, NO otherwise'
/

comment on column DBA_DIGEST_VERIFIERS.DIGEST_TYPE is
'The type of the Digest verifier'
/
Rem ================================================================
Rem End Digest verifiers for XML DB HTTP server  changes
Rem ================================================================

Rem ============================
Rem Begin DBMS Scheduler changes
Rem ============================

update sys.scheduler$_job j set flags=(DECODE(BITAND(j.flags, 65536), 0,
    j.flags - BITAND(j.flags, 35184372088832 + 70368744177664),
    j.flags + 35184372088832 + 70368744177664 - 65536
            - BITAND(j.flags, 35184372088832 + 70368744177664)));

update sys.scheduler$_lightweight_job l set flags=(DECODE(BITAND(l.flags, 65536), 0,
    l.flags - BITAND(l.flags, 35184372088832 + 70368744177664),
    l.flags + 35184372088832 + 70368744177664 - 65536
            - BITAND(l.flags, 35184372088832 + 70368744177664)));

commit;

Rem ==========================
Rem End DBMS Scheduler changes
Rem ==========================
Rem ================================================================
Rem BEGIN changes for DBMS CREDENTIAL package 
Rem ================================================================
-- - Granting CREATE CREDENTIAL to users with CREATE JOB for compatibility
DECLARE
  TYPE user_clause IS RECORD (grantee varchar(128), admin varchar(30));
  TYPE varchartab IS TABLE OF user_clause;
  user_clauses varchartab;
  i PLS_INTEGER;
BEGIN
  SELECT grantee,
    decode(admin_option,'YES',' WITH ADMIN OPTION','') as admin
  BULK COLLECT INTO user_clauses FROM dba_sys_privs
  WHERE PRIVILEGE='CREATE JOB';

  FOR i IN user_clauses.FIRST ..  user_clauses.LAST
  LOOP
    EXECUTE IMMEDIATE 'GRANT CREATE CREDENTIAL TO ' ||
             '"' || user_clauses(i).grantee || '" ' ||
             user_clauses(i).admin;
END LOOP;
END;
/
DECLARE
  TYPE user_clause IS RECORD (grantee varchar(128), admin varchar(30));
  TYPE varchartab IS TABLE OF user_clause;
  user_clauses varchartab;
  i PLS_INTEGER;
BEGIN

  SELECT grantee,
    decode(admin_option,'YES',' WITH ADMIN OPTION','') as admin
  BULK COLLECT INTO user_clauses FROM dba_sys_privs
  WHERE PRIVILEGE='CREATE ANY JOB';

  FOR i IN user_clauses.FIRST ..  user_clauses.LAST
  LOOP
    EXECUTE IMMEDIATE 'GRANT CREATE ANY CREDENTIAL TO ' ||
             '"' || user_clauses(i).grantee || '" ' ||
             user_clauses(i).admin;
END LOOP;
END;
/

DECLARE
  cursor creds is
    select owner, credential_name from dba_scheduler_credentials
      where username is NULL;
BEGIN
  FOR cred_info IN creds
  LOOP
    dbms_credential.enable_credential('"'||cred_info.owner||'"."'||
                                   cred_info.credential_name||'"');
  END LOOP;
END;
/

Rem ================================================================
Rem END changes for DBMS CREDENTIAL package 
Rem ================================================================

Rem =======================================================================
Rem  Begin Changes for Database Replay 
Rem =======================================================================

Rem
Rem Set capture file id equal to replay file id. This is the correct behavior
Rem for non-consolidated replays. Since this is an upgrade, this rule holds.
Rem
update WRR$_REPLAY_DIVERGENCE
set cap_file_id = file_id
where cap_file_id IS NOT NULL;

commit;

update WRR$_REPLAY_SQL_BINDS
set cap_file_id = file_id
where cap_file_id IS NOT NULL;

commit;

Rem =======================================================================
Rem  End Changes for Database Replay 
Rem =======================================================================

Rem *************************************************************************
Rem Optimizer changes - BEGIN
Rem *************************************************************************

-- upgrading synopsis tables and history tables involves staging tables that
-- are partitioned. In normal cases they should have been renamed.
-- In abnormal cases such as exchange does not succeed, they can still hang
-- around. drop them here (dropping partitioned tables can only be done
-- in "a" script since it involves tables not available in "c" script)
declare
  cursor cur is
    select 'drop table ' || o.name sqltxt
    from obj$ o, user$ u
    where o.owner# = u.user# and u.name = 'SYS' and
          (o.name like 'TPART%SYNOPSIS$%' or
           o.name like '%HISTHEAD_HISTORY2%' or
           o.name like '%HISTGRM_HISTORY2%') and
          o.type# = 2;
begin
  -- drop staging tables
  for stmt in cur loop
    execute immediate stmt.sqltxt;
  end loop;
end;
/

Rem *************************************************************************
Rem Optimizer changes - END
Rem *************************************************************************


Rem *************************************************************************
Rem  bug 17436936:DROP system generated shadow types - BEGIN
Rem *************************************************************************
  
REM In upgrade from 11.2 or earlier versions to 12.1 and downgrade from 12.1 to
REM  earlier versions had problem that shadow types were leaked. This happened
REM because the name generation algorithm for shadow type generation was 
REM  changed IN 12.1 and it uses a hash instead of obj# due to CDB project. 
REM The fix for that was made in upgrade/downgrade scripts. The way it worked
REM was generating DDL of the type 
REM 
REM drop <schema>.<type> force. 
REM
REM However, this scheme does not work with editions as it is not allowed TO
REM DROP types when schema name is adjunct schema name. Therefore, now the 
REM  code was changed to use DBMS_SQL to drop these shadow types in each 
REM  editions. As we now use new DBMS_SQL and view DBMS_OBJECTS_AE, the 
REM  code from upgrade script was moved to a* script from c* script to 
REM  make sure all the views and packages are installed before this script
REM is run.
REM bug 18220091: CHECK that schema name AND owner name are proper sql names
REM AND make sure, names LIKE o'brian also work.   
  
DECLARE
   rc sys_refcursor;
   str VARCHAR2(4000);
   name VARCHAR2(32);
   owner VARCHAR(32);
   edition VARCHAR2(32);
   editionable VARCHAR2(1);
   my_cursor NUMBER := dbms_sql.open_cursor();
BEGIN
      
   open rc FOR select o.name, db.owner, db.edition_name, db.EDITIONABLE
     from sys.type$ t, sys.obj$ o,  dba_objects_ae db
     where  o.oid$ = t.tvoid
     and o.type# =13
     AND o.subname IS NULL 
     AND REGEXP_LIKE(o.name, 'SYS_PLSQL_[0-9]+_[[:alnum:]]+_[12]')
     and o.obj#=db.object_id;
   
   LOOP
      fetch rc INTO name, owner, edition, editionable;
      
      EXIT WHEN rc%NOTFOUND;
      
      str := 'drop type '||dbms_assert.ENQUOTE_name(owner, false)||'.'||dbms_assert.ENQUOTE_name(name, false)||' force';
      IF (editionable = 'Y') THEN
         DECLARE
            retval NUMBER;
         BEGIN
            dbms_sql.parse(c =>my_cursor, statement =>str, 
              language_flag => DBMS_SQL.NATIVE, edition =>edition);
            retval := dbms_sql.execute(my_cursor);
         END;
      ELSE
         execute immediate str;
      END IF;
   END LOOP;
   dbms_sql.close_cursor(my_cursor);
EXCEPTION WHEN OTHERS THEN
   dbms_sql.close_cursor(my_cursor);
   RAISE;
END;
/  

Rem *************************************************************************
Rem  bug 17436936:DROP system generated shadow types - END
Rem *************************************************************************
  

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================  

Rem Invoke patch upgrade script
  
@@a1201000.sql
 
Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END a1102000.sql
Rem *************************************************************************
