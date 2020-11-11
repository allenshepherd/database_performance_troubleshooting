@@owmr1220.plb
update wmsys.wm$env_vars$ set value = '12.1.0.1.0' where name = 'OWM_VERSION';
commit ;
revoke read on wmsys.all_mp_graph_workspaces from public ;
revoke read on wmsys.all_mp_parent_workspaces from public ;
revoke read on wmsys.all_removed_workspaces from public ;
revoke read on wmsys.all_version_hview from public ;
revoke read on wmsys.all_wm_constraints from public ;
revoke read on wmsys.all_wm_cons_columns from public ;
revoke read on wmsys.all_wm_ind_columns from public ;
revoke read on wmsys.all_wm_ind_expressions from public ;
revoke read on wmsys.all_wm_locked_tables from public ;
revoke read on wmsys.all_wm_modified_tables from public ;
revoke read on wmsys.all_wm_policies from public ;
revoke read on wmsys.all_wm_ric_info from public ;
revoke read on wmsys.all_wm_tab_triggers from public ;
revoke read on wmsys.all_wm_versioned_tables from public ;
revoke read on wmsys.all_wm_vt_errors from public ;
revoke read on wmsys.all_workspaces from public ;
revoke read on wmsys.all_workspace_privs from public ;
revoke read on wmsys.all_workspace_savepoints from public ;
revoke read on wmsys.role_wm_privs from public ;
revoke read on wmsys.user_mp_graph_workspaces from public ;
revoke read on wmsys.user_mp_parent_workspaces from public ;
revoke read on wmsys.user_removed_workspaces from public ;
revoke read on wmsys.user_wm_constraints from public ;
revoke read on wmsys.user_wm_cons_columns from public ;
revoke read on wmsys.user_wm_ind_columns from public ;
revoke read on wmsys.user_wm_ind_expressions from public ;
revoke read on wmsys.user_wm_locked_tables from public ;
revoke read on wmsys.user_wm_modified_tables from public ;
revoke read on wmsys.user_wm_privs from public ;
revoke read on wmsys.user_wm_policies from public ;
revoke read on wmsys.user_wm_ric_info from public ;
revoke read on wmsys.user_wm_tab_triggers from public ;
revoke read on wmsys.user_wm_versioned_tables from public ;
revoke read on wmsys.user_wm_vt_errors from public ;
revoke read on wmsys.user_workspaces from public ;
revoke read on wmsys.user_workspace_privs from public ;
revoke read on wmsys.user_workspace_savepoints from public ;
revoke read on wmsys.wm_events_info from public ;
revoke read on wmsys.wm_installation from public ;
revoke read on wmsys.wm_replication_info from public ;
grant select on wmsys.all_mp_graph_workspaces to public ;
grant select on wmsys.all_mp_parent_workspaces to public ;
grant select on wmsys.all_removed_workspaces to public ;
grant select on wmsys.all_version_hview to public ;
grant select on wmsys.all_wm_constraints to public ;
grant select on wmsys.all_wm_cons_columns to public ;
grant select on wmsys.all_wm_ind_columns to public ;
grant select on wmsys.all_wm_ind_expressions to public ;
grant select on wmsys.all_wm_locked_tables to public ;
grant select on wmsys.all_wm_modified_tables to public ;
grant select on wmsys.all_wm_policies to public ;
grant select on wmsys.all_wm_ric_info to public ;
grant select on wmsys.all_wm_tab_triggers to public ;
grant select on wmsys.all_wm_versioned_tables to public ;
grant select on wmsys.all_wm_vt_errors to public ;
grant select on wmsys.all_workspaces to public ;
grant select on wmsys.all_workspace_privs to public ;
grant select on wmsys.all_workspace_savepoints to public ;
grant select on wmsys.role_wm_privs to public ;
grant select on wmsys.user_mp_graph_workspaces to public ;
grant select on wmsys.user_mp_parent_workspaces to public ;
grant select on wmsys.user_removed_workspaces to public ;
grant select on wmsys.user_wm_constraints to public ;
grant select on wmsys.user_wm_cons_columns to public ;
grant select on wmsys.user_wm_ind_columns to public ;
grant select on wmsys.user_wm_ind_expressions to public ;
grant select on wmsys.user_wm_locked_tables to public ;
grant select on wmsys.user_wm_modified_tables to public ;
grant select on wmsys.user_wm_privs to public ;
grant select on wmsys.user_wm_policies to public ;
grant select on wmsys.user_wm_ric_info to public ;
grant select on wmsys.user_wm_tab_triggers to public ;
grant select on wmsys.user_wm_versioned_tables to public ;
grant select on wmsys.user_wm_vt_errors to public ;
grant select on wmsys.user_workspaces to public ;
grant select on wmsys.user_workspace_privs to public ;
grant select on wmsys.user_workspace_savepoints to public ;
grant select on wmsys.wm_events_info to public ;
grant select on wmsys.wm_installation to public ;
grant select on wmsys.wm_replication_info to public ;
insert into wmsys.wm$env_vars$ (select 'CONSTRAINT_HASH_TABLE_SIZE', '0', 1
                                from sys.dual
                                where not exists(select 1 from wmsys.wm$env_vars where name = 'CONSTRAINT_HASH_TABLE_SIZE')) ;
insert into wmsys.wm$env_vars$ (select 'DIFF_MODIFIED_ONLY', 'OFF', 1
                                from sys.dual
                                where not exists(select 1 from wmsys.wm$env_vars where name = 'DIFF_MODIFIED_ONLY')) ;
begin
  insert into wmsys.wm$env_vars$ values('CR_WORKSPACE_MODE', 'OPTIMISTIC_LOCKING', 0) ;
exception when dup_val_on_index then null ;
end ;
/
delete wmsys.wm$env_vars$
where name in ('_DYNAMIC_QUERY_REPLACEMENT', '_READERS_BLOCK_DESTRUCTIVE_OPERATIONS', 'CREATEWORKSPACE_SHARED_LOCK', 'DEFAULT_WORKSPACE', 'REMOVEWORKSPACE_DEFERRED', 'REPLICATION_DETAILS') ;
delete wmsys.wm$sysparam_all_values$
where name in ('_DYNAMIC_QUERY_REPLACEMENT', '_READERS_BLOCK_DESTRUCTIVE_OPERATIONS', 'CONSTRAINT_HASH_TABLE_SIZE', 'CREATEWORKSPACE_SHARED_LOCK', 'DEFAULT_WORKSPACE', 'DIFF_MODIFIED_ONLY', 'REMOVEWORKSPACE_DEFERRED') ;
commit ;
update wmsys.wm$workspaces_table$ wt1 set implicit_sp_cnt = (select implicit_sp_cnt from wmsys.wm$workspaces_table wt2 where wt2.workspace = wt1.workspace) ;
update wmsys.wm$workspace_savepoints_table$ wst
set position = (select count(*)+1
                from wmsys.wm$workspace_savepoints_table$ wst2
                where wst2.workspace# = wst.workspace# and
                      (wst2.version < wst.version or (wst2.version = wst.version and wst2.createtime < wst.createtime))) ;
