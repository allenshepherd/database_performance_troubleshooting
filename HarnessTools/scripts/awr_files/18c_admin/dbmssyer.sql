rem 
rem $Header: rdbms/admin/dbmssyer.sql /main/6 2014/02/20 12:45:48 surman Exp $
rem 
Rem  Copyright (c) 1992 by Oracle Corporation 
Rem    NAME
Rem      dbmssyer.sql - DBMS_SYs_ErroR - pl/sql routines for 
Rem                     system error messages for DBMS* routines.
Rem    DESCRIPTION
Rem      This package is private.
Rem    RETURNS
Rem 
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmssyer.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmssyer.sql
Rem SQL_PHASE: DBMSSYER
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     surman     12/29/13  - 13922626: Update SQL metadata
Rem     surman     03/27/12  - 13615447: Add SQL patching tags
Rem     adowning   03/29/94 -  merge changes from branch 1.1.710.2
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     dsdaniel   11/01/93 -  Branch_for_patch
Rem     dsdaniel   10/29/93 -  Creation
Rem
REM ********************************************************************
REM THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD*  ROUTINES MUST NOT BE
REM CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************

@@?/rdbms/admin/sqlsessstart.sql


@?/rdbms/admin/sqlsessend.sql
