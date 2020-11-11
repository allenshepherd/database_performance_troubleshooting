Rem
Rem
Rem catpdeps.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpdeps.sql - CATProc DEPendents
Rem
Rem    DESCRIPTION
Rem      This script creates objects that have dependencies on package 
Rem      specifications and standalone procedures and functions.
Rem
Rem    NOTES
Rem      This script must be run only as a subscript of catproc.sql
Rem      It is run single process by catctl.pl.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpdeps.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpdeps.sql
Rem SQL_PHASE: CATPDEPS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    anbhasu     07/11/17 - Bug 22730089: Moved catpvf from catptabs
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    sdavidso    01/26/17 - bug25225293 have catmettypes.sql execute before
Rem                           dbmsmeta.sql
Rem    sdipirro    11/16/15 - Add prvthdpi.plb
Rem    jerrede     10/19/15 - Bug 21978311 Fix deadlock between
Rem                           catmetgrant1.sql,prvtrepl.sql,catumfusr.sql and
Rem                           catpstr.sql.  Move prvtrepl.sql,catunfusr.sql
Rem                           and catpstr.sql to a serial fast load phase.
Rem    svivian     10/15/15 - bug 21882092: replace dbmslms.sql with 
Rem                           prvtlmss.plb
Rem    msabesan    09/12/15 - bug 21826062: add catumfusr.sql 
Rem    amunnoli    06/16/15 - Proj 46892: Add catuat.sql
Rem    molagapp    01/14/15 - Project 47808 - Restore from preplugin backup
Rem    mthiyaga    07/23/14 - Add cathive.sql
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jerrede     10/15/12 - Move dependency issues out of catpdeps.sql
Rem                           All KUPU$UTILITIES functions.
Rem    pmojjada    08/01/12 - bug 14369888: removed reference to prvtctx
Rem    alui        07/22/12 - move dbmswlm.sql for RM dependency
Rem    jerrede     05/08/12 - Fix lrg 6730954 Definition problem in Windows
Rem                           with moving from phase to phase need to restart
Rem                           between all phases
Rem    rpang       04/17/12 - Move dbmanacl.sql for xs dependency
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jerrede     03/01/12 - Fix lrg 6735059 Dependency Errors
Rem    schakkap    02/20/12 - #(9316756) move catspd.sql to catost.sql
Rem    rpang       02/13/12 - Network ACL triton migration
Rem    kyagoub     01/12/12 - move catvemxv from catptabs.sql
Rem    jerrede     12/27/11 - Fix Deadlock Issue
Rem    jerrede     12/13/11 - Add Comments for Parallel Upgrade
Rem    jerrede     10/17/11 - Parallel Upgrade ntt Changes
Rem    jerrede     10/06/11 - Fix lrg 5829047 Dependency Warning Errors
Rem    pyam        09/12/11 - readd @@prvthpci.plb to fix CDB create
Rem    jerrede     09/08/11 - Parallel Upgrade Project #23496 change file
Rem                           names for catmeta files.
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    liaguo      06/08/11 - Project 32788 DB ILM: add catilm.sql
Rem    paestrad    05/20/11 - Adding DBMS_CREDENTIAL package
Rem    schakkap    05/05/11 - project SPD (31794): add catspd.sql
Rem    gravipat    05/11/11 - DB consolidation: Add table function to create
Rem                           CDB views
Rem    schitti     01/29/09 - AP Support
Rem    kkunchit    01/15/09 - ContentAPI support
Rem    rcolle      01/21/09 - add catwrrvw.sql
Rem    sjanardh    07/01/08 - Add prvtaqiu.lb
Rem    rapayne     06/27/08 - load catmeta.sql after prvtkupc.plb
Rem    msakayed    04/16/08 - compression/encryption feature tracking for 11.2
Rem    akoeller    01/10/08 - Add catrssch.sql
Rem    hosu        12/27/07 - add catost.sql (view dependent on dbmsstat)
Rem    sylin       11/27/07 - move prvtutil.plb to catpprvt
Rem    sylin       11/15/07 - Add prvtsys.plb
Rem    achoi       11/13/07 - add catpexev
Rem    vakrishn    02/16/07 - txn layer dependent objects
Rem    rburns      09/17/06 - add svrm dependents
Rem    jinwu       11/14/06 - add prvthsts prvthfgr prvthcmp
Rem    jinwu       11/13/06 - add catstr.sql
Rem    rburns      08/23/06 - more restructuring
Rem    cdilling    08/07/06 - add catadv.sql
Rem    rburns      07/29/06 - more restructure 
Rem    kneel       06/05/06 - moving execution of prvthdbu to catpdeps.sql 
Rem    kneel       06/04/06 - moving execution of dbmshae.sql to catpdeps.sql 
Rem    rburns      05/24/06 - add prvthlrt 
Rem    rburns      05/19/06 - break up catqueue.sql 
Rem    rburns      01/13/06 - split for parallel processing 
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
Rem pl/sql tracing package
Rem
@@prvthdbu.plb

