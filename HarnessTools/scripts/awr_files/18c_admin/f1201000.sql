Rem
Rem $Header: rdbms/admin/f1201000.sql /main/32 2017/09/26 09:53:16 alestrel Exp $
Rem
Rem f1201000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      f1201000.sql - Use PL/SQL packages for downgrade 
Rem                     from 12.1.0.2 patch release
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      using PL/SQL packages needed to downgrade from the current 
Rem      12.1 patch release to prior 12.1 patch releases
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/f1201000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/f1201000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alestrel   09/10/17 - Bug 25992938. Drop AUTO_SQL_TUNING_PROG in f file
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    pyam        09/26/16 - RTI 19634111: convert types to local
Rem    gravipat    09/19/16 - 24690877: move call to update_version from f
Rem                           script to catdwgrd
Rem    jlingow     07/01/16 - dropping scheduler subscriber and registration to
Rem                           sys$service_metrics queue
Rem    welin       06/02/16 - invoking subsequent release
Rem    thbaby      04/13/16 - Bug 23039033: drop and re-create 
Rem                           cleanup_transient_type, cleanup_transient_pkg
Rem    thbaby      04/13/16 - Bug 23030152: drop and re-create 
Rem                           cleanup_online_pmo
Rem    jmuller     02/25/16 - Move dbms_pdb.check_nft() call to f1201000.sql
Rem    sjanardh    11/25/15 - Replace dbms_aqadm_syscalls APIs w/ dbms_aqadm_sys APIs
Rem    shbose      11/17/15 - bug 21193221: drop eviction table from sharded
Rem                           queues
Rem    desingh     09/07/15 - bug21797512: ugrade 12c view
Rem    yanlili     06/22/15 - Fix bug 20897609: Revoke XSCONNECT from RAS
Rem                            principals
Rem    molagapp    06/17/15 - bug-21132967
Rem    yanlili     06/10/15 - Fix lrg 16743762: drop schema acl
Rem    hlakshma    03/20/15 - Delete rows in ilm_param$ corresponding to 12.2
Rem                           features
Rem    atomar      12/17/14 - atomar_proj_45944_exception_q_phase_2
Rem    desingh     12/17/14 - sharded queue delay
Rem    jomcdon     10/09/14 - bug 19571350: restore old DBRM internal_plan
Rem    svivian     09/09/14 - bug 18529468: downgrade logminer spill
Rem    claguna     07/17/14 - Downgrade Job Incompat and Resource Constraints
Rem    jaeblee     06/24/14 - update version in container$
Rem    amozes      05/11/14 - ODM 12.2 changes
Rem    jomcdon     04/11/14 - implement profiles functionality
Rem    devghosh    04/02/14 - bug17709018: public grant for unflushed_dequeues
Rem    cdilling    01/22/14 - bug 18117095 - set version to truncated current version (i.e. 12.1.0)
Rem    cdilling    12/23/13 - remove version from downgraded as it will be set to prv_version in the function itself
Rem    cdilling    12/16/13 - bug 17961326
Rem    cdilling    10/16/12 - patch downgrade back to 12.1.0.1
Rem    cdilling    10/16/12 - Created
Rem

Rem *************************************************************************
Rem BEGIN f1201000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release
Rem =========================================================================

@@f1202000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary to 12.1.0
Rem =========================================================================

BEGIN
   dbms_registry.downgrading('CATALOG');
   dbms_registry.downgrading('CATPROC');
END;
/

execute dbms_scheduler.disable('FILE_SIZE_UPD', TRUE);
BEGIN
  dbms_scheduler.stop_job('FILE_SIZE_UPD', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/
execute dbms_scheduler.drop_job('FILE_SIZE_UPD', TRUE);


Rem =========================================================================
Rem ALTER SHARDED QUEUE TABLE FOR EXCEPTION QUEUES
Rem =========================================================================

DECLARE
CURSOR dql_alter IS
select name, TABLE_OBJNO from system.aq$_queues where sharded =1;
stmt varchar2(500);
tab_name VARCHAR2(128);
usern VARCHAR2(128);
BEGIN
sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);
    FOR dql_alter_rec IN dql_alter LOOP
      select name into usern from sys.user$
      where user#=(select owner# from sys.obj$ where obj#=dql_alter_rec.TABLE_OBJNO);

      BEGIN

        stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
                 dql_alter_rec.name || ' drop (old_msgid,exception_queue)' ;

                EXECUTE IMMEDIATE stmt;

      exception when others then
        if sqlcode in (-904) then null;
        end if;
      end;

    end loop;
sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
end;
/

Rem =========================================================================
Rem BEGIN AQ Correct grant for aq$_unflushed_dequeues 
Rem =========================================================================

DECLARE
  stmt  VARCHAR2(500);
BEGIN

  -- only when it has flags multiple deq(1), multi-cosnumer(8)
  -- and 10i style queue tables(8192)
  FOR cur_rec IN (
                  SELECT schema, name, flags
                  FROM system.aq$_queue_tables
                  WHERE bitand(flags, 1)=1 and
                        bitand(flags, 8)=8 and
                        bitand(flags, 8192)=8192
                 )
  LOOP
    BEGIN

      sys.dbms_prvtaqim.create_base_view(
               cur_rec.schema, cur_rec.name, cur_rec.flags);

    END;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,
                         'error in view creation' || sqlcode);
      RAISE;

END;
/

Rem =========================================================================
Rem END AQ Correct grant for aq$_unflushed_dequeues
Rem =========================================================================

Rem =========================================================================
Rem BEGIN AQ sharded queues queue table changes
Rem =========================================================================
DECLARE
CURSOR dql_alter IS
select name, TABLE_OBJNO from system.aq$_queues where sharded =1;
stmt varchar2(500);
usern VARCHAR2(128);
BEGIN
sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);

    FOR dql_alter_rec IN dql_alter LOOP
      select name into usern from sys.user$
      where user#=(select owner# from sys.obj$ 
      where obj#=dql_alter_rec.TABLE_OBJNO);

      BEGIN

        stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
                dql_alter_rec.name || ' rename column delivery_time TO delay' ;

                EXECUTE IMMEDIATE stmt;

        stmt := 'alter table '||DBMS_ASSERT.ENQUOTE_NAME(usern)|| '.'||
                 dql_alter_rec.name || ' drop (subshard)' ;

                EXECUTE IMMEDIATE stmt;

        stmt := TO_CLOB('DROP INDEX '                              ||
                        dbms_assert.enquote_name(usern, FALSE) || '.'     ||
                        dbms_assert.enquote_name('qt' || 
                            dql_alter_rec.TABLE_OBJNO || '_delay_idx', FALSE));

                EXECUTE IMMEDIATE stmt;
 
      exception when others then
        if sqlcode in (-904) then null;
        end if;
      end;

    end loop;

sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);

end;
/
Rem =========================================================================
Rem END AQ sharded queues queue table changes
Rem =========================================================================

Rem =======================================================================
Rem  Begin changes : downgrade queue table for long identifiers
Rem =======================================================================
declare
  cursor allqueues is
  select t.schema schema, q.name qname , q.table_objno qobj, t.flags qt_flags,
  q.usage qtype
  from system.aq$_queues q, system.aq$_queue_tables t
  WHERE q.table_objno = t.objno AND NVL(q.sharded,0)=0;

  tabn varchar2(30);
  owner number;
  usern varchar2(30);
  qtabnm varchar2(300);
  altstmt  varchar2(300);
  COLUMN_NONEXISTENT EXCEPTION;
  TABLE_NONEXISTENT EXCEPTION;

  pragma EXCEPTION_INIT(COLUMN_NONEXISTENT, -904);
  pragma EXCEPTION_INIT(TABLE_NONEXISTENT, -942);
