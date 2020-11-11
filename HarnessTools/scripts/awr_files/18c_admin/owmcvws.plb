@@?/rdbms/admin/sqlsessstart.sql
begin
  for view_rec in (select object_name
                   from dba_objects
                   where owner='WMSYS' and
                         object_type = 'VIEW' and
                         regexp_instr(object_name, '^ALL_|^CDB_|^DBA_|^ROLE_|^USER_|^WM_|^WM\$')>0) loop
    execute immediate 'drop view wmsys.' || view_rec.object_name ;
  end loop ;
end;
/
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
       wt2.current_version parent_current_version,
       (case bitand(wt2.wm$flag, 14) when 12 then wt2.mp_root else wt2.workspace end) parent_workspace_D
from wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where wt1.parent_workspace# = wt2.workspace_lock_id(+) ;
create or replace view wmsys.wm$workspaces_table as
select workspace, current_version, parent_version, post_version, verlist, owner, createtime, description, workspace_lock_id, freeze_status, freeze_mode, freeze_writer, oper_status, wm_lockmode,
       isrefreshed, freeze_owner, session_duration, implicit_sp_cnt, cr_status, sync_parver, last_change, depth, mp_root, keep, parent_workspace#, parent_workspace, parent_current_version
from wmsys.wm$workspaces_table$d
where nvl(freeze_mode, 'NULL') not in ('REMOVED', 'DEFERRED_REMOVAL') ;
create or replace view wmsys.wm$workspaces_table$i as
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
       wt1.parent_workspace#,
       wt2.workspace parent_workspace,
       wt2.current_version parent_current_version
from wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where wt1.parent_workspace# = wt2.workspace_lock_id(+) and
      bitand(wt1.wm$flag, 14) not in (12, 14) ;
create or replace view wmsys.wm$versioned_tables$d as
select vt.vtid# vtid,
       vt.table_name,
       vt.owner,
       decode(bitand(vt.wm$flag, 31), 0, 'UNDEFINED', 1, 'VERSIONED', 2, 'HIDDEN', 3, 'EV', 4, 'LWEV', 5, 'DV', 6, 'LWDV', 7, 'LW_DISABLED', 8, 'DDL',
                                      9, 'BDDL', 10, 'CDDL', 11, 'ODDL', 12, 'TDDL', 13, 'AVTDDL', 14, 'BL_F_BEGIN', 15, 'BL_P_BEGIN', 16, 'BL_P_END',
                                     17, 'BL_R_BEGIN', 18, 'ADD_VT', 19, 'SYNCVTV1', 20, 'SYNCVTV2', 21, 'RB_IND', 22, 'RN_CONS', 23, 'RN_IND',
                                     24, 'D_HIST_COLS', 25, 'U_HIST_COLS', 26, 'IDDL') disabling_ver,
       vt.bl_version,
       decode(bitand(vt.wm$flag,1536), 0, null, 512, 'ROOT_VERSION', 1024, 'LATEST') bl_savepoint,
       decode(bitand(vt.wm$flag,6144), 0, null, 2048, 'NO', 4096, 'YES') bl_check_for_duplicates,
       decode(bitand(vt.wm$flag,24576), 0, null, 8192, 'NO', 16384, 'YES') bl_single_transaction,
       decode(bitand(vt.wm$flag, 256), 0, 0, 256, 1) validtime
from wmsys.wm$versioned_tables$ vt ;
create or replace view wmsys.wm$versioned_tables$h as
select vt.vtid# vtid,
       vt.table_name,
       vt.owner,
       0 notification,
       null notifyworkspaces,
       decode(bitand(vt.wm$flag, 31), 0, 'UNDEFINED', 1, 'VERSIONED', 2, 'HIDDEN', 3, 'EV', 4, 'LWEV', 5, 'DV', 6, 'LWDV', 7, 'LW_DISABLED', 8, 'DDL',
                                      9, 'BDDL', 10, 'CDDL', 11, 'ODDL', 12, 'TDDL', 13, 'AVTDDL', 14, 'BL_F_BEGIN', 15, 'BL_P_BEGIN', 16, 'BL_P_END',
                                     17, 'BL_R_BEGIN', 18, 'ADD_VT', 19, 'SYNCVTV1', 20, 'SYNCVTV2', 21, 'RB_IND', 22, 'RN_CONS', 23, 'RN_IND',
                                     24, 'D_HIST_COLS', 25, 'U_HIST_COLS', 26, 'IDDL') disabling_ver,
       vt.ricweight,
       0 isfastlive,
       0 isworkflow,
       decode(bitand(vt.wm$flag, 224), 0, 'NONE', 32, 'VIEW_W_OVERWRITE', 64, 'VIEW_W_OVERWRITE_PERF',
                                      96, 'VIEW_WO_OVERWRITE', 128, 'VIEW_WO_OVERWRITE_PERF') hist,
       vt.pkey_cols,
       vt.undo_code,
       null bl_workspace,
       vt.bl_version,
       decode(bitand(vt.wm$flag, 1536), 0, null, 512, 'ROOT_VERSION', 1024, 'LATEST') bl_savepoint,
       decode(bitand(vt.wm$flag, 6144), 0, null, 2048, 'NO', 4096, 'YES') bl_check_for_duplicates,
       decode(bitand(vt.wm$flag, 24576), 0, null, 8192, 'NO', 16384, 'YES') bl_single_transaction,
       decode(bitand(vt.wm$flag, 256), 0, 0, 256, 1) validtime,
       decode(bitand(vt.wm$flag, 98304), 0, null, 32768, 'IA', 65536, 'IN', null) identity_type
from wmsys.wm$versioned_tables$ vt ;
create or replace view wmsys.wm$versioned_tables as
select vtid, table_name, owner, notification, notifyworkspaces, disabling_ver, ricweight, isfastlive, isworkflow,
       hist, pkey_cols, undo_code, bl_workspace, bl_version, bl_savepoint,
       bl_check_for_duplicates, bl_single_transaction, validtime, identity_type
from wmsys.wm$versioned_tables$h
where disabling_ver <> 'HIDDEN' ;
create or replace view wmsys.wm$batch_compressible_tables as
select wt.workspace,
       vt.owner || '.' || vt.table_name table_name,
       bct.begin_version,
       bct.end_version,
       bct.where_clause
from wmsys.wm$batch_compressible_tables$ bct, wmsys.wm$workspaces_table$i wt, wmsys.wm$versioned_tables$ vt
where bct.workspace# = wt.workspace_lock_id and
      bct.vtid# = vt.vtid# ;
create or replace view wmsys.wm$column_props as
select vt.owner,
       vt.table_name,
       (select column_name
        from sys.dba_tab_cols dtc
        where dtc.owner = vt.owner and
              dtc.table_name = vt.table_name and
              dtc.user_generated = 'YES' and
              dtc.identity_column = 'YES') column_name,
       vt.identity_type
from wmsys.wm$versioned_tables vt
where vt.identity_type is not null ;
create or replace view wmsys.wm$cons_columns as
select vt.owner, cc.constraint_name, vt.table_name, cc.column_name, cc.position
from wmsys.wm$cons_columns$ cc, wmsys.wm$versioned_tables$ vt
where cc.vtid# = vt.vtid# ;
create or replace view wmsys.wm$constraints_table as
select vt.owner,
       ct.constraint_name,
       decode(bitand(ct.wm$flag, 135), 0, 'P', 1, 'PN', 2, 'PU', 3, 'U', 4, 'UI', 5, 'UN', 6, 'UU', 7, 'C', 128, 'R') constraint_type,
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
where ct.vtid# = vt.vtid# and
      bitand(ct.wm$flag, 128) = 0;
create or replace view wmsys.wm$dba_tab_cols as
select dtc.owner, dtc.table_name, dtc.column_name, dtc.data_type, dtc.data_type_mod, dtc.data_type_owner, dtc.data_length, dtc.data_precision, dtc.data_scale,
       dtc.column_id, dtc.default_length, dtc.data_default, dtc.char_length, dtc.char_used, dtc.hidden_column, dtc.user_generated,
       (case dtc.virtual_column
        when 'NO' then 'NO'
        else decode((select bitand(c.property, 65536)
                     from all_users u, sys.obj$ o, sys.col$ c
                     where u.username = dtc.owner and
                           u.user_id = o.owner# and
                           o.name = dtc.table_name and
                           c.obj# = o.obj# and
                           c.name = dtc.column_name),
                    65536, 'YES', 'NO')
        end) virtual_column,
       dtc.identity_column, ic.sequence_name identity_sequence, ic.identity_options,
       (case ic.generation_type when 'ALWAYS' then 'IA' else (case dtc.default_on_null when 'NO' then 'ID' else 'IN' end) end) identity_type
from sys.dba_tab_cols dtc, dba_tab_identity_cols ic
where dtc.owner = ic.owner(+) and
      dtc.table_name = ic.table_name(+) and
      dtc.column_name = ic.column_name(+) ;
create or replace view wmsys.wm$env_vars as
select ev.name,
       ev.value,
       decode(bitand(ev.wm$flag, 1), 0, 0, 1, 1) hidden
from wmsys.wm$env_vars$ ev ;
create or replace view wmsys.wm$events_info as
select ei.event_name, decode(bitand(ei.wm$flag, 1), 0, 'OFF', 1, 'ON') capture
from wmsys.wm$events_info$ ei ;
create or replace view wmsys.wm$hash_table as
select hash
from wmsys.wm$hash_table$ ht ;
create or replace view wmsys.wm$hint_table as
select ht.hint_id, vt.owner, vt.table_name, ht.hint_text, decode(bitand(ht.wm$flag, 1), 0, 0, 1, 1) isdefault
from wmsys.wm$hint_table$ ht, wmsys.wm$versioned_tables$ vt
where ht.vtid# = vt.vtid#(+) ;
create or replace view wmsys.wm$insteadof_trigs_table as
select vt.owner table_owner, vt.table_name,
       'WMSYS.WM$' || vt.vtid || '$INSERT$' insert_trigger_name,
       'WMSYS.WM$' || vt.vtid || '$UPDATE$' update_trigger_name,
       'WMSYS.WM$' || vt.vtid || '$DELETE$' delete_trigger_name
