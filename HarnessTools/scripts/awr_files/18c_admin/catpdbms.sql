Rem
Rem catpdbms.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpdbms.sql - CATProc DBMS_ package specifications
Rem
Rem    DESCRIPTION
Rem      This script creates package specifications, and standalone procedures
Rem      and functions
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpdbms.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpdbms.sql
Rem SQL_PHASE: CATPDBMS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    miglees     11/27/17 - XbranchMerge miglees_bug-27051964 from main
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    miglees     11/05/17 - Bug 27051964: Remove dbmsmemoptimizeadmin.sql
Rem    surman      11/01/17 - 26281129: Support for new release model
Rem    alestrel    09/10/17 - Bug 25992938. Add dbms_isched_utl header
Rem    alestrel    06/08/17 - Bug 25992935. Include dbms_isched_agent package
Rem                           header
Rem    kshergil    06/04/17 - 25632497: add dbmsmemoptimizeadmin
Rem    yuyzhang    04/27/17 - proj# 54799: add prvtstataggs.plb and move
Rem                           prvtstas.plb to catpspec.sql
Rem    pjulsaks    04/05/17 - Bug 25773902: change dbmspdb_altshr to dbmsappcon
Rem    cwidodo     03/27/17 - #(25410921): add prvtols.plb
Rem    surman      03/20/17 - 25616945: Add SQL_DRIVER_ONLY
Rem    sursridh    03/06/17 - Bug 25683998: Remove dbmspen.sql invocation.
Rem    sursridh    01/26/17 - Add support for PDB events framework.
Rem    shvmalik    01/10/17 - #25035608: revert back FCP txn
Rem    jaeblee     12/20/16 - bug #25295968: add setpdb.sql
Rem    aarvanit    11/07/16 - bug #24966761: add dbmssqls, remove dbmssqlt
Rem    drosash     07/05/16 - bug #23598713: add prvthpclxi.plb
Rem    shvmalik    06/30/16 - #23721669: add FCP package spec dbmsfcp.sql
Rem    sramakri    06/10/16 - remove CDC from 12.2
Rem    aarvanit    05/02/16 - bug #22271179: remove dbmssqlu.sql
Rem    schakkap    03/16/16 - #(22029499) move prvtstatadv from catpprvt to
Rem                           catpdbms
Rem    osuro       02/18/16 - add dbmsmb.sql
Rem    akruglik    12/02/15 - (21953121) add dbmspdb_altshr.sql
Rem    yulcho      12/02/15 - add application resilence api
Rem    thbaby      11/09/15 - bug 22157044: catfedcdbviews -> catappcdbviews
Rem    welin       10/12/15 - bug 21978311: move prvthpp.plb to later phase to
Rem                           avoid deadlock
Rem    zhcai       09/29/15 - Proj 47332: Add prvsemx_sql
Rem    raeburns    09/18/15 - RTI 16218614: move catfedcdbviews.sql
Rem    sudurai     09/17/15 - Bug 21805805: Changing DBMS_CRYPTO_STATS_INT to
Rem                           DBMS_CRYPTO_INTERNAL
Rem    sogugupt    09/11/15 - Bug 19814527: Add dbmsdpmt.sql file 
Rem    jerrede     09/10/15 - Bug 21817856: Timeout issues Moved
Rem                           prvthesh.plb,dbmsol.sql and dbmsrsa.sql
Rem                           to a serial phase as they were deadlocking
Rem                           with each other and dbmsmeta.sql.
Rem                           dbmssol.sql deadlock with dbmsrsa.sql
Rem                           and prvthesh.plb deadlock with dbmsmeta.sql.
Rem    sudurai     06/23/15 - Bug 21258745: Moving APIs from
Rem                           DBMS_STATS_INTERNAL -> DBMS_CRYPTO_STATS_INT
Rem    amunnoli    06/16/15 - Proj 46892: Move dbmsaudutl.sql to catuat.sql
Rem    mahrajag    05/21/15 - Add code coverage package
Rem    rajeekku    03/13/15 - Proj 46762 : Add DBMS_TNS
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    bnnguyen    12/29/14 - bug 19697038: Add dbmsaclsrv.sql
Rem    beiyu       12/04/14 - Proj 47091: add dbmsodbo.sql and dbmshier.sql
Rem    hoyao       11/23/14 - add dbcompare
Rem    cqi         11/18/14 - add dbmshmgr.sql
Rem    jiayan      09/15/14 - Switch calls to dbmsstat and prvtstas
Rem    jlingow     09/05/14 - proj-58146 include dbms_isched_remote_access 
Rem                           package header
Rem    kdnguyen    09/03/14 - add dbmsinmemadmin.sql
Rem    yxie        08/22/14 - proj 47332: add prvsemx_rsrcmgr
Rem    spapadom    08/18/14 - Added Unified Manageability Framework pkg specs.
Rem    nkgopal     07/30/14 - Proj 35931: Add DBMS_AUDIT_UTIL
Rem    mthiyaga    07/11/14 - Add dbmshadp.sql
Rem    surman      06/05/14 - Backport surman_bug-17277459 from main
Rem    sagrawal    03/19/14 - Polymorphic Table Functions
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    lbarton     10/17/13 - bug 17621089: add prvthpexpi.plb
Rem    miglees     08/21/13 - Add dbmsinmem.sql
Rem    lvbcheng    08/20/13 - 17356189: remove KKXHTMLDB testing only pkg
Rem    surman      08/02/13 - 17005047: Add dbms_sqlpatch
Rem    cgervasi    06/19/13 - add prvsemx_cell.plb
Rem    jerrede     06/20/13 - Fix Dependency issues dbmsslrt before dbmsgwm.
Rem    vgokhale    05/03/13 - XbranchMerge vgokhale_bug-14121009_11.2.0.4.0_1
Rem                           from st_rdbms_11.2.0
Rem    elu         02/21/13 - remove dbmsobj.sql
Rem    arbalakr    01/31/13 - Backport add cpaddm and rtaddm packages
Rem    elu         12/21/12 - move dbmsrepl after dbmsobj
Rem    cgervasi    08/03/12 - add dbmsperf
Rem    alui        07/22/12 - move dbmswlm.sql for RM dependency
Rem    jerrede     05/08/12 - Fix lrg 6730954 Definition problem in Windows
Rem                           with moving from phase to phase need to restart
Rem                           between all phases
Rem    rpang       04/17/12 - Move dbmanacl.sql for xs dependency
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     03/12/12 - Add dbmsratmask.sql for RAT masking
Rem    shjoshi     02/27/12 - Add prvsautorepi.sql
Rem    rpang       02/02/12 - Network ACL triton migration
Rem    arbalakr    01/15/12 - add cpaddm packages
Rem    tbhukya     12/22/11 - Add dbmsqopi.sql
Rem    dgraj       09/27/11 - Project 32079: Add Script for TSDP
Rem    jerrede     12/12/11 - Add Comments for Parallel Upgrade
Rem    bdagevil    12/10/11 - move dbmsrep.sql to catpspec.sql since
Rem                           prvsemx_admin depends on it
Rem    yxie        12/09/11 - add prvsemx_perf
Rem    sursridh    12/07/11 - bug 13425408: move dbmspdb creation up in the
Rem                           order.
Rem    cgervasi    12/07/11 - add prvtemx_memory
Rem    snadhika    11/14/11 - Added xssess.sql
Rem    dgraj       11/04/11 - Bug 13243011: Remove call to dbmslink.sql
Rem    cslink      10/10/11 - Remove dbmsradma.sql
Rem    jerrede     10/06/11 - Fix lrg 5829047 Dependency Warning Errors
Rem    skabraha    09/27/11 - move utlrcmp invocation to catpspec
Rem    kyagoub     09/24/11 - add prvsemx_dbhome.plb
Rem    cslink      09/19/11 - Add dbmsredacta.sql for rename of RADM API to
Rem                           REDACT
Rem    geadon      09/08/11 - add DBMS_PART
Rem    sslim       09/01/11 - Add dbmsrupg.sql, prvtrupgis.plb
Rem    jerrede     09/08/11 - Parallel Upgrade Project #23496 run
Rem                           dbmsmeti.sql and dbmsmetu.sql outside of
Rem                           catmettypes.sql
Rem    sslim       09/01/11 - Add dbmsrupg.sql, prvtrupgis.plb
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    hayu        08/29/11 - add dbmssqlm.sql
Rem    cgervasi    07/20/11 - add awr viewer
Rem    hosu        07/18/11 - move prvtstas.sql from catpdbms to catpsepc
Rem    bdagevil    07/17/11 - add prvsrepr.plb
Rem    yiru        07/08/11 - Move xsprin.sql to catpspec.sql
Rem    shiyadav    06/06/11 - add dbmsadra.sql and prvsadri.plb
Rem    bdagevil    06/05/11 - add prvtemx_admin
Rem    jheng       06/02/11 - Proj 32973: move catprofp to the beginning
Rem    msusaira    07/04/10 - add dbmsfs
Rem    jheng       02/28/11 - add catprofp.sql
Rem    schakkap    05/05/11 - project SPD (31794): add Sql Plan Directive
Rem                           package specs
Rem    yxie        04/28/11 - add em express package
Rem                           prvsemxi
Rem    mjstewar    04/26/11 - Add GSM
Rem    traney      03/20/11 - add utlcstk.sql
Rem    sroesch     02/09/11 - add dbmsappcont.sql for application continuity
Rem    gravipat    01/26/11 - DB Consolidation: Add dbmspdb.sql
Rem    rpang       01/07/11 - Add DBMS_SQL_TRANSLATOR
Rem    pknaggs     12/21/10 - RADM: add dbmsradma.sql for data masking API
Rem    lbarton     09/09/10 - move prvtdput from catdph.sql to catpdbms.sql
Rem    srirkris    10/10/13 - Remove dbmssjty.sql
Rem    weihwang    08/28/09 - Added xs_diag package
Rem    yiru        08/17/09 - move triton security package xsutil.sql (with 
Rem                           dependents) to catpspec.sql
Rem    snadhika    07/23/09 - add triton admin packages
Rem    msusaira    06/09/09 - Add prvtdnfs
Rem    amullick    06/15/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove dbmsam.sql
Rem    mfallen     04/14/09 - add dbmsadr.sql
Rem    mbastawa    03/17/09 - add prvthcrc.sql
Rem    dalpern     03/17/09 - bug 7646876: applying_crossedit... (drop dbmscet)
Rem    amullick    01/22/09 - Archive provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    yurxu       12/04/08 - Disable IAS
Rem    rbhatti     04/24/08 - Reverting changes from rbhatti_xs_bug_6782472 txn
Rem    shiyer      03/26/08 - Remove TSM packages
Rem    lbarton     04/15/08 - bug 6969874: move mdapi compare APIs to their own
Rem                           package
Rem    huagli      11/27/07 - add dbmsdst
Rem    ssvemuri    03/27/08 - Archive Manager catalog tables
Rem    rbhatti     02/02/08 - bug 6782472- moved dbmskzxp.sql
Rem    ilistvin    01/31/08 - add prvsawri.plb, prvsawrs.plb
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT package spec
Rem    amitsha     12/27/07 - add dbmscomp for dbms_compression
Rem    achoi       11/13/07 - add DBMS_PARALLEL_EXECUTE
Rem    achoi       11/13/07 - add DBMS_CROSSEDITION_TRIGGER
Rem    adalee      09/20/07 - add dbmscu.sql
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    skabraha    05/25/07 - add dbmsobj
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    skabraha    05/25/07 - add dbmsobj
Rem    ushaft      04/23/07 - add prvssmgu
Rem    hosu        02/27/07 - add prvssmbi, prvssmb and prvsspmi 
Rem    jsamuel     11/29/06 - added dbmskzxp
Rem    pbelknap    01/12/07 - add prvssqlf
Rem    ushaft      01/03/07 - add dbmsmp
Rem    rburns      01/06/07 - final catproc cleanup
Rem    jkundu      01/09/07 - add prvtlmes.plb
Rem    rdongmin    01/09/07 - add dbmssqlt and dbmsdiag 
Rem    ilistvin    11/16/06 - add dbmsspm.sql
Rem    ilistvin    11/15/06 - move dbmsadv to catpspec.sql
Rem    ilistvin    11/09/06 - 
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/02/06 - add dbmsstr
Rem    elu         10/23/06 - add replication package specs
Rem    achoi       08/27/06 - replace dbmsptch with dbmsedu 
Rem    kkunchit    09/05/06 - dbms_lobutil support
Rem    rburns      08/23/06 - more restructuring
Rem    eshirk      07/14/06 - Add private_jdbc package 
Rem    cdilling    08/03/06 - add dbmsadv.sql,dbmsaddm.sql
Rem    rburns      07/26/06 - add more package specs 
Rem    sourghos    06/07/06 - add WLM package specs 
Rem    mjstewar    05/25/06 - IR integration 
Rem    chliang     05/19/06 - add sscr package spec
Rem    dkapoor     06/19/06 - OCM integration 
Rem    kamsubra    05/19/06 - Adding prvtkpps.plb 
Rem    nkarkhan    05/26/06 - Project 19620: Add support for application
Rem                           initiated Fast-Start Failover.
Rem    kneel       06/05/06 - moving execution of prvthdbu to catpdeps.sql 
Rem    kneel       06/04/06 - moving execution of dbmshae.sql to catpdeps.sql 
Rem    kneel       06/03/06 - moving execution of prvthdbu.sql to catpdbms.sql 
Rem    kneel       06/01/06 - add dbmshae.sql 
Rem    jklein      06/07/06 - add sql_toolkit cat script
Rem    kmuthukk    05/18/06 - Add dbms_hprof package 
Rem    rburns      05/24/06 - add dbms_alert 
Rem    rburns      05/19/06 - add queue files 
Rem    bkuchibh    05/17/06 - add dbmshm.sql 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem **********************************************************************
Rem 
Rem  NOTE: SQL CODE NOT PERMITTED IN THIS FILE ONLY THE EXECUTION OF A
Rem       .SQL or .PLB file.
Rem
Rem **********************************************************************

