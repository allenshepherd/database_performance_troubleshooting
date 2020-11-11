Rem
Rem $Header: rdbms/admin/catwrrvwp.sql /main/46 2017/09/20 11:11:04 qinwu Exp $
Rem
Rem catwrrvwp.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrvwp.sql - Catalog script for
Rem                      the Workload Replay views 
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary views for the
Rem      Workload Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrvwp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrvwp.sql
Rem SQL_PHASE: CATWRRVWP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrvw.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qinwu       08/05/17 - bug 26554266: add col replay_deadlocks
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    qinwu       04/18/17 - bug 25912100: modify dba_workload_replay_thread
Rem    josmamar    12/20/16 - remove the truncate of module/action
Rem                           in X$MODACT_LENGTH
Rem    josmamar    11/30/16 - add DBA_WORKLOAD_DIV_SUMMARY, 
Rem    qinwu       06/06/16 - bug 22986237: add DBA_WORKLOAD_SQL_MAP
Rem    qinwu       03/14/16 - bug 22881453: select cols for cdb view
Rem    qinwu       12/15/15 - bug 18779084: locate right table/view in CDB
Rem    qinwu       11/10/15 - bug 21911443: connect_time_auto_correct
Rem    josmamar    11/03/15 - bug 21874643: support query-only replay for non
Rem                           consolidated replay
Rem    quotran     09/16/15 - bug 20827740: fix views for workload partitioning
Rem    quotran     08/28/15 - bug 21647479: add views to track commit timing
Rem    quotran     04/07/15 - bug 20827740: add view about group assigments
Rem    qinwu       02/25/15 - bug 20602681: add stats for PL/SQL subcalls
Rem    yberezin    01/30/15 - bug 20381239: long IDs
Rem    qinwu       11/20/14 - proj 47326: ADD columns for PL/SQL subcalls
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    qinwu       09/12/13 - add column divergence_load_status
Rem    talliu      06/28/13 - add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lgalanis    12/21/11 - add the user map
Rem    yujwang     09/27/11 - add schedule_cap_id to view
Rem                           dba_workload_connection_map
Rem    kmorfoni    05/09/11 - DBA_WORKLOAD_REPLAY_DIVERGENCE.capture_stream_id
Rem    yujwang     01/05/11 - workload consolidation
Rem    sburanaw    12/22/10 - add is_data_masked to
Rem                           dba_workload_replay_divergence
Rem    sburanaw    01/09/10 - add filter_set to dba_workload_replays
Rem    arbalakr    11/13/09 - truncate module/action to the maximum lengths
Rem                           in X$MODACT_LENGTH
Rem    lgalanis    04/01/09 - support for SQL tuning set capture during
Rem                           workload capture or replay
Rem    rcolle      02/12/09 - only show DB Replays in views
Rem    rcolle      01/09/09 - add error message in divergence view
Rem    rcolle      12/04/08 - add dba_workload_replay_filter_set
Rem    yujwang     10/03/08 - add scale_up_multiplier to dba_workload_replays
Rem    rcolle      10/01/08 - change synchronization column in
Rem                           dba_workload_replays
Rem    rcolle      09/03/08 - add pause_time to dba_workload_replays
Rem    sburanaw    06/02/08 - add replay_dir_number to dba_workload_replays
Rem    veeve       06/12/07 - remove new/mutated error stats
Rem    veeve       02/14/07 - add awr_ cols to dba_workload_replays
Rem    lgalanis    09/14/06 - add replay id to dba_workload_connection_map view
Rem    yujwang     09/07/06 - add columns for divergence type to
Rem                           dba_workload_replay_divergence
Rem    veeve       09/05/06 - add capture_id
Rem    yujwang     08/05/06 - add replay stats to dba_workload_replays
Rem    veeve       07/25/06 - added dbid, dbname
Rem    veeve       06/14/06 - add DBA_WORKOAD_REPLAY_DIVERGENCE
Rem    lgalanis    06/07/06 - public synonyms for dba views 
Rem    lgalanis    06/05/06 - connection information view 
Rem    veeve       04/11/06 - add REPLAY dict
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem =========================================================
Rem Creating the Workload Replay Views
Rem =========================================================
Rem

