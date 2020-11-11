Rem
Rem $Header: rdbms/admin/utltz_upg_apply.sql /main/4 2017/09/08 16:58:12 huagli Exp $
Rem
Rem utltz_upg_apply.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      utltz_upg_apply.sql - TIME ZONE Upgrade Apply Script
Rem                            (for 11gR2 or higher)
Rem
Rem    DESCRIPTION
Rem      This script update the database to the highest installed
Rem      timezone definitions found by the utltz_upg_check.sql script.
Rem
Rem    NOTES
Rem      * The utltz_upg_check.sql script must be run before this script.
Rem      * This script must be run using SQL*PLUS from the database home.
Rem      * This script must be connected AS SYSDBA to run.
Rem      * The database need to be 11.2.0.1 or higher.
Rem      * The database need to be single instance ( cluster_database = FALSE ).
Rem      * The database will be restarted 2 times without asking any confirmation.
Rem      * This script takes no arguments.
Rem      * This script WILL exit SQL*PLUS when an error is detected
Rem      * The dba_recyclebin WILL be purged.
Rem      * TZ_VERSION in Registry$database will be updated with new DST version after the DST upgrade.
Rem      * The UPG_TZV table will be dropped.
Rem      * the script will write a line into the alert.log before restarting the db and when ending succesfully.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utltz_upg_apply.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utltz_upg_apply.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huagli      08/31/17 - 26721930: DB version change
Rem    huagli      06/09/17 - 25988996: CDB/PDB RAC check and various cleanup
Rem    huagli      04/07/17 - 25856520: handle PDB name correctly
Rem    huagli      01/31/17 - renamed to utltz_upg_apply.sql and added to shiphome
Rem    gvermeir    08/22/14 - updated to handle CDB/PDB (Multitenant) DST updates
Rem    gvermeir    07/10/14 - sync version with upg_tzv_check
Rem    gvermeir    05/23/14 - sync version with upg_tzv_check
Rem    gvermeir    03/17/14 - logging of time makes more sense in minutes
Rem    gvermeir    02/20/14 - added logging to alert.log
Rem    gvermeir    12/23/13 - minor changes on error handling
Rem    gvermeir    09/20/13 - enhanced error handling
Rem    gvermeir    06/12/13 - Enhanced output
Rem    gvermeir    05/16/13 - Typos fixed
Rem    gvermeir    05/13/13 - Initial internal release
Rem    gvermeir    04/23/13 - created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET TERMOUT OFF
SET SERVEROUTPUT OFF
SET FEEDBACK OFF

-- Get current time to track TZ upgrade time
VARIABLE V_TIME NUMBER
EXEC :V_TIME := DBMS_UTILITY.GET_TIME

-- Set client_info so one can use:
-- SELECT ... FROM v$session WHERE client_info = 'upg_tzv';
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('upg_tzv');

-- Alter session to avoid performance issues
ALTER SESSION SET NLS_SORT = 'BINARY';

WHENEVER SQLERROR EXIT

SET TERMOUT ON
SET SERVEROUTPUT ON

-- Give some info
EXEC DBMS_OUTPUT.PUT_LINE('INFO: If an ERROR occurs, the script will EXIT SQL*Plus.' );

-- check if DB is READ WRITE
DECLARE
  v_checkvar1 VARCHAR2(10 CHAR);
BEGIN
  EXECUTE IMMEDIATE 'SELECT open_mode FROM v$database' INTO v_checkvar1;
  IF v_checkvar1 != TO_CHAR('READ WRITE') THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: This database is in ' || v_checkvar1 ||' mode.');
    DBMS_OUTPUT.PUT_LINE('ERROR: Please restart the database in READ WRITE mode ');
    RAISE_APPLICATION_ERROR(-20210, 'Stopping script - see previous message ...');
  END IF;
END;
/

-- Check if user is SYS
DECLARE
   v_checkvar1 VARCHAR2(10 CHAR);
BEGIN
   EXECUTE IMMEDIATE 'SELECT SUBSTR(SYS_CONTEXT(''USERENV'',''CURRENT_USER''), 1, 10)
                      FROM dual'
   INTO v_checkvar1;
   IF v_checkvar1 = 'SYS' THEN
     NULL;
   ELSE
     DBMS_OUTPUT.PUT_LINE('ERROR: Current connection is not a sysdba connection!');
     RAISE_APPLICATION_ERROR(-20001, 'Stopping script - see previous message ...');
   END IF;
