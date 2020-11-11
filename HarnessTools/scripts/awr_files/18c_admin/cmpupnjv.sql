Rem
Rem $Header: rdbms/admin/cmpupnjv.sql /main/22 2017/04/26 08:54:51 frealvar Exp $
Rem
Rem cmpupnjv.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupnjv.sql - CoMPonent UPgrade Non-JaVa dependent components
Rem
Rem    DESCRIPTION
Rem      Upgrade APS, AMD, OLS, DV, CONTEXT, XDB, OWM, MGW, RAC 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupnjv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupnjv.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    frealvar    04/27/17 - Bug 25944951 remove upgrade code to upgrade xdb
Rem    welin       03/23/17 - Add SQL_METADATA
Rem    raeburns    02/23/17 - Bug 25790099: Move XDB, MGW, RAC upgrade here
Rem    risgupta    08/31/15 - Bug 21748684: Move the ols version check to
Rem                           olsdbmig.sql
Rem    risgupta    09/04/15 - Lrg 18497934: Use dbms_registry.nothing_script
Rem                           instead of nothing.sql
Rem    risgupta    08/25/15 - Lrg 18421763: Check whether OLS is installed
Rem                           before upgrading OLS
Rem    risgupta    08/05/15 - Bug 21178327: Invoke olsdbmig.sql if OLS version
Rem                           is same as RDBMS version or if supported for
Rem                           upgrade
Rem    raeburns    08/20/14 - move TEXT upgrade
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    cmlim       04/17/13 - bug 16103409 - AMD is Option Off and utlu121s.sql
Rem                           is not showing AMD in the component status output
Rem    cdilling    12/27/12 - XbranchMerge cdilling_lrg-8636778 from
Rem                           st_rdbms_12.1.0.1
Rem    cdilling    12/22/12 - Move RAC to a serial phase to avoid deadlocks
Rem    jerrede     12/20/12 - DeadLock Issue Moved MGW to serial phase (alter
Rem                           type sys.mgwi_msglink mgwu102.sql)
Rem    awesley     07/13/12 - set AMD component to 'OPTION OFF' status
Rem    awesley     04/02/12 - deprecate cwm, remove AMD
Rem    cdilling    03/05/12 - remove EM processing for 12.1
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    cdilling    03/02/11 - set EM component to 'OPTION OFF' status
Rem    sanagara    02/17/09 - move OWM to cmpupmsc.sql
Rem    rburns      01/16/08 - add reset package
Rem    cdilling    12/07/06 - Data Vault
Rem    rburns      07/19/06 - XOQ Java dependency 
Rem    cdilling    06/08/06 - add error logging support 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

-- clear package state before running component script
EXECUTE dbms_session.reset_package;

Rem =========================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =========================================================================

WHENEVER SQLERROR EXIT;

Rem check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem =========================================================================
Rem Continue even if there are SQL errors in remainder of script 
Rem =========================================================================

WHENEVER SQLERROR CONTINUE;

Rem Setup component script filename variables
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

set serveroutput off

Rem =====================================================================
Rem Upgrade OLAP Analytic Workspace
Rem =====================================================================

Rem Set identifier to APS for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'APS';

SELECT dbms_registry_sys.time_stamp_display('APS') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('APS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem If AMD is in the registry then set its status to OPTION OFF (9)
Rem =====================================================================

Rem Set identifier to AMD for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'AMD';

SELECT dbms_registry_sys.time_stamp_display('AMD') AS timestamp FROM DUAL;
BEGIN
  IF dbms_registry.is_loaded('AMD') IS NOT NULL THEN
   BEGIN
     sys.dbms_registry.Option_Off('AMD');
     commit;
   END;
  END IF;
END;
/
Rem Bug 16103409 - call dbms_registry_sys.time_stamp() to record AMD in 
Rem                registry$log (dba_registry_log) for pickup by utlusts.sql
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Label Security 
Rem =====================================================================

Rem Set identifier to OLS for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'OLS';


SELECT dbms_registry_sys.time_stamp_display('OLS') AS timestamp FROM DUAL;
Rem Bug 21748684: Move the OLS version check to olsdbmig.sql
SELECT dbms_registry_sys.dbupg_script('OLS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Data Vault
Rem =====================================================================

Rem Set identifier to DV for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'DV';


SELECT dbms_registry_sys.time_stamp_display('DV') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('DV') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Text
Rem =====================================================================

Rem Set identifier to CONTEXT for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'CONTEXT';

SELECT dbms_registry_sys.time_stamp_display('CONTEXT') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('CONTEXT') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem Run the rest of components (as long as the total elapsed time is not 
Rem more than the cmpupjav.sql elapsed time)

Rem =====================================================================
Rem Upgrade Oracle Workspace Manager
Rem =====================================================================

Rem Set identifier to OWM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'OWM';

SELECT dbms_registry_sys.time_stamp_display('OWM') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('OWM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Messaging Gateway
Rem =====================================================================

Rem Set identifier to MGW for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'MGW';

SELECT dbms_registry_sys.time_stamp_display('MGW') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('MGW') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Real Application Clusters
Rem =====================================================================

Rem Set identifier to RAC for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'RAC';

SELECT dbms_registry_sys.time_stamp_display('RAC') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('RAC') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

