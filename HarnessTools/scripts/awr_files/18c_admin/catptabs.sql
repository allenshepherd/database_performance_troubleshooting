Rem
Rem $Header: rdbms/admin/catptabs.sql /main/80 2017/07/31 11:05:56 bwright Exp $
Rem
Rem catptabs.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catptabs.sql - CATProc TABleS and views
Rem
Rem    DESCRIPTION
Rem      This script runs the "cat" scripts that create the tables
Rem      and views required by the features loaded in catproc.sql
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql.
Rem      It can be run with catctl.pl as a multiprocess phase.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catptabs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catptabs.sql
Rem SQL_PHASE: CATPTABS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bwright     06/21/17 - Bug 25651930: Add catnodpobs.sql
Rem    anbhasu     05/15/17 - Bug 22730089: Moved catpvf.sql to catpdeps.sql
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    shvmalik    11/25/16 - #25035608: revert back FCP txn
Rem    osuro       11/07/16 - bug 24674921: move catawrtv.sql to catpspect.sql
Rem    jjye        08/04/16 - bug 21571874: MV uses dbms_scheduler
Rem    shvmalik    06/30/16 - #23721669: add catfcp.sql
Rem    aumishra    04/28/16 - Bug 23177430: Add views for In-Memory Expressions
Rem    sursridh    03/11/16 - Bug 21028455: Rename catfed->catappcontainer.
Rem    raeburns    09/24/15 - RTI 16218614: move catfedcdbviews.sql and catrm.sql
Rem    surman      08/20/15 - 20772435: Move catsqlreg to catxrd
Rem    pyam        06/22/15 - catfed -> catfed + catfedcdbviews
Rem    kdnguyen    05/12/15 - Bug 20474610: add catimfs.sql
Rem    amylavar    09/04/15 - proj 46675: Global dictionary tables
Rem    rajeekku    03/15/15 - Project 46762: add catdbl.sql
Rem    bnnguyen    12/29/14 - bug 19697038: add cataclsrv.sql
Rem    sramakri    12/05/14 - add catmvrs.sql
Rem    jorgrive    11/20/14 - proj 46680, Desupport Advanced Replication,
Rem                           remove catrep.sql.                            
Rem    cqi         11/18/14 - add cathmgr.sql
Rem    jlingow     09/08/14 - proj-58146 Creating REMOTE_SCHEDULER_AGENT user
Rem    thbaby      09/02/14 - Proj 47234: invoke catfed
Rem    spapadom    08/18/14 - Added catumftv.sql
Rem    surman      04/21/14 - 17277459: Seperate script for SQL registry
Rem    bhammers    03/03/14 - add catjsonv.sql (JSON views)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jkati       10/24/13 - bug#17543726 : add catpvf.sql
Rem    jerrede     10/22/12 - DeadLock Issue on grant select any table to sys
Rem                           with admin option in catrupg.sql moved to serial
Rem                           phase
Rem    jerrede     09/17/12 - Fix Mutex Issue with gsm_internal
Rem    jerrede     04/18/12 - Lrg 6874389 Fix Deadlocking Issues
Rem                           when processing grants. Move grants
Rem                           to catpgrants.sql
Rem    jerrede     04/17/12 - Fix Mutex error in cattsdp.sql when creating
Rem                           table tsdp_protection$. Moved from catptabs.sql
Rem                           to catptyps.sql to serialize the operation.
Rem    jerrede     04/11/12 - Fix lrg 6888498 Deadlock in catqueue.sql when
Rem                           processing grants. Move from catptabs.sql to
Rem                           catptyps.sql to serialize the operation.
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sroesch     03/16/12 - Bug 13795730: Add automatic TG install 
Rem    sburanaw    03/12/12 - add catratmask.sql
Rem    rpang       02/02/12 - Network ACL triton migration
Rem    kyagoub     01/12/12 - move catvemxv to catpdeps.sql
Rem    kyagoub     01/05/12 - catemxv.sql depends on catadrvw.sql
Rem    tbhukya     12/22/11 - Add catqitab.sql
Rem    jerrede     12/12/11 - Add Comments for Parallel Upgrade
Rem    hlakshma    11/30/11 - Move catilmtab.sql to avoid dependency issues
Rem                           (bug 13430821)
Rem    hlakshma    11/10/11 - Add ILM related tables
Rem    jerrede     11/04/11 - Fix dependency problem found
Rem                           with dbmsautorep.sql when fixing
Rem                           bug 13252372
Rem    shjoshi     09/28/11 - Load spec from dbmsautorep.sql
Rem    dgraj       08/19/11 - Project 32079: Add script for TSDP
Rem    cslink      09/14/11 - Replace catalog views for redaction with
Rem                           catredact
Rem    sslim       09/01/11 - Add rolling upgrade views
Rem    gravipat    08/16/11 - DB Consolidation: Create cdbviews
Rem    swerthei    03/15/11 - force new version on PT.RS branch
Rem    jinjche     03/10/11 - Add Data Guard script
Rem    jheng       03/14/11 - Proj 32973: add catproftab
Rem    jsamuel     05/19/11 - add radm catalog views
Rem    mjstewar    04/26/11 - Add GSM
Rem    snadhika    06/23/09 - Add Triton security catalog table
Rem    amullick    06/15/09 - consolidate archive provider/manager into 
Rem                           DBFS HS: remove catam.sql
Rem    amullick    01/22/09 - Add Archive Provider catalog tables
Rem    rcolle      01/21/09 - only load WRR tables and not views
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    mabhatta    05/07/08 - securefile logging catalog script
Rem    ssvemuri    03/27/08 - Archive Manager catalog tables
Rem    nkgopal     01/11/08 - Add DBMS_AUDIT_MGMT tables and views
Rem    hosu        12/28/07 - move catost.sql to catpdeps.sql
Rem    sylin       12/06/07 - add prvtrctv.plb required by prvtrcmp.plb
Rem    sylin       11/29/07 - add prvtuttv.plb required by prvtutil.plb
Rem    achoi       11/13/07 - add catpexe
Rem    shan        04/13/07 - added catdef.sql
Rem    dvoss       01/03/07 - add catlmnr.sql
Rem    ilistvin    11/22/06 - use catawrtv instead of catawr
Rem    rburns      09/16/06 - split catsvrm.sql
Rem    elu         10/23/06 - add catrep.sql
Rem    schakkap    09/20/06 - fix comments for catost.sql
Rem    mbastawa    08/31/06 - add catcrc.sql
Rem    rburns      08/23/06 - more restructuring
Rem    cdilling    08/03/06 - add catadvtb.sql
Rem    rburns      07/27/06 - more reorganization 
Rem    chliang     05/24/06 - add sscr cat script
Rem    kamsubra    05/19/06 - Adding catkppls.sql 
Rem    kneel       06/01/06 - add cathae.sql 
Rem    rburns      05/19/06 - add queue files 
Rem    mabhatta    05/18/06 - adding transaction backout catalog file 
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
Rem Drop only obsolete and required Data Pump and Metadata API objects FORCE. 
Rem Do not have to drop other object types as CREATE OR REPLACE works for them.
Rem
@@catnodpobs.sql

