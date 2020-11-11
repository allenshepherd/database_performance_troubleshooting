Rem
Rem $Header: rdbms/admin/e1202000.sql /st_rdbms_18.0/6 2018/05/16 22:11:54 apfwkr Exp $
Rem
Rem e1202000.sql
Rem
Rem Copyright (c) 2012, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      e1202000.sql - downgrade Oracle to 12.2
Rem
Rem      This script is run from catdwgrd.sql to perform any actions
Rem      needed to downgrade the server dictionary.
Rem
Rem    DESCRIPTION
Rem      The name of the file includes the first two numbers of
Rem      the immediately-preceding release version, this is known
Rem      as the "origin release" for the upgrade.
Rem
Rem      This file is one component of the server downgrade scripts.
Rem
Rem      This file performs dictionary changes necessary to allow the
Rem      origin release server to work properly after the downgrade.
Rem
Rem      This script is run from catdwgrd.sql in the current release
Rem      environment (before installing the origin release to which
Rem      you are downgrading) to perform any actions needed to
Rem      downgrade the data dictionary to the origin release. Any
Rem      downgrade actions needing to use packages or views need to
Rem      go into the "f" script, since dependent objects may be come
Rem      invalid when the "e" scripts are run.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      * The database must be open in UPGRADE mode/DOWNGRADE mode.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/e1202000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/e1202000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      05/13/18 - Backport shvmalik_bug-27941896 from st_rdbms_18.0
Rem    shvmalik    04/29/18 - #27941896: drop dbms_optim_bundle related objects
Rem    apfwkr      02/23/18 - Backport ineall_bug-27301308 from main
Rem    gravipat    12/01/17 - XbranchMerge gravipat_bug-27131802 from main
Rem    jstenois    11/29/17 - XbranchMerge jstenois_bug-27126506 from main
Rem    osuro       11/28/17 - bug 27078828: Add AWR_CDB_* views
Rem    ineall      01/05/18 - Bug 27301308: Clear unknown container$.flags
Rem    gravipat    11/16/17 - Bug 27131802: Set snapint to NULL in container$
Rem    jstenois    11/15/17 - 27126506: create private synonym for
Rem                           datapump_dir_objs so that older data pump clients
Rem                           work
Rem    thbaby      11/13/17 - Bug 27083755: truncate sensitive_tab$
Rem    kmorfoni    11/09/17 - Bug 27020490: snap_id in PK of WRH$_UNDOSTAT
Rem    hlakshma    10/23/17 - Drop AIM specific heat map view (bug 27119186)
Rem    amunnoli    11/07/17 - Bug 26965236: clear table sensitivity bit
Rem    tmontgom    11/04/17 - BUG 27057144. Drop public synonym
Rem                           DATAPUMP_DIR_OBJS.
Rem    rthammai    10/23/17 - Bug 26753949: remove version_legacy
Rem    quotran     10/19/17 - Add tablespace_name to wrm$_wr_control
Rem    sramakri    10/12/17 - lrg 20621949: remove collid from sumkey$.spare3
Rem    jcarey      09/28/17 - RTI 20639059 - drop DBMS_CUBE_ADVISE_SEC
Rem    pjulsaks    09/26/17 - Bug 21563855: remove flag to fed$app$status
Rem    rthammai    09/22/17 - Bug 26753949: drop v$version_legacy
Rem    vbipinbh    09/20/17 - bug 26711492: drop DBMS_SQLTCB_LIB
Rem    sgdelgad    09/20/17 - Bug 26081503: delete attribute 5 in
Rem                           SYS.ILM_CONCURRENCY$
Rem    xxixu       09/18/17 - Project 68493: clear tab$.property bit for
Rem                           MEMOPTIMIZE
Rem    sdavidso    09/13/17 - BUG 25453685: Drop KU$_SHARD_DOMIDX_NAMEMAP
Rem    alestrel    09/10/17 - Bug 25992938. Drop dbms_isched_utl
Rem    chliang     09/08/17 - bug 23598405: drop dbms_xds_int
Rem    tianlli     09/05/17 - bug 25115388: drop INT$DATA_LINK_TAB_STATISTICS
Rem    prshanth    09/01/17 - Bug 25988806: drop DBMS_PDB_CHECK_LOCKDOWN
Rem    msabesan    08/31/17 - Bug 26712379: drop columns in 
Rem                           wri$_adv_sqlt_plan_stats
Rem    raeburns    08/31/17 - Bug 26255427: Drop new registry$ columns
Rem    miglees     08/24/17 - Bug 26572993: drop [G]V$MEMOPTIMIZE_WRITE_AREA
Rem    thbaby      08/21/17 - Bug 26654326: drop DBMS_PDB_APP_CON
Rem    sroesch     04/04/19 - Drop v$java_services, gv$java_services
Rem    yuyzhang    08/10/17 - #(26150401):revoke insert on finalhist$
Rem    kmorfoni    08/16/17 - Drop begin_interval_time_tz, end_interval_time_tz
Rem                           from WRM$_SNAPSHOT
Rem    molagapp    08/10/17 - Bug 26595855: rename con_id -> unplug_con_id
Rem    kmorfoni    08/09/17 - Drop AWRRPT_VARCHAR256_LIST_TYPE
Rem    jcarey      08/09/17 - Bug 26568895 - Fix quoting
Rem    dmaniyan    08/04/17 - Bug 26546365: Add max_chunk_num to table_family
Rem    atomar      08/01/17 - bug 26259599 grant select priv to
Rem                           SYS.USER_QUEUE_SCHEDULES
Rem    smurdia     08/01/17 - Bug-25900939: Drop v$asm_audit_load_jobs,
Rem                           gv$asm_audit_load_jobs
Rem    cwidodo     07/25/17 - #(25463265): drop SQT_* views
Rem    jlingow     07/31/17 - Bug 26223818: Dropping 
Rem                           remote_scheduler_agent.pingserver
Rem    yingzhen    07/24/17 - Bug 26370266: drop package dbms_awr_protected
Rem    osuro       07/19/17 - Bug 26473362: truncate AWR baseline tables
Rem    jemaldon    07/18/17 - Bug 26351822: drop im_domain$ unique key
Rem    quotran     07/14/17 - Bug 26526331: Support AWR incremental flushing
Rem    rdecker     07/07/17 - Bug 25872389: drop new PL/Scope objects/columns
Rem    skabraha    07/05/17 - Bug 26168696: drop GetAnyTypeFromPersistent
Rem    harnesin    06/28/17 - Bug 25871643: Future pdb registration support
Rem    amunnoli    06/28/17 - Bug 26040105: Update ORA_CIS_RECOMMENDATIONS
Rem    rthatte     06/27/17 - Bug 21587462: delete users for Oracle Hospitality
Rem                           Simphony
Rem    dmaniyan    06/27/17 - Bug 25443435: Drop columns num_chunks, consistent
Rem                           from global_table
Rem    cgervasi    06/23/17 - bug26338046: wrh$_asm_disk_stat_summary
Rem    yanrzhan    06/20/17 - Bug 25598902: skip_obj
Rem    jingzhen    06/19/17 - RTI 20393192: drop kccd2x_ced_scn from x$kccdi2
Rem    prakumar    06/16/17 - Bug 26289288: truncate table ptt_feature$
Rem    amunnoli    06/12/17 - Bug 25245797: revoke the privileges from audsys
Rem    alestrel    06/09/17 - Bug 25992935. Drop dbms_isched_agent
Rem    kshergil    06/07/17 - Bug 25632497: drop DBMS_MEMOPTIMIZE_ADMIN
Rem    jcarey      06/07/17 - RTI 20337387 -- orphaned synonmys
Rem    jingzhen    06/06/17 - bug 26175875
Rem    pyam        06/01/17 - RTI 20292031: catch ORA-1 on insert
Rem    anupkk      05/15/17 - Bug 13954475: Drop DBMS_FEATURE_VPD
Rem    timedina    05/10/17 - Bug 25862910: make transient types not
Rem                           persistable
Rem    saratho     05/08/17 - Bug 25816781: drop column from
Rem                           gsmadmin_internal.cloud table
Rem    nbenadja    05/05/17 - Bug 22145819 : Set the column ddl_intcode to
Rem                           NULL.
Rem    hlakshma    05/05/17 - Drop AIM views during downgrade (bug-26019725)
Rem    lenovak     05/04/17 - Bug 25989904: grant drop index
Rem    atomar      05/01/17 - bug 25956410 clear ruleset compiled data
Rem    rankalik    04/27/17 - Bug25536381: Truncate connection_tests$
Rem    jcarey      04/25/17 - drop OLAP objects that are invalid if OLAP not
Rem                           enabled during downgrade
Rem    msabesan    04/24/17 - bug 25927752: revoke/grant privs for sysumf_role
Rem    quotran     04/21/17 - Add im_db_block_changes_total[delta] to 
Rem                           wrh$_seg_stat
Rem    yuyzhang    04/20/17 - proj #54799: drop dbms_stats_internal_agg
Rem    yanxie      04/19/17 - bug 22666352: change the type of mlog$.partdobj#
Rem    kmorfoni    04/18/17 - Drop open_time_tz from WRM$_PDB_IN_SNAP
Rem    anbhasu     04/14/17 - Bug 23012504: REMOVE EXEMPT DML/DDL REDACTION
Rem                           POLICY
Rem    schakkap    04/13/17 - #(25369636) Drop new types
Rem    dmaniyan    04/12/17 - Bug 25476616: Drop child_obj# from TS_SET_TABLE
Rem    abrown      04/12/17 - bug 25802176 : 128 byte PDB_NAME
Rem    ushaft      04/10/17 - bug 25856821: package dbms_ash
Rem    sdball      04/07/17 - RTI 20220359: remove orphaned object
Rem                           getShardingMode
Rem    sajaureg    04/06/17 - Bug 22550874: I/O calib tool more informative
Rem    hlakshma    04/06/17 - Drop columns for table adoado_imsegtaskdetails
Rem                           (bug-25825879)
Rem    pjulsaks    04/05/17 - Bug 25773902: Drop get_application_diff
Rem    cwidodo     04/04/17 - #(25410921): drop outln_pkg_internal
Rem    snetrava    03/13/17 - 25266580: Drop Text Datastore Access System Priv
Rem    kmorfoni    04/04/17 - Drop snap_id from wrm$_pdb_instance
Rem    sdball      03/31/17 - drop failover_restore from service
Rem    lenovak     03/29/17 - drop gwm_rac_affinity views and dependants
Rem    jcarey      03/27/17 - bug 25254434: aw lockdown
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    kmorfoni    03/24/17 - Drop startup_time_tz, open_time_tz from
Rem                           wrm$_pdb_instance
Rem    prshanth    03/23/17 - Bug 25713423: Drop the lockdown view.
Rem    pjulsaks    03/23/17 - RTI 20164707: drop function is_valid_path
Rem    quotran     03/21/17 - Bug 24845711: Add IM-stats to WRH$_SEG_STAT
Rem    yunkzhan    03/17/17 - Bug 22295425 - Drop table function
Rem                           USER_GG_TABF_PUBLIC
Rem    rdecker     02/03/17 - bug 5910872: drop some metadata
Rem    anupkk      03/09/17 - Bug 25512307: Drop view and public synonym
Rem                           DICTIONARY_CREDENTIALS_ENCRYPT
Rem    sursridh    03/06/17 - Bug 25683998: Remove events framework views.
Rem    pradeshm    03/03/17 - Fix Bug-25410917: drop dbms_rat_mask_internal
Rem                           package
Rem    sankejai    02/28/17 - Bug 25600289: drop key for credential
Rem    akanagra    03/05/17 - lrg 20151722: drop G[V]$AQ_IPC_*_MSGS
Rem    yingzhen    02/27/17 - drop wrh$_process_waittime
Rem    palashar    02/25/17 - #(25493529): drop sql_shard views and synonyms
Rem    alui        02/23/17 - drop wlm_pcservice views and synonym
Rem    rdecker     02/22/17 - ER 24622590: Enhance PL/Scope
Rem    jnunezg     02/13/17 - BUG 25422950: Drop new package
Rem    rthatte     02/10/17 - Bug 23753068: Reduce privileges to AUDIT_ADMIN
Rem    anupkk      02/09/17 - Project 67576: Drop ALTER DATABASE DICTIONARY
Rem                           action from audit policy ora_secureconfig
Rem    saratho     02/08/17 - drop DBMS_HWM_PRIM_SHARDS
Rem    sfeinste    02/08/17 - Drop av_cache_col left around from proj 70791
Rem    siyzhang    02/02/17 - Bug 25394846: drop column from lockdown_prof$
Rem    gravipat    01/31/17 - lrg 20081646: Drop views dba/cdb_pdb_snapshots
Rem    sursridh    01/31/17 - Downgrade for pdb event notification framework.
Rem    kishykum    01/30/17 - proj 70507: pq_timeout_action downgrade changes
Rem    agsaha      01/14/17 - Bug 24706257 : Drop PK-FK and unique key
Rem                           constraints from im_domain$ and im_joingroup$
Rem                           tables
Rem    tchorma     01/30/17 - Proj 47075: Identity column support for Logminer
Rem    amullick    01/11/17 - Proj 68508 - drop delta-IMCU views
Rem    sfeinste    01/27/17 - Proj 70791: remove dyn_all_cache from
Rem                           hcs_analytic_view$
Rem    mdombros    01/27/17 - Project 70791 MD Caching new SYS privilege
Rem    prakumar    01/25/17 - Proj#61375:Drop *_PRIVATE_TEMP_TABLES changes
Rem    victlope    01/25/17 - Proj 70435: remove columns to wri$_adv_executions
Rem    prshanth    01/22/17 - PROJ 70729: alter columns in lockdown_prof$
Rem    jaeblee     01/20/17 - Bug 25033818:set tenant_id to null in container$
Rem    quotran     01/20/17 - Bug 18204711: Add obsolete_count into
Rem                           wrh$_sqlstat
Rem    ygu         01/05/17 - bfile/urowid support
Rem    aumishra    01/04/17 - Drop IME dictionary table
Rem    gravipat    12/22/16 - Bug 21902883:truncate pdb_snapshot$
Rem    siteotia    01/04/17 - Project 68493: Drop DBMS_MEMOPTIMIZE Synonymn
Rem                           and library.
Rem    jaeblee     12/20/16 - bug 25295968: drop trigger dbms_set_pdb
Rem    skayoor     12/09/16 - Project 34974: Clear KTSUCS1_NOAUTH bit in spare1
Rem                           column
Rem    ffeli       12/21/16 - add algorithm registration downgrade for R
Rem                           extensibility
Rem    jaeblee     12/20/16 - bug 25295968: drop trigger dbms_set_pdb
Rem    tianlli     12/14/16 - bug 25177461: change the width of 
Rem                           proxy_remote$.remote_srvc
Rem    yakagi      12/08/16 - bug 23756361: add Segments by GC Remote Grants
Rem                           section
Rem    jgiloni     12/08/16 - Quarantine for allocators
Rem    sjavagal    12/07/16 - Bug 24764763: Drop function sys.is_dv_supported
Rem    hlakshma    12/06/16 - Add column to ADO IM tables (Project 68505)
Rem    jingzhen    12/05/16 - proj 60642: drop column for preplugin tables
Rem                           RPP$X$KCCDI2 and ROPP$X$KCCDI2
Rem    yanlili     12/05/16 - Bug 24799459: Restore legacy SSHA1 verifier toRem
Rem                           SSHA1 verifier format in 12.1.0.1
Rem    dvoss       11/28/16 - bug 21825090:remove
Rem                           SYSTEM.LOGMNR_INTEGRATED_SPILL$
Rem    aanverma    11/21/16 - Bug 24765440: Delete EBS Endeca users from 
Rem                           default password list
Rem    jhartsin    11/18/16 - Bug 250433912: add mv_name to hcs_av_lvlgrp$
Rem    cgervasi    11/16/16 - bug24952170: wrh$_cell_db drop col
Rem                           is_current_src_db
Rem    wanma       11/15/16 - Bug 24826690: drop "globaldict" views  
Rem    dvoss       11/15/16 - bug 5703311: new logminer indexes and column
Rem    jjye        11/15/16 - bug 21571874 drop job_name from rgroup$
Rem    sdball      11/02/16 - Update Shard schema to support PDBs
Rem    aarvanit    11/07/16 - bug #24966761: drop package dbms_sqlset
Rem    dcolello    10/18/16 - drop DBMS_HWM_SHARDS
Rem    arjusing    10/05/16 - Bug 23260076: Revoke select on sha_databases from
Rem                           gds_catalog_select
Rem    arjusing    10/04/16 - Bug 20878412: Revoke inherit any privileges from
Rem                           gsmadmin_internal
Rem    gpongrac    08/15/16 - remove V$_ASM_CACHE_EVENTS stuff
Rem    dmaniyan    09/30/16 - Revoke gds_catalog_select from gsmuser_role
Rem    yuli        09/21/16 - bug 19798066: drop columns for preplugin tables
Rem    almurphy    09/13/16 - remove ref_distinct from sys.hcs_av_dim$
Rem    cgervasi    09/01/16 - bug24575927: drop columns num_failgroup, state
Rem                           from wrh$_asm_diskgroup_stat
Rem    aanverma    09/06/16 - Bug #24289422: Delete OADM users from default
Rem                           password list
Rem    sramakri    09/01/16 - Remove CDC from 12.2
Rem    cgervasi    09/01/16 - bug24575927: drop columns num_failgroup, state 
Rem                           from wrh$_asm_diskgroup_stat
Rem    jjanosik    07/26/16 - bug 18083463 - truncate metaaudit$
Rem    welin       06/03/16 - Created
Rem

