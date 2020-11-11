Rem
Rem $Header: rdbms/admin/cmpupstr.sql /main/4 2017/04/11 17:07:31 welin Exp $
Rem
Rem cmpupstr.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupstr.sql - CoMPonent UPgrade STaRt script
Rem
Rem    DESCRIPTION
Rem      Initial component upgrade actions
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupstr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupstr.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    welin       03/23/17 - Bug 25790099: Add SQL_METADATA
Rem    raeburns    02/25/17 - Bug 25790099: record timestamp CMPUPGRD_BGN
Rem    cmlim       06/06/16 - bug 23215791: add more DBUA_TIMESTAMPs during db
Rem                           upgrades
Rem    jerrede     05/10/13 - Support for CDB, Move calling of timestamp
Rem                           to cmpupstr.sql. Ending of rdbms is to
Rem                           soon as catctl.pl may also invalidate RDBMS after
Rem                           the running of catupprc.sql.
Rem    rburns      05/23/06 - parallel upgrade 
Rem    rburns      05/23/06 - Created
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

Rem =====================================================================
Rem RDBMS UPgrade Complete
Rem =====================================================================

SELECT dbms_registry_sys.time_stamp('rdbms_end') as timestamp from dual;

-- DBUA_TIMESTAMP: database components upgrade begins
SELECT dbms_registry_sys.time_stamp('CMPUPGRD_BGN') AS timestamp FROM DUAL;
