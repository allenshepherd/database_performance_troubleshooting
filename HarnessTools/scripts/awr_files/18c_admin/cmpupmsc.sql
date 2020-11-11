Rem
Rem $Header: rdbms/admin/cmpupmsc.sql /main/14 2017/04/11 17:07:31 welin Exp $
Rem
Rem cmpupmsc.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupmsc.sql - CoMPonent UPgrade MiSC components
Rem
Rem    DESCRIPTION
Rem      Upgrade other components dependent on both XDB and Java
Rem      Ultrasearch, Expression Filter, Rule Manager
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupmsc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupmsc.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    welin       03/23/17 - Bug 25790099: Add SQL_METADATA
Rem    raeburns    01/15/15 - move APEX upgrade to CATCTL via cmpupgrd.sql
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     01/10/13 - Fix Bug 16097914 Update registry with OPTION OFF
Rem                           for RUL and EXF Components. Also move RUL and
Rem                           EXF Components from post upgrade to upgrade due
Rem                           to problems with Logminer/Standby.
Rem    jerrede     12/20/12 - Remove EXF and RUL  obsolete in 12.1.0.1.0
Rem    jerrede     03/26/12 - Fix Deadlock with OWM lrg #6730021
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    sanagara    02/17/09 - move OWM here from cmpupnjv.sql
Rem    cdilling    07/30/08 - remove ultrasearch is not "used" 
Rem    rburns      02/17/07 - rework apex script
Rem    cdilling    12/18/06 - XOQ XDB dependency
Rem    rburns      09/20/06 - add APEX upgrade
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
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

set serveroutput off

Rem =====================================================================
Rem Upgrade Oracle Data Mining
Rem =====================================================================

Rem Set identifier to ODM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'ODM';

SELECT dbms_registry_sys.time_stamp_display('ODM') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('ODM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Remove Ultra Search as it is no longer supported in 11.2
Rem =====================================================================

Rem If Ultra Search user exists but Ultra Search is not "used" then
Rem automatically invoke wkremov.sql script to clean up Ultra Search.
Rem
Rem If Ultra Search user exists but Ultra Search is "used" then
Rem write a WARNING message to the Oracle_Server.log telling the user
Rem to backup the database and run the /rdbms/admin/wkremov.sql script.
Rem
Rem Ultra Search is not used when three conditions are satisfied:
Rem
Rem Condition 1) Index is empty
Rem
Rem  SQL> select count(1) from wk_test.dade difr$wk$doc_path_idx$i;
Rem
Rem COUNT(1)
Rem ----------
Rem     0
Rem
Rem Condition 2) wk_test.wk$url table is empty
Rem
Rem  SQL> select count(1) from wk_test.wk$url;
Rem
Rem  COUNT(1)
Rem  ----------
Rem     0
Rem
Rem  Condition 3) No custom data source created
Rem
Rem SQL> select count(1) from wksys.wk$_data_source
Rem   2> where DS_NAME not in ('Email Source','calendar','files','mail','web');
Rem
Rem   COUNT(1)
Rem  ----------
Rem     0 

DECLARE
  n number := 0;
  index_count number := 0;
  table_count number := 0;
  data_count number  := 0;

BEGIN
  -- Determine if WKSYS user exists
  SELECT count(*) INTO n FROM all_users WHERE username = 'WKSYS';
  BEGIN   
    -- The WKSYS user does not exist so there is no script to invoke
    IF (n = 0) THEN
     :dbinst_name := dbms_registry.nothing_script;        
    ELSE
       -- WKSYS User does exist 
       :dbinst_name := dbms_registry_server.WK_path || 'wkremov.sql';
       -- Check if index is empty        
       EXECUTE IMMEDIATE 
          'select count(1) into index_count from wk_test.dr$wk$doc_path_idx$i';
       -- Check if table is empty
       EXECUTE IMMEDIATE
          'select count(1) into table_count from wk_test.wk$url';
       -- Check if no custom data source created
       EXECUTE IMMEDIATE
          'select count(1) into data_count from wksys.wk$_data_source
            where DS_NAME 
            not in (''Email Source'',''calendar'',''files'',''mail'',''web'')';
       -- When all the conditions are met, then ultra search is used
       IF (index_count = 0) or (table_count = 0) or (data_count = 0)
       THEN
          :dbinst_name := dbms_registry.nothing_script;   
          dbms_system.ksdwrt(dbms_system.alert_file + dbms_system.trace_file,
  'WARNING: Ultra Search is not supported in 11.2 and must be removed by 
  running /rdbms/admin/wkremov.sql. If you need to preserve Ultra Search data, 
  please perform a manual cold backup prior to upgrade.');
       END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
END;
/
Rem Set identifier to WK for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'WK';


SELECT dbms_registry_sys.time_stamp_display('WK') AS timestamp FROM DUAL;

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem =======================================================================
Rem If EXF/RUL in the database, run @catnoexf.sql to remove EXF/RUL schema
Rem =======================================================================

Rem Set identifier to EXF for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'EXF';

SELECT dbms_registry_sys.time_stamp_display('EXF') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.time_stamp_display('RUL') AS timestamp FROM DUAL;

set serveroutput on;
COLUMN :exf_name NEW_VALUE exf_file NOPRINT;
VARIABLE exf_name VARCHAR2(30)
DECLARE
  c_EXFEVENT CONSTANT VARCHAR2(21)  := '_remove_exf_component';
  b_ExfEvt BOOLEAN := sys.dbms_registry.is_trace_event_set(c_EXFEVENT);
BEGIN
   --
   -- When the following trace event is set to FALSE
   -- then the removal of EXF/RUL is not executed.
   -- The default is to remove EXF/RUL as part of the upgrade
   -- this will happen when trace event is set to TRUE (default).
   --
   IF (b_ExfEvt) THEN
     sys.dbms_output.put_line('cmpupmsc: b_ExfEvt     = TRUE');
   ELSE
     sys.dbms_output.put_line('cmpupmsc: b_ExfEvt     = FALSE');
   END IF;

   --
   -- Check to see if EXF is loaded.
   -- RUL cannot exists without EXF present.
   --
   IF (dbms_registry.is_loaded('EXF') IS NOT NULL) THEN

      IF (b_ExfEvt) THEN
          --
          -- Remove RULS and EXF From the database
          --
          :exf_name := '@catnoexf.sql';
      ELSE
          --
          -- Leave as is in the database
          --
          :exf_name := dbms_registry.nothing_script;

          --
          -- Set RUL Component Status to OPTION OFF if loaded
          --
          IF sys.dbms_registry.is_loaded('RUL') IS NOT NULL THEN
              sys.dbms_registry.Option_Off('RUL');
          END IF;

          --
          -- Set EXF Component Status to OPTION OFF
          --
          sys.dbms_registry.Option_Off('EXF');

      END IF;

   ELSE

      --
      -- EXF Not Present do nothing
      --
      :exf_name := dbms_registry.nothing_script;   -- No EXF/RUL

   END IF;
END;
/

set serveroutput off;
SELECT :exf_name FROM DUAL;
@&exf_file
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP API
Rem =====================================================================

Rem Set identifier to XOQ for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XOQ';

SELECT dbms_registry_sys.time_stamp_display('XOQ') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('XOQ') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;
