Rem
Rem $Header: rdbms/admin/utlusts.sql /main/25 2017/09/14 17:35:42 raeburns Exp $
Rem
Rem utlusts.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlusts.sql - UTiLity Upgrade STatuS
Rem
Rem    DESCRIPTION
Rem      Presents Post-upgrade Status in either TEXT or XML
Rem
Rem    NOTES
Rem      Invoked by catresults.sql with TEXT parameter
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/utlusts.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlusts.sql 
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: catresults.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    08/31/17 - Bug 26255427: update for new release versions
Rem    raeburns    04/15/17 - Bug 25790192: Add SQL_METADATA
Rem    welin       02/03/17 - Bug 25371956: Include datapatch execution time in
Rem                           post upgrade status output
Rem    hvieyra     05/11/16 - Fix for bug 23122663. Print most recent component
Rem                           upgrade information.
Rem    welin       05/06/16 - Bug 22966830: final action time double counted in
Rem                           total upgrade time
Rem    jerrede     09/01/15 - Fix for easier reading
Rem    raeburns    03/30/15 - Bug 20752107: update version to 12.2
Rem    hvieyra     11/24/14 - Bug Fix for 8899370 Add Timezone display
Rem    jerrede     07/17/14 - Bug 19050649 Remove Container ID from Report
Rem                           and add utlprp Timings.
Rem    jerrede     02/06/14 - 18191569 Oracle Server Status Invalid when no
Rem                           upgrade performed
Rem    jerrede     01/31/14 - Remove . line in report
Rem    jerrede     01/17/14 - Fix Bug 18071399 Add Post Upgrade Report Time
Rem    jerrede     11/25/13 - ORA-01422 exact fetch returns more than requested
Rem                           number of rows
Rem    jerrede     10/04/13 - Add Container Name
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     01/10/13 - Fix Bug 16097914 Update registry with OPTION OFF
Rem                           for RUL and EXF Components
Rem    jerrede     12/09/11 - Parallel Upgrade Change Status from Valid to
Rem                           Upgraded
Rem    jerrede     11/01/11 - Fix bug 13252372
Rem    mdietric    03/23/11 - remove gathering stats - bug 11901407
Rem    cmlim       03/17/11 - bug 11842119: support version 12.1
Rem    jerrede     03/10/11 - Fix bug #11837389
Rem    cmlim       03/01/11 - display latest status from dba_registry
Rem    cdilling    12/01/08 - change banner to 11.2
Rem    cdilling    04/18/07 - add stats gathering time
Rem    rburns      08/14/06 - limit error output lines
Rem    cdilling    06/08/06 - add support for error logging 
Rem    rburns      05/24/06 - parallel upgrade 
Rem    rburns      07/21/04 - add elapsed time 
Rem    rburns      06/22/04 - rburns_pre_upgrade_util
Rem    rburns      06/16/04 - Created
Rem

--
-- Set echo off so report is clean and
-- reset line size for report.
--
SET ECHO OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;
SET SERVEROUTPUT ON FORMAT WRAPPED;
SET LINESIZE 80;

-- Set version constants to use in report
@?/rdbms/admin/dbms_registry_basic.sql