from wmsys.wm$versioned_tables vt ;
create or replace view wmsys.wm$lockrows_info as
select wt.workspace, vt.owner, vt.table_name, li.where_clause
from wmsys.wm$lockrows_info$ li, wmsys.wm$workspaces_table$i wt, wmsys.wm$versioned_tables$ vt
where li.vtid# = vt.vtid# and
      li.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$modified_tables as
select mt.vtid# vtid, vt.owner || '.' || vt.table_name table_name, mt.version, wt.workspace,
       wmsys.ltUtil.rowsInVersFromHistogram(vt.owner, vt.table_name, wt.workspace, mt.version, mt.version) num_rows
from wmsys.wm$modified_tables$ mt, wmsys.wm$versioned_tables$ vt, wmsys.wm$workspaces_table$i wt
where mt.vtid# = vt.vtid# and
      mt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$mp_graph_workspaces_table as
select wt1.workspace mp_leaf_workspace, wt2.workspace mp_graph_workspace, mgwt.anc_version,
       decode(bitand(mgwt.wm$flag, 3), 0, 'I', 1, 'L', 2, 'R') mp_graph_flag
from wmsys.wm$mp_graph_workspaces_table$ mgwt, wmsys.wm$workspaces_table$i wt1, wmsys.wm$workspaces_table$i wt2
where mgwt.mp_leaf_workspace# = wt1.workspace_lock_id and
      mgwt.mp_graph_workspace# = wt2.workspace_lock_id ;
create or replace view wmsys.wm$mp_parent_workspaces_table as
select wt1.workspace,
       wt2.workspace parent_workspace,
       mpwt.parent_version,
       mpwt.creator,
       mpwt.createtime,
       mpwt.workspace# workspace_lock_id,
       mpwt.parent_workspace#,
       decode(bitand(mpwt.wm$flag, 1), 0, 0, 1, 1) isrefreshed,
       decode(bitand(mpwt.wm$flag, 2), 0, 'DP', 2, 'MP') parent_flag
from wmsys.wm$mp_parent_workspaces_table$ mpwt, wmsys.wm$workspaces_table$i wt1, wmsys.wm$workspaces_table$i wt2
where mpwt.workspace# = wt1.workspace_lock_id and
      mpwt.parent_workspace# = wt2.workspace_lock_id ;
create or replace view wmsys.wm$mw_table as
select wt.workspace
from wmsys.wm$mw_table$ mt, wmsys.wm$workspaces_table$i wt
where mt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$nested_columns_table as
select vt.owner,
       vt.table_name,
       nct.column_name,
       nct.position,
       nct.type_owner,
       nct.type_name,
       nct.nt_owner,
       nct.nt_name,
       nct.nt_store
from wmsys.wm$nested_columns_table$ nct, wmsys.wm$versioned_tables$ vt
where nct.vtid# = vt.vtid# ;
create or replace view wmsys.wm$nextver_table as
select nt.version, nt.next_vers, wt.workspace, nt.split
from wmsys.wm$nextver_table$ nt, wmsys.wm$workspaces_table$i wt
where nt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$removed_workspaces_table as
 select wt1.owner,
        wt1.mp_root workspace_name,
        wt1.workspace_lock_id workspace_id,
        wt1.parent_workspace_D parent_workspace_name,
        wt1.parent_workspace# parent_workspace_id,
        wt1.createtime,
        wt1.last_change retiretime,
        wt1.description,
        to_number(wt1.depth) mp_root_id,
        wt1.isrefreshed
 from wmsys.wm$workspaces_table$d wt1
 where wt1.freeze_mode = 'REMOVED'
union all
 select wt1.owner,
        wt1.workspace workspace_name,
        wt1.workspace_lock_id workspace_id,
        wt1.parent_workspace_D parent_workspace_name,
        wt1.parent_workspace# parent_workspace_id,
        wt1.createtime,
        wt1.last_change retiretime,
        wt1.description,
        to_number(wt1.depth) mp_root_id,
        wt1.isrefreshed
 from wmsys.wm$workspaces_table$d wt1
 where wt1.freeze_mode = 'DEFERRED_REMOVAL' and
       keep=1 ;
create or replace view wmsys.wm$resolve_workspaces_table as
select wt.workspace, rwt.resolve_user, rwt.undo_sp# undo_sp_ver,
       decode(bitand(rwt.wm$flag, 7), 0, null, 1, '1WRITER', 2, '1WRITER_SESSION', 3, 'NO_ACCESS', 4, 'READ_ONLY', 5, 'WM_ONLY') oldfreezemode,
       rwt.oldfreezewriter
from wmsys.wm$resolve_workspaces_table$ rwt, wmsys.wm$workspaces_table$i wt
where rwt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$ric_locking_table as
select vt.owner pt_owner, vt.table_name pt_name, rlt.slockno, rlt.elockno
from wmsys.wm$ric_locking_table$ rlt, wmsys.wm$versioned_tables$ vt
where rlt.pt_vtid# = vt.vtid# ;
create or replace view wmsys.wm$ric_table as
select vt1.owner ct_owner,
       vt1.table_name ct_name,
       vt2.owner pt_owner,
       vt2.table_name pt_name,
       rt.ric_name,
       rt.ct_cols,
       rt.pt_cols,
       rt.pt_unique_const_name,
       decode(bitand(rt.wm$flag, 3), 0, 'C', 1, 'N', 2, 'R') my_mode,
       decode(bitand(rt.wm$flag, 4), 0, 'DISABLED', 4, 'ENABLED') status
from wmsys.wm$ric_table$ rt, wmsys.wm$versioned_tables$ vt1, wmsys.wm$versioned_tables$ vt2
where rt.ct_vtid# = vt1.vtid# and
      rt.pt_vtid# = vt2.vtid# ;
create or replace view wmsys.wm$ric_triggers_table as
select vt2.owner pt_owner, vt2.table_name pt_name, vt1.owner ct_owner, vt1.table_name ct_name,
       'WMSYS.WM$' || vt1.vtid# || '$LT_AU_' || rtt.trig# update_trigger_name,
       'WMSYS.WM$' || vt1.vtid# || '$LT_AD_' || rtt.trig# delete_trigger_name
from wmsys.wm$ric_triggers_table$ rtt, wmsys.wm$versioned_tables$ vt1, wmsys.wm$versioned_tables$ vt2
where rtt.ct_vtid# = vt1.vtid# and
      rtt.pt_vtid# = vt2.vtid# ;
create or replace view wmsys.wm$sysparam_all_values as
select sav.name, sav.value, decode(bitand(sav.wm$flag, 1), 0, 'NO', 1, 'YES') isdefault, decode(bitand(sav.wm$flag, 2), 0, 0, 2, 1) hidden
from wmsys.wm$sysparam_all_values$ sav ;
create or replace view wmsys.wm$udtrig_dispatch_procs as
select vt.owner table_owner_name,
       vt.table_name,
       'WMSYS.WM$DSP_UDT_' || udp.proc# dispatcher_name,
       udp.wm$flag trig_flag
from wmsys.wm$udtrig_dispatch_procs$ udp, wmsys.wm$versioned_tables$ vt
where udp.vtid# = vt.vtid# ;
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
       decode(bitand(ui.wm$flag, 33554432), 0, 0, 33554432, 33554432) +
       decode(bitand(ui.wm$flag, 67108864), 0, 0, 67108864, 67108864) event_flag
from wmsys.wm$udtrig_info$ ui, wmsys.wm$versioned_tables$ vt
where ui.vtid# = vt.vtid# ;
create or replace view wmsys.wm$version_hierarchy_table as
select vht.version, vht.parent_version, wt.workspace, wt.wm_lockmode
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$i wt
where vht.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$version_table as
select wt1.workspace, wt2.workspace anc_workspace, vt.anc_version, vt.anc_depth, vt.refcount
from wmsys.wm$version_table$ vt, wmsys.wm$workspaces_table$i wt1, wmsys.wm$workspaces_table$i wt2
where vt.workspace# = wt1.workspace_lock_id and
      vt.anc_workspace# = wt2.workspace_lock_id ;
create or replace view wmsys.wm$vt_errors_table as
select vt.owner,
       vt.table_name,
       vet.index_type,
       vet.index_field,
       decode(bitand(vet.wm$flag, 31), 0,  'EV STEP BEING EXECUTED',
                                       1,  'EV STEP EXECUTED WITH ERRORS',
                                       2,  'DV STEP BEING EXECUTED',
                                       3,  'DV STEP EXECUTED WITH ERRORS',
                                       4,  'CDDL STEP BEING EXECUTED',
                                       5,  'CDDL STEP EXECUTED WITH ERRORS',
                                       6,  'UNDO EV STEP BEING EXECUTED',
                                       7,  'UNDO EV STEP EXECUTED WITH ERRORS',
                                       8,  'STATEMENT BEING EXECUTED',
                                       9,  'STATEMENT EXECUTED WITH ERRORS',
                                       10, 'ADD VALID TIME STEP BEING EXECUTED',
                                       11, 'ADD VALID TIME STEP EXECUTED WITH ERRORS',
                                       12, 'ALTERVERSIONEDTABLE DDL STEP BEING EXECUTED',
                                       13, 'ALTERVERSIONEDTABLE DDL STEP EXECUTED WITH ERRORS',
                                       14, 'REBUILD INDEX STEP BEING EXECUTED',
                                       15, 'REBUILD INDEX STEP EXECUTED WITH ERRORS',
                                       16, 'RENAME CONSTRAINT STEP BEING EXECUTED',
                                       17, 'RENAME CONSTRAINT STEP EXECUTED WITH ERRORS',
                                       18, 'RENAME INDEX STEP BEING EXECUTED',
                                       19, 'RENAME INDEX STEP EXECUTED WITH ERRORS',
                                       20, 'SYNCRONIZE VT VIEWS STEP BEING EXECUTED',
                                       21, 'SYNCRONIZE VT VIEWS STEP EXECUTED WITH ERRORS') status,
       vet.error_msg