Rem
Rem Flashback transaction backout
Rem The types are used in dbmstran and prvttran
Rem
@@catbac.sql

Rem
Rem tables and views for UTL_RECOMP package body
Rem
@@prvtrctv.plb

Rem
Rem Views for Application context ( dbmsutil and prvtutil depends on it )
Rem
@@catactx.sql

Rem
Rem View and types for dbms_utility package body
Rem
@@prvtuttv.plb

Rem
Rem Server Manager views depends on views created in catspace
Rem
@@catsvrmg.sql

Rem
Rem need before dbms_jobs can be run, so include in this script
Rem Logical Standby package specs
Rem
@@prvtlsis.plb
@@prvtlsss.plb

Rem
Rem Transformations
Rem
@@cattrans.sql

Rem
Rem Rules engine
Rem
@@catrule.sql


Rem
Rem Views for tablespace point in time recovery
Rem
@@catpitr.sql

Rem
Rem DIP account creation
Rem
@@catdip.sql

Rem
Rem Row Level Security catalog views
Rem
@@catrls.sql

Rem
Rem Script for Application Role
Rem
@@catar.sql

Rem Script for Fine Grained Auditing
Rem
@@catfga.sql

Rem
Rem Script for DBMS_AUDIT_MGMT
Rem
@@catamgt.sql