Rem *************************************************************************
Rem BEGIN e1202000.sql
Rem *************************************************************************

rem
rem  Recreate Change Data Capture (CDC) objects except
rem cdc_rsid_seq$ which is used for sync capture 
rem

create table cdc_system$          /* things that apply to all change sources */
(
  major_version      number         not null,       /* i.e. release 1 of CDC */
  minor_version      number         not null     /* maintenance level i.e. 0 */
)
/
insert into cdc_system$ (major_version, minor_version) values(1,0)
/
create table cdc_change_sources$                  /* origin of change stream */
(                                             /* a collection of change sets */
  source_name        varchar2(30) not null,          /* user specified */
  dbid               number,                        /* Oracle DBID of origin */
  logfile_location   varchar2(2000),                   /* redo log directory */
  logfile_suffix     varchar2(30),                      /* "log", etc. */
  source_description varchar2(255),                          /* user comment */
  created            date not null,                     /* when row inserted */
  source_type        number not null,     /* change source type see qccpub.h */
                                         /* 0x01 = Manuallog, 0x02 = Autolog */
                                         /* 0x04 = Hotlog, 0x08 = Synchronous*/
                                        /* 0x10 = 9iR2 src 0x20 = distributed*/
                                        /* 0x40 = hot mine 0x80 = user def   */
  source_database    varchar2(128), /* source database full global name */
  source_dbid        varchar2(16),               /* source database ID */
  first_scn          number,               /* SCN before LogMiner dict. dump */
  first_logfile      varchar2(2000),    /* first ManualLog redo log file */
  logfile_format     varchar2(2000),   /* later log format for ManualLog */
  publisher          varchar2(30),    /* publisher that created source */
  capture_name       varchar2(30),      /* Streams capture engine name */
  capqueue_name      varchar2(30),       /* Streams capture queue name */
  capqueue_tabname   varchar2(30), /* Streams capture queue table name */
  source_enabled     char(1)                  /* Y or N - is capture started */
)
/
create unique index i_cdc_change_sources$ on cdc_change_sources$(source_name)
/
insert into cdc_change_sources$
  (source_name,dbid,logfile_location,logfile_suffix,source_description,created,
   source_type, source_database, source_dbid, first_scn, first_logfile, 
   logfile_format, publisher, capture_name, capqueue_name, capqueue_tabname,
   source_enabled)
  values('HOTLOG_SOURCE',NULL,NULL,NULL,'HOTLOG CHANGE SOURCE',SYSDATE,
         4, NULL, NULL, 0, NULL, NULL, 'SYSTEM', NULL, 'NONE', 'NONE', 'Y')
/
insert into cdc_change_sources$
  (source_name,dbid,logfile_location,logfile_suffix,source_description,created,
   source_type, source_database, source_dbid, first_scn, first_logfile, 
   logfile_format, publisher, capture_name, capqueue_name, capqueue_tabname,
   source_enabled)
  values('SYNC_SOURCE',NULL,NULL,NULL,'SYNCHRONOUS CHANGE SOURCE',SYSDATE,
        8, NULL, NULL, 0, NULL, NULL, 'SYSTEM', 'NONE', 'NONE', 'NONE', 'Y')
/
create table cdc_change_sets$               /* a collection of change tables */
(
  set_name           varchar2(30) not null,          /* user specified */
  change_source_name varchar2(30) not null,                  /* parent */
  begin_date         date,       /* starting point for capturing change data */
  end_date           date,        /* stoping point for capturing change data */
  begin_scn          number,     /* starting point for capturing change data */
  end_scn            number,      /* stoping point for capturing change data */
  freshness_date     date,     /* stopping point for last successful advance */
  freshness_scn      number,   /* stopping point for last successful advance */
  advance_enabled    char(1),               /* Y or N - eligible for advance */
  ignore_ddl         char(1),                  /* Y or N - continue vs. stop */
  created            date not null,                     /* when row inserted */
  rollback_segment_name varchar2(30), /* for use in advance - optional */
  advancing          char(1) not null,       /* Y or N - being advanced now? */
  purging            char(1) not null,         /* Y or N - being purged now? */
  lowest_scn         number,                           /* LWM of change data */
  tablespace         varchar2(30),       /* for advance LCR staging */
  lm_session_id      number,          /* for LogMiner session during advance */
  partial_tx_detected char(1),    /* advance detected partial transaction(s) */
  last_advance       date,                     /* when set was last advanced */
  last_purge         date,                       /* when set was last purged */
  stop_on_ddl        char(1) not null,      /* Y or N - stop if DDL detected */
  capture_enabled    char(1) not null,       /* Y or N - can perform capture */
  capture_error      char(1) not null,    /* Y or N - Streams error detected */
  capture_name       varchar2(30),      /* Streams capture engine name */
  queue_name         varchar2(30),            /* AQ/Streams queue name */
  queue_table_name   varchar2(30), /* AQ/Streams spillover queue table */
  apply_name         varchar2(30),        /* Streams apply engine name */
  supplemental_procs number,        /* number of supp. processes CDC can use */
  set_description    varchar2(255),             /* description of change set */
  publisher          varchar2(30),       /* publisher that created set */
  set_sequence       varchar2(30),    /* sequence object name for rsid */
  lowest_timestamp   date,                       /* lowest timestamp for set */
  time_scn_name      varchar2(30)/* table to map timestamp-scn for set */
)
/
create unique index i_cdc_change_sets$ on cdc_change_sets$(set_name)
/
insert into cdc_change_sets$
  (set_name, change_source_name, created, advancing, purging, stop_on_ddl,
   capture_enabled, capture_error, set_description, lowest_scn, publisher,
   advance_enabled)
  values('SYNC_SET', 'SYNC_SOURCE', SYSDATE, 'N', 'N', 'N', 'Y', 'N',
         'SYNCHRONOUS CHANGE SET', 0, NULL,'Y')
