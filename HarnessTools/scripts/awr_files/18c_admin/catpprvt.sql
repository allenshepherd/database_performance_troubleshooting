Rem
Rem catpprvt.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpprvt.sql - CATProc PRVT_ package and type bodies
Rem
Rem    DESCRIPTION
Rem      This script loads the package and type bodies for the objects
Rem      created in catpdbms.sql and catptabs.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpprvt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpprvt.sql
Rem SQL_PHASE: CATPPRVT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    miglees     11/27/17 - XbranchMerge miglees_bug-27051964 from main
Rem    miglees     11/05/17 - Bug 27051964: remove dbmsmemoptimizeadmin.plb
Rem    alestrel    09/10/17 - Bug 25992938. Add dbms_isched_utl package body
Rem    tianlli     06/30/17 - 26192553: change order of prvtpdb and prvtappcon
Rem    alestrel    06/08/17 - Bug 25992935. Include dbms_isched_agent package
Rem                           body
Rem    kshergil    06/05/17 - 25632497: add dbmsmemoptimizeadmin.plb
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    yuyzhang    04/05/17 - proj# 57499: add package body prvtstatagg
Rem    pjulsaks    04/05/17 - Bug 25773902: change prvtpdb_altshr to prvtappcon
Rem    cwidodo     03/27/17 - #(25410921) : add prvtoli.plb
Rem    sursridh    03/06/17 - Bug 25683998: Remove prtpen invocation.
Rem    sursridh    01/26/17 - Add support for PDB events framework.
Rem    siteotia    12/26/16 - Project 68493: Add prvtmemoptimize.plb
Rem    qinwu       11/26/16 - bug 24923199: add prvtwrr_report.plb
Rem    shvmalik    11/25/16 - #25035608: revert back FCP txn
Rem    aarvanit    11/07/16 - bug #24966761: add prvtsqls.plb
Rem    drosash     07/06/16 - bug23598713 - Add prvtpclxi.plb
Rem    shvmalik    06/30/16 - #23721669: add FCP package body prvtfcp.plb
Rem    sylin       05/09/16 - bug23248734 - remove dbms_sqlplus_script package
Rem    schakkap    03/16/16 - #(22029499) move prvtstatadv from catpprvt to
Rem                           catpdbms
Rem    osuro       02/19/16 - Add prvtmb.plb
Rem    sdipirro    11/16/15 - Add prvtbdpi.plb
Rem    akruglik    12/02/15 - (21953121) run dbmspdb_altshr.sql
Rem    yulcho      12/02/15 - add application resilience api
Rem    svivian     10/16/15 - bug 21882092: renamed prvtlms.plb to prvtlmsb.plb
Rem    zhcai       10/09/15 - add prvtemx_sql
Rem    sudurai     09/17/15 - Bug 21805805: Changing DBMS_CRYPTO_STATS_INT to
Rem                           DBMS_CRYPTO_INTERNAL
Rem    sogugupt    09/12/15 - Bug 19814527: Add prvtdpmt.plb
Rem    surman      08/26/15 - 20772435: Move SQL registry dependents to
Rem                           catxrd.sql
Rem    jerrede     07/29/15 - Fix Loading of prvtbggei.plb
Rem    jerrede     07/27/15 - Add -D Description
Rem    sudurai     06/22/15 - Bug 21258745: Moving STATS crypto APIs from
Rem                           DBMS_STATS_INTERNAL -> DBMS_CRYPTO_STATS_INT
Rem    mahrajag    05/23/15 - add PL/SQL Code Coverage Package
Rem    rajeekku    03/13/15 - proj 46762 : Add prvttns.plb
Rem    huntran     03/12/15 - prvtbggei
Rem    lzheng      03/09/15 - add prvtbgg.plb
Rem    sagrawal    01/28/15 - rename dbms_tf_utl ==>> dbms_tf
Rem    beiyu       01/09/15 - Proj 47091: add prvtodbo.sql and prvthier.sql
Rem    bnnguyen    12/29/14 - bug 19697038: add prvtaclsrv.plb
Rem    cunnitha    12/16/14 - proj 48488: invoke prvtpq for loopback dblink for
Rem                           hubs
Rem    nmuthukr    11/24/14 - add prvtprocess.plb
Rem    hoyao       11/23/14 - add dbcompare
Rem    cqi         11/18/14 - add prvthmgr.plb
Rem    jiayan      09/15/14 - Proj 44162: Stats Advisor
Rem    kdnguyen    08/26/14 - Bug 19510008: move enabling/enabling fs to stored
Rem                           proc
Rem    yxie        08/22/14 - proj 47332: add prvtemx_rsrcmgr
Rem    spapadom    08/18/14 - Added Unified Manageability Framework pkg bodies.
Rem    nkgopal     07/30/14 - Proj 35931: Add DBMS_AUDIT_UTIL
Rem    jlingow     07/10/14 - proj-58146 add prvtrsa.plb, 
Rem                           dbms_isched_remote_access body
Rem    mthiyaga    07/02/14 - Add prvthadoop.plb
Rem    jerrede     06/16/14 - Bug #18838914 Fix Deadlock Issues by making
Rem                           everything serial with load without compile
Rem                           turned on.  Actually faster then running them
Rem                           in parallel.
Rem    jerrede     05/01/14 - Fix Deadlock Issues.
Rem                           prvtidxu.plb Move to Serial phase
Rem                           deadlock on SYS.DBMS_I_INDEX_UTL.
Rem                           catfusrg.sql deadlock on DBMS_FEATURE_ADV_IDXCMP and
Rem                           DBMS_FEATURE_GOLDENGATE procedure moved to a
Rem                           Serial phase.  Should not be loaded when compilation
Rem                           has been turned off.
Rem                           prvtcred.plb moved above prvtesch.sql
Rem                           dependencies on DBMS_CREDENTIAL package.
Rem                           prvtawrv.plb moved up one phase deadlock on
Rem                           PRVT_AWRV_METADATA.
Rem                           prvtds.plb to serial phase 
Rem                           deadlocking on XS_DATA_SECURITY_UTIL.
Rem                           prvtxsrs.plb moved to the start of a new section
Rem                           deadlocking on XS_ROLESET_INT.
Rem    jkaloger    03/29/14 - Add prvtkubsagt.plb
Rem    sagrawal    04/16/14 - polymorphic table functions
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    lbarton     10/17/13 - bug 17621089: add prvtbpexpi.plb
Rem    jnunezg     09/11/13 - Moving prvti18n.plb to an earlier stage, since
Rem                           dbms_isched depens on it
Rem    miglees     08/21/13 - Add prvtinmem.plb
Rem    lvbcheng    08/20/13 - 17356189: remove KKXHTMLDB testing only pkg body
Rem    surman      08/03/13 - 17005047: Add dbms_sqlpatch
Rem    cgervasi    06/19/13 - add prvtemx_cell.plb
Rem    jerrede     06/20/13 - Fix Dependency issues move prvtrlsa before prvtds
Rem    vgokhale    05/03/13 - XbranchMerge vgokhale_bug-14121009_11.2.0.4.0_1
Rem                           from st_rdbms_11.2.0
Rem    jerrede     02/05/13 - Fix Deadlock issue when loading prvtcapi.plb
Rem                           Moved to previous phase.
Rem    minx        11/29/12 - Fix bug 15928711: unload prvtkzxc.plb
Rem    jerrede     10/15/12 - Fix dependency issue move prvtrupgis.sql to the
Rem                           previous phase so it would not collide with
Rem                           prvtrupgib.sql.
Rem    jerrede     10/01/12 - Catcon Changes
Rem    yujwang     08/21/12 - fix bug 14521374 since prvtratmask.plb
Rem                           depends on prvtwrr.plb
Rem    cgervasi    08/03/12 - add prvtperf.plb
Rem    jerrede     06/25/12 - Move prvtbpui.plb to a separate phase
Rem                           To fix a deadlock between prvtbpu.plb and
Rem                           prvtbpui.plb on KUPU$UTILITIES_INT.
Rem    rrungta     06/18/12 - Adding prvtlog.plb
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     03/12/12 - Add prvtratmask.sql for RAT masking
Rem    jerrede     03/01/12 - Fix lrg 6735059 Dependency Errors
Rem    shjoshi     02/27/12 - Add prvtautorepi.plb
Rem    rpang       02/02/12 - Network ACL triton migration
Rem    arbalakr    01/15/12 - add cpaddm packages
Rem    tbhukya     12/22/11 - Add prvtqopi.plb
Rem    dgraj       08/19/11 - Project 32079: Add file for TSDP
Rem    jinjche     12/22/11 - Add prvtpstdy.plb
Rem    jerrede     12/13/11 - Add Comments for Parallel Upgrade
Rem    yxie        12/09/11 - add prvtemx_perf
Rem    cgervasi    12/07/11 - add prvtemx_memory
Rem    dgraj       11/05/11 - Bug 13243011: Remove prvtlink.plb
Rem    cslink      10/10/11 - Remove prvtradma.plb
Rem    jerrede     10/06/11 - Fix lrg 5829047 Dependency Warning Errors
Rem    kyagoub     09/24/11 - add prvtemx_dbhome.plb
Rem    cslink      09/19/11 - Add prvtredacta.plb for rename of RADM to REDACT
Rem    geadon      09/19/11 - add DBMS_PART
Rem    sslim       09/01/11 - Add prvtrupg.plb
Rem    pyam        09/12/11 - remove _LOAD_WITHOUT_COMPILE to fix CDB create
Rem    shjoshi     09/10/11 - Add prvtautorep.plb
Rem    msusaira    02/15/11 - add prvtfs.plb
Rem    sslim       09/01/11 - Add prvtrupg.plb
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    hayu        08/29/11 - add prvtsqlm.sql
Rem    cgervasi    07/20/11 - add awr viewer
Rem    bdagevil    07/17/11 - move @@prvtrepr.plb up since it is needed by emxi
Rem    yiru        07/08/11 - Move prvtprin.plb to catpspec.sql,
Rem                            add prvtkzrxu.plb
Rem    shiyadav    06/06/11 - add prvtadra.plb and prvtadri.plb
Rem    bdagevil    06/05/11 - add prvtemx_admin
Rem    msusaira    02/15/11 - add prvtfs.plb
Rem    hlakshma    05/25/11 - ILM (Project 30966) related package
Rem                           support (add prvtilm.plb)
Rem    paestrad    05/20/11 - Adding DBMS_CREDENTIAL package
Rem    jheng       02/28/11 - add prvtpprof.plb
Rem    schakkap    05/05/11 - project SPD (31794): add Sql Plan Directive
Rem                           package bodies
Rem    yxie        04/28/11 - add em express package prvtemxi
Rem    traney      03/20/11 - add prvtcstk.plb
Rem    sroesch     02/09/11 - Add prvtappcont.sql for application continuity
Rem    gravipat    01/27/11 - Add dbms_pdb
Rem    rpang       01/07/11 - Add DBMS_SQL_TRANSLATOR
Rem    pknaggs     12/21/10 - RADM: Add prvtradma.plb for data masking API
Rem    amullick    12/20/10 - Project 33140: add prvttlog.plb
Rem    lbarton     09/10/10 - prvtdput.plb
Rem    snadhika    11/15/10 - prvtrs renamed to prvtxsrs
Rem    srirkris    10/10/13 - Remove prvtsjty.plb
Rem    snadhika    11/15/10 - prvtrs renamed to prvtxsrs
Rem    gagarg      05/26/10 - catpprvt.sql(auto_comment)
Rem    gagarg      05/23/10 - Proj 31157: Add sharded queue plbs
Rem    yiru        10/20/09 - Add prvtadmi.plb
Rem    weihwang    08/28/09 - Added xs_diag package
Rem    snadhika    07/10/09 - Add triton security packages
Rem    msusaira    06/09/09 - Add prvtdnfs.plb
Rem    amullick    06/16/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove prvtam.plb
Rem    mfallen     06/15/09 - add prvtadr.plb
Rem    mbastawa    03/13/09 - add prvtcrc.plb
Rem    amullick    01/22/09 - Archive Provider support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    yurxu       12/04/08 - Disable IAS
Rem    sipatel      09/29/08 - bug 7414934. call catxtbix from catqm
Rem    chliang     09/04/08 - 
Rem    shiyer      03/26/08 - Remove TSM packages
Rem    sjanardh    07/01/08 - Remove prvtaqiu.lb
Rem    rbhatti     04/24/08 - Reverting changes from rbhatti_xs_bug_6782472 txn
Rem    msakayed    04/16/08 - add KUPU$UTILITIES package
Rem    lbarton     04/15/08 - bug 6969874: move mdapi compare APIs to their own
Rem                           package
Rem    huagli      11/27/07 - add prvtdst
Rem    ssvemuri    03/27/08 - Archive manager prvt file
Rem    amitsha     03/17/08 - change prvtcmp to prvtcmpr
Rem    rbhatti     02/01/08 - bug 6782472- moved prvtkzxp.plb
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT package
Rem    amitsha     12/27/07 - add prvtcmp for dbms_compression
Rem    sylin       11/27/07 - add prvtutil.plb from catpdeps.sql
Rem    achoi       11/13/07 - add DBMS_PARALLEL_EXECUTE
Rem    ilistvin    10/24/07 - add prvtawri.plb
Rem    adalee      09/25/07 - add prvtkcl - misc cache util package
Rem    ilistvin    09/14/07 - add prvtawrs.plb
Rem    kyagoub     05/22/07 - add sqlpa new packages
Rem    ushaft      04/23/07 - add prvtsmgu
Rem    hosu        02/27/07 - add prvtsmb, prvtsmbi and prvtspmi
Rem    jnarasin    11/24/06 - Add prvtkzxp.plb
Rem    pbelknap    01/12/07 - add prvtsqlf
Rem    ushaft      01/04/07 - 
Rem    rburns      01/05/07 - final cleanup
Rem    jkundu      11/30/06 - new pkg prvtlmes and prvtlmeb
Rem    ilistvin    11/09/06 - 
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    jinwu       11/03/06 - add catpstr.sql
Rem    elu         10/23/06 - add replication package bodies
Rem    achoi       08/27/06 - replace prvtptch.plb with prvtedu.plb 
Rem    kkunchit    07/28/06 - dbms_lobutil support 
Rem    mziauddi    09/18/06 - move prvtxpln to catpwork (after catsvrm.sql)
Rem    rburns      08/23/06 - more restructuring
Rem    eshirk      07/14/06 - Add private_jdbc package 
Rem    rburns      07/26/06 - add more package bodies 
Rem    jawilson    07/13/06 - 
Rem    samepate    06/18/06 - remove prvtjob.plb
Rem    sourghos    06/07/06 - add WLM package body 
Rem    mjstewar    05/25/06 - IR integration 
Rem    chliang     05/19/06 - add sscr package body
Rem    kamsubra    05/19/06 - Adding prvtkppb.plb 
Rem    schakkap    06/01/06 - fix dependency of dbms_pitr on dbms_plugts 
Rem    nkarkhan    05/26/06 - Project 19620: Add support for application
Rem                           initiated Fast-Start Failover.
Rem    kneel       06/03/06 - moving execution of prvtbdbu.sql to catpprvt.sql 
Rem    kneel       06/01/06 - add prvtkjhn.sql 
Rem    jklein      06/07/06 - 
Rem    kmuthukk    05/18/06 - Add dbms_hprof package 
Rem    rburns      05/24/06 - add dbms_alert 
Rem    rburns      05/19/06 - add queue files 
Rem    rburns      05/18/06 - add more prvt files 
Rem    bkuchibh    05/17/06 - add prvthm.plb 
Rem    rburns      01/13/06 - split catproc for parallel upgrade 
Rem    rburns      01/13/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem **********************************************************************
Rem 
Rem  NOTE: SQL CODE NOT PERMITTED IN THIS FILE ONLY THE EXECUTION OF A
Rem       .PLB file.
Rem
Rem **********************************************************************
Rem

