Rem
Rem $Header: rdbms/admin/cdfixed.sql /st_rdbms_18.0/1 2017/12/08 14:50:21 hlakshma Exp $
Rem
Rem cdfixed.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdfixed.sql - Catalog FIXED views
Rem
Rem    DESCRIPTION
Rem      Objects which reference fixed views.
Rem
Rem    NOTES
Rem      New fixed views and public synonyms must be dropped in downgrade
Rem      script rdbms/admin/e1201000.sql.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdfixed.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdfixed.sql
Rem SQL_PHASE: CDFIXED
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hlakshma    11/13/17 - Bug 27119186: Add [G]V$IMHMSEG
Rem    rthammai    10/23/17 - Bug 26753949: remove version_legacy
Rem    qinwu       10/01/17 - Bug 26882594: add [g]v$database_replay_progress
Rem    rthammai    09/08/17 - Bug 26753949: add version_full to prd_cmp_ver
Rem    miglees     08/24/17 - Bug 26572993: Add [G]V$MEMOPTIMIZE_WRITE_AREA
Rem    smurdia     07/31/17 - Bug-25900939: Add (G)V_$ASM_AUDIT_LOAD_JOBS
Rem    sroesch     04/26/17 - Bug 25942886: add v$java_patching_status
Rem    sroesch     04/19/17 - Bug 25766353: add v$java_services
Rem    lenovak     03/28/17 - Proj 62462: add GV$GWM_RAC_AFFINITY
Rem    prshanth    03/20/17 - Bug 25713423: add v$lockdown_rules
Rem    alui        02/21/17 - add v$wlm_pcservice for WLM
Rem    palashar    02/06/17 - #(25493529): add shard_sql views and synonyms
Rem    akanagra    02/01/17 - Bug 25486808: add G[V]$AQ_IPC_*_MSGS
Rem    amullick    01/11/17 - Proj 68508: add delta-IMCU views
Rem    jgiloni     12/08/16 - Quarantine for allocators
Rem    wanma       11/15/16 - Bug 24826690: rename "segdict" with "globaldict"                  
Rem    sankejai    10/17/16 - RTI 18965024:fix conid in nls_instance_parameters
Rem    gpongrac    07/26/16 - Add V$ASM_CACHE_EVENTS
Rem    aanverma    06/10/16 - Bug 23515378: grant read on audit views
Rem    jgiloni     06/03/16 - Add per-pdb wait histogram
Rem    moreddy     05/19/16 - 23311482: rename [g]v$asm_split_mirror
Rem    moreddy     03/30/16 - 22980610: Add [G]V$ASM_SPLIT_MIRROR
Rem    mjaiswal    03/22/16 - rename (g)v$aq_opt_* synonyms
Rem    pbollimp    03/09/16 - Bug 22897146: Rename FastStart v$view
Rem    rpang       02/22/16 - Bug 22806411: add [g]v$plsql_debuggable_sessions
Rem    pbollimp    02/01/16 - Bug 22542589: FastStart v$view support
Rem    thbaby      12/22/15 - Bug 22451720: add [G]V$PROXY_PDB_TARGETS
Rem    hohung      12/04/15 - fix typo in gv_$replay_context_systimestamp
Rem    hmohanku    11/03/15 - bug 16574456: add V$PASSWORDFILE_INFO
Rem    alui        10/28/15 - add [g]v$wlm_db_mode views for WLM.
Rem    arogers     10/05/15 - Add [G]V$GCR_STATUS and [G]V$GCR_LOG
Rem    jomcdon     09/18/15 - bug 21673793: implement v$rsrc_pdb(_history)
Rem    jesugonz    09/15/15 - 21767687: add (G)V$ASM_QUOTAGROUP
Rem    svaziran    08/11/15 - bug 21548817: add synonyms for UTS fixed views
Rem    jiayan      07/30/15 - #20663978: add (g)v$dml_stats
Rem    drosash     07/28/15 - Bug 21389839: Replace GV/V$RIMTEMPFILES with
Rem                           GV/V$TEMPFILE_INFO_INSTANCE
Rem    osuro       07/24/15 - Add [G]V$CON_SYSMETRIC[_HISTORY,_SUMMARY]
Rem    mjaiswal    06/16/15 - add synonym for (G)V$AQ_MESSAGE_CACHE_ADVICE and
Rem                           (G)V$AQ_SHARDED_SUBSCRIBER_STAT
Rem    jiayan      06/01/15 - #21165620: add (g)v$exp_stats
Rem    bnnguyen    05/30/15 - bug 20134461: add synonyms for
Rem                           [G]V$EXADIRECT_ACL and [G]V$IP_ACL 
Rem    hlakshma    05/19/15 - Add synonyms for fixed views for ADO for DBIM
Rem                           (project 45958)
Rem    asolisg     05/17/15 - 20936878: add (G)V$ASM_FILEGROUP_FILE
Rem    bsprunt     04/16/15 - Bug 20556913: add v$rsrcpdbmetric_[history]
Rem    vinisubr    04/09/15 - Project 58876: Support for public synonyms for
Rem                           column-level stats in-memory views
Rem    zaxie       04/03/15 - Bug 20688138: Add public synonym for
Rem                           [G]V$FS_FAILOVER_OBSERVERS
Rem    hpoduri     03/25/15 - Proj:47331,add synonym for [g]v$index_usage_info
Rem    itaranov    03/24/15 - proj 46694: SxR and Chunk stats
Rem    jgiloni     03/19/15 - Quarantine
Rem    nmukherj    03/18/15 - Proj 59655: Create public synonym for
Rem                           (g)v$inmemory_xmem_area
Rem    prgaharw    03/06/15 - 20664732 - IM segment dict V$ views support
Rem    jlombera    03/03/15 - bug 9128515: add synonyms for
Rem                           (g)v$system_reset_parameter and
Rem                           (g)v$system_reset_parameter2
Rem    aumishra    02/26/15 - Project 42356: Add views for IME infrastructure
Rem    genli       02/03/15 - add views/synonyms for (g)V$EVENT_OUTLIERS
Rem    nrcorcor    12/30/14 - Bug 13539672/Project 41272 New lost write
Rem                           protection
Rem    bnnguyen    12/29/14 - add synonym for [g]v$exadirect_acl
Rem    devghosh    12/23/14 - OPT4:add synonym for (g)V$AQ_OPT_STATISTICS
Rem                                           (g)V$AQ_OPT_CACHED_SUBSHARD
Rem                                           (g)V$AQ_OPT_UNCACHED_SUBSHARD
Rem                                           (g)V$AQ_OPT_INACTIVE_SUBSHARD
Rem    skayoor     12/12/14 - Proj 58196: Change Select priv to Read Priv
Rem    ineall      12/08/14 - Bug 20106569: v$nonlogged_block should not be
Rem                           public
Rem    nmuthukr    12/01/14 - add v$process pool
Rem    asolisg     11/10/14 - Proj 47340: add (G)V$ASM_FILEGROUP
Rem    pgalinka    10/16/14 - Handling upgrade for gcr_metrics & gcr_actions
Rem    drosash     10/13/14 - Proj 47411: Local Temp Tablespaces
Rem    kaizhuan    09/26/14 - Project 46812 add view [g]v$code_clause
Rem    jiayan      09/15/14 - Proj 44162: Stats Advisor views
Rem    prrathi     09/13/14 - add synonym for (g)V$AQ_REMOTE_DEQUEUE_AFFINITY
Rem    mziauddi    08/31/14 - proj 35612: add gv/v$zonemap_usage_stats
Rem    jgiloni     07/03/14 - PMON Slaves
Rem    moreddy     05/30/14 - lrg 12149882: add v$asm_disk_iostat_sparse
Rem    dagagne     05/29/14 - BUG 17346066: V$DATAGUARD_PROCESS
Rem    yanxie      05/16/14 - add g[v]$online_redef
Rem    dkoppar     05/05/14 - QI views
Rem    sankejai    04/25/14 - 18658574: nls_instance_parameters should only
Rem                           show parameters for current container
Rem    cono        03/13/14 - add view (g)v$process_priority_data
Rem    genli       02/25/14 - add views/synonyms for (g)V$EVENT_HISTOGRAM_MICRO
Rem    sidatta     02/04/14 - adding views v$cell_db, v$cell_db_history and
Rem                           v$cell_open_alerts
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    chinkris    12/12/13 - Rename (g)v$imc views to (g)v$im views
Rem    ssprasad    11/20/13 - Add synonyms for (g)v$asm_disk_sparse(_stat)
Rem                                            (g)v$asm_diskgroup_sparse
Rem    yxie        10/23/13 - grant for v$emx_usage_stats
Rem    sidatta     10/02/13 - v$cell_ioreason table
Rem    chinkris    10/30/13 - Rename (g)v$imc_column_level to 
Rem                           (g)v$im_column_level
Rem    cchiappa    10/28/13 - Rename V$VECTOR_TRANSLATE to V$KEY_VECTOR
Rem    jekamp      10/16/13 - Project 35591: Add v$im_segments and
Rem                           v$im_user_segments
Rem    chinkris    10/10/13 - Rename (g)v$imc_area to g(v)$inmemory_area
Rem    chinkris    11/09/13 - Add synonyms for (g)v$imc_area
Rem    chinkris    09/28/13 - Add synonyms for (G)V$IMC_COLUMN_LEVEL
Rem    yidin       09/09/13 - 12592851:add v$recovery_slave & gv$recovery_slave
Rem    yxie        07/30/13 - add (g)v$emx_usage_stats synonyms
Rem    sidatta     07/30/13 - Adding Cell Metric Description table/views
Rem    shrgauta    07/30/13 - Add entries for V$ and GV$ of IMCU and SMU views
Rem    mayanagr    06/13/13 - add v$imc_tbs_ext_map And v$imc_seg_ext_map
Rem    sidatta     06/06/13 - Adding (g)v$cell_config_info synonyms
Rem    ckearney    04/03/13 - add v$vector_translate
Rem    jekamp      03/07/13 - add v$imc_segments
Rem    youngtak    02/27/13 - Add public synonym for [G]V$FS_OBSERVER_HISTOGRAM
Rem    makataok    02/14/13 - 12777059: fixed a typo in
Rem                           gv$replay_context_systimestamp
Rem    sankejai    12/28/12 - XbranchMerge sankejai_bug-15988931 from
Rem                           st_rdbms_12.1.0.1
Rem    sankejai    12/20/12 - 16010984: remove [g]v$object_usage
Rem    lexuxu      11/26/12 - add public synonym for GV$AUTO_BMR_STATISTICS
Rem    sidatta     11/11/12 - Adding oss exadata metrics fixed views
Rem    aikumar     11/09/12 - Adding [g]v$sessions_count
Rem    kmeiyyap    11/06/12 - rename ofl_cell_thread_history to
Rem                           cell_ofl_thread_history
Rem    rahkrish    10/24/12 - Add public synonym for v$ofl_cell_thread_history.
Rem    vraja       10/15/12 - ILM renamed to HEAT_MAP
Rem    jgiloni     09/26/12 - Add DEAD_CLEANUP view
Rem    adalee      09/14/12 - add public synonym for [G]V$BT_SCAN_CACHE
Rem    dgraj       08/20/12 - Bug 14195982: add public synonym for
Rem                           [g]v$tsdp_supported_feature fixed views.
Rem    moreddy     07/26/12 - Add asm_audit views
Rem    apant       07/16/12 - Add public synonym for (g)v$channel_waits
Rem    mjaiswal    07/09/12 - add aq_ prefix to gv$subscriber_load
Rem    hnandyal    06/27/12 - Add ios_client view
Rem    maba        05/24/12 - add entry for (g)v$message_cache;
Rem    qma         05/16/12 - Increase column length in NLS parameter views
Rem    maba        05/09/12 - add public synonym for V$AQ_NONDUR_REGISTRATIONS
Rem    thbaby      05/08/12 - add v$con_system_event and gv$con_system_event
Rem    jhaslam     05/04/12 - Add public synonym for [g]v$kernel_io_outlier
Rem    akruglik    05/03/12 - add [g]v_$ views and public synonyms for
Rem                           [g]v$system_wait_class
Rem    akruglik    04/26/12 - add synonyms for V$CON_/GV$CON_ views
Rem    vgokhale    04/16/12 - Public synonym for v$pdb_incarnation
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gravipat    03/20/12 - Add public synonym for [G]V$CONTAINERS
Rem    jkundu      03/12/12 - bug 10297974: drop [g]v$_logmnr_region/callback
Rem    ushaft      03/03/12 - Add views and synonyms for (g)v$rt_addm_control
Rem                           and (g)v$instance_ping
Rem    rtati       02/20/12 - change ntfn_clients to aq_notification_clients
Rem    vbipinbh    02/17/12 - add public synonym for gv$msgbm and v$msgbm
Rem    maniverm    02/07/12 - adding v and gv for clonedfile
Rem    rkiyer      01/17/12 - ACFS Security and Encryption Fixed Views in
Rem                           support for EM Project #31221
Rem    kamotwan    12/30/11 - add public synonym for
Rem                           [G]V$GOLDENGATE_CAPABILITIES 
Rem    mlmiller    12/15/11 - add gv/v$asm_acfsrepl, gv/v$asm_acfsrepltag
Rem    gshegalo    12/05/11 - adding copy_nonlogged and backup_nonlogged
Rem    juxie       11/12/11 - bug13420640: add public syn. for px_process_trace
Rem    unjagtap    11/09/11 - LRG 5555569: rename synonym for x$kxftask
Rem    nrcorcor    11/01/11 - 12395847
Rem    mkeller     10/29/11 - add v and gv $asm_acfstag public synonyms + views
Rem    bdagevil    10/29/11 - add [G]V$SYS_REPORT_STATS and
Rem                           [G]V$SYS_REPORT_REQUESTS
Rem    liaguo      10/17/11 - add v$ilm_segment_access (proj 32788)
Rem    hayu        10/06/11 - add public synonym for sql_monitor_sesstat
Rem    kigoyal     09/29/11 - bug13037280
Rem    shase       09/22/11 - proj 32634: synonym for v$tempundostat
Rem    hayu        09/20/11 - create public synonym for v$sql_monitor_sessstat
Rem    rtati       08/29/11 - add public synonym for GV$NTFN_CLIENTS
Rem    mjaiswal    08/22/11 - add gv$subscriber_load synonyms
Rem    savallu     09/15/11 - p#(autodop_31271): (G)V$OPTIMIZER_PROCESSING_RATE
Rem    kigoyal     09/12/11 - adding view flashfilestat
Rem    sankejai    08/25/11 - use x$props in nls_database_parameters
Rem    adalee      08/25/11 - add kcb DW scan fixed views
Rem    jhaslam     08/23/11 - add OFS and IO outlier v$/gv$ public synonyms
Rem    rdongmin    08/12/11 - proj 23305: add v$sql_diag_repository[_reason]
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER and
Rem                           Next Generation to Unified
Rem    jhaslam     08/23/11 - add OFS and IO outlier v$/gv$ public synonyms
Rem    gagarg      08/16/11 - 31157:add AQ public synonyms
Rem    weizhang    08/16/11 - add v$/gv$bts_stat public synonyms and views
Rem    rdongmin    08/12/11 - proj 23305: add v$sql_diag_repository[_reason]
Rem    maba        05/02/11 - added message_cache view
Rem    jhaslam     08/23/11 - add OFS and IO outlier v$/gv$ public synonyms
Rem    tianli      08/08/11 - add con_id to gg views
Rem    awainogl    06/14/11 - project 31793: [g]v$sql_reoptimization_hints
Rem    sankejai    08/10/11 - add v$kxftask for Parallel Task Library (PTL)
Rem    tianli      08/08/11 - add con_id to gg views
Rem    gshegalo    08/03/11 - Project 23025 GV$ / V$ NONLOGGED_BLOCK
Rem    awainogl    06/14/11 - project 31793: [g]v$sql_reoptimization_hints
Rem    rpang       07/18/11 - add v$/gv$mapped_sql public synonyms and views
Rem    hohung      07/21/11 - Add synonym for new replay context fixed views
Rem    rgmani      07/20/11 - Add synonym for new scheduler fixed views
Rem    sankejai    06/07/11 - 12623919: add CON_ID column to v$/gv$ views
Rem                           selecting from other v$/gv$ views
Rem    brwolf      06/07/11 - add v$editionable_types
Rem    snadhika    06/07/11 - Proj 31196, add public synonyms for
Rem                           (G)V$XS_SESSIONS
Rem    rmir        05/17/11 - Proj 32008, add public synonyms for
Rem                           (G)V$ENCRYPTION_KEYS & (G)V$CLIENT_SECRETS
Rem    bdagevil    05/09/11 - add v[g]$sql_monitor_statname
Rem    kquinn      05/06/11 - 10357961: correct *_fix_control,
Rem                           *_transportable_platform synonyms
Rem    gravipat    04/29/11 - Change v$pluggable_databases to v$pdbs
Rem    dfriedma    04/04/11 - v$asm_estimate
Rem    skyathap    03/29/11 - Add dg_broker_config
Rem    nkgopal     04/03/11 - Proj 31908: Add V$AUDIT_RECORD_FORMAT
Rem    skyathap    03/29/11 - Add dg_broker_config
Rem    nkgopal     03/14/11 - Proj 31908: Add (G)V$AUDIT_TRAIL
Rem    sankejai    02/01/18 - move v/gv$ views from catalog scripts to kqfv
Rem    huntran     03/15/11 - cdr stats
Rem    huntran     02/01/11 - v/gv$goldengate_table_stats
Rem    gravipat    11/22/10 - Add v$pluggable_databases
Rem    wbattist    11/09/10 - bug 10256769 - add GV$HANG_STATISTICS and
Rem                           V$HANG_STATISTICS views
Rem    smuthuli    08/01/10 - fast space usage changes
Rem    rmao        05/04/10 - rename streams_name/type in
Rem                           g/gv$xstream/goldengate_transaction to
Rem                           component_name/type
Rem    haxu        04/25/10 - add sga_allocated_knstasl
Rem    rmao        04/15/10 - bug 9577760:fix GoldenGate/XStream view problems
Rem    wbattist    03/18/10 - bug 9384642 - add V$HANG_INFO and
Rem                           V$HANG_SESSION_INFO
Rem    rmao        03/29/10 - add v/gv$xstream/goldengate_transaction,
Rem                           v/gv$xstream/goldengate_message_tracking views
Rem    rmao        03/23/10 - add v/gv$xstream/goldengate_capture views
Rem    ssprasad    12/28/09 - add v$asm_acfs_encryption_info
Rem                           add v$asm_acfs_security_info
Rem    slahoran    12/14/09 - bug #8722860 : nls_instance_parameters should
Rem                           depend on v$system_parameter
Rem    adalee      12/07/09 - add v$database_key_info
Rem    shjoshi     11/11/09 - Add synonyms for [g]v$advisor_current_sqlplan
Rem    molagapp    06/03/09 - add recovery_area_usage views
Rem    adalee      05/27/09 - add [g]v$file_optimized_histogram
Rem    mchainan    02/07/09 - Add v$session_blockers and gv$session_blockers
Rem    gravipat    04/21/09 - Add synonyms for v$libcache_locks,
Rem                           gv$libcache_locks
Rem    ssahu       03/31/09 - synonyms for view cpool_conn_info
Rem    shbose      03/24/09 - change [g]v$persistent_tm_cache to
Rem                           [g]v$persistent_qmn_cache
Rem    mbastawa    03/13/09 - make client_result_cache_stats views internal
Rem    arbalakr    02/23/09 - bug 7350685: add GV/V$SQLCOMMAND and 
Rem                           GV/V$TOPLEVELCALL
Rem    bdagevil    02/12/09 - add [g]v$ash_info
Rem    sidatta     12/23/08 - Adding public synonyms for v$cell_config and
Rem                           gv$cell_config
Rem    ethibaul    01/08/09 - remove deprecated ofs syn
Rem    hongyang    01/04/09 - add GV$DATAGUARD_STATS, 
Rem                           remove GV/V$STANDBY_APPLY_SNAPSHOT
Rem    pbelknap    11/19/08 - add V$SQLPA_METRIC
Rem    jgiloni     08/02/08 - Add GV/V$LISTENER_NETWORK
Rem    rlong       08/07/08 - 
Rem    josmith     07/28/08 - Add ACFS view synonyms
Rem    mziauddi    07/31/08 - add G(V)$OBJECT_DML_STATISTICS
Rem    ruqtang     07/14/08 - Change back v$aw_longops to public grant
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    sugpande    07/14/08 - Change v$cell_name to v$cell
Rem    vkolla      04/25/08 - Add [g]v$iostat_function_detail
Rem    atsukerm    04/22/08 - rename OSS views
Rem    mjaiswal    03/10/08 - add QMON (G)V$ views
Rem    nmacnaug    01/28/08 - add v$policy_history
Rem    jiashi      01/12/08 - add v$standby_event_histogram
Rem    bdagevil    12/18/07 - add v$sqlstats_plan_hash
Rem    nchoudhu    12/18/07 - XbranchMerge nchoudhu_sage1_merge from
Rem                           st_rdbms_11.1
Rem    ethibaul    12/11/07 - add v$asm_ofssnapshots
Rem    sugpande    12/05/07 - Add gv$sagecell and v$sagecell
Rem    tbhosle     10/19/07 - public synonyms for v$emon and gv$emon
Rem    amysoren    10/09/07 - add v$wlm_pc_stats, v$wlm_pcmetric and
Rem                           v$wlm_pcmetric_history
Rem    atsukerm    09/14/07 - add OSS fixed views
Rem    hqian       07/19/07 - #6238754: add (g)v$asm_user, (g)v$asm_usergroup,
Rem                           and (g)v$asm_usergroup_member
Rem    ysarig      07/09/07 - Add v$diag_critical_error
Rem    avaliani    03/28/07 - remove v$wait_chains_history
Rem    molagapp    02/27/07 - rename remote_archived_log to foreign_archived_log
Rem    rfrank      02/07/07 - change v$unfs -> v$dnfs
Rem    vkolla      01/23/07 - calibration_results to status
Rem    rfrank      01/12/07 - Add v$unfs_channels
Rem    skaluska    12/01/06 - bug 5679933: remove v$inststat
Rem    arogers     12/04/06 - 5379252 add v$process_group and v$detached_session
Rem    sackulka    11/20/06 - Add V$SECUREFILE_TIMER
Rem    vkolla      11/17/06 - v$io_calibration_results
Rem    slahoran    10/17/06 - Add v$inststat
Rem    gngai       10/02/06 - added v$diaginfo
Rem    jgalanes    10/06/06 - remove synonymns for IDR views since internal
Rem                           only
Rem    ltominna    09/29/06 - lrg-2575704
Rem    averhuls    08/22/06 - Add {g}v_asm_volume, {g}v_asm_volume_stat,
Rem                           {g}v_asm_filesystem, {g}v_asm_ofsvolumes
Rem    esoyleme    05/19/06 - correct privs for v$aw_* 
Rem    mabhatta    09/06/06 - adding v$flashback_txn_* views
Rem    nthombre    08/31/06 - add gv$ and v$sqlfn_metadata
Rem    nthombre    09/05/06 - Added gv$ and v$sqlfn_arg_metadata
Rem    sdizdar     07/17/06 - add synonym gv$, v$_rman_compression_algorithms
Rem    bbaddepu    08/23/06 - bug 5483084: remove dup of resize_ops
Rem    adalee      08/08/06 - add v$encrypted_tablespaces
Rem    rfrank      08/11/06 - add unfs fixed fiews
Rem    bkuchibh    08/03/06 - create incmeter view synonyms
Rem    kamsubra    07/25/06 - add view creation for cpool_stats (fixed views) 
Rem    kamsubra    07/18/06 - renamed cpool views bug 5396075
Rem    rmir        07/10/06 - add public synonyms for v$encryption_wallet and
Rem                           gv$ encryption_wallet
Rem    veeve       07/13/06 - add v$workload_replay_thread
Rem    bdagevil    06/05/06 - add SQL monitoring views ([G]V$SQL_MONITOR and
Rem                           [G]V$SQL_PLAN_MONITOR
Rem    mlfeng      07/10/06 - add iofuncmetric, rsrcmgrmetric 
Rem    mbastawa    07/12/06 - client result cache:synonyms for V$ fixed views
Rem    avaliani    07/11/06 - add v$wait_chains and v$wait_chains_history
Rem    vkapoor     06/30/06 - Bug 5220793 
Rem    mtao        07/07/06 - proj 17789 synonym gv$, v$_remote_archived_log
Rem    sourghos    06/09/06 - add view for WLM 
Rem    mjstewar    06/12/06 - Fix ir_manual_checklist 
Rem    balajkri    06/12/06 - Transaction layer diagnosability features 
Rem    bbaddepu    06/16/06 - add memory_target views
Rem    absaxena    06/02/06 - add public synonyms for subscr_registration_stats
Rem    chliang     05/19/06 - add sscr fixed views
Rem    amadan      05/24/06 - add public synonyms for PERSISTENT_QUEUES 
Rem    dsemler     06/12/06 - reinstate lost views for hm and ir 
Rem    kamsubra    05/19/06 - Adding views for cpool stats 
Rem    rwickrem    05/25/06 - add asm_attribute 
Rem    dsemler     05/30/06 - add in view def lost in ref/merge 
Rem    mzait       05/19/06 - ACS - support for new fixed views 
Rem                            V$SQL_CS_HISTOGRAM
Rem                            V$SQL_CS_SELECTIVITY 
Rem                            V$SQL_CS_STATISTICS 
Rem    vkolla      05/19/06 - Adding iostats fixed views 
Rem    bkuchibh    05/17/06 - create v$hm views,synonyms 
Rem    dsemler     05/17/06 - add fixed view definitions and grants 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


remark
remark  FAMILY "FIXED (VIRTUAL) VIEWS"
remark

create or replace view v_$map_library as select * from v$map_library;
create or replace public synonym v$map_library for v_$map_library;
grant select on v_$map_library to select_catalog_role;

create or replace view v_$map_file as select * from v$map_file;
create or replace public synonym v$map_file for v_$map_file;
grant select on v_$map_file to select_catalog_role;

create or replace view v_$map_file_extent as select * from v$map_file_extent;
create or replace public synonym v$map_file_extent for v_$map_file_extent;
grant select on v_$map_file_extent to select_catalog_role;

create or replace view v_$map_element as select * from v$map_element;
create or replace public synonym v$map_element for v_$map_element;
grant select on v_$map_element to select_catalog_role;

create or replace view v_$map_ext_element as select * from v$map_ext_element;
create or replace public synonym v$map_ext_element for v_$map_ext_element;
grant select on v_$map_ext_element to select_catalog_role;

create or replace view v_$map_comp_list as select * from v$map_comp_list;
create or replace public synonym v$map_comp_list for v_$map_comp_list;
grant select on v_$map_comp_list to select_catalog_role;

create or replace view v_$map_subelement as select * from v$map_subelement;
create or replace public synonym v$map_subelement for v_$map_subelement;
grant select on v_$map_subelement to select_catalog_role;

create or replace view v_$map_file_io_stack as select * from v$map_file_io_stack;

create or replace public synonym v$map_file_io_stack for v_$map_file_io_stack;
grant select on v_$map_file_io_stack to select_catalog_role;


create or replace view v_$sql_redirection as select * from v$sql_redirection;
create or replace public synonym v$sql_redirection for v_$sql_redirection;
grant select on v_$sql_redirection to select_catalog_role;

create or replace view v_$sql_plan as select * from v$sql_plan;
create or replace public synonym v$sql_plan for v_$sql_plan;
grant select on v_$sql_plan to select_catalog_role;

create or replace view v_$sql_plan_statistics as
  select * from v$sql_plan_statistics;
create or replace public synonym v$sql_plan_statistics
  for v_$sql_plan_statistics;
grant select on v_$sql_plan_statistics to select_catalog_role;

create or replace view v_$sql_plan_statistics_all as
  select * from v$sql_plan_statistics_all;
create or replace public synonym v$sql_plan_statistics_all
  for v_$sql_plan_statistics_all;
grant select on v_$sql_plan_statistics_all to select_catalog_role;

create or replace view v_$advisor_current_sqlplan as
  select * from v$advisor_current_sqlplan;
create or replace public synonym v$advisor_current_sqlplan
  for v_$advisor_current_sqlplan;
grant read on v_$advisor_current_sqlplan to public;

create or replace view v_$sql_workarea as select * from v$sql_workarea;
create or replace public synonym v$sql_workarea for v_$sql_workarea;
grant select on v_$sql_workarea to select_catalog_role;

create or replace view v_$sql_workarea_active
  as select * from v$sql_workarea_active;
create or replace public synonym v$sql_workarea_active
   for v_$sql_workarea_active;
grant select on v_$sql_workarea_active to select_catalog_role;

create or replace view v_$sql_workarea_histogram
   as select * from v$sql_workarea_histogram;
create or replace public synonym v$sql_workarea_histogram
   for v_$sql_workarea_histogram;
grant select on v_$sql_workarea_histogram to select_catalog_role;

create or replace view v_$pga_target_advice as select * from v$pga_target_advice;
create or replace public synonym v$pga_target_advice for v_$pga_target_advice;
grant select on v_$pga_target_advice to select_catalog_role;

create or replace view v_$pga_target_advice_histogram
  as select * from v$pga_target_advice_histogram;
create or replace public synonym v$pga_target_advice_histogram
  for v_$pga_target_advice_histogram;
grant select on v_$pga_target_advice_histogram to select_catalog_role;

create or replace view v_$pgastat as select * from v$pgastat;
create or replace public synonym v$pgastat for v_$pgastat;
grant select on v_$pgastat to select_catalog_role;

create or replace view v_$sys_optimizer_env
  as select * from v$sys_optimizer_env;
create or replace public synonym v$sys_optimizer_env for v_$sys_optimizer_env;
grant select on v_$sys_optimizer_env to select_catalog_role;

create or replace view v_$ses_optimizer_env
  as select * from v$ses_optimizer_env;
create or replace public synonym v$ses_optimizer_env for v_$ses_optimizer_env;
grant select on v_$ses_optimizer_env to select_catalog_role;

create or replace view v_$sql_optimizer_env
  as select * from v$sql_optimizer_env;
create or replace public synonym v$sql_optimizer_env for v_$sql_optimizer_env;
grant select on v_$sql_optimizer_env to select_catalog_role;

create or replace view v_$dlm_misc as select * from v$dlm_misc;
create or replace public synonym v$dlm_misc for v_$dlm_misc;
grant select on v_$dlm_misc to select_catalog_role;

create or replace view v_$dlm_latch as select * from v$dlm_latch;
create or replace public synonym v$dlm_latch for v_$dlm_latch;
grant select on v_$dlm_latch to select_catalog_role;

create or replace view v_$dlm_convert_local as select * from v$dlm_convert_local;
create or replace public synonym v$dlm_convert_local for v_$dlm_convert_local;
grant select on v_$dlm_convert_local to select_catalog_role;

create or replace view v_$dlm_convert_remote as select * from v$dlm_convert_remote;
create or replace public synonym v$dlm_convert_remote
   for v_$dlm_convert_remote;
grant select on v_$dlm_convert_remote to select_catalog_role;

create or replace view v_$dlm_all_locks as select * from v$dlm_all_locks;
create or replace public synonym v$dlm_all_locks for v_$dlm_all_locks;
grant select on v_$dlm_all_locks to select_catalog_role;

create or replace view v_$dlm_locks as select * from v$dlm_locks;
create or replace public synonym v$dlm_locks for v_$dlm_locks;
grant select on v_$dlm_locks to select_catalog_role;

create or replace view v_$dlm_ress as select * from v$dlm_ress;
create or replace public synonym v$dlm_ress for v_$dlm_ress;
grant select on v_$dlm_ress to select_catalog_role;

create or replace view v_$hvmaster_info as select * from v$hvmaster_info;
create or replace public synonym v$hvmaster_info for v_$hvmaster_info;
grant select on v_$hvmaster_info to select_catalog_role;

create or replace view v_$gcshvmaster_info as select * from v$gcshvmaster_info;
create or replace public synonym v$gcshvmaster_info for v_$gcshvmaster_info;
grant select on v_$gcshvmaster_info to select_catalog_role;

create or replace view v_$gcspfmaster_info as select * from v$gcspfmaster_info;
create or replace public synonym v$gcspfmaster_info for v_$gcspfmaster_info;
grant select on v_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$dlm_traffic_controller as
select * from gv$dlm_traffic_controller;
create or replace public synonym gv$dlm_traffic_controller
   for gv_$dlm_traffic_controller;
grant select on gv_$dlm_traffic_controller to select_catalog_role;

create or replace view v_$dlm_traffic_controller as
select * from v$dlm_traffic_controller;
create or replace public synonym v$dlm_traffic_controller
   for v_$dlm_traffic_controller;
grant select on v_$dlm_traffic_controller to select_catalog_role;

create or replace view gv_$dynamic_remaster_stats 
as select * from gv$dynamic_remaster_stats;
create or replace public synonym gv$dynamic_remaster_stats
                             for gv_$dynamic_remaster_stats;
grant select on gv_$dynamic_remaster_stats to select_catalog_role;

create or replace view v_$dynamic_remaster_stats 
as select * from v$dynamic_remaster_stats;
create or replace public synonym v$dynamic_remaster_stats
                             for v_$dynamic_remaster_stats;
grant select on v_$dynamic_remaster_stats to select_catalog_role;

create or replace view v_$ges_enqueue as
select * from v$ges_enqueue;
create or replace public synonym v$ges_enqueue for v_$ges_enqueue;
grant select on v_$ges_enqueue to select_catalog_role;

create or replace view v_$ges_blocking_enqueue as
select * from v$ges_blocking_enqueue;
create or replace public synonym v$ges_blocking_enqueue
   for v_$ges_blocking_enqueue;
grant select on v_$ges_blocking_enqueue to select_catalog_role;

create or replace view v_$gc_element as
select * from v$gc_element;
create or replace public synonym v$gc_element for v_$gc_element;
grant select on v_$gc_element to select_catalog_role;

create or replace view v_$cr_block_server as
select * from v$cr_block_server;
create or replace public synonym v$cr_block_server for v_$cr_block_server;
grant select on v_$cr_block_server to select_catalog_role;

create or replace view v_$current_block_server as
select * from v$current_block_server;
create or replace public synonym v$current_block_server for v_$current_block_server;
grant select on v_$current_block_server to select_catalog_role;

create or replace view v_$policy_history as
select * from v$policy_history;
create or replace public synonym v$policy_history for v_$policy_history;
grant select on v_$policy_history to select_catalog_role;

create or replace view v_$gc_elements_w_collisions as
select * from v$gc_elements_with_collisions;
create or replace public synonym v$gc_elements_with_collisions
   for v_$gc_elements_w_collisions;
grant select on v_$gc_elements_w_collisions to select_catalog_role;

create or replace view v_$file_cache_transfer as
select * from v$file_cache_transfer;
create or replace public synonym v$file_cache_transfer
   for v_$file_cache_transfer;
grant select on v_$file_cache_transfer to select_catalog_role;

create or replace view v_$temp_cache_transfer as
select * from v$temp_cache_transfer;
create or replace public synonym v$temp_cache_transfer
   for v_$temp_cache_transfer;
grant select on v_$temp_cache_transfer to select_catalog_role;

create or replace view v_$class_cache_transfer as
select * from v$class_cache_transfer;
create or replace public synonym v$class_cache_transfer
   for v_$class_cache_transfer;
grant select on v_$class_cache_transfer to select_catalog_role;

create or replace view v_$bh as select * from v$bh;
create or replace public synonym v$bh for v_$bh;
grant read on v_$bh to public;

create or replace view v_$sqlfn_metadata as
select * from v$sqlfn_metadata;
create or replace public synonym v$sqlfn_metadata
   for v_$sqlfn_metadata;
grant read on v_$sqlfn_metadata to public;

create or replace view v_$sqlfn_arg_metadata as
select * from v$sqlfn_arg_metadata;
create or replace public synonym v$sqlfn_arg_metadata
   for v_$sqlfn_arg_metadata;
grant read on v_$sqlfn_arg_metadata to public;


create or replace view v_$lock_element as select * from v$lock_element;
create or replace public synonym v$lock_element for v_$lock_element;
grant select on v_$lock_element to select_catalog_role;

create or replace view v_$locks_with_collisions as
select * from v$locks_with_collisions;
create or replace public synonym v$locks_with_collisions
   for v_$locks_with_collisions;
grant select on v_$locks_with_collisions to select_catalog_role;

create or replace view v_$file_ping as select * from v$file_ping;
create or replace public synonym v$file_ping for v_$file_ping;
grant select on v_$file_ping to select_catalog_role;

create or replace view v_$temp_ping as select * from v$temp_ping;
create or replace public synonym v$temp_ping for v_$temp_ping;
grant select on v_$temp_ping to select_catalog_role;

create or replace view v_$class_ping as select * from v$class_ping;
create or replace public synonym v$class_ping for v_$class_ping;
grant select on v_$class_ping to select_catalog_role;

create or replace view v_$instance_cache_transfer as
select * from v$instance_cache_transfer;
create or replace public synonym v$instance_cache_transfer
   for v_$instance_cache_transfer;
grant select on v_$instance_cache_transfer to select_catalog_role;

create or replace view v_$buffer_pool as select * from v$buffer_pool;
create or replace public synonym v$buffer_pool for v_$buffer_pool;
grant select on v_$buffer_pool to select_catalog_role;

create or replace view v_$buffer_pool_statistics as
select * from v$buffer_pool_statistics;
create or replace public synonym v$buffer_pool_statistics
   for v_$buffer_pool_statistics;
grant select on v_$buffer_pool_statistics to select_catalog_role;

create or replace view v_$bt_scan_obj_temps as
select * from v$bt_scan_obj_temps;
create or replace public synonym v$bt_scan_obj_temps
   for v_$bt_scan_obj_temps;
grant select on v_$bt_scan_obj_temps to select_catalog_role;

create or replace view gv_$bt_scan_obj_temps as
select * from gv$bt_scan_obj_temps;
create or replace public synonym gv$bt_scan_obj_temps
   for gv_$bt_scan_obj_temps;
grant select on gv_$bt_scan_obj_temps to select_catalog_role;

create or replace view v_$bt_scan_cache as
select * from v$bt_scan_cache;
create or replace public synonym v$bt_scan_cache
   for v_$bt_scan_cache;
grant select on v_$bt_scan_cache to select_catalog_role;

create or replace view gv_$bt_scan_cache as
select * from gv$bt_scan_cache;
create or replace public synonym gv$bt_scan_cache
   for gv_$bt_scan_cache;
grant select on gv_$bt_scan_cache to select_catalog_role;

create or replace view v_$instance_recovery as
select * from v$instance_recovery;
create or replace public synonym v$instance_recovery for v_$instance_recovery;
grant select on v_$instance_recovery to select_catalog_role;

create or replace view v_$controlfile as select * from v$controlfile;
create or replace public synonym v$controlfile for v_$controlfile;
grant select on v_$controlfile to select_catalog_role;

create or replace view v_$log as select * from v$log;
create or replace public synonym v$log for v_$log;
grant select on v_$log to SELECT_CATALOG_ROLE;

create or replace view v_$standby_log as select * from v$standby_log;
create or replace public synonym v$standby_log for v_$standby_log;
grant select on v_$standby_log to SELECT_CATALOG_ROLE;

create or replace view v_$dataguard_status as select * from v$dataguard_status;
create or replace public synonym v$dataguard_status for v_$dataguard_status;
grant select on v_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view v_$thread as select * from v$thread;
create or replace public synonym v$thread for v_$thread;
grant select on v_$thread to select_catalog_role;

create or replace view v_$process as select * from v$process;
create or replace public synonym v$process for v_$process;
grant select on v_$process to select_catalog_role;

create or replace view v_$bgprocess as select * from v$bgprocess;
create or replace public synonym v$bgprocess for v_$bgprocess;
grant select on v_$bgprocess to select_catalog_role;

create or replace view v_$session as select * from v$session;
create or replace public synonym v$session for v_$session;
grant select on v_$session to select_catalog_role;

create or replace view v_$license as select * from v$license;
create or replace public synonym v$license for v_$license;
grant select on v_$license to select_catalog_role;

create or replace view v_$transaction as select * from v$transaction;
create or replace public synonym v$transaction for v_$transaction;
grant select on v_$transaction to select_catalog_role;

create or replace view v_$bsp as select * from v$bsp;
create or replace public synonym v$bsp for v_$bsp;
grant select on v_$bsp to select_catalog_role;

create or replace view v_$fast_start_servers as
select * from v$fast_start_servers;
create or replace public synonym v$fast_start_servers
   for v_$fast_start_servers;
grant select on v_$fast_start_servers to select_catalog_role;

create or replace view v_$fast_start_transactions
as select * from v$fast_start_transactions;
create or replace public synonym v$fast_start_transactions
   for v_$fast_start_transactions;
grant select on v_$fast_start_transactions to select_catalog_role;

create or replace view v_$locked_object as select * from v$locked_object;
create or replace public synonym v$locked_object for v_$locked_object;
grant select on v_$locked_object to select_catalog_role;

create or replace view v_$latch as select * from v$latch;
create or replace public synonym v$latch for v_$latch;
grant select on v_$latch to select_catalog_role;

create or replace view v_$latch_children as select * from v$latch_children;
create or replace public synonym v$latch_children for v_$latch_children;
grant select on v_$latch_children to select_catalog_role;

create or replace view v_$latch_parent as select * from v$latch_parent;
create or replace public synonym v$latch_parent for v_$latch_parent;
grant select on v_$latch_parent to select_catalog_role;

create or replace view v_$latchname as select * from v$latchname;
create or replace public synonym v$latchname for v_$latchname;
grant select on v_$latchname to select_catalog_role;

create or replace view v_$latchholder as select * from v$latchholder;
create or replace public synonym v$latchholder for v_$latchholder;
grant select on v_$latchholder to select_catalog_role;

create or replace view v_$latch_misses as select * from v$latch_misses;
create or replace public synonym v$latch_misses for v_$latch_misses;
grant select on v_$latch_misses to select_catalog_role;

create or replace view v_$session_longops as select * from v$session_longops;
create or replace public synonym v$session_longops for v_$session_longops;
grant read on v_$session_longops to public;

create or replace view v_$resource as select * from v$resource;
create or replace public synonym v$resource for v_$resource;
grant select on v_$resource to select_catalog_role;

create or replace view v_$_lock as select * from v$_lock;
create or replace public synonym v$_lock for v_$_lock;
grant select on v_$_lock to select_catalog_role;

create or replace view v_$lock as select * from v$lock;
create or replace public synonym v$lock for v_$lock;
grant select on v_$lock to select_catalog_role;

create or replace view v_$sesstat as select * from v$sesstat;
create or replace public synonym v$sesstat for v_$sesstat;
grant select on v_$sesstat to select_catalog_role;

create or replace view v_$mystat as select * from v$mystat;
create or replace public synonym v$mystat for v_$mystat;
grant select on v_$mystat to select_catalog_role;

create or replace view v_$subcache as select * from v$subcache;
create or replace public synonym v$subcache for v_$subcache;
grant select on v_$subcache to select_catalog_role;

create or replace view v_$sysstat as select * from v$sysstat;
create or replace public synonym v$sysstat for v_$sysstat;
grant select on v_$sysstat to select_catalog_role;

create or replace view v_$con_sysstat as select * from v$con_sysstat;
create or replace public synonym v$con_sysstat for v_$con_sysstat;
grant select on v_$con_sysstat to select_catalog_role;

create or replace view v_$statname as select * from v$statname;
create or replace public synonym v$statname for v_$statname;
grant select on v_$statname to select_catalog_role;

create or replace view v_$osstat as select * from v$osstat;
create or replace public synonym v$osstat for v_$osstat;
grant select on v_$osstat to select_catalog_role;

create or replace view v_$access as select * from v$access;
create or replace public synonym v$access for v_$access;
grant select on v_$access to select_catalog_role;

create or replace view v_$object_dependency as
  select * from v$object_dependency;
create or replace public synonym v$object_dependency for v_$object_dependency;
grant select on v_$object_dependency to select_catalog_role;

create or replace view v_$dbfile as select * from v$dbfile;
create or replace public synonym v$dbfile for v_$dbfile;
grant select on v_$dbfile to select_catalog_role;

create or replace view v_$flashfilestat as select * from v$flashfilestat;
create or replace public synonym v$flashfilestat for v_$flashfilestat;
grant select on v_$flashfilestat to select_catalog_role;

create or replace view v_$filestat as select * from v$filestat;
create or replace public synonym v$filestat for v_$filestat;
grant select on v_$filestat to select_catalog_role;

create or replace view v_$tempstat as select * from v$tempstat;
create or replace public synonym v$tempstat for v_$tempstat;
grant select on v_$tempstat to select_catalog_role;

create or replace view v_$logfile as select * from v$logfile;
create or replace public synonym v$logfile for v_$logfile;
grant select on v_$logfile to select_catalog_role;

create or replace view v_$flashback_database_logfile as
  select * from v$flashback_database_logfile;
create or replace public synonym v$flashback_database_logfile
  for v_$flashback_database_logfile;
grant select on v_$flashback_database_logfile to select_catalog_role;

create or replace view v_$flashback_database_log as
  select * from v$flashback_database_log;
create or replace public synonym v$flashback_database_log
  for v_$flashback_database_log;
grant select on v_$flashback_database_log to select_catalog_role;

create or replace view v_$flashback_database_stat as
  select * from v$flashback_database_stat;
create or replace public synonym v$flashback_database_stat
  for v_$flashback_database_stat;
grant select on v_$flashback_database_stat to select_catalog_role;

create or replace view v_$restore_point as
  select * from v$restore_point;
create or replace public synonym v$restore_point
  for v_$restore_point;
grant read on v_$restore_point to public;

create or replace view v_$rollname as 
   select x$kturd.kturdusn usn, undo$.name, x$kturd.con_id
   from x$kturd, undo$
   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
create or replace public synonym v$rollname for v_$rollname;
grant select on v_$rollname to select_catalog_role;

create or replace view v_$rollstat as select * from v$rollstat;
create or replace public synonym v$rollstat for v_$rollstat;
grant select on v_$rollstat to select_catalog_role;

create or replace view v_$undostat as select * from v$undostat;
create or replace public synonym v$undostat for v_$undostat;
grant select on v_$undostat to select_catalog_role;

create or replace view v_$tempundostat as select * from v$tempundostat;
create or replace public synonym v$tempundostat for v_$tempundostat;
grant select on v_$tempundostat to select_catalog_role;

create or replace view gv_$tempundostat as select * from gv$tempundostat;
create or replace public synonym gv$tempundostat for gv_$tempundostat;
grant select on gv_$tempundostat to select_catalog_role;

create or replace view v_$sga as select * from v$sga;
create or replace public synonym v$sga for v_$sga;
grant select on v_$sga to select_catalog_role;

create or replace view v_$cluster_interconnects 
       as select * from v$cluster_interconnects;
create or replace public synonym v$cluster_interconnects 
       for v_$cluster_interconnects;
grant select on v_$cluster_interconnects to select_catalog_role;

create or replace view v_$configured_interconnects 
       as select * from v$configured_interconnects;
create or replace public synonym v$configured_interconnects 
       for v_$configured_interconnects;
grant select on v_$configured_interconnects to select_catalog_role;

create or replace view v_$parameter as select * from v$parameter;
create or replace public synonym v$parameter for v_$parameter;
grant select on v_$parameter to select_catalog_role;

create or replace view v_$parameter2 as select * from v$parameter2;
create or replace public synonym v$parameter2 for v_$parameter2;
grant select on v_$parameter2 to select_catalog_role;

create or replace view v_$obsolete_parameter as
  select * from v$obsolete_parameter;
create or replace public synonym v$obsolete_parameter
   for v_$obsolete_parameter;
grant select on v_$obsolete_parameter to select_catalog_role;

create or replace view v_$system_parameter as select * from v$system_parameter;
create or replace public synonym v$system_parameter for v_$system_parameter;
grant select on v_$system_parameter to select_catalog_role;

create or replace view v_$system_parameter2 as select * from v$system_parameter2;
create or replace public synonym v$system_parameter2 for v_$system_parameter2;
grant select on v_$system_parameter2 to select_catalog_role;

create or replace view gv_$system_reset_parameter as
  select * from gv$system_reset_parameter;
create or replace public synonym gv$system_reset_parameter
  for gv_$system_reset_parameter;
grant select on gv_$system_reset_parameter to select_catalog_role;

create or replace view v_$system_reset_parameter as
  select * from v$system_reset_parameter;
create or replace public synonym v$system_reset_parameter
  for v_$system_reset_parameter;
grant select on v_$system_reset_parameter to select_catalog_role;

create or replace view gv_$system_reset_parameter2 as
  select * from gv$system_reset_parameter2;
create or replace public synonym gv$system_reset_parameter2
  for gv_$system_reset_parameter2;
grant select on gv_$system_reset_parameter2 to select_catalog_role;

create or replace view v_$system_reset_parameter2 as
  select * from v$system_reset_parameter2;
create or replace public synonym v$system_reset_parameter2
  for v_$system_reset_parameter2;
grant select on v_$system_reset_parameter2 to select_catalog_role;

create or replace view v_$spparameter as select * from v$spparameter;
create or replace public synonym v$spparameter for v_$spparameter;
grant select on v_$spparameter to select_catalog_role;

create or replace view v_$parameter_valid_values 
       as select * from v$parameter_valid_values;
create or replace public synonym v$parameter_valid_values 
       for v_$parameter_valid_values;
grant select on v_$parameter_valid_values to select_catalog_role;

create or replace view v_$rowcache as select * from v$rowcache;
create or replace public synonym v$rowcache for v_$rowcache;
grant select on v_$rowcache to select_catalog_role;

create or replace view v_$rowcache_parent as select * from v$rowcache_parent;
create or replace public synonym v$rowcache_parent for v_$rowcache_parent;
grant select on v_$rowcache_parent to select_catalog_role;

create or replace view v_$rowcache_subordinate as
  select * from v$rowcache_subordinate;
create or replace public synonym v$rowcache_subordinate
   for v_$rowcache_subordinate;
grant select on v_$rowcache_subordinate to select_catalog_role;

create or replace view v_$enabledprivs as select * from v$enabledprivs;
create or replace public synonym v$enabledprivs for v_$enabledprivs;
grant select on v_$enabledprivs to select_catalog_role;

create or replace view v_$nls_parameters as select * from v$nls_parameters;
create or replace public synonym v$nls_parameters for v_$nls_parameters;
grant read on v_$nls_parameters to public;

create or replace view v_$nls_valid_values as
select * from v$nls_valid_values;
create or replace public synonym v$nls_valid_values for v_$nls_valid_values;
grant read on v_$nls_valid_values to public;

create or replace view v_$librarycache as select * from v$librarycache;
create or replace public synonym v$librarycache for v_$librarycache;
grant select on v_$librarycache to select_catalog_role;

create or replace view v_$libcache_locks as select * from v$libcache_locks;
create or replace public synonym v$libcache_locks for v_$libcache_locks;
grant select on v_$libcache_locks to select_catalog_role;

create or replace view v_$type_size as select * from v$type_size;
create or replace public synonym v$type_size for v_$type_size;
grant select on v_$type_size to select_catalog_role;

create or replace view v_$archive as select * from v$archive;
create or replace public synonym v$archive for v_$archive;
grant select on v_$archive to select_catalog_role;

create or replace view v_$circuit as select * from v$circuit;
create or replace public synonym v$circuit for v_$circuit;
grant select on v_$circuit to select_catalog_role;

create or replace view v_$database as select * from v$database;
create or replace public synonym v$database for v_$database;
grant select on v_$database to select_catalog_role;

create or replace view v_$instance as select * from v$instance;
create or replace public synonym v$instance for v_$instance;
grant select on v_$instance to select_catalog_role;

create or replace view v_$dispatcher as select * from v$dispatcher;
create or replace public synonym v$dispatcher for v_$dispatcher;
grant select on v_$dispatcher to select_catalog_role;

create or replace view v_$dispatcher_config
  as select * from v$dispatcher_config;
create or replace public synonym v$dispatcher_config for v_$dispatcher_config;
grant select on v_$dispatcher_config to select_catalog_role;

create or replace view v_$dispatcher_rate as select * from v$dispatcher_rate;
create or replace public synonym v$dispatcher_rate for v_$dispatcher_rate;
grant select on v_$dispatcher_rate to select_catalog_role;

create or replace view v_$loghist as select * from v$loghist;
create or replace public synonym v$loghist for v_$loghist;
grant select on v_$loghist to select_catalog_role;

REM create or replace view v_$plsarea as select * from v$plsarea;
REM create or replace public synonym v$plsarea for v_$plsarea;

create or replace view v_$sqlarea as select * from v$sqlarea;
create or replace public synonym v$sqlarea for v_$sqlarea;
grant select on v_$sqlarea to select_catalog_role;

create or replace view v_$sqlarea_plan_hash 
        as select * from v$sqlarea_plan_hash;
create or replace public synonym v$sqlarea_plan_hash for v_$sqlarea_plan_hash;
grant select on v_$sqlarea_plan_hash to select_catalog_role;

create or replace view v_$sqltext as select * from v$sqltext;
create or replace public synonym v$sqltext for v_$sqltext;
grant select on v_$sqltext to select_catalog_role;

create or replace view v_$sqltext_with_newlines as
      select * from v$sqltext_with_newlines;
create or replace public synonym v$sqltext_with_newlines
   for v_$sqltext_with_newlines;
grant select on v_$sqltext_with_newlines to select_catalog_role;

create or replace view v_$sql as select * from v$sql;
create or replace public synonym v$sql for v_$sql;
grant select on v_$sql to select_catalog_role;

create or replace view v_$sql_shared_cursor as select * from v$sql_shared_cursor;
create or replace public synonym v$sql_shared_cursor for v_$sql_shared_cursor;
grant select on v_$sql_shared_cursor to select_catalog_role;

create or replace view v_$db_pipes as select * from v$db_pipes;
create or replace public synonym v$db_pipes for v_$db_pipes;
grant select on v_$db_pipes to select_catalog_role;

create or replace view v_$db_object_cache as select * from v$db_object_cache;
create or replace public synonym v$db_object_cache for v_$db_object_cache;
grant select on v_$db_object_cache to select_catalog_role;

create or replace view v_$open_cursor as select * from v$open_cursor;
create or replace public synonym v$open_cursor for v_$open_cursor;
grant select on v_$open_cursor to select_catalog_role;

create or replace view v_$option as select * from v$option;
create or replace public synonym v$option for v_$option;
grant read on v_$option to public;

create or replace view v_$version as select * from v$version;
create or replace public synonym v$version for v_$version;
grant read on v_$version to public;

create or replace view v_$pq_sesstat as select * from v$pq_sesstat;
create or replace public synonym v$pq_sesstat for v_$pq_sesstat;
grant read on v_$pq_sesstat to public;

create or replace view v_$pq_sysstat as select * from v$pq_sysstat;
create or replace public synonym v$pq_sysstat for v_$pq_sysstat;
grant select on v_$pq_sysstat to select_catalog_role;

create or replace view v_$pq_slave as select * from v$pq_slave;
create or replace public synonym v$pq_slave for v_$pq_slave;
grant select on v_$pq_slave to select_catalog_role;

create or replace view v_$queue as select * from v$queue;
create or replace public synonym v$queue for v_$queue;
grant select on v_$queue to select_catalog_role;

create or replace view v_$shared_server_monitor as select * from v$shared_server_monitor;
create or replace public synonym v$shared_server_monitor
   for v_$shared_server_monitor;
grant select on v_$shared_server_monitor to select_catalog_role;

create or replace view v_$dblink as select * from v$dblink;
create or replace public synonym v$dblink for v_$dblink;
grant select on v_$dblink to select_catalog_role;

create or replace view v_$pwfile_users as select * from v$pwfile_users;
create or replace public synonym v$pwfile_users for v_$pwfile_users;
grant select on v_$pwfile_users to select_catalog_role;

create or replace view v_$passwordfile_info as select * from v$passwordfile_info;
create or replace public synonym v$passwordfile_info for v_$passwordfile_info;
grant select on v_$passwordfile_info to select_catalog_role;

create or replace view v_$reqdist as select * from v$reqdist;
create or replace public synonym v$reqdist for v_$reqdist;
grant select on v_$reqdist to select_catalog_role;

create or replace view v_$sgastat as select * from v$sgastat;
create or replace public synonym v$sgastat for v_$sgastat;
grant select on v_$sgastat to select_catalog_role;

create or replace view v_$sgainfo as select * from v$sgainfo;
create or replace public synonym v$sgainfo for v_$sgainfo;
grant select on v_$sgainfo to select_catalog_role;

create or replace view v_$waitstat as select * from v$waitstat;
create or replace public synonym v$waitstat for v_$waitstat;
grant select on v_$waitstat to select_catalog_role;

create or replace view v_$shared_server as select * from v$shared_server;
create or replace public synonym v$shared_server for v_$shared_server;
grant select on v_$shared_server to select_catalog_role;

create or replace view v_$timer as select * from v$timer;
create or replace public synonym v$timer for v_$timer;
grant select on v_$timer to select_catalog_role;

create or replace view v_$recover_file as select * from v$recover_file;
create or replace public synonym v$recover_file for v_$recover_file;
grant select on v_$recover_file to select_catalog_role;

create or replace view v_$backup as select * from v$backup;
create or replace public synonym v$backup for v_$backup;
grant select on v_$backup to select_catalog_role;


create or replace view v_$backup_set as select * from v$backup_set;
create or replace public synonym v$backup_set for v_$backup_set;
grant select on v_$backup_set to select_catalog_role;

create or replace view v_$backup_piece as select * from v$backup_piece;
create or replace public synonym v$backup_piece for v_$backup_piece;
grant select on v_$backup_piece to select_catalog_role;

create or replace view v_$backup_datafile as select * from v$backup_datafile;
create or replace public synonym v$backup_datafile for v_$backup_datafile;
grant select on v_$backup_datafile to select_catalog_role;

create or replace view v_$backup_spfile as select * from v$backup_spfile;
create or replace public synonym v$backup_spfile for v_$backup_spfile;
grant select on v_$backup_spfile to select_catalog_role;

create or replace view v_$backup_redolog as select * from v$backup_redolog;
create or replace public synonym v$backup_redolog for v_$backup_redolog;
grant select on v_$backup_redolog to select_catalog_role;

create or replace view v_$backup_corruption as select * from v$backup_corruption;
create or replace public synonym v$backup_corruption for v_$backup_corruption;
grant select on v_$backup_corruption to select_catalog_role;

create or replace view v_$copy_corruption as select * from v$copy_corruption;
create or replace public synonym v$copy_corruption for v_$copy_corruption;
grant select on v_$copy_corruption to select_catalog_role;

create or replace view v_$database_block_corruption as select * from
   v$database_block_corruption;
create or replace public synonym v$database_block_corruption
   for v_$database_block_corruption;
grant select on v_$database_block_corruption to select_catalog_role;

create or replace view v_$mttr_target_advice as select * from
   v$mttr_target_advice;
create or replace public synonym v$mttr_target_advice
   for v_$mttr_target_advice;
grant select on v_$mttr_target_advice to select_catalog_role;

create or replace view v_$statistics_level as select * from
   v$statistics_level;
create or replace public synonym v$statistics_level
   for v_$statistics_level;
grant select on v_$statistics_level to select_catalog_role;

create or replace view v_$deleted_object as select * from v$deleted_object;
create or replace public synonym v$deleted_object for v_$deleted_object;
grant select on v_$deleted_object to select_catalog_role;

create or replace view v_$proxy_datafile as select * from v$proxy_datafile;
create or replace public synonym v$proxy_datafile for v_$proxy_datafile;
grant select on v_$proxy_datafile to select_catalog_role;

create or replace view v_$proxy_archivedlog as select * from v$proxy_archivedlog;
create or replace public synonym v$proxy_archivedlog for v_$proxy_archivedlog;
grant select on v_$proxy_archivedlog to select_catalog_role;

create or replace view v_$controlfile_record_section as select * from v$controlfile_record_section;
create or replace public synonym v$controlfile_record_section
   for v_$controlfile_record_section;
grant select on v_$controlfile_record_section to select_catalog_role;

create or replace view v_$archived_log as select * from v$archived_log;
create or replace public synonym v$archived_log for v_$archived_log;
grant select on v_$archived_log to select_catalog_role;

create or replace view v_$foreign_archived_log as select * from v$foreign_archived_log;
create or replace public synonym v$foreign_archived_log for v_$foreign_archived_log;
grant select on v_$foreign_archived_log to select_catalog_role;

create or replace view v_$offline_range as select * from v$offline_range;
create or replace public synonym v$offline_range for v_$offline_range;
grant select on v_$offline_range to select_catalog_role;

create or replace view v_$datafile_copy as select * from v$datafile_copy;
create or replace public synonym v$datafile_copy for v_$datafile_copy;
grant select on v_$datafile_copy to select_catalog_role;

create or replace view v_$log_history as select * from v$log_history;
create or replace public synonym v$log_history for v_$log_history;
grant select on v_$log_history to select_catalog_role;

create or replace view v_$recovery_log as select * from v$recovery_log;
create or replace public synonym v$recovery_log for v_$recovery_log;
grant select on v_$recovery_log to select_catalog_role;

create or replace view v_$archive_gap as select * from v$archive_gap;
create or replace public synonym v$archive_gap for v_$archive_gap;
grant select on v_$archive_gap to select_catalog_role;

create or replace view v_$datafile_header as select * from v$datafile_header;
create or replace public synonym v$datafile_header for v_$datafile_header;
grant select on v_$datafile_header to select_catalog_role;

create or replace view v_$datafile as select * from v$datafile;
create or replace public synonym v$datafile for v_$datafile;
grant select on v_$datafile to SELECT_CATALOG_ROLE;

create or replace view v_$tempfile as select * from v$tempfile;
create or replace public synonym v$tempfile for v_$tempfile;
grant select on v_$tempfile to SELECT_CATALOG_ROLE;

create or replace view v_$tablespace as select * from v$tablespace;
create or replace public synonym v$tablespace for v_$tablespace;
grant select on v_$tablespace to select_catalog_role;

create or replace view v_$backup_device as select * from v$backup_device;
create or replace public synonym v$backup_device for v_$backup_device;
grant select on v_$backup_device to select_catalog_role;

create or replace view v_$managed_standby as select * from v$managed_standby;
create or replace public synonym v$managed_standby for v_$managed_standby;
grant select on v_$managed_standby to select_catalog_role;

create or replace view v_$archive_processes as select * from v$archive_processes;
create or replace public synonym v$archive_processes for v_$archive_processes;
grant select on v_$archive_processes to select_catalog_role;

create or replace view v_$archive_dest as select * from v$archive_dest;
create or replace public synonym v$archive_dest for v_$archive_dest;
grant select on v_$archive_dest to select_catalog_role;

create or replace view v_$redo_dest_resp_histogram as 
  select * from v$redo_dest_resp_histogram;
create or replace public synonym v$redo_dest_resp_histogram for 
  v_$redo_dest_resp_histogram;
grant select on v_$redo_dest_resp_histogram to select_catalog_role;

create or replace view v_$dataguard_config as select * from v$dataguard_config;
create or replace public synonym v$dataguard_config for v_$dataguard_config;
grant select on v_$dataguard_config to select_catalog_role;

create or replace view v_$dataguard_stats as select * from v$dataguard_stats;
create or replace public synonym v$dataguard_stats for v_$dataguard_stats;
grant select on v_$dataguard_stats to select_catalog_role;

create or replace view v_$fixed_table as select * from v$fixed_table;
create or replace public synonym v$fixed_table for v_$fixed_table;
grant select on v_$fixed_table to select_catalog_role;

create or replace view v_$fixed_view_definition as
   select * from v$fixed_view_definition;
create or replace public synonym v$fixed_view_definition
   for v_$fixed_view_definition;
grant select on v_$fixed_view_definition to select_catalog_role;

create or replace view v_$indexed_fixed_column as
  select * from v$indexed_fixed_column;
create or replace public synonym v$indexed_fixed_column
   for v_$indexed_fixed_column;
grant select on v_$indexed_fixed_column to select_catalog_role;

create or replace view v_$session_cursor_cache as
  select * from v$session_cursor_cache;
create or replace public synonym v$session_cursor_cache
   for v_$session_cursor_cache;
grant select on v_$session_cursor_cache to select_catalog_role;

create or replace view v_$session_wait_class as
  select * from v$session_wait_class;
create or replace public synonym v$session_wait_class for v_$session_wait_class;
grant select on v_$session_wait_class to select_catalog_role;

create or replace view v_$session_wait as
  select * from v$session_wait;
create or replace public synonym v$session_wait for v_$session_wait;
grant select on v_$session_wait to select_catalog_role;

create or replace view v_$session_wait_history as
  select * from v$session_wait_history;
create or replace public synonym v$session_wait_history for
  v_$session_wait_history;
grant select on v_$session_wait_history to select_catalog_role;
 
create or replace view v_$session_blockers as
  select * from v$session_blockers;
create or replace public synonym v$session_blockers for
  v_$session_blockers;
grant select on v_$session_blockers to select_catalog_role; 

create or replace view v_$wait_chains as
  select * from v$wait_chains;
create or replace public synonym v$wait_chains for v_$wait_chains;
grant select on v_$wait_chains to select_catalog_role;

create or replace view v_$session_event as
  select * from v$session_event;
create or replace public synonym v$session_event for v_$session_event;
grant select on v_$session_event to select_catalog_role;

create or replace view v_$session_connect_info as
  select * from v$session_connect_info;
create or replace public synonym v$session_connect_info
   for v_$session_connect_info;
grant read on v_$session_connect_info to public;

create or replace view v_$system_wait_class as
  select * from v$system_wait_class;
create or replace public synonym v$system_wait_class for v_$system_wait_class;
grant select on v_$system_wait_class to select_catalog_role;

create or replace view v_$con_system_wait_class as
  select * from v$con_system_wait_class;
create or replace public synonym v$con_system_wait_class 
  for v_$con_system_wait_class;
grant select on v_$con_system_wait_class to select_catalog_role;

create or replace view v_$system_event as
  select * from v$system_event;
create or replace public synonym v$system_event for v_$system_event;
grant select on v_$system_event to select_catalog_role;

create or replace view v_$con_system_event as
  select * from v$con_system_event;
create or replace public synonym v$con_system_event for v_$con_system_event;
grant select on v_$con_system_event to select_catalog_role;

create or replace view v_$event_name as
  select * from v$event_name;
create or replace public synonym v$event_name for v_$event_name;
grant select on v_$event_name to select_catalog_role;

create or replace view v_$event_histogram as
  select * from v$event_histogram;
create or replace public synonym v$event_histogram for v_$event_histogram;
grant select on v_$event_histogram to select_catalog_role;

create or replace view v_$event_histogram_micro as
  select * from v$event_histogram_micro;
create or replace public synonym v$event_histogram_micro 
  for v_$event_histogram_micro;
grant select on v_$event_histogram_micro to select_catalog_role;

create or replace view v_$con_event_histogram_micro as
  select * from v$con_event_histogram_micro;
create or replace public synonym v$con_event_histogram_micro 
  for v_$con_event_histogram_micro;
grant select on v_$con_event_histogram_micro to select_catalog_role;

create or replace view v_$event_outliers as
  select * from v$event_outliers;
create or replace public synonym v$event_outliers 
  for v_$event_outliers;
grant select on v_$event_outliers to select_catalog_role;

create or replace view v_$file_histogram as
  select * from v$file_histogram;
create or replace public synonym v$file_histogram for v_$file_histogram;
grant select on v_$file_histogram to select_catalog_role;

create or replace view v_$file_optimized_histogram as
  select * from v$file_optimized_histogram;
create or replace public synonym v$file_optimized_histogram 
  for v_$file_optimized_histogram;
grant select on v_$file_optimized_histogram to select_catalog_role;

create or replace view v_$execution as
  select * from v$execution;
create or replace public synonym v$execution for v_$execution;
grant select on v_$execution to select_catalog_role;

create or replace view v_$system_cursor_cache as
  select * from v$system_cursor_cache;
create or replace public synonym v$system_cursor_cache
   for v_$system_cursor_cache;
grant select on v_$system_cursor_cache to select_catalog_role;

create or replace view v_$sess_io as
  select * from v$sess_io;
create or replace public synonym v$sess_io for v_$sess_io;
grant select on v_$sess_io to select_catalog_role;

create or replace view v_$recovery_status as
  select * from v$recovery_status;
create or replace public synonym v$recovery_status for v_$recovery_status;
grant select on v_$recovery_status to select_catalog_role;

create or replace view v_$recovery_file_status as
  select * from v$recovery_file_status;
create or replace public synonym v$recovery_file_status
   for v_$recovery_file_status;
grant select on v_$recovery_file_status to select_catalog_role;

create or replace view v_$recovery_progress as
  select * from v$recovery_progress;
create or replace public synonym v$recovery_progress for v_$recovery_progress;
grant select on v_$recovery_progress to select_catalog_role;

create or replace view v_$shared_pool_reserved as
  select * from v$shared_pool_reserved;
create or replace public synonym v$shared_pool_reserved
   for v_$shared_pool_reserved;
grant select on v_$shared_pool_reserved to select_catalog_role;

create or replace view v_$sort_segment as select * from v$sort_segment;
create or replace public synonym v$sort_segment for v_$sort_segment;
grant select on v_$sort_segment to select_catalog_role;

create or replace view v_$sort_usage as select * from v$sort_usage;
create or replace public synonym v$tempseg_usage for v_$sort_usage;
create or replace public synonym v$sort_usage for v_$sort_usage;
grant select on v_$sort_usage to select_catalog_role;

create or replace view v_$resource_limit as select * from v$resource_limit;
create or replace public synonym v$resource_limit for v_$resource_limit;
grant select on v_$resource_limit to select_catalog_role;

create or replace view v_$enqueue_lock as select * from v$enqueue_lock;
create or replace public synonym v$enqueue_lock for v_$enqueue_lock;
grant select on v_$enqueue_lock to select_catalog_role;

create or replace view v_$transaction_enqueue as select * from v$transaction_enqueue;
create or replace public synonym v$transaction_enqueue
   for v_$transaction_enqueue;
grant select on v_$transaction_enqueue to select_catalog_role;

create or replace view v_$pq_tqstat as select * from v$pq_tqstat;
create or replace public synonym v$pq_tqstat for v_$pq_tqstat;
grant read on v_$pq_tqstat to public;

create or replace view v_$active_instances as select * from v$active_instances;
create or replace public synonym v$active_instances for v_$active_instances;
grant read on v_$active_instances to public;

create or replace view v_$sql_cursor as select * from v$sql_cursor;
create or replace public synonym v$sql_cursor for v_$sql_cursor;
grant select on v_$sql_cursor to select_catalog_role;

create or replace view v_$sql_bind_metadata as
  select * from v$sql_bind_metadata;
create or replace public synonym v$sql_bind_metadata for v_$sql_bind_metadata;
grant select on v_$sql_bind_metadata to select_catalog_role;

create or replace view v_$sql_bind_data as select * from v$sql_bind_data;
create or replace public synonym v$sql_bind_data for v_$sql_bind_data;
grant select on v_$sql_bind_data to select_catalog_role;

create or replace view v_$sql_shared_memory
  as select * from v$sql_shared_memory;
create or replace public synonym v$sql_shared_memory for v_$sql_shared_memory;
grant select on v_$sql_shared_memory to select_catalog_role;

create or replace view v_$global_transaction
  as select * from v$global_transaction;
create or replace public synonym v$global_transaction
   for v_$global_transaction;
grant select on v_$global_transaction to select_catalog_role;

create or replace view v_$session_object_cache as
  select * from v$session_object_cache;
create or replace public synonym v$session_object_cache
   for v_$session_object_cache;
grant select on v_$session_object_cache to select_catalog_role;

CREATE OR replace VIEW v_$kccfe AS
  SELECT * FROM x$kccfe;
GRANT SELECT ON v_$kccfe TO select_catalog_role;

CREATE OR replace VIEW v_$kccdi AS
  SELECT * FROM x$kccdi;
GRANT SELECT ON v_$kccdi TO select_catalog_role;

create or replace view v_$lock_activity as
  select * from v$lock_activity;
create or replace public synonym v$lock_activity for v_$lock_activity;
grant read on v_$lock_activity to public;

create or replace view v_$aq1 as
  select * from v$aq1;
create or replace public synonym v$aq1 for v_$aq1;
grant select on v_$aq1 to select_catalog_role;

create or replace view v_$hs_agent as
  select * from v$hs_agent;
create or replace public synonym v$hs_agent for v_$hs_agent;
grant select on v_$hs_agent to select_catalog_role;

create or replace view v_$hs_session as
  select * from v$hs_session;
create or replace public synonym v$hs_session for v_$hs_session;
grant select on v_$hs_session to select_catalog_role;

create or replace view v_$hs_parameter as
  select * from v$hs_parameter;
create or replace public synonym v$hs_parameter for v_$hs_parameter;
grant select on v_$hs_parameter to select_catalog_role;

create or replace view v_$rsrc_consumer_group_cpu_mth as
  select * from v$rsrc_consumer_group_cpu_mth;
create or replace public synonym v$rsrc_consumer_group_cpu_mth
   for v_$rsrc_consumer_group_cpu_mth;
grant read on v_$rsrc_consumer_group_cpu_mth to public;

create or replace view v_$rsrc_plan_cpu_mth as
  select * from v$rsrc_plan_cpu_mth;
create or replace public synonym v$rsrc_plan_cpu_mth for v_$rsrc_plan_cpu_mth;
grant read on v_$rsrc_plan_cpu_mth to public;

create or replace view v_$rsrc_consumer_group as
  select * from v$rsrc_consumer_group;
create or replace public synonym v$rsrc_consumer_group
   for v_$rsrc_consumer_group;
grant read on v_$rsrc_consumer_group to public;

create or replace view v_$rsrc_session_info as
  select * from v$rsrc_session_info;
create or replace public synonym v$rsrc_session_info
   for v_$rsrc_session_info;
grant read on v_$rsrc_session_info to public;

create or replace view v_$rsrc_plan as
  select * from v$rsrc_plan;
create or replace public synonym v$rsrc_plan for v_$rsrc_plan;
grant read on v_$rsrc_plan to public;

create or replace view v_$rsrc_cons_group_history as
  select * from v$rsrc_cons_group_history;
create or replace public synonym v$rsrc_cons_group_history 
  for v_$rsrc_cons_group_history;
grant read on v_$rsrc_cons_group_history to public;

create or replace view v_$rsrc_plan_history as
  select * from v$rsrc_plan_history;
create or replace public synonym v$rsrc_plan_history for v_$rsrc_plan_history;
grant read on v_$rsrc_plan_history to public;

create or replace view v_$blocking_quiesce as
  select * from v$blocking_quiesce;
create or replace public synonym v$blocking_quiesce
   for v_$blocking_quiesce;
grant read on v_$blocking_quiesce to public;

create or replace view v_$px_buffer_advice as
  select * from v$px_buffer_advice;
create or replace public synonym v$px_buffer_advice for v_$px_buffer_advice;
grant select on v_$px_buffer_advice to select_catalog_role;

create or replace view v_$px_session as
  select * from v$px_session;
create or replace public synonym v$px_session for v_$px_session;
grant select on v_$px_session to select_catalog_role;

create or replace view v_$px_sesstat as
  select * from v$px_sesstat;
create or replace public synonym v$px_sesstat for v_$px_sesstat;
grant select on v_$px_sesstat to select_catalog_role;

create or replace view v_$backup_sync_io as
  select * from v$backup_sync_io;
create or replace public synonym v$backup_sync_io for v_$backup_sync_io;
grant select on v_$backup_sync_io to select_catalog_role;

create or replace view v_$backup_async_io as
  select * from v$backup_async_io;
create or replace public synonym v$backup_async_io for v_$backup_async_io;
grant select on v_$backup_async_io to select_catalog_role;

create or replace view v_$temporary_lobs as select * from v$temporary_lobs;
create or replace public synonym v$temporary_lobs for v_$temporary_lobs;
grant read on v_$temporary_lobs to public;

create or replace view v_$px_process as
  select * from v$px_process;
create or replace public synonym v$px_process for v_$px_process;
grant select on v_$px_process to select_catalog_role;

create or replace view v_$px_process_sysstat as
  select * from v$px_process_sysstat;
create or replace public synonym v$px_process_sysstat for v_$px_process_sysstat;
grant select on v_$px_process_sysstat to select_catalog_role;

create or replace view v_$px_process_trace 
  as select * from v$px_process_trace;
create or replace public synonym v$px_process_trace
  for v_$px_process_trace;
grant select on v_$px_process_trace to select_catalog_role;

create or replace view gv_$px_process_trace 
  as select * from gv$px_process_trace;
create or replace public synonym gv$px_process_trace
  for gv_$px_process_trace;
grant select on gv_$px_process_trace to select_catalog_role;

create or replace view v_$logmnr_contents as
  select * from v$logmnr_contents;
create or replace public synonym v$logmnr_contents for v_$logmnr_contents;
grant select on v_$logmnr_contents to select_catalog_role;

create or replace view v_$logmnr_parameters as
  select * from v$logmnr_parameters;
create or replace public synonym v$logmnr_parameters for v_$logmnr_parameters;
grant select on v_$logmnr_parameters to select_catalog_role;

create or replace view v_$logmnr_dictionary as
  select * from v$logmnr_dictionary;
create or replace public synonym v$logmnr_dictionary for v_$logmnr_dictionary;
grant select on v_$logmnr_dictionary to select_catalog_role;

create or replace view v_$logmnr_logs as
  select * from v$logmnr_logs;
create or replace public synonym v$logmnr_logs for v_$logmnr_logs;
grant select on v_$logmnr_logs to select_catalog_role;

create or replace view v_$logmnr_stats as select * from v$logmnr_stats;
create or replace public synonym v$logmnr_stats for v_$logmnr_stats;
grant select on v_$logmnr_stats to select_catalog_role;

create or replace view v_$logmnr_dictionary_load as
  select * from v$logmnr_dictionary_load;
create or replace public synonym v$logmnr_dictionary_load
  for v_$logmnr_dictionary_load;
grant select on v_$logmnr_dictionary_load to select_catalog_role;

create or replace view v_$rfs_thread as
  select * from v$rfs_thread;
create or replace public synonym v$rfs_thread
  for v_$rfs_thread;
grant select on v_$rfs_thread to select_catalog_role;

create or replace view v_$standby_event_histogram as
  select * from v$standby_event_histogram;
create or replace public synonym v$standby_event_histogram
  for v_$standby_event_histogram;
grant select on v_$standby_event_histogram to select_catalog_role;

create or replace view v_$global_blocked_locks as
select * from v$global_blocked_locks;
create or replace public synonym v$global_blocked_locks
   for v_$global_blocked_locks;
grant select on v_$global_blocked_locks to select_catalog_role;

create or replace view v_$aw_olap as select * from v$aw_olap;
create or replace public synonym v$aw_olap for v_$aw_olap;
grant select on v_$aw_olap to select_catalog_role;

create or replace view v_$aw_calc as select * from v$aw_calc;
create or replace public synonym v$aw_calc for v_$aw_calc;
grant select on v_$aw_calc to select_catalog_role;

create or replace view v_$aw_session_info as select * from v$aw_session_info;
create or replace public synonym v$aw_session_info for v_$aw_session_info;
grant select on v_$aw_session_info to select_catalog_role;

create or replace view gv_$aw_aggregate_op as select * from gv$aw_aggregate_op;
create or replace public synonym gv$aw_aggregate_op for gv_$aw_aggregate_op;
grant select on gv_$aw_aggregate_op to select_catalog_role;

create or replace view v_$aw_aggregate_op as select * from v$aw_aggregate_op;
create or replace public synonym v$aw_aggregate_op for v_$aw_aggregate_op;
grant select on v_$aw_aggregate_op to select_catalog_role;

create or replace view gv_$aw_allocate_op as select * from gv$aw_allocate_op;
create or replace public synonym gv$aw_allocate_op for gv_$aw_allocate_op;
grant select on gv_$aw_allocate_op to select_catalog_role;

create or replace view v_$aw_allocate_op as select * from v$aw_allocate_op;
create or replace public synonym v$aw_allocate_op for v_$aw_allocate_op;
grant select on v_$aw_allocate_op to select_catalog_role;

create or replace view v_$aw_longops as select * from v$aw_longops;
create or replace public synonym v$aw_longops for v_$aw_longops;
grant read on v_$aw_longops to public;

create or replace view v_$max_active_sess_target_mth as
  select * from v$max_active_sess_target_mth;
create or replace public synonym v$max_active_sess_target_mth
   for v_$max_active_sess_target_mth;
grant read on v_$max_active_sess_target_mth to public;

create or replace view v_$active_sess_pool_mth as
  select * from v$active_sess_pool_mth;
create or replace public synonym v$active_sess_pool_mth
   for v_$active_sess_pool_mth;
grant read on v_$active_sess_pool_mth to public;


create or replace view v_$parallel_degree_limit_mth as
  select * from v$parallel_degree_limit_mth;
create or replace public synonym v$parallel_degree_limit_mth
   for v_$parallel_degree_limit_mth;
grant read on v_$parallel_degree_limit_mth to public;

create or replace view v_$queueing_mth as
  select * from v$queueing_mth;
create or replace public synonym v$queueing_mth for v_$queueing_mth;
grant read on v_$queueing_mth to public;

create or replace view v_$reserved_words as
  select * from v$reserved_words;
create or replace public synonym v$reserved_words for v_$reserved_words;
grant select on v_$reserved_words to select_catalog_role;

create or replace view v_$archive_dest_status as select * from v$archive_dest_status;
create or replace public synonym v$archive_dest_status
   for v_$archive_dest_status;
grant select on v_$archive_dest_status to select_catalog_role;

create or replace view v_$db_cache_advice as select * from v$db_cache_advice;
create or replace public synonym v$db_cache_advice for v_$db_cache_advice;
grant select on v_$db_cache_advice to select_catalog_role;

create or replace view v_$sga_target_advice as 
  select * from v$sga_target_advice;
create or replace public synonym v$sga_target_advice for v_$sga_target_advice;
grant select on v_$sga_target_advice to select_catalog_role;

create or replace view v_$memory_target_advice as
  select * from v$memory_target_advice;
create or replace public synonym v$memory_target_advice 
  for v_$memory_target_advice;
grant select on v_$memory_target_advice to select_catalog_role;

create or replace view v_$memory_resize_ops as
  select * from v$memory_resize_ops;
create or replace public synonym v$memory_resize_ops for v_$memory_resize_ops;
grant select on v_$memory_resize_ops to select_catalog_role;

create or replace view v_$memory_current_resize_ops as
  select * from v$memory_current_resize_ops;
create or replace public synonym v$memory_current_resize_ops 
  for v_$memory_current_resize_ops;
grant select on v_$memory_current_resize_ops to select_catalog_role;

create or replace view v_$memory_dynamic_components as
  select * from v$memory_dynamic_components;
create or replace public synonym v$memory_dynamic_components 
  for v_$memory_dynamic_components;
grant select on v_$memory_dynamic_components to select_catalog_role;

create or replace view gv_$memory_target_advice as
  select * from gv$memory_target_advice;
create or replace public synonym gv$memory_target_advice 
  for gv_$memory_target_advice;
grant select on gv_$memory_target_advice to select_catalog_role;

create or replace view gv_$memory_resize_ops as
  select * from gv$memory_resize_ops;
create or replace public synonym gv$memory_resize_ops 
  for gv_$memory_resize_ops;
grant select on gv_$memory_resize_ops to select_catalog_role;

create or replace view gv_$memory_current_resize_ops as
  select * from gv$memory_current_resize_ops;
create or replace public synonym gv$memory_current_resize_ops 
  for gv_$memory_current_resize_ops;
grant select on gv_$memory_current_resize_ops to select_catalog_role;

create or replace view gv_$memory_dynamic_components as
  select * from gv$memory_dynamic_components;
create or replace public synonym gv$memory_dynamic_components 
  for gv_$memory_dynamic_components;
grant select on gv_$memory_dynamic_components to select_catalog_role;

create or replace view v_$segment_statistics as
  select * from v$segment_statistics;
create or replace public synonym v$segment_statistics
  for v_$segment_statistics;
grant select on v_$segment_statistics to select_catalog_role;


create or replace view v_$segstat_name as
  select * from v$segstat_name;
create or replace public synonym v$segstat_name
  for v_$segstat_name;
grant select on v_$segstat_name to select_catalog_role;

create or replace view v_$segstat as select * from v$segstat;
create or replace public synonym v$segstat for v_$segstat;
grant select on v_$segstat to select_catalog_role;

create or replace view v_$library_cache_memory as
  select * from v$library_cache_memory;
create or replace public synonym v$library_cache_memory
  for v_$library_cache_memory;
grant select on v_$library_cache_memory to select_catalog_role;

create or replace view v_$java_library_cache_memory as
  select * from v$java_library_cache_memory;
create or replace public synonym v$java_library_cache_memory
  for v_$java_library_cache_memory;
grant select on v_$java_library_cache_memory to select_catalog_role;

create or replace view v_$shared_pool_advice as
  select * from v$shared_pool_advice;
create or replace public synonym v$shared_pool_advice
  for v_$shared_pool_advice;
grant select on v_$shared_pool_advice to select_catalog_role;

create or replace view v_$java_pool_advice as
  select * from v$java_pool_advice;
create or replace public synonym v$java_pool_advice
  for v_$java_pool_advice;
grant select on v_$java_pool_advice to select_catalog_role;

create or replace view v_$streams_pool_advice as
  select * from v$streams_pool_advice;
create or replace public synonym v$streams_pool_advice
  for v_$streams_pool_advice;
grant select on v_$streams_pool_advice to select_catalog_role;

create or replace view v_$goldengate_capabilities as
  select * from v$goldengate_capabilities;
create or replace public synonym v$goldengate_capabilities
  for v_$goldengate_capabilities;
grant select on v_$goldengate_capabilities to select_catalog_role;

create or replace view v_$sga_current_resize_ops as
  select * from v$sga_current_resize_ops;
create or replace public synonym v$sga_current_resize_ops
  for v_$sga_current_resize_ops;
grant select on v_$sga_current_resize_ops to select_catalog_role;

create or replace view v_$sga_resize_ops as
  select * from v$sga_resize_ops;
create or replace public synonym v$sga_resize_ops
  for v_$sga_resize_ops;
grant select on v_$sga_resize_ops to select_catalog_role;

create or replace view v_$sga_dynamic_components as
  select * from v$sga_dynamic_components;
create or replace public synonym v$sga_dynamic_components
  for v_$sga_dynamic_components;
grant select on v_$sga_dynamic_components to select_catalog_role;

create or replace view v_$sga_dynamic_free_memory as
  select * from v$sga_dynamic_free_memory;
create or replace public synonym v$sga_dynamic_free_memory
  for v_$sga_dynamic_free_memory;
grant select on v_$sga_dynamic_free_memory to select_catalog_role;

create or replace view v_$resumable as select * from v$resumable;
create or replace public synonym v$resumable for v_$resumable;
grant select on v_$resumable to select_catalog_role;

create or replace view v_$timezone_names as select * from v$timezone_names;
create or replace public synonym v$timezone_names for v_$timezone_names;
grant read on v_$timezone_names to public;

create or replace view v_$timezone_file as select * from v$timezone_file;
create or replace public synonym v$timezone_file for v_$timezone_file;
grant read on v_$timezone_file to public;

create or replace view v_$enqueue_stat as select * from v$enqueue_stat;
create or replace public synonym v$enqueue_stat for v_$enqueue_stat;
grant select on v_$enqueue_stat to select_catalog_role;

create or replace view v_$enqueue_statistics as select * from v$enqueue_statistics;
create or replace public synonym v$enqueue_statistics for v_$enqueue_statistics;
grant select on v_$enqueue_statistics to select_catalog_role;

create or replace view v_$lock_type as select * from v$lock_type;
create or replace public synonym v$lock_type for v_$lock_type;
grant select on v_$lock_type to select_catalog_role;

create or replace view v_$rman_configuration as select * from v$rman_configuration;
create or replace public synonym v$rman_configuration
   for v_$rman_configuration;
grant select on v_$rman_configuration to select_catalog_role;

create or replace view v_$database_incarnation as select * from
   v$database_incarnation;
create or replace public synonym v$database_incarnation
   for v_$database_incarnation;
grant select on v_$database_incarnation to select_catalog_role;

create or replace view v_$metric as select * from v$metric;
create or replace public synonym v$metric for v_$metric;
grant select on v_$metric to select_catalog_role;

create or replace view v_$metric_history as
          select * from v$metric_history;
create or replace public synonym v$metric_history for v_$metric_history;
grant select on v_$metric_history to select_catalog_role;

create or replace view v_$sysmetric as select * from v$sysmetric;
create or replace public synonym v$sysmetric for v_$sysmetric;
grant select on v_$sysmetric to select_catalog_role;

create or replace view v_$sysmetric_history as
          select * from v$sysmetric_history;
create or replace public synonym v$sysmetric_history for v_$sysmetric_history;
grant select on v_$sysmetric_history to select_catalog_role;

create or replace view v_$metricname as select * from v$metricname;
create or replace public synonym v$metricname for v_$metricname;
grant select on v_$metricname to select_catalog_role;

create or replace view v_$metricgroup as select * from v$metricgroup;
create or replace public synonym v$metricgroup for v_$metricgroup;
grant select on v_$metricgroup to select_catalog_role;

create or replace view v_$service_wait_class as select * from v$service_wait_class;
create or replace public synonym v$service_wait_class for v_$service_wait_class;
grant select on v_$service_wait_class to select_catalog_role;

create or replace view v_$service_event as select * from v$service_event;
create or replace public synonym v$service_event for v_$service_event;
grant select on v_$service_event to select_catalog_role;

create or replace view v_$active_services as select * from v$active_services;
create or replace public synonym v$active_services for v_$active_services;
grant select on v_$active_services to select_catalog_role;

create or replace view v_$services as select * from v$services;
create or replace public synonym v$services for v_$services;
grant select on v_$services to select_catalog_role;

create or replace view v_$sysmetric_summary as
    select * from v$sysmetric_summary;
create or replace public synonym v$sysmetric_summary
    for v_$sysmetric_summary;
grant select on v_$sysmetric_summary to select_catalog_role;

create or replace view v_$con_sysmetric as
    select * from v$con_sysmetric;
create or replace public synonym v$con_sysmetric
    for v_$con_sysmetric;
grant select on v_$con_sysmetric to select_catalog_role;

create or replace view v_$con_sysmetric_history as
    select * from v$con_sysmetric_history;
create or replace public synonym v$con_sysmetric_history
    for v_$con_sysmetric_history;
grant select on v_$con_sysmetric_history to select_catalog_role;

create or replace view v_$con_sysmetric_summary as
    select * from v$con_sysmetric_summary;
create or replace public synonym v$con_sysmetric_summary
    for v_$con_sysmetric_summary;
grant select on v_$con_sysmetric_summary to select_catalog_role;

create or replace view v_$sessmetric as select * from v$sessmetric;
create or replace public synonym v$sessmetric for v_$sessmetric;
grant select on v_$sessmetric to select_catalog_role;

create or replace view v_$filemetric as select * from v$filemetric;
create or replace public synonym v$filemetric for v_$filemetric;
grant select on v_$filemetric to select_catalog_role;

create or replace view v_$filemetric_history as
    select * from v$filemetric_history;
create or replace public synonym v$filemetric_history
    for v_$filemetric_history;
grant select on v_$filemetric_history to select_catalog_role;

create or replace view v_$eventmetric as select * from v$eventmetric;
create or replace public synonym v$eventmetric for v_$eventmetric;
grant select on v_$eventmetric to select_catalog_role;

create or replace view v_$waitclassmetric as
    select * from v$waitclassmetric;
create or replace public synonym v$waitclassmetric for v_$waitclassmetric;
grant select on v_$waitclassmetric to select_catalog_role;

create or replace view v_$waitclassmetric_history as
    select * from v$waitclassmetric_history;
create or replace public synonym v$waitclassmetric_history
    for v_$waitclassmetric_history;
grant select on v_$waitclassmetric_history to select_catalog_role;

create or replace view v_$servicemetric as select * from v$servicemetric;
create or replace public synonym v$servicemetric for v_$servicemetric;
grant select on v_$servicemetric to select_catalog_role;

create or replace view v_$servicemetric_history
    as select * from v$servicemetric_history;
create or replace public synonym v$servicemetric_history
    for v_$servicemetric_history;
grant select on v_$servicemetric_history to select_catalog_role;

create or replace view v_$iofuncmetric as select * from v$iofuncmetric;
create or replace public synonym v$iofuncmetric for v_$iofuncmetric;
grant select on v_$iofuncmetric to select_catalog_role;

create or replace view v_$iofuncmetric_history
    as select * from v$iofuncmetric_history;
create or replace public synonym v$iofuncmetric_history
    for v_$iofuncmetric_history;
grant select on v_$iofuncmetric_history to select_catalog_role;

create or replace view v_$rsrcmgrmetric as select * from v$rsrcmgrmetric;
create or replace public synonym v$rsrcmgrmetric for v_$rsrcmgrmetric;
grant select on v_$rsrcmgrmetric to select_catalog_role;

create or replace view v_$rsrcmgrmetric_history
    as select * from v$rsrcmgrmetric_history;
create or replace public synonym v$rsrcmgrmetric_history
    for v_$rsrcmgrmetric_history;
grant select on v_$rsrcmgrmetric_history to select_catalog_role;

create or replace view v_$rsrcpdbmetric as select * from v$rsrcpdbmetric;
create or replace public synonym v$rsrcpdbmetric for v_$rsrcpdbmetric;
grant select on v_$rsrcpdbmetric to select_catalog_role;

create or replace view v_$rsrcpdbmetric_history
    as select * from v$rsrcpdbmetric_history;
create or replace public synonym v$rsrcpdbmetric_history
    for v_$rsrcpdbmetric_history;
grant select on v_$rsrcpdbmetric_history to select_catalog_role;

create or replace view v_$rsrc_pdb as select * from v$rsrc_pdb;
create or replace public synonym v$rsrc_pdb for v_$rsrc_pdb;
grant select on v_$rsrc_pdb to select_catalog_role;

create or replace view v_$rsrc_pdb_history as select * from v$rsrc_pdb_history;
create or replace public synonym v$rsrc_pdb_history for v_$rsrc_pdb_history;
grant select on v_$rsrc_pdb_history to select_catalog_role;

create or replace view v_$wlm_pcmetric as select * from v$wlm_pcmetric;
create or replace public synonym v$wlm_pcmetric for v_$wlm_pcmetric;
grant select on v_$wlm_pcmetric to select_catalog_role;

create or replace view v_$wlm_pcmetric_history
    as select * from v$wlm_pcmetric_history;
create or replace public synonym v$wlm_pcmetric_history
    for v_$wlm_pcmetric_history;
grant select on v_$wlm_pcmetric_history to select_catalog_role;

create or replace view v_$wlm_pc_stats as select * from v$wlm_pc_stats;
create or replace public synonym v$wlm_pc_stats for v_$wlm_pc_stats;
grant select on v_$wlm_pc_stats to select_catalog_role;

create or replace view v_$wlm_db_mode as select * from v$wlm_db_mode;
create or replace public synonym v$wlm_db_mode for v_$wlm_db_mode;
grant select on v_$wlm_db_mode to select_catalog_role;

create or replace view v_$wlm_pcservice as select * from v$wlm_pcservice;
create or replace public synonym v$wlm_pcservice for v_$wlm_pcservice;
grant select on v_$wlm_pcservice to select_catalog_role;

create or replace view v_$advisor_progress
    as select * from v$advisor_progress;
create or replace public synonym v$advisor_progress
    for v_$advisor_progress;
grant read on v_$advisor_progress to public;

--
-- Add SQL Performance Analyzer (SPA) fixed views
--

create or replace view gv_$sqlpa_metric
    as select * from gv$sqlpa_metric;
create or replace public synonym gv$sqlpa_metric
    for gv_$sqlpa_metric;
grant select on gv_$sqlpa_metric to select_catalog_role;

create or replace view v_$sqlpa_metric
    as select * from v$sqlpa_metric;
create or replace public synonym v$sqlpa_metric
    for v_$sqlpa_metric;
grant read on v_$sqlpa_metric to public;

create or replace view v_$xml_audit_trail
    as select * from v$xml_audit_trail;
create or replace public synonym v$xml_audit_trail
    for v_$xml_audit_trail;
grant select on v_$xml_audit_trail to select_catalog_role;

create or replace view v_$sql_join_filter
    as select * from v$sql_join_filter;
create or replace public synonym v$sql_join_filter
    for v_$sql_join_filter;
grant select on v_$sql_join_filter to select_catalog_role;

create or replace view v_$process_memory as select * from v$process_memory;
create or replace public synonym v$process_memory for v_$process_memory;
grant select on v_$process_memory to select_catalog_role;

create or replace view v_$process_memory_detail
    as select * from v$process_memory_detail;
create or replace public synonym v$process_memory_detail
    for v_$process_memory_detail;
grant select on v_$process_memory_detail to select_catalog_role;

create or replace view v_$process_memory_detail_prog
    as select * from v$process_memory_detail_prog;
create or replace public synonym v$process_memory_detail_prog
    for v_$process_memory_detail_prog;
grant select on v_$process_memory_detail_prog to select_catalog_role;

create or replace view v_$sqlstats as select * from v$sqlstats;
create or replace public synonym v$sqlstats for v_$sqlstats;
grant select on v_$sqlstats to select_catalog_role;

create or replace view v_$sqlstats_plan_hash as select * from v$sqlstats_plan_hash;
create or replace public synonym v$sqlstats_plan_hash for v_$sqlstats_plan_hash;
grant select on v_$sqlstats_plan_hash to select_catalog_role;

create or replace view v_$mutex_sleep as select * from v$mutex_sleep;
create or replace public synonym v$mutex_sleep for v_$mutex_sleep;
grant select on v_$mutex_sleep to select_catalog_role;

create or replace view v_$mutex_sleep_history as
      select * from v$mutex_sleep_history;
create or replace public synonym v$mutex_sleep_history
   for v_$mutex_sleep_history;
grant select on v_$mutex_sleep_history to select_catalog_role;

create or replace view v_$object_privilege
       as select * from v$object_privilege;
create or replace public synonym v$object_privilege
       for v_$object_privilege;
grant select on v_$object_privilege to select_catalog_role;


create or replace view v_$calltag as select * from v$calltag;
create or replace public synonym v$calltag for v_$calltag;
grant select on v_$calltag to select_catalog_role;

create or replace view v_$process_group
       as select * from v$process_group;
create or replace public synonym v$process_group
       for v_$process_group;
grant select on v_$process_group to select_catalog_role;

create or replace view v_$detached_session
       as select * from v$detached_session;
create or replace public synonym v$detached_session
       for v_$detached_session;
grant select on v_$detached_session to select_catalog_role;

create or replace view v_$mapped_sql as select * from v$mapped_sql;
create or replace public synonym v$mapped_sql for v_$mapped_sql;
grant select on v_$mapped_sql to select_catalog_role;

remark Create synonyms for the global fixed views
remark
remark

create or replace view gv_$mutex_sleep as select * from gv$mutex_sleep;
create or replace public synonym gv$mutex_sleep for gv_$mutex_sleep;
grant select on gv_$mutex_sleep to select_catalog_role;

create or replace view gv_$mutex_sleep_history as
      select * from gv$mutex_sleep_history;
create or replace public synonym gv$mutex_sleep_history
   for gv_$mutex_sleep_history;
grant select on gv_$mutex_sleep_history to select_catalog_role;

create or replace view gv_$sqlstats as select * from gv$sqlstats;
create or replace public synonym gv$sqlstats for gv_$sqlstats;
grant select on gv_$sqlstats to select_catalog_role;

create or replace view gv_$sqlstats_plan_hash as select * from gv$sqlstats_plan_hash;
create or replace public synonym gv$sqlstats_plan_hash for gv_$sqlstats_plan_hash;
grant select on gv_$sqlstats_plan_hash to select_catalog_role;

create or replace view gv_$map_library as select * from gv$map_library;
create or replace public synonym gv$map_library for gv_$map_library;
grant select on gv_$map_library to select_catalog_role;

create or replace view gv_$map_file as select * from gv$map_file;
create or replace public synonym gv$map_file for gv_$map_file;
grant select on gv_$map_file to select_catalog_role;

create or replace view gv_$map_file_extent as select * from gv$map_file_extent;
create or replace public synonym gv$map_file_extent for gv_$map_file_extent;
grant select on gv_$map_file_extent to select_catalog_role;

create or replace view gv_$map_element as select * from gv$map_element;
create or replace public synonym gv$map_element for gv_$map_element;
grant select on gv_$map_element to select_catalog_role;

create or replace view gv_$map_ext_element as select * from gv$map_ext_element;
create or replace public synonym gv$map_ext_element for gv_$map_ext_element;
grant select on gv_$map_ext_element to select_catalog_role;

create or replace view gv_$map_comp_list as select * from gv$map_comp_list;
create or replace public synonym gv$map_comp_list for gv_$map_comp_list;
grant select on gv_$map_comp_list to select_catalog_role;

create or replace view gv_$map_subelement as select * from gv$map_subelement;
create or replace public synonym gv$map_subelement for gv_$map_subelement;
grant select on gv_$map_subelement to select_catalog_role;

create or replace view gv_$map_file_io_stack as select * from gv$map_file_io_stack;
create or replace public synonym gv$map_file_io_stack for gv_$map_file_io_stack;
grant select on gv_$map_file_io_stack to select_catalog_role;

create or replace view gv_$bsp as select * from gv$bsp;
create or replace public synonym gv$bsp for gv_$bsp;
grant select on gv_$bsp to select_catalog_role;

create or replace view gv_$obsolete_parameter as
 select * from gv$obsolete_parameter;
create or replace public synonym gv$obsolete_parameter
   for gv_$obsolete_parameter;
grant select on gv_$obsolete_parameter to select_catalog_role;

create or replace view gv_$fast_start_servers
as select * from gv$fast_start_servers;
create or replace public synonym gv$fast_start_servers
   for gv_$fast_start_servers;
grant select on gv_$fast_start_servers to select_catalog_role;

create or replace view gv_$fast_start_transactions
as select * from gv$fast_start_transactions;
create or replace public synonym gv$fast_start_transactions
   for gv_$fast_start_transactions;
grant select on gv_$fast_start_transactions to select_catalog_role;

create or replace view gv_$enqueue_lock as select * from gv$enqueue_lock;
create or replace public synonym gv$enqueue_lock for gv_$enqueue_lock;
grant select on gv_$enqueue_lock to select_catalog_role;

create or replace view gv_$transaction_enqueue as select * from gv$transaction_enqueue;
create or replace public synonym gv$transaction_enqueue
   for gv_$transaction_enqueue;
grant select on gv_$transaction_enqueue to select_catalog_role;

create or replace view gv_$resource_limit as select * from gv$resource_limit;
create or replace public synonym gv$resource_limit for gv_$resource_limit;
grant select on gv_$resource_limit to select_catalog_role;

create or replace view gv_$sql_redirection as select * from gv$sql_redirection;
create or replace public synonym gv$sql_redirection for gv_$sql_redirection;
grant select on gv_$sql_redirection to select_catalog_role;

create or replace view gv_$sql_plan as select * from gv$sql_plan;
create or replace public synonym gv$sql_plan for gv_$sql_plan;
grant select on gv_$sql_plan to select_catalog_role;

create or replace view gv_$sql_plan_statistics as
  select * from gv$sql_plan_statistics;
create or replace public synonym gv$sql_plan_statistics
  for gv_$sql_plan_statistics;
grant select on gv_$sql_plan_statistics to select_catalog_role;

create or replace view gv_$sql_plan_statistics_all as
  select * from gv$sql_plan_statistics_all;
create or replace public synonym gv$sql_plan_statistics_all
  for gv_$sql_plan_statistics_all;
grant select on gv_$sql_plan_statistics_all to select_catalog_role;

create or replace view gv_$advisor_current_sqlplan as
  select * from gv$advisor_current_sqlplan;
create or replace public synonym gv$advisor_current_sqlplan
  for gv_$advisor_current_sqlplan;
grant read on gv_$advisor_current_sqlplan to public;

create or replace view gv_$sql_workarea as select * from gv$sql_workarea;
create or replace public synonym gv$sql_workarea for gv_$sql_workarea;
grant select on gv_$sql_workarea to select_catalog_role;

create or replace view gv_$sql_workarea_active
  as select * from gv$sql_workarea_active;
create or replace public synonym gv$sql_workarea_active
   for gv_$sql_workarea_active;
grant select on gv_$sql_workarea_active to select_catalog_role;

create or replace view gv_$sql_workarea_histogram
  as select * from gv$sql_workarea_histogram;
create or replace public synonym gv$sql_workarea_histogram
   for gv_$sql_workarea_histogram;
grant select on gv_$sql_workarea_histogram to select_catalog_role;

create or replace view gv_$pga_target_advice
  as select * from gv$pga_target_advice;
create or replace public synonym gv$pga_target_advice
  for gv_$pga_target_advice;
grant select on gv_$pga_target_advice to select_catalog_role;

create or replace view gv_$pgatarget_advice_histogram
  as select * from gv$pga_target_advice_histogram;
create or replace public synonym gv$pga_target_advice_histogram
  for gv_$pgatarget_advice_histogram;
grant select on gv_$pgatarget_advice_histogram to select_catalog_role;

create or replace view gv_$pgastat as select * from gv$pgastat;
create or replace public synonym gv$pgastat for gv_$pgastat;
grant select on gv_$pgastat to select_catalog_role;

create or replace view gv_$sys_optimizer_env
  as select * from gv$sys_optimizer_env;
create or replace public synonym gv$sys_optimizer_env for gv_$sys_optimizer_env;
grant select on gv_$sys_optimizer_env to select_catalog_role;

create or replace view gv_$ses_optimizer_env
  as select * from gv$ses_optimizer_env;
create or replace public synonym gv$ses_optimizer_env for gv_$ses_optimizer_env;
grant select on gv_$ses_optimizer_env to select_catalog_role;

create or replace view gv_$sql_optimizer_env
  as select * from gv$sql_optimizer_env;
create or replace public synonym gv$sql_optimizer_env for gv_$sql_optimizer_env;
grant select on gv_$sql_optimizer_env to select_catalog_role;

create or replace view gv_$dlm_misc as select * from gv$dlm_misc;
create or replace public synonym gv$dlm_misc for gv_$dlm_misc;
grant select on gv_$dlm_misc to select_catalog_role;

create or replace view gv_$dlm_latch as select * from gv$dlm_latch;
create or replace public synonym gv$dlm_latch for gv_$dlm_latch;
grant select on gv_$dlm_latch to select_catalog_role;

create or replace view gv_$dlm_convert_local as select * from gv$dlm_convert_local;
create or replace public synonym gv$dlm_convert_local
   for gv_$dlm_convert_local;
grant select on gv_$dlm_convert_local to select_catalog_role;

create or replace view gv_$dlm_convert_remote as select * from gv$dlm_convert_remote;
create or replace public synonym gv$dlm_convert_remote
   for gv_$dlm_convert_remote;
grant select on gv_$dlm_convert_remote to select_catalog_role;

create or replace view gv_$dlm_all_locks as select * from gv$dlm_all_locks;
create or replace public synonym gv$dlm_all_locks for gv_$dlm_all_locks;
grant select on gv_$dlm_all_locks to select_catalog_role;

create or replace view gv_$dlm_locks as select * from gv$dlm_locks;
create or replace public synonym gv$dlm_locks for gv_$dlm_locks;
grant select on gv_$dlm_locks to select_catalog_role;

create or replace view gv_$dlm_ress as select * from gv$dlm_ress;
create or replace public synonym gv$dlm_ress for gv_$dlm_ress;
grant select on gv_$dlm_ress to select_catalog_role;

create or replace view gv_$hvmaster_info as select * from gv$hvmaster_info;
create or replace public synonym gv$hvmaster_info for gv_$hvmaster_info;
grant select on gv_$hvmaster_info to select_catalog_role;

create or replace view gv_$gcshvmaster_info as select * from gv$gcshvmaster_info
;
create or replace public synonym gv$gcshvmaster_info for gv_$gcshvmaster_info;
grant select on gv_$gcshvmaster_info to select_catalog_role;

create or replace view gv_$gcspfmaster_info as
select * from gv$gcspfmaster_info;
create or replace public synonym gv$gcspfmaster_info for gv_$gcspfmaster_info;
grant select on gv_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$ges_enqueue as
select * from gv$ges_enqueue;
create or replace public synonym gv$ges_enqueue for gv_$ges_enqueue;
grant select on gv_$ges_enqueue to select_catalog_role;

create or replace view gv_$ges_blocking_enqueue as
select * from gv$ges_blocking_enqueue;
create or replace public synonym gv$ges_blocking_enqueue
   for gv_$ges_blocking_enqueue;
grant select on gv_$ges_blocking_enqueue to select_catalog_role;

create or replace view gv_$gc_element as
select * from gv$gc_element;
create or replace public synonym gv$gc_element for gv_$gc_element;
grant select on gv_$gc_element to select_catalog_role;

create or replace view gv_$cr_block_server as
select * from gv$cr_block_server;
create or replace public synonym gv$cr_block_server for gv_$cr_block_server;
grant select on gv_$cr_block_server to select_catalog_role;

create or replace view gv_$current_block_server as
select * from gv$current_block_server;
create or replace public synonym gv$current_block_server for gv_$current_block_server;
grant select on gv_$current_block_server to select_catalog_role;

create or replace view gv_$policy_history as
select * from gv$policy_history;
create or replace public synonym gv$policy_history for gv_$policy_history;
grant select on gv_$policy_history to select_catalog_role;

create or replace view gv_$gc_elements_w_collisions as
select * from gv$gc_elements_with_collisions;
create or replace public synonym gv$gc_elements_with_collisions for
gv_$gc_elements_w_collisions;
grant select on gv_$gc_elements_w_collisions to select_catalog_role;

create or replace view gv_$file_cache_transfer as
select * from gv$file_cache_transfer;
create or replace public synonym gv$file_cache_transfer
   for gv_$file_cache_transfer;
grant select on gv_$file_cache_transfer to select_catalog_role;

create or replace view gv_$temp_cache_transfer as
select * from gv$temp_cache_transfer;
create or replace public synonym gv$temp_cache_transfer for gv_$temp_cache_transfer;
grant select on gv_$temp_cache_transfer to select_catalog_role;

create or replace view gv_$class_cache_transfer as
select * from gv$class_cache_transfer;
create or replace public synonym gv$class_cache_transfer for gv_$class_cache_transfer;
grant select on gv_$class_cache_transfer to select_catalog_role;

create or replace view gv_$bh as select * from gv$bh;
create or replace public synonym gv$bh for gv_$bh;
grant read on gv_$bh to public;

create or replace view gv_$sqlfn_metadata as
select * from gv$sqlfn_metadata;
create or replace public synonym gv$sqlfn_metadata
   for gv_$sqlfn_metadata;
grant read on gv_$sqlfn_metadata to public;

create or replace view gv_$sqlfn_arg_metadata as
select * from gv$sqlfn_arg_metadata;
create or replace public synonym gv$sqlfn_arg_metadata
   for gv_$sqlfn_arg_metadata;
grant read on gv_$sqlfn_arg_metadata to public;

create or replace view gv_$lock_element as select * from gv$lock_element;
create or replace public synonym gv$lock_element for gv_$lock_element;
grant select on gv_$lock_element to select_catalog_role;

create or replace view gv_$locks_with_collisions as select * from gv$locks_with_collisions;
create or replace public synonym gv$locks_with_collisions
   for gv_$locks_with_collisions;
grant select on gv_$locks_with_collisions to select_catalog_role;

create or replace view gv_$file_ping as select * from gv$file_ping;
create or replace public synonym gv$file_ping for gv_$file_ping;
grant select on gv_$file_ping to select_catalog_role;

create or replace view gv_$temp_ping as select * from gv$temp_ping;
create or replace public synonym gv$temp_ping for gv_$temp_ping;
grant select on gv_$temp_ping to select_catalog_role;

create or replace view gv_$class_ping as select * from gv$class_ping;
create or replace public synonym gv$class_ping for gv_$class_ping;
grant select on gv_$class_ping to select_catalog_role;

create or replace view gv_$instance_cache_transfer as
select * from gv$instance_cache_transfer;
create or replace public synonym gv$instance_cache_transfer for gv_$instance_cache_transfer;
grant select on gv_$instance_cache_transfer to select_catalog_role;

create or replace view gv_$buffer_pool as select * from gv$buffer_pool;
create or replace public synonym gv$buffer_pool for gv_$buffer_pool;
grant select on gv_$buffer_pool to select_catalog_role;

create or replace view gv_$buffer_pool_statistics as select * from gv$buffer_pool_statistics;
create or replace public synonym gv$buffer_pool_statistics
   for gv_$buffer_pool_statistics;
grant select on gv_$buffer_pool_statistics to select_catalog_role;

create or replace view gv_$instance_recovery as select * from gv$instance_recovery;
create or replace public synonym gv$instance_recovery
   for gv_$instance_recovery;
grant select on gv_$instance_recovery to select_catalog_role;

create or replace view gv_$controlfile as select * from gv$controlfile;
create or replace public synonym gv$controlfile for gv_$controlfile;
grant select on gv_$controlfile to select_catalog_role;

create or replace view gv_$log as select * from gv$log;
create or replace public synonym gv$log for gv_$log;
grant select on gv_$log to SELECT_CATALOG_ROLE;

create or replace view gv_$standby_log as select * from gv$standby_log;
create or replace public synonym gv$standby_log for gv_$standby_log;
grant select on gv_$standby_log to SELECT_CATALOG_ROLE;

create or replace view gv_$dataguard_status as select * from gv$dataguard_status;
create or replace public synonym gv$dataguard_status for gv_$dataguard_status;
grant select on gv_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view gv_$thread as select * from gv$thread;
create or replace public synonym gv$thread for gv_$thread;
grant select on gv_$thread to select_catalog_role;

create or replace view gv_$process as select * from gv$process;
create or replace public synonym gv$process for gv_$process;
grant select on gv_$process to select_catalog_role;

create or replace view gv_$bgprocess as select * from gv$bgprocess;
create or replace public synonym gv$bgprocess for gv_$bgprocess;
grant select on gv_$bgprocess to select_catalog_role;

create or replace view gv_$session as select * from gv$session;
create or replace public synonym gv$session for gv_$session;
grant select on gv_$session to select_catalog_role;

create or replace view gv_$license as select * from gv$license;
create or replace public synonym gv$license for gv_$license;
grant select on gv_$license to select_catalog_role;

create or replace view gv_$transaction as select * from gv$transaction;
create or replace public synonym gv$transaction for gv_$transaction;
grant select on gv_$transaction to select_catalog_role;

create or replace view gv_$locked_object as select * from gv$locked_object;
create or replace public synonym gv$locked_object for gv_$locked_object;
grant select on gv_$locked_object to select_catalog_role;

create or replace view gv_$latch as select * from gv$latch;
create or replace public synonym gv$latch for gv_$latch;
grant select on gv_$latch to select_catalog_role;

create or replace view gv_$latch_children as select * from gv$latch_children;
create or replace public synonym gv$latch_children for gv_$latch_children;
grant select on gv_$latch_children to select_catalog_role;

create or replace view gv_$latch_parent as select * from gv$latch_parent;
create or replace public synonym gv$latch_parent for gv_$latch_parent;
grant select on gv_$latch_parent to select_catalog_role;

create or replace view gv_$latchname as select * from gv$latchname;
create or replace public synonym gv$latchname for gv_$latchname;
grant select on gv_$latchname to select_catalog_role;

create or replace view gv_$latchholder as select * from gv$latchholder;
create or replace public synonym gv$latchholder for gv_$latchholder;
grant select on gv_$latchholder to select_catalog_role;

create or replace view gv_$latch_misses as select * from gv$latch_misses;
create or replace public synonym gv$latch_misses for gv_$latch_misses;
grant select on gv_$latch_misses to select_catalog_role;

create or replace view gv_$session_longops as select * from gv$session_longops;
create or replace public synonym gv$session_longops for gv_$session_longops;
grant read on gv_$session_longops to public;

create or replace view gv_$resource as select * from gv$resource;
create or replace public synonym gv$resource for gv_$resource;
grant select on gv_$resource to select_catalog_role;

create or replace view gv_$_lock as select * from gv$_lock;
create or replace public synonym gv$_lock for gv_$_lock;
grant select on gv_$_lock to select_catalog_role;

create or replace view gv_$lock as select * from gv$lock;
create or replace public synonym gv$lock for gv_$lock;
grant select on gv_$lock to select_catalog_role;

create or replace view gv_$sesstat as select * from gv$sesstat;
create or replace public synonym gv$sesstat for gv_$sesstat;
grant select on gv_$sesstat to select_catalog_role;

create or replace view gv_$mystat as select * from gv$mystat;
create or replace public synonym gv$mystat for gv_$mystat;
grant select on gv_$mystat to select_catalog_role;

create or replace view gv_$subcache as select * from gv$subcache;
create or replace public synonym gv$subcache for gv_$subcache;
grant select on gv_$subcache to select_catalog_role;

create or replace view gv_$sysstat as select * from gv$sysstat;
create or replace public synonym gv$sysstat for gv_$sysstat;
grant select on gv_$sysstat to select_catalog_role;

create or replace view gv_$con_sysstat as select * from gv$con_sysstat;
create or replace public synonym gv$con_sysstat for gv_$con_sysstat;
grant select on gv_$con_sysstat to select_catalog_role;

create or replace view gv_$statname as select * from gv$statname;
create or replace public synonym gv$statname for gv_$statname;
grant select on gv_$statname to select_catalog_role;

create or replace view gv_$osstat as select * from gv$osstat;
create or replace public synonym gv$osstat for gv_$osstat;
grant select on gv_$osstat to select_catalog_role;

create or replace view gv_$access as select * from gv$access;
create or replace public synonym gv$access for gv_$access;
grant select on gv_$access to select_catalog_role;

create or replace view gv_$object_dependency as
  select * from gv$object_dependency;
create or replace public synonym gv$object_dependency
   for gv_$object_dependency;
grant select on gv_$object_dependency to select_catalog_role;

create or replace view gv_$dbfile as select * from gv$dbfile;
create or replace public synonym gv$dbfile for gv_$dbfile;
grant select on gv_$dbfile to select_catalog_role;

create or replace view gv_$datafile as select * from gv$datafile;
create or replace public synonym gv$datafile for gv_$datafile;
grant select on gv_$datafile to SELECT_CATALOG_ROLE;

create or replace view gv_$tempfile as select * from gv$tempfile;
create or replace public synonym gv$tempfile for gv_$tempfile;
grant select on gv_$tempfile to SELECT_CATALOG_ROLE;

create or replace view gv_$tablespace as select * from gv$tablespace;
create or replace public synonym gv$tablespace for gv_$tablespace;
grant select on gv_$tablespace to select_catalog_role;

create or replace view gv_$flashfilestat as select * from gv$flashfilestat;
create or replace public synonym gv$flashfilestat for gv_$flashfilestat;
grant select on gv_$flashfilestat to select_catalog_role;

create or replace view gv_$filestat as select * from gv$filestat;
create or replace public synonym gv$filestat for gv_$filestat;
grant select on gv_$filestat to select_catalog_role;

create or replace view gv_$tempstat as select * from gv$tempstat;
create or replace public synonym gv$tempstat for gv_$tempstat;
grant select on gv_$tempstat to select_catalog_role;

create or replace view gv_$logfile as select * from gv$logfile;
create or replace public synonym gv$logfile for gv_$logfile;
grant select on gv_$logfile to select_catalog_role;

create or replace view gv_$flashback_database_logfile as
  select * from gv$flashback_database_logfile;
create or replace public synonym gv$flashback_database_logfile
  for gv_$flashback_database_logfile;
grant select on gv_$flashback_database_logfile to select_catalog_role;

create or replace view gv_$flashback_database_log as
  select * from gv$flashback_database_log;
create or replace public synonym gv$flashback_database_log
  for gv_$flashback_database_log;
grant select on gv_$flashback_database_log to select_catalog_role;

create or replace view gv_$flashback_database_stat as
  select * from gv$flashback_database_stat;
create or replace public synonym gv$flashback_database_stat
  for gv_$flashback_database_stat;
grant select on gv_$flashback_database_stat to select_catalog_role;

create or replace view gv_$restore_point as
  select * from gv$restore_point;
create or replace public synonym gv$restore_point
  for gv_$restore_point;
grant read on gv_$restore_point to public;

remark This is bad for gv$ views.  Need to fix or just forget -msc-
remark create or replace view gv_$rollname as select
remark     x$kturd.kturdusn usn, undo$.name, x$kturd.con_id
remark   from x$kturd, undo$
remark   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
remark create or replace public synonym gv$rollname for gv_$rollname;
remark grant select on gv_$rollname to select_catalog_role;

create or replace view gv_$rollstat as select * from gv$rollstat;
create or replace public synonym gv$rollstat for gv_$rollstat;
grant select on gv_$rollstat to select_catalog_role;

create or replace view gv_$undostat as select * from gv$undostat;
create or replace public synonym gv$undostat for gv_$undostat;
grant select on gv_$undostat to select_catalog_role;

create or replace view gv_$sga as select * from gv$sga;
create or replace public synonym gv$sga for gv_$sga;
grant select on gv_$sga to select_catalog_role;

create or replace view gv_$cluster_interconnects 
       as select * from gv$cluster_interconnects;
create or replace public synonym gv$cluster_interconnects 
        for gv_$cluster_interconnects;
grant select on gv_$cluster_interconnects to select_catalog_role;

create or replace view gv_$configured_interconnects 
       as select * from gv$configured_interconnects;
create or replace public synonym gv$configured_interconnects 
       for gv_$configured_interconnects;
grant select on gv_$configured_interconnects to select_catalog_role;

create or replace view gv_$parameter as select * from gv$parameter;
create or replace public synonym gv$parameter for gv_$parameter;
grant select on gv_$parameter to select_catalog_role;

create or replace view gv_$parameter2 as select * from gv$parameter2;
create or replace public synonym gv$parameter2 for gv_$parameter2;
grant select on gv_$parameter2 to select_catalog_role;

create or replace view gv_$system_parameter as select * from gv$system_parameter;
create or replace public synonym gv$system_parameter for gv_$system_parameter;
grant select on gv_$system_parameter to select_catalog_role;

create or replace view gv_$system_parameter2 as select * from gv$system_parameter2;
create or replace public synonym gv$system_parameter2
   for gv_$system_parameter2;
grant select on gv_$system_parameter2 to select_catalog_role;

create or replace view gv_$spparameter as select * from gv$spparameter;
create or replace public synonym gv$spparameter for gv_$spparameter;
grant select on gv_$spparameter to select_catalog_role;

create or replace view gv_$parameter_valid_values 
       as select * from gv$parameter_valid_values;
create or replace public synonym gv$parameter_valid_values 
       for gv_$parameter_valid_values;
grant select on gv_$parameter_valid_values to select_catalog_role;

create or replace view gv_$rowcache as select * from gv$rowcache;
create or replace public synonym gv$rowcache for gv_$rowcache;
grant select on gv_$rowcache to select_catalog_role;

create or replace view gv_$rowcache_parent as select * from gv$rowcache_parent;
create or replace public synonym gv$rowcache_parent for gv_$rowcache_parent;
grant select on gv_$rowcache_parent to select_catalog_role;

create or replace view gv_$rowcache_subordinate as
  select * from gv$rowcache_subordinate;
create or replace public synonym gv$rowcache_subordinate
   for gv_$rowcache_subordinate;
grant select on gv_$rowcache_subordinate to select_catalog_role;

create or replace view gv_$enabledprivs as select * from gv$enabledprivs;
create or replace public synonym gv$enabledprivs for gv_$enabledprivs;
grant select on gv_$enabledprivs to select_catalog_role;

create or replace view gv_$nls_parameters as select * from gv$nls_parameters;
create or replace public synonym gv$nls_parameters for gv_$nls_parameters;
grant read on gv_$nls_parameters to public;

create or replace view gv_$nls_valid_values as
select * from gv$nls_valid_values;
create or replace public synonym gv$nls_valid_values for gv_$nls_valid_values;
grant read on gv_$nls_valid_values to public;

create or replace view gv_$librarycache as select * from gv$librarycache;
create or replace public synonym gv$librarycache for gv_$librarycache;
grant select on gv_$librarycache to select_catalog_role;

create or replace view gv_$libcache_locks as select * from gv$libcache_locks;
create or replace public synonym gv$libcache_locks for gv_$libcache_locks;
grant select on gv_$libcache_locks to select_catalog_role;

create or replace view gv_$type_size as select * from gv$type_size;
create or replace public synonym gv$type_size for gv_$type_size;
grant select on gv_$type_size to select_catalog_role;

create or replace view gv_$archive as select * from gv$archive;
create or replace public synonym gv$archive for gv_$archive;
grant select on gv_$archive to select_catalog_role;

create or replace view gv_$circuit as select * from gv$circuit;
create or replace public synonym gv$circuit for gv_$circuit;
grant select on gv_$circuit to select_catalog_role;

create or replace view gv_$database as select * from gv$database;
create or replace public synonym gv$database for gv_$database;
grant select on gv_$database to select_catalog_role;

create or replace view gv_$instance as select * from gv$instance;
create or replace public synonym gv$instance for gv_$instance;
grant select on gv_$instance to select_catalog_role;

create or replace view gv_$dispatcher as select * from gv$dispatcher;
create or replace public synonym gv$dispatcher for gv_$dispatcher;
grant select on gv_$dispatcher to select_catalog_role;

create or replace view gv_$dispatcher_config
  as select * from gv$dispatcher_config;
create or replace public synonym gv$dispatcher_config
  for gv_$dispatcher_config;
grant select on gv_$dispatcher_config to select_catalog_role;

create or replace view gv_$dispatcher_rate as select * from gv$dispatcher_rate;
create or replace public synonym gv$dispatcher_rate for gv_$dispatcher_rate;
grant select on gv_$dispatcher_rate to select_catalog_role;

create or replace view gv_$loghist as select * from gv$loghist;
create or replace public synonym gv$loghist for gv_$loghist;
grant select on gv_$loghist to select_catalog_role;

REM create or replace view gv_$plsarea as select * from gv$plsarea;
REM create or replace public synonym gv$plsarea for gv_$plsarea;

create or replace view gv_$sqlarea as select * from gv$sqlarea;
create or replace public synonym gv$sqlarea for gv_$sqlarea;
grant select on gv_$sqlarea to select_catalog_role;

create or replace view gv_$sqlarea_plan_hash 
        as select * from gv$sqlarea_plan_hash;
create or replace public synonym gv$sqlarea_plan_hash for gv_$sqlarea_plan_hash;
grant select on gv_$sqlarea_plan_hash to select_catalog_role;

create or replace view gv_$sqltext as select * from gv$sqltext;
create or replace public synonym gv$sqltext for gv_$sqltext;
grant select on gv_$sqltext to select_catalog_role;

create or replace view gv_$sqltext_with_newlines as
      select * from gv$sqltext_with_newlines;
create or replace public synonym gv$sqltext_with_newlines
   for gv_$sqltext_with_newlines;
grant select on gv_$sqltext_with_newlines to select_catalog_role;

create or replace view gv_$sql as select * from gv$sql;
create or replace public synonym gv$sql for gv_$sql;
grant select on gv_$sql to select_catalog_role;

create or replace view gv_$sql_shared_cursor as select * from gv$sql_shared_cursor;
create or replace public synonym gv$sql_shared_cursor for gv_$sql_shared_cursor;
grant select on gv_$sql_shared_cursor to select_catalog_role;

create or replace view gv_$db_pipes as select * from gv$db_pipes;
create or replace public synonym gv$db_pipes for gv_$db_pipes;
grant select on gv_$db_pipes to select_catalog_role;

create or replace view gv_$db_object_cache as select * from gv$db_object_cache;
create or replace public synonym gv$db_object_cache for gv_$db_object_cache;
grant select on gv_$db_object_cache to select_catalog_role;

create or replace view gv_$open_cursor as select * from gv$open_cursor;
create or replace public synonym gv$open_cursor for gv_$open_cursor;
grant select on gv_$open_cursor to select_catalog_role;

create or replace view gv_$option as select * from gv$option;
create or replace public synonym gv$option for gv_$option;
grant read on gv_$option to public;

create or replace view gv_$version as select * from gv$version;
create or replace public synonym gv$version for gv_$version;
grant read on gv_$version to public;

create or replace view gv_$pq_sesstat as select * from gv$pq_sesstat;
create or replace public synonym gv$pq_sesstat for gv_$pq_sesstat;
grant read on gv_$pq_sesstat to public;

create or replace view gv_$pq_sysstat as select * from gv$pq_sysstat;
create or replace public synonym gv$pq_sysstat for gv_$pq_sysstat;
grant select on gv_$pq_sysstat to select_catalog_role;

create or replace view gv_$pq_slave as select * from gv$pq_slave;
create or replace public synonym gv$pq_slave for gv_$pq_slave;
grant select on gv_$pq_slave to select_catalog_role;

create or replace view gv_$queue as select * from gv$queue;
create or replace public synonym gv$queue for gv_$queue;
grant select on gv_$queue to select_catalog_role;

create or replace view gv_$shared_server_monitor as select * from gv$shared_server_monitor;
create or replace public synonym gv$shared_server_monitor
   for gv_$shared_server_monitor;
grant select on gv_$shared_server_monitor to select_catalog_role;

create or replace view gv_$dblink as select * from gv$dblink;
create or replace public synonym gv$dblink for gv_$dblink;
grant select on gv_$dblink to select_catalog_role;

create or replace view gv_$pwfile_users as select * from gv$pwfile_users;
create or replace public synonym gv$pwfile_users for gv_$pwfile_users;
grant select on gv_$pwfile_users to select_catalog_role;

create or replace view gv_$passwordfile_info as select * from gv$passwordfile_info;
create or replace public synonym gv$passwordfile_info for gv_$passwordfile_info;
grant select on gv_$passwordfile_info to select_catalog_role;

create or replace view gv_$reqdist as select * from gv$reqdist;
create or replace public synonym gv$reqdist for gv_$reqdist;
grant select on gv_$reqdist to select_catalog_role;

create or replace view gv_$sgastat as select * from gv$sgastat;
create or replace public synonym gv$sgastat for gv_$sgastat;
grant select on gv_$sgastat to select_catalog_role;

create or replace view gv_$sgainfo as select * from gv$sgainfo;
create or replace public synonym gv$sgainfo for gv_$sgainfo;
grant select on gv_$sgainfo to select_catalog_role;

create or replace view gv_$waitstat as select * from gv$waitstat;
create or replace public synonym gv$waitstat for gv_$waitstat;
grant select on gv_$waitstat to select_catalog_role;

create or replace view gv_$shared_server as select * from gv$shared_server;
create or replace public synonym gv$shared_server for gv_$shared_server;
grant select on gv_$shared_server to select_catalog_role;

create or replace view gv_$timer as select * from gv$timer;
create or replace public synonym gv$timer for gv_$timer;
grant select on gv_$timer to select_catalog_role;

create or replace view gv_$recover_file as select * from gv$recover_file;
create or replace public synonym gv$recover_file for gv_$recover_file;
grant select on gv_$recover_file to select_catalog_role;

create or replace view gv_$backup as select * from gv$backup;
create or replace public synonym gv$backup for gv_$backup;
grant select on gv_$backup to select_catalog_role;


create or replace view gv_$backup_set as select * from gv$backup_set;
create or replace public synonym gv$backup_set for gv_$backup_set;
grant select on gv_$backup_set to select_catalog_role;

create or replace view gv_$backup_piece as select * from gv$backup_piece;
create or replace public synonym gv$backup_piece for gv_$backup_piece;
grant select on gv_$backup_piece to select_catalog_role;

create or replace view gv_$backup_datafile as select * from gv$backup_datafile;
create or replace public synonym gv$backup_datafile for gv_$backup_datafile;
grant select on gv_$backup_datafile to select_catalog_role;

create or replace view gv_$backup_spfile as select * from gv$backup_spfile;
create or replace public synonym gv$backup_spfile for gv_$backup_spfile;
grant select on gv_$backup_spfile to select_catalog_role;

create or replace view gv_$backup_redolog as select * from gv$backup_redolog;
create or replace public synonym gv$backup_redolog for gv_$backup_redolog;
grant select on gv_$backup_redolog to select_catalog_role;

create or replace view gv_$backup_corruption as select * from gv$backup_corruption;
create or replace public synonym gv$backup_corruption
   for gv_$backup_corruption;
grant select on gv_$backup_corruption to select_catalog_role;

create or replace view gv_$copy_corruption as select * from gv$copy_corruption;
create or replace public synonym gv$copy_corruption for gv_$copy_corruption;
grant select on gv_$copy_corruption to select_catalog_role;

create or replace view gv_$database_block_corruption as select * from
   gv$database_block_corruption;
create or replace public synonym gv$database_block_corruption
   for gv_$database_block_corruption;
grant select on gv_$database_block_corruption to select_catalog_role;

create or replace view gv_$mttr_target_advice as select * from
   gv$mttr_target_advice;
create or replace public synonym gv$mttr_target_advice
   for gv_$mttr_target_advice;
grant select on gv_$mttr_target_advice to select_catalog_role;

create or replace view gv_$statistics_level as select * from
   gv$statistics_level;
create or replace public synonym gv$statistics_level
   for gv_$statistics_level;
grant select on gv_$statistics_level to select_catalog_role;

create or replace view gv_$deleted_object as select * from gv$deleted_object;
create or replace public synonym gv$deleted_object for gv_$deleted_object;
grant select on gv_$deleted_object to select_catalog_role;

create or replace view gv_$proxy_datafile as select * from gv$proxy_datafile;
create or replace public synonym gv$proxy_datafile for gv_$proxy_datafile;
grant select on gv_$proxy_datafile to select_catalog_role;

create or replace view gv_$proxy_archivedlog as select * from gv$proxy_archivedlog;
create or replace public synonym gv$proxy_archivedlog
   for gv_$proxy_archivedlog;
grant select on gv_$proxy_archivedlog to select_catalog_role;

create or replace view gv_$controlfile_record_section as select * from gv$controlfile_record_section;
create or replace public synonym gv$controlfile_record_section
   for gv_$controlfile_record_section;
grant select on gv_$controlfile_record_section to select_catalog_role;

create or replace view gv_$archived_log as select * from gv$archived_log;
create or replace public synonym gv$archived_log for gv_$archived_log;
grant select on gv_$archived_log to select_catalog_role;

create or replace view gv_$foreign_archived_log as select * from gv$foreign_archived_log;
create or replace public synonym gv$foreign_archived_log for gv_$foreign_archived_log;
grant select on gv_$foreign_archived_log to select_catalog_role;

create or replace view gv_$offline_range as select * from gv$offline_range;
create or replace public synonym gv$offline_range for gv_$offline_range;
grant select on gv_$offline_range to select_catalog_role;

create or replace view gv_$datafile_copy as select * from gv$datafile_copy;
create or replace public synonym gv$datafile_copy for gv_$datafile_copy;
grant select on gv_$datafile_copy to select_catalog_role;

create or replace view gv_$log_history as select * from gv$log_history;
create or replace public synonym gv$log_history for gv_$log_history;
grant select on gv_$log_history to select_catalog_role;

create or replace view gv_$recovery_log as select * from gv$recovery_log;
create or replace public synonym gv$recovery_log for gv_$recovery_log;
grant select on gv_$recovery_log to select_catalog_role;

create or replace view gv_$archive_gap as select * from gv$archive_gap;
create or replace public synonym gv$archive_gap for gv_$archive_gap;
grant select on gv_$archive_gap to select_catalog_role;

create or replace view gv_$datafile_header as select * from gv$datafile_header;
create or replace public synonym gv$datafile_header for gv_$datafile_header;
grant select on gv_$datafile_header to select_catalog_role;

create or replace view gv_$backup_device as select * from gv$backup_device;
create or replace public synonym gv$backup_device for gv_$backup_device;
grant select on gv_$backup_device to select_catalog_role;

create or replace view gv_$managed_standby as select * from gv$managed_standby;
create or replace public synonym gv$managed_standby for gv_$managed_standby;
grant select on gv_$managed_standby to select_catalog_role;

create or replace view gv_$archive_processes as select * from gv$archive_processes;
create or replace public synonym gv$archive_processes
   for gv_$archive_processes;
grant select on gv_$archive_processes to select_catalog_role;

create or replace view gv_$archive_dest as select * from gv$archive_dest;
create or replace public synonym gv$archive_dest for gv_$archive_dest;
grant select on gv_$archive_dest to select_catalog_role;

create or replace view gv_$redo_dest_resp_histogram as 
  select * from gv$redo_dest_resp_histogram;
create or replace public synonym gv$redo_dest_resp_histogram for 
  gv_$redo_dest_resp_histogram;
grant select on gv_$redo_dest_resp_histogram to select_catalog_role;

create or replace view gv_$dataguard_config as
   select * from gv$dataguard_config;
create or replace public synonym gv$dataguard_config for gv_$dataguard_config;
grant select on gv_$dataguard_config to select_catalog_role;

create or replace view gv_$fixed_table as select * from gv$fixed_table;
create or replace public synonym gv$fixed_table for gv_$fixed_table;
grant select on gv_$fixed_table to select_catalog_role;

create or replace view gv_$fixed_view_definition as
   select * from gv$fixed_view_definition;
create or replace public synonym gv$fixed_view_definition
   for gv_$fixed_view_definition;
grant select on gv_$fixed_view_definition to select_catalog_role;

create or replace view gv_$indexed_fixed_column as
  select * from gv$indexed_fixed_column;
create or replace public synonym gv$indexed_fixed_column
   for gv_$indexed_fixed_column;
grant select on gv_$indexed_fixed_column to select_catalog_role;

create or replace view gv_$session_cursor_cache as
  select * from gv$session_cursor_cache;
create or replace public synonym gv$session_cursor_cache
   for gv_$session_cursor_cache;
grant select on gv_$session_cursor_cache to select_catalog_role;

create or replace view gv_$session_wait_class as
  select * from gv$session_wait_class;
create or replace public synonym gv$session_wait_class
  for gv_$session_wait_class;
grant select on gv_$session_wait_class to select_catalog_role;

create or replace view gv_$session_wait as
  select * from gv$session_wait;
create or replace public synonym gv$session_wait for gv_$session_wait;
grant select on gv_$session_wait to select_catalog_role;

create or replace view gv_$session_wait_history as
  select * from gv$session_wait_history;
create or replace public synonym gv$session_wait_history
  for gv_$session_wait_history;
grant select on gv_$session_wait_history to select_catalog_role;

create or replace view gv_$session_blockers as
  select * from gv$session_blockers;
create or replace public synonym gv$session_blockers
  for gv_$session_blockers;
grant select on gv_$session_blockers to select_catalog_role; 

create or replace view gv_$session_event as
  select * from gv$session_event;
create or replace public synonym gv$session_event for gv_$session_event;
grant select on gv_$session_event to select_catalog_role;

create or replace view gv_$session_connect_info as
  select * from gv$session_connect_info;
create or replace public synonym gv$session_connect_info
   for gv_$session_connect_info;
grant select on gv_$session_connect_info to select_catalog_role;

create or replace view gv_$system_wait_class as
  select * from gv$system_wait_class;
create or replace public synonym gv$system_wait_class 
  for gv_$system_wait_class;
grant select on gv_$system_wait_class to select_catalog_role;

create or replace view gv_$con_system_wait_class as
  select * from gv$con_system_wait_class;
create or replace public synonym gv$con_system_wait_class 
  for gv_$con_system_wait_class;
grant select on gv_$con_system_wait_class to select_catalog_role;

create or replace view gv_$system_event as
  select * from gv$system_event;
create or replace public synonym gv$system_event for gv_$system_event;
grant select on gv_$system_event to select_catalog_role;

create or replace view gv_$con_system_event as
  select * from gv$con_system_event;
create or replace public synonym gv$con_system_event for gv_$con_system_event;
grant select on gv_$con_system_event to select_catalog_role;

create or replace view gv_$event_name as
  select * from gv$event_name;
create or replace public synonym gv$event_name for gv_$event_name;
grant select on gv_$event_name to select_catalog_role;

create or replace view gv_$event_histogram as
  select * from gv$event_histogram;
create or replace public synonym gv$event_histogram for gv_$event_histogram;
grant select on gv_$event_histogram to select_catalog_role;

create or replace view gv_$event_histogram_micro as
  select * from gv$event_histogram_micro;
create or replace public synonym gv$event_histogram_micro 
  for gv_$event_histogram_micro;
grant select on gv_$event_histogram_micro to select_catalog_role;

create or replace view gv_$con_event_histogram_micro as
  select * from gv$con_event_histogram_micro;
create or replace public synonym gv$con_event_histogram_micro 
  for gv_$con_event_histogram_micro;
grant select on gv_$con_event_histogram_micro to select_catalog_role;

create or replace view gv_$event_outliers as
  select * from gv$event_outliers;
create or replace public synonym gv$event_outliers 
  for gv_$event_outliers;
grant select on gv_$event_outliers to select_catalog_role;

create or replace view gv_$file_histogram as
  select * from gv$file_histogram;
create or replace public synonym gv$file_histogram for gv_$file_histogram;
grant select on gv_$file_histogram to select_catalog_role;

create or replace view gv_$file_optimized_histogram as
  select * from gv$file_optimized_histogram;
create or replace public synonym gv$file_optimized_histogram 
  for gv_$file_optimized_histogram;
grant select on gv_$file_optimized_histogram to select_catalog_role;

create or replace view gv_$execution as
  select * from gv$execution;
create or replace public synonym gv$execution for gv_$execution;
grant select on gv_$execution to select_catalog_role;

create or replace view gv_$system_cursor_cache as
  select * from gv$system_cursor_cache;
create or replace public synonym gv$system_cursor_cache
   for gv_$system_cursor_cache;
grant select on gv_$system_cursor_cache to select_catalog_role;

create or replace view gv_$sess_io as
  select * from gv$sess_io;
create or replace public synonym gv$sess_io for gv_$sess_io;
grant select on gv_$sess_io to select_catalog_role;

create or replace view gv_$recovery_status as
  select * from gv$recovery_status;
create or replace public synonym gv$recovery_status for gv_$recovery_status;
grant select on gv_$recovery_status to select_catalog_role;

create or replace view gv_$recovery_file_status as
  select * from gv$recovery_file_status;
create or replace public synonym gv$recovery_file_status
   for gv_$recovery_file_status;
grant select on gv_$recovery_file_status to select_catalog_role;

create or replace view gv_$recovery_progress as
  select * from gv$recovery_progress;
create or replace public synonym gv$recovery_progress
   for gv_$recovery_progress;
grant select on gv_$recovery_progress to select_catalog_role;

create or replace view gv_$shared_pool_reserved as
  select * from gv$shared_pool_reserved;
create or replace public synonym gv$shared_pool_reserved
   for gv_$shared_pool_reserved;
grant select on gv_$shared_pool_reserved to select_catalog_role;

create or replace view gv_$sort_segment as select * from gv$sort_segment;
create or replace public synonym gv$sort_segment for gv_$sort_segment;
grant select on gv_$sort_segment to select_catalog_role;

create or replace view gv_$sort_usage as select * from gv$sort_usage;
create or replace public synonym gv$tempseg_usage for gv_$sort_usage;
create or replace public synonym gv$sort_usage for gv_$sort_usage;
grant select on gv_$sort_usage to select_catalog_role;

create or replace view gv_$pq_tqstat as select * from gv$pq_tqstat;
create or replace public synonym gv$pq_tqstat for gv_$pq_tqstat;
grant read on gv_$pq_tqstat to public;

create or replace view gv_$active_instances as select * from gv$active_instances;
create or replace public synonym gv$active_instances for gv_$active_instances;
grant read on gv_$active_instances to public;

create or replace view gv_$sql_cursor as select * from gv$sql_cursor;
create or replace public synonym gv$sql_cursor for gv_$sql_cursor;
grant select on gv_$sql_cursor to select_catalog_role;

create or replace view gv_$sql_bind_metadata as
  select * from gv$sql_bind_metadata;
create or replace public synonym gv$sql_bind_metadata
   for gv_$sql_bind_metadata;
grant select on gv_$sql_bind_metadata to select_catalog_role;

create or replace view gv_$sql_bind_data as select * from gv$sql_bind_data;
create or replace public synonym gv$sql_bind_data for gv_$sql_bind_data;
grant select on gv_$sql_bind_data to select_catalog_role;

create or replace view gv_$sql_shared_memory
  as select * from gv$sql_shared_memory;
create or replace public synonym gv$sql_shared_memory
   for gv_$sql_shared_memory;
grant select on gv_$sql_shared_memory to select_catalog_role;

create or replace view gv_$global_transaction
  as select * from gv$global_transaction;
create or replace public synonym gv$global_transaction
   for gv_$global_transaction;
grant select on gv_$global_transaction to select_catalog_role;

create or replace view gv_$session_object_cache as
  select * from gv$session_object_cache;
create or replace public synonym gv$session_object_cache
   for gv_$session_object_cache;
grant select on gv_$session_object_cache to select_catalog_role;

create or replace view gv_$aq1 as
  select * from gv$aq1;
create or replace public synonym gv$aq1 for gv_$aq1;
grant select on gv_$aq1 to select_catalog_role;

create or replace view gv_$lock_activity as
  select * from gv$lock_activity;
create or replace public synonym gv$lock_activity for gv_$lock_activity;
grant read on gv_$lock_activity to public;

create or replace view gv_$hs_agent as
  select * from gv$hs_agent;
create or replace public synonym gv$hs_agent for gv_$hs_agent;
grant select on gv_$hs_agent to select_catalog_role;

create or replace view gv_$hs_session as
  select * from gv$hs_session;
create or replace public synonym gv$hs_session for gv_$hs_session;
grant select on gv_$hs_session to select_catalog_role;

create or replace view gv_$hs_parameter as
  select * from gv$hs_parameter;
create or replace public synonym gv$hs_parameter for gv_$hs_parameter;
grant select on gv_$hs_parameter to select_catalog_role;

create or replace view gv_$rsrc_consume_group_cpu_mth as
  select * from gv$rsrc_consumer_group_cpu_mth;
create or replace public synonym gv$rsrc_consumer_group_cpu_mth
   for gv_$rsrc_consume_group_cpu_mth;
grant read on gv_$rsrc_consume_group_cpu_mth to public;

create or replace view gv_$rsrc_plan_cpu_mth as
  select * from gv$rsrc_plan_cpu_mth;
create or replace public synonym gv$rsrc_plan_cpu_mth
   for gv_$rsrc_plan_cpu_mth;
grant read on gv_$rsrc_plan_cpu_mth to public;

create or replace view gv_$rsrc_consumer_group as
  select * from gv$rsrc_consumer_group;
create or replace public synonym gv$rsrc_consumer_group
   for gv_$rsrc_consumer_group;
grant read on gv_$rsrc_consumer_group to public;

create or replace view gv_$rsrc_session_info as
  select * from gv$rsrc_session_info;
create or replace public synonym gv$rsrc_session_info
   for gv_$rsrc_session_info;
grant read on gv_$rsrc_session_info to public;

create or replace view gv_$rsrc_plan as
  select * from gv$rsrc_plan;
create or replace public synonym gv$rsrc_plan for gv_$rsrc_plan;
grant read on gv_$rsrc_plan to public;

create or replace view gv_$rsrc_cons_group_history as
  select * from gv$rsrc_cons_group_history;
create or replace public synonym gv$rsrc_cons_group_history 
  for gv_$rsrc_cons_group_history;
grant read on gv_$rsrc_cons_group_history to public;

create or replace view gv_$rsrc_plan_history as
  select * from gv$rsrc_plan_history;
create or replace public synonym gv$rsrc_plan_history 
  for gv_$rsrc_plan_history;
grant read on gv_$rsrc_plan_history to public;

create or replace view gv_$blocking_quiesce as
  select * from gv$blocking_quiesce;
create or replace public synonym gv$blocking_quiesce
   for gv_$blocking_quiesce;
grant read on gv_$blocking_quiesce to public;

create or replace view gv_$px_buffer_advice as
  select * from gv$px_buffer_advice;
create or replace public synonym gv$px_buffer_advice for gv_$px_buffer_advice;
grant select on gv_$px_buffer_advice to select_catalog_role;

create or replace view gv_$px_session as
  select * from gv$px_session;
create or replace public synonym gv$px_session for gv_$px_session;
grant select on gv_$px_session to select_catalog_role;

create or replace view gv_$px_sesstat as
  select * from gv$px_sesstat;
create or replace public synonym gv$px_sesstat for gv_$px_sesstat;
grant select on gv_$px_sesstat to select_catalog_role;

create or replace view gv_$backup_sync_io as
  select * from gv$backup_sync_io;
create or replace public synonym gv$backup_sync_io for gv_$backup_sync_io;
grant select on gv_$backup_sync_io to select_catalog_role;

create or replace view gv_$backup_async_io as
  select * from gv$backup_async_io;
create or replace public synonym gv$backup_async_io for gv_$backup_async_io;
grant select on gv_$backup_async_io to select_catalog_role;

create or replace view gv_$temporary_lobs as select * from gv$temporary_lobs;
create or replace public synonym gv$temporary_lobs for gv_$temporary_lobs;
grant read on gv_$temporary_lobs to public;

create or replace view gv_$px_process as
  select * from gv$px_process;
create or replace public synonym gv$px_process for gv_$px_process;
grant select on gv_$px_process to select_catalog_role;

create or replace view gv_$px_process_sysstat as
  select * from gv$px_process_sysstat;
create or replace public synonym gv$px_process_sysstat
   for gv_$px_process_sysstat;
grant select on gv_$px_process_sysstat to select_catalog_role;

create or replace view gv_$logmnr_contents as
  select * from gv$logmnr_contents;
create or replace public synonym gv$logmnr_contents for gv_$logmnr_contents;
grant select on gv_$logmnr_contents to select_catalog_role;

create or replace view gv_$logmnr_parameters as
  select * from gv$logmnr_parameters;
create or replace public synonym gv$logmnr_parameters
   for gv_$logmnr_parameters;
grant select on gv_$logmnr_parameters to select_catalog_role;

create or replace view gv_$logmnr_dictionary as
  select * from gv$logmnr_dictionary;
create or replace public synonym gv$logmnr_dictionary
   for gv_$logmnr_dictionary;
grant select on gv_$logmnr_dictionary to select_catalog_role;

create or replace view gv_$logmnr_logs as
  select * from gv$logmnr_logs;
create or replace public synonym gv$logmnr_logs for gv_$logmnr_logs;
grant select on gv_$logmnr_logs to select_catalog_role;

create or replace view gv_$rfs_thread as
  select * from gv$rfs_thread;
create or replace public synonym gv$rfs_thread for gv_$rfs_thread;
grant select on gv_$rfs_thread to select_catalog_role;

create or replace view gv_$dataguard_stats as select * from gv$dataguard_stats;
create or replace public synonym gv$dataguard_stats for gv_$dataguard_stats;
grant select on gv_$dataguard_stats to select_catalog_role;

create or replace view gv_$global_blocked_locks as
select * from gv$global_blocked_locks;
create or replace public synonym gv$global_blocked_locks
   for gv_$global_blocked_locks;
grant select on gv_$global_blocked_locks to select_catalog_role;

create or replace view gv_$aw_olap as select * from gv$aw_olap;
create or replace public synonym gv$aw_olap for gv_$aw_olap;
grant select on gv_$aw_olap to select_catalog_role;

create or replace view gv_$aw_calc as select * from gv$aw_calc;
create or replace public synonym gv$aw_calc for gv_$aw_calc;
grant select on gv_$aw_calc to select_catalog_role;

create or replace view gv_$aw_session_info as select * from gv$aw_session_info;
create or replace public synonym gv$aw_session_info for gv_$aw_session_info;
grant select on gv_$aw_session_info to select_catalog_role;

create or replace view gv_$aw_longops as select * from gv$aw_longops;
create or replace public synonym gv$aw_longops for gv_$aw_longops;
grant read on gv_$aw_longops to public;

create or replace view gv_$max_active_sess_target_mth as
  select * from gv$max_active_sess_target_mth;
create or replace public synonym gv$max_active_sess_target_mth
   for gv_$max_active_sess_target_mth;
grant read on gv_$max_active_sess_target_mth to public;

create or replace view gv_$active_sess_pool_mth as
  select * from gv$active_sess_pool_mth;
create or replace public synonym gv$active_sess_pool_mth
   for gv_$active_sess_pool_mth;
grant read on gv_$active_sess_pool_mth to public;

create or replace view gv_$parallel_degree_limit_mth as
  select * from gv$parallel_degree_limit_mth;
create or replace public synonym gv$parallel_degree_limit_mth
   for gv_$parallel_degree_limit_mth;
grant read on gv_$parallel_degree_limit_mth to public;

create or replace view gv_$queueing_mth as
  select * from gv$queueing_mth;
create or replace public synonym gv$queueing_mth for gv_$queueing_mth;
grant read on gv_$queueing_mth to public;

create or replace view gv_$reserved_words as
  select * from gv$reserved_words;
create or replace public synonym gv$reserved_words for gv_$reserved_words;
grant select on gv_$reserved_words to select_catalog_role;

create or replace view gv_$archive_dest_status as select * from gv$archive_dest_status;
create or replace public synonym gv$archive_dest_status
   for gv_$archive_dest_status;
grant select on gv_$archive_dest_status to select_catalog_role;


create or replace view v_$logmnr_logfile as
  select * from v$logmnr_logfile;
create or replace public synonym v$logmnr_logfile for v_$logmnr_logfile;
grant select on v_$logmnr_logfile to select_catalog_role;

create or replace view v_$logmnr_process as
  select * from v$logmnr_process;
create or replace public synonym v$logmnr_process for v_$logmnr_process;
grant select on v_$logmnr_process to select_catalog_role;

create or replace view v_$logmnr_latch as
  select * from v$logmnr_latch;
create or replace public synonym v$logmnr_latch for v_$logmnr_latch;
grant select on v_$logmnr_latch to select_catalog_role;

create or replace view v_$logmnr_transaction as
  select * from v$logmnr_transaction;
create or replace public synonym v$logmnr_transaction
   for v_$logmnr_transaction;
grant select on v_$logmnr_transaction to select_catalog_role;

create or replace view v_$logmnr_session as
  select * from v$logmnr_session;
create or replace public synonym v$logmnr_session for v_$logmnr_session;
grant select on v_$logmnr_session to select_catalog_role;


create or replace view gv_$logmnr_logfile as
  select * from gv$logmnr_logfile;
create or replace public synonym gv$logmnr_logfile for gv_$logmnr_logfile;
grant select on gv_$logmnr_logfile to select_catalog_role;

create or replace view gv_$logmnr_process as
  select * from gv$logmnr_process;
create or replace public synonym gv$logmnr_process for gv_$logmnr_process;
grant select on gv_$logmnr_process to select_catalog_role;

create or replace view gv_$logmnr_latch as
  select * from gv$logmnr_latch;
create or replace public synonym gv$logmnr_latch for gv_$logmnr_latch;
grant select on gv_$logmnr_latch to select_catalog_role;

create or replace view gv_$logmnr_transaction as
  select * from gv$logmnr_transaction;
create or replace public synonym gv$logmnr_transaction
   for gv_$logmnr_transaction;
grant select on gv_$logmnr_transaction to select_catalog_role;

create or replace view gv_$logmnr_session as
  select * from gv$logmnr_session;
create or replace public synonym gv$logmnr_session for gv_$logmnr_session;
grant select on gv_$logmnr_session to select_catalog_role;

create or replace view gv_$logmnr_stats as select * from gv$logmnr_stats;
create or replace public synonym gv$logmnr_stats for gv_$logmnr_stats;
grant select on gv_$logmnr_stats to select_catalog_role;

create or replace view gv_$logmnr_dictionary_load as
  select * from gv$logmnr_dictionary_load;
create or replace public synonym gv$logmnr_dictionary_load
  for gv_$logmnr_dictionary_load;
grant select on gv_$logmnr_dictionary_load to select_catalog_role;

create or replace view gv_$db_cache_advice as select * from gv$db_cache_advice;
create or replace public synonym gv$db_cache_advice for gv_$db_cache_advice;
grant select on gv_$db_cache_advice to select_catalog_role;

create or replace view gv_$sga_target_advice as select * from gv$sga_target_advice;
create or replace public synonym gv$sga_target_advice for gv_$sga_target_advice;
grant select on gv_$sga_target_advice to select_catalog_role;

create or replace view gv_$segment_statistics as
  select * from gv$segment_statistics;
create or replace public synonym gv$segment_statistics
  for gv_$segment_statistics;
grant select on gv_$segment_statistics to select_catalog_role;

create or replace view gv_$segstat_name as
  select * from gv$segstat_name;
create or replace public synonym gv$segstat_name
  for gv_$segstat_name;
grant select on gv_$segstat_name to select_catalog_role;

create or replace view gv_$segstat as select * from gv$segstat;
create or replace public synonym gv$segstat for gv_$segstat;
grant select on gv_$segstat to select_catalog_role;

create or replace view gv_$library_cache_memory as
  select * from gv$library_cache_memory;
create or replace public synonym gv$library_cache_memory
  for gv_$library_cache_memory;
grant select on gv_$library_cache_memory to select_catalog_role;

create or replace view gv_$java_library_cache_memory as
  select * from gv$java_library_cache_memory;
create or replace public synonym gv$java_library_cache_memory
  for gv_$java_library_cache_memory;
grant select on gv_$java_library_cache_memory to select_catalog_role;

create or replace view gv_$shared_pool_advice as
  select * from gv$shared_pool_advice;
create or replace public synonym gv$shared_pool_advice
  for gv_$shared_pool_advice;
grant select on gv_$shared_pool_advice to select_catalog_role;

create or replace view gv_$java_pool_advice as
  select * from gv$java_pool_advice;
create or replace public synonym gv$java_pool_advice
  for gv_$java_pool_advice;
grant select on gv_$java_pool_advice to select_catalog_role;

create or replace view gv_$streams_pool_advice as
  select * from gv$streams_pool_advice;
create or replace public synonym gv$streams_pool_advice
  for gv_$streams_pool_advice;
grant select on gv_$streams_pool_advice to select_catalog_role;

create or replace view gv_$goldengate_capabilities as
  select * from gv$goldengate_capabilities;
create or replace public synonym gv$goldengate_capabilities
  for gv_$goldengate_capabilities;
grant select on gv_$goldengate_capabilities to select_catalog_role;

create or replace view gv_$sga_current_resize_ops as
  select * from gv$sga_current_resize_ops;
create or replace public synonym gv$sga_current_resize_ops
  for gv_$sga_current_resize_ops;
grant select on gv_$sga_current_resize_ops to select_catalog_role;

create or replace view gv_$sga_resize_ops as
  select * from gv$sga_resize_ops;
create or replace public synonym gv$sga_resize_ops
  for gv_$sga_resize_ops;
grant select on gv_$sga_resize_ops to select_catalog_role;

create or replace view gv_$sga_dynamic_components as
  select * from gv$sga_dynamic_components;
create or replace public synonym gv$sga_dynamic_components
  for gv_$sga_dynamic_components;
grant select on gv_$sga_dynamic_components to select_catalog_role;

create or replace view gv_$sga_dynamic_free_memory as
  select * from gv$sga_dynamic_free_memory;
create or replace public synonym gv$sga_dynamic_free_memory
  for gv_$sga_dynamic_free_memory;
grant select on gv_$sga_dynamic_free_memory to select_catalog_role;

create or replace view gv_$resumable as select * from gv$resumable;
create or replace public synonym gv$resumable for gv_$resumable;
grant select on gv_$resumable to select_catalog_role;

create or replace view gv_$timezone_names as select * from gv$timezone_names;
create or replace public synonym gv$timezone_names for gv_$timezone_names;
grant read on gv_$timezone_names to public;

create or replace view gv_$timezone_file as select * from gv$timezone_file;
create or replace public synonym gv$timezone_file for gv_$timezone_file;
grant read on gv_$timezone_file to public;

create or replace view gv_$enqueue_stat as select * from gv$enqueue_stat;
create or replace public synonym gv$enqueue_stat for gv_$enqueue_stat;
grant select on gv_$enqueue_stat to select_catalog_role;

create or replace view gv_$enqueue_statistics as select * from gv$enqueue_statistics;
create or replace public synonym gv$enqueue_statistics for gv_$enqueue_statistics;
grant select on gv_$enqueue_statistics to select_catalog_role;

create or replace view gv_$lock_type as select * from gv$lock_type;
create or replace public synonym gv$lock_type for gv_$lock_type;
grant select on gv_$lock_type to select_catalog_role;

create or replace view gv_$rman_configuration as select * from gv$rman_configuration;
create or replace public synonym gv$rman_configuration
   for gv_$rman_configuration;
grant select on gv_$rman_configuration to select_catalog_role;

create or replace view gv_$vpd_policy as
  select * from gv$vpd_policy;
create or replace public synonym gv$vpd_policy for gv_$vpd_policy;
grant select on gv_$vpd_policy to select_catalog_role;

create or replace view v_$vpd_policy as
  select * from v$vpd_policy;
create or replace public synonym v$vpd_policy for v_$vpd_policy;
grant select on v_$vpd_policy to select_catalog_role;

create or replace view gv_$database_incarnation as select * from
   gv$database_incarnation;
create or replace public synonym gv$database_incarnation
   for gv_$database_incarnation;
grant select on gv_$database_incarnation to select_catalog_role;

CREATE or replace VIEW gv_$asm_template as
  SELECT * FROM gv$asm_template;
  CREATE or replace PUBLIC synonym gv$asm_template FOR gv_$asm_template;
  GRANT SELECT ON gv_$asm_template TO select_catalog_role;

  CREATE or replace VIEW v_$asm_template as
    SELECT * FROM v$asm_template;
 CREATE or replace PUBLIC synonym v$asm_template FOR v_$asm_template;
 GRANT SELECT ON v_$asm_template TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_file as
  SELECT * FROM gv$asm_file;
  CREATE or replace PUBLIC synonym gv$asm_file FOR gv_$asm_file;
  GRANT SELECT ON gv_$asm_file TO select_catalog_role;

  CREATE or replace VIEW v_$asm_file as
    SELECT * FROM v$asm_file;
 CREATE or replace PUBLIC synonym v$asm_file FOR v_$asm_file;
 GRANT SELECT ON v_$asm_file TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup as
  SELECT * FROM gv$asm_diskgroup;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup FOR gv_$asm_diskgroup;
  GRANT SELECT ON gv_$asm_diskgroup TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup as
    SELECT * FROM v$asm_diskgroup;
 CREATE or replace PUBLIC synonym v$asm_diskgroup FOR v_$asm_diskgroup;
 GRANT SELECT ON v_$asm_diskgroup TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup_stat as
  SELECT * FROM gv$asm_diskgroup_stat;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup_stat FOR
    gv_$asm_diskgroup_stat;
  GRANT SELECT ON gv_$asm_diskgroup_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup_stat as
    SELECT * FROM v$asm_diskgroup_stat;
 CREATE or replace PUBLIC synonym v$asm_diskgroup_stat FOR
    v_$asm_diskgroup_stat;
 GRANT SELECT ON v_$asm_diskgroup_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup_sparse as
  SELECT * FROM gv$asm_diskgroup_sparse;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup_sparse FOR
    gv_$asm_diskgroup_sparse;
  GRANT SELECT ON gv_$asm_diskgroup_sparse TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup_sparse as
    SELECT * FROM v$asm_diskgroup_sparse;
 CREATE or replace PUBLIC synonym v$asm_diskgroup_sparse FOR
    v_$asm_diskgroup_sparse;
 GRANT SELECT ON v_$asm_diskgroup_sparse TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk as
  SELECT * FROM gv$asm_disk;
  CREATE or replace PUBLIC synonym gv$asm_disk FOR gv_$asm_disk;
  GRANT SELECT ON gv_$asm_disk TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk as
    SELECT * FROM v$asm_disk;
 CREATE or replace PUBLIC synonym v$asm_disk FOR v_$asm_disk;
 GRANT SELECT ON v_$asm_disk TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_stat as
  SELECT * FROM gv$asm_disk_stat;
  CREATE or replace PUBLIC synonym gv$asm_disk_stat FOR gv_$asm_disk_stat;
  GRANT SELECT ON gv_$asm_disk_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk_stat as
    SELECT * FROM v$asm_disk_stat;
 CREATE or replace PUBLIC synonym v$asm_disk_stat FOR v_$asm_disk_stat;
 GRANT SELECT ON v_$asm_disk_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_sparse as
  SELECT * FROM gv$asm_disk_sparse;
  CREATE or replace PUBLIC synonym gv$asm_disk_sparse FOR gv_$asm_disk_sparse;
  GRANT SELECT ON gv_$asm_disk_sparse TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk_sparse as
    SELECT * FROM v$asm_disk_sparse;
 CREATE or replace PUBLIC synonym v$asm_disk_sparse FOR v_$asm_disk_sparse;
 GRANT SELECT ON v_$asm_disk_sparse TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_sparse_stat as
  SELECT * FROM gv$asm_disk_sparse_stat;
  CREATE or replace PUBLIC synonym gv$asm_disk_sparse_stat FOR
     gv_$asm_disk_sparse_stat;
  GRANT SELECT ON gv_$asm_disk_sparse_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk_sparse_stat as
    SELECT * FROM v$asm_disk_sparse_stat;
 CREATE or replace PUBLIC synonym v$asm_disk_sparse_stat FOR
    v_$asm_disk_sparse_stat;
 GRANT SELECT ON v_$asm_disk_sparse_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_iostat_sparse as
  SELECT * FROM gv$asm_disk_iostat_sparse;
  CREATE or replace PUBLIC synonym gv$asm_disk_iostat_sparse FOR 
    gv_$asm_disk_iostat_sparse;
  GRANT SELECT ON gv_$asm_disk_iostat_sparse TO select_catalog_role;

 CREATE or replace VIEW v_$asm_disk_iostat_sparse as
  SELECT * FROM v$asm_disk_iostat_sparse;
  CREATE or replace PUBLIC synonym v$asm_disk_iostat_sparse FOR 
    v_$asm_disk_iostat_sparse;
  GRANT SELECT ON v_$asm_disk_iostat_sparse TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_client as
  SELECT * FROM gv$asm_client;
  CREATE or replace PUBLIC synonym gv$asm_client FOR gv_$asm_client;
  GRANT SELECT ON gv_$asm_client TO select_catalog_role;

  CREATE or replace VIEW v_$asm_client as
    SELECT * FROM v$asm_client;
 CREATE or replace PUBLIC synonym v$asm_client FOR v_$asm_client;
 GRANT SELECT ON v_$asm_client TO select_catalog_role;

 CREATE or replace VIEW gv_$ios_client as
  SELECT * FROM gv$ios_client;
  CREATE or replace PUBLIC synonym gv$ios_client FOR gv_$ios_client;
  GRANT SELECT ON gv_$ios_client TO select_catalog_role;

  CREATE or replace VIEW v_$ios_client as
    SELECT * FROM v$ios_client;
 CREATE or replace PUBLIC synonym v$ios_client FOR v_$ios_client;
 GRANT SELECT ON v_$ios_client TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_alias as
  SELECT * FROM gv$asm_alias;
  CREATE or replace PUBLIC synonym gv$asm_alias FOR gv_$asm_alias;
  GRANT SELECT ON gv_$asm_alias TO select_catalog_role;

  CREATE or replace VIEW v_$asm_alias as
    SELECT * FROM v$asm_alias;
 CREATE or replace PUBLIC synonym v$asm_alias FOR v_$asm_alias;
 GRANT SELECT ON v_$asm_alias TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_attribute as
  SELECT * FROM gv$asm_attribute;
  CREATE or replace PUBLIC synonym gv$asm_attribute FOR gv_$asm_attribute;
  GRANT SELECT ON gv_$asm_attribute TO select_catalog_role;

  CREATE or replace VIEW v_$asm_attribute as
    SELECT * FROM v$asm_attribute;
 CREATE or replace PUBLIC synonym v$asm_attribute FOR v_$asm_attribute;
 GRANT SELECT ON v_$asm_attribute TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_operation as
  SELECT * FROM gv$asm_operation;
  CREATE or replace PUBLIC synonym gv$asm_operation FOR gv_$asm_operation;
  GRANT SELECT ON gv_$asm_operation TO select_catalog_role;

  CREATE or replace VIEW v_$asm_operation as
    SELECT * FROM v$asm_operation;
 CREATE or replace PUBLIC synonym v$asm_operation FOR v_$asm_operation;
 GRANT SELECT ON v_$asm_operation TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_user as
  SELECT * FROM gv$asm_user;
  CREATE or replace PUBLIC synonym gv$asm_user FOR gv_$asm_user;
  GRANT SELECT ON gv_$asm_user TO select_catalog_role;

  CREATE or replace VIEW v_$asm_user as
    SELECT * FROM v$asm_user;
 CREATE or replace PUBLIC synonym v$asm_user FOR v_$asm_user;
 GRANT SELECT ON v_$asm_user TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_usergroup as
  SELECT * FROM gv$asm_usergroup;
  CREATE or replace PUBLIC synonym gv$asm_usergroup FOR gv_$asm_usergroup;
  GRANT SELECT ON gv_$asm_usergroup TO select_catalog_role;

  CREATE or replace VIEW v_$asm_usergroup as
    SELECT * FROM v$asm_usergroup;
 CREATE or replace PUBLIC synonym v$asm_usergroup FOR v_$asm_usergroup;
 GRANT SELECT ON v_$asm_usergroup TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_usergroup_member as
  SELECT * FROM gv$asm_usergroup_member;
  CREATE or replace PUBLIC synonym gv$asm_usergroup_member
    FOR gv_$asm_usergroup_member;
  GRANT SELECT ON gv_$asm_usergroup_member TO select_catalog_role;

  CREATE or replace VIEW v_$asm_usergroup_member as
    SELECT * FROM v$asm_usergroup_member;
 CREATE or replace PUBLIC synonym v$asm_usergroup_member
   FOR v_$asm_usergroup_member;
 GRANT SELECT ON v_$asm_usergroup_member TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_estimate as
  SELECT * FROM gv$asm_estimate;
  CREATE or replace PUBLIC synonym gv$asm_estimate
    FOR gv_$asm_estimate;
  GRANT SELECT ON gv_$asm_estimate TO select_catalog_role;

  CREATE or replace VIEW v_$asm_estimate as
    SELECT * FROM v$asm_estimate;
 CREATE or replace PUBLIC synonym v$asm_estimate
   FOR v_$asm_estimate;
 GRANT SELECT ON v_$asm_estimate TO select_catalog_role;

create or replace view gv_$asm_audit_clean_events as
  select * from gv$asm_audit_clean_events;
create or replace public synonym gv$asm_audit_clean_events
  for gv_$asm_audit_clean_events;
grant read on gv_$asm_audit_clean_events to audit_admin;
grant read on gv_$asm_audit_clean_events to audit_viewer;

create or replace view v_$asm_audit_clean_events as
  select * from v$asm_audit_clean_events;
create or replace public synonym v$asm_audit_clean_events for v_$asm_audit_clean_events;
grant read on v_$asm_audit_clean_events to audit_admin;
grant read on v_$asm_audit_clean_events to audit_viewer;

create or replace view gv_$asm_audit_cleanup_jobs as
  select * from gv$asm_audit_cleanup_jobs;
create or replace public synonym gv$asm_audit_cleanup_jobs
  for gv_$asm_audit_cleanup_jobs;
grant read on gv_$asm_audit_cleanup_jobs to audit_admin;
grant read on gv_$asm_audit_cleanup_jobs to audit_viewer;

create or replace view v_$asm_audit_cleanup_jobs as
  select * from v$asm_audit_cleanup_jobs;
create or replace public synonym v$asm_audit_cleanup_jobs for v_$asm_audit_cleanup_jobs;
grant read on v_$asm_audit_cleanup_jobs to audit_admin;
grant read on v_$asm_audit_cleanup_jobs to audit_viewer;

create or replace view gv_$asm_audit_config_params as
  select * from gv$asm_audit_config_params;
create or replace public synonym gv$asm_audit_config_params
  for gv_$asm_audit_config_params;
grant read on gv_$asm_audit_config_params to audit_admin;
grant read on gv_$asm_audit_config_params to audit_viewer;

create or replace view v_$asm_audit_config_params as
  select * from v$asm_audit_config_params;
create or replace public synonym v$asm_audit_config_params for v_$asm_audit_config_params;
grant read on v_$asm_audit_config_params to audit_admin;
grant read on v_$asm_audit_config_params to audit_viewer;

create or replace view gv_$asm_audit_last_arch_ts as
  select * from gv$asm_audit_last_arch_ts;
create or replace public synonym gv$asm_audit_last_arch_ts
  for gv_$asm_audit_last_arch_ts;
grant read on gv_$asm_audit_last_arch_ts to audit_admin;
grant read on gv_$asm_audit_last_arch_ts to audit_viewer;

create or replace view v_$asm_audit_last_arch_ts as
  select * from v$asm_audit_last_arch_ts;
create or replace public synonym v$asm_audit_last_arch_ts for v_$asm_audit_last_arch_ts;
grant read on v_$asm_audit_last_arch_ts to audit_admin;
grant read on v_$asm_audit_last_arch_ts to audit_viewer;

create or replace view gv_$asm_audit_load_jobs as
  select * from gv$asm_audit_load_jobs;
create or replace public synonym gv$asm_audit_load_jobs
  for gv_$asm_audit_load_jobs;
grant read on gv_$asm_audit_load_jobs to audit_admin;
grant read on gv_$asm_audit_load_jobs to audit_viewer;

create or replace view v_$asm_audit_load_jobs as
  select * from v$asm_audit_load_jobs;
create or replace public synonym v$asm_audit_load_jobs for v_$asm_audit_load_jobs;
grant read on v_$asm_audit_load_jobs to audit_admin;
grant read on v_$asm_audit_load_jobs to audit_viewer;

CREATE or replace VIEW gv_$asm_dbclone_info as
  SELECT * FROM gv$asm_dbclone_info;
CREATE or replace PUBLIC synonym gv$asm_dbclone_info FOR 
  gv_$asm_dbclone_info;
GRANT SELECT ON gv_$asm_dbclone_info TO select_catalog_role;

CREATE or replace VIEW v_$asm_dbclone_info as
  SELECT * FROM v$asm_dbclone_info;
CREATE or replace PUBLIC synonym v$asm_dbclone_info FOR 
  v_$asm_dbclone_info;
GRANT SELECT ON v_$asm_dbclone_info TO select_catalog_role;

CREATE or REPLACE view v_$asm_cache_events as
  select * from v$asm_cache_events;
create or replace public synonym v$asm_cache_events for v_$asm_cache_events;
grant select on v_$asm_cache_events to select_catalog_role;

create or replace view gv_$rule_set as select * from gv$rule_set;
create or replace public synonym gv$rule_set for gv_$rule_set;
grant select on gv_$rule_set to select_catalog_role;

create or replace view v_$rule_set as select * from v$rule_set;
create or replace public synonym v$rule_set for v_$rule_set;
grant select on v_$rule_set to select_catalog_role;

create or replace view gv_$rule as select * from gv$rule;
create or replace public synonym gv$rule for gv_$rule;
grant select on gv_$rule to select_catalog_role;

create or replace view v_$rule as select * from v$rule;
create or replace public synonym v$rule for v_$rule;
grant select on v_$rule to select_catalog_role;

create or replace view gv_$rule_set_aggregate_stats as
    select * from gv$rule_set_aggregate_stats;
create or replace public synonym gv$rule_set_aggregate_stats for
    gv_$rule_set_aggregate_stats;
grant select on gv_$rule_set_aggregate_stats to select_catalog_role;

create or replace view v_$rule_set_aggregate_stats as
    select * from v$rule_set_aggregate_stats;
create or replace public synonym v$rule_set_aggregate_stats for
    v_$rule_set_aggregate_stats;
grant select on v_$rule_set_aggregate_stats to select_catalog_role;

create or replace view gv_$javapool as
    select * from gv$javapool;
create or replace public synonym gv$javapool for gv_$javapool;
grant select on gv_$javapool to select_catalog_role;

create or replace view v_$javapool as
    select * from v$javapool;
create or replace public synonym v$javapool for v_$javapool;
grant select on v_$javapool to select_catalog_role;

create or replace view gv_$sysaux_occupants as
    select * from gv$sysaux_occupants;
create or replace public synonym gv$sysaux_occupants for gv_$sysaux_occupants;
grant select on gv_$sysaux_occupants to select_catalog_role;

create or replace view v_$sysaux_occupants as
    select * from v$sysaux_occupants;
create or replace public synonym v$sysaux_occupants for v_$sysaux_occupants;
grant select on v_$sysaux_occupants to select_catalog_role;

create or replace view v_$rman_status as select * from v$rman_status;
create or replace public synonym v$rman_status
   for v_$rman_status;
grant select on v_$rman_status to select_catalog_role;

create or replace view v_$rman_output as select * from v$rman_output;
create or replace public synonym v$rman_output
   for v_$rman_output;
grant select on v_$rman_output to select_catalog_role;

create or replace view gv_$rman_output as select * from gv$rman_output;
create or replace public synonym gv$rman_output
   for gv_$rman_output;
grant select on gv_$rman_output to select_catalog_role;

create or replace view v_$recovery_file_dest as select * from
   v$recovery_file_dest;
create or replace public synonym v$recovery_file_dest
   for v_$recovery_file_dest;
grant select on v_$recovery_file_dest to select_catalog_role;

create or replace view v_$flash_recovery_area_usage as select * from
   v$flash_recovery_area_usage;
create or replace public synonym v$flash_recovery_area_usage
   for v_$flash_recovery_area_usage;
grant select on v_$flash_recovery_area_usage to select_catalog_role;

create or replace view v_$recovery_area_usage as select * from
   v$recovery_area_usage;
create or replace public synonym v$recovery_area_usage
   for v_$recovery_area_usage;
grant select on v_$recovery_area_usage to select_catalog_role;

create or replace view v_$block_change_tracking as
    select * from v$block_change_tracking;
create or replace public synonym v$block_change_tracking for
    v_$block_change_tracking;
grant select on v_$block_change_tracking to select_catalog_role;

create or replace view gv_$metric as select * from gv$metric;
create or replace public synonym gv$metric for gv_$metric;
grant select on gv_$metric to select_catalog_role;

create or replace view gv_$metric_history as
          select * from gv$metric_history;
create or replace public synonym gv$metric_history
          for gv_$metric_history;
grant select on gv_$metric_history to select_catalog_role;

create or replace view gv_$sysmetric as select * from gv$sysmetric;
create or replace public synonym gv$sysmetric for gv_$sysmetric;
grant select on gv_$sysmetric to select_catalog_role;

create or replace view gv_$sysmetric_history as
          select * from gv$sysmetric_history;
create or replace public synonym gv$sysmetric_history
          for gv_$sysmetric_history;
grant select on gv_$sysmetric_history to select_catalog_role;

create or replace view gv_$metricname as select * from gv$metricname;
create or replace public synonym gv$metricname for gv_$metricname;
grant select on gv_$metricname to select_catalog_role;

create or replace view gv_$metricgroup as select * from gv$metricgroup;
create or replace public synonym gv$metricgroup for gv_$metricgroup;
grant select on gv_$metricgroup to select_catalog_role;

create or replace view gv_$active_session_history as
    select * from gv$active_session_history;
create or replace public synonym gv$active_session_history
      for gv_$active_session_history;
grant select on gv_$active_session_history to select_catalog_role;

create or replace view v_$active_session_history as
    select * from v$active_session_history;
create or replace public synonym v$active_session_history
      for v_$active_session_history;
grant select on v_$active_session_history to select_catalog_role;

create or replace view gv_$ash_info as
    select * from gv$ash_info;
create or replace public synonym gv$ash_info
      for gv_$ash_info;
grant select on gv_$ash_info to select_catalog_role;

create or replace view v_$ash_info as
    select * from v$ash_info;
create or replace public synonym v$ash_info
      for v_$ash_info;
grant select on v_$ash_info to select_catalog_role;

create or replace view gv_$rt_addm_control as
    select * from gv$rt_addm_control;
create or replace public synonym gv$rt_addm_control
      for gv_$rt_addm_control;
grant select on gv_$rt_addm_control to select_catalog_role;

create or replace view v_$rt_addm_control as
    select * from v$rt_addm_control;
create or replace public synonym v$rt_addm_control
      for v_$rt_addm_control;
grant select on v_$rt_addm_control to select_catalog_role;

create or replace view gv_$instance_ping as
    select * from gv$instance_ping;
create or replace public synonym gv$instance_ping
      for gv_$instance_ping;
grant select on gv_$instance_ping to select_catalog_role;

create or replace view v_$instance_ping as
    select * from v$instance_ping;
create or replace public synonym v$instance_ping
      for v_$instance_ping;
grant select on v_$instance_ping to select_catalog_role;

create or replace view gv_$workload_replay_thread as
    select * from gv$workload_replay_thread;
create or replace public synonym gv$workload_replay_thread
      for gv_$workload_replay_thread;
grant select on gv_$workload_replay_thread to select_catalog_role;

create or replace view v_$workload_replay_thread as
    select * from v$workload_replay_thread;
create or replace public synonym v$workload_replay_thread
      for v_$workload_replay_thread;
grant select on v_$workload_replay_thread to select_catalog_role;

create or replace view gv_$instance_log_group as
    select * from gv$instance_log_group;
create or replace public synonym gv$instance_log_group
      for gv_$instance_log_group;
grant select on gv_$instance_log_group to select_catalog_role;

create or replace view v_$instance_log_group as
    select * from v$instance_log_group;
create or replace public synonym v$instance_log_group
      for v_$instance_log_group;
grant select on v_$instance_log_group to select_catalog_role;

create or replace view gv_$service_wait_class as select * from gv$service_wait_class;
create or replace public synonym gv$service_wait_class for gv_$service_wait_class;
grant select on gv_$service_wait_class to select_catalog_role;

create or replace view gv_$service_event as select * from gv$service_event;
create or replace public synonym gv$service_event for gv_$service_event;
grant select on gv_$service_event to select_catalog_role;

create or replace view gv_$active_services as select * from gv$active_services;
create or replace public synonym gv$active_services for gv_$active_services;
grant select on gv_$active_services to select_catalog_role;

create or replace view gv_$services as select * from gv$services;
create or replace public synonym gv$services for gv_$services;
grant select on gv_$services to select_catalog_role;

create or replace view v_$scheduler_running_jobs as
    select * from v$scheduler_running_jobs;
create or replace public synonym v$scheduler_running_jobs
      for v_$scheduler_running_jobs;
grant select on v_$scheduler_running_jobs to select_catalog_role;

create or replace view gv_$scheduler_running_jobs as
    select * from gv$scheduler_running_jobs;
create or replace public synonym gv$scheduler_running_jobs
      for gv_$scheduler_running_jobs;
grant select on gv_$scheduler_running_jobs to select_catalog_role;

create or replace view v_$scheduler_inmem_rtinfo as
    select * from v$scheduler_inmem_rtinfo;
create or replace public synonym v$scheduler_inmem_rtinfo
      for v_$scheduler_inmem_rtinfo;
grant select on v_$scheduler_inmem_rtinfo to select_catalog_role;

create or replace view gv_$scheduler_inmem_rtinfo as
    select * from gv$scheduler_inmem_rtinfo;
create or replace public synonym gv$scheduler_inmem_rtinfo
      for gv_$scheduler_inmem_rtinfo;
grant select on gv_$scheduler_inmem_rtinfo to select_catalog_role;

create or replace view v_$scheduler_inmem_mdinfo as
    select * from v$scheduler_inmem_mdinfo;
create or replace public synonym v$scheduler_inmem_mdinfo
      for v_$scheduler_inmem_mdinfo;
grant select on v_$scheduler_inmem_mdinfo to select_catalog_role;

create or replace view gv_$scheduler_inmem_mdinfo as
    select * from gv$scheduler_inmem_mdinfo;
create or replace public synonym gv$scheduler_inmem_mdinfo
      for gv_$scheduler_inmem_mdinfo;
grant select on gv_$scheduler_inmem_mdinfo to select_catalog_role;

create or replace view gv_$buffered_queues as
    select * from gv$buffered_queues;
create or replace public synonym gv$buffered_queues
    for gv_$buffered_queues;
grant select on gv_$buffered_queues to select_catalog_role;

create or replace view v_$buffered_queues as
    select * from v$buffered_queues;
create or replace public synonym v$buffered_queues
    for v_$buffered_queues;
grant select on v_$buffered_queues to select_catalog_role;

create or replace view gv_$buffered_subscribers as
    select * from gv$buffered_subscribers;
create or replace public synonym gv$buffered_subscribers
    for gv_$buffered_subscribers;
grant select on gv_$buffered_subscribers to select_catalog_role;

create or replace view v_$buffered_subscribers as
    select * from v$buffered_subscribers;
create or replace public synonym v$buffered_subscribers
    for v_$buffered_subscribers;
grant select on v_$buffered_subscribers to select_catalog_role;

create or replace view gv_$buffered_publishers as
    select * from gv$buffered_publishers;
create or replace public synonym gv$buffered_publishers
    for gv_$buffered_publishers;
grant select on gv_$buffered_publishers to select_catalog_role;

create or replace view v_$buffered_publishers as
    select * from v$buffered_publishers;
create or replace public synonym v$buffered_publishers
    for v_$buffered_publishers;
grant select on v_$buffered_publishers to select_catalog_role;

create or replace view gv_$tsm_sessions as
    select * from gv$tsm_sessions;
create or replace public synonym gv$tsm_sessions
    for gv_$tsm_sessions;
grant select on gv_$tsm_sessions to select_catalog_role;

create or replace view v_$tsm_sessions as
    select * from v$tsm_sessions;
create or replace public synonym v$tsm_sessions
    for v_$tsm_sessions;
grant select on v_$tsm_sessions to select_catalog_role;

create or replace view gv_$propagation_sender as
    select * from gv$propagation_sender;
create or replace public synonym gv$propagation_sender
    for gv_$propagation_sender;
grant select on gv_$propagation_sender to select_catalog_role;

create or replace view v_$propagation_sender as
    select * from v$propagation_sender;
create or replace public synonym v$propagation_sender
    for v_$propagation_sender;
grant select on v_$propagation_sender to select_catalog_role;

create or replace view gv_$propagation_receiver as
    select * from gv$propagation_receiver;
create or replace public synonym gv$propagation_receiver
    for gv_$propagation_receiver;
grant select on gv_$propagation_receiver to select_catalog_role;

create or replace view v_$propagation_receiver as
    select * from v$propagation_receiver;
create or replace public synonym v$propagation_receiver
    for v_$propagation_receiver;
grant select on v_$propagation_receiver to select_catalog_role;

create or replace view gv_$subscr_registration_stats as
    select * from gv$subscr_registration_stats;
create or replace public synonym gv$subscr_registration_stats
    for gv_$subscr_registration_stats;
grant select on gv_$subscr_registration_stats to select_catalog_role;

create or replace view v_$subscr_registration_stats as
    select * from v$subscr_registration_stats;
create or replace public synonym v$subscr_registration_stats
    for v_$subscr_registration_stats;
grant select on v_$subscr_registration_stats to select_catalog_role;

create or replace view gv_$emon as
    select * from gv$emon;
create or replace public synonym gv$emon
    for gv_$emon;
grant select on gv_$emon to select_catalog_role;

create or replace view v_$emon as
    select * from v$emon;
create or replace public synonym v$emon
    for v_$emon;
grant select on v_$emon to select_catalog_role;

create or replace view v_$aq_notification_clients as
  select * from v$aq_notification_clients;
create or replace public synonym v$aq_notification_clients
  for v_$aq_notification_clients;
grant select on v_$aq_notification_clients to select_catalog_role;

create or replace view gv_$aq_notification_clients as
  select * from gv$aq_notification_clients;
create or replace public synonym gv$aq_notification_clients
  for gv_$aq_notification_clients;
grant select on gv_$aq_notification_clients to select_catalog_role;

create or replace view v_$aq_background_coordinator as
  select * from v$aq_background_coordinator;
create or replace public synonym v$aq_background_coordinator
  for v_$aq_background_coordinator;
grant select on v_$aq_background_coordinator to select_catalog_role;

create or replace view gv_$aq_background_coordinator as
  select * from gv$aq_background_coordinator;
create or replace public synonym gv$aq_background_coordinator
  for gv_$aq_background_coordinator;
grant select on gv_$aq_background_coordinator to select_catalog_role;

create or replace view v_$aq_job_coordinator as
  select * from v$aq_job_coordinator;
create or replace public synonym v$aq_job_coordinator
  for v_$aq_job_coordinator;
grant select on v_$aq_job_coordinator to select_catalog_role;

create or replace view gv_$aq_job_coordinator as
  select * from gv$aq_job_coordinator;
create or replace public synonym gv$aq_job_coordinator
  for gv_$aq_job_coordinator;
grant select on gv_$aq_job_coordinator to select_catalog_role;

create or replace view v_$aq_server_pool as
  select * from v$aq_server_pool;
create or replace public synonym v$aq_server_pool
  for v_$aq_server_pool;
grant select on v_$aq_server_pool to select_catalog_role;

create or replace view gv_$aq_server_pool as
  select * from gv$aq_server_pool;
create or replace public synonym gv$aq_server_pool
  for gv_$aq_server_pool;
grant select on gv_$aq_server_pool to select_catalog_role;

create or replace view v_$aq_cross_instance_jobs as
  select * from v$aq_cross_instance_jobs;
create or replace public synonym v$aq_cross_instance_jobs
  for v_$aq_cross_instance_jobs;
grant select on v_$aq_cross_instance_jobs to select_catalog_role;

create or replace view gv_$aq_cross_instance_jobs as
  select * from gv$aq_cross_instance_jobs;
create or replace public synonym gv$aq_cross_instance_jobs
  for gv_$aq_cross_instance_jobs;
grant select on gv_$aq_cross_instance_jobs to select_catalog_role;

create or replace view gv_$con_sysmetric as 
    select * from gv$con_sysmetric;
create or replace public synonym gv$con_sysmetric 
    for gv_$con_sysmetric;
grant select on gv_$con_sysmetric to select_catalog_role;

create or replace view gv_$con_sysmetric_history as
    select * from gv$con_sysmetric_history;
create or replace public synonym gv$con_sysmetric_history 
    for gv_$con_sysmetric_history;
grant select on gv_$con_sysmetric_history to select_catalog_role;

create or replace view gv_$con_sysmetric_summary as
    select * from gv$con_sysmetric_summary;
create or replace public synonym gv$con_sysmetric_summary
    for gv_$con_sysmetric_summary;
grant select on gv_$con_sysmetric_summary to select_catalog_role;

create or replace view gv_$sysmetric_summary as
    select * from gv$sysmetric_summary;
create or replace public synonym gv$sysmetric_summary
    for gv_$sysmetric_summary;
grant select on gv_$sysmetric_summary to select_catalog_role;

create or replace view gv_$sessmetric as select * from gv$sessmetric;
create or replace public synonym gv$sessmetric for gv_$sessmetric;
grant select on gv_$sessmetric to select_catalog_role;

create or replace view gv_$filemetric as select * from gv$filemetric;
create or replace public synonym gv$filemetric for gv_$filemetric;
grant select on gv_$filemetric to select_catalog_role;

create or replace view gv_$filemetric_history as
    select * from gv$filemetric_history;
create or replace public synonym gv$filemetric_history
    for gv_$filemetric_history;
grant select on gv_$filemetric_history to select_catalog_role;

create or replace view gv_$eventmetric as select * from gv$eventmetric;
create or replace public synonym gv$eventmetric for gv_$eventmetric;
grant select on gv_$eventmetric to select_catalog_role;

create or replace view gv_$waitclassmetric as
    select * from gv$waitclassmetric;
create or replace public synonym gv$waitclassmetric for gv_$waitclassmetric;
grant select on gv_$waitclassmetric to select_catalog_role;

create or replace view gv_$waitclassmetric_history as
    select * from gv$waitclassmetric_history;
create or replace public synonym gv$waitclassmetric_history
    for gv_$waitclassmetric_history;
grant select on gv_$waitclassmetric_history to select_catalog_role;

create or replace view gv_$servicemetric as select * from gv$servicemetric;
create or replace public synonym gv$servicemetric for gv_$servicemetric;
grant select on gv_$servicemetric to select_catalog_role;

create or replace view gv_$servicemetric_history
    as select * from gv$servicemetric_history;
create or replace public synonym gv$servicemetric_history
    for gv_$servicemetric_history;
grant select on gv_$servicemetric_history to select_catalog_role;

create or replace view gv_$iofuncmetric as select * from gv$iofuncmetric;
create or replace public synonym gv$iofuncmetric for gv_$iofuncmetric;
grant select on gv_$iofuncmetric to select_catalog_role;

create or replace view gv_$iofuncmetric_history
    as select * from gv$iofuncmetric_history;
create or replace public synonym gv$iofuncmetric_history
    for gv_$iofuncmetric_history;
grant select on gv_$iofuncmetric_history to select_catalog_role;

create or replace view gv_$rsrcmgrmetric as select * from gv$rsrcmgrmetric;
create or replace public synonym gv$rsrcmgrmetric for gv_$rsrcmgrmetric;
grant select on gv_$rsrcmgrmetric to select_catalog_role;

create or replace view gv_$rsrcmgrmetric_history
    as select * from gv$rsrcmgrmetric_history;
create or replace public synonym gv$rsrcmgrmetric_history
    for gv_$rsrcmgrmetric_history;
grant select on gv_$rsrcmgrmetric_history to select_catalog_role;

create or replace view gv_$rsrcpdbmetric as select * from gv$rsrcpdbmetric;
create or replace public synonym gv$rsrcpdbmetric for gv_$rsrcpdbmetric;
grant select on gv_$rsrcpdbmetric to select_catalog_role;

create or replace view gv_$rsrcpdbmetric_history
    as select * from gv$rsrcpdbmetric_history;
create or replace public synonym gv$rsrcpdbmetric_history
    for gv_$rsrcpdbmetric_history;
grant select on gv_$rsrcpdbmetric_history to select_catalog_role;

create or replace view gv_$rsrc_pdb as select * from gv$rsrc_pdb;
create or replace public synonym gv$rsrc_pdb for gv_$rsrc_pdb;
grant select on gv_$rsrc_pdb to select_catalog_role;

create or replace view gv_$rsrc_pdb_history
    as select * from gv$rsrc_pdb_history;
create or replace public synonym gv$rsrc_pdb_history for gv_$rsrc_pdb_history;
grant select on gv_$rsrc_pdb_history to select_catalog_role;

create or replace view gv_$wlm_pcmetric as select * from gv$wlm_pcmetric;
create or replace public synonym gv$wlm_pcmetric for gv_$wlm_pcmetric;
grant select on gv_$wlm_pcmetric to select_catalog_role;

create or replace view gv_$wlm_pcmetric_history
    as select * from gv$wlm_pcmetric_history;
create or replace public synonym gv$wlm_pcmetric_history
    for gv_$wlm_pcmetric_history;
grant select on gv_$wlm_pcmetric_history to select_catalog_role;

create or replace view gv_$wlm_pc_stats as select * from gv$wlm_pc_stats;
create or replace public synonym gv$wlm_pc_stats for gv_$wlm_pc_stats;
grant select on gv_$wlm_pc_stats to select_catalog_role;

create or replace view gv_$wlm_db_mode as select * from gv$wlm_db_mode;
create or replace public synonym gv$wlm_db_mode for gv_$wlm_db_mode;
grant select on gv_$wlm_db_mode to select_catalog_role;

create or replace view gv_$wlm_pcservice as select * from gv$wlm_pcservice;
create or replace public synonym gv$wlm_pcservice for gv_$wlm_pcservice;
grant select on gv_$wlm_pcservice to select_catalog_role;

create or replace view gv_$advisor_progress
    as select * from gv$advisor_progress;
create or replace public synonym gv$advisor_progress
    for gv_$advisor_progress;
grant select on gv_$advisor_progress to select_catalog_role;

create or replace view gv_$xml_audit_trail
    as select * from gv$xml_audit_trail;
create or replace public synonym gv$xml_audit_trail
    for gv_$xml_audit_trail;
grant select on gv_$xml_audit_trail to select_catalog_role;

create or replace view gv_$sql_join_filter
    as select * from gv$sql_join_filter;
create or replace public synonym gv$sql_join_filter
    for gv_$sql_join_filter;
grant select on gv_$sql_join_filter to select_catalog_role;

create or replace view gv_$process_memory as select * from gv$process_memory;
create or replace public synonym gv$process_memory for gv_$process_memory;
grant select on gv_$process_memory to select_catalog_role;

create or replace view gv_$process_memory_detail
    as select * from gv$process_memory_detail;
create or replace public synonym gv$process_memory_detail
    for gv_$process_memory_detail;
grant select on gv_$process_memory_detail to select_catalog_role;

create or replace view gv_$process_memory_detail_prog
    as select * from gv$process_memory_detail_prog;
create or replace public synonym gv$process_memory_detail_prog
    for gv_$process_memory_detail_prog;
grant select on gv_$process_memory_detail_prog to select_catalog_role;

create or replace view gv_$wallet
    as select * from gv$wallet;
create or replace public synonym gv$wallet
    for gv_$wallet;
grant select on gv_$wallet to select_catalog_role;

create or replace view v_$wallet
    as select * from v$wallet;
create or replace public synonym v$wallet
    for v_$wallet;
grant select on v_$wallet to select_catalog_role;

create or replace view gv_$system_fix_control 
  as select * from gv$system_fix_control;
create or replace public synonym gv$system_fix_control 
  for gv_$system_fix_control;
grant select on gv_$system_fix_control to select_catalog_role;

create or replace view v_$system_fix_control 
  as select * from v$system_fix_control;
create or replace public synonym v$system_fix_control 
  for v_$system_fix_control;
grant select on v_$system_fix_control to select_catalog_role;

create or replace view gv_$session_fix_control 
  as select * from gv$session_fix_control;
create or replace public synonym gv$session_fix_control 
  for gv_$session_fix_control;
grant select on gv_$session_fix_control to select_catalog_role;

create or replace view v_$session_fix_control 
  as select * from v$session_fix_control;
create or replace public synonym v$session_fix_control 
  for v_$session_fix_control;
grant select on v_$session_fix_control to select_catalog_role;

create or replace view gv_$SQL_DIAG_REPOSITORY
  as select * from gv$SQL_DIAG_REPOSITORY;
create or replace public synonym gv$SQL_DIAG_REPOSITORY
  for gv_$SQL_DIAG_REPOSITORY;
grant select on gv_$SQL_DIAG_REPOSITORY to select_catalog_role;

create or replace view v_$SQL_DIAG_REPOSITORY
  as select * from v$SQL_DIAG_REPOSITORY;
create or replace public synonym v$SQL_DIAG_REPOSITORY
  for v_$SQL_DIAG_REPOSITORY;
grant select on v_$SQL_DIAG_REPOSITORY to select_catalog_role;

create or replace view gv_$SQL_DIAG_REPOSITORY_REASON
  as select * from gv$SQL_DIAG_REPOSITORY_REASON;
create or replace public synonym gv$SQL_DIAG_REPOSITORY_REASON
  for gv_$SQL_DIAG_REPOSITORY_REASON;
grant select on gv_$SQL_DIAG_REPOSITORY_REASON to select_catalog_role;

create or replace view v_$SQL_DIAG_REPOSITORY_REASON
  as select * from v$SQL_DIAG_REPOSITORY_REASON;
create or replace public synonym v$SQL_DIAG_REPOSITORY_REASON
  for v_$SQL_DIAG_REPOSITORY_REASON;
grant select on v_$SQL_DIAG_REPOSITORY_REASON to select_catalog_role;

create or replace view gv_$fs_failover_histogram 
as select * from gv$fs_failover_histogram;
create or replace public synonym gv$fs_failover_histogram
                             for gv_$fs_failover_histogram;
grant select on gv_$fs_failover_histogram to select_catalog_role;

create or replace view v_$fs_failover_histogram 
as select * from v$fs_failover_histogram;
create or replace public synonym v$fs_failover_histogram
                             for v_$fs_failover_histogram;
grant select on v_$fs_failover_histogram to select_catalog_role;

create or replace view gv_$sql_feature 
  as select * from gv$sql_feature;
create or replace public synonym gv$sql_feature 
  for gv_$sql_feature;
grant select on gv_$sql_feature to select_catalog_role;

create or replace view v_$sql_feature 
  as select * from v$sql_feature;
create or replace public synonym v$sql_feature 
  for v_$sql_feature;
grant select on v_$sql_feature to select_catalog_role;

create or replace view gv_$sql_feature_hierarchy 
  as select * from gv$sql_feature_hierarchy;
create or replace public synonym gv$sql_feature_hierarchy 
  for gv_$sql_feature_hierarchy;
grant select on gv_$sql_feature_hierarchy to select_catalog_role;

create or replace view v_$sql_feature_hierarchy 
  as select * from v$sql_feature_hierarchy;
create or replace public synonym v$sql_feature_hierarchy 
  for v_$sql_feature_hierarchy;
grant select on v_$sql_feature_hierarchy to select_catalog_role;

create or replace view gv_$sql_feature_dependency 
  as select * from gv$sql_feature_dependency;
create or replace public synonym gv$sql_feature_dependency 
  for gv_$sql_feature_dependency;
grant select on gv_$sql_feature_dependency to select_catalog_role;

create or replace view v_$sql_feature_dependency 
  as select * from v$sql_feature_dependency;
create or replace public synonym v$sql_feature_dependency 
  for v_$sql_feature_dependency;
grant select on v_$sql_feature_dependency to select_catalog_role;

create or replace view gv_$sql_hint 
  as select * from gv$sql_hint;
create or replace public synonym gv$sql_hint 
  for gv_$sql_hint;
grant select on gv_$sql_hint to select_catalog_role;

create or replace view v_$sql_hint 
  as select * from v$sql_hint;
create or replace public synonym v$sql_hint 
  for v_$sql_hint;
grant select on v_$sql_hint to select_catalog_role;

create or replace view gv_$sql_feature_dependency 
  as select * from gv$sql_feature_dependency;
create or replace public synonym gv$sql_feature_dependency 
  for gv_$sql_feature_dependency;
grant select on gv_$sql_feature_dependency to select_catalog_role;

create or replace view v_$sql_feature_dependency 
  as select * from v$sql_feature_dependency;
create or replace public synonym v$sql_feature_dependency 
  for v_$sql_feature_dependency;
grant select on v_$sql_feature_dependency to select_catalog_role;

create or replace view gv_$sql_hint 
  as select * from gv$sql_hint;
create or replace public synonym gv$sql_hint 
  for gv_$sql_hint;
grant select on gv_$sql_hint to select_catalog_role;

create or replace view v_$sql_hint 
  as select * from v$sql_hint;
create or replace public synonym v$sql_hint 
  for v_$sql_hint;
grant select on v_$sql_hint to select_catalog_role;
create or replace view gv_$result_cache_statistics
as select * from gv$result_cache_statistics;
create or replace public synonym gv$result_cache_statistics
                             for gv_$result_cache_statistics;
grant select on gv_$result_cache_statistics to select_catalog_role;

create or replace view v_$result_cache_statistics
as select * from v$result_cache_statistics;
create or replace public synonym v$result_cache_statistics
                             for v_$result_cache_statistics;
grant select on v_$result_cache_statistics to select_catalog_role;

create or replace view gv_$result_cache_memory
as select * from gv$result_cache_memory;
create or replace public synonym gv$result_cache_memory
                             for gv_$result_cache_memory;
grant select on gv_$result_cache_memory to select_catalog_role;

create or replace view v_$result_cache_memory
as select * from v$result_cache_memory;
create or replace public synonym v$result_cache_memory
                             for v_$result_cache_memory;
grant select on v_$result_cache_memory to select_catalog_role;

create or replace view gv_$result_cache_objects
as select * from gv$result_cache_objects;
create or replace public synonym gv$result_cache_objects
                             for gv_$result_cache_objects;
grant select on gv_$result_cache_objects to select_catalog_role;

create or replace view v_$result_cache_objects
as select * from v$result_cache_objects;
create or replace public synonym v$result_cache_objects
                             for v_$result_cache_objects;
grant select on v_$result_cache_objects to select_catalog_role;

create or replace view gv_$result_cache_dependency
as select * from gv$result_cache_dependency;
create or replace public synonym gv$result_cache_dependency
                             for gv_$result_cache_dependency;
grant select on gv_$result_cache_dependency to select_catalog_role;

create or replace view v_$result_cache_dependency
as select * from v$result_cache_dependency;
create or replace public synonym v$result_cache_dependency
                             for v_$result_cache_dependency;
grant select on v_$result_cache_dependency to select_catalog_role;

create or replace view gv_$gwm_rac_affinity as
select * from gv$gwm_rac_affinity;
create or replace public synonym gv$gwm_rac_affinity
   for gv_$gwm_rac_affinity;
grant select on gv_$gwm_rac_affinity to select_catalog_role;

Rem
Rem Add ACS fixed views
Rem

create or replace view gv_$sql_cs_histogram 
  as select * from gv$sql_cs_histogram;
create or replace public synonym gv$sql_cs_histogram 
  for gv_$sql_cs_histogram;
grant select on gv_$sql_cs_histogram to select_catalog_role;

create or replace view v_$sql_cs_histogram 
  as select * from v$sql_cs_histogram;
create or replace public synonym v$sql_cs_histogram 
 for v_$sql_cs_histogram;
grant select on v_$sql_cs_histogram to select_catalog_role;

create or replace view gv_$sql_cs_selectivity 
  as select * from gv$sql_cs_selectivity;
create or replace public synonym gv$sql_cs_selectivity 
  for gv_$sql_cs_selectivity;
grant select on gv_$sql_cs_selectivity to select_catalog_role;

create or replace view v_$sql_cs_selectivity 
  as select * from v$sql_cs_selectivity;
create or replace public synonym v$sql_cs_selectivity 
  for v_$sql_cs_selectivity;
grant select on v_$sql_cs_selectivity to select_catalog_role;

create or replace view gv_$sql_cs_statistics 
  as select * from gv$sql_cs_statistics;
create or replace public synonym gv$sql_cs_statistics 
  for gv_$sql_cs_statistics;
grant select on gv_$sql_cs_statistics to select_catalog_role;

create or replace view v_$sql_cs_statistics 
  as select * from v$sql_cs_statistics;
create or replace public synonym v$sql_cs_statistics 
  for v_$sql_cs_statistics;
grant select on v_$sql_cs_statistics to select_catalog_role;

Rem
Rem Add Index Usage Stats fixed views
Rem
create or replace view gv_$index_usage_info
  as select * from gv$index_usage_info;
create or replace public synonym gv$index_usage_info
  for gv_$index_usage_info;
grant select on gv_$index_usage_info to select_catalog_role;

create or replace view v_$index_usage_info
  as select * from v$index_usage_info;
create or replace public synonym v$index_usage_info 
 for v_$index_usage_info;
grant select on v_$index_usage_info to select_catalog_role;

Rem Add SQL Monitoring fixed views
Rem

create or replace view gv_$sql_monitor 
  as select * from gv$sql_monitor;
create or replace public synonym gv$sql_monitor 
  for gv_$sql_monitor;
grant select on gv_$sql_monitor to select_catalog_role;

create or replace view v_$sql_monitor 
  as select * from v$sql_monitor;
create or replace public synonym v$sql_monitor 
 for v_$sql_monitor;
grant select on v_$sql_monitor to select_catalog_role;

create or replace view gv_$sql_plan_monitor 
  as select * from gv$sql_plan_monitor;
create or replace public synonym gv$sql_plan_monitor 
  for gv_$sql_plan_monitor;
grant select on gv_$sql_plan_monitor to select_catalog_role;

create or replace view v_$sql_plan_monitor 
  as select * from v$sql_plan_monitor;
create or replace public synonym v$sql_plan_monitor 
 for v_$sql_plan_monitor;
grant select on v_$sql_plan_monitor to select_catalog_role;

create or replace view v_$sql_monitor_statname
  as select * from v$sql_monitor_statname;
create or replace public synonym v$sql_monitor_statname 
 for v_$sql_monitor_statname;
grant select on v_$sql_monitor_statname to select_catalog_role;

create or replace view gv_$sql_monitor_statname 
  as select * from gv$sql_monitor_statname;
create or replace public synonym gv$sql_monitor_statname 
  for gv_$sql_monitor_statname;
grant select on gv_$sql_monitor_statname to select_catalog_role;

create or replace view v_$sql_monitor_sesstat 
  as select * from v$sql_monitor_sesstat;
create or replace public synonym v$sql_monitor_sesstat
  for v_$sql_monitor_sesstat;
grant select on v_$sql_monitor_sesstat to select_catalog_role;

create or replace view gv_$sql_monitor_sesstat 
  as select * from gv$sql_monitor_sesstat;
create or replace public synonym gv$sql_monitor_sesstat
  for gv_$sql_monitor_sesstat;
grant select on gv_$sql_monitor_sesstat to select_catalog_role;

create or replace view gv_$mapped_sql as select * from gv$mapped_sql;
create or replace public synonym gv$mapped_sql for gv_$mapped_sql;
grant select on gv_$mapped_sql to select_catalog_role;

remark
remark  FAMILY "NLS"
remark

create or replace view NLS_SESSION_PARAMETERS (PARAMETER, VALUE) as
select substr(parameter, 1, 30),
       substr(value, 1, 64)
from v$nls_parameters
where parameter != 'NLS_CHARACTERSET' and
 parameter != 'NLS_NCHAR_CHARACTERSET'
/
comment on table NLS_SESSION_PARAMETERS is
'NLS parameters of the user session'
/
comment on column NLS_SESSION_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_SESSION_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_SESSION_PARAMETERS
   for NLS_SESSION_PARAMETERS
/
grant read on NLS_SESSION_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_INSTANCE_PARAMETERS (PARAMETER, VALUE) as
select substr(upper(v.name), 1, 30),
       substr(v.value, 1, 64)
from v$system_parameter v, 
     (select sys_context('userenv', 'con_id') con_id from dual) b
where v.name like 'nls%' and 
      (v.con_id = 0 or  v.con_id = b.con_id)
/
comment on table NLS_INSTANCE_PARAMETERS is
'NLS parameters of the instance'
/
comment on column NLS_INSTANCE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_INSTANCE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_INSTANCE_PARAMETERS
   for NLS_INSTANCE_PARAMETERS
/
grant read on NLS_INSTANCE_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_DATABASE_PARAMETERS (PARAMETER, VALUE) as
select name,
       substr(value$, 1, 64)
from x$props
where name like 'NLS%'
/
comment on table NLS_DATABASE_PARAMETERS is
'Permanent NLS parameters of the database'
/
comment on column NLS_DATABASE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_DATABASE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_DATABASE_PARAMETERS
   for NLS_DATABASE_PARAMETERS
/
grant read on NLS_DATABASE_PARAMETERS to PUBLIC with grant option
/

rem
rem family "DATABASE"
rem
create or replace view DATABASE_COMPATIBLE_LEVEL
    (value, description)
  as
select value,description
from v$parameter
where name = 'compatible'
/
comment on table DATABASE_COMPATIBLE_LEVEL is
'Database compatible parameter set via init.ora'
/
comment on column DATABASE_COMPATIBLE_LEVEL.VALUE is
'Parameter value'
/
comment on column DATABASE_COMPATIBLE_LEVEL.DESCRIPTION is
'Description of value'
/
create or replace public synonym DATABASE_COMPATIBLE_LEVEL
   for DATABASE_COMPATIBLE_LEVEL
/
grant read on DATABASE_COMPATIBLE_LEVEL to PUBLIC with grant option
/


Rem     PRODUCT COMPONENT VERSION
create or replace view product_component_version
    (product,version,version_full,status) 
  as
(select
substr(banner,1, instr(banner,'Version')-1),
substr(banner, instr(banner,'Version')+8,
instr(banner,' - ')-(instr(banner,'Version')+8)),
substr(banner_full, instr(banner_full,'Version')+8),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Version') > 0
and
((instr(banner,'Version') <   instr(banner,'Release')) or
instr(banner,'Release') = 0))
union
(select
substr(banner,1, instr(banner,'Release')-1),
substr(banner, instr(banner,'Release')+8,
instr(banner,' - ')-(instr(banner,'Release')+8)),
substr(banner_full, instr(banner_full,'Version')+8),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Release') > 0
and
instr(banner,'Release') <   instr(banner,' - '))
/
comment on table product_component_version is
'version and status information for component products'
/
comment on column product_component_version.product is
'product name'
/
comment on column product_component_version.version is
'version number'
/
comment on column product_component_version.version_full is
'full version number'
/
comment on column product_component_version.status is
'status of release'
/
grant read on product_component_version to public with grant option
/
create or replace public synonym product_component_version
   for product_component_version
/


Rem Add support for ejb generated classes
Rem This is just a stub view - the actual view is created during
Rem the JIS initialization
Rem This statement must happen before @catexp.
create or replace view sns$ejb$gen$ (owner, shortname) as
  select u.name, o.name from user$ u, obj$ o where 1=2
/


create or replace view V_$TRANSPORTABLE_PLATFORM
as select * from V$TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$TRANSPORTABLE_PLATFORM
for V_$TRANSPORTABLE_PLATFORM
/
grant select on V_$TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$TRANSPORTABLE_PLATFORM
as select * from GV$TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$TRANSPORTABLE_PLATFORM
for GV_$TRANSPORTABLE_PLATFORM
/
grant select on GV_$TRANSPORTABLE_PLATFORM to select_catalog_role
/

create or replace view V_$DB_TRANSPORTABLE_PLATFORM
as select * from V$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$DB_TRANSPORTABLE_PLATFORM
for V_$DB_TRANSPORTABLE_PLATFORM
/
grant select on V_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$DB_TRANSPORTABLE_PLATFORM
as select * from GV$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$DB_TRANSPORTABLE_PLATFORM
for GV_$DB_TRANSPORTABLE_PLATFORM
/
grant select on GV_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/

create or replace view v_$iostat_network as select * from v$iostat_network;
create or replace public synonym v$iostat_network for v_$iostat_network;
grant select on v_$iostat_network to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_network as select * from gv$iostat_network;
create or replace public synonym gv$iostat_network for gv_$iostat_network;
grant select on gv_$iostat_network to SELECT_CATALOG_ROLE;

create or replace view gv_$cpool_cc_stats as select * from gv$cpool_cc_stats;
create or replace public synonym gv$cpool_cc_stats for gv_$cpool_cc_stats;
grant select on gv_$cpool_cc_stats to select_catalog_role;

create or replace view v_$cpool_cc_stats as select * from v$cpool_cc_stats;
create or replace public synonym v$cpool_cc_stats for v_$cpool_cc_stats;
grant select on v_$cpool_cc_stats to select_catalog_role;

create or replace view gv_$cpool_cc_info as select * from gv$cpool_cc_info;
create or replace public synonym gv$cpool_cc_info for gv_$cpool_cc_info;
grant select on gv_$cpool_cc_info to select_catalog_role;

create or replace view v_$cpool_cc_info as select * from v$cpool_cc_info;
create or replace public synonym v$cpool_cc_info for v_$cpool_cc_info;
grant select on v_$cpool_cc_info to select_catalog_role;

create or replace view gv_$cpool_stats as select * from gv$cpool_stats;
create or replace public synonym gv$cpool_stats for gv_$cpool_stats;
grant select on gv_$cpool_stats to select_catalog_role;

create or replace view v_$cpool_stats as select * from v$cpool_stats;
create or replace public synonym v$cpool_stats for v_$cpool_stats;
grant select on v_$cpool_stats to select_catalog_role; 

create or replace view gv_$cpool_conn_info as select * from gv$cpool_conn_info;
create or replace public synonym gv$cpool_conn_info for gv_$cpool_conn_info;
grant select on gv_$cpool_conn_info to select_catalog_role; 

create or replace view v_$cpool_conn_info as select * from v$cpool_conn_info;
create or replace public synonym v$cpool_conn_info for v_$cpool_conn_info;
grant select on v_$cpool_conn_info to select_catalog_role; 

create or replace view gv_$hm_run as select * from gv$hm_run;
create or replace public synonym gv$hm_run for gv_$hm_run;
grant select on gv_$hm_run to select_catalog_role;

create or replace view v_$hm_run as select * from v$hm_run;
create or replace public synonym v$hm_run for v_$hm_run;
grant select on v_$hm_run to select_catalog_role;

create or replace view gv_$hm_finding as select * from gv$hm_finding;
create or replace public synonym gv$hm_finding for gv_$hm_finding;
grant select on gv_$hm_finding to select_catalog_role;

create or replace view v_$hm_finding as select * from v$hm_finding;
create or replace public synonym v$hm_finding for v_$hm_finding;
grant select on v_$hm_finding to select_catalog_role;

create or replace view gv_$hm_recommendation as
  select * from gv$hm_recommendation;
create or replace public synonym gv$hm_recommendation for gv_$hm_recommendation;
grant select on gv_$hm_recommendation to select_catalog_role;

create or replace view v_$hm_recommendation as
  select * from v$hm_recommendation;
create or replace public synonym v$hm_recommendation for v_$hm_recommendation;
grant select on v_$hm_recommendation to select_catalog_role;

create or replace view gv_$hm_info as select * from gv$hm_info;
create or replace public synonym gv$hm_info for gv_$hm_info;
grant select on gv_$hm_info to select_catalog_role;

create or replace view v_$hm_info as select * from v$hm_info;
create or replace public synonym v$hm_info for v_$hm_info;
grant select on v_$hm_info to select_catalog_role;

create or replace view gv_$hm_check as select * from gv$hm_check;
create or replace public synonym gv$hm_check for gv_$hm_check;
grant select on gv_$hm_check to select_catalog_role;

create or replace view v_$hm_check as select * from v$hm_check;
create or replace public synonym v$hm_check for v_$hm_check;
grant select on v_$hm_check to select_catalog_role;

create or replace view gv_$hm_check_param as select * from gv$hm_check_param;
create or replace public synonym gv$hm_check_param for gv_$hm_check_param;
grant select on gv_$hm_check_param to select_catalog_role;

create or replace view v_$hm_check_param as select * from v$hm_check_param;
create or replace public synonym v$hm_check_param for v_$hm_check_param;
grant select on v_$hm_check_param to select_catalog_role;

create or replace view gv_$ir_failure as select * from gv$ir_failure;
create or replace public synonym gv$ir_failure for gv_$ir_failure;
grant select on gv_$ir_failure to select_catalog_role;

create or replace view v_$ir_failure as select * from v$ir_failure;
create or replace public synonym v$ir_failure for v_$ir_failure;
grant select on v_$ir_failure to select_catalog_role;

create or replace view gv_$ir_repair as select * from gv$ir_repair;
create or replace public synonym gv$ir_repair for gv_$ir_repair;
grant select on gv_$ir_repair to select_catalog_role;

create or replace view v_$ir_repair as select * from v$ir_repair;
create or replace public synonym v$ir_repair for v_$ir_repair;
grant select on v_$ir_repair to select_catalog_role;

create or replace view gv_$ir_manual_checklist as select * from gv$ir_manual_checklist;
create or replace public synonym gv$ir_manual_checklist for gv_$ir_manual_checklist;
grant select on gv_$ir_manual_checklist to select_catalog_role;

create or replace view v_$ir_manual_checklist as select * from v$ir_manual_checklist;
create or replace public synonym v$ir_manual_checklist for v_$ir_manual_checklist;
grant select on v_$ir_manual_checklist to select_catalog_role;

create or replace view gv_$ir_failure_set as select * from gv$ir_failure_set;
create or replace public synonym gv$ir_failure_set for gv_$ir_failure_set;
grant select on gv_$ir_failure_set to select_catalog_role;

create or replace view v_$ir_failure_set as select * from v$ir_failure_set;
create or replace public synonym v$ir_failure_set for v_$ir_failure_set;
grant select on v_$ir_failure_set to select_catalog_role;

create or replace view v_$px_instance_group
as select * from v$px_instance_group;
create or replace public synonym v$px_instance_group
for v_$px_instance_group;
grant select on v_$px_instance_group to select_catalog_role;

create or replace view gv_$px_instance_group
as select * from gv$px_instance_group;     
create or replace public synonym gv$px_instance_group
for gv_$px_instance_group;
grant select on gv_$px_instance_group to select_catalog_role;

create or replace view v_$iostat_consumer_group 
as select * from v$iostat_consumer_group;
create or replace public synonym v$iostat_consumer_group 
                             for v_$iostat_consumer_group;
grant select on v_$iostat_consumer_group to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_consumer_group 
as select * from gv$iostat_consumer_group;
create or replace public synonym gv$iostat_consumer_group 
                             for gv_$iostat_consumer_group;
grant select on gv_$iostat_consumer_group to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_function 
as select * from v$iostat_function;
create or replace public synonym v$iostat_function 
                             for v_$iostat_function;
grant select on v_$iostat_function to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_function 
as select * from gv$iostat_function;
create or replace public synonym gv$iostat_function 
                             for gv_$iostat_function;
grant select on gv_$iostat_function to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_function_detail
as select * from v$iostat_function_detail;
create or replace public synonym v$iostat_function_detail
                             for v_$iostat_function_detail;
grant select on v_$iostat_function_detail to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_function_detail 
as select * from gv$iostat_function_detail;
create or replace public synonym gv$iostat_function_detail 
                             for gv_$iostat_function_detail;
grant select on gv_$iostat_function_detail to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_file 
as select * from v$iostat_file;
create or replace public synonym v$iostat_file 
                             for v_$iostat_file;
grant select on v_$iostat_file to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_file 
as select * from gv$iostat_file;
create or replace public synonym gv$iostat_file 
                             for gv_$iostat_file;
grant select on gv_$iostat_file to SELECT_CATALOG_ROLE;


create or replace view v_$io_calibration_status
as select * from v$io_calibration_status;
create or replace public synonym v$io_calibration_status
                             for v_$io_calibration_status;
grant select on v_$io_calibration_status to SELECT_CATALOG_ROLE;

create or replace view gv_$io_calibration_status
as select * from gv$io_calibration_status;
create or replace public synonym gv$io_calibration_status 
                             for gv_$io_calibration_status;
grant select on gv_$io_calibration_status to SELECT_CATALOG_ROLE;


create or replace view gv_$corrupt_xid_list as select * from gv$corrupt_xid_list;
create or replace public synonym gv$corrupt_xid_list for gv_$corrupt_xid_list;
grant select on gv_$corrupt_xid_list to SELECT_CATALOG_ROLE;

create or replace view gv_$calltag as select * from gv$calltag;
create or replace public synonym gv$calltag for gv_$calltag;
grant select on gv_$calltag to select_catalog_role;
create or replace view v_$corrupt_xid_list as select * from v$corrupt_xid_list;
create or replace public synonym v$corrupt_xid_list for v_$corrupt_xid_list;
grant select on v_$corrupt_xid_list to SELECT_CATALOG_ROLE;

create or replace view gv_$persistent_queues as
    select * from gv$persistent_queues;
create or replace public synonym gv$persistent_queues
    for gv_$persistent_queues;
grant select on gv_$persistent_queues to select_catalog_role;

create or replace view v_$persistent_queues as
    select * from v$persistent_queues;
create or replace public synonym v$persistent_queues
    for v_$persistent_queues;
grant select on v_$persistent_queues to select_catalog_role;

create or replace view gv_$persistent_subscribers as
    select * from gv$persistent_subscribers;
create or replace public synonym gv$persistent_subscribers
    for gv_$persistent_subscribers;
grant select on gv_$persistent_subscribers to select_catalog_role;

create or replace view v_$persistent_subscribers as
    select * from v$persistent_subscribers;
create or replace public synonym v$persistent_subscribers
    for v_$persistent_subscribers;
grant select on v_$persistent_subscribers to select_catalog_role;

create or replace view gv_$persistent_publishers as
    select * from gv$persistent_publishers;
create or replace public synonym gv$persistent_publishers
    for gv_$persistent_publishers;
grant select on gv_$persistent_publishers to select_catalog_role;

create or replace view v_$persistent_publishers as
    select * from v$persistent_publishers;
create or replace public synonym v$persistent_publishers
    for v_$persistent_publishers;
grant select on v_$persistent_publishers to select_catalog_role;

create or replace view V_$AQ_NONDUR_SUBSCRIBER as
    select * from V$AQ_NONDUR_SUBSCRIBER;
create or replace public synonym V$AQ_NONDUR_SUBSCRIBER
    for V_$AQ_NONDUR_SUBSCRIBER;
grant select on V_$AQ_NONDUR_SUBSCRIBER to select_catalog_role;

create or replace view GV_$AQ_NONDUR_SUBSCRIBER as
    select * from GV$AQ_NONDUR_SUBSCRIBER;
create or replace public synonym GV$AQ_NONDUR_SUBSCRIBER
    for GV_$AQ_NONDUR_SUBSCRIBER;
grant select on GV_$AQ_NONDUR_SUBSCRIBER to select_catalog_role;

create or replace view V_$AQ_NONDUR_SUBSCRIBER_LWM as
    select * from V$AQ_NONDUR_SUBSCRIBER_LWM;
create or replace public synonym V$AQ_NONDUR_SUBSCRIBER_LWM
    for V_$AQ_NONDUR_SUBSCRIBER_LWM;
grant select on V_$AQ_NONDUR_SUBSCRIBER_LWM to select_catalog_role;

create or replace view GV_$AQ_NONDUR_SUBSCRIBER_LWM as 
    select * from GV$AQ_NONDUR_SUBSCRIBER_LWM;
create or replace public synonym GV$AQ_NONDUR_SUBSCRIBER_LWM
    for GV_$AQ_NONDUR_SUBSCRIBER_LWM;
grant select on GV_$AQ_NONDUR_SUBSCRIBER_LWM to select_catalog_role;

create or replace view V_$AQ_BMAP_NONDUR_SUBSCRIBERS as
    select * from V$AQ_BMAP_NONDUR_SUBSCRIBERS;
create or replace public synonym V$AQ_BMAP_NONDUR_SUBSCRIBERS
    for V_$AQ_BMAP_NONDUR_SUBSCRIBERS;
grant select on V_$AQ_BMAP_NONDUR_SUBSCRIBERS to select_catalog_role;

create or replace view GV_$AQ_BMAP_NONDUR_SUBSCRIBERS as
    select * from GV$AQ_BMAP_NONDUR_SUBSCRIBERS;    
create or replace public synonym GV$AQ_BMAP_NONDUR_SUBSCRIBERS
    for GV_$AQ_BMAP_NONDUR_SUBSCRIBERS;
grant select on GV_$AQ_BMAP_NONDUR_SUBSCRIBERS to select_catalog_role; 

create or replace view gv_$aq_subscriber_load as
    select * from gv$aq_subscriber_load;    
create or replace public synonym gv$aq_subscriber_load
    for gv_$aq_subscriber_load;
grant select on gv_$aq_subscriber_load to select_catalog_role; 

create or replace view v_$aq_subscriber_load as
    select * from v$aq_subscriber_load;    
create or replace public synonym v$aq_subscriber_load
    for v_$aq_subscriber_load;
grant select on v_$aq_subscriber_load to select_catalog_role; 

create or replace view gv_$aq_remote_dequeue_affinity as
    select * from gv$aq_remote_dequeue_affinity;
create or replace public synonym gv$aq_remote_dequeue_affinity
    for gv_$aq_remote_dequeue_affinity;
grant select on gv_$aq_remote_dequeue_affinity to select_catalog_role;

create or replace view v_$aq_remote_dequeue_affinity as
    select * from v$aq_remote_dequeue_affinity;
create or replace public synonym v$aq_remote_dequeue_affinity
    for v_$aq_remote_dequeue_affinity;
grant select on v_$aq_remote_dequeue_affinity to select_catalog_role;

create or replace view gv_$aq_message_cache_stat as
    select * from gv$aq_message_cache_stat;
create or replace public synonym gv$aq_message_cache_stat
    for gv_$aq_message_cache_stat;
grant select on gv_$aq_message_cache_stat to select_catalog_role;

create or replace view v_$aq_message_cache_stat as
    select * from v$aq_message_cache_stat;
create or replace public synonym v$aq_message_cache_stat
    for v_$aq_message_cache_stat;
grant select on v_$aq_message_cache_stat to select_catalog_role;

create or replace view gv_$aq_cached_subshards as
    select * from gv$aq_cached_subshards;
create or replace public synonym gv$aq_cached_subshards
    for gv_$aq_cached_subshards;
grant select on gv_$aq_cached_subshards to select_catalog_role;

create or replace view v_$aq_cached_subshards as
    select * from v$aq_cached_subshards;
create or replace public synonym v$aq_cached_subshards
    for v_$aq_cached_subshards;
grant select on v_$aq_cached_subshards to select_catalog_role;

create or replace view gv_$aq_uncached_subshards as
    select * from gv$aq_uncached_subshards;
create or replace public synonym gv$aq_uncached_subshards
    for gv_$aq_uncached_subshards;
grant select on gv_$aq_uncached_subshards to select_catalog_role;

create or replace view v_$aq_uncached_subshards as
    select * from v$aq_uncached_subshards;
create or replace public synonym v$aq_uncached_subshards
    for v_$aq_uncached_subshards;
grant select on v_$aq_uncached_subshards to select_catalog_role;

create or replace view gv_$aq_inactive_subshards as
    select * from gv$aq_inactive_subshards;
create or replace public synonym gv$aq_inactive_subshards
    for gv_$aq_inactive_subshards;
grant select on gv_$aq_inactive_subshards to select_catalog_role;

create or replace view v_$aq_inactive_subshards as
    select * from v$aq_inactive_subshards;
create or replace public synonym v$aq_inactive_subshards
    for v_$aq_inactive_subshards;
grant select on v_$aq_inactive_subshards to select_catalog_role;

Rem
Rem AQ Message Cache Advisor view
Rem
create or replace view gv_$aq_message_cache_advice as
    select * from gv$aq_message_cache_advice;
create or replace public synonym gv$aq_message_cache_advice
    for gv_$aq_message_cache_advice;
grant select on gv_$aq_message_cache_advice to select_catalog_role;

create or replace view v_$aq_message_cache_advice as
    select * from v$aq_message_cache_advice;
create or replace public synonym v$aq_message_cache_advice
    for v_$aq_message_cache_advice;
grant select on v_$aq_message_cache_advice to select_catalog_role;

Rem
Rem AQ Sharded Subscriber stats view
Rem
create or replace view gv_$aq_sharded_subscriber_stat as
    select * from gv$aq_sharded_subscriber_stat;
create or replace public synonym gv$aq_sharded_subscriber_stat
    for gv_$aq_sharded_subscriber_stat;
grant select on gv_$aq_sharded_subscriber_stat to select_catalog_role;

create or replace view v_$aq_sharded_subscriber_stat as
    select * from v$aq_sharded_subscriber_stat;
create or replace public synonym v$aq_sharded_subscriber_stat
    for v_$aq_sharded_subscriber_stat;
grant select on v_$aq_sharded_subscriber_stat to select_catalog_role;


create or replace view gv_$ro_user_account as
    select * from gv$ro_user_account;
create or replace public synonym gv$ro_user_account
    for gv_$ro_user_account;
grant select on gv_$ro_user_account to select_catalog_role;

create or replace view v_$ro_user_account as
    select * from v$ro_user_account;
create or replace public synonym v$ro_user_account
    for v_$ro_user_account;
grant select on v_$ro_user_account to select_catalog_role;

Rem
Rem Process group fixed views
Rem

create or replace view gv_$process_group
       as select * from gv$process_group;
create or replace public synonym gv$process_group
       for gv_$process_group;
grant select on gv_$process_group to select_catalog_role;

create or replace view gv_$detached_session
       as select * from gv$detached_session;
create or replace public synonym gv$detached_session
       for gv_$detached_session;
grant select on gv_$detached_session to select_catalog_role;

Rem 
Rem SSCR fixed views
Rem
create or replace view gv_$sscr_sessions as
    select * from gv$sscr_sessions;
create or replace public synonym gv$sscr_sessions
    for gv_$sscr_sessions;
grant select on gv_$sscr_sessions to select_catalog_role;

create or replace view v_$sscr_sessions as
    select * from v$sscr_sessions;
create or replace public synonym v$sscr_sessions
    for v_$sscr_sessions;
grant select on v_$sscr_sessions to select_catalog_role;
Rem
Rem NFS fixed views
Rem
create or replace view gv_$nfs_clients as
    select * from gv$nfs_clients;
create or replace public synonym gv$nfs_clients
    for gv_$nfs_clients;
grant select on gv_$nfs_clients to select_catalog_role;

create or replace view v_$nfs_clients as
    select * from v$nfs_clients;
create or replace public synonym v$nfs_clients
    for v_$nfs_clients;
grant select on v_$nfs_clients to select_catalog_role;

create or replace view gv_$nfs_open_files as
    select * from gv$nfs_open_files;
create or replace public synonym gv$nfs_open_files
    for gv_$nfs_open_files;
grant select on gv_$nfs_open_files to select_catalog_role;

create or replace view v_$nfs_open_files as
    select * from v$nfs_open_files;
create or replace public synonym v$nfs_open_files
    for v_$nfs_open_files;
grant select on v_$nfs_open_files to select_catalog_role;

create or replace view gv_$nfs_locks as
    select * from gv$nfs_locks;
create or replace public synonym gv$nfs_locks
    for gv_$nfs_locks;
grant select on gv_$nfs_locks to select_catalog_role;

create or replace view v_$nfs_locks as
    select * from v$nfs_locks;
create or replace public synonym v$nfs_locks
    for v_$nfs_locks;
grant select on v_$nfs_locks to select_catalog_role;

Rem
Rem RMAN compression fixed views
Rem

create or replace view v_$rman_compression_algorithm as 
    select * from v$rman_compression_algorithm;
create or replace public synonym v$rman_compression_algorithm 
    for v_$rman_compression_algorithm;
grant select on v_$rman_compression_algorithm to select_catalog_role;

create or replace view gv_$rman_compression_algorithm as 
    select * from gv$rman_compression_algorithm;
create or replace public synonym gv$rman_compression_algorithm 
    for gv_$rman_compression_algorithm;
grant select on gv_$rman_compression_algorithm to select_catalog_role;

Rem
Rem Encryption fixed views
Rem

create or replace view v_$encryption_wallet as
    select * from v$encryption_wallet;
create or replace public synonym v$encryption_wallet 
    for v_$encryption_wallet;
grant select on v_$encryption_wallet to select_catalog_role;

create or replace view gv_$encryption_wallet as 
    select * from gv$encryption_wallet;
create or replace public synonym gv$encryption_wallet 
    for gv_$encryption_wallet;
grant select on gv_$encryption_wallet to select_catalog_role;

create or replace view v_$encrypted_tablespaces as
select * from v$encrypted_tablespaces;
create or replace public synonym v$encrypted_tablespaces
   for v_$encrypted_tablespaces;
grant select on v_$encrypted_tablespaces to select_catalog_role;

create or replace view gv_$encrypted_tablespaces as
select * from gv$encrypted_tablespaces;
create or replace public synonym gv$encrypted_tablespaces
   for gv_$encrypted_tablespaces;
grant select on gv_$encrypted_tablespaces to select_catalog_role;

create or replace view v_$database_key_info as
select * from v$database_key_info;
create or replace public synonym v$database_key_info
   for v_$database_key_info;
grant select on v_$database_key_info to select_catalog_role;

create or replace view gv_$database_key_info as
select * from gv$database_key_info;
create or replace public synonym gv$database_key_info
   for gv_$database_key_info;
grant select on gv_$database_key_info to select_catalog_role;

create or replace view v_$encryption_keys as
    select * from v$encryption_keys;
create or replace public synonym v$encryption_keys
    for v_$encryption_keys;
grant select on v_$encryption_keys to select_catalog_role;

create or replace view gv_$encryption_keys as
    select * from gv$encryption_keys;
create or replace public synonym gv$encryption_keys
    for gv_$encryption_keys;
grant select on gv_$encryption_keys to select_catalog_role;

create or replace view v_$client_secrets as
    select * from v$client_secrets;
create or replace public synonym v$client_secrets
    for v_$client_secrets;
grant select on v_$client_secrets to select_catalog_role;

create or replace view gv_$client_secrets as
    select * from gv$client_secrets;
create or replace public synonym gv$client_secrets
    for gv_$client_secrets;
grant select on gv_$client_secrets to select_catalog_role;

Rem
Rem INCMETER fixed views
Rem
create or replace view gv_$incmeter_config as select * from gv$incmeter_config;
create or replace public synonym gv$incmeter_config for gv_$incmeter_config;
grant select on gv_$incmeter_config to select_catalog_role;

create or replace view v_$incmeter_config as select * from v$incmeter_config;
create or replace public synonym v$incmeter_config for v_$incmeter_config;
grant select on v_$incmeter_config to select_catalog_role;

create or replace view gv_$incmeter_summary as 
    select * from gv$incmeter_summary;
create or replace public synonym gv$incmeter_summary for gv_$incmeter_summary;
grant select on gv_$incmeter_summary to select_catalog_role;

create or replace view v_$incmeter_summary as select * from v$incmeter_summary;
create or replace public synonym v$incmeter_summary for v_$incmeter_summary;
grant select on v_$incmeter_summary to select_catalog_role;

create or replace view gv_$incmeter_info as select * from gv$incmeter_info;
create or replace public synonym gv$incmeter_info for gv_$incmeter_info;
grant select on gv_$incmeter_info to select_catalog_role;

create or replace view v_$incmeter_info as select * from v$incmeter_info;
create or replace public synonym v$incmeter_info for v_$incmeter_info;
grant select on v_$incmeter_info to select_catalog_role;

create or replace view gv_$dnfs_stats as
  select * from gv$dnfs_stats;
create or replace public synonym gv$dnfs_stats for gv_$dnfs_stats;
grant select on gv_$dnfs_stats to select_catalog_role;

create or replace view v_$dnfs_stats as
  select * from v$dnfs_stats;
create or replace public synonym v$dnfs_stats for v_$dnfs_stats;
grant select on v_$dnfs_stats to select_catalog_role;

create or replace view gv_$dnfs_files as
  select * from gv$dnfs_files;
create or replace public synonym gv$dnfs_files for gv_$dnfs_files;
grant select on gv_$dnfs_files to select_catalog_role;

create or replace view v_$dnfs_files as
  select * from v$dnfs_files;
create or replace public synonym v$dnfs_files for v_$dnfs_files;
grant select on v_$dnfs_files to select_catalog_role;

create or replace view gv_$dnfs_servers as
  select * from gv$dnfs_servers;
create or replace public synonym gv$dnfs_servers for gv_$dnfs_servers;
grant select on gv_$dnfs_servers to select_catalog_role;

create or replace view v_$dnfs_servers as
  select * from v$dnfs_servers;
create or replace public synonym v$dnfs_servers for v_$dnfs_servers;
grant select on v_$dnfs_servers to select_catalog_role;

Rem
Rem ASM volume views
Rem

create or replace view gv_$asm_volume as
    select * from gv$asm_volume;
create or replace public synonym gv$asm_volume
    for gv_$asm_volume;
grant select on gv_$asm_volume to select_catalog_role;

create or replace view v_$asm_volume as
    select * from v$asm_volume;
create or replace public synonym v$asm_volume
    for v_$asm_volume;
grant select on v_$asm_volume to select_catalog_role;

create or replace view gv_$asm_volume_stat as
    select * from gv$asm_volume_stat;
create or replace public synonym gv$asm_volume_stat
    for gv_$asm_volume_stat;
grant select on gv_$asm_volume_stat to select_catalog_role;

create or replace view v_$asm_volume_stat as
    select * from v$asm_volume_stat;
create or replace public synonym v$asm_volume_stat
    for v_$asm_volume_stat;
grant select on v_$asm_volume_stat to select_catalog_role;

create or replace view gv_$asm_filesystem as
    select * from gv$asm_filesystem;
create or replace public synonym gv$asm_filesystem
    for gv_$asm_filesystem;
grant select on gv_$asm_filesystem to select_catalog_role;

create or replace view v_$asm_filesystem as
    select * from v$asm_filesystem;
create or replace public synonym v$asm_filesystem
    for v_$asm_filesystem;
grant select on v_$asm_filesystem to select_catalog_role;

create or replace view gv_$asm_acfsvolumes as
    select * from gv$asm_acfsvolumes;
create or replace public synonym gv$asm_acfsvolumes
    for gv_$asm_acfsvolumes;
grant select on gv_$asm_acfsvolumes to select_catalog_role;

create or replace view v_$asm_acfsvolumes as
    select * from v$asm_acfsvolumes;
create or replace public synonym v$asm_acfsvolumes
    for v_$asm_acfsvolumes;
grant select on v_$asm_acfsvolumes to select_catalog_role;

create or replace view gv_$asm_acfssnapshots as
    select * from gv$asm_acfssnapshots;
create or replace public synonym gv$asm_acfssnapshots
    for gv_$asm_acfssnapshots;
grant select on gv_$asm_acfssnapshots to select_catalog_role;

create or replace view v_$asm_acfssnapshots as
    select * from v$asm_acfssnapshots;
create or replace public synonym v$asm_acfssnapshots
    for v_$asm_acfssnapshots;
grant select on v_$asm_acfssnapshots to select_catalog_role;

create or replace view gv_$asm_acfstag as
    select * from gv$asm_acfstag;
create or replace public synonym gv$asm_acfstag
    for gv_$asm_acfstag;
grant select on gv_$asm_acfstag to select_catalog_role;

create or replace view v_$asm_acfstag as
    select * from v$asm_acfstag;
create or replace public synonym v$asm_acfstag
    for v_$asm_acfstag;
grant select on v_$asm_acfstag to select_catalog_role;

create or replace view gv_$asm_acfs_security_info as
    select * from gv$asm_acfs_security_info;
create or replace public synonym gv$asm_acfs_security_info
    for gv_$asm_acfs_security_info;
grant select on gv_$asm_acfs_security_info to select_catalog_role;

create or replace view v_$asm_acfs_security_info as
    select * from v$asm_acfs_security_info;
create or replace public synonym v$asm_acfs_security_info
    for v_$asm_acfs_security_info;
grant select on v_$asm_acfs_security_info to select_catalog_role;

create or replace view gv_$asm_acfs_encryption_info as
    select * from gv$asm_acfs_encryption_info;
create or replace public synonym gv$asm_acfs_encryption_info
    for gv_$asm_acfs_encryption_info;
grant select on gv_$asm_acfs_encryption_info to select_catalog_role;

create or replace view v_$asm_acfs_encryption_info as
    select * from v$asm_acfs_encryption_info;
create or replace public synonym v$asm_acfs_encryption_info
    for v_$asm_acfs_encryption_info;
grant select on v_$asm_acfs_encryption_info to select_catalog_role;

create or replace view gv_$asm_acfs_sec_rule as
    select * from gv$asm_acfs_sec_rule;
create or replace public synonym gv$asm_acfs_sec_rule
    for gv_$asm_acfs_sec_rule;
grant select on gv_$asm_acfs_sec_rule to select_catalog_role;

create or replace view v_$asm_acfs_sec_rule as
    select * from v$asm_acfs_sec_rule;
create or replace public synonym v$asm_acfs_sec_rule
    for v_$asm_acfs_sec_rule;
grant select on v_$asm_acfs_sec_rule to select_catalog_role;

create or replace view gv_$asm_acfs_sec_realm as
    select * from gv$asm_acfs_sec_realm;
create or replace public synonym gv$asm_acfs_sec_realm
    for gv_$asm_acfs_sec_realm;
grant select on gv_$asm_acfs_sec_realm to select_catalog_role;

create or replace view v_$asm_acfs_sec_realm as
    select * from v$asm_acfs_sec_realm;
create or replace public synonym v$asm_acfs_sec_realm
    for v_$asm_acfs_sec_realm;
grant select on v_$asm_acfs_sec_realm to select_catalog_role;

create or replace view gv_$asm_acfs_sec_realm_user as
    select * from gv$asm_acfs_sec_realm_user;
create or replace public synonym gv$asm_acfs_sec_realm_user
    for gv_$asm_acfs_sec_realm_user;
grant select on gv_$asm_acfs_sec_realm_user to select_catalog_role;

create or replace view v_$asm_acfs_sec_realm_user as
    select * from v$asm_acfs_sec_realm_user;
create or replace public synonym v$asm_acfs_sec_realm_user
    for v_$asm_acfs_sec_realm_user;
grant select on v_$asm_acfs_sec_realm_user to select_catalog_role;

create or replace view gv_$asm_acfs_sec_realm_group as
    select * from gv$asm_acfs_sec_realm_group;
create or replace public synonym gv$asm_acfs_sec_realm_group
    for gv_$asm_acfs_sec_realm_group;
grant select on gv_$asm_acfs_sec_realm_group to select_catalog_role;

create or replace view v_$asm_acfs_sec_realm_group as
    select * from v$asm_acfs_sec_realm_group;
create or replace public synonym v$asm_acfs_sec_realm_group
    for v_$asm_acfs_sec_realm_group;
grant select on v_$asm_acfs_sec_realm_group to select_catalog_role;

create or replace view gv_$asm_acfs_sec_realm_filter as
    select * from gv$asm_acfs_sec_realm_filter;
create or replace public synonym gv$asm_acfs_sec_realm_filter
    for gv_$asm_acfs_sec_realm_filter;
grant select on gv_$asm_acfs_sec_realm_filter to select_catalog_role;

create or replace view v_$asm_acfs_sec_realm_filter as
    select * from v$asm_acfs_sec_realm_filter;
create or replace public synonym v$asm_acfs_sec_realm_filter
    for v_$asm_acfs_sec_realm_filter;
grant select on v_$asm_acfs_sec_realm_filter to select_catalog_role;

create or replace view gv_$asm_acfs_sec_ruleset as
    select * from gv$asm_acfs_sec_ruleset;
create or replace public synonym gv$asm_acfs_sec_ruleset
    for gv_$asm_acfs_sec_ruleset;     
grant select on gv_$asm_acfs_sec_ruleset to select_catalog_role;

create or replace view v_$asm_acfs_sec_ruleset as
    select * from v$asm_acfs_sec_ruleset;
create or replace public synonym v$asm_acfs_sec_ruleset
    for v_$asm_acfs_sec_ruleset; 
grant select on v_$asm_acfs_sec_ruleset to select_catalog_role;

create or replace view gv_$asm_acfs_sec_ruleset_rule as
    select * from gv$asm_acfs_sec_ruleset_rule;
create or replace public synonym gv$asm_acfs_sec_ruleset_rule
    for gv_$asm_acfs_sec_ruleset_rule;
grant select on gv_$asm_acfs_sec_ruleset_rule to select_catalog_role;

create or replace view v_$asm_acfs_sec_ruleset_rule as
    select * from v$asm_acfs_sec_ruleset_rule;
create or replace public synonym v$asm_acfs_sec_ruleset_rule
    for v_$asm_acfs_sec_ruleset_rule;     
grant select on v_$asm_acfs_sec_ruleset_rule to select_catalog_role;

create or replace view gv_$asm_acfs_sec_cmdrule as
    select * from gv$asm_acfs_sec_cmdrule;
create or replace public synonym gv$asm_acfs_sec_cmdrule
    for gv_$asm_acfs_sec_cmdrule;
grant select on gv_$asm_acfs_sec_cmdrule to select_catalog_role;

create or replace view v_$asm_acfs_sec_cmdrule as
    select * from v$asm_acfs_sec_cmdrule;
create or replace public synonym v$asm_acfs_sec_cmdrule
    for v_$asm_acfs_sec_cmdrule;
grant select on v_$asm_acfs_sec_cmdrule to select_catalog_role;

create or replace view gv_$asm_acfs_sec_admin as
    select * from gv$asm_acfs_sec_admin;
create or replace public synonym gv$asm_acfs_sec_admin
    for gv_$asm_acfs_sec_admin;
grant select on gv_$asm_acfs_sec_admin to select_catalog_role;

create or replace view v_$asm_acfs_sec_admin as
    select * from v$asm_acfs_sec_admin;
create or replace public synonym v$asm_acfs_sec_admin
    for v_$asm_acfs_sec_admin;
grant select on v_$asm_acfs_sec_admin to select_catalog_role;

create or replace view gv_$asm_acfsrepl as
    select * from gv$asm_acfsrepl;
create or replace public synonym gv$asm_acfsrepl
    for gv_$asm_acfsrepl;
grant select on gv_$asm_acfsrepl to select_catalog_role;

create or replace view v_$asm_acfsrepl as
    select * from v$asm_acfsrepl;
create or replace public synonym v$asm_acfsrepl
    for v_$asm_acfsrepl;
grant select on v_$asm_acfsrepl to select_catalog_role;

create or replace view gv_$asm_acfsrepltag as
    select * from gv$asm_acfsrepltag;
create or replace public synonym gv$asm_acfsrepltag
    for gv_$asm_acfsrepltag;
grant select on gv_$asm_acfsrepltag to select_catalog_role;

create or replace view v_$asm_acfsrepltag as
    select * from v$asm_acfsrepltag;
create or replace public synonym v$asm_acfsrepltag
    for v_$asm_acfsrepltag;
grant select on v_$asm_acfsrepltag to select_catalog_role;

create or replace view v_$flashback_txn_mods as 
  select * from v$flashback_txn_mods;
create or replace public synonym v$flashback_txn_mods 
  for v_$flashback_txn_mods;
grant read on v_$flashback_txn_mods to public;

create or replace view v_$flashback_txn_graph as 
  select * from v$flashback_txn_graph;
create or replace public synonym v$flashback_txn_graph
  for v_$flashback_txn_graph;
grant read on v_$flashback_txn_graph to public;     

create or replace view gv_$lobstat as
  select * from gv$lobstat;
create or replace public synonym gv$lobstat for gv_$lobstat;
grant select on gv_$lobstat to select_catalog_role;

create or replace view v_$lobstat as
  select * from v$lobstat;
create or replace public synonym v$lobstat for v_$lobstat;
grant select on v_$lobstat to select_catalog_role;

create or replace view gv_$fs_failover_stats as
  select * from gv$fs_failover_stats;
create or replace public synonym gv$fs_failover_stats 
  for gv_$fs_failover_stats;
grant select on gv_$fs_failover_stats to select_catalog_role;

create or replace view v_$fs_failover_stats as
  select * from v$fs_failover_stats;
create or replace public synonym v$fs_failover_stats for v_$fs_failover_stats;
grant select on v_$fs_failover_stats to select_catalog_role;

create or replace view gv_$asm_disk_iostat as
  select * from gv$asm_disk_iostat;
create or replace public synonym gv$asm_disk_iostat 
  for gv_$asm_disk_iostat;
grant select on gv_$asm_disk_iostat to select_catalog_role;

create or replace view v_$asm_disk_iostat as
  select * from v$asm_disk_iostat;
create or replace public synonym v$asm_disk_iostat for v_$asm_disk_iostat;
grant select on v_$asm_disk_iostat to select_catalog_role;

Rem
Rem DIAG_INFO fixed views
Rem
create or replace view gv_$diag_info as select * from gv$diag_info;
create or replace public synonym gv$diag_info for gv_$diag_info;
grant read on gv_$diag_info to public;

create or replace view v_$diag_info as select * from v$diag_info;
create or replace public synonym v$diag_info for v_$diag_info;
grant read on v_$diag_info to public;

Rem Securefiles fixed views

create or replace view gv_$securefile_timer as
  select * from gv$securefile_timer;
create or replace public synonym gv$securefile_timer
  for gv_$securefile_timer;
grant select on gv_$securefile_timer to select_catalog_role;

create or replace view v_$securefile_timer as
  select * from v$securefile_timer;
create or replace public synonym v$securefile_timer
  for v_$securefile_timer;
grant select on v_$securefile_timer to select_catalog_role;

create or replace view gv_$dnfs_channels as
  select * from gv$dnfs_channels;
create or replace public synonym gv$dnfs_channels 
  for gv_$dnfs_channels;
grant select on gv_$dnfs_channels to select_catalog_role;

create or replace view v_$dnfs_channels as
  select * from v$dnfs_channels;
create or replace public synonym v$dnfs_channels 
  for v_$dnfs_channels;
grant select on v_$dnfs_channels to select_catalog_role;

Rem
Rem DIAG_CRITICAL_ERROR fixed view
Rem
create or replace view v_$diag_critical_error as 
  select * from v$diag_critical_error;
create or replace public synonym v$diag_critical_error
  for v_$diag_critical_error;
grant read on v_$diag_critical_error to public;

create or replace view gv_$cell_state as
  select * from gv$cell_state;
create or replace public synonym gv$cell_state 
  for gv_$cell_state;
grant select on gv_$cell_state to select_catalog_role;

create or replace view v_$cell_state as
  select * from v$cell_state;
create or replace public synonym v$cell_state 
  for v_$cell_state;
grant select on v_$cell_state to select_catalog_role;

create or replace view gv_$cell_thread_history as
  select * from gv$cell_thread_history;
create or replace public synonym gv$cell_thread_history 
  for gv_$cell_thread_history;
grant select on gv_$cell_thread_history to select_catalog_role;

create or replace view v_$cell_thread_history as
  select * from v$cell_thread_history;
create or replace public synonym v$cell_thread_history 
  for v_$cell_thread_history;
grant select on v_$cell_thread_history to select_catalog_role;

create or replace view gv_$cell_ofl_thread_history as
  select * from gv$cell_ofl_thread_history;
create or replace public synonym gv$cell_ofl_thread_history 
  for gv_$cell_ofl_thread_history;
grant select on gv_$cell_ofl_thread_history to select_catalog_role;

create or replace view v_$cell_ofl_thread_history as
  select * from v$cell_ofl_thread_history;
create or replace public synonym v$cell_ofl_thread_history 
  for v_$cell_ofl_thread_history;
grant select on v_$cell_ofl_thread_history to select_catalog_role;

create or replace view gv_$cell_request_totals as
  select * from gv$cell_request_totals;
create or replace public synonym gv$cell_request_totals 
  for gv_$cell_request_totals;
grant select on gv_$cell_request_totals to select_catalog_role;

create or replace view v_$cell_request_totals as
  select * from v$cell_request_totals;
create or replace public synonym v$cell_request_totals 
  for v_$cell_request_totals;
grant select on v_$cell_request_totals to select_catalog_role;

create or replace view gv_$cell as
  select * from gv$cell;
create or replace public synonym gv$cell
  for gv_$cell;
grant select on gv_$cell to select_catalog_role;

create or replace view v_$cell as
  select * from v$cell;
create or replace public synonym v$cell
  for v_$cell;
grant select on v_$cell to select_catalog_role;

create or replace view gv_$cell_config as
  select * from gv$cell_config;
create or replace public synonym gv$cell_config
  for gv_$cell_config;
grant select on gv_$cell_config to select_catalog_role;

create or replace view v_$cell_config as
  select * from v$cell_config;
create or replace public synonym v$cell_config
  for v_$cell_config;
grant select on v_$cell_config to select_catalog_role;

create or replace view gv_$cell_config_info as
  select * from gv$cell_config_info;
create or replace public synonym gv$cell_config_info
  for gv_$cell_config_info;
grant select on gv_$cell_config_info to select_catalog_role;

create or replace view v_$cell_config_info as
  select * from v$cell_config_info;
create or replace public synonym v$cell_config_info
  for v_$cell_config_info;
grant select on v_$cell_config_info to select_catalog_role;

create or replace view gv_$cell_metric_desc as
  select * from gv$cell_metric_desc;
create or replace public synonym gv$cell_metric_desc
  for gv_$cell_metric_desc;
grant select on gv_$cell_metric_desc to select_catalog_role;

create or replace view v_$cell_metric_desc as
  select * from v$cell_metric_desc;
create or replace public synonym v$cell_metric_desc
  for v_$cell_metric_desc;
grant select on v_$cell_metric_desc to select_catalog_role;

create or replace view gv_$cell_global as
  select * from gv$cell_global;
create or replace public synonym gv$cell_global
  for gv_$cell_global;
grant select on gv_$cell_global to select_catalog_role;

create or replace view v_$cell_global as
  select * from v$cell_global;
create or replace public synonym v$cell_global
  for v_$cell_global;
grant select on v_$cell_global to select_catalog_role;

create or replace view gv_$cell_global_history as
  select * from gv$cell_global_history;
create or replace public synonym gv$cell_global_history
  for gv_$cell_global_history;
grant select on gv_$cell_global_history to select_catalog_role;

create or replace view v_$cell_global_history as
  select * from v$cell_global_history;
create or replace public synonym v$cell_global_history
  for v_$cell_global_history;
grant select on v_$cell_global_history to select_catalog_role;

create or replace view gv_$cell_disk as
  select * from gv$cell_disk;
create or replace public synonym gv$cell_disk
  for gv_$cell_disk;
grant select on gv_$cell_disk to select_catalog_role;

create or replace view v_$cell_disk as
  select * from v$cell_disk;
create or replace public synonym v$cell_disk
  for v_$cell_disk;
grant select on v_$cell_disk to select_catalog_role;

create or replace view gv_$cell_disk_history as
  select * from gv$cell_disk_history;
create or replace public synonym gv$cell_disk_history
  for gv_$cell_disk_history;
grant select on gv_$cell_disk_history to select_catalog_role;

create or replace view v_$cell_disk_history as
  select * from v$cell_disk_history;
create or replace public synonym v$cell_disk_history
  for v_$cell_disk_history;
grant select on v_$cell_disk_history to select_catalog_role;

create or replace view gv_$cell_ioreason as
  select * from gv$cell_ioreason;
create or replace public synonym gv$cell_ioreason
  for gv_$cell_ioreason;
grant select on gv_$cell_ioreason to select_catalog_role;

create or replace view v_$cell_ioreason as
  select * from v$cell_ioreason;
create or replace public synonym v$cell_ioreason
  for v_$cell_ioreason;
grant select on v_$cell_ioreason to select_catalog_role;

create or replace view gv_$cell_ioreason_name as
  select * from gv$cell_ioreason_name;
create or replace public synonym gv$cell_ioreason_name
  for gv_$cell_ioreason_name;
grant select on gv_$cell_ioreason_name to select_catalog_role;

create or replace view v_$cell_ioreason_name as
  select * from v$cell_ioreason_name;
create or replace public synonym v$cell_ioreason_name
  for v_$cell_ioreason_name;
grant select on v_$cell_ioreason_name to select_catalog_role;

create or replace view gv_$cell_db as
  select * from gv$cell_db;
create or replace public synonym gv$cell_db
  for gv_$cell_db;
grant select on gv_$cell_db to select_catalog_role;

create or replace view v_$cell_db as
  select * from v$cell_db;
create or replace public synonym v$cell_db
  for v_$cell_db;
grant select on v_$cell_db to select_catalog_role;

create or replace view gv_$cell_db_history as
  select * from gv$cell_db_history;
create or replace public synonym gv$cell_db_history
  for gv_$cell_db_history;
grant select on gv_$cell_db_history to select_catalog_role;

create or replace view v_$cell_db_history as
  select * from v$cell_db_history;
create or replace public synonym v$cell_db_history
  for v_$cell_db_history;
grant select on v_$cell_db_history to select_catalog_role;

create or replace view gv_$cell_open_alerts as
  select * from gv$cell_open_alerts;
create or replace public synonym gv$cell_open_alerts
  for gv_$cell_open_alerts;
grant select on gv_$cell_open_alerts to select_catalog_role;

create or replace view v_$cell_open_alerts as
  select * from v$cell_open_alerts;
create or replace public synonym v$cell_open_alerts
  for v_$cell_open_alerts;
grant select on v_$cell_open_alerts to select_catalog_role;

Rem
Rem QMON and persistent queue time manager fixed views
Rem

create or replace view gv_$qmon_coordinator_stats as
    select * from gv$qmon_coordinator_stats;
create or replace public synonym gv$qmon_coordinator_stats
    for gv_$qmon_coordinator_stats;
grant select on gv_$qmon_coordinator_stats to select_catalog_role;

create or replace view v_$qmon_coordinator_stats as
    select * from v$qmon_coordinator_stats;
create or replace public synonym v$qmon_coordinator_stats
    for v_$qmon_coordinator_stats;
grant select on v_$qmon_coordinator_stats to select_catalog_role;


create or replace view gv_$qmon_server_stats as
    select * from gv$qmon_server_stats;
create or replace public synonym gv$qmon_server_stats
    for gv_$qmon_server_stats;
grant select on gv_$qmon_server_stats to select_catalog_role;

create or replace view v_$qmon_server_stats as
    select * from v$qmon_server_stats;
create or replace public synonym v$qmon_server_stats
    for v_$qmon_server_stats;
grant select on v_$qmon_server_stats to select_catalog_role;


create or replace view gv_$qmon_tasks as
    select * from gv$qmon_tasks;
create or replace public synonym gv$qmon_tasks
    for gv_$qmon_tasks;
grant select on gv_$qmon_tasks to select_catalog_role;

create or replace view v_$qmon_tasks as
    select * from v$qmon_tasks;
create or replace public synonym v$qmon_tasks
    for v_$qmon_tasks;
grant select on v_$qmon_tasks to select_catalog_role;


create or replace view gv_$qmon_task_stats as
    select * from gv$qmon_task_stats;
create or replace public synonym gv$qmon_task_stats
    for gv_$qmon_task_stats;
grant select on gv_$qmon_task_stats to select_catalog_role;

create or replace view v_$qmon_task_stats as
    select * from v$qmon_task_stats;
create or replace public synonym v$qmon_task_stats
    for v_$qmon_task_stats;
grant select on v_$qmon_task_stats to select_catalog_role;


create or replace view gv_$persistent_qmn_cache as
    select * from gv$persistent_qmn_cache;
create or replace public synonym gv$persistent_qmn_cache
    for gv_$persistent_qmn_cache;
grant select on gv_$persistent_qmn_cache to select_catalog_role;

create or replace view v_$persistent_qmn_cache as
    select * from v$persistent_qmn_cache;
create or replace public synonym v$persistent_qmn_cache
    for v_$persistent_qmn_cache;
grant select on v_$persistent_qmn_cache to select_catalog_role;

create or replace view gv_$object_dml_frequencies as
    select * from gv$object_dml_frequencies;
create or replace public synonym gv$object_dml_frequencies
    for gv_$object_dml_frequencies;
grant select on gv_$object_dml_frequencies to select_catalog_role;

create or replace view v_$object_dml_frequencies as
    select * from v$object_dml_frequencies;
create or replace public synonym v$object_dml_frequencies
    for v_$object_dml_frequencies;
grant select on v_$object_dml_frequencies to select_catalog_role;

Rem
Rem LISTENER_NETWORK fixed views
Rem
create or replace view gv_$listener_network as
    select * from gv$listener_network;
create or replace public synonym gv$listener_network
    for gv_$listener_network;
grant select on gv_$listener_network to select_catalog_role;

create or replace view v_$listener_network as
    select * from v$listener_network;
create or replace public synonym v$listener_network
    for v_$listener_network;
grant select on v_$listener_network to select_catalog_role;


Rem
Rem SQLCOMMAND fixed views
Rem
create or replace view gv_$sqlcommand as
    select * from gv$sqlcommand;
create or replace public synonym gv$sqlcommand 
    for gv_$sqlcommand;
grant select on gv_$sqlcommand to select_catalog_role;

create or replace view v_$sqlcommand as
    select * from v$sqlcommand;
create or replace public synonym v$sqlcommand
    for v_$sqlcommand;
grant select on v_$sqlcommand to select_catalog_role;

Rem
Rem TOPLEVELCALL fixed views
Rem

create or replace view gv_$toplevelcall as
    select * from gv$toplevelcall;
create or replace public synonym gv$toplevelcall
    for gv_$toplevelcall;
grant select on gv_$toplevelcall to select_catalog_role;

create or replace view v_$toplevelcall as
    select * from v$toplevelcall;
create or replace public synonym v$toplevelcall
    for v_$toplevelcall;
grant select on v_$toplevelcall to select_catalog_role;

Rem
Rem Hang Manager fixed views
Rem

create or replace view v_$hang_info as
  select * from v$hang_info;
create or replace public synonym v$hang_info for v_$hang_info;
grant select on v_$hang_info to select_catalog_role;

create or replace view v_$hang_session_info as
  select * from v$hang_session_info;
create or replace public synonym v$hang_session_info for v_$hang_session_info;
grant select on v_$hang_session_info to select_catalog_role;

Rem
Rem Hang Manager hang statistics fixed views
Rem 

create or replace view v_$hang_statistics as
    select * from v$hang_statistics;
create or replace public synonym v$hang_statistics for v_$hang_statistics;
grant select on v_$hang_statistics to select_catalog_role;
    
create or replace view gv_$hang_statistics as
    select * from gv$hang_statistics;
create or replace public synonym gv$hang_statistics for gv_$hang_statistics;
grant select on gv_$hang_statistics to select_catalog_role;

Rem
Rem Fast space usage views.
Rem

create or replace view v_$segspace_usage as select * from v$segspace_usage;
create or replace public synonym v$segspace_usage for v_$segspace_usage;
grant select on v_$segspace_usage to SELECT_CATALOG_ROLE;

create or replace view gv_$segspace_usage as select * from gv$segspace_usage;
create or replace public synonym gv$segspace_usage for gv_$segspace_usage;
grant select on gv_$segspace_usage to SELECT_CATALOG_ROLE;

Rem
Rem bigfile tablespace stat
Rem

create or replace view v_$bts_stat as select * from v$bts_stat;
create or replace public synonym v$bts_stat for v_$bts_stat;
grant select on v_$bts_stat to select_catalog_role;

create or replace view gv_$bts_stat as select * from gv$bts_stat;
create or replace public synonym gv$bts_stat for gv_$bts_stat;
grant select on gv_$bts_stat to select_catalog_role;

Rem
Rem pluggable database views.
Rem
create or replace view v_$pdbs as
  select * from v$pdbs;
create or replace public synonym v$pdbs for v_$pdbs;
grant select on v_$pdbs to select_catalog_role;

create or replace view gv_$pdbs as
  select * from gv$pdbs;
create or replace public synonym gv$pdbs
  for gv_$pdbs;
grant select on gv_$pdbs to select_catalog_role;

create or replace view v_$containers as
  select * from v$containers;
create or replace public synonym v$containers for v_$containers;
grant select on v_$containers to select_catalog_role;

create or replace view gv_$containers as
  select * from gv$containers;
create or replace public synonym gv$containers
  for gv_$containers;
grant select on gv_$containers to select_catalog_role;

Rem
Rem Proxy Pluggable Database Views
Rem

create or replace view v_$proxy_pdb_targets as
  select * from v$proxy_pdb_targets;
create or replace public synonym v$proxy_pdb_targets for v_$proxy_pdb_targets;
grant select on v_$proxy_pdb_targets to select_catalog_role;

create or replace view gv_$proxy_pdb_targets as
  select * from gv$proxy_pdb_targets;
create or replace public synonym gv$proxy_pdb_targets
  for gv_$proxy_pdb_targets;
grant select on gv_$proxy_pdb_targets to select_catalog_role;

Rem
Rem pluggable database incarnation views.
Rem
create or replace view v_$pdb_incarnation as
  select * from v$pdb_incarnation;
create or replace public synonym v$pdb_incarnation for v_$pdb_incarnation;
grant select on v_$pdb_incarnation to select_catalog_role;

create or replace view gv_$pdb_incarnation as
  select * from gv$pdb_incarnation;
create or replace public synonym gv$pdb_incarnation for gv_$pdb_incarnation;
grant select on gv_$pdb_incarnation to select_catalog_role;

Rem
Rem Detected Deadlocks fixed views.
Rem
create or replace view v_$ges_deadlocks as
  select * from v$ges_deadlocks;
create or replace public synonym v$ges_deadlocks for v_$ges_deadlocks;
grant select on v_$ges_deadlocks to select_catalog_role;

create or replace view gv_$ges_deadlocks as
  select * from gv$ges_deadlocks;
create or replace public synonym gv$ges_deadlocks  for gv_$ges_deadlocks;
grant select on gv_$ges_deadlocks to select_catalog_role;

Rem
Rem Detected Deadlock Sessions fixed views.
Rem
create or replace view v_$ges_deadlock_sessions as
  select * from v$ges_deadlock_sessions;
create or replace public synonym v$ges_deadlock_sessions for v_$ges_deadlock_sessions;
grant select on v_$ges_deadlock_sessions to select_catalog_role;

create or replace view gv_$ges_deadlock_sessions as
  select * from gv$ges_deadlock_sessions;
create or replace public synonym gv$ges_deadlock_sessions  for gv_$ges_deadlock_sessions;
grant select on gv_$ges_deadlock_sessions to select_catalog_role;

Rem
Rem Fusion Security views
Rem
create or replace view v_$xs_session_roles as select * from v$xs_session_role;
create or replace public synonym v$xs_session_roles for v_$xs_session_roles;
create or replace public synonym v$xs_session_role for v$xs_session_roles;
grant read on v_$xs_session_roles to PUBLIC;

create or replace view gv_$xs_session_roles as
  select * from gv$xs_session_role;
create or replace public synonym gv$xs_session_roles for gv_$xs_session_roles;
create or replace public synonym gv$xs_session_role for gv_$xs_session_roles;
grant read on gv_$xs_session_roles to PUBLIC;

create or replace view v_$xs_session_ns_attributes as
  select * from v$xs_session_ns_attribute;
create or replace public synonym v$xs_session_ns_attributes 
  for v_$xs_session_ns_attributes;
create or replace public synonym v$xs_session_ns_attribute
  for v_$xs_session_ns_attributes;
grant read on v_$xs_session_ns_attributes to PUBLIC;

create or replace view gv_$xs_session_ns_attributes as
  select * from gv$xs_session_ns_attribute;
create or replace public synonym gv$xs_session_ns_attributes 
  for gv_$xs_session_ns_attributes;
create or replace public synonym gv$xs_session_ns_attribute
  for gv_$xs_session_ns_attributes;
grant read on gv_$xs_session_ns_attributes to PUBLIC;

create or replace view v_$xs_sessions as
  select * from v$xs_sessions;
create or replace public synonym v$xs_sessions
  for v_$xs_sessions;
grant select on v_$xs_sessions to select_catalog_role;

create or replace view gv_$xs_sessions as
  select * from gv$xs_sessions;
create or replace public synonym gv$xs_sessions
  for gv_$xs_sessions;
grant select on gv_$xs_sessions to select_catalog_role;

Rem
Rem Cache views (these views are deprecated)
Rem
create or replace view v_$ping as select * from v$ping;
create or replace public synonym v$ping for v_$ping;
grant select on v_$ping to select_catalog_role;

create or replace view gv_$ping as select * from gv$ping;
create or replace public synonym gv$ping for gv_$ping;
grant select on gv_$ping to select_catalog_role;

create or replace view v_$cache as select * from v$cache;
create or replace public synonym v$cache for v_$cache;
grant select on v_$cache to select_catalog_role;

create or replace view gv_$cache as select * from gv$cache;
create or replace public synonym gv$cache for gv_$cache;
grant select on gv_$cache to select_catalog_role;

create or replace view v_$false_ping as select * from v$false_ping;
create or replace public synonym v$false_ping for v_$false_ping;
grant select on v_$false_ping to select_catalog_role;

create or replace view gv_$false_ping as select * from gv$false_ping;
create or replace public synonym gv$false_ping for gv_$false_ping;
grant select on gv_$false_ping to select_catalog_role;

create or replace view v_$cache_transfer as select * from v$cache_transfer;
create or replace public synonym v$cache_transfer for v_$cache_transfer;
grant select on v_$cache_transfer to select_catalog_role;

create or replace view gv_$cache_transfer as select * from gv$cache_transfer;
create or replace public synonym gv$cache_transfer for gv_$cache_transfer;
grant select on gv_$cache_transfer to select_catalog_role;

create or replace view v_$cache_lock as select * from v$cache_lock;
create or replace public synonym v$cache_lock for v_$cache_lock;
grant select on v_$cache_lock to select_catalog_role;

create or replace view gv_$cache_lock as select * from gv$cache_lock;
create or replace public synonym gv$cache_lock for gv_$cache_lock;
grant select on gv_$cache_lock to select_catalog_role;

Rem
Rem Auditing Unified audit trail views.
Rem
create or replace view v_$unified_audit_trail as
  select * from v$unified_audit_trail;
create or replace public synonym v$unified_audit_trail for 
  v_$unified_audit_trail;
grant read on v_$unified_audit_trail to audit_admin;
grant read on v_$unified_audit_trail to audit_viewer;

create or replace view gv_$unified_audit_trail as
  select * from gv$unified_audit_trail;
create or replace public synonym gv$unified_audit_trail for 
  gv_$unified_audit_trail;
grant read on gv_$unified_audit_trail to audit_admin;
grant read on gv_$unified_audit_trail to audit_viewer;

Rem
Rem Unified Auditing audit record format views.
Rem
create or replace view v_$unified_audit_record_format as
  select * from v$unified_audit_record_format;
create or replace public synonym v$unified_audit_record_format for 
  v_$unified_audit_record_format;
grant read on v_$unified_audit_record_format to audit_admin;
grant read on v_$unified_audit_record_format to audit_viewer;


Rem
Rem DG_BROKER_CONFIG views
Rem

create or replace view v_$dg_broker_config as
  select * from v$dg_broker_config;
create or replace public synonym v$dg_broker_config for v_$dg_broker_config;
grant select on v_$dg_broker_config to select_catalog_role;

create or replace view gv_$dg_broker_config as
  select * from gv$dg_broker_config;
create or replace public synonym gv$dg_broker_config for gv_$dg_broker_config;
grant select on gv_$dg_broker_config to select_catalog_role;

Rem
Rem EBR views
Rem
create or replace view v_$editionable_types as
  select * from v$editionable_types;
create or replace public synonym v$editionable_types for v_$editionable_types;
grant read on v_$editionable_types to public;

create or replace view gv_$editionable_types as
  select * from gv$editionable_types;
create or replace public synonym gv$editionable_types for
  gv_$editionable_types;
grant read on gv_$editionable_types to public;

Rem
Rem Replay Context views
Rem
create or replace view v_$replay_context as
  select * from v$replay_context;
create or replace public synonym v$replay_context for v_$replay_context;
grant read on v_$replay_context to public;

create or replace view gv_$replay_context as
  select * from gv$replay_context;
create or replace public synonym gv$replay_context for gv_$replay_context;
grant read on gv_$replay_context to public;

create or replace view v_$replay_context_sysdate as
  select * from v$replay_context_sysdate;
create or replace public synonym v$replay_context_sysdate for 
  v_$replay_context_sysdate;
grant read on v_$replay_context_sysdate to public;

create or replace view gv_$replay_context_sysdate as
  select * from gv$replay_context_sysdate;
create or replace public synonym gv$replay_context_sysdate for 
  gv_$replay_context_sysdate;
grant read on gv_$replay_context_sysdate to public;

create or replace view v_$replay_context_systimestamp as
  select * from v$replay_context_systimestamp;
create or replace public synonym v$replay_context_systimestamp for 
  v_$replay_context_systimestamp;
grant read on v_$replay_context_systimestamp to public;

create or replace view gv_$replaycontext_systimestamp as
  select * from gv$replay_context_systimestamp;
create or replace public synonym gv$replay_context_systimestamp for 
  gv_$replaycontext_systimestamp;
grant read on gv_$replaycontext_systimestamp to public;

create or replace view v_$replay_context_sysguid as
  select * from v$replay_context_sysguid;
create or replace public synonym v$replay_context_sysguid for 
  v_$replay_context_sysguid;
grant read on v_$replay_context_sysguid to public;

create or replace view gv_$replay_context_sysguid as
  select * from gv$replay_context_sysguid;
create or replace public synonym gv$replay_context_sysguid for 
  gv_$replay_context_sysguid;
grant read on gv_$replay_context_sysguid to public;

create or replace view v_$replay_context_sequence as
  select * from v$replay_context_sequence;
create or replace public synonym v$replay_context_sequence for 
  v_$replay_context_sequence;
grant read on v_$replay_context_sequence to public;

create or replace view gv_$replay_context_sequence as
  select * from gv$replay_context_sequence;
create or replace public synonym gv$replay_context_sequence for 
  gv_$replay_context_sequence;
grant read on gv_$replay_context_sequence to public;

create or replace view v_$replay_context_lob as
  select * from v$replay_context_lob;
create or replace public synonym v$replay_context_lob for 
  v_$replay_context_lob;
grant read on v_$replay_context_lob to public;

create or replace view gv_$replay_context_lob as
  select * from gv$replay_context_lob;
create or replace public synonym gv$replay_context_lob for 
  gv_$replay_context_lob;
grant read on gv_$replay_context_lob to public;

create or replace view v_$ofsmount as
  select * from v$ofsmount;
create or replace public synonym v$ofsmount for v_$ofsmount;
grant select on v_$ofsmount to select_catalog_role;

create or replace view gv_$ofsmount as
  select * from gv$ofsmount;
create or replace public synonym gv$ofsmount for gv_$ofsmount;
grant select on gv_$ofsmount to select_catalog_role;

create or replace view v_$ofs_stats as
  select * from v$ofs_stats;
create or replace public synonym v$ofs_stats for v_$ofs_stats;
grant select on v_$ofs_stats to select_catalog_role;

create or replace view gv_$ofs_stats as
  select * from gv$ofs_stats;
create or replace public synonym gv$ofs_stats for gv_$ofs_stats;
grant select on gv_$ofs_stats to select_catalog_role;

create or replace view v_$io_outlier as
  select * from v$io_outlier;
create or replace public synonym v$io_outlier for v_$io_outlier;
grant select on v_$io_outlier to select_catalog_role;

create or replace view gv_$io_outlier as
  select * from gv$io_outlier;
create or replace public synonym gv$io_outlier for gv_$io_outlier;
grant select on gv_$io_outlier to select_catalog_role;

create or replace view v_$lgwrio_outlier as
  select * from v$lgwrio_outlier;
create or replace public synonym v$lgwrio_outlier for v_$lgwrio_outlier;
grant select on v_$lgwrio_outlier to select_catalog_role;

create or replace view gv_$lgwrio_outlier as
  select * from gv$lgwrio_outlier;
create or replace public synonym gv$lgwrio_outlier for gv_$lgwrio_outlier;
grant select on gv_$lgwrio_outlier to select_catalog_role;

create or replace view v_$kernel_io_outlier as
  select * from v$kernel_io_outlier;
create or replace public synonym v$kernel_io_outlier for v_$kernel_io_outlier;
grant select on v_$kernel_io_outlier to select_catalog_role;

create or replace view gv_$kernel_io_outlier as
  select * from gv$kernel_io_outlier;
create or replace public synonym gv$kernel_io_outlier for gv_$kernel_io_outlier;
grant select on gv_$kernel_io_outlier to select_catalog_role;

create or replace view v_$patches as
  select * from v$patches;
create or replace public synonym v$patches for v_$patches;
grant select on v_$patches to select_catalog_role;

create or replace view gv_$patches as
  select * from gv$patches;
create or replace public synonym gv$patches for gv_$patches;
grant select on gv_$patches to select_catalog_role;


create or replace view v_$kxftask as select * from x$kxftask;
create or replace public synonym x$kxftask for v_$kxftask;
grant read on v_$kxftask to public;


Rem
Rem nologging standby views
Rem
create or replace view v_$nonlogged_block as
  select * from v$nonlogged_block;
create or replace public synonym v$nonlogged_block for v_$nonlogged_block;
grant select on v_$nonlogged_block to select_catalog_role;

create or replace view gv_$nonlogged_block as
  select * from gv$nonlogged_block;
create or replace public synonym gv$nonlogged_block for
  gv_$nonlogged_block;
grant select on gv_$nonlogged_block to select_catalog_role;

create or replace view v_$copy_nonlogged as
  select * from v$copy_nonlogged;
create or replace public synonym v$copy_nonlogged for v_$copy_nonlogged;
grant select on v_$copy_nonlogged to select_catalog_role;

create or replace view gv_$copy_nonlogged as
  select * from gv$copy_nonlogged;
create or replace public synonym gv$copy_nonlogged for
  gv_$copy_nonlogged;
grant select on gv_$copy_nonlogged to select_catalog_role;

create or replace view v_$backup_nonlogged as
  select * from v$backup_nonlogged;
create or replace public synonym v$backup_nonlogged for v_$backup_nonlogged;
grant select on v_$backup_nonlogged to select_catalog_role;

create or replace view gv_$backup_nonlogged as
  select * from gv$backup_nonlogged;
create or replace public synonym gv$backup_nonlogged for
  gv_$backup_nonlogged;
grant select on gv_$backup_nonlogged to select_catalog_role;


Rem
Rem v$sql_reoptimization_hints
Rem

create or replace view v_$sql_reoptimization_hints as
  select * from v$sql_reoptimization_hints;
create or replace public synonym v$sql_reoptimization_hints 
  for v_$sql_reoptimization_hints;
grant select on v_$sql_reoptimization_hints to select_catalog_role;

create or replace view gv_$sql_reoptimization_hints as
  select * from gv$sql_reoptimization_hints;
create or replace public synonym gv$sql_reoptimization_hints 
  for gv_$sql_reoptimization_hints;
grant select on gv_$sql_reoptimization_hints to select_catalog_role;

Rem
Rem OPTIMIZER_PROCESSING_RATE views
Rem

create or replace view v_$optimizer_processing_rate as
  select * from v$optimizer_processing_rate;
create or replace public synonym v$optimizer_processing_rate for v_$optimizer_processing_rate;
grant select on v_$optimizer_processing_rate to select_catalog_role;

create or replace view gv_$optimizer_processing_rate as
  select * from gv$optimizer_processing_rate;
create or replace public synonym gv$optimizer_processing_rate for gv_$optimizer_processing_rate;
grant select on gv_$optimizer_processing_rate to select_catalog_role;

Rem
Rem HEAT MAP views - v_$heat_map_segment and gv_$heat_map_segment
Rem

create or replace view v_$heat_map_segment as
  select * from v$heat_map_segment;
create or replace public synonym v$heat_map_segment for v_$heat_map_segment;
grant select on v_$heat_map_segment to select_catalog_role;

create or replace view gv_$heat_map_segment as
  select * from gv$heat_map_segment;
create or replace public synonym gv$heat_map_segment for gv_$heat_map_segment;
grant select on gv_$heat_map_segment to select_catalog_role;

Rem
Rem [G]V$SYS_REPORT_STATS fixed views
Rem

create or replace view v_$sys_report_stats as
  select * from v$sys_report_stats;
create or replace public synonym v$sys_report_stats for v_$sys_report_stats;
grant select on v_$sys_report_stats to select_catalog_role;

create or replace view gv_$sys_report_stats as
  select * from gv$sys_report_stats;
create or replace public synonym gv$sys_report_stats for gv_$sys_report_stats;
grant select on gv_$sys_report_stats to select_catalog_role;


Rem
Rem [G]V$SYS_REPORT_REQUESTS fixed views
Rem

create or replace view v_$sys_report_requests as
  select * from v$sys_report_requests;
create or replace public synonym v$sys_report_requests for v_$sys_report_requests;
grant select on v_$sys_report_requests to select_catalog_role;

create or replace view gv_$sys_report_requests as
  select * from gv$sys_report_requests;
create or replace public synonym gv$sys_report_requests for gv_$sys_report_requests;
grant select on gv_$sys_report_requests to select_catalog_role;

Rem
Rem [G]V$CLONEDFILE fixed views
Rem
create or replace view v_$clonedfile as select * from v$clonedfile;
create or replace public synonym v$clonedfile for v_$clonedfile;
grant select on v_$clonedfile to select_catalog_role;

create or replace view gv_$clonedfile as
  select * from gv$clonedfile;
create or replace public synonym gv$clonedfile for gv_$clonedfile;
grant select on gv_$clonedfile to select_catalog_role;

Rem
Rem [G]V$AQ_MSGBM fixed views
Rem
create or replace view v_$aq_msgbm as
    select * from v$aq_msgbm;
create or replace public synonym v$aq_msgbm
    for v_$aq_msgbm;
grant select on v_$aq_msgbm to select_catalog_role;

create or replace view gv_$aq_msgbm as
    select * from gv$aq_msgbm;
create or replace public synonym gv$aq_msgbm
    for gv_$aq_msgbm;
grant select on gv_$aq_msgbm to select_catalog_role;

Rem
Rem [G]V$CON_SYS_TIME_MODEL fixed views
Rem
create or replace view v_$con_sys_time_model as 
  select * from v$con_sys_time_model;
create or replace public synonym v$con_sys_time_model 
  for v_$con_sys_time_model;
grant select on v_$con_sys_time_model to select_catalog_role;

create or replace view gv_$con_sys_time_model as 
  select * from gv$con_sys_time_model;
create or replace public synonym gv$con_sys_time_model 
  for gv_$con_sys_time_model;
grant select on gv_$con_sys_time_model to select_catalog_role;

Rem
Rem [G]V$AQ_NONDUR_REGISTRATIONS fixed views
Rem
create or replace view v_$aq_nondur_registrations as
    select * from v$aq_nondur_registrations;
create or replace public synonym v$aq_nondur_registrations
    for v_$aq_nondur_registrations;
grant select on v_$aq_nondur_registrations to select_catalog_role;

create or replace view gv_$aq_nondur_registrations as
    select * from gv$aq_nondur_registrations;
create or replace public synonym gv$aq_nondur_registrations
    for gv_$aq_nondur_registrations;
grant select on gv_$aq_nondur_registrations to select_catalog_role;

Rem
Rem [G]V$MESSAGE_CACHE fixed views
Rem
create or replace view v_$aq_message_cache as
    select * from v$aq_message_cache;
create or replace public synonym v$aq_message_cache
    for v_$aq_message_cache;
grant select on v_$aq_message_cache to select_catalog_role;

create or replace view gv_$aq_message_cache as
    select * from gv$aq_message_cache;
create or replace public synonym gv$aq_message_cache
    for gv_$aq_message_cache;
grant select on gv_$aq_message_cache to select_catalog_role;

Rem
Rem [G]V$CHANNEL_WAITS fixed views
Rem
create or replace view v_$channel_waits as
    select * from v$channel_waits;
create or replace public synonym v$channel_waits
    for v_$channel_waits;
grant select on v_$channel_waits to select_catalog_role;

create or replace view gv_$channel_waits as
    select * from gv$channel_waits;
create or replace public synonym gv$channel_waits
    for gv_$channel_waits;
grant select on gv_$channel_waits to select_catalog_role;

Rem
Rem [G]V$TSDP_SUPPORTED_FEATURE fixed views
Rem
create or replace view v_$tsdp_supported_feature as
    select * from v$tsdp_supported_feature;
create or replace public synonym v$tsdp_supported_feature
    for v_$tsdp_supported_feature;
grant select on v_$tsdp_supported_feature to select_catalog_role;

create or replace view gv_$tsdp_supported_feature as
    select * from gv$tsdp_supported_feature;
create or replace public synonym gv$tsdp_supported_feature
    for gv_$tsdp_supported_feature;
grant select on gv_$tsdp_supported_feature to select_catalog_role;

Rem
Rem [G]V$DEAD_CLEANUP fixed views
Rem
create or replace view v_$dead_cleanup as
    select * from v$dead_cleanup;
create or replace public synonym v$dead_cleanup
    for v_$dead_cleanup;
grant select on v_$dead_cleanup to select_catalog_role;

create or replace view gv_$dead_cleanup as
    select * from gv$dead_cleanup;
create or replace public synonym gv$dead_cleanup
    for gv_$dead_cleanup;
grant select on gv_$dead_cleanup to select_catalog_role;

Rem
Rem [G]V$SESSIONS_COUNT fixed views
Rem
create or replace view v_$sessions_count as
    select * from v$sessions_count;
create or replace public synonym v$sessions_count
    for v_$sessions_count;
grant select on v_$sessions_count to select_catalog_role;

create or replace view gv_$sessions_count as
    select * from gv$sessions_count;
create or replace public synonym gv$sessions_count
    for gv_$sessions_count;
grant select on gv_$sessions_count to select_catalog_role;

Rem
Rem GV$AUTO_BMR_STATISTICS fixed views
Rem
create or replace view gv_$auto_bmr_statistics as 
    select * from gv$auto_bmr_statistics;
create or replace public synonym gv$auto_bmr_statistics 
    for gv_$auto_bmr_statistics;
grant select on gv_$auto_bmr_statistics to select_catalog_role;

Rem
Rem [G]V$IM_SEGMENTS_DETAIL fixed views
Rem
create or replace view v_$im_segments_detail as
    select * from v$im_segments_detail;
create or replace public synonym v$im_segments_detail
    for v_$im_segments_detail;
grant select on v_$im_segments_detail to select_catalog_role;

create or replace view gv_$im_segments_detail as
    select * from gv$im_segments_detail;
create or replace public synonym gv$im_segments_detail
    for gv_$im_segments_detail;
grant select on gv_$im_segments_detail to select_catalog_role;

Rem
Rem [G]V$IM[_USER]_SEGMENTS fixed views
Rem
create or replace view v_$im_segments as
    select * from v$im_segments;
create or replace public synonym v$im_segments
    for v_$im_segments;
grant select on v_$im_segments to select_catalog_role;

create or replace view gv_$im_segments as
    select * from gv$im_segments;
create or replace public synonym gv$im_segments
    for gv_$im_segments;
grant select on gv_$im_segments to select_catalog_role;

create or replace view v_$im_user_segments as
    select * from v$im_user_segments;
create or replace public synonym v$im_user_segments
    for v_$im_user_segments;
grant select on v_$im_user_segments to select_catalog_role;

create or replace view gv_$im_user_segments as
    select * from gv$im_user_segments;
create or replace public synonym gv$im_user_segments
    for gv_$im_user_segments;
grant select on gv_$im_user_segments to select_catalog_role;

Rem
Rem [G]V$INMEMORY_AREA fixed views
Rem
create or replace view v_$inmemory_area as
    select * from v$inmemory_area;
create or replace public synonym v$inmemory_area
    for v_$inmemory_area;
grant select on v_$inmemory_area to select_catalog_role;

create or replace view gv_$inmemory_area as
    select * from gv$inmemory_area;
create or replace public synonym gv$inmemory_area
    for gv_$inmemory_area;
grant select on gv_$inmemory_area to select_catalog_role;

Rem
Rem [G]V$IM_TBS_EXT_MAP fixed views
Rem
create or replace view v_$im_tbs_ext_map as
    select * from v$im_tbs_ext_map;
create or replace public synonym v$im_tbs_ext_map
    for v_$im_tbs_ext_map;
grant select on v_$im_tbs_ext_map to select_catalog_role;

create or replace view gv_$im_tbs_ext_map as
    select * from gv$im_tbs_ext_map;
create or replace public synonym gv$im_tbs_ext_map
    for gv_$im_tbs_ext_map;
grant select on gv_$im_tbs_ext_map to select_catalog_role;

Rem
Rem [G]V$IM_SEG_EXT_MAP fixed views
Rem
create or replace view v_$im_seg_ext_map as
    select * from v$im_seg_ext_map;
create or replace public synonym v$im_seg_ext_map
    for v_$im_seg_ext_map;
grant select on v_$im_seg_ext_map to select_catalog_role;

create or replace view gv_$im_seg_ext_map as
    select * from gv$im_seg_ext_map;
create or replace public synonym gv$im_seg_ext_map
    for gv_$im_seg_ext_map;
grant select on gv_$im_seg_ext_map to select_catalog_role;

Rem
Rem [G]V$IM_HEADER fixed views
Rem
create or replace view v_$im_header as
    select * from v$im_header;
create or replace public synonym v$im_header
    for v_$im_header;
grant select on v_$im_header to select_catalog_role;

create or replace view gv_$im_header as
    select * from gv$im_header;
create or replace public synonym gv$im_header
    for gv_$im_header;
grant select on gv_$im_header to select_catalog_role;

Rem
Rem [G]V$IM_DELTA_HEADER fixed views
Rem
create or replace view v_$im_delta_header as
    select * from v$im_delta_header;
create or replace public synonym v$im_delta_header
    for v_$im_delta_header;
grant select on v_$im_delta_header to select_catalog_role;

create or replace view gv_$im_delta_header as
    select * from gv$im_delta_header;
create or replace public synonym gv$im_delta_header
    for gv_$im_delta_header;
grant select on gv_$im_delta_header to select_catalog_role;

Rem
Rem [G]V$IM_COL_CU fixed views
Rem
create or replace view v_$im_col_cu as
    select * from v$im_col_cu;
create or replace public synonym v$im_col_cu
    for v_$im_col_cu;
grant select on v_$im_col_cu to select_catalog_role;

create or replace view gv_$im_col_cu as
    select * from gv$im_col_cu;
create or replace public synonym gv$im_col_cu
    for gv_$im_col_cu;
grant select on gv_$im_col_cu to select_catalog_role;

Rem
Rem [G]V$IM_SMU_HEAD fixed views
Rem
create or replace view v_$im_smu_head as
    select * from v$im_smu_head ;
create or replace public synonym v$im_smu_head
    for v_$im_smu_head;
grant select on v_$im_smu_head to select_catalog_role;

create or replace view gv_$im_smu_head as
    select * from gv$im_smu_head;
create or replace public synonym gv$im_smu_head
    for gv_$im_smu_head;
grant select on gv_$im_smu_head to select_catalog_role;

Rem
Rem [G]V$IM_SMU_DELTA fixed views
Rem
create or replace view v_$im_smu_delta as
    select * from v$im_smu_delta ;
create or replace public synonym v$im_smu_delta
    for v_$im_smu_delta;
grant select on v_$im_smu_delta to select_catalog_role;

create or replace view gv_$im_smu_delta as
    select * from gv$im_smu_delta;
create or replace public synonym gv$im_smu_delta
    for gv_$im_smu_delta;
grant select on gv_$im_smu_delta to select_catalog_role;

Rem
Rem [G]V$IM_SMU_CHUNK fixed views
Rem
create or replace view v_$im_smu_chunk as
    select * from v$IM_smu_chunk;
create or replace public synonym v$im_smu_chunk
    for v_$im_smu_chunk;
grant select on v_$im_smu_chunk to select_catalog_role;

create or replace view gv_$im_smu_chunk as
    select * from gv$im_smu_chunk;
create or replace public synonym gv$im_smu_chunk
    for gv_$im_smu_chunk;
grant select on gv_$im_smu_chunk to select_catalog_role;


Rem
Rem [G]V$IM_COLUMN_LEVEL fixed views
Rem
create or replace view v_$im_column_level as
    select * from v$im_column_level;
create or replace public synonym v$im_column_level
    for v_$im_column_level;
grant select on v_$im_column_level to select_catalog_role;

create or replace view gv_$im_column_level as
    select * from gv$im_column_level;
create or replace public synonym gv$im_column_level
    for gv_$im_column_level;
grant select on gv_$im_column_level to select_catalog_role;


Rem
Rem [G]V$INMEMORY_FASTSTART_AREA fixed views
Rem
create or replace view v_$inmemory_faststart_area as
    select * from v$inmemory_faststart_area;
create or replace public synonym v$inmemory_faststart_area
    for v_$inmemory_faststart_area;
grant select on v_$inmemory_faststart_area to select_catalog_role;

create or replace view gv_$inmemory_faststart_area as
    select * from gv$inmemory_faststart_area;
create or replace public synonym gv$inmemory_faststart_area
    for gv_$inmemory_faststart_area;
grant select on gv_$inmemory_faststart_area to select_catalog_role;

Rem
Rem [G]V$IM_GLOBALDICT fixed views
Rem
create or replace view v_$im_globaldict as
    select * from v$im_globaldict;
create or replace public synonym v$im_globaldict
    for v_$im_globaldict;
grant select on v_$im_globaldict to select_catalog_role;

create or replace view gv_$im_globaldict as
    select * from gv$im_globaldict;
create or replace public synonym gv$im_globaldict
    for gv_$im_globaldict;
grant select on gv_$im_globaldict to select_catalog_role;

Rem
Rem [G]V$IM_GLOBALDICT_VERSION fixed views
Rem
create or replace view v_$im_globaldict_version as
    select * from v$im_globaldict_version;
create or replace public synonym v$im_globaldict_version
    for v_$im_globaldict_version;
grant select on v_$im_globaldict_version to select_catalog_role;

create or replace view gv_$im_globaldict_version as
    select * from gv$im_globaldict_version;
create or replace public synonym gv$im_globaldict_version
    for gv_$im_globaldict_version;
grant select on gv_$im_globaldict_version to select_catalog_role;

Rem
Rem [G]V$IM_GLOBALDICT_SORTORDER fixed views
Rem
create or replace view v_$im_globaldict_sortorder as
    select * from v$im_globaldict_sortorder;
create or replace public synonym v$im_globaldict_sortorder
    for v_$im_globaldict_sortorder;
grant select on v_$im_globaldict_sortorder to select_catalog_role;

create or replace view gv_$im_globaldict_sortorder as
    select * from gv$im_globaldict_sortorder;
create or replace public synonym gv$im_globaldict_sortorder
    for gv_$im_globaldict_sortorder;
grant select on gv_$im_globaldict_sortorder to select_catalog_role;

Rem
Rem [G]V$IM_GLOBALDICT_PIECEMAP fixed views
Rem
create or replace view v_$im_globaldict_piecemap as
    select * from v$im_globaldict_piecemap;
create or replace public synonym v$im_globaldict_piecemap
    for v_$im_globaldict_piecemap;
grant select on v_$im_globaldict_piecemap to select_catalog_role;

create or replace view gv_$im_globaldict_piecemap as
    select * from gv$im_globaldict_piecemap;
create or replace public synonym gv$im_globaldict_piecemap
    for gv_$im_globaldict_piecemap;
grant select on gv_$im_globaldict_piecemap to select_catalog_role;

Rem
Rem [G]V$IMEU_HEADER fixed views
Rem
create or replace view v_$imeu_header as
    select * from v$imeu_header;
create or replace public synonym v$imeu_header
    for v_$imeu_header;
grant select on v_$imeu_header to select_catalog_role;

create or replace view gv_$imeu_header as
    select * from gv$imeu_header;
create or replace public synonym gv$imeu_header
    for gv_$imeu_header;
grant select on gv_$imeu_header to select_catalog_role;

Rem
Rem [G]V$IM_IMECOL_CU fixed views
Rem
create or replace view v_$im_imecol_cu as
    select * from v$im_imecol_cu;
create or replace public synonym v$im_imecol_cu
    for v_$im_imecol_cu;
grant select on v_$im_imecol_cu to select_catalog_role;

create or replace view gv_$im_imecol_cu as
    select * from gv$im_imecol_cu;
create or replace public synonym gv$im_imecol_cu
    for gv_$im_imecol_cu;
grant select on gv_$im_imecol_cu to select_catalog_role;

Rem
Rem [G]V$INMEMORY_XMEM_AREA fixed views
Rem
create or replace view v_$inmemory_xmem_area as
    select * from v$inmemory_xmem_area;
create or replace public synonym v$inmemory_xmem_area
    for v_$inmemory_xmem_area;
grant select on v_$inmemory_xmem_area to select_catalog_role;

create or replace view gv_$inmemory_xmem_area as
    select * from gv$inmemory_xmem_area;
create or replace public synonym gv$inmemory_xmem_area
    for gv_$inmemory_xmem_area;
grant select on gv_$inmemory_xmem_area to select_catalog_role;

Rem
Rem [G]V$FS_OBSERVER_HISTOGRAM fixed views
Rem
create or replace view gv_$fs_observer_histogram as
    select * from gv$fs_observer_histogram;
create or replace public synonym gv$fs_observer_histogram
    for gv_$fs_observer_histogram;
grant select on gv_$fs_observer_histogram to select_catalog_role;

create or replace view v_$fs_observer_histogram as
    select * from v$fs_observer_histogram;
create or replace public synonym v$fs_observer_histogram
    for v_$fs_observer_histogram;
grant select on v_$fs_observer_histogram to select_catalog_role;

Rem
Rem [G]V$KEY_VECTOR fixed views
Rem
create or replace view v_$key_vector as
    select * from v$key_vector;
create or replace public synonym v$key_vector
    for v_$key_vector;
grant select on v_$key_vector to select_catalog_role;

create or replace view gv_$key_vector as
    select * from gv$key_vector;
create or replace public synonym gv$key_vector
    for gv_$key_vector;
grant select on gv_$key_vector to select_catalog_role;

Rem
Rem [G]V$RECOVERY_SLAVE fixed views
Rem
create or replace view v_$recovery_slave as
    select * from v$recovery_slave;
create or replace public synonym v$recovery_slave
    for v_$recovery_slave;
grant select on v_$recovery_slave to select_catalog_role;

create or replace view gv_$recovery_slave as
    select * from gv$recovery_slave;
create or replace public synonym gv$recovery_slave
    for gv_$recovery_slave;
grant select on gv_$recovery_slave to select_catalog_role;  

Rem
Rem [G]V$EMX_USAGE_STATS fixed views
Rem
create or replace view gv_$emx_usage_stats
  as select * from gv$emx_usage_stats;
create or replace public synonym gv$emx_usage_stats
  for gv_$emx_usage_stats;
grant select on gv_$emx_usage_stats to select_catalog_role;

create or replace view v_$emx_usage_stats 
  as select * from v$emx_usage_stats;
create or replace public synonym v$emx_usage_stats 
 for v_$emx_usage_stats;
grant select on v_$emx_usage_stats to select_catalog_role;

Rem
Rem [G]V$PROCESS_PRIORITY_DATA
Rem

create or replace view gv_$process_priority_data
  as select * from gv$process_priority_data;
create or replace public synonym gv$process_priority_data
  for gv_$process_priority_data;
grant select on gv_$process_priority_data to select_catalog_role;

create or replace view v_$process_priority_data
  as select * from v$process_priority_data;
create or replace public synonym v$process_priority_data
  for v_$process_priority_data;
grant select on v_$process_priority_data to select_catalog_role;

Rem
Rem [G]V$QPX_INVENTORY 
Rem

create or replace view gv_$qpx_inventory
 as select * from gv$qpx_inventory;

create or replace public synonym gv$qpx_inventory
   for gv_$qpx_inventory;

create or replace view v_$qpx_inventory
 as select * from  v$qpx_inventory;
create or replace public synonym v$qpx_inventory
   for v_$qpx_inventory;

Rem
Rem [G]V$DATAGUARD_PROCESS
Rem
create or replace view gv_$dataguard_process
 as select * from gv$dataguard_process;
create or replace public synonym gv$dataguard_process
   for gv_$dataguard_process;
grant select on gv_$dataguard_process to select_catalog_role;

create or replace view v_$dataguard_process
 as select * from v$dataguard_process;
create or replace public synonym v$dataguard_process
   for v_$dataguard_process;
grant select on v_$dataguard_process to select_catalog_role;

Rem
Rem [G]V$ONLINE_REDEF
Rem
create or replace view v_$online_redef as
    select * from v$online_redef;
create or replace public synonym v$online_redef
    for v_$online_redef;
grant select on v_$online_redef to select_catalog_role;

create or replace view gv_$online_redef as
    select * from gv$online_redef;
create or replace public synonym gv$online_redef
    for gv_$online_redef;
grant select on gv_$online_redef to select_catalog_role;

Rem
Rem [G]V$CLEANUP_PROCESS fixed views
Rem
create or replace view v_$cleanup_process as
    select * from v$cleanup_process;
create or replace public synonym v$cleanup_process
    for v_$cleanup_process;
grant select on v_$cleanup_process to select_catalog_role;

create or replace view gv_$cleanup_process as
    select * from gv$cleanup_process;
create or replace public synonym gv$cleanup_process
    for gv_$cleanup_process;
grant select on gv_$cleanup_process to select_catalog_role;

Rem
Rem [G]V$ZONEMAP_USAGE_STATS fixed views/synonyms.
Rem

create or replace view gv_$zonemap_usage_stats as
    select * from gv$zonemap_usage_stats;
create or replace public synonym gv$zonemap_usage_stats
    for gv_$zonemap_usage_stats;
grant select on gv_$zonemap_usage_stats to select_catalog_role;

create or replace view v_$zonemap_usage_stats as
    select * from v$zonemap_usage_stats;
create or replace public synonym v$zonemap_usage_stats
    for v_$zonemap_usage_stats;
grant select on v_$zonemap_usage_stats to select_catalog_role;

Rem
Rem [G]V$CODE_CLAUSE
Rem

create or replace view gv_$code_clause as
    select * from gv$code_clause;
create or replace public synonym gv$code_clause
    for gv_$code_clause;

create or replace view v_$code_clause as
    select * from v$code_clause;
create or replace public synonym v$code_clause
    for v_$code_clause;

Rem
Rem [G]V$GCR_METRICS fixed views/synonyms.
Rem

create or replace view gv_$gcr_metrics as
    select * from gv$gcr_metrics;
create or replace public synonym gv$gcr_metrics
    for gv_$gcr_metrics;
grant select on gv_$gcr_metrics to select_catalog_role;

create or replace view v_$gcr_metrics as
    select * from v$gcr_metrics;
create or replace public synonym v$gcr_metrics
    for v_$gcr_metrics;
grant select on v_$gcr_metrics to select_catalog_role;

Rem
Rem [G]V$GCR_ACTIONS fixed views/synonyms.
Rem

create or replace view gv_$gcr_actions as
    select * from gv$gcr_actions;
create or replace public synonym gv$gcr_actions
    for gv_$gcr_actions;
grant select on gv_$gcr_actions to select_catalog_role;

create or replace view v_$gcr_actions as
    select * from v$gcr_actions;
create or replace public synonym v$gcr_actions
    for v_$gcr_actions;
grant select on v_$gcr_actions to select_catalog_role;

Rem
Rem [G]V$GCR_STATUS fixed views/synonyms.
Rem

create or replace view gv_$gcr_status as
    select * from gv$gcr_status;
create or replace public synonym gv$gcr_status
    for gv_$gcr_status;
grant select on gv_$gcr_status to select_catalog_role;

create or replace view v_$gcr_status as
    select * from v$gcr_status;
create or replace public synonym v$gcr_status
    for v_$gcr_status;
grant select on v_$gcr_status to select_catalog_role;

Rem
Rem [G]V$GCR_LOG fixed views/synonyms.
Rem

create or replace view gv_$gcr_log as
    select * from gv$gcr_log;
create or replace public synonym gv$gcr_log
    for gv_$gcr_log;
grant select on gv_$gcr_log to select_catalog_role;

create or replace view v_$gcr_log as
    select * from v$gcr_log;
create or replace public synonym v$gcr_log
    for v_$gcr_log;
grant select on v_$gcr_log to select_catalog_role;

Rem
Rem V$STATS_ADVISOR_* fixed views
Rem
create or replace view v_$stats_advisor_rules as
  select * from v$stats_advisor_rules;
create or replace public synonym v$stats_advisor_rules
  for v_$stats_advisor_rules;
grant select on v_$stats_advisor_rules to select_catalog_role;

create or replace view v_$stats_advisor_findings as
  select * from v$stats_advisor_findings;
create or replace public synonym v$stats_advisor_findings
  for v_$stats_advisor_findings;
grant select on v_$stats_advisor_findings to select_catalog_role;

create or replace view v_$stats_advisor_recs as
  select * from v$stats_advisor_recs;
create or replace public synonym v$stats_advisor_recs
  for v_$stats_advisor_recs;
grant select on v_$stats_advisor_recs to select_catalog_role;

create or replace view v_$stats_advisor_rationales as
  select * from v$stats_advisor_rationales;
create or replace public synonym v$stats_advisor_rationales
  for v_$stats_advisor_rationales;
grant select on v_$stats_advisor_rationales to select_catalog_role;

create or replace view v_$stats_advisor_actions as
  select * from v$stats_advisor_actions;
create or replace public synonym v$stats_advisor_actions
  for v_$stats_advisor_actions;
grant select on v_$stats_advisor_actions to select_catalog_role;

Rem
Rem [G]V$PROCESS_POOL fixed views
Rem
create or replace view v_$process_pool as
    select * from v$process_pool;
create or replace public synonym v$process_pool
    for v_$process_pool;
grant select on v_$process_pool to select_catalog_role;

create or replace view gv_$process_pool as
    select * from gv$process_pool;
create or replace public synonym gv$process_pool
    for gv_$process_pool;
grant select on gv_$process_pool to select_catalog_role;

CREATE or replace VIEW gv_$asm_filegroup as
  SELECT * FROM gv$asm_filegroup;
CREATE or replace PUBLIC synonym gv$asm_filegroup FOR gv_$asm_filegroup;
GRANT SELECT ON gv_$asm_filegroup TO select_catalog_role;

CREATE or replace VIEW v_$asm_filegroup as
  SELECT * FROM v$asm_filegroup;
CREATE or replace PUBLIC synonym v$asm_filegroup FOR v_$asm_filegroup;
GRANT SELECT ON v_$asm_filegroup TO select_catalog_role;

CREATE or replace VIEW gv_$asm_filegroup_property as
  SELECT * FROM gv$asm_filegroup_property;
CREATE or replace PUBLIC synonym gv$asm_filegroup_property
  FOR gv_$asm_filegroup_property;
GRANT SELECT ON gv_$asm_filegroup_property TO select_catalog_role;

CREATE or replace VIEW v_$asm_filegroup_property as
  SELECT * FROM v$asm_filegroup_property;
CREATE or replace PUBLIC synonym v$asm_filegroup_property
  FOR v_$asm_filegroup_property;
GRANT SELECT ON v_$asm_filegroup_property TO select_catalog_role;

CREATE or replace VIEW gv_$asm_filegroup_file as
  SELECT * FROM gv$asm_filegroup_file ;
CREATE or replace PUBLIC synonym gv$asm_filegroup_file
  FOR gv_$asm_filegroup_file;
GRANT SELECT ON gv_$asm_filegroup_file TO select_catalog_role;

CREATE or replace VIEW v_$asm_filegroup_file as
  SELECT * FROM v$asm_filegroup_file;
CREATE or replace PUBLIC synonym v$asm_filegroup_file
  FOR v_$asm_filegroup_file;
GRANT SELECT ON v_$asm_filegroup_file TO select_catalog_role;

CREATE or replace VIEW gv_$asm_quotagroup as
  SELECT * FROM gv$asm_quotagroup ;
CREATE or replace PUBLIC synonym gv$asm_quotagroup
  FOR gv_$asm_quotagroup;
GRANT SELECT ON gv_$asm_quotagroup TO select_catalog_role;

CREATE or replace VIEW v_$asm_quotagroup as
  SELECT * FROM v$asm_quotagroup;
CREATE or replace PUBLIC synonym v$asm_quotagroup
  FOR v_$asm_quotagroup;
GRANT SELECT ON v_$asm_quotagroup TO select_catalog_role;

create or replace view gv_$shadow_datafile as
select * from gv$shadow_datafile;
create or replace public synonym gv$shadow_datafile
for gv_$shadow_datafile;
grant select on gv_$shadow_datafile to select_catalog_role;
create or replace view v_$shadow_datafile as
select * from v$shadow_datafile;
create or replace public synonym v$shadow_datafile
for v_$shadow_datafile;
grant select on v_$shadow_datafile to select_catalog_role;
create or replace view v_$exadirect_acl as
  select * from v$exadirect_acl;
create or replace public synonym v$exadirect_acl
  for v_$exadirect_acl;
grant select on v_$exadirect_acl to select_catalog_role;
create or replace view gv_$exadirect_acl as
  select * from gv$exadirect_acl;
create or replace public synonym gv$exadirect_acl
  for gv_$exadirect_acl;
grant select on gv_$exadirect_acl to select_catalog_role;

Rem
Rem [G]V$QUARANTINE* fixed views
Rem
create or replace view v_$quarantine as
    select * from v$quarantine;
create or replace public synonym v$quarantine
    for v_$quarantine;
grant select on v_$quarantine to select_catalog_role;

create or replace view gv_$quarantine as
    select * from gv$quarantine;
create or replace public synonym gv$quarantine
    for gv_$quarantine;
grant select on gv_$quarantine to select_catalog_role;

create or replace view v_$quarantine_summary as
    select * from v$quarantine_summary;
create or replace public synonym v$quarantine_summary
    for v_$quarantine_summary;
grant select on v_$quarantine_summary to select_catalog_role;

create or replace view gv_$quarantine_summary as
    select * from gv$quarantine_summary;
create or replace public synonym gv$quarantine_summary
    for gv_$quarantine_summary;
grant select on gv_$quarantine_summary to select_catalog_role;

create or replace view GV_$SERVICE_REGION_METRIC as 
  select * from GV$SERVICE_REGION_METRIC;
create or replace public synonym GV$SERVICE_REGION_METRIC 
  for GV_$SERVICE_REGION_METRIC;
grant select on GV_$SERVICE_REGION_METRIC to select_catalog_role;

create or replace view V_$SERVICE_REGION_METRIC as 
  select * from V$SERVICE_REGION_METRIC;
create or replace public synonym V$SERVICE_REGION_METRIC 
  for V_$SERVICE_REGION_METRIC;
grant select on V_$SERVICE_REGION_METRIC to select_catalog_role;

create or replace view GV_$CHUNK_METRIC as select * from GV$CHUNK_METRIC;
create or replace public synonym GV$CHUNK_METRIC for GV_$CHUNK_METRIC;
grant select on GV_$CHUNK_METRIC to select_catalog_role;

create or replace view V_$CHUNK_METRIC as select * from V$CHUNK_METRIC;
create or replace public synonym V$CHUNK_METRIC for V_$CHUNK_METRIC;
grant select on V_$CHUNK_METRIC to select_catalog_role;

Rem
Rem [G]V$FS_FAILOVER_OBSERVERS fixed views
Rem
create or replace view gv_$fs_failover_observers as
    select * from gv$fs_failover_observers;
create or replace public synonym gv$fs_failover_observers
    for gv_$fs_failover_observers;
grant select on gv_$fs_failover_observers to select_catalog_role;

create or replace view v_$fs_failover_observers as
    select * from v$fs_failover_observers;
create or replace public synonym v$fs_failover_observers
    for v_$fs_failover_observers;
grant select on v_$fs_failover_observers to select_catalog_role;

Rem
Rem Column Level Stats views - v_$column_statistics and gv_$column_statistics
Rem

create or replace view v_$column_statistics as
  select * from v$column_statistics;
create or replace public synonym v$column_statistics for v_$column_statistics;
grant select on v_$column_statistics to select_catalog_role;

create or replace view gv_$column_statistics as
  select * from gv$column_statistics;
create or replace public synonym gv$column_statistics for gv_$column_statistics;
grant select on gv_$column_statistics to select_catalog_role;

Rem
Rem ADO for DBIM (project 45958) synonyms and views 
Rem

create or replace view v_$im_adoelements as 
  select * from v$im_adoelements;
create or replace public synonym v$im_adoelements for v_$im_adoelements;
grant select on v_$im_adoelements to select_catalog_role;

create or replace view gv_$im_adoelements as 
  select * from gv$im_adoelements;
create or replace public synonym gv$im_adoelements for gv_$im_adoelements;
grant select on gv_$im_adoelements to select_catalog_role;

create or replace view v_$im_adotasks as 
  select * from v$im_adotasks;
create or replace public synonym v$im_adotasks for v_$im_adotasks;
grant select on v_$im_adotasks to select_catalog_role;

create or replace view gv_$im_adotasks as 
  select * from gv$im_adotasks;
create or replace public synonym gv$im_adotasks for gv_$im_adotasks;
grant select on gv_$im_adotasks to select_catalog_role;

create or replace view v_$im_adotaskdetails as 
  select * from v$im_adotaskdetails;
create or replace public synonym v$im_adotaskdetails for v_$im_adotaskdetails;
grant select on v_$im_adotaskdetails to select_catalog_role;

create or replace view gv_$im_adotaskdetails as 
  select * from gv$im_adotaskdetails;
create or replace public synonym gv$im_adotaskdetails for 
                                 gv_$im_adotaskdetails;
grant select on gv_$im_adotaskdetails to select_catalog_role;

Rem
Rem [G]V$EXADIRECT_ACL fixed views
Rem

create or replace view v_$exadirect_acl as
  select * from v$exadirect_acl;
create or replace public synonym v$exadirect_acl
  for v_$exadirect_acl;
grant select on v_$exadirect_acl to select_catalog_role;
create or replace view gv_$exadirect_acl as
  select * from gv$exadirect_acl;
create or replace public synonym gv$exadirect_acl
  for gv_$exadirect_acl;
grant select on gv_$exadirect_acl to select_catalog_role;

Rem
Rem [G]V$IP_ACL fixed views
Rem

create or replace view gv_$ip_acl as
  select * from gv$ip_acl;
create or replace public synonym gv$ip_acl for gv_$ip_acl;
grant select on gv_$ip_acl to select_catalog_role;

create or replace view v_$ip_acl as
  select * from v$ip_acl;
create or replace public synonym v$ip_acl for v_$ip_acl;
grant select on v_$ip_acl to select_catalog_role;

Rem
Rem [G]V$TEMPFILE_INFO_INSTANCE fixed views
Rem
create or replace view v_$tempfile_info_instance as
    select * from v$tempfile_info_instance;
create or replace public synonym v$tempfile_info_instance
    for v_$tempfile_info_instance;
grant select on v_$tempfile_info_instance to select_catalog_role;

create or replace view gv_$tempfile_info_instance as
    select * from gv$tempfile_info_instance;
create or replace public synonym gv$tempfile_info_instance
    for gv_$tempfile_info_instance;
grant select on gv_$tempfile_info_instance to select_catalog_role;

Rem Views for expression usage tracking
create or replace view v_$exp_stats as 
  select * from v$exp_stats;
create or replace public synonym v$exp_stats for v_$exp_stats;
grant select on v_$exp_stats to select_catalog_role;

create or replace view gv_$exp_stats as
  select * from gv$exp_stats;
create or replace public synonym gv$exp_stats for gv_$exp_stats;
grant select on gv_$exp_stats to select_catalog_role;


Rem Views representing pre-flushed dml monitoring information
create or replace view v_$dml_stats as 
  select * from v$dml_stats;
create or replace public synonym v$dml_stats for v_$dml_stats;
grant select on v_$dml_stats to select_catalog_role;

create or replace view gv_$dml_stats as
  select * from gv$dml_stats;
create or replace public synonym gv$dml_stats for gv_$dml_stats;
grant select on gv_$dml_stats to select_catalog_role;

Rem Views for UTS
create or replace view gv_$diag_trace_file as
  select * from gv$diag_trace_file;
create or replace public synonym gv$diag_trace_file
   for gv_$diag_trace_file;
grant select on gv_$diag_trace_file to select_catalog_role;

create or replace view v_$diag_trace_file as
  select * from v$diag_trace_file;
create or replace public synonym v$diag_trace_file
   for v_$diag_trace_file;
grant select on v_$diag_trace_file to select_catalog_role;

create or replace view gv_$diag_app_trace_file as
  select * from gv$diag_app_trace_file;
create or replace public synonym gv$diag_app_trace_file
   for gv_$diag_app_trace_file;
grant select on gv_$diag_app_trace_file to select_catalog_role;

create or replace view v_$diag_app_trace_file as
  select * from v$diag_app_trace_file;
create or replace public synonym v$diag_app_trace_file
   for v_$diag_app_trace_file;
grant select on v_$diag_app_trace_file to select_catalog_role;

create or replace view gv_$diag_trace_file_contents as
  select * from gv$diag_trace_file_contents;
create or replace public synonym gv$diag_trace_file_contents
   for gv_$diag_trace_file_contents;
grant select on gv_$diag_trace_file_contents to select_catalog_role;

create or replace view v_$diag_trace_file_contents as
  select * from v$diag_trace_file_contents;
create or replace public synonym v$diag_trace_file_contents
   for v_$diag_trace_file_contents;
grant select on v_$diag_trace_file_contents to select_catalog_role;

create or replace view gv_$diag_sql_trace_records as
  select * from gv$diag_sql_trace_records;
create or replace public synonym gv$diag_sql_trace_records
   for gv_$diag_sql_trace_records;
grant select on gv_$diag_sql_trace_records to select_catalog_role;

create or replace view v_$diag_sql_trace_records as
  select * from v$diag_sql_trace_records;
create or replace public synonym v$diag_sql_trace_records
   for v_$diag_sql_trace_records;
grant select on v_$diag_sql_trace_records to select_catalog_role;

create or replace view gv_$diag_opt_trace_records as
  select * from gv$diag_opt_trace_records;
create or replace public synonym gv$diag_opt_trace_records
   for gv_$diag_opt_trace_records;
grant select on gv_$diag_opt_trace_records to select_catalog_role;

create or replace view v_$diag_opt_trace_records as
  select * from v$diag_opt_trace_records;
create or replace public synonym v$diag_opt_trace_records
   for v_$diag_opt_trace_records;
grant select on v_$diag_opt_trace_records to select_catalog_role;

create or replace view v_$diag_sess_sql_trace_records as
  select * from v$diag_sess_sql_trace_records;
create or replace public synonym v$diag_sess_sql_trace_records
   for v_$diag_sess_sql_trace_records;
grant select on v_$diag_sess_sql_trace_records to select_catalog_role;

create or replace view v_$diag_sess_opt_trace_records as
  select * from v$diag_sess_opt_trace_records;
create or replace public synonym v$diag_sess_opt_trace_records
   for v_$diag_sess_opt_trace_records;
grant select on v_$diag_sess_opt_trace_records to select_catalog_role;
Rem End of fixed views for UTS

create or replace view gv_$plsql_debuggable_sessions as
  select inst_id, sid, serial#, logon_time, user#, username,
         osuser, process, machine, port, terminal, program, type, service_name,
         plsql_debugger_connected, con_id
    from gv_$session s
   where type in ('USER') and
         ((sid = sys_context('USERENV', 'SID') and
           user# = sys_context('USERENV', 'CURRENT_USERID') and
           exists (select null from v$enabledprivs
                    where priv_number in (-238 /* DEBUG CONNECT SESSION */)))
          or
          (exists (select null from sys.userauth$ ua
                    where ua.user# = s.user# and
                          ua.grantee# in (select kzsrorol from x$kzsro) and
                          ua.privilege# in (3 /* DEBUG CONNECT ON USER */)))
          or
          (username not in ('SYS', 'XDB') and
           exists (select null from v$enabledprivs
                    where priv_number in (-240 /* DEBUG CONNECT ANY */)))
          or
          sys_context('USERENV', 'CURRENT_USERID') = 0);
create or replace public synonym gv$plsql_debuggable_sessions
   for gv_$plsql_debuggable_sessions;
grant read on gv_$plsql_debuggable_sessions to public;

create or replace view v_$plsql_debuggable_sessions as
  select sid, serial#, logon_time, user#, username,
         osuser, process, machine, port, terminal, program, type, service_name,
         plsql_debugger_connected, con_id
    from v_$session s
   where type in ('USER') and
         ((sid = sys_context('USERENV', 'SID') and
           user# = sys_context('USERENV', 'CURRENT_USERID') and
           exists (select null from v$enabledprivs
                    where priv_number in (-238 /* DEBUG CONNECT SESSION */)))
          or
          (exists (select null from sys.userauth$ ua
                    where ua.user# = s.user# and
                          ua.grantee# in (select kzsrorol from x$kzsro) and
                          ua.privilege# in (3 /* DEBUG CONNECT ON USER */)))
          or
          (username not in ('SYS', 'XDB') and
           exists (select null from v$enabledprivs
                    where priv_number in (-240 /* DEBUG CONNECT ANY */)))
          or
          sys_context('USERENV', 'CURRENT_USERID') = 0);
create or replace public synonym v$plsql_debuggable_sessions
   for v_$plsql_debuggable_sessions;
grant read on v_$plsql_debuggable_sessions to public;

create or replace view gv_$aq_ipc_active_msgs as
    select * from gv$aq_ipc_active_msgs;
create or replace public synonym gv$aq_ipc_active_msgs
    for gv_$aq_ipc_active_msgs;
grant select on gv_$aq_ipc_active_msgs to select_catalog_role;

create or replace view v_$aq_ipc_active_msgs as
    select * from v$aq_ipc_active_msgs;
create or replace public synonym v$aq_ipc_active_msgs
    for v_$aq_ipc_active_msgs;
grant select on v_$aq_ipc_active_msgs to select_catalog_role;

create or replace view gv_$aq_ipc_pending_msgs as
    select * from gv$aq_ipc_pending_msgs;
create or replace public synonym gv$aq_ipc_pending_msgs
    for gv_$aq_ipc_pending_msgs;
grant select on gv_$aq_ipc_pending_msgs to select_catalog_role;

create or replace view v_$aq_ipc_pending_msgs as
    select * from v$aq_ipc_pending_msgs;
create or replace public synonym v$aq_ipc_pending_msgs
    for v_$aq_ipc_pending_msgs;
grant select on v_$aq_ipc_pending_msgs to select_catalog_role;

create or replace view gv_$aq_ipc_msg_stats as
    select * from gv$aq_ipc_msg_stats;
create or replace public synonym gv$aq_ipc_msg_stats
    for gv_$aq_ipc_msg_stats;
grant select on gv_$aq_ipc_msg_stats to select_catalog_role;

create or replace view v_$aq_ipc_msg_stats as
    select * from v$aq_ipc_msg_stats;
create or replace public synonym v$aq_ipc_msg_stats
    for v_$aq_ipc_msg_stats;
grant select on v_$aq_ipc_msg_stats to select_catalog_role;

create or replace view gv_$lockdown_rules as
    select * from gv$lockdown_rules;
create or replace public synonym gv$lockdown_rules
    for gv_$lockdown_rules;
grant select on gv_$lockdown_rules to select_catalog_role;

create or replace view v_$lockdown_rules as
    select * from v$lockdown_rules;
create or replace public synonym v$lockdown_rules
    for v_$lockdown_rules;
grant select on v_$lockdown_rules to select_catalog_role;

Rem
Rem [G]V$SQL_SHARD fixed views
Rem
create or replace view v_$sql_shard as
    select * from v$sql_shard;
create or replace public synonym v$sql_shard
    for v_$sql_shard;
grant select on v_$sql_shard to select_catalog_role;

create or replace view gv_$sql_shard as
    select * from gv$sql_shard;
create or replace public synonym gv$sql_shard 
    for gv_$sql_shard;
grant select on gv_$sql_shard to select_catalog_role;

create or replace view gv_$java_services as
select * from gv$java_services;
create or replace public synonym gv$java_services
   for gv_$java_services;
grant select on gv_$java_services to select_catalog_role;

create or replace view v_$java_services as select * from v$java_services;
create or replace public synonym v$java_services for v_$java_services;
grant select on v_$java_services to select_catalog_role;

create or replace view gv_$java_patching_status as
select * from gv$java_patching_status;
create or replace public synonym gv$java_patching_status
   for gv_$java_patching_status;
grant select on gv_$java_patching_status to select_catalog_role;

create or replace view v_$java_patching_status
  as select * from v$java_patching_status;
create or replace public synonym v$java_patching_status
  for v_$java_patching_status;
grant select on v_$java_patching_status to select_catalog_role;

Rem
Rem [G]V$MEMOPTIMIZE_WRITE_AREA fixed views
Rem
create or replace view v_$memoptimize_write_area as
    select * from v$memoptimize_write_area;
create or replace public synonym v$memoptimize_write_area
    for v_$memoptimize_write_area;
grant select on v_$memoptimize_write_area to select_catalog_role;

create or replace view gv_$memoptimize_write_area as
    select * from gv$memoptimize_write_area;
create or replace public synonym gv$memoptimize_write_area
    for gv_$memoptimize_write_area;
grant select on gv_$memoptimize_write_area to select_catalog_role;

create or replace view gv_$database_replay_progress as
    select * from gv$database_replay_progress;
create or replace public synonym gv$database_replay_progress
      for gv_$database_replay_progress;
grant select on gv_$database_replay_progress to select_catalog_role;

create or replace view v_$database_replay_progress as
    select * from v$database_replay_progress;
create or replace public synonym v$database_replay_progress
      for v_$database_replay_progress;
grant select on v_$database_replay_progress to select_catalog_role;

Rem
Rem [G]V$IMHMSEG fixed views
Rem
create or replace view v_$imhmseg as 
   select * from v$imhmseg;
create or replace public synonym v$imhmseg
   for v_$imhmseg;
grant select on v_$imhmseg to select_catalog_role;

create or replace view gv_$imhmseg as 
   select * from gv$imhmseg;
create or replace public synonym gv$imhmseg
   for gv_$imhmseg;
grant select on gv_$imhmseg to select_catalog_role;

@?/rdbms/admin/sqlsessend.sql