Rem
Rem Routine Name: utlusts_display_nocomp_time
Rem
Rem Description:  This routine does the following functions.
Rem
Rem               1) Displays XML or TEXT formatted output for
Rem                  the followling Non-components:
Rem
Rem                  Post Upgrade  - catuppst.sql
Rem                  Post Compile  - utlprp.sql
Rem                  Final Actions - utlmmig.sql
Rem
Rem               2) Display the non-component time for both xml and text.
Rem                  Post Upgrade                Total Time
Rem
Rem               3) Display any errors found with non-component as follows:
Rem                  Post Upgrade
Rem                    Error 1
Rem                    Error 2
Rem                    Error 3
Rem                    .
Rem                    .
Rem                    Error Max Errors
Rem                  Post Upgrade                 Total Time    
Rem
Rem                  For XML we just display the error messages until
Rem                  max errors are reached.  Time is also displayed
Rem                  at the end of any errors.
Rem
Rem               4) We return the total elasped time for the non-component.
Rem                  This is added to the total upgrade time.
Rem
Rem INPUTS:
Rem    TIMESTAMP    ptStartTime   - Non-Component Start Time
Rem    TIMESTAMP    ptEndTime     - Non-Component End Time
Rem    registry$error.identifier%type
Rem                 psIdentifier  - Non-Component Identifier (cid) used for
Rem                                 XML Formatted output
Rem                                 <Cid=POSTUP,UTLRP,ACTIONS>
Rem    BOOLEAN      pbDisplayXml  - TRUE Display XML Format
Rem                                 FALSE Display TEXT Format 
Rem    NUMBER       pnMaxErrors   - Max Errors to Display
Rem    VARCHAR2     psXmlDispId   - XML Formatted Component id
Rem                                 <Component id="Post Upgrade"> 
Rem    VARCHAR2     psXMLDispTime - Part of the XML Formatted Component Time
Rem                                 PostupgradeTime=
Rem                                 PostCompileTime=
Rem                                 UpgradeTime=
Rem    VARCHAR2     psTextDisplay - Text Display Title for Non-Component
Rem
Rem RETURNS: 
Rem    INTERVAL DAY TO SECOND Elasped time - Total time to run the non-component.
Rem    
Rem
CREATE OR REPLACE FUNCTION utlusts_display_nocomp_time
       (ptStartTime   IN TIMESTAMP,
        ptEndTime     IN TIMESTAMP,
        psIdentifier  IN registry$error.identifier%type,
        pbDisplayXml  IN BOOLEAN,
        pnMaxErrors   IN NUMBER,
        psXmlDispId   IN VARCHAR2,
        psXmlDispTime IN VARCHAR2,
        psTextDisp    IN VARCHAR2)
RETURN INTERVAL DAY TO SECOND IS

    bFirstTime         BOOLEAN    := TRUE;
    time_result        VARCHAR2(30);
    tRetElapsedTime    INTERVAL DAY TO SECOND(9) := 
                       INTERVAL '0 00:00:00.00' DAY TO SECOND;

BEGIN

    --
    -- Get out if no end time
    --
    IF (ptEndTime IS NULL) THEN
        RETURN (tRetElapsedTime);
    END IF;

    --
    -- Get out if no start time
    --
    IF (ptStartTime IS NULL) THEN
        RETURN (tRetElapsedTime);
    END IF;

    --
    -- Calculate Time
    --
    tRetElapsedTime := ptEndTime - ptStartTime;
    time_result := to_char(tRetElapsedTime);

    --
    -- Display XML
    --
    IF (pbDisplayXml) THEN
         DBMS_OUTPUT.PUT_LINE ( psXmlDispId || ' cid="' || psIdentifier || '"');
    END IF;

    --
    -- Display errors by identifier
    --
    FOR err in (SELECT message FROM sys.registry$error
                WHERE identifier = psIdentifier AND ROWNUM < pnMaxErrors
                ORDER BY timestamp)
    LOOP
        IF (pbDisplayXml) THEN
            DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
        ELSE
            IF (bFirstTime) THEN
                 DBMS_OUTPUT.PUT_LINE(psTextDisp);
                 bFirstTime := FALSE;
            END IF;
            DBMS_OUTPUT.PUT_LINE('    ' || err.message);
        END IF;
    END LOOP; -- End of registry$error loop

    --
    -- Display Time
    --
    IF (pbDisplayXml) THEN
        DBMS_OUTPUT.PUT_LINE (
                         psXmlDispTime || substr(time_result,5,8) ||
                         '">');
    ELSE
        DBMS_OUTPUT.PUT_LINE( psTextDisp ||
                              LPAD(' ',40)   ||
                              LPAD(substr(time_result,5,8),10));
    END IF;

    return (tRetElapsedTime);

END utlusts_display_nocomp_time;
/

