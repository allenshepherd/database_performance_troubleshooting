Rem
Rem $Header: rdbms/admin/upgrdpdb.sql /st_rdbms_18.0/3 2018/05/02 12:52:06 akruglik Exp $
Rem
Rem upgrdpdb.sql
Rem
Rem Copyright (c) 2016, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      upgrdpdb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Upgrade a single PDB using capture/replay
Rem
Rem    NOTES
Rem      Should be conected to the PDB when run.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/upgrdpdb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/upgrdpdb.sql
Rem    SQL_PHASE: PDB
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        11/21/17 - Bug 26527096: use upg mode for pt2 for app pdb
Rem    pyam        11/04/17 - Bug 26894818: fix query for multiple imported
Rem                           capture tables
Rem    pyam        10/13/17 - close -> close immediate
Rem    pyam        06/08/17 - Bug 25578235: catctl-supported output
Rem    pyam        06/07/17 - Remove unneeded diagnostic
Rem    pyam        03/03/17 - Bug 24516131: fix diagnostic
Rem    pyam        03/03/17 - 24516131: fix diagnostic
Rem    pyam        11/09/16 - Upgrade a PDB using statement replay
Rem    pyam        11/09/16 - Created
Rem

set time on
set timing on
set echo on

@@?/rdbms/admin/catappupgpre.sql

@@?/rdbms/admin/sqlsessstart.sql

COLUMN version NEW_VALUE version
select version from v$instance;

COLUMN startvsn NEW_VALUE startvsn
select version startvsn from registry$ where cid='CATPROC';

alter pluggable database application APP$CDB$CATALOG sync to
  '&version..partial';

column open_state new_value open_state
select decode(application_pdb, 'YES', 'upgrade', 'restricted') open_state 
  from v$pdbs 
  where con_id=sys_context('USERENV', 'CON_ID');

alter pluggable database close immediate instances=all;
alter pluggable database open &open_state;

alter pluggable database application APP$CDB$CATALOG sync;

set pagesize 0
set long 10000
set space 0
-- Check constant appid# UB4MAXVAL, UB4MAXVAL-1 and UB4MAXVAL-2, which are
-- used in the case of imported capture tables from multiple starting versions.
-- If no rows exist for UB4MAXVAL, we will only have one 'APP$CDB$CATALOG',
-- so we just check the name.
select NVL(LONGSQLTXT, SQLSTMT) || chr(10) || '/' stmt,
       decode(errormsg, null, 'Statement successful.', errormsg || chr(10)) error
  from int$dba_app_statements s, fed$statement$errors e
 where s.statement_id=e.seq#(+)
   and (((select count(*) from int$dba_app_statements
                         where app_id=4294967295)=0
                 and s.app_name='APP$CDB$CATALOG')
        or s.app_id=decode('&startvsn','12.1.0.1.0',4294967295,
                                       '12.1.0.2.0',4294967294,
                                       '12.2.0.1.0',4294967293,-1))
   and opcode<>0 and optimized is null
 order by session_id, statement_id;

set linesize 120
column app_statement format a55
column errormsg format a55
select app_statement, errormsg from dba_app_errors;

@?/rdbms/admin/sqlsessend.sql
 