END;
/

-- All pre-checks
DECLARE
  V_DBVERSION VARCHAR2(8 CHAR);
  V_ISPDB     VARCHAR2(3 CHAR);
  V_NEWDBTZV  NUMBER;
  V_OLDDBTZV  NUMBER;
  V_CHECKNUM1 NUMBER;
  V_CHECKVAR1 VARCHAR2(10 CHAR);
  V_CHECKVAR2 VARCHAR2(128);
BEGIN
  -- Check if utltz_upg_check.sql has been run
  BEGIN
    EXECUTE IMMEDIATE 'SELECT new_tz_version, ispdb FROM upg_tzv' INTO V_NEWDBTZV, V_ISPDB;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN -- no rows in UPG_TZV
    DBMS_OUTPUT.PUT_LINE('ERROR: UPG_TZV has no rows.');
    DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
    DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
    RAISE_APPLICATION_ERROR(-20212,'Stopping script - see previous message ...');
  WHEN TOO_MANY_ROWS THEN -- more than 1 row in UPG_TZV
    DBMS_OUTPUT.PUT_LINE('ERROR: UPG_TZV has more than one row.');
    DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
    DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
    RAISE_APPLICATION_ERROR(-20213,'Stopping script - see previous message ...');
  WHEN OTHERS THEN
    IF SQLCODE = -904 THEN -- UPG_TZV exists but no NEW_TZ_VERSION
      DBMS_OUTPUT.PUT_LINE('ERROR: UPG_TZV does not exist.');
      DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
      RAISE_APPLICATION_ERROR(-20214,'Stopping script - see previous message ...');
    END IF;
    IF SQLCODE = -942 THEN -- no UPG_TZV table
      DBMS_OUTPUT.PUT_LINE('ERROR: UPG_TZV does not exist.');
      DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
      RAISE_APPLICATION_ERROR(-20215,'Stopping script - see previous message ...');
    END IF;
    IF V_NEWDBTZV IS NULL THEN -- NEW_TZ_VERSION is null
      DBMS_OUTPUT.PUT_LINE('ERROR: NEW_TZ_VERSION is null.');
      DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
      RAISE_APPLICATION_ERROR(-20216,'Stopping script - see previous message ...');
    END IF;
  END;

  -- Check if current DST version is lower than the one found by utltz_upg_check.sql
  BEGIN
    EXECUTE IMMEDIATE 'SELECT TO_NUMBER(SUBSTR(property_value, 1, 3))
                       FROM database_properties
                       WHERE property_name = ''DST_PRIMARY_TT_VERSION'''
    INTO V_OLDDBTZV;
    IF V_OLDDBTZV < V_NEWDBTZV THEN
      DBMS_OUTPUT.PUT_LINE('INFO: The database RDBMS DST version will be updated to DSTv' || 
                           TO_CHAR(V_NEWDBTZV) ||' .');
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: No newer DST update was detected.');
      DBMS_OUTPUT.PUT_LINE('ERROR: You need to run utltz_upg_check.sql BEFORE utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: NO update of the DST version was done!');
      RAISE_APPLICATION_ERROR(-20217,'Stopping script - see previous message ...');
    END IF;
  END;
  -- Check if DST_UPGRADE_STATE is NONE
  BEGIN
    EXECUTE IMMEDIATE 'SELECT SUBSTR(property_value, 1, 10)
                       FROM database_properties
                       WHERE property_name = ''DST_UPGRADE_STATE'''
    INTO V_CHECKVAR1;
    IF V_CHECKVAR1 = TO_CHAR('NONE') THEN
      NULL;
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: Current DST_UPGRADE_STATE is '|| V_CHECKVAR1 || ' !');
      DBMS_OUTPUT.PUT_LINE('ERROR: DST_UPGRADE_STATE in DATABASE_PROPERTIES need to be NONE ');
      DBMS_OUTPUT.PUT_LINE('ERROR: before running utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: See note 977512.1 for 11gR2 or note 1509653.1 for 12c .');
      RAISE_APPLICATION_ERROR(-20218,'Stopping script - see previous message ...');
    END IF;
  END;
  -- For PDB, we make sure that PDB is only opened in a single instance
  -- For non-CDB case and CDB$ROOT, we make sure there is only one instance 
  IF V_ISPDB = 'YES' THEN
    -- Check if PDB is only opened on a single instance
    EXECUTE IMMEDIATE 'SELECT COUNT(*)
                       FROM gv$pdbs
                       WHERE name = (SELECT SYS_CONTEXT(''USERENV'',''CON_NAME'') FROM dual) AND
                             open_mode != ''MOUNTED'''
    INTO V_CHECKNUM1;
    IF V_CHECKNUM1 = 1 THEN
      NULL;
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: This PDB is not started in a single instance!');
      DBMS_OUTPUT.PUT_LINE('ERROR: Start this PDB in one single instance only');
      DBMS_OUTPUT.PUT_LINE('ERROR: and then re-run utltz_upg_apply.sql.');
      RAISE_APPLICATION_ERROR(-20219,'Stopping script - see previous message ...');
    END IF;
  ELSE
    -- Check if DB is single instance, if not, end script
    EXECUTE IMMEDIATE 'SELECT UPPER(value)
                       FROM v$system_parameter
                       WHERE UPPER(name)=''CLUSTER_DATABASE'''
    INTO V_CHECKVAR1;
    IF V_CHECKVAR1 = TO_CHAR('FALSE') THEN
      NULL;
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: This RAC database is not started in single instance mode!');
      DBMS_OUTPUT.PUT_LINE('ERROR: Set cluster_database = false and start as single instance');
      DBMS_OUTPUT.PUT_LINE('ERROR: and then re-run utltz_upg_apply.sql.');
      DBMS_OUTPUT.PUT_LINE('ERROR: This is required by the startup UPGRADE needed to do the DST update.');
      RAISE_APPLICATION_ERROR(-20219,'Stopping script - see previous message ...');
    END IF;
  END IF;
