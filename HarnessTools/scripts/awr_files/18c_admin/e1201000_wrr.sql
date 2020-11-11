Rem
Rem $Header: rdbms/admin/e1201000_wrr.sql /main/6 2016/11/15 10:55:10 qinwu Exp $
Rem
Rem e1201000_wrr.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      e1201000_wrr.sql
Rem
Rem    DESCRIPTION
Rem      Workload Capture and Replay downgrade script
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    07/29/16 - bug 24371112: drop new package dbms_wrr_protected
Rem    yberezin    07/15/16 - bug 24305541
Rem    qinwu       07/06/16 - truncate wrr$_replay_sql_map table
Rem    yberezin    03/24/16 - Created

-- The modifications we do here make sure that after the downgrade, the tables
-- look like what they are in MAIN.

-- Nullify columns introduced in 12.2
UPDATE wrr$_captures SET plsql_mode = NULL;
UPDATE wrr$_capture_stats SET plsql_subcall_size = NULL,
                              plsql_calls        = NULL,
                              plsql_subcalls     = NULL,
                              plsql_dbtime       = NULL;

UPDATE wrr$_replays SET plsql_mode                = NULL,
                        connect_time_auto_correct = NULL,
                        rac_mode                  = NULL,
                        flags                     = NULL;

UPDATE wrr$_replay_stats SET plsql_calls    = NULL,
                             plsql_subcalls = NULL,
                             plsql_dbtime   = NULL;

drop package as_replay;
drop package dbms_wrr_state;
drop package dbms_wrr_protected;

-- Bug 20204603: truncate tables for fixing scn order
-- (See catwrrtbp.sql for more details about these tables)

truncate table WRR$_COMMIT_FIRST_CALL_SCN;
truncate table WRR$_REPLAY_COMMIT_REMAPPING;
truncate table WRR$_REPLAY_CALL_INFO;

-- Bug 20204603: truncate/update tables/views for RAC per-instance sync
-- (See catwrrtbp.sql for more details about these tables)

truncate table WRR$_WORKLOAD_GROUPS;
truncate table WRR$_REPLAY_LOGIN_QUEUE;
truncate table WRR$_CAPTURE_FILE_DETAILS;
truncate table WRR$_REPLAY_FILES;
truncate table WRR$_REPLAY_INSTANCES;
truncate table WRR$_REPLAY_GROUP_ASSIGNMENTS;
truncate table WRR$_WORKLOAD_SESSIONS;
truncate table WRR$_WORKLOAD_EX_OBJECTS;
truncate table WRR$_REPLAY_CLIENTS;

drop view       SYS.DBA_WORKLOAD_GROUP_ASSIGNMENTS;
drop public synonym DBA_WORKLOAD_GROUP_ASSIGNMENTS;
drop view       SYS.CDB_WORKLOAD_GROUP_ASSIGNMENTS;
drop public synonym CDB_WORKLOAD_GROUP_ASSIGNMENTS;

drop view       SYS.DBA_WORKLOAD_REPLAY_CLIENTS;
drop public synonym DBA_WORKLOAD_REPLAY_CLIENTS;
drop view       SYS.CDB_WORKLOAD_REPLAY_CLIENTS;
drop public synonym CDB_WORKLOAD_REPLAY_CLIENTS;

-- Support for always-on capture
truncate table WRR$_CAPTURE_BUCKETS;
update WRR$_CAPTURES set capture_type = NULL;

-- Bug 21647479: track commits per second
truncate table       WRR$_REPLAY_TRACKED_COMMITS;
drop public synonym DBA_WORKLOAD_TRACKED_COMMITS;
drop view       SYS.DBA_WORKLOAD_TRACKED_COMMITS;
drop public synonym CDB_WORKLOAD_TRACKED_COMMITS;
drop view       SYS.CDB_WORKLOAD_TRACKED_COMMITS;

-- handle replay workload thread
truncate table       WRR$_WORKLOAD_REPLAY_THREAD;
drop public synonym DBA_WORKLOAD_REPLAY_THREAD;
drop view       SYS.DBA_WORKLOAD_REPLAY_THREAD;
drop public synonym CDB_WORKLOAD_REPLAY_THREAD;
drop view       SYS.CDB_WORKLOAD_REPLAY_THREAD;

-- handle replay sql skip or remap
truncate table       WRR$_REPLAY_SQL_MAP;
drop public synonym DBA_WORKLOAD_SQL_MAP;
drop view       SYS.DBA_WORKLOAD_SQL_MAP;
drop public synonym CDB_WORKLOAD_SQL_MAP;
drop view       SYS.CDB_WORKLOAD_SQL_MAP;

-- Track replay overhead
truncate table WRR$_COMPONENT_TIMING;

-- drop views with sharing=object clause
drop view WRR_ROOT_REPLAY_COMMITS;
drop view WRR_ROOT_REPLAY_DATA;
drop view WRR_ROOT_REPLAY_DEP_GRAPH;
drop view WRR_ROOT_REPLAY_FILES;
drop view WRR_ROOT_REPLAY_REFERENCES;
drop view WRR_ROOT_REPLAY_SCN_ORDER;
drop view WRR_ROOT_REPLAY_SEQ_DATA;

-- BEGIN bug 20867498: long ids

UPDATE wrr$_masking_definition SET
  owner_name  = substr(owner_name, 1,30),
  table_name  = substr(table_name, 1,30),
  column_name = substr(column_name,1,30)
WHERE length(owner_name)  > 30
   OR length(table_name)  > 30
   OR length(column_name) > 30;
COMMIT;
ALTER TABLE wrr$_masking_definition MODIFY owner_name  VARCHAR2(30);
ALTER TABLE wrr$_masking_definition MODIFY table_name  VARCHAR2(30);
ALTER TABLE wrr$_masking_definition MODIFY column_name VARCHAR2(30);

-- END bug 20867498: long ids

-- BEGIN bug 21787780

ALTER TABLE wrr$_captures
  MODIFY dbversion VARCHAR2(128)
  MODIFY error_msg VARCHAR2(300)
;
ALTER TABLE wrr$_replays
  MODIFY dbversion       VARCHAR2( 128)
  MODIFY error_msg       VARCHAR2( 300)
  MODIFY filter_set_name VARCHAR2(1000)
  MODIFY schedule_name   VARCHAR2( 100)
;
-- END bug 21787780

-- BEGIN bug 22713655
begin
  -- wrr$_replay_scn_order: extra columns in MAIN:
  --   schedule_cap_id
  --   call_elapsed
  --   call_type
  -- column schedule_cap_id is part of the PK in MAIN
  -- the table has to be re-created
  execute immediate 'drop table wrr$_replay_scn_order purge';
end;
/
-- END bug 22713655

-- Bug 24745792
ALTER TABLE wrr$_replay_call_filter DROP CONSTRAINT wrr$_replay_call_filter_pk;