DECLARE

   display_mode       VARCHAR2(4) := '&1';
   display_xml        BOOLEAN := FALSE;
   comp_name          registry$.cname%type;
   prev_comp_name     registry$.cname%type := 'Oracle Server';
   p_id               registry$.cid%type;
   status             VARCHAR2(30);
   catproc_status     number    := 0;
   catalog_status     number    := 0;
   con_id             number    := 0;
   start_time         TIMESTAMP; 
   end_time           TIMESTAMP; 
   up_start_time      TIMESTAMP := NULL;
   up_end_time        TIMESTAMP := NULL; 
   actions_start_time TIMESTAMP := NULL;
   actions_end_time   TIMESTAMP := NULL;
   postup_start_time  TIMESTAMP := NULL;
   postup_end_time    TIMESTAMP := NULL;
   utlprp_start_time  TIMESTAMP := NULL;
   utlprp_end_time    TIMESTAMP := NULL; 
   dp_upg_start_time  TIMESTAMP := NULL;  -- datapatch in upgrade mode
   dp_upg_end_time    TIMESTAMP := NULL;  
   dp_nor_start_time  TIMESTAMP := NULL;  -- datapatch in normal mode
   dp_nor_end_time    TIMESTAMP := NULL;
   message            VARCHAR2(128);
   elapsed_time       INTERVAL DAY TO SECOND(9) := 
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;
   postup_elasped_time INTERVAL DAY TO SECOND(9) := 
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;
   utlprp_elasped_time INTERVAL DAY TO SECOND(9) := 
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;
   dp_upg_elasped_time INTERVAL DAY TO SECOND(9) :=
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;
   dp_nor_elasped_time INTERVAL DAY TO SECOND(9) :=
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;

   actions_elasped_time INTERVAL DAY TO SECOND(9) := 
                      INTERVAL '0 00:00:00.00' DAY TO SECOND;
   time_result        VARCHAR2(30);
   b_first_time       BOOLEAN := TRUE;   -- Flag use to print component name out once
                                         -- when error messages are displayed
   b_no_data_found    BOOLEAN := FALSE;  -- No Data Found (flag) in dba_registry
                                         -- when looking up component
   MAX_ERRORS         CONSTANT NUMBER := 25;  -- Max Errors Displayed

