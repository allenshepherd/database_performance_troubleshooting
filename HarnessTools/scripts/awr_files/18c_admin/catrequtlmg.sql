Rem
Rem $Header: rdbms/admin/catrequtlmg.sql /main/6 2017/04/27 17:09:44 raeburns Exp $
Rem
Rem catrequtlmg.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrequtlmg.sql - Catalog Mandatory Upgrade Script
Rem
Rem    DESCRIPTION
Rem      This catalog script can run from utlmmig.sql or catuppst.sql.
Rem      The event _utlmmig_table_stats_gathering determines where it
Rem      is run.  If TRUE (the default) it is run from utlmmig.sql, if
Rem      FALSE it will be run from catuppst.sql. This script gathers
Rem      statistics on migration stats that are recreated after an
Rem      upgrade occurs.
Rem
Rem    NOTES
Rem      You must be connected AS SYSDBA to run this script.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catrequtlmg.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catrequtlmg.sql
Rem    SQL_PHASE:  UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: catrequired.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/14/17 - Bug 25790192: Add SQL_METADATA
Rem    hvieyra     05/03/16 - Fix for bug 23223406. Remove estimate_percent
Rem                           clause.
Rem    anighosh    09/03/15 - #(21774511): create cluster index name
Rem                           based on whether operating under utlmmig
Rem                           or not.
Rem    anighosh    08/16/15 - #(21377496): Gather cluster index stats
Rem    jerrede     12/20/12 - Turn off set serveroutput
Rem    jerrede     04/17/12 - Moved from catuppst.sql
Rem                           which was written by Tom Raney.
Rem


Rem *********************************************************************
Rem BEGIN catrequtlmg.sql
Rem *********************************************************************

Rem =======================================================================
Rem Statistics gathering
Rem =======================================================================
-- DBMS_STATS now depends on DBMS_UTILITY which may have gotten invalidated
-- by some preceeding DDL statement, so package state needs to be cleared to
-- avoid ORA-04068, reset_package causes set serveroutput on to not work.

execute dbms_session.reset_package;
set serveroutput on;

declare


  c_TRACEEVENT CONSTANT VARCHAR2(30)  := '_utlmmig_table_stats_gathering';
  c_POSTUPGRADE CONSTANT VARCHAR2(19) := 'CATREQ_POST_UPGRADE';
  c_BOOTERR CONSTANT VARCHAR2(23)     := 'BOOTSTRAP_UPGRADE_ERROR';
  c_MIGTABLE CONSTANT VARCHAR2(4)     := '$MIG';
  c_POSTUPGTABLE CONSTANT VARCHAR2(1) := '$';
  s_TableName VARCHAR2(4)             := c_MIGTABLE;
  s_IndexName VARCHAR2(3)             := 'MIG';
  b_InUtlMig BOOLEAN := sys.dbms_registry_sys.select_props_data(c_BOOTERR);
  b_UpgradeMode BOOLEAN := sys.dbms_registry.is_in_upgrade_mode();
  b_StatEvt  BOOLEAN := sys.dbms_registry.is_trace_event_set(c_TRACEEVENT);
  b_SelProps BOOLEAN := sys.dbms_registry_sys.select_props_data(c_POSTUPGRADE);
  b_Props BOOLEAN := TRUE;

