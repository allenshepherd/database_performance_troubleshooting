Rem
Rem $Header: rdbms/admin/f1102000.sql /main/43 2017/04/04 09:12:44 raeburns Exp $
Rem
Rem f1102000.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      f1102000.sql - Use PL/SQL packages for downgrade from 12.1.
Rem
Rem    DESCRIPTION
Rem
Rem      This script is run from catdwgrd.sql to perform any actions
Rem      using PL/SQL packages needed to downgrade from 12.1.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/f1102000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/f1102000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       raeburns 03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem       raeburns 12/07/14 - move TSDP XDB downgrade to xrde112.sql
Rem       svivian  11/20/14 - bug 20066812: fix downgrade of spill
Rem       svivian  09/16/14 - bug 19630651: fix upgrade of spill from 11.2
Rem       ranjaysi 10/16/13 - bug16105750: fwd mrg for bug15964874, fix buffer
Rem                           view for WM$EVENT_QUEUE_TABLE
Rem       jomcdon  09/30/13 - bug 17428353: drop all cdb plans for downgrade
Rem       abrown   03/08/13 - BUG 16063508: remove logminer columns added by
Rem                           create_extended_stats
Rem       jnunezg  03/01/13 - Force stop of jobs that might be running while
Rem                           the downgrade process is on-going
Rem       cdilling 10/27/12 - call patch upgrade script
Rem       jnunezg  09/07/12 - Supress error 4043 for SCHEDULER$_LOG_DIR, object
Rem                           might not exist
Rem       traney   08/30/12 - bug 14228510: increase max number of editions
Rem       pknaggs  08/27/12 - Bug #14055347: Data Redaction downgrd to 11.2.0.4
Rem       pknaggs  08/15/12 - Bug #14499168: Drop data redaction policies.
Rem       tbhukya  07/13/12 - Modify queryable patch inventory objects
Rem       elu      05/16/12 - drop procedure lcr from eval ctx
Rem       claguna  05/16/12 - Fix unique constraint lrg 6749713
Rem       svivian  05/11/12 - Bug 13887570: SQL injection with LOGMINING
Rem                           privilege
Rem       thbaby   05/01/12 - drop cleanup jobs
Rem       hlakshma 04/06/12 - Add ILM downgrade action
Rem       sdball   03/19/12 - Add GSM
Rem       pxwong   03/19/12 - disable project 25225 and 25227
Rem       desingh  02/15/12 - add downgrade of deq hash table view
Rem       jomcdon  01/12/12 - lrg 6559821: fix Resource Manager downgrade
Rem       dgraj    10/16/11 - Project 32079: Downgrade support for TSDP
Rem       cmlim    11/03/11 - add DOWNGRADED status for catalog/catproc;
Rem                           required for major release downgrades
Rem       geadon   09/08/11 - drop pmo_deferred_gidx_maint program
Rem       evoss    08/27/11 - downgrade job resources
Rem       ddas     08/22/11 - drop SYS_AUTO_SPM_EVOLVE_TASK
Rem       rramkiss 06/27/11 - project 25230- remove new job/program types
Rem       paestrad 06/03/11 - Downgrade actions for DBMS_CREDENTIAL package
Rem       rdecker  01/11/11 - Remove package type metadata for downgrade
Rem       amullick 12/20/10 - Project 33140 downgrade path
Rem       amozes   07/01/10 - ODM downgrade for 12g
Rem       qiwang   06/13/10 - LRG 4717421: LSBY downgrade to 11.2.0.1 from
Rem                           11.2.0.2
Rem       sbasu    06/02/10 - fix APPQOS Plan
Rem       sursridh 12/28/09 - Rename materialize_deferred_segments.
Rem       gngai    09/15/09 - bug 6976775: downgrade adr
Rem       sursridh 11/10/09 - Project 31043 downgrade path.
Rem      cdilling 8/03/09   Created

Rem *************************************************************************
Rem BEGIN f1102000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release to 12.1
Rem =========================================================================

@@f1201000

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release to 12.1
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from current release to 11.2.0
Rem =========================================================================

BEGIN    
   dbms_registry.downgrading('CATALOG'); 
   dbms_registry.downgrading('CATPROC');
END;     
/

