Rem
Rem $Header: rdbms/admin/catnowrr.sql /main/7 2017/08/01 14:20:24 yberezin Exp $
Rem
Rem catnowrr.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnowrr.sql - Catalog script to delete the 
Rem                     Workload Capture and Replay schema
Rem    DESCRIPTION
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnowrr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnowrr.sql
Rem SQL_PHASE: CATNOWRR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    07/12/17 - add PL/SQL clean-up
Rem    yberezin    03/15/16 - add start/end
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    yujwang     02/07/14 - check before stopping capture/replay
Rem    kmorfoni    06/15/11 - drop tables required for workload intelligence
Rem    veeve       07/13/06 - stop capture/replay first
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - added catnowrrp.sql
Rem    veeve       01/25/06 - Created

@?/rdbms/admin/sqlsessstart.sql

-- =========================================================
-- Stop Capture in progress, if any
--
declare
  cap_in_progress NUMBER := 0;
begin
  SELECT count(*)
  INTO   cap_in_progress
  FROM   wrr$_captures
  WHERE  status = 'IN PROGRESS';

  if (cap_in_progress > 0) then
    dbms_workload_capture.finish_capture;
  end if;
end;
/

-- =========================================================
-- Stop Replay in progress, if any
--
declare
  rep_in_progress NUMBER := 0;
begin
  SELECT count(*)
  INTO   rep_in_progress
  FROM   wrr$_replays
  WHERE  status in ('IN PROGRESS', 'INITIALIZED', 'PREPARE');

  if (rep_in_progress > 0) then
    dbms_workload_replay.cancel_replay;
  end if;
end;
/

-- Drop the Capture infrastructure tables
@@catnowrrc.sql

-- Drop the Replay infrastructure tables
@@catnowrrp.sql

-- Drop the common infrastructure tables
drop table WRR$_FILTERS;

-- Drop the Workload Intelligence tables
@@catnowrrwitb.sql

-- final clean-up, mainly for backports
exec dbms_management_bootstrap.cleanup_DB_Replay_objects();

@?/rdbms/admin/sqlsessend.sql