commit ;
drop index wmsys.wm$priv_tab_pk ;
delete wmsys.wm$workspace_priv_table$ where bitand(wm$flag, 31) in (13, 14, 15) ;
update wmsys.wm$workspace_priv_table$ set wm$flag = bitand(wm$flag, 15) + 16 where bitand(wm$flag, 32) = 32 ;
commit ;
alter table wmsys.wm$mp_parent_workspaces_table$ rename column wm$flag to workspace_lock_id  ;
alter table wmsys.wm$mp_parent_workspaces_table$ add (wm$flag  integer) ;
update wmsys.wm$mp_parent_workspaces_table$
set wm$flag = workspace_lock_id,
    workspace_lock_id = workspace# ;
commit ;
create table wmsys.wm$removed_workspaces_table$(
  owner varchar2(128),
  workspace_name varchar2(128) not null,
  workspace_id integer,
  parent_workspace_id integer,
  createtime timestamp with time zone,
  retiretime timestamp with time zone,
  description varchar2(1000),
  mp_root_id integer,
  wm$flag integer) pctfree 0 ;
alter table wmsys.wm$removed_workspaces_table$ add constraint wm$removed_workspaces_pk primary key(workspace_id) ;
create index wmsys.wm$rwt_ws_name on wmsys.wm$removed_workspaces_table$(workspace_name) ;
insert into wmsys.wm$removed_workspaces_table$
  (select owner, workspace, workspace_lock_id, parent_workspace#, createtime, last_change, description, mp_root, decode(bitand(wm$flag, 512), 0, 0, 512, 1)
   from wmsys.wm$workspaces_table$
   where bitand(wm$flag, 14) = 12) ;
delete wmsys.wm$workspaces_table$ where bitand(wm$flag, 14) = 12 ;
commit ;
drop index wmsys.wm$ws_tab_ws_ind ;
alter table wmsys.wm$workspaces_table$ modify (workspace null) ;
alter table wmsys.wm$workspaces_table$ drop constraint wm$workspaces_pk ;
alter table wmsys.wm$workspaces_table$ add constraint wm$workspaces_pk primary key(workspace) ;
alter table wmsys.wm$workspaces_table$ add constraint wm$workspace_lock_id_unq unique(workspace_lock_id) ;
drop view wmsys.wm$workspaces_table$d ;
drop view wmsys.wm$workspaces_table$i ;
drop view wmsys.wm$internal_objects ;
drop view wmsys.wm$migration_error_view ;
drop view wmsys.wm$dba_tab_cols ;
begin
  for srec in (select distinct synonym_name
               from (select synonym_name
                     from dba_synonyms
                     where owner = 'PUBLIC' and
                           table_owner = 'WMSYS'
                    union all
                     select do1.object_name
                     from dba_objects do1, dba_objects do2
                     where do1.owner = 'PUBLIC' and
                           do1.object_type = 'SYNONYM' and
                           do2.owner = 'WMSYS' and
                           do2.object_type in ('OPERATOR', 'TYPE', 'VIEW') and
                           do1.object_name = do2.object_name)
               where synonym_name like 'CDB@_%' escape '@') loop
    execute immediate 'drop public synonym ' || srec.synonym_name ;
  end loop ;

  for vrec in (select object_name view_name
               from dba_objects
               where owner = 'WMSYS' and
                     object_type = 'VIEW' and
                     object_name like 'CDB@_%' escape '@') loop
    execute immediate 'drop view wmsys.' || vrec.view_name ;
  end loop ;
end ;
/
alter table wmsys.wm$versioned_tables$ add(bl_version_ integer, wm$flag_ integer) ;
update wmsys.wm$versioned_tables$
set bl_version_ = bl_version,
    wm$flag_ = wm$flag,
    bl_version = null,
    wm$flag = 0 ;
commit ;
drop index wmsys.wm$ver_tab_bl_version ;
alter table wmsys.wm$versioned_tables$ rename column bl_version to siteslist ;
alter table wmsys.wm$versioned_tables$ rename column wm$flag to repsitecount ;
alter table wmsys.wm$versioned_tables$ rename column wm$flag_ to wm$flag ;
alter table wmsys.wm$versioned_tables$ rename column bl_version_ to bl_version ;
alter table wmsys.wm$versioned_tables$ modify siteslist varchar2(4000) ;
alter table wmsys.wm$versioned_tables$ modify repsitecount default 0;
alter table wmsys.wm$version_table$ modify refcount default 1;
alter table wmsys.wm$workspaces_table$ modify implicit_sp_cnt default 0;
alter table wmsys.wm$workspaces_table$ modify last_change default systimestamp;
create index wmsys.wm$ver_tab_bl_version on wmsys.wm$versioned_tables$(bl_version) ;
begin
  for trec in (select t.table_name
               from wmsys.wm$versioned_tables$ vt, dba_tables t
               where vt.vtid# > 0 and
                     t.owner = 'WMSYS' and
                     t.table_name = 'WM$PK_TMP_TAB_' || vt.vtid# || '$') loop
    execute immediate 'drop table wmsys.' || trec.table_name || ' purge' ;
  end loop ;
end;
/
create table wmsys.wm$replication_details_table$(
  name varchar2(128),
  value varchar2(500)) pctfree 0 ;
create table wmsys.wm$replication_table$(
  groupname varchar2(128),
  masterdefsite varchar2(128),
  oldmasterdefsites varchar2(4000),
  wm$flag integer) ;
alter table wmsys.wm$replication_table$ add constraint wm$rep_details_pk primary key(groupname) ;
insert into wmsys.wm$replication_table$
  (select cast(substr(value, 1, p1-1) as varchar2(128)) groupname,
          cast(substr(value, p1+1, p2-p1-1) as varchar2(128)) masterdefsite,
          cast(substr(value, p2+1) as varchar2(1)) iswritersite,
          cast('E' as varchar2(1)) status
   from (select value, instr(value, '|', 1) p1, instr(value, '|', -1) p2
         from wmsys.wm$env_vars$
         where name = 'REPLICATION_DETAILS')) ;
declare
  cursor vtcur is
    select vtid#, owner, table_name,
           decode(bitand(wm$flag, 224), 0, 'NONE', 32, 'VIEW_W_OVERWRITE', 64, 'VIEW_W_OVERWRITE_PERF',
                                       96, 'VIEW_WO_OVERWRITE', 128, 'VIEW_WO_OVERWRITE_PERF') hist,
           decode(bitand(wm$flag, 256), 0, 0, 256, 1) validtime
    from wmsys.wm$versioned_tables$
    where bitand(wm$flag, 31) not in (0, 2) ;


  already_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_null, -01451);

  no_object EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_object, -04043);
