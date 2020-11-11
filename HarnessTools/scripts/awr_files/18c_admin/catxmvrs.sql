Rem
Rem $Header: rdbms/admin/catxmvrs.sql /main/3 2016/01/08 07:31:47 sramakri Exp $
Rem
Rem catxmvrs.sql
Rem
Rem Copyright (c) 2015, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxmvrs.sql -  MV refresh stats catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catxmvrs.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    12/22/15 - bug-22447265: change session_user to current_user
Rem    tfyu        12/14/15 - bug-22343972
Rem    sramakri    02/18/15 - mv refresh stats catalog views
Rem    sramakri    02/18/15 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

-- add the xmltype column for the refresh stats catalog table
alter table sys.mvref$_stmt_stats add execution_plan xmltype;


--------------------------------------
---
---  CATALOG VIEWS
---
--------------------------------------
-- cat0.sql
-- DBA_MVREF_STATS_SYSTEM_DEFAULTS (in func spec)
-- DBA_MVREF_STATS_SYS_DEFAULTS 
create or replace view dba_mvref_stats_sys_defaults
(
 parameter_name,
 value
)
as
select parameter_name, value from 
 (select 'COLLECTION_LEVEL' parameter_name, 
         decode(collection_level, 0, 'NONE', 1, 'TYPICAL', 2, 'ADVANCED', NULL) value
  from sys.mvref$_stats_sys_defaults
  union all
  select 'RETENTION_PERIOD' parameter_name, to_char(retention_period) value 
  from sys.mvref$_stats_sys_defaults)
/

-- USER_MVREF_STATS_SYS_DEFAULTS (note: same definition as DBA_MVREF_STATS_SYS_DEFAULTS)
create or replace view user_mvref_stats_sys_defaults
(
 parameter_name,
 value
)
as
select parameter_name, value
from dba_mvref_stats_sys_defaults;

grant select on SYS.dba_mvref_stats_sys_defaults to select_catalog_role;
create or replace public synonym dba_mvref_stats_sys_defaults for SYS.dba_mvref_stats_sys_defaults;
grant read on SYS.user_mvref_stats_sys_defaults to public;
create or replace public synonym user_mvref_stats_sys_defaults for SYS.user_mvref_stats_sys_defaults;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_STATS_SYS_DEFAULTS','CDB_MVREF_STATS_SYS_DEFAULTS');
grant select on SYS.CDB_MVREF_STATS_SYS_DEFAULTS to select_catalog_role
/
create or replace public synonym CDB_MVREF_STATS_SYS_DEFAULTS for SYS.CDB_MVREF_STATS_SYS_DEFAULTS
/

--------------------------------------
-- DBA_MVREF_STATS_PARAMS
create or replace view dba_mvref_stats_params
(
 mv_owner,
 mv_name,
 collection_level,
 retention_period
)
as
select
 mv_owner,
 mv_name,
 decode(collection_level, 0, 'NONE', 1, 'TYPICAL', 2, 'ADVANCED', NULL),
 retention_period
from
  (
   with defvals as
   (select collection_level, retention_period 
    from sys.mvref$_stats_sys_defaults)
    select mv_owner, mv_name, 
           nvl(e.collection_level, d.collection_level) collection_level,
           nvl(e.retention_period, d.retention_period) retention_period
    from
    (select mv_owner, mv_name, collection_level, retention_period
     from sys.mvref$_stats_params p right outer join 
     (select sowner mv_owner, vname as mv_name 
      from sys.snap$) s1
      using (mv_owner, mv_name)) e, defvals d
   )
/

-- USER_MVREF_STATS_PARAMS
create or replace view user_mvref_stats_params
(
 mv_owner,
 mv_name,
 collection_level,
 retention_period
)
as
select
 mv_owner,
 mv_name,
 collection_level,
 retention_period
from dba_mvref_stats_params
where mv_owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER');
/

grant select on SYS.dba_mvref_stats_params to select_catalog_role;
create or replace public synonym dba_mvref_stats_params for SYS.dba_mvref_stats_params;
grant read on SYS.user_mvref_stats_params to public;
create or replace public synonym user_mvref_stats_params for SYS.user_mvref_stats_params;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_STATS_PARAMS','CDB_MVREF_STATS_PARAMS');
grant select on SYS.CDB_MVREF_STATS_PARAMS to select_catalog_role
/
create or replace public synonym CDB_MVREF_STATS_PARAMS for SYS.CDB_MVREF_STATS_PARAMS
/