from wmsys.wm$vt_errors_table$ vet, wmsys.wm$versioned_tables$ vt
where vet.vtid# = vt.vtid# ;
create or replace view wmsys.wm$workspace_priv_table as
select wpt.grantee,
       wt.workspace,
       wpt.grantor,
       decode(bitand(wpt.wm$flag, 31), 0, 'U',
                                       1, 'A', 2, 'M', 3, 'R', 4, 'D', 5, 'C', 6, 'F', 13, 'G',
                                       7, 'AA', 8, 'MA', 9, 'RA', 10, 'DA', 11, 'CA', 12, 'FA', 14, 'GA',
                                       15, 'W') priv,
       decode(bitand(wpt.wm$flag, 32), 0, 0, 32, 1) admin
from wmsys.wm$workspace_priv_table$ wpt, wmsys.wm$workspaces_table$i wt
where wpt.workspace# = wt.workspace_lock_id(+) ;
create or replace view wmsys.wm$workspace_savepoints_table as
select wt.workspace,
       wst.savepoint,
       wst.version,
       (select count(*)+1
        from wmsys.wm$workspace_savepoints_table$ wst2
        where wst2.workspace# = wst.workspace# and
              (wst2.version < wst.version or (wst2.version = wst.version and wst2.createtime < wst.createtime))) position,
       decode(bitand(wst.wm$flag, 1), 0, 0, 1, 1) is_implicit,
       wst.owner,
       wst.createtime,
       wst.description
from wmsys.wm$workspace_savepoints_table$ wst, wmsys.wm$workspaces_table$i wt
where wst.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$all_locks_view as
select vt.owner, vt.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKMODE'),
              'E', 'EXCLUSIVE', 'S', 'SHARED', 'VE', 'VERSION EXCLUSIVE', 'WE', 'WORKSPACE EXCLUSIVE') lock_mode,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKUSER') lock_owner,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS), 'ROW_LOCKSTATE') locking_state
from wmsys.wm$versioned_tables vt,
     table(wmsys.owm_dynsql_access.get_lock_table(vt.owner, vt.table_name)) t
with READ ONLY ;
create or replace view wmsys.wm$all_version_hview_wdepth as
select vht.version, vht.parent_version, wt.workspace, vht.workspace# workspace_id, wt.depth, wt.wm_lockmode
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$i wt
where vht.workspace# = wt.workspace_lock_id
WITH READ ONLY ;
create or replace view wmsys.wm$anc_version_view as
select vht1.version, vht2.version parent_vers, vht1.workspace
from wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2, wmsys.wm$version_table vt
where vht1.workspace = vt.workspace and
      vht2.workspace = vt.anc_workspace and
      vht2.version  <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$base_version_view as
select decode(sign(vt1.anc_version - vt2.anc_version), 1, vt2.anc_version, vt1.anc_version) version,
       decode(sign(vt1.anc_version - vt2.anc_version), 1, vt2.anc_workspace#, vt1.anc_workspace#) workspace#
from (select vt1.anc_version, vt1.anc_workspace#
      from wmsys.wm$version_table$ vt1
      where vt1.workspace# = sys_context('lt_ctx', 'diffWspc1_id') and
            vt1.anc_workspace# = sys_context('lt_ctx', 'anc_workspace_id')
      union all
      select decode(sys_context('lt_ctx', 'diffver1'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table$
                         where workspace_lock_id = sys_context('lt_ctx', 'diffWspc1_id')),
                     sys_context('lt_ctx', 'diffver1')) version,
              cast(sys_context('lt_ctx', 'diffWspc1_id') as number)
      from sys.dual
      where sys_context('lt_ctx', 'anc_workspace_id') = sys_context('lt_ctx', 'diffWspc1_id')
      ) vt1,
      (select vt2.anc_version, vt2.anc_workspace#
       from wmsys.wm$version_table$ vt2
       where vt2.workspace# = sys_context('lt_ctx', 'diffWspc2_id') and
             vt2.anc_workspace# = sys_context('lt_ctx', 'anc_workspace_id')
       union all
       select decode(sys_context('lt_ctx', 'diffver2'),
                     -1, (select current_version
                          from wmsys.wm$workspaces_table$
                          where workspace_lock_id = sys_context('lt_ctx', 'diffWspc2_id')),
                     sys_context('lt_ctx', 'diffver2')) version,
              cast(sys_context('lt_ctx', 'diffWspc2_id') as number)
       from sys.dual
       where sys_context('lt_ctx', 'anc_workspace_id') = sys_context('lt_ctx', 'diffWspc2_id')
      ) vt2
WITH READ ONLY ;
create or replace view wmsys.wm$base_hierarchy_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$base_version_view bv
 where vht.workspace# = bv.workspace# and
       vht.version <= bv.version
union all
 select vht.version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$base_version_view bv
 where vt.workspace# = bv.workspace# and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$base_nextver_view as
select next_vers
from wmsys.wm$nextver_table$
where version in (select version from wmsys.wm$base_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$conf1_hierarchy_view as
 select vht.version, vht.workspace#
 from wmsys.wm$version_hierarchy_table$ vht
 where vht.workspace# = sys_context('lt_ctx', 'conflict_state_id')
union all
 select vht.version, vht.workspace#
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'conflict_state_id') and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$conf1_nextver_view as
select next_vers
from wmsys.wm$nextver_table
where version in (select version from wmsys.wm$conf1_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$conf2_hierarchy_view as
 select vht.version, vht.workspace#
 from wmsys.wm$version_hierarchy_table$ vht
 where vht.workspace# = sys_context('lt_ctx', 'parent_conflict_state_id')
union all
 select vht.version, vht.workspace#
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'parent_conflict_state_id') and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$conf2_nextver_view as
select next_vers
from wmsys.wm$nextver_table
where version in (select version from wmsys.wm$conf2_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$conf_base_hierarchy_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht
 where vht.workspace# = sys_context('lt_ctx', 'confbasever_id') and
       vht.version <= sys_context('lt_ctx', 'confbasever')
union all
 select vht.version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'confbasever_id') and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$conf_base_nextver_view as
select next_vers
from wmsys.wm$nextver_table
where version in (select version from wmsys.wm$conf_base_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$curconflict_parvers_view as
select mt.version parent_vers, mt.vtid# vtid
from wmsys.wm$modified_tables$ mt
where mt.workspace# = sys_context('lt_ctx', 'conflict_state_id')
WITH READ ONLY ;
create or replace view wmsys.wm$curconflict_nextvers_view as
select nt.version, nt.next_vers, nt.split, cpv.vtid
from wmsys.wm$nextver_table$ nt, wmsys.wm$curConflict_parvers_view cpv
where nt.version = cpv.parent_vers
WITH READ ONLY ;
create or replace view wmsys.wm$current_child_versions_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where vht.workspace = vt.workspace and
       vt.anc_workspace = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
       vt.anc_version >= decode(sys_context('lt_ctx', 'version'),
                                 -1, (select current_version
                                      from wmsys.wm$workspaces_table
                                      where workspace = sys_context('lt_ctx', 'state')),
                                 null, (select current_version
                                        from wmsys.wm$workspaces_table
                                        where workspace = wmsys.ltUtil.getDefaultWorkspaceName),
                                 sys_context('lt_ctx', 'version')
                               )
union all
 select vht.version
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
       vht.version > decode(sys_context('lt_ctx', 'version'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table
                                  where workspace = sys_context('lt_ctx', 'state')),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = wmsys.ltUtil.getDefaultWorkspaceName),
                             sys_context('lt_ctx', 'version')
                           )
WITH READ ONLY ;
create or replace view wmsys.wm$current_cons_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers
from wmsys.wm$nextver_table nvt
where (nvt.workspace = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
       nvt.version <= decode(sys_context('lt_ctx', 'version'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table
                                  where workspace = sys_context('lt_ctx', 'state')),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = wmsys.ltUtil.getDefaultWorkspaceName),
                             sys_context('lt_ctx', 'version')
                            ) and
       not (nvl(sys_context('lt_ctx', 'rowlock_status'), 'X') = 'F' and nvl(sys_context('lt_ctx', 'flip_version'), 'N') = 'Y')
      )
      or
      (exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace  = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
                     nvt.workspace = vt.anc_workspace and
                     nvt.version  <= vt.anc_version)
      )
WITH READ ONLY ;
create or replace view wmsys.wm$current_parvers_view as
select vht.version parent_vers, vht.workspace
from wmsys.wm$version_hierarchy_table vht
where (vht.workspace = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
       vht.version <= decode(sys_context('lt_ctx', 'version'),
                            -1, (select current_version
                                 from wmsys.wm$workspaces_table
                                 where workspace = sys_context('lt_ctx', 'state')),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = wmsys.ltUtil.getDefaultWorkspaceName),
                            sys_context('lt_ctx', 'version'))
      )
      or
      (exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace  = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName) and
                     vht.workspace = vt.anc_workspace and
                     vht.version  <= vt.anc_version )
      )
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_cons_versions as
select vht.version, vht.workspace
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.wm$version_hierarchy_table vht
where instr(sys_context('lt_ctx', 'current_mp_leafs'), mpg.mp_leaf_workspace) > 0 and
      mpg.mp_graph_flag = 'I' and
      vht.workspace = mpg.mp_graph_workspace and
      vht.version <= mpg.anc_version and
      ((nvl(sys_context('lt_ctx', 'rowlock_status'), 'X') = 'F' and nvl(sys_context('lt_ctx', 'flip_version'), 'N') = 'Y')
       or
       (nvl(sys_context('lt_ctx', 'isrefreshed'), '0') = '1')
      )