Rem=========================================================================
Rem BEGIN ADR downgrade items
Rem=========================================================================
Rem
Rem Downgrade ADR from 11.2 format to 11.1 format
Rem

begin
  sys.dbms_adr.downgrade_schema;
end;
/

Rem=========================================================================
Rem End ADR downgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Proj 31043: Deferred Segment Creation for Partitioned Objects
Rem       Materialize segments for partitioned objects on downgrade
Rem=========================================================================

DECLARE
previous_version varchar2(30);

BEGIN
 SELECT prv_version INTO previous_version FROM registry$
 WHERE  cid = 'CATPROC';

 -- Call the materialize segments procedure only if the previous version was
 -- 11.2.0.1
 IF previous_version LIKE '11.2.0.1%' THEN 

   BEGIN
       sys.dbms_space_admin.materialize_deferred_with_opt(partitioned_only=>true);
   END;

 END IF;

END;
/


Rem=========================================================================
Rem END Proj 31043: Deferred Segment Creation for Partitioned Objects
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Resource Manager downgrade items
Rem=========================================================================

Rem Disable Resource Manager plan and drop the built-in plans
alter system set resource_manager_plan='' sid='*';
exec dbms_rmin_sys.downgrade_prep(drop_all_cdb => TRUE);

Rem=========================================================================
Rem END Resource Manager downgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Logical Standby downgrade items
Rem=========================================================================
Rem
Rem lrg 7157890, bug 16063508 : Remove hidden columns from Logminer
Rem Dictionary tables that have been added by create_extended_stats.
Rem
DECLARE
  cursor ext_cur is
    select owner, table_name, to_char(extension)extension
    from dba_stat_extensions
    where droppable = 'YES' and
          owner = 'SYSTEM' and
          table_name in (select case when bitand(x.flags, 2) = 2 
                           then 'LOGMNR_'|| x.name
                           else x.name end table_name
                         from x$krvxdta x
                         where bitand(x.flags, 1) = 1);
BEGIN
  for ext in ext_cur loop
    dbms_stats.drop_extended_stats(ext.owner, ext.table_name,  ext.extension);
  end loop;
END;
/

Rem
Rem BUG 19630651
Rem Convert Logical Standby Ckpt data from 12.1 format to 11.2.0.4 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_121to11204;
end;
/

Rem LRG 4717421
Rem Convert Logical Standby Ckpt data from 11.2.0.2 format to 11.2.0.1 format
Rem
DECLARE
  previous_version varchar2(30);
BEGIN
 SELECT prv_version INTO previous_version FROM registry$
 WHERE  cid = 'CATPROC';

 IF (substr(previous_version, 1, 8) <= '11.2.0.1') THEN
   sys.dbms_logmnr_internal.agespill_11202to112;
 END IF;
END;
/

/* new LOGMINING privilege must be revoked from users */
DECLARE   
  stmt          CLOB;
  TYPE          refcurs IS REF CURSOR;
  curs          refcurs;
  name          VARCHAR2(255);
BEGIN
  stmt := 'select distinct grantee from dba_sys_privs where privilege=' ||
        '''' || 'LOGMINING' || '''';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO name;
    EXIT WHEN curs%NOTFOUND;
    EXECUTE IMMEDIATE 'REVOKE LOGMINING FROM ' || 
        DBMS_ASSERT.ENQUOTE_NAME(name,FALSE);
  END LOOP;

  stmt := 'select username from dba_streams_administrator ' ||
        ' union ' ||
        ' select username from dba_xstream_administrator ' ||
        ' where privilege_type in (' || '''' || 'CAPTURE' || '''' || ',' ||
        '''' || '*' || '''' || ')' ||
        ' union ' ||
        ' select username from dba_goldengate_privileges ' ||
        ' where privilege_type in (' || '''' || 'CAPTURE' || '''' || ',' ||
        '''' || '*' || '''' || ')';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO name;
    EXIT WHEN curs%NOTFOUND;
    EXECUTE IMMEDIATE 'GRANT SELECT ANY TRANSACTION TO ' || 
        DBMS_ASSERT.ENQUOTE_NAME(name,FALSE);
  END LOOP;

END;
/

DECLARE   
  stmt          CLOB;
  TYPE          refcurs IS REF CURSOR;
  curs          refcurs;
  owner         VARCHAR2(128);
  table_name    VARCHAR2(128);
