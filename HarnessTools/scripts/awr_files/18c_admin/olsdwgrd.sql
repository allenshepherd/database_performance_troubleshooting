Rem
Rem $Header: rdbms/admin/olsdwgrd.sql /main/3 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olsdwgrd.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsdwgrd.sql - OLS DoWnGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script downgrades OLS from the current release to
Rem      the release from which the DB was upgraded.
Rem
Rem    NOTES
Rem      It is invoked by cmpdwgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsdwgrd.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/cmpdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    risgupta    01/11/17 - Lrg 19878740: Add @ while referring to
Rem                           downgrade script
Rem    risgupta    11/01/16 - Bug 25029649: OLS downgrade script
Rem    risgupta    11/01/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

WHENEVER SQLERROR EXIT
EXECUTE sys.dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
SET ERRORLOGGING ON IDENTIFIER 'OLS';
SELECT sys.dbms_registry_sys.time_stamp_display('OLS')
       AS timestamp FROM SYS.DUAL;

VARIABLE ols_file VARCHAR2(256)
COLUMN :ols_file NEW_VALUE olsfile NOPRINT

Rem
Rem Determine the correct script to run
Rem

DECLARE
  prv_version sys.registry$.prv_version%type;
BEGIN
  -- Get the previous version of the CATPROC component
  prv_version := substr(sys.dbms_registry.prev_version('OLS'), 1, 6);
  
  IF prv_version = '11.2.0' THEN
    :ols_file := '@olse112.sql';
  ELSIF prv_version = '12.1.0' THEN
    :ols_file := '@olse121.sql';
  ELSIF prv_version = '12.2.0' THEN
    :ols_file := '@olse122.sql';
  ELSE
    :ols_file := sys.dbms_registry.nothing_script;
  END IF;
END;
/

Rem Invoke appropriate OLS downgrade script
SELECT :ols_file FROM DUAL;
@&olsfile

@?/rdbms/admin/sqlsessend.sql
 
