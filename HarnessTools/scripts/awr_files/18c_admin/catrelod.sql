Rem
Rem $Header: rdbms/admin/catrelod.sql /main/56 2017/10/10 12:10:25 raeburns Exp $
Rem
Rem catrelod.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrelod.sql - Script to apply CATalog RELOaD scripts to a database
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post downgrade" steps necessary
Rem      to reload the PL/SQL and Java packages, types, and classes.
Rem      It runs the "old" versions of catalog.sql and catproc.sql
Rem      and calls the component reload scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catrelod.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catrelod.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/18/17 - Bug 26815460: Check version_full value
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    raeburns    04/12/17 - Bug 25790192: Use UPGRADE as SQL_PHASE
Rem    raeburns    04/09/17 - Version change to 18.0.0
Rem    raeburns    10/31/16 - Bug 23231337: remove APEX upgrade/downgrade
Rem    raeburns    06/20/16 - Bug 24709706: Use version constants from
Rem                           dbms_registry_basic.sql
Rem    welin       06/09/16 - Bug 23238774: set catproc prv_version to full
Rem                           version
Rem    welin       08/10/15 - bug 21548540: catrelod rerunnability
Rem    cmlim       07/27/15 - bug 21329301: alert if time zone file needs to be
Rem                           patched on downgrade reloads
Rem    ewittenb    05/14/15 - include dbms_registry_basic.sql
Rem    cmlim       10/19/14 - lrg 13418229: latest time zone file version is 23
Rem    cmlim       07/07/14 - lrg 12281386: 12.2 is now at time zone file
Rem                           version 22
Rem    anjayaku    06/06/14 - update comments to reflect 12.2
Rem    cdilling    03/13/14 - update version to 12.2
Rem    cmlim       11/26/13 - lrg 10260355: latest time zone file version for
Rem                           12102 is 21
Rem    cmlim       07/05/13 - lrg 8816946: latest time zone file version shipped
Rem                           is 20 in 12.1.0.2 (update 'c_tz_version updated')
Rem    cdilling    05/12/13 - add support for 12.2
Rem    cdilling    01/29/13 - add support for 12.1.0.2
Rem    cdilling    08/30/12 - version is 12.1.0.1
Rem    bmccarth    07/10/12 - tz to 18
Rem    awesley     04/02/12 - deprecate cwm, remove AMD
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cmlim       10/26/11 - update_tzv_17: change time zone file version from
Rem                           16 to 17
Rem    traney      10/12/11 - drop old dictionary clusters
Rem    cmlim       10/04/11 - update_tzv_16: change utlu_tz_version to 16
Rem    traney      09/30/11 - gather bootstrap table stats
Rem    cdilling    05/15/11 - check reload to 12.1
Rem    cdilling    03/02/11 - remove EM component
Rem    cdilling    08/04/10 - add support for 12.1 instance
Rem    skabraha    07/22/10 - reset all old version types to valid
Rem    cmlim       07/20/10 - bug 9803834: check time zone file version before
Rem                           continuing with downgrade reload
Rem    cmlim       04/26/10 - bug 9546509: suggest to force a checkpoint prior
Rem                           to shutdown abort
Rem    cdilling    05/21/09 - check for 8 digits for prv_version
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    jciminsk    10/10/07 - fix typo
Rem    cdilling    10/09/07 - update version to 11.2.0.0.0
Rem    cdilling    12/07/06 - add DV support
Rem    rburns      04/15/06 - remove ODM 
Rem    rburns      01/10/06 - release 11.1.0 
Rem    rburns      10/28/05 - no utlip for patch downgrade 
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      04/16/04 - change version to 10.2 
Rem    rburns      02/23/04 - add EM 
Rem    rburns      04/25/03 - use timestamp
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      01/18/03 - use 10.1 release, add EXF, reorder OLAP
Rem    rburns      01/16/03 - fix @@ and use server registry
Rem    dvoss       01/14/03 - add utllmup.sql
Rem    srtata      10/16/02 - add olsrelod.sql
Rem    rburns      08/27/02 - Add Ultra Search, remove ORDVIR
Rem    rburns      06/12/02 - remove pl/sql usage
Rem    rburns      04/16/02 - rburns_catpatch_920
Rem    rburns      04/03/02 - Created
Rem

