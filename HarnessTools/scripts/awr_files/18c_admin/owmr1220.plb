update wmsys.wm$env_vars$ set value = '12.2.0.1.0' where name = 'OWM_VERSION';
commit ;
drop package wmsys.owm_dynsql_access ;
create or replace package wmsys.ltadm wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
1a3 10f
tUYjiiG1Fabbjvw3px12LkOsUdQwgw1KLZ4VZy+iO3MYYlZm4wJ55YFI0RyH38bJC0uerGOf
+SQ5RCrKVDH/uTRCWFVB1VBDn3sPPmHHUVD0A7TnLRWfaVNg5hj/gxUwE3wh7Wcp3fyf2BOU
AF7uqyzur1GwFkCeRRr3dyY0/0PEiCyEzuuiRPbQO2v/2O9qDpVGgQMAGtTNBwfpfzLv0N1M
ZfHRY2RRt9CxCQ/QYB68hzT61qSCFsZfjkRBl63bnAPa24e4WA==

/
delete wmsys.wm$env_vars$ where name = '_CONFLICT_CHECK_IDENTICAL_ID' ;
delete wmsys.wm$sysparam_all_values$ where name = '_CONFLICT_CHECK_IDENTICAL_ID' ;
commit ;
update wmsys.wm$udtrig_info$
set wm$flag = wm$flag - 67108864
where bitand(wm$flag, 67108864) = 67108864 ;
commit ;
drop index wmsys.wm$constraints_table_tab_pk ;
create unique index wmsys.wm$constraints_table_tab_pk on wmsys.wm$constraints_table$(vtid#, constraint_name, bitand(wm$flag,8)) ;
alter table wmsys.wm$constraints_table$ drop column owner ;
drop index wmsys.wm$ws_tab_ws_ind ;
create index wmsys.wm$ws_tab_ws_ind on wmsys.wm$workspaces_table$(workspace) ;
update wmsys.wm$workspaces_table$
set workspace = mp_root,
    mp_root = depth
where bitand(wm$flag, 14) = 12 ;
commit ;
drop index wmsys.wm$mw_tab_ws_idx ;
create index wmsys.wm$mw_tab_ws_idx on wmsys.wm$mw_table$(workspace#) ;
drop index wmsys.wm$ric_locking_ind ;
drop public synonym all_wm_constraint_violations ;
drop view wmsys.all_wm_constraint_violations ;
create or replace view wmsys.wm$workspaces_table$d as
select wt1.workspace,
       wt1.current_version,
       wt1.parent_version,
       wt1.post_version,
       null verlist,
       wt1.owner,
       wt1.createtime,
       wt1.description,
       wt1.workspace_lock_id,
       decode(bitand(wt1.wm$flag, 1), 0, 'UNLOCKED', 1, 'LOCKED') freeze_status,
       decode(bitand(wt1.wm$flag, 14), 0, null, 2, '1WRITER', 4, '1WRITER_SESSION', 6, 'NO_ACCESS', 8, 'READ_ONLY', 10, 'WM_ONLY', 12, 'REMOVED', 14, 'DEFERRED_REMOVAL') freeze_mode,
       wt1.freeze_writer,
       null oper_status,
       decode(bitand(wt1.wm$flag, 112), 0, null, 16, 'S', 32, 'E', 48, 'WE', 64, 'VE', 80, 'C', 96, 'D') ||
         decode(bitand(wt1.wm$flag, 496),  0, null, ',') ||
         decode(bitand(wt1.wm$flag, 384), 0, null, 128, 'Y', 256, 'N') wm_lockmode,
       decode(bitand(wt1.wm$flag, 512), 0, 0, 1) isRefreshed,
       wt1.freeze_owner,
       decode(bitand(wt1.wm$flag, 1024), 0, 0, 1) session_duration,
       (select nvl(max(to_number(substr(st.savepoint, 5))), 0)
        from wmsys.wm$workspace_savepoints_table$ st
        where st.workspace# = wt1.workspace_lock_id and st.savepoint like 'ICP-%') implicit_sp_cnt,
       decode(bitand(wt1.wm$flag, 6144), 0, 'CRS_ALLCR', 2048, 'CRS_ALLNONCR', 4096, 'CRS_LEAF', 6144, 'CRS_MIXED') cr_status,
       wt1.sync_parver,
       wt1.last_change,
       wt1.depth,
       wt1.mp_root,
       decode(bitand(wt1.wm$flag, 8192), 0, 0, 8192, 1) keep,
       wt2.workspace_lock_id parent_workspace#,
       wt2.workspace parent_workspace,
       wt2.current_version parent_current_version
from wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where wt1.parent_workspace# = wt2.workspace_lock_id(+) ;
create or replace view wmsys.wm$workspaces_table as
select *
from wmsys.wm$workspaces_table$d
where freeze_mode is null or freeze_mode not in ('REMOVED', 'DEFERRED_REMOVAL') ;
create or replace view wmsys.wm$constraints_table as
select vt.owner,
       ct.constraint_name,
       decode(bitand(ct.wm$flag, 7), 0, 'P', 1, 'PN', 2, 'PU', 3, 'U', 4, 'UI', 5, 'UN', 6, 'UU', 7, 'C') constraint_type,
       vt.table_name,
       ct.search_condition,
       decode(bitand(ct.wm$flag, 8), 0, 'DISABLED', 8, 'ENABLED') status,
       ct.index_owner,
       ct.index_name,
       decode(bitand(ct.wm$flag, 112), 0, null, 16, 'NORMAL', 32, 'BITMAP', 48, 'FUNCTION-BASED NORMAL',
                                       64, 'FUNCTION-BASED NORMAL DESC', 80, 'FUNCTION-BASED BITMAP', 96, 'DOMAIN') index_type,
       ct.aliasedcolumns,
       ct.numindexcols
from wmsys.wm$constraints_table$ ct, wmsys.wm$versioned_tables$ vt
where ct.vtid# = vt.vtid# ;
create or replace view wmsys.wm$removed_workspaces_table as
select wt1.owner,
       wt1.workspace workspace_name,
       wt1.workspace_lock_id workspace_id,
       wt1.parent_workspace parent_workspace_name,
       wt1.parent_workspace# parent_workspace_id,
       wt1.createtime,
       wt1.last_change retiretime,
       wt1.description,
       to_number(wt1.mp_root) mp_root_id,
       wt1.isrefreshed
from wmsys.wm$workspaces_table$d wt1
where wt1.freeze_mode = 'REMOVED' or
      (wt1.freeze_mode = 'DEFERRED_REMOVAL' and keep=1) ;
create or replace view wmsys.wm$modified_tables as
select mt.vtid# vtid, vt.owner || '.' || vt.table_name table_name, mt.version, wt.workspace
from wmsys.wm$modified_tables$ mt, wmsys.wm$versioned_tables$ vt, wmsys.wm$workspaces_table$i wt
where mt.vtid# = vt.vtid# and
      mt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$udtrig_info as
select ui.trig_owner_name,
       ui.trig_name,
       vt.owner table_owner_name,
       vt.table_name,
       decode(bitand(ui.wm$flag, 1), 0, 0, 1, 1) +
       decode(bitand(ui.wm$flag, 2), 0, 0, 2, 2) +
       decode(bitand(ui.wm$flag, 4), 0, 0, 4, 4) +
       decode(bitand(ui.wm$flag, 8), 0, 0, 8, 8) +
       decode(bitand(ui.wm$flag, 16), 0, 0, 16, 16) +
       decode(bitand(ui.wm$flag, 32), 0, 0, 32, 32) +
       decode(bitand(ui.wm$flag, 64), 0, 0, 64, 64) +
       decode(bitand(ui.wm$flag, 128), 0, 0, 128, 128) +
       decode(bitand(ui.wm$flag, 256), 0, 0, 256, 256) +
       decode(bitand(ui.wm$flag, 512), 0, 0, 512, 512) +
       decode(bitand(ui.wm$flag, 1024), 0, 0, 1024, 1024) +
       decode(bitand(ui.wm$flag, 2048), 0, 0, 2048, 2048) +
       decode(bitand(ui.wm$flag, 4096), 0, 0, 4096, 4096) trig_flag,
       decode(bitand(ui.wm$flag, 8192), 0, 'DISABLED', 8192, 'ENABLED') status,
       decode(proc#, null, null,
              decode(bitand(ui.wm$flag, 16384), 0, ui.trig_owner_name || '.WM$PROC_UDT_' || proc#, 16384, 'WMSYS.WM$PROC_RIC_' || proc#)) trig_procedure,
       ui.when_clause,
       ui.description,
       ui.trig_code,
       decode(bitand(ui.wm$flag, 16384), 0, 'USER_DEFINED', 16384, 'RIC_CHECK') internal_type,
       decode(bitand(ui.wm$flag, 32768), 0, 0, 32768, 32768) +
       decode(bitand(ui.wm$flag, 65536), 0, 0, 65536, 65536) +
       decode(bitand(ui.wm$flag, 131072), 0, 0, 131072, 131072) +
       decode(bitand(ui.wm$flag, 262144), 0, 0, 262144, 262144) +
       decode(bitand(ui.wm$flag, 524288), 0, 0, 524288, 524288) +
       decode(bitand(ui.wm$flag, 1048576), 0, 0, 1048576, 1048576) +
       decode(bitand(ui.wm$flag, 2097152), 0, 0, 2097152, 2097152) +
       decode(bitand(ui.wm$flag, 4194304), 0, 0, 4194304, 4194304) +
       decode(bitand(ui.wm$flag, 8388608), 0, 0, 8388608, 8388608) +
       decode(bitand(ui.wm$flag, 16777216), 0, 0, 16777216, 16777216) +
       decode(bitand(ui.wm$flag, 33554432), 0, 0, 33554432, 33554432) event_flag
from wmsys.wm$udtrig_info$ ui, wmsys.wm$versioned_tables$ vt
where ui.vtid# = vt.vtid# ;
create or replace view wmsys.wm$all_locks_view as
select vt.owner, vt.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKMODE'),
              'E', 'EXCLUSIVE', 'S', 'SHARED', 'VE', 'VERSION EXCLUSIVE', 'WE', 'WORKSPACE EXCLUSIVE') lock_mode,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKUSER') lock_owner,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKSTATE') locking_state
from wmsys.wm$versioned_tables vt,
     table(wmsys.ltadm.get_lock_table(vt.owner, vt.table_name)) t
with READ ONLY ;
create or replace view wmsys.wm$workspace_sessions_view as
  select st.username, wt.workspace, st.sid, st.serial#, st.saddr, st.inst_id, decode(dl.lmode, 2, 'SS', 4, 'S', 'U') lockMode, 0 isImplicit
  from gv$lock dl, wmsys.wm$workspaces_table$i wt, gv$session st
  where dl.type = 'UL' and
        dl.id1 - 1 = wt.workspace_lock_id and
        dl.sid = st.sid and
        dl.inst_id = st.inst_id
 union all
  select st.username, cast(wmsys.ltadm.GetSystemParameter('DEFAULT_WORKSPACE') as varchar2(128)), st.sid, st.serial#, st.saddr, st.inst_id, 'S', 1
  from gv$session st
  where st.username is not null and
        not exists(select 1
                   from gv$lock dl, wmsys.wm$workspaces_table$i wt
                   where dl.type = 'UL' and
                         dl.lmode = 4 and
                         dl.id1 - 1 = wt.workspace_lock_id and
                         dl.sid = st.sid and
                         dl.inst_id = st.inst_id)
WITH READ ONLY ;
create or replace view wmsys.all_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name, t.owner,
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name, t.vtid) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name, t.vtid) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_views av
 where t.table_name = av.view_name and t.owner = av.owner
union all
 select /*+ LEADING(t) */ t.table_name, t.owner,
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name, t.vtid) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name, t.vtid) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_tables at
 where t.table_name = at.table_name and t.owner = at.owner
