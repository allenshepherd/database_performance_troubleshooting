Rem
Rem $Header: rdbms/admin/catuppst.sql /main/60 2017/08/03 17:44:03 wesmith Exp $
Rem
Rem catuppst.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catuppst.sql - CATalog UPgrade PoST-upgrade actions
Rem
Rem    DESCRIPTION
Rem      This post-upgrade script performs remaining upgrade actions that
Rem      do not require that the database be open in UPGRADE mode.
Rem      Automatically apply the latest PSU.
Rem
Rem    NOTES
Rem      You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catuppst.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catuppst.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     08/07/17 - bug 22187143: fix dba_part/subpart_key_columns_v$
Rem    cmlim       05/01/17 - bug 25248712 - Move the copy for bug 19651064
Rem                           from catuppst.sql to a1201000.sql
Rem    cmlim       04/08/17 - bug 25248712: cut down on # of parallel slaves
Rem                           spawned
Rem    frealvar    03/10/17 - move the gather_fixed_objects_stats code for Bug
Rem                           14258301 as a preupgrade check
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    stanaya     12/08/16 - Bug-25191487 : adding sql metadata
Rem    pyam        11/10/16 - 70732: add catalog app upgrade for post-shutdown 
Rem    anighosh    09/15/16 - Bug 24669189: Cleanup utlmmig replacement tables
Rem    vperiwal    07/07/16 - 23726702: remove ORA-65173
Rem    cmlim       06/06/16 - bug 23215791: add more DBUA_TIMESTAMPS during db
Rem                           upgrades
Rem    anupkk      04/03/16 - Bug 22917286: Moved call to olstrig.sql to
Rem                           olsdbmig.sql
Rem    raeburns    02/29/16 - Bug 22820096: revert ALTER TYPE to default
Rem                           CASCADE
Rem    rmorant     02/11/16 - Bug22340563 add parallel hint
Rem    atomar      02/04/16 - move aq action to release specific script
Rem    raeburns    12/09/15 - Bug 22175911: add SERVEROUTPUT OFF after
Rem                           catuptabdata.sql
Rem    rmorant     11/27/15 - bug22271668 add append hint
Rem    welin       11/11/15 - Bug 21099929: 12.2 cleanup
Rem    nneeluru    09/14/15 - Add Java name translation for longer identifiers
Rem    raeburns    08/24/15 - use catuptabdata.sql instead of inline code
Rem    raeburns    06/05/15 - Bug 21322727: upgrade Oracle-maintained table data
Rem    rmorant     05/19/15 - Bug19651064 added upgrade actions
Rem    amadan      05/08/15 - Bug 21027329 remove AQ upgrade dequeue log
Rem    rpang       04/28/15 - Bug 20723336: remove network ACL check
Rem    jaeblee     03/09/15 - lrg 14235955: ignore ORA-65173 on revoke from
Rem                           cdb_keepsizes
Rem    ssubrama    02/12/15 - bug 20494207 sharded q flag during upgrade
Rem    maba        01/28/15 - fix bug 20184738
Rem    cderosa     07/03/14 - Gather table stats on logminer dictionary tables
Rem                           to initialize incremental mode.
Rem    wesmith     05/23/14 - Project 47511: data-bound collation: move fix
Rem                           for bug 17526621 from c1201000.sql
Rem    surman      05/19/14 - 17277459: Remove call to catbundle
Rem    jerrede     01/17/14 - Fix Bug 18071399 Add Post Upgrade Report Time
Rem    surman      05/31/13 - 16790144: Use @@
Rem    cmlim       05/15/13 - bug 16816410: add table name to errorlogging
Rem                           syntax
Rem    surman      03/19/13 - 16094163: Add catbundleapply.sql
Rem    cmlim       03/01/13 - bug 16306200: remove the workaround (added in
Rem                           txn in bug 16085743) that re-updated
Rem                           oracle-supplied bit in views owned by SYS after
Rem                           bootstrap.  Workaround not needed once the shared
Rem                           pool is flushed in catuposb.sql (bug 16306200).
Rem    jerrede     01/14/13 - XbranchMerge jerrede_bug-16097914 from
Rem                           st_rdbms_12.1.0.1
Rem    jerrede     01/11/13 - Move Removal of EXF/RUL to upgrade. 
Rem                           LogMiner/Standyby can not deal with removing
Rem                           a component outside of upgrade. 
Rem    sjanardh    01/10/13 - XbranchMerge maba_bug-14615619 from main
Rem    jerrede     12/19/12 - Bug#16025279 Add Event for Not Removing EXF/RUL
Rem                           Upgrade Components
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    maba        11/26/12 - fixed bug 14615619
Rem    jerrede     11/05/12 - Add Exadata Bundle support
Rem    cmlim       10/27/12 - bug 14258301 : gather fixed obj stats if none of
Rem                           the fixed object tables have had stats collected
Rem    mfallen     09/20/12 - bug 14390165: check if AWR data needs update
Rem    jerrede     10/23/12 - Unset _ORACLE_SCRIPT
Rem    jerrede     10/23/12 - Add Session Info
Rem    maba        09/13/12 - added create dequeue log for bug 14278722
Rem    jerrede     06/26/12 - Set event to optionally update required stats
Rem                           during upgrade
Rem    rpang       05/21/12 - Add network ACL migration status check
Rem    traney      05/09/12 - lrg 6949943: mask ORA-942s
Rem    jerrede     04/17/12 - Moved Mandatory Changes to catrequired.sql
Rem    traney      04/04/12 - lrg 6762280: drop DBMS_DDL_INTERNAL_LIB
Rem    traney      03/12/12 - bug 13719175: move post-utlmmig stats here
Rem    cdilling    12/13/11 - drop SYSMAN schema - removal of EM component for
Rem                           upgrade to 12.1
Rem    aramappa    06/22/11 - Always run olstrig.sql when OLS installed in DB
Rem    xbarr       04/28/11 - move DMSYS removal code to odmu112.sql
Rem    xbarr       10/25/10 - run dmsysrem.sql to drop DMSYS schema if exists  
Rem    cdilling    07/21/10 - add call to catbundle.sql for bug 9925339
Rem    srtata      12/16/08 - run olstrig.sql when upgrading from prior to 10.2 
Rem    srtata      10/15/08 - put back olstrig.sql as we found it cannot be run
Rem                           as part of upgrade
Rem    srtata      02/26/08 - move olstrig.sql to olsdbmig.sql
Rem    ushaft      02/05/07 - post upgrade for ADDM tasks.
Rem    cdilling    12/06/06 - add support for error logging
Rem    rburns      11/10/06 - post upgrade actions
Rem    rburns      11/10/06 - Created
Rem
Rem =====================================================================
Rem Call Common session settings
Rem =====================================================================
@@catpses.sql