begin
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.ENABLE_AQ_DDL);
  for allrow in allqueues loop
    begin
    select owner# into owner from sys.obj$ where obj#= allrow.qobj;
    select name into usern from sys.user$ where user# =owner;
    select name into tabn from sys.obj$ where obj#= allrow.qobj;

    qtabnm := DBMS_ASSERT.ENQUOTE_NAME(usern) || '.' ||
              DBMS_ASSERT.ENQUOTE_NAME(tabn);
    if(tabn = 'AQ_EVENT_TABLE' or tabn = 'DEF$_AQCALL' or tabn = 'DEF$_AQERROR')
    then
      altstmt := 'alter table ' || qtabnm || ' modify(q_name varchar2(30),' ||
               ' exception_qschema varchar2(30),'||
               '  exception_queue varchar2(30))';
      execute immediate altstmt;
    else
      altstmt := ' alter table ' || qtabnm ||
                 ' modify(sender_name varchar2(30),' ||
                 ' q_name varchar2(30), exception_qschema varchar2(30), ' ||
                 'exception_queue varchar2(30))';
      execute immediate altstmt;
    end if;
    IF bitand(allrow.qt_flags, 8192) = 8192 THEN
      BEGIN
      altstmt := ' alter table ' || qtabnm ||
                 ' modify(enq_uid varchar2(30),' ||
                 ' deq_uid varchar2(30))';
      execute immediate altstmt;
      exception  when COLUMN_NONEXISTENT then
      NULL;
      END;
    END IF;

    exception  when COLUMN_NONEXISTENT then
      NULL;
    when TABLE_NONEXISTENT then
      NULL;
    when OTHERS THEN
     raise;
    end;
  end loop;
  sys.dbms_aqadm_sys.Mark_Internal_Tables(dbms_aqadm_sys.DISABLE_AQ_DDL);
end;
/

Rem =======================================================================
Rem  End changes: downgrade queue table for long identifiers
Rem =======================================================================

Rem =========================================================================
Rem BEGIN downgrade 12C Queue View
Rem =========================================================================

DECLARE
BEGIN

  FOR cur_rec IN (
                  SELECT t.schema, t.name, t.flags, q.eventid
                  FROM system.aq$_queue_tables t, system.aq$_queues q
                  WHERE t.objno = q.table_objno and q.sharded =1 
                 )
  LOOP
    BEGIN

      sys.dbms_prvtaqim.create_base_view_12101(
               cur_rec.schema, cur_rec.name, cur_rec.eventid, 
               sys.dbms_aqadm_sys.mcq_12gJms(cur_rec.flags));

    END;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,
                         'error in 12C view creation' || sqlcode);
      RAISE;

END;
/

Rem =========================================================================
Rem BEGIN downgrade 12C Queue View
Rem =========================================================================

Rem =======================================================================
Rem  Begin Downgrade eviction table for Sharded Queues AQ
Rem =======================================================================

DECLARE
   TYPE CurTyp  IS REF CURSOR;  -- define weak REF CURSOR type
   tab_cv          CurTyp;      -- declare cursor variable
   schemaname       varchar2(128);
   tabname          varchar2(128);
   sel_stmt         varchar2(500);
BEGIN
      sys.dbms_aqadm_sys.Mark_Internal_Tables
      (dbms_aqadm_sys.ENABLE_AQ_DDL);
      sel_stmt := 'select t.schema, t.name from system.aq$_queue_tables t where 
      bitand(flags, 67108864)=67108864';
      open tab_cv for sel_stmt;
     LOOP
       FETCH tab_cv INTO schemaname, tabname;
       EXIT WHEN tab_cv%NOTFOUND;
       BEGIN

       sys.dbms_aqadm_sys.drop_eviction_table(schemaname, tabname);
       commit;
       END;
     END LOOP;
      sys.dbms_aqadm_sys.Mark_Internal_Tables
      (dbms_aqadm_sys.DISABLE_AQ_DDL);

     EXCEPTION
        WHEN OTHERS THEN
          sys.dbms_aqadm_sys.Mark_Internal_Tables
             (dbms_aqadm_sys.DISABLE_AQ_DDL);

          dbms_system.ksdwrt(dbms_system.trace_file,
                             'error in sharded queue drop eviction table ' || 
                              sqlcode ||
                             ' schema ' || schemaname || ' tabname ' ||
                             tabname);

          IF SQLCODE = -1647 THEN
            dbms_system.ksdwrt(dbms_system.alert_file,
                               ' There is no impact of this error on ' ||
                               ' Sharded Queue operation');
          END IF;
         

        RAISE;
END;
/