Rem
Rem Optimizer Statistics tables and views that can not be created while running 
Rem catalog.sql due to dependency on other objects
Rem
@@catost.sql

Rem
Rem High Availabilty Events (FAN alerts)
Rem  - dependent on dbmsslrt.sql (dbms_server_alert)
Rem
@@dbmshae.sql

Rem
Rem Views for XA recovery - depends on dbmsraw
Rem
@@catxpend.sql

Rem
Rem STREAMS scripts use SET SERVEROUTPUT ON
Rem
@@prvtotpt.plb

Rem
Rem STREAMS
Rem need to load prvthlut here because of dependency on bit,bis,bic
Rem
@@prvthlut.plb

Rem
Rem need to load prvthlin here because AQ export needs it
Rem
@@prvthlin.plb

Rem
Rem Streams Datapump package specs. AQ and LSBY need it.
Rem
@@prvthsdp.plb

Rem
Rem on-disk versions of rman support
Rem contains type body for v_lbRecSetImpl_t
Rem
@@dbmsrman.sql
@@dbmsbkrs.sql
@@dbmspplb.sql

Rem
Rem System event attribute functions
Rem contains standalone functions
Rem
@@dbmstrig.sql

Rem
Rem Random number generator
Rem contains spec and body for dbms_random
Rem
@@dbmsrand.sql

Rem
Rem Multi-language debug support
Rem contains bodies with order dependencies
Rem
@@dbmsjdwp.sql

Rem
Rem OLAP Services
Rem
@@catxs.sql

Rem
Rem dbms_snapshot
Rem depends on dbms_sql?
Rem
@@dbmssnap.sql

Rem
Rem Materialized views
Rem depends on type created in dbmssnap
Rem
@@prvtxrmv.plb

Rem
Rem AQ dependencies
Rem
@@depsaq.sql

Rem
Rem Server-generated alert dependent file
Rem
@@prvthlrt.plb

Rem
Rem Manageability Advisor
Rem
@@catadv.sql

Rem
Rem DBMS_CREDENTIAL package
Rem
@@dbmscred.sql
@@catcredv.sql

Rem
Rem AQ Dependencies on Scheduler:
Rem
@@cataqsch.sql

Rem
Rem RLS Dependencies on Schedule:
Rem
@@catrssch.sql

Rem
Rem Views for transportable tablespace
Rem Dependencies on queues
Rem
@@catplug.sql

Rem
Rem load dbms_sql and ddbms_assert before logminer
Rem
@@prvtsql.plb
@@prvtssql.plb

Rem
Rem runs logmnr_install
Rem
@@prvtlmd.plb
@@prvtlmcs.plb
@@prvtlmrs.plb
@@prvtlmss.plb

Rem
Rem KUPV$FT private package header (depends on types in dbmsdp.sql)
Rem
@@prvthpv.plb


--CATCTL -R
--CATCTL -S
Rem
Rem KUPCC private types and constants (depends on types in dbmsdp.sql
Rem                                    and routines in prvtbpv)
Rem Metadata API type and view defs for object view of dictionary
Rem Dependent on dbmsmetu
Rem
@@prvtkupc.plb

Rem
Rem AQ dependencies
Rem
@@prvtaqiu.plb

Rem
Rem Logical Standby tables & views & procedures
Rem depends on dbmscr.sql and other objects
Rem
@@catlsby.sql

--CATCTL -R
--CATCTL -M
Rem
Rem Metadata API type and view defs for object view of dictionary
Rem Dependent on dbmsmetu
Rem
@@catmetviews.sql

Rem
Rem KUPW$WORKER private package header (depends on types in prvtkupc.plb)
Rem
@@prvthpw.plb 

Rem
Rem KUPM$MCP private package header  (depends on types in prvtkupc.plb)
Rem
@@prvthpm.plb 

