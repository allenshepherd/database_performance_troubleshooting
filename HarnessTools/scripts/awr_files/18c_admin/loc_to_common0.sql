Rem
Rem $Header: rdbms/admin/loc_to_common0.sql /main/5 2017/04/25 08:09:06 thbaby Exp $
Rem
Rem loc_to_common0.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      loc_to_common0.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/loc_to_common0.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/loc_to_common0.sql
Rem    SQL_PHASE: LOC_TO_COMMON0
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      04/21/17 - Bug 25940936: set _enable_view_pdb
Rem    sankejai    01/22/16 - 16076261: session parameters scoped to container 
Rem    pyam        12/22/15 - 21927236: rename pdb_to_fedpdb to pdb_to_apppdb
Rem    pyam        09/22/15 - 20959267: check for version mismatch
Rem    pyam        07/15/15 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

COLUMN pdbname NEW_VALUE pdbname
COLUMN pdbid NEW_VALUE pdbid


alter session set "_enable_view_pdb"=false;
select :pdbname pdbname from dual;

select TO_CHAR(con_id) pdbid from v$pdbs where name='&pdbname';

-- save pluggable database open mode
COLUMN open_state_col NEW_VALUE open_sql;
COLUMN restricted_col NEW_VALUE restricted_state;
SELECT decode(open_mode,
              'READ ONLY', 'ALTER PLUGGABLE DATABASE &pdbname OPEN READ ONLY',
              'READ WRITE', 'ALTER PLUGGABLE DATABASE &pdbname OPEN',
              'MIGRATE', 'ALTER PLUGGABLE DATABASE &pdbname OPEN UPGRADE', '')
         open_state_col,
       decode(restricted, 'YES', 'RESTRICTED', '')
         restricted_col
       from v$pdbs where name='&pdbname';

alter session set container=CDB$ROOT;

-- if pdb was already closed, don't exit on error
WHENEVER SQLERROR CONTINUE;
alter pluggable database "&pdbname" close immediate instances=all;
WHENEVER SQLERROR EXIT;

alter pluggable database "&pdbname" open upgrade;

-- check that PDB and CDB versions match
SELECT TO_NUMBER('VERSION MISMATCH') from sys.dual
 WHERE (select count(*) from pdb_alert$ where name='&pdbname' and cause#=65
                                          and status=1) > 0;

alter session set container = "&pdbname";
alter session set "_enable_view_pdb"=false;

-- initial setup before beginning the script
-- Bug 16076261: nls_length_semantics is not a parameter, so the value is not
-- lost after set container in further scripts.
alter session set NLS_LENGTH_SEMANTICS=BYTE;