create or replace view DBA_WORKLOAD_REPLAYS
(ID, NAME, 
 DBID, DBNAME, DBVERSION,
 PARALLEL,
 DIRECTORY,
 CAPTURE_ID,
 STATUS,
 PREPARE_TIME, START_TIME, END_TIME, 
 DURATION_SECS,
 NUM_CLIENTS,
 NUM_CLIENTS_DONE,
 FILTER_SET_NAME,
 DEFAULT_ACTION,
 SYNCHRONIZATION, 
 CONNECT_TIME_SCALE,
 THINK_TIME_SCALE,
 THINK_TIME_AUTO_CORRECT,
 SCALE_UP_MULTIPLIER,
 USER_CALLS, DBTIME, NETWORK_TIME, THINK_TIME, PAUSE_TIME,
 PLSQL_CALLS,
 PLSQL_SUBCALLS,
 PLSQL_DBTIME,
 ELAPSED_TIME_DIFF,
 REPLAY_DEADLOCKS,
 AWR_DBID, AWR_BEGIN_SNAP, AWR_END_SNAP,
 AWR_EXPORTED,
 ERROR_CODE, ERROR_MESSAGE,
 DIR_PATH,
 REPLAY_DIR_NUMBER,
 SQLSET_OWNER,
 SQLSET_NAME,
 SCHEDULE_NAME,
 DIVERGENCE_LOAD_STATUS,
 PLSQL_MODE, 
 CONNECT_TIME_AUTO_CORRECT,
 RAC_MODE,
 QUERY_ONLY)
as
select 
 r.id, r.name
 , r.dbid, r.dbname, r.dbversion
 , (case when rs.parallel > 0 then 'YES' else 'NO' end)
 , r.directory
 , r.capture_id
 , r.status
 , r.prepare_time, r.start_time, r.end_time
 , round((r.end_time - r.start_time) * 86400)
 , r.num_clients
 , r.num_clients_done
 , r.filter_set_name
 , r.default_action
 , decode(r.synchronization, 1, 'SCN', 2, 'OBJECT_ID', 'FALSE')
 , r.connect_time_scale
 , r.think_time_scale
 , decode(r.think_time_auto_correct, 1, 'TRUE', 'FALSE')
 , r.scale_up_multiplier
 , rs.user_calls, rs.dbtime, rs.network_time, rs.think_time, rs.time_paused
 , rs.plsql_calls
 , rs.plsql_subcalls
 , rs.plsql_dbtime
 , (rs.time_gain - rs.time_loss)
 , rs.replay_deadlocks
 , r.awr_dbid, r.awr_begin_snap, r.awr_end_snap
 , decode(r.awr_exported, 1, 'YES', 0, 'NO', 'NOT POSSIBLE')
 , r.error_code, r.error_msg
 , r.dir_path
 , r.replay_dir_number
 , r.sqlset_owner
 , r.sqlset_name
 , r.schedule_name
 , r.divergence_load_status
 , decode(nvl(r.plsql_mode, 0), 0, 'TOP_LEVEL', 1, 'EXTENDED', 2, 'EXTENDED_SYS', 'INVALID')
 , decode(r.connect_time_auto_correct, 1, 'YES', 0, 'NO', 'NOT POSSIBLE')
 , decode(r.rac_mode, 0, 'GLOBAL_SYNC', 1, 'PER_INSTANCE_CLIENT', 2, 'PER_INSTANCE_SYNC','INVALID')
 , decode(bitand(r.flags, 1), 0, 'N','Y') as QUERY_ONLY
from
 wrr$_replays r
 , (select id,
           sum(decode(parallel,'YES',1,0)) as parallel,
           sum(user_calls) as user_calls,
           sum(dbtime) as dbtime,
           sum(network_time) as network_time,
           sum(think_time) as think_time,
           sum(time_gain) as time_gain,
           sum(time_loss) as time_loss,
           sum(time_paused) as time_paused,
           sum(plsql_calls) as plsql_calls,
           sum(plsql_subcalls) as plsql_subcalls,
           sum(plsql_dbtime) as plsql_dbtime,
           sum(replay_deadlocks) AS replay_deadlocks
    from   wrr$_replay_stats
    group by id) rs
