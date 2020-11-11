Rem
Rem $Header: rdbms/admin/catresults.sql /main/8 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem catresults.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
SET ECHO OFF
Rem
Rem    NAME
Rem      catresults.sql - Display Upgrade Status 
Rem
Rem    DESCRIPTION
Rem      Display the upgrade results.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catresults.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catresults.sql
Rem    SQL_PHASE:  UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: catupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/14/17 - Bug 25790192: Add SQL_METADATA
Rem    jerrede     09/02/15 - Fix for easier reading
Rem    jerrede     10/22/14 - Support for Read Only Oracle Home
Rem    jerrede     01/30/14 - Fix Report Name
Rem    jerrede     01/08/14 - Fix bug 18044666 Summary Report not displayed
Rem    jerrede     11/23/13 - Add Summary Report
Rem    jerrede     08/28/12 - Created
Rem

--
-- Set echo off so report is clean and
-- reset line size for report.
--
SET ECHO OFF;
SET TIME OFF;
SET TIMING OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;
SET SERVEROUTPUT ON FORMAT WRAPPED;
SET LINESIZE 80;


Rem =====================================================================
Rem  Reset package just in case comming from migrate
Rem =====================================================================
EXECUTE dbms_session.reset_package;

Rem =====================================================================
Rem REPORT TIMINGS AND SHUTDOWN THE DATABASE..!!!!! 
Rem =====================================================================

Rem =====================================================================
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem =====================================================================

Rem =====================================================================
Rem Run component status as the last output
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem Note:  ACTIONS_END must stay here to get the correct upgrade time.
Rem =====================================================================

VARIABLE ReportName  VARCHAR2(2000);

DECLARE

    platform   v$database.platform_name%TYPE;
    RptName    CONSTANT VARCHAR2(15) :=  'upg_summary.log';
    InitName   CONSTANT VARCHAR2(14) := 'Report not run';
    WinSlash   CONSTANT VARCHAR2(1)  := '\';        -- 'WinDows
    UnixSlash  CONSTANT VARCHAR2(1)  := '/';        --  Unix
    Slash      VARCHAR2(1)  := UnixSlash;  --  Default to Unix

BEGIN

  --
  -- Get Report Name
  --
  :ReportName := InitName;
  BEGIN
      EXECUTE IMMEDIATE
        'select reportname from sys.registry$upg_summary where con_id=-1'
      INTO :ReportName;
      EXCEPTION
        WHEN OTHERS THEN NULL;
  END;


  --
  -- Report Not Found
  --
  IF :ReportName = Initname THEN

        --
        -- Find out the platform
        --
        EXECUTE IMMEDIATE 'SELECT NLS_UPPER(platform_name) FROM v$database'
                        INTO platform;

        --
        -- Place in Temp Directory If not in the database
        --
        IF INSTR(platform, 'WINDOWS') != 0 THEN
                slash := WinSlash;
                :ReportName := NULL;
                DBMS_SYSTEM.GET_ENV('TEMP', :ReportName);
                IF :ReportName IS NOT NULL THEN
                    :ReportName := :ReportName || slash || RptName;
                ELSE
                     -- 
                     -- Place in system Drive SystemDrive:\upg_summary.log
                     -- Or if all else fails C:\upg_summary.log
                     --
                     DBMS_SYSTEM.GET_ENV('SystemDrive', :ReportName);
                     IF :ReportName IS NOT NULL THEN
                         :ReportName := :ReportName || slash || RptName;
                     ELSE
                         :ReportName := 'C:' || slash || RptName;
                     END IF;
                END IF;
        ELSE
                :ReportName := slash || 'tmp' || slash || RptName;
        END IF;

  END IF;

END;
/

--
-- Generate Spool Report Name
--
COLUMN generate_logfile NEW_VALUE generate_logfile NOPRINT

--
-- Get the report name out of the database
--
SELECT :ReportName AS generate_logfile FROM SYS.DUAL;

--
-- Spool out the file in append mode
--
SPOOL &generate_logfile append

--
-- Display Upgrade Status and Times
--
@@utlusts TEXT

--
-- Turn spool off
--
SPOOL OFF;

--
-- Print Summary Report File Name
--
PROMPT Summary Report File = &generate_logfile
PROMPT


--
-- Update Summary Table with con_name and endtime.
--
UPDATE sys.registry$upg_summary SET con_name = SYS_CONTEXT('USERENV','CON_NAME'),
                                    endtime  = SYSDATE
       WHERE con_id = -1;
commit;

--
-- Reset
--
SET TIME ON;
SET TIMING ON;
SET FEEDBACK ON;
SET VERIFY ON;
SET SERVEROUTPUT ON;
SET ECHO ON;
