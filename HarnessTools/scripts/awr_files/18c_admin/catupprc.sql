Rem
Rem $Header: rdbms/admin/catupprc.sql /main/7 2017/03/20 11:54:05 raeburns Exp $
Rem
Rem catupprc.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupprc.sql - CATalog UPgrade Post-catPRoC
Rem
Rem    DESCRIPTION
Rem      Final scripts for the RDBMS upgrade
Rem
Rem    NOTES
Rem      Invoked by catupgrd.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupprc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupprc.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/05/17 - Bug 25491041: Separate upgrade error checking 
Rem                           from validation routines for CATALOG/CATPROC
Rem    cmlim       03/03/16 - bug 22812750: re-update status of CATPROC after
Rem                           the a* upgrade scripts complete
Rem    jerrede     05/10/13 - Support for CDB, Move calling of timestamp
Rem                           to cmpupstr.sql. Ending of rdbms is to
Rem                           soon as catctl.pl may also invalidate RDBMS after
Rem                           the running of catupprc.sql.
Rem    skabraha    03/03/11 - move validate_all_versions from catupgrd.sql
Rem    rburns      07/11/07 - add patch upgrade
Rem    rburns      06/11/07 - reset packages
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem
Rem Set error logging
@@catprocses.sql

Rem Compilation of standard might end up invalidating all object types,
Rem including older versions. This will cause problems if we have data
Rem depending on these versions, as they cannot be revalidated. Older
Rem versions are only used for data conversion, so we only need the 
Rem information in type dictionary tables which are unaffected by
Rem changes to standard. Reset obj$ status of these versions to valid
Rem so we can get to the type dictionary metadata.
Rem We need to make this a trusted C callout so that we can bypass the
Rem security check. Otherwise we run intp 1031 when DV is already linked in.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/
CREATE OR REPLACE PROCEDURE validate_old_typeversions IS
LANGUAGE C
NAME "VALIDATE_OLD_VERSIONS"
LIBRARY UPGRADE_LIB;
/
execute validate_old_typeversions();
commit;
alter system flush shared_pool;
drop procedure validate_old_typeversions;

Rem get the correct script name into the "upgrade_file" variable
COLUMN file_name NEW_VALUE upgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;

Rem Run the remainder of the RDBMS upgrade in the "a" scripts
@@a&upgrade_file

Rem
Rem  bug 22812750:
Rem    Set CATALOG and CATPROC upgrade complete and reset CATPROC status
Rem  bug 25491041
Rem    Use count_errors_in_registry - CATALOG includes "i", "c", and CATALOG
Rem    errors; CATPROC includes CATPROC and "a" errors
BEGIN
   sys.dbms_registry.upgraded('CATALOG');
   IF sys.dbms_registry.count_errors_in_registry ('CATALOG') > 0 THEN
      sys.dbms_registry.invalid('CATALOG');
   END IF;

   sys.dbms_registry.upgraded('CATPROC');
   IF sys.dbms_registry.count_errors_in_registry ('CATPROC') > 0 THEN
      sys.dbms_registry.invalid('CATPROC');
   END IF;
END;
/

Rem Reset the package state of any packages invalidated during RDBMS upgrade
execute DBMS_SESSION.RESET_PACKAGE; 