Rem
Rem SERIAL QUICK LOAD 
Rem Needed to avoid deadlocking
Rem on SYS.KUPU$UTILITIES_INT.
Rem
--CATCTL -CS
--CATCTL -S -D "Catproc PLBs"
@@prvthpu.plb
@@prvthpui.plb
@@prvtbpui.plb
Rem Index Rebuild Views and Body
@@prvtidxu.plb

Rem Triton Security
@@prvtadmi.plb
@@prvtbpu.plb
Rem Triton Security
@@prvtutils.plb
Rem Row Level Security package
@@prvtrlsa.plb
@@prvti18n.plb
Rem DBMS_CREDENTIAL package
@@prvtcred.plb

Rem PL/SQL packages
@@prvtfile.plb
@@prvtrawb.plb
@@prvttcp.plb
@@prvtinad.plb
@@prvtsmtp.plb
@@prvthttp.plb
@@prvturl.plb
@@prvtenc.plb
@@prvtgdk.plb
@@prvtlob.plb
@@prvtlobu.plb
@@prvtcstk.plb

@@prvtcomp.plb
@@prvtlms2.plb
@@prvtnla.plb

@@prvttrns.plb
@@prvtsess.plb
@@prvtrwid.plb

@@prvtpclxi.plb
@@prvtpclx.plb

