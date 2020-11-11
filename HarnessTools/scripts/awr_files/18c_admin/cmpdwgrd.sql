Rem $Header: rdbms/admin/cmpdwgrd.sql /main/6 2017/04/20 07:47:01 welin Exp $
Rem
Rem cmpdwgrd.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpdwgrd.sql - downgrade SERVER components to original release
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cmpdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cmpdwgrd.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    welin       04/17/17 - Bug 25838540: Remove EM downgrade
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE 
Rem    raeburns    02/13/17 - Bug 23294337: Add RAC downgrade
Rem    raeburns    10/31/16 - Bug 23231337: remove APEX upgrade/downgrade
Rem    frealvar    07/30/16 - Bug 24332006 added missing metadata
Rem    raeburns    03/30/15 - renaming cmpdbdwg.sql to cmpdwgrd.sql
Rem    cdilling    02/28/14 - remove call to udjvmrm.sql
Rem    clhsu       08/08/12 - add downgradable version 11.x to RAC
Rem    awesley     04/02/12 - deprecate cwm, remove AMD
Rem    srtata      09/15/11 - do OLS downgrade before DV
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during migrations
Rem    cdilling    12/23/09 - fix javavm downgrade status
Rem    cmlim       03/12/08 - support major release downgrade from 11.2 to 11.1
Rem    rburns      01/03/08 - temp remove component check 
Rem                         - and remove udjvmrm.sql for 11.1 downgrade only 
Rem    rburns      08/15/07 - move component check out of catdwgrd.sql
Rem    cdilling    05/21/07 - add support for apex downgrade scripts
Rem    cdilling    12/07/06 - add Data Vault
Rem    cdilling    12/22/06 - fix RAC downgrade version
Rem    rburns      11/17/05 - add RUL 
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      07/01/04 - Fix RAC downgrade version 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created

Rem Setup component script filename variable
COLUMN dbdwg_name NEW_VALUE dbdwg_file NOPRINT;

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

Rem ======================================================================
Rem Downgrade RUL
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('RUL') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EXF
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('EXF') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLS
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OLS') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Downgrade DV
Rem =====================================================================

SELECT dbms_registry_sys.dbdwg_script('DV') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Ultrasearch
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('WK') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;
   
Rem ======================================================================
Rem Downgrade Spatial
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('SDO') AS dbdwg_name FROM DUAL;
@&dbdwg_file 
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Intermedia
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ORDIM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP API
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XOQ') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP Analytic Workspace
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('APS') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Messaging Gateway
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('MGW') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Data Mining
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ODM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Workspace Manager
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OWM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RAC 
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('RAC') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XDB - XML Database 
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XDB') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Text
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CONTEXT') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RDBMS java classes (CATJAVA)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CATJAVA') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XDK for Java
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XML') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade JServer (Last)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('JAVAVM') AS dbdwg_name FROM DUAL;
@&dbdwg_file

SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

-- clear xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context off';

column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version from dba_registry
WHERE comp_id NOT IN ('CATPROC','CATALOG');

DOC
#######################################################################
#######################################################################

 All components in the above query must have a status of DOWNGRADED.
 If not, the following check will get an ORA-39709 error, and the
 downgrade will be aborted. Consult the downgrade chapter of the 
 Oracle Database Upgrade Guide and correct the component problem,
 then re-run this script.

#######################################################################
#######################################################################
#

WHENEVER SQLERROR EXIT;
-- uncomment when all components have downgrade scripts working
-- EXECUTE dbms_registry_sys.check_component_downgrades;
WHENEVER SQLERROR CONTINUE;

Rem ***********************************************************************
Rem END cmpdwgrd.sql
Rem ***********************************************************************