WITH READ ONLY ;
create or replace view wmsys.wm$current_cons_versions_view as
 select version
 from wmsys.wm$current_child_versions_view
union all
 select parent_vers
 from wmsys.wm$current_parvers_view
 where workspace = sys_context('lt_ctx', 'state') or
       nvl(sys_context('lt_ctx', 'rowlock_status'), 'X') <> 'F' or
       nvl(sys_context('lt_ctx', 'flip_version'), 'N') <> 'Y' or
       exists(select 1
              from wmsys.wm$mp_graph_workspaces_table
              where mp_graph_workspace = workspace and
                    mp_graph_flag <> 'R')
union all
 select version
 from wmsys.wm$mp_graph_cons_versions
union all
 select version
 from wmsys.wm$version_hierarchy_table
 where workspace in (select workspace
                     from wmsys.wm$version_table
                     where anc_workspace = sys_context('lt_ctx', 'state')) and
       nvl(sys_context('lt_ctx', 'rowlock_status'), 'X') = 'F' and
       nvl(sys_context('lt_ctx', 'flip_version'), 'N') = 'Y'
WITH READ ONLY ;
create or replace view wmsys.wm$current_mp_join_points as
select mpwst.mp_leaf_workspace# workspace#, vht.version
from wmsys.wm$mp_graph_workspaces_table$ mpwst, wmsys.wm$workspaces_table$i wt, wmsys.wm$version_hierarchy_table$ vht
where mpwst.mp_graph_workspace# = sys_context('lt_ctx', 'state_id')  and
      mpwst.mp_leaf_workspace# = wt.workspace_lock_id and
      wt.workspace_lock_id = vht.workspace# and
      wt.parent_version = vht.parent_version
WITH READ ONLY ;
create or replace view wmsys.wm$current_nextvers_view as
 select nvt.next_vers, nvt.version
 from wmsys.wm$nextver_table$ nvt
 where nvt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       nvt.version <= decode(sys_context('lt_ctx', 'version'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table$
                                  where workspace_lock_id = sys_context('lt_ctx', 'state_id')),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table$
                                    where workspace_lock_id = wmsys.ltUtil.getDefaultWorkspaceId),
                             sys_context('lt_ctx', 'version'))
union all
 select nvt.next_vers, nvt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$nextver_table$ nvt
 where vt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       vt.anc_workspace# = nvt.workspace# and
       nvt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$current_workspace_view as
select workspace, parent_workspace, current_version, post_version, verlist, owner, createtime, description,
       workspace_lock_id, freeze_status, freeze_mode, freeze_writer, oper_status, wm_lockmode, isrefreshed, freeze_owner,
       session_duration, implicit_sp_cnt, cr_status, sync_parver, last_change
from wmsys.wm$workspaces_table
where workspace = coalesce(sys_context('lt_ctx', 'state'), wmsys.ltUtil.getDefaultWorkspaceName)
WITH READ ONLY ;
create or replace view wmsys.wm$diff1_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table$
 where workspace# = sys_context('lt_ctx', 'diffWspc1_id') and
       version <= decode(sys_context('lt_ctx', 'diffver1'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table$
                              where workspace_lock_id = sys_context('lt_ctx', 'diffWspc1_id')),
                         sys_context('lt_ctx', 'diffver1'))
union all
 select version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'diffWspc1_id') and
       vt.anc_workspace# = vht.workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff1_nextver_view as
select next_vers
from wmsys.wm$nextver_table$
where version in (select version from wmsys.wm$diff1_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$diff2_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table$
 where workspace# = sys_context('lt_ctx', 'diffWspc2_id') and
       version <= decode(sys_context('lt_ctx', 'diffver2'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table$
                              where workspace_lock_id = sys_context('lt_ctx', 'diffWspc2_id')),
                         sys_context('lt_ctx', 'diffver2'))
union all
 select version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'diffWspc2_id') and
       vt.anc_workspace# = vht.workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff2_nextver_view as
select next_vers
from wmsys.wm$nextver_table$
where version in (select version from wmsys.wm$diff2_hierarchy_view)
WITH READ ONLY ;
create or replace view wmsys.wm$exp_map as
select code, nfield1, nfield2, nfield3, vfield1, vfield2, vfield3
from table(wmsys.lt_export_pkg.export_mapping_view_func())
WITH READ ONLY ;
create or replace view wmsys.wm$internal_objects as
select code vtid,
       vfield1 obj_owner,
       vfield2 obj_name,
       decode(nfield1, 0, 'TABLE', 1, 'INDEX', 2, 'CONSTRAINT', 3, 'PROCEDURE', 4, 'VIEW', 5, 'TRIGGER', 6, 'PACKAGE', 7, 'PACKAGE BODY', null) obj_type,
       (case nfield2 when 0 then 'VALID' when 1 then 'INVALID' when 2 then 'MISSING' else null end) obj_status,
       (case nfield3 when 0 then 'NO' else 'YES' end) exported
from table(wmsys.lt_export_pkg.get_internal_objects()) ;
create or replace view wmsys.wm$migration_error_view as
select vfield3 error_text
from table(wmsys.ltUtil.wm$getErrors)
/
create or replace view wmsys.wm$metadata_map as
select code, nfield1, nfield2, nfield3, vfield1, vfield2, vfield3, wm_version, wm_nextver, wm_delstatus, wm_ltlock, wm_createtime, wm_retiretime, wm_validfrom, wm_validtill
from table(wmsys.lt_export_pkg.export_metadata_view_func())
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_new_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where vt.workspace = sys_context('lt_ctx', 'new_mp_leaf') and
      vht.workspace = vt.anc_workspace and
      vht.version <= vt.anc_version and
      (vt.refCount < 0 or (vht.workspace = sys_context('lt_ctx', 'new_mp_root') and vht.version > sys_context('lt_ctx', 'old_root_anc_version')))
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_other_versions as
 select vht.version, vht.workspace
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where vt.workspace = sys_context('lt_ctx', 'new_mp_leaf') and
       vht.workspace = vt.anc_workspace and
       vht.version <= vt.anc_version and
       vt.refCount > 0 and
       vt.anc_workspace not in
             (select sys_context('lt_ctx', 'new_mp_root')
              from sys.dual
             union all
              select anc_workspace
              from wmsys.wm$version_table root_anc
              where workspace = sys_context('lt_ctx', 'new_mp_root'))
union all
 select vht.version, vht.workspace
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where vt.anc_workspace = sys_context('lt_ctx', 'new_mp_leaf') and
        vht.workspace = vt.workspace
union all
 select vht.version, vht.workspace
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = sys_context('lt_ctx', 'new_mp_leaf')
union all
 select version, workspace
 from wmsys.wm$mp_graph_cons_versions
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_remaining_versions as
 select vht.version
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where vt.anc_workspace = sys_context('lt_ctx', 'mp_workspace') and
       vht.workspace = vt.workspace
union all
 select vht.version
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = sys_context('lt_ctx', 'mp_workspace')
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_removed_versions as
select vht.version, vht.workspace
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
where vt.workspace = sys_context('lt_ctx', 'mp_workspace') and
      vht.workspace = vt.anc_workspace and
      vht.version <= vt.anc_version and
      (vt.refCount = 0 or (vht.workspace = sys_context('lt_ctx', 'mp_root') and
                           vht.version > sys_context('lt_ctx', 'new_root_anc_version')))
WITH READ ONLY ;
create or replace view wmsys.wm$mp_join_points as
select mpwst.mp_leaf_workspace workspace, vht.version
from wmsys.wm$mp_graph_workspaces_table mpwst, wmsys.wm$workspaces_table$i wt, wmsys.wm$version_hierarchy_table vht
where mpwst.mp_graph_workspace = sys_context('lt_ctx', 'new_mp_leaf') and
      mpwst.mp_leaf_workspace = wt.workspace and
      wt.workspace = vht.workspace and
      wt.parent_version = vht.parent_version
WITH READ ONLY ;
create or replace view wmsys.wm$mw_nextvers_view as
select nvt.next_vers
from wmsys.wm$nextver_table  nvt
where  nvt.workspace in (select workspace from wmsys.wm$mw_table)
       or
       exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace in (select workspace from wmsys.wm$mw_table) and
                     nvt.workspace = vt.anc_workspace and
                     nvt.version  <= vt.anc_version)
WITH READ ONLY ;
create or replace view wmsys.wm$mw_versions_view_9i as
select version, modified_by, wmsys.ltUtil.wm$concat(cast(collect(workspace) as wmsys.wm$ident_tab_type)) seen_by
from (select vht.version, vht.workspace modified_by, mw.workspace
      from wmsys.wm$mw_table mw, wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht
      where mw.workspace = vt.workspace and
            vt.anc_workspace = vht.workspace and
            vht.version <= vt.anc_version
     union all
      select vht.version, vht.workspace modified_by, mw.workspace
      from wmsys.wm$mw_table mw, wmsys.wm$version_hierarchy_table vht
      where mw.workspace = vht.workspace
     )
group by (version,modified_by)
WITH READ ONLY ;
create or replace view wmsys.wm$net_diff1_hierarchy_view as
 select version from wmsys.wm$diff1_hierarchy_view