@@prvterlg.plb
@@prvtapin.plb
@@prvtsyer.plb
@@prvtlock.plb
@@prvtpipe.plb
@@prvtalrt.plb
@@prvtdesc.plb
@@prvtbpexpi.plb
@@prvtpexp.plb
@@prvtzexp.plb
@@prvtstts.plb
@@prvtddl.plb
@@prvtpp.plb
@@prvtkppb.plb

Rem Hierarchical Cube Sql (HCS) packages
@@prvtodbo.plb
@@prvthier.plb

Rem package body for dbms_utility
@@prvtutil.plb 

Rem PL/SQL Server Pages package
@@prvtpsp.plb
@@prvttran.plb

Rem package for XA PL/SQL APIs
@@prvtxa.plb

Rem AnyType creation
@@prvtany.plb

Rem Rules engine
@@prvtread.plb

Rem Probe packages
@@prvtpb.plb

Rem PL/SQL trace packages
@@prvtpbt.plb

Rem dbmsdfrd is replaced by dbmsdefr for the replication option
@@prvtxpsw.plb

Rem pl/sql package for COLLs (UTL_COLL)
@@prvtcoll.plb

Rem pl/sql package for distributed trust administration (trusted list admin)
@@prvttrst.plb

Rem Script for Extensibility types
@@prvtodci.plb

