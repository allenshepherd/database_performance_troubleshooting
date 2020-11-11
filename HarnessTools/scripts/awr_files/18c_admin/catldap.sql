Rem
Rem $Header: rdbms/admin/catldap.sql /main/3 2014/02/20 12:45:56 surman Exp $
Rem
Rem catldap.sql
Rem
Rem Copyright (c) 2000, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catldap.sql - CATalog for LDAP pl/sql API
Rem
Rem    DESCRIPTION
Rem      Contains scripts needed to use the PL/SQL LDAP API
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catldap.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catldap.sql
Rem SQL_PHASE: CATLDAP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       surman   12/29/13 - 13922626: Update SQL metadata
Rem       surman   03/27/12 - 13615447: Add SQL patching tags
Rem       akolli   01/07/00 - PL/SQL LDAP API catalog
Rem                01/07/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem 
Rem LDAP API header 
Rem 
@@prvtldh.plb

Rem
Rem LDAP API package declaration
Rem
@@dbmsldap.sql

Rem
Rem LDAP API package body
Rem
@@prvtldap.plb


@?/rdbms/admin/sqlsessend.sql