Rem
Rem KUPF$FILE_INT private package header
Rem
@@prvthpfi.plb

Rem
Rem KUPF$FILE private package header
Rem
@@prvthpf.plb

Rem
Rem dbms_datapump_int private package header
Rem
@@prvthdpi.plb

Rem
Rem Data Mining
Rem depends on dbms_assert and dbms metadata
Rem
@@dbmsodm.sql

Rem
Rem Internal Trigger package spec and body 
Rem snapshot package bodies depend on this
Rem
@@prvtitrg.plb

Rem
Rem Summary Advisor
Rem
@@prvtsms.plb

Rem
Rem Server Manageability
Rem
@@depssvrm.sql

Rem
Rem Transaction layer dependent objects
Rem
@@deptxn.sql

Rem
Rem dba_capture depends on dba_logmnr_session (prvtlmd)
Rem Streams catalog views
Rem
@@catstr.sql

Rem
Rem prvthsts prvthfgr and prvthcmp need DBMS_LOGREP_UTIL (prvthlut),
Rem ku$_Status and ku$_JobDesc (dbmsdp.sql).
Rem Streams TableSpaces headers
Rem
@@prvthsts.plb

Rem
Rem File Group headers
Rem
@@prvthfgr.plb
@@prvthfie.plb

Rem
Rem Data Comparison headers
Rem
@@prvthcmp.plb

Rem
Rem DBMS_PARALLEL_EXECUTE views
Rem
@@catpexev.sql

Rem
Rem ContentAPI
Rem
@@depscapi.sql

Rem
Rem PSPI Views
Rem
@@depspspi.sql

Rem
Rem DBMS_WORKLOAD_CAPTURE and DBMS_WORKLOAD_REPLAY views
Rem
@@catwrrvw.sql

Rem
Rem Multi-language debug support
Rem contains bodies with order dependencies
Rem
@@dbmsjdcu.sql
@@dbmsjdmp.sql

Rem
Rem KUPC$QUEUE invokers private package header
Rem (depends on types in prvtkupc, prvtbpc)
Rem
@@prvthpc.plb

Rem
Rem hdm pkg
Rem
@@prvt_awr_data.plb

--CATCTL -R
--CATCTL -M
Rem
Rem Grant Privs
Rem
@@catmetgrant1.sql
Rem
Rem DBMS_LDAP package
Rem
@@catldap.sql
Rem
Rem OCM Integration
Rem
@@prvtocm.sql

Rem
Rem NOTE: 
Rem    prvthpci.plb must be in catpdeps.sql for CDB project.
Rem 
Rem KUPC$QUEUE_INT definers private package header (depends on prvtkupc)
Rem
@@prvthpci.plb

Rem
Rem DB ILM views
Rem
@@catilm.sql

Rem
Rem EM Express
Rem tables are created in catpstrt.sql
Rem catemxv because of the em_express_basic role depends on catadrvw.sql
Rem which is sourced in catptabs.sql
Rem
@@catemxv.sql

Rem
Rem Network ACL views
Rem These views are created in catpdeps.sql because of dependency on Triton
Rem views which are created in catptabs.sql
Rem
@@catnaclv.sql

Rem
Rem Network ACL packages
Rem The DBMS_NETWORK_ACL_ADMIN package is created in catpdeps.sql because of
Rem dependency on xs$ace_type created in catpdbms.sql
Rem
@@dbmsnacl.sql

Rem
Rem Complexity functions for passwords.
Rem Oracle provided password verify functions are created in catpdeps.sql 
Rem because of dependency on UTL_LMS created in catpdbms.sql
Rem
@@catpvf.sql

Rem
Rem WLM package
Rem Dependent on dbmsrmin created in catpdbms.sql
Rem
@@dbmswlm.sql

Rem
Rem Oracle catalog views for Hive metastore
Rem
@@cathive.sql

Rem
Rem Unified Audit Trail dependent views and procedures
Rem
@@catuat.sql

--CATCTL -R
--CATCTL -CS
--CATCTL -S

Rem
Rem Replication
Rem
@@prvtrepl.sql
Rem
Rem Streams PL/SQL packages
Rem
@@catpstr.sql
Rem
Rem Create UMF role/user. 
Rem
@@catumfusr.sql

--CATCTL -CE


Rem *********************************************************************
Rem END catpdeps.sql
Rem *********************************************************************

@?/rdbms/admin/sqlsessend.sql
