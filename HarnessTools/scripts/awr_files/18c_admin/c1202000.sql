Rem
Rem $Header: rdbms/admin/c1202000.sql /st_rdbms_18.3.0.0.0dbru/1 2018/06/21 15:26:45 pxwong Exp $
Rem
Rem c1202000.sql
Rem
Rem Copyright (c) 2012, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1202000.sql - Script to apply current release upgrade actions 
Rem
Rem    DESCRIPTION
Rem      Put any dictionary related changes here (i.e. - create, alter,
Rem      update,...).  If you must upgrade using PL/SQL packages,
Rem      put the PL/SQL block in a1202000.sql since catalog.sql and
Rem      catproc.sql will be run before "a" script is invoked.
Rem
Rem      This script is called from catupstr.sql
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/c1202000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/c1202000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pxwong      06/20/18 - RTI 21183805 /Bug 28188330 
Rem    gravipat    12/01/17 - XbranchMerge gravipat_bug-27131802 from main
Rem    gravipat    11/16/17 - Bug 27131802: Add snapshot interval to container
Rem    thbaby      11/13/17 - Bug 27083755: create sensitive_fixed$
Rem    raeburns    11/10/17 - Bug 27103422: Extend banner_full to 128
Rem    pyam        11/09/17 - Bug 27094456: ensure default_pwd$ is valid
Rem    kmorfoni    11/09/17 - Bug 27020490: Add snap_id in PK of WRH$_UNDOSTAT
Rem    pyam        11/04/17 - 26894818: populate fed$binds.appid#
Rem    hlakshma    10/30/17 - Bug 27119186: Set flag in heat_map_stat$
Rem    amunnoli    10/22/17 - Bug 26965236:Table is marked with sensitive cols
Rem    quotran     10/19/17 - Add tablespace_name to wrm$_wr_control
Rem    pjulsaks    09/26/17 - Bug 21563855: add flag to fed$app$status
Rem    amunnoli    09/20/17 - Bug 26389197,26515990: update objauth$
Rem    pyam        09/07/17 - RTI 20595342: update 26623937 fix
Rem    rajarsel    09/06/17 - Bug 26634477: Fix mismatched dict objects after
Rem                           upgrade
Rem    sramakri    09/01/17 - Bugs 26634870, 26634591, 26635035 -
                              mv_refresh_stats and syncref_* changes
Rem    msabesan    08/31/17 - Bug 26712379: add columns in 
Rem                           wri$_adv_sqlt_plan_stats
Rem    raeburns    08/30/17 - Bug 26255427: Add new registry$ columns for FULL
Rem                           RU version
Rem    shvmalik    08/29/17 - #26671620: drop dbms_optim_bundle package
Rem    youyang     08/28/17 - bug26634962:add not null on run_seq# for
Rem                           priv_unused$
Rem    ddas        08/24/17 - Bug 26634569: set sql_handle to varchar2(30)
Rem    rankalik    08/16/17 - Bug 26535638: qualify column names
Rem    kmorfoni    08/16/17 - Add begin_interval_time_tz, end_interval_time_tz
Rem                           to WRM$_SNAPSHOT
Rem    pyam        08/16/17 - Bug 26623937: drop residual temp objects
Rem    fvallin     08/14/17 - Bug 26370269: Drop dbms_registry_server_package
Rem    prshanth    08/14/17 - Bug 26620066: fix default value related to
Rem                           con_uid column of lockdown_prof$
Rem    yuyzhang    08/10/17 - #(26150401): grant insert on finalhist$ to public
Rem    molagapp    08/10/17 - Bug 26595855: rename con_id -> unplug_con_id
Rem    dmaniyan    08/04/17 - Bug 26546365: Add max_chunk_num to table_family
Rem    jcarey      08/03/17 - Bug 26568895 - Fix quoting
Rem    atomar      08/01/17 - bug 26259599 revoke select priv and grant read to
Rem                           SYS.USER_QUEUE_SCHEDULES
Rem    tojhuan     07/21/17 - Bug 25515456: un-desupport SQLJ types
Rem    jemaldon    07/18/17 - Bug 26351822: add unique key to im_domain$
Rem    sramakri    07/17/17 - bug-26432273: drop CDC objects introduced
Rem                           before 10.1
Rem    quotran     07/14/17 - Bug 26526331: Support AWR incremental flushing
Rem    almurphy    07/13/17 - Bug 26437747: HCS dynamic_all_cache default as 0
Rem    tojhuan     07/11/17 - RTI 20257878: drop SYS.OWNER_MIGRATE_UPDATE_TDO
Rem                           and SYS.OWNER_MIGRATE_UPDATE_HASHCODE which might
Rem                           be backported to prior-12.1.0.2 releases
Rem    harnesin    06/28/17 - Bug 25871643: Future pdb registration support
Rem    dmaniyan    06/27/17 - Bug 25443435: Add columns num_chunks, consistent 
Rem                           to global_table
Rem    amunnoli    06/26/17 - Lrg 20390114: Fix container ID of CDB$ROOT
Rem                           Lrg 20400585: DV unified audit trail processing
Rem                           is moved to dvu122.sql
Rem    yanrzhan    06/20/17 - Bug 25598902: skip_obj
Rem    jingzhen    06/19/17 - RTI 20393192: add kccd2x_ced_scn to X$KCCDI2
Rem    prakumar    06/16/17 - Bug 26289288: create table ptt_feature$
Rem    alestrel    06/12/17 - Bug 25992935. Revoking execute privilege on
Rem                           dbms_isched from gsmadmin_internal
Rem    amunnoli    06/12/17 - Bug 25245797: drop SYS owned Unified Audit Trail
Rem                           view and DBMS_AUDIT_MGMT package
Rem    tojhuan     06/09/17 - Bug 24623721: server-side SQLJ is desupported
Rem    raeburns    05/30/17 - RTI 20258949: Drop 12.1 objects
Rem    jnunezg     05/18/17 - Bug 26101140: Drop type SYS.STEP_LIST
Rem    nbenadja    05/05/17 - Bug 22145819 : Add the column ddl_intcode.
Rem    prshanth    05/05/17 - Bug 26007816: update usertyp$ for existing rows
Rem    atomar      05/01/17 - bug 25956410 clear ruleset compiled data
Rem    jcarey      04/26/17 - revoke select on aw tables
Rem    yanxie      04/19/17 - bug 22666352: change the type of mlog$.partdobj#
Rem    anbhasu     05/04/17 - Bug 23012504: REMOVE EXEMPT DML/DDL REDACTION
Rem                           POLICY
Rem    rankalik    04/27/17 - Bug25536381: Adding connection_tests$
Rem    jcarey      04/26/17 - revoke select on aw tables
Rem    quotran     04/21/17 - Add im_db_block_changes_total[delta] to 
Rem                           wrh$_seg_stat
Rem    sramakri    04/21/17 - lrg-20245020: drop DBMS_SUMADV_LIB
Rem    pknaggs     04/21/17 - Bug #24714096: shorten PE_NAME for ORA-01450.
Rem    kmorfoni    04/18/17 - Add open_time_tz to WRM$_PDB_IN_SNAP
Rem    saratho     04/13/17 - Bug 25816781: add column to
Rem                           gsmadmin_internal.cloud table
Rem    cwidodo     04/13/17 - #(25719642): drop outln_edit_pkg and its synonyms
Rem    dmaniyan    04/12/17 - Bug 25476616: Add child_obj# to ts_set_table
Rem    abrown      04/12/17 - bug 25802176 : 128 byte PDB_NAME
Rem    ajbatta     04/12/17 - Bug 25742058
Rem    pyam        04/11/17 - Bug 25879441: make default_pwd$ data link
Rem    atomar      04/10/17 - bug 25861721 drop type shard_meta
Rem    prshanth    04/08/17 - Bug 25861941: fix NOT NULL constraint issue
Rem                           related con_uid column of lockdown_prof$
Rem    sajaureg    04/06/17 - Bug 22550874: I/O calib tool more informative
Rem    hlakshma    04/04/17 - Add columns to AIM dictionary tables
Rem                           (bug-25825879)
Rem    kmorfoni    04/04/17 - Add snap_id in wrm$_pdb_instance
Rem    sdball      03/31/17 - Add failover_restore to service
Rem    kmorfoni    03/24/17 - Add startup_time_tz, open_time_tz to
Rem                           wrm$_pdb_instance
Rem    jcarey      03/24/17 - bug 25254434: aw lockdown
Rem    quotran     03/21/17 - Bug 24845711: Add IM-stats to WRH$_SEG_STAT
Rem    snetrava    03/13/17 - Adding Text Datastore Access System Privilege
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    pyam        03/02/17 - Bug 25654201: make metaaudit$ data link
Rem    sankejai    02/28/17 - Bug 25600289: add key for credential
Rem    alestrel    02/07/17 - Bug 25385095. Revoking select on
Rem                           dba_scheduler_remote_databases from public.
Rem    hlakshma    02/06/17 - Remove incorrect upgrade action (bug-25507334)
Rem    rthatte     02/06/17 - Bug 25406176: alter AUDSYS to no authentication
Rem                           clause
Rem    anupkk      02/02/17 - Proj# 67576: Add ALTER DATABASE DICTIONARY to
Rem                           AUDIT POLICY ORA_SECURECONFIG
Rem    siyzhang    02/02/17 - Bug 25394846: add column to lockdown_prof$
Rem    tchorma     01/30/17 - Proj 47075: Identity column support for logminer
Rem    agsaha      01/24/17 - Bug 24506257 : Add PK-FK and unique key
Rem                           constraints in im_domain$ and im_joingroup$
Rem                           tables
Rem    sfeinste    01/27/17 - Proj 70791: add dyn_all_cache to
Rem                           hcs_analytic_view$
Rem    mdombros    01/27/17 - Project 70791 MD Caching new SYS privileges
Rem    victlope    01/25/17 - Proj 70435: add columns to wri$_adv_executions
Rem    prshanth    01/22/17 - PROJ 70729: alter columns in lockdown_prof$
Rem    quotran     01/20/17 - Bug 18204711: Add obsolete_count into
Rem                           wrh$_sqlstat
REM    jaeblee     01/19/17 - Bug 25033818: add tenant_id to container$
Rem    kishykum    01/17/17 - proj 70507: add pq_timeout_action
Rem    raeburns    01/12/17 - Bug 25376213: Drop evolved ODCIColInfoList2
Rem    hlakshma    01/10/17 - Add column to table sys.ado_imtasks$ (Project
Rem                           68505)
Rem    shvmalik    01/10/17 - #25035608: drop FCP related objects
Rem    saibodap    01/09/17 - Bug 25113868: changes to upgrade
Rem    gravipat    12/23/16 - Bug 21902883: Add pdb_snapshot$
Rem    ffeli       12/21/16 - add algorithm registration upgrade for R
Rem                           extensibility
Rem    sramakri    01/05/17 - lrg-19980009: drop DBMS_STREAMS_CDC_ADM
Rem    akanagra    01/03/17 - Bug 25179268: modify aq$_schedules_primary on
Rem                           upgrade
Rem    tianlli     12/14/16 - bug 25177461: change the width of 
Rem                           proxy_remote$.remote_srvc
Rem    yakagi      12/08/16 - bug 23756361: add Segments by GC Remote Grants
Rem                           section
Rem    jingzhen    12/05/16 - proj 60642: add column for preplugin tables
Rem                           RPP$X$KCCDI2 and ROPP$X$KCCDI2
Rem    dvoss       11/28/16 - bug 21825090: remove LOGMNR_INTEGRATED_SPILL$
Rem    jhartsin    11/18/16 - bug 25043391: remove mv_name from hcs_av_lvlgrp$
Rem    cgervasi    11/16/16 - bug24952170: wrh$_cell_db add is_current_src_db
Rem                           flag
Rem    wanma       11/15/16 - Bug 24826690: drop "segdict" views                  
Rem    dvoss       11/15/16 - bug 5703311: new logminer indexes and column
Rem    jjye        11/15/16 - bug 21571874 add job_name to rgroup$
Rem    sdball      11/02/16 - Update Shard schema to support PDBs
Rem    cgervasi    10/06/16 - bug24748479: fix wrh_asm_diskgroup_stat state
Rem                           column
Rem    yuli        09/21/16 - bug 19798066: add columns for preplugin tables
Rem    sramakri    09/01/16 - Remove CDC from 12.2
Rem    almurphy    09/13/16 - add ref_distinct to sys.hcs_av_dim$
Rem    cgervasi    09/01/16 - bug24575927: add columns num_failgroup, state to
Rem                           wrh$_asm_diskgroup_stat
Rem    sdball      08/12/16 - Remove integrity constraint from
Rem                           gsmadmin_internal.cloud
Rem    jjanosik    07/26/16 - bug 18083463 - create metaaudit$
Rem    welin       06/02/16 - Created
Rem

