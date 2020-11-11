Rem $Header: rdbms/admin/e1201000.sql /st_rdbms_18.0/1 2017/12/09 17:20:14 alui Exp $
Rem
Rem e1201000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      e1201000.sql - downgrade Oracle to 12.1
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
Rem      downgrade the data dictionary to the origin release.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      * The database must be open in UPGRADE mode/DOWNGRADE mode.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/e1201000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/e1201000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alui       12/08/17 - bug 27233903: remove alter user for appqossys
Rem    alestrel   09/10/17 - Bug 25992938. Drop AUTO_SQL_TUNING_PROG in f file
Rem    bwright    07/17/17 - Bug 25651930: consolidate Data Pump scripts
Rem    achatzis   05/22/17 - Bug 25527953: Move flag KTT_HDFS.
Rem    bhammers   04/07/17 - Rti 20220499: drop INT$DBA_JSON_... views
Rem    raeburns   03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE 
Rem    akanagra   03/05/17 - lrg 20151722: remove G[V]$AQ_IPC_*_MSGS
Rem    jekamp     02/22/17 - RTI 20087837: fix DBMS_FEATURE_IM_FORSERVICE
Rem    akanagra   02/01/17 - Bug 25486808: drop G[V]$AQ_IPC_*_MSGS
Rem    raeburns   01/22/17 - Bug 25337332: Correct signature issues with drop
Rem                          column
Rem    lvbcheng   12/07/16 - bug 25165896: noexp$ del ahead of data link conv 
Rem    shvmalik   11/27/16 - #25035608: revert back FCP txn
Rem    bhammers   11/03.16 - bug 24969019: drop JSON_KEY_LIST
Rem    hosu       10/26/16 - 24598595: downgrade action
Rem    sdball     11/04/16 - Drop container_database
Rem    sdball     09/28/16 - RTI 19784095: drop table catalog_requests
Rem    pyam       09/22/16 - Fwd merge bug 24422028
Rem    lenovak    09/21/16 - lrg 19765817: drop exchange  on downgrade
Rem    mthiyaga   09/14/16 - Drop DBMSHADOOPLIB
Rem    skabraha   09/12/16 - drop migrate_80sysimages_to_81
Rem    pyam       09/09/16 - Bug 24617642: public synonyms do not exist in
Rem                          12.1.0.2
Rem    dgagne     09/09/16 - drop TTS types - bug 24605972
Rem    dmaniyan   09/09/16 - Drop DBMS_FEATURE_SHARD procedure
Rem    sroesch    09/09/16 - Bug 24617765: Add back drop statements from
Rem                          failed merge                             
Rem    mstasiew   09/09/16 - Bug 24617798: drop hcs INT$ views
Rem    bymotta    09/09/16 - BUG 24617717: DBMS_REGISTRY_EXTENDED invalid after
Rem                          downgrade, adding a drop of the package. parent
Rem                          Bug #: 18301889
Rem    dcolello   09/08/16 - bug 24618374: drop dbms_gsm_xdb on downgrade
Rem    pyam       09/08/16 - Bug 24617642: fix CDB_FLASHBACK_TXN%
Rem    almurphy   09/06/16 - Drop HCS INT$DBA_XXX views
Rem    amylavar   09/02/16 - Drop DBMS_FEATURE_IM_FORSERVICE
Rem    aumishra   09/01/16 - Drop procedure for IME feature tracking
Rem    pyam       08/31/16 - Bug 24422028: drop session_pga_limit on
Rem                          dwn->12.1.0.2
Rem    amylavar   08/30/16 - Drop DBMS_FEATURE_IM_JOINGROUPS
Rem    yingzhen   08/22/16 - Set cdb_root_dbid default value null
Rem    prakumar   08/18/16 - XbranchMerge prakumar_bug-23525741_v12201 from
Rem                          st_rdbms_12.2.0.1.0
Rem    yanlili    08/03/16 - Bug 23715409: fix delete privilege 
Rem                          SET_DYNAMIC_ROLES and APPLY_SEC_POLICY
Rem    pyam       08/03/16 - RTI 19634111: convert NOEXP\$\/etc back to data
Rem                          links
Rem    rmorant    08/02/16 - bug24381876 drop necesary objects
Rem    wbattist   08/01/16 - bug 24369603 - add drop public synonym for
Rem    prakumar   07/27/16 - Bug 23525741: Drop package, DBMS_SNAPSHOT_KKXRCA
Rem                          DBA_HANG_MANAGER_PARAMETERS
Rem    aanverma   07/24/16 - XbranchMerge aanverma_bug-24289422 from main
Rem    aanverma   07/20/16 - Bug #24289422: Delete OADM users from default
Rem                          password list
Rem    jnunezg    07/18/16 - XbranchMerge jlingow_lrg-13651115 from main
Rem    sursridh   07/18/16 - XbranchMerge sursridh_bug-23733162 from main
Rem    drosash    07/13/16 - Bug 23598713: drop dbms_pclxutil_internal
Rem    sursridh   07/07/16 - Bug 23733162: Reset sensitive prop for pdb_sync$,
Rem                          pdb_create$ cols.
Rem    jlingow    07/01/16 - dropping SYS.SCHEDULER$NTFY_SVC_METRICS procedure
Rem    shvmalik   06/30/16 - #23721669: drop FCP tables, types and package
Rem    bidu       06/30/16 - bug 22597785: drop xs_data_security_util_int
Rem    dvekaria   06/29/16 - Bug 23604553: Fix ORA-22308 in upgrade from
Rem                          pre-12.1.
Rem    quotran    06/27/16 - Add cdb_root_dbid into wrm$_database_instance
Rem    akruglik   06/24/16 - Bug 22852060: if running in a non-CDB, update
Rem                          sysauth$ and objauth$ to clear bits indicating
Rem                          that a privilege is common
Rem    chinkris   06/23/16 - Bug 23541062: clear comp$ spare3 for selective cols
Rem    prakumar   06/22/16 - Bug 23568914
Rem    aanverma   06/21/16 - Bug 23515378: revoke read on audit views
Rem    dhdhshah   06/20/16 - Bug 17036448: drop dbms_heat_map_internal
Rem    frealvar   06/18/16 - RTI 19462491 drop package dbms_preup
Rem    itaranov   06/16/16 - bug 23548757: drop for exec_shard_ddl
Rem    kmorfoni   06/16/16 - Bug 22959310: Drop dbms_umf_private package
Rem    csperry    06/08/16 - fix bug-23335364: dbms_cube_advice_sec fix
Rem    mthiyaga   06/07/16 - Remove HIVE_URI$ references
Rem    jgiloni    06/03/16 - Add per-pdb wait histogram
Rem    rrungta    06/03/16 - bug23300354: update HWM and flags columns in
Rem                          pdb_spfile$
Rem    welin      06/02/16 - invoking subsequent release
Rem    rmorant    05/26/16 - lrg16942052 keep only the first 30 characters at
Rem                          object_name
Rem    thbaby     05/23/16 - Bug 21540980: drop view DBA_APP_PDB_STATUS
Rem    moreddy    05/19/16 - 23311482: rename [g]v$asm_split_mirror 
Rem    gravipat   05/17/16 - Bug 23104651: add postplugscn to container$
Rem    kmorfoni   05/17/16 - Bug 23279437: remove con_id from AWR tables
Rem    thbaby     05/11/16 - Bug 23254735: drop app columns from PROFNAME$
Rem    thoang     05/06/16 - Bug 23182556: drop dbms_xstream_auth_ivk synonym
Rem    yingzhen   05/05/16 - Bug 22151899: Add recovery progress for ADG
Rem    hlakshma   05/06/16 - Drop dbms_inmemory package (bug 22980084)
Rem    osuro      05/03/16 - add wrh$_con_system_event and its views
Rem    estperez   05/02/16 - bug-2639561 dwgrade from 12.1 to 12.1.0.2 indexes
Rem    aumishra   04/28/16 - Bug 23177430: Drop views for IME
Rem    svaziran   04/28/16 - bug 23192127: drop v$diag_pdb_space_mgmt
Rem    dblui      04/21/16 - Bug 23061990: defhscflags overlaps defimcflags
Rem    yberezin   03/31/16 - upgrade bug 22713655: sync up the schemas in the
Rem                          patch and in MAIN
Rem    dmaniyan   04/15/16 - Bug 22485421 : Drop ALL_CHUNKS table & constraint
Rem    jlingow    04/12/16 - bug-20425850: truncate scheduler$_listeneraddresses
Rem    kmorfoni   04/08/16 - Bug 23071193: Fix DBA_HIST_SQLBIND
Rem    moreddy    03/30/16 - Bug 22980610: drop [g]v$asm_split_mirror
Rem    jtomass    02/29/16 - 22911644: Drop procedure dbms_feature_acfs_encr
Rem    yuyzhang   03/31/16 - Bug 22532386: truncate table optstat_snapshot$ 
Rem                          and col FLAGS in table COL_USAGE$ on downgrade
Rem    lkaplan    03/30/16 - Bug 22133352
Rem    kmorfoni   03/22/16 - Bug 22978680: Drop AWRIV$_ROOT% views
Rem    mjaiswal   03/22/16 - rename (g)v$aq_opt_* synonyms
Rem    kmorfoni   03/21/16 - RTI 19353234: Fix for WRH$_PROCESS_MEM_SUMMARY_PK
Rem    anujgg     03/18/16 - Bug 20907094-Feature usage HCC conventional load
Rem    jmuller    12/07/15 - Fix bug 20559930: drop CDBView_internal on
Rem                          downgrade
Rem    akruglik   03/16/16 - LRG 19347428: turn off extended_data bit for all
Rem                          objects
Rem    dcolello   03/15/16 - bug 22875874: drop DBMS_GSM_FIX
Rem    jmuller    12/07/15 - Fix bug 20559930: drop CDBView_internal on
Rem                          downgrade
Rem    aumishra   03/10/16 - Bug 22287896 : Handle IME downgrade issues 
Rem    aumehend   03/10/16 - Bug 22657204: remove inmemory CUs from
Rem                          compression$ to ensure we do not take inmemory
Rem                          formats from 12.2 to 12.1
Rem    msakayed   03/10/16 - RTI #16412598: utilities feature tracking
Rem    sdball     03/09/16 - Remove ddl_sess_info on downgrade
Rem    pbollimp   03/09/16 - Bug 22897146: Rename FastStart v$view
Rem    drchoudh   03/08/16 - bug22367092: add svcobj_access$ table
Rem    prgaharw   03/04/16 - Proj 45958: Downgrade changes for new cols in ADO
Rem    yxie       03/04/16 - Bug 22531082: drop AWR_ROOT_SYSSTAT_ID
Rem    quotran    03/03/16 - Add cdb,edition,db_unique_name,database_role into
Rem                          wrm$_database_instance
Rem    rajeekku   03/03/16 - Bug 22872956: Inherit Remote Privileges changes
Rem    ardesai    03/01/16 - Set con_id column of awr tables to default
Rem    tchorma    02/29/16 - bug 22674912 - drop new OGG view on downgrade
Rem    akruglik   02/29/16 - Bug 22777253: remove code dropping int$container$
Rem    ddas       02/26/16 - RTI 18916476: drop datapump views
Rem    akruglik   02/25/16 - Bug 22132084: get rid of COMMON_DATA
Rem    osuro      02/24/16 - bug 22741414: drop awr package dependent views 
Rem    osuro      02/23/16 - bug 22564419: drop INT$DBA_HIST_PDB_IN_SNAP
Rem    osuro      02/23/16 - bug 22515811: drop AWR_PDB_CON_SYSSTAT
Rem    osuro      02/23/16 - bug 22539348: wrh$_dyn_remaster_stats_pk modified
Rem                          when downgrading to 12.1.0.2
Rem    aanverma   02/22/16 - Bug #22552142: drop STIG compliant function
Rem    rpang      02/22/16 - Bug 22806411: rename debuggable session views
Rem    gravipat   02/18/16 - Bug 21858478: Drop column blks from cdb_file$
Rem    dcolello   02/17/16 - bug 22743674: add svcusercredential
Rem    jomcdon    02/16/16 - bug 22318009: fix import from 11.2
Rem    jmuller    12/07/15 - Fix bug 20559930: drop CDBView_internal on
Rem                          downgrade
Rem    dongfwan   02/16/16 - bug 22548290: drop synonym v$diag_log_ext
Rem                          and view v_$diag_log_ext
Rem    osuro      02/12/16 - bug 22698283: Remove AWR WR_SETTINGS table/views
Rem    sroesch    02/12/16 - bug 22558380: remove dbms_tg_dbg package
Rem    drosash    02/09/16 - Bug 22271488: Delete DBA_TEMP_FREE_SPACE_INSTANCE
Rem                          operations 
Rem    sdball     02/05/16 - Bug 22501277: Remove profile gsm_prof
Rem    sankejai   02/05/16 - Bug 22622072: truncate cdb_props$
Rem    dvoss      02/04/16 - bug 22523590: recreate logmnrg_dictionary$ and
Rem                          logmnrg_container$
Rem    skayoor    02/03/16 - Bug 21814782: Grant SELECT privilege
Rem    yingzhen   02/02/16 - Bug 20421055, remove CDBR_HIST, CDBP_HIST views
Rem                          Create CDB_HIST views on top of AWR_PDB views
Rem                        - Bug 22524938, reset view_location on downgrade
Rem    pbollimp   02/01/16 - Bug 22542589: FastStart v$view support
Rem    mstasiew   02/01/16 - rti 19246529: drop xxx_analytic_view_attr_class
Rem    sdball     01/29/16 - LRG 14836802: drop sha_databases on downgrade
Rem    thbaby     01/26/16 - bug 22332196: drop views INT$DBA_VIEWS_AE, 
Rem                          INT$DBA_SOURCE_AE
Rem    schakkap   01/26/16 - #(20413540) truncate opt_sqlstat$
Rem    jtomass    01/06/16 - bug 22498132: drop procedure
Rem                          dbms_feature_acfs_snapshot
Rem    amunnoli   01/26/16 - Bug 22515748:Do not reset the audit trail column
Rem                          CURRENT_USER on downgrade from 12.2 DB
Rem    joalvizo   01/25/16 - LRG 19083153: clear col$ bit KQLDCOP2_HLOB
Rem    ssonawan   01/22/16 - bug 22523319: drop INT$DBA_CONTEXT view
Rem    kdnguyen   01/21/16 - Bug 22542622 - FS: FEATURE TRACKING
Rem    amylavar   01/21/16 - Bug 22568831: Drop join group views
Rem    yanlili    01/20/16 - Fix bug 22558274: Drop DBMS_RLS_INT package on
Rem                          downgrading from 12.2 DB
Rem    sdipirro   01/20/16 - Drop dbms_datapump_int for downgrade
Rem    atomar     01/19/16 - bug 22558164 drop DBMS_AQADM_VAR
Rem    amunnoli   01/16/16 - Bug 22537605:re-create index on dam_last_arch_ts$
Rem    thbaby     01/15/16 - Bug 20683085: clear col$ bit KQLDCOP2_XSLB
Rem    yanxie     01/13/16 - bug 22531564: reset flag4 in snap$
Rem    ssubrama   01/12/16 - bug 22515411 shard_map table
Rem    yanlili    01/12/16 - Fix bug 22531758: Drop ALL_XS_SECURITY_CLASS_DEP
Rem                          view
Rem    tltang     01/12/16 - Bug 22524193 remove redact_ex and synonym
Rem    qinwu      01/11/16 - bug 18779084: remove sharing views
Rem    yapli      01/11/16 - Bug 22523826: set run_seq# column to NULL
Rem    rdecker    01/11/16 - lrg 18678715: drop INT$DBA_STATEMENTS on downgrade 
Rem    shjoshi    01/11/16 - bug 22525115: set last_exec_start_time to null
Rem    gravipat   01/11/16 - 22516659: drop undoscn column from container$
Rem    mjangir    01/11/16 - bug 22522970: drop view imprbs
Rem    rpang      01/11/16 - LRG 18947646: rename debuggable sessions views
Rem    mthiyaga   01/08/16 - Bug 22516996
Rem    nkedlaya   01/07/16 - bug 21962893: truncate the ofsftab table
Rem    youyang    01/06/16 - lrg18812187:PA downgrade to 12.1.0.2
Rem    qinwan     12/31/15 - Bug 22350371 remove dmrq_config
Rem    svaziran   12/24/15 - 22468424: drop v$diag_pdb_problem
Rem    sumkumar   12/23/15 - Bug 22369990: Drop all out-of-the-box PVFs
Rem    thbaby     12/22/15 - Bug 22451720: drop [g]v_$proxy_pdb_targets
Rem    ralekra    12/18/15 - Drop ggsys user with gsmadmin_internal objects
Rem    akruglik   12/17/15 - LRG 18856828: drop DBMS_PDB_ALTER_SHARING
Rem    smesropi   12/15/15 - RTI 18856155: Fix incorrect HCS view names
Rem    sdball     12/15/15 - RTI 18856782: Drop execAsUser on downgrade
Rem    josmamar   12/14/15 - truncate WRR$_COMPONENT_TIMING
Rem    hosu       12/14/15 - 22239656: downgrade synopsis table from 12.2 to
Rem                          under
Rem    sdball     12/11/15 - Remove redundant fields from database_dsc_t
Rem    chengl     12/10/15 - #20640156 add col_flag to coldictrec
Rem    rpang      12/09/15 - Bug 22325328: audit debug object privilege
Rem    rpang      12/04/15 - Bug 22275536: remove DEBUG CONNECT action
Rem    jlingow    12/04/15 - Add again "with grant option" to scheduler views
Rem    sjanardh   11/25/15 - Move downgrade queue table for long identifiers 
Rem                          to f1201000.sql
Rem    pyam       11/22/15 - 22282825: remove fed$statements
Rem    tchorma    12/03/15 - bug 20395746 - drop new ogg support views
Rem    yulcho     12/02/15 - drop dbms_disrupt package
Rem    rpang      12/01/15 - Bug 22294806: remove DEBUG CONNECT USER sys priv
Rem                          and DEBUG CONNECT user priv
Rem    qinwu      11/30/15 - Bug 22183065: set connect_time_auto_correct null
Rem    pyam       11/30/15 - extra pdb_sync$ columns
Rem    sjanardh   11/25/15 - Move downgrade queue table for long identifiers 
Rem                          to f1201000.sql
Rem    hlakshma   11/29/15 - Downgrade action for ADO DBIM tables
Rem    sjanardh   11/25/15 - Move downgrade queue table for long identifiers 
Rem                          to f1201000.sql
Rem    sankejai   11/25/15 - Bug 21947953: truncate pdb_stat$ and pdb_svc_stat$
Rem    sfeinste   11/25/15 - Bug 21542146: xxx_HIER_LEVEL_ID_ATTRS
Rem    lzheng     11/23/15 - Adding drop view for _DBA_STREAMS_UNSUPPORTED_12_2
Rem                          and _DBA_STREAMS_NEWLY_SUPTED_12_2
Rem    pyam       11/21/15 - 21911641: remove fed$sessions
Rem    aarvanit   11/20/15 - RTI #13227832: modify WRI$_SQLSET_PLAN_LINES
Rem                          column datatypes to match with staging table
Rem    vgerard    11/20/15 - add apply$_procedure_stats
Rem    alui       11/20/15 - drop wlm fixed views [g]v$wlm_db_mode
Rem    jorgrive   11/18/15 - Bug 22234530: streams$_rules,
Rem                          streams$_apply_spill_txn
Rem    rajeekku   11/18/15 - Bug 21795431: drop synonym dbms_tns
Rem    sogugupt   11/17/15 - drop dbms_master_table 
Rem    sursridh   11/12/15 - Truncate pdb_sync_stmt$.
Rem    smesropi   11/11/15 - Bug 21171628: Rename HCS views
Rem    rdecker    11/10/15 - truncate all plscope tables
Rem    huntran    11/09/15 - auto cdr conflict info
Rem    mstasiew   11/09/15 - Bug 21984764: hcs object rename
Rem    dkoppar    11/06/15 - #21143559 long identifier support
Rem    hmohanku   11/05/15 - bug 16574456: drop (G)V$PASSWORDFILE_INFO
Rem    atomar     11/05/15 - bug 21812965, drop SHARD_META_LIST
Rem    alestrel   11/03/15 - bug 22119906, drop types that are not created
Rem                          using force in older releases
Rem    josmamar   11/03/15 - bug 21874643: support query-only replay for non
Rem                          consolidated replay
Rem    yingzhen   10/30/15 - Bug 22101741: Set dba_hist to awr_root by default
Rem    arogers    10/27/15 - Drop [g]v_$gcr_status and [g]v_$gcr_log views
Rem    dcolello   10/19/15 - sharding object rename for production
Rem    yingzhen   10/12/15 - flush v$con_sysstat to wrh$_con_sysstat
Rem    zhcai      09/17/15 - proj 47332: add prvtemx_sql
Rem    osuro      10/18/15 - truncate wrh$_con_sysmetrics_history_bl
Rem    thbaby     10/14/15 - Bug 21971498: truncate table proxy_remote$
Rem    thbaby     10/10/15 - 21963357: drop sequence app$system$seq
Rem    kyagoub    10/02/15 - AWRRPT_INSTANCE_LIST_TYPE: drop type
Rem    svivian    10/01/15 - drop package dbms_logmnr_session_int
Rem    kyagoub    09/28/15 - bug21382425: drop type prvt_awrv_metadata
Rem    kyagoub    09/18/15 - em_express_all: removke resource manager admin
Rem    jtomass    08/25/15 - bug 21693658: drop procedure dbms_feature_acfs 
Rem    smangala   10/09/15 - bug 21192807: CDB non-unique xid
Rem    jlasagu    10/08/15 - ofsmtab$ change
Rem    shbose     10/06/15 - bug 21193221: drop eviction table from sharded
Rem                          queues
Rem    spapadom   10/06/15 - truncate table wrm$_active_pdbs.
Rem    alui       10/06/15 - drop objects in appqossys schema
Rem    thbaby     10/05/15 - 21841612: drop DBA_APP_VERSIONS
Rem    kyagoub    10/02/15 - AWRRPT_INSTANCE_LIST_TYPE: drop type
Rem    quotran     10/01/15 - bug 21903834: add schedule_cap_id column at
Rem                           WRR$_REPLAY_SCN_ORDER
Rem    kyagoub    09/28/15 - bug21382425: drop type prvt_awrv_metadata
Rem    hmohanku   09/28/15 - bug 21787568: DIRECTORY object audit changes
Rem    alestrel   09/25/15 - bug 21647288 : long id in RULE_NAME sys.scheduler
Rem                          _srcq_map
Rem    sdball     09/25/15 - drop shard context on downgrade
Rem    dkoppar    09/23/15 - #21052918 pending-act changes
Rem    kyagoub    09/18/15 - em_express_all: removke resource manager admin
Rem    jomcdon    09/18/15 - bug 21673793: implement v$rsrc_pdb(_history)
Rem    sudurai    09/17/15 - Bug 21805805: Encrypt NUMBER data type in 
Rem                          statistics tables. Changing DBMS_CRYPTO_STATS_INT 
Rem                          to DBMS_CRYPTO_INTERNAL
Rem    rajeekku   09/16/15 - bug 21845353: drop public synonyms on downgrade
Rem    quotran    09/16/15 - bug 20827740: fix dba_replay_client view name
Rem    jesugonz   09/15/15 - 21767687: add (G)V$ASM_QUOTAGROUP
Rem    svaziran   09/13/15 - bug 21819002: fix uts view name
Rem    kdnguyen   09/09/15 - Bug 20474610: down grade IMC FS (project 42357)
Rem    pyam       09/09/15 - bug 21757266: drop new DBA_ public synonyms
Rem    osuro      09/03/15 - add AWR CON_SYS_TIME_MODEL views
Rem    yberezin   09/03/15 - bug 21787780: length mismatch
Rem    yingzhen   08/31/15 - Change dba_hist view location for CDB
Rem    amunnoli   09/03/15 - bug 13716158:update audit trail current_user col
Rem    svaziran   09/02/15 - bug 21548817: drop synonym for uts fixed views
Rem    drosash    09/01/15 - Bug 21611780: Delete DBA_TEMP_FILES_INST ops
Rem    rpang      08/31/15 - 17169333: remove TRANSLATE SQL audit action
Rem    sylin      08/31/15 - bug 21571353: remove drop sys.schedule_job
Rem    bsprunt    08/26/15 - Bug 21652015: add instance_caging column
Rem    ssonawan   08/25/15 - bug 21427375: drop INT$AUDIT_UNIFIED% views
Rem    prshanth   08/24/15 - 21350392: drop some cdb_xml_% views
Rem    surman     08/21/15 - 20772435: SQL registry changes to XDB safe scripts
Rem    bsprunt    08/21/15 - Bug 21460115: DBA_HIST_RSRC_[PDB_]METRIC views
Rem    sdball     08/18/15 - drop shard context on downgrade
Rem    quotran    08/17/15 - bug 21647479: track commits per second
Rem    thbaby     08/17/15 - 21646878: truncate table fed$dependency
Rem    yanlili    08/11/15 - Fix bug 21473661 
Rem    sylin      08/11/15 - bug 21571353: drop sys.schedule_job procedure
Rem    osuro      08/05/15 - Drop AWR CON_SYSMETRIC_* views and synonyms
Rem    yberezin   07/29/15 - bug 21497629: long ids
Rem    osuro      07/24/15 - Drop [g]v$con_sysmetric_[history,summary]
Rem    dgagne     08/11/15 - backout approot txn
Rem    amunnoli   08/10/15 - bug 21370358: drop aud$unified internal table
Rem    quotran    08/06/15 - bug 21610276: support always-on capture
Rem    cgervasi   08/04/15 - bug 21556337: AWR downgrade to 12.1.0.2
Rem    cgervasi   08/03/15 - lrg17960694: alter AWR WRH$_CELL_DB_BL
Rem    jhaslam    08/03/15 - Bug 21350348: drop catblock CDB synonyms and views
Rem    yberezin   07/29/15 - bug 21497629: long ids
Rem    sramakri   07/29/15 - bug-21473945: drop synonym for dbms_irefstats
Rem    dcolello    07/28/15 - more columns for CLOUD table
Rem    pgalinka   07/28/15 - Fix for bug 21474888
Rem                          drop public synonym GV$GCR_METRICS 
Rem    drosash     07/28/15 - Drop view and synonym for DBA_TEMP_FILES_INST
Rem                           and GV/V$TEMPFILE_INFO_INSTANCE
Rem    jiayan      07/27/15 - #20663978: drop synonym for dbms_stats_advisor
Rem    msusaira   07/24/15 - ofsmtab$ changes
Rem    dmaniyan   07/23/15 - Bug 21095569: Drop tablespace set issue
Rem    mthiyaga   07/21/15 - Remove truncate hive_uri
Rem    ardesai     07/14/15 - Bug[20899189] Drop UMF 12.2 objects
Rem    gravipat     07/13/15 - truncate table pdb_create
Rem    dgagne      07/09/15 - move checknft to the right place
Rem    mthiyaga    07/09/15 - Drop package dbms_hadoop_internal
Rem    cgervasi    07/08/15 - awr: add columns to cell_db
Rem    qinwu       07/07/15 - bug 20925358:drop dbms_wrr_state
Rem    jiangzho     06/24/15 - #(21240327): add dba/all/user_mining_model_views
Rem    liding     06/08/15 - bug 21049500: new col in mv_refresh_usage_stats$
Rem    ardesai     07/06/15 - Bug[20933661] drop invalid CDBP objects
Rem    jlingow     07/02/15 - bug21348198 comment column on scheduler tables
Rem                           should go back from 4000 to 240
Rem   jiangzho     06/24/15 - #(21240327): add dba/all/user_mining_model_views
Rem    bmilenov    06/29/15 - bug-21313155: ORA_DM_REFCUR_PKG is invalid
Rem    jnunezg     06/25/15 - Drop package DBMS_SCHED_CONSTRAINT_EXPORT
Rem    dcolello    06/25/15 - bug 21304743: drop dbms_gsm_fixed correctly
Rem    sudurai     06/24/15 - Bug 21258745: Moving STATS crypto APIs from
Rem                           DBMS_STATS_INTERNAL -> DBMS_CRYPTO_STATS_INT
Rem    huntran     06/24/15 - drop dbms_goldengate_imp package
Rem    mahrajag    06/24/15 - bug 21313072
Rem    yanlili     06/22/15 - Fix bug 20897609: drop xs_connect and XSCONNECT
Rem                           roles
Rem    ghicks      06/19/15 - bugs 20481832, 20481863: remove HIER and HIER
Rem                           CUBE privileges
Rem    ddas        06/17/15 - proj 47170: persistent IMC statistics
Rem    mjaiswal    06/16/15 - drop view,synonym of (G)V$AQ_MESSAGE_CACHE_ADVICE
Rem                           and (G)V$AQ_SHARDED_SUBSCRIBER_STAT
Rem    atomar      06/16/15 - downgrade queue tables long identifier
Rem    mthiyaga    06/11/15 - Drop XT_HIVE_TABLES_VALIDATION
Rem    mahrajag    06/10/15 - drop DBMS_PLSQL_CODE_COVERAGE
Rem    yanlili     06/09/15 - Fix lrg 16743762: drop schema acl in f1201000
Rem    sdball      06/05/15 - Bug 21143597: GDS support for long identifiers
Rem    rmorant     06/05/15 - Bug21203169 remove incorrect update by
Rem                           bug20301816
Rem    jiayan      06/01/15 - #21165620: drop (g)v$exp_stats
Rem    molagapp    05/30/15 - bug-21132967
Rem    jibyun      05/29/15 - Bug 17976112: drop dba_checked_roles and
Rem                           dba_checked_roles_path views
Rem    nkgopal     12/01/15 - Bug 17900999: Revert size of auth$privileges of
Rem    mdombros    06/06/15 - Bug 21163869: downgrade hrcube grplvl tbls/views
Rem    atomar      06/02/15 - downgrade system.aq$_schedules
Rem    yingzhen    05/27/15 - Bug 20802034: flush v$channel_waits
Rem    huntran     05/23/15 - drop dbms_goldengate_int_invok package
Rem    rkagarwa    05/21/15 - bug 21068213: drop shadow Type objects
Rem    ddedonat    05/20/15 - Bug 20936507: Drop xxx_HIERARCHIES and 
Rem                           MDX_ODBO_FUNCTIONS objects
Rem    hlakshma    05/19/15 - Drop synonymns defined for project 45958 (ADO for
Rem                           DBIM)
Rem    bnnguyen    05/18/15 - bug 20134461: drop views and synonyms for
Rem                           IP_ACL and EXADIRECT_ACL
Rem    yanlili     05/18/15 - Bug 19880667,20925376: Support xs_resource role
Rem                           and drop xs_admin_util_int package
Rem    jtomass     01/14/15 - bug 20877328: drop procedure dbms_feature_afd
Rem    asolisg     05/17/15 - 20936878: add (G)V$ASM_FILEGROUP_FILE
Rem    rmorant     05/14/15 - bug19651064 downgrade changes
Rem    beiyu       05/14/15 - Bug 20549214: remove SELECT ANY HIER DIM priv
Rem    araghava    05/13/15 - proj 47117: online split
Rem    rmorant     05/12/15 - bug 20553651: long ids
Rem    rmorant     05/12/15 - bug 20301816: long ids
Rem    sdball      05/07/15 - Bug 20917133: missed drop of some new objects on
Rem                           downgrade
Rem    micmcmah    05/06/15 - Bug 20984580: Drop PRIVATE_JDBC_DR
Rem    dvoss       05/01/15 - lrg 16143341: cannot restrict size of
Rem                           logmnr_tab$.property
Rem    thbaby      04/30/15 - 20985003: migrate Common Data views
Rem    andmerca    04/21/15 - bug 20862217: reorder dropping of DDTF_OPT types
Rem    bhammers    04/20/15 - bug 20862217: reorder dropping of json 
Rem                           related types
Rem    welin       04/20/15 - bug 20862217: reorder dropping of 
Rem                           AWRBL_METRIC_TYPE_TABLE, changing drop 
Rem                           option of sys.wri$_adv_stats
Rem    yberezin    04/21/15 - bug 20867498: long ids
Rem    nkgopal     12/01/15 - Bug 17900999: Revert size of auth$privileges of
Rem    rmacnico    04/30/15 - LRG 15949504: downgrade with cellcache
Rem    alestrel    04/29/15 - BUG 20762369:
Rem                           upgradeSYSTEM.SCHEDULER_PROGRAM_ARGS_TBL
Rem    smangala    04/27/15 - bug 20936430: drop LOGMNR_GTCS_CAT_SUPPORT_V$
Rem    nmuthukr    04/27/15 - bug 20936385 - drop dbms_process body
Rem    gravipat    04/25/15 - set new columns in cdb_file$ to null
Rem    sfeinste    04/24/15 - Bug 20876930: Remove dbms_hierarchy_log
Rem    sgarduno    04/23/15 - Bug 20855956, 20511159 
Rem                           + Streams Long Identifier support.
Rem    prshanth    04/22/15 - Bug 20823920: drop default lockdown profiles
Rem    rdecker     04/22/15 - bug 20917444: drop CDB_STATMENTS
Rem    yberezin    04/21/15 - bug 20867498: long ids
Rem    hmohanku    04/21/15 - bug 20511242: revert long identifier support in
Rem                           DBMS_AUDIT_MGMT, TSDP metadata tables
Rem    suelee      04/16/15 - Bug 20898764: PGA limit
Rem    bsprunt     04/16/15 - Bug 15931539: add missing fields to
Rem                           DBA_HIST_RSRC_CONSUMER_GROUP
Rem    bsprunt     04/16/15 - Bug 20556913: add v$rsrcpdbmetric_[history]
Rem    bsprunt     04/16/15 - Bug 20185348: persist v$rsrcmgrmetric_history
Rem    sudurai     04/16/15 - proj 49581 - optimizer stats encryption
Rem    ssonawan    04/15/15 - Bug 20715920: clear ext_username column of
Rem                           cdb_local_adminauth$
Rem    sdoraisw    04/15/15 - proj 47082:partitioned external table support
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    jiayan      04/10/15 - proj 47047: drop tables for expression tracking
Rem    aditigu     04/10/15 - proj 58950,42356-3: added new IMC tables
Rem    schakkap    04/07/15 - proj 46828: drop mon_mods_v
Rem    garysmit    04/06/15 - Proj 46675: Global Dictionary Join Groups
Rem    tbhukya     04/04/15 - Bug 20722522: Drop and recreate index i_dependobj
Rem    quotran     04/03/15 - bug 20827740: support RAC per-instance sync
Rem    zaxie       04/03/15 - Bug 20688138: drop [G]V$FS_FAILOVER_OBSERVERS
Rem    sdball      04/02/15 - ddl_num should default to 0 in database table for
Rem                           upgrade
Rem    huntran     04/02/15 - proj 58812: auto cdr
Rem                         - dvoss: add COLLID and COLLINTCOL# for logminer
Rem    sdball      03/31/15 - New rack column for GDS sharding
Rem    molagapp    03/28/15 - Project 47808 - Phase 2
Rem    cmlim       03/25/15 - bug 20756240: support long identifiers in
Rem                           validation procedure names
Rem    drosash     03/24/15 - Proj 47411: Local Temp Tablespaces
Rem    itaranov    03/24/15 - proj 46694: SxR and Chunk stats
Rem    vinisubr    03/17/15 - Project 58876: Support for downgrade for kernel
Rem                           column-level statistics support
Rem    rajeekku    03/13/15 - Project 46762 - Dblink Enhancements
Rem    dvoss       03/24/15 - bug 20759099: logminer handle wide tab$.property
Rem    jorgrive    03/23/15 - actions for OGG sharding
Rem    hegliu      03/23/15 - bug 20606723: downgrade for partitioned read only
Rem                           table
Rem    sgarduno    03/20/15 - Bug 20560241: Long identifier support for
Rem                           xstream$_map
Rem    sgarduno    03/20/15 - Bug 20511901: Long identifier support for
Rem                           SYS.REPL$_DBNAME_MAPPING.
Rem    hmohanku    03/19/15 - bug 20280545: modify
Rem                           sys.dam_cleanup_jobs$.job_name
Rem    jgiloni     03/19/15 - Quarantine
Rem                           v4inmemory_xmem_area
Rem    nmukherj    03/18/15 - Proj 59655: Upgrade/downgrade
Rem                           v4inmemory_xmem_area
Rem    yxie        03/17/15 - proj 47332: add emx resource manager
Rem    rmacnico    03/15/15 - Proj 47506: CELLCACHE
Rem    rajeekku    03/13/15 - Project 46762 - Dblink Enhancements
Rem    sdball      03/13/15 - More changes for 12.2 sharding
Rem    nkgopal     03/12/15 - Bug 17900999: Revert size of auth$privileges of
Rem    hpoduri     03/11/15 - Proj:47331, drop [G]V$INDEX_USAGE_INFO
Rem    prgaharw    03/06/15 - 20664732 - IM segment dict V$ views support
Rem    mstasiew    03/06/15 - 20512658 olap_metadata_dependencies/properties
Rem    svaziran    03/06/15 - bug 20652654: downgrade name col for ft usage
Rem    sdball      03/04/15 - new 12.2 sharding changes
Rem    sdoraisw    02/17/15 - proj47082:downgrade external_tab$
Rem    thbaby      03/03/15 - Proj 47234: handle fed$editions
Rem    thbaby      03/03/15 - Proj 47234: use truncate for fed$ tables
Rem    thbaby      03/03/15 - Proj 47234: set 3rd word in tab$.property to 0
Rem    jlombera    03/03/15 - bug 9128515: drop (G)V$SYSTEM_RESET_PARAMETER and
Rem                           (G)V$SYSTEM_RESET_PARAMETER2
Rem    aumishra    02/26/15 - Project 42356: Drop views for IME infrastructure
Rem                           during downgrade
Rem    gravipat    02/26/15 - Proj 47234: Drop undots, refreshint columns to
Rem                           container$
Rem    ssonawan    02/26/15 - Bug 20383779: Remove default BECOME USER auditing
Rem    sumkumar    02/25/15 - Bug 19895367 : Clear lock_date, password profile
Rem                           name and profile limits in cdb_local_adminauth$
Rem    mthiyaga    02/23/15 - Drop DBA_HIVE_TAB_PARTITIONS
Rem    msoudaga    02/23/15 - Bug 16028065: Remove role DELETE_CATALOG_ROLE
Rem    pyam        02/19/15 - drop fed$sessions
Rem    hlakshma    02/18/15 - proj 45958: heat_map_stat$ table changes
Rem    jftorres    02/17/15 - proj 45826: restore smb$config to original
Rem                           structure, and remove new rows
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    thbaby      02/15/15 - Proj 47234: set 3rd word in view$.property to 0
Rem    thbaby      02/14/15 - Proj 47234: drop views [CDB|DBA]_APP_ERRORS and
Rem    thbaby      02/13/15 - Proj 47234: drop view INT$DBA_APP_STATEMENTS
Rem    lzheng      02/12/15 - drop tables/views/synonyms used for plsql procdure
Rem                           replication and package dbms_goldengate_adm
Rem    shrgauta    02/04/15 - bug 10173496, truncate table wri$_segadv_attrib
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    jtomass     01/14/15 - bug 20312104: drop procedures dbms_feature_thp
Rem                           and dbms_feature_flex_asm 
Rem    gravipat    02/12/15 - Bug 20533616: Unify wrp,bas scn columns in
Rem                           container
Rem    dagagne     02/10/15 - remove ZDLRA on-disk stats
Rem    hlili       02/09/15 - Revoke changes to partobj$ in 12.2
Rem    svivian     02/09/15 - bug 20488905: revert change to session_name
Rem    shrgauta    02/04/15 - bug 10173496, truncate table wri$_segadv_attrib
Rem    yberezin    02/02/15 - bug 20381239: long IDs
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    bhammers    01/08/14 - drop DBMS_JDOM_LIB and related types
Rem    dagagne     02/10/15 - remove ZDLRA on-disk stats
Rem    msingal     02/09/15 - Bug/19665921 add support for HCC over cloud DB
Rem                           installations
Rem    shrgauta    02/04/15 - bug 10173496, truncate table wri$_segadv_attrib
Rem    genli       02/03/15 - drop view and public synonym for EVENT_OUTLIERS
Rem    nrcorcor    02/03/15 - Bug 13539672/Project 41272 New lost write
Rem                           protection
Rem    yberezin    02/02/15 - bug 20381239: long IDs
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    bhammers    01/08/14 - drop DBMS_JDOM_LIB and related types
Rem    dvoss       02/02/15 - proj 49286:logminer per pdb characterset support
Rem    thbaby      01/30/15 - Proj 47234: drop remote_user from container$
Rem    baparmar    01/29/15 - Bug 19257966 use utl_raw for session_key update
Rem    gravipat    01/29/15 - Proj 47234: truncate cdb_ts$
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    bhammers    01/08/14 - drop DBMS_JDOM_LIB and related types
Rem    jaeblee     01/29/15 - lrg 12680989: drop some dba_xml_% views
Rem    dvoss       01/26/15 - proj 49288: logminer tracking more container$
Rem                           cols
Rem    kkunchit    01/21/15 - project-47046: dbfs support for posix locking
Rem    rpang       01/20/15 - 17854208: clear diagnostic columns in sqltxl_sql$
Rem    nbenadja    01/17/15 - proj-46694: enhance GDS catalog downgrade
Rem    nkgopal     01/13/15 - Bug 17900999: Revert size of auth$privileges of
Rem    sroesch     01/19/14 - Bug 20319989: Make draining timeout a svc attr
Rem                           AUD$
Rem    raeburns    01/15/15 - Bug 20088724: drop dba_registry_schemas view
Rem    beiyu       01/13/15 - Proj 47091: downgrade for HCS objects
Rem    nkgopal     01/12/15 - Bug 17900999: Revert size of auth$privileges of
Rem    cqi         01/12/15 - drop view dba_hang_manager_parameters
Rem    yujwang     01/07/15 - bug(20319569): for RAC AWR report
Rem    akruglik    01/06/15 - Bug 20272756: drop int$container_obj$
Rem    shjoshi     01/04/15 - bug 20301287: drop int$ views for *hist_reports*
Rem    atomar      01/02/15 - bug 19559576
Rem    sumkumar    12/31/14 - Proj 46885: Inactive Account Time
Rem    dkoppar     12/26/14 - #19938082 QI changes
Rem    devghosh    12/23/14 - OPT4:drop synonym for (g)v$aq_opt_* views
Rem    quotran     12/22/14 - bug 20204603: truncate tables for fixing scn order
Rem    qinwu       12/22/14 - proj 47326: add columns for PL/SQL subcalls
Rem    thbaby      12/19/14 - Proj 47234: remove public database link CDB$ROOT
Rem    thbaby      12/19/14 - Proj 47234: truncate table view_pdb$
Rem    thbaby      12/18/14 - Proj 47234: drop view int$container$
Rem    thbaby      12/17/14 - Proj 47234: drop column remote_port
Rem    cunnitha    12/15/14 - drop package dbms_pq_internal
Rem    cqi         11/18/14 - drop package DBMS_HANG_MANAGER
Rem    smangala    12/16/14 - proj-58811: add support for sharding
Rem    ardesai     12/14/14 - modify WRH$_SGASTAT_U and drop awr views
Rem    dmmorton    12/11/14 - proj 47362: changes for purge relations
Rem    rpang       12/11/14 - Downgrade 12.2 multi-language debugging changes
Rem    alui        12/06/14 - revoke pdb name access privileges from appqossys
Rem    wesmith     12/03/14 - Project 47511: data-bound collation
Rem    pyam        12/02/14 - Proj 47234: drop fed$binds
Rem    nmuthukr    12/01/14 - remove v$process pool
Rem    rdecker     12/01/14 - PL/Scope for SQL dictionary tables
Rem    thbaby      12/01/14 - Proj 47234: drop containers_host, containers_port
Rem    hcdoshi     12/01/14 - remove ntfn_subscriber from sys.reg
Rem    cqi         11/18/14 - drop package DBMS_HANG_MANAGER
Rem    mzait       11/13/14 - #(20059248) increase size of target column in
Rem                           optstat_opr_tasks and optstat_opr
Rem    yanlili     11/30/14 - Bug 20019217: Drop view
Rem                           DBA_XS_ENABLED_AUDIT_POLICIES
Rem    prrathi     11/24/14 - remove child subscribers
Rem    pxwong      11/23/14 - bug 18671612 change some obj$ obsoleted fields
Rem    kaizhuan    11/23/14 - Project 46812
Rem    hoyao       11/23/14 - drop dbms_dbcomp package, v$block_compare
Rem    lzheng      11/21/14 - drop view for ogg$_supported_pkgs,
Rem                           ogg$_procedure_annotation, and 
Rem                           ogg$_proc_object_filtering
Rem    yanlili     11/21/14 - bug-19913708: Drop new RAS view
Rem    prakumar    11/20/14 - Proj# 39358: Truncate redef_object_backup$
Rem    atomar      11/17/14 - exception queue
Rem    pyam        11/17/14 - LRG 13206810: remove addition of settings$ rows
Rem    pxwong      11/13/14 - remove size changes in type attributes on
Rem                           downgrade
Rem    asolisg     11/10/14 - Proj 47340: add (G)V$ASM_FILEGROUP
Rem    youyang     09/03/14 - project 46820: PA enhancement
Rem    surman      11/07/14 - 19978542: Change bundle_data back to XMLType
Rem    ddas        11/06/14 - lrg 12890725: downgrade sqlobj$plan
Rem    sankejai    11/04/14 - Bug 19946880: name in pdb_alert$ restored to 30
Rem    bnnguyen    10/29/14 - bug 19697038: drop user DBSFWUSER cascade 
Rem    desingh     10/29/14 - sharded queue delay
Rem    desingh     10/29/14 - sharded queue delay
Rem    akruglik    10/22/14 - Project 47234: add support for federational users
Rem                           and federationally granted privs
Rem    sdball      10/20/14 - GDS downgrade from 12.2
Rem    youyang     09/03/14 - project 46820: PA enhancement
Rem    jiayan      10/20/14 - lrg 13729505: drop stats advisor report client
Rem    mjaiswal    10/17/14 - OPT2: truncate table SYS.AQ$_EVICTED_SUBSHARD
Rem    pgalinka    10/16/14 - Handling downgrade for gcr_metrics & gcr_actions
Rem    sdball      10/15/14 - LRG-13467350: Do not drop types used by 12.1.0.2
Rem                           tables
Rem    jiayan      10/13/14 - Proj 44162: stats advisor
Rem    prshanth    10/12/14 - Proj 47234: truncate lockdown_prof$
Rem    pxwong      09/30/14 - project 36585
Rem                             scheduler child project for long id project
Rem    sramakri    10/07/14 - Project 50868 - refresh stats history
Rem    sslim       09/23/14 - Bug 18842051: decrease column size for
Rem                           DBMS_ROLLING
Rem    myuin       09/22/14 - 19645331: drop AWRBL_METRIC_TYPE for downgrade
Rem    prrathi     09/14/14 - drop synonym for (g)V$AQ_REMOTE_DEQUEUE_AFFINITY
Rem    dkoppar     09/14/14 - #19510547 selectively drop patch uid
Rem    sslim       09/13/14 - project 56343: RA support for downstream OGG
Rem    jinjche     09/11/14 - Fix bug 19357879
Rem    akruglik    09/09/14 - Bug 19525987: drop container$.upgrade_priority
Rem    ardesai     09/09/14 - lrg[13040347]conditionalize alter
Rem                           wrh$_dyn_remaster_stats
Rem    kdnguyen    09/08/14 - Bug 19510008: drop dbmsinmemadmin package
Rem    gravipat    09/08/14 - Bug 19328303: drop rafn# column from container$
Rem    sdball      09/08/14 - BUG 19510593: Fixing downgrade for GDS
Rem    jlingow     09/05/14 - proj-58146 dropping setup for remote scheduler 
Rem                           agent
Rem    thbaby      09/04/14 - Proj 47234: drop Fed tables, views, sequences
Rem    yohu        09/04/14 - Proj 46902: Sesion Privilege Scoping
Rem    amunnoli    09/01/14 - Bug 19480441: Disable audit policies enabled on
Rem                           users with granted roles
Rem    mziauddi    08/31/14 - proj 35612: drop views and synonyms for ZUT
Rem    pyam        08/26/14 - 19455994: share settings$ rows for common objs
Rem    atomar      08/24/14 - bug 19492019
Rem    minwei      08/22/14 - 12.2 downgrade for proj#39358 redef
Rem                           restartability
Rem    prshanth    08/20/14 - Proj 47234: Lockdown profile - adding DDLs
Rem    spapadom    08/18/14 - Added changes for SVRMAN UMF
Rem    schakkap    08/15/14 - proj 46828: Add scan rate
Rem    yanlili     08/16/14 - Proj 46907: Drop views and public synonyms
Rem                           for schema level policy admin
Rem    qinwan      08/15/14 - Drop data mining R model related db objects
Rem    jomcdon     08/13/14 - lrg 12966203: only drop DBRM columns when
Rem                           downgrading to pre-12.1.0.2
Rem    spapadom    08/11/14 - Increased AWR Version to 12.1.0.2. 
Rem    dgagne      08/11/14 - add drops of data pump worker view and synonym
Rem    dhdhshah    08/06/14 - 18718931: remove attr 4 from ilm_concurrency$
Rem    yiru        08/05/14 - Bug 19359488: Do not drop DESCRIPTION column from
Rem                           sys.xs$instset_rule when downgrading to 12.1.0.2
Rem    thbaby      08/01/14 - Proj 47234: conditional rename of vsn to spare1
Rem    nkgopal     07/28/14 - Proj 35931: Drop DBMS_AUDIT_UTIL and
Rem                           DBMS_AUDIT_UTIL_LIB
Rem    yunkzhan    07/23/14 - Drop table function GSBA_GG_TABF_PUBLIC
Rem    sroesch     07/16/14 - Update service$
Rem    bhavenka    07/21/14 - 9853147: drop sqlset_row for last_exec_start_time
Rem    thbaby      07/21/14 - Proj 47234: drop container$ columns
Rem    cxie        07/16/14 - 19229101: dont need to drop CAUSE column in
Rem                           pdb_alert$
Rem    mthiyaga    07/15/14 - Drop hive catalog views
Rem    pknaggs     07/09/14 - Proj #46864: Data Redaction multiple policies.
Rem    pknaggs     07/09/14 - Bug #19142127: REDACTION_COLUMNS_DBMS_ERRLOG.
Rem    ranbaner    07/07/14 - project 45944-Parameter table, cachd hint
Rem    jgiloni     07/03/14 - PMON Slaves
Rem    jorgrive    06/30/14 - Truncate repl$_process_events
Rem    romorale    04/08/14 - BigSCN lcrid_version to streams$_apply_process 
Rem    osuro       06/30/14 - Bug 19067295: Update WRH$_SGASTAT.POOL
Rem    sgarduno    06/26/14 - Streams long identifier support.
Rem    svivian     06/19/14 - logmnr long identifiers
Rem    shjoshi     06/12/14 - bug18969815: drop *hist_reports* for dwngrd
Rem    pyam        06/10/14 - 18764101: truncate pdb_inv_type$
Rem    myuin       06/10/14 - handle WRM$_PDB_IN_SNAP and related table/views
Rem    surman      06/05/14 - Backport surman_bug-17277459 from main
Rem    moreddy     06/05/14 - Backport moreddy_lrg-12149882 from main
Rem    lexuxu      06/04/14 - Backport lexuxu_bug-18756350 from main
Rem    moreddy     05/30/14 - lrg 12149882: add v$asm_disk_iostat_sparse
Rem    cxie        05/30/14 - Backport cxie_bug-18810866 from main
Rem    dagagne     05/29/14 - BUG 17346066: V$DATAGUARD_PROCESS
Rem    ssonawan    05/28/14 - Proj 46885: admin user password management
Rem    apfwkr      05/26/14 - Backport prthiaga_bug-18805145 from main
Rem    prthiaga    05/22/14 - Bug 18805145: Drop DBMS_FEATURE_JSON
Rem    dkoppar     05/22/14 - backport of 18219841
Rem    suelee      05/12/14 - Backport jomcdon_bug-18622736 from main
Rem    apfwkr      04/24/14 - Backport akruglik_bug-17446096 from main
Rem    surman      04/17/14 - Backport surman_bug-17665117 and dkoppar_bug-17665104 from main
Rem    apfwkr      04/10/14 - Backport akruglik_bug-18417322 from main
Rem    lexuxu      05/23/14 - bug 18756350
Rem    yanxie      05/22/14 - drop view and synonyms [G]V$ONLINE_REDEF
Rem    prthiaga    05/22/14 - Bug 18805145: Drop DBMS_FEATURE_JSON
Rem    lbarton     05/21/14 - Project 48787: views to document mdapi transforms
Rem    ashrives    05/21/14 - 18543824: Create index on ilm_results$
Rem    cxie        05/15/14 - drop colunm CAUSE on pdb_alert$
Rem    amozes      05/09/14 - project 47098: data mining framework
Rem    sanbhara    05/05/14 - Project 46816 - adding support for SYSRAC.
Rem    dkoppar     04/28/14 - 18219841 qpx fixed views
Rem    jomcdon     04/27/14 - implement profiles functionality
Rem    ghicks      04/21/14 - undo OLAP obj name length changes
Rem    surman      04/21/14 - 17277459: Add bundle columns to SQL registry
Rem    sagrawal    04/15/14 - Polymorphic Table Functions
Rem    akruglik    04/10/14 - Bug 17446096: remove adminauth$ rows in a non-CDB
Rem    baparmar    04/04/14 - bug18469064: change session_key type 
Rem    akociube    04/02/14 - drop package DBMS_FEATURE_IMA
Rem    youyang     04/02/14 - Backport youyang_bug-18442084 from main
Rem    akruglik    04/01/14 - Bug 18417322: update CDB_LOCAL_ADMINAUTH$.flags
Rem    abrumm      04/01/14 - rename ORACLE_BIGSQL to ORACLE_BIGDATA
Rem    apfwkr      04/01/14 - Backport tseibold_bug-18459020 from main
Rem    jkaloger    03/30/14 - Add changes for Oracle BigData Agent
Rem    skabraha    03/26/14 - drop JSON views
Rem    youyang     03/26/14 - bug18442084:fix type grant_path
Rem    tseibold    03/25/14 - Bug 18459020: drop Opatch diag views
Rem    spapadom    03/24/14 - XbranchMerge spapadom_imc1 from main
Rem    apfwkr      03/20/14 - Backport praghuna_bug-17638117 from main
Rem    akociube    03/20/14 - drop package DBMS_FEATURE_IMA
Rem    jlingow     03/19/14 - scheduler$_notification table has an extra
Rem                           notification_owner column
Rem    surman      03/19/14 - 17665117: Patch UID
Rem    cono        03/17/14 - add (g)v$process_priority_data
Rem    apfwkr      03/16/14 - Backport genli_waitoutlier from main
Rem    ncolloor    03/07/14 - Bug 18157062 downgrade a column of cpool$
Rem    sasounda    03/06/14 - 18111335: conditionalize READ priv downgrd action
Rem    bhammers    03/05/14 - drop JSON views
Rem    jinjche     02/28/14 - Rename a couple of columns
Rem    vradhakr    02/28/14 - Bug 17971239: Increase size of columns for long
Rem                           identifiers.
Rem    genli       02/25/14 - drop view and public synonym 
Rem                           for EVENT_HISTOGRAM_MICRO
Rem    risgupta    02/24/14 - Bug 18174384: Drop ora_logon_failures
Rem    jorgrive    02/21/14 - bug 9774957
Rem    dkoppar     02/16/14 - #17665104 changes in opatch_inst_patch
Rem    hbaer       02/14/14 - remove feature usage tracking DBMS_FEATURE_ZMP
Rem    sslim       02/11/14 - drop cdb_ptc_apply_progress
Rem    spapadom    02/10/14 - Drop AWR tables and views for IM segment stats
Rem    jheng       02/10/14 - Bug 18224840
Rem    cdilling    02/06/14 - bug 18165071 - drop DBA_LOCK related objects
Rem    sidatta     02/04/14 - adding views v$cell_db, v$cell_db_history and
Rem                           v$cell_open_alerts
Rem    risgupta    02/03/14 - Bug 18157726: truncate all_unified_audit_actions
Rem                           table
Rem    cgervasi    01/21/14 - 18057967: add WRH$_CELL_DB, WRH$_CELL_OPEN_ALERTS
Rem    p4kumar     01/21/14 - Bug 17537632
Rem    cdilling    01/16/14 - put back drop statements now the downgrade is run
Rem                           on PDBs first
Rem    traney      01/16/14 - 17971391:downgrade size of opbinding$.functionname
Rem    gclaborn    01/15/14 - Drop new columns from sys.impcalloutreg$
Rem    abrumm      12/24/13 - exadoop-downgrade: remove raw attribute from
Rem                           ODCIExtTable[Open,Fetch,Populate,Close]
Rem    achaudhr    12/16/13 - 17793123: Remove oracle_loader deterministic
Rem                           keyword
Rem    jheng       01/09/14 - Bug 18056142: revoke granted SELECT ON privs
Rem    dvoss       12/31/13 - bug 18006033 - dba_rolling_unsupported
Rem    gravipat    12/30/13 - truncate pdb_sync$
Rem    thbaby      12/24/13 - 17987966: drop procedure createX$PermanentTables
Rem    achaudhr    12/16/13 - 17793123: Remove oracle_loader deterministic keyword
Rem    cmlim       12/15/13 - cmlim_bug-17545700: extra: drop cdb and dba
Rem                           objects on top of registry$error
Rem    chinkris    12/12/13 - rename (g)v$imc views as (g)v$im views
Rem    hlakshma    12/10/13 - Drop constraints to ADO tables
Rem    amylavar    12/06/13 - Drop package DBMS_FEATURE_IOT
Rem    yberezin    12/04/13 - bug 17391276: introduce OS time for
Rem                           capture/replay start
REM    tianli      12/04/13 - 17742001: fix process_drop_user_cascade
Rem    thbaby      12/02/13 - drop INT$DBA_COL_COMMENTS, INT$DBA_TAB_COMMENTS
Rem    rmorant     12/02/13 - LRG:9955689 delete duplicae rows in
Rem                           DYN_REMASTER_STATS
Rem    jinjche     11/22/13 - Add big SCN support
Rem    praghuna    11/20/13 - Added pto recovery fields to apply milestone
Rem    ssprasad    11/20/13 - drop views (g)v$asm_disk_sparse(_stat)
Rem                                      (g)v$asm_diskgroup_sparse
Rem    rpang       11/12/13 - 17637420: clear tracking columns in sqltxl tables
Rem                           WRH$_CELL_IOREASON_NAME
Rem    cgervasi    11/06/13 - bug 17852957: add WRH$_CELL_IOREASON, 
Rem                           WRH$_CELL_IOREASON_NAME
Rem    cdilling    11/04/13 - bug 17639057 -add support for cdb downgrade
Rem                         - remove unnecesary drop type statements
Rem    amylavar    11/01/13 - Drop package DBMS_FEATURE_IMC
Rem    yxie        10/28/13 - drop procedure dbms_feature_emx
Rem    yxie        10/25/13 - drop [g]v$emx_usage_stats
Rem    sidatta     10/02/13 - v$cell_ioreason table
Rem    jmuller     08/06/13 - Fix bug 17250794: rework of USE privilege on
Rem                           default edition
Rem    amylavar    23/10/13 - 16859747: Drop DBMS_FEATURE_ADV_TABCMP
Rem    chinkris    10/30/13 - Drop (g)v$im_column_level
Rem    jkati       10/29/13 - bug#17543726 : drop STIG compliant profile
Rem    cchiappa    10/28/13 - Rename V$VECTOR_TRANSLATE to V$KEY_VECTOR
Rem    qinwu       10/21/13 - drop divergence_load_status from wrr$_replays
Rem    romorale    10/21/13 - drop _dba_xstream_unsupported_12_1
Rem    lbarton     10/17/13 - bug 17621089: drop dbms_export_extension_i
Rem    jekamp      10/16/13 - Project 35591: Add v$im_segments and
Rem                           v$im_user_segments
Rem    jinjche     10/16/13 - Rename nab to old_blocks
Rem    sragarwa    10/10/13 - Bug 17303407 : Add delete privileges on aud$
Rem                           and fga_log$ to DELETE_CATALOG_ROLE
Rem    chinkris    10/10/13 - Drop views (g)v$inmemory_area
Rem    sasounda    09/26/13 - proj 47829: del READ priv granted during upgrade
Rem    surman      08/05/13 - 17005047: Add dbms_sqlpatch
Rem    gravipat    10/04/13 - drop INTDBA_PDBS
Rem    tianli      10/03/13 - drop view for apply$_cdr_info
Rem    cxie        10/01/13 - drop index i_pdb_alert2 on pdb_alert$
Rem    huntran     09/30/13 - add lob apply stats
Rem    thbaby      09/30/13 - 17518642: drop view INT$DBA_HIST_CELL_GLOBAL
Rem    chinkris    09/28/13 - Drop views (G)V$IMC_COLUMN_LEVEL
Rem    shiyadav    09/26/13 - bug17348607:downgrade for wrh$_dyn_remaster_stats
Rem    youyang     09/26/13 - bug17496774:delete plsql capture for PA
Rem    vpriyans    09/23/13 - Bug 17299076: drop ORA_CIS_RECOMMENDATIONS
Rem    minx        09/18/13 - Fix Bug 17478619: Add data realm description 
Rem    thbaby      09/17/13 - lrg 9710290: reload INT$DBA_CONSTRAINTS
Rem    chinkris    09/11/13 - Drop views (G)V$IMC_AREA
Rem    yidin       09/09/13 - bug-12592851 drop v$recovery_slave &
Rem                           gv$recovery_slave
Rem    desingh     08/30/13 - drop columns from AQ SYS.*_PARTITION_MAP tables
Rem    thbaby      08/29/13 - 14515351: drop INT$ views for object linked views
Rem    jinjche     08/27/13 - Add a column and rename some columns
Rem    sdball      08/26/13 - Bug 17199155: Set db_type to NULL on downgrade
Rem    talliu      08/26/13 - add drop public synonym for CDB views.
Rem    shiyadav    08/22/13 - bug 13375362: changes in baseline for downgrade
Rem    jheng       08/22/13 - Bug 17251375: drop rolename_array
Rem    cgervasi    08/20/13 - add wrh$_cell_global, wrh$_cell_metric_desc
Rem    myuin       08/20/13 - add drop view statements to new CDB_HIST views
Rem    thbaby      08/14/13 - 17313338: drop view int$dba_stored_settings
Rem    praghuna    08/13/13 - bug 17030189
Rem    thbaby      08/13/13 - 16956123: drop view INT$INT$DBA_CONSTRAINTS
Rem    jheng       08/08/13 - Bug 16931220: drop type grant_path
Rem    pradeshm    08/07/13 - Drop new vew USER_XS_PASSWORD_LIMITS created for
Rem                           proj46908
Rem    sidatta     07/30/13 - Adding Cell Metric Description table/views
Rem    shrgauta    07/30/13 - Add V$ and GV$ entries for IMCU and SMU views
Rem    hsivrama    07/22/13 - bug 15854162: drop DBMS_FEATURE_ADAPTIVE_PLANS,
Rem                           DBMS_FEATURE_AUTO_REOPTIMIZATION procedures.
Rem    cgervasi    03/25/13 - add wri$_rept_cell
Rem    dlopezg     07/23/13 - bug 16444144 - new objects were created. Remove
Rem                           them
Rem    hsivrama    07/22/13 - bug 15854162: drop DBMS_FEATURE_ADAPTIVE_PLANS,
Rem                           DBMS_FEATURE_AUTO_REOPTIMIZATION procedures.
Rem    sramakri    07/19/13 - update mlog$ for BigSCN
Rem    rpang       07/19/13 - 17185425: downgrade SQL ID/hash for SQL
Rem                           translation profiles
Rem    nkgopal     07/16/13 - Bug 14168362: Remove dbid, pdb guid from
Rem                           sys.dam_last_arch_ts$
Rem    mjungerm    07/08/13 - revert addition of CREATE JAVA priv
Rem    pradeshm    07/03/13 - Proj#46908: drop column added in principal table
Rem    svivian     07/01/13 - bug 16848187: clear con_id in logstdby$events
Rem    rpang       06/28/13 - Remove network ACLs from noexp$
Rem    sidatta     06/20/13 - Dropping (g)v$ views and synonyms for
Rem                           cell_global(_history), cell_disk(_history)
Rem    kyagoub     06/07/13 - bug16654392: drop auto_sql_tuning_prog
Rem    gravipat    06/20/13 - drop view DBA_PDB_SAVED_STATES
Rem    mayanagr    06/12/13 - Drop IMC Space (g)v$ views
Rem    kyagoub     06/07/13 - bug16654392: drop auto_sql_tuning_prog
Rem    xha         06/06/13 - Bug 16829223: IMC level flags and map by flags
Rem    sidatta     03/21/13 - Drop Exadata AWR tables
Rem    dgagne      06/04/13 - drop data pump standalone function
Rem    hlakshma    05/21/13 - Changes related to compression advisor
Rem    sdball      05/15/13 - Bug 16816121: Unset data_vers in cloud
Rem    jstraub     05/10/13 - Delete APEX_050000 from sys.default_pwd$
Rem    thbaby      05/08/13 - 13606922: drop view INT$DBA_PLSQL_OBJECT_SETTINGS
Rem    ckearney    05/07/13 - drop vector translate views
Rem    mjungerm    05/06/13 - add create java and related privs
Rem    sdball      05/06/13 - Bug 16770655 - Remove weights from region
Rem    jstraub     05/02/13 - Delete APEX_040200 from sys.default_pwd$
Rem    jinjche     05/02/13 - Change drop column to update per reviewer
Rem                           comments
Rem    jinjche     04/30/13 - Rename and add columns for cross-endian support
Rem    nbenadja    04/22/13 - Remove GDS package types.
Rem    vgokhale    05/15/13 - dbms_scn package downgrade
Rem    jekamp      03/12/13 - Project 35591: drop IMC views
Rem    itaranov    03/28/13 - GDS downgrade (types removal)
Rem    lexuxu      03/27/13 - lrg 8929646
Rem    jerrede     03/26/13 - Move GV$AUTO_BMR_STATISTICS from e1102000.sql to
Rem                           e1201000.sql, it was put in the wrong script
Rem    sdball      03/13/13 - Bug 16789945:remove old_instances
Rem    xbarr       03/07/13 - Downgrading Data Mining feature usage
Rem    youngtak    03/04/13 - BUG-16223559: drop v$fs_observer_histogram
Rem    pxwong      03/07/13 - re-enable scheduler projects. This change likely will
Rem                           have to move to e 12.2 file later.
Rem    jovillag    02/27/13 - 14669017: drop _DBA_XSTREAM_OUT_ALL_TABLES
Rem                           and _DBA_XSTREAM_OUT_ADT_PK_TABLES
Rem    esmendoz    02/21/13 - BUG 13868571 - Downgrading Gateway Feature usage
Rem    mwjohnso    02/14/13 - drop LOADER_DB_OPEN_READ_WRITE
Rem    amunnoli    02/08/13 - Bug 16066652: Drop column job_flags from
Rem                           dam_cleanup_jobs$
Rem    elu         02/06/13 - drop get_oldversion_hashcode2
Rem    sdball      01/23/13 - Bugs 16269799,16269848:
Rem                           Add GDS downgrade to 12.1.0.1
Rem    praghuna    13/01/11 - update logstdby$apply_milestone.lwm_upd_time  
Rem    vpriyans    01/27/13 - Bug 15996683: drop table
Rem                           UNIFIED_MISC_AUDITED_ACTIONS
Rem    praghuna    13/01/11 - update logstdby$apply_milestone.lwm_upd_time  
Rem    cdilling    10/19/12 - patch downgrade from 12.1.0.2 to 12.1.0.1
Rem    cdilling    10/19/12 - Created
Rem

Rem *************************************************************************
Rem BEGIN e1201000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release -
Rem =========================================================================

@@e1202000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

@@?/rdbms/admin/sqlsessstart.sql

Rem ====================================================================
Rem BEGIN OFS changes since 12.1
Rem ===================================================================

update ofsmtab$ set fsid = 0;
update ofsmtab$ set nodenm = '';
truncate table ofsftab$;

Rem ====================================================================
Rem END Security changes
Rem ===================================================================

Rem ====================================================================
Rem BEGIN Security changes
Rem ===================================================================
/* [17250794] The USE privilege for PUBLIC on the default edition is implicit
 * with this fix.  Make it explicit on downgrade to a version that doesn't
 * contain the fix.
 */
DECLARE
  edn obj$.name%TYPE;
BEGIN
  SELECT property_value INTO edn FROM database_properties 
  WHERE property_name = 'DEFAULT_EDITION';
  EXECUTE IMMEDIATE 'grant use on edition ' ||
                    dbms_assert.enquote_name(edn,FALSE) ||
                    ' to public';
END;
/

DROP VIEW usable_editions;
/

DROP PUBLIC SYNONYM usable_editions;
/

Rem ====================================================================
Rem END Security changes
Rem ===================================================================

Rem =======================================================================
Rem Begin OLAP 12.2 changes
Rem =======================================================================

alter table aw_obj$ modify (
  objname varchar2(256)
)
/

alter table aw_obj$ modify (
  partname varchar2(256)
)
/

alter table aw_prop$ modify (
  objname varchar2(256)
)
/

alter table olap_aw_deployment_controls$ modify (
  physical_name varchar2(288)
)
/

alter table olap_metadata_dependencies$ modify (
  p_owner varchar2(30)
)
/

alter table olap_metadata_dependencies$ modify (
  p_top_obj_name varchar2(30)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name1 varchar2(30)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name2 varchar2(30)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name3 varchar2(30)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name4 varchar2(30)
)
/

alter table olap_metadata_properties$ modify (
  property_key varchar2(30)
)
/

Rem =======================================================================
Rem End OLAP 12.2 changes
Rem =======================================================================

Rem ===================================================================
Rem Begin Creation of DELETE_CATALOG_ROLE (Bug 16028065)
Rem ===================================================================

CREATE ROLE DELETE_CATALOG_ROLE;

Rem ====================================================================
Rem End Creation of DELETE_CATALOG_ROLE (Bug 16028065)
Rem ===================================================================

Rem ==========================================================================
Rem GRANT DELETE on AUD$ and FGA_LOG$ to DELETE_CATALOG_ROLE (Bug 17303407)
Rem ==========================================================================

GRANT DELETE ON AUD$ TO DELETE_CATALOG_ROLE;

GRANT DELETE ON FGA_LOG$ TO DELETE_CATALOG_ROLE;

Rem ====================================================================
Rem End (Bug 17303407)
Rem ===================================================================

Rem ===================================================================
Rem Begin GRANT DELETE_CATALOG_ROLE to DBA (Bug 16028065)
Rem ===================================================================

GRANT DELETE_CATALOG_ROLE TO DBA WITH ADMIN OPTION;

Rem ===================================================================
Rem End GRANT DELETE_CATALOG_ROLE to DBA (Bug 16028065)
Rem ===================================================================

Rem ====================================================================
Rem BEGIN GDS changes since 12.1.0.1
Rem ===================================================================

-- GDS profile
declare
  noexist_prof exception;
  pragma exception_init(noexist_prof,-02380);
begin
   execute immediate 'DROP PROFILE gsm_prof CASCADE';
exception when noexist_prof then null;
end;
/

declare
  noexist_prof exception;
  pragma exception_init(noexist_prof,-02380);
begin
   execute immediate 'DROP PROFILE gsm_catprof CASCADE';
exception when noexist_prof then null;
end;
/

-------------------------------------------------------------------------------
-- Triggers new in 12.1.0.2 or 12.2
-- (replaced in CATGSMCAT.SQL after downgrade if needed)
-------------------------------------------------------------------------------

DROP TRIGGER gsmadmin_internal.vncr_insert
/

DROP TRIGGER gsmadmin_internal.cat_rollback_trigger
/

DROP TRIGGER gsmadmin_internal.request_delete_trigger
/

DROP TRIGGER gsmadmin_internal.done_trigger
/

DROP TRIGGER gsmadmin_internal.GSMlogoff
/

-------------------------------------------------------------------------------
-- Constraints on new tables in 12.2
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.shard_space DROP CONSTRAINT ss_in_pool
/

ALTER TABLE gsmadmin_internal.broker_configs DROP CONSTRAINT bk_in_shardspace
/

ALTER TABLE gsmadmin_internal.shard_group DROP CONSTRAINT sg_in_region
/

ALTER TABLE gsmadmin_internal.shard_group DROP CONSTRAINT sg_in_shardspace
/

ALTER TABLE gsmadmin_internal.shardkey_columns DROP CONSTRAINT sc_in_family
/

ALTER TABLE gsmadmin_internal.catalog_requests DROP CONSTRAINT cr_gsm_requests
/

ALTER TABLE gsmadmin_internal.catalog_requests DROP CONSTRAINT cr_database
/

ALTER TABLE gsmadmin_internal.catalog_requests DROP CONSTRAINT cr_dbtrgt
/

ALTER TABLE gsmadmin_internal.catalog_requests DROP CONSTRAINT cr_dbsrc
/

ALTER TABLE gsmadmin_internal.chunks DROP CONSTRAINT chunk_shardspace
/

ALTER TABLE gsmadmin_internal.all_chunks DROP CONSTRAINT allchunk_shardspace
/

ALTER TABLE gsmadmin_internal.chunk_loc DROP CONSTRAINT cl_database
/

ALTER TABLE gsmadmin_internal.chunk_loc DROP CONSTRAINT cl_shardspace
/

ALTER TABLE gsmadmin_internal.chunk_loc DROP CONSTRAINT cl_shardgroup
/

ALTER TABLE gsmadmin_internal.chunk_loc DROP CONSTRAINT cl_chunk
/

ALTER TABLE gsmadmin_internal.partition_set DROP CONSTRAINT ps_family
/

ALTER TABLE gsmadmin_internal.tablespace_set DROP CONSTRAINT ts_family
/

ALTER TABLE gsmadmin_internal.tablespace_set DROP CONSTRAINT ts_partset
/

ALTER TABLE gsmadmin_internal.shard_ts DROP CONSTRAINT sts_ts
/

ALTER TABLE gsmadmin_internal.shard_ts DROP CONSTRAINT sts_chunks
/

ALTER TABLE gsmadmin_internal.global_table DROP CONSTRAINT gt_family
/

ALTER TABLE gsmadmin_internal.ts_set_table DROP CONSTRAINT ts_set_ts
/

ALTER TABLE gsmadmin_internal.ts_set_table DROP CONSTRAINT ts_set_gt
/

-------------------------------------------------------------------------------
-- all changes made in 12.1.0.2 (only droppped if downgrading below 12.1.0.2)
-------------------------------------------------------------------------------

DECLARE
   prev_version varchar2(30);
BEGIN
   SELECT prv_version INTO prev_version FROM registry$
      WHERE cid = 'CATPROC';

   IF prev_version < '12.1.0.2' THEN
      -- remove table objects not in versions below 12.1.0.2
      execute immediate 'ALTER TABLE 
         gsmadmin_internal.service_preferred_available DROP COLUMN dbparams';
      execute immediate 'ALTER TABLE 
         gsmadmin_internal.service_preferred_available DROP COLUMN instances';
      execute immediate 'ALTER TABLE
         gsmadmin_internal.gsm_requests DROP COLUMN old_instances';
          execute immediate 'DROP PACKAGE gsmadmin_internal.dbms_gsm_alerts';
      -- Per dowgrade guidelines, just set new columns back to default values
      UPDATE gsmadmin_internal.service_preferred_available 
         SET change_state = NULL;
      UPDATE gsmadmin_internal.region SET change_state = NULL;
      UPDATE gsmadmin_internal.region SET weights = NULL;
      UPDATE gsmadmin_internal.service SET change_state = NULL;
      UPDATE gsmadmin_internal.database SET encrypted_gsm_password = NULL;
      UPDATE gsmadmin_internal.cloud SET private_key = NULL;
      UPDATE gsmadmin_internal.cloud SET public_key  = NULL;
      UPDATE gsmadmin_internal.cloud SET prvk_enc_str = NULL;
      UPDATE gsmadmin_internal.cloud SET data_vers = NULL;
      UPDATE gsmadmin_internal.database  SET srlat_thresh=20;
      UPDATE gsmadmin_internal.database  SET cpu_thresh=75;
      UPDATE gsmadmin_internal.database  SET version=NULL;
      UPDATE gsmadmin_internal.database  SET db_type=NULL;
      UPDATE gsmadmin_internal.cloud SET data_vers = NULL;
      UPDATE gsmadmin_internal.gsm SET version = NULL;
      UPDATE gsmadmin_internal.gsm SET change_state = NULL;
   END IF;
END;
/

-------------------------------------------------------------------------------
-- 12.2 new packages and procedures
-------------------------------------------------------------------------------

DROP PACKAGE dbms_gsm_fixed
/

DROP PACKAGE dbms_gsm_fix
/

DROP PACKAGE gsmadmin_internal.dbms_gsm_xdb
/

DROP PACKAGE gsmadmin_internal.exchange
/

DROP PROCEDURE gsmadmin_internal.executeDDL
/

DROP PROCEDURE gsmadmin_internal.exec_sql
/

DROP PROCEDURE SYS.execAsUser
/
DROP PROCEDURE SYS.exec_shard_plsql
/

DROP PROCEDURE DBMS_FEATURE_SHARD
/

DROP PACKAGE dbms_goldengate_adm
/
DROP PUBLIC SYNONYM dbms_goldengate_adm
/
DROP PACKAGE dbms_goldengate_adm_internal
/
DROP PACKAGE dbms_goldengate_adm_int_invok
/
DROP PACKAGE dbms_goldengate_imp
/
DROP PACKAGE dbms_goldengate_exp
/

DROP PACKAGE dbms_pclxutil_internal
/

DROP PACKAGE dbms_registry_extended
/
-------------------------------------------------------------------------------
-- 12.2 changes to table CLOUD
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.cloud MODIFY name VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.cloud MODIFY mastergsm VARCHAR2(30)
/

UPDATE gsmadmin_internal.cloud SET last_ddl_num=0
/

UPDATE gsmadmin_internal.cloud SET last_syncddl_num=0
/

UPDATE gsmadmin_internal.cloud SET region_num=NULL
/

UPDATE gsmadmin_internal.cloud SET deploy_state=0
/

UPDATE gsmadmin_internal.cloud SET objnum_gen=1000000
/

UPDATE gsmadmin_internal.cloud SET sharding_type=NULL
/

UPDATE gsmadmin_internal.cloud SET replication_type=NULL
/

UPDATE gsmadmin_internal.cloud SET protection_mode=NULL
/

UPDATE gsmadmin_internal.cloud SET replication_factor=NULL
/

UPDATE gsmadmin_internal.cloud SET chunk_count=NULL
/

-------------------------------------------------------------------------------
-- 12.2 changes to table REGION
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.region MODIFY name VARCHAR2(30)
/

UPDATE gsmadmin_internal.region SET cs_weight=NULL
/

-------------------------------------------------------------------------------
-- 12.2 changes to table DATABASE_POOL
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.database_pool MODIFY name VARCHAR2(30)
/

UPDATE gsmadmin_internal.database_pool SET replication_type=NULL
/

UPDATE gsmadmin_internal.database_pool SET pool_type=0
/

-------------------------------------------------------------------------------
-- 12.2 changes to table DATABASE_POOL_ADMIN
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.database_pool_admin
   MODIFY pool_name VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.database_pool_admin
   MODIFY user_name VARCHAR2(30)
/

-------------------------------------------------------------------------------
-- 12.2 changes to table SERVICE_PREFERRED_AVAILABLE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.service_preferred_available
   DROP CONSTRAINT fk_db_spa
/

ALTER TABLE gsmadmin_internal.service_preferred_available
   DROP CONSTRAINT spa_in_pool
/

ALTER TABLE gsmadmin_internal.service_preferred_available
   MODIFY pool_name VARCHAR2(30)
/

UPDATE gsmadmin_internal.service_preferred_available SET change_state=NULL 
/

-------------------------------------------------------------------------------
-- 12.2 changes to table DATABASE
-------------------------------------------------------------------------------

-- constraints
ALTER TABLE gsmadmin_internal.database DROP PRIMARY KEY
/

ALTER TABLE gsmadmin_internal.database ADD PRIMARY KEY(name)
/

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT in_shardgroup
/

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT in_drset
/

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT in_shardspace
/

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT name_unique
/

ALTER TABLE gsmadmin_internal.database DROP CONSTRAINT in_vncr
/

-- columns
ALTER TABLE gsmadmin_internal.database MODIFY pool_name VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.database
   MODIFY gsm_password VARCHAR2(30)
/

UPDATE gsmadmin_internal.database
   SET connect_string = substr(connect_string, 1, 256)
/

UPDATE gsmadmin_internal.database
   SET scan_address=substr(scan_address, 1, 256)
/

ALTER TABLE gsmadmin_internal.database
   MODIFY connect_string VARCHAR2(256)
/

ALTER TABLE gsmadmin_internal.database
   MODIFY scan_address VARCHAR2(256)
/

UPDATE gsmadmin_internal.database SET encrypted_gsm_password=NULL
/

UPDATE gsmadmin_internal.database SET hostid=NULL  
/

UPDATE gsmadmin_internal.database SET oracle_home=NULL  
/

UPDATE gsmadmin_internal.database SET shardgroup_id=NULL  
/

UPDATE gsmadmin_internal.database SET ddl_num=0
/

UPDATE gsmadmin_internal.database SET ddl_error=NULL
/

UPDATE gsmadmin_internal.database SET dpl_status=0
/

UPDATE gsmadmin_internal.database SET conv_state=NULL
/

UPDATE gsmadmin_internal.database SET DRSET_NUMBER=NULL 
/

UPDATE gsmadmin_internal.database SET DEPLOY_AS=0 
/

UPDATE gsmadmin_internal.database SET is_monitored=0
/

UPDATE gsmadmin_internal.database SET SHARDSPACE_ID=NULL
/

-- New type so drop column
ALTER TABLE gsmadmin_internal.database DROP COLUMN dg_params
/

UPDATE gsmadmin_internal.database SET FLAGS=NULL
/

UPDATE gsmadmin_internal.database SET DESTINATION=NULL
/

UPDATE gsmadmin_internal.database SET CREDENTIAL=NULL
/

UPDATE gsmadmin_internal.database SET DBPARAMFILE=NULL
/

UPDATE gsmadmin_internal.database SET DBTEMPLATEFILE=NULL
/

UPDATE gsmadmin_internal.database SET NETPARAMFILE=NULL
/

UPDATE gsmadmin_internal.database SET SYS_PASSWORD=NULL
/

UPDATE gsmadmin_internal.database SET SYSTEM_PASSWORD=NULL
/

UPDATE gsmadmin_internal.database SET SVCUSERCREDENTIAL=NULL
/

UPDATE gsmadmin_internal.database SET DBNAME=NULL
/

UPDATE gsmadmin_internal.database SET DBDOMAIN=NULL
/

UPDATE gsmadmin_internal.database SET DBUNIQUENAME=NULL
/

UPDATE gsmadmin_internal.database SET INSTANCENAME=NULL
/

UPDATE gsmadmin_internal.database SET MINOBJ_NUM=NULL
/

UPDATE gsmadmin_internal.database SET MAXOBJ_NUM=NULL
/

UPDATE gsmadmin_internal.database SET GSM_REQUEST#=0
/

UPDATE gsmadmin_internal.database SET response_code=NULL
/

UPDATE gsmadmin_internal.database SET response_info=NULL
/

UPDATE gsmadmin_internal.database SET error_info=NULL
/

UPDATE gsmadmin_internal.database SET int_dbnum=0
/

UPDATE gsmadmin_internal.database SET RACK=NULL
/

UPDATE gsmadmin_internal.database SET CDB_NAME=NULL
/

UPDATE gsmadmin_internal.database SET GG_SERVICE=NULL
/

UPDATE gsmadmin_internal.database SET GG_PASSWORD=NULL
/

UPDATE gsmadmin_internal.database SET SPARE1=NULL
/

UPDATE gsmadmin_internal.database SET SPARE2=NULL
/

-------------------------------------------------------------------------------
-- 12.2 changes to table VNCR
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.vncr DROP CONSTRAINT pk_vncr
/

ALTER TABLE gsmadmin_internal.vncr DROP CONSTRAINT vncr_name
/

ALTER TABLE gsmadmin_internal.vncr MODIFY hostid NUMBER NULL
/

UPDATE gsmadmin_internal.vncr SET hostid=NULL
/

UPDATE gsmadmin_internal.vncr SET hostname=NULL
/

UPDATE gsmadmin_internal.vncr SET name=substr(name, 1, 256)
/

ALTER TABLE gsmadmin_internal.vncr MODIFY name VARCHAR2(256)
/

ALTER TABLE gsmadmin_internal.vncr MODIFY group_id VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.vncr ADD CONSTRAINT pk_vncr primary key(name)
/


-------------------------------------------------------------------------------
-- 12.2 changes to table SERVICE
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.service DROP CONSTRAINT in_family
/

UPDATE gsmadmin_internal.service
   SET network_name=substr(network_name, 1, 250)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY network_name VARCHAR2(250)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY pool_name VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY failover_method VARCHAR2(6)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY failover_type VARCHAR2(12)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY edition VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.service 
   MODIFY pdb VARCHAR2(30)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY session_state_consistency VARCHAR2(7)
/

ALTER TABLE gsmadmin_internal.service
   MODIFY sql_translation_profile VARCHAR2(30)
/

UPDATE gsmadmin_internal.service SET table_family=NULL
/

UPDATE gsmadmin_internal.service SET stop_option=NULL
/

UPDATE gsmadmin_internal.service SET drain_timeout=NULL
/

-------------------------------------------------------------------------------
-- 12.2 changes to table GSM
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.gsm MODIFY name VARCHAR2(30)
/

UPDATE gsmadmin_internal.gsm SET endpoint1=substr(endpoint1, 1, 256)
/

UPDATE gsmadmin_internal.gsm SET endpoint2=substr(endpoint2, 1, 256)
/

ALTER TABLE gsmadmin_internal.gsm MODIFY endpoint1 VARCHAR2(256)
/

ALTER TABLE gsmadmin_internal.gsm MODIFY endpoint2 VARCHAR2(256)
/

-------------------------------------------------------------------------------
-- 12.2 changes to table GSM_REQUESTS
-------------------------------------------------------------------------------

ALTER TABLE gsmadmin_internal.gsm_requests DROP CONSTRAINT ddl_rec
/

ALTER TABLE gsmadmin_internal.gsm_requests DROP CONSTRAINT prnt_req
/

ALTER TABLE gsmadmin_internal.gsm_requests DROP PRIMARY KEY
/

UPDATE gsmadmin_internal.gsm_requests SET error_num = NULL
/

UPDATE gsmadmin_internal.gsm_requests SET ddl_num = NULL 
/

UPDATE gsmadmin_internal.gsm_requests SET parent_request= NULL 
/

-------------------------------------------------------------------------------
-- 12.2 New views
-------------------------------------------------------------------------------

DROP PUBLIC SYNONYM local_chunk_types FORCE
/

DROP PUBLIC SYNONYM sha_databases FORCE
/

DROP VIEW gsmadmin_internal.local_chunk_types
/

DROP PUBLIC SYNONYM local_chunk_columns FORCE
/

DROP VIEW gsmadmin_internal.local_chunk_columns
/

DROP PUBLIC SYNONYM local_chunks FORCE
/

DROP VIEW gsmadmin_internal.local_chunks
/

DROP VIEW gsmadmin_internal.sha_databases
/

-------------------------------------------------------------------------------
-- 12.2 New tables
-------------------------------------------------------------------------------

TRUNCATE TABLE gsmadmin_internal.SHARD_SPACE
/

-- needs to be droped becasue it uses new type
DROP TABLE gsmadmin_internal.BROKER_CONFIGS
/

TRUNCATE TABLE gsmadmin_internal.SHARD_GROUP
/

TRUNCATE TABLE gsmadmin_internal.TABLE_FAMILY
/

TRUNCATE TABLE gsmadmin_internal.SHARDKEY_COLUMNS
/

DROP TABLE gsmadmin_internal.CATALOG_REQUESTS
/

TRUNCATE TABLE gsmadmin_internal.CHUNKS
/

TRUNCATE TABLE gsmadmin_internal.ALL_CHUNKS
/

TRUNCATE TABLE gsmadmin_internal.CHUNK_LOC
/

TRUNCATE TABLE gsmadmin_internal.PARTITION_SET
/

TRUNCATE TABLE gsmadmin_internal.TABLESPACE_SET
/

TRUNCATE TABLE gsmadmin_internal.SHARD_TS
/

TRUNCATE TABLE gsmadmin_internal.GLOBAL_TABLE
/

TRUNCATE TABLE gsmadmin_internal.TS_SET_TABLE
/

TRUNCATE TABLE gsmadmin_internal.DDLID$
/

TRUNCATE TABLE gsmadmin_internal.FILES
/

TRUNCATE TABLE gsmadmin_internal.CREDENTIAL
/

TRUNCATE TABLE sys.ddl_requests_pwd
/

TRUNCATE TABLE sys.ddl_requests
/

-- New table in 12.2.0.2 which uses dbparams_list type; needs to be droppped
-- when downgrading below 12.2.0.1
DROP TABLE gsmadmin_internal.container_database
/

-- Global temporary tables

DROP TABLE gsmadmin_internal.CHUNKDATA_TMP
/

-- needs to be droppped here because it uses multiple types below
DROP TYPE gsmadmin_internal.gsm_info
/

-------------------------------------------------------------------------------
-- Types used in new 12.1.0.2 and 12.2
-- (only remove if downgrading below 12.1.0.2)
-------------------------------------------------------------------------------
DECLARE
   prev_version varchar2(30);
BEGIN
   SELECT prv_version INTO prev_version FROM registry$
      WHERE cid = 'CATPROC';

   IF prev_version < '12.1.0.2' THEN
      execute immediate 'DROP TYPE gsmadmin_internal.instance_list';
      execute immediate 'DROP TYPE gsmadmin_internal.rac_instance_t';
      execute immediate 'DROP TYPE gsmadmin_internal.instance_list_t';
      execute immediate 'DROP TYPE gsmadmin_internal.instance_t';
      execute immediate 'DROP TYPE gsmadmin_internal.dbparams_list';
      execute immediate 'DROP TYPE gsmadmin_internal.dbparams_t';
      execute immediate 'DROP TYPE gsmadmin_internal.database_dsc_t';
      execute immediate 'DROP TYPE gsmadmin_internal.service_dsc_list_t';
      execute immediate 'DROP TYPE gsmadmin_internal.service_dsc_t';
      execute immediate 'DROP TYPE gsmadmin_internal.warning_list_t';
      execute immediate 'DROP TYPE gsmadmin_internal.warning_t';
      execute immediate 'DROP TYPE gsmadmin_internal.tvers_lookup_t';
      execute immediate 'DROP TYPE gsmadmin_internal.vers_lookup_t';
      execute immediate 'DROP TYPE gsmadmin_internal.tvers_rec';
      execute immediate 'DROP TYPE gsmadmin_internal.vers_lookup_rec';
      execute immediate 'DROP TYPE gsmadmin_internal.vers_list';
      execute immediate 'DROP TYPE gsmadmin_internal.gsm_session';
   END IF;
END;
/

-------------------------------------------------------------------------------
-- Types used only in new 12.2 columns
-------------------------------------------------------------------------------

DROP TYPE gsmadmin_internal.name_list
/

DROP TYPE gsmadmin_internal.shard_list_t
/

DROP TYPE gsmadmin_internal.shard_t
/

DROP TYPE gsmadmin_internal.number_list
/

DROP TYPE gsmadmin_internal.chunkrange_list_t
/

DROP TYPE gsmadmin_internal.chunkrange_t
/

DROP TYPE BODY gsmadmin_internal.service_dsc_t
/

DROP TYPE gsmadmin_internal.t_shdcol_tab
/

DROP TYPE gsmadmin_internal.t_shdcol_row
/

-------------------------------------------------------------------------------
-- New sequences in 12.2
-------------------------------------------------------------------------------

DROP SEQUENCE gsmadmin_internal.shardspace_sequence
/

DROP SEQUENCE gsmadmin_internal.shardgroup_sequence
/

DROP SEQUENCE gsmadmin_internal.drset_sequence
/

DROP SEQUENCE gsmadmin_internal.family_sequence
/

DROP SEQUENCE gsmadmin_internal.cat_sequence
/

DROP SEQUENCE gsmadmin_internal.sid_sequence
/

DROP SEQUENCE gsmadmin_internal.files_sequence
/

DROP SEQUENCE gsmadmin_internal.credential_sequence
/

DROP SEQUENCE gsmadmin_internal.int_dbnum_sequence
/

DROP SEQUENCE gsmadmin_internal.vncr_sequence
/

------------------------------------------------------------------------------
-- Other objects new in 12.2
------------------------------------------------------------------------------
DROP CONTEXT shard_ctx
/

DROP CONTEXT shard_ctx2
/
-------------------------------------------------------------------------------
-- Revoke priviliges to gsmadmin_internal
-------------------------------------------------------------------------------
REVOKE select on sys.col$ from gsmadmin_internal
/
REVOKE execute on sys.dbms_sys_sql from gsmadmin_internal
/
REVOKE create tablespace from gsmadmin_internal
/
COMMIT
/

show errors

Rem ===================================================================
Rem GDS metric fixed views 
Rem ===================================================================

drop view GV_$CHUNK_METRIC;
drop public synonym GV$CHUNK_METRIC;

drop view V_$CHUNK_METRIC;
drop public synonym V$CHUNK_METRIC;

drop view GV_$SERVICE_REGION_METRIC;
drop public synonym GV$SERVICE_REGION_METRIC;

drop view V_$SERVICE_REGION_METRIC;
drop public synonym V$SERVICE_REGION_METRIC;

Rem ====================================================================
Rem END GDS changes since 12.1.0.1
Rem ===================================================================

Rem *************************************************************************
Rem BEGIN GG Sharding
Rem *************************************************************************

delete from default_pwd$ where user_name = 'GGSYS';
commit;

drop role ggsys_role;
drop user ggsys cascade;

Rem *************************************************************************
Rem END OGG Sharding
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Changes for WLM
Rem =======================================================================
Rem Drop table required due to package dependencies
Rem so that the WLM user, appqossys can be dropped without cascade
Rem specified after all its tables are removed.

drop public synonym v$wlm_db_mode;
drop view v_$wlm_db_mode;
drop public synonym gv$wlm_db_mode;
drop view gv_$wlm_db_mode;

drop table appqossys.wlm_feature_usage;

alter user APPQOSSYS set container_data=default for "PUBLIC".v$containers;
revoke SELECT on sys.v_$containers from APPQOSSYS;

Rem =======================================================================
Rem  End Changes for WLM
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Gateway feature usage
Rem =======================================================================

drop procedure  DBMS_FEATURE_GATEWAYS;

Rem =======================================================================
Rem  End Changes for Gateway feature usage
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Data Mining feature usage
Rem =======================================================================

drop procedure DBMS_FEATURE_DATABASE_ODM;

Rem =======================================================================
Rem  End Changes for Data Mining feature usage
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$EVENT_OUTLIERS
Rem =======================================================================
 
drop public synonym gv$event_outliers;
drop view gv_$event_outliers;
drop public synonym v$event_outliers;
drop view v_$event_outliers;

Rem =======================================================================
Rem END Changes for [G]V$EVENT_OUTLIERS
Rem =======================================================================  

Rem =======================================================================
Rem  Begin Changes for Unified Auditing
Rem =======================================================================

Rem Bug 16066652
declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  -- Drop the column only if downgrading to 12.1.0.1 or lower
  if prev_version < '12.1.0.2' then 
    execute immediate 'alter table sys.dam_cleanup_jobs$ ' || 
                      'drop column job_flags';
  end if;
end;
/

Rem Bug 15996683
drop table UNIFIED_MISC_AUDITED_ACTIONS;

Rem Bug 19480441
Rem Audit policies enabled on users with granted roles does not make sense
Rem in DB version lower than 12.2, it is better to delete them than having
Rem stale entries in the dictionary. Performing the NOAUDIT on such policies
Rem delete the entries from dictionary and updates the user cache as well.

Rem Bug 21427375: Replace the references of audit_unified_policies and
Rem   audit_unified_enabled_policies views with their underlying dictionary
Rem   tables. The view could become invalid, e.g. if any of its dependent
Rem   object gets dropped.

begin
  for item in
    (select o.name policy_name, u.name entity_name, u.type# entity_type
       from sys.obj$ o, sys.audit_ng$ a, sys.user$ u
       where a.user# = u.user# and a.policy# = o.obj#)
  loop
    if item.entity_type = 0 then
      execute immediate 'noaudit policy '|| item.policy_name ||
                         ' by users with granted roles '|| item.entity_name;
    end if;
  end loop; 
end; 
/

Rem Bug 20383779: Remove auditing on BECOME USER on downgrade from 12.2
noaudit BECOME USER;

alter audit policy ora_secureconfig drop privileges BECOME USER;

Rem *************************************************************************
Rem Begin Bug 14168362: Support cleanup of old dbid and guid based audit data
Rem *************************************************************************

drop index sys.i_dam_last_arch_ts$;
declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version = '12.1.0.1' then 
    execute immediate 'create unique index sys.i_dam_last_arch_ts$ ' ||
                      'on sys.dam_last_arch_ts$ ' ||
                      '(audit_trail_type#, rac_instance#)';
  elsif prev_version < '12.1.0.1' then 
    execute immediate 'alter table sys.dam_last_arch_ts$ add constraint ' ||
                      'DAM_LAST_ARCH_TS_UK1 unique ' ||
                      '(audit_trail_type#, rac_instance#)';
  end if;
  /* Bug 22537605: Re-create the index on sys.dam_last_arch_ts$ during
   * downgrade to 12.1.0.2
   */
  if prev_version = '12.1.0.2' then
    execute immediate 'create unique index sys.i_dam_last_arch_ts$ ' ||
                      'on sys.dam_last_arch_ts$ ' ||
    '(audit_trail_type#, rac_instance#, database_id, container_guid)';
  end if;
  -- Drop the columns only if downgrading to 12.1.0.1 or lower
  if prev_version < '12.1.0.2' then 
    execute immediate 'alter table sys.dam_last_arch_ts$ ' ||
                      'drop column database_id';
  end if;
  if prev_version < '12.1.0.2' then 
    execute immediate 'alter table sys.dam_last_arch_ts$ ' ||
                      'drop column container_guid';
  end if;
end;
/

Rem *************************************************************************
Rem End Bug 14168362: Support cleanup of old dbid and guid based audit data
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 17299076 drop  ORA_CIS_RECOMMENDATIONS audit policy
Rem       Bug 18174384 drop  ORA_LOGON_FAILURES
Rem *************************************************************************
begin
  for item in
    (select o.name policy_name, u.name user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a, sys.user$ u
       where a.user# = u.user# and a.policy# = o.obj# and
             o.name = 'ORA_CIS_RECOMMENDATIONS'
     union all 
     select o.name policy_name, 'ALL USERS' user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a
       where a.user#  = -1 and a.policy# = o.obj# and
             o.name = 'ORA_CIS_RECOMMENDATIONS')
  loop
    if item.user_name = 'ALL USERS' or item.enabled_opt = 2 then
      execute immediate 'noaudit policy '|| item.policy_name;
    else
      execute immediate 'noaudit policy '|| item.policy_name ||
                                    ' by '|| item.user_name;
    end if;
  end loop;
end;
/
drop audit policy ORA_CIS_RECOMMENDATIONS
/
begin
  for item in
    (select o.name policy_name, u.name user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a, sys.user$ u
       where a.user# = u.user# and a.policy# = o.obj# and
             o.name = 'ORA_LOGON_FAILURES'
     union all 
     select o.name policy_name, 'ALL USERS' user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a
       where a.user#  = -1 and a.policy# = o.obj# and
             o.name = 'ORA_LOGON_FAILURES')
  loop
    if item.user_name = 'ALL USERS' or item.enabled_opt = 2 then
      execute immediate 'noaudit policy '|| item.policy_name;
    else
      execute immediate 'noaudit policy '|| item.policy_name ||
                                    ' by '|| item.user_name;
    end if;
  end loop;
end;
/
drop audit policy ORA_LOGON_FAILURES 
/
Rem ***********************************************************************
Rem End Bug 17299076 drop  ORA_CIS_RECOMMENDATIONS audit policy
Rem ***********************************************************************

Rem Bug 15996683
truncate table ALL_UNIFIED_AUDIT_ACTIONS
/

Rem Bug 20280545 decrease size of sys.dam_cleanup_jobs$.job_name
alter table sys.dam_cleanup_jobs$ modify job_name varchar2(100)
/

Rem Bug 21370358
drop table AUDSYS.AUD$UNIFIED;

rem bug 21787568
delete from audit_actions where action = 125;
delete from audit_actions where action = 126;
delete from audit_actions where action = 135;
insert into audit_actions values (135, 'DIRECTORY EXECUTE');

delete from STMT_AUDIT_OPTION_MAP where OPTION# in (362,363,364);

Rem =======================================================================
Rem  End Changes for Unified Auditing
Rem =======================================================================

Rem *************************************************************************
Rem Exadirect Secure - BEGIN
Rem *************************************************************************

drop user DBSFWUSER cascade;
drop view V_X$KSWSASTAB;
drop view V_$EXADIRECT_ACL;
drop public synonym V$EXADIRECT_ACL;
drop view GV_$EXADIRECT_ACL;
drop public synonym GV$EXADIRECT_ACL;
drop view V_$IP_ACL;
drop public synonym V$IP_ACL;
drop view GV_$IP_ACL;
drop public synonym GV$IP_ACL;

Rem *************************************************************************
Rem Exadirect Secure - END
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for RAS
Rem =======================================================================

-- drop user_xs_users view
drop public synonym USER_XS_USERS;
drop view SYS.USER_XS_USERS;

-- drop USER_XS_PASSWORD_LIMITS view
drop public synonym USER_XS_PASSWORD_LIMITS;
drop view SYS.USER_XS_PASSWORD_LIMITS;

-- Update new columns to default values which are added as part of project#46908
-- Per downgrade guideline: drop columns are not recommended. Instead, update
-- those columns to the default values.
update sys.xs$prin set profile# = 0;
update sys.xs$prin set astatus = 0;

-- add column profile varchar2(128) dropped as part of project#46908
declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version < '12.1.0.2' then
    execute immediate 'alter table sys.xs$prin add profile varchar2(128)';
  end if;
end;
/ 

-- drop column description
declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version < '12.1.0.2' then
    execute immediate 'alter table sys.xs$instset_rule drop column description';
  end if;
end;
/ 

-- drop type XS$REALM_CONSTRAINT_TYPE
drop type XS$REALM_CONSTRAINT_TYPE force;

-- change column acloid data type in rxs$sessions
truncate table sys.rxs$sessions;
alter table sys.rxs$sessions modify (acloid raw(16));

-- delete privileges APPLY_SEC_POLICY, SET_DYNAMIC_ROLES
declare
  priv_id number;
  cursor aces is select distinct acl#, ace_order# 
                 from sys.xs$ace_priv
                 where priv# = 
                  (select id from sys.xs$obj where name = 'SET_DYNAMIC_ROLES');
begin

  select id into priv_id from sys.xs$obj where name = 'APPLY_SEC_POLICY';
  delete from sys.xs$priv where priv#=priv_id;
  delete from sys.xs$obj where id=priv_id;

  select id into priv_id from sys.xs$obj where name = 'SET_DYNAMIC_ROLES';
  for aces_crec in aces loop
    delete from xs$ace_priv where priv#= priv_id and acl# = aces_crec.acl# 
                              and ace_order#= aces_crec.ace_order#;
    delete from sys.xs$ace where acl# = aces_crec.acl# and 
                                 order# = aces_crec.ace_order#;
  end loop;
  delete from sys.xs$aggr_priv where implied_priv#=priv_id;
  delete from sys.xs$priv where priv#=priv_id;
  delete from sys.xs$obj where id=priv_id;

  commit;
exception
  when others then
    null;
end;
/
show errors;

Rem =======================================================================
Rem  End Changes for RAS
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Logminer
Rem =======================================================================

-- These types are local to prvtlmcb.sql and are not used outside them. 
-- These types are used for returning rows from logminer table functions
-- and wont be persisted. 
-- In earlier releases we didnt drop the types before creating them in 
-- prvtlmcb.sql.Hence dropping them here so that running prvtlmcb.sql in
-- the downgraded db wont error.

drop TYPE SYSTEM.LOGMNR$TAB_GG_RECS ;
drop TYPE SYSTEM.LOGMNR$COL_GG_RECS ;
drop TYPE SYSTEM.LOGMNR$SEQ_GG_RECS ;
drop TYPE SYSTEM.LOGMNR$KEY_GG_RECS ;
drop TYPE SYSTEM.LOGMNR$GSBA_GG_RECS ;

drop TYPE SYSTEM.LOGMNR$TAB_GG_REC ;
drop TYPE SYSTEM.LOGMNR$COL_GG_REC ;
drop TYPE SYSTEM.LOGMNR$SEQ_GG_REC ;
drop TYPE SYSTEM.LOGMNR$KEY_GG_REC ;
drop TYPE SYSTEM.LOGMNR$GSBA_GG_REC ;

-- Drop these types rather than altering them since you can't decrease 
-- object attribute width.
drop type sys.logmnr$alwayssuplog_srecs force;
drop type sys.logmnr$alwayssuplog_srec force;

drop FUNCTION SYSTEM.LOGMNR$GSBA_GG_TABF_PUBLIC ;

update SYSTEM.LOGMNRC_GSBA set DB_GLOBAL_NAME = NULL;
commit;

-- At most one row can exist in global$ prior to 12.2.  This row corresponds
-- corresponds with fast recovery area state on an active logical standby
-- database.  If there is a single global$ record, its session# column can 
-- safely be cleared.  In the presence of multiple records, we could be 
-- downgrading from an errant state.  In such a case, we err on the side of
-- caution, and truncate the table to allow for the global$ entry to be 
-- re-created at the expense of a full scan of the foreign log section of 
-- the control file.
declare
  rowcount  number;
begin
  select count(1) into rowcount from system.logmnr_global$;
  if rowcount = 1 then 
    update system.logmnr_global$ set session# = null;
    commit;
  else
    execute immediate 'truncate table system.logmnr_global$';
  end if;
end;
/

update system.logmnr_container$
  set vsn = null,
      fed_root_con_id# =null;
commit;

update system.logmnr_dictionary$
  set fed_root_con_id# = null;
commit;

-- Added for Sharding
update system.logmnr_ts$ set start_scnbas = null, start_scnwrp = null;
commit;
truncate table system.logmnrc_tspart;
truncate table system.logmnrc_ts;
truncate table system.logmnrc_shard_ts;
truncate table system.logmnr_shard_ts;
truncate table sys.logmnrg_shard_ts;

/* Added for automatic CDR */
update system.logmnrggc_gtlo set acdrflags = NULL, acdrtsobj# = NULL,
                                 acdrrowtsintcol# = NULL;
update system.logmnrggc_gtcs set collid = NULL, collintcol# = NULL,
                                 acdrrescol# = NULL;
update system.logmnrc_gtlo set acdrflags = NULL, acdrtsobj# = NULL,
                                 acdrrowtsintcol# = NULL;
update system.logmnrc_gtcs set collid = NULL, collintcol# = NULL,
                               acdrrescol# = NULL;
update system.logmnr_tab$ set acdrflags = NULL, acdrtsobj# = NULL,
                              acdrrowtsintcol# = NULL;
update system.logmnr_col$ set collid = NULL, collintcol# = NULL,
                              acdrrescol# = NULL;
commit;

/* Drop and recreate LOGMNRG_{TAB,COL}$ tables due to automatic CDR
 * and property type change
 */
-- This could be cleaned out and modified, but it should be empty
-- and other changes in this release will require it to be dropped
-- and recreated anyway.
drop table sys.logmnrg_tab$ purge;
drop table sys.logmnrg_col$ purge;
CREATE TABLE SYS.LOGMNRG_TAB$ (
      TS# NUMBER(22),
      COLS NUMBER(22),
      PROPERTY NUMBER(22),
      INTCOLS NUMBER(22),
      KERNELCOLS NUMBER(22),
      BOBJ# NUMBER(22),
      TRIGFLAG NUMBER(22),
      FLAGS NUMBER(22),
      OBJ# NUMBER(22) NOT NULL ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_COL$ (
      COL# NUMBER(22),
      SEGCOL# NUMBER(22),
      NAME VARCHAR2(128),
      TYPE# NUMBER(22),
      LENGTH NUMBER(22),
      PRECISION# NUMBER(22),
      SCALE NUMBER(22),
      NULL$ NUMBER(22),
      INTCOL# NUMBER(22),
      PROPERTY NUMBER(22),
      CHARSETID NUMBER(22),
      CHARSETFORM NUMBER(22),
      SPARE1 NUMBER(22),
      SPARE2 NUMBER(22),
      OBJ# NUMBER(22) NOT NULL ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

-- drop the view created in catlmnr_mig.sql
drop view logmnr_gtcs_cat_support_v$;

-- per pdb characterset changes (dlmnr.bsq)
alter table system.logmnr_gt_tab_include$ modify (schema_name varchar2(130));
alter table system.logmnr_gt_tab_include$ modify (table_name varchar2(130));
alter table system.logmnr_gt_tab_include$ modify (pdb_name varchar2(130));

alter table system.logmnr_gt_user_include$ modify (user_name varchar2(130));
alter table system.logmnr_gt_user_include$ modify (pdb_name varchar2(130));

alter table system.logmnr_pdb_info$ modify (pdb_name varchar2(128));
alter table system.logmnr_pdb_info$ modify (pdb_global_name varchar2(128));

alter table system.logmnr_uid$ modify (pdb_name varchar2(128));

alter table system.logmnrggc_gtlo modify (ownername varchar2(128));
alter table system.logmnrggc_gtlo modify (lvl0name varchar2(128));
alter table system.logmnrggc_gtlo modify (lvl1name varchar2(128));
alter table system.logmnrggc_gtlo modify (lvl2name varchar2(128));
alter table system.logmnrggc_gtlo modify (tsname varchar2(30));

alter table system.logmnrggc_gtcs modify (colname varchar2(128));
alter table system.logmnrggc_gtcs modify (typename varchar2(128));
alter table system.logmnrggc_gtcs modify (xtypeschemaname varchar2(128));
alter table system.logmnrggc_gtcs modify (eamkeyid varchar2(64));

alter table system.logmnrc_dbname_uid_map modify (global_name varchar2(128));
alter table system.logmnrc_dbname_uid_map modify (pdb_name varchar2(128));

alter table system.logmnr_parameter$ modify (name varchar2(128));

alter table system.logmnr_session$ modify (global_db_name varchar2(128));

-- per pdb characterset changes (catlmnr.sql)
alter table system.logmnrc_gtlo modify (ownername varchar2(128));
alter table system.logmnrc_gtlo modify (lvl0name varchar2(128));
alter table system.logmnrc_gtlo modify (lvl1name varchar2(128));
alter table system.logmnrc_gtlo modify (lvl2name varchar2(128));
alter table system.logmnrc_gtlo modify (tsname varchar2(30));

alter table system.logmnrc_gtcs modify (colname  varchar2(128));
alter table system.logmnrc_gtcs modify (typename varchar2(128));
alter table system.logmnrc_gtcs modify (xtypeschemaname varchar2(128));
alter table system.logmnrc_gtcs modify (eamkeyid varchar2(64));

alter table system.logmnrc_seq_gg modify (ownername varchar2(128));
alter table system.logmnrc_seq_gg modify (objname varchar2(128));

alter table system.logmnrc_con_gg modify (name varchar2(128));

alter table system.logmnrc_ind_gg modify (name varchar2(128));
alter table system.logmnrc_ind_gg modify (ownername varchar2(128));

alter table system.logmnrc_gsba modify (dbtimezone_value varchar2(64));
-- logmnrc_gsba.db_global_name added above for this release, no need to modify

alter table system.logmnr_seed$ modify (schemaname varchar2(128));
alter table system.logmnr_seed$ modify (table_name varchar2(128));
alter table system.logmnr_seed$ modify (col_name varchar2(128));

alter table system.logmnr_dictionary$ modify (db_name varchar2(9));

alter table system.logmnr_dictionary$ modify (db_character_set varchar2(128));
alter table system.logmnr_dictionary$ modify (db_version varchar(64));
alter table system.logmnr_dictionary$ modify (db_status varchar(64));
alter table system.logmnr_dictionary$ modify (db_global_name varchar(128));
alter table system.logmnr_dictionary$ modify (pdb_name varchar2(30));
alter table system.logmnr_dictionary$ modify (pdb_global_name varchar2(128));

alter table system.logmnr_obj$ modify (name varchar2(128));
alter table system.logmnr_obj$ modify (subname varchar2(128));
alter table system.logmnr_obj$ modify (remoteowner varchar2(128));
alter table system.logmnr_obj$ modify (linkname varchar(128));

alter table system.logmnr_col$ modify (name varchar2(128));

alter table system.logmnr_ts$ modify (name varchar2(30));

alter table system.logmnr_user$ modify (name varchar2(128));

alter table system.logmnr_type$ modify (version  varchar2(128));

alter table system.logmnr_attribute$ modify (name varchar2(128));

alter table system.logmnr_con$ modify (name varchar2(128));

alter table system.logmnr_kopm$ modify (name varchar2(128));

alter table system.logmnr_props$ modify (name varchar2(128));

alter table system.logmnr_enc$ modify (mkeyid varchar2(64));

alter table system.logmnr_partobj$ modify (parameters varchar2(1000));

-- end per pdb characterset changes

-- ensure no large proeprty values remain
update system.logmnr_tab$
   set property=mod(property,power(2,64))
 where property >= power(2,64);
commit;

update system.logmnrc_gtlo
   set property=mod(property,power(2,64))
 where property >= power(2,64);
commit;

update system.logmnrggc_gtlo
   set property=mod(property,power(2,64))
 where property >= power(2,64);
commit;

/* Added for CDB non-unique xid (local undo) */
update system.logmnr_gt_xid_include$ set pdbid = NULL;
commit;

truncate table system.logmnr_spill$;
alter table system.logmnr_spill$ drop constraint
  logmnr_spill$_pk;
alter table system.logmnr_spill$ add constraint
  logmnr_spill$_pk primary key
  (session#, xidusn, xidslt, xidsqn, chunk,
   startidx, endidx, flag, sequence#)
  using index tablespace sysaux logging;

-- Check for conflicts and delete age spill and checkpoint table
-- entries so downgrade will succeed.  Note that a session with
-- conflicts is actually unusable after the downgrade, because it has
-- already mined redo from 12.2.
declare
  cursor sessions is select distinct session# 
                       from system.logmnr_age_spill$
                       group by session#, xidusn, xidslt, xidsqn,
                                chunk, sequence#
                       having count(1) > 1;
begin
  for s in sessions loop
    delete from system.logmnr_age_spill$ where session# = s.session#;
    commit;
  end loop;
end;
/

declare
  cursor  checkpoints is
            select distinct session#, ckpt_scn 
              from system.logmnr_restart_ckpt$
              group by session#, ckpt_scn, xidusn, xidslt, xidsqn,
                       session_num, serial_num
              having count(1) > 1;
begin
  for ckpt in checkpoints loop
    delete from system.logmnr_restart_ckpt$
      where session# = ckpt.session# and ckpt_scn = ckpt.ckpt_scn;
    commit;
  end loop;
end;
/

alter table system.logmnr_age_spill$ drop constraint
  logmnr_age_spill$_pk;
alter table system.logmnr_age_spill$ add constraint
  logmnr_age_spill$_pk primary key
  (session#, xidusn, xidslt, xidsqn, chunk, sequence#)
  using index tablespace sysaux logging;
update system.logmnr_age_spill$ set pdbid = null;
commit;

alter table system.logmnr_restart_ckpt$ drop constraint
  logmnr_restart_ckpt$_pk;
alter table system.logmnr_restart_ckpt$ add constraint
  logmnr_restart_ckpt$_pk primary key
  (session#, ckpt_scn, xidusn, xidslt, xidsqn, session_num, serial_num)
  using index tablespace sysaux logging;
update system.logmnr_restart_ckpt$ set pdbid = null;
commit;

drop package dbms_logmnr_session_int;

drop table SYS.LOGMNRG_CONTAINER$ purge;
CREATE TABLE SYS.LOGMNRG_CONTAINER$ (
     OBJ#          NUMBER NOT NULL,      /* Object number for the container */
     CON_ID#       NUMBER NOT NULL,                         /* container ID */
     DBID          NUMBER NOT NULL,                          /* database ID */
     CON_UID       NUMBER NOT NULL,                            /* unique ID */
     FLAGS         NUMBER,                                         /* flags */
     STATUS        NUMBER NOT NULL,                    /* active, plugged...*/
     CREATE_SCNWRP NUMBER NOT NULL,                    /* creation scn wrap */
     CREATE_SCNBAS NUMBER NOT NULL)                    /* creation scn base */
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/
drop table SYS.LOGMNRG_DICTIONARY$ purge;
CREATE TABLE SYS.LOGMNRG_DICTIONARY$ (
      DB_NAME VARCHAR2(9),
      DB_ID NUMBER(20),
      DB_CREATED VARCHAR2(20),
      DB_DICT_CREATED VARCHAR2(20),
      DB_DICT_SCN NUMBER(22),
      DB_THREAD_MAP RAW(8),
      DB_TXN_SCNBAS NUMBER(22),
      DB_TXN_SCNWRP NUMBER(22),
      DB_RESETLOGS_CHANGE# NUMBER(22),
      DB_RESETLOGS_TIME VARCHAR2(20),
      DB_VERSION_TIME VARCHAR2(20),
      DB_REDO_TYPE_ID VARCHAR2(8),
      DB_REDO_RELEASE VARCHAR2(60),
      DB_CHARACTER_SET VARCHAR2(30),
      DB_VERSION VARCHAR2(64),
      DB_STATUS VARCHAR2(64),
      DB_GLOBAL_NAME VARCHAR(128),
      DB_DICT_MAXOBJECTS NUMBER(22),
      PDB_NAME VARCHAR(30),
      PDB_ID NUMBER,                 /* Short/Reusable PDB Identifier/Slot */
      PDB_UID NUMBER,                        /* Long/Unique PDB Identifier */
      PDB_DBID NUMBER,                         /* PDB specific databaes ID */
      PDB_GUID RAW(16),                  /* PDB Globally Unique Identifier */
      PDB_CREATE_SCN NUMBER,
      PDB_COUNT NUMBER,
      PDB_GLOBAL_NAME VARCHAR2(128),
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL  ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================

update system.logstdby$apply_milestone 
set lwm_upd_time = null, spare4 = null, spare5 = null, spare6 = null, 
    spare7 = null, pto_recovery_scn = null, pto_recovery_incarnation = null;
commit;

update system.logstdby$events set con_id = null;
commit;

drop view cdb_rolling_unsupported;
drop public synonym cdb_rolling_unsupported;

drop view dba_rolling_unsupported;
drop public synonym dba_rolling_unsupported;

drop view logstdby_ru_unsupport_tab_12_1;

drop view cdb_ptc_apply_progress;
drop view ptc_apply_progress;


drop view logstdby_unsupport_tab_12_2;
drop view logstdby_ru_unsupport_tab_12_2;
drop view logstdby_support_tab_12_2;

-- OGG compat-specific views came into being for the first time in 12.2.
drop public synonym CDB_goldengate_not_unique;
drop view CDB_goldengate_not_unique;
drop public synonym dba_goldengate_not_unique;
drop view dba_goldengate_not_unique;
drop view ogg_support_tab_12_2;
drop view ogg_support_tab_12_1;
drop view ogg_support_tab_11_2b;
drop view ogg_support_tab_11_2;

drop view "_DBA_OGG_ALL_TABLES";

-- Invalidate the guard here to force re-validation of the guard level of
-- all objects.  The 12.1 binary in use should decide the proper support level.
Update system.logstdby$parameters set value = 'NOT READY'
  where name='GUARD_STANDBY';
commit;

/* Added for CDB non-unique xid (local undo) */
update system.logstdby$skip_transaction set con_name = null;
commit;

Rem =======================================================================
Rem End Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Data Pump 
Rem =======================================================================
drop public synonym LOADER_DB_OPEN_READ_WRITE
drop view SYS.LOADER_DB_OPEN_READ_WRITE

Rem classical import view
drop view SYS.IMPRBS;

Rem Normally, columns added to dictionary tables during upgrade are NOT
Rem dropped during downgrade, but we must in this case because WMSYS
Rem inserts into impcalloutreg$ in V11.x do not specify an explicit
Rem column list and so the extra columns without values causes 
Rem ORA-00947, not enough values.

ALTER TABLE sys.impcalloutreg$ DROP COLUMN alt_schema
/
ALTER TABLE sys.impcalloutreg$ DROP COLUMN alt_name
/
ALTER TABLE sys.impcalloutreg$ DROP COLUMN ending_tgt_version
/
ALTER TABLE sys.impcalloutreg$ DROP COLUMN beginning_tgt_version
/

Rem =======================================================================
Rem End Changes for Data Pump
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$FS_OBSERVER_HISTOGRAM
Rem =======================================================================

drop public synonym v$fs_observer_histogram;
drop view v_$fs_observer_histogram;
drop public synonym gv$fs_observer_histogram;
drop view gv_$fs_observer_histogram;

Rem =======================================================================
Rem END Changes for [G]V$FS_OBSERVER_HISTOGRAM
Rem =======================================================================


Rem*************************************************************************
Rem BEGIN Changes for Scheduler - remove new import callouts
Rem*************************************************************************

TRUNCATE TABLE sys.scheduler$_resources;
TRUNCATE TABLE sys.scheduler$_constraints;
TRUNCATE TABLE sys.scheduler$_constraints_stats;

drop public synonym dba_scheduler_resources;
drop public synonym dba_scheduler_rsc_constraints;
drop public synonym dba_scheduler_incompats;
drop public synonym dba_scheduler_incompat_member;
drop public synonym all_scheduler_resources;
drop public synonym all_scheduler_rsc_constraints;
drop public synonym all_scheduler_incompats;
drop public synonym all_scheduler_incompat_member;
drop public synonym user_scheduler_resources;
drop public synonym user_scheduler_rsc_constraints;
drop public synonym user_scheduler_incompats;
drop public synonym user_scheduler_incompat_member;

drop public synonym CDB_scheduler_resources;
drop public synonym CDB_scheduler_rsc_constraints;
drop public synonym CDB_scheduler_incompats;
drop public synonym CDB_scheduler_incompat_member;

drop view sys.CDB_scheduler_resources;
drop view sys.CDB_scheduler_rsc_constraints;
drop view sys.CDB_scheduler_incompats;
drop view sys.CDB_scheduler_incompat_member;

DROP VIEW sys.scheduler$_job_objects;
DROP VIEW sys.scheduler$_running_constr_objs;
DROP VIEW sys.scheduler$_resource_usage;
DROP VIEW sys.dba_scheduler_resources;
DROP VIEW sys.dba_scheduler_rsc_constraints ;
DROP VIEW sys.dba_scheduler_incompats;
DROP VIEW sys.dba_scheduler_incompat_member;
DROP VIEW sys.all_scheduler_resources;
DROP VIEW sys.all_scheduler_rsc_constraints ;
DROP VIEW sys.all_scheduler_incompats;
DROP VIEW sys.all_scheduler_incompat_member;
DROP VIEW sys.user_scheduler_resources;
DROP VIEW sys.user_scheduler_rsc_constraints ;
DROP VIEW sys.user_scheduler_incompats;
DROP VIEW sys.user_scheduler_incompat_member;


delete from SYSAUTH$ where privilege# in ( -390);
delete from SYSTEM_PRIVILEGE_MAP where privilege in ( 390);
delete from AUDIT$ where option# in (390);
delete from STMT_AUDIT_OPTION_MAP where option# in ( -390);

drop public synonym DBMS_SCHED_CONSTRAINT_EXPORT;
drop package DBMS_SCHED_CONSTRAINT_EXPORT;

update sys.scheduler$_program set comments = substr(comments,1,240);
update sys.scheduler$_class set comments = substr(comments,1,240);
update sys.scheduler$_job set comments = substr(comments,1,240);
update sys.scheduler$_window set comments = substr(comments,1,240);
update sys.scheduler$_window_group set comments = substr(comments,1,240);
update sys.scheduler$_schedule set comments = substr(comments,1,240);
update sys.scheduler$_chain set comments = substr(comments,1,240);
update sys.scheduler$_credential set comments = substr(comments,1,240);
update scheduler$_file_watcher set comments = substr(comments,1,240);
update scheduler$_destinations set comments = substr(comments,1,240);

Rem ==================================
Rem End enabled/disabled job resource/incompatibility  support
Rem ==================================

Rem =======================================================================
Rem Begin Drop new methods defined for objects 
Rem =======================================================================
      
drop public synonym get_oldversion_hashcode2
/

drop function get_oldversion_hashcode2
/

drop procedure migrate_80sysimages_to_81
/

Rem =======================================================================
Rem End Drop new methods defined for objects 
Rem =======================================================================
      
Rem =======================================================================
Rem Begin Changes for Streams/XStream 
Rem =======================================================================
      
drop view "_DBA_XSTREAM_OUT_ALL_TABLES";
drop view "_DBA_XSTREAM_OUT_ADT_PK_TABLES";
TRUNCATE TABLE apply$_cdr_info;
drop view "_DBA_APPLY_CDR_INFO";
drop view "_DBA_XSTREAM_UNSUPPORTED_12_1";
drop view "_DBA_GG_AUTO_CDR_TABLES";
drop view "_ALL_GG_AUTO_CDR_TABLES";
DROP public synonym DBA_GG_AUTO_CDR_TABLES;
DROP public synonym CDB_GG_AUTO_CDR_TABLES;
DROP public synonym ALL_GG_AUTO_CDR_TABLES;
drop view DBA_GG_AUTO_CDR_TABLES;
drop view CDB_GG_AUTO_CDR_TABLES;
drop view ALL_GG_AUTO_CDR_TABLES;
drop view "_DBA_GG_AUTO_CDR_COLUMNS";
DROP public synonym DBA_GG_AUTO_CDR_COLUMNS;
DROP public synonym CDB_GG_AUTO_CDR_COLUMNS;
DROP public synonym ALL_GG_AUTO_CDR_COLUMNS;
drop view DBA_GG_AUTO_CDR_COLUMNS;
drop view CDB_GG_AUTO_CDR_COLUMNS;
drop view ALL_GG_AUTO_CDR_COLUMNS;
DROP public synonym DBA_GG_AUTO_CDR_COLUMN_GROUPS;
DROP public synonym CDB_GG_AUTO_CDR_COLUMN_GROUPS;
DROP public synonym ALL_GG_AUTO_CDR_COLUMN_GROUPS;
drop view DBA_GG_AUTO_CDR_COLUMN_GROUPS;
drop view CDB_GG_AUTO_CDR_COLUMN_GROUPS;
drop view ALL_GG_AUTO_CDR_COLUMN_GROUPS;
drop view "_DBA_STREAMS_UNSUPPORTED_12_2";
drop view "_DBA_STREAMS_NEWLY_SUPTED_12_2";

truncate table sys.repl$_process_events;
truncate table sys.apply$_auto_cdr_column_groups;

truncate table sys.apply$_procedure_stats;

drop public synonym v$goldengate_procedure_stats;
drop view v_$goldengate_procedure_stats;
drop public synonym gv$goldengate_procedure_stats;
drop view gv_$goldengate_procedure_stats;

drop public synonym dbms_xstream_auth_ivk;
revoke execute on dbms_xstream_auth_ivk from execute_catalog_role; 

DROP view DBA_REPLICATION_PROCESS_EVENTS;
DROP public synonym DBA_REPLICATION_PROCESS_EVENTS;

DROP view ALL_REPLICATION_PROCESS_EVENTS;
DROP public synonym ALL_REPLICATION_PROCESS_EVENTS;

DROP view CDB_REPLICATION_PROCESS_EVENTS;
DROP public synonym CDB_REPLICATION_PROCESS_EVENTS;

update sys.apply$_table_stats set lob_operations = 0;
commit;

Rem support drop_user_cascade if downgrade
DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_STREAMS_ADM_UTL' 
  AND proc='PROCESS_DROP_USER_CASCADE' AND operation#=1;

INSERT INTO sys.duc$ (owner, pack, proc, operation#, seq, com)
  VALUES ('SYS', 'DBMS_STREAMS_ADM_UTL', 'PROCESS_DROP_USER_CASCADE', 1, 1,
          'Drop any capture or apply processes for this user');
commit;

drop package SYS.dbms_offline_snapshot_internal;
drop package SYS.dbms_defer_sys_definer;
drop package SYS.dbms_rectifier_diff_internal;
drop package SYS.dbms_defer_query_definer;
drop package SYS.dbms_defer_definer;
drop package SYS.dbms_offline_rgt_internal;
drop package SYS.dbms_repcat_definer;
drop package SYS.dbms_repcat_sna_internal;
drop package SYS.dbms_offline_og_internal;

update sys.streams$_apply_milestone 
set pto_recovery_scn = null, pto_recovery_incarnation = null;
commit;

drop type sys.streams$transformation_info force;

alter table sys.streams$_component_prop_in modify (prop_name  VARCHAR2(30));
alter table sys.fgr$_file_group_files modify (file_type  VARCHAR2(32));
alter table sys.apply$_error modify (aq_transaction_id  VARCHAR2(30));
alter table sys.rmtab$ modify (name VARCHAR(30));

alter table xstream$_map modify (src_obj_name varchar2(100));
alter table xstream$_map modify (tgt_obj_name varchar2(100));

alter table apply$_dest_obj_ops modify (user_apply_procedure varchar2(98));

alter table sys.streams$_apply_process modify (message_handler varchar2(98));
alter table sys.streams$_apply_process modify (ddl_handler varchar2(98));
alter table sys.streams$_apply_process modify (precommit_handler varchar2(98));
alter table sys.streams$_apply_process modify (ua_notification_handler varchar2(98));

truncate table sys.gg$_supported_packages;
truncate table sys.gg$_procedure_annotation;
truncate table sys.gg$_proc_object_exclusion;
truncate table sys.gg$_package_mapping;

drop public synonym CDB_GG_SUPPORTED_PACKAGES;
drop view CDB_GG_SUPPORTED_PACKAGES;
drop public synonym DBA_GG_SUPPORTED_PACKAGES;
drop view DBA_GG_SUPPORTED_PACKAGES;

drop public synonym CDB_GG_PROCEDURE_ANNOTATION;
drop view CDB_GG_PROCEDURE_ANNOTATION;
drop public synonym DBA_GG_PROCEDURE_ANNOTATION;
drop view DBA_GG_PROCEDURE_ANNOTATION;

drop public synonym CDB_GG_PROC_OBJECT_EXCLUSION;
drop view CDB_GG_PROC_OBJECT_EXCLUSION;
drop public synonym DBA_GG_PROC_OBJECT_EXCLUSION;
drop view DBA_GG_PROC_OBJECT_EXCLUSION;

drop public synonym CDB_GG_SUPPORTED_PROCEDURES;
drop view CDB_GG_SUPPORTED_PROCEDURES;
drop public synonym DBA_GG_SUPPORTED_PROCEDURES;
drop view DBA_GG_SUPPORTED_PROCEDURES;

UPDATE sys.streams$_apply_process SET lcrid_version = 1;

update sys.streams$_rules SET schema_name=substr(schema_name, 1, 128);
alter table sys.streams$_rules modify (schema_name VARCHAR(128));

update sys.streams$_rules SET object_name=substr(object_name, 1, 128);
alter table sys.streams$_rules modify (object_name VARCHAR(128));

update sys.streams$_apply_spill_txn set pdb_id = 0;

UPDATE sys.apply$_error_txn SET cg_info = NULL;
UPDATE sys.apply$_error_txn SET source_package_name = NULL;
UPDATE sys.apply$_error_txn SET dest_package_name = NULL;

commit;

-- move tables back to SYSTEM
alter table sys.apply$_error_txn move tablespace SYSTEM;
-- rebuild index, bu leave in current tablespace (SYSAUX)
alter index streams$_apply_error_txn_unq rebuild;

alter table sys.apply$_cdr_info move tablespace SYSTEM;
alter index apply$_cdr_info_unq1 rebuild tablespace SYSTEM;

Rem =======================================================================
Rem End Changes for Streams/XStream
Rem =======================================================================
   
Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_SEGMENTS_DETAIL
Rem =======================================================================

drop public synonym gv$im_segments_detail;
drop view gv_$im_segments_detail;
drop public synonym v$im_segments_detail;
drop view v_$im_segments_detail;

Rem =======================================================================
Rem END Changes for [G]V$IM_SEGMENTS_DETAIL
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM[_USER]_SEGMENTS
Rem =======================================================================

drop public synonym gv$im_segments;
drop view gv_$im_segments;
drop public synonym v$im_segments;
drop view v_$im_segments;

drop public synonym gv$im_user_segments;
drop view gv_$im_user_segments;
drop public synonym v$im_user_segments;
drop view v_$im_user_segments;

Rem =======================================================================
Rem END Changes for [G]V$IM[_USER]_SEGMENTS
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$INMEMORY_AREA
Rem =======================================================================

drop public synonym gv$inmemory_area;
drop view gv_$inmemory_area;
drop public synonym v$inmemory_area;
drop view v_$inmemory_area;

Rem =======================================================================
Rem END Changes for [G]V$INMEMORY_AREA
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_COLUMN_LEVEL
Rem =======================================================================

drop public synonym gv$im_column_level;
drop view gv_$im_column_level;
drop public synonym v$im_column_level;
drop view v_$im_column_level;

Rem =======================================================================
Rem END Changes for [G]V$IM_COLUMN_LEVEL
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_TBS_EXT_MAP
Rem =======================================================================

drop public synonym gv$im_tbs_ext_map;
drop view gv_$im_tbs_ext_map;
drop public synonym v$im_tbs_ext_map;
drop view v_$im_tbs_ext_map;

Rem =======================================================================
Rem END Changes for [G]V$IM_TBS_EXT_MAP
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_SEG_EXT_MAP
Rem =======================================================================

drop public synonym gv$im_seg_ext_map;
drop view gv_$im_seg_ext_map;
drop public synonym v$im_seg_ext_map;
drop view v_$im_seg_ext_map;

Rem =======================================================================
Rem END Changes for [G]V$IM_SEG_EXT_MAP
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_HEADER
Rem =======================================================================

drop public synonym gv$im_header;
drop view gv_$im_header;
drop public synonym v$im_header;
drop view v_$im_header;

Rem =======================================================================
Rem END Changes for [G]V$IM_HEADER
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_COL_CU
Rem =======================================================================

drop public synonym gv$im_col_cu;
drop view gv_$im_col_cu;
drop public synonym v$im_col_cu;
drop view v_$im_col_cu;

Rem =======================================================================
Rem END Changes for [G]V$IM_COL_CU
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_SMU_HEAD 
Rem =======================================================================

drop public synonym gv$im_smu_head;
drop view gv_$im_smu_head;
drop public synonym v$im_smu_head;
drop view v_$im_smu_head;

Rem =======================================================================
Rem END Changes for [G]V$IM_SMU_HEAD 
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_SMU_CHUNK
Rem =======================================================================

drop public synonym gv$im_smu_chunk;
drop view gv_$im_smu_chunk;
drop public synonym v$im_smu_chunk;
drop view v_$im_smu_chunk;

Rem =======================================================================
Rem END Changes for [G]V$IM_SMU_CHUNK
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$INMEMORY_FASTSTART_AREA
Rem =======================================================================

drop public synonym gv$inmemory_faststart_area;
drop view gv_$inmemory_faststart_area;
drop public synonym v$inmemory_faststart_area;
drop view v_$inmemory_faststart_area;

Rem =======================================================================
Rem END Changes for [G]V$INMEMORY_FASTSTART_AREA
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for IM Segment level dictionary views [G]V$IM_SEGDICT*
Rem =======================================================================

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

Rem =======================================================================
Rem BEGIN Changes for [G]V$IMEU_HEADER
Rem =======================================================================

drop public synonym gv$imeu_header;
drop view gv_$imeu_header;
drop public synonym v$imeu_header;
drop view v_$imeu_header;

Rem =======================================================================
Rem END Changes for [G]V$IMEU_HEADER
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$IM_IMECOL_CU
Rem =======================================================================

drop public synonym gv$im_imecol_cu;
drop view gv_$im_imecol_cu;
drop public synonym v$im_imecol_cu;
drop view v_$im_imecol_cu;

Rem =======================================================================
Rem END Changes for [G]V$IM_IMECOL_CU
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$INMEMORY_XMEM_AREA
Rem =======================================================================

drop public synonym gv$inmemory_xmem_area;
drop view gv_$inmemory_xmem_area;
drop public synonym v$inmemory_xmem_area;
drop view v_$inmemory_xmem_area;

Rem =======================================================================
Rem END Changes or [G]V$INMEMORY_XMEM_AREA
Rem =======================================================================

Rem =======================================================================
Rem BEGIN IMC changes
Rem =======================================================================

Rem ts$ and seg$ flags were extended to ub8 for IMC
update ts$ set flags = bitand(flags, 4294967295) where flags > 4294967295;
update seg$ set spare1 = bitand(spare1, 4294967295) where spare1 > 4294967295;
update partobj$ set spare2 = bitand(spare2, 1099511627775) where
 spare2 > 1099511627775;

Rem File dcore.bsq - delete imc flag from deferred_stg$
update deferred_stg$ set imcflag_stg = NULL;

Rem We remove inmemory CUs from compression$ to force analyzer to run on
Rem those CUs. This ensures we do not carry forward IMC CU formats from
Rem 12.1 to 12.2.
delete from compression$ where ULEVEL >=5 and ULEVEL <= 11;

Rem Remove the IME and VC compression$ entries
delete from compression$ where ulevel in (4294967294, 4294967293);

Rem Zero out spare3 (ddl scn) for selective column entries
update compression$ set spare3 = 0 where ulevel = 4294967295;

commit;

Rem =======================================================================
Rem END IMC changes
Rem =======================================================================

Rem =======================================================================
Rem BEGIN 12.2 CELLCACHE flag changes
Rem =======================================================================

Rem File dcore.bsq - clear ccflag and flags2 from deferred_stg$
update deferred_stg$ set ccflag_stg = NULL;
update deferred_stg$ set flags2_stg = NULL;
Rem tabcompart$ spare1 was extended to ub8 for cellcache
update tabcompart$ set spare1 = bitand(spare1, 4294967295) where 
  spare1 > 4294967295;

commit;

Rem =======================================================================
Rem END 12.2 CELLCACHE flag changes
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for GV$AUTO_BMR_STATISTICS 
Rem =======================================================================

drop public synonym gv$auto_bmr_statistics;
drop view gv_$auto_bmr_statistics;

Rem =======================================================================
Rem End Changes for GV$AUTO_BMR_STATISTICS 
Rem =======================================================================

-- Remove entries from SYS.DEFAULT_PWD$
delete from SYS.DEFAULT_PWD$ where user_name='APEX_040200' and
 pwd_verifier='NOLOGIN000000000';
delete from SYS.DEFAULT_PWD$ where user_name='APEX_050000' and
 pwd_verifier='NOLOGIN000000000';

Rem =======================================================================
Rem  Begin 12.2 Changes for Physical Standby
Rem =======================================================================

declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version < '12.1.0.2' then
    execute immediate 'alter table system.redo_db  rename column endian to spare2';
    execute immediate 'alter table system.redo_db  rename column enqidx to spare3';
    execute immediate 'alter table system.redo_db  rename column resetlogs_scn to scn1_bas';
    execute immediate 'alter table system.redo_db  rename column presetlogs_scn to scn1_wrp';
    execute immediate 'alter table system.redo_db  rename column gap_ret2 to scn1_time';
    execute immediate 'alter table system.redo_db  rename column gap_next_scn to curscn_bas';
    execute immediate 'alter table system.redo_db  rename column gap_next_time to curscn_wrp';
  end if;
end;
/ 

update system.redo_db set spare8 = 0;
update system.redo_db set spare9 = 0;
update system.redo_db set spare10 = 0;
update system.redo_db set spare11 = 0;
update system.redo_db set spare12 = 0;
update system.redo_db set resetlogs_scn_bas=0, resetlogs_scn_wrp=1, resetlogs_time=1, presetlogs_scn_bas=1, presetlogs_scn_wrp=1 where dbid=0 and thread#=0;

declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version < '12.1.0.2' then
    execute immediate 'alter table system.redo_log  rename column endian to spare1';
    execute immediate 'alter table system.redo_log  rename column first_scn to current_scn_bas';
    execute immediate 'alter table system.redo_log  rename column next_scn to current_scn_wrp';
    execute immediate 'alter table system.redo_log  rename column resetlogs_scn to current_time';
    execute immediate 'alter table system.redo_log  rename column presetlogs_scn to current_blkno';
    execute immediate 'alter table system.redo_log  rename column old_blocks to nab';
  end if;
end;
/ 

update system.redo_log set spare8  = 0;
update system.redo_log set spare9  = 0;
update system.redo_log set spare10 = 0;
update system.redo_log set old_status1 = 0;
update system.redo_log set old_status2 = 0;
update system.redo_log set old_filename = '';

CREATE TABLE SYSTEM.REDO_RTA (
  DBID                    NUMBER NOT NULL,
  DBUNAME                 VARCHAR2(32),
  THREAD                  NUMBER NOT NULL,
  RLS                     NUMBER,
  SPARE9                  NUMBER,
  RLC                     NUMBER,
  SEQNO                   NUMBER,
  BLKNO                   NUMBER,
  PSCN                    NUMBER,
  SPARE10                 NUMBER,
  PTIME                   NUMBER,
  PSEQ                    NUMBER,
  RSCN                    NUMBER,
  SPARE11                 NUMBER,
  RTIME                   NUMBER,
  RCVNAB                  NUMBER,
  RCVSEQ                  NUMBER,
  CTIME                   NUMBER,
  FLAG                    NUMBER,
  TIMEDIF                 NUMBER,
  SPARE1                  NUMBER,
  SPARE2                  NUMBER,
  SPARE3                  NUMBER,
  SPARE4                  NUMBER,
  SPARE5                  DATE,
  SPARE6                  VARCHAR2(32),
  SPARE7                  NUMBER,
  SPARE8                  NUMBER
) tablespace SYSAUX LOGGING
/

CREATE UNIQUE INDEX system.redo_rta_idx ON
                    system.redo_rta(dbid, thread)
                    TABLESPACE SYSAUX LOGGING
/

Rem =======================================================================
Rem  End 12.2 Changes for Physical Standby
Rem =======================================================================

Rem *************************************************************************
Rem Network ACL changes for 12.1.0.2
Rem *************************************************************************

Rem Delete network ACLs from Datapump noexp$
delete from noexp$ ne
 where ne.obj_type = 110
   and exists (select * from dba_xs_acls xa
                where xa.security_class_owner = 'SYS'
                  and xa.security_class       = 'NETWORK_SC'
                  and xa.owner                = ne.owner
                  and xa.name                 = ne.name);
commit;

Rem *************************************************************************
Rem END Network ACL changes
Rem *************************************************************************

Rem
Rem BEGIN RTI 19634111: Remove sharing=metadata and set sharing=data
Rem                     on Datapump tables. Truncate if in PDB.
Rem                     NOEXP$, EXPACT$, IMPCALLOUTREG$, EXPPKGACT$, and
Rem                     EXPPKGOBJ$
Rem

declare
  con_id number;
begin
  SELECT sys_context('USERENV', 'CON_ID') INTO con_id FROM dual;
  if con_id > 1 then
    execute immediate 'truncate table SYS.NOEXP$';
    execute immediate 'truncate table SYS.EXPACT$';
    execute immediate 'truncate table SYS.IMPCALLOUTREG$';
    execute immediate 'truncate table SYS.EXPPKGACT$';
    execute immediate 'truncate table SYS.EXPPKGOBJ$';
  end if;
end;
/

update obj$ o
   set o.flags = o.flags + 131072 - 65536
 where bitand(o.flags, 65536) =  65536
   and o.name in ('NOEXP$', 'EXPACT$', 'IMPCALLOUTREG$', 'EXPPKGACT$',
                  'EXPPKGOBJ$')
   and o.owner# = 0
/
commit;

Rem
Rem   END RTI 19634111: Remove sharing=metadata and set sharing=data
Rem                     on Datapump tables. Truncate if in PDB.
Rem                     NOEXP$, EXPACT$, IMPCALLOUTREG$, EXPPKGACT$, and
Rem                     EXPPKGOBJ$
Rem

Rem =======================================================================
Rem  Begin Changes for CDB Common Data Views
Rem =======================================================================

drop view INT$DBA_COL_COMMENTS;
drop view INT$DBA_TAB_COMMENTS;
drop view INT$DBA_PLSQL_OBJECT_SETTINGS;
drop view INT$INT$DBA_CONSTRAINTS;

-- [20559930]
drop package CDBView_internal;
-- Note this library should have been dropped independently of my fix.
drop library dbms_pdb_lib;

-- lrg 9710290: 12.1.0.2->12.1.0.1 downgrade drops INT$INT$DBA_CONSTRAINTS, 
-- which causes INT$DBA_CONSTRAINTS to be marked invalid. This, in turn, 
-- causes USER_CONSTRAINTS to be marked invalid. 12.1.0.1->11.2 downgrade 
-- accesses USER_CONSTRAINTS and cannot validate it. Reload the 12.1.0.1 
-- definition of INT$DBA_CONSTRAINTS right after INT$INT$DBA_CONSTRAINTS 
-- is dropped. 
-- Bug 22132084: since we are getting rid of COMMON_DATA keyword in 12.2, 
-- we will use the (new for 12.2) syntax (SHARING=EXTENDED DATA) which 
-- sets Extended Data (2^32) and Metadata Link bits in obj$ and common_data 
-- bit in view$ and then clear the Extended Data bit to prevent numeric 
-- overflow which would occur when 12.1 code tries to read obj$.flags 
-- corresponding to this view into kqdobflg (which is a ub4 in 12.1)
create or replace view INT$DBA_CONSTRAINTS SHARING = EXTENDED DATA
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, OBJECT_TYPE#, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
     R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, SHARING, ORIGIN_CON_ID)
as
select ou.name, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', 8, 'H', 9, 'F',
              10, 'F', 11, 'F', 13, 'F', '?'),
       o.name, o.type#, c.condition, 
       getlong(2, c.rowid), 
       ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null), 
       decode(bitand(o.flags, 196608), 65536, 1, 131072, 1, 0), 
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.con$ oc, sys.con$ rc, sys."_BASE_USER" ou, sys."_BASE_USER" ru,
     sys."_CURRENT_EDITION_OBJ" ro, sys."_CURRENT_EDITION_OBJ" o, sys.cdef$ c,
     sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8        /* don't include hash expressions */
  and (c.type# < 14 or c.type# > 17)    /* don't include supplog cons   */
  and (c.type# != 12)                   /* don't include log group cons */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
/

update obj$ set flags = flags - power(2,32) 
  where bitand(flags, power(2,32)) != 0;
commit;

drop view INT$DBA_STORED_SETTINGS;

-- Bug 21427375: drop unified audit policy's common_data views
-- INT$AUDIT_UNIFIED_POLICIES and INT$AUDIT_UNIFIED_ENABLED_POL
drop view INT$AUDIT_UNIFIED_POLICIES;
drop view INT$AUDIT_UNIFIED_ENABLED_POL;

-- Bug 22332196: drop common_data views corresponding to "VIEWS_AE" family
-- and "SOURCE_AE" family
drop view INT$DBA_VIEWS_AE;
drop view INT$DBA_SOURCE_AE;

-- Bug 22523319: drop application context's common_data view INT$DBA_CONTEXT
drop view INT$DBA_CONTEXT;

Rem =======================================================================
Rem  End Changes for CDB Common Data Views
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for CDB Object Linked Views
Rem =======================================================================

DROP VIEW INT$DBA_ALERT_HISTORY; 
DROP VIEW INT$DBA_ALERT_HISTORY_DETAIL; 
DROP VIEW INT$DBA_CPOOL_INFO; 
DROP VIEW INT$DBA_HIST_ACT_SESS_HISTORY; 
DROP VIEW INT$DBA_HIST_APPLY_SUMMARY; 
DROP VIEW INT$DBA_HIST_ASH_SNAPSHOT; 
DROP VIEW INT$DBA_HIST_ASM_BAD_DISK; 
DROP VIEW INT$DBA_HIST_ASM_DG_STAT; 
DROP VIEW INT$DBA_HIST_ASM_DISKGROUP; 
DROP VIEW INT$DBA_HIST_BASELINE; 
DROP VIEW INT$DBA_HIST_BASELINE_DETAILS; 
DROP VIEW INT$DBA_HIST_BASELINE_METADATA;
DROP VIEW INT$DBA_HIST_BASELINE_TEMPLATE; 
DROP VIEW INT$DBA_HIST_BG_EVENT_SUMMARY; 
DROP VIEW INT$DBA_HIST_BUFFERED_QUEUES; 
DROP VIEW INT$DBA_HIST_BUFFER_POOL_STAT; 
DROP VIEW INT$DBA_HIST_BUF_SUBSCRIBERS; 
DROP VIEW INT$DBA_HIST_CAPTURE; 
DROP VIEW INT$DBA_HIST_CELL_CFG_DETAIL; 
DROP VIEW INT$DBA_HIST_CELL_CONFIG; 
DROP VIEW INT$DBA_HIST_CELL_DISKTYPE; 
DROP VIEW INT$DBA_HIST_CELL_DISK_NAME; 
DROP VIEW INT$DBA_HIST_CELL_DISK_SUMMARY; 
DROP VIEW INT$DBA_HIST_CELL_GLBL_SUMMARY; 
DROP VIEW INT$DBA_HIST_CELL_NAME; 
DROP VIEW INT$DBA_HIST_CLUSTER_INTERCON; 
DROP VIEW INT$DBA_HIST_COLORED_SQL; 
DROP VIEW INT$DBA_HIST_COMP_IOSTAT; 
DROP VIEW INT$DBA_HIST_CR_BLOCK_SERVER; 
DROP VIEW INT$DBA_HIST_CURR_BLK_SERVER; 
DROP VIEW INT$DBA_HIST_DATABASE_INSTANCE; 
DROP VIEW INT$DBA_HIST_DATAFILE; 
DROP VIEW INT$DBA_HIST_DB_CACHE_ADVICE; 
DROP VIEW INT$DBA_HIST_DISPATCHER; 
DROP VIEW INT$DBA_HIST_DLM_MISC; 
DROP VIEW INT$DBA_HIST_DYN_RE_STATS; 
DROP VIEW INT$DBA_HIST_LMS_STATS; 
DROP VIEW INT$DBA_HIST_ENQUEUE_STAT; 
DROP VIEW INT$DBA_HIST_EVENT_HISTOGRAM; 
DROP VIEW INT$DBA_HIST_EVENT_NAME; 
DROP VIEW INT$DBA_HIST_FILESTATXS; 
DROP VIEW INT$DBA_HIST_FM_HISTORY; 
DROP VIEW INT$DBA_HIST_IC_CLIENT_STATS; 
DROP VIEW INT$DBA_HIST_IC_DEVICE_STATS; 
DROP VIEW INT$DBA_HIST_IC_PINGS; 
DROP VIEW INT$DBA_HIST_IC_TRANSFER; 
DROP VIEW INT$DBA_HIST_INSTANCE_RECOVERY; 
DROP VIEW INT$DBA_HIST_IOSTAT_DETAIL; 
DROP VIEW INT$DBA_HIST_IOSTAT_FILETYPE; 
DROP VIEW INT$DBA_HIST_IOSTAT_FN_NAME; 
DROP VIEW INT$DBA_HIST_IOSTAT_FT_NAME; 
DROP VIEW INT$DBA_HIST_IOSTAT_FUNCTION; 
DROP VIEW INT$DBA_HIST_JAVA_POOL_ADVICE; 
DROP VIEW INT$DBA_HIST_LATCH; 
DROP VIEW INT$DBA_HIST_LATCH_CHILDREN; 
DROP VIEW INT$DBA_HIST_LATCH_NAME; 
DROP VIEW INT$DBA_HIST_LATCH_PARENT; 
DROP VIEW INT$DBA_HIST_LAT_M_SUMMARY; 
DROP VIEW INT$DBA_HIST_LIBRARYCACHE; 
DROP VIEW INT$DBA_HIST_LOG; 
DROP VIEW INT$DBA_HIST_MEMORY_RESIZE_OPS; 
DROP VIEW INT$DBA_HIST_MEM_DYNAMIC_COMP; 
DROP VIEW INT$DBA_HIST_MEM_TGT_ADVICE; 
DROP VIEW INT$DBA_HIST_METRIC_NAME; 
DROP VIEW INT$DBA_HIST_MTTR_TGT_ADVICE; 
DROP VIEW INT$DBA_HIST_MUTEX_SLEEP; 
DROP VIEW INT$DBA_HIST_MVPARAMETER; 
DROP VIEW INT$DBA_HIST_OPTIMIZER_ENV; 
DROP VIEW INT$DBA_HIST_OSSTAT; 
DROP VIEW INT$DBA_HIST_OSSTAT_NAME; 
DROP VIEW INT$DBA_HIST_PARAMETER; 
DROP VIEW INT$DBA_HIST_PARAMETER_NAME; 
DROP VIEW INT$DBA_HIST_PDB_INSTANCE; 
DROP VIEW INT$DBA_HIST_PERSISTENT_QUEUES; 
DROP VIEW INT$DBA_HIST_PERSISTENT_SUBS; 
DROP VIEW INT$DBA_HIST_PERS_QMN_CACHE; 
DROP VIEW INT$DBA_HIST_PGASTAT; 
DROP VIEW INT$DBA_HIST_PGA_TARGET_ADVICE; 
DROP VIEW INT$DBA_HIST_PLAN_OPTION_NAME; 
DROP VIEW INT$DBA_HIST_PLAN_OP_NAME; 
DROP VIEW INT$DBA_HIST_PMEM_SUMMARY; 
DROP VIEW INT$DBA_HIST_REP_TBL_STATS; 
DROP VIEW INT$DBA_HIST_REP_TXN_STATS; 
DROP VIEW INT$DBA_HIST_RESOURCE_LIMIT; 
DROP VIEW INT$DBA_HIST_ROWCACHE_SUMMARY; 
DROP VIEW INT$DBA_HIST_RSRC_CON_GROUP; 
DROP VIEW INT$DBA_HIST_RSRC_PLAN; 
DROP VIEW INT$DBA_HIST_RULE_SET; 
DROP VIEW INT$DBA_HIST_SEG_STAT; 
DROP VIEW INT$DBA_HIST_SEG_STAT_OBJ; 
DROP VIEW INT$DBA_HIST_SERVICE_NAME; 
DROP VIEW INT$DBA_HIST_SERVICE_STAT; 
DROP VIEW INT$DBA_HIST_SESS_SGA_STATS; 
DROP VIEW INT$DBA_HIST_SESS_TIME_STATS; 
DROP VIEW INT$DBA_HIST_SGA; 
DROP VIEW INT$DBA_HIST_SGASTAT; 
DROP VIEW INT$DBA_HIST_SGA_TARGET_ADVICE; 
DROP VIEW INT$DBA_HIST_SHRD_SVR_SUMMARY; 
DROP VIEW INT$DBA_HIST_SM_HISTORY; 
DROP VIEW INT$DBA_HIST_SNAPSHOT; 
DROP VIEW INT$DBA_HIST_SNAP_ERROR; 
DROP VIEW INT$DBA_HIST_SPOOL_ADVICE; 
DROP VIEW INT$DBA_HIST_SQLCOMMAND_NAME; 
DROP VIEW INT$DBA_HIST_SQLSTAT; 
DROP VIEW INT$DBA_HIST_SQLTEXT; 
DROP VIEW INT$DBA_HIST_SQL_BIND_METADATA; 
DROP VIEW INT$DBA_HIST_SQL_PLAN; 
DROP VIEW INT$DBA_HIST_SQL_SUMMARY; 
DROP VIEW INT$DBA_HIST_SQL_WA_HSTGRM; 
DROP VIEW INT$DBA_HIST_STAT_NAME; 
DROP VIEW INT$DBA_HIST_STREAMS_APPLY_SUM; 
DROP VIEW INT$DBA_HIST_STREAMS_CAPTURE; 
DROP VIEW INT$DBA_HIST_STRPOOL_ADVICE; 
DROP VIEW INT$DBA_HIST_SVC_WAIT_CLASS; 
DROP VIEW INT$DBA_HIST_SYSMETRIC_HISTORY; 
DROP VIEW INT$DBA_HIST_SYSMETRIC_SUMMARY; 
DROP VIEW INT$DBA_HIST_SYSSTAT; 
DROP VIEW INT$DBA_HIST_SYSTEM_EVENT; 
DROP VIEW INT$DBA_HIST_SYS_TIME_MODEL; 
DROP VIEW INT$DBA_HIST_TABLESPACE; 
DROP VIEW INT$DBA_HIST_TABLESPACE_STAT; 
DROP VIEW INT$DBA_HIST_TBSPC_SPACE_USAGE; 
DROP VIEW INT$DBA_HIST_TEMPFILE; 
DROP VIEW INT$DBA_HIST_TEMPSTATXS; 
DROP VIEW INT$DBA_HIST_THREAD; 
DROP VIEW INT$DBA_HIST_TOPLEVELCALL_NAME; 
DROP VIEW INT$DBA_HIST_UNDOSTAT; 
DROP VIEW INT$DBA_HIST_WAITSTAT; 
DROP VIEW INT$DBA_HIST_WCM_HISTORY; 
DROP VIEW INT$DBA_HIST_WR_CONTROL; 
DROP VIEW INT$DBA_OUTSTANDING_ALERTS; 
DROP VIEW INT$DBA_PDB_SAVED_STATES; 
DROP VIEW INT$DBA_HIST_CELL_GLOBAL;
DROP VIEW INT$DBA_HIST_CELL_METRIC_DESC;
DROP VIEW INT$DBA_HIST_CELL_IOREASON_NM;
DROP VIEW INT$DBA_HIST_CELL_IOREASON;
DROP VIEW INT$DBA_HIST_CELL_DB;
DROP VIEW INT$DBA_HIST_CELL_OPEN_ALERTS;
DROP VIEW INT$DBA_HIST_IM_SEG_STAT;
DROP VIEW INT$DBA_HIST_IM_SEG_STAT_OBJ;
DROP VIEW INT$DBA_PDBS;
DROP VIEW INT$DBA_HIST_REPORTS_DETAILS;
DROP VIEW INT$DBA_HIST_REPORTS;
DROP VIEW INT$DBA_HIST_REPORTS_TIMEBANDS;
DROP VIEW INT$DBA_HIST_PDB_IN_SNAP;

Rem =======================================================================
Rem  End Changes for CDB Object Linked Views
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for CDB X$ Tables
Rem =======================================================================

drop procedure createX$PermanentTables;
drop procedure dropX$PermanentTables;

Rem =======================================================================
Rem  End Changes for CDB X$ Tables
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$KEY_VECTOR
Rem =======================================================================

drop public synonym gv$key_vector;
drop public synonym v$key_vector;
drop view gv_$key_vector;
drop view v_$key_vector;

Rem =======================================================================
Rem END Changes for [G]V$KEY_VECTOR
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Aggregation
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IMA;

Rem =======================================================================
Rem END Changes for In-Memory Aggregation
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for DBMS_SCN
Rem =======================================================================

drop public synonym dbms_scn;
drop package body sys.dbms_scn;
drop package sys.dbms_scn;
drop library dbms_scn_lib;

Rem =======================================================================
Rem End Changes for DBMS_SCN
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Column Store FastStart
Rem =======================================================================

Rem Removing supporting catalog objects.  Indexes are automatically dropped

drop view     SYS.SYSDBIMFSV$;

drop sequence SYSDBIMFSCUID_SEQ$;
drop sequence SYSDBIMFSSEG_SEQ$;

drop table SYSDBIMFS$ cascade constraints purge; 
drop table SYSDBIMFSDBA$ cascade constraints purge;
drop table SYSDBIMFSSEG$ cascade constraints purge;
drop table SYSDBIMFS_METADATA$ cascade constraints purge;

--Feature usage tracking
drop procedure DBMS_FEATURE_IMFS;

Rem =======================================================================
Rem END Changes for In-Memory Column Store FastStart
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Column Store
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IMC;

Rem Used by dbms_inmemory_admin package
drop public synonym dbms_inmemory_admin; 
drop package body sys.dbms_inmemory_admin;
drop package sys.dbms_inmemory_admin;

Rem Used by dbms_inmemory package
drop public synonym dbms_inmemory;
drop package body sys.dbms_inmemory;
drop package sys.dbms_inmemory;

Rem =======================================================================
Rem END Changes for In-Memory Column Store
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Join Groups
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IM_JOINGROUPS;

Rem =======================================================================
Rem END Changes for In-Memory Join Groups
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory ADO Policies
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IM_ADO;

Rem =======================================================================
Rem END Changes for In-Memory ADO Policies
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory For Service (USER_DEFINED) tracking
Rem =======================================================================

Rem Used by for service feature tracking
drop procedure DBMS_FEATURE_IM_FORSERVICE;

Rem =======================================================================
Rem END Changes for In-Memory For Service (USER_DEFINED) tracking
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes Zone map tracking
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_ZMAP;

Rem =======================================================================
Rem END Changes for In-Memory Column Store
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for In-Memory Expressions
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IM_EXPRESSIONS;

Rem =======================================================================
Rem END Changes for In-Memory Expressions
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for Index Organized Tables
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_IOT;

Rem =======================================================================
Rem END Changes for Index Organized Tables
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for ADVANCED Table Compression
Rem =======================================================================

Rem Used by dbms_compression
drop package prvt_compress;

Rem Used by feature tracking
drop procedure DBMS_FEATURE_ADV_TABCMP;

Rem =======================================================================
Rem END Changes for ADVANCED Table Compression
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for JSON
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_JSON;

Rem JSON PL/SQL DOM api 
drop type Json_Object_T;
drop type Json_Array_T;
drop type Json_Scalar_T;
drop type Json_Element_T;
drop type JDOM_T;
drop type JSON_KEY_LIST;
drop library DBMS_JDOM_LIB;
drop PUBLIC SYNONYM JDOM_T;
drop PUBLIC SYNONYM Json_Element_T;
drop PUBLIC SYNONYM Json_Object_T;
drop PUBLIC SYNONYM Json_Array_T;
drop PUBLIC SYNONYM Json_Scalar_T;
drop PUBLIC SYNONYM JSON_KEY_LIST;

Rem =======================================================================
Rem END Changes for JSON
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for Hybrid Columnar Compression Conventional Load Feature 
Rem Tracking
Rem =======================================================================

Rem Used by feature tracking
drop procedure DBMS_FEATURE_HCCCONV;

Rem =======================================================================
Rem END Changes for Hybrid Columnar COmpression Conventional Load Feature 
Rem Tracking
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$CELL_CONFIG_INFO
Rem =======================================================================

drop public synonym gv$cell_config_info;
drop public synonym v$cell_config_info;
drop view gv_$cell_config_info;
drop view v_$cell_config_info;

Rem =======================================================================
Rem END Changes for [G]V$CELL_CONFIG_INFO
Rem =======================================================================



Rem Begin Changes for DBMS_DBCOMP
Rem =======================================================================
drop package sys.dbms_dbcomp;

Rem =======================================================================
Rem End Changes for DBMS_DBCOMP
Rem =======================================================================


Rem Begin Changes for Appilcation Resilience API
Rem =======================================================================
drop package sys.dbms_disrupt;

Rem =======================================================================
Rem End Changes for Application Resilience API
Rem =======================================================================


Rem =======================================================================
Rem BEGIN Changes for Cell Metrics Fixed Tables
Rem =======================================================================

drop public synonym gv$cell_metric_desc;
drop public synonym v$cell_metric_desc;
drop view gv_$cell_metric_desc;
drop view v_$cell_metric_desc;

drop public synonym gv$cell_global;
drop public synonym v$cell_global;
drop view gv_$cell_global;
drop view v_$cell_global;

drop public synonym gv$cell_global_history;
drop public synonym v$cell_global_history;
drop view gv_$cell_global_history;
drop view v_$cell_global_history;

drop public synonym gv$cell_disk;
drop public synonym v$cell_disk;
drop view gv_$cell_disk;
drop view v_$cell_disk;

drop public synonym gv$cell_disk_history;
drop public synonym v$cell_disk_history;
drop view gv_$cell_disk_history;
drop view v_$cell_disk_history;

drop public synonym gv$cell_ioreason;
drop public synonym v$cell_ioreason;
drop view gv_$cell_ioreason;
drop view v_$cell_ioreason;

drop public synonym gv$cell_ioreason_name;
drop public synonym v$cell_ioreason_name;
drop view gv_$cell_ioreason_name;
drop view v_$cell_ioreason_name;

drop public synonym gv$cell_db;
drop public synonym v$cell_db;
drop view gv_$cell_db;
drop view v_$cell_db;

drop public synonym gv$cell_db_history;
drop public synonym v$cell_db_history;
drop view gv_$cell_db_history;
drop view v_$cell_db_history;

drop public synonym gv$cell_open_alerts;
drop public synonym v$cell_open_alerts;
drop view gv_$cell_open_alerts;
drop view v_$cell_open_alerts;

Rem =======================================================================
Rem END Changes for Cell Metrics Fixed Tables
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for AWR Metrics Fixed Tables
Rem =======================================================================

drop public synonym gv$con_sysmetric;
drop public synonym v$con_sysmetric;
drop view gv_$con_sysmetric;
drop view v_$con_sysmetric;

drop public synonym gv$con_sysmetric_history;
drop public synonym v$con_sysmetric_history;
drop view gv_$con_sysmetric_history;
drop view v_$con_sysmetric_history;

drop public synonym gv$con_sysmetric_summary;
drop public synonym v$con_sysmetric_summary;
drop view gv_$con_sysmetric_summary;
drop view v_$con_sysmetric_summary;

Rem =======================================================================
Rem END Changes for AWR Metrics Fixed Tables
Rem =======================================================================

Rem===================
Rem AWR Changes Begin
Rem===================

alter table WRH$_REPLICATION_TXN_STATS modify (object_name VARCHAR2(30));

update wrm$_baseline set baseline_name = substr(baseline_name, 1, 64);
update wrm$_baseline set template_name = substr(template_name, 1, 64);

update wrm$_baseline_template set template_name = 
substr(template_name, 1, 30);

update wrm$_baseline_template set baseline_name_prefix = 
substr(baseline_name_prefix, 1, 30);

update wrh$_sgastat set pool = substr(pool, 1, 12);

drop type AWRBL_METRIC_TYPE_TABLE;

drop type AWRBL_METRIC_TYPE;

alter table wrh$_sgastat drop constraint wrh$_sgastat_u;

alter table wrh$_sgastat add constraint wrh$_sgastat_u
        unique (dbid, snap_id, instance_number, name, pool, con_dbid);

update wrh$_cr_block_server set builds = NULL;
update wrh$_current_block_server set pin0 = NULL, flush0 = NULL;

update wrh$_cell_db set 
  disk_small_io_reqs          = null,
  disk_large_io_reqs          = null,
  flash_small_io_reqs         = null,
  flash_large_io_reqs         = null,
  disk_small_io_service_time  = null,
  disk_small_io_queue_time    = null,
  disk_large_io_service_time  = null,
  disk_large_io_queue_time    = null,
  flash_small_io_service_time = null,
  flash_small_io_queue_time   = null,
  flash_large_io_service_time = null,
  flash_large_io_queue_time   = null;

update wrh$_cell_db_bl set 
  disk_small_io_reqs          = null,
  disk_large_io_reqs          = null,
  flash_small_io_reqs         = null,
  flash_large_io_reqs         = null,
  disk_small_io_service_time  = null,
  disk_small_io_queue_time    = null,
  disk_large_io_service_time  = null,
  disk_large_io_queue_time    = null,
  flash_small_io_service_time = null,
  flash_small_io_queue_time   = null,
  flash_large_io_service_time = null,
  flash_large_io_queue_time   = null;

truncate table wrh$_con_sysmetric_history;
truncate table wrh$_con_sysmetric_history_bl;
drop view DBA_HIST_CON_SYSMETRIC_HIST;
drop public synonym DBA_HIST_CON_SYSMETRIC_HIST;

truncate table wrh$_con_sysmetric_summary;
drop view DBA_HIST_CON_SYSMETRIC_SUMM;
drop public synonym DBA_HIST_CON_SYSMETRIC_SUMM;

truncate table wrh$_con_sys_time_model;
truncate table wrh$_con_sys_time_model_bl;
drop view DBA_HIST_CON_SYS_TIME_MODEL;
drop public synonym DBA_HIST_CON_SYS_TIME_MODEL;

truncate table WRH$_CON_SYSSTAT;
truncate table WRH$_CON_SYSSTAT_BL;
drop public synonym DBA_HIST_CON_SYSSTAT;
drop view DBA_HIST_CON_SYSSTAT;

truncate table WRM$_WR_SETTINGS;
drop public synonym DBA_HIST_WR_SETTINGS;
drop view DBA_HIST_WR_SETTINGS;
drop public synonym CDB_HIST_WR_SETTINGS;
drop view CDB_HIST_WR_SETTINGS;

drop public synonym DBA_HIST_PDB_IN_SNAP;
drop view DBA_HIST_PDB_IN_SNAP;
drop public synonym CDB_HIST_PDB_IN_SNAP;
drop view CDB_HIST_PDB_IN_SNAP;

truncate table wrm$_active_pdbs;

truncate table wrh$_con_system_event;
truncate table wrh$_con_system_event_bl;
drop view DBA_HIST_CON_SYSTEM_EVENT;
drop public synonym DBA_HIST_CON_SYSTEM_EVENT;

-- bug21382425: changes in type prvt_awrv_metadata
-- created a dependency with AWRRPT_INSTANCE_LIST_TYPE
-- therefore dropping this type during downgrade.
-- Otherwise, catawrtb.sql will fail when trying to create or replace 
-- of type AWRRPT_INSTANCE_LIST_TYPE (which is used in prvt_awrv_metadata)  
drop type AWRRPT_INSTANCE_LIST_TYPE force;

drop package dbms_management_bootstrap;
drop public synonym dbms_management_bootstrap;

Rem =======================================================================
Rem Update new columns of awr tables to default value
Rem =======================================================================
update WRH$_FILESTATXS set per_pdb = null;
commit;

update WRH$_FILESTATXS_BL set per_pdb = null;
commit;

update WRH$_TEMPSTATXS set per_pdb = null;
commit;

update WRH$_DATAFILE set per_pdb = null;
commit;

update WRH$_TEMPFILE set per_pdb = null;
commit;

update WRH$_COMP_IOSTAT set per_pdb = null;
commit;

update WRH$_IOSTAT_FUNCTION set per_pdb = null;
commit;

update WRH$_IOSTAT_FUNCTION_NAME set per_pdb = null;
commit;

update WRH$_IOSTAT_FILETYPE set per_pdb = null;
commit;

update WRH$_IOSTAT_FILETYPE_NAME set per_pdb = null;
commit;

update WRH$_IOSTAT_DETAIL set per_pdb = null;
commit;

update WRH$_SQLSTAT set per_pdb = null;
commit;

update WRH$_SQLSTAT_BL set per_pdb = null;
commit;

update WRH$_SQLTEXT set per_pdb = null;
commit;

update WRI$_SQLTEXT_REFCOUNT set per_pdb = null;
commit;

update WRH$_SQL_SUMMARY set per_pdb = null;
commit;

update WRH$_SQL_PLAN set per_pdb = null;
commit;

update WRH$_SQL_BIND_METADATA set per_pdb = null;
commit;

update WRH$_OPTIMIZER_ENV set per_pdb = null;
commit;

update WRH$_SYSTEM_EVENT set per_pdb = null;
commit;

update WRH$_SYSTEM_EVENT_BL set per_pdb = null;
commit;

update WRH$_EVENT_NAME set per_pdb = null;
commit;

update WRH$_LATCH_NAME set per_pdb = null;
commit;

update WRH$_BG_EVENT_SUMMARY set per_pdb = null;
commit;

update WRH$_CHANNEL_WAITS set per_pdb = null;
commit;

update WRH$_WAITSTAT set per_pdb = null;
commit;

update WRH$_WAITSTAT_BL set per_pdb = null;
commit;

update WRH$_ENQUEUE_STAT set per_pdb = null;
commit;

update WRH$_LATCH set per_pdb = null;
commit;

update WRH$_LATCH_BL set per_pdb = null;
commit;

update WRH$_LATCH_CHILDREN set per_pdb = null;
commit;

update WRH$_LATCH_CHILDREN_BL set per_pdb = null;
commit;

update WRH$_LATCH_PARENT set per_pdb = null;
commit;

update WRH$_LATCH_PARENT_BL set per_pdb = null;
commit;

update WRH$_LATCH_MISSES_SUMMARY set per_pdb = null;
commit;

update WRH$_LATCH_MISSES_SUMMARY_BL set per_pdb = null;
commit;

update WRH$_EVENT_HISTOGRAM set per_pdb = null;
commit;

update WRH$_EVENT_HISTOGRAM_BL set per_pdb = null;
commit;

update WRH$_MUTEX_SLEEP set per_pdb = null;
commit;

update WRH$_LIBRARYCACHE set per_pdb = null;
commit;

update WRH$_DB_CACHE_ADVICE set per_pdb = null;
commit;

update WRH$_DB_CACHE_ADVICE_BL set per_pdb = null;
commit;

update WRH$_BUFFER_POOL_STATISTICS set per_pdb = null;
commit;

update WRH$_ROWCACHE_SUMMARY set per_pdb = null;
commit;

update WRH$_ROWCACHE_SUMMARY_BL set per_pdb = null;
commit;

update WRH$_SGA set per_pdb = null;
commit;

update WRH$_SGASTAT set per_pdb = null;
commit;

update WRH$_SGASTAT_BL set per_pdb = null;
commit;

update WRH$_PGASTAT set per_pdb = null;
commit;

delete from WRH$_PROCESS_MEMORY_SUMMARY where per_pdb_nn = 1;
commit;

alter table WRH$_PROCESS_MEMORY_SUMMARY drop primary key;

alter table WRH$_PROCESS_MEMORY_SUMMARY
  add constraint WRH$_PROCESS_MEM_SUMMARY_PK
  primary key (dbid, snap_id, instance_number, category, con_dbid)
  using index tablespace SYSAUX;

update WRH$_PROCESS_MEMORY_SUMMARY set per_pdb = null, per_pdb_nn = 0;
commit;

update WRH$_RESOURCE_LIMIT set per_pdb = null;
commit;

update WRH$_SHARED_POOL_ADVICE set per_pdb = null;
commit;

update WRH$_STREAMS_POOL_ADVICE set per_pdb = null;
commit;

update WRH$_SQL_WORKAREA_HISTOGRAM set per_pdb = null;
commit;

update WRH$_PGA_TARGET_ADVICE set per_pdb = null;
commit;

update WRH$_SGA_TARGET_ADVICE set per_pdb = null;
commit;

update WRH$_MEMORY_TARGET_ADVICE set per_pdb = null;
commit;

update WRH$_MEMORY_RESIZE_OPS set per_pdb = null;
commit;

update WRH$_INSTANCE_RECOVERY set per_pdb = null;
commit;

update WRH$_JAVA_POOL_ADVICE set per_pdb = null;
commit;

update WRH$_THREAD set per_pdb = null;
commit;

update WRH$_SYSSTAT set per_pdb = null;
commit;

update WRH$_SYSSTAT_BL set per_pdb = null;
commit;


update WRH$_IM_SEG_STAT set per_pdb = null;
commit;

update WRH$_IM_SEG_STAT_BL set per_pdb = null;
commit;

update WRH$_IM_SEG_STAT_OBJ set per_pdb = null;
commit;

update WRH$_SYS_TIME_MODEL set per_pdb = null;
commit;

update WRH$_SYS_TIME_MODEL_BL set per_pdb = null;
commit;

update WRH$_OSSTAT set per_pdb = null;
commit;

update WRH$_OSSTAT_BL set per_pdb = null;
commit;

update WRH$_PARAMETER set per_pdb = null;
commit;

update WRH$_PARAMETER_BL set per_pdb = null;
commit;

update WRH$_MVPARAMETER set per_pdb = null;
commit;

update WRH$_MVPARAMETER_BL set per_pdb = null;
commit;

update WRH$_STAT_NAME set per_pdb = null;
commit;

update WRH$_OSSTAT_NAME set per_pdb = null;
commit;

update WRH$_PARAMETER_NAME set per_pdb = null;
commit;

update WRH$_PLAN_OPERATION_NAME set per_pdb = null;
commit;

update WRH$_PLAN_OPTION_NAME set per_pdb = null;
commit;

update WRH$_SQLCOMMAND_NAME set per_pdb = null;
commit;

update WRH$_TOPLEVELCALL_NAME set per_pdb = null;
commit;

update WRH$_UNDOSTAT set per_pdb = null;
commit;

update WRH$_SEG_STAT set per_pdb = null;
commit;

update WRH$_SEG_STAT_BL set per_pdb = null;
commit;

update WRH$_SEG_STAT_OBJ set per_pdb = null;
commit;

update WRH$_METRIC_NAME set per_pdb = null;
commit;

update WRH$_SYSMETRIC_HISTORY set per_pdb = null;
commit;

update WRH$_SYSMETRIC_HISTORY_BL set per_pdb = null;
commit;

update WRH$_SYSMETRIC_SUMMARY set per_pdb = null;
commit;

update WRH$_SESSMETRIC_HISTORY set per_pdb = null;
commit;

update WRH$_FILEMETRIC_HISTORY set per_pdb = null;
commit;

update WRH$_WAITCLASSMETRIC_HISTORY set per_pdb = null;
commit;

update WRH$_DLM_MISC set per_pdb = null;
commit;

update WRH$_DLM_MISC_BL set per_pdb = null;
commit;

update WRH$_CR_BLOCK_SERVER set per_pdb = null;
commit;

update WRH$_CURRENT_BLOCK_SERVER set per_pdb = null;
commit;

update WRH$_INST_CACHE_TRANSFER set per_pdb = null;
commit;

update WRH$_INST_CACHE_TRANSFER_BL set per_pdb = null;
commit;

update WRH$_ACTIVE_SESSION_HISTORY set per_pdb = null;
commit;

update WRH$_ACTIVE_SESSION_HISTORY_BL set per_pdb = null;
commit;

update WRH$_TABLESPACE_STAT set per_pdb = null;
commit;

update WRH$_TABLESPACE_STAT_BL set per_pdb = null;
commit;

update WRH$_LOG set per_pdb = null;
commit;

update WRH$_MTTR_TARGET_ADVICE set per_pdb = null;
commit;

update WRH$_TABLESPACE set per_pdb = null;
commit;

update WRH$_TABLESPACE_SPACE_USAGE set per_pdb = null;
commit;

update WRH$_SERVICE_NAME set per_pdb = null;
commit;

update WRH$_SERVICE_STAT set per_pdb = null;
commit;

update WRH$_SERVICE_STAT_BL set per_pdb = null;
commit;

update WRH$_SERVICE_WAIT_CLASS set per_pdb = null;
commit;

update WRH$_SERVICE_WAIT_CLASS_BL set per_pdb = null;
commit;

update WRH$_SESS_TIME_STATS set per_pdb = null;
commit;

update WRH$_STREAMS_CAPTURE set per_pdb = null;
commit;

update WRH$_STREAMS_APPLY_SUM set per_pdb = null;
commit;

update WRH$_BUFFERED_QUEUES set per_pdb = null;
commit;

update WRH$_BUFFERED_SUBSCRIBERS set per_pdb = null;
commit;

update WRH$_PERSISTENT_QUEUES set per_pdb = null;
commit;

update WRH$_PERSISTENT_SUBSCRIBERS set per_pdb = null;
commit;

update WRH$_RULE_SET set per_pdb = null;
commit;

update WRH$_SESS_SGA_STATS set per_pdb = null;
commit;

update WRH$_REPLICATION_TBL_STATS set per_pdb = null;
commit;

update WRH$_REPLICATION_TXN_STATS set per_pdb = null;
commit;

update WRH$_CELL_CONFIG set per_pdb = null;
commit;

update WRH$_CELL_CONFIG_DETAIL set per_pdb = null;
commit;

update WRH$_ASM_DISKGROUP set per_pdb = null;
commit;

update WRH$_ASM_DISKGROUP_STAT set per_pdb = null;
commit;

update WRH$_ASM_BAD_DISK set per_pdb = null;
commit;

update WRH$_CELL_GLOBAL_SUMMARY set per_pdb = null;
commit;

update WRH$_CELL_GLOBAL_SUMMARY_BL set per_pdb = null;
commit;

update WRH$_CELL_DISK_SUMMARY set per_pdb = null;
commit;

update WRH$_CELL_DISK_SUMMARY_BL set per_pdb = null;
commit;

update WRH$_CELL_METRIC_DESC set per_pdb = null;
commit;

update WRH$_CELL_GLOBAL set per_pdb = null;
commit;

update WRH$_CELL_GLOBAL_BL set per_pdb = null;
commit;

update WRH$_CELL_IOREASON_NAME set per_pdb = null;
commit;

update WRH$_CELL_IOREASON set per_pdb = null;
commit;

update WRH$_CELL_IOREASON_BL set per_pdb = null;
commit;

update WRH$_CELL_DB set per_pdb = null;
commit;

update WRH$_CELL_DB_BL set per_pdb = null;
commit;

update WRH$_CELL_OPEN_ALERTS set per_pdb = null;
commit;

update WRH$_CELL_OPEN_ALERTS_BL set per_pdb = null;
commit;

update WRH$_RSRC_CONSUMER_GROUP set per_pdb = null;
commit;

update WRH$_RSRC_PLAN set per_pdb = null;
commit;

update WRH$_RSRC_METRIC set per_pdb = null;
commit;

update WRH$_RSRC_PDB_METRIC set per_pdb = null;
commit;

update WRH$_CLUSTER_INTERCON set per_pdb = null;
commit;

update WRH$_IC_DEVICE_STATS set per_pdb = null;
commit;

update WRH$_IC_CLIENT_STATS set per_pdb = null;
commit;

update WRH$_MEM_DYNAMIC_COMP set per_pdb = null;
commit;

update WRH$_INTERCONNECT_PINGS set per_pdb = null;
commit;

update WRH$_INTERCONNECT_PINGS_BL set per_pdb = null;
commit;

update WRH$_DISPATCHER set per_pdb = null;
commit;

update WRH$_SHARED_SERVER_SUMMARY set per_pdb = null;
commit;

update WRH$_DYN_REMASTER_STATS set per_pdb = null;
commit;

update WRH$_LMS_STATS set per_pdb = null;
commit;

update WRH$_PERSISTENT_QMN_CACHE set per_pdb = null;
commit;

update WRM$_DATABASE_INSTANCE set cdb = NULL,
                                  edition = NULL,
                                  db_unique_name = NULL,
                                  database_role = NULL,
                                  cdb_root_dbid = NULL;
commit;

Rem =======================================================================
Rem downgrading to 12.1.0.1 or lower
Rem =======================================================================

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  if previous_version < '12.1.0.2' then
    -- Remove tables that were introduced in 12.1.0.2 and should
    -- only be truncated when downgrading to an earlier release.
    execute immediate 'truncate table WRM$_PDB_IN_SNAP';
    execute immediate 'truncate table WRM$_PDB_IN_SNAP_BL';

    execute immediate 'alter table wrh$_dyn_remaster_stats ' ||
                      'drop constraint wrh$_dyn_remaster_stats_pk';

    execute immediate 'delete from wrh$_dyn_remaster_stats a ' ||
                      'where a.rowid > any ( '                 ||
                      '  select b.rowid from wrh$_dyn_remaster_stats b ' ||
                      '  where b.dbid = a.dbid ' ||
                      '    and b.snap_id = a.snap_id ' ||
                      '    and b.instance_number = a.instance_number ' ||
                      '    and b.con_dbid = a.con_dbid)';

    execute immediate 'alter table wrh$_dyn_remaster_stats ' ||
                      'add constraint wrh$_dyn_remaster_stats_pk ' ||
                      'primary key (dbid, snap_id, instance_number, con_dbid)';

    execute immediate 'alter table wrh$_dyn_remaster_stats' ||
                      ' drop column remaster_type';
  END IF;
END;
/

commit;

Rem =======================================================================
Rem Begin Changes for AWR Exadata
Rem =======================================================================

-- AWR: tables introduced in 12.1.0.2 should only be truncated
-- if downgrading to 12.1.0.1 or lower to prevent data loss
-- views/synonyms can be dropped as they are recreated when running
-- catalog/catproc
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
   WHERE cid = 'CATPROC';
  IF previous_version < '12.1.0.2' THEN
    execute immediate 'truncate table WRH$_IM_SEG_STAT';
    execute immediate 'truncate table WRH$_IM_SEG_STAT_BL';
    execute immediate 'truncate table WRH$_IM_SEG_STAT_OBJ';
    execute immediate 'truncate table WRH$_CELL_CONFIG';
    execute immediate 'truncate table WRH$_CELL_CONFIG_DETAIL';
    execute immediate 'truncate table WRH$_ASM_DISKGROUP';
    execute immediate 'truncate table WRH$_ASM_DISKGROUP_STAT';
    execute immediate 'truncate table WRH$_ASM_BAD_DISK';
    execute immediate 'truncate table WRH$_CELL_GLOBAL_SUMMARY';
    execute immediate 'truncate table WRH$_CELL_GLOBAL_SUMMARY_BL';
    execute immediate 'truncate table WRH$_CELL_DISK_SUMMARY';
    execute immediate 'truncate table WRH$_CELL_DISK_SUMMARY_BL';
    execute immediate 'truncate table WRH$_CELL_METRIC_DESC';
    execute immediate 'truncate table WRH$_CELL_GLOBAL';
    execute immediate 'truncate table WRH$_CELL_GLOBAL_BL';
    execute immediate 'truncate table WRH$_CELL_IOREASON_NAME';
    execute immediate 'truncate table WRH$_CELL_IOREASON';
    execute immediate 'truncate table WRH$_CELL_IOREASON_BL';
    execute immediate 'truncate table WRH$_CELL_DB';
    execute immediate 'truncate table WRH$_CELL_DB_BL';
    execute immediate 'truncate table WRH$_CELL_OPEN_ALERTS';
    execute immediate 'truncate table WRH$_CELL_OPEN_ALERTS_BL';
  END IF;
END;
/


-- AWR IM Segments changes
drop view DBA_HIST_IM_SEG_STAT;
drop public synonym DBA_HIST_IM_SEG_STAT; 

drop view DBA_HIST_IM_SEG_STAT_OBJ;
drop public synonym DBA_HIST_IM_SEG_STAT_OBJ; 

-- Drop Exadata AWR views
drop view DBA_HIST_CELL_CONFIG;
drop public synonym DBA_HIST_CELL_CONFIG;

drop view DBA_HIST_CELL_CONFIG_DETAIL;
drop public synonym DBA_HIST_CELL_CONFIG_DETAIL;

drop view DBA_HIST_CELL_NAME;
drop public synonym DBA_HIST_CELL_NAME;

drop view DBA_HIST_CELL_DISKTYPE;
drop public synonym DBA_HIST_CELL_DISKTYPE;

drop view DBA_HIST_CELL_DISK_NAME;
drop public synonym DBA_HIST_CELL_DISK_NAME;

drop view DBA_HIST_ASM_DISKGROUP;
drop public synonym DBA_HIST_ASM_DISKGROUP;

drop view DBA_HIST_ASM_DISKGROUP_STAT;
drop public synonym DBA_HIST_ASM_DISKGROUP_STAT;

drop view DBA_HIST_ASM_BAD_DISK;
drop public synonym DBA_HIST_ASM_BAD_DISK;

drop view DBA_HIST_CELL_GLOBAL_SUMMARY;
drop public synonym DBA_HIST_CELL_GLOBAL_SUMMARY;

drop view DBA_HIST_CELL_DISK_SUMMARY;
drop public synonym DBA_HIST_CELL_DISK_SUMMARY;

drop view DBA_HIST_CELL_METRIC_DESC;
drop public synonym DBA_HIST_CELL_METRIC_DESC;

drop view DBA_HIST_CELL_GLOBAL;
drop public synonym DBA_HIST_CELL_GLOBAL;

drop view DBA_HIST_CELL_IOREASON_NAME;
drop public synonym DBA_HIST_CELL_IOREASON_NAME;

drop view DBA_HIST_CELL_IOREASON;
drop public synonym DBA_HIST_CELL_IOREASON;

drop view DBA_HIST_CELL_DB;
drop public synonym DBA_HIST_CELL_DB;

drop view DBA_HIST_CELL_OPEN_ALERTS;
drop public synonym DBA_HIST_CELL_OPEN_ALERTS;

-- Drop ADG AWR views
drop view DBA_HIST_RECOVERY_PROGRESS;
drop public synonym DBA_HIST_RECOVERY_PROGRESS;

Rem =======================================================================
Rem End Changes for AWR Exadata
Rem =======================================================================

Rem =======================================================================
Rem for RAC AWR report improvement
Rem =======================================================================

truncate table WRH$_LMS_STATS;
drop view DBA_HIST_LMS_STATS;
drop public synonym DBA_HIST_LMS_STATS;

Rem =======================================================================
Rem Begin Changes for AWR for CDB/PDB
Rem =======================================================================

-- drop AWR_ROOT views

drop view AWR_ROOT_DATABASE_INSTANCE;
drop public synonym AWR_ROOT_DATABASE_INSTANCE;
drop view AWR_ROOT_SNAPSHOT;
drop public synonym AWR_ROOT_SNAPSHOT;
drop view AWR_ROOT_SNAP_ERROR;
drop public synonym AWR_ROOT_SNAP_ERROR;
drop view AWR_ROOT_COLORED_SQL;
drop public synonym AWR_ROOT_COLORED_SQL;
drop view AWR_ROOT_BASELINE_METADATA;
drop public synonym AWR_ROOT_BASELINE_METADATA;
drop view AWR_ROOT_BASELINE_TEMPLATE;
drop public synonym AWR_ROOT_BASELINE_TEMPLATE;
drop view AWR_ROOT_WR_CONTROL;
drop public synonym AWR_ROOT_WR_CONTROL;
drop view AWR_ROOT_TABLESPACE;
drop public synonym AWR_ROOT_TABLESPACE;
drop view AWR_ROOT_DATAFILE;
drop public synonym AWR_ROOT_DATAFILE;
drop view AWR_ROOT_FILESTATXS;
drop public synonym AWR_ROOT_FILESTATXS;
drop view AWR_ROOT_TEMPFILE;
drop public synonym AWR_ROOT_TEMPFILE;
drop view AWR_ROOT_TEMPSTATXS;
drop public synonym AWR_ROOT_TEMPSTATXS;
drop view AWR_ROOT_COMP_IOSTAT;
drop public synonym AWR_ROOT_COMP_IOSTAT;
drop view AWR_ROOT_SQLSTAT;
drop public synonym AWR_ROOT_SQLSTAT;
drop view AWR_ROOT_SQLTEXT;
drop public synonym AWR_ROOT_SQLTEXT;
drop view AWR_ROOT_SQL_SUMMARY;
drop public synonym AWR_ROOT_SQL_SUMMARY;
drop view AWR_ROOT_SQL_PLAN;
drop public synonym AWR_ROOT_SQL_PLAN;
drop view AWR_ROOT_SQL_BIND_METADATA;
drop public synonym AWR_ROOT_SQL_BIND_METADATA;
drop view AWR_ROOT_OPTIMIZER_ENV;
drop public synonym AWR_ROOT_OPTIMIZER_ENV;
drop view AWR_ROOT_EVENT_NAME;
drop public synonym AWR_ROOT_EVENT_NAME;
drop view AWR_ROOT_SYSTEM_EVENT;
drop public synonym AWR_ROOT_SYSTEM_EVENT;
drop view AWR_ROOT_BG_EVENT_SUMMARY;
drop public synonym AWR_ROOT_BG_EVENT_SUMMARY;
drop view AWR_ROOT_WAITSTAT;
drop public synonym AWR_ROOT_WAITSTAT;
drop view AWR_ROOT_ENQUEUE_STAT;
drop public synonym AWR_ROOT_ENQUEUE_STAT;
drop view AWR_ROOT_LATCH_NAME;
drop public synonym AWR_ROOT_LATCH_NAME;
drop view AWR_ROOT_LATCH;
drop public synonym AWR_ROOT_LATCH;
drop view AWR_ROOT_LATCH_CHILDREN;
drop public synonym AWR_ROOT_LATCH_CHILDREN;
drop view AWR_ROOT_LATCH_PARENT;
drop public synonym AWR_ROOT_LATCH_PARENT;
drop view AWR_ROOT_LATCH_MISSES_SUMMARY;
drop public synonym AWR_ROOT_LATCH_MISSES_SUMMARY;
drop view AWR_ROOT_EVENT_HISTOGRAM;
drop public synonym AWR_ROOT_EVENT_HISTOGRAM;
drop view AWR_ROOT_MUTEX_SLEEP;
drop public synonym AWR_ROOT_MUTEX_SLEEP;
drop view AWR_ROOT_LIBRARYCACHE;
drop public synonym AWR_ROOT_LIBRARYCACHE;
drop view AWR_ROOT_DB_CACHE_ADVICE;
drop public synonym AWR_ROOT_DB_CACHE_ADVICE;
drop view AWR_ROOT_BUFFER_POOL_STAT;
drop public synonym AWR_ROOT_BUFFER_POOL_STAT;
drop view AWR_ROOT_ROWCACHE_SUMMARY;
drop public synonym AWR_ROOT_ROWCACHE_SUMMARY;
drop view AWR_ROOT_SGA;
drop public synonym AWR_ROOT_SGA;
drop view AWR_ROOT_SGASTAT;
drop public synonym AWR_ROOT_SGASTAT;
drop view AWR_ROOT_PGASTAT;
drop public synonym AWR_ROOT_PGASTAT;
drop view AWR_ROOT_PROCESS_MEM_SUMMARY;
drop public synonym AWR_ROOT_PROCESS_MEM_SUMMARY;
drop view AWR_ROOT_RESOURCE_LIMIT;
drop public synonym AWR_ROOT_RESOURCE_LIMIT;
drop view AWR_ROOT_SHARED_POOL_ADVICE;
drop public synonym AWR_ROOT_SHARED_POOL_ADVICE;
drop view AWR_ROOT_STREAMS_POOL_ADVICE;
drop public synonym AWR_ROOT_STREAMS_POOL_ADVICE;
drop view AWR_ROOT_SQL_WORKAREA_HSTGRM;
drop public synonym AWR_ROOT_SQL_WORKAREA_HSTGRM;
drop view AWR_ROOT_PGA_TARGET_ADVICE;
drop public synonym AWR_ROOT_PGA_TARGET_ADVICE;
drop view AWR_ROOT_SGA_TARGET_ADVICE;
drop public synonym AWR_ROOT_SGA_TARGET_ADVICE;
drop view AWR_ROOT_MEMORY_TARGET_ADVICE;
drop public synonym AWR_ROOT_MEMORY_TARGET_ADVICE;
drop view AWR_ROOT_MEMORY_RESIZE_OPS;
drop public synonym AWR_ROOT_MEMORY_RESIZE_OPS;
drop view AWR_ROOT_INSTANCE_RECOVERY;
drop public synonym AWR_ROOT_INSTANCE_RECOVERY;
drop view AWR_ROOT_JAVA_POOL_ADVICE;
drop public synonym AWR_ROOT_JAVA_POOL_ADVICE;
drop view AWR_ROOT_THREAD;
drop public synonym AWR_ROOT_THREAD;
drop view AWR_ROOT_STAT_NAME;
drop public synonym AWR_ROOT_STAT_NAME;
drop view AWR_ROOT_SYSSTAT_ID;
drop public synonym AWR_ROOT_SYSSTAT_ID;
drop view AWR_ROOT_SYSSTAT;
drop public synonym AWR_ROOT_SYSSTAT;
drop view AWR_ROOT_SYS_TIME_MODEL;
drop public synonym AWR_ROOT_SYS_TIME_MODEL;
drop view AWR_ROOT_CON_SYS_TIME_MODEL;
drop public synonym AWR_ROOT_CON_SYS_TIME_MODEL;
drop view AWR_ROOT_OSSTAT_NAME;
drop public synonym AWR_ROOT_OSSTAT_NAME;
drop view AWR_ROOT_OSSTAT;
drop public synonym AWR_ROOT_OSSTAT;
drop view AWR_ROOT_PARAMETER_NAME;
drop public synonym AWR_ROOT_PARAMETER_NAME;
drop view AWR_ROOT_PARAMETER;
drop public synonym AWR_ROOT_PARAMETER;
drop view AWR_ROOT_MVPARAMETER;
drop public synonym AWR_ROOT_MVPARAMETER;
drop view AWR_ROOT_UNDOSTAT;
drop public synonym AWR_ROOT_UNDOSTAT;
drop view AWR_ROOT_SEG_STAT;
drop public synonym AWR_ROOT_SEG_STAT;
drop view AWR_ROOT_SEG_STAT_OBJ;
drop public synonym AWR_ROOT_SEG_STAT_OBJ;
drop view AWR_ROOT_METRIC_NAME;
drop public synonym AWR_ROOT_METRIC_NAME;
drop view AWR_ROOT_SYSMETRIC_HISTORY;
drop public synonym AWR_ROOT_SYSMETRIC_HISTORY;
drop view AWR_ROOT_SYSMETRIC_SUMMARY;
drop public synonym AWR_ROOT_SYSMETRIC_SUMMARY;
drop view AWR_ROOT_CON_SYSMETRIC_HIST;
drop public synonym AWR_ROOT_CON_SYSMETRIC_HIST;
drop view AWR_ROOT_CON_SYSMETRIC_SUMM;
drop public synonym AWR_ROOT_CON_SYSMETRIC_SUMM;
drop view AWR_ROOT_SESSMETRIC_HISTORY;
drop public synonym AWR_ROOT_SESSMETRIC_HISTORY;
drop view AWR_ROOT_FILEMETRIC_HISTORY;
drop public synonym AWR_ROOT_FILEMETRIC_HISTORY;
drop view AWR_ROOT_WAITCLASSMET_HISTORY;
drop public synonym AWR_ROOT_WAITCLASSMET_HISTORY;
drop view AWR_ROOT_DLM_MISC;
drop public synonym AWR_ROOT_DLM_MISC;
drop view AWR_ROOT_CR_BLOCK_SERVER;
drop public synonym AWR_ROOT_CR_BLOCK_SERVER;
drop view AWR_ROOT_CURRENT_BLOCK_SERVER;
drop public synonym AWR_ROOT_CURRENT_BLOCK_SERVER;
drop view AWR_ROOT_INST_CACHE_TRANSFER;
drop public synonym AWR_ROOT_INST_CACHE_TRANSFER;
drop view AWR_ROOT_PLAN_OPERATION_NAME;
drop public synonym AWR_ROOT_PLAN_OPERATION_NAME;
drop view AWR_ROOT_PLAN_OPTION_NAME;
drop public synonym AWR_ROOT_PLAN_OPTION_NAME;
drop view AWR_ROOT_SQLCOMMAND_NAME;
drop public synonym AWR_ROOT_SQLCOMMAND_NAME;
drop view AWR_ROOT_TOPLEVELCALL_NAME;
drop public synonym AWR_ROOT_TOPLEVELCALL_NAME;
drop view AWR_ROOT_ACTIVE_SESS_HISTORY;
drop public synonym AWR_ROOT_ACTIVE_SESS_HISTORY;
drop view AWR_ROOT_ASH_SNAPSHOT;
drop public synonym AWR_ROOT_ASH_SNAPSHOT;
drop view AWR_ROOT_TABLESPACE_STAT;
drop public synonym AWR_ROOT_TABLESPACE_STAT;
drop view AWR_ROOT_LOG;
drop public synonym AWR_ROOT_LOG;
drop view AWR_ROOT_MTTR_TARGET_ADVICE;
drop public synonym AWR_ROOT_MTTR_TARGET_ADVICE;
drop view AWR_ROOT_TBSPC_SPACE_USAGE;
drop public synonym AWR_ROOT_TBSPC_SPACE_USAGE;
drop view AWR_ROOT_SERVICE_NAME;
drop public synonym AWR_ROOT_SERVICE_NAME;
drop view AWR_ROOT_SERVICE_STAT;
drop public synonym AWR_ROOT_SERVICE_STAT;
drop view AWR_ROOT_SERVICE_WAIT_CLASS;
drop public synonym AWR_ROOT_SERVICE_WAIT_CLASS;
drop view AWR_ROOT_SESS_TIME_STATS;
drop public synonym AWR_ROOT_SESS_TIME_STATS;
drop view AWR_ROOT_STREAMS_CAPTURE;
drop public synonym AWR_ROOT_STREAMS_CAPTURE;
drop view AWR_ROOT_CAPTURE;
drop public synonym AWR_ROOT_CAPTURE;
drop view AWR_ROOT_STREAMS_APPLY_SUM;
drop public synonym AWR_ROOT_STREAMS_APPLY_SUM;
drop view AWR_ROOT_APPLY_SUMMARY;
drop public synonym AWR_ROOT_APPLY_SUMMARY;
drop view AWR_ROOT_BUFFERED_QUEUES;
drop public synonym AWR_ROOT_BUFFERED_QUEUES;
drop view AWR_ROOT_BUFFERED_SUBSCRIBERS;
drop public synonym AWR_ROOT_BUFFERED_SUBSCRIBERS;
drop view AWR_ROOT_RULE_SET;
drop public synonym AWR_ROOT_RULE_SET;
drop view AWR_ROOT_PERSISTENT_QUEUES;
drop public synonym AWR_ROOT_PERSISTENT_QUEUES;
drop view AWR_ROOT_PERSISTENT_SUBS;
drop public synonym AWR_ROOT_PERSISTENT_SUBS;
drop view AWR_ROOT_SESS_SGA_STATS;
drop public synonym AWR_ROOT_SESS_SGA_STATS;
drop view AWR_ROOT_REPLICATION_TBL_STATS;
drop public synonym AWR_ROOT_REPLICATION_TBL_STATS;
drop view AWR_ROOT_REPLICATION_TXN_STATS;
drop public synonym AWR_ROOT_REPLICATION_TXN_STATS;
drop view AWR_ROOT_IOSTAT_FUNCTION;
drop public synonym AWR_ROOT_IOSTAT_FUNCTION;
drop view AWR_ROOT_IOSTAT_FUNCTION_NAME;
drop public synonym AWR_ROOT_IOSTAT_FUNCTION_NAME;
drop view AWR_ROOT_IOSTAT_FILETYPE;
drop public synonym AWR_ROOT_IOSTAT_FILETYPE;
drop view AWR_ROOT_IOSTAT_FILETYPE_NAME;
drop public synonym AWR_ROOT_IOSTAT_FILETYPE_NAME;
drop view AWR_ROOT_IOSTAT_DETAIL;
drop public synonym AWR_ROOT_IOSTAT_DETAIL;
drop view AWR_ROOT_RSRC_CONSUMER_GROUP;
drop public synonym AWR_ROOT_RSRC_CONSUMER_GROUP;
drop view AWR_ROOT_RSRC_PLAN;
drop public synonym AWR_ROOT_RSRC_PLAN;
drop view AWR_ROOT_CLUSTER_INTERCON;
drop public synonym AWR_ROOT_CLUSTER_INTERCON;
drop view AWR_ROOT_MEM_DYNAMIC_COMP;
drop public synonym AWR_ROOT_MEM_DYNAMIC_COMP;
drop view AWR_ROOT_IC_CLIENT_STATS;
drop public synonym AWR_ROOT_IC_CLIENT_STATS;
drop view AWR_ROOT_IC_DEVICE_STATS;
drop public synonym AWR_ROOT_IC_DEVICE_STATS;
drop view AWR_ROOT_INTERCONNECT_PINGS;
drop public synonym AWR_ROOT_INTERCONNECT_PINGS;
drop view AWR_ROOT_DISPATCHER;
drop public synonym AWR_ROOT_DISPATCHER;
drop view AWR_ROOT_SHARED_SERVER_SUMMARY;
drop public synonym AWR_ROOT_SHARED_SERVER_SUMMARY;
drop view AWR_ROOT_DYN_REMASTER_STATS;
drop public synonym AWR_ROOT_DYN_REMASTER_STATS;
drop view AWR_ROOT_LMS_STATS;
drop public synonym AWR_ROOT_LMS_STATS;
drop view AWR_ROOT_PERSISTENT_QMN_CACHE;
drop public synonym AWR_ROOT_PERSISTENT_QMN_CACHE;
drop view AWR_ROOT_PDB_INSTANCE;
drop public synonym AWR_ROOT_PDB_INSTANCE;
drop view AWR_ROOT_PDB_IN_SNAP;
drop public synonym AWR_ROOT_PDB_IN_SNAP;
drop view AWR_ROOT_CELL_CONFIG;
drop public synonym AWR_ROOT_CELL_CONFIG;
drop view AWR_ROOT_CELL_CONFIG_DETAIL;
drop public synonym AWR_ROOT_CELL_CONFIG_DETAIL;
drop view AWR_ROOT_ASM_DISKGROUP;
drop public synonym AWR_ROOT_ASM_DISKGROUP;
drop view AWR_ROOT_ASM_DISKGROUP_STAT;
drop public synonym AWR_ROOT_ASM_DISKGROUP_STAT;
drop view AWR_ROOT_ASM_BAD_DISK;
drop public synonym AWR_ROOT_ASM_BAD_DISK;
drop view AWR_ROOT_CELL_NAME;
drop public synonym AWR_ROOT_CELL_NAME;
drop view AWR_ROOT_CELL_DISKTYPE;
drop public synonym AWR_ROOT_CELL_DISKTYPE;
drop view AWR_ROOT_CELL_DISK_NAME;
drop public synonym AWR_ROOT_CELL_DISK_NAME;
drop view AWR_ROOT_CELL_GLOBAL_SUMMARY;
drop public synonym AWR_ROOT_CELL_GLOBAL_SUMMARY;
drop view AWR_ROOT_CELL_DISK_SUMMARY;
drop public synonym AWR_ROOT_CELL_DISK_SUMMARY;
drop view AWR_ROOT_CELL_METRIC_DESC;
drop public synonym AWR_ROOT_CELL_METRIC_DESC;
drop view AWR_ROOT_CELL_IOREASON_NAME;
drop public synonym AWR_ROOT_CELL_IOREASON_NAME;
drop view AWR_ROOT_CELL_GLOBAL;
drop public synonym AWR_ROOT_CELL_GLOBAL;
drop view AWR_ROOT_CELL_IOREASON;
drop public synonym AWR_ROOT_CELL_IOREASON;
drop view AWR_ROOT_CELL_DB;
drop public synonym AWR_ROOT_CELL_DB;
drop view AWR_ROOT_CELL_OPEN_ALERTS;
drop public synonym AWR_ROOT_CELL_OPEN_ALERTS;
drop view AWR_ROOT_IM_SEG_STAT;
drop public synonym AWR_ROOT_IM_SEG_STAT;
drop view AWR_ROOT_IM_SEG_STAT_OBJ;
drop public synonym AWR_ROOT_IM_SEG_STAT_OBJ;
drop view AWR_ROOT_CON_SYSSTAT;
drop public synonym AWR_ROOT_CON_SYSSTAT;
drop view AWR_ROOT_WR_SETTINGS;
drop public synonym AWR_ROOT_WR_SETTINGS;
drop view AWR_ROOT_BASELINE;
drop public synonym AWR_ROOT_BASELINE;
drop view AWR_ROOT_BASELINE_DETAILS;
drop public synonym AWR_ROOT_BASELINE_DETAILS;
drop view AWR_ROOT_SQLBIND;
drop public synonym AWR_ROOT_SQLBIND;
drop view AWR_ROOT_CON_SYSTEM_EVENT;
drop public synonym AWR_ROOT_CON_SYSTEM_EVENT;
drop view AWR_ROOT_RECOVERY_PROGRESS;
drop public synonym AWR_ROOT_RECOVERY_PROGRESS;

-- drop AWR_PDB views

drop view AWR_PDB_DATABASE_INSTANCE;
drop public synonym AWR_PDB_DATABASE_INSTANCE;
drop view AWR_PDB_SNAPSHOT;
drop public synonym AWR_PDB_SNAPSHOT;
drop view AWR_PDB_SNAP_ERROR;
drop public synonym AWR_PDB_SNAP_ERROR;
drop view AWR_PDB_COLORED_SQL;
drop public synonym AWR_PDB_COLORED_SQL;
drop view AWR_PDB_BASELINE_METADATA;
drop public synonym AWR_PDB_BASELINE_METADATA;
drop view AWR_PDB_BASELINE_TEMPLATE;
drop public synonym AWR_PDB_BASELINE_TEMPLATE;
drop view AWR_PDB_WR_CONTROL;
drop public synonym AWR_PDB_WR_CONTROL;
drop view AWR_PDB_TABLESPACE;
drop public synonym AWR_PDB_TABLESPACE;
drop view AWR_PDB_DATAFILE;
drop public synonym AWR_PDB_DATAFILE;
drop view AWR_PDB_FILESTATXS;
drop public synonym AWR_PDB_FILESTATXS;
drop view AWR_PDB_TEMPFILE;
drop public synonym AWR_PDB_TEMPFILE;
drop view AWR_PDB_TEMPSTATXS;
drop public synonym AWR_PDB_TEMPSTATXS;
drop view AWR_PDB_COMP_IOSTAT;
drop public synonym AWR_PDB_COMP_IOSTAT;
drop view AWR_PDB_SQLSTAT;
drop public synonym AWR_PDB_SQLSTAT;
drop view AWR_PDB_SQLTEXT;
drop public synonym AWR_PDB_SQLTEXT;
drop view AWR_PDB_SQL_SUMMARY;
drop public synonym AWR_PDB_SQL_SUMMARY;
drop view AWR_PDB_SQL_PLAN;
drop public synonym AWR_PDB_SQL_PLAN;
drop view AWR_PDB_SQL_BIND_METADATA;
drop public synonym AWR_PDB_SQL_BIND_METADATA;
drop view AWR_PDB_OPTIMIZER_ENV;
drop public synonym AWR_PDB_OPTIMIZER_ENV;
drop view AWR_PDB_EVENT_NAME;
drop public synonym AWR_PDB_EVENT_NAME;
drop view AWR_PDB_SYSTEM_EVENT;
drop public synonym AWR_PDB_SYSTEM_EVENT;
drop view AWR_PDB_BG_EVENT_SUMMARY;
drop public synonym AWR_PDB_BG_EVENT_SUMMARY;
drop view AWR_PDB_WAITSTAT;
drop public synonym AWR_PDB_WAITSTAT;
drop view AWR_PDB_ENQUEUE_STAT;
drop public synonym AWR_PDB_ENQUEUE_STAT;
drop view AWR_PDB_LATCH_NAME;
drop public synonym AWR_PDB_LATCH_NAME;
drop view AWR_PDB_LATCH;
drop public synonym AWR_PDB_LATCH;
drop view AWR_PDB_LATCH_CHILDREN;
drop public synonym AWR_PDB_LATCH_CHILDREN;
drop view AWR_PDB_LATCH_PARENT;
drop public synonym AWR_PDB_LATCH_PARENT;
drop view AWR_PDB_LATCH_MISSES_SUMMARY;
drop public synonym AWR_PDB_LATCH_MISSES_SUMMARY;
drop view AWR_PDB_EVENT_HISTOGRAM;
drop public synonym AWR_PDB_EVENT_HISTOGRAM;
drop view AWR_PDB_MUTEX_SLEEP;
drop public synonym AWR_PDB_MUTEX_SLEEP;
drop view AWR_PDB_LIBRARYCACHE;
drop public synonym AWR_PDB_LIBRARYCACHE;
drop view AWR_PDB_DB_CACHE_ADVICE;
drop public synonym AWR_PDB_DB_CACHE_ADVICE;
drop view AWR_PDB_BUFFER_POOL_STAT;
drop public synonym AWR_PDB_BUFFER_POOL_STAT;
drop view AWR_PDB_ROWCACHE_SUMMARY;
drop public synonym AWR_PDB_ROWCACHE_SUMMARY;
drop view AWR_PDB_SGA;
drop public synonym AWR_PDB_SGA;
drop view AWR_PDB_SGASTAT;
drop public synonym AWR_PDB_SGASTAT;
drop view AWR_PDB_PGASTAT;
drop public synonym AWR_PDB_PGASTAT;
drop view AWR_PDB_PROCESS_MEM_SUMMARY;
drop public synonym AWR_PDB_PROCESS_MEM_SUMMARY;
drop view AWR_PDB_RESOURCE_LIMIT;
drop public synonym AWR_PDB_RESOURCE_LIMIT;
drop view AWR_PDB_SHARED_POOL_ADVICE;
drop public synonym AWR_PDB_SHARED_POOL_ADVICE;
drop view AWR_PDB_STREAMS_POOL_ADVICE;
drop public synonym AWR_PDB_STREAMS_POOL_ADVICE;
drop view AWR_PDB_SQL_WORKAREA_HSTGRM;
drop public synonym AWR_PDB_SQL_WORKAREA_HSTGRM;
drop view AWR_PDB_PGA_TARGET_ADVICE;
drop public synonym AWR_PDB_PGA_TARGET_ADVICE;
drop view AWR_PDB_SGA_TARGET_ADVICE;
drop public synonym AWR_PDB_SGA_TARGET_ADVICE;
drop view AWR_PDB_MEMORY_TARGET_ADVICE;
drop public synonym AWR_PDB_MEMORY_TARGET_ADVICE;
drop view AWR_PDB_MEMORY_RESIZE_OPS;
drop public synonym AWR_PDB_MEMORY_RESIZE_OPS;
drop view AWR_PDB_INSTANCE_RECOVERY;
drop public synonym AWR_PDB_INSTANCE_RECOVERY;
drop view AWR_PDB_JAVA_POOL_ADVICE;
drop public synonym AWR_PDB_JAVA_POOL_ADVICE;
drop view AWR_PDB_THREAD;
drop public synonym AWR_PDB_THREAD;
drop view AWR_PDB_STAT_NAME;
drop public synonym AWR_PDB_STAT_NAME;
drop view AWR_PDB_SYSSTAT;
drop public synonym AWR_PDB_SYSSTAT;
drop view AWR_PDB_SYS_TIME_MODEL;
drop public synonym AWR_PDB_SYS_TIME_MODEL;
drop view AWR_PDB_CON_SYS_TIME_MODEL;
drop public synonym AWR_PDB_CON_SYS_TIME_MODEL;
drop view AWR_PDB_OSSTAT_NAME;
drop public synonym AWR_PDB_OSSTAT_NAME;
drop view AWR_PDB_OSSTAT;
drop public synonym AWR_PDB_OSSTAT;
drop view AWR_PDB_PARAMETER_NAME;
drop public synonym AWR_PDB_PARAMETER_NAME;
drop view AWR_PDB_PARAMETER;
drop public synonym AWR_PDB_PARAMETER;
drop view AWR_PDB_MVPARAMETER;
drop public synonym AWR_PDB_MVPARAMETER;
drop view AWR_PDB_UNDOSTAT;
drop public synonym AWR_PDB_UNDOSTAT;
drop view AWR_PDB_SEG_STAT;
drop public synonym AWR_PDB_SEG_STAT;
drop view AWR_PDB_SEG_STAT_OBJ;
drop public synonym AWR_PDB_SEG_STAT_OBJ;
drop view AWR_PDB_METRIC_NAME;
drop public synonym AWR_PDB_METRIC_NAME;
drop view AWR_PDB_SYSMETRIC_HISTORY;
drop public synonym AWR_PDB_SYSMETRIC_HISTORY;
drop view AWR_PDB_SYSMETRIC_SUMMARY;
drop public synonym AWR_PDB_SYSMETRIC_SUMMARY;
drop view AWR_PDB_CON_SYSMETRIC_HIST;
drop public synonym AWR_PDB_CON_SYSMETRIC_HIST;
drop view AWR_PDB_CON_SYSMETRIC_SUMM;
drop public synonym AWR_PDB_CON_SYSMETRIC_SUMM;
drop view AWR_PDB_REPLICATION_TXN_STATS;
drop public synonym AWR_PDB_REPLICATION_TXN_STATS;
drop view AWR_PDB_SESSMETRIC_HISTORY;
drop public synonym AWR_PDB_SESSMETRIC_HISTORY;
drop view AWR_PDB_FILEMETRIC_HISTORY;
drop public synonym AWR_PDB_FILEMETRIC_HISTORY;
drop view AWR_PDB_WAITCLASSMET_HISTORY;
drop public synonym AWR_PDB_WAITCLASSMET_HISTORY;
drop view AWR_PDB_DLM_MISC;
drop public synonym AWR_PDB_DLM_MISC;
drop view AWR_PDB_CR_BLOCK_SERVER;
drop public synonym AWR_PDB_CR_BLOCK_SERVER;
drop view AWR_PDB_CURRENT_BLOCK_SERVER;
drop public synonym AWR_PDB_CURRENT_BLOCK_SERVER;
drop view AWR_PDB_INST_CACHE_TRANSFER;
drop public synonym AWR_PDB_INST_CACHE_TRANSFER;
drop view AWR_PDB_PLAN_OPERATION_NAME;
drop public synonym AWR_PDB_PLAN_OPERATION_NAME;
drop view AWR_PDB_PLAN_OPTION_NAME;
drop public synonym AWR_PDB_PLAN_OPTION_NAME;
drop view AWR_PDB_SQLCOMMAND_NAME;
drop public synonym AWR_PDB_SQLCOMMAND_NAME;
drop view AWR_PDB_TOPLEVELCALL_NAME;
drop public synonym AWR_PDB_TOPLEVELCALL_NAME;
drop view AWR_PDB_ACTIVE_SESS_HISTORY;
drop public synonym AWR_PDB_ACTIVE_SESS_HISTORY;
drop view AWR_PDB_ASH_SNAPSHOT;
drop public synonym AWR_PDB_ASH_SNAPSHOT;
drop view AWR_PDB_TABLESPACE_STAT;
drop public synonym AWR_PDB_TABLESPACE_STAT;
drop view AWR_PDB_LOG;
drop public synonym AWR_PDB_LOG;
drop view AWR_PDB_MTTR_TARGET_ADVICE;
drop public synonym AWR_PDB_MTTR_TARGET_ADVICE;
drop view AWR_PDB_TBSPC_SPACE_USAGE;
drop public synonym AWR_PDB_TBSPC_SPACE_USAGE;
drop view AWR_PDB_SERVICE_NAME;
drop public synonym AWR_PDB_SERVICE_NAME;
drop view AWR_PDB_SERVICE_STAT;
drop public synonym AWR_PDB_SERVICE_STAT;
drop view AWR_PDB_SERVICE_WAIT_CLASS;
drop public synonym AWR_PDB_SERVICE_WAIT_CLASS;
drop view AWR_PDB_SESS_TIME_STATS;
drop public synonym AWR_PDB_SESS_TIME_STATS;
drop view AWR_PDB_STREAMS_CAPTURE;
drop public synonym AWR_PDB_STREAMS_CAPTURE;
drop view AWR_PDB_CAPTURE;
drop public synonym AWR_PDB_CAPTURE;
drop view AWR_PDB_STREAMS_APPLY_SUM;
drop public synonym AWR_PDB_STREAMS_APPLY_SUM;
drop view AWR_PDB_APPLY_SUMMARY;
drop public synonym AWR_PDB_APPLY_SUMMARY;
drop view AWR_PDB_BUFFERED_QUEUES;
drop public synonym AWR_PDB_BUFFERED_QUEUES;
drop view AWR_PDB_BUFFERED_SUBSCRIBERS;
drop public synonym AWR_PDB_BUFFERED_SUBSCRIBERS;
drop view AWR_PDB_RULE_SET;
drop public synonym AWR_PDB_RULE_SET;
drop view AWR_PDB_PERSISTENT_QUEUES;
drop public synonym AWR_PDB_PERSISTENT_QUEUES;
drop view AWR_PDB_PERSISTENT_SUBS;
drop public synonym AWR_PDB_PERSISTENT_SUBS;
drop view AWR_PDB_SESS_SGA_STATS;
drop public synonym AWR_PDB_SESS_SGA_STATS;
drop view AWR_PDB_REPLICATION_TBL_STATS;
drop public synonym AWR_PDB_REPLICATION_TBL_STATS;
drop view AWR_PDB_REPLICATION_TXN_STAT;
drop public synonym AWR_PDB_REPLICATION_TXN_STAT;
drop view AWR_PDB_IOSTAT_FUNCTION;
drop public synonym AWR_PDB_IOSTAT_FUNCTION;
drop view AWR_PDB_IOSTAT_FUNCTION_NAME;
drop public synonym AWR_PDB_IOSTAT_FUNCTION_NAME;
drop view AWR_PDB_IOSTAT_FILETYPE;
drop public synonym AWR_PDB_IOSTAT_FILETYPE;
drop view AWR_PDB_IOSTAT_FILETYPE_NAME;
drop public synonym AWR_PDB_IOSTAT_FILETYPE_NAME;
drop view AWR_PDB_IOSTAT_DETAIL;
drop public synonym AWR_PDB_IOSTAT_DETAIL;
drop view AWR_PDB_RSRC_CONSUMER_GROUP;
drop public synonym AWR_PDB_RSRC_CONSUMER_GROUP;
drop view AWR_PDB_RSRC_PLAN;
drop public synonym AWR_PDB_RSRC_PLAN;
drop view AWR_PDB_CLUSTER_INTERCON;
drop public synonym AWR_PDB_CLUSTER_INTERCON;
drop view AWR_PDB_MEM_DYNAMIC_COMP;
drop public synonym AWR_PDB_MEM_DYNAMIC_COMP;
drop view AWR_PDB_IC_CLIENT_STATS;
drop public synonym AWR_PDB_IC_CLIENT_STATS;
drop view AWR_PDB_IC_DEVICE_STATS;
drop public synonym AWR_PDB_IC_DEVICE_STATS;
drop view AWR_PDB_INTERCONNECT_PINGS;
drop public synonym AWR_PDB_INTERCONNECT_PINGS;
drop view AWR_PDB_DISPATCHER;
drop public synonym AWR_PDB_DISPATCHER;
drop view AWR_PDB_SHARED_SERVER_SUMMARY;
drop public synonym AWR_PDB_SHARED_SERVER_SUMMARY;
drop view AWR_PDB_DYN_REMASTER_STATS;
drop public synonym AWR_PDB_DYN_REMASTER_STATS;
drop view AWR_PDB_LMS_STATS;
drop public synonym AWR_PDB_LMS_STATS;
drop view AWR_PDB_PERSISTENT_QMN_CACHE;
drop public synonym AWR_PDB_PERSISTENT_QMN_CACHE;
drop view AWR_PDB_PDB_INSTANCE;
drop public synonym AWR_PDB_PDB_INSTANCE;
drop view AWR_PDB_PDB_IN_SNAP;
drop public synonym AWR_PDB_PDB_IN_SNAP;
drop view AWR_PDB_CELL_CONFIG;
drop public synonym AWR_PDB_CELL_CONFIG;
drop view AWR_PDB_CELL_CONFIG_DETAIL;
drop public synonym AWR_PDB_CELL_CONFIG_DETAIL;
drop view AWR_PDB_ASM_DISKGROUP;
drop public synonym AWR_PDB_ASM_DISKGROUP;
drop view AWR_PDB_ASM_DISKGROUP_STAT;
drop public synonym AWR_PDB_ASM_DISKGROUP_STAT;
drop view AWR_PDB_ASM_BAD_DISK;
drop public synonym AWR_PDB_ASM_BAD_DISK;
drop view AWR_PDB_CELL_NAME;
drop public synonym AWR_PDB_CELL_NAME;
drop view AWR_PDB_CELL_DISKTYPE;
drop public synonym AWR_PDB_CELL_DISKTYPE;
drop view AWR_PDB_CELL_DISK_NAME;
drop public synonym AWR_PDB_CELL_DISK_NAME;
drop view AWR_PDB_CELL_GLOBAL_SUMMARY;
drop public synonym AWR_PDB_CELL_GLOBAL_SUMMARY;
drop view AWR_PDB_CELL_DISK_SUMMARY;
drop public synonym AWR_PDB_CELL_DISK_SUMMARY;
drop view AWR_PDB_CELL_METRIC_DESC;
drop public synonym AWR_PDB_CELL_METRIC_DESC;
drop view AWR_PDB_CELL_IOREASON_NAME;
drop public synonym AWR_PDB_CELL_IOREASON_NAME;
drop view AWR_PDB_CELL_GLOBAL;
drop public synonym AWR_PDB_CELL_GLOBAL;
drop view AWR_PDB_CELL_IOREASON;
drop public synonym AWR_PDB_CELL_IOREASON;
drop view AWR_PDB_CELL_DB;
drop public synonym AWR_PDB_CELL_DB;
drop view AWR_PDB_CELL_OPEN_ALERTS;
drop public synonym AWR_PDB_CELL_OPEN_ALERTS;
drop view AWR_PDB_IM_SEG_STAT;
drop public synonym AWR_PDB_IM_SEG_STAT;
drop view AWR_PDB_IM_SEG_STAT_OBJ;
drop public synonym AWR_PDB_IM_SEG_STAT_OBJ;
drop view AWR_PDB_CON_SYSSTAT;
drop public synonym AWR_PDB_CON_SYSSTAT;
drop view AWR_PDB_WR_SETTINGS;
drop public synonym AWR_PDB_WR_SETTINGS;
drop view AWR_PDB_BASELINE;
drop public synonym AWR_PDB_BASELINE;
drop view AWR_PDB_BASELINE_DETAILS;
drop public synonym AWR_PDB_BASELINE_DETAILS;
drop view AWR_PDB_SQLBIND;
drop public synonym AWR_PDB_SQLBIND;
drop view AWR_PDB_CON_SYSTEM_EVENT;
drop public synonym AWR_PDB_CON_SYSTEM_EVENT;
drop view AWR_PDB_RECOVERY_PROGRESS;
drop public synonym AWR_PDB_RECOVERY_PROGRESS;


-- drop CDB_HIST views

drop view CDB_HIST_DATABASE_INSTANCE;
drop public synonym CDB_HIST_DATABASE_INSTANCE;
drop view CDB_HIST_SNAPSHOT;
drop public synonym CDB_HIST_SNAPSHOT;
drop view CDB_HIST_SNAP_ERROR;
drop public synonym CDB_HIST_SNAP_ERROR;
drop view CDB_HIST_COLORED_SQL;
drop public synonym CDB_HIST_COLORED_SQL;
drop view CDB_HIST_BASELINE_METADATA;
drop public synonym CDB_HIST_BASELINE_METADATA;
drop view CDB_HIST_BASELINE_TEMPLATE;
drop public synonym CDB_HIST_BASELINE_TEMPLATE;
drop view CDB_HIST_WR_CONTROL;
drop public synonym CDB_HIST_WR_CONTROL;
drop view CDB_HIST_TABLESPACE;
drop public synonym CDB_HIST_TABLESPACE;
drop view CDB_HIST_DATAFILE;
drop public synonym CDB_HIST_DATAFILE;
drop view CDB_HIST_FILESTATXS;
drop public synonym CDB_HIST_FILESTATXS;
drop view CDB_HIST_TEMPFILE;
drop public synonym CDB_HIST_TEMPFILE;
drop view CDB_HIST_TEMPSTATXS;
drop public synonym CDB_HIST_TEMPSTATXS;
drop view CDB_HIST_COMP_IOSTAT;
drop public synonym CDB_HIST_COMP_IOSTAT;
drop view CDB_HIST_SQLSTAT;
drop public synonym CDB_HIST_SQLSTAT;
drop view CDB_HIST_SQLTEXT;
drop public synonym CDB_HIST_SQLTEXT;
drop view CDB_HIST_SQL_SUMMARY;
drop public synonym CDB_HIST_SQL_SUMMARY;
drop view CDB_HIST_SQL_PLAN;
drop public synonym CDB_HIST_SQL_PLAN;
drop view CDB_HIST_SQL_BIND_METADATA;
drop public synonym CDB_HIST_SQL_BIND_METADATA;
drop view CDB_HIST_OPTIMIZER_ENV;
drop public synonym CDB_HIST_OPTIMIZER_ENV;
drop view CDB_HIST_EVENT_NAME;
drop public synonym CDB_HIST_EVENT_NAME;
drop view CDB_HIST_SYSTEM_EVENT;
drop public synonym CDB_HIST_SYSTEM_EVENT;
drop view CDB_HIST_BG_EVENT_SUMMARY;
drop public synonym CDB_HIST_BG_EVENT_SUMMARY;
drop view CDB_HIST_CHANNEL_WAITS;
drop public synonym CDB_HIST_CHANNEL_WAITS;
drop view CDB_HIST_WAITSTAT;
drop public synonym CDB_HIST_WAITSTAT;
drop view CDB_HIST_ENQUEUE_STAT;
drop public synonym CDB_HIST_ENQUEUE_STAT;
drop view CDB_HIST_LATCH_NAME;
drop public synonym CDB_HIST_LATCH_NAME;
drop view CDB_HIST_LATCH;
drop public synonym CDB_HIST_LATCH;
drop view CDB_HIST_LATCH_CHILDREN;
drop public synonym CDB_HIST_LATCH_CHILDREN;
drop view CDB_HIST_LATCH_PARENT;
drop public synonym CDB_HIST_LATCH_PARENT;
drop view CDB_HIST_LATCH_MISSES_SUMMARY;
drop public synonym CDB_HIST_LATCH_MISSES_SUMMARY;
drop view CDB_HIST_EVENT_HISTOGRAM;
drop public synonym CDB_HIST_EVENT_HISTOGRAM;
drop view CDB_HIST_MUTEX_SLEEP;
drop public synonym CDB_HIST_MUTEX_SLEEP;
drop view CDB_HIST_LIBRARYCACHE;
drop public synonym CDB_HIST_LIBRARYCACHE;
drop view CDB_HIST_DB_CACHE_ADVICE;
drop public synonym CDB_HIST_DB_CACHE_ADVICE;
drop view CDB_HIST_BUFFER_POOL_STAT;
drop public synonym CDB_HIST_BUFFER_POOL_STAT;
drop view CDB_HIST_ROWCACHE_SUMMARY;
drop public synonym CDB_HIST_ROWCACHE_SUMMARY;
drop view CDB_HIST_SGA;
drop public synonym CDB_HIST_SGA;
drop view CDB_HIST_SGASTAT;
drop public synonym CDB_HIST_SGASTAT;
drop view CDB_HIST_PGASTAT;
drop public synonym CDB_HIST_PGASTAT;
drop view CDB_HIST_PROCESS_MEM_SUMMARY;
drop public synonym CDB_HIST_PROCESS_MEM_SUMMARY;
drop view CDB_HIST_RESOURCE_LIMIT;
drop public synonym CDB_HIST_RESOURCE_LIMIT;
drop view CDB_HIST_SHARED_POOL_ADVICE;
drop public synonym CDB_HIST_SHARED_POOL_ADVICE;
drop view CDB_HIST_STREAMS_POOL_ADVICE;
drop public synonym CDB_HIST_STREAMS_POOL_ADVICE;
drop view CDB_HIST_SQL_WORKAREA_HSTGRM;
drop public synonym CDB_HIST_SQL_WORKAREA_HSTGRM;
drop view CDB_HIST_PGA_TARGET_ADVICE;
drop public synonym CDB_HIST_PGA_TARGET_ADVICE;
drop view CDB_HIST_SGA_TARGET_ADVICE;
drop public synonym CDB_HIST_SGA_TARGET_ADVICE;
drop view CDB_HIST_MEMORY_TARGET_ADVICE;
drop public synonym CDB_HIST_MEMORY_TARGET_ADVICE;
drop view CDB_HIST_MEMORY_RESIZE_OPS;
drop public synonym CDB_HIST_MEMORY_RESIZE_OPS;
drop view CDB_HIST_INSTANCE_RECOVERY;
drop public synonym CDB_HIST_INSTANCE_RECOVERY;
drop view CDB_HIST_JAVA_POOL_ADVICE;
drop public synonym CDB_HIST_JAVA_POOL_ADVICE;
drop view CDB_HIST_THREAD;
drop public synonym CDB_HIST_THREAD;
drop view CDB_HIST_STAT_NAME;
drop public synonym CDB_HIST_STAT_NAME;
drop view CDB_HIST_SYSSTAT;
drop public synonym CDB_HIST_SYSSTAT;
drop view CDB_HIST_CON_SYSSTAT;
drop public synonym CDB_HIST_CON_SYSSTAT;
drop view CDB_HIST_SYS_TIME_MODEL;
drop public synonym CDB_HIST_SYS_TIME_MODEL;
drop view CDB_HIST_CON_SYS_TIME_MODEL;
drop public synonym CDB_HIST_CON_SYS_TIME_MODEL;
drop view CDB_HIST_OSSTAT_NAME;
drop public synonym CDB_HIST_OSSTAT_NAME;
drop view CDB_HIST_OSSTAT;
drop public synonym CDB_HIST_OSSTAT;
drop view CDB_HIST_PARAMETER_NAME;
drop public synonym CDB_HIST_PARAMETER_NAME;
drop view CDB_HIST_PARAMETER;
drop public synonym CDB_HIST_PARAMETER;
drop view CDB_HIST_MVPARAMETER;
drop public synonym CDB_HIST_MVPARAMETER;
drop view CDB_HIST_UNDOSTAT;
drop public synonym CDB_HIST_UNDOSTAT;
drop view CDB_HIST_SEG_STAT;
drop public synonym CDB_HIST_SEG_STAT;
drop view CDB_HIST_SEG_STAT_OBJ;
drop public synonym CDB_HIST_SEG_STAT_OBJ;
drop view CDB_HIST_METRIC_NAME;
drop public synonym CDB_HIST_METRIC_NAME;
drop view CDB_HIST_SYSMETRIC_HISTORY;
drop public synonym CDB_HIST_SYSMETRIC_HISTORY;
drop view CDB_HIST_SYSMETRIC_SUMMARY;
drop public synonym CDB_HIST_SYSMETRIC_SUMMARY;
drop view CDB_HIST_CON_SYSMETRIC_HIST;
drop public synonym CDB_HIST_CON_SYSMETRIC_HIST;
drop view CDB_HIST_CON_SYSMETRIC_SUMM;
drop public synonym CDB_HIST_CON_SYSMETRIC_SUMM;
drop view CDB_HIST_SESSMETRIC_HISTORY;
drop public synonym CDB_HIST_SESSMETRIC_HISTORY;
drop view CDB_HIST_FILEMETRIC_HISTORY;
drop public synonym CDB_HIST_FILEMETRIC_HISTORY;
drop view CDB_HIST_WAITCLASSMET_HISTORY;
drop public synonym CDB_HIST_WAITCLASSMET_HISTORY;
drop view CDB_HIST_DLM_MISC;
drop public synonym CDB_HIST_DLM_MISC;
drop view CDB_HIST_CR_BLOCK_SERVER;
drop public synonym CDB_HIST_CR_BLOCK_SERVER;
drop view CDB_HIST_CURRENT_BLOCK_SERVER;
drop public synonym CDB_HIST_CURRENT_BLOCK_SERVER;
drop view CDB_HIST_INST_CACHE_TRANSFER;
drop public synonym CDB_HIST_INST_CACHE_TRANSFER;
drop view CDB_HIST_PLAN_OPERATION_NAME;
drop public synonym CDB_HIST_PLAN_OPERATION_NAME;
drop view CDB_HIST_PLAN_OPTION_NAME;
drop public synonym CDB_HIST_PLAN_OPTION_NAME;
drop view CDB_HIST_SQLCOMMAND_NAME;
drop public synonym CDB_HIST_SQLCOMMAND_NAME;
drop view CDB_HIST_TOPLEVELCALL_NAME;
drop public synonym CDB_HIST_TOPLEVELCALL_NAME;
drop view CDB_HIST_ACTIVE_SESS_HISTORY;
drop public synonym CDB_HIST_ACTIVE_SESS_HISTORY;
drop view CDB_HIST_ASH_SNAPSHOT;
drop public synonym CDB_HIST_ASH_SNAPSHOT;
drop view CDB_HIST_TABLESPACE_STAT;
drop public synonym CDB_HIST_TABLESPACE_STAT;
drop view CDB_HIST_LOG;
drop public synonym CDB_HIST_LOG;
drop view CDB_HIST_MTTR_TARGET_ADVICE;
drop public synonym CDB_HIST_MTTR_TARGET_ADVICE;
drop view CDB_HIST_TBSPC_SPACE_USAGE;
drop public synonym CDB_HIST_TBSPC_SPACE_USAGE;
drop view CDB_HIST_SERVICE_NAME;
drop public synonym CDB_HIST_SERVICE_NAME;
drop view CDB_HIST_SERVICE_STAT;
drop public synonym CDB_HIST_SERVICE_STAT;
drop view CDB_HIST_SERVICE_WAIT_CLASS;
drop public synonym CDB_HIST_SERVICE_WAIT_CLASS;
drop view CDB_HIST_SESS_TIME_STATS;
drop public synonym CDB_HIST_SESS_TIME_STATS;
drop view CDB_HIST_STREAMS_CAPTURE;
drop public synonym CDB_HIST_STREAMS_CAPTURE;
drop view CDB_HIST_CAPTURE;
drop public synonym CDB_HIST_CAPTURE;
drop view CDB_HIST_STREAMS_APPLY_SUM;
drop public synonym CDB_HIST_STREAMS_APPLY_SUM;
drop view CDB_HIST_APPLY_SUMMARY;
drop public synonym CDB_HIST_APPLY_SUMMARY;
drop view CDB_HIST_BUFFERED_QUEUES;
drop public synonym CDB_HIST_BUFFERED_QUEUES;
drop view CDB_HIST_BUFFERED_SUBSCRIBERS;
drop public synonym CDB_HIST_BUFFERED_SUBSCRIBERS;
drop view CDB_HIST_RULE_SET;
drop public synonym CDB_HIST_RULE_SET;
drop view CDB_HIST_PERSISTENT_QUEUES;
drop public synonym CDB_HIST_PERSISTENT_QUEUES;
drop view CDB_HIST_PERSISTENT_SUBS;
drop public synonym CDB_HIST_PERSISTENT_SUBS;
drop view CDB_HIST_SESS_SGA_STATS;
drop public synonym CDB_HIST_SESS_SGA_STATS;
drop view CDB_HIST_REPLICATION_TBL_STATS;
drop public synonym CDB_HIST_REPLICATION_TBL_STATS;
drop view CDB_HIST_REPLICATION_TXN_STATS;
drop public synonym CDB_HIST_REPLICATION_TXN_STATS;
drop view CDB_HIST_IOSTAT_FUNCTION;
drop public synonym CDB_HIST_IOSTAT_FUNCTION;
drop view CDB_HIST_IOSTAT_FUNCTION_NAME;
drop public synonym CDB_HIST_IOSTAT_FUNCTION_NAME;
drop view CDB_HIST_IOSTAT_FILETYPE;
drop public synonym CDB_HIST_IOSTAT_FILETYPE;
drop view CDB_HIST_IOSTAT_FILETYPE_NAME;
drop public synonym CDB_HIST_IOSTAT_FILETYPE_NAME;
drop view CDB_HIST_IOSTAT_DETAIL;
drop public synonym CDB_HIST_IOSTAT_DETAIL;
drop view CDB_HIST_RSRC_CONSUMER_GROUP;
drop public synonym CDB_HIST_RSRC_CONSUMER_GROUP;
drop view CDB_HIST_RSRC_PLAN;
drop public synonym CDB_HIST_RSRC_PLAN;
drop view CDB_HIST_RSRC_METRIC;
drop public synonym CDB_HIST_RSRC_METRIC;
drop view CDB_HIST_RSRC_PDB_METRIC;
drop public synonym CDB_HIST_RSRC_PDB_METRIC;
drop view CDB_HIST_CLUSTER_INTERCON;
drop public synonym CDB_HIST_CLUSTER_INTERCON;
drop view CDB_HIST_MEM_DYNAMIC_COMP;
drop public synonym CDB_HIST_MEM_DYNAMIC_COMP;
drop view CDB_HIST_IC_CLIENT_STATS;
drop public synonym CDB_HIST_IC_CLIENT_STATS;
drop view CDB_HIST_IC_DEVICE_STATS;
drop public synonym CDB_HIST_IC_DEVICE_STATS;
drop view CDB_HIST_INTERCONNECT_PINGS;
drop public synonym CDB_HIST_INTERCONNECT_PINGS;
drop view CDB_HIST_DISPATCHER;
drop public synonym CDB_HIST_DISPATCHER;
drop view CDB_HIST_SHARED_SERVER_SUMMARY;
drop public synonym CDB_HIST_SHARED_SERVER_SUMMARY;
drop view CDB_HIST_DYN_REMASTER_STATS;
drop public synonym CDB_HIST_DYN_REMASTER_STATS;
drop view CDB_HIST_LMS_STATS;
drop public synonym CDB_HIST_LMS_STATS;
drop view CDB_HIST_PERSISTENT_QMN_CACHE;
drop public synonym CDB_HIST_PERSISTENT_QMN_CACHE;
drop view CDB_HIST_PDB_INSTANCE;
drop public synonym CDB_HIST_PDB_INSTANCE;
drop view CDB_HIST_PDB_IN_SNAP;
drop public synonym CDB_HIST_PDB_IN_SNAP;
drop view CDB_HIST_CELL_CONFIG;
drop public synonym CDB_HIST_CELL_CONFIG;
drop view CDB_HIST_CELL_CONFIG_DETAIL;
drop public synonym CDB_HIST_CELL_CONFIG_DETAIL;
drop view CDB_HIST_ASM_DISKGROUP;
drop public synonym CDB_HIST_ASM_DISKGROUP;
drop view CDB_HIST_ASM_DISKGROUP_STAT;
drop public synonym CDB_HIST_ASM_DISKGROUP_STAT;
drop view CDB_HIST_ASM_BAD_DISK;
drop public synonym CDB_HIST_ASM_BAD_DISK;
drop view CDB_HIST_CELL_NAME;
drop public synonym CDB_HIST_CELL_NAME;
drop view CDB_HIST_CELL_DISKTYPE;
drop public synonym CDB_HIST_CELL_DISKTYPE;
drop view CDB_HIST_CELL_DISK_NAME;
drop public synonym CDB_HIST_CELL_DISK_NAME;
drop view CDB_HIST_CELL_GLOBAL_SUMMARY;
drop public synonym CDB_HIST_CELL_GLOBAL_SUMMARY;
drop view CDB_HIST_CELL_DISK_SUMMARY;
drop public synonym CDB_HIST_CELL_DISK_SUMMARY;
drop view CDB_HIST_CELL_METRIC_DESC;
drop public synonym CDB_HIST_CELL_METRIC_DESC;
drop view CDB_HIST_CELL_IOREASON_NAME;
drop public synonym CDB_HIST_CELL_IOREASON_NAME;
drop view CDB_HIST_CELL_GLOBAL;
drop public synonym CDB_HIST_CELL_GLOBAL;
drop view CDB_HIST_CELL_IOREASON;
drop public synonym CDB_HIST_CELL_IOREASON;
drop view CDB_HIST_CELL_DB;
drop public synonym CDB_HIST_CELL_DB;
drop view CDB_HIST_CELL_OPEN_ALERTS;
drop public synonym CDB_HIST_CELL_OPEN_ALERTS;
drop view CDB_HIST_IM_SEG_STAT;
drop public synonym CDB_HIST_IM_SEG_STAT;
drop view CDB_HIST_IM_SEG_STAT_OBJ;
drop public synonym CDB_HIST_IM_SEG_STAT_OBJ;
drop view CDB_HIST_BASELINE;
drop public synonym CDB_HIST_BASELINE;
drop view CDB_HIST_BASELINE_DETAILS;
drop public synonym CDB_HIST_BASELINE_DETAILS;
drop view CDB_HIST_SQLBIND;
drop public synonym CDB_HIST_SQLBIND;
drop view CDB_HIST_CON_SYSTEM_EVENT;
drop public synonym CDB_HIST_CON_SYSTEM_EVENT;
drop view CDB_HIST_RECOVERY_PROGRESS;
drop public synonym CDB_HIST_RECOVERY_PROGRESS;


Rem =======================================================================
Rem End Changes for AWR for CDB/PDB
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for SVRMAN UMF. 
Rem =======================================================================

truncate table umf$_link; 
truncate table umf$_service;
truncate table umf$_registration; 
truncate table umf$_topology; 

drop view dba_umf_topology; 
drop view dba_umf_registration; 
drop view dba_umf_link; 
drop view dba_umf_service;
drop view umf_schema_xmltype;
drop view umf_topology_xml;
drop view umf_registration_xml;
drop view umf_link_xml; 
drop view umf_service_xml;
drop view umf$_topology_xml; 
drop view umf$_registration_xml; 
drop view umf$_link_xml; 
drop view umf$_service_xml;
drop package dbms_umf_protected;
drop package dbms_umf_internal;
drop package dbms_umf;

drop public synonym dba_umf_topology;
drop public synonym dba_umf_service;
drop public synonym dba_umf_registration;
drop public synonym dba_umf_link;
drop public synonym dbms_umf;
drop library dbms_umf_lib;

drop role sysumf_role;
drop user sys$umf cascade;

Rem =======================================================================
Rem End Changes for SVRMAN UMF. 
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for Proj: 47331 Remove Index Usage Tracking related views
Rem =======================================================================

truncate table wri$_index_usage;
drop public synonym DBA_INDEX_USAGE;
drop view SYS.DBA_INDEX_USAGE;
drop public synonym CDB_INDEX_USAGE;
drop view SYS.CDB_INDEX_USAGE;

drop view gv_$index_usage_info;
drop view v_$index_usage_info;
drop public synonym v$index_usage_info;
drop public synonym gv$index_usage_info;

Rem =======================================================================
Rem END Changes for Proj: 47331 
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$RECOVERY_SLAVE
Rem =======================================================================

drop public synonym gv$recovery_slave;
drop public synonym v$recovery_slave;
drop view gv_$recovery_slave;
drop view v_$recovery_slave;

Rem =======================================================================
Rem END Changes for [G]V$RECOVERY_SLAVE
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for ASM DISK(/GROUP) Sparse views
Rem =======================================================================

drop public synonym v$asm_diskgroup_sparse;
drop view v_$asm_diskgroup_sparse;
drop public synonym gv$asm_diskgroup_sparse;
drop view gv_$asm_diskgroup_sparse;

drop public synonym v$asm_disk_sparse;
drop view v_$asm_disk_sparse;
drop public synonym gv$asm_disk_sparse;
drop view gv_$asm_disk_sparse;

drop public synonym v$asm_disk_sparse_stat;
drop view v_$asm_disk_sparse_stat;
drop public synonym gv$asm_disk_sparse_stat;
drop view gv_$asm_disk_sparse_stat;

drop public synonym v$asm_disk_iostat_sparse;
drop view v_$asm_disk_iostat_sparse;
drop public synonym gv$asm_disk_iostat_sparse;
drop view gv_$asm_disk_iostat_sparse;

Rem =======================================================================
Rem End Changes for ASM DISK(/GROUP) Sparse views
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for ASM FILEGROUP Views
Rem =======================================================================

drop public synonym v$asm_filegroup;
drop view v_$asm_filegroup;
drop public synonym gv$asm_filegroup;
drop view gv_$asm_filegroup;

drop public synonym v$asm_filegroup_property;
drop view v_$asm_filegroup_property;
drop public synonym gv$asm_filegroup_property;
drop view gv_$asm_filegroup_property;

drop public synonym v$asm_filegroup_file;
drop view v_$asm_filegroup_file;
drop public synonym gv$asm_filegroup_file;
drop view gv_$asm_filegroup_file;

Rem =======================================================================
Rem End Changes for ASM FILEGROUP Views
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for ASM QUOTAGROUP Views
Rem =======================================================================

drop public synonym v$asm_quotagroup;
drop view v_$asm_quotagroup;
drop public synonym gv$asm_quotagroup;
drop view gv_$asm_quotagroup;

Rem =======================================================================
Rem End Changes for ASM QUOTAGROUP Views
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for ASM views
Rem =======================================================================

drop public synonym v$asm_dbclone_info;
drop view v_$asm_dbclone_info;
drop public synonym gv$asm_dbclone_info;
drop view gv_$asm_dbclone_info;

Rem =======================================================================
Rem End Changes for ASM views
Rem =======================================================================

Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current  version. ==
Rem ==  To 12.1.0.2 and later, set to SWRF version 11    ==
Rem ==  Earlier than 12.1.0.2, set to SWRF version 10    ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  downgrade changes.  Place all other AWR          ==
Rem ==  downgrade changes above this.                    ==
Rem ==  The range of values for swrf_version are defined ==
Rem ==  in kewr.h: KEWR_DB_RELEASE_* macros.             ==
Rem =======================================================
DECLARE
  previous_version      VARCHAR2(30);
  previous_swrf_version NUMBER;
BEGIN

  SELECT prv_version INTO previous_version FROM registry$
   WHERE  cid = 'CATPROC';

  IF previous_version < '12.1.0.2' THEN
     previous_swrf_version := 10;
  ELSE
    previous_swrf_version := 11;
  END IF;

  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    ' SET swrf_version = :prv, src_dbname = NULL' 
              USING previous_swrf_version;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/


Rem *************************************************************************
Rem Bug 19651064: AWR Changes in WRH$_SYSMETRIC_HISTORY
Rem *************************************************************************

alter index WRH$_SYSMETRIC_HISTORY_INDEX rename to OLD_SYSMETRIC_HISTORY_INDEX;
alter table WRH$_SYSMETRIC_HISTORY rename to OLD_SYSMETRIC_HISTORY;

create table            WRH$_SYSMETRIC_HISTORY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,intsize                number          not null
,group_id               number          not null
,metric_id              number          not null
,value                  number          not null
,con_dbid               number default 0 not null
,per_pdb                number default null
) tablespace SYSAUX
pctfree 1
/

create index WRH$_SYSMETRIC_HISTORY_INDEX 
 on WRH$_SYSMETRIC_HISTORY
 (dbid, snap_id, instance_number, group_id, metric_id, begin_time, con_dbid)
tablespace SYSAUX
/

insert into WRH$_SYSMETRIC_HISTORY select * from OLD_SYSMETRIC_HISTORY;
commit;

drop index OLD_SYSMETRIC_HISTORY_INDEX;
drop table OLD_SYSMETRIC_HISTORY;

-- lrg 16942052 
update WRH$_SEG_STAT_OBJ set object_name = substr(object_name, 1, 30)
where LENGTH(object_name) > 30;
commit;

Rem=================
Rem AWR Changes End
Rem=================

Rem =======================================================================
Rem Consolidated Database changes - BEGIN
Rem =======================================================================

drop public synonym DBA_PDB_SAVED_STATES;
drop view SYS.DBA_PDB_SAVED_STATES;
drop view SYS.CDB_PDB_SAVED_STATES;
drop public synonym CDB_PDB_SAVED_STATES;

drop public synonym dbms_pdb_alter_sharing;
drop package body sys.dbms_pdb_alter_sharing;
drop package sys.dbms_pdb_alter_sharing;

drop public synonym v$proxy_pdb_targets;
drop view sys.v_$proxy_pdb_targets;

drop public synonym gv$proxy_pdb_targets;
drop view sys.gv_$proxy_pdb_targets;

Rem =======================================================================
Rem Consolidated Database changes - END
Rem =======================================================================


Rem*************************************************************************
Rem BEGIN Undo the changes for mlog$ made for 12.2
Rem*************************************************************************

-- update the new_max_scn value to the old_max_scn value for commit-scn logs
declare
 cursor c1 is 
   select * from sys.mlog$ where bitand(flag, 65536) = 65536 for update;
   old_max_scn  number := 281474976710655;       /* 0xffffffffffff     */
   new_max_scn  number := 18446744073709551615;  /* 0xffffffffffffffff */
begin
 for rec in c1
 loop
   if rec.oscn = new_max_scn then
     update sys.mlog$ set oscn = old_max_scn where current of c1; 
   end if;

   if rec.oscn_pk = new_max_scn then
     update sys.mlog$ set oscn_pk = old_max_scn where current of c1; 
   end if;

   if rec.oscn_seq = new_max_scn then
     update sys.mlog$ set oscn_seq = old_max_scn where current of c1; 
   end if;

   if rec.oscn_oid = new_max_scn then
     update sys.mlog$ set oscn_oid = old_max_scn where current of c1; 
   end if;

   if rec.oscn_new = new_max_scn then
     update sys.mlog$ set oscn_new = old_max_scn where current of c1; 
   end if;

 end loop;
end;
/

Rem*************************************************************************
Rem END Changes for mlog$
Rem*************************************************************************


Rem ====================================================================
Rem Begin changes for Bug 16444144: Added optimized objects
Rem ====================================================================

DROP SYNONYM  SYS.HS$_DDTF_OPTTables;                            
DROP FUNCTION SYS.HS$_DDTF_OPTColumns;    
DROP TYPE     SYS.HS$_DDTF_OPTColumns_T;      
DROP TYPE     SYS.HS$_DDTF_OPTColumns_O;      
DROP SYNONYM  SYS.HS$_DDTF_OPTPrimaryKeys; 
DROP FUNCTION SYS.HS$_DDTF_OPTForeignKeys;
DROP TYPE     SYS.HS$_DDTF_OPTForeignKeys_T;  
DROP TYPE     SYS.HS$_DDTF_OPTForeignKeys_O;  
DROP FUNCTION SYS.HS$_DDTF_OPTProcedures; 
DROP TYPE     SYS.HS$_DDTF_OPTProcedures_T;   
DROP TYPE     SYS.HS$_DDTF_OPTProcedures_O;   
DROP FUNCTION SYS.HS$_DDTF_OPTStatistics; 
DROP TYPE     SYS.HS$_DDTF_OPTStatistics_T;   
DROP TYPE     SYS.HS$_DDTF_OPTStatistics_O;   
DROP FUNCTION SYS.HS$_DDTF_OPTTabPriKeys; 
DROP FUNCTION SYS.HS$_DDTF_OPTTabForKeys; 
DROP FUNCTION SYS.HS$_DDTF_OPTTabStats;   

Rem ====================================================================
Rem End changes for Bug 16444144: Added optimized objects
Rem ====================================================================


Rem*********************************************************************
Rem bug 15854162: Drop dbms_feature_adaptive_plans and 
Rem               dbms_feature_auto_reopt - BEGIN
Rem*********************************************************************

drop procedure dbms_feature_adaptive_plans;
drop procedure dbms_feature_auto_reopt;

Rem*********************************************************************
Rem bug 15854162: Drop dbms_feature_adaptive_plans and 
Rem               dbms_feature_auto_reop  - END
Rem*********************************************************************

Rem =========================================================================
Rem BEGIN SQL Translation Framework Changes
Rem =========================================================================

Rem Downgrade SQL ID and SQL hash to 12.1.0.1
declare

  md5      raw(16);
  sql_id   sqltxl_sql$.sqlid%type;
  sql_hash sqltxl_sql$.sqlhash%type;

  cursor c is select u.name owner, o.name profile_name,
                     o.defining_edition edition, s.sqltext sqltext
                from sqltxl_sql$ s, "_ACTUAL_EDITION_OBJ" o, user$ u
               where s.obj# = o.obj#
                 and o.owner# = u.user#
                 for update of s.sqlid, s.sqlhash;

  -- Cast a 4-byte raw to unsigned integer in machine endianness
  function unsigned_integer(r in raw) return number as
    n number;
  begin
    n := utl_raw.cast_to_binary_integer(r, utl_raw.machine_endian);
    if (n < 0) then
      n := n + 4294967296;
    end if;
    return n;
  end;

  -- MD5 hash to SQL ID
  function sqlt_sqlid(md5 in raw) return varchar2 as
    type map_type is varray(32) of varchar2(1);
    map  map_type := map_type('0', '1', '2', '3', '4', '5', '6', '7',
                              '8', '9', 'a', 'b', 'c', 'd', 'f', 'g',
                              'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r',
                              's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
    hash  number;
    sqlid varchar2(13);
  begin
    hash := unsigned_integer(utl_raw.substr(md5, 9, 4)) * 4294967296 +
            unsigned_integer(utl_raw.substr(md5, 13, 4));
    for i in 1..13 loop
      sqlid := map(mod(hash,32)+1) || sqlid;
      hash  := trunc(hash/32);
    end loop;
    return sqlid;
  end;

  -- MD5 hash to SQL hash
  function sqlt_sqlhash(md5 in raw) return number as
  begin
    return unsigned_integer(utl_raw.substr(md5, 13, 4));
  end;

begin

  for r in c loop
    -- In 12.1.0.1, SQL ID and SQL hash of SQL translations in profile include
    -- profile name and edition name
    md5 := dbms_crypto.hash(r.sqltext||chr(0)||
                            '"'||r.owner||'"."'||r.profile_name||'"'||r.edition,
                            dbms_crypto.hash_md5);
    sql_id   := sqlt_sqlid(md5);
    sql_hash := sqlt_sqlhash(md5);

    update sqltxl_sql$
       set sqlid = sql_id, sqlhash = sql_hash
     where current of c;
  end loop;

end;
/
commit;

Rem =========================================================================
Rem END SQL Translation Framework Changes
Rem =========================================================================

Rem =======================================================================
Rem Begin Changes for report framework / em express 
Rem =======================================================================

-- drop wri$_rept_statsadv
drop public synonym wri$_rept_statsadv;

BEGIN
  -- delete statsdv object before drop the subtype
  execute immediate 'delete from sys.wri$_rept_components
             where treat(object as wri$_rept_statsadv) is not null';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore 942 which may be caused during downgrade
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

drop type body wri$_rept_statsadv;

drop type wri$_rept_statsadv validate;

-- drop new packages generating new reports
drop package prvtemx_cell;

-- drop your report subtype synonyms here
drop public synonym wri$_rept_cell;

BEGIN
  -- delete cell object before drop the subtype
  execute immediate 'delete from sys.wri$_rept_components
             where treat(object as wri$_rept_cell) is not null';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore 942 which may be caused during downgrade
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/
 
-- drop your report subtypes here
drop type wri$_rept_cell validate;

-- drop the new prvtemx_sql package
DROP package prvtemx_sql;

-- drop prvtemx_sql synonym
DROP PUBLIC SYNONYM prvtemx_sql; 

-- drop new resource manager package
DROP package prvtemx_rsrcmgr;

-- drop resource manager report type, synonym and pacakge   
DROP PUBLIC SYNONYM wri$_rept_rsrcmgr;

BEGIN
  -- delete resource manager object before drop the subtype
  execute immediate 'delete from sys.wri$_rept_components
             where treat(object as wri$_rept_rsrcmgr) is not null';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore 942 which may be caused during downgrade
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

DROP TYPE wri$_rept_rsrcmgr VALIDATE;

-- feature usage changes 
drop procedure dbms_feature_emx;
drop public synonym v$emx_usage_stats;
drop view v_$emx_usage_stats;
drop public synonym gv$emx_usage_stats;
drop view gv_$emx_usage_stats;

-- remove resource manager admin system privilege 
revoke administer resource manager from em_express_all;

Rem =======================================================================
Rem End Changes for report framework / em express 
Rem =======================================================================

Rem =========================================================================
Rem BEGIN DATAPUMP Changes for 12.2
Rem Project 48787: views to document mdapi transforms
Rem =========================================================================
TRUNCATE TABLE metaxslparamdesc$;

Rem
Rem Bug 20722522: Drop and recreate index i_dependobj$
Rem =========================================================================
drop index i_dependobj;
create unique index i_dependobj on expdepobj$(d_obj#)
/

Rem =========================================================================
Rem END DATAPUMP Changes
Rem =========================================================================
Rem =========================================================================
Rem BEGIN Privilege Analysis Changes
Rem =========================================================================

--Bug 25337332: drop tables and type to avoid signature mismatches
drop table sys.priv_used_path$;
drop table sys.priv_unused_path$;
drop type sys.grant_path;

--Bug 18056142
revoke select on sys.priv_capture$ from capture_admin;
revoke select on sys.capture_run_log$ from capture_admin;

--Bug 18224840
drop function sys.grantpath_to_string;
drop function sys.string_to_grantpath;

--Project 46820
drop public synonym DBA_UNUSED_GRANTS;
drop view SYS.DBA_UNUSED_GRANTS;
drop public synonym cdb_unused_grants;
drop view sys.cdb_unused_grants;
truncate table sys.unused_grant$;

alter table sys.captured_priv$ drop column cbac_plist;
drop public synonym package_array;
drop type sys.package_array;

drop public synonym dba_checked_roles;
drop view sys.dba_checked_roles;
drop public synonym cdb_checked_roles;
drop view sys.cdb_checked_roles;
drop public synonym dba_checked_roles_path;
drop view sys.dba_checked_roles_path;
drop public synonym cdb_checked_roles_path;
drop view sys.cdb_checked_roles_path;

--Bug 22523826
update sys.priv_unused$ set run_seq# = 0;
update sys.captured_priv$ set app_roles = NULL;
update sys.capture_run_log$ set run_name = NULL;
commit;

Rem =========================================================================
Rem END Privilege Analysis Changes
Rem =========================================================================


Rem ====================================================================
Rem BEGIN changes for Privilege Analysis
Rem ====================================================================
drop public synonym rolename_array;
drop type sys.rolename_array FORCE;

-- bug 17496774
delete from sys.priv_capture$ where id# = 0;

Rem ====================================================================
Rem End changes for Privilege Analysis
Rem ====================================================================

Rem *************************************************************************
Rem BEGIN bug#17543726 : drop STIG compliant profile
Rem
Rem Bug# 22369990 : In 12.2, all out-of-the-box Oracle supplied password
Rem verification functions are created as common objects, so during downgrade
Rem they need to be dropped. Customer is expected to re-execute utlpwdmg.sql
Rem located underneath ${OH}/rdbms/admin, so as to re-create all the password
Rem verification functions as local objects.
Rem
Rem *************************************************************************

drop profile ora_stig_profile cascade;
drop function ora12c_strong_verify_function;
drop function ora12c_verify_function;
drop function verify_function_11G;
drop function verify_function;
drop function ora_complexity_check;
drop function ora_string_distance;

Rem *************************************************************************
Rem END bug#17543726 : drop STIG compliant profile
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug#22552142 : drop STIG compliant function
Rem *************************************************************************

drop function ora12c_stig_verify_function;

Rem *************************************************************************
Rem END bug#22552142 : drop STIG compliant function
Rem *************************************************************************

Rem ====================================================================
Rem BEGIN changes for PDB_ALERT$
Rem ====================================================================
drop index i_pdb_alert2;

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  /* 19229101: downgrade to 12.1.0.1 */
  if previous_version < '12.1.0.2' then
     delete from pdb_alert$ where cause#>57;
     commit;
  /* downgrade to 12.1.0.2 */
  elsif previous_version = '12.1.0.2' then
     delete from pdb_alert$ where cause#>76;
     commit;
  END IF;
END;
/

alter table pdb_alert$ modify (name varchar2(30));

Rem ====================================================================
Rem End changes for PDB_ALERT$
Rem ===================================================================

Rem =======================================================================
Rem  Begin changes for AQ SYS.AQ$_QUEUE_PARAMS
Rem =======================================================================

truncate table SYS.AQ$_QUEUE_PARAMS
/

Rem =======================================================================
Rem  End changes for AQ SYS.AQ$_QUEUE_PARAMS
Rem =======================================================================

Rem =======================================================================
Rem  Begin changes for AQ SYS.AQ$_SHARD_MAP table
Rem =======================================================================

truncate table sys.aq$_shard_map
/

Rem =======================================================================
Rem  End changes for AQ SYS.AQ$_SHARD_MAP
Rem =======================================================================

Rem =======================================================================
Rem  Begin changes for AQ SYS.*_PARTITION_MAP tables & *_pmap_* types.
Rem =======================================================================

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  
  BEGIN
    execute immediate 'update sys.aq$_queue_partition_map set instance = instance*1000 where bitand(part_properties,1)=1';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column part_properties';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column bucket_timestamp';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column bucket_width';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column bucket_id';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column min_delv_time';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column min_delv_time_sn';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column min_delv_time_scn';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column spare1';
    execute immediate 'alter table sys.aq$_queue_partition_map drop column spare2';

    execute immediate 'update sys.aq$_dequeue_log_partition_map set instance = instance*1000 where bitand(part_properties,1)=1';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map rename column rowmarker TO flag';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column part_properties';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column min_sub_delv_time';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column min_sub_delv_time_sn';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column min_delv_time_enq_scn';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column min_sub_delv_time_deq_scn';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column spare1';
    execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column spare2';

    execute immediate 'DROP TYPE sys.sh$qtab_pmap_list';
    execute immediate 'DROP TYPE BODY sys.sh$qtab_pmap';
    execute immediate 'DROP TYPE sys.sh$qtab_pmap';
    execute immediate 'DROP TYPE sys.sh$deq_pmap_list';
    execute immediate 'DROP TYPE BODY sh$deq_pmap';
    execute immediate 'DROP TYPE sh$deq_pmap';

  exception when others then
    if sqlcode in (-904) then null;
    end if;
  end;

  if previous_version < '12.1.0.2.0' then
    BEGIN
      execute immediate 'alter table sys.aq$_queue_partition_map drop column unbound_idx';
      execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column subshard';
      execute immediate 'alter table sys.aq$_dequeue_log_partition_map drop column unbound_idx';
      commit;

        exception when others then
      if sqlcode in (-904) then null;
      end if;
    end;

  END IF;
END;
/

update system.aq$_queues set base_queue = NULL;
commit;
alter table SYS.AQ$_QUEUE_SHARDS drop(base_queue);
alter table SYS.AQ$_QUEUE_SHARDS drop(delay_shard);
truncate table SYS.AQ$_E_QUEUE_PARTITION_MAP;

alter table sys.reg$ modify (subscription_name varchar2(128));
alter table sys.aq$_subscriber_table modify (name VARCHAR2(30));
alter table SYSTEM.AQ$_Internet_Agents modify (agent_name VARCHAR2(30));
alter table SYSTEM.AQ$_Internet_Agent_Privs modify (agent_name VARCHAR2(30));
alter table SYS.AQ$_QUEUE_PARTITION_MAP modify(partname VARCHAR2(30));
alter table SYS.AQ$_DEQUEUE_LOG_PARTITION_MAP modify(partname VARCHAR2(30));
alter table SYS.AQ$_DURABLE_SUBS modify(schema VARCHAR2(30),
                                        queue_name VARCHAR2(30),
                                        rule_name VARCHAR2(30),
                                        trans_owner VARCHAR2(30),
                                        trans_name VARCHAR2(30));
alter table sys.rec_var$ modify(var_mthd_func varchar2(228));
alter table system.aq$_schedules modify(destination varchar2(128));
alter table sys.aq$_schedules modify(destination varchar2(128));
drop type sys.sh$shard_meta_list;
drop type body sys.sh$shard_meta;
drop type sys.sh$shard_meta force;
drop type sys.sh$sub_meta_list;
drop type body sys.sh$sub_meta;
drop type sys.sh$sub_meta force;

drop package dbms_master_table;

drop package body sys.dbms_aqadm_var;
drop package sys.dbms_aqadm_var;
drop public synonym dbms_aqadm_var;

Rem =======================================================================
Rem  End changes for AQ *_PARTITION_MAP tables & *_pmap_* types.
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for child subscribers
Rem ====================================================================

alter table SYS.AQ$_DURABLE_SUBS drop column parent_id;

drop type sys.sh$sub_meta force;

Rem =======================================================================
Rem  End changes for child subscribers
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for sys.reg$ table.
Rem ====================================================================

update sys.reg$ set ntfn_subscriber = NULL;

Rem =======================================================================
Rem  End changes for sys.reg$ table.
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_remote_dequeue_affinity
Rem ====================================================================

drop public synonym gv$aq_remote_dequeue_affinity;
drop view gv_$aq_remote_dequeue_affinity;
drop public synonym v$aq_remote_dequeue_affinity;
drop view v_$aq_remote_dequeue_affinity;

Rem =======================================================================
Rem  End changes for (g)v$aq_remote_dequeue_affinity
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_message_cache_stat
Rem ====================================================================

drop public synonym gv$aq_message_cache_stat;
drop view gv_$aq_message_cache_stat;
drop public synonym v$aq_message_cache_stat;
drop view v_$aq_message_cache_stat;

Rem =======================================================================
Rem  End changes for (g)v$aq_message_cache_stat
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_cached_subshards
Rem ====================================================================

drop public synonym gv$aq_cached_subshards;
drop view gv_$aq_cached_subshards;
drop public synonym v$aq_cached_subshards;
drop view v_$aq_cached_subshards;

Rem =======================================================================
Rem  End changes for (g)v$aq_cached_subshards
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_uncached_subshards
Rem ====================================================================

drop public synonym gv$aq_uncached_subshards;
drop view gv_$aq_uncached_subshards;
drop public synonym v$aq_uncached_subshards;
drop view v_$aq_uncached_subshards;

Rem =======================================================================
Rem  End changes for (g)v$aq_uncached_subshards
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_inactive_subshards
Rem ====================================================================

drop public synonym gv$aq_inactive_subshards;
drop view gv_$aq_inactive_subshards;
drop public synonym v$aq_inactive_subshards;
drop view v_$aq_inactive_subshards;

Rem =======================================================================
Rem  End changes for (g)v$aq_inactive_subshards
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_message_cache_advice
Rem ====================================================================

drop public synonym gv$aq_message_cache_advice;
drop view gv_$aq_message_cache_advice;
drop public synonym v$aq_message_cache_advice;
drop view v_$aq_message_cache_advice;

Rem =======================================================================
Rem  End changes for (g)v$aq_message_cache_advice
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for (g)v$aq_sharded_subscriber_stat
Rem ====================================================================

drop public synonym gv$aq_sharded_subscriber_stat;
drop view gv_$aq_sharded_subscriber_stat;
drop public synonym v$aq_sharded_subscriber_stat;
drop view v_$aq_sharded_subscriber_stat;

Rem =======================================================================
Rem  End changes for (g)v$aq_sharded_subscriber_stat
Rem =======================================================================

Rem ====================================================================
Rem Begin changes for Bug 17621089: drop dbms_export_extension_i
Rem ====================================================================

DROP PACKAGE sys.dbms_export_extension_i;

Rem ====================================================================
Rem End changes for Bug 17621089: drop dbms_export_extension_i
Rem ====================================================================

Rem =======================================================================
Rem  Changes for Database Workload Capture and Replay
@@e1201000_wrr.sql
Rem =======================================================================

Rem =========================================================================
Rem BEGIN proj 47829 - delete READ obj priv and READ ANY TABLE sys priv
Rem =========================================================================

declare
  cursor c1 is
    select oa1.obj#, oa1.grantor#, oa1.grantee#, oa1.col#
    from sys.objauth$ oa1, sys.objauth$ oa2
    where oa1.obj# = oa2.obj#
    and oa1.grantor# = oa2.grantor#
    and oa1.grantee# = oa2.grantee#
    and (oa1.col# = oa2.col# or (oa1.col# is null and oa2.col# is null))
    and oa1.privilege# != oa2.privilege#
    and oa1.privilege# = 17
    and oa2.privilege# = 9;
  priv_record  c1%rowtype;
  prev_version varchar2(30);
begin
  select prv_version into prev_version from registry$ where cid = 'CATPROC';
  
  if prev_version < '12.1.0.2' then
    -- update/delete READ object privilege from objauth$
    open c1;
    loop
      fetch c1 into priv_record;
      exit when c1%NOTFOUND;
      delete from sys.objauth$ oa
        where oa.obj# = priv_record.obj#
        and oa.obj# not in (select obj# from sys.obj$ where type# = 23)
        and oa.grantor# = priv_record.grantor#
        and oa.grantee# = priv_record.grantee#
        and (oa.col# = priv_record.col# or oa.col# is null)
        and oa.privilege# = 17;
      commit;
    end loop;
    close c1;
    update sys.objauth$ oa set oa.privilege# = 9 where oa.privilege# = 17
      and oa.obj# not in (select obj# from sys.obj$ where type# = 23);
    commit;

    -- update/delete READ ANY TABLE privilege from sysauth$
    update sys.sysauth$ set privilege# = -47 where privilege# = -397
    and grantee# not in (select sa1.grantee# from sys.sysauth$ sa1
                         where sa1.privilege# = -47);
    delete from sys.sysauth$ where privilege# = -397;
    commit;

    -- delete READ ANY TABLE option from audit$
    delete from sys.audit$ where option# = 397;
    commit;

    -- delete READ ANY TABLE privilege from stmt_audit_option_map
    delete from sys.stmt_audit_option_map where option# = 397;
    commit;

    -- delete READ ANY TABLE privilege from system_priv_map
    delete from sys.system_privilege_map where privilege = -397;
    commit;

    -- delete from aud_policy$
    delete from aud_policy$ where syspriv = 'READ ANY TABLE';
    commit;

    -- delete from objpriv$
    delete from objpriv$ where privilege# = 17;
    commit;

    -- delete from adminauth$
    delete from adminauth$ where syspriv = 397;
    commit;  
  end if;
end;
/

Rem =========================================================================
Rem END proj 47829 changes
Rem =========================================================================

Rem =========================================================================
Rem Begin ADO changes
Rem =========================================================================

alter table sys.ilm_executiondetails$ drop constraint fk_execdet;

alter table sys.ilm_results$ drop constraint fk_res;

alter table sys.ilm_result_stat$ drop constraint fk_resst;
 
alter table sys.ilm_dependant_obj$ drop constraint fk_depobj;

alter table sys.ilm_dependant_obj$ drop constraint fk_depobjjobn;

alter table sys.ilm_dep_executiondetails$ drop constraint fk_depdet;

alter table sys.ilm_dep_executiondetails$ drop constraint fk_depdetjobn;

alter table sys.ilm_results$ drop constraint pk_res;

alter table sys.ilm_execution$ drop constraint pk_taskid;

Rem Index on execution_id column of ilm_execution$. This index is replaced by
Rem the primark key constraint pk_taskid in later versions.

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';
  /* 22639561: Changes only apply from downgrade to 12.1.0.1.0 */
  IF previous_version < '12.1.0.2' THEN
     execute immediate 'create index i_ilmexec_execid on ilm_execution$(execution_id) tablespace SYSAUX';

  /* Rem Index on ilm_results$. This index is replaced by pk_res in later */
  /* versions. */
     execute immediate ' create index i_ilm_results$ on ilm_results$(jobname) tablespace SYSAUX';
  END IF;
END;
/

Rem =========================================================================
Rem End ADO changes
Rem =========================================================================

Rem *************************************************************************
Rem Begin Bug 17637420: Clear tracking columns in SQL and error translation
Rem                     tables
Rem *************************************************************************

update sqltxl_sql$ set rtime = null, cinfo = null, module = null, action = null,
  puser# = null, pschema# = null, comment$ = null;


update sqltxl_err$ set rtime = null, comment$ = null;

commit;


Rem *************************************************************************
Rem End Bug 17637420
Rem *************************************************************************

Rem =======================================================================
Rem Bug 18165071 - Drop DBA_LOCK associated objects (catblock.sql) 
Rem =======================================================================
drop view DBA_LOCK;
drop public synonym DBA_LOCK;
drop public synonym DBA_LOCKS;
drop view DBA_LOCK_INTERNAL;
drop public synonym DBA_LOCK_INTERNAL;
drop view DBA_WAITERS;
drop public synonym DBA_WAITERS;
drop view DBA_BLOCKERS;
drop public synonym DBA_BLOCKERS;

drop view sys.CDB_WAITERS;
drop public synonym CDB_WAITERS;

drop view sys.CDB_BLOCKERS;
drop public synonym CDB_BLOCKERS;

drop view sys.CDB_LOCK;
drop public synonym CDB_LOCK;

drop view sys.CDB_LOCK_INTERNAL;
drop public synonym CDB_LOCK_INTERNAL;


Rem =======================================================================
Rem BEGIN Changes for [G]V$PROCESS_PRIORITY_DATA
Rem =======================================================================

drop public synonym gv$process_priority_data;
drop public synonym v$process_priority_data;
drop view gv_$process_priority_data;
drop view v_$process_priority_data;

Rem =======================================================================
Rem END Changes for [G]V$CELL_CONFIG_INFO
Rem =======================================================================

Rem =======================================================================
Rem BEGIN dbms_qopatch 
Rem =======================================================================
DROP PACKAGE BODY dbms_qopatch;
DROP PACKAGE dbms_qopatch;

Rem =======================================================================
Rem BEGIN Changes for [G]V$QPX_INVENTORY
Rem =======================================================================
drop public synonym gv$qpx_inventory;
drop public synonym v$qpx_inventory;
drop view gv_$qpx_inventory;
drop view v_$qpx_inventory;

Rem =======================================================================
Rem END Changes for [G]V$QPX_INVENTORY
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$DATAGUARD_PROCESS
Rem =======================================================================

drop public synonym gv$dataguard_process;
drop public synonym v$dataguard_process;
drop view gv_$dataguard_process;
drop view v_$dataguard_process;

Rem =======================================================================
Rem END Changes for [G]V$DATAGUARD_PROCESS
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for [G]V$SYSTEM_RESET_PARAMETER[2]
Rem =======================================================================
drop public synonym gv$system_reset_parameter;
drop public synonym gv$system_reset_parameter2;
drop public synonym v$system_reset_parameter;
drop public synonym v$system_reset_parameter2;
drop view gv_$system_reset_parameter;
drop view gv_$system_reset_parameter2;
drop view v_$system_reset_parameter;
drop view v_$system_reset_parameter2;

Rem =======================================================================
Rem END Changes for [G]V$SYSTEM_RESET_PARAMETER[2]
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for REGISTRY objects
Rem =======================================================================

drop view dba_registry_error;
drop public synonym dba_registry_error;

drop view cdb_registry_error;
drop public synonym cdb_registry_error;

Rem =======================================================================
Rem END changes for REGISTRY objects
Rem =======================================================================

Rem *************************************************************************
Rem Begin Bug 17526652 17526621 revoke select_catalog_role
Rem *************************************************************************

begin
  execute immediate 'grant select on cdb_keepsizes to select_catalog_role';
  execute immediate 'grant select on cdb_analyze_objects to select_catalog_role';
exception when others then
  if sqlcode in (-1927, -942) then null;
  else raise;
  end if;
end;
/

Rem *************************************************************************
Rem End Bug 17526652 17526621
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj 47082: External tables
Rem *************************************************************************
-- Remove the AccessParmMod arg. Do this before dropping and recreating the
-- ORACLE LOADER and ORACLE DATAPUMP methods below. Drop the TYPE completely
-- and create the old version(rather than drop the attribute),to avoid errors 
-- when later recreating dependant types
drop type sys.ODCIExtTableInfo force;
CREATE OR REPLACE TYPE ODCIExtTableInfo AS object
(
  TableSchema      VARCHAR2(128),
  TableName        VARCHAR2(128),
  RefCols          ODCIColInfoList2,
  AccessParmClob   CLOB,
  AccessParmBlob   BLOB,
  Locations        ODCIArgDescList,
  Directories      ODCIArgDescList,
  DefaultDirectory VARCHAR2(128),
  DriverType       VARCHAR2(128),
  OpCode           NUMBER,
  AgentNum         NUMBER,
  GranuleSize      NUMBER,
  Flag             NUMBER,
  SamplePercent    NUMBER,
  MaxDoP           NUMBER,
  SharedBuf        RAW(2000),
  MTableName       VARCHAR2(128),
  MTableSchema     VARCHAR2(128),
  TableObjNo       NUMBER
);
/

Rem ********************************************************************
Rem Begin Bug 23604553 Drop types ORACLE_LOADER and ORACLE_DATAPUMP
Rem ********************************************************************

DROP TYPE sys.oracle_loader;
DROP TYPE sys.oracle_datapump;

Rem ********************************************************************
Rem End Bug 23604553
Rem ********************************************************************

Rem ********************************************************************
Rem Begin sys.ORACLE_[BIGSQL,HDFS,HIVE]
Rem   Drop these new external table types which did not exist
Rem   prior to 12.1.0.1
Rem ********************************************************************

drop type sys.oracle_hive force;
drop type sys.oracle_hdfs force;
drop type sys.oracle_bigdata force;

Rem ********************************************************************
Rem End sys.ORACLE_[BIGSQL,HDFS,HIVE]
Rem ********************************************************************

Rem =======================================================================
Rem BEGIN Changes for pdb_sync$
Rem =======================================================================
truncate table pdb_sync_stmt$;

declare
  prev_version varchar2(30);
begin
  select prv_version into prev_version from registry$
   where cid = 'CATPROC';

   if prev_version < '12.1.0.2' then
     execute immediate 'truncate table pdb_sync$';
   else 
     execute immediate 'update pdb_sync$ set sqlid = NULL, appid# = NULL,
                        ver# = NULL, patch# = NULL, app_status = NULL,
                        sessserial# = NULL';
   end if;
end;
/

Rem =======================================================================
Rem  END Changes for pdb_sync$
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for pdb_inv_type$
Rem =======================================================================
truncate table pdb_inv_type$;
Rem =======================================================================
Rem  END Changes for pdb_inv_type$
Rem =======================================================================

Rem *************************************************************************
Rem 17971391: downgrade size of opbinding$.functionname
Rem *************************************************************************

alter table sys.opbinding$ modify functionname varchar2(92);

Rem *************************************************************************
Rem End 17971391
Rem *************************************************************************

Rem *************************************************************************
Rem 17537632: VALUE column for System table RECO_SCRIPT_PARAMS$ need to change
Rem           from CLOB datatype to varchar2(4000).
Rem           And for this during down-grade process, any existing records in
Rem           VALUE column will be copied to new column of varchar2(4000) type
Rem      NOTE:Data truncation possible as CLOB could be holding data which is
Rem           greater than 4K in size.
Rem *************************************************************************
ALTER TABLE reco_script_params$ ADD (TEMP varchar2(4000));
UPDATE reco_script_params$ SET TEMP = substr(VALUE, 1, 4000);
ALTER TABLE reco_script_params$ DROP COLUMN VALUE;
ALTER TABLE reco_script_params$ RENAME COLUMN TEMP to VALUE;

Rem *************************************************************************
Rem End 17537632
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Changes for [G]V$[CON_]EVENT_HISTOGRAM_MICRO
Rem =======================================================================

drop public synonym gv$event_histogram_micro;
drop view gv_$event_histogram_micro;
drop public synonym v$event_histogram_micro;
drop view v_$event_histogram_micro;

drop public synonym gv$con_event_histogram_micro;
drop view gv_$con_event_histogram_micro;
drop public synonym v$con_event_histogram_micro;
drop view v_$con_event_histogram_micro;

Rem =======================================================================
Rem END Changes for [G]V$[CON_]EVENT_HISTOGRAM_MICRO
Rem =======================================================================  

Rem *************************************************************************
Rem  FBA Long identifers for 12.1.0.2
Rem *************************************************************************
Rem ================================================================
Rem ==  Bug 7971239: Decrease size of columns for  downgrade      ==
Rem ==  long identifiers in FBA dictionary tables                 ==
Rem ================================================================

update SYS_FBA_FA set ownername = substr(ownername,1,30);
update SYS_FBA_TRACKEDTABLES set objname = substr(objname,1,30),
       ownername = substr(ownername,1,30);
update SYS_FBA_CONTEXT set namespace = substr(namespace,1,30),
       parameter = substr(parameter, 1,30);
update SYS_FBA_CONTEXT_LIST set namespace = substr(namespace,1,30),
       parameter = substr(parameter, 1,30);
commit;
alter table SYS_FBA_FA modify (ownername varchar2(30));
alter table SYS_FBA_TRACKEDTABLES modify 
          (objname varchar2(30), ownername varchar2(30));
alter table SYS_FBA_CONTEXT modify
          (namespace varchar2(30), parameter varchar2(30));
alter table SYS_FBA_CONTEXT_LIST modify
          (namespace varchar2(30), parameter varchar2(30));

Rem *************************************************************************
Rem End FBA dictionary support for long identifers
Rem *************************************************************************

Rem ========================================================================
Rem END FBA Changes
Rem =========================================================================

Rem *************************************************************************
Rem 18157062: downgrade drop the column max_txn_think_time from cpool$
Rem *************************************************************************

ALTER TABLE cpool$ DROP COLUMN max_txn_think_time;

Rem *************************************************************************
Rem End 18157062
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 17665104 add patch UID into opatch_inst_patch
Rem *************************************************************************
Rem Drop the column if the version is below 12.1.0.2

declare
  prev_version varchar2(30);
begin
  select prv_version into prev_version from registry$
   where cid = 'CATPROC';

   if prev_version < '12.1.0.2' then
     execute immediate 'alter table opatch_inst_patch drop column patchUId';
   else 
     execute immediate 'alter table opatch_inst_patch modify patchUId varchar(20)';
   end if;
  
   execute immediate 'drop type qopatch_list force';
   execute immediate 'truncate table opatch_sql_patches';
end;
/

Rem *************************************************************************
Rem end of 17665104
Rem *************************************************************************

Rem *************************************************************************
Rem long identifier support for QI
Rem *************************************************************************

alter table opatch_inst_job modify node_name varchar2(60);
alter table opatch_inst_job modify inst_name varchar2(60);

alter table opatch_inst_patch modify nodeName varchar2(60);
alter table opatch_inst_patch modify patchNum varchar2(15);


Rem 20772435: All registry$sqlpatch changes are now in the XDB friendly
Rem downgrade scripts

Rem *************************************************************************
Rem bug#18469064 change session_key type to varchar2 in reg$
Rem bug#25337332 avoid DROP COLUMN signature mismatches; modify in place
Rem *************************************************************************

ALTER TABLE reg$ ADD (TEMP varchar2(1024));
UPDATE reg$ SET TEMP = utl_raw.cast_to_varchar2(session_key);
UPDATE reg$ SET session_key = NULL;
COMMIT;
ALTER TABLE reg$ MODIFY session_key VARCHAR2(1024);
UPDATE reg$ SET session_key = temp;
COMMIT;
ALTER TABLE reg$ DROP COLUMN temp;

Rem ********************************************************************
Rem End  18469064
Rem ********************************************************************

Rem =======================================================================
Rem Begin Changes for Oracle BigData Agent
Rem =======================================================================

drop package body sys.kubsagt;
drop package sys.kubsagt;
drop library kubsagt_lib;

Rem =======================================================================
Rem End Changes for Oracle BigData Agent
Rem =======================================================================

Rem =======================================================================
Rem BEGIN JSON views
Rem =======================================================================
drop view ALL_JSON_COLUMNS;
drop view USER_JSON_COLUMNS;
drop view CDB_JSON_COLUMNS;
drop view DBA_JSON_COLUMNS;
drop view INT$DBA_JSON_COLUMNS;
drop view INT$DBA_JSON_VIEW_COLUMNS;
drop view INT$DBA_JSON_TABLE_COLUMNS;

drop public synonym ALL_JSON_COLUMNS;
drop public synonym USER_JSON_COLUMNS;
drop public synonym CDB_JSON_COLUMNS;
drop public synonym DBA_JSON_COLUMNS;
Rem =======================================================================
Rem  END JSON views
Rem =======================================================================

Rem *************************************************************************
Rem Begin Bug 18459020 
Rem *************************************************************************
drop public synonym v$DIAG_DFW_PATCH_CAPTURE;
drop view v_$DIAG_DFW_PATCH_CAPTURE;
drop public synonym v$DIAG_DFW_PATCH_ITEM;
drop view v_$DIAG_DFW_PATCH_ITEM;
Rem *************************************************************************
Rem end of 18459020
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 22548290 
Rem *************************************************************************
drop public synonym v$DIAG_LOG_EXT;
drop view v_$DIAG_LOG_EXT;
Rem *************************************************************************
Rem end of Bug 22548290
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 18543824
Rem *************************************************************************
drop index i_ilmresults_status;
Rem *************************************************************************
Rem end of 18543824
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN bug 18417322: set CDB_LOCAL_ADMINAUTH$.flags to 0
Rem =======================================================================

update cdb_local_adminauth$ set flags = 0
/

commit
/
  
Rem =======================================================================
Rem  END bug 18417322
Rem =======================================================================

Rem ********************************************************************
Rem Proj 46885 - admin user password management - BEGIN
Rem   Update 12.2 new columns of sys.cdb_local_adminauth$ back to their
Rem   default values during the downgrade process.
Rem ********************************************************************
update sys.cdb_local_adminauth$ set lcount = 0;       /* Failed Login Count */
update sys.cdb_local_adminauth$ set astatus = 0;   /* Account Status = OPEN */
update sys.cdb_local_adminauth$ set ltime = NULL;    /* Clear the lock date */
update sys.cdb_local_adminauth$ set lsltime = NULL;  /* Last Successful Logon
                                                                       Time */
update sys.cdb_local_adminauth$ set passwd_profile=NULL;/* Password Profile */
update sys.cdb_local_adminauth$ set passwd_limit=NULL;    /* Profile Limits */
update sys.cdb_local_adminauth$ set ext_username=NULL; /* External username */

commit;

Rem *************************************************************************
Rem Proj 46885 - admin user password management - END
Rem *************************************************************************

Rem *************************************************************************
Rem bug 17446096: delete rows from adminauth$ in a non-CDB.
Rem *************************************************************************
delete from adminauth$ where sys_context('userenv', 'con_id') = 0
/

commit
/

Rem ********************************************************************
Rem End  17446096
Rem ********************************************************************


Rem ********************************************************************
Rem LRG 19083153: update col$ to clear KQLDCOP2_HLOB bit, which is
Rem new in 12.2. Having this bit set can cause numeric overflow in
Rem lower versions during reload.
Rem ********************************************************************

update col$ set property=property-power(2,32)*2097152
where bitand(property, power(2,32)*2097152)=power(2,32)*2097152;

Rem ********************************************************************
Rem LRG 19083153: update col$ to clear KQLDCOP2_HLOB bit.
Rem ********************************************************************


Rem ********************************************************************
Rem Bug 20683085: update col$ to clear KQLDCOP2_XSLB bit, which is 
Rem new in 12.2. Having this bit set can cause numeric overflow in 
Rem lower versions during reload.
Rem ********************************************************************

update col$ set property=property-power(2,32)*4194304
where bitand(property, power(2,32)*4194304)=power(2,32)*4194304;

Rem ********************************************************************
Rem Bug 20683085: update col$ to clear KQLDCOP2_XSLB bit.
Rem ********************************************************************

Rem *************************************************************************
Rem SYSRAC (project 46816) changes - BEGIN
Rem *************************************************************************

drop user sysrac cascade;
delete from SYSTEM_PRIVILEGE_MAP where name = 'SYSRAC';
delete from STMT_AUDIT_OPTION_MAP where name = 'SYSRAC';

Rem *************************************************************************
Rem SYSRAC (project 46816) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Project 46885 : Inactive Account Time Password Profile Parameter - BEGIN
Rem *************************************************************************

delete from resource_map where name='INACTIVE_ACCOUNT_TIME';
delete from profile$ where RESOURCE#=7 and TYPE#=1;

commit
/

Rem *************************************************************************
Rem Project 46885 : Inactive Account Time Password Profile Parameter - END
Rem *************************************************************************

Rem *************************************************************************
Rem bug 18756350: delete dbms_feature_ba_owner procedure.
Rem *************************************************************************
drop procedure dbms_feature_ba_owner;

Rem ********************************************************************
Rem End  18756350
Rem ********************************************************************

Rem =======================================================================
Rem BEGIN Changes for [G]V$ONLINE_REDEF
Rem =======================================================================

drop public synonym gv$online_redef;
drop view gv_$online_redef;
drop public synonym v$online_redef;
drop view v_$online_redef;

Rem =======================================================================
Rem END Changes for [G]V$ONLINE_REDEF
Rem =======================================================================

Rem =======================================================================
Rem Begin Online Redefinition 12.2 Proj#39358 restartability changes
Rem =======================================================================

update redef_status$ set err_no = 0, err_txt = NULL, action = NULL;

Rem =======================================================================
Rem End Online Redefinition 12.2 Proj#39358  restartability changes
Rem =======================================================================
  
Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************

-- Unfortunately, 12.1.0.1 code uses an insert without parameters. This
-- means that the old code cannot tolerate extra columns. So, these
-- columns need to be dropped rather than simply cleared for the
-- downgrade to work correctly. The server code has been modified so
-- that it tolerates the lack of columns, so it is safe to drop them.
-- 
-- LRG 12966203: only drop the columns when going to 12.1.0.1 or lower.
-- Bug 24422028: drop session_pga_limit even going to 12.1.0.2
--
alter table resource_plan_directive$ drop column session_pga_limit;

declare
  prev_version varchar2(30);
begin
  select prv_version into prev_version from registry$
   where cid = 'CATPROC';

  if prev_version < '12.1.0.2' then
    execute immediate 'alter table cdb_resource_plan_directive$ ' ||
                      'drop column memory_min';
    execute immediate 'alter table cdb_resource_plan_directive$ ' ||
                      'drop column memory_limit';
    execute immediate 'alter table cdb_resource_plan_directive$ ' ||
                      'drop column directive_type';
   end if;
end;
/

drop public synonym AWR_PDB_CHANNEL_WAITS;
drop view AWR_PDB_CHANNEL_WAITS;

drop public synonym AWR_ROOT_CHANNEL_WAITS;
drop view AWR_ROOT_CHANNEL_WAITS; 

drop public synonym DBA_HIST_CHANNEL_WAITS;
drop view DBA_HIST_CHANNEL_WAITS;

truncate table WRH$_CHANNEL_WAITS;

drop public synonym v$rsrc_pdb;
drop view v_$rsrc_pdb;

drop public synonym gv$rsrc_pdb;
drop view gv_$rsrc_pdb;

drop public synonym v$rsrc_pdb_history;
drop view v_$rsrc_pdb_history;

drop public synonym gv$rsrc_pdb_history;
drop view gv_$rsrc_pdb_history;

drop public synonym v$rsrcpdbmetric;
drop view v_$rsrcpdbmetric;

drop public synonym v$rsrcpdbmetric_history;
drop view v_$rsrcpdbmetric_history;

drop public synonym gv$rsrcpdbmetric;
drop view gv_$rsrcpdbmetric;

drop public synonym gv$rsrcpdbmetric_history;
drop view gv_$rsrcpdbmetric_history;

drop public synonym DBA_HIST_RSRC_METRIC;
drop view DBA_HIST_RSRC_METRIC;

drop public synonym AWR_ROOT_RSRC_METRIC;
drop view AWR_ROOT_RSRC_METRIC;

drop public synonym AWR_PDB_RSRC_METRIC;
drop view AWR_PDB_RSRC_METRIC;

drop public synonym DBA_HIST_RSRC_PDB_METRIC;
drop view DBA_HIST_RSRC_PDB_METRIC;

drop public synonym AWR_ROOT_RSRC_PDB_METRIC;
drop view AWR_ROOT_RSRC_PDB_METRIC;

drop public synonym AWR_PDB_RSRC_PDB_METRIC;
drop view AWR_PDB_RSRC_PDB_METRIC;

truncate table WRH$_RSRC_METRIC;
truncate table WRH$_RSRC_PDB_METRIC;
truncate table WRH$_RECOVERY_PROGRESS;

update WRH$_RSRC_CONSUMER_GROUP set switches_in_io_logical    = 0;
update WRH$_RSRC_CONSUMER_GROUP set switches_out_io_logical   = 0;
update WRH$_RSRC_CONSUMER_GROUP set switches_in_elapsed_time  = 0;
update WRH$_RSRC_CONSUMER_GROUP set switches_out_elapsed_time = 0;
update WRH$_RSRC_CONSUMER_GROUP set pga_limit_sessions_killed = 0;

update WRH$_RSRC_PLAN set instance_caging = NULL;

delete from resource_plan$ where status = 'ACTIVE_FLAT';
delete from resource_plan_directive$ where status = 'ACTIVE_FLAT';

commit;

Rem *************************************************************************
Rem Resource Manager related changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem : polymorphic TABLE Functions
Rem *************************************************************************
update  procedureinfo$ SET properties2=0;
commit;

DROP PACKAGE DBMS_TF;
drop public synonym dbms_tf;

Rem ********************************************************************
Rem End  polymorphic TABLE Functions
Rem ********************************************************************

Rem =======================================================================
Rem BEGIN Changes for [G]V$CLEANUP_PROCESS
Rem =======================================================================

drop public synonym gv$cleanup_process;
drop view gv_$cleanup_process;
drop public synonym v$cleanup_process;
drop view v_$cleanup_process;

Rem =======================================================================
Rem END Changes for [G]V$CLEANUP_PROCESS
Rem =======================================================================

Rem ========================================================================
Rem BEGIN scheduler Changes
Rem =========================================================================

alter table scheduler$_notification drop column notification_owner;

drop index sys.i_scheduler_notification1;
CREATE INDEX sys.i_scheduler_notification1
  ON scheduler$_notification ( owner, job_name, job_subname);
drop index sys.i_scheduler_notification2;
CREATE INDEX sys.i_scheduler_notification2
  ON scheduler$_notification ( owner, job_name, job_subname, event_flag);

Rem ============== Revoke privileges from scheduler views ==================

REVOKE READ ON user_scheduler_programs FROM public
REVOKE READ ON all_scheduler_programs FROM public
REVOKE READ ON user_scheduler_dests FROM public
REVOKE READ ON all_scheduler_dests FROM public
REVOKE READ ON all_scheduler_external_dests FROM public
REVOKE READ ON user_scheduler_db_dests FROM public
REVOKE READ ON all_scheduler_db_dests FROM public
REVOKE READ ON user_scheduler_job_dests FROM public
REVOKE READ ON all_scheduler_job_dests FROM public
REVOKE READ ON user_scheduler_jobs FROM public
REVOKE READ ON all_scheduler_jobs FROM public
REVOKE READ ON all_scheduler_job_classes FROM public
REVOKE READ ON all_scheduler_windows FROM public
REVOKE READ ON user_scheduler_program_args FROM public
REVOKE READ ON all_scheduler_program_args FROM public
REVOKE READ ON user_scheduler_job_args FROM public
REVOKE READ ON all_scheduler_job_args FROM public
REVOKE READ ON user_scheduler_job_log FROM public
REVOKE READ ON user_scheduler_job_run_details FROM public
REVOKE READ ON all_scheduler_job_log FROM public
REVOKE READ ON all_scheduler_job_run_details FROM public
REVOKE READ ON all_scheduler_window_log FROM public
REVOKE READ ON all_scheduler_window_details FROM public
REVOKE READ ON all_scheduler_window_groups FROM public
REVOKE READ ON all_scheduler_wingroup_members FROM public
REVOKE READ ON user_scheduler_group_members FROM public
REVOKE READ ON all_scheduler_group_members FROM public
REVOKE READ ON user_scheduler_groups FROM public
REVOKE READ ON all_scheduler_groups FROM public
REVOKE READ ON user_scheduler_schedules FROM public
REVOKE READ ON all_scheduler_schedules FROM public
REVOKE READ ON all_scheduler_remote_jobstate FROM public
REVOKE READ ON user_scheduler_remote_jobstate FROM public
REVOKE READ ON all_scheduler_global_attribute FROM public
REVOKE READ ON user_scheduler_chains FROM public
REVOKE READ ON all_scheduler_chains FROM public
REVOKE READ ON user_scheduler_chain_rules FROM public
REVOKE READ ON all_scheduler_chain_rules FROM public
REVOKE READ ON user_scheduler_chain_steps FROM public
REVOKE READ ON all_scheduler_chain_steps FROM public
REVOKE READ ON user_scheduler_running_chains FROM public
REVOKE READ ON all_scheduler_running_chains FROM public
REVOKE READ ON user_scheduler_credentials FROM public
REVOKE READ ON all_scheduler_credentials FROM public
REVOKE READ ON user_scheduler_file_watchers FROM public
REVOKE READ ON all_scheduler_file_watchers FROM public

truncate table sys.scheduler$_listeneraddresses;

drop procedure SYS.SCHEDULER$NTFY_SVC_METRICS;

Rem ========================================================================
Rem END scheduler Changes
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN Changes to sqlset_row due to new last_exec_start_time column
Rem *************************************************************************
Rem We have added a new column to the type sqlset_row in 12gR2. However this
Rem will be created along with its new constructor in catsqlt.sql. Hence we
Rem just drop it here, so that it will be correctly created in catsqlt.sql

drop type sqlset_row force;
drop public synonym sqlset_row;

Rem bug 22525115 - set last_exec_start_time to null on downgrd
update wri$_sqlset_statistics set last_exec_start_time = null;

Rem *************************************************************************
Rem End Changes to sqlset_row due to new last_exec_start_time column
Rem *************************************************************************
  
Rem =======================================================================
Rem BEGIN Changes for [G]V$CODE_CLAUSE
Rem =======================================================================
drop public synonym gv$CODE_CLAUSE;
drop public synonym v$CODE_CLAUSE;
drop view gv_$CODE_CLAUSE;
drop view v_$CODE_CLAUSE;

Rem =======================================================================
Rem END Changes for [G]V$CODE_CLAUSE
Rem =======================================================================

Rem**************************************************************************
Rem BEGIN Drop all the views related to Hive metastore
Rem**************************************************************************

DROP PUBLIC SYNONYM DBA_HIVE_TABLES;
DROP VIEW DBA_HIVE_TABLES;

DROP PUBLIC SYNONYM CDB_HIVE_TABLES;
DROP VIEW CDB_HIVE_TABLES;

DROP PUBLIC SYNONYM USER_HIVE_TABLES;
DROP VIEW USER_HIVE_TABLES;

DROP PUBLIC SYNONYM ALL_HIVE_TABLES;
DROP VIEW ALL_HIVE_TABLES;

DROP PUBLIC SYNONYM DBA_HIVE_DATABASES;
DROP VIEW DBA_HIVE_DATABASES;

DROP PUBLIC SYNONYM CDB_HIVE_DATABASES;
DROP VIEW CDB_HIVE_DATABASES;

DROP PUBLIC SYNONYM USER_HIVE_DATABASES;
DROP VIEW USER_HIVE_DATABASES;

DROP PUBLIC SYNONYM ALL_HIVE_DATABASES;
DROP VIEW ALL_HIVE_DATABASES;

DROP PUBLIC SYNONYM DBA_HIVE_COLUMNS;
DROP VIEW DBA_HIVE_COLUMNS;

DROP PUBLIC SYNONYM CDB_HIVE_COLUMNS;
DROP VIEW CDB_HIVE_COLUMNS;

DROP PUBLIC SYNONYM USER_HIVE_COLUMNS;
DROP VIEW USER_HIVE_COLUMNS;

DROP PUBLIC SYNONYM ALL_HIVE_COLUMNS;
DROP VIEW ALL_HIVE_COLUMNS;

DROP PUBLIC SYNONYM DBA_HIVE_TAB_PARTITIONS;
DROP VIEW DBA_HIVE_TAB_PARTITIONS;

DROP PUBLIC SYNONYM CDB_HIVE_TAB_PARTITIONS;
DROP VIEW CDB_HIVE_TAB_PARTITIONS;

DROP PUBLIC SYNONYM USER_HIVE_TAB_PARTITIONS;
DROP VIEW USER_HIVE_TAB_PARTITIONS;

DROP PUBLIC SYNONYM ALL_HIVE_TAB_PARTITIONS;
DROP VIEW ALL_HIVE_TAB_PARTITIONS;

DROP PUBLIC SYNONYM DBA_HIVE_PART_KEY_COLUMNS;
DROP VIEW DBA_HIVE_PART_KEY_COLUMNS;

DROP PUBLIC SYNONYM CDB_HIVE_PART_KEY_COLUMNS;
DROP VIEW CDB_HIVE_PART_KEY_COLUMNS;

DROP PUBLIC SYNONYM USER_HIVE_PART_KEY_COLUMNS;
DROP VIEW USER_HIVE_PART_KEY_COLUMNS;

DROP PUBLIC SYNONYM ALL_HIVE_PART_KEY_COLUMNS;
DROP VIEW ALL_HIVE_PART_KEY_COLUMNS;

DROP PUBLIC SYNONYM DBA_XT_HIVE_TABLES_VALIDATION;
DROP VIEW DBA_XT_HIVE_TABLES_VALIDATION;

DROP PUBLIC SYNONYM CDB_XT_HIVE_TABLES_VALIDATION;
DROP VIEW CDB_XT_HIVE_TABLES_VALIDATION;

DROP PUBLIC SYNONYM USER_XT_HIVE_TABLES_VALIDATION;
DROP VIEW USER_XT_HIVE_TABLES_VALIDATION;

DROP PUBLIC SYNONYM ALL_XT_HIVE_TABLES_VALIDATION;
DROP VIEW ALL_XT_HIVE_TABLES_VALIDATION;

DROP PACKAGE DBMS_HADOOP_INTERNAL;
DROP PUBLIC SYNONYM DBMS_HADOOP;
DROP LIBRARY DBMSHADOOPLIB;
DROP PACKAGE DBMS_HADOOP;

DROP TYPE HiveMetadata;
DROP TYPE hiveTypeSet;
DROP TYPE hiveType;

Rem**************************************************************************
Rem END Drop all the views related to Hive metastore
Rem**************************************************************************



Rem **************************************************************************
Rem BEGIN Data Redaction downgrade to 12.1
Rem **************************************************************************
Rem
Rem Bug 19142127: drop the REDACTION_COLUMNS_DBMS_ERRLOG view and synonym.
Rem
drop view REDACTION_COLUMNS_DBMS_ERRLOG;
drop public synonym REDACTION_COLUMNS_DBMS_ERRLOG;

Rem Bug 22524193 drop 'REDACTION_EXPRESSIONS' view and public synonym
drop view REDACTION_EXPRESSIONS;
drop public synonym REDACTION_EXPRESSIONS;

Rem **************************************************************************
Rem END   Data Redaction downgrade to 12.1
Rem **************************************************************************

Rem *************************************************************************
Rem BEGIN  Data Redaction - downgrade data dictionary to 12.1
Rem *************************************************************************
Rem
Rem Project #46864: Data Redaction multiple policy support.
Rem The new Data Redaction API can only be used if the compatible
Rem parameter is set to 12.2.  Since we are doing downgrade here, it means
Rem that compatible was not set to 12.2, so the new Data Redaction API was
Rem never invoked, hence only the default object-wide Policy Expression
Rem information in the radm_pe$ table is needed.
Rem Remember that during upgrade, the radm_pe$ table was
Rem populated with a copy of the values from radm$.pexpr.

BEGIN
  FOR cur_rec IN (SELECT rp.pe_pexpr policy_expression,
                         rp.pe_obj#  object_number
                    FROM radm_pe$    rp,
                         radm$       r
                   WHERE rp.pe_obj# = r.obj#
                     AND rp.pe_name is NULL)
  LOOP
    BEGIN
      EXECUTE IMMEDIATE
         'UPDATE sys.radm$ SET pexpr = ' 
         || DBMS_ASSERT.ENQUOTE_LITERAL(cur_rec.policy_expression)
         || ' WHERE obj# = ' 
         || cur_rec.object_number;
    END;
  END LOOP;
END;
/

Rem
Rem Now, after copying the default object-wide Policy Expressions back
Rem from the radm_pe$ to the old radm$ table, we no longer need the
Rem contents of the radm_pe$ table.  So now, symmetrically with what
Rem we did in the upgrade script, we perform the following actions:
Rem
Rem  - drop the radm_mc_pe_number constraint
Rem  - alter the column radm_mc$.pe# to allow NULL
Rem  - set the foreign key radm_mc$.pe# to NULL
Rem  - truncate the radm_pe$ table (delete all rows).
Rem
drop index i_radm_mc3;
alter table sys.radm_mc$ drop constraint radm_mc_pe_number;
alter table sys.radm_mc$ modify pe# NULL;
update sys.radm_mc$ set pe# = null;
update sys.radm_mc$ set regexp_charset = null;
truncate table sys.radm_pe$;
drop index i_radm_pe1;
drop index i_radm_pe2;
drop sequence sys.radm_pe$_seq;
Rem
Rem The column radm$.pexpr must now be altered back to NOT NULL, 
Rem since after downgrade it will be used for storing the
Rem default object-wide Policy Expression, which cannot be NULL.
Rem If anything went wrong with the downgrade script, an
Rem   ORA-02296: cannot enable (SYS.) - null values found
Rem error would be raised here, meaning that the downgrade
Rem script had somehow failed to copy the required default 
Rem object-wide Policy Expression from the radm_pe$ table.
Rem 
alter table sys.radm$ modify pexpr NOT NULL
/
commit;

Rem *************************************************************************
Rem END    Data Redaction - downgrade data dictionary to 12.1
Rem *************************************************************************
  
Rem **************************************************************************
Rem BEGIN Downgrade ilm_concurrency$ to 12.1
Rem **************************************************************************

delete from sys.ilm_concurrency$ where attribute = 4;
commit;

Rem **************************************************************************
Rem END Downgrade ilm_concurrency$ to 12.1
Rem **************************************************************************

Rem **************************************************************************
Rem BEGIN Project 35931: VPD predicate support in audit trail
Rem **************************************************************************
drop package body dbms_audit_util;
drop package dbms_audit_util;
drop library dbms_audit_util_lib;
drop public synonym dbms_audit_util;

Rem **************************************************************************
Rem END Project 35931: VPD predicate support in audit trail
Rem **************************************************************************

Rem *************************************************************************
Rem BEGIN 12.2 Project 47098: Data Mining Framework
Rem BEGIN 12.2 Project 47099: Data Mining Model Partitioning
Rem *************************************************************************

drop view user_mining_model_partitions;
drop view all_mining_model_partitions;
drop view dba_mining_model_partitions;
drop view cdb_mining_model_partitions;
drop view user_mining_model_xforms;
drop view all_mining_model_xforms;
drop view dba_mining_model_xforms;
drop view cdb_mining_model_xforms;
drop view user_mining_model_views;
drop view all_mining_model_views;
drop view dba_mining_model_views;
drop view cdb_mining_model_views;
drop public synonym user_mining_model_partitions;
drop public synonym all_mining_model_partitions;
drop public synonym dba_mining_model_partitions;
drop public synonym cdb_mining_model_partitions;
drop public synonym user_mining_model_xforms;
drop public synonym all_mining_model_xforms;
drop public synonym dba_mining_model_xforms;
drop public synonym cdb_mining_model_xforms;
drop public synonym user_mining_model_views;
drop public synonym all_mining_model_views;
drop public synonym dba_mining_model_views;
drop public synonym cdb_mining_model_views;
delete from audit_actions where action = 242;
drop table modelgttraw$;
truncate table modelxfm$;
truncate table modelpartcol$;
truncate table modelpart$;
alter table model$ drop column properties;
alter table model$ drop column pco;
alter table model$ drop column pseq#;
alter table modeltab$ drop column siz;
drop procedure dm$rqMod_Build;
drop procedure dm$rqMod_Score;
drop procedure dm$rqEvalSerInp;
drop procedure dm$rqCreateDBOBJS;
drop type dm$rqMod_DetailImpl;
drop library DM$RQEXTLIB;
drop public synonym ORA_DM_BUILD;
drop public synonym ORA_DM_BUILD_OROWS;
drop function ORA_DM_BUILD;
drop type ORA_DM_BUILD_OROWS;
drop type ORA_DM_BUILD_OROW;
drop public synonym ORA_DM_BUILD_FLAT;
drop public synonym ORA_DM_BUILD_FLAT_OROWS;
drop function ORA_DM_BUILD_FLAT;
drop type ORA_DM_BUILD_FLAT_OROWS;
drop type ORA_DM_BUILD_FLAT_OROW;
drop type DM_RQMODEL_RAW_NT;
drop package ORA_DM_REFCUR_PKG;

Rem *************************************************************************
Rem END 12.2 Project 47098: Data Mining Framework
Rem END 12.2 Project 47099: Data Mining Model Partitioning
Rem *************************************************************************

Rem ************************************************************************
Rem BEGIN new lost write
Rem ************************************************************************

truncate table new_lost_write_datafiles$;
truncate table new_lost_write_shadows$;
truncate table new_lost_write_extents$;

Rem V$shadow_datafile for new lost write
drop public synonym gv$shadow_datafile;
drop view gv_$shadow_datafile;
drop public synonym v$shadow_datafile;
drop view v_$shadow_datafile;

Rem =======================================================================
Rem BEGIN Changes for Object Linked view int$container_obj$ (Project 47234)
Rem =======================================================================
Rem 

drop view int$container_obj$;

Rem =======================================================================
Rem END Changes for Object Linked view int$container_obj$ (Project 47234)
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for container$
Rem =======================================================================

Rem Drop columns added to support Proj 47234
alter table container$ drop column remote_user;
alter table container$ drop column lastrcvscn;
alter table container$ drop column srcpdbuid;
alter table container$ drop column remote_srvc;
alter table container$ drop column remote_host;
alter table container$ drop column remote_port;
alter table container$ drop column containers_host;
alter table container$ drop column containers_port;
alter table container$ drop column rafn#;
alter table container$ drop column upgrade_priority;
alter table container$ drop column linkname;
alter table container$ drop column srcpdb;
alter table container$ drop column undoscn;
alter table container$ drop column spare5;
alter table container$ drop column spare6;
alter table container$ rename column fed_root_con_id# to spare2;

Rem Drop columns added to support Proj 47808
alter table container$ drop column f_cdb_dbid;
alter table container$ drop column uscn;
alter table container$ drop column f_con_id#;

Rem proj 47234: drop undots, refreshint columns
alter table container$ drop column undots;
alter table container$ drop column refreshint;

alter table container$ drop column postplugscn;
alter table container$ drop column postplugtime;

-- Column vsn is needed in 12.1.0.2. So conditionalize the rename column.
declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  if prev_version < '12.1.0.2' then
    execute immediate 'alter table container$ rename column vsn to spare1';
  end if;
end;
/

Rem =======================================================================
Rem  END Changes for container$
Rem =======================================================================

Rem =======================================================================
Rem BEGIN View PDB (Proxy PDB) related changes
Rem =======================================================================

truncate table view_pdb$;
truncate table proxy_remote$;

Rem =======================================================================
Rem END View PDB (Proxy PDB) related changes
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Bug 20985003: Migrate Common Data views to use a bit in the first
Rem                     word of PROPERTY column in VIEW$. This bit is 
Rem                     KQLDTVCP_COMMON_DATA (defined as 0x04000000 or
Rem                     power(2,26)). In 12.2, Common Data views use
Rem                     KQLDTVCP2_COMMON_DATA (defined as 0x00100000 or
Rem                     power(2,20)).
Rem =======================================================================

update view$
set property = property - power(2,32+20) + power(2,26)
where bitand(property, power(2,32+20)) = power(2,32+20)
  and bitand(property, power(2,26)) = 0
/
commit;

Rem =======================================================================
Rem END Bug 20985003: Migrate Common Data views to use a bit in the first
Rem                   word of PROPERTY column in VIEW$. This bit is 
Rem                   KQLDTVCP_COMMON_DATA (defined as 0x04000000 or
Rem                   power(2,26)). In 12.2, Common Data views use 
Rem                   KQLDTVCP2_COMMON_DATA (defined as 0x00100000 or
Rem                   power(2,20)).
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes Project 58146 - Scheduler changes for database sharding
Rem =======================================================================

DROP USER REMOTE_SCHEDULER_AGENT CASCADE;
DROP PACKAGE DBMS_ISCHED_REMOTE_ACCESS;

Rem =======================================================================
Rem END Changes Project 58146 - Scheduler changes for database sharding
Rem =======================================================================

Rem *************************************************************************
Rem PDB lockdown profile (project 47234) changes - BEGIN
Rem *************************************************************************

delete from audit_actions where action = 234;
delete from audit_actions where action = 235;
delete from audit_actions where action = 236;

delete from SYSTEM_PRIVILEGE_MAP where
  name = 'CREATE LOCKDOWN PROFILE';
delete from SYSTEM_PRIVILEGE_MAP where
  name = 'DROP LOCKDOWN PROFILE';
delete from SYSTEM_PRIVILEGE_MAP where
  name = 'ALTER LOCKDOWN PROFILE';

delete from STMT_AUDIT_OPTION_MAP where
  name = 'LOCKDOWN PROFILE';
delete from STMT_AUDIT_OPTION_MAP where
  name = 'CREATE LOCKDOWN PROFILE';
delete from STMT_AUDIT_OPTION_MAP where
  name = 'DROP LOCKDOWN PROFILE';
delete from STMT_AUDIT_OPTION_MAP where
  name = 'ALTER LOCKDOWN PROFILE';

commit;

-- define the three default lockdown profiles
DECLARE
  l_is_cdb    VARCHAR(4) := 'NO';
  l_con_id    NUMBER;
BEGIN
  -- Check first to see if connected to a PDB.
  BEGIN
    execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'',''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
  EXCEPTION
    WHEN OTHERS THEN
       null;
  END;
  -- YES and con_id = 1, means connected to root container.
  -- YES and con_id > 1, means connected to a PDB.
  IF l_is_cdb = 'YES' and l_con_id = 1 THEN
    execute immediate 'drop lockdown profile PRIVATE_DBAAS';
    execute immediate 'drop lockdown profile SAAS';
    execute immediate 'drop lockdown profile PUBLIC_DBAAS';
  END IF;
END;
/

drop public synonym CDB_LOCKDOWN_PROFILES;
drop view CDB_LOCKDOWN_PROFILES;
drop public synonym DBA_LOCKDOWN_PROFILES;
drop view DBA_LOCKDOWN_PROFILES;

truncate table lockdown_prof$;

Rem *************************************************************************
Rem PDB lockdown profile (project 47234) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem : Begin Optimizer changes
Rem *************************************************************************

Rem *************************************************************************
Rem : Begin proj 46828 and 47170:
Rem *************************************************************************

-- It may not cause any issues even if we don't set these columns to  null.
-- But just in case...
update tab_stats$ set im_imcu_count = null;
update tab_stats$ set im_block_count = null;
update tab_stats$ set im_sys_incarnation = null;
update tab_stats$ set im_stat_update_time = null;
update tab_stats$ set scanrate = null;
commit;
update wri$_optstat_tab_history set im_imcu_count = null;
update wri$_optstat_tab_history set im_block_count = null;
update wri$_optstat_tab_history set scanrate = null;
commit;

drop view mon_mods_v;

Rem *************************************************************************
Rem : End proj 46828 and 47170:
Rem *************************************************************************


Rem *************************************************************************
Rem Begin Proj 44162: Optimizer Stats Advisor
Rem *************************************************************************

-- We have to drop the package dbms_stats_internal in the downgrade script, 
-- because we added references to new fixed tables in 12.2. Whenever we add 
-- new fixed tables references in a package, we need to drop the package in 
-- downgrade.
drop package body dbms_stats_internal;

drop package dbms_stats_internal;

drop package body sys.dbms_stats_advisor;

drop public synonym dbms_stats_advisor;

drop package sys.dbms_stats_advisor;

delete from wri$_adv_definitions where id = 12;

delete from wri$_adv_def_parameters where advisor_id = 12;

delete from wri$_adv_def_exec_types where advisor_id = 12;

drop type body sys.wri$_adv_stats;

drop type sys.wri$_adv_stats validate;

-- drop stats advisor related tables
drop table stats_advisor_filter_obj$;

drop table stats_advisor_filter_opr$;

drop table stats_advisor_filter_rule$;

-- drop the sequence
drop sequence stats_advisor_dir_seq;

-- drop public synonyms in prvtstattyp.sql
drop public synonym DS_VARRAY_4_CLOB;

drop public synonym COLDICTREC;

drop public synonym COLDICTTAB;

drop public synonym SELREC;

drop public synonym SELTAB;

drop public synonym DBMSSTATNumTab;

drop public synonym CREC;

drop public synonym CTAB;

drop public synonym RAWCREC;

drop public synonym RAWCTAB;

-- drop the fixed views
drop public synonym v$stats_advisor_rules;
drop view v_$stats_advisor_rules;

drop public synonym v$stats_advisor_findings;
drop view v_$stats_advisor_findings;

drop public synonym v$stats_advisor_recs;
drop view v_$stats_advisor_recs;

drop public synonym v$stats_advisor_rationales;
drop view v_$stats_advisor_rationales;

drop public synonym v$stats_advisor_actions;
drop view v_$stats_advisor_actions;

Rem *************************************************************************
Rem End Proj 44162: Optimizer Stats Advisor
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN #(20059248) Changes to wri$_optstat_opr and wri$_optstat_opr_tasks
Rem *************************************************************************

alter table wri$_optstat_opr modify target VARCHAR2(64);

alter table wri$_optstat_opr_tasks modify target VARCHAR2(100);

-- Drop the types modified in prvtstattyp.sql. They were not created with 
-- force option in 12.1.0.2. If we don't drop it, it will leave us with the
-- upgraded type definition
DROP TYPE COLDICTREC FORCE;
DROP TYPE CREC FORCE:

-- SELREC is not dropped since prvtstas.sql in 12.1.0.2 does drop before
-- creating it.
-- RAWCREC is not dropped since it is not modified in 12.2

Rem *************************************************************************
Rem END Changes to wri$_optstat_opr and wri$_optstat_opr_tasks
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj 47047: Expression Tracking
Rem *************************************************************************

truncate table exp_head$;

truncate table exp_obj$;

truncate table exp_stat$;

Rem *************************************************************************
Rem END Proj 47047: Expression Tracking
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN #(20640156) Drop atribute col_flag
Rem *************************************************************************

drop type COLDICTREC force;

Rem *************************************************************************
Rem END #(20640156) Drop atribute col_flag
Rem *************************************************************************

Rem =========================================================================
Rem Begin #(20413540) 
Rem =========================================================================

Rem Truncate the index organized table that store sql statistics
truncate table opt_sqlstat$;

Rem =========================================================================
Rem End #(20413540) 
Rem =========================================================================

Rem =========================================================================
Rem Begin #(22532386) downgrade requirement 
Rem =========================================================================

Rem truncate table optstat_snapshot$ and col FLAGS in table COL_USAGE$
truncate table optstat_snapshot$;
update COL_USAGE$ set FLAGS = null; 

Rem =========================================================================
Rem End #(22532386) 
Rem =========================================================================

Rem ********************************************************************
Rem End  Optimizer changes
Rem ********************************************************************

Rem =======================================================================
Rem BEGIN changes for Proj 46907: RAS schema level policy admin
Rem =======================================================================

drop view ALL_XS_SECURITY_CLASSES;
drop public synonym ALL_XS_SECURITY_CLASSES;
drop view ALL_XS_SECURITY_CLASS_DEP;
drop public synonym ALL_XS_SECURITY_CLASS_DEP;
drop view ALL_XS_PRIVILEGES;
drop public synonym ALL_XS_PRIVILEGES;
drop view ALL_XS_IMPLIED_PRIVILEGES;
drop public synonym ALL_XS_IMPLIED_PRIVILEGES;
drop view ALL_XS_ACLS;
drop public synonym ALL_XS_ACLS;
drop view ALL_XS_ACES;
drop public synonym ALL_XS_ACES;
drop view ALL_XS_APPLIED_POLICIES;
drop public synonym ALL_XS_APPLIED_POLICIES;
drop view ALL_XS_POLICIES;
drop public synonym ALL_XS_POLICIES;
drop view ALL_XS_REALM_CONSTRAINTS;
drop public synonym ALL_XS_REALM_CONSTRAINTS;
drop view ALL_XS_INHERITED_REALMS;
drop public synonym ALL_XS_INHERITED_REALMS;
drop view ALL_XS_ACL_PARAMETERS;
drop public synonym ALL_XS_ACL_PARAMETERS;
drop view ALL_XS_COLUMN_CONSTRAINTS;
drop public synonym ALL_XS_COLUMN_CONSTRAINTS;
drop view DBA_XS_PRIVILEGE_GRANTS;
drop public synonym DBA_XS_PRIVILEGE_GRANTS;
drop view CDB_XS_PRIVILEGE_GRANTS;
drop public synonym CDB_XS_PRIVILEGE_GRANTS;
drop view ALL_XS_APPLICABLE_OBJECTS;
drop public synonym ALL_XS_APPLICABLE_OBJECTS;

drop package XS_ADMIN_UTIL_INT; 

-- Create XS_RESOURCE role;
create role XS_RESOURCE;

declare
PRIN_XS_RESOURCE_ROLE    NUMBER;
RESERVED_ID              NUMBER := 2147483648;
ACL_SYSTEM_SC            NUMBER := RESERVED_ID + 13;
PRIV_ADMIN_SEC_PLY       NUMBER := RESERVED_ID + 19;
begin
-- Grant XS_RESOURCE role ADMIN_SEC_POLICY privilege
select user# into PRIN_XS_RESOURCE_ROLE from sys.user$ 
where NAME = 'XS_RESOURCE';

insert into sys.xs$ace values (ACL_SYSTEM_SC,6,1,PRIN_XS_RESOURCE_ROLE,2,0,null,null,3);
insert into sys.xs$ace_priv values (ACL_SYSTEM_SC,6,PRIV_ADMIN_SEC_PLY);
end;
/
commit;

Rem =======================================================================
Rem END changes for Proj 46907: RAS schema level policy admin
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Zonemap Usage Tracking (ZUT)
Rem =======================================================================

DROP VIEW v_$zonemap_usage_stats;
DROP PUBLIC synonym v$zonemap_usage_stats;
DROP VIEW gv_$zonemap_usage_stats;
DROP PUBLIC synonym gv$zonemap_usage_stats;

Rem =======================================================================
Rem  End Changes for Zonemap Usage Tracking (ZUT)
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for GCR_METRICS 
Rem =======================================================================

DROP VIEW v_$gcr_metrics;
DROP PUBLIC synonym v$gcr_metrics;
DROP VIEW gv_$gcr_metrics;
DROP PUBLIC synonym gv$gcr_metrics;

Rem =======================================================================
Rem  End Changes for GCR_METRICS 
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for GCR_ACTIONS 
Rem =======================================================================

DROP VIEW v_$gcr_actions;
DROP PUBLIC synonym v$gcr_actions;
DROP VIEW gv_$gcr_actions;
DROP PUBLIC synonym gv$gcr_actions;

Rem =======================================================================
Rem  End Changes for GCR_ACTIONS
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for GCR_STATUS 
Rem =======================================================================

DROP VIEW v_$gcr_status;
DROP PUBLIC synonym v$gcr_status;
DROP VIEW gv_$gcr_status;
DROP PUBLIC synonym gv$gcr_status;

Rem =======================================================================
Rem  End Changes for GCR_STATUS
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for GCR_LOG
Rem =======================================================================

DROP VIEW v_$gcr_log;
DROP PUBLIC synonym v$gcr_log;
DROP VIEW gv_$gcr_log;
DROP PUBLIC synonym gv$gcr_log;

Rem =======================================================================
Rem  End Changes for GCR_LOG
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for Federation tables/views/sequences (Proj 47234)
Rem =======================================================================

drop public synonym CDB_APP_ERRORS;
drop view CDB_APP_ERRORS;
drop public synonym DBA_APP_ERRORS;
drop view DBA_APP_ERRORS;

drop public synonym CDB_APPLICATIONS;
drop view CDB_APPLICATIONS;
drop public synonym DBA_APPLICATIONS;
drop view DBA_APPLICATIONS;

drop public synonym CDB_APP_PATCHES;
drop view CDB_APP_PATCHES;
drop public synonym DBA_APP_PATCHES;
drop view DBA_APP_PATCHES;

drop public synonym CDB_APP_VERSIONS;
drop view CDB_APP_VERSIONS;
drop public synonym DBA_APP_VERSIONS;
drop view DBA_APP_VERSIONS;

drop public synonym CDB_APP_STATEMENTS;
drop view CDB_APP_STATEMENTS;
drop public synonym DBA_APP_STATEMENTS;
drop view DBA_APP_STATEMENTS;
drop view INT$DBA_APP_STATEMENTS;

drop public synonym CDB_APP_PDB_STATUS;
drop view CDB_APP_PDB_STATUS;
drop public synonym DBA_APP_PDB_STATUS;
drop view DBA_APP_PDB_STATUS;

truncate table sys.fed$apps;
truncate table sys.fed$patches;
truncate table sys.fed$versions;
truncate table sys.fed$statement$errors;
truncate table sys.fed$app$status;
truncate table sys.fed$binds;
truncate table sys.fed$editions;
truncate table sys.fed$dependency;

drop sequence sys.fed$sess_seq;
drop sequence sys.fed$stmt_seq;
drop sequence sys.fed$appid_seq;
drop sequence sys.app$system$seq;

Rem =======================================================================
Rem  END Changes for Federation tables/views/sequences (Proj 47234)
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for zeroing the 3rd and higher significant words in 
Rem       view$.property (Proj 47234)
Rem =======================================================================

update view$ set property=mod(property,power(2,64))
where property >= power(2,64);

Rem =======================================================================
Rem BEGIN Changes for zeroing the 3rd and higher significant words in 
Rem       view$.property (Proj 47234)
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for zeroing the 3rd and higher significant words in 
Rem       tab$.property (Proj 47234)
Rem =======================================================================

update tab$ set property=mod(property,power(2,64))
where property >= power(2,64);

Rem =======================================================================
Rem BEGIN Changes for zeroing the 3rd and higher significant words in 
Rem       tab$.property (Proj 47234)
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for scheduler for long id project
Rem =======================================================================

alter table sys.scheduler$_job modify (destination varchar2(128),
                                       queue_agent varchar2(256));

alter table sys.scheduler$_lightweight_job modify (destination varchar2(128),
                                                   queue_agent varchar2(256));

alter table scheduler$_event_log
modify destination varchar2(128);


alter table scheduler$_job_run_details
modify destination varchar2(128);

alter table scheduler$_step modify (destination varchar2(128),
                                    queue_agent varchar2(128));

alter table scheduler$_step_state
modify destination varchar2(128);

alter table scheduler$_file_watcher
modify destination varchar2(128);

alter table scheduler$_filewatcher_resend
modify destination varchar2(128);

alter table scheduler$_job_destinations
modify destination varchar2(128);

alter table job$ modify (cur_ses_label MLSLABEL,
                         CLEARANCE_HI  MLSLABEL,
                         CLEARANCE_LO  MLSLABEL);

alter table system.scheduler_program_args_tbl modify
  program_name varchar2(30);

alter table system.scheduler_program_args_tbl modify
  owner varchar2(30):

alter table scheduler$_schedule  modify
   queue_agent varchar2(128); 

alter table sys.scheduler$_srcq_map drop constraint 
   scheduler$_srcq_map_pk;

alter table sys.scheduler$_srcq_map modify 
   rule_name varchar2(256); 

alter table sys.scheduler$_srcq_map add constraint
  scheduler$_srcq_map_pk primary key (oid, rule_name);

drop type sys.scheduler$_chain_link force;

drop type sys.scheduler$_step_type force;

drop type sys.scheduler$_batcherr force;

drop type sys.job_definition force; 

drop type sys.job force; 

Rem *************************************************************************
Rem END changes for scheduler for long id project
Rem *************************************************************************
  
Rem =======================================================================
Rem  Begin Changes for refresh stats history
Rem =======================================================================

truncate table mvref$_stats;
truncate table mvref$_run_stats;
truncate table mvref$_change_stats;
truncate table mvref$_stmt_stats;
truncate table mvref$_stats_sys_defaults;
truncate table mvref$_stats_params;


drop public synonym CDB_MVREF_STATS_SYS_DEFAULTS;
drop view CDB_MVREF_STATS_SYS_DEFAULTS;
drop public synonym CDB_MVREF_STATS_PARAMS;
drop view CDB_MVREF_STATS_PARAMS;
drop public synonym CDB_MVREF_RUN_STATS;
drop view CDB_MVREF_RUN_STATS;
drop public synonym CDB_MVREF_CHANGE_STATS;
drop view CDB_MVREF_CHANGE_STATS;
drop public synonym CDB_MVREF_STMT_STATS;
drop view CDB_MVREF_STMT_STATS;
drop public synonym CDB_MVREF_STATS;
drop view CDB_MVREF_STATS;


drop public synonym dbms_mview_stats;
drop public synonym dba_mvref_stats_sys_defaults;
drop public synonym user_mvref_stats_sys_defaults;
drop public synonym dba_mvref_stats_params;
drop public synonym user_mvref_stats_params;
drop public synonym dba_mvref_run_stats;
drop public synonym user_mvref_run_stats;
drop public synonym dba_mvref_change_stats;
drop public synonym user_mvref_change_stats;
drop public synonym dba_mvref_stmt_stats;
drop public synonym user_mvref_stmt_stats;
drop public synonym dba_mvref_stats;
drop public synonym user_mvref_stats;
drop public synonym dbms_irefstats;


drop sequence mvref$_stats_seq;

drop package dbms_mview_stats;
drop package dbms_irefstats;

drop view dba_mvref_stats_sys_defaults;
drop view user_mvref_stats_sys_defaults;
drop view dba_mvref_stats_params;
drop view user_mvref_stats_params;
drop view dba_mvref_run_stats;
drop view user_mvref_run_stats;
drop view dba_mvref_change_stats;
drop view user_mvref_change_stats;
drop view dba_mvref_stmt_stats;
drop view user_mvref_stmt_stats;
drop view dba_mvref_stats;
drop view user_mvref_stats;


Rem =======================================================================
Rem  End Changes for refresh stats history
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for proj 47362 - Purge by size project
Rem =======================================================================
drop public synonym v$DIAG_DFW_PURGE;
drop view v_$DIAG_DFW_PURGE;
drop public synonym v$DIAG_DFW_PURGE_ITEM;
drop view v_$DIAG_DFW_PURGE_ITEM;
drop public synonym v$DIAG_ADR_CONTROL_AUX;
drop view v_$DIAG_ADR_CONTROL_AUX;
Rem =======================================================================
Rem  End Changes for proj 47362
Rem =======================================================================

Rem *************************************************************************
Rem Begin PL/Scope for SQL changes
Rem *************************************************************************

truncate table plscope_sql$;
truncate table plscope_statement$;
truncate table plscope_identifier$;
truncate table plscope_action$;
drop view all_statements;
drop public synonym all_statements;
drop view dba_statements;
drop public synonym dba_statements;
drop view user_statements;
drop public synonym user_statements;
drop view CDB_STATEMENTS;
drop public synonym CDB_STATEMENTS;
drop view INT$DBA_STATEMENTS;

Rem *************************************************************************
Rem End PL/Scope for SQL changes
Rem *************************************************************************

Rem *************************************************************************
Rem Project 47511: data-bound collation
Rem *************************************************************************

-- drop views created in cdcore_mig.sql, cdpart_mig.sql
drop view user_ind_columns_v$;
drop view all_ind_columns_v$;
drop view dba_ind_columns_v$;
drop view cdb_ind_columns_v$;
drop view user_part_key_columns_v$;
drop view all_part_key_columns_v$;
drop view dba_part_key_columns_v$;
drop view cdb_part_key_columns_v$;
drop view user_subpart_key_columns_v$;
drop view all_subpart_key_columns_v$;
drop view dba_subpart_key_columns_v$;
drop view cdb_subpart_key_columns_v$;

Rem *************************************************************************
Rem End Project 47511: data-bound collation
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for DBMS_HANG_MANAGER
Rem =======================================================================

drop package dbms_hang_manager;
drop view dba_hang_manager_parameters;
drop public synonym dba_hang_manager_parameters;
drop view cdb_hang_manager_parameters;
drop public synonym cdb_hang_manager_parameters;
truncate table hang_manager_parameters;
drop library dbms_hang_manager_lib;

Rem =======================================================================
Rem  End Changes for DBMS_HANG_MANAGER
Rem =======================================================================
  
Rem *************************************************************************
Rem : Proj 47234 - adding support for federationally granted administrative 
Rem     privileges
Rem *************************************************************************

update cdb_local_adminauth$ set fed_privileges = 0
/

update adminauth$ set fedpriv = 0
/

Rem *************************************************************************
Rem : End Proj 47234 - adding support for federationally granted 
Rem     administrative privileges
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN changes for DBMS_ROLLING
Rem =======================================================================

-- 18842051: Decrease column size back to pre 12.2 definition
update system.rolling$parameters 
  set curval = substr(curval,1,256), lstval = substr(lstval,1,256),
      defval = substr(defval,1,256);
commit;
alter table system.rolling$parameters modify
  (curval varchar2(256), lstval varchar2(256), defval varchar2(256));

Rem =======================================================================
Rem END changes for DBMS_ROLLING
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN Changes to sqlobj$plan
Rem *************************************************************************

alter table sqlobj$plan modify category VARCHAR2(30);

Rem *************************************************************************
Rem END Changes to sqlobj$plan
Rem *************************************************************************


Rem =======================================================================
Rem BEGIN Changes for DBMS_PROCESS & [G]V$PROCESS_POOL
Rem =======================================================================

drop package dbms_process;
drop library dbms_process_lib;
drop public synonym gv$process_pool;
drop view gv_$process_pool;
drop public synonym v$process_pool;
drop view v_$process_pool;

Rem =======================================================================
Rem END Changes for DBMS_PROCESS & [G]V$PROCESS_POOL
Rem =======================================================================

Rem =======================================================================
Rem Begin Online Redefinition 12.2 Proj#39358 ROLLBACK changes
Rem =======================================================================

truncate table redef_object_backup$;

Rem =======================================================================
Rem End Online Redefinition 12.2 Proj#39358 ROLLBACK changes
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for bug 20019217, 21473661
Rem =======================================================================

drop view DBA_XS_ENABLED_AUDIT_POLICIES;
drop public synonym DBA_XS_ENABLED_AUDIT_POLICIES;
drop view CDB_XS_ENABLED_AUDIT_POLICIES;
drop public synonym CDB_XS_ENABLED_AUDIT_POLICIES;
drop public synonym DBA_XS_ENB_AUDIT_POLICIES;
drop public synonym CDB_XS_ENB_AUDIT_POLICIES;

Rem =======================================================================
Rem END changes for bug 20019217, 21473661
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for bug 17900999 
Rem =======================================================================

Rem Bug 17900999. Restore it back to 16
alter table sys.aud$ modify(auth$privileges varchar2(16))
/

Rem =======================================================================
Rem END changes for bug 17900999 
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.2 Changes for Multi-language debugging
Rem =======================================================================

drop view gv_$plsql_debuggable_sessions;
drop public synonym gv$plsql_debuggable_sessions;
drop view v_$plsql_debuggable_sessions;
drop public synonym v$plsql_debuggable_sessions;
delete from SYSTEM_PRIVILEGE_MAP where PRIVILEGE in (-240);
delete from STMT_AUDIT_OPTION_MAP where OPTION# in (240);

Rem =======================================================================
Rem  End 12.2 Changes for Multi-language debugging
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for proj 48488 (BigSQL/Read Only Instances)
Rem =======================================================================

drop package sys.dbms_pq_internal;

Rem =======================================================================
Rem END  changes for proj 48488 (BigSQL/Read Only Instances)
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for bug 20088724
Rem =======================================================================

drop view dba_registry_schemas;
drop public synonym dba_registry_schemas;
drop view CDB_registry_schemas;
drop public synonym CDB_registry_schemas;

Rem =======================================================================
Rem END changes for bug 20088724
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for Proj 47091: Analytic View Sql (HCS)
Rem =======================================================================

-- HCS dictionary tables
truncate table hcs_dim$;
truncate table hcs_dim_attr$;
truncate table hcs_dim_lvl_key$;
truncate table hcs_dim_lvl_key_attr$;
truncate table hcs_dim_dtm_attr$;
truncate table hcs_dim_lvl$;
truncate table hcs_lvl_ord$;
truncate table hcs_hierarchy$;
truncate table hcs_hr_lvl$;
truncate table hcs_hier_attr$;
truncate table hcs_hier_col$;
truncate table hcs_analytic_view$;
truncate table hcs_av_key$;
truncate table hcs_av_dim$;
truncate table hcs_av_meas$;
truncate table hcs_av_hier$;
truncate table hcs_av_col$;
truncate table hcs_av_lvl$;
truncate table hcs_av_lvlgrp$;
truncate table hcs_lvlgrp_lvls$;
truncate table hcs_measlst_measures$;
truncate table hcs_clsfctn$;
truncate table hcs_av_clsfctn$;
truncate table hcs_src$;
truncate table hcs_src_col$;
truncate table hcs_dim_join_path$;
truncate table hcs_join_cond_elem$;
truncate table hcs_hier_join_path$;
truncate table hcs_hr_lvl_id$;

-- HCS dictionary views
drop public synonym DBA_ATTRIBUTE_DIM_ORDER_ATTRS;
drop view DBA_ATTRIBUTE_DIM_ORDER_ATTRS;
drop public synonym USER_ATTRIBUTE_DIM_ORDER_ATTRS;
drop view USER_ATTRIBUTE_DIM_ORDER_ATTRS;
drop public synonym ALL_ATTRIBUTE_DIM_ORDER_ATTRS;
drop view ALL_ATTRIBUTE_DIM_ORDER_ATTRS;
drop public synonym DBA_ATTRIBUTE_DIM_CLASS;
drop view DBA_ATTRIBUTE_DIM_CLASS;
drop public synonym USER_ATTRIBUTE_DIM_CLASS;
drop view USER_ATTRIBUTE_DIM_CLASS;
drop public synonym ALL_ATTRIBUTE_DIM_CLASS;
drop view ALL_ATTRIBUTE_DIM_CLASS;
drop public synonym DBA_ATTRIBUTE_DIM_ATTR_CLASS;
drop view DBA_ATTRIBUTE_DIM_ATTR_CLASS;
drop public synonym USER_ATTRIBUTE_DIM_ATTR_CLASS;
drop view USER_ATTRIBUTE_DIM_ATTR_CLASS;
drop public synonym ALL_ATTRIBUTE_DIM_ATTR_CLASS;
drop view ALL_ATTRIBUTE_DIM_ATTR_CLASS;
drop public synonym DBA_ATTRIBUTE_DIM_LVL_CLASS;
drop view DBA_ATTRIBUTE_DIM_LVL_CLASS;
drop public synonym USER_ATTRIBUTE_DIM_LVL_CLASS;
drop view USER_ATTRIBUTE_DIM_LVL_CLASS;
drop public synonym ALL_ATTRIBUTE_DIM_LVL_CLASS;
drop view ALL_ATTRIBUTE_DIM_LVL_CLASS;
drop public synonym DBA_HIER_CLASS;
drop view DBA_HIER_CLASS;
drop public synonym USER_HIER_CLASS;
drop view USER_HIER_CLASS;
drop public synonym ALL_HIER_CLASS;
drop view ALL_HIER_CLASS;
drop public synonym DBA_ANALYTIC_VIEW_LEVELS;
drop view DBA_ANALYTIC_VIEW_LEVELS;
drop public synonym USER_ANALYTIC_VIEW_LEVELS;
drop view USER_ANALYTIC_VIEW_LEVELS;
drop public synonym ALL_ANALYTIC_VIEW_LEVELS;
drop view ALL_ANALYTIC_VIEW_LEVELS;
drop public synonym DBA_ANALYTIC_VIEW_LVLGRPS;
drop view DBA_ANALYTIC_VIEW_LVLGRPS;
drop public synonym USER_ANALYTIC_VIEW_LVLGRPS;
drop view USER_ANALYTIC_VIEW_LVLGRPS;
drop public synonym ALL_ANALYTIC_VIEW_LVLGRPS;
drop view ALL_ANALYTIC_VIEW_LVLGRPS;
drop public synonym DBA_ANALYTIC_VIEW_ATTR_CLASS;
drop view DBA_ANALYTIC_VIEW_ATTR_CLASS;
drop public synonym USER_ANALYTIC_VIEW_ATTR_CLASS;
drop view USER_ANALYTIC_VIEW_ATTR_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_ATTR_CLASS;
drop view ALL_ANALYTIC_VIEW_ATTR_CLASS;
drop public synonym DBA_ANALYTIC_VIEW_HIER_CLASS;
drop view DBA_ANALYTIC_VIEW_HIER_CLASS;
drop public synonym USER_ANALYTIC_VIEW_HIER_CLASS;
drop view USER_ANALYTIC_VIEW_HIER_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_HIER_CLASS;
drop view ALL_ANALYTIC_VIEW_HIER_CLASS;
drop public synonym DBA_ANALYTIC_VIEW_LEVEL_CLASS;
drop view DBA_ANALYTIC_VIEW_LEVEL_CLASS;
drop public synonym USER_ANALYTIC_VIEW_LEVEL_CLASS;
drop view USER_ANALYTIC_VIEW_LEVEL_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_LEVEL_CLASS;
drop view ALL_ANALYTIC_VIEW_LEVEL_CLASS;
drop public synonym DBA_HIER_HIER_ATTR_CLASS;
drop view DBA_HIER_HIER_ATTR_CLASS;
drop public synonym USER_HIER_HIER_ATTR_CLASS;
drop view USER_HIER_HIER_ATTR_CLASS;
drop public synonym ALL_HIER_HIER_ATTR_CLASS;
drop view ALL_HIER_HIER_ATTR_CLASS;
drop public synonym DBA_HIER_HIER_ATTRIBUTES;
drop view DBA_HIER_HIER_ATTRIBUTES;
drop public synonym USER_HIER_HIER_ATTRIBUTES;
drop view USER_HIER_HIER_ATTRIBUTES;
drop public synonym ALL_HIER_HIER_ATTRIBUTES;
drop view ALL_HIER_HIER_ATTRIBUTES;
drop public synonym DBA_ANALYTIC_VIEW_CLASS;
drop view DBA_ANALYTIC_VIEW_CLASS;
drop public synonym USER_ANALYTIC_VIEW_CLASS;
drop view USER_ANALYTIC_VIEW_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_CLASS;
drop view ALL_ANALYTIC_VIEW_CLASS;
drop public synonym DBA_ANALYTIC_VIEW_MEAS_CLASS;
drop view DBA_ANALYTIC_VIEW_MEAS_CLASS;
drop public synonym USER_ANALYTIC_VIEW_MEAS_CLASS;
drop view USER_ANALYTIC_VIEW_MEAS_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_MEAS_CLASS;
drop view ALL_ANALYTIC_VIEW_MEAS_CLASS;
drop public synonym DBA_ANALYTIC_VIEW_DIM_CLASS;
drop view DBA_ANALYTIC_VIEW_DIM_CLASS;
drop public synonym USER_ANALYTIC_VIEW_DIM_CLASS;
drop view USER_ANALYTIC_VIEW_DIM_CLASS;
drop public synonym ALL_ANALYTIC_VIEW_DIM_CLASS;
drop view ALL_ANALYTIC_VIEW_DIM_CLASS;
drop public synonym DBA_ATTRIBUTE_DIMENSIONS;
drop view DBA_ATTRIBUTE_DIMENSIONS;
drop public synonym USER_ATTRIBUTE_DIMENSIONS;
drop view USER_ATTRIBUTE_DIMENSIONS;
drop public synonym ALL_ATTRIBUTE_DIMENSIONS;
drop view ALL_ATTRIBUTE_DIMENSIONS;
drop public synonym DBA_ATTRIBUTE_DIM_ATTRS;
drop view DBA_ATTRIBUTE_DIM_ATTRS;
drop public synonym USER_ATTRIBUTE_DIM_ATTRS;
drop view USER_ATTRIBUTE_DIM_ATTRS;
drop public synonym ALL_ATTRIBUTE_DIM_ATTRS;
drop view ALL_ATTRIBUTE_DIM_ATTRS;
drop public synonym DBA_ATTRIBUTE_DIM_TABLES;
drop view DBA_ATTRIBUTE_DIM_TABLES;
drop public synonym USER_ATTRIBUTE_DIM_TABLES;
drop view USER_ATTRIBUTE_DIM_TABLES;
drop public synonym ALL_ATTRIBUTE_DIM_TABLES;
drop view ALL_ATTRIBUTE_DIM_TABLES;
drop public synonym DBA_ATTRIBUTE_DIM_LEVELS;
drop view DBA_ATTRIBUTE_DIM_LEVELS;
drop public synonym USER_ATTRIBUTE_DIM_LEVELS;
drop view USER_ATTRIBUTE_DIM_LEVELS;
drop public synonym ALL_ATTRIBUTE_DIM_LEVELS;
drop view ALL_ATTRIBUTE_DIM_LEVELS;
drop public synonym DBA_HIERARCHIES;
drop view DBA_HIERARCHIES;
drop public synonym USER_HIERARCHIES;
drop view USER_HIERARCHIES;
drop public synonym ALL_HIERARCHIES;
drop view ALL_HIERARCHIES;
drop public synonym DBA_HIER_LEVELS;
drop view DBA_HIER_LEVELS;
drop public synonym USER_HIER_LEVELS;
drop view USER_HIER_LEVELS;
drop public synonym ALL_HIER_LEVELS;
drop view ALL_HIER_LEVELS;
drop public synonym DBA_HIER_COLUMNS;
drop view DBA_HIER_COLUMNS;
drop public synonym USER_HIER_COLUMNS;
drop view USER_HIER_COLUMNS;
drop public synonym ALL_HIER_COLUMNS;
drop view ALL_HIER_COLUMNS;
drop public synonym DBA_ANALYTIC_VIEWS;
drop view DBA_ANALYTIC_VIEWS;
drop public synonym USER_ANALYTIC_VIEWS;
drop view USER_ANALYTIC_VIEWS;
drop public synonym ALL_ANALYTIC_VIEWS;
drop view ALL_ANALYTIC_VIEWS;
drop public synonym DBA_ANALYTIC_VIEW_DIMENSIONS;
drop view DBA_ANALYTIC_VIEW_DIMENSIONS;
drop public synonym USER_ANALYTIC_VIEW_DIMENSIONS;
drop view USER_ANALYTIC_VIEW_DIMENSIONS;
drop public synonym ALL_ANALYTIC_VIEW_DIMENSIONS;
drop view ALL_ANALYTIC_VIEW_DIMENSIONS;
drop public synonym DBA_ANALYTIC_VIEW_CALC_MEAS;
drop view DBA_ANALYTIC_VIEW_CALC_MEAS;
drop public synonym USER_ANALYTIC_VIEW_CALC_MEAS;
drop view USER_ANALYTIC_VIEW_CALC_MEAS;
drop public synonym ALL_ANALYTIC_VIEW_CALC_MEAS;
drop view ALL_ANALYTIC_VIEW_CALC_MEAS;
drop public synonym DBA_ANALYTIC_VIEW_BASE_MEAS;
drop view DBA_ANALYTIC_VIEW_BASE_MEAS;
drop public synonym USER_ANALYTIC_VIEW_BASE_MEAS;
drop view USER_ANALYTIC_VIEW_BASE_MEAS;
drop public synonym ALL_ANALYTIC_VIEW_BASE_MEAS;
drop view ALL_ANALYTIC_VIEW_BASE_MEAS;
drop public synonym DBA_ANALYTIC_VIEW_KEYS;
drop view DBA_ANALYTIC_VIEW_KEYS;
drop public synonym USER_ANALYTIC_VIEW_KEYS;
drop view USER_ANALYTIC_VIEW_KEYS;
drop public synonym ALL_ANALYTIC_VIEW_KEYS;
drop view ALL_ANALYTIC_VIEW_KEYS;
drop public synonym DBA_ANALYTIC_VIEW_HIERS;
drop view DBA_ANALYTIC_VIEW_HIERS;
drop public synonym USER_ANALYTIC_VIEW_HIERS;
drop view USER_ANALYTIC_VIEW_HIERS;
drop public synonym ALL_ANALYTIC_VIEW_HIERS;
drop view ALL_ANALYTIC_VIEW_HIERS;
drop public synonym DBA_ANALYTIC_VIEW_COLUMNS;
drop view DBA_ANALYTIC_VIEW_COLUMNS;
drop public synonym USER_ANALYTIC_VIEW_COLUMNS;
drop view USER_ANALYTIC_VIEW_COLUMNS;
drop public synonym ALL_ANALYTIC_VIEW_COLUMNS;
drop view ALL_ANALYTIC_VIEW_COLUMNS;
drop public synonym DBA_ATTRIBUTE_DIM_KEYS;
drop view DBA_ATTRIBUTE_DIM_KEYS;
drop public synonym USER_ATTRIBUTE_DIM_KEYS;
drop view USER_ATTRIBUTE_DIM_KEYS;
drop public synonym ALL_ATTRIBUTE_DIM_KEYS;
drop view ALL_ATTRIBUTE_DIM_KEYS;
drop public synonym DBA_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop view DBA_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop public synonym USER_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop view USER_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop public synonym ALL_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop view ALL_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop public synonym DBA_ATTRIBUTE_DIM_JOIN_PATHS;
drop view DBA_ATTRIBUTE_DIM_JOIN_PATHS;
drop public synonym USER_ATTRIBUTE_DIM_JOIN_PATHS;
drop view USER_ATTRIBUTE_DIM_JOIN_PATHS;
drop public synonym ALL_ATTRIBUTE_DIM_JOIN_PATHS;
drop view ALL_ATTRIBUTE_DIM_JOIN_PATHS;
drop public synonym DBA_HIER_JOIN_PATHS;
drop view DBA_HIER_JOIN_PATHS;
drop public synonym USER_HIER_JOIN_PATHS;
drop view USER_HIER_JOIN_PATHS;
drop public synonym ALL_HIER_JOIN_PATHS;
drop view ALL_HIER_JOIN_PATHS;
drop public synonym DBA_HIER_LEVEL_ID_ATTRS;
drop view DBA_HIER_LEVEL_ID_ATTRS;
drop public synonym USER_HIER_LEVEL_ID_ATTRS;
drop view USER_HIER_LEVEL_ID_ATTRS;
drop public synonym ALL_HIER_LEVEL_ID_ATTRS;
drop view ALL_HIER_LEVEL_ID_ATTRS;

-- HCS cdb views
drop public synonym CDB_ATTRIBUTE_DIM_ORDER_ATTRS;
drop view CDB_ATTRIBUTE_DIM_ORDER_ATTRS;
drop public synonym CDB_ATTRIBUTE_DIM_CLASS;
drop view CDB_ATTRIBUTE_DIM_CLASS;
drop public synonym CDB_ATTRIBUTE_DIM_ATTR_CLASS;
drop view CDB_ATTRIBUTE_DIM_ATTR_CLASS;
drop public synonym CDB_ATTRIBUTE_DIM_LVL_CLASS;
drop view CDB_ATTRIBUTE_DIM_LVL_CLASS;
drop public synonym CDB_HIER_CLASS;
drop view CDB_HIER_CLASS;
drop public synonym CDB_ANALYTIC_VIEW_LEVELS;
drop view CDB_ANALYTIC_VIEW_LEVELS;
drop public synonym CDB_ANALYTIC_VIEW_LVLGRPS;
drop view CDB_ANALYTIC_VIEW_LVLGRPS;
drop public synonym CDB_ANALYTIC_VIEW_ATTR_CLASS;
drop view CDB_ANALYTIC_VIEW_ATTR_CLASS;
drop public synonym CDB_ANALYTIC_VIEW_HIER_CLASS;
drop view CDB_ANALYTIC_VIEW_HIER_CLASS;
drop public synonym CDB_ANALYTIC_VIEW_LEVEL_CLASS;
drop view CDB_ANALYTIC_VIEW_LEVEL_CLASS;
drop public synonym CDB_HIER_HIER_ATTR_CLASS;
drop view CDB_HIER_HIER_ATTR_CLASS;
drop public synonym CDB_HIER_HIER_ATTRIBUTES;
drop view CDB_HIER_HIER_ATTRIBUTES;
drop public synonym CDB_ANALYTIC_VIEW_CLASS;
drop view CDB_ANALYTIC_VIEW_CLASS;
drop public synonym CDB_ANALYTIC_VIEW_MEAS_CLASS;
drop view CDB_ANALYTIC_VIEW_MEAS_CLASS;
drop public synonym CDB_ANALYTIC_VIEW_DIM_CLASS;
drop view CDB_ANALYTIC_VIEW_DIM_CLASS;
drop public synonym CDB_ATTRIBUTE_DIMENSIONS;
drop view CDB_ATTRIBUTE_DIMENSIONS;
drop public synonym CDB_ATTRIBUTE_DIM_ATTRS;
drop view CDB_ATTRIBUTE_DIM_ATTRS;
drop public synonym CDB_ATTRIBUTE_DIM_TABLES;
drop view CDB_ATTRIBUTE_DIM_TABLES;
drop public synonym CDB_ATTRIBUTE_DIM_LEVELS;
drop view CDB_ATTRIBUTE_DIM_LEVELS;
drop public synonym CDB_HIERARCHIES;
drop view CDB_HIERARCHIES;
drop public synonym CDB_HIER_LEVELS;
drop view CDB_HIER_LEVELS;
drop public synonym CDB_HIER_COLUMNS;
drop view CDB_HIER_COLUMNS;
drop public synonym CDB_ANALYTIC_VIEWS;
drop view CDB_ANALYTIC_VIEWS;
drop public synonym CDB_ANALYTIC_VIEW_DIMENSIONS;
drop view CDB_ANALYTIC_VIEW_DIMENSIONS;
drop public synonym CDB_ANALYTIC_VIEW_CALC_MEAS;
drop view CDB_ANALYTIC_VIEW_CALC_MEAS;
drop public synonym CDB_ANALYTIC_VIEW_BASE_MEAS;
drop view CDB_ANALYTIC_VIEW_BASE_MEAS;
drop public synonym CDB_ANALYTIC_VIEW_KEYS;
drop view CDB_ANALYTIC_VIEW_KEYS;
drop public synonym CDB_ANALYTIC_VIEW_HIERS;
drop view CDB_ANALYTIC_VIEW_HIERS;
drop public synonym CDB_ANALYTIC_VIEW_COLUMNS;
drop view CDB_ANALYTIC_VIEW_COLUMNS;
drop public synonym CDB_ATTRIBUTE_DIM_KEYS;
drop view CDB_ATTRIBUTE_DIM_KEYS;
drop public synonym CDB_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop view CDB_ATTRIBUTE_DIM_LEVEL_ATTRS;
drop public synonym CDB_ATTRIBUTE_DIM_JOIN_PATHS;
drop view CDB_ATTRIBUTE_DIM_JOIN_PATHS;
drop public synonym CDB_HIER_JOIN_PATHS;
drop view CDB_HIER_JOIN_PATHS;
drop public synonym CDB_HIER_LEVEL_ID_ATTRS;
drop view CDB_HIER_LEVEL_ID_ATTRS;

-- HCS int$dba views
drop view INT$DBA_ATTR_DIM_ORDER_ATT;
drop view INT$DBA_ATTR_DIM_CLASS;
drop view INT$DBA_ATTR_DIM_ATTR_CLASS;
drop view INT$DBA_ATTR_DIM_LVL_CLASS;
drop view INT$DBA_HIER_CLASS;
drop view INT$DBA_AVIEW_LEVELS;
drop view INT$DBA_AVIEW_LVLGRPS;
drop view INT$DBA_AVIEW_ATTR_CLASS;
drop view INT$DBA_AVIEW_HIER_CLASS;
drop view INT$DBA_AVIEW_LEVEL_CLASS;
drop view INT$DBA_HIER_HIER_ATTR_CLASS;
drop view INT$DBA_HIER_HIER_ATTRIBUTES;
drop view INT$DBA_AVIEW_CLASS;
drop view INT$DBA_AVIEW_MEAS_CLASS;
drop view INT$DBA_AVIEW_DIM_CLASS;
drop view INT$DBA_ATTR_DIM;
drop view INT$DBA_ATTR_DIM_ATTRS;
drop view INT$DBA_ATTR_DIM_TABLES;
drop view INT$DBA_ATTR_DIM_LEVELS;
drop view INT$DBA_HIERARCHIES;
drop view INT$DBA_HIER_LEVELS;
drop view INT$DBA_HIER_LEVEL_ID_ATTRS;
drop view INT$DBA_HIER_COLUMNS;
drop view INT$DBA_AVIEWS;
drop view INT$DBA_AVIEW_DIMENSIONS;
drop view INT$DBA_AVIEW_CALC_MEAS;
drop view INT$DBA_AVIEW_BASE_MEAS;
drop view INT$DBA_AVIEW_KEYS;
drop view INT$DBA_AVIEW_HIERS;
drop view INT$DBA_AVIEW_COLUMNS;
drop view INT$DBA_ATTR_DIM_KEYS;
drop view INT$DBA_ATTR_DIM_LEVEL_ATTRS;
drop view INT$DBA_ATTR_DIM_JOIN_PATHS;
drop view INT$DBA_HIER_JOIN_PATHS;

-- HCS pl/sql packages, types, and library
drop public synonym DBMS_HIERARCHY;
drop package body sys.DBMS_HIERARCHY;
drop package sys.DBMS_HIERARCHY;

drop public synonym DBMS_MDX_ODBO;
drop package body sys.DBMS_MDX_ODBO;
drop package sys.DBMS_MDX_ODBO;
drop type DBMS_MDX_ODBO_KEYWORD_T force;
drop type DBMS_MDX_ODBO_KEYWORD_R force;
DROP TYPE DBMS_MDX_ODBO_FUNCTION_T force;
DROP TYPE DBMS_MDX_ODBO_FUNCTION_R force;
DROP TYPE DBMS_MDX_ODBO_PROPVAL_T force;
DROP TYPE DBMS_MDX_ODBO_PROPVAL_R force;

drop library DBMS_HCS_LIB;

-- HCS internal role for DBMS_MDX_ODBO
drop role DBMS_MDX_INTERNAL;

-- HCS MDX Schema Rowset Metadata Views
drop view mdx_odbo_cubes;
drop view mdx_odbo_dimensions;
drop view mdx_odbo_functions;
drop view mdx_odbo_hierarchies;
drop view mdx_odbo_levels;
drop view mdx_odbo_measures;
drop view mdx_odbo_properties;
drop view mdx_odbo_sets;
drop view mdx_odbo_actions;
drop view mdx_odbo_input_datasources;
drop view mdx_odbo_kpis;
drop view mdx_odbo_measuregroup_dims;
drop view mdx_odbo_measuregroups;

-- system privilege and audit options
delete from sys.system_privilege_map 
where privilege in (-399, -400, -401, -402,
                    -403, -404, -405, -406,
                    -407, -408, -409, -410);

delete from sys.stmt_audit_option_map 
where option# in (359, 360, 361,
                  399, 400, 401, 402,
                  403, 404, 405, 406,
                  407, 408, 409, 410);

delete from sys.audit$ where option# in (359, 360, 361,
                                         399, 400, 401, 402,
                                         403, 404, 405, 406,
                                         407, 408, 409, 410);

delete from sys.sysauth$ where PRIVILEGE# in (-399, -400, -401, -402,
                                              -403, -404, -405, -406,
                                              -407, -408, -409, -410);

delete from sys.aud_policy$ 
where SYSPRIV in ('CREATE ATTRIBUTE DIMENSION', 'CREATE ANY ATTRIBUTE DIMENSION',
'ALTER ANY ATTRIBUTE DIMENSION', 'DROP ANY ATTRIBUTE DIMENSION',
'CREATE HIERARCHY', 'CREATE ANY HIERARCHY',
'ALTER ANY HIERARCHY', 'DROP ANY HIERARCHY',
'CREATE ANALYTIC VIEW', 'CREATE ANY ANALYTIC VIEW',
'ALTER ANY ANALYTIC VIEW', 'DROP ANY ANALYTIC VIEW');

commit;

Rem =======================================================================
Rem END changes for Proj 47091: Analytic View Sql (HCS)
Rem =======================================================================

Rem =====================================================================
Rem BEGIN changes for bug 10173496
Rem =======================================================================

truncate table sys.wri$_segadv_attrib;

Rem =======================================================================
Rem END  changes for bug 10173496
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for Proj 47808: Transportable PDB backups
Rem =======================================================================

drop package body sys.dbms_preplugin_backup;
drop package sys.dbms_preplugin_backup;

drop type SYS.ORA$PREPLUGIN_BACKUP_MSG_T;

drop view cdb_rpp$x$kccdi;
drop public synonym cdb_rpp$x$kccdi;
truncate table rpp$x$kccdi;
drop view cdb_ropp$x$kccdi;
drop public synonym cdb_ropp$x$kccdi;
truncate table ropp$x$kccdi;
drop sequence ropp$x$kccdi_seq;

drop view cdb_rpp$x$kccdi2;
drop public synonym cdb_rpp$x$kccdi2;
truncate table rpp$x$kccdi2;
drop view cdb_ropp$x$kccdi2;
drop public synonym cdb_ropp$x$kccdi2;
truncate table ropp$x$kccdi2;
drop sequence ropp$x$kccdi2_seq;

drop view cdb_rpp$x$kccic;
drop public synonym cdb_rpp$x$kccic;
truncate table rpp$x$kccic;
drop view cdb_ropp$x$kccic;
drop public synonym cdb_ropp$x$kccic;
truncate table ropp$x$kccic;
drop sequence ropp$x$kccic_seq;

drop view cdb_rpp$x$kccpdb;
drop public synonym cdb_rpp$x$kccpdb;
truncate table rpp$x$kccpdb;
drop view cdb_ropp$x$kccpdb;
drop public synonym cdb_ropp$x$kccpdb;
truncate table ropp$x$kccpdb;
drop sequence ropp$x$kccpdb_seq;

drop view cdb_rpp$x$kcpdbinc;
drop public synonym cdb_rpp$x$kcpdbinc;
truncate table rpp$x$kcpdbinc;
drop view cdb_ropp$x$kcpdbinc;
drop public synonym cdb_ropp$x$kcpdbinc;
truncate table ropp$x$kcpdbinc;
drop sequence ropp$x$kcpdbinc_seq;

drop view cdb_rpp$x$kccts;
drop public synonym cdb_rpp$x$kccts;
truncate table rpp$x$kccts;
drop view cdb_ropp$x$kccts;
drop public synonym cdb_ropp$x$kccts;
truncate table ropp$x$kccts;
drop sequence ropp$x$kccts_seq;

drop view cdb_rpp$x$kccfe;
drop public synonym cdb_rpp$x$kccfe;
truncate table rpp$x$kccfe;
drop view cdb_ropp$x$kccfe;
drop public synonym cdb_ropp$x$kccfe;
truncate table ropp$x$kccfe;
drop sequence ropp$x$kccfe_seq;

drop view cdb_rpp$x$kccfn;
drop public synonym cdb_rpp$x$kccfn;
truncate table rpp$x$kccfn;
drop view cdb_ropp$x$kccfn;
drop public synonym cdb_ropp$x$kccfn;
truncate table ropp$x$kccfn;
drop sequence ropp$x$kccfn_seq;

drop view cdb_rpp$x$kcvdf;
drop public synonym cdb_rpp$x$kcvdf;
truncate table rpp$x$kcvdf;
drop view cdb_ropp$x$kcvdf;
drop public synonym cdb_ropp$x$kcvdf;
truncate table ropp$x$kcvdf;
drop sequence ropp$x$kcvdf_seq;

drop view cdb_rpp$x$kcctf;
drop public synonym cdb_rpp$x$kcctf;
truncate table rpp$x$kcctf;
drop view cdb_ropp$x$kcctf;
drop public synonym cdb_ropp$x$kcctf;
truncate table ropp$x$kcctf;
drop sequence ropp$x$kcctf_seq;

drop view cdb_rpp$x$kcvfh;
drop public synonym cdb_rpp$x$kcvfh;
truncate table rpp$x$kcvfh;
drop view cdb_ropp$x$kcvfh;
drop public synonym cdb_ropp$x$kcvfh;
truncate table ropp$x$kcvfh;
drop sequence ropp$x$kcvfh_seq;

drop view cdb_rpp$x$kcvfhtmp;
drop public synonym cdb_rpp$x$kcvfhtmp;
truncate table rpp$x$kcvfhtmp;
drop view cdb_ropp$x$kcvfhtmp;
drop public synonym cdb_ropp$x$kcvfhtmp;
truncate table ropp$x$kcvfhtmp;
drop sequence ropp$x$kcvfhtmp_seq;

drop view cdb_rpp$x$kcvfhall;
drop public synonym cdb_rpp$x$kcvfhall;
truncate table rpp$x$kcvfhall;
drop view cdb_ropp$x$kcvfhall;
drop public synonym cdb_ropp$x$kcvfhall;
truncate table ropp$x$kcvfhall;
drop sequence ropp$x$kcvfhall_seq;

drop view cdb_rpp$x$kccrt;
drop public synonym cdb_rpp$x$kccrt;
truncate table rpp$x$kccrt;
drop view cdb_ropp$x$kccrt;
drop public synonym cdb_ropp$x$kccrt;
truncate table ropp$x$kccrt;
drop sequence ropp$x$kccrt_seq;

drop view cdb_rpp$x$kccle;
drop public synonym cdb_rpp$x$kccle;
truncate table rpp$x$kccle;
drop view cdb_ropp$x$kccle;
drop public synonym cdb_ropp$x$kccle;
truncate table ropp$x$kccle;
drop sequence ropp$x$kccle_seq;

drop view cdb_rpp$x$kccsl;
drop public synonym cdb_rpp$x$kccsl;
truncate table rpp$x$kccsl;
drop view cdb_ropp$x$kccsl;
drop public synonym cdb_ropp$x$kccsl;
truncate table ropp$x$kccsl;
drop sequence ropp$x$kccsl_seq;

drop view cdb_rpp$x$kcctir;
drop public synonym cdb_rpp$x$kcctir;
truncate table rpp$x$kcctir;
drop view cdb_ropp$x$kcctir;
drop public synonym cdb_ropp$x$kcctir;
truncate table ropp$x$kcctir;
drop sequence ropp$x$kcctir_seq;

drop view cdb_rpp$x$kccor;
drop public synonym cdb_rpp$x$kccor;
truncate table rpp$x$kccor;
drop view cdb_ropp$x$kccor;
drop public synonym cdb_ropp$x$kccor;
truncate table ropp$x$kccor;
drop sequence ropp$x$kccor_seq;

drop view cdb_rpp$x$kcclh;
drop public synonym cdb_rpp$x$kcclh;
truncate table rpp$x$kcclh;
drop view cdb_ropp$x$kcclh;
drop public synonym cdb_ropp$x$kcclh;
truncate table ropp$x$kcclh;
drop sequence ropp$x$kcclh_seq;

drop view cdb_rpp$x$kccal;
drop public synonym cdb_rpp$x$kccal;
truncate table rpp$x$kccal;
drop view cdb_ropp$x$kccal;
drop public synonym cdb_ropp$x$kccal;
truncate table ropp$x$kccal;
drop sequence ropp$x$kccal_seq;

drop view cdb_rpp$x$kccbs;
drop public synonym cdb_rpp$x$kccbs;
truncate table rpp$x$kccbs;
drop view cdb_ropp$x$kccbs;
drop public synonym cdb_ropp$x$kccbs;
truncate table ropp$x$kccbs;
drop sequence ropp$x$kccbs_seq;

drop view cdb_rpp$x$kccbp;
drop public synonym cdb_rpp$x$kccbp;
truncate table rpp$x$kccbp;
drop view cdb_ropp$x$kccbp;
drop public synonym cdb_ropp$x$kccbp;
truncate table ropp$x$kccbp;
drop sequence ropp$x$kccbp_seq;

drop view cdb_rpp$x$kccbf;
drop public synonym cdb_rpp$x$kccbf;
truncate table rpp$x$kccbf;
drop view cdb_ropp$x$kccbf;
drop public synonym cdb_ropp$x$kccbf;
truncate table ropp$x$kccbf;
drop sequence ropp$x$kccbf_seq;

drop view cdb_rpp$x$kccbl;
drop public synonym cdb_rpp$x$kccbl;
truncate table rpp$x$kccbl;
drop view cdb_ropp$x$kccbl;
drop public synonym cdb_ropp$x$kccbl;
truncate table ropp$x$kccbl;
drop sequence ropp$x$kccbl_seq;

drop view cdb_rpp$x$kccbi;
drop public synonym cdb_rpp$x$kccbi;
truncate table rpp$x$kccbi;
drop view cdb_ropp$x$kccbi;
drop public synonym cdb_ropp$x$kccbi;
truncate table ropp$x$kccbi;
drop sequence ropp$x$kccbi_seq;

drop view cdb_rpp$x$kccdc;
drop public synonym cdb_rpp$x$kccdc;
truncate table rpp$x$kccdc;
drop view cdb_ropp$x$kccdc;
drop public synonym cdb_ropp$x$kccdc;
truncate table ropp$x$kccdc;
drop sequence ropp$x$kccdc_seq;

drop view cdb_rpp$x$kccpd;
drop public synonym cdb_rpp$x$kccpd;
truncate table rpp$x$kccpd;
drop view cdb_ropp$x$kccpd;
drop public synonym cdb_ropp$x$kccpd;
truncate table ropp$x$kccpd;

drop view cdb_rpp$x$kccpa;
drop public synonym cdb_rpp$x$kccpa;
truncate table rpp$x$kccpa;
drop view cdb_ropp$x$kccpa;
drop public synonym cdb_ropp$x$kccpa;
truncate table ropp$x$kccpa;

-- kccpd and kccpa share this sequence.
drop sequence ropp$x$kccpc_seq;

Rem =======================================================================
Rem END changes for Proj 47808: Transportable PDB backups
Rem =======================================================================

Rem =======================================================================
Rem BEGIN changes for proj 45826 (SPM plan capture improvements)
Rem =======================================================================

delete from smb$config where parameter_name like 'AUTO_CAPTURE%';
update smb$config set parameter_data = NULL;

Rem =======================================================================
Rem END  changes for proj 45826 (SPM plan capture improvements)
Rem =======================================================================


Rem *************************************************************************
Rem Service layer related changes - BEGIN
Rem *************************************************************************

update service$ set stop_option = 0;
update service$ set failover_restore = 0;
update service$ set drain_timeout = 0;
commit;

Rem *************************************************************************
Rem Service layer related changes - END
Rem *************************************************************************

Rem =======================================================================
Rem  BEGIN changes for Thin Provisioning bug 20312104
Rem =======================================================================

drop procedure dbms_feature_thp;

Rem =======================================================================
Rem  END changes for Thin Provisioning bug 20312104
Rem =======================================================================

Rem =======================================================================
Rem  BEGIN changes for Flex ASM bug 20312104
Rem =======================================================================

drop procedure dbms_feature_flex_asm;

Rem =======================================================================
Rem  END changes for Flex ASM bug 20312104
Rem =======================================================================


Rem ====================================================================
Rem Begin changes for lrg 12680989 and Bug 21350392
Rem ====================================================================

drop public synonym DBA_XML_NESTED_TABLES;
drop view DBA_XML_NESTED_TABLES;
drop public synonym CDB_XML_NESTED_TABLES;
drop view CDB_XML_NESTED_TABLES;
drop public synonym DBA_XML_OUT_OF_LINE_TABLES;
drop view DBA_XML_OUT_OF_LINE_TABLES;
drop public synonym CDB_XML_OUT_OF_LINE_TABLES;
drop view CDB_XML_OUT_OF_LINE_TABLES;
drop public synonym DBA_XML_TABLES;
drop view DBA_XML_TABLES;
drop public synonym CDB_XML_TABLES;
drop view CDB_XML_TABLES;
drop public synonym DBA_XML_TAB_COLS;
drop view DBA_XML_TAB_COLS;
drop public synonym CDB_XML_TAB_COLS;
drop view CDB_XML_TAB_COLS;

Rem ====================================================================
Rem End changes for lrg 12680989 and Bug 21350392
Rem ====================================================================

Rem ************************************************************************
Rem Changes for Cloud HCC feature tracking - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_cloud_ehcc;

Rem ************************************************************************
Rem Changes for Cloud HCC feature tracking  - END
Rem ************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for Project 45958 - ADO for DBIM
Rem *************************************************************************

drop sequence sys.ado_imcseq$;

alter table sys.heat_map_stat$ drop column n_write;
alter table sys.heat_map_stat$ drop column n_fts;
alter table sys.heat_map_stat$ drop column n_lookup;

alter table sys.ilmpolicy$ drop column tier_to;
alter table sys.ilmpolicy$ drop column actionc_clob;
alter table sys.ilmpolicy$ drop column pol_subtype;

truncate table sys.ado_imsegtaskdetails$;
truncate table sys.ado_imtasks$;
truncate table sys.ado_imsegstat$;
truncate table sys.ado_imstat$;

drop public synonym gv$im_adoelements;
drop view  gv_$im_adoelements;

drop public synonym v$im_adoelements;
drop view  v_$im_adoelements;

drop public synonym gv$im_adotasks;
drop view  gv_$im_adotasks;

drop public synonym v$im_adotasks;
drop view  v_$im_adotasks;

drop public synonym gv$im_adotaskdetails;
drop view  gv_$im_adotaskdetails;

drop public synonym v$im_adotaskdetails;
drop view  v_$im_adotaskdetails;

Rem *************************************************************************
Rem END Changes for  Project 45958 - ADO for DBIM
Rem *************************************************************************
  
Rem *************************************************************************
Rem Statistics Encryption Project (New Views)- BEGIN 
Rem Project# 49581
Rem *************************************************************************

drop view SYS."_HIST_HEAD_DEC";
drop view SYS."_HISTGRM_DEC";

drop view SYS."_OPTSTAT_HISTHEAD_HISTORY_DEC";
drop view SYS."_OPTSTAT_HISTGRM_HISTORY_DEC";

drop package sys.dbms_crypto_internal;

drop library crypto_internal_lib;

update hist_head$ set minimum_enc = null;
update hist_head$ set maximum_enc = null;
update histgrm$ set endpoint_enc = null;
commit;

update wri$_optstat_histhead_history set minimum_enc = null;
update wri$_optstat_histhead_history set maximum_enc = null;
update wri$_optstat_histgrm_history set endpoint_enc = null;
commit;

Rem *************************************************************************
Rem Statistics Encryption Project (New Views) - END 
Rem *************************************************************************
 
Rem *************************************************************************
Rem DBFS support for POSIX locking - BEGIN
Rem *************************************************************************

truncate table sys.dbfs$_clients;

Rem *************************************************************************
Rem DBFS support for POSIX locking - END
Rem *************************************************************************

Rem *************************************************************************
Rem cdb_file$, cdb_ts$ related changes - BEGIN
Rem *************************************************************************

alter table cdb_file$ drop column ts#;
alter table cdb_file$ drop column relfile#;
alter table cdb_file$ drop column cscnwrp;
alter table cdb_file$ drop column cscnbas;
alter table cdb_file$ drop column spare5;
alter table cdb_file$ drop column spare6;
alter table cdb_file$ drop column src_afn;
alter table cdb_file$ drop column tgt_afn;
alter table cdb_file$ drop column status;
alter table cdb_file$ drop column flags;
alter table cdb_file$ drop column blks;
alter table cdb_file$ drop column spare7;
alter table cdb_file$ drop column spare8;
alter table cdb_file$ drop column spare9;
alter table cdb_file$ drop column spare10;
alter table cdb_file$ drop column spare11;
alter table cdb_file$ drop column spare12;

truncate table cdb_ts$;

Rem *************************************************************************
Rem cdb_file$, cdb_ts$ related changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Begin revoke 12.2 change to partobj$
Rem *************************************************************************
update partobj$ set subptn_interval_str = NULL;
update partobj$ set subptn_interval_bival = NULL;
commit;
Rem *************************************************************************
Rem End revoke 12.2 change to partobj$
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 20606723: Clear read only flag for partitioned table
Rem *************************************************************************
update partobj$ po
  set po.flags = po.flags - 65536
  where bitand(po.flags, 65536) != 0;

update tabpart$ tp
  set tp.flags = tp.flags - 67108864
  where bitand(tp.flags, 67108864) != 0;

update tabsubpart$ tsp
  set tsp.flags = tsp.flags - 67108864
  where bitand(tsp.flags, 67108864) != 0;

commit;
Rem *************************************************************************
Rem END Bug 20606723
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 17854208: Clear diagnostic columns in SQL translation table
Rem *************************************************************************

update sqltxl_sql$ set errcode# = null, errsrc = null, txlmthd = null,
  dictid = null;

commit;

Rem *************************************************************************
Rem END Bug 17854208
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Changes for [G]V$QUARANTINE
Rem =======================================================================

drop public synonym gv$quarantine;
drop view gv_$quarantine;
drop public synonym v$quarantine;
drop view v_$quarantine;

Rem =======================================================================
Rem END Changes for [G]V$QUARANTINE
Rem =======================================================================

Rem =======================================================================
Rem Kernel column-level statistics tables & views
Rem =======================================================================
truncate table column_stat$;

Rem drop column-level statistics views and synonyms
drop public synonym DBA_COL_USAGE_STATISTICS;
drop view DBA_COL_USAGE_STATISTICS;
drop public synonym CDB_COL_USAGE_STATISTICS;
drop view CDB_COL_USAGE_STATISTICS;

Rem drop column-level statistics real-time views and synonyms
drop view gv_$column_statistics;
drop public synonym gv$column_statistics;

drop view v_$column_statistics;
drop public synonym v$column_statistics;
 
Rem *************************************************************************
Rem BEGIN Proj 57436
Rem *************************************************************************
-- delete entries in HLL format 
delete from wri$_optstat_synopsis_head$
where spare1 = 1;

alter table wri$_optstat_synopsis_head$ drop column spare2;

alter table wri$_optstat_synopsis_head$ add spare2 clob;

Rem *************************************************************************
Rem END Proj 57436
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 20652654
Rem *************************************************************************

-- drop rows which have names longer than 64
delete from wri$_dbu_feature_usage where length(name) > 64;
delete from wri$_dbu_feature_metadata where length(name) > 64;
delete from wri$_dbu_high_water_mark where length(name) > 64;
delete from wri$_dbu_hwm_metadata where length(name) > 64;
commit;

alter table wri$_dbu_feature_usage modify name varchar2(64);
alter table wri$_dbu_feature_metadata modify name varchar2(64);
alter table wri$_dbu_high_water_mark modify name varchar2(64);
alter table wri$_dbu_hwm_metadata modify name varchar2(64);

Rem *************************************************************************
Rem END Bug 20652654
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Bug 20688138: [G]V$FS_FAILOVER_OBSERVERS
Rem =======================================================================

drop public synonym v$fs_failover_observers;
drop view v_$fs_failover_observers;
drop public synonym gv$fs_failover_observers;
drop view gv_$fs_failover_observers;

Rem =======================================================================
Rem END Bug 20688138: [G]V$FS_FAILOVER_OBSERVERS
Rem =======================================================================

Rem BEGIN Proj 47082: External tables
Rem *************************************************************************
drop view USER_XTERNAL_PART_TABLES;
drop view ALL_XTERNAL_PART_TABLES;
drop view DBA_XTERNAL_PART_TABLES;
drop view CDB_XTERNAL_PART_TABLES;
drop view USER_XTERNAL_TAB_PARTITIONS;
drop view ALL_XTERNAL_TAB_PARTITIONS;
drop view DBA_XTERNAL_TAB_PARTITIONS;
drop view CDB_XTERNAL_TAB_PARTITIONS;
drop view USER_XTERNAL_TAB_SUBPARTITIONS;
drop view ALL_XTERNAL_TAB_SUBPARTITIONS;
drop view DBA_XTERNAL_TAB_SUBPARTITIONS;
drop view CDB_XTERNAL_TAB_SUBPARTITIONS;
drop view USER_XTERNAL_LOC_PARTITIONS;
drop view ALL_XTERNAL_LOC_PARTITIONS;
drop view DBA_XTERNAL_LOC_PARTITIONS;
drop view CDB_XTERNAL_LOC_PARTITIONS;
drop view USER_XTERNAL_LOC_SUBPARTITIONS;
drop view ALL_XTERNAL_LOC_SUBPARTITIONS;
drop view DBA_XTERNAL_LOC_SUBPARTITIONS;
drop view CDB_XTERNAL_LOC_SUBPARTITIONS;

drop public synonym USER_XTERNAL_PART_TABLES;
drop public synonym ALL_XTERNAL_PART_TABLES;
drop public synonym DBA_XTERNAL_PART_TABLES;
drop public synonym CDB_XTERNAL_PART_TABLES;
drop public synonym USER_XTERNAL_TAB_PARTITIONS;
drop public synonym ALL_XTERNAL_TAB_PARTITIONS;
drop public synonym DBA_XTERNAL_TAB_PARTITIONS;
drop public synonym CDB_XTERNAL_TAB_PARTITIONS;
drop public synonym USER_XTERNAL_TAB_SUBPARTITIONS;
drop public synonym ALL_XTERNAL_TAB_SUBPARTITIONS;
drop public synonym DBA_XTERNAL_TAB_SUBPARTITIONS;
drop public synonym CDB_XTERNAL_TAB_SUBPARTITIONS;
drop public synonym USER_XTERNAL_LOC_PARTITIONS;
drop public synonym ALL_XTERNAL_LOC_PARTITIONS;
drop public synonym DBA_XTERNAL_LOC_PARTITIONS;
drop public synonym CDB_XTERNAL_LOC_PARTITIONS;
drop public synonym USER_XTERNAL_LOC_SUBPARTITIONS;
drop public synonym ALL_XTERNAL_LOC_SUBPARTITIONS;
drop public synonym DBA_XTERNAL_LOC_SUBPARTITIONS;
drop public synonym CDB_XTERNAL_LOC_SUBPARTITIONS;
alter table external_tab$ modify default_dir varchar2(128) not null;
alter table external_tab$ modify type$ varchar2(128) not null;

Rem *************************************************************************
Rem END Proj 47082:  External tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 20652654: long identifier support:  revert column size 
Rem *************************************************************************

alter table SYS.REGISTRY$ modify (vproc varchar2(61));

Rem *************************************************************************
Rem END Bug 20652654: long identifier support: revert column size
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj 58950,42356-3: New INMEMORY syntax - FOR SERVICE, ORDER BY
Rem *************************************************************************
truncate table imsvc$;
truncate table imsvcts$;
truncate table imorderby$;
Rem *************************************************************************
Rem END Proj 58950,42356-3: New INMEMORY syntax - FOR SERVICE, ORDER BY
Rem *************************************************************************

Rem *************************************************************************
Rem pdb_create$ changes  - BEGIN
Rem *************************************************************************
truncate table pdb_create$;
Rem *************************************************************************
Rem pdb_create$ changes  - END
Rem *************************************************************************

Rem *************************************************************************
Rem DBMS support for TNS - BEGIN
Rem *************************************************************************

drop package sys.dbms_tns;
drop library dbms_tns_lib;
drop public synonym DBMS_TNS;

Rem *************************************************************************
Rem DBMS support for TNS  - END
Rem *************************************************************************

Rem *************************************************************************
Rem Project 46762 DBLINK Enhancements - BEGIN
Rem *************************************************************************

drop view DBA_DB_LINK_SOURCES;
drop view DBA_EXTERNAL_SCN_ACTIVITY;
drop public synonym DBA_DB_LINK_SOURCES;
drop public synonym DBA_EXTERNAL_SCN_ACTIVITY;
drop view CDB_DB_LINK_SOURCES;
drop public synonym CDB_DB_LINK_SOURCES;
drop view CDB_EXTERNAL_SCN_ACTIVITY;
drop public synonym CDB_EXTERNAL_SCN_ACTIVITY;
drop index link_sources$_ui;
drop index link_sources$_usrnm_idx;
drop index link_logons$_srcid_idx;
alter table link_logons$ drop constraint fk_srcid;
truncate table LINK_SOURCES$;
truncate table LINK_LOGONS$;
truncate table EXTERNAL_SCN_ACTIVITY$;
drop sequence link_source_id_seq;

Rem *************************************************************************
Rem Project 46762 DBLINK Enhancements  - END
Rem *************************************************************************

Rem =======================================================================
Rem  BEGIN changes for ASM Filter driver (AFD) bug 20877328
Rem =======================================================================

drop procedure dbms_feature_afd;

Rem =======================================================================
Rem  END changes for ASM Filter driver (AFD) bug 20877328
Rem =======================================================================

Rem ********************************************************************
Rem Begin Materialized View changes
Rem ********************************************************************

update mv_refresh_usage_stats$ set seq# = 0;
commit;

drop view mv_refresh_usage_stats;

drop sequence sys.mv_rf$usagestatseq;

Rem ********************************************************************
Rem End Materialized View changes
Rem ********************************************************************

Rem *************************************************************************
Rem BEGIN Proj 46675: Global Dictionary Join Groups
Rem *************************************************************************

truncate table im_domain$;
truncate table im_joingroup$;
drop sequence im_domainseq$;
 
Rem *************************************************************************
Rem END Proj 46675: Global Dictionary Join Groups
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 20511242: revert long identifier support
Rem *************************************************************************

alter table sys.audtab$tbs$for_export_tbl modify(owner varchar2(30));
alter table sys.audtab$tbs$for_export_tbl modify(name varchar2(30));

Rem *************************************************************************
Rem End Bug 20511242
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 20511352: revert long identifier support
Rem *************************************************************************

alter table sys.dba_sensitive_data_tbl modify(schema_name varchar2(30));
alter table sys.dba_sensitive_data_tbl modify(table_name varchar2(30));
alter table sys.dba_sensitive_data_tbl modify(column_name varchar2(30));

alter table sys.dba_tsdp_policy_protection_tbl modify(schema_name varchar2(30));
alter table sys.dba_tsdp_policy_protection_tbl modify(table_name varchar2(30));
alter table sys.dba_tsdp_policy_protection_tbl modify(column_name varchar2(30));

Rem *************************************************************************
Rem End Bug 20511352
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 20867498: long ids

Rem  Instead of altering type ket$_window_type, attribute window_name back to
Rem  varchar2(30), we'll drop the type; the "old" catatsk.sql will recreate it.
DROP TYPE ket$_window_list;
DROP TYPE ket$_window_type;

UPDATE wri$_sts_granules
SET    sqlset_owner = substr(sqlset_owner,1,30)
WHERE  length(sqlset_owner) > 30;
COMMIT;
ALTER TABLE wri$_sts_granules MODIFY sqlset_owner VARCHAR2(30);

UPDATE wrh$_iostat_function_name
SET    function_name = substr(function_name,1,30)
WHERE  length(function_name) > 30;
COMMIT;
ALTER TABLE wrh$_iostat_function_name MODIFY function_name VARCHAR2(30);

Rem END bug 20867498: long ids
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 21497629: long ids

ALTER TABLE wrh$_buffered_queues
  MODIFY queue_schema VARCHAR2(30)
  MODIFY queue_name   VARCHAR2(30)
;
ALTER TABLE wrh$_rsrc_consumer_group
  MODIFY consumer_group_name VARCHAR2(30)
;
ALTER TABLE wri$_adv_def_parameters
  MODIFY name      VARCHAR2(30)
  MODIFY exec_type VARCHAR2(30)
;
ALTER TABLE wri$_adv_def_exec_types
  MODIFY name VARCHAR2(30)
;
ALTER TABLE wri$_adv_executions
  MODIFY name      VARCHAR2(30)
  MODIFY exec_type VARCHAR2(30)
;
ALTER TABLE wri$_sqlset_definitions
  MODIFY name  VARCHAR2(30)
  MODIFY owner VARCHAR2(30)
;
ALTER TABLE wri$_sqlset_statements
  MODIFY parsing_schema_name VARCHAR2(30)
;
ALTER TABLE wri$_sqlset_plans
  MODIFY parsing_schema_name VARCHAR2(30)
;
ALTER TABLE wri$_sqlset_plan_lines
  MODIFY statement_id VARCHAR2(30)
  MODIFY operation    VARCHAR2(30)
  MODIFY object_owner VARCHAR2(30)
  MODIFY object_name  VARCHAR2(30)
  MODIFY object_alias VARCHAR2(65)
  MODIFY object_type  VARCHAR2(30)
  MODIFY distribution VARCHAR2(30)
  MODIFY qblock_name  VARCHAR2(30)
;
Rem END bug 21497629: long ids
Rem *************************************************************************

rem Proj 47117
rem this index was dropped during upgrade. recreate it on downgrade
create unique index pk_rmtab$ on rmtab$ (obj#);
rem this table was created during upgrade. truncate it on downgrade
truncate table online_hidden_frags$;
rem end Proj 47117

Rem *************************************************************************
Rem  BEGIN Bug 20984580: Drop Private_jdbc
Rem *************************************************************************

DROP PUBLIC SYNONYM PRIVATE_JDBC;
DROP PACKAGE PRIVATE_JDBC;
DROP PACKAGE PRIVATE_JDBC_DR;

Rem *************************************************************************
Rem  END Bug 20984580: Drop Private_jdbc
Rem *************************************************************************

Rem *************************************************************************
Rem  BEGIN #21165620: Drop Views for expression usage tracking
Rem *************************************************************************

-- dropping dba views
drop public synonym dba_expression_statistics;
drop view dba_expression_statistics;
drop public synonym all_expression_statistics;
drop view all_expression_statistics;
drop public synonym user_expression_statistics;
drop view user_expression_statistics;
drop public synonym cdb_expression_statistics;
drop view cdb_expression_statistics;

-- dropping (g)v$ views
drop public synonym gv$exp_stats;
drop view gv_$exp_stats;

drop public synonym v$exp_stats;
drop view v_$exp_stats;

Rem *************************************************************************
Rem  End #21165620
Rem *************************************************************************

Rem *************************************************************************
Rem  BEGIN Bug 21069796: Drop DBMS_PLSQL_CODE_COVERAGE
Rem *************************************************************************

DROP PUBLIC SYNONYM DBMS_PLSQL_CODE_COVERAGE;
DROP LIBRARY DBMS_PLSQL_CODE_COVERAGE_LIB;
DROP PACKAGE DBMS_PLSQL_CODE_COVERAGE;

Rem *************************************************************************
Rem  END Bug 21069796: Drop DBMS_PLSQL_CODE_COVERAGE
Rem *************************************************************************

Rem *************************************************************************
Rem  BEGIN Bug 21068213: Drop shadow Types
Rem *************************************************************************

declare
  cursor c1 is
    select u.name, o.name
    from sys.type$ t, sys.obj$ o, sys.user$ u
    where o.type# = 13
          and bitand(t.properties, 2048) = 2048 
          and o.oid$ = t.toid
          and o.owner# = u.user#
          and o.name like 'SYS_PLSQL_%';
  type_owner   varchar2(128);
  type_name    varchar2(128);
begin
  -- Drop system generated shadow Types
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
Rem  END Bug 21068213: Drop shadow Types
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 20897609 
Rem *************************************************************************

-- delete role XSCONNECT
declare
  role_id number;
begin
  select id into role_id from sys.xs$obj where name = 'XSCONNECT';
  delete from sys.xs$prin where prin#=role_id;
  delete from sys.xs$obj where id=role_id;
exception
  when others then
    null;
end;
/

-- drop role xs_connect
BEGIN
EXECUTE IMMEDIATE 'DROP ROLE xs_connect';
EXCEPTION
WHEN others THEN
IF sqlcode = -1919 THEN NULL;
-- suppress error for non-existent role for earlier versions
ELSE raise;
END IF;
END;
/
commit;

Rem *************************************************************************
Rem End Bug 20897609
Rem *************************************************************************

Rem *************************************************************************
Rem Project 47411: Local Temporary Tablespaces - BEGIN
Rem *************************************************************************

drop public synonym dbms_space_alert;
drop package sys.dbms_space_alert;
drop library dbms_space_alert_LIB;

drop public synonym V$TEMPFILE_INFO_INSTANCE;
drop view V_$TEMPFILE_INFO_INSTANCE;

drop public synonym GV$TEMPFILE_INFO_INSTANCE;
drop view GV_$TEMPFILE_INFO_INSTANCE;

Rem *************************************************************************
Rem Project 47411: Local Temporary Tablespaces - END
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 20663978
Rem *************************************************************************
-- drop column rec_type_id
update wri$_adv_recommendations set rec_type_id = NULL;

-- dropping (g)v$ views for dml stats
drop public synonym gv$dml_stats;
drop view gv_$dml_stats;

drop public synonym v$dml_stats;
drop view v_$dml_stats;

Rem *************************************************************************
Rem End Bug 20663978
Rem *************************************************************************

Rem =======================================================================
Rem  BEGIN changes for ACFS bug 21693658
Rem =======================================================================

drop procedure dbms_feature_acfs;

Rem =======================================================================
Rem  END changes for ACFS bug 21693658
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN BUG 21548817: UTS FIXED VIEWS
Rem *************************************************************************

drop role APPLICATION_TRACE_VIEWER;

drop public synonym gv$diag_trace_file;
drop view gv_$diag_trace_file;

drop public synonym v$diag_trace_file;
drop view v_$diag_trace_file;

drop public synonym gv$diag_app_trace_file;
drop view gv_$diag_app_trace_file;

drop public synonym v$diag_app_trace_file;
drop view v_$diag_app_trace_file;

drop public synonym gv$diag_trace_file_contents;
drop view gv_$diag_trace_file_contents;

drop public synonym v$diag_trace_file_contents;
drop view v_$diag_trace_file_contents;

drop public synonym gv$diag_sql_trace_records;
drop view gv_$diag_sql_trace_records;

drop public synonym v$diag_sql_trace_records;
drop view v_$diag_sql_trace_records;

drop public synonym gv$diag_opt_trace_records;
drop view gv_$diag_opt_trace_records;

drop public synonym v$diag_opt_trace_records;
drop view v_$diag_opt_trace_records;

drop public synonym v$diag_sess_sql_trace_records;
drop view v_$diag_sess_sql_trace_records;

drop public synonym v$diag_sess_opt_trace_records;
drop view v_$diag_sess_opt_trace_records;

Rem *************************************************************************
Rem END BUG 21548817: UTS FIXED VIEWS
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 21757266: public synonyms
Rem *************************************************************************

drop public synonym dba_analyze_objects;
drop public synonym cdb_analyze_objects;
drop public synonym dba_keepsizes;
drop public synonym cdb_keepsizes;

Rem *************************************************************************
Rem End Bug 21757266: public synonyms
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 17169333
Rem *************************************************************************
-- drop TRANSLATE SQL audit action
delete from audit_actions where action = 237;
commit;

Rem *************************************************************************
Rem End Bug 17169333
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN pdb_stat$, pdb_svc_state$ related changes
Rem *************************************************************************
truncate table pdb_stat$;
truncate table pdb_svc_state$;
Rem *************************************************************************
Rem END pdb_stat$, pdb_svc_state$ related changes
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 16574456
Rem *************************************************************************
drop public synonym v$passwordfile_info;
drop view v_$passwordfile_info;

drop public synonym gv$passwordfile_info;
drop view gv_$passwordfile_info;

Rem *************************************************************************
Rem End bug 16574456
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 22468424
Rem *************************************************************************
drop public synonym v$diag_pdb_problem;
drop view v_$diag_pdb_problem;

drop public synonym v$diag_vpdb_problem;
drop view v_$diag_vpdb_problem;

Rem *************************************************************************
Rem End bug 22468424
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 23192127
Rem *************************************************************************
drop public synonym v$diag_pdb_space_mgmt;
drop view v_$diag_pdb_space_mgmt;

Rem *************************************************************************
Rem End bug 23192127
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 22531564
Rem *************************************************************************
UPDATE sys.snap$ s SET s.flag4 = 0;
COMMIT;

Rem *************************************************************************
Rem End bug 22531564
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 22558274
Rem *************************************************************************

drop package DBMS_RLS_INT;

Rem *************************************************************************
Rem End bug 22558274
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 22275536: DEBUG CONNECT audit action
Rem *************************************************************************
-- drop DEBUG CONNECT audit action
delete from audit_actions where action = 221;
delete from stmt_audit_option_map where option# = 367;
commit;

Rem *************************************************************************
Rem End Bug 22275536
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 22325328: DEBUG PROCEDURE audit action
Rem *************************************************************************
-- drop DEBUG PROCEDURE audit action
delete from audit_actions where action = 223;
commit;

Rem *************************************************************************
Rem End Bug 22325328
Rem *************************************************************************

Rem *************************************************************************
Rem User Privileges related changes for 12.2 - BEGIN
Rem *************************************************************************

delete from user_privilege_map where privilege in (3);
commit;

Rem *************************************************************************
Rem User Privileges related changes for 12.2 - END
Rem *************************************************************************

Rem =======================================================================
Rem  BEGIN changes for ACFS bug 22498132
Rem =======================================================================

drop procedure dbms_feature_acfs_snapshot;

Rem =======================================================================
Rem  END changes for ACFS bug 22498132
Rem =======================================================================

Rem *************************************************************************
Rem Begin bug 22568831
Rem *************************************************************************

drop public synonym user_joingroups;
drop view user_joingroups;

drop public synonym dba_joingroups;
drop view dba_joingroups;

drop public synonym cdb_joingroups;
drop view cdb_joingroups;

Rem *************************************************************************
Rem End bug 22568831
Rem *************************************************************************

Rem *************************************************************************
Rem Begin RTI 18548742
Rem       Bug 24617642: public synonyms don't exist in 12.1.0.2
Rem *************************************************************************

declare
  prev_version  varchar2(30);
begin
  select prv_version into prev_version from registry$
  where cid = 'CATPROC';
  execute immediate 'drop public synonym CDB_FLASHBACK_TXN_STATE';
  execute immediate 'drop public synonym CDB_FLASHBACK_TXN_REPORT';
  if prev_version < '12.1.0.2' then
    execute immediate 'drop view CDB_FLASHBACK_TXN_STATE';
    execute immediate 'drop view CDB_FLASHBACK_TXN_REPORT';
  end if;
end;
/

Rem *************************************************************************
Rem End RTI 18548742
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 21814782
Rem *************************************************************************

grant SELECT on SYSTEM_PRIVILEGE_MAP to PUBLIC with grant option;
grant SELECT on TABLE_PRIVILEGE_MAP to PUBLIC with grant option;
grant SELECT on USER_PRIVILEGE_MAP to PUBLIC with grant option;
grant SELECT on STMT_AUDIT_OPTION_MAP to PUBLIC;

Rem *************************************************************************
Rem End Bug 21814782
Rem *************************************************************************

Rem =======================================================================
Rem  BEGIN changes for ACFS Encryption bug X
Rem =======================================================================

drop procedure dbms_feature_acfs_encr;

Rem =======================================================================
Rem  END changes for ACFS Encryption bug X
Rem =======================================================================


Rem*************************************************************************
Rem BEGIN Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem In 12.2 we track each external table invocation by access driver:
Rem dbms_feature_utilities4 = ORACLE_DATAPUMP
Rem dbms_feature_utilities5 = ORACLE_LOADER 
Rem dbms_feature_utilities6 = ORACLE_BIGSQL
Rem
Rem Note: dbms_feature_utilities4 was the old version of feature tracking
Rem       which counted all external table invocations as a single feature.
Rem       Don't need to drop the dbms_feature_utilities4 procedure here as it
Rem       will be reloaded as part of the downgrade/upgrade process.
Rem
drop procedure dbms_feature_utilities5;
drop procedure dbms_feature_utilities6;

Rem*************************************************************************
Rem END Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN cdb_props$ changes
Rem *************************************************************************

truncate table cdb_props$;

Rem *************************************************************************
Rem END cdb_props$ changes
Rem *************************************************************************

Rem =======================================================================
Rem  Begin 12.2 Changes for Project 57189 Inherit Remote Privileges 
Rem =======================================================================

delete from SYSTEM_PRIVILEGE_MAP where PRIVILEGE in (-365);
delete from user_privilege_map where privilege in (2);
delete from sys.stmt_audit_option_map  where option# in (365, 366);
commit;

Rem =======================================================================
Rem  End 12.2 Changes for Project 57189 Inherit Remote Privileges 
Rem =======================================================================

Rem *************************************************************************
Rem Begin RTI 18916476
Rem *************************************************************************

drop view sql$text_datapump;
drop view sqlobj$plan_datapump;
drop view sqlobj$data_datapump;
drop view sqlobj$auxdata_datapump;

Rem *************************************************************************
Rem End RTI 18916476
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 22367092 truncate svcobj*$ tables
Rem *************************************************************************
truncate table svcobj$;
truncate table svcobj_access$;
truncate table svcobj_access_attr$;
Rem *************************************************************************
Rem END BUG 22367092
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23061990 
Rem *************************************************************************
Rem 12.1 has bit 40 of spare2 overloaded: used for both 
Rem KKPACOCD_INDCMP_OLTPLOW and KKPACOCD_IMC_ENABLED flags.
Rem For indexes, move bit 32 of spare3 to bit 40 of spare2
UPDATE partobj$ SET spare2 = spare2 + 1099511627776,
                    spare3 = spare3 - 4294967296
                WHERE obj# IN (SELECT obj# FROM obj$ WHERE type# = 1)
                      and MOD(TRUNC(spare3/4294967296), 2) = 1;
COMMIT;
Rem *************************************************************************
Rem END BUG 23061990
Rem *************************************************************************

Rem =====================================================================
Rem Begin Bug 23254735 changes
Rem =====================================================================

ALTER TABLE sys.profname$ DROP COLUMN SPARE5;
ALTER TABLE sys.profname$ DROP COLUMN SPARE4;
ALTER TABLE sys.profname$ DROP COLUMN SPARE3;
ALTER TABLE sys.profname$ DROP COLUMN SPARE2;
ALTER TABLE sys.profname$ DROP COLUMN SPARE1;
ALTER TABLE sys.profname$ DROP COLUMN MODPATCHID;
ALTER TABLE sys.profname$ DROP COLUMN MODVERID;
ALTER TABLE sys.profname$ DROP COLUMN MODAPPID;
ALTER TABLE sys.profname$ DROP COLUMN CREPATCHID;
ALTER TABLE sys.profname$ DROP COLUMN CREVERID;
ALTER TABLE sys.profname$ DROP COLUMN CREAPPID;

Rem =====================================================================
Rem End Bug 23254735 changes
Rem =====================================================================

Rem *************************************************************************
Rem Begin bug 23177430: Drop In-Memory Expression Views
Rem *************************************************************************

drop public synonym user_im_expressions;
drop view user_im_expressions;

drop public synonym dba_im_expressions;
drop view dba_im_expressions;

Rem *************************************************************************
Rem End bug 23177430
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23300354 - remove HWM and flags column values in pdb_spfile$
Rem *************************************************************************
update pdb_spfile$ set
db_uniq_name=(select sys_context('userenv', 'DB_UNIQUE_NAME') from dual)
where db_uniq_name='*';
Rem Set HWM value to 0
update pdb_spfile$ set spare1=0;
Rem Delete deleted rows and reset flags to 0
delete from pdb_spfile$ where bitand(nvl(spare2,0),1) = 1;
update pdb_spfile$ set spare2=0;
commit;

Rem *************************************************************************
Rem END BUG 23300354
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN unfix bug23335364,23340322,23476009,23475567:drop cube advise views
Rem *************************************************************************
Rem dropping these views invalidates current dbms_cube_advise package

drop view COAD$MVIEWS_WITH_VIEWS;
drop view COAD$CUBE_MVIEWS;
drop view COAD$INLINE_NOTNULL_CONS;

Rem *************************************************************************
Rem END unfix bug 23335364, 23340322, 23476009, 23475567: 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 19462491
Rem *************************************************************************
drop package dbms_preup;
Rem *************************************************************************
Rem END RTI 19462491
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23568914
Rem *************************************************************************

drop package dbms_sync_refresh_internal;
drop package dbms_mview_stats_internal;

Rem *************************************************************************
Rem END BUG 23568914
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 17036448 drop dbms_heat_map_internal
Rem *************************************************************************
drop package dbms_heat_map_internal;

Rem *************************************************************************
Rem END BUG 17036448
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 22852060 clear COMMON privilege bits if connected to a non-CDB
Rem *************************************************************************
DECLARE
  is_cdb  sys.v$database.cdb%type;
BEGIN
  select cdb into is_cdb from v$database;
  if is_cdb = 'NO' then
    -- in objauth$.option$ 4 indicates that a privilege was granted commonly 
    -- but not locally while 8 indicates that it was granted both commonly 
    -- and locally
    update sys.objauth$ set option$ = option$ - bitand(option$, 12)
      where bitand(option$, 12) != 0;

    -- in sysauth$.option$ 4 indicates that a privilege was granted commonly 
    -- but not locally while 8 indicates that it was granted both commonly 
    -- and locally
    update sys.sysauth$ set option$ = option$ - bitand(option$, 12)
      where bitand(option$, 12) != 0;

    commit;
  end if;
END;
/

Rem *************************************************************************
Rem END BUG 22852060
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 23515378: revoke read on audit views - START
Rem *************************************************************************
Rem Following changes are related to the views in catamgt.sql, cataudit.sql, 
Rem catfga.sql, catuat.sql, cdfixed.sql, rxsviews.sql

DECLARE
  stmt VARCHAR2(100);
  TYPE obj_name_list IS VARRAY(100) OF VARCHAR2(64);
  views_list obj_name_list;
BEGIN
  -- Make a list of views for revoking read privilege later
  views_list := obj_name_list('DBA_AUDIT_MGMT_CONFIG_PARAMS', 
                              'CDB_AUDIT_MGMT_CONFIG_PARAMS',
                              'DBA_AUDIT_MGMT_LAST_ARCH_TS',
                              'CDB_AUDIT_MGMT_LAST_ARCH_TS',
                              'DBA_AUDIT_MGMT_CLEANUP_JOBS',
                              'CDB_AUDIT_MGMT_CLEANUP_JOBS',
                              'DBA_AUDIT_MGMT_CLEAN_EVENTS',
                              'CDB_AUDIT_MGMT_CLEAN_EVENTS',
                              'DBA_AUDIT_TRAIL',
                              'CDB_AUDIT_TRAIL',
                              'AUDIT_UNIFIED_POLICIES',
                              'AUDIT_UNIFIED_ENABLED_POLICIES',
                              'AUDIT_UNIFIED_CONTEXTS',
                              'AUDIT_UNIFIED_POLICY_COMMENTS',
                              'DBA_FGA_AUDIT_TRAIL',
                              'CDB_FGA_AUDIT_TRAIL',
                              'DBA_COMMON_AUDIT_TRAIL',
                              'CDB_COMMON_AUDIT_TRAIL',
                              'UNIFIED_AUDIT_TRAIL',
                              'CDB_UNIFIED_AUDIT_TRAIL',
                              'DBA_XS_AUDIT_TRAIL',
                              'CDB_XS_AUDIT_TRAIL',
                              'gv_$asm_audit_clean_events',
                              'v_$asm_audit_clean_events',
                              'gv_$asm_audit_cleanup_jobs',
                              'v_$asm_audit_cleanup_jobs',
                              'gv_$asm_audit_config_params',
                              'v_$asm_audit_config_params',
                              'gv_$asm_audit_last_arch_ts',
                              'v_$asm_audit_last_arch_ts',
                              'v_$unified_audit_trail',
                              'gv_$unified_audit_trail',
                              'v_$unified_audit_record_format',
                              'DBA_XS_AUDIT_POLICY_OPTIONS',
                              'CDB_XS_AUDIT_POLICY_OPTIONS',
                              'DBA_XS_ENABLED_AUDIT_POLICIES',
                              'CDB_XS_ENABLED_AUDIT_POLICIES');

  -- Loop through all the views in the list and revoke read privilege
  FOR i IN views_list.first..views_list.last
  LOOP
    BEGIN
      -- Revoke read privilege from audit_admin
      stmt := 'REVOKE READ ON SYS.' || views_list(i) || ' FROM audit_admin';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    BEGIN
      -- Revoke read privilege from audit_viewer
      stmt := 'REVOKE READ ON SYS.' || views_list(i) || ' FROM audit_viewer';
      EXECUTE IMMEDIATE stmt;

      EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
  END LOOP;

END;
/

Rem *************************************************************************
Rem Bug 23515378: revoke read on audit views - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23733162
Rem *************************************************************************

Rem Remove sensitive flag for PDB_CREATE$.SQLSTMT.

update col$
set property = property - bitand(property, 8796093022208)
where name = 'SQLSTMT' and obj# =
(select obj# from obj$ where name = 'PDB_CREATE$'
 and owner# = (select user# from user$ where name = 'SYS')
 and remoteowner is NULL);

Rem Remove sensitive flag for PDB_SYNC$.SQLSTMT,LONGSQLTXT.

update col$
set property = property - bitand(property, 8796093022208)
where name in ('SQLSTMT', 'LONGSQLTXT') and obj# =
(select obj# from obj$ where name = 'PDB_SYNC$'
 and owner# = (select user# from user$ where name = 'SYS')
 and remoteowner is NULL);

COMMIT;

Rem *************************************************************************
Rem END BUG 23733162
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23597785 drop xs_data_security_util_int
Rem *************************************************************************
drop package xs_data_security_util_int;

Rem *************************************************************************
Rem END BUG 23597785
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23525741
Rem *************************************************************************

DROP PACKAGE dbms_snapshot_kkxrca;
DROP PACKAGE dbms_snapshot_common;

Rem *************************************************************************
Rem END BUG 23525741
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 22558380
Rem *************************************************************************
DROP PUBLIC SYNONYM DBMS_TG_DBG;
DROP PACKAGE dbms_tg_dbg;
DROP LIBRARY dbms_tg_dbg_lib;

Rem *************************************************************************
Rem End bug 22558380
Rem *************************************************************************

Rem *************************************************************************
Rem Begin bug 24605972
Rem *************************************************************************
DROP TYPE sys.tts_info_tab FORCE;
DROP TYPE sys.tts_info_tab_t FORCE;
DROP TYPE sys.tts_info_t FORCE;
DROP TYPE sys.tts_error_tab FORCE;
DROP TYPE sys.tts_error_tab_t FORCE;
DROP TYPE sys.tts_error_t FORCE;
Rem *************************************************************************
Rem End bug 24605972
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN of rollback Bug 24598595: Mark hist_head$, histgrm$ columns as 
Rem                                 insensitive.
Rem *************************************************************************

update col$ set property = property - bitand(property, 8796093022208)
where name in ('MINIMUM', 'MAXIMUM', 'LOWVAL', 'HIVAL') 
  and obj# =
        (select obj# from obj$ 
         where name = 'HIST_HEAD$'
           and owner# = (select user# from user$ where name = 'SYS')
           and remoteowner is NULL);

update col$ set property = property - bitand(property, 8796093022208)
where name in ('ENDPOINT', 'EPVALUE', 'EPVALUE_RAW') 
 and obj# =
       (select obj# from obj$ 
        where name = 'HISTGRM$'
          and owner# = (select user# from user$ where name = 'SYS')
          and remoteowner is NULL);

commit;

Rem *************************************************************************
Rem END of roll back Bug 24598595
Rem *************************************************************************

Rem *************************************************************************
Rem START Bug 25527953: Move flag KTT_HDFS to a different bit
Rem *************************************************************************

update ts$ set flags = flags - (4294967296 * 4294967296) + 9223372036854775808
where bitand( flags, (4294967296 * 4294967296) ) > 0;
commit;

Rem *************************************************************************
Rem END Bug 25527953
Rem *************************************************************************

Rem *************************************************************************
Rem END   e1201000.sql
Rem *************************************************************************

@?/rdbms/admin/sqlsessend.sql