Rem =====================================================================
Rem Begin Catalog App Upgrade for Post-shutdown. All additional code
Rem       should be placed after this.
Rem =====================================================================
@@catappupgbeg2.sql

Rem *********************************************************************
Rem BEGIN catuppst.sql
Rem *********************************************************************
Rem Set identifier to POSTUP for errorlogging

SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'POSTUP';

-- DBUA_TIMESTAMP: db shutdown/startup is finished by now
SELECT dbms_registry_sys.time_stamp('DBRESTART') as timestamp from dual;

-- DBUA_TIMESTAMP: catuppst.sql begins
SELECT dbms_registry_sys.time_stamp_display('CATUPPST') AS timestamp FROM DUAL;


SELECT dbms_registry_sys.time_stamp('POSTUP_BGN') as timestamp from dual;


Rem =======================================================================
Rem  Run Post Upgrade Operations
Rem =======================================================================

@@catrequired.sql

--
-- These were created in utlmmig.sql but could not be dropped until now.
-- Suppress "does not exist" errors.
--
set serveroutput on;
begin
  sys.dbms_output.put_line('catuppst: Dropping library DBMS_DDL_INTERNAL_LIB');
  execute immediate 'drop library DBMS_DDL_INTERNAL_LIB';
exception
  when others then
  if sqlcode = -4043 then
      null;
  end if;
end;
/

begin
  sys.dbms_output.put_line('catuppst: Dropping view _CURRENT_EDITION_OBJ_MIG');
  execute immediate 'drop view "_CURRENT_EDITION_OBJ_MIG"';
exception
  when others then
    if sqlcode = -942 then
      null;
    end if;
end;
/

begin
  sys.dbms_output.put_line('catuppst: Dropping view _ACTUAL_EDITION_OBJ_MIG');
  execute immediate 'drop view "_ACTUAL_EDITION_OBJ_MIG"';
exception
  when others then
    if sqlcode = -942 then
      null;
    end if;
end;
/

begin
  sys.dbms_output.put_line(
    'catuppst: Dropping view DBA_PART_KEY_COLUMNS_V$_MIG');
  execute immediate 'drop view "DBA_PART_KEY_COLUMNS_V$_MIG"';
exception
  when others then
    if sqlcode = -942 then
      null;
    end if;
end;
/

