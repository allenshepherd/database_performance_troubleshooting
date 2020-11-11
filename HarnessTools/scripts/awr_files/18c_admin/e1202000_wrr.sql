Rem
Rem $Header: rdbms/admin/e1202000_wrr.sql /main/13 2017/11/16 14:50:00 josmamar Exp $
Rem
Rem e1202000_wrr.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      e1202000_wrr.sql
Rem
Rem    DESCRIPTION
Rem      Workload Capture and Replay downgrade script
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    josmamar    11/13/17 - bug 26989795: long sql text support
Rem    qinwu       10/01/17 - Bug 26882594: drop [g]v$database_replay_progress
Rem    qinwu       08/05/17 - bug 26634650: changes indexes for div and thread
Rem    qinwu       08/05/17 - bug 26554266: drop col replay_deadlocks
Rem    qinwu       06/07/17 - bug 25975538: sql text and support for remapping
Rem    josmamar    05/11/17 - bug 22374149: truncate wrr$_capture_files table
Rem    qinwu       05/09/17 - proj 70152: support capture encryption
Rem    qinwu       04/18/17 - bug 25912100: fix replay thread constraint error
Rem    qinwu       01/19/17 - proj 70151: convert to invoker rights
Rem    josmamar    11/30/16 - remove the divergence summary table/view
Rem    qinwu       10/05/16 - Created

DROP PACKAGE dbms_wrr_report;
-- Divergence summary table/view
TRUNCATE TABLE      WRR$_REPLAY_DIV_SUMMARY;
DROP PUBLIC SYNONYM DBA_WORKLOAD_DIV_SUMMARY;
DROP VIEW           DBA_WORKLOAD_DIV_SUMMARY;
DROP PUBLIC SYNONYM CDB_WORKLOAD_DIV_SUMMARY;
DROP VIEW           CDB_WORKLOAD_DIV_SUMMARY;


----------------------- Begin: Project 70151 --------------------------
--  convert current dbms_workload_capture and dbms_workload_replay to 
--  invoker's rights. Move the current code to the internal packages. 
--  They need to be dropped during downgrade.
DROP PACKAGE dbms_workload_capture_i;
DROP PACKAGE dbms_workload_replay_i;
----------------------- End: Project 70151 --------------------------

----------------------- Begin: bug 25912100 ------------------------
ALTER TABLE wrr$_workload_replay_thread DROP COLUMN flags;
----------------------- End: bug 25912100 --------------------------

----------------------- Begin: Project 70152 ------------------------
ALTER TABLE wrr$_captures DROP column encryption;
ALTER TABLE wrr$_captures DROP column encryption_verifier;
----------------------- End: Project 70152 --------------------------

----------------------- Begin: Bug 22374149 --------------------------
TRUNCATE TABLE wrr$_capture_files;
----------------------- End: Bug 22374149 ----------------------------

----------------------- Begin: bug 25975538 ------------------------
TRUNCATE TABLE wrr$_capture_sql_tmp;
TRUNCATE TABLE wrr$_capture_sqltext;

DROP VIEW dba_workload_capture_sqltext;
DROP PUBLIC SYNONYM dba_workload_capture_sqltext;
----------------------- End: bug 25975538 ------------------------

----------------------- Begin: bug 26554266 ------------------------
ALTER TABLE wrr$_replay_stats DROP COLUMN replay_deadlocks;
----------------------- End: bug 26554266 ------------------------

----------------------- Begin: bug 26634650 ------------------------
DROP INDEX wrr$_replay_divergence_idx;
ALTER TABLE wrr$_replay_divergence ADD CONSTRAINT wrr$_replay_divergence_pk 
PRIMARY KEY (id, file_id, call_counter);
----------------------- End: bug 26634650 ------------------------

----------------------- Begin: bug 26882594 ------------------------
DROP PUBLIC synonym v$database_replay_progress;
DROP VIEW v_$database_replay_progress;
DROP PUBLIC synonym gv$database_replay_progress; 
DROP VIEW gv_$database_replay_progress;
----------------------- End: bug 26882594 ------------------------

----------------------- Begin: bug 26989795 ------------------------
TRUNCATE TABLE wrr$_capture_long_sqltext;

DROP VIEW dba_workload_long_sqltext;
DROP PUBLIC SYNONYM dba_workload_long_sqltext;
----------------------- End: bug 26989795 ------------------------

COMMIT;