Rem
Rem PL/SQL packages
Rem
@@utlinad.sql
@@utlsmtp.sql
@@utlurl.sql
@@utlenc.sql
@@utlgdk.sql
@@utlcstk.sql
@@utlcomp.sql
@@utli18n.sql
@@utllms.sql

Rem
Rem PL/SQL warning settings
Rem
@@dbmsplsw.sql

Rem
Rem PL/SQL linear algebra support
Rem
@@utlnla.sql

Rem
Rem PDB data manipulation pacckage
Rem
@@dbmspdb.sql
@@dbmsappcon.sql

@@dbmstrns.sql
@@dbmsrwid.sql

Rem
Rem DBMS_PCLXUTIL package spec
Rem
@@dbmspclx.sql
@@prvthpclxi.plb

@@dbmserlg.sql
@@dbmsspu.sql


Rem 
Rem pl/sql packages used for rdbms functionality
Rem
@@dbmsapin.sql
@@dbmssyer.sql
@@dbmspipe.sql
@@dbmsalrt.sql
@@dbmsdesc.sql
@@prvthpexpi.plb
@@dbmspexp.sql
@@dbmsjob.sql
@@prvtstataggs.plb
@@prvtstatadv.plb
@@dbmsstts.sql
@@dbmsddl.sql
@@dbmsedu.sql
@@dbmspp.sql
@@prvthddl.plb
@@prvthjob.plb
@@prvthsye.plb
@@prvtzhlp.plb