Rem =======================================================================
Rem  End Downgrade eviction table for Sharded Queues AQ
Rem =======================================================================


Rem=========================================================================
Rem BEGIN Resource Manager downgrade items
Rem=========================================================================

Rem Disable Resource Manager plan and drop the built-in plans
Rem Also drop all PROFILE directives in the CDB plans
alter system set resource_manager_plan='' sid='*';
exec dbms_rmin_sys.downgrade_prep(drop_all_profiles => TRUE);

Rem The definition of INTERNAL_PLAN changes in 12.2. Revert to the old
Rem definition on downgrade. This procedure only does an action if
Rem INTERNAL_PLAN has the new definition.
exec dbms_rmin_sys.restore_old_internal_plan;

Rem=========================================================================
Rem END Resource Manager downgrade items
Rem=========================================================================


Rem ========================================================================
Rem BEGIN Downgrade Scheduler Job incompatibilities and resource constraints
Rem ========================================================================

DECLARE
  cursor jrs is
    select  owner, resource_name from dba_scheduler_resources;
BEGIN
  FOR jr_info IN jrs
  LOOP
    dbms_scheduler.drop_resource('"'||jr_info.owner||'"."'||
                                   jr_info.resource_name||'"');
  END LOOP;
END;
/

DECLARE
  cursor ics is
    select  owner, incompatibility_name from dba_scheduler_incompats;
BEGIN
  FOR ic_info IN ics
  LOOP
    dbms_scheduler.drop_incompatibility('"'||ic_info.owner||'"."'||
                                   ic_info.incompatibility_name||'"');
  END LOOP;
END;
/

Rem ========================================================================
Rem END Downgrade Scheduler Job incompatibilities and resource constraints
Rem ========================================================================

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem ODM model downgrades
exec dmp_sys.downgrade_models('12.2.0');
/

Rem =====================
Rem End ODM changes
Rem =====================

Rem ========================================================================
Rem BEGIN Downgrade Scheduler Load Balancing
Rem ========================================================================

DECLARE 
  reginfo sys.aq$_reg_info;
  reglist sys.aq$_reg_info_list;
BEGIN
  reginfo := sys.aq$_reg_info('SYS.SYS$SERVICE_METRICS:"SCHEDULER$_LBAGT"', 
      dbms_aq.namespace_aq,'plsql://SYS.SCHEDULER$NTFY_SVC_METRICS',NULL);
  reglist := sys.aq$_reg_info_list(reginfo);
  dbms_aq.unregister ( reglist, 1 );
END;
/

DECLARE subscriber sys.aq$_agent;
BEGIN
  subscriber := sys.aq$_agent('SCHEDULER$_LBAGT', NULL, NULL);
  dbms_aqadm.remove_subscriber(queue_name => 'SYS.SYS$SERVICE_METRICS',
    subscriber => subscriber);
END;
/

Rem ========================================================================
Rem END Downgrade Scheduler Load Balancing
Rem ========================================================================

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================

Rem BUG 18529468:
Rem Convert Logical Standby Ckpt data from 12.2 format to 12.1 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_122to12;
end;
/

Rem =======================================================================
Rem End Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem Begin Drop scheduler job
Rem =======================================================================

BEGIN
  dbms_scheduler.disable('CLEANUP_UNNEEDED_122_METADATA', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27476 THEN
    NULL; --Supress job doesn't exist error
  END IF;
END;
/

BEGIN
  dbms_scheduler.stop_job('CLEANUP_UNNEEDED_122_METADATA', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27475 THEN
    NULL; --Supress unknown job error
  END IF;
END;
/
 
BEGIN
  dbms_scheduler.drop_job('CLEANUP_UNNEEDED_122_METADATA', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27475 THEN
    NULL; --Supress unknown job error
  END IF;
END;
/

Rem =======================================================================
Rem End Drop scheduler job
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for Proj 47808: Transportable PDB backups
Rem =======================================================================

BEGIN
   dbms_scheduler.drop_job(
      job_name => 'SYS.ORA$PREPLUGIN_BACKUP_JOB',
      force    => TRUE);
   commit;
EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE = -27475) THEN
         NULL;
      ELSE
         RAISE;
      END IF;
END;
/

BEGIN
   dbms_scheduler.drop_program(
      program_name => 'SYS.ORA$PREPLUGIN_BACKUP_PRG',
      force        => TRUE);
   commit;
EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE = -27476) THEN
         NULL;
      ELSE
         RAISE;
      END IF;
END;
/


BEGIN
   dbms_aqadm.stop_queue('SYS.ORA$PREPLUGIN_BACKUP_QUE');
   commit;
EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE = -24010) THEN
         NULL;
      ELSE
         RAISE;
      END IF;
