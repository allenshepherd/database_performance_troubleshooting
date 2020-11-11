Rem
Rem $Header: rdbms/admin/cmpupend.sql /main/14 2017/09/07 06:00:16 fvallin Exp $
Rem
Rem cmpupend.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupend.sql - CoMPonent UPgrade END script
Rem
Rem    DESCRIPTION
Rem      Final component upgrade actions
Rem
Rem    NOTES
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupend.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupend.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    fvallin     08/21/17 - Bug 26635046: Added conditional run of pupbld.sql
Rem    hvieyra     07/27/17 - Fix for bug 26389096. Execute hlpbld.sql script
Rem                           as part of upgrade.
Rem    welin       03/23/17 - Bug 25790099: Add SQL_METADATA
Rem    raeburns    02/25/17 - record timestamp CMPUPGRD_END
Rem    cmlim       06/06/16 - bug 23215791: add more DBUA_TIMESTAMPs during db
Rem                           upgrades
Rem    raeburns    01/10/16 - lrg 18666083: Add dbmsclr.plb for Windows NET
Rem                           extensions
Rem    raeburns    01/30/15 - move TSDP upgrade to xrdupgrd.sql
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    dgraj       11/12/11 - Project 32079: Upgrade action for TSDP
Rem    mdietric    03/23/11 - remove gathering stats - bug 11901407
Rem    cdilling    04/18/07 - add timestamp for gather_stats
Rem    rburns      12/07/06 - move gather_stats
Rem    cdilling    12/14/06 - add RDBMS identifier
Rem    rburns      07/19/06 - move final actions to catupend.sql 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

set serveroutput off
set errorlogging on table sys.registry$error identifier 'ACTIONS';

Rem ===============================================================
Rem BEGIN ODE NET_EXTENSIONS upgrade
Rem ===============================================================

-- If dbms_clr objects are in the database, load the latest versions.
-- dbmsclr.plb is installed in rdbms/admin only on Windows and only 
-- when the NET_EXTENSIONS option is specified.  An SP2-0310 error
-- will be raised if the dbms_clr objects are in the database but the
-- dbmsclr.plb file is not in rdbms/admin.

COLUMN :clr_name NEW_VALUE clr_file NOPRINT;
VARIABLE clr_name VARCHAR2(256)

DECLARE
  found number:=0;
BEGIN
  SELECT 1 INTO found FROM dba_objects
  WHERE owner = 'SYS' AND object_type='LIBRARY'
    AND object_name = 'ORACLECLR_LIB';
  :clr_name := '?/rdbms/admin/dbmsclr.plb';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   :clr_name := sys.dbms_registry.nothing_script();
END;
/

-- Load the dbmsclr.plb script or the nothing script
SELECT :clr_name FROM DUAL;
@&clr_file

Rem ===============================================================
Rem End of ODE NET EXTENSIONS upgrade
Rem ===============================================================

Rem ===============================================================
Rem BEGIN SQLPLUS help script execution
Rem ===============================================================

COLUMN :help_name NEW_VALUE help_file NOPRINT;
VARIABLE help_name VARCHAR2(256);

COLUMN :arg_name NEW_VALUE arg_file NOPRINT;
VARIABLE arg_name VARCHAR2(256);

DECLARE
  found number:=0;
BEGIN
  SELECT 1 INTO found FROM dba_objects
  WHERE owner = 'SYSTEM' AND object_type='TABLE'
    AND object_name = 'HELP';
  :help_name := '?/sqlplus/admin/help/hlpbld.sql';
  :arg_name  := '?/sqlplus/admin/help/helpus.sql';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   :help_name := sys.dbms_registry.nothing_script();
   :arg_name  := '';
END;
/

-- Load hlpbld.sql script taking helpus.sql as argument  or the nothing script
SELECT :help_name FROM DUAL;
SELECT :arg_name  FROM DUAL;
@&help_file &arg_file

Rem ===============================================================
Rem END SQLPLUS help script execution
Rem ===============================================================

Rem ===============================================================
Rem BEGIN Bug 26635046: Conditional run of pupbld.sql
Rem ===============================================================

COLUMN :pupbld_name NEW_VALUE pupbld_file NOPRINT;
VARIABLE pupbld_name VARCHAR2(256);

DECLARE
  found number:=0;
BEGIN
  SELECT 1 INTO found FROM dba_objects
  WHERE owner = 'SYSTEM' AND object_type='TABLE'
    AND object_name = 'SQLPLUS_PRODUCT_PROFILE';
    :pupbld_name := '?/sqlplus/admin/pupbld.sql';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   :pupbld_name := sys.dbms_registry.nothing_script();
END;
/

SELECT :pupbld_name FROM DUAL;
ALTER SESSION SET CURRENT_SCHEMA = SYSTEM;
@&pupbld_file
ALTER SESSION SET CURRENT_SCHEMA = SYS;

Rem ===============================================================
Rem END Bug 26635046: Conditional run of pupbld.sql
Rem ===============================================================

-- DBUA_TIMESTAMP: database components upgrade finishes
SELECT dbms_registry_sys.time_stamp('CMPUPGRD_END') AS timestamp FROM DUAL;

SELECT dbms_registry_sys.time_stamp('ACTIONS_BGN') AS timestamp FROM DUAL;

-- DBUA_TIMESTAMP: FINAL upgrade scripts/ACTIONs begins
SELECT dbms_registry_sys.time_stamp_display('FINALACTION')
  AS timestamp FROM DUAL;

