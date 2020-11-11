Rem
Rem $Header: rdbms/admin/execemx.sql /main/3 2014/02/20 12:45:37 surman Exp $
Rem
Rem execemx.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execemx.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execemx.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execemx.sql
Rem SQL_PHASE: EXECEMX
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    kyagoub     06/17/11 - reload all emx/framework files in register_files
Rem    yxie        03/06/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Register EM Exprses files
Rem FIXME: do we really need execemx now ?? 
exec prvt_emx.register_files(TRUE);

@?/rdbms/admin/sqlsessend.sql