Rem
Rem Hierarchical Cube Sql (HCS) packages
Rem
@@dbmsodbo.sql
@@dbmshier.sql

Rem
Rem Index Rebuild
Rem
@@dbmsidxu.sql
@@prvthidx.plb

Rem
Rem PL/SQL Server Pages package
Rem
@@dbmspsp.sql
@@dbmstran.sql

Rem
Rem package for XA PL/SQL APIs
Rem
@@dbmsxa.sql

Rem
Rem Transformations
Rem
@@dbmstxfm.sql

Rem
Rem Rules engine
Rem
@@dbmsread.sql
@@prvtreut.plb

Rem
Rem Probe packages
Rem
@@dbmspb.sql

Rem
Rem PL/SQL trace packages
Rem
@@dbmspbt.sql

Rem
Rem Transportabel tablespaces
Rem
@@dbmsplts.sql

Rem
Rem dbms_pitr package spec
Rem
@@dbmspitr.sql

Rem
Rem pl/sql package for REFs (UTL_REF)
Rem
@@utlrefld.sql

Rem
Rem pl/sql package for COLLs (UTL_COLL)
Rem
@@utlcoll.plb

Rem
Rem pl/sql package for distributed trust administration (trusted list admin)
Rem
@@dbmstrst.sql

Rem
Rem Row Level Security package
Rem
@@dbmsrlsa.sql