Rem Data/Index Repair Package
@@prvtrpr.plb

Rem Obfuscation (encryption) toolkist
@@prvtobtk.plb

Rem XMLTYPE bodies
@@prvtxmlt.plb
@@prvturi.plb
@@prvtxml.plb

Rem UTL_XML: PL/SQL wrapper around CORE LPX facility: C-based XML/XSL parsing
@@prvtcxml.plb

Rem EM Express packages
Rem (also used by Manageability/Diagnosability Report Framework)
@@prvtemxi.plb
@@prvtemx_admin.plb
@@prvtemx_dbhome.plb
@@prvtemx_memory.plb
@@prvtemx_perf.plb
@@prvtemx_cell.plb
@@prvtperf.plb
@@prvtemx_rsrcmgr.plb
@@prvtemx_sql.plb

Rem Manageability/Diagnosability Report Framework
@@prvtrep.plb
@@prvtrept.plb
@@prvtrepr.plb

REM Script for Fine Grained Auditing
@@prvtfga.plb

REM Script for DBMS_AUDIT_MGMT
@@prvtamgt.plb

Rem Type Utility 
@@prvttypu.plb

Rem Multi-language debug support
@@prvtjdwp.plb
@@prvtjdmp.plb

Rem package for Resumable and ora_space_error_info attribute function
@@prvtres.plb

