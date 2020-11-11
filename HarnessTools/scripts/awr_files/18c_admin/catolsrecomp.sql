Rem
Rem $Header: rdbms/admin/catolsrecomp.sql /main/3 2017/05/28 22:46:03 stanaya Exp $
Rem
Rem catolsrecomp.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catolsrecomp.sql - Recompiles conflicting OLS objects.
Rem
Rem    DESCRIPTION
Rem      This script recompiles conflicting OLS views, functions and 
Rem      synonyms after a PDB with incompatible OLS configuration is plugged.
Rem
Rem    NOTES
Rem      This script is used to resolve conflicts when a PDB with incompatible 
Rem      Label Security configuration is plugged in a consolidated DB. This
Rem      recompiles all the conflicting objects i.e views, synonyms and functions
Rem      to match that of the consolidated DB.
Rem
Rem      Must be run using catcon.pl as SYSDBA.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catolsrecomp.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catolsrecomp.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    02/16/16 - Bug 22733719: Must explictly set
Rem                           NLS_LENGTH_SEMANTICS to BYTE
Rem    risgupta    10/18/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Bug 22733719: Must explictly set NLS_LENGTH_SEMANTICS to BYTE
alter session set NLS_LENGTH_SEMANTICS=BYTE;

COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(20)

DECLARE
oid BOOLEAN := FALSE;
BEGIN
  -- Get OID configuration status in Root.
  oid := lbacsys.lbac_cache.is_oid_configured;

  IF (oid = FALSE) THEN
    :file_name := 'prvtolsstnd.plb';
  ELSE
    :file_name := 'prvtolsldap.plb';
  END IF;
END;
/

SELECT :file_name FROM DUAL;
@@&comp_file