END;
/

BEGIN
   dbms_aqadm.drop_queue('SYS.ORA$PREPLUGIN_BACKUP_QUE');
   commit;
EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE = -24010) THEN
         NULL;
      ELSE
         RAISE;
      END IF;
END;
/

BEGIN
   dbms_aqadm.drop_queue_table('SYS.ORA$PREPLUGIN_BACKUP_QTB');
   commit;
EXCEPTION
   WHEN OTHERS THEN
      IF (SQLCODE = -24010) THEN
         NULL;
      ELSE
         RAISE;
      END IF;
END;
/

Rem =======================================================================
Rem END changes for Proj 47808: Transportable PDB backups
Rem =======================================================================

Rem **************************************************************************
Rem BEGIN Downgrade ilm_param$ to 12.1
Rem **************************************************************************

begin
delete from sys.ilm_param$ where param#=DBMS_ILM_ADMIN.ABS_JOBLIMIT;
delete from sys.ilm_param$ where param#=DBMS_ILM_ADMIN.JOB_SIZELIMIT;
commit;
end;
/

Rem **************************************************************************
Rem END Downgrade ilm_param$ to 12.1
Rem **************************************************************************

Rem ========================================================================
Rem BEGIN Downgrade RAS Schema ACL
Rem ========================================================================

-- Drop schema ACL
DECLARE
qaclname  VARCHAR2(300) := NULL;
CURSOR schemaacl_users IS
select owner from sys.xs$obj where name = 'XS$SCHEMA_ACL' and type = 3;
BEGIN
FOR schemaacl_users_crec IN schemaacl_users LOOP
  qaclname := sys.dbms_assert.enquote_name(schemaacl_users_crec.owner, false)
              ||'.'||sys.dbms_assert.enquote_name('XS$SCHEMA_ACL', false);
  sys.xs_acl.delete_acl(qaclname, XS_ADMIN_UTIL.CASCADE_OPTION);
END LOOP;
END;
/

Rem ========================================================================
Rem END Downgrade RAS Schema ACL
Rem ========================================================================

Rem *************************************************************************
Rem Begin Bug 20897609 
Rem *************************************************************************

-- Revoke XSCONNECT role from RAS principals
DECLARE
CURSOR xsconnect_principals IS
select grantee from dba_xs_role_grants where granted_role = 'XSCONNECT';
BEGIN
FOR xsconnect_crec IN xsconnect_principals LOOP
 sys.xs_principal.revoke_roles(xsconnect_crec.grantee, 'XSCONNECT');
END LOOP;
END;
/

Rem *************************************************************************
Rem End Bug 20897609
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for bug 19328303
Rem =======================================================================

exec dbms_pdb.check_nft();

Rem =======================================================================
Rem  End Changes for bug 19328303
Rem =======================================================================

Rem =======================================================================
Rem Bug 23039033: drop and re-create scheduler job cleanup_transient_type
Rem               drop and re-create scheduler job cleanup_transient_pkg
Rem =======================================================================

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_TYPE', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_TYPE', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_TYPE', TRUE);

