Rem
Rem $Header: rdbms/admin/pdb_to_apppdb.sql /main/6 2017/08/21 09:38:56 pjulsaks Exp $
Rem
Rem pdb_to_apppdb.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      pdb_to_apppdb.sql - PDB to Federation PDB
Rem
Rem    DESCRIPTION
Rem      Converts PDB (standalone or Application ROOT) to Application PDB
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/pdb_to_apppdb.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/pdb_to_apppdb.sql
Rem    SQL_PHASE: PDB_TO_APPPDB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    08/21/17 - Bug 26590200: update fed$app$status for 
Rem                           root-cloned pdb
Rem    thbaby      04/22/17 - Bug 25940936: set _enable_view_pdb
Rem    pjulsaks    08/17/16 - XbranchMerge pjulsaks_lrg-19700592 from
Rem                           st_rdbms_12.2.0.1.0
Rem    pjulsaks    08/12/16 - RTI 19700592: remove code that modified 
Rem                           fed$app$status, pdb_sync$, etc. (undo fixes for 
Rem                           bugs 23213558, 21930902, 21652856)
Rem    pjulsaks    05/10/16 - Bug 23213558: add application all sync and 
Rem                           rearrange the code
Rem    thbaby      01/16/16 - Bug 22550952: disallow script in PDB$SEED
Rem    pyam        12/18/15 - renamed from pdb_to_fedpdb.sql
Rem                           (below comments copied from old file)
Rem    pyam        12/13/15 - LRG 18533922: pass argument to loc_to_common3.sql
Rem    pyam        11/25/15 - fed$statements -> pdb_sync$
Rem    pyam        11/22/15 - 21911641: remove fed$sessions
Rem    thbaby      11/03/15 - Bug 21930902: set status in fed$app$status
Rem    juilin      09/01/15 - 21458522: rename syscontext FEDERATION_NAME
Rem    thbaby      08/19/15 - 21652856: remove insert into fed$app$status
Rem    surman      01/08/15 - 19475031: Update SQL metadata
Rem    pyam        09/09/14 - Proj 47234: script to run in PDB to convert into
Rem                           a Federation PDB
Rem    pyam        09/09/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

WHENEVER SQLERROR EXIT;

alter session set "_enable_view_pdb"=false;

VARIABLE cdbname VARCHAR2(128)
VARIABLE pdbname VARCHAR2(128)
VARIABLE appname VARCHAR2(128)
BEGIN
  -- Disallow script in non-CDB
  SELECT sys_context('USERENV', 'CDB_NAME') 
    INTO :cdbname
    FROM dual
    WHERE sys_context('USERENV', 'CDB_NAME') is not null;
  -- Disallow script in CDB Root
  -- Disallow script in PDB$SEED (Bug 22550952)
  SELECT sys_context('USERENV', 'CON_NAME') 
    INTO :pdbname
    FROM dual
    WHERE sys_context('USERENV', 'CON_NAME') <> 'CDB$ROOT'
    AND   sys_context('USERENV', 'CON_NAME') <> 'PDB$SEED';
  -- Disallow script outside of Application Container
  SELECT sys_context('USERENV', 'APPLICATION_NAME') 
    INTO :appname
    FROM dual
    WHERE sys_context('USERENV', 'APPLICATION_NAME') is not null;
END;
/

-- this script should only be run in an application PDB
select TO_NUMBER('NOT_IN_APPLICATION_PDB') from v$pdbs
  where con_id=sys_context('USERENV', 'CON_ID') and application_pdb<>'YES';

@@?/rdbms/admin/loc_to_common0.sql
@@?/rdbms/admin/loc_to_common1.sql 5

/* Bug 26590200: Update fed$app$status when pdb is cloned from approot, 
 * if this is not the case, fed$apps and pdb_sync$ should be empty 
 */
insert into fed$app$status (appid#, lastseq#, errorseq#)
select a.appid#, max(s.replay#), 0 from pdb_sync$ s, fed$apps a 
  where a.appid# = s.appid# and bitand(flags,8)=8 and a.spare1=0 
  group by a.appid#;
commit;

/* Bug 23213558: Execute sync command to copy the application data from root */
alter session set "_skip_app_unconverted_check" = TRUE;
alter pluggable database application all sync;
alter session set "_skip_app_unconverted_check" = FALSE;

@@?/rdbms/admin/loc_to_common2.sql 1
@@?/rdbms/admin/loc_to_common3.sql 0


@@?/rdbms/admin/loc_to_common4.sql 6