where r.id = rs.id(+)
and   nvl(r.replay_type, 'DB') = 'DB'
/

create or replace public synonym dba_workload_replays
   for sys.dba_workload_replays;
grant select on dba_workload_replays to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAYS','CDB_WORKLOAD_REPLAYS');
grant select on SYS.CDB_WORKLOAD_REPLAYS to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_REPLAYS for SYS.CDB_WORKLOAD_REPLAYS
/

Rem
Rem Workload replay divergence summary information
Rem
create or replace view DBA_WORKLOAD_DIV_SUMMARY
(REPLAY_ID,
 DIVERGENCE_TYPE,
 IS_QUERY_DATA_DIVERGENCE,
 IS_DML_DATA_DIVERGENCE,
 IS_ERROR_DIVERGENCE,
 IS_THREAD_FAILURE,
 IS_DATA_MASKED,
 STREAM_ID,
 SQL_ID,
 EXPECTED_ERROR#,
 EXPECTED_ERROR_MESSAGE,
 OBSERVED_ERROR#,
 OBSERVED_ERROR_MESSAGE,
 SERVICE,
 MODULE,
 OCCURRENCES)
as
select
 replay_id
 , type
 , decode(bitand(type, 1), 0, 'N','Y') as IS_QUERY_DATA_DIVERGENCE
 , decode(bitand(type, 2), 0, 'N','Y') as IS_DML_DATA_DIVERGENCE
 , decode(bitand(type, 4), 0, 'N','Y') as IS_ERROR_DIVERGENCE
 , decode(bitand(type,16), 0, 'N','Y') as IS_THREAD_FAILURE
 , decode(bitand(type,64), 0, 'N','Y') as IS_DATA_MASKED
 , file_id
 , sql_id
 , exp_error
 , decode(exp_error, 0, NULL, dbms_advisor.format_message(exp_error))
 , obs_error
 , decode(obs_error, 0, NULL, dbms_advisor.format_message(obs_error))
 , service
 , module
 , sum(occurrences)
 from  WRR$_REPLAY_DIV_SUMMARY
 group by replay_id, type, file_id, sql_id, exp_error, obs_error, service, module
/ 

create or replace public synonym dba_workload_div_summary
   for sys.dba_workload_div_summary;
grant select on dba_workload_div_summary to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_DIV_SUMMARY','CDB_WORKLOAD_DIV_SUMMARY');
grant select on SYS.CDB_WORKLOAD_DIV_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_DIV_SUMMARY for SYS.CDB_WORKLOAD_DIV_SUMMARY
/


Rem
Rem Workload replay divergence information
Rem
create or replace view DBA_WORKLOAD_REPLAY_DIVERGENCE
(REPLAY_ID,
 TIMESTAMP,
 DIVERGENCE_TYPE,
 IS_QUERY_DATA_DIVERGENCE,
 IS_DML_DATA_DIVERGENCE,
 IS_ERROR_DIVERGENCE,
 IS_THREAD_FAILURE,
 IS_DATA_MASKED,
 EXPECTED_ROW_COUNT,
 OBSERVED_ROW_COUNT,
 EXPECTED_ERROR#,
 EXPECTED_ERROR_MESSAGE,
 OBSERVED_ERROR#,
 OBSERVED_ERROR_MESSAGE,
 STREAM_ID,
 CALL_COUNTER,
 CAPTURE_STREAM_ID,
 SQL_ID,
 SESSION_ID,
 SESSION_SERIAL#,
 SERVICE,
 MODULE,
 ACTION)