Rem Component registry package bodies
@@prvtcr.plb

Rem package for transaction layer internal functions
@@prvttxin.plb

Rem Data Guard recovery framework support (dbms_drs & dbms_dg)
@@prvtdrs.plb
@@prvtdg.plb

Rem Frequent Itemset package
@@prvtfi.plb

Rem File Mapping package
@@prvtmap.plb

Rem DBVerify
@@prvtdbv.plb

Rem Trace Conversion
@@prvttcv.plb

Rem profiler package
@@prvtpbp.plb

Rem dbms_hprof package
@@prvthpro.plb

Rem dbms_plsql_code_coverage package
@@prvtcov.plb

Rem trace package
@@prvtbdbu.plb

Rem dbms_service package
@@prvtsrv.plb

Rem shared pool
@@prvtpool.plb

Rem Lightweight user sessions (a.k.a eXtensible Security Sessions)
@@prvtkzxs.plb

Rem Extensible Security System package
@@prvtkzxp.plb

Rem Client Result Cache
@@prvtcrc.plb

Rem Result_Cache
@@prvtrc.plb

Rem AQ package bodies
@@prvtaq.plb
@@prvtaqdi.plb
@@prvtaqxe.plb
@@prvtaqis.plb
@@prvtaqim.plb
@@prvtaqad.plb
@@prvtaq8x.plb
@@prvtaqin.plb
@@prvtaqal.plb
@@prvtaqjm.plb
@@prvtaqmi.plb
@@prvtaqme.plb
@@prvtaqem.plb 

