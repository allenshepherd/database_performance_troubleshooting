Rem
Rem $Header: rdbms/admin/c1202000_wrr.sql /main/6 2017/09/05 13:33:19 qinwu Exp $
Rem
Rem c1202000_wrr.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1202000_wrr.sql
Rem
Rem    DESCRIPTION
Rem      Workload Capture and Replay upgrade script
Rem
Rem    NOTES
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qinwu       08/05/17 - bug 26634650: changes indexes for div and thread
Rem    qinwu       08/05/17 - bug 26554266: add col replay_deadlocks
Rem    qinwu       05/09/17 - proj 70152: support capture encryption
Rem    qinwu       04/18/17 - bug 25912100: fix replay thread constraint error
Rem    qinwu       10/05/16 - created

----------------------- Begin: bug 25912100 --------------------------
ALTER TABLE wrr$_workload_replay_thread ADD (flags INTEGER);

ALTER TABLE wrr$_workload_replay_thread 
DROP  CONSTRAINT wrr$_workload_replay_thread_pk;
----------------------- End: bug 25912100 ----------------------------

----------------------- Begin: Project 70152 ------------------------
ALTER TABLE wrr$_captures ADD (encryption VARCHAR2(128));
ALTER TABLE wrr$_captures ADD (encryption_verifier RAW(512));
----------------------- End: Project 70152 --------------------------

----------------------- Begin: bug 26554266 ------------------------
ALTER TABLE wrr$_replay_stats ADD (replay_deadlocks INTEGER DEFAULT 0);
----------------------- End: bug 26554266 ------------------------

----------------------- Begin: bug 26634650 ------------------------
ALTER TABLE wrr$_replay_divergence DROP CONSTRAINT wrr$_replay_divergence_pk;
DROP INDEX wrr$_wkld_replay_thread_idx;
----------------------- End: bug 26634650 ------------------------

COMMIT;