Rem *************************************************************************
Rem BEGIN catrelod.sql
Rem *************************************************************************

SELECT 'COMP_TIMESTAMP RELOD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem Get Version constants from dbms_registry_basic.sql
@@dbms_registry_basic.sql

Rem =======================================================================
Rem Verify server version and UPGRADE status (PL/SQL not available yet)
Rem =======================================================================

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database server version is not correct
  Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and use a
  different script or a different server.
#######################################################################
#######################################################################
#

Rem =====================================================================
Rem The following statement confirms that the script version identified by
Rem the &C_ORACLE_HIGH_ sqlplus variables matches the
Rem server version full value from v$instance. The C_ORACLE_HIGH
Rem sqlplus variables are defined in dbms_registry_basic.sql and contains
Rem a version value like 18.10.2.0.0. This value will be
Rem substituted in the query at run time, for example,
Rem TO_NUMBER('MUST_BE_18.10.2')
Rem =====================================================================

SELECT TO_NUMBER(
  'MUST_BE_&C_ORACLE_HIGH_MAJ..&C_ORACLE_HIGH_RU..&C_ORACLE_HIGH_RUR') 
FROM v$instance
WHERE substr(version_full,1,instr(version_full,'.',1,3)-1) !=
      '&C_ORACLE_HIGH_MAJ..&C_ORACLE_HIGH_RU..&C_ORACLE_HIGH_RUR';

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database has not been opened for UPGRADE.  

  Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and 
  restart using UPGRADE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER(status) FROM v$instance
WHERE status != 'OPEN MIGRATE';

DOC
#######################################################################
#######################################################################
  The following query will cause:
  - An "ORA-01722: invalid number"
    if the old Oracle release is expecting a time zone file version
    that does not exist.

  o Action on downgrades:
    Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and
    patch old ORACLE_HOME to the same time zone file version as used
    in the new ORACLE_HOME.
#######################################################################
#######################################################################
#
Rem time zone check
Rem   SELECT TO_NUMBER('MUST_BE_SAME_TIMEZONE_FILE_VERSION')

SELECT TO_NUMBER('MUST_BE_SAME_TIMEZONE_FILE_VERSION')
FROM sys.props$
WHERE (
  (name = 'DST_PRIMARY_TT_VERSION'
    AND TO_NUMBER(value$) > &C_LTZ_CONTENT_VER)
  AND (0 = (select count(*) from v$timezone_file))
  );

Rem =======================================================================
Rem SET nls_length_semantics at session level (bug 1488174)
Rem =======================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =======================================================================
Rem Set event to avoid unnecessary re-compilations
Rem =======================================================================

ALTER SESSION SET EVENTS '10520 TRACE NAME CONTEXT FOREVER, LEVEL 10'; 

Rem =======================================================================
Rem Invalidate all PL/SQL packages and types for major release downgrade
Rem =======================================================================

Rem If CATPROC status is not DOWNGRADED, don't run utlip.sql to invalidate
DEFINE utlip_file = nothing.sql
COLUMN utlip_name NEW_VALUE utlip_file NOPRINT;
SELECT 'utlip.sql' AS utlip_name FROM sys.registry$
       WHERE cid = 'CATPROC' AND namespace = 'SERVER' AND status = 7;   
@@&utlip_file

Rem =======================================================================
Rem Confirm that the previous release was this release, using the 
Rem C_ORACLE_HIGH_VERSIONFULL sqlplus variable from dbms_registry_basic.sql
Rem to compare to the registry$ CATPROC prv_version_full.
Rem =======================================================================

-- get dbms_registry_extended package for version compare
@dbms_registry_extended.sql

DECLARE
  p_prv_version      sys.registry$.prv_version%type;
  p_prv_version_full sys.registry$.prv_version_full%type;
  p_version          sys.registry$.version%type;
  p_version_full     sys.registry$.version_full%type;