END;
/

-- Warn if this is runned against CDB$ROOT on Multitenant and if there are open PDB's
DECLARE
  V_DBVERSION VARCHAR2(8 CHAR);
  V_CHECKNUM1 NUMBER;
  V_CHECKVAR1 VARCHAR2(10 CHAR);
  V_CHECKVAR2 VARCHAR2(128 CHAR);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT SUBSTR(version, 1, 4) FROM v$instance' 
    INTO V_DBVERSION;
  END;
  BEGIN
    IF V_DBVERSION >= '12.1' THEN
      EXECUTE IMMEDIATE 'SELECT cdb FROM v$database' INTO V_CHECKVAR1;
      IF V_CHECKVAR1 = TO_CHAR('NO') THEN
        NULL;
      ELSE
        DBMS_OUTPUT.PUT_LINE('INFO: This database is a Multitenant database.');
        EXECUTE IMMEDIATE 'SELECT SYS_CONTEXT(''USERENV'',''CON_NAME'') FROM dual' INTO V_CHECKVAR2;
        IF V_CHECKVAR2 = TO_CHAR('CDB$ROOT') THEN
          DBMS_OUTPUT.PUT_LINE('INFO: Current container is CDB$ROOT .');
          DBMS_OUTPUT.PUT_LINE('INFO: Updating the RDBMS DST version of the CDB / CDB$ROOT database ');
          DBMS_OUTPUT.PUT_LINE('INFO: will NOT update the RDBMS DST version of PDB databases in this CDB.');
          EXECUTE IMMEDIATE 'SELECT COUNT(*)
                             FROM v$pdbs
                             WHERE name != TO_CHAR(''PDB$SEED'') AND
                                   open_mode != TO_CHAR(''MOUNTED'')'
          INTO V_CHECKNUM1;
          IF V_CHECKNUM1 = TO_NUMBER('0') THEN
            DBMS_OUTPUT.PUT_LINE('INFO: There are no open PDBs .');
          ELSE
            DBMS_OUTPUT.PUT_LINE('WARNING: There are '|| V_CHECKNUM1 ||' open PDBs .');
            DBMS_OUTPUT.PUT_LINE('WARNING: They will be closed when CDB$ROOT is restarted ');
          END IF;
        ELSE
          DBMS_OUTPUT.PUT_LINE('INFO: This database is a PDB.');
          DBMS_OUTPUT.PUT_LINE('INFO: Current PDB is '||V_CHECKVAR2||' .');	
        END IF;
      END IF;
    END IF;
    DBMS_OUTPUT.PUT_LINE('WARNING: This script will restart the database 2 times ' );
    DBMS_OUTPUT.PUT_LINE('WARNING: WITHOUT asking ANY confirmation.' );
    DBMS_OUTPUT.PUT_LINE('WARNING: Hit control-c NOW if this is not intended.' );
  END;
  -- End block