Rem
Rem Index Rebuild Views and Body
Rem
@@catidxu.sql

Rem
Rem Transparent Session Migration
Rem
@@cattsm.sql

Rem
Rem Change Notification
Rem
@@catchnf.sql

Rem
Rem Data Mining
Rem
@@catodm.sql

Rem
Rem Connection pool
Rem
@@catkppls.sql

Rem
Rem Session State Capture and Restore (SSCR)
Rem
@@catsscr.sql

Rem
Rem Advanced Queues
Rem
@@catqueue.sql

Rem
Rem High Availabilty Events (FAN alerts)
Rem
@@cathae.sql

Rem
Rem Manageability Advisor
Rem
@@catadvtb.sql

Rem
Rem Scheduler tables
Rem
@@catsch.sql

Rem
Rem Stored outline catalog views
Rem
@@catol.sql

Rem
Rem DataPump views
Rem
@@catdpb.sql

Rem
Rem Client result cache
Rem
@@catcrc.sql

Rem
Rem Component Registry Package spec and views
Rem
@@dbmscr.sql

Rem
Rem dbms_utility used in package specs
Rem
@@dbmsutil.sql

Rem
Rem Create the DB Feature Usage tables/views
Rem
@@catdbfus.sql

Rem
Rem Create server alert schema
Rem
@@catalrt.sql

Rem
Rem Create Autotask Schema
Rem
@@catatsk.sql

Rem
Rem create dbms monitor schema
Rem
@@catmntr.sql

Rem
Rem create SQL Tune schema
Rem
@@catsqlt.sql

Rem 
Rem create SVRMAN UMF schema
Rem 
@@catumftv.sql

Rem
Rem SQL Management Base (SMB) catalog views
Rem
@@catsmbvw.sql

Rem
Rem Create the WRR$ schema
Rem
@@catwrrtb.sql

Rem
Rem SQL Access Advisor tables
Rem
@@catsumat.sql

Rem
Rem Logminer tables and views
Rem
@@catlmnr.sql

Rem
Rem Catdef, default password table and views
Rem
@@catdef.sql

Rem 
Rem @@catpvf.sql has been moved to catpdeps - Bug 22730089
Rem Its safe to remove this comment in future
Rem

Rem
Rem Catadrvw - the adr views/synonyms/grants
Rem
@@catadrvw.sql

Rem Manageability/Diagnosability Report Framework
Rem tables are created in catpstrt.sql
Rem
@@catrepv.sql

Rem
Rem DBMS_PARALLEL_EXECUTE table
Rem
@@catpexe.sql

Rem
Rem securefile logging catalog tables
Rem
@@cattlog.sql

Rem
Rem ContentAPI
Rem
@@catcapi.sql

Rem
Rem archive provider catalog tables
Rem
@@catpspi.sql

Rem
Rem triton security tables
Rem
@@catts.sql

Rem
Rem Network ACLs
Rem
@@catnacl.sql

Rem Real-time Application-controlled Data Masking
Rem
@@catredact.sql

Rem
Rem privilege profile tables and views
Rem
@@catproftab.sql

Rem
Rem Data Guard views
Rem
@@catpstdy.sql

Rem
Rem RAT Masking tables
Rem
@@catratmask.sql

Rem
Rem Queryable patch inventory
Rem
@@catqitab.sql

Rem transaction guard
@@catappcont.sql

Rem  JSON views
@@catjsonv.sql

Rem proj-58146
Rem Creating REMOTE_SCHEDULER_AGENT user
@@catrsa.sql

Rem Application Container Tables
@@catappcontainer.sql

Rem
Rem Hang Manager parameter table
Rem
@@cathmgr

Rem MV Refresh stats
@@catmvrs.sql

Rem Exadirect Secure ACL table
@@cataclsrv.sql

Rem DBLINKS sources and logons tables
@@catdbl.sql

Rem Global dictionary tables
@@catgdtab.sql

Rem FastStart dictionary tables
@@catimfstab.sql

Rem In-Memory Expressions dictionary tables
@@catimime.sql

Rem *********************************************************************
Rem END catptabs.sql
Rem *********************************************************************

@?/rdbms/admin/sqlsessend.sql
