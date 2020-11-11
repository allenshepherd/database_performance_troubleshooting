Rem
Rem $Header: plsql/admin/utlrefld.sql /main/4 2014/02/20 12:46:21 surman Exp $
Rem
Rem utlrefld.sql
Rem
Rem Copyright (c) 1997, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlrefld.sql - Load UTL_REF package on the server
Rem
Rem    DESCRIPTION
Rem      Installs the utl_ref package on the rdbms.
Rem
Rem    NOTES
Rem      Must be executed as SYS.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: plsql/admin/utlrefld.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/utlrefld.sql
Rem SQL_PHASE: UTLREFLD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/13/14 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rxgovind    03/25/98 - merge from 8.0.5
Rem    sabburi     08/20/97 - installation of utl_ref package
Rem    sabburi     08/20/97 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace library DBMS_UTL_REF_LIB TRUSTED as STATIC;
/
@@utlref.plb
@@prvtref.plb

@?/rdbms/admin/sqlsessend.sql