Rem
Rem Data/Index Repair Package
Rem
@@dbmsrpr.sql

Rem
Rem Obfuscation (encryption) toolkist
Rem
@@dbmsobtk.sql

Rem
Rem package specs for Redo LogMiner
Rem
@@dbmslm.sql
@@dbmslmd.sql
@@prvtlmes.plb

Rem
Rem UTL_XML: PL/SQL wrapper around CORE LPX facility: C-based XML/XSL parsing
Rem
@@utlcxml.sql

Rem
Rem Script for Fine Grained Auditing
Rem
@@dbmsfga.sql

Rem
Rem Script for DBMS_AUDIT_MGMT
Rem
@@dbmsamgt.sql

Rem
Rem Type Utility
Rem
@@dbmstypu.sql

Rem
Rem package for Resumable and ora_space_error_info attribute function
Rem
@@dbmsres.sql

Rem
Rem package for transaction layer internal functions
Rem
@@dbmstxin.sql

Rem
Rem SQLJ Object Type support
Rem Data Guard recovery framework support (dbms_drs & dbms_dg)
Rem
@@dbmsdrs.sql
@@dbmsdg.sql

Rem
Rem Packages for Summary Management and Materialized Views
Rem
@@dbmssum.sql
@@dbmshord.sql

Rem
Rem File Transfer
Rem
@@dbmsxfr.sql