BEGIN
  SELECT prv_version, version, prv_version_full, version_full 
  INTO p_prv_version, p_version, p_prv_version_full, p_version_full
  FROM registry$ WHERE cid = 'CATPROC' AND namespace = 'SERVER';

  -- Allow catrelod to run if the previous version is NULL (a newly created DB)
  -- or if the previous version is less than or equal to the current server 
  -- version (e.g, allow reload of 18.5.1.0.0 into 18.10.0.0.0, but not 
  -- into 18.2.0.0.0)
  IF p_prv_version_full IS NOT NULL AND 
     dbms_registry_extended.compare_versions 
         (p_prv_version_full, '&C_ORACLE_HIGH_VERSIONFULL') > 0 THEN
     RAISE_APPLICATION_ERROR (-20000,
        'Upgrade from version ' || p_prv_version_full ||
        ' cannot be downgraded to version &C_ORACLE_HIGH_VERSIONFULL');
  END IF;
  IF p_version='&C_ORACLE_HIGH_MAJ' THEN
     -- Set the version to the full version value, not just the major version
     -- e.g., 18.5.1.0.0 instead of 18 as set in the downgrade script.
     update registry$ set version=p_prv_version, 
         version_full=p_prv_version_full 
         WHERE cid = 'CATPROC' AND namespace = 'SERVER';
     commit;
  END IF;
END;
/


WHENEVER SQLERROR CONTINUE;

Rem =======================================================================
Rem Run catalog.sql and catproc.sql
Rem =======================================================================

Rem Remove any existing rows that would fire on DROP USER statements
delete from duc$;

@@catalog.sql
@@catproc.sql 
SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;

Rem =======================================================================
Rem Reset all old version types to valid
Rem =======================================================================

Rem Compilation of standard might end up invalidating all object types,
Rem including older versions. This will cause problems if we have data
Rem depending on these versions, as they cannot be revalidated. Older
Rem versions are only used for data conversion, so we only need the 
Rem information in type dictionary tables which are unaffected by
Rem changes to standard. Reset obj$ status of these versions to valid
Rem so we can get to the type dictionary metadata.
Rem We need to make this a trusted C callout so that we can bypass the
Rem security check. Otherwise we run intp 1031 when DV is already linked in.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/
CREATE OR REPLACE PROCEDURE validate_old_typeversions IS
LANGUAGE C
NAME "VALIDATE_OLD_VERSIONS"
LIBRARY UPGRADE_LIB;
/
execute validate_old_typeversions();
commit;
alter system flush shared_pool;
drop procedure validate_old_typeversions;

Rem *************************************************************************
Rem START Component Reloads 
Rem *************************************************************************

Rem Setup component script filename variable
COLUMN relod_name NEW_VALUE relod_file NOPRINT;