as
select 
 id
 , time
 , type
 , decode(bitand(type, 1), 0, 'N','Y') as IS_QUERY_DATA_DIVERGENCE
 , decode(bitand(type, 2), 0, 'N','Y') as IS_DML_DATA_DIVERGENCE
 , decode(bitand(type, 4), 0, 'N','Y') as IS_ERROR_DIVERGENCE
 , decode(bitand(type,16), 0, 'N','Y') as IS_THREAD_FAILURE
 , decode(bitand(type,64), 0, 'N','Y') as IS_DATA_MASKED
 , exp_num_rows
 , obs_num_rows
 , exp_error
 , decode(exp_error, 0, NULL, dbms_advisor.format_message(exp_error))
 , obs_error
 , decode(obs_error, 0, NULL, dbms_advisor.format_message(obs_error))
 , file_id
 , call_counter
 , cap_file_id
 , sql_id
 , session_id
 , session_serial#
 , service
 , module
 , action
 from  WRR$_REPLAY_DIVERGENCE
/ 

create or replace public synonym dba_workload_replay_divergence
   for sys.dba_workload_replay_divergence;
grant select on dba_workload_replay_divergence to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_DIVERGENCE','CDB_WORKLOAD_REPLAY_DIVERGENCE');
grant select on SYS.CDB_WORKLOAD_REPLAY_DIVERGENCE to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_REPLAY_DIVERGENCE for SYS.CDB_WORKLOAD_REPLAY_DIVERGENCE
/


Rem
Rem connection mapping information
Rem
create or replace view DBA_WORKLOAD_CONNECTION_MAP
(replay_id,
 conn_id, 
 schedule_cap_id,
 capture_conn, 
 replay_conn)
as
 select replay_id, conn_id, schedule_cap_id, capture_conn, replay_conn
 from WRR$_CONNECTION_MAP
/ 

create or replace public synonym dba_workload_connection_map
   for sys.dba_workload_connection_map;
grant select on dba_workload_connection_map to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_CONNECTION_MAP','CDB_WORKLOAD_CONNECTION_MAP');
grant select on SYS.CDB_WORKLOAD_CONNECTION_MAP to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_CONNECTION_MAP for SYS.CDB_WORKLOAD_CONNECTION_MAP
/

Rem
Rem user mapping information
Rem
create or replace view DBA_WORKLOAD_USER_MAP
(replay_id,
 schedule_cap_id,
 capture_user, 
 replay_user)
as
 select replay_id, schedule_cap_id, capture_user, replay_user
 from WRR$_USER_MAP
/ 


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_USER_MAP','CDB_WORKLOAD_USER_MAP');
grant select on SYS.CDB_WORKLOAD_USER_MAP to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_USER_MAP for SYS.CDB_WORKLOAD_USER_MAP
/

Rem
Rem active user mappings to take effect for the current or next replay
Rem
create or replace view DBA_WORKLOAD_ACTIVE_USER_MAP
(schedule_cap_id,
 capture_user,
 replay_user)
as 
  select schedule_cap_id, capture_user, replay_user
  from WRR$_USER_MAP m, WRR$_REPLAYS r
  where m.replay_id = r.id and 
        (r.status = 'INITIALIZED' 
         or r.status = 'IN PROGRESS'
         or r.status = 'PREPARE')
/

create or replace public synonym dba_workload_user_map
   for sys.dba_workload_user_map;
grant select on dba_workload_user_map to select_catalog_role;

create or replace public synonym dba_workload_active_user_map
   for sys.dba_workload_active_user_map;
grant select on dba_workload_active_user_map to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_ACTIVE_USER_MAP','CDB_WORKLOAD_ACTIVE_USER_MAP');
grant select on SYS.CDB_WORKLOAD_ACTIVE_USER_MAP to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_ACTIVE_USER_MAP for SYS.CDB_WORKLOAD_ACTIVE_USER_MAP
/

Rem
Rem replay filter sets
Rem
create or replace view DBA_WORKLOAD_REPLAY_FILTER_SET
(capture_id,
 set_name,
 filter_name,
 attribute, 
 value)
as
 select capture_id, set_name, filter_name, attribute, value
 from WRR$_REPLAY_FILTER_SET
/ 

create or replace public synonym dba_workload_replay_filter_set
   for sys.dba_workload_replay_filter_set;
