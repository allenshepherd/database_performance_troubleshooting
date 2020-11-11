Rem
Rem $Header: rdbms/admin/catfusrg.sql /st_rdbms_18.0/1 2017/12/08 14:50:19 hlakshma Exp $
Rem
Rem catfusrg.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catfusrg.sql - Catalog registration file for DB Feature Usage clients
Rem
Rem    DESCRIPTION
Rem      Clients of the DB Feature Usage infrastructure can register their
Rem      features and high water marks in this file.
Rem
Rem      It is important to register the following 8 features:
Rem        RAC, Partitioning, OLAP, Data Mining, Oracle Label Security,
Rem        Oracle Advanced Security, Oracle Programmer(?), Oracle Spatial.
Rem
Rem    NOTES
Rem      The tracking for the following advisors is currently disabled:
Rem         Tablespace Advisor - smuthuli
Rem         SGA/Memory Advisor - tlahiri
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catfusrg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catfusrg.sql
Rem SQL_PHASE: CATFUSRG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpprvt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hlakshma    11/14/17 - Bug 27119186 : Modify heat map feature
Rem                           tracking 
Rem    cqi         10/28/17 - Bug 27038435: fix appcnt
Rem    hosu        10/26/17 - lrg 9048090: exclude oracle owned table
Rem                           incremental usage
Rem    suelee      09/19/17 - RTI 12538704: fix comments for RM
Rem    aksshah     07/26/17 - RTI 19537162: Fix pdb_spfile$ query
Rem    anupkk      06/19/17 - Lrg 20334630: blacklist SYSMAN and SYSMAN_MDS
Rem                           from VPD feature usage
Rem    dagagne     05/23/17 - Fix real time apply query
Rem    rjanders    05/22/17 - Simplify spatial/locator feature usage queries
Rem    saratho     05/03/17 - Bug 25816781: replace shard related changes to
Rem                           gsmadmin_internal.cloud table
Rem    anupkk      04/14/17 - Bug 13954475 Improve Virtual Private Database
Rem                           (VPD) feature usage tracking.
Rem    mbastawa    04/10/17 - Bug 25949590: cache result cache feature tracking
Rem    saratho     02/07/17 - add high-watermark for number of primary shards
Rem    hbaer       02/03/17 - filter out sharding for partition usage
Rem    rayalag     11/23/16 - bug24844549: fix hcc tables shown as oltp indexes 
Rem    yulcho      11/07/16 - Enh 16798703: DBMS_FEATURE_ADG is modified
Rem    sramakri    10/25/16 - remove CDC probing from partition usage tracking
Rem    dcolello    10/18/16 - Add high water mark for shards
Rem    amylavar    09/02/16 - Feature tracking for In-Memory Distribute 
Rem                           For Service
Rem    aumishra    09/01/16 - IME feature tracking
Rem    amylavar    08/29/16 - Feature tracking for join groups
Rem    prthiaga    06/22/16 - Bug 23572368: Sql Injection vulnerability 
Rem                           in DBMS_FEATURE_JSON 
Rem    dmaniyan    05/19/16 - Add feature tracking for sharding
Rem    schakkap    05/11/16 - #(22652097): _optimizer_adaptive_plans =>
Rem                           optimizer_adaptive_plans
Rem    prthiaga    05/05/16 - Bug 23491595: Add 12.2 JSON features & 
Rem                           add XDB non-index table/view stats
Rem    msingal     04/17/16 - Lrg/18936592 statistics changed for HCC in cloud
Rem    anujgg      03/18/16 - Bug 20907094: Feature usage HCC conventional load
Rem    jtomass     03/03/16 - Bug 20898668: density_factor to dbms_feature_asm
Rem    msakayed    03/01/16 - RTI #16412598: fix ext table usage
Rem    jtomass     02/29/16 - 22911644: add ACFS Encryption support on ASM
Rem    jftorres    02/11/16 - #(22449281): add new dba_sql_plan_baselines
Rem                           origins
Rem    qyu         02/01/16 - #22642521: track xmlindex usage
Rem    aksshah     01/29/16 - Bug 22620507: PDB I/O Rate Limits feature usage
Rem    kdnguyen    01/15/16 - Bug 22542622: Feat Tracking for IMC FS 
Rem    jtomass     01/05/16 - 22498132: ACFS Snapshot support
Rem    hbaer       01/04/16 - tracking of json partitioning
Rem    rmacnico    12/08/15 - Rename Cellcache to Cellmemory
Rem    lzheng      11/19/15 - procedural replication feature
Rem    soumadat    10/20/15 - Bug 21932167 : HCC ARCHIVE HIGH Not Showing In
Rem                           Feature Tracking
Rem    alui        10/06/15 - Bug 20674123: fix feature usage for QoS
Rem    rmacnico    10/01/15 - bug 21931792: cellcache as IMC feature
Rem    molagapp    09/17/15 - bug 21848513
Rem    jtomass     08/25/15 - bug 21693658: ACFS support on ASM with #FS
Rem                           Management
Rem    molagapp    08/17/15 - lrg 14294933
Rem    yinlu       08/05/15 - bug 21562376 exclude securefile compression
Rem                           for xml search index D table
Rem    pkapil      07/03/15 - Bug 21248059 : Correcting feature_boolean for
Rem                           Hybrid Columnar Compression case
Rem    carlorti    06/05/15 - Bug 21059266: Rewrote query in terms of Data
Rem                           Dictionary base tables
Rem    hbaer       05/27/15 - bug 21151384, overload zonemap tracking with
Rem                           attribute clustering
Rem    jtomass     05/21/15 - 20877328: FT for ASM Filter Driver
Rem    hbaer       05/08/15 - bug 21052077: enhanced partition usage tracking
Rem    mfallen     05/01/15 - bug 20746293: long identifiers
Rem    prshanth    04/23/15 - Bug 20718081 Rename Oracle Pluggable Databases to
Rem                           Oracle Multitenant
Rem    dblui       03/27/15 - Bug 20347656 exclude compression advisor tmp idxs
Rem    msingal     02/05/15 - Bug/19665921 add support for HCC over cloud DB
Rem                           installations
Rem    jtomass     01/08/15 - 20312104: FT for ThinProvisioning & FlexASM, add
Rem                           high water mark for FlexASM
Rem    jstraub     12/08/14 - Bug 20147092: Fix logic for APEX feature usage
Rem    hbaer       12/05/14 - fix bug 12573239, additional filtering for
Rem                           internal partitioning use cases
Rem    snechand    11/24/14 - Bug 16532277 Excluding schemas - SYSMAN_MDS,
Rem                           SYSMAN_OPSS, SYSMAN_BIPLATFORM
Rem    zhimchen    10/30/14 - Fix bug#12970736, exclude SYSEXT and UD1
Rem    yhu         10/12/14 - LRG# 13361756: deal with MDSYS lob, from 
Rem                           zhimchen_lrg-13361756
Rem    rjanders    08/13/14 - LRG# 12953957, qualify dba_registry queries
Rem    suelee      08/07/14 - Bug 19351050: fix usage for Resource Manager on
Rem                           CDBs
Rem    molagapp    08/06/14 - rename BA to RA
Rem    amylavar    07/29/14 - Bug 19308780: Dont enable tracking for inmemory
Rem                           if inmemory_size = 0
Rem    zqiu        07/11/14 - PARTIAL state added to v$KEY_VECTOR
Rem    jinjche     06/09/14 - Add Backup Appliance NZDL feature tracking
Rem    lexuxu      06/04/14 - Backport lexuxu_bug-18756350 from main
Rem    apfwkr      05/26/14 - Backport prthiaga_bug-18805145 from main
Rem    prthiaga    05/21/14 - Bug 18805145: JSON feature usage
Rem    apfwkr      05/01/14 - Backport pmojjada_lrg-11571892 from main
Rem    prthiaga    05/21/14 - Bug 18805145: JSON feature usage
Rem    lexuxu      04/30/14 - DBLRA feature usage
Rem    pmojjada    04/23/14 - LRG# 11571892, Bug# 18645104 : Exclude SYSTEM
Rem                           schema from VPD feature usage
Rem    akociube    02/26/14 - DBMS_FEATURE_IMA support
Rem    kdnguyen    02/20/14 - Change ADVANCED to Advanced for Index Compression
Rem    hbaer       02/14/14 - add zonemap feature tracking
Rem    yanchuan    01/13/14 - lrg 9586866: add DVSYS in the NOT IN USER list
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    chinkris    12/12/13 - Rename in-memory views
Rem    hbaer       12/18/12 - bug 14666795, plus partition collection 
Rem                           enhancements for 12.1.0.2 and other bug fixes
Rem    jiayan      12/09/13 - lrg 9549959: fix feature_boolean value for 
Rem                           Automatic Reoptimization and Adaptive Plans
Rem    amylavar    12/05/13 - Feature tracking for IOTs
Rem    zhimchen    11/17/13 - Fix lrg#10052943: exclude user FLOWS_FILES for
Rem                           XDB feature usage
Rem    yxie        11/08/13 - get emx usage info for all instances
Rem    amylavar    11/01/13 - Feature tracking for IMC
Rem    youyang     10/30/13 - lrg9922394: change pa feature usage cursor
Rem    amylavar    10/22/13 - Change tracking for ROW STORE COMPRESS ADVANCED
Rem    yxie        07/30/13 - add feature usage for em express
Rem    smuthuli    07/22/13 - Fix heatmap feature usage query
Rem    hsivrama    07/15/13 - Bug 15854162 : Feature tracking for adaptive
Rem                           plans(project 31793)
Rem    gkulkarn    06/13/13 - bug-16874207: OGG ALLKEY SUPLOG feature tracking
Rem    esmendoz    05/22/13 - BUG 16564880 - error on gateways usage.
Rem    kamotwan    05/20/13 - 16830636 : Added feature tracking for GGSESSION
Rem                           and DELCASCADEHINT in goldengate
Rem    kamotwan    05/20/13 - Bug 16874207 : Added feature tracking for
Rem                           DBENCRYPTION in goldengate 
Rem    pmojjada    03/29/13 - Bug# 16532243 & 16555784: Exclude MDSYS and
Rem                           SYSMAN_MDS from showing in feature usage.
Rem    suelee      03/28/13 - Bug 16557838: Resource Manager on CDBs
Rem    dagagne     03/27/13 - BUG 16563848: ADG not required for global
Rem                           sequences
Rem    smuthuli    02/24/13 - XbranchMerge smuthuli_bug-14803927 from
Rem                           st_rdbms_12.1.0.1
Rem    smuthuli    12/27/12 - Track Heatmap
Rem    yhuang      12/13/12 - XbranchMerge yhuang_idmr_feature_tracking from
Rem                           main
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    banand      12/06/12 - bug 15844932: 12c RMAN features tracking
Rem    ratiwary    11/28/12 - Add In-Database Hadoop Feature tracking
Rem    snadhika    11/28/12 - lrg 7256825
Rem    panzho      11/27/12 - lrg-7270756
Rem    jiayan      11/13/12 - Add SQL Plan Directives and Concurrent Stats
Rem                           Gathering
Rem    sasounda    11/09/12 - 15841236: add feature compress online
Rem    chinkris    11/08/12 - Bug-15846613: Add HCC row level locking feature
Rem    talliu      11/05/12 - Adding tracking for pluggable database
Rem    jerrede     11/05/12 - Use Common Routine to calculate cells
Rem    xbarr       10/05/12 - Add feature usage support for Data Mining
Rem    smcgee      10/12/12 - Rename far sync standby to far sync instance
Rem    xihua       10/12/12 - 12c Index Compression factoring change
Rem    vpantele    09/28/12 - bug 14672752: add online move datafile tracking
Rem    fuli        09/24/12 - bug 13966908
Rem    jkaloger    09/20/12 - Feature tracking for Data Pump Full Transportable
Rem    paestrad    09/12/12 - Adding information from NEW JOB TYPES project for
Rem                           DBMS_FEATURE_JOB_SCHEDULER
Rem    esmendoz    09/11/12 - adding DBMS_FEATURE_HS to query gateway features.
Rem    teclee      09/06/12 - Add tracking for HCC row level locking
Rem    amunnoli    08/31/12 - Bug 14568283:Intuitive Audit Feature names
Rem    panzho      08/22/12 - bug 14514644
Rem    liding      08/16/12 - bug 14500587: tracking for out-of-place refresh
Rem    minwei      08/14/12 - Add tracking for online redefinition
Rem    kmohan      08/10/12 - Track Database Resident Connection Pooling (DRCP)
Rem                           usage.
Rem    hbaer       08/01/12 - fix bug 14369338, plus adjustments for 12c
Rem    ysarig      07/23/12 - Remove DB control
Rem    sslim       07/11/12 - Bug 14158354: Add tracking of DBMS_ROLLING
Rem    prgaharw    07/05/12 - 13895208 - Proj-30966: ILM feature tracking
Rem    kdnguyen    06/05/12 - register oltp compressed index feature
Rem    sdball      05/24/12 - Exclude GSM schema from feature usage checks
Rem    dgraj       05/21/12 - Bug 13887494: Add feature usage tracking for TSDP
Rem    ddas        05/16/12 - add evolve advisor origin to SPM tracking
Rem    jheng       05/14/12 - Bug 14050142: add privilege capture usage tracking
Rem    cqi         04/17/12 - Add feature tracking for RACONENODE
Rem    aramappa    04/10/12 - bug 13921755:Improve label security feature usage
Rem    dagagne     04/16/12 - Add more Data Guard features
Rem    lzheng      04/13/12 - bug 13917054: Enhance Stream/XStream/GoldenGate
Rem                           feature tracking
Rem    snadhika    04/12/12 - Add feature tracking for Real Application Security
Rem    sdball      04/05/12 - Add GSM usage checking
Rem    siravic     03/30/12 - Bug# 13888340: Data redaction feature 
Rem                           usage tracking
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ssonawan    03/26/12 - Bug 8518997: Improve 'Audit Options',
Rem                           add 'Fine Grained Audit' & 'Unified Audit'
Rem    alui        02/21/12 - enhance QoSM to track measure only mode
Rem    kamotwan    12/22/11 - Add feature tracking for GoldenGate
Rem    qyu         11/22/11 - lrg 5834576 fix 
Rem    alhollow    10/28/11 - Pillar/ ZFS support
Rem    spamu       09/13/11 - Add feature tracking for Advanced Network
Rem                           Compression
Rem    alhollow    08/01/11 - Add HCC stats
Rem    rjanders    09/30/11 - #11707598: differentiate "spatial" from "locator"
Rem    srtata      08/29/11 - renamed OLS policy table
Rem    ddas        08/22/11 - enhance SPM feature usage tracking
Rem    alui        06/30/11 - Add QoS Management tracking
Rem    vraja       06/03/11 - add DBFS feature-usage checks
Rem    jkaloger    01/04/11 - PROJ:27450 - Update Utilities tracking for 12g.
Rem    hosu        05/07/10 - register incremental maintenance
Rem    mtozawa     11/17/10 - bug 10280821: add DMU feature usage tracking
Rem    jjlee       07/19/10 - bug 9903993: remove compat check from ADG query
Rem    fsanchez    05/06/10 - bug 9689580
Rem    bpwang      05/30/10 - LRG 4646114: Handle GoldenGate Capture change
Rem    rmao        05/19/10 - change to dba_capture/apply.purpose
Rem    evoss       05/07/10 - better dbms_scheduler queries
Rem    bpwang      04/23/10 - Add XStream In, XStream Out, GoldenGate
Rem    jheng       04/06/10 - Fix bug 9256867: use dba_policies for OLS
Rem    yemeng      03/03/10 - change the name for diag/tuning pack
Rem    hbaer       02/26/10 - bug 9404352: fix Partition feature usage tracking
Rem                           for 11gR2
Rem    ysarig      02/10/10 - fixing bug 8940905
Rem    bvaranas    02/03/10 - 8803049: Feature usage tracking for deferred
Rem                           segment creation
Rem    pbelknap    09/23/09 - correct advisor fusg for reports
Rem    suelee      08/26/09 - Add tracking for dNFS and instance caging
Rem    fsanchez    07/22/09 - XbranchMerge fsanchez_bug-8657554 from
Rem                           st_rdbms_11.2.0.1.0
Rem    baleti      06/29/09 - split SF into user and system tracking
Rem    jcarey      06/30/09 - better olap query
Rem    qyu         06/30/09 - fix bug 8643026
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    bsthanik    06/30/09 - 8643032: Exclude user APEX for XDB feature usage
Rem                           reporting
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    cchui       06/17/09 - Register Database Vault
Rem    baleti      06/16/09 - Add SF compression, encryption and deduplication
Rem                           feature tracking
Rem    etucker     06/19/09 - break up OJVM stats
Rem    ychan       06/18/09 - Fix bug 8607966
Rem    xbarr       06/18/09 - Bug 8610599: update feature usage tracking for Data Mining option
Rem    mfallen     06/16/09 - add awr reports feature
Rem    mhho        06/17/09 - update ASO tracking queries
Rem    baleti      06/16/09 - Add SF compression, encryption and deduplication
Rem                           feature tracking
Rem    bsthanik    06/09/09 - Exclude user OE for XDB feature tracking
Rem    fsanchez    06/05/09 - change compression name DEFAULT -> BASIC
Rem    sugpande    06/24/09 - Change xml in HWM for exadata to a simple sql
Rem    sugpande    06/19/09 - Change HWM name
Rem    suelee      06/03/09 - Bug 8544790: gather feature info for Resource
Rem                           Manager
Rem    spsundar    05/29/09 - bug 8540405
Rem    alexsanc    05/26/09 - bug 7012409
Rem    weizhang    05/22/09 - bug 7026782: segment advisor (user)
Rem    sravada     05/22/09 - fix Spatial usage tracking so that only Spatial
Rem                           usage is counted and Locator is not counted
Rem    wbattist    05/26/09 - bug 7009390 - properly ignore XDB service and any
Rem                           streams services for feature usage
Rem    sravada     05/22/09 - fix Spatial usage tracking so that only Spatial
Rem                           usage is counted and Locator is not counted
Rem    qyu         05/14/09 - bug 7012411 and 7012412
Rem    vmarwah     05/14/09 - feature tracking for hybrid columnar compression
Rem    bsthanik    05/13/09 - 7009367: report xdb usage correctly
Rem    vgokhale    05/12/09 - Add feature usage for server flash cache
Rem    fsanchez    04/06/09 - bug 8411943
Rem    mkeihl      03/12/09 - Bug 5074668: active_instance_count is deprecated
Rem    ataracha    01/29/09 - enhance dbms_feature_xdb
Rem    etucker     12/02/08 - add javavm registration
Rem    sugpande    01/06/09 - Add db feature usage and high water mark for
Rem                           exadata
Rem    ysarig      09/25/08 - Fix bug# 7425224
Rem    fsanchez    08/28/08 - bug 6623413
Rem    jberesni    07/10/08 - add 7-day dbtime and dbcpu to AWR feature_info
Rem    lgalanis    06/25/08 - fix date logic in capture and replay procs
Rem    msakayed    04/17/08 - compression/encryption feature tracking for 11.2
Rem    ssamaran    02/13/08 - Add RMAN tracking
Rem    jiashi      03/19/08 - Remove dest_id from ADG RTQ feature tracking
Rem    jiashi      02/28/08 - Update ADG RTQ feature name
Rem    achoi       01/22/08 - track Edition feature
Rem    dolin       01/15/08 - Update Multimedia to Oracle Multimedia, DICOM to
Rem                           Oracle Multimedia DICOM
Rem    rkgautam    08/17/07 - bug-5475037 Using the feature 
Rem                         - Externally authenticated users 
Rem    evoss       06/08/07 - Add scheduler feature usage support
Rem    mlfeng      05/22/07 - more information for tablespaces
Rem    siroych     05/22/07 - fix errors in Auto SGA/MEM procedures
Rem    sdizdar     05/13/07 - bug-6040046: add tracking for backup compression
Rem    soye        04/25/07 - #5599389: add failgroup info to ASM tracking
Rem    dolin       04/10/07 - Update feature usage for interMedia->Multimedia
Rem                         - interMedia DICOM->DICOM
Rem    rmir        11/19/06 - Bug 5570546, VPD feature usage query correction
Rem    gstredie    02/19/07 - Add tracking for heap compression
Rem    siroych     04/13/07 - bug 5868103: fix feature usage for ASMM
Rem    vakrishn    02/27/07 - Flashback Data Archive feature usage
Rem    mlfeng      03/28/07 - add feature usage capture for baselines
Rem    veeve       02/26/07 - add db usage for workload capture and replay
Rem    hchatter    03/09/07 - 5868117: correctly report IPQ usage
Rem    amadan      02/19/07 - bug 5570961: fix db feature usage for stream
Rem    pbelknap    02/24/07 - lrg 2875206 - add nvl to asta query
Rem    ychan       02/13/07 - Support em feature usage
Rem    jsoule      01/25/07 - add db usage for metric baselines
Rem    pbelknap    02/12/07 - add projected db time saved for auto sta
Rem    ilistvin    01/24/07 - add autotask clients
Rem    weizhang    01/29/07 - add tracking for auto segadv and shrink
Rem    pbelknap    01/12/07 - split STS usage into system and user
Rem    sackulka    01/22/07 - Usage tracking for securefiles
Rem    kyagoub     12/28/06 - add db usage for SQL replay advisor
Rem    suelee      01/02/07 - Disable IORM
Rem    ilistvin    11/15/06 - move procedure invokations to execsvrm.sql
Rem    mannamal    12/21/06 - Fix the problems caused by merge (lrg 2750790)
Rem    shsong      11/01/06 - Add tracking for recovery layer
Rem    achaudhr    12/05/06 - Result_Cache: Add feature tracking
Rem    yohu        12/06/06 - use sysstat instead of inststat 
Rem    sltam       11/13/06 - count service with goal = null
Rem    sltam       10/30/06 - dbms_feature_services - Handle if db_domain 
Rem                           is not set
Rem    rvenkate    10/25/06 - enhance service usage tracking
Rem    mannamal    10/31/06 - Add tracking for semantics/RDF
Rem    yohu        11/21/06 - add tracking for XA/RAC (clusterwide global txn)
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    msakayed    10/17/06 - add tracking for loader/datapump/metadata api
Rem    jdavison    10/19/06 - Add more Data Guard feature info
Rem    mbrey       10/09/06 - add support for CDC
Rem    sbodagal    10/03/06 - add support for Materialized Views (user)
Rem    soye        10/05/06 - #5582564: add more ASM usage tracking
Rem    jdavison    10/10/06 - Modify Data Guard features
Rem    kigoyal     10/11/06 - add cache features
Rem    suelee      10/02/06 - Track IORM
Rem    molagapp    10/06/06 - track usage of BMR and rollforward
Rem    dolin       10/10/06 - add interMedia feature
Rem    rmir        09/27/06 - 5566035,add Transparent Database Encryption
Rem                           feature
Rem    jstraub     10/04/06 - Changed registering of Application Express per
Rem                           mfeng comments
Rem    jstraub     10/02/06 - add Application Express
Rem    bspeckha    09/26/06 - add workspace manager feature
Rem    ayalaman    09/26/06 - tracking for RUL and EXF components
Rem    oshiowat    09/18/06 - bug5385695 - add oracle text
Rem    amozes      09/25/06 - add support for data mining
Rem    molagapp    09/25/06 - add data repair advisor
Rem    ddas        09/07/06 - register optimizer plan management feature
Rem    xbarr       06/06/06 - remove DMSYS entries for Data Mining 
Rem    qyu         05/11/06 - add more xml in xdb 
Rem    mrafiq      03/22/06 - number of resources changed 
Rem    mlfeng      01/18/06 - add flag to USER_TABLES highwater mark for 
Rem                           recycle bin 
Rem    vkapoor     12/23/05 - Number of resources changed 
Rem    qyu         12/15/05 - add xml, lob, object and extensibility feature 
Rem    mrafiq      08/18/05 - adding XDB feature 
Rem    swerthei    08/15/05 - add backup encryption
Rem    swerthei    08/15/05 - add Oracle Secure Backup 
Rem    yuli        07/21/05 - remove standby unprotected mode feature 
Rem    mlfeng      05/16/05 - upper to values 
Rem    mlfeng      05/09/05 - fix spatial query 
Rem    rpang       02/18/05 - 4148642: long report in dbms_feature_plsql_native
Rem    pokumar     08/11/04 - change query for Dynamic SGA feature usage
Rem    fayang      08/02/04 - add CSSCAN features usage detection 
Rem    bpwang      08/03/04 - lrg 1726108:  disregard wmsys in streams query
Rem    jywang      08/02/04 - Add temp tbs into DBFUS_LOCALLY_MANAGED_USER_STR 
Rem    ckearney    07/29/04 - fix Olap Cube SQL to match how it is populated 
Rem    pokumar     05/20/04 - change query for Dynamic SGA feature usage 
Rem    veeve       04/28/04 - Populate CLOB column for ADDM
Rem    mrhodes     02/25/04 - OSM->ASM 
Rem    mlfeng      01/14/04 - tune high water mark queries 
Rem    mkeihl      11/10/03 - Bug 3238893: Fix RAC feature usage tracking 
Rem    mlfeng      11/05/03 - add tracking for SQL Tuning Set, AWR 
Rem    gmulagun    10/28/03 - improve performance of audit query 
Rem    mlfeng      10/30/03 - add ASM tracking, services HWM
Rem    mlfeng      10/30/03 - track system/user
Rem    jwlee       10/16/03 - add flashback database feature 
Rem    ckearney    10/08/03 - fix owner of DBA_OLAP2_CUBES
Rem    hbaer       09/30/03 - lrg1578529 
Rem    esoyleme    09/22/03 - change analytic workspace query 
Rem    mlfeng      09/05/03 - change HDM -> ADDM, OMF logic 
Rem    rpang       08/15/03 - Tune SQL for PL/SQL NCOMP sampling
Rem    bpwang      08/08/03 - bug 2993461:  updating streams query
Rem    hbaer       07/31/03 - fix bug 3074607 
Rem    rsahani     07/29/03 - enable SQL TUNING ADVISOR
Rem    myechuri    07/10/03 - change file mapping query
Rem    gngai       07/15/03 - seed db register
Rem    mlfeng      07/02/03 - change high water mark statistics logic
Rem    sbalaram    06/19/03 - Bug 2993464: fix usage query for adv. replication
Rem    tbosman     05/13/03 - add cpu count tracking
Rem    rpang       05/21/03 - Fixed PL/SQL native compilation
Rem    mlfeng      05/02/03 - change unused aux_count from 0 to null
Rem    xcao        05/22/03 - modify Messaging Gateway usage registration
Rem    aime        04/25/03 - aime_going_to_main
Rem    rjanders    03/11/03 - Correct 'standby archival' query for beta1
Rem    mpoladia    03/11/03 - Change audit options query
Rem    dwildfog    03/10/03 - Enable tracking for several advisors
Rem    swerthei    03/07/03 - fix RMAN usage queries
Rem    hbaer       03/07/03 - adjust dbms_feature_part for cdc tables
Rem    mlfeng      02/20/03 - Change name of oracle label security
Rem    wyang       03/06/03 - enable tracking undo advisor
Rem    mlfeng      02/07/03 - Add PL/SQL native and interpreted tracking
Rem    mlfeng      01/31/03 - Add test flag to test features and hwm
Rem    mlfeng      01/23/03 - Updating Feature Names and Descriptions
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/08/03 - Comments for registering DB Features and HWM
Rem    mlfeng      01/08/03 - Added Partitioning procedure and test procs
Rem    mlfeng      11/07/02 - Registering more features
Rem    mlfeng      11/05/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


  -- ******************************************************** 
  --  To register a database feature, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  --
  --    procedure REGISTER_DB_FEATURE 
  --       ( feature_name           IN VARCHAR2,
  --         install_check_method   IN INTEGER,
  --         install_check_logic    IN VARCHAR2,
  --         usage_detection_method IN INTEGER,
  --         usage_detection_logic  IN VARCHAR2,
  --         feature_description    IN VARCHAR2);
  --
  --  Input arguments:
  --   feature_name           - name of feature
  --   install_check_method   - how to check if the feature is installed.
  --                            currently support the values:
  --                            DBU_INST_ALWAYS_INSTALLED, DBU_INST_OBJECT
  --   install_check_logic    - logic used to check feature installation.
  --                            if method is DBU_INST_ALWAYS_INSTALLED, 
  --                            this argument will take the NULL value.
  --                            if method is DBU_INST_OBJECT, this argument 
  --                            will take the owner and object name for
  --                            an object that must exist if the feature has 
  --                            been installed.
  --   usage_detection_method - how to capture the feature usage, either
  --                            DBU_DETECT_BY_SQL, DBU_DETECT_BY_PROCEDURE, 
  --                            DBU_DETECT_NULL
  --   usage_detection_logic  - logic used to detect usage.  
  --                            If method is DBU_DETECT_BY_SQL, logic will 
  --                            SQL statement used to detect usage.
  --                            If method is DBU_DETECT_BY_PROCEDURE, logic
  --                            will be PL/SQL procedure used to detect usage.
  --                            If method is DBU_DETECT_NULL, this argument
  --                            will not be used. Usage is not tracked.
  --   feature_description    - Description of feature
  --
  --
  --  Examples:
  --
  --  To register the Label Security feature (an install check is not 
  --  required and the detection method is to use a PL/SQL procedure), 
  --  the following is used:
  -- 
  --  declare 
  --   DBFUS_LABEL_SECURITY_PROC CONSTANT VARCHAR2(1000) :=
  --    'dbms_feature_label_security';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --     ('Label Security',
  --      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
  --      NULL,
  --      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
  --      DBFUS_LABEL_SECURITY_PROC,
  --      'Oracle Label Security is being used');
  --  end; 
  --
  --  To register the Partitioning feature (an install check is not
  --  required and the detection method is to use a PL/SQL procedure),
  --  the following is used:
  --
  --  declare
  --   DBFUS_PARTN_USER_PROC CONSTANT VARCHAR2(1000) :=
  --       'DBMS_FEATURE_PARTITION_USER';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --      ('Partitioning (user)',
  --       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
  --       NULL,
  --       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
  --       DBFUS_PARTN_USER_PROC,
  --       'Partitioning');
  --  end;
  -- ******************************************************** 


  -- ******************************************************** 
  --  To register a high water mark, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  -- 
  --    procedure REGISTER_HIGH_WATER_MARK
  --       ( hwm_name   IN VARCHAR2,
  --         hwm_method IN INTEGER,
  --         hwm_logic  IN VARCHAR2,
  --         hwm_desc   IN VARCHAR2);
  --
  --  Input arguments:
  --   hwm_name   - name of high water mark
  --   hwm_method - how to compute the high water mark, either
  --                DBU_HWM_BY_SQL, DBU_HWM_BY_PROCEDURE, or DBU_HWM_NULL
  --   hwm_logic  - logic used for high water mark.
  --                If method is DBU_HWM_BY_SQL, this argument will be SQL 
  --                statement used to compute hwm.
  --                If method is DBU_HWM_BY_PROCEDURE, this argument will be
  --                PL/SQL procedure used to compute hwm.
  --                If method is DBU_HWM_NULL, this argument will not be
  --                used. The high water mark will not be tracked.
  --   hwm_desc   - Description of high water mark
  --
  -- 
  --  Example:
  --
  --  To register the number of user tables (method is SQL), the 
  --  following is used:
  --
  --  declare
  --   HWM_USER_TABLES_STR CONST VARCHAR2(1000) :=
  --       'select count(*) from dba_tables where owner not in ' ||
  --       '(''SYS'', ''SYSTEM'')';
  --
  --  begin
  --   dbms_feature_usage.register_high_water_mark
  --      ('USER_TABLES',
  --       dbms_feature_usage.DBU_HWM_BY_SQL,
  --       HWM_USER_TABLES_STR,
  --       'Number of User Tables');
  --  end;
  -- ******************************************************** 




Rem *********************************************************
Rem Procedures used by the Features to Track Usage
Rem *********************************************************

/***************************************************************
 * DBMS_FEATURE_BA_OWNER
 *  The procedure to detect usage for Recovery Appliance
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_ba_owner
      (feature_boolean OUT number, 
       aux_count       OUT number, 
       info            OUT clob)
AS
   owner     VARCHAR2(100);

BEGIN

   EXECUTE IMMEDIATE 
   'BEGIN ' ||
   'SELECT dbms_rai_owner INTO :owner FROM DUAL; ' ||
   'EXCEPTION ' ||
   '   WHEN OTHERS THEN ' ||
   '   :owner := NULL; ' ||
   'END;' USING OUT owner;

   IF (owner IS NOT NULL) THEN
      feature_boolean := 1;
   ELSE
      feature_boolean := 0;
   END IF;

   aux_count := NULL;
   info := NULL;

END dbms_feature_ba_owner;
/
show errors

/***************************************************************
 * DBMS_FEATURE_ASM
 *  The procedure to detect usage for ASM
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_asm
      (is_used OUT number, total_diskgroup_size OUT number, summary OUT clob)
AS
   redundancy_type    clob;
   max_diskgroup_size number;
   min_diskgroup_size number;
   num_disk           number;
   num_diskgroup      number;
   min_disk_size      number;
   max_disk_size      number;
   num_failgroup      number;
   min_failgroup_size number;
   max_failgroup_size number;
   au_size            clob;
   density_factor     number;

BEGIN
  -- initialize
  redundancy_type      := 'Redundancy';
  max_diskgroup_size   := NULL;
  min_diskgroup_size   := NULL;
  total_diskgroup_size := NULL;
  num_disk             := NULL;
  num_diskgroup        := NULL;
  min_disk_size        := NULL;  
  max_disk_size        := NULL;
  num_failgroup        := NULL;
  min_failgroup_size   := NULL;
  max_failgroup_size   := NULL;
  au_size              := ':au_size';
  density_factor        := NULL;

  select count(*) into is_used from v$asm_client; 
  
  -- if asm is used 
  if (is_used >= 1) then

       select max(total_mb), min(total_mb), sum(total_mb), count(*)
         into max_diskgroup_size, min_diskgroup_size, 
              total_diskgroup_size, num_diskgroup
         from v$asm_diskgroup;

       select max(total_mb), min(total_mb), count(*)
         into max_disk_size, min_disk_size, num_disk
         from v$asm_disk;

       select max(total_fg_mb), min(total_fg_mb), count(*)
         into max_failgroup_size, min_failgroup_size, num_failgroup
         from (select sum(total_mb) as total_fg_mb 
                 from v$asm_disk 
                 group by failgroup);

                               
                        
       for item in (select type, count(*) as rcount from v$asm_diskgroup group by type)
       loop
         redundancy_type:=redundancy_type||':'||item.type||'='||item.rcount;
       end loop;

       for item in (select allocation_unit_size as ausz from v$asm_diskgroup )
       loop
         au_size:=au_size||':'||item.ausz;
       end loop;

       select sys_context('SYS_CLUSTER_PROPERTIES','ASM_DENSITYFACT')
         into density_factor
         from dual; 

       summary := redundancy_type||':total_diskgroup_size:'||total_diskgroup_size
                ||':max_diskgroup_size:'||max_diskgroup_size
                ||':min_diskgroup_size:'||min_diskgroup_size
                ||':num_diskgroup:'||num_diskgroup
                ||':max_disk_size:'||max_disk_size
                ||':min_disk_size:'||min_disk_size
                ||':num_disk:'||num_disk
                ||':max_failgroup_size:'||max_failgroup_size
                ||':min_failgroup_size:'||min_failgroup_size
                ||':num_failgroup:'||num_failgroup
                ||au_size
                ||':density_factor:'||density_factor;

  end if;

END;
/


/***************************************************************
 * DBMS_FEATURE_THP - ASM Thin Provisioning
 *  The procedure to detect usage for Thin Provisioning
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_thp
      (feature_boolean OUT number, aux_count OUT number, feature_info OUT clob)
AS
BEGIN
  select count(*) into feature_boolean from v$asm_attribute 
  where name='thin_provisioned' AND value='true';
  -- compose the CLOB
   
END;
/

/***************************************************************
 * DBMS_FEATURE_FLEX_ASM
 *  The procedure to detect usage for Flex ASM
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_flex_asm
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
   flxasmstat         VARCHAR2(30);   
   numfailovr         VARCHAR2(30);
BEGIN
  select sys_context('SYS_CLUSTER_PROPERTIES', 'FLEXASM_STATE') 
         into flxasmstat from dual;
  
  if (flxasmstat = 'FLEXASM_ENABLED') then
    is_used := 1;
  else
    is_used := 0;
  end if;

  if (is_used >= 1) then
    select sys_context('SYS_CLUSTER_PROPERTIES', 'FLEXASM_STATE_HW') 
           into numfailovr from dual;  

    -- compose the CLOB
    feature_info := ':num_failovers:'||numfailovr; 
  end if;

END;
/

/***************************************************************
 * DBMS_FEATURE_AFD
 *  The procedure to detect usage for ASM Filter Driver
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_afd
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
BEGIN
  select count(*) into is_used
         from v$asm_disk where path LIKE 'AFD:%' AND
                               state = 'NORMAL' AND
                               library LIKE '%AFD Library%' AND
                               mount_status = 'CACHED' AND
                               group_number != '0';
END;
/

/***************************************************************
 * DBMS_FEATURE_ACFS
 *  The procedure to detect usage for ACFS -
 *  Automatic Storage Management Cluster File System
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_acfs
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
  numfs    NUMBER;                            -- # of file systems
BEGIN
  /* Query to detect if ACFS drivers are loaded */
  select sys_context('SYS_CLUSTER_PROPERTIES','ACFS_SUPPORTED')
         into is_used from dual; 
  
  /* Query to retrieve the number of file systems across the cluster */
  select count(*) into numfs from gv$asm_filesystem;

   -- compose the CLOB
   feature_info := ':num_filesystems:'||numfs;
END;
/

/***************************************************************
 * DBMS_FEATURE_ACFS_SNAPSHOT
 *  The procedure to detect usage for ACFS SNAPSHOT -
 *  Automatic Storage Management Cluster File System Snapshot
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_acfs_snapshot
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
BEGIN
  /* Query to detect if ACFS snapshot are being used */
  select count(*) into is_used from gv$asm_acfssnapshots;

   -- compose the CLOB
   feature_info := ':num_snapshots: '||is_used;
END;
/

/***************************************************************
 * DBMS_FEATURE_ACFS_ENCR
 *  The procedure to detect usage for ACFS Encryption -
 *  Automatic Storage Management Cluster File System
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_acfs_encr
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
BEGIN
  /* Query to detect if there is at least one acfs file system
   * with encryption enabled. */
  select count(*) into is_used from V$ASM_ACFS_ENCRYPTION_INFO
         where set_status like 'YES' and
         enabled_status like 'ENABLED'; 
END;
/

/***************************************************************
 * DBMS_FEATURE_AUTOSTA
 *  The procedure to detect usage for Automatic SQL Tuning
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_autosta
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  asqlt_task_name    dbms_id := 'SYS_AUTO_SQL_TUNING_TASK';

  execs_since_sample NUMBER;                  -- # of execs since last sample
  total_execs        NUMBER;                  -- number of task executions 
  w_auto_impl        NUMBER;                  -- execs with AUTO implement on
  profs_rec          NUMBER;                  -- total profiles in task
  savedsecs          NUMBER;                  -- db time saved (s)
  tmp_buf            VARCHAR2(32767);         -- temp buffer
BEGIN

  /*
   * We compute the following stats for db feature usage:
   *   Number of executions since last sample (execs_since_sample)
   *   Total number of executions in the task (total_execs)
   *   Total number of executions with auto-implement ON (w_auto_impl)
   *   Total number of SQL profiles recommended in the task (profs_rec)
   *   Projected DB Time Saved through Auto Implementation (savedsecs)
   *
   * Note that these stats are only computed through looking at the task,
   * which, by default, stores results from the last month of history only.
   */

  -- execs since last sample
  SELECT count(*)
  INTO   execs_since_sample 
  FROM   dba_advisor_executions 
  WHERE  task_name = asqlt_task_name AND 
         execution_last_modified >= (SELECT nvl(max(last_sample_date),
                                                sysdate-7) 
                                     FROM   dba_feature_usage_statistics);
  
  -- total # of executions
  SELECT count(*) 
  INTO   total_execs
  FROM   dba_advisor_executions 
  WHERE  task_name = asqlt_task_name;

  -- #execs with auto implement ON
  SELECT count(*) 
  INTO   w_auto_impl
  FROM   dba_advisor_exec_parameters 
  WHERE  task_name = asqlt_task_name AND 
         parameter_name = 'ACCEPT_SQL_PROFILES' AND 
         parameter_value = 'TRUE';

  -- total profiles recommended so far
  SELECT count(*) 
  INTO   profs_rec
  FROM   dba_advisor_recommendations r 
  WHERE  r.task_name = asqlt_task_name AND
         r.type = 'SQL PROFILE';

  -- db time saved by AUTO impl profiles
  SELECT round(nvl(sum(before_usec - after_usec)/1000000, 0))
  INTO   savedsecs 
  FROM   (SELECT nvl(o.attr8, 0) before_usec, 
                 nvl(o.attr8, 0) * (1 - r.benefit/10000) after_usec
          FROM   dba_sql_profiles sp,
                 dba_advisor_objects o,
                 dba_advisor_findings f,
                 dba_advisor_recommendations r
          WHERE  o.task_name = asqlt_task_name AND
                 o.type = 'SQL' AND
                 sp.task_id = o.task_id AND
                 sp.task_obj_id = o.object_id AND
                 sp.task_exec_name = o.execution_name AND
                 o.task_id = f.task_id AND 
                 o.execution_name = f.execution_name AND
                 o.object_id = f.object_id AND
                 f.finding_id = sp.task_fnd_id AND
                 r.task_id = f.task_id AND
                 r.execution_name = f.execution_name AND
                 r.finding_id = f.finding_id AND
                 r.rec_id = sp.task_rec_id AND
                 sp.type = 'AUTO');

  -- the used boolean and aux count we set to the number of execs since last
  -- sample
  feature_boolean := execs_since_sample;
  aux_count := execs_since_sample;

  -- compose the CLOB
  tmp_buf := 'Execution count so far: '          || total_execs || ', ' ||
             'Executions with auto-implement: '  || w_auto_impl || ', ' ||
             'SQL profiles recommended so far: ' || profs_rec   || ', ' ||
             'Projected DB Time Saved Automatically (s): ' || savedsecs;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);

END dbms_feature_autosta;
/

/************************************************************************
 * DBMS_FEATURE_SPD - DBMS FEATURE Sql Plan Directive
 *  The procedure to detect usage for statistics incremental maintenance
 ***********************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_spd
  (feature_boolean    OUT  NUMBER,
   aux_count          OUT  NUMBER,
   feature_info       OUT  CLOB)
AS
  NEW_LINE      CONSTANT  VARCHAR2(8) := '
';
  num_dirs                NUMBER;   -- number of directives
  plan_dir_mgmt_control   NUMBER;
  dsdir_usage_control     NUMBER;
  spd_retention_weeks     NUMBER;
  num_dir_obj             NUMBER;
  num_dir_subobj          NUMBER;
  tmp_buf                 VARCHAR2(32767);
  CURSOR spd_reason_cursor IS
    select reason c1, count(*) c2 from dba_sql_plan_directives group by reason;
  CURSOR spd_state_cursor IS
    select state c1, count(*) c2 from dba_sql_plan_directives group by state;
  CURSOR spd_type_cursor IS
    select type c1, count(*) c2 from dba_sql_plan_directives group by type;
BEGIN
  -- get total number of rows in dba_sql_plan_directives
  SELECT count(*)
  INTO num_dirs
  FROM dba_sql_plan_directives;

  dbms_lob.createtemporary(feature_info, TRUE);  
  
  -- # of directives with each type
  for spd_type_iter in spd_type_cursor
  loop
    tmp_buf := 'Number of directives with type, '||spd_type_iter.c1||': '||
               spd_type_iter.c2 || NEW_LINE;
    dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  end loop;

  -- # of directives with each reason
  for spd_reason_iter in spd_reason_cursor
  loop
    tmp_buf := 'Number of Directives with reason, '||spd_reason_iter.c1||': '||
               spd_reason_iter.c2||NEW_LINE;
    dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  end loop;  

  -- # of directives with each state
  for spd_state_iter in spd_state_cursor
  loop
    tmp_buf := 'Number of Directives with state, '||spd_state_iter.c1||': '||
               spd_state_iter.c2 || NEW_LINE;
    dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  end loop;

  -- # of directive objects and subobjects
  select count(object_name), count(subobject_name)
  into num_dir_obj, num_dir_subobj
  from dba_sql_plan_dir_objects;

  tmp_buf := 'Number of Directive objects: '|| num_dir_obj || 
             ', subobjects: ' || num_dir_subobj || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- # of retention weeks 
  select dbms_spd.get_prefs('SPD_RETENTION_WEEKS')
  into spd_retention_weeks
  from dual;

  tmp_buf := 'spd_retention_weeks: '||spd_retention_weeks|| NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- get value of _sql_plan_directive_mgmt_control
  select ksppstvl value
  into plan_dir_mgmt_control
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = '_sql_plan_directive_mgmt_control';

  tmp_buf := '_sql_plan_directive_mgmt_control: ' || plan_dir_mgmt_control
             || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- get value of _optimizer_dsdir_usage_control
  select ksppstvl value
  into dsdir_usage_control
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = '_optimizer_dsdir_usage_control';
  
  tmp_buf := '_optimizer_dsdir_usage_control: ' || dsdir_usage_control || 
             NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- populate the outputs if some directive mgmt operation is enabled or
  -- if there is atleast one directive.
  if (plan_dir_mgmt_control > 0 or num_dirs > 0) then
    feature_boolean := plan_dir_mgmt_control; 
  else
    feature_boolean := 0;
  end if;

  aux_count := num_dirs;

END dbms_feature_spd;
/
show errors

/**************************************************************************
 * DBMS_FEATURE_ADAPTIVE_PLANS - DBMS FEATURE Adaptive Plans
 *  The procedure is to track the usage of adaptive execution plans.
 *************************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_adaptive_plans
  (feature_boolean    OUT  NUMBER,
   aux_count          OUT  NUMBER,
   feature_info       OUT  CLOB)
AS
  NEW_LINE      CONSTANT  VARCHAR2(8) := '
';

  adaptive_plan_param     VARCHAR2(10);   -- adaptive plans parameter
  reporting_param         VARCHAR2(10);   -- reporting mode parameter 
  num_all_queries         NUMBER;         -- number of queries
  num_adaptive_queries    NUMBER;         -- number of adaptive queries
  reporting_param_value   VARCHAR2(10);   -- reporting mode param value
  tmp_buf                 VARCHAR2(32767);

BEGIN
  dbms_lob.createtemporary(feature_info, TRUE);  

  select ksppstvl
  into adaptive_plan_param
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = 'optimizer_adaptive_plans';

  select ksppstvl
  into reporting_param
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = 'optimizer_adaptive_reporting_only';

  if (reporting_param = 'FALSE' AND adaptive_plan_param = 'TRUE') then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;

  if (reporting_param = 'FALSE') then
    reporting_param_value := 'No';
  else
    reporting_param_value := 'Yes';
  end if; 


  -- Find # of sqls in v$sql
  select count(*)
  into   num_all_queries
  from   v$sql vs, v$sqlcommand vsc 
  where vs.command_type = vsc.command_type and
  vsc.command_name in ('INSERT', 'SELECT', 'UPDATE', 'DELETE', 'UPSERT');
 
  -- Find # of sqls which are adaptive
  select count(*)
  into   num_adaptive_queries
  from   v$sql vs, v$sqlcommand vsc
  where vs.command_type = vsc.command_type and 
  vs.is_resolved_adaptive_plan is NOT NULL and 
  vsc.command_name in ('INSERT', 'SELECT', 'UPDATE', 'DELETE', 'UPSERT'); 

  tmp_buf := 'Total number of queries: ' || num_all_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

  tmp_buf := 'Number of queries with an adaptive plan: ' || 
              num_adaptive_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

  tmp_buf := 'Percentage of queries with an adaptive plan: ' || 
             100*num_adaptive_queries/num_all_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

  tmp_buf := 'Are the queries running in reporting mode ? : ' || 
             reporting_param_value || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

END dbms_feature_adaptive_plans;
/
show errors

/**************************************************************************
 * DBMS_FEATURE_AUTO_REOPT - DBMS FEATURE Auto reoptimization
 *  The procedure is to track the usage of adaptive reoptimization.
 *************************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_auto_reopt
  (feature_boolean    OUT  NUMBER,
   aux_count          OUT  NUMBER,
   feature_info       OUT  CLOB)
AS
  NEW_LINE      CONSTANT  VARCHAR2(8) := '
';

  reporting_param         VARCHAR2(10);
  use_feedback_param      VARCHAR2(10);
  num_all_queries         NUMBER;   -- number of queries
  num_reopt_queries       NUMBER;   -- number of reoptimizable queries
  tmp_buf                 VARCHAR2(32767);

BEGIN
  dbms_lob.createtemporary(feature_info, TRUE);  

  select ksppstvl
  into reporting_param
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = 'optimizer_adaptive_reporting_only';

  select ksppstvl
  into use_feedback_param
  from x$ksppi x, x$ksppcv y where (x.indx = y.indx) and
  ksppinm = '_optimizer_use_feedback';
 
  if (reporting_param = 'FALSE' AND use_feedback_param = 'TRUE') then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if; 

  -- Find # of sqls in v$sql
  select count(*)
  into   num_all_queries
  from   v$sql vs, v$sqlcommand vsc 
  where vs.command_type = vsc.command_type and
  vsc.command_name in ('INSERT', 'SELECT', 'UPDATE', 'DELETE', 'UPSERT'); 
 
  -- Find # of sqls which are reoptimizable
  select count(*)
  into   num_reopt_queries
  from   v$sql vs, v$sqlcommand vsc 
  where vs.command_type = vsc.command_type and vs.is_reoptimizable = 'Y' 
  and vsc.command_name in ('INSERT', 'SELECT', 'UPDATE', 'DELETE', 'UPSERT');    

  tmp_buf := 'Total number of queries: ' || num_all_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

  tmp_buf := 'Number of reoptimizable queries: ' || num_reopt_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

  tmp_buf := 'Percentage of reoptimizable queries: ' || 
             100*num_reopt_queries/num_all_queries || 
             NEW_LINE ;

  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf); 

END dbms_feature_auto_reopt;
/
show errors

/**************************************************************************
 * DBMS_FEATURE_CONCURRENT_STATS - DBMS FEATURE Concurrent Stats Gathering
 *  The procedure is to track the usage of concurrent stats gathering.
 *************************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_concurrent_stats
  (feature_boolean    OUT  NUMBER,
   aux_count          OUT  NUMBER,
   feature_info       OUT  CLOB)
AS
  NEW_LINE      CONSTANT  VARCHAR2(8) := '
';
  num_all_ops             NUMBER;   -- number of all stats operations
  num_gath_ops            NUMBER;   -- number of gather operations
  num_conc_ops            NUMBER;   -- number of concurrent stats operations
  num_auto_ops            NUMBER;   -- number of auto stats gathering jobs
  interval_start          VARCHAR(20); -- minimum start time in operations view
  interval_end            VARCHAR(20); -- maximum start time in operations view
  conc_pref               VARCHAR2(10); -- value of "concurrent" preference
  tmp_buf                 VARCHAR2(32767);

  -- cursor to get the types of stats gathering operations which were
  -- were performed concurrently.
  CURSOR op_type_cursor IS
    select operation op, count(*) cnt from dba_optstat_operations
    where  extractvalue(xmltype(notes), 
                       '/params/param[@name="concurrent"]/@val') = 'TRUE'
    group by operation
    order by 2 desc;

BEGIN
  dbms_lob.createtemporary(feature_info, TRUE);  

  -- get the time interval reported in dba_optstat_operations
  select to_char(min(start_time), 'MM/DD/YYYY'),
         to_char(max(start_time), 'MM/DD/YYYY') 
         into interval_start, interval_end
  from dba_optstat_operations;

  tmp_buf := 'Time interval covered by dba_optstat_operations: '|| 
             interval_start || ' - ' || interval_end || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- get the total number of rows in dba_optstat_operations
  SELECT count(*)
  INTO num_all_ops
  FROM dba_optstat_operations;

  tmp_buf := 'Total Number of All Stats Operations: '|| num_all_ops 
             || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- get the number of gather stats operations which is eligible to be run
  -- concurrently
  SELECT count(*)
  INTO num_gath_ops
  FROM dba_optstat_operations
  WHERE operation like 'gather%';

  tmp_buf := 'Total Number of Gather Stats Operations: '|| num_gath_ops 
             || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  

  -- get the number of concurrent stats gathering operations
  SELECT count(*)
  INTO num_conc_ops
  FROM dba_optstat_operations
  WHERE extractvalue(xmltype(notes), 
                       '/params/param[@name="concurrent"]/@val') = 'TRUE';
 
  tmp_buf := 'Total Number of Concurrent Operations: ' || num_conc_ops || '.'
              || NEW_LINE || 
             'Types of concurrent operations with their frequencies:'
              || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);

  -- # of concurrent operations group by the kind of operation
  for op_type_iter in op_type_cursor
  loop
    tmp_buf := '  ' || op_type_iter.op ||': '||
                      op_type_iter.cnt || NEW_LINE;
    dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  end loop; 

  -- value of "concurrent" preference
  select dbms_stats.get_prefs('CONCURRENT')
  into conc_pref
  from dual;

  tmp_buf := 'Current value of CONCURRENT preference: '|| conc_pref || NEW_LINE;
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);  
  
  -- populate the outputs if concurrent stats gathering is enabled
  if (num_conc_ops > 0 OR
      upper(conc_pref) not in ('OFF', 'FALSE')) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;

  if (num_gath_ops > 0) then
    aux_count := num_conc_ops/num_gath_ops;
  else
    aux_count := -1;
  end if;

END dbms_feature_concurrent_stats;
/
show errors

/************************************************************************
 * DBMS_FEATURE_STATS_INCREMENTAL
 *  The procedure to detect usage for statistics incremental maintenance
 ***********************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_stats_incremental
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  im_preference      VARCHAR2(30) := 'INCREMENTAL';
  global_on          VARCHAR2(20);
  table_im_on        NUMBER;
  table_im_off       NUMBER;
  stats_gathered_im  NUMBER;
  tmp_buf            VARCHAR2(32767);   
BEGIN

  /*
   * We compute the following stats for db feature usage:
   *   whether global preference of incremental maintenance turned on
   *   # of tables with table level incremental maintenance preference 
   *     turned on
   *   # of tables with table level incremental maintenance preference 
   *     turned off
   *   # of tables that have had stats gathered in incremental mode
   */

  -- rti 9048090: exclude oracle owned tables. incremental can
  -- be enabled for oracle internal tables. We are not interested
  -- in such usage

  --whether global preference of incremental maintenance turned on
  SELECT decode(count(*), 0, 'FALSE', 'TRUE')
  INTO   global_on  
  FROM   dual
  WHERE  dbms_stats.get_prefs(im_preference) = 'TRUE';

  --# of tables with table level incremental maintenance preference 
  -- turned on
  SELECT count(*)
  INTO   table_im_on
  FROM   all_tab_stat_prefs
  WHERE  PREFERENCE_NAME = im_preference and PREFERENCE_VALUE = 'TRUE'
    and  owner not in
         (select distinct username 
          from dba_users 
          where oracle_maintained = 'Y');

  -- # of tables with table level incremental maintenance preference 
  -- turned off
  SELECT count(*)
  INTO   table_im_off
  FROM   all_tab_stat_prefs
  WHERE  PREFERENCE_NAME = im_preference and PREFERENCE_VALUE = 'FALSE'
    and  owner not in 
         (select distinct username 
          from dba_users 
          where oracle_maintained = 'Y');

  -- # of tables that have had stats gathered in incremental mode
  SELECT distinct count(bo#)
  INTO   stats_gathered_im
  FROM   sys.wri$_optstat_synopsis_head$ h, obj$ o, user$ u
  WHERE  h.analyzetime is not null and h.bo# = o.obj# and
         o.owner# = u.user# and
         u.name not in 
         (select distinct username 
          from dba_users 
          where oracle_maintained = 'Y');
    
  -- the used boolean and aux count we set to the number of execs since last
  -- sample
  feature_boolean := stats_gathered_im;
  aux_count := stats_gathered_im;

  -- compose the CLOB
  tmp_buf := 'Incremental global preference on : ' || global_on || ', ' ||
    'Number of tables with table level incremental maintenance preference ' ||
      'turned on: ' || table_im_on || ', ' ||
    'Number of tables with table level incremental maintenance preference ' ||
      'turned off: ' || table_im_off || ', ' ||
    'Number of tables that have had statistics gathered in incremental mode: ' || 
      stats_gathered_im;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);

END dbms_feature_stats_incremental;
/

/***************************************************************
 * DBMS_FEATURE_WCR_CAPTURE
 *  The procedure to detect usage for Workload Capture
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_wcr_capture
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  prev_sample_count     NUMBER;
  prev_sample_date      DATE;
  prev_sample_date_dbtz DATE;
  date_format           CONSTANT VARCHAR2(64) := 'YYYY:MM:DD HH24:MI:SS';

  captures_since     NUMBER;             -- # of captures since last sample
BEGIN

  /*
   * We compute the total number of captures done on the 
   * current database by finding the number of captures done
   * since the last sample and adding it to the current aux_count.
   */

  -- Find prev_sample_count and prev_sample_date first
  select nvl(max(aux_count), 0), nvl(max(last_sample_date), sysdate-7)
  into   prev_sample_count, prev_sample_date
  from   dba_feature_usage_statistics
  where  name = 'Database Replay: Workload Capture';

  -- convert date to db timezone
  select to_date(to_char(from_tz(cast(prev_sample_date as timestamp), 
         sessiontimezone) at time zone dbtimezone, date_format), 
         date_format) into prev_sample_date_dbtz from dual;

  -- Find # of workload captures since last sample in current DB
  select count(*)
  into   captures_since
  from   dba_workload_captures
  where  (prev_sample_date_dbtz is null OR start_time > prev_sample_date_dbtz)
   and   dbid = (select dbid from v$database);

  -- Mark boolean to be captures_since
  feature_boolean := captures_since;
  -- Add current aux_count with captures_since for new value
  aux_count       := prev_sample_count + captures_since;
  -- Feature_info not used
  feature_info    := NULL;

END dbms_feature_wcr_capture;
/

show errors;
/

/***************************************************************
 * DBMS_FEATURE_WCR_REPLAY
 *  The procedure to detect usage for Workload Replay
 *  Almost Verbatim to DBMS_FEATURE_WCR_CAPTURE
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_wcr_replay
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  prev_sample_count     NUMBER;
  prev_sample_date      DATE;
  prev_sample_date_dbtz DATE;
  date_format           CONSTANT VARCHAR2(64) := 'YYYY:MM:DD HH24:MI:SS';

  replays_since      NUMBER;             -- # of replays since last sample
BEGIN

  /*
   * We compute the total number of replays done on the 
   * current database by finding the number of replays done
   * since the last sample and adding it to the current aux_count.
   */

  -- Find prev_sample_count and prev_sample_date first
  select nvl(max(aux_count), 0), nvl(max(last_sample_date), sysdate-7)
  into   prev_sample_count, prev_sample_date
  from   dba_feature_usage_statistics
  where  name = 'Database Replay: Workload Replay';

  -- convert date to db timezone
  select to_date(to_char(from_tz(cast(prev_sample_date as timestamp), 
         sessiontimezone) at time zone dbtimezone, date_format), 
         date_format) into prev_sample_date_dbtz from dual;

  -- Find # of workload replays since last sample in current DB
  select count(*)
  into   replays_since
  from   dba_workload_replays
  where  (prev_sample_date_dbtz is null OR start_time > prev_sample_date_dbtz)
    and  dbid = (select dbid from v$database);

  -- Mark boolean to be replays_since
  feature_boolean := replays_since;
  -- Add current aux_count with replays_since for new value
  aux_count       := prev_sample_count + replays_since;
  -- Feature_info not used
  feature_info    := NULL;

END dbms_feature_wcr_replay;
/

show errors;
/


/***************************************************************
 * DBMS_FEATURE_PARTITION_USER
 *  The procedure to detect usage for Partitioning (user)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_user
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
  c1            SYS_REFCURSOR;
  stmt          varchar2(32767) default null;
  inc_result    varchar2(32767) default null;
  result        clob            default null;
  is_sharded    char(1)         default null;
BEGIN
  -- initialize
  is_used       := 0;
  data_ratio    := 0;
  clob_rest     := NULL;

  -- switch to dynamic sql because mdsys catalog is not 
  -- available when catfusrg.sql is run
  stmt := q'!select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||
                    pcnt||':'||subpcnt||':'||pcols||':'||subpcols||':'||
                    idx_flags||':'||idx_type||':'||idx_uk||':'||rpcnt||':'||
                    rsubpcnt||':'|| def_segment_creation||':'||
                    partial_idx||':'||orphaned_entries ||':'||zonemap||':'||
                    attrcluster||':'||subpartemp 
                    -- read only partitions and subpartitions
                    ||':'|| numrodeftab||':'||numrodefpart
                    ||':'|| numropart||':'||numrosubpart
                    -- partitioned external tables
                    ||':'|| exttab ||':'||exttype
                    -- sharded or not
                    ||':'|| sharded
                    -- some debug info for customer-specific analysis,
                    -- if required. Uncommenting this line will provide the
                    -- tracking of object owner and object name
--                      ||  ':'|| owner ||'.'||name
                    || '|' my_string
                    -- new flag to identify sharded tables
                    -- we want to get table info for sharded tables, but without counting 
                    -- those tables as partition feature usage, so we cannot simply
                    -- filter those tables out.
                    , sharded is_sharded 
               from (select dense_rank() over (order by  decode(bo#,null,pobj#,bo#)) NUM,
                            idx_or_tab, 
                            ptype, pcols, pcnt, rpcnt, 
                            subptype, subpcols, subpartemp, subpcnt, rsubpcnt,
                            idx_flags, idx_type, idx_uk, orphaned_entries,
                            def_segment_creation, partial_idx,            
                            zonemap, attrcluster
                            -- read only
                            , numrodeftab, numrodefpart
                            , numropart, numrosubpart
                            -- partitioned external tables
                            , exttab, exttype
                            -- sharded table
                            , sharded
                            -- some debug info
                            , owner, name
                     from
                     ( select /*+ full(o) */ o.obj#, i.bo#, p.obj# pobj#, 
                       u.name owner, o.name name,
                       decode(o.type#,1,'I',2,'T',3,'C',null) IDX_OR_TAB, 
                       is_xml ||
                       -- tracking of JSON partitioned tables, similar to XML tracking
                       -- e.g. prefixing the partitioning type
                       case when bitand(p.flags,4194304)=4194304 then 'JSON-' end ||
                       -- introducing abbreviations
                       -- I: interval, R: range, H: hash, L: list, S: system
                       -- RF: reference, IR: interval-ref, AL: auto list
                       -- (P): parent of reference partitioned table
                       decode(p.parttype, 1, case when bitand(p.flags,64)=64 then 
                                                 -- INTERVAL-REF, 12c
                                                 case when bitand(p.flags,32)=32 then 'IR'
                                                      else 'I' end 
                                                 else 'R' end 
                                         ,2, 'H', 3, 'S' 
                                                 -- AUTO LIST, 12.2
                                                 ,4, case when bitand(p.flags,64)=64 
                                                          then 'AL'
                                                          else 'L' end
                                                ,5, 'RF'
                                         ,p.parttype||'-?') ||
                      decode(bitand(p.flags,32),32,' (P)') PTYPE,
                       -- introducing abbreviations
                       -- I: interval, R: range, H: hash, L: list, S: system
                       -- RF: reference, IR: interval-ref, AL: auto list
                       -- (P): parent of reference partitioned table 
                      decode(mod(p.spare2, 256), 0, null
                                                   , 1, case when bitand(p.flags, 32768) = 32768
                                                             then 'I'
                                                             else 'R' end
                                                    , 2, 'H', 3,'S' 
                                                    -- AUTO LIST, 12.2
                                                    ,4, case when bitand(p.flags,32768)=32768 
                                                             then 'AL'
                                                             else 'L' end
                                                    , 5, 'RF' 
                                                    , p.spare2||'-?') SUBPTYPE,
                      p.partcnt PCNT, 
                      -- interval subpartitioning
                      -- overloading default subpartitioning count with max number of
                      -- subpartitions. default subpartition count does not really make sense
                      -- for interval subpartition since subpartitions will be created on demand
                      case when (mod(p.spare2, 256) = 1 and bitand(p.flags, 32768) = 32768)
                           then 1048575
                      else
                           mod(trunc(p.spare2/65536), 65536) 
                      end SUBPCNT,
                      to_char(p.partkeycols) || vc.vc_p PCOLS, 
                      to_char(case mod(trunc(p.spare2/256), 256) 
                           when 0 then null 
                           else mod(trunc(p.spare2/256), 256) end)||vc.vc_sp SUBPCOLS,
                      case when bitand(p.flags,1) = 1 then 
                                case when bitand(p.flags,2) = 2 then 'LP'
                                      else 'L' end
                           when bitand(p.flags,2) = 2 then 'GP' 
                      end IDX_FLAGS,
                      -- introducing abbreviation
                      -- N: normal, /R: reverse, B: bitmap, C: cluster, IT: iot - top
                      -- IN: iot nested, S: secondary, A: ansi, L: lob, -F: function-based
                      -- D: domain
                      decode(i.type#, 1, 'N'||
                                          decode(bitand(i.property, 4), 0, '', 4, '/R'),
                                      2, 'B', 3, 'C', 4, 'IT',
                                      5, 'IN', 6, 'S', 7, 'A', 8, 'L',
                                      9, 'D')  || 
                                      case when bitand(i.property,16) = 16 
                                           then '-F' end IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NU', 
                                                                       1, 'U', '?')) IDX_UK,
                      -- real partition and subpartition count
                      case when bitand(p.flags,64)=64 then op.xnumpart else p.partcnt end RPCNT,
                      osp.numsubpart RSUBPCNT,
                      -- deferred segments
                      case o.type# 
                      when 1 then --index
                        decode(ip_seg_off,null,isp_seg_off,ip_seg_off)   
                      when 2 then --table
                        decode(tp_seg_off,null,tsp_seg_off,tp_seg_off)
                      else null end DEF_SEGMENT_CREATION,
                      -- partial indexing
                      -- this is overloaded functionality, showing different values for tables
                      -- and indexes
                      -- tables:   ON | OFF
                      -- indexes:  P: partial, F: full index
                      -- in addition it is overloaded with the number of [sub]partitions
                      -- with indexing off FOR PARTITIONED INDEXES. Null for nonpartitioned ones
                      case o.type# 
                      when 1 then --index
                         decode(bitand(i.flags, 8388608), 8388608, 'P', 'F')||'-'||
                        -- overload field with count of all [sub]partitions with indexing off
                        decode(ip_idx_off,null,isp_idx_off,ip_idx_off)
                      when 2 then --table
                        decode(bitand(p.flags,8192),8192,'OFF','ON')||'-'||
                        -- overload field with count of all [sub]partitions with indexing off
                        decode(tp_idx_off,null,tsp_idx_off,tp_idx_off)
                      else null end PARTIAL_IDX,
                      null ORPHANED_ENTRIES,
                      decode(zonemap,null,'N',zonemap) ZONEMAP, 
                      decode(attrcluster,null,'N',attrcluster) ATTRCLUSTER,
                      st_part SUBPARTEMP
                      -- 12.2 read only partition counts
                      , decode(bitand(p.flags, 65536), 65536, 1, 0) NUMRODEFTAB -- table default read only
                      , numrodefpart -- partitions default read only
                      , numropart, numrosubpart -- real counts of read only [sub]partitions
                      , exttab 
                      , decode(exttype,'ORACLE_LOADER','LD','ORACLE_HIVE','HI',
                                       'ORACLE_HDFS','HD','ORACLE_DATAPUMP','DP',exttype) as exttype 
                      , case o.type#
                        when 1 then -- partitioned index can only be ignored when base table is sharded
                             case when bitand(i.property,2) = 2 and
                                  (select decode(bitand(oo.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N')
                                       from obj$ oo where obj# = i.bo#) = 'Y' then
                               'Y'
                             else 'N' end
                        when 2 then -- identify sharded tables 
                             decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N') 
                        when 3 then -- cluster
                               'N'
                        else null end sharded
                      from partobj$ p, obj$ o, user$ u, ind$ i, 
                           ( select distinct obj#, 'XML-' as is_xml from opqtype$ where type=1) xml,
                           -- real subpartition count for tables and indexes
                           ( select /* NO_MERGE FULL(tsp) FULL(tcp) */ tcp.bo#, count(*) numsubpart
                             -- default read only partitions (none counts as no)
                             , max(tcp.numrodefpart) numrodefpart
                             -- read only subpartition count
                             , sum(decode(bitand(tsp.flags, 67108864), 67108864, 1, 0)) numrosubpart
                             from tabsubpart$ tsp, 
                                  (select obj#, bo#, spare2,
                                          sum(decode(bitand(spare2, 12288), 4096, 1, 0))
                                          over (partition by bo#)  numrodefpart
                                   from tabcompart$) tcp 
                             where tcp.obj# = tsp.pobj# 
                             group by tcp.bo#
                             union all
                             select /* NO_MERGE FULL(isp) FULL(icp) */ icp.bo#, count(*) numsubpart
                             -- dummy for read only info
                             , null, null 
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj# 
                             group by icp.bo#) osp,
                           -- real partition count for tables and indexes
                           ( select tp.bo#, count(*) xnumpart
                             -- read only partitions count
                             , sum(decode(bitand(tp.flags, 67108864), 67108864, 1, 0)) numropart            
                             from tabpart$ tp
                             group by tp.bo#
                             union all
                             select ip.bo#, count(*) xnumpart
                             -- dummy for read only partitions
                             , 0
                             from indpart$ ip
                             group by ip.bo#) op,                            
                           -- details table partitions: partial indexing and deferred segments
                           ( select tp.bo#,
                                    -- number or partitions with indexing off 
                                    sum(decode(bitand(tp.flags, 2097152), 2097152, 1, 0))  tp_idx_off,
                                    -- number or partitions with deferred segment creation
                                    sum(decode(bitand(tp.flags, 65536), 65536, 1, 0))  tp_seg_off
                             from tabpart$ tp
                             group by tp.bo#) pxd,
                           -- details table subpartitions: partial indexing and deferred segments
                           ( select tcp.bo#, 
                                    -- number or subpartitions with indexing off 
                                    sum(decode(bitand(tsp.flags, 2097152), 2097152, 1, 0))  tsp_idx_off,
                                    -- number or subpartitions with deferred segment creation
                                    sum(decode(bitand(tsp.flags, 65536), 65536, 1, 0))  tsp_seg_off
                             from tabsubpart$ tsp, tabcompart$ tcp 
                             where tcp.obj# = tsp.pobj#
                             group by tcp.bo#) spxd,
                           -- details index partitions: partial indexing and deferred segments
                           ( select ip.bo#,
                                    -- number or partitions with indexing off 
                                    sum(decode(bitand(ip.flags, 1), 1, 1, 0))  ip_idx_off,
                                    -- number or partitions with deferred segment creation
                                    sum(decode(bitand(ip.flags, 65536), 65536, 1, 0))  ip_seg_off
                             from indpart$ ip
                             group by ip.bo#) ipd,
                           -- details index subpartitions: partial indexing and deferred segments
                           ( select icp.bo#, 
                                    -- number or subpartitions with indexing off 
                                    sum(decode(bitand(isp.flags, 1), 1, 1, 0))  isp_idx_off,
                                    -- number or subpartitions with deferred segment creation
                                    sum(decode(bitand(isp.flags, 65536), 65536, 1, 0))  isp_seg_off
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj#
                             group by icp.bo#) ispd,
                           -- attribute clustering
                           ( select c.clstobj#, 'Y-'||
                                    -- kind of attribute clustering  
                                    case when ctable is not null 
                                         then 'MT-' else 'ST-' end
                                    ||
                                    case when clstfunc = 1 then 'I-'     -- interleaved
                                         else 'L-' end     -- linear
                                    ||to_char(decode(ctable, null,0,ctable)+1)||'-'||ccol as ATTRCLUSTER
                             from sys.clst$ c, 
                                  -- count of tables and columns used for attribute clustering
                                  -- no detailed breakdown of columns per row
                                  -- table count does not include fact table for hierarchical attr. clustering
                                  ( select clstobj#, count(intcol#) ccol 
                                    from sys.clstkey$
                                    group by clstobj#) k,
                                  ( select clstobj#, count(*) ctable
                                    from sys.clstjoin$
                                    group by clstobj#) kt
                             where c.clstobj# = k.clstobj#
                             and   c.clstobj# = kt.clstobj#(+)) attrcl,
                            -- zone maps
                            (select detailobj#, zonemap from
                                (select sd.detailobj#, flags, 'Y-'||        
                                        -- single table zonemap or hierarchical zonemap
                                        decode(bitand(sn.flag3, 1024),
                                               0, 'ST', 'MT') ||
                                               -- number of tables and columns in zonemap (aggr, no detailed breakdown)
                                               -- table count does not include fact table for hierarch. zonemap
                                               '-'||  count(distinct sd.detailobj#) over (partition by sd.sumobj#) ||
                                               '-'||  sa.zmcol as ZONEMAP 
                                 from sys.sumdetail$ sd, sys.sum$ s, sys.snap$ sn,
                                      ( select sumobj#, count(*) zmcol
                                        from sys.sumagg$ 
                                        where aggfunction = 18
                                        group by sumobj#) sa
                                 where s.obj# = sd.sumobj# 
                                 and   s.obj# = sa.sumobj#
                                 and s.containernam(+) = sn.vname) v
                             where bitand(v.flags, 2) = 2      /* zonemap fact table */
                           ) zm,
                           ( select bo#, count(*) st_part 
                             from defsubpart$ 
                             group by bo# ) spt,
                           -- partitioned external tables
                           ( select obj#, 'Y' exttab, type$ exttype
                             from external_tab$ ) xt,
                           -- virtual column detection
                           (select obj#, case when p_cnt is not null 
                                         then '-VC('||p_cnt||')' 
                                         else null end as vc_p, 
                                         case when sp_cnt is not null 
                                         then '-VC('||sp_cnt||')' 
                                         else null end as vc_sp
                                         from (select pc.obj#, lvl, count(*) cnt 
                                               from (select obj#, 'P' lvl, intcol#  
                                                     from partcol$ pc
                                                     union all 
                                                     select obj#, 'SP' lvl, intcol#
                                                     from subpartcol$) pc,
                                                    (select obj#, intcol# from col$
                                                     where bitand(property, 8) = 8) c
                                               where pc. obj# = c.obj# and pc.intcol# =c.intcol#
                                              group by pc.obj#, lvl)
                                         pivot (max(cnt) cnt 
                                                for lvl in ('P' as P,'SP' as SP))) vc
                      where o.obj# = i.obj#(+)
                      and   o.owner# = u.user# 
                      and   p.obj# = o.obj#
                      and   p.obj# = xml.obj#(+)
                      and   p.obj# = osp.bo#(+) 
                      and   p.obj# = op.bo#(+)
                      and   p.obj# = pxd.bo#(+)
                      and   p.obj# = spxd.bo#(+)
                      and   p.obj# = ipd.bo#(+)
                      and   p.obj# = ispd.bo#(+)
                      and   p.obj# = spt.bo#(+)
                      and   o.obj# = attrcl.clstobj#(+)
                      and   o.obj# = zm.detailobj#(+)
                      and   o.obj# = xt.obj#(+)
                      and   o.obj# = vc.obj#(+)
                      -- bug 14369338, exclude AUDSYS
                      -- changed logic to exclude all oracle maintained schemas
                      and   u.name not in (select distinct username from
                                           dba_users where oracle_maintained = 'Y')
                      and   u.name <> 'SH'
                      -- bug 12573239
                      -- exclude RMAN catalog usage, identified by schema 
                      -- (introduced with ZDLRA, 12.1.0.2)
                      and u.name not in (select u.name 
                                         from sysauth$ sa join user$ u 
                                         on (sa.grantee# = u.user#) join user$ u2 
                                         on (sa.privilege# = u2.user#) 
                                         where u2.name = 'RECOVERY_CATALOG_OWNER')
                      -- bug 12573239
                      -- exclude Spatial topology tables and indexes
                      -- SDO metadata does not have any unique identifier like obj# 
                      -- but only owner and table name. This would make a very expensive 
                      -- query joing back to obj$ and user$ to uniquely identify 
                      -- partitioned indexes through i.bo#, so we are using 
                      -- an approximation by filtering on the prefix of the 
                      -- auto-generated index names ... 
                      and not exists (select 1 
                                      from mdsys.sdo_topo_metadata_table sdo 
                                      where u.name = sdo.sdo_owner 
                                      and o.name like topology||'%')
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,3,19,20,25,34,35)
                      -- exclude flashback data archive tables
                      -- fix bug 14666795
                      -- crystal clear identification of FBA tables deemed as too expensive
                      -- would require a probe against tab$             
                      -- e,g. o.obj# not in (select obj# from tab$ where bitand(property,8589934592)=8589934592)
                      and o.name not like 'SYS_FBA%'
                union all
                -- global nonpartitioned indexes on partitioned tables
                select o.obj#, i.bo#, p.obj# pobj#,
                       u.name owner, o.name name,
                       'I' IDX_OR_TAB,
                        null,null,null,null,
                        to_char(case cols when 0 then null
                                  else cols end) PCOLS,
                        null SUBPCOLS,
                       'GNP' IDX_FLAGS, 
                      -- introducing abbreviation
                      -- N: normal, /R: reverse, B: bitmap, C: cluster, IT: iot - top
                      -- IN: iot nested, S: secondary, A: ansi, L: lob, -F: function-based
                      -- D: domain
                       decode(i.type#, 1, 'N'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/R'),
                                      2, 'B', 3, 'C', 4, 'IT',
                                      5, 'IN', 6, 'S', 7, 'A', 8, 'L',
                                      9, 'D') ||
                       case when bitand(i.property,16) = 16 then '-F' end IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NU', 
                                          1, 'U', '?')) IDX_UK,
                       null, null, 
                       null DEF_SEGMENT_CREATION,
                       -- P: partial, F: full
                       decode(bitand(i.flags, 8388608), 8388608, 'P', 'F') PARTIAL_IDX,
                       decode(bitand(i.flags, 268435456), 268435456, 'YES', 'NO') ORPHANED_ENTRIES,
                       NULL ZONEMAP, NULL ATTRCLUSTER,
                       NULL SUBPARTEMP
                       , NULL NUMDEFROTAB
                       , NULL NUMDEFROPART
                       , NULL NUMROPART
                       , NULL NUMROSUBPART
                       , NULL EXTTAB
                       , NULL EXTTYPE
                       , NULL SHARDED
                from partobj$ p, user$ u, obj$ o, ind$ i
                where p.obj# = i.bo#
                -- exclude flashback data archive tables
                and   o.name not like 'SYS_FBA%'
                -- bug 12573239
                -- exclude global indexes on Spatial topology tables
                and o.name not in (select topology||'_RELATION$' 
                                   from mdsys.sdo_topo_metadata_table sdo 
                                   where u.name = sdo.sdo_owner)
                and   o.owner# = u.user# 
                and   p.obj# = o.obj# 
                -- nonpartitioned index
                and   bitand(i.property, 2) <>2
                -- bug 14369338, exclude AUDSYS
                and   u.name not in ('SYS','SYSTEM','SH','SYSMAN','AUDSYS')
                -- bug 12573239
                -- exclude RMAN catalog usage, identified by schema (introduced with ZDLRA, 12.1.0.2)
                and u.name not in (select u.name 
                                   from sysauth$ sa join user$ u 
                                   on (sa.grantee# = u.user#) join user$ u2 on (sa.privilege# = u2.user#) 
                                   where u2.name like 'RECOVERY_CATALOG_OWNER')
                )
                order by num, idx_or_tab desc)!';

     -- usage of spatial catalog made rewrite to dynamic sql necessary
     open c1 for stmt;

     loop
        fetch c1 into inc_result, is_sharded;
        exit when c1%notfound;

     if (is_used = 0) then
       if is_sharded  = 'N' then
         is_used:=1;
       end if;
     end if;  

     clob_rest := clob_rest||inc_result;
   end loop;
   
   close c1;

     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';

   exception when others then
     if c1%isopen then
        close c1;
     end if;

     is_used    := 0;
     data_ratio := 9999;
     clob_rest  := 'an error occurred at processing time ... : '|| sqlerrm;
end;
/

/***************************************************************
 * DBMS_FEATURE_PARTITION_SYSTEM
 *  The procedure to detect usage for Partitioning (system)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_system
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
BEGIN
  -- initialize
  is_used := 0;
  data_ratio := 0;
  clob_rest := NULL;

  -- SQL is synchronized with Partitioning user tracking to simplify development
  -- and enhancement of code
  FOR crec IN (select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||
                    pcnt||':'||subpcnt||':'||pcols||':'||subpcols||':'||
                    idx_flags||':'||idx_type||':'||idx_uk||':'||rpcnt||':'||
                    rsubpcnt||':'|| def_segment_creation||':'||
                    partial_idx||':'||orphaned_entries ||':'||zonemap||':'||
                    attrcluster||':'||subpartemp 
                    -- read only partitions and subpartitions
                    ||':'|| numrodeftab||':'||numrodefpart
                    ||':'|| numropart||':'||numrosubpart
                    -- partitioned external tables
                    ||':'|| exttab ||':'||exttype
                    -- sharded or not
                    ||':'|| sharded
                    -- some debug info for customer-specific analysis,
                    -- if required. Uncommenting this line will provide the
                    -- tracking of object owner and object name
--                      ||  ':'|| owner ||'.'||name
                    || '|' my_string
                    -- new flag to identify sharded tables
                    -- we want to get table info for sharded tables, but without counting 
                    -- those tables as partition feature usage, so we cannot simply
                    -- filter those tables out.
                    , sharded is_sharded 
               from (select dense_rank() over (order by  decode(bo#,null,pobj#,bo#)) NUM,
                            idx_or_tab, 
                            ptype, pcols, pcnt, rpcnt, 
                            subptype, subpcols, subpartemp, subpcnt, rsubpcnt,
                            idx_flags, idx_type, idx_uk, orphaned_entries,
                            def_segment_creation, partial_idx,            
                            zonemap, attrcluster
                            -- read only
                            , numrodeftab, numrodefpart
                            , numropart, numrosubpart
                            -- partitioned external tables
                            , exttab, exttype
                            -- sharded table
                            , sharded
                            -- some debug info
                            , owner, name
                     from
                     ( select /*+ full(o) */ o.obj#, i.bo#, p.obj# pobj#, 
                       u.name owner, o.name name,
                       decode(o.type#,1,'I',2,'T',3,'C',null) IDX_OR_TAB, 
                       is_xml ||
                       -- tracking of JSON partitioned tables, similar to XML tracking
                       -- e.g. prefixing the partitioning type
                       case when bitand(p.flags,4194304)=4194304 then 'JSON-' end ||
                       -- introducing abbreviations
                       -- I: interval, R: range, H: hash, L: list, S: system
                       -- RF: reference, IR: interval-ref, AL: auto list
                       -- (P): parent of reference partitioned table
                       decode(p.parttype, 1, case when bitand(p.flags,64)=64 then 
                                                 -- INTERVAL-REF, 12c
                                                 case when bitand(p.flags,32)=32 then 'IR'
                                                      else 'I' end 
                                                 else 'R' end 
                                         ,2, 'H', 3, 'S' 
                                                 -- AUTO LIST, 12.2
                                                 ,4, case when bitand(p.flags,64)=64 
                                                          then 'AL'
                                                          else 'L' end
                                                ,5, 'RF'
                                         ,p.parttype||'-?') ||
                      decode(bitand(p.flags,32),32,' (P)') PTYPE,
                       -- introducing abbreviations
                       -- I: interval, R: range, H: hash, L: list, S: system
                       -- RF: reference, IR: interval-ref, AL: auto list
                       -- (P): parent of reference partitioned table 
                      decode(mod(p.spare2, 256), 0, null
                                                   , 1, case when bitand(p.flags, 32768) = 32768
                                                             then 'I'
                                                             else 'R' end
                                                    , 2, 'H', 3,'S' 
                                                    -- AUTO LIST, 12.2
                                                    ,4, case when bitand(p.flags,32768)=32768 
                                                             then 'AL'
                                                             else 'L' end
                                                    , 5, 'RF' 
                                                    , p.spare2||'-?') SUBPTYPE,
                      p.partcnt PCNT, 
                      -- interval subpartitioning
                      -- overloading default subpartitioning count with max number of
                      -- subpartitions. default subpartition count does not really make sense
                      -- for interval subpartition since subpartitions will be created on demand
                      case when (mod(p.spare2, 256) = 1 and bitand(p.flags, 32768) = 32768)
                           then 1048575
                      else
                           mod(trunc(p.spare2/65536), 65536) 
                      end SUBPCNT,
                      to_char(p.partkeycols) || vc.vc_p PCOLS, 
                      to_char(case mod(trunc(p.spare2/256), 256) 
                           when 0 then null 
                           else mod(trunc(p.spare2/256), 256) end)||vc.vc_sp SUBPCOLS,
                      case when bitand(p.flags,1) = 1 then 
                                case when bitand(p.flags,2) = 2 then 'LP'
                                      else 'L' end
                           when bitand(p.flags,2) = 2 then 'GP' 
                      end IDX_FLAGS,
                      -- introducing abbreviation
                      -- N: normal, /R: reverse, B: bitmap, C: cluster, IT: iot - top
                      -- IN: iot nested, S: secondary, A: ansi, L: lob, -F: function-based
                      -- D: domain
                      decode(i.type#, 1, 'N'||
                                          decode(bitand(i.property, 4), 0, '', 4, '/R'),
                                      2, 'B', 3, 'C', 4, 'IT',
                                      5, 'IN', 6, 'S', 7, 'A', 8, 'L',
                                      9, 'D')  || 
                                      case when bitand(i.property,16) = 16 
                                           then '-F' end IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NU', 
                                                                       1, 'U', '?')) IDX_UK,
                      -- real partition and subpartition count
                      case when bitand(p.flags,64)=64 then op.xnumpart else p.partcnt end RPCNT,
                      osp.numsubpart RSUBPCNT,
                      -- deferred segments
                      case o.type# 
                      when 1 then --index
                        decode(ip_seg_off,null,isp_seg_off,ip_seg_off)   
                      when 2 then --table
                        decode(tp_seg_off,null,tsp_seg_off,tp_seg_off)
                      else null end DEF_SEGMENT_CREATION,
                      -- partial indexing
                      -- this is overloaded functionality, showing different values for tables
                      -- and indexes
                      -- tables:   ON | OFF
                      -- indexes:  P: partial, F: full index
                      -- in addition it is overloaded with the number of [sub]partitions
                      -- with indexing off FOR PARTITIONED INDEXES. Null for nonpartitioned ones
                      case o.type# 
                      when 1 then --index
                         decode(bitand(i.flags, 8388608), 8388608, 'P', 'F')||'-'||
                        -- overload field with count of all [sub]partitions with indexing off
                        decode(ip_idx_off,null,isp_idx_off,ip_idx_off)
                      when 2 then --table
                        decode(bitand(p.flags,8192),8192,'OFF','ON')||'-'||
                        -- overload field with count of all [sub]partitions with indexing off
                        decode(tp_idx_off,null,tsp_idx_off,tp_idx_off)
                      else null end PARTIAL_IDX,
                      null ORPHANED_ENTRIES,
                      decode(zonemap,null,'N',zonemap) ZONEMAP, 
                      decode(attrcluster,null,'N',attrcluster) ATTRCLUSTER,
                      st_part SUBPARTEMP
                      -- 12.2 read only partition counts
                      , decode(bitand(p.flags, 65536), 65536, 1, 0) NUMRODEFTAB -- table default read only
                      , numrodefpart -- partitions default read only
                      , numropart, numrosubpart -- real counts of read only [sub]partitions
                      , exttab 
                      , decode(exttype,'ORACLE_LOADER','LD','ORACLE_HIVE','HI',
                                       'ORACLE_HDFS','HD','ORACLE_DATAPUMP','DP',exttype) as exttype 
                      , case o.type#
                        when 1 then -- partitioned index can only be ignored when base table is sharded
                             case when bitand(i.property,2) = 2 and
                                  (select decode(bitand(oo.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N')
                                       from obj$ oo where obj# = i.bo#) = 'Y' then
                               'Y'
                             else 'N' end
                        when 2 then -- identify sharded tables 
                             decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N') 
                        when 3 then -- cluster
                               'N'
                        else null end sharded
                      from partobj$ p, obj$ o, user$ u, ind$ i, 
                           ( select distinct obj#, 'XML-' as is_xml from opqtype$ where type=1) xml,
                           -- real subpartition count for tables and indexes
                           ( select /* NO_MERGE FULL(tsp) FULL(tcp) */ tcp.bo#, count(*) numsubpart
                             -- default read only partitions (none counts as no)
                             , max(tcp.numrodefpart) numrodefpart
                             -- read only subpartition count
                             , sum(decode(bitand(tsp.flags, 67108864), 67108864, 1, 0)) numrosubpart
                             from tabsubpart$ tsp, 
                                  (select obj#, bo#, spare2,
                                          sum(decode(bitand(spare2, 12288), 4096, 1, 0))
                                          over (partition by bo#)  numrodefpart
                                   from tabcompart$) tcp 
                             where tcp.obj# = tsp.pobj# 
                             group by tcp.bo#
                             union all
                             select /* NO_MERGE FULL(isp) FULL(icp) */ icp.bo#, count(*) numsubpart
                             -- dummy for read only info
                             , null, null 
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj# 
                             group by icp.bo#) osp,
                           -- real partition count for tables and indexes
                           ( select tp.bo#, count(*) xnumpart
                             -- read only partitions count
                             , sum(decode(bitand(tp.flags, 67108864), 67108864, 1, 0)) numropart            
                             from tabpart$ tp
                             group by tp.bo#
                             union all
                             select ip.bo#, count(*) xnumpart
                             -- dummy for read only partitions
                             , 0
                             from indpart$ ip
                             group by ip.bo#) op,                            
                           -- details table partitions: partial indexing and deferred segments
                           ( select tp.bo#,
                                    -- number or partitions with indexing off 
                                    sum(decode(bitand(tp.flags, 2097152), 2097152, 1, 0))  tp_idx_off,
                                    -- number or partitions with deferred segment creation
                                    sum(decode(bitand(tp.flags, 65536), 65536, 1, 0))  tp_seg_off
                             from tabpart$ tp
                             group by tp.bo#) pxd,
                           -- details table subpartitions: partial indexing and deferred segments
                           ( select tcp.bo#, 
                                    -- number or subpartitions with indexing off 
                                    sum(decode(bitand(tsp.flags, 2097152), 2097152, 1, 0))  tsp_idx_off,
                                    -- number or subpartitions with deferred segment creation
                                    sum(decode(bitand(tsp.flags, 65536), 65536, 1, 0))  tsp_seg_off
                             from tabsubpart$ tsp, tabcompart$ tcp 
                             where tcp.obj# = tsp.pobj#
                             group by tcp.bo#) spxd,
                           -- details index partitions: partial indexing and deferred segments
                           ( select ip.bo#,
                                    -- number or partitions with indexing off 
                                    sum(decode(bitand(ip.flags, 1), 1, 1, 0))  ip_idx_off,
                                    -- number or partitions with deferred segment creation
                                    sum(decode(bitand(ip.flags, 65536), 65536, 1, 0))  ip_seg_off
                             from indpart$ ip
                             group by ip.bo#) ipd,
                           -- details index subpartitions: partial indexing and deferred segments
                           ( select icp.bo#, 
                                    -- number or subpartitions with indexing off 
                                    sum(decode(bitand(isp.flags, 1), 1, 1, 0))  isp_idx_off,
                                    -- number or subpartitions with deferred segment creation
                                    sum(decode(bitand(isp.flags, 65536), 65536, 1, 0))  isp_seg_off
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj#
                             group by icp.bo#) ispd,
                           -- attribute clustering
                           ( select c.clstobj#, 'Y-'||
                                    -- kind of attribute clustering  
                                    case when ctable is not null 
                                         then 'MT-' else 'ST-' end
                                    ||
                                    case when clstfunc = 1 then 'I-'     -- interleaved
                                         else 'L-' end     -- linear
                                    ||to_char(decode(ctable, null,0,ctable)+1)||'-'||ccol as ATTRCLUSTER
                             from sys.clst$ c, 
                                  -- count of tables and columns used for attribute clustering
                                  -- no detailed breakdown of columns per row
                                  -- table count does not include fact table for hierarchical attr. clustering
                                  ( select clstobj#, count(intcol#) ccol 
                                    from sys.clstkey$
                                    group by clstobj#) k,
                                  ( select clstobj#, count(*) ctable
                                    from sys.clstjoin$
                                    group by clstobj#) kt
                             where c.clstobj# = k.clstobj#
                             and   c.clstobj# = kt.clstobj#(+)) attrcl,
                            -- zone maps
                            (select detailobj#, zonemap from
                                (select sd.detailobj#, flags, 'Y-'||        
                                        -- single table zonemap or hierarchical zonemap
                                        decode(bitand(sn.flag3, 1024),
                                               0, 'ST', 'MT') ||
                                               -- number of tables and columns in zonemap (aggr, no detailed breakdown)
                                               -- table count does not include fact table for hierarch. zonemap
                                               '-'||  count(distinct sd.detailobj#) over (partition by sd.sumobj#) ||
                                               '-'||  sa.zmcol as ZONEMAP 
                                 from sys.sumdetail$ sd, sys.sum$ s, sys.snap$ sn,
                                      ( select sumobj#, count(*) zmcol
                                        from sys.sumagg$ 
                                        where aggfunction = 18
                                        group by sumobj#) sa
                                 where s.obj# = sd.sumobj# 
                                 and   s.obj# = sa.sumobj#
                                 and s.containernam(+) = sn.vname) v
                             where bitand(v.flags, 2) = 2      /* zonemap fact table */
                           ) zm,
                           ( select bo#, count(*) st_part 
                             from defsubpart$ 
                             group by bo# ) spt,
                           -- partitioned external tables
                           ( select obj#, 'Y' exttab, type$ exttype
                             from external_tab$ ) xt,
                           -- virtual column detection
                           (select obj#, case when p_cnt is not null 
                                         then '-VC('||p_cnt||')' 
                                         else null end as vc_p, 
                                         case when sp_cnt is not null 
                                         then '-VC('||sp_cnt||')' 
                                         else null end as vc_sp
                                         from (select pc.obj#, lvl, count(*) cnt 
                                               from (select obj#, 'P' lvl, intcol#  
                                                     from partcol$ pc
                                                     union all 
                                                     select obj#, 'SP' lvl, intcol#
                                                     from subpartcol$) pc,
                                                    (select obj#, intcol# from col$
                                                     where bitand(property, 8) = 8) c
                                               where pc. obj# = c.obj# and pc.intcol# =c.intcol#
                                              group by pc.obj#, lvl)
                                         pivot (max(cnt) cnt 
                                                for lvl in ('P' as P,'SP' as SP))) vc
                      where o.obj# = i.obj#(+)
                      and   o.owner# = u.user# 
                      and   p.obj# = o.obj#
                      and   p.obj# = xml.obj#(+)
                      and   p.obj# = osp.bo#(+) 
                      and   p.obj# = op.bo#(+)
                      and   p.obj# = pxd.bo#(+)
                      and   p.obj# = spxd.bo#(+)
                      and   p.obj# = ipd.bo#(+)
                      and   p.obj# = ispd.bo#(+)
                      and   p.obj# = spt.bo#(+)
                      and   o.obj# = attrcl.clstobj#(+)
                      and   o.obj# = zm.detailobj#(+)
                      and   o.obj# = xt.obj#(+)
                      and   o.obj# = vc.obj#(+)
                      -- bug 14369338, exclude AUDSYS
--                      and   u.name not in ('SYS','SYSTEM','SH','SYSMAN','AUDSYS')
                      -- bug 12573239
                      -- exclude RMAN catalog usage, identified by schema 
                      -- (introduced with ZDLRA, 12.1.0.2)
--                      and u.name not in (select u.name 
--                                         from sysauth$ sa join user$ u 
--                                         on (sa.grantee# = u.user#) join user$ u2 
--                                         on (sa.privilege# = u2.user#) 
--                                         where u2.name = 'RECOVERY_CATALOG_OWNER')
                      -- bug 12573239
                      -- exclude Spatial topology tables and indexes
                      -- SDO metadata does not have any unique identifier like obj# 
                      -- but only owner and table name. This would make a very expensive 
                      -- query joing back to obj$ and user$ to uniquely identify 
                      -- partitioned indexes through i.bo#, so we are using 
                      -- an approximation by filtering on the prefix of the 
                      -- auto-generated index names ... 
--                      and not exists (select 1 
--                                      from mdsys.sdo_topo_metadata_table sdo 
--                                      where u.name = sdo.sdo_owner 
--                                      and o.name like topology||'%')
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,3,19,20,25,34,35)
                      -- exclude flashback data archive tables
                      -- fix bug 14666795
                      -- crystal clear identification of FBA tables deemed as too expensive
                      -- would require a probe against tab$             
                      -- e,g. o.obj# not in (select obj# from tab$ where bitand(property,8589934592)=8589934592)
--                      and o.name not like 'SYS_FBA%'
                union all
                -- global nonpartitioned indexes on partitioned tables
                select o.obj#, i.bo#, p.obj# pobj#,
                       u.name owner, o.name name,
                       'I' IDX_OR_TAB,
                        null,null,null,null,
                        to_char(case cols when 0 then null
                                  else cols end) PCOLS,
                        null SUBPCOLS,
                       'GNP' IDX_FLAGS, 
                      -- introducing abbreviation
                      -- N: normal, /R: reverse, B: bitmap, C: cluster, IT: iot - top
                      -- IN: iot nested, S: secondary, A: ansi, L: lob, -F: function-based
                      -- D: domain
                       decode(i.type#, 1, 'N'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/R'),
                                      2, 'B', 3, 'C', 4, 'IT',
                                      5, 'IN', 6, 'S', 7, 'A', 8, 'L',
                                      9, 'D') ||
                       case when bitand(i.property,16) = 16 then '-F' end IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NU', 
                                          1, 'U', '?')) IDX_UK,
                       null, null, 
                       null DEF_SEGMENT_CREATION,
                       -- P: partial, F: full
                       decode(bitand(i.flags, 8388608), 8388608, 'P', 'F') PARTIAL_IDX,
                       decode(bitand(i.flags, 268435456), 268435456, 'YES', 'NO') ORPHANED_ENTRIES,
                       NULL ZONEMAP, NULL ATTRCLUSTER,
                       NULL SUBPARTEMP
                       , NULL NUMDEFROTAB
                       , NULL NUMDEFROPART
                       , NULL NUMROPART
                       , NULL NUMROSUBPART
                       , NULL EXTTAB
                       , NULL EXTTYPE
                       , NULL SHARDED
                from partobj$ p, user$ u, obj$ o, ind$ i
                where p.obj# = i.bo#
                -- exclude flashback data archive tables
--                and   o.name not like 'SYS_FBA%'
                -- bug 12573239
                -- exclude global indexes on Spatial topology tables
--                and o.name not in (select topology||'_RELATION$' 
--                                   from mdsys.sdo_topo_metadata_table sdo 
--                                   where u.name = sdo.sdo_owner)
                and   o.owner# = u.user# 
                and   p.obj# = o.obj# 
                -- nonpartitioned index
                and   bitand(i.property, 2) <>2
                -- bug 14369338, exclude AUDSYS
--                and   u.name not in ('SYS','SYSTEM','SH','SYSMAN','AUDSYS')
                -- bug 12573239
                -- exclude RMAN catalog usage, identified by schema (introduced with ZDLRA, 12.1.0.2)
--                and u.name not in (select u.name 
--                                   from sysauth$ sa join user$ u 
--                                   on (sa.grantee# = u.user#) join user$ u2 on (sa.privilege# = u2.user#) 
--                                   where u2.name like 'RECOVERY_CATALOG_OWNER')
                )
                order by num, idx_or_tab desc)) LOOP 

     if (is_used = 0) then
       if crec.is_sharded = 'N' then
         is_used:=1;
       end if;
     end if;  

     clob_rest := clob_rest||crec.my_string;
   end loop;

   if (is_used = 1) then
     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';
   end if;
end;
/


/***************************************************************
 * DBMS_FEATURE_ZMAP
 *  The procedure to detect usage for Zone maps
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_zmap
      (is_used OUT number, zmap_ratio OUT number, clob_rest OUT clob)
AS
BEGIN
  -- initialize
  is_used := 0;
  zmap_ratio := 0;
  clob_rest := '{ "data": [';

FOR crec IN (SELECT 
       -- zone map existent
       DECODE(xx.sumobj#,NULL,'N','Y') ||
       DECODE(xx.clstobj#,NULL,'N','Y') zmap_used,
       '{ ' ||
       -- zone map existent
       CASE WHEN xx.sumobj# IS NOT NULL THEN
         '"zmap": { '       || 
--         '"zmap":"'       || DECODE(xx.sumobj#,NULL,'N','Y')  ||'",' ||
         '"zm_w_attrcl":"' || DECODE(bitand(xx.cflags,8),8,'Y','N') ||'",' ||
         '"joined_zmap":"' || DECODE(bitand(xx.xpflags,137438953472),137438953472,'Y','N') || '",' ||
         '"zm_scale":'     || zmapscale     || ','||
         '"num_joins":'    || numjoins      || ','||
         '"num_tabs":'     || numdetailtab  || ','||
         '"num_cols":'     || (numaggregates - numjoins-1)/2 || ','||
         '"refresh_mode":"'|| DECODE(bitand(mflags,65536),65536,'C', 
                                     DECODE(bitand(mflags,34359738368+68719476736),34359738368+68719476736,'L+M', 
                                            34359738368,'L', 68719476736,'M','D'))    || '",'||
         '"disabled":"'    || DECODE(bitand(mflags,4),4,'Y','N')                      || '",'||
         '"unusable":"'    || DECODE(bitand(mflags,17179869184),17179869184,'Y','N')  || '",'||
         '"invalid":"'     || DECODE(bitand(mflags,64),64,'Y','N')                    || '",'||
         '"stale":"'       || DECODE(bitand(mflags,16+32),0,'Y','N')                  || '"},'
       END ||
       -- attribute clustering existent
       CASE WHEN xx.clstobj# IS NOT NULL THEN
         '"attrcl":{ '      ||
--         '"attrcl":"'      || DECODE(xx.clstobj#,NULL,'N','Y') ||'",' ||
         '"clst_type":"'    || DECODE(clstfunc,1,'I','L')                                 || '",'||
         '"clst_mode":"'    || DECODE(bitand(xx.cflags,1+2),1+2,'L+M',1,'L',2,'M','OFF')  || '",'||
         '"clst_dim":'      || (SELECT COUNT(*) FROM clstdimension$ d 
                                WHERE d.clstobj#(+)=xx.clstobj#)                          || ','||
         '"clst_grp":'     || (SELECT COUNT(DISTINCT groupid) FROM clstkey$ k
                                       WHERE k.clstobj#(+)=xx.clstobj#)                   || ','||
         '"clst_cols":'     || (SELECT COUNT(*) FROM clstkey$ k 
                                        WHERE k.clstobj#(+)=xx.clstobj#)                  || ','||
         '"clst_invalid":"' || DECODE(bitand(xx.flags,4),4,'Y','N')                       || '"},'
       END ||
       '"tab":{'    ||
       CASE 
       WHEN bitand(xx.property,32) = 32 THEN
         '"parttab":"Y"'
       -- nonpartitioned tables with existing segments
       WHEN s.block# IS NOT NULL THEN
          '"parttab":"N",' ||
           '"imc_prio":"'      ||
           DECODE(bitand(s.spare1, 4294967296), 4294967296, 
                 DECODE(bitand(s.spare1, 34359738368), 34359738368, 
                        DECODE(bitand(s.spare1, 3848290697216), 549755813888,'LOW',
                                                               1099511627776,'MEDIUM', 
                                                               2199023255552,'HIGH',
                                                               3298534883328,'CRITICAL','NONE'),'NONE'),'-')  || '",'||
          '"imc_dist":"'       ||
          DECODE(bitand(s.spare1, 4294967296), 4294967296, 
                 DECODE(bitand(s.spare1, 8589934592),0,'DUPLICATE','AUTO DIST'),'-')                          || '",'||
          '"imc_comp":"'       ||
          DECODE(bitand(s.spare1, 4294967296), 4294967296, 
                 DECODE(bitand(s.spare1, 274877906944), 0, 
                       DECODE(bitand(s.spare1,17179869184),0,'BASIC','QUERY'), 
                              DECODE(bitand(s.spare1,17179869184),0,'CAP LOW','CAP HIGH')),'-') ||'"' 
          ELSE
          '"parttab":"N"' 
      END 
      || '} }' zmap_obj
FROM (SELECT * 
      FROM (SELECT sumobj#, clstobj#, detailobj#, mflags, c.flags as cflags, clstfunc, numjoins, 
                   numaggregates, numdetailtab, zmapscale, xpflags
            FROM ( SELECT sumobj#, detailobj#, mflags, numjoins, numaggregates, numdetailtab,
                          zmapscale, xpflags        
                   FROM sum$ s 
                            RIGHT OUTER JOIN sumdetail$ sd
                            ON (s.obj# = sd.sumobj#)
                            WHERE bitand(s.xpflags,34359738368)=34359738368
                            AND bitand(sd.flags,2) = 2
                  ) zm 
            -- to accommodate either-or for zone maps or attribute clustering      
            FULL OUTER JOIN clst$ c
            ON (zm.detailobj# = c.clstobj#)
            ) x
            JOIN tab$ t
            ON (t.obj#=DECODE(x.clstobj#,NULL,x.detailobj#,x.clstobj#))
     ) xx
     -- needed for deferred segments and partitioned objects
     LEFT OUTER JOIN seg$ s
     ON (xx.file#  = s.file#
     AND xx.block# = s.block#
     AND xx.ts#    = s.ts#)) loop
     
     -- overloading of zonemap tracking with basic attribute clustering tracking
     IF (is_used = 0 AND crec.zmap_used != 'NN') THEN
       is_used:=1;
     END IF;  

 clob_rest := clob_rest || crec.zmap_obj ||', ';
 END LOOP;

 clob_rest := substr(clob_rest,1,length(clob_rest)-2) ||' ] }';

   IF (is_used = 1) THEN
      -- ratio of tables with zone maps versus total # of tables in percent
      -- if AUX_COUNT=0 then only attribute clustering is used
      SELECT (COUNT(detailobj#)/COUNT(obj#))*100 INTO zmap_ratio   
      FROM ( SELECT detailobj#                
             FROM sum$ s 
             JOIN sumdetail$ sd
       ON (s.obj# = sd.sumobj#)
       WHERE bitand(s.xpflags,34359738368)=34359738368
       AND bitand(sd.flags,2) = 2
       ) zm
      RIGHT OUTER JOIN tab$ t
      ON (t.obj#=zm.detailobj#); 
   END IF;

 END;
 /


/***************************************************************
 * DBMS_FEATURE_PLSQL_NATIVE
 *  The procedure to detect usage for PL/SQL Native
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_plsql_native (
  o_is_used     OUT           number,
  o_aux_count   OUT           number, -- not used, set to zero
  o_report      OUT           clob )

  --
  -- Find ncomp usage from ncomp_dll$
  --
  -- When >0 NATIVE units, sets "o_is_used=1". Always generates XML report,
  -- for example...
  --
  -- <plsqlNativeReport date ="04-feb-2003 14:34">
  -- <owner name="1234" native="2" interpreted="1"/>
  -- <owner name="1235" native="10" interpreted="1"/>
  -- <owner name="CTXSYS" native="118"/>
  -- ...
  -- <owner name="SYS" native="1292" interpreted="6"/>
  -- <owner name="SYSTEM" native="6"/>
  -- ...
  -- <owner name="XDB" native="176"/>
  -- </plsqlNativeReport>
  --

is
  YES      constant number := 1;
  NO       constant number := 0;
  NEWLINE  constant varchar2(2 char) := '
';
  v_date   constant varchar2(30) := to_char(sysdate, 'dd-mon-yyyy hh24:mi');
  v_report          varchar2(400); -- big enough to hold one "<owner .../>"
begin

  o_is_used   := NO;
  o_aux_count := 0;
  o_report    := '<plsqlNativeReport date ="' || v_date || '">' || NEWLINE;

  -- For security and privacy reasons, we do not collect the names of the
  -- non-Oracle schemas. In the case statement below, we filter the schema
  -- names against v$sysaux_occupants, which contains the list of Oracle
  -- schemas.
  for r in (select (case when u.name in
                              (select distinct schema_name
                                 from v$sysaux_occupants)
                         then u.name
                         else to_char(u.user#)
                    end) name,
              count(o.obj#) total, count(d.obj#) native
              from user$ u, ncomp_dll$ d, obj$ o
              where o.obj# = d.obj# (+)
                and o.type# in (7,8,9,11,12,13,14)
                and u.user# = o.owner#
              group by u.name, u.user#
              order by u.name) loop
    if (r.native > 0) then
      o_is_used := YES;
    end if;
    v_report := '<owner name="'|| r.name || '"';
    if (r.native > 0) then
      v_report := v_report || ' native="' || r.native || '"';
    end if;
    if (r.total > r.native) then
      v_report := v_report || ' interpreted="' || (r.total - r.native) || '"';
    end if;
    v_report := v_report || '/>' || NEWLINE;
    o_report := o_report || v_report;
  end loop;
  o_report := o_report || '</plsqlNativeReport>';
end dbms_feature_plsql_native;
/

/*******************************************************************
 * DBMS_FEATURE_QOSM
 *  The procedure to detect usage for Quality of Service Management
 *******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_qosm
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
  managed_cumtime     interval day(9) to second(0);
  measureonly_cumtime interval day(9) to second(0);
  monitor_cumtime     interval day(9) to second(0);
  enabled             number;
  prevmode            number;
  curmode             number;
  maxpc               number;
  curnumpc            number;
  managed             number;
  measureonly         number;
  monitor             number;
BEGIN
  -- initialize
  feature_info := NULL;
  aux_count := NULL;
  enabled := 0;

  -- get number of performance classes
  select count(*) into is_used from x$kywmpctab
    where kywmpctabsp not like ':%';

  execute immediate
  'select used,curmode,prevmode,maxpc,curnumpc,managed_cumtime,' ||
     'measureonly_cumtime,monitor_cumtime,managed,measureonly,' ||
     'monitor from appqossys.wlm_feature_usage'
   into
     enabled,curmode,prevmode,maxpc,curnumpc,managed_cumtime,
     measureonly_cumtime,monitor_cumtime,managed,measureonly,monitor;

  -- if QOSM is used
  if (is_used >= 1) then
    -- number of Performance Classes
    aux_count := is_used;
  end if;

  if (enabled > 0) then
    is_used := 1;
    feature_info := to_clob(
      'Curmode '    || to_char(curmode) ||
      ', Prevmode ' || to_char(prevmode) ||
      ', MaxNumPC ' || to_char(maxpc) ||
      ', CurNumPC ' || to_char(curnumpc) ||
      ', Managed_cumtime ' || to_char(managed_cumtime) ||
      ', MO_cumtime '  || to_char(measureonly_cumtime) ||
      ', MON_cumtime ' || to_char(monitor_cumtime) ||
      ', Managed '  || to_char(managed) ||
      ', MeasureOnly ' || to_char(measureonly) ||
      ', Monitor '  || to_char(monitor));
  end if;
END;
/
show errors;

/*******************************************************************
 * DBMS_FEATURE_RACONENODE
 *  The procedure to detect usage for RAC One Node
 *******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_rond
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS
  is_rac_on number;
  d_type varchar2(15);
  q_status number;
  ops_enabled number;
BEGIN
  is_used := 0;
  aux_count := 0;
  feature_info := NULL;
  d_type := NULL;
  q_status := 0;
  ops_enabled := 0;

  select count(*) into ops_enabled from x$kjidt;

  if (ops_enabled > 0) then
    select kjidtv, kjidtqs into d_type, q_status from x$kjidt;
    if (q_status = 0) then
      feature_info := to_clob('Database is not in RAC');
    elsif (q_status = 1) then
      if (upper(d_type) = 'RACONENODE') then
        is_used := 1;
        feature_info := to_clob('Database is of type RACOneNode');
      elsif (upper(d_type) = 'RAC') then
        feature_info := to_clob('Database is of type RAC');
      elsif (upper(d_type) = 'SINGLE') then
        feature_info := to_clob('Database is of type SINGLE');
      end if;
    elsif (q_status = 2) then
      feature_info := to_clob('Database type query failed');
    elsif (q_status = 3) then
      feature_info := to_clob('Database type query returned warning');
    end if;
  else
    feature_info := to_clob('Database is not RAC One Node');
  end if;
END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_RAC
 *  The procedure to detect usage for RAC
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_rac
      (is_used OUT number, nodes OUT number, clob_rest OUT clob)
AS
   cpu_count_current number;
   cpu_stddev_current number;
BEGIN
  -- initialize
  clob_rest := NULL;
  nodes := NULL;
  cpu_count_current := NULL;
  cpu_stddev_current := NULL;

  select count(*) into is_used from v$system_parameter where
     name='cluster_database' and value='TRUE';
   -- if RAC is used see if only active/passive or active/active
   if (is_used = 1) then
       select count(*) into nodes from gv$instance;
       select sum(cpu_count_current), round(stddev(cpu_count_current),1)
          into cpu_count_current, cpu_stddev_current from gv$license;
       -- active_instance_count init.ora has been deprecated
       --   so 'usage:Active Passive' will no longer be returned
       clob_rest:='usage:All Active:cpu_count_current:'||cpu_count_current
                ||':cpu_stddev_current:'||cpu_stddev_current;
  end if;
END;
/

/***************************************************************
 * DBMS_FEATURE_XDB
 *  The procedure to detect usage for XDB
 ***************************************************************/
/*
 * XDB is being used if user has created atleast 1 of the following
 ***** resource in XDB repositor, 
 ***** XML schema, 
 ***** table with XMLType column, or
 ***** view with XMLType column

 * Here is an example of what this procedure puts in OUT var feature_info
<xdb_feature_usage>
  <user_resources>       2 </user_resources>
  <user_schemas>         1 </user_schemas>
  <user_SB_columns>      1 </user_SB_columns>
  <user_NSB_columns>     7 </user_NSB_columns>
  <user_SB_views>        0 </user_SB_views>
  <user_NSB_views>       0 </user_NSB_views>
  <user_SB_columns_noidx> 1 </user_SB_columns_noidx>
  <user_NSB_columns_noidx>3 </user_NSB_columns_noidx>
  <user_SB_views_noidx>   0 </user_SB_views_noidx>
  <user_NSB_views_noidx>  0 </user_NSB_views_noidx>
  <user_OR_cols>         0 </user_OR_cols>
  <user_CLOB_cols>       6 </user_CLOB_cols>
  <user_BINARY_cols>     2 </user_BINARY_cols>
  <all_resconfigs>       8 </all_resconfigs>
  <all_acls>             4 </all_acls>
  <user_xml_SXIs>        1 </user_xml_SXIs>
  <user_xml_UXIs>        0 </user_xml_UXIs>
  <xml_search_idxes>     0 </xml_search_idxes>
</xdb_feature_usage>

 * Notes:
*/

create or replace procedure DBMS_FEATURE_XDB
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  num_xdb_res           number := 0;
  num_xdb_rc            number := 0;
  num_xdb_acl           number := 0;
  num_xdb_schemas       number := 0;
  num_sb_tbl            number := 0;
  num_xdb_tbl           number := 0;
  num_xdb_vw            number := 0;
  num_nsb_tbl           number := 0;
  num_sb_vw             number := 0;
  num_nsb_vw            number := 0;
  num_st_or             number := 0;
  num_st_lob            number := 0;
  num_st_clob           number := 0;
  num_st_bin            number := 0;
  num_xdb_sidx          number := 0;
  num_xdb_uidx          number := 0;
  num_xdb_tidx          number := 0;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_objtype        cursor_t;
  total_count           number := 0;
  flag                  number := 0;
  objtype               number := 0;
  num_sb_tbl_noidx       number := 0;
  num_nsb_tbl_noidx      number := 0;
  num_sb_vw_noidx        number := 0;
  num_nsb_vw_noidx       number := 0;
begin
    /* get number of non system resources from resource_view */
    execute immediate q'[select count(*) 
    from xdb.xdb$resource e, sys.user$ u 
    where to_number(utl_raw.cast_to_binary_integer(e.xmldata.ownerid)) = 
        u.user# and u.name not in (select distinct username from 
          dba_users where oracle_maintained = 'Y') and 
        u.name not in ('OE', 'SH', 'HR', 'SCOTT')
        and u.name not like 'APEX_%'
        and u.name not like 'FLOWS_%']'
        into num_xdb_res;

    /* get number of non system xml schemas registered */
    execute immediate q'[select count(*) 
    from dba_xml_schemas 
    where owner not in (select distinct username from dba_users 
                        where oracle_maintained = 'Y') 
     and owner not in ('OE', 'SH', 'HR', 'SCOTT') and owner not like 'APEX_%'
     and owner not like 'FLOWS_%']' into num_xdb_schemas ;
    
    /* count non system, SB and NSB xml columns */
       OPEN cursor_objtype FOR q'[
             select count(*), o.type#, bitand(p.flags, 2)
             from sys.opqtype$ p, sys.obj$ o, sys.user$ u
             where o.obj# = p.obj# and p.type = 1 and
                   (o.type# = 2 or o.type# = 4) and
                   o.owner# = u.user# and u.name not in 
                     (select distinct username from dba_users 
                      where oracle_maintained = 'Y')
                   and u.name not in ('OE', 'SH', 'HR', 'SCOTT') and
                   u.name not like 'APEX_%'
                   and u.name not like 'FLOWS_%'
             group by (bitand(p.flags, 2), o.type#)]';

        LOOP
          BEGIN
            FETCH cursor_objtype INTO total_count, objtype, flag;
            EXIT WHEN cursor_objtype%NOTFOUND;


            /* get number of non schema based tables */
            IF (flag = 0) and (objtype = 2) THEN
              num_nsb_tbl := total_count;
            END IF;

            /* get number of non schema based views */
            IF (flag = 0) and (objtype = 4) THEN
              num_nsb_vw := total_count;
            END IF;

            /* get number of schema based tables */
            IF (flag = 2) and (objtype = 2) THEN
              num_sb_tbl := total_count;
            END IF;

            /* get number of schema based views */
            IF (flag = 2) and (objtype = 4) THEN
              num_sb_vw := total_count;
            END IF;
          END;
        END LOOP;

    num_xdb_vw := num_nsb_vw + num_sb_vw;
    num_xdb_tbl := num_nsb_tbl + num_sb_tbl;

    /* count user created SB and NSB xml columns */
       OPEN cursor_objtype FOR q'[
             select count(*), o.type#, bitand(p.flags, 2)
             from sys.opqtype$ p, sys.obj$ o, sys.user$ u
             where o.obj# = p.obj# and p.type = 1 and
                   (o.type# = 2 or o.type# = 4) and
                   o.owner# = u.user# and u.name not in 
                     (select distinct username from dba_users 
                      where oracle_maintained = 'Y')
                   and u.name not in ('OE', 'SH', 'HR', 'SCOTT') and
                   u.name not like 'APEX_%'
                   and u.name not like 'FLOWS_%'
                   and (bitand(p.flags, 1) = 1 or bitand(p.flags, 4) = 4 or
                        bitand(p.flags, 68) = 68 or 
                        bitand(p.flags, 1024) = 1024)
             group by (bitand(p.flags, 2), o.type#)]';

        LOOP
          BEGIN
            FETCH cursor_objtype INTO total_count, objtype, flag;
            EXIT WHEN cursor_objtype%NOTFOUND;

            /* get number of non schema based tables */
            IF (flag = 0) and (objtype = 2) THEN
              num_nsb_tbl_noidx := total_count;
            END IF;

            /* get number of non schema based views */
            IF (flag = 0) and (objtype = 4) THEN
              num_nsb_vw_noidx := total_count;
            END IF;

            /* get number of schema based tables */
            IF (flag = 2) and (objtype = 2) THEN
              num_sb_tbl_noidx := total_count;
            END IF;

            /* get number of schema based views */
            IF (flag = 2) and (objtype = 4) THEN
              num_sb_vw_noidx := total_count;
            END IF;
          END;
        END LOOP;

    if (num_xdb_res > 0) or (num_xdb_schemas > 0) or
        (num_xdb_vw > 0) or (num_xdb_tbl > 0) then

        /* xdb is being used by user */
        OPEN cursor_objtype FOR q'[
             select count(*), bitand(p.flags, 69)
             from sys.opqtype$ p, sys.user$ u, sys.obj$ o
             where p.type = 1 and 
                  (bitand(p.flags, 1) = 1 or bitand(p.flags, 4) = 4 or 
                   bitand(p.flags, 68) = 68) and
                  p.obj# = o.obj# and
                  o.owner# = u.user# and u.name not in 
                    (select distinct username from dba_users 
                     where oracle_maintained = 'Y') 
                  and u.name not in ('OE', 'SH', 'HR', 'SCOTT') and 
                  u.name not like 'APEX_%' 
                  and u.name not like 'FLOWS_%'                
             group by (bitand(p.flags, 69))]';

        LOOP 
          BEGIN
            FETCH cursor_objtype INTO total_count, flag;
            EXIT WHEN cursor_objtype%NOTFOUND;

            /* get number of xmltype columns stored as object */
            IF flag = 1 THEN 
              num_st_or := total_count; 
            END IF;

            /* get number of xmltype columns stored as lob */
            IF flag = 4 THEN
              num_st_clob := total_count;
            END IF;

            /* get number of xmltype columns stored as binary */
            IF flag = 68 THEN
              num_st_bin := total_count;
            END IF;
          END;
        END LOOP;

        /* get number of resconfigs */ 
        execute immediate 'select count(*) from xdb.xdb$resconfig' into 
                                                        num_xdb_rc;
        /* get number of acls */ 
        execute immediate 'select count(*) from xdb.xdb$acl' into 
                                                        num_xdb_acl;

        /* get number of structured xml indexes */
        execute immediate q'[select count(1) from dba_xml_indexes 
                     where index_type = 'STRUCTURED' and 
                     index_owner not in
                     (select distinct username from dba_users 
                      where oracle_maintained = 'Y')
                     and index_owner not in ('OE', 'SH', 'HR', 'SCOTT')]'
                into num_xdb_sidx;
        
        /* get number of unstructured xml indexes */
        execute immediate q'[select count(1) from dba_xml_indexes
                     where index_type = 'UNSTRUCTURED' and 
                     index_owner not in
                     (select distinct username from dba_users 
                      where oracle_maintained = 'Y')
                     and index_owner not in ('OE', 'SH', 'HR', 'SCOTT')]'
                 into num_xdb_uidx;        

        /* get number of xml search indexes */
        execute immediate q'[select count(1) from ctxsys.dr$index i, 
                     sys.user$ u where i.idx_id in (select ixv_idx_id from
                     ctxsys.dr$index_value where IXV_OAT_ID = 50814) and 
                     i.idx_owner# = u.user# and u.name not in
                     (select distinct username from dba_users 
                      where oracle_maintained = 'Y') 
                     and u.name not in ('OE', 'SH', 'HR', 'SCOTT')]'
                     into num_xdb_tidx;

        feature_boolean := 1;
        aux_count := 0; 

        feature_usage := chr(10) ||
           '<xdb_feature_usage>'||
                chr(10)||chr(32)||chr(32)||
                '<user_resources>       '|| to_char(num_xdb_res)  || 
                ' </user_resources>'||
                chr(10) ||chr(32)||chr(32)||
                '<user_schemas>         '|| to_char(num_xdb_schemas) || 
                ' </user_schemas>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_columns>      '|| to_char(num_sb_tbl)   || 
                ' </user_SB_columns>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_columns>     '|| to_char(num_nsb_tbl)  || 
                ' </user_NSB_columns>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_views>        '|| to_char(num_sb_vw)    || 
                ' </user_SB_views>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_views>       '|| to_char(num_nsb_vw)   || 
                ' </user_NSB_views>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_columns_noidx> '|| to_char(num_sb_tbl_noidx) || 
                ' </user_SB_columns_noidx>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_columns_noidx>'|| to_char(num_nsb_tbl_noidx) || 
                ' </user_NSB_columns_noidx>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_views_noidx>   '|| to_char(num_sb_vw_noidx)   || 
                ' </user_SB_views_noidx>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_views_noidx>  '|| to_char(num_nsb_vw_noidx)  || 
                ' </user_NSB_views_noidx>'||
                chr(10)||chr(32)||chr(32)||
                '<user_OR_cols>         '|| to_char(num_st_or)    || 
                ' </user_OR_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<user_CLOB_cols>       '|| to_char(num_st_clob)  || 
                ' </user_CLOB_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<user_BINARY_cols>     '|| to_char(num_st_bin)   || 
                ' </user_BINARY_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<all_resconfigs>       '|| to_char(num_xdb_rc)   || 
                ' </all_resconfigs>'||
                chr(10)||chr(32)||chr(32)||
                '<all_acls>             '|| to_char(num_xdb_acl)  || 
                ' </all_acls>'||
                chr(10)||chr(32)||chr(32)||
                '<user_xml_SXIs>        '|| to_char(num_xdb_sidx) ||
                ' </user_xml_SXIs>'||
                chr(10)||chr(32)||chr(32)||
                '<user_xml_UXIs>        '|| to_char(num_xdb_uidx) ||
                ' </user_xml_UXIs>'||
                chr(10)||chr(32)||chr(32)||
                '<xml_search_idxes>     '|| to_char(num_xdb_tidx) ||
                ' </xml_search_idxes>'|| 
                chr(10) ||
           '</xdb_feature_usage>';
        
        feature_info := to_clob(feature_usage);
    else
        feature_boolean := 0;
        aux_count := 0; 
        feature_info := 
            to_clob('<xdb_feature_usage>SYSTEM</xdb_feature_usage>');
    end if;
 
end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_JSON
 *  The procedure to detect usage for JSON
 ***************************************************************/

create or replace procedure DBMS_FEATURE_JSON
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB )
AS
  num_json_cols         number := 0;
  num_clob_cols         number := 0;
  num_blob_cols         number := 0;
  num_raw_cols          number := 0;
  num_varchar2_cols     number := 0;
  num_json_view         number := 0;
  num_jv_view           number := 0;
  num_je_view           number := 0;
  num_jq_view           number := 0;
  num_jt_view           number := 0;
  num_dg_view           number := 0;
  num_min_rows          number := 0;
  num_max_rows          number := 0;
  num_avg_rows          number := 0;
  num_jv_fidx           number := 0;
  num_je_fidx           number := 0;
  num_jq_fidx           number := 0;
  num_json_cidx         number := 0;
  num_bson_cidx         number := 0;
  maxsize_jsoncol       number := 0;
  avgsize_jsoncol       number := 0;
  num_dataguides        number := 0;
  num_collections       number := 0;
  num_imcu_json         number := 0;
  num_imeu_json         number := 0;
  num_json_imc_enabled  number := 0;
  num_i_rows            number := 0;
  num_sn_rows           number := 0;
  num_dg_rows           number := 0;
  stmt                  varchar2(1000);
  table_not_found       EXCEPTION;
  PRAGMA exception_init(table_not_found, -942);
  CURSOR expr_cur IS
    SELECT COLUMN_EXPRESSION
    FROM DBA_IND_EXPRESSIONS; 
  expr   expr_cur%ROWTYPE; 
  c         clob; 
  TYPE      CurTyp IS REF CURSOR;
  cur       CurTyp;
  idxname1   dbms_id;
  uname1     dbms_id;   
  idxname2   dbms_quoted_id;
  uname2     dbms_quoted_id;   
BEGIN
  -- initialize
  feature_boolean := 0;
  aux_count := 0; 
  feature_info := '{ "version":1, ';

  /* get the number of json cols from dba_json_columns */
  execute immediate 'select count(1) from dba_json_columns
                     where owner not in 
                     (select distinct username from all_users             
                      where oracle_maintained = ''Y'')'
  into num_json_cols;

  /* Number of CLOB columns */
  execute immediate 'select count(1) from dba_json_columns
                     where data_type = ''CLOB'' and owner not in 
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_clob_cols;
  
  /* Number of BLOB columns */
  execute immediate 'select count(1) from dba_json_columns
                     where data_type = ''BLOB'' and owner not in 
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_blob_cols;

  /* Number of RAW columns */
  execute immediate 'select count(1) from dba_json_columns
                     where data_type = ''RAW'' and owner not in 
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_raw_cols;

  /* Number of varchar columns */
  execute immediate 'select count(1) from dba_json_columns
                     where data_type = ''VARCHAR2'' and owner not in 
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_varchar2_cols;

  /* Write Storage stats into clob */
  dbms_lob.append(feature_info, to_clob ('"jsonColumns": {' ||
                  '"total":' || to_char(num_json_cols) || ' , ' ||
                  '"varchar2":' || to_char(num_varchar2_cols) || ' , ' ||
                  '"clob":' || to_char(num_clob_cols) || ' , ' ||
                  '"blob":' || to_char(num_blob_cols) || ' , ' ||
                  '"raw":'  || to_char(num_raw_cols)  || ' }, '));

  /* Get the min, max and avg size of the JSON tables */
  execute immediate 'select max(num_rows) from dba_tables where 
                     table_name in (select table_name 
                     from dba_json_columns where owner not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y''))'
  into num_max_rows;

  execute immediate 'select min(num_rows) from dba_tables where 
                     table_name in (select table_name 
                     from dba_json_columns where owner not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y''))'
  into num_min_rows;
  
  execute immediate 'select avg(num_rows) from dba_tables where 
                     table_name in (select table_name 
                     from dba_json_columns where owner not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y''))'
  into num_avg_rows;

  if num_max_rows is null then
    num_max_rows := 0;
  end if;

  if num_min_rows is null then
    num_min_rows := 0;
  end if;

  if num_avg_rows is null then
    num_avg_rows := 0;
  end if;

  /* Write row count stats into clob */
  dbms_lob.append(feature_info, to_clob ('"rowCount": {' ||
                  '"maxCount":' || to_char(num_max_rows) || ' , ' ||
                  '"minCount":' || to_char(num_min_rows) || ' , ' ||
                  '"avgCount":' || to_char(num_avg_rows) || ' }, '));

  /* Get size of JSON column */
  /* Average length in bytes */
  execute immediate 'select nvl(avg(avg_col_len),0) from dba_tab_columns t, 
                     dba_json_columns j where t.owner not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')
                     and t.table_name = j.table_name 
                     and t.column_name = j.column_name'
  into avgsize_jsoncol;

  /* Max length in chars */
  execute immediate 'select nvl(max(char_length),0) from dba_tab_columns t, 
                     dba_json_columns j where t.owner not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')
                     and t.table_name = j.table_name 
                     and t.column_name = j.column_name'
  into maxsize_jsoncol;

  /* Write row size stats into clob */
  dbms_lob.append(feature_info, to_clob ('"rowSize": {' ||
                  '"avgSizeBytes":' || to_char(avgsize_jsoncol) || ' , ' ||
                  '"maxSizeChars":' || to_char(maxsize_jsoncol) || ' }, '));

  /* IMC related stats */
  /* JSON stored in IMCUs */
  execute immediate 'select count(1) from v$im_col_cu a, sys.col$ b,
                                           dba_json_columns j, obj$ o
                      where a.objd = b.obj# and 
                            b.obj# = o.obj# and
                            a.column_number = b.segcol# and 
                            b.name = j.column_name and 
                            o.name = j.table_name'
  into num_imcu_json;

  /* OSON corresponding to JSON stored in IMEUs */
  execute immediate 'select count(1) from v$im_imecol_cu a, sys.col$ b 
                     where a.objd = b.obj# and 
                           a.internal_column_number = b.intcol# and 
                           b.name like ''SYS_IME_OSON%'''
  into num_imeu_json;

  /* Get number of JSON cols/tables which have just been enabled for IMC */
  execute immediate 'select count(1) from x$kdzcolcl x, dba_json_columns j 
                    where x.column_name = j.column_name and 
                          x.table_name = j.table_name and 
                          x.owner = j.owner'
  into num_json_imc_enabled;
 
  /* Write row size stats into clob */
  dbms_lob.append(feature_info, to_clob ('"IMCStats": {' ||
                  '"IMCU#":' || to_char(num_imcu_json) || ' , ' ||
                  '"IMEU#":' || to_char(num_imeu_json) || ' , ' ||
                  '"JSONIMC#":' || to_char(num_json_imc_enabled) || ' }, '));

  /* Get the JSON view stats */
  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_VALUE%'' and owner 
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_jv_view;

  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_EXISTS%'' and owner
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_je_view;

  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_QUERY%'' and owner
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_jq_view;

  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_TABLE%'' and owner
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_jt_view;

  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_DATAGUIDE%'' and owner
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_dg_view;

  execute immediate 'select count(1) from dba_views where 
                     upper(text_vc) like ''%JSON_%'' and owner
                     not in (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_json_view;

  /* Write JSON view stats into clob */
  dbms_lob.append(feature_info, to_clob ('"views": {' ||
                  '"total":' || to_char(num_json_view) || ' , ' ||
                  '"jsonValue":'  || to_char(num_jv_view) || ' , ' ||
                  '"jsonExists":' || to_char(num_je_view) || ' , ' ||
                  '"jsonQuery":'  || to_char(num_jq_view) || ' , ' ||
                  '"jsonTable":'  || to_char(num_jt_view) || ' , ' ||
                  '"jsonDataGuide":'  || to_char(num_dg_view) || ' }, '));

  /* Indexes */

  /* Get JSON Functional Index stats */
  OPEN expr_cur;
  LOOP
      FETCH expr_cur INTO expr;
      EXIT WHEN expr_cur%NOTFOUND;
      c := to_clob(expr.COLUMN_EXPRESSION);
      if (upper(c) like '%JSON_VALUE%') then
        num_jv_fidx := num_jv_fidx + 1;
      elsif (upper(c) like '%JSON_EXISTS%') then
        num_je_fidx := num_je_fidx + 1;
      elsif (upper(c) like '%JSON_QUERY%') then
        num_jq_fidx := num_jq_fidx + 1;
      end if;
  END LOOP;
  CLOSE expr_cur; 

  /* Write JSON view stats into clob */
  dbms_lob.append(feature_info, to_clob ('"funcIdx": {' ||
                  '"jsonValue":'  || to_char(num_jv_fidx) || ' , ' ||
                  '"jsonExists":' || to_char(num_je_fidx) || ' , ' ||
                  '"jsonQuery":'  || to_char(num_jq_fidx) || ' }, '));


  dbms_lob.append(feature_info, to_clob ('"searchIdxStats": {' ));
  /* Get JSON text indexes stats */
  stmt:= 'select i.idx_name, u.username 
          from ctxsys.dr$index i, all_users u
          where i.idx_id in ( select ixv_idx_id 
                              from ctxsys.dr$index_value 
                              where IXV_OAT_ID = 50817) and
                i.idx_owner# = u.user_id and u.username not in
                                 (select distinct username 
                                  from all_users
                                  where oracle_maintained = ''Y'')';
  open cur for stmt;
    LOOP
      fetch cur into idxname1, uname1;
      exit when cur%notfound;

      idxname2 := DBMS_ASSERT.ENQUOTE_NAME(idxname1, false);
      uname2   := DBMS_ASSERT.ENQUOTE_NAME(uname1, false);

      num_json_cidx := num_json_cidx + 1;
    begin 
      stmt := 'select count(*) from ' || uname2 || '.' || 
              dbms_assert.enquote_name('DR$'||idxname1||'$I', FALSE);
      execute immediate stmt into num_i_rows;
    exception
      when table_not_found then
        null;
    end;    

    begin
      stmt := 'select count(*) from ' || uname2 || '.' ||
              dbms_assert.enquote_name('DR$'||idxname1||'$SN', FALSE);
      execute immediate stmt into num_sn_rows;
    exception
      when table_not_found then
        null;
    end;    

    begin
      stmt := 'select count(*) from ' || uname2 || '.' ||
              dbms_assert.enquote_name('DR$'||idxname1||'$DG', FALSE);
      execute immediate stmt into num_dg_rows;
    exception
      when table_not_found then
        null;
    end;    

    dbms_lob.append(feature_info, to_clob ('"Index-Stats": {' ||
                  '"indexName":' || idxname2 || ' , ' ||
                  '"num$IRows":' || to_char(num_i_rows) || ' , ' ||
                  '"num$SNRows":' || to_char(num_sn_rows) || ' , ' ||
                  '"num$DGRows":' || to_char(num_dg_rows)  || ' }, '));
  END LOOP;  
  dbms_lob.append(feature_info, to_clob ('},'));

  begin
  execute immediate 'select count(1) from ctxsys.dr$index i, sys.user$ u 
                     where i.idx_id in (select ixv_idx_id from 
                     ctxsys.dr$index_value where IXV_OAT_ID = 50819) and
                     i.idx_owner# = u.user# and u.name not in
                     (select distinct username from all_users
                      where oracle_maintained = ''Y'')'
  into num_bson_cidx;
  exception
    when OTHERS then
       num_bson_cidx := 0;
  end;

  /* Write JSON Search index stats into clob */
  dbms_lob.append(feature_info, to_clob ('"searchIdx": {' ||
                  '"jsonSearchIdx":' || to_char(num_json_cidx) || ' , ' ||
                  '"bsonSearchIdx":' || to_char(num_bson_cidx)  || ' }, '));

  /* Get the JSON dataguide stats*/
  execute immediate 'select count(1) from ALL_JSON_DATAGUIDES'
  into num_dataguides;

  /* Write JSON dataguide stats into clob */
  dbms_lob.append(feature_info, to_clob ('"dataguideStats": {' ||
                  '"numDataguide":' || to_char(num_dataguides) || ' }, '));
        
  /* Get the SODA JSON stats*/
  execute immediate 'select count(1) from XDB.JSON$COLLECTION_METADATA'
  into num_collections;

  /* Write SODA JSON stats into clob */
  dbms_lob.append(feature_info, to_clob ('"sodaStats": {' ||
                  '"numCollections":' || to_char(num_collections) || ' } } '));
        
  /* set feature_boolean if reqd */
  IF num_json_cols > 0 THEN
    feature_boolean := 1;                    
  END IF;
END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_APEX
 *  The procedure to detect usage for Application Express 
 ***************************************************************/

create or replace procedure DBMS_FEATURE_APEX
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
    l_apex_schema   dbms_id := null;
    l_num_apps      number := 0;
    l_num_views     number := 0;
    l_num_workspace number := 0;
    l_num_users     number := 0;
begin
    /* Determine current schema for Application Express
       Note: this will only return one row              */
    for c1 in (select schema
                 from dba_registry
                where comp_id = 'APEX' ) loop
        l_apex_schema := dbms_assert.enquote_name(c1.schema, FALSE);
    end loop;

    /* If not found, then APEX is not installed */
    if l_apex_schema is null then
        feature_boolean := 0;
        aux_count := 0;
        feature_info := to_clob('APEX usage not detected');
        return;
    end if;

       /* Determine the number of workspaces */
       execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flow_companies
 where provisioning_company_id not in (0,10,11,12)' into l_num_workspace;

    if l_num_workspace > 0 then

       /* Determine the number of user-created applications */
       execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flows
 where security_group_id not in (10,11,12)' into l_num_apps;

       /* Determine the number of non-internal Application Express users */
       execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flow_fnd_user
 where security_group_id not in (10,11,12)' into l_num_users;

       /* Determine number of page views in the last 30 days */
       execute immediate 'select nvl(sum(page_views),0)
  from '||l_apex_schema||'.wwv_flow_log_history
 where log_day > sysdate -30' into l_num_views;

       feature_boolean := 1;
       aux_count := l_num_apps;
       feature_info := to_clob('Number of applications: '||to_char(l_num_apps)||
       ', '||'Number of workspaces: '||to_char(l_num_workspace)||
       ', '||'Number of users: '||to_char(l_num_users))||
       ', '||'Page views last 30 days: '||to_char(l_num_views);

    else
       feature_boolean := 0;
       aux_count := 0;
       feature_info := to_clob('APEX usage not detected');
    end if;

end DBMS_FEATURE_APEX;
/

/***************************************************************
 * DBMS_FEATURE_OBJECT
 *  The procedure to detect usage for OBJECT 
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_OBJECT
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  num_obj_types         number;
  num_obj_tables        number;
  num_obj_columns       number;
  num_obj_views         number;
  num_anydata_cols      number;
  num_nt_cols           number;
  num_varray_cols       number;
  num_octs              number;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_coltype        cursor_t;
  total_count           number;
  flag                  number;

BEGIN
  --initialize
  num_obj_types         :=0;
  num_obj_tables        :=0;
  num_obj_columns       :=0;
  num_obj_views         :=0;
  num_anydata_cols      :=0;
  num_nt_cols           :=0;
  num_varray_cols       :=0;
  num_octs              :=0;
  total_count           :=0;
  flag                  :=0;

  feature_boolean := 0;
  aux_count := 0;

  /* get number of object types */
  execute immediate 'select count(*) from sys.type$ t, sys.obj$ o, sys.user$ u 
          where o.owner# = u.user# and o.oid$ = t.tvoid and 
            u.name not in (select schema_name from v$sysaux_occupants) and
            u.name not in (''OE'', ''IX'', ''PM'', ''DVSYS'', 
                           ''LBACSYS'', ''GSMADMIN_INTERNAL'') and
            u.name not like ''FLOWS_%'' and
            u.name not like ''APEX_%'''
          into num_obj_types;

  /* get number of object tables */
  execute immediate 'select count(*) from  sys.tab$ t, sys.obj$ o, sys.user$ u
          where o.owner# = u.user# and o.obj# = t.obj# and
                bitand(t.property, 1) = 1 and bitand(o.flags, 128) = 0 and
                u.name not in (select schema_name from v$sysaux_occupants) and
                u.name not in (''OE'', ''PM'', ''GSMADMIN_INTERNAL'') and
                u.name not like ''FLOWS_%'' and
                u.name not like ''APEX_%'''
          into num_obj_tables;
 

  /* get number of object views */ 
  execute immediate 'select count(*) from sys.typed_view$ t, sys.obj$ o, sys.user$ u
          where o.owner# = u.user# and o.obj# = t.obj# and
                u.name not in (select schema_name from v$sysaux_occupants) and
                u.name not in (''OE'', ''DVSYS'') and
                u.name not like ''FLOWS_%'' and
                u.name not like ''APEX_%'''
          into num_obj_views;

  /* get number of object columns, nested table columns, varray columns,
   * anydata columns and OCTs
   */  
  OPEN cursor_coltype FOR '
    select /*+ index(o i_obj1) */ count(*), bitand(t.flags, 16414)
    from sys.coltype$ t, sys.obj$ o, sys.user$ u
    where o.owner# = u.user# and o.obj# = t.obj# and
          u.name not in (select schema_name from v$sysaux_occupants) and
          u.name not in (''OE'', ''IX'', ''PM'', ''DVSYS'', 
                         ''GSMADMIN_INTERNAL'') and
          u.name not like ''FLOWS_%'' and
          u.name not like ''APEX_%'' and
          ((bitand(t.flags, 30) != 0) OR
           (bitand(t.flags, 16384) = 16384 and
            t.toid = ''00000000000000000000000000020011''))
    group by (bitand(t.flags, 16414))';


  LOOP
    BEGIN
      FETCH cursor_coltype INTO total_count, flag;
      EXIT WHEN cursor_coltype%NOTFOUND;

      /* number of nested table columns */
      IF flag = 4 THEN
        num_nt_cols := total_count;
      END IF;

      /* number of varray columns */
      IF flag = 8 THEN
        num_varray_cols := total_count;
      END IF;

      /* number of OCTs */
      IF flag = 12 THEN
        num_octs := total_count;
      END IF;

      /* number of adt and ref columns */
      IF (flag = 2 or flag = 16) THEN
        num_obj_columns  := num_obj_columns + total_count;
      END IF;

      /* number of anydata columns */
      IF (flag = 16384) THEN
        num_anydata_cols := total_count;
      END IF;
    END;
  END LOOP;

  if ((num_obj_types > 0) OR (num_obj_tables > 0) OR (num_obj_columns >0)
      OR (num_obj_views > 0) OR (num_anydata_cols > 0) OR (num_nt_cols > 0)
      OR (num_varray_cols > 0) OR (num_octs > 0)) then

    feature_boolean := 1;  
    feature_usage := 'num of object types: ' || to_char(num_obj_types) ||
        ',' || 'num of object tables: ' || to_char(num_obj_tables) ||
        ',' || 'num of adt and ref columns: ' || to_char(num_obj_columns) ||
        ',' || 'num of object views: ' || to_char(num_obj_views) ||
        ',' || 'num of anydata cols: ' || to_char(num_anydata_cols) ||
        ',' || 'num of nested table cols: ' || to_char(num_nt_cols) ||
        ',' || 'num of varray cols: ' || to_char(num_varray_cols) ||
        ',' || 'num of octs: ' || to_char(num_octs);

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('OBJECT usage not detected');
  end if;

end;
/
 
/***************************************************************
 * DBMS_FEATURE_EXTENSIBILITY
 *  The procedure to detect usage for EXTENSIBILITY 
 ***************************************************************/
  
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_EXTENSIBILITY
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB) 
AS
  num_user_opts         number;
  num_user_aggs         number;
  num_table_funs        number;
  num_idx_types         number;
  num_domain_idxs       number;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_udftype        cursor_t;
  total_count           number;
  flag                  number;

begin
  --initialize
  num_user_opts         :=0;
  num_user_aggs         :=0;
  num_table_funs        :=0;
  num_idx_types         :=0;
  num_domain_idxs       :=0;
  total_count           :=0;
  flag                  :=0;


  feature_boolean := 0;
  aux_count := 0;

  /* get number of user-defined operators */
  execute immediate 'select count(*) from DBA_OPERATORS
          where owner not in (select schema_name from v$sysaux_occupants)
          and owner not in (''SH'')'
          into num_user_opts;

  /* get number of user-defined index types */
  execute immediate 'select count(*) 
          from sys.indtypes$ i, sys.user$ u, sys.obj$ o
          where i.obj# = o.obj# and o.owner# = u.user# and
                u.name not in (select schema_name from v$sysaux_occupants)
                and u.name not in (''SH'')'
          into num_idx_types;

  /* get number of user-defined domain indexes */
  execute immediate 'select count(*) from sys.user$ u, sys.ind$ i, sys.obj$ o
          where u.user# = o.owner# and o.obj# = i.obj# and
                i.type# = 9 and
                u.name not in (select schema_name from v$sysaux_occupants)
                and u.name not in (''SH'')'
          into num_domain_idxs; 

  /* get number of user-defined aggregates and user-defined 
   * pipelined table functions
   */
  OPEN cursor_udftype FOR '
    select count(*), bitand(p.properties, 24)
    from sys.obj$ o, sys.user$ u, sys.procedureinfo$ p
    where o.owner# = u.user# and o.obj# = p.obj# and
          bitand(p.properties, 24) != 0 and
          u.name not in (select schema_name from v$sysaux_occupants)
          and u.name not in (''SH'', ''DVSYS'')
    group by (bitand(p.properties, 24))';

  LOOP
    BEGIN
      FETCH cursor_udftype INTO total_count, flag;
      EXIT WHEN cursor_udftype%NOTFOUND;

      IF flag = 8 THEN
        num_user_aggs := total_count;
      END IF;

      IF flag = 16 THEN
        num_table_funs := total_count;
      END IF;
    END;
  END LOOP; 
   
  if ((num_user_opts > 0) OR (num_user_aggs > 0) OR (num_table_funs > 0)
      OR (num_idx_types > 0) OR (num_domain_idxs > 0)) then
    feature_boolean := 1;
    feature_usage := 'num of user-defined operators: ' || to_char(num_user_opts) ||
        ',' || 'num of user-defined aggregates: ' || to_char(num_user_aggs) ||
        ',' || 'num of table functions: ' || to_char(num_table_funs) ||
        ',' || 'num of index types: ' || to_char(num_idx_types) ||
        ',' || 'num of domain indexes: ' || to_char(num_domain_idxs);

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('EXTENSIBILITY usage not detected');
  end if;
 
end;
/

/***************************************************************
 * DBMS_FEATURE_RULESMANAGER
 *  The procedure to detect usage for RULES MANAGER & EXPRESSION FILTER
 ***************************************************************/
  
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RULESMANAGER
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB) 
AS
  num_rule_clss        number := 0; 
  num_comp_rulcls       number := 0; 
  max_pmevt_prcmp       number := 0; 
  avg_pmevt_prcmp       number := 0; 
  num_cllt_evts         number := 0; 
  num_pure_expcols      number := 0; 
  num_domain_idxs       number;

  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_udftype        cursor_t;
  total_count           number;
  flag                  number;

begin
  --initialize
  feature_boolean := 0;
  aux_count := 0;

  /* get the number of rule classes */ 
  begin  
    execute immediate 'select count(*) from exfsys.adm_rlmgr_rule_classes'
                          into num_rule_clss; 
  exception 
    when others then 
       num_rule_clss := 0; 
  end; 

  if (num_rule_clss > 0) then 
    /* get the numbers on rule classes with composite events */ 
    execute immediate 'select count(*), avg(prmevtprc), max(prmevtprc) 
     from (select count(*) as prmevtprc from 
           exfsys.adm_rlmgr_comprcls_properties
           group by rule_class_owner, rule_class_name) ' into 
         num_comp_rulcls, avg_pmevt_prcmp, max_pmevt_prcmp;

    /* rule class with collection events */
    execute immediate 'select count(*) from 
            exfsys.adm_rlmgr_comprcls_properties
              where collection_enb = ''Y''' into num_cllt_evts;
  end if; 

  /* expression columns outside the context of rule classes */ 
  execute immediate 'select count(*) from exfsys.adm_expfil_expression_sets
     where not(expr_column like ''RLM$%'')' into num_pure_expcols;
   
  if ((num_rule_clss > 0) OR (num_comp_rulcls > 0) OR (avg_pmevt_prcmp > 0)
      OR (max_pmevt_prcmp > 0) OR (num_pure_expcols > 0)) then
    feature_boolean := 1; 
    feature_usage :=
       'num of rule classes: '||to_char(num_rule_clss) ||', '||
       'num of rule classes with composite events: '||
                          to_char(num_comp_rulcls) ||', '||
       'avg num of primitive events per composite: '||
                          to_char(avg_pmevt_prcmp) ||', '||
       'max num of primitive events for a rule class: '||
                          to_char(max_pmevt_prcmp) ||', '||
       'num expression columns(user): '||
                          to_char(num_pure_expcols); 
     feature_info := to_clob(feature_usage);
  else
     feature_info := to_clob(
              'Rules Manager/Expression Filter usage not detected');  
  end if;
 
end;
/


/***************************************************************
 * DBMS_FEATURE_SERVICES
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_services
      (is_used OUT number, hwm OUT number, feature_info OUT clob)
AS
  -- Based off dba_services
  num_clb_long                            NUMBER := 0;
  num_clb_short                           NUMBER := 0;
  num_goal_service_time                   NUMBER := 0;
  num_goal_throughput                     NUMBER := 0;
  num_goal_none                           NUMBER := 0;
  num_goal_null                           NUMBER := 0;
  num_aq_notifications                    NUMBER := 0;

  -- Based off gv$active_services
  num_active_svcs                         NUMBER := 0;
  num_active_svcs_wo_distinct             NUMBER := 0;
  avg_active_cardinality                  NUMBER := 0;

  default_service_name                    varchar2(1000);
  default_xdb_service_name                varchar2(1000);
  db_domain                               varchar2(1000);

BEGIN
  -- initialize
  is_used      := 0;
  hwm          := 0;
  feature_info := 'Services usage not detected';

  -- get default service name - db_unique_name[.db_domain]

  SELECT value INTO default_service_name FROM v$parameter WHERE
        lower(name) = 'db_unique_name';

  SELECT value INTO db_domain FROM v$parameter WHERE
        lower(name) = 'db_domain';

  -- create default XDB service name
  default_xdb_service_name := default_service_name || 'XDB';

  -- append db_domain if it is set
  IF db_domain IS NOT NULL then
    default_service_name := default_service_name || '.' || db_domain;
  END IF;

  SELECT count(*) INTO hwm
  FROM dba_services
  WHERE 
      NAME NOT LIKE 'SYS$%'
  AND NETWORK_NAME NOT LIKE 'SYS$%'
  AND NAME <> default_xdb_service_name
  AND NAME <> default_service_name;

  IF hwm > 0 THEN
    is_used := 1;
  END IF;

  -- if services is used 
  IF (is_used = 1) THEN

    -- Get the counts for CLB_GOAL variations
    FOR item IN (
      SELECT clb_goal, count(*) cg_count
      FROM dba_services
      where 
          NAME NOT LIKE 'SYS$%'
      AND NETWORK_NAME NOT LIKE 'SYS$%'
      AND NAME <> default_xdb_service_name
      AND NAME <> default_service_name
      GROUP BY clb_goal) 

    LOOP

      IF item.clb_goal = 'SHORT' THEN
        num_clb_short := item.cg_count;
      ELSIF item.clb_goal = 'LONG' THEN
        num_clb_long  := item.cg_count;
      END IF;

    END LOOP;

    
    -- Get the counts for GOAL variations
    FOR item IN (
      SELECT goal, count(*) g_count
      FROM dba_services
      where 
          NAME NOT LIKE 'SYS$%'
      AND NETWORK_NAME NOT LIKE 'SYS$%'
      AND NAME <> default_xdb_service_name
      AND NAME <> default_service_name
      GROUP BY goal) 

    LOOP

      IF item.goal = 'SERVICE_TIME' THEN
        num_goal_service_time := item.g_count;
      ELSIF item.goal = 'THROUGHPUT' THEN
        num_goal_throughput  := item.g_count;
      ELSIF item.goal = 'NONE' THEN
        num_goal_none := item.g_count;
      ELSIF item.goal is NULL THEN
        num_goal_null := item.g_count;
      END IF;

    END LOOP;

    -- count goal is NULL as goal = NONE
    num_goal_none := num_goal_none + num_goal_null;

    -- Get the count for aq_ha_notifications
    SELECT count(*) into num_aq_notifications
    FROM dba_services
    where 
        NAME NOT LIKE 'SYS$%'
    AND NETWORK_NAME NOT LIKE 'SYS$%'
    AND NAME <> default_xdb_service_name
    AND NAME <> default_service_name
    AND AQ_HA_NOTIFICATIONS = 'YES';


    SELECT count(distinct name), count(*)
      INTO num_active_svcs, num_active_svcs_wo_distinct
    FROM gv$active_services
    WHERE 
        NAME NOT LIKE 'SYS$%'
    AND NETWORK_NAME NOT LIKE 'SYS$%'
    AND NAME <> default_xdb_service_name
    AND NAME <> default_service_name;

    IF num_active_svcs > 0 THEN

      avg_active_cardinality := 
        round(num_active_svcs_wo_distinct / num_active_svcs);

    END IF;

    feature_info := 
        ' num_clb_long: '          || num_clb_long
      ||' num_clb_short: '         || num_clb_short
      ||' num_goal_service_time: ' || num_goal_service_time
      ||' num_goal_throughput: '   || num_goal_throughput
      ||' num_goal_none: '         || num_goal_none
      ||' num_aq_notifications: '  || num_aq_notifications
      ||' num_active_services: '   || num_active_svcs
      ||' avg_active_cardinality: '|| avg_active_cardinality;

  END IF;

END;
/

/***************************************************************
 * DBMS_FEATURE_STREAMS(system)
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_streams
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_prop                                NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_prop                         := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','XSTREAM_OUT');

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','XSTREAM_OUT')
       and UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','GOLDENGATE APPLY',
                                  'XSTREAM IN', 'XSTREAM OUT');

  select decode (count(*), 0, 0, 1) into num_prop from dba_propagation;

  total_feature_usage := num_capture + num_apply + num_prop; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' prop:'                 || num_prop;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_prop > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_streams;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_XSTREAM_OUT
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_out
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM OUT';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM OUT' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM OUT';


  total_feature_usage := num_capture + num_apply; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_out;
/

show errors;

/*************************************************
 *   Database Feature Usage VPD                  *
 *   Procedure to detect usage for VPD           *
 *************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_VPD
  (feature_boolean OUT NUMBER,
   aux_count       OUT NUMBER,
   feature_info    OUT CLOB)
AS
  num_policies                    NUMBER := 0;
  num_enabled_policies            NUMBER := 0;
  num_objects_using_VPD           NUMBER := 0;
  num_policies_on_select          NUMBER := 0;
  num_policies_on_insert          NUMBER := 0;
  num_policies_on_update          NUMBER := 0;
  num_policies_on_index           NUMBER := 0;
  num_policies_on_delete          NUMBER := 0;
  num_policies_dynamic            NUMBER := 0;
  num_policies_static             NUMBER := 0;
  num_policies_column_level       NUMBER := 0;
  num_policies_context_sensitive  NUMBER := 0;
  num_policies_shared_CS          NUMBER := 0;
  num_policies_FG_CS              NUMBER := 0;
  num_policies_shared_static      NUMBER := 0;
  num_policies_long_pred          NUMBER := 0;
  num_common_policies             NUMBER := 0;
  num_inherited_policies          NUMBER := 0;
  feature_usage_str               VARCHAR2(5000) := NULL;
  user_array dbms_utility.maxname_array;

BEGIN
  -- initialize --
  feature_boolean := 0;
  aux_count       := 0;
  feature_info    := NULL;
  user_array(1)   := 'SYSMAN';
  user_array(2)   := 'SYSMAN_MDS';
  user_array(3)   := 'OE';
  -------------------------  GLOBAL INFORMATION  -------------------------

  -- No. of VPD policies
  SELECT count(*) INTO num_policies FROM dba_policies
  WHERE object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and object_owner NOT IN (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of enabled VPD policies
  SELECT count(*) INTO num_enabled_policies FROM dba_policies
  WHERE enable = 'YES' and object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and object_owner NOT IN (SELECT COLUMN_VALUE FROM TABLE(user_array));

  --  No. of objects that have VPD Policies  --
  SELECT count (*) INTO num_objects_using_vpd 
  FROM (SELECT object_name, object_owner FROM dba_policies 
    WHERE dba_policies.object_owner NOT IN
      (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
      and dba_policies.object_owner NOT IN
      (SELECT COLUMN_VALUE FROM TABLE(user_array))
    GROUP BY object_name, object_owner);

  --  No. of policies on SELECT statement  --
  SELECT count (*) INTO num_policies_on_select
  FROM dba_policies WHERE sel = 'YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of policies on INSERT statement --
  SELECT count (*) INTO num_policies_on_insert
  FROM dba_policies WHERE ins = 'YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of policies on UPDATE statement --
  SELECT count (*) INTO num_policies_on_update
  FROM dba_policies WHERE upd = 'YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of policies on DELETE statement --
  SELECT count (*) INTO num_policies_on_delete
  FROM dba_policies WHERE del = 'YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of policies on INDEX statement --
  SELECT count (*) INTO num_policies_on_index
  FROM dba_policies WHERE idx = 'YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of dynamic policies --
  SELECT count (*) INTO num_policies_dynamic
  FROM dba_policies WHERE policy_type = 'DYNAMIC' and dba_policies.object_owner
    NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array));

  -- No. of static policies --
  SELECT count (*) INTO num_policies_static
  FROM dba_policies WHERE policy_type = 'STATIC' and dba_policies.object_owner
    NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of shared_static policies --
  SELECT count (*) INTO num_policies_shared_static
  FROM dba_policies WHERE policy_type = 'SHARED_STATIC' and 
    dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of context_sensitive policies --
  SELECT count (*) INTO num_policies_context_sensitive
  FROM dba_policies WHERE policy_type = 'CONTEXT_SENSITIVE' and 
    dba_policies.object_owner NOT IN 
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of shared_context_sensitive policies --
  SELECT count (*) INTO num_policies_shared_CS
  FROM dba_policies WHERE policy_type = 'SHARED_CONTEXT_SENSITIVE' and 
    dba_policies.object_owner NOT IN 
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of fine grained context sensitive VPD policies --
  SELECT count (*) INTO num_policies_FG_CS FROM
    (SELECT DISTINCT policy_group, policy_name
    FROM dba_policy_attributes WHERE object_owner NOT IN
      (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
      and object_owner NOT IN (SELECT COLUMN_VALUE FROM TABLE(user_array))); 

  -- No. of policies with long predicates --
  SELECT count(*) INTO num_policies_long_pred
  FROM dba_policies WHERE long_predicate = 'YES' AND
    dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of column level policies --
  SELECT count (*) INTO num_policies_column_level FROM
    (SELECT DISTINCT object_owner, object_name, policy_name
    FROM dba_sec_relevant_cols dsrc WHERE dsrc.object_owner NOT IN 
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dsrc.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array))); 

  -- No. of common policies in federation --
  SELECT count (*) INTO num_common_policies
  FROM dba_policies WHERE common='YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- No. of inherited policies in federation --
  SELECT count(*) INTO num_inherited_policies
  FROM dba_policies WHERE inherited='YES' and dba_policies.object_owner NOT IN
    (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
    and dba_policies.object_owner NOT IN
    (SELECT COLUMN_VALUE FROM TABLE(user_array)); 

  -- Feature used if there are VPD security policies --
  IF (num_policies > 0) THEN
    feature_boolean := 1;
  END IF;

  -- Create string with all policies information --
  feature_usage_str := 'Number of policies='
    || to_char (num_policies)
    || ', Number of enabled policies='
    || to_char (num_enabled_policies)
    || ', Number of objects that have VPD policies='
    || to_char (num_objects_using_VPD)
    || ', Number of policies on SELECT statement='
    || to_char (num_policies_on_select)
    || ', Number of policies on INSERT statement='
    || to_char (num_policies_on_insert)
    || ', Number of policies on UPDATE statement='
    || to_char (num_policies_on_update)
    || ', Number of policies on DELETE statement='
    || to_char (num_policies_on_delete)
    || ', Number of policies on INDEX statement='
    || to_char (num_policies_on_index)
    || ', Number of DYNAMIC policies='
    || to_char (num_policies_dynamic)
    || ', Number of STATIC policies='
    || to_char (num_policies_static)
    || ', Number of SHARED_STATIC policies='
    || to_char (num_policies_shared_static)
    || ', Number of CONTEXT_SENSITIVE policies='
    || to_char (num_policies_context_sensitive)
    || ', Number of SHARED_CONTEXT_SENSITIVE policies='
    || to_char (num_policies_shared_CS)
    || ', Number of attribute associated CONTEXT_SENSITIVE policies='
    || to_char (num_policies_FG_CS)
    || ', Number of policies with long predicate='
    || to_char (num_policies_long_pred)
    || ', Number of COLUMN LEVEL policies='
    || to_char (num_policies_column_level)
    || ', Number of COMMON policies='
    || to_char (num_common_policies)
    || ', Number of INHERITED policies='
    || to_char (num_inherited_policies)
    || feature_usage_str;

  ----  Return feature usage string  ----
  feature_info := to_clob(feature_usage_str);

END dbms_feature_VPD;
/
show errors;

/***************************************************************
 *  DBMS_FEATURE_XSTREAM_IN                                    *
 *  The procedure to detect usage for Services                 *
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_in
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_apply                               NUMBER;
  feature_usage                           VARCHAR2(2000);
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_apply                        := 0;
  feature_usage                    := NULL;

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM IN';

  feature_usage := feature_usage ||
        'app:'                   || num_apply;

  feature_info   := to_clob(feature_usage);
  if (num_apply > 0) THEN
      feature_boolean := 1;
      aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_in;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_XSTREAM_STREAMS
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_streams
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_prop                                NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_prop                         := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM STREAMS';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM STREAMS' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM STREAMS';

  select decode (count(*), 0, 0, 1) into num_prop from dba_propagation;

  total_feature_usage := num_capture + num_apply + num_prop; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' prop:'                 || num_prop;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_prop > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_streams;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_GOLDENGATE
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_goldengate
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  -- Based on goldengate usage
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_trigger_suppression                 NUMBER;
  num_transient_duplicate                 NUMBER;
  num_dblogreader                         NUMBER;
  num_ggsddltrigopt                       NUMBER;
  feature_usage                           VARCHAR2(4000);
  total_feature_usage                     NUMBER;
  num_dbencryption                        NUMBER;
  num_ggsession                           NUMBER;
  num_delcascadehint                      NUMBER;
  num_suplog                              NUMBER;
  num_procrepl                            NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_trigger_suppression          := 0;
  num_transient_duplicate          := 0;
  num_dblogreader                  := 0;
  num_ggsddltrigopt                := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;
  num_dbencryption                 := 0;
  num_ggsession                    := 0;
  num_delcascadehint               := 0;
  num_suplog                       := 0;
  num_procrepl                     := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'GOLDENGATE CAPTURE';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'GOLDENGATE CAPTURE' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply from dba_apply 
     where UPPER(purpose) IN ('GOLDENGATE APPLY', 'GOLDENGATE CAPTURE');

  select sum(count) into num_dblogreader 
     from GV$GOLDENGATE_CAPABILITIES where name like 'DBLOGREADER';
  
  select sum(count) into num_transient_duplicate
     from GV$GOLDENGATE_CAPABILITIES where name like 'TRANSIENTDUPLICATE';

  select sum(count) into num_trigger_suppression
     from GV$GOLDENGATE_CAPABILITIES where name like 'TRIGGERSUPPRESSION';

  select sum(count) into num_ggsddltrigopt 
     from GV$GOLDENGATE_CAPABILITIES where name like 'DDLTRIGGEROPTIMIZATION';
 
  select sum(count) into num_dbencryption
     from GV$GOLDENGATE_CAPABILITIES where name like 'DBENCRYPTION';

  select sum(count) into num_ggsession
     from GV$GOLDENGATE_CAPABILITIES where name like 'GGSESSION';

  select sum(count) into num_delcascadehint
     from GV$GOLDENGATE_CAPABILITIES where name like 'DELETECASCADEHINT';

  select sum(count) into num_suplog
     from GV$GOLDENGATE_CAPABILITIES where name like 'SUPPLEMENTALLOG';

  select sum(count) into num_procrepl
     from GV$GOLDENGATE_CAPABILITIES where name like 'PROCREPLICATION';

  total_feature_usage := num_capture + num_apply + num_dblogreader + 
     num_transient_duplicate + num_ggsddltrigopt + num_trigger_suppression +
     num_dbencryption + num_ggsession + num_delcascadehint + num_suplog +
     num_procrepl;

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' dblogread:'            || num_dblogreader
      ||' tdup:'                 || num_transient_duplicate
      ||' suptrig:'              || num_trigger_suppression
      ||' dtrigopt:'             || num_ggsddltrigopt
      ||' dbenc:'                || num_dbencryption
      ||' ggsess:'               || num_ggsession
      ||' delhint:'              || num_delcascadehint
      ||' suplog:'               || num_suplog
      ||' suplog:'               || num_procrepl;
   
  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_dblogreader > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_transient_duplicate > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_ggsddltrigopt > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_trigger_suppression > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_dbencryption > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_ggsession > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_delcascadehint > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_suplog > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_procrepl > 0) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_goldengate;
/

show errors;

/****************************************************************
 * DBMS_FEATURE_USER_MVS
 * The procedure to detect usage for MATERIALIZED VIEWS (USER)
 ****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_USER_MVS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
 num_mv         number;     -- total number of user mvs (user mvs of all types)
 num_ondmd      number;                                   -- on-demand user mvs
 num_cmplx      number;  -- complex user mvs (mvs that can't be fast refreshed)
 num_mav        number;                                          -- (user) mavs
 num_mjv        number;                                          -- (user) mjvs
 num_mav1       number;                                         -- (user) mav1s
 num_oncmt      number;                                   -- on-commit user mvs
 num_enqrw      number;                           -- rewrite enabled (user) mvs
 num_rmt        number;                                    -- remote (user) mvs
 num_pk         number;                                        -- pk (user) mvs
 num_rid        number;                                     -- rowid (user) mvs
 num_obj        number;                                    -- object (user) mvs
 num_ofprf      number;                                 -- out-of-place refresh
 num_sync       number;                                     -- sync refresh mvs
 feature_usage  varchar2(1000);
 user_mv_test   varchar2(100);

BEGIN
  -- initialize
  num_mv := 0;                                   
  num_ondmd := 0;
  num_cmplx := 0;
  num_mav := 0;
  num_mjv := 0;
  num_mav1 := 0;
  num_oncmt := 0;
  num_enqrw := 0;
  num_rmt := 0;
  num_pk := 0;
  num_rid := 0;
  num_obj := 0;
  num_ofprf := 0;
  num_sync := 0;
  user_mv_test := ' s.sowner not in (''SYS'', ''SYSTEM'', ''SH'', ''SYSMAN'')';

  feature_boolean := 0;
  aux_count := 0;

  /* get the user mv count (user mvs of all types) */
  execute immediate 'select count(*) from dba_mviews
                     where owner not in (''SYS'', ''SYSTEM'', ''SH'', ''SYSMAN'')'
  into num_mv;

  if (num_mv > 0)
  then

    /* get number of rowid (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 16) = 16 and' || user_mv_test
    into num_rid;

    /* get number of pk (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 32) = 32 and' || user_mv_test
    into num_pk;

    /* get number of on-demand user mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 64) = 64 and' || user_mv_test
    into num_ondmd;

    /* get number of complex user mvs (mvs that can't be fast refreshed) */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 256) = 256 and' || user_mv_test
    into num_cmplx;

    /* get number of (user) mavs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 4096) = 4096 and' || user_mv_test
    into num_mav;

    /* get number of (user) mjvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 8192) = 8192 and' || user_mv_test
    into num_mjv;

    /* get number of (user) mav1s */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 16384) = 16384 and' || user_mv_test
    into num_mav1;

    /* get number of on-commit user mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 32768) = 32768 and' || user_mv_test
    into num_oncmt;

    /* get number of rewrite enabled (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 1048576) = 1048576 and' ||
                       user_mv_test
    into num_enqrw;

    /* get number of remote (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where s.mlink is not null and' || user_mv_test
    into num_rmt;

    /* get number of object (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 536870912) = 536870912 and' ||
                       user_mv_test
    into num_obj;
   
    /* get number of SyncRefresh mvs */
    execute immediate 'select sum(count#) from mv_refresh_usage_stats$ 
                       where refresh_method# = ''SYNC'''

    into num_sync;

    /* get number of out-of-place refreshes */
    execute immediate 'select sum(count#) from SYS.MV_REFRESH_USAGE_STATS$
                       where OUT_OF_PLACE# = ''YES'''
    into num_ofprf;

    feature_boolean := 1;

    feature_usage := 'total number of user mvs (user mvs of all types):' || to_char(num_mv) ||
          ',' || ' num of (user) mavs:' || to_char(num_mav) ||
          ',' || ' num of (user) mjvs:' || to_char(num_mjv) ||
          ',' || ' num of (user) mav1s:' || to_char(num_mav1) ||
          ',' || ' num of on-demand user mvs:' || to_char(num_ondmd) ||
          ',' || ' num of on-commit user mvs:' || to_char(num_oncmt) ||
          ',' || ' num of remote (user) mvs:' || to_char(num_rmt) ||
          ',' || ' num of pk (user) mvs:' || to_char(num_pk) ||
          ',' || ' num of rowid (user) mvs:' || to_char(num_rid) ||
          ',' || ' num of object (user) mvs:' || to_char(num_obj) ||
          ',' || ' num of rewrite enabled (user) mvs:' || to_char(num_enqrw) ||
          ',' || ' num of complex user mvs:' || to_char(num_cmplx) ||
          ',' || ' num of out-of-place refreshes:' || to_char(num_ofprf) ||
          ',' || ' num of SyncRefresh mvs:' || to_char(num_sync) ||
          '.';

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('User MVs do not exist.');
  end if;

end;
/

/****************************************************************
 * DBMS_FEATURE_IOT
 * The procedure to detect Index Organized Table usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IOT(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage                 varchar2(1000);
    num_iot                       number;
    num_iotpart_index_segments    number;
    num_iotpart_overflow_segments number;

BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;

    -- If the IOT or its overflow segment is stored in a tablespace other than 
    -- SYSTEM or SYSAUX, count it.
    execute immediate 
       'select count(*) from dba_tables, dba_indexes where ' ||
       'dba_tables.iot_type is not null and dba_indexes.table_name ' ||
       '= dba_tables.table_name and (dba_indexes.tablespace_name ' ||
       'not in (''SYSTEM'', ''SYSAUX'', ''TEMP'', ''SYSEXT'')' ||
       'or dba_tables.tablespace_name ' ||
       'not in (''SYSTEM'', ''SYSAUX'', ''TEMP'', ''SYSEXT''))'
    into num_iot;

    -- Partitioned IOT/overflow segment
    -- for the IOT overflow segment partitions
    -- Bug 21059266:
    -- Query rewritten in terms of Data Dictionary base tables; the three
    -- bitands correspond to the dba_tables.iot_type column in the original
    -- query. That column is not null if any of the following bitands are true:
    -- (bitand(property, 64) = 64) means IOT
    -- (bitand(property,512) = 512) means IOT_OVERFLOW
    -- (bitand(flags, 536870912) = 536870912) IOT_MAPPING
    execute immediate
       'select count(OBJ#) ' ||
       'from tabpart$ ' ||
       'where BO# in ' ||
          '((select OBJ# ' ||
            'from tab$ ' ||
            'where (((bitand(property, 64) = 64) or ' || 
                   '(bitand(property,512) = 512) or ' ||
                   '(bitand(flags, 536870912) = 536870912)) and ' || 
                   'TS# in ' ||
                     '(select TS# ' ||
                      'from ts$ ' ||
                      'where NAME not in ' ||
                         '(''SYSTEM'', ''SYSAUX'', ''TEMP'', ''SYSEXT'')))))'
    into num_iotpart_overflow_segments;

    -- for the IOT index segment partitions
    execute immediate
       'select count(*) ' ||
       'from dba_tables, dba_indexes, dba_ind_partitions where ' ||
       'dba_tables.iot_type is not null and dba_tables.table_name = ' ||
       'dba_indexes.table_name and dba_indexes.index_name = ' ||
       'dba_ind_partitions.index_name and ' ||
       'dba_ind_partitions.tablespace_name ' ||
       'not in (''SYSTEM'', ''SYSAUX'', ''TEMP'', ''SYSEXT'')'
    into num_iotpart_index_segments;

    -- Composite partitioning is not supported for IOTs

    --Summary
    feature_usage :=
        ' Index Organized Table Feature Usage: ' ||
                'Index Organized Tables: ' || 
                  to_char(num_iot) ||
        ', ' || 'Index Organized Table Partitions ' ||
        '(Index and Overflow Partitions) ' || 
                  to_char(num_iotpart_index_segments + 
                          num_iotpart_overflow_segments);

     if (num_iot + num_iotpart_index_segments + 
         num_iotpart_overflow_segments > 0) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    else
      feature_boolean := 0;
      feature_info := to_clob('Index Organized Tables Not Detected');
    end if;

END;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IMC
 * The procedure to detect In-Memory Column Store usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IMC(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    num_tab                     number;
    num_tab_part                number;
    num_tab_subpart             number;
    num_tab_cc                  number;
    num_tab_part_cc             number;
    num_segs                    number;
    inmemory_size_value         number;

BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;
    inmemory_size_value         := 0;
    
    -- check if any segments are enabled for in-memory
    execute immediate 
       'select count(*) from dba_tables where ' ||
       'inmemory_compression is not null and ' ||
       'not (tablespace_name in (''SYSTEM'', ''SYSAUX'') ' ||
       'and owner like ''SYS'')'
    into num_tab;

    execute immediate 
       'select count(*) from dba_tab_partitions where ' ||
       'inmemory_compression is not null and ' ||
       'not (tablespace_name in (''SYSTEM'', ''SYSAUX'') ' ||
       'and table_owner like ''SYS'') and table_name ' ||
       'not like ''BIN$%'''
    into num_tab_part;

    execute immediate 
       'select count(*) from dba_tab_subpartitions where ' ||
       'inmemory_compression is not null and ' ||
       'not (tablespace_name in (''SYSTEM'', ''SYSAUX'') ' ||
       'and table_owner like ''SYS'') and table_name ' ||
       'not like ''BIN$%'''
    into num_tab_subpart;

    -- check if any segments were enabled for cellmemory
    -- note some tables may show up twice as in-memory and cellmemory
    execute immediate 
       'select count(*) from dba_tables where ' ||
       'cellmemory like ''MEMCOMPRESS%'' and ' ||
       'not (tablespace_name in (''SYSTEM'', ''SYSAUX'') ' ||
       'and owner like ''SYS'')'
    into num_tab_cc;

    execute immediate 
       'select count(*) from dba_tab_partitions where ' ||
       'cellmemory like ''MEMCOMPRESS%'' and ' ||
       'not (tablespace_name in (''SYSTEM'', ''SYSAUX'') ' ||
       'and table_owner like ''SYS'') and table_name ' ||
       'not like ''BIN$%'''
    into num_tab_part_cc;

    -- check if any segments are actually in-memory
    execute immediate 
       'select count(*) from gv$im_segments_detail where ' ||
       'segtype=0'
    into num_segs;

    -- check the value of the parameter "inmemory_size" from 
    -- all instances
    execute immediate 
       'select nvl(max(value),0) from gv$parameter where ' || 
       'name = ''inmemory_size'''
    into inmemory_size_value;

    --Summary
    feature_usage :=
        ' In-Memory Column Store Feature Usage: ' ||
                'In-Memory Column Store Tables: ' || 
                  to_char(num_tab) ||
        ', ' || 'In-Memory Column Store Table Partitions: ' || 
                  to_char(num_tab_part) ||
        ', ' || 'In-Memory Column Store Table Subpartitions: ' ||
                  to_char(num_tab_subpart) ||
        ', ' || 'Total In-Memory Column Store Segments Populated: ' ||
                  to_char(num_segs) ||
        ', ' || 'Cellcache Column Store Tables: ' || 
                  to_char(num_tab_cc) ||
        ', ' || 'Cellcache Column Store Table Partitions: ' || 
                  to_char(num_tab_part_cc);

     if (((num_tab + num_tab_part + num_tab_subpart + num_segs > 0)
          AND (inmemory_size_value > 0)) 
    OR  (num_tab_cc + num_tab_part_cc > 0))
        then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    else
      feature_boolean := 0;
      feature_info := to_clob('In-Memory Column Store Not Detected');
    end if;
END;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IM_EXPRESSIONS
 * The procedure to detect In-Memory Virtual Columns and 
 * In-Memory Expressions usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IM_EXPRESSIONS(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage                    varchar2(2000);
    num_imes_created                 number  := 0;
    num_vcs_enabled_for_inmem        number  := 0;
    num_osons_created                number  := 0;
    num_exp_inmem                    number  := 0;
    num_oson_inmem                   number  := 0;
    inmemory_size_value              number  := 0;
    inmemory_exp_usage_value         number  := 0;
    inmemory_virtual_columns_value   number  := 0;
    feature_params_enabled           boolean := FALSE;
    feature_check_static             boolean := FALSE;
    feature_check_dynamic            boolean := FALSE;
BEGIN
    feature_boolean := 0;
    aux_count       := 0;
   
    -- Check total number of IMEs created regardless of memcompress level
    -- Ignore OSON
    execute immediate
        'select count(*) from sys.col$ where name like ''SYS\_IME%''' ||
        ' escape ''\'' and name not like ''SYS\_IME\_OSON\_%'' escape ''\'''
    into num_imes_created;
   
    -- Check total number of OSON created regardless of in-memory compression
    execute immediate
        'select count(*) from sys.col$ where name like ''SYS\_IME\_OSON\_%''' ||
        ' escape ''\'''
    into num_osons_created;

    -- Check the number of VCs explicitly enabled for in-memory storage
    -- SYS_IMEs do not show up in this view
    execute immediate
        'select count(*) from gv$im_column_level where segment_column_id = 0' ||
        ' and inmemory_compression in (''DEFAULT'', ''NO MEMCOMPRESS'',' ||
        ' ''FOR DML'', ''FOR QUERY LOW'', ''FOR QUERY HIGH'',' ||
        ' ''FOR CAPACITY LOW'', ''FOR CAPACITY HIGH'')'
    into num_vcs_enabled_for_inmem;

    -- Check if any VC or IME (not OSON) are populated in-memory
    execute immediate
        'select count(*) from gv$im_imecol_cu where column_name not like' ||
        ' ''SYS\_IME\_OSON%'' escape ''\'''
    into num_exp_inmem;
 
    -- Check if any OSON is populated in-memory
    execute immediate
        'select count(*) from gv$im_imecol_cu where column_name like' ||
        ' ''SYS\_IME\_OSON%'' escape ''\'''
    into num_oson_inmem; 

    -- Check the value of "inmemory_size" from all instances
    execute immediate 
       'select nvl(max(value),0) from gv$parameter where ' || 
       'name = ''inmemory_size'''
    into inmemory_size_value;

    -- Check the value of "inmemory_virtual_columns" from all instances
    execute immediate
       'select count(*) from gv$parameter where ' ||
       'name = ''inmemory_virtual_columns'' and value != ''DISABLE'''
    into inmemory_virtual_columns_value;

     -- Check the value of "inmemory_expressions_usage" from all instances
    execute immediate
       'select count(*) from gv$parameter where ' ||
       'name = ''inmemory_expressions_usage'' and value != ''DISABLE'''
    into inmemory_exp_usage_value;

    -- Summary
    feature_usage :=
                ' In-Memory Virtual Columns enabled on: ' ||
                to_char(inmemory_virtual_columns_value) || ' instances' ||
                ', In-Memory Expressions enabled on: ' ||
                to_char(inmemory_exp_usage_value) || ' instances' ||
                ', Number of IMEs created: ' || 
                to_char(num_imes_created) ||
                ', Number of VCs explicitly enabled for in-memory: ' ||
                to_char(num_vcs_enabled_for_inmem) ||
                ', Number of OSONs created: ' ||
                to_char(num_osons_created) ||
                ', Number of VC or IME CUs in-memory: ' ||
                to_char(num_exp_inmem) ||
                ', Number of OSON CUs in-memory: ' ||
                to_char(num_oson_inmem);

    -- Check if either parameter is ENABLEd and in-memory size is setup
    feature_params_enabled := (
                               ((inmemory_exp_usage_value > 0) OR
                                (inmemory_virtual_columns_value > 0)) AND
                               (inmemory_size_value > 0)
                              );

    -- Static feature check based on IMEs created or VCs enabled for IM
    feature_check_static := ((num_imes_created > 0) OR
                             (num_vcs_enabled_for_inmem > 0));

    -- Dynamic feature check based on IME/VC/OSON populated in-memory
    -- This is necessary because of the ENABLE mode in inmemory_virtual_columns
    feature_check_dynamic := ((num_exp_inmem > 0) OR (num_oson_inmem > 0));

    -- Feature Check
    if (feature_params_enabled) then
      if (feature_check_static OR feature_check_dynamic) then
        feature_boolean := 1;
        feature_info := to_clob(feature_usage);
      end if;
    end if;
END;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_IM_ADO
 * The procedure to detect usage for IM ADO policies. 
 ********************************************************************/

create or replace procedure DBMS_FEATURE_IM_ADO
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_im_ado_pol        number := 0;
    num_obj_pol           number := 0;
    im_size               number := 0;

begin
    -- initialize
    feature_boolean := 0;
    aux_count       := 0;

    -- check for ILM usage by counting policies in ILM dictionary
    select count(*) into num_im_ado_pol
      from sys.ilmpolicy$
     where pol_subtype = 1;

    if (num_im_ado_pol > 0) then
      
     -- check the value of the parameter "inmemory_size" from 
     -- all instances
     execute immediate 
        'select nvl(max(value),0) from gv$parameter where ' || 
        'name = ''inmemory_size'''
      into im_size;

     if (im_size > 0) then 
        feature_boolean := 1;

        select count(*) into num_obj_pol
          from sys.ilmobj$
         where policy# in (select policy# from sys.ilmpolicy$
                          where pol_subtype = 1);

        feature_usage   :=
                'Number of IM ADO Policies: ' || to_char(num_im_ado_pol) ||
        ', ' || 'Number of Objects Affected: ' || to_char(num_obj_pol);
        feature_info    := to_clob(feature_usage);

     end if;      
   end if;
end;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IM_JOINGROUPS
 * The procedure to detect In-Memory Join Group Usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IM_JOINGROUPS(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    num_jg                      number;
    inmemory_size_value         number;
BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;
    inmemory_size_value         := 0;
   
    execute immediate
        'select count(distinct(domain#)) from im_joingroup$'
    into num_jg;

    -- check the value of the parameter "inmemory_size" from 
    -- all instances
    execute immediate 
       'select nvl(max(value),0) from gv$parameter where ' || 
       'name = ''inmemory_size'''
    into inmemory_size_value;

    --Summary
    feature_usage :=
        ' In-Memory Join Groups Feature Usage: ' ||
                ' Number of join groups created: ' || 
                  to_char(num_jg);

     if ((num_jg > 0) AND (inmemory_size_value > 0)) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    end if;
END;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IM_FORSERVICE
 * The procedure to detect In-Memory For Service usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IM_FORSERVICE(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    num_tablespaces             number;
    num_tab                     number;
    num_tab_part                number;
    num_tab_subpart             number;
BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;
    num_tablespaces             := 0;
    num_tab                     := 0;
    num_tab_part                := 0;
    num_tab_subpart             := 0;
   
    execute immediate
        'select count(*) from dba_tables where ' ||
        'inmemory_service = ''USER_DEFINED'''
    into num_tab;

    execute immediate
        'select count(*) from dba_tab_partitions where ' ||
        'inmemory_service = ''USER_DEFINED'''
    into num_tab_part;

    execute immediate
        'select count(*) from dba_tab_subpartitions where ' ||
        'inmemory_service = ''USER_DEFINED'''
    into num_tab_subpart;

    execute immediate
        'select count(*) from dba_tablespaces where ' ||
        'def_inmemory_service = ''USER_DEFINED'''
    into num_tablespaces;
    
    --Summary
    feature_usage :=
        ' In-Memory For Service Feature Usage: ' ||
                'In-Memory USER_DEFINED For Service Tables: ' || 
                  to_char(num_tab) ||
        ', ' || 'In-Memory USER_DEFINED For Service Table Partitions: ' || 
                  to_char(num_tab_part) ||
        ', ' || 'In-Memory USER_DEFINED For Service Table Subpartitions: ' ||
                  to_char(num_tab_subpart) ||
        ', ' || 'In-Memory USER_DEFINED For Service Tablespaces: ' ||
                  to_char(num_tablespaces);

     if ((num_tab > 0) OR (num_tab_part > 0) OR (num_tab_subpart > 0) OR
         (num_tablespaces > 0)) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
     end if;
END;
/
show errors;
    
/****************************************************************
 * DBMS_FEATURE_ADV_TABCMP
 * The procedure to detect ADVANCED Table Compression usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_ADV_TABCMP(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    num_tab                     number;
    num_tab_part                number;
    num_tab_subpart             number;

BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;

    -- dbms_compression might create tables with 
    -- prefixes 'CMP4%' which we want to ignore
    execute immediate 
       'select count(*) from dba_tables where ' ||
       'compress_for = ''ADVANCED'' and table_name ' ||
       'not like ''' 
        || prvt_compression.COMP_TMP_OBJ_PREFIX || '%'''
    into num_tab;

    execute immediate 
       'select count(*) from dba_tab_partitions where ' ||
       'compress_for = ''ADVANCED'' '
    into num_tab_part;

    execute immediate 
       'select count(*) from dba_tab_subpartitions where ' ||
       'compress_for = ''ADVANCED'' '
    into num_tab_subpart;

    --Summary
    feature_usage :=
        ' ADVANCED Table Compression Feature Usage: ' ||
                ' Tables compressed for ADVANCED: ' || 
                  to_char(num_tab) ||
        ', ' || ' Table partitions compressed for ADVANCED: ' || 
                  to_char(num_tab_part) ||
        ', ' || ' Table subpartitions compressed for ADVANCED: ' ||
                  to_char(num_tab_subpart); 

     if (num_tab + num_tab_part + num_tab_subpart > 0) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    else
      feature_boolean := 0;
      feature_info := to_clob('ADVANCED Table Compression Not Detected');
    end if;
END;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_ADV_IDXCMP
 * The procedure to detect Advanced Index Compression usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_ADV_IDXCMP(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    oltp_high_idx_cnt           number;
    oltp_low_idx_cnt            number;
    oltp_high_part_idx_cnt      number;
    oltp_low_part_idx_cnt       number;
    num_oltp_high               number;
    num_oltp_low                number;
    blk_oltp_high               number;
    blk_oltp_low                number;
    def_oltp_high               number;
    def_oltp_low                number;
    tmp_pattern                 varchar(50);

BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;
    --Pattern used by Compression Advisor for creating temporary 
    --compressed objects
    tmp_pattern                 := '''' || 
                                   prvt_compression.COMP_TMP_OBJ_PREFIX ||
                                   '%''';

    --Check for ADVANCED HIGH seg, block, deferred seg
    execute immediate 'select count(*) from seg$ s, ind$ i, obj$ o ' ||
      ' where s.type# = 6 AND ' ||
            ' s.user# not in (select user# from user$ ' ||
                ' where name in (''SYS'' , ''SYSTEM'' )) AND ' ||
            ' bitand(s.spare1, 2048) = 2048 AND ' ||
            ' bitand(s.spare1, 16777216 + 1048576) = 16777216 AND ' ||
            ' s.ts# = i.ts# AND s.file# = i.file# AND ' ||
            ' s.block# = i.block# AND i.obj# = o.obj# AND ' ||
            ' o.name not like ' || tmp_pattern
      into num_oltp_high;

    if (num_oltp_high = 0) then
      blk_oltp_high := 0;
    else
      execute immediate 'select sum(blocks) from seg$ s, ind$ i, obj$ o ' ||
        ' where s.type# = 6 AND ' ||
              ' s.user# not in (select user# from user$ ' ||
                  ' where name in (''SYS'', ''SYSTEM'' )) AND' ||
              ' bitand(s.spare1, 2048) = 2048 AND ' ||
              ' bitand(s.spare1, 16777216 + 1048576) = 16777216 AND ' ||
              ' s.ts# = i.ts# AND s.file# = i.file# AND ' ||
              ' s.block# = i.block# AND i.obj# = o.obj# AND ' ||
              ' o.name not like ' || tmp_pattern
        into blk_oltp_high;
    end if;

    execute immediate 'select count(*) from deferred_stg$ ds ' ||
      ' where ds.obj# in (select obj# from obj$ ob' ||
                ' where ob.type# in (1,20) AND ob.owner# not in ' ||
                     '(select user# from user$ ' ||
                          ' where name in (''SYS'', ''SYSTEM'' ))) AND' ||
            ' bitand(ds.flags_stg, 4) = 4 AND ' ||
            ' bitand(ds.cmpflag_stg, 6) = 2 '
      into def_oltp_high;

    --Check for ADVANCED LOW seg, block, deferred seg
    execute immediate 'select count(*) from seg$ s, ind$ i, obj$ o ' ||
      ' where s.type# = 6 AND ' ||
            ' s.user# not in (select user# from user$ ' ||
                ' where name in (''SYS'', ''SYSTEM'' )) AND' ||
            ' bitand(s.spare1, 2048) = 2048 AND ' ||
            ' bitand(s.spare1, 16777216 + 1048576) = 1048576 AND ' ||
            ' s.ts# = i.ts# AND s.file# = i.file# AND ' ||
            ' s.block# = i.block# AND i.obj# = o.obj# AND ' ||
            ' o.name not like ' || tmp_pattern
      into num_oltp_low;

    if (num_oltp_low = 0) then
      blk_oltp_low := 0;
    else
      execute immediate 'select sum(blocks) from seg$ s, ind$ i, obj$ o  ' ||
        ' where s.type# = 6 AND ' ||
              ' s.user# not in (select user# from user$ ' ||
                  ' where name in (''SYS'', ''SYSTEM'' )) AND' ||
              ' bitand(s.spare1, 2048) = 2048 AND ' ||
              ' bitand(s.spare1, 16777216 + 1048576) = 1048576  AND ' ||
              ' s.ts# = i.ts# AND s.file# = i.file# AND ' ||
              ' s.block# = i.block# AND i.obj# = o.obj# AND ' ||
              ' o.name not like ' || tmp_pattern
        into blk_oltp_low;
    end if;

    execute immediate 'select count(*) from deferred_stg$ ds ' ||
      ' where ds.obj# in (select obj# from obj$ ob' ||
                ' where ob.type# in (1,20) AND ob.owner# not in ' ||
                      '(select user# from user$ ' ||
                          ' where name in (''SYS'', ''SYSTEM'' ))) AND' ||
            ' bitand(ds.flags_stg, 4) = 4 AND ' ||
            ' bitand(ds.cmpflag_stg, 6) = 4 '
      into def_oltp_low;

    --Summary
    feature_usage :=
        ' Advanced Index Compression feature usage: ' ||
                ' Segments Compressed for ADVANCED HIGH: ' || 
                  to_char(num_oltp_high) ||
        ', ' || ' Blocks Compressed for ADVANCED HIGH: ' || 
                  to_char(blk_oltp_high) ||
        ', ' || ' Deferred Segements Compressed for ADVANCED HIGH: ' ||
                  to_char(def_oltp_high) ||
        ', ' || ' Segments Compressed for ADVANCED LOW: ' || 
                  to_char(num_oltp_low) ||
        ', ' || ' Blocks Compressed for ADVANCED LOW: ' || 
                  to_char(blk_oltp_low) ||
        ', ' || ' Deferred Segements Compressed for ADVANCED LOW: ' ||
                  to_char(def_oltp_low);

    if (num_oltp_high + def_oltp_high + num_oltp_low + def_oltp_low > 0) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    else
      feature_boolean := 0;
      feature_info := to_clob('Advanced Index Compression not detected');
    end if;
END;
/
show errors;


/****************************************************************
 * DBMS_FEATURE_HCC
 * The procedure to detect usage for Hybrid Columnar Compression
 ****************************************************************/

create or replace procedure DBMS_FEATURE_HCC
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_cmp_dollar        number;
    num_level1            number;
    num_level2            number;
    num_level3            number;
    num_level4            number;
    num_hcc               number;
    num_dmls              number;
    num_rll               number;
    blk_level1            number;
    blk_level2            number;
    blk_level3            number;
    blk_level4            number;
    blk_nonhcc            number;
    blk_nonhcctry         number;
    blk_rll               number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_cmp_dollar := 0;
    num_hcc := 0;
    num_level1  := 0;
    num_level2  := 0;
    num_level3  := 0;
    num_level4  := 0;
    blk_level1 := 0;
    blk_level2 := 0;
    blk_level3 := 0;
    blk_level4 := 0;

    execute immediate 'select count(*) from compression$ '
        into num_cmp_dollar;

    -- check if there is something compressed
    execute immediate 'select count(*) from seg$ s ' ||
         ' where bitand(s.spare1, 234881024) = 33554432 OR '  ||
               ' bitand(s.spare1, 234881024) = 67108864 OR '  ||
               ' bitand(s.spare1, 234881024) = 100663296 OR ' ||
               ' bitand(s.spare1, 234881024) = 134217728'         
        into num_hcc;

    if (num_hcc > 0) then
    
        feature_boolean := 1;

        -- check for HCC for Query LOW (level 1)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 33554432 '
           into num_level1;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 33554432 '
           into blk_level1;

        -- check for HCC for Query HIGH (level 2)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 67108864 '
           into num_level2;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 67108864 '
           into blk_level2;

        -- check for HCC for Archive LOW (level 3)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 100663296 '
           into num_level3;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 100663296 '
           into blk_level3;
           
        -- check for HCC for Archive HIGH (level 4)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 134217728 '
           into num_level4;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 234881024) = 134217728 '
           into blk_level4;
           

        -- track OLTP compression (non-HCC compression) w/in HCC
        execute immediate 'select value from v$sysstat' ||
            ' where name like ''HCC block compressions completed'''
            into blk_nonhcc;

        execute immediate 'select value from v$sysstat' ||
            ' where name like ''HCC block ' ||
            'compressions attempted'''
            into blk_nonhcctry;

        execute immediate 'select value from v$sysstat' ||
            ' where name like ''HCC DML conventional'''
            into num_dmls;

        -- check for HCC with Row Level Locking
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 2147483648) = 2147483648 '
           into num_rll;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 2147483648) = 2147483648 '
           into blk_rll;

     feature_usage :=
      'Number of Hybrid Columnar Compressed Segments: ' || to_char(num_hcc) ||
        ', ' || ' Segments Analyzed: ' || to_char(num_cmp_dollar) ||
        ', ' || ' Segments Compressed Query Low: ' || to_char(num_level1) ||
        ', ' || ' Blocks Compressed Query Low: ' || to_char(blk_level1) ||
        ', ' || ' Segments Compressed Query High: ' || to_char(num_level2) ||
        ', ' || ' Blocks Compressed Query High: ' || to_char(blk_level2) ||
        ', ' || ' Segments Compressed Archive Low: ' || to_char(num_level3) ||
        ', ' || ' Blocks Compressed Archive Low: ' || to_char(blk_level3) ||
        ', ' || ' Segments Compressed Archive High: ' || to_char(num_level4) ||
        ', ' || ' Blocks Compressed Archive High: ' || to_char(blk_level4) ||
        ', ' || ' Blocks Compressed Non-HCC: ' || to_char(blk_nonhcc) || 
        ', ' || ' Attempts to Block Compress: ' || to_char(blk_nonhcctry) || 
        ', ' || ' Conventional DMLs: ' || to_char(num_dmls) ||
        ', ' || ' Segments with HCC Row Level Locking: ' || to_char(num_rll) ||
        ', ' || ' Blocks with HCC Row Level Locking: ' || to_char(blk_rll);

        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Hybrid Columnar Compression not detected');
    end if;

end;
/
show errors;

/**************************************************************************
 * DBMS_FEATURE_HCCCONV
 * Procedure to detect use of Hybrid Columnar Compression Conventional Load
 **************************************************************************/
 CREATE OR REPLACE PROCEDURE DBMS_FEATURE_HCCCONV
      ( feature_boolean  OUT  NUMBER,
        aux_count        OUT  NUMBER,
        feature_info     OUT  CLOB) 
 AS
   feature_count NUMBER;
   feature_usage varchar2(100);
 BEGIN 
   -- initialize
   feature_info  := NULL; 
   feature_count := 0; 
 
   execute immediate 'select sum(value) from v$sysstat where name ' ||
   'like ''HCC load conventional bytes compressed''' into feature_count;
   
   feature_usage :=
    'Hybrid Columnar Compressed Conventional: ' || to_char(feature_count);
   feature_info  := to_clob(feature_usage);
 
   if (feature_count > 0) then
     feature_boolean := 1; 
   else  
     feature_boolean := 0; 
   end if;
   aux_count := feature_count;
 END;
 /
 show errors;
 
/****************************************************************
 * DBMS_FEATURE_HCCRLL
 * The procedure to detect usage of Hybrid Columnar Compression
 * Row Level Locking
 ****************************************************************/

create or replace procedure DBMS_FEATURE_HCCRLL
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_cmp_dollar        number;
    num_hcc               number;
    num_rll               number;
    blk_rll               number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_cmp_dollar := 0;
    num_hcc := 0;

    execute immediate 'select count(*) from compression$ '
        into num_cmp_dollar;

    -- check if there is something compressed
    execute immediate 'select count(*) from seg$ s ' ||
         ' where bitand(s.spare1, 100663296) = 33554432 OR ' ||
               ' bitand(s.spare1, 100663296) = 67108864 OR ' ||
               ' bitand(s.spare1, 100663296) = 100663296 '
        into num_hcc;

        -- check for HCC with Row Level Locking
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 2147483648) = 2147483648 '
           into num_rll;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 2147483648) = 2147483648 '
           into blk_rll;

    if ((num_rll > 0) OR (blk_rll > 0)) then
    
        feature_boolean := 1;

     feature_usage :=
      'Number of Hybrid Columnar Compressed Segments: ' || to_char(num_hcc) ||
        ', ' || ' Segments Analyzed: ' || to_char(num_cmp_dollar) ||
        ', ' || ' Segments with HCC Row Level Locking: ' || to_char(num_rll) ||
        ', ' || ' Blocks with HCC Row Level Locking: ' || to_char(blk_rll);

        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Hybrid Columnar Compression Row Level Locking not detected');
    end if;

end;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_ILM
 * The procedure to detect usage for Information Lifecycle Management
 ********************************************************************/

create or replace procedure DBMS_FEATURE_ILM
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_ilm_pol           number := 0;
    num_obj_pol           number := 0;
begin
    -- initialize
    feature_boolean := 0;
    aux_count       := 0;
    feature_info    := to_clob('Information Lifecycle Management not detected');

    -- check for ILM usage by counting policies in ILM dictionary
    execute immediate 'select count(*) from ilm$ '
       into num_ilm_pol;

    if num_ilm_pol > 0 then
      
      feature_boolean := 1;

      execute immediate 'select count(*) from ilmobj$ '
         into num_obj_pol;   

      feature_usage   :=
                'Number of ILM Policies: ' || to_char(num_ilm_pol) ||
        ', ' || 'Number of Objects Affected: ' || to_char(num_obj_pol);
      feature_info    := to_clob(feature_usage);

    end if;      

end;
/
show errors;


/********************************************************************
 * DBMS_FEATURE_HEATMAP
 * The procedure tracks usage of heatmap feature.
 ********************************************************************/

create or replace procedure DBMS_FEATURE_HEATMAP
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage   varchar2(300);
    num_tbs         number := 0;
    num_seg         number := 0;
    num_blocks      number := 0;
begin
    -- initialize
    feature_boolean := 0;
    aux_count       := 0;
    feature_info    := to_clob('Heat Map feature is not used');

/* Note: 
 * Bug 27119186:  For 18.1 AIM feature, access tracking for IM segments may be
 * on, even when heat_map is turned off. Filter out rows that were tracked when
 * heat_map was off using the predicate 'bitand(flag,1) = 0'
 *
 * However, block heat map is not tracked when heat_map is turned off. 
 * So no special processing is needed for the query on x$ktfsimstat;
 */


    -- Distinct tablespaces tracked

    execute immediate 'select count(distinct(ts#)) from heat_map_stat$ ' ||
                      ' where obj# <> -1 and bitand(flag,1) = 0' 
       into num_tbs;
       

    -- Distinct segments tracked
    execute immediate 'select count(*) from ' || 
                ' (select distinct obj#, dataobj#, ts# from heat_map_stat$ ' ||
                  ' where obj# <> -1 and bitand(flag,1) = 0)' 
       into num_seg;

    -- Blocks tracked in memory
    execute immediate 'select count(*) from x$ktfsimstat' into num_blocks;

    if num_tbs > 0 OR num_seg > 0 OR num_blocks > 0 then

      feature_boolean := 1;
      feature_usage   :=
                'Number of Tablespaces Tracked: ' || to_char(num_tbs) ||
        ', ' || ' Number of Segments Tracked: ' || to_char(num_seg) ||
        ', ' || ' Number of Blocks Tracked in Memory: ' || to_char(num_blocks);
      feature_info    := to_clob(feature_usage);

    end if;     

end;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_SHARD
 * The procedure tracks if the database is a database shard.
 ********************************************************************/

create or replace procedure DBMS_FEATURE_SHARD
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage   varchar2(300);
    deployed        number := 0;
    shard_method    number := 0;
begin
    -- initialize
    feature_boolean := 0;
    aux_count       := 0;
    feature_info    := to_clob('The database is not a shard');

    -- Determine if the sharded configuration has been deployed
    execute immediate 'select count(*) from v$parameter vp1 ' ||  
       ' where vp1.name = ''_gws_deployed'' and vp1.value = 2 ' ||
       ' and (select count(*) from gsmadmin_internal.cloud ' ||
       ' where database_flags = ''C'') = 0'
       into deployed;

    -- Determine the  sharding method used 
    execute immediate 'select value from v$parameter ' ||
       ' where name=''_gws_sharding_method''' 
        into shard_method;
    if shard_method = 1 then
      feature_usage := 'System-managed';
    elsif shard_method = 2 then
      feature_usage := 'User-managed';
    elsif shard_method = 3 then
      feature_usage := 'Composite';
    end if; 

    if deployed > 0 AND shard_method > 0 AND shard_method < 4 then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    end if;
end;
/
show errors;

CREATE OR REPLACE LIBRARY DBMS_STORAGE_TYPE_LIB TRUSTED AS STATIC;
/
create or replace procedure kdzstoragetype(tsn IN number, type out NUMBER) as
  LANGUAGE C
  NAME "kdzstoragetype"
  LIBRARY DBMS_STORAGE_TYPE_LIB
  with context
  PARAMETERS (context, tsn OCINumber, type OCINumber);
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_ZFS_STORAGE
 * Procedure to detect use of ZFS storage
 *****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ZFS_STORAGE
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
  tsn           NUMBER;
  stortype      NUMBER;
  TYPE cursor_t         IS REF CURSOR;
  cursor_objtype        cursor_t;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  OPEN cursor_objtype FOR q'[select ts# from sys.ts$]';

  LOOP
    BEGIN
      FETCH cursor_objtype INTO tsn;
      EXIT WHEN cursor_objtype%NOTFOUND;
      kdzstoragetype(tsn, stortype);
      IF (stortype = 1) THEN
        feature_count := feature_count + 1;
      END IF;
    END;
  END LOOP;

  feature_usage := 'TS on ZFS: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1;
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_PILLAR_STORAGE
 * Procedure to detect use of PILLAR storage
 *****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_PILLAR_STORAGE
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count  NUMBER;
  tsn            NUMBER;
  stortype       NUMBER;
  TYPE cursor_t  IS REF CURSOR;
  cursor_objtype cursor_t;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  OPEN cursor_objtype FOR q'[select ts# from sys.ts$]';

  LOOP
    BEGIN
      FETCH cursor_objtype INTO tsn;
      EXIT WHEN cursor_objtype%NOTFOUND;
      kdzstoragetype(tsn, stortype);
      IF (stortype = 2) THEN
        feature_count := feature_count + 1;
      END IF;
    END;
  END LOOP;

  feature_usage := 'TS on Pillar: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);
  
  if (feature_count > 0) then
    feature_boolean := 1;
  else
    feature_boolean := 0;
  end if;  
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_ZFS_EHCC
 * Procedure to detect use of ZFS storage with EHCC
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ZFS_EHCC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  execute immediate 'select value from v$sysstat' ||
    ' where name like ''HCC usage ZFS'''
    into feature_count;

  feature_usage := 'EHCC on ZFS: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
end;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_PILLAR_EHCC
 * Procedure to detect use of Pillar storage with EHCC
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_PILLAR_EHCC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
    feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  execute immediate 'select value from v$sysstat' ||
    ' where name like ''HCC usage pillar'''
    into feature_count;

  feature_usage := 'EHCC on Pillar: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
end;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_CLOUD_EHCC
 * Procedure to detect use of EHCC in Cloud Database
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_CLOUD_EHCC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count         NUMBER;
  feature_usage         VARCHAR2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  execute immediate 'select value from v$sysstat' ||
    ' where name like ''HCC usage cloud'''
    into feature_count;

  feature_usage := 'EHCC in Cloud Database: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
end;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SECUREFILES_USR
 * Procedure to detect usage of Oracle SecureFiles 
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SECUREFILES_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB','MDSYS'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB','MDSYS'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB','MDSYS'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;


/*****************************************************************
 * DBMS_FEATURE_SECUREFILES_SYS
 * Procedure to detect usage of Oracle SecureFiles
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SECUREFILES_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;


/*****************************************************************
 * DBMS_FEATURE_SFENCRYPT_USR
 * Procedure to detect usage of Oracle SecureFile Encryption
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFENCRYPT_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 4096), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFENCRYPT_SYS
 * Procedure to detect usage of Oracle SecureFile Encryption
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFENCRYPT_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 4096), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFCOMPRESS_USR
 * Procedure to detect usage of Oracle SecureFile Compression
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFCOMPRESS_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  -- bug 21562376: XML search index $D table (with name pattern 'DR%$D')
  --               uses compression, skip it.
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 57344), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.name not like 'DR%$D' and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.name not like 'DR%$D' and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.name not like 'DR%$D' and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFCOMPRESS_SYS
 * Procedure to detect usage of Oracle SecureFile Compression
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFCOMPRESS_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  -- bug 21562376: XML search index $D table (with name pattern 'DR%$D')
  --               uses compression, count it as system usage.
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 57344), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            (o.name like 'DR%$D' or 
             o.owner# in (select user# from user$ 
                          where name in ('SYS', 'SYSTEM', 'XDB')))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            (o.name like 'DR%$D' or 
             o.owner# in (select user# from user$ 
                          where name in ('SYS', 'SYSTEM', 'XDB')))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            (o.name like 'DR%$D' or 
             o.owner# in (select user# from user$ 
                          where name in ('SYS', 'SYSTEM', 'XDB')))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_SFDEDUP_USR
 * Procedure to detect usage of Oracle SecureFile Deduplication
 * by non-system users
 ********************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFDEDUP_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 458752), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_SFDEDUP_SYS
 * Procedure to detect usage of Oracle SecureFile Deduplication
 * by system (internal) users
 ********************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFDEDUP_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 458752), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_DATA_GUARD
 * The procedure to detect usage for Data Guard
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DATA_GUARD
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    log_transport         varchar2(25);
    num_arch              number;
    num_casc_stby         number;
    num_compression       number;
    num_dgconfig          number;
    num_far_sync          number;
    num_fast_sync         number;
    num_lgwr_async        number;
    num_lgwr_sync         number;
    num_realtime_apply    number;
    num_redo_apply        number;
    num_snapshot          number;
    num_sql_apply         number;
    num_standbys          number;
    num_terminal_db       number;
    num_ra                number;
    protection_mode       varchar2(24);
    use_broker            varchar2(5);
    use_compression       varchar2(8);
    use_far_sync          varchar2(5);
    use_fast_sync         varchar2(5);
    use_flashback         varchar2(18);
    use_fs_failover       varchar2(22);
    use_realtime_apply    varchar2(5);
    use_redo_apply        varchar2(5);
    use_snapshot          varchar2(5);
    use_sql_apply         varchar2(5);
    use_ra                varchar2(5);

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    log_transport := NULL;
    num_arch := 0;
    num_casc_stby := 0;
    num_compression := 0;
    num_dgconfig :=0;
    num_far_sync := 0;
    num_fast_sync := 0;
    num_lgwr_async := 0;
    num_lgwr_sync := 0;
    num_realtime_apply := 0;
    num_redo_apply := 0;
    num_snapshot := 0;
    num_sql_apply := 0;
    num_standbys := 0;
    num_terminal_db := 0;
    num_ra := 0;
    use_broker := 'FALSE';
    use_compression := 'FALSE';
    use_far_sync := 'FALSE';
    use_fast_sync := 'FALSE';
    use_flashback := 'FALSE';
    use_fs_failover := 'FALSE';
    use_realtime_apply := 'FALSE';
    use_redo_apply := 'FALSE';
    use_snapshot := 'FALSE';
    use_sql_apply := 'FALSE';
    use_ra := 'FALSE';

    -- check for Data Guard usage by counting valid standby destinations
    -- We use v$archive_dest here and NOT v$dataguard_config because if the
    -- dg_config is not initialized, v$dataguard_config will be empty.
    execute immediate 'select count(*) from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY'''
        into num_standbys;

    if (num_standbys > 0) then
        feature_boolean := 1;

        -- determine if v$dataguard_config is populated
        execute immediate 'select count(*) from v$dataguard_config'
            into num_dgconfig;

        -- Depending on whether v$dataguard_config is populated or not, some
        -- of the commands below will either use v$dataguard_config or
        -- v$archive_dest.

        if (num_dgconfig > 0) then
            -- get the real number of standbys
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE like ''% STANDBY'')'
                into num_standbys;

            -- get the number of cascading standbys
            execute immediate 'select count(unique(PARENT_DBUN)) ' ||
                'from v$dataguard_config ' ||
                'where (PARENT_DBUN not in ' ||
                '(select DB_UNIQUE_NAME from v$database) and ' ||
                'PARENT_DBUN != ''NONE'' and PARENT_DBUN != ''UNKNOWN'')'
                into num_casc_stby;

            -- get the number of terminal databases
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DB_UNIQUE_NAME not in ' ||
                '(select PARENT_DBUN from v$dataguard_config) and ' ||
                'PARENT_DBUN != ''UNKNOWN'')'
                into num_terminal_db;

            -- check for Redo Apply (Physical Standby) usage
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE = ''PHYSICAL STANDBY'')'
                into num_redo_apply;
            if (num_redo_apply > 0) then
                use_redo_apply := 'TRUE';
            end if;

            -- check for SQL Apply (Logical Standby) usage
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE = ''LOGICAL STANDBY'')'
                into num_sql_apply;
            if (num_sql_apply > 0) then
                use_sql_apply := 'TRUE';
            end if;

            -- check for Far Sync Instance usage
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE = ''FAR SYNC INSTANCE'')'
                into num_far_sync;
            if (num_far_sync > 0) then
                use_far_sync := 'TRUE';
            end if;

            -- check for Snapshot Standby usage
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE = ''SNAPSHOT STANDBY'')'
                into num_snapshot;
            if (num_snapshot > 0) then
                use_snapshot := 'TRUE';
            end if;

            -- check for Recovery Appliance usage using v$dataguard_config
            execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
                'from v$dataguard_config ' ||
                'where (DEST_ROLE = ''BACKUP APPLIANCE'')'
                into num_ra;
            if (num_ra > 0) then
                use_ra := 'TRUE';
            end if;

        else
            -- check for Redo Apply (Physical Standby) usage
            execute immediate 'select count(*) from v$archive_dest_status ' ||
                'where status = ''VALID'' and type = ''PHYSICAL'''
                into num_redo_apply;
            if (num_redo_apply > 0) then
                use_redo_apply := 'TRUE';
            end if;

            -- check for SQL Apply (Logical Standby) usage
            execute immediate 'select count(*) from v$archive_dest_status ' ||
                'where status = ''VALID'' and type = ''LOGICAL'''
                into num_sql_apply;
            if (num_sql_apply > 0) then
                use_sql_apply := 'TRUE';
            end if;

            -- check for Far Sync Instance usage
            execute immediate 'select count(*) from v$archive_dest_status ' ||
                'where status = ''VALID'' and type = ''FAR SYNC'''
                into num_far_sync;
            if (num_far_sync > 0) then
                use_far_sync := 'TRUE';
            end if;

            -- copy far sync instance count into cascading standby
            num_casc_stby := num_far_sync;

            -- check for Snapshot Standby usage
            execute immediate 'select count(*) from v$archive_dest_status ' ||
                'where status = ''VALID'' and type = ''SNAPSHOT'''
                into num_snapshot;
            if (num_snapshot > 0) then
                use_snapshot := 'TRUE';
            end if;

            -- check for Recovery Appliance usage using v$archive_dest_status
            execute immediate 'select count(*) from v$archive_dest_status ' ||
                'where status = ''VALID'' and type = ''BACKUP APPLIANCE'''
                into num_ra;
            if (num_ra > 0) then
                use_ra := 'TRUE';
            end if;

        end if;

        -- check for Broker usage by selecting the init param value
        execute immediate 'select value from v$system_parameter ' ||
            'where name = ''dg_broker_start'''
            into use_broker;

        -- get all log transport methods
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver like ''ARC%'''
            into num_arch;
        if (num_arch > 0) then
            log_transport := 'ARCH ';
        end if;
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver = ''LGWR'' ' ||
            'and (transmit_mode = ''SYNCHRONOUS'' or ' ||
            '     transmit_mode = ''PARALLELSYNC'')'
            into num_lgwr_sync;
        if (num_lgwr_sync > 0) then
            log_transport := log_transport || 'LGWR SYNC ';
        end if;
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver = ''LGWR'' ' ||
            'and transmit_mode = ''ASYNCHRONOUS'''
            into num_lgwr_async;
        if (num_lgwr_async > 0) then
            log_transport := log_transport || 'LGWR ASYNC';
        end if;

        -- get protection mode for primary db
        execute immediate 'select protection_mode from v$database'
            into protection_mode;

        -- check for Fast Sync usage
        if (protection_mode = 'MAXIMUM AVAILABILITY') then
            execute immediate 'select count(*) from v$archive_dest ' ||
                'where status = ''VALID'' and target = ''STANDBY'' ' ||
                'and archiver = ''LGWR'' ' ||
                'and (transmit_mode = ''SYNCHRONOUS'' or ' ||
                '     transmit_mode = ''PARALLELSYNC'') ' ||
                'and affirm = ''NO'' '
                into num_fast_sync;
            if (num_fast_sync > 0) then
                use_fast_sync := 'TRUE';
            end if;
        end if;

        -- check for fast-start failover usage
        execute immediate 'select fs_failover_status from v$database'
            into use_fs_failover;
        if (use_fs_failover != 'DISABLED') then
            use_fs_failover := 'TRUE';
        else
            use_fs_failover := 'FALSE';
        end if;

        -- check for realtime apply usage
        -- We can only count the directly connected standbys
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' ' ||
            'and recovery_mode like ''%REAL TIME APPLY%'''
            into num_realtime_apply;
        if (num_realtime_apply > 0) then
            use_realtime_apply := 'TRUE';
        end if;

        -- check for network compression usage
        -- We can only count the directly connected standbys
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and compression = ''ENABLE'''
            into num_compression;
        if (num_compression > 0) then
            use_compression := 'TRUE';
        end if;

        -- check for flashback usage
        execute immediate 'select flashback_on from v$database'
            into use_flashback;
        if (use_flashback = 'YES') then
            use_flashback := 'TRUE';
        else
            use_flashback := 'FALSE';
        end if;

        feature_usage :=
                'Number of standbys: ' || to_char(num_standbys) ||
        ', ' || 'Number of Cascading databases: ' || to_char(num_casc_stby) ||
        ', ' || 'Number of Terminal databases: ' || to_char(num_terminal_db) ||
        ', ' || 'Redo Apply used: ' || upper(use_redo_apply) ||
        ', ' || 'SQL Apply used: ' || upper(use_sql_apply) ||
        ', ' || 'Far Sync Instance used: ' || upper(use_far_sync) ||
        ', ' || 'Snapshot Standby used: ' || upper(use_snapshot) ||
        ', ' || 'Broker used: ' || upper(use_broker) ||
        ', ' || 'Protection mode: ' || upper(protection_mode) ||
        ', ' || 'Log transports used: ' || upper(log_transport) ||
        ', ' || 'Fast Sync used: ' || upper(use_fast_sync) ||
        ', ' || 'Fast-Start Failover used: ' || upper(use_fs_failover) ||
        ', ' || 'Real-Time Apply used: ' || upper(use_realtime_apply) ||
        ', ' || 'Compression used: ' || upper(use_compression) ||
        ', ' || 'Flashback used: ' || upper(use_flashback) ||
        ', ' || 'Recovery Appliance used: ' || upper(use_ra)
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Data Guard usage not detected');
    end if;
end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_ACTIVE_DATA_GUARD
 * The procedure to detect usage for Active Data Guard
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ACTIVE_DATA_GUARD
    (feature_boolean  OUT  NUMBER,
      aux_count        OUT  NUMBER,
      feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_casc_stby         number;
    num_dgconfig          number;
    num_far_sync          number;
    num_realtime_query    number;
    num_terminal_db       number;
    num_rolling           number;
    num_rolling_logs      number;
    num_rolling_parts     number;
    num_rolling_pops      number;
    num_rolling_pots      number;
    num_global_seq_use    number;
    use_global_sequences  varchar2(5);
    use_realtime_query    varchar2(5);
    use_rolling           varchar2(5);
BEGIN
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_casc_stby := 0;
    num_dgconfig :=0;
    num_far_sync := 0;
    num_realtime_query := 0;
    num_terminal_db := 0;
    num_rolling := 0;
    num_rolling_logs := 0;
    num_rolling_parts := 0;
    num_rolling_pops := 0;
    num_rolling_pots := 0;
    num_global_seq_use := 0;
    use_global_sequences := 'FALSE';
    use_realtime_query := 'FALSE';
    use_rolling := 'FALSE';

    -- We have to first look for each Active Data Guard feature before we can
    -- report if they are using any of them.

    -- determine if v$dataguard_config is populated
    execute immediate 'select count(*) from v$dataguard_config'
        into num_dgconfig;

    -- Depending on whether v$dataguard_config is populated or not, some
    -- of the commands below will either use v$dataguard_config or
    -- v$archive_dest.

    if (num_dgconfig > 0) then
        -- get number of Far Sync Instances
        execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
            'from v$dataguard_config ' ||
            'where (DEST_ROLE = ''FAR SYNC INSTANCE'')'
            into num_far_sync;
        if (num_far_sync > 0) then
            feature_boolean := 1;
        end if;

        -- get the number of cascading standbys
        execute immediate 'select count(unique(PARENT_DBUN)) ' ||
            'from v$dataguard_config ' ||
            'where (PARENT_DBUN not in ' ||
            '(select DB_UNIQUE_NAME from v$database) and ' ||
            'PARENT_DBUN != ''NONE'' and PARENT_DBUN != ''UNKNOWN'')'
            into num_casc_stby;
        if (num_casc_stby > 0) then
            feature_boolean := 1;
        end if;

        -- get the number of terminal databases
        -- Note: this is not an Active Data Guard feature, but we report it.
        execute immediate 'select count(unique(DB_UNIQUE_NAME)) ' ||
            'from v$dataguard_config ' ||
            'where (DB_UNIQUE_NAME not in ' ||
            '(select PARENT_DBUN from v$dataguard_config) and ' ||
            'PARENT_DBUN != ''UNKNOWN'')'
            into num_terminal_db;

        -- check for DBMS_ROLLING usage
        execute immediate 'select count(status) from dba_rolling_status'
            into num_rolling;
        if (num_rolling > 0) then
            feature_boolean := 1;
            use_rolling := 'TRUE';

            -- get the total number of DBMS_ROLLING participants
            execute immediate 'select count(dbun) '                     ||
                'from dba_rolling_databases '                           ||
                'where participant=''YES'''
                into num_rolling_parts;

            -- get the number of physicals of the original primary
            execute immediate 'select count(scope) '                    ||
                'from dba_rolling_parameters where name=''PROTECTS'''   ||
                'and curval=''PRIMARY'' and scope in (select dbun '     ||
                'from dba_rolling_databases where participant=''YES'''  ||
                'and role=''PHYSICAL'')' 
                into num_rolling_pops;

            -- get the number of physicals of the future primary
            execute immediate 'select count(scope) '                    ||
                'from dba_rolling_parameters where name=''PROTECTS'''   ||
                'and curval=''TRANSIENT'' and scope in (select dbun '   ||
                'from dba_rolling_databases where participant=''YES'' ' || 
                'and role=''PHYSICAL'')' 
                into num_rolling_pots;

            -- get the number of logical standbys
            execute immediate 'select count(dbun) '                     ||
                'from dba_rolling_databases where participant=''YES'' ' || 
                'and role=''LOGICAL'' and dbun != '                     ||
                '(select future_primary from dba_rolling_status)' 
                into num_rolling_logs;
        end if;
    else
        -- get number of Far Sync Instances
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' and type = ''FAR SYNC'''
            into num_far_sync;
        if (num_far_sync > 0) then
            feature_boolean := 1;
        end if;

        -- copy far sync instance count into cascading standby
        num_casc_stby := num_far_sync;
    end if;

    -- check for real time query usage
    -- We can only count the directly connected standbys
    execute immediate 'select count(*) from v$archive_dest_status ' ||
        'where status = ''VALID'' and ' ||
        'recovery_mode like ''MANAGED%QUERY'' and ' ||
        'database_mode = ''OPEN_READ-ONLY'''
        into num_realtime_query;
    if (num_realtime_query > 0) then
        use_realtime_query := 'TRUE';
        feature_boolean := 1;
    end if;
    -- check for global sequence usage
    execute immediate 'select count(*) from dba_sequences ' ||  
        'where sequence_owner != ''SYS'' and session_flag = ''N'''
        into num_global_seq_use;
    if (num_global_seq_use > 0) then
        use_global_sequences := 'TRUE';
    end if;
    if (feature_boolean = 1) then
        feature_usage :=
                'Number of Far Sync Instances: ' || to_char(num_far_sync) ||
        ', ' || 'Number of Cascading databases: ' || to_char(num_casc_stby) ||
        ', ' || 'Number of Terminal databases: ' || to_char(num_terminal_db) ||
        ', ' || 'Real Time Query used: ' || upper(use_realtime_query) ||
        ', ' || 'Global Sequences used: ' || upper(use_global_sequences) ||
        ', ' || 'DBMS_ROLLING used: ' || upper(use_rolling) ||
        ', ' || 'Number of DBMS_ROLLING Participants: ' 
             || to_char(num_rolling_parts) ||
        ', ' || 'Number of DBMS_ROLLING OP Physicals: ' 
             || to_char(num_rolling_pops) ||
        ', ' || 'Number of DBMS_ROLLING FP Physicals: ' 
             || to_char(num_rolling_pots) ||
        ', ' || 'Number of DBMS_ROLLING OP Logicals: ' 
             || to_char(num_rolling_logs) 
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Active Data Guard usage not detected');
    end if;
END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_MOVE_DATAFILE
 * The procedure to detect usage for Online Move Datafile
 ***************************************************************/

create or replace procedure DBMS_FEATURE_MOVE_DATAFILE
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage      varchar2(1000);
    use_omd_primary    varchar2(5);
    use_pri            number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    use_omd_primary := 'FALSE';

    execute immediate 'select DI2MVUSE_PRI from X$KCCDI2'
      into use_pri;
    if (use_pri > 0) then
      use_omd_primary := 'TRUE';
      feature_boolean := 1;
    end if;

    if (feature_boolean = 1) then
        feature_usage :=
                'Online Move Datafile on primary used: '
             || upper(use_omd_primary)
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Online Move Datafile usage not detected');
    end if;
end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_DATA_REDACTION
 * The procedure to detect usage for Data Redaction
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DATA_REDACTION
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_policies          number;
    num_policies_enabled  number;
    num_full_redaction    number;
    num_partial_redaction number;
    num_random_redaction  number;
    num_regexp_redaction   number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_policies := 0;
    num_policies_enabled := 0;
    num_full_redaction := 0;
    num_partial_redaction := 0;
    num_random_redaction := 0;
    num_regexp_redaction := 0;
    
    -- check for Data Redaction usage by counting number of policies
    execute immediate 'select count(*) from REDACTION_POLICIES '
        into num_policies;

    if (num_policies > 0) then
        feature_boolean := 1;

        -- check for enable Data Radaction policy usage
        execute immediate 'select count(*) from REDACTION_POLICIES ' ||
            'where upper(ENABLE) like ''%YES%'''
            into num_policies_enabled;

        -- check for Full Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''FULL REDACTION'''
            into num_full_redaction;
     
        -- check for Partial Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''PARTIAL REDACTION'''
            into num_partial_redaction;

        -- check for Random Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''RANDOM REDACTION'''
            into num_random_redaction;

        -- check for Regexp-based Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''REGEXP REDACTION'''
            into num_regexp_redaction;

        feature_usage :=
                'Number of data redaction policies: ' || 
                 to_char(num_policies) ||
        ', ' || 'Number of enabled policies: ' || 
                 to_char(num_policies_enabled) ||
        ', ' || 'Number of policies using full redaction: ' || 
                 to_char(num_full_redaction) ||
        ', ' || 'Number of policies using partial redaction: ' || 
                 to_char(num_partial_redaction) ||
        ', ' || 'Number of policies using random redaction: ' || 
                 to_char(num_random_redaction)  ||
        ', ' || 'Number of policies using regexp redaction: ' || 
                 to_char(num_regexp_redaction)
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Data Redaction usage not detected');
    end if;

end;
/

/***************************************************************
 *  DBMS_FEATURE_DATABASE_ODM
 *  The procedure to detect usage for Oracle Data Mining
***************************************************************/

create or replace procedure DBMS_FEATURE_DATABASE_ODM
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   dm_on              NUMBER;     -- data mining option on
   model_cnt          NUMBER;
   dm_usage           varchar2(32767);
begin
  -- initialize
  feature_boolean   := 0;
  aux_count         := 0;
  feature_info      := NULL;
  model_cnt         := 0;

  -- check if ODM option is installed
  select count(*) into dm_on from v$option where
     parameter = 'Data Mining' and value = 'TRUE';

  if (dm_on = 0) then
    return;
  end if;
 
   execute immediate
         'select count(*), listagg(feature,'';'') within group (order by feature) ' ||
     'from ( ' ||
       'with a as ( ' ||
        'select decode(func ' ||
          ',1, ''CLASSIFICATION'' ' ||
          ',2, ''REGRESSION'' ' ||
          ',3, ''CLUSTERING'' ' ||
          ',4, ''FEATURE_EXTRACTION''  ' ||
          ',5, ''ASSOCIATION_RULES''  ' ||
          ',6, ''ATTRIBUTE_IMPORTANCE''  ' ||
          ',0)||''(''||   ' ||
          ' decode(alg ' ||
          ',1, ''NAIVE_BAYES''  ' ||
          ',2, ''ADAPTIVE_BAYES_NETWORK''  ' ||
          ',3, ''DECISION_TREE''   ' ||
          ',4, ''SUPPORT_VECTOR_MACHINES''  ' ||
          ',5, ''KMEANS''   ' ||
          ',6, ''O_CLUSTER''  ' ||
          ',7, ''NONNEGATIVE_MATRIX_FACTOR''   ' ||
          ',8, ''GENERALIZED_LINEAR_MODEL''  ' ||
          ',9, ''APRIORI_ASSOCIATION_RULES''   ' ||
          ',10, ''MINIMUM_DESCRIPTION_LENGTH''   ' ||
          ',11, ''SINGULAR_VALUE_DECOMP''   ' ||
          ',12, ''EXPECTATION_MAXIMIZATION''    ' ||
          ',0)||'')'' feat from model$  ' ||
          'where (alg not in (4,5)) or  ' ||
          '(alg in (4,5) and obj# in (select mod# from modeltab$ where typ#=2))) ' ||
      'select feat||''(''||count(*)||'')'' feature from a group by feat order by count(*))'
       into model_cnt, dm_usage;

    if (model_cnt  > 0)   then     --- feature used
        feature_boolean := 1;
        aux_count := model_cnt;
        feature_info := TO_CLOB(dm_usage);
    else                        --- feature not used
        feature_boolean := 0;
        aux_count := 0;
        feature_info := null;
    end if;

END DBMS_FEATURE_DATABASE_ODM;
/


/***************************************************************
 * DBMS_FEATURE_DYN_SGA
 * The procedure to detect usage of Dynamic SGA
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DYN_SGA
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  num_resize_ops         number;                 -- number of resize operations
  feature_usage          varchar2(1000);
begin
  -- initialize
  num_resize_ops := 0;
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Dynamic SGA usage not detected');
  feature_usage := '';

  execute immediate 'select count(*) from v$sga_resize_ops ' ||
                    'where oper_type in (''GROW'', ''SHRINK'') and ' ||
                    'oper_mode=''MANUAL''and ' ||
                    'start_time >= ' ||
                    'to_date((select nvl(max(last_sample_date), sysdate-7) ' ||
                    'from dba_feature_usage_statistics))'
  into num_resize_ops;

  if num_resize_ops > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':rsz ops:'||num_resize_ops;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;

    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_AUTO_SGA
 * The procedure to detect usage of Automatic SGA Tuning
 ***************************************************************/

create or replace procedure DBMS_FEATURE_AUTO_SGA
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
  sga_target             number;
  sga_max_size           number;
begin

  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Automatic SGA Tuning usage not detected');
  feature_usage := '';
  sga_target := 0;
  sga_max_size := 0;

  execute immediate 'select to_number(value) from v$system_parameter where ' ||
                    'name like ''sga_target'' and con_id = 0'
  into sga_target;

  if sga_target > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':sga_target:'||sga_target;

    -- get sga_max_size value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''sga_max_size'' and con_id = 0'
    into sga_max_size;

    feature_usage := feature_usage||':sga_max_size:'||sga_max_size;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;
    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_AUTO_MEM
 * The procedure to detect usage of Automatic Memory Tuning
 ***************************************************************/

create or replace procedure DBMS_FEATURE_AUTO_MEM
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
  memory_target             number;
  sga_max_size              number;
  memory_max_target         number;
begin

  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Automatic Memory Tuning usage not detected');
  feature_usage := '';
  memory_target := 0;
  sga_max_size := 0;
  memory_max_target := 0;

  execute immediate 'select to_number(value) from v$system_parameter where ' ||
                    'name like ''memory_target'''
  into memory_target;

  if memory_target > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':memory_target:'||memory_target;

    -- get sga_max_size value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''sga_max_size'''
    into sga_max_size;

    feature_usage := feature_usage||':sga_max_size:'||sga_max_size;

    -- get memory_max_target value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''memory_max_target'''
    into memory_max_target;

    feature_usage := feature_usage||':memory_max_target:'||memory_max_target;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$pgastat info
    for item in (select name, value from v$pgastat where
                 name in ('tot PGA alc', 'over alc cnt',
                          'tot PGA for auto wkar',
                          'tot PGA for man wkar',
                          'glob mem bnd', 'aggr PGA auto tgt',
                          'aggr PGA tgt prm'))
    loop
      feature_usage := feature_usage||':'||item.name||':'||item.value;
    end loop;

    -- get v$memory_target_advice info
    feature_usage := feature_usage||':mem tgt adv:';
    for item in (select memory_size, memory_size_factor, estd_db_time,
                 estd_db_time_factor from v$memory_target_advice
                 order by memory_size)
    loop
      feature_usage := feature_usage||':msz:'||item.memory_size||
                       ':sf:'||item.memory_size_factor||
                       ':time:'||item.estd_db_time||
                       ':tf:'||item.estd_db_time_factor;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;

    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_RESOURCE_MANAGER
 * The procedure to detect usage of Resource Manager
 ***************************************************************/

create or replace procedure DBMS_FEATURE_RESOURCE_MANAGER
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage             varchar2(1000);
  non_maint_sql             varchar2(2000);
  non_maint_usage           number;
  non_maint_cpu             number;
  non_maint_other           number;
begin

  -- Initialize all variables

  feature_boolean := 0;  
  aux_count       := 0;
  feature_info    := to_clob('Resource Manager usage not detected');

  feature_usage   := NULL;
  non_maint_sql   := NULL;
  non_maint_cpu   := 0;
  non_maint_other := 0;

  -- 'feature_boolean' is set to 1 if Resource Manager was enabled, not
  -- including for maintenance windows.
  -- 
  -- The SQL clause is saying it found a plan that is set, not internal,
  -- not maintenance (or if it is, it has a null window or a non-maintenance 
  -- window name), not default_cdb_plan (or if it is, either no PDB plans 
  -- are set or non-maintenance PDB plans are set).
  --
  -- We cannot use the CDB's and PDB's sequence#s because the are not sync'd.
  -- Therefore, we see if count(PDBs with non-maintenance plans) > 0 or
  -- count(PDBs with plans) = 0.

  non_maint_sql := 
      'select decode(count(*), 0, 0, 1) from v$rsrc_plan_history top where ' ||
      '(name != ''ORA$INTERNAL_CDB_PLAN'' and ' ||
      ' name != ''INTERNAL_PLAN'' and name is not null and ' ||
      ' (name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '   (window_name is null or ' ||
      '    (window_name != ''MONDAY_WINDOW'' and ' ||
      '     window_name != ''TUESDAY_WINDOW'' and ' ||
      '     window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '     window_name != ''THURSDAY_WINDOW'' and ' ||
      '     window_name != ''FRIDAY_WINDOW'' and ' ||
      '     window_name != ''SATURDAY_WINDOW'' and ' ||
      '     window_name != ''SUNDAY_WINDOW''))) and ' ||
      ' (name != ''DEFAULT_CDB_PLAN'' or ' ||
      '   (select count(*) from v$rsrc_plan_history pdb ' ||
      '      where pdb.con_id > 1 and pdb.name is not null) = 0 or ' ||
      '   (select count(*) from v$rsrc_plan_history pdb ' ||
      '      where pdb.con_id > 1 and ' ||
      '            pdb.name is not null and ' ||
      '            pdb.name != ''INTERNAL_PLAN'' and ' ||
      '            (pdb.name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '              (pdb.window_name is null or ' ||
      '               (pdb.window_name != ''MONDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''TUESDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''THURSDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''FRIDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''SATURDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''SUNDAY_WINDOW'')))) > 0))';
  execute immediate
    non_maint_sql
  into feature_boolean;

  -- 'aux_count' is not being used

  -- 'feature_info' is constructed of the following name-value pairs:
  --   Non-Maintenance CPU Management:
  --     This field is set to 1 if Resource Manager was enabled explicitly
  --     and the Resource Plan was managing CPU.
  --   Non-Maintenance Other Management:
  --     This field is set to 1 if Resource Manager was enabled explicitly
  --     and the Resource Plan was NOT managing CPU, i.e. the Resource Plan
  --     was managing idle time, switch time, DOP, etc.

  if feature_boolean > 0
  then
    execute immediate 
      non_maint_sql || ' and cpu_managed = ''ON'' '
    into non_maint_cpu;

    execute immediate 
      non_maint_sql || ' and cpu_managed = ''OFF'' '
    into non_maint_other;

    feature_usage := 
      'Non-Maintenance CPU Management: ' || non_maint_cpu ||
      ', Non-Maintenance Other Management: ' || non_maint_other;

    feature_info := to_clob(feature_usage);
  end if;

end dbms_feature_resource_manager;
/
show errors;


/***************************************************************
 * DBMS_FEATURE_RMAN_ZLIB
 *  The procedure to detect usage of RMAN ZLIB compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_ZLIB
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted => FALSE, 
                    compalg => 'ZLIB');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_BZIP2
 *  The procedure to detect usage of RMAN BZIP2 compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BZIP2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'BZIP2');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_BASIC
 *  The procedure to detect usage of RMAN BASIC compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BASIC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'BASIC');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_LOW
 *  The procedure to detect usage of RMAN LOW compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_LOW
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'LOW');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_MEDIUM
 *  The procedure to detect usage of RMAN MEDIUM compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_MEDIUM
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'MEDIUM');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_HIGH
 *  The procedure to detect usage of RMAN HIGH compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_HIGH
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'HIGH');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_BACKUP_ENCRYPTION
 *  The procedure to detect usage of RMAN ENCRYPTION on backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_BACKUP_ENCRYPTION
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => TRUE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_RMAN_BACKUP
 *  The procedure to detect usage of RMAN backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_DISK_BACKUP
 *  The procedure to detect usage of RMAN backups on DISK
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_DISK_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => TRUE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_TAPE_BACKUP
 *  The procedure to detect usage of RMAN backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_TAPE_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => TRUE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_AUTO_SSM
 *  The procedure to detect usage for Automatic Segment Space
 *  Managed tablespaces
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_auto_ssm
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  auto_seg_space boolean;
  ts_info        varchar2(1000);
BEGIN

  /* initialize everything */
  auto_seg_space := FALSE;
  ts_info        := '';
  aux_count      := 0;

  for ts_type in 
     (select segment_space_management, count(*) tcount, sum(size_mb) size_mb
       from
        (select ts.tablespace_name, segment_space_management, 
              sum(bytes)/1048576 size_mb
          from dba_data_files df, dba_tablespaces ts
         where df.tablespace_name = ts.tablespace_name
         group by ts.tablespace_name, segment_space_management)
       group by segment_space_management)
  loop

    /* check for auto segment space management */    
    if ((ts_type.segment_space_management = 'AUTO') and
         (ts_type.tcount > 0)) then
      auto_seg_space  := TRUE;
      aux_count       := ts_type.tcount;
    end if;

    ts_info := ts_info || 
        '(Segment Space Management: ' || ts_type.segment_space_management ||
       ', TS Count: ' || ts_type.tcount ||
       ', Size MB: '  || ts_type.size_mb || ') ';

  end loop; 

  /* set the boolean and feature info.  the aux count is already set above */
  if (auto_seg_space) then
    feature_boolean := 1;
    feature_info    := to_clob(ts_info);
  else
    feature_boolean := 0;
    feature_info    := null;
  end if;

END dbms_feature_auto_ssm;
/

show errors;


/******************************************************************
 * DBMS_FEATURE_LMT
 *  The procedure to detect usage for Locally Managed tablespaces
 ******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_lmt
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  loc_managed boolean;
  ts_info     varchar2(1000);  
BEGIN

  /* initialize everything */
  loc_managed := FALSE;
  ts_info     := '';
  aux_count   := 0;

  for ts_type in 
     (select extent_management, count(*) tcount, sum(size_mb) size_mb
       from
        (select ts.tablespace_name, extent_management, 
                sum(bytes)/1048576 size_mb
           from dba_data_files df, dba_tablespaces ts
          where df.tablespace_name = ts.tablespace_name
          group by ts.tablespace_name, extent_management)
       group by extent_management)
  loop

    /* check for auto segment space management */    
    if ((ts_type.extent_management = 'LOCAL') and
         (ts_type.tcount > 0)) then
      loc_managed  := TRUE;
      aux_count       := ts_type.tcount;
    end if;

    ts_info := ts_info || 
        '(Extent Management: ' || ts_type.extent_management ||
       ', TS Count: ' || ts_type.tcount ||
       ', Size MB: '  || ts_type.size_mb || ') ';

  end loop; 

  /* set the boolean and feature info.  the aux count is already set above */
  if (loc_managed) then
    feature_boolean := 1;
    feature_info    := to_clob(ts_info);
  else
    feature_boolean := 0;
    feature_info    := null;
  end if;

END dbms_feature_lmt;
/

show errors;

/******************************************************************
 * DBMS_FEATURE_SEGADV_USER
 *  The procedure to detect usage for Segment Advisor (user)
 ******************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_segadv_user
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  execs_since_sample    NUMBER;               -- # of execs since last sample
  total_execs           NUMBER;               -- total # of execs
  total_recs            NUMBER;               -- total # of recommendations
  total_space_saving    NUMBER;               -- total potential space saving
  tmp_buf               VARCHAR2(32767);      -- temp buffer
BEGIN
  -- executions since last sample
  SELECT  count(*) 
  INTO    execs_since_sample
  FROM    dba_advisor_executions
  WHERE   advisor_name = 'Segment Advisor' AND
          task_name not like 'SYS_AUTO_SPCADV%' AND
          execution_last_modified >= (SELECT nvl(max(last_sample_date),
                                                sysdate-7) 
                                     FROM   dba_feature_usage_statistics);
      
  -- total # of executions
  SELECT  count(*) 
  INTO    total_execs
  FROM    dba_advisor_executions
  WHERE   advisor_name = 'Segment Advisor' AND
          task_name not like 'SYS_AUTO_SPCADV%';

  -- total # of recommendations and total potential space saving
  SELECT  count(task.task_id), NVL(sum(msg.p3),0)
  INTO    total_recs, total_space_saving
  FROM    dba_advisor_tasks task, 
          sys.wri$_adv_findings fin,
          sys.wri$_adv_recommendations rec,
          sys.wri$_adv_message_groups msg
  WHERE   task.advisor_name = 'Segment Advisor' AND
          task.task_name not like 'SYS_AUTO_SPCADV%' AND
          task.task_id = rec.task_id AND
          nvl(rec.annotation,0) <> 3 AND
          fin.task_id = rec.task_id AND 
          fin.id = rec.finding_id AND
          msg.task_id = fin.task_id AND 
          msg.id = fin.more_info_id;
  
  -- set feature_used and aux_count 
  feature_boolean := execs_since_sample;
  aux_count := execs_since_sample;

  -- prepare feature_info
  tmp_buf := 'Executions since last sample: ' || execs_since_sample || ', ' ||
             'Total Executions: ' || total_execs || ', ' ||
             'Total Recommendations: ' || total_recs   || ', ' ||
             'Projected Space saving (byte): ' || total_space_saving;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  
END dbms_feature_segadv_user;
/

show errors;

/******************************************************************
 * DBMS_FEATURE_AUM
 *  The procedure to detect usage for Automatic Undo Management
 ******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_aum
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  ts_info         varchar2(1000);  
  undo_blocks     number;
  max_concurrency number;  
BEGIN

  select count(*) into feature_boolean from v$system_parameter where
    name = 'undo_management' and upper(value) = 'AUTO';

  if (feature_boolean = 0) then
    /* not automatic undo management */
    aux_count    := 0;
    feature_info := null;
  else

    aux_count := 0;

    /* undo tablespace information */
    for ts_type in 
      (select retention, count(*) tcount, sum(size_mb) size_mb
        from
         (select ts.tablespace_name, retention, sum(bytes)/1048576 size_mb
           from dba_data_files df, dba_tablespaces ts
          where df.tablespace_name = ts.tablespace_name
            and ts.contents = 'UNDO'
          group by ts.tablespace_name, retention)
        group by retention)
    loop

      /* track total number of tablespaces */
      aux_count := aux_count + ts_type.tcount;

      ts_info := ts_info || 
          '(Retention: ' || ts_type.retention ||
         ', TS Count: ' || ts_type.tcount ||
         ', Size MB: '  || ts_type.size_mb || ') ';

    end loop; 

    /* get some more information */
    select sum(undoblks), max(maxconcurrency) 
      into undo_blocks, max_concurrency
      from v$undostat
      where begin_time >=
             (SELECT nvl(max(last_sample_date), sysdate-7) 
                FROM dba_feature_usage_statistics);

    ts_info := ts_info || '(Undo Blocks: ' || undo_blocks ||
                         ', Max Concurrency: ' || max_concurrency || ') ';

    for ssold in
      (select to_char(min(begin_time), 'YYYY-MM-DD HH24:MI:SS') btime,
              to_char(max(end_time),   'YYYY-MM-DD HH24:MI:SS') etime,
              sum(SSOLDERRCNT) errcnt
        from v$undostat 
        where (begin_time >=
               (SELECT nvl(max(last_sample_date), sysdate-7) 
                  FROM dba_feature_usage_statistics)))
    loop
      ts_info := ts_info || 
          '(Snapshot Old Info - Begin Time: ' || ssold.btime || 
                        ', End Time: '   || ssold.etime || 
                        ', SSOLD Error Count: ' || ssold.errcnt || ') ';
    end loop;

    feature_boolean := 1;
    feature_info    := to_clob(ts_info);

  end if;

END dbms_feature_aum;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_JOB_SCHEDULER
 *  The procedure to detect usage for DBMS_SCHEDULER
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_job_scheduler
      (is_used OUT number, nr_of_jobs OUT number, summary OUT clob)
AS
sum1 varchar2(4000);
n1 number;
n2 number;
n3 number;
n4 number;
n5 number;
n6 number;
n7 number;
n8 number;
n9 number;

BEGIN
  select count(*) into nr_of_jobs from dba_scheduler_jobs where 
      owner not in ('SYS', 'ORACLE_OCM', 'EXFSYS' ) 
       and job_name not like 'AQ$%'
       and job_name not like 'MV_RF$J_%';

  is_used := nr_of_jobs;
  -- if job used 
  if is_used = 0  then return; end if;

select count(*) into n1 from dba_scheduler_jobs;
    sum1  := sum1 
              || 'JNRA:' || n1
              || ',JNRU:' || nr_of_jobs; 

select count(*) into n1 from dba_jobs;
    sum1  := sum1 
              || ',DJOBS:' || n1; 
-- Direct per job type counts, i.e of the total number of jobs how many are
--  program vs executable vs plsql block vs stored procedure vs chain


  for it in  (
select jt t, count(*) n
from (select   nvl(job_type, 'PROGRAM') jt
from   dba_scheduler_jobs )
group by jt order by 1) 
  loop  
    sum1  := sum1 || ',JTD' || substr(it.t,1,3) || ':' || it.n;
  end loop;

 
-- Indirect per job type counts. 
-- In this case the you have to track down the program type of all 
-- the jobs whose jobs are of type program. 
-- So now of the the total number of jobs, how many are
--  executable vs plsql block vs stored procedure vs chain

  for it in  (
select jt t, count(*) n from 
   (select program_type jt
      from dba_scheduler_jobs j, 
         dba_scheduler_programs p 
    where 
            job_type is null 
            and p.owner = j.program_owner 
            and p.program_name = j.program_name 
    union all 
     select 'NAP' 
      from dba_scheduler_jobs j
       where
            j.job_type is null
            and not exists (select 1 from 
             dba_scheduler_programs p
              where
               p.owner = j.program_owner    
              and p.program_name = j.program_name) 
    union all 
    select   job_type
    from   dba_scheduler_jobs where job_type is not null)
     group by jt order by 1)
  loop  
    sum1  := sum1 || ',JTI' || substr(it.t,1,3) || ':' || it.n;
  end loop;
-- Direct per schedule type counts, i.e. of the total 
-- number of jobs how many are
-- repeat_interval is null, schedule based, event based, file watcher based, 
-- plsql repeat interval, calendar repeat interval, window based



  for it in  (
select schedule_type t, 
         count(*) n 
from   dba_scheduler_jobs 
group by schedule_type order by 1)
  loop  
    sum1  := sum1 || ',JDS' || substr(replace(it.t, 'WINDOW_','W'),1,3) || ':' || it.n;
  end loop;

-- Indirect per schedule type counts. In this case the schedule based jobs are 
-- tracked down to their eventual schedule type. So now of the total number of jobs, how many are
--  repeat_interval is null, event based, file watcher, plsql repeat interval, 
-- calendar repeat interval, window (group) based

  for it in  (
select schedule_type t, count(*) n from 
   (select p.schedule_type
      from dba_scheduler_jobs j, 
         dba_scheduler_schedules p 
    where 
            j.schedule_type = 'NAMED' 
            and p.owner = j.schedule_owner 
            and p.schedule_name = j.schedule_name 
    union all 
    select   schedule_type
    from   dba_scheduler_jobs where schedule_type <> 'NAMED')
     group by schedule_type order by 1)
  loop  
    sum1  := sum1 || ',JIS' || substr(replace(it.t, 'WINDOW_','W'),1,3) || ':' || it.n;
  end loop;
   

-- Number of jobs that have destination set to a 
-- single destination vs destination set to a destination group

 for it in (
select dest t, count(*) n 
   from (select decode(number_of_destinations,1, 'SD', 'MD') dest 
       from dba_scheduler_jobs where destination is not null)
   group by dest order by 1) 
  loop  
    sum1  := sum1 || ',JD' || it.t || ':' || it.n;
  end loop;

-- Number of external jobs (job type or program type executable) split across local without a credential, 
-- local with credential, remote single destination, remote destination group
 for it in (
select ext_type t, count(*) n from
(select job_name, decode(destination, null,
     decode(credential_name, null,'JXL','JXLC'),
     decode(dest_type,null,'JXRID','SINGLE','JXRSD','JXRGD')) ext_type from
(select job_name, job_type, credential_name, destination_owner, destination
from all_scheduler_jobs where program_name is null
union all
select job_name, program_type, credential_name, destination_owner, destination
from all_scheduler_jobs aj, all_scheduler_programs ap
where aj.program_owner = ap.owner and aj.program_name = ap.program_name) aij,
(select owner, group_name dest_name, 'GROUP' dest_type from all_scheduler_groups
where group_type = 'EXTERNAL_DEST'
union all
select 'SYS', destination_name, 'SINGLE' from all_scheduler_external_dests) ad
where job_type in ('EXECUTABLE','EXTERNAL_SCRIPT')  and aij.destination_owner = ad.owner(+) and
aij.destination = ad.dest_name(+)) group by ext_type order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;


-- Number of remote database jobs with single destination versus number of jobs with destination group (i.e. destination is set and job type or program type is plsql block or stored procedure).

 for it in (
select dest_type t, count(*) n from
    (select  job_type, destination_owner, destination
        from all_scheduler_jobs where program_name is null
    union all
    select  program_type, destination_owner, destination
        from all_scheduler_jobs aj, all_scheduler_programs ap
            where aj.program_owner = ap.owner and aj.program_name = ap.program_name) aij,
    (select owner, group_name dest_name, 'JDBG' dest_type from all_scheduler_groups
            where group_type = 'DB_DEST'
     union all
     select owner, destination_name, 'JDBS' from all_scheduler_db_dests) ad
 where job_type in  ('STORED_PROCEDURE','PLSQL_BLOCK','SQL_SCRIPT', 'BACKUP_SCRIPT') and
       aij.destination is not null and aij.destination_owner = ad.owner(+) and
       aij.destination = ad.dest_name(+) group by dest_type order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

-- Number of jobs with arguments. For those jobs with arguments, avg,
-- median and max number of job arguments.

select count(*),  
       avg(number_of_arguments), 
       median(number_of_arguments), 
       max(number_of_arguments) into  n1, n2, n3, n4
from dba_scheduler_jobs where number_of_arguments > 0;

    sum1  := sum1 
              || ',JAC:' || n1 
              || ',JAA:' || round(n2) 
              || ',JAM:' || n3 
              || ',JAX:' || n4; 

-- Split total number of jobs across job_style, i.e. regular vs lightweight

 for it in (
select job_style t, count(*) n from dba_scheduler_jobs
     group by job_style order by 1)
  loop  
    sum1  := sum1 || ',JST' || substr(it.t,1,3) || ':' || it.n;
  end loop;
   

-- Number of jobs that have restartable set to true
-- How many have max_run_duration set
-- How many have schedule_limit set
-- How many have instance_id set
-- How many have allow_runs_in_restricted_mode set
-- How many have raise_events set
-- How many have parallel_instances set
select sum(decode(restartable,null, 0,1)),
       sum(decode(max_run_duration,null, 0,1)) ,
       sum(decode(schedule_limit,null, 0,1)) ,
       sum(decode(instance_id,null, 0,1)) ,
       sum(decode(allow_runs_in_restricted_mode,'FALSE', 0,1)) ,
       sum(decode(bitand(flags, 2147483648),2147483648,1,0)),
       sum(decode(bitand(flags, 68719476736),68719476736,1,0)),
       sum(decode(enabled,'FALSE',1,0)),
       sum(decode(raise_events,null, 0,1)) 
             into n1, n2, n3, n4, n5,n6, n7, n8, n9
from dba_scheduler_jobs;
    sum1  := sum1 
              || ',JRS:' || n1 
              || ',JMRD:' || n2 
              || ',JSL:' || n3 
              || ',JII:' || n4 
              || ',JAR:' || n5 
              || ',JFLW:' || n7 
              || ',JRE:' || n9 
              || ',JDIS:' || n8 
              || ',JPI:' || n6; 

-- Total number of programs
-- Per type program numbers, i.e. the number of executable, plsql_block, 
-- stored procedure, chain programs

 for it in (
select program_type t, count(*) n from dba_scheduler_programs 
    group by program_type order by 1)
  loop  
    sum1  := sum1 || ',PRT' || substr(it.t,1,3) || ':' || it.n;
  end loop;


-- Number of programs with arguments
-- For programs with arguments, avg, mean and max number of arguments
select count(*) ,  round(avg(number_of_arguments)) , 
       median(number_of_arguments) , 
      max(number_of_arguments)  
         into n1, n2, n3, n4
from dba_scheduler_programs where number_of_arguments > 0;
    sum1  := sum1 
              || ',PAC:' || n1 
              || ',PAA:' || n2 
              || ',PAM:' || n3 
              || ',PAX:' || n4; 

-- Total number of schedules
-- Split across schedule type. How many in each category:
-- run once, plsql repeat interval, calendar repeat interval, event based, 
-- file watcher, window based


 for it in (
select schedule_type t, count(*) n from dba_scheduler_schedules group by
     schedule_type order by 1)
  loop  
    sum1  := sum1 || ',SST' || substr(it.t,1,3) || ':' || it.n;
  end loop;


-- Total number of arguments
-- How many of them are named arguments

 for it in (
select an t, count(*) n 
    from (select  decode(argument_name, null, 'PA_', 'PAN') an from
    dba_scheduler_program_args) group by an order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

-- Split across count of metadata arguments, varchar based args, anydata based arguments
 for it in (
select metadata_attribute t, count(*) n from dba_scheduler_program_args where 
         metadata_attribute is not null group by metadata_attribute order by 1)
  loop  
    sum1  := sum1 || ',PM' || 
                  substr(replace(replace(it.t,'JOB_','J'),'WINDOW_','W'),1,3) 
                    || ':' || it.n;
  end loop;

-- Job Classes
-- Total number of job classes
-- How many have service set
-- How many have resource consumer group set
-- split across logging levels, i.e. how many no logging, failed runs, runs only, full

select count(*) , sum(decode(service, null, 0, 1)) ,
sum(decode(resource_consumer_group, null, 0, 1)) into n1,n2,n3 
from dba_scheduler_job_classes;
    sum1  := sum1 
              || ',JCNT:' || n1 
              || ',JCSV:' || n2 
              || ',JCCG:' || n3 ;

 for it in (
select logging_level t, count(*) n from dba_scheduler_job_classes 
    group by logging_level order by 1)
  loop  
    sum1  := sum1 || ',LL' || substr(it.t,1,3)  || ':' || it.n;
  end loop;

-- Windows
-- Total number of windows
-- Number of high priority windows (low = total - high)
-- Number of windows without a resource plan
-- Number of named schedule based windows (inlined schedule = total - named schedule)
 for it in (
select window_priority t, count(*) n from dba_scheduler_windows 
    group by window_priority order by 1) 
  loop  
    sum1  := sum1 || ',WIP' || substr(it.t,1,2) || ':' || it.n;
  end loop;

select count(*) into n1 from dba_scheduler_windows  where resource_plan is
 null;
    sum1  := sum1 
              || ',WINR:' || n1;

 for it in (
select st t, count(*) n from  
   (select schedule_type  st
     from
     dba_scheduler_windows)  group by st order by 1) 
  loop  
    sum1  := sum1 || ',SWT' || substr(it.t,1,2) || ':' || it.n;
  end loop;


-- Chains
-- Total number of chains
-- How many have evaluation interval set
-- How many were created with a rule set passed in
-- Total number of steps
-- How many steps have destination set
-- Avg, mean and max number of steps per chain
-- Total number of rules
-- Avg, mean and max number of rules per chain
-- ? How many of them use simple syntax
-- ? Avg, mean and max number of steps per rule condition
-- ? Avg, mean and max number of steps per rule action

select count(*), sum(decode(evaluation_interval, null, 0, 1)) EV,
       sum(decode(user_rule_set, 'TRUE', 1, 0)) UR, 
       sum(nvl(number_of_rules,0)) NR, sum(nvl(number_of_steps,0)) NS, 
       round(avg(number_of_steps)) VS , median(number_of_steps) MS, 
       max(number_of_steps) XS into n1, n2,n3,n4,n5,n6,n7,n8 
    from dba_scheduler_chains;
    sum1  := sum1 
              || ',CCNT:' || n1 
              || ',CEVI:' || n2 
              || ',CURS:' || n3 
              || ',CNRR:' || n4 
              || ',CNRS:' || n5 
              || ',CAVS:' || n6 
              || ',CMDS:' || n7 
              || ',CMXS:' || n8;
   

select count(*) into n1 
    from dba_scheduler_chain_steps where destination is not null; 
    sum1  := sum1 
              || ',CSRD:' || n1 ;

-- Direct per step type counts. Of total how many steps point to:
--    program vs (sub)chain vs event
 for it in (
select step_type t, count(*)  n from dba_scheduler_chain_steps 
   group by step_type order by 1)
  loop  
    sum1  := sum1 || ',CSP' || substr(it.t,1,3) || ':' || it.n;
  end loop;

-- Indirect per step type counts. By following the program type how many are:
--    executable vs plsql block vs stored procedure vs (sub)chain vs event

 for it in (
select step_type t, count(*) n from 
      (select step_type from dba_scheduler_chain_steps  
            where step_type <> 'PROGRAM' 
      union all 
       select program_type from dba_scheduler_programs p,
                                dba_scheduler_chain_steps s 
          where 
           s.step_type = 'PROGRAM' and
          s.program_owner =p.owner and 
          s.program_name = p.program_name)
   group by step_type order by 1)
  loop  
    sum1  := sum1 || ',CHST' || substr(it.t,1,3) || ':' || it.n;
  end loop;
     
-- Total number of credentials
-- How many have database role set
-- How many have windows domain set

select count(*), sum(decode(database_role, null, 0, 1)),
       sum(decode(windows_domain, null, 0, 1)) 
     into n1,n2,n3
    from dba_scheduler_credentials;
    sum1  := sum1 
              || ',CRNR:' || n1  
              || ',CRDB:' || n2  
              || ',CSWD:' || n3 ;

-- Total number of destinations
-- How many database destinations (external dests = total - database dests)
-- Of the database destinations, how many specified connect info (non null tns_name)

 for it in (
select dt t, count(*) n from 
   (select decode(destination_type, 'EXTERNAL', 'DSXT', 'DSDB') dt
     from dba_scheduler_dests )
    group by dt order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

select count(*) into n1 from dba_scheduler_db_dests 
         where connect_info is null;
    sum1  := sum1 
              || ',DSDN:' || n1  ;
-- File Watcher
-- Total number of file watchers
-- How many remote file watchers (destination is non null)
-- How many have minimum file size > 0
-- How many have steady_state_duration set to a non-null value
select count(*), 
       sum(decode(steady_state_duration, null, 0,1)),
       sum(decode(destination, null, 0,1)),
       sum(decode(nvl(min_file_size,0), 0, 0, 1))
      into n1,n2,n3,n4
 from dba_scheduler_file_watchers;
    sum1  := sum1 
              || ',FWNR:' || n1  
              || ',FWSS:' || n2  
              || ',FWDS:' || n3  
              || ',FWMF' || n4  ;


-- Groups
-- Total number of groups
-- Per group type count, i.e. how many are db_dest vs external_dest vs window
-- Avg, mean and max number of members per group

 for it in (
select group_type t, count(*) n , round(avg(number_of_members)) a ,
              max(number_of_members) b,
              median(number_of_members) c
        from dba_scheduler_groups group by group_type order by 1)
  loop  
    sum1  := sum1 || ',G' || substr(it.t,1,3) || 'N:' || it.n
                        || ',G' || substr(it.t,1,3) || 'A:' || it.a
                        || ',G' || substr(it.t,1,3) || 'X:' || it.b
                        || ',G' ||substr( it.t,1,3) || 'M:' || it.c;
  end loop;


-- Calendar Syntax
-- Total number of schedules
-- Total number of non-null repeat_intervals schedules
-- Of the calendar syntax ones how many:
-- use include, exclude, or intersect
-- have a user defined frequency
-- use offset

select count(*) into n1 from dba_scheduler_schedules; 
    sum1  := sum1 
              || ',SCHNRA:' || n1;  

select count(*) into n1 from dba_scheduler_schedules
       where repeat_interval is not null;
    sum1  := sum1 
              || ',SCHNNR:' || n1;  
                             
 for it in (
select typ t, count(*) n from 
      (select decode(instr(i,'FREQ=YEARLY'),1, 'Y', 
        decode(instr(i, 'FREQ=MONTHLY'),1,'M', 
         decode(instr(i,'FREQ=WEEKLY'),1, 'W', 
          decode(instr(i,'FREQ=DAILY'),1, 'D', 
           decode(instr(i,'FREQ=HOURLY'),1, 'H', 
           decode(instr(i,'FREQ=MINUTELY'),1, 'MI', 
           decode(instr(i,'FREQ=SECONDLY'),1, 'S',
           decode(instr(i,'FREQ='),1, 'U','X')))))))) typ
      from (select replace(upper(iv), ' ', '') i from (
         select repeat_interval iv 
        from dba_scheduler_jobs 
          where schedule_type = 'CALENDAR' 
       union all select repeat_interval from dba_scheduler_schedules where
         schedule_type = 'CALENDAR')))
 group by typ order by 1)
  loop  
    sum1  := sum1 || ',CAF' || it.t || ':' || it.n;
  end loop;


select sum(decode(instr(i, 'OFFSET'), 0, 0, 1)) "Offset",  
       sum(decode(instr(i, 'SPAN'), 0, 0, 1)) "Span",  
       sum(decode(instr(i, 'BYSETPOS'), 0, 0, 1)) "Bysetp",  
       sum(decode(instr(i, 'INCLUDE'), 0, 0, 1)) "Inc",  
       sum(decode(instr(i, 'EXCLUDE'), 0, 0, 1)) "EXC",  
      sum(decode(instr(i, 'INTERSECT'), 0, 0, 1)) "ISEC"
      into n1,n2,n3,n4,n5,n6
from (select replace(upper(iv), ' ', '') i from (
   select repeat_interval iv 
  from dba_scheduler_jobs 
    where schedule_type = 'CALENDAR' 
 union all select repeat_interval from dba_scheduler_schedules where
   schedule_type = 'CALENDAR'));
    sum1  := sum1 
              || ',CAOF:' || n1  
              || ',CASC:' || n2  
              || ',CABS:' || n3  
              || ',CAIC:' || n4  
              || ',CAEX:' || n5  
              || ',CAIS:' || n6;  
 

select count (distinct owner||job_name) into n1
     from dba_scheduler_notifications;
    sum1  := sum1 
              || ',SNNR:' || n1;  

 for it in (
select event t, count(*) n
     from dba_scheduler_notifications
     group by event order by 1)
  loop  
    sum1  := sum1 || ',JN' 
               || substr(replace(it.t, 'JOB_','J'),1,5) || ':' || it.n;
  end loop;
  summary := to_clob(sum1);
END;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_EXADATA
 *  The procedure to detect usage for EXADATA storage
 ***************************************************************/
create or replace procedure DBMS_FEATURE_EXADATA
    (feature_boolean  OUT  NUMBER,
     num_cells        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
begin
  -- initialize
  num_cells := 0;
  feature_boolean := 0;
  feature_info := to_clob('EXADATA usage not detected');
  feature_usage := '';

  num_cells := sys.dbms_registry.num_of_exadata_cells();

  if num_cells > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':cells:'||num_cells;

    feature_info := to_clob(feature_usage);

  end if;

end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_IDH
 *  The procedure to detect usage for In-Database Hadoop
 ***************************************************************/
create or replace procedure DBMS_FEATURE_IDH
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
  cursor c1 is select grantee,granted_role 
                      from dba_role_privs where
                      granted_role = 'DBHADOOP' and grantee != 'SYS';
begin
  -- initialize
  aux_count := 0;
  feature_boolean := 0;
  feature_info := to_clob('In-Database Hadoop usage not detected');
  feature_usage := '';

  for i in c1
  loop
    aux_count := aux_count + 1; 
  end loop;

  if aux_count > 0
  then
    feature_boolean := 1;
    feature_usage := feature_usage||':DBHADOOP users:'||aux_count;
    feature_info := to_clob(feature_usage);
  end if;

end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_GATEWAYS
 *  The procedure to detect usage for Oracle database gateways.
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_GATEWAYS
    ( feature_boolean OUT NUMBER,
      aux_count        OUT NUMBER,
      feature_info    OUT CLOB )
AS
  TYPE GtwCursorRef is REF CURSOR;
  TYPE ResultList   is TABLE of varchar(150);
  cur GtwCursorRef;
  res ResultList; 
  hs_sql varchar(250);
  i number;
BEGIN
 /*
 We are using "execute immediate" to query HS tables
 because they are not present at the moment this
 stored procedure is created.
 */ 

  hs_sql := 'select count(*)  ' ||
            '  from   HS_FDS_CLASS '        ||
            '  where fds_class_name <> ''BITE''';
  execute immediate hs_sql into aux_count;

  feature_boolean := aux_count;

  if aux_count = 0
  then
    feature_info := 'This feature is not used.';

    return;
  end if;

  feature_info := 'Num of FDS classes:' || aux_count;

  open cur for 'select ''(ID:''  || FDS_CLASS_ID || ''' ||
               ',NAME:'' || FDS_CLASS_NAME || '',' ||
               'COMMENTS:'' || substr(FDS_CLASS_COMMENTS, 1, 110) || '')''' ||
               ' from HS_FDS_CLASS where FDS_CLASS_NAME <> ''BITE''';
  fetch cur bulk collect into res;
  close cur;

  for i in res.FIRST .. res.LAST loop
    feature_info := feature_info || ',' || res(i);
    /* make sure we don't reach the 1000 chars limit */ 
    if LENGTH(feature_info) > 850 
    then
      feature_info := feature_info || '...'; 
      return;
    end if;
  end loop;

  hs_sql := 'select count(*)  ' ||
            '  from   HS_FDS_INST '        ||
            '  where fds_class_name <> ''BITE''';
  execute immediate hs_sql into i;

  feature_info := feature_info || ',Num of FDS instances:' || i;

  if i > 0 then
    open cur for 'select ''(CLASS:''  || FDS_CLASS_ID || '',ID:'' || ' ||
                 'FDS_INST_ID || '',NAME:'' || FDS_INST_NAME || ' ||
                 ''',COMMENTS:'' || substr(FDS_INST_COMMENTS, 1, 110)' ||
                 ' || '')'' from HS_FDS_INST where FDS_CLASS_NAME <> ''BITE''';
    fetch cur bulk collect into res;
    close cur;
  
    for i in res.FIRST .. res.LAST loop
      feature_info := feature_info || ',' || res(i);
      /* make sure we don't reach the 1000 chars limit */ 
      if LENGTH(feature_info) > 850 
      then
        feature_info := feature_info || '...';  
        return;
      end if;
    end loop;
  end if;
END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES1
 *  The procedure to detect usage for Oracle database Utilities
 *  for datapump export.
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities1
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
   compression_count  NUMBER := 0;
   compressbas_count  NUMBER := 0;
   compresslow_count  NUMBER := 0;
   compressmed_count  NUMBER := 0;
   compresshgh_count  NUMBER := 0;
   encryption_count   NUMBER := 0;
   encrypt128_count   NUMBER := 0;
   encrypt192_count   NUMBER := 0;
   encrypt256_count   NUMBER := 0;
   encryptpwd_count   NUMBER := 0;
   encryptdual_count  NUMBER := 0;
   encrypttran_count  NUMBER := 0;
   parallel_count     NUMBER := 0;
   fulltts_count      NUMBER := 0;
BEGIN
  -- initialize
  feature_info      := NULL;

  -- Select stats from ku_utluse.
  begin
    select usecnt, encryptcnt, encrypt128, encrypt192, encrypt256,
           encryptpwd, encryptdual, encrypttran, compresscnt,
           compressbas, compresslow, compressmed, compresshgh, parallelcnt,
           fullttscnt
      into feature_count, encryption_count, encrypt128_count, encrypt192_count,
           encrypt256_count, encryptpwd_count, encryptdual_count,
           encrypttran_count, compression_count, compressbas_count,
           compresslow_count, compressmed_count, compresshgh_count,
           parallel_count, fulltts_count
      from sys.ku_utluse
     where utlname = 'Oracle Utility Datapump (Export)'
       and   (last_used >=
              (SELECT nvl(max(last_sample_date), sysdate-7)
                 FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_usage := feature_usage || 'Oracle Utility Datapump (Export) ' || 
                'invoked: ' || feature_count || 
                ' times, compression used: '      || compression_count ||
                ' times (BASIC algorithm used: '  || compressbas_count ||
                ' times, LOW algorithm used: '    || compresslow_count ||
                ' times, MEDIUM algorithm used: ' || compressmed_count ||
                ' times, HIGH algorithm used: '   || compresshgh_count ||
                ' times), encryption used: '      || encryption_count  ||
                ' times (AES128 algorithm used: ' || encrypt128_count  ||
                ' times, AES192 algorithm used: ' || encrypt192_count  ||
                ' times, AES256 algorithm used: ' || encrypt256_count  ||
                ' times, PASSWORD mode used: '    || encryptpwd_count  ||
                ' times, DUAL mode used: '        || encryptdual_count ||
                ' times, TRANSPARENT mode used: ' || encrypttran_count ||
                ' times), parallel used: '        || parallel_count    ||
                ' times, full transportable used: ' || fulltts_count   ||
                ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities1;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES2
 *  The procedure to detect usage for Oracle database Utilities
 *  for datapump import
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
   parallel_count     NUMBER := 0;
   fulltts_count      NUMBER := 0;
BEGIN
  -- initialize
  feature_info := NULL;

  begin
    select usecnt, parallelcnt, fullttscnt
      into feature_count, parallel_count, fulltts_count
      from sys.ku_utluse
     where utlname = 'Oracle Utility Datapump (Import)'
       and   (last_used >=
              (SELECT nvl(max(last_sample_date), sysdate-7)
                 FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_usage := feature_usage || 'Oracle Utility Datapump (Import) ' || 
                   'invoked: ' || feature_count ||
                   ' times, parallel used: ' || parallel_count ||
                   ' times, full transportable used: ' || fulltts_count ||
                   ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities2;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES3
 *  The procedure to detect usage for Oracle database Utilities
 *  for MetaData API.
 *
 *  Although this information could have been detected by a SQL
 *  statement, we'll leave this procedure for future feature
 *  tracking.
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities3
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS 
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
BEGIN
  -- initialize     
  feature_info      := NULL;
  
  begin
    select usecnt into feature_count from sys.ku_utluse
      where utlname = 'Oracle Utility Metadata API'
       and   (last_used >=
             (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities3;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES4
 *  The procedure to detect usage for Oracle database Utilities
 *  for external tables (ORACLE_DATAPUMP). 
 *  Also reports on compression/encryption usage
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities4
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
   compression_count  NUMBER := 0;
   compressbas_count  NUMBER := 0;
   compresslow_count  NUMBER := 0;
   compressmed_count  NUMBER := 0;
   compresshgh_count  NUMBER := 0;
   encryption_count   NUMBER := 0;
BEGIN
  -- initialize
  feature_info      := NULL;

  begin
    select usecnt, encryptcnt, compresscnt, compressbas, compresslow, 
           compressmed, compresshgh
      into feature_count, encryption_count, compression_count,
           compressbas_count, compresslow_count, compressmed_count,
           compresshgh_count
      from sys.ku_utluse
      where utlname = 'Oracle Utility External Table (ORACLE_DATAPUMP)'
      and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_usage := 'Oracle Utility External Table (ORACLE_DATAPUMP) invoked '   || 
                   feature_count                                                || 
                   ' times, compression used: '      || compression_count ||
                   ' times (BASIC algorithm used: '  || compressbas_count ||
                   ' times, LOW algorithm used: '    || compresslow_count ||
                   ' times, MEDIUM algorithm used: ' || compressmed_count ||
                   ' times, HIGH algorithm used: '   || compresshgh_count ||
                   ' times), encryption used: '      || encryption_count  ||
                   ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities4;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES5
 *  The procedure to detect usage for Oracle database Utilities
 *  for external tables (ORACLE_LOADER). 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities5
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
BEGIN
  -- initialize
  feature_info      := NULL;

  begin
    select usecnt
      into feature_count
      from sys.ku_utluse
      where utlname = 'Oracle Utility External Table (ORACLE_LOADER)'
      and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_usage := 'Oracle Utility External Table (ORACLE_LOADER) invoked ' ||
                   feature_count                                            || 
                   ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities5;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES6
 *  The procedure to detect usage for Oracle database Utilities
 *  for external tables (ORACLE_BIGSQL). 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities6
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000) := NULL;
   feature_count      NUMBER := 0;
BEGIN
  -- initialize
  feature_info      := NULL;

  begin
    select usecnt
      into feature_count
      from sys.ku_utluse
      where utlname = 'Oracle Utility External Table (ORACLE_BIGSQL)'
      and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));
  exception
    when others then
      null;
  end;

  feature_usage := 'Oracle Utility External Table (ORACLE_BIGSQL) invoked ' ||
                   feature_count                                            || 
                   ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities6;
/

show errors;

/********************************************************* 
* DBMS_FEATURE_AWR
* counts snapshots since last sample
* also counts DB time and DB cpu over last 7 days
*********************************************************/ 
create or replace procedure DBMS_FEATURE_AWR
     ( feature_boolean_OUT  OUT  NUMBER,
       aux_count_OUT        OUT  NUMBER,
       feature_info_OUT     OUT  CLOB)
AS
  DBFUS_LAST_SAMPLE_DATE  DATE;

  l_DBtime7day_secs   number;
  l_DBcpu7day_secs    number;

  -- cursor fetches last 7 days of AWR snapshot DB time and DB cpu
  cursor TimeModel7day_cur
  IS
WITH snap_ranges AS
(select /*+ FULL(ST) */
        SN.dbid
       ,SN.instance_number
       ,SN.startup_time
       ,ST.stat_id
       ,ST.stat_name
       ,MIN(SN.snap_id) as MIN_snap
       ,MAX(SN.snap_id) as MAX_snap
       ,MIN(CAST(begin_interval_time AS DATE)) as MIN_date
       ,MAX(CAST(end_interval_time AS DATE)) as MAX_date
   from
        dba_hist_snapshot   SN
       ,wrh$_stat_name      ST
  where 
        SN.begin_interval_time > TRUNC(SYSDATE) - 7
    and SN.end_interval_time   < TRUNC(SYSDATE)
    and SN.dbid = ST.dbid
    and ST.stat_name IN ('DB time', 'DB CPU')
  group by
        SN.dbid,SN.instance_number,SN.startup_time,ST.stat_id,ST.stat_name
)
,delta_data AS
(select
        SR.dbid
       ,SR.instance_number
       ,SR.stat_name
       ,CASE WHEN SR.startup_time BETWEEN SR.MIN_date AND SR.MAX_date
               THEN TM1.value + (TM2.value - TM1.value)
             ELSE (TM2.value - TM1.value)
        END
        as delta_time
   from
        WRH$_SYS_TIME_MODEL   TM1
       ,WRH$_SYS_TIME_MODEL   TM2
       ,snap_ranges           SR
  where
        TM1.dbid = SR.dbid
    and TM1.instance_number = SR.instance_number
    and TM1.snap_id         = SR.MIN_snap
    and TM1.stat_id         = SR.stat_id
    and TM2.dbid = SR.dbid
    and TM2.instance_number = SR.instance_number
    and TM2.snap_id         = SR.MAX_snap
    and TM2.stat_id         = SR.stat_id
)
select
       stat_name
      ,ROUND(SUM(delta_time/1000000),2) as secs
  from
       delta_data
 group by
       stat_name;

begin
  --> initialize OUT parameters
  feature_boolean_OUT := 0;
  aux_count_OUT       := null;
  feature_info_OUT    := null;

  --> initialize last sample date
  select nvl(max(last_sample_date), sysdate-7)  
    into DBFUS_LAST_SAMPLE_DATE
   from wri$_dbu_usage_sample;

  if DBFUS_LAST_SAMPLE_DATE IS NOT NULL
  then
    --> get snapshot count since last sample date
    select count(*) 
      into feature_boolean_OUT
      from wrm$_snapshot 
     where dbid = (select dbid from v$database) 
       and status = 0 
       and bitand(snap_flag, 1) = 1 
       and end_interval_time > DBFUS_LAST_SAMPLE_DATE;
  end if;

  --> fetch 7 day DB time and DB CPU from AWR
  for TimeModel7day_rec in TimeModel7day_cur
  loop
    case TimeModel7day_rec.stat_name
      when 'DB time' then l_DBtime7day_secs := TimeModel7day_rec.secs;
      when 'DB CPU'  then l_DBcpu7day_secs := TimeModel7day_rec.secs;
    end case;
  end loop;

  --> assemble feature info CLOB
  feature_info_OUT := 'DBtime:'||TO_CHAR(l_DBtime7day_secs)||
                      ',DBcpu:'||TO_CHAR(l_DBcpu7day_secs);


end;
/
show errors


/***************************************************************
 * DBMS_FEATURE_DATABASE_VAULT
 *  The procedure to detect usage for Oracle Database Vault
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_database_vault
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   dv_linkon          NUMBER;
   dvsys_uid          NUMBER;
   dvowner_uid        NUMBER;
   dvacctmgr_uid      NUMBER;
BEGIN
  -- initialize
  feature_boolean   := 0;
  aux_count         := 0;
  feature_info      := NULL;

  -- check to see if DV is linked on
  select count(*) into dv_linkon from v$option where 
     parameter = 'Oracle Database Vault' and
     value = 'TRUE';

  if (dv_linkon = 0) then
    return;
  end if;

  -- get DVSYS hard coded uid
  select count(*) into dvsys_uid from user$ where
    name = 'DVSYS' and
    user# = 1279990;

  -- get uids for hard coded roles
  select count(*) into dvowner_uid from user$ where 
     name = 'DV_OWNER' and
     user# = 1279992;
  select count(*) into dvacctmgr_uid from user$ where
     name = 'DV_ACCTMGR' and
     user# = 1279991;

  if (dvsys_uid = 0 or
      dvowner_uid = 0 or
      dvacctmgr_uid = 0) then
     return;
  end if;
  
  feature_boolean := 1;

END dbms_feature_database_vault;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_DEFERRED_SEG_CRT
 *  The procedure to detect usage for the deferred segment
 *  creation feature.
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_DEFERRED_SEG_CRT
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage        VARCHAR2(1000);
   table_count          NUMBER;
   index_count          NUMBER;
   lob_count            NUMBER;
   tabpart_count        NUMBER;
   indpart_count        NUMBER;
   lobpart_count        NUMBER;
   tabsubpart_count     NUMBER;
   indsubpart_count     NUMBER;
   lobsubpart_count     NUMBER;
   total_segments       NUMBER;
   total_def_segments   NUMBER;
BEGIN
  -- initialize
  feature_boolean    := 0;
  aux_count          := 0;
  feature_info       := NULL;
  feature_usage      := NULL;
  table_count        := 0;
  index_count        := 0;
  lob_count          := 0;
  tabpart_count      := 0;
  indpart_count      := 0;
  lobpart_count      := 0;
  tabsubpart_count   := 0;
  indsubpart_count   := 0;
  lobsubpart_count   := 0;
  total_segments     := 0;
  total_def_segments := 0;

  -- check to see if DSC parameter is turned on
  select count(*) into feature_boolean from v$system_parameter where 
     name = 'deferred_segment_creation' and value = 'TRUE';

  -- Regardless of the value of the parameter, compute the number of 
  -- objects that do not yet have segments created

  -- non-partitioned tables
--  select count(*) into table_count from dba_tables where 
--      segment_created = 'NO';

  select count(*) into table_count from 
  (  select decode(bitand(t.property, 17179869184), 17179869184, 'NO', 
                   decode(bitand(t.property, 32), 32, 'N/A', 'YES')) x 
     from tab$ t
  ) 
  where x = 'NO';

  -- non-partitioned indexes
--  select count(*) into index_count from dba_indexes where 
--      segment_created = 'NO';

  select count(*) into index_count from 
  (  select  decode(bitand(i.flags, 67108864), 67108864, 'NO','?')  x
     from ind$ i
   )
   where x = 'NO';

  -- non-partitioned lobs
--  select count(*) into lob_count from dba_lobs where 
--      segment_created = 'NO';

  select count(*) into lob_count from 
  ( select decode(bitand(l.property, 4096), 4096, 'NO','?') x
    from lob$ l
   )
   where x = 'NO';

  -- table partitions
--  select count(*) into tabpart_count from dba_tab_partitions where 
--      segment_created = 'NO';

  select count(*) into tabpart_count from
  ( select  decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES') x 
    from tabpart$ tp
  ) where x = 'NO';

  -- index partitions
--  select count(*) into indpart_count from dba_ind_partitions where 
--      segment_created = 'NO';

  select count(*) into indpart_count from
  ( select  decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES') x 
    from indpart$ ip
  ) where x = 'NO';

  -- lob partitions
--  select count(*) into lobpart_count from dba_lob_partitions where 
--      segment_created = 'NO';

    select count(*) into lobpart_count from
  ( select decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES') x
    from lobfrag$ lf where lf.fragtype$='P'
  ) where x = 'NO';

  -- table sub-partitions
--  select count(*) into tabsubpart_count from dba_tab_subpartitions where 
--      segment_created = 'NO';

  select count(*) into tabsubpart_count from
  ( select  decode(bitand(tsp.flags, 65536), 65536, 'NO', 'YES') x 
    from tabsubpart$ tsp
  ) where x = 'NO';

  -- index sub-partitions
--  select count(*) into indsubpart_count from dba_ind_subpartitions where 
--      segment_created = 'NO';

  select count(*) into indsubpart_count from
  ( select  decode(bitand(isp.flags, 65536), 65536, 'NO', 'YES') x 
    from indsubpart$ isp
  ) where x = 'NO';

  -- lob sub-partitions
--  select count(*) into lobsubpart_count from dba_lob_subpartitions where 
--      segment_created = 'NO';

  select count(*) into lobsubpart_count from
  ( select decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES') x
    from lobfrag$ lf where lf.fragtype$='S'
  ) where x = 'NO';

  -- Total segments of objects which can have deferred segment creation
--  select count(*) into total_segments from dba_segments where
--      segment_type IN ('TABLE', 
--                       'INDEX', 
--                       'LOBSEGMENT', 
--                       'LOBINDEX', 
--                       'TABLE PARTITION', 
--                       'INDEX PARTITION', 
--                       'LOB PARTITION' );

 select count(*) into total_segments from seg$ where type# in (5,6,8);
 
  -- Total # of segments whose creation is deferred
  total_def_segments := table_count + index_count + lob_count +
                        tabpart_count + indpart_count + lobpart_count +
                        tabsubpart_count + indsubpart_count + lobsubpart_count;

  feature_usage := feature_usage || 'Deferred Segment Creation ' || 
                   ' Parameter:' || feature_boolean ||
                   ' Total Deferred Segments:' || total_def_segments || 
                   ' Total Created Segments:' || total_segments   ||
                   ' Table Segments:' || table_count   ||
                   ' Index Segments:' || index_count   ||
                   ' Lob Segments:'   || lob_count   ||
                   ' Table Partition Segments:' || tabpart_count   ||
                   ' Index Partition Segments:' || indpart_count   ||
                   ' Lob Partition Segments:'   || lobpart_count   ||
                   ' Table SubPartition Segments:' || tabsubpart_count   ||
                   ' Index SubPartition Segments:' || indsubpart_count   ||
                   ' Lob SubPartition Segments:'   || lobsubpart_count;

  -- update feature_boolean if even one segment is uncreated
  if (total_def_segments > 0) then
    feature_boolean := feature_boolean+1;
  end if;

  feature_info    := to_clob(feature_usage);
  aux_count       := total_def_segments;

END dbms_feature_deferred_seg_crt;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_DBFS_CONTENT
 *  The procedure to detect usage of the Database File System 
 *  Content (DBFS Content) feature
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_dbfs_content
    (feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  table_not_found        exception;
  PRAGMA EXCEPTION_INIT(table_not_found, -942);
  num_content_stores     number;
BEGIN
  -- initialize
  feature_boolean    := 0;
  aux_count          := 0;
  num_content_stores := 0;

  -- check existence of content stores
  BEGIN
    execute immediate 'SELECT COUNT(*) FROM sys.dbfs$_stores' 
      INTO num_content_stores;
  EXCEPTION
    WHEN table_not_found THEN NULL;
  END;

  feature_boolean := num_content_stores;
  IF feature_boolean <> 0
  THEN
    feature_info := to_clob('DBFS Content feature in use. ' || 
                               num_content_stores || 
                               ' DBFS Content stores detected.');  
  ELSE
    feature_info := to_clob('DBFS Content feature not in use.');  
  END IF;
END;
/
show errors

/***************************************************************
 * DBMS_FEATURE_DBFS_SFS
 *  The procedure to detect usage of the Database File System 
 *  SecureFile Store (DBFS SFS) feature
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_dbfs_sfs
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  table_not_found        exception;
  PRAGMA EXCEPTION_INIT(table_not_found, -942);
  num_sf_stores          number;
BEGIN
  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  num_sf_stores := 0;

  -- check existence of SecureFile stores (POSIX file-systems)
  BEGIN
    execute immediate 'SELECT COUNT(*) FROM sys.dbfs_sfs$_fs' 
      INTO num_sf_stores;
  EXCEPTION
    WHEN table_not_found THEN NULL;
  END;

  feature_boolean := num_sf_stores;
  IF feature_boolean <> 0
  THEN
    feature_info := to_clob('DBFS SFS feature in use. ' || 
                              num_sf_stores || 
                              ' DBFS SF stores detected.');
  ELSE
    feature_info := to_clob('DBFS SFS feature is not in use.');
  END IF;  
END;
/
show errors

/***************************************************************
 * DBMS_FEATURE_DBFS_HS
 *  The procedure to detect usage of the Database File System 
 *  Hierarchical Store (DBFS HS) feature
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_dbfs_hs
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  table_not_found        exception;
  PRAGMA EXCEPTION_INIT(table_not_found, -942);
  num_hierarchical_stores number;
BEGIN
  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  num_hierarchical_stores := 0;

  -- check existence of content stores of HS sub-types
  BEGIN
    execute immediate 'SELECT COUNT(*)  FROM sys.dbfs_hs$_fs' 
      INTO num_hierarchical_stores;
  EXCEPTION
    WHEN table_not_found THEN NULL;
  END;

  feature_boolean := num_hierarchical_stores;
  IF feature_boolean <> 0
  THEN
    feature_info := to_clob('DBFS HS in use. ' || 
                              num_hierarchical_stores ||
                              ' DBFS hierarchical stores detected.');
  ELSE
    feature_info := to_clob('DBFS HS feature not in use.');
  END IF;
END;
/
show errors

/***************************************************************
 * DBMS_FEATURE_DMU
 *  The procedure to detect usage for DMU
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_DMU
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  v_usage_value   varchar2(4000);
  v_last_used     date;
  v_last_sampled  date;
BEGIN
  --
  -- start with 'DMU usage not detected'
  -- we do not utilize aux_count.
  --
  feature_boolean := 0;
  feature_info := to_clob('DMU usage not detected');
  aux_count := 0;
  --
  -- test if DMU was used since last sampled date
  --
  begin
    --
    -- get the date DMU was used last time
    --
    select value$ into v_usage_value
      from sys.props$
     where name = 'NLS_DMU_USAGE';
    v_last_used := to_date(substr(v_usage_value,1,instr(v_usage_value,',')-1),
                           'YYYYMMDDHH24MISS');
    --
    -- get the date sampled last time
    --
    select nvl(max(last_sample_date), sysdate-7)
      into v_last_sampled
      from wri$_dbu_usage_sample;
    --
    -- DMU usage is detected
    --
    if v_last_sampled < v_last_used then
      feature_boolean := 1;
      feature_info := to_clob(v_usage_value);
    end if;
  exception
    --
    -- DMU usage is not detected if any exception is thrown including:
    --  * NLS_DMU_USAGE not found in sys.props$
    --  * the value is not in the format of 'YYYYMMDDHH24MISS'
    --
    when others then
      null;
  end;
END DBMS_FEATURE_DMU;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_RAS
 *  The procedure to detect usage for Real Application Security
 ***************************************************************/

create or replace procedure DBMS_FEATURE_RAS
     ( feature_boolean  OUT NUMBER,
       aux_count        OUT NUMBER,
       feature_info     OUT CLOB)
AS
  row_count1              PLS_INTEGER;
  row_count2              PLS_INTEGER;
  policy_count            PLS_INTEGER;
  applied_policy_count    PLS_INTEGER;
  acl_count               PLS_INTEGER;
  ace_count               PLS_INTEGER;
  user_count              PLS_INTEGER;
  role_count              PLS_INTEGER;
  sc_count                PLS_INTEGER;
  privilege_count         PLS_INTEGER;
  session_count           PLS_INTEGER;
  external_session_count  PLS_INTEGER;
  regular_session_count   PLS_INTEGER;
  dispatcher_used         VARCHAR2(5);
  midtier_cache_used      VARCHAR2(5);
  max_seeded_id           NUMBER := 2147493647;
begin
 feature_boolean := 0;
 feature_info := to_clob('Real Application Security usage not detected');
 aux_count := 0;

 begin
   
   /* Check if Real Application Security objects are created. */
   select count(*) into row_count1 from sys.xs$obj where id > max_seeded_id and BITAND(flags,1) = 0;
   if row_count1 > 0 then
     feature_boolean := 1;
     
     /* Find the number of XDS policies. */
     select count(*) into policy_count from sys.xs$dsec;
     
     if policy_count > 0 then
     
       /* Find the number of applied XDS policies. */
       select count(*) into applied_policy_count from sys.DBA_XS_APPLIED_POLICIES p 
              where p.status = 'ENABLED';
     end if;

     /* Find the number of ACLs. */
     select count(*) into acl_count from sys.xs$acl where acl# > max_seeded_id;
     
     /* Find the number of ACEs. */
     select count(*) into ace_count from sys.xs$ace where acl# > max_seeded_id;
     
     /* Find the number of users. */
     select count(*) into user_count from sys.xs$prin p where p.type = 0 and prin# > max_seeded_id;
     
     /* Find the number of roles. */
     select count(*) into role_count from sys.xs$prin p where p.type <> 0 and prin# > max_seeded_id;

     /* Find number of security classes. */
     select count(*) into sc_count from sys.xs$seccls where sc# > max_seeded_id;

     /* Find number of privileges. */
     select count(*) into privilege_count from sys.xs$priv where priv# > max_seeded_id; 

     /* Find the number of sessions. */
     select count(*) into session_count from sys.rxs$sessions;
     
     /* Find the number of session created with external user. */
     select count(*) into external_session_count from sys.rxs$sessions r 
            where BITAND(r.flag,4) = 4;
     
     /* Find the number of session created with regular XS user. */
     regular_session_count := session_count - external_session_count;
    
     /* Find if dispatcher is being used. */
     select count(*) into row_count1 from sys.dba_xs_role_grants where granted_role = 'XSSESSIONADMIN';
     select count(*) into row_count2 from sys.dba_role_privs where granted_role = 'XS_SESSION_ADMIN' and grantee <> 'SYS';
     if ((row_count1 > 0) OR (row_count2 > 0)) then
       dispatcher_used := 'TRUE';
     else
       dispatcher_used := 'FALSE';
     end if;

     /* Find if midtier cache is used. */
     select count(*) into row_count1 from sys.dba_xs_role_grants where granted_role = 'XSCACHEADMIN';
     select count(*) into row_count2 from sys.dba_role_privs where granted_role = 'XS_CACHE_ADMIN' and grantee <> 'SYS';
     if ((row_count2 > 0) OR (row_count2 > 0)) then
       midtier_cache_used := 'TRUE';
     else
       midtier_cache_used := 'FALSE';
     end if;

     feature_info := to_clob('Number of policies: '||policy_count||
                            ' Number of policies applied: '||applied_policy_count||
                ' Number of ACLs created: '||acl_count||
                ' Number of ACEs: '||ace_count||
                ' Number of users created: '||user_count||
                ' Number of roles created: '||role_count||
                ' Number of security classes created: '||sc_count||
                ' Number of privileges created: '||privilege_count||
                ' Number of sessions created: '||session_count||
                ' Number of external sessions created: '||external_session_count||
                ' Number of regular sessions created: '||regular_session_count||
                ' Dispatcher used: '||dispatcher_used||
                ' Mid-tier cache used: '||midtier_cache_used);
   end if;
 exception
   when others then
     null;
 end;
END DBMS_FEATURE_RAS;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_ONLINE_REDEF
 * The procedure to detect usage for Online Redefinition
 ****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ONLINE_REDEF
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
 num_usage         number;                  
 num_redef         number;                              -- total number of redefinition
 num_finish      number;                       -- total number of finished redefinition
 num_abort      number;                         -- total number of aborted redefinition
 num_pk       number;                          -- total number of PK-based redefinition
 num_rowid        number;                   -- total number of rowid-based redefinition
 num_part      number;                  -- total number of partition-based redefinition
 num_batch      number;                           -- total number of batch redefinition
 num_auto_vpd      number;                -- total number of auto copy VPD redefinition
 num_manual_vpd        number;          -- total number of manual copy VPD redefinition
 last_refresh_date     date;                                  -- last redefinition date
 feature_usage  varchar2(1000);

BEGIN
  -- initialize
  num_usage  := 0;      
  num_redef  := 0;                                   
  num_finish := 0;
  num_abort := 0;
  num_pk := 0;
  num_rowid := 0;
  num_part  := 0;
  num_batch := 0;
  num_auto_vpd := 0;
  num_manual_vpd  := 0;
  num_pk := 0;
  
  feature_boolean := 0;
  aux_count := 0;

  /* get total number of redefinition */
  execute immediate 'select count(*) from sys.redef$'
  into num_usage;

  if (num_usage > 0)
  then
   /* get number of finished redefinition */
    execute immediate 'select redef# from sys.redef_track$'
    into num_redef;

    /* get number of finished redefinition */
    execute immediate 'select finish_redef# from sys.redef_track$'
    into num_finish;

    /* get number of aborted redefinition */
    execute immediate 'select abort_redef# from sys.redef_track$'
    into num_abort;

    /* get number of PK-based redefinition */
    execute immediate 'select pk_redef# from sys.redef_track$'
    into num_pk;

    /* get number of rowid-based redefinition */
    execute immediate 'select rowid_redef#  from sys.redef_track$'
    into num_rowid;

    /* get number of partition redefinition */
    execute immediate 'select part_redef# from sys.redef_track$'
    into num_part;

    /* get number of batch redefinition */
    execute immediate 'select batch_redef# from sys.redef_track$'
    into num_batch;

    /* get number of auto copy VPD  redefinition */
    execute immediate 'select vpd_auto# from sys.redef_track$'
    into num_auto_vpd;

    /* get number of manual copy VPD redefinition */
    execute immediate 'select vpd_manual# from sys.redef_track$'
    into num_manual_vpd;

    /* get last refresh date */
    execute immediate 'select last_redef_time from sys.redef_track$'
    into last_refresh_date;

    feature_boolean := 1;

    feature_usage := 'total number of redefinition:' || to_char(num_redef) ||
          ',' || ' num of finished redefinition:' || to_char(num_finish) ||
          ',' || ' num of abort redefinition:' || to_char(num_abort) ||
          ',' || ' num of PK-based redefinition:' || to_char(num_pk) ||
          ',' || ' num of rowid-based redefinition:' || to_char(num_rowid) ||
          ',' || ' num of partition-based redefinition:' || to_char(num_part) ||
          ',' || ' num of batch redefinition:' || to_char(num_batch) ||
          ',' || ' num of automatic copy VPD redefinition:' || to_char(num_auto_vpd) ||
          ',' || ' num of manual copy VPD redefinition:' || to_char(num_manual_vpd) ||
          ',' || ' last redefiniton date:' ||  to_char(last_refresh_date, 'Month DD, YYYY') ||
          '.';

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('Online Redefinition usage not detected!');
  end if;
  exception
    when others then
      null;
end DBMS_FEATURE_ONLINE_REDEF;
/
show errors;

  -- ******************************************************** 
  --   TEST_PROC_1
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_1
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 0;
    aux_count := 12;
    feature_info := NULL;
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_2
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 1;
    aux_count := 33;
    feature_info := 'Extra Feature Information for TEST_PROC_2';    
end;
/


-- ******************************************************** 
--   TEST_PROC_3
-- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_3
  ( current_value  OUT  NUMBER) 
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly.
     */
    current_value := 101;    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_4
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_4
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* raise an application error to make sure the error is being
     * handled correctly 
     */     
    raise_application_error(-20020, 'Error for Test Proc 4 ');
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_5
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_5
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* What happens if values are not set? */     
    feature_info := 'TEST PROC 5';
    
end;
/

/*******************************************************************
 * DBMS_FEATURE_AUDIT_OPTIONS
 *  The procedure to detect usage for Oracle Database Standard audit
 *******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_audit_options
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   uniaud_linkon        NUMBER;
   system_audit_options NUMBER;
   object_audit_options NUMBER;
   audit_trail          VARCHAR2(100);
   feature_usage        VARCHAR2(1000);
BEGIN

  -- Initialize
  feature_boolean       := 0;
  aux_count             := 0;
  feature_info          := NULL;
  system_audit_options  := 0;
  object_audit_options  := 0;

  -- Check if 'uniaud_on' is linked
  select count(*) into uniaud_linkon from v$option
    where parameter like '%Unified Auditing%' and value = 'TRUE';

  -- Get the value of 'audit_trail' parameter
  select UPPER(value) into audit_trail from v$parameter 
    where UPPER(name) = 'AUDIT_TRAIL';

  -- If Unified auditing is ON, then Audit options(OLD) are always disabled
  if ((uniaud_linkon = 0) AND (audit_trail != 'NONE')) then
    feature_boolean := 1;
  end if;

  select count(*) into system_audit_options from audit$;
  select count(*) into object_audit_options from dba_obj_audit_opts;

  feature_usage := 'AUDIT_TRAIL=' || audit_trail || '; ' ||
   'Number of system audit options=' || to_char(system_audit_options) || '; '||
   'Number of object audit options=' || to_char(object_audit_options);
  feature_info := to_clob(feature_usage);

END dbms_feature_audit_options;
/
show errors;

/****************************************************************************
 * DBMS_FEATURE_FGA_AUDIT
 *  The procedure to detect usage for Oracle Database Fine Grained Audit(FGA)
 ****************************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_fga_audit
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage           VARCHAR2(1000);
   fga_policies_total      NUMBER;
   fga_policies_enabled    NUMBER;
   fga_policies_column     NUMBER;
   fga_policies_condition  NUMBER;
   fga_policies_handler    NUMBER;
   fga_policies_DB_trail   NUMBER;
   fga_policies_XML_trail  NUMBER;
BEGIN

  -- Initialize
  feature_boolean         := 0;
  aux_count               := 0;
  feature_info            := NULL;
  fga_policies_total      := 0;
  fga_policies_enabled    := 0;
  fga_policies_column     := 0;
  fga_policies_condition  := 0;
  fga_policies_handler    := 0;
  fga_policies_DB_trail   := 0;
  fga_policies_XML_trail  := 0;

  -- Get FGA policy details from the database
  FOR item IN (SELECT enabled, policy_text, policy_column, pf_function,
                      audit_trail FROM DBA_AUDIT_POLICIES)
  LOOP
    IF (item.enabled = 'YES') THEN
      fga_policies_enabled := fga_policies_enabled + 1;
    END IF;

    IF (item.policy_text IS NOT NULL) THEN
      fga_policies_condition := fga_policies_condition + 1;
    END IF;

    IF (item.policy_column IS NOT NULL) THEN
      fga_policies_column := fga_policies_column + 1;
    END IF;

    IF (item.pf_function IS NOT NULL) THEN
      fga_policies_handler := fga_policies_handler + 1;
    END IF;

    IF (item.audit_trail LIKE 'DB%') THEN
      fga_policies_DB_trail := fga_policies_DB_trail + 1;
    ELSE 
      fga_policies_XML_trail := fga_policies_XML_trail + 1;
    END IF;
    
    fga_policies_total := fga_policies_total + 1;
  END LOOP;

  -- If atleast a single FGA policy is enabled, then FGA feature is enabled
  if (fga_policies_enabled > 0) then
    feature_boolean := 1;
  end if;

  feature_usage := 'Number of FGA policies=' ||
                       to_char(fga_policies_total) || '; ' ||
                   'Number of Enabled FGA policies=' || 
                       to_char(fga_policies_enabled) || '; ' ||
                   'Number of FGA policies with audit_condition=' || 
                       to_char(fga_policies_condition) || '; ' ||
                   'Number of FGA policies with column-level audit=' ||
                       to_char(fga_policies_column) || '; ' ||
                   'Number of FGA policies with handler=' ||
                       to_char(fga_policies_handler) || '; ' ||
                   'Number of FGA policies with DB audit_trail=' ||
                       to_char(fga_policies_DB_trail) || '; ' ||
                   'Number of FGA policies with XML audit_trail=' ||
                       to_char(fga_policies_XML_trail);

  feature_info := to_clob(feature_usage);

END dbms_feature_fga_audit;
/
show errors;

/*******************************************************************
 * DBMS_FEATURE_UNIFIED_AUDIT
 *  The procedure to detect usage for Oracle Database Unified Audit
 *******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_unified_audit
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage         VARCHAR2(1000);
   uniaud_linkon         NUMBER;
   unified_policies      NUMBER;
   unified_policies_enb  NUMBER;
   unified_policies_cond NUMBER;
   unified_policies_dv   NUMBER;
   unified_policies_ols  NUMBER;
   unified_policies_xs   NUMBER;
   unified_policies_dp   NUMBER;
   unified_contexts      NUMBER;
BEGIN

  -- Initialize
  feature_boolean       := 0;
  aux_count             := 0;
  feature_info          := NULL;
  unified_policies      := 0;
  unified_policies_enb  := 0;
  unified_policies_cond := 0;
  unified_policies_dv   := 0;
  unified_policies_ols  := 0;
  unified_policies_xs   := 0;
  unified_policies_dp   := 0;
  unified_contexts      := 0;

  -- Check if 'uniaud_on' is linked
  select count(*) into uniaud_linkon from v$option
    where parameter like '%Unified Auditing%' and value = 'TRUE';

  -- Get number of Unified Audit policies created in the database
  select count(*) into unified_policies from aud_policy$;

  -- Get number of Unified Audit policies enabled in the database
  select count(distinct policy#) into unified_policies_enb from audit_ng$;

  -- Get number of Unified Audit policies with condition 
  select count(*) into unified_policies_cond from aud_policy$ 
    where condition is NOT NULL;

  -- Get number of Unified Audit policies for each componenet
  FOR item IN (SELECT audit_option_type, count(distinct policy_name) pol_cnt
               FROM AUDIT_UNIFIED_POLICIES group by audit_option_type)
  LOOP
    IF (item.audit_option_type LIKE 'DV%') THEN
      unified_policies_dv := item.pol_cnt;
    ELSIF (item.audit_option_type LIKE 'OLS%') THEN
      unified_policies_ols := item.pol_cnt;
    ELSIF (item.audit_option_type LIKE 'XS%') THEN
      unified_policies_xs := item.pol_cnt;
    ELSIF (item.audit_option_type LIKE 'DATAPUMP%') THEN
      unified_policies_dp := item.pol_cnt;
    END IF;
  END LOOP;

  -- Get number of contexts enabled for audit
  select count(*) into unified_contexts from aud_context$;

  -- If 'uniaud_on' is linked, then Unified audit feature is enabled. 
  -- Else if atleast a single Unified audit policy is enabled,
  --   then Unified audit feature is enabled.
  if ((uniaud_linkon > 0) OR (unified_policies_enb > 0)) then
    feature_boolean := 1;
  end if;

  feature_usage := 'Number of Unified Audit policies=' ||
                   to_char(unified_policies) || '; ' ||
                   'Number of Enabled Unified Audit policies=' || 
                   to_char(unified_policies_enb) || '; ' ||
                   'Number of Unified Audit policies with condition=' || 
                   to_char(unified_policies_cond) || '; ' ||
                   'Number of Unified Audit policies on DV=' || 
                   to_char(unified_policies_dv) || '; ' ||
                   'Number of Unified Audit policies on OLS=' || 
                   to_char(unified_policies_ols) || '; ' ||
                   'Number of Unified Audit policies on XS=' || 
                   to_char(unified_policies_xs) || '; ' ||
                   'Number of Unified Audit policies on DATAPUMP=' || 
                   to_char(unified_policies_dp) || '; ' ||
                   'Number of Enabled Unified Audit Contexts=' || 
                   to_char(unified_contexts);
  feature_info := to_clob(feature_usage);

END dbms_feature_unified_audit;
/
show errors;

/*******************************************************************
 * DBMS_PDB_NUM
 *  The procedure to check if Oracle Multitenant is used and count
 *  user-created pluggable databases
 *******************************************************************/

CREATE OR REPLACE PROCEDURE dbms_pdb_num
     ( feature_boolean  OUT NUMBER,
       aux_count        OUT NUMBER,
       feature_info     OUT CLOB)
AS
begin
  feature_boolean := 0;
  aux_count := 0;
  feature_info := NULL;

  select count(*) into feature_boolean from v$database where cdb = 'YES';
  if (feature_boolean = 1) then
    select count(*) into aux_count from v$pdbs where con_id > 2;
  end if;

end dbms_pdb_num;
/
show errors;


/*******************************************************************
 * DBMS_FEATURE_LABEL_SECURITY
 *  The procedure to detect usage for Oracle Label Security
 *******************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_label_security
     ( feature_boolean  OUT NUMBER,
       aux_count        OUT NUMBER,
       feature_info     OUT CLOB)
AS
begin
  -- execute immediate as lbacsys is not installed yet
  execute immediate 'begin lbacsys.feature_usage(:1,:2,:3); end;'
                     USING OUT feature_boolean, 
                           OUT aux_count,
                           OUT feature_info;

  EXCEPTION WHEN OTHERS THEN
    null;
 
end dbms_feature_label_security;
/
show errors;

/*******************************************************************
 * DBMS_FEATURE_PRIV_CAPTURE
 *  The procedure to detect usage for privilege capture feature
 *******************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_priv_capture
     ( feature_boolean  OUT NUMBER,
       aux_count        OUT NUMBER,
       feature_info     OUT CLOB)
AS
  cursor priv_capture is select id#, type,
                         CASE type 
                           WHEN 1 THEN 'DATABASE'
                           WHEN 2 THEN 'ROLE'
                           WHEN 3 THEN 'CONTEXT'
                           WHEN 4 THEN 'ROLE_AND_CONTEXT'
                         END l_type
                         from sys.priv_capture$ where id# >= 5000;
  l_capture   priv_capture%ROWTYPE;
  feature_usage varchar2(1000) := NULL;
  l_prefix      varchar2(100) := NULL;
  l_count       number := 0;
begin
  -- initialize output parameters
  aux_count := 0;
  feature_boolean := 0;
  feature_info := NULL;
  
  -- total number of captures
  select count(*) into l_count from sys.priv_capture$ where id# >= 5000;

  if (l_count > 0) then
    -- feature is used if a capture is created
    feature_boolean := 1;
    aux_count := l_count;

    l_prefix := 'Number of privilege captures=' || to_char(l_count) 
                || Chr(13) || Chr(10) || '(';
   
    -- Information for each capture
    for l_capture in priv_capture loop
        
        feature_usage := feature_usage || 'Type=' || l_capture.l_type;

        select count(*) into l_count from sys.capture_run_log$ 
        where capture = l_capture.id#;

        feature_usage := feature_usage || ' Number of Runs=' || 
                         to_char(l_count) || Chr(13) || Chr(10);
    end loop;
    feature_info := to_clob(l_prefix || feature_usage || ')');

  end if; 
end dbms_feature_priv_capture;
/
show errors;

/*******************************************************************
 * DBMS_FEATURE_TSDP
 *  The procedure to detect usage for TSDP
 *******************************************************************/

create or replace procedure DBMS_FEATURE_TSDP
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_sensitive_cols    number;
    num_policies          number;
    num_columns_protected number;
    num_sensitive_types   number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_sensitive_cols := 0;
    num_policies := 0;
    num_columns_protected := 0;
    num_sensitive_types := 0;

    -- check if sensitive columns have been identified.
    execute immediate 'select count(*) from DBA_SENSITIVE_DATA'
        into num_sensitive_cols;

    -- check if Sensitive Column Types have been created.
    execute immediate 'select count(*) from DBA_SENSITIVE_COLUMN_TYPES'
            into num_sensitive_types;

    -- check if TSDP policies have been created.
    execute immediate 'select count(*) from DBA_TSDP_POLICY_FEATURE'
            into num_policies;

    -- check for protected sensitive columns.
    execute immediate 'select count(*) from DBA_TSDP_POLICY_PROTECTION'
            into num_columns_protected;

    -- Feature_usage information will contain:
    -- number of Sensitive Column Types created,
    -- number of TSDP policies created, and 
    -- number of Sensitive Columns protected using TSDP. 
    -- Note: Number of Sensitive Columns identified is not shown here
    --       as it is a sensitive metric.
    feature_usage :=
                'Number of Sensitive Column Types created: ' ||
                 to_char(num_sensitive_types) ||
        ', ' || 'Number of TSDP policies created: ' ||
                 to_char(num_policies) ||
        ', ' || 'Number of Sensitive Columns protected using TSDP: ' ||
                 to_char(num_columns_protected)
        ;

    -- In order to conclude that TSDP is in use, we check if
    --   atleast one Sensitive Column Type is created,
    --   OR if atleast one column identified as sensitive,
    --   OR atleast two TSDP policies exist. (Note that
    --      REDACT_AUDIT policy is created by default,
    --      and this policy cannot be dropped).
    if ((num_sensitive_cols > 0) or (num_sensitive_types > 0)
        or (num_policies > 1))
     then
       feature_boolean := 1;
       feature_info := to_clob(feature_usage);

    else
       feature_info := to_clob('Transparent Sensitive Data Protection ' ||
                               'feature not used');

    end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_SEG_MAIN_ONL_COMP
 *   Segment Maintenance Online Compress
 *   This procedure tracks the segments compressed as a result 
 *   of an online partition maintenance operation like MOVE.
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SEG_MAIN_ONL_COMP
  (isAnyFragCompressed OUT  NUMBER,
   numFragsCompressed  OUT  NUMBER,
   fragObjNumList      OUT  CLOB)
AS
  partnFragsCompressed     NUMBER;
  subpartnFragsCompressed  NUMBER;
  fragObjNumListStr        VARCHAR2(1000);

  -- select from tabpart$
  cursor tp_cursor is      select tp.obj# from sys.tabpart$ tp
                           where bitand(tp.flags, 33554432) = 33554432;
  
  -- select from tabsubpart$
  cursor tsp_cursor is     select tsp.obj# from sys.tabsubpart$ tsp 
                           where bitand(tsp.flags, 33554432) = 33554432;
BEGIN
  -- initialize
  isAnyFragCompressed := 0;
  numFragsCompressed  := 0;
  fragObjNumListStr   := NULL;

  -- count partitions compressed through an online PMOP
  select count(*) into partnFragsCompressed
  from sys.tabpart$ where bitand(flags, 33554432) = 33554432;

  -- count subpartitions compressed through an online PMOP
  select count(*) into subpartnFragsCompressed 
  from sys.tabsubpart$ where bitand(flags, 33554432) = 33554432;

  -- loop through tabpart$
  if (partnFragsCompressed > 0) then
    isAnyFragCompressed := 1;
    fragObjNumListStr   := fragObjNumListStr || 'Partition Obj# list: ';
    for ri in tp_cursor 
    loop
      fragObjNumListStr := fragObjNumListStr || ri.obj# || ':';
    end loop;
    fragObjNumListStr := fragObjNumListStr || chr(10);
  end if;
  
  -- loop through subpart$
  if (subpartnFragsCompressed > 0) then
    isAnyFragCompressed := 1;
    fragObjNumListStr   := fragObjNumListStr || 'Subpartition Obj# list: ';
    for ri in tsp_cursor 
    loop
      fragObjNumListStr := fragObjNumListStr || ri.obj# || ':';
    end loop;
  end if;

  -- populate the variables to be returned
  if (partnFragsCompressed + subpartnFragsCompressed > 0) then
    isAnyFragCompressed := 1;
    numFragsCompressed  := partnFragsCompressed + subpartnFragsCompressed;
    fragObjNumList      := to_clob(fragObjNumListStr);
  end if;

END DBMS_FEATURE_SEG_MAIN_ONL_COMP;
/

show errors;


/******************************************************************************
 * DBMS_FEATURE_EMX
 *  The procedure to detect usage for EM Express
 *****************************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_emx
     ( feature_boolean  OUT NUMBER,
       aux_count        OUT NUMBER,
       feature_info     OUT CLOB)
AS
  -- total em express usage count since last feature usage collection
  l_count_total_delta number := 0;

  -- total em express usage count since the first time it's used
  l_count_total number := 0;

  -- feature_info clob
  l_detailed_usage_clob CLOB := NULL;

  -- feature_info xml
  l_detailed_usage_xml xmltype := NULL;

  -- new xml to add to feature_info xml for one report
  l_report_usage_xml xmltype   := NULL;

  -- xpath key to find out if report already has entry in feature_info xml
  l_report_usage_key varchar2(32767);

  -- report name
  l_report_name varchar2(32767) := NULL;

  -- statistics of existing entry in feature_info xml for report
  l_old_report_count         number;
  l_old_report_avg_time      number;
  l_old_report_avg_cputime   number;

  -- new statistics to put into feature_info xml for report
  l_new_report_count         number:= NULL;
  l_new_report_total_time    number:= NULL;
  l_new_report_avg_time      number:= NULL;
  l_new_report_total_cputime number:= NULL;
  l_new_report_avg_cputime   number:= NULL;

  -- last db feature usage sample collection time
  l_last_collection_time date;

  -- Query to select the delta since last feature usage collection
  -- from internal fixed table X$KEXSVFU.
  -- Note if count for the report is 0, but last request timestamp is greater
  -- than or equal to the latest sample date of db feature usage framework,
  -- then this report must have been used at least once, therefore decoding
  -- count from 0 to 1.
  -- If in CDB, returned result is for this container only
  cursor emx_fu_cursor(p_last_collection_time date) is      
    select report, 
           sum(total_count) as total_count, 
           sum(total_elapsed_time) as total_elapsed_time, 
           sum(total_cpu_time) as total_cpu_time 
      from table(gv$(cursor(
             select report_kexsvfu       as report, 
                    decode(count_kexsvfu, 0, 1, count_kexsvfu) as total_count, 
                    elapsed_time_kexsvfu as total_elapsed_time,
                    cpu_time_kexsvfu     as total_cpu_time
               from X$KEXSVFU
              where last_req_time_kexsvfu >= p_last_collection_time
                and con_id = sys_context('userenv', 'con_id'))))
    group by report;

begin

  -- initialize output parameters
  feature_boolean := 0;
  aux_count := 0;
  feature_info := NULL;

  -- get total em express usage count from aux_count column and
  -- detailed em express usage info from feature_info column before 
  -- last usage collection
  begin
    select nvl(aux_count, 0), feature_info
      into l_count_total, l_detailed_usage_clob
      from dba_feature_usage_statistics
     where name = 'EM Express';
  exception
    when NO_DATA_FOUND then
      l_count_total := 0;
      l_detailed_usage_clob := NULL;
  end;

  -- if no feature_info xml exists, construct a brand new one
  if (l_detailed_usage_clob is NULL) then
    l_detailed_usage_xml := 
      xmltype('<emx_usage time_unit="us"></emx_usage>');
  -- otherwise update the existing one
  else
    l_detailed_usage_xml := xmltype(l_detailed_usage_clob);
  end if;

  -- get last db feature usage collection time
  select nvl(max(last_sample_date), sysdate-7)
    into l_last_collection_time
    from dba_feature_usage_statistics;

  -- get report usage info since last feature usage collection
  for rc in emx_fu_cursor(l_last_collection_time)
  loop
    l_report_name              := rc.report;
    l_new_report_count         := rc.total_count;
    l_new_report_total_time    := rc.total_elapsed_time;
    l_new_report_total_cputime := rc.total_cpu_time;

    -- update total count for all EM Express reports since last usage
    -- collection, this will indicate if EM Express has been used since last
    -- collection, and be added to aux_count column
    l_count_total_delta := l_count_total_delta + l_new_report_count;

    --
    -- update the feature_info detail xml
    --

    -- build the xpath key to find out if the report already exists
    -- in the xml. The key looks like: 
    --   '//report_usage[@report="<report_id>"]'
    l_report_usage_key := '//report_usage[' ||
                          '@report="' || l_report_name || '"' ||
                          ']';

    -- find out if an xml element for this report already exists in the xml
    if (l_detailed_usage_xml.existsNode(l_report_usage_key) > 0) then

      -- get the old count for this report 
      -- if any of the attributes is not found for this report, 
      -- reset it to 0
      select NVL(EXTRACTVALUE(l_detailed_usage_xml, 
                              l_report_usage_key || '//@count'), 0),
             NVL(EXTRACTVALUE(l_detailed_usage_xml, 
                              l_report_usage_key || '//@avg_elapsed_time'), 0),
             NVL(EXTRACTVALUE(l_detailed_usage_xml, 
                              l_report_usage_key || '//@avg_cpu_time'), 0)
        into l_old_report_count, 
             l_old_report_avg_time,
             l_old_report_avg_cputime
        from dual;

      -- update the statistics, increment count and total time with stats 
      -- since the last usage collection
      l_new_report_count 
        := l_old_report_count + l_new_report_count; 

      -- recalculate average time
      l_new_report_avg_time 
        := round((l_old_report_avg_time * l_old_report_count 
                  + l_new_report_total_time) / l_new_report_count, 1);

      l_new_report_avg_cputime 
        := round((l_old_report_avg_cputime * l_old_report_count
                 + l_new_report_total_cputime) / l_new_report_count, 1);

      -- update the xml using the new stats
      select updateXML(l_detailed_usage_xml, 
                       l_report_usage_key || '//@count', 
                       l_new_report_count,
                       l_report_usage_key || '//@avg_elapsed_time', 
                       l_new_report_avg_time,
                       l_report_usage_key || '//@avg_cpu_time',
                       l_new_report_avg_cputime)
        into l_detailed_usage_xml
        from dual;

    -- if no xml element is found for this report, construct a new one
    else
      -- calculate average time
      l_new_report_avg_time    
        := round(l_new_report_total_time / l_new_report_count, 1);
      l_new_report_avg_cputime 
        := round(l_new_report_total_cputime / l_new_report_count, 1);

      -- construct new xml element for this report usage
      select xmlelement("report_usage", 
                        xmlattributes(
                          l_report_name              as "report",
                          l_new_report_count         as "count",
                          l_new_report_avg_time      as "avg_elapsed_time",
                          l_new_report_avg_cputime   as "avg_cpu_time"))
        into l_report_usage_xml
        from dual;

      -- append this report usage to the main emx feature usage xml
      l_detailed_usage_xml := 
        l_detailed_usage_xml.appendChildxml('/*', l_report_usage_xml);

    end if;

  end loop;

  -- update feature_boolean to indicate if em express has been used or not
  -- by setting it to the total count since last usage collection
  feature_boolean := l_count_total_delta;

  -- update total count in aux_count column
  aux_count := l_count_total + l_count_total_delta;

  -- update feature_info for the new collection
  feature_info := l_detailed_usage_xml.getClobVal();

end dbms_feature_emx;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IMA
 * The procedure to detect In-Memory Aggregation usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IMA(
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
AS
    feature_usage               varchar2(1000);
    num_kv                      number;
    avg_num_dim                 number;
    max_num_dim                 number;
    num_fact                    number;

BEGIN
    feature_boolean             := 0;
    aux_count                   := 0;

    -- find the total number of recent key vectors 
    execute immediate 'select count(*) from gv$key_vector 
                       where state = ''FINISHED'''
      into num_kv;

    -- average number of recent key vectors per query, overall maximum and
    -- total number of unique fact tables referenced (does not include 
    -- complex facts)
    execute immediate 'select round(avg(key_vector_count),2),
                              max(key_vector_count),
                              count(distinct fact_name)
                       from (select fact_name, count(*) key_vector_count
                             from gv$key_vector
                             where state = ''FINISHED''
                             group by sql_id, sql_exec_id, fact_name)'
      into avg_num_dim, max_num_dim, num_fact;

    --Summary
    feature_usage :=
        ' In-Memory Aggregation Feature Usage: ' ||
                'Total Number of Key Vectors: ' ||
                  to_char(num_kv) ||
         ', ' || 'Maximum Number of Key Vectors for a Query: ' ||
                  to_char(max_num_dim) ||
        ', ' || 'Average Number of Key Vectors per Query: ' ||
                  to_char(avg_num_dim) ||
        ', ' || 'Total Number of Unique Fact Tables: ' ||
                  to_char(num_fact);

     if (num_kv > 0) then
      feature_boolean := 1;
      feature_info := to_clob(feature_usage);
    else
      feature_boolean := 0;
      feature_info := to_clob('In-Memory Aggregation Not Detected');
    end if;
END DBMS_FEATURE_IMA;
/
show errors;

/****************************************************************
 * DBMS_FEATURE_IMFS
 * The procedure to detect In-Memory FastStart usage
 ****************************************************************/
create or replace procedure DBMS_FEATURE_IMFS (
    feature_boolean OUT NUMBER,
    aux_count       OUT NUMBER,
    feature_info    OUT CLOB)
as
  val       varchar2(4096);     -- FS status
  tbs       varchar2(4096);     -- FS tablespace name
  spspace   number;             -- space used by savepoints
  spcnttot  number;             -- total number of savepoints processed by FS
BEGIN
  select value into val from SYSDBIMFS_METADATA$ where key='STATUS';
  if( val = 'ENABLE' ) then
    feature_boolean := 1;
    
    -- Get FS assigned tbs
    select name into tbs
    from 
      v$tablespace vtbs, 
      (select to_number(value) as tsn from SYSDBIMFS_METADATA$ where key='TSN') t2
    where t2.tsn = vtbs.ts#;

    -- Get the number of CU persisted in FS.
    select count(*) into aux_count from SYS.SYSDBIMFS$;

    -- Get FS savepoint space usage.  Table is not created until feature is enabled
    -- so we need to do exec immediate.
    execute immediate 'select sum(dbms_lob.getlength(data)) from SYSDBIMFSDATA$' 
      into spspace;

    -- Get total number of CU cached in FS
    select max(cuid) into spcnttot from sys.sysdbimfs$;

    feature_info := to_clob('In-Memory FastStart enabled on ' || tbs || 
                            ': Current Number of Savepoints in FastStart Area: ' || aux_count ||
                            ', Current Space Usage: ' || spspace ||
                            ', Total Number of Savepoints in FastStart Area: ' || spcnttot);
  else
    feature_boolean := 0;
    aux_count := 0;
    feature_info := to_clob('In-Memory FastStart Not Used');
  end if;
END DBMS_FEATURE_IMFS;
/
show errors;

/****************************************************************
 * DBMS_HWM_SHARDS
 * Procedure to get current number of deployed shards in catalog
 ****************************************************************/
create or replace procedure DBMS_HWM_SHARDS
  (current_value OUT NUMBER) 
AS
    loc_count  number;
    loc_shtype number;
    loc_repl   number;
BEGIN
    current_value := 0;

    execute immediate 'SELECT COUNT(*) 
                       FROM GSMADMIN_INTERNAL.CLOUD 
                       WHERE database_flags = ''C'''
      into loc_count;

    -- if not a catalog or not initialized, then no shards yet
    IF loc_count = 0 THEN
      RETURN;
    END IF;

    execute immediate 'SELECT SHARDING_TYPE, REPLICATION_TYPE 
                       FROM GSMADMIN_INTERNAL.CLOUD'
      into loc_shtype, loc_repl;

    -- if not a sharded catalog, then no shards possible
    IF loc_shtype = 0 THEN
      RETURN;
    END IF;

    IF loc_repl = 0 THEN
      -- DataGuard
      execute immediate 'SELECT COUNT(*) 
                         FROM GSMADMIN_INTERNAL.DATABASE
                         WHERE DPL_STATUS = 4'
        into current_value;
    ELSE
      -- GoldenGate
      execute immediate 'SELECT COUNT(*) 
                         FROM GSMADMIN_INTERNAL.DATABASE
                         WHERE DPL_STATUS = 5'
        into current_value;
    END IF;
 
END DBMS_HWM_SHARDS;
/
show errors;

/*************************************************************************
 * DBMS_HWM_PRIM_SHARDS
 * Procedure to get current number of deployed primary shards in catalog
 *************************************************************************/
create or replace procedure DBMS_HWM_PRIM_SHARDS
  (current_value OUT NUMBER) 
AS
    loc_count  number;
    loc_shtype number;
    loc_repl   number;
BEGIN
    current_value := 0;

    execute immediate 'SELECT COUNT(*) 
                       FROM GSMADMIN_INTERNAL.CLOUD
                       WHERE database_flags = ''C'''
      into loc_count;

    -- if not a catalog or not initialized, then no shards yet
    IF loc_count = 0 THEN
      RETURN;
    END IF;

    execute immediate 'SELECT SHARDING_TYPE, REPLICATION_TYPE 
                       FROM GSMADMIN_INTERNAL.CLOUD'
      into loc_shtype, loc_repl;

    -- if not a sharded catalog, then no shards possible
    IF loc_shtype = 0 THEN
      RETURN;
    END IF;

    IF loc_repl = 0 THEN
      -- DataGuard, 0= primary
      execute immediate 'SELECT COUNT(*) 
                         FROM GSMADMIN_INTERNAL.DATABASE
                         WHERE DPL_STATUS = 4 AND DEPLOY_AS = 0'
        into current_value;
    ELSE
      -- GoldenGate
      execute immediate 'SELECT COUNT(*) 
                         FROM GSMADMIN_INTERNAL.DATABASE
                         WHERE DPL_STATUS = 5'
        into current_value;
    END IF;
 
END DBMS_HWM_PRIM_SHARDS;
/
show errors;

/*************************************************
 * Database Features Usage Tracking Registration 
 *************************************************/

create or replace procedure DBMS_FEATURE_REGISTER_ALLFEAT
as
  /* string to get the last sample date */
  DBFUS_LAST_SAMPLE_DATE_STR CONSTANT VARCHAR2(100) :=
            ' (select nvl(max(last_sample_date), sysdate-7) ' || 
                'from wri$_dbu_usage_sample) ';

begin

  /********************** 
   * Advanced Replication
   **********************/

  declare 
    DBFUS_ADV_REPLICATION_STR CONSTANT VARCHAR2(1000) := 
        'select count(*), NULL, NULL from dba_repcat';

  begin
    dbms_feature_usage.register_db_feature
     ('Advanced Replication',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ADV_REPLICATION_STR,
      'Advanced Replication has been enabled.');
  end;

  /********************** 
   * Advanced Security Option Encryption/Checksumming
   **********************/

  declare
    DBFUS_ASO_STR CONSTANT VARCHAR2(1000) := 
     'select count (*), NULL, NULL from v$session_connect_info where ' ||
        'network_service_banner like ''%AES256 encryption%'' or ' ||
        'network_service_banner like ''%AES192 encryption%'' or ' ||
        'network_service_banner like ''%AES128 encryption%'' or ' ||
        'network_service_banner like ''%RC4_256 encryption%'' or ' ||
        'network_service_banner like ''%RC4_128 encryption%'' or ' ||
        'network_service_banner like ''%3DES168 encryption%'' or ' ||
        'network_service_banner like ''%3DES112 encryption%'' or ' ||
        'network_service_banner like ''%RC4_56 encryption%'' or ' ||
        'network_service_banner like ''%RC4_40 encryption%'' or ' ||
        'network_service_banner like ''%DES encryption%'' or ' ||
        'network_service_banner like ''%DES40 encryption%'' or ' ||
        'network_service_banner like ''%SHA1 crypto-checksumming%'' or ' ||
        'network_service_banner like ''%MD5 crypto-checksumming%''';
  begin
    dbms_feature_usage.register_db_feature
     ('ASO native encryption and checksumming',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ASO_STR,
      'ASO network native encryption and checksumming is being used.');
  end;

  /********************** 
   * Advanced Network Compression 
   **********************/
  declare
   DBFUS_NETWORK_COMPRESSION_STR CONSTANT VARCHAR2(1000) :=
    'select count (*), 0, null' ||
      ' from  v$session_connect_info' ||
      ' where network_service_banner like ''%Compression%''';
  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Advanced Network Compression Service',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL, 
      DBFUS_NETWORK_COMPRESSION_STR,
      'Oracle Advanced Network Compression Service Used');
  end;

  /********************** 
   * Thin Provisioning
   **********************/

  declare
    DBFUS_THP_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_THP';

  begin
    dbms_feature_usage.register_db_feature
     ('Thin Provisioning',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_THP_PROC,
      'Thin Provisioning in use');
  end;

  /********************** 
   * Flex ASM
   **********************/
  declare
    DBFUS_FLX_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_FLEX_ASM';

  begin
    dbms_feature_usage.register_db_feature
     ('Flex ASM',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_FLX_PROC,
      'Flex ASM in use');
  end;

  /************************** 
   * ASM Filter Driver (AFD)
   **************************/
  declare
    DBFUS_AFD_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_AFD';

  begin
    dbms_feature_usage.register_db_feature
     ('ASM Filter Driver',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AFD_PROC,
      'ASM Filter Driver in use');
  end;

  /************************** 
   * Automatic Storage Management Cluster File System (ACFS)
   **************************/
  declare
    DBFUS_ACFS_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ACFS';

  begin
    dbms_feature_usage.register_db_feature
     ('ACFS',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ACFS_PROC,
      'ACFS in use');
  end;

  /************************** 
   * Automatic Storage Management Cluster File System (ACFS) SNAPSHOT
   **************************/
  declare
    DBFUS_ACFS_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ACFS_SNAPSHOT';

  begin
    dbms_feature_usage.register_db_feature
     ('ACFS Snapshot',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ACFS_PROC,
      'ACFS Snapshot in use');
  end;

  /************************** 
   * Automatic Storage Management Cluster File System (ACFS)
   * Encryption
   **************************/
  declare
    DBFUS_ACFS_ENCR_PROC CONSTANT VARCHAR2(1000) :=
      'DBMS_FEATURE_ACFS_ENCR';

  begin
    dbms_feature_usage.register_db_feature
     ('ACFS Encryption',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ACFS_ENCR_PROC,
      'ACFS encryption in use');
  end;

  /********************** 
   * Traditional Audit
   **********************/
  declare 
    DBFUS_AUDIT_PROC CONSTANT VARCHAR2(1000) := 
      'dbms_feature_audit_options';

  begin
    dbms_feature_usage.register_db_feature
     ('Traditional Audit',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AUDIT_PROC,
      'Traditional Audit in use.');
  end;

  /**************************
   * Fine Grained Audit (FGA)
   **************************/
  declare 
    DBFUS_FGA_PROC CONSTANT VARCHAR2(1000) := 
      'dbms_feature_fga_audit';

  begin
    dbms_feature_usage.register_db_feature
     ('Fine Grained Audit',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_FGA_PROC,
      'Fine Grained Audit in use.');
  end;

  /**********************
   * Unified Audit 
   **********************/
  declare 
    DBFUS_UNIFIED_PROC CONSTANT VARCHAR2(1000) := 
      'dbms_feature_unified_audit';

  begin
    dbms_feature_usage.register_db_feature
     ('Unified Audit',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_UNIFIED_PROC,
      'Unified Audit in use.');
  end;

  /**********************************************
   * Auto-Maintenance Tasks
   *********************************************/

  declare 
    DBFUS_KET_OPT_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''auto optimizer stats collection'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(OPTIMIZER_STATS),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';

    DBFUS_KET_SEG_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''auto space advisor'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(SEGMENT_ADVISOR),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';

    DBFUS_KET_SQL_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''sql tuning advisor'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(SQL_TUNE_ADVISOR),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';


  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - Optimizer Statistics Gathering',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_OPT_STATS_STR,
      'Automatic initiation of Optimizer Statistics Collection');

    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - Space Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_SEG_STATS_STR,
      'Automatic initiation of Space Advisor');

    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - SQL Tuning Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_SQL_STATS_STR,
      'Automatic initiation of SQL Tuning Advisor');
  end;

  /**********************************************
   * Automatic Segment Space Management (system)
   **********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_AUTO_SSM';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_BITMAP_SEGMENT_SYS_PROC,
      'Extents of locally managed tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /********************************************
   * Automatic Segment Space Management (user)
   ********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'segment_space_management = ''AUTO'' and ' ||
        'tablespace_name not in ' ||
          '(''SYSTEM'', ''SYSAUX'', ''TEMP'', ''USERS'', ''EXAMPLE'', ''SYSEXT'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BITMAP_SEGMENT_USER_STR,
      'Extents of locally managed user tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /*********************************
   * Automatic SQL Execution Memory
   *********************************/

  declare 
    DBFUS_AUTO_PGA_STR CONSTANT VARCHAR2(1000) := 
      'select decode(pga + wap, 2, 1, 0), pga_aux + wap_aux, NULL from ' ||
        '(select count(*) pga, 0 pga_aux from v$system_parameter ' ||
          'where name = ''pga_aggregate_target'' and value != ''0''), ' ||
        '(select count(*) wap, 0 wap_aux from v$system_parameter ' ||
          'where name = ''workarea_size_policy'' and upper(value) = ''AUTO'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SQL Execution Memory',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUTO_PGA_STR,
      'Sizing of work areas for all dedicated sessions (PGA) is automatic.');
  end;

  /******************************** 
   * Automatic Storage Management
   ******************************/

  declare 
    DBFUS_ASM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ASM';
 
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Storage Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ASM_PROC,
      'Automatic Storage Management has been enabled');
  end;

  /***************************
   * Automatic Undo Management
   ***************************/

  declare 
    DBFUS_AUM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_AUM';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Undo Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AUM_PROC,
      'Oracle automatically manages undo data using an UNDO tablespace.');
  end;

  /**************************************
   * Automatic Workload Repository (AWR)
   **************************************/
  begin
    dbms_feature_usage.register_db_feature
       ('Automatic Workload Repository'
       ,dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED
       ,NULL
       ,dbms_feature_usage.DBU_DETECT_BY_PROCEDURE
       ,'DBMS_FEATURE_AWR'
       ,'A manual Automatic Workload Repository (AWR) snapshot was taken ' ||
        'in the last sample period.');
  end;


  /***************
   * AWR Baseline
   ***************/

  declare 
    DBFUS_AWR_BASELINE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from dba_hist_baseline ' ||
        'where baseline_name != ''SYSTEM_MOVING_WINDOW''';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Baseline',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_BASELINE_STR,
      'At least one AWR Baseline has been created by the user');
  end;

  /************************
   * AWR Baseline Template
   ************************/

  declare 
    DBFUS_AWR_BL_TEMPLATE_STR VARCHAR2(1000) := 
      'select count(*), count(*), NULL ' ||
        'from dba_hist_baseline_template';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Baseline Template',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_BL_TEMPLATE_STR,
      'At least one AWR Baseline Template has been created by the user');
  end;

  /***************
   * AWR Reports
   ***************/

  declare 
    DBFUS_AWR_REPORT_STR CONSTANT VARCHAR2(1000) := 
    q'[with last_period as
       (select * from wrm$_wr_usage
         where upper(feature_type) like 'REPORT'
           and usage_time >= ]' ||
    DBFUS_LAST_SAMPLE_DATE_STR ||
    q'[) 
       select decode (count(*), 0, 0, 1),
              count(*),
              feature_list
         from last_period,
        (select substr(sys_connect_by_path(feature_count, ','),2) feature_list
           from 
             (select feature_count,
                     count(*) over () cnt, 
                     row_number () over (order by 1) seq 
                from 
                  (select feature_name || ':' || count(*) feature_count
                     from last_period
                 group by feature_name)
             ) 
        where seq=cnt
        start with seq=1 
   connect by prior seq+1=seq)
     group by feature_list]';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Report',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_REPORT_STR,
      'At least one Workload Repository Report has been created by the user');
  end;

  /**************************
   * Backup Encryption
   **************************/

  /* This query returns 1 if there are any encrypted backup pieces,
   * whose status is 'available'.
   * Controlfile autobackups are ignored, because we don't want to 
   * consider RMAN in use if they just turned on the controlfile autobackup
   * feature. */

  begin
    dbms_feature_usage.register_db_feature
     ('Backup Encryption',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_BACKUP_ENCRYPTION',
      'Encrypted backups are being used.');
  end;

  /********************************
   * Baseline Adaptive Thresholds
   ********************************/

  declare
    DBFUS_BASELINE_ADAPTIVE_STR CONSTANT VARCHAR2(1000) :=
      'select decode(nvl(sum(moving)+sum(static),0), 0, 0, 1) '||
            ',nvl(sum(moving)+sum(static),0) '||
            ',''Adaptive: ''||nvl(sum(moving),0)||''; Static:''||nvl(sum(static),0) '||
        'from (select decode(AB.baseline_id, 0, 0, 1) static '||
                    ',decode(AB.baseline_id, 0, 1, 0) moving '||
                'from dbsnmp.bsln_threshold_params TP '||
                    ',dbsnmp.bsln_baselines B '||
                    ',dba_hist_baseline AB '||
                    ',v$database D '||
                    ',v$instance I '||
               'where AB.dbid = D.dbid '||
                 'and B.dbid = AB.dbid '||
                 'and B.baseline_id = AB.baseline_id '||
                 'and B.instance_name = I.instance_name '||
                 'and TP.bsln_guid = B.bsln_guid '||
                 'and in_effect = ''Y'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Baseline Adaptive Thresholds',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BASELINE_ADAPTIVE_STR,
      'Adaptive Thresholds have been configured.');
  end;

  /********************************
   * Baseline Static Computations
   ********************************/

  declare
    DBFUS_BASELINE_COMPUTES_STR CONSTANT VARCHAR2(1000) :=
      'select decode(count(*), 0, 0, 1), count(*), NULL '||
        'from dba_hist_baseline_metadata AB '||
            ',dbsnmp.bsln_baselines B '||
            ',v$database D '||
            ',v$instance I '||
       'where AB.dbid = D.dbid '||
         'and AB.baseline_type <> ''MOVING_WINDOW'' '||
         'and B.dbid = AB.dbid '||
         'and B.baseline_id = AB.baseline_id '||
         'and B.instance_name = I.instance_name '||
         'and B.last_compute_date IS NOT NULL';
  begin
    dbms_feature_usage.register_db_feature
     ('Baseline Static Computations',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BASELINE_COMPUTES_STR,
      'Static baseline statistics have been computed.');
  end;

  /************************ 
   * Block Change Tracking
   ************************/

  declare 
    DBFUS_BLOCK_CHANGE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from v$block_change_tracking where status = ''ENABLED''';

  begin
    dbms_feature_usage.register_db_feature
     ('Change-Aware Incremental Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BLOCK_CHANGE_STR,
      'Track blocks that have changed in the database.');
  end;

  /********************** 
   * Client Identifier
   **********************/

  declare 
    DBFUS_CLIENT_IDN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$session ' ||
      'where client_identifier is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Client Identifier',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CLIENT_IDN_STR,
      'Application User Proxy Authentication: Client Identifier is ' ||
      'used at this specific time.');
  end;


  /**********************************
   * Clusterwide Global Transactions
   **********************************/

  declare 
    DBFUS_CLUSTER_GTX_STR CONSTANT VARCHAR2(1000) :=
      'select value, NULL, NULL from v$sysstat ' ||
        'where name = ''Clusterwide global transactions''';
  
  begin
    dbms_feature_usage.register_db_feature
     ('Clusterwide Global Transactions',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CLUSTER_GTX_STR,
      'Clusterwide Global Transactions is being used.');
  end;

  /**********************************
   * Crossedition Triggers
   **********************************/

  declare 
    DBFUS_XEDTRG_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), NULL from trigger$ t ' ||
        'where bitand(t.property, 8192) = 8192';
  
  begin
    dbms_feature_usage.register_db_feature
     ('Crossedition Triggers',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_XEDTRG_STR,
      'Crossedition triggers is being used.');
  end;

  /****************************** 
   * CSSCAN - character set scan
   *******************************/

  declare 
    DBFUS_CSSCAN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'csmig.csm$parameters c ' ||
      'where c.name=''TIME_START'' and ' ||
      'to_date(c.value, ''YYYY-MM-DD HH24:MI:SS'') ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;

  begin
    dbms_feature_usage.register_db_feature
     ('CSSCAN',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'CSMIG.csm$parameters',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CSSCAN_STR,
      'Oracle Database has been scanned at least once for character set:' ||
      'CSSCAN has been run at least once.');
  end;
  
 
  /****************************** 
   * Character semantics turned on
   *******************************/

  declare 
    DBFUS_CHAR_SEMANTICS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_LENGTH_SEMANTICS'' and upper(value)=''CHAR'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Semantics',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SEMANTICS_STR,
      'Character length semantics is used in Oracle Database');
  end;
  
  /**************************** 
   * Character Set of Database
   ****************************/

  declare 
    DBFUS_CHAR_SET_STR CONSTANT VARCHAR2(1000) := 
      'select 1, null, value  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_CHARACTERSET'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Set',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SET_STR,
      'Character set is used in Oracle Database');
  end;
  

  /********************** 
   * Data Guard
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Data Guard',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DATA_GUARD',
      'Data Guard, a set of services, is being used to create, ' ||
      'maintain, manage, and monitor one or more standby databases.');
  end;

  /********************** 
   * Data Mining
   **********************/

 declare
    DBFUS_ODM_PROC VARCHAR2(100) := 'DBMS_FEATURE_DATABASE_ODM';
  begin
    dbms_feature_usage.register_db_feature
     ('Data Mining',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ODM_PROC,
      'There exist Oracle Data Mining models in the database.');
  end;


  /********************** 
   * Dynamic SGA
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Dynamic SGA',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DYN_SGA',
      'The Oracle SGA has been dynamically resized through an ' ||
      'ALTER SYSTEM SET statement.');
  end;

  /*************************************************
   * DMU - Database Migration Assistant for Unicode
   *************************************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Database Migration Assistant for Unicode',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.PROPS$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DMU',
      'Database Migration Assistant for Unicode has been used.');
  end;

  /******************************
   * Editions
   *******************************/

  declare
    DBFUS_EDITION_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), null from sys.edition$ e, sys.obj$ o ' ||
      'where e.obj# = o.obj# and o.name != ''ORA$BASE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Editions',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EDITION_STR,
      'Editions is being used.');
  end;

  /******************************
   * Editioning Views
   *******************************/

  declare
    DBFUS_EDITION_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), null from sys.view$ v ' ||
      'where bitand(v.property, 32) = 32';

  begin
    dbms_feature_usage.register_db_feature
     ('Editioning Views',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EDITION_STR,
      'Editioning views is being used.');
  end;

  /******************************
   * EM - Cloud Control tracking
   *******************************/

  declare
    DBFUS_EM_GC_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''GC'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('EM Cloud Control',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_GC_STR,
      'EM Cloud Control Database Home Page has been visited at least once.');
  end;

  /******************************
   * EM Performance Page  tracking
   *******************************/

  declare
    DBFUS_EM_DIAG_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''Diagnostic'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('EM Performance Page',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_DIAG_STR,
      'EM Performance Page has been visited at least once.');
  end;

  /******************************
   * EM - SQL Monitoring and Tuning pages tracking
   *******************************/

  declare
    DBFUS_EM_TUNING_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''Tuning'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Monitoring and Tuning pages',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_TUNING_STR,
      'EM SQL Monitoring and Tuning pages has been visited at least once.');
  end;

  /********************** 
   * File Mapping
   **********************/

  declare 
    DBFUS_FILE_MAPPING_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''file_mapping'' and upper(value) = ''TRUE'' and ' ||
        'exists (select 1 from v$map_file)';

  begin
    dbms_feature_usage.register_db_feature
     ('File Mapping',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FILE_MAPPING_STR,
      'File Mapping, the mechanism that shows a complete mapping ' ||
      'of a file to logical volumes and physical devices, is ' ||
      'being used.');
  end;


  /***************************
   * Flashback Database
   ***************************/

  declare 
    DBFUS_FB_DB_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database where ' ||
        'flashback_on = ''YES''';

  begin
    dbms_feature_usage.register_db_feature
     ('Flashback Database',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FB_DB_STR,
      'Flashback Database, a rewind button for the database, is enabled');
  end;


  /***************************
   * Flashback Data Archive
   ***************************/

  declare 
    DBFUS_FDA_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from DBA_FLASHBACK_ARCHIVE_TABLES';

  begin
    dbms_feature_usage.register_db_feature
     ('Flashback Data Archive',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FDA_STR,
      'Flashback Data Archive, a historical repository of changes to data ' ||
      'contained in a table, is used ');
  end;


  /******************************
   * Internode Parallel Execution
   ******************************/

  declare 
    DBFUS_INODE_PRL_EXEC_STR CONSTANT VARCHAR2(1000) := 
      'select sum(value), NULL, NULL from gv$pq_sysstat ' ||
        'where statistic like ''%Initiated (IPQ)%''';
      

  begin
    dbms_feature_usage.register_db_feature
     ('Internode Parallel Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_INODE_PRL_EXEC_STR,
      'Internode Parallel Execution is being used.');
  end;

  /********************** 
   * Label Security
   **********************/

  declare 
    DBFUS_LABEL_SECURITY_PROC CONSTANT VARCHAR2(1000) :=
      'dbms_feature_label_security';
  begin
    dbms_feature_usage.register_db_feature
     ('Label Security',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_LABEL_SECURITY_PROC,
      'Oracle Label Security is being used');
  end;

  /********************** 
   * Oracle Database Vault
   **********************/
  declare
     DBFUS_DATABASE_VAULT_PROC CONSTANT VARCHAR2(1000) :=
       'DBMS_FEATURE_DATABASE_VAULT';
  begin
     dbms_feature_usage.register_db_feature
     ('Oracle Database Vault',
      dbms_feature_usage.DBU_INST_OBJECT,
      'dvsys.realm$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DATABASE_VAULT_PROC,
      'Oracle Database Vault is being used');
  end;

  /***************************************
   * Deferred Segment Creation
   ***************************************/

  declare 
    DBFUS_DEFERRED_SEG_CRT_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_DEFERRED_SEG_CRT';
  begin
    dbms_feature_usage.register_db_feature
     ('Deferred Segment Creation',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DEFERRED_SEG_CRT_PROC,
      'Deferred Segment Creation is being used');
  end;

  /***************************************
   * Locally Managed Tablespaces (system)
   ***************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_LMT';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_LOCALLY_MANAGED_SYS_PROC,
      'There exists tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /*************************************
   * Locally Managed Tablespaces (user)
   *************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'extent_management = ''LOCAL'' and ' ||
        'tablespace_name not in ' ||
          '(''SYSTEM'', ''SYSAUX'', ''TEMP'', ''USERS'', ''EXAMPLE'',''SYSEXT'',''UD1'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCALLY_MANAGED_USER_STR,
      'There exists user tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /******************************
   * Messaging Gateway
   ******************************/

  declare
    DBFUS_MSG_GATEWAY_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from dba_registry ' ||
        'where comp_id = ''MGW'' and status != ''REMOVED'' and ' ||
        'exists (select 1 from mgw$_links)';

  begin
    dbms_feature_usage.register_db_feature
     ('Messaging Gateway',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.MGW$_GATEWAY',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MSG_GATEWAY_STR,
      'Messaging Gateway, that enables communication between non-Oracle ' ||
      'messaging systems and Advanced Queuing (AQ), link configured.');
  end;

  /********************** 
   * VLM
   **********************/

  declare 
    DBFUS_VLM_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''use_indirect_data_buffers'' and upper(value) != ''FALSE''';
  begin
    dbms_feature_usage.register_db_feature
     ('Very Large Memory',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_VLM_ADV_STR,
      'Very Large Memory is enabled.');
  end;


  /********************** 
   * Automatic Memory Tuning
   **********************/
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Memory Tuning',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_AUTO_MEM',
      'Automatic Memory Tuning is enabled.');
  end;

  /********************** 
   * Automatic SGA Tuning
   **********************/
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SGA Tuning',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_AUTO_SGA',
      'Automatic SGA Tuning is enabled.');
  end;


  /********************** 
   * ENCRYPTED Tablespace
   **********************/
  declare 
    DBFUS_ENT_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$encrypted_tablespaces'; 
  begin
    dbms_feature_usage.register_db_feature
     ('Encrypted Tablespaces',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ENT_ADV_STR,
      'Encrypted Tablespaces is enabled.');
  end;

  
  /********************** 
   * MTTR Advisor
   **********************/

  declare 
    DBFUS_MTTR_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$statistics_level where ' ||
        'statistics_name = ''MTTR Advice'' and ' ||
        'system_status = ''ENABLED'' and ' ||
        'exists (select 1 from v$instance_recovery ' ||
                  'where target_mttr != 0) and ' ||
        'exists (select 1 from v$mttr_target_advice ' ||
                  'where advice_status = ''ON'')';

  begin
    dbms_feature_usage.register_db_feature
     ('MTTR Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTTR_ADV_STR,
      'Mean Time to Recover Advisor is enabled.');
  end;

  /*********************** 
   * Multiple Block Sizes
   ***********************/

  declare 
    DBFUS_MULT_BLOCK_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''db_%_cache_size'' and value != ''0''';

  begin
    dbms_feature_usage.register_db_feature
     ('Multiple Block Sizes',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MULT_BLOCK_SIZE_STR,
      'Multiple Block Sizes are being used with this database.');
  end;

  /***************************** 
   * OLAP - Analytic Workspaces
   *****************************/

  declare 
    DBFUS_OLAP_AW_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from dba_aws where AW_NUMBER >= 1000' ||
        'and owner not in (''DM'',''OLAPTRAIN'',''GLOBAL'',''HR'',''OE'','||
        '''PM'',''SH'',''IX'',''BI'',''SCOTT'')';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Analytic Workspaces',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_AW_STR,
      'OLAP - the analytic workspaces stored in the database.');
  end;

  /***************************** 
   * OLAP - Cubes
   *****************************/

  declare 
    DBFUS_OLAP_CUBE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from DBA_OLAP2_CUBES ' ||
        'where invalid != ''Y'' and OWNER = ''SYS'' ' ||
        'and CUBE_NAME = ''STKPRICE_TBL''';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Cubes',
      dbms_feature_usage.DBU_INST_OBJECT,
      'PUBLIC.DBA_OLAP2_CUBES',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_CUBE_STR,
      'OLAP - number of cubes in the OLAP catalog that are fully ' ||
      'mapped and accessible by the OLAP API.');
  end;

  /*********************** 
   * Oracle Managed Files 
   ***********************/

  declare 
    DBFUS_OMF_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_data_files where ' ||
        'upper(file_name) like ''%O1_MF%''';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Managed Files',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OMF_STR,
      'Database files are being managed by Oracle.');
  end;

  /***********************
   * Oracle Secure Backup
   ***********************/

  /* This query returns the number of backup pieces created with 
   * Oracle Secure Backup whose status is 'available'. */

  declare
    DBFUS_OSB_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from x$kccbp where ' ||
      'bitand(bpext, 256) = 256 and '                   ||
      'bitand(bpflg,1+4096+8192) = 0';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Secure Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OSB_STR,
      'Oracle Secure Backup is used for backups to tertiary storage.');
  end;

  /*******************************
   * Parallel SQL DDL Execution
   *******************************/

  declare 
    DBFUS_PSQL_DDL_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DDL Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DDL Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DDL_STR,
      'Parallel SQL DDL Execution is being used.');
  end;

  /*******************************
   * Parallel SQL DML Execution
   *******************************/

  declare 
    DBFUS_PSQL_DML_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DML Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DML Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DML_STR,
      'Parallel SQL DML Execution is being used.');
  end;

  /****************************
   * Oracle Multitenant
   ****************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Multitenant',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_PDB_NUM',
      'Oracle Multitenant is being used.');
  end;

  /****************************
   * Oracle Pluggable Database
   ****************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Pluggable Databases',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      'DBMS_PDB_NUM',
      'Oracle Pluggable Databases is being used.');
  end;

  /*******************************
   * Parallel SQL Query Execution
   *******************************/

  declare 
    DBFUS_PSQL_QUERY_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''Queries Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL Query Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_QUERY_STR,
      'Parallel SQL Query Execution is being used.');
  end;

  /************************
   * Partitioning (system)
   ************************/

  declare 
    DBFUS_PARTN_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_SYSTEM';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_SYS_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one partitioned object created.');
  end;

  /**********************
   * Partitioning (user)
   **********************/

  declare 
    DBFUS_PARTN_USER_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_USER';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_USER_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one user partitioned object created.');
  end;

  /**********************
   * Zone Maps
   **********************/

  declare 
    DBFUS_ZMAP_USER_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ZMAP';
  begin
    dbms_feature_usage.register_db_feature
      ('Zone maps',       
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       DBFUS_ZMAP_USER_PROC,
       'Zone maps');
  end;


  /****************************
   * Oracle Text
   ****************************/
  
  declare
    DBFUS_TEXT_PROC CONSTANT VARCHAR2(1000) := 'ctxsys.drifeat.dr$feature_track';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Text',
      dbms_feature_usage.DBU_INST_OBJECT,
      'ctxsys.drifeat',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_TEXT_PROC,
      'Oracle Text is being used - there is at least one oracle '|| 
      'text index');
  end;

  /****************************
   * PL/SQL Native Compilation
   ****************************/

  declare 
    DBFUS_PLSQL_NATIVE_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PLSQL_NATIVE';

  begin
    dbms_feature_usage.register_db_feature
     ('PL/SQL Native Compilation',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PLSQL_NATIVE_PROC,
      'PL/SQL Native Compilation is being used - there is at least one ' ||
      'natively compiled PL/SQL library unit in the database.');
  end;

  /********************************
   * Quality of Service Management
   ********************************/

  declare 
    DBFUS_QOSM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_QOSM';
 
  begin
    dbms_feature_usage.register_db_feature
     ('Quality of Service Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_QOSM_PROC,
      'Quality of Service Management has been used.');
  end;

  /********************************
   * RAC One Node
   ********************************/

  declare
    DBFUS_ROND_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ROND';

  begin
    dbms_feature_usage.register_db_feature
     ('Real Application Cluster One Node',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ROND_PROC,
      'Real Application Cluster One Node is being used.');
  end;

  /****************************
   * Real Application Clusters 
   ****************************/

  declare 
    DBFUS_RAC_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_RAC';

  begin
    dbms_feature_usage.register_db_feature
     ('Real Application Clusters (RAC)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_RAC_PROC,
      'Real Application Clusters (RAC) is configured.');
  end;

  /********************** 
   * Recovery Area
   **********************/

  declare 
    DBFUS_RECOVERY_AREA_STR CONSTANT VARCHAR2(1000) := 
      'select p, s, NULL from ' ||
        '(select count(*) p from v$parameter ' ||
         'where name = ''db_recovery_file_dest'' and value is not null), ' ||
        '(select to_number(value) s from v$parameter ' ||
         'where name = ''db_recovery_file_dest_size'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Area',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RECOVERY_AREA_STR,
      'The recovery area is configured.');
  end;

  /**************************
   * Recovery Manager (RMAN)
   **************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Manager (RMAN)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database.');
  end;

  /********************** 
   * RMAN - Disk Backup
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Disk Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_DISK_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database to disk.');
  end;

  /********************** 
   * RMAN - Tape Backup
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Tape Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_TAPE_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database to tape.');
  end;

  /**********************************
   * RMAN - ZLIB compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup ZLIB Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_ZLIB',
      'ZLIB compressed backups are being used.');
  end;

  /**********************************
   * RMAN - BZIP2 compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup BZIP2 Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BZIP2',
      'BZIP2 compressed backups are being used.');
  end;

  /**********************************
   * RMAN - BASIC compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup BASIC Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BASIC',
      'BASIC compressed backups are being used.');
  end;

  /**********************************
   * RMAN - LOW compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup LOW Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_LOW',
      'LOW compressed backups are being used.');
  end;

  /**********************************
   * RMAN - MEDIUM compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup MEDIUM Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_MEDIUM',
      'MEDIUM compressed backups are being used.');
  end;

  /**********************************
   * RMAN - HIGH compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup HIGH Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_HIGH',
      'HIGH compressed backups are being used.');
  end;

  /****************************
  * Long-term archival backups
  *****************************/

  declare
  DBFUS_KEEP_BACKUP_STR CONSTANT VARCHAR2(1000) :=
    'select count(*), NULL, decode(min(keep_options), ''BACKUP_LOGS'',
    ''Consistent backups archived'') from v$backup_set where keep = ''YES'''; 

  begin
    dbms_feature_usage.register_db_feature
     ('Long-term Archival Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KEEP_BACKUP_STR,
      'Long-term archival backups are being used.');
  end;

  /****************************
  * Multi section backups
  *****************************/

  declare
  DBFUS_MULTI_SECTION_BACKUP_STR CONSTANT VARCHAR2(1000) :=
    'select count(*), NULL, NULL ' ||
    'from v$backup_set where multi_section = ''YES'''; 

  begin
    dbms_feature_usage.register_db_feature
     ('Multi Section Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MULTI_SECTION_BACKUP_STR,
      'Multi section backups are being used.');
  end;    

  /*********************** 
   * Block Media Recovery
   ***********************/

  declare
    DBFUS_BLOCK_MEDIA_RCV_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''BLOCK MEDIA RECOVERY%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Block Media Recovery',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BLOCK_MEDIA_RCV_STR,
      'Block Media Recovery is being used to repair the database.');
  end;


  /*********************** 
   * Restore Point
   ***********************/

  declare
    DBFUS_RESTORE_POINT_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$restore_point)';
  begin
    dbms_feature_usage.register_db_feature
     ('Restore Point',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RESTORE_POINT_STR,
      'Restore Points are being used as targets for Flashback');
  end;

  /*********************** 
   * Logfile Multiplexing
   ***********************/

  declare
    DBFUS_LOGFILE_MULTIPLEX_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from ' ||
        '  (select count(*) a from v$logfile group by group#)' ||
        '  where a>1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Logfile Multiplexing',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOGFILE_MULTIPLEX_STR,
      'Multiple members are used in a single log file group');
  end;


  /*********************** 
   * Bigfile Tablespace
   ***********************/

  declare
    DBFUS_BIGFILE_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$tablespace' ||
        '  where bigfile = ''YES'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Bigfile Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BIGFILE_TBS_STR,
      'Bigfile tablespace is being used');
  end;


  /************************** 
   * Transportable Tablespace
   **************************/

  declare
    DBFUS_TRANSPORTABLE_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$datafile' ||
        '  where plugged_in = 1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Transportable Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_TRANSPORTABLE_TBS_STR,
      'Transportable tablespace is being used');
  end;


  /*********************** 
   * Read Only Tablespace
   ***********************/
  
  declare
    DBFUS_READONLY_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$datafile' ||
        '  where enabled = ''READ ONLY'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Read Only Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_READONLY_TBS_STR,
      'Read only tablespace is being used');
  end;

  /************************* 
   * Read Only Open Delayed
   *************************/
  
  declare
    DBFUS_READOPEN_DELAY_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$parameter' ||
        '  where name = ''read_only_open_delayed'' and value = ''TRUE'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Deferred Open Read Only',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_READOPEN_DELAY_STR,
      'Deferred open read only feature is enabled');
  end;


  /********************** 
   * Active Data Guard
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Active Data Guard - Real-Time Query on Physical Standby',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_ACTIVE_DATA_GUARD',
      'Active Data Guard, a set of services, is being used to enhance ' ||
      'Data Guard');
  end;


  /********************** 
   * Online Move Datafile
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Online Move Datafile',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_MOVE_DATAFILE',
      'Online Move Datafile is being used to move datafiles');
  end;


  /********************* 
   * Backup Rollforward
   *********************/

  declare
    DBFUS_BACKUP_ROLLFORWARD_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''BACKUP COPYROLLFORWARD%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Backup Rollforward',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BACKUP_ROLLFORWARD_STR,
      'Backup Rollforward strategy is being used to backup the database.');
  end;

  /************************ 
   * Data Recovery Advisor
   ************************/

  declare
    DBFUS_DATA_RCV_ADVISOR_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$ir_repair' ||
        '  where rownum = 1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Data Recovery Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_RCV_ADVISOR_STR,
      'Data Recovery Advisor (DRA) is being used to repair the database.');
  end;

  /***********************
   * Backup and Restore of plugged database
   ***********************/

  declare
    DBFUS_BR_PLUGGED_DB_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''%PLUGGABLE DATABASE%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Backup and Restore of plugged database',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BR_PLUGGED_DB_STR,
      'Backup and Restore of plugged database by RMAN is used.');
  end;

  /********************* 
   * Recover Table, additional space after TABLE is intentional.
   *********************/

  declare
    DBFUS_RECOVER_TABLE_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''RECOVER TABLE %'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Recover Table',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RECOVER_TABLE_STR,
      'Recover Table is used to recover a table in the database.');
  end;

  /********************* 
   * Recover Until Snapshot
   *********************/

  declare
    DBFUS_RECOVER_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''RECOVER UNTIL SNAPSHOT%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Recover Until Snapshot',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RECOVER_STR,
      'Recover until snapshot is used to recover the database.');
  end;

  /********************* 
   * TRANSPORT TABLESPACE command
   *********************/

  declare
    DBFUS_TRANSPORT_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''TRANSPORT TABLESPACE%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('TRANSPORT TABLESPACE command',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_TRANSPORT_TBS_STR,
      'RMAN''s TRANSPORT TABLESPACE command used by the database.');
  end;

  /********************* 
   * CONVERT command
   *********************/

  declare
    DBFUS_CONVERT_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''CONVERT%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('CONVERT command',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CONVERT_STR,
      'RMAN''s CONVERT command used by the database.');
  end;

  /********************* 
   * Cross Platform Backup and Restore
   *********************/

  declare
    DBFUS_CROSS_PLATFORM_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation in '||
        '     (''RECOVER FROM PLATFORM'', ''BACKUP FOR TRANSPORT'', '||
        '      ''BACKUP FROM PLATFORM'', ''RESTORE FROM PLATFORM''))';
  begin
    dbms_feature_usage.register_db_feature
     ('Cross-Platform Backups',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CROSS_PLATFORM_STR,
      'Cross-Platform Backup and Restore used by the database.');
  end;

  /********************* 
   * Duplicate from Active Database using BackupSet
   *********************/

  declare
    DBFUS_DUPDB_USINGBCK_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''DUPLICATE DB FROM ACTIVE USING B%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Duplicate Db from Active Db using BackupSet',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DUPDB_USINGBCK_STR,
      'Duplicate from Active Database using BackupSet is used.');
  end;

  /********************** 
   * Resource Manager
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Resource Manager',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RESOURCE_MANAGER',
      'Oracle Database Resource Manager is being used to manage ' ||
      'database resources.');
  end;

  /********************** 
   * Instance Caging
   **********************/

  declare
    DBFUS_DATA_INSTANCE_CAGING_STR CONSTANT VARCHAR2(2000) :=
      'select count(*), NULL, NULL from v$rsrc_plan_history top where ' ||
      'instance_caging = ''ON'' and ' ||
      '(name != ''ORA$INTERNAL_CDB_PLAN'' and ' ||
      ' name != ''INTERNAL_PLAN'' and name is not null and ' ||
      ' (name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '   (window_name is null or ' ||
      '    (window_name != ''MONDAY_WINDOW'' and ' ||
      '     window_name != ''TUESDAY_WINDOW'' and ' ||
      '     window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '     window_name != ''THURSDAY_WINDOW'' and ' ||
      '     window_name != ''FRIDAY_WINDOW'' and ' ||
      '     window_name != ''SATURDAY_WINDOW'' and ' ||
      '     window_name != ''SUNDAY_WINDOW''))) and ' ||
      ' (name != ''DEFAULT_CDB_PLAN'' or ' ||
      '   (select count(*) from v$rsrc_plan_history pdb ' ||
      '      where pdb.con_id > 1 and pdb.name is not null) = 0 or ' ||
      '   (select count(*) from v$rsrc_plan_history pdb ' ||
      '      where pdb.con_id > 1 and ' ||
      '            pdb.name is not null and ' ||
      '            pdb.name != ''INTERNAL_PLAN'' and ' ||
      '            (pdb.name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '              (pdb.window_name is null or ' ||
      '               (pdb.window_name != ''MONDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''TUESDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''THURSDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''FRIDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''SATURDAY_WINDOW'' and ' ||
      '                pdb.window_name != ''SUNDAY_WINDOW'')))) > 0))';
  begin
    dbms_feature_usage.register_db_feature
     ('Instance Caging',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_INSTANCE_CAGING_STR,
      'Instance Caging is being used to limit the CPU usage by the ' ||
      'database instance.');
  end;

  /********************** 
   * dNFS
   **********************/

  declare
    DBFUS_DATA_DNFS_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from v$dnfs_servers';
  begin
    dbms_feature_usage.register_db_feature
     ('Direct NFS',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_DNFS_STR,
      'Direct NFS is being used to connect to an NFS server');
  end;

  /********************** 
   * PDB I/O rate limits
   **********************/

  declare
    DBFUS_DATA_PDB_IORL_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from pdb_spfile$ ' ||
      'where (name = ''max_iops'' or name = ''max_mbps'') and spare2 = 0';
  begin
    dbms_feature_usage.register_db_feature
     ('PDB I/O Rate Limits',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_PDB_IORL_STR,
      'PDB I/O Rate Limits are being used to limit the I/O usage by ' ||
      'Pluggable databases.');
  end;

  /*********************** 
   * Server Flash Cache
   ***********************/

  declare 
    DBFUS_SRV_FLASH_CACHE_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''%flash_cache_size'' and value != ''0''';

  begin
    dbms_feature_usage.register_db_feature
     ('Server Flash Cache',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SRV_FLASH_CACHE_SIZE_STR,
      'Server Flash Cache is being used with this database.');
  end;

  /************************ 
   * Server Parameter File
   ************************/

  declare 
    DBFUS_SPFILE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''spfile'' and value is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Server Parameter File',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPFILE_STR,
      'The server parameter file (SPFILE) was used to startup the database.');
  end;

  /********************** 
   * Shared Server
   **********************/

  declare 
    DBFUS_MTS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter ' ||
        'where name = ''shared_servers'' and value != ''0'' and ' ||
        'exists (select 1 from v$shared_server where requests > 0)';

  begin
    dbms_feature_usage.register_db_feature
     ('Shared Server',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTS_STR,
      'The database is configured as Shared Server, where one server ' ||
      'process can service multiple client programs.');
  end;

  /********************************************** 
   * Database Resident Connection Pooling  (DRCP)
   **********************************************/

  declare 
    DBFUS_DRCP_STR CONSTANT VARCHAR2(1000) := 
      'select count(maxsize), nvl(sum(maxsize),0), NULL from dba_cpool_info '||
      'where status=''ACTIVE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Database Resident Connection Pooling (DRCP)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DRCP_STR,
      'Active Database Resident Connection Pool has been detected');
  end;

  /********************** 
   * Spatial 
   **********************/

  declare 
    DBFUS_SPATIAL_STR CONSTANT VARCHAR2(1000) := 
     'select count(*), 0, NULL ' ||
     'from mdsys.sdo_feature_usage '||
     'where used = ''Y'' ' ||
     'and is_spatial = ''Y'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Spatial',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'MDSYS.all_sdo_index_metadata',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPATIAL_STR,
      'There is at least one usage of the Oracle Spatial feature usage table.');
  end;

  /**********************
   * Locator
   **********************/

  declare
    DBFUS_LOCATOR_STR CONSTANT VARCHAR2(1000) :=
     'select count(*), 0, NULL ' ||
     'from mdsys.sdo_feature_usage '||
     'where used = ''Y'' ' ||
     'and is_spatial = ''N'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Locator',
      dbms_feature_usage.DBU_INST_OBJECT,
      'MDSYS.sdo_geom_metadata_table',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCATOR_STR,
      'There is at least one usage of the Oracle Locator feature usage table.');
  end;


  /***********************************************************************
   * All advisors using the advisor framework. This includes all advisors 
   * listed in DBA_ADVISOR_DEFINITIONS and DBA_ADVISOR_USAGE views.
   ************************************************************************/
  /* FIXME: Mike would like to use a pl/sql procedure instead of a query */ 
  declare 
      dbu_detect_sql VARCHAR2(32767); 
  begin 
      FOR adv_rec IN (SELECT advisor_name, advisor_id 
                      FROM dba_advisor_definitions
                      WHERE bitand(property, 64) != 64
                      ORDER BY advisor_id)  
      LOOP
        -- build the query that will be executed to track an advisor usage

        -- clob column FEATURE_INFO will contain XML for advisor framework-
        -- level info, with advisor extra info sitting beneath the framework
        -- tag
        IF (adv_rec.advisor_name = 'ADDM') THEN 
          dbu_detect_sql := ', xmltype(prvt_hdm.db_feature_clob) ';
        ELSE
          dbu_detect_sql := '';
        END IF;

        dbu_detect_sql := 
          ' xmlelement("advisor_usage", 
              xmlelement("reports", 
                xmlelement("first_report_time", 
                            to_char(first_report_time, 
                                    ''dd-mon-yyyy hh24:mi:ss'')), 
                xmlelement("last_report_time", 
                           to_char(last_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                xmlelement("num_db_reports", num_db_reports)) 
                ' || dbu_detect_sql || ').getClobVal(2,2) ';

        -- used:       1 if advisor executed since last sample
        -- sofar_exec: total # of executions since db create
        -- dbf_clob:   reporting, plus advisor-specific stuff
        dbu_detect_sql := 
          'SELECT used, sofar_exec, dbf_clob FROM 
             (SELECT num_execs sofar_exec, ' || dbu_detect_sql || ' dbf_clob
              FROM   dba_advisor_usage u 
              WHERE  u.advisor_name = ''' || adv_rec.advisor_name || '''), ' ||
            '(SELECT count(*) used
              FROM   dba_advisor_usage u
              WHERE u.advisor_name = ''' || adv_rec.advisor_name || ''' AND 
                    (u.num_execs > 0 or u.num_db_reports > 0) and 
                     greatest(nvl(u.last_exec_time, sysdate - 1000), 
                              nvl(u.last_report_time, sysdate - 1000)) >= 
                                       ' || DBFUS_LAST_SAMPLE_DATE_STR || ')';

        -- register the current advisor
        dbms_feature_usage.register_db_feature
          (adv_rec.advisor_name,
           dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
           NULL,
           dbms_feature_usage.DBU_DETECT_BY_SQL,
           dbu_detect_sql,
           adv_rec.advisor_name || ' has been used.');
      END LOOP;
  end;

  /******************************
   * Real-Time SQL Monitoring
   ******************************/
  declare 
      dbu_detect_sql VARCHAR2(32767); 
  begin 
      -- used:       1 if db report for monitoring details requested since
      --             last sample (list report is not tracked)
      -- sofar_exec: total # of db reports requested since db creation
      -- dbf_clob:   extra XML info
      dbu_detect_sql := 
        'SELECT used, sofar_exec, dbf_clob
         FROM   (SELECT count(*) used
                 FROM   dba_sql_monitor_usage
                 WHERE  num_db_reports > 0 AND
                        last_db_report_time >= ' || DBFUS_LAST_SAMPLE_DATE_STR
                || '), 
                (SELECT num_db_reports sofar_exec, 
                        xmlelement("sqlmon_usage", 
                         xmlelement("num_em_reports", num_em_reports),
                         xmlelement("first_db_report_time", 
                           to_char(first_db_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("last_db_report_time", 
                           to_char(last_db_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("first_em_report_time", 
                           to_char(first_em_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("last_em_report_time", 
                           to_char(last_em_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss''))
                        ).getClobVal(2,2) dbf_clob
                FROM dba_sql_monitor_usage)'; 

      -- register the feature
      dbms_feature_usage.register_db_feature
        ('Real-Time SQL Monitoring',
         dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
         NULL,
         dbms_feature_usage.DBU_DETECT_BY_SQL,
         dbu_detect_sql,
         'Real-Time SQL Monitoring Usage.');
  end;
  

  /******************************
   * SQL Tuning Set
   ******************************/
  declare 
    -- A 'user' SQL Tuning Set is one not owned by SYS, and a 'system' SQL
    -- Tuning Set is one that is owned by SYS.  This will cover the $$ STSes
    -- that Access Advisor creates, and users do not use EM as SYS, so it should
    -- be good enough for now.
    DBFUS_USER_SQL_TUNING_SET_STR CONSTANT VARCHAR2(1000) := 
      'select numss, numref, NULL from ' ||
        '(select count(*) numss ' ||
        ' from wri$_sqlset_definitions ' ||
        ' where owner <> ''SYS''), ' ||
        '(select count(*) numref ' ||
        ' from wri$_sqlset_references r, wri$_sqlset_definitions d ' ||
        ' where d.id = r.sqlset_id and d.owner <> ''SYS'')';

    DBFUS_SYS_SQL_TUNING_SET_STR CONSTANT VARCHAR2(1000) := 
      'select numss, numref, NULL from ' ||
        '(select count(*) numss ' ||
        ' from wri$_sqlset_definitions ' ||
        ' where owner = ''SYS''), ' ||
        '(select count(*) numref ' ||
        ' from wri$_sqlset_references r, wri$_sqlset_definitions d ' ||
        ' where d.id = r.sqlset_id and d.owner = ''SYS'')';
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Tuning Set (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_USER_SQL_TUNING_SET_STR,
      'A SQL Tuning Set has been created in the database in a user schema.');


    dbms_feature_usage.register_db_feature
     ('SQL Tuning Set (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SYS_SQL_TUNING_SET_STR,
      'A SQL Tuning Set has been created in the database in the SYS schema.');
  end;

  /******************************
   * Automatic SQL Tuning Advisor
   ******************************/
  declare
    DBFUS_AUTOSTA_PROC VARCHAR2(100) := 'DBMS_FEATURE_AUTOSTA';
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SQL Tuning Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AUTOSTA_PROC,
      'Automatic SQL Tuning Advisor has been used.');
  end;

  /******************************
   * SQL Profiles 
   ******************************/
  /* FIXME: Mike would like to use a pl/sql procedure instead of a query */ 
  declare 
    DBFUS_SQLPROFILE_STR CONSTANT VARCHAR2(32767) := 
      q'#SELECT used,
                prof_count, 
                profs || ', ' || manual || ', ' || auto || ', ' || 
                enabl || ', ' || cat as details
         FROM (SELECT sum(decode(status, 'ENABLED', 1, 0)) used,
                      sum(1) prof_count,
                     'Total so far: ' || sum(1) profs, 
                     'Enabled: ' || sum(decode(status, 'ENABLED', 1, 0)) enabl,
                     'Manual: ' || sum(decode(type, 'MANUAL', 1, 0)) manual,
                     'Auto: ' || sum(decode(type, 'AUTO', 1, 0)) auto,
                     'Category count: ' || count(unique category) cat
               FROM dba_sql_profiles)#';
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Profile',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQLPROFILE_STR,
      'SQL profiles have been used.');
  end;

  /************************************************
   * Database Replay: Workload Capture and Replay *
   ************************************************/
  declare
    prev_sample_count     NUMBER;
    prev_sample_date      NUMBER;

    DBFUS_WCR_CAPTURE_PROC VARCHAR2(1000) := 'DBMS_FEATURE_WCR_CAPTURE';
    DBFUS_WCR_REPLAY_PROC  VARCHAR2(1000) := 'DBMS_FEATURE_WCR_REPLAY';
  begin
    dbms_feature_usage.register_db_feature
     ('Database Replay: Workload Capture',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_WCR_CAPTURE_PROC,
      'Database Replay: Workload was ever captured.');

    dbms_feature_usage.register_db_feature
     ('Database Replay: Workload Replay',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_WCR_REPLAY_PROC,
      'Database Replay: Workload was ever replayed.');
  end;

  /********************** 
   * Streams (system)
   **********************/

  declare 
    DBFUS_STREAMS_SYS_PROC CONSTANT VARCHAR2(1000) := 
       'dbms_feature_streams';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_STREAMS_SYS_PROC,
      'Oracle Streams processes have been configured');
  end;

  /********************** 
   * Streams (user)
   **********************/

  declare 
    DBFUS_STREAMS_USER_STR CONSTANT VARCHAR2(1000) := 
    -- for AQ, there are default queues in the sys, system, ix, 
    -- wmsys, sysman, and gsmdamin_internal
    -- schemas which we do not want to count towards Streams user feature usage
    -- for Streams messaging these consumers are in db by default
     'select decode(strmsg + aq, 0, 0, 1), 0, NULL from ' ||
     '(select decode(count(*), 0, 0, 1) strmsg ' ||
     '  from dba_streams_message_consumers ' ||
     '  where streams_name != ''SCHEDULER_COORDINATOR'' and ' ||
     '  streams_name != ''SCHEDULER_PICKUP''),' ||  
     '(select decode (count(*), 0, 0, 1) aq ' ||
     '  from system.aq$_queue_tables where schema not in ' ||
     '  (''SYS'', ''SYSTEM'', ''IX'', ''WMSYS'', ''SYSMAN'', ' ||
     '''GSMADMIN_INTERNAL''))';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STREAMS_USER_STR,
      'Users have configured Oracle Streams AQ');
  end;

  /********************** 
   * XStream In
   **********************/

  declare 
    DBFUS_XSTREAM_IN_PROC CONSTANT VARCHAR2(1000) := 
       'dbms_feature_xstream_in';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream In',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_IN_PROC,
      'Oracle XStream Inbound servers have been configured');
  end;

  /**********************
   * XStream Out
   **********************/

  declare
    DBFUS_XSTREAM_OUT_PROC CONSTANT VARCHAR2(1000) :=
       'dbms_feature_xstream_out';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream Out',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_OUT_PROC,
      'Oracle XStream Outbound servers have been configured');
  end;

  /**********************
   * XStream Streams
   **********************/

  declare
    DBFUS_XSTREAM_STREAMS_PROC CONSTANT VARCHAR2(1000) :=
       'dbms_feature_xstream_streams';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream Streams',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_STREAMS_PROC,
      'Oracle Streams with XStream functionality has been configured');
  end;

  /**********************
   * GoldenGate
   **********************/

  declare
    DBFUS_GOLDENGATE_PROC CONSTANT VARCHAR2(1000) :=
    'dbms_feature_goldengate';

  begin
    dbms_feature_usage.register_db_feature
     ('GoldenGate',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_GOLDENGATE_PROC,
      'Oracle GoldenGate Capabilities are in use.');
  end;

  /********************** 
   * Transparent Gateway
   **********************/

  declare 
    DBFUS_GATEWAYS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from hs_fds_class_date ' || 
        'where fds_class_name != ''BITE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Gateway',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_GATEWAYS_STR,
      'Heterogeneous Connectivity, access to a non-Oracle system, has ' ||
      'been configured.');
  end;

  /***************************
   * Virtual Private Database
   ***************************/

  declare 
    DBFUS_VPD_STR CONSTANT VARCHAR2(1000) := 
      'dbms_feature_VPD';

  begin
    dbms_feature_usage.register_db_feature
     ('Virtual Private Database (VPD)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_VPD_STR,
      'Virtual Private Database (VPD) policies are being used.');
  end;

  /********************** 
   * Workspace Manager
   **********************/

  declare 
    DBFUS_OWM_STR CONSTANT VARCHAR2(1000) := 
     'select count(*), count(*), NULL ' ||
     'from wmsys.wm$versioned_tables';

  begin
    dbms_feature_usage.register_db_feature
     ('Workspace Manager',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'WMSYS.wm$versioned_tables',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OWM_STR,
      'There is at least one version enabled table.');
  end;

  /**************************
   * XDB
   **************************/
   
  begin
    dbms_feature_usage.register_db_feature
     ('XDB',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'XDB.Resource_View',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_XDB',
      'XDB feature is being used.');
  end;

  /*****************************
   * JSON
   *****************************/

  begin
    dbms_feature_usage.register_db_feature
     ('JSON',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_JSON',
      'JSON feature is being used.');
  end;

  /*****************************
   * Application Express (APEX)
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
    ( 'Application Express',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_APEX',
      'Application Express feature is being used.');
  end;

  /***************************
   * LOB 
   ***************************/

  declare
    DBMS_FEATURE_LOB CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from sys.lob$ l, sys.obj$ o, sys.user$ u ' ||
       'where l.obj# = o.obj# ' ||
         'and o.owner# = u.user# ' ||
         'and u.name not in (select schema_name from v$sysaux_occupants) ' ||
         'and u.name not in (''OUTLN'', ''OE'', ''IX'', ''PM'', ''SH'', 
                             ''OJVMSYS'', ''DVSYS'', ''GSMADMIN_INTERNAL'', 
                             ''SYSMAN_MDS'', ''SYSMAN_OPSS'', 
                             ''SYSMAN_BIPLATFORM'') ' ||
         'and u.name not like ''APEX_% '' ' ||
         'and u.name not like ''FLOWS_%'''; 

  begin
    dbms_feature_usage.register_db_feature
     ('LOB',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBMS_FEATURE_LOB,
      'Persistent LOBs are being used.');
  end;

  /***************************
   * OBJECT 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Object',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_OBJECT',
      'Object feature is being used.');
  end;

  /***************************
   * EXTENSIBILITY 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Extensibility',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_EXTENSIBILITY',
      'Extensibility feature is being used.');
  end;

  /******************************
   * SQL Plan Management
   ******************************/

  declare 
    DBFUS_SQL_PLAN_MANAGEMENT_STR CONSTANT VARCHAR2(4000) := 
      q'#SELECT nvl(total_count, 0) total_count,
                nvl(enabled_count, 0) enabled_count, 
                decode(total_count, null, null,
                                    0, null,
                                    (manual_load || ', ' ||
                                     auto_capture || ', ' ||
                                     manual_sqltune || ', ' || 
                                     auto_sqltune || ', ' ||
                                     stored_outline || ', ' ||
                                     evolve_adaptive || ', ' ||
                                     manual_load_sts || ', ' ||
                                     manual_load_awr || ', ' ||
                                     manual_load_cc || ', ' ||
                                     evolve_load_sts || ', ' ||
                                     evolve_load_awr || ', ' ||
                                     evolve_load_cc || ', ' ||
                                     accepted_count || ', ' ||
                                     fixed_count || ', ' ||
                                     reproduced_count)) as details
         FROM (SELECT
                 sum(1) total_count,
                 sum(decode(enabled, 'YES', 1, 0)) enabled_count,
                 'Manual-load: ' ||
                   sum(decode(origin, 'MANUAL-LOAD', 1, 0)) manual_load,
                 'Auto-capture: ' ||
                   sum(decode(origin, 'AUTO-CAPTURE', 1, 0)) auto_capture,
                 'Manual-sqltune: ' ||
                   sum(decode(origin, 'MANUAL-SQLTUNE', 1, 0)) manual_sqltune,
                 'Auto-sqltune: ' ||
                   sum(decode(origin, 'AUTO-SQLTUNE', 1, 0)) auto_sqltune,
                 'Stored-outline: ' ||
                   sum(decode(origin, 'STORED-OUTLINE', 1, 0)) stored_outline,
                 'Evolve-create-from-adaptive: ' ||
                   sum(decode(origin, 'EVOLVE-CREATE-FROM-ADAPTIVE', 1, 0)) 
                     evolve_adaptive,
                 'Manual-load-from-sts: ' ||
                   sum(decode(origin, 'MANUAL-LOAD-FROM-STS', 1, 0))
                     manual_load_sts,
                 'Manual-load-from-awr: ' ||
                   sum(decode(origin, 'MANUAL-LOAD-FROM-AWR', 1, 0))
                     manual_load_awr,
                 'Manual-load-from-cursor-cache: ' ||
                   sum(decode(origin, 'MANUAL-LOAD-FROM-CURSOR-CACHE', 1, 0))
                     manual_load_cc,
                 'Evolve-load-from-sts: ' ||
                   sum(decode(origin, 'EVOLVE-LOAD-FROM-STS', 1, 0))
                     evolve_load_sts,
                 'Evolve-load-from-awr: ' ||
                   sum(decode(origin, 'EVOLVE-LOAD-FROM-AWR', 1, 0))
                     evolve_load_awr,
                 'Evolve-load-from-cursor-cache: ' ||
                   sum(decode(origin, 'EVOLVE-LOAD-FROM-CURSOR-CACHE', 1, 0))
                     evolve_load_cc,
                 'Accepted: ' ||
                   sum(decode(accepted, 'YES', 1, 0)) accepted_count,
                 'Fixed: ' ||
                   sum(decode(fixed, 'YES', 1, 0)) fixed_count,
                 'Reproduced: ' ||
                   sum(decode(reproduced, 'YES', 1, 0)) reproduced_count
               FROM dba_sql_plan_baselines)#';
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Plan Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQL_PLAN_MANAGEMENT_STR,
      'SQL Plan Management has been used.');
  end;

  /******************************
   * DBMS_FEATURE_ADAPTIVE_PLANS
   ******************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Adaptive Plans',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_ADAPTIVE_PLANS',
      'Adaptive Plans have been used');
  end;

  /**********************************
   * DBMS_FEATURE_AUTO_REOPT
   **********************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Reoptimization',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_AUTO_REOPT',
      'Automatic Reoptimization have been used');
  end;

  begin
    dbms_feature_usage.register_db_feature
     ('SQL Plan Directive',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SPD',
      'Sql plan directive has been used');
  end;

  /******************************
   * DBMS_FEATURE_STATS_CONCURRENT
   ******************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Concurrent Statistics Gathering',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_CONCURRENT_STATS',
      'Concurrent Statistics Gathering has been used');
  end;

  /******************************
   * DBMS_FEATURE_STATS_INCREMENTAL
   ******************************/
  begin
    dbms_feature_usage.register_db_feature
     ('DBMS_STATS Incremental Maintenance',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_STATS_INCREMENTAL',
      'DBMS_STATS Incremental Maintenance has been used.');
  end;


  /***************************
   * RULES MANAGER and EXPRESSION FILTER
   ***************************/
  begin
    dbms_feature_usage.register_db_feature
        ('Rules Manager',
          dbms_feature_usage.DBU_INST_OBJECT, 
          'EXFSYS.exf$attrset',
          dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
          'DBMS_FEATURE_RULESMANAGER',
           'Rules Manager and Expression Filter');
  end;

  /***************************************************************
   *  DATABASE UTILITY: ORACLE DATAPUMP EXPORT
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Datapump (Export)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities1',
       'Oracle Utility Datapump (Export) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: ORACLE DATAPUMP IMPORT
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Datapump (Import)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities2',
       'Oracle Utility Datapump (Import) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: SQL*LOADER (DIRECT PATH LOAD)
   ***************************************************************/
  declare
   DBFUS_UTL_SQLLOADER_STR CONSTANT VARCHAR2(1000) :=
       'select usecnt, NULL, NULL from sys.ku_utluse                      ' ||
       ' where utlname = ''Oracle Utility SQL Loader (Direct Path Load)'' ' ||
       ' and   (last_used >=                                              ' ||
       '       (SELECT nvl(max(last_sample_date), sysdate-7)              ' ||
       '          FROM dba_feature_usage_statistics))';

  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility SQL Loader (Direct Path Load)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_SQL,
       DBFUS_UTL_SQLLOADER_STR,
       'Oracle Utility SQL Loader (Direct Path Load) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: METADATA API
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Metadata API',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities3',
       'Oracle Utility (Metadata API) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: EXTERNAL TABLE
   ***************************************************************/

  /* As of 12.2 we treat each invocation of external tables according
   * to which access driver is used.  Deprecate this registration of
   * 'Oracle Utility External Table' by setting DBU_DETECT_NULL.
   */
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility External Table',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_NULL,
       'dbms_feature_utilities4',
       'Oracle Utility External Table has been used.');
  end;

  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility External Table (ORACLE_DATAPUMP)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities4',
       'Oracle Utility External Table (ORACLE_DATAPUMP) has been used.');
  end;

  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility External Table (ORACLE_LOADER)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities5',
       'Oracle Utility External Table (ORACLE_LOADER) has been used.');
  end;

  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility External Table (ORACLE_BIGSQL)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities6',
       'Oracle Utility External Table (ORACLE_BIGSQL) has been used.');
  end;
  
  /***************************************************************
   *  RESULT CACHE
   ***************************************************************/
  declare
   DBFUS_RESULT_CACHE_STR CONSTANT VARCHAR2(1000) :=
       'select (select value from v$result_cache_statistics ' ||
       '        where name = ''Block Count Current''), '      ||
       '       (select value from v$result_cache_statistics ' ||
       '        where name = ''Find Count''), null '          ||
       'from dual';

  begin
   dbms_feature_usage.register_db_feature
      ('Result Cache', 
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_SQL,
       DBFUS_RESULT_CACHE_STR,
       'The Result Cache feature has been used.');
  end;

  /************************************** 
   * TDE - Transparent Data Encryption
   **************************************/

  declare 
    DBFUS_TDE_STR CONSTANT VARCHAR2(1000) :=
      'SELECT (T1.A + T2.B) IsFeatureUsed, ' ||
             '(T1.A + T2.B) AUX_COUNT, ' ||
             '''Encryption TABLESPACE Count = '' || T1.A || '','||
               'Encryption COLUMN Count = '' || T2.B REMARK ' ||
      'FROM   (SELECT count(*) A FROM DBA_TABLESPACES WHERE ' ||
                    ' UPPER(ENCRYPTED) = ''YES'') T1, ' ||
             '(SELECT count(*) B FROM DBA_ENCRYPTED_COLUMNS) T2 ' ;
  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Data Encryption',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_TDE_STR,
      'Transparent Database Encryption is being used. There is' || 
      ' atleast one column or tablespace that is encrypted.');
  end;

  /******************* 
   * Data Redaction
   *******************/
  
  /* Bug# 13888340: Data redaction feature usage tracking
   * Related test files are tmfudru.tsc and tmfudr.tsc.
   */
  begin
    dbms_feature_usage.register_db_feature
     ('Data Redaction',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DATA_REDACTION',
      'Data redaction is being used. There is' || 
      ' at least one policy that is defined.');
  end;

  /********************** 
   * Oracle Multimedia
   **********************/

  declare 
    DBFUS_MULTIMEDIA_STR CONSTANT VARCHAR2(1000) := 
      'ordsys.CARTRIDGE.dbms_feature_multimedia';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Multimedia',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'ORDSYS.ORDIMERRORCODES',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_MULTIMEDIA_STR,
      'Oracle Multimedia has been used');
  end;

  /*****************************************************************
   * Oracle Multimedia DICOM: medical imaging 
   * DICOM stands for Digital Imaging and COmmunications in Medicine
   *****************************************************************/

  declare 
    DBFUS_DICOM_STR CONSTANT VARCHAR2(1000) := 
      'ordsys.CARTRIDGE.dbms_feature_dicom';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Multimedia DICOM',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'ORDSYS.ORDDICOM',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DICOM_STR,
      'Oracle Multimedia DICOM (Digital Imaging and COmmunications in Medicine) has been used');
  end;

  /****************************
   * Materialized Views (User)
   ****************************/

  declare
    DBFUS_USER_MVS CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_USER_MVS';

  begin
    dbms_feature_usage.register_db_feature
     ('Materialized Views (User)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_USER_MVS,
      'User Materialized Views exist in the database');
  end;

  /***************************
   * Change Data Capture (CDC) 
   ***************************/
  begin
    dbms_feature_usage.register_db_feature
        ('Change Data Capture',
          dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
          NULL,
          dbms_feature_usage.DBU_DETECT_NULL,
          'DBMS_FEATURE_CDC',
           'Change Data Capture exit in the database');
  end;

  /********************************
   * Services
   *********************************/
  declare
    DBFUS_SERVICES_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_SERVICES';
  begin
    dbms_feature_usage.register_db_feature
     ('Services',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_SERVICES_PROC,
      'Oracle Services.');
  end;

  /***********************
   * Semantics/RDF/OWL
   ***********************/

   declare
     DBFUS_SEMANTICS_RDF_STR CONSTANT VARCHAR2(1000) := 
        'select cnt, cnt, null from ' ||
        ' (select count(*) cnt from mdsys.rdf_model$)';

   begin
     dbms_feature_usage.register_db_feature
       ('Semantics/RDF', 
         dbms_feature_usage.DBU_INST_OBJECT, 
         'MDSYS.RDF_Models',
         dbms_feature_usage.DBU_DETECT_BY_SQL,
         DBFUS_SEMANTICS_RDF_STR,
         'A semantic network has been created indicating usage of the ' ||
         'Oracle Semantics Feature.');
    end;
    
  /***********************
   * SecureFiles (user)
   ***********************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFiles (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SECUREFILES_USR',
       'SecureFiles is being used');
  end;

  /***********************
   * SecureFiles (system)
   ***********************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFiles (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SECUREFILES_SYS',
       'SecureFiles is being used by system users');
  end;

  /*********************************
   * SecureFile Encryption (user)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Encryption (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFENCRYPT_USR',
       'SecureFile Encryption is being used');
  end;

  /*********************************
   * SecureFile Encryption (system)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Encryption (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFENCRYPT_SYS',
       'SecureFile Encryption is being used by system users');
  end;

  /*********************************
   * SecureFile Compression (user)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Compression (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFCOMPRESS_USR',
       'SecureFile Compression is being used');
  end;

  /*********************************
   * SecureFile Compression (system)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Compression (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFCOMPRESS_SYS',
       'SecureFile Compression is being used by system users');
  end;

  /*********************************
   * SecureFile Deduplication (user)
   *********************************/

  begin
    dbms_feature_usage.register_db_feature
     ('SecureFile Deduplication (user)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SFDEDUP_USR',
      'SecureFile Deduplication is being used');
  end;

  /*********************************
   * SecureFile Deduplication (system)
   *********************************/

  begin
    dbms_feature_usage.register_db_feature
     ('SecureFile Deduplication (system)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SFDEDUP_SYS',
      'SecureFile Deduplication is being used by system users');
  end;

  /******************************
   * Segment Advisor
   ******************************/

  declare 
    DBFUS_SEGADV_USER_PROC CONSTANT VARCHAR2(100) := 'DBMS_FEATURE_SEGADV_USER';
  begin
    dbms_feature_usage.register_db_feature
     ('Segment Advisor (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_SEGADV_USER_PROC,
      'Segment Advisor has been used. There is at least one user task executed.');
  end;


  /***************************
   * In-Memory Expressions
   ***************************/

  begin
   dbms_feature_usage.register_db_feature
      ('In-Memory Expressions',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_IM_EXPRESSIONS',
       'In-Memory Expressions or In-Memory Virtual Columns are being used');
  end;

  /***************************
   * In-Memory Join Groups
   ***************************/

  begin
   dbms_feature_usage.register_db_feature
      ('In-Memory Join Groups',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_IM_JOINGROUPS',
       'In-Memory Join Groups are being used');
  end;
  
  /***************************
   * In-Memory ADO Policies
   ***************************/

  begin
   dbms_feature_usage.register_db_feature
      ('In-Memory ADO Policies',
       dbms_feature_usage.DBU_INST_OBJECT,
       'SYS.ILM$',
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_IM_ADO',
       'In-Memory ADO Policies are being used');
  end;
  
  /***********************
   * Compression
   ***********************/

  begin
   dbms_feature_usage.register_db_feature
      ('HeapCompression',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ADV_TABCMP',
       'Heap Compression is being used');
  end;

 /******************************
   * Advanced Index Compression
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Advanced Index Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_ADV_IDXCMP',
      'Advanced Index Compression is used');
  end;

/******************************
   * Index Organized Tables
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Index Organized Tables',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_IOT',
      'Index Organized Tables are being used');
  end;

/******************************
   * In-Memory Column Store
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
     ('In-Memory Column Store',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_IMC',
      'In-Memory Column Store is being used');
  end;

/***************************************
   * In-Memory Distribute For Service (User Defined)
   *************************************/
  begin
    dbms_feature_usage.register_db_feature
     ('In-Memory Distribute For Service (User Defined)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_IM_FORSERVICE',
      'In-Memory Distribute For Service (User Defined) is being used');
  end;


 /******************************
   * Hybrid Columnar Compression
   *****************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Hybrid Columnar Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_HCC',
      'Hybrid Columnar Compression is used');
  end;

 /***************************************************
   * Hybrid Columnar Compression Conventional Load
   ****************************************************/
  begin
    dbms_feature_usage.register_db_feature
    ('Hybrid Columnar Compression Conventional Load',
     dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
     NULL,
     dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
     'DBMS_FEATURE_HCCCONV',
     'Hybrid Columnar Compression with Conventional Load is used');
  end;

 /************************************************
   * Hybrid Columnar Compression Row Level Locking
   **********************************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Hybrid Columnar Compression Row Level Locking',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_HCCRLL',
      'Hybrid Columnar Compression Row Level Locking is used');
  end;

  /*****************************************
    * Information Lifecycle Management (ILM)
    ****************************************/

  begin
    dbms_feature_usage.register_db_feature
      ('Information Lifecycle Management',
       dbms_feature_usage.DBU_INST_OBJECT,
       'SYS.ilm$',
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ILM',
       'Information Lifecycle Management is used');
  end;

  /*****************************************
    * Heat Map
    ****************************************/

  begin
    dbms_feature_usage.register_db_feature
      ('Heat Map',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_HEATMAP',
       'Heat Map is used');
  end;


  /******************************
    * ZFS Storage
    ******************************/
  begin
    dbms_feature_usage.register_db_feature
      ('ZFS Storage',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ZFS_STORAGE',
       'Tablespaces stored on Oracles Sun ZFS Storage');
  end;

  /******************************
    * Pillar Storage
    ******************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Pillar Storage',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_PILLAR_STORAGE',
       'Tablespaces stored on Oracles Pillar Axiom Storage');
  end;

  /******************************
    * ZFS Storage + EHCC
    *****************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Sun ZFS with EHCC',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ZFS_EHCC',
       'EHCC used on tablespaces stored on Oracles Sun ZFS Storage');
  end;

  /******************************
    * Pillar Storage + EHCC
    *****************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Pillar Storage with EHCC',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_PILLAR_EHCC',
       'EHCC used on tablespaces stored on Oracles Pillar Axiom Storage');
  end;

  /******************************
    * Cloud + EHCC
    *****************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Cloud DB with EHCC',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_CLOUD_EHCC',
       'EHCC used for Cloud Database');
  end;

  /******************************
   * Segment Shrink
   ******************************/

  declare 
    DBFUS_SEG_SHRINK_STR CONSTANT VARCHAR2(1000) :=
      'select  count(*), 0, null ' ||
        'from  sys.seg$ s ' ||
        'where s.scanhint != 0 and ' ||
              'bitand(s.spare1, 65793) = 257 and ' ||
              's.type# in (5, 6,8) ';
  begin
    dbms_feature_usage.register_db_feature
     ('Segment Shrink',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SEG_SHRINK_STR,
      'Segment Shrink has been used.');
  end;

  /***************************
   * Job Scheduler 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Job Scheduler',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_JOB_SCHEDULER',
      'Job Scheduler feature is being used.');
  end;

  /***************************
   * Orcle Gateways
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Gateways',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_GATEWAYS',
      'Gateways feature is being used.');
  end;

  /*******************************
   * Java Virtual Machine (user)
   *******************************/

  declare 
    DBFUS_OJVM_STR CONSTANT VARCHAR2(1000) := 
      'sys.dbms_java.dbms_feature_ojvm';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Java Virtual Machine (user)',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'SYS.JAVA$POLICY$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_OJVM_STR,
      'OJVM has been used by at least one non-system user');
  end;

  /*********************************
   * Java Virtual Machine (system)
   *********************************/

  declare 
    DBFUS_OJVM_SYS_STR CONSTANT VARCHAR2(1000) := 
      'sys.dbms_java.dbms_feature_system_ojvm';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Java Virtual Machine (system)',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'SYS.JAVA$POLICY$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_OJVM_SYS_STR,
      'OJVM default system users');
  end;
  
  /**********************
   * In-Database Hadoop
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle In-Database Hadoop',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'SYS.JAVA$POLICY$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_IDH',
      'In-Database Hadoop for running MapReduce in java');
  end;


  /************************
   * DBFS Content
   ************************/

  declare 
    DBFUS_DBFS_CONTENT_PROC CONSTANT VARCHAR2(1000) := 
      'sys.dbms_feature_dbfs_content';

  begin
    dbms_feature_usage.register_db_feature
     ('DBFS Content',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DBFS_CONTENT_PROC,
      'Oracle Database FileSystem Content feature is being used');
  end;

  /************************
   * DBFS SecureFile Store
   ************************/ 

  declare 
    DBFUS_DBFS_SFS_PROC CONSTANT VARCHAR2(1000) := 
      'sys.dbms_feature_dbfs_sfs';

  begin
    dbms_feature_usage.register_db_feature
     ('DBFS SFS',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DBFS_SFS_PROC,
      'Oracle Database FileSystem SecureFile Store feature is being used');
  end;

  /**************************
   * DBFS Hierarchical Store
   **************************/ 

  declare 
    DBFUS_DBFS_HS_PROC CONSTANT VARCHAR2(1000) := 
      'sys.dbms_feature_dbfs_hs';

  begin
    dbms_feature_usage.register_db_feature
     ('DBFS HS',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DBFS_HS_PROC,
      'Oracle Database FileSystem Hierarchical Store feature is being used');
  end;

  /******************************
   * EXADATA
   ******************************/

  declare 
    DBFUS_EXADATA_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_EXADATA';

  begin
    dbms_feature_usage.register_db_feature
     ('Exadata',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_EXADATA_PROC,
      'Exadata is being used');
  end;

  /**************************
   * GSM CATALOG
   *************************/
   
   declare
     DBFUS_GSMCAT_STR CONSTANT VARCHAR2(1000) :=
        'select count(*), 0, NULL from gsmadmin_internal.cloud ' ||
        'where database_flags = ''C''';

   begin
    dbms_feature_usage.register_db_feature
     ('GDS Catalog',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_GSMCAT_STR,
      'Database is a GDS catalog database.');
   end;
   
  /**************************
   * GSM GLOBAL SERVICES
   *************************/
   
   declare
     DBFUS_GSMGLOB_STR CONSTANT VARCHAR2(1000) :=
        'select count(*), 0, NULL from dba_services ' ||
        'where global_service = ''YES''';

   begin
    dbms_feature_usage.register_db_feature
     ('Global Data Services',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_GSMGLOB_STR,
      'Database contains global services.');
   end;

  /**************************
   * SYSTEM SHARDING CATALOG
   *************************/
  
  declare
    DBFUS_SYSSHDCAT_STR CONSTANT VARCHAR2(1000) :=
       'select count(*), 0, NULL from gsmadmin_internal.cloud gc, v$parameter vp ' ||
       'WHERE gc.sharding_type in (1,2,3) and vp.name = ''_gws_deployed'' ' ||
       'and vp.value = 2 and gc.database_flags = ''C'''; 
  begin
    dbms_feature_usage.register_db_feature 
     ('Sharding Catalog',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SYSSHDCAT_STR,
      'Database is a Sharding Catalog.');
  end;


  /**************************
   * SHARD DATABASE
   *************************/
  
  declare
    DBFUS_SHARD_STR CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_SHARD';
  begin
   dbms_feature_usage.register_db_feature 
    ('Shard Database',
     dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
     NULL,
     dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
     DBFUS_SHARD_STR,
     'Database is a Shard.');
  end;

  /*************************************
   * Real Application Security
   *************************************/
  
  declare
    DBFUS_RAS_STR CONSTANT VARCHAR2(1000) := 'SYS.DBMS_FEATURE_RAS';
    
  begin
    dbms_feature_usage.register_db_feature
     ('Real Application Security',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.XS$OBJ',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_RAS_STR,
      'Oracle Real Application Security is being used');
  end;

  /**********************
   * Privilege Capture  *
   **********************/

  declare
    DBFUS_PRIV_CAPTURE_PROC CONSTANT VARCHAR2(1000) := 
      'SYS.DBMS_FEATURE_PRIV_CAPTURE';

  begin
    dbms_feature_usage.register_db_feature
     ('Privilege Capture',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PRIV_CAPTURE_PROC,
      'Privilege Capture is being used');
  end;

 /****************************
   * Online Redefintion
   ****************************/

  declare
    DBFUS_ONLINE_REDEF CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_ONLINE_REDEF';

  begin
    dbms_feature_usage.register_db_feature
     ('Online Redefinition',
       dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.REDEF$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ONLINE_REDEF,
      'Online Redefinition is being used');
  end;

  /***************************************************************
   *  In-Memory Aggregation
   ***************************************************************/

  begin
   dbms_feature_usage.register_db_feature
      ('In-Memory Aggregation',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_IMA',
       'In-Memory Aggregation is being used.');
  end;


  /******************************
   * In-Memory FastStart
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
     ('In-Memory FastStart',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_IMFS',
      'In-Memory FastStart is being used');
  end;


  /*********************************************
   * TEST features to test the infrastructure 
   *********************************************/

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 1, 0, NULL from dual',
      'Test sql 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 10, to_clob(''hi, mike'') from dual',
      'Test sql 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 13, NULL, to_clob(''hello, mike'') from dual',
      'Test sql 3');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_4',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 11, 11, to_clob(''test sql 4 check tab$'') from dual',
      'Test sql 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_5',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.foo',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 2, 0, to_clob(''check foo'') from dual',
      'Test sql 5');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_6',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 0, to_clob(''should not see'') from dual',
      'Test sql 6');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_7',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      'junk',
      'Test sql 7');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_8',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 8 - Test error case');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_9',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'test.test',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 9 - Test error case for install');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_10',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.dbu_test_table',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select count(*), count(*), max(letter) from dbu_test_table',
      'Test sql 10 - Test infrastructure');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_1',
      'Test feature 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_2',
      'Test feature 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'Junk Procedure',
      'Test feature 3 - Bad procedure name');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_4',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_4',
      'Test feature 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_5',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_5',
      'Test feature 5');

  /*********************************************
   * Transparent Sensitive Data Protection (TSDP) 
   ********************************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Sensitive Data Protection',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TSDP',
      'Transparent Sensitive Data Protection (TSDP)');
  end;

  /*********************************************
   * Segment Maintenance Online Compress 
   ********************************************/
  begin
    dbms_feature_usage.register_db_feature
     ('Segment Maintenance Online Compress',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SEG_MAIN_ONL_COMP',
      'Segment Maintenance Online Compress');
  end;

  /**************************
   * EM Express
   **************************/
  begin
    dbms_feature_usage.register_db_feature
     ('EM Express',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'sys.wri$_emx_files',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_EMX',
      'EM Database Express has been used');
  end;

  /*********************************************
   * BA Owner 
   ********************************************/
  declare
    DBMS_FEATURE_BA_OWNER_STR CONSTANT VARCHAR2(1000) := 
       'DBMS_FEATURE_BA_OWNER';
  begin
    dbms_feature_usage.register_db_feature
     ('BA Owner',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBMS_FEATURE_BA_OWNER_STR,
      'BA OWNER');
   end;

  /****************************** 
   * INSTANT RESTORE command
   *********************************/
  declare
    DBFUS_INSTANT_RES_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation like ''RESTORE INSTANT%'')';
  begin
    dbms_feature_usage.register_db_feature
     ('INSTANT RESTORE command',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_INSTANT_RES_STR,
      'RMAN''s INSTANT RESTORE command used by the database.');
  end;

  /****************************** 
   * Container Usage
   *********************************/
  declare
    DBFUS_CONTAINER_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from sys.amgrp$)'; 
  begin
    dbms_feature_usage.register_db_feature
     ('Container Usage',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CONTAINER_STR,
      'CONTAINER FILES used by backup appliance.');
  end;

  /********************************************** 
   * Client Result Cache
   **********************************************/

  declare 
    DBFUS_CRC_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from CRC$_RESULT_CACHE_STATS '
      || 'where cache_ID = 0 and stat_id = 2';

  begin
    dbms_feature_usage.register_db_feature
     ('Client Result Cache',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CRC_STR,
      'Client Result Cache has been enabled');
  end;


  /********************************************** 
   * Application Continuity
   **********************************************/

  declare 
    DBFUS_APC_STR CONSTANT VARCHAR2(1000) := 
      'select max(ksuzsal), NULL, NULL from x$ksuzsa where ksuzsal != 0';

  begin
    dbms_feature_usage.register_db_feature
     ('Application Continuity',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_APC_STR,
      'Application Continuity has been enabled');
  end;


end;
/
show errors; 

Rem ************************************
Rem     High Water Mark Registration
Rem ************************************

create or replace procedure DBMS_FEATURE_REGISTER_ALLHWM
as
begin

  /**************************
   * User Tables
   **************************/

  declare 
    HWM_USER_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.tab$ t, sys.obj$ o ' ||
       'where t.obj# = o.obj# ' ||
         'and bitand(t.property, 1) = 0 ' ||
         'and bitand(o.flags, 128) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_TABLES_STR,
      'Number of User Tables');
  end;

  /**************************
   * Segment Size 
   **************************/

  declare 
    HWM_SEG_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select max(bytes) from dba_segments';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SEGMENT_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SEG_SIZE_STR,
      'Size of Largest Segment (Bytes)');
  end;

  /**************************
   * Partition Tables
   **************************/

  declare 
    HWM_PART_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 2 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_TABLES_STR,
      'Maximum Number of Partitions belonging to an User Table');
  end;

  /**************************
   * Partition Indexes
   **************************/

  declare 
    HWM_PART_INDEXES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 1 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_INDEXES_STR,
      'Maximum Number of Partitions belonging to an User Index');
  end;

  /**************************
   * User Indexes
   **************************/

  declare 
    HWM_USER_INDEX_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ind$ i, sys.obj$ o ' ||
       'where i.obj# = o.obj# ' ||
         'and bitand(i.flags, 4096) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_INDEX_STR,
      'Number of User Indexes');
  end;

  /**************************
   * Sessions
   **************************/

  declare 
    HWM_SESSIONS_STR CONSTANT VARCHAR2(1000) := 
      'select sessions_highwater from V$LICENSE';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SESSIONS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SESSIONS_STR,
      'Maximum Number of Concurrent Sessions seen in the database');
  end;

  /**************************
   * DB Size
   **************************/

  declare 
    HWM_DB_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select sum(bytes) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DB_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DB_SIZE_STR,
      'Maximum Size of the Database (Bytes)');
  end;

  /**************************
   * Datafiles
   **************************/

  declare 
    HWM_DATAFILES_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DATAFILES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DATAFILES_STR,
      'Maximum Number of Datafiles');
  end;

  /**************************
   * Tablespaces
   **************************/

  declare 
    HWM_TABLESPACES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ts$ ts ' ||
       'where ts.online$ != 3 ' ||
         'and bitand(ts.flags, 2048) != 2048';

  begin
    dbms_feature_usage.register_high_water_mark
     ('TABLESPACES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_TABLESPACES_STR,
      'Maximum Number of Tablespaces');
  end;

  /**************************
   * CPU count
   **************************/

  declare 
    HWM_CPU_COUNT_STR CONSTANT VARCHAR2(1000) := 
      'select sum(cpu_count_highwater) from gv$license';

  begin
    dbms_feature_usage.register_high_water_mark
     ('CPU_COUNT',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_CPU_COUNT_STR,
      'Maximum Number of CPUs');
  end;

  /**************************
   * Query Length
   **************************/

  declare 
    HWM_QUERY_LENGTH_STR CONSTANT VARCHAR2(1000) := 
      'select max(maxquerylen) from v$undostat';

  begin
    dbms_feature_usage.register_high_water_mark
     ('QUERY_LENGTH',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_QUERY_LENGTH_STR,
      'Maximum Query Length');
  end;

  /****************************** 
   * National Character Set Usage
   *******************************/

  declare 
    HWM_NCHAR_COLUMNS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from col$ c, obj$ o ' ||
      ' where c.charsetform = 2 and c.obj# = o.obj# ' ||
      ' and o.owner# not in ' || 
      ' (select distinct u.user_id from all_users u, ' ||
      ' sys.ku_noexp_view k where (k.OBJ_TYPE=''USER'' and ' ||
      ' k.name=u.username) or (u.username=''SYSTEM'')) ' ;

  begin
    dbms_feature_usage.register_high_water_mark
     ('SQL_NCHAR_COLUMNS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_NCHAR_COLUMNS_STR,
      'Maximum Number of SQL NCHAR Columns');
  end;
  
  /********************************
   * Instances
   *********************************/
  declare
    HWM_INSTANCES_STR CONSTANT VARCHAR2(1000) := 
      'SELECT count(*) FROM gv$instance';
  begin
    dbms_feature_usage.register_high_water_mark
     ('INSTANCES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_INSTANCES_STR,
      'Oracle Database instances');
  end;

  /****************************
   * Materialized Views (User)
   ****************************/

  declare
    HWM_USER_MV_STR CONSTANT VARCHAR2(1000) :=
     'select count(*) from dba_mviews ' ||
       'where owner not in (''SYS'',''SYSTEM'', ''SH'')';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_MV',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_MV_STR,
      'Maximum Number of Materialized Views (User)');
  end;


  /*******************
   * Active Sessions
   *******************/

  declare
    HWM_ACTIVE_SESSIONS_STR CONSTANT VARCHAR2(1000) :=
     'select max(value) from v$sysmetric_history ' ||
       'where metric_name = ''Average Active Sessions''';

  begin
    dbms_feature_usage.register_high_water_mark
     ('ACTIVE_SESSIONS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_ACTIVE_SESSIONS_STR,
      'Maximum Number of Active Sessions seen in the system');
  end;

  /*******************
   * DBMS_SCHEDULER   HWM is number of jobs per day
   *******************/

   declare 
     HWM_DBMS_SCHEDULER_STR CONSTANT VARCHAR2(1000) := 
       'select '||
         'round(max(runs*((max_id-min_id)/2 + 1)/tot),0) '||
       'from '||
         '( select '||
             'trunc(log_date) day, '||
             'max(log_id) max_id, '||
             'min(log_id) min_id, '||
             'count(log_id) tot, '||
             'count(case when operation = ''RUN'' then 1 end) runs '||
           'from '||
             'scheduler$_event_log '||
           'where '||
             'log_date > systimestamp - interval ''8'' day '||
           'group by trunc(log_date) '||
          ')' ;
   begin
     dbms_feature_usage.register_high_water_mark
      ('HWM_DBMS_SCHEDULER',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_DBMS_SCHEDULER_STR,
       'Number of job runs per day');
   end;

  /*******************
   * Exadata
   *******************/

   declare 
     HWM_EXADATA_STR CONSTANT VARCHAR2(1000) := 
        'select replace(substr(statistics_value, 23), ''</nphysicaldisks_stats>'') from gv$cell_state where statistics_type = ''NPHYSDISKS''';
   begin
     dbms_feature_usage.register_high_water_mark
      ('EXADATA_DISKS',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_EXADATA_STR,
       'Number of physical disks');
   end;
   
  /************************
   * GSM Global services
   ***********************/
   
   declare 
     HWM_GSM_STR CONSTANT VARCHAR2(1000) := 
        'select count(*) from dba_services ' ||
        'where global_service = ''YES''';
   begin
     dbms_feature_usage.register_high_water_mark
      ('GLOBAL SERVICES',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_GSM_STR,
       'Number of global services');
   end;

  /************
   * Shards 
   ***********/

   declare
     DBMS_HWM_SHARDS_STR CONSTANT VARCHAR2(1000) := 
       'DBMS_HWM_SHARDS';
   begin
     dbms_feature_usage.register_high_water_mark
      ('SHARDS',
       dbms_feature_usage.DBU_HWM_BY_PROCEDURE,
       DBMS_HWM_SHARDS_STR,
       'Number of deployed shards in catalog');
   end;

  /*******************
   * Primary Shards 
   ******************/

   declare
     DBMS_HWM_PRIM_SHARDS_STR CONSTANT VARCHAR2(1000) := 
       'DBMS_HWM_PRIM_SHARDS';
   begin
     dbms_feature_usage.register_high_water_mark
      ('PRIMARY SHARDS',
       dbms_feature_usage.DBU_HWM_BY_PROCEDURE,
       DBMS_HWM_PRIM_SHARDS_STR,
       'Number of deployed primary shards in catalog');
   end;

  /************************
   * Flex ASM
   ***********************/

   declare
     HWM_FLX_STR CONSTANT VARCHAR2(1000) :=
        'select sys_context(''SYS_CLUSTER_PROPERTIES'',''FLEXASM_STATE_HW'') '||
        'from dual';
   begin
     dbms_feature_usage.register_high_water_mark
      ('Flex ASM',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_FLX_STR,
       'Number of completed and successful failovers');
   end;

  /**************************
   * Test HWM
   **************************/

  declare 
    HWM_TEST_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_TEST_PROC_3';

  begin
    dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_1',
      dbms_feature_usage.DBU_HWM_BY_PROCEDURE +
      dbms_feature_usage.DBU_HWM_TEST,
      HWM_TEST_PROC,
      'Test HWM 1');
  end;

  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_2',
      dbms_feature_usage.DBU_HWM_NULL +
      dbms_feature_usage.DBU_HWM_TEST,
      'Junk',
      'Test HWM 2');
  
  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_3',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 10 from dual',
      'Test HWM 3');

  dbms_feature_usage.register_high_water_mark  
     ('_HWM_TEST_4',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 1240 from foo',
      'Test HWM 4 - Error case');

end;
/
show errors; 

@?/rdbms/admin/sqlsessend.sql