END;
/

-- sleep for 3 seconds so one can control-C
EXEC DBMS_LOCK.SLEEP( 3 );
-- Say what we do next
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Restarting the database in UPGRADE mode to start the DST upgrade.' );
-- write info to alert.log
DECLARE
  V_NEWDBTZV NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT new_tz_version FROM upg_tzv' INTO V_NEWDBTZV;
  dbms_system.ksdwrt(2, 'utltz_upg_apply is ready to update to RDBMS DSTv'|| V_NEWDBTZV ||
                        ' and will now restart the database in UPGRADE mode.');
  -- End block
END;
/

WHENEVER SQLERROR CONTINUE

-- Startup in upgrade mode
-- keep termout on to show any startup errors
SHUTDOWN IMMEDIATE;
STARTUP UPGRADE;

-- in a PDB startup upgrade will not work
-- alter pluggable database open upgrade need to be used
-- this will error out with ORA-65000 or ORA-00904 in a non PDB but that's not an issue
-- the only side effect is that restart a PDB 2 times instead of 1 time
SET TERMOUT OFF
SET SERVEROUTPUT OFF
SET FEEDBACK OFF

ALTER pluggable DATABASE CLOSE IMMEDIATE;
ALTER pluggable DATABASE OPEN upgrade;

-- Alter sessions to avoid (performance) issues
ALTER SESSION SET nls_sort               = 'BINARY';
ALTER SESSION SET "_with_subquery"       = 'MATERIALIZE';
ALTER SESSION SET "_simple_view_merging" = TRUE;

-- Clean up used objects
TRUNCATE TABLE SYS.DST$TRIGGER_TABLE;
TRUNCATE TABLE SYS.DST$AFFECTED_TABLES;
TRUNCATE TABLE SYS.DST$ERROR_TABLE;

-- Purging dba_recyclebin
PURGE dba_recyclebin;

WHENEVER SQLERROR EXIT

SET TERMOUT ON
SET SERVEROUTPUT ON
SET FEEDBACK OFF

-- Say what we do next
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Starting the RDBMS DST upgrade. ' );
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Upgrading all SYS owned TSTZ data.' );
EXEC DBMS_OUTPUT.PUT_LINE('INFO: It might take time before any further output is seen ...');

-- Start upgrade block
DECLARE
  V_NEWDBTZV            NUMBER;
  V_OLDDBTZV            NUMBER;
  V_CHECKVAR1           VARCHAR2(10 CHAR);
  V_NUMFAIL             NUMBER;
  V_ERRCODE             NUMBER;
  V_ERRMSG              VARCHAR2(140 CHAR);
  INVALID_TIMEZONE_FILE EXCEPTION;
  PRAGMA EXCEPTION_INIT(INVALID_TIMEZONE_FILE, -30094);
  WINDOW_ACTIVE EXCEPTION;
  PRAGMA EXCEPTION_INIT(WINDOW_ACTIVE, -56920);
  NOT_IN_UPGRADE_MODE EXCEPTION;
  PRAGMA EXCEPTION_INIT(NOT_IN_UPGRADE_MODE, -56926);
  VIRTUAL_COLUMNS EXCEPTION;
  PRAGMA EXCEPTION_INIT(VIRTUAL_COLUMNS, -54017);