Rem JServer
SELECT dbms_registry_sys.relod_script('JAVAVM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem XDK for Java
SELECT dbms_registry_sys.relod_script('XML') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem Java Supplied Packages
SELECT dbms_registry_sys.relod_script('CATJAVA') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem Text
SELECT dbms_registry_sys.relod_script('CONTEXT') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem Oracle XML Database
SELECT dbms_registry_sys.relod_script('XDB') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem Real Application Clusters
SELECT dbms_registry_sys.relod_script('RAC') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem Oracle Workspace Manager
SELECT dbms_registry_sys.relod_script('OWM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem Messaging Gateway
SELECT dbms_registry_sys.relod_script('MGW') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem OLAP Analytic Workspace
SELECT dbms_registry_sys.relod_script('APS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem OLAP API
SELECT dbms_registry_sys.relod_script('XOQ') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem Intermedia
SELECT dbms_registry_sys.relod_script('ORDIM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem Spatial
SELECT dbms_registry_sys.relod_script('SDO') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem Ultrasearch
SELECT dbms_registry_sys.relod_script('WK') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem Oracle Label Security
SELECT dbms_registry_sys.relod_script('OLS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem Expression Filter
SELECT dbms_registry_sys.relod_script('EXF') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem Rule Manager
SELECT dbms_registry_sys.relod_script('RUL') AS relod_name FROM DUAL;
@&relod_file     
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem Database Vault 
SELECT dbms_registry_sys.relod_script('DV') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

set serveroutput off

Rem **********************************************************************
Rem END Component Reloads 
Rem **********************************************************************

Rem =======================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =======================================================================
@@utllmup.sql

Rem =======================================================================
Rem Gather stats on bootstrap tables
Rem =======================================================================
-- DBMS_STATS now depends on DBMS_UTILITY which may have gotten invalidated 
-- by some preceeding DDL statement, so package state needs to be cleared to 
-- avoid ORA-04068
execute dbms_session.reset_package;

begin
  dbms_stats.delete_table_stats('SYS', 'OBJ$');
  dbms_stats.delete_table_stats('SYS', 'USER$');
  dbms_stats.delete_table_stats('SYS', 'COL$');
  dbms_stats.delete_table_stats('SYS', 'CLU$');
  dbms_stats.delete_table_stats('SYS', 'CON$');
  dbms_stats.delete_table_stats('SYS', 'TAB$');
  dbms_stats.delete_table_stats('SYS', 'IND$');
  dbms_stats.delete_table_stats('SYS', 'ICOL$');
  dbms_stats.delete_table_stats('SYS', 'LOB$');
  dbms_stats.delete_table_stats('SYS', 'COLTYPE$');
  dbms_stats.delete_table_stats('SYS', 'SUBCOLTYPE$');
  dbms_stats.delete_table_stats('SYS', 'NTAB$');
  dbms_stats.delete_table_stats('SYS', 'REFCON$');
  dbms_stats.delete_table_stats('SYS', 'OPQTYPE$');
  dbms_stats.delete_table_stats('SYS', 'ICOLDEP$');
  dbms_stats.delete_table_stats('SYS', 'TSQ$');
  dbms_stats.delete_table_stats('SYS', 'VIEWTRCOL$');
  dbms_stats.delete_table_stats('SYS', 'ATTRCOL$');
  dbms_stats.delete_table_stats('SYS', 'TYPE_MISC$');
  dbms_stats.delete_table_stats('SYS', 'LIBRARY$');
  dbms_stats.delete_table_stats('SYS', 'ASSEMBLY$');
  dbms_Stats.gather_table_stats('SYS', 'OBJ$',  estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'USER$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'COL$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'CLU$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'CON$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'TAB$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'IND$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'ICOL$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'LOB$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'COLTYPE$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'SUBCOLTYPE$', 
                                 estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'NTAB$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'REFCON$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'OPQTYPE$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'ICOLDEP$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'TSQ$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'VIEWTRCOL$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'ATTRCOL$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'TYPE_MISC$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'LIBRARY$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'ASSEMBLY$', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
end;
/

-- This library was created in utlmmigdown.sql but could not be dropped until
-- this point.
drop library DBMS_DDL_INTERNAL_LIB;

-- Drop the old dictionary clusters
drop cluster c_obj#mig including tables;
drop cluster c_user#mig including tables;

Rem =====================================================================
Rem Record Reload Completion
Rem =====================================================================

BEGIN  
   dbms_registry_sys.record_action('RELOAD',NULL,
             'Reloaded to  ' || 
              dbms_registry.version_full('CATPROC'));
END;
/

SELECT dbms_registry_sys.time_stamp('relod_end') AS timestamp FROM DUAL;

Rem =======================================================================
Rem Display new versions and status
Rem =======================================================================

column comp_name format a35
column version_full format a15
SELECT comp_name, status, version_full
from dba_server_registry order by modified;

DOC
#######################################################################
#######################################################################

   The above query lists the SERVER components now loaded in the
   database, along with their current version and status. 

   Please review the status and version columns and look for
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the correct RU
   patch version, consult the downgrade chapter of the current release
   Database Upgrade book.

   Next shutdown immediate, restart for normal operation, and then
   run utlrp.sql to recompile any invalid application objects.

#######################################################################
#######################################################################
#  

Rem *******************************************************************
Rem END catrelod.sql 
Rem *******************************************************************
