Rem
Rem $Header: rdbms/admin/catproftab.sql /main/3 2014/02/20 12:45:53 surman Exp $
Rem
Rem catproftab.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catproftab.sql - Privilege Profile Tables and Views
Rem
Rem    DESCRIPTION
Rem      Invoked in catptabs.sql
Rem
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catproftab.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catproftab.sql
Rem SQL_PHASE: CATPROFTAB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jheng       05/16/11 - project 32973: tables and views for privilege
Rem                           profile
Rem    jheng       05/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- tables used for privilege profile
@@catprofc.sql

-- views
@@catprofa.sql

@?/rdbms/admin/sqlsessend.sql