begin
  for vtrec in vtcur loop
    if (vtrec.hist <> 'NONE') then
      begin
        execute immediate 'alter table ' || vtrec.owner || '.' || vtrec.table_name || '_LT modify (wm_createtime null)'  ;
      exception when already_null then null ;
      end;

      if (vtrec.validtime=1)  then
        begin
          execute immediate 'alter table ' || vtrec.owner || '.' || vtrec.table_name || '_VT modify (wm_createtime null)'  ;
        exception when already_null then null ;
        end ;
      end if ;
    end if ;

    begin
      execute immediate 'drop package wmsys.wm$pkg$' || vtrec.vtid# || '$' ;
    exception when no_object then null ;
    end ;
  end loop ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_objects
  where owner = 'SYS' and
        object_name = 'DBMS_DEFER_SYS' and
        object_type = 'PACKAGE' ;

  if (cnt=0) then
    execute immediate
      'create or replace package sys.dbms_defer_sys is end ;' ;
  end if ;

  select count(*) into cnt
  from dba_objects
  where owner = 'SYS' and
        object_name = 'DBMS_REPCAT' and
        object_type = 'PACKAGE' ;

  if (cnt=0) then
    execute immediate
      'create or replace package sys.dbms_repcat is end;' ;
  end if ;
end;
/
revoke select any sequence, alter any sequence, drop any sequence, create any sequence from wmsys ;
revoke insert, delete on sys.noexp$ from wmsys ;
grant create indextype, create operator, create role, create sequence, create session, create type to wmsys ;
grant create public synonym, drop public synonym to wmsys ;
grant execute on sys.dbms_defer_sys to wmsys ;
grant execute on sys.dbms_repcat to wmsys ;
grant inherit privileges on user sys to wmsys ;
drop package wmsys.ltsys ;
drop synonym dbms_wm ;
delete wmsys.wm$hint_table where hint_id in(1358, 2060, 2066, 2076, 2082, 2084, 2090, 2092, 2098, 2100, 2106, 2108, 2114, 2116, 2122, 2124, 2130, 2132, 2138, 2140, 2146, 5201) ;
commit ;
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
102 c2
YkpyXElQbqUzzHReEwntHEMfBmUwgztHLZ7WZy/ps3c6GD6yVGMN7F8gMvT/l4oRWpRGiaGc
tUmscGwaoRLuaDdDl7J9gVhPIBg6Wo5glNCh9LIZFcqhhB+Vx+7PKaVaeAKz2xtiBb4aDcX+
tAb0b9rsSGuD/bF/Rp0u/TC8F4AkS2KXOJWWsjsKah8ggukf

/
drop view wmsys.wm$metadata_map ;
drop table wmsys.wm$metadata_map_tbl ;
drop type wmsys.wm$metadata_map_tab ;
drop type wmsys.wm$metadata_map_type ;
drop view wmsys.wm$column_props ;
create or replace view wmsys.wm$workspaces_table as
select wt1.workspace,
       wt2.workspace parent_workspace,
       wt1.current_version,
       wt1.parent_version,
       wt1.post_version,
       null verlist,
       wt1.owner,
       wt1.createtime,
       wt1.description,
       wt1.workspace_lock_id,
       decode(bitand(wt1.wm$flag, 1), 0, 'UNLOCKED', 1, 'LOCKED') freeze_status,
       decode(bitand(wt1.wm$flag, 14), 0, null, 2, '1WRITER', 4, '1WRITER_SESSION', 6, 'NO_ACCESS', 8, 'READ_ONLY', 10,'WM_ONLY') freeze_mode,
       wt1.freeze_writer,
       null oper_status,
       decode(bitand(wt1.wm$flag, 112), 0, null, 16, 'S', 32, 'E', 48, 'WE', 64, 'VE', 80, 'C') ||
         decode(bitand(wt1.wm$flag, 496),  0, null, ',') ||
         decode(bitand(wt1.wm$flag, 384), 0, null, 128, 'Y', 256, 'N') wm_lockmode,
       decode(bitand(wt1.wm$flag, 512), 0, 0, 1) isRefreshed,
       wt1.freeze_owner,
       decode(bitand(wt1.wm$flag, 1024), 0, 0, 1) session_duration,
       wt1.implicit_sp_cnt,
       decode(bitand(wt1.wm$flag, 6144), 0, 'CRS_ALLCR', 2048, 'CRS_ALLNONCR', 4096, 'CRS_LEAF', 6144, 'CRS_MIXED') cr_status,
       wt1.sync_parver,
       wt1.last_change,
       wt1.depth,
       wt1.mp_root
from wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where wt1.parent_workspace#=wt2.workspace_lock_id(+) ;
create or replace view wmsys.wm$versioned_tables$d as
select vt.vtid# vtid,
       vt.table_name,
       vt.owner,
       decode(bitand(vt.wm$flag, 31), 0, 'UNDEFINED', 1, 'VERSIONED', 2, 'HIDDEN', 3, 'EV', 4, 'LWEV', 5, 'DV', 6, 'LWDV', 7, 'LW_DISABLED', 8, 'DDL',
                                      9, 'BDDL', 10, 'CDDL', 11, 'ODDL', 12, 'TDDL', 13, 'AVTDDL', 14, 'BL_F_BEGIN', 15, 'BL_P_BEGIN', 16, 'BL_P_END',
                                     17, 'BL_R_BEGIN', 18, 'ADD_VT', 19, 'SYNCVTV1', 20, 'SYNCVTV2', 21, 'RB_IND', 22, 'RN_CONS', 23, 'RN_IND',
                                     24, 'D_HIST_COLS', 25, 'U_HIST_COLS') disabling_ver,
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
                                     24, 'D_HIST_COLS', 25, 'U_HIST_COLS') disabling_ver,
       vt.ricweight,
       0 isfastlive,
       0 isworkflow,
       decode(bitand(vt.wm$flag, 224), 0, 'NONE', 32, 'VIEW_W_OVERWRITE', 64, 'VIEW_W_OVERWRITE_PERF',
                                      96, 'VIEW_WO_OVERWRITE', 128, 'VIEW_WO_OVERWRITE_PERF') hist,
       vt.pkey_cols,
       vt.undo_code,
       vt.siteslist,
       vt.repsitecount,
       null bl_workspace,
       vt.bl_version,
       decode(bitand(vt.wm$flag,1536), 0, null, 512, 'ROOT_VERSION', 1024, 'LATEST') bl_savepoint,
       decode(bitand(vt.wm$flag,6144), 0, null, 2048, 'NO', 4096, 'YES') bl_check_for_duplicates,
       decode(bitand(vt.wm$flag,24576), 0, null, 8192, 'NO', 16384, 'YES') bl_single_transaction,
       decode(bitand(vt.wm$flag, 256), 0, 0, 256, 1) validtime
from wmsys.wm$versioned_tables$ vt ;
create or replace view wmsys.wm$versioned_tables as
select vtid, table_name, owner, notification, notifyworkspaces, disabling_ver, ricweight, isfastlive, isworkflow,
       hist, pkey_cols, undo_code, siteslist, repsitecount, bl_workspace, bl_version, bl_savepoint,
       bl_check_for_duplicates, bl_single_transaction, validtime
