Rem
Rem $Header: rdbms/admin/catwrrvwc.sql /main/21 2017/11/16 14:50:00 josmamar Exp $
Rem
Rem catwrrvwc.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrvwc.sql - Catalog script for
Rem                      the Workload Capture views 
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary views for the
Rem      Workload Capture infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrvwc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrvwc.sql
Rem SQL_PHASE: CATWRRVWC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrvw.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    josmamar    11/13/17 - bug 26989795: add view for long sql text
Rem    qinwu       09/06/17 - bug 18488916: sql with sess/pdb switch container
Rem    qinwu       07/02/17 - bug 25975538: add view for sql text
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    qinwu       03/20/17 - proj 70152: add columns for capture encryption
Rem    yberezin    03/27/15 - bug 20787546
Rem    qinwu       02/25/15 - bug 20602681: add stats for PL/SQL subcalls
Rem    yberezin    01/30/15 - bug 20381239: long IDs
Rem    qinwu       11/20/14 - proj 47326: ADD columns for PL/SQL subcalls
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sburanaw    01/11/10 - add info from wrr$_replay_filter_set to
Rem                           dba_workload_filters, dba_workload_filter_set
Rem    lgalanis    04/01/09 - support for SQL tuning set capture during
Rem                           workload capture or replay
Rem    veeve       04/12/06 - made FILTERS.STATUS [NEW|IN USE|USED]
Rem    veeve       12/18/06 - add dbversion, parallel, _total s 
Rem                           to dba_workload_captures
Rem    yujwang     08/08/06 - remove unsupported_calls
Rem    veeve       08/03/06 - added dbid, dbname, last_prep_version
Rem    veeve       07/13/06 - added capture_size
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       01/25/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem =========================================================
Rem Creating the Common Infrastructure Views
Rem =========================================================
Rem

create or replace view dba_workload_filters
(TYPE,
 ID,
 STATUS,
 SET_NAME, NAME, ATTRIBUTE, VALUE)
as
select
 f.filter_type,
 to_number( decode(f.wrr_id, 0, NULL, f.wrr_id) ),
 (case when c.status = 'IN PROGRESS'
       then 'IN USE'
       when f.wrr_id = 0
       then 'NEW'
       else 'USED'
  end) as status,
 NULL, f.name, f.attribute, f.value
from
 wrr$_filters  f,
 wrr$_captures c
where f.wrr_id = c.id(+)
  and f.filter_type = 'CAPTURE'
UNION ALL
select
 f.filter_type,
 to_number( decode(f.wrr_id, 0, NULL, f.wrr_id) ),
 (case when r.status = 'IN PROGRESS'
         or r.status = 'INITIALIZED'
         or r.status = 'PREPARE'
       then 'IN USE'
       when f.wrr_id = 0
       then 'NEW'
       else 'USED'
  end) as status,
 r.filter_set_name, f.name, f.attribute, f.value
from
 wrr$_filters f,
 wrr$_replays r
where f.filter_type = 'REPLAY'
  and f.wrr_id = r.id(+)
UNION ALL
select
 'REPLAY' as filter_type,
 to_number(NULL) as wrr_id,
 'IN SET' as status,
 set_name, filter_name, attribute, value
from wrr$_replay_filter_set rfs
where NOT EXISTS
  (SELECT 1
   FROM   WRR$_REPLAYS r
   WHERE  r.filter_set_name = rfs.set_name
   AND    r.capture_id = rfs.capture_id)
/


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_FILTERS','CDB_WORKLOAD_FILTERS');
grant select on SYS.CDB_workload_filters to select_catalog_role
/
create or replace public synonym CDB_workload_filters for SYS.CDB_workload_filters
/

create or replace view dba_workload_replay_filter_set
(CAPTURE_ID,
 SET_NAME,
 FILTER_NAME, ATTRIBUTE, VALUE,
 DEFAULT_ACTION)
as
select capture_id, set_name, filter_name, attribute, value, default_action
from wrr$_replay_filter_set rfs
UNION ALL
select NULL, NULL, name, attribute, value, NULL
from wrr$_filters
where wrr_id = 0
and   filter_type = 'REPLAY'
/

create or replace public synonym dba_workload_filters
   for sys.dba_workload_filters;
grant select on dba_workload_filters to select_catalog_role;


execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_REPLAY_FILTER_SET','CDB_WORKLOAD_REPLAY_FILTER_SET');
grant select on SYS.CDB_workload_replay_filter_set to select_catalog_role
/
create or replace public synonym CDB_workload_replay_filter_set for SYS.CDB_workload_replay_filter_set
/

Rem =========================================================
Rem Creating the Workload Capture Views
Rem =========================================================
Rem

