Rem
Rem $Header: rdbms/admin/catmmig.sql /main/6 2017/09/14 17:35:42 raeburns Exp $
Rem
Rem catmmig.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmmig.sql - cat mini migration
Rem
Rem    DESCRIPTION
Rem      Driver script for utlmmig.sql. Checks for release etc.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    08/31/17 - Bug 26255427: include FULL version in registry
Rem    cmlim       06/19/16 - cmlim_lrg-19543910: display DBRESTART tag only
Rem                           after catupgrd.sql is done
Rem    jerrede     08/27/14 - Bug 19518079 add back record_action.
Rem                           Dropped by mistake.
Rem    jerrede     01/21/14 - Add upgrade timmings back in.
Rem    traney      01/14/14 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catmmig.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

Rem =====================================================================
Rem Note:  SEE utlmmig.sql for further documentation and restrictions 
Rem =====================================================================

-- Setup component script filename variables
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

-- Run utlmmig.sql or catupshd.sql
SELECT dbms_registry_sys.utlmmig_script_name AS dbmig_name FROM SYS.DUAL;
@@&dbmig_file

Rem =====================================================================
Rem Record UPGRADE complete
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem =====================================================================

EXECUTE dbms_session.reset_package;

-- Record Upgrade Action.
BEGIN
   dbms_registry_sys.record_action('UPGRADE',NULL,'Upgraded from ' || 
       dbms_registry.prev_version('CATPROC') || ' to ' || 
       dbms_registry.version_full('CATPROC'));
END;
/

-- Add Upgrade times.
-- Add COMP_TIMESTAMP and DBUA_TIMESTAMP tags
-- Add tags to indicate which upgrade phases have ended
-- note: FINALACTION means: FINAL upgrade scripts/ACTION ends
SELECT dbms_registry_sys.time_stamp('ACTIONS_END') AS timestamp FROM SYS.DUAL;
SELECT dbms_registry_sys.time_stamp('FINALACTION') AS timestamp FROM SYS.DUAL;
SELECT dbms_registry_sys.time_stamp('UPGRD_END') AS timestamp FROM SYS.DUAL;

Rem
Rem DBUA_TIMESTAMP: database restart (shutdown/startup) begins
Rem note: DBUA is interested in this tag for only after catupgrd.sql is
Rem       finished.
Rem
SELECT dbms_registry_sys.time_stamp_display('DBRESTART') AS timestamp
  FROM SYS.DUAL;

commit;

@@?/rdbms/admin/sqlsessend.sql