WITH READ ONLY ;
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name, t.vtid) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name, t.vtid) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t, dba_views u
where t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY ;
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name, t.vtid) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name, t.vtid) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t
where t.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.wm_compress_batch_sizes as
select /*+ RULE */ vt.owner, vt.table_name,
       (case dt.data_type
        when 'CHAR'      then (case when nvl(dt.num_buckets, 0) in (0,1) then 'TABLE' else 'TABLE/PRIMARY_KEY_RANGE' end)
        when 'VARCHAR2'  then (case when nvl(dt.num_buckets, 0) in (0,1) then 'TABLE' else 'TABLE/PRIMARY_KEY_RANGE' end)
        when 'NUMBER'    then (case when nvl(dt.num_buckets, 0) in (0)   then 'TABLE' else 'TABLE/PRIMARY_KEY_RANGE' end)
        when 'DATE'      then (case when nvl(dt.num_buckets, 0) in (0)   then 'TABLE' else 'TABLE/PRIMARY_KEY_RANGE' end)
        when 'TIMESTAMP' then (case when nvl(dt.num_buckets, 0) in (0)   then 'TABLE' else 'TABLE/PRIMARY_KEY_RANGE' end)
        else 'TABLE'
        end) batch_size,
       (case dt.data_type
        when 'CHAR'      then (case when nvl(dt.num_buckets, 0) in (0,1) then 1 else dt.num_buckets end)
        when 'VARCHAR2'  then (case when nvl(dt.num_buckets, 0) in (0,1) then 1 else dt.num_buckets end)
        when 'NUMBER'    then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
        when 'DATE'      then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
        when 'TIMESTAMP' then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
        else 1
        end) num_batches
from wmsys.wm$versioned_tables vt, dba_ind_columns di, dba_tab_cols dt
where di.table_owner = vt.owner and
      di.table_name = vt.table_name || '_LT' and
      di.index_name = vt.table_name || '_PKI$' and
      di.column_position = 1 and
      dt.owner = vt.owner and
      dt.table_name = vt.table_name || '_LT' and
      dt.column_name = di.column_name and
      dt.user_generated = 'YES'
WITH READ ONLY ;
create or replace view wmsys.wm$all_version_hview_wdepth as
select vht.version, vht.parent_version, wt.workspace, vht.workspace# workspace_id, wt.depth
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$i wt
where vht.workspace# = wt.workspace_lock_id
WITH READ ONLY ;
create or replace procedure wmsys.validate_owm wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
7
54 96
a/+p57kl0OAcO2Zl3hSbUR92rUQwg0Svf8tnZy9EaYFBBpygoz1l1qHfA2XYKxSO01Hz4rvt
r+BqiV8I4sEtO3K8aJqNxmfZR9/yw0cZ7Bm6k92wJh/hUtWXOYhM15BNHSECqZct0+WKW3ix
Hx8=

/