-- create scheduler job to cleanup transient types
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_TYPE';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_TYP
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(4); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(150, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Types');
  end if;
end;
/

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_PKG', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_PKG', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_PKG', TRUE);

-- create scheduler job to cleanup cursor transient packages
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_TRANSIENT_PKG';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_CLNUP_TRANS_PKG
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(5); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(160, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 2',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup Transient Packages');
  end if;
end;
/

Rem =======================================================================
Rem Bug 23039033: drop and re-create scheduler job cleanup_transient_type
Rem               drop and re-create scheduler job cleanup_transient_pkg
Rem =======================================================================

Rem =======================================================================
Rem Bug 23030152: drop and re-create scheduler job cleanup_online_pmo
Rem =======================================================================

execute dbms_scheduler.disable('CLEANUP_ONLINE_PMO', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_ONLINE_PMO', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; -- Suppress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_ONLINE_PMO', TRUE);

-- create scheduler job to perform online PMO cleanup
declare
  exist   number;
  jobname varchar2(128);
begin
  jobname := 'CLEANUP_ONLINE_PMO';

  select count(*) into exist 
  from   dba_scheduler_jobs 
  where  job_name=jobname AND owner='SYS';

  if exist = 0 then 
    dbms_scheduler.create_job(
             job_name   => jobname,
             job_type   => 'PLSQL_BLOCK',
             -- cleanup_task with task id KPDB_FUNC_ONLINE_PMOP
             job_action => 
               'declare 
                  myinterval number; 
                begin 
                  myinterval := dbms_pdb.cleanup_task(6); 
                  if myinterval <> 0 then
                    next_date := systimestamp + 
                      numtodsinterval(myinterval, ''second'');
                  end if; 
                end;',
             start_date => systimestamp + numtodsinterval(170, 'second'),
             repeat_interval => 'FREQ = HOURLY; INTERVAL = 1',
             job_class => 'SCHED$_LOG_ON_ERRORS_CLASS', 
             enabled => TRUE,
             comments => 'Cleanup after Failed PMO');
  end if;
end;
/

Rem =======================================================================
Rem Bug 23030152: drop and re-create scheduler job cleanup_online_pmo
Rem =======================================================================

Rem
Rem BEGIN RTI 19634111: make GSM_CHANGE_MESSAGE and %URITYPE local
Rem

exec dbms_pdb.convert_to_local('GSMADMIN_INTERNAL', 'GSM_CHANGE_MESSAGE', 1);
exec dbms_pdb.convert_to_local('SYS', 'FTPURITYPE', 2);
exec dbms_pdb.convert_to_local('SYS', 'HTTPURITYPE', 2);
exec dbms_pdb.convert_to_local('SYS', 'XDBURITYPE', 2);
exec dbms_pdb.convert_to_local('SYS', 'DBURITYPE', 2);
exec dbms_pdb.convert_to_local('SYS', 'URITYPE', 2);
exec dbms_pdb.convert_to_local('SYS', 'FTPURITYPE', 1);
exec dbms_pdb.convert_to_local('SYS', 'HTTPURITYPE', 1);
exec dbms_pdb.convert_to_local('SYS', 'XDBURITYPE', 1);
exec dbms_pdb.convert_to_local('SYS', 'DBURITYPE', 1);
exec dbms_pdb.convert_to_local('SYS', 'URITYPE', 1);

Rem
Rem   END RTI 19634111: make GSM_CHANGE_MESSAGE and %URITYPE local
Rem


Rem ====================================================================
Rem Begin Changes for SQL Tuning Advisor 
Rem ====================================================================
Rem 
Rem bug#16654392: drop the auto-sqltune program if already exists. 
Rem 
begin 
  -- drop program  
  dbms_scheduler.drop_program('AUTO_SQL_TUNING_PROG');

exception
  when others then
    if (sqlcode = -27476)     -- program does not exist
    then
      null;                   -- ignore it
    else
      raise;                  -- non expected errors
    end if;
end; 
/

Rem ====================================================================
Rem End Changes for SQL Tuning Advisor 
Rem ====================================================================

Rem Put ALL downgrade actions ABOVE these final actions!!!

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary to 12.1.0
Rem =========================================================================

Rem =========================================================================
Rem Downgrade dictionary to 12.1.0
Rem =========================================================================

  --
  -- Set the version to 12.1.0, not the full version.
  -- This action applies to both non-CDB and CDB and ultimately
  -- helps to support handling of a plugged in PDB in the previous version.
  --
BEGIN
   dbms_registry.downgraded('CATALOG','12.1.0');
   dbms_registry.downgraded('CATPROC','12.1.0');
END;
/



Rem *************************************************************************
Rem END f1201000.sql
Rem *************************************************************************
