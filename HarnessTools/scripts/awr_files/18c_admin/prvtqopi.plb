  Rem
Rem $Header: rdbms/src/client/tools/qpinv/prvtqopi.sql /st_rdbms_18.0/1 2018/03/05 00:47:50 sspulava Exp $
Rem
Rem $Header: rdbms/src/client/tools/qpinv/prvtqopi.sql /st_rdbms_18.0/1 2018/03/05 00:47:50 sspulava Exp $
Rem
Rem prvtqopi.sql
Rem
Rem Copyright (c) 2011, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      prvtqopi.sql - Implementation of DBMS_QOPATCH
Rem
Rem    DESCRIPTION
Rem      DBMS_QOPATCH APIs to get inventory details.
Rem
Rem    NOTES
Rem      .
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/src/client/tools/qpinv/prvtqopi.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/prvtqopi.plb
Rem SQL_PHASE: CATPPRVT_MAIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
rem    sspulava    03/01/18 - BUG 27553758 - CONTENT INCLUSION OF 27169796 IN
rem                           DATABASE RU 18.0.0.0.0
rem    apfwkr      02/15/18 - Backport apfwkr_blr_backport_27169796_12.2.0.1.0
rem                           from st_rdbms_12.2.0.1.0
rem    sspulava    10/22/17 - move xslt variable to package body(this file)
rem                           B#26370219
rem    sspulava    08/21/17 - 26641610 Fixing space trim logic, using trim
rem    sspulava    08/21/17 - 26641610 Fixing space trim logic, using rtrim
rem    prprprak    03/28/17 - #23333567 Create non public clean_metadata
rem			       to avoid release lock in clean_metadata
rem    prprprak    03/10/17 - #25442858 Remove qopatch.log 
rem 			       file from script directory
rem    prprprak    03/09/17 - #22995820 Logging and diag
rem    surman      03/08/17 - 25425451: Intelligent bootstrap
rem    sspulava    12/20/17 - BLR 27301349 fetching hostname from gvInstance
rem    apfwkr      12/21/17 - Backport
rem                           sspulava_ci_backport_27169796_12.1.0.2.171219fa-dbbp
rem                           from st_rdbms_12.1.0.2.0p4fadbbp
rem    dkoppar     04/10/16 - #22889182 check and clean job
rem    dkoppar     02/02/16 - #21471484 gold image support
rem    dkoppar     11/03/15 - #21143559 long identifier support
rem    ssathyan    11/10/15 - #22171584 add event for sanity check 
rem    dkoppar     11/03/15 - #21143559 long identifier support
rem    dkoppar     10/19/15 - #22062026 switch to original node and instance
rem                           when we query across nodes
Rem    sspulava    12/04/17 - using gvInstance for fetching hostname and
Rem                           instance_name instead of vActive_instances(it
Rem                           truncates hostname:instname combination to
Rem                           60chars, as of today)
rem    dkoppar     10/16/15 - #22026338 cleanup failed when opatch_inst_job had
rem                           no data
rem    ssathyan    09/27/15 - #21864223 print exceptions and handle error
rem    dkoppar     09/06/15 - RO changes
rem    surman      08/26/15 - 20772435: Move SQL registry dependents to
rem                           catxrd.sql
rem    dkoppar     08/10/15 - #21235521 handle switching instances in policy
rem                           managed DB
rem    ssathyan    05/21/15 - #18592717 Move qopatch logs
rem    dkoppar     12/17/14 - #19938082 add additional APIs - OOW
rem    dkoppar     04/15/15 - #20879709 add concurrency contol
rem    dkoppar     08/18/14 - #19454638 fix check for test enabled
rem    dkoppar     08/06/14 - #19379529 UTL_FILE and directory objects issue
rem    dkoppar     06/13/14 - #18909599  patch up directory objects if
rem                           these are outof sync with OH
rem    dkoppar     06/11/14 - #18935334 optimzations in jobs
rem    dkoppar     05/10/14 - add debug statements for GV
Rem    dkoppar     04/23/14 - #18416476 diag improvement
Rem    dkoppar     03/11/14 - #18122066 cleanup in pending_activity
Rem    dkoppar     03/04/14 - gv$ implementation
Rem    dkoppar     01/15/14 - #18080354 add checks for Windows x64- 233 port
Rem    surman      01/12/14 - 13922626: Update SQL metadata
Rem    dkoppar     01/01/14 - #15842666 add templates
Rem    dkoppar     12/06/13 - #17665104 add patch UID for pending_activity()
Rem    dkoppar     09/17/13 - #17344263 put sanity checks before run
Rem    tbhukya     11/24/12 - Bug 15913092 : Donot use job for non-rac
Rem    dkoppar     10/04/12 - #14648409 add sqlpatch interface with sql
Rem                           registry
Rem    dkoppar     09/19/12 - Init xslt
Rem    tbhukya     09/17/12 - Bug 14633572 : Improve error handling
Rem    dkoppar     08/27/12 - implement pending activity for non-RAC
Rem    tbhukya     07/13/12 - Implement RAC specific apis
Rem    dkoppar     07/01/12 - add xml support
Rem    tbhukya     05/24/12 - Enable job code
Rem    tbhukya     05/23/12 - Disable job code`
Rem    tbhukya     05/08/12 - Add opatch_run_stop_job api
Rem    surman      04/17/12 - 13615447: Add SQL patching tags
Rem    tbhukya     06/19/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql



CREATE OR REPLACE PACKAGE BODY DBMS_QOPATCH wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
13c73 4e1d
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

/
show errors

@?/rdbms/admin/sqlsessend.sql
