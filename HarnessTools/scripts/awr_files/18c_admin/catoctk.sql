Rem
Rem $Header: rdbms/admin/catoctk.sql /main/3 2016/10/12 11:01:00 frealvar Exp $
Rem
Rem catoctk.sql
Rem
Rem Copyright (c) 1997, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catoctk.sql - CATalog - Oracle Cryptographic ToolKit
Rem
Rem    DESCRIPTION
Rem      Contains scripts needed to use the PL/SQL Cryptographic Toolkit
Rem      Interface
Rem
Rem    NOTES
Rem      None.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catoctk.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catoctk.sql
Rem SQL_PHASE: CATOCTK
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    frealvar    09/15/16 - Bug 24661828: set NLS_LENGTH_SEMANTICS to BYTE
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    rwessman    04/15/97 - Added actual SQL.
Rem    rwessman    04/14/97 - Cryptographic toolkit catalog
Rem    rwessman    04/14/97 - Created
Rem
Rem Cryptographic toolkit package declaration
Rem

@@?/rdbms/admin/sqlsessstart.sql

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

@@dbmsoctk.sql
Rem
Rem Cryptographic toolkit package body
Rem
@@prvtoctk.plb
Rem
Rem Random number generator
Rem
@@dbmsrand.sql


@?/rdbms/admin/sqlsessend.sql