Rem
Rem File Mapping package
Rem
@@dbmsmap.sql

Rem
Rem Frequent Itemset package
Rem
@@dbmsfi.sql

Rem
Rem DBVerify
Rem
@@dbmsdbv.sql

Rem
Rem Trace Conversion
Rem
@@dbmstcv.sql

Rem
Rem Collect UDA
Rem
@@dbmscoll.sql

Rem
Rem profiler package
Rem
@@dbmspbp.sql

Rem
Rem dbms_hprof package
Rem
@@dbmshpro.sql

Rem
Rem Code coverage package
Rem
@@dbmscov.sql

Rem
Rem dbms_service package
Rem
@@dbmssrv.sql

Rem
Rem Change Notification
Rem
@@dbmschnf.sql

Rem
Rem Load explain plan package
Rem
@@dbmsxpln.sql

Rem
Rem OWB Match package
Rem
@@utlmatch.sql

Rem
Rem DBMS_DB_VERSION package
Rem
@@dbmsdbvn.sql

Rem
Rem dbms_shared_pool
Rem
@@dbmspool.sql

Rem
Rem Result_Cache
Rem
@@dbmsrcad.sql

Rem
Rem Client Result Cache
Rem
@@prvthcrc.plb

Rem
Rem dbms_connection_pool
Rem
@@prvtkpps.plb

Rem
Rem from catqueue.sql
Rem
@@dbmsaq.plb
@@dbmsaqad.sql
@@dbmsaq8x.plb
@@dbmsaqem.plb
@@prvtaqxi.plb

Rem
Rem Server-generated alert header files
Rem
@@dbmsslrt.sql

--CATCTL -R
--CATCTL -M
Rem
Rem dbms_monitor package
Rem
@@dbmsmntr.sql

Rem
Rem Health Monitor
Rem
@@dbmshm.sql
@@catsqltk.sql

Rem
Rem Intelligent Repair
Rem
@@dbmsir.sql

Rem
Rem dbms_session_state package (sscr)
Rem
@@prvtsss.plb

Rem
Rem OCM
Rem 
@@dbmsocm.sql

Rem
Rem dbms_lobutil package
Rem
@@dbmslobu.sql

Rem
Rem Manageability Advisor
Rem
@@dbmsmp.sql
@@dbmsaddm.sql

Rem
Rem dbms_transform internal packages
Rem
@@prvttxfs.plb

Rem
Rem Load DBMS RESOURCE MANAGER interface packages
Rem
@@dbmsrmin.plb
@@dbmsrmad.sql
@@dbmsrmpr.sql
@@dbmsrmpe.plb
@@dbmsrmge.plb
@@dbmsrmpa.plb
@@prvtrmie.plb

Rem
Rem dbms_scheduler package
Rem
@@prvthjob.plb

Rem
Rem Data Pump utility functions
Rem
@@prvtdputh.plb

Rem
Rem Metadata API public package header and type defs
Rem
@@dbmsmeta.sql

Rem
Rem Metadata API private package header and type defs for building 
Rem heterogeneous object types
Rem
@@dbmsmetb.sql

Rem
Rem Metadata API private package header and type defs for building 
Rem heterogeneous object types used by Data Pump
Rem
@@dbmsmetd.sql

Rem
Rem Metadata API public package header for compare APIs
Rem
@@dbmsmet2.sql

Rem
Rem DBMS_DATAPUMP public package header and type definitions
Rem
@@dbmsdp.sql 

