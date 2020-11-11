
Rem
Rem $Header: rdbms/admin/catbsln.sql /main/3 2014/02/20 12:45:44 surman Exp $
Rem
Rem catbsln.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catbsln.sql - Baseline schema creation.
Rem
Rem    DESCRIPTION
Rem      Creates the EM baseline feature schema components
Rem
Rem    NOTES
Rem      Called by catsnmp.sql during database creation.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catbsln.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catbsln.sql
Rem SQL_PHASE: CATBSLN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catsnmp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jsoule      05/02/06 - created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Create object types for bsln.
@@catbslny.sql

Rem Create tables for bsln.
@@catbslnt.sql

Rem Create the BSLN package definition.
@@dbmsbsln.sql

Rem Create the BSLN_INTERNAL package definition, package body.
Rem Create the BSLN package body.
@@prvtblid.plb
@@prvtblib.plb
@@prvtbsln.plb

Rem Seed the tables.
@@catbslnd.sql

Rem Create views for bsln.
@@catbslnv.sql


@?/rdbms/admin/sqlsessend.sql
