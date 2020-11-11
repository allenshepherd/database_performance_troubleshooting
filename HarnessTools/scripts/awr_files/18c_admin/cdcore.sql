Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdcore.sql - Catalog DCORE.bsq views
Rem
Rem    DESCRIPTION
Rem      This script invokes a set of subscripts, so that, for backports, the
Rem      complete script does not need to be run.  There are CATCTL annotations
Rem      included so that the scripts can be run in parallel.  However
Rem      to enable the parallel processing, a CATFILE -X annotation must
Rem      be added to the file invocation in catalog.sql.
Rem
Rem    NOTES
Rem      To preserve the capability to use parallel processing, 
Rem      NO SQL statements should be added to this script; they 
Rem      should be added to one of the subscripts.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdcore.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdcore.sql
Rem SQL_PHASE: CDCORE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sshringa    09/08/17 - Adding start/end markers for rti-20225108
Rem    raeburns    04/23/17 - Bug 25825613: Restructure cdcore.sql
Rem                           Add SQL_DRIVER_ONLY: YES
Rem    dblui       04/14/17 - Bug 14835642: stats for adv index compression
Rem    thbaby      04/07/17 - Bug 25836652: use synonym name instead of id
Rem    spetride    03/28/17 - Bug 25768974: add SESSION_FLAG, EXTEND_FLAG,
Rem                           SCALE_FLAG to *_TAB_IDENTITY_COLS
Rem    wesmith     03/25/17 - Bug 25259507: modify IDENTITY_OPTIONS column
Rem                           of *_TAB_IDENTITY_COLS to display KEEP_VALUE
Rem    siyzhang    02/17/17 - Bug 25390238: handle RESET in 
Rem                           DBA_LOCKDOWN_PROFILE
Rem    siyzhang    02/15/17 - Bug 25358106: add template to dictionary table
Rem    prshanth    02/07/17 - Bug 25395134: make dba_lockdown_profiles a
Rem                           regular view.
Rem    rthatte     02/03/17 - Bug 23753068: reduce privileges to AUDIT_ADMIN
Rem    siyzhang    02/02/17 - Bug 25394846: add USERS to DBA_LOCKDOWN_PROFILE
Rem    prshanth    01/22/17 - PROJ 70729: lockdown profile enhancements
Rem    gravipat    12/23/16 - Bug 21902883: Add dba_pdb_snapshots
Rem    rmacnico    12/20/16 - Proj 68495; inmemory external tables
Rem    sankejai    12/06/16 - Bug 21109023: add extra decodes for DBA_PDBS
Rem    siyzhang    10/18/16 - Bug 24912411: Rename COMMON_DATA column to
Rem                           EXTENDED_DATA_LINK
Rem    siteotia    10/18/16 - Project 68493: MEMOPTIMIZE (IMOLTP) DDL Changes.
Rem    joevilla    09/05/16 - Bug 21445715: update catalog tables to show user
Rem                           comments for hcs objects 
Rem    zzeng       08/25/16 - Expand DUPLICATED flag for non-table objects
Rem    prshanth    08/01/16 - Bug 20812121: make plug_in_violations DATA LINK
Rem    prshanth    07/18/16 - Bug 23750190: add columns to LOCKDOWN_PROFILES
Rem    hlili       06/30/16 - bug 23699225: throw error when updating read-only
Rem                           partitioned table
Rem    thbaby      06/20/16 - Bug 22833985: ignore synonym on another synonym
Rem    prshanth    05/19/16 - Bug 23304812: decode lockdown profile obj type
Rem    gravipat    05/17/16 - Add refresh mode and refresh interval to DBA_PDBS
Rem    sursridh    03/11/16 - Bug 21028455: Remove DBA_PBS.FEDERATION_ROOT.
Rem    akruglik    02/29/16 - Bug 22777253: combine INT$CONTAINER_OBJ$ and
Rem                           INT$CONTAINER$ views and mark INT$CONTAINER_OBJ$
Rem                           CONTAINER_DATA
Rem    prshanth    02/18/16 - Bug 22686666: add order by ltime to lkdw profile
Rem    mziauddi    02/15/16 - #(22706389) fix xxx_OBJECTS views for zonemaps
Rem    wesmith     02/08/16 - Bug 22660999: XXX_OBJECTS: show default_collation 
Rem                           for relevant objects
Rem    sankejai    02/06/16 - Bug 22622072: use x$props in database_properties
Rem    makataok    01/31/16 - Bug 22113854: add NO_PUSH_SUBQ hint to
Rem                           _all_synonyms_tree view
Rem    akruglik    03/08/16 - (22132084) replace COMMON_DATA with EXTENDED DATA
Rem    ciyer       01/11/16 - bug 22332196: keep base and _AE views in sync
Rem    thbaby      12/12/15 - Bug 22359004: remove PROXY_PDB_SOURCE_PDB
Rem    mstasiew    12/07/15 - Bug 22309211: OLAP updates
Rem    thbaby      12/07/15 - Bug 22324791: add CREATED_APPID and CREATED_VSNID
Rem    rmacnico    12/01/15 - Bug 22293392: change cachecompress to memcompress
Rem    prshanth    10/23/15 - Bug 21982366: Rename columns of lockdown_profiles
Rem    aditigu     10/22/15 - Bug 21238674: changed key for imsvc$
Rem    sfeinste    10/13/15 - Bug 22008202: HCS name changes
Rem    thbaby      10/08/15 - Bug 21971498: rename View PDB to Proxy PDB
Rem    juilin      22/07/15 - Bug 21458522 rename syscontext IS_FEDERATION_ROOT
Rem    sudurai     09/23/15 - Bug 21805805: Encrypt NUMBER data type in
Rem                           statistics tables
Rem    juilin      09/02/15 - 21485248: rename FEDERATION column to APPLICATION
Rem    thbaby      08/27/15 - 21747323: add CONTAINER_MAP_OBJECT column
Rem    raavudai    08/12/15 - Proj 58196: Use ora_check_sys_privilege 
Rem                           operator to check system privileges.
Rem    thbaby      07/27/15 - bug 21512134: add CONTAINER_MAP column
Rem    thbaby      07/27/15 - bug 21501076: add CONTAINERS_DEFAULT column
Rem    ghicks      07/07/15 - bug 21208995: fix ALL_OBJECTS for HIER objs
Rem    aditigu     07/06/15 - Bug 21437329: add column for inmemory for service
Rem    akruglik    06/30/15 - Get rid of scope column
Rem    esoderst    06/22/15 - Bug #21230047: Add ARIA SEED GOST to views.
Rem    ghicks      06/19/15 - bugs 20481832, 20481863: USER_TAB_PRIVS_MADE and
Rem                           ALL_TAB_PRIVS_MADE
Rem    jaeblee     06/18/15 - add extra status decodes for DBA_PDBS
Rem    prshanth    06/17/15 - Bug 21091902: add VALUE$ to DBA_LOCKDOWN_PROFILES
Rem    akruglik    06/02/15 - Bug 20691564: modify definition of
Rem                           DBA_CONTAINER_DATA to reflect the fact that SYSDG
Rem                           and SYSRAC get to see data across the CDB and
Rem                           that SYS, SYSBACKUP, SYSDG and SYSRAC get to see
Rem                           data across the App Container
Rem    kquinn      05/27/15 - 20992573: Add DB_VERSION_STRING to
Rem                           DBA_PDB_HISTORY
Rem    jcanovi     05/13/15 - 20997166: Check for null columns while checking
Rem                           for binary xml token sets.
Rem    beiyu       04/21/15 - Bug 20549214: + hcs obj previliges in all_objects
Rem    thbaby      04/12/15 - 20869766: hidden cols in CDB_PDBS, CDB_PROPERTIES
Rem    sdoraisw    04/15/14 - proj47082:add EXTERNAL to TABLES family
Rem    jcanovi     03/18/15 - Bug 20730496: Exclude binary xml granular token
Rem                           set objects from catalog views.
Rem    rmacnico    03/15/15 - Proj 47506: CELLCACHE
Rem    prshanth    03/02/15 - Bug 20766944: revert the fix for bug 20618595
Rem    prshanth    03/02/15 - Bug 20618595: use no_common_data for table cons
Rem    gravipat    02/12/15 - Bug 20533616: Add undo_mode_switch_scn,
Rem                           creation_time to dba_pdbs
Rem    gravipat    02/12/15 - Bug 20533616: Add creation_time to dba_pdbs
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    thbaby      01/27/15 - Proj 47234: add FEDERATION_CLONE to DBA_PDBS
Rem    sudurai     01/26/15 - proj 49581 - optimizer stats encryption
Rem    sanbhara    01/21/15 - Bug 19863180,19678993 - updating user_role_privs
Rem                           to not display secure roles in a proxy session
Rem                           and to display rows in RAS proxy sessions.
Rem    prshanth    01/17/15 - Proj 47234: add option$ to lockdown_prof$
Rem    beiyu       01/13/15 - Proj 47091: Add HCS objs to xxx_objects,
Rem                           xxx_TAB_PRIVS, and xxx_TAB_PRIVS_RECD
Rem    akruglik    01/06/15 - Bug 20272756: define int$container_obj$ and use
Rem                           it in definition of dba_container_data
Rem    thbaby      12/03/14 - Proj 47234: Object Linked view over container$
Rem    thbaby      12/03/14 - Proj 47234: fix *_TAB_COMMENTS and *_COL_COMMENTS
Rem    thbaby      12/03/14 - Proj 47234: remove decode from SHARING column
Rem    wesmith     12/02/14 - Project 47511: data-bound collation
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    hegliu      11/24/14 - proj-57973: READ_ONLY will be 'N/A' for
Rem                           partitioned-table
Rem    skayoor     11/17/14 - Proj 58196: Use operator to check system priv
Rem    akruglik    11/05/14 - Project 47234: add SCOPE column to various 
Rem                           privilege views
Rem    prshanth    10/12/14 - Proj 47234: add DBA_LOCKDOWN_PROFILES
Rem    akruglik    09/03/14 - Bug 19525987: add dba_pdbs.upgrade_priority
Rem    akruglik    08/11/14 - LRG 12677313: update definition of dba_pdbs to
Rem                           reflect changes to values of flags indicating
Rem                           that a PDB is a Federation Root or Seed which
Rem                           were made during transaction merge
Rem    thbaby      07/21/14 - Proj 47234: DBA_PDBS columns for view PDB
Rem    pyam        07/16/14 - add FEDERATION column
Rem    akruglik    07/08/14 - Proj 47234: add/modify view defnitions to display
Rem                           Federation info
Rem    thbaby      06/12/14 - 18971004: remove INT$ views for OBL cases
Rem    chinkris    04/28/14 - Project 23621: Scalable sequences
Rem    cxie        04/01/14 - violations view selects cause from pdb_alert$ 
Rem    prshanth    04/16/14 - 18657870: replace cdb$view with containers
Rem    amylavar    04/10/14 - New IMC syntax
Rem    xinjing     04/10/14 - add column DUPLICATED and SHARDED to view *_OBJECTS
Rem    cxie        04/01/14 - violations view selects cause from pdb_alert$ 
Rem    prshanth    04/09/14 - 16180077: update decode for DBA_OBJECTS
Rem    cxie        04/02/14 - 18507040: restore violation decoding in accord
Rem                           with 12.1.0.1
Rem    cxie        03/17/14 - 18414254: update decode for the violations view
Rem    prshanth    03/03/14 - 18192977: removed the union all branch while
Rem                           querying INT$DBA_CONSTRAINTS
Rem    sanbhara    02/25/14 - 18258385: Update USER_ROLE_PRIVS for proxy 
Rem                           connections
Rem    cxie        02/20/14 - add decode for KPDBXMLVSNNOTMATCH in violation
Rem                           view
Rem    sasounda    01/29/14 - 18095778: handle READ priv when creating views
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jmuller     11/21/13 - Fix LRG 10246358: grant USABLE_EDITIONS to PUBLIC
Rem    thbaby      12/02/13 - make tab_comments view family Common Data
Rem    thbaby      12/02/13 - make col_comments view family Common Data
Rem    jekamp      11/22/13 - do not display NO INMEMORY in INMEMORY_DISTRIBUTE
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    jmuller     08/08/13 - Fix bug 17250794: rework of USE privilege on
Rem                           default edition
Rem    traney      11/07/13 - 16382107: add EDITION decode to priv views
Rem    thbaby      10/17/13 - 17406127: optional object # for OBJ_ID
Rem    gravipat    10/03/13 - Bug 17556147: Mark DBA_PDBS as object linked
Rem    thbaby      10/01/13 - 17545909: remove origin_con_id from *_CLUSTERS
Rem    thbaby      10/01/13 - lrg 9629374: redefine user_constraints 
Rem    thbaby      09/30/13 - 17298055: add CON_ID column to DBA_PDBS
Rem    jekamp      09/27/13 - Project 35591: new IMC syntax
Rem    thbaby      08/28/13 - 14515351: add INT$ views for sharing=object
Rem    jklebane    08/23/13 - #13724904. ALL_TABLE_TABLES: ensure KSPPCV and
Rem                           KSPPI are joined first
Rem    xha         08/20/13 - Update IMC level flags
Rem    cxie        08/19/13 - update decode in pdb_plug_in_violations
Rem    thbaby      08/15/13 - 17318420: do not mark *_CLUSTERS as common data
Rem    gravipat    08/14/13 - 17064181: Do not show UNUSED entries in
Rem                           DBA_PDBS
Rem    thbaby      08/13/13 - 16956123: display constraints on common views 
Rem    smuthuli    08/07/13 - IMC preload prioritization
Rem    gravipat    07/25/13 - 17220860: change DBA_PDB_SAVED_STATES to be an
Rem                           object link
Rem    mjungerm    07/08/13 - revert addition of CREATE JAVA priv
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    yiru        06/26/13 - Proj 47393:Add DELEGATE_OPTION for 
Rem                           user_role_privs, dba_role_privs
Rem    gravipat    06/20/13 - Add DBA_PDB_SAVED_STATES
Rem    gravipat    06/19/13 - Add LOGGING mode to DBA_PDBS
Rem    thbaby      05/31/13 - 16813682: INT$DBA_CONSTRAINTS is not common data 
Rem    xha         05/29/13 - Bug 16829223: IMC level flags and map by flags
Rem    cxie        05/24/13 - 16863416: update pdb_plug_in_violations decoding
Rem    mmcracke    06/20/13 - Add MINING MODEL PARTITION object type
Rem    wesmith     05/22/13 - 16532705: add sequence_name to *TAB_IDENTITY_COLS
Rem    mjungerm    05/14/13 - add create java and related privs
Rem    marccaba    04/19/13 - Bug16382107-Adding job, job class and job
Rem                           schedule types
Rem    jgalanes    03/22/13 - remove pkrid trigger
Rem    ptearle     03/08/13 - 10417602: fix ALL_OBJECTS for indexes
Rem    huagli      03/13/13 - 16081860: add time zone version violation
Rem    jekamp      03/01/13 - IMC preload flag
Rem    thbaby      02/28/13 - use constant object type # argument for OBJ_ID
Rem    thbaby      02/13/13 - add SHARING column to Common Data views
Rem    ankrajes    02/07/13 - 9199532: Testing in all_tab_comments if
Rem                           linkname is null
Rem    pyam        02/06/13 - add ORACLE_MAINTAINED column
Rem    pyam        01/27/13 - further update pdb_plug_in_violations decoding
Rem    thbaby      01/29/13 - XbranchMerge thbaby_bug_15827913_ph8 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/28/13 - XbranchMerge thbaby_bug_15827913_ph7 from
Rem    thbaby      01/24/13 - 15827913: add NO_ROOT_SW_FOR_LOCAL
Rem    cxie        01/22/13 - 16204081: update pdb_plug_in_violations decoding
Rem    thbaby      01/19/13 - lrg 8809394: redefine ALL_SYNONYMS
Rem    thbaby      01/22/13 - XbranchMerge thbaby_bug_15827913_ph4 from
Rem    thbaby      01/21/13 - XbranchMerge thbaby_bug_15827913_ph5 from
Rem    thbaby      01/19/13 - lrg 8809394: redefine ALL_SYNONYMS
Rem    thbaby      01/16/13 - XbranchMerge thbaby_bug_15827913_ph2 from
Rem    talliu      01/16/13 - modify the comments for common colume
Rem    thbaby      01/16/13 - 15827913: fix ALL_SYNONYMS for linked objects
Rem    thbaby      01/15/13 - 15827913: Common Data View support for *_VIEWS
Rem    thbaby      01/14/13 - XbranchMerge thbaby_com_dat from
Rem    thbaby      12/31/12 - 15827913: add ORIGIN_CON_ID column
Rem    akruglik    12/27/12 - XbranchMerge akruglik_lrg-8591165 from
Rem    akruglik    12/17/12 - (LRG 8591165): changing 3rd parameter for OBJ_ID
Rem    jekamp      12/10/12 - Clean up IMC flags
Rem    youyang     12/07/12 - bug15950146:add dv to pdb plug in violations
Rem    thbaby      12/06/12 - 15922914: mark dba_synonyms as common_data
Rem    risgupta    12/03/12 - Bug 14259254: Update pdb_plug_in_violations
Rem    krajaman    11/27/12 - Move pdb_dba grants to PDB creation time
Rem    thbaby      11/13/12 - 15827913: define ALL_ view on top of DBA_view
Rem    xihua       10/11/12 - Index Compression Factoring Change
Rem    traney      09/26/12 - move bootstrap table dependencies to cdcore_mig
Rem    ciyer       09/12/12 - move edition range from index to expression
Rem                           column
Rem    gravipat    09/27/12 - 14678938: combine creation_scnbas,
Rem                           creation_scnwrp into one column
Rem    amylavar    09/25/12 - Syntax change for ACO/HCC
Rem    hosu        09/12/12 - 14228225: add more notes contents in 
Rem                           *_tab_cols_v$
Rem    tianli      09/07/12 - lrg 7228742
Rem    snadhika    09/03/12 - Bug 14543350: secure application role shown as 
Rem                           default role in user/dba_role_privs
Rem    krajaman    08/30/12 - Add PDB_DBA role
Rem    gravipat    08/21/12 - Add columns to DBA_PDBS
Rem    tianli      08/20/12 - add cdb_pdbs and cdb_properties view definition
Rem    gravipat    08/03/12 - Add columns to DBA_PDB_HISTORY
Rem    hosu        07/31/12 - 14395801: add _all(user/dba)_tab_cols_v$ 
Rem    skayoor     06/21/12 - Bug 14184250: Support CDB for ON USER
Rem                           grant/revoke
Rem    byu         05/03/12 - Bug 13242046: add SELECT and ALTER privilege for 
Rem                           measure folder and build process
Rem    sankejai    06/20/12 - add UNUSABLE state to DBA_PDBS view
Rem    akruglik    06/08/12 - (14167701) restrict data returned by
Rem                           DBA_CONTA_DATA to avoid returning data
Rem                           pertaining to PDBs which have been dropped
Rem    pyam        05/21/12 - fix sharing clause bitcheck in *_OBJECTS views
Rem    jekamp      05/09/12 - extend seg$ and ts$ flags to ub8
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ssonawan    03/27/12 - bug 13565214: show audit policy in *_OBJECTS view
Rem    hjhala      02/27/12 - changeing the condition for view ALL_CONSTRAINTS
Rem    jjlee       01/17/12 - rename SESSION_PRIVATE to SESSION_FLAG
Rem    akruglik    01/11/12 - (13253505) add CONTAINER_DATA column to
Rem                           dba/user/all_tables views
Rem    acakmak     12/15/11 - Check identifying flags for (top-)freq histograms
Rem    akruglik    12/12/11 - DB Consolidation: rename CDB_PRIVILEGES to
Rem                           CDB_ADMIN_PRIVS
Rem    anthkim     12/09/11 - In-Memory Columnar Snapshot Store:
Rem    akruglik    12/08/11 - grant set container to connect
Rem    jaeblee     11/29/11 - add con_uid column to dba_pdbs
Rem    skayoor     11/28/11 - Bug 13077185: WITH GRANT OPTION for ON USER
Rem    akruglik    11/22/11 - dba_pdbs.status needs to decode value stored in
Rem                           container$.status
Rem    sankejai    11/11/11 - 13033018: add KEEP_VALUE column to sequence views
Rem    akruglik    11/04/11 - DB Consolidation: cdb_privileges and 
Rem                           pdb_plug_in_violations
Rem    akruglik    10/27/11 - modify definition of DBA_CONTAINER_DATA to
Rem                           reflect the fact that SYSBACKUP has an implicit
Rem                           CONTAINER_DATA attribute enabling it to see data
Rem                           pertaining to all Containers
Rem    akruglik    10/20/11 - modify definition of DBA_CONTAINER_DATA so it
Rem                           would correctly display names of fixed objects
Rem                           for which CONTAINER_DATA attribute was defined
Rem    acakmak     10/17/11 - Add extra checks for top-freq histogram type in
Rem                           column stats views
Rem    dgraj       10/16/11 - Add SENSITIVE_COLUMN to DBA_TAB_COLS and
Rem                           DBA_TAB_COLUMNS
Rem    hschiu      10/14/11 - Proj#30969: rename OLTPHIGH/LOW to OLTP HIGH/LOW
Rem    bhristov    10/10/11 - replace ACCESS PDB with SET CONTAINER
Rem    hosu        10/10/11 - add comments for user_tab_cols
Rem    liaguo      10/07/11 - Remove lifecycle management
Rem    jjlee       10/04/11 - rename SESSION_PRIVATE_ON_STANDBY to
Rem                           SESSION_PRIVATE
Rem    akruglik    10/03/11 - (13056894): modify definition of
Rem                           DBA_CONTAINER_DATA to show that SYS can see data
Rem                           pertaining to all Containers
Rem    brwolf      07/18/11 - 32733: evaluation editions
Rem    kshergil    08/22/11 - fix OLTPHIGH/LOW ind$.flags
Rem    rpang       08/18/11 - Project 32719: add user_privilege_map
Rem    akruglik    09/16/11 - Add SHARING column to _OBJECTS views
Rem    akruglik    09/06/11 - rename CDB_ADMIN to CDB_DBA
Rem    acakmak     08/29/11 - Project 31794: New histogram types
Rem    akruglik    08/29/11 - create role CDB_ADMIN
Rem    teclee      08/23/11 - Add HCC row level locking info on COMPRESS_FOR
Rem    brwolf      08/22/11 - 32733: finer-grained editioning
Rem    akruglik    08/18/11 - define dba_pdb_history
Rem    sursridh    07/06/11 - Proj 32995: support for partial indexes.
Rem    kshergil    06/17/11 - Proj#30969: index OLTP compression
Rem    akruglik    07/15/11 - DB Consolidation: bit indicating that a view is a
Rem                           CONTAINER_DATA view has moved
Rem    sursridh    07/06/11 - Proj 32995: support for partial indexes.
Rem    jaeblee     06/29/11 - add guid column to dba_pdbs
Rem    skayoor     06/27/11 - Project 32719 - Add INHERIT PRIVILEGES
Rem    kshergil    06/17/11 - Proj#30969: index OLTP compression
Rem    wesmith     06/07/11 - project 31843: identity columns
Rem    liaguo      06/24/11 - Project 32788 DB ILM
Rem    sursridh    03/22/11 - Project 32995: Support for fast global index
Rem                           maintenance during drop/truncate partition.
Rem    wxli        05/20/11 - add BEQUEATH on USER_VIEWS and other _VIEWS
Rem    jibyun      05/15/11 - Project 5687: Allow SYSBACKUP to have full access
Rem                           to ALL_TABLES
Rem    awitkows    05/06/11 - add clustering to *_tables
Rem    gravipat    04/29/11 - Change dba_pluggable_databases to dba_pdbs
Rem    jjlee       04/27/11 - add SESSION_PRIVATE_ON_STANDBY to sequence views
Rem    wesmith     04/27/11 - project 36891: column default enhancements
Rem    jmadduku    04/25/11 - Bug 12327898: Remove SPARE4 containing salted
Rem                           password verifier and unused SPARE3 and
Rem                           SPARE5 from _BASE_USER view
Rem    akruglik    04/15/11 - add CONTAINER_DATA column to *_VIEWS views
Rem    krajaman    11/30/09 - Fix bug#7122614, add nocycle to all_synonyms_tree
Rem    akruglik    04/15/11 - add CONTAINER_DATA column to *_VIEWS views
Rem    krajaman    04/09/11 - Extend dba_pluggable_databases
Rem    krajaman    04/09/11 - Extend dba_pluggable_databases 
Rem    ramekuma    03/16/11 - invisible_columns: Fix views for invisible
Rem                           columns
Rem    rpang       03/01/11 - Add SQL translation profile object type
Rem    amunnoli    02/24/11 - Proj 26873:Grant select on DBA_OBJECTS to 
Rem                           AUDIT_ADMIN role
Rem    sfeinste    02/18/11 - 11791349: fix ALL_OBJECTS security for
Rem                           objects of type CUBE
Rem    gravipat    11/22/10 - Add dba_pluggable_databases
Rem    akruglik    11/18/10 - DB Consolidation: add COMMON column to various
Rem                           views edscribing object and system privileges
Rem    sanagara    10/15/10 - 9935857: show lob indexes in dba_objects
Rem    rkagarwa    08/22/10 - 10048645: modifying catalog views related to 
Rem                           updatable_columns
Rem    aamor       07/20/10 - Bug 9371529: move joins out of _all_synonyms_tree
Rem    sursridh    05/21/10 - Bug 8937971: Return freelists, freelist_groups
Rem                           correctly for deferred case.
Rem    achoi       05/12/10 - bug 9543463
Rem    ruparame    03/15/10 - Bug 9192924 Add SYS_OP_DV_CHECK to sensitive columns
Rem    gkulkarn    10/06/09 - Include ID KEY LOG Groups in *_LOG_GROUPS views
Rem    nlee        08/04/09 - Fix for bug 8534445.
Rem    jklebane    07/14/09 - 8560951: remove NO_EXPAND hint from ALL_OBJECTS
Rem    rmacnico    06/11/09 - ARCHIVE LOW/HIGH
Rem    bvaranas    04/27/09 - Remove redundant query to access deferred_stg$
Rem    rmacnico    04/14/09 - Bug 8360974: dba_tables and AdvCmp
Rem    rramkiss    04/14/09 - fill in missing object type names
Rem    adalee      03/06/09 - new cachehint
Rem    bvaranas    03/03/09 - Fix storage parameters in views for deferred
Rem                           segment creation
Rem    rbhatti     02/10/09 - Fix bug 7635949; correct definition of view
Rem                           USER_ROLE_PRIVS (do not show pasword-protected
Rem                           roles as DEFAULT_ROLE)
Rem    bvaranas    12/11/08 - Fix segment_created for partitioned objects
Rem    slynn       09/02/08 - 
Rem    pyoun       08/27/08 - fix comments for encrypted_columns
Rem    mcusson     08/13/08 - Do not include supplemental logging related
Rem                           constraints in dba_constraints
Rem    slynn       07/27/08 - Sequence Partitioning
Rem    achoi       07/18/08 - fix bug6672949
Rem    slynn       08/14/08 - 
Rem    pyoun       05/05/08 - bug 7002207
Rem    slynn       04/16/08 - Add New Retention Column to *_LOBS.
Rem    mbastawa    04/16/08 - add result_cache column
Rem    sursridh    03/28/08 - Deferred Segment Creation bug fix.  Correct
Rem                           COMPRESSION, COMPRESS_FOR in *_tables views.
Rem    weizhang    03/13/08 - storage clause INITIAL/NEXT for ASSM segment
Rem    bvaranas    02/04/08 - Proj 25274: Deferred Segment Creation. Add
Rem                           segment_created to _tables, _indexes, _lobs
Rem    cvenezia    09/25/07 - add OLAP types 92-95 to ALL_OBJECTS (bug 6311970)
Rem    kquinn      07/27/07 - 2883037: extend constraint_type
Rem    achoi       04/26/07 - defining_edition instead of defining_edition_id
Rem    vmarwah     05/23/07 - Add COMPRESS_FOR in *_TABLES views
Rem    achoi       05/14/07 - improve all_synonyms
Rem    achoi       04/26/07 - defining_edition instead of defining_edition_id
Rem    sfeinste    04/03/07 - Add OLAP types to *_OBJECTS view decodes
Rem    vakrishn    01/04/07 - move Flashback Archive views to cdtxnspc.sql
Rem    ramekuma    03/20/07 - bug-5931139: remove extra spacing in defintion of
Rem                           'INVISIBLE' in index views VISIBILITY column
Rem    achoi       02/02/07 - fix undefined object in _AE views
Rem    slynn       11/20/06 - 
Rem    achoi       11/07/06 - obj$.spare3 stores base user#
Rem    rramkiss    01/08/07 - b5736514, add credential to *_OBJECTS_AE
Rem    rpang       01/02/07 - 5725761: show objs with debug priv in all_objects
Rem    kquinn      11/13/06 - 5550536: *_objects now hides recyclebin objects
Rem    rburns      11/06/06 - add view for invalid objects
Rem    slynn       10/12/06 - smartfile->securefile
Rem    schakkap    10/20/06 - move v$object_usage to cdmanege.sql
Rem    achoi       08/09/06 - add *_VIEWS_AE and *_EDITIONING_VIEWS_AE
Rem    achoi       07/21/06 - add read-only column for *_views family
Rem    achoi       06/26/06 - fix bug 5508217
Rem    jforsyth    09/13/06 - fix lob views
Rem    gviswana    09/29/06 - CURRENT_EDITION -> CURRENT_EDITION_NAME
Rem    vakrishn    09/29/06 - Flashback Archive Views
Rem    akruglik    09/01/06 - replace CMV$ with EV$, CMVCOL$ with EVCOL$ +
Rem                           rename a few columns and get rid of a few;
Rem                           rename *_COLUMN_MAP_VIEWS to *_EDITIONING_VIEWS
REM                           rename *_COLUMN_MAP_COLUMNS to 
REM                           *_EDITIONING_VIEW_COLUMNS
Rem    slynn       07/31/06 - change csce keywords.
Rem    gviswana    07/16/06 - Editions: non-versionable users 
Rem    rlathia     06/20/06 - bug5304489 Add check for KQDOBRBO in USER_LOBS 
Rem                           definition 
Rem    achoi       06/30/06 - fix performance on _CURRENT_EDITION_OBJ 
Rem    achoi       06/07/06 - stub obj# is 88 
Rem    pstengar    05/18/06 - update system priv numbers for mining models
Rem    jforsyth    06/06/06 - CSCE columns in lob views empty for NOLOCAL 
Rem    rramkiss    05/17/06 - all credential Scheduler object 
Rem    akruglik    05/31/06 - replace references to obj$ with 
Rem                           _CURRENT_EDITION_OBJ in EDITIONING_VIEWS and 
Rem                           EDITIONING_VIEW_COLUMNS views 
Rem    akruglik    05/30/06 - change EDITIONING_VIEWS views to return names, 
Rem                           rather than ids, of EVs and their base tables 
Rem    weizhang    05/17/06 - proj 19400: GTT tablespace option 
Rem    akruglik    05/26/06 - move EV-related comments from catalog.sql 
Rem    akruglik   05/04/06  - in definitions of EDITIONING_VIEWS add 
Rem                           restriction on type# when joining EV$ to OBJ$ 
Rem                           on base table schema id and name to avoid 
Rem                           returning multiple rows for EV defined on 
Rem                           partitioned tables 
Rem    akruglik   05/02/06  - remove EDITIONING_FREEZE_SCN column from 
Rem                           _EDITIONING_VIEWS views 
Rem    akruglik   04/29/06  - replace ev$.base_tbl_obj# with base_tbl_owner# 
Rem                           and base_tbl_name to make life simple for 
Rem                           online redef 
Rem    akruglik   04/07/06  - Add <user/all/dba>_EDITIONING_VIEWS and 
Rem                           <user/all/dba>_EDITIONING_VIEW_COLUMNS views 
Rem                           and add a EDITIONING_VIEW column to 
Rem                           <user/all/dba>_VIEWS 
Rem    akruglik    05/18/06 - move Editioning View-related changes from 
Rem                           catalog.sql 
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

-- Run initial cdcore script in a single process
@@cdcore_str.sql

--CATCTL -M 
@@cdcore_objs.sql
@@cdcore_ind.sql
@@cdcore_misc.sql
@@cdcore_privs.sql
@@cdcore_tabs.sql
@@cdcore_cols.sql
@@cdcore_pdbs.sql
@?/rdbms/admin/sqlsessend.sql