begin
  sys.dbms_output.put_line(
    'catuppst: Dropping view DBA_SUBPART_KEY_COLUMNS_V$_MIG');
  execute immediate 'drop view "DBA_SUBPART_KEY_COLUMNS_V$_MIG"';
exception
  when others then
    if sqlcode = -942 then
      null;
    end if;
end;
/

--
-- [24669189] : These replacement tables for the bootstrap tables
-- were created during utlmmig --> utlmmigtbls phase. Drop them here.
--
declare

 type mig_table_type is table of dbms_id;
 mig_table_list  CONSTANT mig_table_type :=
                 mig_table_type('OBJ$MIG',        'USER$MIG',
                                'COL$MIG',        'CLU$MIG',
                                'CON$MIG',        'BOOTSTRAP$MIG',
                                'TAB$MIG',        'TS$MIG',
                                'IND$MIG',        'ICOL$MIG',
                                'LOB$MIG',        'COLTYPE$MIG',
                                'SUBCOLTYPE$MIG', 'NTAB$MIG',
                                'REFCON$MIG',     'OPQTYPE$MIG',
                                'ICOLDEP$MIG',    'VIEWTRCOL$MIG',
                                'ATTRCOL$MIG',    'TYPE_MISC$MIG',
                                'LIBRARY$MIG',    'ASSEMBLY$MIG',
                                'TSQ$MIG',        'FET$MIG');

 table_not_found       EXCEPTION;
 PRAGMA exception_init(table_not_found, -942);
  
begin

  -- Loop through the array, creating the drop stmt
  -- for each entry and execute it.

  for i in mig_table_list.FIRST..mig_table_list.LAST loop
    sys.dbms_output.put_line('catuppst: Dropping table ' || mig_table_list(i));

    begin
      execute immediate 'drop table ' || mig_table_list(i) ;
    exception
      when table_not_found then
        null;
    end;

  end loop;
end;
/

Rem *************************************************************************
Rem Bug 17526621 revoke select_catalog_role
Rem *************************************************************************
begin
  execute immediate 'revoke select on cdb_keepsizes from select_catalog_role';
exception when others then
  if sqlcode in (-1927, -942) then null;
  else raise;
  end if;
end;
/


set serveroutput off

Rem =======================================================================
Rem Gather Fixed Objects Stats end
Rem =======================================================================

Rem =======================================================================
Rem Gather stats on Logminer Dictionary tables to initialize incremental
Rem stats mode
Rem =======================================================================

@@execlmnrstats.sql

Rem =======================================================================
Rem Logminer End
Rem =======================================================================

Rem =======================================================================
Rem Upgrade types in Oracle-Maintained tables if any have not already
Rem been upgraded to the latest versions of evolved types.
Rem =======================================================================

@@catuptabdata.sql
SET SERVEROUTPUT OFF

Rem =======================================================================
Rem Component Postupgrade action for 12.2
Rem =======================================================================

Rem =======================================================================
Rem If EM in the database, run @emremove.sql to remove EM schema
Rem This is only needed for upgrading database from 11.2 and prior
Rem =======================================================================

COLUMN :em_name NEW_VALUE em_file NOPRINT;
VARIABLE em_name VARCHAR2(30)
DECLARE
BEGIN
   IF dbms_registry.is_loaded('EM') IS NOT NULL THEN
      :em_name := '@emremove.sql';   -- EM exists in DB
   ELSE
      :em_name := dbms_registry.nothing_script;   -- No EM
   END IF;
END;
/
SELECT :em_name FROM DUAL;
@&em_file

Rem =======================================================================
Rem EM End
Rem =======================================================================


Rem =======================================================================
Rem Do Java longer identifiers name translation, if necessary
Rem =======================================================================

declare
  ret varchar2(20);
begin
  ret := dbms_java_test.funcall('-lid_translate_all', ' ');
exception
  when others then
    null;
end;
/

Rem =======================================================================
Rem Java longer identifiers name translation End
Rem =======================================================================

Rem =======================================================================
Rem Signal 'end' of catuppst.sql before catbundle.sql is executed
Rem =======================================================================
SELECT dbms_registry_sys.time_stamp('POSTUP_END') as timestamp from dual;

-- DBUA_TIMESTAMP: catuppst.sql finished
SELECT dbms_registry_sys.time_stamp('CATUPPST') as timestamp from dual;

Rem Set errorlogging off
SET ERRORLOGGING OFF;

Rem
Rem Set _ORACLE_SCRIPT to false
Rem
ALTER SESSION SET "_ORACLE_SCRIPT"=false;

Rem *********************************************************************
Rem END catuppst.sql
Rem *********************************************************************