--------------------------------------
-- cat1.sql
-- DBA_MVREF_RUN_STATS 
create or replace view dba_mvref_run_stats
(
 run_owner,
 refresh_id,
 num_mvs,
 mviews,
 base_tables,
 method,
 rollback_seg,
 push_deferred_rpc,
 refresh_after_errors,
 purge_option,
 parallelism,
 heap_size,
 atomic_refresh,
 nested,
 out_of_place,
 number_of_failures,
 start_time,
 end_time,
 elapsed_time,
 log_setup_time,
 log_purge_time,
 complete_stats_available
) as
select
  u1.name as run_owner,
  refresh_id,
  num_mvs_total as num_mvs,
  mviews,
  base_tables,
  method,
  rollback_seg,
  push_deferred_rpc,
  refresh_after_errors,
  purge_option,
  parallelism,
  heap_size,
  atomic_refresh,
  nested,
  out_of_place,
  number_of_failures,
  decode(atomic_refresh, 'Y', start_time, NULL) start_time,
  decode(atomic_refresh, 'Y', end_time, NULL) end_time,
  decode(atomic_refresh, 'Y', elapsed_time, NULL) elapsed_time,
  decode(atomic_refresh, 'Y', log_setup_time, NULL) log_setup_time,
  decode(atomic_refresh, 'Y', log_purge_time, NULL) log_purge_time,
 complete_stats_available
from sys.mvref$_run_stats, sys.user$ u1
where run_owner_user# = u1.user#;
-- USER_MVREF_RUN_STATS 
create or replace view user_mvref_run_stats
as 
select
  refresh_id,
  num_mvs,
  mviews,
  base_tables,
  method,
  rollback_seg,
  push_deferred_rpc,
  refresh_after_errors,
  purge_option,
  parallelism,
  heap_size,
  atomic_refresh,
  nested,
  out_of_place,
  number_of_failures,
  start_time,
  end_time,
  elapsed_time,
  log_setup_time,
  log_purge_time,
  complete_stats_available
from dba_mvref_run_stats
where run_owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER');

grant select on SYS.dba_mvref_run_stats to select_catalog_role;
create or replace public synonym dba_mvref_run_stats for SYS.dba_mvref_run_stats;
grant read on SYS.user_mvref_run_stats to public;
create or replace public synonym user_mvref_run_stats for SYS.user_mvref_run_stats;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_RUN_STATS','CDB_MVREF_RUN_STATS');
grant select on SYS.CDB_MVREF_RUN_STATS to select_catalog_role
/
create or replace public synonym CDB_MVREF_RUN_STATS for SYS.CDB_MVREF_RUN_STATS
/

--------------------------------------
-- cat2.sql
-- DBA_MVREF_CHANGE_STATS 
create or replace view dba_mvref_change_stats
(
 tbl_owner,
 tbl_name,
 mv_owner,
 mv_name,
 refresh_id,
 num_rows_ins,
 num_rows_upd,
 num_rows_del,
 num_rows_dl_ins,
 pmops_occurred,
 pmop_details,
 num_rows
) as
select
  u1.name as tbl_owner,
  o1.name as tbl_name,
  u2.name as mv_owner,
  o2.name as mv_name,
  refresh_id,
  num_rows_ins,
  num_rows_upd,
  num_rows_del,
  num_rows_dl_ins,
  pmops_occurred,
  pmop_details,
  num_rows
from sys.mvref$_change_stats m1, 
     sys.obj$ o1, sys.obj$ o2, sys.user$ u1, sys.user$ u2
where o1.obj# = m1.tbl_obj# and o1.owner# = u1.user# and
      o2.obj# = m1.mv_obj# and o2.owner# = u2.user#;
-- USER_MVREF_CHANGE_STATS 
-- Note: same columns as dba_mvref_change_stats
-- The mv_owner column is retained.
create or replace view user_mvref_change_stats
(
 tbl_owner,
 tbl_name,
 mv_owner,
 mv_name,
 refresh_id,
 num_rows_ins,
 num_rows_upd,
 num_rows_del,
 num_rows_dl_ins,
 pmops_occurred,
 pmop_details,
 num_rows
) as
select
  tbl_owner,
  tbl_name,
  mv_owner,
  mv_name,
  refresh_id,
  num_rows_ins,
  num_rows_upd,
  num_rows_del,
  num_rows_dl_ins,
  pmops_occurred,
  pmop_details,
  num_rows
