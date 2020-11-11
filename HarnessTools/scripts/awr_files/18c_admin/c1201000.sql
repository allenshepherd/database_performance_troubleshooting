Rem
Rem $Header: rdbms/admin/c1201000.sql /st_rdbms_18.0/2 2017/12/06 15:06:50 pyam Exp $
Rem
Rem c1201000.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1201000.sql - Script to apply current release patch release
Rem
Rem    DESCRIPTION
Rem      Put any dictionary related changes here (i.e. - create, alter,
Rem      update,...).  If you must upgrade using PL/SQL packages,
Rem      put the PL/SQL block in a1201000.sql since catalog.sql and
Rem      catproc.sql will be run before a1201000.sql is invoked.
Rem
Rem      This script is called from catupstr.sql
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/c1201000.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/c1201000.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupstr.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        12/04/17 - RTI 20773151: force drop dbms_feature_ra_owner
Rem    jstenois    11/29/17 - XbranchMerge jstenois_bug-27126506 from main
Rem    jstenois    11/17/17 - 27126506: add SYS to view datapump_dir_objs
Rem    rodfuent    08/31/17 - Bug 26731573: Use owner# in fix for bug 21693228
Rem    risgupta    08/17/17 - Bug 26634509: Dont set default values of new
Rem                           columns in aud$/fga_log$ to NULL
Rem    osuro       07/19/17 - Bug 26473362: Fix WRH$_SYSMETRIC_HISTORY index
Rem    tojhuan     07/11/17 - RTI 20257878: drop SYS.OWNER_MIGRATE_UPDATE_TDO
Rem                           and SYS.OWNER_MIGRATE_UPDATE_HASHCODE which might
Rem                           be backported to prior-12.1.0.2 releases
Rem    jaeblee     06/19/17 - Bug 25947201: move pseudo bootstrap to catupstr
Rem    raeburns    06/13/17 - RTI 20258949; remove whitepace in type creation
Rem    pknaggs     05/23/17 - Bug 26137416: REPLACE before ENQUOTE_LITERAL
Rem    achatzis    05/22/17 - Bug 25527953: Move flag KTT_HDFS.
Rem    osuro       05/03/17 - Bug 25954054: Fix mismatching WRH$_* constraints
Rem    amunnoli    03/24/17 - Bug 25717371:Fix unique constraint violation
Rem    raeburns    03/09/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    raeburns    01/16/17 - Bug 25337332: Correct signature issues with drop
Rem                           column
Rem    akanagra    12/28/16 - Bug 25179268: modify aq$_schedules_primary on
Rem                           upgrade
Rem    shvmalik    11/27/16 - #25035608: revert back FCP txn
Rem    pyam        11/10/16 - 70732: move app upgrade logic into catupstr.sql
Rem    vgerard     11/04/16 - Bug 24841465: move autocdr to i script
Rem    drchoudh    11/02/16 - bug24750289: migrate svcobj*$ to IOTs
Rem    raeburns    10/28/16 - Bug 23231303: DROP DIRECTORY no longer needs to
Rem                           be wrapped
Rem    hosu        10/26/16 - 24598595:mark hist_head$ histgrm$ sensitive
Rem    amunnoli    10/20/16 - bug 24812771: read only property for aud$unified
Rem    sdball      10/11/16 - Bug 24824274: unlimited sysaux for
Rem                           gsmadmin_internal
Rem    sramakri    09/09/16 - Remove CDC from 12.2 - remove revoke privs on CDC pkgs
Rem    skabraha    08/29/16 - bug 24494515: add migrate_80sysimages_to_81
Rem    suelee      08/18/16 - Bug 24449106: WRH$_RSRC default values
Rem    molagapp    08/17/16 - fwdmerge molagapp_bug-23755051 from 12.2.0.1.0
Rem    molagapp    08/16/16 - Bug 23755051
Rem    yingzhen    08/15/16 - Increase swrf version to 12CR201
Rem    yohu        08/09/16 - Bug 24426165: Add sqlcode 100 to the list
Rem    pknaggs     08/09/16 - Bug #24449912: Forward mrg pknaggs_lrg-19690342.
Rem    prakumar    07/21/16 - Bug 23746738: Drop gethivetable, unix_ts_to_date
Rem                           and user_privileged
Rem    yohu        07/20/16 - Bug 24314853: Fix the typo 1430 -> 1403
Rem    prshanth    07/18/16 - Bug 23750190: add minval$, maxval$ and list$ to
Rem                           lockdown_prof$
Rem    sursridh    07/07/16 - Bug 23733162: Mark pdb_create$, pdb_sync$ cols
Rem                           sensitive
Rem    shvmalik   06/30/16 - #23721669: drop FCP tables, types and package
Rem    welin       06/02/16 - invoking subsequent release
Rem    dvekaria    06/29/16 - Bug 23604553: ORA-22308 in upgrade from pre-12.1
Rem    quotran     06/27/16 - Add cdb_root_dbid into wrm$_database_instance
Rem    chinkris   06/23/16 - Bug 23541062: clear comp$ spare3 for selective cols
Rem    frealvar    06/12/16 - RTI 19400841 drop package dbms_preup and
Rem                           preupgrade directory 
Rem    sramakri    06/20/16 - bug-23515980: remove support for CDC
Rem    jcarey      06/07/16 - bug 23536767 - remove unneeded grants
Rem    thoang      06/03/16 - Fix bug 23525819
Rem    frealvar    05/25/16 - Bug23316483 drop PREUPJAVAEXIT and PREUPCREATEDIR
Rem    shjoshi     05/18/16 - bug 23279437: Upgd changes to wrp tables
Rem    gravipat    05/17/16 - Bug 23104651: add postplugscn to container$
Rem    kmorfoni    05/17/16 - Bug 23279437: remove con_id from AWR tables
Rem    ddas        05/16/16 - #(23137623) add SPM evolve task parameters
Rem    sylin       05/09/16 - bug23248734 - drop dbms_sqlplus_script package
Rem    alestrel    05/09/16 - bug 23207701: remove execute grant on
Rem                           dbms_sched_argument_import from
Rem                           select_catalog_role
Rem    qicui       05/05/16 - Bug 23207710: Not grant execute to SELECT ROLE
Rem    molagapp    04/29/16 - bug 23202142
Rem    dblui       04/21/16 - Bug 23061990: defhscflags overlaps defimcflags
Rem    yberezin    03/11/16 - upgrade bug 22713655: sync up the schemas in the
Rem                           patch and in MAIN
Rem    shjoshi     04/13/16 - bug 23059287: Upgd changes to wrp tables
Rem    gravipat    04/08/16 - lrg 19284950: sqlstmt in pdb_create$ needs to be
Rem                           a clob
Rem    dhdhshah    03/30/16 - fix-up new columns of ilmpolicy$ (project 45958)
Rem    lkaplan     03/29/16 - Bug 22133352
Rem    mjaiswal    03/24/16 - drop (g)v$aq_opt_* views/synonyms with old names
Rem    rthammai    03/17/16 - Bug 22682473: revoke all to map_object
Rem    sursridh    03/11/16 - Bug 21028455: Rename catfed->catappcontainer.
Rem    sdball      03/09/16 - New columns in gsmadmin_internal.database
Rem    aumehend    03/09/16 - Bug 22657204: remove inmemory CUs from
Rem                           compression$ to ensure we do not carry forward in
Rem                           memory CU formats from 12.1 to 12.2
Rem    sursridh    03/09/16 - Bug 22895916: Dict. changes for app container.
Rem    prshanth    03/09/16 - Bug 22904308: index change for lockdown profile
Rem    prgaharw    03/04/16 - Proj 45958: Upgrade for new cols in ilmpolicy$
Rem    rajeekku    03/04/16 - Bug 22872956: Inherit Remote Privileges changes
Rem    quotran     03/03/16 - Add cdb,edition,db_unique_name,database_role into
Rem                           wrm$_database_instance
Rem    drchoudh    02/29/16 - bug22367092: add svcobj*$ tables
Rem    aramappa    02/29/16 - 21239547:Revoke INHERIT PRIVILEGE on SYS from
Rem                           DBSNMP
Rem    osuro       02/18/16 - bug 22698283: remove view_location from
Rem                           wrm$_wr_control
Rem    gravipat    02/18/16 - Bug 21858478: Add blks to cdb_file$
Rem    dcolello    02/17/16 - bug 22743674: add svcusercredential
Rem    prshanth    02/17/16 - Bug 22686666: add timestamp to lockdown_prof$
Rem    ardesai     12/17/15 - add con_id to awr tables with default value to 0
Rem    rmorant     02/11/16 - bug22674649 delete objects for upgrade rerun
Rem    yiru        02/10/16 - Bug 21080787,22393016:Remove grants from 
Rem                           objauth$ for old $DEPRECATED$ views
Rem    sankejai    02/05/16 - Bug 22622072: add cdb_props$
Rem    abrown      02/04/16 - yunkzhan_bug-21466698 : default logmnr_did$.flags
Rem                           to 0.
Rem    skayoor     02/03/16 - Bug 22608480: Grant READ privilege
Rem    pyam        02/02/16 - Bug 22373750: fix pdb_sync$ indexes
Rem    jmuller     12/15/15 - Fix bug 21097449: drop primary key on
Rem                           dbms_parallel_execute_chunks$ on upgrade
Rem    pknaggs     01/28/16 - Bug #22153841: pname 128 in Data Redaction.
Rem    mstasiew    01/28/16 - add hcs_av_col$.sub_obj#, sub_obj_type
Rem    schakkap    01/26/16 - #(20413540) create opt_sqlstat$
Rem    welin       01/22/16 - Bug 21393622: remove error handling for truncate
Rem                           grant revoke operation
Rem    beiyu       01/19/16 - Bug 21365797: add owner_in_ddl col to HCS views
Rem    pyam        01/12/16 - RTI 18548742: drop check_test_internal
Rem    beiyu       01/12/16 - Bug 20619944: add level_type column
Rem    nkedlaya    01/07/16 - bug 21962893: add new table ofsftab
Rem    pyam        01/07/16 - RTI 18894935: make I_PDBSYNC1 non-unique
Rem    rapayne     12/18/15 - bug 21609747: metastylesheet table must be
Rem                           object linked (reinstate previous fix).
Rem    josmamar    12/16/15 - Bug 22345422: Revoke SELECT privileges from 
Rem                           WRR$_REPLAY_CALL_FILTER
Rem    jlingow     12/03/15 - remove "with grant option" from scheduler views
Rem    sfeinste    12/02/15 - Remove NOT NULL constraint on precision#,
Rem                           scale, charsetform in hcs tables and add
Rem                           charsetid and property
Rem    rpang       12/01/15 - Bug 22294806: remove DEBUG CONNECT USER sys priv
Rem                           and add DEBUG CONNECT to USER_PRIVILEGE_MAP
Rem    rpang       11/30/15 - Bug 22275536: add DEBUG CONNECT stmt audit option
Rem    qinwu       11/30/15 - Bug 22183065: add connect_time_auto_correct
Rem    thbaby      11/30/15 - Bug 21898184: add remote_user to proxy_remote$
Rem    vgerard     11/30/15 - add apply$_procedure_stats
Rem    smesropi    11/26/15 - Bug 21910928: Modify all_member_name to be clob
Rem    sankejai    11/25/15 - Bug 21947953: create pdb_stat$ and pdb_svc_stat$
Rem    jaeblee     11/25/15 - Bug 22076114: app$cdb$catalog only for CDB$ROOT
Rem    sfeinste    11/25/15 - Bug 21542146: hcs_hr_lvl_id$ and in_minimal col
Rem    pyam        11/22/15 - move pdb_sync$ earlier
Rem    dcolello    11/21/15 - redo VNCR table for patching
Rem    sfeinste    11/25/15 - Bug 21542146: hcs_hr_lvl_id$ and in_minimal col
Rem    aarvanit    11/20/15 - RTI #13227832: modify WRI$_SQLSET_PLAN_LINES
Rem                           column datatypes to match with staging table
Rem    jorgrive    11/18/15 - Bug 22234530: add pdb_id streams$_apply_spill_txn
Rem    sursridh    11/12/15 - Add sqlid to pdb_sync$, add table pdb_sync_stmt$.
Rem    smesropi    11/11/15 - Bug 21171628: Rename HCS tables
Rem    huntran     11/09/15 - auto cdr conflict info
Rem    mstasiew    11/09/15 - Bug 21984764: hcs object rename
Rem    dkoppar     11/06/15 - #21143559 long identifiers
Rem    dcolello    11/03/15 - bug 22145787: make response_info larger
Rem    josmamar    11/03/15 - bug 21874643: support query-only replay for non
Rem                           consolidated replay
Rem    alestrel    11/02/15 - bug 22119906, removing alter scheduler types
Rem    svivian     11/02/15 - bug 21882092: drop package dbms_logmnr_session
Rem    raeburns    10/30/15 - Bug 21834837: Remove unnecessary ALTER TYPEs
Rem    aditigu     10/22/15 - Bug 21238674: Add new column to imsvc$ 
Rem    jjanosik    10/21/15 - bug 13611733: Fix privs for upgrade
Rem    yapli       10/20/15 - Bug 21963345: Drop obsolete public synonym
Rem                           DBMS_DBLINK
Rem    dcolello    10/19/15 - object rename for production
Rem    thbaby      10/14/15 - Bug 21971498: add proxy_remote$
Rem    timedina    10/13/15 - RTI 18569453: Transient object type after upgrade
Rem    youyang     10/11/15 - bug21963542:remove unusable synonyms
Rem    smangala    10/09/15 - bug 21192807: CDB non-unique xid
Rem    jlasagu     10/08/15 - ofsmtab$ change
Rem    yingzhen    10/06/15 - Bug 21575534: change dba_hist view location
Rem    amozes      10/06/15 - revoke grants to remove with grant option
Rem    quotran     10/01/15 - bug 21903834: add schedule_cap_id column at
Rem                           WRR$_REPLAY_SCN_ORDER
Rem    hmohanku    09/28/15 - bug 21787568: add directory stmt audit options
Rem    alestrel    09/25/15 - bug 21647288 : long id in RULE_NAME sys.scheduler
Rem                           _srcq_map
Rem    prshanth    09/22/15 - Bug 21861152: Change upg priority of ROOT & SEED
Rem    aarvanit    09/21/15 - proj #47346: add _USE_STATS_ADVISOR
Rem                           NUM_ROWS_TO_FETCH, EXECUTE_TRIGGERS, 
Rem                           REPLACE_SYSDATE_WITH task parameters
Rem    jstenois    09/10/15 - 21816303: no longer need to modify types in
Rem                           dbmspump.sql since they are recreated later
Rem                           move ALTER TABLE for opatch_xml_inv to a1201000
Rem    rapayne     09/10/15 - RTI 18489707: backout previous load stylesheet
Rem                           change as it does not work when the PDB charsets
Rem    yberezin    09/03/15 - bug 21787780: length mismatch
Rem    rodfuent    09/03/15 - Bug 21693228: Update implobj# of indtypes$ to the
Rem                           most recent version before dropping ODCI types
Rem    amunnoli    09/02/15 - Bug 13716158: add current_user to aud$, fga_log$
Rem    juilin      09/02/15 - 21662644 handle exception 65213
Rem    juilin      09/01/15 - 21485248 rename syscontext FEDERATION_NAME
Rem    pyam        08/31/15 - 21757266: drop public syn for CDB_SECUREFILE_*
Rem    bmilenov    08/31/15 - bug-21757392: drop DMGLM_LIB
Rem    bsprunt     08/26/15 - Bug 21652015: add instance_caging column
Rem    surman      08/21/15 - 20772435: SQL registry changes to XDB safe
Rem                           scripts
Rem    skabraha    08/19/15 - update type metadata TDSs for long identifier
Rem    rapayne     08/18/15 - bug 21609747: metastylesheet table must be
Rem                           object linked.
Rem    mdombros    08/16/15 - #21378698 Cube Cache remove not null lvlgrp_lvls
Rem    yberezin    07/24/15 - bug 21497629: long ids
Rem    dgagne      08/11/15 - backout approot txn
Rem    atomar      08/10/15 - move aq alter type to cataqalt121.sql, after
Rem                           depsaq.sql bug:20803176
Rem    atomar      08/10/15 - revoke public grant on _unflushed_dequeues bug
Rem                           21185104
Rem    quotran     08/06/15 - bug 21610276: support always-on capture
Rem    jiayan      08/03/15 - #20663978: add rec_type_id column to 
Rem                           wri$_adv_recommendations
Rem    cgervasi    08/03/15 - lrg17960694: add cols AWR WRH$_CELL_DB_BL
Rem    pyam        07/31/15 - add 65251 to pdb app begin error handler
Rem    dcolello    07/28/15 - more columns for CLOUD table
Rem    msusaira    07/24/15 - ofsmtab$ changes
Rem    tchorma     07/24/15 - Bug 21281961: drop lsby (un)supported table funcs
Rem    jstenois    07/22/15 - 21185010: drop view SYS.KU$_VIEW_STATUS_VIEW
Rem                           (removed in 11.2.0.4)
Rem    yidin       07/21/15 - Bug 21185089: Revoke SELECT privilege on nologged
Rem                           views
Rem    aditigu     07/20/15 - bug 21437329: adding index i_imsvc1, i_imsvcts1
Rem    yanxie      07/17/15 - set flag4 in snap$
Rem    dvoss       07/16/15 - bug 21456550: naming change
Rem    liding      07/16/15 - bug 21049500: new col in mv_refresh_usage_stats$
Rem    anighosh    07/14/15 - #(21385501): Record the time to compile
Rem    gravipat    07/13/15 - Add table pdb_create$
Rem    cgervasi    07/08/15 - awr: add columns to cell_db
Rem    jlingow     07/02/15 - bug21348198 change comment lenght of scheduler
Rem                           tables
Rem    ghicks      06/19/15 - bugs 20481832, 20481863: HIER and HIER CUBE
Rem                           in SYSTEM_PRIVILEGE_MAP and STMT_AUDIT_OPTION_MAP
Rem    prshanth    06/17/15 - Bug 21091902: add value$ to lockdown_prof$
Rem    ddas        06/17/15 - proj 47170: persistent IMC statistics
Rem    papatne     06/15/15 - Bug 20868862: Delete invalid rule_set Object
Rem    atomar      06/14/15 - 20512406 alter sys.aq$_dequeue_history longidn
Rem    mdombros    06/06/15 - Bug 21163869: create hier cube level grouping tables
Rem    sdball      06/05/15 - Bug 21143597: GDS support for long idenitifiers
Rem    rmorant     06/05/15 - Bug21203169 remove incorrect update by
Rem                           bug20301816
Rem    atomar      06/02/15 - alter system.aq$_schedules
Rem    raeburns    06/02/15 - Remove unnecessary ALTER TYPE statements
Rem                         - Use FORCE for types with only type dependents
Rem                         - Remove OR REPLACE for types with table dependents
Rem    jiayan      06/01/15 - #21117297: fix stats_advisor_filter_rule$
Rem    beiyu       05/29/15 - Bug 20969687: correct HCS index names 
Rem    jftorres    05/27/15 - proj 45826: use CLOB for
Rem                           smb$config.parameter_data
Rem    raeburns    05/26/15 - Drop ODCI types to remove unnecessary versions
Rem    atomar      05/22/15 - bug 20965078 drop _HIST index his iot
Rem    pyam        05/20/15 - cdb upgrade optimizations
Rem    smesropi    05/18/15 - Bug 20555264: Add aggr col to hcs cube and meas
Rem    hmohanku    05/15/15 - bug 20961072: Clear the common bit of all the out
Rem                           of the box unified audit policies
Rem    rmorant     05/12/15 - bug 20553651: long ids
Rem    rmorant     05/12/15 - bug 20301816: long ids
Rem    beiyu       05/12/15 - Bug 20549214: remove SELECT ANY HIER DIM priv
Rem    araghava    05/05/15 - proj 47117: online split, drop unique index on
Rem                           rmtab$
Rem    sfeinste    05/04/15 - Bug 20844599: HCS parent-child metadata
Rem    mstasiew    05/04/15 - Bug 20898181: hcs_hrcube_col$/cb_meas$ dt cols
Rem    thbaby      04/30/15 - 20985003: migrate Common Data views 
Rem    alestrel    04/27/15 - BUG 20762369: upgrade
Rem                           SYSTEM.SCHEDULER_PROGRAM_ARGS_TBL
Rem    thbaby      04/27/15 - 20984107: remove OBL on Datapump tables
Rem    sgarduno    04/23/15 - Bug 20855956, 20511159  
Rem                           + Streams Long Identifier support.
Rem    sanagara    04/22/15 - Bug 19624713: drop old dba_* views
Rem    msakayed    04/22/15 - replace DATAPUMP_DIR_OBJS with LOADER_DIR_OBJS
Rem    gravipat    04/20/15 - Add new columns to cdb_file$
Rem    suelee      04/16/15 - Bug 20898764: PGA limit
Rem    bsprunt     04/16/15 - Bug 15931539: add missing fields to
Rem                           DBA_HIST_RSRC_CONSUMER_GROUP
Rem    schakkap    04/16/15 - proj 47047: add new tables for expression
Rem                           tracking
Rem    sumkumar    04/15/15 - Initialize Inactive_Account_Time parameter for
Rem                           "DEFAULT" profile with UNLIMITED in stead of 0
Rem    ssonawan    04/15/15 - Bug 20715920: add ext_username column to
Rem                           cdb_local_adminauth$
Rem    yberezin    04/13/15 - bug 20867498: long ids
Rem    sdoraisw    04/15/15 - Proj 47082: partitioned external table support
Rem    thbaby      04/12/15 - 20869766: re-create cdb_analyze_objects
Rem    aditigu     04/10/15 - proj 58950,42356-3: added new IMC tables
Rem    yunkzhan    04/09/15 - Bug 17761631: truncate all logminer gather tables
Rem    amozes      04/09/15 - #(20817805): fix drop type ordering
Rem    yehan       04/08/15 - bug 20495105: relocate to i1201000.sql the code
Rem                           that removes OWB and EQ from SERVER registry
Rem    ratakuma    04/08/15 - Bug 20756607: account for remoteowner field
Rem                           in pwd_verifier column to get a single row.
Rem    schakkap    04/07/15 - proj 46828: add nrows to opt_finding_obj$
Rem    quotran     04/03/15 - bug 20827740: support RAC per-instance sync
Rem    smesropi    04/03/15 - Bug 20508729: Add datatype to hcs attr$ tables
Rem    sdball      04/02/15 - ddl_num should default to 0 in database table for
Rem                           upgrade
Rem    huntran     04/02/15 - proj 58812: auto cdr tables
Rem                         - dvoss: add COLLID and COLLINTCOL# for logminer
Rem    tbhukya     04/01/15 - Bug 20722522: Drop and recreate index i_dependobj
Rem    sdball      03/31/15 - New rack field for GDS database table
Rem    raeburns    03/27/15 - Remove EQ from SERVER registry (see bug 14227409)
Rem    cmlim       03/25/15 - bug 20756240: support long identifiers in
Rem                           validation procedure names
Rem    dvoss       03/24/15 - bug 20759099: logminer handle wide tab$.property
Rem    hegliu      03/23/15 - bug 20606723: upgrade for partitioned read only
Rem                           table
Rem    jorgrive    03/23/15 - actions for OGG sharding
Rem    sgarduno    03/20/15 - Bug 20560241: Long identifier support for
Rem                           xstream$_map
Rem    sgarduno    03/20/15 - Bug 20511901: Long identifier support for
Rem                           SYS.REPL$_DBNAME_MAPPING.
Rem    arbalakr    03/02/15 - Bug 18822045: Add microseconds perrow and
Rem                           sample_time_utc to ash
Rem    givey       03/20/15 - Lrg 15403336: Account for big tablespace when
Rem                           inserting the endian type property
Rem    hmohanku    03/19/15 - bug 20280545: modify
Rem                           sys.dam_cleanup_jobs$.job_name
Rem    arbalakr    03/02/15 - Bug 18822045: Add microseconds perrow and
Rem                           sample_time_utc to ash
Rem    dvoss       03/17/15 - bug 19652746 - cleanup LSBY skip container rules
Rem    pyam        03/16/15 - 18764101 fwd merge: add pdb_inv_types$
Rem    rmacnico    03/15/15 - Prof 47506: CELLCACHE
Rem    sdball      03/13/15 - More changes for 12.2 sharding
Rem    sdoraisw    03/12/15 - proj47082:allow null in external_tab$.default_dir
Rem    arbalakr    03/02/15 - Bug 18822045: Add microseconds perrow and
Rem                           sample_time_utc to ash
Rem    jaeblee     03/09/15 - lrg 14235955: ignore ORA-65173 on revoke from
Rem                           cdb_keepsizes
Rem    mstasiew    03/06/15 - 20512658 olap_metadata_dependencies/properties
Rem    svaziran    03/06/15 - bug 20652654: increase name col for feature usage
Rem    krajaman    03/05/15 - bug#20682673 fix, PQ sends out session parameters
Rem    jiayan      03/04/15 - Proj 57436: schema change for synopsis tables
Rem    sdball      03/04/15 - New columns for sharding
Rem    smesropi    03/03/15 - Bug 20556365: Modify hcs_cb_dim$ for invalid cube
Rem    thbaby      02/27/15 - Proj 47234: add column TGT_CON_UID to VIEW_PDB$
Rem    ssonawan    02/27/15 - bug 20383779: audit BECOME USER by default
Rem    hlakshma    02/25/15 - proj 45958: heat_map_stat$ table changes
Rem    givey       02/26/15 - Bug 20189000: Insert DICTIONARY_ENDIAN_TYPE into
Rem                           PROPS$
Rem    gravipat    02/26/15 - Proj 47234: Add undots, refreshint columns to
Rem                           container$
Rem    sumkumar    02/25/15 - Bug 19895367: Store profile name instead of
Rem                           profile number in cdb_local_adminauth$ table
Rem    jftorres    02/17/15 - proj 45826: add smb$config.parameter_data 
Rem                           VARCHAR2, new rows for autocapture filtering
Rem    mstasiew    02/17/15 - Bug 20448392 add datatype cols to hcs_hier_col$
Rem    gravipat    02/12/15 - Bug 20533616: Unify wrp,bas scn columns in
Rem                           container$
Rem    dagagne     02/10/15 - remove ZDLRA on-disk stats
Rem    claguna     02/09/15 - Bug 20310090
Rem    svivian     02/09/15 - bug 20488905: revert change to session_name
Rem    yberezin    02/02/15 - bug 20381239: long IDs
Rem    dvoss       02/02/15 - proj 49286: per-pdb charset support in logminer
Rem    prshanth    01/30/15 - Proj 47234: add option$ to lockdown_prof$
Rem    baparmar    01/29/15 - Bug 19257966 use utl_raw for session_key update
Rem    gravipat    01/28/15 - Proj 47234: add columns to cdb_file#, 
Rem                           add table cdb_ts$
Rem    thbaby      01/27/15 - Proj 47234: add column remote_user to container$
Rem    dvoss       01/26/15 - proj 49288: logminer tracking more container$
Rem                           cols
Rem    prakumar    01/23/15 - 20309744: Support for long identifiers in REWRITE
Rem    rpang       01/20/15 - 17854208: add diagnostic columns to sqltxl_sql$
Rem    sroesch     01/19/14 - Bug 20319989: Make draining timeout a svc attribute
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    nkgopal     01/13/15 - Bug 17900999: Increase size of auth$privileges in
Rem                           AUD$
Rem    nrcorcor    01/13/15 - Bug 13539672/Proj 41272 New lost write protection
Rem    svivian     01/09/15 - bug 20309181: long identifier support for
Rem                           logstdby$srec
Rem    beiyu       01/09/15 - Proj 47091: add dict tables for new HCS objects
Rem    raeburns    01/07/15 - remove OWB from SERVER registry (see bug 13338356)
Rem                         - add more sample schemas to NOT oracle_maintained
Rem    yujwang     01/07/15 - bug(20319569): for RAC AWR report
Rem    atomar      01/02/15 - bug 19559576
Rem    sumkumar    12/31/14 - Proj 46885: Inactive Account Time
Rem    yehan       12/31/14 - Mark sample schemas as NOT Oracle-maintained
Rem    gravipat    12/30/14 - Proj 47234: Add endrcvscnbas, endrcvscnbas,
Rem                           srcpdbuid
Rem    ddas        12/30/14 - #(20267662) increase max plan line size
Rem    qinwu       12/22/14 - proj 47326: add columns for PL/SQL subcalls
Rem    amozes      12/22/14 - #(20257194): long identifier data mining
Rem    thbaby      12/19/14 - Proj 47234: add remote_port to container$
Rem    thbaby      12/19/14 - Proj 47234: remove public database link CDB$ROOT
Rem    thbaby      12/19/14 - Proj 47234: add view_pdb$
Rem    smangala    12/16/14 - proj-58811: add support for sharding
Rem    rpang       12/11/14 - Add debug connect user and any sys privileges
Rem    pxwong      12/09/14   bug 18671612 modify obsoleted fields def
Rem    youyang     12/08/14 - lrg14341300: move PA update table to a1201000.sql
Rem    ardesai     12/07/14 - modify WRH$_SGASTAT_U constraint
Rem    hcdoshi     12/03/14 - add ntfn_subscriber column in sys.reg table
Rem    prrathi     11/25/14 - support child subscribers
Rem    mzait       11/13/14 - #(20059248) increase size of target column in
Rem                           optstat_opr_tasks and optstat_opr
Rem    thbaby      11/25/14 - Proj 47234: add containers_port, containers_host
Rem    thbaby      11/24/14 - Proj 47234: delete comments for common objects
Rem    jorgrive    11/24/14 - Desupport Advanced Replication
Rem    prakumar    11/20/14 - Proj# 39358: Add redef_object_backup$
Rem    youyang     09/03/14 - project 46820: upgrade PA
Rem    pknaggs     11/20/14 - Lrg 14165401: version and compat NOT NULL 
Rem    atomar      11/17/14 - exception queue
Rem    pyam        11/17/14 - 20020274: add finer-grained deps for MDLs
Rem    pyam        11/17/14 - LRG 13206810: remove deletion of settings$ rows
Rem    kyagoub     11/17/14 - fix with review comments
Rem    ddas        11/06/14 - lrg 12890725: upgrade sqlobj$plan,
Rem                           sql_plan_row_type
Rem    sankejai    11/04/14 - Bug 19946880: name in pdb_alert$ should be 128
Rem    hlili       11/04/14 - bug 18843669: upgrade for partitioned tables with
Rem                           bad metadata caused by adding nested table columns
Rem    surman      11/03/14 - 19928926: Update statements inside exception
Rem                            handler
Rem    desingh     10/28/14 - sharded queue delay
Rem    mbastawa    10/24/14 - bug17765342 add row archival
Rem    yohu        10/21/14 - Lrg13827527: handle ORA-942 errors 
Rem    sdball      10/17/14 - GDS Sharding project, upgrade to 12.2
Rem    pyam        10/16/14 - 12726312: pdb_sync$ ins, drop ku$_12_1_index_view
Rem    yohu        10/14/14 - Bug 19762574: Do not grant MODIFY_SESSION system
Rem                           privilege to XSPUBLIC
Rem    jiayan      10/13/14 - Proj 44162: stats advisor
Rem    prshanth    10/12/14 - Proj 47234: add lockdown_prof$
Rem    sslim       10/09/14 - Bug 18842051: DBMS_ROLLING supports 128 DG
Rem                           members
Rem    surman      10/08/14 - 19315691: bundle_data to CLOB
Rem    akruglik    10/02/14 - Project 47234: add support for federation users
Rem                           and federationally granted privs
Rem    pxwong      09/30/14 - proj 36585 scheduler child project for longid
Rem    yohu        09/24/14 - Lrg 13467436: handle ORA-942 in exception
Rem    myuin       09/20/14 - increased AWRBL_METRIC_TYPE.baseline_name to 128
Rem    sslim       09/13/14 - project 56343: RA support for downstream OGG
Rem    akruglik    09/09/14 - Bug 19525987: add container$.upgrade_priority
Rem    gravipat    09/08/14 - Bug 19328303: add rafn# column from container$
Rem    yohu        09/05/14 - Proj 46902: Sesion Privilege Scoping
Rem    krajaman    07/26/14 - Set psedo boostrap parameter
Rem    amunnoli    09/02/14 - Bug 19499532: Add comments to OOB audit policies
Rem    pyam        08/26/14 - 19455994: share settings$ rows for common objs
Rem    schakkap    08/22/14 - proj 46828: Add scan rate
Rem    minwei      08/22/14 - 12.2 upgrade for proj#39358 restartability
Rem    prshanth    08/20/14 - Proj 47234: Lockdown profile - adding DDLs
Rem    spapadom    08/11/14 - Updated swrf_version to 12cR2.
Rem    bhavenka    07/21/14 - 9853147: add last_exec_start_time in STS
Rem    yunkzhan    07/23/14 - Add column DB_GLOBAL_NAME in LOGMNRC_GSBA table
Rem    sroesch     07/16/14 - Add failover_restore and stop_option to service$
Rem    thbaby      07/17/14 - Project 47234: add srcpdb, linkname to container$
Rem    jaeblee     07/22/14 - proj 47234: add undo switchover scn to container$
Rem    akruglik    07/11/14 - Proj 47234: rename CONTAINER$.SPARE2 to
Rem                           fed_root_con_id#
Rem    risgupta    07/04/14 - Bug 19076927: Donot need query to get AUD$ schema
Rem    jorgrive    06/30/14 - Add repl$_process_events table
Rem    pknaggs     06/26/14 - Proj #46864: add radm_pe$ for multiple policies.
Rem    romorale    04/08/14 - BigSCN lcrid_version to streams$_apply_process 
Rem    sgarduno    06/26/14 - Streams long identifier support.
Rem    osuro       06/26/14 - 19067295: Increase WRH$_SGASTAT.POOL size to 30
Rem    surman      06/14/14 - 18977120: Add bundle_series to registry$history
Rem    nkgopal     06/13/14 - Proj# 35931: Add rls$info to aud$ and fga_log$
Rem    svivian     06/06/14 - logminer long ident support
Rem    sankejai    06/06/14 - 18912837: use replay# in i_pdbsync1 index
Rem    wesmith     05/29/14 - Project 47511: data-bound collation: move fix
Rem                           for bug 17526621 to catuppst.sql
Rem    ssonawan    05/28/14 - Proj 46885: admin user password management
Rem    pyam        05/27/14 - 18858022: fix reco_script_params$ value column
Rem                           to clob
Rem    lbarton     05/21/14 - Project 48787: views to document mdapi transforms
Rem    surman      05/20/14 - 17277459: Fix constraints
Rem    atomar      05/20/14 - unbound_idx, subshard default  -1,bug 18799102
Rem    cxie        05/15/14 - add CAUSE colunm to pdb_alert$
Rem    amozes      05/09/14 - project 47098: data mining framework
Rem    suelee      05/12/14 - Backport jomcdon_bug-18622736 from main
Rem    sanbhara    05/05/14 - Project 46816 - adding support for SYSRAC.
Rem    apfwkr      04/28/14 - Backport ssathyan_bug-18288676 from main
Rem    jomcdon     04/27/14 - implement profiles functionality
Rem    apfwkr      04/24/14 - Backport akruglik_bug-17446096 from main
Rem    surman      04/21/14 - 17277459: Add bundle columns to SQL registry
Rem    ghicks      04/21/14 - OLAP obj name length changes
Rem    surman      04/17/14 - Backport surman_bug-17665117 from main
Rem    apfwkr      04/10/14 - Backport akruglik_bug-18417322 from main
Rem    youyang     04/02/14 - Backport youyang_bug-18442084 from main
Rem    dkoppar     02/10/14 - #17665104 add Patch UID col
Rem    akruglik    04/09/14 - Bug 17446096: populate adminauth$ in a non-CDB
Rem                           using data in v$pwfile_users
Rem    baparmar    04/04/14 - bug18469064: update session_key type to raw
Rem    akruglik    04/01/14 - Bug 18417322: adding columns to
Rem                           CDB_LOCAL_ADMINAUTH$
Rem    youyang     03/26/14 - bug18442084:fix type grant_path
Rem    ssathyan    03/23/14 - 18403520: Update readsize
Rem    jlingow     03/19/14 - add notification_owner column to
Rem                           schedulr$_notification table
Rem    surman      03/19/14 - 17665117: Patch UID
Rem    ssathyan    03/13/14 - disable_directory_link_check
Rem    ssathyan    03/03/14 - 17675121:opatch_xml_inv change charset to utf8
Rem    jinjche     02/28/14 - Rename a couple of columns
Rem    vradhakr    02/28/14 - Bug 17971239: Increase size of columns for long
Rem                           identifiers.
Rem    ncolloor    02/21/14 - Bug18157062:add column to cpool$ table.
Rem    skayoor     02/21/14 - Bug 18180897: Grant privilege to SYSTEM
Rem    risgupta    02/17/14 - Bug 18174384: Remove Logon/Logoff actions from
Rem                           ORA_SECURECONFIG audit policy
Rem    pyam        02/16/14 - change i_pdbsync2 to non-unique index
Rem    dkoppar     02/10/14 - #17665104 add Patch UID col
Rem    skayoor     01/31/14 - Bug 18019880: Remove admin option from DBA.
Rem    p4kumar     01/21/14 - Bug 17537632
Rem    traney      01/16/14 - 17971391: increase size of opbinding$.functionname
Rem    hlakshma    01/10/14 - Bug-18046497. Handle ORA-02206 
Rem    rkagarwa    01/06/14 - 17954127: patch synobj# of MDSYS objects
Rem    gravipat    12/30/13 - Add pdb_sync$ on upgrade
Rem    abrumm      12/24/13 - exadoop-upgrade: add raw attribute to
Rem                           ODCIExtTable[Open,Fetch,Populate,Close]
Rem    pyam        12/19/13 - 17976551: fix ALTER TABLE UPGRADE query
Rem    achaudhr    12/16/13 - 17793123: Add oracle_loader deterministic keyword
Rem    pyam        12/14/13 - readd 17860560 with proper code to support it
Rem    pyam        12/12/13 - 17937809: backout 17860560
Rem    hlakshma    12/10/13 - Add ADO related constraints
Rem    pyam        12/05/13 - 17670879, 17860560: patch 12.1.0.1 dict problems
Rem    talliu      12/05/13 - revoke grant select_catalog_role on cdb views
Rem    yberezin    12/04/13 - bug 17391276: introduce OS time for
Rem                           capture/replay start
REM    tianli      12/04/13 - 17742001: fix process_drop_user_cascade
Rem    arbalakr    11/21/13 - Bug17425096: Add Full plan hash value to ASH
Rem    jinjche     11/22/13 - Add big SCN support
Rem    praghuna    11/20/13 - Added pto recovery fields to apply milestone
Rem    jmuller     09/17/13 - Fix bug 17250794: upgrade actions re: edition
Rem                           security
REM    surman      10/24/13 - 14563594: Add version to registry$sqlpatch
REM    rpang       10/23/13 - 17637420: add tracking columns to sqltxl tables
Rem    qinwu       10/21/13 - bug 17456719: add divergence_load_status
Rem    cxie        10/16/13 - make index i_pdb_alert2 not unique
Rem    jinjche     10/16/13 - Rename nab to old_blocks
REM    cxie        10/16/13 - make index i_pdb_alert2 not unique
Rem    tianli      10/03/13 - add apply$_cdr_info
Rem    sguirgui    10/02/13 - bug 17191640 - drop wrm$_wr_control_name_uk
Rem    cxie        10/01/13 - add index i_pdb_alert2 on pdb_alert$
Rem    huntran     09/30/13 - add lob apply stats
Rem    sasounda    09/26/13 - proj 47829: add READ ANY TABLE sys priv
Rem    shiyadav    09/26/13 - bug 17348607: modify wrh$_dyn_remaster_stats
Rem    vpriyans    09/21/13 - Bug 17299076: Added ORA_CIS_RECOMMENDATIONS
Rem    minx        09/18/13 - Fix Bug 17478619: drop data realm description 
Rem    amunnoli    09/15/13 - Bug #17459511: mark pwd_verifier column of 
Rem                           default_pwd$ as sensitive 
Rem    dvoss       09/11/13 - bug 17328599: standardize logminer create types
Rem    desingh     08/28/13 - add columns in AQ sys.*_PARTITION_MAP tables
Rem    jerrede     08/28/13 - Fix bug 17267114 Convert Data
Rem    jinjche     08/27/13 - Add a column and rename some columns
Rem    sdball      08/26/13 - Bug 17199155: add db_type to database
Rem    shiyadav    08/22/13 - bug 13375362: increase column width for baseline
Rem    cechen      08/22/13 - add domains for PKI keys in database and cloud
Rem    pxwong      08/12/13 - bug16017445 revoke public grant for dbms_job
Rem    jheng       08/08/13 - Bug 16931220: drop and re-create type grant_path
Rem    gclaborn    07/30/13 - 17247965: Add version support for import callouts
Rem    schakkap    07/08/13 - #(16576884) revisit indexes for directive tables
Rem    nkgopal     07/16/13 - Bug 14168362: Add dbid, pdb guid to
Rem                           sys.dam_last_arch_ts$
Rem    shiyadav    07/10/13 - Bug 17042658: update the flush_type flag
Rem    mjungerm    07/08/13 - revert addition of CREATE JAVA priv
Rem    pradeshm    07/03/13 - Proj#46908: new columns in RAS principal table
Rem    svivian     06/28/13 - bug 16848187: add con_id to logstdby$events
Rem    sramakri    06/27/13 - update mlog$ for BigSCN
Rem    cxie        06/13/13 - bug 16863416: add vsn column to container$
Rem    xha         06/03/13 - Bug 16739969: invalid imcflag_stg
Rem    mjungerm    05/23/13 - ignore constraint violations for java privs in
Rem                           case of reupgrade
Rem    cgervasi    05/10/13 - bump up AWR version
Rem    jinjche     05/20/13 - Make the redo_rta_idx a unique index
Rem    svivian     05/17/13 - bug 16684631: add LOGMINING to
Rem                           system_privilege_map
Rem    jovillag    05/08/13 - lrg 9137071 - dont revoke execute from 
Rem                           public from dbms_streams_pub_rpc
Rem    mjungerm    05/06/13 - add create java and related privs
Rem    sdball      05/06/13 - Bug 16770655 - Add weights to region
Rem    sdball      05/15/13 - Bug 16816121: Add data_vers to cloud
Rem    jinjche     05/02/13 - Set default to 0 in newly added columns
Rem    jinjche     04/30/13 - Rename and add columns for cross-endian support
Rem    abrown      04/26/13 - abrown_bug-16594543: Enable logmnrUid to cycle
Rem    jovillag    04/23/13 - bug 16047985 - revoke execute from public from
Rem                           some replication packages
Rem    jekamp      04/10/13 - Project 35591: IMC flag in deferred_stg$
Rem    amunnoli    04/02/13 - Bug #16496620: Enable audit on directory, 
Rem                           pluggable database by default
Rem    minwei      03/18/13 - Bug 13105099: alter index i_aclmv
Rem    sdball      03/12/13 - Bug 16789945: add old_instances to gsm_requests
Rem    sdball      03/06/13 - Move GDS upgrade code here from a1201000.sql
Rem    jkati       02/11/13 - bug#16080525: Enable audit on DBMS_RLS by default
Rem    pxwong      03/03/13 - re-enable project 25225
Rem    amunnoli    02/08/13 - Bug 16066652: add  job_flags column in
Rem                           sys.dam_cleanup_jobs$
Rem    praghuna    13/01/11 - Add lwm_upd_time to logstdby$apply_milestone
Rem    sylin       12/27/12 - drop package procedure with zero argument in
Rem                           argument$ view
Rem    cdilling    10/19/12 - patch upgrade script for 12.1.0.1 to 12.1.0.2
Rem    cdilling    10/19/12 - Created
Rem

