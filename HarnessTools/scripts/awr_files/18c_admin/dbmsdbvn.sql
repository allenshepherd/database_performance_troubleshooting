Rem
Rem $Header: plsql/admin/dbmsdbvn.sql /main/10 2017/10/13 18:07:14 wxli Exp $
Rem
Rem dbmsdbvn.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsdbvn.sql - RDBMS version information
Rem
Rem    DESCRIPTION
Rem      The package dbms_db_version specifies RDBMS version information
Rem      (for example, major version number and release number). They are
Rem      presented as package constants.
Rem    NOTES
Rem      This package is meant for use by the users of PL/SQL conditional
Rem      compilation. This does not forbid other uses but additions/changes
Rem      to this package must be carefully considered.
Rem
Rem      This script should be run as user SYS.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/dbmsdbvn.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsdbvn.sql
Rem SQL_PHASE: DBMSDBVN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wxli        06/16/17 - Use predefined version constants
Rem    jdavison    04/11/17 - Version 18 changes
Rem    jciminsk    03/19/14 - bump the version
Rem    surman      01/09/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    wxli        02/02/11 - add version 12.1
Rem    wxli        11/14/08 - add version 11.2
Rem    wxli        09/20/06 - add version 11.1
Rem    mxyang      09/10/04 - rewrite some comments
Rem    mxyang      05/28/04 - mxyang_bug-3644582
Rem    mxyang      04/09/04 - Created

@@?/rdbms/admin/sqlsessstart.sql

@@?/rdbms/admin/dbms_registry_basic.sql

create or replace package dbms_db_version is
  version constant pls_integer := 
          &C_ORACLE_HIGH_VERSION_0_DOTS; -- RDBMS version number
  release constant pls_integer := 0;  -- RDBMS release number

  /* The following boolean constants follow a naming convention. Each
     constant gives a name for a boolean expression. For example,
     ver_le_9_1  represents version <=  9 and release <= 1
     ver_le_10_2 represents version <= 10 and release <= 2
     ver_le_10   represents version <= 10

     Code that references these boolean constants (rather than directly 
     referencing version and release) will benefit from fine grain 
     invalidation as the version and release values change.

     A typical usage of these boolean constants is

         $if dbms_db_version.ver_le_10 $then
           version 10 and ealier code
         $elsif dbms_db_version.ver_le_11 $then
           version 11 code
         $else
           version 12 and later code
         $end

     This code structure will protect any reference to the code
     for version 12. It also prevents the controlling package
     constant dbms_db_version.ver_le_11 from being referenced
     when the program is compiled under version 10. A similar
     observation applies to version 11. This scheme works even
     though the static constant ver_le_11 is not defined in
     version 10 database because conditional compilation protects
     the $elsif from evaluation if the dbms_db_version.ver_le_10 is
     TRUE.
  */

  /* Deprecate boolean constants for unsupported releases */

  ver_le_9_1    constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_9_1);
  ver_le_9_2    constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_9_2);
  ver_le_9      constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_9);
  ver_le_10_1   constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_10_1);
  ver_le_10_2   constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_10_2);
  ver_le_10     constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_10);
  ver_le_11_1   constant boolean := FALSE;
  PRAGMA DEPRECATE(ver_le_11_1);
  ver_le_11_2   constant boolean := FALSE;
  ver_le_11     constant boolean := FALSE;
  ver_le_12_1   constant boolean := FALSE;
  ver_le_12_2   constant boolean := FALSE;
  ver_le_12     constant boolean := FALSE;
  ver_le_18     constant boolean := TRUE;

end dbms_db_version;
/

create or replace public synonym dbms_db_version for dbms_db_version
/
grant execute on dbms_db_version to public
/

@?/rdbms/admin/sqlsessend.sql
