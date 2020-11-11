@@?/rdbms/admin/sqlsessstart.sql
Rem
Rem $Header: plsql/src/apps/gen/utl_ident/utlident.pls /main/3 2014/02/20 12:45:56 surman Exp $
Rem
Rem utlident.sql
Rem
Rem Copyright (c) 2007, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlident.sql - PL/SQL Package for IDENTification information
Rem
Rem    DESCRIPTION
Rem      The package utl_ident specifies which Database or client PL/SQL is
Rem      running in. 
Rem
Rem    NOTES
Rem      This package is meant for use to conditional compile PL/SQL
Rem      packages that are supported by Oracle, TimesTen Database, and
Rem      possibly other clients like Oracle Forms.  This does not forbid other
Rem      uses but additions/changes to this package must be carefully
Rem      considered.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/src/apps/gen/utl_ident/utlident.pls
Rem SQL_SHIPPED_FILE: rdbms/admin/utlident.sql
Rem SQL_PHASE: UTLIDENT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/14/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sylin       11/23/10 - create template for utl_ident package
Rem    lvbcheng    09/10/10 - Add XE flag
Rem    sylin       09/25/09 - add is_oracle_forms
Rem    sylin       02/26/08 - rename is_timesten_server to is_timesten
Rem    sylin       08/13/07 - Created
Rem

create or replace package utl_ident is

  /* A typical usage of these boolean constants is

         $if utl_ident.is_oracle_server $then
           code supported for Oracle Database
         $elsif utl_ident.is_timesten $then
           code supported for TimesTen Database
         $end
   */

  /* an XE database is an Oracle server but an Oracle
     server is not necessarily XE */
  is_oracle_xe         constant boolean := FALSE;
  is_oracle_server     constant boolean := TRUE;
  is_oracle_client     constant boolean := FALSE;
  is_timesten          constant boolean := FALSE;
  is_oracle_forms      constant boolean := FALSE;

end utl_ident;
/

create or replace public synonym utl_ident for utl_ident
/
grant execute on utl_ident to public
/

@?/rdbms/admin/sqlsessend.sql