Rem *************************************************************************
Rem BEGIN c1201000.sql
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN migrate_80sysimages_to_81
Rem =======================================================================
REM We might have an issue where 3 predefined types, UROWID, BINARY DOUBLE
REM and BINARY FLOAT are inserted into type dictionary tables in 8.0 format
REM when upgrading to 10g. This was fixed in 10.2.0.3/4, but the bug was
REM reintroduced in 10.2.0.5. 8.0 images are buggy and has some inherent 
REM problem with pointers in 64 bit m/cs. So if such and image exists, we 
REM need to drop and reinsert in 8.1 image format. The following procedure
REM does that
REM.
REM We have the same procedure defined in dbmsobj.sql also. But it appears
REM that gets defined after here, during upgrade. So I am defining it here
REM and droping after execution.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PROCEDURE migrate_80sysimages_to_81 IS
LANGUAGE C
NAME "MIGRATE_80_TO_81"
LIBRARY UPGRADE_LIB;
/

begin
   migrate_80sysimages_to_81;
exception when others then
-- as of now raise all errors. This failing is a problem.
  raise;
end;
/

drop procedure migrate_80sysimages_to_81;

Rem =======================================================================
Rem  BEGIN DML changes for pdb_sync$ (DDLs are in catappupgpre.sql)
Rem =======================================================================

Rem initial row to initialize replay counter, if no rows exist. Use opcode -1
DECLARE
  num_rows  number := -1;