Rem 
Rem DBMS_MASTER_TABLE public package header for Master table inforamtion
Rem
@@dbmsdpmt.sql

Rem
Rem KUPD$DATA invokers private package header
Rem
@@prvthpd.plb

Rem
Rem KUPD$DATA_INT private package header
Rem
@@prvthpdi.plb

Rem
Rem KUPV$FT_INT private package header
Rem
@@prvthpvi.plb

Rem
Rem Declaration of TDE_LIBRARY packages
Rem
@@prvtdtde.plb

Rem
Rem Declaration of DBMS_CRYPTO_INTERNAL package
Rem
@@prvtcia.plb

Rem
Rem Summary Management
Rem
@@prvtsum.plb

Rem
Rem PRIVATE_JDBC package
Rem
@@prvtjdbs.plb

Rem
Rem Create DBMS_SERVER_ALERT_EXPORT package
Rem
@@dbmsslxp.sql

Rem
Rem create prvt_smgutil package
Rem
@@prvssmgu.plb

Rem
Rem Create DBMS_MANAGEMENT_BOOTSTRAP package
Rem
@@dbmsmb.sql

Rem
Rem Create AWR package
Rem
@@dbmsawr.sql

Rem 
Rem Create SVRMAN UMF package specification
Rem 
@@dbmsumf.sql

Rem
Rem EM Express packages
Rem
@@prvsemxi.plb
@@prvsemx_admin.plb
@@prvsemx_dbhome.plb
@@prvsemx_memory.plb
@@prvsemx_perf.plb
@@prvsemx_cell.plb
@@dbmsperf.sql
@@prvsemx_rsrcmgr.plb
@@prvsemx_sql.plb

Rem
Rem common report types
Rem
@@prvsrept.plb
@@prvsrepr.plb

Rem
Rem prvt_hdm and prvt_rtaddm
Rem
@@prvshdm.plb
@@prvsrtaddm.plb
@@prvs_awr_data_cp.plb
@@prvscpaddm.plb

Rem
Rem create prvt_advisor package
Rem
@@prvsadv.plb

Rem
Rem dbms_swrf_report_internal
Rem
@@prvsawr.plb

Rem
Rem dbms_swrf_internal
Rem
@@prvsawri.plb

Rem
Rem dbms_umf_internal
Rem
@@prvsumfi.plb

Rem
Rem dbms_awr_report_layout
Rem
@@prvsawrs.plb

Rem
Rem dbms_ash_internal
Rem
@@prvsash.plb

Rem
Rem prvt_awr_viewer
Rem
@@prvsawrv.plb

Rem
Rem Create prvt_sqlxxx_infra package specifications
Rem
@@prvssqlf.plb

Rem
Rem Create DBMS_WORKLOAD_ package 
Rem
@@dbmswrr.sql

Rem
Rem Create the DB Feature Usage Report Package
Rem
@@dbmsfus.sql

Rem
Rem Create the DB Feature Usage Package
Rem
@@prvsfus.plb

Rem
Rem packages for manageability undo advisor
Rem has dependencies on dbms_output and dbms_sql
Rem
@@dbmsuadv.sql

Rem
Rem SQL Plan Management (DBMS_SPM) package spec
Rem
@@dbmsspm.sql
@@prvsspmi.plb
@@prvssmb.plb
@@prvssmbi.plb

Rem
Rem Streams
Rem
@@dbmsstr.sql

Rem
Rem SQL Tuning Sets package specification
Rem
@@dbmssqls.sql

Rem
Rem Create dbms_sqlpa packages for SQLPA advisor
Rem prvt_sqlpa is created in depssvrm.sql
Rem
@@dbmsspa.sql

Rem
Rem Automatic Report Capture internal package
Rem
@@prvsautorepi.plb

Rem
Rem Automatic Report Capture package
Rem
@@dbmsautorep.sql

Rem Create dbms_rat_mask package for RAT masking
@@dbmsratmask.sql

Rem SQL Test Case builder depends on dbms.metadata
Rem SQL Diag Package specification
Rem dependent on sql_binds
Rem
@@dbmsdiag.sql

Rem
Rem Replication
Rem
@@dbmsrepl.sql

Rem
Rem Set XS System Paramaters
Rem
@@dbmskzxp.sql

Rem
Rem misc cache utilities
Rem
@@dbmscu.sql

Rem
Rem Utilties for Daylight Saving Patching of TIMESTAMP WITH TIMEZONE data
Rem
@@dbmsdst.sql

