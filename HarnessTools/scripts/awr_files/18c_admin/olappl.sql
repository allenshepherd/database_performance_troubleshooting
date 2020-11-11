rem 
rem $Header: oraolap/admin/olappl.sql /main/9 2014/02/20 12:44:09 surman Exp $ 
rem 
Rem Copyright (c) 2004, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem    NAME
Rem      olappl.sql
Rem    DESCRIPTION
Rem      Install OLAP-related PL/SQL packages
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected AS SYSDBA.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: oraolap/admin/olappl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/olappl.sql
Rem SQL_PHASE: OLAPPL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     surman     01/13/14 - 13922626: Update SQL metadata
Rem     cchiappa   03/14/13 - Backport cchiappa_set_oracle_script_121010
Rem     surman     03/28/12 - 13615447: Add SQL patching tags
Rem     cchiappa   06/04/08 - Add dbmscbl and prvtcbl
Rem     ckearney   06/05/06 - add dbmsawst.sql & prvtawst.plb 
Rem     cchiappa   01/18/05 - Run olaptf.plb 
Rem     cchiappa   01/11/05 - Move DBMS_AW_XML to catawxml 
Rem     cchiappa   12/13/04 - Add dbmsawx, unwrap dbmsaw.sql 
Rem     cchiappa   04/06/04 - created
Rem

@@?/rdbms/admin/sqlsessstart.sql

@@dbmsaw.sql
@@prvtaw.plb
@@olaptf.plb
@@dbmsawex.sql
@@prvtawex.plb
@@dbmsawst.sql
@@prvtawst.plb
@@dbmscbl.sql
@@prvtcbl.plb

@@?/rdbms/admin/sqlsessend.sql
