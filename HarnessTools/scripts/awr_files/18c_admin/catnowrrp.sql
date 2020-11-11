Rem
Rem $Header: rdbms/admin/catnowrrp.sql /main/24 2017/02/10 09:39:51 yberezin Exp $
Rem
Rem catnowrrp.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnowrrp.sql - Catalog script to delete the 
Rem                      Workload Replay schema
Rem
Rem    DESCRIPTION
Rem      Undo file for all objects created in catwrrtbp.sql
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnowrrp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnowrrp.sql
Rem SQL_PHASE: CATNOWRRP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    02/02/17 - bug 25356940: drop views
Rem    josmamar    11/30/16 - drop WRR$_REPLAY_DIV_SUMMARY
Rem    qinwu       06/06/16 - bug 22986237: drop WRR$_REPLAY_SESSION_HIST
Rem    josmamar    11/26/15 - bug 21759305: track replay overhead
Rem    quotran     07/31/15 - bug 21647479: track commits per second
Rem    qinwu       06/15/15 - bug 20716953: drop WRR$_REPLAY_CALL_INFO
Rem    quotran     03/27/15 - bug 20827740: support RAC per-instance sync
Rem    surman      01/23/15 - 20386160: Add SQL metadata tags
Rem    quotran     12/04/14 - bug 20204603: drop tables for fixing scn order
Rem    hpoduri     07/18/12 - add for ash time period object type
Rem    lgalanis    12/27/11 - add user map
Rem    spapadom    11/10/11 - drop WRR$_ASREPLAY_DATA table
Rem    kmorfoni    04/12/11 - drop WRR$_FILE_ID_MAP table
Rem    yujwang     01/05/11 - drop workload consolidation tables
Rem    lgalanis    02/15/10 - workload attributes
Rem    rcolle      09/09/08 - 
Rem    rcolle      11/07/08 - drop WRR$_REPLAY_CALL_FILTER
Rem    sburanaw    03/28/08 - drop wrr$_replay_data
Rem    lgalanis    08/07/08 - drop the seqeunce exception table
Rem    rcolle      07/08/08 - drop WRR$_REPLAY_SQL_TEXT and
Rem                           WRR$_REPLAY_SQL_BINDS
Rem    rcolle      05/08/08 - drop WRR$_REPLAY_UC_GRAPH
Rem    rcolle      04/04/08 - drop tables for new synchronization (dep_graph,
Rem                           commits and references)
Rem    yujwang     08/05/06 - drop wrr$_replay_stats
Rem    veeve       07/13/06 - stop replay in catnowrr.sql
Rem    lgalanis    06/03/06 - connection information 
Rem    veeve       06/02/06 - drop replay divergence, scn order, seqdata
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - Created

Rem =========================================================
Rem Dropping the Workload Replay Tables
Rem =========================================================

delete from PROPS$ where name = 'WORKLOAD_REPLAY_MODE';
commit;

drop public synonym DBA_WORKLOAD_ACTIVE_USER_MAP;
drop public synonym DBA_WORKLOAD_CONNECTION_MAP;
drop public synonym DBA_WORKLOAD_DIV_SUMMARY;
drop public synonym DBA_WORKLOAD_GROUP_ASSIGNMENTS;
drop public synonym DBA_WORKLOAD_REPLAYS;
drop public synonym DBA_WORKLOAD_REPLAY_CLIENTS;
drop public synonym DBA_WORKLOAD_REPLAY_DIVERGENCE;
drop public synonym DBA_WORKLOAD_REPLAY_FILTER_SET;
drop public synonym DBA_WORKLOAD_REPLAY_SCHEDULES;
drop public synonym DBA_WORKLOAD_REPLAY_THREAD;
drop public synonym DBA_WORKLOAD_SCHEDULE_CAPTURES;
drop public synonym DBA_WORKLOAD_SCHEDULE_ORDERING;
drop public synonym DBA_WORKLOAD_SQL_MAP;
drop public synonym DBA_WORKLOAD_TRACKED_COMMITS;
drop public synonym DBA_WORKLOAD_USER_MAP;

drop public synonym CDB_WORKLOAD_ACTIVE_USER_MAP;
drop public synonym CDB_WORKLOAD_CONNECTION_MAP;
drop public synonym CDB_WORKLOAD_DIV_SUMMARY;
drop public synonym CDB_WORKLOAD_GROUP_ASSIGNMENTS;
drop public synonym CDB_WORKLOAD_REPLAYS;
drop public synonym CDB_WORKLOAD_REPLAY_CLIENTS;
drop public synonym CDB_WORKLOAD_REPLAY_DIVERGENCE;
drop public synonym CDB_WORKLOAD_REPLAY_FILTER_SET;
drop public synonym CDB_WORKLOAD_REPLAY_SCHEDULES;
drop public synonym CDB_WORKLOAD_REPLAY_THREAD;
drop public synonym CDB_WORKLOAD_SCHEDULE_CAPTURES;
drop public synonym CDB_WORKLOAD_SCHEDULE_ORDERING;
drop public synonym CDB_WORKLOAD_SQL_MAP;
drop public synonym CDB_WORKLOAD_TRACKED_COMMITS;
drop public synonym CDB_WORKLOAD_USER_MAP;

