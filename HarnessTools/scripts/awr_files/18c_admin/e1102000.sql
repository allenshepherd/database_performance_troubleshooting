Rem
Rem e1102000.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      e1102000.sql - downgrade Oracle from 12g
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      needed to downgrade from 12g
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      * The database must be open in UPGRADE mode/DOWNGRADE mode.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/e1102000.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/e1102000.sql
Rem    SQL_PHASE:DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bwright     07/17/17 - Bug 25651930: consolidate Data Pump scripts
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    sanagara    11/22/16 - 25117045: remove common-user bit
Rem    cwidodo     07/27/16 - #(24309782) downgrade changes for histograms
Rem    frealvar    06/25/16 - RTI 19462491 drop package dbms_preup
Rem    raeburns    06/22/16 - Bug 23596553: drop DBMS_XS_MTCACHE and 
Rem                           DBMS_XS_PRINCIPALS
Rem    rmorant     06/15/16 - RTI 19527576 set correct length validation
Rem    yiru        04/08/16 - Bug 23058041: Drop PROVISIONER role
Rem    hmohanku    01/29/16 - bug 22160989: remove all except S: verifiers
Rem    pknaggs     01/29/16 - Bug #22153841: pname 128 in Data Redaction.
Rem    shjoshi     01/26/16 - lrg 17547882: Drop dbms_perf synonym
Rem    svivian     01/06/16 - bug 22503319: revert typename size
Rem    hosu        12/14/15 - 22239656: downgrade synopsis table from 12.2 to
Rem                           under
Rem    ddedonat    11/09/15 - Lrg 16327573  Downgrade to 11.2 leaves orphaned OLAP
Rem                           objects due to DROP SYNONYM syntax when it should have been
Rem                           DROP PUBLIC SYNONYM syntax
Rem    cmlim       10/12/15 - bug 21744290: extra: flush shared pool after
Rem                           unset oracle-maintained bit
Rem    awalter2    09/25/15 - Bug 20312022: change flags column from sqlobj$
Rem    ddedonat    10/05/15 - Lrg 18535472 Downgrade to 11.2 leaves invalid OLAP objects
Rem    ssonawan    08/27/15 - Bug 21427375: replace audit_unified_% references
Rem                           with underlying dictionary tables
Rem    sankejai    07/20/15 - Bug 21474896: drop public synonym x$kxftask
Rem    sankejai    07/20/15 - Bug 21473993: drop public synonym for dbms_pdb
Rem    sramakri    07/20/15 - bug-21350866
Rem    skabraha    07/06/15 - drop dbms_objects_apps_utils
Rem    msakayed    07/01/15 - Bug #21351073: Drop LOADER_LOB_INDEX_* views/syn
Rem    risgupta    06/04/15 - Bug 21133861: move ALTER TABLE on LBACSYS tables
Rem                           for long identifier support to olse112.sql
Rem    sgarduno    05/06/15 - Streams Long Identifier support.
Rem    sudurai     04/16/15 - proj 49581 - optimizer stats encryption
Rem    risgupta    04/09/15 - Lrg 14680081: Determine AUD$ schema before
Rem                           altering it.
Rem    ramekuma    01/14/15 - bug-19333670: Set new columns in histgrm$ to
Rem                           unused state
Rem    pjotawar    12/29/14 - 20216526: Updating flag correctly for 
Rem                           streams$_apply_process
Rem    ajbatta     11/09/14 - 19896841: set guard_id column to null in ecol$
Rem    rdecker     01/11/11 - Remove package type metadata for downgrade
Rem    surman      05/12/14 - 18744004: Drop SQL registry
Rem    sagrawal    02/17/14 - bug 18220091
Rem    yiru        11/25/13 - Lrg 10225403: get XS constraints from metadata 
Rem                           tables directly insead of constraint view
Rem    sagrawal    11/06/13 - bug 17436936
Rem    thbaby      09/02/13 - 14515351: drop view DBA_HIST_PDB_INSTANCE
Rem    geadon      04/24/13 - bug 16686798: limit DEFERRED_STG$.FLAGS_STG to 16
Rem                           bits
Rem    amunnoli    04/08/13 - Bug #16496620: Remove PLUGGABLE DATABASE from
Rem                           default auditing
Rem    lexuxu      03/27/13 - lrg 8929646
Rem    jerrede     03/26/13 - Move GV$AUTO_BMR_STATISTICS from e1102000.sql to
Rem                           e1201000.sql, it was put in the wrong script
Rem    dvoss       03/18/13 - do not drop backported logminer objects
Rem    cmlim       03/01/13 - XbranchMerge cmlim_bug-16085743 from
Rem    smuthuli    02/24/13 - XbranchMerge smuthuli_bug-14803927 from
Rem                           st_rdbms_12.1.0.1
Rem    hosu        02/21/13 - 16246179: fast downgrade of synopsis
Rem    amunnoli    02/18/13 - Bug #16310544: Remove PLUGGABLE DATABASE
Rem                           action from STMT_AUDIT_OPTION_MAP and AUDIT$
Rem    cdilling    02/16/13 - move invocation of e1201000.sql to top of script
Rem    thbaby      02/08/13 - truncate table cdbvw_stats$
Rem    thbaby      01/28/13 - XbranchMerge thbaby_bug_15827913_ph7 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/24/13 - XbranchMerge thbaby_bug_15827913_ph6 from
Rem                           st_rdbms_12.1.0.1
Rem    jahuesva    01/14/13 - XbranchMerge jahuesva_bug-16025907 from
Rem    thbaby      01/22/13 - XbranchMerge thbaby_bug_15827913_ph4 from
Rem                           st_rdbms_12.1.0.1
Rem    akruglik    01/22/13 - XbranchMerge akruglik_common_profiles from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/21/13 - XbranchMerge thbaby_bug_15827913_ph5 from
Rem    thbaby      01/20/13 - XbranchMerge thbaby_bug_15827913_ph3 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/19/13 - lrg 8809394: INT$ALL_SYNONYMS no longer needed
Rem    thbaby      01/17/13 - 15827913: drop INT$DBA_DIRECTORIES
Rem    thbaby      01/16/13 - 15827913: drop INT$ALL_SYNONYMS
Rem    thbaby      01/14/13 - XbranchMerge thbaby_com_dat from
Rem                           st_rdbms_12.1.0.1
Rem    jstraub     01/14/13 - XbranchMerge jstraub_lrg-8743190 from
Rem    thbaby      01/16/13 - 15827913: drop function getlong
Rem    thbaby      01/14/13 - 15827913: drop INT$DBA_SOURCE
Rem    cmlim       01/11/13 - bug 16085743 - remove oracle supplied flag
Rem    jstraub     01/09/13 - remove drop apex_datapump_support
Rem    thbaby      01/07/13 - drop INT$ views
Rem    talliu      12/12/27 - 16020123: drop DBMS_PDB_NUM feature tracking
Rem    sankejai    12/28/12 - XbranchMerge sankejai_bug-15988931 from
Rem                           st_rdbms_12.1.0.1
Rem    smuthuli    12/27/12 - Heatmap feature tracking procedure
Rem    myuin       12/26/12 - XbranchMerge myuin_bug-15981425_12.1.0.1.0 from
Rem                           st_rdbms_12.1.0.1
Rem    sankejai    12/20/12 - 16010984: downgrade change for V$OBJECT_USAGE
Rem    myuin       12/20/12 - drop _DBA_STREAMS_COMPONENT_* views
Rem    sylin       12/18/12 - deprecate dbms_sql2 in release 12
Rem    yhuang      12/13/12 - XbranchMerge yhuang_idmr_feature_tracking from
Rem                           main
Rem    cdilling    12/07/12 - invoke 12.1 patch downgrade script
Rem    lexuxu      11/30/12 - add downgrade of gv$auto_bmr_statistics
Rem    yhuang      12/05/12 - drop procedure dbms_feature_idh
Rem    akruglik    12/03/12 - (15926959): drop profname$.flags
Rem    gclaborn    12/03/12 - Remove drop of datapump''s tstz/tsltz parent  views
Rem    shrgauta    12/03/12 - dropping a package created in prvtcmpr for
Rem                           downgrading from 12.1
Rem    sasounda    11/30/12 - 15841236: drop proc DBMS_FEATURE_SEG_MAIN_ONL_COMP
Rem    elu         11/30/12 - fix XStream downgrade
Rem    aikumar     11/27/12 - bug-15925294:change dbms_lock_allocated table
Rem                           name
Rem    jiayan      11/26/12 - 14133199: drop dbms_feature_spd and 
Rem                           dbms_feature_concurrent_stats
Rem    sagrawal    11/26/12 - lrg 7344697
Rem    prgaharw    11/25/12 - 15865137 - drop ILM indexes not required
Rem    hlakshma    11/18/12 - Drop types created for ADO feature
Rem    cdilling    11/18/12 - bug 15892490 - clean up XA objects
Rem    amadan      11/18/12 - Bug 15860373: drop pdb from aq$_srvntfn_message
Rem    chinkris    11/13/12 - Changes for hybrid columnar compression row level
Rem                           locking feature usage
Rem    aikumar     11/09/12 - add sessions_count view
Rem    cmlim       11/08/12 - bug 14763826 - remove oracle-supplied bits if set
Rem    kmeiyyap    11/06/12 - rename v$ofl_cell_thread_history to 
Rem                           v$cell_ofl_thread_history
Rem    sagrawal    11/08/12 - lrg-8486616
Rem    vbipinbh    11/01/12 - drop wri$_rept_tcb
Rem    jkundu      10/24/12 - bug 13603798: logmnr_gt_tab_xyz needs pdb name
Rem                           column
Rem    rahkrish    10/24/12 - Add downgrade of v$ofl_cellthread_history table.
Rem    akruglik    10/23/12 - (14759626) get rid of DROP PDB privilege
Rem    minx        10/22/12 - Change xs_nsattr_admin to xs_namespace_admin
Rem    rpang       10/19/12 - lrg 7256879: drop network ACE export view
Rem    mfallen     10/17/12 - bug 14390165: use real dbid for con_dbid default
Rem    sagrawal    10/16/12 - bug 14589702
Rem    xihua       10/17/12 - 12c Index Compression factoring change
Rem    siravic     10/15/12 - Bug#14764532 drop DBMS_FEATURE_DATA_REDACTION
Rem                           only for pre-11.2.0.4 case
Rem    vraja       10/15/12 - ILM renamed to HEAT_MAP
Rem    dgagne      10/15/12 - remove Data Pump worker views
Rem    smuthuli    10/15/12 - drop temp tables created for heatmap
Rem    jgiloni     09/26/12 - Add DEAD_CLEANUP view
Rem    myuin       10/15/12 - drop DBA_GOLDENGATE_SUPPORT_MODE
Rem    hlakshma    10/10/12 - Fix ILM view names
Rem    sasounda    09/27/12 - 14621938: drop dbms_part_lib library
Rem    romorale    09/27/12 - Remove Replication Bundle row from sys.props$
Rem    jgiloni     09/26/12 - Add DEAD_CLEANUP view
Rem    smuthuli    10/03/12 - drop dbms_heat_map
Rem    brwolf      09/26/12 - undo editioning of PUBLIC
Rem    yanlili     09/25/12 - Consolidate four RAS audit policies into two
Rem    yanchuan    09/21/12 - bug 14456083: drop LIBRARY DBMS_DATAPUMP_DV_LIB
Rem    jkaloger    09/20/12 - Feature tracking for Data Pump full transportable
Rem    prgaharw    09/20/12 - 13861386 - drop csvlist type
Rem    adalee      09/14/12 - drop [G]V$BT_SCAN_CACHE for downgrades
Rem    amunnoli    09/14/12 - Bug14560783 - Drop AUDSYS user during downgrade
Rem    ygu         09/10/12 - drop dba_logstdby_plsql_support
Rem    jinjche     09/09/12 - Add dropping redo indexes and tables
Rem    krajaman    08/30/12 - Drop PDB_DBA role
Rem    sjanardh    08/24/12 - Drop FLAGS column in SH$SHARD_META type
Rem    hosu        08/27/12 - drop *_tab_cols_v
Rem    pknaggs     08/27/12 - Bug #14055347: Data Redaction downgrd to 11.2.0.4
Rem    sjanardh    08/24/12 - Drop FLAGS column in SH$SHARD_META type
Rem    shase       08/16/12 - truncate undohist$
Rem    dvoss       08/27/12 - bug 14508550 - logminer metadata fixes cdb
Rem    sjanardh    08/24/12 - Drop FLAGS column in SH$SHARD_META type
Rem    minwei      08/22/12 - drop procedure DBMS_FEATURE_ONLINE_REDEF
Rem    yunkzhan    08/21/12 - Bug 13894794: set LogmnrDerivedFlags to null in
Rem                           logmnrc_gtcs for downgrade
Rem    dgraj       08/21/12 - Bug 14195982: drop public synonym for fixed view
Rem    ssonawan    08/21/12 - bug 14491701: clear 0x10 bit user$.astatus column
Rem    cdilling    08/20/12 - clean up invalid 12.1 objects
Rem    jheng       08/17/12 - Bug 14491844: drop views
Rem    traney      08/16/12 - remove non$cdb obj$ row
Rem    dgraj       08/16/12 - Bug 14410104: Clear col$.property flags for TSDP
Rem    pknaggs     08/15/12 - Bug #14499168: Drop data redaction policies.
Rem    tianli      08/14/12 - fix cdb global-name/pdb-name mapping
Rem    rpang       08/13/12 - drop ora_original_sql_txt
Rem    sroesch     08/10.12 - lrg 6853101; add missing sql
Rem    yunkzhan    08/08/12 - drop the DBMS_XSTREAM_GG_INTERNAL package
Rem    sdball      08/08/12 - Drop gds_catalog_select role for GSM
Rem    fergutie    08/03/12 - Bug 14312761: Drop view and synonym for
Rem                           (g)v$gg_apply_receiver and
Rem                           (g)v$xstream_apply_receiver
Rem    cgervasi    08/03/12 - add dbms_perf
Rem    gravipat    08/03/12 - truncate pdb_history$
Rem    cchiappa    08/02/12 - Handle noexp$ changes for OLAP
Rem    vgerard     08/01/12 - Bug 14284283: new set_by columns
Rem    anighosh    08/01/12 - #(14296972): Stretch Identifiers for
Rem                           DBMS_PARALLEL_EXECUTE
Rem    apant       08/01/12 - drop synonyms for V$ and GV$ channel_waits
Rem    moreddy     07/31/12 - Drop asm_audit views
Rem    abrown      07/27/12 - Bug 14378546 : Logminer must track CON$
Rem    alui        07/25/12 - drop wlm package
Rem    sroesch     07/24/12 - Add new service attribute for pq rim service
Rem    praghuna    07/22/12 - bug 14283060: drop logmnrc_*_gg tables
Rem    cdilling    07/20/12 - clean up more objects 
Rem    shiyadav    07/19/12 - 14320459: truncate wri$_tracing_enabled
Rem    ssonawan    07/18/12 - bug 13843068: delete SHA-512 and SHA-1 verifiers
Rem                           from user_history$;
Rem                           delete SHA-1 hash from default_pwd$
Rem    nkgopal     07/11/12 - Bug 14029047: Drop Audit Trail export views
Rem    byu         07/19/12 - lrg 7132763: delete select and alter privilege of
Rem                           measure folder and build process from sysauth$
Rem    rpang       07/19/12 - Remove network ACL name seq and name-map view
Rem    ssonawan    07/18/12 - bug 13843068: delete SHA-512 and SHA-1 verifiers
Rem                           from user_history$;
Rem                           delete SHA-1 hash from default_pwd$
Rem    weihwang    07/17/12 - drop xs_diag_int package
Rem    tbhukya     07/13/12 - Modify queryable patch inventory tables
Rem    dvoss       07/13/12 - drop LOGSTDBY_%SUPPORT_TAB_12_1
Rem    wanhlee     07/12/12 - lrg 7122041: drop gv, gv_, v, v_$ios_client
Rem    nkgopal     07/11/12 - Bug 14029047: Drop Audit Trail export views
Rem    dvoss       07/11/12 - bug 14307623 - streams cloned session issue
Rem    mjaiswal    07/09/12 - add aq_ prefix to gv$subscriber_load
Rem    jmuller     07/06/12 - Bug 14162791 changes
Rem    prgaharw    07/05/12 - 13895208 - Proj-30966: ILM feature tracking
Rem    kdnguyen    07/02/12 - add drop DBMS_FEATURE_OLTP_INDEXCOMP
Rem    thbaby      06/20/12 - drop CDB_* views owned by non-SYS schemas
Rem    rrungta     06/14/12 - Downgrade action for DBMS_LOG
Rem    cslink      06/13/12 - Bug #14151458: Truncate radm_fptm_lob$
Rem    shiyadav    06/12/12 - lrg 7038053: drop column block size from
Rem                           WRH$_TABLESPACE during downgrade
Rem    aramappa    06/06/12 - bug 14163435: do not uppercase schema name in
Rem                           update to rls$
Rem    cqi         06/01/12 - drop procedure dbms_feature_raconenode
Rem    smesropi    06/01/12 - drop views and synonyms for metadata_properties
Rem    dgraj       05/31/12 - Bug 13887494: drop DBMS_FEATURE_TSDP during
Rem                           downgrade
Rem    nkgopal     05/31/12 - Bug 14108323: Drop all_audited_system_actions
Rem                           view
Rem    ygu         05/30/12 - drop dba_logstdby_plsql_map
Rem    vpriyans    05/29/12 - Bug 13768040: Drop public synonym and view
Rem                           AUDIT_UNIFIED_POLICY_COMMENTS
Rem    cslink      05/29/12 - Bug #14133343: Add radm_td$ and radm_cd$ tables.
Rem    aramappa    05/23/12 - bug 13921755: drop procedure
Rem                           dbms_feature_label_security
Rem    svivian     05/23/12 - Bug 13591992: new CON_NAME column
Rem    jheng       05/22/12 - Bug 14003817: remove priv_used$
Rem    hlakshma    05/22/12 - Drop ILM indexes
Rem    jnunezg     05/16/12 - Remove store_output field for job_definition type
Rem    byu         05/09/12 - Bug 13242046: drop SELECT and ALTER privileges for  
Rem                           measure folder and build process while downgrading 
Rem    byu         12/27/11 - truncate olap_metadata_dependencies$ and drop 
Rem                           related views 
Rem    jheng       05/18/12 - Bug 14050142: drop dbms_feature_priv_capture
Rem    paestrad    05/16/12 - downgrade for connect_credential
Rem    smesropi    05/16/12 - drop views and synonyms for 
Rem                           cube_sub_partition_levels, cube_named_build specs
Rem                           and measure_folder_subfolders
Rem    rpang       05/15/12 - 14054925: rename network ACL import package
Rem    maba        05/09/12 - downgrade for V$AQ_MESSAGE_CACHE
Rem    huntran     05/03/12 - Add error_seq#/error_rba/error_index# for error
Rem                           table
Rem    gravipat    05/15/12 - Drop package CDBView
Rem    svivian     05/11/12 - Bug 13887570: SQL injection with LOGMINING
Rem                           privilege
Rem    maba        05/09/12 - downgrade for V$AQ_NONDUR_REGISTRATIONS
Rem    tbhukya     05/08/12 - Truncate opatch_inst_job tab
Rem    huntran     05/03/12 - Add error_seq#/error_rba/error_index# for error
Rem                           table
Rem    thbaby      05/08/12 - drop views and synonyms defined for
Rem                           [g]v$con_system_event
Rem    jhaslam     05/04/12 - drop kernel_io_outlier views and synonyms
Rem    aikumar     05/04/12 - lrg-6922637: drop procedure in dbms_lock package
Rem    akruglik    05/03/12 - drop [g]v_$ views and public synonyms for
Rem                           [g]v$system_wait_class
Rem    cdilling    05/02/12 - drop missing objects
Rem    hosu        05/02/12 - 13844984: add synopsis# primary key constraint
Rem                           back to synopsis head
Rem    akruglik    05/02/12 - drop [g]v_$ views and public synonyms defined for
Rem                           [G]V$CON_SYSSTAT
Rem    bdagevil    04/28/12 - drop packages, views and synonyms on downgrade
Rem    dagagne     04/27/12 - Drop new 12.1 Data Guard stuff
Rem    rpang       04/18/12 - Remove more network ACL view and package
Rem    vgokhale    04/16/12 - Public synonym for v$pdb_incarnation
Rem    pradeshm    04/13/12 - Fix bug-13728931: create triton related tables
Rem                           xs$sessions,xs$session_appns,xs$session_roles
Rem    elu         04/10/12 - add persistent apply tables
Rem    vpriyans    03/21/12 - Bug 13413683: drop all audit policies
Rem                           while downgrading
Rem    lzheng      04/13/12 - drop procedures: feature usage tracking for
Rem                           Streams/XStream/GoldenGate
Rem    snadhika    04/12/12 - Drop procedure DBMS_FEATURE_RAS
Rem    elu         04/10/12 - add persistent apply tables
Rem    hlakshma    04/06/12 - Move ILM downgrade involving PL/SQL references to
Rem                           f1102000.sql
Rem    pknaggs     04/05/12 - Bug #13932111: EXEMPT DML/DDL REDACTION POLICY.
Rem    siravic     03/30/12 - Bug# 13888340: Data redaction feature 
Rem                           usage tracking
Rem    liding      03/30/12 - bug 13904132: MV refresh usage track
Rem    ssonawan    03/26/12 - Bug 8518997: Drop dbms_feature_* procedures
Rem    vpriyans    03/21/12 - Bug 13413683: drop all audit policies
Rem                           while downgrading
Rem    shase       04/04/12 - lrg6853101: drop view v_$tempundostat
Rem    sroesch     04/03/12 - Bug 13795730: Add automatic install and uninstall
Rem    acakmak     04/02/12 - lrg 6723628: Trim column stats min/max raw values
Rem                           when downgrading to 11.1.0.7
Rem    liding      03/30/12 - bug 13904132: MV refresh usage track
Rem    yanchuan    03/28/12 - LRG 6851190: drop view UNIFIED_AUDIT_TRAIL
Rem    shjoshi     03/28/12 - lrg6723583: Add con_dbid to MERGE stmt for
Rem                           wri$_sqltext_refcount
Rem    nrcorcor    03/28/12 - bug 13404486 - missing drop of table added
Rem    shjoshi     03/27/12 - lrg6796359: drop all wri$_rept_ types
Rem    nrcorcor    03/26/12 - bug 13404486 - add drop V$ and GV$ ro_user_account
Rem    shjoshi     03/25/12 - lrg6852622: Drop v$ views for auto report capture
Rem    vbipinbh    03/24/12 - drop view and synonym for GV$AQ_MSGBM
Rem    romorale    03/22/12 - Adding drop view for DBA_STREAMS_UNSUPPORTED_12_1
Rem                           and _DBA_STREAMS_NEWLY_SUPTED_12_1
Rem    shjoshi     03/20/12 - truncate wrp$_reports_control
Rem    elu         03/20/12 - xin persistent table stats
Rem    tianli      03/20/12 - add seq/rba/index to error tables
Rem    gravipat    03/20/12 - Drop public synonyms for [G]V$CONTAIENRS
Rem    pxwong      03/19/12 - disable project 25225 and 25227
Rem    rramkiss    03/19/12 - drop *_scheduler_running_jobs for lrg 6723628
Rem    dgraj       03/15/12 - ER 13485095: downgrade support for tsdp_error$ 
Rem                           and dba_tsdp_import_errors
Rem    sankejai    03/15/12 - 13254357: truncate table pdb_spfile$
Rem    sdball      03/13/12 - GSM Updates
Rem    ushaft      03/03/12 - drop synonyms for rt addm
Rem    tbhukya     03/13/12 - Lrg 6815693
Rem    maniverm    03/12/12 - drop view ans synonym for ksfdsscloneinfo and
Rem                           clonedfile
Rem    shjoshi     03/12/12 - Drop new attributes, columns for RAT masking
Rem    lzheng      03/12/12 - fix lrg 6823980: drop view DBA_CAPTURE
Rem    dvoss       03/12/12 - bug 13826076 drop column seq$.partcount
Rem    kmorfoni    03/09/12 - Disable newly added FK before truncate
Rem    dgraj       03/09/12 - LRG 6814111: dba_sensitive_columns_tbl renamed to
Rem                           dba_sensitive_data_tbl
Rem    jkundu      03/08/12 - bug 13615340 drop always log group for seq
Rem    xiaobma     03/06/12 - Bug 13784524: XS_DATA_SECURITY_UTIL cleanup
Rem    vbipinbh    03/05/12 - downgrade aq$_subscriber
Rem    hayu        02/29/12 - change parse_report_ref
Rem    nijacob     03/01/12 - Lrg 6796289
Rem    hayu        02/29/12 - change parse_report_ref
Rem    jibyun      02/29/12 - Bug 13795256: remove ADMINISTER KEY MANAGEMENT
Rem                           and PURGE DBA_RECYCLEBIN from sysauth$
Rem    schakkap    02/29/12 - #(9316756) delete views created for stats
Rem                           transfer in datapump
Rem    praghuna    02/28/12 - bug13110976: PTO downgrade
Rem    lzheng      02/23/12 - truncate wrh$_sess_sga_stats,
Rem                           wrh$_replication_tbl_stats, and
Rem                           wrh$_replication_txn_stats
Rem    desingh     02/22/12 - drop aq_unflushed_dequeue view
Rem    rtati       02/20/12 - change ntfn_clients to aq_notification_clients
Rem    pyam        02/20/12 - remove various new sysauth privs
Rem    lzheng      02/14/12 - drop gv$goldengate_outbounde_server, 
Rem                         dba_goldengate_outbound,and dba_gg_outbound_progress
Rem    kyagoub     02/10/12 - lrg#6714779: do not revoke emx priv from dba
Rem    brwolf      02/08/12 - 32733: evaluation edition
Rem    shjoshi     02/13/12 - drop member function get_report_with_summary
Rem    kyagoub     02/10/12 - lrg#6714779: do not revoke emx priv from dba
Rem    sroesch     02/06/12 - LRG 6730092: drop pkg dbms_service_prvt
Rem                           for downgrade
Rem    rpang       02/02/12 - Network ACL triton migration
Rem    ssonawan    01/13/12 - Bug 11883154: Remove handler from aud_policy$
Rem    elu         09/26/11 - procedure LCR
Rem    lzheng      02/03/12 - drop _SXGG_DBA_CAPTURE
Rem    ilistvin    02/02/12 - set SWRF version based on prv_version
Rem    shjoshi     01/26/12 - lrg6714550: Use correct name for wrp time bands
Rem                           table
Rem    kmorfoni    01/25/12 - LRG 6714529: disable constraints before truncate
Rem    tbhosle     01/19/12 - lrg 6646349: set session_key column values to
Rem                           null
Rem    hlakshma    01/18/12 - Drop constraint on ilm_param$
Rem    rkiyer      01/17/12 - ACFS Security and Encryption Fixed Views in
Rem                           support for EM Project #31221
Rem    kamotwan    01/11/12 - drop procedure, view and synonyms : feature
Rem                           usage tracking for GoldenGate
Rem    hosu        01/06/12 - drop views defined on session private stats fixed
Rem                           tables
Rem    tbhukya     12/29/11 - Proj 38715 :Drop queryable patch inventory objects
Rem    tianli      12/22/11 - add notifier info for prepare/grant
Rem    dgraj       08/19/11 - Project 32079: Add support for TSDP
Rem    jjlee       01/17/12 - clear flags for seq$.flags beyond a ub1
Rem    arbalakr    01/15/12 - drop cpaddm packages
Rem    ssonawan    01/13/12 - Bug 11883154: Remove handler from aud_policy$
Rem    kamotwan    01/11/12 - drop procedure, view and synonyms : feature
Rem                           usage tracking for GoldenGate
Rem    hosu        01/06/12 - drop views defined on session private stats fixed
Rem                           tables
Rem    tbhukya     12/29/11 - Proj 38715 :Drop queryable patch inventory objects
Rem    tianli      12/22/11 - add notifier info for prepare/grant
Rem    elu         09/26/11 - procedure LCR
Rem    dgraj       08/19/11 - Project 32079: Add support for TSDP
Rem    dvoss       01/13/12 - logstdby$skip_support changes
Rem    dvoss       01/12/12 - logmnr_dictionary$ add pdb_create_scn, pdb_count
Rem    shjoshi     01/11/12 - Drop report repository object
Rem    bdagevil    01/09/12 - remove dup header
Rem    gravipat    12/30/11 - Remove CDBView package
Rem    ddas        01/07/12 - drop evolve advisor from wri$_adv_* tables
Rem    nijacob     01/06/12 - Bug#13485488: Add REDEFINE ANY TABLE privilege
Rem    akruglik    01/04/12 - LRG 5954743: move update of obj$.flags to
Rem                           e1101000.sql since kqdobflg was extended in 11.2
Rem    akruglik    01/04/12 - LRG 5954743: move update of obj$.flags to
Rem                          e1101000.sql since kqdobflg was extended in 11.2
Rem    gravipat    12/30/11 - Remove CDBView package
Rem    akruglik    12/29/11 - LRG 5954743 take 3: clear all view$.property bits
Rem                           which would not fit into a ub4
Rem    akruglik    12/29/11 - LRG 5954743 take 3: clear all view$.property bits
Rem                          which would not fit into a ub4
Rem    kyagoub     12/28/11 - bug#13527334: revoke em express connect from dba
Rem    lgalanis    12/27/11 - truncate user map
Rem    kyagoub     12/27/11 - drop em_express_admin/monitor_role
Rem    kmorfoni    12/27/11 - Downgrade schema related to workload intelligence
Rem    shase       09/25/11 - proj32634: drop tempundostat views
Rem    vradhakr    12/26/11 - Valid time temporal: SYS_FBA_PERIOD.
Rem    cgervasi    12/22/11 - add prvt_awrv_insttab
Rem    mlmiller    12/20/11 - drop new asm_acfsrepl, asm_acfsrepltag
Rem    mkeller     12/20/11 - drop new asm_acfstag
Rem    huntran     12/05/11 - error position in apply$_error
Rem    akruglik    12/19/11 - LRG 5954743: clear obj$.flags bits that do not 
Rem                           fit in a ub2
Rem    jinjche     12/16/11 - Data Pump support for redo management tables
Rem    cchiappa    12/15/11 - Bug12957533: Drop awlogseq$ on downgrade
Rem    hosu        12/13/11 - proj 31794: downgrade synopsis$ table
Rem    jheng       12/12/11 - rename privilege capture objects
Rem    juxie       12/11/11 - bug13420640: drop px_process_trace synonym
Rem    huntran     12/05/11 - error position in apply$_error
Rem    yxie        12/09/11 - drop new em express packages
Rem    yxie        12/09/11 - add session and security report
Rem    cgervasi    12/07/11 - add emx memory report
Rem    gshegalo    12/05/11 - adding copy_nonlogged and backup_nonlogged
Rem    rdecker     11/24/11 - 13020741: cleanup plsql type views
Rem    dvoss       12/01/11 - lrg 6600520 drop packages causing 16206 assert
Rem    akruglik    11/30/11 - LRG 5954743: when downgrading to 11, turn off
Rem                           view$.property bit corresponding to
Rem                           KQLDTVCP2_CONTAINER_DATA
Rem    sramakri    11/28/11 - drop syncref views and synonyms defined in catsnap.sql
Rem    alhollow    11/23/11 - Drop library used to get Pillar/ ZFS storage
Rem    aamirish    11/22/11 - Bug 13358789: Changing names of views
Rem                           {DBA,ALL,USER}_CONTEXT_SENSITIVE_ASSOSNS.
Rem    weihwang    11/17/11 - RAS view cleanup
Rem    lzheng      11/16/11 - drop (g)v$goldengate_outbound_server
Rem    thoang      11/15/11 - LRG 6560220 - chg source_db_name to source_dbname 
Rem    pyam        11/13/11 - clear obj$.flags beyond a ub2
Rem    hlakshma    11/07/11 - Remove ilm_concurrency$ (30966)
Rem    spsundar    11/04/11 - downgrade indpart_param$ table
Rem    ilistvin    11/03/11 - AWR Remote Snapshot
Rem    jnunezg     11/03/11 - Drop scheduler_jobs views since they use new v$
Rem                           tables.
Rem    jomcdon     11/01/11 - lrg 5758311: fix resource manager upgrade
Rem    akruglik    10/24/11 - DB Consolidation: cdb_sysauth$
Rem    byu         10/17/11 - update columns for olap tables
Rem    liaguo      10/21/11 - drop gv$ilm_segment_access
Rem    jibyun      10/18/11 - Bug 13109138: move ALTER TABLE on DVSYS for long
Rem                           identifier support to dve112
Rem    byu         10/17/11 - update columns for olap tables
Rem    jooskim     10/12/11 - bug 13072644: critical parallel statements
Rem    cslink      10/10/11 - Remove dbms_radm package.
Rem    bmccarth    09/29/11 - remove quotes
Rem                         - fix order and remove dups in comments
Rem                         - Remove invalid alters for dv_auth$
Rem    yiru        08/29/11 - XS Admin package cleanup
Rem    jheng       10/10/11 - remove operation_syspriv_map table
Rem    liaguo      10/06/11 - Remove ILM histograms views (32788)
Rem    bmccarth    09/29/11 - remove quotes
Rem                         - fix order and remove dups in comments
Rem                         - Remove invalid alters for dv_auth$
Rem    sslim       09/29/11 - drop dba_rolling synonyms
Rem    byu         09/26/11 - add OLAP changes
Rem    yberezin    09/26/11 - bug 12926385
Rem    kyagoub     09/24/11 - downgrade emx dbhome and storage types
Rem    shjoshi     09/23/11 - Tables and Views for auto report capture
Rem    hayu        09/20/11 - drop v$sql_monitor_sesstat
Rem    yanlili     09/16/11 - Proj 23934: Drop view DBA_XS_AUDIT_POLICY_OPTIONS,
Rem                           DBA_XS_ENB_AUDIT_POLICIES, and
Rem                           DBA_XS_AUDIT_TRAIL
Rem    thoang      09/10/11 - update source_database in streams$_rules
Rem    geadon      09/08/11 - drop DBMS_PART package
Rem    cgervasi    08/29/11 - add perfpage
Rem    cgervasi    07/20/11 - downgrade awrviewer report types
Rem    kyagoub     07/13/11 - downgrade config and ashviewer report types
Rem    savallu     09/15/11 - p#(autodop_31271) calibration stats table
Rem    rrudd       09/14/11 - 12g Dictionary Downgrade for project 32728 (High
Rem                           Priority Online Redefinition Enhancements).
Rem    cslink      09/14/11 - Remove old catalog views for data redaction
Rem    vradhakr    09/12/11 - Project 32919: DBHardening.
Rem    thoang      09/10/11 - update source_database in streams$_rules
Rem    gagarg      09/10/11 - incorporate Carol review comment
Rem    tbhosle     09/09/11 - drop v_$ntfn_clients and gv_$ntfn_clients
Rem    sslim       09/09/11 - Project 27852: remove DBMS_ROLLING package
Rem    adalee      09/09/11 - drop kcb DW scan views for downgrade
Rem    yiru        08/29/11 - XS Admin package cleanup
Rem    hlakshma    09/09/11 - Project 30966: Drop ILM result stat table
Rem    rpang       08/08/11 - 12843424: add translate sql privilege
Rem    geadon      09/08/11 - drop DBMS_PART package
Rem    jstamos     09/08/11 - PDB views for AQ
Rem    akruglik    09/06/11 - rename CDB_ADMIN to CDB_DBA
Rem    gagarg      09/01/11 - set sub_oid column of AQ$_queues to NULL
Rem    brwolf      09/01/11 - 32733: finer-grained editioning
Rem    akruglik    08/30/11 - DB Consolidation: drop DBA_PDB_HISTORY,
Rem                           DBA_CONTAINER_DATA and CDB_ADMIN
Rem    kigoyal     08/29/11 - drop flashfilestat views
Rem    hlakshma    08/29/11 - Drop ILM (project 30966) views
Rem    mjaiswal    08/22/11 - AQ$_QUEUE_SHARDS downgrade changes
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER
Rem                           Next Generation to Unified
Rem    rdongmin    08/12/11 - proj 23305: drop v$sqLdiag_repository[_reason]
Rem    maba        08/11/11 - downgrade changes for system.aq$_queues and views
Rem    gagarg      08/04/11 - 31157:truncate AQ_DURABLE_SUBS
Rem    msusaira    02/14/11 - dbmsfs changes
Rem    evoss       08/27/11 - downgrade job resources
Rem    acakmak     08/26/11 - Project 31794: New histogram types downgrade
Rem    sankejai    08/25/11 - downgrade changes for Database Properties (props$)
Rem    jomcdon     08/23/11 - project 27116: add parallel_server_target
Rem    skayoor     08/22/11 - Bug 12846043: Audit for INHERIT PRIVILEGES.
Rem    ddas        08/22/11 - drop wri$_adv_spm_evolve
Rem    svivian     08/22/11 - Project 30582: Logical Standby EDS DDL support
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER
Rem                           Next Generation to Unified
Rem    rdongmin    08/12/11 - proj 23305: drop v$sqLdiag_repository[_reason]
Rem    msusaira    02/14/11 - dbmsfs changes
Rem    svivian     08/19/11 - project 33052: revoke logmining privilege
Rem    weizhang    08/16/11 - drop v$/gv$bts_stat public synonyms and views 
Rem    rpang       08/16/11 - Revoke inherit privs & sql translation sys privs
Rem    praghuna    08/15/11 - 12879207: clear FLAGS in logstdby$apply_milestone
Rem    skyathap    08/12/11 - drop gsm_flags from service$
Rem    rdongmin    08/12/11 - proj 23305: drop v$sqLdiag_repository[_reason]
Rem    maba        08/11/11 - downgrade changes for system.aq$_queues and views
Rem    sankejai    08/11/11 - downgrade for Parallel Task Library - X$KXFTASK
Rem    thoang      08/10/11 - set src_dbname to src_root_name
Rem    aikumar     08/05/11 - bug 12710912 : Drop new dbms_lock sequence and
Rem                           truncate new table
Rem    bhristov    08/05/11 - DB Consolidation: drop pdbdba$
Rem    gagarg      08/04/11 - 31157:truncate AQ_DURABLE_SUBS
Rem    gshegalo    08/03/11 - Project 23025 GV/V$NONLOGGED_BLOCK
Rem    elu         08/02/11 - bug 12650347
Rem    rdongmin    08/01/11 - proj 28394: drop sqlobj$plan
Rem    gkulkarn    08/01/11 - Downgrade actions for dba_supplemental_logging
Rem    acakmak     07/29/11 - project 31794: drop tables and indexes added
Rem                           for reporting stats operations
Rem    sroesch     07/26/11 - Bug 12713359: Rename and widen sql translation
Rem                           name column in service$
Rem    sramakri    07/26/11 - changes to syncref$ tables
Rem    hohung      07/21/11 - Drop replay context fixed views
Rem    hosu        07/20/11 - downgrade synopsis table only when downgrade
Rem                           version is prior to 11.2.0.2
Rem    rpang       07/18/11 - drop v$/gv$mapped_sql public synonyms and views
Rem    yanlili     07/08/11 - lrg 5695694: drop pre-seeded audit policies,
Rem                           drop view DBA_XS_AUDIT_POLICY_OPTS
Rem    rgmani      07/20/11 - Drop scheduler fixed views
Rem    minwei      07/19/11 - sys.redef_track$ table for online redefinition
Rem    rpang       07/18/11 - drop v$/gv$mapped_sql public synonyms and views
Rem    dvoss       07/18/11 - bug 12701895 - logmnr/lsby chk target release
Rem    akruglik    07/15/11 - DB Consolidation: new table - condata$
Rem    elu         07/14/11 - row lcr changes
Rem    yurxu       07/11/11 - Bug-12701917: add version check
Rem    yiru        07/10/11 - proj# 24200 :Drop admin internal packages
Rem    bmilenov    07/08/11 - Data Mining Expectation Maximization related
Rem                           downgrades
Rem    wesmith     07/07/11 - project 31843: identity columns
Rem    sursridh    07/06/11 - proj 32995: drop index_orphaned_entry$.
Rem    liaguo      07/06/11 - drop dbms_ilm_lib
Rem    alui        07/06/11 - drop procedure dbms_feature_qosm
Rem    mjstewar    07/06/11 - Drop GSM
Rem    aramappa    06/30/11 - Project 31942: Clear rls$ bit for OLS
Rem    pstengar    06/30/11 - project 32330: drop attrspec from modelatt$
Rem    shbose      06/27/11 - downgrade changes for support of fast operators
Rem                           for rule set
Rem    shiyadav    06/27/11 - proj# 31118: DBMS_ADR and DBMS_ADR_APP package
Rem    skwak       06/27/11 - Drop XS_SESSION_ADMIN, XS_NSATTR_ADMIN, and 
Rem                           XS_CACHE_ADMIN
Rem    rgmani      06/27/11 - Drop 12.1 scheduler views
Rem    liaguo      06/27/11 - Proj 32788 DB ILM: remove ILM stats tables
Rem    skayoor     06/27/11 - Project 32719 - Add INHERIT PRIVILEGES
Rem    aramappa    06/23/11 - Project 31942: clear tab$.property bit for OLS
Rem    ilistvin    06/21/11 - drop wrm$_pdb_instance
Rem    dahlim      06/20/11 - Project 32006: RADM add EXEMPT REDACTION POLICY
Rem    yiru        06/18/11 - proj# 24200: drop role XS_RESOURCE
Rem    jnunezg     06/17/11 - Downgrade action for scheduler jobs RESTARTABLE
Rem                           flag.
Rem    sramakri    06/16/11 - project 31326: syncref$ objects for mv sync-refresh
Rem    paestrad    06/15/11 - Downgrade for long varchar on scheduler program
Rem                           and job action
Rem    jomcdon     06/15/11 - Add base tables for Resource Manager CDB plans
Rem    jnunezg     06/14/11 - Downgrade for job_run_details
Rem    jaeblee     06/13/11 - Consolidated Databases: Truncate cdb_service$
Rem    dvoss       06/10/11 - LOGMNRC_DBNAME_UID_MAP CDB changes
Rem    brwolf      06/09/11 - edition-based redefiniton changes
Rem    rbello      06/08/11 - downgrade rmtab$
Rem    snadhika    06/08/11 - Changes related dropping active Triton session
Rem                           views (Project # 31196)
Rem    ilistvin    06/03/11 - extend AWR_OBJECT_INFO_TYPE
Rem    paestrad    06/03/11 - Downgrade actions for DBMS_CREDENTIAL and
Rem                           scheduler$_credential
Rem    jheng       06/01/11 - Proj 32973
Rem    weihwang    06/01/11 - proj# 23920: drop cbac views and truncate
Rem                           codeauth$
Rem    hlakshma    05/27/11 - Remove ILM (Project 30966) related tables
Rem    elu         05/25/11 - remove xml schema
Rem    tianli      05/19/11 - change src_root_name to root_name
Rem    shbose      05/19/11 - downgrade for new column in rule_set_ve$
Rem    jsamuel     05/19/11 - drop radm catalog views (Proj 32006)
Rem    rmir        05/17/11 - Proj 32008, add public synonyms for
Rem                           (G)V$ENCRYPTION_KEYS & (G)V$CLIENT_SECRETS
Rem    sankejai    05/15/11 - truncate fba tables
Rem    jibyun      05/15/11 - Project 5687: Remove PURGE DBA_RECYCLEBIN
Rem                           privilege
Rem    sankejai    05/15/11 - truncate fba tables
Rem    tfyu        05/13/11 - bug-11874338
Rem    huntran     01/13/11 - conflict, error, and collision handlers
Rem    elu         01/12/11 - error queue
Rem    gravipat    05/12/11 - DB Consolidation: Drop CDB views
Rem    traney      05/12/11 - 35209: longer identifiers dictionary downgrade
Rem    pbagal      05/10/11 - Drop v$asm_estimate
Rem    jnarasin    05/10/11 - Drop views for project 35612
Rem    bdagevil    05/09/11 - drop v$sql_monitor_statname
Rem    mziauddi    05/09/11 - project 35612: remove zmapscale from sum$,
Rem                           drop zone map dictionary views
Rem    amullick    05/06/11 - drop cli_tab$
Rem    yxie        05/06/11 - remove em express schema
Rem    bhristov    05/05/11 - DB Consolidation: delete pdb privileges
Rem    schakkap    05/05/11 - project SPD (31794): drop Sql Plan Directive
Rem                           objects
Rem    sroesch     05/04/11 - drop erase max_lag_time
Rem    hohung      05/04/11 - add KEEP DATE TIME, KEEP SYSGUID system privilege
Rem    kmorfoni    05/03/11 - schedule_name in wrr$_replays and cap_file_id in
Rem                           wrr$_replay_divergence & wrr$_replay_sql_binds
Rem    gravipat    04/29/11 - Change dba_pluggable_databases to dba_pdbs
Rem    vbipinbh    04/29/11 - downgrade changes for rules engine
Rem    kyagoub     04/26/11 - fix drop sqlset_row type
Rem    liding      04/25/11 - out-place refresh
Rem    skyathap    04/21/11 - drop dg_broker_config
Rem    dvoss       04/19/11 - Project 33052 - Logminer consolidation support
Rem    yurxu       04/11/11 - Add connect_user for xstream$_sever
Rem    nkgopal     04/04/11 - Drop V$AUDIT_RECORD_FORMAT view
Rem    amylavar    04/04/11 - remove ILM related sequences, tables, indexes
Rem    rpang       04/01/11 - Auditing support for SQL translation profiles
Rem    jheng       04/01/11 - Proj 32973
Rem    traney      03/31/11 - 29499: drop utl_call_stack pkg
Rem    hosu        03/31/11 - project 31794: drop new types created for 
Rem                           online stats gathering
Rem    aamirish    03/27/11 - Project 35490: Truncating rls_csa$ and dropping
Rem                           its views.
Rem    abrown      03/25/11 - abrown_bug-11737200
Rem    dahlim      03/25/11 - proj 32006 (RADM): truncate radm_fptm$
Rem    jibyun      03/25/11 - Project 5687: Remove new administrative
Rem                           privileges/users; SYSBACKUP, SYSDG, and SYSKM
Rem    jinjche     03/24/11 - Rename a table
Rem    slynn       03/22/11 - Project-25215: Sequence Enhancements
Rem    tianli      03/22/11 - add PDB for xstream
Rem    yurxu       03/18/11 - Bug-11922716: 2-level privilege model
Rem    nkgopal     03/18/11 - Drop v_$audit_trail and gv_$audit_trail
Rem    amylavar    03/16/11 - truncate compression_stat$
Rem    shjoshi     03/16/11 - Restore columns in STS for CDB
Rem    swerthei    03/15/11 - force new version on PT.RS branch
Rem    jstraub     03/15/11 - drop apex_datapump_support
Rem    jinjche     03/10/11 - Add actions for Data Guard tables and views
Rem    amunnoli    03/09/11 - Proj 26873:Drop roles AUDIT_ADMIN and AUDITOR
Rem    alui        03/08/11 - drop capability array type for wlm
Rem    sylin       03/07/11 - drop dbms_sql2 for release < 11.2.0.2
Rem    gclaborn    03/07/11 - truncate table impcalloutreg$
Rem    wbattist    03/02/11 - bug 11779958_2 - correct downgrade for
Rem                           hang_statistics views for 11.2.0.4
Rem    elu         02/28/11 - set internal flag
Rem    kkunchit    02/25/11 - bug-10349967: dbfs export/import support
Rem    rramkiss    02/23/11 - downgrade scheduler by removing import callouts
Rem    sankejai    02/19/11 - move v$/gv$ views in catalog scripts to kqfv
Rem    elu         02/19/11 - lcr changes
Rem    rmir        02/16/11 - Proj 32008,delete ADMINISTER KEY MANAGEMENT audit
Rem                           option & system privilege
Rem    wbattist    02/16/11 - bug 11779958 - do not remove hang manager views
Rem                           when downgrading to 11.2.0.3
Rem    elu         02/16/11 - modify eager_size
Rem    msusaira    02/14/11 - dbmsfs changes
Rem    yiru        02/08/11 - Triton security downgrade
Rem    ssonawan    01/28/11 - proj16531: drop dictionary objects 
Rem    gravipat    01/26/11 - Drop dbms_pdb
Rem    spetride    06/09/10 - downgrade for Digest verifiers in user$
Rem    huntran     01/26/11 - XStream table stats
Rem    kshergil    01/26/11 - drop dbms_lobutil_dedupset_t
Rem    rdongmin    01/28/11 - lrg-5121554 fix typo at the first line
Rem    rpang       01/10/11 - Add SQL translation
Rem    kshergil    01/26/11 - drop dbms_lobutil_dedupset_t
Rem    jkaloger    01/19/11 - PROJ:27450 - Update Utilities tracking for 12g.
Rem    rapayne     01/10/11 - remove 12g specific Triton Security support for mdapi
Rem    hosu        01/07/11 - drop procedure for registering dbms_stats incremental
Rem    avangala    01/10/11 - Bug 9873405: downgrade MVs
Rem    xbarr       01/06/11 - bug10640550: move odm metadata to SYSAUX
Rem    sroesch     01/03/11 - Remove new service attributes
Rem    ilistvin    12/27/10 - bug10427840: downgrade AWR version
Rem    pknaggs     12/14/10 - RADM: downgrade from 12.1 to 11.2
Rem    mmcracke    12/13/10 - migrate sys.dm_glm_coeff
Rem    wbattist    12/03/10 - bug 10256769 - drop V$ views and synonyms
Rem                           associated with Hang Manager statistics
Rem    mtozawa     11/23/10 - drop feature usage tracking for DMU(bug 10280821)
Rem    gkulkarn    11/23/10 - Logminer: Add downgrade from 11203 leg
Rem    gravipat    11/22/10 - Consolidated databases: drop view
Rem                           dba_pluggable_database, remove pdb column from
Rem                           service$
Rem    gravipat    11/17/10 - Consolidated Databases: Truncate cdb_file$
Rem    bmilenov    10/07/10 - Data mining SVD-related downgrades
Rem    jaeblee     11/05/10 - pdb$ -> container$
Rem    yiru        11/01/10 - Fix lrg 4815614: drop ACLMV tables and views
Rem    amullick    08/26/10 - common logging infrastructure changes
Rem    sankejai    08/22/10 - Consolidated Databases: truncate pdb$
Rem    prakumar    08/17/10 - Bug 6321275: Drop dbms_redefinition_internal
Rem    smuthuli    08/01/10 - fast space usage changes
Rem    thoang      07/29/10 - drop dba_xstream_outbound view
Rem    thoang      07/29/10 - drop dba_xstream_outbound view 
Rem    fsanchez    06/09/10 - bug 9689580
Rem    qiwang      05/26/10 - truncate logmnr integrated spill table
Rem                         - (gkulkarn) Set logmnr_session$.spare1 to null
Rem                           on downgrade
Rem    tbhosle     05/04/10 - 8670389: remove session_key from reg$
Rem    jawilson    05/05/10 - Change aq$_replay_info address format
Rem    pbelknap    04/27/10 - add dbms_auto_sqltune
Rem    thoang      04/27/10 - change Streams parameter names
Rem    pbelknap    02/25/10 - #8710750: introduce WRI$_SQLTEXT_REFCOUNT
Rem    wbattist    04/13/10 - drop v$hang_info and v$hang_session_info views
Rem    ptearle     04/09/10 - 8354888: drop synonym for DBA_TAB_MODIFICATIONS
Rem    rmao        03/29/10 - drop v/gv$xstream/goldengate_transaction,
Rem                           v/gv$xstream/goldengate_message_tracking views
Rem    abrown      03/24/10 - bug-9501098: GG XMLOR support
Rem    rmao        03/10/10 - drop v$xstream/goldenate_capture views
Rem    lgalanis    02/16/10 - workload attributes table
Rem    jomcdon     02/10/10 - bug 9368895: add parallel_queue_timeout
Rem    bvaranas    02/10/10 - Drop feature usage tracking procedure for
Rem                           deferred segment creation
Rem    hosu        02/15/10 - 9038395: wri$_optstat_synopsis$ schema change
Rem    jomcdon     02/10/10 - bug 9207475: undo end_time allowed to be null
Rem    rramkiss    02/04/10 - remove new scheduler types
Rem    juyuan      02/01/10 - drop lcr$_row_record.get_object_id
Rem    sburanaw    01/13/10 - filter_set_name in wrr$_replays and
Rem                           default_action in wrr$_replay_filter_set
Rem    juyuan      01/14/10 - re-create ALL_STREAMS_STMT_HANDLERS and
Rem                           ALL_STREAMS_STMTS
Rem    ssprasad    12/28/09 - add vasm_acfs_encryption_info
Rem                           add v$asm_acfs_security_info
Rem    juyuan      12/23/09 - drop {dba,user}_goldengate_privileges
Rem    gngai       09/15/09 - bug 6976775: downgrade adr
Rem    juyuan      01/14/10 - re-create ALL_STREAMS_STMT_HANDLERS and
Rem                           ALL_STREAMS_STMTS
Rem    msusaira    01/11/10 - dbmsdnfs.sql changes
Rem    gagarg      12/24/09 - Bug8656192: Drop rules engine package
Rem                           dbms_rule_internal
Rem    amadan      11/19/09 - Bug 9115881 drop DBA_HIST_PERSISTENT_QMN_CACHE
Rem    adalee      12/08/09 - drop [g]v$database_key_info
Rem    dvoss       12/10/09 - Bug 9128849: delete lsby underscore skip entries
Rem    thoang      12/03/09 - drop synonym dbms_xstream_gg
Rem    shjoshi     11/12/09 - drop view v$advisor_current_sqlplan for downgrade
Rem    arbalakr    11/12/09 - drop views that uses X$MODACT_LENGTH
Rem    jomcdon     12/03/09 - project 24605: clear max_active_sess_target_p1
Rem    ilistvin    11/20/09 - bug 8811401: drop index on WRH$_SEG_STAT_OBJ
Rem    akruglik    11/18/09 - 31113 (SCHEMA SYNONYMS): adding support for 
Rem                           auditing CREATE/DROP SCHEMA SYNONYM
Rem    mfallen     11/15/09 - bug 5842726: add drpadrvw.sql
Rem    mziauddi    11/13/09 - drop views and synonyms for DFT
Rem    arbalakr    11/12/09 - drop views that uses X$MODACT_LENGTH
Rem    xingjin     11/15/09 - Bug 9086576: modify construct in lcr$_row_record
Rem    akruglik    11/10/09 - add/remove new audit_actions rows
Rem    shbose      11/05/09 - Bug 9068654: update destq column
Rem    praghuna    11/03/09 - Drop some columns added in 11.2
Rem    juyuan      10/31/09 - drop a row in sys.props$ where
Rem                           name='GG_XSTREAM_FOR_STREAMS'
Rem    gravipat    10/27/09 - Truncate sqlerror$
Rem    lgalanis    10/27/09 - STS capture for DB Replay
Rem    haxu        10/26/09 - add DBA_APPLY_DML_CONF_HANDLERS changes
Rem    msakayed    10/22/09 - Bug #5842629: direct path load auditing
Rem    praghuna    10/19/09 - Make start_scn_time, first_scn_time NULL
Rem    tianli      10/14/09 - add xstream change
Rem    thoang      10/13/09 - add uncommitted data mode for XStream
Rem    bpwang      10/11/09 - drop DBA_XSTREAM_OUT_SUPPORT_MODE
Rem    elu         10/06/09 - stmt lcr
Rem    alui        10/26/09 - drop objects in APPQOSSYS schema
Rem    msakayed    10/22/09 - Bug #8862486: AUDIT_ACTION for directory execute
Rem    gkulkarn    10/06/09 - Downgrade for ID Key Supplemental logging
Rem    achoi       09/21/09 - edition as a service attribute
Rem    shbose      09/18/09 - Bug 8764375: add destq column to
Rem    sriganes    09/03/09 - bug 8413874: changes for DBA_HIST_MVPARAMETER
Rem    abrown      09/02/09 - downgrade for tianli_bug-8733323
Rem    cdilling    07/31/09 - Patch downgrade script for 11.2
Rem    cdilling    07/31/09 - Created
Rem

Rem *************************************************************************
Rem BEGIN e1102000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release - 
Rem                invoke 12.1 patch downgrade
Rem =========================================================================
  
@@e1201000.sql
  
Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN Changes to STS tables due to CDB
Rem *************************************************************************

Rem alter pk constraints on various STS tables and set con_dbid column to NULL

-- stmts table
alter table wri$_sqlset_statements
drop constraint wri$_sqlset_statements_pk;

alter table wri$_sqlset_statements
add constraint wri$_sqlset_statements_pk primary key (id);

-- plans table
alter table wri$_sqlset_plans
drop constraint wri$_sqlset_plans_pk;

alter table wri$_sqlset_plans
add constraint wri$_sqlset_plans_pk primary key(stmt_id, plan_hash_value);

-- plans_to_cap table
alter table wri$_sqlset_plans_tocap
drop constraint wri$_sqlset_plans_tocap_pk;

alter table wri$_sqlset_plans_tocap
add constraint wri$_sqlset_plans_tocap_pk primary key(stmt_id, plan_hash_value);

-- stats table
alter table wri$_sqlset_statistics
drop constraint wri$_sqlset_statistics_pk;

alter table wri$_sqlset_statistics
add constraint wri$_sqlset_statistics_pk primary key(stmt_id, plan_hash_value);

-- mask table
alter table wri$_sqlset_mask
drop constraint wri$_sqlset_mask_pk;

alter table wri$_sqlset_mask
add constraint wri$_sqlset_mask_pk primary key(stmt_id, plan_hash_value);

-- plan lines table
alter table wri$_sqlset_plan_lines
drop constraint wri$_sqlset_plan_lines_pk;

alter table wri$_sqlset_plan_lines
add constraint wri$_sqlset_plan_lines_pk primary key(stmt_id,
                                                     plan_hash_value,id);

-- binds table
alter table wri$_sqlset_binds
drop constraint wri$_sqlset_binds_pk;

alter table wri$_sqlset_binds
add constraint wri$_sqlset_binds_pk primary key(stmt_id,plan_hash_value,
                                                position);

Rem Drop field from type sqlset_row
drop type sqlset_row force;  
drop public synonym sqlset_row;

Rem *************************************************************************
Rem END Changes to STS tables due to CDB
Rem *************************************************************************

Rem ========================================================================
Rem Begin Changes for AQ
Rem ========================================================================

update aq$_schedules set destq = NULL;

Rem WRH$_PERSISTENT_QMN_CACHE changes
Rem
drop view DBA_HIST_PERSISTENT_QMN_CACHE;
drop public synonym DBA_HIST_PERSISTENT_QMN_CACHE;
truncate table WRH$_PERSISTENT_QMN_CACHE;


DECLARE
CURSOR s_c IS   SELECT  r.eventid, r.agent.address as address
                from sys.aq$_replay_info r where r.agent.address IS NOT NULL;
dom_pos         BINARY_INTEGER;
db_domain       VARCHAR2(1024);
new_address     VARCHAR2(1024);
BEGIN

  SELECT UPPER(value) INTO db_domain FROM v$parameter WHERE name = 'db_domain';

  IF db_domain IS NOT NULL THEN
    FOR s_c_rec in s_c LOOP
      dom_pos := INSTRB(s_c_rec.address, db_domain, 1, 1);
      IF (dom_pos != 0) THEN
        new_address := SUBSTRB(s_c_rec.address, 1, dom_pos - 2);
        UPDATE sys.aq$_replay_info r set r.agent.address = new_address WHERE
          r.eventid = s_c_rec.eventid AND r.agent.address = s_c_rec.address;
      END IF;

      COMMIT;
    END LOOP;
  END IF;
END;
/


drop index sys.reg$_idx
/

update sys.reg$ set session_key = NULL;

Rem ==============================
Rem Changes applicable for 12.0 AQ
Rem ==============================
update system.aq$_queues set sub_oid = NULL;
truncate table sys.AQ$_DURABLE_SUBS;
truncate table SYS.AQ$_SUBSCRIBER_LWM;
truncate table SYS.AQ$_QUEUE_SHARDS;

drop library dbms_sqadm_lib;

-- drop attributes from aq$_event_message
ALTER TYPE sys.aq$_event_message
DROP ATTRIBUTE(pdb) CASCADE
/

-- drop attributes from aq$_srvntfn_message
ALTER TYPE sys.aq$_srvntfn_message
DROP ATTRIBUTE(pdb) CASCADE
/

 
-- drop attributes from sh$shard_meta
ALTER TYPE sys.sh$shard_meta
DROP ATTRIBUTE(flags) CASCADE
/

drop public synonym gv$aq_subscriber_load;
drop view gv_$aq_subscriber_load;
drop public synonym v$aq_subscriber_load;
drop view v_$aq_subscriber_load;

drop public synonym V$AQ_NONDUR_SUBSCRIBER;
drop view V_$AQ_NONDUR_SUBSCRIBER;
drop public synonym GV$AQ_NONDUR_SUBSCRIBER;
drop view GV_$AQ_NONDUR_SUBSCRIBER;
drop public synonym V$AQ_NONDUR_SUBSCRIBER_LWM;
drop view V_$AQ_NONDUR_SUBSCRIBER_LWM;
drop public synonym GV$AQ_NONDUR_SUBSCRIBER_LWM;
drop view GV_$AQ_NONDUR_SUBSCRIBER_LWM;
drop public synonym V$AQ_BMAP_NONDUR_SUBSCRIBERS;
drop view V_$AQ_BMAP_NONDUR_SUBSCRIBERS;
drop public synonym GV$AQ_BMAP_NONDUR_SUBSCRIBERS;
drop view GV_$AQ_BMAP_NONDUR_SUBSCRIBERS;

drop public synonym gv$ro_user_account;
drop view gv_$ro_user_account;
drop public synonym v$ro_user_account;
drop view v_$ro_user_account;
drop public synonym gv$aq_notification_clients;
drop view gv_$aq_notification_clients;
drop public synonym v$aq_notification_clients;
drop view v_$aq_notification_clients;

drop public synonym gv$aq_background_coordinator;
drop view gv_$aq_background_coordinator;
drop public synonym v$aq_background_coordinator;
drop view v_$aq_background_coordinator;
drop public synonym gv$aq_job_coordinator;
drop view gv_$aq_job_coordinator;
drop public synonym v$aq_job_coordinator;
drop view v_$aq_job_coordinator;
drop public synonym gv$aq_server_pool;
drop view gv_$aq_server_pool;
drop public synonym v$aq_server_pool;
drop view v_$aq_server_pool;
drop public synonym gv$aq_cross_instance_jobs;
drop view gv_$aq_cross_instance_jobs;
drop public synonym v$aq_cross_instance_jobs;
drop view v_$aq_cross_instance_jobs;

drop public synonym dba_subscr_registrations;
drop view dba_subscr_registrations;

drop public synonym "_ALL_QUEUE_CACHED_MESSAGES";
drop view "_ALL_QUEUE_CACHED_MESSAGES";

drop public synonym dbms_aqjms;

drop public synonym gv$channel_waits;
drop view gv_$channel_waits;
drop public synonym v$channel_waits;
drop view v_$channel_waits;

Rem ===================
Rem End 12.0 AQ changes
Rem ===================

-- hidden table to contain session keys for registrations
create table sys.regz$
( reg_id            number,
  session_key       varchar2(1024))
/

-- drop AQ PDB views
drop view "_CDB_RULES1";
drop view "_DBA_RULES1";
drop view "_CDB_QUEUE_STATS1";
drop view "_DBA_QUEUE_STATS1";

drop public synonym aq$_unflushed_dequeues;
drop view aq$_unflushed_dequeues;

Rem ========================================================================
Rem End Changes for AQ
Rem ========================================================================

Rem===================
Rem AWR Changes Begin
Rem===================

Rem 
Rem Drop sysawr user
Rem
drop user sysawr
/

alter type AWR_OBJECT_INFO_TYPE drop attribute (
             partition_type
           , index_type
           , base_object_name
           , base_object_owner
           , base_object_id
) cascade
/

Rem  WRH$_MVPARAMETER changes

drop view DBA_HIST_MVPARAMETER;
drop public synonym DBA_HIST_MVPARAMETER;
truncate table WRH$_MVPARAMETER;
truncate table WRH$_MVPARAMETER_BL;

Rem Bug 8811401 changes
drop index WRH$_SEG_STAT_OBJ_INDEX;
truncate table wrh$_tablespace;
drop public synonym AWR_OBJECT_INFO_TABLE_TYPE;
drop public synonym AWR_OBJECT_INFO_TYPE;
drop type AWR_OBJECT_INFO_TABLE_TYPE force;
drop type AWR_OBJECT_INFO_TYPE force;

Rem PDB changes
truncate table wrm$_pdb_instance;

Rem Tables for Automatic Report Capture
truncate table wrp$_reports;
truncate table wrp$_reports_details;
truncate table wrp$_reports_time_bands;
truncate table wrp$_reports_control;

Rem auto report packages
drop package body dbms_auto_report_internal;
drop package dbms_auto_report_internal;
drop package dbms_auto_report;
drop public synonym dbms_auto_report;

Rem Views and Synonyms for Automatic Report Capture
drop public synonym dba_hist_reports;
drop view dba_hist_reports;

drop public synonym dba_hist_reports_details;
drop view dba_hist_reports_details;

drop public synonym DBA_HIST_REPORTS_TIMEBANDS;
drop view DBA_HIST_REPORTS_TIMEBANDS;

drop public synonym DBA_HIST_REPORTS_CONTROL;
drop view DBA_HIST_REPORTS_CONTROL;

drop public synonym GV$SYS_REPORT_STATS;
drop view GV_$SYS_REPORT_STATS;

drop public synonym V$SYS_REPORT_STATS;
drop view V_$SYS_REPORT_STATS;

drop public synonym GV$SYS_REPORT_REQUESTS;
drop view GV_$SYS_REPORT_REQUESTS;

drop public synonym V$SYS_REPORT_REQUESTS;
drop view V_$SYS_REPORT_REQUESTS;

-- truncate the new table wrh$_sess_sga_stats, wrh$_replication_tbl_stats and
-- wrh$_replication_txn_stats
truncate table wrh$_sess_sga_stats;
truncate table wrh$_replication_tbl_stats;
truncate table wrh$_replication_txn_stats;
 
-- drop the new views 
drop view dba_hist_sess_sga_stats;
drop public synonym DBA_HIST_SESS_SGA_STATS;
drop view dba_hist_capture;
drop public synonym DBA_HIST_CAPTURE;
drop view dba_hist_apply_summary;
drop public synonym DBA_HIST_APPLY_SUMMARY;
drop view dba_hist_replication_tbl_stats;
drop public synonym DBA_HIST_REPLICATION_TBL_STATS;
drop view dba_hist_replication_txn_stats;
drop public synonym DBA_HIST_REPLICATION_TXN_STATS;

Rem ****************************************************************
Rem * Clear "CDB cleanup required" flag
Rem ****************************************************************
BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    '   SET status_flag = status_flag - 4 ' ||
                    ' WHERE bitand(status_flag, 4) = 0 ' ||
                    '   AND dbid != (SELECT dbid FROM v$database)';
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

Rem ===========================================================================
Rem Begin Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

-- Move ref counts back into WRH$_SQLTEXT
MERGE
/*+ FULL(@"SEL$F5BB74E1" "WRI$_SQLTEXT_REFCOUNT"@"SEL$2") */ 
INTO WRH$_SQLTEXT S
USING (SELECT DBID, SQL_ID, CON_DBID, REF_COUNT FROM WRI$_SQLTEXT_REFCOUNT) R
ON (R.DBID (+) = S.DBID AND R.SQL_ID (+) = S.SQL_ID AND
     R.CON_DBID (+) = S.CON_DBID)
WHEN MATCHED THEN UPDATE
  SET S.REF_COUNT = nvl(R.REF_COUNT, 0);

commit;

TRUNCATE TABLE WRI$_SQLTEXT_REFCOUNT
/

Rem ===========================================================================
Rem End Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

Rem=================
Rem AWR Changes End
Rem=================

Rem===================
Rem ADR Changes Begin
Rem===================

@@drpadrvw.sql

Rem=================
Rem ADR Changes End
Rem=================


Rem*************************************************************************
Rem BEGIN 11.2 Changes for LogMiner
Rem*************************************************************************

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

     /* downgrade for tianli_bug-8733323: clear new bit */
     /* add downgrade for abrown_bug-9501098. clear another new bit. */
     /* Note: 4294967199 == FFFFFF9F */

     update system.logmnrc_gtlo
     set LogmnrTLOFlags = bitand(LogmnrTLOFlags, 4294967199)
     where bitand(32,LogmnrTLOFlags) = 32 or bitand(64,LogmnrTLOFlags) = 64;
     commit;

     /* downgrade for ID KEY supplemental logging : clear new bit */
     update sys.tab$
     set trigflag = trigflag - 512
     where bitand(512,trigflag) = 512;
     commit;

     /* downgrade for sessionFlags2 */
     update system.logmnr_session$
     set spare1 = null;
     commit;

  END IF;
END;
/ 

drop view logstdby_support_tab_11_2b;
drop view logstdby_unsupport_tab_11_2b;

truncate table SYSTEM.logmnr_integrated_spill$;

drop procedure sys.logmnr_rmt_bld;
drop trigger sys.logmnrggc_trigger;
drop procedure sys.logmnr_ddl_trigger_proc;
drop function system.logmnr_get_gt_protocol;


Rem =======================================================================
Rem  End 11.2 Changes for LogMiner
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for ADR
Rem =======================================================================

drop package DBMS_ADR_INTERNAL;
drop package DBMS_SQADM_SYSCALLS;
drop public synonym dbms_adr;
drop package body sys.dbms_adr;
drop package sys.dbms_adr;
drop library dbms_adr_lib;

Rem =======================================================================
Rem  End Changes for ADR
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for DBMS_ADR_APP
Rem =======================================================================

drop public synonym dbms_adr_app;
drop package body sys.dbms_adr_app;
drop package sys.dbms_adr_app;
drop library dbms_adri_lib;

Rem =======================================================================
Rem  End Changes for DBMS_ADR_APP
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for ADR Objects
Rem =======================================================================

drop public synonym adr_log_msg_t;
drop public synonym adr_log_msg_errid_t;
drop public synonym adr_log_msg_ecid_t;
drop public synonym adr_log_msg_args_t;
drop public synonym adr_log_msg_arg_t;
drop public synonym adr_log_msg_suppl_attrs_t;
drop public synonym adr_log_msg_suppl_attr_t;
drop public synonym adr_incident_t;
drop public synonym adr_incident_files_t;
drop public synonym adr_incident_corr_keys_t;
drop public synonym adr_incident_err_args_t;
drop public synonym adr_home_t;

drop type sys.adr_log_msg_t force;
drop type sys.adr_msg_template_t force;
drop type sys.adr_log_msg_errid_t force;
drop type sys.adr_log_msg_ecid_t force;
drop type sys.adr_log_msg_args_t force;
drop type sys.adr_log_msg_arg_t force;
drop type sys.adr_log_msg_suppl_attrs_t force;
drop type sys.adr_log_msg_suppl_attr_t force;
drop type sys.adr_incident_t force;
drop type sys.adr_incident_info_t force;
drop type sys.adr_incident_files_t force;
drop type sys.adr_incident_file_t force;
drop type sys.adr_incident_corr_keys_t force;
drop type sys.adr_incident_corr_key_t force;
drop type sys.adr_incident_err_args_t force;
drop type sys.adr_home_t force;

Rem =======================================================================
Rem  End Changes for ADR Objects
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

  delete from system.logstdby$skip
    where statement_opt = '_UNSUPPORTED_OVERRIDE';
  commit;

  END IF;
END;
/ 

UPDATE system.logstdby$events SET con_name = NULL;
COMMIT;

DROP SEQUENCE SYSLSBY_EDS_DDL_SEQ;
DROP TRIGGER SYSLSBY_EDS_DDL_TRIG;

Rem =======================================================================
Rem  End Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for XStream/Streams
Rem =======================================================================
Rem
Rem !!! Be sure to protect any dml/truncate table statements with 
Rem the previous version checks !!!

drop view "_DBA_STREAMS_UNSUPPORTED_12_1";
drop view "_DBA_STREAMS_NEWLY_SUPTED_12_1";

Rem Drop Views and Packages
drop view DBA_STREAMS_TRANSFORMATIONS;
drop public synonym DBA_STREAMS_TRANSFORMATIONS;
drop view USER_STREAMS_TRANSFORMATIONS;
drop public synonym USER_STREAMS_TRANSFORMATIONS;
drop view ALL_STREAMS_TRANSFORMATIONS;
drop public synonym ALL_STREAMS_TRANSFORMATIONS;
drop view DBA_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym DBA_ATTRIBUTE_TRANSFORMATIONS;
drop view USER_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym USER_ATTRIBUTE_TRANSFORMATIONS;
drop view ALL_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym ALL_ATTRIBUTE_TRANSFORMATIONS;
drop view ALL_STREAMS_KEEP_COLUMNS;
drop public synonym ALL_STREAMS_KEEP_COLUMNS;
drop view ALL_APPLY_INSTANTIATED_OBJECTS;
drop public synonym ALL_APPLY_INSTANTIATED_OBJECTS;
drop view ALL_APPLY_INSTANTIATED_SCHEMAS;
drop public synonym ALL_APPLY_INSTANTIATED_SCHEMAS;
drop view ALL_APPLY_INSTANTIATED_GLOBAL;
drop public synonym ALL_APPLY_INSTANTIATED_GLOBAL;
drop view ALL_APPLY_SPILL_TXN;
drop public synonym ALL_APPLY_SPILL_TXN;
drop view all_comparison_scan_summary;
drop public synonym all_comparison_scan_summary;
drop view ALL_XSTREAM_ADMINISTRATOR;
drop public synonym ALL_XSTREAM_ADMINISTRATOR;

drop view all_xstream_out_support_mode;
drop public synonym all_xstream_out_support_mode;
drop view dba_xstream_out_support_mode;
drop public synonym dba_xstream_out_support_mode;

drop view dba_goldengate_support_mode;
drop public synonym dba_goldengate_support_mode;

drop public synonym ALL_APPLY_DML_CONF_HANDLERS;
drop view ALL_APPLY_DML_CONF_HANDLERS;
drop public synonym DBA_APPLY_DML_CONF_HANDLERS;
drop view DBA_APPLY_DML_CONF_HANDLERS;
drop view "_DBA_APPLY_DML_CONF_HANDLERS";

Rem xstream conflict handler columns
drop public synonym ALL_APPLY_DML_CONF_COLUMNS;
drop view ALL_APPLY_DML_CONF_COLUMNS;
drop public synonym DBA_APPLY_DML_CONF_COLUMNS;
drop view DBA_APPLY_DML_CONF_COLUMNS;
drop view "_DBA_APPLY_DML_CONF_COLUMNS";

Rem xstream collision handlers
drop public synonym ALL_APPLY_HANDLE_COLLISIONS;
drop view ALL_APPLY_HANDLE_COLLISIONS;
drop public synonym DBA_APPLY_HANDLE_COLLISIONS;
drop view DBA_APPLY_HANDLE_COLLISIONS;
drop view "_DBA_APPLY_HANDLE_COLLISIONS";

Rem xstream collision handlers
drop public synonym ALL_APPLY_REPERROR_HANDLERS;
drop view ALL_APPLY_REPERROR_HANDLERS;
drop public synonym DBA_APPLY_REPERROR_HANDLERS;
drop view DBA_APPLY_REPERROR_HANDLERS;
drop view "_DBA_APPLY_REPERROR_HANDLERS";

Rem USER_APPLY_ERROR view
drop public synonym USER_APPLY_ERROR;
drop view USER_APPLY_ERROR;
drop public synonym DBA_APPLY_ERROR_MESSAGES;
drop view DBA_APPLY_ERROR_MESSAGES;
drop public synonym ALL_APPLY_ERROR_MESSAGES;
drop view ALL_APPLY_ERROR_MESSAGES;

drop public synonym GV$XSTREAM_TABLE_STATS;
drop view GV_$XSTREAM_TABLE_STATS;
drop public synonym V$XSTREAM_TABLE_STATS;
drop view V_$XSTREAM_TABLE_STATS;
drop view "_DBA_APPLY_TABLE_STATS";

drop public synonym GV$GOLDENGATE_TABLE_STATS;
drop view GV_$GOLDENGATE_TABLE_STATS;
drop public synonym V$GOLDENGATE_TABLE_STATS;
drop view V_$GOLDENGATE_TABLE_STATS;

drop view ALL_GOLDENGATE_PRIVILEGES;
drop public synonym ALL_GOLDENGATE_PRIVILEGES;
drop public synonym dba_goldengate_privileges;
drop public synonym user_goldengate_privileges;
drop view dba_goldengate_privileges;
drop view user_goldengate_privileges;

Rem Drop DBA_XSTREAM_OUTBOUND because in 11.2.0.2 this view refers to
Rem gv$xstream_outbound_server, which is not available in 11.2.0.1.
drop view DBA_XSTREAM_OUTBOUND;

drop view "_DBA_XSTREAM_OUTBOUND";
drop view "_DBA_XSTREAM_CONNECTION";

drop public synonym V$XSTREAM_OUTBOUND_SERVER;
drop view V_$XSTREAM_OUTBOUND_SERVER;
drop public synonym GV$XSTREAM_OUTBOUND_SERVER;
drop view GV_$XSTREAM_OUTBOUND_SERVER;

drop view "_DBA_APPLY_COORDINATOR_STATS";
drop view "_DBA_APPLY_SERVER_STATS";
drop view "_DBA_APPLY_READER_STATS";
drop view "_DBA_APPLY_BATCH_SQL_STATS";

drop public synonym gv$xstream_capture;
drop view gv_$xstream_capture;
drop public synonym v$xstream_capture;
drop view v_$xstream_capture;

drop public synonym gv$goldengate_capture;
drop view gv_$goldengate_capture;
drop public synonym v$goldengate_capture;
drop view v_$goldengate_capture;

drop public synonym gv$xstream_transaction;
drop view gv_$xstream_transaction;
drop public synonym v$xstream_transaction;
drop view v_$xstream_transaction;

drop public synonym gv$goldengate_transaction;
drop view gv_$goldengate_transaction;
drop public synonym v$goldengate_transaction;
drop view v_$goldengate_transaction;

drop public synonym gv$flashfilestat;
drop view gv_$flashfilestat;
drop public synonym v$flashfilestat;
drop view v_$flashfilestat;

drop public synonym gv$xstream_message_tracking;
drop view gv_$xstream_message_tracking;
drop public synonym v$xstream_message_tracking;
drop view v_$xstream_message_tracking;

drop public synonym gv$goldengate_message_tracking;
drop view gv_$goldengate_messagetracking;
drop public synonym v$goldengate_message_tracking;
drop view v_$goldengate_message_tracking;

drop public synonym gv$xstream_apply_coordinator;
drop view gv_$xstream_apply_coordinator;
drop public synonym v$xstream_apply_coordinator;
drop view v_$xstream_apply_coordinator;

drop public synonym gv$xstream_apply_reader;
drop view gv_$xstream_apply_reader;
drop public synonym v$xstream_apply_reader;
drop view v_$xstream_apply_reader;

drop public synonym gv$xstream_apply_server;
drop view gv_$xstream_apply_server;
drop public synonym v$xstream_apply_server;
drop view v_$xstream_apply_server;

drop public synonym gv$xstream_apply_receiver;
drop view gv_$xstream_apply_receiver;
drop public synonym v$xstream_apply_receiver;
drop view v_$xstream_apply_receiver;

drop public synonym gv$gg_apply_coordinator;
drop view gv_$gg_apply_coordinator;
drop public synonym v$gg_apply_coordinator;
drop view v_$gg_apply_coordinator;

drop public synonym gv$gg_apply_reader;
drop view gv_$gg_apply_reader;
drop public synonym v$gg_apply_reader;
drop view v_$gg_apply_reader;

drop public synonym gv$gg_apply_server;
drop view gv_$gg_apply_server;
drop public synonym v$gg_apply_server;
drop view v_$gg_apply_server;

drop public synonym gv$gg_apply_receiver;
drop view gv_$gg_apply_receiver;
drop public synonym v$gg_apply_receiver;
drop view v_$gg_apply_receiver;

drop view dba_goldengate_inbound;
drop public synonym dba_goldengate_inbound;
drop view all_goldengate_inbound;
drop public synonym all_goldengate_inbound;

drop view dba_gg_inbound_progress;
drop public synonym dba_gg_inbound_progress;
drop view all_gg_inbound_progress;
drop public synonym all_gg_inbound_progress;

drop view dba_xstream_stmt_handlers;
drop public synonym dba_xstream_stmt_handlers;
drop view dba_xstream_stmts;
drop public synonym dba_xstream_stmts;
drop view dba_xstream_transformations;
drop public synonym dba_xstream_transformations;
drop view all_xstream_transformations;
drop public synonym all_xstream_transformations;

drop view dba_xstream_split_merge;
drop public synonym dba_xstream_split_merge;
drop view dba_xstream_split_merge_hist;
drop public synonym dba_xstream_split_merge_hist;

drop view dba_goldengate_rules;
drop public synonym dba_goldengate_rules;
drop view all_goldengate_rules;
drop public synonym all_goldengate_rules;

drop view dba_xstream_transformation;
drop public synonym dba_xstream_transformation;
drop view all_xstream_transformation;
drop public synonym all_xstream_transformation;

drop package dbms_xstream_utl_ivk;
drop package dbms_xstream_adm_internal;
drop package dbms_xstream_gg;
drop package dbms_xstream_gg_internal;
drop package dbms_xstream_auth;
drop PUBLIC SYNONYM dbms_xstream_gg; 
drop PUBLIC SYNONYM dbms_xstream_auth; 

drop public synonym dbms_xstream_gg_adm;
drop public synonym dbms_goldengate_auth;
drop package dbms_xstream_gg_adm;
drop package dbms_goldengate_auth;
drop package dbms_apply_adm_internal;
 
drop view "_DBA_STREAMS_RULES_H2";
drop view "_DBA_SXGG_TRANSFORMATIONS";
drop view "_DBA_SXGG_SPLIT_MERGE";
drop view "_DBA_SXGG_SPLIT_MERGE_HIST";
drop view "_SXGG_DBA_CAPTURE";
drop public synonym "_DBA_GGXSTREAM_OUTBOUND";
drop view "_DBA_GGXSTREAM_OUTBOUND";
drop public synonym "_DBA_GGXSTREAM_INBOUND";
drop view "_DBA_GGXSTREAM_INBOUND";
drop view "_V$SXGG_CAPTURE";
drop public synonym "_V$SXGG_CAPTURE";
drop view "_GV$SXGG_CAPTURE";
drop public synonym "_GV$SXGG_CAPTURE";
drop view "_V$SXGG_APPLY_COORDINATOR";
drop public synonym "_V$SXGG_APPLY_COORDINATOR";
drop view "_GV$SXGG_APPLY_COORDINATOR";
drop public synonym "_GV$SXGG_APPLY_COORDINATOR";
drop view "_V$SXGG_APPLY_SERVER";
drop public synonym "_V$SXGG_APPLY_SERVER";
drop view "_GV$SXGG_APPLY_SERVER";
drop public synonym "_GV$SXGG_APPLY_SERVER";
drop view "_V$SXGG_APPLY_READER";
drop public synonym "_V$SXGG_APPLY_READER";
drop view "_GV$SXGG_APPLY_READER";
drop public synonym "_GV$SXGG_APPLY_READER";
drop view "_V$SXGG_TRANSACTION";
drop public synonym "_V$SXGG_TRANSACTION";
drop view "_GV$SXGG_TRANSACTION";
drop public synonym "_GV$SXGG_TRANSACTION";
drop view "_V$SXGG_MESSAGE_TRACKING";
drop public synonym "_V$SXGG_MESSAGE_TRACKING";
drop view "_GV$SXGG_MESSAGE_TRACKING";
drop public synonym "_GV$SXGG_MESSAGE_TRACKING";
drop view DBA_CAPTURE;
drop public synonym DBA_CAPTURE;

drop view "_DBA_STREAMS_COMPONENT_PROP";
drop public synonym "_DBA_STREAMS_COMPONENT_PROP";
drop view "_DBA_STREAMS_COMPONENT_STAT";
drop public synonym "_DBA_STREAMS_COMPONENT_STAT";
drop view "_DBA_STREAMS_COMPONENT_EVENT";
drop public synonym "_DBA_STREAMS_COMPONENT_EVENT";


Rem Changes to DDL LCR
alter type lcr$_ddl_record drop member function
   get_root_name return varchar2 cascade;

alter type lcr$_ddl_record drop member procedure set_root_name(
        self in out nocopy lcr$_ddl_record, 
        root_name       IN VARCHAR2) cascade;

alter type lcr$_ddl_record drop STATIC FUNCTION construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     object_type                in varchar2,
     ddl_text                   in clob,
     logon_user                 in varchar2,
     current_schema             in varchar2,
     base_table_owner           in varchar2,
     base_table_name            in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     position                   in raw               DEFAULT NULL,
     edition_name               in varchar2          DEFAULT NULL,
     current_user               in varchar2          DEFAULT NULL,
     root_name                  in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

Rem Changes to Procedure LCR
alter type lcr$_procedure_record drop 
  MEMBER FUNCTION get_compatible RETURN NUMBER cascade;

alter type lcr$_procedure_record drop 
   MEMBER FUNCTION get_source_time RETURN DATE cascade;

alter type lcr$_procedure_record drop 
   MEMBER FUNCTION get_thread_number RETURN NUMBER cascade;

alter type lcr$_procedure_record drop 
   MEMBER FUNCTION get_position RETURN RAW cascade;

alter type lcr$_procedure_record drop 
  MEMBER FUNCTION get_tag RETURN RAW cascade;

alter type lcr$_procedure_record drop 
  MEMBER FUNCTION is_null_tag  RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record drop 
MEMBER FUNCTION  get_root_name RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record drop 
MEMBER FUNCTION  get_logon_user RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record drop 
  MEMBER FUNCTION  get_current_user RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record drop 
  MEMBER FUNCTION  get_default_user RETURN VARCHAR2 cascade;

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.3.0' THEN
    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' || 
     'add STATIC FUNCTION construct(' || 
     '  source_database_name       in varchar2,' || 
     '  command_type               in varchar2,' || 
     '  object_owner               in varchar2,' || 
     '  object_name                in varchar2,' || 
     '  object_type                in varchar2,' || 
     '  ddl_text                   in clob,' || 
     '  logon_user                 in varchar2,' || 
     '  current_schema             in varchar2,' || 
     '  base_table_owner           in varchar2,' || 
     '  base_table_name            in varchar2,' || 
     '  tag                        in raw               DEFAULT NULL,' || 
     '  transaction_id             in varchar2          DEFAULT NULL,' || 
     '  scn                        in number            DEFAULT NULL,' || 
     '  position                   in raw               DEFAULT NULL,' || 
     '  edition_name               in varchar2          DEFAULT NULL' || 
     ')' || 
   '  RETURN lcr$_ddl_record cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' ||
      'drop MEMBER FUNCTION get_current_user RETURN varchar2 cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record '|| 
      'drop MEMBER PROCEDURE set_current_user '||
      '(self in out nocopy lcr$_ddl_record, current_user IN VARCHAR2) cascade';

  ELSE
    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' || 
     'add STATIC FUNCTION construct(' || 
     '  source_database_name       in varchar2,' || 
     '  command_type               in varchar2,' || 
     '  object_owner               in varchar2,' || 
     '  object_name                in varchar2,' || 
     '  object_type                in varchar2,' || 
     '  ddl_text                   in clob,' || 
     '  logon_user                 in varchar2,' || 
     '  current_schema             in varchar2,' || 
     '  base_table_owner           in varchar2,' || 
     '  base_table_name            in varchar2,' || 
     '  tag                        in raw               DEFAULT NULL,' || 
     '  transaction_id             in varchar2          DEFAULT NULL,' || 
     '  scn                        in number            DEFAULT NULL,' || 
     '  position                   in raw               DEFAULT NULL,' || 
     '  edition_name               in varchar2          DEFAULT NULL,' || 
     '  current_user               in varchar2          DEFAULT NULL' ||
     ')' || 
   '  RETURN lcr$_ddl_record cascade';
  END IF;
END;
/

Rem Changes to Row LCR 
alter type lcr$_row_record drop member function
   get_root_name return varchar2 cascade;

alter type lcr$_row_record drop member procedure set_root_name(
        self in out nocopy lcr$_row_record, 
        root_name       IN VARCHAR2) cascade;

alter type lcr$_row_record drop static function construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL,
     position                   in raw               DEFAULT NULL,
     statement                  in varchar2          DEFAULT NULL,
     bind_variables             in sys.lcr$_row_list DEFAULT NULL,
     bind_by_position           in varchar2          DEFAULT 'N',
     root_name                  in varchar2          DEFAULT NULL
   )  RETURN lcr$_row_record cascade;

update streams$_apply_milestone set source_db_name = source_root_name; 
update streams$_capture_process set source_dbname = source_root_name; 
update streams$_rules set source_database = source_root_name; 

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.2.0' THEN

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'is_statement_lcr return varchar2 cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop  member procedure '||
       'set_row_text(self in out nocopy lcr$_row_record, '||
       '             row_text           IN CLOB, '||
       '             variable_list IN sys.lcr$_row_list DEFAULT NULL, '||
       '             bind_by_position in varchar2 DEFAULT ''N'') cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record '||
     'add static function construct('||
     '  source_database_name       in varchar2,'||
     '  command_type               in varchar2,'||
     '  object_owner               in varchar2,'||
     '  object_name                in varchar2,'||
     '  tag                        in raw               DEFAULT NULL,'||
     '  transaction_id             in varchar2          DEFAULT NULL,'||
     '  scn                        in number            DEFAULT NULL,'||
     '  old_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  new_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  position                   in raw               DEFAULT NULL'||
     ')  RETURN lcr$_row_record cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'get_base_object_id return number cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'get_object_id return number cascade';

  ELSE
    EXECUTE IMMEDIATE 'alter type lcr$_row_record '||
     'add static function construct('||
     '  source_database_name       in varchar2,'||
     '  command_type               in varchar2,'||
     '  object_owner               in varchar2,'||
     '  object_name                in varchar2,'||
     '  tag                        in raw               DEFAULT NULL,'||
     '  transaction_id             in varchar2          DEFAULT NULL,'||
     '  scn                        in number            DEFAULT NULL,'||
     '  old_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  new_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  position                   in raw               DEFAULT NULL,'||
     '  statement                  in varchar2          DEFAULT NULL,'||
     '  bind_variables             in sys.lcr$_row_list DEFAULT NULL,'||
     '  bind_by_position           in varchar2          DEFAULT ''N'''||
     ')  RETURN lcr$_row_record cascade';

  END IF;
END;
/ 

DECLARE
  previous_version varchar2(30);
  -- the variables used for copying xstream$_privileges
  user_names_xs     dbms_sql.varchar2s;
  cnt               NUMBER;
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.3.0' THEN

    -- Copy xstream users from xstream$_privileges to streams$_privileged_user
    BEGIN
      SELECT xp.username
      BULK COLLECT INTO user_names_xs
      FROM sys.xstream$_privileges xp;

      FOR i IN 1 .. user_names_xs.count 
      LOOP 
        -- insert into streams$_privileged_user
        SELECT count(*) into cnt 
          FROM sys.streams$_privileged_user
          WHERE user# IN
           (SELECT u.user#
            FROM sys.user$ u
            WHERE u.name = user_names_xs(i));

        IF (cnt = 0) THEN
          INSERT INTO sys.streams$_privileged_user(user#, privs, flags)
           SELECT u.user#, 1, 1
            FROM user$ u
            WHERE u.name = user_names_xs(i);
        ELSE
          UPDATE sys.streams$_privileged_user
           SET privs = dbms_logrep_util.bis(privs,
                       dbms_streams_adm_utl.privs_local_offset),
              flags = dbms_logrep_util.bis(0, 1)
          WHERE user# IN
           (SELECT u.user#
            FROM sys.user$ u
            WHERE u.name = user_names_xs(i));
        END IF;
      END LOOP;
    END;
  END IF; -- of 11.2.0.3.0
END;
/
commit;

update sys.streams$_apply_process
  set source_root_name = NULL;
commit;
update sys.streams$_apply_milestone
  set source_root_name = NULL;
commit;
update sys.apply$_source_obj
  set source_root_name = NULL;
commit;
update sys.apply$_source_schema
  set source_root_name = NULL;
commit;
update sys.streams$_capture_process
  set source_root_name = NULL;
commit;
update sys.streams$_rules
  set source_root_name = NULL;
commit;
update streams$_process_params set source_database = NULL; 
commit;

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.4.0' THEN
    update apply$_error 
      set error_pos = NULL,
          start_seq# = NULL,
          end_seq# = NULL,
          start_rba = NULL,
          end_rba = NULL,
          error_seq# = NULL,
          error_rba = NULL,
          error_index# = NULL,
          spare6 = NULL,
          spare7 = NULL,
          spare8 = NULL,
          spare9 = NULL,
          spare10 = NULL,
          spare11 = NULL,
          spare12 = NULL;
    commit;
  
    update apply$_error_txn 
      set seq# = NULL,
          index# = NULL,
          rba = NULL,
          spare7 = NULL,
          spare8 = NULL,
          spare9 = NULL,
          spare10 = NULL,
          spare11 = NULL,
          spare12 = NULL;
    commit;

    update apply$_dest_obj_ops set set_by = NULL;
    commit;
    update xstream$_dml_conflict_handler set set_by = NULL;
    commit;
    update xstream$_reperror_handler set set_by = NULL;
    commit;
    update xstream$_handle_collisions set set_by = NULL;
    commit;

  END IF; -- of 11.2.0.4.0

  IF previous_version < '11.2.0.3.0' THEN
    update sys.streams$_process_params 
      set name = '_MAX_PARALLELISM', internal_flag = 1
      where name = 'MAX_PARALLELISM';

    update sys.streams$_process_params 
      set name = '_EAGER_SIZE', internal_flag = 1 
      where name = 'EAGER_SIZE';

    update xstream$_server set
      connect_user = null;

    update xstream$_server
      set status_change_time = NULL;
  END IF; -- of 11.2.0.3.0

  IF previous_version < '11.2.0.2.0' THEN

    -- Set the new columns to null in older releases
    update  streams$_apply_milestone 
      set spare8 = null, 
          spare9 = null, 
          spare10 = null, 
          spare11 = null,
          eager_error_retry = NULL;

    update sys.streams$_process_params
      set name = '_CMPKEY_ONLY', internal_flag = 1
      where name = 'COMPARE_KEY_ONLY';

    update sys.streams$_process_params
      set name = '_IGNORE_TRANSACTION', internal_flag = 1
      where name = 'IGNORE_TRANSACTION';

    update sys.streams$_process_params
      set name = '_IGNORE_UNSUPERR_TABLE', internal_flag = 1
      where name = 'IGNORE_UNSUPPORTED_TABLE';

    -- Nullify the scn_time fields for lower versions
    update streams$_capture_process 
    set start_scn_time = NULL, first_scn_time = NULL;

    update sys.apply$_error
      set retry_count = NULL,
          flags       = NULL;

     -- Clear uncommitted data flag
    update xstream$_server  
      set flags = flags - 4  where bitand(flags, 4) = 4;

    update streams$_apply_process set
          spare4                      = NULL,
          spare5                      = NULL,
          spare6                      = NULL,
          spare7                      = NULL,
          spare8                      = NULL,
          spare9                      = NULL;

    update streams$_privileged_user set
          flags                       = NULL,
          spare1                      = NULL,
          spare2                      = NULL,
          spare3                      = NULL,
          spare4                      = NULL;
 
    update sys.apply$_error_txn
      set source_object_owner = NULL,
          source_object_name  = NULL,
          dest_object_owner   = NULL,
          dest_object_name    = NULL,
          primary_key         = NULL,
          position            = NULL,
          message_flags       = NULL,
          operation           = NULL;
 
    delete from sys.props$ where name='GG_XSTREAM_FOR_STREAMS';

  END IF; -- of 11.2.0.2.0

END;
/
commit;

Rem DDL changes (drop index, truncate)

Rem Set source_db_name to not null
alter table streams$_apply_milestone
    modify (source_db_name VARCHAR2(128) not null);
drop index i_streams_apply_milestone1;
create unique index i_streams_apply_milestone1 on streams$_apply_milestone
  (apply#, source_db_name);

drop index i_apply_source_obj2;
create unique index i_apply_source_obj2 on apply$_source_obj 
  (owner, name, type, source_db_name, dblink);

drop index i_apply_source_schema1;
create unique index i_apply_source_schema1 on apply$_source_schema 
  (source_db_name, global_flag, name, dblink);

Rem DDLs for changes in patchsets
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.4.0' THEN

    EXECUTE IMMEDIATE 'truncate table apply$_table_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_coordinator_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_server_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_reader_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_batch_sql_stats';

  END IF; -- of 11.2.0.4.0

  IF previous_version < '11.2.0.3.0' THEN

    EXECUTE IMMEDIATE 'truncate table xstream$_dml_conflict_columns';
    EXECUTE IMMEDIATE 'truncate table xstream$_handle_collisions';
    EXECUTE IMMEDIATE 'truncate table xstream$_reperror_handler';
    EXECUTE IMMEDIATE 'truncate table sys.xstream$_privileges';
    EXECUTE IMMEDIATE 'drop index i_xstream_privileges';

  END IF; -- of 11.2.0.3.0

  IF previous_version < '11.2.0.2.0' THEN
    -- xstream parameter changes
    EXECUTE IMMEDIATE 'drop view "_DBA_XSTREAM_PARAMETERS"';
    EXECUTE IMMEDIATE 'truncate table xstream$_parameters';
    EXECUTE IMMEDIATE 'drop index i_xstream_parameters';

    -- xstream dml_conflict_handler
    EXECUTE IMMEDIATE 'truncate table xstream$_dml_conflict_handler';

    EXECUTE IMMEDIATE 'truncate table xstream$_ddl_conflict_handler';
    EXECUTE IMMEDIATE 'truncate table xstream$_map';

    EXECUTE IMMEDIATE 'truncate table xstream$_server_connection';


    EXECUTE IMMEDIATE 'truncate table sys.goldengate$_privileges';
  END IF; -- of 11.2.0.2.0
END;
/

UPDATE streams$_prepare_ddl SET allpdbs = NULL, c_invoker = NULL;
COMMIT;


declare
 oldflag number;
 CURSOR all_apply IS 
   select apply#, flags from sys.streams$_apply_milestone;
begin
 FOR app IN all_apply 
 LOOP
   oldflag := 0;
   /* Pass on used flag KNALA_PTO_USED -> KNAPROCFPTOUSED */
   IF (bitand(app.flags, 1) = 1) THEN
     oldflag := 8192;
     /* Pass on recovered flag KNALA_PTO_RECOVERED -> KNAPROCFPTRDONE */
     IF (bitand(app.flags, 2) = 2) THEN
       oldflag := oldflag + 2048;
     END IF;
   END IF;
   IF (oldflag <> 0) THEN
       update sys.streams$_apply_process set flags = flags + oldflag 
       where apply# = app.apply#;
   END IF;
   /* Not clearing the milestone flags for debugging purpose */
 END LOOP; 
 COMMIT;
  
end;
/

truncate table repl$_dbname_mapping;
drop view dba_repl_dbname_mapping;
drop public synonym dba_repl_dbname_mapping;
drop view all_repl_dbname_mapping;
drop public synonym all_repl_dbname_mapping;

Rem Remove Replication Bundle row from sys.props$
BEGIN
  EXECUTE IMMEDIATE 'delete from sys.props$ where NAME='''||
  'REPLICATION_BUNDLE''';
END;
/

/* Long Identifier missed downgrade actions for Streams/Xstream*/

alter table apply$_error_txn modify(source_object_owner varchar2(30));
alter table apply$_error_txn modify(source_object_name varchar2(30));
alter table apply$_error_txn modify(dest_object_owner varchar2(30));
alter table apply$_error_txn modify(dest_object_name varchar2(30));

-- This table is created in c110200.sql.
alter table apply$_table_stats modify(source_table_owner varchar2(30));
alter table apply$_table_stats modify(source_table_name varchar2(30));
alter table apply$_table_stats modify(destination_table_owner varchar2(30));
alter table apply$_table_stats modify(destination_table_name varchar2(30));

-- This table is created in c110200.sql.
alter table apply$_coordinator_stats modify(apply_name varchar2(30));
alter table apply$_coordinator_stats modify(replname varchar2(30));

-- This table is created in c110200.sql.
alter table apply$_server_stats modify(apply_name varchar2(30));
-- This table is created in c110200.sql.
alter table apply$_reader_stats modify(apply_name varchar2(30));

alter table streams$_database modify(management_pack_access varchar2(30));

-- This column is added in c1102000.sql.
update xstream$_server set connect_user = null;

-- Table created in c110200.sql and these columns were added in 11.2.0.3.
alter table xstream$_dml_conflict_handler modify(conflict_handler_name varchar2(30));
alter table xstream$_dml_conflict_handler modify(resolution_column varchar2(30));

-- This table is created in c110200.sql.
alter table xstream$_dml_conflict_columns modify(column_name varchar2(30));

-- This table is created in c110200.sql.
alter table xstream$_reperror_handler modify(apply_name varchar2(30));
alter table xstream$_reperror_handler modify(schema_name varchar2(30));
alter table xstream$_reperror_handler modify(table_name varchar2(30));
alter table xstream$_reperror_handler modify(source_schema_name varchar2(30));
alter table xstream$_reperror_handler modify(source_table_name varchar2(30));

-- This table is created in c110200.sql.
alter table xstream$_handle_collisions modify(apply_name varchar2(30));
alter table xstream$_handle_collisions modify(schema_name varchar2(30));
alter table xstream$_handle_collisions modify(table_name varchar2(30));
alter table xstream$_handle_collisions modify(source_schema_name varchar2(30));
alter table xstream$_handle_collisions modify(source_table_name varchar2(30));


alter table repl$_dbname_mapping modify (source_container_name varchar2(30));


Rem =======================================================================
Rem  End Changes for XStream/Streams
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for Service
Rem*************************************************************************

Rem remove the edition column
update service$ set edition = null;
commit;

Rem =======================================================================
Rem  End Changes for Service
Rem =======================================================================

Rem truncate sqlerroror$
truncate table sqlerror$;

Rem =======================================================================
Rem  Bug #5842629 : direct path load and direct path export
Rem =======================================================================
delete from STMT_AUDIT_OPTION_MAP where option# = 330;
delete from STMT_AUDIT_OPTION_MAP where option# = 331;
Rem =======================================================================
Rem  End Changes for Bug #5842629
Rem =======================================================================  

Rem =======================================================================
Rem  Project 32008: remove ADMINISTER KEY MANAGEMENT audit option and 
Rem  system privilege
Rem =======================================================================
delete from STMT_AUDIT_OPTION_MAP where option# = 343;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -343;
delete from SYSAUTH$ where privilege# = -343; 

Rem =======================================================================
Rem  End Changes for project 32008
Rem =======================================================================  

Rem =======================================================================
Rem  Project 26121 DB Consolidation: remove PDB audit option and 
Rem  system privilege
Rem =======================================================================
delete from STMT_AUDIT_OPTION_MAP where option# in (375, 377);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-375, -377);
delete from SYSAUTH$ where privilege# in (-375, -377);

Rem =======================================================================
Rem  End Changes for project 26121
Rem ======================================================================= 



Rem =======================================================================
Rem  Begin Changes for Database Replay
Rem =======================================================================
Rem
Rem NULL out columns added for STS tracking
Rem
Rem wrr$_captures
update WRR$_CAPTURES set sqlset_owner = NULL, sqlset_name = NULL;
Rem wrr$_replays
update WRR$_REPLAYS 
set sqlset_owner = NULL, sqlset_name = NULL, 
    sqlset_cap_interval = NULL,
    filter_set_name = NULL,
    num_admins = NULL,
    schedule_name = NULL;

Rem
Rem Delete entries related to consolidated replay
Rem
delete from WRR$_REPLAY_DIVERGENCE where file_id <> cap_file_id;
delete from WRR$_REPLAY_SQL_BINDS where file_id <> cap_file_id;

Rem
Rem Update the remaining entries which correspond to non-consolidated replays
Rem
update WRR$_REPLAY_DIVERGENCE set cap_file_id = NULL;
update WRR$_REPLAY_SQL_BINDS  set cap_file_id = NULL;

Rem
Rem Drop this column since the table was introduced at 11.2.0.1
Rem      and the column was added at 11.2.0.2
Rem
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version LIKE '11.2.0.1%' THEN
    execute immediate 'alter table WRR$_REPLAY_FILTER_SET drop column default_action';
  END IF;
END;
/
commit;

Rem
Rem truncate attributes table
Rem
truncate table wrr$_workload_attributes;

Rem truncate wrr$_asreplay_data for AS Replays
truncate table wrr$_asreplay_data;

Rem truncate user map and related views
truncate table wrr$_user_map;
drop view dba_workload_user_map;
drop public synonym dba_workload_user_map;
drop view dba_workload_active_user_map;
drop public synonym dba_workload_active_user_map;

Rem
Rem Truncate tables used for workload intelligence.
Rem To avoid ORA-02266, first disable the relevant constraints, then truncate,
Rem and finally enable the constraints again.
Rem
alter table WI$_TEMPLATE disable constraint WI$_TEMPLATE_FK1;
alter table WI$_STATEMENT disable constraint WI$_STATEMENT_FK1;
alter table WI$_OBJECT disable constraint WI$_OBJECT_FK1;
alter table WI$_CAPTURE_FILE disable constraint WI$_CAPTURE_FILE_FK1;
alter table WI$_EXECUTION_ORDER disable constraint WI$_EXECUTION_ORDER_FK1;
alter table WI$_EXECUTION_ORDER disable constraint WI$_EXECUTION_ORDER_FK2;
alter table WI$_FREQUENT_PATTERN disable constraint WI$_FREQUENT_PATTERN_FK1;
alter table WI$_FREQUENT_PATTERN_ITEM
  disable constraint WI$_FREQUENT_PATTERN_ITEM_FK1;
alter table WI$_FREQUENT_PATTERN_ITEM
  disable constraint WI$_FREQUENT_PATTERN_ITEM_FK2;
alter table WI$_FREQUENT_PATTERN_METADATA
  disable constraint WI$_FREQ_PATTERN_METADATA_FK1;

truncate table WI$_FREQUENT_PATTERN_METADATA;
truncate table WI$_FREQUENT_PATTERN_ITEM;
truncate table WI$_FREQUENT_PATTERN;
truncate table WI$_EXECUTION_ORDER;
truncate table WI$_CAPTURE_FILE;
truncate table WI$_OBJECT;
truncate table WI$_STATEMENT;
truncate table WI$_TEMPLATE;
truncate table WI$_JOB;

alter table WI$_TEMPLATE enable constraint WI$_TEMPLATE_FK1;
alter table WI$_STATEMENT enable constraint WI$_STATEMENT_FK1;
alter table WI$_OBJECT enable constraint WI$_OBJECT_FK1;
alter table WI$_CAPTURE_FILE enable constraint WI$_CAPTURE_FILE_FK1;
alter table WI$_EXECUTION_ORDER enable constraint WI$_EXECUTION_ORDER_FK1;
alter table WI$_EXECUTION_ORDER enable constraint WI$_EXECUTION_ORDER_FK2;
alter table WI$_FREQUENT_PATTERN enable constraint WI$_FREQUENT_PATTERN_FK1;
alter table WI$_FREQUENT_PATTERN_ITEM
  enable constraint WI$_FREQUENT_PATTERN_ITEM_FK1;
alter table WI$_FREQUENT_PATTERN_ITEM
  enable constraint WI$_FREQUENT_PATTERN_ITEM_FK2;
alter table WI$_FREQUENT_PATTERN_METADATA
  enable constraint WI$_FREQ_PATTERN_METADATA_FK1;

Rem
Rem Drop sequences used for workload intelligence
Rem
drop sequence WI$_JOB_ID;

Rem
Rem Drop views and the corresponding synonyms related to workload intelligence
Rem
drop view DBA_WI_JOBS;
drop public synonym DBA_WI_JOBS;
drop view DBA_WI_TEMPLATES;
drop public synonym DBA_WI_TEMPLATES;
drop view DBA_WI_STATEMENTS;
drop public synonym DBA_WI_STATEMENTS;
drop view DBA_WI_OBJECTS;
drop public synonym DBA_WI_OBJECTS;
drop view DBA_WI_CAPTURE_FILES;
drop public synonym DBA_WI_CAPTURE_FILES;
drop view DBA_WI_TEMPLATE_EXECUTIONS;
drop public synonym DBA_WI_TEMPLATE_EXECUTIONS;
drop view DBA_WI_PATTERNS;
drop public synonym DBA_WI_PATTERNS;
drop view DBA_WI_PATTERN_ITEMS;
drop public synonym DBA_WI_PATTERN_ITEMS;

Rem =======================================================================
Rem  End Changes for Database Replay
Rem =======================================================================

Rem ==========================
Rem Begin Bug #8862486 changes
Rem ==========================

Rem Directory EXECUTE auditing (action #135)
delete from AUDIT_ACTIONS where action = 135;

Rem ========================
Rem End Bug #8862486 changes
Rem ========================


Rem*************************************************************************
Rem BEGIN Changes for WLM
Rem*************************************************************************
Rem Drop table required due to package dependencies
Rem so that the WLM user, appqossys can be dropped without cascade
Rem specified after all its tables are removed.

drop public synonym wlm_mpa_stream;
drop public synonym wlm_violation_stream;
drop table appqossys.wlm_mpa_stream;
drop table appqossys.wlm_violation_stream;

drop public synonym WLM_CAPABILITY_OBJECT;
drop public synonym WLM_CAPABILITY_ARRAY;
drop type WLM_CAPABILITY_ARRAY force;
drop type WLM_CAPABILITY_OBJECT force;

Rem Drop package due to 16206 assert. Due to dependent fixed objects
Rem are dropped in this downgrade.
drop package dbms_wlm;

Rem =======================================================================
Rem  End Changes for WLM
Rem =======================================================================

Rem ==========================
Rem Begin ALTER USER RENAME changes
Rem ==========================

-- Schema Synonyms got postponed to 12g
-- delete from audit_actions where action in (222, 224);
-- delete from stmt_audit_option_map where option# in (332, 333);

Rem ========================
Rem End ALTER USER RENAME changes
Rem ========================

Rem =======================================================================
Rem  Begin Changes for DML frequency tracking (DFT)
Rem =======================================================================

DROP VIEW v_$object_dml_frequencies;
DROP PUBLIC synonym v$object_dml_frequencies;
DROP VIEW gv_$object_dml_frequencies;
DROP PUBLIC synonym gv$object_dml_frequencies;

Rem =======================================================================
Rem  End Changes for DML frequency tracking (DFT)
Rem =======================================================================

Rem ************************************************************************
Rem Resource Manager related changes - BEGIN
Rem ************************************************************************

DECLARE
previous_version varchar2(30);
ddl varchar2(200);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

    update resource_plan_directive$ set
      max_active_sess_target_p1 = 4294967295;
    update resource_plan_directive$ set
      parallel_queue_timeout = NULL;
    update resource_plan_directive$ set
      parallel_stmt_critical = NULL;
    commit;

    -- Remove all entries with null values.
    -- Undo the change in upgrade to allow null values (see bug #9207475)
    delete from wrh$_rsrc_plan where end_time is null;
    ddl := 'alter table wrh$_rsrc_plan modify (end_time date not null)';

    execute immediate ddl;
  END IF;
END;
/

Rem ************************************************************************
Rem Resource Manager related changes - END
Rem ************************************************************************

Rem**************************************************************************
Rem BEGIN Drop all the views that use X$MODACT_LENGTH
Rem**************************************************************************

drop view DBA_HIST_SQLSTAT;
drop public synonym DBA_HIST_SQLSTAT;

drop view DBA_HIST_ACTIVE_SESS_HISTORY;
drop public synonym DBA_HIST_ACTIVE_SESS_HISTORY;

drop view DBA_WORKLOAD_REPLAY_DIVERGENCE;
drop public synonym DBA_WORKLOAD_REPLAY_DIVERGENCE;

drop view DBA_SQLTUNE_STATISTICS;
drop public synonym DBA_SQLTUNE_STATISTICS;

drop view USER_SQLTUNE_STATISTICS;
drop public synonym USER_SQLTUNE_STATISTICS;

drop view DBA_SQLSET_STATEMENTS;
drop public synonym DBA_SQLSET_STATEMENTS;

drop view USER_SQLSET_STATEMENTS;
drop public synonym USER_SQLSET_STATEMENTS;

drop view ALL_SQLSET_STATEMENTS;
drop public synonym ALL_SQLSET_STATEMENTS;

drop view "_ALL_SQLSET_STATEMENTS_ONLY";
drop public synonym "_ALL_SQLSET_STATEMENTS_ONLY";

drop view "_ALL_SQLSET_STATEMENTS_PHV";
drop public synonym "_ALL_SQLSET_STATEMENTS_PHV";

drop view "_DBA_STREAMS_COMPONENT_EVENT";
drop public synonym "_DBA_STREAMS_COMPONENT_EVENT";

drop view DBA_SQL_PLAN_BASELINES;
drop public synonym DBA_SQL_PLAN_BASELINES;

drop view DBA_ADVISOR_SQLW_STMTS;
drop public synonym DBA_ADVISOR_SQLW_STMTS;

drop view USER_ADVISOR_SQLW_STMTS;
drop public synonym USER_ADVISOR_SQLW_STMTS;

Rem**************************************************************************
Rem END Drop all the views that use X$MODACT_LENGTH
Rem**************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for SPA
Rem*************************************************************************

drop public synonym gv$advisor_current_sqlplan;
drop public synonym v$advisor_current_sqlplan;
drop view gv_$advisor_current_sqlplan;
drop view v_$advisor_current_sqlplan;

Rem =======================================================================
Rem  End Changes for SPA
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for SPA
Rem*************************************************************************

drop package dbms_auto_sqltune;
drop public synonym dbms_auto_sqltune;

Rem*************************************************************************
Rem END Changes for SPA
Rem*************************************************************************


Rem ************************************************************************
Rem TDE Tablespace encrypton related changes - BEGIN
Rem ************************************************************************

drop public synonym v$database_key_info;
drop view v_$database_key_info;
drop public synonym gv$database_key_info;
drop view gv_$database_key_info;

Rem ************************************************************************
Rem TDE Tablespace encrypton related changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Rules engine related changes - BEGIN
Rem ************************************************************************

Rem Bug 8656192: Rule/chain performance improvement.
drop public synonym dbms_rule_internal;
drop package sys.dbms_rule_internal;

Rem ************************************************************************
Rem Rules engine related changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Scheduler/Chains  related changes - BEGIN
Rem ************************************************************************

Rem Bug 8656192: Rule/chain performance improvement
drop type sys.scheduler$_var_value_list FORCE;
drop type sys.scheduler$_variable_value FORCE;

Rem ************************************************************************
Rem Scheduler/Chains  related changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Direct NFS changes - BEGIN
Rem ************************************************************************

drop PUBLIC SYNONYM dbms_dnfs;
drop package dbms_dnfs;

Rem ************************************************************************
Rem Direct NFS changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem ACFS Security and Encryption related changes - BEGIN
Rem ************************************************************************

drop public synonym v$asm_acfs_security_info;
drop view v_$asm_acfs_security_info;
drop public synonym gv$asm_acfs_security_info;
drop view gv_$asm_acfs_security_info;

drop public synonym v$asm_acfs_encryption_info;
drop view v_$asm_acfs_encryption_info;
drop public synonym gv$asm_acfs_encryption_info;
drop view gv_$asm_acfs_encryption_info;

drop public synonym v$asm_acfs_sec_rule;
drop view v_$asm_acfs_sec_rule;
drop public synonym gv$asm_acfs_sec_rule;
drop view gv_$asm_acfs_sec_rule;

drop public synonym v$asm_acfs_sec_realm;
drop view v_$asm_acfs_sec_realm;
drop public synonym gv$asm_acfs_sec_realm;
drop view gv_$asm_acfs_sec_realm;

drop public synonym v$asm_acfs_sec_realm_user;
drop view v_$asm_acfs_sec_realm_user;
drop public synonym gv$asm_acfs_sec_realm_user;
drop view gv_$asm_acfs_sec_realm_user;

drop public synonym v$asm_acfs_sec_realm_group;
drop view v_$asm_acfs_sec_realm_group;
drop public synonym gv$asm_acfs_sec_realm_group;
drop view gv_$asm_acfs_sec_realm_group;

drop public synonym v$asm_acfs_sec_realm_filter;
drop view v_$asm_acfs_sec_realm_filter;
drop public synonym gv$asm_acfs_sec_realm_filter;
drop view gv_$asm_acfs_sec_realm_filter;

drop public synonym v$asm_acfs_sec_ruleset;
drop view v_$asm_acfs_sec_ruleset;
drop public synonym gv$asm_acfs_sec_ruleset;
drop view gv_$asm_acfs_sec_ruleset;

drop public synonym v$asm_acfs_sec_ruleset_rule;
drop view v_$asm_acfs_sec_ruleset_rule;
drop public synonym gv$asm_acfs_sec_ruleset_rule;
drop view gv_$asm_acfs_sec_ruleset_rule;

drop public synonym v$asm_acfs_sec_cmdrule;
drop view v_$asm_acfs_sec_cmdrule;
drop public synonym gv$asm_acfs_sec_cmdrule;
drop view gv_$asm_acfs_sec_cmdrule;

drop public synonym v$asm_acfs_sec_admin;
drop view v_$asm_acfs_sec_admin;
drop public synonym gv$asm_acfs_sec_admin;
drop view gv_$asm_acfs_sec_admin;


Rem ************************************************************************
Rem ACFS Security and Encryption related changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem BEGIN Changes for (G)V$ASM_ACFSREPL
Rem*************************************************************************

drop public synonym v$asm_acfsrepl;
drop view v_$asm_acfsrepl;
drop public synonym gv$asm_acfsrepl;
drop view gv_$asm_acfsrepl;

Rem*************************************************************************
Rem END Changes for (G)V$ASM_ACFSREPL
Rem*************************************************************************

Rem ************************************************************************
Rem BEGIN Changes for (G)V$ASM_ACFSREPLTAG
Rem*************************************************************************

drop public synonym v$asm_acfsrepltag;
drop view v_$asm_acfsrepltag;
drop public synonym gv$asm_acfsrepltag;
drop view gv_$asm_acfsrepltag;

Rem*************************************************************************
Rem END Changes for (G)V$ASM_ACFSREPLTAG
Rem*************************************************************************

Rem=========================================================================
Rem Attribute associations of VPD policies related changes - BEGIN
Rem=========================================================================

truncate table sys.rls_csa$;
/* clear the bit 0x40000 */
update sys.rls$ r set r.stmt_type = r.stmt_type - 262144
  where bitand(r.stmt_type, 262144) = 262144;

drop public synonym DBA_POLICY_ATTRIBUTES;
drop view DBA_POLICY_ATTRIBUTES;

drop public synonym ALL_POLICY_ATTRIBUTES;
drop view ALL_POLICY_ATTRIBUTES;

drop public synonym USER_POLICY_ATTRIBUTES;
drop view USER_POLICY_ATTRIBUTES;
commit;

Rem=========================================================================
Rem Attribute associations of VPD policies related changes - END
Rem=========================================================================

Rem ************************************************************************
Rem Feature Usage tracking for Deferred Seg Creation related changes - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_DEFERRED_SEG_CRT;

Rem ************************************************************************
Rem Feature Usage tracking for Deferred Seg Creation related changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for rman functionality - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_BACKUP_ENCRYPTION;
drop procedure DBMS_FEATURE_RMAN_BACKUP;
drop procedure DBMS_FEATURE_RMAN_DISK_BACKUP;
drop procedure DBMS_FEATURE_RMAN_TAPE_BACKUP;

Rem ************************************************************************
Rem Feature Usage tracking for rman functionality - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for DMU - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_DMU;

Rem ************************************************************************
Rem Feature Usage tracking for DMU - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for QOSM - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_QOSM;

Rem ************************************************************************
Rem Feature Usage tracking for QOSM - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for RACONENODE - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_ROND;

Rem ************************************************************************
Rem Feature Usage tracking for RACONENODE - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for GoldenGate - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_goldengate;
drop public synonym v$goldengate_capabilities;
drop view v_$goldengate_capabilities;
drop public synonym gv$goldengate_capabilities;
drop view gv_$goldengate_capabilities;
drop procedure dbms_feature_streams;
drop procedure dbms_feature_xstream_out;
drop procedure dbms_feature_xstream_in;
drop procedure dbms_feature_xstream_streams;

Rem ************************************************************************
Rem Feature Usage tracking for GoldenGate - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for AUDIT - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_audit_options;
drop procedure dbms_feature_fga_audit;
drop procedure dbms_feature_unified_audit;

Rem ************************************************************************
Rem Feature Usage tracking for AUDIT - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for Privilege Capture - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_priv_capture;

Rem ************************************************************************
Rem Feature Usage tracking for Privilege Capture - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for TSDP - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_TSDP;

Rem ************************************************************************
Rem Feature Usage tracking for TSDP - END
Rem ************************************************************************

Rem ************************************************************************
Rem Optimizer changes - BEGIN
Rem ************************************************************************
-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

DECLARE
  previous_version varchar2(30);
  type numtab is table of number;
  tobjns           numtab := numtab();
  tobjn            number;
  null_synopnum    varchar2(1) := null;
  property         number := 0;
  sqltxt           varchar2(32767);
  cnt              number;
  create_new_head  boolean := FALSE;
  create_new_head_pk boolean := FALSE;
  create_head      varchar2(32767) :=
    ' create table wri$_optstat_synopsis_head$ 
      ( bo#           number not null,    /* table obj# */
        group#        number not null,    /* partition group number */
        intcol#       number not null,             /* column number */
        synopsis#     number,
        split         number,     
                    /* number of splits during creation of synopsis */
        analyzetime   date,
                             /* time when this synopsis is gathered */
        spare1        number,
        spare2        clob
      ) tablespace sysaux 
      pctfree 1
      enable row movement';
  create_head_pk   varchar2(32767) :=
   ' create table wri$_optstat_synopsis_head$ 
      ( bo#           number not null,    /* table obj# */
        group#        number not null,    /* partition group number */
        intcol#       number not null,             /* column number */
        synopsis#     number not null primary key,                           
        split         number,     
              /* number of splits during creation of synopsis */
        analyzetime   date,
              /* time when this synopsis is gathered */
        spare1        number,
        spare2        clob
      ) tablespace sysaux 
      pctfree 1
      enable row movement';
  create_head_index varchar2(32767) := 
     'create unique index i_wri$_optstat_synophead on 
      wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
      tablespace sysaux';
  create_synop_nonpart varchar2(32767) := 
   'create table wri$_optstat_synopsis$
             (synopsis#   number not null,
              hashvalue   number not null
             ) 
             tablespace sysaux
             pctfree 1
             enable row movement';
  create_synop_part    varchar2(32767) := 
   'create table wri$_optstat_synopsis$
             ( bo#           number not null,
               group#        number not null,
               intcol#       number not null,           
               hashvalue     number not null 
             ) 
             partition by range(bo#) 
             subpartition by hash(group#) 
             subpartitions 32
             (
               partition p0 values less than (0)
             ) 
             tablespace sysaux
             pctfree 1
            enable row movement';
  cursor cur is
    select 'drop table ' || table_name sqltxt
    from user_tables
    where table_name in 
          (upper('tmp_wri$_optstat_synhead$'),
           upper('tmp_wri$_optstat_synopsis$'),
           upper('tpart_wri$_optstat_synopsis$'));
BEGIN
  -- in case residue tables exist from previous upgrade/downgrade
  -- drop tmp_* tables
  for stmt in cur loop
    execute immediate stmt.sqltxt;
  end loop;

  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF (substr(previous_version, 1, 4) >= '12.1' or
      previous_version is null) THEN
    -- already in 12c or don't know which prior version is
    return;
  END IF;
  
  -- step 1: downgrade synopsis head. if synopsis head does not exist,
  --         create it
  -- step 2: check whether synopsis is already in downgraded schema.
  --         if yes, return. If not exist, create one in downgraded schema
  -- step 3: renaming existing synopsis head and synopsis to tmp_*;
  --         create synopsis and synopsis head in downgraded schema
  -- step 4: populate synopsis using tmp_*, dpending on synopsis
  --         downgrading status, populating synopsis head accordingly

  -- step 1: downgrade synopsis head

  -- check whether synopsis# already a primary key constraint 
  begin
    select decode(sign(c.null$),-1,'D', 0, 'Y', 'N') 
    into null_synopnum
    from obj$ o, user$ u, col$ c 
    where o.name = 'WRI$_OPTSTAT_SYNOPSIS_HEAD$' 
    and c.obj# = o.obj#
    and c.name = 'SYNOPSIS#' 
    and u.user# = o.owner#;  
  exception
    when no_data_found then
      if (substr(previous_version, 1, 8) < '11.2.0.2') then
        -- create synopsis head with pk constraint
        create_new_head_pk := TRUE;
      else
        -- create synopsis head without pk constraint
        create_new_head := TRUE;
      end if;
    when others then
      raise;
  end;

  if (create_new_head_pk) then
    execute immediate create_head_pk;
  elsif (create_new_head) then
    execute immediate create_head;
  end if;   

  if (not create_new_head_pk and
      not create_new_head and
      null_synopnum = 'Y' and 
      substr(previous_version, 1, 8) < '11.2.0.2') then
    -- not a primary constraint yet, add it if downgrade prior to 11.2.0.2
    execute immediate
      'update wri$_optstat_synopsis_head$
       set synopsis# = synopsis_num_seq.nextval';

    execute immediate
      'alter table wri$_optstat_synopsis_head$
       add primary key (synopsis#)';
  end if;

  -- create index on synopsis head
  begin
    execute immediate create_head_index;
  exception
    when others then
      if (sqlcode = -955) then
        -- ORA-00955: name is already used by an existing object
        -- index has already been created
        null;
      else
        raise;
      end if;
  end;

  --- step 2: check whether synopsis is already in downgraded schema.
  --          if yes, return. If not exist, create a new one 

  -- check whether we are already in oldest schema
  -- if we have not downgraded, this will throw 904 error that will be caught
  begin
    execute immediate 
      'select synopsis# 
       from wri$_optstat_synopsis$
       where rownum < 2';

    -- synopsis$ already downgraded to the oldest schema
    return;
  exception
    when others then
      if (sqlcode = -904) then
        -- ORA-904: "S"."SYNOPSIS#": invalid identifier 
        -- has not been downgraded before 11202 yet
        if (substr(previous_version, 1, 8) >= '11.2.0.2') then
          -- download to 11202 or afterwards
          select count(*) into cnt
          from all_part_tables
          where owner = 'SYS' and
                table_name = 'WRI$_OPTSTAT_SYNOPSIS$' and
                partitioning_type = 'RANGE';

          if (cnt = 1) then
            -- synopsis$ table is range-hash, has been successfully downgraded
            -- to at least 11202, do nothing
            return;
          end if;
        end if;
      elsif (sqlcode = -942) then
        -- ORA-00942: table or view does not exist
        -- wri$_optstat_synopsis$ does not exist
        -- recreate wri$_optstat_synopsis$ (we might lose old data)
        if (substr(previous_version, 1, 8) >= '11.2.0.2') then
          execute immediate create_synop_part;
        else
          execute immediate create_synop_nonpart;
        end if;
        
        -- since we have recreated synopsis$, truncate existing synopsis 
        -- head$
        execute immediate 'truncate table wri$_optstat_synopsis_head$';

        -- we are done with synopsis$ (all old data are lost though)
        return;
      else
        raise;
      end if;
  end;

  -- step 3: renaming existing synopsis head and synopsis to tmp_*;
  --         create synopsis and synopsis head in downgraded schema

  -- rename synopsis head to tmp_*
  -- wri$_optstat_synopsis_head$ must have index right now
  execute immediate 
    'rename wri$_optstat_synopsis_head$ to tmp_wri$_optstat_synhead$';

  execute immediate
    'alter index i_wri$_optstat_synophead 
     rename to i2_wri$_optstat_synophead';

  -- create new synopsis head and its index
  execute immediate create_head;
  execute immediate create_head_index;

  -- rename synopsis to tmp_*
  execute immediate 
    'rename wri$_optstat_synopsis$ to tmp_wri$_optstat_synopsis$';

  -- step 4: populate synopsis using tmp_*, dpending on synopsis
  --         downgrading status, populating synopsis head accordingly
  IF (substr(previous_version, 1, 8) < '11.2.0.2') THEN
    -- downgrade to a version prior to (not including) 11.2.0.2
    -- populate using tmp table
    execute immediate create_synop_nonpart;

    execute immediate
      'insert /*+ append parallel */ 
       into wri$_optstat_synopsis$
       select /*+ full(h) full(s) leading(h s) use_hash(h s) */
         h.synopsis#, s.hashvalue
       from tmp_wri$_optstat_synopsis$ s, 
            tmp_wri$_optstat_synhead$ h
       where s.bo# = h.bo# 
         and s.group# = h.group# 
         and s.intcol# = h.intcol#';

    -- restore synopsis head
    execute immediate
      'drop table wri$_optstat_synopsis_head$';
    execute immediate 
      'rename tmp_wri$_optstat_synhead$ to wri$_optstat_synopsis_head$';
    execute immediate
      'alter index i2_wri$_optstat_synophead 
       rename to i_wri$_optstat_synophead';
      
    -- make sure index is created on synopsis$
    execute immediate
      'create index i_wri$_optstat_synopsis on 
       wri$_optstat_synopsis$ (synopsis#)
       tablespace sysaux';
  ELSE 
    -- downgrade to any version prior to 12 but after (and including) 
    -- 11.2.0.2

    -- get all the partitioned tables that have synopses
    -- must order by bo# because we are going to create partitions
    -- using "add partition" statement
    execute immediate create_synop_part;

    begin
      execute immediate 
      'select distinct bo# 
        from sys.tmp_wri$_optstat_synhead$
        order by bo#' bulk collect into tobjns;
    exception
      when no_data_found then
        null;
      when others then
        raise;
    end;

    if (tobjns.count > 0) then
      -- has something to populate
      -- #(16246179)  
      -- 11.2.0.2 and above has same table definition except
      -- it is changed from range-hash to list-hash. Do exchange
      -- instead of insert for better performance. Also this avoids 
      -- additional space usage.
      execute immediate 
        'create table tpart_wri$_optstat_synopsis$
        ( bo#           number not null,
          group#        number not null,
          intcol#       number not null,           
          hashvalue     number not null 
        ) 
        partition by hash(group#) 
        partitions 32
        tablespace sysaux
        pctfree 1
        enable row movement';

      -- create range partition for each partitioned table
      for i in 1..tobjns.count loop
        tobjn := tobjns(i);

        -- check whethre low boundary has been created
        if (i = 1 or tobjns(i-1) <> tobjn - 1) then
          -- we haven't created a partition with highvalue tobjn yet
          -- check whether objn-1 is a partitioned table
          begin
            select bitand(t.property, 32) into property
            from sys.obj$ o,
                 sys.tab$ t
            where o.obj# = tobjn-1 and
                  o.type# = 2 and
                  o.obj# = t.obj#; 
          exception
            when no_data_found then
              property := 0;
          end;

          if (property = 32) then
            -- tobjn-1 is a partitioned table, create a range partition
            -- with default subpartition number
            sqltxt := 'alter table wri$_optstat_synopsis$' ||
                      ' add partition p_' || to_char(tobjn - 1) ||
                      ' values less than (' || to_char(tobjn) || ')';
          else
            -- tobjn-1 is a non partitioned table. create a range
            -- partition with 1 subpartition
            sqltxt := 'alter table wri$_optstat_synopsis$' ||
                      ' add partition p_' || to_char(tobjn - 1) || 
                      ' values less than (' || to_char(tobjn) || ')' ||
                      ' subpartitions 1';
          end if;
          execute immediate sqltxt; 
        end if;

        -- high boundary
        sqltxt := 'alter table wri$_optstat_synopsis$' ||
                  ' add partition p_' || tobjn || 
                  ' values less than (' || to_char(tobjn + 1) || ')';
        execute immediate sqltxt; 

        -- bug 22239656: prior to 12.2 every bo# in wri$_optstat_synopsis
        -- _head$ has a corresponding partition in wri$_optstat_
        -- synopsis$. Adaptive sampling synopses are stored in the 
        -- partitioned wri$_optstat_synopsis$ table.
        -- From 12.2 on, we provide a second option of gathering 
        -- synopses, i.e., HLL. For a bo# in wri$_optstat_synopsis_
        -- head$, if all its synopses are in HLL format, then there
        -- is no corresponding partition in wri$_optstat_synopsis$.
        -- check whether a partition in wri$_optstat_synopsis exists
        -- before we exchange on it
        select count(*) into cnt
        from dba_tab_partitions
        where table_owner = 'SYS' 
          and table_name = 'TMP_WRI$_OPTSTAT_SYNOPSIS$'
          and partition_name = 'P_' || tobjn;

        if (cnt > 0) then
          -- populate using temp table
          execute immediate
            q'# alter table tmp_wri$_optstat_synopsis$ 
                exchange partition p_#' || tobjn || 
            q'# with table tpart_wri$_optstat_synopsis$
                without validation #';

          execute immediate
            q'# alter table wri$_optstat_synopsis$ 
                exchange partition p_#' || tobjn || 
            q'# with table tpart_wri$_optstat_synopsis$
                without validation #'; 
       
          -- we have succesfully upgraded the synopses, restore the old
          -- analyzetime
          execute immediate
            'insert /*+append */ into wri$_optstat_synopsis_head$
             select * from tmp_wri$_optstat_synhead$
             where bo# = ' || tobjn;

          commit;
        end if;
    
      end loop;
    end if;

  END IF;

  <<clean_up>>
  for stmt in cur loop
    execute immediate stmt.sqltxt;
  end loop;

exception
  when others then
    -- in case residue tables exist from previous upgrade/downgrade
    -- drop tmp_* tables
    for stmt in cur loop
      execute immediate stmt.sqltxt;
    end loop;
      raise;
END;
/

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

drop public synonym DBA_TAB_MODIFICATIONS;

drop view all_tab_statistics;
drop view user_tab_statistics;
drop view dba_tab_statistics;
drop view all_tab_col_statistics;
drop view user_tab_col_statistics;
drop view dba_tab_col_statistics;
drop view all_tab_histograms;
drop view user_tab_histograms;
drop view dba_tab_histograms;
drop view all_ind_statistics;
drop view user_ind_statistics;
drop view dba_ind_statistics;
drop view user_tab_cols_v$;
drop view all_tab_cols_v$;
drop view dba_tab_cols_v$;
drop public synonym all_tab_statistics;
drop public synonym user_tab_statistics;
drop public synonym dba_tab_statistics;
drop public synonym all_tab_col_statistics;
drop public synonym user_tab_col_statistics;
drop public synonym dba_tab_col_statistics;
drop public synonym all_tab_histograms;
drop public synonym user_tab_histograms;
drop public synonym dba_tab_histograms;
drop public synonym all_ind_statistics;
drop public synonym user_ind_statistics;
drop public synonym dba_ind_statistics;

Rem ************************************************************************
Rem Optimizer changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Online redef changes - BEGIN
Rem ************************************************************************

drop package dbms_redefinition_internal;

TRUNCATE TABLE redef_track$;

Rem ************************************************************************
Rem Online redef changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Hang Manager changes - BEGIN
Rem ************************************************************************

drop public synonym v$hang_info;
drop view v_$hang_info;

drop public synonym v$hang_session_info;
drop view v_$hang_session_info;

Rem ************************************************************************
Rem Hang Manager changes - END
Rem ************************************************************************

Rem
Rem Fast Space Usage Views.
Rem

drop public synonym v$segspace_usage ;
drop view v_$segspace_usage ;

drop public synonym gv$segspace_usage ;
drop view gv_$segspace_usage ;

Rem
Rem bigfile tablespace stat view
Rem

drop public synonym v$bts_stat;
drop view v_$bts_stat;
drop public synonym gv$bts_stat;
drop view gv_$bts_stat;

Rem ************************************************************************
Rem Common Logging Infrastructure changes - BEGIN
Rem ************************************************************************

drop view dba_securefile_logs;
drop view dba_securefile_log_tables;
drop view dba_securefile_log_instances;
drop view dba_securefile_log_partitions;

drop sequence CLI_ID$;
truncate TABLE CLI_LOG$;
truncate table CLI_INST$;
truncate TABLE CLI_PART$;
truncate TABLE CLI_TS$;
truncate TABLE CLI_TAB$;


Rem ************************************************************************
Rem Common Logging Infrastructure changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Data Pump changes - BEGIN
Rem ************************************************************************

-- Remove all import callout registrations
truncate table impcalloutreg$;

drop view SYS.DATAPUMP_DIR_OBJS;
drop view SYS.LOADER_DIR_OBJS;
drop view SYS.ALL_DIRECTORIES;
drop view SYS.DBA_DIRECTORIES;

Rem ************************************************************************
Rem Data Pump changes - END
Rem ************************************************************************

Rem *************************************************************************
Rem RAC/Services changes - BEGIN
Rem *************************************************************************

Rem remove the new service$ columns
update service$ set pdb          = null;
update service$ set max_lag_time = null;
update service$ set gsm_flags    = null;
update service$ set pq_svc       = null;
commit;

Rem *************************************************************************
Rem RAC/Services changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Consolidated Database changes - BEGIN
Rem *************************************************************************

truncate table container$;
delete from obj$ where name='NON$CDB';

truncate table pdb_history$;

truncate table pdb_alert$;

truncate table pdbstate$;

truncate table cdbvw_stats$;

truncate table cdb_file$;

truncate table cdb_service$;

drop public synonym v$pdbs;
drop view v_$pdbs;

drop public synonym gv$pdbs;
drop view gv_$pdbs;

drop public synonym v$containers;
drop view v_$containers;

drop public synonym gv$containers;
drop view gv_$containers;

drop public synonym v$pdb_incarnation;
drop view v_$pdb_incarnation;

drop public synonym gv$pdb_incarnation;
drop view gv_$pdb_incarnation;

drop public synonym DBA_PDBS;
drop view DBA_PDBS;

drop public synonym dbms_pdb;
drop package body sys.dbms_pdb;
drop package sys.dbms_pdb;

-- drop public synonyms of CDB_* views created by CDBView.create_cdbviews.
-- drop CDB_* views created by CDBView.create_cdbviews. 
declare
  cdbvowner varchar2(128);
  cdbvname  varchar2(128);
  sqlstmt   varchar2(200);
  synonym   varchar2(128);
  quoted_synonym   varchar2(130); -- 2 more than the size of synonym
  quoted_cdbvowner varchar2(130); -- 2 more than the size of cdbvowner
  quoted_cdbvname  varchar2(130); -- 2 more than the size of cdbvname
  cursor c1 is 
  select owner, view_name 
  from   dba_views 
  where  view_name like 'CDB_%';

  cursor c2 is
  select s.synonym_name
    from dba_synonyms s
   where s.table_owner = cdbvowner
     and s.table_name = cdbvname
     and s.owner = 'PUBLIC';
begin
  open c1;
  loop
    fetch c1 into cdbvowner, cdbvname;
    exit when c1%NOTFOUND;
    open c2;
    loop
      fetch c2 into synonym;
      exit when c2%NOTFOUND;
      quoted_synonym := '"' || synonym || '"';
      sqlstmt := 'drop public synonym ' || quoted_synonym;
      execute immediate sqlstmt;
    end loop;
    close c2;
    quoted_cdbvowner := '"' || cdbvowner || '"';
    quoted_cdbvname  := '"' || cdbvname  || '"';
    sqlstmt := 'drop view ' || quoted_cdbvowner || '.' || quoted_cdbvname;
    execute immediate sqlstmt;
  end loop;
  close c1;
end;
/

-- drop other CDB Views
drop view AWRI$_CDB_TS$;

-- drop CDB View package
drop package body sys.CDBView;
drop package sys.CDBView;

truncate table condata$;

truncate table adminauth$;

drop public synonym DBA_PDB_HISTORY;
drop view DBA_PDB_HISTORY;

drop public synonym DBA_CONTAINER_DATA;
drop view DBA_CONTAINER_DATA;

Rem turn off view$.property bits which will not fit into a ub4
update view$ set property = bitand(property, 4294967295)
  where property > 4294967295;

drop role cdb_dba;
drop role pdb_dba;

truncate table cdb_local_adminauth$;

drop public synonym CDB_LOCAL_ADMIN_PRIVS;
drop view CDB_LOCAL_ADMIN_PRIVS;

drop public synonym PDB_PLUG_IN_VIOLATIONS;
drop view PDB_PLUG_IN_VIOLATIONS;

drop table pdb_alert$;
drop view pdb_alerts;
drop public synonym pdb_alerts;

drop sequence PDB_ALERT_SEQUENCE;

truncate table pdb_spfile$;

drop public synonym v$con_sysstat;
drop view v_$con_sysstat;

drop public synonym gv$con_sysstat;
drop view gv_$con_sysstat;

drop public synonym v$con_sys_time_model;
drop view v_$con_sys_time_model;

drop public synonym gv$con_sys_time_model;
drop view gv_$con_sys_time_model;

drop public synonym v$con_system_wait_class;
drop view v_$con_system_wait_class;

drop public synonym gv$con_system_wait_class;
drop view gv_$con_system_wait_class;

drop public synonym v$con_system_event;
drop view v_$con_system_event;

drop public synonym gv$con_system_event;
drop view gv_$con_system_event;

-- unset oracle-supplied bit if set in obj$
-- note: expect to update around 90,000 rows.
--       did not run out of undo during testing, but just to be safe, let's
--       break up the updates into batches.
update sys.obj$
  set flags = flags - 4194304
  where bitand(flags, 4194304) = 4194304
    and rownum <= 50000;
commit;
update sys.obj$
  set flags = flags - 4194304
  where bitand(flags, 4194304) = 4194304;
commit;

-- unset oracle-supplied bit if set in user$
-- Bug 25117045: also unset common-user bit
-- note: expect to update less than 200 rows.
update sys.user$
  set spare1 = spare1 - bitand(spare1, 256) - bitand(spare1, 128)
  where bitand(spare1, 256) = 256
  or bitand(spare1, 128) = 128;
commit;

alter system flush shared_pool;
-- end of unset of oracle-maintained bit


alter table sys.profname$ drop column flags;

Rem *************************************************************************
Rem Consolidated Database changes - END
Rem *************************************************************************
  
Rem *************************************************************************
Rem Data Mining changes - BEGIN
Rem *************************************************************************
-- SVD  
drop PACKAGE DM_FE_CUR; 
drop PUBLIC synonym dm_svd_matrix;
drop PUBLIC synonym dm_svd_matrix_set;
drop PUBLIC synonym dm_fe_build;
drop LIBRARY DMFE_LIB;
drop FUNCTION DM_FE_BUILD;
drop TYPE DMFEBO force;
drop TYPE DMFEBOS force;
drop TYPE DMFEBIMP force;
drop TYPE DM_SVD_MATRIX force;
drop TYPE DM_SVD_MATRIX_SET force;

Rem Migrate DM_GLM_COEFF type
alter type dm_glm_coeff drop attribute feature_expression cascade;
drop public synonym dm_nested_binary_float;
drop public synonym dm_nested_binary_floats;
drop public synonym dm_nested_binary_double;
drop public synonym dm_nested_binary_doubles;
drop type dm_nested_binary_floats force;
drop type dm_nested_binary_float force;
drop type dm_nested_binary_doubles force;
drop type dm_nested_binary_double force;

Rem  Move odm metadata to SYSAUX tablespace
alter table model$ move tablespace sysaux;
alter table modelset$ move tablespace sysaux;
alter table modelatt$ move tablespace sysaux;
alter table modeltab$ move tablespace sysaux;
alter index model$idx rebuild tablespace sysaux;
alter index modelset$idx rebuild tablespace sysaux;
alter index modelatt$idx rebuild tablespace sysaux;
alter index modeltab$idx rebuild tablespace sysaux;

-- Expectation Maximization
drop PUBLIC synonym ora_fi_exp_max;
drop PUBLIC synonym ora_dmem_nodes;
drop PUBLIC synonym dm_em_component;
drop PUBLIC synonym dm_em_component_set;
drop PUBLIC synonym dm_em_projection;
drop PUBLIC synonym dm_em_projection_set;
drop FUNCTION ora_fi_exp_max;
drop TYPE ora_dmem_node force;
drop TYPE ora_dmem_nodes force;
drop TYPE dm_em_component force;
drop TYPE dm_em_component_set force;
drop TYPE dm_em_projection force;
drop TYPE dm_em_projection_set force;

Rem *************************************************************************
Rem Data Mining changes - END
Rem ************************************************************************* 

Rem =======================================================================
Rem  Begin Changes for 12g Online Redefinition Enhancements(32728)
Rem =======================================================================
update sys.redef_dep_error$ set err_no = 0, err_txt = NULL;
update sys.redef_status$ set obj_owner = 'MATERIALIZED_VIEW_DG',
        obj_name = 'MATERIALIZED_VIEW_DG';

DROP PUBLIC SYNONYM DBA_REDEFINITION_STATUS;
DROP VIEW DBA_REDEFINITION_STATUS;

Rem =======================================================================
Rem  End Changes for 12g Online Redefinition Enhancements(32728)
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Static ACL Refresh using Materialized Views
Rem =======================================================================

DROP PUBLIC SYNONYM USER_XDS_LATEST_ACL_REFSTAT;
DROP VIEW USER_XDS_LATEST_ACL_REFSTAT;

DROP PUBLIC SYNONYM ALL_XDS_LATEST_ACL_REFSTAT;
DROP VIEW ALL_XDS_LATEST_ACL_REFSTAT;

DROP PUBLIC SYNONYM DBA_XDS_LATEST_ACL_REFSTAT;
DROP VIEW DBA_XDS_LATEST_ACL_REFSTAT;

DROP PUBLIC SYNONYM USER_XDS_ACL_REFSTAT;
DROP VIEW USER_XDS_ACL_REFSTAT;

DROP PUBLIC SYNONYM ALL_XDS_ACL_REFSTAT;
DROP VIEW ALL_XDS_ACL_REFSTAT;

DROP PUBLIC SYNONYM DBA_XDS_ACL_REFSTAT;
DROP VIEW DBA_XDS_ACL_REFSTAT;

DROP PUBLIC SYNONYM USER_XDS_ACL_REFRESH;
DROP VIEW USER_XDS_ACL_REFRESH;

DROP PUBLIC SYNONYM ALL_XDS_ACL_REFRESH;
DROP VIEW ALL_XDS_ACL_REFRESH;

DROP PUBLIC SYNONYM DBA_XDS_ACL_REFRESH;
DROP VIEW DBA_XDS_ACL_REFRESH;

DROP VIEW aclmv$_mvinfo;
DROP VIEW aclmv$_base_view; 

TRUNCATE TABLE aclmvsubtbl$;
TRUNCATE TABLE aclmvrefstat$;
TRUNCATE TABLE aclmv$_reflog; 
TRUNCATE TABLE aclmv$;

Rem =======================================================================
Rem  End Changes for Static ACL Refresh using Materialized Views
Rem =======================================================================

Rem *************************************************************************
Rem Separation of Duty project (5687) changes - BEGIN
Rem *************************************************************************

-- Drop administrative users.
drop user sysbackup cascade;
drop user sysdg cascade;
drop user syskm cascade;

-- Remove metadata for new administrative privileges.
delete from SYSTEM_PRIVILEGE_MAP where name = 'SYSBACKUP';
delete from SYSTEM_PRIVILEGE_MAP where name = 'SYSDG';
delete from SYSTEM_PRIVILEGE_MAP where name = 'SYSKM';
delete from STMT_AUDIT_OPTION_MAP where name = 'SYSBACKUP';
delete from STMT_AUDIT_OPTION_MAP where name = 'SYSDG';
delete from STMT_AUDIT_OPTION_MAP where name = 'SYSKM';

-- Remove the entries for administrative users.
delete from SYS.DEFAULT_PWD$  where user_name='SYSBACKUP' and
pwd_verifier='23AA48ACB42ADCF9';
delete from SYS.DEFAULT_PWD$  where user_name='SYSDG' and
pwd_verifier='6C6198D0644CF9B4';
delete from SYS.DEFAULT_PWD$  where user_name='SYSKM' and
pwd_verifier='F2DCB573DBFEDD9E';

-- Remove default password entries with SHA-1 hash
delete from SYS.DEFAULT_PWD$ where pv_type=1;

-- Remove the entries for the PURGE DBA_RECYCLEBIN privilege.
delete from SYSTEM_PRIVILEGE_MAP where name = 'PURGE DBA_RECYCLEBIN';
delete from STMT_AUDIT_OPTION_MAP where name = 'PURGE DBA_RECYCLEBIN';
delete from SYSAUTH$ where privilege# = -347;

COMMIT;

Rem *************************************************************************
Rem Separation of Duty project (5687) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Package dbms_log (Bug 10637191) - START 
Rem *************************************************************************

drop package dbms_log;
drop public synonym dbms_log;

Rem *************************************************************************
Rem Package dbms_log (Bug 10637191) - END
Rem *************************************************************************


Rem *************************************************************************
Rem END   e1102000.sql
Rem *************************************************************************


Rem *************************************************************************
Rem *************************************************************************
Rem *************************** 11203 DOWNGRADE ACTIONS *********************
Rem *************************************************************************
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Downgrade Actions for 11.2.0.3
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for LogMiner - for downgrade from 11203
Rem*************************************************************************

drop type sys.logmnr$alwayssuplog_srecs force;
drop type sys.logmnr$alwayssuplog_srec force;
drop type sys.logmnr$intcol_arr_type force;

drop procedure sys.logmnr$alwayssuplog_proc;
drop function sys.logmnr$alwsuplog_tabf_public;

drop view  sys.logmnr$schema_allkey_suplog ;
drop public synonym logmnr$always_suplog_columns;
drop public synonym logmnr$schema_allkey_suplog;

declare
 previous_version varchar2(30);
 cnt number;
begin
  select prv_version into previous_version from registry$
  where  cid = 'CATPROC';

  select count(1) into cnt
  from con$ co, cdef$ cd, obj$ o, user$ u
  where o.name = 'SEQ$'
    and u.name = 'SYS'
    and co.name = 'SEQ$_LOG_GRP'
    and cd.obj# = o.obj#
    and cd.con# = co.con#;

  if previous_version < '11.2.0.3.0' and cnt > 0 then
    execute immediate 'alter table sys.seq$ 
                       drop supplemental log group seq$_log_grp';
  end if;
end;
/

Rem ************************************************************************
Rem End Changes for LogMiner - for downgrade from 11203
Rem ************************************************************************

Rem ************************************************************************
Rem BEGIN Hang Manger changes - for downgrade from 11203 and 12.1
Rem ************************************************************************

DECLARE
previous_version varchar2(30);

BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.3.0' THEN
    execute immediate
      'drop public synonym v$hang_statistics';
    execute immediate
      'drop view v_$hang_statistics';
    execute immediate
      'drop public synonym gv$hang_statistics';
    execute immediate
      'drop view gv_$hang_statistics';
  END IF;
END;
/

Rem ************************************************************************
Rem END Hang Manager changes - for downgrade from 11203 and 12.1
Rem ************************************************************************

Rem ************************************************************************
Rem Digest verifiers changes - BEGIN
Rem ************************************************************************

Rem remove H: verifier and T: verifier if they are present
Rem bug 22160989: since we are by default not generating the H: verifiers
Rem we will change the query to just retain S: verifier if we are
Rem downgrading

update user$ set spare4 = substr(spare4,1,62) where instr(spare4, 'S:') = 1;

Rem spare4 will be null if we dont find the S: verifier

update user$ set spare4 = null where instr(spare4, 'S:') = 0;

Rem remove DBA_DIGEST_VERIFIERS view

begin
 execute immediate 'drop public synonym DBA_DIGEST_VERIFIERS';
 execute immediate 'drop view DBA_DIGEST_VERIFIERS';
 exception
   when others then 
     null;
end;
/

Rem ************************************************************************
Rem Digest verifiers changes - END
Rem ************************************************************************


Rem *************************************************************************
Rem Data Redaction changes - BEGIN
Rem Data Redaction (RADM, Real-time Application-controlled Data Masking)
Rem is 12c Advanced Security Option project 32006 (proj 44284 in 11.2.0.4).
Rem These changes are for downgrade from 12.1 to 11.2, to drop all Data
Rem Redaction policies (done in f1102000.sql, since it needs to use the
Rem DBMS_REDACT package) and truncate the RADM dictionary tables.
Rem
Rem  Drop all Data Redaction policies (done in f1102000.sql).
Rem  Truncate the RADM dictionary tables radm$, radm_mc$ radm_fptm$ and
Rem  drop everything created by the following catalog scripts.
Rem     $SRCHOME/rdbms/admin/dbmsredacta.sql
Rem     $SRCHOME/rdbms/src/server/security/dbmasking/prvtredacta.sql
Rem  Delete the EXEMPT REDACTION POLICY system privilege.
Rem  Delete the EXEMPT DML REDACTION POLICY system privilege.
Rem  Delete the EXEMPT DDL REDACTION POLICY system privilege.
Rem
Rem Bug #14055347 - Data Redaction downgrade to 11.2.0.4.
Rem Note: if the downgrade is from 12.1 to 11.2.0.4 or later, then because
Rem the Data Redaction feature is backported to 11.2.0.4, then we don't 
Rem do anything here, since the Data Redaction dictionary tables can't
Rem be truncated as they may contain policies which were created using
Rem the 11.2.0.4 release.  We do need to drop the packages and privileges,
Rem though, and create them with the appropriate 11.2.0.4 versions.
Rem
Rem *************************************************************************

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version
    INTO previous_version
    FROM registry$
   WHERE cid = 'CATPROC';

  IF (substr(previous_version, 1, 8) < '11.2.0.4') THEN
    -- If downgrading to a version prior to (but not including) 11.2.0.4,
    -- then truncate all the Data Redaction dictionary tables, drop all
    -- the packages and synonyms, and delete the system privileges.

    execute immediate
    'truncate table radm$';
    -- Bug 22153841: The radm$.pname, radm_td$.panme and radm_cd$.pname
    -- columns are defined as M_IDEN.  Change them to 30 upon downgrade.
    -- It is safe to modify pname to 30 here because no Policy Name longer
    -- than 30 can be created by Data Redaction unless the COMPATIBLE
    -- parameter is set to 12.2 or later, and such a COMPATIBLE setting
    -- would obviously preclude the possibility of downgrade to 11.2.
    execute immediate
    'alter table radm$ modify pname VARCHAR2(30)';
    execute immediate
    'alter table radm_td$ modify pname VARCHAR2(30)';
    execute immediate
    'alter table radm_cd$ modify pname VARCHAR2(30)';
    execute immediate
    'truncate table radm_mc$';
    execute immediate
    'truncate table radm_td$';
    execute immediate
    'truncate table radm_cd$';
    execute immediate
    'drop public synonym dbms_redact';
    execute immediate
    'drop package body sys.dbms_redact';
    execute immediate
    'drop package sys.dbms_redact';
    execute immediate
    'drop package dbms_redact_int';
    execute immediate
    'drop library dbms_redact_lib';
    execute immediate
    'truncate table radm_fptm$';
    execute immediate
    'truncate table radm_fptm_lob$';
    execute immediate
    'drop view REDACTION_POLICIES';
    execute immediate
    'drop public synonym REDACTION_POLICIES';
    execute immediate
    'drop view REDACTION_COLUMNS';
    execute immediate
    'drop public synonym REDACTION_COLUMNS';
    execute immediate
    'drop view REDACTION_VALUES_FOR_TYPE_FULL';
    execute immediate
    'drop public synonym REDACTION_VALUES_FOR_TYPE_FULL';
    execute immediate
    'drop procedure DBMS_FEATURE_DATA_REDACTION';
    
    -- Delete the EXEMPT REDACTION POLICY system privilege.
    execute immediate
    'delete from STMT_AUDIT_OPTION_MAP where option# = 351';
    execute immediate
    'delete from SYSTEM_PRIVILEGE_MAP where privilege = -351';
    execute immediate
    'delete from SYSAUTH$ where privilege#=-351';

    -- Delete the EXEMPT DML REDACTION POLICY system privilege.
    execute immediate
    'delete from STMT_AUDIT_OPTION_MAP where option# = 391';
    execute immediate
    'delete from SYSTEM_PRIVILEGE_MAP where privilege = -391';
    execute immediate
    'delete from SYSAUTH$ where privilege#=-391';

    -- Delete the EXEMPT DDL REDACTION POLICY system privilege.
    execute immediate
    'delete from STMT_AUDIT_OPTION_MAP where option# = 392';
    execute immediate
    'delete from SYSTEM_PRIVILEGE_MAP where privilege = -392';
    execute immediate
    'delete from SYSAUTH$ where privilege#=-392';

  ELSIF (substr(previous_version, 1, 8) = '11.2.0.4') THEN

    -- If downgrading to version 11.2.0.4, don't truncate the dictionary
    -- tables or drop anything here.
    --
    -- Then, as part of running the 11.2.0.4 catrelod.sql script (which 
    -- runs the catalog.sql and catproc.sql scripts using 11.2.0.4 software),
    -- the Data Redaction packages and catalog views with 11.2.0.4 versions 
    -- will be created again using the catredact.sql, dbmsredacta.sql, and 
    -- prvtredacta.plb scripts, so they'll be downgraded to their 11.2.0.4 
    -- backport versions.  The EXEMPT REDACTION POLICY system privilege is
    -- reserved with the same number in the 11.2.0.4 backport, so it doesn't
    -- need to be dropped, but the other two do need to be dropped as they
    -- were not backported.

    -- Bug 22153841: The radm$.pname, radm_td$.panme and radm_cd$.pname
    -- columns are defined as M_IDEN.  Change them to 30 upon downgrade.
    -- It is safe to modify pname to 30 here because no Policy Name longer
    -- than 30 can be created by Data Redaction unless the COMPATIBLE
    -- parameter is set to 12.2 or later, and such a COMPATIBLE setting
    -- would obviously preclude the possibility of downgrade to 11.2.
    execute immediate
    'alter table radm$ modify pname VARCHAR2(30)';
    execute immediate
    'alter table radm_td$ modify pname VARCHAR2(30)';
    execute immediate
    'alter table radm_cd$ modify pname VARCHAR2(30)';
    execute immediate
    'drop public synonym dbms_redact';
    execute immediate
    'drop package body sys.dbms_redact';
    execute immediate
    'drop package sys.dbms_redact';
    execute immediate
    'drop package dbms_redact_int';
    execute immediate
    'drop library dbms_redact_lib';
    execute immediate
    'drop view REDACTION_POLICIES';
    execute immediate
    'drop public synonym REDACTION_POLICIES';
    execute immediate
    'drop view REDACTION_COLUMNS';
    execute immediate
    'drop public synonym REDACTION_COLUMNS';
    execute immediate
    'drop view REDACTION_VALUES_FOR_TYPE_FULL';
    execute immediate
    'drop public synonym REDACTION_VALUES_FOR_TYPE_FULL';

    -- Delete the EXEMPT DML REDACTION POLICY system privilege.
    execute immediate
    'delete from STMT_AUDIT_OPTION_MAP where option# = 391';
    execute immediate
    'delete from SYSTEM_PRIVILEGE_MAP where privilege = -391';
    execute immediate
    'delete from SYSAUTH$ where privilege#=-391';

    -- Delete the EXEMPT DDL REDACTION POLICY system privilege.
    execute immediate
    'delete from STMT_AUDIT_OPTION_MAP where option# = 392';
    execute immediate
    'delete from SYSTEM_PRIVILEGE_MAP where privilege = -392';
    execute immediate
    'delete from SYSAUTH$ where privilege#=-392';

  END IF;
END;
/

Rem *************************************************************************
Rem Data Redaction changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Downgrade  AWR version
Rem *************************************************************************
ALTER TABLE WRM$_WR_CONTROL DROP CONSTRAINT WRM$_WR_CONTROL_NAME_UK
/
Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==     to   (11gR203 and later => SWRF Version 5)    ==
Rem ==          (11gR202 and earlier => SWRF Version 4)  ==
Rem =======================================================
DECLARE
  previous_version      VARCHAR2(30);
  previous_swrf_version NUMBER;
BEGIN

   SELECT prv_version INTO previous_version FROM registry$
    WHERE  cid = 'CATPROC';

   IF previous_version < '11.2.0.3' THEN
     previous_swrf_version := 4;
   ELSE
     previous_swrf_version := 5;
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
Rem End Downgrade AWR version
Rem *************************************************************************

Rem ************************************************************************
Rem BEGIN metadata changes for Triton Security support
Rem ************************************************************************
-- Drop Triton Security types
drop type ku$_xsobj_t force;
drop type ku$_xsobj_list_t force;
drop type ku$_xsprin_t force;
drop type ku$_xsuser_t force;
drop type ku$_xsrole_grant_t force;
drop type ku$_xsrole_t force;
drop type ku$_xsroleset_t force;
drop type ku$_xsrole_grant_t force;
drop type ku$_xsrgrant_list_t force;
drop type ku$_xsaggpriv_list_t force;
drop type ku$_xsaggpriv_t force;
drop type ku$_xspriv_list_t force;
drop type ku$_xspriv_t force;
drop type ku$_xsacepriv_list_t force;
drop type ku$_xsacepriv_t force;
drop type ku$_xsace_list_t force;
drop type ku$_xsace_t force;
drop type ku$_xssecclsh_t force;
drop type ku$_xssecclsh_list_t force;
drop type ku$_xssclass_t force;
drop type ku$_xsaclparam_t force;
drop type ku$_xsaclparam_list_t force;
drop type ku$_xsacl_t force;
drop type ku$_xsinstset_t force;
drop type ku$_xsinstset_list_t force;
drop type ku$_xsinst_inh_t force;
drop type ku$_xsinstinh_list_t force;
drop type ku$_xsinst_inhkey_t force;
drop type ku$_xsinstinhkey_list_t force;
drop type ku$_xsinst_acl_t force;
drop type ku$_xsinstacl_list_t force;
drop type ku$_xsinst_rule_t force;
drop type ku$_xsattrsec_t force;
drop type ku$_xsattrsec_list_t force;
drop type ku$_xspolicy_t force;
drop type ku$_xspolicy_param_t force;
drop type ku$_xsolap_policy_t force;
drop type ku$_xsnspace_t force;
drop type ku$_xsnstmpl_attr_t force;
drop type ku$_xsnstmpl_attr_list_t force;

-- Drop Triton Security related views;
drop view ku$_xsobj_view;
drop view ku$_xsuser_view;
drop view ku$_xsprin_view;
drop view ku$_xsrole_view;
drop view ku$_xsroleset_view;
drop view ku$_xsrole_grant_view;
drop view ku$_xssclass_view;
drop view ku$_xssecclsh_view;
drop view ku$_xsaggpriv_view;
drop view ku$_xspriv_view;
drop view ku$_xsacepriv_view;
drop view ku$_xsaclparam_view;
drop view ku$_xsacl_view;
drop view ku$_xsace_view;
drop view ku$_xsinst_inh_view;
drop view ku$_xsinst_inhkey_view;
drop view ku$_xsinst_acl_view;
drop view ku$_xsinst_rule_view;
drop view ku$_xsinstset_view;
drop view ku$_xsattrsec_view;
drop view ku$_xspolicy_view;
drop view ku$_xspolicy_param_view;
drop view ku$_xsnspace_view;
drop view ku$_xsnstmpl_attr_view;
drop view ku$_xsolap_policy_view;

Rem Create xs$sessions,xs$session_roles,xs$session_appns

Rem Light Weight Sessions and Roles

create table xs$sessions
(
  username             varchar2(4000) not null ,   /* Light Weight User Name */
  userid               number(10)     not null ,     /* Light Weight User ID */
  userguid             raw(16)        not null ,   /* Light Weight User GUID */
  acloid               raw(16)                 ,                  /* ACL OID */
  sid                  raw(16)        not null ,  /* Light Weight Session ID */
  cookie               varchar2(1024)          ,                   /* Cookie */
  proxyguid            raw(16)                 ,          /* Proxy User GUID */
  creatorid            raw(16)        not null ,          /* Creator User ID */
  updateid             raw(16)        not null ,          /* Updator User ID */
  createtime           timestamp      not null ,      /* Session Create time */
  authtime             timestamp      not null , /* Last Authentication Time */
  accesstime           timestamp      not null ,         /* Last Access Time */
  inactivetimeout      number(6)               ,       /* Inactivity Timeout */
  sessize              number                  ,             /* Session Size */
  nls_calendar         varchar2(255)           ,
  nls_comp             varchar2(255)           ,
  nls_credit           varchar2(255)           ,
  nls_currency         varchar2(255)           ,
  nls_date_format      varchar2(255)           ,
  nls_date_language    varchar2(255)           ,
  nls_debit            varchar2(255)           ,
  nls_iso_currency     varchar2(255)           ,
  nls_lang             varchar2(255)           ,
  nls_language         varchar2(255)           ,
  nls_length_semantics varchar2(255)           ,
  nls_list_separator   varchar2(255)           ,
  nls_monetary_chrs    varchar2(255)           ,
  nls_nchar_conv_excp  varchar2(255)           ,
  nls_numeric_chrs     varchar2(255)           ,
  nls_sort             varchar2(255)           ,
  nls_territory        varchar2(255)           ,
  nls_timestamp_fmt    varchar2(255)           ,
  nls_timestamp_tz_fmt varchar2(255)           ,
  nls_dual_currency    varchar2(255)           ,
  apps_feature         varchar2(255)           ,
  proxyid              number(10)              ,            /* Proxy User ID */
  effstartdate          timestamp             , /* Effective User Start Date */
  effenddate            timestamp             ,   /* Effective User End Date */
  rgversion             number(10)                /* Role graph version */
)
tablespace SYSAUX
/
create unique index i_xs$sessions1 on xs$sessions(cookie)
/

create unique index xs$sessions_i1 on xs$sessions(sid);
/

create table xs$session_roles
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  roleintid       number(10)     not null ,              /* Role Internal ID */
  roleid          raw(16)        not null ,                       /* Role ID */
  rolename        varchar2(4000) not null ,                     /* Role Name */
  roleflags       number(10)     not null ,                    /* Role Flags */
  effstartdate    timestamp               ,     /* Effective Role Start Date */
  effenddate      timestamp               ,       /* Effective Role End Date */
  parentid        number(10)              ,                    /* Parent  ID */
  refcount        number(10)                                    /* Ref count */
)
tablespace SYSAUX
/

create index xs$session_roles_i1 on xs$session_roles(sid);
/

create table xs$session_appns
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  nsname          varchar2(4000) not null ,                /* Namespace Name */
  attrname        varchar2(4000)          ,                /* Attribute Name */
  nsacloid        raw(16)                 ,         /* ACL OID for Namespace */
  nshandler       varchar2(255)           ,             /* Namespace Handler */
  nsaudit         number(10)              ,                 /* Audit Options */
  flags           number(10)              ,               /* Namespace Flags */
  attrvalue       varchar2(4000)          ,               /* Attribute Value */
  modtime         timestamp               ,             /* Modification time */
  attr_default_value  varchar2(4000)              /* Attribute default value */
)
tablespace SYSAUX
/

create index xs$session_appns_i1 on xs$session_appns(sid);
/

Rem ************************************************************************
Rem END metadata changes for Triton Security support
Rem ************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for mlog$.partdobj# 
Rem*************************************************************************
UPDATE sys.mlog$ SET partdobj# = 0;

Rem*************************************************************************
Rem END Changes for mlog$.partdobj# 
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for refresh operations of non-updatable replication MVs
Rem*************************************************************************

Rem Set status of non-updatable replication MVs to regenerate refresh
Rem operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE bitand(s.flag, 4096) = 0 AND
       bitand(s.flag, 8192) = 0 AND
       bitand(s.flag, 16384) = 0 AND
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete 11g fast refresh operations for non-updatable replication MVs
DELETE FROM sys.snap_refop$ sr
 WHERE EXISTS
  ( SELECT 1 from sys.snap$ s
     WHERE bitand(s.flag, 4096) = 0 AND
           bitand(s.flag, 8192) = 0 AND
           bitand(s.flag, 16384) = 0 AND
           bitand(s.flag, 2) = 0 AND s.instsite = 0 AND
           sr.sowner = s.sowner AND
           sr.vname = s.vname ) ;
COMMIT;

Rem*************************************************************************
Rem END Changes for refresh operations of non-updatable replication MVs
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade feature tracking 
Rem *************************************************************************

drop procedure dbms_feature_stats_incremental;

Rem *************************************************************************
Rem End Downgrade feature tracking
Rem *************************************************************************

Rem *************************************************************************
Rem Downgrade SQL translation
Rem *************************************************************************

truncate table sqltxl_err$;
truncate table sqltxl_sql$;
truncate table sqltxl$;

drop public synonym dba_sql_translation_profiles;
drop view dba_sql_translation_profiles;
drop public synonym dba_sql_translations;
drop view dba_sql_translations;
drop public synonym dba_error_translations;
drop view dba_error_translations;

drop public synonym user_sql_translation_profiles;
drop view user_sql_translation_profiles;
drop public synonym user_sql_translations;
drop view user_sql_translations;
drop public synonym user_error_translations;
drop view user_error_translations;

drop public synonym all_sql_translation_profiles;
drop view all_sql_translation_profiles;
drop public synonym all_sql_translations;
drop view all_sql_translations;
drop public synonym all_error_translations;
drop view all_error_translations;

drop public synonym dbms_sql_translator;
drop package dbms_sql_translator;
drop public synonym dbms_sql_translator_export;
drop package dbms_sql_translator_export;
delete from sys.exppkgobj$ where type# = 114;
commit;

drop public synonym gv$mapped_sql;
drop public synonym v$mapped_sql;
drop view gv_$mapped_sql;
drop view v_$mapped_sql;

delete from SYSAUTH$
 where privilege# in (-334, -335, -336, -337, -338);
delete from SYSTEM_PRIVILEGE_MAP
 where privilege in (-334, -335, -336, -337, -338);
delete from STMT_AUDIT_OPTION_MAP
 where option# in (334, 335, 336, 337, 338, 339, 348, 349, 385, 386);
delete from AUDIT_ACTIONS
 where action in (140, 141, 142, 143);

Rem *************************************************************************
Rem END Downgrade SQL translation
Rem *************************************************************************

Rem *************************************************************************
Rem Cursor Replay Context changes - BEGIN
Rem *************************************************************************

delete from SYSAUTH$ where privilege# in (-344, -345);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-344, -345);
delete from STMT_AUDIT_OPTION_MAP where option# in (344, 345);
update STMT_AUDIT_OPTION_MAP set option# = 19 where NAME = 'INDEX';
update sys.audit$ set option# = 19 where option# = 53;

Rem *************************************************************************
Rem Cursor Replay Context changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem RAC/Services changes - BEGIN
Rem *************************************************************************

update service$ set pdb = null;
update service$ set retention_timeout = null;
update service$ set replay_initiation_timeout = null;
update service$ set session_state_consistency = null;
update service$ set sql_translation_profile = null;
commit;

drop type parameter_t force;
drop type parameter_list_t force;

drop public synonym dbms_service_prvt;
drop package body dbms_service_prvt;
drop package dbms_service_prvt;

Rem *************************************************************************
Rem RAC/Services changes - END
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for dbms_lobutil_lobmap_t
Rem*************************************************************************

DROP TYPE dbms_lobutil_dedupset_t FORCE;
DROP PUBLIC SYNONYM dbms_lobutil_dedupset_t;

Rem*************************************************************************
Rem END Changes for dbms_lobutil_lobmap_t
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN dbfs export/import downgrade
Rem *************************************************************************

Rem delete procedural action registrations

delete
from    sys.exppkgact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

delete
from    sys.expdepact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

commit;

Rem *************************************************************************
Rem END dbfs export/import downgrade
Rem *************************************************************************


Rem*************************************************************************
Rem BEGIN Changes for Utilities Feature Tracking
Rem*************************************************************************

drop package sys.kupu$utilities;
drop package sys.kupu$utilities_int;
drop procedure dbms_feature_utilities1;
drop procedure dbms_feature_utilities2;
drop procedure dbms_feature_utilities3;
drop procedure dbms_feature_utilities4;

update sys.ku_utluse set encryptcnt  = 0;
update sys.ku_utluse set encrypt128  = 0;
update sys.ku_utluse set encrypt192  = 0;
update sys.ku_utluse set encrypt256  = 0;
update sys.ku_utluse set encryptpwd  = 0;
update sys.ku_utluse set encryptdual = 0;
update sys.ku_utluse set encrypttran = 0;
update sys.ku_utluse set compresscnt = 0; 
update sys.ku_utluse set compressbas = 0;
update sys.ku_utluse set compresslow = 0;
update sys.ku_utluse set compressmed = 0;
update sys.ku_utluse set compresshgh = 0;
update sys.ku_utluse set parallelcnt = 0;
update sys.ku_utluse set last_used   = NULL;
update sys.ku_utluse set fullttscnt  = 0;

commit;

Rem*************************************************************************
Rem END Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Scheduler - remove new import callouts
Rem*************************************************************************

DROP PACKAGE dbms_sched_argument_import;
DROP PUBLIC SYNONYM dbms_sched_argument_import;
DROP VIEW system.scheduler_program_args;
DROP VIEW system.scheduler_job_args;
TRUNCATE TABLE system.scheduler_program_args_tbl;
TRUNCATE TABLE system.scheduler_job_args_tbl;


drop public synonym dba_credentials;
drop public synonym all_credentials;
drop public synonym user_credentials;

drop public synonym all_scheduler_jobs;
drop public synonym dba_scheduler_jobs;
drop public synonym user_scheduler_jobs;

DROP VIEW sys.dba_credentials;
DROP VIEW sys.all_credentials;
DROP VIEW sys.user_credentials;

DROP VIEW sys.user_scheduler_jobs;
DROP VIEW sys.dba_scheduler_jobs;
DROP VIEW sys.all_scheduler_jobs;

DROP PUBLIC SYNONYM all_scheduler_running_jobs;
DROP PUBLIC SYNONYM dba_scheduler_running_jobs;
DROP PUBLIC SYNONYM user_scheduler_running_jobs;
DROP VIEW sys.user_scheduler_running_jobs;
DROP VIEW sys.dba_scheduler_running_jobs;
DROP VIEW sys.all_scheduler_running_jobs;

DROP PUBLIC SYNONYM dbms_credential;

DROP PACKAGE sys.dbms_credential;

delete from SYSAUTH$ where privilege# in (-387, -388);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-387, -388);
delete from AUDIT$ where option# in (387, 388);
delete from STMT_AUDIT_OPTION_MAP where option# in (387, 388);

update scheduler$_credential set flags = flags - 4 where bitand(flags, 4) = 4;
update scheduler$_job set connect_credential_name = NULL;
update scheduler$_job set connect_credential_owner = NULL;
update scheduler$_job set connect_credential_oid = NULL;

Rem*************************************************************************
Rem END Changes for Scheduler - remove new import callouts
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Undo changes for REDEFINE ANY TABLE system privilege (Bug#13485488)
Rem*************************************************************************

delete from SYSTEM_PRIVILEGE_MAP where privilege = -56;
delete from SYSAUTH$ where privilege# = -56;

BEGIN
 EXECUTE IMMEDIATE 'REVOKE REDEFINE ANY TABLE FROM DBA';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045, -1952 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/
delete from STMT_AUDIT_OPTION_MAP where option# = 56;
delete from AUDIT$ where option# = 56;
commit;

Rem*************************************************************************
Rem END Undo changes for REDEFINE ANY TABLE system privilege (Bug#13485488)
Rem************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade Triton Network ACLs
Rem *************************************************************************

drop view dba_network_acls;
drop view dba_network_acl_privileges;
drop view user_network_acl_privileges;
drop view dba_host_acls;
drop view dba_wallet_acls;
drop view dba_host_aces;
drop view dba_wallet_aces;
drop view user_host_aces;
drop view user_wallet_aces;
drop view dba_acl_name_map;
drop view nacl$_host_exp;
drop view nacl$_wallet_exp;
drop view nacl$_ace_exp;
drop public synonym dba_network_acls;
drop public synonym dba_network_acl_privileges;
drop public synonym user_network_acl_privileges;
drop public synonym dba_host_acls;
drop public synonym dba_wallet_acls;
drop public synonym dba_host_aces;
drop public synonym dba_wallet_aces;
drop public synonym user_host_aces;
drop public synonym user_wallet_aces;
drop public synonym dba_acl_name_map;
truncate table nacl$_host;
truncate table nacl$_wallet;
truncate table nacl$_name_map;
truncate table nacl$_host_exp_tbl;
truncate table nacl$_wallet_exp_tbl;
truncate table nacl$_ace_exp_tbl;
delete from sys.impcalloutreg$ where tag = 'NETWORK_ACL';
commit;

Rem *************************************************************************
Rem END Downgrade Triton Network ACLs
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade Triton security 
Rem *************************************************************************

Rem drop views
drop procedure DBMS_FEATURE_RAS; 
drop view DBA_XS_OBJECTS;

drop view DBA_XS_PRINCIPALS;
drop view DBA_XS_USERS;
drop view DBA_XS_ROLES;
drop view DBA_XS_DYNAMIC_ROLES;
drop view DBA_XS_EXTERNAL_PRINCIPALS;

drop view DBA_XS_ROLE_GRANTS;
drop view DBA_XS_PROXY_ROLES;

drop view DBA_XS_NS_TEMPLATES;
drop view DBA_XS_NS_TEMPLATE_ATTRIBUTES;

drop view DBA_XS_SECURITY_CLASSES;
drop view USER_XS_SECURITY_CLASSES;
drop view DBA_XS_SECURITY_CLASS_DEP;
drop view USER_XS_SECURITY_CLASS_DEP;
drop view DBA_XS_PRIVILEGES;
drop view USER_XS_PRIVILEGES;
drop view DBA_XS_IMPLIED_PRIVILEGES;
drop view USER_XS_IMPLIED_PRIVILEGES;

drop view DBA_XS_ACLS;
drop view USER_XS_ACLS;
drop view DBA_XS_ACES;
drop view USER_XS_ACES;

drop view DBA_XS_APPLIED_POLICIES;
drop view DBA_XS_POLICIES;
drop view USER_XS_POLICIES;
drop view DBA_XS_REALM_CONSTRAINTS;
drop view USER_XS_REALM_CONSTRAINTS;
drop view DBA_XS_INHERITED_REALMS;
drop view USER_XS_INHERITED_REALMS;
drop view DBA_XS_ACL_PARAMETERS;
drop view USER_XS_ACL_PARAMETERS;
drop view DBA_XS_COLUMN_CONSTRAINTS;
drop view USER_XS_COLUMN_CONSTRAINTS;

drop view DBA_XS_SESSIONS;
drop view DBA_XS_ACTIVE_SESSIONS;
drop view DBA_XS_SESSION_ROLES;
drop view DBA_XS_SESSION_NS_ATTRIBUTES;

drop view DBA_XS_AUDIT_POLICY_OPTIONS;
drop view DBA_XS_ENB_AUDIT_POLICIES;
drop view DBA_XS_AUDIT_TRAIL;

drop view V_$XS_SESSION_ROLES;
drop view GV_$XS_SESSION_ROLES;
drop view V_$XS_SESSION_NS_ATTRIBUTES;
drop view GV_$XS_SESSION_NS_ATTRIBUTES;
drop view V_$XS_SESSIONS;
drop view GV_$XS_SESSIONS;

-- 2) XML version
drop view ALL_XS_SECURITYCLASSES;
drop view ALL_XS_SECURITYCLASS_DEP;
drop view ALL_XS_PRIVS;
drop view ALL_XS_AGGR_PRIVS;

Rem drop Admin API packages
drop package XS_PRINCIPAL;
drop package XS_ROLESET;
drop package XS_ACL;
drop package XS_DATA_SECURITY;
drop package XS_DATA_SECURITY_UTIL;
drop package XS_NAMESPACE;
drop package XS_SECURITY_CLASS; 
drop package XS_ADMIN_UTIL;
drop package XS_ADMIN_INT;
drop package XS_DIAG;

drop package XS_PRINCIPAL_INT;
drop package DBMS_XS_PRINCIPALS;
drop package XS_MTCACHE_INT;
drop package DBMS_XS_MTCACHE;
drop package DBMS_XS_WEAK_AUTH;
drop package DBMS_XS_SIDP;
drop package XS_ROLESET_INT;
drop package XS_ACL_INT;
drop package XS_DATA_SECURITY_INT;
drop package XS_NAMESPACE_INT;
drop package XS_SECURITY_CLASS_INT;
drop package XS_DIAG_INT;

Rem drop synonyms
drop public synonym DBA_XS_OBJECTS;

drop public synonym DBA_XS_PRINCIPALS;
drop public synonym DBA_XS_USERS;
drop public synonym DBA_XS_ROLES;
drop public synonym DBA_XS_DYNAMIC_ROLES;
drop public synonym DBA_XS_EXTERNAL_PRINCIPALS;

drop public synonym DBA_XS_ROLE_GRANTS;
drop public synonym DBA_XS_PROXY_ROLES;

drop public synonym DBA_XS_NS_TEMPLATES;
drop public synonym DBA_XS_NS_TEMPLATE_ATTRIBUTES;

drop public synonym DBA_XS_SECURITY_CLASSES;
drop public synonym USER_XS_SECURITY_CLASSES;
drop public synonym DBA_XS_SECURITY_CLASS_DEP;
drop public synonym USER_XS_SECURITY_CLASS_DEP;
drop public synonym DBA_XS_PRIVILEGES;
drop public synonym USER_XS_PRIVILEGES;
drop public synonym DBA_XS_IMPLIED_PRIVILEGES;
drop public synonym USER_XS_IMPLIED_PRIVILEGES;

drop public synonym DBA_XS_ACLS;
drop public synonym USER_XS_ACLS;
drop public synonym DBA_XS_ACES;
drop public synonym USER_XS_ACES;

drop public synonym DBA_XS_APPLIED_POLICIES;
drop public synonym DBA_XS_POLICIES;
drop public synonym USER_XS_POLICIES;
drop public synonym DBA_XS_REALM_CONSTRAINTS;
drop public synonym USER_XS_REALM_CONSTRAINTS;
drop public synonym DBA_XS_INHERITED_REALMS;
drop public synonym USER_XS_INHERITED_REALMS;
drop public synonym DBA_XS_ACL_PARAMETERS;
drop public synonym USER_XS_ACL_PARAMETERS;
drop public synonym DBA_XS_COLUMN_CONSTRAINTS;
drop public synonym USER_XS_COLUMN_CONSTRAINTS;

drop public synonym DBA_XS_SESSIONS;
drop public synonym DBA_XS_ACTIVE_SESSIONS;
drop public synonym DBA_XS_SESSION_ROLES;
drop public synonym DBA_XS_SESSION_NS_ATTRIBUTES;

drop public synonym DBA_XS_AUDIT_POLICY_OPTIONS;
drop public synonym DBA_XS_ENB_AUDIT_POLICIES;
drop public synonym DBA_XS_AUDIT_TRAIL;

drop public synonym XS_PRINCIPAL;
drop public synonym XS_ROLESET;
drop public synonym XS_ACL;
drop public synonym XS_SECURITY_CLASS;
drop public synonym XS_DATA_SECURITY;
drop public synonym XS_DATA_SECURITY_UTIL;
drop public synonym XS_NAMESPACE;
drop public synonym XS_ADMIN_UTIL;
drop public synonym XS_DIAG;
drop public synonym XS_ADMIN_INT;

drop public synonym XS$ROLE_GRANT_TYPE;
drop public synonym XS$ROLE_GRANT_LIST;
drop public synonym XS$ACE_TYPE;
drop public synonym XS$ACE_LIST;
drop public synonym XS$PRIVILEGE;
drop public synonym XS$PRIVILEGE_LIST;
drop public synonym XS$REALM_CONSTRAINT_TYPE;
drop public synonym XS$REALM_CONSTRAINT_LIST;
drop public synonym XS$COLUMN_CONSTRAINT_TYPE;
drop public synonym XS$COLUMN_CONSTRAINT_LIST;
drop public synonym XS$KEY_TYPE;
drop public synonym XS$KEY_LIST;
drop public synonym XS$NS_ATTRIBUTE;
drop public synonym XS$NS_ATTRIBUTE_LIST;
drop public synonym XS$NAME_LIST;
drop public synonym XS$LIST;


drop public synonym DBMS_XS_SIDP;
drop public synonym DBMS_XS_MTCACHE;
drop public synonym DBMS_XS_PRINCIPALS;

drop public synonym V$XS_SESSION_ROLES;
drop public synonym V$XS_SESSION_ROLE;
drop public synonym GV$XS_SESSION_ROLES;
drop public synonym GV$XS_SESSION_ROLE;
drop public synonym V$XS_SESSION_NS_ATTRIBUTES;
drop public synonym V$XS_SESSION_NS_ATTRIBUTE;
drop public synonym GV$XS_SESSION_NS_ATTRIBUTES;
drop public synonym GV$XS_SESSION_NS_ATTRIBUTE;
drop public synonym V$XS_SESSIONS;
drop public synonym GV$XS_SESSIONS;

-- 2) XML version
drop public synonym ALL_XS_SECURITYCLASSES;
drop public synonym ALL_XS_SECURITYCLASS_DEP;
drop public synonym ALL_XS_PRIVS;
drop public synonym ALL_XS_AGGR_PRIVS;

Rem drop types
drop type XS$ROLE_GRANT_TYPE force;
drop type XS$ROLE_GRANT_LIST force;
drop type XS$ACE_TYPE force;
drop type XS$ACE_LIST force;
drop type XS$PRIVILEGE force;
drop type XS$PRIVILEGE_LIST force;
drop type XS$REALM_CONSTRAIN_TYPE force;
drop type XS$REALM_CONSTRAINT_LIST force;
drop type XS$COLUMN_CONSTRAINT_TYPE force;
drop type XS$COLUMN_CONSTRAINT_LIST force;
drop type XS$KEY_TYPE force;
drop type XS$KEY_LIST force;
drop type XS$NS_ATTRIBUTE force;
drop type XS$NS_ATTRIBUTE_LIST force;
drop type XS$NAME_LIST force;
drop type XS$LIST force;
drop type XS$REALM_PARAMETER_TABLE force;

Rem Drop library
drop library DBMS_RXS_LIB;
drop function GET_REALM_PARAMETERS;

Rem Drop sequence
drop sequence XS$ID_SEQUENCE;

Rem Truncate tables
-- disable foreign key constraints first
--Fix lrg 10225403:Query from metadata table directly insead of constraint views
DECLARE
  buf varchar2(4000);
BEGIN
  FOR con_name_rec IN
       (SELECT c.name          CONSTRAINT_NAME,
               o.name          TABLE_NAME,
               u.name          SCHEMA_NAME
        FROM sys.con$ c, sys.obj$ o, sys.user$ u, sys.cdef$ cd
        WHERE cd.con# = c.con# and cd.type# = 4 and
              cd.obj# = o.obj# and o.owner# = u.user# and
              u.name = 'SYS' and c.name like 'XS$%' and o.name like 'XS$%')
  LOOP
    buf:=  'ALTER TABLE '||
            dbms_assert.enquote_name(con_name_rec.SCHEMA_NAME, FALSE) || '.' ||
            dbms_assert.enquote_name(con_name_rec.TABLE_NAME, FALSE) ||
           ' DISABLE CONSTRAINT ' ||
           dbms_assert.enquote_name(con_name_rec.CONSTRAINT_NAME, FALSE);

    EXECUTE IMMEDIATE buf;
  END LOOP;
END;
/

truncate table xs$role_grant;
truncate table xs$proxy_role;
truncate table xs$prin;

truncate table xs$aggr_priv;
truncate table xs$priv;
truncate table xs$seccls_h;
truncate table xs$seccls;

truncate table xs$ace_priv;
truncate table xs$ace;
truncate table xs$acl;

truncate table xs$instset_inh_key;
truncate table xs$instset_inh;
truncate table xs$instset_acl;
truncate table xs$instset_rule;
truncate table xs$instset_list;
truncate table xs$attr_sec;
truncate table xs$acl_param;
truncate table xs$policy_param;
truncate table xs$dsec;

truncate table xs$olap_policy;
truncate table xs$roleset_roles;
truncate table xs$roleset;
truncate table xs$nstmpl_attr;
truncate table xs$nstmpl;

truncate table rxs$sessions;
truncate table rxs$session_roles;
truncate table rxs$session_appns;
truncate table xs$cache_actions;
truncate table xs$cache_delete;

truncate table xs$obj;
truncate table xs$workspace;

-- enable foreign key constraints
--Fix lrg 10225403:Query from metadata table directly insead of constraint views
DECLARE
  buf varchar2(4000);
BEGIN
  FOR con_name_rec IN
       (SELECT c.name          CONSTRAINT_NAME,
               o.name          TABLE_NAME,
               u.name          SCHEMA_NAME
        FROM sys.con$ c, sys.obj$ o, sys.user$ u, sys.cdef$ cd
        WHERE cd.con# = c.con# and cd.type# = 4 and
              cd.obj# = o.obj# and o.owner# = u.user# and
              u.name = 'SYS' and c.name like 'XS$%' and o.name like 'XS$%')
  LOOP
    buf:=  'ALTER TABLE '||
            dbms_assert.enquote_name(con_name_rec.SCHEMA_NAME, FALSE) || '.' ||
            dbms_assert.enquote_name(con_name_rec.TABLE_NAME, FALSE) ||
           ' ENABLE CONSTRAINT ' ||
           dbms_assert.enquote_name(con_name_rec.CONSTRAINT_NAME, FALSE);

    EXECUTE IMMEDIATE buf;
  END LOOP;
END;
/

drop role XS_RESOURCE;
drop role xs_session_admin;
drop role xs_namespace_admin;
drop role xs_cache_admin;

-- Fix bug 23058041: drop provisioner role
drop role provisioner;


drop AUDIT POLICY ORA_RAS_SESSION_MGMT;
drop AUDIT POLICY ORA_RAS_POLICY_MGMT;


Rem *************************************************************************
Rem End Downgrade Triton security 
Rem *************************************************************************
Rem =======================================================================
Rem  Begin 12.1 Changes for Logminer
Rem =======================================================================

Rem LOGMINING privilege is new in 12.1

DELETE FROM SYSAUTH$ WHERE privilege# = -389;
DELETE FROM system_privilege_map WHERE name='LOGMINING';
DELETE FROM stmt_audit_option_map WHERE name='LOGMINING';
COMMIT;

drop package dbms_logmnr_internal;

update system.logmnrc_gtcs
  set LogmnrDerivedFlags = NULL;

update system.logmnrggc_gtcs
  set LogmnrDerivedFlags = NULL;
commit;

ALTER TABLE SYSTEM.LOGMNR_UID$ DROP PRIMARY KEY
/

declare
  n number;
begin
  select count(1) into n
    from obj$ o, tab$ t, user$ u, col$ c
    where o.owner# = u.user#
      and u.name = 'SYSTEM'
      and o.name = 'LOGMNR_UID$'
      and o.type# = 2
      and o.remoteowner is null
      and o.obj# = t.obj#
      and o.obj# = c.obj#
      and c.name = 'LOGMNR_DID';
  if n > 0 then
    select count(1) into n
      from obj$ o, tab$ t, user$ u
      where o.owner# = u.user#
        and u.name = 'SYSTEM'
        and o.name = 'LOGMNR_DID$'
        and o.type# = 2
        and o.remoteowner is null
        and o.obj# = t.obj#;
  end if;

  if n > 0 then
    execute immediate 'select count(1) from system.logmnr_did$' into n;
  end if;

  if n > 0 then
    /* logmnr_did$ has the session numbers we need and has the right */
    /* cardinality for logmnr_uid$ post downgrade.  So we will stage */
    /* the logmnr_uid$ data there temporarily. */

    /* First replace the logmnr_did values with the appropriate */
    /* logmnr_uid value for each session. */
    execute immediate 'update system.logmnr_did$ d
                   set d.logmnr_did = (select u.logmnr_uid
                                       from system.logmnr_uid$ u
                                       where u.logmnr_did = d.logmnr_did)';

    /* Now clean out the logmnr_uid$ table. */
    execute immediate 'delete from system.logmnr_uid$';

    /* Now copy the staged data back into logmnr_uid$. */
    execute immediate 'insert into system.logmnr_uid$ (logmnr_did, logmnr_uid)
                       select session#, logmnr_did
                          from system.logmnr_did$';

    /* Now clear out the logmnr_did$ table. */
    execute immediate 'delete from system.logmnr_did$';
    commit;
  end if;

  execute immediate 'alter table system.logmnr_uid$ rename column '||
                    ' logmnr_did to session#';
exception 
  when others then
    rollback;
    raise;
end;
/
ALTER TABLE SYSTEM.LOGMNR_UID$ ADD CONSTRAINT LOGMNR_UID$_PK 
            PRIMARY KEY (SESSION#)
/
DROP SEQUENCE system.logmnr_dids$
/
update SYSTEM.LOGMNR_UID$
   set LOGMNR_MDH = null,
       PDB_NAME = null,
       PDB_ID =  null,
       PDB_UID = null,
       START_SCN = null,
       END_SCN = null,
       FLAGS = null,
       SPARE1 = null,
       SPARE2 = null,
       SPARE3 = null,
       SPARE4 = null
/
commit
/
update system.logmnr_dictionary$
   set PDB_NAME = null,
       PDB_ID = null,
       PDB_UID  = null,
       PDB_DBID = null,
       PDB_GUID = null,
       PDB_CREATE_SCN = null,
       PDB_COUNT = null,
       PDB_GLOBAL_NAME = null
/
commit
/
TRUNCATE TABLE SYSTEM.LOGMNR_PDB_INFO$
/
DROP TABLE SYS.LOGMNRG_DICTIONARY$
/
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
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL  ) 
   TABLESPACE SYSTEM LOGGING
/
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP DROP PRIMARY KEY
/
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP MODIFY (LOGMNR_MDH NUMBER NULL)
/
UPDATE SYSTEM.LOGMNRC_DBNAME_UID_MAP 
   SET LOGMNR_MDH = NULL,
       PDB_NAME = NULL;

COMMIT;

ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP
      ADD CONSTRAINT LOGMNRC_DBNAME_UID_MAP_PK
                     PRIMARY KEY(GLOBAL_NAME)
/

Rem LOGMNR_CONTAINER$ is partitioned.
Rem Rather than truncate, we drop.  This avoids problem of finding all 
Rem partitions.  

DROP TABLE SYSTEM.LOGMNR_CONTAINER$
/

Rem Older release may query the dictionary for tables named LOGMNRG%
Rem so they will be dropped.

DROP TABLE SYS.LOGMNRG_CONTAINER$
/

Rem Colum order is crtical for LOGMNRG tables so this must be dropped
Rem and recreated.

DROP TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG;
/
CREATE TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG (
       BUILD_DATE VARCHAR2(20),
       DB_TXN_SCNBAS NUMBER,
       DB_TXN_SCNWRP NUMBER,
       CURRENT_BUILD_STATE NUMBER,
       COMPLETION_STATUS NUMBER,
       MARKED_LOG_FILE_LOW_SCN NUMBER,
       INITIAL_XID VARCHAR2(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/

update SYS.LOGMNR_BUILDLOG
   set CDB_XID = NULL,
       SPARE1 = NULL,
       SPARE2 = NULL;

update SYSTEM.LOGMNR_LOGMNR_BUILDLOG
   set CDB_XID = NULL,
       SPARE1 = NULL,
       SPARE2 = NULL;
commit;

DROP INDEX SYSTEM.LOGMNR_I2CDEF$
/
-- Supplemental logging related downgrade actions.
drop view dba_supplemental_logging;
drop public synonym dba_supplemental_logging;

Rem Downgrade changes related to Logminer/GG functionality added in 11.2.0.4
Rem These actions must only be performed for downgrades to releases older
Rem than 11.2.0.4.
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version
    INTO previous_version
    FROM registry$
   WHERE cid = 'CATPROC';

  IF (substr(previous_version, 1, 8) < '11.2.0.4') THEN

    -- These tables are being dropped rather than truncated because these
    -- are partitioned tables with unknown partitions.
    execute immediate 'drop table system.logmnrc_seq_gg';
    execute immediate 'drop table system.logmnrc_ind_gg';
    execute immediate 'drop table system.logmnrc_indcol_gg';
    execute immediate 'drop table system.logmnrc_con_gg';
    execute immediate 'drop table system.logmnrc_concol_gg';
    execute immediate 'DROP TABLE SYSTEM.LOGMNR_CON$';

    -- drop functions created for GG
    execute immediate 'drop function SYSTEM.LOGMNR$TAB_GG_TABF_PUBLIC';
    execute immediate 'drop function SYSTEM.LOGMNR$COL_GG_TABF_PUBLIC';
    execute immediate 'drop function SYSTEM.LOGMNR$SEQ_GG_TABF_PUBLIC';
    execute immediate 'drop function SYSTEM.LOGMNR$KEY_GG_TABF_PUBLIC';

    -- drop types created for using in GG functions
    execute immediate 'drop type SYSTEM.LOGMNR$TAB_GG_RECS force';
    execute immediate 'drop type SYSTEM.LOGMNR$COL_GG_RECS force';
    execute immediate 'drop type SYSTEM.LOGMNR$SEQ_GG_RECS force';
    execute immediate 'drop type SYSTEM.LOGMNR$KEY_GG_RECS force';

    execute immediate 'drop type SYSTEM.LOGMNR$TAB_GG_REC force';
    execute immediate 'drop type SYSTEM.LOGMNR$COL_GG_REC force';
    execute immediate 'drop type SYSTEM.LOGMNR$SEQ_GG_REC force';
    execute immediate 'drop type SYSTEM.LOGMNR$KEY_GG_REC force';

    -- Older release may query the dictionary for tables named LOGMNRG%
    -- so they will be dropped.
    execute immediate 'DROP TABLE SYS.LOGMNRG_CON$';
  end if;
end;
/

Rem drop additional columns created for EM filtering
alter table system.logmnr_gt_tab_include$ drop column pdb_name;
alter table system.logmnr_gt_tab_include$ drop column spare1;
alter table system.logmnr_gt_tab_include$ drop column spare2;
alter table system.logmnr_gt_tab_include$ drop column spare3;

alter table system.logmnr_gt_user_include$ drop column pdb_name;
alter table system.logmnr_gt_user_include$ drop column spare1;
alter table system.logmnr_gt_user_include$ drop column spare2;
alter table system.logmnr_gt_user_include$ drop column spare3;

alter table system.logmnr_gt_xid_include$ drop column spare1;
alter table system.logmnr_gt_xid_include$ drop column spare2;
alter table system.logmnr_gt_xid_include$ drop column spare3;

Rem =======================================================================
Rem  End 12.1 Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.1 Changes for Logical Standby
Rem =======================================================================

update system.logstdby$apply_milestone set FLAGS = 0;
commit;

drop table system.logstdby$skip_support;
drop public synonym dba_logstdby_plsql_map;
drop view dba_logstdby_plsql_map;
drop public synonym dba_logstdby_plsql_support;
drop view dba_logstdby_plsql_support;
drop view logstdby_unsupport_tab_12_1;
drop view logstdby_support_tab_12_1;

Rem =======================================================================
Rem  End 12.1 Changes for Logical Standby
Rem =======================================================================

Rem ************************************************************************
Rem BEGIN dbms_stats changes - for downgrade from 11202 and 12.1
Rem ************************************************************************
drop public synonym SelTab;
drop public synonym SelRec;
drop public synonym ColDictTab;
drop public synonym ColDictRec;
drop public synonym CRec;
drop public synonym CTab;
drop public synonym RawCRec;
drop public synonym RawCTab;
drop type SelTab force;
drop type SelRec force;
drop type ColDictTab force;
drop type ColDictRec force;
drop type CRec force;
drop type CTab force;
drop type RawCRec force;
drop type RawCTab force;

drop package dbms_stats_internal;
Rem ************************************************************************
Rem Changes for Pillar/ ZFS HCC feature tracking - BEGIN
Rem ************************************************************************

drop library dbms_storage_type_lib;
drop procedure kdzstoragetype;
drop procedure dbms_feature_zfs_storage;
drop procedure dbms_feature_pillar_storage;
drop procedure dbms_feature_zfs_ehcc;
drop procedure dbms_feature_pillar_ehcc;

Rem ************************************************************************
Rem Changes for Pillar/ ZFS HCC feature tracking  - END
Rem ************************************************************************

Rem ************************************************************************
Rem Changes for HCC row level locking feature tracking - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_hccrll;

Rem ************************************************************************
Rem Changes for HCC row level locking feature tracking  - END
Rem ************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for moving v$/gv$ views in catalog to fixed views in kqfv
Rem *************************************************************************

Rem Remove the subname '$DEPRECATED$' in obj$ for the catalog v$/gv$ views 
Rem that have been moved into kqfv.h, so that the name lookup can again match
Rem with the catalog view with the same v$/gv$ name.
UPDATE obj$ SET subname = '', status = 6
 WHERE type# = 4 AND namespace = 1 AND owner# = 0 AND
       name IN ('V$XS_SESSION_ROLES', 'GV$XS_SESSION_ROLES',
                'V$XS_SESSION_ROLE', 'GV$XS_SESSION_ROLE',
                'V$XS_SESSION_NS_ATTRIBUTES', 'GV$XS_SESSION_NS_ATTRIBUTES',
                'V$XS_SESSION_NS_ATTRIBUTE', 'GV$XS_SESSION_NS_ATTRIBUTE',
                'V$PING', 'GV$PING',
                'V$CACHE', 'GV$CACHE',
                'V$FALSE_PING', 'GV$FALSE_PING',
                'V$CACHE_TRANSFER', 'GV$CACHE_TRANSFER',
                'V$CACHE_LOCK');
COMMIT;

Rem drop the v_$/gv_$ views created for the fixed views
drop view V_$PING;
drop view GV_$PING;
drop view V_$CACHE;
drop view GV_$CACHE;
drop view V_$FALSE_PING;
drop view GV_$FALSE_PING;
drop view V_$CACHE_TRANSFER;
drop view GV_$CACHE_TRANSFER;
drop view V_$CACHE_LOCK;
drop view GV_$CACHE_LOCK;
drop view DBA_OBJECT_USAGE;
drop view USER_OBJECT_USAGE;
drop view V_$GES_DEADLOCKS;
drop view GV_$GES_DEADLOCKS;
drop view V_$GES_DEADLOCK_SESSIONS;
drop view GV_$GES_DEADLOCK_SESSIONS;

Rem drop the public synonyms for the fixed views
drop public synonym V$PING;
drop public synonym GV$PING;
drop public synonym V$CACHE;
drop public synonym GV$CACHE;
drop public synonym V$FALSE_PING;
drop public synonym GV$FALSE_PING;
drop public synonym V$CACHE_TRANSFER;
drop public synonym GV$CACHE_TRANSFER;
drop public synonym V$CACHE_LOCK;
drop public synonym GV$CACHE_LOCK;
drop public synonym V$OBJECT_USAGE;
drop public synonym DBA_OBJECT_USAGE;
drop public synonym USER_OBJECT_USAGE;
drop public synonym V$GES_DEADLOCKS;
drop public synonym GV$GES_DEADLOCKS;
drop public synonym V$GES_DEADLOCK_SESSIONS;
drop public synonym GV$GES_DEADLOCK_SESSIONS;   

Rem *************************************************************************
Rem END Changes for moving v$/gv$ views in catalog to fixed views in kqfv
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Downgrade for UTL_CALL_STACK
Rem =======================================================================

drop public synonym utl_call_stack;
drop package sys.utl_call_stack;

Rem =======================================================================
Rem  End Downgrade for UTL_CALL_STACK
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Traditional Audit
Rem =======================================================================

Rem Bug 16496620
NOAUDIT PLUGGABLE DATABASE;

Rem =======================================================================
Rem End Changes for Traditional Audit
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Downgrade changes to drop dictionary objects of new Audit config
Rem*************************************************************************

Rem Bug 21427375: Replace the references of audit_unified_policies and
Rem   audit_unified_enabled_policies views with their underlying dictionary
Rem   tables. The view could become invalid, e.g. if any of its dependent
Rem   object gets dropped.

begin
  for item in
    (select o.name policy_name, u.name user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a, sys.user$ u
       where a.user# = u.user# and a.policy# = o.obj#
     union all 
     select o.name policy_name, 'ALL USERS' user_name, a.how enabled_opt
       from sys.obj$ o, sys.audit_ng$ a
       where a.user#  = -1 and a.policy# = o.obj#)
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

begin
  for item in (select obj.name from sys.obj$ obj, sys.aud_policy$ pol
                 where obj.obj# = pol.policy#)
  loop
    execute immediate 'drop audit policy '|| item.name;
  end loop;
end;
/

truncate table aud_policy$;
truncate table aud_object_opt$;
truncate table audit_ng$;
truncate table aud_context$;

drop public synonym AUDITABLE_SYSTEM_ACTIONS;
drop view AUDITABLE_SYSTEM_ACTIONS;
drop public synonym AUDITABLE_OBJECT_ACTIONS;
drop view AUDITABLE_OBJECT_ACTIONS;
drop public synonym AUDIT_UNIFIED_POLICIES;
drop view AUDIT_UNIFIED_POLICIES;
drop public synonym AUDIT_UNIFIED_ENABLED_POLICIES;
drop view AUDIT_UNIFIED_ENABLED_POLICIES;
drop public synonym AUDIT_UNIFIED_CONTEXTS;
drop view AUDIT_UNIFIED_CONTEXTS;
drop public synonym AUDIT_UNIFIED_POLICY_COMMENTS;
drop view AUDIT_UNIFIED_POLICY_COMMENTS;

drop package amgt$datapump;
drop package dbms_audit_mgmt;

drop table fga_log$for_export_tbl;
drop view fga_log$for_export;
drop table audtab$tbs$for_export_tbl;
drop view audtab$tbs$for_export;

Rem*************************************************************************
Rem END Downgrade changes to drop dictionary objects of new Audit config
Rem*************************************************************************

Rem ***************************************************************************
Rem BEGIN Unified Auditing Changes 
Rem ***************************************************************************

Rem BEGIN Drop v_$unified_audit_trail, gv_$unified_audit_trail and 
Rem       v_$unified_audit_record_format, UNIFIED_AUDIT_TRAIL views along with
Rem       Oracle Supplied roles AUDIT_ADMIN/AUDIT_VIEWER and user AUDSYS.

drop view ALL_AUDITED_SYSTEM_ACTIONS;
drop public synonym UNIFIED_AUDIT_TRAIL;
drop view UNIFIED_AUDIT_TRAIL;

drop public synonym v$unified_audit_trail;
drop public synonym gv$unified_audit_trail;
drop public synonym v$unified_audit_record_format;

drop view gv_$unified_audit_trail;
drop view v_$unified_audit_trail;
drop view v_$unified_audit_record_format;

DROP ROLE AUDIT_ADMIN ;
DROP ROLE AUDIT_VIEWER ;
DROP USER AUDSYS CASCADE;

Rem END Drop v_$unified_audit_trail, gv_$unified_audit_trail and
Rem     v_$unified_audit_record_format, UNIFIED_AUDIT_TRAIL views

Rem Bug #16310544
delete from STMT_AUDIT_OPTION_MAP where option# = 357;
delete from AUDIT$ where option# = 357;
commit;

Rem ***************************************************************************
Rem END  Unified Auditing Changes  
Rem ***************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade Compression Statistics 
Rem *************************************************************************

truncate table compression_stat$;

Rem *************************************************************************
Rem END Downgrade Compression Statistics
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for Sequence downgrade 
Rem *************************************************************************
alter table seq$ drop column partcount;
Rem *************************************************************************
Rem END Changes for Sequence downgrade 
Rem *************************************************************************

Rem===========================
Rem SQL Monitor Changes Begin
Rem==========================

drop view v_$sql_monitor_statname;
drop public synonym v$sql_monitor_statname;

drop view gv_$sql_monitor_statname ;
drop public synonym gv$sql_monitor_statname ;

drop view v_$sql_monitor_sesstat;
drop public synonym v$sql_monitor_sesstat;

drop view gv_$sql_monitor_sesstat ;
drop public synonym gv$sql_monitor_sesstat ;

Rem need to drop this package because of the new reference to
Rem v$sql_monitor_statname
drop package body dbms_sqltune;

Rem drop new package
DROP PUBLIC SYNONYM DBMS_SQL_MONITOR;
DROP PACKAGE DBMS_SQL_MONITOR;
DROP LIBRARY DBMS_SQLMON_LIB;

Rem===========================
Rem SQL Monitor Changes End
Rem==========================

Rem===========================
Rem RT ADDM Changes Begin
Rem==========================
drop public synonym gv$rt_addm_control;
drop view gv_$rt_addm_control;
drop public synonym v$rt_addm_control;
drop view v_$rt_addm_control;
drop public synonym gv$instance_ping;
drop view gv_$instance_ping;
drop public synonym v$instance_ping;
drop view v_$instance_ping;
drop table sys.wri$_adv_addm_pdbs;
Rem===========================
Rem RT ADDM Changes End
Rem==========================

Rem===========================
Rem ADDM Changes Begin
Rem==========================
update wri$_adv_addm_tasks set fdg_count = NULL;
commit;
Rem===========================
Rem ADDM Changes End
Rem==========================


Rem==========================
Rem PX Blackbox Changes Begin
Rem==========================

drop view v_$px_process_trace;
drop public synonym v$px_process_trace;

drop view gv_$px_process_trace;
drop public synonym gv$px_process_trace;


Rem==========================
Rem PX Blackbox Changes End
Rem==========================

Rem*************************************************************************
Rem BEGIN Changes for rule_set_fob$ 
Rem*************************************************************************

update rule_set_fob$ set opexpr_c1 = substr(opexpr_c1, 1, 30);
commit;
alter table rule_set_fob$ modify (opexpr_c1 varchar2(30));
update rule_set_ee$ set complex_operators = NULL;
update rule_set_ve$ set srchattrs = NULL;
update rule_set_pr$ set arop_id = 0;
update rule_set_rop$  set parop_id = 0;
update rule_set_rop$  set arop_id = 0;
update  rule_set_rop$  set usesfp = 0;
update rule_set_rop$  set nopsfp = NULL;
update rule_set_rop$  set varsfp = NULL;
update rule_set_rop$  set prnum = 0;

truncate table rule_set_ptpdty$;


Rem Drop iee view
drop view rule_expression;
drop view rule_expression_clauses;
drop view rule_expression_conditions;

Rem Drop public synonym
drop public synonym rule_expression;
drop public synonym rule_expression_clauses;
drop public synonym rule_expression_conditions;

Rem*************************************************************************
Rem END Changes for rule_set_fob$
Rem*************************************************************************

Rem*************************************************************************
Rem Begin rules engine objects invalidation
Rem*************************************************************************
UPDATE sys.obj$ SET status = 5
where obj# in
  ((select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)
   union all
   (select /*+ index (dependency$ i_dependency2) */
      d_obj# from dependency$
      connect by prior d_obj# = p_obj#
      start with p_obj# in
        (select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)))
/
commit
/

Rem*************************************************************************
Rem END rules engine objects invalidation
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade ILM
Rem *************************************************************************

truncate table ilm$;
truncate table ilmpolicy$;
truncate table ilmobj$;
truncate table ilm_execution$;
truncate table ilm_executiondetails$;
truncate table ilm_results$;
truncate table ilm_param$;
truncate table ilm_result_stat$;
truncate table ilm_dependant_obj$;
truncate table ilm_dep_executiondetails$;
truncate table ilm_concurrency$;

alter table ilm_concurrency$ drop constraint c_ilm_attribute;
alter table ilm_param$ drop constraint c_ilm_param;
drop index i_ilm$;
drop index i_ilmpolicy$;
drop index i_ilmobj$;
drop index i_ilmexecdet_jobname;
drop index i_ilm_results$;

drop sequence ilm_seq$;
drop sequence ilm_executionid;

drop type tabobj#;
drop type objrank;
drop type csvlist;

drop public synonym USER_ILMPOLICIES;
drop public synonym USER_ILMDATAMOVEMENTPOLICIES;
drop public synonym USER_ILMOBJECTS;
drop public synonym USER_ILMTASKS;
drop public synonym USER_ILMEVALUATIONDETAILS;
drop public synonym USER_ILMRESULTS;
drop public synonym DBA_ILMPOLICIES;
drop public synonym DBA_ILMDATAMOVEMENTPOLICIES;
drop public synonym DBA_ILMOBJECTS;
drop public synonym DBA_ILMTASKS;
drop public synonym DBA_ILMEVALUATIONDETAILS;
drop public synonym DBA_ILMRESULTS;
drop public synonym DBA_ILMPARAMETERS;
drop public synonym DBMS_ILM;
drop public synonym DBMS_ILM_ADMIN;
drop public synonym DBMS_HEAT_MAP;


drop view USER_ILMPOLICIES;
drop view USER_ILMDATAMOVEMENTPOLICIES;
drop view USER_ILMOBJECTS;
drop view USER_ILMTASKS;
drop view USER_ILMEVALUATIONDETAILS;
drop view USER_ILMRESULTS;

drop view DBA_ILMPOLICIES;
drop view DBA_ILMDATAMOVEMENTPOLICIES;
drop view DBA_ILMOBJECTS;
drop view DBA_ILMTASKS;
drop view DBA_ILMEVALUATIONDETAILS;
drop view DBA_ILMRESULTS;
drop view DBA_ILMPARAMETERS;
 
drop package dbms_heat_map;
drop package dbms_ilm;
drop package prvt_ilm;
drop package dbms_ilm_admin;

drop library dbms_ilm_lib;

Rem HEAT MAP tables & views
truncate table heat_map_stat$;
truncate table heat_map_extent_stat$;

Rem drop heatmap views and synonyms
drop public synonym DBA_HEATMAP_TOP_OBJECTS;
drop view DBA_HEATMAP_TOP_OBJECTS;
drop public synonym DBA_HEATMAP_TOP_TABLESPACES;
drop view DBA_HEATMAP_TOP_TABLESPACES;
drop TABLE wri$_heatmap_top_objects;
drop TABLE wri$_heatmap_top_tablespaces;
drop table wri$_topn_metadata;
drop table wri$_heatmap_topn_dep1;
drop table wri$_heatmap_topn_dep2;

drop view "_SYS_HEAT_MAP_SEG_HISTOGRAM";
drop view DBA_HEAT_MAP_SEG_HISTOGRAM;
drop view DBA_HEAT_MAP_SEGMENT;
drop view USER_HEAT_MAP_SEG_HISTOGRAM;
drop view USER_HEAT_MAP_SEGMENT;
drop view ALL_HEAT_MAP_SEG_HISTOGRAM;
drop view ALL_HEAT_MAP_SEGMENT;

drop public synonym DBA_HEAT_MAP_SEG_HISTOGRAM;
drop public synonym DBA_HEAT_MAP_SEGMENT;
drop public synonym USER_HEAT_MAP_SEG_HISTOGRAM;
drop public synonym USER_HEAT_MAP_SEGMENT;
drop public synonym ALL_HEAT_MAP_SEG_HISTOGRAM;
drop public synonym ALL_HEAT_MAP_SEGMENT;
Rem ILM stats tables & views

Rem ILM real time stats (G)V$ views
drop view gv_$heat_map_segment;
drop public synonym gv$heat_map_segment;

drop view v_$heat_map_segment;
drop public synonym v$heat_map_segment;

drop public synonym dba_sscr_capture;
drop public synonym dba_sscr_restore;

Rem Drop ILM feature tracking procedure
drop procedure dbms_feature_ilm;

Rem Drop Heatmap Feature tracking procedure
drop procedure dbms_feature_heatmap;

Rem *************************************************************************
Rem END Downgrade ILM
Rem *************************************************************************

Rem Drop In-Database Hadoop feature tracking procedure
drop procedure dbms_feature_idh;

Rem *************************************************************************
Rem END Downgrade In-Database Hadoop
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Drop v_$dg_broker_config and gv_$dg_broker_config views
Rem *************************************************************************
drop view gv_$dg_broker_config;
drop view v_$dg_broker_config;

drop public synonym v$dg_broker_config;
drop public synonym gv$dg_broker_config;

Rem *************************************************************************
Rem END Drop v_$dg_broker_config and gv_$dg_broker_config views
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for refresh operations of AJVs
Rem*************************************************************************

Rem Set status of AJVs to regenerate refresh
Rem operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE (bitand(s.flag, 4096) = 4096 OR
        bitand(s.flag, 8192) = 8192 OR
        bitand(s.flag, 16384) = 16384) AND
       bitand(s.flag, 512) = 0 AND bitand(s.flag, 32768) = 0 AND
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete 11g fast refresh operations for AJVs
DELETE FROM sys.snap_refop$ sr
 WHERE EXISTS
  ( SELECT 1 from sys.snap$ s
     WHERE (bitand(s.flag, 4096) = 4096 OR
            bitand(s.flag, 8192) = 8192 OR
            bitand(s.flag, 16384) = 16384) AND
           bitand(s.flag, 512) = 0 AND bitand(s.flag, 32768) = 0 AND
           bitand(s.flag, 2) = 0 AND s.instsite = 0 AND
           sr.sowner = s.sowner AND
           sr.vname = s.vname ) ;
COMMIT;

Rem*************************************************************************
Rem END Changes for refresh operations of non-updatable replication MVs
Rem*************************************************************************

Rem*******************
Rem Begin Remove GSM
Rem*******************

-------------
-- Drop Users
-------------
BEGIN
EXECUTE IMMEDIATE 'DROP USER gsmcatuser cascade';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1918 THEN NULL;
       -- suppress error for non-existent queue table
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP USER gsmuser cascade';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1918 THEN NULL;
       -- suppress error for non-existent user
  ELSE raise;
  END IF;
END;
/

-- Will drop catalog tables also
BEGIN
EXECUTE IMMEDIATE 'DROP USER gsmadmin_internal cascade';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1918 THEN NULL;
       -- suppress error for non-existent user
  ELSE raise;
  END IF;
END;
/

DELETE FROM default_pwd$ WHERE
  user_name IN ('GSMADMIN_USER', 'GSMUSER', 'GSMCATUSER');

-------------
-- Drop Roles
-------------
BEGIN
EXECUTE IMMEDIATE 'DROP ROLE gsmuser_role';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP ROLE gsm_pooladmin_role';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP ROLE gsmadmin_role';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role
  ELSE raise;
  END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP ROLE gds_catalog_select';
EXCEPTION
WHEN others THEN
  IF sqlcode = -1919 THEN NULL;
       -- suppress error for non-existent role
  ELSE raise;
  END IF;
END;
/

Rem*******************
Rem End Remove GSM
Rem*******************

Rem*************************************************************************
Rem BEGIN Changes for v$asm_estimate
Rem*************************************************************************
drop view gv_$asm_estimate;
drop view v_$asm_estimate;

drop public synonym v$asm_estimate;
drop public synonym gv$asm_estimate;
Rem*************************************************************************
Rem END Changes for v$asm_estimate
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for v$asm_audit views
Rem*************************************************************************
drop view gv_$asm_audit_clean_events;
drop view v_$asm_audit_clean_events;

drop public synonym v$asm_audit_clean_events;
drop public synonym gv$asm_audit_clean_events;

drop view gv_$asm_audit_cleanup_jobs;
drop view v_$asm_audit_cleanup_jobs;

drop public synonym v$asm_audit_cleanup_jobs;
drop public synonym gv$asm_audit_cleanup_jobs;

drop view gv_$asm_audit_config_params;
drop view v_$asm_audit_config_params;

drop public synonym v$asm_audit_config_params;
drop public synonym gv$asm_audit_config_params;

drop view gv_$asm_audit_last_arch_ts;
drop view v_$asm_audit_last_arch_ts;

drop public synonym v$asm_audit_last_arch_ts;
drop public synonym gv$asm_audit_last_arch_ts;
Rem*************************************************************************
Rem END Changes for v$asm_audit views
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for (G)V$ENCRYPTION_KEYS & (G)V$CLIENT_SECRETS
Rem*************************************************************************

drop public synonym v$encryption_keys;
drop view v_$encryption_keys;
drop public synonym gv$encryption_keys;
drop view gv_$encryption_keys;

drop public synonym v$client_secrets;
drop view v_$client_secrets;
drop public synonym gv$client_secrets;
drop view gv_$client_secrets;

Rem*************************************************************************
Rem END Changes for (G)V$ENCRYPTION_KEYS  & (G)V$CLIENT_SECRETS
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Flashback Archive
Rem*************************************************************************

truncate table SYS_FBA_CONTEXT;
truncate table SYS_FBA_CONTEXT_AUD;
truncate table SYS_FBA_CONTEXT_LIST;
truncate table SYS_FBA_APP;
truncate table SYS_FBA_APP_TABLES;
truncate table SYS_FBA_COLS;
truncate table SYS_FBA_PERIOD;

Rem*************************************************************************
Rem END Changes for Flashback Archive
Rem*************************************************************************


Rem =========================================================================
Rem p#(autodop_31271)
Rem Begin Optimizer calibration statistics
Rem       drop (g)v_$optimizer_processing_rate
Rem =========================================================================

truncate table opt_calibration_stats$;

drop view v_$optimizer_processing_rate;
drop public synonym v$optimizer_processing_rate;

drop view gv_$optimizer_processing_rate;
drop public synonym gv$optimizer_processing_rate;

Rem =========================================================================
Rem p#(autodop_31271)
Rem End Optimizer calibration statistics
Rem     drop (g)v_$optimizer_processing_rate
Rem =========================================================================

Rem*************************************************************************
Rem BEGIN Changes for (G)V$ASM_ACFSTAG
Rem*************************************************************************

drop public synonym v$asm_acfstag;
drop view v_$asm_acfstag;
drop public synonym gv$asm_acfstag;
drop view gv_$asm_acfstag;

Rem*************************************************************************
Rem END Changes for (G)V$ASM_ACFSTAG
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem 1. Set the values of the 2 new columns in sts plans table to null
update wri$_sqlset_plans 
set flags = null,
    masked_binds_flag = null;

Rem 2. Truncate all new catalog objects created in this txn
truncate table wrr$_masking_definition;

truncate table wrr$_masking_parameters;

truncate table wri$_sts_granules;

truncate table wri$_sts_sensitive_sql;

truncate table wri$_masking_script_progress;

truncate table  wri$_sts_masking_step_progress;

truncate table wrr$_masking_file_progress;

truncate table wrr$_masking_bind_cache;

truncate table wri$_sts_masking_errors;

truncate table  wri$_sts_masking_exceptions;

drop sequence wri$_sqlset_ratmask_seq;

Rem 3. Drop program units
drop package body dbms_rat_mask;
drop package dbms_rat_mask;
drop public synonym dbms_rat_mask;

Rem *************************************************************************
Rem END Changes to catsqlt for RAT Masking
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Longer Identifiers
Rem *************************************************************************

--File plsql/admin/diutil.sql

alter table sys.pstubtbl modify username varchar2(30);
alter table sys.pstubtbl modify lun varchar2(30);

--File rdbms/admin/catadvtb.sql

alter table wri$_adv_definitions modify name varchar2(30);
alter table wri$_adv_def_parameters modify name varchar2(30);
alter table wri$_adv_tasks modify owner_name varchar2(30);
alter table wri$_adv_tasks modify name varchar2(30);
alter table wri$_adv_tasks modify advisor_name varchar2(30);
alter table wri$_adv_tasks modify last_exec_name varchar2(30);
alter table wri$_adv_tasks modify source varchar2(30);
alter table wri$_adv_parameters modify name varchar2(30);
alter table wri$_adv_executions modify name varchar2(30);
alter table wri$_adv_exec_parameters modify exec_name varchar2(30);
alter table wri$_adv_exec_parameters modify name varchar2(30);
alter table wri$_adv_objects modify exec_name varchar2(30);
alter table wri$_adv_findings modify exec_name varchar2(30);
alter table wri$_adv_inst_fdg modify exec_name varchar2(30);
alter table wri$_adv_recommendations modify exec_name varchar2(30);
alter table wri$_adv_actions modify exec_name varchar2(30);
alter table wri$_adv_rationale modify exec_name varchar2(30);
alter table wri$_adv_directive_defs modify domain varchar2(30);
alter table wri$_adv_directive_defs modify name varchar2(30);
alter table wri$_adv_directive_instances modify name varchar2(30);
alter table wri$_adv_journal modify exec_name varchar2(30);
alter table wri$_adv_message_groups modify exec_name varchar2(30);
alter table wri$_adv_sqlt_plan_hash modify exec_name VARCHAR2(30);
alter table wri$_adv_sqlt_plans modify object_owner VARCHAR2(30);
alter table wri$_adv_sqlt_plans modify object_name VARCHAR2(30);
alter table wri$_adv_sqlt_plans modify object_alias VARCHAR2(65);
alter table wri$_adv_sqlt_plans modify qblock_name VARCHAR2(30);

-- delete SPM evolve advisor
delete from wri$_adv_definitions
where id = 11;

delete from wri$_adv_def_parameters
where advisor_id = 11;

drop type wri$_adv_spm_evolve validate;

--File rdbms/admin/catalrt.sql

alter table wri$_alert_outstanding modify owner VARCHAR2(30);
alter table wri$_alert_outstanding modify subobject_name VARCHAR2(30);
alter table wri$_alert_outstanding modify action_argument_1 VARCHAR2(30);
alter table wri$_alert_outstanding modify action_argument_2 VARCHAR2(30);
alter table wri$_alert_outstanding modify action_argument_3 VARCHAR2(30);
alter table wri$_alert_outstanding modify action_argument_4 VARCHAR2(30);
alter table wri$_alert_outstanding modify action_argument_5 VARCHAR2(30);
alter table wri$_alert_outstanding modify user_id VARCHAR2(30);
alter table wri$_alert_history modify owner VARCHAR2(30);
alter table wri$_alert_history modify subobject_name VARCHAR2(30);
alter table wri$_alert_history modify action_argument_1 VARCHAR2(30);
alter table wri$_alert_history modify action_argument_2 VARCHAR2(30);
alter table wri$_alert_history modify action_argument_3 VARCHAR2(30);
alter table wri$_alert_history modify action_argument_4 VARCHAR2(30);
alter table wri$_alert_history modify action_argument_5 VARCHAR2(30);
alter table wri$_alert_history modify user_id VARCHAR2(30);

--File rdbms/admin/catawrtb.sql

alter table WRH$_SQLSTAT modify parsing_schema_name varchar2(30);
alter table WRH$_SQL_PLAN modify object_owner varchar2(30);
alter table WRH$_SQL_PLAN modify object_name varchar2(30);
alter table WRH$_SQL_PLAN modify object_alias varchar2(65);
alter table WRH$_SQL_PLAN modify qblock_name varchar2(30);
alter table WRH$_SQL_BIND_METADATA modify name VARCHAR2(30);
alter table WRH$_SEG_STAT_OBJ modify owner varchar(30);
alter table WRH$_SEG_STAT_OBJ modify object_name varchar(30);
alter table WRH$_SEG_STAT_OBJ modify subobject_name varchar(30);
alter table WRH$_SEG_STAT_OBJ modify base_object_name varchar2(30);
alter table WRH$_SEG_STAT_OBJ modify base_object_owner varchar2(30);
alter table WRH$_STREAMS_CAPTURE modify capture_name varchar2(30);
alter table WRH$_STREAMS_APPLY_SUM modify apply_name varchar2(30);
alter table WRH$_BUFFERED_QUEUES modify queue_schema varchar2(30);
alter table WRH$_BUFFERED_QUEUES modify queue_name varchar2(30);
alter table WRH$_BUFFERED_SUBSCRIBERS modify queue_schema varchar2(30);
alter table WRH$_BUFFERED_SUBSCRIBERS modify queue_name varchar2(30);
alter table WRH$_BUFFERED_SUBSCRIBERS modify subscriber_name varchar2(30);
alter table WRH$_BUFFERED_SUBSCRIBERS modify subscriber_type varchar2(30);
alter table WRH$_PERSISTENT_QUEUES modify queue_schema varchar2(30);
alter table WRH$_PERSISTENT_QUEUES modify queue_name varchar2(30);
alter table WRH$_PERSISTENT_SUBSCRIBERS modify queue_schema varchar2(30);
alter table WRH$_PERSISTENT_SUBSCRIBERS modify queue_name varchar2(30);
alter table WRH$_PERSISTENT_SUBSCRIBERS modify subscriber_name varchar2(30);
alter table WRH$_PERSISTENT_SUBSCRIBERS modify subscriber_type varchar2(30);
alter table WRH$_RULE_SET modify owner varchar2(30);
alter table WRH$_RULE_SET modify name varchar2(30);
alter table WRH$_RSRC_CONSUMER_GROUP modify consumer_group_name varchar2(30);
alter table WRH$_RSRC_PLAN modify plan_name varchar2(30);
alter table WRM$_SNAP_ERROR modify table_name varchar2(30);

--File rdbms/admin/catcapi.sql

alter table sys.dbfs$_stores modify s_owner varchar2(30);
alter table sys.dbfs$_stores modify p_pkg varchar2(30);

drop index sys.is_dbfs$_mounts;
alter table sys.dbfs$_mounts modify s_owner varchar2(30);
create unique index sys.is_dbfs$_mounts
    on
    sys.dbfs$_mounts(decode(s_mount, null, s_owner, null));

alter table sys.dbfs$_stats modify s_owner varchar2(30);
alter table sys.dbfs_sfs$_tab modify schema_name varchar2(30);
alter table sys.dbfs_sfs$_tab modify table_name varchar2(30);
alter table sys.dbfs_sfs$_tab modify ptable_name varchar2(30);
alter table sys.dbfs_sfs$_fs modify store_owner varchar2(30);

--File rdbms/admin/catchnf.sql

alter table invalidation_registry$ modify plsqlcallback varchar2(128);
alter table invalidation_registry$ modify username varchar2(30);

--File rdbms/admin/catdefrt.sql

alter table system.def$_calldest modify schema_name VARCHAR2(30);
alter table system.def$_calldest modify package_name VARCHAR2(30);
alter table system.def$_propagator modify username VARCHAR2(30);

--File rdbms/admin/catdpb.sql

alter table sys.ku_noexp_tab modify schema VARCHAR2(30);
alter table sys.ku_noexp_tab modify name VARCHAR2(30);
alter table sys.ku$_list_filter_temp_2 modify object_schema VARCHAR2(30);

--File rdbms/admin/catdwgrd.sql

alter table ityp$temp1 modify ityp_own varchar2(30);
alter table ityp$temp1 modify typ_own varchar2(30);

--File rdbms/admin/caths.sql

alter table hs$_base_dd modify dd_table_name varchar2(30);

--File rdbms/admin/catlmnr.sql

alter table SYSTEM.LOGMNRC_GTLO modify OWNERNAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTLO modify LVL0NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTLO modify LVL1NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTLO modify LVL2NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTCS modify COLNAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTCS modify TYPENAME VARCHAR2(30);
alter table SYSTEM.LOGMNRC_GTCS modify XTYPESCHEMANAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_SEED$ modify SCHEMANAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_SEED$ modify TABLE_NAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_SEED$ modify COL_NAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_DICTIONARY$ modify DB_CHARACTER_SET VARCHAR2(30);
alter table SYSTEM.LOGMNR_OBJ$ modify NAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_OBJ$ modify SUBNAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_OBJ$ modify REMOTEOWNER VARCHAR2(30);
alter table SYSTEM.LOGMNR_COL$ modify NAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_USER$ modify NAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_TYPE$ modify version varchar2(30);
alter table SYSTEM.LOGMNR_ATTRIBUTE$ modify name varchar2(30);
alter table SYSTEM.LOGMNR_KOPM$ modify name varchar2(30);
alter table SYSTEM.LOGMNR_PROPS$ modify name varchar2(30);

--File rdbms/admin/catlsby.sql

alter table system.logstdby$scn modify schema varchar2(30);
alter table system.logstdby$skip modify statement_opt varchar2(30);
alter table system.logstdby$skip modify schema varchar2(30);
alter table system.logstdby$skip modify name varchar2(65);
alter table system.logstdby$skip modify proc varchar2(98);
alter table system.logstdby$eds_tables modify owner varchar2(30);
alter table system.logstdby$eds_tables modify table_name varchar2(30);
alter table system.logstdby$eds_tables modify shadow_table_name varchar2(30);
alter table system.logstdby$eds_tables modify base_trigger_name varchar2(30);
alter table system.logstdby$eds_tables modify shadow_trigger_name varchar2(30);
alter table system.logstdby$eds_tables modify mview_name varchar2(30);
alter table system.logstdby$eds_tables modify mview_log_name varchar2(30);
alter table system.logstdby$eds_tables modify mview_trigger_name varchar2(30);

--File rdbms/admin/catodci.sql

alter table SYS.ODCI_SECOBJ$ modify IdxSchema VARCHAR2(30);
alter table SYS.ODCI_SECOBJ$ modify IdxName VARCHAR2(30);
alter table SYS.ODCI_SECOBJ$ modify SecObjSchema VARCHAR2(30);
alter table SYS.ODCI_SECOBJ$ modify SecObjName VARCHAR2(30);

--File rdbms/admin/catol.sql

alter table system.ol$ modify ol_name varchar2(30);
alter table system.ol$ modify category varchar2(30);
alter table system.ol$ modify creator varchar2(30);
alter table system.ol$hints modify ol_name varchar2(30);
alter table system.ol$hints modify category varchar2(30);
alter table system.ol$hints modify table_name varchar2(30);
alter table system.ol$hints modify user_table_name varchar2(64);
alter table system.ol$nodes modify ol_name varchar2(30);
alter table system.ol$nodes modify category varchar2(30);

--File rdbms/admin/catpexe.sql

alter table DBMS_PARALLEL_EXECUTE_TASK$ modify TABLE_OWNER VARCHAR2(30);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify TABLE_NAME VARCHAR2(30);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify NUMBER_COLUMN VARCHAR2(30);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify JOB_PREFIX VARCHAR2(30);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify EDITION VARCHAR2(32);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify APPLY_CROSSEDITION_TRIGGER VARCHAR2(32);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify JOB_CLASS VARCHAR2(30);
alter table DBMS_PARALLEL_EXECUTE_CHUNKS$ modify JOB_NAME VARCHAR2(30);

--File rdbms/admin/catplan.sql

alter table plan_table$ modify object_owner varchar2(30);
alter table plan_table$ modify object_name varchar2(30);
alter table plan_table$ modify object_alias varchar2(65);

--File rdbms/admin/catpspi.sql

alter table sys.dbfs_hs$_fs modify store_owner varchar2(30);
alter table sys.dbfs_hs$_fs modify store_name varchar2(30);
alter table sys.dbfs_hs$_property modify store_owner varchar2(30);
alter table sys.dbfs_hs$_property modify store_name varchar2(30);
alter table sys.dbfs_hs$_property modify prop_type varchar2(30);

--File rdbms/admin/catqueue.sql

alter table system.aq$_queue_tables modify schema VARCHAR2(30);
alter table system.aq$_queue_tables modify name VARCHAR2(30);
alter table system.aq$_queues modify name VARCHAR2(30);
alter table sys.aq$_subscriber_table modify schema VARCHAR2(30);
alter table sys.aq$_subscriber_table modify table_name VARCHAR2(30);
alter table sys.aq$_subscriber_table modify queue_name VARCHAR2(30);
alter table sys.aq$_subscriber_table modify name VARCHAR2(30);
alter table sys.aq$_subscriber_table modify rule_name VARCHAR2(30);
alter table sys.aq$_subscriber_table modify trans_name VARCHAR2(65);
alter table sys.aq$_subscriber_table modify ruleset_name VARCHAR2(65);
alter table sys.aq$_subscriber_table modify negative_ruleset_name VARCHAR2(65);
alter table sys.aq$_schedules modify job_name VARCHAR2(30);
alter table sys.aq$_message_types modify schema_name VARCHAR(30);
alter table sys.aq$_message_types modify queue_name VARCHAR(30);
alter table sys.aq$_message_types modify trans_name VARCHAR2(61);
alter table aq$_publisher modify p_name VARCHAR2(30);
alter table aq$_publisher modify p_rule_name VARCHAR2(61);
alter table aq$_publisher modify p_ruleset VARCHAR2(61);
alter table aq$_publisher modify p_transformation VARCHAR2(61);
alter table SYSTEM.AQ$_Internet_Agents modify agent_name VARCHAR2(30);
alter table SYSTEM.AQ$_Internet_Agent_Privs modify agent_name VARCHAR2(30);
alter table SYSTEM.AQ$_Internet_Agent_Privs modify db_username VARCHAR2(30);

--File rdbms/admin/catrepc.sql

alter table system.repcat$_repcat modify gowner VARCHAR2(30);
alter table system.repcat$_flavors modify gowner VARCHAR2(30);
alter table system.repcat$_repschema modify gowner VARCHAR2(30);
alter table system.repcat$_snapgroup modify gowner VARCHAR2(30);
alter table system.repcat$_repobject modify sname VARCHAR2(30);
alter table system.repcat$_repobject modify oname VARCHAR2(30);
alter table system.repcat$_repobject modify gowner VARCHAR2(30);
alter table system.repcat$_repcolumn modify sname VARCHAR2(30);
alter table system.repcat$_repcolumn modify oname VARCHAR2(30);
alter table system.repcat$_repcolumn modify cname VARCHAR2(30);
alter table system.repcat$_repcolumn modify ctype_name VARCHAR2(30);
alter table system.repcat$_repcolumn modify ctype_owner VARCHAR2(30);
alter table system.repcat$_repcolumn modify top VARCHAR2(30);
alter table system.repcat$_key_columns modify sname VARCHAR2(30);
alter table system.repcat$_key_columns modify oname VARCHAR2(30);
alter table system.repcat$_key_columns modify col VARCHAR2(30);
alter table system.repcat$_generated modify sname VARCHAR2(30);
alter table system.repcat$_generated modify oname VARCHAR2(30);
alter table system.repcat$_generated modify base_sname VARCHAR2(30);
alter table system.repcat$_generated modify base_oname VARCHAR2(30);
alter table system.repcat$_generated modify package_prefix VARCHAR2(30);
alter table system.repcat$_generated modify procedure_prefix VARCHAR2(30);
alter table system.repcat$_repprop modify sname VARCHAR2(30);
alter table system.repcat$_repprop modify oname VARCHAR2(30);
alter table system.repcat$_repcatlog modify userid VARCHAR2(30);
alter table system.repcat$_repcatlog modify sname VARCHAR2(30);
alter table system.repcat$_repcatlog modify oname VARCHAR2(30);
alter table system.repcat$_repgroup_privs modify username VARCHAR2(30);
alter table system.repcat$_repgroup_privs modify gowner VARCHAR2(30);
alter table system.repcat$_column_group modify sname varchar2(30);
alter table system.repcat$_column_group modify oname varchar2(30);
alter table system.repcat$_grouped_column modify sname varchar2(30);
alter table system.repcat$_grouped_column modify oname varchar2(30);
alter table system.repcat$_grouped_column modify column_name varchar2(30);
alter table system.repcat$_conflict modify sname varchar2(30);
alter table system.repcat$_conflict modify oname varchar2(30);
alter table system.repcat$_conflict modify reference_name varchar2(30);
alter table system.repcat$_resolution modify sname varchar2(30);
alter table system.repcat$_resolution modify oname varchar2(30);
alter table system.repcat$_resolution modify reference_name varchar2(30);
alter table system.repcat$_resolution modify function_name varchar2(92);
alter table system.repcat$_resolution_statistics modify sname varchar2(30);
alter table system.repcat$_resolution_statistics modify oname varchar2(30);
alter table system.repcat$_resolution_statistics modify reference_name varchar2(30);
alter table system.repcat$_resolution_statistics modify function_name varchar2(92);
alter table system.repcat$_resol_stats_control modify sname varchar2(30);
alter table system.repcat$_resol_stats_control modify oname varchar2(30);
alter table system.repcat$_parameter_column modify sname varchar2(30);
alter table system.repcat$_parameter_column modify oname varchar2(30);
alter table system.repcat$_parameter_column modify reference_name varchar2(30);
alter table system.repcat$_parameter_column modify parameter_table_name varchar2(30);
alter table system.repcat$_audit_attribute modify attribute varchar2(30);
alter table system.repcat$_audit_attribute modify source varchar2(92);
alter table system.repcat$_audit_column modify sname varchar2(30);
alter table system.repcat$_audit_column modify oname varchar2(30);
alter table system.repcat$_audit_column modify column_name varchar2(30);
alter table system.repcat$_audit_column modify base_sname varchar2(30);
alter table system.repcat$_audit_column modify base_oname varchar2(30);
alter table system.repcat$_audit_column modify base_reference_name varchar2(30);
alter table system.repcat$_audit_column modify attribute varchar2(30);
alter table system.repcat$_flavor_objects modify gowner VARCHAR2(30);
alter table system.repcat$_flavor_objects modify sname VARCHAR2(30);
alter table system.repcat$_flavor_objects modify oname VARCHAR2(30);
alter table system.repcat$_refresh_templates modify owner varchar2(30);
alter table system.repcat$_template_objects modify object_name varchar2(30);
alter table system.repcat$_template_objects modify derived_from_sname varchar2(30);
alter table system.repcat$_template_objects modify derived_from_oname varchar2(30);
alter table system.repcat$_template_objects modify schema_name varchar2(30);
alter table system.repcat$_template_parms modify parameter_name varchar2(30);
alter table system.repcat$_template_sites modify template_owner varchar2(30);
alter table system.repcat$_template_sites modify user_name varchar2(30);
alter table system.repcat$_site_objects modify sname varchar2(30);
alter table system.repcat$_site_objects modify oname varchar2(30);
alter table system.repcat$_runtime_parms modify parameter_name varchar2(30);
alter table system.repcat$_exceptions modify user_name varchar2(30);
alter table system.repcat$_sites_new modify gowner VARCHAR2(30);

--File rdbms/admin/catrept.sql
-- 
-- We have to drop the components table to avoid issues on re-upgrade 
-- (e.g., the drop type force below of the abstract 
-- object causes the "object" column of this table to disappear, and it
-- is not re-added during upgrade)
-- 
DROP TABLE wri$_rept_components;
DROP TABLE wri$_rept_reports;
DROP TABLE wri$_rept_files;
DROP TABLE wri$_rept_formats; 

-- drop synonyms and new types 
DROP PUBLIC SYNONYM wri$_rept_dbreplay;
DROP TYPE wri$_rept_dbreplay FORCE;

DROP PUBLIC SYNONYM wri$_rept_optstats;
DROP TYPE wri$_rept_optstats FORCE;

DROP PUBLIC SYNONYM wri$_rept_plan_diff;
DROP TYPE wri$_rept_plan_diff FORCE;

DROP PUBLIC SYNONYM wri$_rept_sqlmonitor;
DROP TYPE wri$_rept_sqlmonitor FORCE;

DROP PUBLIC SYNONYM wri$_rept_sqlpi;
DROP TYPE wri$_rept_sqlpi FORCE;

DROP PUBLIC SYNONYM wri$_rept_sqlt;
DROP TYPE wri$_rept_sqlt FORCE;

DROP PUBLIC SYNONYM wri$_rept_xplan;
DROP TYPE wri$_rept_xplan FORCE;

DROP PUBLIC SYNONYM wri$_rept_config;
DROP TYPE wri$_rept_config FORCE;

drop public synonym wri$_rept_spmevolve;
drop type wri$_rept_spmevolve force;

DROP PUBLIC SYNONYM wri$_rept_ash;
DROP TYPE wri$_rept_ash FORCE;
-- drop synonym for dbms_ash_internal package
DROP PUBLIC SYNONYM ashviewer;

DROP PUBLIC SYNONYM wri$_rept_addm;
DROP TYPE wri$_rept_addm FORCE;

DROP PUBLIC SYNONYM wri$_rept_rtaddm;
DROP TYPE wri$_rept_rtaddm FORCE;

DROP PUBLIC SYNONYM wri$_rept_cpaddm;
DROP TYPE wri$_rept_cpaddm FORCE;

DROP PUBLIC SYNONYM wri$_rept_sqldetail;
DROP TYPE wri$_rept_sqldetail FORCE;

DROP PUBLIC SYNONYM wri$_rept_awrv;
DROP TYPE wri$_rept_awrv FORCE;
DROP TYPE prvt_awrv_mapTab FORCE;
DROP TYPE prvt_awrv_map FORCE;
DROP TYPE prvt_awrv_instTab FORCE;
DROP TYPE prvt_awrv_inst FORCE;
DROP TYPE prvt_awrv_metadata FORCE;
DROP TYPE prvt_awrv_varchar64Tab FORCE;
DROP PACKAGE prvt_awr_viewer;
DROP PACKAGE prvt_rtaddm;
DROP PACKAGE prvt_awr_data;
DROP PACKAGE prvt_awr_data_cp;
DROP PACKAGE prvt_cpaddm;
DROP TYPE prvt_awr_period FORCE;
DROP TYPE prvt_awr_inst_meta_tab FORCE;
DROP TYPE prvt_awr_inst_meta FORCE;

DROP PUBLIC SYNONYM wri$_rept_emx_perf;
DROP TYPE wri$_rept_emx_perf;
DROP PUBLIC SYNONYM dbms_perf;
DROP PACKAGE DBMS_PERF;

DROP PUBLIC SYNONYM wri$_rept_perf;
DROP TYPE wri$_rept_perf FORCE;

DROP PUBLIC SYNONYM wri$_rept_dbhome;
DROP TYPE wri$_rept_dbhome FORCE;

DROP PUBLIC SYNONYM wri$_rept_storage;
DROP TYPE wri$_rept_storage FORCE;

DROP PUBLIC SYNONYM wri$_rept_memory;
DROP TYPE wri$_rept_memory FORCE;

DROP PUBLIC SYNONYM wri$_rept_session;
DROP TYPE wri$_rept_session FORCE;

DROP PUBLIC SYNONYM wri$_rept_security;
DROP TYPE wri$_rept_security FORCE;

DROP PUBLIC SYNONYM wri$_rept_arc;
DROP TYPE wri$_rept_arc FORCE;

alter type wri$_rept_sqlmonitor drop 
  overriding member function get_report_with_summary(
        report_reference IN VARCHAR2) return xmltype cascade;

alter type wri$_rept_abstract_t drop member function get_report_with_summary(
    report_reference IN VARCHAR2) return xmltype cascade;

-- drop TCB report TYPE and synonym
DROP PUBLIC SYNONYM wri$_rept_tcb;
DROP TYPE wri$_rept_tcb FORCE;
   
--File rdbms/admin/catrule.sql

alter table sys.rule_set_ieuac$ modify client_name VARCHAR2(30);
alter table sys.rule$ modify uactx_client varchar2(30);
alter table sys.rec_tab$ modify tab_alias varchar2(30);
alter table sys.rec_var$ modify var_name varchar2(30);
alter table sys.rule_set_fob$ modify opexpr_c1 varchar2(30);
alter table sys.rule_set_nl$ modify name varchar2(30);

--File rdbms/admin/catsch.sql

alter table sys.scheduler$_class modify res_grp_name varchar2(30);
alter table sys.scheduler$_job modify queue_owner varchar2(30);
alter table sys.scheduler$_job modify queue_name varchar2(30);
alter table sys.scheduler$_job modify event_rule varchar2(65);
alter table sys.scheduler$_job modify user_callback varchar2(92);
alter table sys.scheduler$_job modify creator varchar2(30);
alter table sys.scheduler$_job modify credential_name varchar2(30);
alter table sys.scheduler$_job modify credential_owner varchar2(30);
alter table sys.scheduler$_job modify fw_name varchar2(65);
alter table sys.scheduler$_lwjob_obj modify name VARCHAR2(30);
alter table sys.scheduler$_lwjob_obj modify subname VARCHAR2(30);
alter table sys.scheduler$_lightweight_job modify queue_owner varchar2(30);
alter table sys.scheduler$_lightweight_job modify queue_name varchar2(30);
alter table sys.scheduler$_lightweight_job modify event_rule varchar2(65);
alter table sys.scheduler$_lightweight_job modify creator varchar2(30);
alter table sys.scheduler$_lightweight_job modify fw_name varchar2(65);
alter table sys.scheduler$_lightweight_job modify credential_name varchar2(30);
alter table sys.scheduler$_lightweight_job modify credential_owner varchar2(30);
alter table sys.scheduler$_job_argument modify name varchar2(30);
alter table sys.scheduler$_window modify res_plan varchar2(30);
alter table sys.scheduler$_window modify creator varchar2(30);
alter table sys.scheduler$_program_argument modify name varchar2(30);
alter table sys.scheduler$_srcq_info modify ruleset_name varchar2(30);
alter table sys.scheduler$_evtq_sub modify agt_name VARCHAR2(30);
alter table sys.scheduler$_evtq_sub modify uname VARCHAR2(30);
alter table scheduler$_event_log modify name varchar2(65);
alter table scheduler$_event_log modify owner varchar2(30);
alter table scheduler$_event_log modify user_name varchar2(30);
alter table scheduler$_event_log modify credential varchar2(65);
alter table scheduler$_job_run_details modify session_id varchar2(30);
alter table scheduler$_job_run_details modify credential varchar2(65);
alter table sys.scheduler$_schedule modify queue_owner varchar2(30);
alter table sys.scheduler$_schedule modify queue_name varchar2(30);
alter table sys.scheduler$_schedule modify queue_agent varchar2(30);
alter table sys.scheduler$_schedule modify fw_name varchar2(65);
alter table sys.scheduler$_chain modify rule_set varchar2(30);
alter table sys.scheduler$_chain modify rule_set_owner varchar2(30);
alter table sys.scheduler$_step modify var_name varchar2(30);
alter table sys.scheduler$_step modify object_name varchar2(98);
alter table sys.scheduler$_step modify queue_owner varchar2(30);
alter table sys.scheduler$_step modify queue_name varchar2(30);
alter table sys.scheduler$_step modify queue_agent varchar2(30);
alter table sys.scheduler$_step modify credential_owner varchar2(30);
alter table sys.scheduler$_step modify credential_name varchar2(30);
alter table sys.scheduler$_step_state modify step_name varchar2(30);
alter table sys.scheduler$_credential modify username varchar2(30);
alter table sys.scheduler$_rjob_src_db_info modify source_schema varchar2(30);
alter table scheduler$_filewatcher_resend modify fw_owner VARCHAR2(30);
alter table scheduler$_filewatcher_resend modify fw_name VARCHAR2(30);
alter table scheduler$_notification modify job_name VARCHAR2(30);
alter table scheduler$_notification modify job_subname VARCHAR2(30);
alter table scheduler$_notification modify owner VARCHAR2(30);
alter table scheduler$_job_destinations modify credential VARCHAR2(65);
alter table scheduler$_credential modify username VARCHAR2(128) NOT NULL;
alter table scheduler$_credential modify password VARCHAR2(255) NOT NULL;

truncate table scheduler$_job_out_args;

alter table scheduler$_job_output
drop constraint scheduler$_job_output_fk;

alter table scheduler$_job_run_details
drop constraint scheduler$_job_run_details_pk;

truncate table scheduler$_job_output;

ALTER TYPE job_definition DROP
  CONSTRUCTOR FUNCTION job_definition
  ( 
    job_name                IN     VARCHAR2,
    job_style               IN     VARCHAR2 DEFAULT 'REGULAR',
    program_name            IN     VARCHAR2 DEFAULT NULL,
    job_action              IN     VARCHAR2 DEFAULT NULL,
    job_type                IN     VARCHAR2 DEFAULT NULL,
    schedule_name           IN     VARCHAR2 DEFAULT NULL,
    repeat_interval         IN     VARCHAR2 DEFAULT NULL,
    event_condition         IN     VARCHAR2 DEFAULT NULL,
    queue_spec              IN     VARCHAR2 DEFAULT NULL,
    start_date              IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date                IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    number_of_arguments     IN     NATURAL DEFAULT NULL,
    arguments               IN     SYS.JOBARG_ARRAY DEFAULT NULL,
    job_class               IN     VARCHAR2 DEFAULT 'DEFAULT_JOB_CLASS',
    schedule_limit          IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    job_priority            IN     NATURAL DEFAULT NULL,
    job_weight              IN     NATURAL DEFAULT NULL,
    max_run_duration        IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    max_runs                IN     NATURAL DEFAULT NULL,
    max_failures            IN     NATURAL DEFAULT NULL,
    logging_level           IN     NATURALN DEFAULT 64,
    restartable             IN     BOOLEAN DEFAULT FALSE,
    stop_on_window_close    IN     BOOLEAN DEFAULT FALSE,
    raise_events            IN     NATURAL DEFAULT NULL,
    comments                IN     VARCHAR2 DEFAULT NULL,
    auto_drop               IN     BOOLEAN DEFAULT TRUE,
    enabled                 IN     BOOLEAN DEFAULT FALSE,
    follow_default_timezone IN     BOOLEAN DEFAULT FALSE,
    parallel_instances      IN     BOOLEAN DEFAULT FALSE,
    aq_job                  IN     BOOLEAN DEFAULT FALSE,
    instance_id             IN     NATURAL DEFAULT NULL,
    credential_name         IN     VARCHAR2 DEFAULT NULL,
    destination             IN     VARCHAR2 DEFAULT NULL,
    database_role           IN     VARCHAR2 DEFAULT NULL,
    allow_runs_in_restricted_mode IN BOOLEAN DEFAULT FALSE,
    restart_on_recovery     IN     BOOLEAN DEFAULT FALSE,
    restart_on_failure      IN     BOOLEAN DEFAULT FALSE,
    connect_credential_name IN     VARCHAR2 DEFAULT NULL,
    store_output            IN     BOOLEAN DEFAULT TRUE
  )
  RETURN SELF AS RESULT CASCADE;

ALTER TYPE job_definition ADD
  CONSTRUCTOR FUNCTION job_definition
  ( 
    job_name                IN     VARCHAR2,
    job_style               IN     VARCHAR2 DEFAULT 'REGULAR',
    program_name            IN     VARCHAR2 DEFAULT NULL,
    job_action              IN     VARCHAR2 DEFAULT NULL,
    job_type                IN     VARCHAR2 DEFAULT NULL,
    schedule_name           IN     VARCHAR2 DEFAULT NULL,
    repeat_interval         IN     VARCHAR2 DEFAULT NULL,
    event_condition         IN     VARCHAR2 DEFAULT NULL,
    queue_spec              IN     VARCHAR2 DEFAULT NULL,
    start_date              IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date                IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    number_of_arguments     IN     NATURAL DEFAULT NULL,
    arguments               IN     SYS.JOBARG_ARRAY DEFAULT NULL,
    job_class               IN     VARCHAR2 DEFAULT 'DEFAULT_JOB_CLASS',
    schedule_limit          IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    job_priority            IN     NATURAL DEFAULT NULL,
    job_weight              IN     NATURAL DEFAULT NULL,
    max_run_duration        IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    max_runs                IN     NATURAL DEFAULT NULL,
    max_failures            IN     NATURAL DEFAULT NULL,
    logging_level           IN     NATURALN DEFAULT 64,
    restartable             IN     BOOLEAN DEFAULT FALSE,
    stop_on_window_close    IN     BOOLEAN DEFAULT FALSE,
    raise_events            IN     NATURAL DEFAULT NULL,
    comments                IN     VARCHAR2 DEFAULT NULL,
    auto_drop               IN     BOOLEAN DEFAULT TRUE,
    enabled                 IN     BOOLEAN DEFAULT FALSE,
    follow_default_timezone IN     BOOLEAN DEFAULT FALSE,
    parallel_instances      IN     BOOLEAN DEFAULT FALSE,
    aq_job                  IN     BOOLEAN DEFAULT FALSE,
    instance_id             IN     NATURAL DEFAULT NULL,
    credential_name         IN     VARCHAR2 DEFAULT NULL,
    destination             IN     VARCHAR2 DEFAULT NULL,
    database_role           IN     VARCHAR2 DEFAULT NULL,
    allow_runs_in_restricted_mode IN BOOLEAN DEFAULT FALSE
  )
  RETURN SELF AS RESULT CASCADE;

ALTER TYPE job_definition DROP ATTRIBUTE
 (restart_on_recovery,    
  restart_on_failure,
  connect_credential_name,
  store_output) CASCADE;

update sys.scheduler$_job j set flags=(DECODE(BITAND(j.flags, 35184372088832 + 70368744177664),
      35184372088832 + 70368744177664,
      j.flags + 65536 - BITAND(j.flags, 65536 + 35184372088832 + 70368744177664),
      j.flags - BITAND(j.flags, 65536 + 35184372088832 + 70368744177664)));

update sys.scheduler$_lightweight_job l set flags=(DECODE(BITAND(l.flags, 35184372088832 + 70368744177664),
      35184372088832 + 70368744177664,
      l.flags + 65536 - BITAND(l.flags, 65536 + 35184372088832 + 70368744177664),
      l.flags - BITAND(l.flags, 65536 + 35184372088832 + 70368744177664)));

--File rdbms/admin/catspace.sql

alter table wri$_segadv_objlist modify segment_owner varchar2(30);
alter table wri$_segadv_objlist modify segment_name varchar2(30);
alter table wri$_segadv_objlist modify partition_name varchar2(30);

--File rdbms/admin/catsqlt.sql

alter table wri$_adv_sqlt_rtn_plan modify exec_name VARCHAR2(30);
alter table wri$_sqlset_definitions modify name VARCHAR(30);
alter table wri$_sqlset_definitions modify owner VARCHAR(30);
alter table wri$_sqlset_references modify owner VARCHAR(30);
alter table wri$_sqlset_statements modify parsing_schema_name VARCHAR2(30);
alter table wri$_sqlset_plans modify parsing_schema_name VARCHAR2(30);
alter table wri$_sqlset_sts_topack modify name VARCHAR2(30);
alter table wri$_sqlset_sts_topack modify owner VARCHAR2(30);
alter table wri$_sqlset_plan_lines modify object_owner VARCHAR2(30);
alter table wri$_sqlset_plan_lines modify object_name VARCHAR2(30);
alter table wri$_sqlset_plan_lines modify object_alias VARCHAR2(65);
alter table wri$_sqlset_plan_lines modify qblock_name VARCHAR2(30);
alter table wri$_sqlset_workspace modify workspace_name VARCHAR2(30);
alter table wri$_sqlset_workspace modify sqlset_name VARCHAR2(30);
alter table wri$_sqlset_workspace_plans modify object_owner VARCHAR2(30);
alter table wri$_sqlset_workspace_plans modify object_name VARCHAR2(30);
alter table wri$_sqlset_workspace_plans modify object_alias VARCHAR2(65);
alter table wri$_sqlset_workspace_plans modify qblock_name VARCHAR2(30);

--File rdbms/admin/catsqltk.sql

alter table SQL_TK_COLL_CHK$ modify table_name varchar2(30);
alter table SQL_TK_ROW_CHK$ modify table_name varchar2(30);
alter table SQL_TK_REF_CHK$ modify table_name varchar2(30);
alter table SQL_TK_REF_CHK$ modify pk_table_name varchar2(30);
alter table SQL_TK_TAB_DESC$ modify table_name varchar2(30);

--File rdbms/admin/catsscr.sql

alter table sscr_cap$ modify directory varchar2(30);
alter table sscr_res$ modify directory varchar2(30);

--File rdbms/admin/catstrt.sql

alter table streams$_internal_transform modify rule_owner varchar2(30);
alter table streams$_internal_transform modify rule_name varchar2(30);
alter table streams$_internal_transform modify from_schema_name varchar2(30);
alter table streams$_internal_transform modify to_schema_name varchar2(30);
alter table streams$_internal_transform modify from_table_name varchar2(30);
alter table streams$_internal_transform modify to_table_name varchar2(30);
alter table streams$_internal_transform modify schema_name varchar2(30);
alter table streams$_internal_transform modify table_name varchar2(30);
alter table streams$_internal_transform modify column_function varchar2(30);

--File rdbms/admin/catsum.sql

alter table system.mview$_adv_workload modify application varchar(30);
alter table system.mview$_adv_workload modify uname varchar(30);
alter table system.mview$_adv_basetable modify owner varchar(30);
alter table system.mview$_adv_basetable modify table_name varchar(30);
alter table system.mview$_adv_sqldepend modify to_owner varchar2(30);
alter table system.mview$_adv_log modify uname varchar2(30);
alter table system.mview$_adv_level modify levelname varchar2(30);
alter table system.mview$_adv_output modify summary_owner varchar2(30);
alter table system.mview$_adv_output modify summary_name varchar2(30);
alter table system.mview$_adv_exceptions modify owner varchar2(30);
alter table system.mview$_adv_exceptions modify table_name varchar2(30);
alter table system.mview$_adv_exceptions modify dimension_name varchar2(30);
alter table system.mview$_adv_parameters modify parameter_name varchar2(30);
alter table system.mview$_adv_plan modify object_owner varchar2(30);
alter table system.mview$_adv_plan modify object_name varchar2(30);

--File rdbms/admin/catsumat.sql

alter table wri$_adv_sqlw_stmts modify username varchar2(30);
alter table wri$_adv_sqlw_tables modify table_owner varchar2(30);
alter table wri$_adv_sqlw_tables modify table_name varchar2(30);
alter table wri$_adv_sqlw_tabvol modify owner_name varchar2(30);
alter table wri$_adv_sqlw_tabvol modify table_name varchar2(30);
alter table wri$_adv_sqla_map modify name varchar2(30);
alter table wri$_adv_sqla_tables modify table_owner varchar2(30);
alter table wri$_adv_sqla_tables modify table_name varchar2(30);
alter table wri$_adv_sqla_tabvol modify owner_name varchar2(30);
alter table wri$_adv_sqla_tabvol modify table_name varchar2(30);
alter table wri$_adv_sqla_fake_reg modify owner varchar2(30);
alter table wri$_adv_sqla_fake_reg modify name varchar2(30);

--File rdbms/admin/catmntr.sql

truncate table wri$_tracing_enabled;
alter table wri$_tracing_enabled modify qualifier_id1 varchar2(48);
alter table wri$_tracing_enabled modify qualifier_id2 varchar2(32);

--File rdbms/admin/cattlog.sql

alter table CLI_LOG$ modify NAME VARCHAR2(30);

--File rdbms/admin/cattrans.sql

alter table transformations$ modify owner varchar2(30);
alter table transformations$ modify name varchar2(30);
alter table transformations$ modify from_schema varchar2(30);
alter table transformations$ modify from_type varchar2(30);
alter table transformations$ modify to_schema varchar2(30);
alter table transformations$ modify to_type varchar2(60);

--File rdbms/admin/catts.sql

alter table xs$prin modify schema varchar2(30);
alter table xs$prin modify profile varchar2(30);
alter table xs$prin modify credential varchar2(30);
alter table xs$prin modify powner varchar2(30);
alter table xs$prin modify pname varchar2(30);
alter table xs$prin modify pfname varchar2(30);
alter table xs$instset_inh modify parent_schema varchar2(30);
alter table xs$instset_inh modify parent_object varchar2(30);
alter table xs$instset_inh_key modify pkey varchar2(30);
alter table xs$olap_policy modify schema_name VARCHAR2(30);
alter table xs$olap_policy modify logical_name VARCHAR2(30);
alter table xs$nstmpl modify hschema varchar2(30);
alter table xs$nstmpl modify hpname varchar2(30);
alter table xs$nstmpl modify hfname varchar2(30);
alter table rxs$session_appns modify nshandler varchar2(255);

--File rdbms/admin/catupstr.sql

alter table registry$log modify cid VARCHAR2(30);
alter table registry$log modify namespace VARCHAR2(30);

--File rdbms/admin/catwrrtbc.sql

alter table WRR$_FILTERS modify filter_type varchar2(30);
alter table WRR$_FILTERS modify name varchar2(100);
alter table WRR$_FILTERS modify attribute varchar2(100);
alter table WRR$_CAPTURES modify name varchar2(30);
alter table WRR$_CAPTURES modify dbversion varchar2(30);
alter table WRR$_CAPTURES modify directory varchar2(30);
alter table WRR$_CAPTURES modify last_prep_version varchar2(30);
alter table WRR$_CAPTURES modify sqlset_owner varchar2(30);
alter table WRR$_CAPTURES modify sqlset_name varchar2(30);

--File rdbms/admin/catwrrtbp.sql

alter table WRR$_REPLAYS modify name varchar2(30);
alter table WRR$_REPLAYS modify dbversion varchar2(30);
alter table WRR$_REPLAYS modify directory varchar2(30);
alter table WRR$_REPLAYS modify sqlset_owner varchar2(30);
alter table WRR$_REPLAYS modify sqlset_name varchar2(30);
alter table WRR$_REPLAY_SEQ_DATA modify seq_name varchar2(30);
alter table WRR$_REPLAY_SEQ_DATA modify seq_bnm varchar2(30);
alter table WRR$_REPLAY_SEQ_DATA modify seq_bow varchar2(30);
alter table WRR$_SEQUENCE_EXCEPTIONS modify sequence_owner varchar2(30);
alter table WRR$_SEQUENCE_EXCEPTIONS modify sequence_name varchar2(30);

--File rdbms/admin/catxdbpi.sql

alter table xdb.xdb$path_index_params modify name varchar2(30);

--File rdbms/admin/catxidx.sql

alter table XDB.XDB$XIDX_IMP_T modify index_name VARCHAR2(40);
alter table XDB.XDB$XIDX_IMP_T modify schema_name VARCHAR2(40);
alter table XDB.XDB$XIDX_PARAM_T modify param_name VARCHAR2(30);

--File rdbms/admin/daw.bsq

alter table olap_aw_deployment_controls$ modify physical_name varchar2(64);

--File rdbms/admin/dbmshsld.sql

alter table HS_BULKLOAD_VIEW_OBJ modify SCHEMA_NAME varchar2(30);
alter table HS_BULKLOAD_VIEW_OBJ modify VIEW_NAME varchar2(30);
alter table hs$_parallel_metadata modify remote_table_name varchar2(30);
alter table hs$_parallel_metadata modify remote_schema_name varchar2(30);
alter table hs$_parallel_metadata modify hist_column varchar2(30);
alter table hs$_parallel_metadata modify hist_column_type varchar2(30);
alter table hs$_parallel_metadata modify sample_column varchar2(30);
alter table hs$_parallel_metadata modify sample_column_type varchar2(30);
alter table hs$_parallel_partition_data modify remote_table_name varchar2(30);
alter table hs$_parallel_partition_data modify remote_schema_name varchar2(30);
alter table hs$_parallel_histogram_data modify remote_table_name varchar2(30);
alter table hs$_parallel_histogram_data modify remote_schema_name varchar2(30);
alter table hs$_parallel_sample_data modify remote_table_name varchar2(30);
alter table hs$_parallel_sample_data modify remote_schema_name varchar2(30);

--File rdbms/admin/dbmsplts.sql

alter table sys.tts_usr$ modify name varchar2(30);

--File rdbms/admin/dlmnr.bsq

alter table system.logmnr_gt_tab_include$ modify schema_name varchar2(32);
alter table system.logmnr_gt_tab_include$ modify table_name varchar2(32);
alter table system.logmnr_gt_user_include$ modify user_name varchar2(32);

--File rdbms/admin/doptim.bsq

alter table outln.ol$hints modify user_table_name varchar2(64);

--File rdbms/admin/dpart.bsq

alter table defsubpart$ modify spart_name varchar2(34);
alter table defsubpartlob$ modify lob_spart_name varchar2(34);

--File rdbms/admin/drep.bsq

alter table streams$_component modify component_name varchar2(194);

--File rdbms/admin/dsec.bsq

-- lrg 14680081
-- determine AUD$ schema before altering it.
DECLARE
  uname VARCHAR2(30);
BEGIN
  select usr.name into uname
  from sys.tab$ tab, sys.obj$ obj, sys.user$ usr
  where obj.name ='AUD$' AND obj.obj# =tab.obj# AND usr.user# = obj.owner#;

  execute immediate 
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify clientid varchar2(30)';
END;
/

alter table fga_log$ modify clientid varchar2(30);
alter table aclmv$_reflog modify job_name varchar2(30);
alter table aclmv$_reflog modify acl_status varchar2(30);

--File rdbms/admin/mgdtab.sql

alter table mgd_id_category_tab modify owner VARCHAR2(30);

--File rdbms/admin/sbctab.sql

alter table STATS$SQL_PLAN modify object_owner varchar2(30);
alter table STATS$SQL_PLAN modify object_name varchar2(30);
alter table STATS$SQL_PLAN modify qblock_name varchar2(30);
alter table STATS$SEG_STAT_OBJ modify owner varchar(30);
alter table STATS$SEG_STAT_OBJ modify object_name varchar(30);
alter table STATS$SEG_STAT_OBJ modify subobject_name varchar(30);
alter table STATS$STREAMS_CAPTURE modify capture_name varchar2(30);
alter table STATS$PROPAGATION_SENDER modify queue_schema varchar2(30);
alter table STATS$PROPAGATION_SENDER modify queue_name varchar2(30);
alter table STATS$PROPAGATION_SENDER modify dst_queue_schema varchar2(30);
alter table STATS$PROPAGATION_SENDER modify dst_queue_name varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify src_queue_schema varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify src_queue_name varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify dst_queue_schema varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify dst_queue_name varchar2(30);
alter table STATS$BUFFERED_QUEUES modify queue_schema varchar2(30);
alter table STATS$BUFFERED_QUEUES modify queue_name varchar2(30);
alter table STATS$RULE_SET modify owner varchar2(30);
alter table STATS$RULE_SET modify name varchar2(30);

--File rdbms/admin/schutl.sql

alter table SCHEDUTIL$_TEMP_DIR_LIST modify job_owner VARCHAR2(30);
alter table SCHEDUTIL$_TEMP_DIR_LIST modify schedule_name VARCHAR2(30);
alter table schedutil$_schedule_list modify schedule_owner VARCHAR2(30);
alter table schedutil$_schedule_list modify schedule_name VARCHAR2(30);
alter table schedutil$_notifications modify job_name VARCHAR2(30);
alter table schedutil$_notifications modify job_subname VARCHAR2(30);
alter table schedutil$_notifications modify owner VARCHAR2(30);

--File rdbms/admin/spctab.sql

alter table STATS$SQL_PLAN modify object_owner varchar2(30);
alter table STATS$SQL_PLAN modify object_name varchar2(30);
alter table STATS$SQL_PLAN modify object_alias varchar2(65);
alter table STATS$SQL_PLAN modify qblock_name varchar2(30);
alter table STATS$SEG_STAT_OBJ modify owner varchar(30);
alter table STATS$SEG_STAT_OBJ modify object_name varchar(30);
alter table STATS$SEG_STAT_OBJ modify subobject_name varchar(30);
alter table STATS$STREAMS_CAPTURE modify capture_name varchar2(30);
alter table STATS$PROPAGATION_SENDER modify queue_schema varchar2(30);
alter table STATS$PROPAGATION_SENDER modify queue_name varchar2(30);
alter table STATS$PROPAGATION_SENDER modify dst_queue_schema varchar2(30);
alter table STATS$PROPAGATION_SENDER modify dst_queue_name varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify src_queue_schema varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify src_queue_name varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify dst_queue_schema varchar2(30);
alter table STATS$PROPAGATION_RECEIVER modify dst_queue_name varchar2(30);
alter table STATS$BUFFERED_QUEUES modify queue_schema varchar2(30);
alter table STATS$BUFFERED_QUEUES modify queue_name varchar2(30);
alter table STATS$BUFFERED_SUBSCRIBERS modify queue_schema varchar2(30);
alter table STATS$BUFFERED_SUBSCRIBERS modify queue_name varchar2(30);
alter table STATS$BUFFERED_SUBSCRIBERS modify subscriber_name varchar2(30);
alter table STATS$RULE_SET modify owner varchar2(30);
alter table STATS$RULE_SET modify name varchar2(30);

--File rdbms/admin/utlchain.sql

alter table CHAINED_ROWS modify owner_name varchar2(30);
alter table CHAINED_ROWS modify table_name varchar2(30);
alter table CHAINED_ROWS modify cluster_name varchar2(30);
alter table CHAINED_ROWS modify partition_name varchar2(30);
alter table CHAINED_ROWS modify subpartition_name varchar2(30);

--File rdbms/admin/utlchn1.sql

alter table CHAINED_ROWS modify owner_name varchar2(30);
alter table CHAINED_ROWS modify table_name varchar2(30);
alter table CHAINED_ROWS modify cluster_name varchar2(30);
alter table CHAINED_ROWS modify partition_name varchar2(30);
alter table CHAINED_ROWS modify subpartition_name varchar2(30);

--File rdbms/admin/utldim.sql

alter table dimension_exceptions modify owner VARCHAR2(30);
alter table dimension_exceptions modify table_name VARCHAR2(30);
alter table dimension_exceptions modify dimension_name VARCHAR2(30);

--File rdbms/admin/utledtol.sql

alter table ol$ modify ol_name varchar2(30);
alter table ol$ modify category varchar2(30);
alter table ol$ modify creator varchar2(30);
alter table ol$hints modify ol_name varchar2(30);
alter table ol$hints modify category varchar2(30);
alter table ol$hints modify table_name varchar2(30);
alter table ol$hints modify user_table_name varchar2(260);
alter table ol$nodes modify ol_name varchar2(30);
alter table ol$nodes modify category varchar2(30);

--File rdbms/admin/utlexcpt.sql

alter table exceptions modify owner varchar2(30);
alter table exceptions modify table_name varchar2(30);
alter table exceptions modify (constraint varchar2(30));

--File rdbms/admin/utloidxs.sql

alter table INDEX$INDEX_STATS modify TABLE_NAME VARCHAR2(30);
alter table INDEX$INDEX_STATS modify COLUMN_NAME VARCHAR2(30);
alter table INDEX$INDEX_STATS modify STAT_NAME VARCHAR2(30);
alter table INDEX$BADNESS_STATS modify table_name varchar2(30);
alter table INDEX$BADNESS_STATS modify column_name varchar2(30);

--File rdbms/admin/utlspadv.sql

alter table streams$_pa_monitoring modify job_name varchar2(30);
alter table streams$_pa_monitoring modify query_user_name varchar2(30);
alter table streams$_pa_monitoring modify show_stats_table varchar2(30);
alter table streams$_pa_control modify param_unit varchar2(30);

--File rdbms/admin/utltzuv2.sql

alter table sys.sys_tzuv2_temptab modify table_owner VARCHAR2(30);
alter table sys.sys_tzuv2_temptab modify table_name VARCHAR2(30);
alter table sys.sys_tzuv2_va_temptab modify table_owner VARCHAR2(30);
alter table sys.sys_tzuv2_va_temptab modify table_name VARCHAR2(30);
alter table sys.sys_tzuv2_va_temptab1 modify va_of_tstz_typ VARCHAR2(30);

--File rdbms/admin/utlvalid.sql

alter table INVALID_ROWS modify owner_name varchar2(30);
alter table INVALID_ROWS modify table_name varchar2(30);
alter table INVALID_ROWS modify partition_name varchar2(30);
alter table INVALID_ROWS modify subpartition_name varchar2(30);

--File rdbms/admin/utlxaa.sql

alter table user_workload modify username varchar2(30);

--File rdbms/admin/utlxplan.sql

alter table PLAN_TABLE modify object_owner varchar2(30);
alter table PLAN_TABLE modify object_name varchar2(30);
alter table PLAN_TABLE modify object_alias varchar2(65);
alter table PLAN_TABLE modify qblock_name varchar2(30);

--File rdbms/admin/utlxrw.sql

alter table REWRITE_TABLE modify mv_owner VARCHAR2(30);
alter table REWRITE_TABLE modify mv_name VARCHAR2(30);
alter table REWRITE_TABLE modify mv_in_msg VARCHAR2(30);

--File rdbms/admin/xtitab.sql

alter table xti$index modify owner VARCHAR2(30);
alter table xti$index modify index_name VARCHAR2(30);
alter table xti$index modify base_table_schema VARCHAR2(30);
alter table xti$index modify base_table_name VARCHAR2(30);
alter table xti$index modify row_sequence_id VARCHAR2(30);
alter table xti$index_partition_stats modify owner VARCHAR2(30);
alter table xti$index_partition_stats modify index_name VARCHAR2(30);
alter table xti$index_partition_stats modify partition_name VARCHAR2(30);
alter table xti$index_partition_stats modify index_table_name VARCHAR2(30);
alter table xti$index_partition_stats modify index_table_pk_name VARCHAR2(30);
alter table xti$index_partition_stats modify index_table_rowid_idx_name VARCHAR2(30);
alter table xti$index_period_stats modify owner VARCHAR2(30);
alter table xti$index_period_stats modify index_name VARCHAR2(30);
alter table xti$index_period_stats modify partition_name VARCHAR2(30);

--File rdbms/src/server/dict/sqlddl/prvtrctv.sql

alter table utl_recomp_sorted modify owner varchar2(30);
alter table utl_recomp_sorted modify objname varchar2(30);
alter table utl_recomp_sorted modify edition_name varchar2(30);

--File rdbms/src/server/ilm/assistant/create_meta.sql

alter table ilm_toolkit.ilm$_stats_data modify table_owner varchar2(30);
alter table ilm_toolkit.ilm$_stats_data modify table_name varchar2(30);
alter table ilm_toolkit.ilm$_stats_data modify obj_owner varchar2(30);
alter table ilm_toolkit.ilm$_stats_data modify obj_name varchar2(30);
alter table ilm_toolkit.ilm$_invalid_names modify owner varchar2(30);
alter table ilm_toolkit.ilm$_invalid_names modify name varchar2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify TABLE_OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify TABLE_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify PARTITION_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify TABLE_OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify TABLE_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify PARTITION_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify PP_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_PART_KEY_COLUMNS modify OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_PART_KEY_COLUMNS modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_PART_TABLES modify OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VIRT_PART_TABLES modify TABLE_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_RULE_STAGES modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISKGROUP modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_RULES modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify PARTITION_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify TABLE_OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify TABLE_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify OBJECT_OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify OBJECT_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify POLICY_GROUP VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_EVENTS modify PARTITION_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_EVENTS modify TABLE_OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_EVENTS modify TABLE_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_EVENTS modify SEC_PARTITION_NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_POLICY_CLASS modify NAME VARCHAR2(30);
alter table ilm_toolkit.ilm$_job_info modify name varchar2(30);
alter table ilm_toolkit.ilm$_job_info modify username varchar2(30);
alter table ilm_toolkit.ilm$_table_cache modify username varchar2(30);
alter table ilm_toolkit.ilm$_table_index modify owner varchar2(30);
alter table ilm_toolkit.ilm$_table_index modify table_name varchar2(30);
alter table ilm_toolkit.ilm$_table_index modify rule_name varchar2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify TABLENAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify KEY_COLUMN VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify TABLENAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify KEY_COLUMN VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_EVENTS_SCAN modify USERNAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_SQLHASH_RESULT_SET modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_SQLHASH_RESULT_SET modify OWNER VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISK modify NAME VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISK modify FAILGROUP VARCHAR2(30);
alter table ILM_TOOLKIT.ILM$_POLICY modify NAME VARCHAR2(30);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify owner VARCHAR2(30);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify table_owner varchar2(30);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify table_name varchar2(30);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify job_name VARCHAR2(65);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify job_subname VARCHAR2(65);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify chain_name varchar2(65);
alter table ilm_toolkit.ilm$_scheduler_job_run_details modify session_id VARCHAR2(30);

--
-- LI Part 2 - BSQ files
--

--File daw.bsq

alter table aw$ modify awname varchar2(30);
alter table olap_mappings$ modify map_name varchar2(30);
alter table olap_models$ modify model_name varchar2(30);
alter table olap_model_assignments$ modify member_name varchar2(30);
alter table olap_calculated_members$ modify member_name varchar2(30);
alter table olap_descriptions$ modify description_type varchar2(30);
alter table olap_dim_levels$ modify level_name varchar2(30);
alter table olap_attributes$ modify attribute_name varchar2(30);
alter table olap_hierarchies$ modify hierarchy_name varchar2(30);
alter table olap_measures$ modify measure_name varchar2(30);

--File dcore.bsq

alter table ugroup$ modify spare2 varchar2(30);
alter table syn$ modify owner varchar2(30);
alter table syn$ modify name varchar2(30);
alter table typed_view$ modify typeowner varchar2(30);
alter table typed_view$ modify typename varchar2(30);
alter table props$ modify name varchar2(30);
alter table edition$ modify spare2 varchar2(30);
alter table migrate$ modify version# varchar2(30);
alter table viewcon$ modify conname varchar2(30);
alter table ev$ modify base_tbl_name VARCHAR2(30);
alter table evcol$ modify base_tbl_col_name VARCHAR2(30);
alter table container$ modify spare3 varchar2(30);
alter table container$ modify spare4 varchar2(30);
alter table pdb_history$ modify name varchar2(30);
alter table pdb_history$ modify c_pdb_name varchar2(30);
alter table pdb_history$ modify c_db_name varchar2(30);
alter table pdb_history$ modify c_db_uname varchar2(30);
alter table pdb_history$ modify clonetag varchar2(30);
alter table pdb_history$ modify spare3 varchar2(30);
alter table pdb_history$ modify spare4 varchar2(30);
alter table pdbstate$ modify inst_name varchar2(30);

--File ddm.bsq

alter table modelatt$ modify name varchar2(30);
alter table modelatt$ drop column attrspec;

--File ddst.bsq

alter table dst$affected_tables modify table_owner VARCHAR2(30);
alter table dst$affected_tables modify table_name VARCHAR2(30);
alter table dst$error_table modify table_owner VARCHAR2(30);
alter table dst$error_table modify table_name VARCHAR2(30);
alter table dst$trigger_table modify trigger_owner VARCHAR2(30);
alter table dst$trigger_table modify trigger_name VARCHAR2(30);

--File denv.bsq

alter table profname$ modify name varchar2(30);
alter table job$ modify lowner varchar2(30);
alter table job$ modify powner varchar2(30);
alter table job$ modify cowner varchar2(30);
alter table resource_plan$ modify name varchar2(30);
alter table resource_plan$ modify mgmt_method varchar2(30);
alter table resource_plan$ modify mast_method varchar2(30);
alter table resource_plan$ modify pdl_method varchar2(30);
alter table resource_plan$ modify status varchar2(30);
alter table resource_plan$ modify que_method varchar2(30);
alter table resource_consumer_group$ modify name varchar2(30);
alter table resource_consumer_group$ modify mgmt_method varchar2(30);
alter table resource_consumer_group$ modify status varchar2(30);
alter table resource_consumer_group$ modify category varchar2(30);
alter table resource_category$ modify name varchar2(30);
alter table resource_category$ modify status varchar2(30);
alter table resource_plan_directive$ modify plan varchar2(30);
alter table resource_plan_directive$ modify group_or_subplan varchar2(30);
alter table resource_plan_directive$ modify status varchar2(30);
alter table resource_plan_directive$ modify switch_group varchar2(30);
alter table resource_group_mapping$ modify attribute varchar2(30);
alter table resource_group_mapping$ modify consumer_group varchar2(30);
alter table resource_group_mapping$ modify status varchar2(30);
alter table resource_mapping_priority$ modify attribute varchar2(30);
alter table resource_mapping_priority$ modify status varchar2(30);
alter table resource_storage_pool_mapping$ modify attribute varchar2(30);
alter table resource_storage_pool_mapping$ modify value varchar2(30);
alter table resource_storage_pool_mapping$ modify pool_name varchar2(30);
alter table resource_storage_pool_mapping$ modify status varchar2(30);
alter table resource_capability$ modify io_capable varchar2(30);
alter table resource_capability$ modify status varchar2(30);
alter table resource_instance_capability$ modify status varchar2(30);

--File dexttab.bsq

alter table external_tab$ modify default_dir varchar2(30);
alter table external_tab$ modify type$ varchar2(30);
alter table external_location$ modify dir varchar2(30);

--File dfmap.bsq

alter table map_extelement$ modify attrb1_name varchar2(30);
alter table map_extelement$ modify attrb1_val varchar2(30);
alter table map_extelement$ modify attrb2_name varchar2(30);
alter table map_extelement$ modify attrb2_val varchar2(30);
alter table map_extelement$ modify attrb3_name varchar2(30);
alter table map_extelement$ modify attrb3_val varchar2(30);
alter table map_extelement$ modify attrb4_name varchar2(30);
alter table map_extelement$ modify attrb4_val varchar2(30);
alter table map_extelement$ modify attrb5_name varchar2(30);
alter table map_extelement$ modify attrb5_val varchar2(30);
alter table map_complist$ modify comp1_name varchar2(30);
alter table map_complist$ modify comp2_name varchar2(30);
alter table map_complist$ modify comp3_name varchar2(30);
alter table map_complist$ modify comp4_name varchar2(30);
alter table map_complist$ modify comp5_name varchar2(30);

--File djava.bsq

alter table javasnm$ modify short varchar2(30);

--File dlmnr.bsq

alter table SYSTEM.LOGMNRGGC_GTLO modify OWNERNAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTLO modify LVL0NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTLO modify LVL1NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTLO modify LVL2NAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTCS modify COLNAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTCS modify XTYPESCHEMANAME VARCHAR2(30);
alter table SYSTEM.LOGMNRGGC_GTCS modify TYPENAME VARCHAR2(30);
alter table SYSTEM.LOGMNR_PARAMETER$ modify name varchar2(30);
alter table SYS.LOGMNRG_SEED$ modify SCHEMANAME VARCHAR2(30);
alter table SYS.LOGMNRG_SEED$ modify TABLE_NAME VARCHAR2(30);
alter table SYS.LOGMNRG_SEED$ modify COL_NAME VARCHAR2(30);
alter table SYS.LOGMNRG_OBJ$ modify NAME VARCHAR2(30);
alter table SYS.LOGMNRG_OBJ$ modify SUBNAME VARCHAR2(30);
alter table SYS.LOGMNRG_OBJ$ modify REMOTEOWNER VARCHAR2(30);
alter table SYS.LOGMNRG_COL$ modify NAME VARCHAR2(30);
alter table SYS.LOGMNRG_USER$ modify NAME VARCHAR2(30);
alter table SYS.LOGMNRG_TYPE$ modify version varchar2(30);
alter table SYS.LOGMNRG_ATTRIBUTE$ modify name varchar2(30);
alter table SYS.LOGMNRG_KOPM$ modify name varchar2(30);
alter table SYS.LOGMNRG_PROPS$ modify name varchar2(30);

--File dmanage.bsq

alter table smb$config modify parameter_name VARCHAR2(30);
alter table smb$config modify updated_by VARCHAR2(30);
alter table sql$text modify sql_handle VARCHAR2(30);
alter table sqlobj$ modify category VARCHAR2(30);
alter table sqlobj$ modify name VARCHAR2(30);
alter table sqlobj$data modify category VARCHAR2(30);
alter table sqlobj$auxdata modify category VARCHAR2(30);
alter table sqlobj$auxdata modify creator VARCHAR2(30);
alter table sqlobj$auxdata modify parsing_schema_name VARCHAR2(30);
alter table sqlobj$auxdata modify task_exec_name VARCHAR2(30);

insert into sqlobj$data 
  select signature, category, obj_type, plan_id, 
         xmltype(other_xml).extract('/*/outline_data').getClobVal(), 
         null, null 
  from sqlobj$plan 
  where obj_type = 2 and other_xml is not null;

-- bug 20312022 remove ADAPTIVE_PLAN_BASELINE_STATUS flag
update sqlobj$
set    flags = flags - bitand(flags, 128 + 256);
commit;

drop table sqlobj$plan;


--File dobj.bsq

alter table type$ modify version varchar2(30);
alter table type$ modify typ_name varchar2(30);
alter table collection$ modify coll_name varchar2(30);
alter table attribute$ modify name varchar2(30);
alter table method$ modify name varchar2(30);
alter table parameter$ modify name varchar2(30);
alter table kopm$ modify name varchar2(30);
alter table vtable$ modify itypeowner varchar2(30);
alter table vtable$ modify itypename varchar2(30);
alter table opbinding$ modify returnschema varchar2(30);
alter table opbinding$ modify returntype varchar2(30);
alter table opbinding$ modify impschema varchar2(30);
alter table opbinding$ modify imptype varchar2(30);
alter table opbinding$ modify spare1 varchar2(30);
alter table opbinding$ modify spare2 varchar2(30);
alter table indop$ modify filt_nam varchar2(30);
alter table indop$ modify filt_sch varchar2(30);
alter table indop$ modify filt_typ varchar2(30);

--File doptim.bsq

alter table outln.ol$ modify ol_name varchar2(30);
alter table outln.ol$ modify category varchar2(30);
alter table outln.ol$ modify creator varchar2(30);
alter table outln.ol$hints modify ol_name varchar2(30);
alter table outln.ol$hints modify category varchar2(30);
alter table outln.ol$hints modify table_name varchar2(30);
alter table outln.ol$nodes modify ol_name varchar2(30);
alter table outln.ol$nodes modify category varchar2(30);

drop index i_wri$_optstat_hh_obj_icol_st;
alter table wri$_optstat_histhead_history modify colname varchar2(30);
create unique index i_wri$_optstat_hh_obj_icol_st on
  wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
  tablespace sysaux
/

drop index i_wri$_optstat_h_obj#_icol#_st;
alter table wri$_optstat_histgrm_history modify colname varchar2(30);
create index i_wri$_optstat_h_obj#_icol#_st on 
  wri$_optstat_histgrm_history(obj#, intcol#, savtime, colname)
  tablespace sysaux
/

--File dplsql.bsq

alter table procedureinfo$ modify procedurename varchar2(30);
alter table argument$ modify procedure$ varchar2(30);
alter table argument$ modify argument varchar2(30);
alter table argument$ modify type_owner varchar2(30);
alter table argument$ modify type_name varchar2(30);
alter table argument$ modify type_subname varchar2(30);
alter table argument$ modify pls_type varchar2(30);
alter table settings$ modify param varchar2(30);
alter table procedurejava$ modify ownername varchar2(30);
alter table plscope_identifier$ modify symrep varchar2(30);

--File drac.bsq

alter table service$ modify edition varchar2(30);
alter table service$ modify pdb varchar2(30);
alter table service$ modify session_state_consistency varchar2(30);
alter table service$ modify sql_translation_profile varchar2(128);
alter table dir$database_attributes modify attribute_name varchar2(30);
alter table dir$victim_policy modify user_name varchar2(30);
alter table dir$node_attributes modify attribute_name varchar2(30);
alter table dir$service_attributes modify attribute_name varchar2(30);

--File drep.bsq

create table mlog2$ as select * from mlog$;
create table slog2$ as select * from slog$;

alter table mlog2$ modify mowner varchar2(30);
alter table mlog2$ modify master varchar2(30);
alter table mlog2$ modify log varchar2(30);
alter table mlog2$ modify trig varchar2(30);
alter table mlog2$ modify temp_log varchar2(30);
alter table mlog2$ modify purge_job varchar2(30);
alter table slog2$ modify mowner varchar2(30);
alter table slog2$ modify master varchar2(30);

drop index i_slog;
drop table slog$;
drop table mlog$;

drop index i_mlog#;
drop cluster c_mlog#;

create cluster c_mlog# (master varchar2(30), mowner varchar2(30))
/
create index i_mlog# on cluster c_mlog#
/
create table mlog$          /* list of local master tables used by snapshots */
( mowner          varchar2(30) not null,            /* owner of master */
  master          varchar2(30) not null,             /* name of master */
  oldest          date,       /* maximum age of rowid information in the log */
  oldest_pk       date,          /* maximum age of PK information in the log */
  oldest_seq      date,    /* maximum age of sequence information in the log */
  oscn            number,                                   /* scn of oldest */
  youngest        date,                     /* most recent snaptime assigned */
  yscn            number,                   /* set-up scn;  identifies group */
                                          /* of rows set up at time youngest */
  log             varchar2(30) not null,                /* name of log */
  trig            varchar2(30),           /* trigger on master for log */
  flag            number,       /* 0x0001, log contains rowid values         */
                                /* 0x0002, log contains primary key values   */
                                /* 0x0004, log contains filter column values */
                                /* 0x0008, log is imported                   */
                                /* 0x0010, log is created with temp table    */
  mtime           date not null,                    /* DDL modification time */
  temp_log        varchar2(30),/* temp table as updatable snapshot log */
  oldest_oid      date,         /* maximum age of OID information in the log */
  oldest_new      date,              /* maximum age of new values in the log */
  purge_start       date,                                /* purge start date */
  purge_next        varchar2(200),        /* purge next date expression */
  purge_job         varchar2(30),                    /* purge job name */
  last_purge_date   date,                                 /* last purge date */
  last_purge_status number,    /* last purge status: error# or 0 for success */
  rows_purged       number,                     /* last purge: # rows purged */
  oscn_pk           number,      /* maximum scn of PK information in the log */
  oscn_seq          number,/* maximum scn of sequence information in the log */
  oscn_oid          number,     /* maximum scn of OID information in the log */
  oscn_new          number,          /* maximum scn of new values in the log */
  partdobj#         number       /* partition data obj# of the table for log */
)
cluster c_mlog# (master, mowner)
/

create table slog$                     /* list of snapshots on local masters */
( mowner          varchar2(30) not null,            /* owner of master */
  master          varchar2(30) not null,             /* name of master */
  snapshot        date,                 /* identifies V7 snapshots: obsolete */
  snapid          integer,                        /* identifies V8 snapshots */
  sscn            number,                                 /* scn of snapshot */
  snaptime        date               not null,        /* when last refreshed */
  tscn            number,                                 /* scn of snaptime */
  user#           number)                  /* userid for security validation */
cluster c_mlog# (master, mowner)
/
create index i_slog1 on slog$(snaptime)
/

insert into mlog$ select * from mlog2$;
insert into slog$ select * from slog2$;
drop table mlog2$;
drop table slog2$;

truncate table mv_refresh_usage_stats$;

alter table snap$ modify sowner varchar2(30);
alter table snap$ modify vname varchar2(30);
alter table snap$ modify tname varchar2(30);
alter table snap$ modify mview varchar2(30);
alter table snap$ modify mowner varchar2(30);
alter table snap$ modify master varchar2(30);
alter table snap$ modify ustrg varchar2(30);
alter table snap$ modify uslog varchar2(30);
alter table snap$ modify field2 varchar2(30);
alter table snap$ modify mas_roll_seg varchar2(30);
alter table snap$ modify sna_type_owner varchar2(30);
alter table snap$ modify sna_type_name varchar2(30);
alter table snap$ modify mas_type_owner varchar2(30);
alter table snap$ modify mas_type_name varchar2(30);
alter table snap$ modify parent_sowner varchar2(30);
alter table snap$ modify parent_vname varchar2(30);
alter table snap_reftime$ modify sowner varchar2(30);
alter table snap_reftime$ modify vname varchar2(30);
alter table snap_reftime$ modify mowner varchar2(30);
alter table snap_reftime$ modify master varchar2(30);
alter table snap_reftime$ modify change_view varchar2(30);
alter table mlog_refcol$ modify mowner varchar2(30);
alter table mlog_refcol$ modify master varchar2(30);
alter table mlog_refcol$ modify colname varchar2(30);
alter table snap_refop$ modify sowner varchar2(30);
alter table snap_refop$ modify vname varchar2(30);
alter table snap_colmap$ modify sowner varchar2(30);
alter table snap_colmap$ modify vname varchar2(30);
alter table snap_colmap$ modify snacol varchar2(30);
alter table snap_colmap$ modify mascol varchar2(30);
alter table snap_objcol$ modify sowner varchar2(30);
alter table snap_objcol$ modify vname varchar2(30);
alter table snap_objcol$ modify snacol varchar2(30);
alter table snap_objcol$ modify mascol varchar2(30);
alter table snap_objcol$ modify storage_tab_owner varchar2(30);
alter table snap_objcol$ modify storage_tab_name varchar2(30);
alter table snap_objcol$ modify sna_type_owner varchar2(30);
alter table snap_objcol$ modify sna_type_name varchar2(30);
alter table snap_objcol$ modify mas_type_owner varchar2(30);
alter table snap_objcol$ modify mas_type_name varchar2(30);
alter table reg_snap$ modify sowner varchar2(30);
alter table reg_snap$ modify snapname varchar2(30);
alter table rgroup$ modify owner varchar2(30);
alter table rgroup$ modify name varchar2(30);
alter table rgroup$ modify rollback_seg varchar2(30);
alter table rgchild$ modify owner varchar2(30);
alter table rgchild$ modify name varchar2(30);
alter table rgchild$ modify type# varchar2(30);
alter table cdc_change_sources$ modify source_name varchar2(30);
alter table cdc_change_sources$ modify logfile_suffix varchar2(30);
alter table cdc_change_sources$ modify publisher varchar2(30);
alter table cdc_change_sources$ modify capture_name varchar2(30);
alter table cdc_change_sources$ modify capqueue_name varchar2(30);
alter table cdc_change_sources$ modify capqueue_tabname varchar2(30);
alter table cdc_change_sets$ modify set_name varchar2(30);
alter table cdc_change_sets$ modify change_source_name varchar2(30);
alter table cdc_change_sets$ modify rollback_segment_name varchar2(30);
alter table cdc_change_sets$ modify capture_name varchar2(30);
alter table cdc_change_sets$ modify queue_name varchar2(30);
alter table cdc_change_sets$ modify queue_table_name varchar2(30);
alter table cdc_change_sets$ modify apply_name varchar2(30);
alter table cdc_change_sets$ modify publisher varchar2(30);
alter table cdc_change_sets$ modify set_sequence varchar2(30);
alter table cdc_change_sets$ modify time_scn_name varchar2(30);
alter table cdc_change_tables$ modify change_set_name varchar2(30);
alter table cdc_change_tables$ modify source_schema_name varchar2(30);
alter table cdc_change_tables$ modify source_table_name varchar2(30);
alter table cdc_change_tables$ modify change_table_schema varchar2(30);
alter table cdc_change_tables$ modify change_table_name varchar2(30);
alter table cdc_change_tables$ modify mvl_temp_log varchar2(30);
alter table cdc_change_tables$ modify mvl_v7trigger varchar2(30);
alter table cdc_change_tables$ modify mvl_backcompat_view varchar2(30);
alter table cdc_change_tables$ modify mvl_physmvl varchar2(30);
alter table cdc_subscribers$ modify subscription_name varchar2(30);
alter table cdc_subscribers$ modify set_name varchar2(30);
alter table cdc_subscribers$ modify username varchar2(30);
alter table cdc_subscribed_tables$ modify view_name varchar2(30);
alter table cdc_subscribed_columns$ modify column_name varchar2(30);
alter table cdc_change_columns$ modify column_name varchar2(30);
alter table cdc_propagations$ modify propagation_name varchar2(30);
alter table cdc_propagations$ modify destqueue_publisher varchar2(30);
alter table cdc_propagations$ modify destqueue_name varchar2(30);
alter table cdc_propagations$ modify sourceid_name varchar2(30);
alter table cdc_propagated_sets$ modify propagation_name varchar2(30);
alter table cdc_propagated_sets$ modify change_set_publisher varchar2(30);
alter table cdc_propagated_sets$ modify change_set_name varchar2(30);
alter table streams$_split_merge modify original_capture_name VARCHAR2(30);
alter table streams$_split_merge modify cloned_capture_name VARCHAR2(30);
alter table streams$_split_merge modify original_queue_owner VARCHAR2(30);
alter table streams$_split_merge modify original_queue_name VARCHAR2(30);
alter table streams$_split_merge modify cloned_queue_owner VARCHAR2(30);
alter table streams$_split_merge modify cloned_queue_name VARCHAR2(30);
alter table streams$_split_merge modify original_streams_name VARCHAR2(30);
alter table streams$_split_merge modify cloned_streams_name VARCHAR2(30);
alter table streams$_split_merge modify job_owner VARCHAR2(30);
alter table streams$_split_merge modify job_name VARCHAR2(30);
alter table streams$_split_merge modify schedule_owner VARCHAR2(30);
alter table streams$_split_merge modify schedule_name VARCHAR2(30);
alter table streams$_capture_server modify QUEUE_SCHEMA VARCHAR2(30);
alter table streams$_capture_server modify QUEUE_NAME VARCHAR2(30);
alter table streams$_capture_server modify DST_QUEUE_SCHEMA VARCHAR2(30);
alter table streams$_capture_server modify DST_QUEUE_NAME VARCHAR2(30);
alter table streams$_capture_server modify STATUS VARCHAR2(30);
alter table streams$_capture_server modify SPID VARCHAR2(30);
alter table streams$_capture_server modify PROPAGATION_NAME VARCHAR2(30);
alter table streams$_capture_server modify CAPTURE_NAME VARCHAR2(30);
alter table streams$_capture_server modify APPLY_NAME VARCHAR2(30);
alter table streams$_capture_process modify queue_owner varchar2(30);
alter table streams$_capture_process modify queue_name varchar2(30);
alter table streams$_capture_process modify capture_name varchar2(30);
alter table streams$_capture_process modify ruleset_owner varchar2(30);
alter table streams$_capture_process modify ruleset_name varchar2(30);
alter table streams$_capture_process modify negative_ruleset_owner varchar2(30);
alter table streams$_capture_process modify negative_ruleset_name varchar2(30);
alter table streams$_apply_process modify apply_name varchar2(30);
alter table streams$_apply_process modify queue_owner varchar2(30);
alter table streams$_apply_process modify queue_name varchar2(30);
alter table streams$_apply_process modify ruleset_owner varchar2(30);
alter table streams$_apply_process modify ruleset_name varchar2(30);
alter table streams$_apply_process modify negative_ruleset_owner varchar2(30);
alter table streams$_apply_process modify negative_ruleset_name varchar2(30);
alter table streams$_apply_process modify ua_ruleset_owner varchar2(30);
alter table streams$_apply_process modify ua_ruleset_name VARCHAR2(30);
alter table streams$_propagation_process modify propagation_name varchar2(30);
alter table streams$_propagation_process modify source_queue_schema varchar2(30);
alter table streams$_propagation_process modify source_queue varchar2(30);
alter table streams$_propagation_process modify destination_queue_schema varchar2(30);
alter table streams$_propagation_process modify destination_queue varchar2(30);
alter table streams$_propagation_process modify ruleset_schema varchar2(30);
alter table streams$_propagation_process modify ruleset varchar2(30);
alter table streams$_propagation_process modify negative_ruleset_schema varchar2(30);
alter table streams$_propagation_process modify negative_ruleset varchar2(30);
alter table streams$_propagation_process modify original_propagation_name varchar2(30);
alter table streams$_propagation_process modify original_source_queue_schema varchar2(30);
alter table streams$_propagation_process modify original_source_queue varchar2(30);
alter table streams$_extra_attrs modify name varchar2(30);
alter table streams$_extra_attrs modify include varchar2(30);
alter table streams$_key_columns modify sname varchar2(30);
alter table streams$_key_columns modify oname varchar2(30);
alter table streams$_key_columns modify cname varchar2(30);
alter table streams$_def_proc modify owner varchar2(30);
alter table streams$_def_proc modify package_name varchar2(30);
alter table streams$_def_proc modify procedure_name varchar2(30);
alter table streams$_def_proc modify param_name varchar2(30);
alter table streams$_rules modify streams_name varchar2(30);
alter table streams$_rules modify rule_owner varchar2(30);
alter table streams$_rules modify rule_name varchar2(30);
alter table streams$_rules modify schema_name varchar2(30);
alter table streams$_rules modify object_name varchar2(30);
alter table apply$_source_obj modify owner varchar2(30);
alter table apply$_source_obj modify name varchar2(30);
alter table apply$_source_schema modify name varchar2(30);
alter table apply$_virtual_obj_cons modify owner varchar2(30);
alter table apply$_virtual_obj_cons modify name varchar2(30);
alter table apply$_virtual_obj_cons modify powner varchar2(30);
alter table apply$_virtual_obj_cons modify pname varchar2(30);
alter table apply$_virtual_obj_cons modify spare3 varchar2(30);
alter table sys.apply$_constraint_columns modify owner varchar2(30);
alter table sys.apply$_constraint_columns modify name varchar2(30);
alter table sys.apply$_constraint_columns modify constraint_name varchar2(30);
alter table sys.apply$_constraint_columns modify cname varchar2(30);
alter table sys.apply$_constraint_columns modify spare3 varchar2(30);
alter table apply$_dest_obj modify source_owner varchar2(30);
alter table apply$_dest_obj modify source_name varchar2(30);
alter table apply$_dest_obj modify owner varchar2(30);
alter table apply$_dest_obj modify name varchar2(30);
alter table apply$_dest_obj_ops modify sname varchar2(30);
alter table apply$_dest_obj_ops modify oname varchar2(30);
alter table apply$_dest_obj_ops modify apply_name varchar2(30);
alter table apply$_dest_obj_ops modify handler_name varchar2(30);
alter table streams$_stmt_handlers modify handler_name varchar2(30);
alter table apply$_change_handlers modify change_table_owner varchar2(30);
alter table apply$_change_handlers modify change_table_name varchar2(30);
alter table apply$_change_handlers modify source_table_owner varchar2(30);
alter table apply$_change_handlers modify source_table_name varchar2(30);
alter table apply$_change_handlers modify handler_name varchar2(30);
alter table apply$_change_handlers modify apply_name varchar2(30);
alter table apply$_error modify queue_owner varchar2(30);
alter table apply$_error modify queue_name varchar2(30);
alter table apply$_error modify recipient_name varchar2(30);
alter table apply$_conf_hdlr_columns modify column_name varchar2(30);
alter table streams$_dest_obj_cols modify column_name varchar2(30);
alter table streams$_message_rules modify streams_name varchar2(30);
alter table streams$_message_rules modify msg_type_owner varchar2(30);
alter table streams$_message_rules modify msg_type_name varchar2(30);
alter table streams$_message_rules modify msg_rule_var varchar2(30);
alter table streams$_message_rules modify rule_owner varchar2(30);
alter table streams$_message_rules modify rule_name varchar2(30);
alter table streams$_message_rules modify spare4 varchar2(30);
alter table streams$_message_consumers modify streams_name varchar2(30);
alter table streams$_message_consumers modify queue_owner varchar2(30);
alter table streams$_message_consumers modify queue_name varchar2(30);
alter table streams$_message_consumers modify rset_owner varchar2(30);
alter table streams$_message_consumers modify rset_name varchar2(30);
alter table streams$_message_consumers modify neg_rset_owner varchar2(30);
alter table streams$_message_consumers modify neg_rset_name varchar2(30);
alter table streams$_message_consumers modify spare4 varchar2(30);
alter table streams$_apply_spill_txn modify applyname varchar2(30);
alter table streams$_apply_spill_txn modify sender varchar2(30);
alter table fgr$_file_groups modify creator varchar2(30);
alter table fgr$_file_groups modify sequence_name varchar2(30);
alter table fgr$_file_groups modify default_dir_obj varchar2(30);
alter table fgr$_file_groups modify spare3 varchar2(30);
alter table fgr$_file_group_versions modify creator varchar2(30);
alter table fgr$_file_group_versions modify version_name varchar2(30);
alter table fgr$_file_group_versions modify default_dir_obj varchar2(30);
alter table fgr$_file_group_versions modify spare3 varchar2(30);
alter table fgr$_file_group_export_info modify export_version varchar2(30);
alter table fgr$_file_group_export_info modify spare3 varchar2(30);
alter table fgr$_file_group_files modify creator varchar2(30);
alter table fgr$_file_group_files modify file_dir_obj varchar2(30);
alter table fgr$_file_group_files modify spare3 varchar2(30);
alter table fgr$_tablespace_info modify spare3 varchar2(30);
alter table fgr$_table_info modify schema_name varchar2(30);
alter table fgr$_table_info modify table_name varchar2(30);
alter table fgr$_table_info modify spare3 varchar2(30);
alter table redef$ modify name varchar2(30);
alter table redef_object$ modify obj_owner varchar2(30);
alter table redef_object$ modify obj_name varchar2(30);
alter table redef_object$ modify int_obj_owner varchar2(30);
alter table redef_object$ modify int_obj_name varchar2(30);
alter table redef_object$ modify bt_owner varchar2(30);
alter table redef_object$ modify bt_name varchar2(30);
alter table redef_dep_error$ modify obj_owner varchar2(30);
alter table redef_dep_error$ modify obj_name varchar2(30);
alter table redef_dep_error$ modify bt_owner varchar2(30);
alter table redef_dep_error$ modify bt_name varchar2(30);
alter table log$ modify colname varchar2(30);
alter table reco_script$ modify invoking_package_owner varchar2(30);
alter table reco_script$ modify invoking_package varchar2(30);
alter table reco_script$ modify invoking_procedure varchar2(30);
alter table reco_script$ modify invoking_user varchar2(30);
alter table reco_script_params$ modify name varchar2(30);
alter table comparison$ modify comparison_name VARCHAR2(30);
alter table comparison$ modify schema_name VARCHAR2(30);
alter table comparison$ modify object_name VARCHAR2(30);
alter table comparison$ modify rmt_schema_name VARCHAR2(30);
alter table comparison$ modify rmt_object_name VARCHAR2(30);
alter table comparison_col$ modify col_name VARCHAR2(30);
alter table streams$_component_prop modify prop_name varchar2(30);
alter table streams$_database modify version varchar2(30);
alter table streams$_database modify compatibility varchar2(30);
alter table xstream$_server modify server_name varchar2(30);
alter table xstream$_server modify capture_name varchar2(30);
alter table xstream$_server modify queue_owner varchar2(30);
alter table xstream$_server modify queue_name varchar2(30);
alter table xstream$_subset_rules modify server_name varchar2(30);
alter table xstream$_subset_rules modify rules_owner varchar2(30);
alter table xstream$_subset_rules modify insert_rule varchar2(30);
alter table xstream$_subset_rules modify delete_rule varchar2(30);
alter table xstream$_subset_rules modify update_rule varchar2(30);
alter table xstream$_sysgen_objs modify server_name varchar2(30);
alter table xstream$_sysgen_objs modify object_owner varchar2(30);
alter table xstream$_sysgen_objs modify object_name varchar2(30);
alter table xstream$_sysgen_objs modify object_type varchar2(30);
alter table xstream$_parameters modify server_name varchar2(30);
alter table xstream$_parameters modify schema_name varchar2(30);
alter table xstream$_parameters modify object_name varchar2(30);
alter table xstream$_parameters modify user_name varchar2(30);
alter table xstream$_dml_conflict_handler modify object_name varchar2(30);
alter table xstream$_dml_conflict_handler modify schema_name varchar2(30);
alter table xstream$_dml_conflict_handler modify apply_name varchar2(30);
alter table xstream$_dml_conflict_handler modify old_object varchar2(30);
alter table xstream$_dml_conflict_handler modify old_schema varchar2(30);
alter table xstream$_server_connection modify outbound_server varchar2(30);
alter table xstream$_server_connection modify inbound_server varchar2(30);
alter table xstream$_server_connection modify outbound_queue_owner varchar2(30);
alter table xstream$_server_connection modify outbound_queue_name varchar2(30);
alter table xstream$_server_connection modify inbound_queue_owner varchar2(30);
alter table xstream$_server_connection modify inbound_queue_name varchar2(30);
alter table xstream$_server_connection modify rule_set_owner varchar2(30);
alter table xstream$_server_connection modify rule_set_name varchar2(30);
alter table xstream$_server_connection modify negative_rule_set_owner varchar2(30);
alter table xstream$_server_connection modify negative_rule_set_name varchar2(30);
alter table xstream$_ddl_conflict_handler modify apply_name varchar2(30);
alter table xstream$_map modify apply_name varchar2(30);
alter table xstream$_map modify src_obj_owner varchar2(30);
alter table xstream$_map modify tgt_obj_owner varchar2(30);
alter table goldengate$_privileges modify username varchar2(30);
alter table xstream$_privileges modify username varchar2(30);
alter table streams$_prepare_ddl modify c_invoker varchar2(30);
alter table goldengate$_privileges modify c_invoker varchar2(30);
alter table xstream$_privileges modify c_invoker varchar2(30);

--File dsec.bsq

alter table aud_context$ modify namespace varchar2(30);
alter table aud_context$ modify attribute varchar2(30);

-- bug 13843068:
-- delete rows from user_history$, which have SHA-1 or SHA-512 verifiers 
delete from user_history$ where LENGTH(password) > 30;

alter table user_history$ modify password varchar2(30);
alter table rls$ modify gname VARCHAR2(30);
alter table rls$ modify pname VARCHAR2(30);
alter table rls$ modify pfschma VARCHAR2(30);
alter table rls$ modify ppname VARCHAR2(30);
alter table rls$ modify pfname VARCHAR2(30);
alter table rls_sc$ modify gname VARCHAR2(30);
alter table rls_sc$ modify pname VARCHAR2(30);
alter table rls_grp$ modify gname VARCHAR2(30);
alter table rls_ctx$ modify ns VARCHAR2(30);
alter table rls_ctx$ modify attr VARCHAR2(30);

-- lrg 14680081
-- determine AUD$ schema before altering it.
DECLARE
  uname VARCHAR2(30);
BEGIN
  select usr.name into uname
  from sys.tab$ tab, sys.obj$ obj, sys.user$ usr
  where obj.name ='AUD$' AND obj.obj# =tab.obj# AND usr.user# = obj.owner#;

  execute immediate
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify userid varchar2(30)';

  execute immediate
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify obj$creator varchar2(30)';

  execute immediate
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify auth$grantee varchar2(30)';

  execute immediate
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify new$owner varchar2(30)';

  execute immediate
    'alter table ' || dbms_assert.enquote_name(uname) || 
    '.aud$ modify obj$edition varchar2(30)';
END;
/

alter table fga$ modify pname VARCHAR2(30);
alter table fga$ modify pfschma VARCHAR2(30);
alter table fga$ modify ppname VARCHAR2(30);
alter table fga$ modify pfname VARCHAR2(30);
alter table fga$ modify pcol VARCHAR2(30);
alter table fgacol$ modify pname VARCHAR2(30);
alter table fga_log$ modify dbuid varchar2(30);
alter table fga_log$ modify obj$schema varchar2(30);
alter table fga_log$ modify policyname varchar2(30);
alter table fga_log$ modify obj$edition varchar2(30);
alter table approle$ modify schema VARCHAR2(30);
alter table approle$ modify package VARCHAR2(30);
alter table XSDB$SCHEMA_ACL modify schema_name varchar2(30);
alter table aclmv$_reflog modify schema_name varchar2(30);
alter table aclmv$_reflog modify table_name varchar2(30);
alter table aclmv$_reflog modify mview_name varchar2(30);

--File dsqlddl.bsq

alter table link$ modify userid varchar2(30);
alter table link$ modify password varchar2(30);
alter table link$ modify authusr varchar2(30);
alter table link$ modify authpwd varchar2(30);
alter table duc$ modify owner varchar2(30);
alter table duc$ modify pack varchar2(30);
alter table duc$ modify proc varchar2(30);
alter table recyclebin$ modify original_name varchar2(30);
alter table recyclebin$ modify partition_name varchar2(30);
alter table context$ modify schema varchar2(30);
alter table context$ modify package varchar2(30);
alter table sql_version$ modify sql_version varchar2(30);
alter table trigger$ modify refoldname varchar2(30);
alter table trigger$ modify refnewname varchar2(30);
alter table trigger$ modify refprtname varchar2(30);
alter table triggerjavac$ modify ownername varchar2(30);
alter table triggerdep$ modify p_trgowner varchar2(30);
alter table triggerdep$ modify p_trgname varchar2(30);
alter table sqltxl$ modify txlrowner varchar2(30);
alter table sqltxl$ modify txlrname varchar2(30);

--File dsummgt.bsq

alter table sum$ modify containernam varchar2(30);
alter table sum$ modify rw_name varchar2(30);
alter table sumdetail$ modify detailalias varchar2(30);
alter table sumdep$ modify syn_own varchar2(30);
alter table sumdep$ modify syn_name varchar2(30);
alter table hier$ modify hiername varchar2(30);
alter table dimlevel$ modify levelname varchar2(30);
alter table dimattr$ modify attname varchar2(30);

truncate table syncref$_groups;
truncate table syncref$_table_info;
truncate table syncref$_objects;
truncate table syncref$_partn_ops;
truncate table syncref$_group_status;
truncate table syncref$_object_status;
truncate table syncref$_step_status;
truncate table syncref$_log_exceptions; 
truncate table syncref$_parameters;
truncate table syncref$_er_refgrps;
truncate table syncref$_soft_errors;
truncate table syncref$_stlog_stats;
drop sequence syncref_group_id_seq$;
drop sequence syncref_step_seq$;

-- syncref views and synonyms defined in catsnap.sql

drop view DBA_SR_GRP_STATUS_ALL;
drop view dba_sr_grp_status;
drop view user_sr_grp_status_all;
drop view user_sr_grp_status;
drop public synonym dba_sr_grp_status_all;
drop public synonym dba_sr_grp_status;
drop public synonym user_sr_grp_status_all;
drop public synonym user_sr_grp_status;
drop view DBA_SR_OBJ_STATUS_ALL;
drop view dba_sr_obj_status;
drop view user_sr_obj_status_all;
drop view user_sr_obj_status;
drop public synonym dba_sr_obj_status_all;
drop public synonym dba_sr_obj_status;
drop public synonym user_sr_obj_status_all;
drop public synonym user_sr_obj_status;
drop view DBA_SR_OBJ_ALL;
drop view dba_sr_obj;
drop view user_sr_obj_all;
drop view user_sr_obj;
drop public synonym dba_sr_obj_all;
drop public synonym dba_sr_obj;
drop public synonym user_sr_obj_all;
drop public synonym user_sr_obj;
drop view DBA_SR_LOG_EXCEPTIONS;
drop public synonym DBA_SR_LOG_EXCEPTIONS;
drop view USER_SR_LOG_EXCEPTIONS;
drop public synonym USER_SR_LOG_EXCEPTIONS;
drop view DBA_SR_STLOG_STATS;
drop view USER_SR_STLOG_STATS;
drop public synonym DBA_SR_STLOG_STATS;
drop public synonym USER_SR_STLOG_STATS;
drop view DBA_SR_PARTN_OPS;
drop view USER_SR_PARTN_OPS;
drop public synonym DBA_SR_PARTN_OPS;
drop public synonym USER_SR_PARTN_OPS;

-- drop syncref packages
drop package dbms_isyncref;
drop package dbms_sync_refresh;

--File dtools.bsq

alter table incexp modify name varchar2(30);
alter table incfil modify expuser varchar2(30);
alter table expact$ modify owner varchar2(30);
alter table expact$ modify name varchar2(30);
alter table expact$ modify func_schema varchar2(30);
alter table expact$ modify func_package varchar2(30);
alter table expact$ modify func_proc varchar2(30);
alter table noexp$ modify owner varchar2(30);
alter table noexp$ modify name varchar2(30);
alter table exppkgobj$ modify package varchar2(30);
alter table exppkgobj$ modify schema varchar2(30);
alter table exppkgact$ modify package varchar2(30);
alter table exppkgact$ modify schema varchar2(30);
alter table expdepact$ modify package varchar2(30);
alter table expdepact$ modify schema varchar2(30);
alter table expimp_tts_ct$ modify owner varchar2(30);
alter table expimp_tts_ct$ modify tablename varchar2(30);
alter table metaview$ modify type varchar2(30);
alter table metaview$ modify model varchar2(30);
alter table metaview$ modify xmltag varchar2(30);
alter table metaview$ modify udt varchar2(30);
alter table metaview$ modify schema varchar2(30);
alter table metaview$ modify viewname varchar2(30);
alter table metafilter$ modify filter varchar2(30);
alter table metafilter$ modify type varchar2(30);
alter table metafilter$ modify model varchar2(30);
alter table metaxsl$ modify xmltag varchar2(30);
alter table metaxsl$ modify transform varchar2(30);
alter table metaxsl$ modify model varchar2(30);
alter table metaxslparam$ modify model varchar2(30);
alter table metaxslparam$ modify transform varchar2(30);
alter table metaxslparam$ modify type varchar2(30);
alter table metaxslparam$ modify param varchar2(30);
alter table metastylesheet modify name varchar2(30);
alter table metastylesheet modify model varchar2(30);
alter table metascript$ modify htype varchar2(30);
alter table metascript$ modify ptype varchar2(30);
alter table metascript$ modify ltype varchar2(30);
alter table metascript$ modify model varchar2(30);
alter table metascriptfilter$ modify htype varchar2(30);
alter table metascriptfilter$ modify ptype varchar2(30);
alter table metascriptfilter$ modify ltype varchar2(30);
alter table metascriptfilter$ modify filter varchar2(30);
alter table metascriptfilter$ modify pfilter varchar2(30);
alter table metascriptfilter$ modify model varchar2(30);
alter table metanametrans$ modify htype varchar2(30);
alter table metanametrans$ modify ptype varchar2(30);
alter table metanametrans$ modify model varchar2(30);
alter table metapathmap$ modify htype varchar2(30);
alter table metapathmap$ modify model varchar2(30);
alter table impcalloutreg$ modify package varchar2(30);
alter table impcalloutreg$ modify schema varchar2(30);
alter table impcalloutreg$ modify tag varchar2(30);
alter table impcalloutreg$ modify tgt_schema varchar2(30);
alter table impcalloutreg$ modify tgt_object varchar2(30);

--File dtxnspc.bsq

alter table pending_trans$ modify top_db_user varchar2(30);
alter table pending_trans$ modify spare2 varchar2(30);
alter table pending_trans$ modify spare4 varchar2(30);

Rem *************************************************************************
Rem END Longer Identifiers
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Drop Sql Plan Directive objects
Rem *************************************************************************

Rem The dictionary tables are not truncated. It will work even if reupgrade

Rem Views
drop view sys."_BASE_OPT_FINDING";

drop view sys."_BASE_OPT_FINDING_OBJ";

drop view sys."_BASE_OPT_FINDING_OBJ_COL";

drop view sys."_BASE_OPT_DIRECTIVE";

drop public synonym dba_sql_plan_directives;
drop view sys.dba_sql_plan_directives;

drop public synonym dba_sql_plan_dir_objects;
drop view sys.dba_sql_plan_dir_objects;

Rem Packages
drop public synonym dbms_spd;
drop package body sys.dbms_spd;
drop package body sys.dbms_spd_internal;
drop package sys.dbms_spd;
drop package sys.dbms_spd_internal;
drop library sys.dbms_spd_lib;

Rem *************************************************************************
Rem END Drop Sql Plan Directive objects
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Data Guard support
Rem*************************************************************************

drop procedure DBMS_FEATURE_ACTIVE_DATA_GUARD;
drop public synonym dba_redo_db;
drop view dba_redo_db;
drop public synonym dba_redo_log;
drop view dba_redo_log;
drop index system.redo_db_idx;
truncate table system.redo_db;
drop index system.redo_log_idx;
truncate table system.redo_log;
drop index system.redo_rta_idx;
truncate table system.redo_rta;
drop package body sys.pstdy_datapump_support;
drop package sys.pstdy_datapump_support;

Rem*************************************************************************
Rem END Changes for Data Guard support
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN EM Express downgrade
Rem *************************************************************************
Rem Delete EM Express system privileges 
delete from SYSAUTH$ where privilege# in (-346);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-346);
commit; 

Rem Delete EM Express audit options
delete from AUDIT$ where option# in (346);
delete from STMT_AUDIT_OPTION_MAP where option# in (346);
commit;

Rem Drop EM Express schema
TRUNCATE TABLE wri$_emx_files;
DROP SEQUENCE wri$_emx_file_id_seq;
DROP PUBLIC SYNONYM prvt_emx;
DROP package body prvt_emx;
DROP package prvt_emx;

DROP package body prvtemx_admin;
DROP package prvtemx_admin;

DROP package body prvtemx_dbhome;
DROP package prvtemx_dbhome;

DROP package body prvtemx_memory;
DROP package prvtemx_memory;

DROP package body prvtemx_perf;
DROP package prvtemx_perf;

DROP ROLE em_express_all; 
DROP ROLE em_express_basic; 


Rem *************************************************************************
Rem END EM Express downgrade 
Rem *************************************************************************
        
Rem *************************************************************************
Rem BEGIN Downgrade Clustering
Rem *************************************************************************
drop public synonym DBA_CLUSTERING_TABLES ;
drop public synonym ALL_CLUSTERING_TABLES ;
drop public synonym USER_CLUSTERING_TABLES ;

drop public synonym DBA_CLUSTERING_KEYS ;
drop public synonym ALL_CLUSTERING_KEYS ;
drop public synonym USER_CLUSTERING_KEYS ;

drop public synonym DBA_CLUSTERING_DIMENSIONS ;
drop public synonym ALL_CLUSTERING_DIMENSIONS ;
drop public synonym USER_CLUSTERING_DIMENSIONS ;

drop public synonym DBA_CLUSTERING_JOINS ;
drop public synonym ALL_CLUSTERING_JOINS ;
drop public synonym USER_CLUSTERING_JOINS ;

drop view DBA_CLUSTERING_TABLES ;
drop view ALL_CLUSTERING_TABLES ;
drop view USER_CLUSTERING_TABLES ;

drop view DBA_CLUSTERING_KEYS ;
drop view ALL_CLUSTERING_KEYS ;
drop view USER_CLUSTERING_KEYS ;

drop view DBA_CLUSTERING_DIMENSIONS ;
drop view ALL_CLUSTERING_DIMENSIONS ;
drop view USER_CLUSTERING_DIMENSIONS ;

drop view DBA_CLUSTERING_JOINS ;
drop view ALL_CLUSTERING_JOINS ;
drop view USER_CLUSTERING_JOINS ;

truncate table clst$
truncate table clstkey$
truncate table clstdimension$
truncate table clstjoin$

Rem *************************************************************************
Rem End Downgrade Clustering
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Downgrade Zone Maps
Rem *************************************************************************

drop public synonym user_zonemaps;
drop view user_zonemaps;
drop public synonym all_zonemaps;
drop view all_zonemaps;
drop public synonym dba_zonemaps;
drop view dba_zonemaps;

drop public synonym user_zonemap_measures;
drop view user_zonemap_measures;
drop public synonym all_zonemap_measures;
drop view all_zonemap_measures;
drop public synonym dba_zonemap_measures;
drop view dba_zonemap_measures;

alter table sys.sum$ drop (zmapscale);

Rem *************************************************************************
Rem END Downgrade Zone Maps
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for Code-Based Access Control
Rem =======================================================================

drop public synonym USER_CODE_ROLE_PRIVS;
drop public synonym ALL_CODE_ROLE_PRIVS;
drop public synonym DBA_CODE_ROLE_PRIVS;
drop view USER_CODE_ROLE_PRIVS;
drop view ALL_CODE_ROLE_PRIVS;
drop view DBA_CODE_ROLE_PRIVS;
truncate table codeauth$;

Rem =======================================================================
Rem  End Changes for Code-Based Access Control
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Rowid Mapping Table rmtab$
Rem =======================================================================
truncate table rmtab$

Rem =======================================================================
Rem  End Changes for Rowid Mapping Table rmtab$
Rem =======================================================================

Rem Remove SQL Diag Repository views
drop public synonym v$SQL_DIAG_REPOSITORY;
drop view v_$SQL_DIAG_REPOSITORY;
drop public synonym gv$SQL_DIAG_REPOSITORY;
drop view gv_$SQL_DIAG_REPOSITORY;

drop public synonym v$SQL_DIAG_REPOSITORY_REASON;
drop view v_$SQL_DIAG_REPOSITORY_REASON;
drop public synonym gv$SQL_DIAG_REPOSITORY_REASON;
drop view gv_$SQL_DIAG_REPOSITORY_REASON;

Rem *************************************************************************
Rem Resource Manager related downgrade for 12g - BEGIN
Rem *************************************************************************

truncate table cdb_resource_plan$;
truncate table cdb_resource_plan_directive$;

drop view dba_cdb_rsrc_plans;
drop view dba_cdb_rsrc_plan_directives;

drop public synonym dba_cdb_rsrc_plans;
drop public synonym dba_cdb_rsrc_plan_directives;

update resource_plan_directive$ set
  parallel_server_limit = 4294967295;
update resource_plan_directive$ set
  switch_io_logical = 4294967295;
update resource_plan_directive$ set
  switch_elapsed_time = 4294967295;

drop public synonym dbms_rmin_sys;
drop package sys.dbms_rmin_sys;

Rem *************************************************************************
Rem Resource Manager related downgrade for 12g - END
Rem *************************************************************************

Rem *************************************************************************
Rem Privilege Capture changes -BEGIN
Rem *************************************************************************
drop public synonym role_id_list;
drop public synonym role_array;
drop public synonym role_name_list;
drop public synonym grant_path;
drop public synonym dba_priv_captures;
drop public synonym dba_used_privs;
drop public synonym dba_used_sysprivs;
drop public synonym dba_used_objprivs;
drop public synonym dba_used_userprivs;
drop public synonym dba_used_sysprivs_path;
drop public synonym dba_used_objprivs_path;
drop public synonym dba_used_userprivs_path;
drop public synonym dba_used_pubprivs;
drop public synonym dba_unused_privs;
drop public synonym dba_unused_sysprivs;
drop public synonym dba_unused_objprivs;
drop public synonym dba_unused_userprivs;
drop public synonym dba_unused_sysprivs_path;
drop public synonym dba_unused_objprivs_path;
drop public synonym dba_unused_userprivs_path;
drop public synonym dbms_privilege_capture;
drop public synonym g_database;
drop public synonym g_role;
drop public synonym g_context;
drop public synonym g_role_and_context;
drop public synonym dbms_priv_capture;

drop view sys.dba_priv_captures;
drop view sys.dba_used_privs;
drop view sys.dba_used_sysprivs;
drop view sys.dba_used_objprivs;
drop view sys.dba_used_userprivs;
drop view sys.dba_used_sysprivs_path;
drop view sys.dba_used_objprivs_path;
drop view sys.dba_used_userprivs_path;
drop view sys.dba_used_pubprivs;
drop view SYS.dba_unused_privs;
drop view SYS.dba_unused_sysprivs;
drop view SYS.dba_unused_objprivs;
drop view SYS.dba_unused_userprivs;
drop view SYS.dba_unused_sysprivs_path;
drop view SYS.dba_unused_objprivs_path;
drop view sys.dba_unused_userprivs_path;

drop package sys.dbms_privilege_capture;
drop package sys.dbms_priv_capture;
drop role capture_admin;

drop table sys.priv_capture$;
drop table sys.capture_run_log$;
drop table sys.captured_priv$;
drop table sys.priv_used_path$;
drop table sys.priv_unused$;
drop table sys.priv_unused_path$;

drop sequence sys.priv_capture_seq$;
drop sequence sys.priv_used_id$;
drop sequence sys.priv_unused_id$;
drop type sys.role_id_list force;
drop type sys.role_array force;
drop type sys.grant_path force;
drop type sys.role_name_list force;
Rem ************************************************************************
Rem Privilege Capture changes -END
Rem ************************************************************************

Rem *************************************************************************
Rem BEGIN Edition-Based Redefinition downgrade
Rem *************************************************************************

drop public synonym gv$editionable_types;
drop public synonym v$editionable_types;
drop view gv_$editionable_types;
drop view v_$editionable_types;

update user$ set spare1 = spare1 - bitand(spare1, 16) where user#=1;
delete from user$ where ext_username='PUBLIC' and type#=2;
commit;

truncate table user_editioning$;
drop public synonym DBA_EDITIONED_TYPES;
drop public synonym USER_EDITIONED_TYPES;
drop view DBA_EDITIONED_TYPES;
drop view USER_EDITIONED_TYPES;

Rem *************************************************************************
Rem END Edition-Based Redefinition downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Identity columns downgrade
Rem *************************************************************************

drop public synonym USER_TAB_IDENTITY_COLS;
drop public synonym ALL_TAB_IDENTITY_COLS;
drop public synonym DBA_TAB_IDENTITY_COLS;

drop view USER_TAB_IDENTITY_COLS;
drop view ALL_TAB_IDENTITY_COLS;
drop view DBA_TAB_IDENTITY_COLS;

truncate table idnseq$;

Rem *************************************************************************
Rem END Identity columns downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN OLS (Oracle Label Security) downgrade of tab$ property column bit -
Rem These changes are for downgrade from 12.1 to 11.2 - Update the tab$
Rem property column bit to clear the label security flag 
Rem *************************************************************************

UPDATE sys.tab$ t 
SET    t.property = t.property - 70368744177664 
WHERE  BITAND(t.property, 70368744177664) = 70368744177664;
COMMIT;

Rem *************************************************************************
Rem END OLS (Oracle Label Security) downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN UPDATE rls$ to clear Oracle Label Security RLS policies 
Rem *************************************************************************

UPDATE sys.rls$ SET stmt_type = stmt_type - 524288
WHERE  BITAND(stmt_type,524288) = 524288
AND    PFSCHMA = 'LBACSYS';
COMMIT;

Rem *************************************************************************
Rem END UPDATE rls$ to clear Oracle Label Security RLS policies
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Scheduler downgrade actions
Rem *************************************************************************

drop view SCHEDULER$_CDB_CLASS;
drop view SCHEDULER$_CDB_COMB_LW_JOB;
drop view SCHEDULER$_CDB_GLOBAL_ATTRIB;
drop view SCHEDULER$_CDB_JOB;
drop view SCHEDULER$_CDB_LIGHTWEIGHT_JOB;
drop view SCHEDULER$_CDB_PROGRAM;
drop view SCHEDULER$_CDB_WINDOW;
drop view SCHEDULER$_COMB_LW_JOB;
drop view JOB$_CDB;
drop view JOB$_REDUCED;
drop public synonym v$scheduler_inmem_rtinfo;
drop public synonym gv$scheduler_inmem_rtinfo;
drop public synonym v$scheduler_inmem_mdinfo;
drop public synonym gv$scheduler_inmem_mdinfo;
drop view v_$scheduler_inmem_rtinfo;
drop view gv_$scheduler_inmem_rtinfo;
drop view v_$scheduler_inmem_mdinfo;
drop view gv_$scheduler_inmem_mdinfo;

Rem *************************************************************************
Rem END Scheduler downgrade actions
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN system.aq$_queues downgrade actions
Rem *************************************************************************

ALTER TABLE system.aq$_queues DROP COLUMN sharded;

Rem *************************************************************************
Rem END system.aq$_queues downgrade actions
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Fast global index maint during drop/truncate partition downgrade
Rem *************************************************************************

truncate table index_orphaned_entry$;

Rem *************************************************************************
Rem END Fast global index maint during drop/truncate partition downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Replay Context downgrade 
Rem *************************************************************************

drop public synonym v$replay_context;
drop public synonym gv$replay_context;
drop view gv_$replay_context;
drop view v_$replay_context;

drop public synonym v$replay_context_sysdate;
drop public synonym gv$replay_context_sysdate;
drop view gv_$replay_context_sysdate;
drop view v_$replay_context_sysdate;

drop public synonym v$replay_context_systimestamp;
drop public synonym gv$replay_context_systimestamp;
drop view gv_$replaycontext_systimestamp;
drop view v_$replay_context_systimestamp;

drop public synonym v$replay_context_sysguid;
drop public synonym gv$replay_context_sysguid;
drop view gv_$replay_context_sysguid;
drop view v_$replay_context_sysguid;

drop public synonym v$replay_context_sequence;
drop public synonym gv$replay_context_sequence;
drop view gv_$replay_context_sequence;
drop view v_$replay_context_sequence;

drop public synonym v$replay_context_lob;
drop public synonym gv$replay_context_lob;
drop view gv_$replay_context_lob;
drop view v_$replay_context_lob;

Rem *************************************************************************
Rem END Replay Context downgrade
Rem *************************************************************************



Rem********************************************************************************
Rem bug 12710912 : Drop new sequence in dbms_lock package -BEGIN 
Rem********************************************************************************

drop sequence dbms_lock_id_v2;

Rem*********************************************************************************
Rem bug 12710912 : Drop new sequence in dbms_lock package -END
Rem********************************************************************************


Rem********************************************************************************
Rem bug 15925294 : Drop contsraint in dbms_lock_allocated -BEGIN 
Rem********************************************************************************

alter table dbms_lock_allocated drop unique (lockid);


Rem*********************************************************************************
Rem bug 15925294 : Drop constraint in dbms_lock_allocated -END
Rem********************************************************************************


Rem********************************************************************************
Rem lrg 6922637 : Drop procedure in  dbms_lock package -BEGIN 
Rem********************************************************************************

drop procedure dbms_lock.allocate_unique_autonomous

Rem********************************************************************************
Rem lrg 6922637 : Drop procedure in  dbms_lock package -END
Rem********************************************************************************



Rem********************************************************************************
Rem bug 14133199: Drop dbms_feature_spd and dbms_feature_concurrent_stats - BEGIN
Rem********************************************************************************

drop procedure dbms_feature_spd;
drop procedure dbms_feature_concurrent_stats;

Rem********************************************************************************
Rem bug 14133199: Drop dbms_feature_spd and dbms_feature_concurrent_stats - END
Rem********************************************************************************

Rem *************************************************************************
Rem BEGIN User Privilege Metadata downgrade
Rem *************************************************************************

truncate table userauth$;
drop sequence user_grant;
truncate table user_privilege_map;
drop public synonym uesr_privilege_map;
delete from SYSAUTH$ where privilege# in (-352, -355);
delete from SYSTEM_PRIVILEGE_MAP where PRIVILEGE in (-352,-355);
delete from STMT_AUDIT_OPTION_MAP where OPTION# in (352,353,354,355,356);

Rem *************************************************************************
Rem END User Privilege Metadata downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN 12.1 NoLogging Standby downgrade
Rem *************************************************************************

drop public synonym gv$nonlogged_block;
drop public synonym v$nonlogged_block;
drop view gv_$nonlogged_block;
drop view v_$nonlogged_block;

drop public synonym gv$copy_nonlogged;
drop public synonym v$copy_nonlogged;
drop view gv_$copy_nonlogged;
drop view v_$copy_nonlogged;

drop public synonym gv$backup_nonlogged;
drop public synonym v$backup_nonlogged;
drop view gv_$backup_nonlogged;
drop view v_$backup_nonlogged;

Rem *************************************************************************
Rem END 12.1 NoLogging Standby downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem START Stats gathering reporting downgrage actions
Rem *************************************************************************

-- truncate the new table wri$_optstat_opr_tasks
truncate table wri$_optstat_opr_tasks;

-- drop the corresponding view and its public synonym
drop public synonym DBA_OPTSTAT_OPERATION_TASKS;
drop view DBA_OPTSTAT_OPERATION_TASKS;

-- drop the operation id sequence
drop sequence st_opr_id_seq;

update stats_target$ set start_time = null, end_time = null;
update wri$_optstat_opr set id = null, status = null, job_name = null,
                            session_id = null, notes = null;

Rem *************************************************************************
Rem END Stats gathering reporting downgrage actions
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Parallel Task Library downgrade
Rem *************************************************************************

drop public synonym x$kxftask;
drop view v_$kxftask;

Rem *************************************************************************
Rem END Parallel Task Library downgrade
Rem *************************************************************************

Rem ************************************************************************
Rem Oracle FS changes - BEGIN
Rem ************************************************************************

drop PUBLIC SYNONYM dbms_fs;
drop package dbms_fs;

Rem truncate tables created in dbmsfs.sql

truncate table ofsmtab$;
truncate table ofsotab$;
truncate table ofsdtab$;

Rem drop views created for Oracle FS

drop view v_$ofsmount;
drop public synonym v$ofsmount;
drop view gv_$ofsmount;
drop public synonym gv$ofsmount;
drop view v_$ofs_stats;
drop public synonym v$ofs_stats;
drop view gv_$ofs_stats;
drop public synonym gv$ofs_stats;

Rem ************************************************************************
Rem Oracle FS changes - END
Rem ************************************************************************


drop view v_$io_outlier;
drop public synonym v$io_outlier;
drop view gv_$io_outlier;
drop public synonym gv$io_outlier;
drop view v_$lgwrio_outlier;
drop public synonym v$lgwrio_outlier;
drop view gv_$lgwrio_outlier;
drop public synonym gv$lgwrio_outlier;
drop view v_$kernel_io_outlier;
drop public synonym v$kernel_io_outlier;
drop view gv_$kernel_io_outlier;
drop public synonym gv$kernel_io_outlier;
drop view v_$patches;
drop public synonym v$patches;
drop view gv_$patches;
drop public synonym gv$patches;

Rem *************************************************************************
Rem BEGIN v$sql_reoptimization_hints
Rem *************************************************************************

drop public synonym gv$sql_reoptimization_hints;
drop public synonym v$sql_reoptimization_hints;
drop view gv_$sql_reoptimization_hints;
drop view v_$sql_reoptimization_hints;

Rem *************************************************************************
Rem END v$sql_reoptimization_hints
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN DBMS_PART package
Rem *************************************************************************

drop package dbms_part;
drop public synonym dbms_part;

Rem *************************************************************************
Rem END DBMS_PART package
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Database Properties (props$) downgrade changes
Rem *************************************************************************

drop view nls_database_parameters;

Rem *************************************************************************
Rem END Database Properties (props$) downgrade changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN KCB data warehousing big table scan views downgrade
Rem *************************************************************************

drop public synonym gv$bt_scan_obj_temps;
drop public synonym v$bt_scan_obj_temps;
drop view gv_$bt_scan_obj_temps;
drop view v_$bt_scan_obj_temps;

drop public synonym gv$bt_scan_cache;
drop public synonym v$bt_scan_cache;
drop view gv_$bt_scan_cache;
drop view v_$bt_scan_cache;

Rem *************************************************************************
Rem END KCB data warehousing big table scan views downgrade
Rem *************************************************************************

Rem *************************************************************************
Rem DBMS_ROLLING downgrade actions - BEGIN
Rem *************************************************************************

-- truncate base tables
truncate table system.rolling$connections;
truncate table system.rolling$databases;
truncate table system.rolling$directives;
truncate table system.rolling$events;
truncate table system.rolling$parameters;
truncate table system.rolling$plan;
truncate table system.rolling$statistics;
truncate table system.rolling$status;

-- drop event sequence
drop sequence system.rolling_event_seq$;

-- drop views
drop public synonym dba_rolling_databases;
drop view dba_rolling_databases;
drop public synonym dba_rolling_events;
drop view dba_rolling_events;
drop public synonym dba_rolling_parameters;
drop view dba_rolling_parameters;
drop public synonym dba_rolling_plan;
drop view dba_rolling_plan;
drop public synonym dba_rolling_statistics;
drop view dba_rolling_statistics;
drop public synonym dba_rolling_status;
drop view dba_rolling_status;

-- drop package and library
drop public synonym dbms_rolling;
drop package body sys.dbms_rolling;
drop package body sys.dbms_internal_rolling;
drop package sys.dbms_rolling;
drop package sys.dbms_internal_rolling;
drop library sys.dbms_rolling_lib;


Rem *************************************************************************
Rem DBMS_ROLLING downgrade actions - END
Rem *************************************************************************


Rem *************************************************************************
Rem New histogram types downgrade actions - BEGIN
Rem *************************************************************************

Rem #(24309782): downgrade changes for histograms from 12c - BEGIN
Rem

-- Step 1: Delete all histograms that have > 255 buckets
--         They are not supported prior to 12c.
DECLARE
   -- Flag to know whether there is still batch to be processed
   has_next_batch  boolean;

BEGIN

  -- A. Delete histograms that have > 255 buckets from dictionary

  -- Deleting histogram of columns are done in batches to avoid
  -- large rollback segment issues
  -- Assume we have a batch now.
  has_next_batch := true;

  -- Loop over the batches and delete histogram of the batch
  WHILE has_next_batch LOOP

    has_next_batch := false;

    -- inner loop : check all histograms that have > 255 buckets
    FOR cur_col IN (SELECT hhead.obj#, hhead.intcol# 
                    FROM hist_head$ hhead
                    WHERE hhead.row_cnt > 255
                    AND rownum < 1000
                    ORDER BY hhead.obj#) LOOP
        
      -- Reset histogram
      UPDATE hist_head$ hhead
      SET bucket_cnt = 1, row_cnt = 0, cache_cnt = 0,
          spare2 = spare2 - 
                   bitand(spare2, 
                          4     +             -- KQDSCS_EAV
                          32    +             -- KQDSCS_HIST_FREQ
                          64    +             -- KQDSCS_HIST_TOPFREQ
                          128   +             -- KQDSCS_HIST_IGNORE
                          256)                -- KQDSCS_HISTGRM_ONLY
      WHERE cur_col.obj# = hhead.obj# AND cur_col.intcol# = hhead.intcol#;
        
      -- Delete all histograms entry with > 255 buckets
      DELETE FROM histgrm$ hist
      WHERE cur_col.obj# = hist.obj# AND cur_col.intcol# = hist.intcol#;
        
      has_next_batch := true;
     
    END LOOP;  -- for cur_col
      
    COMMIT;
      
  END LOOP;

  -- B. Delete histograms that have > 255 buckets from history

  -- Deleting histogram of columns are done in batches.
  -- Assume we have a batch now.
  has_next_batch := true;

  -- Loop over the batches and delete histogram of the batch
  WHILE has_next_batch LOOP

    has_next_batch := false;

    -- inner loop : check all histograms that have > 255 buckets
    -- sys_extract_utc is used to make sure index access path is used
    -- and sort is avoided for group by
    FOR cur_col IN (SELECT *
                    FROM
                    (SELECT /*+ index(hist i_wri$_optstat_h_obj#_icol#_st) */ 
                       hist.obj#, hist.intcol#, 
                       sys_extract_utc(hist.savtime) savtime
                     FROM wri$_optstat_histgrm_history hist
                     GROUP BY 
                       hist.obj#, hist.intcol#, sys_extract_utc(hist.savtime)
                     HAVING count(*) > 255)
                    WHERE rownum < 1000) LOOP

      -- Reset histogram flags in histhead
      UPDATE /*+ index(hhead i_wri$_optstat_hh_obj_icol_st) */
        wri$_optstat_histhead_history hhead 
      SET flags = flags - 
                  bitand(flags, 
                         4     +             -- DSC_EAVS 
                         64    +             -- DSC_CACHE_CNT
                         4096  +             -- DSC_HIST_FREQ 
                         8192  +             -- DSC_HIST_TOPFREQ
                         16384 +             -- DSC_HIST_IGNORE
                         65536)              -- DSC_HISTGRM_ONLY
      WHERE cur_col.obj# = hhead.obj# AND cur_col.intcol# = hhead.intcol#
        AND cur_col.savtime = sys_extract_utc(hhead.savtime);
        
      -- Delete all histograms entry with > 255 buckets
      DELETE /*+ index(hist i_wri$_optstat_h_obj#_icol#_st) */
      FROM  wri$_optstat_histgrm_history hist
      WHERE cur_col.obj# = hist.obj# AND cur_col.intcol# = hist.intcol#
        AND cur_col.savtime = sys_extract_utc(hist.savtime);

      has_next_batch := true;
     
    END LOOP;  -- for cur_col
      
    COMMIT;
      
  END LOOP;
    
END;       
/  

-- Step 2: 
-- Reset new actual value column and ep_repeat_count introduced in 12c
-- from stats and history as they are not used prior to 12c.

-- A. Clear finalhist
Rem Update newly added columns to null or zero
update finalhist$ set eprepcnt = 0, epvalue_raw = null;
commit;

-- B. Clear DSC_EAVS before clearing actual values in history
update wri$_optstat_histhead_history hhead
set flags = flags - bitand(flags, 4)
where (obj#, intcol#, savtime) in 
      (select obj#, intcol#, savtime
       from wri$_optstat_histgrm_history
       where epvalue_raw is not null);

-- C. Clear repeat count and new actual value columns
update wri$_optstat_histgrm_history set ep_repeat_count = 0,
                                        epvalue_raw = null
where ep_repeat_count != 0 or  epvalue_raw is not null;
commit;

-- D. Clear KQDSCS_EAV before  clearing actual values in dictionary
update hist_head$ hhead
set spare2 = spare2 - bitand(spare2, 4)
where (obj#, intcol#) in 
      (select obj#, intcol#
       from histgrm$
       where epvalue_raw is not null);

-- E. Clear new actual value column
update histgrm$ set epvalue_raw = null
where epvalue_raw is not null;
commit;

-- F. Clear repeat count column
Rem bug-19333670 - ep_repeat_count is a default value column added via fast 
Rem add column optimization to a clustered table. Hence it needs to be set 
Rem unused as code to handle clustered fast added columns is not there on 11.2

alter table histgrm$ set unused (ep_repeat_count);

Rem #(24309782): downgrade changes for histograms from 12c - END

Rem Trim the min/max raw values to 32 bytes if we are downgrading to
Rem 11.1.0.7 as this version cannot handle values larger than 32 bytes.

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version = '11.1.0.7.0' THEN
     
    -- trim min/max values which are longer than 32 bytes.
    -- only some character columns will qualify for this
    -- update, and we expect a small portion of hist_head$
    -- (e.g., ~1% in GSI production db) will be updated.
    update hist_head$ 
    set lowval = case when utl_raw.length(lowval) > 32
                      then utl_raw.substr(lowval, 1, 32)
                 else lowval end,
        hival = case when utl_raw.length(hival) > 32
                     then utl_raw.substr(hival, 1, 32)
                else hival end
    where utl_raw.length(lowval) > 32 or utl_raw.length(hival) > 32;
    
    commit; 

  END IF;
END;
/ 
Rem Please note that we leave extended min/max columns of basic column
Rem statistics tables as they are when we are downgrading to a version
Rem higher than 11.1.0.7 with the following reasoning:
Rem
Rem   >> only the optimizer uses these columns, and the implementation in 
Rem      the downgraded version reads up to the old size regardless of the 
Rem      actual length of data on disk. Hence, there will not be any side 
Rem      effect in terms of restoring the bahavior of the downgraded version.

Rem *************************************************************************
Rem New histogram types downgrade actions - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for OLAP
Rem *************************************************************************

drop view DBA_CUBE_MAPPINGS;
drop view ALL_CUBE_MAPPINGS;
drop view USER_CUBE_MAPPINGS;
DROP PUBLIC SYNONYM DBA_CUBE_MAPPINGS;
DROP PUBLIC SYNONYM ALL_CUBE_MAPPINGS;
DROP PUBLIC SYNONYM USER_CUBE_MAPPINGS;

drop view DBA_CUBE_MEAS_MAPPINGS;
drop view ALL_CUBE_MEAS_MAPPINGS;
drop view USER_CUBE_MEAS_MAPPINGS;
DROP PUBLIC SYNONYM DBA_CUBE_MEAS_MAPPINGS;
DROP PUBLIC SYNONYM ALL_CUBE_MEAS_MAPPINGS;
DROP PUBLIC SYNONYM USER_CUBE_MEAS_MAPPINGS;

drop view DBA_CUBE_DIMNL_MAPPINGS;
drop view ALL_CUBE_DIMNL_MAPPINGS;
drop view USER_CUBE_DIMNL_MAPPINGS;
DROP PUBLIC SYNONYM DBA_CUBE_DIMNL_MAPPINGS;
DROP PUBLIC SYNONYM ALL_CUBE_DIMNL_MAPPINGS;
DROP PUBLIC SYNONYM USER_CUBE_DIMNL_MAPPINGS;

drop view DBA_CUBE_DIM_MAPPINGS;
drop view ALL_CUBE_DIM_MAPPINGS;
drop view USER_CUBE_DIM_MAPPINGS;
DROP PUBLIC SYNONYM DBA_CUBE_DIM_MAPPINGS;
DROP PUBLIC SYNONYM ALL_CUBE_DIM_MAPPINGS;
DROP PUBLIC SYNONYM USER_CUBE_DIM_MAPPINGS;

drop view DBA_CUBE_ATTR_MAPPINGS;
drop view ALL_CUBE_ATTR_MAPPINGS;
drop view USER_CUBE_ATTR_MAPPINGS;
DROP PUBLIC SYNONYM DBA_CUBE_ATTR_MAPPINGS;
DROP PUBLIC SYNONYM ALL_CUBE_ATTR_MAPPINGS;
DROP PUBLIC SYNONYM USER_CUBE_ATTR_MAPPINGS;

drop view DBA_CUBE_DESCRIPTIONS;
drop view USER_CUBE_DESCRIPTIONS;
drop view ALL_CUBE_DESCRIPTIONS;
DROP PUBLIC SYNONYM DBA_CUBE_DESCRIPTIONS;
DROP PUBLIC SYNONYM USER_CUBE_DESCRIPTIONS;
DROP PUBLIC SYNONYM ALL_CUBE_DESCRIPTIONS;

drop view DBA_CUBE_CLASSIFICATIONS;
drop view USER_CUBE_CLASSIFICATIONS;
drop view ALL_CUBE_CLASSIFICATIONS;
DROP PUBLIC SYNONYM DBA_CUBE_CLASSIFICATIONS;
DROP PUBLIC SYNONYM USER_CUBE_CLASSIFICATIONS;
DROP PUBLIC SYNONYM ALL_CUBE_CLASSIFICATIONS;

alter table olap_mappings$ drop (spare2);
alter table olap_descriptions$ drop (spare1);
alter table olap_impl_options$ drop (spare3);
alter table olap_mappings$ rename column map_order to spare2;
alter table olap_descriptions$ rename column description_order to spare1;
alter table olap_impl_options$ rename column option_long_value to spare3;

drop public synonym user_cube_sub_partition_levels;
drop view user_cube_sub_partition_levels;

drop public synonym all_cube_sub_partition_levels;
drop view all_cube_sub_partition_levels;

drop public synonym dba_cube_sub_partition_levels;
drop view dba_cube_sub_partition_levels;

drop public synonym user_cube_named_build_specs;
drop view user_cube_named_build_specs;

drop public synonym all_cube_named_build_specs;
drop view all_cube_named_build_specs;

drop public synonym dba_cube_named_build_specs;
drop view dba_cube_named_build_specs;

drop public synonym user_measure_folder_subfolders;
drop view user_measure_folder_subfolders;

drop public synonym all_measure_folder_subfolders;
drop view all_measure_folder_subfolders;

drop public synonym dba_measure_folder_subfolders;
drop view dba_measure_folder_subfolders;

drop view DBA_CUBE_DEPENDENCIES;
drop view ALL_CUBE_DEPENDENCIES;
drop view USER_CUBE_DEPENDENCIES;
DROP public SYNONYM DBA_CUBE_DEPENDENCIES;
DROP public SYNONYM ALL_CUBE_DEPENDENCIES;
DROP public SYNONYM USER_CUBE_DEPENDENCIES;

truncate table sys.olap_metadata_dependencies$;

drop public synonym DBA_METADATA_PROPERTIES;
drop view DBA_METADATA_PROPERTIES;

drop public synonym ALL_METADATA_PROPERTIES;
drop view ALL_METADATA_PROPERTIES;

drop public synonym USER_METADATA_PROPERTIES;
drop view USER_METADATA_PROPERTIES;

drop public synonym DBA_CUBE_ATTR_UNIQUE_KEYS;
drop view DBA_CUBE_ATTR_UNIQUE_KEYS;

drop public synonym ALL_CUBE_ATTR_UNIQUE_KEYS;
drop view ALL_CUBE_ATTR_UNIQUE_KEYS;

drop public synonym USER_CUBE_ATTR_UNIQUE_KEYS;
drop view USER_CUBE_ATTR_UNIQUE_KEYS;

truncate table sys.olap_metadata_properties$;
drop sequence sys.OLAP_PROPERTIES_SEQ;

drop sequence sys.awlogseq$;

delete from STMT_AUDIT_OPTION_MAP where option# = 393;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -393;
delete from STMT_AUDIT_OPTION_MAP where option# = 394;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -394;
delete from STMT_AUDIT_OPTION_MAP where option# = 395;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -395;
delete from STMT_AUDIT_OPTION_MAP where option# = 396;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -396;

delete from AUDIT_ACTIONS where action = 144;
delete from AUDIT_ACTIONS where action = 145;
delete from AUDIT_ACTIONS where action = 146;
delete from AUDIT_ACTIONS where action = 147;
delete from AUDIT_ACTIONS where action = 148;
delete from AUDIT_ACTIONS where action = 149;

delete from sysauth$ where privilege# in (-393, -394, -395, -396);

INSERT INTO sys.noexp$ (owner, name, obj_type)
  (SELECT u.name, 'AW$'||a.awname, 2
     FROM sys.aw$ a, sys.user$ u
    WHERE awseq# >= 1000 AND u.user#=a.owner#)
/

Rem *************************************************************************
Rem END changes for OLAP
Rem *************************************************************************

Rem clear flags for obj$.flags beyond a ub2
update obj$ set flags=bitand(flags,65535) where flags>65535;

Rem clear flags for seq$.flags beyond a ub1
update seq$ set flags = bitand(flags, 255) where flags > 255;

Rem *************************************************************************
Rem BEGIN changes for Domain Indexes
Rem *************************************************************************
update indpart_param$ set flags = 0;

Rem *************************************************************************
Rem END changes for Domain Indexes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for downgrading plsql type views
Rem *************************************************************************

drop view USER_PLSQL_TYPES;
drop view ALL_PLSQL_TYPES;
drop view DBA_PLSQL_TYPES;
drop public synonym USER_PLSQL_TYPES;
drop public synonym ALL_PLSQL_TYPES;
drop public synonym DBA_PLSQL_TYPES;

drop view USER_PLSQL_COLL_TYPES;
drop view ALL_PLSQL_COLL_TYPES;
drop view DBA_PLSQL_COLL_TYPES;
drop public synonym USER_PLSQL_COLL_TYPES;
drop public synonym ALL_PLSQL_COLL_TYPES;
drop public synonym DBA_PLSQL_COLL_TYPES;

drop view USER_PLSQL_TYPE_ATTRS;
drop view ALL_PLSQL_TYPE_ATTRS;
drop view DBA_PLSQL_TYPE_ATTRS;
drop public synonym USER_PLSQL_TYPE_ATTRS;
drop public synonym ALL_PLSQL_TYPE_ATTRS;
drop public synonym DBA_PLSQL_TYPE_ATTRS;

Rem *************************************************************************
Rem END changes for downgrading plsql type views
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN tempundostat changes
Rem *************************************************************************

drop public synonym v$tempundostat;
drop public synonym gv$tempundostat;
drop view v_$tempundostat;
drop view gv_$tempundostat;

Rem *************************************************************************
Rem END tempundostat changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for TSDP
Rem *************************************************************************

Rem Remove the objects created for TSDP (12gR1)

Rem Drop the Views

drop view DBA_SENSITIVE_DATA;
drop view DBA_DISCOVERY_SOURCE;
drop view DBA_SENSITIVE_COLUMN_TYPES;
drop view DBA_TSDP_POLICY_FEATURE;
drop view DBA_TSDP_POLICY_CONDITION;
drop view DBA_TSDP_POLICY_PARAMETER;
drop view DBA_TSDP_POLICY_TYPE;
drop view DBA_TSDP_POLICY_PROTECTION;
drop view DBA_TSDP_IMPORT_ERRORS;

Rem Drop Public Synonyms

drop public synonym DBA_SENSITIVE_DATA;
drop public synonym DBA_DISCOVERY_SOURCE;
drop public synonym DBA_SENSITIVE_COLUMN_TYPES;
drop public synonym DBA_TSDP_POLICY_FEATURE;
drop public synonym DBA_TSDP_POLICY_CONDITION;
drop public synonym DBA_TSDP_POLICY_PARAMETER;
drop public synonym DBA_TSDP_POLICY_TYPE;
drop public synonym DBA_TSDP_POLICY_PROTECTION;
drop public synonym DBA_TSDP_IMPORT_ERRORS;

Rem Truncate tables created for Datapump

truncate table dba_sensitive_data_tbl;
truncate table dba_tsdp_policy_protection_tbl;

Rem Truncate catalog tables (disable constraints so that tables be truncated)

truncate table tsdp_feature_policy$;
truncate table tsdp_protection$;
truncate table tsdp_association$;
truncate table tsdp_parameter$;
truncate table tsdp_condition$;

alter table tsdp_condition$ disable constraint tsdp_condition$fk;
alter table tsdp_parameter$ disable constraint tsdp_parameter$fk;
alter table tsdp_protection$ disable constraint tsdp_protection$fkpc;
truncate table tsdp_subpol$;

alter table tsdp_subpol$ disable constraint tsdp_subpol$fk;
alter table tsdp_association$ disable constraint tsdp_association$fkpo;
truncate table tsdp_policy$;

alter table tsdp_association$ disable constraint tsdp_association$fkst;
truncate table tsdp_sensitive_type$;

alter table tsdp_sensitive_type$ disable constraint tsdp_sensitive_type$fk;
truncate table tsdp_source$;

alter table tsdp_protection$ disable constraint tsdp_protection$fksd;
truncate table tsdp_sensitive_data$;

truncate table tsdp_error$;

Rem Drop Sequences

drop sequence tsdp_polname$sequence;
drop sequence tsdp_protection$sequence;
drop sequence tsdp_association$sequence;
drop sequence tsdp_subpol$sequence;
drop sequence tsdp_policy$sequence;
drop sequence tsdp_type$sequence;
drop sequence tsdp_source$sequence;
drop sequence tsdp_sensitive$sequence;

Rem Drop Package related objects

drop public synonym dbms_tsdp_protect;
drop package body dbms_tsdp_protect;
drop package dbms_tsdp_protect;
drop public synonym dbms_tsdp_manage;
drop package body dbms_tsdp_manage;
drop package dbms_tsdp_manage;
drop library dbms_tsdp_lib;

drop public synonym v$tsdp_supported_feature;
drop public synonym gv$tsdp_supported_feature;
drop view v_$tsdp_supported_feature;
drop view gv_$tsdp_supported_feature;

Rem Clear col$.property flags
Rem KQLDCOP2_SEN    : 0x0000080000000000 : 8796093022208
Rem KQLDCOP2_SENDEP : 0x0000200000000000 : 35184372088832
BEGIN
  UPDATE sys.col$ 
  SET property = 
      CASE
        -- if KQLDCOP2_SEN and KQLDCOP2_SENDEP.
        WHEN (bitand(property, 8796093022208)=8796093022208 
              AND bitand(property, 35184372088832)=35184372088832)
          THEN      
            property-(8796093022208+35184372088832)
        -- if only KQLDCOP2_SEN is set.
        WHEN bitand(property, 8796093022208)=8796093022208 
          THEN
            property-8796093022208
        -- if only KQLDCOP2_SENDEP is set.
        WHEN bitand(property, 35184372088832)=35184372088832 
          THEN
            property-35184372088832
        ELSE property
      END
  WHERE bitand(property, 8796093022208)=8796093022208 
        OR bitand(property, 35184372088832)=35184372088832;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/

Rem *************************************************************************
Rem END Changes for TSDP
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN drop for CLONEDFILE 
Rem *************************************************************************

drop public synonym v$clonedfile;
drop view v_$clonedfile;
drop public synonym gv$clonedfile;
drop view gv_$clonedfile;

Rem *************************************************************************
Rem END drop for CLONEDFILE
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN changes for downgrading Queryable patch inventory objects
Rem *************************************************************************

-- Drop Packages, Types, sequence, tables, procedure.
DROP PACKAGE BODY dbms_qopatch;
DROP PACKAGE dbms_qopatch;

DROP TABLE opatch_xml_inv;
TRUNCATE TABLE opatch_inst_job;
TRUNCATE TABLE opatch_xinv_tab;

DROP DIRECTORY opatch_log_dir;
DROP DIRECTORY opatch_script_dir;

Rem *************************************************************************
Rem END changes for downgrading Queryable patch inventory objects
Rem *************************************************************************
  
Rem *************************************************************************
Rem BEGIN 1874004: Drop SQL registry
Rem *************************************************************************

DROP VIEW dba_registry_sqlpatch;
TRUNCATE TABLE registry$sqlpatch;

Rem *************************************************************************
Rem END 1874004: Drop SQL registry
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
     AND REGEXP_LIKE(o.name, 'SYS_PLSQL_[[:alnum:]]+_[[:alnum:]]+_[12]')
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
Rem *************************************************************************
Rem Downgrade aq$_subscriber - START
Rem *************************************************************************
ALTER TYPE sys.aq$_subscriber DROP ATTRIBUTE
 (subscriber_id,                                      -- subscriber id
  pos_bitmap           -- subscriber position in bitmap for 12c queues
 )
CASCADE
/

drop public synonym v$aq_msgbm;
drop public synonym gv$aq_msgbm;
drop view v_$aq_msgbm;
drop view gv_$aq_msgbm;

Rem *************************************************************************
Rem Downgrade aq$_subscriber - END
Rem *************************************************************************

Rem *************************************************************************
Rem Downgrade [G]V$AQ_NONDUR_REGISTRATIONS - START
Rem *************************************************************************

drop public synonym v$aq_nondur_registrations;
drop public synonym gv$aq_nondur_registrations;
drop view v_$aq_nondur_registrations;
drop view gv_$aq_nondur_registrations;

Rem *************************************************************************
Rem Downgrade [G]V$AQ_NONDUR_REGISTRATIONS - END
Rem *************************************************************************

Rem *************************************************************************
Rem Downgrade [G]V$AQ_MESSAGE_CACHE - START
Rem *************************************************************************

drop public synonym v$aq_message_cache;
drop public synonym gv$aq_message_cache;
drop view v_$aq_message_cache;
drop view gv_$aq_message_cache;

Rem *************************************************************************
Rem Downgrade [G]V$AQ_NONDUR_REGISTRATIONS - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN  #(9316756) drop views created for stats transfer during datapump
Rem *************************************************************************

DROP VIEW "_user_stat";

DROP VIEW "_user_stat_varray";

Rem *************************************************************************
Rem END drop views created for stats transfer during datapump
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN evaluation edition changes
Rem *************************************************************************

update snap$ set eval_edition = null;
update sum$ set evaledition#=0, unusablebefore#=0, unusablebeginning#=0;
commit;

Rem *************************************************************************
Rem END evaluation edition changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN  application continuity changes
Rem *************************************************************************

truncate table sys.ltxid_trans;

Rem *************************************************************************
Rem END application continuity changes
Rem *************************************************************************

Rem =======================================================================
Rem  Bug #14162791 : enhancement to utl_recomp
Rem =======================================================================
drop view utl_recomp_invalid_mv;
Rem =======================================================================
Rem  End Changes for Bug #14162791
Rem =======================================================================  
Rem *************************************************************************
Rem BEGIN  dropping a package in prvtcmpr.sql
Rem *************************************************************************
drop package prvt_compress;

Rem *************************************************************************
Rem END  dropping a package in prvtcmpr.sql
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Clean up various synonyms, views, packages, libraries, procedures
Rem       and functions
Rem *************************************************************************

alter table WRH$_TABLESPACE drop column block_size;

drop package dbms_xstream_auth_ivk;
drop package dbms_prvtsqis;
drop package dbms_sync_refresh;
drop public synonym dbms_sync_refresh;
drop type xs$realm_constraint_type force;
drop package dbms_apply_adm_ivk;
drop public synonym dba_alert_history_detail;
drop view dba_alert_history_detail;
drop package dbms_service_err;
drop public synonym dbms_service_err; 
drop package dbms_capture_adm_ivk;
drop procedure dbms_pdb_exec_sql;
drop public synonym dbms_pdb_exec_sql;
drop package dbms_streams_adm_ivk;
drop public synonym dbms_streams_adm_ivk;
drop package tsdp$datapump;
drop public synonym v$restore_range;
drop view v_$restore_range;
drop public synonym v$disk_restore_range;
drop view v_$disk_restore_range;
drop public synonym v$sbt_restore_range;
drop view v_$sbt_restore_range;
drop function v_listRsRangePipe;
drop type v_RangeRecSetImpl_t force;
drop type v_RangeRecSet_t force;
drop type v_RangeRec_t force;
drop package amgt$datapump;
drop public synonym dba_alert_history_detail;
drop view dba_alert_history_detail;
drop package dbms_dbfs_content_admin;
drop public synonym dbms_dbfs_content_admin;
drop package dbms_dbfs_content;
drop public synonym dbms_dbfs_content;
drop view dba_hist_ash_snapshot;
drop public synonym dba_hist_ash_snapshot;
drop package dbms_dbfs_sfs_admin;
drop public synonym dbms_dbfs_sfs_admin;
drop package dbms_dbfs_sfs;
drop public synonym dbms_dbfs_sfs;
drop view dbfs_content_properties;
drop public synonym dbfs_content_properties;
drop package dbms_fuse;
drop public synonym dbms_fuse;
drop view gv_$ios_client;
drop public synonym gv$ios_client;
drop view v_$ios_client;
drop public synonym  v$ios_client;
drop package dbms_result_cache_internal;
drop function original_sql_txt;
drop public synonym ora_original_sql_txt;
drop package dbms_prvtsqds;
drop view dbfs_content;
drop public synonym dbfs_content;
drop view dba_hist_tablespace;
drop public synonym dba_hist_tablespace;
drop public synonym v$dead_cleanup;
drop public synonym gv$dead_cleanup;
drop view v_$dead_cleanup;
drop view gv_$dead_cleanup;
drop public synonym v$cell_ofl_thread_history;
drop view v_$cell_ofl_thread_history;
drop public synonym gv$cell_ofl_thread_history;
drop view gv_$cell_ofl_thread_history;
drop public synonym v$sessions_count;
drop view v_$sessions_count;
drop public synonym gv$sessions_count;
drop view gv_$sessions_count;
drop function getlong;
drop view INT$DBA_SOURCE;
drop view INT$DBA_CLUSTERS;
drop view INT$DBA_SYNONYMS;
drop view INT$DBA_VIEWS;
drop view INT$DBA_CONSTRAINTS;
drop view "_INT$_ALL_SYNONYMS_FOR_SYN";
drop view "_INT$_ALL_SYNONYMS_FOR_AO";
drop view INT$DBA_IDENTIFIERS;
drop view INT$DBA_LIBRARIES;
drop view INT$DBA_PROCEDURES;
drop view INT$DBA_DIRECTORIES;
drop view INT$DBA_ARGUMENTS;
drop public synonym DBA_HIST_PDB_INSTANCE;
drop view DBA_HIST_PDB_INSTANCE;
drop package dbms_objects_apps_utils;

Rem *************************************************************************
Rem END Cleanup various synonyms, views, packages, libraries, procedures 
Rem     and functions
Rem ************************************************************************

Rem**************************************************************************
Rem START Changes for ADVANCED Index Compression
Rem**************************************************************************

drop procedure DBMS_FEATURE_ADV_IDXCMP;

Rem**************************************************************************
Rem END Changes for ADVANCED Index Compression
Rem**************************************************************************

Rem**************************************************************************
Rem START Changes for Online redefinition feature tracking
Rem**************************************************************************

drop procedure DBMS_FEATURE_ONLINE_REDEF;

Rem**************************************************************************
Rem END Changes for Online redefintion feature tracking
Rem**************************************************************************

Rem**************************************************************************
Rem START Changes for Oracle Pluggable Database feature tracking
Rem**************************************************************************

drop procedure DBMS_PDB_NUM;

Rem**************************************************************************
Rem END Changes for Oracle Pluggable Database feature tracking
Rem**************************************************************************

Rem**************************************************************************
Rem START Changes for Txn Dictionary
Rem**************************************************************************

truncate table undohist$;

Rem**************************************************************************
Rem END Changes for Txn Dictionary
Rem**************************************************************************

Rem *************************************************************************
Rem END Downgrade Actions for 12.1
Rem ************************************************************************* 

Rem**************************************************************************
Rem Clear 0x10 bit of user$.astatus column. 
Rem In 12.1, this bit identifies Default Accout using Default password
Rem**************************************************************************
update user$ set astatus = (astatus - 16) where BITAND(astatus, 16) = 16;
commit;

Rem**************************************************************************
Rem START plsql procedure to cleanup failed online move operations
Rem**************************************************************************

-- drop views
drop view INDEX_ORPHANED_ENTRY_V$;

-- drop library
drop library dbms_part_lib;

Rem**************************************************************************
Rem END plsql procedure to cleanup failed online move operations
Rem**************************************************************************

Rem *************************************************************************
Rem Bug 15892490
Rem  Delete the V$ XA synonyms and D$ views. 
Rem
Rem *************************************************************************
drop synonym v$xatrans$;
drop synonym v$pending_xatrans$;
drop view d$xatrans$;
drop view d$pending_xatrans$;

Rem**************************************************************************
Rem START Changes for Move Partition Online Compress feature tracking
Rem**************************************************************************

drop procedure DBMS_FEATURE_SEG_MAIN_ONL_COMP;

Rem**************************************************************************
Rem END Changes for Move Partition Online Compress feature tracking
Rem**************************************************************************

Rem *************************************************************************
Rem Bug 16025907                                                             
Rem  The range for Operator capabilities (OPN) was increased 999 to 4999.    
Rem  Drop all FDS classes, and adjust HS$_BASE_CAPS                          
Rem  All gateways will re-upload their FDS classes next time they connect in 
Rem  the appropriate ranges.                                                 
Rem *************************************************************************
                                                                             
DECLARE                                                                      
  classname varchar(30);                                                     
  cursor c1 is select FDS_CLASS_NAME from HS_FDS_CLASS;                      
BEGIN                                                                        
                                                                             
  open c1;                                                                   
                                                                             
  LOOP                                                                       
    fetch c1 into classname;                                                 
      exit when c1%NOTFOUND;                                                 
                                                                             
     dbms_hs.drop_fds_class(classname);                                       
  END LOOP;                                                                    
END;
/

exec dbms_hs.replace_base_caps(5000, 1000, 'multicolumn: (a,b,c)=');
exec dbms_hs.replace_base_caps(5001, 1001, 'join');
exec dbms_hs.replace_base_caps(5002, 1002, 'outer join');
exec dbms_hs.replace_base_caps(5003, 1003, 'delimited IDs: "id"');
exec dbms_hs.replace_base_caps(5004, 1004, 'SELECT DISTINCT');
exec dbms_hs.replace_base_caps(5005, 1005, 'DISTINCT in aggregate functions');
exec dbms_hs.replace_base_caps(5006, 1006, 'ROWNUM');
exec dbms_hs.replace_base_caps(5007, 1007, 'subquery');
exec dbms_hs.replace_base_caps(5008, 1008, 'GROUP BY');
exec dbms_hs.replace_base_caps(5009, 1009, 'HAVING');
exec dbms_hs.replace_base_caps(5010, 1010, 'ORDER BY');
exec dbms_hs.replace_base_caps(5011, 1011, 'CONNECT BY');
exec dbms_hs.replace_base_caps(5012, 1012, 'START WITH');
exec dbms_hs.replace_base_caps(5013, 1013, 'WHERE');
exec dbms_hs.replace_base_caps(5014, 1014, 'callback');
exec dbms_hs.replace_base_caps(5015, 1015, 'add redundant local filters');
exec dbms_hs.replace_base_caps(5016, 1016, 'ROWID');
exec dbms_hs.replace_base_caps(5017, 1017, 'ANY');
exec dbms_hs.replace_base_caps(5018, 1018, 'ALL');
exec dbms_hs.replace_base_caps(5019, 1019, 'EXISTS');
exec dbms_hs.replace_base_caps(5020, 1020, 'NOT EXISTS');
exec dbms_hs.replace_base_caps(5021, 1021, 'nls parameters');
exec dbms_hs.replace_base_caps(5022, 1022, 'describe index');
exec dbms_hs.replace_base_caps(5023, 1023, 'distributed read consistency');
exec dbms_hs.replace_base_caps(5024, 1024, 'bundled calls');
exec dbms_hs.replace_base_caps(5025, 1025, 'evaluate USER, UID, SYDATE local');
exec dbms_hs.replace_base_caps(5026, 1026, 'KGL operation for PL/SQL RPC');
exec dbms_hs.replace_base_caps(5027, 1027, 'NVL: change ANSI to ORA compare');
exec dbms_hs.replace_base_caps(5028, 1028, 'remote mapping of queries');
exec dbms_hs.replace_base_caps(5029, 1029, '2PC type (RO-SS-CC-PREP/2P-2PCC)');
exec dbms_hs.replace_base_caps(5030, 1030, 'streamed protocol version number');
exec dbms_hs.replace_base_caps(5031, 1031, 'special non-optdef functions');
exec dbms_hs.replace_base_caps(5032, 1032, 'CURRVAL and NEXTVAL');
exec dbms_hs.replace_base_caps(5033, 1033, 'hints (inline comments and aliases');
exec dbms_hs.replace_base_caps(5034, 1034, 'remote sort by index access');
exec dbms_hs.replace_base_caps(5035, 1035, 'use universal rowid for rowids');
exec dbms_hs.replace_base_caps(5036, 1036, 'wait option in select for update');
exec dbms_hs.replace_base_caps(5037, 1037, 'connect by order siblings by');
exec dbms_hs.replace_base_caps(5038, 1038, 'On clause');
exec dbms_hs.replace_base_caps(5039, 1039, 'no supprt for rem extended partn');
exec dbms_hs.replace_base_caps(5040, 1040, 'SPREADSHEET clause');
exec dbms_hs.replace_base_caps(5041, 1041, 'Merge optional WHERE clauses');
exec dbms_hs.replace_base_caps(5042, 1042, 'connect by nocycle');
exec dbms_hs.replace_base_caps(5043, 1043, 'connect by enhancements: connect_by_iscycle, connect_by_isleaf');
exec dbms_hs.replace_base_caps(5044, 1044, 'Group Outer-Join');
exec dbms_hs.replace_base_caps(5045, 1045, ' u''xxx\ffff''');
exec dbms_hs.replace_base_caps(5046, 1046, '"with check option" in from-clause subqueries');
exec dbms_hs.replace_base_caps(5047, 1047, 'new connect-by');
exec dbms_hs.replace_base_caps(5048, 1048, 'native full outer join');
exec dbms_hs.replace_base_caps(5049, 1049, 'recursive WITH');
exec dbms_hs.replace_base_caps(5050, 1050, 'column alias list for WITH clause');
exec dbms_hs.replace_base_caps(5051, 1051, 'WAIT option in LOCK TABLE');
exec dbms_hs.replace_base_caps(5963, 1963, 'FDS can not DescribeParam after Exec in Transact SQL');
exec dbms_hs.replace_base_caps(5964, 1964, 'FDS can handle schema in queries');
exec dbms_hs.replace_base_caps(5965, 1965, 'Null is Null');
exec dbms_hs.replace_base_caps(5966, 1966, 'ANSI Decode (CASE) support');
exec dbms_hs.replace_base_caps(5967, 1967, 'Result set support');
exec dbms_hs.replace_base_caps(5968, 1968, 'Piecewise fetch and exec');
exec dbms_hs.replace_base_caps(5969, 1969, 'How to handle PUBLIC schema');
exec dbms_hs.replace_base_caps(5970, 1970, 'Subquery in having clause is supported');
exec dbms_hs.replace_base_caps(5971, 1971, 'Do not close and re-parse on re-exec of SELECTs');
exec dbms_hs.replace_base_caps(5972, 1972, 'Informix related cap: Add space before negative numeric literals');
exec dbms_hs.replace_base_caps(5973, 1973, 'Informix related cap: Add extra parenthesis for update sub-queries to make it a list');
exec dbms_hs.replace_base_caps(5974, 1974, 'DB2-related cap: Change empty str assigns to null assigns');
exec dbms_hs.replace_base_caps(5975, 1975, 'DB2-related cap: Zero length bind not same as null bind');
exec dbms_hs.replace_base_caps(5976, 1976, 'DB2-related cap: Add space after comma');
exec dbms_hs.replace_base_caps(5977, 1977, 'DB2-related cap: Order-by clause contains only numbers');
exec dbms_hs.replace_base_caps(5978, 1978, 'DB2-related cap: Change empty string comparisons to is null');
exec dbms_hs.replace_base_caps(5979, 1979, 'Implicit Coercion cap: Comparison of two objrefs');
exec dbms_hs.replace_base_caps(5980, 1980, 'Implicit Coercion cap: Comparison of objref and bindvar');
exec dbms_hs.replace_base_caps(5981, 1981, 'Implicit Coercion cap: Comparison of objref and literal');
exec dbms_hs.replace_base_caps(5982, 1982, 'Implicit Coercion cap: Comparison of two bindvars');
exec dbms_hs.replace_base_caps(5983, 1983, 'Implicit Coercion cap: Comparison of bindvar and literal');
exec dbms_hs.replace_base_caps(5984, 1984, 'Implicit Coercion cap: Comparison of two literals');
exec dbms_hs.replace_base_caps(5985, 1985, 'Implicit Coercion cap: Assignment of objref to column');
exec dbms_hs.replace_base_caps(5986, 1986, 'Implicit Coercion cap: Assignment of bindvar to column');
exec dbms_hs.replace_base_caps(5987, 1987, 'Implicit Coercion cap: Assignment of literal to column');
exec dbms_hs.replace_base_caps(5988, 1988, 'RPC Bundling Capability');
exec dbms_hs.replace_base_caps(5989, 1989, 'hoatcis() call capability');
exec dbms_hs.replace_base_caps(5990, 1990, 'Quote Owner names in SQL statements');
exec dbms_hs.replace_base_caps(5991, 1991, 'Map Alias to table names in non-select statements');
exec dbms_hs.replace_base_caps(5992, 1992, 'Send Delimited IDs to FDS');
exec dbms_hs.replace_base_caps(5993, 1993, 'HOA Describe Table Call Capability');
exec dbms_hs.replace_base_caps(5994, 1994, 'Raw literal format');
exec dbms_hs.replace_base_caps(5995, 1995, 'FOR UPDATE syntax mapping');
exec dbms_hs.replace_base_caps(5996, 1996, 'Replace NULLs in select list with other constant');
exec dbms_hs.replace_base_caps(5997, 1997, 'flush describe table cache');
exec dbms_hs.replace_base_caps(5998, 1998, 'length of physical part of rowid');
exec dbms_hs.replace_base_caps(5999, 1999, 'Bind to parameter mapping');
exec dbms_hs.replace_base_caps(6000, 2000, 'SELECT ... FOR UPDATE');
exec dbms_hs.replace_base_caps(6001, 2001, 'SELECT');
exec dbms_hs.replace_base_caps(6002, 2002, 'UPDATE');
exec dbms_hs.replace_base_caps(6003, 2003, 'DELETE');
exec dbms_hs.replace_base_caps(6004, 2004, 'INSERT ... VALUES (...)');
exec dbms_hs.replace_base_caps(6005, 2005, 'INSERT ... SELECT ...');
exec dbms_hs.replace_base_caps(6006, 2006, 'LOCK TABLE');
exec dbms_hs.replace_base_caps(6007, 2007, 'ROLLBACK TO SAVEPOINT ...');
exec dbms_hs.replace_base_caps(6008, 2008, 'SAVEPOINT ...');
exec dbms_hs.replace_base_caps(6009, 2009, 'SET TRANSACTION READ ONLY');
exec dbms_hs.replace_base_caps(6010, 2010, 'alter session set nls_* = ...');
exec dbms_hs.replace_base_caps(6011, 2011, 'alter session set GLOBAL_NAMES, OPTIMIZER_GOAL = ..');
exec dbms_hs.replace_base_caps(6012, 2012, 'alter session set REMOTE_DEPENDENCIES_MODE = ..');
exec dbms_hs.replace_base_caps(6013, 2013, 'set transaction isolation level serializable');
exec dbms_hs.replace_base_caps(6014, 2014, 'set constraints all immediate');
exec dbms_hs.replace_base_caps(6015, 2015, 'alter session set SKIP_UNUSABLE_INDEXES = ..');
exec dbms_hs.replace_base_caps(6016, 2016, 'alter session set time_zone - its absolete now');
exec dbms_hs.replace_base_caps(6017, 2017, 'alter session set ERROR_ON_OVERLAP_TIME');
exec dbms_hs.replace_base_caps(6018, 2018, 'Upsert');
exec dbms_hs.replace_base_caps(7000, 3000, 'VARCHAR2');
exec dbms_hs.replace_base_caps(7001, 3001, 'INTEGER');
exec dbms_hs.replace_base_caps(7002, 3002, 'DECIMAL');
exec dbms_hs.replace_base_caps(7003, 3003, 'FLOAT');
exec dbms_hs.replace_base_caps(7004, 3004, 'DATE');
exec dbms_hs.replace_base_caps(7005, 3005, 'VARCHAR');
exec dbms_hs.replace_base_caps(7006, 3006, 'SMALL INTEGER');
exec dbms_hs.replace_base_caps(7007, 3007, 'RAW');
exec dbms_hs.replace_base_caps(7008, 3008, 'VAR RAW');
exec dbms_hs.replace_base_caps(7009, 3009, '? RAW');
exec dbms_hs.replace_base_caps(7010, 3010, 'SMALL FLOAT');
exec dbms_hs.replace_base_caps(7011, 3011, 'LONG INT QUADWORD');
exec dbms_hs.replace_base_caps(7012, 3012, 'LEFT OVERPUNCH');
exec dbms_hs.replace_base_caps(7013, 3013, 'RIGHT OVERPUNCH');
exec dbms_hs.replace_base_caps(7014, 3014, 'ROWID');
exec dbms_hs.replace_base_caps(7015, 3015, 'LEFT SEPARATE');
exec dbms_hs.replace_base_caps(7016, 3016, 'RIGHT SEPARATE');
exec dbms_hs.replace_base_caps(7017, 3017, 'OS DATE');
exec dbms_hs.replace_base_caps(7018, 3018, 'OS FULL ==> DATE + TIME');
exec dbms_hs.replace_base_caps(7019, 3019, 'OS TIME');
exec dbms_hs.replace_base_caps(7020, 3020, 'UNSIGNED SMALL INTEGER');
exec dbms_hs.replace_base_caps(7021, 3021, 'BYTE');
exec dbms_hs.replace_base_caps(7022, 3022, 'UNSIGNED BYTE');
exec dbms_hs.replace_base_caps(7023, 3023, 'UNSIGNED INTEGER');
exec dbms_hs.replace_base_caps(7024, 3024, 'CHAR INTEGER');
exec dbms_hs.replace_base_caps(7025, 3025, 'CHAR FLOAT');
exec dbms_hs.replace_base_caps(7026, 3026, 'CHAR DECIMAL');
exec dbms_hs.replace_base_caps(7027, 3027, 'LONG');
exec dbms_hs.replace_base_caps(7028, 3028, 'VARLONG');
exec dbms_hs.replace_base_caps(7029, 3029, 'OS RDATE');
exec dbms_hs.replace_base_caps(7030, 3030, '(RELATIVE) RECORD ADDRESS');
exec dbms_hs.replace_base_caps(7031, 3031, '(RELATIVE) RECORD NUMBER');
exec dbms_hs.replace_base_caps(7032, 3032, 'VARGRAPHIC');
exec dbms_hs.replace_base_caps(7033, 3033, 'VARNUM');
exec dbms_hs.replace_base_caps(7034, 3034, 'NUMBER');
exec dbms_hs.replace_base_caps(7035, 3035, 'ANSI FIXED CHAR');
exec dbms_hs.replace_base_caps(7036, 3036, 'LONG RAW');
exec dbms_hs.replace_base_caps(7037, 3037, 'LONG VARRAW');
exec dbms_hs.replace_base_caps(7038, 3038, 'MLSLABEL');
exec dbms_hs.replace_base_caps(7039, 3039, 'RAW MLSLABEL');
exec dbms_hs.replace_base_caps(7040, 3040, 'CHARZ');
exec dbms_hs.replace_base_caps(7041, 3041, 'BINARY INTEGER');
exec dbms_hs.replace_base_caps(7042, 3042, 'ORACLE DATE');
exec dbms_hs.replace_base_caps(7043, 3043, 'BOOLEAN');
exec dbms_hs.replace_base_caps(7044, 3044, 'CHAR ROWID');
exec dbms_hs.replace_base_caps(7045, 3045, 'UNSIGNED LONG INTEGER');
exec dbms_hs.replace_base_caps(7046, 3046, 'ODBC CHAR DECIMAL');
exec dbms_hs.replace_base_caps(7047, 3047, 'TIMESTAMP');
exec dbms_hs.replace_base_caps(7048, 3048, 'TIMESTAMP WITH TIME ZONE');
exec dbms_hs.replace_base_caps(7049, 3049, 'INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7050, 3050, 'INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7051, 3051, 'TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7052, 3052, 'CHAR TIMESTAMP');
exec dbms_hs.replace_base_caps(7053, 3053, 'CHAR TIMESTAMP WITH TIMEZONE');
exec dbms_hs.replace_base_caps(7054, 3054, 'CHAR INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7055, 3055, 'CHAR INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7056, 3056, 'CHAR TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7057, 3057, 'STRUCT TIMESTAMP');
exec dbms_hs.replace_base_caps(7058, 3058, 'STRUCT TIMESTAMP WITH TIMEZONE');
exec dbms_hs.replace_base_caps(7059, 3059, 'STRUCT INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7060, 3060, 'STRUCT INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7061, 3061, 'STRUCT TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7062, 3062, 'RESULT SET HANDLE');
exec dbms_hs.replace_base_caps(7063, 3063, 'CLOB');
exec dbms_hs.replace_base_caps(7064, 3064, 'BLOB');
exec dbms_hs.replace_base_caps(7065, 3065, 'BINARY FILE');
exec dbms_hs.replace_base_caps(7066, 3066, 'ODBC DATE');
exec dbms_hs.replace_base_caps(7067, 3067, 'ODBC TIMESTAMP STRUCT');
exec dbms_hs.replace_base_caps(7068, 3068, 'ODBC INVERVAL YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7069, 3069, 'ODBC INTERVAL DATE TO SECOND');
exec dbms_hs.replace_base_caps(7500, 3500, '');
exec dbms_hs.replace_base_caps(7501, 3501, '');
exec dbms_hs.replace_base_caps(7502, 3502, '');
exec dbms_hs.replace_base_caps(7503, 3503, '');
exec dbms_hs.replace_base_caps(7504, 3504, '');
exec dbms_hs.replace_base_caps(7505, 3505, '');
exec dbms_hs.replace_base_caps(7506, 3506, '');
exec dbms_hs.replace_base_caps(7507, 3507, '');
exec dbms_hs.replace_base_caps(7508, 3508, '');
exec dbms_hs.replace_base_caps(7509, 3509, '');
exec dbms_hs.replace_base_caps(7510, 3510, '');
exec dbms_hs.replace_base_caps(7511, 3511, '');
exec dbms_hs.replace_base_caps(7512, 3512, '');
exec dbms_hs.replace_base_caps(7513, 3513, '');
exec dbms_hs.replace_base_caps(7514, 3514, '');
exec dbms_hs.replace_base_caps(7515, 3515, '');
exec dbms_hs.replace_base_caps(7516, 3516, '');
exec dbms_hs.replace_base_caps(7517, 3517, '');
exec dbms_hs.replace_base_caps(7518, 3518, '');
exec dbms_hs.replace_base_caps(7519, 3519, '');
exec dbms_hs.replace_base_caps(8000, 4000, '');

Rem *************************************************************************
Rem END Bug 16025907                                                        
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 16686798
Rem   flags_stg is fetched into a ub2 prior to 12c.
Rem   12c may set flags larger than this, but they can be cleared now
Rem   that we are downgrading.
Rem *************************************************************************

update sys.deferred_stg$ set flags_stg = bitand(flags_stg, 65535);

Rem *************************************************************************
Rem END Bug 16686798
Rem *************************************************************************

Rem ====================================
Rem Begin Downgrade package type support
Rem ====================================

Rem  Downgrade PL/SQL package type support
create or replace library PCKG_DOWNGRADE_LIB trusted as static;
/

declare
  procedure pckg_downgrade is
  language C
  library PCKG_DOWNGRADE_LIB
  name "pckg_downgrade";
begin
  pckg_downgrade;
end;
/

drop library pckg_downgrade_lib;

Rem ==================================
Rem End Downgrade package type support
Rem ==================================

Rem *************************************************************************
Rem BEGIN Bug 19896841
Rem   update guard_id column in ecol$ to null, 
Rem   added as part of Proj 33161 for 12c
Rem *************************************************************************

update sys.ecol$ set guard_id = null;
commit;

Rem *************************************************************************
Rem END Bug 16686798
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN 21351073: Drop LOADER_LOB_INDEX_* views
Rem These views were introduced as part of fix for bug #12418269.
Rem *************************************************************************

drop view LOADER_LOB_INDEX_TAB;
drop view LOADER_LOB_INDEX_COL;
drop public synonym LOADER_LOB_INDEX_TAB;
drop public synonym LOADER_LOB_INDEX_COL;

Rem *************************************************************************
Rem END 21351073: Drop LOADER_LOB_INDEX_* views
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 19462491
Rem *************************************************************************
drop package dbms_preup;
Rem *************************************************************************
Rem END RTI 19462491
Rem *************************************************************************
 

Rem *************************************************************************
Rem END   e1102000.sql
Rem *************************************************************************