BEGIN
  stmt := 'select owner,table_name from system.logstdby$eds_tables where ' ||
        ' state=' || '''' || 'EVOLVING' || '''';
  OPEN curs FOR stmt;
  LOOP
    FETCH curs INTO owner,table_name;
    EXIT WHEN curs%NOTFOUND;
    EXECUTE IMMEDIATE 
        'BEGIN DBMS_LOGSTDBY.EDS_EVOLVE_MANUAL(' || 
        '''' || 'FINISH' || '''' || ',' || 
        DBMS_ASSERT.ENQUOTE_LITERAL(
          REPLACE(DBMS_ASSERT.ENQUOTE_NAME(owner,FALSE),'''','''''')) ||
        ',' || 
        DBMS_ASSERT.ENQUOTE_LITERAL(
          REPLACE(DBMS_ASSERT.ENQUOTE_NAME(table_name,FALSE),'''','''''')) ||
        '); END;';
  END LOOP;
END;
/

Rem=========================================================================
Rem End Logical Standby downgrade items
Rem=========================================================================

Rem =======================================================================
Rem  Begin Changes for XStream/Streams
Rem =======================================================================

Rem Remove procedure LCR from the streams rule evaluation context
DECLARE
  vt sys.re$variable_type_list;
BEGIN
  vt := sys.re$variable_type_list(
    sys.re$variable_type('DML', 'SYS.LCR$_ROW_RECORD', 
       'SYS.DBMS_STREAMS_INTERNAL.ROW_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.ROW_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type('DDL', 'SYS.LCR$_DDL_RECORD',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type(NULL, 'SYS.ANYDATA',
       NULL,
       'SYS.DBMS_STREAMS_INTERNAL.ANYDATA_FAST_EVAL_FUNCTION'));

  dbms_rule_adm.alter_evaluation_context(
    evaluation_context_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
    variable_types=>vt);
END;
/

Rem =======================================================================
Rem  End Changes for XStream/Streams
Rem =======================================================================

Rem =====================
Rem Begin ODM changes
Rem =====================

Rem  ODM model upgrades
exec dmp_sys.downgrade_models('12.0.0');
/

Rem =====================
Rem End ODM changes
Rem =====================

Rem =================================
Rem Begin Purge log to fix unique contraint lrg
Rem on SYS.SCHEDULER$_INSTANCE_PK 
Rem =================================
begin
dbms_scheduler.purge_log();
end;
/
Rem =================================
Rem End of fix
Rem =================================

Rem ==================================
Rem Begin enabled/disabled credentials support
Rem ==================================

DECLARE
  cursor creds is
    select  owner, credential_name from dba_scheduler_credentials
      where username is NULL;
BEGIN
  FOR cred_info IN creds
  LOOP
    dbms_scheduler.drop_credential('"'||cred_info. owner||'"."'||
                                   cred_info.credential_name||'"', true);
  END LOOP;
END;
/

Rem ==================================
Rem End enabled/disabled credentials support
Rem ==================================


Rem ==================================
Rem =====================
Rem Begin Project 33140 changes
Rem =====================


exec DBMS_SECUREFILE_LOG_ADMIN.destroy_all_logs;
/

Rem =====================
Rem End Project 33140 changes
Rem =====================

Rem =====================
Rem BEGIN scheduler new job types changes
Rem =====================

DECLARE
  CURSOR new_type_jobs IS
    SELECT owner, job_name from dba_scheduler_jobs
    WHERE job_type IN ('EXTERNAL_SCRIPT', 'SQL_SCRIPT', 'BACKUP_SCRIPT')
      AND job_subname IS NULL;
BEGIN
  FOR drop_this IN new_type_jobs LOOP
    dbms_scheduler.disable('"'||drop_this.owner || '"."' ||
                            drop_this.job_name || '"', TRUE);
    BEGIN
      dbms_scheduler.stop_job('"'||drop_this.owner || '"."' ||
                              drop_this.job_name || '"', TRUE);
    EXCEPTION
      WHEN others THEN
      IF sqlcode = -27366 THEN
        NULL; --Supress job not running error
      ELSE
        raise;
      END IF;
    END;
    dbms_scheduler.drop_job('"'||drop_this.owner || '"."' ||
                            drop_this.job_name || '"', TRUE);
  END LOOP;
END;
/

DECLARE
  CURSOR new_type_programs IS
    SELECT owner, program_name from dba_scheduler_programs
    WHERE program_type IN ('EXTERNAL_SCRIPT', 'SQL_SCRIPT', 'BACKUP_SCRIPT');
BEGIN
  FOR drop_this IN new_type_programs LOOP
    dbms_scheduler.drop_program('"'||drop_this.owner || '"."' ||
                            drop_this.program_name || '"', TRUE);
  END LOOP;
END;
/

BEGIN
  execute immediate
    'drop directory SCHEDULER$_LOG_DIR';
EXCEPTION
  when others then
    if (sqlcode = -4043) then
      --object is only created if needed, so it might not exist on the DB
      null;
    else
      raise;
    end if;
END;
/

Rem =====================
Rem END scheduler new job types changes
Rem =====================

Rem ====================================
Rem BEGIN SQL Plan Management Evolve Advisor changes
Rem ====================================

--
-- Drop the new auto task that was created during upgrade to 12g.  We add
-- a little extra code just to be careful that we are really dropping the
-- right task.
--
-- Any auto-evolved plans will survive the downgrade.
--
declare
  tname wri$_adv_tasks.name%TYPE;
begin
  select max(name)
  into   tname
  from   wri$_adv_tasks t
  where  t.name = prvt_advisor.TASK_RESERVED_NAME_ASPME and
         t.owner_name = 'SYS' and
         bitand(t.property, prvt_advisor.TASK_PROP_SYSTEMTASK) <> 0;

  if (tname is not null) then
    dbms_spm.drop_evolve_task(tname);
  end if;
end;
/

Rem ====================================
Rem END SQL Plan Management Evolve Advisor changes
Rem ====================================

Rem =====================
Rem BEGIN new scheduler job for partition maintenance index cleanup
Rem =====================

execute dbms_scheduler.disable('pmo_deferred_gidx_maint_job', TRUE);
BEGIN
  dbms_scheduler.stop_job('pmo_deferred_gidx_maint_job', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/
execute dbms_scheduler.drop_job('pmo_deferred_gidx_maint_job', TRUE);
execute dbms_scheduler.drop_program('pmo_deferred_gidx_maint');

Rem =====================
Rem END new scheduler job for partition maintenance index cleanup
Rem =====================

Rem =====================
Rem BEGIN scheduler jobs for cleanup 

execute dbms_scheduler.disable('CLEANUP_NON_EXIST_OBJ', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_NON_EXIST_OBJ', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/
execute dbms_scheduler.drop_job('CLEANUP_NON_EXIST_OBJ', TRUE);

execute dbms_scheduler.disable('CLEANUP_ONLINE_IND_BUILD', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_ONLINE_IND_BUILD', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/
execute dbms_scheduler.drop_job('CLEANUP_ONLINE_IND_BUILD', TRUE);

execute dbms_scheduler.disable('CLEANUP_TAB_IOT_PMO', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TAB_IOT_PMO', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TAB_IOT_PMO', TRUE);

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_TYPE', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_TYPE', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_TYPE', TRUE);

execute dbms_scheduler.disable('CLEANUP_TRANSIENT_PKG', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_TRANSIENT_PKG', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_TRANSIENT_PKG', TRUE);

execute dbms_scheduler.disable('CLEANUP_ONLINE_PMO', TRUE);
BEGIN
  dbms_scheduler.stop_job('CLEANUP_ONLINE_PMO', TRUE);
EXCEPTION
  WHEN others THEN
  IF sqlcode = -27366 THEN
    NULL; --Supress job not running error
  ELSE
    raise;
  END IF;
END;
/

execute dbms_scheduler.drop_job('CLEANUP_ONLINE_PMO', TRUE);

Rem END scheduler jobs for cleanup
Rem =====================

Rem ================================================
Rem BEGIN Data Redaction changes for 12.1 downgrade.
Rem ================================================

Rem Data Redaction (RADM, Real-time Application-controlled Data Masking)
Rem is 12c Advanced Security Option project 32006 (proj 44284 in 11.2.0.4).
Rem
Rem Need to use the following PL/SQL loop to drop all Data Redaction policies,
Rem otherwise the "high" bits of the col$.property flags would remain behind,
Rem causing a mess in the lower release when any such column was referenced,
Rem since in the lower release the KGL callback support for reading in any
Rem such 64-bit col$.property flag values doesn't exist.  Only the 11.2.0.4
Rem release is having support for the 64-bit col$.property flag backported
Rem to it.  The col$.property flags are used by Data Redaction to speed up
Rem the search for redacted columns within the SQL during the Semantic
Rem Analysis hard-parse phase, to know where to insert MASK operators.

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version
    INTO previous_version
    FROM registry$
   WHERE cid = 'CATPROC';

  --
  -- Bug #14055347: Handle Data Redaction downgrade to 11.2.0.4, now that
  -- Project 44284 (Data Redaction) is present in the 11.2.0.4 label.
  --
  IF (substr(previous_version, 1, 8) < '11.2.0.4') THEN
    --
    -- If downgrading to a version prior to (but not including) 11.2.0.4,
    -- then drop all of the Data Redaction policies.
    --
    FOR data_redaction_policy IN
      (SELECT object_owner schema_name,
              object_name  object_name,
              policy_name  policy_name
         FROM redaction_policies)
    LOOP
      DBMS_REDACT.DROP_POLICY(
        OBJECT_SCHEMA => data_redaction_policy.schema_name
       ,OBJECT_NAME   => data_redaction_policy.object_name
       ,POLICY_NAME   => data_redaction_policy.policy_name);
    END LOOP;
  END IF;

  --
  -- Note: If downgrading to version 11.2.0.4, we do NOT
  -- drop any of the existing Data Redaction policies.
  --
END;
/

Rem ==============================================
Rem END Data Redaction changes for 12.1 downgrade.
Rem ==============================================

Rem *************************************************************************
Rem BEGIN changes for downgrading Queryable patch inventory objects
Rem *************************************************************************

-- DROP Job
DECLARE
  inst_tab dbms_utility.instance_table;
  inst_cnt NUMBER;
  jobname varchar2(128)  := NULL;
BEGIN

  -- Check if it is a RAC env or not
  IF dbms_utility.is_cluster_database THEN
    dbms_utility.active_instances(inst_tab, inst_cnt);

    -- Drop job on all the active nodes in RAC
    FOR i in inst_tab.FIRST..inst_tab.LAST LOOP
      jobname := 'Load_opatch_inventory_' || inst_tab(i).inst_number;


      dbms_scheduler.disable(jobname, TRUE);
      BEGIN
        dbms_scheduler.stop_job(jobname, TRUE);
      EXCEPTION
        WHEN others THEN
        IF sqlcode = -27366 THEN
          NULL; --Supress job not running error
        ELSE
          raise;
        END IF;
      END;
      DBMS_SCHEDULER.DROP_JOB (job_name        => jobname,
                               force           => TRUE);

    END LOOP;
  END IF;

  dbms_scheduler.disable('Load_opatch_inventory', TRUE);
  BEGIN
    dbms_scheduler.stop_job('Load_opatch_inventory', TRUE);
  EXCEPTION
    WHEN others THEN
    IF sqlcode = -27366 THEN
      NULL; --Supress job not running error
    ELSE
      raise;
    END IF;
  END;
  -- Create job on current oracle home
  DBMS_SCHEDULER.DROP_JOB (job_name        => 'Load_opatch_inventory',
                           force           => TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END;
/
show errors

Rem *************************************************************************
Rem END changes for downgrading Queryable patch inventory objects
Rem *************************************************************************

Rem =========================================================================
Rem Begin downgrading GSM
Rem =========================================================================

-------------
-- Drop Queue
-------------

BEGIN
   dbms_aqadm.stop_queue('gsmadmin_internal.change_log_queue');
EXCEPTION
  WHEN others THEN
  IF sqlcode = -24010 THEN NULL;
       -- suppress error for non-existent queue
  ELSE raise;
  END IF;
END;
/

BEGIN
   dbms_aqadm.drop_queue('gsmadmin_internal.change_log_queue');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24010 THEN NULL;
       -- suppress error for non-existent queue
  ELSE raise;
  END IF;
END;
/

BEGIN
   dbms_aqadm.drop_queue_table('gsmadmin_internal.change_log_queue_table', TRUE);
EXCEPTION
WHEN others THEN
  IF sqlcode = -24002 THEN NULL;
       -- suppress error for non-existent queue table
  ELSE raise;
  END IF;
END;
/
show errors

Rem ==========================================================================
Rem End downgrading GSM
Rem ==========================================================================

Rem *************************************************************************
Rem BEGIN Downgrade ILM
Rem *************************************************************************

BEGIN
DBMS_AQ.UNREGISTER (
          SYS.AQ$_REG_INFO_LIST(
             SYS.AQ$_REG_INFO(
               'SYS.SCHEDULER$_EVENT_QUEUE:ILM_AGENT',
                DBMS_AQ.NAMESPACE_AQ,
                'plsql://SYS.PRVT_ILM.ILM_CALLBACK',
                HEXTORAW('FF')
                )
             ),
         1
         );
END;
/

DECLARE
subs                  SYS.AQ$_AGENT;
BEGIN
subs := SYS.AQ$_AGENT('ILM_AGENT', NULL, NULL);
DBMS_AQADM.REMOVE_SUBSCRIBER('SYS.SCHEDULER$_EVENT_QUEUE',subs );
END;
/

Rem *************************************************************************
Rem END Downgrade ILM
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 14228510: decrease max number of editions
Rem *************************************************************************

-- Downgrading from blob
-- There can't be more than 2000 editions unless compatibilty >= 12, in which
-- case we won't be downgrading, so it will fit in raw(2000)
create table edition$mig (obj#, p_obj#, flags, code, audit$, spare1, spare2) as 
  select obj#, p_obj#, flags, hextoraw('01'), audit$, spare1, spare2 
  from edition$;
alter table edition$mig modify code raw(2000);

declare
  coderaw  raw(2000);
  length   number;
  cursor   edcur is select obj#, code from edition$;
begin
  for ed in edcur
  loop
    length := dbms_lob.getlength(ed.code);
    dbms_lob.read(ed.code, length, 1, coderaw);
    update edition$mig set code = coderaw where obj# = ed.obj#;
  end loop;
  commit;
end;
/
alter table edition$ rename to edition$old;
alter table edition$mig rename to edition$;
drop table edition$old;

Rem *************************************************************************
Rem End Bug 14228510: decrease max number of editions
Rem *************************************************************************

Rem BEGIN Advanced Queuing related downgrade changes
Rem =============================================================================
Rem bug12860875:drop _L view and recreate downgraded base view for 11.2 
Rem qtables multiconsumer  
Rem =============================================================================
declare
   cursor qt_cur is select schema, name, flags from system.aq$_queue_tables;
begin
    for qt in qt_cur loop
      if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags) AND 
          sys.dbms_aqadm_sys.newq_10_1(qt.flags)) then
        begin
          --sys.dbms_prvtaqim.drop_dqlog_view(qt.schema, qt.name);

          /* bug15964874/16105750: Recreate buffer view for WM$EVENT_QUEUE_TABLE */
          if (qt.name='WM$EVENT_QUEUE_TABLE') then
            sys.dbms_aqadm_sys.drop_buffer_view(qt.schema, qt.name);
            sys.dbms_aqadm_sys.create_buffer_view(qt.schema, qt.name, TRUE);
          end if;

          sys.dbms_prvtaqim.create_base_view11_2_0(qt.schema, qt.name, qt.flags);

        exception
          when others then
            dbms_system.ksdwrt(dbms_system.alert_file,
                               'f1102000.sql: create _L view or recreate base' ||
                               ' view failed for ' || qt.schema || '.' || qt.name);
        end;
      end if;
    end loop;
end;
/

Rem *************************************************************************
Rem END Advanced Queuing related downgrade changes
Rem *************************************************************************



Rem Put ALL downgrade actions ABOVE these final actions!!!

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from current release to 11.2.0
Rem =========================================================================

Rem update status in component registry (last)

BEGIN
   dbms_registry.downgraded('CATALOG','11.2.0');
   dbms_registry.downgraded('CATPROC','11.2.0');
END;
/

Rem *************************************************************************
Rem END f1102000.sql
Rem *************************************************************************