Rem *************************************************************************
Rem BEGIN c1202000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================
Rem =========================================================================
Rem BEGIN GDS/Sharding  changes for  12.2.0.2
Rem =========================================================================
-----------------------------------------------------------------------------
-- changes to table CLOUD
-----------------------------------------------------------------------------
-- remove ref constraint to gsm (RTI 19633236)
DECLARE
   cons_name   varchar2(128);
BEGIN
   select oc.name INTO cons_name
      from sys.con$ oc, sys.obj$ o, sys.cdef$ c, user$ u
      where c.obj# = o.obj# and oc.con# = c.con#
      and c.type# = 4 --ref constraint
      and u.user# = o.owner#
      and o.name='CLOUD' and u.name='GSMADMIN_INTERNAL';
   execute immediate 
         'alter table gsmadmin_internal.cloud 
            drop constraint ' || dbms_assert.enquote_name(cons_name);
-- ignore no constraint
EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;
/

ALTER TABLE gsmadmin_internal.cloud ADD
    database_flags     CHAR(1)       DEFAULT NULL
/
-- on catalog set this column value to 'C', on shard insert a row with 'S'
DECLARE 
   is_cat            NUMBER;
   loc_cloud_name    VARCHAR2(128);
   loc_deploy_state  NUMBER;
BEGIN
   -- gsmadmin_internal.cloud table doesn't exist before 12.1.0.1
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM gsmadmin_internal.cloud' INTO is_cat;
   IF is_cat > 0 THEN
      EXECUTE IMMEDIATE 'UPDATE gsmadmin_internal.cloud SET database_flags = ''C''';
      COMMIT;
   ELSE
      EXECUTE IMMEDIATE
         'SELECT value FROM sys.v_$parameter2 WHERE name=''_gws_deployed'''
         INTO loc_deploy_state;
      -- this is a shard
      IF loc_deploy_state IS NOT NULL THEN
         EXECUTE IMMEDIATE 'SELECT value FROM sys.v_$parameter2 WHERE name=''_cloud_name'''
            INTO loc_cloud_name;
         IF loc_cloud_name IS NOT NULL THEN
            EXECUTE IMMEDIATE
               'INSERT INTO gsmadmin_internal.cloud(name, deploy_state, database_flags)
               VALUES (:1, :2, ''S'')' USING loc_cloud_name, loc_deploy_state;
               COMMIT;
         END IF;
      END IF;
   END IF;
EXCEPTION 
   WHEN NO_DATA_FOUND THEN NULL;
   WHEN OTHERS THEN
      IF (SQLCODE = -942) THEN NULL;
      END IF;
END;
/

-------------------------------------------------------------------------------
-- changes to table DATABASE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.database ADD
    container              VARCHAR2(128)   DEFAULT NULL
/

-------------------------------------------------------------------------------
-- changes to table SERVICE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.service ADD
    failover_restore        VARCHAR2(64) DEFAULT NULL
/

-------------------------------------------------------------------------------
-- changes to table TS_SET_TABLE
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.ts_set_table ADD
    child_obj#             NUMBER          DEFAULT NULL
/

ALTER TABLE SYS.ddl_requests ADD
    ddl_intcode             NUMBER DEFAULT NULL
/

-------------------------------------------------------------------------------
-- changes to table GLOBAL_TABLE
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.global_table ADD
    (NUM_CHUNKS            NUMBER          DEFAULT NULL,
     CONSISTENT            NUMBER(1)       DEFAULT NULL)     
/

-------------------------------------------------------------------------------
-- changes to table TABLE_FAMILY
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.table_family ADD
    max_chunk_num             NUMBER          DEFAULT 0
/

Rem =========================================================================
Rem END GDS/Sharding  changes for  12.2.0.2
Rem =========================================================================
Rem *************************************************************************
Rem BEGIN BUG 18083463 create metaaudit$
Rem *************************************************************************
create table metaaudit$
sharing=data
(
  version  varchar2(20), /* the version number in 'aa.bb.cc.dd.ee' format */
  option#  number        /* the audit option number from */
                         /* STMT_AUDIT_OPTION_MAP */
)
/

create index i_metaaudit_version$ on metaaudit$(version)
/

Rem *************************************************************************
Rem END BUG 18083463 create metaaudit$
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 22550874 (add a new column)
Rem *************************************************************************
alter table resource_io_calibrate$ add (additional_info varchar2(1024));
Rem *************************************************************************
Rem END BUG 22550874
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN HCS Changes for 12.2
Rem =========================================================================
-- Bug 24361734: add column for one-up mappings
ALTER TABLE sys.hcs_av_dim$ ADD ref_distinct NUMBER(1) DEFAULT 0 NOT NULL
/

-- Bug 25043391: remove unused mv_name column
begin
  execute immediate 'ALTER TABLE sys.hcs_av_lvlgrp$ DROP COLUMN mv_name';
exception when others then
  if sqlcode = -904 then null; 
  else raise;
  end if;
end;
/