create or replace view dba_workload_captures
(ID, NAME, 
 DBID, DBNAME, DBVERSION,
 PARALLEL,
 DIRECTORY,
 STATUS,
 START_TIME, END_TIME, 
 DURATION_SECS,
 START_SCN, END_SCN,
 DEFAULT_ACTION, FILTERS_USED,
 CAPTURE_SIZE, 
 DBTIME, DBTIME_TOTAL,
 USER_CALLS, USER_CALLS_TOTAL, USER_CALLS_UNREPLAYABLE,
 PLSQL_SUBCALL_SIZE,
 PLSQL_CALLS,
 PLSQL_SUBCALLS,
 PLSQL_DBTIME,
 TRANSACTIONS, TRANSACTIONS_TOTAL,
 CONNECTS, CONNECTS_TOTAL,
 ERRORS, 
 AWR_DBID, AWR_BEGIN_SNAP, AWR_END_SNAP, 
 AWR_EXPORTED,
 ERROR_CODE, ERROR_MESSAGE,
 DIR_PATH,
 DIR_PATH_SHARED,
 LAST_PROCESSED_VERSION,
 SQLSET_OWNER,
 SQLSET_NAME,
 PLSQL_MODE,
 ENCRYPTION)
as
select 
 r.id, r.name
 , r.dbid, r.dbname, r.dbversion
 , (case when rs.parallel > 0 then 'YES' else 'NO' end)
 , r.directory
 , r.status
 , r.start_time, r.end_time
 , round((r.end_time - r.start_time) * 86400)
 , r.start_scn, r.end_scn
 , r.default_action, nvl(f.cnt,0)
 , rs.capture_size
 , rs.dbtime, greatest(rs.dbtime_total, rs.dbtime)
 , rs.user_calls, greatest(rs.user_calls_total, rs.user_calls)
 , rs.user_calls_empty
 , rs.plsql_subcall_size
 , rs.plsql_calls
 , rs.plsql_subcalls
 , rs.plsql_dbtime
 , rs.txns, greatest(rs.txns_total, rs.txns)
 , rs.connects, greatest(rs.connects_total, rs.connects)
 , rs.errors
 , r.awr_dbid, r.awr_begin_snap, r.awr_end_snap
 , decode(r.awr_exported, 1, 'YES', 0, 'NO', 'NOT POSSIBLE')
 , r.error_code, r.error_msg
 , r.dir_path
 , r.dir_path_shared
 , r.last_prep_version
 , r.sqlset_owner
 , r.sqlset_name
 , decode(nvl(r.plsql_mode, 0), 0, 'TOP_LEVEL', 1, 'EXTENDED', 2, 'EXTENDED_SYS', 'INVALID')
 , r.encryption
from
 wrr$_captures r
 , (select wrr_id, count(*) as cnt
    from   wrr$_filters
    where  filter_type = 'CAPTURE'
    group  by wrr_id) f
 , (select id, 
           sum(decode(parallel,'YES',1,0)) as parallel,
           sum(capture_size) as capture_size,
           sum(dbtime) as dbtime,
           sum(dbtime_tend - dbtime_tstart) as dbtime_total,
           sum(user_calls) as user_calls, 
           sum(user_calls_tend - user_calls_tstart) as user_calls_total,
           sum(user_calls_empty) as user_calls_empty, 
           sum(nvl(plsql_subcall_size, 0)) as plsql_subcall_size,
           sum(nvl(plsql_calls,0)) as plsql_calls,  
           sum(nvl(plsql_subcalls, 0)) as plsql_subcalls,
           sum(nvl(plsql_dbtime, 0)) as plsql_dbtime, 
           sum(txns) as txns, 
           sum(txns_tend - txns_tstart) as txns_total,
           sum(connects) as connects, 
           sum(connects_tend - connects_tstart) as connects_total, 
           sum(errors) as errors
    from   wrr$_capture_stats
    group by id) rs
where r.id = f.wrr_id(+)
  and r.id = rs.id(+)
/

create or replace public synonym  dba_workload_captures
   for sys.dba_workload_captures;
grant select on dba_workload_captures to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_WORKLOAD_CAPTURES','CDB_WORKLOAD_CAPTURES');
grant select on SYS.CDB_workload_captures to select_catalog_role
/
create or replace public synonym CDB_workload_captures for SYS.CDB_workload_captures
/

create or replace view dba_workload_capture_sqltext
( capture_id
, sql_id
, sql_type
, sql_text
, sql_length
, sql_text_complete
)
AS
SELECT cs.capture_id
, cs.sql_id
, oct.oct_name
, cs.sql_text
, cs.sql_length
, (case when cs.sql_length > 1000 then 'N' else 'Y' end) AS sql_text_complete
FROM wrr$_capture_sqltext cs left join x$oct oct ON cs.oct_type = oct.oct_type;

create or replace public synonym  dba_workload_capture_sqltext
for sys.dba_workload_capture_sqltext;
grant select on dba_workload_capture_sqltext to select_catalog_role;

create or replace view dba_workload_long_sqltext
( capture_id
, sql_id
, sql_fulltext
)
AS
SELECT cls.capture_id
, cls.sql_id
, cls.sql_fulltext
FROM wrr$_capture_long_sqltext cls;

create or replace public synonym  dba_workload_long_sqltext
for sys.dba_workload_long_sqltext;
grant select on dba_workload_long_sqltext to select_catalog_role;

@?/rdbms/admin/sqlsessend.sql