from wmsys.wm$versioned_tables$h
where disabling_ver<>'HIDDEN' ;
create or replace view wmsys.wm$workspace_savepoints_table as
select wt.workspace,
       wst.savepoint,
       wst.version,
       wst.position,
       decode(bitand(wst.wm$flag, 1), 0, 0, 1, 1) is_implicit,
       wst.owner,
       wst.createtime,
       wst.description
from wmsys.wm$workspace_savepoints_table$ wst, wmsys.wm$workspaces_table$ wt
where wst.workspace#=wt.workspace_lock_id ;
create or replace view wmsys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr, st.inst_id
from gv$lock dl, wmsys.wm$workspaces_table wt, gv$session st
where dl.type    = 'UL' and
      dl.id1 - 1 = wt.workspace_lock_id and
      dl.sid     = st.sid and
      dl.inst_id = st.inst_id
WITH READ ONLY ;
create or replace view wmsys.dba_workspace_sessions as
select sut.username, sut.workspace, sut.sid, decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from wmsys.wm$workspace_sessions_view sut, gv$transaction t
where sut.inst_id = t.inst_id(+) and sut.saddr = t.ses_addr(+)
WITH READ ONLY ;
create or replace view wmsys.wm$sysparam_all_values as
select sav.name, sav.value, decode(bitand(sav.wm$flag, 1), 0, 'NO', 1, 'YES') isdefault
from wmsys.wm$sysparam_all_values$ sav ;
create or replace view wmsys.wm_installation as
 select name, value
 from wmsys.wm$env_vars
 where hidden=0
union
 select name, value
 from wmsys.wm$sysparam_all_values sv
 where isdefault = 'YES' and
       not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name)
union
 select 'OWM_VERSION', version from sys.registry$ where cid='OWM'
WITH READ ONLY ;
create or replace view wmsys.wm$workspace_priv_table as
select wpt.grantee,
       wt.workspace,
       wpt.grantor,
       decode(bitand(wpt.wm$flag, 15), 0, null, 1, 'A', 2, 'C', 3, 'R', 4, 'D', 5, 'M', 6, 'F',
                                                7, 'AA', 8, 'CA', 9, 'RA', 10, 'DA', 11, 'MA', 12, 'FA', 13, 'U') priv,
       decode(bitand(wpt.wm$flag, 16), 0, 0, 16, 1) admin
from wmsys.wm$workspace_priv_table$ wpt, wmsys.wm$workspaces_table$ wt
where wpt.workspace#=wt.workspace_lock_id(+) ;
create or replace view wmsys.user_wm_privs as
select workspace,
       decode(priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',
                   'CA','MERGE_ANY_WORKSPACE',
                   'RA','ROLLBACK_ANY_WORKSPACE',
                   'DA','REMOVE_ANY_WORKSPACE',
                   'MA','CREATE_ANY_WORKSPACE',
                   'FA','FREEZE_ANY_WORKSPACE',
                        'UNKNOWN_PRIV') privilege,
       grantor,
       decode(admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table
where grantee in
   (select role from session_roles
   union all
    select 'WM_ADMIN_ROLE' from dual where sys_context('userenv', 'current_user') = 'SYS'
   union all
    select username from all_users where username=sys_context('userenv', 'current_user')
   union all
    select 'PUBLIC' from dual)
WITH READ ONLY ;
create or replace view wmsys.all_workspaces_internal as
 select s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
        s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
        s.freeze_owner, s.session_duration, s.mp_root
 from wmsys.wm$workspaces_table s
 where exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
 union
 select s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
        s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
       s.freeze_owner, s.session_duration, s.mp_root
 from wmsys.wm$workspaces_table s,
      (select distinct workspace from wmsys.user_wm_privs) u
 where u.workspace = s.workspace
union
 select s.workspace,s.parent_workspace,s.current_version,s.parent_version,s.post_version,s.verlist,s.owner,s.createTime,
        s.description,s.workspace_lock_id,s.freeze_status,s.freeze_mode,s.freeze_writer,s.oper_status,s.wm_lockmode,s.isRefreshed,
        s.freeze_owner, s.session_duration, s.mp_root
from wmsys.wm$workspaces_table s where owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.wm$removed_workspaces_table as
select rwt1.owner,
       rwt1.workspace_name,
       rwt1.workspace_id,
       rwt2.workspace_name parent_workspace_name,
       rwt2.workspace_id parent_workspace_id,
       rwt1.createtime,
       rwt1.retiretime,
       rwt1.description,
       rwt1.mp_root_id,
       decode(bitand(rwt1.wm$flag, 1), 0, 0, 1, 1) isrefreshed
from wmsys.wm$removed_workspaces_table$ rwt1,
     (select workspace_name, workspace_id
      from wmsys.wm$removed_workspaces_table$
     union
      select workspace, workspace_lock_id
      from wmsys.wm$workspaces_table$) rwt2
where rwt1.parent_workspace_id = rwt2.workspace_id(+) ;
create or replace view wmsys.all_removed_workspaces as
 select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
        createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
 from wmsys.wm$removed_workspaces_table rwt
 where exists (select 1 from wmsys.user_wm_privs where privilege like '%ANY%')
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
create or replace view wmsys.all_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',
                   'CA','MERGE_ANY_WORKSPACE',
                   'RA','ROLLBACK_ANY_WORKSPACE',
                   'DA','REMOVE_ANY_WORKSPACE',
                   'MA','CREATE_ANY_WORKSPACE',
                   'FA','FREEZE_ANY_WORKSPACE',
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO',
                         1, 'YES') grantable
from wmsys.all_workspaces_internal alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace
WITH READ ONLY ;
create or replace view wmsys.dba_wm_sys_privs as
select spt.grantee,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                       'C','MERGE_WORKSPACE',
                       'R','ROLLBACK_WORKSPACE',
                       'D','REMOVE_WORKSPACE',
                       'M','CREATE_WORKSPACE',
                       'F','FREEZE_WORKSPACE',
                       'AA','ACCESS_ANY_WORKSPACE',
                       'CA','MERGE_ANY_WORKSPACE',
                       'RA','ROLLBACK_ANY_WORKSPACE',
                       'DA','REMOVE_ANY_WORKSPACE',
                       'MA','CREATE_ANY_WORKSPACE',
                       'FA','FREEZE_ANY_WORKSPACE',
                            'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table spt
where spt.workspace is null
WITH READ ONLY ;
create or replace view wmsys.dba_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                       'C','MERGE_WORKSPACE',
                       'R','ROLLBACK_WORKSPACE',
                       'D','REMOVE_WORKSPACE',
                       'M','CREATE_WORKSPACE',
                       'F','FREEZE_WORKSPACE',
                       'AA','ACCESS_ANY_WORKSPACE',
                       'CA','MERGE_ANY_WORKSPACE',
                       'RA','ROLLBACK_ANY_WORKSPACE',
                       'DA','REMOVE_ANY_WORKSPACE',
                       'MA','CREATE_ANY_WORKSPACE',
                       'FA','FREEZE_ANY_WORKSPACE',
                            'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspaces_table alt, wmsys.wm$workspace_priv_table spt
