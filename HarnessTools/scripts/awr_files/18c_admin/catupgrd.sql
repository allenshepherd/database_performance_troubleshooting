Rem
Rem $Header: rdbms/admin/catupgrd.sql /main/48 2017/05/26 05:12:29 raeburns Exp $
Rem
Rem catupgrd.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupgrd.sql - Catalog Upgrade to the new release
Rem
Rem    DESCRIPTION
Rem     This script is to be used for upgrading a 11.2.0.3, 11.2.0.4,
Rem     or 12.1 database to the new release.
Rem     This script provides a direct upgrade path from these releases
Rem     to the new Oracle release.
Rem
Rem      The upgrade is partitioned into the following 5 stages:
Rem        STAGE 1: call the "i" script for the oldest supported release:
Rem                 This loads all tables that are necessary
Rem                 to perform basic DDL commands for the new release
Rem        STAGE 2: call utlip.sql to invalidate PL/SQL objects
Rem        STAGE 3: Determine the original release and call the 
Rem                 c0x0x0x0.sql for the release.  This performs all 
Rem                 necessary dictionary upgrade actions to bring the 
Rem                 database from the original release to new release.
Rem
Rem    NOTES
Rem
Rem      * This script needs to be run in the new release environment
Rem        (after installing the release to which you want to upgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupgrd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupgrd.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    pyam        11/10/16 - 70732: move catappupgend
Rem    pyam        12/02/15 - 22282825: move catendappupg earlier
Rem    frealvar    08/11/15 - bug21274752: Added suport to add two new tags
Rem    jerrede     07/27/15 - Add Description
Rem    pyam        05/20/15 - cdb upgrade optimizations
Rem    jerrede     05/14/15 - Bug 21091219 support read only table spaces
Rem    jerrede     04/15/15 - Add Running of Mandatory Post Upgrade
Rem    jerrede     03/10/15 - Bug 18877911 Make post upgrade mandatory.
Rem    cmlim       10/20/14 - bug 19732293: update correct versions supported
Rem                           for db upgrades in description comment
Rem    jerrede     07/08/14 - Removed Exit in catupgrd.sql not tolerated
Rem                           by catcon.  The exit was initially put
Rem                           in to fix bug 12337546.
Rem    jerrede     04/03/14 - Bug 18500239 Run ultrp in PDB$SEED
Rem    traney      01/14/14 - 18074131: remove unnecessary scripts
Rem    jerrede     10/08/13 - Make catuppst Multi process
Rem    jerrede     09/12/13 - Root first processing.
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     08/29/12 - Mandatory Post Upgrade
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jerrede     03/16/12 - Fix Display Comments
Rem    jerrede     02/02/12 - Fix Bug 13656337
Rem    jerrede     12/12/11 - Add Comments for Parallel Upgrade
Rem    jerrede     10/28/11 - Fix Bug 13252372
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    cmlim       04/19/11 - bug 12337546: exit from catupgrd.sql at end of
Rem                           upgrade
Rem    skabraha    03/03/11 - move validate_all_versions to catupprc.sql
Rem    skabraha    07/22/10 - reset all old version types to valid
Rem    cdilling    03/29/07 - set error logging off - bug 5959958
Rem    rburns      12/11/06 - eliminate first phase
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - restructure for parallel upgrade 
Rem    rburns      02/15/06 - re-run message with expected errors
Rem    gviswana    03/09/06 - Add utlrdt 
Rem    rburns      02/10/06 - fix re-run logic for 11.1 
Rem    rburns      01/10/06 - release 11.1.0 
Rem    rburns      11/09/05 - version fixes
Rem    rburns      10/21/05 - remove 817 and 901 upgrades 
Rem    cdilling    09/28/05 - temporary version until db version updated
Rem    ssubrama    08/17/05 - bug 4523571 add note before utlip 
Rem    sagrawal    06/28/05 - invalidate PL/SQL objects for upgrade to 11 
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      10/18/04 - remove catpatch.sql 
Rem    rburns      09/02/04 - remove dbms_output compile 
Rem    rburns      06/17/04 - use registry log and utlusts 
Rem    mvemulap    05/26/04 - grid mcode compatibility 
Rem    jstamos     05/20/04 - utlip workaround 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      01/27/04 - Created
Rem


DOC
######################################################################
######################################################################
                                 ERROR

    
    As of 12.2, customers must use the parallel upgrade utility, catctl.pl,
    to invoke catupgrd.sql when upgrading the database dictionary.
    Running catupgrd.sql directly from SQL*Plus is no longer supported. 

    For Example:

          cd $ORACLE_HOME/rdbms/admin
          catctl

          or

          cd $ORACLE_HOME/rdbms/admin
          $ORACLE_HOME/perl/bin/perl catctl.pl catupgrd.sql

    Refer to the Oracle Database Upgrade Guide for more information.


######################################################################
######################################################################
#

EXIT;
WHENEVER SQLERROR CONTINUE;

Rem **********************************************************************
Rem 
Rem  NOTE: SQL CODE NOT PERMITTED IN THIS FILE ONLY THE EXECUTION OF A
Rem       .SQL or .PLB file.
Rem
Rem **********************************************************************

Rem
Rem Initial checks and RDBMS upgrade scripts
Rem
@@catupstr.sql

Rem
Rem Execute upgrade and catalog session script
Rem
@@catupses.sql    --CATFILE -SES
@@catalogses.sql  --CATFILE -SESS

Rem
Rem Run catalog with some multiprocess phases
Rem
@@catalog.sql     --CATFILE -X

Rem
Rem Execute catproc session script
Rem
@@catprocses.sql  --CATFILE -SESE -SESS

Rem
Rem Run catproc with some multiprocess phases
Rem
@@catproc.sql     --CATFILE -X

--CATCTL -R
--CATCTL -S -D "Final RDBMS scripts"
Rem
Rem Final RDBMS upgrade scripts
Rem
@@catupprc.sql

Rem
Rem Upgrade components with some multiprocess phases
Rem
@@cmpupgrd.sql    --CATFILE -X -SESE

--CATCTL -S -D "Final Upgrade scripts"
Rem
Rem Final upgrade scripts
Rem
@@catupend.sql

Rem
Rem Run utlmmig and catresults, then shutdown the database.
Rem
--CATCTL -S -D "Migration"
@@catmmig.sql

--CATCTL -S -D "End PDB Application Upgrade Pre-Shutdown"
Rem
Rem This ends the PDB Application Upgrade, used to capture statements.
Rem
@@catappupgend

--CATCTL -S
@@catshutdownpdb.sql

--CATCTL -S
@@catshutdown.sql

Rem
Rem Post Upgrade Script
Rem
--CATCTL -S -D "Post Upgrade"
@@catuppst.sql
--CATCTL -S -D "Summary report"
@@catresults.sql
--CATCTL -S -D "End PDB Application Upgrade Post-Shutdown"
Rem
Rem This ends the PDB Application Upgrade, used to capture statements.
Rem
@@catappupgend
--CATCTL -PSE @catshutdownpdb.sql EOL
--CATCTL -PSE @catshutdown.sql EOL

REM
REM NOTE:
REM   Database has been shut down
REM   NO SQL Commands beyond this point
REM 
REM END OF CATUPGRD.SQL


Rem *********************************************************************
Rem END catupgrd.sql
Rem *********************************************************************