@@prvtaqip.plb
@@prvtaqds.plb

Rem Shared queue plbs
@@prvtsqdi.plb
@@prvtsqds.plb
@@prvtsqis.plb

Rem Health Monitor
@@prvthm.plb

Rem WLM package body
@@prvtwlm.plb
@@prvtsqtk.plb


Rem High Availabilty Events (FAN alerts)
@@prvtkjhn.plb

Rem Intelligent Repair
@@prvtir.plb

Rem dbms_session_state package (sscr)
@@prvtssb.plb

Rem dbms_transform internal packages
@@prvttxfm.plb

Rem Load DBMS RESOURCE MANAGER interface packages
@@prvtrmin.plb
@@prvtrmad.plb
@@prvtrmpr.plb
@@prvtrmpe.plb
@@prvtrmge.plb
@@prvtrmpa.plb

Rem Load Scheduler packages
Rem dbmssch.sql is needed for the views so it is loaded earlier
@@prvtjob.plb
@@prvtbsch.plb
@@prvtesch.plb

Rem Stored outline package 
@@prvtol.plb
@@prvtoli.plb

Rem package bodys for Redo LogMiner
Rem Make sure these are always called after dbmstrig.sql has been installed
Rem dependent on prvtlrm.sql
@@prvtlm.plb
@@prvtlmcb.plb
@@prvtlmrb.plb
@@prvtlmsb.plb
@@prvtlmeb.plb

Rem Create DBMS_WORKLOAD_ package body
@@prvtwrr_report.plb
@@prvtwrr.plb

Rem DBMS_ROLLING 
@@prvtrupg.plb
@@prvtrupgis.plb

Rem ContentAPI
@@prvtcapi.plb

Rem prvt_awr_viewer
@@prvtawrv.plb

Rem DBMS_DATAPUMP_UTL package body
@@prvtdput.plb
Rem DBMS_METADATA package body: Dependent on dbmsxml.sql
@@prvtmeta.plb
Rem DBMS_METADATA_INT package body: Dependent on prvtpbui
@@prvtmeti.plb
Rem DBMS_METADATA_UTIL package body: dependent on prvthpdi
@@prvtmetu.plb
Rem DBMS_METADATA_BUILD package body
@@prvtmetb.plb
Rem DBMS_METADATA_DPBUILD package body
@@prvtmetd.plb
Rem DBMS_METADATA_DIFF package body
@@prvtmet2.plb
Rem DBMS_DATAPUMP_INT definers private package body
@@prvtbdpi.plb
Rem DBMS_DATAPUMP public package body
@@prvtdp.plb
Rem DBMS_MASTER_TABLE public package body
@@prvtdpmt.plb
Rem KUPC$QUEUE invokers private package body
@@prvtbpc.plb
Rem KUPC$QUEUE_INT definers private package body
@@prvtbpci.plb
Rem KUPW$WORKER private package body
@@prvtbpw.plb
Rem KUPM$MCP private package body: Dependent on prvtbpui
@@prvtbpm.plb
Rem KUPF$FILE_INT private package body
@@prvtbpfi.plb
Rem KUPF$FILE private package body
@@prvtbpf.plb
Rem KUPP$PROC private package body
@@prvtbpp.plb
Rem KUPD$DATA invokers private package body
@@prvtbpd.plb
Rem KUPD$DATA_INT private package body
@@prvtbpdi.plb
Rem KUPV$FT private package body
@@prvtbpv.plb
Rem KUPV$FT_INT private package body
@@prvtbpvi.plb

