Rem
Rem $Header: plsql/admin/plspur.sql /main/4 2014/02/20 12:45:56 surman Exp $
Rem
Rem plspurity.sql
Rem
Rem Copyright (c) 1998, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      plspur.sql - sys_stub_for_purity_analysis definitions
Rem
Rem    DESCRIPTION
Rem      Define package sys_stub_for_purity_analysis.
Rem      As we create the top level subprograms, a dependency between
Rem    the subprogram and this package is formed.  For more info on
Rem    this package, please refer to the document on interop purity
Rem
Rem    NOTES
Rem      This package has to run after the creation of standard and
Rem    before any other creation of top level subprograms.
Rem      Top level subprograms should NOT be defined in standard.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/plspur.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/plspur.sql
Rem SQL_PHASE: PLSPUR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/09/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    nle         05/11/98 - change stub package name
Rem    nle         04/27/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package sys_stub_for_purity_analysis as
  procedure prds;
  pragma restrict_references(prds, wnds, rnps, wnps);

  procedure pwds;
  pragma restrict_references(pwds, rnds, rnps, wnps);

  procedure prps;
  pragma restrict_references(prps, rnds, wnds, wnps);

  procedure pwps;
  pragma restrict_references(pwps, rnds, wnds, rnps);
end sys_stub_for_purity_analysis;
/
show errors;

@?/rdbms/admin/sqlsessend.sql