where alt.workspace = spt.workspace
WITH READ ONLY ;
create or replace view wmsys.role_wm_privs as
select grantee role,
       workspace,
       decode(priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',
                   'CA','MERGE_ANY_WORKSPACE',
                   'RA','ROLLBACK_ANY_WORKSPACE',
                   'DA','REMOVE_ANY_WORKSPACE',
                   'MA','CREATE_ANY_WORKSPACE',
                   'FA','FREEZE_ANY_WORKSPACE',
                        'UNKNOWN_PRIV') privilege,
       decode(admin, 0, 'NO', 1, 'YES') grantable
from wmsys.wm$workspace_priv_table
where grantee in (select role from session_roles
                 union all
                  select 'WM_ADMIN_ROLE' from dual where sys_context('userenv', 'current_user') = 'SYS')
WITH READ ONLY ;
create or replace view wmsys.wm$resolve_workspaces_table as
select wt.workspace, rwt.resolve_user, null undo_sp_name, rwt.undo_sp# undo_sp_ver,
       decode(bitand(rwt.wm$flag, 7), 0, null, 1, '1WRITER', 2, '1WRITER_SESSION', 3, 'NO_ACCESS', 4, 'READ_ONLY', 5, 'WM_ONLY') oldfreezemode,
       rwt.oldfreezewriter
from wmsys.wm$resolve_workspaces_table$ rwt, wmsys.wm$workspaces_table$ wt
where rwt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.user_workspaces as
select st.workspace, st.workspace_lock_id workspace_id, st.parent_workspace, ssp.savepoint parent_savepoint,
       st.owner, st.createTime, st.description,
       decode(st.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(st.oper_status, null, st.freeze_mode,'INTERNAL') freeze_mode,
       decode(st.freeze_mode, '1WRITER_SESSION', s.username, st.freeze_writer) freeze_writer,
       decode(rst.workspace, null, decode(st.session_duration, 0, st.freeze_owner, s.username), null) freeze_owner,
       decode(st.freeze_status, 'UNLOCKED', null, decode(st.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(st.session_duration, 1,
              decode((select 1 from dual
                      where s.sid=sys_context('lt_ctx', 'cid') and
                            s.serial#=sys_context('lt_ctx', 'serial#') and
                            s.inst_id=dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace, null, 'INACTIVE', 'ACTIVE') resolve_status,
       rst.resolve_user,
       decode(st.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(st.wm_lockmode, 1, instr(st.wm_lockmode, ',')-1),
              'S', 'SHARED',
              'E', 'EXCLUSIVE',
              'WE', 'WORKSPACE EXCLUSIVE',
              'VE', 'VERSION EXCLUSIVE',
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(st.wm_lockmode, instr(st.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from wmsys.wm$workspaces_table st,
     wmsys.wm$workspace_savepoints_table ssp,
     wmsys.wm$resolve_workspaces_table rst, gv$session s
where st.owner = sys_context('userenv', 'current_user') and
      (ssp.position is null or ssp.position = (select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version)) and
      st.parent_version = ssp.version (+) and
      st.workspace = rst.workspace (+) and
      to_char(s.sid(+)) = substr(st.freeze_owner, 1, instr(st.freeze_owner, ',')-1)  and
      to_char(s.serial#(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',')+1, instr(st.freeze_owner, ',',1,2)-instr(st.freeze_owner, ',')-1) and
      to_char(s.inst_id(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
create or replace view wmsys.user_workspace_privs as
select spt.grantee,
       spt.workspace,
       decode(spt.priv,'A','ACCESS_WORKSPACE',
                   'C','MERGE_WORKSPACE',
                   'R','ROLLBACK_WORKSPACE',
                   'D','REMOVE_WORKSPACE',
                   'M','CREATE_WORKSPACE',
                   'F','FREEZE_WORKSPACE',
                   'AA','ACCESS_ANY_WORKSPACE',
                   'CA','MERGE_ANY_WORKSPACE',
                   'RA','ROLLBACK_ANY_WORKSPACE',
                   'DA','REMOVE_ANY_WORKSPACE',
                   'MA','CREATE_ANY_WORKSPACE',
                   'FA','FREEZE_ANY_WORKSPACE',
                        'UNKNOWN_PRIV') privilege,
       spt.grantor,
       decode(spt.admin, 0, 'NO', 1, 'YES') grantable
from user_workspaces ult, wmsys.wm$workspace_priv_table spt
where ult.workspace = spt.workspace
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
                         where workspace = sys_context('lt_ctx', 'diffWspc1')),
                     sys_context('lt_ctx', 'diffver1')) version,
              cast(sys_context('lt_ctx', 'diffWspc1_id') as number)
      from dual
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
                          where workspace = sys_context('lt_ctx', 'diffWspc2')),
                     sys_context('lt_ctx', 'diffver2')) version,
              cast(sys_context('lt_ctx', 'diffWspc2_id') as number)
       from dual
       where sys_context('lt_ctx', 'anc_workspace_id') = sys_context('lt_ctx', 'diffWspc2_id')
      ) vt2
WITH READ ONLY ;
create or replace view wmsys.wm$current_nextvers_view as
 select nvt.next_vers, nvt.version
 from wmsys.wm$nextver_table$ nvt
 where nvt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0) and
       nvt.version <= decode(sys_context('lt_ctx', 'version'),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table$
                                    where workspace = 'LIVE'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table$
                                  where workspace = sys_context('lt_ctx', 'state')),
                             sys_context('lt_ctx', 'version'))
union all
 select nvt.next_vers, nvt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$nextver_table$ nvt
 where vt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0) and
       vt.anc_workspace# = nvt.workspace# and
       nvt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff1_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table$
 where workspace# = sys_context('lt_ctx', 'diffWspc1_id') and
       version <= decode(sys_context('lt_ctx', 'diffver1'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table$
                              where workspace = sys_context('lt_ctx', 'diffWspc1')),
                         sys_context('lt_ctx', 'diffver1'))
union all
 select version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'diffWspc1_id') and
       vt.anc_workspace# = vht.workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$diff2_hierarchy_view as
 select version
 from wmsys.wm$version_hierarchy_table$
 where workspace# = sys_context('lt_ctx', 'diffWspc2_id') and
       version <= decode(sys_context('lt_ctx', 'diffver2'),
                         -1, (select current_version
                              from wmsys.wm$workspaces_table$
                              where workspace = sys_context('lt_ctx', 'diffWspc2')),
                         sys_context('lt_ctx', 'diffver2'))
union all
 select version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'diffWspc2_id') and
       vt.anc_workspace# = vht.workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$modified_tables as
select mt.vtid# vtid, vt.owner || '.' || vt.table_name table_name, mt.version, wt.workspace
from wmsys.wm$modified_tables$ mt, wmsys.wm$versioned_tables$ vt, wmsys.wm$workspaces_table$ wt
where mt.vtid#=vt.vtid# and
      mt.workspace# = wt.workspace_lock_id ;
create or replace view wmsys.wm$parconflict_parvers_view as
select mt.version parent_vers, mt.vtid# vtid
from wmsys.wm$modified_tables$ mt, wmsys.wm$workspaces_table$ wt
where mt.workspace# = sys_context('lt_ctx','parent_conflict_state_id') and
      wt.workspace = sys_context('lt_ctx','conflict_state') and
      mt.version >= decode(sign(wt.parent_version - wt.sync_parver), -1, (wt.parent_version+1), sync_parver)
WITH READ ONLY ;
create or replace view wmsys.wm$table_parvers_view as
 select vtid# vtid, mt.version parent_vers
 from wmsys.wm$modified_tables$ mt
 where mt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0) and
       mt.version <= decode(sys_context('lt_ctx', 'version'),
                            null, (select current_version
                                   from wmsys.wm$workspaces_table$
                                   where workspace = 'LIVE'),
                            -1, (select current_version
                                 from wmsys.wm$workspaces_table$
                                 where workspace = sys_context('lt_ctx', 'state')),
                            sys_context('lt_ctx', 'version'))
