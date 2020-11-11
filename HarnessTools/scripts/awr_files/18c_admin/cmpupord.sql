Rem
Rem $Header: rdbms/admin/cmpupord.sql /main/13 2017/04/11 17:07:31 welin Exp $
Rem
Rem cmpupord.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupord.sql - CoMPonent UPgrade ORD components
Rem
Rem    DESCRIPTION
Rem      Upgrade Multimedia and Spatial
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupord.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupord.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    welin       03/23/17 - Bug 25790099: Add SQL_METADATA
Rem    raeburns    12/10/14 - Project 46657: remove ORDIM upgrade 
Rem                         - using CATCTL for directly in cmpupgrd.sql
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    jerrede     04/05/13 - Support for CDB. Move Spatial to its own
Rem                           component file to assure it was run by
Rem                           itself during an CDB upgrade.
Rem    cdilling    10/13/12 - fix bug 14625890 - make SDO rerunnable
Rem    jerrede     04/25/12 - Bug 13995725 Serial OWM because of Deadlocks
Rem                           Moved from cmpupord.sql to cmpupnxb.sql
Rem    jerrede     03/26/12 - Fix Deadlock with OWM lrg #6730021
Rem    jerrede     09/27/11 - Fix Bug 12959399
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    cdilling    12/14/06 - remove extra sdo timestamp
Rem    cdilling    10/05/06 - for XE upgrade locator instead of SDO
Rem    cdilling    06/08/06 - add support for error logging 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

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
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

set serveroutput off

Rem =====================================================================
Rem Install ORDIM if Spatial is in the DB, but ORDIM is not
Rem =====================================================================

Rem Set identifier to ORDIM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'ORDIM';

BEGIN
  IF dbms_registry.is_loaded('ORDIM') IS NULL AND
     dbms_registry.is_loaded('SDO') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.ORDIM_path || 'imupins.sql';
     EXECUTE IMMEDIATE 
          'CREATE USER si_informtn_schema IDENTIFIED BY ordsys ' ||
          'ACCOUNT LOCK PASSWORD EXPIRE ' ||
          'DEFAULT TABLESPACE SYSAUX';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file