begin

  --
  -- Debug Info
  --
  IF (b_StatEvt) THEN
    sys.dbms_output.put_line('catrequtlmg: b_StatEvt     = TRUE');
  ELSE
    sys.dbms_output.put_line('catrequtlmg: b_StatEvt     = FALSE');
  END IF;

  IF (b_SelProps) THEN
    sys.dbms_output.put_line('catrequtlmg: b_SelProps    = TRUE');
  ELSE
    sys.dbms_output.put_line('catrequtlmg: b_SelProps    = FALSE');
  END IF;

  IF (b_UpgradeMode) THEN
    sys.dbms_output.put_line('catrequtlmg: b_UpgradeMode = TRUE');
  ELSE
    sys.dbms_output.put_line('catrequtlmg: b_UpgradeMode = FALSE');
  END IF;

  IF (b_InUtlMig) THEN
    sys.dbms_output.put_line('catrequtlmg: b_InUtlMig    = TRUE');
  ELSE
    sys.dbms_output.put_line('catrequtlmg: b_InUtlMig    = FALSE');
    s_TableName := c_POSTUPGTABLE;
    s_IndexName := '';
  END IF;

  --
  -- b_StatEvt = FALSE indicates don't collect stats
  --             in upgrade mode.
  --
  -- Don't do the migration stats in UPGRADE mode.
  -- Stats will run no matter what mode we are in
  -- if post upgrade data is found in sys.props$.
  --
  IF (b_StatEvt = FALSE AND b_SelProps = FALSE) THEN

    --
    -- In Upgrade Mode Only
    --
    IF (b_UpgradeMode) THEN

      --
      -- Set sys.props$ table indicating that it
      -- needs to be run in the post upgrade script.
      --
      b_Props := sys.dbms_registry_sys.insert_props_data(c_POSTUPGRADE,
               'Run Migration Stats',
               'Startup database in normal mode and run catuppst.sql');
      IF (b_Props) THEN
        sys.dbms_output.put_line('catrequtlmg: insert_props_data: Success');
      ELSE
        sys.dbms_output.put_line('catrequtlmg: insert_props_data: Failure');
      END IF;

    END IF;

    RETURN;

  END IF;

  --
  -- b_StatEvt = TRUE indicates collect stats
  --             in upgrade mode.
  --
  -- Don't do the migration stats in NORMAL mode.
  -- Stats will run no matter what mode we are in
  -- if post upgrade data is found in sys.props$.
  --
  IF (b_StatEvt = TRUE AND b_SelProps = FALSE AND b_UpgradeMode = FALSE) THEN

      RETURN;

  END IF;

  --
  -- Updating migration stats in post upgrade. Write an entry to
  -- sys.props$ table to indicate that stat collection has started.
  -- If this entry is present then this routine has failed.
  --
  IF (b_SelProps) THEN

    b_Props := sys.dbms_registry_sys.update_props_data(c_POSTUPGRADE,
                                         'Started Migration Stats');
    IF (b_Props) THEN
      sys.dbms_output.put_line('catrequtlmg: update_props_data: Success');
    ELSE
      sys.dbms_output.put_line('catrequtlmg: update_props_data: Failure');
    END IF;

  END IF;


  --
  -- Delete Stats
  --
  sys.dbms_output.put_line('catrequtlmg: Deleting table stats');
  sys.dbms_stats.delete_table_stats('SYS', 'OBJ' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'USER' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'COL' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'CLU' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'CON' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'TAB' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'IND' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'ICOL' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'LOB' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'COLTYPE' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'SUBCOLTYPE' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'NTAB' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'REFCON' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'OPQTYPE' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'ICOLDEP' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'TSQ' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'VIEWTRCOL' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'ATTRCOL' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'TYPE_MISC' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'LIBRARY' || s_TableName);
  sys.dbms_stats.delete_table_stats('SYS', 'ASSEMBLY' || s_TableName);

  --
  -- Gather Stats
  --
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats OBJ' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'OBJ' || s_TableName,  
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats USER' ||
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'USER' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats COL' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'COL' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats CLU' || 
                            s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'CLU' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats CON' || 
                            s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'CON' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats TAB' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'TAB' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats IND' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'IND' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats ICOL' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'ICOL' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats LOB' || 
                            s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'LOB' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats COLTYPE' ||
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'COLTYPE' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats SUBCOLTYPE' ||
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'SUBCOLTYPE' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats NTAB' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'NTAB' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats REFCON' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'REFCON' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats OPQTYPE' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'OPQTYPE' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats ICOLDEP' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'ICOLDEP' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats TSQ' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'TSQ' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats VIEWTRCOL' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'VIEWTRCOL' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats ATTRCOL' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'ATTRCOL' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats TYPE_MISC' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'TYPE_MISC' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats LIBRARY' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'LIBRARY' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  sys.dbms_output.put_line('catrequtlmg: Gathering Table Stats ASSEMBLY' || 
                           s_TableName);
  sys.dbms_stats.gather_table_stats('SYS', 'ASSEMBLY' || s_TableName, 
                                method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');


  -- [21377496]: Gather_Table_Stats does not collect stats for cluster index.
  -- Cluster index is not associated with any table, but only with a cluster.
  -- Thus we need to explicitly collected stats for this index.
  --
  -- [21774511]: Note that utlmmig may not be invoked for patch upgrades.
  -- Given that, create the index name appropriately depending on whether
  -- we are inside utlmmig or not.

  -- Delete Cluster Index Stats

  sys.dbms_output.put_line('catrequtlmg: Deleting cluster index stats');
  sys.dbms_stats.delete_index_stats('SYS', 'I_USER#' || s_IndexName);
  sys.dbms_stats.delete_index_stats('SYS', 'I_OBJ#' || s_IndexName);

  -- Gather Cluster Index Stats

  sys.dbms_output.put_line('catrequtlmg: Gathering Index Stats I_USER#' ||
                           s_IndexName);
  sys.dbms_stats.gather_index_stats('SYS', 'I_USER#' || s_IndexName);

  sys.dbms_output.put_line('catrequtlmg: Gathering Index Stats I_OBJ#'||
                           s_IndexName);
  sys.dbms_stats.gather_index_stats('SYS', 'I_OBJ#' || s_IndexName);
 
  --
  -- Delete any previous entry that may have been stored in
  -- sys.props$ table.
  -- 
  b_Props := sys.dbms_registry_sys.delete_props_data(c_POSTUPGRADE);
  IF (b_Props) THEN
    sys.dbms_output.put_line('catrequtlmg: delete_props_data: Success');
  ELSE
    sys.dbms_output.put_line('catrequtlmg: delete_props_data: No Props Data');
  END IF;

end;
/

--
-- Set serveroutput off
--
set serveroutput off;

--
-- Reset Package to be on the safe side for the
-- case where we are running in catuppst.sql
-- 
execute dbms_session.reset_package;


Rem *********************************************************************
Rem END catrequtlmg.sql
Rem *********************************************************************