union all
 select vtid#, mt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$modified_tables$ mt
 where vt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0) and
       vt.anc_workspace# = mt.workspace# and
       mt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$batch_compressible_tables as
select wt.workspace,
       vt.owner || '.' || vt.table_name table_name,
       bct.begin_version,
       bct.end_version,
       bct.where_clause
from wmsys.wm$batch_compressible_tables$ bct, wmsys.wm$workspaces_table$ wt, wmsys.wm$versioned_tables$ vt
where bct.workspace# = wt.workspace_lock_id and
      bct.vtid# = vt.vtid# ;
create or replace view wmsys.wm$lockrows_info as
select wt.workspace, vt.owner, vt.table_name, li.where_clause
from wmsys.wm$lockrows_info$ li, wmsys.wm$workspaces_table$ wt, wmsys.wm$versioned_tables$ vt
where li.vtid#=vt.vtid# and
      li.workspace#=wt.workspace_lock_id ;
create or replace view wmsys.wm$mp_graph_workspaces_table as
select wt1.workspace mp_leaf_workspace, wt2.workspace mp_graph_workspace, mgwt.anc_version,
       decode(bitand(mgwt.wm$flag, 3), 0, 'I', 1, 'L', 2, 'R') mp_graph_flag
from wm$mp_graph_workspaces_table$ mgwt, wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where mgwt.mp_leaf_workspace#=wt1.workspace_lock_id and
      mgwt.mp_graph_workspace#=wt2.workspace_lock_id ;
create or replace view wmsys.wm$mp_parent_workspaces_table as
select wt1.workspace,
       wt2.workspace parent_workspace,
       mpwt.parent_version,
       mpwt.creator,
       mpwt.createtime,
       mpwt.workspace_lock_id,
       decode(bitand(mpwt.wm$flag, 1), 0, 0, 1, 1) isrefreshed,
       decode(bitand(mpwt.wm$flag, 2), 0, 'DP', 2, 'MP') parent_flag
from wm$mp_parent_workspaces_table$ mpwt, wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where mpwt.workspace#=wt1.workspace_lock_id and
      mpwt.parent_workspace#=wt2.workspace_lock_id ;
create or replace view wmsys.wm$mw_table as
select wt.workspace
from wmsys.wm$mw_table$ mt, wmsys.wm$workspaces_table$ wt
where mt.workspace#=wt.workspace_lock_id ;
create or replace view wmsys.wm$nextver_table as
select nt.version, nt.next_vers, wt.workspace, nt.split
from wmsys.wm$nextver_table$ nt, wmsys.wm$workspaces_table$ wt
where nt.workspace#=wt.workspace_lock_id ;
create or replace view wmsys.wm$version_hierarchy_table as
select vht.version, vht.parent_version, wt.workspace
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$ wt
where vht.workspace#=wt.workspace_lock_id ;
create or replace view wmsys.wm$version_table as
select wt1.workspace, wt2.workspace anc_workspace, vt.anc_version, vt.anc_depth, vt.refcount
from wmsys.wm$version_table$ vt, wmsys.wm$workspaces_table$ wt1, wmsys.wm$workspaces_table$ wt2
where vt.workspace#=wt1.workspace_lock_id and
      vt.anc_workspace#=wt2.workspace_lock_id ;
create or replace view wmsys.wm$all_version_hview_wdepth as
select vht.version, vht.parent_version, wt.workspace, vht.workspace# workspace_id, wt.depth
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$ wt
where vht.workspace# = wt.workspace_lock_id
WITH READ ONLY ;
create or replace view wmsys.wm$current_mp_join_points as
select mpwst.mp_leaf_workspace# workspace#, vht.version
from wmsys.wm$mp_graph_workspaces_table$ mpwst, wmsys.wm$workspaces_table$ wt, wmsys.wm$version_hierarchy_table$ vht
where mpwst.mp_graph_workspace# = sys_context('lt_ctx','state_id')  and
      mpwst.mp_leaf_workspace#  = wt.workspace_lock_id and
      wt.workspace_lock_id      = vht.workspace# and
      wt.parent_version         = vht.parent_version
WITH READ ONLY ;
create or replace view wmsys.wm$mp_join_points as
select mpwst.mp_leaf_workspace workspace, vht.version
from wmsys.wm$mp_graph_workspaces_table mpwst, wmsys.wm$workspaces_table wt, wmsys.wm$version_hierarchy_table vht
where mpwst.mp_graph_workspace = sys_context('lt_ctx','new_mp_leaf')  and
      mpwst.mp_leaf_workspace  = wt.workspace                         and
      wt.workspace             = vht.workspace                        and
      wt.parent_version        = vht.parent_version