drop view DBA_WORKLOAD_ACTIVE_USER_MAP;
drop view DBA_WORKLOAD_CONNECTION_MAP;
drop view DBA_WORKLOAD_DIV_SUMMARY;
drop view DBA_WORKLOAD_GROUP_ASSIGNMENTS;
drop view DBA_WORKLOAD_REPLAYS;
drop view DBA_WORKLOAD_REPLAY_CLIENTS;
drop view DBA_WORKLOAD_REPLAY_DIVERGENCE;
drop view DBA_WORKLOAD_REPLAY_FILTER_SET;
drop view DBA_WORKLOAD_REPLAY_SCHEDULES;
drop view DBA_WORKLOAD_REPLAY_THREAD;
drop view DBA_WORKLOAD_SCHEDULE_CAPTURES;
drop view DBA_WORKLOAD_SCHEDULE_ORDERING;
drop view DBA_WORKLOAD_SQL_MAP;
drop view DBA_WORKLOAD_TRACKED_COMMITS;
drop view DBA_WORKLOAD_USER_MAP;

drop view CDB_WORKLOAD_ACTIVE_USER_MAP;
drop view CDB_WORKLOAD_CONNECTION_MAP;
drop view CDB_WORKLOAD_DIV_SUMMARY;
drop view CDB_WORKLOAD_GROUP_ASSIGNMENTS;
drop view CDB_WORKLOAD_REPLAYS;
drop view CDB_WORKLOAD_REPLAY_CLIENTS;
drop view CDB_WORKLOAD_REPLAY_DIVERGENCE;
drop view CDB_WORKLOAD_REPLAY_FILTER_SET;
drop view CDB_WORKLOAD_REPLAY_SCHEDULES;
drop view CDB_WORKLOAD_REPLAY_THREAD;
drop view CDB_WORKLOAD_SCHEDULE_CAPTURES;
drop view CDB_WORKLOAD_SCHEDULE_ORDERING;
drop view CDB_WORKLOAD_SQL_MAP;
drop view CDB_WORKLOAD_TRACKED_COMMITS;
drop view CDB_WORKLOAD_USER_MAP;

drop view WRR_ROOT_REPLAY_COMMITS;
drop view WRR_ROOT_REPLAY_DATA;
drop view WRR_ROOT_REPLAY_DEP_GRAPH;
drop view WRR_ROOT_REPLAY_FILES;
drop view WRR_ROOT_REPLAY_REFERENCES;
drop view WRR_ROOT_REPLAY_SCN_ORDER;
drop view WRR_ROOT_REPLAY_SEQ_DATA;

drop table WRR$_REPLAYS;
drop table WRR$_REPLAY_DIV_SUMMARY;
drop table WRR$_REPLAY_DIVERGENCE;
drop table WRR$_ASREPLAY_DATA;
drop table WRR$_REPLAY_SCN_ORDER;
drop table WRR$_COMMIT_FIRST_CALL_SCN;
drop table WRR$_REPLAY_COMMIT_REMAPPING;
drop table WRR$_REPLAY_CALL_INFO;
drop table WRR$_REPLAY_SEQ_DATA;
drop table WRR$_CONNECTION_MAP;
drop table WRR$_REPLAY_STATS;
drop table WRR$_REPLAY_UC_GRAPH;
drop table WRR$_REPLAY_SQL_TEXT;
drop table WRR$_REPLAY_SQL_BINDS;
drop table WRR$_SEQUENCE_EXCEPTIONS;
drop table WRR$_COMPONENT_TIMING;
drop table WRR$_REPLAY_DATA;
drop table WRR$_REPLAY_CALL_FILTER;
drop table WRR$_REPLAY_FILTER_SET;
drop table WRR$_REPLAY_DEP_GRAPH;
drop table WRR$_REPLAY_COMMITS;
drop table WRR$_REPLAY_REFERENCES;
drop table WRR$_WORKLOAD_ATTRIBUTES;
drop table WRR$_SCHEDULE_ORDERING;
drop table WRR$_SCHEDULE_CAPTURES;
drop table WRR$_REPLAY_SCHEDULES;
drop table WRR$_FILE_ID_MAP;
drop table WRR$_REPLAY_DIRECTORY;
drop table WRR$_USER_MAP;
drop table WRR$_CAPTURE_FILE_DETAILS;
drop table WRR$_REPLAY_LOGIN_QUEUE;
drop table WRR$_REPLAY_CONN_DATA;
drop table WRR$_REPLAY_FILES;
drop table WRR$_REPLAY_GROUP_ASSIGNMENTS;
drop table WRR$_REPLAY_INSTANCES;
drop table WRR$_WORKLOAD_GROUPS;
drop table WRR$_WORKLOAD_SESSIONS;
drop table WRR$_WORKLOAD_EX_OBJECTS;
drop table WRR$_REPLAY_CLIENTS;
drop table WRR$_REPLAY_TRACKED_COMMITS;
drop table WRR$_WORKLOAD_REPLAY_THREAD;
drop table WRR$_REPLAY_SQL_MAP;

drop sequence WRR$_REPLAY_ID;

drop type WRR$_ASH_TIME_PERIOD;