grant select on dba_workload_replay_filter_set to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_FILTER_SET','CDB_WORKLOAD_REPLAY_FILTER_SET');
grant select on SYS.CDB_WORKLOAD_REPLAY_FILTER_SET to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_REPLAY_FILTER_SET for SYS.CDB_WORKLOAD_REPLAY_FILTER_SET
/

Rem
Rem Replay schedules
Rem
create or replace view DBA_WORKLOAD_REPLAY_SCHEDULES
(schedule_name,
 directory,
 status)
as 
 select schedule_name, directory, status
 from   WRR$_REPLAY_SCHEDULES;
/

create or replace public synonym dba_workload_replay_schedules
   for sys.dba_workload_replay_schedules;
grant select on dba_workload_replay_schedules to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_SCHEDULES','CDB_WORKLOAD_REPLAY_SCHEDULES');
grant select on SYS.CDB_WORKLOAD_REPLAY_SCHEDULES to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_REPLAY_SCHEDULES for SYS.CDB_WORKLOAD_REPLAY_SCHEDULES
/

---
--- create view DBA_WORKLOAD_SCHEDULE_CAPTURES
--- 
create or replace view DBA_WORKLOAD_SCHEDULE_CAPTURES
( schedule_name                                      /* replay schedule name */
 ,schedule_cap_id             /* schedule capture ID returned by add_capture */
 ,capture_id                        /* capture ID from dba_workload_captures */
 ,capture_dir                                    /* capture directory object */
 ,os_subdir                           /* OS subdirectory name of the capture */
 ,max_concurrent_sessions   /* max concurrent sessions computed by calibrate */
 ,num_clients_assigned        /* number of wrc assigned before replay starts */
 ,num_clients                                 /* number of wrc during replay */
 ,num_clients_done                /* number of wrc that are done with replay */
 ,stop_replay               /* 'Y' to stop the whole replay, 'N' to continue */
 ,take_begin_snapshot
              /* 'Y': take a snapshot when the replay of this capture starts */
 ,take_end_snapshot 
            /* 'Y': take a snapshot when the replay of this capture finishes */
 ,query_only          /* 'Y': replay the read-only queries from this capture */
 ,start_delay_secs    /* wait time in seconds when capture is ready to start */
 ,start_time                    /* start time for the replay of this capture */
 ,end_time                      /* finish time of the replay of this capture */
 ,awr_dbid                                        /* AWR DB ID of the replay */
 ,awr_begin_snap                   /* AWR snapshot ID when the replay starts */
 ,awr_end_snap                   /* AWR snapshot ID when the replay finishes */
)
as 
 select schedule_name, schedule_cap_id, capture_id, 
        capture_dir, os_subdir, max_concurrent_sessions, 
        num_clients_assigned, num_clients,
        num_clients_done, stop_replay, take_begin_snapshot,
        take_end_snapshot, query_only, start_delay_secs,
        start_time,end_time,awr_dbid,awr_begin_snap,awr_end_snap        
 from   WRR$_SCHEDULE_CAPTURES
/

create or replace public synonym dba_workload_schedule_captures
   for sys.dba_workload_schedule_captures;
grant select on dba_workload_schedule_captures to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_SCHEDULE_CAPTURES','CDB_WORKLOAD_SCHEDULE_CAPTURES');
grant select on SYS.CDB_WORKLOAD_SCHEDULE_CAPTURES to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_SCHEDULE_CAPTURES for SYS.CDB_WORKLOAD_SCHEDULE_CAPTURES
/

create or replace view DBA_WORKLOAD_SCHEDULE_ORDERING
( schedule_name
 ,schedule_cap_id
 ,waitfor_cap_id
)
as 
 select schedule_name, schedule_cap_id, waitfor_cap_id
 from   WRR$_SCHEDULE_ORDERING
/

create or replace public synonym dba_workload_schedule_ordering
   for sys.dba_workload_schedule_ordering;
grant select on dba_workload_schedule_ordering 
   to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_SCHEDULE_ORDERING','CDB_WORKLOAD_SCHEDULE_ORDERING');