WITH READ ONLY ;
create or replace view wmsys.all_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(rst.workspace, null, decode(asp.session_duration, 0, asp.freeze_owner, s.username), null) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
              decode((select 1 from dual
                      where s.sid=sys_context('lt_ctx', 'cid') and
                            s.serial#=sys_context('lt_ctx', 'serial#') and
                            s.inst_id=dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace, null, 'INACTIVE', 'ACTIVE') resolve_status,
       rst.resolve_user,
       decode(asp.isRefreshed, 1, 'YES', 'NO') continually_refreshed,
       decode(substr(asp.wm_lockmode, 1, instr(asp.wm_lockmode, ',')-1),
              'S', 'SHARED',
              'E', 'EXCLUSIVE',
              'WE', 'WORKSPACE EXCLUSIVE',
              'VE', 'VERSION EXCLUSIVE',
              'C', 'CARRY', NULL) workspace_lockmode,
       decode(substr(asp.wm_lockmode, instr(asp.wm_lockmode, ',')+1, 1), 'Y', 'YES', 'N', 'NO', NULL) workspace_lockmode_override,
       mp_root mp_root_workspace
from   wmsys.all_workspaces_internal asp, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table rst, gv$session s
where  (ssp.position is null or ssp.position = (select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version)) and
       asp.parent_version = ssp.version (+) and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1, instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1) and
       to_char(s.inst_id(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
create or replace view wmsys.all_version_hview as
select vht.version, vht.parent_version, wt.workspace, vht.workspace# workspace_id
from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$workspaces_table$ wt
where vht.workspace# = wt.workspace_lock_id
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
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table group by parent_workspace) max,
     (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = asi.workspace and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.dba_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS','NO','YES') removable,
       t.version
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table asi,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table group by parent_workspace) max,
     (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = asi.workspace and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.dba_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, 1, instr(asp.freeze_writer, ',')-1), null)) sid,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1,
                                                                   instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1), null)) serial#,
       to_number(decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, instr(asp.freeze_writer, ',', 1, 2)+1), null)) inst_id,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
              decode((select 1 from dual
                      where s.sid=sys_context('lt_ctx', 'cid') and
                            s.serial#=sys_context('lt_ctx', 'serial#') and
                            s.inst_id=dbms_utility.current_instance),
                     1, 'YES', 'NO'),
              null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
       rst.resolve_user,
       mp_root mp_root_workspace
from   wmsys.wm$workspaces_table asp, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table rst, gv$session s
where  nvl(ssp.is_implicit,1) = 1 and
       asp.parent_version = ssp.version (+) and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1, instr(asp.freeze_owner, ',',1,2)-instr(asp.freeze_owner, ',')-1) and
       to_char(s.inst_id(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',', 1, 2)+1)
WITH READ ONLY ;
create or replace view wmsys.user_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable,
       t.version
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table u,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table group by parent_workspace) max,
     (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = u.workspace and
      u.owner = sys_context('userenv', 'current_user') and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.wm$replication_details_table as
select rdt.name, rdt.value
from wmsys.wm$replication_details_table$ rdt ;
create or replace view wmsys.wm$replication_table as
select rt.groupname, rt.masterdefsite, rt.oldmasterdefsites,
       decode(bitand(rt.wm$flag, 1), 0, 'N', 1, 'Y') iswritersite,
       decode(bitand(rt.wm$flag, 2), 0, 'D', 2, 'E') status
from wmsys.wm$replication_table$ rt ;
create or replace view wmsys.wm$modified_tables_view as
select vtid# vtid, version, workspace#
from wmsys.wm$modified_tables$ mt
WITH READ ONLY ;
create or replace view wmsys.wm$mp_graph_other_versions as
 select vht.version, vht.workspace
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where (vt.workspace = sys_context('lt_ctx','new_mp_leaf') and
        vht.workspace = vt.anc_workspace and
        vht.version <= vt.anc_version and
        vt.refCount > 0 and
        vt.anc_workspace not in
              (select sys_context('lt_ctx','new_mp_root')
               from dual
              union all
               select anc_workspace
               from wmsys.wm$version_table root_anc
               where workspace = sys_context('lt_ctx','new_mp_root'))) or
       (vt.anc_workspace = sys_context('lt_ctx','new_mp_leaf') and
        vht.workspace = vt.workspace)
union all
 select vht.version, vht.workspace
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = sys_context('lt_ctx','new_mp_leaf')
union all
 select version, workspace
 from wmsys.wm$mp_graph_cons_versions
WITH READ ONLY ;
create or replace view wmsys.wm$current_child_versions_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
 where
    vht.workspace = vt.workspace and
    vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    vt.anc_version  >= decode(sys_context('lt_ctx','version'),
                               null, (select current_version
                                      from wmsys.wm$workspaces_table
                                      where workspace = 'LIVE'),
                               -1, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = sys_context('lt_ctx','state')),
                               sys_context('lt_ctx','version')
                             )
union all
 select vht.version
 from wmsys.wm$version_hierarchy_table vht
 where vht.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
       vht.version > decode(sys_context('lt_ctx','version'),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = 'LIVE'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table
                                  where workspace = sys_context('lt_ctx','state')),
                             sys_context('lt_ctx','version')
                           )
WITH READ ONLY ;
create or replace view wmsys.wm$current_cons_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers
from wmsys.wm$nextver_table nvt
where (nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
       nvt.version <= decode(sys_context('lt_ctx','version'),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = 'LIVE'),
                             -1, (select current_version
                                  from wmsys.wm$workspaces_table
                                  where workspace = sys_context('lt_ctx','state')),
                             sys_context('lt_ctx','version')
                            ) and
       not (nvl(sys_context('lt_ctx','rowlock_status'),'X') = 'F' and nvl(sys_context('lt_ctx','flip_version'),'N') = 'Y')
      )
      or
      (exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and
                     nvt.workspace = vt.anc_workspace and
                     nvt.version  <= vt.anc_version)
      )
WITH READ ONLY ;
create or replace view wmsys.wm$current_parvers_view as
select vht.version parent_vers
from wmsys.wm$version_hierarchy_table  vht
where (vht.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
       vht.version <= decode(sys_context('lt_ctx','version'),
                             null, (select current_version
                                    from wmsys.wm$workspaces_table
                                    where workspace = 'LIVE'),
                            -1, (select current_version
                                 from wmsys.wm$workspaces_table
                                 where workspace = sys_context('lt_ctx','state')),
                            sys_context('lt_ctx','version'))
      )
      or
      (exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and
                     vht.workspace = vt.anc_workspace and
                     vht.version  <= vt.anc_version )
      )
WITH READ ONLY ;
create or replace view wmsys.wm$current_cons_versions_view as
 select version from wmsys.wm$current_child_versions_view
union all
 select parent_vers from wmsys.wm$current_parvers_view
union all
 select version from wmsys.wm$mp_graph_cons_versions
union all
 select version
 from wmsys.wm$version_hierarchy_table
 where workspace in (select workspace from wmsys.wm$version_table where anc_workspace = sys_context('lt_ctx','state')) and
       (nvl(sys_context('lt_ctx','rowlock_status'),'X') = 'F' and nvl(sys_context('lt_ctx','flip_version'),'N') = 'Y')
WITH READ ONLY ;
create or replace view wmsys.wm$current_workspace_view as
select workspace, parent_workspace, current_version, post_version, verlist, owner, createtime, description,
       workspace_lock_id, freeze_status, freeze_mode, freeze_writer, oper_status, wm_lockmode, isrefreshed, freeze_owner,
       session_duration, implicit_sp_cnt, cr_status, sync_parver, last_change
from wmsys.wm$workspaces_table
where workspace = nvl(sys_context('lt_ctx','state'),'LIVE')
WITH READ ONLY ;
create or replace view wmsys.wm$parvers_view as
 select version parent_vers
 from wmsys.wm$version_hierarchy_table$
 where workspace# = nvl(sys_context('lt_ctx','state_id'), 0)
