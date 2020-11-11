Rem
Rem $Header: rdbms/admin/cmpupjav.sql /main/18 2017/04/11 17:07:31 welin Exp $
Rem
Rem cmpupjav.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupjav.sql - CoMPonent UPgrade JAVa
Rem
Rem    DESCRIPTION
Rem      Upgrade Java
Rem
Rem    NOTES
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupjav.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupjav.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    02/23/17 - Bug 25790099: move catjava and xdk upgrade here 
Rem    ssonawan    09/03/13 - bug 17384626: use 'DROP JAVA' ddl to drop AppCtx
Rem                           java classes
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    jerrede     04/03/13 - Support for CDB
Rem    jerrede     12/20/12 - Bug#16025279 Add Event for Not Removing EXF/RUL
Rem                           Upgrade Components
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    ssonawan    01/27/10 - Bug 9315778: use 'execute immediate'
Rem    ssonawan    08/13/09 - Bug 8746395: check JAVAVM before dropping appctx
Rem    ssonawan    07/16/09 - Bug 8687981: drop appctx package
Rem    rburns      01/16/08 - add reset package
Rem    cdilling    12/18/06 - add log entry on java install
Rem    rburns      07/19/06 - include XML 
Rem    cdilling    06/08/06 - add errorlogging support 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

-- clear package state before running component scripts
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
Rem Upgrade JServer
Rem =====================================================================

Rem Set identifier to JAVAVM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'JAVAVM';

SELECT dbms_registry_sys.time_stamp_display('JAVAVM') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('JAVAVM') AS dbmig_name FROM DUAL;

@&dbmig_file
Rem If Intermedia, Ultrasearch, Spatial, Data Mining upgrade, 
Rem    first install JAVAVM if it is not loaded

BEGIN
  IF dbms_registry.is_loaded('JAVAVM') IS NULL AND
     (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
      dbms_registry.is_loaded('WK') IS NOT NULL OR
      dbms_registry.is_loaded('SDO') IS NOT NULL OR
      dbms_registry.is_loaded('ODM') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.JAVAVM_path || 'initjvm.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('JAVAVM', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;  
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;


Rem =====================================================================
Rem Upgrade Java XDK
Rem =====================================================================

Rem Set identifier to XML for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XML';

SELECT dbms_registry_sys.time_stamp_display('XML') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('XML') AS dbmig_name FROM DUAL;

@&dbmig_file

Rem If Intermedia upgrade, first install XML if it is not loaded
BEGIN
   IF dbms_registry.is_loaded('XML') IS NULL AND
      (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
       dbms_registry.is_loaded('SDO') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.XML_path || 'initxml.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('XML', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;  
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;


Rem =====================================================================
Rem Java Supplied Packages
Rem =====================================================================

Rem Set identifier to CATJAVA for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'CATJAVA';

SELECT dbms_registry_sys.time_stamp_display('CATJAVA') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.dbupg_script('CATJAVA') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If JAVAVM install for dependencies no CATJAVA, load it
BEGIN
  IF dbms_registry.is_loaded('CATJAVA') IS NULL AND
     dbms_registry.is_loaded('JAVAVM') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.CATJAVA_path || 'catjava.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('CATJAVA', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;