from dba_mvref_change_stats
where mv_owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER');

grant select on SYS.dba_mvref_change_stats to select_catalog_role;
create or replace public synonym dba_mvref_change_stats for SYS.dba_mvref_change_stats;
grant read on SYS.user_mvref_change_stats to public;
create or replace public synonym user_mvref_change_stats for SYS.user_mvref_change_stats;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_CHANGE_STATS','CDB_MVREF_CHANGE_STATS');
grant select on SYS.CDB_MVREF_CHANGE_STATS to select_catalog_role
/
create or replace public synonym CDB_MVREF_CHANGE_STATS for SYS.CDB_MVREF_CHANGE_STATS
/

--------------------------------------
-- DBA_MVREF_STMT_STATS 
create or replace view dba_mvref_stmt_stats
(
 mv_owner,
 mv_name,
 refresh_id,
 step,
 sqlid,
 stmt,
 execution_time,
 execution_plan
) as
select
  u1.name as mv_owner,
  o1.name as mv_name,
  refresh_id,
  step,
  sqlid,
  stmt,
  execution_time,
  execution_plan
from sys.mvref$_stmt_stats m1, 
     sys.obj$ o1, sys.user$ u1
where o1.obj# = m1.mv_obj# and o1.owner# = u1.user#;

-- USER_MVREF_STMT_STATS 
-- Note: same columns as dba_mvref_stmt_stats
-- The mv_owner column is retained.
create or replace view user_mvref_stmt_stats
(
 mv_owner,
 mv_name,
 refresh_id,
 step,
 sqlid,
 stmt,
 execution_time,
 execution_plan
) as
select
  mv_owner,
  mv_name,
  refresh_id,
  step,
  sqlid,
  stmt,
  execution_time,
  execution_plan
from dba_mvref_stmt_stats
where mv_owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER');

grant select on SYS.dba_mvref_stmt_stats to select_catalog_role;
create or replace public synonym dba_mvref_stmt_stats for SYS.dba_mvref_stmt_stats;
grant read on SYS.user_mvref_stmt_stats to public;
create or replace public synonym user_mvref_stmt_stats for SYS.user_mvref_stmt_stats;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_STMT_STATS','CDB_MVREF_STMT_STATS');
grant select on SYS.CDB_MVREF_STMT_STATS to select_catalog_role
/
create or replace public synonym CDB_MVREF_STMT_STATS for SYS.CDB_MVREF_STMT_STATS
/

-- cat3a.sql
-- DBA_MVREF_STATS 
create or replace view dba_mvref_stats
(
 mv_owner,
 mv_name,
 refresh_id,
 refresh_method,
 refresh_optimizations,
 additional_executions,
 start_time,
 end_time,
 elapsed_time,
 log_setup_time,
 log_purge_time,
 initial_num_rows,
 final_num_rows
) as
select
  u1.name as mv_owner,
  o1.name as mv_name,
  refresh_id,
  refresh_method,
  refresh_optimizations,
  additional_executions,
  start_time,
  end_time,
  elapsed_time,
  log_setup_time,
  log_purge_time,
  initial_num_rows,
  final_num_rows
from sys.mvref$_stats m1, 
     sys.obj$ o1, sys.user$ u1
where o1.obj# = m1.mv_obj# and o1.owner# = u1.user#;

-- USER_MVREF_STATS 
create or replace view user_mvref_stats
as 
select
  mv_name,
  refresh_id,
  refresh_method,
  refresh_optimizations,
  additional_executions,
  start_time,
  end_time,
  elapsed_time,
  log_setup_time,
  log_purge_time,
  initial_num_rows,
  final_num_rows
from dba_mvref_stats
where mv_owner = SYS_CONTEXT ('USERENV', 'CURRENT_USER');

grant select on SYS.dba_mvref_stats to select_catalog_role;
create or replace public synonym dba_mvref_stats for SYS.dba_mvref_stats;
grant read on SYS.user_mvref_stats to public;
create or replace public synonym user_mvref_stats for SYS.user_mvref_stats;

execute CDBView.create_cdbview(false,'SYS','DBA_MVREF_STATS','CDB_MVREF_STATS');
grant select on SYS.CDB_MVREF_STATS to select_catalog_role
/
create or replace public synonym CDB_MVREF_STATS for SYS.CDB_MVREF_STATS
/
--------------------------------------


@?/rdbms/admin/sqlsessend.sql
