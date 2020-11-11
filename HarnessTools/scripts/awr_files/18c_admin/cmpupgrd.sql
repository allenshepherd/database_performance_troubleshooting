Rem
Rem $Header: rdbms/admin/cmpupgrd.sql /main/26 2017/09/05 17:58:53 raeburns Exp $
Rem
Rem cmpupgrd.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupgrd.sql - CoMPonent UPGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script upgrades the components in the database
Rem
Rem    NOTES
Rem      When run with catctl.pl, components can use
Rem         CATCTL -CP <comp_id>  or
Rem         CATCTL -CP <comp_id> -X
Rem      to invoke a <compid>upgrd.sql script with or with out
Rem      additional CATCTL annotations (-X option)
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupgrd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupgrd.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupgrd.sql
Rem SQL_DRIVER_ONLY: YES
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/01/17 - RTI 20238715: revert parallel component upgrades
Rem                           due to GRANT/REVOKE timeouts and deadlocks
Rem    raeburns    06/08/17 - Bug 26241638: re-enable SDO parallel upgrade
Rem    raeburns    05/14/17 - Bug 25906282: Use SQL_DRIVER_ONLY
Rem    frealvar    04/27/17 - Bug 25944951 fix deadlock issue in sqljutl
Rem    raeburns    02/23/17 - Bug 25790099: run component upgrade in parallel
Rem    raeburns    11/28/16 - Bug 25149769: Revert SDO to non-parallel
Rem                           processing
Rem    raeburns    10/31/16 - Bug 23231337: remove APEX upgrade/downgrade
Rem    jerrede     07/27/15 - Add Description
Rem    raeburns    01/15/15 - add APEX upgrade using CATCTL
Rem    raeburns    12/20/14 - enable SDO parallel upgrade
Rem    raeburns    12/10/14 - Project 46657: add ORDIM parallel upgrade
Rem    raeburns    11/21/14 - enable XDB parallel upgrade
Rem    raeburns    08/20/14 - Use catctl directly for XDB upgrade
Rem                         - Add XDB session initialization
Rem    jerrede     07/25/13 - Serialize for CDB
Rem    jerrede     04/03/13 - Support for CDB
Rem    jerrede     02/11/13 - Fix Syntax Error
Rem    jerrede     01/08/13 - Lrg 8580699 DeadLock Issue Registering 
Rem                           ordexif.xsd with XDB under
Rem                           http://xmlns.oracle.com/ord/meta/exif
Rem    jerrede     01/07/13 - Lrg 8652277 Make JAVM Serial deadlock issue
Rem                           when running jvmrm.sql during the FULL_REMOVAL
Rem                           or GRADE_REMOVAL.
Rem    jerrede     05/08/12 - Fix lrg 6730954 Definition problem in Windows
Rem                           with moving from phase to phase need to restart
Rem                           between all phases
Rem    jerrede     04/25/12 - Bug 13995725 Serial OWM because of Deadlocks
Rem                           Moved from cmpupord.sql to cmpupnxb.sql
Rem    jerrede     02/03/12 - Fix lock issue loading rdbms/jlib/CDC.jar lrg
Rem                           6728210
Rem    jerrede     12/12/11 - Add Comments for Parallel Upgrade
Rem    jerrede     10/18/11 - Parallel Upgrade ntt Changes
Rem    badeoti     09/30/10 - diagnostic errorstack for intermittent ORA-31061
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during migrations
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem


Rem **********************************************************************
Rem 
Rem  NOTE: SQL CODE NOT PERMITTED IN THIS FILE ONLY THE EXECUTION OF A
Rem       .SQL or .PLB file.
Rem
Rem **********************************************************************

--CATCTL -S -D "Upgrade Component Start"
@@cmpupstr.sql

--CATCTL -R
--CATCTL -S  -D "Upgrading Java and non-Java" 
Rem
Rem Java upgrade (JAVAVM, XML, CATJAVA)
Rem
@@cmpupjav.sql

Rem
Rem non-Java dependent upgrades (include XDB and Dependent since all
Rem     single process while Java components being upgraded in other single 
Rem     process):
Rem     APS, AMD, OLS, DV, CONTEXT, XDB, OWM, MGW, RAC
Rem 
@@cmpupnjv.sql

--CATCTL -R -D "Upgrading XDB"
Rem
Rem Oracle XDB (uses catctl directly)
Rem
--CATCTL -CP XDB -X

--CATCTL -R -D "Upgrading ORDIM"
Rem
Rem Oracle Multimedia
Rem
--CATCTL -CP ORDIM -X

Rem Install ORDIM if Spatial is in the DB but ORDIM is not
@@cmpupord.sql

--CATCTL -R -D "Upgrading SDO"
Rem
Rem Spatial  (uses catctl directly)
Rem
--CATCTL -CP SDO -X

--CATCTL -R
--CATCTL -S
Rem
Rem check for XE db and upgrade locator
Rem
@@cmpupsdo.sql

--CATCTL -R
--CATCTL -S -D "Upgrading ODM, WK, EXF, RUL, XOQ"
@@cmpupmsc.sql

--CATCTL -R
--CATCTL -S -D "Final Component scripts "
Rem
Rem Final component actions
Rem
@@cmpupend.sql


Rem *********************************************************************
Rem END cmpupgrd.sql
Rem *********************************************************************