grant select on SYS.CDB_WORKLOAD_SCHEDULE_ORDERING to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_SCHEDULE_ORDERING for SYS.CDB_WORKLOAD_SCHEDULE_ORDERING
/

Rem
Rem View about group assignments
Rem
create or replace view DBA_WORKLOAD_GROUP_ASSIGNMENTS
( replay_dir_number,
  group_id,
  instance_number )
as
 select replay_dir_number, gid as group_id, inst_id as instance_number
   from WRR$_REPLAY_GROUP_ASSIGNMENTS
/ 

create or replace public synonym dba_workload_group_assignments
   for sys.dba_workload_group_assignments;
grant select on dba_workload_group_assignments to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_GROUP_ASSIGNMENTS','CDB_WORKLOAD_GROUP_ASSIGNMENTS');
grant select on SYS.CDB_WORKLOAD_GROUP_ASSIGNMENTS to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_GROUP_ASSIGNMENTS for SYS.CDB_WORKLOAD_GROUP_ASSIGNMENTS
/

Rem
Rem View about replay clients
Rem
create or replace view DBA_WORKLOAD_REPLAY_CLIENTS
( wrc_id
 ,schedule_cap_id
 ,instance_number )
as
 select wrc_id, schedule_cap_id, inst_id as instance_number
   from WRR$_REPLAY_CLIENTS
/
 
create or replace public synonym dba_workload_replay_clients
   for sys.dba_workload_replay_clients;
grant select on dba_workload_replay_clients to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_CLIENTS','CDB_WORKLOAD_REPLAY_CLIENTS');
grant select on SYS.CDB_WORKLOAD_REPLAY_CLIENTS to select_catalog_role
/
create or replace public synonym CDB_WORKLOAD_REPLAY_CLIENTS for SYS.CDB_WORKLOAD_REPLAY_CLIENTS
/

Rem
Rem View about commits tracked every second during replay
Rem
create or replace view DBA_WORKLOAD_TRACKED_COMMITS
( replay_dir_number
 ,instance_number
 ,file_id
 ,call_ctr
 ,commit_scn
 ,prev_global_commit_file_id
 ,prev_global_commit_scn
 ,prev_local_commit_call_ctr
 ,capture_commit_time
 ,capture_commit_time_delta 
 ,replay_commit_time
 ,replay_commit_time_delta )
as
 select replay_dir_number, instance_number
        ,file_id, call_ctr, commit_scn
        ,prev_global_commit_file_id, prev_global_commit_scn
        ,prev_local_commit_call_ctr
        ,cap_commit_time as capture_commit_time
        ,cap_commit_time_delta as capture_commit_time_delta
        ,rep_commit_time as replay_commit_time 
        ,rep_commit_time_delta as replay_commit_time_delta
   from WRR$_REPLAY_TRACKED_COMMITS
/ 

create or replace public synonym dba_workload_tracked_commits
   for sys.dba_workload_tracked_commits;
grant select on dba_workload_tracked_commits to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_TRACKED_COMMITS','CDB_WORKLOAD_TRACKED_COMMITS');
grant select on SYS.cdb_workload_tracked_commits to select_catalog_role
/
create or replace public synonym cdb_workload_tracked_commits for SYS.cdb_workload_tracked_commits
/

Rem
Rem View about session history for every replay
Rem
create or replace view DBA_WORKLOAD_REPLAY_THREAD
( replay_dir_number
 ,inst_id
 ,sid
 ,serial#
 ,spid
 ,logon_user
 ,logon_time
 ,file_id
 ,call_counter
 ,session_type
 ,wrc_id
 ,schedule_cap_id
 ,file_name
 ,dbtime
 ,network_time
 ,think_time
 ,user_calls
 ,plsql_calls
 ,plsql_subcalls
 ,plsql_dbtime
 ,capture_elapsed_time
 ,replay_elapsed_time
 ,is_scale_up_sess)