minus
 select version from wmsys.wm$base_hierarchy_view
WITH READ ONLY ;
create or replace view wmsys.wm$net_diff2_hierarchy_view as
 select version from wmsys.wm$diff2_hierarchy_view
minus
 select version from wmsys.wm$base_hierarchy_view
WITH READ ONLY ;
create or replace view wmsys.wm$parconflict_parvers_view as
select mt.version parent_vers, mt.vtid# vtid
from wmsys.wm$modified_tables$ mt, wmsys.wm$workspaces_table$i wt
where mt.workspace# = sys_context('lt_ctx', 'parent_conflict_state_id') and
      wt.workspace_lock_id = sys_context('lt_ctx', 'conflict_state_id') and
      mt.version >= decode(sign(wt.parent_version - wt.sync_parver), -1, (wt.parent_version+1), sync_parver)
WITH READ ONLY ;
create or replace view wmsys.wm$parconflict_nextvers_view as
select nt.version, nt.next_vers, nt.split, ppv.vtid
from wmsys.wm$nextver_table$ nt, wmsys.wm$parConflict_parvers_view ppv
where nt.version = ppv.parent_vers
WITH READ ONLY ;
create or replace view wmsys.wm$parvers_view as
 select version parent_vers
 from wmsys.wm$version_hierarchy_table$
 where workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId)
union all
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$version_table$ vt
 where vt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$table_parvers_view as
 select vtid# vtid, mt.version parent_vers
 from wmsys.wm$modified_tables$ mt
 where mt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       mt.version <= decode(sys_context('lt_ctx', 'version'),
                            -1, (select current_version
                                 from wmsys.wm$workspaces_table$
                                 where workspace_lock_id = sys_context('lt_ctx', 'state_id')),
                            null, (select current_version
                                   from wmsys.wm$workspaces_table$
                                   where workspace_lock_id = wmsys.ltUtil.getDefaultWorkspaceId),
                            sys_context('lt_ctx', 'version'))
union all
 select vtid#, mt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$modified_tables$ mt
 where vt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       vt.anc_workspace# = mt.workspace# and
       mt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$table_versions_in_live_view as
select vtid# vtid, mt.version parent_vers
from wmsys.wm$modified_tables$ mt
where mt.workspace# = 0
WITH READ ONLY ;
create or replace view wmsys.wm$table_ws_parvers_view as
 select vtid# vtid, mt.version parent_vers
 from wmsys.wm$modified_tables$ mt
 where mt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId)
union all
 select vtid#, mt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$modified_tables$ mt
 where vt.workspace# = coalesce(to_number(sys_context('lt_ctx', 'state_id')), wmsys.ltUtil.getDefaultWorkspaceId) and
       vt.anc_workspace# = mt.workspace# and
       mt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$version_view as
 select vht1.version, vht2.version parent_vers, vht1.workspace
 from wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2, wmsys.wm$version_table vt
 where vht1.workspace = vt.workspace and
       vht2.workspace = vt.anc_workspace and
       vht2.version  <= vt.anc_version
union all
 select vht1.version, vht2.version parent_vers, vht1.workspace
 from wmsys.wm$version_hierarchy_table vht1, wmsys.wm$version_hierarchy_table vht2
 where vht2.version <= vht1.version and
       vht2.workspace = vht1.workspace