union all
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht, wmsys.wm$version_table$ vt
 where vt.workspace# = nvl(sys_context('lt_ctx','state_id'), 0) and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$table_ws_parvers_view as
 select vtid# vtid, mt.version parent_vers
 from wmsys.wm$modified_tables$ mt
 where mt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0)
union all
 select vtid#, mt.version
 from wmsys.wm$version_table$ vt, wmsys.wm$modified_tables$ mt
 where vt.workspace# = nvl(sys_context('lt_ctx', 'state_id'), 0) and
       vt.anc_workspace# = mt.workspace# and
       mt.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm_compress_batch_sizes as
select /*+ RULE */ vt.owner, vt.table_name,
       decode(dt.data_type,
              'CHAR',decode(dt.num_buckets,null,'TABLE',0,'TABLE',1,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
              'VARCHAR2',decode(dt.num_buckets,null,'TABLE',0,'TABLE',1,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
              'NUMBER',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
              'DATE',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
              'TIMESTAMP',decode(dt.num_buckets,null,'TABLE',0,'TABLE','TABLE/PRIMARY_KEY_RANGE'),
              'TABLE') batch_size,
       decode(dt.data_type,
              'CHAR',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets),
              'VARCHAR2',decode(dt.num_buckets,null,1,0,1,1,1,dt.num_buckets),
              'NUMBER',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
              'DATE',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
              'TIMESTAMP',decode(dt.num_buckets,null,1,0,1,1,(wmsys.ltadm.GetSystemParameter('NUMBER_OF_COMPRESS_BATCHES')),dt.num_buckets),
              1) num_batches
from wmsys.wm$versioned_tables vt, dba_ind_columns di, dba_tab_columns dt
where di.table_owner = vt.owner and
      di.table_name = vt.table_name || '_LT' and
      di.index_name = vt.table_name || '_PKI$' and
      di.column_position = 1 and
      dt.owner = vt.owner and
      dt.table_name = vt.table_name || '_LT' and
      dt.column_name = di.column_name
WITH READ ONLY ;
create or replace view wmsys.wm_compressible_tables as
 select vt.owner, vt.table_name,
        sys_context('lt_ctx','compress_workspace') workspace,
        sys_context('lt_ctx','compress_beginsp') begin_savepoint,
        sys_context('lt_ctx','compress_endsp') end_savepoint
 from wmsys.wm$versioned_tables vt
 where exists
      (select 1
       from wmsys.wm$modified_tables mt
       where mt.table_name = vt.owner || '.' || vt.table_name and
             mt.workspace = sys_context('lt_ctx','compress_workspace') and
             mt.version > sys_context('lt_ctx','compress_beginver') and
             mt.version <= sys_context('lt_ctx','compress_endver') and
             substr(vt.hist,1,17) != 'VIEW_WO_OVERWRITE' and
             mt.version in
               (select v.version
                from wmsys.wm$version_hierarchy_table v,
                     (select w1.beginver, w2.endver
                      from (select rownum rn,beginver
                            from (select distinct beginver
                                  from (select to_number(sys_context('lt_ctx','compress_beginver')) beginver
                                        from dual
                                        where not exists
                                             (select parent_version
                                              from wmsys.wm$workspaces_table
                                              where parent_workspace = sys_context('lt_ctx','compress_workspace') and
                                                    to_number(sys_context('lt_ctx','compress_beginver')) = parent_version
                                             )
                                       union all
                                        select min(version) beginver
                                        from wmsys.wm$version_hierarchy_table,
                                             (select distinct parent_version
                                              from wmsys.wm$workspaces_table
                                              where parent_workspace = sys_context('lt_ctx','compress_workspace') and
                                                    parent_version >= sys_context('lt_ctx','compress_beginver') and
                                                    parent_version < sys_context('lt_ctx','compress_endver')) pv
                                        where workspace = sys_context('lt_ctx','compress_workspace') and
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
                                       where parent_workspace = sys_context('lt_ctx','compress_workspace') and
                                             parent_version > sys_context('lt_ctx','compress_beginver') and
                                             parent_version <= sys_context('lt_ctx','compress_endver')
                                      union all
                                       select to_number(sys_context('lt_ctx','compress_endver')) endver
                                       from dual
                                      )
                                 order by endver
                                )
                          ) w2
                      where w1.rn = w2.rn and
                            w2.endver > w1.beginver
                     ) p
                where v.workspace = sys_context('lt_ctx','compress_workspace') and
                      v.version > p.beginver and
                      v.version <= p.endver
               )
      union all
       select 1
       from wmsys.wm$modified_tables mt
       where mt.table_name = vt.owner || '.' || vt.table_name and
             mt.workspace = sys_context('lt_ctx','compress_workspace') and
             mt.version >= sys_context('lt_ctx','compress_beginver') and
             mt.version <= sys_context('lt_ctx','compress_endver') and
             substr(vt.hist,1,17) = 'VIEW_WO_OVERWRITE'
      )
WITH READ ONLY ;
create or replace view wmsys.wm_replication_info as
select groupName, masterdefsite writerSite
from wmsys.wm$replication_table
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
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t, dba_views u
where t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY ;
create or replace view wmsys.all_wm_versioned_tables as
select /*+ LEADING(t) */ t.table_name, t.owner,
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_views av
 where t.table_name = av.view_name and t.owner = av.owner
union all
 select /*+ LEADING(t) */ t.table_name, t.owner,
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_tables at
 where t.table_name = at.table_name and t.owner = at.owner
WITH READ ONLY ;
create or replace view wmsys.user_wm_versioned_tables as
select t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from wmsys.wm$versioned_tables t
where t.owner = sys_context('userenv', 'current_user')
WITH READ ONLY ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace graph_workspace,
       decode(mpg.mp_graph_flag,'R', 'ROOT_WORKSPACE', 'I', 'INTERMEDIATE_WORKSPACE', 'L', 'LEAF_WORKSPACE') graph_flag
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.user_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace
WITH READ ONLY ;
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
       decode(mp.isRefreshed,0,'NO','YES') IsRefreshed, decode(mp.parent_flag, 'DP', 'DEFAULT_PARENT', 'ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.user_workspaces uw
where mp.workspace = uw.workspace
WITH READ ONLY ;
create or replace view wmsys.wm$conf1_hierarchy_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht
 where vht.workspace# = sys_context('lt_ctx', 'conflict_state_id')
union all
 select vht.version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'conflict_state_id') and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
create or replace view wmsys.wm$conf2_hierarchy_view as
 select vht.version
 from wmsys.wm$version_hierarchy_table$ vht
 where vht.workspace# = sys_context('lt_ctx', 'parent_conflict_state_id')
union all
 select vht.version
 from wmsys.wm$version_table$ vt, wmsys.wm$version_hierarchy_table$ vht
 where vt.workspace# = sys_context('lt_ctx', 'parent_conflict_state_id') and
       vht.workspace# = vt.anc_workspace# and
       vht.version <= vt.anc_version
WITH READ ONLY ;