AS
  SELECT replay_dir_number, inst_id, sid, serial#, spid, 
         logon_user, logon_time, file_id, call_counter, 
         session_type, wrc_id, schedule_cap_id, file_name, 
         dbtime, network_time, think_time, 
         user_calls, plsql_calls, plsql_subcalls, plsql_dbtime, 
         capture_elapsed_time, replay_elapsed_time,
         decode(bitand(flags, 1), 0, 'N', 'Y')
  FROM WRR$_WORKLOAD_REPLAY_THREAD
/ 

create or replace public synonym dba_workload_replay_thread
   for sys.dba_workload_replay_thread;
grant select on dba_workload_replay_thread to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_THREAD','CDB_WORKLOAD_REPLAY_THREAD');
grant select on SYS.cdb_workload_replay_thread to select_catalog_role
/
create or replace public synonym cdb_workload_replay_thread for SYS.cdb_workload_replay_thread
/

Rem
Rem View about sql remapping
Rem
create or replace view dba_workload_sql_map
( replay_id
 ,schedule_cap_id
 ,sql_id 
 ,operation
 ,sql_id_number
 ,replacement_sql_text)
AS
  SELECT replay_id, schedule_cap_id, sql_id,
         decode(operation, 0, 'SKIP', 1, 'REPLACE', 'INVALID') operation,
         sql_id_number, replacement_sql_text
  FROM wrr$_replay_sql_map
/
  
create or replace public synonym dba_workload_sql_map
   for sys.dba_workload_sql_map;
grant select on dba_workload_sql_map to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_SQL_MAP','CDB_WORKLOAD_SQL_MAP');
grant select on SYS.cdb_workload_sql_map to select_catalog_role
/
create or replace public synonym cdb_workload_sql_map for SYS.cdb_workload_sql_map
/


Rem %%%%%%%%%%%%%%%%%%%%%%%%%
Rem Create sharing view
Rem %%%%%%%%%%%%%%%%%%%%%%%%%
CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_COMMITS sharing=object
(schedule_cap_id, file_id, call_ctr, db_seq, valid)
AS
SELECT schedule_cap_id, file_id, call_ctr, db_seq, valid
FROM WRR$_REPLAY_COMMITS
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_DATA sharing=object
(schedule_cap_id, file_id, call_ctr, rank, data_type, value)
AS
SELECT schedule_cap_id, file_id, call_ctr, rank, data_type, value
FROM WRR$_REPLAY_DATA
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_DEP_GRAPH sharing=object
(schedule_cap_id, file_id, call_ctr, file_id_dep, call_ctr_dep, sync_point)
AS
SELECT schedule_cap_id, file_id, call_ctr, file_id_dep, call_ctr_dep, sync_point
FROM WRR$_REPLAY_DEP_GRAPH
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_FILES sharing=object
(cap_file_id, schedule_cap_id, rep_file_id, gid, num_calls, db_time, inst_id, status)
AS
SELECT cap_file_id, schedule_cap_id, rep_file_id, gid, num_calls, db_time, inst_id, status
FROM WRR$_REPLAY_FILES
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_REFERENCES sharing=object
(schedule_cap_id, file_id, refs)
AS
SELECT schedule_cap_id, file_id, refs
FROM WRR$_REPLAY_REFERENCES
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_SCN_ORDER sharing=object
(call_id, call_time, post_commit_scn, stream_id, module, action, ecid, ecid_hash, valid, schedule_cap_id)
AS
SELECT call_id, call_time, post_commit_scn, stream_id, module, action, ecid, ecid_hash, valid, schedule_cap_id
FROM WRR$_REPLAY_SCN_ORDER
/

CREATE OR REPLACE VIEW WRR_ROOT_REPLAY_SEQ_DATA sharing=object
(schedule_cap_id, file_id, call_ctr, rank, seq_name, seq_bnm, seq_bow, first_value, last_value, change, num_values)
AS 
SELECT schedule_cap_id, file_id, call_ctr, rank, seq_name, seq_bnm, seq_bow, first_value, last_value, change, num_values
FROM WRR$_REPLAY_SEQ_DATA
/

@?/rdbms/admin/sqlsessend.sql