Rem TDE utility
@@prvtdpcr.plb

Rem Statistics Encryption APIs - Body of DBMS_CRYPTO_INTERNAL package
@@prvtciai.plb

Rem transportable tablespace packages
@@prvtplts.plb

Rem dbms_pitr package body
@@prvtpitr.plb

Rem rules engin imp/exp and upgrade/downgrade packages
@@prvtreie.plb
@@prvtrwee.plb

Rem UTL_RECOMP body
@@prvtrcmp.plb

Rem Change Notification
@@prvtchnf.plb

Rem dbms_edition
@@prvtedu.plb

Rem Logical Standby package bodies
@@prvtlsby.plb
@@prvtlsib.plb
@@prvtlssb.plb

Rem Summary Advisor
@@prvtsmv.plb
@@prvtsma.plb

Rem iAS packages
Rem @@prvtbias.plb  

Rem File Transfer
Rem dependent on prvtsnap
@@prvtbxfr.plb

Rem Load package body of online redefinition
Rem dependent on snapshot_lib
@@prvtbord.plb

Rem PRIVATE_JDBC package
@@prvtjdbb.plb

Rem Create the DBMS_SERVER_ALERT package
@@prvtslrt.plb

Rem Create DBMS_SERVER_ALERT_EXPORT package
@@prvtslxp.plb

Rem Create dbms_auto_task package
@@prvtatsk.plb

Rem Create dbms_monitor package
@@prvtmntr.plb

Rem Create prvt_smgutil package
@@prvtsmgu.plb

Rem Advisory framework (DBMS_ADVISOR API)
@@prvtdadv.plb

Rem Create prvt_advisor package
@@prvtadv.plb

Rem dbms_management_bootstrap
@@prvtmb.plb 

Rem dbms_swrf_report_internal
@@prvtawr.plb

Rem dbms_awr_report_layout
@@prvtawrs.plb

Rem dbms_swrf_internal
@@prvtawri.plb

Rem dbms_umf 
@@prvtumf.plb 

Rem dbms_umf_internal
@@prvtumfi.plb 

Rem dbms_ash_internal
@@prvtash.plb

Rem prvt_sqlxxx_infra
@@prvtsqlf.plb

Rem SQL Tuning Sets package body
@@prvtsqls.plb

Rem dbms_sqltune and dbms_sqltune_internal packages
@@prvtsqli.plb
@@prvtsqlt.plb

Rem Add Automatic Report Capture Internal package body
@@prvtautorepi.plb

Rem Add Automatic Report Capture package body
@@prvtautorep.plb

Rem Create the DB Feature Usage Package
@@prvtfus.plb

Rem dbms_management_packs package body
@@prvtmp.plb

Rem hdm pkg
@@prvthdm.plb
@@prvtaddm.plb
@@prvtrtaddm.plb
@@prvt_awr_data_cp.plb
@@prvtcpaddm.plb

Rem package body for the manageability undo advisor
@@prvtuadv.plb

Rem Create dbms_sqltune_util0 and dbms_sqltune_util1 package bodies
Rem for sqltune and sqlpi advisors
@@prvtsqlu.plb

Rem Create prvt_sqlpa and dbms_sqlpa packages for SPA advisor
@@prvtspai.plb
@@prvtspa.plb

Rem Create dbms_rat_mask package for RAT masking
@@prvtratmask.plb

Rem Optimizer Plan Management (DBMS_OPM) package body
@@prvtspmi.plb
@@prvtspm.plb
@@prvtsmbi.plb
@@prvtsmb.plb

Rem create feature usage packages
@@prvtfus.plb

Rem SQL Access Advisor workload package
@@prvtwrk.plb

Rem Access Advisor and TUNE Mview packages
@@prvtsmaa.plb

Rem Explain Plan
@@prvtxpln.plb

Rem Stats Advisor
@@prvtstatadvi.plb

Rem DBMS_STATS
@@prvtstat.plb
@@prvtstai.plb
@@prvtstatagg.plb