BEGIN
  -- Get V_Newdbtzv value
  BEGIN
    EXECUTE IMMEDIATE 'SELECT new_tz_version FROM upg_tzv' INTO V_NEWDBTZV;
  END;
  -- Start DST upgrade using V_Newdbtzv
  -- Need catch for ORA-30094, ORA-56920, ORA-56926 and ora-54017
  BEGIN
    DBMS_DST.BEGIN_UPGRADE(V_NEWDBTZV);
  EXCEPTION
  WHEN INVALID_TIMEZONE_FILE THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: Unable to find newer RDBMS DST patch or files.');
    RAISE_APPLICATION_ERROR(-20230,'Stopping script - see previous message ...');
  WHEN WINDOW_ACTIVE THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: A prepare or upgrade window or an on-demand ');
    DBMS_OUTPUT.PUT_LINE('ERROR: or datapump-job loading of a secondary time zone data file is in an active state.');
    RAISE_APPLICATION_ERROR(-20231,'Stopping script - see previous message ...');
  WHEN NOT_IN_UPGRADE_MODE THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: The database is not started in startup UPGRADE mode!');
    RAISE_APPLICATION_ERROR(-20232,'Stopping script - see previous message');
  WHEN VIRTUAL_COLUMNS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: Virtual columns with TSTZ dataype exist giving ora-54017!');
    RAISE_APPLICATION_ERROR(-20233,'Stopping script - see previous message ...');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: something went wrong during DBMS_DST.BEGIN_UPGRADE.');
    V_ERRCODE := SQLCODE;
    V_ERRMSG  := SUBSTR(SQLERRM,1,140);
    DBMS_OUTPUT.PUT_LINE('Error code ' || V_ERRCODE || ': ' || V_ERRMSG);
    RAISE_APPLICATION_ERROR(-20234,'Stopping script - see previous message ...');
  END;
  -- Check if DST_UPGRADE_STATE is UPGRADE
  BEGIN
    EXECUTE IMMEDIATE 'SELECT SUBSTR(property_value, 1, 10)
                       FROM database_properties
                       WHERE property_name = ''DST_UPGRADE_STATE'''
    INTO V_CHECKVAR1;
    IF V_CHECKVAR1 = TO_CHAR('UPGRADE') THEN
      NULL;
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: Current DST_UPGRADE_STATE is '|| V_CHECKVAR1 || ' !');
      DBMS_OUTPUT.PUT_LINE('ERROR: DST_UPGRADE_STATE in DATABASE_PROPERTIES need to be UPGRADE ');
      DBMS_OUTPUT.PUT_LINE('ERROR: after a DBMS_DST.BEGIN_UPGRADE.');
      DBMS_OUTPUT.PUT_LINE('ERROR: See note 1509653.1 for 12c .');
      RAISE_APPLICATION_ERROR(-20235,'Stopping script - see previous message ...');
    END IF;
  END;
  -- End block
END;
/

-- Say what we do next
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Restarting the database in NORMAL mode to upgrade non-SYS TSTZ data.' );
-- write info to alert.log
BEGIN
  dbms_system.ksdwrt(2, 'utltz_upg_apply updated all SYS TSTZ data and ' || 
                        'will now restart the database to update all non SYS TSTZ data.');
  -- End block
END;
/

WHENEVER SQLERROR CONTINUE

-- Startup normal needed to end upgrade
-- This will also work on a PDB
-- keep termout on to show any startup errors
SHUTDOWN IMMEDIATE
STARTUP

SET TERMOUT OFF

-- Alter sessions to avoid (performance) issues
ALTER SESSION SET nls_sort               = 'BINARY';
ALTER SESSION SET "_with_subquery"       = 'MATERIALIZE';
ALTER SESSION SET "_simple_view_merging" = TRUE;

WHENEVER SQLERROR EXIT

SET TERMOUT ON
SET SERVEROUTPUT ON
SET FEEDBACK OFF

-- Say what we do next
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Upgrading all non-SYS TSTZ data.' );
EXEC DBMS_OUTPUT.PUT_LINE('INFO: It might take time before any further output is seen ...');
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Do NOT start any application yet that uses TSTZ data!');

-- Begin upgrade user data block
DECLARE
  V_NEWDBTZV  NUMBER;
  V_OLDDBTZV  NUMBER;
  V_CHECKNUM1 NUMBER;  
  V_CHECKVAR1 VARCHAR2(10 CHAR);
  V_NUMFAIL   NUMBER;
BEGIN
  -- Upgrade database TSTZ data
  BEGIN
    DBMS_OUTPUT.PUT_LINE('INFO: Next is a list of all upgraded tables:');
    DBMS_DST.UPGRADE_DATABASE(V_NUMFAIL,
                              PARALLEL => TRUE, 
                              LOG_ERRORS => TRUE, 
                              LOG_ERRORS_TABLE => 'SYS.DST$ERROR_TABLE', 
                              LOG_TRIGGERS_TABLE => 'SYS.DST$TRIGGER_TABLE', 
                              ERROR_ON_OVERLAP_TIME => FALSE, 
                              ERROR_ON_NONEXISTING_TIME => FALSE);
    DBMS_OUTPUT.PUT_LINE('INFO: Total failures during update of TSTZ data: '|| V_NUMFAIL|| ' .');
  END;
  -- If this gives count(*) > 0 then error - go manual
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM SYS.DST$ERROR_TABLE' INTO V_CHECKNUM1 ;
    IF V_CHECKNUM1 != TO_NUMBER('0') THEN
      DBMS_OUTPUT.PUT_LINE('ERROR: Something cannot be handled automatically !');
      DBMS_OUTPUT.PUT_LINE('ERROR: Do an manual update and checks as documented in ');
      DBMS_OUTPUT.PUT_LINE('ERROR: of note 977512.1 for 11gR2 or note 1509653.1 for 12c.');
      RAISE_APPLICATION_ERROR(-20240,'Stopping script - see previous message ...');
    END IF;
  END;
  -- End upgrade
  DBMS_DST.END_UPGRADE(V_NUMFAIL);
  -- Check if DST_UPGRADE_STATE is NONE
  BEGIN
    EXECUTE IMMEDIATE 'SELECT SUBSTR(property_value, 1, 10) 
                       FROM database_properties 
                       WHERE property_name = ''DST_UPGRADE_STATE''' 
    INTO V_CHECKVAR1;
    IF V_CHECKVAR1 = TO_CHAR('NONE') THEN
      NULL;
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: Current DST_UPGRADE_STATE is '|| V_CHECKVAR1 || ' !');
      DBMS_OUTPUT.PUT_LINE('ERROR: DST_UPGRADE_STATE in DATABASE_PROPERTIES need to be NONE ');
      DBMS_OUTPUT.PUT_LINE('ERROR: after a DBMS_DST.END_UPGRADE.');
      DBMS_OUTPUT.PUT_LINE('ERROR: See note 977512.1 for 11gR2 or note 1509653.1 for 12c .');
      RAISE_APPLICATION_ERROR(-20241,'Stopping script - see previous message ...');
    END IF;
  END;
  -- Check if new TZ value is indeed seen
  -- Get new Newdbtzv value and compare
  BEGIN
    EXECUTE IMMEDIATE 'SELECT new_tz_version FROM upg_tzv' INTO V_NEWDBTZV ;
    EXECUTE IMMEDIATE 'SELECT TO_NUMBER(SUBSTR(property_value, 1, 3)) 
                       FROM database_properties
                       WHERE property_name = ''DST_PRIMARY_TT_VERSION''' 
    INTO V_OLDDBTZV;
    IF V_OLDDBTZV = V_NEWDBTZV THEN
      DBMS_OUTPUT.PUT_LINE('INFO: Your new Server RDBMS DST version is DSTv' || TO_CHAR(V_NEWDBTZV) ||' .');
    ELSE
      DBMS_OUTPUT.PUT_LINE('ERROR: Your Server timezone version was not updated to DSTv' || 
                           TO_CHAR(V_NEWDBTZV) || '.');
      RAISE_APPLICATION_ERROR(-20243,'Stopping script - see previous message ...');
    END IF;
  END;
  -- Housekeeping
  BEGIN
    EXECUTE IMMEDIATE 'UPDATE registry$database SET tz_version = :1' USING V_NEWDBTZV;
    COMMIT;
    EXECUTE IMMEDIATE 'DROP TABLE upg_tzv PURGE';
  END;
  -- End of block
END;
/
EXEC DBMS_OUTPUT.PUT_LINE('INFO: The RDBMS DST update is successfully finished.');
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Make sure to exit this SQL*Plus session.');
EXEC DBMS_OUTPUT.PUT_LINE('INFO: Do not use it for timezone related selects.');

-- get time elapsed in minutes
EXEC :V_TIME := ROUND((DBMS_UTILITY.GET_TIME - :V_TIME)/100/60)

-- write info to alert.log
DECLARE
  V_NEWDBTZV NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT tz_version FROM registry$database' INTO V_NEWDBTZV;
  dbms_system.ksdwrt(2, 'utltz_upg_apply sucessfully updated this database to RDBMS DSTv' || V_NEWDBTZV ||
                        ' and took '|| :V_TIME ||' minutes to run.');
END;
/

WHENEVER SQLERROR CONTINUE
SET FEEDBACK ON

-- End of utltz_upg_apply.sql

@?/rdbms/admin/sqlsessend.sql
 