/
create table cdc_change_tables$           /* information about change tables */
(
  obj#                number not null,           /* object # of change table */
  change_set_name     varchar2(30) not null,                 /* parent */
  source_schema_name  varchar2(30) not null,     /* source table owner */
  source_table_name   varchar2(30) not null,  /* corresp. source table */
  change_table_schema varchar2(30) not null,  /* for DROP_CHANGE_TABLE */
  change_table_name   varchar2(30) not null,  /* for DROP_CHANGE_TABLE */
  created             date not null,                    /* when row inserted */
  created_scn         number,  /* system commit scn of this table's creation */
  mvl_flag            number,                    /* for MV Log compatability */
  captured_values     char(1) not null,           /* Old values, New or Both */
  mvl_temp_log        varchar2(30),   /* MV Log temp. update. log name */
  mvl_v7trigger       varchar2(30),               /* MV Log V7 trigger */
  last_altered        date,       /* last successful ALTER_CHANGE_TABLE date */
  lowest_scn          number not null,         /* LWM for this table (PURGE) */
  mvl_oldest_rid      number,                     /* MV Log oldest rowid scn */
  mvl_oldest_pk       number,               /* MV Log oldest primary key scn */
  mvl_oldest_seq      number,                  /* MV Log oldest sequence scn */
  mvl_oldest_oid      number,                 /* MV Log oldest object id scn */
  mvl_oldest_new      number,                 /* MV Log oldest new value scn */
  mvl_oldest_rid_time date,                      /* MV Log oldest rowid time */
  mvl_oldest_pk_time  date,                /* MV Log oldest primary key time */
  mvl_oldest_seq_time date,                   /* MV Log oldest sequence time */
  mvl_oldest_oid_time date,                  /* MV Log oldest object id time */
  mvl_oldest_new_time date,                  /* MV Log oldest new value time */
  mvl_backcompat_view varchar2(30),  /* MV Log back. compat. view name */
  mvl_physmvl         varchar2(30),             /* physical mv log     */
  highest_scn         number,                 /*  high water mark scn for ct */
  highest_timestamp   date,             /* time of last extend_window[_list] */
  change_table_type  number         not null, /* type of change table:       */
                                              /* 1 MV log style synchronous  */
                                              /* 2 asynchronous              */
                                              /* 3 improved synchronous      */
  major_version      number         not null,       /* i.e. release 1 of CDC */
  minor_version      number         not null,    /* maintenance level i.e. 0 */
  source_table_obj#  number,                     /* object # of source table */
  source_table_ver   number                /* version number of source table */
)
/
create unique index i_cdc_change_tables$ on cdc_change_tables$(obj#)
/
create table cdc_subscribers$                /* subscriptions to change data */
(
  subscription_name varchar2(30) not null,      /* subscription name   */
  handle             number not null,                 /* subscription handle */
  set_name           varchar2(30) not null,   /* change set identifier */
  username           varchar2(30) not null,           /* of subscriber */
  created            date not null,                     /* when row inserted */
  status             char(1) not null,         /* Not active (yet) or Active */
  earliest_scn       number not null,           /* starting point for window */
  latest_scn         number not null,             /* ending point for window */
  description        varchar2(255),                      /* for user comment */
  last_purged        date,             /* last time user called PURGE_WINDOW */
  last_extended      date,              /* time of last extend_window[_list] */
  mvl_invalid        char(1),     /* MV Log subscription invalid, 'Y' or 'N' */
  reserved1          number                     /* reserved numerical column */
)    
/
create unique index i_cdc_subscribers$ on cdc_subscribers$(subscription_name)
/
create table cdc_subscribed_tables$               /* tables of subscriptions */
(
  handle             number not null,                 /* subscription handle */
  change_table_obj#  number not null,    /* subscribed change table object # */
  view_name          varchar2(30),              /* generated view name */
  view_status        char(1) not null,                 /* Created or Dropped */
  mv_flag            number,                  /* MV Log info. required by MV */
  mv_colvec          raw(128)  /* MV Log columns required by MV (bit vector) */
)
/
create unique index i_cdc_subscribed_tables$ on cdc_subscribed_tables$
  (handle, change_table_obj#)
/
create table cdc_subscribed_columns$         /* columns of subscribed tables */
(
  handle            number not null,                  /* subscription handle */
  change_table_obj# number not null,     /* subscribed change table object # */
  column_name       varchar2(30) not null  /* src table col identifier */
)
/
create unique index i_cdc_subscribed_columns$ on cdc_subscribed_columns$
  (handle, change_table_obj#, column_name)
/
create sequence cdc_subscribe_seq$     /* CDC subscription handle allocation */
  start with 1
  increment by 1
  nomaxvalue
  minvalue 1
  nocycle
  cache 20
  noorder
/
create table cdc_change_columns$       /* track when columns added to tables */
(
  change_table_obj#  number not null,    /* subscribed change table object # */
  column_name        varchar2(30) not null,       /* column identifier */
  created            date not null,                     /* when row inserted */
  created_scn        number not null         /* scn of this columns creation */
)
/
create unique index i_cdc_change_columns$ on cdc_change_columns$
  (change_table_obj#, column_name)
/
create table cdc_propagations$                       /* cdc propagation info */
(                                          /* describes a given propagation  */
  propagation_name   varchar2(30) not null, /*Streams propagation name */
  destqueue_publisher varchar2(30) not null,    /* owner of dest queue */
  destqueue_name     varchar2(30) not null,  /* destination queue name */
  staging_database   varchar2(128) not null,    /* stage db global name */
  sourceid_name      varchar2(30) not null, 
                                        /* source identifier name for propag */
  source_class       number not null    /* class of source                   */
                                        /* 1=propag starts at change source  */
                                        /* 2=propag starts at change set     */
)
/
create index i_cdc_propagations$ on cdc_propagations$(propagation_name)
/
create table cdc_propagated_sets$                /* cdc set propagation info */
(                                    /* correlates progations to change sets */
  propagation_name    varchar2(30) not null, /*Streams propagation name*/
  change_set_publisher varchar2(30) not null, /* change set publisher  */
  change_set_name     varchar2(30) not null /* change set name-stage db*/
)
/
create index i_cdc_propagated_sets$ on cdc_propagated_sets$(propagation_name)
/
rem end of change data capture metadata



Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release -
Rem =========================================================================

  -- @@exxxxxxx.sql

  -- V$ASM_CACHE_EVENTS
  drop public synonym v$asm_cache_events;
  drop view v_$asm_cache_events;

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary to 12.2.0
Rem =========================================================================

Rem BEGIN BUG 18083463 truncate metaaudit$
Rem *************************************************************************
truncate table metaaudit$;
Rem *************************************************************************
Rem END BUG 18083463

Rem =====================================================================
Rem Begin Bug 5910872 changes
Rem =====================================================================
alter table sys.argument$ drop (type_type#);
update sys.argument$ set pls_type=null where pls_type='ROWTYPE';
Rem =====================================================================
Rem End Bug 5910872 changes
Rem =====================================================================

Rem BEGIN BUG 23260076 Revoke priviliges from gds_catalog_select
Rem *************************************************************************
revoke select on sha_databases from gds_catalog_select;
Rem *************************************************************************
Rem END BUG 23260076

Rem BEGIN BUG 22550874 (Drop a column)
Rem *************************************************************************
alter table resource_io_calibrate$ drop column additional_info;
Rem *************************************************************************
Rem END BUG 22550874
Rem *************************************************************************

Rem BEGIN BUG 20878412 Revoke priviliges from gsmadmin_internal
Rem *************************************************************************
revoke inherit privileges on user sys from gsmadmin_internal;
revoke inherit any privileges from gsmadmin_internal;
Rem *************************************************************************
Rem END BUG 20878412

Rem BEGIN BUG 25989904 Revoke priviliges from gsmadmin_internal
Rem *************************************************************************
revoke drop any index from gsmadmin_internal;
Rem *************************************************************************
Rem END BUG 25989904


Rem *************************************************************************
Rem Bug 24289422: Delete OADM users from default password list - START
Rem *************************************************************************
-- Remove OADM default user entries from SYS.DEFAULT_PWD$
delete from SYS.DEFAULT_PWD$ where user_name='OADM_REPORT';
delete from SYS.DEFAULT_PWD$ where user_name='OADM_SAMPLE';
delete from SYS.DEFAULT_PWD$ where user_name='OADM_SYS';
delete from SYS.DEFAULT_PWD$ where user_name='OADM_USER';
commit;

Rem *************************************************************************
Rem Bug 24289422: Delete OADM users from default password list - END
Rem *************************************************************************

Rem BEGIN BUG 24764763 Drop function SYS.IS_DV_SUPPORTED
Rem *************************************************************************
DROP FUNCTION SYS.IS_DV_SUPPORTED;
Rem *************************************************************************
Rem END BUG 24764763

Rem =========================================================================
Rem BEGIN HCS Changes for 12.2
Rem =========================================================================
-- Bug 24361734: remove column for one-up mappings
ALTER TABLE sys.hcs_av_dim$ DROP COLUMN ref_distinct
/

-- Bug 25043391: add mv_name column
ALTER TABLE sys.hcs_av_lvlgrp$ ADD mv_name VARCHAR2(128)
/

-- Proj 70791: remove dyn_all_cache from hcs_analytic_view$
alter table sys.hcs_analytic_view$ drop column dyn_all_cache;
drop table sys.av_dual;

-- Project 70791 MD Caching remove new SYS privileges
delete from sys.system_privilege_map 
where privilege in (-411, -412);

delete from sys.stmt_audit_option_map 
where option# in (411, 412);

-- Drop any new views/functions/synonyms introduced in cdhcs.sql
drop function av_cache_col;

Rem =========================================================================
Rem END HCS Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN CONTEXT Changes
Rem =========================================================================

-- Text DATASTORE ACCESS System Privilege for access 
-- to the file/url datastore access for creating Oracle Text Indexes
delete from STMT_AUDIT_OPTION_MAP where option# = 414;
delete from AUDIT$ where option# = 414;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -414;
delete from SYSAUTH$ where privilege# = -414;
commit;
Rem =========================================================================
Rem END CONTEXT Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN OBJECTS Changes
Rem =========================================================================

-- bug 26168696
drop public synonym GetAnyTypeFromPersistent
/

drop function GetAnyTypeFromPersistent
/

Rem =========================================================================
Rem END OBJECTS Changes
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN AWR changes
Rem *************************************************************************
-- drop AWR_CDB views

drop view AWR_CDB_DATABASE_INSTANCE;
drop public synonym AWR_CDB_DATABASE_INSTANCE;
drop view AWR_CDB_SNAPSHOT;
drop public synonym AWR_CDB_SNAPSHOT;
drop view AWR_CDB_SNAP_ERROR;
drop public synonym AWR_CDB_SNAP_ERROR;
drop view AWR_CDB_COLORED_SQL;
drop public synonym AWR_CDB_COLORED_SQL;
drop view AWR_CDB_BASELINE_METADATA;
drop public synonym AWR_CDB_BASELINE_METADATA;
drop view AWR_CDB_BASELINE_TEMPLATE;
drop public synonym AWR_CDB_BASELINE_TEMPLATE;
drop view AWR_CDB_WR_CONTROL;
drop public synonym AWR_CDB_WR_CONTROL;
drop view AWR_CDB_TABLESPACE;
drop public synonym AWR_CDB_TABLESPACE;
drop view AWR_CDB_DATAFILE;
drop public synonym AWR_CDB_DATAFILE;
drop view AWR_CDB_FILESTATXS;
drop public synonym AWR_CDB_FILESTATXS;
drop view AWR_CDB_TEMPFILE;
drop public synonym AWR_CDB_TEMPFILE;
drop view AWR_CDB_TEMPSTATXS;
drop public synonym AWR_CDB_TEMPSTATXS;
drop view AWR_CDB_COMP_IOSTAT;
drop public synonym AWR_CDB_COMP_IOSTAT;
drop view AWR_CDB_SQLSTAT;
drop public synonym AWR_CDB_SQLSTAT;
drop view AWR_CDB_SQLTEXT;
drop public synonym AWR_CDB_SQLTEXT;
drop view AWR_CDB_SQL_SUMMARY;
drop public synonym AWR_CDB_SQL_SUMMARY;
drop view AWR_CDB_SQL_PLAN;
drop public synonym AWR_CDB_SQL_PLAN;
drop view AWR_CDB_SQL_BIND_METADATA;
drop public synonym AWR_CDB_SQL_BIND_METADATA;
drop view AWR_CDB_OPTIMIZER_ENV;
drop public synonym AWR_CDB_OPTIMIZER_ENV;
drop view AWR_CDB_EVENT_NAME;
drop public synonym AWR_CDB_EVENT_NAME;
drop view AWR_CDB_SYSTEM_EVENT;
drop public synonym AWR_CDB_SYSTEM_EVENT;
drop view AWR_CDB_BG_EVENT_SUMMARY;
drop public synonym AWR_CDB_BG_EVENT_SUMMARY;
drop view AWR_CDB_WAITSTAT;
drop public synonym AWR_CDB_WAITSTAT;
drop view AWR_CDB_ENQUEUE_STAT;
drop public synonym AWR_CDB_ENQUEUE_STAT;
drop view AWR_CDB_LATCH_NAME;
drop public synonym AWR_CDB_LATCH_NAME;
drop view AWR_CDB_LATCH;
drop public synonym AWR_CDB_LATCH;
drop view AWR_CDB_LATCH_CHILDREN;
drop public synonym AWR_CDB_LATCH_CHILDREN;
drop view AWR_CDB_LATCH_PARENT;
drop public synonym AWR_CDB_LATCH_PARENT;
drop view AWR_CDB_LATCH_MISSES_SUMMARY;
drop public synonym AWR_CDB_LATCH_MISSES_SUMMARY;
drop view AWR_CDB_EVENT_HISTOGRAM;
drop public synonym AWR_CDB_EVENT_HISTOGRAM;
drop view AWR_CDB_MUTEX_SLEEP;
drop public synonym AWR_CDB_MUTEX_SLEEP;
drop view AWR_CDB_LIBRARYCACHE;
drop public synonym AWR_CDB_LIBRARYCACHE;
drop view AWR_CDB_DB_CACHE_ADVICE;
drop public synonym AWR_CDB_DB_CACHE_ADVICE;
drop view AWR_CDB_BUFFER_POOL_STAT;
drop public synonym AWR_CDB_BUFFER_POOL_STAT;
drop view AWR_CDB_ROWCACHE_SUMMARY;
drop public synonym AWR_CDB_ROWCACHE_SUMMARY;
drop view AWR_CDB_SGA;
drop public synonym AWR_CDB_SGA;
drop view AWR_CDB_SGASTAT;
drop public synonym AWR_CDB_SGASTAT;
drop view AWR_CDB_PGASTAT;
drop public synonym AWR_CDB_PGASTAT;
drop view AWR_CDB_PROCESS_MEM_SUMMARY;
drop public synonym AWR_CDB_PROCESS_MEM_SUMMARY;
drop view AWR_CDB_RESOURCE_LIMIT;
drop public synonym AWR_CDB_RESOURCE_LIMIT;
drop view AWR_CDB_SHARED_POOL_ADVICE;
drop public synonym AWR_CDB_SHARED_POOL_ADVICE;
drop view AWR_CDB_STREAMS_POOL_ADVICE;
drop public synonym AWR_CDB_STREAMS_POOL_ADVICE;
drop view AWR_CDB_SQL_WORKAREA_HSTGRM;
drop public synonym AWR_CDB_SQL_WORKAREA_HSTGRM;
drop view AWR_CDB_PGA_TARGET_ADVICE;
drop public synonym AWR_CDB_PGA_TARGET_ADVICE;
drop view AWR_CDB_SGA_TARGET_ADVICE;
drop public synonym AWR_CDB_SGA_TARGET_ADVICE;
drop view AWR_CDB_MEMORY_TARGET_ADVICE;
drop public synonym AWR_CDB_MEMORY_TARGET_ADVICE;
drop view AWR_CDB_MEMORY_RESIZE_OPS;
drop public synonym AWR_CDB_MEMORY_RESIZE_OPS;
drop view AWR_CDB_INSTANCE_RECOVERY;
drop public synonym AWR_CDB_INSTANCE_RECOVERY;
drop view AWR_CDB_JAVA_POOL_ADVICE;
drop public synonym AWR_CDB_JAVA_POOL_ADVICE;
drop view AWR_CDB_THREAD;
drop public synonym AWR_CDB_THREAD;
drop view AWR_CDB_STAT_NAME;
drop public synonym AWR_CDB_STAT_NAME;
drop view AWR_CDB_SYSSTAT_ID;
drop public synonym AWR_CDB_SYSSTAT_ID;
drop view AWR_CDB_SYSSTAT;
drop public synonym AWR_CDB_SYSSTAT;
drop view AWR_CDB_SYS_TIME_MODEL;
drop public synonym AWR_CDB_SYS_TIME_MODEL;
drop view AWR_CDB_CON_SYS_TIME_MODEL;
drop public synonym AWR_CDB_CON_SYS_TIME_MODEL;
drop view AWR_CDB_OSSTAT_NAME;
drop public synonym AWR_CDB_OSSTAT_NAME;
drop view AWR_CDB_OSSTAT;
drop public synonym AWR_CDB_OSSTAT;
drop view AWR_CDB_PARAMETER_NAME;
drop public synonym AWR_CDB_PARAMETER_NAME;
drop view AWR_CDB_PARAMETER;
drop public synonym AWR_CDB_PARAMETER;
drop view AWR_CDB_MVPARAMETER;
drop public synonym AWR_CDB_MVPARAMETER;
drop view AWR_CDB_UNDOSTAT;
drop public synonym AWR_CDB_UNDOSTAT;
drop view AWR_CDB_SEG_STAT;
drop public synonym AWR_CDB_SEG_STAT;
drop view AWR_CDB_SEG_STAT_OBJ;
drop public synonym AWR_CDB_SEG_STAT_OBJ;
drop view AWR_CDB_METRIC_NAME;
drop public synonym AWR_CDB_METRIC_NAME;
drop view AWR_CDB_SYSMETRIC_HISTORY;
drop public synonym AWR_CDB_SYSMETRIC_HISTORY;
drop view AWR_CDB_SYSMETRIC_SUMMARY;
drop public synonym AWR_CDB_SYSMETRIC_SUMMARY;
drop view AWR_CDB_CON_SYSMETRIC_HIST;
drop public synonym AWR_CDB_CON_SYSMETRIC_HIST;
drop view AWR_CDB_CON_SYSMETRIC_SUMM;
drop public synonym AWR_CDB_CON_SYSMETRIC_SUMM;
drop view AWR_CDB_SESSMETRIC_HISTORY;
drop public synonym AWR_CDB_SESSMETRIC_HISTORY;
drop view AWR_CDB_FILEMETRIC_HISTORY;
drop public synonym AWR_CDB_FILEMETRIC_HISTORY;
drop view AWR_CDB_WAITCLASSMET_HISTORY;
drop public synonym AWR_CDB_WAITCLASSMET_HISTORY;
drop view AWR_CDB_DLM_MISC;
drop public synonym AWR_CDB_DLM_MISC;
drop view AWR_CDB_CR_BLOCK_SERVER;
drop public synonym AWR_CDB_CR_BLOCK_SERVER;
drop view AWR_CDB_CURRENT_BLOCK_SERVER;
drop public synonym AWR_CDB_CURRENT_BLOCK_SERVER;
drop view AWR_CDB_INST_CACHE_TRANSFER;
drop public synonym AWR_CDB_INST_CACHE_TRANSFER;
drop view AWR_CDB_PLAN_OPERATION_NAME;
drop public synonym AWR_CDB_PLAN_OPERATION_NAME;
drop view AWR_CDB_PLAN_OPTION_NAME;
drop public synonym AWR_CDB_PLAN_OPTION_NAME;
drop view AWR_CDB_SQLCOMMAND_NAME;
drop public synonym AWR_CDB_SQLCOMMAND_NAME;
drop view AWR_CDB_TOPLEVELCALL_NAME;
drop public synonym AWR_CDB_TOPLEVELCALL_NAME;
drop view AWR_CDB_ACTIVE_SESS_HISTORY;
drop public synonym AWR_CDB_ACTIVE_SESS_HISTORY;
drop view AWR_CDB_ASH_SNAPSHOT;
drop public synonym AWR_CDB_ASH_SNAPSHOT;
drop view AWR_CDB_TABLESPACE_STAT;
drop public synonym AWR_CDB_TABLESPACE_STAT;
drop view AWR_CDB_LOG;
drop public synonym AWR_CDB_LOG;
drop view AWR_CDB_MTTR_TARGET_ADVICE;
drop public synonym AWR_CDB_MTTR_TARGET_ADVICE;
drop view AWR_CDB_TBSPC_SPACE_USAGE;
drop public synonym AWR_CDB_TBSPC_SPACE_USAGE;
drop view AWR_CDB_SERVICE_NAME;
drop public synonym AWR_CDB_SERVICE_NAME;
drop view AWR_CDB_SERVICE_STAT;
drop public synonym AWR_CDB_SERVICE_STAT;
drop view AWR_CDB_SERVICE_WAIT_CLASS;
drop public synonym AWR_CDB_SERVICE_WAIT_CLASS;
drop view AWR_CDB_SESS_TIME_STATS;
drop public synonym AWR_CDB_SESS_TIME_STATS;
drop view AWR_CDB_STREAMS_CAPTURE;
drop public synonym AWR_CDB_STREAMS_CAPTURE;
drop view AWR_CDB_CAPTURE;
drop public synonym AWR_CDB_CAPTURE;
drop view AWR_CDB_STREAMS_APPLY_SUM;
drop public synonym AWR_CDB_STREAMS_APPLY_SUM;
drop view AWR_CDB_APPLY_SUMMARY;
drop public synonym AWR_CDB_APPLY_SUMMARY;
drop view AWR_CDB_BUFFERED_QUEUES;
drop public synonym AWR_CDB_BUFFERED_QUEUES;
drop view AWR_CDB_BUFFERED_SUBSCRIBERS;
drop public synonym AWR_CDB_BUFFERED_SUBSCRIBERS;
drop view AWR_CDB_RULE_SET;
drop public synonym AWR_CDB_RULE_SET;
drop view AWR_CDB_PERSISTENT_QUEUES;
drop public synonym AWR_CDB_PERSISTENT_QUEUES;
drop view AWR_CDB_PERSISTENT_SUBS;
drop public synonym AWR_CDB_PERSISTENT_SUBS;
drop view AWR_CDB_SESS_SGA_STATS;
drop public synonym AWR_CDB_SESS_SGA_STATS;
drop view AWR_CDB_REPLICATION_TBL_STATS;
drop public synonym AWR_CDB_REPLICATION_TBL_STATS;
drop view AWR_CDB_REPLICATION_TXN_STATS;
drop public synonym AWR_CDB_REPLICATION_TXN_STATS;
drop view AWR_CDB_IOSTAT_FUNCTION;
drop public synonym AWR_CDB_IOSTAT_FUNCTION;
drop view AWR_CDB_IOSTAT_FUNCTION_NAME;
drop public synonym AWR_CDB_IOSTAT_FUNCTION_NAME;
drop view AWR_CDB_IOSTAT_FILETYPE;
drop public synonym AWR_CDB_IOSTAT_FILETYPE;
drop view AWR_CDB_IOSTAT_FILETYPE_NAME;
drop public synonym AWR_CDB_IOSTAT_FILETYPE_NAME;
drop view AWR_CDB_IOSTAT_DETAIL;
drop public synonym AWR_CDB_IOSTAT_DETAIL;
drop view AWR_CDB_RSRC_CONSUMER_GROUP;
drop public synonym AWR_CDB_RSRC_CONSUMER_GROUP;
drop view AWR_CDB_RSRC_PLAN;
drop public synonym AWR_CDB_RSRC_PLAN;
drop view AWR_CDB_CLUSTER_INTERCON;
drop public synonym AWR_CDB_CLUSTER_INTERCON;
drop view AWR_CDB_MEM_DYNAMIC_COMP;
drop public synonym AWR_CDB_MEM_DYNAMIC_COMP;
drop view AWR_CDB_IC_CLIENT_STATS;
drop public synonym AWR_CDB_IC_CLIENT_STATS;
drop view AWR_CDB_IC_DEVICE_STATS;
drop public synonym AWR_CDB_IC_DEVICE_STATS;
drop view AWR_CDB_INTERCONNECT_PINGS;
drop public synonym AWR_CDB_INTERCONNECT_PINGS;
drop view AWR_CDB_DISPATCHER;
drop public synonym AWR_CDB_DISPATCHER;
drop view AWR_CDB_SHARED_SERVER_SUMMARY;
drop public synonym AWR_CDB_SHARED_SERVER_SUMMARY;
drop view AWR_CDB_DYN_REMASTER_STATS;
drop public synonym AWR_CDB_DYN_REMASTER_STATS;
drop view AWR_CDB_LMS_STATS;
drop public synonym AWR_CDB_LMS_STATS;
drop view AWR_CDB_PERSISTENT_QMN_CACHE;
drop public synonym AWR_CDB_PERSISTENT_QMN_CACHE;
drop view AWR_CDB_PDB_INSTANCE;
drop public synonym AWR_CDB_PDB_INSTANCE;
drop view AWR_CDB_PDB_IN_SNAP;
drop public synonym AWR_CDB_PDB_IN_SNAP;
drop view AWR_CDB_CELL_CONFIG;
drop public synonym AWR_CDB_CELL_CONFIG;
drop view AWR_CDB_CELL_CONFIG_DETAIL;
drop public synonym AWR_CDB_CELL_CONFIG_DETAIL;
drop view AWR_CDB_ASM_DISKGROUP;
drop public synonym AWR_CDB_ASM_DISKGROUP;
drop view AWR_CDB_ASM_DISKGROUP_STAT;
drop public synonym AWR_CDB_ASM_DISKGROUP_STAT;
drop view AWR_CDB_ASM_BAD_DISK;
drop public synonym AWR_CDB_ASM_BAD_DISK;
drop view AWR_CDB_CELL_NAME;
drop public synonym AWR_CDB_CELL_NAME;
drop view AWR_CDB_CELL_DISKTYPE;
drop public synonym AWR_CDB_CELL_DISKTYPE;
drop view AWR_CDB_CELL_DISK_NAME;
drop public synonym AWR_CDB_CELL_DISK_NAME;
drop view AWR_CDB_CELL_GLOBAL_SUMMARY;
drop public synonym AWR_CDB_CELL_GLOBAL_SUMMARY;
drop view AWR_CDB_CELL_DISK_SUMMARY;
drop public synonym AWR_CDB_CELL_DISK_SUMMARY;
drop view AWR_CDB_CELL_METRIC_DESC;
drop public synonym AWR_CDB_CELL_METRIC_DESC;
drop view AWR_CDB_CELL_IOREASON_NAME;
drop public synonym AWR_CDB_CELL_IOREASON_NAME;
drop view AWR_CDB_CELL_GLOBAL;
drop public synonym AWR_CDB_CELL_GLOBAL;
drop view AWR_CDB_CELL_IOREASON;
drop public synonym AWR_CDB_CELL_IOREASON;
drop view AWR_CDB_CELL_DB;
drop public synonym AWR_CDB_CELL_DB;
drop view AWR_CDB_CELL_OPEN_ALERTS;
drop public synonym AWR_CDB_CELL_OPEN_ALERTS;
drop view AWR_CDB_IM_SEG_STAT;
drop public synonym AWR_CDB_IM_SEG_STAT;
drop view AWR_CDB_IM_SEG_STAT_OBJ;
drop public synonym AWR_CDB_IM_SEG_STAT_OBJ;
drop view AWR_CDB_CON_SYSSTAT;
drop public synonym AWR_CDB_CON_SYSSTAT;
drop view AWR_CDB_WR_SETTINGS;
drop public synonym AWR_CDB_WR_SETTINGS;
drop view AWR_CDB_BASELINE;
drop public synonym AWR_CDB_BASELINE;
drop view AWR_CDB_BASELINE_DETAILS;
drop public synonym AWR_CDB_BASELINE_DETAILS;
drop view AWR_CDB_SQLBIND;
drop public synonym AWR_CDB_SQLBIND;
drop view AWR_CDB_CON_SYSTEM_EVENT;
drop public synonym AWR_CDB_CON_SYSTEM_EVENT;
drop view AWR_CDB_RECOVERY_PROGRESS;
drop public synonym AWR_CDB_RECOVERY_PROGRESS;
drop view AWR_CDB_CHANNEL_WAITS;
drop public synonym AWR_CDB_CHANNEL_WAITS;
drop view AWR_CDB_RSRC_METRIC;
drop public synonym AWR_CDB_RSRC_METRIC;
drop view AWR_CDB_RSRC_PDB_METRIC;
drop public synonym AWR_CDB_RSRC_PDB_METRIC;

alter table wrh$_asm_diskgroup_stat drop (num_failgroup, state);

alter table wrh$_cell_db drop (is_current_src_db);

-- bug 18204711
alter table wrh$_sqlstat drop (obsolete_count);

-- bug 23756361, 24845711
alter table wrh$_seg_stat drop (gc_remote_grants_total
                                ,gc_remote_grants_delta
                                ,im_scans_total
                                ,im_scans_delta
                                ,populate_cus_total
                                ,populate_cus_delta
                                ,repopulate_cus_total
                                ,repopulate_cus_delta
                                ,im_db_block_changes_total
                                ,im_db_block_changes_delta
                               ); 

-- bug 26526331
alter table wrm$_wr_control drop (mrct_snap_step_tm
                                 ,mrct_snap_step_id
                                 ,tablespace_name);

-- wrm$_snap_error
alter table WRM$_SNAP_ERROR drop primary key;

-- remove snapshots of intermediate steps
delete from WRM$_SNAP_ERROR where step_id > 0;

commit;

alter table wrm$_snap_error drop (step_id);

alter table WRM$_SNAP_ERROR 
  add constraint WRM$_SNAP_ERROR_PK 
  primary key (dbid, snap_id, instance_number, table_name)
  using index tablespace SYSAUX;

-- snapshot details
drop index WRM$_SNAPSHOT_DETAILS_INDEX;

delete from WRM$_SNAPSHOT_DETAILS where step_id > 0;

commit;

alter table wrm$_snapshot_details drop (step_id);

create index WRM$_SNAPSHOT_DETAILS_INDEX 
 on WRM$_SNAPSHOT_DETAILS(snap_id, dbid, instance_number, table_id)
  tablespace SYSAUX;

truncate table WRH$_AWR_TEST_1;
truncate table WRH$_AWR_TEST_1_BL;

-- bug 25486323
drop public synonym AWR_PDB_PROCESS_WAITTIME;
drop view AWR_PDB_PROCESS_WAITTIME;
drop public synonym AWR_ROOT_PROCESS_WAITTIME;
drop view AWR_ROOT_PROCESS_WAITTIME;
drop public synonym AWR_CDB_PROCESS_WAITTIME;
drop view AWR_CDB_PROCESS_WAITTIME;
drop public synonym DBA_HIST_PROCESS_WAITTIME;
drop view DBA_HIST_PROCESS_WAITTIME;
truncate table  WRH$_PROCESS_WAITTIME;
truncate table  WRH$_PROCESS_WAITTIME_BL;
drop public synonym CDB_HIST_PROCESS_WAITTIME;
drop view CDB_HIST_PROCESS_WAITTIME;

-- bug 26338046
drop public synonym AWR_PDB_ASM_DISK_STAT_SUMMARY;
drop view AWR_PDB_ASM_DISK_STAT_SUMMARY;
drop public synonym AWR_ROOT_ASM_DISK_STAT_SUMMARY;
drop view AWR_ROOT_ASM_DISK_STAT_SUMMARY;
drop public synonym AWR_CDB_ASM_DISK_STAT_SUMMARY;
drop view AWR_CDB_ASM_DISK_STAT_SUMMARY;
drop public synonym DBA_HIST_ASM_DISK_STAT_SUMMARY;
drop view DBA_HIST_ASM_DISK_STAT_SUMMARY;
drop public synonym CDB_HIST_ASM_DISK_STAT_SUMMARY;
drop view CDB_HIST_ASM_DISK_STAT_SUMMARY;
truncate table WRH$_ASM_DISK_STAT_SUMMARY;
truncate table WRH$_ASM_DISK_STAT_SUMMARY_BL;

alter table wrm$_pdb_instance drop (snap_id, startup_time_tz, open_time_tz);

alter table wrm$_database_instance drop(startup_time_tz);

alter table wrm$_pdb_in_snap drop (open_time_tz);

alter table wrm$_snapshot drop (begin_interval_time_tz, end_interval_time_tz);

drop public synonym AWRRPT_NUMBER_LIST_TYPE;
drop type AWRRPT_NUMBER_LIST_TYPE force;

drop public synonym AWRRPT_VARCHAR256_LIST_TYPE;
drop type AWRRPT_VARCHAR256_LIST_TYPE;

truncate table WRM$_ACTIVE_PDBS_BL;

drop package dbms_awr_protected;

-- Remove snap_id from the PK of WRH$_UNDOSTAT.
-- Delete rows that will violate the new constraint.
delete from WRH$_UNDOSTAT u1
where exists (
  select 1
  from   WRH$_UNDOSTAT u2
  where  u2.begin_time = u1.begin_time
  and    u2.end_time = u1.end_time
  and    u2.dbid = u1.dbid
  and    u2.instance_number = u1.instance_number
  and    u2.con_dbid = u1.con_dbid
  and    u2.snap_id < u1.snap_id
);

commit;

alter table WRH$_UNDOSTAT drop primary key;

alter table WRH$_UNDOSTAT 
  add constraint WRH$_UNDOSTAT_PK
  primary key (begin_time, end_time, dbid, instance_number, con_dbid)
  using index tablespace SYSAUX;

Rem *************************************************************************
Rem END AWR changes
Rem *************************************************************************

Rem =======================================================================
Rem  Changes for Database Workload Capture and Replay
@@e1202000_wrr.sql
Rem =======================================================================


Rem ====================================================================
Rem BEGIN GDS changes since 12.2
Rem ===================================================================

REVOKE gds_catalog_select from gsmuser_role
/

-------------------------------------------------------------------------------
-- New procedures since 12.2.0.1
-------------------------------------------------------------------------------

DROP PROCEDURE DBMS_HWM_SHARDS
/

DROP PROCEDURE DBMS_HWM_PRIM_SHARDS
/

DROP PROCEDURE getShardingMode
/

-------------------------------------------------------------------------------
-- 12.2.0.2 changes to table DATABASE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT in_container
/

ALTER TABLE gsmadmin_internal.database DROP COLUMN container
/
DROP PUBLIC SYNONYM LOCAL_CHUNKS
/
DROP VIEW gsmadmin_internal.local_chunks
/
drop public synonym gv$gwm_rac_affinity
/
drop view gv_$gwm_rac_affinity
/
-------------------------------------------------------------------------------
-- changes to table SERVICE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.service DROP COLUMN failover_restore
/

-------------------------------------------------------------------------------
-- 12.2.0.2 changes to table TS_SET_TABLE
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.ts_set_table DROP COLUMN child_obj#
/

-------------------------------------------------------------------------------
-- 12.2.0.2 changes to table GLOBAL_TABLE
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.global_table DROP(NUM_CHUNKS, CONSISTENT)
/

-------------------------------------------------------------------------------
-- 12.2.0.2 changes to table TABLE_FAMILY
-------------------------------------------------------------------------------
ALTER TABLE gsmadmin_internal.table_family DROP COLUMN MAX_CHUNK_NUM
/

-------------------------------------------------------------------------------
-- 12.2.0.2 changes to table CLOUD
-------------------------------------------------------------------------------

DECLARE
    is_cat NUMBER;
BEGIN
    SELECT COUNT(*) INTO is_cat
        FROM gsmadmin_internal.cloud WHERE database_flags = 'C';
    IF is_cat > 0 THEN
        -- on catalog, reset the column database_flags
        UPDATE gsmadmin_internal.cloud SET database_flags = NULL;
    ELSE
        -- on shard, delete the row from cloud table
        DELETE FROM gsmadmin_internal.cloud WHERE database_flags != 'C';
    END IF;
END;
/

-------------------------------------------------------------------------------
-- 12.2.0.2 New tables
-------------------------------------------------------------------------------

TRUNCATE TABLE gsmadmin_internal.container_database
/

ALTER TABLE SYS.ddl_requests DROP COLUMN ddl_intcode
/

show errors

DROP FUNCTION GSMADMIN_INTERNAL.GETSHARDINGMODE
/
DROP PACKAGE GSMADMIN_INTERNAL.EXCHANGE
/
Rem ====================================================================
Rem END GDS changes since 12.2
Rem ===================================================================



Rem *************************************************************************
Rem BEGIN Preplugin changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCPDB drop (PDBCRCVBSCN,
                                   PDBRDB,
                                   PDBCCID_LOWER,
                                   PDBCCID_UPPER,
                                   PDBPREV_CCID_LOWER,
                                   PDBPREV_CCID_UPPER,
                                   PDBMIN_ACTSCN,
                                   PDBSCAN_FINSCN,
                                   PDBMA_RLS,
                                   PDBMA_RLC);

alter table SYS.ROPP$X$KCCPDB drop (PDBCRCVBSCN,
                                   PDBRDB,
                                   PDBCCID_LOWER,
                                   PDBCCID_UPPER,
                                   PDBPREV_CCID_LOWER,
                                   PDBPREV_CCID_UPPER,
                                   PDBMIN_ACTSCN,
                                   PDBSCAN_FINSCN,
                                   PDBMA_RLS,
                                   PDBMA_RLC);
drop view cdb_rpp$x$kccpic;
drop public synonym cdb_rpp$x$kccpic;
truncate table rpp$x$kccpic;
drop view cdb_ropp$x$kccpic;
drop public synonym cdb_ropp$x$kccpic;
truncate table ropp$x$kccpic;
drop sequence ropp$x$kccpic_seq;

DECLARE
   TYPE names_t IS TABLE OF VARCHAR2(30);
   lnames CONSTANT names_t := names_t (
      'ropp$x$kccdi_seq_', 
      'ropp$x$kccdi2_seq_',
      'ropp$x$kccic_seq_',
      'ropp$x$kccpdb_seq_',
      'ropp$x$kcpdbinc_seq_',
      'ropp$x$kccts_seq_',
      'ropp$x$kccfe_seq_',
      'ropp$x$kccfn_seq_',
      'ropp$x$kcvdf_seq_',
      'ropp$x$kcctf_seq_',
      'ropp$x$kcvfh_seq_',
      'ropp$x$kcvfhtmp_seq_',
      'ropp$x$kcvfhall_seq_',
      'ropp$x$kccrt_seq_',
      'ropp$x$kccle_seq_',
      'ropp$x$kccsl_seq_',
      'ropp$x$kcctir_seq_',
      'ropp$x$kccor_seq_', 
      'ropp$x$kcclh_seq_',
      'ropp$x$kccal_seq_',
      'ropp$x$kccbs_seq_',
      'ropp$x$kccbp_seq_',
      'ropp$x$kccbf_seq_',
      'ropp$x$kccbl_seq_',
      'ropp$x$kccbi_seq_',
      'ropp$x$kccdc_seq_',
      'ropp$x$kccpc_seq_',
      'ropp$x$kccpic_seq_'
   );
   no_such_sequence EXCEPTION;
   pragma exception_init (no_such_sequence, -2289);
   PROCEDURE dropSequence(p_seqName IN varchar2) IS
   BEGIN
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || p_seqName;
   EXCEPTION
      WHEN no_such_sequence THEN
         NULL;
   END dropSequence;
BEGIN
   FOR i in (select con_id from v$pdbs where con_id > 1) LOOP
      FOR n in 1..lnames.COUNT LOOP
         dropSequence(lnames(n) || to_char(i.con_id));
      END LOOP;
   END LOOP;
END;
/

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
   PROCEDURE renamePartitionIdColumn(p_tableName IN varchar2) IS
   BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE ' || p_tableName ||
                        ' RENAME COLUMN UNPLUG_CON_ID TO CON_ID';
   EXCEPTION
      WHEN dup_column_name THEN
         NULL;
   END renamePartitionIdColumn;
BEGIN
   FOR n in 1..lnames.COUNT LOOP
      renamePartitionIdColumn('SYS.RPP$'  || lnames(n));
   END LOOP;
END;
/

Rem *************************************************************************
Rem END Preplugin changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN project 60642 changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCDI2 drop column DI2PREVCYCLEDFHCKPSCN;
alter table SYS.ROPP$X$KCCDI2 drop column DI2PREVCYCLEDFHCKPSCN;

Rem *************************************************************************
Rem END project 60642 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 20393192 changes
Rem *************************************************************************

alter table SYS.RPP$X$KCCDI2 drop column DI2_CED_SCN;
alter table SYS.ROPP$X$KCCDI2 drop column DI2_CED_SCN;

Rem *************************************************************************
Rem END RTI 20393192 changes
Rem *************************************************************************

Rem =======================================================================
Rem Begin Logminer changes for 12.2.0.2
Rem =======================================================================
alter table system.logmnr_session$ rename column purge_scn to spare2;
alter table system.logmnr_session$ drop column spare9;
alter table system.logmnr_filter$ drop column attr7;
alter table system.logmnr_filter$ drop column attr8;
alter table system.logmnr_filter$ drop column attr9;
alter table system.logmnr_filter$ drop column attr10;
alter table system.logmnr_filter$ drop column attr11;
CREATE TABLE SYSTEM.logmnr_integrated_spill$ (
                session#                number,
                xidusn                  number,
                xidslt                  number,
                xidsqn                  number,
                chunk                   number,
                flag                    number,
                ctime                   date,
                mtime                   date,
                spill_data              blob,
                spare1                  number,
                spare2                  number,
                spare3                  number, 
                spare4                  date,
                spare5                  date,
        CONSTRAINT LOGMNR_INTEG_SPILL$_PK PRIMARY KEY 
            (session#, xidusn, xidslt, xidsqn, chunk, flag)
            USING INDEX TABLESPACE SYSAUX LOGGING)
        LOB (spill_data) STORE AS BASICFILE
           (TABLESPACE SYSAUX CACHE PCTVERSION 0
            CHUNK 32k STORAGE (INITIAL 4M NEXT 2M))
        TABLESPACE SYSAUX LOGGING
/
DROP TABLE SYS.LOGMNRG_SEED2$;

-- bug 25802176 : Restore 128 byte PDB_NAME to 30
TRUNCATE TABLE SYS.LOGMNRG_DICTIONARY$
/
ALTER TABLE SYS.LOGMNRG_DICTIONARY$ MODIFY PDB_NAME VARCHAR(30)
/

Rem Drop the supp log group on idnseq$ if downgrading before 12.2.0.2
declare
 previous_version varchar2(30);
 cnt number;
begin
  select prv_version into previous_version from registry$
  where  cid = 'CATPROC';

  select count(1) into cnt
  from con$ co, cdef$ cd, obj$ o, user$ u
  where o.name = 'IDNSEQ$'
    and u.name = 'SYS'
    and co.name = 'IDNSEQ$_LOG_GRP'
    and cd.obj# = o.obj#
    and cd.con# = co.con#;

  if previous_version < '12.2.0.2.0' and cnt > 0 then
    execute immediate 'alter table sys.idnseq$ 
                       drop supplemental log group idnseq$_log_grp';
  end if;
end;
/

drop index i_idnseq2
/

DROP INDEX SYSTEM.LOGMNR_I1IDNSEQ$;
DROP INDEX SYSTEM.LOGMNR_I2IDNSEQ$;
DROP TABLE SYSTEM.LOGMNR_IDNSEQ$ PURGE;
DROP TABLE SYS.LOGMNRG_IDNSEQ$ PURGE;

-- Also, delete any entries added to SYSTEM.LOGMNR_SEED$ for IDNSEQ$.
DELETE FROM SYSTEM.LOGMNR_SEED$ WHERE TABLE_NAME LIKE '%IDNSEQ%';

-- Drop SYSTEM.LOGMNR$USER_GG_TABF_PUBLIC and related types
drop FUNCTION SYSTEM.LOGMNR$USER_GG_TABF_PUBLIC ;
drop TYPE SYSTEM.LOGMNR$USER_GG_RECS ;
drop TYPE SYSTEM.LOGMNR$USER_GG_REC ;


Rem =======================================================================
Rem End Logminer changes for 12.2.0.2
Rem =======================================================================
  
Rem =======================================================================
Rem Begin XStreams changes for 12.2.0.2
Rem =======================================================================
  
-- bug 25871643: Future PDB registration
DROP VIEW dba_goldengate_container_rules;
DROP VIEW cdb_goldengate_container_rules;
DROP VIEW all_goldengate_container_rules;
DROP PUBLIC SYNONYM dba_goldengate_container_rules;
DROP PUBLIC SYNONYM cdb_goldengate_container_rules;
DROP PUBLIC SYNONYM all_goldengate_container_rules;

DROP TABLE sys.goldengate$_container_rules;
DROP SEQUENCE rule_id_seq$;

Rem =======================================================================
Rem End XStreams changes for 12.2.0.2
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================

drop view logstdby_ru_un_tab_12_2_0_2;
drop view logstdby_unsupp_tab_12_2_0_2;
drop view logstdby_support_tab_12_2_0_2;
drop view ogg_support_tab_12_2_0_2;

Rem =======================================================================
Rem End Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$QUARANTINE_SUMMARY
Rem =======================================================================

drop public synonym gv$quarantine_summary;
drop view gv_$quarantine_summary;
drop public synonym v$quarantine_summary;
drop view v_$quarantine_summary;

Rem =======================================================================
Rem END Changes for [G]V$QUARANTINE_SUMMARY
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for WLM
Rem =======================================================================
Rem Drop table required due to package dependencies
Rem so that the WLM user, appqossys can be dropped without cascade
Rem specified after all its tables are removed.

drop public synonym v$wlm_pcservice;
drop view v_$wlm_pcservice;
drop public synonym gv$wlm_pcservice;
drop view gv_$wlm_pcservice;

Rem =======================================================================
Rem  END Changes for WLM
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for global dictionary views [G]V$IM_GLOBALDICT*
Rem =======================================================================

--Bug 24826690: "segdict" has been renamed with "globaldict" for 12.2.0.2
REM [G]V$IM_GLOBALDICT
drop public synonym gv$im_globaldict;
drop view gv_$im_globaldict;
drop public synonym v$im_globaldict;
drop view v_$im_globaldict;

REM [G]V$IM_GLOBALDICT_VERSION
drop public synonym gv$im_globaldict_version;
drop view gv_$im_globaldict_version;
drop public synonym v$im_globaldict_version;
drop view v_$im_globaldict_version;

REM [G]V$IM_GLOBALDICT_SORTORDER
drop public synonym gv$im_globaldict_sortorder;
drop view gv_$im_globaldict_sortorder;
drop public synonym v$im_globaldict_sortorder;
drop view v_$im_globaldict_sortorder;

REM [G]V$IM_GLOBALDICT_PIECEMAP
drop public synonym gv$im_globaldict_piecemap;
drop view gv_$im_globaldict_piecemap;
drop public synonym v$im_globaldict_piecemap;
drop view v_$im_globaldict_piecemap;

Rem =======================================================================
Rem END Changes for IM Segment level dictionary views [G]V$IM_GLOBALDICT*
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Expressions dictionary table im_ime$
Rem =======================================================================
truncate table im_ime$;
Rem =======================================================================
Rem END Changes for In-Memory Expressions dictionary table im_ime$
Rem =======================================================================

Rem ====================================================================
Rem Begin Bug 24799459: Restore Legacy SSHA1 verifier to 12.1.0.1 SSHA1 
Rem verifier format.
Rem ====================================================================

DECLARE
CURSOR xs_lssha1_verifiers IS
select user#, verifier from sys.xs$verifiers where type# = 3;
BEGIN
FOR xs_lssha1_verifiers_crec IN xs_lssha1_verifiers LOOP
  update xs$verifiers set verifier = substr(xs_lssha1_verifiers_crec.verifier, 3), type#=1 where user#=xs_lssha1_verifiers_crec.user#;
END LOOP;
END;
/

Rem ====================================================================
Rem End Bug 24799459: Restore Legacy SSHA1 verifier to 12.1.0.1 SSHA1 
Rem verifier format.
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN Proxy PDB changes
Rem *************************************************************************
-- bug 25177461: change the width of proxy_remote$.remote_srvc
UPDATE sys.proxy_remote$ SET REMOTE_SRVC = SUBSTR(REMOTE_SRVC, 1, 64);
COMMIT;
ALTER TABLE sys.proxy_remote$ MODIFY REMOTE_SRVC varchar2(64);
Rem *************************************************************************
Rem END Proxy PDB changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 21571874 drop job_name from rgroup$ 
Rem *************************************************************************

ALTER TABLE rgroup$ DROP COLUMN job_name;

Rem *************************************************************************
Rem END BUG 21571874
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 25245797 - Revoke privileges from AUDSYS user
Rem *************************************************************************

DROP LIBRARY AUDSYS.DBMS_AUDIT_MGMT_LIB;
DROP PUBLIC SYNONYM DBMS_AUDIT_MGMT;
DROP PACKAGE AUDSYS.DBMS_AUDIT_MGMT;
DROP PUBLIC SYNONYM CDB_XS_AUDIT_TRAIL;
DROP VIEW AUDSYS.CDB_XS_AUDIT_TRAIL;
DROP PUBLIC SYNONYM DBA_XS_AUDIT_TRAIL;
DROP VIEW AUDSYS.DBA_XS_AUDIT_TRAIL;
DROP PUBLIC SYNONYM CDB_UNIFIED_AUDIT_TRAIL;
DROP VIEW AUDSYS.CDB_UNIFIED_AUDIT_TRAIL;
DROP PUBLIC SYNONYM UNIFIED_AUDIT_TRAIL;
DROP VIEW AUDSYS.UNIFIED_AUDIT_TRAIL;

drop public synonym get_aud_pdb_list;
drop function sys.get_aud_pdb_list;
drop public synonym aud_pdb_list;
drop type sys.aud_pdb_list;

revoke read on sys.v_$database from audsys;
revoke read on sys.v_$containers from audsys;
revoke read on sys.gv_$instance from audsys;
revoke read on sys.v_$option from audsys;
revoke read on sys.v_$instance from audsys;
revoke read on sys.v_$version from audsys;

revoke insert on SYS.DAM_LAST_ARCH_TS$ from audsys;
revoke delete on SYS.DAM_LAST_ARCH_TS$ from audsys;
revoke update on SYS.DAM_LAST_ARCH_TS$ from audsys;
revoke insert on SYS.DAM_CONFIG_PARAM$ from audsys;
revoke update on SYS.DAM_CONFIG_PARAM$ from audsys;
revoke delete on SYS.DAM_CONFIG_PARAM$ from audsys;
revoke update on SYS.DAM_CLEANUP_JOBS$ from audsys;
revoke delete on SYS.DAM_CLEANUP_JOBS$ from audsys;
revoke insert on SYS.DAM_CLEANUP_JOBS$ from audsys;

revoke execute on sys.dbms_session from audsys;
revoke execute on sys.dbms_assert from audsys;
revoke execute on sys.DBMS_SQL from audsys;
revoke execute on sys.DBMS_INTERNAL_LOGSTDBY from audsys;
revoke execute on sys.DBMS_PDB_EXEC_SQL from audsys;
revoke execute on SYS.DBMS_LOCK from audsys;
revoke execute on SYS.DBMS_STATS from audsys;
revoke execute on SYS.DBMS_SCHEDULER from audsys;

revoke alter session from audsys;
revoke analyze any dictionary from audsys;
revoke select any dictionary from audsys;
revoke create job from audsys;
revoke set container from audsys;

revoke read on sys.gv_$unified_audit_trail from audsys;
revoke read on sys.vw_x$aud_xs_actions from audsys;
revoke read on sys.dba_xs_audit_policy_options from audsys;

drop view sys.vw_x$aud_xs_actions;

Rem *************************************************************************
Rem END BUG 25245797
Rem *************************************************************************


Rem *************************************************************************
Rem Begin bug 26223818
Rem *************************************************************************
drop procedure remote_scheduler_agent.pingserver;
Rem *************************************************************************
Rem End bug 26223818
Rem *************************************************************************


Rem *************************************************************************
Rem Begin bug 25295968
Rem *************************************************************************
DROP TRIGGER sys.dbms_set_pdb;
Rem *************************************************************************
Rem End bug 25295968
Rem *************************************************************************

Rem *************************************************************************
Rem START Project 34974
Rem Clear KTSUCS1_NOAUTH bit. This bit will be set for users with no 
Rem authentication method.
Rem *************************************************************************

update user$ set spare1 = spare1 - 65536 where bitand (spare1,65536) = 65536;

Rem *************************************************************************
Rem END Project 34974
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Project 68493, DBMS_MEMOPTIMIZE, DBMS_MEMOPTIMIZE_ADMIN Changes
Rem *************************************************************************

DROP PUBLIC SYNONYM dbms_memoptimize;
DROP LIBRARY DBMS_MEMOPTIMIZE_LIB;
DROP PACKAGE SYS.DBMS_MEMOPTIMIZE;

DROP PUBLIC SYNONYM dbms_memoptimize_admin;
DROP LIBRARY DBMS_MEMOPTIMIZE_ADMIN_LIB;
DROP PACKAGE SYS.DBMS_MEMOPTIMIZE_ADMIN;

-- Update the tab$ property column bit to clear memoptimize flag

-- MEMOPTIMIZE FOR READ
UPDATE sys.tab$ t 
SET    t.property = t.property - power(2,91)
WHERE  BITAND(t.property, power(2,91)) = power(2,91);
COMMIT;

-- MEMOPTIMIZE FOR WRITE
UPDATE sys.tab$ t 
SET    t.property = t.property - power(2,92)
WHERE  BITAND(t.property, power(2,92)) = power(2,92);
COMMIT;

Rem *************************************************************************
Rem END Project 68493, DBMS_MEMOPTIMIZE Changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for project 67576
Rem *************************************************************************

ALTER AUDIT POLICY ora_secureconfig DROP ACTIONS ALTER DATABASE DICTIONARY
/
-- Bug 25512307
DROP PUBLIC SYNONYM DICTIONARY_CREDENTIALS_ENCRYPT;
DROP VIEW DICTIONARY_CREDENTIALS_ENCRYPT;

Rem *************************************************************************
Rem END changes for project 67576
Rem *************************************************************************
Rem *************************************************************************
Rem BEGIN Project 61375, *_PRIVATE_TEMP_TABLES changes
Rem *************************************************************************

DROP PUBLIC SYNONYM user_private_temp_tables;
DROP VIEW user_private_temp_tables;
DROP PUBLIC SYNONYM dba_private_temp_tables;
DROP VIEW dba_private_temp_tables;
DROP PUBLIC SYNONYM cdb_private_temp_tables;
DROP VIEW cdb_private_temp_tables;

Rem *************************************************************************
Rem END Project 61375, *_PRIVATE_TEMP_TABLES changes
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 27083755: truncate table that tracks sensitive fixed tables
Rem *************************************************************************

truncate table sensitive_fixed$;

Rem *************************************************************************
Rem Bug 27083755: truncate table that tracks sensitive fixed tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for lockdown profile enhancement
Rem *************************************************************************

DELETE from sys.lockdown_prof$ WHERE status=5;
ALTER TABLE sys.lockdown_prof$ MODIFY ruletyp NOT NULL;
ALTER TABLE sys.lockdown_prof$ MODIFY ruletyp# NOT NULL;
ALTER TABLE sys.lockdown_prof$ MODIFY ruleval NOT NULL;
ALTER TABLE sys.lockdown_prof$ DROP COLUMN con_uid;
ALTER TABLE sys.lockdown_prof$ DROP COLUMN usertyp$;

Rem *************************************************************************
Rem END changes for lockdown profile enhancement
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN CDB changes
Rem *************************************************************************

truncate table pdb_snapshot$;
drop public synonym CDB_PDB_SNAPSHOTS;
drop view CDB_PDB_SNAPSHOTS;
drop public synonym DBA_PDB_SNAPSHOTS;
drop view DBA_PDB_SNAPSHOTS;

alter table container$ drop column tenant_id;
alter table container$ drop column snapint;

Rem
Rem Bug 27301308: Clear flags set by later versions
Rem
update container$ set flags = bitand(flags, 549755813887);
commit;

Rem *************************************************************************
Rem END CDB changes
Rem *************************************************************************

Rem *************************************************************************
Rem Begin PL/Scope ER 24622590
Rem *************************************************************************
alter table plscope_action$ drop column flags;
alter table plscope_action$ drop column exp1;
alter table plscope_action$ drop column exp2;
alter table plscope_action$ drop column decl_obj#;
drop index i_plscope_flags_action$;
drop index i_plscope_decl_action$;

Rem *************************************************************************
Rem End PL/Scope ER 24622590
Rem *************************************************************************

Rem *************************************************************************
Rem Changes for Automatic inmemory management (Project 68505)
Rem *************************************************************************

TRUNCATE TABLE SYS.ado_imparam$;
ALTER TABLE sys.ado_imtasks$ DROP COLUMN state;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN est_imsize;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN val;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN im_pop_state;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN state;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN imbytes;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN blocksinmem;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN datablocks;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare1;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare2;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare3;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare4;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare5;
ALTER TABLE sys.ado_imsegtaskdetails$ DROP COLUMN spare6;

DROP PUBLIC SYNONYM dba_inmemory_aimtasks; 
DROP VIEW sys.dba_inmemory_aimtasks;

DROP PUBLIC SYNONYM cdb_inmemory_aimtasks;
DROP VIEW sys.cdb_inmemory_aimtasks;

DROP PUBLIC SYNONYM dba_inmemory_aimtaskdetails;
DROP VIEW sys.dba_inmemory_aimtaskdetails;

DROP PUBLIC SYNONYM cdb_inmemory_aimtaskdetails;
DROP VIEW sys.cdb_inmemory_aimtaskdetails;

DROP VIEW sys."_INMEMORY_AIMTASKS";
DROP VIEW sys."_INMEMORY_AIMTASKDETAILS";
DROP VIEW sys."_SYS_AIM_SEG_HISTOGRAM";

Rem *************************************************************************
Rem END Changes for Automatic inmemory management (Project 68505)
Rem *************************************************************************



Rem ************************************************************************
Rem Resource Manager related changes - BEGIN
Rem ************************************************************************

-- Drop pq_timeout_action column only when going to 12.2.0.1 or lower.
DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '12.2.0.2' THEN 

    execute immediate 'alter table resource_plan_directive$ ' ||
                      'drop column pq_timeout_action';
  END IF;
END;
/


Rem ************************************************************************
Rem Resource Manager related changes - END
Rem ************************************************************************

Rem *************************************************************************
Rem BEGIN Join group catalog changes
Rem *************************************************************************

alter table im_domain$ drop constraint im_domain_fk;
alter table im_domain$ drop constraint im_domain_uk;

alter table im_joingroup$ drop constraint im_joingroup_uk;
alter table im_joingroup$ drop constraint im_joingroup_pk;

Rem *************************************************************************
Rem END Join group catalog changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for [G]V$IM_SMU_DELTA
Rem *************************************************************************

drop public synonym gv$im_smu_delta;
drop view gv_$im_smu_delta;
drop public synonym v$im_smu_delta;
drop view v_$im_smu_delta;

Rem *************************************************************************
Rem END Changes for [G]V$IM_SMU_DELTA
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for [G]V$IM_DELTA_HEADER
Rem *************************************************************************

drop public synonym gv$im_delta_header;
drop view gv_$im_delta_header;
drop public synonym v$im_delta_header;
drop view v_$im_delta_header;

Rem *************************************************************************
Rem END Changes for [G]V$IM_DELTA_HEADER
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Changes for PDB events framework.
Rem =======================================================================

drop type pdb_mon_event_type$;

Rem =======================================================================
Rem END Changes for PDB events framework.
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN Bug 24737763: Data Mining FIC Table function rewrite
Rem *************************************************************************
drop type ora_fi_RImp_t;
drop type fi_categoricals;
drop type fi_numericals;
drop type itemsets;
drop type itemset;
drop type ora_fi_t;

Rem *************************************************************************
Rem END Bug 24737763: Data Mining FIC Table function rewrite
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN 12.2 Project: Data Mining Algorithm Registration
Rem *************************************************************************

drop view all_mining_algorithms;
drop public synonym all_mining_algorithms;
drop table modelalg$;
drop sequence modelalg_seq$;

Rem *************************************************************************
Rem END 12.2 Project: Data Mining Algorithm Registration
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 23753068: revoke read, grant select to AUDIT_ADMIN
Rem *************************************************************************

revoke read on DBA_OBJECTS from AUDIT_ADMIN;
revoke read on DBA_OBJECTS_AE from AUDIT_ADMIN;
revoke read on DBA_USERS from AUDIT_ADMIN;
revoke read on DBA_ROLES from AUDIT_ADMIN;
revoke read on SYS.CDB_ROLES from AUDIT_ADMIN;
grant select on DBA_OBJECTS to AUDIT_ADMIN;
grant select on DBA_OBJECTS_AE to AUDIT_ADMIN;
grant select on DBA_USERS to AUDIT_ADMIN;
grant select on DBA_ROLES to AUDIT_ADMIN;
grant select on SYS.CDB_ROLES to AUDIT_ADMIN;

Rem *************************************************************************
Rem END Bug 23753068: revoke read, grant select to AUDIT_ADMIN
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Project 70435 changes
Rem *************************************************************************

ALTER TABLE SYS.WRI$_ADV_EXECUTIONS DROP COLUMN REQ_DOP;
ALTER TABLE SYS.WRI$_ADV_EXECUTIONS DROP COLUMN ACTUAL_DOP;

Rem *************************************************************************
Rem END Project 70435 changes
Rem *************************************************************************

Rem**************************************************************************
Rem BEGIN BUG 25600289: DWCS enhancements for Credentials
Rem**************************************************************************

alter table scheduler$_credential drop column key;

Rem**************************************************************************
Rem END BUG 25600289: DWCS enhancements for Credentials
Rem**************************************************************************

Rem**************************************************************************
Rem BEGIN RTI 20164707 Drop function DBMS_PDB_IS_VALID_PATH
Rem *************************************************************************

DROP FUNCTION DBMS_PDB_IS_VALID_PATH;
DROP PUBLIC SYNONYM DBMS_PDB_IS_VALID_PATH;

Rem *************************************************************************
Rem END RTI 20164707
Rem**************************************************************************

Rem**************************************************************************
Rem BEGIN #(25463265) Drop SQT_* views 
Rem *************************************************************************
drop public synonym SQT_TAB_STATISTICS;
drop view SQT_TAB_STATISTICS;

drop public synonym SQT_TAB_COL_STATISTICS;
drop view SQT_TAB_COL_STATISTICS;

drop public synonym SQT_CORRECT_BIT;
drop view SQT_CORRECT_BIT;

Rem *************************************************************************
Rem Begin Scheduler changes
Rem *************************************************************************

-- BUG 25422950: Drop new package
DROP PACKAGE sys.dbms_ischedfw;

-- Bug 25992935 : drop dbms_isched_agent
drop package sys.dbms_isched_agent;

-- Bug 25992938 : drop dbms_isched_utl
drop package sys.dbms_isched_utl;

Rem *************************************************************************
Rem END Scheduler changes
Rem *************************************************************************

Rem *************************************************************************
Rem  Insert the new EXEMPT DML REDACTION POLICY system privilege.
Rem  Insert the new EXEMPT DDL REDACTION POLICY system privilege.
Rem  BEGIN BUG 23012504 - REMOVE EXEMPT DML REDACTION POLICY AND 
Rem  EXEMPT DDL REDACTION POLICY PRIVILEGES
Rem  RTI 20292031 - catch ORA-1
Rem *************************************************************************

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values
    (-391, 'EXEMPT DML REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values
    (-392, 'EXEMPT DDL REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values
    (391, 'EXEMPT DML REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values
    (392, 'EXEMPT DDL REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

commit;

Rem *************************************************************************
Rem END BUG 23012504
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25486808 changes
Rem *************************************************************************

drop public synonym gv$aq_ipc_active_msgs;
drop view gv_$aq_ipc_active_msgs;
drop public synonym v$aq_ipc_active_msgs;
drop view v_$aq_ipc_active_msgs;

drop public synonym gv$aq_ipc_pending_msgs;
drop view gv_$aq_ipc_pending_msgs;
drop public synonym v$aq_ipc_pending_msgs;
drop view v_$aq_ipc_pending_msgs;

drop public synonym gv$aq_ipc_msg_stats;
drop view gv_$aq_ipc_msg_stats;
drop public synonym v$aq_ipc_msg_stats;
drop view v_$aq_ipc_msg_stats;

Rem *************************************************************************
Rem END Bug 25486808 changes
Rem *************************************************************************
Rem *************************************************************************
Rem BEGIN Bug 26259599 changes, during upgrade select priv replaced with read
Rem *************************************************************************
BEGIN
  execute immediate
          'REVOKE READ ON SYS.USER_QUEUE_SCHEDULES '||
          ' FROM PUBLIC' ;
  EXCEPTION WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
execute immediate
        'GRANT SELECT ON SYS.USER_QUEUE_SCHEDULES to '||
        'PUBLIC with grant option' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/

Rem *************************************************************************
Rem end Bug 26259599 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25713423 changes
Rem *************************************************************************

drop public synonym gv$lockdown_rules;
drop view gv_$lockdown_rules;
drop public synonym v$lockdown_rules;
drop view v_$lockdown_rules;

Rem *************************************************************************
Rem END Bug 25713423 changes
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
              ' USAGE NONE';
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


Rem *************************************************************************
Rem BEGIN BUG 25410917 changes
Rem *************************************************************************
drop package sys.dbms_rat_mask_internal;
Rem *************************************************************************
Rem END BUG 25410917 changes
Rem *************************************************************************

Rem *************************************************************************
REM BEGIN BUG 25410921 outln_pkg_internal (security)
Rem *************************************************************************

DROP PUBLIC SYNONYM dbms_outln_internal;
DROP PACKAGE SYS.OUTLN_PKG_INTERNAL;

Rem *************************************************************************
REM END BUG 25410921 outln_pkg_internal (security)
Rem *************************************************************************

Rem *************************************************************************
REM BEGIN BUG 25773902 get_application_diff
Rem *************************************************************************

DROP FUNCTION GET_APPLICATION_DIFF;

Rem *************************************************************************
REM END BUG 25773902
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 25493529 Drop [g]v$sql_shard views and synonyms
Rem *************************************************************************

drop public synonym gv$sql_shard;
drop view gv_$sql_shard;
drop public synonym v$sql_shard;
drop view v_$sql_shard;
Rem *************************************************************************
Rem END BUG 25493529
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25766353 changes
Rem *************************************************************************

drop public synonym gv$java_services;
drop view gv_$java_services;
drop public synonym v$java_services;
drop view v_$java_services;

Rem *************************************************************************
Rem END Bug 25766353 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN #(25369636)
Rem *************************************************************************

DROP PUBLIC SYNONYM RAWCTAB;
DROP TYPE RAWCTAB;
DROP PUBLIC SYNONYM RAWCREC;
DROP TYPE RAWCREC;

DROP PUBLIC SYNONYM COLHISTTAB;
DROP TYPE COLHISTTAB;
DROP PUBLIC SYNONYM COLHISTREC;
DROP TYPE COLHISTREC;

Rem *************************************************************************
Rem END #(25369636)
Rem *************************************************************************
Rem *************************************************************************
Rem BEGIN #(25956410) clear ruleset compiled data
Rem *************************************************************************
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

Rem *************************************************************************
Rem BEGIN Bug 25942886 changes
Rem *************************************************************************

drop public synonym gv$java_patching_status;
drop view gv_$java_patching_status;
drop public synonym v$java_patching_status;
drop view v_$java_patching_status;

Rem *************************************************************************
Rem END Bug 25942886 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 24966761 changes
Rem *************************************************************************

DROP PUBLIC SYNONYM dbms_sqlset;
DROP PACKAGE dbms_sqlset;

Rem *************************************************************************
Rem END Bug 24966761 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25856821 changes
Rem *************************************************************************
drop public synonym dbms_ash;
drop package dbms_ash;
Rem *************************************************************************
Rem END Bug 25856821 changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 25684134 Drop OLAP objects that may be invalid
Rem *************************************************************************

Rem If we are downgrading to a version of the db that does not have the
Rem OLAP option enabled, the following objects turn up invalid.  They
Rem would get redefined if OLAP were to be added later.

DROP PUBLIC SYNONYM ALL_AW_AC;
DROP VIEW SYS.ALL_AW_AC;
DROP PUBLIC SYNONYM ALL_AW_AC_10G;
DROP VIEW SYS.ALL_AW_AC_10G;
DROP PUBLIC SYNONYM ALL_AW_OBJ;
DROP VIEW SYS.ALL_AW_OBJ;
DROP PUBLIC SYNONYM ALL_AW_PROP;
DROP VIEW SYS.ALL_AW_PROP;
DROP PUBLIC SYNONYM ALL_AW_PROP_NAME;
DROP VIEW SYS.ALL_AW_PROP_NAME;
DROP PACKAGE SYS.DBMS_CUBE;
DROP PUBLIC SYNONYM DBMS_CUBE;
DROP PACKAGE SYS.DBMS_CUBE_ADVISE;
DROP PUBLIC SYNONYM DBMS_CUBE_ADVISE;
DROP PACKAGE SYS.DBMS_CUBE_EXP;
DROP PUBLIC SYNONYM DBMS_CUBE_EXP;
DROP PACKAGE SYS.DBMS_CUBE_UTIL;
DROP PUBLIC SYNONYM DBMS_CUBE_UTIL;
DROP PACKAGE SYS.DBMS_CUBE_ADVISE_SEC;

Rem *************************************************************************
Rem END BUG 25684134 Drop OLAP objects that may be invalid
Rem *************************************************************************

Rem *************************************************************************
REM BEGIN BUG 23598405 drop dbms_xds_int (internal package)
Rem *************************************************************************

DROP PACKAGE SYS.DBMS_XDS_INT;

Rem *************************************************************************
REM END BUG 23598405 drop dbms_xds_int (internal package)
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 26040105: UPDATE ORA_CIS_RECOMMENDATIONS AUDIT POLICY
Rem *************************************************************************

ALTER AUDIT POLICY ORA_CIS_RECOMMENDATIONS 
ADD PRIVILEGES 
CREATE ANY LIBRARY, DROP ANY LIBRARY, CREATE ANY TRIGGER,
ALTER ANY TRIGGER, DROP ANY TRIGGER 
DROP ACTIONS 
ALTER SYNONYM, 
CREATE FUNCTION, CREATE PACKAGE, CREATE PACKAGE BODY, ALTER FUNCTION, 
ALTER PACKAGE, ALTER SYSTEM, ALTER PACKAGE BODY, DROP FUNCTION,
DROP PACKAGE, DROP PACKAGE BODY, CREATE TRIGGER, ALTER TRIGGER,
DROP TRIGGER
/

Rem *************************************************************************
Rem END BUG 26040105: UPDATE ORA_CIS_RECOMMENDATIONS AUDIT POLICY
Rem *************************************************************************

commit;


Rem *************************************************************************
Rem END #(25956410)
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 22666352 mlog$
Rem *************************************************************************
-- bug 22666352: change the type of mlog$.partdobj#
UPDATE SYS.MLOG$ SET PARTDOBJ# = NULL;
COMMIT;
ALTER TABLE SYS.MLOG$ MODIFY PARTDOBJ# NUMBER;
Rem *************************************************************************
Rem END bug 22666352 mlog$
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for bug 13954475
Rem *************************************************************************

DROP PROCEDURE SYS.DBMS_FEATURE_VPD;

Rem *************************************************************************
Rem END bug 13954475
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25927752: revoke/grant privs to sysumf_role 
Rem *************************************************************************

revoke ADVISOR from sysumf_role;
revoke ADMINISTER SQL MANAGEMENT OBJECT from sysumf_role;

grant execute on dbms_sqltune_internal to sysumf_role;

Rem *************************************************************************
Rem END  Bug 25927752: revoke/grant privs to sysumf_role  
Rem *************************************************************************

Rem *************************************************************************
REM BEGIN proj 54799 dbms_stats_internal_agg
Rem *************************************************************************

DROP PUBLIC SYNONYM dbms_stats_internal_agg;
DROP PACKAGE SYS.DBMS_STATS_INTERNAL_AGG;

Rem *************************************************************************
REM END proj 54799 dbms_stats_internal_agg
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Planned Maintenance
Rem *************************************************************************

truncate table connection_tests$;
drop public synonym CDB_CONNECTION_TESTS;
drop view CDB_CONNECTION_TESTS;
drop public synonym DBA_CONNECTION_TESTS;
drop view DBA_CONNECTION_TESTS;

Rem *************************************************************************
Rem END Planned Maintenance changes
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN BUG 25862910
Rem
Rem Remove cursor duration types since they are now not persistable.
Rem *************************************************************************

declare
   cursor c1 is
     select u.name, o.name
     from sys.type$ t, sys.obj$ o, sys.user$ u
     where o.type# = 13                                   /* type# = TYPE */
           and bitand(t.properties,8388608) = 8388608  /* Cursor duration */
           and o.oid$ = t.tvoid                /* Type's versioned obj id */ 
           and o.subname is null                        /* Latest version */
           and o.owner# = u.user#                /* Join clause for user$ */
           and o.name like 'ST%';           /* Name prefix before 12.1 */
   type_owner   varchar2(128);
   type_name    varchar2(128);
begin
   -- Drop cursor duration types
   open c1;
   loop
     fetch c1 into type_owner, type_name;
     exit when c1%NOTFOUND;
     begin
       EXECUTE IMMEDIATE 'drop type "' || type_owner || '"."' ||
                         type_name || '" force';
     exception
       when others then
         null;
     end;
   end loop;
   close c1;
exception
   when others then
     null;
end;
/

Rem *************************************************************************
Rem END BUG 25862910
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 21587462 : Delete users for Oracle Hospitality Simphony
Rem
Rem  Inserts to SYS.DEFAULT_PWD$ wont have to be deleted in e* downgrade
Rem  scripts once 11.2.0.X is no longer supported for downgrade 
Rem *************************************************************************

delete from SYS.DEFAULT_PWD$  where user_name = 'MICROS' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'MICROSDB' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'MCRSCACHE' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'SIMADMIN' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'UTIL' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'AGGREGATE_DB' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'BIREPOS' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'COREDB' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'LOCATION_ACTIVITY_DB' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'PORTAL_DB' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'QUARTZ' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'RTA' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'BLITZ' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'SYS' and product = 'ORACLE HOSPITALITY SIMPHONY';
delete from SYS.DEFAULT_PWD$  where user_name = 'SYSTEM' and product = 'ORACLE HOSPITALITY SIMPHONY';

Rem Following changes are made due to changes in catdef.sql to replace 10g 
Rem verifier with SHA-1 value
 
Rem *************************************************************************
Rem BEGIN Bug 26289288: Persistent state of Private Temp Table(PTT) feature
Rem *************************************************************************

TRUNCATE TABLE ptt_feature$;

Rem *************************************************************************
Rem END Bug 26289288
Rem *************************************************************************

delete from SYS.DEFAULT_PWD$  where user_name = 'SYS' and pwd_verifier = 'CDCDF63019576031CF6BFEBC22DA1A2362DF97FA';
insert into SYS.DEFAULT_PWD$(user_name, pwd_verifier)
values('SYS', '089509EC42EF6C07');

Rem *************************************************************************
Rem END BUG 21587462 : Delete users for Oracle Hospitality Simphony
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for bug 25900939 
Rem *************************************************************************

drop public synonym gv$asm_audit_load_jobs;
drop view gv_$asm_audit_load_jobs;
drop public synonym v$asm_audit_load_jobs;
drop view v_$asm_audit_load_jobs;

Rem *************************************************************************
Rem END bug 25900939 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 26255427: Drop new registry$ columns and package
Rem *************************************************************************

ALTER TABLE sys.registry$ DROP COLUMN version_full;
ALTER TABLE sys.registry$ DROP COLUMN org_version_full;
ALTER TABLE sys.registry$ DROP COLUMN prv_version_full;
ALTER TABLE sys.registry$ DROP COLUMN banner_full;

DROP PACKAGE sys.dbms_registry_extended;

Rem *************************************************************************
Rem END Bug 26255427: Drop new registry$ columns
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 26654326: drop DBMS_PDB_APP_CON
Rem *************************************************************************

drop public synonym dbms_pdb_app_con;
drop package sys.dbms_pdb_app_con;

Rem *************************************************************************
Rem END Bug 26654326
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for bug 26572993 
Rem *************************************************************************

drop public synonym gv$memoptimize_write_area;
drop view gv_$memoptimize_write_area;
drop public synonym v$memoptimize_write_area;
drop view v_$memoptimize_write_area;

Rem *************************************************************************
Rem END bug 26572993 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25988806: drop function DBMS_PDB_CHECK_LOCKDOWN
Rem *************************************************************************

DROP FUNCTION DBMS_PDB_CHECK_LOCKDOWN;
DROP PUBLIC SYNONYM DBMS_PDB_CHECK_LOCKDOWN;

Rem *************************************************************************
Rem END Bug 25988806
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 25115388: Drop view INT$DATA_LINK_TAB_STATISTICS
Rem *************************************************************************

drop view INT$DATA_LINK_TAB_STATISTICS;

Rem *************************************************************************
Rem END Bug 25115388	
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN  Bug 26712379: drop columns in wri$_adv_sqlt_plan_stats
Rem *************************************************************************

ALTER TABLE sys.wri$_adv_sqlt_plan_stats drop column CACHED_GETS;
ALTER TABLE sys.wri$_adv_sqlt_plan_stats drop column DIRECT_GETS;

Rem *************************************************************************
Rem END  Bug 26712379
Rem *************************************************************************
Rem ====================================================================
Rem Begin bug 26150401: revoke insert on finalhist$ from public
Rem ====================================================================

revoke insert on finalhist$ from public;

Rem ====================================================================
Rem End bug 26150401
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN BUG 26711492 - drop DBMS_SQLTCB_LIB
Rem *************************************************************************

DROP LIBRARY DBMS_SQLTCB_LIB;

Rem *************************************************************************
Rem END BUG 26711492
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 26081503: delete attribute 5 in SYS.ILM_CONCURRENCY$
Rem *************************************************************************

delete from SYS.ILM_CONCURRENCY$ where attribute= 5;
commit;

Rem *************************************************************************
Rem End bug 26081503
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 25453685 changes 
Rem *************************************************************************

drop table SYS.KU$_SHARD_DOMIDX_NAMEMAP;

Rem *************************************************************************
Rem END BUG 25453685 changes
Rem *************************************************************************


Rem ====================================================================
Rem Begin Bug 21563855
Rem ====================================================================

alter table fed$app$status drop column flag;

Rem ====================================================================
Rem End Bug 21563855
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN LRG 20621949 changes 
Rem
Rem Drop the text after and including the last '#' - this is the collation id 
Rem introduced in wesmith_bug-26807415. Since this field is not present in 
Rem prior versions, it has to be removed. The collation-id is the seventh
Rem field, and the fields are separated by a '#' sign; so we remove 
Rem the last field only if there are seven fields present.
Rem
Rem *************************************************************************

update sys.sumkey$ set spare3 = substr(spare3, 1, instr(spare3, '#', -1) - 1)
  where regexp_count(spare3, '#') = 6;
update sys.sumkey$ set spare2 = length(spare3);
commit;

Rem *************************************************************************
Rem END LRG 20621949 changes 
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN HEAT MAP changes for AIM 
Rem *************************************************************************

Rem Bug 27119186: Default value of flag column in sys.heat_map_stat$ is 
Rem 0 starting 18.1. bitand(flag, 1) = 1 represents rows that were tracked 
Rem when heat map was off, so these rows must be deleted on downgrade.

delete sys.heat_map_stat$ where obj# != -1 and bitand(flag, 1) = 1;

Rem Revert flag value to null for regular heat map rows (obj# != -1)
update sys.heat_map_stat$ set flag = null where obj# != -1;
commit;

alter table sys.heat_map_stat$ modify flag default NULL;

drop public synonym v$imhmseg;
drop view v_$imhmseg;

drop public synonym gv$imhmseg;
drop view gv_$imhmseg;


Rem *************************************************************************
Rem END HEAT MAP changes for AIM 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 27057144: drop DATAPUMP_DIR_OBJS
Rem *************************************************************************

drop public synonym DATAPUMP_DIR_OBJS;

Rem *************************************************************************
Rem END Bug 27057144
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 27126506: drop private synonym DATAPUMP_DIR_OBJS
Rem *************************************************************************

drop synonym DATAPUMP_DIR_OBJS;

Rem *************************************************************************
Rem END Bug  27126506
Rem *************************************************************************

Rem ====================================================================
Rem Begin Bug 26965236
Rem ====================================================================

-- Make sure we clear the tab$ property indicating that existing tables
-- have sensitive columns.
-- tab$ property (KQLDTVCP3_HAS_SENS_COL, 
-- decimal value: 618970019642690137449562112, which is: power(2,89))
update sys.tab$ set property = property - bitand(property, power(2,89))
where bitand(property, power(2,89)) = power(2,89);
commit;

Rem ====================================================================
Rem End Bug 26965236
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN Bug 27941896: drop dbms_optim_bundle objects
Rem *************************************************************************

drop package sys.dbms_optim_bundle;
drop type sys.dbms_optim_fcTabType;
drop type sys.dbms_optim_bugValObType;

Rem *************************************************************************
Rem END Bug 27941896
Rem *************************************************************************

---------- ADD DOWNGRADE ACTIONS ABOVE THIS LINE ---------------
----- ADD ACTIONS USING VIEWS OR PACKAGES TO f1202000.sql ------

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary to 12.2.0
Rem =========================================================================

Rem *************************************************************************
Rem END   e1202000.sql
Rem *************************************************************************