Rem
Rem dbms_compression package
Rem
@@dbmscomp.sql

Rem
Rem dbms_ilm package
Rem
@@dbmsilm.sql

Rem
Rem DBMS_PARALLEL_EXECUTE package spec
Rem
@@dbmspexe.sql
@@prvthpexei.plb

Rem
Rem ContentAPI
Rem
@@dbmscapi.sql
@@dbmsfuse.sql
@@dbmsfspi.sql

Rem
Rem ArchiveProvider
Rem
@@dbmspspi.sql

Rem
Rem dNFS package
Rem
@@dbmsdnfs.sql

Rem
Rem DBMS_ADR package
Rem
@@dbmsadr.sql

Rem
Rem ADR_APP package
Rem
@@dbmsadra.sql

Rem
Rem DBMS_ADR_INTERNAL package
Rem
@@prvsadri.plb

Rem
Rem Triton security packages
Rem
@@xsrs.sql
@@xssc.sql
@@xsacl.sql
@@xsds.sql
@@xsns.sql
@@xsdiag.sql
@@xssess.sql

Rem
Rem Data Redaction (Real Time Application-controlled Data Masking, RADM)
Rem
@@dbmsredacta.sql

Rem
Rem SQL Translation
Rem
@@dbmssqll.sql

Rem GSM Common packages
@@dbmsgwm.sql

Rem Application continuity
Rem
@@dbmsappcont.sql

Rem
Rem DBMS_SCN package for SCNCompatibility project
Rem
@@dbmsscnc.sql

Rem
Rem Sql Plan Directive specs
Rem
@@dbmsspd.sql
@@prvsspdi.plb

Rem
Rem FS package
Rem
@@dbmsfs.sql

Rem
Rem DBOP monitoring
Rem
@@dbmssqlm.sql

Rem
Rem dbms_privilege_profile package
Rem
@@catprofp.sql

Rem
Rem contains packge spec and body for dbms_system
Rem
@@prvtsys.plb

Rem
Rem DBMS_PART package
Rem
@@dbmspart.sql

Rem
Rem Rolling upgrade package
Rem
@@dbmsrupg.sql

Rem
Rem TSDP package
Rem
@@dbmstsdp.sql

Rem
Rem dbms_inmemory package
Rem
@@dbmsinmem.sql

Rem
Rem DBCOMPARE package
Rem
@@dbmsdbcomp.sql

Rem
Rem Application Resilience package
Rem
@@dbmsapre.sql

Rem
Rem dbms_inmemory_admin package
Rem
@@dbmsinmemadmin.sql

Rem
Rem DBMS_HADOOP package specifications
Rem
@@dbmshadp.sql

--CATCTL -R
--CATCTL -S      Execute dependent catmetfiles.sql
Rem
Rem Note all catmetfiles.sql must be executed in process 0
Rem
Rem Metadata API private definers rights package header
Rem
@@dbmsmeti.sql
Rem
Rem Metadata API private utility package header and type defs
Rem
@@dbmsmetu.sql

Rem Queryable patch inventory
@@dbmsqopi.sql

Rem Polymorphic Table functions Helpers
@@dbmstf.sql

Rem Proj 47329: DBMS_HANG_MANAGER
@@dbmshmgr.sql

Rem dbms_acl_service package
@@dbmsaclsrv.sql

Rem Proj 46762: DBMS_TNS
@@dbmstns.sql

Rem Application cdb views
@@catappcdbviews

Rem
Rem dbms_scheduler package
Rem
@@prvthesh.plb

Rem proj-58146
Rem dbms_isched_remote_access package
Rem
@@dbmsrsa.plb

Rem Bug 25992935
Rem dbms_isched_agent package
Rem
@@prvthisagt.plb

Rem Bug 25992938
Rem dbms_isched_utl package  
Rem 
@@prvthisutl.plb

Rem
Rem Stored outline package
Rem
@@dbmsol.sql
@@prvtols.plb

Rem
Rem KUPP$PROC private package header
Rem
@@prvthpp.plb

Rem
Rem dbms_set_pdb trigger
Rem
@@setpdb.sql

Rem proj-68493
Rem dbms_memoptimize package
Rem
@@dbmsmemoptimize.sql


Rem *********************************************************************
Rem END catpdbms.sql
Rem *********************************************************************

@?/rdbms/admin/sqlsessend.sql