WITH READ ONLY ;
create or replace view wmsys.wm$workspace_sessions_view as
  select st.username, wt.workspace, st.sid, st.serial#, st.saddr, st.inst_id, decode(dl.lmode, 2, 'SS', 4, 'S', 'U') lockMode, 0 isImplicit
  from gv$lock dl, wmsys.wm$workspaces_table$i wt, gv$session st
  where dl.type = 'UL' and
        dl.id1 - 1 = wt.workspace_lock_id and
        dl.sid = st.sid and
        dl.inst_id = st.inst_id
 union all
  select st.username, cast(wmsys.owm_dynsql_access.GetSystemParameter('DEFAULT_WORKSPACE') as varchar2(128)), st.sid, st.serial#, st.saddr, st.inst_id, 'S', 1
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
create or replace view wmsys.user_wm_privs as
select distinct
       workspace,
       decode(priv, 'A',  'ACCESS_WORKSPACE',
                    'C',  'CREATE_WORKSPACE',
                    'D',  'REMOVE_WORKSPACE',
                    'F',  'FREEZE_WORKSPACE',
                    'G',  'GRANTPRIV_WORKSPACE',
                    'M',  'MERGE_WORKSPACE',
                    'R',  'ROLLBACK_WORKSPACE',
                    'AA', 'ACCESS_ANY_WORKSPACE',
                    'CA', 'CREATE_ANY_WORKSPACE',
                    'DA', 'REMOVE_ANY_WORKSPACE',
                    'FA', 'FREEZE_ANY_WORKSPACE',
                    'GA', 'GRANTPRIV_ANY_WORKSPACE',
                    'MA', 'MERGE_ANY_WORKSPACE',
                    'RA', 'ROLLBACK_ANY_WORKSPACE',
                    'W',  'WM_ADMIN',
                          'UNKNOWN_PRIV') privilege,
       grantor,
       decode(admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table
where grantee in
   (select role from session_roles
   union all
    select 'WM_ADMIN_ROLE' from sys.dual where sys_context('userenv', 'current_user') = 'SYS'
   union all
    select username from all_users where username = sys_context('userenv', 'current_user')
   union all
    select 'PUBLIC' from sys.dual)
WITH READ ONLY ;
create or replace view wmsys.all_workspaces_internal as
 select s.workspace, s.parent_workspace, s.current_version, s.parent_version, s.post_version, s.verlist, s.owner, s.createTime,
        s.description, s.workspace_lock_id, s.freeze_status, s.freeze_mode, s.freeze_writer, s.oper_status, s.wm_lockmode, s.isRefreshed,
        s.freeze_owner, s.session_duration, s.mp_root
 from wmsys.wm$workspaces_table$i s
 where exists (select 1 from wmsys.user_wm_privs where privilege = 'WM_ADMIN' or privilege like '%ANY%')
 union
 select s.workspace, s.parent_workspace, s.current_version, s.parent_version, s.post_version, s.verlist, s.owner, s.createTime,
        s.description, s.workspace_lock_id, s.freeze_status, s.freeze_mode, s.freeze_writer, s.oper_status, s.wm_lockmode, s.isRefreshed,
        s.freeze_owner, s.session_duration, s.mp_root
 from wmsys.wm$workspaces_table$i s,
      (select distinct workspace from wmsys.user_wm_privs) u
 where u.workspace = s.workspace
union
 select s.workspace, s.parent_workspace, s.current_version, s.parent_version, s.post_version, s.verlist, s.owner, s.createTime,
        s.description, s.workspace_lock_id, s.freeze_status, s.freeze_mode, s.freeze_writer, s.oper_status, s.wm_lockmode, s.isRefreshed,
        s.freeze_owner, s.session_duration, s.mp_root
from wmsys.wm$workspaces_table$i s where owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.all_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status, 'LOCKED', 'FROZEN', 'UNLOCKED', 'UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode, 'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(rst.workspace, null, decode(asp.session_duration, 0, asp.freeze_owner, s.username), null) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
              decode((select 1 from sys.dual
                      where s.sid = sys_context('lt_ctx', 'cid') and
                            s.serial# = sys_context('lt_ctx', 'serial#') and
                            s.inst_id = dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace, null, 'INACTIVE', 'ACTIVE') resolve_status,
       rst.resolve_user,
       decode(asp.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(asp.wm_lockmode, 1, instr(asp.wm_lockmode, ',')-1),
              'C', 'CARRY',
              'D', 'DISREGARD',
              'E', 'EXCLUSIVE',
              'S', 'SHARED',
              'VE', 'VERSION EXCLUSIVE',
              'WE', 'WORKSPACE EXCLUSIVE',
              null) workspace_lockmode,
       decode(substr(asp.wm_lockmode, instr(asp.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from   wmsys.all_workspaces_internal asp, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table rst, gv$session s
where  (ssp.position is null or ssp.position = (select min(position) from wmsys.wm$workspace_savepoints_table where version = ssp.version)) and
       asp.parent_version = ssp.version (+) and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1, instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1) and
       to_char(s.inst_id(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
create or replace view wmsys.user_workspaces as
select st.workspace, st.workspace_lock_id workspace_id, st.parent_workspace, ssp.savepoint parent_savepoint,
       st.owner, st.createTime, st.description,
       decode(st.freeze_status, 'LOCKED', 'FROZEN', 'UNLOCKED', 'UNFROZEN') freeze_status,
       decode(st.oper_status, null, st.freeze_mode, 'INTERNAL') freeze_mode,
       decode(st.freeze_mode, '1WRITER_SESSION', s.username, st.freeze_writer) freeze_writer,
       decode(rst.workspace, null, decode(st.session_duration, 0, st.freeze_owner, s.username), null) freeze_owner,
       decode(st.freeze_status, 'UNLOCKED', null, decode(st.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(st.session_duration, 1,
              decode((select 1 from sys.dual
                      where s.sid = sys_context('lt_ctx', 'cid') and
                            s.serial# = sys_context('lt_ctx', 'serial#') and
                            s.inst_id = dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace, null, 'INACTIVE', 'ACTIVE') resolve_status,
       rst.resolve_user,
       decode(st.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(st.wm_lockmode, 1, instr(st.wm_lockmode, ',')-1),
              'C', 'CARRY',
              'D', 'DISREGARD',
              'E', 'EXCLUSIVE',
              'S', 'SHARED',
              'VE', 'VERSION EXCLUSIVE',
              'WE', 'WORKSPACE EXCLUSIVE',
              null) workspace_lockmode,
       decode(substr(st.wm_lockmode, instr(st.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from wmsys.wm$workspaces_table$i st,
     wmsys.wm$workspace_savepoints_table ssp,
     wmsys.wm$resolve_workspaces_table rst, gv$session s
where st.owner = sys_context('userenv', 'current_user') and
      (ssp.position is null or ssp.position = (select min(position) from wmsys.wm$workspace_savepoints_table where version = ssp.version)) and
      st.parent_version = ssp.version (+) and
      st.workspace = rst.workspace (+) and
      to_char(s.sid(+)) = substr(st.freeze_owner, 1, instr(st.freeze_owner, ',')-1)  and
      to_char(s.serial#(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',')+1, instr(st.freeze_owner, ',',1,2)-instr(st.freeze_owner, ',')-1) and
      to_char(s.inst_id(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
create or replace view wmsys.all_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE,
       decode(mpg.mp_graph_flag, 'R', 'ROOT_WORKSPACE', 'I', 'INTERMEDIATE_WORKSPACE', 'L', 'LEAF_WORKSPACE') GRAPH_FLAG
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.all_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace
WITH READ ONLY ;
create or replace view wmsys.all_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
       decode(mp.isRefreshed,0, 'NO', 'YES') isRefreshed, decode(mp.parent_flag, 'DP', 'DEFAULT_PARENT', 'ADDITIONAL_PARENT') PARENT_FLAG
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.all_workspaces aw
where mp.workspace = aw.workspace
WITH READ ONLY ;
create or replace view wmsys.all_removed_workspaces as
 select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
        createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
 from wmsys.wm$removed_workspaces_table rwt
 where exists (select 1 from wmsys.user_wm_privs where privilege = 'WM_ADMIN' or privilege like '%ANY%')
union
 select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
        createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
 from wmsys.wm$removed_workspaces_table rwt,
      (select distinct workspace from wmsys.user_wm_privs) u
 where rwt.workspace_name = u.workspace
union
 select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
        createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
 from wmsys.wm$removed_workspaces_table rwt
 where rwt.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.all_version_hview as
select vht.version, vht.parent_version, wt.workspace, vht.workspace# workspace_id
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$i wt
where vht.workspace# = wt.workspace_lock_id
WITH READ ONLY ;
create or replace view wmsys.all_wm_constraints as
select /*+ LEADING(ct) */ ct.owner, constraint_name, constraint_type, table_name, search_condition, status, index_owner, index_name, index_type
from wmsys.wm$constraints_table ct, all_views av
where ct.owner = av.owner and
      ct.table_name = av.view_name
WITH READ ONLY ;
create or replace view wmsys.all_wm_constraint_violations as
select t.code violation#, t.vfield1 table_name1, substr(t.vfield3, 1, instr(t.vfield3, '|')-1) predicate1, t.nfield1 version1,
                          t.vfield2 table_name2, substr(t.vfield3, instr(t.vfield3, '|')+1) predicate2, t.nfield2 version2
from table(wmsys.owm_dynsql_access.returnConstraintViolations) t
WITH READ ONLY ;
create or replace view wmsys.all_wm_cons_columns as
select /*+ LEADING(t1) */ t1.owner, t1.constraint_name, t1.table_name, t1.column_name, t1.position
from wmsys.wm$cons_columns t1, all_views t2
where t1.owner = t2.owner and
      t1.table_name = t2.view_name
WITH READ ONLY ;
create or replace view wmsys.all_wm_ind_columns as
 select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name, t2.column_position, t2.column_length,  t2.descend
 from wmsys.wm$constraints_table t1, all_ind_columns t2
 where t1.index_owner = t2.index_owner and
       t1.index_name = t2.index_name and
       t1.constraint_type not in ('P', 'PN', 'PU')
union
 select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name, t2.column_position-1, t2.column_length, t2.descend
 from wmsys.wm$constraints_table t1, all_ind_columns t2
 where t1.index_owner = t2.index_owner and
       t1.index_name = t2.index_name and
       t1.constraint_type in ('P', 'PN', 'PU') and
       t2.column_name not in ('WM_VERSION', 'WM_DELSTATUS')
WITH READ ONLY ;
create or replace view wmsys.all_wm_ind_expressions as
select /*+ USE_NL(t1 t2) */ t2.index_owner,t2.index_name, t1.owner, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, all_ind_expressions t2
where t1.index_owner = t2.index_owner and
      t1.index_name = t2.index_name
WITH READ ONLY ;
create or replace view wmsys.all_wm_locked_tables as
select /*+ LEADING(t) */ t.owner table_owner, t.table_name, t.lock_mode, t.lock_owner, t.locking_state
from wmsys.wm$all_locks_view t, all_views s
where t.owner = s.owner and t.table_name = s.view_name
WITH READ ONLY ;
create or replace view wmsys.all_wm_modified_tables as
select table_name, workspace, savepoint
from (select o.table_name, o.workspace,
             nvl(s.savepoint, 'LATEST') savepoint,
             s.is_implicit imp,
             count(*) over (partition by o.table_name, o.workspace, s.version) counter
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s, all_views a
      where substr(o.table_name, 1, instr(o.table_name, '.')-1) = a.owner and
            substr(o.table_name, instr(o.table_name, '.')+1) = a.view_name and
            o.version = s.version (+))
where (imp = 0 or imp is null or counter = 1)
WITH READ ONLY ;
create or replace view wmsys.all_wm_policies as
select ap.object_owner, ap.object_name, ap.policy_group, ap.policy_name, ap.pf_owner,ap. package, ap.function,
       ap.sel, ap.ins, ap.upd, ap.del, ap.idx, ap.chk_option, enable, ap.static_policy, ap.policy_type, ap.long_predicate
from wmsys.wm$versioned_tables vt, all_policies ap
where ap.object_owner = vt.owner and
      ap.object_name in (vt.table_name, vt.table_name || '_CONF', vt.table_name || '_DIFF',
                         vt.table_name || '_HIST', vt.table_name || '_LOCK', vt.table_name || '_MW')
WITH READ ONLY ;
create or replace view wmsys.all_wm_ric_info as
select /*+ LEADING(rt) */ ct_owner, ct_name, pt_owner, pt_name, ric_name, rtrim(ct_cols, ',') ct_cols, rtrim(pt_cols, ',') pt_cols,
                          pt_unique_const_name r_constraint_name, my_mode delete_rule, status
from wmsys.wm$ric_table rt, all_views uv
where uv.view_name = rt.ct_name and
      uv.owner = rt.ct_owner
WITH READ ONLY ;
create or replace view wmsys.all_wm_tab_triggers as
select trig_owner_name trigger_owner,
       trig_name trigger_name,
       table_owner_name table_owner,
       table_name table_name,
       wmsys.ltUtil.getTrigTypes(trig_flag) trigger_type,
       status,
       when_clause,
       description,
       trig_code trigger_body,
       decode(bitand(event_flag, 32768), 0, 'OFF', 'ON') tab_merge_wo_remove,
       decode(bitand(event_flag, 65536), 0, 'OFF', 'ON') tab_merge_w_remove,
       decode(bitand(event_flag, 131072), 0, 'OFF', 'ON') wspc_merge_wo_remove,
       decode(bitand(event_flag, 262144), 0, 'OFF', 'ON') wspc_merge_w_remove,
       decode(bitand(event_flag, 524288), 0, 'OFF', 'ON') dml,
       decode(bitand(event_flag, 33554432), 0, 'OFF', 'ON') table_import
from wmsys.wm$udtrig_info
where (trig_owner_name  = sys_context('userenv', 'current_user') or
       table_owner_name = sys_context('userenv', 'current_user') or
       exists (select 1
               from user_sys_privs
               where privilege = 'CREATE ANY TRIGGER') or
       exists (select 1
               from session_roles sr, role_sys_privs rsp
               where sr.role = rsp.role and
                     rsp.privilege = 'CREATE ANY TRIGGER')) and
     internal_type = 'USER_DEFINED'
WITH READ ONLY ;
create or replace view wmsys.all_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name,
       t.owner,
       t.disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(t.notifyWorkspaces, 2, length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.owm_dynsql_access.AreThereConflicts(dv.owner, dv.object_name, vtid) conflict,
       wmsys.owm_dynsql_access.AreThereDiffs(dv.owner, dv.object_name, vtid) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t, all_objects dv
where t.owner = dv.owner and
      t.table_name = dv.object_name and
      dv.object_type in ('TABLE', 'VIEW')
WITH READ ONLY ;
create or replace view wmsys.all_wm_vt_errors as
select distinct vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
 from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str
       from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et, all_tables at
 where vt.owner = et.owner and
       vt.table_name = et.table_name and
       vt.index_type = et.index_type and
       vt.index_field = et.index_field and
       vt.owner = at.owner and
       at.table_name in (vt.table_name, vt.table_name || '_LT')
WITH READ ONLY ;
create or replace view wmsys.all_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv, 'A',  'ACCESS_WORKSPACE',
                        'C',  'CREATE_WORKSPACE',
                        'D',  'REMOVE_WORKSPACE',
                        'F',  'FREEZE_WORKSPACE',
                        'G',  'GRANTPRIV_WORKSPACE',
                        'M',  'MERGE_WORKSPACE',
                        'R',  'ROLLBACK_WORKSPACE',
                        'AA', 'ACCESS_ANY_WORKSPACE',
                        'CA', 'CREATE_ANY_WORKSPACE',
                        'DA', 'REMOVE_ANY_WORKSPACE',
                        'FA', 'FREEZE_ANY_WORKSPACE',
                        'GA', 'GRANTPRIV_ANY_WORKSPACE',
                        'MA', 'MERGE_ANY_WORKSPACE',
                        'RA', 'ROLLBACK_ANY_WORKSPACE',
                        'W',  'WM_ADMIN',
                              'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from wmsys.all_workspaces_internal alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace
WITH READ ONLY ;
create or replace view wmsys.all_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable,
       t.version
from wmsys.wm$workspace_savepoints_table t,
     wmsys.all_workspaces_internal asi,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table$i group by parent_workspace) max,
     (select distinct parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = asi.workspace and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.dba_removed_workspaces as
select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
       createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
from wmsys.wm$removed_workspaces_table rwt
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_REMOVED_WORKSPACES', 'CDB_REMOVED_WORKSPACES');
create or replace view wmsys.dba_wm_sys_privs as
select spt.grantee,
       decode(spt.priv, 'A',  'ACCESS_WORKSPACE',
                        'C',  'CREATE_WORKSPACE',
                        'D',  'REMOVE_WORKSPACE',
                        'F',  'FREEZE_WORKSPACE',
                        'G',  'GRANTPRIV_WORKSPACE',
                        'M',  'MERGE_WORKSPACE',
                        'R',  'ROLLBACK_WORKSPACE',
                        'AA', 'ACCESS_ANY_WORKSPACE',
                        'CA', 'CREATE_ANY_WORKSPACE',
                        'DA', 'REMOVE_ANY_WORKSPACE',
                        'FA', 'FREEZE_ANY_WORKSPACE',
                        'GA', 'GRANTPRIV_ANY_WORKSPACE',
                        'MA', 'MERGE_ANY_WORKSPACE',
                        'RA', 'ROLLBACK_ANY_WORKSPACE',
                        'W',  'WM_ADMIN',
                              'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table spt
where spt.workspace is null
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WM_SYS_PRIVS', 'CDB_WM_SYS_PRIVS');
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name,
       t.owner,
       t.disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(t.notifyWorkspaces, 2, length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.owm_dynsql_access.AreThereConflicts(u.owner, u.view_name, t.vtid) conflict,
       wmsys.owm_dynsql_access.AreThereDiffs(u.owner, u.view_name, t.vtid) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t, dba_views u
where t.owner = u.owner and
      t.table_name = u.view_name
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WM_VERSIONED_TABLES', 'CDB_WM_VERSIONED_TABLES');
create or replace view wmsys.dba_wm_vt_errors as
select decode(vt.owner, 'WMSYS', null, vt.owner) owner,
       decode(vt.owner, 'WMSYS', null, vt.table_name) table_name,
       decode(vt.owner, 'WMSYS', decode(vt.index_type, 10, 'DROP USER COMMAND', 11, 'EXPORT', 12, 'IMPORT', 'UNKNOWN OPERATION'), vt.state) state,
       vt.sql_str, et.status, et.error_msg
from (select t1.owner, t1.table_name, t1.disabling_ver state, nt.index_type, nt.index_field, dbms_lob.substr(nt.sql_str,4000, 1) sql_str
      from wmsys.wm$versioned_tables$h t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et
where (vt.state <> 'HIDDEN' or vt.table_name in ('WM$IMP_EXP', 'WM$LOG_TABLE')) and
      vt.owner = et.owner and
      vt.table_name = et.table_name and
      vt.index_type = et.index_type and
      vt.index_field = et.index_field
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WM_VT_ERRORS', 'CDB_WM_VT_ERRORS');
create or replace view wmsys.dba_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv, 'A',  'ACCESS_WORKSPACE',
                        'C',  'CREATE_WORKSPACE',
                        'D',  'REMOVE_WORKSPACE',
                        'F',  'FREEZE_WORKSPACE',
                        'G',  'GRANTPRIV_WORKSPACE',
                        'M',  'MERGE_WORKSPACE',
                        'R',  'ROLLBACK_WORKSPACE',
                        'AA', 'ACCESS_ANY_WORKSPACE',
                        'CA', 'CREATE_ANY_WORKSPACE',
                        'DA', 'REMOVE_ANY_WORKSPACE',
                        'FA', 'FREEZE_ANY_WORKSPACE',
                        'GA', 'GRANTPRIV_ANY_WORKSPACE',
                        'MA', 'MERGE_ANY_WORKSPACE',
                        'RA', 'ROLLBACK_ANY_WORKSPACE',
                        'W',  'WM_ADMIN',
                              'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspaces_table$i alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WORKSPACE_PRIVS', 'CDB_WORKSPACE_PRIVS');
create or replace view wmsys.dba_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable,
       t.version
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table$i asi,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table$i group by parent_workspace) max,
     (select distinct parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = asi.workspace and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WORKSPACE_SAVEPOINTS', 'CDB_WORKSPACE_SAVEPOINTS');
create or replace view wmsys.dba_workspace_sessions as
select sut.username, sut.workspace, sut.sid, decode(t.ses_addr, null, 'INACTIVE', 'ACTIVE') status, decode(isImplicit, 1, 'YES', 'NO') isImplicit
from wmsys.wm$workspace_sessions_view sut, gv$transaction t
where sut.lockMode = 'S' and sut.inst_id = t.inst_id(+) and sut.saddr = t.ses_addr(+)
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WORKSPACE_SESSIONS', 'CDB_WORKSPACE_SESSIONS');
create or replace view wmsys.dba_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status, 'LOCKED', 'FROZEN', 'UNLOCKED', 'UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode, 'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, 1, instr(asp.freeze_writer, ',')-1), null)) sid,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1,
                                                                   instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1), null)) serial#,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, instr(asp.freeze_writer, ',', 1, 2)+1), null)) inst_id,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
              decode((select 1 from sys.dual
                      where s.sid = sys_context('lt_ctx', 'cid') and
                            s.serial# = sys_context('lt_ctx', 'serial#') and
                            s.inst_id = dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace,null, 'INACTIVE', 'ACTIVE') resolve_status,
       rst.resolve_user,
       mp_root mp_root_workspace
from   wmsys.wm$workspaces_table$d asp, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table rst, gv$session s
where  (asp.freeze_mode is null or asp.freeze_mode <> 'REMOVED') and
       asp.parent_version = ssp.version (+) and
       nvl(ssp.is_implicit,1) = 1 and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1, instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1) and
       to_char(s.inst_id(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
exec cdbview.create_cdbview(false, 'WMSYS', 'DBA_WORKSPACES', 'CDB_WORKSPACES');
create or replace view wmsys.role_wm_privs as
select grantee role,
       workspace,
       decode(priv, 'A',  'ACCESS_WORKSPACE',
                    'C',  'CREATE_WORKSPACE',
                    'D',  'REMOVE_WORKSPACE',
                    'F',  'FREEZE_WORKSPACE',
                    'G',  'GRANTPRIV_WORKSPACE',
                    'M',  'MERGE_WORKSPACE',
                    'R',  'ROLLBACK_WORKSPACE',
                    'AA', 'ACCESS_ANY_WORKSPACE',
                    'CA', 'CREATE_ANY_WORKSPACE',
                    'DA', 'REMOVE_ANY_WORKSPACE',
                    'FA', 'FREEZE_ANY_WORKSPACE',
                    'GA', 'GRANTPRIV_ANY_WORKSPACE',
                    'MA', 'MERGE_ANY_WORKSPACE',
                    'RA', 'ROLLBACK_ANY_WORKSPACE',
                    'W',  'WM_ADMIN',
                          'UNKNOWN_PRIV') privilege,
       decode(admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table
where grantee in (select role from session_roles
                 union all
                  select 'WM_ADMIN_ROLE' from sys.dual where sys_context('userenv', 'current_user') = 'SYS')
WITH READ ONLY ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace graph_workspace,
       decode(mpg.mp_graph_flag, 'R', 'ROOT_WORKSPACE', 'I', 'INTERMEDIATE_WORKSPACE', 'L', 'LEAF_WORKSPACE') graph_flag
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.wm$workspaces_table$i wt
where wt.owner = sys_context('userenv', 'current_user') and
      mpg.mp_leaf_workspace = wt.workspace
WITH READ ONLY ;
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace, mp.parent_workspace, mp.creator, mp.createtime,
       decode(mp.isRefreshed,0, 'NO', 'YES') isRefreshed, decode(mp.parent_flag, 'DP', 'DEFAULT_PARENT', 'ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.wm$workspaces_table$i wt
where wt.owner = sys_context('userenv', 'current_user') and
      mp.workspace = wt.workspace
WITH READ ONLY ;
create or replace view wmsys.user_removed_workspaces as
select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
       createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
from wmsys.wm$removed_workspaces_table rwt
where rwt.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_wm_cons_columns as
select /*+ LEADING(t1) */ t1.owner, t1.constraint_name, t1.table_name, t1.column_name, t1.position
from wmsys.wm$cons_columns t1, user_views t2
where t1.owner = sys_context('userenv', 'current_user') and
      t1.table_name = t2.view_name
WITH READ ONLY ;
create or replace view wmsys.user_wm_constraints as
select /*+ LEADING(ct) */ constraint_name, constraint_type, table_name, search_condition, status, index_owner, index_name, index_type
from wmsys.wm$constraints_table ct, user_views uv
where ct.owner = sys_context('userenv', 'current_user') and
      ct.table_name = uv.view_name
WITH READ ONLY ;
create or replace view wmsys.user_wm_ind_columns as
 select /*+ LEADING(t1) */ t2.index_name, t1.table_name, t2.column_name, t2.column_position, t2.column_length, t2.descend
 from wmsys.wm$constraints_table t1, user_ind_columns t2
 where t1.index_owner = sys_context('userenv', 'current_user') and
       t1.index_name = t2.index_name and
       t1.constraint_type not in ('P', 'PN', 'PU')
union
 select /*+ LEADING(t1) */ t2.index_name, t1.table_name, t2.column_name, t2.column_position-1, t2.column_length, t2.descend
 from wmsys.wm$constraints_table t1, user_ind_columns t2
 where t1.index_owner = sys_context('userenv', 'current_user') and
       t1.index_name = t2.index_name and
       t1.constraint_type in ('P', 'PN', 'PU') and
       t2.column_name not in ('WM_VERSION', 'WM_DELSTATUS')
WITH READ ONLY ;
create or replace view wmsys.user_wm_ind_expressions as
select /*+ LEADING(t1) */ t2.index_name, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, user_ind_expressions t2
where t1.index_owner = sys_context('userenv', 'current_user') and
      t1.index_name = t2.index_name
WITH READ ONLY ;
create or replace view wmsys.user_wm_locked_tables as
select t.owner table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state
from wmsys.wm$all_locks_view t
where t.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_wm_modified_tables as
select table_name, workspace, savepoint
from (select o.table_name, o.workspace,
             nvl(s.savepoint, 'LATEST') savepoint,
             s.is_implicit imp,
             count(*) over (partition by o.table_name, o.workspace, s.version) counter
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s
      where substr(o.table_name, 1, instr(o.table_name, '.')-1) = sys_context('userenv', 'current_user') and
            o.version = s.version (+))
where (imp = 0 or imp is null or counter = 1)
WITH READ ONLY ;
create or replace view wmsys.user_wm_policies as
select object_name, policy_group, policy_name, pf_owner, package, function, sel, ins, upd, del, idx,
       chk_option, enable, static_policy, policy_type, long_predicate
from wmsys.all_wm_policies
where object_owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_wm_ric_info as
select ct_owner, ct_name, pt_owner, pt_name, ric_name, rtrim(ct_cols, ',') ct_cols, rtrim(pt_cols, ',') pt_cols,
       pt_unique_const_name r_constraint_name, my_mode delete_rule, status
from wmsys.wm$ric_table rt, user_views uv
where uv.view_name = rt.ct_name and
      rt.ct_owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_wm_tab_triggers as
select trig_name trigger_name,
       table_owner_name table_owner,
       table_name,
       wmsys.ltUtil.getTrigTypes(trig_flag) trigger_type,
       status,
       when_clause,
       description,
       trig_code trigger_body,
       decode(bitand(event_flag, 32768), 0, 'OFF', 'ON') tab_merge_wo_remove,
       decode(bitand(event_flag, 65536), 0, 'OFF', 'ON') tab_merge_w_remove,
       decode(bitand(event_flag, 131072), 0, 'OFF', 'ON') wspc_merge_wo_remove,
       decode(bitand(event_flag, 262144), 0, 'OFF', 'ON') wspc_merge_w_remove,
       decode(bitand(event_flag, 524288), 0, 'OFF', 'ON') dml,
       decode(bitand(event_flag, 33554432), 0, 'OFF', 'ON') table_import
from wmsys.wm$udtrig_info
where trig_owner_name = sys_context('userenv', 'current_user') and
      internal_type = 'USER_DEFINED'
WITH READ ONLY ;
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.owm_dynsql_access.AreThereConflicts(t.owner, t.table_name, t.vtid) conflict,
       wmsys.owm_dynsql_access.AreThereDiffs(t.owner, t.table_name, t.vtid) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t
where t.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
from (select t1.owner, t1.table_name, t1.disabling_ver state, nt.index_type, nt.index_field, dbms_lob.substr(nt.sql_str,4000,1) sql_str
      from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
     wmsys.wm$vt_errors_table et
where vt.owner = et.owner and
      vt.table_name = et.table_name and
      vt.index_type = et.index_type and
      vt.index_field = et.index_field and
      vt.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv, 'A',  'ACCESS_WORKSPACE',
                        'C',  'CREATE_WORKSPACE',
                        'D',  'REMOVE_WORKSPACE',
                        'F',  'FREEZE_WORKSPACE',
                        'G',  'GRANTPRIV_WORKSPACE',
                        'M',  'MERGE_WORKSPACE',
                        'R',  'ROLLBACK_WORKSPACE',
                        'AA', 'ACCESS_ANY_WORKSPACE',
                        'CA', 'CREATE_ANY_WORKSPACE',
                        'DA', 'REMOVE_ANY_WORKSPACE',
                        'FA', 'FREEZE_ANY_WORKSPACE',
                        'GA', 'GRANTPRIV_ANY_WORKSPACE',
                        'MA', 'MERGE_ANY_WORKSPACE',
                        'RA', 'ROLLBACK_ANY_WORKSPACE',
                        'W',  'WM_ADMIN',
                              'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table spt, wmsys.wm$workspaces_table$i wt
where wt.owner = sys_context('userenv', 'current_user') and
      wt.workspace = spt.workspace
WITH READ ONLY ;
create or replace view wmsys.user_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable,
       t.version
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table$i u,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table$i group by parent_workspace) max,
     (select distinct parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = u.workspace and
      u.owner = sys_context('userenv', 'current_user') and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
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
        when 'NUMBER'    then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.owm_dynsql_access.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
        when 'DATE'      then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.owm_dynsql_access.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
        when 'TIMESTAMP' then (case      nvl(dt.num_buckets, 0) when 0 then 1 when 1 then to_number(wmsys.owm_dynsql_access.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')) else dt.num_buckets end)
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
create or replace view wmsys.wm_compressible_tables as
 select vt.owner, vt.table_name,
        sys_context('lt_ctx', 'compress_workspace') workspace,
        sys_context('lt_ctx', 'compress_beginsp') begin_savepoint,
        sys_context('lt_ctx', 'compress_endsp') end_savepoint
 from wmsys.wm$versioned_tables vt
 where exists
      (select 1
       from wmsys.wm$modified_tables mt
       where mt.table_name = vt.owner || '.' || vt.table_name and
             mt.workspace = sys_context('lt_ctx', 'compress_workspace') and
             mt.version > sys_context('lt_ctx', 'compress_beginver') and
             mt.version <= sys_context('lt_ctx', 'compress_endver') and
             substr(vt.hist,1,17) <> 'VIEW_WO_OVERWRITE' and
             mt.version in
               (select v.version
                from wmsys.wm$version_hierarchy_table v,
                     (select w1.beginver, w2.endver
                      from (select rownum rn,beginver
                            from (select distinct beginver
                                  from (select to_number(sys_context('lt_ctx', 'compress_beginver')) beginver
                                        from sys.dual
                                        where not exists
                                             (select parent_version
                                              from wmsys.wm$workspaces_table
                                              where parent_workspace = sys_context('lt_ctx', 'compress_workspace') and
                                                    to_number(sys_context('lt_ctx', 'compress_beginver')) = parent_version
                                             )
                                       union all
                                        select min(version) beginver
                                        from wmsys.wm$version_hierarchy_table,
                                             (select distinct parent_version
                                              from wmsys.wm$workspaces_table
                                              where parent_workspace = sys_context('lt_ctx', 'compress_workspace') and
                                                    parent_version >= sys_context('lt_ctx', 'compress_beginver') and
                                                    parent_version < sys_context('lt_ctx', 'compress_endver')) pv
                                        where workspace = sys_context('lt_ctx', 'compress_workspace') and
                                              version > pv.parent_version
                                        group by (pv.parent_version)
                                       )
                                  order by beginver
                                 )
                           ) w1,
                          (select rownum rn, endver
                           from (select distinct endver
                                 from (select parent_version endver
                                       from wmsys.wm$workspaces_table
                                       where parent_workspace = sys_context('lt_ctx', 'compress_workspace') and
                                             parent_version > sys_context('lt_ctx', 'compress_beginver') and
                                             parent_version <= sys_context('lt_ctx', 'compress_endver')
                                      union all
                                       select to_number(sys_context('lt_ctx', 'compress_endver')) endver
                                       from sys.dual
                                      )
                                 order by endver
                                )
                          ) w2
                      where w1.rn = w2.rn and
                            w2.endver > w1.beginver
                     ) p
                where v.workspace = sys_context('lt_ctx', 'compress_workspace') and
                      v.version > p.beginver and
                      v.version <= p.endver
               )
      union all
       select 1
       from wmsys.wm$modified_tables mt
       where mt.table_name = vt.owner || '.' || vt.table_name and
             mt.workspace = sys_context('lt_ctx', 'compress_workspace') and
             mt.version >= sys_context('lt_ctx', 'compress_beginver') and
             mt.version <= sys_context('lt_ctx', 'compress_endver') and
             substr(vt.hist,1,17) = 'VIEW_WO_OVERWRITE'
      )
WITH READ ONLY ;
create or replace view wmsys.wm_events_info as
select event_name, capture
from wmsys.wm$events_info
WITH READ ONLY ;
create or replace view wmsys.wm_installation as
 select name, value
 from wmsys.wm$env_vars
 where hidden = 0
union
 select name, value
 from wmsys.wm$sysparam_all_values sv
 where isdefault = 'YES' and
       hidden = 0 and
       not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name)
union
 select 'OWM_VERSION', version from sys.registry$ where cid='OWM'
WITH READ ONLY ;
create or replace view wmsys.wm_replication_info as
select cast(null as varchar2(128)) groupName, cast(null as varchar2(128)) writerSite
from dual
where 1 = 2
WITH READ ONLY ;
@@owmwdmlb.plb
begin
  for vrec in (select do1.object_name
               from dba_objects do1
               where do1.owner = 'WMSYS' and
                     do1.object_type = 'VIEW' and
                     do1.object_name like 'DBA@_%' escape '@' and
                     not exists(select 1
                                from dba_objects do2
                                where do2.owner = 'WMSYS' and
                                      do2.object_type = 'VIEW' and
                                      do2.object_name = 'CDB_' || substr(do1.object_name, 5))) loop
    raise no_data_found ;
  end loop ;
end;
/
@@?/rdbms/admin/sqlsessend.sql
