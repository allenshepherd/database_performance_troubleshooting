Rem $Header: rdbms/admin/c1102000.sql /main/382 2017/10/23 10:08:24 hosu Exp $
Rem
Rem
Rem c1102000.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1102000.sql - Script to apply current release patch release
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post install" steps necessary
Rem      to upgrade the SERVER dictionary to the new patchset version.
Rem      It runs the new patchset versions of catalog.sql and catproc.sql
Rem      and calls the component patch scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/c1102000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/c1102000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hosu        10/14/17 - lrg 20648269: history tables must be partitioned
Rem                           in c1102000.sql
Rem    hosu        09/08/17 - 26657382: move partitioning wri$_optstat_hist*_
Rem                           history change to a1102000.sql
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    schakkap    08/02/16 - #(24309782) Fix issues with #(18255105)
Rem    shvmalik    05/06/16 - #21699753: rollback fix #19595663
Rem    yiru        01/19/16 - Add comment for Bug 21080787, 22393016
Rem                           old $DEPRECATED$ views
Rem    frealvar    12/13/15 - Bug 21156050 moved code that adds flags col to
Rem                           profname$ to i1102000.sql
Rem    sudurai     10/19/15 - Bug 21805805: Encrypt NUMBER data type in 
Rem                           statistics tables
Rem    papatne     06/12/15 - Bug 20868862: Delete invalid rule_set Object
Rem    risgupta    06/04/15 - Bug 21133861: move ALTER TABLE on LBACSYS tables
Rem                           for long identifier support to olsu112.sql
Rem    hosu        05/21/15 - 21073559: avoid drop partitioned table
Rem    raeburns    05/08/15 - Remove ODCI alter types
Rem    sumkumar    04/15/15 - Initialize Inactive_Account_Time parameter for
Rem                           "DEFAULT" profile with UNLIMITED in stead of 0
Rem    ratakuma    04/07/15 - Bug 20756607:account for remoteowner in non-bootstrap
Rem                           dictionary tables
Rem    dagagne     02/10/15 - remove ZDLRA on-disk stats
Rem    sumkumar    12/31/14 - Proj 46885: Inactive Account Time
Rem    pjotawar    12/31/14 - #(20216526: Updating flag correctly for
Rem                           streams$_apply_milestone
Rem    avangala    10/27/14 - #(19855835): make wri* indexes as parallel
Rem    shvmalik    09/22/14 - #19595663: allow SU for subqueries with ROWNUM
Rem    amunnoli    09/02/14 - Bug 19499532: Add comments to OOB audit policies
Rem    risgupta    06/26/14 - bug 19076927: invoke olsaudup to move audit 
Rem                           records if not moved before upgrade
Rem    nkgopal     03/27/14 - bug 18461047: ALTER USER_HISTORY$ before first
Rem                           create user command
Rem    avangala    03/18/14 - #(18255105): Force re-gather of histograms for
Rem                           char columns
Rem    mziauddi    01/07/14 - #(18036580) move out the addition of
Rem                           sum$.zmapscale and sumdetail$.flags to
Rem                           i1102000.sql
Rem    sagrawal    11/14/13 - bug 17436936
REM    jinjche     10/16/13 - Rename nab to old_blocks
Rem    jibyun      10/04/13 - Bug 17554941: Lock and expire passwords when
Rem                           creating SYSBACKUP, SYSDG, and SYSKM
REM    jinjche     08/21/13 - Add a column and rename some columns
REM    jinjche     05/20/13 - Make redo_rta_idx a unique index
REM    jinjche     04/30/13 - Rename and add columns for cross-endian support
Rem    lexuxu      03/29/13 - lrg 8929646
Rem    vraja       03/28/13 - bug16456871: backport from MAIN
Rem    youngtak    03/26/13 - LRG 8999930: drop v$fs_observer_histogram
Rem    vraja       03/19/13 - bug16456871: set drop scn to 0 in undohist$
Rem    acakmak     03/08/13 - #(16225046) materialize sysdate before using
Rem                           it in table definition DDL
Rem    hosu        03/04/13 - 16246179: fast synopsis upgrade 
Rem    amunnoli    03/04/13 - Bug #16310544: add PLUGGABLE DATABASE
Rem                           action to STMT_AUDIT_OPTION_MAP
Rem    aramappa    02/20/13 - bug 16317592: resolve to the correct schema
Rem                           before modifying AUD$ columns
Rem    amozes      02/25/13 - XbranchMerge amozes_bug-16187411 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      02/11/13 - add cdbvw_stats$
Rem    schakkap    02/01/13 - #(16225046) Enable tracing for debugging the
Rem                           problem
Rem    akruglik    01/22/13 - XbranchMerge akruglik_common_profiles from
Rem                           st_rdbms_12.1.0.1
Rem    jahuesva    01/14/13 - XbranchMerge jahuesva_bug-16025907 from
Rem    gravipat    01/07/13 - remove i_pdb_alert1
Rem    qiwang      01/05/13 - XbranchMerge qiwang_bug-16054577 from
Rem                           st_rdbms_12.1.0.1
Rem    qiwang      01/02/13 - BUG 16054577: use basicfile for logmnr blob
Rem                           metadata
Rem    gravipat    01/02/13 - 16056224: Remove i_pdb_alert1
Rem    sankejai    12/28/12 - XbranchMerge sankejai_bug-15988931 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     12/20/12 - Remove Trace Events
Rem    sankejai    12/20/12 - 16010984: upgrade change for V$OBJECT_USAGE
Rem    sylin       12/18/12 - drop dbms_sql2 package
Rem    cdilling    12/07/12 - add support for 12.1 patch upgrade
Rem    akruglik    12/03/12 - (15926959): add profname$.flags and 
Rem                           PDB_ALERT_SEQUENCE
Rem    smangala    12/02/12 - bug15870693: kpdbuid in redo header
Rem    krajaman    11/27/12 - Bug 15920632: Add exp_service$
Rem    aikumar     11/27/12 - bug-15925294:change dbms_lock_allocated table
Rem                           name
Rem    dvoss       11/26/12 - LOGMNRG tables must not defer segment creation
Rem    cdilling    11/17/12 - bug 15892490: fix XA views
Rem    sagrawal    11/14/12 - lrg 7344697
Rem    amadan      11/11/12 - Bug 15860373: add pdb to aq_svrntfn_message
Rem    dvoss       11/10/12 - bug 13600871: fix logminer index tablespaces
Rem    sslim       11/09/12 - Bug 14582062: update rolling statistics
Rem    mfallen     11/08/12 - bug 13796131: parallel rebuild of awr indices
Rem    jerrede     11/08/12 - Set trace event in the hopes of catching bug
Rem                           14852127
Rem    jkundu      10/24/12 - bug 13603798: logmnr_gt_tab_xyz needs pdb name
Rem                           column
Rem    yunkzhan    10/24/12 - LRG-7340308: zero out logmnr_pdb_info$.flag on
Rem                           upgrade
Rem    akruglik    10/23/12 - (14759626) get rid of DROP PDB privilege
Rem    sagrawal    10/16/12 - bug 14589702
Rem    jinjche     10/15/12 - Rename redo_db.spare1 to redo_db.curlog
Rem    pknaggs     10/04/12 - Bug #14712865: no insert into radm_fptm_lob$
Rem    dvoss       10/03/12 - logminer bug 13894920 - pdb_id is supposed
Rem                           to be 0 for non-consolidated
Rem    gravipat    09/25/12 - Add foreign fields to container$, cdb_file$
Rem    rbello      09/21/12 - bug-14621938, add user# to rmtab$
Rem    jkaloger    09/20/12 - Feature tracking for Data Pump full transportable
Rem    tianli      09/13/12 - fix bug 14625788: rename source_pdb_name to
Rem                           source_container_name
Rem    acakmak     09/14/12 - update indexes while converting stats history
Rem                           tables into partitioned tables
Rem    jinjche     09/09/12 - Add potential data loss support for OAM
Rem    acakmak     09/07/12 - Add constraint ep_repeat_count not null
Rem    akruglik    09/06/12 - get rid of CLONE PDB privilege; add DROP PDB
Rem                           privilege
Rem    sdavidso    09/04/12 - bug 12977174 - allow option tags for
Rem                           include/exclude
Rem    shiyadav    09/04/12 - Bug 14125108: insert all dbid in WRM$_BASELINE
Rem    mfallen     08/31/12 - bug 14390165: use real dbid for con_dbid default
Rem    krajaman    08/30/12 - Add PDB_DBA role
Rem    dgraj       08/30/12 - Bug 14355614: Mark sensitive dictionary columns
Rem    sjanardh    08/24/12 - Add FLAGS column in AQ$_QUEUE_SHARDS
Rem    nkgopal     08/28/12 - Bug 14362936: Grant AUDSYS with seeded privileges
Rem    dvoss       08/28/12 - zero out system.logmnr_uid$.flags on upgrade
Rem    sjanardh    08/24/12 - Add FLAGS column in AQ$_QUEUE_SHARDS
Rem    dvoss       08/27/12 - bug 14508550 - logminer metadata fixes
Rem                           cdb/constraints
Rem    gkulkarn    08/27/12 - bug-14527495: Fix setting of
Rem                           logmnr_session$.spare1
Rem    sjanardh    08/24/12 - Add FLAGS column in AQ$_QUEUE_SHARDS
Rem    pstengar    08/23/12 - bug 14498267: change SELECT MINING MODEL to 299
Rem                           in STMT_AUDIT_OPTION_MAP
Rem    shase       08/21/12 - add undohist$
Rem    gravipat    08/21/12 - createSCN for container$ should have wrap and
Rem                           base
Rem    yunkzhan    08/21/12 - Bug 13894794: add LogmnrDerivedFlags in
Rem    tianli      08/14/12 - fix cdb global-name/pdb-name
Rem    traney      06/28/12 - bug 14228510: increase max number of editions
Rem    yunkzhan    08/06/12 - Bug 13894794: add LogmnrDerivedFlags in
Rem                           logmnrc_gtcs and other related views and tables
Rem    mfallen     07/18/12 - bug 14226622: add IP to WRH$_CLUSTER_INTERCON_PK
Rem    pmojjada    08/03/12 - bug 14369888: added drop lib and package 
Rem                           for dbms_appctx
Rem    cchiappa    08/02/12 - Handle noexp$ changes for OLAP
Rem    cgervasi    08/06/12 - truncate wri$_rept_components
Rem    gravipat    08/03/12 - Add new columns to pdb_history, container
Rem    vgerard     08/01/12 - Bug 14284293: Add set_by column
Rem    anighosh    08/01/12 - #(14296972): Stretch Identifiers for
Rem                           DBMS_PARALLEL_EXECUTE
Rem    cslink      07/31/12 - Bug #14285251: Add NCLOB column to radm_fptm_lob$
Rem    jmadduku    07/19/12 - BUG 12628619: Revoke unlimited tablespace 
Rem                           from all roles
Rem    sanagara    07/31/12 - add spare columns to sqlerror$
Rem    abrown      07/27/12 - Bug 14378546 : Logminer must track CON$
Rem    jinjche     07/27/12 - Change column name DBNAME to DBUNAME
Rem    sroesch     07/24/12 - Add new service attribute for pq rim service
Rem    shiyadav    07/19/12 - 14320459:extend column width wri$_tracing_enabled
Rem    spramani    07/19/12 - force drop of SYSMAN.MGMT_STARTUP
Rem    ssonawan    07/12/12 - bug 13843068: modify user_history$.password
Rem                           column to varchar2(4000)
Rem    dvoss       07/11/12 - bug 14307623 - streams cloned session issue
Rem    sanbhara    07/05/12 - Bug 13785394 - adding column comp_info to
Rem                           aud_object_opt$.
Rem    byu         06/27/12 - Bug 13242046: add SELECT and ALTER privileges 
Rem                           for measure folder and build process
Rem    byu         12/27/11 - Create table olap_metadata_dependencies$ 
Rem    aramappa    06/06/12 - bug 14163435: do not uppercase schema name in
Rem                           update to rls$
Rem    vpriyans    06/05/12 - Bug 12904308: Audit CREATE DIRECTORY action by
Rem                           default
Rem    cslink      05/31/12 - Bug #14151458: Add table radm_fptm_lob$
Rem    shiyadav    05/31/12 - bug 13548980: add block_size in WRH$_TABLESPACE
Rem    panzho      05/29/12 - panzho_bug-14118698
Rem    cslink      05/29/12 - Bug #14133343: Add radm_td$ and radm_cd$ tables.
Rem    smesropi    05/24/12 - Created table olap_metadata_properties$
Rem    svivian     05/23/12 - Bug 13591992: new CON_NAME column
Rem    panzho      05/17/12 - bug 14087115
Rem    schakkap    05/17/12 - #(13898075) Increase size of
Rem                           optstat_user_prefs$.valchar
Rem    jnunezg     05/16/12 - Add store_output field for job_definition type
Rem    paestrad    05/16/12 - Upgrade actions for connect_credential
Rem    hosu        05/12/12 - 13911389: delay dropping synopsis table until
Rem                           a1102000
Rem    jerrede     05/11/12 - Added date_optionoff to registry$
Rem    svivian     05/11/12 - Bug 13887570: SQL injection with LOGMINING
Rem                           privilege
Rem    huntran     05/03/12 - Add error_seq#/error_rba/error_index# for error
Rem                           table
Rem    sroesch     04/25/12 - Add always-on pdb services
Rem    sankejai    04/17/12 - 13022221: CLI tables use GUID instead of DBID
Rem    hosu        04/16/12 - 13844984: remove synopsis# primary key constraint
Rem    vpriyans    03/21/12 - Bug 13413683: Rename predefined audit policies
Rem                           and add few more actions
Rem    bhristov    04/16/12 - add flags to container$
Rem    elu         04/10/12 - add persistent apply tables
Rem    vpriyans    03/21/12 - Bug 13413683: Rename predefined audit policies
Rem                           and add few more actions
Rem    sslim       04/13/12 - Changes to rolling$ tables
Rem    pradeshm    04/12/12 - Fix bug-13728931: Remove old Triton tables
Rem                           xs$sessions,xs$session_appns,xs$session_roles
Rem    yuli        04/09/12 - lrg 6883756
Rem    skayoor     04/06/12 - Bug 13077185: WITH GRANT OPTION for ON USER
Rem    hlakshma    04/06/12 - Remove ILM related tables
Rem    pknaggs     04/05/12 - Bug #13932111: EXEMPT DML/DDL REDACTION POLICY.
Rem    liding      03/30/12 - bug 13904132: MV refresh usage track
Rem    ilistvin    03/29/12 - bug13905133: up SWRF_VERSION to 10 for 12c
Rem    pxwong      03/26/12 - bug 13862732  
Rem    elu         03/20/12 - xin persistent table stats
Rem    skayoor     03/19/12 - Bug 13850182 - Insert record for PUBLIC
Rem    tianli      03/12/12 - Add seq#/rba/index for error tables
Rem    yuli        03/22/12 - bug 13573552: system/sysaux default to force 
Rem                           logging
Rem    sankejai    03/15/12 - 13254357: create table pdb_spfile$
Rem    amozes      03/15/12 - drop DBMS_DM_UTIL_INTERNAL
Rem    jmuller     02/16/12 - Fix bug 11720698: clean up warning_settings$ on
Rem                           lu drop
Rem    shjoshi     03/12/12 - Add new attributes, columns for RAT masking
Rem    jkundu      03/12/12 - bug 10297974: drop [g]v$_logmnr_region/callback
Rem    vbipinbh    03/05/12 - add upgrade for aq$_subscriber
Rem    jkundu      03/08/12 - bug 13615340 need always log group for seq
Rem    vbipinbh    03/05/12 - add upgrade for aq$_subscriber
Rem    hayu        02/29/12 - change parse_report_ref
Rem    praghuna    02/28/12 - bug13110976: PTO upgrade
Rem    traney      02/22/12 - bug 13651945: add exception handlers for long
Rem                           idents tables
Rem    sanbhara    02/16/12 - Bug 13643954 - adding more types to
Rem                           aud_object_opt$.
Rem    ramekuma    02/16/12 - bug-13715717: Move addition to ecol$ to the top
Rem    acakmak     01/27/12 - Proj. #41376: Upgrade changes for optimizer
Rem                           statistics history dictionary tables
Rem    shjoshi     01/27/12 - add get_report_with_summary to
Rem                           wri$_rept_abstract_t
Rem    ssonawan    01/13/12 - Bug 11883154: Remove handler from aud_policy$
Rem    savallu     10/04/11 - update definition of opt_calibration_stats$
Rem    elu         09/26/11 - procedure LCR
Rem    arbalakr    01/27/12 - add event 14524 for ASH upgrade
Rem    lzheng      01/18/12 - alter WRH$_SESS_TIME_STATS, WRH$_STREAMS_CAPTURE
Rem                           and WRH$_STREAMS_APPLY_SUM to accommodate
Rem                           GoldenGate/XStream info
Rem    akruglik    01/18/12 - (LRG 6689911): add cdb_local_adminauth$.passwd
Rem    tianli      12/05/11 - add notifier info for prepare/grant
Rem    dvoss       01/13/12 - update logical standby max_sga
Rem    dvoss       01/13/12 - logstdby$skip_support changes
Rem    dvoss       01/12/12 - logmnr_dictionary$ add pdb_create_scn, pdb_count
Rem    nijacob     01/06/12 - Bug#13485488: Add REDEFINE ANY TABLE privilege
Rem    amullick    01/05/12 - Bug13549280: add CLI dictionary tables
Rem    jheng       01/03/12 - Change PROF_ADMIN to CAPTURE_ADMIN
Rem    kyagoub     12/28/11 - bug#13527334: grant new privs to dba
Rem    tianli      12/14/11 - add source_database to streams$_process_params
Rem    huntran     12/05/11 - add error position to apply$_error
Rem    vradhakr    12/28/11 - Valid time temporal: SYS_FBA_PERIOD.
Rem    dahlim      12/22/11 - Bug 13520720: radm_fptm NLS issue
Rem    apatthak    12/20/11 - Bug fix 9538366, adding unaligned cu count in
Rem                           compression_stat
REM    krajaman    12/12/11 - add rdba to container$
Rem    jerrede     12/19/11 - Flush out shared pool.
Rem    weihwang    12/14/11 - RAS view cleanup
Rem    akruglik    12/12/11 - update description of cdb_auth$, get rid of
Rem                           grantee#
Rem    jerrede     12/09/11 - Trap Revoke Errors
Rem    skayoor     12/06/11 - Bug 13077185: WITH GRANT OPTION for ON USER
Rem    snadhika    11/28/11 - Drop obsolete dbms_xs* types
Rem    sramakri    11/28/11 - remove redunant insert into syncref$_parameters
Rem    sramakri    11/22/11 - changes to syncref tables
Rem    ddadashe    11/21/11 - Removing JDM types and procedures
Rem    paestrad    11/15/11 - Dropping scheduler_util package
Rem    cchiappa    11/14/11 - Bug 12957533: Create awlogseq$
Rem    hlakshma    11/07/11 - Modify ilm related tables (30966)
Rem    spsundar    11/04/11 - Bug 12836764: add new column to indpart_param$
Rem    dgraj       11/04/11 - Bug 13243011: Drop library and package for
Rem                           DBMS_DBLINK
Rem    ilistvin    11/03/11 - AWR support for remote snapshots
Rem    jomcdon     11/01/11 - lrg 5758311: fix resource manager upgrade
Rem    akruglik    10/24/11 - DB Consolidation: cdb_auth$
Rem    byu         10/17/11 - add and update columns for olap tables
Rem    jibyun      10/18/11 - Bug 13109138: move ALTER TABLE on DVSYS for long
Rem                           identifier support to dvu112
Rem    byu         10/17/11 - add and update columns for olap tables
Rem    hosu        10/13/11 - upgrade synopsis$ table
Rem    geadon      10/13/11 - remove check constraint from
Rem                           index_orphaned_entry$
Rem    bmccarth    10/03/11 - Attempt ordering of modified, and removed many dups.
Rem                         - Remove invalid alters for dv_auth$
Rem    jooskim     10/03/11 - bug 13072644: critical parallel statements
Rem    nkgopal     09/07/11 - Bug 12794116: Move creation of policies from
Rem                           cataudit.sql to c1102000.sql
Rem    prakumar    09/30/11 - Lrg 5631019: Handle Zonemap case during upgrade
Rem    acakmak     09/24/11 - Project 31794: Modify histogram dictionary tables
Rem    bmccarth    09/23/11 - fix drop cluster command, insert into
Rem                           command for mlog$ needed column list for 
Rem                           ordering.
Rem    jinjche     09/21/11 - Address review comments
Rem    gagarg      09/19/11 - AQ pdb changes
Rem    ssonawan    09/12/11 - bug 12844480:remove flags column from audit$
Rem    brwolf      08/31/11 - 32733: evaluation edition
Rem    savallu     09/15/11 - p#(autodop_31271) calibration stats table
Rem    rpang       09/14/11 - 12843424: add translate sql privilege
Rem    rrudd       09/14/11 - 12g Dictionary Upgrade for project 32728 (High
Rem                           Priority Online Redefinition Enhancements).
Rem    jerrede     09/12/11 - Fix Bug l2959399 Project #23496
Rem    ssonawan    09/12/11 - bug 12844480:remove flags column from audit$
Rem    bhristov    09/12/11 - update to pdbdba$
Rem    ssonawan    09/12/11 - bug 12844480:remove flags column from audit$
Rem    gagarg      09/12/11 - remove extra header
Rem    vradhakr    09/12/11 - Project 32919: DBHardening.
Rem    thoang      09/10/11 - Add source_root_name to streams$_rules
Rem    sslim       09/09/11 - Project 27852: create all DBMS_ROLLING objects
Rem    hlakshma    09/09/11 - proj: 30966 Add ILM result stat table
Rem    xbarr       09/04/11 - drop desupported odm objects 
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    prakumar    08/30/11 - Fix bug 12798177
Rem    cxie        08/30/11 - change pdb_history$.time to date
Rem    skayoor     08/22/11 - Bug 12846043: Audit for INHERIT PRIVILEGES.
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER
Rem    akruglik    08/18/11 - change pdb_history$.operation to varchar2(16)
Rem    jinjche     08/15/11 - Add a statement creating the dummy record
Rem    jinjche     08/15/11 - Add purge_done column
Rem    jinjche     08/11/11 - Add ts1 and ts2 columns to redo_log
Rem    jinjche     08/09/11 - Add two more columns to the redo_db table
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    hlakshma    08/29/11 - Change ILM (30966) related tables and views
Rem    hayu        07/14/11 - upgrade ash with dbop
Rem    ccaominh    08/26/11 - Proj 32743: Extend container$ for PDB open/close 
Rem    kmorfoni    08/23/11 - Fix for lrg 5759823
Rem    jomcdon     08/23/11 - project 27116: add parallel_server_limit
Rem    skayoor     08/22/11 - Bug 12846043: Audit for INHERIT PRIVILEGES.
Rem    mjaiswal    08/22/11 - AQ$_QUEUE_SHARDS upgrade changes
Rem    nkgopal     08/21/11 - Bug 12794380: AUDITOR to AUDIT_VIEWER
Rem    akruglik    08/18/11 - change pdb_history$.operation to varchar2(16)
Rem    svivian     08/16/11 - project 33052: new logmining privilege
Rem    praghuna    08/15/11 - 12879207: added flags to logstdby$apply_milestone
Rem    jinjche     08/15/11 - Add a statement creating the dummy record
Rem    jinjche     08/15/11 - Add purge_done column
Rem    skyathap    08/12/11 - add gsm_flags to service$
Rem    jinjche     08/11/11 - Add ts1 and ts2 columns to redo_log
Rem    maba        08/11/11 - upgrade changes for system.aq$_queues and views
Rem    thoang      08/10/11 - set src_root_name to src_dbname
Rem    jinjche     08/09/11 - Add two more columns to the redo_db table
Rem    aikumar     08/05/11 - bug 12710912 : Drop old dbms_lock table and
Rem                           sequence
Rem    bhristov    08/05/11 - DB Consolidation: add pdbdba$
Rem    evoss       08/05/11 - add use job resource privileges
Rem    jinjche     08/02/11 - Add GAP_RET column
Rem    rdongmin    08/01/11 - proj 28394: add sqlobj$plan to smb
Rem    ilistvin    08/01/11 - move 14524 event to AWR section
Rem    acakmak     07/29/11 - Project 31794: Add wri$_optstat_opr_tasks and
Rem                           modify wri$_optstat_opr
Rem    rpang       07/27/11 - Project 32719 - REVOKE INHERIT PRIVILEGES
Rem    hlakshma    07/27/11 - Add spare fields to ILM tables
Rem    sroesch     07/26/11 - Bug 12713359: rename service column from
Rem                           sql_translation_name to sql_translation_profile
Rem    sramakri    07/26/11 - changes to syncref$ tables
Rem    jinjche     07/18/11 - Rename cur_branch column to has_child
Rem    jinjche     07/18/11 - Add more columns
Rem    jinjche     07/15/11 - Add and rename columns
Rem    akruglik    07/15/11 - DB Consolidation: new table - condata$
Rem    hayu        07/14/11 - upgrade ash with dbop
Rem    elu         07/14/11 - row lcr changes
Rem    ilistvin    07/13/11 - disable partition checking
Rem    rgmani      07/13/11 - Scheduler db consolidation upgrade
Rem    minwei      07/08/11 - sys.redef_track$ table for online redefinition
Rem    sursridh    07/06/11 - proj 32995: Add index_orphaned_entry$.
Rem    ssonawan    07/04/11 - proj 16531: add role auditng support
Rem    aramappa    06/30/11 - Project 31942: Set rls$ bit for OLS
Rem    pstengar    06/30/11 - project 32330: add attrspec to modelatt$
Rem    bhammers    06/28/11 - bug 12674093, recompile XDB.DBMS_CSX_INT 
Rem    shbose      06/27/11 - upgrade changes for support of fast operators for
Rem                           rule set
Rem    liaguo      06/27/11 - Proj 32788 DB ILM: add ILM stats tables
Rem    skayoor     06/27/11 - Project 32719 - Add INHERIT PRIVILEGES
Rem    ramekuma    06/20/11 - Proj 33161: add guard_id column to ecol$
Rem    dahlim      06/20/11 - Project 32006: RADM add EXEMPT REDACTION POLICY
Rem    jnunezg     06/17/11 - Upgrade actions for scheduler jobs RESTARTABLE
Rem                           flag.
Rem    ilistvin    06/16/11 - add con_dbid column to AWR tables
Rem    sramakri    06/16/11 - project 31326: syncref$ objects for mv sync-refresh
Rem    jaeblee     06/13/11 - Add cdb_service$ creation
Rem    dvoss       06/11/11 - LOGMNRC_DBNAME_UID_MAP CDB changes
Rem    abrown      06/09/11 - logmnr_pdb_info$ needs did, not session# as key
Rem    jinjche     06/07/11 - Rename ERROR column to ERROR1
Rem    paestrad    06/03/11 - Dictionary changes for dbms credential
Rem    jomcdon     06/02/11 - Add base tables for Resource Manager CDB plans
Rem    weihwang    06/01/11 - proj#23920, add codeauth$
Rem    jinjche     06/01/11 - Add the error column to the redo_log table
Rem    hlakshma    05/27/11 - ILM (project 30966) related tables
Rem    elu         05/25/11 - remove xml schema
Rem    rbello      05/20/11 - rmtab$ upgrade
Rem    jinjche     05/20/11 - Add three columns to the db table
Rem    shbose      05/19/11 - upgrade for new column in rule_set_ve$
Rem    tianli      05/19/11 - change src_root_name to root_name
Rem    mziauddi    05/09/11 - project 35612: add zmapscale to sum$
Rem    jnarasin    05/09/11 - Add clustering table for project 35612
Rem    jibyun      05/15/11 - Project 5687: Add PURGE DBA_RECYCLEBIN privilege
Rem    tfyu        05/13/11 - bug-11874338
Rem    mziauddi    05/09/11 - project 35612: add zmapscale to sum$
Rem    jnarasin    05/09/11 - Add clustering table for project 35612
Rem    yxie        05/06/11 - add em express schema
Rem    schakkap    05/05/11 - project SPD (31794): add dictionary tables
Rem    bhristov    05/05/11 - DB Consolidaton: add pdb privileges
Rem    sankejai    05/05/11 - Add more creation of Flashback Archive tables
Rem    sroesch     05/04/11 - Add max_lag_time column to service$ table
Rem    traney      05/04/11 - 35209: longer identifiers dictionary upgrade
Rem    kmorfoni    05/03/11 - add schedule_name to wrr$_replays and cap_file_id
Rem                           to wrr$_replay_divergence & wrr$_replay_sql_binds
Rem    hohung      05/01/11 - Add KEEP DATE TIME, KEEP SYSGUID system privilege
Rem    vbipinbh    04/29/11 - upgrade change for rule_set_fob$
Rem    nalamand    04/27/11 - Bug-8356107: Add product column to default_pwd$. 
Rem                           Also populate default_pwd$ only in catdef.sql
Rem    shiyadav    04/27/11 - bug-12317689: AWR report accessibility changes
Rem    kyagoub     04/26/11 - fix drop sqlset_row type
Rem    liding      04/25/11 - out-place refresh
Rem    rramkiss    04/22/11 - bug #12319196, remove password
Rem    dvoss       04/19/11 - Project 33052 - Logminer consolidation support
Rem    sankejai    04/18/11 - Add creation of Flashback Archive tables
Rem    kyagoub     04/18/11 - make accecpt_sql_profile CDB aware
Rem    nalamand    04/12/11 - Proj-32480: Modify audit dictionary tables to
Rem                           accommodate Common Audit Configuration
Rem    yurxu       04/11/11 - Add connect_user for xstream$_sever
Rem    krajaman    04/09/11 - Extend container$
Rem    arbalakr    04/06/11 - Project 35499: Add PDB Attributes to ASH
Rem    sdavidso    04/04/11 - Merge full transportable from 11.2.0.3
Rem    amylavar    04/04/11 - add ilm$ dictionary tables
Rem    rpang       04/01/11 - Auditing support for SQL translation profiles
Rem    abrown      04/01/11 - lrg 5388234: put logmnrggc tables in system, not
Rem                           sysaux
Rem    kyagoub     03/30/11 - project-35499: advisor framework changes for 12g
Rem    jinjche     03/25/11 - Add a column to a table
Rem    dahlim      03/25/11 - proj 32006 (RADM): add radm_fptm$
Rem    yurxu       03/25/11 - Bug-11922716: 2-level privilege model
Rem    xiaobma     03/24/11 - add column flags to sumdetail$
Rem    tianli      03/22/11 - support PDB for xstream
Rem    jinjche     03/24/11 - Rename a table
Rem    aamirish    03/21/11 - Project 35490: Create rls_csa$ table to store
Rem                           attribute associations of VPD policies.
Rem    jinjche     03/20/11 - Add some columns on sequence number
Rem    ilistvin    03/22/11 - AWR changes for 12g
Rem    jinjche     03/18/11 - Add some columns to the Data Guard tables
Rem    abrown      03/17/11 - abrown_bug-11737200: add logmnrcgg_* tables
Rem    amylavar    03/16/11 - add compression_stat$ for statistics
Rem    shjoshi     03/16/11 - Add new columns to STS for CDB
Rem    swerthei    03/15/11 - force new version on PT.RS branch
Rem    jibyun      03/14/11 - Project 5687: Create new administrative
Rem                           privileges/users; SYSBACKUP, SYSDG, and SYSKM
Rem    jheng       03/10/11 - proj 32973
Rem    jinjche     03/10/11 - Add tables for Data Guard
Rem    amunnoli    03/05/11 - proj 26873:Creation of new user 'AUDSYS' and
Rem                           new roles 'AUDIT_ADMIN' and 'AUDITOR' 
Rem    elu         02/28/11 - set internal flag
Rem    gravipat    02/28/11 - Define a multikey index on cdb_file
Rem    rpang       02/22/11 - Add SQL translation
Rem    sankejai    02/19/11 - move v$/gv$ views in catalog scripts to kqfv
Rem    elu         02/19/11 - lcr changes
Rem    gclaborn    02/18/11 - add new flags to impcalloutreg$
Rem    msakayed    02/18/11 - Bug #11787333: upsert STMT_AUDIT_OPTION_MAP 
Rem    elu         02/16/11 - modify eager_size
Rem    rmir        02/16/11 - Proj 32008, add ADMINISTER KEY MANAGEMENT audit
Rem                           option and system privilege
Rem    yiru        02/07/11 - Triton security upgrade
Rem    huntran     01/13/11 - conflict, error, and collision handlers
Rem    elu         01/12/11 - error queue
Rem    ssonawan    01/14/11 - proj 16531: new dictinary tables for Audit policy
Rem    pknaggs     01/31/11 - RADM: move creation of radm_mc$ to i1102000.sql
Rem    jkaloger    01/19/11 - PROJ:27450 - Update Utilities tracking for 12g.
Rem    avangala    01/10/11 - Bug 9873405: upgrade MVs
Rem    xbarr       01/06/11 - Bug10640550: move odm metadata to system
Rem    sroesch     01/03/11 - Add new service parameters
Rem    cdilling    12/30/10 - add signature and edition to registry$
Rem    krajaman    12/26/10 - cdb_file$ redefined.
Rem    nalamand    12/26/10 - Bug-10396290: Add missing default password from
Rem                           phase forward acquisition
Rem    ilistvin    12/23/10 - bug10427840: bump swrf version
Rem    schakkap    12/23/10 - #(10410249) create col_group_usage$ as a non iot
Rem                           table
Rem    gclaborn    12/14/10 - add tgt_type to impcalloutreg$
Rem    pknaggs     12/14/10 - RADM: upgrade 11.2 to 12g
Rem    gravipat    12/06/10 - Add pdb column to service$
Rem    gravipat    11/17/10 - Add cdb_file$ creation
Rem    jaeblee     11/05/10 - pdb$ -> container$
Rem    yiru        11/01/10 - Fix lrg 4815614: create ACLMV tables
Rem    svivian     10/19/10 - project 30582: EDS logical standby
Rem    mjungerm    10/18/10 - add OJVMSYS schema
Rem    amozes      10/07/10 - #(10122250) fix OIDs in DM types
Rem    gclaborn    09/15/10 - add impcalloutreg$
Rem    sankejai    08/22/10 - Consolidated Databases: add pdb$ creation
Rem    gagarg      04/13/10 - Proj 31157: Add column sub_oid in
Rem                           system.aq$_queues
Rem    hosu        08/09/10 - lrg 4797011: remove nologging for wri$_optstat_
Rem                           synopsis$
Rem    nalamand    07/27/10 - Bug-8720888: Add missing default passwords
Rem    qiwang      06/04/10 - add logmnr integrated spill table
Rem                         - (gkulkarn) Set logmnr_session$.spare1 to zero
Rem                           on upgrade
Rem    nalamand    06/03/10 - Bug-9765326, 9747794: Add missing default 
Rem                           passwords
Rem    rangrish    06/02/10 - revoke grant on urifactory on upgrade
Rem    thoang      06/01/10 - handle lowercased user name
Rem    schakkap    05/23/10 - #(9577300) add table to record column group usage
Rem    hosu        05/10/10 - upgrade wri$_optstat_synopsis$
Rem    tbhosle     05/04/10 - 8670389: increase regid seq cache size, move 
Rem                           session key into reg$
Rem    thoang      04/27/10 - change Streams parameter names
Rem    hosu        04/09/10 - reduce subpartition number in wri$_optstat_synopsis$
Rem    hosu        03/30/10 - 4545922: disable partitioning check
Rem    bdagevil    03/14/10 - add px_flags column to
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    yurxu       03/05/10 - Bug-9469148: modify goldengate$_privileges
Rem    dongfwan    03/01/10 - Bug 9266913: add snap_timezone to wrm$_snapshot
Rem    hosu        02/15/10 - 9038395: wri$_optstat_synopsis$ schema change
Rem    jomcdon     02/10/10 - bug 9368895: add parallel_queue_timeout
Rem    jomcdon     02/10/10 - Bug 9207475: allow end_time to be null
Rem    sburanaw    02/04/10 - Add DB Replay callid to ASH
Rem    juyuan      02/03/10 - add lcr$_row_record.get_object_id
Rem    akociube    02/02/10 - Fix OLAP revoke order
Rem    juyuan      01/21/10 - remove all_streams_stmt_handlers and
Rem                           all_streams_stmts
Rem    apsrivas    01/12/10 - Bug 9148218, add def pwds for APR_USER and
Rem                           ARGUSUSER
Rem    sburanaw    01/08/10 - add filter_set to wrr$_replays
Rem                           add default_action to wrr$_replay_filter_set
Rem    jomcdon     12/31/09 - bug 9212250: add PQQ fields to AWR tables
Rem    juyuan      12/27/09 - create goldengate$_privileges
Rem    akociube    12/21/09 - Bug 9226807 revoke permissions
Rem    slynn       12/03/09 - Add column to seq$.
Rem    jomcdon     12/03/09 - project 24605: clear max_active_sess_target_p1
Rem    amadan      11/19/09 - Bug 9115881 Add new columns to PERSISTENT_QUEUES
Rem    akruglik    11/18/09 - 31113 (SCHEMA SYNONYMS): adding support for 
Rem                           auditing CREATE/DROP SCHEMA SYNONYM
Rem    arbalakr    11/12/09 - increase length of module and action columns
Rem    xingjin     11/14/09 - Bug 9086576: modify construct in lcr$_row_record
Rem    akruglik    11/10/09 - add/remove new audit_actions rows
Rem    gravipat    10/27/09 - Add sqlerror$ creation
Rem    hayu        10/01/09 - change the advisor/spa
Rem    msakayed    10/28/09 - Bug #5842629: direct path load auditing
Rem    praghun     11/03/09 - Added some spare columns to milestone table
Rem    thoang      10/13/09 - support uncommitted data mode
Rem    tianli      10/11/09 - add xstream$_parameters table
Rem    elu         10/06/09 - stmt lcr
Rem    praghuna    10/19/09 - Added start_scn_time, first_scn_time
Rem    msakayed    10/22/09 - Bug #8862486: AUDIT_ACTION for directory execute
Rem    lgalanis    10/20/09 - STS capture for DB Replay
Rem    achoi       09/21/09 - edition as a service attribute
Rem    shbose      09/18/09 - Bug 8764375: add destq column to aq$_schedules
Rem    cdilling    07/31/09 - Patch upgrade script for 11.2.0
Rem    cdilling    07/31/09 - Created
Rem    mmcracke    05/11/09 - proj 32331.1 support native double in DMF

Rem

Rem *************************************************************************
Rem BEGIN c1102000.sql
Rem *************************************************************************

Rem *************************************************************************
Rem Upgrade for Proj 33161: Add of a nullable column with default value - BEGIN
Rem *************************************************************************

alter table sys.ecol$ add (guard_id number);

Rem *************************************************************************
Rem Upgrade for Proj 33161: Add of a nullable column with default value - END
Rem *************************************************************************

Rem *************************************************************************
Rem User Privileges related changes for 12g - BEGIN
Rem *************************************************************************

create table userauth$                           /* user authorization table */
( user#         number not null,                              /* user number */
  grantor#      number not null,                      /* grantor user number */
  grantee#      number not null,                      /* grantee user number */
  privilege#    number not null,                   /* table privilege number */
  sequence#     number not null,                    /* unique grant sequence */
  parent        rowid,                                             /* parent */
  option$       number)                                 /* null = no options */
/
create unique index i_userauth1 on 
  userauth$(user#, grantor#, grantee#, privilege#)
/

create sequence user_grant                     /* user grant sequence number */
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 20
  order
  nocycle
/

BEGIN
  insert into userauth$ values (1,1,1,0,0,NULL,0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

create table user_privilege_map (
        privilege       number not null,
        name            varchar2(40) not null)
/
create unique index i_user_privilege_map on
  user_privilege_map(privilege)
/
comment on table USER_PRIVILEGE_MAP is
'Description table for user privilege (auditing option) type codes.  Maps privilege (auditing option) type numbers to type names'
/
comment on column USER_PRIVILEGE_MAP.PRIVILEGE is
'Numeric privilege (auditing option) type code'
/
comment on column USER_PRIVILEGE_MAP.NAME is
'Name of the type of privilege (auditing option)'
/
create public synonym user_privilege_map for user_privilege_map
/
grant select on user_privilege_map to public with grant option
/
BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-352, 'INHERIT ANY PRIVILEGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-355, 'TRANSLATE ANY SQL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into USER_PRIVILEGE_MAP values (0, 'INHERIT PRIVILEGES');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into USER_PRIVILEGE_MAP values (1, 'TRANSLATE SQL');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (352, 'INHERIT ANY PRIVILEGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (353, 'INHERIT PRIVILEGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (354, 'GRANT USER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (355, 'TRANSLATE ANY SQL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (356, 'TRANSLATE SQL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem User Privileges related changes for 12g - END
Rem *************************************************************************

Rem *************************************************************************
Rem System Privileges related changes for 12g - BEGIN
Rem *************************************************************************

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-56, 'REDEFINE ANY TABLE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

grant REDEFINE ANY TABLE to DBA with ADMIN OPTION;

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (56, 'REDEFINE ANY TABLE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem System Privileges related changes for 12g - END
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for Code-Based Access Control
Rem =======================================================================

REM
REM codeauth$ is used to store the roles attached to program units. 
REM The attached roles will be enabled during the execution.
REM

create table codeauth$
( obj# number not null,                                     /* object number */
  privilege# number not null                 /* roles attached to the object */
)
/
create unique index i_codeauth1 on codeauth$(obj#, privilege#)
/

Rem =======================================================================
Rem  End Changes for Code-Based Access Control
Rem =======================================================================


Rem =======================================================================
Rem  Begin Changes for XStream
Rem =======================================================================

Rem
Rem Add some spare columns for apply optimization purpose
Rem
alter table streams$_apply_milestone add
(spare8 number, spare9 number, spare10 timestamp, spare11 timestamp);

alter table STREAMS$_APPLY_MILESTONE
    modify (source_db_name VARCHAR2(128) null);

alter type lcr$_row_record add member function
   is_statement_lcr return varchar2 cascade;

alter type lcr$_row_record add member procedure
   set_row_text(self in out nocopy lcr$_row_record,
                row_text           IN CLOB,
                variable_list IN sys.lcr$_row_list DEFAULT NULL,
                bind_by_position in varchar2 DEFAULT 'N') cascade;

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
     position                   in raw               DEFAULT NULL
   )  RETURN lcr$_row_record cascade;

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
     bind_by_position           in varchar2          DEFAULT 'N'
   )  RETURN lcr$_row_record cascade;

alter type lcr$_row_record add static function construct(
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

alter type lcr$_row_record add member function 
   get_base_object_id return number cascade;

alter type lcr$_row_record add member function
   get_object_id return number cascade;

alter type lcr$_row_record add member function
   get_root_name return varchar2 cascade;

alter type lcr$_row_record add member procedure set_root_name(
        self in out nocopy lcr$_row_record, 
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
     edition_name               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

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
     current_user               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

alter type lcr$_ddl_record add STATIC FUNCTION construct(
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

alter type lcr$_ddl_record add MEMBER FUNCTION get_current_user
   RETURN varchar2 cascade;

alter type lcr$_ddl_record add MEMBER PROCEDURE set_current_user
    (self in out nocopy lcr$_ddl_record, current_user IN VARCHAR2) cascade;

alter type lcr$_ddl_record add member function
   get_root_name return varchar2 cascade;

alter type lcr$_ddl_record add member procedure set_root_name(
        self in out nocopy lcr$_ddl_record, 
        root_name       IN VARCHAR2) cascade;

Rem Changes to Procedure LCR
alter type lcr$_procedure_record add 
  MEMBER FUNCTION get_compatible RETURN NUMBER cascade;

alter type lcr$_procedure_record add 
   MEMBER FUNCTION get_source_time RETURN DATE cascade;

alter type lcr$_procedure_record add 
   MEMBER FUNCTION get_thread_number RETURN NUMBER cascade;

alter type lcr$_procedure_record add 
   MEMBER FUNCTION get_position RETURN RAW cascade;

alter type lcr$_procedure_record add 
  MEMBER FUNCTION get_tag RETURN RAW cascade;

alter type lcr$_procedure_record add 
  MEMBER FUNCTION is_null_tag  RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record add 
MEMBER FUNCTION  get_root_name RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record add 
MEMBER FUNCTION  get_logon_user RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record add 
  MEMBER FUNCTION  get_current_user RETURN VARCHAR2 cascade;

alter type lcr$_procedure_record add 
  MEMBER FUNCTION  get_default_user RETURN VARCHAR2 cascade;

alter table sys.streams$_apply_milestone add
(
  eager_error_retry              number /* number of retries for eager error */
);

alter table sys.apply$_error add
(
  retry_count           number,         /* number of times to retry an error */
  flags                 number                                      /* flags */
);

alter table sys.apply$_error_txn add
(
  error_number         number,                      /* error number reported */
  error_message        varchar2(4000),               /* explanation of error */
  flags                number,                                      /* flags */
  spare1               number,
  spare2               number,
  spare3               varchar2(4000),
  spare4               varchar2(4000),
  spare5               raw(2000),
  spare6               timestamp
);

alter table sys.apply$_error_txn add
(
  source_object_owner  varchar2(30),         /* source database object owner */
  source_object_name   varchar2(30),          /* source database object name */
  dest_object_owner    varchar2(30),           /* dest database object owner */
  dest_object_name     varchar2(30),            /* dest database object name */
  primary_key          varchar2(4000),            /* primary key information */
  position             raw(64),                              /* LCR position */
  message_flags        number,                              /* knlqdqm flags */
  operation            varchar2(100)                        /* LCR operation */
);

alter table sys.streams$_apply_process add
(
  source_root_name     varchar2(128)
);

alter table sys.streams$_apply_milestone add
(
  source_root_name     varchar2(128)
);

alter table sys.apply$_source_obj add
(
  source_root_name     varchar2(128)
);

alter table sys.apply$_source_schema add
(
  source_root_name     varchar2(128)
);

alter table sys.streams$_capture_process add
(
  source_root_name     varchar2(128)
);

alter table sys.streams$_rules add
(
  source_root_name     varchar2(128)
);

alter table sys.streams$_process_params add
(
  source_database      varchar2(128)
);

drop index i_streams_apply_milestone1;
create unique index i_streams_apply_milestone1 on streams$_apply_milestone
  (apply#, source_db_name, source_root_name);

drop index i_apply_source_obj2;
create unique index i_apply_source_obj2 on apply$_source_obj 
  (owner, name, type, source_db_name, dblink, source_root_name);

drop index i_apply_source_schema1;
create unique index i_apply_source_schema1 on apply$_source_schema 
  (source_db_name, global_flag, name, dblink, source_root_name);


drop index i_streams_process_params1;
create unique index i_streams_process_params1 on
  streams$_process_params (process_type, process#, name, source_database)
/

--
-- Table to for ddl conflict handlers
--
create table xstream$_ddl_conflict_handler
(
  apply_name        varchar2(30) not null,                     /* apply name */
  conflict_type     varchar2(4000) not null,                /* conflict type */
  include           clob,                                /* inclusion clause */
  exclude           clob,                                /* exclusion clause */
  method            clob,                   /* method for resolving conflict */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            clob,
  spare8            clob,
  spare9            raw(100)
)
/
create index i_xstream_ddl_conflict_hdlr1 on
  xstream$_ddl_conflict_handler(apply_name)
/

--
-- Table to for ddl conflict handlers
--
create table xstream$_map
(
  apply_name        varchar2(30) not null,                     /* apply name */
  src_obj_owner     varchar2(30),                      /*source object owner */
  src_obj_name      varchar2(100) not null,            /* source object name */
  tgt_obj_owner     varchar2(30),                     /* target object owner */
  tgt_obj_name      varchar2(100) not null,            /* target object name */
  colmap            clob,                       /* column mapping definition */
  sqlexec           clob,                              /* SQLEXEC definition */
  sequence          number,                      /* order of mapping clauses */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            clob,
  spare8            clob,
  spare9            raw(100)
)
/
create index i_xstream_map1 on
  xstream$_map(apply_name)
/

Rem
Rem table for apply table stats
Rem
create table apply$_table_stats 
(
apply#                     number,                   /* apply process number */
server_id                  number,                /* apply server identifier */
save_time                  date,                /* when stats were persisted */
source_table_owner         varchar2(30),               /* source table owner */
source_table_name          varchar2(30),                /* source table name */
destination_table_owner    varchar2(30),          /* destination table owner */
destination_table_name     varchar2(30),           /* destination table name */
last_update                date,    /*last time stats for table were updated */
total_inserts              number,  /* total number of inserts for the table */
total_updates              number,  /* total number of updates for the table */
total_deletes              number,  /* total number of deletes for the table */
insert_collisions          number,    /* num insert collisions for the table */
update_collisions          number,    /* num update collisions for the table */
delete_collisions          number,   /* num delete collisionss for the table */
reperror_records           number,  /* num colls resolved by reperror record */
reperror_ignores           number,  /* num colls resolved by reperror ignore */
wait_dependencies          number,            /* number of wait dependencies */
cdr_insert_row_exists      number,  /* number of insert row exists conflicts */
cdr_update_row_exists      number,  /* number of update row exists conflicts */
cdr_update_row_missing     number, /* number of update row missing conflicts */
cdr_delete_row_exists      number,  /* number of delete row exists conflicts */
cdr_delete_row_missing     number, /* number of delete row missing conflicts */
cdr_successful_resolutions number,   /* number of successful CDR resolutions */
cdr_failed_resolutions     number,       /* number of failed CDR resolutions */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
)
/
create index apply$_table_stats_i
  on apply$_table_stats (apply#, server_id, save_time)
/


rem XStream In persistent apply coodinator table 
create table apply$_coordinator_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                      /* coordinator state */
total_applied              number,                           /* txns applied */
total_waitdeps             number,             /* WAIT_DEP messages received */
total_waitcommits          number,          /* WAIT_COMMIT messages received */
total_admin                number,                  /* admin requests issued */
total_assigned             number,                          /* txns assigned */
total_received             number,                           /* txn received */
total_ignored              number,                 /* number of txns ignored */
total_rollbacks            number,            /* number of rollback attempts */
total_errors               number,  /* number of txns which errored on apply */
unassigned_eager           number,        /* number of unassigned eager txns */
unassigned_complete        number,     /* number of unassigned complete txns */
auto_txnbufsize            number,      /* Auto adjusted value of txnbufsize */
startup_time               date,           /* SYSDATE when the apply started */
lwm_time                   date,                     /* time lwm was updated */
lwm_msg_num                number,                       /* lwm number (SCN) */
lwm_msg_time               date,             /* creation time of lwm message */
hwm_time                   date,                     /* time hwm was updated */
hwm_msg_num                number,                       /* hwm number (SCN) */
hwm_msg_time               date,             /* creation time of hwm message */
elapsed_schedule_time      number,       /* time elapsed scheduling messages */
elapsed_idle_time          number,                /* time elapsed being idle */
lwm_position               raw(64),         /* low watermark commit position */
hwm_position               raw(64),        /* high watermark commit position */
processed_msg_num          number,             /* processed msg number (SCN) */
flag                       number,                       /* coordinator flag */
flags_factoring            number,                           /* factor flags */
replname                   varchar2(30),     /* name of the replicat process */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_coordinator_stats_i
  on apply$_coordinator_stats (apply#, save_time)
/

rem XStream In persistent apply server table 
create table apply$_server_stats
(
apply#                     number,                   /* apply process number */
server_id                  number,                /* apply server identifier */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                     /* apply server state */
startup_time               date,           /* SYSDATE when the apply started */
xid_usn                    number,   /* xid usn of transaction being applied */
xid_slt                    number,   /* xid slt of transaction being applied */
xid_sqn                    number,   /* xid sqn of transaction being applied */
cscn                       number,      /* commit scn of current transaction */
depxid_usn                 number,       /* xid usn of txn server depends on */
depxid_slt                 number,       /* xid slt of txn server depends on */
depxid_sqn                 number,       /* xid sqn of txn server depends on */
depcscn                    number,    /* commit scn of txn server depends on */
msg_num                    number,          /* current message being applied */
total_assigned             number,          /* total txns assigned to server */
total_admin                number,   /* total admin tasks assigned to server */
total_rollbacks            number,       /* total number of txns rolled back */
total_msg                  number,       /* total number of messages applied */
last_apply_time            date,            /* time last message was applied */
last_apply_msg_num         number,         /* number of last message applied */
last_apply_msg_time        date,    /* creation time of last applied message */
elapsed_apply_time         number,         /* time elapsed applying messages */
commit_position            raw(64),    /* commit position of the transaction */
dep_commit_position        raw(64),   /* commit pos of txn server depends on */
last_apply_pos             raw(64),      /* position of last message applied */
flag                       number,                                  /* flags */
nosxid                     varchar2(128),   /* txn id that slave is applying */
depnosxid                  varchar2(128),        /* txn id slave depends on  */
max_inst_scn               number,              /* maximum instantiation SCN */
total_waitdeps             number,      /* total number of wait dependencies */
total_lcrs_retried         number,           /* total number of lcrs retried */
total_txns_retried         number,           /* total number of txns retried */
txn_retry_iter             number,            /* current txn retry iteration */
lcr_retry_iter             number,            /* current lcr retry iteration */
total_txns_discarded       number,    /* txns handled by reperror RECORD_TXN */
flags_factoring            number,                        /* factoring flags */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_server_stats_i
  on apply$_server_stats (apply#, server_id, save_time)
/

rem XStream In persistent apply reader table 
create table apply$_reader_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                     /* apply reader state */
startup_time               date,           /* SYSDATE when the apply started */
msg_num                    number,          /* current message being applied */
total_msg                  number,       /* total number of messages applied */
total_spill_msg            number,   /* the total number of messages spilled */
last_rcv_time              date,           /* time last message was received */
last_rcv_msg_num           number,        /* number of last message received */
last_rcv_msg_time          date,           /* creation time of last received */
sga_used                   number,                        /* SGA memory used */
elapsed_dequeue_time       number,        /* time elapsed dequeuing messages */
elapsed_schedule_time      number,       /* time elapsed scheduling messages */
elapsed_spill_time         number,         /* time elapsed spilling messages */
last_browse_num            number,                        /* last browse SCN */
oldest_scn_num             number,                             /* oldest SCN */
last_browse_seq            number,            /* last browse sequence number */
last_deq_seq               number,           /* last dequeue sequence number */
oldest_xid_usn             number,                         /* oldest xid usn */
oldest_xid_slt             number,                         /* oldest xid slt */
oldest_xid_sqn             number,                         /* oldest xid sqn */
spill_lwm_scn              number,                /* spill low watermark SCN */
commit_position            raw(64),    /* commit position of the transaction */
last_rcv_pos               raw(64),             /* position of last received */
last_browse_pos            raw(64),                  /* last browse position */
oldest_pos                 raw(64),                       /* oldest position */
spill_lwm_pos              raw(64),          /* spill low watermark position */
flag                       number,                                  /* flags */
oldest_xidtxt              varchar2(128),           /* oldest transaction id */
num_deps                   number,                 /* number of dependencies */
num_dep_lcrs               number,            /* number of lcrs with txn dep */
num_wmdeps                 number             ,/* number of lcrs with WM dep */
num_in_memory_lcrs         number,           /* number of knallcrs in memory */
sga_allocated              number,  /* total sga allocated from streams pool */
total_lcrs_retried         number,           /* total number of lcrs retried */
total_txns_retried         number,           /* total number of txns retried */
txn_retry_iter             number,            /* current txn retry iteration */
lcr_retry_iter             number,            /* current lcr retry iteration */
total_txns_discarded       number,    /* txns handled by reperror RECORD_TXN */
flags_factoring            number,                        /* factoring flags */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_reader_stats_i
  on apply$_reader_stats (apply#, save_time)
/

rem stores persistent batch sql statistics for the apply servers
create table apply$_batch_sql_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
server_id                  number,                /* apply server identifier */
batch_opeations            number,
batches                    number,
batches_executed           number,
queues                     number,
batches_in_error           number,
normal_mode_ops            number,
immediate_flush_ops        number,
pk_collisions              number,
uk_collisions              number,
fk_collisions              number,
thread_batch_groups        number,
num_commits                number,
num_rollbacks              number,
queue_flush_calls          number,
ops_per_batch              number,
ops_per_batch_executed     number,
ops_per_queue              number,
parallel_batch_rate        number,
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    number,
spare12                    number,
spare13                    number,
spare14                    number,
spare15                    number,
spare16                    varchar2(4000),
spare17                    varchar2(4000),
spare18                    varchar2(4000),
spare19                    varchar2(4000),
spare20                    raw(1000),
spare21                    raw(1000),
spare22                    raw(1000),
spare23                    date,
spare24                    date,
spare25                    date
);
create index apply$_batch_sql_stats_i
  on apply$_batch_sql_stats (apply#, server_id, save_time)
/

Rem
Rem Add time parameters for scn
Rem
ALTER TABLE streams$_capture_process ADD 
(
  start_scn_time      date , 
  first_scn_time      date 
);

Rem
Rem Table for xstream parameters 
Rem
create table xstream$_parameters
(
  server_name       varchar2(30) not null,            /* XStream server name */
  server_type       number not null,         /* 0 for outbond, 1 for inbound */
  position          number not null,    /* total ordering for the parameters */
  param_key         varchar2(100),               /* keyword in the parameter */
  schema_name       varchar2(30),                   /* optional, no wildcard */
  object_name       varchar2(30),               /* optional, can do wildcard */
  user_name         varchar2(30),                           /* creation user */
  creation_time     timestamp,                              /* creation time */
  modification_time timestamp,                          /* modification time */
  flags             number,                              /* unused right now */
  details           clob,                           /* the parameter details */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            raw(64),
  spare8            date,
  spare9            clob
)
/
create unique index i_xstream_parameters on
  xstream$_parameters(server_name, server_type, position)
/


Rem
Rem Sequence for conflict handler id
Rem
create sequence conflict_handler_id_seq$     /* conflict handler id sequence */
  start with 1
  increment by 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  nocycle
  nocache
/

Rem
Rem Table for xstream dml_conflict_handler
Rem
create table xstream$_dml_conflict_handler
(
  object_name            varchar2(30),                        /* object name */
  schema_name            varchar2(30),                        /* schema name */
  apply_name             varchar2(30),                         /* apply name */
  conflict_type          number,                 /* conflict type definition */
                                                             /* 1 row exists */
                                                            /* 2 row missing */
  user_error             number,                                   /* unused */
  opnum                  number,             /* 1 insert, 2 update, 3 delete */
  method_txt             clob,                                     /* unused */
  method_name            varchar2(4000),                           /* unused */
  old_object             varchar2(30),               /* original object name */
  old_schema             varchar2(30),               /* original schema name */
  method_num             number,           /* resolution method
                                            * 1 RECORD, 2 IGNORE, 3 OVERWRITE,
                                            * 4 MAXIMUM, 5 MINIMUM, 6 DELTA  */
  conflict_handler_name  varchar2(30),       /* Name of the conflict handler */
  resolution_column      varchar2(30),                 /* column to evaluate */
  conflict_handler_id    number,               /* ID of the conflict handler */
  spare1                 number,  
  spare2                 number, 
  spare3                 number, 
  spare4                 timestamp,  
  spare5                 varchar2(4000),
  spare6                 varchar2(4000),
  spare7                 raw(64),
  spare8                 date,
  spare9                 clob
)
/
Rem add new columns for 11.2.0.3
alter table xstream$_dml_conflict_handler
  add (
    method_num             number,         /* resolution method
                                            * 1 RECORD, 2 IGNORE, 3 OVERWRITE,
                                            * 4 MAXIMUM, 5 MINIMUM, 6 DELTA  */
    conflict_handler_name  varchar2(30),     /* Name of the conflict handler */
    resolution_column      varchar2(30),               /* column to evaluate */
    conflict_handler_id    number              /* ID of the conflict handler */
  )
/

Rem this index may exist for an old version of this table
drop index i_xstream_dml_conflict_handler
/
create index i_xstream_dml_conf_handler1 on
  xstream$_dml_conflict_handler(apply_name, schema_name, object_name,
                                old_schema, old_object, opnum, conflict_type,
                                method_num)
/
create unique index i_xstream_dml_conf_handler2 on
  xstream$_dml_conflict_handler(apply_name, conflict_handler_name)
/

Rem
Rem Table to store the conflict resolution group for
Rem xstream$_dml_conflict_handler
Rem
create table xstream$_dml_conflict_columns
(
  conflict_handler_id       number not null,                   /* handler id */
  column_name               varchar2(30) not null,                 /* column */
  spare1                    number,  
  spare2                    number, 
  spare3                    number, 
  spare4                    timestamp,  
  spare5                    varchar2(4000),
  spare6                    varchar2(4000),
  spare7                    raw(64),
  spare8                    date,
  spare9                    clob
)
/
create index i_xstream_dml_conflict_cols1 on
  xstream$_dml_conflict_columns(conflict_handler_id)
/

Rem
Rem table for reperror handlers
Rem
create table xstream$_reperror_handler
(
  apply_name          varchar2(30) not null,                   /* Apply name */
  schema_name         varchar2(30) not null,                  /* dest schema */
  table_name          varchar2(30) not null,                   /* dest table */
  source_schema_name  varchar2(30) not null,                   /* src schema */
  source_table_name   varchar2(30) not null,                    /* src table */
  error_number        number not null,                       /* error number */
  method              number not null, /* 1 ABEND, 2 RECORD,
                                        * 3 RECORD_TRANSACTION, 4 IGNORE,
                                        * 5 RETRY, 6 RETRY_TRANSACTION */
  max_retries         number,                                 /* max retries */
  delay_msecs         number,                     /* retry delay miliseconds */
  spare1              number,  
  spare2              number, 
  spare3              number, 
  spare4              timestamp,  
  spare5              varchar2(4000),
  spare6              varchar2(4000),
  spare7              raw(64),
  spare8              date,
  spare9              clob
)
/
create unique index i_xstream_reperror_handler1 on
  xstream$_reperror_handler(apply_name, schema_name, table_name,
                           source_schema_name, source_table_name, error_number)
/

Rem
Rem table for collision handlers
Rem
create table xstream$_handle_collisions
(
  apply_name          varchar2(30) not null,                   /* apply name */
  schema_name         varchar2(30) not null,                  /* dest schema */
  table_name          varchar2(30) not null,                   /* dest table */
  source_schema_name  varchar2(30) not null,                   /* src schema */
  source_table_name   varchar2(30) not null,                    /* src table */
  handle_collisions   varchar2(1) not null,        /* Handle collisions? Y/N */
  spare1              number,  
  spare2              number, 
  spare3              number, 
  spare4              timestamp,  
  spare5              varchar2(4000),
  spare6              varchar2(4000),
  spare7              raw(64),
  spare8              date,
  spare9              clob
)
/
create unique index i_xstream_handle_collisions1 on
  xstream$_handle_collisions(apply_name, schema_name, table_name,
                             source_schema_name, source_table_name)
/


alter table streams$_apply_process add
( spare4                  number,
  spare5                  number,
  spare6                  varchar2(4000),
  spare7                  varchar2(4000),
  spare8                  date,
  spare9                  date
);

alter table streams$_privileged_user add
( flags number,
  spare1 number,
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
);

alter table xstream$_server add
( status_change_time date        /* the time that the status column changed */
);

alter table xstream$_server add
(
  connect_user varchar2(30)
);

create table xstream$_server_connection
(
 outbound_server               varchar2(30) not null,
 inbound_server                varchar2(30) not null,
 inbound_server_dblink         varchar2(128),
 outbound_queue_owner          varchar2(30),
 outbound_queue_name           varchar2(30),
 inbound_queue_owner           varchar2(30),
 inbound_queue_name            varchar2(30),
 rule_set_owner                varchar2(30),
 rule_set_name                 varchar2(30),
 negative_rule_set_owner       varchar2(30),
 negative_rule_set_name        varchar2(30),
 flags                         number,
 status                        number,
 create_date                   date,
 error_message                 varchar2(4000),
 error_date                    date,
 acked_scn                     number,
 auto_merge_threshold          number,
 spare1                        number,
 spare2                        number,
 spare3                        varchar2(4000),
 spare4                        varchar2(4000),
 spare5                        varchar2(4000),
 spare6                        varchar2(4000),
 spare7                        date,
 spare8                        date,
 spare9                        raw(2000),
 spare10                       raw(2000)
)
/
create index i_xstream_server_connection1 on xstream$_server_connection
    (outbound_server, inbound_server, inbound_server_dblink)
/

create table goldengate$_privileges
( username        varchar2(30) not null,
  privilege_type  number not null,              /* 1: capture; 2: apply; 3:* */
  privilege_level number not null,           /* 0: NONE; 1: select privilege */
  create_time     timestamp,
  spare1          number,
  spare2          number,
  spare3          timestamp,
  spare4          varchar2(4000),
  spare5          varchar2(4000))
/
create unique index goldengate$_privileges_i on 
  goldengate$_privileges(username, privilege_type, privilege_level)
/

create table xstream$_privileges
( username        varchar2(300) not null,
  privilege_type  number not null,              /* 1: capture; 2: apply; 3:* */
  privilege_level number not null,              /* 1: administrator; 2: user */
  create_time     timestamp,
  spare1          number,
  spare2          number,
  spare3          timestamp,
  spare4          varchar2(4000),
  spare5          varchar2(4000))
/
create unique index i_xstream_privileges on 
  xstream$_privileges(username, privilege_type, privilege_level)
/

drop public synonym all_streams_stmt_handlers;
drop view all_streams_stmt_handlers;

drop public synonym all_streams_stmts;
drop view all_streams_stmts;

Rem Modify Streams parameter names 
update sys.streams$_process_params 
  set name = 'COMPARE_KEY_ONLY', internal_flag = 0 
   where name = '_CMPKEY_ONLY';

update sys.streams$_process_params 
  set name = 'IGNORE_TRANSACTION', internal_flag = 0 
   where name = '_IGNORE_TRANSACTION';

update sys.streams$_process_params 
  set name = 'IGNORE_UNSUPPORTED_TABLE', internal_flag = 0 
   where name = '_IGNORE_UNSUPERR_TABLE';

update sys.streams$_process_params 
  set name = 'MAX_PARALLELISM', internal_flag = 0 
  where name = '_MAX_PARALLELISM';

update sys.streams$_process_params 
  set name = 'EAGER_SIZE', internal_flag = 0 
  where name = '_EAGER_SIZE';

update sys.streams$_process_params 
  set value = '9500' 
  where name = 'EAGER_SIZE' 
  and user_changed_flag=0
  and value = '1000';
commit;

Rem set source_root_name to source_dbname 
Rem
update streams$_apply_milestone
  set source_root_name = source_db_name;

update apply$_source_obj
  set source_root_name = source_db_name;

update apply$_source_schema
  set source_root_name = source_db_name;

update streams$_capture_process
  set source_root_name = source_dbname;

update streams$_rules
  set source_root_name = source_database;

Rem Grant SELECT ANY TRANSACTION to all Streams admin users
DECLARE
  user_names       dbms_sql.varchar2s;
  i                PLS_INTEGER;
BEGIN
  -- grant select any transaction to username from dba_streams_administrator. 
  SELECT u.name
  BULK COLLECT INTO user_names FROM user$ u, sys.streams$_privileged_user pu
  WHERE u.user# = pu.user# AND pu.privs != 0 and
       (pu.flags IS NULL or pu.flags = 0 or (bitand(pu.flags, 1) = 1));
  FOR i IN 1 .. user_names.count 
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names(i) <> 'SYS' AND user_names(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'GRANT SELECT ANY TRANSACTION TO ' || 
               dbms_assert.enquote_name(user_names(i), FALSE);
    END IF;
  END LOOP;
END;
/

rem =======================================================================
Rem  12.1 Changes for XStream
Rem =======================================================================
alter table sys.apply$_error add
(
  error_pos      raw(64)                                   /* error position */
);

alter table sys.apply$_error add
(
  start_seq#            number           /* start seq# of the replicat trail */
);
alter table sys.apply$_error add
(
  end_seq#              number             /* end seq# of the replicat trail */
);
alter table sys.apply$_error add
(
  start_rba             number            /* start rba of the replicat trail */
);
alter table sys.apply$_error add
(
  end_rba               number              /* end rba of the replicat trail */
);

alter table sys.apply$_error add
(
  error_seq#            number    /* seq# of replicat trail for error record */
);

alter table sys.apply$_error add
(
  error_rba             number     /* rba of replicat trail for error record */
);

alter table sys.apply$_error add
(
  error_index#          number    /* replicat mapping index for error record */
);

alter table sys.apply$_error add
(
  spare6                number
);

alter table sys.apply$_error add
(
  spare7                number
);

alter table sys.apply$_error add
(
  spare8                varchar2(4000)
);

alter table sys.apply$_error add
(
  spare9                varchar2(4000)
);

alter table sys.apply$_error add
(
  spare10               raw(1000)
);

alter table sys.apply$_error add
(
  spare11               raw(1000)
);

alter table sys.apply$_error add
(
  spare12               timestamp
);

alter table sys.apply$_error_txn add
(
  seq#                  number                 /* seq# of the replicat trail */
);
alter table sys.apply$_error_txn add
(
  rba                   number                  /* rba of the replicat trail */
);
alter table sys.apply$_error_txn add
(
  index#                number             /* index # of the replicat record */
);
alter table sys.apply$_error_txn add
(
  spare7                number
);
alter table sys.apply$_error_txn add
(
  spare8                number
);
alter table sys.apply$_error_txn add
(
  spare9                varchar2(4000)
);
alter table sys.apply$_error_txn add
(
  spare10               varchar2(4000)
);
alter table sys.apply$_error_txn add
(
  spare11               raw(1000)
);
alter table sys.apply$_error_txn add
(
  spare12               raw(1000)
);

Rem add set_by columns to apply handlers
ALTER TABLE apply$_dest_obj_ops ADD (set_by number default NULL);
ALTER TABLE xstream$_dml_conflict_handler ADD (set_by number default NULL);
ALTER TABLE xstream$_reperror_handler ADD (set_by number default NULL);
ALTER TABLE xstream$_handle_collisions ADD (set_by number default NULL);

Rem add columns to streams$_prepare_ddl
ALTER TABLE streams$_prepare_ddl ADD (allpdbs number default 0);
ALTER TABLE streams$_prepare_ddl ADD (c_invoker varchar2(30));

Rem add columns to xstream$_privileges
ALTER TABLE xstream$_privileges ADD (optional_priv varchar2(4000));
ALTER TABLE xstream$_privileges ADD (allpdbs number default 0);
ALTER TABLE xstream$_privileges ADD (c_invoker varchar2(30));

Rem add columns to goldengate$_privileges
ALTER TABLE goldengate$_privileges ADD (optional_priv varchar2(4000));
ALTER TABLE goldengate$_privileges ADD (allpdbs number default 0);
ALTER TABLE goldengate$_privileges ADD (c_invoker varchar2(30));

alter table streams$_apply_milestone add ( flags number);

declare
 newflag number;
 CURSOR all_apply IS 
   select apply#, flags from sys.streams$_apply_process;
begin
 FOR app IN all_apply 
 LOOP
   newflag := 0;
   /* Pass on used flag KNAPROCFPTOUSED -> KNALA_PTO_USED*/
   IF (bitand(app.flags, 8192) = 8192) THEN
     newflag := 1;
     /* Pass on recovered flag KNAPROCFPTRDONE -> KNALA_PTO_RECOVERED */
     IF (bitand(app.flags, 2048) = 2048) THEN
       newflag := 3;
     END IF;
   END IF;
   IF (newflag <> 0) THEN
       update sys.streams$_apply_milestone set flags = flags + newflag 
       where apply# = app.apply#;
   END IF;
   /* Not clearing the streams$_apply_process flags for debugging purpose */
 END LOOP; 
 COMMIT;
  
end;
/

Rem add dbname mapping table for CDB
create table repl$_dbname_mapping
(
  source_root_name     varchar2(128),
  source_database_name varchar2(128),
  source_container_name varchar2(30),
  spare1               number,
  spare2               number,
  spare3               timestamp,
  spare4               varchar2(4000),
  spare5               varchar2(4000)
)
/

create unique index i_repl_dbname_mapping_1 on 
  repl$_dbname_mapping(source_root_name, source_database_name)
/

create unique index i_repl_dbname_mapping_2 on 
  repl$_dbname_mapping(source_root_name, source_container_name)
/

rem =======================================================================
Rem  End Changes for XStream
Rem =======================================================================

Rem *************************************************************************
Rem DBMS CREDENTIAL package - BEGIN
Rem *************************************************************************

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-387, 'CREATE CREDENTIAL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-388, 'CREATE ANY CREDENTIAL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values(387, 'CREATE CREDENTIAL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values(388, 'CREATE ANY CREDENTIAL', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

alter table scheduler$_credential modify username VARCHAR2(128) NULL;
alter table scheduler$_credential modify password VARCHAR2(255) NULL;

alter table scheduler$_job add (connect_credential_name varchar2(128));
alter table scheduler$_job add (connect_credential_owner varchar2(128));
alter table scheduler$_job add (connect_credential_oid number);
alter table scheduler$_lightweight_job add 
                  (connect_credential_name varchar2(128));
alter table scheduler$_lightweight_job add 
                  (connect_credential_owner varchar2(128));
alter table scheduler$_lightweight_job add 
                  (connect_credential_oid varchar2(128));
commit;


Rem *************************************************************************
Rem DBMS CREDENTIAL package - END
Rem *************************************************************************

Rem =======================================================================
Rem  Begin 11.2 Changes for LogMiner
Rem =======================================================================

Rem Set system.logmnr_session$.spare1 to zero
update system.logmnr_session$
 set spare1 = 0
 where spare1 is null;
commit;

Rem logminer needs a log group to track seq$ for GG Integrated Capture
declare
  cnt number;
begin
  select count(1) into cnt
    from con$ co, cdef$ cd, obj$ o, user$ u
    where o.name = 'SEQ$'
      and u.name = 'SYS'
      and co.name = 'SEQ$_LOG_GRP'
      and cd.obj# = o.obj#
      and cd.con# = co.con#;
  if cnt = 0 then
    execute immediate 'alter table sys.seq$
                          add supplemental log group 
                          seq$_log_grp (obj#) always';
  end if;
end;
/

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
--
-- For Logminer support of GG mining across a redo gap.
-- The tables LOGMNRGGC_GTLO and LOGMNRGGC_GTCS are are
-- identical to their counterparts LOGMNRC_GTLOG and  LOGMNRC_GTCS.
-- Though it would have been simpler to use designated paritions
-- of the original tables, this could have led to unacceptable locking
-- issues when the DDL trigger that maintains these tables fires.
--
CREATE TABLE SYSTEM.LOGMNRGGC_GTLO( 
                  LOGMNR_UID         NUMBER NOT NULL, 
                  KEYOBJ#            NUMBER NOT NULL,
                  LVLCNT             NUMBER NOT NULL,  /* level count */
                  BASEOBJ#           NUMBER NOT NULL,  /* base object number */
                  BASEOBJV#          NUMBER NOT NULL,  
                                                      /* base object version */
                  LVL1OBJ#           NUMBER,  /* level 1 object number */
                  LVL2OBJ#           NUMBER,  /* level 2 object number */
                  LVL0TYPE#          NUMBER NOT NULL,
                                              /* level 0 (base obj) type # */
                  LVL1TYPE#          NUMBER,  /* level 1 type # */
                  LVL2TYPE#          NUMBER,  /* level 2 type # */
                  OWNER#             NUMBER,  /* owner number */
                  OWNERNAME          VARCHAR2(30) NOT NULL,
                  LVL0NAME           VARCHAR2(30) NOT NULL,
                                              /* name of level 0 (base obj)  */
                  LVL1NAME           VARCHAR2(30), /* name of level 1 object */
                  LVL2NAME           VARCHAR2(30), /* name of level 2 object */
                  INTCOLS            NUMBER NOT NULL,
                              /* for table object, number of all types cols  */
                  COLS               NUMBER,
                           /* for table object, number of user visable cols  */
                  KERNELCOLS         NUMBER,
                        /* for table object, number of non zero secol# cols  */
                  TAB_FLAGS          NUMBER,   /* TAB$.FLAGS        */
                  TRIGFLAG           NUMBER,   /* TAB$.TRIGFLAG     */
                  ASSOC#             NUMBER,   /* IOT/OF Associated object */
                  OBJ_FLAGS          NUMBER,   /* OBJ$.FLAGS        */
                  TS#                NUMBER, /* table space number */
                  TSNAME             VARCHAR2(30), /* table space name   */
                  PROPERTY           NUMBER,
                  /* Replication Dictionary Specific Columns  */
                  START_SCN          NUMBER NOT NULL,
                                            /* SCN at which existence begins */
                  DROP_SCN         NUMBER,  /* SCN at which existence ends   */
                  XIDUSN             NUMBER,
                                        /* src txn which created this object */
                  XIDSLT             NUMBER,
                  XIDSQN             NUMBER,
                  FLAGS              NUMBER,
                  LOGMNR_SPARE1             NUMBER,
                  LOGMNR_SPARE2             NUMBER,
                  LOGMNR_SPARE3             VARCHAR2(1000),
                  LOGMNR_SPARE4             DATE,
                  LOGMNR_SPARE5             NUMBER,
                  LOGMNR_SPARE6             NUMBER,
                  LOGMNR_SPARE7             NUMBER,
                  LOGMNR_SPARE8             NUMBER,
                  LOGMNR_SPARE9             NUMBER,
                /* New in V11  */
                  PARTTYPE                  NUMBER,
                  SUBPARTTYPE               NUMBER,
                  UNSUPPORTEDCOLS           NUMBER,
                  COMPLEXTYPECOLS           NUMBER,
                  NTPARENTOBJNUM            NUMBER,
                  NTPARENTOBJVERSION        NUMBER,
                  NTPARENTINTCOLNUM         NUMBER,
                  LOGMNRTLOFLAGS            NUMBER,
                  LOGMNRMCV                 VARCHAR2(30),
                    CONSTRAINT LOGMNRGGC_GTLO_PK
                    PRIMARY KEY(LOGMNR_UID, KEYOBJ#, BASEOBJV#)
                  ) TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I2GTLO 
    ON SYSTEM.LOGMNRGGC_GTLO (logmnr_uid, baseobj#, baseobjv#) 
    TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I3GTLO 
    ON SYSTEM.LOGMNRGGC_GTLO (logmnr_uid, drop_scn) 
    TABLESPACE SYSTEM LOGGING
/

CREATE TABLE SYSTEM.LOGMNRGGC_GTCS(
                   LOGMNR_UID                NUMBER NOT NULL,
                   OBJ#                      NUMBER NOT NULL,
                                              /* table (base) object number  */
                   OBJV#                     NUMBER NOT NULL,
                                              /* table object version        */
                   SEGCOL#                   NUMBER NOT NULL,
                                              /* segcol# of column           */
                   INTCOL#                   NUMBER NOT NULL,
                                              /* intcol# of column           */
                   COLNAME                   VARCHAR2(30) NOT NULL, 
                                              /* name of column              */
                   TYPE#                     NUMBER NOT NULL, /* column type */
                   LENGTH                    NUMBER, /* data length */
                   PRECISION                 NUMBER, /* data precision */
                   SCALE                     NUMBER, /* data scale */
                   INTERVAL_LEADING_PRECISION  NUMBER,
                                       /* Interval Leading Precision, if any */
                   INTERVAL_TRAILING_PRECISION NUMBER,
                                      /* Interval trailing precision, if any */
                   PROPERTY                  NUMBER,
                   TOID                      RAW(16),
                   CHARSETID                 NUMBER,
                   CHARSETFORM               NUMBER,
                   TYPENAME                  VARCHAR2(30),
                   FQCOLNAME                 VARCHAR2(4000),
                                              /* fully-qualified column name */
                   NUMINTCOLS                NUMBER, /* Number of Int Cols  */
                   NUMATTRS                  NUMBER,
                   ADTORDER                  NUMBER,
                   LOGMNR_SPARE1                    NUMBER,
                   LOGMNR_SPARE2                    NUMBER,
                   LOGMNR_SPARE3                    VARCHAR2(1000),
                   LOGMNR_SPARE4                    DATE,
                   LOGMNR_SPARE5             NUMBER,
                   LOGMNR_SPARE6             NUMBER,
                   LOGMNR_SPARE7             NUMBER,
                   LOGMNR_SPARE8             NUMBER,
                   LOGMNR_SPARE9             NUMBER,
                /* New for V11.  */
                   COL#                      NUMBER,
                   XTYPESCHEMANAME           VARCHAR2(30),
                   XTYPENAME                 VARCHAR2(4000),
                   XFQCOLNAME                VARCHAR2(4000),
                   XTOPINTCOL                NUMBER,
                   XREFFEDTABLEOBJN          NUMBER,
                   XREFFEDTABLEOBJV          NUMBER,
                   XCOLTYPEFLAGS             NUMBER,
                   XOPQTYPETYPE              NUMBER,
                   XOPQTYPEFLAGS             NUMBER,
                   XOPQLOBINTCOL             NUMBER,
                   XOPQOBJINTCOL             NUMBER,
                   XXMLINTCOL                NUMBER,
                   EAOWNER#                  NUMBER,
                   EAMKEYID                  VARCHAR2(64),
                   EAENCALG                  NUMBER,
                   EAINTALG                  NUMBER,
                   EACOLKLC                  RAW(2000),
                   EAKLCLEN                  NUMBER,
                   EAFLAGS                   NUMBER,
                     constraint logmnrggc_gtcs_pk
                     primary key(logmnr_uid, obj#, objv#,intcol#)
                  )  TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I2GTCS
    ON SYSTEM.LOGMNRGGC_GTCS (logmnr_uid, obj#, objv#, segcol#, intcol#)
    TABLESPACE SYSTEM LOGGING
/



Rem =======================================================================
Rem  End 11.2 Changes for LogMiner
Rem =======================================================================


Rem 
Rem Add edition column for Service
Rem 
alter table SERVICE$ add (edition varchar2(30));

Rem =================
Rem Begin AQ changes
Rem =================

ALTER TABLE sys.aq$_schedules ADD (destq NUMBER);
-- Proj 31157 
ALTER TABLE system.aq$_queues ADD (sub_oid RAW(16));

alter table sys.reg$ add (session_key VARCHAR2(1024));

ALTER TYPE sys.aq$_event_message
ADD ATTRIBUTE(pdb number)
CASCADE
/

ALTER TYPE sys.sh$shard_meta 
ADD ATTRIBUTE(flags NUMBER)
CASCADE
/

ALTER TABLE sys.aq$_queue_shards ADD (flags NUMBER);

-- alter type add pdb 
ALTER TYPE sys.aq$_srvntfn_message
  ADD ATTRIBUTE(pdb NUMBER)
  CASCADE
/

Rem ===================
Rem End 12.0 AQ changes
Rem ===================

alter sequence invalidation_reg_id$
  cache 300
/

Rem =================
Rem End AQ changes
Rem =================

REM create a table to store the sql errors that occur during parsing so that
REM the next time the same bad sql is issued we can look up from this table
REM and throw the same error instead of doing a hard parse
create table sqlerror$
(
  sqlhash   varchar(32)  not null,
  error#    number       not null,
  errpos#   number       not null,
  flags     number       not null);

Rem =======================================================================
Rem  add spare columns to sqlerror$
Rem =======================================================================
Rem
alter table sqlerror$ add
(
  spare1 number default 0 not null
);
alter table sqlerror$ add
(
  spare2 number default 0 not null
);
alter table sqlerror$ add
(
  spare3 number default 0 not null
);

Rem =======================================================================
Rem  End of changes for bug 12326358
Rem =======================================================================

Rem =======================================================================
Rem  Bug #5842629 : direct path load and direct path export
Rem =======================================================================
Rem Bug #11787333: delete records first if they already exist.
Rem 
delete from STMT_AUDIT_OPTION_MAP where option# = 330;
delete from STMT_AUDIT_OPTION_MAP where option# = 331;
insert into STMT_AUDIT_OPTION_MAP values (330, 'DIRECT_PATH LOAD', 0);
insert into STMT_AUDIT_OPTION_MAP values (331, 'DIRECT_PATH UNLOAD', 0);
Rem =======================================================================
Rem  End Changes for Bug #5842629
Rem =======================================================================  

Rem =======================================================================
Rem BEGIN Upgrade changes to add dictionary objects for new Audit config
Rem =======================================================================
create table aud_policy$ (
  policy#         number not null,
  type            number not null, /*     0 - Invalid
                                    *  0x01 - System Privilgege options
                                    *  0x02 - System Action options
                                    *  0x04 - Object Action options
                                    *  0x08 - Local Audit Policy in case of 
                                    *         Consolidated Database
                                    *  0x10 - Common Audit Policy in case of 
                                    *         Consolidated Database
                                    *  0x20 - Role Privilege options
                                    */
  syspriv         varchar2(2000),
  sysactn         varchar2(2000),
  condition       varchar2(4000),
  condition_eval  number)
/
create table aud_object_opt$ (
  object#         number not null,
  policy#         number not null,
  action#         varchar2(100),
  type            number not null,  /*   1 - Role audit options
                                     *   2 - Schema object audit options
                                     *   3 - DV Realm option
                                     *   4 - DV Rule set option
                                     *   5 - DV Factor option
                                     */
  comp_info       varchar2(128))    
                                    /* For DV objects, this column will
                                     * be used to store the names of 
                                     * realms, rule sets or factors.
                                     */
/
create table audit_ng$ (
  user#           number,          /*  -1 - ALL
                                    *   0 - SYS
                                    *   1 - PUBLIC(SYSOPER)
                                    */
  policy#         number,
  when            number,          /*  1 - Success
                                    *  2 - Failure
                                    *  3 - Both
                                    */
  how             number)          /* 1 - By, 2 - Except */
/
create table aud_context$ (
  namespace      varchar2(128)  NOT NULL,
  attribute      varchar2(128)  NOT NULL,
  user#          number)
/
create unique index i_aud_context on aud_context$(namespace, attribute, user#)
                       /* this index is more for uniqueness than performance */
/

Rem
Rem Create pre-defined Audit policies
Rem
Rem
Rem Audit policy to audit user account & privilege management
create audit policy ora_account_mgmt 
 actions create user, alter user, drop user, create role, drop role,
         alter role, set role, grant, revoke
/
comment on audit policy ora_account_mgmt is
'Audit policy containing audit options for auditing account management actions'
/
Rem
Rem Audit policy to audit Database parameter settings
create audit policy ora_database_parameter
  actions alter database, alter system, create spfile
/
comment on audit policy ora_database_parameter is
'Audit policy containing audit options to audit changes in database parameters'
/
Rem Audit policy containing all Secure Configuration audit-options
create audit policy ora_secureconfig
  privileges alter any table, create any table, drop any table,
             create any procedure, drop any procedure, alter any procedure,
             grant any privilege, grant any object privilege, grant any role,
             audit system, create external job, create any job,
             create any library, exempt access policy, create user,
             drop user, alter database, alter system, 
             create public synonym, drop public synonym, 
             create sql translation profile,
             create any sql translation profile,
             drop any sql translation profile,
             alter any sql translation profile,translate any sql,
             exempt redaction policy, purge dba_recyclebin, logmining,
             administer key management
  actions alter user, create role, alter role, drop role, set role,
          create profile, alter profile, drop profile,
          create database link, alter database link, drop database link,
          logon, logoff, create directory, drop directory,
          create pluggable database, drop pluggable database,
          alter pluggable database
/
comment on audit policy ora_secureconfig is
'Audit policy containing audit options as per database security best practices'
/

Rem =======================================================================
Rem End Upgrade changes to add dictionary objects for new Audit config
Rem =======================================================================


Rem =======================================================================
Rem  Project 32008: add ADMINISTER KEY MANAGEMENT audit option and action
Rem =======================================================================

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (343, 'ADMINISTER KEY MANAGEMENT', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-343, 'ADMINISTER KEY MANAGEMENT', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem =======================================================================
Rem  End Changes for project 32008
Rem =======================================================================

Rem =======================================================================
Rem  Project 26121 DB Consolidation: add PDB audit option and privileges
Rem =======================================================================

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-375, 'CREATE PLUGGABLE DATABASE', 0);  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-377, 'SET CONTAINER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (375, 'CREATE PLUGGABLE DATABASE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (377, 'SET CONTAINER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem =======================================================================
Rem  End Changes for project 26121
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Database Replay 
Rem =======================================================================
Rem
Rem add columns to WRR$_CAPTURES and WRR$_REPLAYS
Rem
Rem wrr$_captures
alter table WRR$_CAPTURES add (sqlset_owner varchar2(30));
alter table WRR$_CAPTURES add (sqlset_name varchar2(30));
Rem wrr$_replays
alter table WRR$_REPLAYS add (sqlset_owner varchar2(30));
alter table WRR$_REPLAYS add (sqlset_name varchar2(30));
alter table WRR$_REPLAYS add (sqlset_cap_interval number);
alter table WRR$_REPLAYS add (filter_set_name varchar2(1000));
alter table WRR$_REPLAYS add (schedule_name varchar2(100));
alter table WRR$_REPLAYS add (num_admins number);
alter table WRR$_REPLAY_SEQ_DATA add (schedule_cap_id number);
alter table WRR$_CONNECTION_MAP add (schedule_cap_id number);
alter table WRR$_REPLAY_DATA add (schedule_cap_id number);
alter table WRR$_REPLAY_DEP_GRAPH add (schedule_cap_id number);
alter table WRR$_REPLAY_COMMITS add (schedule_cap_id number);
alter table WRR$_REPLAY_REFERENCES add (schedule_cap_id number);
alter table WRR$_REPLAY_FILTER_SET add (default_action varchar2(20));
alter table WRR$_REPLAY_DIVERGENCE add (cap_file_id number);
alter table WRR$_REPLAY_SQL_BINDS add (cap_file_id number);

Rem We have moved some UPDATE calls for  tables WRR$_REPLAY_DIVERGENCE and
Rem WRR$_REPLAY_SQL_BINDS to file a1102000.sql to fix lrg problem 5759823.

Rem =======================================================================
Rem  End Changes for Database Replay 
Rem =======================================================================

Rem ==========================
Rem Begin Bug #8862486 changes
Rem ==========================

Rem Directory EXECUTE auditing (action #135)
Rem Bug #11787333: delete record first if it already exists.
Rem 
delete from audit_actions where action = 135;
insert into audit_actions values (135, 'DIRECTORY EXECUTE');

Rem ========================
Rem End Bug #8862486 changes
Rem ========================

Rem ===========================================================================
Rem add new columns to WRH$_PERSISTENT_QUEUES and WRH$_PERSISTENT_SUBSCRIBERS
Rem ===========================================================================

alter table WRH$_PERSISTENT_QUEUES add (browsed_msgs          number);
alter table WRH$_PERSISTENT_QUEUES add (enqueue_cpu_time      number);
alter table WRH$_PERSISTENT_QUEUES add (dequeue_cpu_time      number);
alter table WRH$_PERSISTENT_QUEUES add (avg_msg_age           number);
alter table WRH$_PERSISTENT_QUEUES add (dequeued_msg_latency  number);
alter table WRH$_PERSISTENT_QUEUES add (enqueue_transactions  number);
alter table WRH$_PERSISTENT_QUEUES add (dequeue_transactions  number);
alter table WRH$_PERSISTENT_QUEUES add (execution_count       number);

alter table WRH$_PERSISTENT_SUBSCRIBERS add (avg_msg_age           number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (browsed_msgs          number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (elapsed_dequeue_time  number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (dequeue_cpu_time      number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (dequeue_transactions  number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (execution_count       number);

Rem ===========================================================================
Rem End changes to WRH$_PERSISTENT_QUEUES and WRH$_PERSISTENT_SUBSCRIBERS 
Rem ===========================================================================

Rem ===========================================================================
Rem add new columns to WRH$_BUFFERED_QUEUES and WRH$_BUFFERED_SUBSCRIBERS
Rem ===========================================================================
alter table WRH$_BUFFERED_QUEUES add (expired_msgs                    number);
alter table WRH$_BUFFERED_QUEUES add (oldest_msgid                   raw(16));
alter table WRH$_BUFFERED_QUEUES add (oldest_msg_enqtm          timestamp(3));
alter table WRH$_BUFFERED_QUEUES add (queue_state               varchar2(25));
alter table WRH$_BUFFERED_QUEUES add (elapsed_enqueue_time            number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_dequeue_time            number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_transformation_time     number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_rule_evaluation_time    number);
alter table WRH$_BUFFERED_QUEUES add (enqueue_cpu_time                number);
alter table WRH$_BUFFERED_QUEUES add (dequeue_cpu_time                number);
alter table WRH$_BUFFERED_QUEUES add (last_enqueue_time         timestamp(3));
alter table WRH$_BUFFERED_QUEUES add (last_dequeue_time         timestamp(3));

alter table WRH$_BUFFERED_SUBSCRIBERS add (last_browsed_seq           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_browsed_num           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeued_seq          number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeued_num          number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (current_enq_seq            number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (total_dequeued_msg         number); 
alter table WRH$_BUFFERED_SUBSCRIBERS add (expired_msgs               number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (message_lag                number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (elapsed_dequeue_time       number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (dequeue_cpu_time           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeue_time    timestamp(3));
alter table WRH$_BUFFERED_SUBSCRIBERS add (oldest_msgid              raw(16));
alter table WRH$_BUFFERED_SUBSCRIBERS add (oldest_msg_enqtm     timestamp(3));
Rem ===========================================================================
Rem End changes to WRH$_BUFFERED_QUEUES and WRH$_BUFFERED_SUBSCRIBERS 
Rem ===========================================================================

Rem *************************************************************************
Rem AWR substitution variable setup
Rem   - Get DBID to allow correct default value for CON_DBID
Rem *************************************************************************

column new_con_dbid new_value new_con_dbid
select dbid new_con_dbid from v$database;

Rem *************************************************************************
Rem END AWR substitution variable setup
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to STS due to CDB
Rem *************************************************************************
Rem Add new column to the STS definitions table
alter table wri$_sqlset_definitions
 add (con_dbid number default &new_con_dbid not null);


Rem Add new column to the STS statements table and change its primary key
alter table wri$_sqlset_statements
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_statements_idx_01;

drop index wri$_sqlset_statements_idx_02;


Rem Add new column to the STS plans table and change its primary key
alter table wri$_sqlset_plans
 add(con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_plans_idx_01;


Rem Add new column to the STS stats table and change its primary key
alter table wri$_sqlset_statistics
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_statistics_idx_01;

Rem Add new column to the STS mask table and change its primary key
alter table wri$_sqlset_mask
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_mask_idx_01;


Rem Add new column to the STS binds table and change its primary key
alter table wri$_sqlset_binds
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_binds_idx_01;

Rem Add new column to the STS plan lines table and change its primary key
alter table wri$_sqlset_plan_lines
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_plan_lines_idx_01;

Rem Add new column to the STS plans_tocap table and change its primary key
alter table wri$_sqlset_plans_tocap
 add (con_dbid number default &new_con_dbid not null);

Rem We have added a new column to this index in 12g. The index will be 
Rem correctly created in catsqlt.sql, so here we just drop it.
drop index wri$_sqlset_plans_tocap_idx_01;

Rem We have added a new attribute to the type sqlset_row in 12g. However
Rem this is an in-memory type only and will be created along with its new
Rem constructor in catsqlt.sql. Hence we just drop it here, so that it will
Rem be correctly created in catsqlt.sql
drop type sqlset_row force;  
drop public synonym sqlset_row;

Rem Add new column to the SQLTUNE plan hash table and change its primary key
alter table wri$_adv_sqlt_plan_hash
 add (con_dbid number default &new_con_dbid not null);

Rem *************************************************************************
Rem End Changes to STS due to CDB
Rem *************************************************************************

Rem ==========================================================================
Rem Begin advisor framework
Rem ==========================================================================

Rem --------------------------------------------------------------------------
Rem SPA changes
Rem --------------------------------------------------------------------------
Rem in 11.2, we added a new parameter EXECUTE_COUNT to control the
Rem execution count in the sql analyze when doing SPA.

BEGIN
  -- add new parameters to existing tasks. Note that the definition 
  -- of these two parameters will be added later during upgrade 
  -- when dbms_advisor.setup_repository is called. 
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'EXECUTE_COUNT', 'UNUSED', 1,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'EXECUTE_COUNT'))#';    

  -- handle exception when upgrading from 9i. The advisor tables do not exist
  EXCEPTION 
    WHEN OTHERS THEN
      IF SQLCODE = -942 
        THEN NULL;
      ELSE
        RAISE;
      END IF;
END;
/

Rem --------------------------------------------------------------------------
Rem ADDM changes
Rem --------------------------------------------------------------------------
Rem
alter table wri$_adv_addm_tasks add (fdg_count number);

Rem --------------------------------------------------------------------------
Rem Advisor framework changes 
Rem --------------------------------------------------------------------------
Rem in 12g as part of the consolidated database project, we added extra 
Rem attributes to the wri$_adv_objects table so that clients/advisors 
Rem such sqltune can store pdb-specific information in the framework  
alter table wri$_adv_objects add (
  attr11 number,
  attr12 number,
  attr13 number,
  attr14 number,
  attr15 number,
  attr16 varchar2(4000),                        
  attr17 varchar2(4000),
  attr18 varchar2(4000),
  attr19 varchar2(4000),
  attr20 varchar2(4000));

Rem ==========================================================================
Rem End advisor framework
Rem ==========================================================================


Rem ==========================================================================
Rem BEGIN SMO Changes 
Rem ==========================================================================

Rem in 12g as part of the consolidated database project, we added an extra 
Rem column to the sqlobj$auxdata table to store the task container dbid
alter table sqlobj$auxdata add (task_con_dbid number); 

Rem ==========================================================================
Rem End SMO Changes 
Rem ==========================================================================

Rem*************************************************************************
Rem BEGIN Changes for SEQ$
Rem*************************************************************************

ALTER TABLE seq$ add (PARTCOUNT number);

Rem*************************************************************************
Rem END Changes for SEQ$
Rem*************************************************************************
  

Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************
DECLARE
  stmt VARCHAR2(200);
BEGIN
  -- if this column already exists, then the following updates are unnecessary
  stmt := 'alter table resource_plan_directive$ ' || 
          'add (parallel_queue_timeout number)';

  execute immediate stmt;

  update resource_plan_directive$ set
    max_active_sess_target_p1 = 4294967295;

  -- This part of the procedure relies on the success of the alter
  -- table above. Unless this is done as an execute immediate,
  -- the PL/SQL will not compile, as parallel_queue_timeout does
  -- not exist.
  stmt := 'update resource_plan_directive$ set ' ||
            'parallel_queue_timeout = 4294967295';

  execute immediate stmt;

  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 
      THEN RETURN;
    ELSE
      RAISE;
    END IF;
END;
/

Rem Update WRH$_RSRC_CONSUMER_GROUP (basis for dba_hist_rsrc_consumer_group)
alter table WRH$_RSRC_CONSUMER_GROUP add (pqs_queued                number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_queued_time            number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_queue_time_outs        number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pqs_completed             number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_servers_used           number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_active_time            number);

Rem Update WRH$_RSRC_PLAN (basis for dba_hist_rsrc_plan)
alter table WRH$_RSRC_PLAN add (parallel_execution_managed    varchar2(4));

Rem This is needed for bug #9207475 to allow AWR snapshots to include
Rem the currently active plan
alter table WRH$_RSRC_PLAN modify (end_time date null);

Rem *************************************************************************
Rem Resource Manager related changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Change the lengths of module and action
Rem *************************************************************************

alter table SQLOBJ$AUXDATA modify (module varchar2(64));
alter table SQLOBJ$AUXDATA modify (action varchar2(64));

alter table WRH$_ACTIVE_SESSION_HISTORY_BL modify (module varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL modify (action varchar2(64));

alter table WRH$_ACTIVE_SESSION_HISTORY modify (module varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY modify (action varchar2(64));

alter table WRI$_ADV_SQLT_STATISTICS modify (module varchar2(64));
alter table WRI$_ADV_SQLT_STATISTICS modify (action varchar2(64));

alter table WRI$_SQLSET_STATEMENTS modify (module varchar2(64));
alter table WRI$_SQLSET_STATEMENTS modify (action varchar2(64));

alter table WRR$_REPLAY_DIVERGENCE modify (module varchar2(64));
alter table WRR$_REPLAY_DIVERGENCE modify (action varchar2(64));

alter table WRH$_SQLSTAT modify (module varchar2(64));
alter table WRH$_SQLSTAT modify (action varchar2(64));

alter table WRH$_SQLSTAT_BL modify (module varchar2(64));
alter table WRH$_SQLSTAT_BL modify (action varchar2(64));

alter table STREAMS$_COMPONENT_EVENT_IN modify (module_name varchar2(64));
alter table STREAMS$_COMPONENT_EVENT_IN modify (action_name varchar2(64));

alter table STREAMS$_PATH_BOTTLENECK_OUT modify (module_name varchar2(64));
alter table STREAMS$_PATH_BOTTLENECK_OUT modify (action_name varchar2(64));

alter type SQLSET_ROW modify attribute module varchar2(64) cascade;
alter type SQLSET_ROW modify attribute action varchar2(64) cascade;
-- type alert_type is used for AQ messages
-- Turn ON the event to enable DDL on AQ tables
alter session set events '10851 trace name context forever, level 1';
alter type sys.alert_type
      modify attribute module_id varchar2(64) cascade;

-- Turn OFF the event to disable DDL on AQ tables
alter session set events '10851 trace name context off';

Rem *************************************************************************
Rem END Change the lengths of module and action
Rem *************************************************************************

Rem *************************************************************************
Rem WRH$_ACTIVE_SESSION_HISTORY changes
Rem   - Add columns to ASH
Rem *************************************************************************
-- Turn ON the event to disable the partition check
-- Needed for upgrade of AWR tables
alter session set events  '14524 trace name context forever, level 1';

alter table WRH$_ACTIVE_SESSION_HISTORY add (dbreplay_file_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (dbreplay_call_counter NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (px_flags NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY
 add (con_dbid NUMBER default &new_con_dbid NOT NULL);
alter table WRH$_ACTIVE_SESSION_HISTORY add (dbop_name varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY add (dbop_exec_id NUMBER);

alter table WRH$_ACTIVE_SESSION_HISTORY drop primary key drop index
/
create unique index WRH$_ACTIVE_SESSION_HISTORY_PK on
 WRH$_ACTIVE_SESSION_HISTORY
  (dbid, snap_id, instance_number, sample_id, session_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_ACTIVE_SESSION_HISTORY
 add constraint WRH$_ACTIVE_SESSION_HISTORY_PK primary key
  (dbid, snap_id, instance_number, sample_id, session_id, con_dbid)
 using index WRH$_ACTIVE_SESSION_HISTORY_PK
/
alter index WRH$_ACTIVE_SESSION_HISTORY_PK noparallel
/

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbreplay_file_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbreplay_call_counter NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (px_flags NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL 
 add (con_dbid NUMBER default &new_con_dbid NOT NULL);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbop_name varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbop_exec_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL drop primary key;
alter table WRH$_ACTIVE_SESSION_HISTORY_BL
 add constraint WRH$_ASH_BL_PK primary key
    (dbid, snap_id, instance_number, sample_id, session_id, con_dbid )
 using index tablespace SYSAUX;

-- Turn OFF the event to disable the partition check
-- Needed for upgrade of AWR tables
alter session set events  '14524 OFF';

Rem *************************************************************************
Rem END WRH$_ACTIVE_SESSION_HISTORY
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 9766219 - BEGIN
Rem *************************************************************************

Rem
Rem Errors trapped are the following:
Rem ORA-04042 - Does not exists
Rem ORA-01927 - Cannot Revoke Priv you did not grant
Rem ORA-00942 - Table of view does not exits
Rem ORA-04045 - Errors during recomp
Rem
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.URIFACTORY FROM PUBLIC';
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.URIFACTORY TO PUBLIC';
EXCEPTION 
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem *************************************************************************
Rem Bug 9766219 - END
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 12674093  - BEGIN
Rem *************************************************************************
DECLARE
BEGIN
  execute immediate  'alter package XDB.DBMS_CSX_INT compile reuse settings';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/
Rem *************************************************************************
Rem Bug  12674093 - END
Rem *************************************************************************

Rem *************************************************************************
Rem OLAP changes - BEGIN
Rem *************************************************************************

Rem
Rem Errors trapped are the following:
Rem ORA-04042 - Does not exists
Rem ORA-01927 - Cannot Revoke Priv you did not grant
Rem ORA-00942 - Table of view does not exits
Rem ORA-04045 - Errors during recomp
Rem

-- More limited grants will occur in olaptf.sql
BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON CUBE_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAPRC_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_SRF_T FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_NUMBER_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_TEXT_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_TEXT FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_DATE_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_DATE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_BOOL_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_BOOL FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/ 

Rem *************************************************************************
Rem Bug  12957533 - BEGIN
Rem *************************************************************************

-- Missing from 11.2 upgrade
create sequence awlogseq$ /* sequence for log id numbers */
  start with 1
  increment by 1
  cache 10
  maxvalue 18446744073709551615
/

Rem *************************************************************************
Rem Bug  12957533 - END
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 13242046  - BEGIN
Rem *************************************************************************

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
    values (-393, 'SELECT ANY MEASURE FOLDER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
    values (-394, 'ALTER ANY MEASURE FOLDER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
    values (-395, 'SELECT ANY CUBE BUILD PROCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP 
    values (-396, 'ALTER ANY CUBE BUILD PROCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
    values (393, 'SELECT ANY MEASURE FOLDER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
    values (394, 'ALTER ANY MEASURE FOLDER', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
    values (395, 'SELECT ANY CUBE BUILD PROCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP 
    values (396, 'ALTER ANY CUBE BUILD PROCESS', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (144, 'CREATE MEASURE FOLDER');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (145, 'ALTER MEASURE FOLDER');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (146, 'DROP MEASURE FOLDER');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (147, 'CREATE CUBE BUILD PROCESS');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (148, 'ALTER CUBE BUILD PROCESS');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into audit_actions values (149, 'DROP CUBE BUILD PROCESS');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem Bug 13242046   - END
Rem *************************************************************************

-- In 12.1+, only system AWs remain in noexp$, user AWs are not
DELETE FROM sys.noexp$ WHERE (owner, name, obj_type) IN
  (SELECT u.name, 'AW$'||a.awname, 2
     FROM sys.aw$ a, sys.user$ u
    WHERE awseq# >= 1000 AND u.user#=a.owner#)
/

Rem *************************************************************************
Rem OLAP changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem WRM$_SNAPSHOT changes - BEGIN
Rem *************************************************************************

Rem add snap_timezone column to wrm$_snapshot
alter table WRM$_SNAPSHOT add (snap_timezone interval day(0) to second(0));

Rem *************************************************************************
Rem WRM$_SNAPSHOT changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem  Project 32973 Privilege Capture changes - BEGIN
Rem *************************************************************************

create role CAPTURE_ADMIN;

GRANT CAPTURE_ADMIN TO DBA WITH ADMIN OPTION;

Rem *************************************************************************
Rem Privilege Capture changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 18461047: The below ALTER TABLE on USER_HISTORY$ increased the length
Rem of the password column to 4000. Fix for 14731670 now expects all users
Rem created in 12.1.0.2 to have 12c verifier and hence this should be moved
Rem before the first CREATE USER in the script
Rem *************************************************************************
begin
  execute immediate 'alter table user_history$ modify password varchar2(4000)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

Rem *************************************************************************
Rem Project 46885 : Inactive Account Time Password Profile Parameter - BEGIN
Rem Profile DEFAULT which is associated with all the newly created users by
Rem default, needs to be altered to a have a row in PROFILE$ corresponding
Rem to Inactive_Account_Time parameter, otherwise at the time of profile limit
Rem population, create user would run into ORA-600[kzdpfr:pwd] errors. So this
Rem statement needs to run before the first CREATE USER in the script
Rem *************************************************************************
declare
  num_rows  number := -1;
  iatVal    number := -1;
begin
  select
    count(*) into num_rows
  from
    resource_map
  where
    name = 'INACTIVE_ACCOUNT_TIME';
  if num_rows = 0 then
    insert into resource_map values ( 7, 1, 'INACTIVE_ACCOUNT_TIME' );
  end if;

  /* For every existing profile, insert a row into profile$ table for
  ** Inactive_Account_Time with the following entries
  **   RESOURCE# = 7 (Next number after PASSWORD_GRACE_TIME [6])
  **   TYPE#     = 1 (This is a password profile parameter [0 for resource])
  **   LIMIT#    = 0 (Parameter value same as those of DEFAULT profile) for
  **               non-DEFAULT profile and UNLIMITED for DEFAULT profile
  */
  for rec in (select profile# from profname$ order by profile#)
  loop
    num_rows := -1;
    select
      count(*) into num_rows
    from
      profile$
    where
      profile#  = rec.profile# and
      type#     = 1 and
      resource# = 7;
    if num_rows = 0 then
      iatVal := (case rec.profile# when 0 then 2147483647 else 0 end);
      insert into profile$ values (rec.profile#, 7, 1, iatVal);
    end if;
  end loop;
end;
/

commit
/

Rem *************************************************************************
Rem Project 46885 : Inactive Account Time Password Profile Parameter - END
Rem *************************************************************************

Rem *************************************************************************
Rem Unified Auditing changes - BEGIN
Rem *************************************************************************

CREATE ROLE AUDIT_ADMIN;

CREATE ROLE AUDIT_VIEWER;

CREATE USER AUDSYS IDENTIFIED BY AUDSYS ACCOUNT LOCK PASSWORD EXPIRE;

Rem
Rem Errors trapped are the following:
Rem ORA-04042 - Does not exists
Rem ORA-01927 - Cannot Revoke Priv you did not grant
Rem ORA-00942 - Table of view does not exits
Rem ORA-04045 - Errors during recomp
Rem
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER AUDSYS FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

UPDATE user$ set password=null,spare4=null where name='AUDSYS';

UPDATE user$ set password=null,spare4=null where name='REMOTE_SCHEDULER_AGENT';

commit;

Rem Bug 14362936
alter user AUDSYS quota unlimited on SYSAUX;
grant create table to AUDSYS;

Rem Bug #16310544
BEGIN
  insert into STMT_AUDIT_OPTION_MAP values(357, 'PLUGGABLE DATABASE', 0);
  commit;
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE = -00001 THEN NULL; 
    ELSE RAISE; 
    END IF;
END;
/

Rem *************************************************************************
Rem Unified Auditing changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN: Default Password Scanner upgrade changes
Rem *************************************************************************

Rem Add product column to default_pwd$

ALTER TABLE sys.default_pwd$ ADD
            (product varchar2(4000) default NULL);

Rem *************************************************************************
Rem END: Default Password Scanner upgrade changes
Rem *************************************************************************

Rem =========================================================================
Rem Attribute associations of VPD policies related changes - BEGIN
Rem =========================================================================

create table rls_csa$                            /* Attribute Associations */
(
  obj#          NUMBER NOT NULL,       /* synonym/table/view object number */
  gname         VARCHAR2(128) NOT NULL,            /* name of policy group */
  pname         VARCHAR2(128) NOT NULL,                  /* name of policy */
  ns            VARCHAR2(128) NOT NULL,               /* context namespace */
  attr          VARCHAR2(128) NOT NULL                        /* attribute */
)
/
create index i_rls_csa on rls_csa$(obj#, gname, pname);
/

Rem =========================================================================
Rem Attribute associations of VPD policies related changes - END
Rem =========================================================================

Rem *************************************************************************
Rem Optimizer changes - BEGIN
Rem *************************************************************************
alter session set events  '14524 trace name context forever, level 1';

-- bug 21073559/rti 20648269
-- do not drop partitioned tables such as tmp_wri$_optstat_synopsis$ since
-- it issues recursive queries that refer to tables (such as 
-- compression_stats$) created in catproc and it is not created yet 
-- (c1102000.sql is called before catproc in catupgrd)

drop table tmp_wri$_optstat_synhead$;
drop table tmp_wri$_optstat_synobj;

declare
  type numtab is table of number;
  tobjns      numtab := numtab();
  tobjn       number;
  cnt         number := 0;
  before11202 boolean := FALSE;  
         -- whether upgrade from a verion prior to (not including) 11202
  create_new_head  boolean := FALSE;
  create_new_synop boolean := FALSE;
  create_synop  varchar2(32767) := 
   'create table wri$_optstat_synopsis$
    ( bo#           number not null,
      group#        number not null,
      intcol#       number not null,           
      hashvalue     number not null 
    ) 
    partition by list(bo#) 
      subpartition by hash(group#) 
      subpartitions 32
    (
      partition p0 values (0)
    ) 
    tablespace sysaux
    pctfree 1
    enable row movement';
  create_head varchar2(32767) := 
    'create table wri$_optstat_synopsis_head$ 
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
     )tablespace sysaux 
     pctfree 1
     enable row movement';
  create_head_index varchar2(32767) := 
    'create unique index i_wri$_optstat_synophead on 
     wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
     tablespace sysaux';

  tmptabname varchar2(30);

  cursor cur is
    select 'drop table ' || o.name sqltxt
    from obj$ o, user$ u
    where o.owner# = u.user# and u.name = 'SYS' and
          o.name in
          (upper('tmp_wri$_optstat_synhead$'),
           upper('tmp_wri$_optstat_synobj')) and
         o.type# = 2;
begin

  -- upgrade process is as follows
  -- step 1: upgrade synopsis head. if synopsis head does not exist,
  --         create it
  -- step 2: check whether synopsis table is already in new schema.
  --         if yes, return. If not exist, create a new one
  -- step 3: rename existing synopsis head and synopsis to tmp_*;
  --         create synopsis and synopsis head in new schema
  -- step 4: populate synopsis using tmp_*, depending on synopsis
  --         updating status, populate synopsis head accordingly
  -- steps 1 ~ 3 are done in c1102000.sql while step 4 is done in
  -- a1102000.sql (step 4 might perform partitioning related
  -- operations. Such partitioning related operations cannot be
  -- done in c1102000.sql since they require dictionary tables 
  -- that have not been created in c1102000.sql yet)

  -- step 1: upgrade synopsis head
  -- no longer need synopsis# primary key constraint
  begin
    execute immediate
      'alter table wri$_optstat_synopsis_head$ drop primary key';
  exception
    when others then 
      if (sqlcode = -2441) then
        -- ORA-02441: Cannot drop nonexistent primary key
        -- primary key has been dropped, no action
        null;
      elsif (sqlcode = -942) then
        -- synopsis head does not exist, create it 
        -- index will be created later
        create_new_head := TRUE;
      else
        raise;
      end if;
  end;

  if (create_new_head) then
    -- synopsis head does not exist, create it 
    -- index will be created later
     execute immediate create_head;
  else
    -- synopsis_head$ exists.
    -- make sure synopsis# no longer a primary key and can thus be null  
    begin
      execute immediate
        'alter table wri$_optstat_synopsis_head$ modify (synopsis# null)';
    exception
      when others then 
        if (sqlcode = -1451) then
          -- ORA-01451: column to be modified to NULL cannot be modified 
          -- to NULL
          -- synopsis# already nullable, no action
          null;
        else
          raise;
        end if;
    end;
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

  -- step 2: check whether synopsis table is already in new schema.
  --         if yes, return. If not exist, create a new one
  -- check whether we are already in new schema
  -- if we have upgraded it, this will throw 904 error that will be caught
  begin
    execute immediate 
      'select synopsis# 
       from wri$_optstat_synopsis$
       where rownum < 2';
  exception
    when others then
      if (sqlcode = -904) then 
        -- ORA-904: "S"."SYNOPSIS#": invalid identifier 
        -- has been upgraded at least to 11.2.0.2
        -- equivalent to check all_part_tables. 
        -- partitioning_type is defined as
        --  decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
        --    5, 'REFERENCE', 'UNKNOWN'), 
        select count(*) into cnt
        from obj$ o, partobj$ po, user$ u
        where o.owner# = u.user# and u.name = 'SYS' and
              o.name = 'WRI$_OPTSTAT_SYNOPSIS$' and
              o.subname is null and
              o.obj# = po.obj# and
              po.parttype = 4;

        if (cnt = 1) then
          -- synopsis$ table is list-hash, has been successfully upgraded
          -- to 12g, do nothing
          return;
        end if;
      elsif (sqlcode = -942) then
        -- ORA-00942: table or view does not exist
        -- wri$_optstat_synopsis$ does not exist
        create_new_synop := TRUE;
      else
        raise;
      end if;
  end;

  if (create_new_synop) then
    -- recreate wri$_optstat_synopsis$ (we might lose old data)
    execute immediate create_synop;

    if (not create_new_head) then
      -- since we have recreated synopsis$, truncate existing synopsis 
      -- head$
      execute immediate 'truncate table wri$_optstat_synopsis_head$';
    end if;

    -- we are done with synopsis$ (all old data are lost though)
    return;
  end if;

  -- step 3: rename existing synopsis head and synopsis to tmp_*;
  -- create synopsis and synopsis head in new schema

  -- rename synopsis and synopsis head table to tmp_*
  -- create new synopsis and new synopsis head 
  -- we will populate new synopsis and synopsis head using tmp_
  -- in a1102000. We need to perform PMOP which cannot be done 
  -- here since some partitioning related tables are not created
  -- yet at this point

  -- at this point wri$_optstat_synopsis_head$ must be in new schema
  -- and wri$_optstat_synopsis$ must be in old schema
  select count(*) into cnt
  from obj$ o, user$ u
  where o.owner# = u.user# and u.name = 'SYS' and
        o.name = upper('tmp_wri$_optstat_synhead$');

  if (cnt = 0) then
    -- tmp_wri$_optstat_synhead$ does not exist.
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
  end if;

  -- rename synopsis to tmp_*
  -- we get here only when wri$_optstat_synopsis$ is still in the old
  -- schema. Old schema wri$_optstat_synopsis$ never co-exists with
  -- tmp_wri$_optstat_synopsis$ because the latter was renamed from 
  -- the former. So it is safe to rename without checking whether
  -- tmp_wri$_optstat_synopsis$ exists
  execute immediate 
    'rename wri$_optstat_synopsis$ to tmp_wri$_optstat_synopsis$';
  
  execute immediate create_synop;
  
  -- At this point tmp_wri$_optstat_synhead$ anand tmp_wri$_optstat_synopsis$ 
  -- are in new schema.  
  -- exchange non partitioned wri$_optstat_synopsis$ with partitioned tmp_
  -- wri$_optstat_synopsis$
 
  -- check whether we are already in new schema
  begin
    execute immediate 
      'select synopsis# 
       from tmp_wri$_optstat_synopsis$
       where rownum < 2';

    -- old table has synopsis# column, must be prior to 11202
    before11202 := TRUE;
  exception
    when others then
      if (sqlcode = -904) then 
        -- ORA-904: "S"."SYNOPSIS#": invalid identifier 
        -- has been upgraded at least to 11.2.0.2
        -- equivalent to
        -- select count(*)
        -- from user_part_tables
        -- where table_name = 'TMP_WRI$_OPTSTAT_SYNOPSIS$' and
        --       partitioning_type = 'LIST'
        -- c1102000.sql is run before catproc.sql. do not use any dictionary
        -- views to be safe
        select count(*) into cnt
        from obj$ o, partobj$ po, user$ u
        where o.owner# = u.user# and u.name = 'SYS' and
              o.name = 'TMP_WRI$_OPTSTAT_SYNOPSIS$' and
              o.type# = 2 and
              o.obj# = po.obj# and
              po.parttype = 4;

        if (cnt = 1) then
          -- even old synopsis$ table is list-hash, has been successfully 
          -- upgraded to 12, do nothing
          goto clean_up;
        end if;
      elsif (sqlcode = -942) then
        -- ORA-00942: table or view does not exist
        -- tmp synopsis table does not exist, cannot populate synopsis
        goto clean_up;
      else
        raise;
      end if;
  end;

  -- get all the partitioned tables that have synopses and
  -- the partitions still exist
  -- order by not needed since using "add partition" for 
  -- list partition
  begin  
    if (before11202) then
      -- store all the valid (bo#, group#) in tmp_wri$_optstat_synobj
      execute immediate
      'create table tmp_wri$_optstat_synobj as
       select distinct bo#
         from sys.tmp_wri$_optstat_synhead$
         where bo# in (select obj# from sys.tab$)';

      execute immediate 'select bo# from tmp_wri$_optstat_synobj '
      bulk collect into tobjns;
    else
      -- store all the valid bo# in tobjns
      execute immediate 
        'select distinct bo# 
         from sys.tmp_wri$_optstat_synhead$
         where bo# in (select obj# from sys.tab$)'
      bulk collect into tobjns;
    end if;
  exception
    when no_data_found then
      -- nothing to populate
      goto clean_up;
    when others then
      if (sqlcode = -942) then
        -- ORA-00942: table or view does not exist
        -- tmp synopsis head table does not exist, cannot populate synopsis
        goto clean_up;
      else
        raise;
      end if;
  end;

  -- create list partition
  for i in 1..tobjns.count loop
    tobjn := tobjns(i);
    
    execute immediate 'alter table wri$_optstat_synopsis$' ||
                     ' add partition p_' || tobjn || 
                     ' values (' || to_char(tobjn) || ')';
  end loop;

  if (before11202) then
    -- upgrade table prior to 11202
  
    if (tobjns.count > 0) then
      -- bug 22865331: only add the valid entries stored in 
      -- tmp_wri$_optstat_synobj
      execute immediate 
        '  insert /*+ append parallel */ 
           into wri$_optstat_synopsis$
           select /*+ full(h) full(s) leading(o h s) use_hash(s) */
             h.bo#,
             h.group#,
             h.intcol#,
             s.hashvalue
           from tmp_wri$_optstat_synhead$ h,
                tmp_wri$_optstat_synopsis$ s,
                tmp_wri$_optstat_synobj o
           where h.synopsis# = s.synopsis# and
                 h.bo# = o.bo#';
    end if;

    -- restore synopsis head
    execute immediate
      'drop table wri$_optstat_synopsis_head$';
    execute immediate 
      'rename tmp_wri$_optstat_synhead$ to wri$_optstat_synopsis_head$';
    execute immediate
      'alter index i2_wri$_optstat_synophead 
       rename to i_wri$_optstat_synophead';

  else   -- upgrade table from or after 11202
    -- #(16246179)
    -- 11.2.0.2 and above has same table definition except
    -- it is changed from range-hash to list-hash. Do exchange
    -- instead of insert for better performance. Also this avoids 
    -- additional space usage.
    if (tobjns.count > 0) then
      -- something to populate synopsis

      -- since we cannot drop partitioned table, there is no guarantee
      -- that there are no residue staging tables from previous runs.
      -- generate a unique name each time and drop them in a1102000.
      select 'TPART_SYNOPSIS$_' || ora_hash(systimestamp) 
      into tmptabname
      from dual; 

      execute immediate 
        'create table ' || tmptabname || 
        ' ( bo#           number not null,
            group#        number not null,
            intcol#       number not null,           
            hashvalue     number not null 
        ) 
        partition by hash(group#) 
        partitions 32
        tablespace sysaux
        pctfree 1
        enable row movement';

      for i in 1..tobjns.count loop
        tobjn := tobjns(i);

        -- bug 26614959: tobjns come from wri$_optstat_synopsis_head$.
        -- For a bo# in wri$_optstat_synopsis_head$, make sure it has 
        -- a partition in wri$_optstat_synposis$ before we exchange it
        select count(*) into cnt
        from obj$ o, user$ u
        where o.owner# = u.user# and u.name = 'SYS' 
          and o.name = 'TMP_WRI$_OPTSTAT_SYNOPSIS$'
          and o.subname = 'P_' || tobjn;

        if (cnt = 0) then
          -- there is no p_tobjn in tmp_wri$_optstat_synopsis$, 
          -- skip it
          continue;
        end if;

        -- tmp_wri$_optstat_synopsis$ <-> tpart_wri$_optstat_synopsis$
        -- tpart_wri$_optstat_synopsis <-> wri$_optstat_synopsis$
        begin
          execute immediate
            'alter table tmp_wri$_optstat_synopsis$ 
             exchange partition p_' || tobjn || 
            ' with table ' || tmptabname ||
            ' without validation ';

          execute immediate
            'alter table wri$_optstat_synopsis$ 
               exchange partition p_' || tobjn || 
            ' with table ' || tmptabname ||
             ' without validation ';
        exception
          when others then
            if (sqlcode = -2149) then
              -- 26614959: with the check in dba_tab_partitions, we should not 
              -- get here. But to be extra safe. If the synopsis population 
              -- for the current tobjn fail, continue to next tobjn
              continue;
            else
              raise;
            end if;  
        end; 

        begin
          -- we have succesfully upgraded the synopses, restore the old
          -- analyzetime
          execute immediate
            'insert /*+append */ into wri$_optstat_synopsis_head$
             select * from tmp_wri$_optstat_synhead$
             where bo# = '|| tobjn;
        exception
          when others then
            -- lrg 16660989: If column type does not match, tmp_wri$_
            -- optstat_synhead$ is in old format (spare2 is a clob) while 
            -- wri$_optstat_synhead$ is in new format. use an insert query 
            -- that accesses only useful columns in tmp_wri$_optstat_synhead$
            -- (synopsis#, spare1 and spare2 are no use)
            if (sqlcode = -932) then
              execute immediate 
              'insert /*+append */ into wri$_optstat_synopsis_head$
               (bo#, group#, intcol#, split, analyzetime)
               select bo#, group#, intcol#, split, analyzetime
               from tmp_wri$_optstat_synhead$
               where bo# = ' || tobjn;              
            else
              raise;
            end if;
        end;

        commit;

      end loop;
    
    end if;
  end if;
  
  <<clean_up>>
  -- drop tmp_* tables
  for stmt in cur loop
    execute immediate stmt.sqltxt;
  end loop;
   
exception
when others then
   -- drop tmp_* tables
  for stmt in cur loop
    execute immediate stmt.sqltxt;
  end loop;
  raise;
end;
/
   
-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

-- #(9577300) Column group usage
Rem #(10410249) create col_group_usage$ as a non iot table

variable found_iot number;


-- Check if col_group_usage$ is an iot
begin
  select count(*) into :found_iot
  from  user_tables 
  where table_name ='COL_GROUP_USAGE$' and iot_type = 'IOT';
end;
/

-- Save the contents if it is an iot
begin
  if (:found_iot != 0) then
    execute immediate
    q'# create table col_group_usage$_sav as select * from col_group_usage$ #';
  end if;
end;
/

-- Drop the iot
begin
  if (:found_iot != 0) then
    execute immediate
    q'# drop table col_group_usage$ purge #';
  end if;
end;
/

-- Create it as non iot. It may fail if it already exists and if it not an iot.
-- Upgrade ignores the error
create table col_group_usage$
(
  obj#              number,                                 /* object number */
  /*
   * We store intcol# separated by comma in the following column.
   * We allow upto 32 (CKYMAX) columns in the group. intcol# can be 
   * upto 1000 (or can be 64K in future or with some xml virtual columns?). 
   * Assume 5 digits for intcol# and one byte for comma. 
   * So max length would be 32 * (5+1) = 192
   */
  cols              varchar2(192 char),              /* columns in the group */
  timestamp         date,     /* timestamp of last time this row was changed */
  flags             number,                                 /* various flags */
  constraint        pk_col_group_usage$
  primary key       (obj#, cols))
  storage (initial 200K next 100k maxextents unlimited pctincrease 0)
/

-- Restore the contents. Fails if col_group_usage$ was not an iot
-- (col_group_usage$_sav will not be created in this case)
-- upgrade does not ignore 942 errors during insert and hence explicitly 
-- ignore it.
begin

  execute immediate
  q'# insert into col_group_usage$ select * from col_group_usage$_sav #';

exception
  when others then
    if (sqlcode = -942) then
      null;
    else
      raise;
    end if;
end;
/

-- Drop the staging table. Fails if col_group_usage$ was not an iot
drop table col_group_usage$_sav;

Rem *************************************************************************
Rem Optimizer changes - END
Rem *************************************************************************


Rem ===========================
Rem Begin Bug #11720698 changes
Rem ===========================

Rem Bug #11720698: delete old entries in warning_settings$ that correspond to
Rem dropped objects.  Break the delete into chunks of 100000 rows to avoid
Rem stressing undo.
Rem 

BEGIN
  LOOP
    DELETE FROM warning_settings$ WHERE rowid IN 
        (select rowid from warning_settings$ where obj# not in
            (select obj# from obj$) and rownum <= 100000);
    EXIT WHEN sql%ROWCOUNT = 0;
    COMMIT;
  END LOOP;
  COMMIT;
END;
/

Rem =========================
Rem End Bug #11720698 changes
Rem =========================


Rem=========================================================================
Rem Add changes to other SYS dictionary objects here 
Rem 
Rem=========================================================================

Rem upgrade registry$ table
alter table registry$ add (signature raw(20));
alter table registry$ add (edition varchar2(30));
alter table registry$ add (date_optionoff date);


Rem *************************************************************************
Rem DataPump changes - BEGIN
Rem *************************************************************************
Rem
Rem Register import callouts for metadata tables and views
Rem
create table impcalloutreg$                      /* register import callouts */
( package      varchar2(30) not null,           /* pkg implementing callouts */
  schema       varchar2(30) not null,                 /* pkg's owning schema */
  tag          varchar2(30) not null,      /* mandatory component identifier */
  class        number not null,     /* 1=system,           3=object instance */
                                    /* (2=schema support deferred)           */
  level#       number default 1000 not null, /* determines calling order for */
                 /* multiple pkgs registered at same callout pt: lower first */
  flags        number not null,                    /* Only used when class=3 */
  /* See dbmsdp.sql for flags definitions                                    */
  /* 0x01: KU$_ICRFLAGS_IS_EXPR: tgt_object is an expression to be evaluated */
  /*       with LIKE operator. Only valid for tables (not views)             */
  /* 0x02: KU$_ICRFLAGS_EARLY_IMPORT: tgt_object will be imported and its    */
  /*       post-instance callout executed before import of user tables       */
  /* 0x04: KU$_ICRFLAGS_GET_DEPENDENTS: child dependents of tgt_object (eg,  */
  /*       indexes, grants, constraints, etc) will be fetched at export time */
  /*       Only valid for tables (not views)                                 */
  /* 0x08: KU$_ICRFLAGS_EXCLUDE: tgt_object should not be exported when it   */
  /*       matches a wildcard registration via flag KU$_ICRFLAGS_IS_EXPR     */
  /* 0x10: KU$_ICRFLAGS_XDB_NO_TTS: tgt_object is exported only if the XDB   */
  /*       tablespace is not transportable (xdb use only)                    */
  tgt_schema   varchar2(30),       /* for class 2/3, the target schema or    */
                                 /* schema of the target object respectively */
  tgt_object   varchar2(30),       /* for class 3, the name of the tgt obj.  */
  tgt_type     number,          /* type of obj as defined in KQD.H. Must be  */
                                /* table, view, type, pkg or proc            */
  cmnt         varchar2(2000)  /* component description, for include/exclude */
)
/
--
-- Initially, a non-null comment was required for impcalloutreg$; the 
-- comment would be display in database_export_objects. That is not
-- desireable for the DATAPUMP (internal) option. 
-- The following assues a null cmnt is allowed.
--
begin
  execute immediate 'alter table impcalloutreg$ modify cmnt null';
exception when others then
  if sqlcode in (-1451) then null;
  else raise;
  end if;
end;
/
Rem
Rem Metadata API changes
Rem
alter table metascript$   add (
  r1seq#        number,                 /* sequence number prerequisite step */
  r2seq#        number                  /* sequence number prerequisite step */
)
/
Rem *************************************************************************
Rem DataPump changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem RAC/Service changes - BEGIN
Rem *************************************************************************

alter table service$ add(pdb varchar2(30));

create table exp_service$
(
  name        varchar2(64),                                  /* service name */
  attr_name   varchar2(100),                               /* attribute name */
  attr_value  varchar2(4000)                              /* attribute value */
)
/
 
Rem *************************************************************************
Rem RAC/Services changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Consolidated Database changes - BEGIN
Rem *************************************************************************

/* create a table container$ for information about containers
 * (Root and pluggable databases) 
 */
create table container$
(
 obj#            number not null,         /* Object number for the container */
 con_id#         number not null,                            /* container ID */
 dbid            number not null,                             /* database ID */
 con_uid         number not null,                               /* unique ID */
 status          number not null,                       /* active, plugged...*/
 create_scnwrp   number not null,                       /* creation scn wrap */
 create_scnbas   number not null,                       /* creation scn base */
 clnscnwrp       number,    /* clean offline scn - zero if not offline clean */
 clnscnbas       number,       /* clnscnbas - scn base, clnscnwrp - scn wrap */
 rdba            number not null,                 /*  r-dba of the container */
 flags           number,                                            /* flags */
 spare1          number,                                            /* spare */
 spare2          number,                                            /* spare */
 spare3          varchar2(128),                                     /* spare */
 spare4          varchar2(128)                                      /* spare */
)
/

CREATE UNIQUE INDEX i_container1 ON container$(obj#)
/

CREATE UNIQUE INDEX i_container2 ON container$(con_id#)
/

CREATE UNIQUE INDEX i_container3 ON container$(con_uid)
/

create table cdb_file$                    /* file table in a consolidated db */
(
 file#         number not null,                    /* file identifier number */
 con_id#       number not null,                              /* container ID */
 mtime         date,                        /* time it was created, modified */
 spare1        number,                                              /* spare */
 spare2        number,                                              /* spare */
 spare3        number,                                              /* spare */
 spare4        number,                                              /* spare */
 f_afn         number not null,              /* foreign absolute file number */
 f_dbid        number not null,                       /* foreign database id */
 f_cpswrp      number not null,                    /* foreign checkpoint scn */
 f_cpsbas      number not null,
 f_prlswrp     number not null,              /* foreign plugin resetlogs scn */
 f_prlsbas     number not null,
 f_prlstim     number not null              /* foreign plugin resetlogs time */
)
/

CREATE UNIQUE INDEX i_cdbfile1 ON cdb_file$(file#, con_id#)
/

create table pdb_history$
(
 name       varchar2(128) not null,                       /* Name of the PDB */
 con_id#    number  not null,                                /* Container ID */
 dbid       number  not null,                                 /* DBID of PDB */
 guid       raw(16) not null,                                 /* GUID of PDB */
 scnbas     number  not null,             /* SCN base when operation occured */
 scnwrp     number  not null,             /* SCN wrap when operation occured */
 time       date    not null,                 /* time when operation occured */
 operation  varchar2(16)  not null,   /* CREATE, CLONE, UNPLUG, PLUG, RENAME */
 db_version number  not null,                            /* Database version */
 c_pdb_name varchar2(128),                  /* Created, Cloned from PDB name */
 c_pdb_dbid number,                    /* Created, Cloned from PDB DBID name */
 c_pdb_guid raw(16),                        /* Created, Cloned from PDB GUID */
 c_db_name  varchar2(128),                     /* Created, Cloned in DB name */
 c_db_uname varchar2(128),              /* Created, Cloned in DB unique name */
 c_db_dbid  number,                               /* Created, Cloned in DBID */
 clonetag   varchar2(128),                                 /* Clone tag name */
 spare1     number,                                                 /* spare */
 spare2     number,                                                 /* spare */
 spare3     varchar2(128),                                          /* spare */
 spare4     varchar2(128)                                           /* spare */
)
/

create table cdb_service$
(
  name         varchar2(64),                                   /* short name */
  network_name varchar2(512),                                /* network name */
  name_hash    number,                                  /* service name hash */
  flags        number,                                              /* flags */
  con_id#      number,                                       /* container ID */
  sparen1      number,
  sparen2      number,
  sparevc1     varchar2(4000),
  sparevc2     varchar2(4000)
)
/

REM Table containing values of CONTAINER_DATA Attributes (both default and 
REM object-specific)
create table condata$
(
  user#  number not null,
  obj#   number not null, /* 0 represents a default CONTAINER_DATA attribute */
  con#   number not null                    /* 0 represents ALL (containers) */
)
/

CREATE UNIQUE INDEX i_condata1 ON condata$(user#, obj#, con#)
/

CREATE INDEX i_condata2 ON condata$(obj#)
/

CREATE INDEX i_condata3 ON condata$(con#)
/

create table adminauth$
(
  user#        number not null,                                   /* user id */
  syspriv      number not null,           /* Local administrative privileges */
  common       number not null           /* Common administrative privileges */
)
/


CREATE UNIQUE INDEX i_adminauth1 ON adminauth$(user#)
/

create table cdb_local_adminauth$
( con_uid       number not null,                          /* Container's UID */
  grantee$      varchar2(128) not null,                      /* grantee name */
  privileges    number not null,            /* privileges granted to grantee */
  passwd        varchar2(4000) not null)   /* List of "password hash" values */
/

create unique index i_cdb_local_adminauth_1 
  on cdb_local_adminauth$(con_uid, grantee$)
/

create table pdb_alert$
(
  cause#      number not null,
  type#       number not null,
  time        timestamp with time zone not null,         /* Time it happened */
  line#       number not null,
  /* reason why a plug in operation may not be performed */
  msg$        varchar2(4000) not null,
  /* name of a non-CDB or a PDB described by the specified XML file */
  name        varchar2(30) not null,
  /* if the specified XML file describes a PDB, UID of that PDB */
  con_uid     number,
  error#      number,
  status      number,                         /* status: pending or resolved */
  action      varchar2(4000),                              /* action to take */ 
  spare1      number,                                               /* spare */
  spare2      number,                                               /* spare */
  spare3      varchar2(30)                                          /* spare */
)
/

CREATE UNIQUE INDEX i_pdb_alert1 ON pdb_alert$(name, cause#, type#)
/

/* sequence for populating pdb_alert$.line# */
create sequence PDB_ALERT_SEQUENCE 
  increment by 1
  start with 1
  maxvalue 18446744073709551615 
  minvalue 1
  cycle 
  cache 10
  order
/

create table pdb_spfile$
(
  db_uniq_name    varchar2(30)    not null,     /* DB Unique Name of the CDB */
  pdb_uid         number          not null,                /* UID of the PDB */
  sid             varchar2(80)    not null,    /* sid for parameter setting, */
                                                          /* '*' if all sids */
  name            varchar2(80)    not null,         /* system parameter name */
  value$          varchar2(4000),                  /* system parameter value */
  comment$        varchar2(255),                 /* parameter update comment */
  spare1     number,                                                 /* spare */
  spare2     number,                                                 /* spare */
  spare3     varchar2(30)
)
/

create unique index i_pdb_spfile_1
  on pdb_spfile$(db_uniq_name, pdb_uid, sid, name)
/

create table pdbstate$
(
  inst_name   varchar2(128) not null,                       /* instance name */
  pdb_guid    RAW(16),                                           /* pdb guid */
  pdb_uid     number not null,                              /* pdb unique ID */
  state       number not null,                            /* last open state */
  restricted  number not null,                                 /* restricted */
  spare1      number,                                               /* spare */
  spare2      number                                                /* spare */
)
/

CREATE UNIQUE INDEX i_pdbstate1 ON pdbstate$(inst_name, pdb_guid)
/

Rem This table stores per-PDB stats for CDB views
create table cdbvw_stats$
( objname       varchar2(128) not null,                       /* object name */
  timestamp     date not null,                 /* stats collection timestamp */
  flags         number,  
  rowcnt        number,                                    /* number of rows */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date          
)
  segment creation immediate
  storage (maxextents unlimited)
/

create unique index i_cdbvw_stats$_objname on cdbvw_stats$(objname)
  storage (maxextents unlimited)
/

Rem *************************************************************************
Rem Consolidated Database changes - END
Rem *************************************************************************

Rem =======================================================================
Rem  Begin 12.1 Changes for Logminer
Rem =======================================================================

CREATE TABLE SYSTEM.LOGMNR_PDB_INFO$ (
                    LOGMNR_DID NUMBER NOT NULL,
                    LOGMNR_MDH NUMBER NOT NULL,      /* PDB Metadata Handle */
                    PDB_NAME VARCHAR2(128),
                    PDB_ID NUMBER,    /* Short/Reusable PDB Identifier/Slot */
                    PDB_UID NUMBER,           /* Long/Unique PDB Identifier */
                    PLUGIN_SCN NUMBER NOT NULL,
                    UNPLUG_SCN NUMBER,
                    FLAGS NUMBER,
                    SPARE1 NUMBER,
                    SPARE2 NUMBER,
                    SPARE3 VARCHAR2(4000),
                    SPARE4 TIMESTAMP,
                    PDB_GLOBAL_NAME VARCHAR2(128),
                    CONSTRAINT LOGMNR_PDB_INFO$_PK PRIMARY KEY 
                     (LOGMNR_DID, LOGMNR_MDH, PLUGIN_SCN)
                     USING INDEX TABLESPACE SYSAUX LOGGING)
                   TABLESPACE SYSAUX LOGGING
/
CREATE SEQUENCE system.logmnr_dids$ START WITH 1
       INCREMENT BY 1 NOMAXVALUE ORDER NOCACHE
/
CREATE TABLE SYSTEM.LOGMNR_DID$ (
                    SESSION# NUMBER CONSTRAINT LOGMNR_DID$_PK PRIMARY KEY,
                    LOGMNR_DID NUMBER,
                    FLAGS NUMBER,
                    SPARE1 NUMBER,
                    SPARE2 NUMBER,
                    SPARE3 VARCHAR2(4000),
                    SPARE4 TIMESTAMP) TABLESPACE SYSAUX LOGGING
/
ALTER TABLE SYSTEM.LOGMNR_UID$ DROP PRIMARY KEY
/
ALTER TABLE SYSTEM.LOGMNR_UID$ RENAME COLUMN SESSION# TO LOGMNR_DID
/
ALTER TABLE SYSTEM.LOGMNR_UID$ ADD (
                    LOGMNR_MDH NUMBER,
                    PDB_NAME VARCHAR(30),
                    PDB_ID NUMBER,
                    PDB_UID NUMBER,
                    START_SCN NUMBER,
                    END_SCN NUMBER,
                    FLAGS NUMBER,
                    SPARE1 NUMBER,
                    SPARE2 NUMBER,
                    SPARE3 VARCHAR2(4000),
                    SPARE4 TIMESTAMP)
/
declare
  n number;
begin
  select count(1) into n from system.logmnr_uid$;
  if (n != 0) then
    select count(1) into n from system.logmnr_did$;
    if (n = 0) then
      /* copy all data from logmnr_uid$ into logmnr_did$ */
      /*   set session# column based on old renamed session# column */
      /*   set logmnr_did column to old UID value temporarily */
      insert into system.logmnr_did$ (session#, logmnr_did)
        select u.logmnr_did, u.logmnr_uid
          from system.logmnr_uid$ u;

      /* Clean out logmnr_uid$ */
      delete from system.logmnr_uid$;

      /* populate logmnr_uid table from list of uids saved above */
      /* mdh is defaulted to 1 for non-consolidated and pdb_id */
      /* and start_scn get 0 */
      insert into system.logmnr_uid$
        (logmnr_uid, logmnr_did, logmnr_mdh, pdb_id, start_scn)
        select x.logmnr_did, system.logmnr_dids$.nextval new_did, 1, 0, 0
           from (select distinct d.logmnr_did /* uid is in did column */
                   from system.logmnr_did$ d
                   order by d.logmnr_did ) x;

      /* now overwrite the UIDs that were temporarily stored in logmnr_did$ */
      /* with the actual DIDs we just generated */
      update system.logmnr_did$ d
         set d.logmnr_did = (select u.logmnr_did
                               from system.logmnr_uid$ u
                              where u.logmnr_uid = d.logmnr_did);

      /* populate logmnr_pdb_info with defaults */
      insert into system.logmnr_pdb_info$ 
          (logmnr_did, logmnr_mdh, pdb_id, plugin_scn)
        select distinct d.logmnr_did, 1, 0, 0
          from system.logmnr_did$ d
          where d.logmnr_did not in (select logmnr_did
                                     from system.logmnr_pdb_info$);
      commit;
    end if;
  end if;
exception when others then
  rollback;
  raise;
end;
/
ALTER TABLE SYSTEM.LOGMNR_UID$ ADD CONSTRAINT LOGMNR_UID$_PK 
            PRIMARY KEY (LOGMNR_UID) USING INDEX TABLESPACE SYSAUX LOGGING
/

update system.logmnr_uid$
  set flags = 0
  where flags is NULL;
commit;

update system.logmnr_pdb_info$
set flags = 0
where flags is NULL;
commit;

update system.logmnr_uid$
set pdb_uid = 0
where pdb_uid is NULL;
commit;

update system.logmnr_pdb_info$
set pdb_uid = 0
where pdb_uid is NULL;
commit;

ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP ADD (PDB_NAME VARCHAR2(128))
/
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP ADD (LOGMNR_MDH NUMBER) 
/
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP DROP PRIMARY KEY
/
UPDATE SYSTEM.LOGMNRC_DBNAME_UID_MAP 
   SET LOGMNR_MDH = 1
   WHERE LOGMNR_MDH IS NULL;

COMMIT;

ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP MODIFY (LOGMNR_MDH NUMBER NOT NULL)
/
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP
      ADD CONSTRAINT LOGMNRC_DBNAME_UID_MAP_PK
                     PRIMARY KEY(GLOBAL_NAME, LOGMNR_MDH) 
                     USING INDEX TABLESPACE SYSAUX LOGGING
/

/* We would like to keep the last column in place.  Since the table
 * is always empty it is ok to just drop and recreate it.
 */
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
      PDB_NAME VARCHAR(30),
      PDB_ID NUMBER,
      PDB_UID NUMBER,
      PDB_DBID NUMBER,
      PDB_GUID RAW(16),
      PDB_CREATE_SCN NUMBER,
      PDB_COUNT NUMBER,
      PDB_GLOBAL_NAME VARCHAR2(128),
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL  ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_NAME VARCHAR(30));
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_ID NUMBER);
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_UID NUMBER);
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_DBID NUMBER);
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_GUID RAW(16));
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_CREATE_SCN NUMBER);
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_COUNT NUMBER);
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ ADD (PDB_GLOBAL_NAME VARCHAR2(128));

CREATE TABLE SYS.LOGMNRG_CON$ (
     OWNER#        NUMBER NOT NULL,
     NAME          VARCHAR2(128) NOT NULL,
     CON#          NUMBER NOT NULL )
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

CREATE TABLE SYS.LOGMNRG_CONTAINER$ (
     obj#          number not null,      /* Object number for the container */
     con_id#       number not null,                         /* container ID */
     dbid          number not null,                          /* database ID */
     con_uid       number not null,                            /* unique ID */
     flags         number,                                         /* flags */
     status        number not null,                    /* active, plugged...*/
     create_scnwrp number not null,                    /* creation scn wrap */
     create_scnbas number not null)                    /* creation scn base */
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

Rem Column order is critical for LOGMNRG tables and they are always
Rem empty so we drop and recreate for any add/drop column.

DROP TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG;
CREATE TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG (
       BUILD_DATE VARCHAR2(20),
       DB_TXN_SCNBAS NUMBER,
       DB_TXN_SCNWRP NUMBER,
       CURRENT_BUILD_STATE NUMBER,
       COMPLETION_STATUS NUMBER,
       MARKED_LOG_FILE_LOW_SCN NUMBER,
       CDB_XID VARCHAR2(22),
       SPARE1 NUMBER,
       SPARE2 VARCHAR2(4000),
       INITIAL_XID VARCHAR2(22) NOT NULL ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

ALTER TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG ADD (CDB_XID VARCHAR2(22));
ALTER TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG ADD (SPARE1 NUMBER);
ALTER TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG ADD (SPARE2 VARCHAR2(4000));

ALTER TABLE SYS.LOGMNR_BUILDLOG ADD (CDB_XID VARCHAR2(22));
ALTER TABLE SYS.LOGMNR_BUILDLOG ADD (SPARE1 NUMBER);
ALTER TABLE SYS.LOGMNR_BUILDLOG ADD (SPARE2 VARCHAR2(4000));

drop view v_$logmnr_region;
drop public synonym v$logmnr_region;

drop view gv_$logmnr_region;
drop public synonym gv$logmnr_region;

drop view v_$logmnr_callback;
drop public synonym v$logmnr_callback;

drop view gv_$logmnr_callback;
drop public synonym gv$logmnr_callback;

-- Add LogmnrDerivedFlags to gtcs related tables and views
alter table system.logmnrc_gtcs add (LogmnrDerivedFlags NUMBER);

alter table system.logmnrggc_gtcs add (logmnrDerivedFlags NUMBER);

-- Add columns for EM support tables
alter table system.logmnr_gt_tab_include$ add (pdb_name varchar2(130));
alter table system.logmnr_gt_tab_include$ add (spare1 number);
alter table system.logmnr_gt_tab_include$ add (spare2 number);
alter table system.logmnr_gt_tab_include$ add (spare3 varchar2(4000));

alter table system.logmnr_gt_user_include$ add (pdb_name varchar2(130));
alter table system.logmnr_gt_user_include$ add (spare1 number);
alter table system.logmnr_gt_user_include$ add (spare2 number);
alter table system.logmnr_gt_user_include$ add (spare3 varchar2(4000));

alter table system.logmnr_gt_xid_include$ add (spare1 number);
alter table system.logmnr_gt_xid_include$ add (spare2 number);
alter table system.logmnr_gt_xid_include$ add (spare3 varchar2(4000));

Rem =======================================================================
Rem  End 12.1 Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.1 Changes for Logical Standby
Rem =======================================================================

alter table system.logstdby$apply_milestone add (flags number default 0);

drop table system.logstdby$skip_support;

Rem If MAX_SGA is set it must be at least 50.
update system.logstdby$parameters
 set value = '50'
 where upper(name) = 'MAX_SGA'
   and value is not null
   and to_number(value, '999999999999') < 50;

commit;

ALTER TABLE system.logstdby$events ADD (con_name VARCHAR2(30));

Rem =======================================================================
Rem  End 12.1 Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for 12g Online Redefinition Enhancements(32728)
Rem =======================================================================
alter table sys.redef_dep_error$ add (err_no INTEGER);
alter table sys.redef_dep_error$ add (err_txt VARCHAR2(1000));

create table redef_status$(
   redef_id       INTEGER             not null,           /* redefinition id */
   prev_operation VARCHAR2(128)       not null,           /* the previous op */
   obj_owner      VARCHAR2(128)       not null,  /* owner of redefined table */ 
   obj_name       VARCHAR2(128)       not null,         /* name of partition */ 
   status         VARCHAR2(128)       not null,     /* status of previous Op */
   restartable    VARCHAR2(1)         not null   /* can restart previous op? */
)
/
create index i_redef_status$ on
             redef_status$(redef_id)
/
Rem =======================================================================
Rem  End Changes for 12g Online Redefinition Enhancements(32728)
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Static ACL Refresh using Materialized Views
Rem =======================================================================
create table aclmv$                  /* the acl mvs used by fusion security */
( table_obj#       number,           /* object# of table */
  acl_mview_obj#   number,           /* object# of mview */
  refresh_mode     number,           /* ON COMMIT, SCHEDULED or ON DEMAND */
  job_name         varchar2(128),    /* the job-name if SCHEDULED */
  trace_level      number            /* the tracing-level, default 0 => off */
)
/
create unique index i_aclmv$_1 on aclmv$(table_obj#)
/

create table aclmvsubtbl$
( acl_mview_obj#  number,            /* foreign key to aclmv$ table */ 
  subtable_obj#   number             /* object number of a subtable */
)
/
create index i_aclmvsubtbl$_1 on aclmvsubtbl$(acl_mview_obj#)
/

create table aclmvrefstat$                    /* the acl mvs refresh status */
( acl_mview_obj#      number,           /* object# of table */
  job_start_time       timestamp with time zone,      
  job_end_time         timestamp with time zone,      
  total_inserts        number,
  total_deletes        number,
  total_updates        number,
  row_update_count     number,
  status               number,
  error_message        varchar2(4000)
)
/
create index i_aclmvrefstat$_1 on aclmvrefstat$(acl_mview_obj#)
/

create table aclmv$_reflog(rtime timestamp,
                           schema_name varchar2(32),
                           table_name  varchar2(32),
                           mview_name  varchar2(32),
                           job_name    varchar2(32),
                           acl_status  varchar2(32),
                           status      number,
                           errmsg      varchar2(256));


Rem =======================================================================
Rem  End Changes for Static ACL Refresh using Materialized Views
Rem =======================================================================

Rem *************************************************************************
Rem Separation of Duty project (5687) changes - BEGIN
Rem *************************************************************************

-- Create administrative users.
create user sysbackup identified by "D_SYSBKPW" account lock password expire;
create user sysdg identified by "D_SYSDGPW" account lock password expire;
create user syskm identified by "D_SYSKMPW" account lock password expire;

Rem
Rem Errors trapped are the following:
Rem ORA-04042 - Does not exists
Rem ORA-01927 - Cannot Revoke Priv you did not grant
Rem ORA-00942 - Table of view does not exits
Rem ORA-04045 - Errors during recomp
Rem
BEGIN
  EXECUTE IMMEDIATE 'revoke inherit privileges on user sysbackup from public';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke inherit privileges on user sysdg from public';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke inherit privileges on user syskm from public';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Update metadata for new administrative privileges.
BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-340, 'SYSBACKUP', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-341, 'SYSDG', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-342, 'SYSKM', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (340, 'SYSBACKUP', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (341, 'SYSDG', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (342, 'SYSKM', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

-- Update metadate for the PURGE DBA_RECYCLEBIN system privilege.
BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-347, 'PURGE DBA_RECYCLEBIN', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (347, 'PURGE DBA_RECYCLEBIN', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem Separation of Duty project (5687) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking) changes - BEGIN
Rem (Project 32006)
Rem These changes are for upgrade from 11.2 to 12.1, to add RADM dict table.
Rem
Rem  Create the RADM dictionary tables radm$ and radm_fptm$.
Rem  Note: creation of the radm_mc$ table has been moved to i1102000.sql.
Rem  insert the new EXEMPT REDACTION POLICY system privilege.
Rem  Insert the new EXEMPT DML REDACTION POLICY system privilege.
Rem  Insert the new EXEMPT DDL REDACTION POLICY system privilege.
Rem *************************************************************************

create table radm$ /* Real-time Application-controlled Data Masking policies */
( 
  obj#        NUMBER NOT NULL,                        /* table object number */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  pexpr       VARCHAR2(4000) NOT NULL,             /* RADM Policy Expression */
  enable_flag NUMBER NOT NULL     /* Policy State: 0 = disabled, 1 = enabled */
) 
/ 
create index i_radm1 on radm$(obj#)
/
create index i_radm2 on radm$(obj#, pname)
/

create table radm_fptm$ /* RADM Fixed PoinT Masking values */
(
  numbercol    NUMBER NOT NULL,
  binfloatcol  BINARY_FLOAT NOT NULL,
  bindoublecol BINARY_DOUBLE NOT NULL,
  charcol      CHAR(1),
  varcharcol   VARCHAR2(1),
  ncharcol     NCHAR(1),
  nvarcharcol  NVARCHAR2(1),
  datecol      DATE NOT NULL,
  ts_col       TIMESTAMP NOT NULL,
  tswtz_col    TIMESTAMP WITH TIME ZONE NOT NULL,
  fpver        NUMBER NOT NULL
)
/
create unique index i_radm_fptm on radm_fptm$(fpver)
/

BEGIN
  insert into radm_fptm$ values 
  (
    0,
    0,
    0,
    ' ',
    ' ',
    N' ',
    N' ',
    TO_DATE('01-JAN-01','DD-MON-YY','NLS_DATE_LANGUAGE = AMERICAN'),
    TO_TIMESTAMP('01-JAN-2001 01.00.00.000000AM','DD-MON-YYYY HH.MI.SS.FF6AM','NLS_DATE_LANGUAGE = AMERICAN'),
    TO_TIMESTAMP_TZ('01-JAN-2001 01.00.00.000000AM +00:00','DD-MON-YYYY HH.MI.SS.FF6AM TZH:TZM','NLS_DATE_LANGUAGE = AMERICAN'),
    1
  );  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

create table radm_fptm_lob$ /* RADM Fixed PoinT Masking values for LOBs*/
(
  blobcol      BLOB,
  clobcol      CLOB,
  nclobcol     NCLOB,
  fpver        NUMBER NOT NULL
)
tablespace SYSAUX
/

create unique index i_radm_fptm_lob on radm_fptm_lob$(fpver)
tablespace SYSAUX
/

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version
    INTO previous_version
    FROM registry$
   WHERE cid = 'CATPROC';

  -- Bug #14712865: If upgrading from 11.2.0.4, don't insert 
  -- the initial row into radm_fptm_lob$, as that was already done
  -- during the 11.2.0.4 installation.
  -- Also, we keep any existing fpver=1 row, so that we preserve
  -- away any customizations which might have been made to
  -- the FULL redaction values for LOB while running 11.2.0.4.

  IF (substr(previous_version, 1, 8) = '11.2.0.4') THEN
    insert into radm_fptm_lob$ values
    (
      NULL,
      NULL,
      NULL,
      0
    );
  END IF;
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

create table radm_td$
(
  obj#        NUMBER NOT NULL,             /* object number of table or view */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  pdesc       VARCHAR2(4000)                      /* RADM policy description */
)
/
create index i_radm_td1 on radm_td$(obj#)
/
create index i_radm_td2 on radm_td$(obj#, pname)
/
create table radm_cd$
(
  obj#        NUMBER NOT NULL,             /* object number of table or view */
  intcol#     NUMBER NOT NULL,                              /* column number */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  cdesc       VARCHAR2(4000)         /* column level RADM policy description */
)
/
create index i_radm_cd1 on radm_cd$(obj#)
/
create index i_radm_cd2 on radm_cd$(obj#, intcol#)
/
create index i_radm_cd3 on radm_cd$(obj#, intcol#, pname)
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-351, 'EXEMPT REDACTION POLICY', 0);  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN 
  insert into SYSTEM_PRIVILEGE_MAP values (-391, 'EXEMPT DML REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-392, 'EXEMPT DDL REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (351, 'EXEMPT REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (391, 'EXEMPT DML REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (392, 'EXEMPT DDL REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Oracle Data Mining changes - BEGIN
Rem *************************************************************************

drop type dm_glm_coeff force;
drop type dm_glm_coeff_set force;

-- move odm metadata to SYSTEM tablespace
alter table model$ move tablespace system;
alter table modelset$ move tablespace system;
alter table modelatt$ move tablespace system;
alter table modeltab$ move tablespace system;
alter index model$idx rebuild tablespace system;
alter index modelset$idx rebuild tablespace system;
alter index modelatt$idx rebuild tablespace system;
alter index modeltab$idx rebuild tablespace system;

-- drop abn and jdm objects (desupported)
drop package odm_abn_model;
drop package dbms_jdm_internal;
drop type dm_abn_details force;
drop type dm_abn_detail force; 

-- drop unused packages
drop package DBMS_DM_UTIL_INTERNAL;
drop package dbms_dm_imp_internal;

DROP TYPE JDM_STR_VALS FORCE;
DROP TYPE JDM_ATTR_NAMES FORCE;
DROP TYPE JDM_NUM_VALS FORCE;

drop public synonym odm_abn_model;
drop public synonym dm_abn_details;
drop public synonym dm_abn_detail; 

DROP PROCEDURE JDM_PROFILE_PROGRAM;
DROP PROCEDURE JDM_EXPORT_PROGRAM;
DROP PROCEDURE JDM_IMPORT_PROGRAM;
DROP PROCEDURE JDM_EXPLAIN_PROGRAM;
DROP PROCEDURE JDM_BUILD_PROGRAM;
DROP PROCEDURE JDM_PREDICT_PROGRAM;
DROP PROCEDURE JDM_XFORM_SEQ_PROGRAM;
DROP PROCEDURE JDM_XFORM_PROGRAM;
DROP PROCEDURE JDM_PROFILE_PROGRAM;
DROP PROCEDURE JDM_SQL_APPLY_PROGRAM;
DROP PROCEDURE JDM_TEST_PROGRAM;

delete from STMT_AUDIT_OPTION_MAP where NAME = 'SELECT MINING MODEL';
insert into STMT_AUDIT_OPTION_MAP values (299, 'SELECT MINING MODEL', 0);
commit;

Rem *************************************************************************
Rem Oracle Data Mining changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem EDS For Logical Standby Changes - BEGIN
Rem *************************************************************************

alter table system.logstdby$eds_tables add (mview_name varchar2(30));
alter table system.logstdby$eds_tables add (mview_log_name varchar2(30));
alter table system.logstdby$eds_tables add (mview_trigger_name varchar2(30));

Rem *************************************************************************
Rem EDS For Logical Standby Changes - END
Rem *************************************************************************

Rem =======================================================================
Rem Begin changes For Database Services
Rem =======================================================================

alter table service$ add (retention_timeout number);
alter table service$ add (replay_initiation_timeout number);
alter table service$ add (session_state_consistency varchar2(30));
alter table service$ add (sql_translation_profile varchar2(30));
alter table service$ add (max_lag_time varchar2(30));
alter table service$ add (gsm_flags number);
alter table service$ add (pq_svc varchar2(64));

create type parameter_t is object (param_name varchar2(30),
                                   param_value varchar2(100));
/

create type parameter_list_t is varray(30) of parameter_t;
/

Rem =======================================================================
Rem End changes For Database Services
Rem =======================================================================

Rem =======================================================================
Rem Server Generated Alerts  Changes for 12g
Rem =======================================================================

truncate table wri$_alert_outstanding
/
alter table wri$_alert_outstanding
   modify (owner                    VARCHAR2(128),
           subobject_name           VARCHAR2(128),
           action_argument_1        VARCHAR2(128),
           action_argument_2        VARCHAR2(128),
           action_argument_3        VARCHAR2(128),
           action_argument_4        VARCHAR2(128),
           action_argument_5        VARCHAR2(128),
           user_id                  VARCHAR2(128))
/

alter table wri$_alert_outstanding
    add (state_transition_number  NUMBER,
         pdb_name                 VARCHAR2(128),
         con_id                   NUMBER NOT NULL)
/
alter table wri$_alert_outstanding drop primary key
/
alter table wri$_alert_outstanding add constraint wri$_alert_outstanding_pk
 PRIMARY KEY (con_id,
              reason_id,
              object_id,
              subobject_id,
              internal_instance_number)
        USING INDEX TABLESPACE sysaux
/

alter table wri$_alert_history
    add (state_transition_number  NUMBER DEFAULT 0,
         pdb_name                 VARCHAR2(128),
         con_id                   NUMBER)
/
alter table wri$_alert_history drop primary key
/
alter table wri$_alert_history add constraint wri$_alert_history_pk
  PRIMARY KEY (sequence_id, state_transition_number)
        USING INDEX TABLESPACE sysaux
/

alter session set events '10851 level 1';
alter type sys.alert_type
      add attribute pdb_name varchar2(128)  cascade;

-- Turn OFF the event to disable DDL on AQ tables
alter session set events '10851 off';

alter table WRI$_TRACING_ENABLED modify (qualifier_id1 VARCHAR2(64));
alter table WRI$_TRACING_ENABLED modify (qualifier_id2 VARCHAR2(64));

Rem =======================================================================
Rem End Server Generated Alerts  Changes for 12g
Rem =======================================================================

Rem =======================================================================
Rem AWR Changes for 12g
Rem =======================================================================

-- Turn ON the event to disable the partition check
-- Needed for upgrade of AWR tables
alter session set events  '14524 trace name context forever, level 1';

alter type AWR_OBJECT_INFO_TYPE add attribute (
             partition_type    VARCHAR2(64)
           , index_type        VARCHAR2(64)
           , base_object_name  VARCHAR2(128)
           , base_object_owner VARCHAR2(128)
           , base_object_id    NUMBER
) cascade
/

alter type AWR_OBJECT_INFO_TYPE modify attribute (
            owner_name        VARCHAR2(128)
) cascade
/

Rem ***********************************************
Rem Upgrade WRH$_SQLSTAT
Rem ***********************************************
alter table WRH$_SQLSTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQLSTAT drop primary key drop index
/
create unique index WRH$_SQLSTAT_PK on WRH$_SQLSTAT
  (dbid, snap_id, instance_number, sql_id, plan_hash_value, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SQLSTAT
 add constraint WRH$_SQLSTAT_PK primary key
  (dbid, snap_id, instance_number, sql_id, plan_hash_value, con_dbid)
 using index WRH$_SQLSTAT_PK
/
alter index WRH$_SQLSTAT_PK noparallel
/
drop index WRH$_SQLSTAT_INDEX
/
create index WRH$_SQLSTAT_INDEX on WRH$_SQLSTAT (sql_id, dbid, con_dbid)
 local nologging parallel tablespace sysaux
/
alter index WRH$_SQLSTAT_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SQLSTAT_BL
Rem ***********************************************
alter table WRH$_SQLSTAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQLSTAT_BL drop primary key drop index
/
alter table WRH$_SQLSTAT_BL
 add constraint WRH$_SQLSTAT_BL_PK primary key
  (dbid, snap_id, instance_number, sql_id, plan_hash_value, con_dbid)
 using index tablespace SYSAUX
/

drop index WRH$_SQLSTAT_BL_INDEX
/

Rem ***********************************************
Rem Upgrade WRH$_SQLTEXT
Rem ***********************************************
alter table WRH$_SQLTEXT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQLTEXT drop primary key drop index
/
create unique index WRH$_SQLTEXT_PK on WRH$_SQLTEXT (dbid, sql_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SQLTEXT
 add constraint WRH$_SQLTEXT_PK primary key (dbid, sql_id, con_dbid)
 using index WRH$_SQLTEXT_PK
/
alter index WRH$_SQLTEXT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SQL_PLAN
Rem ***********************************************
alter table WRH$_SQL_PLAN add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQL_PLAN drop primary key drop index
/
create unique index WRH$_SQL_PLAN_PK on WRH$_SQL_PLAN
  (dbid, sql_id, plan_hash_value, id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SQL_PLAN
 add constraint WRH$_SQL_PLAN_PK primary key
  (dbid, sql_id, plan_hash_value, id, con_dbid)
 using index WRH$_SQL_PLAN_PK
/
alter index WRH$_SQL_PLAN_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SEG_STAT
Rem ***********************************************
alter table WRH$_SEG_STAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SEG_STAT drop primary key drop index
/
create unique index WRH$_SEG_STAT_PK on WRH$_SEG_STAT
  (dbid, snap_id, instance_number, ts#, obj#, dataobj#, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SEG_STAT
 add constraint WRH$_SEG_STAT_PK primary key
  (dbid, snap_id, instance_number, ts#, obj#, dataobj#, con_dbid)
 using index WRH$_SEG_STAT_PK
/
alter index WRH$_SEG_STAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SEG_STAT_BL
Rem ***********************************************
alter table WRH$_SEG_STAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SEG_STAT_BL drop primary key drop index
/
alter table WRH$_SEG_STAT_BL
 add constraint WRH$_SEG_STAT_BL_PK primary key
  (dbid, snap_id, instance_number, ts#, obj#, dataobj#, con_dbid)
 using index tablespace SYSAUX
/
Rem ***********************************************
Rem Upgrade WRH$_SEG_STAT_OBJ
Rem ***********************************************
alter table WRH$_SEG_STAT_OBJ
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SEG_STAT_OBJ drop primary key drop index
/
create unique index WRH$_SEG_STAT_OBJ_PK on WRH$_SEG_STAT_OBJ
  (dbid, ts#, obj#, dataobj#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SEG_STAT_OBJ
 add constraint WRH$_SEG_STAT_OBJ_PK primary key
  (dbid, ts#, obj#, dataobj#, con_dbid)
 using index WRH$_SEG_STAT_OBJ_PK
/
alter index WRH$_SEG_STAT_OBJ_PK noparallel
/
drop index WRH$_SEG_STAT_OBJ_INDEX
/
create index WRH$_SEG_STAT_OBJ_INDEX on WRH$_SEG_STAT_OBJ
  (dbid, snap_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_SEG_STAT_OBJ_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_TABLESPACE_STAT
Rem ***********************************************
alter table WRH$_TABLESPACE_STAT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TABLESPACE_STAT drop primary key drop index
/
create unique index WRH$_TABLESPACE_STAT_PK on WRH$_TABLESPACE_STAT
  (dbid, snap_id, instance_number, ts#, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_TABLESPACE_STAT
 add constraint WRH$_TABLESPACE_STAT_PK primary key
  (dbid, snap_id, instance_number, ts#, con_dbid)
 using index WRH$_TABLESPACE_STAT_PK
/
alter index WRH$_TABLESPACE_STAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_TABLESPACE_STAT_BL
Rem ***********************************************
alter table WRH$_TABLESPACE_STAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TABLESPACE_STAT_BL drop primary key drop index
/
alter table WRH$_TABLESPACE_STAT_BL
 add constraint WRH$_TABLESPACE_STAT_BL_PK primary key
  (dbid, snap_id, instance_number, ts#, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_TABLESPACE
Rem ***********************************************
alter table WRH$_TABLESPACE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TABLESPACE add (block_size number)
/
alter table WRH$_TABLESPACE drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_TABLESPACE_PK on WRH$_TABLESPACE
    (dbid, ts#, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_TABLESPACE
 add constraint WRH$_TABLESPACE_PK primary key
  (dbid, ts#, con_dbid)
 using index WRH$_TABLESPACE_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_TABLESPACE_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_TABLESPACE_SPACE_USAGE
Rem ***********************************************
alter table WRH$_TABLESPACE_SPACE_USAGE
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_TS_SPACE_USAGE_IND
/
Rem ========================================================
Rem create an index on the WRH$_TABLESPACE_SPACE_USAGE table
Rem ========================================================
create index WRH$_TS_SPACE_USAGE_IND on WRH$_TABLESPACE_SPACE_USAGE
  (dbid, snap_id, tablespace_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_TS_SPACE_USAGE_IND noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_FILESTATXS
Rem ***********************************************
alter table WRH$_FILESTATXS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_FILESTATXS add (optimized_phyblkrd number)
/
alter table WRH$_FILESTATXS drop primary key drop index
/
create unique index WRH$_FILESTATXS_PK on WRH$_FILESTATXS
  (dbid, snap_id, instance_number, file#, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_FILESTATXS
 add constraint WRH$_FILESTATXS_PK primary key
  (dbid, snap_id, instance_number, file#, con_dbid)
 using index WRH$_FILESTATXS_PK
/
alter index WRH$_FILESTATXS_PK noparallel
/
Rem ***********************************************
Rem Upgrade WRH$_FILESTATXS_BL
Rem ***********************************************
alter table WRH$_FILESTATXS_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_FILESTATXS_BL add (optimized_phyblkrd number)
/
alter table WRH$_FILESTATXS_BL drop primary key drop index
/
alter table  WRH$_FILESTATXS_BL
 add constraint WRH$_FILESTATXS_BL_PK primary key
  (dbid, snap_id, instance_number, file#, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_TEMPSTATXS
Rem ***********************************************
alter table WRH$_TEMPSTATXS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TEMPSTATXS drop primary key drop index
/
create unique index WRH$_TEMPSTATXS_PK on WRH$_TEMPSTATXS
  (dbid, snap_id, instance_number, file#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_TEMPSTATXS
 add constraint WRH$_TEMPSTATXS_PK primary key
  (dbid, snap_id, instance_number, file#, con_dbid)
 using index WRH$_TEMPSTATXS_PK
/
alter index WRH$_TEMPSTATXS_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_DATAFILE
Rem ***********************************************
alter table WRH$_DATAFILE add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DATAFILE drop primary key drop index
/
create unique index WRH$_DATAFILE_PK on WRH$_DATAFILE
  (dbid, file#, creation_change#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_DATAFILE
 add constraint WRH$_DATAFILE_PK primary key
  (dbid, file#, creation_change#, con_dbid)
 using index WRH$_DATAFILE_PK
/
alter index WRH$_DATAFILE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_TEMPFILE
Rem ***********************************************
alter table WRH$_TEMPFILE add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TEMPFILE drop primary key drop index
/
create unique index WRH$_TEMPFILE_PK on WRH$_TEMPFILE
  (dbid, file#, creation_change#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_TEMPFILE
 add constraint WRH$_TEMPFILE_PK primary key
  (dbid, file#, creation_change#, con_dbid)
 using index WRH$_TEMPFILE_PK
/
alter index WRH$_TEMPFILE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SQL_BIND_METADATA
Rem ***********************************************
alter table WRH$_SQL_BIND_METADATA
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQL_BIND_METADATA drop primary key drop index
/
create unique index WRH$_SQL_BIND_METADATA_PK on WRH$_SQL_BIND_METADATA
  (dbid, sql_id, position, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SQL_BIND_METADATA
 add constraint WRH$_SQL_BIND_METADATA_PK primary key
  (dbid, sql_id, position, con_dbid)
 using index WRH$_SQL_BIND_METADATA_PK
/
alter index WRH$_SQL_BIND_METADATA_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRI$_SQLTEXT_REFCOUNT
Rem ***********************************************
alter table WRI$_SQLTEXT_REFCOUNT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRI$_SQLTEXT_REFCOUNT drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRI$_SQLTEXT_REFCOUNT_PK on WRI$_SQLTEXT_REFCOUNT
    (dbid, sql_id, con_dbid)
   nologging parallel
   tablespace SYSAUX';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRI$_SQLTEXT_REFCOUNT
 add constraint WRI$_SQLTEXT_REFCOUNT_PK primary key
  (dbid, sql_id, con_dbid)
 using index WRI$_SQLTEXT_REFCOUNT_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRI$_SQLTEXT_REFCOUNT_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_COMP_IOSTAT
Rem ***********************************************
alter table WRH$_COMP_IOSTAT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_COMP_IOSTAT drop primary key drop index
/
create unique index WRH$_COMP_IOSTAT_PK on WRH$_COMP_IOSTAT
  (dbid, snap_id, instance_number,
   component, file_type, io_type, operation, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_COMP_IOSTAT
 add constraint WRH$_COMP_IOSTAT_PK primary key
  (dbid, snap_id, instance_number,
   component, file_type, io_type, operation, con_dbid)
 using index WRH$_COMP_IOSTAT_PK
/
alter index WRH$_COMP_IOSTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_IOSTAT_FUNCTION
Rem ***********************************************
alter table WRH$_IOSTAT_FUNCTION
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IOSTAT_FUNCTION drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IOSTAT_FUNCTION_PK on WRH$_IOSTAT_FUNCTION
    (dbid, snap_id, instance_number, function_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IOSTAT_FUNCTION
 add constraint WRH$_IOSTAT_FUNCTION_PK primary key
  (dbid, snap_id, instance_number, function_id, con_dbid)
 using index WRH$_IOSTAT_FUNCTION_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IOSTAT_FUNCTION_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IOSTAT_DETAIL
Rem ***********************************************
alter table WRH$_IOSTAT_DETAIL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IOSTAT_DETAIL drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IOSTAT_DETAIL_PK on WRH$_IOSTAT_DETAIL
    (dbid, snap_id, instance_number, function_id, filetype_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IOSTAT_DETAIL
 add constraint WRH$_IOSTAT_DETAIL_PK primary key
  (dbid, snap_id, instance_number, function_id, filetype_id, con_dbid)
 using index WRH$_IOSTAT_DETAIL_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IOSTAT_DETAIL_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IOSTAT_FILETYPE
Rem ***********************************************
alter table WRH$_IOSTAT_FILETYPE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IOSTAT_FILETYPE drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IOSTAT_FILETYPE_PK on WRH$_IOSTAT_FILETYPE
    (dbid, snap_id, instance_number, filetype_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IOSTAT_FILETYPE
 add constraint WRH$_IOSTAT_FILETYPE_PK primary key
  (dbid, snap_id, instance_number, filetype_id, con_dbid)
 using index WRH$_IOSTAT_FILETYPE_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IOSTAT_FILETYPE_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_SQL_SUMMARY
Rem ***********************************************
alter table WRH$_SQL_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQL_SUMMARY drop primary key drop index
/
create unique index WRH$_SQL_SUMMARY_PK on WRH$_SQL_SUMMARY
  (dbid, snap_id, instance_number, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SQL_SUMMARY
 add constraint WRH$_SQL_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_SQL_SUMMARY_PK
/
alter index WRH$_SQL_SUMMARY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_OPTIMIZER_ENV
Rem ***********************************************
alter table WRH$_OPTIMIZER_ENV
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_OPTIMIZER_ENV drop primary key drop index
/
create unique index WRH$_OPTIMIZER_ENV_PK on WRH$_OPTIMIZER_ENV
  (dbid, optimizer_env_hash_value, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_OPTIMIZER_ENV
 add constraint WRH$_OPTIMIZER_ENV_PK primary key
  (dbid, optimizer_env_hash_value, con_dbid)
 using index WRH$_OPTIMIZER_ENV_PK
/
alter index WRH$_OPTIMIZER_ENV_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSTEM_EVENT
Rem ***********************************************
alter table WRH$_SYSTEM_EVENT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYSTEM_EVENT drop primary key drop index
/
create unique index WRH$_SYSTEM_EVENT_PK on WRH$_SYSTEM_EVENT
  (dbid, snap_id, instance_number, event_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SYSTEM_EVENT
 add constraint WRH$_SYSTEM_EVENT_PK primary key
  (dbid, snap_id, instance_number, event_id, con_dbid)
 using index WRH$_SYSTEM_EVENT_PK
/
alter index WRH$_SYSTEM_EVENT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSTEM_EVENT_BL
Rem ***********************************************
alter table WRH$_SYSTEM_EVENT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYSTEM_EVENT_BL drop primary key drop index
/
alter table WRH$_SYSTEM_EVENT_BL
 add constraint WRH$_SYSTEM_EVENT_BL_PK primary key
  (dbid, snap_id, instance_number, event_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_BG_EVENT_SUMMARY
Rem ***********************************************
alter table WRH$_BG_EVENT_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_BG_EVENT_SUMMARY drop primary key drop index
/
create unique index WRH$_BG_EVENT_SUMMARY_PK on WRH$_BG_EVENT_SUMMARY
  (dbid, snap_id, instance_number, event_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_BG_EVENT_SUMMARY
 add constraint WRH$_BG_EVENT_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, event_id, con_dbid)
 using index WRH$_BG_EVENT_SUMMARY_PK
/
alter index WRH$_BG_EVENT_SUMMARY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_WAITSTAT
Rem ***********************************************
alter table WRH$_WAITSTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_WAITSTAT drop primary key drop index
/
create unique index WRH$_WAITSTAT_PK on WRH$_WAITSTAT
  (dbid, snap_id, instance_number, class, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_WAITSTAT
 add constraint WRH$_WAITSTAT_PK primary key
  (dbid, snap_id, instance_number, class, con_dbid)
 using index WRH$_WAITSTAT_PK
/
alter index WRH$_WAITSTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_WAITSTAT_BL
Rem ***********************************************
alter table WRH$_WAITSTAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_WAITSTAT_BL drop primary key drop index
/
alter table WRH$_WAITSTAT_BL
 add constraint WRH$_WAITSTAT_BL_PK primary key
  (dbid, snap_id, instance_number, class, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_ENQUEUE_STAT
Rem ***********************************************
alter table WRH$_ENQUEUE_STAT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_ENQUEUE_STAT drop primary key drop index
/
create unique index WRH$_ENQUEUE_STAT_PK on WRH$_ENQUEUE_STAT
  (dbid, snap_id, instance_number, eq_type, req_reason, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_ENQUEUE_STAT
 add constraint WRH$_ENQUEUE_STAT_PK primary key
  (dbid, snap_id, instance_number, eq_type, req_reason, con_dbid)
 using index WRH$_ENQUEUE_STAT_PK
/
alter index WRH$_ENQUEUE_STAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH
Rem ***********************************************
alter table WRH$_LATCH add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH drop primary key drop index
/
create unique index WRH$_LATCH_PK on WRH$_LATCH
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_LATCH
 add constraint WRH$_LATCH_PK primary key
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 using index WRH$_LATCH_PK
/
alter index WRH$_LATCH_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_BL
Rem ***********************************************
alter table WRH$_LATCH_BL add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_BL drop primary key drop index
/
alter table WRH$_LATCH_BL
 add constraint WRH$_LATCH_BL_PK primary key
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_CHILDREN
Rem ***********************************************
alter table WRH$_LATCH_CHILDREN
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_CHILDREN drop primary key drop index
/
create unique index WRH$_LATCH_CHILDREN_PK on WRH$_LATCH_CHILDREN
  (dbid, snap_id, instance_number, latch_hash, child#, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_LATCH_CHILDREN
 add constraint WRH$_LATCH_CHILDREN_PK primary key
  (dbid, snap_id, instance_number, latch_hash, child#, con_dbid)
 using index WRH$_LATCH_CHILDREN_PK
/
alter index WRH$_LATCH_CHILDREN_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_CHILDREN_BL
Rem ***********************************************
alter table WRH$_LATCH_CHILDREN_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_CHILDREN_BL drop primary key drop index
/
alter table WRH$_LATCH_CHILDREN_BL
 add constraint WRH$_LATCH_CHILDREN_BL_PK primary key
  (dbid, snap_id, instance_number, latch_hash, child#, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_PARENT
Rem ***********************************************
alter table WRH$_LATCH_PARENT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_PARENT drop primary key drop index
/
create unique index WRH$_LATCH_PARENT_PK on WRH$_LATCH_PARENT
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_LATCH_PARENT
 add constraint WRH$_LATCH_PARENT_PK primary key
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 using index WRH$_LATCH_PARENT_PK
/
alter index WRH$_LATCH_PARENT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_PARENT_BL
Rem ***********************************************
alter table WRH$_LATCH_PARENT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_PARENT_BL drop primary key drop index
/
alter table WRH$_LATCH_PARENT_BL
 add constraint WRH$_LATCH_PARENT_BL_PK primary key
  (dbid, snap_id, instance_number, latch_hash, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_MISSES_SUMMARY
Rem ***********************************************
alter table WRH$_LATCH_MISSES_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_MISSES_SUMMARY drop primary key drop index
/
create unique index WRH$_LATCH_MISSES_SUMMARY_PK on WRH$_LATCH_MISSES_SUMMARY
  (dbid, snap_id, instance_number, parent_name, where_in_code, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_LATCH_MISSES_SUMMARY
 add constraint WRH$_LATCH_MISSES_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, parent_name, where_in_code, con_dbid)
 using index WRH$_LATCH_MISSES_SUMMARY_PK
/
alter index WRH$_LATCH_MISSES_SUMMARY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_MISSES_SUMMARY_BL
Rem ***********************************************
alter table WRH$_LATCH_MISSES_SUMMARY_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_MISSES_SUMMARY_BL drop primary key drop index
/
alter table WRH$_LATCH_MISSES_SUMMARY_BL
 add constraint WRH$_LATCH_MISSES_SUMRY_BL_PK primary key
  (dbid, snap_id, instance_number, parent_name, where_in_code, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_EVENT_HISTOGRAM
Rem ***********************************************
alter table WRH$_EVENT_HISTOGRAM
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_EVENT_HISTOGRAM drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_EVENT_HISTOGRAM_PK on WRH$_EVENT_HISTOGRAM
    (dbid, snap_id, instance_number, event_id, wait_time_milli, con_dbid)
   local nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_EVENT_HISTOGRAM
 add constraint WRH$_EVENT_HISTOGRAM_PK primary key
  (dbid, snap_id, instance_number, event_id, wait_time_milli, con_dbid)
 using index WRH$_EVENT_HISTOGRAM_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_EVENT_HISTOGRAM_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_EVENT_HISTOGRAM_BL
Rem ***********************************************
alter table WRH$_EVENT_HISTOGRAM_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_EVENT_HISTOGRAM_BL drop primary key drop index
/
alter table WRH$_EVENT_HISTOGRAM_BL
 add constraint WRH$_EVENT_HISTOGRAM_BL_PK primary key
  (dbid, snap_id, instance_number, event_id, wait_time_milli, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_MUTEX_SLEEP
Rem ***********************************************
alter table WRH$_MUTEX_SLEEP
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MUTEX_SLEEP drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_MUTEX_SLEEP_PK on WRH$_MUTEX_SLEEP
    (dbid, snap_id, instance_number, mutex_type, location, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_MUTEX_SLEEP
 add constraint WRH$_MUTEX_SLEEP_PK primary key
  (dbid, snap_id, instance_number, mutex_type, location, con_dbid)
 using index WRH$_MUTEX_SLEEP_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_MUTEX_SLEEP_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_LIBRARYCACHE
Rem ***********************************************
alter table WRH$_LIBRARYCACHE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LIBRARYCACHE drop primary key drop index
/
create unique index WRH$_LIBRARYCACHE_PK on WRH$_LIBRARYCACHE
  (dbid, snap_id, instance_number, namespace, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_LIBRARYCACHE
 add constraint WRH$_LIBRARYCACHE_PK primary key
  (dbid, snap_id, instance_number, namespace, con_dbid)
 using index WRH$_LIBRARYCACHE_PK
/
alter index WRH$_LIBRARYCACHE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_DB_CACHE_ADVICE
Rem ***********************************************
alter table WRH$_DB_CACHE_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DB_CACHE_ADVICE drop primary key drop index
/
create unique index WRH$_DB_CACHE_ADVICE_PK on WRH$_DB_CACHE_ADVICE
  (dbid, snap_id, instance_number, bpid, buffers_for_estimate, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_DB_CACHE_ADVICE
 add constraint WRH$_DB_CACHE_ADVICE_PK primary key
  (dbid, snap_id, instance_number, bpid, buffers_for_estimate, con_dbid)
 using index WRH$_DB_CACHE_ADVICE_PK
/
alter index WRH$_DB_CACHE_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_DB_CACHE_ADVICE_BL
Rem ***********************************************
alter table WRH$_DB_CACHE_ADVICE_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DB_CACHE_ADVICE_BL drop primary key drop index
/
alter table WRH$_DB_CACHE_ADVICE_BL
 add constraint WRH$_DB_CACHE_ADVICE_BL_PK primary key
  (dbid, snap_id, instance_number, bpid, buffers_for_estimate, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_BUFFER_POOL_STATISTICS
Rem ***********************************************
alter table WRH$_BUFFER_POOL_STATISTICS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_BUFFER_POOL_STATISTICS drop primary key drop index
/
create unique index WRH$_BUFFER_POOL_STATISTICS_PK on
 WRH$_BUFFER_POOL_STATISTICS
  (dbid, snap_id, instance_number, id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_BUFFER_POOL_STATISTICS
 add constraint WRH$_BUFFER_POOL_STATISTICS_PK primary key
  (dbid, snap_id, instance_number, id, con_dbid)
 using index WRH$_BUFFER_POOL_STATISTICS_PK
/
alter index WRH$_BUFFER_POOL_STATISTICS_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_ROWCACHE_SUMMARY
Rem ***********************************************
alter table WRH$_ROWCACHE_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_ROWCACHE_SUMMARY drop primary key drop index
/
create unique index WRH$_ROWCACHE_SUMMARY_PK on WRH$_ROWCACHE_SUMMARY
  (dbid, snap_id, instance_number, parameter, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_ROWCACHE_SUMMARY
 add constraint WRH$_ROWCACHE_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, parameter, con_dbid)
 using index WRH$_ROWCACHE_SUMMARY_PK
/
alter index WRH$_ROWCACHE_SUMMARY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_ROWCACHE_SUMMARY_BL
Rem ***********************************************
alter table WRH$_ROWCACHE_SUMMARY_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_ROWCACHE_SUMMARY_BL drop primary key drop index
/
alter table WRH$_ROWCACHE_SUMMARY_BL
 add constraint WRH$_ROWCACHE_SUMMARY_BL_PK primary key
  (dbid, snap_id, instance_number, parameter, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_SGA
Rem ***********************************************
alter table WRH$_SGA add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SGA drop primary key drop index
/
create unique index WRH$_SGA_PK on WRH$_SGA
  (dbid, snap_id, instance_number, name, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SGA
 add constraint WRH$_SGA_PK primary key
  (dbid, snap_id, instance_number, name, con_dbid)
 using index WRH$_SGA_PK
/
alter index WRH$_SGA_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SGASTAT
Rem ***********************************************
alter table WRH$_SGASTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SGASTAT drop constraint WRH$_SGASTAT_U 
/
alter table WRH$_SGASTAT
 add constraint WRH$_SGASTAT_U unique
  (dbid, snap_id, instance_number, name, pool, con_dbid)
 using index local tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_SGASTAT_BL
Rem ***********************************************
alter table WRH$_SGASTAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SGASTAT_BL drop constraint WRH$_SGASTAT_BL_U
/
alter table WRH$_SGASTAT_BL
 add constraint WRH$_SGASTAT_BL_U unique
  (dbid, snap_id, instance_number, name, pool, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_PGASTAT
Rem ***********************************************
alter table WRH$_PGASTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PGASTAT drop primary key drop index
/
create unique index WRH$_PGASTAT_PK on WRH$_PGASTAT
  (dbid, snap_id, instance_number, name, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_PGASTAT
 add constraint WRH$_PGASTAT_PK primary key
  (dbid, snap_id, instance_number, name, con_dbid)
 using index WRH$_PGASTAT_PK
/
alter index WRH$_PGASTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PROCESS_MEMORY_SUMMARY
Rem ***********************************************
alter table WRH$_PROCESS_MEMORY_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PROCESS_MEMORY_SUMMARY drop primary key drop index
/
create unique index WRH$_PROCESS_MEMORY_SUMMARY_PK on
 WRH$_PROCESS_MEMORY_SUMMARY
  (dbid, snap_id, instance_number, category, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_PROCESS_MEMORY_SUMMARY
 add constraint WRH$_PROCESS_MEMORY_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, category, con_dbid)
 using index WRH$_PROCESS_MEMORY_SUMMARY_PK
/
alter index WRH$_PROCESS_MEMORY_SUMMARY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_RESOURCE_LIMIT
Rem ***********************************************
alter table WRH$_RESOURCE_LIMIT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_RESOURCE_LIMIT drop primary key drop index
/
create unique index WRH$_RESOURCE_LIMIT_PK on WRH$_RESOURCE_LIMIT
  (dbid, snap_id, instance_number, resource_name, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_RESOURCE_LIMIT
 add constraint WRH$_RESOURCE_LIMIT_PK primary key
  (dbid, snap_id, instance_number, resource_name, con_dbid)
 using index WRH$_RESOURCE_LIMIT_PK
/
alter index WRH$_RESOURCE_LIMIT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SHARED_POOL_ADVICE
Rem ***********************************************
alter table WRH$_SHARED_POOL_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SHARED_POOL_ADVICE drop primary key drop index
/
create unique index WRH$_SHARED_POOL_ADVICE_PK on WRH$_SHARED_POOL_ADVICE
  (dbid, snap_id, instance_number, shared_pool_size_for_estimate, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SHARED_POOL_ADVICE
 add constraint WRH$_SHARED_POOL_ADVICE_PK primary key
  (dbid, snap_id, instance_number, shared_pool_size_for_estimate, con_dbid)
 using index WRH$_SHARED_POOL_ADVICE_PK
/
alter index WRH$_SHARED_POOL_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_STREAMS_POOL_ADVICE
Rem ***********************************************
alter table WRH$_STREAMS_POOL_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_STREAMS_POOL_ADVICE drop primary key drop index
/
create unique index WRH$_STREAMS_POOL_ADVICE_PK on WRH$_STREAMS_POOL_ADVICE
  (dbid, snap_id, instance_number, size_for_estimate, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_STREAMS_POOL_ADVICE
 add constraint WRH$_STREAMS_POOL_ADVICE_PK primary key
  (dbid, snap_id, instance_number, size_for_estimate, con_dbid)
 using index WRH$_STREAMS_POOL_ADVICE_PK
/
alter index WRH$_STREAMS_POOL_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SQL_WORKAREA_HISTOGRAM
Rem ***********************************************
alter table WRH$_SQL_WORKAREA_HISTOGRAM
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQL_WORKAREA_HISTOGRAM drop primary key drop index
/
create unique index WRH$_SQL_WORKAREA_HISTOGRAM_PK on WRH$_SQL_WORKAREA_HISTOGRAM
  (dbid, snap_id, instance_number,
   low_optimal_size, high_optimal_size, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SQL_WORKAREA_HISTOGRAM
 add constraint WRH$_SQL_WORKAREA_HISTOGRAM_PK primary key
  (dbid, snap_id, instance_number,
   low_optimal_size, high_optimal_size, con_dbid)
 using index WRH$_SQL_WORKAREA_HISTOGRAM_PK
/
alter index WRH$_SQL_WORKAREA_HISTOGRAM_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PGA_TARGET_ADVICE
Rem ***********************************************
alter table WRH$_PGA_TARGET_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PGA_TARGET_ADVICE drop primary key drop index
/
create unique index WRH$_PGA_TARGET_ADVICE_PK on WRH$_PGA_TARGET_ADVICE
  (dbid, snap_id, instance_number, pga_target_for_estimate, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_PGA_TARGET_ADVICE
 add constraint WRH$_PGA_TARGET_ADVICE_PK primary key
  (dbid, snap_id, instance_number, pga_target_for_estimate, con_dbid)
 using index WRH$_PGA_TARGET_ADVICE_PK
/
alter index WRH$_PGA_TARGET_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SGA_TARGET_ADVICE
Rem ***********************************************
alter table WRH$_SGA_TARGET_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SGA_TARGET_ADVICE drop primary key drop index
/
create unique index WRH$_SGA_TARGET_ADVICE_PK on WRH$_SGA_TARGET_ADVICE
  (dbid, snap_id, instance_number, sga_size, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SGA_TARGET_ADVICE
 add constraint WRH$_SGA_TARGET_ADVICE_PK primary key
  (dbid, snap_id, instance_number, sga_size, con_dbid)
 using index WRH$_SGA_TARGET_ADVICE_PK
/
alter index WRH$_SGA_TARGET_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_MEMORY_TARGET_ADVICE
Rem ***********************************************
alter table WRH$_MEMORY_TARGET_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MEMORY_TARGET_ADVICE drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_MEMORY_TARGET_ADVICE_PK on
    WRH$_MEMORY_TARGET_ADVICE
    (dbid, snap_id, instance_number, memory_size, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_MEMORY_TARGET_ADVICE
 add constraint WRH$_MEMORY_TARGET_ADVICE_PK primary key
  (dbid, snap_id, instance_number, memory_size, con_dbid)
 using index WRH$_MEMORY_TARGET_ADVICE_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_MEMORY_TARGET_ADVICE_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_MEMORY_RESIZE_OPS
Rem ***********************************************
alter table WRH$_MEMORY_RESIZE_OPS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MEMORY_RESIZE_OPS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_MEMORY_RESIZE_OPS_PK on WRH$_MEMORY_RESIZE_OPS
    (dbid, snap_id, instance_number,
     component, oper_type, start_time, target_size, con_dbid)
 nologging parallel tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_MEMORY_RESIZE_OPS
 add constraint WRH$_MEMORY_RESIZE_OPS_PK primary key
  (dbid, snap_id, instance_number,
   component, oper_type, start_time, target_size, con_dbid)
 using index WRH$_MEMORY_RESIZE_OPS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_MEMORY_RESIZE_OPS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_INSTANCE_RECOVERY
Rem ***********************************************
alter table WRH$_INSTANCE_RECOVERY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_INSTANCE_RECOVERY drop primary key drop index
/
create unique index WRH$_INSTANCE_RECOVERY_PK on WRH$_INSTANCE_RECOVERY
  (dbid, snap_id, instance_number, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_INSTANCE_RECOVERY
 add constraint WRH$_INSTANCE_RECOVERY_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_INSTANCE_RECOVERY_PK
/
alter index WRH$_INSTANCE_RECOVERY_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_JAVA_POOL_ADVICE
Rem ***********************************************
alter table WRH$_JAVA_POOL_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_JAVA_POOL_ADVICE drop primary key drop index
/
create unique index WRH$_JAVA_POOL_ADVICE_PK on WRH$_JAVA_POOL_ADVICE
  (dbid, snap_id, instance_number, java_pool_size_for_estimate, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_JAVA_POOL_ADVICE
 add constraint WRH$_JAVA_POOL_ADVICE_PK primary key
  (dbid, snap_id, instance_number, java_pool_size_for_estimate, con_dbid)
 using index WRH$_JAVA_POOL_ADVICE_PK
/
alter index WRH$_JAVA_POOL_ADVICE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_THREAD
Rem ***********************************************
alter table WRH$_THREAD add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_THREAD drop primary key drop index
/
create unique index WRH$_THREAD_PK on WRH$_THREAD
  (dbid, snap_id, instance_number, thread#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_THREAD
 add constraint WRH$_THREAD_PK primary key
  (dbid, snap_id, instance_number, thread#, con_dbid)
 using index WRH$_THREAD_PK
/
alter index WRH$_THREAD_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSSTAT
Rem ***********************************************
alter table WRH$_SYSSTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYSSTAT drop primary key drop index
/
create unique index WRH$_SYSSTAT_PK on WRH$_SYSSTAT
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SYSSTAT
 add constraint WRH$_SYSSTAT_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index WRH$_SYSSTAT_PK
/
alter index WRH$_SYSSTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSSTAT_BL
Rem ***********************************************
alter table WRH$_SYSSTAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYSSTAT_BL drop primary key drop index
/
alter table WRH$_SYSSTAT_BL
 add constraint WRH$_SYSSTAT_BL_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_SYS_TIME_MODEL
Rem ***********************************************
alter table WRH$_SYS_TIME_MODEL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYS_TIME_MODEL drop primary key drop index
/
create unique index WRH$_SYS_TIME_MODEL_PK on WRH$_SYS_TIME_MODEL
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SYS_TIME_MODEL
 add constraint WRH$_SYS_TIME_MODEL_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index WRH$_SYS_TIME_MODEL_PK
/
alter index WRH$_SYS_TIME_MODEL_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYS_TIME_MODEL_BL
Rem ***********************************************
alter table WRH$_SYS_TIME_MODEL_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SYS_TIME_MODEL_BL drop primary key drop index
/
alter table WRH$_SYS_TIME_MODEL_BL
 add constraint WRH$_SYS_TIME_MODEL_BL_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_OSSTAT
Rem ***********************************************
alter table WRH$_OSSTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_OSSTAT drop primary key drop index
/
create unique index WRH$_OSSTAT_PK on WRH$_OSSTAT
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_OSSTAT
 add constraint WRH$_OSSTAT_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index WRH$_OSSTAT_PK
/
alter index WRH$_OSSTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_OSSTAT_BL
Rem ***********************************************
alter table WRH$_OSSTAT_BL add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_OSSTAT_BL drop primary key drop index
/
alter table WRH$_OSSTAT_BL
 add constraint WRH$_OSSTAT_BL_PK primary key
  (dbid, snap_id, instance_number, stat_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_PARAMETER
Rem ***********************************************
alter table WRH$_PARAMETER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PARAMETER drop primary key drop index
/
create unique index WRH$_PARAMETER_PK on WRH$_PARAMETER
  (dbid, snap_id, instance_number, parameter_hash, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_PARAMETER
 add constraint WRH$_PARAMETER_PK primary key
  (dbid, snap_id, instance_number, parameter_hash, con_dbid)
 using index WRH$_PARAMETER_PK
/
alter index WRH$_PARAMETER_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PARAMETER_BL
Rem ***********************************************
alter table WRH$_PARAMETER_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PARAMETER_BL drop primary key drop index
/
alter table WRH$_PARAMETER_BL
 add constraint WRH$_PARAMETER_BL_PK primary key
  (dbid, snap_id, instance_number, parameter_hash, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_MVPARAMETER
Rem ***********************************************
alter table WRH$_MVPARAMETER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MVPARAMETER drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_MVPARAMETER_PK on WRH$_MVPARAMETER
    (dbid, snap_id, instance_number, parameter_hash, ordinal, con_dbid)
   local nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_MVPARAMETER
 add constraint WRH$_MVPARAMETER_PK primary key
  (dbid, snap_id, instance_number, parameter_hash, ordinal, con_dbid)
 using index WRH$_MVPARAMETER_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_MVPARAMETER_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_MVPARAMETER_BL
Rem ***********************************************
alter table WRH$_MVPARAMETER_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MVPARAMETER_BL drop primary key drop index
/
alter table WRH$_MVPARAMETER_BL
 add constraint WRH$_MVPARAMETER_BL_PK primary key
  (dbid, snap_id, instance_number, parameter_hash, ordinal, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_UNDOSTAT
Rem ***********************************************
alter table WRH$_UNDOSTAT add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_UNDOSTAT drop primary key drop index
/
create unique index WRH$_UNDOSTAT_PK on WRH$_UNDOSTAT
  (begin_time, end_time, dbid, instance_number, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_UNDOSTAT
 add constraint WRH$_UNDOSTAT_PK primary key
  (begin_time, end_time, dbid, instance_number, con_dbid)
 using index WRH$_UNDOSTAT_PK
/
alter index WRH$_UNDOSTAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSMETRIC_HISTORY
Rem ***********************************************
alter table WRH$_SYSMETRIC_HISTORY
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_SYSMETRIC_HISTORY_INDEX
/
create index WRH$_SYSMETRIC_HISTORY_INDEX on WRH$_SYSMETRIC_HISTORY
  (dbid, snap_id, instance_number, group_id, metric_id, begin_time, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_SYSMETRIC_HISTORY_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SYSMETRIC_SUMMARY
Rem ***********************************************
alter table WRH$_SYSMETRIC_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_SYSMETRIC_SUMMARY_INDEX
/
create index WRH$_SYSMETRIC_SUMMARY_INDEX on WRH$_SYSMETRIC_SUMMARY
  (dbid, snap_id, instance_number, group_id, metric_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_SYSMETRIC_SUMMARY_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SESSMETRIC_HISTORY
Rem ***********************************************
alter table WRH$_SESSMETRIC_HISTORY
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_SESSMETRIC_HISTORY_INDEX
/
create index WRH$_SESSMETRIC_HISTORY_INDEX on WRH$_SESSMETRIC_HISTORY
  (dbid, snap_id, instance_number,
   group_id, sessid, metric_id, begin_time, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_SESSMETRIC_HISTORY_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_FILEMETRIC_HISTORY
Rem ***********************************************
alter table WRH$_FILEMETRIC_HISTORY
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_FILEMETRIC_HISTORY_INDEX
/
create index WRH$_FILEMETRIC_HISTORY_INDEX on WRH$_FILEMETRIC_HISTORY
  (dbid, snap_id, instance_number,
   group_id, fileid, begin_time, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_FILEMETRIC_HISTORY_INDEX noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_WAITCLASSMETRIC_HISTORY
Rem ***********************************************
alter table WRH$_WAITCLASSMETRIC_HISTORY
 add (con_dbid number default &new_con_dbid not null)
/
drop index WRH$_WAITCLASSMETRIC_HIST_IND
/
create index WRH$_WAITCLASSMETRIC_HIST_IND on WRH$_WAITCLASSMETRIC_HISTORY
  (dbid, snap_id, instance_number,
   group_id, wait_class_id, begin_time, con_dbid)
 nologging parallel tablespace sysaux
/
alter index WRH$_WAITCLASSMETRIC_HIST_IND noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_DLM_MISC
Rem ***********************************************
alter table WRH$_DLM_MISC add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DLM_MISC drop primary key drop index
/
create unique index WRH$_DLM_MISC_PK on WRH$_DLM_MISC
  (dbid, snap_id, instance_number, statistic#, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_DLM_MISC
 add constraint WRH$_DLM_MISC_PK primary key
  (dbid, snap_id, instance_number, statistic#, con_dbid)
 using index WRH$_DLM_MISC_PK
/
alter index WRH$_DLM_MISC_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_DLM_MISC_BL
Rem ***********************************************
alter table WRH$_DLM_MISC_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DLM_MISC_BL drop primary key drop index
/
alter table WRH$_DLM_MISC_BL
 add constraint WRH$_DLM_MISC_BL_PK primary key
  (dbid, snap_id, instance_number, statistic#, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_CR_BLOCK_SERVER
Rem ***********************************************
alter table WRH$_CR_BLOCK_SERVER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_CR_BLOCK_SERVER drop primary key drop index
/
create unique index WRH$_CR_BLOCK_SERVER_PK on WRH$_CR_BLOCK_SERVER
  (dbid, snap_id, instance_number, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_CR_BLOCK_SERVER
 add constraint WRH$_CR_BLOCK_SERVER_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_CR_BLOCK_SERVER_PK
/
alter index WRH$_CR_BLOCK_SERVER_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_CURRENT_BLOCK_SERVER
Rem ***********************************************
alter table WRH$_CURRENT_BLOCK_SERVER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_CURRENT_BLOCK_SERVER drop primary key drop index
/
create unique index WRH$_CURRENT_BLOCK_SERVER_PK on WRH$_CURRENT_BLOCK_SERVER
  (dbid, snap_id, instance_number, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_CURRENT_BLOCK_SERVER
 add constraint WRH$_CURRENT_BLOCK_SERVER_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_CURRENT_BLOCK_SERVER_PK
/
alter index WRH$_CURRENT_BLOCK_SERVER_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_INST_CACHE_TRANSFER
Rem ***********************************************
alter table WRH$_INST_CACHE_TRANSFER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_INST_CACHE_TRANSFER drop primary key drop index
/
create unique index WRH$_INST_CACHE_TRANSFER_PK on WRH$_INST_CACHE_TRANSFER
  (dbid, snap_id, instance_number, instance, class, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_INST_CACHE_TRANSFER
 add constraint WRH$_INST_CACHE_TRANSFER_PK primary key
  (dbid, snap_id, instance_number, instance, class, con_dbid)
 using index WRH$_INST_CACHE_TRANSFER_PK
/
alter index WRH$_INST_CACHE_TRANSFER_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_INST_CACHE_TRANSFER_BL
Rem ***********************************************
alter table WRH$_INST_CACHE_TRANSFER_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_INST_CACHE_TRANSFER_BL drop primary key drop index
/
alter table WRH$_INST_CACHE_TRANSFER_BL
 add constraint WRH$_INST_CACHE_TRANSFER_BL_PK primary key
  (dbid, snap_id, instance_number, instance, class, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_LOG
Rem ***********************************************
alter table WRH$_LOG add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LOG drop primary key drop index
/
create unique index WRH$_LOG_PK on WRH$_LOG
  (dbid, snap_id, instance_number, group#, thread#, sequence#, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_LOG
 add constraint WRH$_LOG_PK primary key
  (dbid, snap_id, instance_number, group#, thread#, sequence#, con_dbid)
 using index WRH$_LOG_PK
/
alter index WRH$_LOG_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_MTTR_TARGET_ADVICE
Rem ***********************************************
alter table WRH$_MTTR_TARGET_ADVICE
 add (con_dbid number default &new_con_dbid not null)
/

Rem ***********************************************
Rem Upgrade WRH$_SERVICE_STAT
Rem ***********************************************
alter table WRH$_SERVICE_STAT
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SERVICE_STAT drop primary key drop index
/
create unique index WRH$_SERVICE_STAT_PK on WRH$_SERVICE_STAT
  (dbid, snap_id, instance_number, service_name_hash, stat_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SERVICE_STAT
 add constraint WRH$_SERVICE_STAT_PK primary key
  (dbid, snap_id, instance_number, service_name_hash, stat_id, con_dbid)
 using index WRH$_SERVICE_STAT_PK
/
alter index WRH$_SERVICE_STAT_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SERVICE_STAT_BL
Rem ***********************************************
alter table WRH$_SERVICE_STAT_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SERVICE_STAT_BL drop primary key drop index
/
alter table WRH$_SERVICE_STAT_BL
 add constraint WRH$_SERVICE_STAT_BL_PK primary key
  (dbid, snap_id, instance_number, service_name_hash, stat_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_SERVICE_WAIT_CLASS
Rem ***********************************************
alter table WRH$_SERVICE_WAIT_CLASS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SERVICE_WAIT_CLASS drop primary key drop index
/
create unique index WRH$_SERVICE_WAIT_CLASS_PK on WRH$_SERVICE_WAIT_CLASS
  (dbid, snap_id, instance_number,
   service_name_hash, wait_class_id, con_dbid)
 local nologging parallel tablespace sysaux
/
alter table WRH$_SERVICE_WAIT_CLASS
 add constraint WRH$_SERVICE_WAIT_CLASS_PK primary key
  (dbid, snap_id, instance_number,
   service_name_hash, wait_class_id, con_dbid)
 using index WRH$_SERVICE_WAIT_CLASS_PK
/
alter index WRH$_SERVICE_WAIT_CLASS_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SERVICE_WAIT_CLASS_BL
Rem ***********************************************
alter table WRH$_SERVICE_WAIT_CLASS_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SERVICE_WAIT_CLASS_BL drop primary key drop index
/
alter table WRH$_SERVICE_WAIT_CLASS_BL
 add constraint WRH$_SERVICE_WAIT_CLASS_BL_PK primary key
  (dbid, snap_id, instance_number,
   service_name_hash, wait_class_id, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_SESS_TIME_STATS
Rem ***********************************************
alter table WRH$_SESS_TIME_STATS 
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SESS_TIME_STATS 
add(session_module varchar2(64) default 'Streams' not null) 
/
alter table WRH$_SESS_TIME_STATS drop primary key drop index
/
create unique index WRH$_SESS_TIME_STATS_PK on WRH$_SESS_TIME_STATS
  (dbid, snap_id, instance_number, session_type, session_module, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SESS_TIME_STATS
 add constraint WRH$_SESS_TIME_STATS_PK primary key
  (dbid, snap_id, instance_number, session_type, session_module, con_dbid)
 using index WRH$_SESS_TIME_STATS_PK
/
alter index WRH$_SESS_TIME_STATS_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_STREAMS_CAPTURE
Rem ***********************************************
alter table WRH$_STREAMS_CAPTURE 
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_STREAMS_CAPTURE add(extract_name varchar2(128))
/
alter table WRH$_STREAMS_CAPTURE add(bytes_redo_mined number)
/
alter table WRH$_STREAMS_CAPTURE add(bytes_sent  number) 
/
alter table WRH$_STREAMS_CAPTURE 
add(session_module varchar2(64) default 'Streams' not null) 
/
alter table WRH$_STREAMS_CAPTURE drop primary key drop index
/
create unique index WRH$_STREAMS_CAPTURE_PK on WRH$_STREAMS_CAPTURE
  (dbid, snap_id, instance_number, capture_name, session_module, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_STREAMS_CAPTURE
 add constraint WRH$_STREAMS_CAPTURE_PK primary key
  (dbid, snap_id, instance_number, capture_name, session_module, con_dbid)
 using index WRH$_STREAMS_CAPTURE_PK
/
alter index WRH$_STREAMS_CAPTURE_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_STREAMS_APPLY_SUM
Rem ***********************************************
alter table WRH$_STREAMS_APPLY_SUM 
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_STREAMS_APPLY_SUM add(replicat_name varchar2(128))
/
alter table WRH$_STREAMS_APPLY_SUM add(unassigned_complete_txn number)
/
alter table WRH$_STREAMS_APPLY_SUM add(total_lcrs_retried number)
/ 
alter table WRH$_STREAMS_APPLY_SUM add(total_transactions_retried  number) 
/
alter table WRH$_STREAMS_APPLY_SUM add(total_errors number)
/
alter table WRH$_STREAMS_APPLY_SUM 
add(session_module varchar2(64) default 'Streams' not null)
/
alter table WRH$_STREAMS_APPLY_SUM drop primary key drop index
/
create unique index WRH$_STREAMS_APPLY_SUM_PK on WRH$_STREAMS_APPLY_SUM
  (dbid, snap_id, instance_number, apply_name, session_module, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_STREAMS_APPLY_SUM
 add constraint WRH$_STREAMS_APPLY_SUM_PK primary key
  (dbid, snap_id, instance_number, apply_name, session_module, con_dbid)
 using index WRH$_STREAMS_APPLY_SUM_PK
/
alter index WRH$_STREAMS_APPLY_SUM_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_BUFFERED_QUEUES
Rem ***********************************************
alter table WRH$_BUFFERED_QUEUES
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_BUFFERED_QUEUES drop primary key drop index
/
create unique index WRH$_BUFFERED_QUEUES_PK on WRH$_BUFFERED_QUEUES
  (dbid, snap_id, instance_number, queue_schema, queue_name, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_BUFFERED_QUEUES
 add constraint WRH$_BUFFERED_QUEUES_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_name, con_dbid)
 using index WRH$_BUFFERED_QUEUES_PK
/
alter index WRH$_BUFFERED_QUEUES_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_BUFFERED_SUBSCRIBERS
Rem ***********************************************
alter table WRH$_BUFFERED_SUBSCRIBERS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_BUFFERED_SUBSCRIBERS drop primary key drop index
/
create unique index WRH$_BUFFERED_SUBSCRIBERS_PK on WRH$_BUFFERED_SUBSCRIBERS
  (dbid, snap_id, instance_number,
   queue_schema, queue_name, subscriber_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_BUFFERED_SUBSCRIBERS
 add constraint WRH$_BUFFERED_SUBSCRIBERS_PK primary key
  (dbid, snap_id, instance_number,
   queue_schema, queue_name, subscriber_id, con_dbid)
 using index WRH$_BUFFERED_SUBSCRIBERS_PK
/
alter index WRH$_BUFFERED_SUBSCRIBERS_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PERSISTENT_QUEUES
Rem ***********************************************
alter table WRH$_PERSISTENT_QUEUES
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PERSISTENT_QUEUES drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_PERSISTENT_QUEUES_PK on WRH$_PERSISTENT_QUEUES
    (dbid, snap_id, instance_number, queue_schema, queue_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_PERSISTENT_QUEUES
 add constraint WRH$_PERSISTENT_QUEUES_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_id, con_dbid)
 using index WRH$_PERSISTENT_QUEUES_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_PERSISTENT_QUEUES_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_PERSISTENT_SUBSCRIBERS
Rem ***********************************************
alter table WRH$_PERSISTENT_SUBSCRIBERS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PERSISTENT_SUBSCRIBERS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_PERSISTENT_SUBSCRIBERS_PK on
    WRH$_PERSISTENT_SUBSCRIBERS
    (dbid, snap_id, instance_number,
     queue_schema, queue_name, subscriber_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_PERSISTENT_SUBSCRIBERS
 add constraint WRH$_PERSISTENT_SUBSCRIBERS_PK primary key
  (dbid, snap_id, instance_number,
   queue_schema, queue_name, subscriber_id, con_dbid)
 using index WRH$_PERSISTENT_SUBSCRIBERS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_PERSISTENT_SUBSCRIBERS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_RULE_SET
Rem ***********************************************
alter table WRH$_RULE_SET add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_RULE_SET drop primary key drop index
/
create unique index WRH$_RULE_SET_PK on WRH$_RULE_SET
  (dbid, snap_id, instance_number, owner, name, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_RULE_SET
 add constraint WRH$_RULE_SET_PK primary key
  (dbid, snap_id, instance_number, owner, name, con_dbid)
 using index WRH$_RULE_SET_PK
/
alter index WRH$_RULE_SET_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_RSRC_CONSUMER_GROUP
Rem ***********************************************
alter table WRH$_RSRC_CONSUMER_GROUP
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_RSRC_CONSUMER_GROUP drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_RSRC_CONSUMER_GROUP_PK on WRH$_RSRC_CONSUMER_GROUP
    (dbid, snap_id, instance_number, sequence#, consumer_group_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_RSRC_CONSUMER_GROUP
 add constraint WRH$_RSRC_CONSUMER_GROUP_PK primary key
  (dbid, snap_id, instance_number, sequence#, consumer_group_id, con_dbid)
 using index WRH$_RSRC_CONSUMER_GROUP_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_RSRC_CONSUMER_GROUP_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_RSRC_PLAN
Rem ***********************************************
alter table WRH$_RSRC_PLAN add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_RSRC_PLAN drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_RSRC_PLAN_PK on WRH$_RSRC_PLAN
    (dbid, snap_id, instance_number, sequence#, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_RSRC_PLAN
 add constraint WRH$_RSRC_PLAN_PK primary key
  (dbid, snap_id, instance_number, sequence#, con_dbid)
 using index WRH$_RSRC_PLAN_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_RSRC_PLAN_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_CLUSTER_INTERCON
Rem ***********************************************
alter table WRH$_CLUSTER_INTERCON
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_CLUSTER_INTERCON drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_CLUSTER_INTERCON_PK on WRH$_CLUSTER_INTERCON
    (dbid, snap_id, instance_number, name, ip_address, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_CLUSTER_INTERCON
 add constraint WRH$_CLUSTER_INTERCON_PK primary key
  (dbid, snap_id, instance_number, name, ip_address, con_dbid)
 using index WRH$_CLUSTER_INTERCON_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_CLUSTER_INTERCON_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IC_DEVICE_STATS
Rem ***********************************************
alter table WRH$_IC_DEVICE_STATS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IC_DEVICE_STATS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IC_DEVICE_STATS_PK on WRH$_IC_DEVICE_STATS
    (dbid, snap_id, instance_number, if_name, ip_addr, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IC_DEVICE_STATS
 add constraint WRH$_IC_DEVICE_STATS_PK primary key
  (dbid, snap_id, instance_number, if_name, ip_addr, con_dbid)
 using index WRH$_IC_DEVICE_STATS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IC_DEVICE_STATS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IC_CLIENT_STATS
Rem ***********************************************
alter table WRH$_IC_CLIENT_STATS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IC_CLIENT_STATS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IC_CLIENT_STATS_PK on WRH$_IC_CLIENT_STATS
    (dbid, snap_id, instance_number, name, con_dbid)
 nologging parallel tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IC_CLIENT_STATS
 add constraint WRH$_IC_CLIENT_STATS_PK primary key
  (dbid, snap_id, instance_number, name, con_dbid)
 using index WRH$_IC_CLIENT_STATS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IC_CLIENT_STATS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_MEM_DYNAMIC_COMP
Rem ***********************************************
alter table WRH$_MEM_DYNAMIC_COMP
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_MEM_DYNAMIC_COMP drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_MEM_DYNAMIC_COMP_PK on WRH$_MEM_DYNAMIC_COMP
    (dbid, snap_id, instance_number, component, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_MEM_DYNAMIC_COMP
 add constraint WRH$_MEM_DYNAMIC_COMP_PK primary key
  (dbid, snap_id, instance_number, component, con_dbid)
 using index WRH$_MEM_DYNAMIC_COMP_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_MEM_DYNAMIC_COMP_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_INTERCONNECT_PINGS
Rem ***********************************************
alter table WRH$_INTERCONNECT_PINGS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_INTERCONNECT_PINGS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_INTERCONNECT_PINGS_PK on WRH$_INTERCONNECT_PINGS
    (dbid, snap_id, instance_number, target_instance, con_dbid)
   local nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_INTERCONNECT_PINGS
 add constraint WRH$_INTERCONNECT_PINGS_PK primary key
  (dbid, snap_id, instance_number, target_instance, con_dbid)
 using index WRH$_INTERCONNECT_PINGS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_INTERCONNECT_PINGS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_INTERCONNECT_PINGS_BL
Rem ***********************************************
alter table WRH$_INTERCONNECT_PINGS_BL
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_INTERCONNECT_PINGS_BL drop primary key drop index
/
alter table WRH$_INTERCONNECT_PINGS_BL
 add constraint WRH$_INTERCONNECT_PINGS_BL_PK primary key
  (dbid, snap_id, instance_number, target_instance, con_dbid)
 using index tablespace SYSAUX
/

Rem ***********************************************
Rem Upgrade WRH$_DISPATCHER
Rem ***********************************************
alter table WRH$_DISPATCHER
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DISPATCHER drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_DISPATCHER_PK on WRH$_DISPATCHER
    (dbid, snap_id, instance_number, name, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_DISPATCHER
 add constraint WRH$_DISPATCHER_PK primary key
  (dbid, snap_id, instance_number, name, con_dbid)
 using index WRH$_DISPATCHER_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_DISPATCHER_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_SHARED_SERVER_SUMMARY
Rem ***********************************************
alter table WRH$_SHARED_SERVER_SUMMARY
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SHARED_SERVER_SUMMARY drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_SHARED_SERVER_SUMMARY_PK on WRH$_SHARED_SERVER_SUMMARY
    (dbid, snap_id, instance_number, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_SHARED_SERVER_SUMMARY
 add constraint WRH$_SHARED_SERVER_SUMMARY_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_SHARED_SERVER_SUMMARY_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_SHARED_SERVER_SUMMARY_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_DYN_REMASTER_STATS
Rem ***********************************************
alter table WRH$_DYN_REMASTER_STATS
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_DYN_REMASTER_STATS drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_DYN_REMASTER_STATS_PK on WRH$_DYN_REMASTER_STATS
    (dbid, snap_id, instance_number, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_DYN_REMASTER_STATS
 add constraint WRH$_DYN_REMASTER_STATS_PK primary key
  (dbid, snap_id, instance_number, con_dbid)
 using index WRH$_DYN_REMASTER_STATS_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_DYN_REMASTER_STATS_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_PERSISTENT_QMN_CACHE
Rem ***********************************************
alter table WRH$_PERSISTENT_QMN_CACHE
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PERSISTENT_QMN_CACHE drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_PERSISTENT_QMN_CACHE_PK on WRH$_PERSISTENT_QMN_CACHE
    (dbid, snap_id, instance_number, queue_table_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_PERSISTENT_QMN_CACHE
 add constraint WRH$_PERSISTENT_QMN_CACHE_PK primary key
  (dbid, snap_id, instance_number, queue_table_id, con_dbid)
 using index WRH$_PERSISTENT_QMN_CACHE_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_PERSISTENT_QMN_CACHE_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IOSTAT_FUNCTION_NAME
Rem ***********************************************
alter table WRH$_IOSTAT_FUNCTION_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IOSTAT_FUNCTION_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IOSTAT_FUNCTION_NAME_PK on WRH$_IOSTAT_FUNCTION_NAME
    (dbid, function_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IOSTAT_FUNCTION_NAME
 add constraint WRH$_IOSTAT_FUNCTION_NAME_PK primary key
  (dbid, function_id, con_dbid)
 using index WRH$_IOSTAT_FUNCTION_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IOSTAT_FUNCTION_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_IOSTAT_FILETYPE_NAME
Rem ***********************************************
alter table WRH$_IOSTAT_FILETYPE_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_IOSTAT_FILETYPE_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_IOSTAT_FILETYPE_NAME_PK on WRH$_IOSTAT_FILETYPE_NAME
    (dbid, filetype_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_IOSTAT_FILETYPE_NAME
 add constraint WRH$_IOSTAT_FILETYPE_NAME_PK primary key
  (dbid, filetype_id, con_dbid)
 using index WRH$_IOSTAT_FILETYPE_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_IOSTAT_FILETYPE_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_EVENT_NAME
Rem ***********************************************
alter table WRH$_EVENT_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_EVENT_NAME drop primary key drop index
/
create unique index WRH$_EVENT_NAME_PK on WRH$_EVENT_NAME
  (dbid, event_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_EVENT_NAME
 add constraint WRH$_EVENT_NAME_PK primary key
  (dbid, event_id, con_dbid)
 using index WRH$_EVENT_NAME_PK
/
alter index WRH$_EVENT_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_LATCH_NAME
Rem ***********************************************
alter table WRH$_LATCH_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_LATCH_NAME drop primary key drop index
/
create unique index WRH$_LATCH_NAME_PK on WRH$_LATCH_NAME
  (dbid, latch_hash, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_LATCH_NAME
 add constraint WRH$_LATCH_NAME_PK primary key
  (dbid, latch_hash, con_dbid)
 using index WRH$_LATCH_NAME_PK
/
alter index WRH$_LATCH_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_STAT_NAME
Rem ***********************************************
alter table WRH$_STAT_NAME add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_STAT_NAME drop primary key drop index
/
create unique index WRH$_STAT_NAME_PK on WRH$_STAT_NAME
  (dbid, stat_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_STAT_NAME
 add constraint WRH$_STAT_NAME_PK primary key
  (dbid, stat_id, con_dbid)
 using index WRH$_STAT_NAME_PK
/
alter index WRH$_STAT_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_OSSTAT_NAME
Rem ***********************************************
alter table WRH$_OSSTAT_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_OSSTAT_NAME drop primary key drop index
/
create unique index WRH$_OSSTAT_NAME_PK on WRH$_OSSTAT_NAME
  (dbid, stat_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_OSSTAT_NAME
 add constraint WRH$_OSSTAT_NAME_PK primary key
  (dbid, stat_id, con_dbid)
 using index WRH$_OSSTAT_NAME_PK
/
alter index WRH$_OSSTAT_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PARAMETER_NAME
Rem ***********************************************
alter table WRH$_PARAMETER_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PARAMETER_NAME drop primary key drop index
/
create unique index WRH$_PARAMETER_NAME_PK on WRH$_PARAMETER_NAME
  (dbid, parameter_hash, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_PARAMETER_NAME
 add constraint WRH$_PARAMETER_NAME_PK primary key
  (dbid, parameter_hash, con_dbid)
 using index WRH$_PARAMETER_NAME_PK
/
alter index WRH$_PARAMETER_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_PLAN_OPERATION_NAME
Rem ***********************************************
alter table WRH$_PLAN_OPERATION_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PLAN_OPERATION_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_PLAN_OPERATION_NAME_PK on WRH$_PLAN_OPERATION_NAME
    (dbid, operation_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_PLAN_OPERATION_NAME
 add constraint WRH$_PLAN_OPERATION_NAME_PK primary key
  (dbid, operation_id, con_dbid)
 using index WRH$_PLAN_OPERATION_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_PLAN_OPERATION_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_PLAN_OPTION_NAME
Rem ***********************************************
alter table WRH$_PLAN_OPTION_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_PLAN_OPTION_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_PLAN_OPTION_NAME_PK on WRH$_PLAN_OPTION_NAME
    (dbid, option_id, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_PLAN_OPTION_NAME
 add constraint WRH$_PLAN_OPTION_NAME_PK primary key
  (dbid, option_id, con_dbid)
 using index WRH$_PLAN_OPTION_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_PLAN_OPTION_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_SQLCOMMAND_NAME
Rem ***********************************************
alter table WRH$_SQLCOMMAND_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SQLCOMMAND_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_SQLCOMMAND_NAME_PK on WRH$_SQLCOMMAND_NAME
    (dbid, command_type, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_SQLCOMMAND_NAME
 add constraint WRH$_SQLCOMMAND_NAME_PK primary key
  (dbid, command_type, con_dbid)
 using index WRH$_SQLCOMMAND_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_SQLCOMMAND_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_TOPLEVELCALL_NAME
Rem ***********************************************
alter table WRH$_TOPLEVELCALL_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_TOPLEVELCALL_NAME drop primary key drop index
/
BEGIN
 EXECUTE IMMEDIATE
  'create unique index WRH$_TOPLEVELCALL_NAME_PK on WRH$_TOPLEVELCALL_NAME
    (dbid, top_level_call#, con_dbid)
   nologging parallel
   tablespace sysaux';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -942) THEN NULL; ELSE RAISE; END IF;
END;
/
alter table WRH$_TOPLEVELCALL_NAME
 add constraint WRH$_TOPLEVELCALL_NAME_PK primary key
  (dbid, top_level_call#, con_dbid)
 using index WRH$_TOPLEVELCALL_NAME_PK
/
BEGIN
 EXECUTE IMMEDIATE 'alter index WRH$_TOPLEVELCALL_NAME_PK noparallel';
EXCEPTION
 WHEN OTHERS THEN IF (SQLCODE = -1418) THEN NULL; ELSE RAISE; END IF;
END;
/

Rem ***********************************************
Rem Upgrade WRH$_METRIC_NAME
Rem ***********************************************
alter table WRH$_METRIC_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_METRIC_NAME drop primary key drop index
/
create unique index WRH$_METRIC_NAME_PK on WRH$_METRIC_NAME
  (dbid, group_id, metric_id, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_METRIC_NAME
 add constraint WRH$_METRIC_NAME_PK primary key
  (dbid, group_id, metric_id, con_dbid)
 using index WRH$_METRIC_NAME_PK
/
alter index WRH$_METRIC_NAME_PK noparallel
/

Rem ***********************************************
Rem Upgrade WRH$_SERVICE_NAME
Rem ***********************************************
alter table WRH$_SERVICE_NAME
 add (con_dbid number default &new_con_dbid not null)
/
alter table WRH$_SERVICE_NAME drop primary key drop index
/
create unique index WRH$_SERVICE_NAME_PK on WRH$_SERVICE_NAME
  (dbid, service_name_hash, con_dbid)
 nologging parallel tablespace sysaux
/
alter table WRH$_SERVICE_NAME
 add constraint WRH$_SERVICE_NAME_PK primary key
  (dbid, service_name_hash, con_dbid)
 using index WRH$_SERVICE_NAME_PK
/
alter index WRH$_SERVICE_NAME_PK noparallel
/

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem WRM$_PDB_INSTANCE
Rem  Contains open-time information for pluggable databases
Rem  Used only for consolidated database
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE TABLE WRM$_PDB_INSTANCE
(dbid                 number       not null
,instance_number      number       not null
,startup_time         timestamp(3) not null
,con_dbid             number       not null
,open_time            timestamp(3) not null
,open_mode            varchar2(16)
,pdb_name             varchar2(128)
,constraint WRM$_PDB_INSTANCE_PK primary key
   (dbid, instance_number, startup_time, con_dbid, open_time)
   using index tablespace sysaux
) tablespace SYSAUX
/
Rem ******************************************
Rem * Add columns for Remote Snapshot support
Rem *****************************************
ALTER TABLE WRM$_WR_CONTROL ADD (
src_dbid               number default 0
,src_dbname             varchar2(32)
,t2s_dblink             varchar2(128)
,flush_type             number default 0
,snap_align             number default 0)
/
Rem ****************************************************************
Rem * Assign default src_dbname values for existing non-local DBIDs
Rem ****************************************************************
BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    '   SET src_dbname = TO_CHAR(dbid) ';
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
Rem *********************************************
Rem * Add unique constraint on src_dbname
Rem *********************************************
ALTER TABLE WRM$_WR_CONTROL ADD CONSTRAINT 
         WRM$_WR_CONTROL_NAME_UK unique (src_dbname)
 using index tablespace SYSAUX
/

Rem ****************************************************************
Rem * Set "CDB cleanup required" flag for existing non-local DBIDs
Rem ****************************************************************
BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    '   SET status_flag = status_flag + 4 ' ||
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

Rem *************************************************************************
Rem Increment  AWR version for 12gR1
Rem *************************************************************************
Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (12gR1   = SWRF Version 10)              ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 10';
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
Rem End Increment AWR version
Rem *************************************************************************

-- Turn OFF the event to disable the partition check
-- Needed for upgrade of AWR tables
alter session set events  '14524 OFF';

Rem =======================================================================
Rem END AWR Changes for 12g
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN Changes for refresh operations of non-updatable replication MVs
Rem *************************************************************************

Rem  Set status of non-updatable replication MVs to regenerate refresh
Rem  operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE bitand(s.flag, 4096) = 0 AND
       bitand(s.flag, 8192) = 0 AND
       bitand(s.flag, 16384) = 0 AND
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete old fast refresh operations for non-updatable replication MVs
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

Rem *************************************************************************
Rem END Changes for refresh operations of non-updatable replication MVs
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Utilities Feature Tracking
Rem*************************************************************************

alter table sys.ku_utluse add (encrypt128  number default 0);
alter table sys.ku_utluse add (encrypt192  number default 0);
alter table sys.ku_utluse add (encrypt256  number default 0);
alter table sys.ku_utluse add (encryptpwd  number default 0);
alter table sys.ku_utluse add (encryptdual number default 0); 
alter table sys.ku_utluse add (encrypttran number default 0);
alter table sys.ku_utluse add (compressbas number default 0); 
alter table sys.ku_utluse add (compresslow number default 0);
alter table sys.ku_utluse add (compressmed number default 0);
alter table sys.ku_utluse add (compresshgh number default 0); 
alter table sys.ku_utluse add (parallelcnt number default 0);
alter table sys.ku_utluse add (fullttscnt  number default 0);

Rem*************************************************************************
Rem END Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem Add new columns to the STS plans table
alter table wri$_sqlset_plans add (flags number, masked_binds_flag raw(1000));


Rem *************************************************************************
Rem END Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for DB Privileges
Rem *************************************************************************

Rem BUG 12628619: Unlimited Tablespace granted to roles is not effective. 
Rem               Hence remove from all roles.

DECLARE 
  user_names       dbms_sql.varchar2s;
  i                PLS_INTEGER;
BEGIN
  SELECT u.name 
   BULK COLLECT INTO user_names FROM user$ u JOIN sysauth$ s 
   ON (s.grantee# = u.user#) WHERE (s.privilege#=-15) AND (u.type#=0);
  FOR i IN 1 .. user_names.count 
  LOOP  
      EXECUTE IMMEDIATE 'REVOKE UNLIMITED TABLESPACE FROM ' || 
               dbms_assert.enquote_name(user_names(i), FALSE);
  END LOOP; 
END; 
/ 
  
Rem *************************************************************************
Rem END Changes for DB Privileges
Rem *************************************************************************

Rem *************************************************************************
Rem Triton Security changes - BEGIN
Rem *************************************************************************

Rem drop old views
drop view V$XS_SESSION;
drop view V$XS_SESSION_ATTRIBUTE;
drop view XS_SESSION_ROLES;

drop view ALL_XSC_SECURITY_CLASS;
drop view ALL_XSC_SECURITY_CLASS_STATUS;
drop view ALL_XSC_SECURITY_CLASS_DEP;
drop view ALL_XSC_PRIVILEGE;
drop view ALL_XSC_AGGREGATE_PRIVILEGE;

drop view ALL_XS_RPINCIPALS;
drop view ALL_XS_USERS;
drop view ALL_XS_REGULAR_ROLES;
drop view ALL_XS_DYNAMIC_ROLES;
drop view ALL_XS_FUNCTION_ROLES;
drop view ALL_XS_EXTERNAL_PRINCIPALS;

drop view ALL_XS_ROLEGRANTS;
drop view ALL_XS_PROXYROLES;

drop view ALL_XS_ROLESETS;
drop view ALL_XS_ROLESET_ROLES;

drop view ALL_XS_NS_TEMPLATES;
drop view ALL_XS_NS_TEMPLATE_ATTRIBUTES;

drop view ALL_XS_SECURITY_CLASSES;
drop view ALL_XS_SECURITY_CLASS_DEP;
drop view ALL_XS_PRIVILEGES;
drop view ALL_XS_AGGREGATE_PRIVILEGES;

drop view ALL_XS_ACLS;
drop view ALL_XS_ACES;

drop view DBA_XS_OBJECTS;
drop view ALL_XDS_OBJECTS;
drop view USER_XDS_OBJECTS;

drop view DBA_XS_ATTRIBUTE_SECS;
drop view ALL_XDS_ATTRIBUTE_SECS;
drop view USER_XDS_ATTRIBUTE_SECS;

drop view DBA_XS_INSTANCE_SETS;

Rem drop old synonyms
drop public synonym V$XS_SESSION;
drop public synonym V$XS_SESSION_ROLE;
drop public synonym V$XS_SESSION_ATTRIBUTE;
drop public synonym XS_SESSION_ROLES;

drop public synonym ALL_XSC_SECURITY_CLASS;
drop public synonym ALL_XSC_SECURITY_CLASS_STATUS;
drop public synonym ALL_XSC_SECURITY_CLASS_DEP;
drop public synonym ALL_XSC_PRIVILEGE;
drop public synonym ALL_XSC_AGGREGATE_PRIVILEGE;
drop public synonym DBMS_XS_UTIL;

drop public synonym DBMS_XS_NSLIST;
drop public synonym DBMS_XS_ATTRLIST;
drop public synonym DBMS_XS_ATTRVALLIST;
drop public synonym DBMS_XS_ROLELIST;

drop public synonym ALL_XS_RPINCIPALS;
drop public synonym ALL_XS_USERS;
drop public synonym ALL_XS_REGULAR_ROLES;
drop public synonym ALL_XS_DYNAMIC_ROLES;
drop public synonym ALL_XS_FUNCTION_ROLES;
drop public synonym ALL_XS_EXTERNAL_PRINCIPALS;

drop public synonym ALL_XS_ROLEGRANTS;
drop public synonym ALL_XS_PROXYROLES;

drop public synonym ALL_XS_ROLESETS;
drop public synonym ALL_XS_ROLESET_ROLES;

drop public synonym ALL_XS_NS_TEMPLATES;
drop public synonym ALL_XS_NS_TEMPLATE_ATTRIBUTES;

drop public synonym ALL_XS_SECURITY_CLASSES;
drop public synonym ALL_XS_SECURITY_CLASS_DEP;
drop public synonym ALL_XS_PRIVILEGES;
drop public synonym ALL_XS_AGGREGATE_PRIVILEGES;

drop public synonym ALL_XS_ACLS;
drop public synonym ALL_XS_ACES;

drop public synonym DBA_XS_OBJECTS;
drop public synonym ALL_XDS_OBJECTS;
drop public synonym USER_XDS_OBJECTS;

drop public synonym DBA_XS_ATTRIBUTE_SECS;
drop public synonym ALL_XDS_ATTRIBUTE_SECS;
drop public synonym USER_XDS_ATTRIBUTE_SECS;

drop public synonym DBA_XS_INSTANCE_SETS;

Rem drop old libraries
drop library DBMS_XSH_LIB;
drop library DBMS_XSU_LIB;
drop library UTL_XS_LIB;

Rem drop old packages
drop package DBMS_XS_MTCACHE_FFI;
drop package DBMS_XS_PRINCIPALS_INT;
drop package XS_UTIL; 
drop package XS$CATVIEW_UTIL;

Rem drop old types
drop type DBMS_XS_NSLIST;
drop type DBMS_XS_ATTRLIST;
drop type DBMS_XS_ATTRVALLIST;
drop type DBMS_XS_ROLELIST;

Rem drop old index
DROP index xs$sessions_i1 ;
DROP index xs$session_roles_i1 ;
DROP index xs$session_appns_i1 ;
DROP index i_xs$sessions1;

Rem DROP old tables
DROP table xs$sessions;
DROP table xs$session_appns;
DROP table xs$session_roles;

Rem *************************************************************************
Rem Triton Security changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for moving v$/gv$ views in catalog to fixed views in kqfv
Rem *************************************************************************

Rem Add a subname '$DEPRECATED$' into obj$ for the catalog v$/gv$ views that
Rem have been moved into kqfv.h, so that the name lookup does not match it
Rem with the catalog view with the same v$/gv$ name. Also set the status to 1
Rem ecuase utlrp cannot recompile them, and they can remain invalid even 
Rem after utlrp.
UPDATE obj$ SET subname = '$DEPRECATED$', status = 1
  WHERE type# = 4 AND namespace = 1 and owner# = 0 AND
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

Rem delete the dependencies for the old catalog views with v$/gv$ prefix
Rem so that they do not get invalidated during catalog/catproc
DELETE FROM dependency$
  WHERE d_obj# IN  (SELECT obj# FROM obj$ WHERE subname = '$DEPRECATED$');

Rem Bug 21080787, 22393016:
Rem Place the fix in c1201000.sql, so that the problem would also be fixed in
Rem any 12.1.0.x databases that had been upgraded from 11.2 without the fix,
Rem and then upgraded to 12.2.
Rem For backport to 12.1.0.1, the following fix would need to be placed here.

Rem   Remove grants for the old catalog views with v$/gv$ prefix
Rem DELETE FROM objauth$
Rem  WHERE obj# IN  (SELECT obj# FROM obj$ WHERE subname = '$DEPRECATED$');

COMMIT;

Rem drop the public synonyms for the old catalog views with v$/gv$ prefix
drop public synonym V$PING;
drop public synonym GV$PING;
drop public synonym V$CACHE;
drop public synonym GV$CACHE;
drop public synonym V$FALSE_PING;
drop public synonym GV$FALSE_PING;
drop public synonym V$CACHE_TRANSFER;
drop public synonym GV$CACHE_TRANSFER;
drop public synonym V$CACHE_LOCK;
drop view v$object_usage;

Rem *************************************************************************
Rem END Changes for moving v$/gv$ views in catalog to fixed views in kqfv
Rem *************************************************************************

Rem *************************************************************************
Rem SQL translation changes - BEGIN
Rem *************************************************************************

Rem
Rem System privileges and audit options
Rem

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-334,
                                           'CREATE SQL TRANSLATION PROFILE', 0);  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-335,
                                           'CREATE ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-336,
                                           'ALTER ANY SQL TRANSLATION PROFILE', 0);

EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-337,
                                           'USE ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-338,
                                           'DROP ANY SQL TRANSLATION PROFILE', 0);  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (334,
                                            'CREATE SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (335,
                                            'CREATE ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (336,
                                            'ALTER ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (337,
                                            'USE ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (338,
                                            'DROP ANY SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (339,
                                            'SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (348,
                                            'ALTER SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (349,
                                            'GRANT SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (385,
                                            'USE SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (386,
                                           'DROP SQL TRANSLATION PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/


BEGIN
  insert into AUDIT_ACTIONS values (140, 'CREATE SQL TXLN PROFILE');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into AUDIT_ACTIONS values (141, 'ALTER SQL TXLN PROFILE');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into AUDIT_ACTIONS values (142, 'USE SQL TXLN PROFILE');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into AUDIT_ACTIONS values (143, 'DROP SQL TXLN PROFILE');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem SQL translation changes - END
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for mlog$ on 12.0
Rem*************************************************************************

alter table mlog$ add (partdobj# number default 0);

Rem*************************************************************************
Rem END Changes for mlog$
Rem*************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for refresh operations of AJVs
Rem *************************************************************************

Rem  Set status of AJVs to regenerate refresh
Rem  operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE (bitand(s.flag, 4096) = 4096 OR
        bitand(s.flag, 8192) = 8192 OR
        bitand(s.flag, 16384) = 16384) AND
       bitand(s.flag, 512) = 0 AND bitand(s.flag, 32768) = 0 AND
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete old fast refresh operations for AJVs
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

Rem *************************************************************************
Rem END Changes for refresh operations of AJVs
Rem *************************************************************************

Rem *************************************************************************
Rem Flashback Archive - BEGIN
Rem *************************************************************************

Rem The flashback archive dictionary tables have been moved to dfba.bsq from
Rem ktfa.c. So if the tables do not already exist in the earlier version of
Rem the database, we need to create them on upgrade, since the ktfa.c code
Rem will no longer create them on database open


declare
  cnt number := 0;
begin
  -- lookup obj$ to check if the FBA tables exist in dictionary 
  select count(*) into cnt from obj$
    where name in ('SYS_FBA_FA', 'SYS_FBA_TSFA', 'SYS_FBA_TRACKEDTABLES',
                   'SYS_FBA_USERS', 'SYS_FBA_BARRIERSCN', ' SYS_FBA_DL',
                   'SYS_MFBA_STAGE_RID', 'SYS_MFBA_TRACKED_TXN',
                   'SYS_MFBA_NROW', 'SYS_MFBA_NCHANGE', 'SYS_MFBA_NTCRV');

  -- if the tables do not exist, then create them now. otherwise, do nothing
  if (cnt != 11) then

    -- SYS_FBA_FA
    execute immediate
     q'#create table SYS_FBA_FA
        ( FANAME varchar2(255) not null unique,
        FA# number,
        RETENTION number not null,
        CREATESCN number,
        PURGESCN number,
        FLAGS number not null,
        SPARE1 number,
        SPARE2 number,
        OWNERNAME varchar2(30),
        primary key (FA#)) #';

    -- SYS_FBA_TSFA
    execute immediate
     q'#create table SYS_FBA_TSFA
        ( FA# number not null,
          TS# number not null,
          QUOTA number not null,
          FLAGS number not null,
          SPARE number,
          primary key (FA#, TS#)) #';

    -- SYS_FBA_TRACKEDTABLES
    execute immediate
     q'#create table SYS_FBA_TRACKEDTABLES
        ( OBJ# number not null unique,
          FA# number not null,
          DROPSCN number,
          OBJNAME varchar2(30),
          OWNERNAME varchar2(30),
          FLAGS number,
          SPARE number ) #';

    -- SYS_FBA_PARTITIONS
    execute immediate
     q'#create table SYS_FBA_PARTITIONS
        ( OBJ# number,
          PARTITIONSCN number not null,
          FLAGS number,
          SPARE number) #';

    -- SYS_FBA_USERS
    execute immediate
     q'#create table SYS_FBA_USERS
        ( FA# number,
          USER# number not null,
          FLAGS number,
          unique (FA#, USER#)) #';

    -- SYS_FBA_BARRIERSCN
    execute immediate
     q'#create table SYS_FBA_BARRIERSCN
        ( INST_ID number unique not null,
          BARRIERSCN number not null,
          ACTIVESCN number not null,
          STATUS number not null,
          SPARE number) #';

    -- SYS_FBA_DL
    execute immediate
     q'#create table SYS_FBA_DL
        ( OBJN number, LROWID varchar2(20),
          HROWID varchar2(20),
          USN number,
          SLOT number,
          SEQ number,
          CSCN number) #';

    -- SYS_MFBA_STAGE_RID
    execute immediate
     q'#create global temporary table SYS_MFBA_STAGE_RID
        ( OBJN number,
          RID varchar(4000),
          ESCN number)
         ON COMMIT PRESERVE ROWS #';

    -- SYS_MFBA_TRACKED_TXN
    execute immediate
     q'#create global temporary table SYS_MFBA_TRACKED_TXN
        ( USN number,
          SLOT number,
          SEQ number)
         ON COMMIT PRESERVE ROWS #';

    -- SYS_MFBA_NROW
    execute immediate
     q'#create global temporary table SYS_MFBA_NROW
        ( RID varchar(4000) )
         ON COMMIT PRESERVE ROWS #';

    -- SYS_MFBA_NCHANGE
    execute immediate
     q'#create global temporary table SYS_MFBA_NCHANGE
        ( RID varchar(4000),
          ESCN number)
          ON COMMIT PRESERVE ROWS #';

    -- SYS_MFBA_NTCRV
    execute immediate
     q'#create global temporary table SYS_MFBA_NTCRV
        ( RID varchar2(4000),
          STARTSCN number,
          ENDSCN number,
          XID raw(8),
          OP varchar2(1))
         ON COMMIT PRESERVE ROWS #';
  end if;
end;
/

Rem
Rem New Tables for Flashback Archive
Rem

-- SYS_FBA_CONTEXT
create table SYS_FBA_CONTEXT
( XID raw(8), 
  NAMESPACE varchar2(30), 
  PARAMETER varchar2(30), 
  VALUE varchar2(256))
/

-- SYS_FBA_CONTEXT_AUD
create table SYS_FBA_CONTEXT_AUD
( XID raw(8),
  ACTION varchar2(256),
  AUTHENTICATED_IDENTITY varchar2(256),
  CLIENT_IDENTIFIER varchar2(256),
  CLIENT_INFO varchar2(256),
  CURRENT_EDITION_NAME varchar2(256),
  CURRENT_SCHEMA varchar2(256),
  CURRENT_USER varchar2(256),
  DATABASE_ROLE varchar2(256),
  DB_NAME varchar2(256),
  GLOBAL_UID varchar2(256),
  HOST varchar2(256),
  IDENTIFICATION_TYPE varchar2(256),
  INSTANCE_NAME varchar2(256),
  IP_ADDRESS varchar2(256),
  MODULE varchar2(256),
  OS_USER varchar2(256),
  SERVER_HOST varchar2(256),
  SERVICE_NAME varchar2(256),
  SESSION_EDITION_NAME varchar2(256),
  SESSION_USER varchar2(256),
  SESSION_USERID varchar2(256),
  SESSIONID varchar2(256),
  TERMINAL  varchar2(256),
  SPARE  varchar2(256))
/

-- SYS_FBA_CONTEXT_LIST
create table SYS_FBA_CONTEXT_LIST
( NAMESPACE varchar2(30), 
  PARAMETER varchar2(30))
/

-- SYS_FBA_APP
create table SYS_FBA_APP
( APPNAME varchar2(255) not null,
  APP# number,
  FA# number,
  flags number,
  spare number)
/ 

-- SYS_FBA_APP_TABLES
create table SYS_FBA_APP_TABLES
( obj# number not null,
  APP# number,
  flags number,
  spare number)
/

-- SYS_FBA_COLS
create table SYS_FBA_COLS
(
  obj# number not null,
  columnname varchar2(255) not null,
  flags number,
  spare number)
/

-- SYS_FBA_PERIODS
create table SYS_FBA_PERIOD
(
  obj# number not null,
  periodname varchar2(255) not null,
  flags number,
  periodstart varchar2(255) not null,
  periodend varchar2(255) not null,
  spare number)
/

Rem *************************************************************************
Rem Flashback Archive - END
Rem *************************************************************************

Rem *************************************************************************
Rem Cursor Replay Context Changes - BEGIN
Rem *************************************************************************


BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-344, 'KEEP DATE TIME', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-345, 'KEEP SYSGUID', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (344, 'KEEP DATE TIME', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (345, 'KEEP SYSGUID', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

update STMT_AUDIT_OPTION_MAP set option# = 53 where NAME = 'INDEX';
update sys.audit$ set option# = 53 where option# = 19;

Rem *************************************************************************
Rem Cursor Replay Context Changes - END
Rem *************************************************************************


Rem =========================================================================
Rem BEGIN Optimizer findings and directives
Rem =========================================================================

Rem Following table stores the information about optimizer findings. 
Rem The table contains 1 row per finding. The f_id is generated by
Rem hashing object number of objects (and intcol# if columns in finding)   
Rem involved in the finding.
Rem
create table opt_finding$
( f_own#               number not null,            /* owner of the finding */
  f_id                 number not null,               /* id of the finding */
  type                 number not null,   
                              /* type of the finding, please see qosdFType */
  reason               number not null, 
                        /* reason for the finding,  please see qosdFReason */
  ctime                date not null,                /* creation timestamp */
  tab_cnt              number not null  /* number of tables in the finding */
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of the finding given an id.
Rem
create unique index i_opt_finding_f_id on 
  opt_finding$(f_id)
  tablespace sysaux
/

Rem Following table stores the objects (tables, columns, table functons etc) 
Rem in the findings. Number of rows for each finding in this table will be 
Rem equal to the number of objects referenced in the finding.  Columns are 
Rem stored in a bitvector in a single row corresponding to the parent object
Rem (table).
Rem
create table opt_finding_obj$
( f_id                 number not null,               /* id of the finding */
  f_obj#               number not null,   
                              /* object number of an object in the finding */
  obj_type             number not null,              /* type of the object */
  col_list             raw(128),  
     /* bit vector of columns of the object (only for objects with columns */
  cvec_size            number not null,        /* size of above bit vector */
  flags                number not null     
                                 /* various flags, please see flg_qosdFObj */
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of all tables in a finding.
Rem Note that the following index is not unique since the finding can be
Rem for a self join and will have same object number for both objects.
Rem
create index i_opt_finding_obj_id_obj_type on 
  opt_finding_obj$(f_id, f_obj#, obj_type)
  tablespace sysaux
/

Rem Following table stores the information about directive owner. The table
Rem contains 1 row per directive owner.
Rem
create table opt_directive_own$
( dir_own#             number not null,      /* object number of the owner */
  dir_cnt              number        /* number of directives for the owner */
) Tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of the owner given owner object number.
Rem
create unique index i_opt_directive_own# on 
  opt_directive_own$(dir_own#)
  tablespace sysaux
/

Rem Following table stores the information about directive. The table
Rem contains 1 row per directive.
Rem
create table opt_directive$
( dir_own#             number not null,      /* object number of the owner */ 
  dir_id               number not null,             /* id of the directive */
  f_id                 number not null, /* id of the corresponding finding */
  type                 number not null,   
                          /* type of the directive, please see qosdDirType */
  state                number not null,       
                        /* state of the directive, please see qosdDirState */
  flags                number not null,  
                                  /* various flags, please see flg_qosdDir */
  created              date not null,                     /* creation time */
  last_modified        date,                         /* last modified time */
  last_used            date,                             /* last used time */
  /* Following are generic spare variables. We will be able to store 
   * different type of information for different type of directives.
   */
  num_one              number,
  num_two              number,
  num_three            number,
  vc_one               varchar2(4000),
  vc_two               varchar2(4000),
  vc_three             varchar2(4000),
  cl_one               clob
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of all the directives given owner.
Rem
create unique index i_opt_directive_own#_id on 
  opt_directive$(dir_own#, dir_id)
  tablespace sysaux
/

Rem Index that allows fast purging of directives that are not used for 
Rem long time.
Rem
create  index i_opt_directive_last_used on 
  opt_directive$(last_used)
  tablespace sysaux
/

Rem =========================================================================
Rem END Optimizer findings and directives
Rem =========================================================================

Rem =========================================================================
Rem Begin Optimizer calibration statistics
Rem =========================================================================

Rem 
Rem This table contains the calibration statistics of IO and CPU
Rem 
Rem Columns            Description
Rem ---------------------------------------------------------------
Rem statid#            id of the statistic
Rem statvalue          value of the statistic
Rem timestamp          timestamp of the statistic creation
Rem origin             origin of the statistic
Rem properties         flags associated with the statistic
Rem 
create table opt_calibration_stats$
(
  statid#           number not null,               /* id of the statistic */
  statvalue         double precision,           /* value of the statistic */
  timestamp         date,          /* timestamp of the statistic creation */
  origin            number,                    /* origin of the statistic */
  properties        number                 /* properties of the statistic */
)
/

create unique index i_opt_calibration_stats$ on
  opt_calibration_stats$ (statid#, origin, properties)
/

Rem =========================================================================
Rem End Optimizer calibration statistics
Rem =========================================================================
    
Rem *************************************************************************
Rem AWR report accessibility changes - BEGIN
Rem *************************************************************************

alter type AWRRPT_HTML_TYPE modify attribute output varchar2(8000 CHAR) 
        cascade;

Rem *************************************************************************
Rem AWR report accessibility changes - END
Rem *************************************************************************


Rem *************************************************************************
Rem Longer Identifiers - BEGIN
Rem *************************************************************************

--File plsql/admin/diutil.sql

begin
  execute immediate 'alter table sys.pstubtbl modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.pstubtbl modify lun varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catadvtb.sql

begin
  execute immediate 'alter table wri$_adv_definitions modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_def_parameters modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_tasks modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_tasks modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_tasks modify advisor_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_tasks modify last_exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_tasks modify source varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_parameters modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_executions modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_exec_parameters modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_exec_parameters modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_objects modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_findings modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_inst_fdg modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_recommendations modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_actions modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_rationale modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_directive_defs modify domain varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_directive_defs modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_directive_instances modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_journal modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_message_groups modify exec_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlt_plan_hash modify exec_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlt_plans modify object_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlt_plans modify object_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlt_plans modify object_alias VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlt_plans modify qblock_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catalrt.sql

begin
  execute immediate 'alter table wri$_alert_outstanding modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify subobject_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify action_argument_1 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify action_argument_2 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify action_argument_3 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify action_argument_4 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify action_argument_5 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_outstanding modify user_id VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify subobject_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify action_argument_1 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify action_argument_2 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify action_argument_3 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify action_argument_4 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify action_argument_5 VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_alert_history modify user_id VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catawrtb.sql

begin
  execute immediate 'alter table WRH$_SQLSTAT modify parsing_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SQL_PLAN modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SQL_PLAN modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SQL_PLAN modify object_alias varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SQL_PLAN modify qblock_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SQL_BIND_METADATA modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SEG_STAT_OBJ modify owner varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SEG_STAT_OBJ modify object_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SEG_STAT_OBJ modify subobject_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SEG_STAT_OBJ modify base_object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_SEG_STAT_OBJ modify base_object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_STREAMS_CAPTURE modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_STREAMS_APPLY_SUM modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_QUEUES modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_QUEUES modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_SUBSCRIBERS modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_SUBSCRIBERS modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_SUBSCRIBERS modify subscriber_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_BUFFERED_SUBSCRIBERS modify subscriber_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_QUEUES modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_QUEUES modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_SUBSCRIBERS modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_SUBSCRIBERS modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_SUBSCRIBERS modify subscriber_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_PERSISTENT_SUBSCRIBERS modify subscriber_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_RULE_SET modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_RULE_SET modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_RSRC_CONSUMER_GROUP modify consumer_group_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRH$_RSRC_PLAN modify plan_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRM$_SNAP_ERROR modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catcapi.sql

begin
  execute immediate 'alter table sys.dbfs$_stores modify s_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs$_stores modify p_pkg varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

drop index sys.is_dbfs$_mounts;
begin
  execute immediate 'alter table sys.dbfs$_mounts modify s_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate '
create unique index sys.is_dbfs$_mounts
    on
    sys.dbfs$_mounts(decode(s_mount, null, s_owner, null))';
exception when others then null;
end;
/

begin
  execute immediate 'alter table sys.dbfs$_stats modify s_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_sfs$_tab modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_sfs$_tab modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_sfs$_tab modify ptable_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_sfs$_fs modify store_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catchnf.sql

begin
  execute immediate 'alter table invalidation_registry$ modify plsqlcallback varchar2(257)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table invalidation_registry$ modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catdefrt.sql

begin
  execute immediate 'alter table system.def$_calldest modify schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.def$_calldest modify package_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.def$_propagator modify username VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catdpb.sql

begin
  execute immediate 'alter table sys.ku_noexp_tab modify schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.ku_noexp_tab modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.ku$_list_filter_temp_2 modify object_schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catdwgrd.sql

begin
  execute immediate 'alter table ityp$temp1 modify ityp_own varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ityp$temp1 modify typ_own varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/caths.sql

begin
  execute immediate 'alter table hs$_base_dd modify dd_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catlmnr.sql

begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTLO modify OWNERNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTLO modify LVL0NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTLO modify LVL1NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTLO modify LVL2NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTCS modify COLNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTCS modify TYPENAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRC_GTCS modify XTYPESCHEMANAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_SEED$ modify SCHEMANAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_SEED$ modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_SEED$ modify COL_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_DICTIONARY$ modify DB_CHARACTER_SET VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_OBJ$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_OBJ$ modify SUBNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_OBJ$ modify REMOTEOWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_COL$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_USER$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_TYPE$ modify version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_ATTRIBUTE$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_KOPM$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_PROPS$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catlsby.sql

begin
  execute immediate 'alter table system.logstdby$scn modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$skip modify statement_opt varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$skip modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$skip modify name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$skip modify proc varchar2(392)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify shadow_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify base_trigger_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify shadow_trigger_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify mview_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify mview_log_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logstdby$eds_tables modify mview_trigger_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catol.sql

begin
  execute immediate 'alter table system.ol$ modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$ modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$ modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$hints modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$hints modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$hints modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$hints modify user_table_name varchar2(260)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$nodes modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.ol$nodes modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catpexe.sql

begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify TABLE_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify NUMBER_COLUMN VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify JOB_PREFIX VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify EDITION VARCHAR2(130)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify APPLY_CROSSEDITION_TRIGGER VARCHAR2(130)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify JOB_CLASS VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_CHUNKS$ modify JOB_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catplan.sql

begin
  execute immediate 'alter table plan_table$ modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table plan_table$ modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table plan_table$ modify object_alias varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catpspi.sql

begin
  execute immediate 'alter table sys.dbfs_hs$_fs modify store_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_hs$_fs modify store_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_hs$_property modify store_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_hs$_property modify store_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.dbfs_hs$_property modify prop_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catqueue.sql

begin
  execute immediate 'alter table system.aq$_queue_tables modify schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.aq$_queue_tables modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.aq$_queues modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify queue_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify rule_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify trans_name VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify ruleset_name VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_subscriber_table modify negative_ruleset_name VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_schedules modify job_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_message_types modify schema_name VARCHAR(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_message_types modify queue_name VARCHAR(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.aq$_message_types modify trans_name VARCHAR2(257)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aq$_publisher modify p_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aq$_publisher modify p_rule_name VARCHAR2(257)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aq$_publisher modify p_ruleset VARCHAR2(257)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aq$_publisher modify p_transformation VARCHAR2(257)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.AQ$_Internet_Agents modify agent_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.AQ$_Internet_Agent_Privs modify agent_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.AQ$_Internet_Agent_Privs modify db_username VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catrepc.sql

begin
  execute immediate 'alter table system.repcat$_repcat modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_flavors modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repschema modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_snapgroup modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repobject modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repobject modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repobject modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify cname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify ctype_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify ctype_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcolumn modify top VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_key_columns modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_key_columns modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_key_columns modify col VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify base_sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify base_oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify package_prefix VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_generated modify procedure_prefix VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repprop modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repprop modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcatlog modify userid VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcatlog modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repcatlog modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repgroup_privs modify username VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_repgroup_privs modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_column_group modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_column_group modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_grouped_column modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_grouped_column modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_grouped_column modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_conflict modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_conflict modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_conflict modify reference_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution modify reference_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution modify function_name varchar2(386)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution_statistics modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution_statistics modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution_statistics modify reference_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resolution_statistics modify function_name varchar2(386)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resol_stats_control modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_resol_stats_control modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_parameter_column modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_parameter_column modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_parameter_column modify reference_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_parameter_column modify parameter_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_attribute modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_attribute modify source varchar2(386)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify base_sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify base_oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify base_reference_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_audit_column modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_flavor_objects modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_flavor_objects modify sname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_flavor_objects modify oname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_refresh_templates modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_objects modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_objects modify derived_from_sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_objects modify derived_from_oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_objects modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_parms modify parameter_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_sites modify template_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_template_sites modify user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_site_objects modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_site_objects modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_runtime_parms modify parameter_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_exceptions modify user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.repcat$_sites_new modify gowner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catrept.sql

begin
  execute immediate 'alter table wri$_rept_components modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_rept_reports modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_rept_formats modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

-- truncate wri$_rept_components table to avoid errors during
-- creation of new subtypes
begin
   execute immediate 'truncate table sys.wri$_rept_components';
exception 
  when others then
    if sqlcode = -942 
      then NULL;
    else
      raise;
    end if;
end;
/


alter type wri$_rept_abstract_t add member function get_report_with_summary(
    report_reference IN VARCHAR2) return xmltype cascade;

alter type wri$_rept_sqlmonitor 
  add overriding member function get_report_with_summary(
        report_reference IN VARCHAR2) return xmltype cascade;

--File rdbms/admin/catrule.sql

begin
  execute immediate 'alter table sys.rule_set_ieuac$ modify client_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.rule$ modify uactx_client varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.rec_tab$ modify tab_alias varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.rec_var$ modify var_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.rule_set_fob$ modify opexpr_c1 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.rule_set_nl$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsch.sql

begin
  execute immediate 'alter table sys.scheduler$_class modify res_grp_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify event_rule varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify user_callback varchar2(386)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify credential_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify credential_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job modify fw_name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lwjob_obj modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lwjob_obj modify subname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify event_rule varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify fw_name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify credential_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_lightweight_job modify credential_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_job_argument modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_window modify res_plan varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_window modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_program_argument modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_srcq_info modify ruleset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_evtq_sub modify agt_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_evtq_sub modify uname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_event_log modify name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_event_log modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_event_log modify user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_event_log modify credential varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_job_run_details modify session_id varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_job_run_details modify credential varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_schedule modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_schedule modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_schedule modify queue_agent varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_schedule modify fw_name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_chain modify rule_set varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_chain modify rule_set_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify var_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify object_name varchar2(392)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify queue_agent varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify credential_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step modify credential_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_step_state modify step_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_credential modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.scheduler$_rjob_src_db_info modify source_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_filewatcher_resend modify fw_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_filewatcher_resend modify fw_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_notification modify job_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_notification modify job_subname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_notification modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table scheduler$_job_destinations modify credential VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/


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
    allow_runs_in_restricted_mode IN BOOLEAN DEFAULT FALSE
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
    allow_runs_in_restricted_mode IN BOOLEAN DEFAULT FALSE,
    restart_on_recovery     IN     BOOLEAN DEFAULT FALSE,
    restart_on_failure      IN     BOOLEAN DEFAULT FALSE,
    connect_credential_name IN     VARCHAR2 DEFAULT NULL,
    store_output            IN     BOOLEAN DEFAULT TRUE
  )
  RETURN SELF AS RESULT CASCADE;

ALTER TYPE job_definition ADD ATTRIBUTE
 (restart_on_recovery varchar2(5),    
  restart_on_failure varchar2(5),
  connect_credential_name varchar2(65),
  store_output varchar2(5)) CASCADE;

ALTER TYPE job_definition MODIFY ATTRIBUTE job_style varchar2(17) CASCADE;
--File rdbms/admin/catspace.sql

begin
  execute immediate 'alter table wri$_segadv_objlist modify segment_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_segadv_objlist modify segment_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_segadv_objlist modify partition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsqlt.sql

begin
  execute immediate 'alter table wri$_adv_sqlt_rtn_plan modify exec_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_definitions modify name VARCHAR(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_definitions modify owner VARCHAR(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_references modify owner VARCHAR(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_statements modify parsing_schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_plans modify parsing_schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_sts_topack modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_sts_topack modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_plan_lines modify object_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_plan_lines modify object_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_plan_lines modify object_alias VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_plan_lines modify qblock_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace modify workspace_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace modify sqlset_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace_plans modify object_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace_plans modify object_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace_plans modify object_alias VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_sqlset_workspace_plans modify qblock_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsqltk.sql

begin
  execute immediate 'alter table SQL_TK_COLL_CHK$ modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SQL_TK_ROW_CHK$ modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SQL_TK_REF_CHK$ modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SQL_TK_REF_CHK$ modify pk_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SQL_TK_TAB_DESC$ modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsscr.sql

begin
  execute immediate 'alter table sscr_cap$ modify directory varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sscr_res$ modify directory varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catstrt.sql

begin
  execute immediate 'alter table streams$_internal_transform modify rule_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify rule_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify from_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify to_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify from_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify to_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_internal_transform modify column_function varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsum.sql

begin
  execute immediate 'alter table system.mview$_adv_workload modify application varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_workload modify uname varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_basetable modify owner varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_basetable modify table_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_sqldepend modify to_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_log modify uname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_level modify levelname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_output modify summary_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_output modify summary_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_exceptions modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_exceptions modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_exceptions modify dimension_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_parameters modify parameter_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_plan modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.mview$_adv_plan modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catsumat.sql

begin
  execute immediate 'alter table wri$_adv_sqlw_stmts modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlw_tables modify table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlw_tables modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlw_tabvol modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqlw_tabvol modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_map modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_tables modify table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_tables modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_tabvol modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_tabvol modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_fake_reg modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table wri$_adv_sqla_fake_reg modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/cattlog.sql

begin
  execute immediate 'alter table CLI_LOG$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/cattrans.sql

begin
  execute immediate 'alter table transformations$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table transformations$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table transformations$ modify from_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table transformations$ modify from_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table transformations$ modify to_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table transformations$ modify to_type varchar2(256)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catts.sql

begin
  execute immediate 'alter table xs$prin modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$prin modify profile varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$prin modify credential varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$prin modify powner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$prin modify pname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$prin modify pfname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$instset_inh modify parent_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$instset_inh modify parent_object varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$instset_inh_key modify pkey varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$olap_policy modify schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$olap_policy modify logical_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$nstmpl modify hschema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$nstmpl modify hpname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xs$nstmpl modify hfname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rxs$session_appns modify nshandler varchar2(400)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catupstr.sql

begin
  execute immediate 'alter table registry$log modify cid VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table registry$log modify namespace VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catwrrtbc.sql

begin
  execute immediate 'alter table WRR$_FILTERS modify filter_type varchar2(30)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_FILTERS modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_FILTERS modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify dbversion varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify directory varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify last_prep_version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify sqlset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_CAPTURES modify sqlset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catwrrtbp.sql

begin
  execute immediate 'alter table WRR$_REPLAYS modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAYS modify dbversion varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAYS modify directory varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAYS modify sqlset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAYS modify sqlset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAY_SEQ_DATA modify seq_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAY_SEQ_DATA modify seq_bnm varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_REPLAY_SEQ_DATA modify seq_bow varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_SEQUENCE_EXCEPTIONS modify sequence_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table WRR$_SEQUENCE_EXCEPTIONS modify sequence_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catxdbpi.sql

begin
  execute immediate 'alter table xdb.xdb$path_index_params modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/catxidx.sql

begin
  execute immediate 'alter table XDB.XDB$XIDX_IMP_T modify index_name VARCHAR2(138)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table XDB.XDB$XIDX_IMP_T modify schema_name VARCHAR2(138)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table XDB.XDB$XIDX_PARAM_T modify param_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/daw.bsq

begin
  execute immediate 'alter table olap_aw_deployment_controls$ modify physical_name varchar2(288)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_descriptions$ rename column spare1 to description_order';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_impl_options$ rename column spare3 to option_long_value';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_mappings$ rename column spare2 to map_order';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_mappings$ add (spare2 number)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_descriptions$ add (spare1 number)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_impl_options$ add (spare3 varchar2(1000))';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

create table olap_metadata_properties$
(
 top_obj# number not null,              /* id of top level object of property */
 owning_object_id number not null,                        /* owning object ID */
 owning_type number not null,                           /* owning object type */
 property_id number not null,                                  /* property ID */
 property_key varchar2(30) not null,                  /* M_IDEN, property key */
 property_value clob,                      /* property value stored in a clob */
 property_order number not null,                            /* property order */
 owning_type2 number,                   /* owning type for objects with no ID */
 owning_object_id2 number,            /* owning object ID for the IDless objs */
 spare1 number,
 spare2 number,
 spare3 varchar2(1000),
 spare4 varchar2(1000)
)
/

create unique index i_olap_metadata_properties on olap_metadata_properties$ 
  (owning_object_id, owning_type, owning_type2, owning_object_id2, 
   property_order)
/
create unique index i2_olap_metadata_properties on olap_metadata_properties$ 
  (owning_object_id, owning_type, owning_type2, owning_object_id2, property_key)
/
create unique index i3_olap_metadata_properties on olap_metadata_properties$
  (property_id)
/

create table olap_metadata_dependencies$
(
 d_top_obj# number not null,            /* dependent top-level object ID */
 d_sub_obj# number,                     /* dependent sub-object ID */
 d_obj_type number not null,            /* type of the dependent object */
 p_obj# number,                         /* referenced object ID */
 p_obj_type number,                     /* type of the referenced object */
 p_owner varchar2(30) not null,         /* owner of the referenced object */
 p_top_obj_name varchar2(30) not null,  /* top-level obj name of the 
                                           referenced object */
 p_sub_obj_name1 varchar2(30),          /* first sub-obj name of the referenced
                                           object */
 p_sub_obj_name2 varchar2(30),          /* second sub-obj name of the referenced
                                           object */
 p_sub_obj_name3 varchar2(30),          /* third sub-obj name of the referenced
                                           object */
 p_sub_obj_name4 varchar2(30),          /* fourth sub-obj name of the referenced
                                           object */
 dep_type number,                       /* type of dependency relationship */
 spare1 number, 
 spare2 number,
 spare3 varchar2(1000),
 spare4 varchar2(1000)
)
/

--File rdbms/admin/dbmshsld.sql

begin
  execute immediate 'alter table HS_BULKLOAD_VIEW_OBJ modify SCHEMA_NAME varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table HS_BULKLOAD_VIEW_OBJ modify VIEW_NAME varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify remote_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify remote_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify hist_column varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify hist_column_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify sample_column varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_metadata modify sample_column_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_partition_data modify remote_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_partition_data modify remote_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_histogram_data modify remote_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_histogram_data modify remote_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_sample_data modify remote_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hs$_parallel_sample_data modify remote_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/dbmsplts.sql

begin
  execute immediate 'alter table sys.tts_usr$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/dlmnr.bsq

begin
  execute immediate 'alter table system.logmnr_gt_tab_include$ modify schema_name varchar2(130)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logmnr_gt_tab_include$ modify table_name varchar2(130)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table system.logmnr_gt_user_include$ modify user_name varchar2(130)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/doptim.bsq

begin
  execute immediate 'alter table outln.ol$hints modify user_table_name varchar2(260)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/dpart.bsq

begin
  execute immediate 'alter table defsubpart$ modify spart_name varchar2(132)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table defsubpartlob$ modify lob_spart_name varchar2(132)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/drep.bsq

begin
  execute immediate 'alter table streams$_component modify component_name varchar2(390)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/dsec.bsq

begin
  execute immediate 'alter table fga_log$ modify clientid varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aclmv$_reflog modify job_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aclmv$_reflog modify acl_status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/mgdtab.sql

begin
  execute immediate 'alter table mgd_id_category_tab modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/sbctab.sql

begin
  execute immediate 'alter table STATS$SQL_PLAN modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SQL_PLAN modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SQL_PLAN modify qblock_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify owner varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify object_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify subobject_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$STREAMS_CAPTURE modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify dst_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify dst_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify src_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify src_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify dst_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify dst_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_QUEUES modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_QUEUES modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$RULE_SET modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$RULE_SET modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/schutl.sql

begin
  execute immediate 'alter table SCHEDUTIL$_TEMP_DIR_LIST modify job_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SCHEDUTIL$_TEMP_DIR_LIST modify schedule_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table schedutil$_schedule_list modify schedule_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table schedutil$_schedule_list modify schedule_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table schedutil$_notifications modify job_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table schedutil$_notifications modify job_subname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table schedutil$_notifications modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/spctab.sql

begin
  execute immediate 'alter table STATS$SQL_PLAN modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SQL_PLAN modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SQL_PLAN modify object_alias varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SQL_PLAN modify qblock_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify owner varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify object_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$SEG_STAT_OBJ modify subobject_name varchar(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$STREAMS_CAPTURE modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify dst_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_SENDER modify dst_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify src_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify src_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify dst_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$PROPAGATION_RECEIVER modify dst_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_QUEUES modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_QUEUES modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_SUBSCRIBERS modify queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_SUBSCRIBERS modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$BUFFERED_SUBSCRIBERS modify subscriber_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$RULE_SET modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table STATS$RULE_SET modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlchain.sql

begin
  execute immediate 'alter table CHAINED_ROWS modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify cluster_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify partition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify subpartition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlchn1.sql

begin
  execute immediate 'alter table CHAINED_ROWS modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify cluster_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify partition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table CHAINED_ROWS modify subpartition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utldim.sql

begin
  execute immediate 'alter table dimension_exceptions modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dimension_exceptions modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dimension_exceptions modify dimension_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utledtol.sql

begin
  execute immediate 'alter table ol$ modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$ modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$ modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$hints modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$hints modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$hints modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$hints modify user_table_name varchar2(260)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$nodes modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ol$nodes modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlexcpt.sql

begin
  execute immediate 'alter table exceptions modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exceptions modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exceptions modify (constraint varchar2(128))';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utloidxs.sql

begin
  execute immediate 'alter table INDEX$INDEX_STATS modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INDEX$INDEX_STATS modify COLUMN_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INDEX$INDEX_STATS modify STAT_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INDEX$BADNESS_STATS modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INDEX$BADNESS_STATS modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlspadv.sql

begin
  execute immediate 'alter table streams$_pa_monitoring modify job_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_pa_monitoring modify query_user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_pa_monitoring modify show_stats_table varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_pa_control modify param_unit varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utltzuv2.sql

begin
  execute immediate 'alter table sys.sys_tzuv2_temptab modify table_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.sys_tzuv2_temptab modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.sys_tzuv2_va_temptab modify table_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.sys_tzuv2_va_temptab modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.sys_tzuv2_va_temptab1 modify va_of_tstz_typ VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlvalid.sql

begin
  execute immediate 'alter table INVALID_ROWS modify owner_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INVALID_ROWS modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INVALID_ROWS modify partition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table INVALID_ROWS modify subpartition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlxaa.sql

begin
  execute immediate 'alter table user_workload modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlxplan.sql

begin
  execute immediate 'alter table PLAN_TABLE modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table PLAN_TABLE modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table PLAN_TABLE modify object_alias varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table PLAN_TABLE modify qblock_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/utlxrw.sql

begin
  execute immediate 'alter table REWRITE_TABLE modify mv_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table REWRITE_TABLE modify mv_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table REWRITE_TABLE modify mv_in_msg VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/admin/xtitab.sql

begin
  execute immediate 'alter table xti$index modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index modify index_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index modify base_table_schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index modify base_table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index modify row_sequence_id VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify index_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify partition_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify index_table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify index_table_pk_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_partition_stats modify index_table_rowid_idx_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_period_stats modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_period_stats modify index_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xti$index_period_stats modify partition_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File rdbms/src/server/dict/sqlddl/prvtrctv.sql

begin
  execute immediate 'alter table utl_recomp_sorted modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table utl_recomp_sorted modify objname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 
    'alter table utl_recomp_sorted modify edition_name varchar2(128)';
exception when others then
  if (sqlcode = -904) then null; end if;
end;
/

--File rdbms/src/server/ilm/assistant/create_meta.sql

begin
  execute immediate 'alter table ilm_toolkit.ilm$_stats_data modify table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_stats_data modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_stats_data modify obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_stats_data modify obj_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_invalid_names modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_invalid_names modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify TABLE_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_TAB_PARTITIONS modify PARTITION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify TABLE_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify PARTITION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_FUT_TAB_PARTITIONS modify PP_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_PART_KEY_COLUMNS modify OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_PART_KEY_COLUMNS modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_PART_TABLES modify OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VIRT_PART_TABLES modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_RULE_STAGES modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISKGROUP modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_RULES modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify PARTITION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify TABLE_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_STAGE_PARTITIONS modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify OBJECT_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify OBJECT_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_POLICY_GROUPS modify POLICY_GROUP VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_EVENTS modify PARTITION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_EVENTS modify TABLE_OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_EVENTS modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_EVENTS modify SEC_PARTITION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_POLICY_CLASS modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_job_info modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_job_info modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_table_cache modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_table_index modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_table_index modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_table_index modify rule_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify TABLENAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES modify KEY_COLUMN VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify TABLENAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_VALID_TABLES_BK modify KEY_COLUMN VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_EVENTS_SCAN modify USERNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_SQLHASH_RESULT_SET modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_SQLHASH_RESULT_SET modify OWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISK modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_TMP_ASM_DISK modify FAILGROUP VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ILM_TOOLKIT.ILM$_POLICY modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify job_name VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify job_subname VARCHAR2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify chain_name varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ilm_toolkit.ilm$_scheduler_job_run_details modify session_id VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--
-- LI Part 2 - BSQ files
--

--File daw.bsq

begin
  execute immediate 'alter table aw$ modify awname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_mappings$ modify map_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_models$ modify model_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_model_assignments$ modify member_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_calculated_members$ modify member_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_descriptions$ modify description_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_dim_levels$ modify level_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_attributes$ modify attribute_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_hierarchies$ modify hierarchy_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table olap_measures$ modify measure_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dcore.bsq

begin
  execute immediate 'alter table ugroup$ modify spare2 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table syn$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table syn$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table typed_view$ modify typeowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table typed_view$ modify typename varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table props$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table edition$ modify spare2 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table migrate$ modify version# varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table viewcon$ modify conname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table ev$ modify base_tbl_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table evcol$ modify base_tbl_col_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pdb_history$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pdb_history$ modify c_pdb_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pdb_history$ modify c_db_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pdb_history$ modify c_db_uname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File ddm.bsq

begin
  execute immediate 'alter table modelatt$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table modelatt$ add (attrspec varchar2(4000))';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File ddst.bsq

begin
  execute immediate 'alter table dst$affected_tables modify table_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dst$affected_tables modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dst$error_table modify table_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dst$error_table modify table_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dst$trigger_table modify trigger_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dst$trigger_table modify trigger_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File denv.bsq

begin
  execute immediate 'alter table profname$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table job$ modify lowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table job$ modify powner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table job$ modify cowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify mgmt_method varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify mast_method varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify pdl_method varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan$ modify que_method varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_consumer_group$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_consumer_group$ modify mgmt_method varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_consumer_group$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_consumer_group$ modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_category$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_category$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan_directive$ modify plan varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan_directive$ modify group_or_subplan varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan_directive$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_plan_directive$ modify switch_group varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_group_mapping$ modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_group_mapping$ modify consumer_group varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_group_mapping$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_mapping_priority$ modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_mapping_priority$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_storage_pool_mapping$ modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_storage_pool_mapping$ modify value varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_storage_pool_mapping$ modify pool_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_storage_pool_mapping$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_capability$ modify io_capable varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_capability$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table resource_instance_capability$ modify status varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dexttab.bsq

begin
  execute immediate 'alter table external_tab$ modify default_dir varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table external_tab$ modify type$ varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table external_location$ modify dir varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dfmap.bsq

begin
  execute immediate 'alter table map_extelement$ modify attrb1_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb1_val varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb2_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb2_val varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb3_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb3_val varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb4_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb4_val varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb5_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_extelement$ modify attrb5_val varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_complist$ modify comp1_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_complist$ modify comp2_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_complist$ modify comp3_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_complist$ modify comp4_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table map_complist$ modify comp5_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File djava.bsq

begin
  execute immediate 'alter table javasnm$ modify short varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dlmnr.bsq

begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTLO modify OWNERNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTLO modify LVL0NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTLO modify LVL1NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTLO modify LVL2NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTCS modify COLNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNRGGC_GTCS modify XTYPESCHEMANAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYSTEM.LOGMNR_PARAMETER$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_SEED$ modify SCHEMANAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_SEED$ modify TABLE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_SEED$ modify COL_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_OBJ$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_OBJ$ modify SUBNAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_OBJ$ modify REMOTEOWNER VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_COL$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_USER$ modify NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_TYPE$ modify version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_ATTRIBUTE$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_KOPM$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table SYS.LOGMNRG_PROPS$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dmanage.bsq

begin
  execute immediate 'alter table smb$config modify parameter_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table smb$config modify updated_by VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sql$text modify sql_handle VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$ modify category VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$ modify name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$data modify category VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$auxdata modify category VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$auxdata modify creator VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$auxdata modify parsing_schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqlobj$auxdata modify task_exec_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

CREATE TABLE sqlobj$plan (
   signature           NUMBER,                                   /* join key */
   category            VARCHAR2(30),                             /* join key */
   obj_type            NUMBER,                                   /* join key */
   plan_id             NUMBER,                                   /* join key */
   statement_id        VARCHAR2(30),
   xpl_plan_id         NUMBER,
   timestamp           DATE,
   remarks             VARCHAR2(4000),
   operation           VARCHAR2(30),
   options             VARCHAR2(255),
   object_node         VARCHAR2(128),
   object_owner        VARCHAR2(128),
   object_name         VARCHAR2(128),
   object_alias        VARCHAR2(261),
   object_instance     NUMBER,
   object_type         VARCHAR2(30),
   optimizer           VARCHAR2(255),
   search_columns      NUMBER,
   id                  NUMBER,
   parent_id           NUMBER,
   depth               NUMBER,
   position            NUMBER,
   cost                NUMBER,
   cardinality         NUMBER,
   bytes               NUMBER,
   other_tag           VARCHAR2(255),
   partition_start     VARCHAR2(255),
   partition_stop      VARCHAR2(255),
   partition_id        NUMBER,
   other               LONG,
   distribution        VARCHAR2(30),
   cpu_cost            NUMBER,
   io_cost             NUMBER,
   temp_space          NUMBER,
   access_predicates   VARCHAR2(4000),
   filter_predicates   VARCHAR2(4000),
   projection          VARCHAR2(4000),
   time                NUMBER,
   qblock_name         VARCHAR2(128),
   other_xml           CLOB,  
   CONSTRAINT sqlobj$plan_pkey PRIMARY KEY (signature,
                                            category,
                                            obj_type,
                                            plan_id,
                                            id)
 )
 TABLESPACE sysaux
/


--File dobj.bsq

begin
  execute immediate 'alter table type$ modify version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table type$ modify typ_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table collection$ modify coll_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table attribute$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table method$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table parameter$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table kopm$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table vtable$ modify itypeowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table vtable$ modify itypename varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify returnschema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify returntype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify impschema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify imptype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify spare1 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table opbinding$ modify spare2 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table indop$ modify filt_nam varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table indop$ modify filt_sch varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table indop$ modify filt_typ varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File doptim.bsq

begin
  execute immediate 'alter table outln.ol$ modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$ modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$ modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$hints modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$hints modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$hints modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$nodes modify ol_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table outln.ol$nodes modify category varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dplsql.bsq

begin
  execute immediate 'alter table procedureinfo$ modify procedurename varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify procedure$ varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify argument varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify type_subname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table argument$ modify pls_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table settings$ modify param varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table procedurejava$ modify ownername varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table plscope_identifier$ modify symrep varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File drac.bsq

begin
  execute immediate 'alter table service$ modify edition varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table service$ modify pdb varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table service$ modify session_state_consistency varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table service$ modify sql_translation_profile varchar2(261)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dir$database_attributes modify attribute_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dir$victim_policy modify user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dir$node_attributes modify attribute_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dir$service_attributes modify attribute_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File drep.bsq

create table mlog2$ as select * from mlog$;
create table slog2$ as select * from slog$;

begin
  execute immediate 'alter table mlog2$ modify mowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog2$ modify master varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog2$ modify log varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog2$ modify trig varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog2$ modify temp_log varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog2$ modify purge_job varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table slog2$ modify mowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table slog2$ modify master varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

rem table to store usage statistics for MV refresh
create table mv_refresh_usage_stats$(
  mv_type#        varchar2(10),
  refresh_method# varchar2(10),
  refresh_mode#   varchar2(10),
  out_of_place#   varchar2(3),
  atomic#         varchar2(3),
  count#          number
)
/

rem insert rows for all combinations along the following dimensions
rem 1. MV type: MAV, MJV, MAV1, OTHER
rem 2. Refresh method: FAST, PCT, COMPLETE, SYNC
rem 3. Refresh mode: ON-DEMAND, ON-COMMIT
rem 4. OUT-OF-PLACE(YES), IN-PLACE(NO)
rem 5. ATOMIC(YES), NON-ATOMIC(NO)

declare
  cmdbuf_1 varchar2 (1000);
  cmdbuf_2 varchar2 (1000);
  cmdbuf_3 varchar2 (1000);
  cmdbuf_4 varchar2 (1000);
  cmdbuf_5 varchar2 (1000);
  cmdbuf varchar2 (1000);
begin
  cmdbuf_1 := 'insert into mv_refresh_usage_stats$(mv_type#, refresh_method#,
refresh_mode#, out_of_place#, atomic#, count#) values (';
  for i in 1..4 loop
    if (i=1) then
      cmdbuf_2 := cmdbuf_1 || '''' || 'MAV' || ''', ';
    elsif (i=2) then
      cmdbuf_2 := cmdbuf_1 || '''' || 'MJV' || ''', ';
    elsif (i=3) then
      cmdbuf_2 := cmdbuf_1 || '''' || 'MAV1' || ''', ';
    else
      cmdbuf_2 := cmdbuf_1 || '''' || 'OTHER' || ''', ';
    end if;

    for j in 1..3 loop
      if (j=1) then
        cmdbuf_3 := cmdbuf_2 || '''' || 'FAST' || ''', ';
      elsif (j=2) then
        cmdbuf_3 := cmdbuf_2 || '''' || 'PCT' || ''', ';
      else
        cmdbuf_3 := cmdbuf_2 || '''' || 'COMPLETE' || ''', ';
      end if;

      for k in 1..2 loop
        if (k=1) then
          cmdbuf_4 := cmdbuf_3 || '''' || 'ON_DEMAND' || ''', ';
        else
          cmdbuf_4 := cmdbuf_3 || '''' || 'ON_COMMIT' || ''', ';
        end if;

        for m in 1..2 loop
          if (m=1) then
            cmdbuf_5 := cmdbuf_4 || '''' || 'YES' || ''', ';
          else
            cmdbuf_5 := cmdbuf_4 || '''' || 'NO' || ''', ';
          end if;

          for n in 1..2 loop
            if (n=1) then
              cmdbuf := cmdbuf_5 || '''' || 'YES' || ''', 0)';
            else
              cmdbuf := cmdbuf_5 || '''' || 'NO' || ''', 0)';
            end if;

            execute immediate cmdbuf;
          end loop;
        end loop;
      end loop;
    end loop;
  end loop;

  execute immediate 'insert into mv_refresh_usage_stats$(mv_type#, 
    refresh_method#,  refresh_mode#, out_of_place#,
    atomic#, count#) values 
   (''MAV'', ''SYNC'', ''ON_DEMAND'', ''NO'', ''NO'', 0)'; 

  execute immediate 'insert into mv_refresh_usage_stats$(mv_type#, 
    refresh_method#,  refresh_mode#, out_of_place#,
    atomic#, count#) values 
   (''MAV1'', ''SYNC'', ''ON_DEMAND'', ''NO'', ''NO'', 0)'; 

  execute immediate 'insert into mv_refresh_usage_stats$(mv_type#, 
    refresh_method#,  refresh_mode#, out_of_place#,
    atomic#, count#) values 
   (''MJV'', ''SYNC'', ''ON_DEMAND'', ''NO'', ''NO'', 0)'; 

  execute immediate 'insert into mv_refresh_usage_stats$(mv_type#, 
    refresh_method#,  refresh_mode#, out_of_place#,
    atomic#, count#) values 
   (''OTHER'', ''SYNC'', ''ON_DEMAND'', ''NO'', ''NO'', 0)'; 
  
  commit;
end;
/

alter system flush shared_pool;

drop index i_slog;
drop table slog$;
drop table mlog$;
drop index i_mlog#;
drop cluster c_mlog# including tables cascade constraints;

create cluster c_mlog# (master varchar2(128), mowner varchar2(128))
/
create index i_mlog# on cluster c_mlog#
/
create table mlog$          /* list of local master tables used by snapshots */
( mowner          varchar2(128) not null,            /* owner of master */
  master          varchar2(128) not null,             /* name of master */
  oldest          date,       /* maximum age of rowid information in the log */
  oldest_pk       date,          /* maximum age of PK information in the log */
  oldest_seq      date,    /* maximum age of sequence information in the log */
  oscn            number,                                   /* scn of oldest */
  youngest        date,                     /* most recent snaptime assigned */
  yscn            number,                   /* set-up scn;  identifies group */
                                          /* of rows set up at time youngest */
  log             varchar2(128) not null,                /* name of log */
  trig            varchar2(128),           /* trigger on master for log */
  flag            number,       /* 0x0001, log contains rowid values         */
                                /* 0x0002, log contains primary key values   */
                                /* 0x0004, log contains filter column values */
                                /* 0x0008, log is imported                   */
                                /* 0x0010, log is created with temp table    */
  mtime           date not null,                    /* DDL modification time */
  temp_log        varchar2(128),/* temp table as updatable snapshot log */
  oldest_oid      date,         /* maximum age of OID information in the log */
  oldest_new      date,              /* maximum age of new values in the log */
  purge_start       date,                                /* purge start date */
  purge_next        varchar2(200),        /* purge next date expression */
  purge_job         varchar2(128),                    /* purge job name */
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
( mowner          varchar2(128) not null,            /* owner of master */
  master          varchar2(128) not null,             /* name of master */
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

/* Bug 12798177: Don't rely on column ordering instead use col names */
insert into mlog$(mowner, master, oldest, oldest_pk, oldest_seq, oscn,
                  youngest, yscn, log, trig, flag, mtime, temp_log, 
                  oldest_oid, oldest_new, purge_start, purge_next, purge_job,
                  last_purge_date,last_purge_status, rows_purged, oscn_pk,
                  oscn_seq, oscn_oid, oscn_new, partdobj#)
   select mowner, master, oldest, oldest_pk, oldest_seq, oscn, 
          youngest, yscn, log, trig, flag, mtime, temp_log,  
          oldest_oid, oldest_new, purge_start, purge_next, purge_job,  
          last_purge_date,last_purge_status, rows_purged, oscn_pk,     
          oscn_seq, oscn_oid, oscn_new, partdobj#
   from mlog2$;
insert into slog$(mowner, master, snapshot, snapid, sscn, snaptime, tscn, user#)
  select mowner, master, snapshot, snapid, sscn, snaptime, tscn, user# 
  from slog2$;
drop table mlog2$;
drop table slog2$;

rem table to store the statistics information for online redefinition
create table redef_track$(
  redef#            number not null primary key,  /* total # of redefinition */
  finish_redef#     number,            /* total # of successful redefinition */
  abort_redef#      number,               /* total # of aborted redefinition */
  pk_redef#         number,              /* total # of PK-based redefinition */
  rowid_redef#      number,           /* total # of rowid-based redefinition */
  part_redef#       number,       /* total # of partition-based redefinition */
  batch_redef#      number,                 /* total # of batch redefinition */
  vpd_auto#         number,         /* total # of auto copy VPD redefinition */
  vpd_manual#       number,       /* total # of manual copy VPD redefinition */
  last_redef_time   date                           /* last redefinition time */
)
/

BEGIN
  insert into redef_track$ (redef#, finish_redef#, abort_redef#, pk_redef#, rowid_redef#,
    part_redef#, batch_redef#,vpd_auto#, vpd_manual#, last_redef_time)
    values(0, 0, 0, 0, 0, 0, 0, 0,  0, null);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

begin
  execute immediate 'alter table snap$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify tname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify mview varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify mowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify master varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify ustrg varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify uslog varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify field2 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify mas_roll_seg varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify sna_type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify sna_type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify mas_type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify mas_type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify parent_sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap$ modify parent_vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_reftime$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_reftime$ modify vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_reftime$ modify mowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_reftime$ modify master varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_reftime$ modify change_view varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog_refcol$ modify mowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog_refcol$ modify master varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table mlog_refcol$ modify colname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_refop$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_refop$ modify vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_colmap$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_colmap$ modify vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_colmap$ modify snacol varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_colmap$ modify mascol varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify vname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify snacol varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify mascol varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify storage_tab_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify storage_tab_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify sna_type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify sna_type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify mas_type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table snap_objcol$ modify mas_type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reg_snap$ modify sowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reg_snap$ modify snapname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgroup$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgroup$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgroup$ modify rollback_seg varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgchild$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgchild$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rgchild$ modify type# varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify source_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify logfile_suffix varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify publisher varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify capqueue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sources$ modify capqueue_tabname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify change_source_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify rollback_segment_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify queue_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify publisher varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify set_sequence varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_sets$ modify time_scn_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify change_set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify source_schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify source_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify change_table_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify change_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify mvl_temp_log varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify mvl_v7trigger varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify mvl_backcompat_view varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_tables$ modify mvl_physmvl varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_subscribers$ modify subscription_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_subscribers$ modify set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_subscribers$ modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_subscribed_tables$ modify view_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_subscribed_columns$ modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_change_columns$ modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagations$ modify propagation_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagations$ modify destqueue_publisher varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagations$ modify destqueue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagations$ modify sourceid_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagated_sets$ modify propagation_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagated_sets$ modify change_set_publisher varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table cdc_propagated_sets$ modify change_set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify original_capture_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify cloned_capture_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify original_queue_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify original_queue_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify cloned_queue_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify cloned_queue_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify original_streams_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify cloned_streams_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify job_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify job_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify schedule_owner VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_split_merge modify schedule_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify QUEUE_SCHEMA VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify QUEUE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify DST_QUEUE_SCHEMA VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify DST_QUEUE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify STATUS VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify SPID VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify PROPAGATION_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify CAPTURE_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_server modify APPLY_NAME VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify ruleset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify ruleset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify negative_ruleset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_capture_process modify negative_ruleset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify ruleset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify ruleset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify negative_ruleset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify negative_ruleset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify ua_ruleset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_process modify ua_ruleset_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify propagation_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify source_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify source_queue varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify destination_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify destination_queue varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify ruleset_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify ruleset varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify negative_ruleset_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify negative_ruleset varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify original_propagation_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify original_source_queue_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_propagation_process modify original_source_queue varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_extra_attrs modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_extra_attrs modify include varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_key_columns modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_key_columns modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_key_columns modify cname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_def_proc modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_def_proc modify package_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_def_proc modify procedure_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_def_proc modify param_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_rules modify streams_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_rules modify rule_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_rules modify rule_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_rules modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_rules modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_source_obj modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_source_obj modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_source_schema modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_virtual_obj_cons modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_virtual_obj_cons modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_virtual_obj_cons modify powner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_virtual_obj_cons modify pname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_virtual_obj_cons modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.apply$_constraint_columns modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.apply$_constraint_columns modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.apply$_constraint_columns modify constraint_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.apply$_constraint_columns modify cname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sys.apply$_constraint_columns modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj modify source_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj modify source_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj_ops modify sname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj_ops modify oname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj_ops modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_dest_obj_ops modify handler_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_stmt_handlers modify handler_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify change_table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify change_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify source_table_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify source_table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify handler_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_change_handlers modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_error modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_error modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_error modify recipient_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table apply$_conf_hdlr_columns modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_dest_obj_cols modify column_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify streams_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify msg_type_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify msg_type_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify msg_rule_var varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify rule_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify rule_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_rules modify spare4 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify streams_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify rset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify rset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify neg_rset_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify neg_rset_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_message_consumers modify spare4 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_spill_txn modify applyname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_apply_spill_txn modify sender varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_groups modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_groups modify sequence_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_groups modify default_dir_obj varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_groups modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_versions modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_versions modify version_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_versions modify default_dir_obj varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_versions modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_export_info modify export_version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_export_info modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_files modify creator varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_files modify file_dir_obj varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_file_group_files modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_tablespace_info modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_table_info modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_table_info modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgr$_table_info modify spare3 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify obj_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify int_obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify int_obj_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify bt_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_object$ modify bt_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_dep_error$ modify obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_dep_error$ modify obj_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_dep_error$ modify bt_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table redef_dep_error$ modify bt_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table log$ modify colname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reco_script$ modify invoking_package_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reco_script$ modify invoking_package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reco_script$ modify invoking_procedure varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reco_script$ modify invoking_user varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table reco_script_params$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison$ modify comparison_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison$ modify schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison$ modify object_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison$ modify rmt_schema_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison$ modify rmt_object_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table comparison_col$ modify col_name VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_component_prop modify prop_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_database modify version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_database modify compatibility varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server modify server_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server modify capture_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server modify queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server modify queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_subset_rules modify server_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_subset_rules modify rules_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_subset_rules modify insert_rule varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_subset_rules modify delete_rule varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_subset_rules modify update_rule varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_sysgen_objs modify server_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_sysgen_objs modify object_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_sysgen_objs modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_sysgen_objs modify object_type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_parameters modify server_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_parameters modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_parameters modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_parameters modify user_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_dml_conflict_handler modify object_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_dml_conflict_handler modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_dml_conflict_handler modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_dml_conflict_handler modify old_object varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_dml_conflict_handler modify old_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify outbound_server varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify inbound_server varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify outbound_queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify outbound_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify inbound_queue_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify inbound_queue_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify rule_set_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify rule_set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify negative_rule_set_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_server_connection modify negative_rule_set_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_ddl_conflict_handler modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_map modify apply_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_map modify src_obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_map modify tgt_obj_owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table goldengate$_privileges modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_privileges modify username varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table streams$_prepare_ddl modify c_invoker varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table xstream$_privileges modify c_invoker varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table goldengate$_privileges modify c_invoker varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dsec.bsq

begin
  execute immediate 'alter table aud_context$ modify namespace varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aud_context$ modify attribute varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls$ modify gname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls$ modify pname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls$ modify pfschma VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls$ modify ppname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls$ modify pfname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls_sc$ modify gname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls_sc$ modify pname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls_grp$ modify gname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls_ctx$ modify ns VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table rls_ctx$ modify attr VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table radm$ modify pname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

DECLARE
  schema_name   VARCHAR2(10);
BEGIN
  -- find out in which schema AUD$ table exists
  SELECT u.name INTO schema_name 
  FROM obj$ o, user$ u
  WHERE o.name = 'AUD$' AND o.type#=2 AND o.owner# = u.user#
  AND o.remoteowner IS NULL AND o.linkname IS NULL 
  AND u.name IN ('SYS', 'SYSTEM');

  begin
    -- construct Alter Table statement for all columns and execute it
    EXECUTE IMMEDIATE
     'ALTER TABLE ' || dbms_assert.enquote_name(schema_name, FALSE) 
                    || '.AUD$ modify (clientid     varchar2(128),
                                      userid       varchar2(128),
                                      obj$creator  varchar2(128),
                                      auth$grantee varchar2(128),
                                      new$owner    varchar2(128),
                                      obj$edition  varchar2(128)
                                     )';
  exception when others then
    if sqlcode in (-904, -942) then null;
    else raise;
    end if;
  end;
END;
/
begin
  execute immediate 'alter table fga$ modify pname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga$ modify pfschma VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga$ modify ppname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga$ modify pfname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga$ modify pcol VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fgacol$ modify pname VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga_log$ modify dbuid varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga_log$ modify obj$schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga_log$ modify policyname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table fga_log$ modify obj$edition varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table approle$ modify schema VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table approle$ modify package VARCHAR2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table XSDB$SCHEMA_ACL modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aclmv$_reflog modify schema_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aclmv$_reflog modify table_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table aclmv$_reflog modify mview_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dsqlddl.bsq

begin
  execute immediate 'alter table link$ modify userid varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table link$ modify password varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table link$ modify authusr varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table link$ modify authpwd varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table duc$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table duc$ modify pack varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table duc$ modify proc varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table recyclebin$ modify original_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table recyclebin$ modify partition_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table context$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table context$ modify package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sql_version$ modify sql_version varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table trigger$ modify refoldname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table trigger$ modify refnewname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table trigger$ modify refprtname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table triggerjavac$ modify ownername varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table triggerdep$ modify p_trgowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table triggerdep$ modify p_trgname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqltxl$ modify txlrowner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sqltxl$ modify txlrname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dsummgt.bsq

begin
  execute immediate 'alter table sum$ modify containernam varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sum$ modify rw_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sumdetail$ modify detailalias varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sumdep$ modify syn_own varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table sumdep$ modify syn_name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table hier$ modify hiername varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dimlevel$ modify levelname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table dimattr$ modify attname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dtools.bsq

begin
  execute immediate 'alter table incexp modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table incfil modify expuser varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expact$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expact$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expact$ modify func_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expact$ modify func_package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expact$ modify func_proc varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table noexp$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table noexp$ modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exppkgobj$ modify package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exppkgobj$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exppkgact$ modify package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table exppkgact$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expdepact$ modify package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expdepact$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expimp_tts_ct$ modify owner varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table expimp_tts_ct$ modify tablename varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify xmltag varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify udt varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaview$ modify viewname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metafilter$ modify filter varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metafilter$ modify type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metafilter$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxsl$ modify xmltag varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxsl$ modify transform varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxsl$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxslparam$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxslparam$ modify transform varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxslparam$ modify type varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metaxslparam$ modify param varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metastylesheet modify name varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metastylesheet modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascript$ modify htype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascript$ modify ptype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascript$ modify ltype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascript$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify htype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify ptype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify ltype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify filter varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify pfilter varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metascriptfilter$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metanametrans$ modify htype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metanametrans$ modify ptype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metanametrans$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metapathmap$ modify htype varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table metapathmap$ modify model varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table impcalloutreg$ modify package varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table impcalloutreg$ modify schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table impcalloutreg$ modify tag varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table impcalloutreg$ modify tgt_schema varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table impcalloutreg$ modify tgt_object varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

--File dtxnspc.bsq

begin
  execute immediate 'alter table pending_trans$ modify top_db_user varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pending_trans$ modify spare2 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table pending_trans$ modify spare4 varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/


Rem *************************************************************************
Rem Longer Identifiers - END
Rem *************************************************************************


REM 
REM SYNC REFRESH CATALOG TABLES
REM

--
-- syncref$_groups
--
-- This table stores information on the sync-refresh-groups. It is populated 
-- at register_mviews time and deleted according to the purge policy.
--
-- The lock_flag field is used to enforce sync-refresh-group-locking with 
-- the locking_primitive implemented with Oracle row-level locks.
--

create table syncref$_groups
(
 group_id	    number not null primary key,             /* the group-id */
 lock_flag          number not null            /* 0 - not locked, 1 - locked */
);

--
-- syncref$_table_info
--
-- This table stores information on the base-tables of the MVs registered 
-- for sync refresh. It is populated during staging-log DDL. A row is inserted
-- when the staging-log is created and deleted when the log is dropped or 
-- altered to an ordinary MV-log.
--

create table syncref$_table_info
(
  table_obj#        number         not null primary key, 
  staging_log_obj#  number         not null
);

--
-- syncref$_objects
--
-- This table stores information on the objects (tables and MV's) registered 
-- for sync refresh. It can contain multiple rows for the same obj# but only 
-- one of them can have current_group_flag = TRUE; all others must have  
-- current_group_flag = FALSE.
-- A row is entered into this table whenever an MV is either registered 
-- or unregistered.
--

create table syncref$_objects
(
 obj#               number not null, 
 object_type_flag   number not null,                       /* table or mview */
 group_id	    number not null,
 current_group_flag number not null      /* 1 ==> current sync-refresh-group */
                                        /* 0 ==> obsolete sync-refresh-group */
);

--
-- syncref$_partn_ops
--
-- This table stores information on the partition operations registered 
-- on the base-tables of  the MV's registered for sync refresh. 
-- The usage of this table is quite straight-forward.  It is populated at
-- REGISTER_PARTITION_OPERATION time and rows deleted when pmops are 
-- unregistered or the refresh is completed.
--

create table syncref$_partn_ops
(
 table_obj#         number  not null, 
 partition_op	    varchar2(30) not null,  /* exchange or drop or  truncate */
 partition_name	    varchar2(30)    not null,    /* name of the partition to */
                                                              /* be changed. */
 outside_table_schema_name  varchar2(30), /*schema in which the outside-table*/
                                     /* (for exchange partition) was created */
 outside_table_name   varchar2(30)              /* name of the outside-table */
                                                 /* (for exchange partition) */
);

--
-- syncref$_group_status
-- 
-- This table stores information on the overall status of the prepare_refresh (PR)
-- and  execute_refresh (ER) operations and the current-state of the operation for 
-- each run of a group. 
-- An entry is created in this table for a refresh-group when the 
-- prepare-refresh is started and it is deleted according to the 
-- refresh-history retention policy.
-- The state and status of the group during prepare- and execute-refresh 
-- is constantly updated during those operations. The usage of the cur_run_xxx
-- fields to maintain the state-transition-table have been discussed in 
-- Section 3.4 and is not repeated here.
--
-- The current_step field records the stmt-number in syncref$_step_status
-- which is currently executing at PR time. It is not used/set for ER.
--
--

create table syncref$_group_status
(
 group_id	    number not null,                  /* the group-id of the */
                      /* sync-refresh-group whose status is being described. */
 cur_run_flag       number not null,                 /* 0 - old, 1 - current */
 cur_run_opn        number not null,              /* 1 - PREPARE, 2- EXECUTE */
 cur_run_status     number not null,            /* 0 - RUNNING, 1- COMPLETE, */
                                  /* 2 - ERROR-SOFT, 3- ERROR-HARD, 4 -ABORT */
                                                              /* 5 - PARTIAL */
 num_prepare_steps  number not null,
 num_execute_steps  number not null,
 current_step       number not null,              /* used by prepare_refresh */
 num_abortpr_steps  number not null,
 num_tbls           number not null,     /* the number of tables in the group */
 num_mvs            number not null,     /* the number of mviews in the group */
 base_tbls_refr_status  number not null,               /* 0 - NOT PROCESSED, */
                                                  /* 1 - COMPLETE, 4 - ABORT */
 num_mvs_completed  number,  /*the number of mvs which have completed refresh*/
 num_mvs_aborted    number,  /* the number of mvs which have aborted refresh */
 error_number	    number,                           /* error number if any */
 error_message	    varchar2(4000),                  /* error message if any */
 prepare_start_time  date,                  /* start-time of prepare_refresh */
 prepare_end_time    date,                    /* end-time of prepare_refresh */
 execute_start_time  date,                  /* start-time of execute_refresh */
 execute_end_time    date,                    /* end-time of execute_refresh */
 owner#	             number not null               /* the owner of the group */
);

--
-- syncref$_object_status
--
-- This table is the object-level counterpart of syncref$_group_status.  
-- It stores information on the status of each object during the 
-- prepare_refresh and  execute_refresh operations 
--
-- An entry is created in this table for the objects in the sync-refresh-group
-- at prepare-refresh time with  cur_run_flag = 1 any previous entry for the 
-- group is marked with cur_run_flag = 0
--
-- The status of the object is updated by  execute-refresh to COMPLETE or ABORT
--
-- The field canonical_order is a canonical_ordering of the objects in the 
-- group in the order they are to be processed for Data-Validation. 
-- It is assigned at the initialization time of prepare_refresh.
--
-- The status field has the following values:
--   0 - NOT PROCESSED, 1 - COMPLETE, 4 - ABORT 
--  NOT PROCESSED  means refresh has not occurred or is running
--

create table syncref$_object_status
(
 obj#               number not null, 
 cur_run_flag       number not null,                 /* 0 - old, 1 - current */
 group_id	    number not null,                  /* the group-id of the */
                         /* sync-refresh-group to which this object belongs. */
 canonical_order    number,                     /* canonical ordering number */
 status	            number not null,            /* status - see values above */
 num_exch_partns    number,          /* number of partitions to be exchanged */
 num_inplace_partns number,                          /* number of partitions */
                         /* to be modified in-place with incremental refresh */
 num_inplace_rows   number,                          /* number of rows to be */
                              /* modified in-place with incremental refresh. */
 error_number	    number,                           /* error number if any */
 error_message	    varchar2(4000),                  /* error message if any */
 last_modified_time   date        /* timestamp of last update, used by purge */
);

-- 
-- syncref$_step_status
--
-- This table maintains the status of each step of each current operation 
-- on  a group. The usage of this table in conjunction with the current_step 
-- field in syncref$_group_status is described in Section 3.3.
-- This table is populated at PREPARE_REFRESH initialization time. 
-- It represents the plan for the prepare- and execute operations, as well 
-- the plan for undoing the actions in case of an ABORT. If an error occurs 
-- at a step, processing will stop and if the operation is resumed, we will 
-- pick up processing from the place we stopped.
--
-- The prepare_refresh and execute_refresh are broken into a sequence  
-- of steps, each associated with a SQL statement which must be  executed. 
-- These steps are computed at the beginning of prepare_refresh  and recorded 
-- in the syncref$_step_status table. In syncref$_group_status, 
-- the num_prepare_steps and num_execute_steps record the values of the 
-- number of steps in the two operations 
-- 
-- The field current_step  in syncref$_group_status stores  the number 
-- of the current step  being processed. If processing stops due to a 
-- soft error, and user resumes the refresh-operation, the operation will 
-- begin from the current-step. If the user chooses to abort the operation, 
-- the  abort-refresh will execute the undo_statements in the reverse-order 
-- starting from the predecessor of the current step all the way to the 
-- first step. 
--
-- New fields added on 6/7/2011:
-- stmt_grp_type - the statement-group-type, used internally by Sync Refresh 
--                 and documented in kkzf2.c
-- stmt_type     - the statement-type, used internally by Sync Refresh 
--                 and documented in kkzf2.c
-- set_seq-num - the sequence number obtained from the syncref_step_seq$
--               sequence. It is being set currently but used later. It
--               could be useful for consistency check on stmt_step.
-- stmt_step  - is the renamed "step" field. It starts at 1 .. max_steps
--              for the operation
-- aux_obj#   - set to 0 currentl. Not used. Maybe useful later
-- owner      - owner of the the object being operated on 
-- obj_name   - name of object (table or mv) 
-- aux_obj_name - np_name (i.e. new-partition-name) or ot_name (outside-
--               table-name). The former is for the fact-table, the latter
--               for mv's.
-- The owner, obj_name are set but not used currently.
-- The aux_obj_name is set and used later in instantiating the 
-- "disable foreign key" statement on new partitions. Since the foreign-keys
-- are given system-generated names which are generated only at 
-- execute_refresh (ER) time, they are not known at prepare_refresh (PR) time,
-- so PR generates these statements with a "%s" placeholder which is filled
-- at ER time after the foreign-key constraints have been created enabled.
--
create table syncref$_step_status
(
 group_id            number not null,                  /* the group-id of the */
                       /* sync-refresh-group whose status is being described. */
 operation           number not null,                    /* PREPARE, EXECUTE, */
 step_seq_num        number not null,           /* set from syncref_step_seq$ */
 stmt_grp_type       number not null,     /* stmt_grp-number of the operation */
 stmt_type           number not null,     /* stmt_grp-number of the operation */
 stmt_step           number not null,         /* step-number of the operation */
                                                             /* starts with 1 */
 obj#                number not null,    /* the object-number of object being */
                                                     /* processed in the step */
 aux_obj#            number,   /* the object-number of auxillary object being */
                                                     /* processed in the step */
 statement           clob,                                       /* statement */
 undo_statement      clob,    /* statement in case statement is being aborted */
 status              number not null,        /* completed, error, not-started */
 owner               varchar2(30),
 obj_name            varchar2(30),
 aux_obj_name        varchar2(30)
);

-- 
-- syncref$_log_exceptions
--
-- This table maintains information on exceptions in the staging-log 
-- detected by prepare_staging_log or prepare_refresh. 
--

create table syncref$_log_exceptions 
(
 table_obj#         number not null, 
 staging_log_obj#   number not null,
 bad_rowid	    rowid not null,                          /* rowid of the */
                                         /* offending row in the staging log */
 error_number	   number,                                   /* error number */
 error_message	   varchar2(4000)                           /* error message */
);

--
-- syncref$_parameters
--
-- This table stores  information on parameters which can be set by user 
-- to affect sync-refresh behavior. Current we have only parameter as shown 
-- below. This table can also be used if we need to ship patches to the 
-- customer as an alternative to the RDBMS global system parameters 
-- (defined in prm.h).
--
 
create table syncref$_parameters
(
 parameter_name     varchar2(256) not null primary key,
 num_value          number,
 str_value          varchar2(4000),                    /* not used currently */
 flags              number                             /* not used currently */
);

BEGIN
  insert into syncref$_parameters values ('REFRESH_HISTORY_STATS_RETENTION', 31, NULL, 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

--
-- syncref$_er_refgrps
--
-- Refresh-groups used by ER 
-- When ER is resumed or aborted, we construct a ref_list containing the 
-- refresh sub-group. Each sub-group is refreshed atomically, in one
-- transaction. The base tables are all in the first sub-group with
-- ref_grp_num = 0;  each mv is in a different group and its sumobjn 
-- is stored in it's eref. 
--
-- The sub-groups are constructed and stored on disk on a fresh ER
-- The term sub-group and refgrp are used interchangeably below.
--
-- The status field has the following values:
--   0 - NOT PROCESSED, 1 - COMPLETE, 4 - ABORT 
--
--  NOT PROCESSED  means refresh has not occurred or is running
--

create table syncref$_er_refgrps
(
 group_id	    number not null,                  /* the group-id of the */
                         /* sync-refresh-group to which this object belongs. */
 ref_grp_num	    number not null,             /* the number of the refgrp */
                        /* 0 - base_table_group; 1 - num_mvs  for mv_refgrps */
 mv_obj#            number not null,                   /* obj# for mv_refgrp */
 status	            number not null,            /* status - see values above */
 first_stmt         number not null,           /* first_stmt in the sub-group */
 last_stmt          number not null            /* last_stmt in the sub-group */
);

--
-- syncref$_soft_errors
--
-- The errors stored in this table are used to classify an error as hard or
-- soft. We populate this table at database-creation time. We read from this
-- table at prepare_refresh time. This table will be provided to Support.
--
-- Note: a soft error is an error from which the user can resume PR
--

create table syncref$_soft_errors 
(
 error number primary key
);

--
-- Mark 1536 as a soft-error. This corresponds to:
-- ORA-01536: space quota exceeded for tablespace '%s'
--

BEGIN
  insert into syncref$_soft_errors (error) values (1536);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

-- 
-- syncref$_stlog_stats
--
-- This table stores information about the staging table statistics including
-- number of rows to be inserted, deleted and updated.
--

create table syncref$_stlog_stats
(
  table_obj#        number         not null primary key,
  num_inserts       number         not null,
  num_deletes       number         not null,
  num_updates       number         not null, 
  psl_mode          number         not null/* 0=ENFORCED; */
                                   /* 1=INSERT_TRUSTED; */
                                   /* 2=DELETE_TRUSTED; */
                                   /* 4=UPDATE_TRUSTED; */
                                   /* 7=TRUSTED;   */
);

--
-- syncref_group_id_seq$
--
-- This sequence is used to assign group-ids to Sync Refresh groups at
-- mv-registration time. Note group-ids may also change during the 
-- unregister_mviews call.
--

create sequence syncref_group_id_seq$                   /* syncref group_id sequence */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 2147483647     /* max value that is guaranteed to fit into an SB4 */
  nocycle
/

--
-- syncref_step_seq$
--
-- This sequence is used to assign the step_seq_num at PR time.
-- It could be useful as a check on the step_seq assigned by PR
--
-- 

create sequence syncref_step_seq$
  increment by 1
  start with 1
  minvalue 1
  maxvalue 2147483647     /* max value that is guaranteed to fit into an SB4 */
  nocycle;


REM 
REM SYNC REFRESH END
REM

Rem*************************************************************************
Rem BEGIN Changes for rule_set on 12.0
Rem*************************************************************************

alter table rule_set_fob$ modify (opexpr_c1 varchar2(4000));
alter table rule_set_ve$ add (srchattrs raw(2000));
alter table rule_set_ee$ add (complex_operators number);

Rem re-create metadata IOTs
create table rule_set_pr$_sav as select  * from  rule_set_pr$;
drop table rule_set_pr$;

CREATE TABLE sys.rule_set_pr$(
       rs_obj#           number,                      /* rule set obj number */
       ec_obj#           number,            /* evaluation context obj number */
       rule_id           number,                                  /* rule ID */
       rule_or_piece     number,                     /* rule or piece number */
       rop_id            number,                         /* fast operator ID */
       arop_id           number,           /* argument rop or result rop  ID */
       eval_id           number,                      /* evaluation order ID */
       pr_id             number not null,                 /* parameter index */
       value             RAW(300),                        /* parameter value */
       primary key(rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id, arop_id,
                   eval_id, pr_id))
organization index tablespace sysaux overflow tablespace sysaux
/

insert into rule_set_pr$ (rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id,
                          arop_id, eval_id, pr_id, value)
 select rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id, 0,
        eval_id, pr_id, value from  rule_set_pr$_sav; 
drop table rule_set_pr$_sav;


create table rule_set_rop$_sav as select  * from  rule_set_rop$;
drop table rule_set_rop$;

CREATE TABLE sys.rule_set_rop$(
       rs_obj#           number,                      /* rule set obj number */
       ec_obj#           number,            /* evaluation context obj number */
       rule_id           number,                                  /* rule ID */
       rule_or_piece     number,                              /* or piece ID */
       rop_id            number,                         /* fast operator ID */
       parop_id          number,        /* parent of nested fast operator ID */
       arop_id           number,           /* argument rop or result rop  ID */
       eval_id           number,                            /* evaluation ID */
       box_id            number,                                   /* box ID */
       usesfp            number,     /* if 1, argument or result can be rop  */
       nopsfp            number,  /* total number of arguments if above is 1 */
       varsfp            raw(2000),           /* variables used for this rop */
       prnum             number,      /* max pr_id at pr$ table for this rop */
       primary key(rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id,
                   parop_id, arop_id, eval_id))
organization index tablespace sysaux overflow tablespace sysaux
/


insert into rule_set_rop$ (rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id,
                           parop_id, arop_id, eval_id, box_id, usesfp, nopsfp, 
                           varsfp, prnum)
 select rs_obj#, 
        ec_obj#, 
        rule_id, 
        rule_or_piece, 
        rop_id, 
        0,                                                       /* parop_id */
        0,                                                        /* arop_id */
        eval_id,
        box_id, 
        0,                                                         /* usesfp */
        NULL,                                                      /* nopsfp */
        NULL,                                                      /* varsfp */
        0                                                           /* prnum */
        from rule_set_rop$_sav;

drop table rule_set_rop$_sav;

create table rule_set_temp$ as select obj# from sys.obj$
       where type# = 46 and status = 5;

delete from rule_set_ee$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_te$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_ve$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_re$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_fob$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_ror$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_rop$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_nl$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_pr$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_rdep$ where rs_obj# in (select obj# from rule_set_temp$ );
delete from rule_set_iot$ where rs_obj# in (select obj# from rule_set_temp$ );

commit;

drop table rule_set_temp$;

Rem *************************************************************************
Rem END Changes for rule_set
Rem *************************************************************************



Rem *************************************************************************
Rem BEGIN Changes for Data Guard redo log tables
Rem *************************************************************************

CREATE TABLE SYSTEM.REDO_DB (
  DBID                    NUMBER NOT NULL,
  GLOBAL_DBNAME           VARCHAR2(129),
  DBUNAME                 VARCHAR2(32),
  VERSION                 VARCHAR2(32),
  THREAD#                 NUMBER NOT NULL,
  RESETLOGS_SCN_BAS       NUMBER NOT NULL,
  RESETLOGS_SCN_WRP       NUMBER NOT NULL,
  RESETLOGS_TIME          NUMBER NOT NULL,
  PRESETLOGS_SCN_BAS      NUMBER,
  PRESETLOGS_SCN_WRP      NUMBER,
  PRESETLOGS_TIME         NUMBER,
  SEQNO_RCV_CUR           NUMBER,
  SEQNO_RCV_LO            NUMBER,
  SEQNO_RCV_HI            NUMBER,
  SEQNO_DONE_CUR          NUMBER,
  SEQNO_DONE_LO           NUMBER,
  SEQNO_DONE_HI           NUMBER,
  GAP_SEQNO               NUMBER,
  GAP_RET                 NUMBER,
  GAP_DONE                NUMBER,
  APPLY_SEQNO             NUMBER,
  APPLY_DONE              NUMBER,
  PURGE_DONE              NUMBER,
  HAS_CHILD               NUMBER,
  ERROR1                  NUMBER,
  STATUS                  NUMBER,
  CREATE_DATE             DATE,
  TS1                     NUMBER,
  TS2                     NUMBER,
  CURSCN_BAS              NUMBER,
  CURSCN_WRP              NUMBER,
  CURSCN_TIME             NUMBER,
  SCN1_BAS                NUMBER,
  SCN1_WRP                NUMBER,
  SCN1_TIME               NUMBER,
  CURLOG                  NUMBER,
  SPARE2                  NUMBER,
  SPARE3                  NUMBER,
  SPARE4                  NUMBER,
  SPARE5                  DATE,
  SPARE6                  VARCHAR2(65),
  SPARE7                  VARCHAR2(129),
  TS3                     NUMBER,
  CURBLKNO                NUMBER
) tablespace SYSAUX LOGGING
/

CREATE TABLE SYSTEM.REDO_LOG (
  DBID                    NUMBER NOT NULL,
  GLOBAL_DBNAME           VARCHAR2(129),
  DBUNAME                 VARCHAR2(32),
  VERSION                 VARCHAR2(32),
  THREAD#                 NUMBER NOT NULL,
  RESETLOGS_SCN_BAS       NUMBER NOT NULL,
  RESETLOGS_SCN_WRP       NUMBER NOT NULL,
  RESETLOGS_TIME          NUMBER NOT NULL,
  PRESETLOGS_SCN_BAS      NUMBER,
  PRESETLOGS_SCN_WRP      NUMBER,
  PRESETLOGS_TIME         NUMBER,
  SEQUENCE#               NUMBER NOT NULL,
  DUPID                   NUMBER,
  STATUS1                 NUMBER,
  STATUS2                 NUMBER,
  CREATE_TIME             VARCHAR2(32),
  CLOSE_TIME              VARCHAR2(32),
  DONE_TIME               VARCHAR2(32),
  FIRST_SCN_BAS           NUMBER,
  FIRST_SCN_WRP           NUMBER,
  FIRST_TIME              NUMBER,
  NEXT_SCN_BAS            NUMBER,
  NEXT_SCN_WRP            NUMBER,
  NEXT_TIME               NUMBER,
  CURRENT_SCN_BAS         NUMBER,
  CURRENT_SCN_WRP         NUMBER,
  CURRENT_TIME            NUMBER,
  BLOCKS                  NUMBER,
  BLOCK_SIZE              NUMBER,
  OLD_BLOCKS              NUMBER,
  CREATE_DATE             DATE,
  ERROR1                  NUMBER,
  ERROR2                  NUMBER,
  FILENAME                VARCHAR2(513),
  TS1                     NUMBER,
  TS2                     NUMBER,
  SPARE1                  NUMBER,
  SPARE2                  NUMBER,
  SPARE3                  NUMBER,
  SPARE4                  NUMBER,
  SPARE5                  DATE,
  SPARE6                  VARCHAR2(65),
  SPARE7                  VARCHAR2(129),
  TS3                     NUMBER,
  CURRENT_BLKNO           NUMBER
) tablespace SYSAUX LOGGING
/

CREATE INDEX system.redo_db_idx ON
        system.redo_db(dbid, thread#, resetlogs_scn_bas, resetlogs_scn_wrp, resetlogs_time)
        TABLESPACE SYSAUX LOGGING
/

CREATE INDEX system.redo_log_idx ON
        system.redo_log(dbid, thread#, resetlogs_scn_bas, resetlogs_scn_wrp, resetlogs_time)
        TABLESPACE SYSAUX LOGGING
/

commit;

Rem *************************************************************************
Rem END Changes for Data Guard redo log tables
Rem *************************************************************************

Rem *************************************************************************
Rem EM Express - BEGIN
Rem *************************************************************************

Rem add new system privilege for EM Express
BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-346, 'EM EXPRESS CONNECT', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem Add new audit option map for EM Express privilege
BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (346, 'EM EXPRESS CONNECT', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

commit;

Rem explicitly grant em express connect to dba (even though "grant 
Rem all privileges to dba" at the end of the script will do it)
grant EM EXPRESS CONNECT to dba; 
 
Rem
Rem Drop reporting framework file storage table.
Rem
drop table wri$_rept_files;


Rem *************************************************************************
Rem EM Express - END
Rem *************************************************************************

Rem *************************************************************************
Rem Clustering - Begin
Rem *************************************************************************

REM
REM Clustering Metadata Table clst$
REM 

create table clst$
(
  clstobj#     number not null,  /* object number of the table           */
  clstfunc     number not null,  /* Clustering Function                  */
                                 /* 1 - Hilbert                          */
                                 /* 2 - Order                            */
  clstlastdm   timestamp,        /* Last time the clustering occurred on */
                                 /* Data Movement                        */
  clstlastload timestamp,        /* Last time the clustering occurred on */
                                 /* Load                                 */
  flags        number            
                                 /* 0x00000001 - Load                    */
                                 /* 0x00000002 - Data Movement           */
)
/
Rem Index on clst$
create unique index i_clst$ on clst$(clstobj#)
/

REM
REM Clustering Metadata Table clstkey$
REM 

create table clstkey$
(
  clstobj# number not null,  /* object number of the table              */
  tabobj#  number not null,  /* Clustering column tables                */
  intcol#  number not null,  /* Clustering column                       */
  position number not null,  /* Position of column in clustering clause */
  groupid  number not null   /* Identifier of the Group                 */
)
/

REM
REM Index for Clustering Metadata Table clstkey$
REM 

create index i_clstkey$ on clstkey$(clstobj#)
/


REM
REM Clustering Metadata Table clstdimension$
REM 

create table clstdimension$
(
  clstobj# number not null,  /* object number of the table */
  tabobj#  number not null   /* Clustering column tables   */
)
/

REM
REM Index for Clustering Metadata Table clstdimension$
REM 

create index i_clstdimension$ on clstdimension$(clstobj#)
/

REM
REM Clustering Metadata Table clstjoin$
REM 

create table clstjoin$
(
  clstobj# number not null,  /* object number of the table          */
  tab1obj# number not null,  /* object number of the table in join  */
  int1col# number not null,  /* column number of the column in join */
  tab2obj# number not null,  /* object number of the table in join  */
  int2col# number not null   /* column number of the column in join */
)
/

REM
REM Index Clustering Metadata Table clstjoin$
REM 

create index i_clstjoin$ on clstjoin$(clstobj#)
/

Rem *************************************************************************
Rem Clustering - End
Rem *************************************************************************

Rem *************************************************************************
Rem Resource Manager related changes for 12g - BEGIN
Rem *************************************************************************

create table cdb_resource_plan$
(
  obj#                       number not null,            /* obj# of cdb plan */
  name                       varchar2(128),              /* name of cdb plan */
  description                varchar2(2000),          /* comment on the plan */
  status                     varchar2(128),     /* whether active or pending */
  mandatory                  number             /* whether plan is mandatory */
);

create table cdb_resource_plan_directive$
(
  obj#                       number not null,            /* obj$ of cdb plan */
  cdb_plan                   varchar2(128),              /* name of cdb plan */
  pdb                        varchar2(128),            /* pluggable database */
  description                varchar2(2000),          /* comment on plan dir */
  shares                     number,        /* number of shares for this pdb */
  utilization_limit          number,           /* limit on resources for pdb */
  parallel_server_limit      number,          /* limit on pq servers for pdb */
  status                     varchar2(128),     /* whether active or pending */
  mandatory                  number         /* whether plan dir is mandatory */
);

Rem Move the parallel server limit from max_active_sess_target_p1 to
Rem a new column, parallel_server_limit.
alter table resource_plan_directive$ add (parallel_server_limit number);
alter table resource_plan_directive$ add (switch_io_logical number);
alter table resource_plan_directive$ add (switch_elapsed_time number);

update resource_plan_directive$ set
  parallel_server_limit = max_active_sess_target_p1;
update resource_plan_directive$ set
  switch_io_logical = 4294967295;
update resource_plan_directive$ set
  switch_elapsed_time = 4294967295;

Rem Add parallel_stmt_critical
alter table resource_plan_directive$ add (parallel_stmt_critical number);
update resource_plan_directive$ set
  parallel_stmt_critical = 4294967295;

commit;

Rem *************************************************************************
Rem Resource Manager related changes for 12g - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Set the rls$.stmt_type bit for all the Oracle Label Security RLS 
Rem policies
Rem *************************************************************************

UPDATE sys.rls$ SET stmt_type = stmt_type + 524288
WHERE PFSCHMA = 'LBACSYS'
AND BITAND(stmt_type, 524288) = 0;
COMMIT;

Rem *************************************************************************
Rem END Set the rls$.stmt_type bit for all the Oracle Label Security RLS 
Rem policies
Rem *************************************************************************

Rem *************************************************************************
Rem Scheduler - BEGIN
Rem *************************************************************************

alter table sys.scheduler$_job add
(pdb_id number);

delete from sys.scheduler$_job_run_details where log_id is null;
delete from sys.scheduler$_job_run_details where rowid in
  (select rowid from
    (select rowid, row_number()
      over (partition by log_id order by log_id, log_date) dup
      from sys.scheduler$_job_run_details)
  where dup > 1);

begin
  execute immediate 'alter table sys.scheduler$_job_run_details
                     add constraint scheduler$_job_run_details_pk
                     PRIMARY KEY (log_id)
                     using index sys.i_scheduler_job_run_details';
exception when others then
  if (sqlcode = -2260) then null;
  else raise;
  end if;
end;
/

COMMIT;

DROP PACKAGE SCHEDULER_UTIL;

Rem *************************************************************************
Rem Scheduler - END
Rem *************************************************************************

Rem *************************************************************************
Rem Upgrade for system.aq$_queues and related views - BEGIN
Rem *************************************************************************

ALTER TABLE system.aq$_queues ADD (sharded NUMBER);

Rem *************************************************************************
Rem Upgrade for system.aq$_queues and related views - END
Rem *************************************************************************

Rem *************************************************************************
Rem rowid mapping table support changes - BEGIN
Rem *************************************************************************

create table rmtab$
(
   obj#     number,                                              /* rmt objn */
   stab#    number,                                     /* source table objn */
   sobj#    number,                           /* source table partition objn */
   sobjd#   number,                            /* source table/partiton objd */
   ttab#    number,                                     /* target table objn */
   tobj#    number,                           /* target table partitino objn */
   tobjd#   number,                           /* target table/partition objd */
   mflags   number,                                         /* mutable flags */
   name     varchar(30),                                      /* name of rmt */
   user#    number                                   /* user who created rmt */
)
/

create unique index pk_rmtab$ on rmtab$ (obj#)
/
create index stab_rmtab$ on rmtab$ (stab#)
/

Rem *************************************************************************
Rem rowid mapping table support changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Fast global index maintenance during drop/truncate partition - BEGIN
Rem *************************************************************************

create table index_orphaned_entry$
(
  indexobj#     number not null,       /* object number of index (partition) */
  tabpartdobj#  number not null,       /* dataobj number of table partition for
                                        * which there are orphaned entries.
                                        */
  hidden        char(1)                /* is this a hidden (H), orphaned (O),
                                        * or redirected (R) partition? 
                                        */
)
/

create unique index i_index_orphaned_entry$_1 on index_orphaned_entry$
(indexobj#, tabpartdobj#)
/

Rem *************************************************************************
Rem Fast global index maintenance during drop/truncate partition - END
Rem *************************************************************************


Rem**************************************************************************
Rem bug 12710912 : Drop old sequence in dbms_lock package - BEGIN
Rem**************************************************************************

drop sequence dbms_lock_id;

Rem**************************************************************************
Rem bug 12710912 : Drop old sequence in dbms_lock package - END
Rem**************************************************************************


Rem**************************************************************************
Rem bug 15925294 : Add constraint in dbms_lock_allocated table - BEGIN
Rem**************************************************************************

truncate table dbms_lock_allocated;
alter table dbms_lock_allocated add unique (lockid);

Rem**************************************************************************
Rem bug 15925294 : Add constraint in dbms_lock_allocated table - END
Rem**************************************************************************


Rem *************************************************************************
Rem Stats gathering reporting changes - BEGIN
Rem *************************************************************************

Rem Extend stats_target$ table with start and end time fields
Rem
alter table stats_target$ add start_time timestamp with time zone;
alter table stats_target$ add end_time timestamp with time zone;

Rem Extend wri$_optstat_opr table with new reporting columns
Rem
alter table wri$_optstat_opr add id number;
alter table wri$_optstat_opr add status number;
alter table wri$_optstat_opr add job_name varchar2(64);
alter table wri$_optstat_opr add session_id number;
alter table wri$_optstat_opr add notes varchar2(4000);

Rem Index to access stats operations efficiently by their id
Rem
create index i_wri$_optstat_opr_id on 
  wri$_optstat_opr(id)
  tablespace sysaux
/

Rem Sequence to generate id for stats operations
Rem
create sequence st_opr_id_seq
    minvalue 1
    start with 1
    increment by 1
    cache 20
/

Rem The following table stores individual tasks that are run as part of 
Rem each stats operation.
Rem
create table wri$_optstat_opr_tasks (
op_id           number,                                      /* operation id */
job_name        varchar(50),          /* name of the job which run this task */
status          number,                    /* completion status for the task */
start_time      timestamp with time zone,                 /* task start time */
end_time        timestamp with time zone,                   /* task end time */
target          varchar(100),                                 /* target name */
target_objn     number,                              /* target object number */
target_type     number,                                /* target object type */
target_size     number,                        /* number of blocks in target */
estimated_cost  number,                     /* estimated_cost for the target */
batching_coeff  number,                    /* target cost/batching threshold */
actions         number,         /* number of histograms created in this task */
priority        number,          /* rank/priority of the target in its group */
flags           number,                     /* flgs representing reason code */
notes           varchar2(4000), /* additional notes on the task in xml format*/
spare1          number,
spare2          number,
spare3          number,
spare4          varchar2(1000),
spare5          varchar2(1000),
spare6          timestamp with time zone
) tablespace sysaux
pctfree 1
enable row movement
/

Rem Index to access tasks of an operation efficiently given a target and 
Rem task status. Mainly used for querying history for estimating cost of 
Rem the currently running tasks.
Rem
create index i_wri$_optstat_opr_tasks_tgst on 
          wri$_optstat_opr_tasks(target, status)
          tablespace sysaux
/

Rem Index to access tasks of an operation efficiently given the id of the 
Rem operation. Mainly used for reporting tasks of an operation. 
Rem
create index i_wri$_optstat_opr_tasks_opid on 
          wri$_optstat_opr_tasks(op_id)
          tablespace sysaux
/

Rem Index to access stats tasks efficiently given their start time. 
Rem Mainly used for purging older tasks as part of stats history
Rem purging.
Rem
create index i_wri$_optstat_opr_tasks_stime on 
          wri$_optstat_opr_tasks(start_time)
          tablespace sysaux
/

Rem Index to access a particular task of an operation efficiently given 
Rem the id of the operation and obj# of a target. 
Rem
create index i_wri$_optstat_opr_tasks_opobj on 
          wri$_optstat_opr_tasks(op_id, target_objn)
          tablespace sysaux
/

Rem *************************************************************************
Rem End stats gathering reporting changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem RDBMS rolling upgrades via DBMS_ROLLING package - BEGIN
Rem *************************************************************************

create table system.rolling$connections (
  source_rdbid       number,                                 /* source rdbid */
  dest_rdbid         number,                            /* destination rdbid */
  attributes         number,                        /* connection attributes */
  service_name       varchar2(256),      /* net service name at source_rdbid */
  conn_handle        number,        /* RMI connection handle at source_rdbid */
  connect_time       timestamp,                      /* time of last connect */
  send_time          timestamp,                         /* time of last send */
  disconnect_time    timestamp,                   /* time of last disconnect */
  update_time        timestamp,                /* time of last record update */
  source_pid         number,                     /* PID of connection source */
  dest_pid           number,                       /* PID of connection dest */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

create table system.rolling$databases (
  rdbid              number,                /* rolling upgrade db identifier */
  attributes         number,                          /* database attributes */
  attributes2        number,                        /* database attributes 2 */
  dbun               varchar2(128),                        /* db_unique_name */
  dbid               number,                                         /* dbid */
  prod_rscn          number,                     /* reset scn being produced */
  prod_rid           number,                      /* reset id being produced */
  prod_scn           number,                          /* recent scn produced */
  cons_rscn          number,                     /* reset scn being consumed */
  cons_rid           number,                      /* reset id being consumed */
  cons_scn           number,                 /* recent scn applied/recovered */
  engine_status      number,                     /* run state of the MRP/LSP */
  version            varchar2(128),                         /* rdbms version */
  redo_source        number,                  /* rdbid of protected database */
  update_time        timestamp,                /* time of last record update */
  revision           number,                              /* revision number */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

create table system.rolling$directives (
  directid           number,                                 /* directive id */
  phase              number,                                        /* phase */
  taskid             number,                                      /* task id */
  feature            varchar2(32),                     /* feature dependency */
  description        varchar2(256),              /* description of directive */
  target             number,                       /* parameter id of target */
  flags              varchar2(64),                 /* compiler/runtime flags */
  opcode             number,                         /* operation identifier */
  p1                 varchar2(256),                /* p1 argument for opcode */
  p2                 varchar2(256),                /* p2 argument for opcode */
  p3                 varchar2(256),                /* p3 argument for opcode */
  spare1             number,
  spare2             number,
  spare3             varchar2(256)
) tablespace SYSTEM LOGGING
/

create sequence system.rolling_event_seq$ start with 1
       increment by 1 nomaxvalue order nocache
/

create table system.rolling$events (
  eventid            number,                                     /* event id */
  instid             number,                               /* instruction id */
  revision           number,                            /* build revision id */
  event_time         timestamp,                                 /* timestamp */
  type               varchar2(16),                             /* event type */
  status             number,                                  /* status code */
  message            varchar2(256),                         /* event message */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

create table system.rolling$parameters (                
  scope              number,                             /* associated rdbid */
  name               varchar2(32),                         /* parameter name */
  id                 number,                       /* DGLR_P_ constant value */
  descrip            varchar2(256),                 /* parameter description */
  type               number,                               /* parameter type */
  datatype           number,                           /* parameter datatype */
  attributes         number,                                   /* attributes */
  curval             varchar2(256),                         /* current value */
  lstval             varchar2(256),                            /* last value */
  defval             varchar2(256),                         /* default value */
  minval             number,              /* minimum value for number values */
  maxval             number,              /* maximum value for number values */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

create table system.rolling$plan (
  instid             number,                               /* instruction id */
  batchid            number,                                     /* batch id */
  directid           number,                                 /* directive id */
  taskid             number,                                      /* task id */
  revision           number,                                   /* revision # */
  phase              number,                            /* instruction phase */
  status             number,                             /* execution status */
  progress           number,                           /* execution progress */
  source             number,                              /* rdbid of sender */
  target             number,                              /* rdbid of target */
  rflags             number,                                /* runtime flags */
  opcode             number,                         /* operation identifier */
  p1                 varchar2(256),                /* p1 argument for opcode */
  p2                 varchar2(256),                /* p2 argument for opcode */
  p3                 varchar2(256),                /* p3 argument for opcode */
  p4                 varchar2(256),                /* p4 argument for opcode */
  description        varchar2(256),                 /* formatted description */
  exec_status        number,                  /* exec callback return status */
  exec_info          varchar2(256),        /* mid-exec informational message */
  exec_time          timestamp,            /* time of last execution attempt */
  finish_time        timestamp,            /* time of instruction completion */
  post_status        number,                      /* post-proc return status */
  spare1             number,
  spare2             number,
  spare3             varchar2(256)
) tablespace SYSTEM LOGGING
/

create table system.rolling$statistics (
  statid             number,                                 /* statistic id */
  rdbid              number,                             /* associated rdbid */
  attributes         number,                                   /* attributes */
  type               number,                               /* statistic type */
  name               varchar2(256),                        /* statistic name */
  valuestr           varchar2(256),                          /* string value */
  valuenum           number,                                 /* number value */
  valuets            timestamp,                           /* timestamp value */
  valueint           interval day(3) to second (2),        /* interval value */
  update_time        timestamp,                       /* time of last update */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

create table system.rolling$status (
  revision           number,                            /* build revision id */
  phase              number,                                /* current phase */
  batchid            number,                    /* current instruction batch */
  status             number,                                       /* status */
  coordid            number,         /* rdbid of rolling upgrade coordinator */
  oprimary           number,                    /* rdbid of original primary */
  fprimary           number,                      /* rdbid of future primary */
  pid                number,                                /* pid of caller */
  instance           number,                          /* instance# of caller */
  dbtotal            number,                 /* total no. of known databases */
  dbactive           number,         /* total no. of participating databases */
  location           varchar2(128),         /* db unique name of coordinator */
  init_time          timestamp,            /* timestamp of last init attempt */
  build_time         timestamp,           /* timestamp of last build attempt */
  start_time         timestamp,           /* timestamp of last start attempt */
  switch_time        timestamp,      /* timestamp of last switchover attempt */
  finish_time        timestamp,          /* timestamp of last finish attempt */
  last_instid        number,          /* inst id of last completed operation */
  last_batchid       number,             /* batch id of last completed batch */
  spare1             number,
  spare2             number,
  spare3             varchar2(128)
) tablespace SYSTEM LOGGING
/

Rem *************************************************************************
Rem RDBMS rolling upgrades via DBMS_ROLLING package - END
Rem *************************************************************************

Rem *************************************************************************
Rem Materialized views - BEGIN
Rem *************************************************************************

update sys.snap$ set flag3 = 0 where flag3 is null;

Rem *************************************************************************
Rem Materialized views - END
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 13243011: Drop library and package for SYS.DBMS_DBLINK - BEGIN
Rem *************************************************************************

drop  library  sys.dbms_dblink_lib;
drop  package  sys.dbms_dblink;

Rem *************************************************************************
Rem Bug 13243011: Drop library and package for SYS.DBMS_DBLINK - END
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 14369888: Drop library and package for dbms_appctx - BEGIN
Rem ************************************************************************* 

drop library dbms_appctx_lib;
drop package dbms_appctx;

Rem *************************************************************************
Rem Bug 14369888: Drop library and package for dbms_appctx - END
Rem *************************************************************************
  
Rem *************************************************************************
Rem New domain index changes for 12g - BEGIN
Rem *************************************************************************

alter table indpart_param$ add (flags NUMBER default 0);

Rem *************************************************************************
Rem New domain index changes for 12g - END
Rem *************************************************************************



Rem 
Rem grant all new system privileges to dba role. 
Rem NOTE: please do not move the following grant statement upper in this 
Rem       script or add new privileges after this point.  This statement 
Rem       should be the last to execute in this script to make sure all
Rem       new privileges (added above) are granted to DBA. 
grant all privileges, select any dictionary, analyze any dictionary to dba with admin option; 

Rem *************************************************************************
Rem CLI static dictionary tables for 12g - BEGIN
Rem *************************************************************************

CREATE SEQUENCE CLI_ID$
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  NOMAXVALUE
  NOCACHE
  ORDER
  NOCYCLE
/

CREATE TABLE CLI_LOG$ (
   GUID          VARCHAR2(32) NOT NULL,      /* guid associated with the log */
   USER#         NUMBER,                     /* uid associated with this log */
   NAME          VARCHAR2(128),                                  /* log-name */
   CLIENT#       NUMBER,                           /* client-id for this log */
   LOG#          NUMBER UNIQUE,                                    /* log-id */
   FLAGS         NUMBER,                                        /* log-flags */
   LOB_FLAGS     NUMBER,                               /* securefile options */
   RETENTION     NUMBER,                                    /* lob-retention */
   PART_SIZE     NUMBER,                            /* target partition size */
   HIGH_TAB#     NUMBER,                        /* highest tab# for this log */
   SPARE1        NUMBER,
   SPARE2        NUMBER,
   SPARE3        NUMBER,
   SPARE4        NUMBER,
   CONSTRAINT CLI_LOG$PK PRIMARY KEY (GUID, USER#, NAME)
)
/

CREATE TABLE CLI_TAB$ (
   GUID              VARCHAR2(32) NOT NULL,          /* guid can import from */
                                                             /* different db */
   USER#             NUMBER,                                        /* owner */
   LOG#              NUMBER,                                       /* log-id */
   TAB#              NUMBER,              /* seq# associated with this table */
   VER#              NUMBER,                        /* schema version number */
   NAME              VARCHAR2(128),       /* name associated with this table */
   FLAGS             NUMBER,                 /* current value for this table */
   LOB_FLAGS         NUMBER,                           /* securefile options */
   CUR_TS#           NUMBER, /* current tablespace for the highest partition */
   CRT_SCN           NUMBER,                           /* table creation scn */
   CRT_TIME            DATE,                          /* table creation time */
   MIN_SCN           NUMBER,             /* min scn of records stored in tab */
   MIN_TIME            DATE,            /* min time of records stored in tab */
   HIGH_PART#        NUMBER,                     /* highest partition number */
   NUM_PARTS         NUMBER,          /* number of partitions for this table */
   SPARE1            NUMBER,
   SPARE2            NUMBER,
   SPARE3            NUMBER,
   SPARE4            NUMBER,
   CONSTRAINT CLI_TAB$PK PRIMARY KEY (GUID, USER#, LOG#, TAB#)
)
/
   

CREATE TABLE CLI_INST$ (
   GUID               VARCHAR2(32),                                  /* guid */
   USER#              NUMBER,                                       /* owner */
   LOG#               NUMBER,                                      /* log-id */
   INST#              NUMBER,                                 /* instance-id */
   FLAGS              NUMBER,                      /* current instance flags */
   MAX_BUCKET#        NUMBER,      /* max number of buckets in this instance */
   NUM_BUCKETS        NUMBER,             /* num buckets at last incarnation */
   INC_SCN            NUMBER,           /* scn when this was last incarnated */
   INC_TIME             DATE,          /* time when this was last incarnated */
   CRT_SCN            NUMBER,                   /* scn when this was created */
   CRT_TIME             DATE,                  /* time when this was created */
   INC#               NUMBER,                 /* instance incarnation number */
   SPARE1             NUMBER,
   SPARE2             NUMBER,
   SPARE3             NUMBER,
   SPARE4             NUMBER,
   CONSTRAINT CLI_INST$PK PRIMARY KEY (GUID, USER#, LOG#, INST#)
)
/


CREATE TABLE CLI_PART$ (
  GUID            VARCHAR2(32) NOT NULL,                             /* guid */
  USER#           NUMBER,                                           /* owner */
  LOG#            NUMBER,                                          /* log-id */
  TAB#            NUMBER,                                    /* table number */
  PART#           NUMBER,                                /* partition number */
  TS#             NUMBER,              /* tablespace number of the partition */
  LOB_FLAGS       NUMBER,                              /* securefile options */
  NAME            VARCHAR2(128),                           /* partition name */
  PART_SCN        NUMBER,                    /* SCN at the time of partition */
  PART_TIME         DATE,              /* timestamp at the time of partition */
  MIN_SCN         NUMBER,  /* min-scn column in all entries in the partition */
  MIN_TIME          DATE,   /* min-ts column in all entries in the partition */
  SPARE1          NUMBER,
  SPARE2          NUMBER,
  SPARE3          NUMBER,
  SPARE4          NUMBER,
  CONSTRAINT CLI_PART$PK PRIMARY KEY (GUID, USER#, LOG#, TAB#, PART#)
)
/

CREATE TABLE CLI_TS$ (
  GUID           VARCHAR2(32),                                       /* guid */
  USER#          NUMBER,                                 /* owner of the log */
  LOG#           NUMBER,                                            /* logid */
  TS#            NUMBER,                                              /* tsn */
  FLAGS          NUMBER,                                            /* flags */
  NUM_PARTS      NUMBER,                                 /* # of partititons */
  SPARE1         NUMBER,
  SPARE2         NUMBER,
  CONSTRAINT CLI_TS$PK PRIMARY KEY(GUID, USER#, LOG#, TS#)
)
/


Rem *************************************************************************
Rem CLI static dictionary tables for 12g - END
Rem *************************************************************************

Rem *************************************************************************
Rem Stats history purging changes - BEGIN
Rem *************************************************************************

-- drop indexes on wri$_optstat_hist*_history so we can modify 
-- their columns
-- both indexes are re-created in a1102000.sql
drop index i_wri$_optstat_hh_obj_icol_st;

begin
  execute immediate 'alter table wri$_optstat_histhead_history modify colname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

drop index i_wri$_optstat_h_obj#_icol#_st;

begin
  execute immediate 'alter table wri$_optstat_histgrm_history modify colname varchar2(128)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

Rem *************************************************************************
Rem New histogram types changes for 12g - BEGIN
Rem *************************************************************************

Rem Add columns to accommodate endpoint actual values	
alter table histgrm$ add epvalue_raw raw(1000);
alter table wri$_optstat_histgrm_history add epvalue_raw raw(1000);	
alter table finalhist$ add epvalue_raw raw(1000);	

Rem Add columns to accommodate endpoint repeat count information
alter table histgrm$ add ep_repeat_count number default 0 not null;
alter table finalhist$ add eprepcnt number default 0 not null;

Rem 14373728: For histogram/hist_head history table, first add savtime_date 
Rem column for stats history purging changes
Rem 26657382: no need to check first whether it is already there. The error 
Rem will be automatically suppressed during the upgrade (upgrade mode includes
Rem automatic suppresssion of most "does not exist" and "already exists" 
Rem errors
alter table wri$_optstat_histhead_history 
  add savtime_date as (trunc(savtime));

alter table wri$_optstat_histgrm_history 
  add savtime_date as (trunc(savtime));

alter table wri$_optstat_histgrm_history 
      add ep_repeat_count number default 0 not null;

Rem Extend the length of the min/max value columns in column statistics tables
alter table hist_head$ modify (lowval raw(1000));
alter table hist_head$ modify (hival raw(1000));
   
alter table wri$_optstat_histhead_history modify (lowval raw(1000));
alter table wri$_optstat_histhead_history modify (hival raw(1000));

Rem *************************************************************************
Rem Optimizer stats history changes - BEGIN
Rem *************************************************************************
-- bug 26657382/rti 20648269
-- Converting non-partitioned stats history and synopsis tables in 
-- a&upgrade_file is problematic.
-- XDB validate procedure gets called at end of XDB install.
-- It happens before a&upgrade_file.sql. During validatexdb procedure, it
-- goes to SYS.UTL_RECOMP.SELECT_INVALID_PARALLEL_OBJS which calls
-- SYS.DBMS_STATS.GATHER_TABLE_STATS. The code relies on stats history tables
-- already partitioned. 
alter session set events  '14524 trace name context forever, level 1';

-- this event is needed to copy the src table's column property into 
-- destination. In particular, if the src table has a virutal column,
-- without this event a non virtual column will be created in the 
-- destination table. With the event, a virtual column is created in the 
-- destination
alter session set events '14529 trace name context forever, level 512';

declare
  type       varchartab is table of varchar2(128);  
  cnt        number := 0;  
  colnames   varchartab := varchartab();
  cur_time   timestamp with time zone := systimestamp;
  cur_date   date           := cast(cur_time as date);
  p_old_d    varchar2(512)  := to_char(cur_date, 'dd-mm-yyyy hh:mi:ss');
  p_perm_d   varchar2(512)  := to_char(cur_date+0.000012, 
                                       'dd-mm-yyyy hh:mi:ss');
  txt        varchar2(4000);
  tmptabname varchar2(30);
begin
  -- U1. Check if wri$_optstat_histhead_history has already been 
  -- partitioned
  select count(*) into cnt
  from obj$ o, user$ u
  where o.owner# = u.user# and u.name = 'SYS' and
        o.name = 'WRI$_OPTSTAT_HISTHEAD_HISTORY' and 
        o.subname is not null;

  if (cnt > 0) then
    -- partitioned, no op
    return;
  end if;

  -- U2. generate unique name
  select 'HISTHEAD_HISTORY2' || to_char(systimestamp,'yymmddhhmiss')
  into tmptabname
  from dual; 

  -- U3. Create a new partitioned table tmptabname which
  -- has the same schema as wri$_optstat_histhead_history, and is interval 
  -- partitioned based on savtime_date column with two default partitions, 
  -- p_old and p_permanent, with boundary values (current timestamp) and 
  -- (current timestamp + 1 sec) respectively, where p_old is a place holder 
  -- to plugin the existing statistics history, while p_permanent will be 
  -- permanently  kept, as interval partitioning does not allow dropping the 
  -- newest range partition.

  -- Adapt schema accordingly depending on schema of wri$_optstat_histhead_
  -- history (the order of columns in tmptabname must 
  -- match that of wri$_optstat_histhead_history)
  txt :=
        'create table ' || tmptabname ||
        q'# partition by range (savtime_date)
        interval (numtodsinterval(1,'day'))
        (partition p_old values less than (to_date('#' || p_old_d
         || q'#', 'dd-mm-yyyy hh:mi:ss')),
         partition p_permanent values less than (to_date('#' || p_perm_d
         || q'#', 'dd-mm-yyyy hh:mi:ss')))
        tablespace sysaux
        pctfree 1
        enable row movement 
        as select * from wri$_optstat_histhead_history where 1=0 #';
  
  execute immediate txt;

  -- U4. Transfer pending stats (if any) into the new table
  -- Insert pending stats (if any) into the new table.
  -- New table tmptabname has virtual column, cannot use
  --   insert into tmptabname
  --   select * from wri$_optstat_histhead_history
  -- exclude virtual columns since we cannot directly populate 
  -- virtual columns
  select c.name bulk collect into colnames
  from obj$ o, user$ u, col$ c
  where o.owner# = u.user# and u.name = 'SYS' and
        o.name = 'WRI$_OPTSTAT_HISTHEAD_HISTORY' and o.subname is null and
        o.obj# = c.obj# and
        -- virtual_column = 'NO' in all_tab_cols$
        decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')) = 'NO'
  order by c.intcol#;
    
  txt := '';
  for i in 1..colnames.count loop
    txt := txt || colnames(i);
    if (i < colnames.count) then
      -- more columns to follow
      txt := txt || ',';
    else
      txt := txt || ' ';
    end if;
  end loop;

  execute immediate
      'insert into ' || tmptabname ||  '( ' ||
      txt || ') ' ||
      ' select ' || txt ||
      ' from wri$_optstat_histhead_history 
        where savtime > :1 ' using cur_time;
     
  commit;

  -- delete the pending stats (if any) from the old table
  execute immediate 
      'delete from wri$_optstat_histhead_history where savtime > :1'
      using cur_time;

  commit;

  -- U5. Plug-in wri$_optstat_histhead_history as a partition of 
  -- tmptabname
  execute immediate
    ' alter table ' || tmptabname || 
    ' exchange partition p_old 
      with table wri$_optstat_histhead_history without validation 
      update global indexes ';

  -- U6. Drop table wri$_optstat_histhead_history.
  execute immediate q'#drop table wri$_optstat_histhead_history#';

  -- U7. Rename tmptabname into wri$_optstat_histhead_history.
  execute immediate 
    ' alter table ' || tmptabname || 
    ' rename to wri$_optstat_histhead_history';

  execute immediate
    q'#create index i_wri$_optstat_hh_st on
       wri$_optstat_histhead_history (savtime)
       parallel tablespace sysaux #';
       
  execute immediate
    q'#alter index i_wri$_optstat_hh_st noparallel #';

end;
/

declare
  type       varchartab is table of varchar2(128);  
  cnt        number := 0;  
  colnames   varchartab := varchartab();
  cur_time   timestamp with time zone := systimestamp;
  cur_date   date           := cast(cur_time as date);
  p_old_d    varchar2(512)  := to_char(cur_date, 'dd-mm-yyyy hh:mi:ss');
  p_perm_d   varchar2(512)  := to_char(cur_date+0.000012, 
                                       'dd-mm-yyyy hh:mi:ss');
  txt        varchar2(4000);
  tmptabname varchar2(30);
begin
  -- U1. Check if wri$_optstat_histgrm_history has been partitioned
  select count(*) into cnt
  from obj$ o, user$ u
  where o.owner# = u.user# and u.name = 'SYS' and
        o.name = 'WRI$_OPTSTAT_HISTGRM_HISTORY' and 
        o.subname is not null;  

  if (cnt > 0) then
    -- has been partitioned, do nothing
    return;
  end if;

  -- U2. generate unique name
  select 'HISTGRM_HISTORY2' || to_char(systimestamp,'yymmddhhmiss')
  into tmptabname
  from dual; 

  -- U3. Create a new partitioned table tmptabname which
  -- has the same schema as wri$_optstat_histgrm_history, and is interval 
  -- partitioned based on savtime_date column with two default partitions.
   
  -- Adapt schema accordingly depending on schema of wri$_optstat_histgrm_
  -- history (the order of columns in tmptabname must
  -- match that of wri$_optstat_histgrm_history)
  txt :=
       'create table ' || tmptabname ||
        q'# partition by range (savtime_date)
         interval (numtodsinterval(1,'day'))
         (partition p_old values less than (to_date('#' || p_old_d
           || q'#', 'dd-mm-yyyy hh:mi:ss')),
          partition p_permanent values less than (to_date('#' ||
            p_perm_d || q'#', 'dd-mm-yyyy hh:mi:ss')))
          tablespace sysaux
          pctfree 1
          enable row movement 
          as select * from wri$_optstat_histgrm_history where 1 = 0#'; 
  
  execute immediate txt;
    
  -- U4. Transfer pending stats (if any) into the new table
  -- Insert pending stats (if any) into the new table
  -- tmptabname has virtual column, cannot use
  --   insert into tmptabname
  --   select * from wri$_optstat_histgrm_history
  select c.name bulk collect into colnames
  from obj$ o, user$ u, col$ c
  where o.owner# = u.user# and u.name = 'SYS' and
        o.name = 'WRI$_OPTSTAT_HISTGRM_HISTORY' and o.subname is null and
        o.obj# = c.obj# and
        -- virtual_column = 'NO' in all_tab_cols$
        decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')) = 'NO'
  order by intcol#;
    
  txt := '';
  for i in 1..colnames.count loop
    txt := txt || colnames(i);
    if (i < colnames.count) then
      -- more columns to follow
      txt := txt || ',';
    else
      txt := txt || ' ';
    end if;
  end loop;
       
  execute immediate
      'insert into ' || tmptabname || '(' ||
       txt || ')' ||
      ' select ' || txt ||
      ' from wri$_optstat_histgrm_history 
        where savtime > :1 ' using cur_time;

  commit;

  -- delete the pending stats (if any) from the old table
  execute immediate 
    'delete from wri$_optstat_histgrm_history where savtime > :1'
  using cur_time;
  commit;

  -- U5. Plug-in wri$_optstat_histgrm_history as a partition of 
  -- tmptabname
  execute immediate
    'alter table ' || tmptabname || ' exchange partition p_old 
     with table wri$_optstat_histgrm_history without validation 
     update global indexes ';

  -- U6. Drop table wri$_optstat_histgrm_history.
  execute immediate q'#drop table wri$_optstat_histgrm_history#';

  -- U7. Rename tmptabname 
  execute immediate 
    'alter table ' || tmptabname ||
    ' rename to wri$_optstat_histgrm_history';

  execute immediate
    q'#create index i_wri$_optstat_h_st on
       wri$_optstat_histgrm_history (savtime)
       parallel tablespace sysaux #';

  execute immediate
    q'#alter index i_wri$_optstat_h_st noparallel #';
end;
/

-- turn off event for CTAS
alter session set events '14529 trace name context off';

-- #(19855835): make wri* indexes as parallel
create unique index i_wri$_optstat_hh_obj_icol_st on
       wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
       parallel tablespace sysaux;
alter index i_wri$_optstat_hh_obj_icol_st noparallel;

-- #(19855835): make wri* indexes as parallel
create index i_wri$_optstat_h_obj#_icol#_st on
       wri$_optstat_histgrm_history (obj#, intcol#, savtime, colname)
       parallel tablespace sysaux;
alter index i_wri$_optstat_h_obj#_icol#_st noparallel;

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

Rem *************************************************************************
Rem Optimizer stats history changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem #(18255105) : As part of bug fix 12555499 we changed the algorithm for 
Rem  calculating hashvalue of char type values. So for all tables with char 
Rem  columns need to re-gather the histograms. Mark mon_mods_all$ entries with 
Rem  truncated stats flag, so that next gather_stats will re-gather the 
Rem  stats for such tables.
Rem *************************************************************************

  merge into sys.mon_mods_all$ m
    using
   (select /*+ leading(tab) dynamic_sampling(4) dynamic_sampling_est_cdn */
      tab.obj# obj#, 0 inserts, 0 updates, 0 deletes, sysdate timestamp,
      1 flags, 0 drop_segments
    from
      (select t.obj# from sys.tab$ t /* non-partitioned tables */
         /* 
          * #(24309782):
          * Temp tables are volatile. Avoid marking them as stale and get
          * picked up by manually gather stats with STALE option 
          * where these tables will not have any data
          * when stats are gathered.
          * All other types should be considered if it has stats.
          */
         where bitand(t.property,4194304+8388608) = 0
               /* If table is non-partitioned or partitioned table 
                * with global stats 
                */
           and (bitand(t.property,32) = 0 OR
                (bitand(t.property,32) = 32 and bitand(t.flags, 512) = 512))
           and bitand(t.flags,16) != 0       /* analyzed */
           and exists (select 1 from sys.col$ c, sys.histgrm$ h
                        where c.obj# = t.obj#
                          and c.intcol# = h.intcol# /* histograms collected */
                          and t.obj# = h.obj#
                          and c.type# = 96)             /* char type column */
      union all                              /* table partitions */
      select tp.obj# from sys.tabpart$ tp, sys.tab$ t
         where tp.bo# = t.obj#
           and bitand(tp.flags,2) != 0       /* analyzed */
           and exists (select 1 from sys.col$ c, sys.histgrm$ h
                        where c.obj# = t.obj#
                          and c.intcol# = h.intcol# /* histograms collected */
                          and tp.obj# = h.obj#
                          and c.type# = 96)            /* char type column */
      /* #(24309782) Consider composite partitions */
      union all                             /* table partitions (composite) */
      select tp.obj# from sys.tabcompart$ tp, sys.tab$ t
         where tp.bo# = t.obj#
           and bitand(tp.flags,2) != 0       /* analyzed */
           and exists (select 1 from sys.col$ c, sys.histgrm$ h
                        where c.obj# = t.obj#
                          and c.intcol# = h.intcol# /* histograms collected */
                          and tp.obj# = h.obj#
                          and c.type# = 96)            /* char type column */
      union all                              /* table subpartitions */
      select tsp.obj# from sys.tabsubpart$ tsp,
                           sys.tabcompart$ tp, sys.tab$ t
         where tsp.pobj# = tp.obj# and tp.bo# = t.obj#
           and bitand(tsp.flags,2) != 0      /* analyzed */
           and exists (select 1 from sys.col$ c, sys.histgrm$ h
                        where c.obj# = t.obj#
                          and c.intcol# = h.intcol# /* histograms collected */
                          and tsp.obj# = h.obj#
                          and c.type# = 96)            /* char type column */
      ) tab, obj$ o
      /* #(24309782) avoid dropped objects */
      where tab.obj# = o.obj# 
        and bitand(o.flags, 128) != 128              /* not in recycle bin */
    ) v on (m.obj# = v.obj#)
    when matched then
                                             /* set stats as truncated */
      update set flags = flags - bitand(flags,1) + 1
    when NOT matched then
      insert values
        (v.obj#, v.inserts, v.updates, v.deletes, v.timestamp,
         v.flags, v.drop_segments);

Rem *************************************************************************
Rem #(18255105) : END
Rem *************************************************************************

Rem *************************************************************************
Rem #(13898075) BEGIN
Rem *************************************************************************

-- Increase the size of valchar column
-- Note that there is no downgrade action as server code handles
-- this new length
alter table optstat_user_prefs$ modify valchar varchar2(4000);

Rem *************************************************************************
Rem #(13898075) END
Rem *************************************************************************

Rem *************************************************************************
Rem Upgrade aq$_subscriber - START
Rem *************************************************************************
ALTER TYPE sys.aq$_subscriber ADD ATTRIBUTE
  (subscriber_id NUMBER,                                   -- subscriber id
   pos_bitmap    NUMBER     -- subscriber position in bitmap for 12c queues
  )
CASCADE
/

Rem *************************************************************************
Rem Upgrade aq$_subscriber - END
Rem *************************************************************************

Rem *************************************************************************
Rem Begin evaluation edition changes
Rem *************************************************************************

alter table snap$ add (eval_edition varchar2(128))
/
alter table sum$ add
  (evaledition# number, unusablebefore# number, unusablebeginning# number)
/
update sum$ set evaledition#=0, unusablebefore#=0, unusablebeginning#=0
/
commit;

Rem *************************************************************************
Rem End evaluation edition changes
Rem *************************************************************************


Rem *************************************************************************
Rem Bug 14228510: increase max number of editions
Rem *************************************************************************

create table edition$mig (obj#, p_obj#, flags, code, audit$, spare1, spare2) as
  select obj#, p_obj#, flags, to_blob(code), audit$, spare1, spare2 
  from edition$;
alter table edition$ rename to edition$old;
alter table edition$mig rename to edition$;
drop table edition$old;

Rem *************************************************************************
Rem End Bug 14228510: increase max number of editions
Rem *************************************************************************


Rem *************************************************************************
Rem Begin upgrade to undohist$ changes
Rem
Rem undohist$ stores undo$ attributes of every incarnation of 
Rem an undo segment number. history for system undo segment is not available
Rem as it is never dropped.
Rem *************************************************************************

create table undohist$
( 
  us#         number not null,                        /* undo segment number */
  inc#        number not null,                         /* incarnation number */
  tsn         number not null,              /* useg header tablespace number */
  file#       number not null,           /* useg header relative file number */
  block#      number not null,                   /* useg header block number */
  crscnwrp    number not null,                          /* creation scn-wrap */
  crscnbas    number not null,                          /* creation scn-base */
  drscnwrp    number not null,                              /* drop scn-wrap */
  drscnbas    number not null,                              /* drop scn-base */
  crttime     number not null,                              /* creation time */
  drptime     number not null,                                  /* drop time */
  name        varchar2(30) not null,            /* name of this undo segment */
  user#       number not null,        /* owner: 0 = SYS(PRIVATE), 1 = PUBLIC */
  scnwrp      number,                /* scnbas - scn base, scnwrp - scn wrap */
  scnbas      number,             /* highest commit time in rollback segment */
  xactsqn     number,                 /* highest transaction sequence number */
  undosqn     number,                  /* highest undo block sequence number */
  inst#       number,      /* parallel server instance that owns the segment */
  flags1      number,                                     /* spare1 of undo$ */
  spare1      number, 
  spare2      number,
  spare3      number, 
  spare4      number,
  spare5      number, 
  spare6      number,
  spare7      number,
  spare8      number
)
/

create unique index i_undohist1 on undohist$(us#, inc#)
/

Rem Add existing valid USN entries (except SYSTEM) to undohist$

begin

  insert /*+ append */  into undohist$
    (us#, inc#, tsn, file#, block#, crscnwrp, crscnbas, drscnwrp, drscnbas, 
     crttime, drptime, name, user#, scnwrp, scnbas, xactsqn, undosqn, inst#, 
     flags1)
        (select us#, 1, ts#, file#, block#, 
         0, 0, 0, 0, 0, 0,  
         name, user#, scnwrp, scnbas, xactsqn, undosqn, inst#, spare1 
         from undo$  where status$ != 1 and us# > 0);
  commit;

exception
  when others then
    if sqlcode = -00001 then 
      null; 
    else 
      raise; 
    end if;  
end;
/
show errors;


Rem *************************************************************************
Rem End upgrade to undohist$ changes
Rem *************************************************************************


Rem *************************************************************************
Rem Make system/sysaux force logging
Rem *************************************************************************
begin
  execute immediate 'alter tablespace system force logging';
exception when others then
  if sqlcode in (-12924) then null;
  else raise;
  end if;
end;
/

begin 
  execute immediate 'alter tablespace sysaux force logging'; 
exception when others then
  if sqlcode in (-12924) then null;
  else raise;
  end if;
end;
/
Rem *************************************************************************
Rem Drop SYSMAN.MGMT_STARTUP trigger forcefully inline to upgrade to 12.1
Rem *************************************************************************
declare
l_count number := 0;
begin
    select count(*) into l_count from all_objects where object_name='MGMT_STARTUP' and owner='SYSMAN' and object_type='TRIGGER';
    if l_count > 0 then
    begin
        execute immediate 'drop trigger SYSMAN.MGMT_STARTUP';
    exception when others then
        if sqlcode in (-12924) then null;
        else raise;
        end if;
    end;
    end if;
end;
/

Rem *************************************************************************
Rem insert dbid in WRM$_BASELINE for imported database also
Rem *************************************************************************

BEGIN
  execute immediate
   'insert into WRM$_BASELINE
      (dbid, baseline_id, baseline_name, start_snap_id, end_snap_id,
       baseline_type, moving_window_size, creation_time,
       expiration, template_name, last_time_computed)
    select 
        dbid, 0, ''SYSTEM_MOVING_WINDOW'', NULL, NULL,
        ''MOVING_WINDOW'', LEAST(91, extract(DAY from retention)), SYSDATE,
        NULL, NULL, NULL
     from WRM$_WR_CONTROL
    where not exists (select 1 from wrm$_baseline b where b.dbid = dbid and b.baseline_id = 0)';
  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001, -942 ) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

Rem *************************************************************************
Rem Bug 14355614: Mark sensitive columns of non-bootstrap dictionary tables.
Rem Column is marked as sensitive by setting the 'sensitive column' bit
Rem (i.e, KQLDCOP2_SEN which has decimal value 8796093022208) in col$.property.
Rem Sensitive columns from non-bootstrap dictionary tables are:
Rem XS$VERIFIERS.VERIFIER
Rem LINK$.PASSWORDX, LINK$.AUTHPWDX, LINK$.PASSWORD
Rem LINK$.AUTHPWD
Rem ENC$.COLKLC
Rem USER_HISTORY$.PASSWORD
Rem CDB_LOCAL_ADMINAUTH$.PASSWD
Rem *************************************************************************

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name = 'VERIFIER' and obj# = (select obj# from obj$ where name = 'XS$VERIFIERS' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name in ('PASSWORDX', 'AUTHPWDX', 'PASSWORD', 'AUTHPWD') and obj# = (select obj# from obj$ where name = 'LINK$' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name = 'COLKLC' and obj# = (select obj# from obj$ where name = 'ENC$' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name = 'PASSWORD' and obj# = (select obj# from obj$ where name = 'USER_HISTORY$' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name = 'PASSWD' and obj# = (select obj# from obj$ where name = 'CDB_LOCAL_ADMINAUTH$' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/

Rem *************************************************************************
Rem END Bug 14355614 Mark sensitive columns of non-bootstrap dictionary tables
Rem *************************************************************************

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

DECLARE
  capno number;
  cursor c1 is select CAP_NUMBER from HS_BASE_CAPS where CAP_NUMBER >= 1000;
BEGIN

  open c1;

  LOOP
    fetch c1 into capno;
      exit when c1%NOTFOUND;

    dbms_hs.drop_base_caps(capno);
  END LOOP;

END;
/

exec dbms_hs.replace_base_caps(5000, 5000, 'multicolumn: (a,b,c)=');
exec dbms_hs.replace_base_caps(5001, 5001, 'join');
exec dbms_hs.replace_base_caps(5002, 5002, 'outer join');
exec dbms_hs.replace_base_caps(5003, 5003, 'delimited IDs: "id"');
exec dbms_hs.replace_base_caps(5004, 5004, 'SELECT DISTINCT');
exec dbms_hs.replace_base_caps(5005, 5005, 'DISTINCT in aggregate functions');
exec dbms_hs.replace_base_caps(5006, 5006, 'ROWNUM');
exec dbms_hs.replace_base_caps(5007, 5007, 'subquery');
exec dbms_hs.replace_base_caps(5008, 5008, 'GROUP BY');
exec dbms_hs.replace_base_caps(5009, 5009, 'HAVING');
exec dbms_hs.replace_base_caps(5010, 5010, 'ORDER BY');
exec dbms_hs.replace_base_caps(5011, 5011, 'CONNECT BY');
exec dbms_hs.replace_base_caps(5012, 5012, 'START WITH');
exec dbms_hs.replace_base_caps(5013, 5013, 'WHERE');
exec dbms_hs.replace_base_caps(5014, 5014, 'callback');
exec dbms_hs.replace_base_caps(5015, 5015, 'add redundant local filters');
exec dbms_hs.replace_base_caps(5016, 5016, 'ROWID');
exec dbms_hs.replace_base_caps(5017, 5017, 'ANY');
exec dbms_hs.replace_base_caps(5018, 5018, 'ALL');
exec dbms_hs.replace_base_caps(5019, 5019, 'EXISTS');
exec dbms_hs.replace_base_caps(5020, 5020, 'NOT EXISTS');
exec dbms_hs.replace_base_caps(5021, 5021, 'nls parameters');
exec dbms_hs.replace_base_caps(5022, 5022, 'describe index');
exec dbms_hs.replace_base_caps(5023, 5023, 'distributed read consistency');
exec dbms_hs.replace_base_caps(5024, 5024, 'bundled calls');
exec dbms_hs.replace_base_caps(5025, 5025, 'evaluate USER, UID, SYDATE local');
exec dbms_hs.replace_base_caps(5026, 5026, 'KGL operation for PL/SQL RPC');
exec dbms_hs.replace_base_caps(5027, 5027, 'NVL: change ANSI to ORA compare');
exec dbms_hs.replace_base_caps(5028, 5028, 'remote mapping of queries');
exec dbms_hs.replace_base_caps(5029, 5029, '2PC type (RO-SS-CC-PREP/2P-2PCC)');
exec dbms_hs.replace_base_caps(5030, 5030, 'streamed protocol version number');
exec dbms_hs.replace_base_caps(5031, 5031, 'special non-optdef functions');
exec dbms_hs.replace_base_caps(5032, 5032, 'CURRVAL and NEXTVAL');
exec dbms_hs.replace_base_caps(5033, 5033, 'hints (inline comments and aliases');
exec dbms_hs.replace_base_caps(5034, 5034, 'remote sort by index access');
exec dbms_hs.replace_base_caps(5035, 5035, 'use universal rowid for rowids');
exec dbms_hs.replace_base_caps(5036, 5036, 'wait option in select for update');
exec dbms_hs.replace_base_caps(5037, 5037, 'connect by order siblings by');
exec dbms_hs.replace_base_caps(5038, 5038, 'On clause');
exec dbms_hs.replace_base_caps(5039, 5039, 'no supprt for rem extended partn');
exec dbms_hs.replace_base_caps(5040, 5040, 'SPREADSHEET clause');
exec dbms_hs.replace_base_caps(5041, 5041, 'Merge optional WHERE clauses');
exec dbms_hs.replace_base_caps(5042, 5042, 'connect by nocycle');
exec dbms_hs.replace_base_caps(5043, 5043, 'connect by enhancements: connect_by_iscycle, connect_by_isleaf');
exec dbms_hs.replace_base_caps(5044, 5044, 'Group Outer-Join');
exec dbms_hs.replace_base_caps(5045, 5045, ' u''xxx\ffff''');
exec dbms_hs.replace_base_caps(5046, 5046, '"with check option" in from-clause subqueries');
exec dbms_hs.replace_base_caps(5047, 5047, 'new connect-by');
exec dbms_hs.replace_base_caps(5048, 5048, 'native full outer join');
exec dbms_hs.replace_base_caps(5049, 5049, 'recursive WITH');
exec dbms_hs.replace_base_caps(5050, 5050, 'column alias list for WITH clause');
exec dbms_hs.replace_base_caps(5051, 5051, 'WAIT option in LOCK TABLE');
exec dbms_hs.replace_base_caps(5963, 5963, 'FDS can not DescribeParam after Exec in Transact SQL');
exec dbms_hs.replace_base_caps(5964, 5964, 'FDS can handle schema in queries');
exec dbms_hs.replace_base_caps(5965, 5965, 'Null is Null');
exec dbms_hs.replace_base_caps(5966, 5966, 'ANSI Decode (CASE) support');
exec dbms_hs.replace_base_caps(5967, 5967, 'Result set support');
exec dbms_hs.replace_base_caps(5968, 5968, 'Piecewise fetch and exec');
exec dbms_hs.replace_base_caps(5969, 5969, 'How to handle PUBLIC schema');
exec dbms_hs.replace_base_caps(5970, 5970, 'Subquery in having clause is supported');
exec dbms_hs.replace_base_caps(5971, 5971, 'Do not close and re-parse on re-exec of SELECTs');
exec dbms_hs.replace_base_caps(5972, 5972, 'Informix related cap: Add space before negative numeric literals');
exec dbms_hs.replace_base_caps(5973, 5973, 'Informix related cap: Add extra parenthesis for update sub-queries to make it a list');
exec dbms_hs.replace_base_caps(5974, 5974, 'DB2-related cap: Change empty str assigns to null assigns');
exec dbms_hs.replace_base_caps(5975, 5975, 'DB2-related cap: Zero length bind not same as null bind');
exec dbms_hs.replace_base_caps(5976, 5976, 'DB2-related cap: Add space after comma');
exec dbms_hs.replace_base_caps(5977, 5977, 'DB2-related cap: Order-by clause contains only numbers');
exec dbms_hs.replace_base_caps(5978, 5978, 'DB2-related cap: Change empty string comparisons to is null');
exec dbms_hs.replace_base_caps(5979, 5979, 'Implicit Coercion cap: Comparison of two objrefs');
exec dbms_hs.replace_base_caps(5980, 5980, 'Implicit Coercion cap: Comparison of objref and bindvar');
exec dbms_hs.replace_base_caps(5981, 5981, 'Implicit Coercion cap: Comparison of objref and literal');
exec dbms_hs.replace_base_caps(5982, 5982, 'Implicit Coercion cap: Comparison of two bindvars');
exec dbms_hs.replace_base_caps(5983, 5983, 'Implicit Coercion cap: Comparison of bindvar and literal');
exec dbms_hs.replace_base_caps(5984, 5984, 'Implicit Coercion cap: Comparison of two literals');
exec dbms_hs.replace_base_caps(5985, 5985, 'Implicit Coercion cap: Assignment of objref to column');
exec dbms_hs.replace_base_caps(5986, 5986, 'Implicit Coercion cap: Assignment of bindvar to column');
exec dbms_hs.replace_base_caps(5987, 5987, 'Implicit Coercion cap: Assignment of literal to column');
exec dbms_hs.replace_base_caps(5988, 5988, 'RPC Bundling Capability');
exec dbms_hs.replace_base_caps(5989, 5989, 'hoatcis() call capability');
exec dbms_hs.replace_base_caps(5990, 5990, 'Quote Owner names in SQL statements');
exec dbms_hs.replace_base_caps(5991, 5991, 'Map Alias to table names in non-select statements');
exec dbms_hs.replace_base_caps(5992, 5992, 'Send Delimited IDs to FDS');
exec dbms_hs.replace_base_caps(5993, 5993, 'HOA Describe Table Call Capability');
exec dbms_hs.replace_base_caps(5994, 5994, 'Raw literal format');
exec dbms_hs.replace_base_caps(5995, 5995, 'FOR UPDATE syntax mapping');
exec dbms_hs.replace_base_caps(5996, 5996, 'Replace NULLs in select list with other constant');
exec dbms_hs.replace_base_caps(5997, 5997, 'flush describe table cache');
exec dbms_hs.replace_base_caps(5998, 5998, 'length of physical part of rowid');
exec dbms_hs.replace_base_caps(5999, 5999, 'Bind to parameter mapping');
exec dbms_hs.replace_base_caps(6000, 6000, 'SELECT ... FOR UPDATE');
exec dbms_hs.replace_base_caps(6001, 6001, 'SELECT');
exec dbms_hs.replace_base_caps(6002, 6002, 'UPDATE');
exec dbms_hs.replace_base_caps(6003, 6003, 'DELETE');
exec dbms_hs.replace_base_caps(6004, 6004, 'INSERT ... VALUES (...)');
exec dbms_hs.replace_base_caps(6005, 6005, 'INSERT ... SELECT ...');
exec dbms_hs.replace_base_caps(6006, 6006, 'LOCK TABLE');
exec dbms_hs.replace_base_caps(6007, 6007, 'ROLLBACK TO SAVEPOINT ...');
exec dbms_hs.replace_base_caps(6008, 6008, 'SAVEPOINT ...');
exec dbms_hs.replace_base_caps(6009, 6009, 'SET TRANSACTION READ ONLY');
exec dbms_hs.replace_base_caps(6010, 6010, 'alter session set nls_* = ...');
exec dbms_hs.replace_base_caps(6011, 6011, 'alter session set GLOBAL_NAMES, OPTIMIZER_GOAL = ..');
exec dbms_hs.replace_base_caps(6012, 6012, 'alter session set REMOTE_DEPENDENCIES_MODE = ..');
exec dbms_hs.replace_base_caps(6013, 6013, 'set transaction isolation level serializable');
exec dbms_hs.replace_base_caps(6014, 6014, 'set constraints all immediate');
exec dbms_hs.replace_base_caps(6015, 6015, 'alter session set SKIP_UNUSABLE_INDEXES = ..');
exec dbms_hs.replace_base_caps(6016, 6016, 'alter session set time_zone - its absolete now');
exec dbms_hs.replace_base_caps(6017, 6017, 'alter session set ERROR_ON_OVERLAP_TIME');
exec dbms_hs.replace_base_caps(6018, 6018, 'Upsert');
exec dbms_hs.replace_base_caps(7000, 7000, 'VARCHAR2');
exec dbms_hs.replace_base_caps(7001, 7001, 'INTEGER');
exec dbms_hs.replace_base_caps(7002, 7002, 'DECIMAL');
exec dbms_hs.replace_base_caps(7003, 7003, 'FLOAT');
exec dbms_hs.replace_base_caps(7004, 7004, 'DATE');
exec dbms_hs.replace_base_caps(7005, 7005, 'VARCHAR');
exec dbms_hs.replace_base_caps(7006, 7006, 'SMALL INTEGER');
exec dbms_hs.replace_base_caps(7007, 7007, 'RAW');
exec dbms_hs.replace_base_caps(7008, 7008, 'VAR RAW');
exec dbms_hs.replace_base_caps(7009, 7009, '? RAW');
exec dbms_hs.replace_base_caps(7010, 7010, 'SMALL FLOAT');
exec dbms_hs.replace_base_caps(7011, 7011, 'LONG INT QUADWORD');
exec dbms_hs.replace_base_caps(7012, 7012, 'LEFT OVERPUNCH');
exec dbms_hs.replace_base_caps(7013, 7013, 'RIGHT OVERPUNCH');
exec dbms_hs.replace_base_caps(7014, 7014, 'ROWID');
exec dbms_hs.replace_base_caps(7015, 7015, 'LEFT SEPARATE');
exec dbms_hs.replace_base_caps(7016, 7016, 'RIGHT SEPARATE');
exec dbms_hs.replace_base_caps(7017, 7017, 'OS DATE');
exec dbms_hs.replace_base_caps(7018, 7018, 'OS FULL ==> DATE + TIME');
exec dbms_hs.replace_base_caps(7019, 7019, 'OS TIME');
exec dbms_hs.replace_base_caps(7020, 7020, 'UNSIGNED SMALL INTEGER');
exec dbms_hs.replace_base_caps(7021, 7021, 'BYTE');
exec dbms_hs.replace_base_caps(7022, 7022, 'UNSIGNED BYTE');
exec dbms_hs.replace_base_caps(7023, 7023, 'UNSIGNED INTEGER');
exec dbms_hs.replace_base_caps(7024, 7024, 'CHAR INTEGER');
exec dbms_hs.replace_base_caps(7025, 7025, 'CHAR FLOAT');
exec dbms_hs.replace_base_caps(7026, 7026, 'CHAR DECIMAL');
exec dbms_hs.replace_base_caps(7027, 7027, 'LONG');
exec dbms_hs.replace_base_caps(7028, 7028, 'VARLONG');
exec dbms_hs.replace_base_caps(7029, 7029, 'OS RDATE');
exec dbms_hs.replace_base_caps(7030, 7030, '(RELATIVE) RECORD ADDRESS');
exec dbms_hs.replace_base_caps(7031, 7031, '(RELATIVE) RECORD NUMBER');
exec dbms_hs.replace_base_caps(7032, 7032, 'VARGRAPHIC');
exec dbms_hs.replace_base_caps(7033, 7033, 'VARNUM');
exec dbms_hs.replace_base_caps(7034, 7034, 'NUMBER');
exec dbms_hs.replace_base_caps(7035, 7035, 'ANSI FIXED CHAR');
exec dbms_hs.replace_base_caps(7036, 7036, 'LONG RAW');
exec dbms_hs.replace_base_caps(7037, 7037, 'LONG VARRAW');
exec dbms_hs.replace_base_caps(7038, 7038, 'MLSLABEL');
exec dbms_hs.replace_base_caps(7039, 7039, 'RAW MLSLABEL');
exec dbms_hs.replace_base_caps(7040, 7040, 'CHARZ');
exec dbms_hs.replace_base_caps(7041, 7041, 'BINARY INTEGER');
exec dbms_hs.replace_base_caps(7042, 7042, 'ORACLE DATE');
exec dbms_hs.replace_base_caps(7043, 7043, 'BOOLEAN');
exec dbms_hs.replace_base_caps(7044, 7044, 'CHAR ROWID');
exec dbms_hs.replace_base_caps(7045, 7045, 'UNSIGNED LONG INTEGER');
exec dbms_hs.replace_base_caps(7046, 7046, 'ODBC CHAR DECIMAL');
exec dbms_hs.replace_base_caps(7047, 7047, 'TIMESTAMP');
exec dbms_hs.replace_base_caps(7048, 7048, 'TIMESTAMP WITH TIME ZONE');
exec dbms_hs.replace_base_caps(7049, 7049, 'INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7050, 7050, 'INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7051, 7051, 'TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7052, 7052, 'CHAR TIMESTAMP');
exec dbms_hs.replace_base_caps(7053, 7053, 'CHAR TIMESTAMP WITH TIMEZONE');
exec dbms_hs.replace_base_caps(7054, 7054, 'CHAR INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7055, 7055, 'CHAR INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7056, 7056, 'CHAR TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7057, 7057, 'STRUCT TIMESTAMP');
exec dbms_hs.replace_base_caps(7058, 7058, 'STRUCT TIMESTAMP WITH TIMEZONE');
exec dbms_hs.replace_base_caps(7059, 7059, 'STRUCT INTERVAL - YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7060, 7060, 'STRUCT INTERVAL - DAY TO SECOND');
exec dbms_hs.replace_base_caps(7061, 7061, 'STRUCT TIMESTAMP WITH IMPLICIT TIME ZONE');
exec dbms_hs.replace_base_caps(7062, 7062, 'RESULT SET HANDLE');
exec dbms_hs.replace_base_caps(7063, 7063, 'CLOB');
exec dbms_hs.replace_base_caps(7064, 7064, 'BLOB');
exec dbms_hs.replace_base_caps(7065, 7065, 'BINARY FILE');
exec dbms_hs.replace_base_caps(7066, 7066, 'ODBC DATE');
exec dbms_hs.replace_base_caps(7067, 7067, 'ODBC TIMESTAMP STRUCT');
exec dbms_hs.replace_base_caps(7068, 7068, 'ODBC INVERVAL YEAR TO MONTH');
exec dbms_hs.replace_base_caps(7069, 7069, 'ODBC INTERVAL DATE TO SECOND');
exec dbms_hs.replace_base_caps(7500, 7500, '');
exec dbms_hs.replace_base_caps(7501, 7501, '');
exec dbms_hs.replace_base_caps(7502, 7502, '');
exec dbms_hs.replace_base_caps(7503, 7503, '');
exec dbms_hs.replace_base_caps(7504, 7504, '');
exec dbms_hs.replace_base_caps(7505, 7505, '');
exec dbms_hs.replace_base_caps(7506, 7506, '');
exec dbms_hs.replace_base_caps(7507, 7507, '');
exec dbms_hs.replace_base_caps(7508, 7508, '');
exec dbms_hs.replace_base_caps(7509, 7509, '');
exec dbms_hs.replace_base_caps(7510, 7510, '');
exec dbms_hs.replace_base_caps(7511, 7511, '');
exec dbms_hs.replace_base_caps(7512, 7512, '');
exec dbms_hs.replace_base_caps(7513, 7513, '');
exec dbms_hs.replace_base_caps(7514, 7514, '');
exec dbms_hs.replace_base_caps(7515, 7515, '');
exec dbms_hs.replace_base_caps(7516, 7516, '');
exec dbms_hs.replace_base_caps(7517, 7517, '');
exec dbms_hs.replace_base_caps(7518, 7518, '');
exec dbms_hs.replace_base_caps(7519, 7519, '');
exec dbms_hs.replace_base_caps(8000, 8000, '');

Rem *************************************************************************
Rem END Bug 16025907: Increase the OPN range
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 15892490
Rem  We need to first create the D$ XA views and then
Rem  drop the old V$ XA views to be able to now
Rem  create the V$ XA synonyms. This is to cover the
Rem  case where xaview.sql was run on the source database.
Rem
Rem *************************************************************************

create or replace view d$pending_xatrans$ AS
(SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   sys.pending_trans$ tran, sys.pending_sessions$ sess
   WHERE  tran.local_tran_id = sess.local_tran_id
     AND    tran.state != 'collecting'
     AND    BITAND(TO_NUMBER(tran.session_vector),
                   POWER(2, (sess.session_id - 1))) = sess.session_id)
/

create or replace view d$xatrans$ AS
(((SELECT k2gtifmt, k2gtitid_ext, k2gtibid
   FROM x$k2gte2
   WHERE  k2gterct=k2gtdpct)
 MINUS
  SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   d$pending_xatrans$)
UNION
 SELECT global_tran_fmt, global_foreign_id, branch_id
   FROM   d$pending_xatrans$)
/

-- Delete the previous views before creating the synonyms
drop view v$xatrans$;
drop view v$pending_xatrans$;


-- create v$ synonyms for d$ XA views
create or replace synonym v$xatrans$ for d$xatrans$;
create or replace synonym v$pending_xatrans$ for d$pending_xatrans$;

Rem *************************************************************************
Rem END Bug 15892490
Rem *************************************************************************

Rem ************************************************************************
Rem BEGIN dbms_sql2 changes - for upgrade from 11202
Rem ************************************************************************
DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version >= '11.2.0.2.0' THEN
    execute immediate
      'drop public synonym dbms_sql2';
    execute immediate
      'drop package dbms_sql2';
  END IF;
END;
/

Rem *************************************************************************
Rem Bug 19076927 - OLS AUD$ changes
Rem *************************************************************************
COLUMN :file_name NEW_VALUE olsaudupg_file NOPRINT
VARIABLE file_name VARCHAR2(14)

BEGIN
  IF dbms_registry.is_loaded('OLS') IS NOT NULL THEN
    :file_name := 'olsaudup.sql';
  ELSE
    :file_name := 'nothing.sql';
  END IF;
END;
/

SELECT :file_name FROM DUAL;
@@&olsaudupg_file

Rem *************************************************************************
Rem END Bug 19076927
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================
 
@@c1201000
  
Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END   c1102000.sql
Rem *************************************************************************