-- Proj 70791: add dyn_all_cache to hcs_analytic_view$
-- Note that the default value of the column is 0
alter table sys.hcs_analytic_view$
  add dyn_all_cache number(1) default 0 not null;
create table sys.av_dual (c varchar2(1));
insert into sys.av_dual values (null);
grant read on sys.av_dual to public;

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
         values (-411, 'READ ANY ANALYTIC VIEW CACHE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
         values (-412, 'WRITE ANY ANALYTIC VIEW CACHE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
         values (411, 'READ ANY ANALYTIC VIEW CACHE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
         values (412, 'WRITE ANY ANALYTIC VIEW CACHE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem =========================================================================
Rem END HCS Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN CONTEXT Changes
Rem =========================================================================

BEGIN
insert into SYSTEM_PRIVILEGE_MAP values (-414, 'TEXT DATASTORE ACCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
insert into STMT_AUDIT_OPTION_MAP values (414, 'TEXT DATASTORE ACCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/


Rem =========================================================================
Rem END CONTEXT Changes
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN AWR changes
Rem *************************************************************************

-- bug24575927
alter table WRH$_ASM_DISKGROUP_STAT add (
  num_failgroup number       default null,
  state         varchar2(32) default null);

-- bug24952170
alter table WRH$_CELL_DB add (is_current_src_db number default null);

-- bug 18204711
alter table WRH$_SQLSTAT add (obsolete_count number default 0);

-- bug 23756361, 24845711
alter table WRH$_SEG_STAT add (
  gc_remote_grants_total                number
 ,gc_remote_grants_delta                number
 ,im_scans_total                        number default 0
 ,im_scans_delta                        number default 0
 ,populate_cus_total                    number default 0
 ,populate_cus_delta                    number default 0
 ,repopulate_cus_total                  number default 0 
 ,repopulate_cus_delta                  number default 0
 ,im_db_block_changes_total             number default 0
 ,im_db_block_changes_delta             number default 0
);

-- bug 26526331
alter table WRM$_WR_CONTROL add (
  mrct_snap_step_tm      number default 0
 ,mrct_snap_step_id      number default 0
 ,tablespace_name        varchar2(128));

-- snap_error
alter table WRM$_SNAP_ERROR drop primary key;

alter table WRM$_SNAP_ERROR add (
  step_id                number  default 0 not null);

alter table WRM$_SNAP_ERROR 
  add constraint WRM$_SNAP_ERROR_PK 
  primary key (dbid, snap_id, instance_number, table_name, step_id)
  using index tablespace SYSAUX;

-- snapshot details
drop index WRM$_SNAPSHOT_DETAILS_INDEX;

alter table WRM$_SNAPSHOT_DETAILS add (
  step_id                number  default 0 not null);

alter table WRM$_PDB_INSTANCE add (
  snap_id         number,
  startup_time_tz timestamp(3) with time zone,
  open_time_tz    timestamp(3) with time zone);

alter table WRM$_DATABASE_INSTANCE add (
  startup_time_tz timestamp(3) with time zone);

alter table WRM$_PDB_IN_SNAP add (open_time_tz timestamp(3) with time zone);

alter table WRM$_SNAPSHOT add (
  begin_interval_time_tz timestamp(3) with time zone,
  end_interval_time_tz   timestamp(3) with time zone);

-- Add snap_id in the PK of WRH$_UNDOSTAT
alter table WRH$_UNDOSTAT drop primary key;

alter table WRH$_UNDOSTAT 
  add constraint WRH$_UNDOSTAT_PK
  primary key (begin_time, end_time, dbid, instance_number, con_dbid, snap_id)
  using index tablespace SYSAUX;

Rem *************************************************************************
Rem END AWR changes
Rem *************************************************************************

Rem =======================================================================
Rem  Changes for Database Workload Capture and Replay
@@c1202000_wrr.sql
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN project 60642 changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCDI2 add (DI2PREVCYCLEDFHCKPSCN VARCHAR2(20));
alter table SYS.ROPP$X$KCCDI2 add (DI2PREVCYCLEDFHCKPSCN VARCHAR2(20));

Rem *************************************************************************
Rem END project 60642 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 20393192 changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCDI2 add (DI2_CED_SCN VARCHAR2(20));
alter table SYS.ROPP$X$KCCDI2 add (DI2_CED_SCN VARCHAR2(20));

Rem *************************************************************************
Rem END project 20393192 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Preplugin changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCPDB add (PDBCRCVBSCN         VARCHAR2(20),
                                  PDBRDB              NUMBER,
                                  PDBCCID_LOWER       NUMBER,
                                  PDBCCID_UPPER       NUMBER,
                                  PDBPREV_CCID_LOWER  NUMBER,
                                  PDBPREV_CCID_UPPER  NUMBER,
                                  PDBMIN_ACTSCN       VARCHAR2(20),
                                  PDBSCAN_FINSCN      VARCHAR2(20),
                                  PDBMA_RLS           VARCHAR2(20),
                                  PDBMA_RLC           NUMBER);

alter table SYS.ROPP$X$KCCPDB add (PDBCRCVBSCN         VARCHAR2(20),
                                  PDBRDB              NUMBER,
                                  PDBCCID_LOWER       NUMBER,
                                  PDBCCID_UPPER       NUMBER,
                                  PDBPREV_CCID_LOWER  NUMBER,
                                  PDBPREV_CCID_UPPER  NUMBER,
                                  PDBMIN_ACTSCN       VARCHAR2(20),
                                  PDBSCAN_FINSCN      VARCHAR2(20),
                                  PDBMA_RLS           VARCHAR2(20),
                                  PDBMA_RLC           NUMBER);


DECLARE
   TYPE names_t IS TABLE OF VARCHAR2(30);
   lnames CONSTANT names_t := names_t (
      'X$KCCDI',
      'X$KCCDI2',
      'X$KCCIC',
      'X$KCCPDB',
      'X$KCPDBINC',
      'X$KCCTS',
      'X$KCCFE',
      'X$KCCFN',
      'X$KCVDF',
      'X$KCCTF',
      'X$KCVFH',
      'X$KCVFHTMP',
      'X$KCVFHALL',
      'X$KCCRT',
      'X$KCCLE',
      'X$KCCSL',
      'X$KCCTIR',
      'X$KCCOR',
      'X$KCCLH',
      'X$KCCAL',
      'X$KCCBS',
      'X$KCCBP',
      'X$KCCBF',
      'X$KCCBL',
      'X$KCCBI',
      'X$KCCDC',
      'X$KCCPD',
      'X$KCCPA',
      'X$KCCPIC'
   );
   dup_column_name EXCEPTION;
   pragma exception_init (dup_column_name, -957);
   PROCEDURE renameConIdColumn(p_tableName IN varchar2) IS
   BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || p_tableName ||
                        ' RENAME COLUMN CON_ID TO UNPLUG_CON_ID';
   EXCEPTION
      WHEN dup_column_name THEN
         NULL;
   END renameConIdColumn;
BEGIN
   FOR n in 1..lnames.COUNT LOOP
      renameConIdColumn('SYS.RPP$'  || lnames(n));
   END LOOP;
END;
/

Rem *************************************************************************
Rem END Preplugin changes
Rem *************************************************************************

Rem =======================================================================
Rem Begin Logminer changes for 12.2.0.2
Rem =======================================================================
CREATE INDEX system.logmnr_log$_purge_idx1 ON 
        system.logmnr_log$(file_name, status)
        TABLESPACE SYSAUX LOGGING
/
CREATE INDEX system.logmnr_log$_purge_idx2 ON 
        system.logmnr_log$(session#, reset_timestamp, next_change#, status)
        TABLESPACE SYSAUX LOGGING
/
ALTER TABLE system.logmnr_session$ rename column spare2 to purge_scn;
/
ALTER TABLE system.logmnr_session$ add (spare9 number)
/
DROP TABLE system.logmnr_integrated_spill$
/
ALTER TABLE system.logmnr_filter$ add (attr7 varchar2(128))
/
ALTER TABLE system.logmnr_filter$ add (attr8 varchar2(128))
/
ALTER TABLE system.logmnr_filter$ add (attr9 varchar2(128))
/
ALTER TABLE system.logmnr_filter$ add (attr10 varchar2(128))
/
ALTER TABLE system.logmnr_filter$ add (attr11 varchar2(128));

Rem
Rem Bug 25113868 : Do not allow Logminer Fast Start clones run through
Rem                an upgrade.  Look for FSCs.  If they are fully initialized,
Rem                convert to a state such that they will not mine the
Rem                upgrade.  If they are partially initialized, revert them
Rem                to being traditional Logminer sessions.
DECLARE
  FFFFFFFF                  CONSTANT NUMBER  /* 0xFFFFFFFF */ := 4294967295;
  KRVRD_DIDFLG_NOSTOPLC     CONSTANT NUMBER  /* 0x00000001 */ := 1;
  KRVRD_DIDFLG_CURRENTLC    CONSTANT NUMBER  /* 0x00000002 */ := 2;
  KRVRD_DIDFLG_FSC_INIT     CONSTANT NUMBER  /* 0x00000010 */ := 16;
  KRVRD_DIDFLG_FSC_ON       CONSTANT NUMBER  /* 0x00000020 */ := 32;
  KRVRD_DIDFLG_FSC_HASLC    CONSTANT NUMBER  /* 0x00000040 */ := 64;
  KRVRD_DIDFLG_FSC_HADERROR CONSTANT NUMBER  /* 0x00000080 */ := 128;
BEGIN
  UPDATE SYSTEM.LOGMNR_DID$
    SET FLAGS = bitand(flags, FFFFFFFF - KRVRD_DIDFLG_NOSTOPLC
                                       - KRVRD_DIDFLG_CURRENTLC
                                       - KRVRD_DIDFLG_FSC_INIT
                                       - KRVRD_DIDFLG_FSC_ON
                                       - KRVRD_DIDFLG_FSC_HADERROR)
    WHERE BITAND(FLAGS, KRVRD_DIDFLG_FSC_INIT) <> 0 AND
          BITAND(FLAGS, KRVRD_DIDFLG_FSC_HASLC) = 0;
  UPDATE SYSTEM.LOGMNR_DID$
    SET FLAGS = (flags + KRVRD_DIDFLG_FSC_HADERROR)
    WHERE BITAND(FLAGS, KRVRD_DIDFLG_FSC_HASLC) <> 0 AND
          BITAND(FLAGS, KRVRD_DIDFLG_FSC_HADERROR) = 0;
  COMMIT;
END;
/ 


CREATE TABLE SYS.LOGMNRG_SEED2$ (
      SEED_VERSION NUMBER(22),
      GATHER_VERSION NUMBER(22),
      SCHEMANAME VARCHAR2(128),
      OBJ# NUMBER,
      OBJV# NUMBER(22),
      TABLE_NAME VARCHAR2(128),
      COL_NAME VARCHAR2(128),
      COL# NUMBER,
      INTCOL# NUMBER,
      SEGCOL# NUMBER,
      TYPE# NUMBER,
      LENGTH NUMBER,
      PRECISION# NUMBER,
      SCALE NUMBER,
      NULL$ NUMBER NOT NULL ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

CREATE TABLE SYS.LOGMNRG_IDNSEQ$
(obj#         number not null, 
 intcol#      number not null,
 seqobj#      number not null,  
 startwith    number not null )
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

-- bug 25802176 : 128 byte PDB_NAME
ALTER TABLE SYS.LOGMNRG_DICTIONARY$ MODIFY PDB_NAME VARCHAR(128)
/

Rem logminer needs a log group to track idnseq$ 
declare
  cnt number;
begin
  select count(1) into cnt
    from con$ co, cdef$ cd, obj$ o, user$ u
    where o.name = 'IDNSEQ$'
      and u.name = 'SYS'
      and co.name = 'IDNSEQ$_LOG_GRP'
      and cd.obj# = o.obj#
      and cd.con# = co.con#;
  if cnt = 0 then
    execute immediate 'alter table sys.idnseq$
                          add supplemental log group 
                          idnseq$_log_grp (obj#, intcol#, seqobj#) always';
  end if;
end;
/

create index i_idnseq2 on idnseq$(seqobj#)
/

Rem =======================================================================
Rem End Logminer changes for 12.2.0.2
Rem =======================================================================
  
Rem =======================================================================
Rem Begin XStreams changes for 12.2.0.2
Rem =======================================================================
  
-- bug 25871643: Add goldengate$_container_rules to store rules for automatic 
-- registration of PDBs.
CREATE TABLE goldengate$_container_rules
(
   rule#          number          not null,                       /* rule id */
   capture_name   varchar2 (128)  not null,                  /* capture name */
   filter_rule    varchar2 (4000) not null,                   /* filter rule */
   inclusion_rule number          default 1,           /* 0 - exclusion rule */
						       /* 1 - inclusion rule */
   escape_char    varchar2(1)     default '\',           /* escape character */
   flag           number          default 1,            /* flag for wildcard */
   spare1         number          default null,                    /* unused */
   spare2         varchar2 (2000) default null                     /* unused */
)
/

CREATE UNIQUE INDEX i_goldengate$_container_rules ON goldengate$_container_rules 
	(rule#)
/

CREATE SEQUENCE rule_id_seq$ 
                        /* Sequence for rule# in goldengate$_container_rules */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  cycle
/

Rem =======================================================================
Rem End Xstreams changes for 12.2.0.2
Rem =======================================================================

Rem =========================================================================
Rem BEGIN Bug 25035608
Rem drop FCP tables, types and package
Rem =========================================================================

drop package sys.dbms_fix_control_persistence;
drop type sys.dbms_optim_fcTabType;
drop type sys.dbms_optim_bugValObType;
drop library sys.dbms_fcp_lib;
drop directory ORA_DBMS_FCP_LOGDIR;
drop directory ORA_DBMS_FCP_ADMINDIR;
drop table sys.ora_bundle_fixcontrol_state$;
drop table sys.ora_fcp_params$;

Rem =========================================================================
Rem END Bug 25035608
Rem =========================================================================

Rem =======================================================================
Rem BEGIN Changes for IM Segment level dictionary views [G]V$IM_SEGDICT*
Rem =======================================================================

--Bug 24826690: rename "segdict" with "globaldict" for 12.2.0.2
REM [G]V$IM_SEGDICT
drop public synonym gv$im_segdict;
drop view gv_$im_segdict;
drop public synonym v$im_segdict;
drop view v_$im_segdict;

REM [G]V$IM_SEGDICT_VERSION
drop public synonym gv$im_segdict_version;
drop view gv_$im_segdict_version;
drop public synonym v$im_segdict_version;
drop view v_$im_segdict_version;

REM [G]V$IM_SEGDICT_SORTORDER
drop public synonym gv$im_segdict_sortorder;
drop view gv_$im_segdict_sortorder;
drop public synonym v$im_segdict_sortorder;
drop view v_$im_segdict_sortorder;

REM [G]V$IM_SEGDICT_PIECEMAP
drop public synonym gv$im_segdict_piecemap;
drop view gv_$im_segdict_piecemap;
drop public synonym v$im_segdict_piecemap;
drop view v_$im_segdict_piecemap;

Rem =======================================================================
Rem END Changes for IM Segment level dictionary views [G]V$IM_SEGDICT*
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN Remove CDC from 12.2
Rem *************************************************************************
DELETE FROM sys.exppkgact$
WHERE schema = 'SYS' AND package IN ('DBMS_CDC_EXPDP', 'DBMS_CDC_EXPVDP');

drop table sys.cdc_system$;
drop table sys.cdc_subscribers$;
drop table sys.cdc_subscribed_tables$;
drop table sys.cdc_subscribed_columns$;
drop table sys.cdc_change_sources$;
drop table sys.cdc_change_sets$;
drop table sys.cdc_change_tables$;
drop table sys.cdc_change_columns$;
drop table sys.cdc_propagations$;
drop table sys.cdc_propagated_sets$; 

drop sequence sys.cdc_subscribe_seq$;

drop trigger sys.cdc_alter_ctable_before;
drop trigger sys.cdc_create_ctable_after;
drop trigger sys.cdc_create_ctable_before;
drop trigger sys.cdc_drop_ctable_before;


-- drop CDC Synonyms (12)
drop public synonym dbms_cdc_isubscribe;
drop public synonym dbms_cdc_sys_ipublish;
drop public synonym dbms_cdc_ipublish;
drop public synonym dbms_cdc_expdp;
drop public synonym dbms_cdc_expvdp; 
drop public synonym dbms_cdc_impdp;
drop public synonym dbms_cdc_impdpv; 
drop public synonym dbms_cdc_dputil;
drop public synonym dbms_cdc_publish;
drop public synonym dbms_cdc_subscribe;
drop public synonym dbms_logmnr_cdc_subscribe;
drop public synonym dbms_logmnr_cdc_publish;

-- drop CDC Packages (11)
drop package sys.dbms_cdc_isubscribe;
drop package sys.dbms_cdc_sys_ipublish;
drop package sys.dbms_cdc_ipublish;
drop package sys.dbms_cdc_expdp;
drop package sys.dbms_cdc_expvdp; 
drop package sys.dbms_cdc_impdp;
drop package sys.dbms_cdc_impdpv; 
drop package sys.dbms_cdc_dputil;
drop package sys.dbms_cdc_publish;
drop package sys.dbms_cdc_subscribe;
drop package sys.dbms_cdc_utility;

-- drop synonyms for catalog views
drop public synonym all_change_sources;
drop public synonym change_sources;
drop public synonym all_change_sets;
drop public synonym change_sets;
drop public synonym all_change_tables;
drop public synonym change_tables;
drop public synonym all_change_propagations;
drop public synonym change_propagations;
drop public synonym all_change_propagation_sets;
drop public synonym change_propagation_sets;
drop public synonym dba_source_tables;
drop public synonym user_source_tables;
drop public synonym all_source_tables;


drop public synonym dba_published_columns;
drop public synonym user_published_columns;
drop public synonym all_published_columns;
drop public synonym dba_subscriptions;
drop public synonym user_subscriptions;
drop public synonym all_subscriptions;
drop public synonym dba_subscribed_tables;
drop public synonym user_subscribed_tables;
drop public synonym all_subscribed_tables;
drop public synonym dba_subscribed_columns;
drop public synonym user_subscribed_columns;
drop public synonym all_subscribed_columns;
drop public synonym CDB_source_tables;
drop public synonym CDB_published_columns;
drop public synonym CDB_subscriptions;
drop public synonym CDB_subscribed_tables;
drop public synonym CDB_subscribed_columns;

-- bug-26432273: these objects can be present 
-- if database older than 10.1 is upgraded 
drop public synonym dba_source_tab_columns;
drop public synonym user_source_tab_columns;
drop public synonym all_source_tab_columns;

-- drop catalog views
drop view all_change_sources;
drop view all_change_sets;
drop view all_change_tables;
drop view all_change_propagations;
drop view all_change_propagation_sets;
drop view dba_source_tables;
drop view user_source_tables;
drop view dba_published_columns;
drop view user_published_columns;
drop view dba_subscriptions;
drop view user_subscriptions;
drop view dba_subscribed_tables;
drop view user_subscribed_tables;
drop view dba_subscribed_columns;
drop view user_subscribed_columns;
drop view CDB_source_tables;
drop view CDB_published_columns;
drop view CDB_subscriptions;
drop view CDB_subscribed_tables;
drop view CDB_subscribed_columns;

-- bug-26432273: these objects can be present 
-- if database older than 10.1 is upgraded 
drop view dba_source_tab_columns;
drop view user_source_tab_columns;
drop view all_source_tab_columns;

-- drop the CDC views for export
DROP VIEW exu10mvl;
DROP VIEW exu10mvlu;
DROP VIEW exu9mvl;
DROP VIEW exu9mvlu;
DROP VIEW exu9mvlcdcs;
DROP VIEW exu9mvlcdcst;
DROP VIEW exu9mvlcdcsc;
DROP VIEW exu9mvlcdccc;

-- drop the CDC libraries
drop library DBMS_CDCAPI_LIB;
drop library DBMS_CDCPUB_LIB;

-- remove CDC feature usage tracking
DROP PROCEDURE DBMS_FEATURE_CDC;

-- drop the Streams CDC package
drop package DBMS_STREAMS_CDC_ADM;

Rem *************************************************************************
Rem END Remove CDC from 12.2
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN CDB changes
Rem *************************************************************************

REM This table stores pdb snapshot information
create table pdb_snapshot$               /* pdb snapshots in consolidated db */
(
  con_id#       number not null,                             /* container ID */
  con_uid       number not null,                            /* container UID */
  snapname      varchar2(128) not null,                     /* snapshot name */
  snapscn       number not null,                             /* snapshot scn */
  prevsnapscn   number not null,                    /* previous snapshot scn */
  snaptime      number not null,                            /* snapshot time */
  prevsnaptime  number not null,                   /* previous snapshot time */
  archivepath   varchar2(4000) not null,        /* snapshot archive location */
  flags         number,                                             /* flags */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        varchar2(4000),
  spare7        date
)
/

create index i_pdbsnap1 on pdb_snapshot$(con_uid, snapscn)
/

create index i_pdbsnap2 on pdb_snapshot$(con_uid, snapname)
/

Rem *************************************************************************
Rem END CDB changes
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Proxy PDB changes
Rem *************************************************************************
-- bug 25177461: change the width of proxy_remote$.remote_srvc
ALTER TABLE sys.proxy_remote$ MODIFY REMOTE_SRVC varchar2(128);
Rem *************************************************************************
Rem END Proxy PDB changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Drainining changes
Rem *************************************************************************

REM Table stores non-std sqls and en/disable info for plann maint draining.
create table connection_tests$   /* Tests which can be used for draining */
(
  predefined            number,       /* Test - Predefined(1) or Custom(0) */
  connection_test_type  number,           /* SQL(0)/PING(1)/END_REQUEST(2) */
  sql_connection_test   varchar2(64),                               /* SQL */
  service_name          varchar2(128),            /* Optional service name */
  enabled               number,          /* Test enabled(1) or disabled(0) */
  spare1                number,
  spare2                number,
  spare3                number,
  spare4                varchar2(1000),
  spare5                varchar2(1000),
  spare6                date
)
/
create unique index u_sql on 
  connection_tests$(connection_test_type, sql_connection_test)
/ 
BEGIN 
  insert into connection_tests$(predefined, connection_test_type, 
                                sql_connection_test, service_name, enabled) 
              values(1, 0, 'SELECT 1 FROM DUAL', '', 1);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into connection_tests$(predefined, connection_test_type, 
                                sql_connection_test, service_name, enabled) 
              values(1, 0, 'SELECT COUNT(*) FROM DUAL', '', 1);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into connection_tests$(predefined, connection_test_type, 
                                sql_connection_test, service_name, enabled) 
              values(1, 0, 'SELECT 1', '', 1);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into connection_tests$(predefined, connection_test_type, 
                                sql_connection_test, service_name, enabled) 
              values(1, 0, 'BEGIN NULL;END', '', 1);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into connection_tests$(predefined, connection_test_type, 
                                sql_connection_test, service_name, enabled) 
  values(1, 1, 'NA', '',0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into connection_tests$(predefined, connection_test_type, 
                              sql_connection_test, service_name, enabled) 
              values(1, 2, 'NA', '', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
commit
/

Rem *************************************************************************
Rem END Draining changes
Rem *************************************************************************



Rem *************************************************************************
Rem BEGIN BUG 21571874 add job_name to rgroup$
Rem *************************************************************************

ALTER TABLE rgroup$ ADD (job_name VARCHAR2(128) DEFAULT NULL) ;
CREATE INDEX i_rgjobname ON rgroup$ (job_name)
/

Rem *************************************************************************
REM END BUG 21571874 add job_name to rgroup$
Rem *************************************************************************

Rem**************************************************************************
Rem BEGIN BUG 23012504: remove EXEMPT DML REDACTION POLICY privilege and
Rem remove EXEMPT DDL REDACTION POLICY privilege
Rem**************************************************************************

-- Delete the EXEMPT DML/DDL REDACTION POLICY system privilege.
delete from STMT_AUDIT_OPTION_MAP where option# in (391,392);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-391,-392);
commit;

Rem**************************************************************************
Rem END BUG 23012504 
Rem**************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 25245797
Rem *************************************************************************

--
-- Create DUMMY AUDIT OBJECTS (which we plan to move from SYS schema to 
-- AUDSYS schema) under AUDSYS schema and grant the object level privileges
-- on these dummy objects to those users/roles who have already been 
-- granted object level privileges on these objects under SYS schema.
-- Once the upgrade finishes, as part of catuat.sql/dbmsamgt.sql these
-- dummy objects would get replaced with actual objects under AUDSYS schema.
-- Since we would be granting required privileges on these objects under AUDSYS
-- schema to users/roles, post DB upgrade accessing these objects wouldn't
-- have privilege issues.
--
-- LRG 20400585: Create and process the DUMMY DV unified audit trail objects
-- in the DV migration script (dvu122.sql). This is required because for an 
-- upgrade rerun, the RDBMS upgrade (e.g., the c1202000.sql script and 
-- catproc.sql) is always run, but for each component, if the upgrade has 
-- already be run successfully and the status is VALID or UPGRADED, then the 
-- component script is not rerun.  So the the dummy views created in this file
-- would never get replaced by the real views. This could lead to signature 
-- mismatch for an upgraded DB vs freshly created DB.

create or replace view AUDSYS.CDB_XS_AUDIT_TRAIL as select * from sys.dual;
create or replace view AUDSYS.DBA_XS_AUDIT_TRAIL as select * from sys.dual;
create or replace view AUDSYS.CDB_UNIFIED_AUDIT_TRAIL as select * from sys.dual;
create or replace view AUDSYS.UNIFIED_AUDIT_TRAIL as select * from sys.dual;
create or replace package AUDSYS.DBMS_AUDIT_MGMT as
procedure dummy_audsys_proc;
end;
/

-- Bug 26389197, 26515990: Update the objauth$ dictionary to set the grantor
-- information correctly. This would also avoid executing the GRANT statements
-- with CONTAINER=ALL when _ORACLE_SCRIPT is set to TRUE.

declare
cnt                    NUMBER := 0;    -- Number of Grants
sys_audit_objid        NUMBER := 0;    -- Audit Object ID owned by SYS
audsys_audit_objid     NUMBER := 0;    -- Audit Object ID owned by AUDSYS
audsys_uid             NUMBER := 0;    -- AUDSYS UserID
TYPE obj_name_list IS VARRAY(5) OF VARCHAR2(30); -- List of Audit Objects
audit_obj_list obj_name_list;

BEGIN
  audit_obj_list := obj_name_list('UNIFIED_AUDIT_TRAIL',
                                  'CDB_UNIFIED_AUDIT_TRAIL',
                                  'DBA_XS_AUDIT_TRAIL',
                                  'CDB_XS_AUDIT_TRAIL',
                                  'DBMS_AUDIT_MGMT');

  -- Get the UserID of AUDSYS
  SELECT user# INTO audsys_uid FROM sys.user$ where name = 'AUDSYS';

  -- For every Audit Object of interest
  FOR i IN audit_obj_list.first..audit_obj_list.last
  LOOP
    BEGIN
      -- First, check if the grant exists on this SYS owned audit object
      SELECT count(*) INTO cnt FROM sys.objauth$ oa, sys.obj$ o
      WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
      AND oa.obj# = o.obj# and rownum = 1;

      IF (cnt > 0) THEN  -- if the grant exists
        IF (audit_obj_list(i) = 'DBMS_AUDIT_MGMT') THEN -- if package
          -- Get the object ID of SYS owned audit package
          SELECT o.obj# INTO sys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
          AND o.type# = 9;

          -- Get the object ID of AUDSYS owned audit package
          SELECT o.obj# INTO audsys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
          AND o.type# = 9;

        ELSE  -- else, it is a view
          -- Get the object ID of SYS owned audit view
          SELECT o.obj# INTO sys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = 0 AND o.name = audit_obj_list(i)
          AND o.type# = 4;

          -- Get the object ID of AUDSYS owned audit view
          SELECT o.obj# INTO audsys_audit_objid FROM sys.obj$ o
          WHERE o.owner# = audsys_uid AND o.name = audit_obj_list(i)
          AND o.type# = 4;
        END IF;

        -- Update both obj# and grantor# for the entries who have been granted 
        -- privileges as SYS or anyone with GRANT ANY OBJECT privilege.
        UPDATE sys.objauth$ SET
        obj# = audsys_audit_objid, grantor# = audsys_uid
        WHERE obj# = sys_audit_objid AND grantor# = 0;

        -- Update ONLY obj# for entries who have been granted by user
        -- having 'WITH GRANT OPION'.
        UPDATE sys.objauth$ SET obj# = audsys_audit_objid
        WHERE obj# = sys_audit_objid AND grantor# <> 0;

        COMMIT;
      END IF;
    END;
  END LOOP;
END;
/

DROP LIBRARY SYS.DBMS_AUDIT_MGMT_LIB;

DROP PUBLIC SYNONYM DBMS_AUDIT_MGMT;
DROP PACKAGE SYS.DBMS_AUDIT_MGMT;

DROP PUBLIC SYNONYM CDB_XS_AUDIT_TRAIL;
DROP VIEW SYS.CDB_XS_AUDIT_TRAIL;

DROP PUBLIC SYNONYM DBA_XS_AUDIT_TRAIL;
DROP VIEW SYS.DBA_XS_AUDIT_TRAIL;

DROP PUBLIC SYNONYM CDB_UNIFIED_AUDIT_TRAIL;
DROP VIEW SYS.CDB_UNIFIED_AUDIT_TRAIL;

DROP PUBLIC SYNONYM UNIFIED_AUDIT_TRAIL;
DROP VIEW SYS.UNIFIED_AUDIT_TRAIL;

Rem *************************************************************************
REM END BUG 25245797
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25376213: Drop evolved ODCIColInfoList2
Rem Type was evolved in upgrade to 12.1; drop so can be recreated
Rem as non-evolved type in catodci.sql
Rem *************************************************************************

DROP TYPE ODCIColInfoList2 FORCE;

Rem *************************************************************************
Rem END Bug 25376213: Drop evolved ODCIColInfoList2
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for AQ 
Rem *************************************************************************
--bug 25179268: change the primary key of table aq$_schedules 
ALTER TABLE sys.aq$_schedules drop primary key;
ALTER TABLE sys.aq$_schedules add constraint aq$_schedules_primary
        primary key (oid, destination, job_name);
--bug 25861721 drop type shard_meta and dependents
drop type sys.sh$shard_meta_list;
drop type sys.sh$shard_meta;
-- clear RULESET  compiled data
delete from rule_set_ee$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_te$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_ve$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_re$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_fob$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_ror$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_rop$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_nl$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_pr$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_rdep$ where rs_obj# in (select obj# from sys.obj$
where type# = 46 );
delete from rule_set_iot$ where rs_obj# in (select obj# from sys.obj$
                                            where type# = 46 );

commit;

--Bug 26634477: Fix mismatched dict objects after upgrade
alter table sys.aq$_dequeue_log_partition_map modify (min_delv_time_enq_scn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map modify (min_sub_delv_time_deq_scn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map modify (min_sub_delv_time_sn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map modify (part_properties NUMBER default 0);
alter table sys.aq$_queue_partition_map modify (part_properties   NUMBER default 0);
alter table SYS.AQ$_QUEUE_SHARDS modify(base_queue  NUMBER DEFAULT 0);

commit;

Rem *************************************************************************
Rem END changes for AQ 
Rem *************************************************************************
Rem *************************************************************************
Rem BEGIN Bug 26259599 changes
Rem *************************************************************************

BEGIN
  execute immediate
          'REVOKE SELECT ON SYS.USER_QUEUE_SCHEDULES '||
          ' FROM PUBLIC' ;
  EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
execute immediate
        'GRANT READ ON SYS.USER_QUEUE_SCHEDULES to '||
        'PUBLIC with grant option' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/

Rem *************************************************************************
Rem end Bug 26259599 changes
Rem *************************************************************************

Rem**************************************************************************
Rem BEGIN BUG 25879441: make default_pwd$ a data link
Rem**************************************************************************
update obj$ set flags=flags-bitand(flags,196608)+131072, status=1
 where name='DEFAULT_PWD$' and owner#=0 and type#=2;
commit;
alter system flush shared_pool;

-- do this after updating obj$ to avoid ORA-4063
begin
  if (SYS_CONTEXT('USERENV','CON_ID') > 1) then
    execute immediate 'truncate table sys.default_pwd$';
  end if;
end;
/

Rem**************************************************************************
Rem END BUG 25879441: make default_pwd$ a data link
Rem**************************************************************************

Rem ************************************************************************
Rem BEGIN Bug 25406176 : alter AUDSYS to no authentication clause
Rem ************************************************************************

ALTER USER audsys NO AUTHENTICATION;
delete from SYS.default_pwd$ where user_name='AUDSYS';
commit;

Rem ************************************************************************
Rem END Bug 25406176 : alter AUDSYS to no authentication clause
Rem ************************************************************************

Rem *************************************************************************
Rem BEGIN changes for project 67576
Rem *************************************************************************

ALTER AUDIT POLICY ora_secureconfig ADD ACTIONS ALTER DATABASE DICTIONARY
/

Rem *************************************************************************
Rem END changes for project 67576
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for lockdown profile enhancement
Rem *************************************************************************

ALTER TABLE sys.lockdown_prof$ MODIFY ruletyp NULL;
ALTER TABLE sys.lockdown_prof$ MODIFY ruletyp# NULL;
ALTER TABLE sys.lockdown_prof$ MODIFY ruleval NULL;

ALTER TABLE sys.lockdown_prof$ ADD (con_uid NUMBER);
Rem In 12.2.0.1, lockdown profiles were only allowed to be created in CDBROOT.
Rem So update con_uid for existing rows to 1(ROOT's con_uid).
UPDATE sys.lockdown_prof$ set con_uid = 1 where con_uid is NULL;
Rem Add NOT NULL constraint for con_uid column.
ALTER TABLE sys.lockdown_prof$ MODIFY con_uid NOT NULL;

ALTER TABLE sys.lockdown_prof$ ADD (usertyp$ NUMBER);
Rem Update usertyp$ for existing rows to 0(ALL_USERS)
UPDATE sys.lockdown_prof$ set usertyp$ = 0;

Rem *************************************************************************
Rem END changes for lockdown profile enhancement
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 27083755: changes for table that tracks sensitive fixed tables
Rem *************************************************************************
create table sensitive_fixed$
(
  name     varchar2(128) not null,
  flag     number,
  spare1   number,
  spare2   number,
  spare3   varchar2(1000)
)
/

create index i_sensitive_fixed_n$ on sensitive_fixed$(name)
/

Rem *************************************************************************
Rem Bug 27083755: changes for table that tracks sensitive fixed tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes to container$ (Bugs 25033818, 27131802)
Rem *************************************************************************

ALTER TABLE container$ ADD (tenant_id VARCHAR2(255));
ALTER TABLE container$ ADD (snapint number);

Rem *************************************************************************
REM END changes to container$
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for Automatic inmemory management changes (Project 68505)
Rem *************************************************************************

ALTER TABLE sys.ado_imtasks$ add state number;
ALTER TABLE sys.ado_imsegtaskdetails$ add est_imsize number;
ALTER TABLE sys.ado_imsegtaskdetails$ add val number;
ALTER TABLE sys.ado_imsegtaskdetails$ add im_pop_state number;
ALTER TABLE sys.ado_imsegtaskdetails$ add state number;
ALTER TABLE sys.ado_imsegtaskdetails$ add imbytes number;
ALTER TABLE sys.ado_imsegtaskdetails$ add blocksinmem number;
ALTER TABLE sys.ado_imsegtaskdetails$ add datablocks number;
ALTER TABLE sys.ado_imsegtaskdetails$ add spare1 number;
ALTER TABLE sys.ado_imsegtaskdetails$ add spare2 number;
ALTER TABLE sys.ado_imsegtaskdetails$ add spare3 number;
ALTER TABLE sys.ado_imsegtaskdetails$ add spare4 varchar2(128);
ALTER TABLE sys.ado_imsegtaskdetails$ add spare5 varchar2(128);
ALTER TABLE sys.ado_imsegtaskdetails$ add spare6 timestamp;

Rem Bug: 27119186: Flag column in heat_map_stat$ is used to distinguish
Rem access tracking performed when heat map is off. 18.1 codebase expects to 
Rem see a non-null value of the flag column. A null value recorded in prior 
Rem releases is equivalent to a flag value of 0

declare 
  table_not_found exception;
  PRAGMA EXCEPTION_INIT(table_not_found, -942);
begin
  execute immediate 
    'update sys.heat_map_stat$ set flag = 0 where obj# !=-1';
  commit;
exception
  when table_not_found  then
    null;
end;
/

alter table sys.heat_map_stat$ modify flag default 0;

Rem *************************************************************************
REM END Changes for Automatic inmemory management changes (Project 68505)
Rem *************************************************************************


Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************

Rem Add pq_timeout_action
alter table resource_plan_directive$ add (pq_timeout_action number);
update resource_plan_directive$ set pq_timeout_action = 4294967295;

commit;

Rem ************************************************************************
Rem Resource Manager related changes - END
Rem ************************************************************************


Rem *************************************************************************
Rem BEGIN Join group catalog changes
Rem *************************************************************************

DECLARE
  primary_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(primary_key_exists, -02260);
BEGIN
  execute immediate
    'alter table im_joingroup$ add constraint im_joingroup_pk ' ||
    ' primary key (domain#) ' ;
EXCEPTION
  WHEN primary_key_exists THEN
    NULL;
END;
/

alter table im_joingroup$ add constraint im_joingroup_uk 
 unique (name, owner#);

alter table im_domain$ add constraint im_domain_uk
  unique (objn, col#);

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table im_domain$ add constraint im_domain_fk ' ||
    ' foreign key (domain#) references im_joingroup$(domain#) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

Rem *************************************************************************
REM END Join group catalog changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN 12.2 Project: Data Mining Algorithm Registration
Rem *************************************************************************

rem data mining algorithms
create table modelalg$(
       owner       NUMBER,
       name        varchar2(128),
       num         NUMBER not null,
       func        NUMBER,
       type        varchar2(20), 
       mdata       clob 
       CONSTRAINT ensure_json CHECK (mdata IS JSON), 
       des         varchar2(4000))
storage (maxextents unlimited)
tablespace SYSTEM
/
create unique index modelalg$idx
  on modelalg$ (num)
storage (maxextents unlimited)
tablespace SYSTEM
/
CREATE SEQUENCE modelalg_seq$
 START WITH     1000
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;
BEGIN
  insert into modelalg$
     (owner, name, num, func, type, mdata, des)
     values(NULL, NULL, 0, NULL, NULL, NULL, NULL);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
commit;

Rem *************************************************************************
Rem END 12.2 Project: Data Mining Algorithm Registration
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Project 70435 changes
Rem *************************************************************************

-- add new columns
ALTER TABLE SYS.WRI$_ADV_EXECUTIONS ADD REQ_DOP NUMBER;
ALTER TABLE SYS.WRI$_ADV_EXECUTIONS ADD ACTUAL_DOP NUMBER;

-- add new parameter to SPA tasks
BEGIN
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'TEST_EXECUTE_DOP', 0, 1, 8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'TEST_EXECUTE_DOP'))#';
END;
/

Rem *************************************************************************
Rem END Project 70435 changes
Rem *************************************************************************

Rem *************************************************************************
REM BEGIN BUG 25254434 aw lockdown
Rem *************************************************************************
DECLARE
  owner   varchar2(128); -- M_IDEN
  awname  varchar2(128); -- M_IDEN
  
  CURSOR awlist IS
    SELECT a.awname, u.name
    FROM sys.aw$ a, sys.user$ u
    WHERE a.owner# = u.user#;
BEGIN
  OPEN awlist;
  LOOP
    BEGIN
      FETCH awlist INTO awname, owner;
      EXIT WHEN awlist%NOTFOUND;
      EXECUTE IMMEDIATE 'ALTER TABLE ' ||
              sys.dbms_assert.enquote_name(owner, FALSE) || '.' ||
              sys.dbms_assert.enquote_name('AW$'||awname, FALSE) || 
              ' USAGE AW';
    EXCEPTION
      WHEN OTHERS THEN CONTINUE;
    END;
  END LOOP;
  CLOSE awlist;
END;
/

Rem *************************************************************************
REM END BUG 25254434 aw lockdown
Rem *************************************************************************

Rem =======================================================================
Rem  Begin changes for scheduler 
Rem =======================================================================

drop type sys.step_list;

Rem *************************************************************************
Rem begin bug 25385095 revoke select privilege on scheduler view
Rem *************************************************************************

revoke select on dba_scheduler_remote_databases from public;

Rem *************************************************************************
Rem end bug 25385095 revoke select privilege on scheduler view
Rem *************************************************************************

Rem *************************************************************************
Rem begin bug 25992935 revoke execute privilege on dbms_isched
Rem *************************************************************************

revoke execute on dbms_isched from gsmadmin_internal;

Rem *************************************************************************
Rem end bug 25992935 revoke execute privilege on dbms_isched
Rem *************************************************************************

Rem =======================================================================
Rem  End changes for scheduler 
Rem =======================================================================

Rem =======================================================================
Rem  Begin changes for privilege analysis
Rem =======================================================================

-- bug26634962: make run_seq# nullable
alter table sys.priv_unused$ modify run_seq# NULL;

Rem =======================================================================
Rem  End changes for privilege analysis
Rem =======================================================================


Rem**************************************************************************
Rem BEGIN BUG 25600289: DWCS enhancements for Credentials
Rem**************************************************************************

alter table scheduler$_credential add key varchar2(4000);

Rem**************************************************************************
Rem END BUG 25600289: DWCS enhancements for Credentials
Rem**************************************************************************

Rem ====================================================================
Rem Begin Bug 25742058
Rem ====================================================================

Rem
Rem Bug 25742058: update col$.length for columns stored internally as 
Rem klob to reflect the new kpn size.
Rem

DECLARE
CURSOR c1 IS
select c.obj#, l.intcol# from col$ c, lob$ l  
where l.obj#=c.obj# and l.intcol#=c.intcol# and 
      bitand(l.property, 1) <> 0 and length = 3748;
BEGIN
FOR c1_rec IN c1 LOOP
  update sys.col$
  set length = 3752
  where obj# = c1_rec.obj# and intcol# = c1_rec.intcol#;
end loop;
commit;
END;
/

Rem ====================================================================
Rem End Bug 25742058
Rem ====================================================================

Rem**************************************************************************
Rem BEGIN BUG 25719642: Deprecate dbms_outln_edit
Rem**************************************************************************

DROP PUBLIC SYNONYM dbms_outln_edit;
DROP PACKAGE sys.outln_edit_pkg;

Rem**************************************************************************
Rem END BUG 25719642: Deprecate dbms_outln_edit
Rem**************************************************************************

Rem ====================================================================
Rem Begin RTI 20245020 - drop obsolete Summary Advisor library
Rem ====================================================================

drop library DBMS_SUMADV_LIB;

Rem ====================================================================
Rem End RTI 20245020 
Rem ====================================================================

Rem ====================================================================
Rem Begin RTI 20258949 - drop 12.1 objects
Rem ====================================================================

DROP PACKAGE sys.dbms_defergen;
DROP PUBLIC SYNONYM dbms_defergen;
DROP SEQUENCE sys.generator$_s;
DROP PACKAGE sys.dbms_defergen_util;

DROP VIEW sys.INT$DBA_HIST_PDB_IN_SNAP;

DROP PACKAGE sys.dbms_tsm;
DROP PACKAGE sys.dbms_tsm_prvt;
DROP LIBRARY sys.dbms_tsm_lib;
DROP PUBLIC SYNONYM dbms_tsm;
DROP PUBLIC SYNONYM dbms_tsm_prvt;

DROP TABLE sys.TTS_TBS$;
DROP TABLE sys.TTS_USR$;

Rem ====================================================================
Rem End RTI 20258949 
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 24714096
Rem ====================================================================

Rem
Rem Bug #24714096: shorten pe_name to 256 to avoid ORA-01450 on 2K block size.
Rem An index needs to be created on the pe_name column, and 758 is the
Rem maximum key length that can be indexed on a 2K block size, and also
Rem the cost-based optimizer would tend to avoid using indexes on very
Rem wide columns, so limiting the Policy Expression name to 256 here.
Rem
ALTER TABLE sys.radm_pe$ MODIFY pe_name VARCHAR2(256);

Rem ====================================================================
Rem End Bug 24714096
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN BUG 25684134: revoke select on aw$name tables
Rem *************************************************************************

revoke select on sys.aw$awcreate from public;
revoke select on sys.aw$awcreate10g from public;
revoke select on sys.aw$awmd from public;
revoke select on sys.aw$awreport from public;
revoke select on sys.aw$awxml from public;
revoke select on sys.aw$express from public;

Rem *************************************************************************
Rem END BUG 25684134: revoke select on aw$name tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 22666352
Rem *************************************************************************
-- bug 22666352: change the data type of mlog$.PARTDOBJ#
UPDATE SYS.MLOG$ SET PARTDOBJ# = NULL;
COMMIT;
ALTER TABLE sys.mlog$ MODIFY PARTDOBJ# varchar2(4000);
Rem *************************************************************************
Rem END bug 22666352
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 26289288: Persistent state of Private Temp Table(PTT) feature
Rem *************************************************************************
CREATE TABLE ptt_feature$
(
  track_time    TIMESTAMP,
  status        NUMBER NOT NULL,
  prefix_value  VARCHAR2(128) NOT NULL,
  spare1        NUMBER,
  spare2        VARCHAR2(128)
);
insert into ptt_feature$ values(systimestamp, 0, 'ORA$PTT_', NULL, NULL);
commit;
Rem *************************************************************************
Rem END Bug 26289288 
Rem *************************************************************************

Rem ====================================================================
Rem Begin Bug 26623937 / RTI 20595342
Rem ====================================================================

-- In 12.1.0.2, temporary views CDB$COMMONOBJPRIVS/etc may not have
-- been dropped in noncdb_to_pdb.sql. Drop them here.
DECLARE
  CURSOR c1 IS
  select name from obj$
  where type#=4 and owner#=0 and
       (name like 'CDB$COMMON%' or
        name like 'INT$CDB$COMMON%');
BEGIN
  FOR c1_rec IN c1 LOOP
    execute immediate 'DROP VIEW SYS.' || c1_rec.name;
  end loop;
END;
/

Rem ====================================================================
Rem End Bug 26623937 / RTI 20595342
Rem ====================================================================

Rem ====================================================================
Rem Begin RTI 20257878
Rem ====================================================================

-- In 12.1.0.2, OWNER_MIGRATE_UPDATE_TDO and OWNER_MIGRATE_UPDATE_HASHCODE are
-- standalone routines introduced by [tojhuan_bug-16162444] and later pulled
-- into the package DBMS_OBJECTS_UTILS by [skabraha_bug-17487358]. The former
-- transaction is backported alone to some prior-12.1.0.2 release and will
-- cause problems if instances of such releases are later upgraded to
-- 12.1.0.2 or higher.

drop procedure sys.OWNER_MIGRATE_UPDATE_TDO;
drop function  sys.OWNER_MIGRATE_UPDATE_HASHCODE;

Rem ====================================================================
Rem End RTI 20257878
Rem ====================================================================

Rem*************************************************************************
Rem BEGIN BUG 26370269: remove dbms_registry_server package body
Rem**************************************************************************

DROP package body sys.dbms_registry_server;

Rem**************************************************************************
Rem END BUG 26370269: remove dbms_registry_server package body
Rem**************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 26255427: Add new registry$ columns for FULL RU version
Rem *************************************************************************

ALTER TABLE sys.registry$ ADD (
      version_full        VARCHAR2(30), 
      org_version_full    VARCHAR2(30), 
      prv_version_full    VARCHAR2(30), 
      banner_full         VARCHAR2(128));

Rem *************************************************************************
Rem END Bug 26255427: Add new registry$ columns for FULL RU version
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 26634569: Set sql_handle to varchar2(30)
Rem *************************************************************************

-- Disable column validation; values will never be longer than 30 chars
alter session set events '14533 trace name context forever, level 1';

begin
  execute immediate 'alter table sql$text modify sql_handle VARCHAR2(30)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

alter session set events '14533 trace name context off';

Rem *************************************************************************
Rem END Bug 26634569
Rem *************************************************************************

Rem ====================================================================
Rem Begin Bugs 26634870, 26634591, 26635035
Rem ====================================================================

-- bug 26634870
alter table SYS.MV_REFRESH_USAGE_STATS$ modify ATOMIC# not null;
alter table SYS.MV_REFRESH_USAGE_STATS$ modify COUNT# not null;
alter table SYS.MV_REFRESH_USAGE_STATS$ modify MV_TYPE# not null;
alter table SYS.MV_REFRESH_USAGE_STATS$ modify OUT_OF_PLACE# not null;
alter table SYS.MV_REFRESH_USAGE_STATS$ modify REFRESH_METHOD# not null;
alter table SYS.MV_REFRESH_USAGE_STATS$ modify REFRESH_MODE# not null;

-- bug 26634591
alter table SYS.SYNCREF$_PARTN_OPS modify OUTSIDE_TABLE_NAME varchar2(128);
alter table SYS.SYNCREF$_PARTN_OPS modify OUTSIDE_TABLE_SCHEMA_NAME varchar2(128);
alter table SYS.SYNCREF$_PARTN_OPS modify PARTITION_NAME varchar2(128);
alter table SYS.SYNCREF$_PARTN_OPS modify PARTITION_OP varchar2(128);

-- bug 26635035
alter table SYS.SYNCREF$_STEP_STATUS modify AUX_OBJ_NAME varchar2(128);
alter table SYS.SYNCREF$_STEP_STATUS modify OBJ_NAME varchar2(128);
alter table SYS.SYNCREF$_STEP_STATUS modify OWNER varchar2(128);


Rem ====================================================================
Rem End Bugs 26634870, 26634591, 26635035
Rem ====================================================================

Rem**************************************************************************
Rem BEGIN Bug 26671620
Rem drop dbms_optim_bundle package
Rem**************************************************************************

drop package sys.dbms_optim_bundle;

Rem**************************************************************************
Rem END Bug 26671620
Rem**************************************************************************

Rem *************************************************************************
Rem BEGIN  Bug 26712379: add columns in wri$_adv_sqlt_plan_stats
Rem *************************************************************************

ALTER TABLE sys.wri$_adv_sqlt_plan_stats
  ADD (CACHED_GETS NUMBER, DIRECT_GETS NUMBER);

Rem *************************************************************************
Rem END  Bug 26712379
Rem *************************************************************************

Rem ====================================================================
Rem Begin bug 26150401: grant insert on finalhist$ to public
Rem ====================================================================
-- finalhist$ is a global temporary table used by optimzer to store the 
-- intermidiate histogram information. Global temporary table is per
-- session and for this certain table finalhist$, it is defined as on
-- commit delete. Therefore there will be no security breach when grant
-- the insert privilege to public.
 
grant insert on finalhist$ to public;

Rem ====================================================================
Rem End bug 26150401
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 21563855
Rem ====================================================================

alter table fed$app$status add flag number;

Rem ====================================================================
Rem End Bug 21563855
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 26965236
Rem ====================================================================

-- Make sure we set a tab$ property to indicate that existing tables
-- have sensitive columns.
-- tab$ property (KQLDTVCP3_HAS_SENS_COL, 
-- decimal value: 618970019642690137449562112, which is: power(2,89))
update sys.tab$ set
property = property + (power(2,89))
where (bitand(property, power(2,89)) = 0) and obj# in 
(select distinct o.obj# from sys.obj$ o, sys.col$ c
 where c.obj# = o.obj# and bitand(c.property, 8796093022208) = 8796093022208); 
commit;

Rem ====================================================================
Rem End Bug 26965236
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 26894818: populate fed$binds.appid#
Rem ====================================================================

update fed$binds b set appid#=(select appid# from pdb_sync$ s 
                                where b.seq#=s.replay#);
commit;

Rem ====================================================================
Rem End Bug 26894818
Rem ====================================================================

Rem ====================================================================
Rem Begin Bug 28188330 / RTI 21183805
Rem ====================================================================

drop public synonym DBMS_BDSQL;
drop package SYS.DBMS_BDSQL;



Rem ====================================================================
Rem End Bug 28188330 / RTI 2118380
Rem ====================================================================


---------- ADD UPGRADE ACTIONS ABOVE THIS LINE ---------------

Rem =========================================================================
Rem END STAGE 1: upgrade from 12.2 to the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

-- @@cxxxxxxxx.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END   c1202000.sql
Rem *************************************************************************

