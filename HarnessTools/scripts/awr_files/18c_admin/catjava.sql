Rem
Rem $Header: rdbms/admin/catjava.sql /main/21 2017/07/21 12:49:39 tojhuan Exp $
Rem
Rem catjava.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catjava.sql - CATalog scripts for JAVA
Rem
Rem    DESCRIPTION
Rem      This script loads the java classes for RDBMS features; it
Rem      should be run after JAVA is loaded into the database.  The
Rem      CATNOJAV.SQL script should be used to remove these java 
Rem      classes prior to removing JAVA from the database.
Rem
Rem    NOTES
Rem      Use SQL*Plus when connected AS SYSDBA
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catjava.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catjava.sql
Rem    SQL_PHASE:  CATJAVA
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     07/21/17 - Bug 25515456: bring back package dbms_sqljtype
Rem    tojhuan     06/09/17 - Bug 24623721: drop obsolete package dbms_sqljtype
Rem    raeburns    04/14/17 - Bug 25790192: Add SQL_METADATA
Rem    frealvar    09/15/16 - Bug 24661828: set NLS_LENGTH_SEMANTICS to BYTE
Rem    sramakri    06/09/16 - remove CDC from 12.2
Rem    frealvar    02/10/16 - Bug22649453 change calls is_valid to is_loaded
Rem    thbaby      06/13/12 - create CDB views over DBA views
Rem    ssonawan    02/13/09 - Bug 6736417: Don't load appctx package
Rem    rgmani      04/02/08 - Load scheduler java package
Rem    gssmith     02/05/07 - Remove Summary Advisor Java component
Rem    nireland    06/09/05 - Increase buffer size. #4380942 
Rem    mkrishna    11/15/04 - add xquery jar by defaut 
Rem    rburns      09/09/03 - cleanup 
Rem    jwwarner    06/24/03 - add loading of catxdbj.sql here
Rem    rburns      04/26/03 - use serveroutput for diagnostics
Rem    rburns      06/13/02 - comments for catnojav.sql
Rem    rburns      04/05/02 - continue even if Jserver not valid
Rem    rburns      02/11/02 - add registry version
Rem    rburns      01/12/02 - Merged rburns_catjava
Rem    rburns      12/03/01 - Created
Rem

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

DOC
##########################################################################
##########################################################################
   If the following PL/SQL block fails, then JServer is not operational.
##########################################################################
##########################################################################
#

BEGIN
   IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) != 1 THEN
      RAISE_APPLICATION_ERROR(-20000,
           'JServer has not been correctly loaded into the database.');   
   END IF;
END;
/

BEGIN
   sys.dbms_registry.loading('CATJAVA','Oracle Database Java Packages',
        'DBMS_REGISTRY_SYS.validate_catjava');
END;
/

VARIABLE initfile VARCHAR2(32)
COLUMN :initfile NEW_VALUE init_file NOPRINT;

Rem =====================================================================
Rem SQLJTYPE
Rem =====================================================================

BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := 'initsjty.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem AQ JMS
Rem =====================================================================

BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := 'initjms.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem ODCI and Cartridge Services
Rem =====================================================================

BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := 'initsoxx.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem XDB Java components if XDK is also loaded
Rem =====================================================================
BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := sys.dbms_registry.script('XML', '@catxdbj.sql');
  ELSE
     :initfile := '@nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@&init_file

Rem Load XQuery java classes ONLY if XDK java is loaded
BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := sys.dbms_registry.script('XML', '@initxqry.sql');
  ELSE
     :initfile := '@nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@&init_file

Rem =====================================================================
Rem Scheduler Java code
Rem =====================================================================

BEGIN
  IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
     :initfile := 'initscfw.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file


Rem =====================================================================
Rem Only set status to LOADED if JServer is loaded
Rem =====================================================================

Rem for invalid object diagnostic output
SET SERVEROUTPUT ON        

DECLARE
   instance_status VARCHAR2(30);
BEGIN
   IF sys.dbms_registry.is_loaded('JAVAVM',sys.dbms_registry.release_version) = 1 THEN
      sys.dbms_registry.loaded('CATJAVA');
      -- Don't validate during upgrades, leave that for post-upgrade utlrp
      SELECT status INTO instance_status FROM v$instance;
      IF instance_status != 'OPEN MIGRATE' THEN
          sys.dbms_registry_sys.validate_catjava;
      END IF;
   END IF;
END;
/
SET SERVEROUTPUT OFF

Rem *********************************************************************
Rem END CATJAVA.SQL 
Rem *********************************************************************