BEGIN
  select count(*) into num_rows from pdb_sync$ where opcode=-1;

  if num_rows = 0 then
    insert into pdb_sync$(scnwrp, scnbas, ctime, name, opcode, flags, replay#)
    values(0, 0, sysdate, 'PDB$LASTREPLAY', -1, 0, 0);
  end if;
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

commit;

Rem =======================================================================
Rem  END Changes for pdb_sync$
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN Bug 21963345: Drop obsolete public synonym DBMS_DBLINK 
Rem *************************************************************************

drop public synonym dbms_dblink;

Rem *************************************************************************
Rem END Bug 21963345: Drop obsolete public synonym DBMS_DBLINK
Rem *************************************************************************

Rem ****************************************************************
Rem BEGIN bug 21385501: Add a new column to record compilation time
Rem ****************************************************************

alter table sys.utl_recomp_compiled add (completed_at timestamp);

Rem ****************************************************************
Rem END bug 21385501: Add a new column to record compilation time
Rem ****************************************************************

Rem *************************************************************************
Rem BEGIN bug 20756240: support long identifiers in validation procedure names
Rem *************************************************************************

alter table SYS.REGISTRY$ modify (vproc varchar2(128));

Rem *************************************************************************
Rem END bug 20756240: support long identifiers in validation procedure names
Rem *************************************************************************

Rem *************************************************************************
Rem Mark sample schemas as NOT Oracle-maintained (a.k.a. Oracle-supplied)
Rem (incorrectly marked as Oracle-maintained in 12.1.0.1)
Rem *************************************************************************

update user$
   set spare1=spare1-256
 where bitand(spare1,256)=256
   and type#=1
   and name in ('HR', 'OE', 'SH', 'IX', 'PM',
                'ADAMS','BLAKE','CLARK','JONES','SCOTT',
                'TSMSYS');
commit;

Rem ====================================================================
Rem Begin Add finer-grained dependencies for MDLs in a PDB
Rem ====================================================================

begin
  execute immediate 'select dbms_pdb.cleanup_task(9) from dual';
exception when others then
  if sqlcode in (-904) then null;
  else raise;
  end if;
end;
/

Rem ====================================================================
Rem End Add finer-grained dependencies for MDLS in a PDB
Rem ====================================================================

Rem ====================================================================
Rem Begin Changes for Security
Rem ====================================================================
Rem
Rem [17250794] With the new requirement that a user must have USE privilege WITH
Rem GRANT OPTION on an edition in order to make it the default edition, we grant
Rem this privilege to SYSTEM for edition ora$base.
Rem
DECLARE
  edition_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(edition_does_not_exist, -38802);
BEGIN
  execute immediate
    'grant use on edition ora$base to system with grant option';
EXCEPTION
  WHEN edition_does_not_exist THEN
    NULL;
END;
/

Rem ====================================================================
Rem End Changes for Security
Rem ====================================================================

Rem =======================================================================
Rem Begin OFS 12.2 changes
Rem =======================================================================

alter table ofsmtab$ add (fsid integer default 0);
alter table ofsmtab$ add (nodenm varchar2(256));
create table ofsftab$
(
  fstype                  varchar(64) not null,
  fsname                  varchar(64) not null,
  fs_metadata_table_owner varchar2(30) default 'SYS',
  fs_metadata_table_name  varchar2(30), 
  fs_data_table_owner     varchar2(30) default 'SYS',
  fs_data_table_name      varchar2(30), 
  fs_creation_time        date default sysdate,
  constraint pk_ofsftab$ primary key (fstype, fsname)
);

Rem ====================================================================
Rem End Changes for OFS
Rem ====================================================================

Rem =======================================================================
Rem Begin OLAP 12.2 changes
Rem =======================================================================

alter table aw_obj$ modify (
  objname varchar2(512)
)
/

alter table aw_obj$ modify (
  partname varchar2(512)
)
/

alter table aw_prop$ modify (
  objname varchar2(512)
)
/

alter table olap_aw_deployment_controls$ modify (
  physical_name varchar2(512)
)
/

alter table olap_metadata_dependencies$ modify (
  p_owner varchar2(128)
)
/

alter table olap_metadata_dependencies$ modify (
  p_top_obj_name varchar2(128)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name1 varchar2(128)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name2 varchar2(128)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name3 varchar2(128)
)
/

alter table olap_metadata_dependencies$ modify (
  p_sub_obj_name4 varchar2(128)
)
/

alter table olap_metadata_properties$ modify (
  property_key varchar2(128)
)
/

Rem =======================================================================
Rem End OLAP 12.2 changes
Rem =======================================================================

Rem *************************************************************************
Rem START Bug 17267114
Rem *************************************************************************

--
-- Guarantee that object types without super types
-- have a NULL super type object ID
--
update sys.type$ set supertoid=null where 
        supertoid='00000000000000000000000000000000';
commit;

Rem *************************************************************************
Rem END Bug 17267114
Rem *************************************************************************

Rem =======================================================================
Rem BEGIN Changes for container$
Rem =======================================================================

rem bug 16863416
alter table container$ rename column spare1 to vsn;

rem support for federations
alter table container$ rename column spare2 to fed_root_con_id#;

rem replenish supply of spare number columns
alter table container$ add (spare5 NUMBER);
alter table container$ add (spare6 NUMBER);

rem support for local undo
alter table container$ add (undoscn number);

rem Project 47234 - add columns srcpdb and linkname 
alter table container$ add (srcpdb varchar2(128));
alter table container$ add (linkname varchar2(128));

rem Begin Bug 19525987: add container$.upgrade_priority and set it for
rem                     CDB$ROOT and PDB$SEED
alter table container$ add (upgrade_priority number);
update container$ set upgrade_priority=1 where con_id# in (1,2);
commit;

rem Project 47234 - reserved afn#
alter table container$ add (rafn# number);

rem Project 47234 - add columns containers_port and containers_host
alter table container$ add (containers_port number);
alter table container$ add (containers_host varchar2(128));

rem Project 47234 - add columns to store remote info for view PDBs
alter table container$ add (remote_port number);
alter table container$ add (remote_host varchar2(128));
alter table container$ add (remote_srvc varchar2(128));

rem Project 47234 - add columns srcpdbuid, lastrcvscnwrp, lastrcvscnbas
alter table container$ add (srcpdbuid number);
alter table container$ add (lastrcvscn number);

rem Project 47234 - add column to store remote user for view PDB
alter table container$ add (remote_user varchar2(128));

rem Project 47808
alter table container$ add (f_cdb_dbid number);
alter table container$ add (uscn number);
alter table container$ add (f_con_id# number);

rem Project 47234
alter table container$ add (undots date);
alter table container$ add (refreshint number);

alter table container$ add (postplugscn number);
alter table container$ add (postplugtime date);

rem set initial value for postplugtime and postplugscn
update container$ c
   set c.postplugscn=c.create_scnwrp*power(2,32)+c.create_scnbas,
       c.postplugtime=(select ctime from obj$ o where o.obj#=c.obj#);
commit;

Rem =======================================================================
Rem  END Changes for container$
Rem =======================================================================

Rem
Rem BEGIN Delete duplicate comments of shared objects in PDB.
Rem       See also bug 19954575.
Rem

delete sys.com$ c
where c.obj# in
 (select o.obj# from sys.obj$ o 
  where bitand(o.flags, 196608) > 0
  and 
  (
   (bitand(o.flags, 4194304) > 0 and 
    sys_context('USERENV', 'CON_ID')>1)
   or
   (bitand(o.flags, 134217728) > 0 and
    sys_context('USERENV', 'APPLICATION_NAME') <>  
    sys_context('USERENV', 'CON_NAME'))
  )
 )
/
commit;

Rem
Rem END Delete duplicate comments of shared objects in PDB.
Rem

Rem
Rem BEGIN Proj 47234: create view_pdb$
Rem This table stores attributes related to View PDBS
Rem

create table view_pdb$
(
  con_uid     number,                    /* container Unique ID for view PDB */
  port        number,                             /* port number of view PDB */
  host        varchar2(128),                        /* host name of view PDB */
  service     varchar2(64),                      /* service name of view PDB */
  tgt_con_uid number                   /* container unique ID for target PDB */
)
/

Rem
Rem END Proj 47234: create view_pdb$
Rem

Rem
Rem Bug 21898184: add table to store attributes of remote PDBs of a Proxy PDB
Rem

create table proxy_remote$
(
  con_id#     number,                           /* container ID of Proxy PDB */
  name        varchar2(128) not null,                      /* name for entry */
  flag        number,                                      /* flag for entry */
  remote_port number,                          /* port number for remote PDB */
  remote_host varchar2(128),                     /* host name for remote PDB */
  remote_srvc varchar2(64),                   /* service name for remote PDB */
  remote_user varchar2(128),                     /* user name for remote PDB */
  spare1      number,
  spare2      number,
  spare3      number,
  spare4      varchar2(1000),
  spare5      varchar2(1000),
  spare6      date
)
/

Rem
Rem Bug 21898184: add table to store attributes of remote PDBs of a Proxy PDB
Rem 

Rem
Rem BEGIN Bug 20984107: Remove sharing=object and set sharing=metadata on 
Rem                     Datapump tables:
Rem                     NOEXP$, EXPACT$, IMPCALLOUTREG$, EXPPKGACT$, and
Rem                     EXPPKGOBJ$
Rem

update obj$ o
   set o.flags = o.flags - 131072 + 65536
 where bitand(o.flags, 131072) =  131072
   and o.name in ('NOEXP$', 'EXPACT$', 'IMPCALLOUTREG$', 'EXPPKGACT$',
                  'EXPPKGOBJ$')
   and o.owner# = 0
/
commit;

Rem
Rem   END Bug 20984107: Remove sharing=object and set sharing=metadata on 
Rem                     Datapump tables:
Rem                       NOEXP$, EXPACT$, IMPCALLOUTREG$, EXPPKGACT$, 
Rem                       and EXPPKGOBJ$
Rem

Rem
Rem BEGIN Bug 20985003: Migrate Common Data views to use a bit in the second 
Rem                     word of PROPERTY column in VIEW$. This bit is 
Rem                     KQLDTVCP2_COMMON_DATA (defined as 0x00100000 or
Rem                     power(2,20)). In 12.1, Common Data views use 
Rem                     KQLDTVCP_COMMON_DATA (defined as 0x04000000 or 
Rem                     power(2,26))
Rem

update view$
set property = property - power(2,26) + power(2,32+20)
where bitand(property, power(2,26)) = power(2,26)
  and bitand(property, power(2,32+20)) = 0
/
commit;

Rem   END Bug 20985003: Migrate Common Data views to use a bit in the second 
Rem                     word of PROPERTY column in VIEW$. This bit is 
Rem                     KQLDTVCP2_COMMON_DATA (defined as 0x00100000 or
Rem                     power(2,20)). In 12.1, Common Data views use 
Rem                     KQLDTVCP_COMMON_DATA (defined as 0x04000000 or 
Rem                     power(2,26))
Rem

rem delete package procedure with zero arguments from argument$
delete from argument$ where argument is null and type#=0 and pls_type is null
  and position#=1 and sequence#=0 and level#=0;

Rem =======================================================================
Rem Begin Changes for Traditional Audit
Rem =======================================================================

rem Bug 16496620
AUDIT DIRECTORY BY ACCESS
/

AUDIT PLUGGABLE DATABASE BY ACCESS
/

rem Bug 20383779: Configure Traditional Audit on BECOME USER privilege
AUDIT BECOME USER BY ACCESS
/

Rem =======================================================================
Rem End Changes for Traditional Audit
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Unified Auditing
Rem =======================================================================

rem Bug 16066652
begin
  execute immediate 'alter table sys.dam_cleanup_jobs$ add job_flags number';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

rem Bug 20961072: Clear the common bit of all the out of the box unified audit
rem               policies
update aud_policy$ 
   set type=type-16
   where policy# in
   (select obj.obj# from obj$ obj
    where obj.type#=115
    and obj.name in ('ORA_SECURECONFIG', 'ORA_DV_AUDPOL',
                     'ORA_RAS_POLICY_MGMT', 'ORA_RAS_SESSION_MGMT', 
                     'ORA_ACCOUNT_MGMT', 'ORA_DATABASE_PARAMETER', 
                     'ORA_LOGON_FAILURES', 'ORA_CIS_RECOMMENDATIONS'))
   and bitand(type,16)=16
/
commit;

rem Bug 16080525 : add DBMS_RLS to default out-of-the-box Unified audit policy
alter audit policy ora_secureconfig add actions execute on dbms_rls
/

rem Bug 20383779: Add BECOME USER privilege audit-option to out-of-the-box
rem               Unified audit policy
alter audit policy ora_secureconfig add privileges BECOME USER
/

rem Bug 17299076: audit policy with CIS recommended audit options
CREATE AUDIT POLICY ORA_CIS_RECOMMENDATIONS
              PRIVILEGES SELECT ANY DICTIONARY, CREATE ANY LIBRARY,
                         DROP ANY LIBRARY, CREATE ANY TRIGGER,
                         ALTER ANY TRIGGER, DROP ANY TRIGGER, ALTER SYSTEM 
                 ACTIONS CREATE USER, ALTER USER, DROP USER,
                         CREATE ROLE, DROP ROLE, ALTER ROLE,
                         GRANT, REVOKE, CREATE DATABASE LINK,
                         ALTER DATABASE LINK, DROP DATABASE LINK,
                         CREATE PROFILE, ALTER PROFILE, DROP PROFILE,
                         CREATE SYNONYM, DROP SYNONYM,
                         CREATE PROCEDURE, DROP PROCEDURE, ALTER PROCEDURE
/
comment on audit policy ORA_CIS_RECOMMENDATIONS is
'Audit policy containing audit options as per CIS recommendations'
/

rem Bug 18174384: remove Logon/Logoff from default out-of-the-box 
rem Unified audit policy
create audit policy ora_logon_failures actions logon
/
comment on audit policy ora_logon_failures is
'Audit policy containing audit options to capture logon failures'
/
alter audit policy ora_secureconfig drop actions logon, logoff
/

rem Bug 20280545: increase size of sys.dam_cleanup_jobs$.job_name to 128
alter table sys.dam_cleanup_jobs$ modify job_name varchar2(128)
/

Rem *************************************************************************
Rem Begin Bug 14168362: Support cleanup of old dbid and guid based audit data
Rem *************************************************************************
alter table sys.dam_last_arch_ts$ drop constraint DAM_LAST_ARCH_TS_UK1;
alter table sys.dam_last_arch_ts$ add(database_id     number);
alter table sys.dam_last_arch_ts$ add(container_guid  varchar2(33));

declare
  dbid number;
  pdbguid varchar2(33);
begin
  select dbid into dbid from v$containers
  where name = SYS_CONTEXT('USERENV', 'CON_NAME');
  select guid into pdbguid from v$containers 
  where name = SYS_CONTEXT('USERENV', 'CON_NAME');

  -- Bug 25717371: Update DBID, GUID columns only when they are newly added.
  -- If they already exist in sys.dam_last_arch_ts$ with NON-NULL values,
  -- audit supports APIs to perform cleanup based on old DBID and GUIDs.
  execute immediate 'update sys.dam_last_arch_ts$ ' ||
                    'set database_id = :dbid, container_guid = :pdbguid ' ||
                    'where database_id is NULL and container_guid is NULL'
  using dbid, pdbguid;
  commit;
end;
/

alter table sys.dam_last_arch_ts$ modify(database_id not null);
alter table sys.dam_last_arch_ts$ modify(container_guid not null);

drop index sys.i_dam_last_arch_ts$;
create unique index sys.i_dam_last_arch_ts$ on sys.dam_last_arch_ts$
(audit_trail_type#, rac_instance#, database_id, container_guid);

Rem *************************************************************************
Rem End Bug 14168362: Support cleanup of old dbid and guid based audit data
Rem *************************************************************************

rem bug 21787568: add new statement audit options

BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP VALUES (362, 'READ DIRECTORY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP VALUES (363, 'WRITE DIRECTORY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP VALUES (364, 'EXECUTE DIRECTORY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

-- Bug 24812771: Make sure we set the read-only property for unified audit
-- internal table AUDSYS.AUD$UNIFIED
update sys.tab$ set property = property + 4835703278458516698824704 - bitand(property, 4835703278458516698824704) where obj# = (select o.obj# from obj$ o where o.name = 'AUD$UNIFIED' and o.type# = 2 and o.owner# = (select u.user# from user$ u where u.name ='AUDSYS'));
commit;

Rem =======================================================================
Rem  End Changes for Unified Auditing
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for RAS
Rem =======================================================================
-- drop column profile from xs$prin : project#46908
begin
  execute immediate 'alter table sys.xs$prin drop column profile';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

-- add columns in xs$prin table : project#46908
begin
  execute immediate 'alter table sys.xs$prin add profile# number default 0';
  execute immediate 'alter table sys.xs$prin add ptime date';
  execute immediate 'alter table sys.xs$prin add exptime date';
  execute immediate 'alter table sys.xs$prin add ltime date';
  execute immediate 'alter table sys.xs$prin add lslogontime date';
  execute immediate 'alter table sys.xs$prin add astatus number default 0';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/ 

-- add columns description in xs$instset_rule
  alter table sys.xs$instset_rule add description varchar2(4000) default null;

-- drop type XS$REALM_CONSTRAINT_TYPE 
  drop type XS$REALM_CONSTRAINT_TYPE force;

-- change column acloid data type in rxs$sessions
  truncate table sys.rxs$sessions;

alter table sys.rxs$sessions modify (acloid number);

-- Do not grant MODIFY_SESSION system privilege to XSPUBLIC
declare
  priv_id number;
  xspublic_id number;
  acl_id number;
begin
  execute immediate 'select id from sys.xs$obj where name = ''MODIFY_SESSION''' into priv_id;
  execute immediate 'select id from sys.xs$obj where name = ''XSPUBLIC''' into xspublic_id;
  execute immediate 'select id from sys.xs$obj where name = ''SESSIONACL''' into acl_id;
  execute immediate 'delete from sys.xs$ace_priv where acl#=:1 and priv#=:2'using acl_id, priv_id;
  execute immediate 'delete from sys.xs$ace where acl#=:1 and prin#=:2' using acl_id, xspublic_id;
  execute immediate 'commit';
exception
  when others then
    if sqlcode in (-904, -942, -1403, 100) then null;
    else raise;
  end if;
end;
/

Rem Bug 21080787, 22393016:
Rem Place the fix here, so that the problem would also be fixed in any 12.1.0.x 
Rem databases that had been upgraded from 11.2 without the fix, and then 
Rem upgraded to 12.2.
Rem For backport to 12.1.0.1, the following fix would need to be moved to 
Rem c1102000.sql.

Rem   Remove grants for the old catalog views with v$/gv$ prefix
DELETE FROM objauth$
  WHERE obj# IN  (SELECT obj# FROM obj$ WHERE subname = '$DEPRECATED$');

COMMIT;

Rem =======================================================================
Rem  End Changes for RAS
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.1.0.2 Changes for Logminer
Rem =======================================================================

Rem Must ensure that at least one value has been fetched from logmnr_uids$
Rem to ensure that min is at least 100.  Without min being at least 100
Rem the following alter will fail

Rem Put this inside PL/SQL to force upgrade capture.
DECLARE
  val number;
BEGIN
  SELECT system.logmnr_uids$.nextval into val FROM dual;
END;
/

COMMIT;
ALTER SEQUENCE system.logmnr_uids$
       INCREMENT BY 1 ORDER NOCACHE
       MINVALUE 100
       MAXVALUE 99999 CYCLE ;

BEGIN
  INSERT INTO SYSTEM_PRIVILEGE_MAP(PRIVILEGE,NAME,PROPERTY)
  VALUES (-389, 'LOGMINING', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP(OPTION#,NAME,PROPERTY)
  VALUES (389, 'LOGMINING', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

-- Drop types modified in 12.1.0.2
-- These types are only used as a part of the API for internally used
-- table functions so there should not be any user objects dependent
-- upon them, hence dropping is ok.  Types will be recreated in
-- catlmnr.sql.

drop TYPE SYSTEM.LOGMNR$TAB_GG_RECS;
drop TYPE SYSTEM.LOGMNR$TAB_GG_REC;
drop TYPE SYSTEM.LOGMNR$COL_GG_RECS;
drop TYPE SYSTEM.LOGMNR$COL_GG_REC;

drop package dbms_logmnr_session;

Rem =======================================================================
Rem  End 12.1.0.2 Changes for Logminer
Rem =======================================================================


Rem =======================================================================
Rem  Begin 12.2 Changes for Logminer
Rem =======================================================================

Alter table system.logmnrc_gsba add (DB_GLOBAL_NAME VARCHAR2(384));

-- Add session# column for project 56343
alter table system.logmnr_global$ add (session# number);

-- At most one row should exist in global$ prior to 12.2.  This row 
-- corresponds with fast recovery area state on an active logical standby
-- database.  Since a session# column has been added, this column 
-- must be initialized to the id of the associated logminer session.
declare
  rowcount  number;
  sessid    number;
  updated   boolean := FALSE;
begin
  -- only update global$ on logical standby databases
  select count(1) into rowcount from v$database where 
    database_role = 'LOGICAL STANDBY';

  if rowcount = 1 then
    -- ensure the logical was fully instantiated
    select nvl(max(value), 0) into sessid
      from system.logstdby$parameters where name = 'LMNR_SID';

    if sessid > 0 then
      -- at most a single row should exist
      select count(1) into rowcount from system.logmnr_global$;

      if rowcount = 1 then
        update system.logmnr_global$ set session# = sessid;
        commit;
        updated := TRUE;
      end if;
    end if;
  end if;

  -- All other cases should result in a truncate of the table.  This includes
  -- scenarios such as:
  --   - primary database that was formerly a logical standby
  --   - multiple global$ entries (bug 18414679)
  if updated = FALSE then 
    execute immediate 'truncate table system.logmnr_global$';
  end if;
end;
/

/* Automatic CDR */
alter table system.logmnrggc_gtlo add (acdrflags        number,
                                       acdrtsobj#       number,
                                       acdrrowtsintcol# number);
alter table system.logmnrggc_gtcs add (collid      number,
                                       collintcol# number,
                                       acdrrescol# number);
alter table system.logmnrc_gtlo add (acdrflags        number,
                                     acdrtsobj#       number,
                                     acdrrowtsintcol# number);
alter table system.logmnrc_gtcs add (collid      number,
                                     collintcol# number,
                                     acdrrescol# number);
alter table system.logmnr_tab$ add (acdrflags        number,
                                    acdrtsobj#       number,
                                    acdrrowtsintcol# number);
alter table system.logmnr_col$ add (collid      number,
                                    collintcol# number,
                                    acdrrescol# number);

/*
 * Column order is critical, so we drop and recreate these empty gather tables.
 */
drop table sys.logmnrg_tab$;

create table sys.logmnrg_tab$ (
      ts#              number(22),
      cols             number(22),
      property         number,
      intcols          number(22),
      kernelcols       number(22),
      bobj#            number(22),
      trigflag         number(22),
      flags            number(22),
      acdrflags        number,                              /* Automatic CDR */
      acdrtsobj#       number,                              /* Automatic CDR */
      acdrrowtsintcol# number,                              /* Automatic CDR */
      obj#             number(22) not null)  /* last column must be non null */
   segment creation immediate
   tablespace system logging
/

drop table sys.logmnrg_col$;
create table sys.logmnrg_col$ (
      col#        number(22),
      segcol#     number(22),
      name        varchar2(128),
      type#       number(22),
      length      number(22),
      precision#  number(22),
      scale       number(22),
      null$       number(22),
      intcol#     number(22),
      property    number(22),
      charsetid   number(22),
      charsetform number(22),
      spare1      number(22),
      spare2      number(22),
      collid      number,
      collintcol# number,
      acdrrescol# number,                                   /* Automatic CDR */
      obj#        number(22) not null)       /* last column must be non null */
   segment creation immediate
   tablespace system logging
/

-- per pdb characterset changes (dlmnr.bsq)
alter table system.logmnr_gt_tab_include$ modify (schema_name varchar2(390));
alter table system.logmnr_gt_tab_include$ modify (table_name varchar2(390));
alter table system.logmnr_gt_tab_include$ modify (pdb_name varchar2(390));

alter table system.logmnr_gt_user_include$ modify (user_name varchar2(390));
alter table system.logmnr_gt_user_include$ modify (pdb_name varchar2(390));

alter table system.logmnr_pdb_info$ modify (pdb_name varchar2(384));
alter table system.logmnr_pdb_info$ modify (pdb_global_name varchar2(384));

alter table system.logmnr_uid$ modify (pdb_name varchar2(384));

alter table system.logmnrggc_gtlo modify (ownername varchar2(384));
alter table system.logmnrggc_gtlo modify (lvl0name varchar2(384));
alter table system.logmnrggc_gtlo modify (lvl1name varchar2(384));
alter table system.logmnrggc_gtlo modify (lvl2name varchar2(384));
alter table system.logmnrggc_gtlo modify (tsname varchar2(90));

alter table system.logmnrggc_gtcs modify (colname varchar2(384));
alter table system.logmnrggc_gtcs modify (typename varchar2(384));
alter table system.logmnrggc_gtcs modify (xtypeschemaname varchar2(384));
alter table system.logmnrggc_gtcs modify (eamkeyid varchar2(192));

alter table system.logmnrc_dbname_uid_map modify (global_name varchar2(384));
alter table system.logmnrc_dbname_uid_map modify (pdb_name varchar2(384));

alter table system.logmnr_parameter$ modify (name varchar2(384));

alter table system.logmnr_session$ modify (global_db_name varchar2(384));

-- per pdb characterset changes (catlmnr.sql)
alter table system.logmnrc_gtlo modify (ownername varchar2(384));
alter table system.logmnrc_gtlo modify (lvl0name varchar2(384));
alter table system.logmnrc_gtlo modify (lvl1name varchar2(384));
alter table system.logmnrc_gtlo modify (lvl2name varchar2(384));
alter table system.logmnrc_gtlo modify (tsname varchar2(90));

alter table system.logmnrc_gtcs modify (colname  varchar2(384));
alter table system.logmnrc_gtcs modify (typename varchar2(384));
alter table system.logmnrc_gtcs modify (xtypeschemaname varchar2(384));
alter table system.logmnrc_gtcs modify (eamkeyid varchar2(192));

alter table system.logmnrc_seq_gg modify (ownername varchar2(384));
alter table system.logmnrc_seq_gg modify (objname varchar2(384));

alter table system.logmnrc_con_gg modify (name varchar2(384));

alter table system.logmnrc_ind_gg modify (name varchar2(384));
alter table system.logmnrc_ind_gg modify (ownername varchar2(384));

alter table system.logmnrc_gsba modify (dbtimezone_value varchar2(192));
-- logmnrc_gsba.db_global_name added above for this release, no need to modify

alter table system.logmnr_seed$ modify (schemaname varchar2(384));
alter table system.logmnr_seed$ modify (table_name varchar2(384));
alter table system.logmnr_seed$ modify (col_name varchar2(384));

alter table system.logmnr_dictionary$ modify (db_name varchar2(27));

alter table system.logmnr_dictionary$ modify (db_character_set varchar2(192));
alter table system.logmnr_dictionary$ modify (db_version varchar(240));
alter table system.logmnr_dictionary$ modify (db_status varchar(240));
alter table system.logmnr_dictionary$ modify (db_global_name varchar(384));
alter table system.logmnr_dictionary$ modify (pdb_name varchar2(384));
alter table system.logmnr_dictionary$ modify (pdb_global_name varchar2(384));

alter table system.logmnr_obj$ modify (name varchar2(384));
alter table system.logmnr_obj$ modify (subname varchar2(384));
alter table system.logmnr_obj$ modify (remoteowner varchar2(384));
alter table system.logmnr_obj$ modify (linkname varchar(384));

alter table system.logmnr_col$ modify (name varchar2(384));

alter table system.logmnr_ts$ modify (name varchar2(90));

alter table system.logmnr_user$ modify (name varchar2(384));

alter table system.logmnr_type$ modify (version  varchar2(384));

alter table system.logmnr_attribute$ modify (name varchar2(384));

alter table system.logmnr_con$ modify (name varchar2(384));

alter table system.logmnr_kopm$ modify (name varchar2(384));

alter table system.logmnr_props$ modify (name varchar2(384));

alter table system.logmnr_enc$ modify (mkeyid varchar2(192));

alter table system.logmnr_partobj$ modify (parameters varchar2(3000));

-- drop modified types these are recreated in catlmnr.sql
-- as these are only used by table functions they should be ok to drop

-- logmnr$tab_gg_recs already dropped above
-- logmnr$tab_gg_rec  already dropped above
-- logmnr$col_gg_recs already dropped above
-- logmnr$col_gg_rec  already dropped above
drop type system.logmnr$seq_gg_recs;
drop type system.logmnr$seq_gg_rec;
drop type system.logmnr$key_gg_recs;
drop type system.logmnr$key_gg_rec;
drop type system.logmnr$gsba_gg_recs;
drop type system.logmnr$gsba_gg_rec;

-- recreate to ensure correct column layout (table should be empty)
drop table SYS.LOGMNRG_CONTAINER$ purge;

CREATE TABLE SYS.LOGMNRG_CONTAINER$ (
     OBJ#          NUMBER NOT NULL,      /* Object number for the container */
     CON_ID#       NUMBER NOT NULL,                         /* container ID */
     DBID          NUMBER NOT NULL,                          /* database ID */
     CON_UID       NUMBER NOT NULL,                            /* unique ID */
     FLAGS         NUMBER,                                         /* flags */
     STATUS        NUMBER NOT NULL,                    /* active, plugged...*/
     VSN           NUMBER,                                  /* software vsn */
     FED_ROOT_CON_ID# NUMBER,   /* CON_ID of Application Root if applicable */
     CREATE_SCNWRP NUMBER NOT NULL,                    /* creation scn wrap */
     CREATE_SCNBAS NUMBER NOT NULL)                    /* creation scn base */
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/

alter table system.logmnr_container$ add (vsn number);
alter table system.logmnr_container$ add (fed_root_con_id# number);

-- recreate to ensure correct column layout (table should be empty)
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
      FED_ROOT_CON_ID# NUMBER,
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL  ) 
   SEGMENT CREATION IMMEDIATE
   TABLESPACE SYSTEM LOGGING
/
alter table system.logmnr_dictionary$ add (fed_root_con_id# number);

-- Sharding support
alter table system.logmnr_ts$ add (start_scnbas number, start_scnwrp number);
create table sys.logmnrg_shard_ts (
   tablespace_name  varchar2(30),
   chunk_number     number)
   segment creation immediate
   tablespace system logging
/

alter table system.logmnr_tab$ modify (property number);

-- Truncate logmnrg_% tables
TRUNCATE TABLE SYS.LOGMNRG_SEED$;
TRUNCATE TABLE SYS.LOGMNRG_OBJ$;
TRUNCATE TABLE SYS.LOGMNRG_ATTRCOL$;
TRUNCATE TABLE SYS.LOGMNRG_TS$;
TRUNCATE TABLE SYS.LOGMNRG_IND$;
TRUNCATE TABLE SYS.LOGMNRG_USER$;
TRUNCATE TABLE SYS.LOGMNRG_TABPART$;
TRUNCATE TABLE SYS.LOGMNRG_TABSUBPART$;
TRUNCATE TABLE SYS.LOGMNRG_TABCOMPART$;
TRUNCATE TABLE SYS.LOGMNRG_TYPE$;
TRUNCATE TABLE SYS.LOGMNRG_COLTYPE$;
TRUNCATE TABLE SYS.LOGMNRG_ATTRIBUTE$;
TRUNCATE TABLE SYS.LOGMNRG_LOB$;
TRUNCATE TABLE SYS.LOGMNRG_CON$;
TRUNCATE TABLE SYS.LOGMNRG_CDEF$;
TRUNCATE TABLE SYS.LOGMNRG_CCOL$;
TRUNCATE TABLE SYS.LOGMNRG_ICOL$;
TRUNCATE TABLE SYS.LOGMNRG_LOBFRAG$;
TRUNCATE TABLE SYS.LOGMNRG_INDPART$;
TRUNCATE TABLE SYS.LOGMNRG_INDSUBPART$;
TRUNCATE TABLE SYS.LOGMNRG_INDCOMPART$;
TRUNCATE TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG;
TRUNCATE TABLE SYS.LOGMNRG_NTAB$;
TRUNCATE TABLE SYS.LOGMNRG_OPQTYPE$;
TRUNCATE TABLE SYS.LOGMNRG_SUBCOLTYPE$;
TRUNCATE TABLE SYS.LOGMNRG_KOPM$;
TRUNCATE TABLE SYS.LOGMNRG_PROPS$;
TRUNCATE TABLE SYS.LOGMNRG_ENC$;
TRUNCATE TABLE SYS.LOGMNRG_REFCON$;
TRUNCATE TABLE SYS.LOGMNRG_PARTOBJ$;

/* Added for CDB non-unique xid (local undo) */
alter table system.logmnr_gt_xid_include$ add (pdbid    number,
                                               pdb_name varchar2(390));
alter table system.logmnr_session_actions$ add (pdbid   number,
                                               pdb_name varchar2(390));
alter table system.logmnr_spill$ drop constraint
  logmnr_spill$_pk;
alter table system.logmnr_spill$ add (pdbid number);
update system.logmnr_spill$ set pdbid = 0;
commit;
alter table system.logmnr_spill$ add constraint
  logmnr_spill$_pk primary key
  (session#, pdbid, xidusn, xidslt, xidsqn, chunk,
   startidx, endidx, flag, sequence#)
  using index tablespace sysaux logging;

alter table system.logmnr_age_spill$ drop constraint
  logmnr_age_spill$_pk;
alter table system.logmnr_age_spill$ add (pdbid number);
update system.logmnr_age_spill$ set pdbid = 0;
commit;
alter table system.logmnr_age_spill$ add constraint
  logmnr_age_spill$_pk primary key
  (session#, pdbid, xidusn, xidslt, xidsqn, chunk, sequence#)
  using index tablespace sysaux logging;

alter table system.logmnr_restart_ckpt$ drop constraint
  logmnr_restart_ckpt$_pk;
alter table system.logmnr_restart_ckpt$ add (pdbid number);
update system.logmnr_restart_ckpt$ set pdbid = 0;
commit;
alter table system.logmnr_restart_ckpt$ add constraint
  logmnr_restart_ckpt$_pk primary key
  (session#, ckpt_scn, xidusn, xidslt, xidsqn, pdbid, session_num, serial_num)
  using index tablespace sysaux logging;

-- Do not add a corresponding downgrade action to NULL this.  This will allow
-- us to use new flags in a 12.1 backport and retain their values in the
-- event of an upgrade - downgrade scenario.
update system.logmnr_did$ set flags = 0 where flags is null;
commit;

alter table system.logmnr_did$ modify (flags default 0);

Rem =======================================================================
Rem  End 12.2 Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.1.0.2 Changes for Logical Standby
Rem =======================================================================

alter table system.logstdby$apply_milestone add (lwm_upd_time DATE);
update system.logstdby$apply_milestone set lwm_upd_time = sysdate;
commit;

alter table system.logstdby$apply_milestone add (spare4 NUMBER);
alter table system.logstdby$apply_milestone add (spare5 NUMBER);
alter table system.logstdby$apply_milestone add (spare6 NUMBER);
alter table system.logstdby$apply_milestone add (spare7 DATE);
alter table system.logstdby$apply_milestone add (pto_recovery_scn NUMBER);
alter table system.logstdby$apply_milestone 
            add (pto_recovery_incarnation NUMBER);

alter table system.logstdby$events add (con_id number);

Rem =======================================================================
Rem  End 12.1.0.2 Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.2.0.0 Changes for Logical Standby
Rem =======================================================================

-- Bug 21281961: with the rewrite of (un)supported views to use a UNION ALL,
-- the table functions and accompanying types are no longer needed.
drop function logstdby$tabf;
drop type logstdby$srecs force;
drop type logstdby$srec force;
drop function logstdby$utabf;
drop type logstdby$urecs force;
drop type logstdby$urec force;


begin
  if (SYS_CONTEXT('USERENV','CON_ID') != 1) then
    delete from system.logstdby$skip
      where statement_opt = 'CONTAINER';
    commit;
  end if;
end;
/

-- Remove existing skip rules.  Users need to re-add them specifying con_name.
truncate table system.logstdby$skip_transaction;
alter table system.logstdby$skip_transaction add (con_name varchar2(384));

Rem =======================================================================
Rem  End 12.2.0.0 Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem Begin 12.2 changes for DBMS_ROLLING 
Rem =======================================================================

-- 18842051: increase columns to accommodate 128 members in a DG config
alter table system.rolling$parameters modify 
  (curval varchar2(1024), lstval varchar2(1024), defval varchar2(1024));

Rem =======================================================================
Rem End 12.2 changes for DBMS_ROLLING
Rem =======================================================================


Rem =======================================================================
Rem BEGIN IMC changes
Rem =======================================================================

Rem File dcore.bsq - add imc flag to deferred_stg$
alter table deferred_stg$ add (imcflag_stg number);

Rem We remove inmemory CUs from compression$ to force analyzer to run on
Rem those CUs. This ensures we do not carry forward IMC CU formats from
Rem 12.1 to 12.2.
delete from compression$ where ULEVEL >=5 and ULEVEL <= 11;

Rem Zero out spare3 (ddl scn) for selective column entries   
update compression$ set spare3 = 0 where ulevel = 4294967295;

commit;

Rem =======================================================================
Rem END IMC changes
Rem =======================================================================

Rem =======================================================================
Rem BEGIN 12.2 CELLCACHE flag changes
Rem =======================================================================

Rem File dcore.bsq - add ccache flag to deferred_stg$
alter table deferred_stg$ add (ccflag_stg number);
alter table deferred_stg$ add (flags2_stg number);

Rem =======================================================================
Rem END 12.2 CELLCACHE flag changes
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.2 Changes for Physical Standby
Rem =======================================================================

alter table system.redo_db  rename column spare2 to endian;
alter table system.redo_db  rename column spare3 to enqidx;
alter table system.redo_db  rename column scn1_bas to resetlogs_scn;
alter table system.redo_db  rename column scn1_wrp to presetlogs_scn;
alter table system.redo_db  rename column scn1_time to gap_ret2;
alter table system.redo_db  rename column curscn_bas to gap_next_scn;
alter table system.redo_db  rename column curscn_wrp to gap_next_time;
alter table system.redo_db  add (spare8 NUMBER default 0);
alter table system.redo_db  add (spare9 NUMBER default 0);
alter table system.redo_db  add (spare10 NUMBER default 0);
alter table system.redo_db  add (spare11 NUMBER default 0);
alter table system.redo_db  add (spare12 NUMBER default 0);
update system.redo_db set resetlogs_scn_bas=0, resetlogs_scn_wrp=0, resetlogs_time=2, presetlogs_scn_bas=0, presetlogs_scn_wrp=0 where dbid=0 and thread#=0;

alter table system.redo_log  rename column spare1 to endian;
alter table system.redo_log  rename column current_scn_bas to first_scn;
alter table system.redo_log  rename column current_scn_wrp to next_scn;
alter table system.redo_log  rename column current_time to resetlogs_scn;
alter table system.redo_log  rename column current_blkno to presetlogs_scn;
alter table system.redo_log  rename column nab to old_blocks;
alter table system.redo_log  add (spare8 NUMBER default 0);
alter table system.redo_log  add (spare9 NUMBER default 0);
alter table system.redo_log  add (spare10 NUMBER default 0);
alter table system.redo_log  add (old_status1 NUMBER default 0);
alter table system.redo_log  add (old_status2 NUMBER default 0);
alter table system.redo_log  add (old_filename VARCHAR2(513) default '');

Rem redo_rta is not used in 12.2.
drop index system.redo_rta_idx;
drop table system.redo_rta;

Rem =======================================================================
Rem  End 12.2 Changes for Physical Standby
Rem =======================================================================

Rem ====================================================================
Rem BEGIN GDS changes for  12.1.0.2 and 12.2
Rem ===================================================================

-- The assumption here is that both "already exists" and "does not exist"
-- are ignored by the upgrade code; so we simply alter everything that might
-- exist before 12.2 to the new 12.2 format. If the object does not yet exist
-- it will be created later from CATPROC. If the new format already exists,
-- then the error is ignored.

-- create gsmadmin_internal user in case it doesn't already exist (upgrade
-- from pre 12.1 release)
CREATE USER gsmadmin_internal identified by gsm
  account lock password expire
  default tablespace sysaux
  quota unlimited on sysaux
/

-- above will be ignored in upgrade mode if user already exists
-- alter existing user to change quota in this case to be sure
ALTER USER gsmadmin_internal quota unlimited on sysaux
/

-------------------------------------------------------------------------------
-- Create types to hold data in new columns
-------------------------------------------------------------------------------

ALTER SESSION SET CURRENT_SCHEMA = gsmadmin_internal;

CREATE TYPE dbparams_t AS OBJECT (
    param_name     VARCHAR2(30),
    param_value    VARCHAR2(100))
/

CREATE TYPE dbparams_list IS VARRAY(10) OF dbparams_t
/

CREATE TYPE rac_instance_t AS OBJECT (
    instance_name  VARCHAR2(30),
    pref_or_avail  CHAR(1)          -- 'P' (preferred)
                                    -- 'A' (available)
)
/

CREATE OR REPLACE TYPE chunkrange_t FORCE IS OBJECT ( 
                        chk_from  number,
                        chk_to    number )
/

CREATE OR REPLACE TYPE chunkrange_list_t FORCE
   IS TABLE OF chunkrange_t
/

CREATE OR REPLACE TYPE name_list IS TABLE OF VARCHAR2(128)
/

CREATE TYPE number_list IS TABLE OF number
/

CREATE TYPE instance_list IS TABLE OF rac_instance_t
/

ALTER TABLE cloud MODIFY name VARCHAR2(128)
/

------------------------------------------------------------------------------
-- changes to table VNCR
-------------------------------------------------------------------------------

ALTER TABLE vncr MODIFY name VARCHAR2(512)
/

ALTER TABLE vncr MODIFY group_id VARCHAR2(128)
/

ALTER TABLE vncr ADD hostid NUMBER
/

ALTER TABLE vncr ADD hostname VARCHAR2(256)
/

ALTER TABLE vncr DROP PRIMARY KEY CASCADE
/

ALTER TABLE vncr DROP CONSTRAINT pk_vncr CASCADE
/

CREATE SEQUENCE vncr_sequence
/

-- update the new hostid column for any existing data
DECLARE
   vncr_name        varchar2(512);
   TYPE vncr_cur_type IS REF CURSOR;
   vncr_cur         vncr_cur_type;
   select_str       varchar2(32);
BEGIN
   select_str := 'select name from vncr'; 

   OPEN vncr_cur FOR select_str;
   LOOP
    FETCH vncr_cur INTO vncr_name;
    EXIT WHEN vncr_cur%NOTFOUND;
    EXECUTE IMMEDIATE 
     'UPDATE VNCR SET HOSTID = VNCR_SEQUENCE.NEXTVAL
       WHERE NAME = '||DBMS_ASSERT.ENQUOTE_LITERAL(vncr_name);
   END LOOP;
   CLOSE vncr_cur;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -942 THEN 
      NULL;
    ELSE 
      RAISE;
    END IF;
END;
/

ALTER TABLE vncr MODIFY hostid NUMBER NOT NULL
/

---------------------------------------------------------------
-- changes to table CLOUD
-------------------------------------------------------------------------------

ALTER TABLE cloud MODIFY name VARCHAR2(128)
/

ALTER TABLE cloud MODIFY mastergsm VARCHAR2(128)
/

ALTER TABLE cloud ADD
   private_key      RAW(2000)      DEFAULT NULL  -- PKI private key
/

ALTER TABLE cloud ADD
   public_key       RAW(2000)      DEFAULT NULL  -- PKI public key
/

ALTER TABLE cloud ADD
   prvk_enc_str    RAW(1000)  DEFAULT NULL -- flag for private key status
/

ALTER TABLE cloud ADD
   data_vers       VARCHAR2(30) DEFAULT NULL
/

ALTER TABLE cloud ADD
   last_ddl_num       NUMBER default 0           --last ddl_num
/

ALTER TABLE cloud ADD
   last_syncddl_num   NUMBER default 0           --last sync ddl_num
/

ALTER TABLE cloud ADD
   region_num NUMBER -- catalog region
/

ALTER TABLE cloud ADD
   deploy_state NUMBER default 0
/

ALTER TABLE cloud ADD
   objnum_gen NUMBER default 1000000
/

ALTER TABLE cloud ADD
   sharding_type      NUMBER(1) default NULL  -- 0 - not sharded
                                              -- 1 - system managed
                                              -- 2 - user-defined
                                              -- 3 - composite
/

begin
  execute immediate 'UPDATE cloud SET sharding_type = 0 WHERE sharding_type IS NULL';
exception when others then
  if (sqlcode = -942) then null;
  else raise;
  end if;
end;
/

ALTER TABLE cloud ADD
   replication_type   NUMBER(1) default NULL   -- 0 - DataGuard
                                               -- 1 - GoldenGate
/

ALTER TABLE cloud ADD
   protection_mode    NUMBER(1) default NULL   -- 0 - max protection
                                               -- 1 - max availability 
                                               -- 2 - max performance
/

ALTER TABLE cloud ADD
   replication_factor NUMBER default NULL
/

ALTER TABLE cloud ADD
   chunk_count        NUMBER default NULL
/

-------------------------------------------------------------------------------
-- changes to table DATABASE_POOL
-------------------------------------------------------------------------------

ALTER TABLE database_pool MODIFY name VARCHAR2(128)
/

ALTER TABLE database_pool ADD
     replication_type  NUMBER(1) DEFAULT NULL -- 0 - DataGuard
                                              -- 1 - GoldenGate
/

ALTER TABLE database_pool ADD
     pool_type  NUMBER(1) DEFAULT 0 -- 0 - GDS
                                    -- 1 - Sharded
/

begin
  execute immediate 'UPDATE database_pool SET pool_type = 0 WHERE pool_type IS NULL';
exception when others then
  if (sqlcode = -942) then null;
  else raise;
  end if;
end;
/

-------------------------------------------------------------------------------
-- changes to table DATABASE_POOL_ADMIN
-------------------------------------------------------------------------------

ALTER TABLE database_pool_admin MODIFY pool_name VARCHAR2(128)
/

ALTER TABLE database_pool_admin MODIFY user_name VARCHAR2(128)
/

-------------------------------------------------------------------------------
-- changes to table SERVICE_PREFERRED_AVAILABLE
-------------------------------------------------------------------------------

ALTER TABLE service_preferred_available
   MODIFY pool_name VARCHAR2(128)
/

ALTER TABLE service_preferred_available ADD 
   dbparams        dbparams_list DEFAULT NULL
/

ALTER TABLE service_preferred_available ADD
   instances       instance_list DEFAULT NULL
NESTED TABLE instances STORE AS instances_nt
/

ALTER TABLE service_preferred_available ADD
    change_state    CHAR(1) DEFAULT NULL -- record is being changed ?
                                -- NULL - No changes in progress
                                -- 'N' - change is being procesed
/

-- PK will be re-added in CATGWMCAT.SQL
ALTER TABLE service_preferred_available DROP PRIMARY KEY
/

-- re-added in catgwmcat.sql
ALTER TABLE service_preferred_available DROP constraint fk_db_spa
/

-- find system generated constraints from previous
-- releases, need to drop them so that we can change index in database table
-- new constraints are then added back in CATGWMCAT.SQL
DECLARE
   cons_name   varchar2(128);
   TYPE cons_cur_type  IS REF CURSOR;
   cons_cur    cons_cur_type;
   select_str   varchar2(500);
BEGIN
   select_str := 'select oc.name 
      from sys.con$ oc, sys.obj$ o, sys.cdef$ c
      where c.obj# = o.obj# and oc.con# = c.con#
      and o.name=''SERVICE_PREFERRED_AVAILABLE''';
   OPEN cons_cur FOR select_str;
   LOOP
      FETCH cons_cur INTO cons_name;
      EXIT WHEN cons_cur%NOTFOUND;
      execute immediate 
         'alter table service_preferred_available 
            drop constraint ' || dbms_assert.enquote_name(cons_name);
   END LOOP;
   CLOSE cons_cur;
END;
/

-------------------------------------------------------------------------------
-- changes to table DATABASE
-------------------------------------------------------------------------------

ALTER TABLE database MODIFY pool_name VARCHAR2(128)
/

ALTER TABLE database MODIFY gsm_password VARCHAR2(128)
/

ALTER TABLE database MODIFY connect_string VARCHAR2(512)
/

ALTER TABLE database MODIFY scan_address VARCHAR2(512)
/

ALTER TABLE database ADD
   srlat_thresh    NUMBER      DEFAULT 20  -- disk threshold
/

ALTER TABLE database ADD
   cpu_thresh      NUMBER      DEFAULT 75  -- cpu threshold
/

ALTER TABLE database ADD
   version         VARCHAR(30) DEFAULT NULL --database version
/

ALTER TABLE database ADD
   db_type         CHAR(1)     DEFAULT NULL -- database type
/

ALTER TABLE database ADD
   encrypted_gsm_password      RAW(2000)  DEFAULT NULL --encrypted gsm password
/

ALTER TABLE database ADD
    hostid            NUMBER DEFAULT NULL  
/

ALTER TABLE database ADD
     oracle_home      VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
    shardgroup_id            NUMBER DEFAULT NULL  
/

ALTER TABLE database ADD
     ddl_num                NUMBER DEFAULT 0       -- DDL number
/

ALTER TABLE database ADD
     ddl_error              VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
     dpl_status             NUMBER DEFAULT 0
/

ALTER TABLE database ADD
     conv_state             CHAR(1) DEFAULT NULL
/

ALTER TABLE database ADD
    DRSET_NUMBER           NUMBER DEFAULT NULL 
/

ALTER TABLE database ADD
    DEPLOY_AS            NUMBER(1) DEFAULT 0 
/

ALTER TABLE database ADD
    is_monitored           NUMBER(1) DEFAULT 0
/

ALTER TABLE database ADD
    SHARDSPACE_ID           NUMBER DEFAULT NULL 
/

ALTER TABLE database ADD
    dg_params              dbparams_list
/

ALTER TABLE database ADD
    FLAGS              NUMBER DEFAULT NULL
/

ALTER TABLE database ADD
    DESTINATION        VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
    CREDENTIAL         VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
    DBPARAMFILE	       VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
    DBTEMPLATEFILE     VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
    NETPARAMFILE       VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
    SYS_PASSWORD VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
   SYSTEM_PASSWORD VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
   SVCUSERCREDENTIAL VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
   DBNAME VARCHAR2(9) DEFAULT NULL
/

ALTER TABLE database ADD
   DBDOMAIN VARCHAR2(256) DEFAULT NULL
/

ALTER TABLE database ADD
   DBUNIQUENAME VARCHAR2(30) DEFAULT NULL
/

ALTER TABLE database ADD
   INSTANCENAME VARCHAR2(255) DEFAULT NULL
/

ALTER TABLE database ADD
   MINOBJ_NUM NUMBER DEFAULT NULL --obj number range min
/

ALTER TABLE database ADD
   MAXOBJ_NUM NUMBER DEFAULT NULL --obj number range max
/

ALTER TABLE database ADD
   GSM_REQUEST#         NUMBER DEFAULT 0
/

ALTER TABLE database ADD
   response_code        NUMBER DEFAULT NULL
/

ALTER TABLE database ADD
   response_info        VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
   error_info           VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
   int_dbnum            NUMBER DEFAULT 0
/

ALTER TABLE database ADD
   RACK               VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
CDB_NAME        VARCHAR2(128) DEFAULT NULL
/

ALTER TABLE database ADD
GG_SERVICE VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
gg_password     RAW(2000) DEFAULT NULL
/

ALTER TABLE database ADD
SPARE1          VARCHAR2(4000) DEFAULT NULL
/

ALTER TABLE database ADD
SPARE2          VARCHAR2(4000) DEFAULT NULL
/

-- re-create primary key
BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE database DROP PRIMARY KEY';
   EXECUTE IMMEDIATE 'ALTER TABLE database 
      ADD PRIMARY KEY(database_num)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-02273 , -02260 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-------------------------------------------------------------------------------
-- changes to table SERVICE
-------------------------------------------------------------------------------

ALTER TABLE service MODIFY network_name VARCHAR2(512)
/

ALTER TABLE service MODIFY pool_name VARCHAR2(128)
/

ALTER TABLE service MODIFY failover_method VARCHAR2(64)
/

ALTER TABLE service MODIFY failover_type VARCHAR2(64)
/

ALTER TABLE service MODIFY edition VARCHAR2(128)
/

ALTER TABLE service MODIFY pdb VARCHAR2(128)
/

ALTER TABLE service 
   MODIFY session_state_consistency VARCHAR2(128)
/

ALTER TABLE service
   MODIFY sql_translation_profile VARCHAR2(261)
/

ALTER TABLE service ADD
   change_state    CHAR(1) DEFAULT NULL -- record is being changed ?
                                -- NULL - No changes in progress
                                -- 'N' - change is being procesed
/

ALTER TABLE service ADD
   table_family  NUMBER DEFAULT NULL
/

ALTER TABLE service ADD
   stop_option VARCHAR2(13) -- 'NORMAL' or 'IMMEDIATE' or 'TRANSACTIONAL'
/

ALTER TABLE service ADD
   drain_timeout NUMBER DEFAULT NULL
/

-------------------------------------------------------------------------------
-- changes to table GSM_REQUESTS
-------------------------------------------------------------------------------

ALTER TABLE gsm_requests MODIFY
   (error_message    VARCHAR2(4000))
/

ALTER TABLE gsm_requests ADD
   old_instances   instance_list DEFAULT NULL
NESTED TABLE old_instances STORE AS old_instances_nt
/

ALTER TABLE gsm_requests ADD
   error_num      NUMBER DEFAULT NULL
/

ALTER TABLE gsm_requests ADD
   ddl_num        NUMBER DEFAULT NULL 
/

ALTER TABLE gsm_requests ADD
   parent_request       NUMBER DEFAULT NULL 
/

BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE gsm_requests 
      ADD PRIMARY KEY(change_seq#)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -02260 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

-------------------------------------------------------------------------------
-- changes to table REGION
-------------------------------------------------------------------------------

ALTER TABLE region MODIFY name VARCHAR2(128)
/

ALTER TABLE region ADD
   change_state    CHAR(1) DEFAULT NULL -- record is being changed ?
                                -- NULL - No changes in progress
                                -- 'N' - change is being procesed
/

ALTER TABLE region ADD
   weights         VARCHAR2(500) DEFAULT NULL -- weight for manual RLB override
/

ALTER TABLE region ADD
   CS_WEIGHT NUMBER -- region weight for cross-shard ops
/

-------------------------------------------------------------------------------
-- changes to table GSM
-------------------------------------------------------------------------------

ALTER TABLE gsm MODIFY name VARCHAR2(128)
/

ALTER TABLE gsm MODIFY endpoint1 VARCHAR2(512)
/

ALTER TABLE gsm MODIFY endpoint2 VARCHAR2(512)
/

ALTER TABLE gsm ADD
   version         VARCHAR(30) DEFAULT NULL  -- GSM version
/

ALTER TABLE gsm ADD
   change_state    CHAR(1) DEFAULT NULL -- record is being changed ?
                                -- NULL - No changes in progress
                                -- 'N' - change is being procesed
/

COMMIT
/

ALTER SESSION SET CURRENT_SCHEMA = SYS;


Rem ====================================================================
Rem END GDS changes for 12.1.0.2 and 12.2
Rem ===================================================================

Rem =======================================================================
Rem  Begin 12.2 Changes for scheduler 
Rem =======================================================================

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-390, 'USE ANY JOB RESOURCE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (390, 'USE ANY JOB RESOURCE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

alter table sys.scheduler$_program modify(comments varchar2(4000));
alter table sys.scheduler$_class modify(comments varchar2(4000));
alter table sys.scheduler$_job modify(comments varchar2(4000));
alter table sys.scheduler$_window modify(comments varchar2(4000));
alter table sys.scheduler$_window_group modify(comments varchar2(4000));
alter table sys.scheduler$_schedule modify(comments varchar2(4000));
alter table sys.scheduler$_chain modify(comments varchar2(4000));
alter table sys.scheduler$_credential modify(comments varchar2(4000));
alter table scheduler$_file_watcher modify(comments varchar2(4000));
alter table scheduler$_destinations modify(comments varchar2(4000));

Rem ========= Remove "with grant option" from scheduler views =============

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
REVOKE READ ON dba_scheduler_remote_databases FROM public
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
REVOKE READ ON all_scheduler_resources FROM public
REVOKE READ ON all_scheduler_rsc_constraints FROM public
REVOKE READ ON all_scheduler_incompats FROM public
REVOKE READ ON all_scheduler_incompat_member FROM public
REVOKE READ ON user_scheduler_resources FROM public
REVOKE READ ON user_scheduler_rsc_constraints FROM public
REVOKE READ ON user_scheduler_incompats FROM public
REVOKE READ ON user_scheduler_incompat_member FROM public

Rem = bug 23207701 exec grant are beyond select_catalog_role definition = 

revoke execute on dbms_sched_argument_import from select_catalog_role;

Rem =======================================================================
Rem  End 12.2 Changes for scheduler 
Rem =======================================================================

Rem =========================================================================
Rem BEGIN dictionary changes for static ACL MV
Rem =========================================================================

drop index i_acl_mv$_1;
create unique index i_aclmv$_1 on aclmv$(table_obj#, acl_mview_obj#);

Rem =========================================================================
Rem END dictionary changes for  static ACL MV
Rem =========================================================================

Rem =========================================================================
Rem BEGIN Replication changes (Repcat, Streams, XStream, OGG) 
Rem =========================================================================

-- Bug 16047985: Revoke execute grant from public on these packages; 
-- ignore the following errors:
-- -04042: Procedure, function, package, or package body does not exist 
-- -01927: Cannot REVOKE privileges you did not grant

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dbms_checksum FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON lcr$_parameter_list FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dbms_xstream_auth FROM EXECUTE_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dbms_goldengate_auth FROM EXECUTE_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

rem stores the CDR resolution information for populating IR exception tables
create table apply$_cdr_info
(
  local_transaction_id  varchar2(22),      /*local id of txn that errors out */
  Source_transaction_id varchar2(128),       /* transaction id at the source */
  source_database       varchar2(128),       /* db which originated this txn */   
  error_number          number,                     /* error number reported */
  error_message         varchar2(4000),              /* explanation of error */
  source_object_owner   varchar2(128),        /* source database object owner */
  source_object_name    varchar2(128),         /* source database object name */
  dest_object_owner     varchar2(128),          /* dest database object owner */
  dest_object_name      varchar2(128),           /* dest database object name */
  operation             number,                             /* LCR operation */
  position              raw(64),                             /* LCR position */
  seq#                  number,                /* seq# of the replicat trail */
  rba                   number,                 /* rba of the replicat trail */
  index#                number,            /* index # of the replicat record */
  resolution_status     number,                    /* 1. SUCCEEDED 2. FAILED */
  resolution_column     varchar2(4000),        /* column used for resolution */
  resolution_method     number,            /* resolution method
                                            * 1 RECORD, 2 IGNORE, 3 OVERWRITE,
                                            * 4 MAXIMUM, 5 MINIMUM, 6 DELTA  */
  resolution_time       timestamp,           /* time when resolution happens */
  table_successful_cdr  number, /* # of successful resolutions for the table */
  table_failed_cdr      number,     /* # of failed resolutions for the table */
  all_successful_cdr    number, /* # of successful resolutions for the table */
  all_failed_cdr        number,     /* # of failed resolutions for the table */
  flags                 number,                                     /* flags */
  spare1                number,
  spare2                varchar2(4000),
  spare3                timestamp
)
/
create unique index apply$_cdr_info_unq1
 on apply$_cdr_info(local_transaction_id,seq#,rba,index#)
/

alter table sys.apply$_table_stats add (lob_operations NUMBER default 0);

DELETE FROM sys.duc$ WHERE owner='SYS' AND pack='DBMS_STREAMS_ADM_UTL' 
  AND proc='PROCESS_DROP_USER_CASCADE' AND operation#=1;


alter table sys.streams$_apply_milestone add (pto_recovery_scn number);
alter table sys.streams$_apply_milestone add (pto_recovery_incarnation  number);

alter table sys.streams$_component_prop_in modify (prop_name  VARCHAR2(128));
alter table sys.fgr$_file_group_files modify (file_type  VARCHAR2(130));
alter table sys.apply$_error modify (aq_transaction_id  VARCHAR2(128));
alter table sys.rmtab$ modify (name VARCHAR(128));
alter table sys.repl$_dbname_mapping modify (source_container_name varchar2(128));
alter table xstream$_map modify (src_obj_name varchar2(128));
alter table xstream$_map modify (tgt_obj_name varchar2(128));

alter table sys.streams$_apply_process add lcrid_version NUMBER DEFAULT 1;

alter table apply$_dest_obj_ops modify (user_apply_procedure varchar2(392));

alter table sys.streams$_apply_process modify (message_handler varchar2(392));
alter table sys.streams$_apply_process modify (ddl_handler varchar2(392));
alter table sys.streams$_apply_process modify (precommit_handler varchar2(392));
alter table sys.streams$_apply_process modify (ua_notification_handler varchar2(392));

/* Long Identifier missed upgrade actions for Streams/Xstream  */
alter table apply$_error_txn modify(source_object_owner varchar2(128));
alter table apply$_error_txn modify(source_object_name varchar2(128));
alter table apply$_error_txn modify(dest_object_owner varchar2(128));
alter table apply$_error_txn modify(dest_object_name varchar2(128));


alter table apply$_table_stats modify(source_table_owner varchar2(128));
alter table apply$_table_stats modify(source_table_name varchar2(128));
alter table apply$_table_stats modify(destination_table_owner varchar2(128));
alter table apply$_table_stats modify(destination_table_name varchar2(128));

alter table apply$_coordinator_stats modify(apply_name varchar2(128));
alter table apply$_coordinator_stats modify(replname varchar2(128));

alter table apply$_server_stats modify(apply_name varchar2(128));
alter table apply$_reader_stats modify(apply_name varchar2(128));

alter table streams$_database modify(management_pack_access varchar2(128));

alter table xstream$_server modify(connect_user varchar2(128));

alter table xstream$_dml_conflict_handler modify(conflict_handler_name varchar2(128));
alter table xstream$_dml_conflict_handler modify(resolution_column varchar2(128));

alter table xstream$_dml_conflict_columns modify(column_name varchar2(128));

alter table xstream$_reperror_handler modify(apply_name varchar2(128));
alter table xstream$_reperror_handler modify(schema_name varchar2(128));
alter table xstream$_reperror_handler modify(table_name varchar2(128));
alter table xstream$_reperror_handler modify(source_schema_name varchar2(128));
alter table xstream$_reperror_handler modify(source_table_name varchar2(128));

alter table xstream$_handle_collisions modify(apply_name varchar2(128));
alter table xstream$_handle_collisions modify(schema_name varchar2(128));
alter table xstream$_handle_collisions modify(table_name varchar2(128));
alter table xstream$_handle_collisions modify(source_schema_name varchar2(128));
alter table xstream$_handle_collisions modify(source_table_name varchar2(128));

alter table sys.streams$_rules modify (schema_name VARCHAR(384));
alter table sys.streams$_rules modify (object_name VARCHAR(384));
alter table sys.streams$_apply_spill_txn add (pdb_id number default 0);

create table apply$_procedure_stats 
(
apply#                 number,                    /* apply process number */
server_id              number,                 /* apply server identifier */
save_time              date,                 /* when stats were persisted */
startup_time           date,
procedure_owner        varchar2(128),         
package_name           varchar2(128),          
procedure_name         varchar2(128),     
last_update            date,    /* last time stats for table were updated */
total_executions       number, /* total number of executions for the proc */
spare1                 number,
spare2                 number,
spare3                 number,
spare4                 number,
spare5                 varchar2(4000),
spare6                 varchar2(4000),
spare7                 date,
spare8                 date
)
/
create index apply$_procedure_stats_i
  on apply$_procedure_stats (apply#, save_time)
/

alter table sys.apply$_error_txn add (cg_info varchar2(4000));

alter table apply$_error_txn add (source_package_name varchar2(128));
alter table apply$_error_txn add (dest_package_name varchar2(128));

-- move tables to sysaux
alter table sys.apply$_error_txn move tablespace SYSAUX;
-- rebuild index and leave in current tablespace (SYSAUX)
alter index streams$_apply_error_txn_unq rebuild;

alter table sys.apply$_cdr_info move tablespace SYSAUX;
alter index apply$_cdr_info_unq1 rebuild tablespace SYSAUX;

Rem =========================================================================
Rem END Replication changes (Repcat, Streams, XStream, OGG)  
Rem =========================================================================

Rem =========================================================================
Rem BEGIN AWR Changes
Rem =========================================================================

alter table WRH$_REPLICATION_TXN_STATS modify (object_name VARCHAR2(128));

alter table wrm$_baseline modify (baseline_name  VARCHAR2(128));
alter table wrm$_baseline modify (template_name  VARCHAR2(128));

alter table wrm$_baseline_template modify (template_name VARCHAR2(128));
alter table wrm$_baseline_template modify (baseline_name_prefix VARCHAR2(128));

alter table wrh$_dyn_remaster_stats add 
        (remaster_type varchar2(11) default 'AFFINITY' not null);

alter table wrh$_dyn_remaster_stats drop constraint wrh$_dyn_remaster_stats_pk;

alter table wrh$_dyn_remaster_stats add constraint wrh$_dyn_remaster_stats_pk 
        primary key (dbid, snap_id, instance_number, con_dbid, remaster_type)
        using index tablespace SYSAUX;

alter table wrh$_sgastat add (stattype number default 0);

alter table wrh$_sgastat drop constraint wrh$_sgastat_u;

-- Turn off partition check
alter session set events  '14524 trace name context forever, level 1';

alter table wrh$_sgastat add constraint wrh$_sgastat_u
        unique (dbid, snap_id, instance_number, name, pool, con_dbid, stattype)
        using index local tablespace SYSAUX;

-- Turn on partition check
alter session set events  '14524 trace name context off';

alter table wrh$_cell_db add (disk_small_io_reqs          number,
                              disk_large_io_reqs          number,
                              flash_small_io_reqs         number,
                              flash_large_io_reqs         number,
                              disk_small_io_service_time  number,
                              disk_small_io_queue_time    number,
                              disk_large_io_service_time  number,
                              disk_large_io_queue_time    number,
                              flash_small_io_service_time number,
                              flash_small_io_queue_time   number,
                              flash_large_io_service_time number,
                              flash_large_io_queue_time   number);

-- also modify _bl table
alter table wrh$_cell_db_bl add (disk_small_io_reqs          number,
                                 disk_large_io_reqs          number,
                                 flash_small_io_reqs         number,
                                 flash_large_io_reqs         number,
                                 disk_small_io_service_time  number,
                                 disk_small_io_queue_time    number,
                                 disk_large_io_service_time  number,
                                 disk_large_io_queue_time    number,
                                 flash_small_io_service_time number,
                                 flash_small_io_queue_time   number,
                                 flash_large_io_service_time number,
                                 flash_large_io_queue_time   number);

Rem Drop the WRM$_WR_CONTROL_NAME_UK constraint, and ignore
Rem error in case constraint did not exist (ORA 02443)


Rem *************************************************************************
Rem  add columns in AWR tables
Rem *************************************************************************

alter table WRH$_FILESTATXS add (per_pdb number default null);

alter table WRH$_FILESTATXS_BL add (per_pdb number default null);

alter table WRH$_TEMPSTATXS add (per_pdb number default null);

alter table WRH$_DATAFILE add (per_pdb number default null);

alter table WRH$_TEMPFILE add (per_pdb number default null);
 
alter table WRH$_COMP_IOSTAT add (per_pdb number default null);

alter table WRH$_IOSTAT_FUNCTION add (per_pdb number default null);

alter table WRH$_IOSTAT_FUNCTION_NAME add (per_pdb number default null);

alter table WRH$_IOSTAT_FILETYPE add (per_pdb number default null);

alter table WRH$_IOSTAT_FILETYPE_NAME add (per_pdb number default null);

alter table WRH$_IOSTAT_DETAIL add (per_pdb number default null);

alter table WRH$_SQLSTAT add (per_pdb number default null);

alter table WRH$_SQLSTAT_BL add (per_pdb number default null);

alter table WRH$_SQLTEXT add (per_pdb number default null);

alter table WRI$_SQLTEXT_REFCOUNT add (per_pdb number default null);

alter table WRH$_SQL_SUMMARY add (per_pdb number default null);

alter table WRH$_SQL_PLAN add (per_pdb number default null);

alter table WRH$_SQL_BIND_METADATA add (per_pdb number default null);

alter table WRH$_OPTIMIZER_ENV add (per_pdb number default null);

alter table WRH$_SYSTEM_EVENT add (per_pdb number default null);

alter table WRH$_SYSTEM_EVENT_BL add (per_pdb number default null);

alter table WRH$_EVENT_NAME add (per_pdb number default null);

alter table WRH$_LATCH_NAME add (per_pdb number default null);

alter table WRH$_BG_EVENT_SUMMARY add (per_pdb number default null);

alter table WRH$_CHANNEL_WAITS add (per_pdb number default null);

alter table WRH$_WAITSTAT add (per_pdb number default null);

alter table WRH$_WAITSTAT_BL add (per_pdb number default null);

alter table WRH$_ENQUEUE_STAT add (per_pdb number default null);

alter table WRH$_LATCH add (per_pdb number default null);

alter table WRH$_LATCH_BL add (per_pdb number default null);

alter table WRH$_LATCH_CHILDREN add (per_pdb number default null);

alter table WRH$_LATCH_CHILDREN_BL add (per_pdb number default null);

alter table WRH$_LATCH_PARENT add (per_pdb number default null);

alter table WRH$_LATCH_PARENT_BL add (per_pdb number default null);

alter table WRH$_LATCH_MISSES_SUMMARY add (per_pdb number default null);

alter table WRH$_LATCH_MISSES_SUMMARY_BL add (per_pdb number default null);

alter table WRH$_EVENT_HISTOGRAM add (per_pdb number default null);

alter table WRH$_EVENT_HISTOGRAM_BL add (per_pdb number default null);

alter table WRH$_MUTEX_SLEEP add (per_pdb number default null);

alter table WRH$_LIBRARYCACHE add (per_pdb number default null);

alter table WRH$_DB_CACHE_ADVICE add (per_pdb number default null);

alter table WRH$_DB_CACHE_ADVICE_BL add (per_pdb number default null);

alter table WRH$_BUFFER_POOL_STATISTICS add (per_pdb number default null);

alter table WRH$_ROWCACHE_SUMMARY add (per_pdb number default null);

alter table WRH$_ROWCACHE_SUMMARY_BL add (per_pdb number default null);

alter table WRH$_SGA add (per_pdb number default null);

alter table WRH$_SGASTAT add (per_pdb number default null);

alter table WRH$_SGASTAT_BL add (per_pdb number default null);

alter table WRH$_PGASTAT add (per_pdb number default null);

alter table WRH$_PROCESS_MEMORY_SUMMARY drop primary key;

alter table WRH$_PROCESS_MEMORY_SUMMARY add (
  per_pdb    number default null
 ,per_pdb_nn number default 0 not null);

alter table WRH$_PROCESS_MEMORY_SUMMARY
  add constraint WRH$_PROCESS_MEM_SUMMARY_PK
  primary key (dbid, snap_id, instance_number, category, con_dbid, per_pdb_nn)
  using index tablespace SYSAUX;

alter table WRH$_RESOURCE_LIMIT add (per_pdb number default null);

alter table WRH$_SHARED_POOL_ADVICE add (per_pdb number default null);

alter table WRH$_STREAMS_POOL_ADVICE add (per_pdb number default null);

alter table WRH$_SQL_WORKAREA_HISTOGRAM add (per_pdb number default null);

alter table WRH$_PGA_TARGET_ADVICE add (per_pdb number default null);

alter table WRH$_SGA_TARGET_ADVICE add (per_pdb number default null);

alter table WRH$_MEMORY_TARGET_ADVICE add (per_pdb number default null);

alter table WRH$_MEMORY_RESIZE_OPS add (per_pdb number default null);

alter table WRH$_INSTANCE_RECOVERY add (per_pdb number default null);

alter table WRH$_JAVA_POOL_ADVICE add (per_pdb number default null);

alter table WRH$_THREAD add (per_pdb number default null);

alter table WRH$_SYSSTAT add (per_pdb number default null);

alter table WRH$_SYSSTAT_BL add (per_pdb number default null);

alter table WRH$_IM_SEG_STAT add (per_pdb number default null);

alter table WRH$_IM_SEG_STAT_BL add (per_pdb number default null);

alter table WRH$_IM_SEG_STAT_OBJ add (per_pdb number default null);

alter table WRH$_SYS_TIME_MODEL add (per_pdb number default null);

alter table WRH$_SYS_TIME_MODEL_BL add (per_pdb number default null);

alter table WRH$_OSSTAT add (per_pdb number default null);

alter table WRH$_OSSTAT_BL add (per_pdb number default null);

alter table WRH$_PARAMETER add (per_pdb number default null);

alter table WRH$_PARAMETER_BL add (per_pdb number default null);

alter table WRH$_MVPARAMETER add (per_pdb number default null);

alter table WRH$_MVPARAMETER_BL add (per_pdb number default null);

alter table WRH$_STAT_NAME add (per_pdb number default null);

alter table WRH$_OSSTAT_NAME add (per_pdb number default null);

alter table WRH$_PARAMETER_NAME add (per_pdb number default null);

alter table WRH$_PLAN_OPERATION_NAME add (per_pdb number default null);

alter table WRH$_PLAN_OPTION_NAME add (per_pdb number default null);

alter table WRH$_SQLCOMMAND_NAME add (per_pdb number default null);

alter table WRH$_TOPLEVELCALL_NAME add (per_pdb number default null);

alter table WRH$_UNDOSTAT add (per_pdb number default null);

alter table WRH$_SEG_STAT add (per_pdb number default null);

alter table WRH$_SEG_STAT_BL add (per_pdb number default null);

alter table WRH$_SEG_STAT_OBJ add (per_pdb number default null);

alter table WRH$_METRIC_NAME add (per_pdb number default null);

alter table WRH$_SYSMETRIC_HISTORY add (per_pdb number default null);

alter table WRH$_SYSMETRIC_HISTORY_BL add (per_pdb number default null);

alter table WRH$_SYSMETRIC_SUMMARY add (per_pdb number default null);

alter table WRH$_SESSMETRIC_HISTORY add (per_pdb number default null);

alter table WRH$_FILEMETRIC_HISTORY add (per_pdb number default null);

alter table WRH$_WAITCLASSMETRIC_HISTORY add (per_pdb number default null);

alter table WRH$_DLM_MISC add (per_pdb number default null);

alter table WRH$_DLM_MISC_BL add (per_pdb number default null);

alter table WRH$_INST_CACHE_TRANSFER add (per_pdb number default null);

alter table WRH$_INST_CACHE_TRANSFER_BL add (per_pdb number default null);

alter table WRH$_TABLESPACE_STAT add (per_pdb number default null);

alter table WRH$_TABLESPACE_STAT_BL add (per_pdb number default null);

alter table WRH$_LOG add (per_pdb number default null);

alter table WRH$_MTTR_TARGET_ADVICE add (per_pdb number default null);

alter table WRH$_TABLESPACE add (per_pdb number default null);

alter table WRH$_TABLESPACE_SPACE_USAGE add (per_pdb number default null);

alter table WRH$_SERVICE_NAME add (per_pdb number default null);

alter table WRH$_SERVICE_STAT add (per_pdb number default null);

alter table WRH$_SERVICE_STAT_BL add (per_pdb number default null);

alter table WRH$_SERVICE_WAIT_CLASS add (per_pdb number default null);

alter table WRH$_SERVICE_WAIT_CLASS_BL add (per_pdb number default null);

alter table WRH$_SESS_TIME_STATS add (per_pdb number default null);

alter table WRH$_STREAMS_CAPTURE add (per_pdb number default null);

alter table WRH$_STREAMS_APPLY_SUM add (per_pdb number default null);

alter table WRH$_BUFFERED_QUEUES add (per_pdb number default null);

alter table WRH$_BUFFERED_SUBSCRIBERS add (per_pdb number default null);

alter table WRH$_PERSISTENT_QUEUES add (per_pdb number default null);

alter table WRH$_PERSISTENT_SUBSCRIBERS add (per_pdb number default null);

alter table WRH$_RULE_SET add (per_pdb number default null);

alter table WRH$_SESS_SGA_STATS add (per_pdb number default null);

alter table WRH$_REPLICATION_TBL_STATS add (per_pdb number default null);

alter table WRH$_REPLICATION_TXN_STATS add (per_pdb number default null);

alter table WRH$_CELL_CONFIG add (per_pdb number default null);

alter table WRH$_CELL_CONFIG_DETAIL add (per_pdb number default null);

alter table WRH$_ASM_DISKGROUP add (per_pdb number default null);

alter table WRH$_ASM_DISKGROUP_STAT add (per_pdb number default null);

alter table WRH$_ASM_BAD_DISK add (per_pdb number default null);

alter table WRH$_CELL_GLOBAL_SUMMARY add (per_pdb number default null);

alter table WRH$_CELL_GLOBAL_SUMMARY_BL add (per_pdb number default null);

alter table WRH$_CELL_DISK_SUMMARY add (per_pdb number default null);

alter table WRH$_CELL_DISK_SUMMARY_BL add (per_pdb number default null);

alter table WRH$_CELL_METRIC_DESC add (per_pdb number default null);

alter table WRH$_CELL_GLOBAL add (per_pdb number default null);

alter table WRH$_CELL_GLOBAL_BL add (per_pdb number default null);

alter table WRH$_CELL_IOREASON_NAME add (per_pdb number default null);

alter table WRH$_CELL_IOREASON add (per_pdb number default null);

alter table WRH$_CELL_IOREASON_BL add (per_pdb number default null);

alter table WRH$_CELL_DB add (per_pdb number default null);

alter table WRH$_CELL_DB_BL add (per_pdb number default null);

alter table WRH$_CELL_OPEN_ALERTS add (per_pdb number default null);

alter table WRH$_CELL_OPEN_ALERTS_BL add (per_pdb number default null);

alter table WRH$_RSRC_METRIC add (per_pdb number default null);

alter table WRH$_RSRC_PDB_METRIC add (per_pdb number default null);

alter table WRH$_CLUSTER_INTERCON add (per_pdb number default null);

alter table WRH$_IC_DEVICE_STATS add (per_pdb number default null);

alter table WRH$_IC_CLIENT_STATS add (per_pdb number default null);

alter table WRH$_MEM_DYNAMIC_COMP add (per_pdb number default null);

alter table WRH$_INTERCONNECT_PINGS add (per_pdb number default null);

alter table WRH$_INTERCONNECT_PINGS_BL add (per_pdb number default null);

alter table WRH$_DISPATCHER add (per_pdb number default null);

alter table WRH$_SHARED_SERVER_SUMMARY add (per_pdb number default null);

alter table WRH$_DYN_REMASTER_STATS add (per_pdb number default null);

alter table WRH$_LMS_STATS add (per_pdb number default null);

alter table WRH$_PERSISTENT_QMN_CACHE add (per_pdb number default null);

alter table WRM$_DATABASE_INSTANCE add(cdb                   varchar2(3)
                                       ,edition              varchar2(7)
                                       ,db_unique_name       varchar2(30)
                                       ,database_role        varchar2(16)
                                       ,cdb_root_dbid        number);

BEGIN
  EXECUTE IMMEDIATE 'alter table wrm$_wr_control 
                     drop constraint WRM$_WR_CONTROL_NAME_UK';
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -2443) THEN
      NULL;
    ELSE
      RAISE;
    END IF;  
END;
/

Rem ****************************************************************
Rem * Set "flush_type" flag to 1 for existing non-local DBIDs
Rem ****************************************************************
BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    '   SET flush_type = 1 '  ||
                    ' WHERE dbid != (SELECT dbid FROM v$database)';
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
Rem Increment AWR version for 12.2.0.1
Rem *************************************************************************
Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (12cR201   = SWRF Version 20)            ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem ==  For the current AWR version definition refer to  ==
Rem ==  kewr.h:KEWR_CURRENT_VERSION.                     ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 20 ';
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

Rem *************************************************************************
Rem Bug 19067295: AWR SNAPSHOT CANNOT FLUSH WRH$_SGASTAT
Rem *************************************************************************

alter table WRH$_SGASTAT modify (pool varchar2(30));

Rem *************************************************************************
Rem for RAC AWR report improvement
Rem *************************************************************************
alter table WRH$_CR_BLOCK_SERVER add (builds number);
alter table WRH$_CR_BLOCK_SERVER add (per_pdb number default null);

alter table WRH$_CURRENT_BLOCK_SERVER add(pin0 number, flush0 number);
alter table WRH$_CURRENT_BLOCK_SERVER add(per_pdb number default null);

Rem ========================================================================
Rem END AWR Changes
Rem =========================================================================

Rem*************************************************************************
Rem BEGIN Changes for mlog$ on 12.2
Rem*************************************************************************

-- update the old_max_scn value to the new_max_scn value for commit-scn logs
declare
 cursor c1 is 
   select * from sys.mlog$ where bitand(flag, 65536) = 65536 for update;
   old_max_scn  number := 281474976710655;       /* 0xffffffffffff     */
   new_max_scn  number := 18446744073709551615;  /* 0xffffffffffffffff */
begin
 for rec in c1
 loop
   if rec.oscn = old_max_scn then
     update sys.mlog$ set oscn = new_max_scn where current of c1; 
   end if;

   if rec.oscn_pk = old_max_scn then
     update sys.mlog$ set oscn_pk = new_max_scn where current of c1; 
   end if;

   if rec.oscn_seq = old_max_scn then
     update sys.mlog$ set oscn_seq = new_max_scn where current of c1; 
   end if;

   if rec.oscn_oid = old_max_scn then
     update sys.mlog$ set oscn_oid = new_max_scn where current of c1; 
   end if;

   if rec.oscn_new = old_max_scn then
     update sys.mlog$ set oscn_new = new_max_scn where current of c1; 
   end if;

 end loop;
end;
/

Rem*************************************************************************
Rem END Changes for mlog$ on 12.2
Rem*************************************************************************


Rem *************************************************************************
Rem  FBA Long identifers for 12.1.0.2
Rem *************************************************************************
Rem =======================================================
Rem ==  Bug 7971239: Increase size of columns for        ==
Rem ==  long identifiers in FBA dictionary tables        ==
Rem =======================================================

alter table SYS_FBA_FA modify (ownername varchar2(255));
alter table SYS_FBA_TRACKEDTABLES modify
          (objname varchar2(255), ownername varchar2(255));
alter table SYS_FBA_CONTEXT modify
          (namespace varchar2(255), parameter varchar2(255));
alter table SYS_FBA_CONTEXT_LIST modify
          (namespace varchar2(255), parameter varchar2(255));

Rem *************************************************************************
Rem End FBA dictionary support for long identifers
Rem *************************************************************************

Rem ========================================================================
Rem END FBA Changes
Rem =========================================================================

Rem ========================================================================
Rem BEGIN scheduler Changes
Rem =========================================================================
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dbms_job FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

drop index sys.i_scheduler_notification1;
drop index sys.i_scheduler_notification2;
commit;

-- Add the notification_owner column to scheduler$_notification
alter table sys.scheduler$_notification add
  ( notification_owner VARCHAR2(128));
commit;

-- Use the job owner as default notification owner
begin
  execute immediate 
  'begin 
      update sys.scheduler$_notification
        set notification_owner = owner
        where notification_owner is null; 
    end;';
  commit;
exception
  when others then
    if ( SQLCODE != -06550 ) then
      raise;
    end if;
end;
/

alter table sys.scheduler$_notification modify
  ( notification_owner VARCHAR2(128) not null);
commit;
Rem ========================================================================
Rem END scheduler Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN Privilege Analysis Changes
Rem =========================================================================

-- Bug 25337332: Correct signature issues with drop column
-- GRANT_PATH type is changed in 12.2 to be a VARRAY instead of NESTED TABLE
-- Drop tables and type; they will be recreated when catproc.sql is run.

DROP table sys.priv_used_path$;
DROP table sys.priv_unused_path$;
DROP type sys.grant_path;

alter table sys.capture_run_log$ add run_name varchar2(128);
alter table sys.captured_priv$ add app_roles sys.role_array;

create type sys.package_array as varray(1024) of number;
/
create or replace public synonym package_array for sys.package_array;
grant execute on package_array to PUBLIC;
alter table sys.captured_priv$ add cbac_plist sys.package_array;

alter table sys.priv_unused$ add run_seq# number;


Rem BUG 21963542
drop public synonym g_database;
drop public synonym g_role;
drop public synonym g_context;
drop public synonym g_role_and_context;

Rem =========================================================================
Rem END Privilege Analysis Changes
Rem =========================================================================

Rem =========================================================================
Rem BEGIN changes specific to proj 47829 - insert READ ANY TABLE sys priv
Rem =========================================================================
BEGIN
  INSERT INTO SYSTEM_PRIVILEGE_MAP(PRIVILEGE,NAME,PROPERTY)
  VALUES (-397, 'READ ANY TABLE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

-- auditing support
BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP(OPTION#,NAME,PROPERTY)
  VALUES (397, 'READ ANY TABLE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
Rem =========================================================================
Rem END changes specific to proj 47829
Rem =========================================================================

Rem =========================================================================
Rem BEGIN DATAPUMP Changes for 12.2
Rem Project 48787: views to document mdapi transforms
Rem =========================================================================
create table metaxslparamdesc$   /* doc for mdAPI's XSL and parse parameters */
sharing=object 
(
  model        varchar2(128) not null,                         /* model name */
  param        varchar2(128) not null,             /* documented param. name */
  flags        number default 0 not null,
  /* 0x001 = internal  */
  /* 0x002 = parse item for ALTER_XML  */
  /* 0x004 = parse item returned by FETCH_XML_CLOB  */
  /* 0x008 = parse item returned by CONVERT and FETCH_DDL  */
  description  varchar2(4000))
/
create unique index i_metaxslparamdesc$ on metaxslparamdesc$(model, param)
/

Rem Bug 20722522 : Drop unique index i_dependobj and recreate normal index
Rem =========================================================================
drop index i_dependobj;
create index i_dependobj on expdepobj$(d_obj#)
/

Rem =========================================================================
Rem BEGIN DATAPUMP Changes for 12.1
Rem Add columns for versioned callout registration support
Rem =========================================================================
alter table sys.impcalloutreg$ add
        beginning_tgt_version varchar2(14)  default null
/
alter table sys.impcalloutreg$ add
        ending_tgt_version    varchar2(14)  default null
/
alter table sys.impcalloutreg$ add
        alt_name              varchar2(128) default null
/
alter table sys.impcalloutreg$ add
        alt_schema            varchar2(128) default null
/

Rem DATAPUMP_DIR_OBJS view has been replaced with LOADER_DIR_OBJS view
drop public synonym DATAPUMP_DIR_OBJS;
drop view SYS.DATAPUMP_DIR_OBJS;
Rem in 11.2.0.4 SYS.KU$_VIEW_STATUS_VIEW replaced by SYS.KU$_OBJECT_STATUS_VIEW
drop view SYS.KU$_VIEW_STATUS_VIEW;

Rem =========================================================================
Rem END DATAPUMP Changes
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN Bug 17459511 Mark pwd_verifier column of default_pwd$ as sensitive
Rem *************************************************************************

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208) where name = 'PWD_VERIFIER' and obj# = (select obj# from obj$ where name = 'DEFAULT_PWD$' and owner# = (select user# from user$ where name = 'SYS') and remoteowner is NULL)
/
commit;

Rem *************************************************************************
Rem END Bug 17459511 Mark pwd_verifier column of default_pwd$ as sensitive
Rem *************************************************************************

Rem ===========================================================================
Rem BEGIN Proj 47091 changes:
Rem Add dictionary tables for attribute dimension, hierarchy, and analytic view
Rem ===========================================================================

REM BEGIN - dictionary tables for attribute dimension

create table hcs_dim$                                     /* dimension table */
( obj#             number not null,                         /* object number */
--  is_distinct      number(1) not null,      /* 1 for indicating performing 
--                                          DISTINCT operation on the source 
--                                                         data, 0 otherwise */
--  constraints_mode number not null,               /* 0=ENFORCED, 1=TRUSTED */
--  level_attr#      number,         /* attr# of LEVELS DETERMINED BY clause */
  dim_type           number(1) not null,   /* 1 for STANDARD dim, 2 for TIME */
  all_member_name    clob not null,                       /* All Member Name */
  all_member_caption clob,                             /* All Member Caption */
  all_member_desc    clob,                         /* All Member Description */
  audit$             varchar2(38) not null,              /* auditing options */
  spare1             number,
  spare2             number,
  spare3             varchar2(1000),
  spare4             date
)
/

create unique index i_hcs_dim$_1 on hcs_dim$(obj#)
/

create table hcs_dim_attr$                      /* dimension attribute table */
( dim#            number not null,                         /* dimension obj# */
  attr#           number not null,  /* attribute number within the dimension */
  attr_name       varchar2(128),                           /* attribute name */
  src_col#        number not null,  /* id of src col object the attr is from */
  data_type#      number not null,                 /* datatype of the column */
  data_length     number not null,        /* length of the column (in bytes) */
  charsetform     number,                                    /* charset form */
  charsetid       number,                                      /* charset id */
  precision#      number,                         /* precision of the column */
  scale           number,            /* digits right of decimal pt in number */
  is_null         number not null,                     /* can column be null */
  property        number not null,                                  /* flags */
  order_num       number not null,       /* order num of the attr in the dim */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_attr$_1 on hcs_dim_attr$(dim#, attr#)
/

create table hcs_dim_lvl_key$                   /* dimension level key table */
( dim#            number not null,                         /* dimension obj# */
  lvl#            number not null,     /* level number within this dimension */
  lvl_key#        number not null,        /* lvl key number within the level */
  order_num       number not null,    /* order num of the lvl key in the lvl */
  is_pc           number(1) not null,         /* is this a parent-child key? */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_lvl_key$_1 
  on hcs_dim_lvl_key$(dim#, lvl#, is_pc, lvl_key#)
/

/* map for attr to the lvl key it belongs to */
create table hcs_dim_lvl_key_attr$ 
( dim#            number not null,                         /* dimension obj# */
  lvl#            number not null,     /* level number within this dimension */
  lvl_key#        number not null,        /* lvl key number within the level */
  attr#           number not null,          /* number of attr in the lvl key */
  order_num       number not null,   /* order num of the attr in the lvl key */
  is_pc           number(1) not null,         /* is this a parent-child key? */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_lvl_key_attr$_1
  on hcs_dim_lvl_key_attr$(dim#, lvl#, lvl_key#, is_pc, attr#)
/

create table hcs_dim_dtm_attr$            /* determined attrs of each level */
( dim#            number not null,                         /* dimension obj# */
  attr#           number not null,                         /* id of the attr */
  lvl#            number not null, /* id of the lvl that determines the attr */
  in_minimal      number(1) not null,                /* attr in minimal set? */
  order_num       number not null,   /* order number of the attr in the list */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_dtm_attr$_1 
      on hcs_dim_dtm_attr$(dim#, lvl#, attr#)
/

create unique index i_hcs_dim_dtm_attr$_2 
      on hcs_dim_dtm_attr$(dim#, lvl#, order_num)
/

create table hcs_dim_lvl$
( dim#            number not null,                         /* dimension obj# */
  lvl#            number not null,     /* level number within this dimension */
  lvl_name        varchar2(128),                               /* level name */
  member_name     clob not null,                              /* member Name */
  member_caption  clob,                                    /* member Caption */
  member_desc     clob,                                /* member Description */
  skip_when_null  number(1), /* indicator if lvl is NOT NULL, SKIP WHEN NULL */
  lvl_type        number not null,                             /* level type */        
  order_num       number not null,   /* order number of the level in the dim */
  is_pc           number(1) not null,           /* is this for parent-child? */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_lvl$_1 on hcs_dim_lvl$(dim#, lvl#, is_pc)
/

create table hcs_lvl_ord$                               /* lvl order by list */
( dim#            number not null,                         /* dimension obj# */
  ord#            number not null,          /* id of the order by in the dim */
  dim_lvl#        number not null,                  /* dim lvl# of the level */
  attr#           number,                           /* attr# of the order by */
  is_asc          number(1),                     /* 1 for asc, and 0 for dsc */
  null_first      number(1),        /* 1 for null first, and 0 for null last */
  aggr_func       number(1),                  /* 0 unspecified, 1 MIN, 2 MAX */
  order_num       number not null,  /* order num of atr in the order by list */
  is_pc           number(1) not null,           /* is this for parent-child? */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_lvl_ord$_1 
   on hcs_lvl_ord$(dim#, dim_lvl#, is_pc, ord#)
/

create unique index i_hcs_lvl_ord$_2 
   on hcs_lvl_ord$(dim#, dim_lvl#, is_pc, attr#)
/

create unique index i_hcs_lvl_ord$_3
   on hcs_lvl_ord$(dim#, dim_lvl#, is_pc, order_num)
/

REM END - dictionary tables for attribute dimension

REM BEGIN - dictionary tables for HCS hierarchy 

create table hcs_hierarchy$
( obj#            number not null,                          /* object number */
  dim_owner       varchar2(128) not null,           /* owner of the base dim */
  owner_in_ddl    number(1) not null,        /* whether dim_owner was in DDL */
  dim_name        varchar2(128) not null,            /* name of the base dim */
  audit$          varchar2(38) not null,                 /* auditing options */
  par_attr_name   varchar2(128),                    /* parent attribute name */
  max_depth       number,                      /* max depth for parent-child */
  validate_state  number not null,                         /* validate state */ 
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)  
/

create unique index i_hcs_hierarchy$_1 on hcs_hierarchy$(obj#)
/

create table hcs_hr_lvl$
( hier#           number not null,                         /* hierarchy obj# */
  lvl_name        varchar2(128) not null,               /* name of the level */
  order_num       number not null,  /* order of the hier lvl in the sequence */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_hr_lvl$_1 on hcs_hr_lvl$(hier#, lvl_name)
/

create table hcs_hr_lvl_id$
( hier#           number not null,                         /* hierarchy obj# */
  lvl_name        varchar2(128) not null,               /* name of the level */
  attr_name       varchar2(128) not null,           /* name of the attribute */
  order_num       number not null,      /* order of the attr in the sequence */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_hr_lvl_id$_1 on
  hcs_hr_lvl_id$(hier#, lvl_name, attr_name)
/
create unique index i_hcs_hr_lvl_id$_2 on
  hcs_hr_lvl_id$(hier#, lvl_name, order_num)
/

create table hcs_hier_attr$                  /* hierarchical attribute table */
( hier#           number not null,                         /* hierarchy obj# */
  attr#           number not null,  /* attribute number within the hierarchy */
  attr_name       varchar2(128),                           /* attribute name */
  expr            clob,                                   /* expression text */
  data_type#      number not null,                 /* datatype of the column */
  data_length     number not null,        /* length of the column (in bytes) */
  charsetform     number,                                    /* charset form */
  charsetid       number,                                      /* charset id */
  precision#      number,                         /* precision of the column */
  scale           number,            /* digits right of decimal pt in number */
  is_null         number not null,                     /* can column be null */
  property        number not null,                                  /* flags */
  is_sys_expr     number(1) not null,        /* system-generated expression? */
  order_num       number not null,       /* order num of the attr in the dim */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_hier_attr$_1 on hcs_hier_attr$(hier#, attr#)
/

create table hcs_hier_col$                              /* hierarchy columns */
( hier#            number not null,                 /* obj# of the hierarchy */
  col_name         varchar2(128) not null,                 /* attribute name */
  role             number not null,                    /* role of the column */
  order_num        number not null,    /* order number of the column in hier */
  data_type#       number not null,                /* datatype of the column */
  data_length      number not null,       /* length of the column (in bytes) */
  charsetform      number,                                   /* charset form */
  charsetid        number,                                     /* charset id */
  precision#       number,                        /* precision of the column */
  scale            number,           /* digits right of decimal pt in number */
  is_null          number not null,                    /* can column be null */
  property         number not null,                                 /* flags */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_hier_col$_1 on hcs_hier_col$(hier#, col_name)
/

create unique index i_hcs_hier_col$_2 on hcs_hier_col$(hier#, order_num)
/

REM END - dictionary tables for HCS hierarchy 


REM BEGIN - dictionary tables for HCS analytic view 

create table hcs_analytic_view$                             /* analytic view */
( obj#             number not null,                         /* object number */
  default_measure# number not null,                    /* default measure id */
  audit$           varchar2(38) not null,                /* auditing options */
  default_aggr     varchar2(128) not null,  /* default aggr by function name */
  validate_state   number not null,                        /* validate state */ 
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_analytic_view$_1 on hcs_analytic_view$(obj#)
/

create table hcs_av_key$                      /* analytic view dimension key */
( av#              number not null,             /* obj# of the analytic view */
  av_dim#          number not null,    /* id of the owning analytic view dim */
  key#             number not null,                  /* analytic view key id 
                                                    (av_dim# of hcs_av_dim$) */
  src_col#         number not null,               /* id of the source column */
  ref_attr_name    varchar2(128),      /* name of the ref dim attr if exists */
  order_num        number not null, /* order num of the key atrs in a av_dim */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_av_key$_1 on 
  hcs_av_key$(av#, av_dim#, key#)
/

create table hcs_av_dim$                          /* analytic view dimension */
( av#                number not null,           /* obj# of the analytic view */
  av_dim#            number not null,         /* id of the analytic view dim */
  dim_owner          varchar2(128) not null,             /* owner of the dim */
  owner_in_ddl       number(1) not null,     /* whether dim_owner was in DDL */
  dim_name           varchar2(128) not null,              /* name of the dim */
  alias              varchar2(128),      /* alias of analytic view dimension */
  dim_type           number(1),            /* 1 for STANDARD dim, 2 for TIME */
  all_member_name    clob,                                /* All Member Name */
  all_member_caption clob,                             /* All Member Caption */
  all_member_desc    clob,                         /* All Member Description */
  order_num          number not null,   /* order number of analytic view dim */
  spare1             number,
  spare2             number,
  spare3             varchar2(1000),
  spare4             date
)
/

create unique index i_hcs_av_dim$_1 on hcs_av_dim$(av#, av_dim#)
/

create table hcs_av_meas$                           /* analytic view measure */
( av#              number not null,             /* obj# of the analytic view */
  meas#            number not null,/* id of the measure in the analytic view */
  meas_name        varchar2(128),                            /* measure name */
  meas_type        number,                                   /* measure type */
  src_col#         number,  /* id of src col object the base measure is from */
  aggr             varchar2(128),              /* aggregate by function name */
  expr             clob,                          /* measure expression text */
  order_num        number not null,           /* order number of the measure */
  data_type#       number not null,                /* datatype of the column */
  data_length      number not null,       /* length of the column (in bytes) */
  charsetform      number,                                   /* charset form */
  charsetid        number,                                     /* charset id */
  precision#       number,                        /* precision of the column */
  scale            number,           /* digits right of decimal pt in number */
  is_null          number not null,                    /* can column be null */
  property         number not null,                                 /* flags */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_av_meas$_1 on hcs_av_meas$(av#, meas#)
/

create table hcs_av_hier$                         /* analytic view hierarchy */
( av#              number not null,             /* obj# of the analytic view */
  av_dim#          number not null,           /* id of the analytic view dim */
  hier#            number not null,    /* id of analytic view hier in the av */
  hier_owner       varchar2(128) not null,                /* hierarchy owner */
  owner_in_ddl     number(1) not null,      /* whether hier_owner was in DDL */
  hier_name        varchar2(128) not null,                 /* hierarchy name */
  hier_alias       varchar2(128),                         /* hierarchy alias */
  is_default       number(1),              /* indicator if it's default hier */
  order_num        number not null,         /* order number of the hierarchy */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_av_hier$_1 on hcs_av_hier$(av#, av_dim#, hier#)
/

create table hcs_av_col$                            /* analytic view columns */
( av#              number not null,             /* obj# of the analytic view */
  av_dim#          number,      /* analytic view dim id, NULL if for measure */
  av_hier#         number,          /* analytic view id, NULL if for measure */
  sub_obj#         number not null,                 /* either attr# or meas# */
  sub_obj_type     number not null,                           /* object type */
  col_name         varchar2(128) not null,           /* attr or measure name */
  role             number not null,                    /* role of the column */
  order_num        number not null,  /* order num of column in analytic view */
  data_type#       number not null,                /* datatype of the column */
  data_length      number not null,       /* length of the column (in bytes) */
  charsetform      number,                                   /* charset form */
  charsetid        number,                                     /* charset id */
  precision#       number,                        /* precision of the column */
  scale            number,           /* digits right of decimal pt in number */
  is_null          number not null,                    /* can column be null */
  property         number not null,                                 /* flags */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           date
)
/

create unique index i_hcs_av_col$_1 
   on hcs_av_col$(av#, av_dim#, av_hier#, col_name)
/

create unique index i_hcs_av_col$_2 on hcs_av_col$(av#, order_num)
/

create unique index i_hcs_av_col$_3 
   on hcs_av_col$(av#, av_dim#, av_hier#, sub_obj#, sub_obj_type)
/

create table hcs_av_lvl$                             /* analytic view levels */
( av#            number not null,               /* obj# of the analytic view */
  av_dim#        number not null,                    /* analytic view dim id */
  av_hier#       number not null,              /* analytic view hierarchy id */
  lvl#           number not null,                         /* id of the level */
  lvl_name       varchar2(128) not null,                       /* level name */
  order_num      number not null,  /*order number of column in analytic view */
  spare1         number,
  spare2         number,
  spare3         varchar2(1000),
  spare4         date
)
/

create unique index i_hcs_av_lvl$_1 
   on hcs_av_lvl$(av#, av_dim#, av_hier#, lvl#)
/

create unique index i_hcs_av_lvl$_2 
   on hcs_av_lvl$(av#, av_dim#, av_hier#, order_num)
/

create table hcs_av_lvlgrp$                 /* analytic view level groupings */
( av#              number not null,             /* obj# of the analytic view */
  lvlgrp#          number not null,              /* id of the level grouping */
  measlst#         number not null,     /* id of the measure list for lvlgrp */
  mv_name          varchar2(128),                  /* opt mv name for lvlgrp */
  cache_type       varchar2(128) not null,           /* materialization type */
  order_num        number not null,   /* order num of group in analytic view */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           varchar2(1000),
  spare5           date
)
/

create unique index i_hcs_av_lvlgrp_1 
   on hcs_av_lvlgrp$(av#, lvlgrp#)
/

create unique index i_hcs_av_lvlgrp_2
   on hcs_av_lvlgrp$(av#, order_num)
/


create table hcs_lvlgrp_lvls$                          /* level group levels */
( av#              number not null,             /* obj# of the analytic view */
  lvlgrp#          number not null,              /* id of the level grouping */
  dim_alias        varchar2(128),           /* hier dim alias for this level */
  hier_alias       varchar2(128),          /* hierarchy alias for this level */
  level_name       varchar2(128) not null,      /* level name for this level */
  order_num        number not null,  /* order number of the lvl in the group */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           varchar2(1000),
  spare5           date
)
/

create unique index i_hcs_lvlgrp_lvls_1 
   on hcs_lvlgrp_lvls$(av#, lvlgrp#, dim_alias, hier_alias, level_name)
/

create unique index i_hcs_lvlgrp_lvls_2 
   on hcs_lvlgrp_lvls$(av#, lvlgrp#, order_num)
/

create table hcs_measlst_measures$                  /* measure list measures */
( av#              number not null,             /* obj# of the analytic view */
  measlst#         number not null,                /* id of the measure list */
  meas_name        varchar2(128) not null,                  /* measure name  */
  order_num        number not null, /* order number of the meas in the group */
  spare1           number,
  spare2           number,
  spare3           varchar2(1000),
  spare4           varchar2(1000),
  spare5           date
)
/

create unique index i_hcs_measlst_measures_1 
   on hcs_measlst_measures$(av#, measlst#, meas_name)
/

create unique index i_hcs_measlst_measures_2 
   on hcs_measlst_measures$(av#, measlst#, order_num)
/

REM END - dictionary tables for HCS analytic view 

REM BEGIN - dictionary table for classifications

create table hcs_clsfctn$
( obj#            number not null,   /* top lvl object id containing clsfctn */
  sub_obj#        number,    /* optional subobject id containing the clsfctn */
  obj_type        number not null,     /* object type containing the clsfctn */
  clsfction_name  varchar2(128),                      /* classification name */
  clsfction_lang  varchar2(64),          /* optional classification language */
  clsfction_value clob,                     /* optional classification value */
  order_num       number not null,     /* order number of the classification */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_clsfctn$_1 on hcs_clsfctn$(obj#, sub_obj#, 
      obj_type, clsfction_name, clsfction_lang)
/

create table hcs_av_clsfctn$                /* analytic view classifications */
( av#             number not null,  /* analytic view obj id containing cbDim */
  av_dim#         number not null, /* analytic view dim id containing avHier */
  av_hier#        number not null,   /* analytic view hier id containing lvl */
  sub_obj#        number, /* lvlId or null if cbHier, containing the clsfctn */
  obj_type        number not null,     /* subobj type containing the clsfctn */
  clsfction_name  varchar2(128),                      /* classification name */
  clsfction_lang  varchar2(64),          /* optional classification language */
  clsfction_value clob,                     /* optional classification value */
  order_num       number not null,     /* order number of the classification */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_av_clsfctn$_1 
   on hcs_av_clsfctn$(av#, av_dim#, av_hier#, sub_obj#, 
                      obj_type, clsfction_name, clsfction_lang)
/

REM END - dictionary tables for classifications

REM BEGIN - dictionary table for sources

create table hcs_src$      /* source object of an analytic view or dimension */
( hcs_obj#        number not null,    /* obj# of hcs obj based on the source */
  src#            number not null,                       /* id of the source */
  owner           varchar2(128) not null,             /* owner of the source */
  owner_in_ddl    number(1) not null,            /* whether owner was in DDL */
  name            varchar2(128) not null,              /* name of the source */
  alias           varchar2(128),                      /* alias of the source */
  order_num       number not null,             /* order number of the source */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_src$_1 on hcs_src$(hcs_obj#, src#)
/

create table hcs_src_col$(
  obj#           number not null, /* top lvl object id containing the srcCol */
  src_col#       number not null,                 /* id of the source column */
  obj_type       number not null,       /* object type containing the srcCol */
  table_alias    varchar2(128),                       /* owner of the column */
  src_col_name   varchar2(128) not null,               /* name of the column */
  spare1         number,
  spare2         number,
  spare3         varchar2(1000),
  spare4         date)
/

create unique index i_hcs_src_col$_1 on hcs_src_col$(obj#, src_col#,
         obj_type, src_col_name)
/

REM END - dictionary tables for sources

REM BEGIN - dictionary table for join paths and conditions

create table hcs_dim_join_path$       /* join path of an attribute dimension */
( dim#            number not null,                         /* dimension obj# */
  joinpath#       number not null,                    /* id of the join path */
  join_path_name  varchar2(128) not null,           /* name of the join path */
  order_num       number not null,          /* order number of the join path */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_dim_join_path_1 
          on hcs_dim_join_path$(dim#, joinpath#)
/

create unique index i_hcs_dim_join_path_2
          on hcs_dim_join_path$(dim#, join_path_name)
/

create unique index i_hcs_dim_join_path_3
          on hcs_dim_join_path$(dim#, order_num)
/

create table hcs_join_cond_elem$(
  dim#           number not null, /* dim# containing the join condition elem */
  joinpath#      number not null,                     /* id of the join path */
  lhs_src_col#   number not null,               /* left hand side src col id */
  rhs_src_col#   number not null,              /* right hand side src col id */
  order_num      number not null,      /* order number of the join cond elem */
  spare1         number,
  spare2         number,
  spare3         varchar2(1000),
  spare4         date)
/

create unique index i_hcs_join_cond_elem$_1 
          on hcs_join_cond_elem$(dim#, joinpath#, order_num)
/

create table hcs_hier_join_path$                /* join paths of a hierarchy */
( hier#           number not null,                         /* hierarchy obj# */
  join_path_name  varchar2(128) not null,           /* name of the join path */
  order_num       number not null,          /* order number of the join path */
  spare1          number,
  spare2          number,
  spare3          varchar2(1000),
  spare4          date
)
/

create unique index i_hcs_hier_join_path_1
          on hcs_hier_join_path$(hier#, join_path_name)
/

create unique index i_hcs_hier_join_path_2
          on hcs_hier_join_path$(hier#, order_num)
/

REM END - dictionary tables for join paths and conditions


REM BEGIN - system privileges and audit options for HCS objects

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-399, 'CREATE ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-400, 'CREATE ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-401, 'ALTER ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-402, 'DROP ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-403, 'CREATE HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-404, 'CREATE ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-405, 'ALTER ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-406, 'DROP ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-407, 'CREATE ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-408, 'CREATE ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-409, 'ALTER ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-410, 'DROP ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (359, 'ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (399, 'CREATE ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (400, 'CREATE ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (401, 'ALTER ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (402, 'DROP ANY ATTRIBUTE DIMENSION', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (360, 'HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (403, 'CREATE HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (404, 'CREATE ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (405, 'ALTER ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (406, 'DROP ANY HIERARCHY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (361, 'ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (407, 'CREATE ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (408, 'CREATE ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (409, 'ALTER ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (410, 'DROP ANY ANALYTIC VIEW', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

commit;
REM END - system privileges for HCS objects

Rem ===========================================================================
Rem END Proj 47091 changes
Rem ===========================================================================

Rem =======================================================================
Rem  Begin changes for AQ SYS.*_PARTITION_MAP tables & *_pmap* types.
Rem =======================================================================

Rem 12.1.0.1 to 12.1.0.2 additions
alter table sys.aq$_queue_partition_map add (unbound_idx   NUMBER default -1);
alter table sys.aq$_dequeue_log_partition_map add (subshard   NUMBER default -1);
alter table sys.aq$_dequeue_log_partition_map add (unbound_idx   NUMBER default -1);

Rem 12.1.0.2 to 12.2.0.1 additions
alter table sys.aq$_queue_partition_map add (part_properties   NUMBER default 0);
alter table sys.aq$_queue_partition_map add (bucket_timestamp  TIMESTAMP WITH TIME ZONE default null);
alter table sys.aq$_queue_partition_map add (bucket_width      NUMBER );
alter table sys.aq$_queue_partition_map add (bucket_id         NUMBER );
alter table sys.aq$_queue_partition_map add (min_delv_time     TIMESTAMP WITH TIME ZONE default null);
alter table sys.aq$_queue_partition_map add (min_delv_time_sn  NUMBER );
alter table sys.aq$_queue_partition_map add (min_delv_time_scn NUMBER );
alter table sys.aq$_queue_partition_map add (spare1 NUMBER );
alter table sys.aq$_queue_partition_map add (spare2 NUMBER );

alter table sys.aq$_dequeue_log_partition_map rename column flag TO rowmarker;
alter table sys.aq$_dequeue_log_partition_map add (part_properties NUMBER default 0);
alter table sys.aq$_dequeue_log_partition_map add (min_sub_delv_time TIMESTAMP WITH TIME ZONE default null);
alter table sys.aq$_dequeue_log_partition_map add (min_sub_delv_time_sn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map add (min_delv_time_enq_scn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map add (min_sub_delv_time_deq_scn NUMBER default null);
alter table sys.aq$_dequeue_log_partition_map add (spare1 NUMBER );
alter table sys.aq$_dequeue_log_partition_map add (spare2 NUMBER );

alter table system.aq$_queues add(base_queue  NUMBER DEFAULT 0);
alter table SYS.AQ$_QUEUE_SHARDS add(base_queue  NUMBER DEFAULT 0);
alter table SYS.AQ$_QUEUE_SHARDS add(delay_shard  NUMBER DEFAULT NULL);

DROP TYPE sys.sh$qtab_pmap_list;
DROP TYPE BODY sys.sh$qtab_pmap;
DROP TYPE sys.sh$qtab_pmap;
DROP TYPE sys.sh$deq_pmap_list;
DROP TYPE BODY sys.sh$deq_pmap;
DROP TYPE sys.sh$deq_pmap;

Rem =======================================================================
Rem  End changes for AQ *_PARTITION_MAP tables  & *_pmap* types.
Rem =======================================================================

Rem ====================================================================
Rem BEGIN changes for child subscribers
Rem ====================================================================

alter table SYS.AQ$_DURABLE_SUBS add (parent_id NUMBER default NULL);

Rem =======================================================================
Rem  End changes for child subscribers
Rem =======================================================================

Rem =======================================================================
Rem BEGIN Changes for rule_set on 12.0
Rem =======================================================================
 
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
 
Rem ======================================================================= 
Rem END Changes for rule_set
Rem =======================================================================
Rem revoke public grant on sys.aq$_unflushed_dequeues
revoke select on sys.aq$_unflushed_dequeues from public;

Rem ====================================================================
Rem BEGIN changes for AQ long identifier support
Rem ====================================================================

alter table sys.reg$ modify (subscription_name varchar2(776));
alter table sys.aq$_subscriber_table modify (name VARCHAR2(512));
alter table SYSTEM.AQ$_Internet_Agents modify (agent_name VARCHAR2(512));
alter table SYSTEM.AQ$_Internet_Agent_Privs modify (agent_name VARCHAR2(512));
alter table SYS.AQ$_QUEUE_PARTITION_MAP modify(partname VARCHAR2(128));
alter table SYS.AQ$_DEQUEUE_LOG_PARTITION_MAP modify(partname VARCHAR2(128));
alter table SYS.AQ$_DURABLE_SUBS modify(schema VARCHAR2(128), 
                                        queue_name VARCHAR2(128),
                                        rule_name VARCHAR2(128),
                                        trans_owner VARCHAR2(128),
                                        trans_name VARCHAR2(128));
alter table sys.rec_var$ modify(var_mthd_func varchar2(515));
alter table system.aq$_schedules modify(destination varchar2(390));
alter table sys.aq$_schedules modify(destination varchar2(390));
alter table sys.aq$_schedules drop primary key;
alter table sys.aq$_schedules add constraint aq$_schedules_primary
        primary key (oid, destination, job_name);

Rem =======================================================================
Rem  End changes for AQ long identifier support
Rem =======================================================================
Rem =======================================================================
Rem drop SCHEDULER$_EVENT_QTAB_HIST index
Rem =======================================================================

drop index scheduler$_event_qtab_hist;

Rem ====================================================================
Rem BEGIN changes for PDB_ALERT$
Rem ====================================================================
CREATE INDEX i_pdb_alert2 ON pdb_alert$(name, cause#)
/
alter table pdb_alert$ add (cause varchar(64));
update pdb_alert$ set cause=decode(cause#, 
  36, 'Database CHARACTER SET', 37, 'NATIONAL CHARACTER SET', 
  39, 'OPTION',  40, 'OLS Configuration', 41, 'Database Vault', 
  42, 'Non-CDB to PDB', 43, 'Sync Failure', 43, 'APEX', 45, 'APEX', 
  46, 'APEX', 48, 'Parameter', 50, 'SQL Patch', 51, 'Offline Tablespace',
  52, 'No CDB spfile', 54, 'Time Zone Version', 55, 'Wallet Key Needed', 
  57, 'Service Name Conflict', 59, 'Oracle Opatch',
  60, 'PDB version not allowed', 63, 'AWR load profile', 65, 'VSN not match', 
  'UNDEFINED');

alter table pdb_alert$ modify (name varchar2(128));

Rem ====================================================================
Rem End changes for PDB_ALERT$
Rem ===================================================================

Rem ====================================================================
Rem BEGIN changes for PDB_INV_TYPE$
Rem ====================================================================
create table pdb_inv_type$
(
  owner     varchar2(128),                                /* type owner */
  type_name varchar2(128)                                  /* type name */
)
/
Rem ====================================================================
Rem End changes for PDB_INV_TYPE$
Rem ===================================================================

Rem *************************************************************************
Rem Revisit indexes for SQL Plan Directive dictionary tables for 12.1.0.2
Rem #(16576884)
Rem *************************************************************************

drop index sys.i_opt_directive_last_used;

drop index sys.i_opt_directive_own#_id;

create unique index sys.i_opt_directive_dirid on
  opt_directive$(dir_id)
  tablespace sysaux
/

create index sys.i_opt_directive_dirown# on
  opt_directive$(dir_own#)
  tablespace sysaux
/


Rem =======================================================================
Rem  Changes for Database Workload Capture and Replay
@@c1201000_wrr.sql
Rem =======================================================================

Rem *************************************************************************
Rem End Revisit indexes for SQL Plan Directive dictionary tables for 12.1.0.2
Rem *************************************************************************

Rem =======================================================================
Rem Begin Changes for WRH$_ACTIVE_SESSION_HISTORY
Rem - Add columns to ASH
Rem =======================================================================
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_full_plan_hash_value NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_adaptive_plan_resolved NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (usecs_per_row  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sample_time_utc TIMESTAMP(3));
alter table WRH$_ACTIVE_SESSION_HISTORY add (per_pdb number default null);

alter table WRH$_ACTIVE_SESSION_HISTORY_BL
           add (sql_full_plan_hash_value NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL 
           add (sql_adaptive_plan_resolved NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL 
           add (usecs_per_row  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL 
           add (sample_time_utc TIMESTAMP(3));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL
           add (per_pdb number default null);

Rem =======================================================================
Rem End Changes for WRH$_ACTIVE_SESSION_HISTORY
Rem =======================================================================


Rem =========================================================================
Rem Begin ADO changes
Rem =========================================================================
Rem
Rem
Rem Add referential constraints introduced in 12.1.0.2 to ADO execution 
Rem related dictionary tables

drop index  sys.i_ilmexec_execid;

DECLARE
  primary_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(primary_key_exists, -02260);
BEGIN
  execute immediate
    'alter table sys.ilm_execution$ add constraint pk_taskid ' ||
    ' primary key (execution_id) ' ;
EXCEPTION
  WHEN primary_key_exists THEN
    NULL;
END;
/

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_executiondetails$ add constraint  fk_execdet ' ||
    ' foreign key (execution_id) references  ilm_execution$(execution_id) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

drop index sys.i_ilm_results$;

DECLARE
  primary_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(primary_key_exists, -02260);
BEGIN
  execute immediate
    'alter table sys.ilm_results$ add constraint pk_res ' ||
    ' primary key (jobname) ' ;
EXCEPTION
  WHEN primary_key_exists THEN
    NULL;
END;
/


DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_results$ add constraint  fk_res ' ||
    ' foreign key (execution_id) references  ilm_execution$(execution_id) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_result_stat$ add constraint  fk_resst ' ||
    ' foreign key (jobname) references  ilm_results$(jobname) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_dependant_obj$ add constraint  fk_depobj' ||
    ' foreign key (execution_id) references  ilm_execution$(execution_id) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/


DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_dependant_obj$ add constraint  fk_depobjjobn' ||
    ' foreign key (par_jobname) references  ilm_results$(jobname) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_dep_executiondetails$ add constraint  fk_depdet' ||
    ' foreign key (execution_id) references  ilm_execution$(execution_id) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

DECLARE
  foreign_key_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(foreign_key_exists, -02275);
BEGIN
  execute immediate
    'alter table sys.ilm_dep_executiondetails$ add constraint fk_depdetjobn' ||
    ' foreign key (par_jobname) references  ilm_results$(jobname) ' ||
    ' on delete cascade ' ;
EXCEPTION
  WHEN foreign_key_exists THEN
    NULL;
END;
/

Rem =========================================================================
Rem End ADO changes
Rem =========================================================================

Rem *************************************************************************
Rem Begin Bug 17637420: Add tracking columns to SQL and error translation tables
Rem *************************************************************************

alter table sqltxl_sql$ add(rtime timestamp);
alter table sqltxl_sql$ add(cinfo varchar2(64));
alter table sqltxl_sql$ add(module varchar2(64));
alter table sqltxl_sql$ add(action varchar2(64));
alter table sqltxl_sql$ add(puser# number);
alter table sqltxl_sql$ add(pschema# number);
alter table sqltxl_sql$ add(comment$ varchar2(4000));

alter table sqltxl_err$ add(rtime timestamp);
alter table sqltxl_err$ add(comment$ varchar2(4000));

Rem *************************************************************************
Rem End Bug 17637420
Rem *************************************************************************

Rem *************************************************************************
Rem 17670879: remove extraneous local Oracle-supplied system privileges
Rem *************************************************************************

update sysauth$
   set option$=bitand(option$,56)+4
 where sys_context('USERENV', 'CON_ID') > 1
   and grantee# in (select user# from user$ where bitand(spare1,256)<>0)
   and privilege#<0
   and bitand(option$, 12)=8;
commit;

Rem *************************************************************************
Rem End 17670879
Rem *************************************************************************

Rem *************************************************************************
Rem 17860560: run ALTER TABLE UPGRADE on table dependents of types
Rem *************************************************************************

-- run ALTER TABLE UPGRADE on table dependents of common types
DECLARE
  cursor c is
    select u.name owner, o.name object_name
      from sys.obj$ o, sys.user$ u
    where sys_context('userenv', 'con_id') > 1 and
      o.type#=2 and u.user#=o.owner# and obj# in
      (select d_obj# from sys.dependency$ d, sys.obj$ typo where
       typo.type#=13 and typo.obj#=d.p_obj# and d.p_timestamp <> typo.stime and
       bitand(typo.flags, 196608)<>0);
BEGIN
  FOR tab in c
  LOOP
    execute immediate 'ALTER TABLE ' ||
                      dbms_assert.enquote_name(tab.owner, FALSE) || '.' ||
                      dbms_assert.enquote_name(tab.object_name, FALSE) ||
                      ' UPGRADE';
  END LOOP;
  commit;
END;
/

Rem *************************************************************************
Rem End 17860560
Rem *************************************************************************

Rem ************************************************************************* 
Rem Begin Bug 20869766
Rem       
Rem       The definition of all CDB_* views changed between 12.1 and 12.2. 
Rem       CDB_ANALYZE_OBJECTS does not get re-created until later. So,
Rem       re-create it explicitly here. Do not invoke package function
Rem       CDBView.create_cdbview, since the new definition of create_cdbview
Rem       is not loaded until later. If we do not re-create CDB_ANALYZE_OBJECTS
Rem       here, the revoke below will fail with error ORA-04063.
Rem       
Rem *************************************************************************

create or replace view sys.cdb_analyze_objects as 
select k.*, k.con$name, k.cdb$name
from containers(sys.dba_analyze_objects) k
/

Rem *************************************************************************
Rem End Bug 20869766
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 17526652 17526621 revoke select_catalog_role
Rem *************************************************************************

-- NOTE: move revoke select on cdb_keepsizes for project 47511 to catuppst.sql
-- until a better solution is found. Bug 17526621 will be reopened.
revoke select on cdb_analyze_objects from select_catalog_role;

Rem *************************************************************************
Rem End Bug 17526652 17526621
Rem *************************************************************************

Rem ========================================================================
Rem BEGIN Bug 21185089 revoke select privilege from public on nologged views
Rem =========================================================================
REVOKE SELECT ON gv_$backup_nonlogged FROM PUBLIC;
REVOKE SELECT ON v_$backup_nonlogged FROM PUBLIC;
REVOKE SELECT ON gv_$copy_nonlogged FROM PUBLIC;
REVOKE SELECT ON v_$copy_nonlogged FROM PUBLIC;
REVOKE SELECT ON gv_$nonlogged_block FROM PUBLIC;
REVOKE SELECT ON v_$nonlogged_block FROM PUBLIC;

Rem *************************************************************************
Rem End Bug 21185089
Rem *************************************************************************

Rem ========================================================================
Rem BEGIN Bug 13611733 
Rem    revoke select privilege from select_catalog_role on some views
Rem =========================================================================
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON ku$_12audit_policy_enable_view FROM SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'REVOKE SELECT ON ku$_audit_context_view FROM SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'REVOKE SELECT ON ku$_audit_policy_view FROM SELECT_CATALOG_ROLE';
  EXECUTE IMMEDIATE 'REVOKE SELECT ON ku$_audit_policy_enable_view FROM SELECT_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/ 

Rem *************************************************************************
Rem End Bug 13611733
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for XStream
Rem =======================================================================

create table repl$_process_events
(
   streams_type  number not null,                           /* 0 -> STREAMS */
                                                            /* 1 -> XSTREAM */
                                                         /* 2 -> GOLDENGATE */
   process_type  number not null,                           /* process type */
   streams_name  varchar2 (128) not null,                   /* streams name */
   event_name    varchar2 (128),                                   /* event */
   description   varchar2 (2000),                        /* event's details */
   event_time    timestamp,                    /* event's registration time */ 
   error_number  number,                    /* error number reported if any */
   error_message varchar2(2000),                    /* explanation of error */
   spare1        number,
   spare2        number,
   spare3        number,
   spare4        varchar2(2000),
   spare5        varchar2(2000),
   spare6        timestamp,
   spare7        raw(2000)
)
/

create index i_repl$_process_event on repl$_process_events (streams_name)
/

rem =======================================================================
Rem  End Changes for XStream
Rem =======================================================================

Rem *************************************************************************
Rem 17954127: patch synobj# of MDSYS objects to point to PUBLIC.XMLTYPE
Rem *************************************************************************

declare
  xmltype_pub_syn   number := -1;
  entries_to_patch  number := -1;
begin

  select count(*) into entries_to_patch
  from coltype$
  where synobj# NOT IN (select obj# from obj$)
        and obj# in (select obj# from obj$
                     where owner# = (select user#
                                     from user$ where name = 'MDSYS'));

  select obj# into xmltype_pub_syn
  from obj$
  where name = 'XMLTYPE'
        and type# = 5
        and owner# = (select user# from user$ where name = 'PUBLIC');

  if entries_to_patch <> 0 then
    update coltype$
    set synobj# = xmltype_pub_syn
    where synobj# NOT IN (select obj# from obj$)
          and obj# in (select obj# from obj$
                       where owner# = (select user#
                                       from user$ where name = 'MDSYS'));
    commit;
  end if;

exception when others then
  if entries_to_patch = 0 then null;
  else raise;
  end if;
end;
/

Rem *************************************************************************
Rem End 17954127
Rem *************************************************************************

Rem *************************************************************************
Rem 17971391: increase size of opbinding$.functionname
Rem *************************************************************************

alter table sys.opbinding$ modify functionname varchar2(386);

Rem *************************************************************************
Rem End 17971391
Rem *************************************************************************

Rem *************************************************************************
Rem 18157062: Add MAX_TXN_THINK_TIME column to CPOOL$ table
Rem *************************************************************************

ALTER TABLE CPOOL$ ADD (max_txn_think_time NUMBER);

Rem *************************************************************************
Rem End 18157062
Rem *************************************************************************

Rem *************************************************************************
Rem 18019880: Update sysauth$ to remove admin option for DBA
Rem *************************************************************************

update sysauth$ set option$ = decode (bitand (option$,46), 0, null,
bitand (option$,46)) where grantee# = 
(select user# from user$ where name = 'DBA');
/
commit;

Rem *************************************************************************
Rem End 18019880
Rem *************************************************************************

Rem *************************************************************************
Rem 18180897: Grant privileges to SYSTEM
Rem *************************************************************************

grant enqueue any queue to system with admin option;
/
grant dequeue any queue to system with admin option;
/
grant manage any queue to system with admin option;
/

Rem *************************************************************************
Rem End 18180897
Rem *************************************************************************

Rem *************************************************************************
Rem bug#18469064 change session_key type to raw in reg
Rem Bug 25337332: Drop column changes table signature, so don't perform
Rem upgrade actions if they have already been done.
Rem 
Rem *************************************************************************

-- session_key is not the last column, and cannot be dropped
-- without changing the table's signature, so update in place.
-- and only if the change has not aleady been made.
DECLARE
   col_type number;
BEGIN
   -- update only if the session_key column is varchar2
   SELECT c.type# INTO col_type
   FROM col$ c, obj$ o, user$ u
   WHERE u.name = 'SYS'
     and u.user# = o.owner#
     and o.name = 'REG$'
     and o.type#=2
     and o.obj#=c.obj#
     and c.name = 'SESSION_KEY';
   IF col_type=1 THEN   -- 12.1 column type was VARCHAR2, so change to RAW
     EXECUTE IMMEDIATE
       'ALTER TABLE reg$ ADD (temp RAW(1024))';
     EXECUTE IMMEDIATE
        'UPDATE reg$ SET TEMP = utl_raw.cast_to_raw(session_key)';
     EXECUTE IMMEDIATE
        'UPDATE reg$ SET session_key = NULL';
     COMMIT;
     EXECUTE IMMEDIATE
        'ALTER TABLE reg$ MODIFY session_key RAW(1024)';
     EXECUTE IMMEDIATE
        'UPDATE reg$ SET session_key = temp';
     COMMIT;
     EXECUTE IMMEDIATE
        'ALTER TABLE reg$ DROP COLUMN temp';
   END IF;
END;
/

Rem ********************************************************************
Rem End  18469064
Rem ********************************************************************

Rem ====================================================================
Rem BEGIN changes for sys.reg table
Rem ====================================================================
alter table sys.reg$ add (ntfn_subscriber VARCHAR2(128) default NULL);

Rem =======================================================================
Rem  End changes for sys.reg table
Rem =======================================================================

Rem *************************************************************************
Rem : bug #17665104 add patch-UID to opatch_inst_patch
Rem *************************************************************************
ALTER  TABLE  opatch_inst_patch ADD
patchUId VARCHAR2(20);

Rem *************************************************************************
Rem End  17665104
Rem ********************************************************************

Rem *************************************************************************
Rem : #21143559 long identifiers support -BEGIN
Rem ********************************************************************
alter table opatch_inst_job modify node_name varchar2(128);
alter table opatch_inst_job modify inst_name varchar2(128);

alter table opatch_inst_patch modify nodeName varchar2(128);
alter table opatch_inst_patch modify patchNum varchar2(128);
alter table opatch_inst_patch modify patchUId varchar2(128);

Rem *************************************************************************
Rem : #21143559 long identifiers support - END


Rem =======================================================================
Rem BEGIN bug 18417322: add flags and a couple of spare columns to 
Rem CDB_LOCAL_ADMINAUTH$
Rem =======================================================================

alter table cdb_local_adminauth$ add flags number default 0 not null;
alter table cdb_local_adminauth$ add spare1 number;
alter table cdb_local_adminauth$ add spare2 varchar2(128);

Rem *************************************************************************
Rem : Proj 46885 - admin user password management
Rem     Add new columns to enforce security on PDB local admin users.
Rem *************************************************************************
ALTER TABLE cdb_local_adminauth$ add
(
  lcount        number default 0,         /* count of failed login attempts */
  astatus       number default 0,                  /* status of the account */
  exptime       date,                    /* actual password expiration time */
  ltime         date,                        /* time when account is locked */
  lsltime       date,                         /* Last Successful Logon Time */
  passwd_profile varchar2(128),                    /* Password Profile name */
  passwd_limit   varchar2(4000),               /* Profile's password limits */
  fed_privileges number default 0 not null, /* federationally granted privs */
  ext_username   varchar2(4000)                        /* external username */
)
/

Rem ********************************************************************
Rem End Proj 46885 - admin user password management
Rem ********************************************************************

Rem Set a bit (0x01) in FLAGS in CDB_LOCAL_ADMINAUTH$ rows that represent 
Rem administrative privilege(s) granted locally to Common Users
update CDB_LOCAL_ADMINAUTH$ a set flags = flags + 1
  where sys_context('userenv', 'con_id') = 1 
    and bitand(flags, 1) = 0 
    and exists (select null from user$ u
                  where a.grantee$ = u.name
                    and bitand(u.spare1, 128) = 128)
/

commit
/
  
Rem =======================================================================
Rem  END bug 18417322
Rem =======================================================================

Rem 20772435: All registry$sqlpatch changes are now in the XDB friendly
Rem upgrade scripts

Rem *************************************************************************
Rem Begin 18977120: Add bundle_series to registry$history
Rem *************************************************************************

begin
  execute immediate
    'alter table registry$history add (bundle_series varchar2(30))';
exception
  when others then
    if sqlcode in (-904, -942, -1430) then
      null;
    else
      raise;
    end if;
end;
/

Rem *************************************************************************
Rem End 18977120: Add bundle_series to registry$history
Rem *************************************************************************


Rem *************************************************************************
Rem bug 17446096: populate adminauth$ in a non-CDB using data in 
Rem v$pwfile_users.  Do not propagate data from a row corresponding to SYS
Rem because SYS always has SYSDBA and SYSOPER
Rem *************************************************************************

Rem delete rows from adminauth$ in a non-CDB before doing an insert to avoid 
Rem unique key violations
delete from adminauth$ where sys_context('userenv', 'con_id') = 0
/

insert into adminauth$ (user#, syspriv, common)
  select u.user#, 
         decode(p.SYSDBA,    'TRUE', 2,    0) +
         decode(p.SYSOPER,   'TRUE', 4,    0) +
         decode(p.SYSBACKUP, 'TRUE', 256,  0) +
         decode(p.SYSDG,     'TRUE', 512,  0) +
         decode(p.SYSKM,     'TRUE', 1024, 0) as syspriv,
         0 as common
  from v$pwfile_users p, user$ u
  where sys_context('userenv', 'con_id') = 0
    and p.username = u.name
    and u.name != 'SYS'
/

commit
/

Rem ********************************************************************
Rem End  17446096
Rem ********************************************************************

Rem *************************************************************************
Rem Project 46885 : Inactive Account Time Password Profile Parameter - BEGIN
Rem *************************************************************************
Rem
Rem Insert a row in resource_map for newly added password profile parameter
Rem INACTIVE_ACCOUNT_TIME, which has resource# set to 7 in profile$.
Rem For pre-12.2 created profiles, there will be no entry in profile$ table
Rem corresponding to resource#=7, so altering it later would result into
Rem ORA-600[kzdpfr:pwd] errors. So we go over all of the existing profiles,
Rem including DEFAULT and ORA_STIG_PROFILE and insert a row in profile$
Rem for Inactive_Account_Time parameter.
Rem
Rem PROFILE$ and RESOURCE_MAP tables does not have any constraint on entries
Rem and hence no ORA-00001 : unique constraint violated error to rescue.
Rem The same anonymous block runs inside c1102000.sql as well. So for database
Rem upgrades from 11.2 to current release, in order to avoid the double-insert
Rem into profile$ as well as resource_map, we check the dictionary whether an
Rem entry already exists. Only if it does not, we go ahead with the insert.
Rem
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
Rem SYSRAC (proj 46816) changes - BEGIN
Rem *************************************************************************

create user sysrac identified by "D_SYSRACPW" account lock password expire;

revoke inherit privileges on user sysrac from public;

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-398, 'SYSRAC', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (398, 'SYSRAC', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem SYSRAC (proj 46816) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************

Rem Add directive_type column to cdb_resource_plan_directive$
alter table cdb_resource_plan_directive$ add (directive_type varchar2(30));

Rem All directives other than the default and autotask directives
Rem have directive_type = PDB.
update cdb_resource_plan_directive$ set directive_type = 'PDB';
update cdb_resource_plan_directive$ set directive_type = 'DEFAULT_DIRECTIVE'
 where pdb = 'ORA$DEFAULT_PDB_DIRECTIVE';
update cdb_resource_plan_directive$ set directive_type = 'AUTOTASK'
 where pdb = 'ORA$AUTOTASK';

Rem Add memory_min and memory_limit columns to cdb_resource_plan_directive$
alter table cdb_resource_plan_directive$ add (memory_min number);
alter table cdb_resource_plan_directive$ add (memory_limit number);

update cdb_resource_plan_directive$ set memory_min = 4294967295;
update cdb_resource_plan_directive$ set memory_limit = 4294967295;

Rem Add session_pga_limit
alter table resource_plan_directive$ add (session_pga_limit number);
update resource_plan_directive$ set session_pga_limit = 4294967295;

alter table WRH$_RSRC_CONSUMER_GROUP 
  add (switches_in_io_logical    number default 0 not null);
alter table WRH$_RSRC_CONSUMER_GROUP 
  add (switches_out_io_logical   number default 0 not null);
alter table WRH$_RSRC_CONSUMER_GROUP 
  add (switches_in_elapsed_time  number default 0 not null);
alter table WRH$_RSRC_CONSUMER_GROUP 
  add (switches_out_elapsed_time number default 0 not null);
alter table WRH$_RSRC_CONSUMER_GROUP 
  add (pga_limit_sessions_killed number default 0 not null);
alter table WRH$_RSRC_CONSUMER_GROUP add (per_pdb number default null);

alter table WRH$_RSRC_PLAN add (instance_caging varchar2(4));
alter table WRH$_RSRC_PLAN add (per_pdb number default null);

Rem *************************************************************************
Rem Resource Manager related changes - END
Rem *************************************************************************

Rem ********************************************************************
Rem BEGIN Proj# 35931: New Clob column to store VPD predicates
Rem ********************************************************************
Rem Bug 19076927 - Donot need the query now since AUD$ will be in SYS schema.
Rem Bug 26634509 - Donot set default values of new columns in aud$/fga_log$
Rem                to NULL.
alter table sys.aud$ add rls$info clob
/
alter table sys.fga_log$ add rls$info clob
/

Rem ********************************************************************
Rem END Proj# 35931: New Clob column to store VPD predicates
Rem ********************************************************************

Rem **************************************************************************
Rem BEGIN changes for bug 17900999 
Rem **************************************************************************

Rem Bug 17900999 - increase size of aud$.auth$privileges
alter table sys.aud$ modify(auth$privileges varchar2(32))
/

Rem **************************************************************************
Rem END changes for bug 17900999 
Rem **************************************************************************

Rem ********************************************************************
Rem BEGIN changes for Bug 13716158
Rem ********************************************************************
Rem Add a new column to hold the current user information
Rem Bug 26634509 - Donot set default values of new columns in aud$/fga_log$
Rem                to NULL.

alter table sys.aud$ add current_user varchar2(128)
/
alter table sys.fga_log$ add current_user varchar2(128)
/

Rem ********************************************************************
Rem END changes for Bug 13716158
Rem ********************************************************************

Rem **************************************************************************
Rem BEGIN Proj #46864: Data Redaction upgrade from 12.1 release.
Rem **************************************************************************
Rem
Rem Add radm_pe$ to allow more than one Policy Expression per object.
Rem Each column can have its own Policy Expression.
Rem Columns in separate objects can share a Policy Expression.
Rem The pe_name may be NULL, indicating that this is an object-wide default
Rem Policy Expression (the pe_obj# must then contain the object number).
Rem
create table radm_pe$                   /* Data Redaction Policy Expression */
(
  pe#        number primary key,               /* Policy Expression number. */
  pe_obj#    number,     /* Object number of default Policy Expr, else NULL */
  pe_name    varchar2(4000),  /* Policy Expression name (NULL: use pe_obj#) */
  pe_pexpr   varchar2(4000) not null,                 /* Policy Expression. */
  pe_version varchar2(30) not null,    /* Version that created Policy Expr. */
  pe_descrip varchar2(4000),            /* Description of Policy Expression */
  pe_compat  varchar2(30) not null, /* Value of COMPATIBLE at creation time */
  pe_spare1  varchar2(1000),
  pe_spare2  date,
  pe_spare3  timestamp,
  pe_spare4  number,
  pe_spare5  number,
  pe_spare6  number
)
/

Rem
Rem To cover the rerun scenario, in order to avoid an ORA-02266 during
Rem the following truncate of the radm_pe$ table, we need to drop the
Rem constraint radm_mc_pe_number.  An ORA-02266 would otherwise occur
Rem because the primary key pe# of the radm_pe$ table is referenced by
Rem the enabled foreign key constraint radm_mc_pe_number (on the pe#
Rem column of the radm_mc$ table).
Rem
alter table sys.radm_mc$ drop constraint radm_mc_pe_number
/

Rem
Rem lrg #19690342: Data Redaction fix for re-upgrade.
Rem Cannot truncate the radm_pe$ table here, as the upgrade script 
Rem may be re-run after a Data Redaction Policy has been upgraded
Rem to the 12.2-format by the PL/SQL block below (see the "Copy each 
Rem existing Policy Expression..." comment).
Rem

create unique index i_radm_pe1 on sys.radm_pe$(pe_name)
/
create index i_radm_pe2 on sys.radm_pe$(pe_obj#, pe_name)
/

Rem
Rem Create the sequence radm_pe$_seq to use for the radm_pe$.pe# primary key.
Rem
create sequence sys.radm_pe$_seq
start with 5000 increment by 1 nocache nocycle order
/

Rem
Rem Add the pe# column to the radm_mc$ table,
Rem such that it references the pe# column of the radm_pe$ table
Rem (the name of this constraint is radm_mc_pe_number).
Rem
Rem Note: cannot use "on delete cascade" when defining the radm_mc_pe_number
Rem constraint, because the radm_mc$ table is managed by KGL and SQL-level
Rem deletion does not invalidate the KGL cache, leading to inconsistency.
Rem Instead, let's raise an error from the DBMS_REDACT api if an
Rem attempt is made to delete a Policy Expression while a column
Rem is still using it.
Rem
Rem Note: the column radm_mc$.pe# will be altered to be NOT NULL after
Rem the column is populated with the Policy Expression IDs.
Rem
alter table sys.radm_mc$ add pe# number 
/

Rem
Rem The index i_radm_mc3 on radm_mc$.pe# is needed because will need to lookup
Rem all objects (obj#) associated with a given Policy Expression ID (pe#).
Rem
create index i_radm_mc3 on radm_mc$(pe#)
/

Rem
Rem Add the regexp_charset column (NLS character set information)
Rem to the radm_mc$ table (needed for bug 14340405).
Rem
alter table sys.radm_mc$ add regexp_charset number 
/

Rem
Rem Copy each existing Policy Expression from the pexpr column of
Rem the radm$ table to the radm_pe$ table, inserting them as
Rem a special kind of Policy Expression known as the "default
Rem object-wide Policy Expression".
Rem
Rem Note: A default object-wide Policy Expression will always
Rem       have NULL as its name, it is identified instead
Rem       by its pe_obj# (its object number).
Rem
Rem The Policy Expression rows in radm_pe$ are thus populated as follows:
Rem
Rem radm_pe$.pe_pexpr - This value comes from the existing radm$.pexpr value.
Rem radm_pe$.pe_obj#  - This value comes from the object number.
Rem radm_pe$.pe_name  - always NULL: this identifies this Policy Expression
Rem                     as being a default object-wide Policy Expression.
Rem radm_pe$.pe#      - New Policy Expression ID: this is allocated from
Rem                     the sys.radm_pe$_seq sequence.
Rem
Rem Update the pe# column of the sys.radm_mc$ so that it has the
Rem corresponding Policy Expression ID, so that (if there are any
Rem existing column policies for the object), they all use this 
Rem new pe# from the sequence.
Rem
Rem Each existing Data Redaction policy results in one new
Rem row being created in the radm_pe$ table, and zero or more
Rem rows being updated in the radm_mc$ table (depending on
Rem whether any columns had been added to the redaction policy).
Rem
Rem Note: It's not possible for this upgrade script to know the
Rem version that it's upgrading from, so since both versions
Rem 11.2.0.4 and 12.1.0.1.0 use the same dictionary metadata
Rem to describe per-table policy expressions, we set the 
Rem previous_version to 12.1.0.1.0.  The compatible_version
Rem of 11.0.0.0.0 is just a placeholder, because a non-NULL
Rem value needs to be provided.
Rem 
Rem Bug 26137416: Add a call to REPLACE before calling ENQUOTE_LITERAL,
Rem to replace any quote in the Policy Expression with two quotes (escaping
Rem the quotes), otherwise when a quote is present in any of the existing
Rem customer's Policy Expressions, an ORA-06502: "PL/SQL: numeric or value 
Rem error" would get raised by ENQUOTE_LITERAL (see enhancement request
Rem bug 9777721 and doc bug 14128230), and the ORA-06502 would cause the
Rem following block to be aborted, leaving the newly-added pe# column
Rem of the radm_mc$ table with only NULL values, which in turn would
Rem cause the creation of the "NOT NULL" constraint on the pe# column
Rem of the radm_mc$ table to fail with an ORA-02296 error.
Rem
DECLARE
  previous_version      varchar2(30);
  compatible_version    varchar2(30);
  policy_description    varchar2(30);
  policy_expression_key number;
BEGIN
  previous_version   := '12.1.0.1.0';
  compatible_version := '11.0.0.0.0';
  policy_description := 'Default policy expression.';

  --
  -- lrg #19690342: Data Redaction fix for re-upgrade.
  -- Add "WHERE pexpr IS NOT NULL", to avoid attempting to
  -- upgrade any 12.2-format Data Redaction policy.
  --
  FOR cur_rec IN (SELECT pexpr policy_expression,
                         obj#  object_number
                    FROM sys.radm$
                   WHERE pexpr IS NOT NULL)
  LOOP
    BEGIN
      SELECT sys.radm_pe$_seq.NEXTVAL
        INTO policy_expression_key
        FROM dual;

      EXECUTE IMMEDIATE 
        'INSERT INTO sys.radm_pe$'
        || '(pe#, pe_obj#, pe_pexpr, pe_version, pe_descrip, pe_compat)'
        || ' VALUES ('
        || policy_expression_key
        || ','
        || cur_rec.object_number
        || ','
        || DBMS_ASSERT.ENQUOTE_LITERAL(
             REPLACE(cur_rec.policy_expression, '''',''''''))
        || ','
        || DBMS_ASSERT.ENQUOTE_LITERAL(previous_version)
        || ','
        || DBMS_ASSERT.ENQUOTE_LITERAL(policy_description)
        || ','
        || DBMS_ASSERT.ENQUOTE_LITERAL(compatible_version)
        || ')';

      EXECUTE IMMEDIATE
        'UPDATE sys.radm_mc$ SET pe# = ' || policy_expression_key ||
        ' WHERE obj# = ' || cur_rec.object_number;
    END;
  END LOOP;
END;
/

Rem
Rem Now that the pe# values have been filled in for radm_mc$
Rem and the default Policy Expressions have been moved to radm_pe$,
Rem enable the constraint radm_mc_pe_number to ensure the tables
Rem always remain consistent.
Rem
alter table sys.radm_mc$ add constraint radm_mc_pe_number
foreign key(pe#) references sys.radm_pe$(pe#)
/

Rem
Rem We need to now modify the radm_mc_pe_number
Rem constraint on the sys.radm_mc$ table to enable and validate
Rem the radm_mc_pe_number constraint.
Rem
alter table sys.radm_mc$ modify constraint radm_mc_pe_number enable validate
/

Rem
Rem The column radm_mc$.pe# must now be altered to NOT NULL since
Rem it has been populated with the Policy Expression IDs.
Rem
alter table sys.radm_mc$ modify pe# NOT NULL
/

Rem
Rem The column radm$.pexpr must now be altered to allow NULL, 
Rem since we will no longer be using it for storing Policy Expressions,
Rem they now reside in the radm_pe$ table.
Rem 
alter table sys.radm$ modify pexpr NULL
/

Rem
Rem lrg #19690342: Data Redaction fix for re-upgrade.
Rem Now that any existing Policy Expression of a Data Redaction policy
Rem has been upgraded to the 12.2-format (by moving it to the radm_pe$
Rem table) set the radm$.pexpr column to NULL. There are not expected
Rem to be many rows in this table, so a bulk update isn't needed.
Rem
update sys.radm$ set pexpr = NULL
/

commit;

Rem
Rem Bug #22153841: Adding the commands to increase the length of the pname
Rem column of both radm_td$ and radm_cd$ during the upgrade of Data Redaction
Rem from 12.1 release.
Rem During an upgrade from 11.2 to 12.1, only the pname column of the radm$
Rem data dictionary table was (correctly) increased in size to 128 by the
Rem rdbms/admin/c1102000.sql, whereas the pname column of both the radm_td$
Rem and radm_cd$ tables was mistakenly left unchanged at length 30
Rem (these tables were somehow omitted from the c1102000.sql changes
Rem made by txn traney_bug-13651945, so they need to be added here).
Rem
alter table radm_td$ modify pname VARCHAR2(128)
/

alter table radm_cd$ modify pname VARCHAR2(128)
/

Rem **************************************************************************
Rem END Proj #46864: Data Redaction upgrade from 12.1 release.
Rem **************************************************************************

Rem *************************************************************************
Rem Change reco_script_params$ VARCHAR to CLOB
Rem *************************************************************************
ALTER TABLE reco_script_params$ ADD (TEMP clob);
UPDATE reco_script_params$ SET TEMP = VALUE;
ALTER TABLE reco_script_params$ DROP COLUMN VALUE;
ALTER TABLE reco_script_params$ RENAME COLUMN TEMP to VALUE;
Rem *************************************************************************
Rem End change reco_script_params$ VARCHAR to CLOB
Rem *************************************************************************

Rem =======================================================================
Rem Begin Online Redefinition 12.2 Proj#39358 restartability changes
Rem =======================================================================

alter table redef_status$ add(err_no INTEGER);
alter table redef_status$ add(err_txt varchar2(1000));
alter table redef_status$ add(action varchar2(400));

Rem =======================================================================
Rem End Online Redefinition 12.2 Proj#39358 restartability changes
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN 12.2 Project 47098: Data Mining Framework
Rem BEGIN 12.2 Project 47099: Data Mining Model Partitioning
Rem *************************************************************************

drop public synonym dm_fe_build;
drop public synonym dm_glm_build;
drop public synonym dm_cl_apply;
drop public synonym dm_mod_build;
drop public synonym dm_nmf_build;
drop public synonym dm_svm_build;
drop public synonym dm_svm_apply;
drop public synonym dm_cl_build;
drop function dm_fe_build;
drop function dm_glm_build;
drop function dm_cl_apply;
drop function dm_mod_build;
drop function dm_nmf_build;
drop function dm_svm_build;
drop function dm_svm_apply;
drop function dm_cl_build;
drop package dm_fe_cur;
drop package dm_glm_cur;
drop package dm_modb_cur;
drop package dm_nmf_cur;
drop package dm_svm_cur;
drop package dm_cl_cur;
drop type dmfebimp;
drop type dmglmbimp;
drop type dmclbimp;
drop type dmclaimp;
drop type dmmodbimp;
drop type dmnmfbimp;
drop type dmsvmbimp;
drop type dmsvmaimp;
drop type dmfebos;
drop type dmfebo;
drop type dmglmbos;
drop type dmglmbo;
drop type dmclaos;
drop type dmclao;
drop type dmmodbos;
drop type dmmodbo;
drop type dmnmfbos;
drop type dmnmfbo;
drop type dmsvmbos;
drop type dmsvmbo;
drop type dmsvmaos;
drop type dmsvmao;
drop type dmclbos;
drop type dmclbo;
drop library DMFE_LIB;
drop library DMCL_LIB;
drop library DMMOD_LIB;
drop library DMSVM_LIB;
drop library DMSVMA_LIB;
drop library DMNMF_LIB;
drop library DMGLM_LIB;
drop public synonym ORA_FI_DECISION_TREE_HORIZ;
drop function ORA_FI_DECISION_TREE_HORIZ;
drop public synonym ORA_DM_Tree_Nodes;
DROP TYPE ORA_DM_Tree_Nodes;
DROP TYPE ORA_DM_Tree_Node;
drop public synonym ORA_FI_EXP_MAX;
drop function ORA_FI_EXP_MAX;
drop public synonym ORA_DMEM_Nodes;
DROP TYPE ORA_DMEM_Nodes;
DROP TYPE ORA_DMEM_Node;
drop public synonym odm_association_rule_model;
drop public synonym odm_clustering_util;
drop public synonym odm_oc_clustering_model;
drop package body odm_association_rule_model;
drop package body odm_clustering_util;
drop package body odm_oc_clustering_model;
drop package odm_association_rule_model;
drop package odm_clustering_util;
drop package odm_oc_clustering_model;
alter table model$ add pseq# number;
alter table model$ add pco number;
alter table model$ add properties number;
alter table modeltab$ add siz number;
create or replace procedure revoke_dm_grant (gname varchar2) is
begin
  execute immediate 'revoke execute on SYS.'||gname||' from public';
exception WHEN OTHERS THEN 
  NULL;
end;
/
exec revoke_dm_grant('ORA_MINING_NUMBER_NT');
exec revoke_dm_grant('ORA_MINING_VARCHAR2_NT');
exec revoke_dm_grant('ORA_MINING_TABLE_TYPE');
exec revoke_dm_grant('ORA_MINING_TABLES_NT');
exec revoke_dm_grant('DM_MODEL_SIGNATURE_ATTRIBUTE');
exec revoke_dm_grant('DM_MODEL_SIGNATURE');
exec revoke_dm_grant('DM_MODEL_SETTING');
exec revoke_dm_grant('DM_MODEL_SETTINGS');
exec revoke_dm_grant('DM_PREDICATE');
exec revoke_dm_grant('DM_PREDICATES');
exec revoke_dm_grant('DM_RULE');
exec revoke_dm_grant('DM_RULES');
exec revoke_dm_grant('DM_ITEM');
exec revoke_dm_grant('DM_ITEMS');
exec revoke_dm_grant('DM_ITEMSET');
exec revoke_dm_grant('DM_ITEMSETS');
exec revoke_dm_grant('DM_CENTROID');
exec revoke_dm_grant('DM_CENTROIDS');
exec revoke_dm_grant('DM_HISTOGRAM_BIN');
exec revoke_dm_grant('DM_HISTOGRAMS');
exec revoke_dm_grant('DM_CHILD');
exec revoke_dm_grant('DM_CHILDREN');
exec revoke_dm_grant('DM_CLUSTER');
exec revoke_dm_grant('DM_CLUSTERS');
exec revoke_dm_grant('DM_CONDITIONAL');
exec revoke_dm_grant('DM_CONDITIONALS');
exec revoke_dm_grant('DM_NB_DETAIL');
exec revoke_dm_grant('DM_NB_DETAILS');
exec revoke_dm_grant('DM_NMF_ATTRIBUTE');
exec revoke_dm_grant('DM_NMF_ATTRIBUTE_SET');
exec revoke_dm_grant('DM_NMF_FEATURE');
exec revoke_dm_grant('DM_NMF_FEATURE_SET');
exec revoke_dm_grant('DM_SVM_ATTRIBUTE');
exec revoke_dm_grant('DM_SVM_ATTRIBUTE_SET');
exec revoke_dm_grant('DM_SVM_LINEAR_COEFF');
exec revoke_dm_grant('DM_SVM_LINEAR_COEFF_SET');
exec revoke_dm_grant('DM_GLM_COEFF');
exec revoke_dm_grant('DM_GLM_COEFF_SET');
exec revoke_dm_grant('DM_SVD_MATRIX');
exec revoke_dm_grant('DM_SVD_MATRIX_SET');
exec revoke_dm_grant('DM_MODEL_GLOBAL_DETAIL');
exec revoke_dm_grant('DM_MODEL_GLOBAL_DETAILS');
exec revoke_dm_grant('DM_NESTED_NUMERICAL');
exec revoke_dm_grant('DM_NESTED_NUMERICALS');
exec revoke_dm_grant('DM_NESTED_CATEGORICAL');
exec revoke_dm_grant('DM_NESTED_CATEGORICALS');
exec revoke_dm_grant('DM_RANKED_ATTRIBUTE');
exec revoke_dm_grant('DM_RANKED_ATTRIBUTES');
exec revoke_dm_grant('DM_TRANSFORM');
exec revoke_dm_grant('DM_TRANSFORMS');
exec revoke_dm_grant('DM_COST_ELEMENT');
exec revoke_dm_grant('DM_COST_MATRIX');
exec revoke_dm_grant('DM_NESTED_BINARY_FLOAT');
exec revoke_dm_grant('DM_NESTED_BINARY_FLOATS');
exec revoke_dm_grant('DM_NESTED_BINARY_DOUBLE');
exec revoke_dm_grant('DM_NESTED_BINARY_DOUBLES');
exec revoke_dm_grant('DM_EM_COMPONENT');
exec revoke_dm_grant('DM_EM_COMPONENT_SET');
exec revoke_dm_grant('DM_EM_PROJECTION');
exec revoke_dm_grant('DM_EM_PROJECTION_SET');
exec revoke_dm_grant('DM_MODEL_TEXT_DF');
exec revoke_dm_grant('DM_MODEL_TEXT_DFS');
drop procedure revoke_dm_grant;
create table modelpart$
(
  mod#                number       not null,              /* model object id */
  obj#                number       not null,          /* partition object id */
  part#               number       not null,             /* partition number */
  pos#                number,                      /* column position number */
  bhiboundval         blob,                     /* binary form of high bound */
  hiboundlen          number,                  /* length of high bound value */
  hiboundval          varchar2(4000)             /* text of high bound value */
)
storage (maxextents unlimited)
tablespace SYSTEM
/
create unique index modelpart$idx
  on modelpart$ (mod#, part#, pos#)
storage (maxextents unlimited)
tablespace SYSTEM
/
create index modelpart$idx2
  on modelpart$ (mod#, obj#)
storage (maxextents unlimited)
tablespace SYSTEM
/
create table modelpartcol$
(
  obj#                number       not null,          /* partition object id */
  pos#                number       not null,       /* column position number */
  name                varchar2(128) not null,       /* partition column name */
  dty                 number                   /* partition column data type */
)
storage (maxextents unlimited)
tablespace SYSTEM
/
create unique index modelpartcol$idx
  on modelpartcol$ (obj#, pos#)
storage (maxextents unlimited)
tablespace SYSTEM
/
create table modelxfm$
(
  mod#                number       not null,              /* model object id */
  attr                varchar2(128),                       /* attribute name */
  subn                varchar2(4000),  /* attribute subname for nested xform */
  properties          number,                                  /* properties */
  idty                number,                   /* input datatype for rxform */
  ibfl                number,              /* input buffer length for rxform */
  dtyp                number,                             /* result datatype */
  bufl                number,                           /* result buffer len */
  attrspec            varchar2(4000),                      /* attribute spec */
  expr                clob                                     /* expression */
)
storage (maxextents unlimited)
tablespace SYSTEM
/
create index modelxfm$idx
  on modelxfm$ (mod#)
storage (maxextents unlimited)
tablespace SYSTEM
/
create global temporary table modelgttraw$
(
 PARTNUMBER                      NUMBER,
 CONTROLVAL                      NUMBER,
 SLAVENUMBER                     NUMBER,
 ROWNUMBER                       NUMBER,
 CHUNKNUMBER                     NUMBER,
 CHUNKDATA                       RAW(2000)
)
on commit preserve rows
;
grant select on modelgttraw$ to public;
grant insert on modelgttraw$ to public;

Rem *************************************************************************
Rem END 12.2 Project 47098: Data Mining Framework
Rem END 12.2 Project 47099: Data Mining Model Partitioning
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to sqlset_row and wri$_sqlset_statistics
Rem *************************************************************************

Rem We have added a new column to the type sqlset_row in 12gR2. However this
Rem will be created along with its new constructor in catsqlt.sql. Hence we
Rem just drop it here, so that it will be correctly created in catsqlt.sql
drop type sqlset_row force;
drop public synonym sqlset_row;

Rem We need to add last_exec_start_time to wri$_sqlset_statistics for upgrade
Rem This column stores the sysdate to be captured during STS creation
alter table wri$_sqlset_statistics add last_exec_start_time VARCHAR2(19);

Rem *************************************************************************
Rem End Changes to sqlset_row and wri$_sqlset_statistics
Rem *************************************************************************

Rem *************************************************************************
Rem PDB lockdown profile (proj 47234) changes - BEGIN
Rem *************************************************************************

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP
    values (-378, 'CREATE LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP
    values (-379, 'DROP LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP
    values (-380, 'ALTER LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (358, 'LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (378, 'CREATE LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (379, 'DROP LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (380, 'ALTER LOCKDOWN PROFILE', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

commit;

Rem This table stores attributes related to PDB lockdown profiles.
create table lockdown_prof$
(
  prof#       number not null,                                 /* profile id */
  ruletyp     varchar2(128) not null,     /* rule type - stmt/feature/option */
  ruletyp#    number not null,                               /* rule type id */
  ruleval     varchar2(128) not null,                          /* rule value */
  ruleval#    number,                                       /* rule value id */
  clause      varchar2(128),                                       /* clause */
  option$     varchar2(128),                                       /* option */
  status      number,                             /* status - disable/enable */
  level#      number,                                  /* stmt/clause/option */
  value$      varchar2(4000),                               /* default value */
  ltime       timestamp,                           /* timestamp of the entry */
  spare1      number,                                               /* spare */
  spare2      number,                                               /* spare */
  spare3      number,                                               /* spare */
  spare4      number,                                               /* spare */
  spare5      timestamp,                                            /* spare */
  spare6      varchar2(128),                                        /* spare */
  spare7      varchar2(128),                                        /* spare */
  spare8      varchar2(4000),                                       /* spare */
  spare9      varchar2(4000),                                       /* spare */
  minval$     varchar2(4000),                       /* minimum allowed value */
  maxval$     varchar2(4000),                       /* maximum allowed value */
  list$       varchar2(4000)                       /* list of allowed values */
)
/

CREATE INDEX i_lockdownprof1 ON
  lockdown_prof$(prof#, ruletyp#, ruleval, clause, option$)
/

CREATE INDEX i_lockdownprof2 ON
  lockdown_prof$(prof#, ruletyp#, ruleval)
/

CREATE INDEX i_lockdownprof3 ON
  lockdown_prof$(prof#, ruletyp#)
/

Rem *************************************************************************
Rem PDB lockdown profile (proj 47234) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem : Begin Optimizer changes
Rem *************************************************************************

Rem *************************************************************************
Rem : Begin proj 46828 and 47170:
Rem *************************************************************************

Rem is_default for JOB_OVERHEAD preference was incorrectly set to 0.
Rem Correct it.
UPDATE sys.optstat_hist_control$
SET spare1 = 1
WHERE sname =  'JOB_OVERHEAD' AND spare1 != 1;

Rem The column order should be same in newly created db and upgraded db for
Rem cdb. Spare columns does not have any data. We don't store length field
Rem in disk blocks for trailing nulls. To take advantage of this optimization
Rem we add the new columns before the spare columns.

Rem Drop spare columns. Catch and ignore the error if the columns are
Rem already dropped.
BEGIN
  EXECUTE IMMEDIATE
  'ALTER TABLE wri$_optstat_tab_history 
    DROP (spare2, spare3, spare4, spare5, spare6)';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE = -00904 THEN NULL; 
    ELSE RAISE; 
    END IF;
END;
/

Rem Add the new columns. Note that this may fail if the new columns already 
Rem exist. It is silently ignored during upgrade.
ALTER TABLE wri$_optstat_tab_history 
  ADD (im_imcu_count NUMBER);
ALTER TABLE wri$_optstat_tab_history 
  ADD (im_block_count NUMBER);
ALTER TABLE wri$_optstat_tab_history 
  ADD (scanrate NUMBER);

Rem Add spare columns
ALTER TABLE wri$_optstat_tab_history 
  ADD (spare2 NUMBER, spare3 NUMBER, spare4 VARCHAR2(1000), 
       spare5 VARCHAR2(1000), spare6 TIMESTAMP WITH TIME ZONE);

Rem Add nrows to opt_finding_obj$
ALTER TABLE opt_finding_obj$
  ADD (nrows NUMBER);

Rem *************************************************************************
Rem : End proj 46828 and 47170:
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Proj 44162: Optimizer Stats Advisor
Rem *************************************************************************

Rem object filter table
create global temporary table stats_advisor_filter_obj$
(rule_id number,                                         /* Rule ID to check */
 obj# number not null,                                      /* Object number */
 flags number,                                                      /* flags */
 type  number)                                          /* type of the entry */
on commit preserve rows
/

create index i_stats_advisor_filter_obj$ on
  stats_advisor_filter_obj$ (rule_id, obj#)
/

Rem stats operation filter table
create global temporary table stats_advisor_filter_opr$
(rule_id number,                                         /* Rule ID to check */
 name varchar2(64),                           /* Name of the stats operation */
 param varchar2(4000),                         /* Parameter and their values */
 flags number                                                       /* flags */
) on commit preserve rows
/

create index i_stats_advisor_filter_opr$ on
  stats_advisor_filter_opr$ (rule_id, name)
/

Rem rule filter table
create global temporary table stats_advisor_filter_rule$
(rule_id number not null primary key,                    /* Rule ID to check */
 flags   number)                                                    /* flags */
on commit preserve rows
/

Rem Optimizer Statistics Snapshot Information
create table optstat_snapshot$
(
  obj#              number,                                 /* object number */
  inserts           number,  /* approx. number of inserts since last analyze */
  updates           number,  /* approx. number of updates since last analyze */
  deletes           number,  /* approx. number of deletes since last analyze */
  flags             number,                                         /* flags */
  timestamp         timestamp(6) with time zone   /* timestamp of last entry */
)
  storage (initial 200K next 100k maxextents unlimited pctincrease 0)
/

create index i_optstat_snapshot$ on
  optstat_snapshot$ (obj#)
/

create sequence stats_advisor_dir_seq start with 1 increment by 1
/

alter table col_usage$ add flags number;

Rem *************************************************************************
Rem END Proj 44162: Optimizer Stats Advisor
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN #(20059248) Changes to wri$_optstat_opr and wri$_optstat_opr_tasks
Rem *************************************************************************

alter table wri$_optstat_opr modify target VARCHAR2(512);

alter table wri$_optstat_opr_tasks modify target VARCHAR2(512);

Rem *************************************************************************
Rem END Changes to wri$_optstat_opr and wri$_optstat_opr_tasks
Rem *************************************************************************

Rem =========================================================================
Rem Begin Proj 47047: Expression Tracking
Rem =========================================================================

create table exp_head$
(
  exp_id             number not null,                      /* expresion id */
  objn	             number not null,    
                                  /* table object number of the expression */
  sub_id             number,   /* entry-level number for package functions */
  fixed_cost         number not null,        /* fixed cost of an expresion */
  text               varchar2(4000) not null,           /* expression text */
  col_list           varchar2(4000) not null, 
                                  /* list of columns seen in the expresion */
  flags              number,                                      /* flags */
  ctime              date not null                   /* creation timestamp */
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of the expression header given expression id.
Rem
create unique index i_exp_head$ on 
  exp_head$(exp_id)
  tablespace sysaux
/

Rem Following table stores the information about expression object. The table
Rem contains 1 row per expression object.
Rem
create table exp_obj$
( 
  objn        number not null,   /* table/partition obj# of the expression */
  snapshot_id number not null,                              /* snapshot id */
  exp_cnt     number               /* number of expressions for the object */
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of the expression object given object number.
Rem
create unique index i_exp_obj$ on 
  exp_obj$(objn, snapshot_id)
  tablespace sysaux
/

create table exp_stat$
(
  exp_id                number not null,                    /* expression id */
  objn	                number not null,
                        /* lowest level object number (i.e. partition level) */
  dynamic_cost          number,              /* dynamic cost of an expresion */
  eval_count            number not null,  /* expression evaluation frequency */
  snapshot_id           number not null,                      /* snapshot id */
  ctime                 date not null,                 /* creation timestamp */
  last_modified         date,                     /* last modified timestamp */
  update_count          number                           /* update frequency */
) tablespace sysaux 
pctfree 1
enable row movement
/

Rem Index for fast lookup of all the expression stats given object number
Rem and snapshot id.
Rem
create index sys.i_exp_stat$ on
  exp_stat$(objn, snapshot_id)
  tablespace sysaux
/

Rem =========================================================================
Rem End Proj 47047: Expression Tracking
Rem =========================================================================

Rem =========================================================================
Rem Begin #(20413540) Table for storing sql statistics
Rem =========================================================================

Rem Drop the table if it is already created as part of applying BLR. The 
Rem second column name is different in 12.2 (used to be parse_schema in BLR).
drop table opt_sqlstat$ purge;

Rem Create Index organized table to store sql statistics
create table opt_sqlstat$
( sql_id               varchar2(13) not null,                    /* sql id */
  parsing_schema_name  varchar2(128) not null,      /* parsing schema name */
  executions           number,                     /* number of executions */
  end_of_fetch_count   number,                       /* end of fetch count */
  elapsed_time         number,                             /* elapsed time */
  cpu_time             number,                                 /* cpu time */
  buffer_gets          number,                              /* buffer gets */
  last_gather_time     date,              /* last time stats were gathered */
  constraint           pk_opt_sqlstat 
                       primary key (sql_id, parsing_schema_name))
organization index 
tablespace sysaux 
pctfree 1
/

Rem Create secondary index on last_gather_time to have fast look up
Rem while deleting old entries of sql_ids
Rem
create index i_opt_sqlstat_lgt on
  opt_sqlstat$(last_gather_time)
  tablespace sysaux
/

Rem =========================================================================
Rem End #(20413540) Table for storing sql statistics
Rem =========================================================================

Rem ********************************************************************
Rem End  Optimizer changes
Rem ********************************************************************

Rem *************************************************************************
Rem : Proj 47234 - adding support for federationally granted administrative 
Rem     privileges
Rem *************************************************************************

ALTER TABLE cdb_local_adminauth$ modify (privileges default 0)
/

ALTER TABLE adminauth$ add (fedpriv number default 0 not null)
/

Rem *************************************************************************
Rem : End Proj 47234 - adding support for federationally granted 
Rem     administrative privileges
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to scheduler for long id project
Rem *************************************************************************

alter table sys.scheduler$_job
 modify destination varchar2(261);

alter table sys.scheduler$_job
 modify queue_agent varchar2(523);

alter table sys.scheduler$_lightweight_job
  modify destination varchar2(261);

alter table sys.scheduler$_lightweight_job
  modify queue_agent varchar2(523);

alter table sys.scheduler$_schedule
  modify queue_agent varchar2(523); 

alter table scheduler$_event_log
modify destination varchar2(261);

alter table scheduler$_job_run_details
modify destination varchar2(261);

alter table scheduler$_step
modify destination varchar2(261);

alter table scheduler$_step
modify queue_agent varchar2(523);

alter table scheduler$_step_state
modify destination varchar2(261);

alter table scheduler$_file_watcher
modify destination varchar2(261);

alter table scheduler$_filewatcher_resend
modify destination varchar2(261);

alter table scheduler$_job_destinations
modify destination varchar2(261);

alter table job$ modify (cur_ses_label RAW(255),
                         CLEARANCE_HI RAW(255),
                         CLEARANCE_LO RAW(255));

alter table system.scheduler_program_args_tbl modify 
  program_name varchar2(128);

alter table system.scheduler_program_args_tbl modify 
  owner varchar2(128);

alter table sys.scheduler$_srcq_map drop constraint 
  scheduler$_srcq_map_pk;

alter table sys.scheduler$_srcq_map modify 
  rule_name varchar2(523);

alter table sys.scheduler$_srcq_map add constraint
  scheduler$_srcq_map_pk primary key (oid, rule_name);

Rem *************************************************************************
Rem End Changes to scheduler for long id project
Rem *************************************************************************


Rem *************************************************************************
Rem Begin changes for advisor framework 
Rem *************************************************************************
Rem 
Rem Bug: 19556283: dba_advisor_directives and user_advisor_directives views 
Rem      were introduced in 10.1 and then replaced/renamed in 10.2 by/to other  
Rem      to dba_advisor_dir_xxx views, but not dropped in the upgrade script.
Rem      Changes were made by transaction  gssmith_directives/7. 
Rem 
-- drop the dba/user views 
drop view dba_advisor_directives;
drop view user_advisor_directives;

-- drop the corresponding public synonyms 
drop public synonym dba_advisor_directives;
drop public synonym user_advisor_directives;

Rem add new parameters to existing tasks. Note that the definition 
Rem of these parameters will be added later during upgrade 
Rem when dbms_advisor.setup_repository is called. 

BEGIN

  -- Proj #47346: In 12.2, we added a new parameter _USE_STATS_ADVISOR to enable
  -- or disable the statistics advisor leg in SQL Tuning.
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, '_USE_STATS_ADVISOR', 'UNUSED', 2,  9 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Tuning Advisor' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = '_USE_STATS_ADVISOR'))#';

  -- bug #9853147
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'NUM_ROWS_TO_FETCH', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'NUM_ROWS_TO_FETCH'))#';

  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'EXECUTE_TRIGGERS', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'EXECUTE_TRIGGERS'))#';

  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'REPLACE_SYSDATE_WITH', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'REPLACE_SYSDATE_WITH'))#';

  -- bug 23137623: add parameters for SPM evolve advisor tasks
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'ALTERNATE_PLAN_LIMIT', 'UNUSED', 1,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SPM Evolve Advisor' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'ALTERNATE_PLAN_LIMIT'))#';

  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'ALTERNATE_PLAN_SOURCE', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SPM Evolve Advisor' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'ALTERNATE_PLAN_SOURCE'))#';

  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'ALTERNATE_PLAN_BASELINE', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SPM Evolve Advisor' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'ALTERNATE_PLAN_BASELINE'))#';

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

Rem *************************************************************************
Rem end changes for advisor framework 
Rem *************************************************************************


Rem Bug17765342 add row archival
exec dbms_hs.replace_base_caps(6019, 6019, 'alter session set archival row visibility = ...');


Rem *************************************************************************
Rem Begin Drop view ku$_12_1_index_view for LRG 13217417
Rem *************************************************************************

drop view ku$_12_1_index_view;

Rem *************************************************************************
Rem End Drop view ku$_12_1_index_view for LRG 13217417
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 18843669: upgrade for patitioned tables with bad metadata
Rem *************************************************************************
update partobj$ po 
  set flags = flags + 32
  where bitand(flags, 32) = 0
    and exists (select * from cdef$ c
                where c.robj# = po.obj# and bitand(c.defer, 512) != 0);
commit;
Rem *************************************************************************
Rem End Bug 18843669: upgrade for patitioned tables with bad metadata
Rem *************************************************************************

Rem *************************************************************************
Rem Begin Bug 20606723: upgrade for patitioned read only tables
Rem *************************************************************************
update partobj$ po
  set po.flags = po.flags+ 65536
  where po.obj# in (select t.obj# from tab$ t where bitand(t.trigflag, 2097152)!=0)
    and bitand(po.flags, 65536) = 0;

update tabpart$ tp
  set tp.flags = tp.flags + 67108864
  where tp.obj# in (select t.obj# from tab$ t where bitand(t.trigflag, 2097152)!=0)
    and bitand(tp.flags, 67108864) = 0;

update tabsubpart$ tsp
  set tsp.flags = tsp.flags + 67108864
  where tsp.obj# in (select t.obj# from tab$ t where bitand(t.trigflag, 2097152)!=0)
    and bitand(tsp.flags, 67108864) = 0;

commit;
Rem *************************************************************************
Rem End Bug 20606723: upgrade for patitioned read only tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to sqlobj$plan and sql_plan_row_type
Rem *************************************************************************

alter table sqlobj$plan modify category VARCHAR2(128);

Rem *************************************************************************
Rem END Changes to sqlobj$plan and sql_plan_row_type
Rem *************************************************************************

Rem =======================================================================
Rem Begin Online Redefinition 12.2 Proj#39358 ROLLBACK changes
Rem =======================================================================

Rem Create backup of redef_object$(used during dbms_redefinition.rollback)
create table redef_object_backup$ as select * from redef_object$
/

Rem Create an index for speedy lookup
create index i_redef_object_backup$ on
 redef_object_backup$(redef_id, obj_type, obj_owner, obj_name)
/

Rem =======================================================================
Rem End Online Redefinition 12.2 Proj#39358 ROLLBACK changes
Rem =======================================================================

Rem =======================================================================
Rem  Begin 12.2 Changes for Multi-language debugging
Rem =======================================================================
BEGIN
  INSERT INTO SYSTEM_PRIVILEGE_MAP(PRIVILEGE,NAME,PROPERTY)
  VALUES (-240, 'DEBUG CONNECT ANY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP(OPTION#,NAME,PROPERTY)
  VALUES (240, 'DEBUG CONNECT ANY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
Rem =======================================================================
Rem  End 12.2 Changes for Multi-language debugging
Rem =======================================================================

Rem ************************************************************************* 
Rem  Begin New Lost Write feature - Bug 13539672/Project 41272
Rem
Rem      For the 12.2 Server and higher these system tables track the
Rem      offsets in the shadow tablespace/datafile that contain SCNs of blocks
Rem      from other datafiles that were written. Upon
Rem      reading a block in any other datafile we can compare the SCN
Rem      in that block with the SCN that was stored in the shadow datafile
Rem      and if the SCN in the block is less than the shadow datafile's
Rem      copy this indicates a lost write.
Rem 
Rem  See file dmanage.bsq for more information.
Rem **************************************************************************
CREATE TABLE new_lost_write_datafiles$
(
  datafile_tsid_tracked     NUMBER,
  datafile_rfn_tracked        NUMBER,
  shadow_datafile_tsid        NUMBER,
  shadow_datafile_rfn         NUMBER,
  shadow_datafile_offset      NUMBER,
  number_of_blocks_allocated  NUMBER,
  datafile_current_status     VARCHAR2(10) NOT NULL
)
  TABLESPACE sysaux
/
CREATE UNIQUE INDEX i_datafile_new_lost_wrt$_pkey ON
  new_lost_write_datafiles$ (datafile_tsid_tracked, datafile_rfn_tracked)
  TABLESPACE sysaux
/
Rem =========================================================================
Rem      new_lost_write_extents$ contains a list of free extents in all the
Rem      shadow datafiles defined.
Rem =========================================================================
CREATE TABLE new_lost_write_extents$
(
  extent_datafile_rfn         NUMBER,  /* set to 0 if no shadow datafile   */
  extent_datafile_tsid        NUMBER,  /* tablespace ID                    */
  extent_start                NUMBER,  /* start of this free extent */
  extent_length_blocks_2K     NUMBER,  /* num of blocks in this free extent -
                                         * using 2K blocks - always a multiple
                                         * of 16 */
  extent_next_block           NUMBER   /* next block after this extent; used
                                         * for combining free extents */
)
 TABLESPACE sysaux
/
CREATE INDEX i_new_lost_write_extents$ ON
  new_lost_write_extents$ (extent_length_blocks_2K)
  TABLESPACE sysaux
/
Rem ========================================================================
Rem      new_lost_write_shadows$ describes all the lost write shadow
Rem      tablespaces. These are bigfile tablespaces so have only one
Rem      datafile.
Rem ========================================================================
CREATE TABLE new_lost_write_shadows$
(
  shadow_datafile_rfn         NUMBER,
  shadow_datafile_tsid        NUMBER,  /* tablespace ID                      */
  shadow_number_blocks_alloc  NUMBER,  /* total number of blocks currently
                                         * in file including the unused bitmap
                                         * not 2K blocksize                   */
  shadow_first_free_block     NUMBER,  /* first available block; after bitmap*/
  shadow_block_size_bytes     NUMBER,  /* block size in this tablespace      */   shadow_recs_per_block       NUMBER   /* number of records per block        */
)
  TABLESPACE sysaux
/
Rem =======================================================================
Rem  12.2 proj 45826: changes to smb$config
Rem =======================================================================

ALTER TABLE smb$config ADD parameter_data CLOB;

DECLARE 
  empty_filters VARCHAR2(30) := '<filters></filters>';
BEGIN
  INSERT INTO smb$config VALUES
    ('AUTO_CAPTURE_PARSING_SCHEMA_NAME', 0, NULL, NULL, empty_filters);
  INSERT INTO smb$config VALUES
    ('AUTO_CAPTURE_MODULE', 0, NULL, NULL, empty_filters);
  INSERT INTO smb$config VALUES
    ('AUTO_CAPTURE_ACTION', 0, NULL, NULL, empty_filters);
  INSERT INTO smb$config VALUES
    ('AUTO_CAPTURE_SQL_TEXT', 0, NULL, NULL, empty_filters); 
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/


Rem =======================================================================
Rem End 12.2 proj 45826: changes to smb$config
Rem =======================================================================

Rem *************************************************************************
Rem END New lost write feature
Rem *************************************************************************

Rem =========================================================================
Rem Begin Changes to PROPS$
Rem =========================================================================

-- Insert the DICTIONARY_ENDIAN_TYPE property indicating the endian-type
-- of the data dictionary. This is derived from the creation platform id
-- in the file header of the first data file in the system tablespace. 
-- Failing this, the endian type of the current platform is used.
-- The first datafile in the system tablespace has a relative file number 
-- of 1 (for a small tablespace) or 1024 (for a big tablespace).

declare
   cnt        number;     
   endian     varchar2(7);
begin
   select count(*) into cnt from props$
   where name = 'DICTIONARY_ENDIAN_TYPE';
   if cnt > 0 then
      delete from props$
      where name = 'DICTIONARY_ENDIAN_TYPE';
   end if;
   begin
      select
         case endian_format
            when 'Little' then 'LITTLE'
            when 'Big' then 'BIG'
            else 'UNKNOWN'
         end
      into endian
      from v$transportable_platform tp, X$KCVFH fh
      where    tp.platform_id = fh.FHCPLID 
         and   fh.FHTSN = 0 
         and   (fh.FHRFN = 1 or fh.FHRFN = 1024)
         and   fh.CON_ID = SYS_CONTEXT ('USERENV', 'CON_ID');
   exception
      when no_data_found then
         select
            case endian_format
               when 'Little' then 'LITTLE'
               when 'Big' then 'BIG'
               else 'UNKNOWN'
            end
         into endian
         from v$transportable_platform tp, v$database db
         where tp.platform_id = db.platform_id;
   end;   
   insert into props$ (name, value$, comment$)
       (select 'DICTIONARY_ENDIAN_TYPE', endian,
               'Endian type of the data dictionary' from dual
        where 'DICTIONARY_ENDIAN_TYPE' NOT IN
        (select name from props$ where name =  'DICTIONARY_ENDIAN_TYPE'));
   commit;
end;
/

Rem =========================================================================
Rem End Changes to PROPS$
Rem =========================================================================

Rem *************************************************************************
Rem BEGIN Bug 20267662: increase maximum plan line size
Rem *************************************************************************

-- Drop types so they can be recreated without versions in catplan.sql
DROP TYPE dbms_xplan_type_table;
DROP TYPE dbms_xplan_type;

Rem *************************************************************************
Rem END Bug 20267662: increase maximum plan line size
Rem *************************************************************************

Rem *************************************************************************
Rem Service layer related changes - BEGIN
Rem *************************************************************************

alter table service$ add (stop_option number);
alter table service$ add (failover_restore number);
alter table service$ add (drain_timeout number);

Rem *************************************************************************
Rem Service layer related changes - END
Rem *************************************************************************


Rem *************************************************************************
Rem cdb_file$, cdb_ts$ related changes - BEGIN
Rem *************************************************************************

alter table cdb_file$ add (ts# number);
alter table cdb_file$ add (relfile# number);
alter table cdb_file$ add (cscnwrp number);
alter table cdb_file$ add (cscnbas number);
alter table cdb_file$ add (spare5 varchar2(1000));
alter table cdb_file$ add (spare6 date);
alter table cdb_file$ add (src_afn number);
alter table cdb_file$ add (tgt_afn number);
alter table cdb_file$ add (status number);
alter table cdb_file$ add (flags number);
alter table cdb_file$ add (blks number);
alter table cdb_file$ add (spare7 number);
alter table cdb_file$ add (spare8 number);
alter table cdb_file$ add (spare9 number);
alter table cdb_file$ add (spare10 number);
alter table cdb_file$ add (spare11 varchar2(128));
alter table cdb_file$ add (spare12 varchar2(128));

REM This table stores plug attributes for tablespaces in a consolidated db
create table cdb_ts$                        /* ts table in a consolidated db */
(
  ts#           number not null,                        /* tablespace number */
  name          varchar2(128) not null,                /* name of tablespace */
  con_id#       number not null,                             /* container ID */
  status$       number not null,                        /* tablespace status */
  cscnwrp       number not null,                           /* createscn wrap */
  cscnbas       number not null,                           /* createscn base */
  filecnt       number not null,             /* file count during pdb plugin */
  flags         number not null,                         /* additional flags */
  ptype         number not null,                   /* tablespace plugin type */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        number,                                             /* spare */
  spare5        varchar2(1000)                                      /* spare */
)
/

CREATE UNIQUE INDEX i_cdbts1 ON cdb_ts$(ts#, con_id#)
/

Rem *************************************************************************
Rem cdb_file$, cdb_ts$ related changes - END
Rem *************************************************************************


Rem *************************************************************************
Rem Materialized view layer related changes - BEGIN
Rem *************************************************************************

alter table mv_refresh_usage_stats$ add seq# number default 0 not null;

Rem Drop types in case they have been upgraded from 11.1
Rem Types will be recreated with FORCE in catsnap.sql

DROP TYPE SYS.RewriteArrayType;
DROP TYPE SYS.RewriteMessage;

DROP TYPE SYS.CanSyncRefArrayType;
DROP TYPE SYS.CanSyncRefMessage;

Rem *************************************************************************
Rem Materialized view layer related changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 17854208: Add diagnostic columns to SQL translation table
Rem *************************************************************************

alter table sqltxl_sql$ add (errcode# number);
alter table sqltxl_sql$ add (errsrc number);
alter table sqltxl_sql$ add (txlmthd number);
alter table sqltxl_sql$ add (dictid varchar2(13));

Rem *************************************************************************
Rem END Bug 17854208
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj# 57436
Rem *************************************************************************

alter table wri$_optstat_synopsis_head$ drop column spare2;

alter table wri$_optstat_synopsis_head$ add spare2 blob;

Rem *************************************************************************
Rem END Proj# 57436
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 20652654: 12.2 LIDENT:Inc name column for feature usage tables
Rem *************************************************************************

alter table wri$_dbu_feature_usage modify name varchar2(128);
alter table wri$_dbu_feature_metadata modify name varchar2(128);
alter table wri$_dbu_high_water_mark modify name varchar2(128);
alter table wri$_dbu_hwm_metadata modify name varchar2(128);

Rem *************************************************************************
Rem END Bug 20652654
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes related to Project 45958 - ADO for DBIM 
Rem *************************************************************************


create sequence sys.ado_imcseq$ increment by 1 start with 1 nocycle;

alter table sys.heat_map_stat$ add n_write number;
alter table sys.heat_map_stat$ add n_fts number;
alter table sys.heat_map_stat$ add n_lookup number;

/* add a new column to ilmpolicy$ */
alter table sys.ilmpolicy$ add pol_subtype number default 0;
alter table sys.ilmpolicy$ add actionc_clob clob;
alter table sys.ilmpolicy$ add tier_to number;

/* fix up tier_to for on-disk ADO tiering policies */
begin
  execute immediate 'update sys.ilmpolicy$ set tier_to = 0 where tier_tbs is not null';
  commit;
exception when others then
  if (sqlcode = -942) then
    null;
  else
    raise;
  end if;
end;
/

Rem *************************************************************************
Rem END Changes related to Project 45958 - ADO for DBIM
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj 47082:  External tables(EXTERNAL MODIFY clause and
Rem                    Partitioned external table support)
Rem *************************************************************************

alter table external_tab$ modify default_dir varchar2(128) null;
alter table external_tab$ modify type$ varchar2(128) null;

Rem *************************************************************************
Rem END Proj 47082:  External tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Proj 58950,42356-3: New INMEMORY syntax - FOR SERVICE, ORDER BY
Rem *************************************************************************
REM This table stores attributes related to INMEMORY DISTRIBUTE FOR SERVICE
REM Key is <objn> or <file,block>
create table imsvc$ (
  obj#       number not null,                             /* object number */
  subpart#   number,            /*   subpartition number:                  */
                                /*    non null for subpartition templates, */
                                /*    null otherwise                       */
  dataobj#   number,                           /* data layer object number */
  file#      number,                         /* segment header file number */
  block#     number,                        /* segment header block number */
  ts#        number,                                  /* tablespace number */
  svcflags   number,                            /* distribute service type */
  svcname    varchar2(1000),                    /* distribute service name */
  spare1     number,                                              /* spare */
  spare2     number,                                              /* spare */
  spare3     varchar2(1000),                                      /* spare */
  spare4     varchar2(1000),                                      /* spare */
  spare5     date                                                 /* spare */
) 
/
create index i_imsvc1 on imsvc$(obj#,subpart#)
/

REM This table stores attributes related to INMEMORY DISTRIBUTE FOR SERVICE
REM for tablespaces.
REM Key is <ts#>
create table imsvcts$ (
  ts#        number,                                  /* tablespace number */
  svcflags   number,                            /* distribute service type */
  svcname    varchar2(1000),                    /* distribute service name */
  spare1     number,                                              /* spare */
  spare2     number,                                              /* spare */
  spare3     number,                                              /* spare */
  spare4     number,                                              /* spare */
  spare5     varchar2(1000),                                      /* spare */
  spare6     varchar2(1000),                                      /* spare */
  spare7     date                                                 /* spare */
) 
/
create index i_imsvcts1 on imsvcts$(ts#)
/

REM This table stores metadata related to INMEMORY ORDER BY clause
create table imorderby$ (
  obj#       number not null,                             /* object number */
  bo#        number,                                 /* base object number */
  file#      number,                         /* segment header file number */
  block#     number,                        /* segment header block number */
  ts#        number,                                  /* tablespace number */
  intcol#    number not null,                        /* user column number */
  position   number not null,         /* position of column in IMOB clause */
  spare1     number,                                              /* spare */
  spare2     number,                                              /* spare */
  spare3     number,                                              /* spare */
  spare4     number,                                              /* spare */
  spare5     varchar2(1000),                                      /* spare */
  spare6     varchar2(1000),                                      /* spare */
  spare7     date                                                 /* spare */
)
/
Rem *************************************************************************
Rem END Proj 58950,42356-3: New INMEMORY syntax - FOR SERVICE, ORDER BY
Rem *************************************************************************

Rem *************************************************************************
Rem pdb_create$ changes  - BEGIN
Rem *************************************************************************
REM This table stores pdb create sql statement in CDB$ROOT
create table pdb_create$                   /* pdb creates in consolidated db */
(
  con_id#       number not null,                             /* container ID */
  con_uid       number not null,                            /* container UID */
  sqlstmt       clob,                                       /* sql statement */
  plugxml       blob,                                            /* plug XML */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(4000)
)
/

Rem *************************************************************************
Rem pdb_create$ changes  - END
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN bug 20867498: long ids

ALTER TABLE wri$_sts_granules MODIFY sqlset_owner VARCHAR2(128);

ALTER TABLE wrh$_iostat_function_name MODIFY function_name VARCHAR2(128);

Rem END bug 20867498: long ids
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 21497629: long ids

ALTER TABLE wrh$_buffered_queues
  MODIFY queue_schema VARCHAR2(128)
  MODIFY queue_name   VARCHAR2(128)
;
ALTER TABLE wrh$_rsrc_consumer_group
  MODIFY consumer_group_name VARCHAR2(128)
;
ALTER TABLE wri$_adv_def_parameters
  MODIFY name      VARCHAR2(128)
  MODIFY exec_type VARCHAR2(128)
;
ALTER TABLE wri$_adv_def_exec_types
  MODIFY name VARCHAR2(128)
;
ALTER TABLE wri$_adv_executions
  MODIFY name      VARCHAR2(128)
  MODIFY exec_type VARCHAR2(128)
;
ALTER TABLE wri$_sqlset_definitions
  MODIFY name  VARCHAR2(128)
  MODIFY owner VARCHAR2(128)
;
ALTER TABLE wri$_sqlset_statements
  MODIFY parsing_schema_name VARCHAR2(128)
;
ALTER TABLE wri$_sqlset_plans
  MODIFY parsing_schema_name VARCHAR2(128)
;
ALTER TABLE wri$_sqlset_plan_lines
  MODIFY statement_id VARCHAR2(128)
  MODIFY operation    VARCHAR2(128)
  MODIFY object_owner VARCHAR2(128)
  MODIFY object_name  VARCHAR2(128)
  MODIFY object_alias VARCHAR2(261)
  MODIFY object_type  VARCHAR2(128)
  MODIFY distribution VARCHAR2(128)
  MODIFY qblock_name  VARCHAR2(128)
;
Rem END bug 21497629: long ids
Rem *************************************************************************

rem Proj 47117
drop index pk_rmtab$;
create table online_hidden_frags$
(
  sobj#  number not null,               /* object number of source fragment */
  tobj#  number not null                /* object number of hidden fragment */
)
/
rem end Proj 47117

Rem ========================================================================
Rem Update type metada TDSs for long identifier
Rem ========================================================================

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PROCEDURE update_typemetadata_TDS IS
LANGUAGE C
NAME "UPG_FROM_121"
LIBRARY UPGRADE_LIB;
/

execute update_typemetadata_TDS();
commit;
alter system flush shared_pool;
drop procedure update_typemetadata_TDS;

REM *************************************************************************
REM Begin Bug 21693228: Update implobj# on indtypes$ to the most recent
REM version of the type specification
REM Bug 26731573: Handle the case where there is another type with
REM the same name in another schema

DECLARE
  CURSOR indtype_data IS
    SELECT u.user#, it.obj#, it.implobj#
      FROM sys.indtypes$ it,
           sys.obj$ o,
           sys.user$ u
     WHERE o.owner# = u.user#
       AND o.obj# = it.implobj#;

  owner_id NUMBER;
  indtype_num NUMBER;
  impl_num NUMBER;
  type_name VARCHAR2(4000);
  impl_count NUMBER;
  latest_impl_num NUMBER;
BEGIN
  OPEN indtype_data;

  LOOP
    FETCH indtype_data INTO owner_id, indtype_num, impl_num;
    EXIT WHEN indtype_data%NOTFOUND;

    -- Get name of implementation object
    SELECT name INTO type_name
      FROM sys.obj$
     WHERE obj# = impl_num;

    -- Get all implementation objects (type specification)
    SELECT count(obj#) INTO impl_count
      FROM sys.obj$
     WHERE type# = 13
       AND name = type_name
       AND owner# = owner_id;

    -- If there is more than one implementation...
    IF impl_count > 1 THEN
      -- Get the most recent implementation
      SELECT obj# INTO latest_impl_num
        FROM sys.obj$
       WHERE type# = 13
         AND name = type_name
         AND subname IS NULL
         AND owner# = owner_id;

      -- Update implobj# on indtypes$
      UPDATE indtypes$ SET implobj# = latest_impl_num
       WHERE obj# = indtype_num;
    END IF;
  END LOOP;

  CLOSE indtype_data;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  -- Make sure we close the cursor in case of error
  IF indtype_data%ISOPEN THEN
    CLOSE indtype_data;
  END IF;
  -- Raise the error now
  RAISE;
END;
/

REM End Bug 21693228
REM *************************************************************************

Rem *************************************************************************
Rem DROP ODCI types that have been evolved in prior upgrades.  New versions
Rem will be created by catodci.sql with FORCE
Rem *************************************************************************

-- Drop with FORCE the ODCI types versioned in upgrade to 12.1
DROP TYPE ODCIARGDESC FORCE;
DROP TYPE ODCIARGDESCLIST FORCE;
DROP TYPE ODCICOLINFO FORCE;
DROP TYPE ODCICOLINFOLI FORCE;
DROP TYPE ODCICOLINFOLIST FORCE;
DROP TYPE ODCICOMPQUERYINFO FORCE;
DROP TYPE ODCIFILTERINFO FORCE;
DROP TYPE ODCIFILTERINFOLIST FORCE;
DROP TYPE ODCIFUNCCALLINFO FORCE;
DROP TYPE ODCIFUNCINFO FORCE;
DROP TYPE ODCIINDEXCTX FORCE;
DROP TYPE ODCIINDEXINFO FORCE;
DROP TYPE ODCIOBJECT FORCE;
DROP TYPE ODCIOBJECTLIST FORCE;
DROP TYPE ODCIORDERBYINFO FORCE;
DROP TYPE ODCIORDERBYINFOLIST FORCE;
DROP TYPE ODCIPARTINFO FORCE;
DROP TYPE ODCIPARTINFOLIST FORCE;
DROP TYPE ODCIPREDINFO FORCE;
DROP TYPE ODCIQUERYINFO FORCE;
DROP TYPE ODCIEXTTABLEINFO FORCE;


Rem *************************************************************************
Rem Bug 19624713: Drop some old DBA_* views and their synonyms as they are
Rem no longer used. Also drop corresponding CDB_* views since these might
Rem have been created during a 12.1.0.1 upgrade.
Rem *************************************************************************
drop view DBA_CL_DIR_INSTANCE_ACTIONS;
drop view DBA_DB_DIR_ESCALATE_ACTIONS;
drop view DBA_DB_DIR_QUIESCE_ACTIONS;
drop view DBA_DB_DIR_SERVICE_ACTIONS;
drop view DBA_DB_DIR_SESSION_ACTIONS;
drop view DBA_DIR_DATABASE_ATTRIBUTES;
drop view DBA_DIR_VICTIM_POLICY;
drop view DBA_SOURCE_TAB_COLUMNS;
drop view CDB_CL_DIR_INSTANCE_ACTIONS;
drop view CDB_DB_DIR_ESCALATE_ACTIONS;
drop view CDB_DB_DIR_QUIESCE_ACTIONS;
drop view CDB_DB_DIR_SERVICE_ACTIONS;
drop view CDB_DB_DIR_SESSION_ACTIONS;
drop view CDB_DIR_DATABASE_ATTRIBUTES;
drop view CDB_DIR_VICTIM_POLICY;
drop view CDB_SOURCE_TAB_COLUMNS;
drop public synonym DBA_SOURCE_TAB_COLUMNS;
drop public synonym DBA_CL_DIR_INSTANCE_ACTIONS;
drop public synonym DBA_DB_DIR_ESCALATE_ACTIONS;
drop public synonym DBA_DB_DIR_QUIESCE_ACTIONS;
drop public synonym DBA_DB_DIR_SERVICE_ACTIONS;
drop public synonym DBA_DB_DIR_SESSION_ACTIONS;
drop public synonym DBA_DIR_DATABASE_ATTRIBUTES;
drop public synonym DBA_DIR_VICTIM_POLICY;
drop public synonym CDB_SOURCE_TAB_COLUMNS;
drop public synonym CDB_CL_DIR_INSTANCE_ACTIONS;
drop public synonym CDB_DB_DIR_ESCALATE_ACTIONS;
drop public synonym CDB_DB_DIR_QUIESCE_ACTIONS;
drop public synonym CDB_DB_DIR_SERVICE_ACTIONS;
drop public synonym CDB_DB_DIR_SESSION_ACTIONS;
drop public synonym CDB_DIR_DATABASE_ATTRIBUTES;
drop public synonym CDB_DIR_VICTIM_POLICY;

Rem *************************************************************************
Rem Materialized views - BEGIN
Rem *************************************************************************

update sys.snap$ set flag4 = 0 where flag4 is null;

Rem *************************************************************************
Rem Materialized views - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 20663978
Rem *************************************************************************

alter table wri$_adv_recommendations add (rec_type_id number);

Rem *************************************************************************
Rem END Bug 20663978
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Bug 21757266
Rem *************************************************************************

drop public synonym CDB_SECUREFILE_LOGS;
drop public synonym CDB_SECUREFILE_LOG_INSTANCES;
drop public synonym CDB_SECUREFILE_LOG_PARTITIONS;
drop public synonym CDB_SECUREFILE_LOG_TABLES;
drop public synonym CDB_TAB_COLS_V$;

Rem *************************************************************************
Rem END Bug 21757266
Rem *************************************************************************

Rem =======================================================================
Rem Bug 19651064 - Make WRH$_SYSMETRIC_HISTORY partitioned table
Rem =======================================================================

drop index TMP_SYSMETRIC_HISTORY_INDEX;
drop table TMP_SYSMETRIC_HISTORY;

-- Turn off partition check
alter session set events  '14524 trace name context forever, level 1';

alter index WRH$_SYSMETRIC_HISTORY_INDEX rename to TMP_SYSMETRIC_HISTORY_INDEX;
alter table WRH$_SYSMETRIC_HISTORY rename to TMP_SYSMETRIC_HISTORY;

-- Turn on partition check
alter session set events  '14524 trace name context off';

Rem =======================================================================
Rem Bug 19651064 - End
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN pdb_stat$, pdb_svc_state$ related changes
Rem *************************************************************************

REM This table stores metadata related to PDB system statistics
create table pdb_stat$ (
  con_uid#    number not null,                       /* Unique ID of the PDB */
  inst_id     number not null,                                /* instance id */
  inst_name   varchar2(128),                                /* instance name */
  stat_name   varchar2(128) not null,        /* name of the system statistic */
  stat_value  number not null,                         /* value of statistic */
  spare1      number,                                               /* spare */
  spare2      number,                                               /* spare */
  spare3      number,                                               /* spare */
  spare4      number,                                               /* spare */
  spare5      varchar2(4000),                                       /* spare */
  spare6      varchar2(4000)                                        /* spare */
)
/

CREATE UNIQUE INDEX i_pdbstat1 ON pdb_stat$(con_uid#, inst_name, stat_name)
/

REM This table stores metadata related to status of PDB services
create table pdb_svc_state$ (
  inst_id       number not null,                              /* instance id */
  inst_name     varchar2(128),                              /* instance name */
  pdb_guid      RAW(16),                                         /* pdb guid */
  pdb_uid       number not null,                            /* pdb unique ID */
  svc_hash      number not null,                             /* service hash */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        number,                                             /* spare */
  spare5        varchar2(4000),                                     /* spare */
  spare6        varchar2(4000)                                      /* spare */
)
/

CREATE UNIQUE INDEX i_pdbsvcstate1 
 ON pdb_svc_state$(inst_name, pdb_guid, svc_hash)
/

Rem *************************************************************************
Rem END pdb_stat$, pdb_svc_state$ related changes
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 18569453
Rem
Rem Cursor duration types that are left invalid used to be called SYSTP% in
Rem 11.2 but from 12.1 are now called ST00%. So at this point we can delete
Rem invalid cursor duration types:
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
           and o.name like 'SYSTP%';           /* Name prefix before 12.1 */
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
Rem END RTI 18569453
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Bug 22275536: debug connect audit option
Rem =======================================================================
BEGIN
  INSERT INTO STMT_AUDIT_OPTION_MAP(OPTION#,NAME,PROPERTY)
  VALUES (367, 'DEBUG CONNECT', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
Rem =======================================================================
Rem  End Bug 22275536
Rem =======================================================================

Rem =======================================================================
Rem Begin 22608480
Rem =======================================================================

grant read on stmt_audit_option_map to public;
grant read on system_privilege_map to public;
grant read on table_privilege_map to public;
grant read on user_privilege_map to public;

Rem =======================================================================
Rem End 22608480
Rem =======================================================================

Rem *************************************************************************
Rem User Privileges related changes for 12.2 - BEGIN
Rem *************************************************************************

BEGIN
  insert into USER_PRIVILEGE_MAP values (3, 'DEBUG CONNECT');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
COMMIT;

Rem *************************************************************************
Rem User Privileges related changes for 12.2 - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 18548742
Rem Drop check_test_internal, which exists only in 12.1.0.1 patch sets
Rem *************************************************************************

drop function check_test_internal;

Rem *************************************************************************
Rem END RTI 18548742
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 21097449
Rem *************************************************************************

alter table DBMS_PARALLEL_EXECUTE_CHUNKS$ DROP PRIMARY KEY;
alter table DBMS_PARALLEL_EXECUTE_CHUNKS$ ADD CONSTRAINT I_DBMS_PARALLEL_EXECUTE_CHUNK1 PRIMARY KEY (chunk_id);

Rem *************************************************************************
Rem END BUG 21097449
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 21239547
Rem *************************************************************************

begin
  execute immediate 'revoke inherit privileges on user SYS from dbsnmp';
exception
  when others then 
    if sqlcode in (-1917,-1918,-1927,-1951,-1952)
      then null;
    else 
      raise;
    end if;
end;
/

Rem *************************************************************************
Rem END BUG 21239547
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN cdb_props$ changes
Rem *************************************************************************

REM This table stores certain database properties in a CDB
create table cdb_props$
( con_uid#      number,                              /* unique ID of the PDB */
  name          varchar2(128) not null,                     /* property name */
  value$        varchar2(4000),                            /* property value */
  comment$      varchar2(4000),                   /* description of property */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        varchar2(4000),                                     /* spare */
  spare4        varchar2(4000)                                      /* spare */
)
/

Rem *************************************************************************
Rem END cdb_props$ changes
Rem *************************************************************************

Rem =======================================================================
Rem  Begin 12.2 Changes for Project 57189 Inherit Remote Privileges 
Rem =======================================================================

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP
    values (-365, 'INHERIT ANY REMOTE PRIVILEGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into USER_PRIVILEGE_MAP values (2, 'INHERIT REMOTE PRIVILEGES');
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (365, 'INHERIT ANY REMOTE PRIVILIGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
BEGIN
  insert into STMT_AUDIT_OPTION_MAP
    values (366, 'INHERIT REMOTE PRIVILIGES', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/
COMMIT;
Rem =======================================================================
Rem  End 12.2 Changes for Project 57189 Inherit Remote Privileges 
Rem =======================================================================

Rem *************************************************************************
Rem BEGIN BUG 22367092 create svcobj*$ tables
Rem *************************************************************************
Rem table to store service state persistently

drop table svcobj$;
create table svcobj$
(
  name               varchar2(64),                             /* short name */
  active             number,                                        /* state */
  change_incno       number,  /* inc number at the time of last state change */
  CONSTRAINT         idx1_svcobj$
                     PRIMARY KEY (name)
)
organization index tablespace sysaux
/

Rem table to store service access stats persistently

drop table svcobj_access$;
create table svcobj_access$
(
  name               varchar2(64),                             /* short name */
  pdb                number,                                          /* pdb */
  tsn                number,                                          /* tsn */
  objid              number,                                       /* obj id */
  accesses           number,                                 /* avg accesses */
  inc_no             number,
  CONSTRAINT         idx1_svcobj_access$
                     PRIMARY KEY (name, pdb, tsn, objid)
)
organization index tablespace sysaux
/

Rem table to store service access stats attributes persistently
create table svcobj_access_attr$
(
  attr               number,
  value              number
)
tablespace sysaux
/

Rem initialize on disk incarnation number to 1
insert into svcobj_access_attr$(attr, value) values(1, 1);

Rem *************************************************************************
Rem END BUG 22367092
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 22682473 reduced privileges for map_object
Rem *************************************************************************
revoke all on map_object from dba;
grant select, insert, update, delete on map_object to dba;

Rem *************************************************************************
Rem END BUG 22682473
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23207710
Rem *************************************************************************
revoke execute on pstdy_datapump_support from SELECT_CATALOG_ROLE;

Rem *************************************************************************
Rem END BUG 23207710
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN AQ changes for renaming (g)v$aq_opt_* views
Rem *************************************************************************

drop public synonym gv$aq_opt_statistics;
drop view gv_$aq_opt_statistics;
drop public synonym v$aq_opt_statistics;
drop view v_$aq_opt_statistics;

drop public synonym gv$aq_opt_cached_subshard;
drop view gv_$aq_opt_cached_subshard;
drop public synonym v$aq_opt_cached_subshard;
drop view v_$aq_opt_cached_subshard;

drop public synonym gv$aq_opt_uncached_subshard;
drop view gv_$aq_opt_uncached_subshard;
drop public synonym v$aq_opt_uncached_subshard;
drop view v_$aq_opt_uncached_subshard;

drop public synonym gv$aq_opt_inactive_subshard;
drop view gv_$aq_opt_inactive_subshard;
drop public synonym v$aq_opt_inactive_subshard;
drop view v_$aq_opt_inactive_subshard;

Rem *************************************************************************
Rem END AQ changes for renaming (g)v$aq_opt_* views
Rem *************************************************************************

Rem =======================================================================
Rem bug 23248734: drop unsued dbms_sqlplus_script package
Rem =======================================================================

drop package dbms_sqlplus_script;
drop public synonym dbms_sqlplus_script;
drop library dbms_sqlplus_script_lib;

Rem *************************************************************************
Rem END BUG 23248734
Rem *************************************************************************

Rem =======================================================================
Rem Begin: bug 23202142
Rem =======================================================================
revoke execute on sys.dbms_rcvman from select_catalog_role;

Rem =======================================================================
Rem End: bug 23202142
Rem =======================================================================
Rem *************************************************************************
Rem BEGIN BUG 23061990 
Rem *************************************************************************
Rem KKPACOCD_INDCMP_OLTPLOW flag overwrites KKPACOCD_IMC_ENABLED
Rem For indexes, move bit 40 of spare2 to bit 32 of spare3
UPDATE partobj$ SET spare3 = NVL(spare3, 0) + 4294967296,
                    spare2 = spare2 - 1099511627776
                  WHERE obj# IN (SELECT obj# FROM obj$ WHERE type# = 1)
                        AND MOD(TRUNC(spare2/1099511627776), 2) = 1;
COMMIT;
Rem *************************************************************************
Rem END BUG 23061990
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23316483
Rem *************************************************************************
drop procedure preupjavaexit;
drop function preupcreatedir;
Rem *************************************************************************
Rem END BUG 23316483
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 23536767
Rem *************************************************************************
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT, ALTER ON sys.awseq$         FROM dba ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT, DEBUG ON sys.aw$            FROM dba ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE ' REVOKE SELECT, DEBUG ON sys.ps$            FROM dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT, DEBUG ON sys.aw_prop$       FROM dba ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE ' REVOKE SELECT, DEBUG ON sys.aw_obj$        FROM dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT, DEBUG ON sys.aw_track$      FROM dba ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE ' REVOKE SELECT, DEBUG ON sys.olap_tab$      FROM dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE ' REVOKE SELECT, DEBUG ON sys.olap_tab_col$  FROM dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE ' REVOKE SELECT, DEBUG ON sys.olap_tab_hier$ FROM dba';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem *************************************************************************
Rem BEGIN bug 23536767
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23515980
Rem *************************************************************************

DELETE FROM sys.exppkgact$
WHERE schema = 'SYS' AND package IN ('DBMS_CDC_EXPDP', 'DBMS_CDC_EXPVDP');

Rem *************************************************************************
Rem END BUG 23515980
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN bug 23604553 Drop types oracle_loader and oracle_datapump
Rem *************************************************************************

DROP TYPE sys.oracle_loader;
DROP TYPE sys.oracle_datapump;

Rem *************************************************************************
Rem END bug 23604553
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN RTI 19400841
Rem *************************************************************************
drop package dbms_preup;
drop directory preupgrade_dir;

Rem *************************************************************************
Rem END RTI 19400841
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23733162
Rem *************************************************************************

Rem Mark PDB_CREATE$.SQLSTMT as sensitive. This may contain the admin user
Rem password verifiers.

update col$
set property = property + 8796093022208 - bitand(property, 8796093022208)
where name = 'SQLSTMT' and obj# =
(select obj# from obj$ where name = 'PDB_CREATE$'
 and owner# = (select user# from user$ where name = 'SYS')
 and remoteowner is NULL);

Rem Mark PDB_SYNC$.SQLSTMT,LONGSQLTXT as sensitive. These may contain user
Rem password verifiers.

update col$
set property = property + 8796093022208 - bitand(property, 8796093022208)
where name in ('SQLSTMT', 'LONGSQLTXT') and obj# =
(select obj# from obj$ where name = 'PDB_SYNC$'
 and owner# = (select user# from user$ where name = 'SYS')
 and remoteowner is NULL);

COMMIT;

Rem *************************************************************************
Rem END BUG 23733162
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN BUG 23746738 
Rem *************************************************************************

DROP PUBLIC SYNONYM user_privileged;
DROP FUNCTION user_privileged;
DROP FUNCTION unix_ts_to_date;
DROP FUNCTION gethivetable;

Rem *************************************************************************
Rem END BUG 23746738 
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN of Bug 24598595: Mark hist_head$, histgrm$ columns as sensitive.
Rem *************************************************************************

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208)
where name in ('MINIMUM', 'MAXIMUM', 'LOWVAL', 'HIVAL') 
  and obj# =
        (select obj# from obj$ 
         where name = 'HIST_HEAD$'
           and owner# = (select user# from user$ where name = 'SYS')
           and remoteowner is NULL);

update col$ set property = property + 8796093022208 - bitand(property, 8796093022208)
where name in ('ENDPOINT', 'EPVALUE', 'EPVALUE_RAW') 
 and obj# =
       (select obj# from obj$ 
        where name = 'HISTGRM$'
          and owner# = (select user# from user$ where name = 'SYS')
          and remoteowner is NULL);

commit;

Rem *************************************************************************
Rem END of Bug 24598595
Rem *************************************************************************

Rem *************************************************************************
Rem START Bug 25527953: Move flag KTT_HDFS to a different bit
Rem *************************************************************************

update ts$ set flags = flags - 9223372036854775808 + (4294967296 * 4294967296)
where bitand( flags, 9223372036854775808 ) > 0;
commit;

Rem *************************************************************************
Rem END Bug 25527953
Rem *************************************************************************

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

Rem *************************************************************************
Rem BEGIN Bug 23755051
Rem       RTI 20773151: wrap in PL/SQL to force capture for Replay Upgrade
Rem                     as BPs have the object but PSUs and RELEASE don't.
Rem *************************************************************************
BEGIN
  execute immediate 'DROP PROCEDURE dbms_feature_ra_owner';
END;
/
Rem *************************************************************************
Rem END Bug 23755051
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@c1202000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END   c1201000.sql
Rem *************************************************************************