BEGIN
   IF display_mode = 'XML' THEN
      display_xml := TRUE;
      DBMS_OUTPUT.PUT_LINE('<RDBMSUP version="12.2">');
      DBMS_OUTPUT.PUT_LINE('<Components>');
   ELSE
      DBMS_OUTPUT.PUT_LINE(' ');
      DBMS_OUTPUT.PUT_LINE(
             'Oracle Database Release &C_ORACLE_HIGH_MAJ Post-Upgrade Status Tool    ' ||
             LPAD(TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'),18));
      con_id := sys.dbms_registry.get_con_id();
      IF ( con_id > 0 ) THEN
          DBMS_OUTPUT.PUT_LINE(LPAD('[',30) || 
                               sys.dbms_registry.get_container_name(con_id) ||
                               ']');
      END IF;
      DBMS_OUTPUT.PUT_LINE(' ');
      DBMS_OUTPUT.PUT_LINE(RPAD('Component', 40) || RPAD('Current',16) ||
              RPAD('Full', 9) || RPAD('Elapsed Time', 15));
      DBMS_OUTPUT.PUT_LINE(RPAD('Name', 40) || RPAD('Status',16) ||
              RPAD('Version', 9) || RPAD('HH:MM:SS', 15));
      DBMS_OUTPUT.PUT_LINE(' ');
   END IF;

   BEGIN
      -- get upgrade start/end times
      SELECT MAX(optime) INTO up_start_time 
      FROM dba_registry_log
      WHERE comp_id='UPGRD_BGN';

      start_time := up_start_time;
	
      SELECT MAX(optime) INTO up_end_time 
      FROM dba_registry_log
      WHERE comp_id='UPGRD_END';

      -- get 'final actions' start/end times
      SELECT MAX(optime) INTO actions_start_time 
      FROM dba_registry_log
      WHERE comp_id='ACTIONS_BGN';
	
      SELECT MAX(optime) INTO actions_end_time 
      FROM dba_registry_log
      WHERE comp_id='ACTIONS_END';


      -- get 'Post Upgrade' start/end times
      SELECT MAX(optime) INTO postup_start_time 
      FROM dba_registry_log
      WHERE comp_id='POSTUP_BGN';
	
      SELECT MAX(optime) INTO postup_end_time 
      FROM dba_registry_log
      WHERE comp_id='POSTUP_END';

      SELECT MAX(optime) INTO utlprp_start_time 
      FROM dba_registry_log
      WHERE comp_id='UTLRP_BGN';

      SELECT MAX(optime) INTO utlprp_end_time 
      FROM dba_registry_log
      WHERE comp_id='UTLRP_END';

      -- datapatch in upgrade mode
      SELECT MAX(optime) INTO dp_upg_start_time
      FROM dba_registry_log
      WHERE comp_id='DP_UPG_BGN';

      SELECT MAX(optime) INTO dp_upg_end_time
      FROM dba_registry_log
      WHERE comp_id='DP_UPG_END';

      -- datapatch in normal mode
      SELECT MAX(optime) INTO dp_nor_start_time
      FROM dba_registry_log
      WHERE comp_id='DP_NOR_BGN';

      SELECT MAX(optime) INTO dp_nor_end_time
      FROM dba_registry_log
      WHERE comp_id='DP_NOR_END';

      -- get RDBMS end time
      SELECT optime, operation, message INTO end_time, status, message
      FROM dba_registry_log
      WHERE comp_id='RDBMS' AND 
            optime = (SELECT MAX(optime) FROM dba_registry_log
                      WHERE comp_id = 'RDBMS');

      -- get RDBMS (catproc) status
      SELECT status INTO catproc_status 
      FROM registry$
      WHERE cid = 'CATPROC';

      -- get RDBMS (catalog) status
      SELECT status INTO catalog_status 
      FROM registry$
      WHERE cid = 'CATALOG';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
  
   IF start_time IS NOT NULL AND end_time IS NOT NULL THEN
      elapsed_time := end_time - start_time;
      time_result := to_char(elapsed_time);
   ELSE
      time_result := NULL;
   END IF;

   --
   -- Get out if no Upgrade Performed
   --
   IF up_end_time IS NULL THEN
      IF display_xml THEN
          DBMS_OUTPUT.PUT_LINE ('<Component id="NONE"' ||
                                ' cid="NONE"');
          DBMS_OUTPUT.PUT_LINE ('" status="NONE"' ||
                                ' upgradeTime="00:00:00">');
          DBMS_OUTPUT.PUT_LINE('<No status to report as upgrade was not performed./>');

          DBMS_OUTPUT.PUT_LINE('</Components>');
          DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
      ELSE
          DBMS_OUTPUT.PUT_LINE('No status to report as upgrade was not performed.');
      END IF;
      RETURN;
   END IF;


   IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE ('<Component id="Oracle Server"' ||
                  ' cid="RDBMS"');
   END IF;

   FOR err in (SELECT message FROM sys.registry$error
               WHERE (identifier = 'CATALOG' OR identifier = 'CATPROC')
               AND    ROWNUM < MAX_ERRORS
               ORDER BY timestamp)
   LOOP
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
      ELSE
         IF (b_first_time) THEN
             DBMS_OUTPUT.PUT_LINE('Oracle Server');
             b_first_time := FALSE;
         END IF;
         DBMS_OUTPUT.PUT_LINE('   ' || err.message);
      END IF;
   END LOOP; -- registry$error loop

   --
   -- Set initial status to catproc_status as the default.
   -- This will set the RDBMS Server as Upgraded (catupgrd.sql)
   -- or Valid (utlrp), if we succeeded.
   -- 
   status := sys.dbms_registry.status_name(catproc_status);

   --
   -- If either catproc or catalog are invalid then mark
   -- the RDBMS Server as Invalid.
   --
   IF (catproc_status = 0 OR catalog_status = 0) THEN
       status := sys.dbms_registry.status_name(0);
   END IF;


   IF display_xml THEN
       DBMS_OUTPUT.PUT_LINE ('" status="' || status ||
                   '" upgradeTime="' || substr(time_result,5,8) ||
                   '">');
   ELSE
      DBMS_OUTPUT.PUT_LINE('Oracle Server' ||
                        LPAD(status,34) || ' ' ||
                        LPAD(substr(message,1,15),15) ||
                        LPAD(substr(time_result,5,8),10));
   END IF;

   -- look for all SERVER components 
   FOR i IN 1..SYS.dbms_registry_server.component.last LOOP
      p_id := dbms_registry_server.component(i);
      IF p_id != 'ODM' THEN  -- ODM has status REMOVED
         start_time := NULL;
         end_time := NULL;
         FOR log IN (SELECT operation, optime, message
                     FROM dba_registry_log WHERE namespace = 'SERVER' AND
                     comp_id = p_id and optime=(SELECT max(optime)
					  FROM dba_registry_log
					  WHERE comp_id = p_id and operation='START')
         	     UNION ALL
	    	     SELECT operation, optime, message
                     FROM dba_registry_log WHERE namespace = 'SERVER' AND
                     comp_id = p_id and optime=(SELECT max(optime)
					  FROM dba_registry_log
					  WHERE comp_id = p_id and operation<>'START')
	             ORDER BY optime) LOOP

            comp_name :=  dbms_registry.comp_name(p_id);

            --
            -- Always display component name but only when
            -- the component changes.  In dba_registry_log
            -- you will have component with multiple operations.
            -- For example JAVAVM is the p_id (component) and
            -- START and VALID are the operations.
            -- We only display the corresponding component
            -- name associated with the p_id once.  In this
            -- example the component name is JServer JAVA Virtual
            -- Machine that is assocatied with the p_id JAVAVM.
            --
            IF (prev_comp_name != comp_name) THEN
               prev_comp_name :=  comp_name;
               IF display_xml THEN
                  DBMS_OUTPUT.PUT_LINE ('<Component id="' || comp_name ||
                         '" cid="' || p_id || '" ');
               END IF;
            END IF;

            IF log.operation = 'START' THEN
               start_time := log.optime;
               b_first_time := TRUE;
	       -- For each Component output up to MAX_ERRORS upgrade errors	
               FOR err in (SELECT message FROM sys.registry$error
                           WHERE identifier = p_id AND ROWNUM < MAX_ERRORS
                           ORDER BY timestamp) LOOP
                  IF display_xml THEN
                    DBMS_OUTPUT.PUT_LINE ('"error="' || err.message || '" ');
                  ELSE
                     IF (b_first_time) THEN
                         DBMS_OUTPUT.PUT_LINE(comp_name);
                         b_first_time := FALSE;
                     END IF;
                     DBMS_OUTPUT.PUT_LINE('    ' || err.message);
                  END IF;
               END LOOP; -- registry$error loop
            ELSE
               BEGIN
                 SELECT status into status
                 FROM dba_registry
                 WHERE namespace = 'SERVER' AND comp_id = p_id;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     b_no_data_found := TRUE;
               END;

               --
               -- Check for No Data found in dba_registry
               -- If Component does not exist in the database
               -- Move to the next component
               --
               IF (b_no_data_found) THEN
                   b_no_data_found := FALSE;
                   continue;
               END IF;

               --
               -- No Start time then no elapsed time
               -- Set time results to display zero
               --
               IF (start_time IS NULL) THEN

                 time_result := '    00:00:00';

               ELSE

                 elapsed_time := log.optime - start_time;
                 time_result := to_char(elapsed_time);

               END IF;

               IF display_xml THEN
                  DBMS_OUTPUT.PUT_LINE ('" status="' || LOWER(status) ||
                         '" upgradeTime="' || substr(time_result,5,8) ||
                         '">');
               ELSE
                  DBMS_OUTPUT.PUT_LINE(rpad(comp_name,35) ||
                                    LPAD(status,12) || ' ' ||
                                    LPAD(substr(log.message,1,15),15) ||
                                    LPAD(substr(time_result,5,8),10));
               END IF;
            END IF;
        
         END LOOP;  -- log loop 
      END IF;  -- not ODM
   END LOOP;  -- component loop

   --
   -- Display Datapatch Upgrade Time
   --
   dp_upg_elasped_time := utlusts_display_nocomp_time(
                                 dp_upg_start_time,
                                 dp_upg_end_time,
                                 'DATAPATCH_UPG',
                                 display_xml,
                                 MAX_ERRORS,
                                 '<Component id="Upgrade Datapatch"',
                                 '" UpgradeDatapatch="',
                                 'Upgrade Datapatch      ');

   --
   -- Display Final Actions Time
   --
   actions_elasped_time := utlusts_display_nocomp_time(
                                 actions_start_time,
                                 actions_end_time,
                                 'ACTIONS',
                                 display_xml,
                                 MAX_ERRORS,
                                 '<Component id="Final Actions"',
                                 '" upgradeTime="',
                                 'Final Actions          ');


   --
   -- Display Post Upgrade Time
   --
   postup_elasped_time := utlusts_display_nocomp_time(
                                 postup_start_time,
                                 postup_end_time,
                                 'POSTUP',
                                 display_xml,
                                 MAX_ERRORS,
                                 '<Component id="Post Upgrade"',
                                 '" PostupgradeTime="',
                                 'Post Upgrade           ');

   --
   -- Display Datapatch Normal Time
   --
   dp_nor_elasped_time := utlusts_display_nocomp_time(
                                 dp_nor_start_time,
                                 dp_nor_end_time,
                                 'POSTUP_DATAPATCH',
                                 display_xml,
                                 MAX_ERRORS,
                                 '<Component id="Post Upgrade Datapatch"',
                                 '" PostUpgradeDatapatch="',
                                 'Post Upgrade Datapatch ');
   --
   -- Display utlprp Upgrade Time
   --
   utlprp_elasped_time := utlusts_display_nocomp_time(
                                 utlprp_start_time,
                                 utlprp_end_time,
                                 'UTLRP',
                                 display_xml,
                                 MAX_ERRORS,
                                 '<Component id="Post Compile"',
                                 '" PostCompileTime="',
                                 'Post Compile           ');

   IF up_end_time IS NOT NULL THEN
      --
      -- Add up Upgrade time, Final Actions, Post Upgrade and Compile Time
      --
      elapsed_time := (up_end_time - up_start_time) +
                      postup_elasped_time +
                      dp_nor_elasped_time +
                      utlprp_elasped_time;

      time_result := to_char(elapsed_time); 
      IF display_xml THEN
         DBMS_OUTPUT.PUT_LINE('<totalUpgrade time="' || 
                  substr(time_result, 5,8) || '">');
      ELSE
         DBMS_OUTPUT.PUT_LINE('');
         IF ( con_id > 0 ) THEN
             DBMS_OUTPUT.PUT_LINE('Total Upgrade Time: ' 
                || substr(time_result, 5,8) || ' [' || 
                sys.dbms_registry.get_container_name(con_id) ||
                ']');
         ELSE
             DBMS_OUTPUT.PUT_LINE('Total Upgrade Time: ' ||  
                      substr(time_result, 5,8));
         END IF;
      END IF;
   END IF;
   IF display_xml THEN
      DBMS_OUTPUT.PUT_LINE('</Components>');
      DBMS_OUTPUT.PUT_LINE('</RDBMSUP>');
   END IF;
END;
/

execute dbms_output.new_line;

declare
rel_tz_version NUMBER;
db_tz NUMBER;
begin
EXECUTE IMMEDIATE 'select version from v$timezone_file' INTO db_tz;
EXECUTE IMMEDIATE 'select dbms_dst.get_latest_timezone_version from dual' INTO rel_tz_version;
if db_tz < rel_tz_version
then
dbms_output.put_line('Database time zone version is '||db_tz||'. It is older than current release time' );
dbms_output.put_line('zone version '||rel_tz_version||'. Time zone upgrade is needed using the DBMS_DST package.');
else
dbms_output.put_line('Database time zone version is '||db_tz||'. It meets current release needs.');
end if;
end;
/

execute dbms_output.new_line;

DROP FUNCTION utlusts_display_nocomp_time;