Rem Create the private portion of the SQL Diag package
@@prvtsqld.plb

Rem dbms_space
@@prvtspcu.plb

Rem Data Mining
@@prvtodm.plb

Rem Misc Cache Utilities
@@prvtkcl.plb

Rem Utilties for Daylight Saving Patching of TIMESTAMP WITH TIMEZONE data
@@prvtdst.plb

Rem dbms_compression
@@prvtcmpr.plb

Rem ILM related package implementation
@@prvtilm.plb

Rem DBMS_PARALLEL_EXECUTE package body
@@prvtpexei.plb
@@prvtpexe.plb

Rem ContentAPI
@@prvtfuse.plb
@@prvtfspi.plb

Rem DBMS_DBFS_HS
@@prvtpspi.plb

Rem dnfs package
@@prvtdnfs.plb

Rem ofs package
@@prvtfs.plb

Rem ADR package
@@prvtadri.plb
@@prvtadr.plb
@@prvtadra.plb

Rem Triton Security
@@prvtds.plb


Rem Triton Security
@@prvtxsrs.plb
@@prvtsc.plb
@@prvtacl.plb
@@prvtns.plb
@@prvtdiag.plb
@@prvtkzrxu.plb

Rem Network ACL packages
@@prvtnacl.plb

Rem Data Redaction (Real Time Application-controlled Data Masking, RADM)
@@prvtredacta.plb

Rem DBMS_PDB_ALTER_SHARING
@@prvtappcon.plb
Rem DBMS_PDB
@@prvtpdb.plb

Rem SecureFile log
@@prvttlog.plb
Rem SQL Translation
@@prvtsqll.plb

Rem Application continuity
@@prvtappcont.plb

Rem Sql Plan Directive bodies
@@prvtspd.plb
@@prvtspdi.plb

Rem dbms_privilege_profile package body
@@prvtpprof.plb

Rem dbms_sqlm package body
@@prvtsqlm.plb

Rem DBMS_PART package
@@prvtpart.plb

Rem DBMS_ROLLING 
@@prvtrupgib.plb

Rem Data Guard Redo
@@prvtpstdy.plb

Rem Transparent Sensitive Data Protection
@@prvttsdp.plb

-- 20772435: Queryable patch inventory package body is now created in catxrd

Rem dbms_log package
@@prvtlog.plb

Rem dbms_scn package
@@prvtscnc.plb

Rem dbms_inmemory package
@@prvtinmem.plb

Rem DBCOMPARE
@@prvtdbcomp.plb

Rem application resilience package
@@prvtapre.plb
  
Rem dbms_indmemory_admin package
@@prvtinmemadmin.plb

Rem dbms_tf package
@@prvttf.plb

Rem BigData Agent package
@@prvtkubsagt.plb

-- 20772435: Queryable dbms_sqlpatch package body is now created in catxrd

Rem dbms_hadoop /hive package
@@prvthadoop.plb

Rem dbms_hang_manager package
@@prvthmgr.plb

Rem Proj 35931: DBMS_AUDIT_UTIL
@@prvtaudutl.plb

Rem proj-58146
Rem dbms_isched_remote_access
@@prvtrsa.plb

Rem Bug 25992935
Rem dbms_isched_agent
@@prvtbisagt.plb

Rem Bug 25992938
Rem dbms_isched_utl package
Rem 
@@prvtbisutl.plb

Rem dbms_process package
@@prvtprocess.plb

Rem proj 48488: invoke prvtpq for loopback dblink for hubs
@@prvtpq.plb

Rem dbms_acl_service package
@@prvtaclsrv.plb

Rem dbms_goldengate_adm package
@@prvtbgg.plb

Rem proj 46762
@@prvttns.plb

Rem GoldenGate packages
@@prvtbggei.plb

--CATCTL -CE
--CATCTL -R

--CATCTL -S
rem Register the Features and High Water Marks
@@catfusrg.sql

Rem Project 68493
Rem dbms_memoptimize package
@@prvtmemoptimize.plb

Rem *********************************************************************
Rem END catpprvt.sql
Rem *********************************************************************

@?/rdbms/admin/sqlsessend.sql
