@@owmr1210.plb
create table wmsys.wm$adt_func_table(
  func_name varchar2(30),
  type_name varchar2(68),
  ref_count number);
create or replace function resolveTypeSynonym wrapped 
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
8
46f 20f
rSB1M72clodEFHNvLPetcLXKq9Ywgzu3LvbWZy9AEjPqRy5ia6CtjTkoHnsbrP+XRd/X+l5I
eQmjFjabhpiYPxRILhFrrFb/wdrQ2t4ucQGsjwv4vqpzg+Vq+GF7ijOYaroO32zf4C4WExcb
NZ3PlV3POTw12N33ADb05achBMoKeqbcnmhJ7wIMiZnNK+kxV/BA4a9q5H92RLIuSazlsr2D
jiZNPin9leZdhedBZlqTh+4VbVJY90q5rpAHrcBEGJVCsOA8EHVIYAp1aa34PpcrDGMWyvST
6/om2DLt5vRwt6jhF4dg9L/g60MN14x/HgLBkAKgt/yzidizRaUCC96qsEhaZ1GhdeAu/U3Y
Jv/HHZk+LYiTnvu9KsWIg2kFKaIpna1MZkPCm9l7/4K52ok/lSmeJp1L/BExhB39U0xwPFIG
g9isBUtEjMRwzwBfGSaYUnPAdF7L9/+FYJwxU+e5chQ1ney2BZ96rKrBE4bBp7LrE0XLN7wG
lSfcbGqli/2taRzj

/
insert into wmsys.wm$adt_func_table
(select rownum, type_name, c
 from (select type_name, count(*) c
       from wmsys.wm$versioned_tables vt,
            (select owner, table_name, resolveTypeSynonym(data_type_owner, data_type) type_name
             from dba_tab_cols
             where data_type_owner is not null and
                   user_generated = 'YES'
            ) dtc
       where vt.owner = dtc.owner and
             vt.table_name || '_LT' = dtc.table_name
       group by type_name
       order by type_name)) ;
commit;
drop function resolveTypeSynonym ;
declare
  adt_max integer ;
begin
  select nvl(max(to_number(func_name))+1, 1) into adt_max
  from wmsys.wm$adt_func_table ;

  execute immediate 'create sequence wmsys.wm$adt_sequence start with ' || adt_max || ' nocache' ;
end;
/
alter table wmsys.wm$adt_func_table add constraint wm$adt_func_tab_pk primary key(type_name);
create table wmsys.wm$batch_compressible_tables#(
  workspace varchar2(30),
  table_name varchar2(65),
  begin_version integer,
  end_version integer,
  where_clause varchar2(4000));
insert into wmsys.wm$batch_compressible_tables#(select workspace,table_name,begin_version,end_version,where_clause from wmsys.wm$batch_compressible_tables);
commit;
drop view wmsys.wm$batch_compressible_tables;
drop table wmsys.wm$batch_compressible_tables$ purge;
alter table wmsys.wm$batch_compressible_tables# rename to wm$batch_compressible_tables;
create index wmsys.wm$bct_idx on wmsys.wm$batch_compressible_tables(workspace, table_name);
create table wmsys.wm$constraints_table#(
  owner varchar2(30),
  constraint_name varchar2(30),
  constraint_type varchar2(2),
  table_name varchar2(30),
  search_condition clob,
  status varchar2(8),
  index_owner varchar2(30),
  index_name varchar2(30),
  index_type varchar2(40),
  aliasedcolumns clob,
  numindexcols integer);
insert into wmsys.wm$constraints_table#(select owner,constraint_name,constraint_type,table_name,search_condition,status,index_owner,index_name,index_type,aliasedcolumns,numindexcols from wmsys.wm$constraints_table);
commit;
drop view wmsys.wm$constraints_table;
drop table wmsys.wm$constraints_table$ purge;
alter table wmsys.wm$constraints_table# rename to wm$constraints_table;
alter table wmsys.wm$constraints_table add constraint wm$constraints_table_pk primary key(owner, constraint_name, status);
create index wmsys.wm$constraints_table_tab_idx on wmsys.wm$constraints_table(owner, table_name);
create table wmsys.wm$cons_columns#(
  owner varchar2(30),
  constraint_name varchar2(30),
  table_name varchar2(30),
  column_name varchar2(4000),
  position number);
insert into wmsys.wm$cons_columns#(select owner,constraint_name,table_name,column_name,position from wmsys.wm$cons_columns);
commit;
drop view wmsys.wm$cons_columns;
drop table wmsys.wm$cons_columns$ purge;
alter table wmsys.wm$cons_columns# rename to wm$cons_columns;
create index wmsys.wm$cons_columns_idx on wmsys.wm$cons_columns(owner, constraint_name);
create table wmsys.wm$env_vars#(
  name varchar2(100),
  value varchar2(4000),
  hidden integer default 0);
insert into wmsys.wm$env_vars#(select name,value,hidden from wmsys.wm$env_vars);
commit;
drop view wmsys.wm$env_vars;
drop table wmsys.wm$env_vars$ purge;
alter table wmsys.wm$env_vars# rename to wm$env_vars;
alter table wmsys.wm$env_vars add constraint wm$env_vars_pk primary key(name);
create table wmsys.wm$events_info#(
  event_name varchar2(30),
  capture varchar2(10));
insert into wmsys.wm$events_info#(select event_name,capture from wmsys.wm$events_info);
commit;
drop view wmsys.wm$events_info;
drop table wmsys.wm$events_info$ purge;
alter table wmsys.wm$events_info# rename to wm$events_info;
alter table wmsys.wm$events_info add primary key(event_name);
drop table wmsys.wm$hash_table$ purge;
drop view wmsys.wm$hash_table ;
create table wmsys.wm$hint_table#(
  hint_id integer,
  owner varchar2(30),
  table_name varchar2(30),
  hint_text varchar2(4000),
  isdefault integer);
insert into wmsys.wm$hint_table#(select hint_id,owner,table_name,hint_text,isdefault from wmsys.wm$hint_table);
commit;
drop view wmsys.wm$hint_table;
drop table wmsys.wm$hint_table$ purge;
alter table wmsys.wm$hint_table# rename to wm$hint_table;
alter table wmsys.wm$hint_table add constraint hint_table_unq1 unique(hint_id, owner, table_name, isdefault);
create table wmsys.wm$insteadof_trigs_table#(
  table_owner varchar2(40),
  table_name varchar2(40),
  insert_trig_name varchar2(40),
  update_trig_name varchar2(40),
  delete_trig_name varchar2(40));
insert into wmsys.wm$insteadof_trigs_table#(select owner,table_name,'OVM_Insert_'||vtid,'OVM_Update_'||vtid,'OVM_Delete_'||vtid from wmsys.wm$versioned_tables);
commit;
begin
  for mrec in (select nvl(max(vtid)+1, 1) max_vtid from wmsys.wm$versioned_tables) loop
    execute immediate 'create sequence wmsys.wm$insteadof_trigs_sequence start with ' || mrec.max_vtid || ' nocache' ;
  end loop ;
end;
/
drop view wmsys.wm$insteadof_trigs_table;
alter table wmsys.wm$insteadof_trigs_table# rename to wm$insteadof_trigs_table;
alter table wmsys.wm$insteadof_trigs_table add constraint wm$insteadof_trigs_pk primary key(table_owner, table_name);
create table wmsys.wm$lockrows_info#(
  workspace varchar2(30),
  owner varchar2(30),
  table_name varchar2(30),
  where_clause clob);
insert into wmsys.wm$lockrows_info#(select workspace,owner,table_name,where_clause from wmsys.wm$lockrows_info);
commit;
drop view wmsys.wm$lockrows_info;
drop table wmsys.wm$lockrows_info$ purge;
alter table wmsys.wm$lockrows_info# rename to wm$lockrows_info;
create index wmsys.wm$lockrows_info_idx on wmsys.wm$lockrows_info(workspace);
create table wmsys.wm$log_table(
  group# integer,
  order# integer,
  owner varchar2(30),
  sql_str clob);
alter table wmsys.wm$log_table add constraint log_tab_pk primary key(group#, order#);
create table wmsys.wm$log_table_errors(
  group# integer,
  order# integer,
  status varchar2(100),
  error_msg varchar2(200));
alter table wmsys.wm$log_table_errors add primary key(group#);
create table wmsys.wm$modified_tables#(
  vtid integer,
  table_name varchar2(61),
  version integer,
  workspace varchar2(30));
insert into wmsys.wm$modified_tables#(select vtid,table_name,version,workspace from wmsys.wm$modified_tables);
commit;
drop view wmsys.wm$modified_tables;
drop table wmsys.wm$modified_tables$ purge;
alter table wmsys.wm$modified_tables# rename to wm$modified_tables;
alter table wmsys.wm$modified_tables add constraint modified_tables_pk primary key(workspace, table_name, version);
create index wmsys.wm$mod_tab_ver_ind on wmsys.wm$modified_tables(version, workspace);
create table wmsys.wm$mp_graph_workspaces_table#(
  mp_leaf_workspace varchar2(30),
  mp_graph_workspace varchar2(30),
  anc_version integer,
  mp_graph_flag varchar2(1));
insert into wmsys.wm$mp_graph_workspaces_table#(select mp_leaf_workspace,mp_graph_workspace,anc_version,mp_graph_flag from wmsys.wm$mp_graph_workspaces_table);
commit;
drop view wmsys.wm$mp_graph_workspaces_table;
drop table wmsys.wm$mp_graph_workspaces_table$ purge;
alter table wmsys.wm$mp_graph_workspaces_table# rename to wm$mp_graph_workspaces_table;
alter table wmsys.wm$mp_graph_workspaces_table add constraint wm$mp_graph_workspaces_pk primary key(mp_leaf_workspace, mp_graph_workspace);
create index wmsys.wm$mp_graph_workspace_idx on wmsys.wm$mp_graph_workspaces_table(mp_graph_workspace);
create table wmsys.wm$mp_parent_workspaces_table#(
  workspace varchar2(30),
  parent_workspace varchar2(30),
  parent_version integer,
  creator varchar2(30),
  createtime date,
  workspace_lock_id integer,
  isrefreshed integer,
  parent_flag varchar2(2));
insert into wmsys.wm$mp_parent_workspaces_table#(select workspace,parent_workspace,parent_version,creator,createtime,workspace_lock_id,isrefreshed,parent_flag from wmsys.wm$mp_parent_workspaces_table);
commit;
drop view wmsys.wm$mp_parent_workspaces_table;
drop table wmsys.wm$mp_parent_workspaces_table$ purge;
alter table wmsys.wm$mp_parent_workspaces_table# rename to wm$mp_parent_workspaces_table;
alter table wmsys.wm$mp_parent_workspaces_table add constraint wm$mp_parent_pk primary key(workspace, parent_workspace);
create index wmsys.wm$mp_pws_tab_pver_ind on wmsys.wm$mp_parent_workspaces_table(parent_version);
create index wmsys.wm$mp_pws_tab_pws_ind on wmsys.wm$mp_parent_workspaces_table(parent_workspace);
create global temporary table wmsys.wm$mw_table#(
  workspace varchar2(30)) on commit preserve rows;
insert into wmsys.wm$mw_table#(select workspace from wmsys.wm$mw_table);
commit;
drop view wmsys.wm$mw_table;
drop table wmsys.wm$mw_table$ purge;
alter table wmsys.wm$mw_table# rename to wm$mw_table;
create table wmsys.wm$nested_columns_table#(
  owner varchar2(30),
  table_name varchar2(30),
  column_name varchar2(30),
  position integer,
  type_owner varchar2(30),
  type_name varchar2(30),
  nt_owner varchar2(30),
  nt_name varchar2(30),
  nt_store varchar2(30));
insert into wmsys.wm$nested_columns_table#(select owner,table_name,column_name,position,type_owner,type_name,nt_owner,nt_name,nt_store from wmsys.wm$nested_columns_table);
commit;
drop view wmsys.wm$nested_columns_table;
drop table wmsys.wm$nested_columns_table$ purge;
alter table wmsys.wm$nested_columns_table# rename to wm$nested_columns_table;
alter table wmsys.wm$nested_columns_table add constraint wm$nested_columns_pk primary key(owner, table_name, column_name);
create table wmsys.wm$nextver_table#(
  version integer,
  next_vers varchar2(500),
  workspace varchar2(30),
  split integer);
insert into wmsys.wm$nextver_table#(select version,next_vers,workspace,split from wmsys.wm$nextver_table);
commit;
drop view wmsys.wm$nextver_table;
drop table wmsys.wm$nextver_table$ purge;
alter table wmsys.wm$nextver_table# rename to wm$nextver_table;
create unique index wmsys.wm$nextver_table_nv_indx on wmsys.wm$nextver_table(next_vers, version, workspace);
create index wmsys.wm$nextver_table_indx on wmsys.wm$nextver_table(version, next_vers);
create table wmsys.wm$removed_workspaces_table#(
  owner varchar2(30),
  workspace_name varchar2(30),
  workspace_id integer,
  parent_workspace_name varchar2(30),
  parent_workspace_id integer,
  createtime date,
  retiretime date,
  description varchar2(1000),
  mp_root_id integer,
  isrefreshed integer);
insert into wmsys.wm$removed_workspaces_table#(select owner,workspace_name,workspace_id,parent_workspace_name,parent_workspace_id,createtime,retiretime,description,mp_root_id,isrefreshed from wmsys.wm$removed_workspaces_table);
commit;
drop view wmsys.wm$removed_workspaces_table;
drop table wmsys.wm$removed_workspaces_table$ purge;
alter table wmsys.wm$removed_workspaces_table# rename to wm$removed_workspaces_table;
alter table wmsys.wm$removed_workspaces_table add constraint removed_workspaces_pk primary key(workspace_id);
create table wmsys.wm$replication_details_table#(
  name varchar2(100),
  value varchar2(500));
insert into wmsys.wm$replication_details_table#(select name,value from wmsys.wm$replication_details_table);
commit;
drop view wmsys.wm$replication_details_table;
drop table wmsys.wm$replication_details_table$ purge;
alter table wmsys.wm$replication_details_table# rename to wm$replication_details_table;
create table wmsys.wm$replication_table#(
  groupname varchar2(30),
  masterdefsite varchar2(128),
  oldmasterdefsites varchar2(4000),
  iswritersite varchar2(1),
  status varchar2(1) default 'E');
insert into wmsys.wm$replication_table#(select groupname,masterdefsite,oldmasterdefsites,iswritersite,status from wmsys.wm$replication_table);
commit;
drop view wmsys.wm$replication_table;
drop table wmsys.wm$replication_table$ purge;
alter table wmsys.wm$replication_table# rename to wm$replication_table;
alter table wmsys.wm$replication_table add primary key(groupname);
create table wmsys.wm$resolve_workspaces_table#(
  workspace varchar2(30),
  resolve_user varchar2(30),
  undo_sp_name varchar2(30),
  undo_sp_ver integer,
  oldfreezemode varchar2(30),
  oldfreezewriter varchar2(30));
insert into wmsys.wm$resolve_workspaces_table#(select workspace,resolve_user,'ICP-'||undo_sp_ver,undo_sp_ver,oldfreezemode,oldfreezewriter from wmsys.wm$resolve_workspaces_table);
commit;
drop view wmsys.wm$resolve_workspaces_table;
drop table wmsys.wm$resolve_workspaces_table$ purge;
alter table wmsys.wm$resolve_workspaces_table# rename to wm$resolve_workspaces_table;
alter table wmsys.wm$resolve_workspaces_table add constraint wm$resolve_workspaces_pk primary key(workspace);
create table wmsys.wm$ric_locking_table#(
  pt_owner varchar2(30),
  pt_name varchar2(30),
  slockno integer,
  elockno integer);
insert into wmsys.wm$ric_locking_table#(select pt_owner,pt_name,slockno,elockno from wmsys.wm$ric_locking_table);
commit;
drop view wmsys.wm$ric_locking_table;
drop table wmsys.wm$ric_locking_table$ purge;
alter table wmsys.wm$ric_locking_table# rename to wm$ric_locking_table;
create table wmsys.wm$ric_table#(
  ct_owner varchar2(40),
  ct_name varchar2(40),
  pt_owner varchar2(40),
  pt_name varchar2(40),
  ric_name varchar2(40),
  ct_cols varchar2(4000),
  pt_cols varchar2(4000),
  pt_unique_const_name varchar2(40),
  my_mode varchar2(2),
  status varchar2(8));
insert into wmsys.wm$ric_table#(select ct_owner,ct_name,pt_owner,pt_name,ric_name,ct_cols,pt_cols,pt_unique_const_name,my_mode,status from wmsys.wm$ric_table);
commit;
drop view wmsys.wm$ric_table;
drop table wmsys.wm$ric_table$ purge;
alter table wmsys.wm$ric_table# rename to wm$ric_table;
alter table wmsys.wm$ric_table add constraint wm$ric_pk primary key(ct_owner, ric_name);
create index wmsys.wm$ric_table_pt_idx on wmsys.wm$ric_table(pt_owner, pt_name);
create index wmsys.wm$ric_table_ct_idx on wmsys.wm$ric_table(ct_owner, ct_name);
declare
  nonexistent_trig  EXCEPTION;
  PRAGMA            EXCEPTION_INIT(nonexistent_trig, -04080);
begin
  for trec in (select pt_owner, update_trigger_name, delete_trigger_name from wmsys.wm$ric_triggers_table) loop
    begin
      execute immediate 'drop trigger ' || trec.update_trigger_name ;
    exception when nonexistent_trig then null;
    end;

    begin
      execute immediate 'drop trigger ' || trec.delete_trigger_name ;
    exception when nonexistent_trig then null;
    end;
  end loop;
end;
/
create table wmsys.wm$ric_triggers_table#(
  pt_owner varchar2(40),
  pt_name varchar2(40),
  ct_owner varchar2(40),
  ct_name varchar2(40),
  update_trigger_name varchar2(40),
  delete_trigger_name varchar2(40));
insert into wmsys.wm$ric_triggers_table#(select pt_owner,pt_name,ct_owner,ct_name,'LT_AU_'||(to_number(regexp_substr(update_trigger_name, '[[:digit:]]+$'))*2),'LT_AD_'||(to_number(regexp_substr(delete_trigger_name, '[[:digit:]]+$'))*2-1) from wmsys.wm$ric_triggers_table);
commit;
drop view wmsys.wm$ric_triggers_table;
drop table wmsys.wm$ric_triggers_table$ purge;
alter table wmsys.wm$ric_triggers_table# rename to wm$ric_triggers_table;
alter table wmsys.wm$ric_triggers_table add constraint wm$ric_triggers_pk primary key(pt_owner, pt_name, ct_owner, ct_name);
create table wmsys.wm$sysparam_all_values#(
  name varchar2(100),
  value varchar2(512),
  isdefault varchar2(9));
insert into wmsys.wm$sysparam_all_values#(select name,value,isdefault from wmsys.wm$sysparam_all_values);
commit;
drop view wmsys.wm$sysparam_all_values;
drop table wmsys.wm$sysparam_all_values$ purge;
alter table wmsys.wm$sysparam_all_values# rename to wm$sysparam_all_values;
alter table wmsys.wm$sysparam_all_values add constraint wm$env_sys_pk primary key(name, value);
create table wmsys.wm$tmp_dba_constraints(
  owner varchar2(30),
  table_name varchar2(30),
  constraint_name varchar2(30),
  constraint_type varchar2(30),
  r_constraint_name varchar2(30),
  r_owner varchar2(30));
create index wmsys.wm$tmp_dba_cons_ind on wmsys.wm$tmp_dba_constraints(owner, table_name);
create table wmsys.wm$udtrig_dispatch_procs#(
  table_owner_name varchar2(50),
  table_name varchar2(50),
  dispatcher_name varchar2(50),
  trig_flag integer);
insert into wmsys.wm$udtrig_dispatch_procs#(select table_owner_name,table_name,dispatcher_name,trig_flag from wmsys.wm$udtrig_dispatch_procs);
commit;
drop view wmsys.wm$udtrig_dispatch_procs;
drop table wmsys.wm$udtrig_dispatch_procs$ purge;
alter table wmsys.wm$udtrig_dispatch_procs# rename to wm$udtrig_dispatch_procs;
alter table wmsys.wm$udtrig_dispatch_procs add constraint wm$udtrig_dispatch_procs_pk primary key(table_owner_name, table_name);
create table wmsys.wm$udtrig_info#(
  trig_owner_name varchar2(50),
  trig_name varchar2(50),
  table_owner_name varchar2(50),
  table_name varchar2(50),
  trig_flag integer,
  status varchar2(10),
  trig_procedure varchar2(50),
  when_clause varchar2(4000),
  description varchar2(4000),
  trig_code clob,
  internal_type varchar2(50) default 'USER_DEFINED',
  event_flag integer);
insert into wmsys.wm$udtrig_info#(select trig_owner_name,trig_name,table_owner_name,table_name,trig_flag,status,trig_procedure,when_clause,description,trig_code,internal_type,event_flag from wmsys.wm$udtrig_info);
commit;
drop view wmsys.wm$udtrig_info;
drop table wmsys.wm$udtrig_info$ purge;
alter table wmsys.wm$udtrig_info# rename to wm$udtrig_info;
alter table wmsys.wm$udtrig_info add constraint wm$udtrig_info_pk primary key(trig_owner_name, trig_name);
create index wmsys.wm$udtrig_info_indx on wmsys.wm$udtrig_info(table_owner_name, table_name, trig_flag, status);
update wmsys.wm$udtrig_info
set trig_procedure = 'wm$' || trig_name
where trig_procedure is not null and
      internal_type = 'USER_DEFINED' ;
commit ;
update wmsys.wm$udtrig_info
set event_flag = decode(trig_procedure, null, null, (event_flag/32768))
where internal_type = 'USER_DEFINED' ;
commit ;
begin
  for tabrec in (select owner, table_name
                 from wmsys.wm$versioned_tables) loop

    for trigrec in (select trig_owner_name, trig_name, rowid r, rownum rn
                    from wmsys.wm$udtrig_info
                    where table_owner_name=tabrec.owner and table_name=tabrec.table_name and internal_type='RIC_CHECK') loop
      update wmsys.wm$udtrig_info
      set trig_procedure = table_name || '$R' || trigrec.rn
      where rowid = trigrec.r ;
    end loop ;
  end loop ;
end ;
/
create table wmsys.wm$version_hierarchy_table#(
  version integer,
  parent_version integer,
  workspace varchar2(30));
insert into wmsys.wm$version_hierarchy_table#(select version,parent_version,workspace from wmsys.wm$version_hierarchy_table);
commit;
drop view wmsys.wm$version_hierarchy_table;
drop table wmsys.wm$version_hierarchy_table$ purge;
alter table wmsys.wm$version_hierarchy_table# rename to wm$version_hierarchy_table;
alter table wmsys.wm$version_hierarchy_table add constraint wm$version_hierarchy_pk primary key(version);
create index wmsys.wm$vht_idx on wmsys.wm$version_hierarchy_table(workspace, version);
create table wmsys.wm$version_table#(
  workspace varchar2(30),
  anc_workspace varchar2(30),
  anc_version integer,
  anc_depth integer,
  refcount integer default 1);
insert into wmsys.wm$version_table#(select workspace,anc_workspace,anc_version,anc_depth,refcount from wmsys.wm$version_table);
commit;
drop view wmsys.wm$version_table;
drop table wmsys.wm$version_table$ purge;
alter table wmsys.wm$version_table# rename to wm$version_table;
alter table wmsys.wm$version_table add constraint wm$version_pk primary key(workspace, anc_workspace);
create index wmsys.wm$vt_anc_idx on wmsys.wm$version_table(anc_workspace, anc_version);
create table wmsys.wm$vt_errors_table#(
  owner varchar2(30),
  table_name varchar2(30),
  index_type integer,
  index_field integer,
  status varchar2(100),
  error_msg varchar2(200));
insert into wmsys.wm$vt_errors_table#(select owner,table_name,index_type,index_field,status,error_msg from wmsys.wm$vt_errors_table);
commit;
drop view wmsys.wm$vt_errors_table;
drop table wmsys.wm$vt_errors_table$ purge;
alter table wmsys.wm$vt_errors_table# rename to wm$vt_errors_table;
alter table wmsys.wm$vt_errors_table add constraint wm$vt_errors_pk primary key(owner, table_name);
create table wmsys.wm$workspace_priv_table#(
  grantee varchar2(30),
  workspace varchar2(30),
  grantor varchar2(30),
  priv varchar2(10),
  admin integer);
insert into wmsys.wm$workspace_priv_table#(select grantee,workspace,grantor,priv,admin from wmsys.wm$workspace_priv_table);
commit;
drop view wmsys.wm$workspace_priv_table;
drop table wmsys.wm$workspace_priv_table$ purge;
alter table wmsys.wm$workspace_priv_table# rename to wm$workspace_priv_table;
create index wmsys.wm$ws_priv_tab_ws_grte_ind on wmsys.wm$workspace_priv_table(workspace, grantee);
create index wmsys.wm$ws_priv_tab_grtor_ind on wmsys.wm$workspace_priv_table(grantor);
create index wmsys.wm$ws_priv_tab_grte_ind on wmsys.wm$workspace_priv_table(grantee);
create table wmsys.wm$workspace_savepoints_table#(
  workspace varchar2(30),
  savepoint varchar2(30),
  version number,
  position integer,
  is_implicit number,
  owner varchar2(30),
  createtime date,
  description varchar2(1000));
insert into wmsys.wm$workspace_savepoints_table#(select workspace,savepoint,version,position,is_implicit,owner,createtime,description from wmsys.wm$workspace_savepoints_table);
commit;
drop view wmsys.wm$workspace_savepoints_table;
drop table wmsys.wm$workspace_savepoints_table$ purge;
alter table wmsys.wm$workspace_savepoints_table# rename to wm$workspace_savepoints_table;
alter table wmsys.wm$workspace_savepoints_table add constraint wm$workspace_savepoints_pk primary key(workspace, savepoint);
create index wmsys.wm$ws_sp_tab_ver_ind on wmsys.wm$workspace_savepoints_table(version);
create table wmsys.wm$versioned_tables#(
  vtid integer not null,
  table_name varchar2(30),
  owner varchar2(30),
  notification integer,
  notifyworkspaces varchar2(4000),
  disabling_ver varchar2(13),
  ricweight integer,
  isfastlive integer default 0,
  isworkflow integer default 0,
  hist varchar2(50) default 'NONE',
  pkey_cols varchar2(4000) default '',
  undo_code wmsys.wm$ed_undo_code_table_type,
  siteslist varchar2(4000),
  repsitecount integer default 0 ,
  bl_workspace varchar2(30),
  bl_version integer,
  validtime integer default 0,
  initvtrange wmsys.wm_period) nested table undo_code store as wm$undo_code_tmp;
insert into wmsys.wm$versioned_tables#(select vtid,table_name,owner,notification,notifyworkspaces,disabling_ver,ricweight,isfastlive,isworkflow,hist,pkey_cols,undo_code,siteslist,repsitecount,bl_workspace,bl_version,validtime,null from wmsys.wm$versioned_tables);
commit;
drop view wmsys.wm$versioned_tables ;
drop view wmsys.wm$versioned_tables$h ;
drop view wmsys.wm$versioned_tables$d ;
drop table wmsys.wm$versioned_tables$ purge;
alter table wmsys.wm$versioned_tables# rename to wm$versioned_tables;
alter table wmsys.wm$undo_code_tmp rename to wm$versioned_tables_undo_code;
alter table wmsys.wm$versioned_tables add constraint wm$versioned_tables__pk primary key(table_name, owner);
create index wmsys.wm$ver_tab_bl_indx on wmsys.wm$versioned_tables(bl_workspace, bl_version);
create table wmsys.wm$workspaces_table#(
  workspace varchar2(30),
  parent_workspace varchar2(30),
  current_version number,
  parent_version number,
  post_version number,
  verlist varchar2(2000),
  owner varchar2(30),
  createtime date,
  description varchar2(1000),
  workspace_lock_id integer,
  freeze_status varchar2(8),
  freeze_mode varchar2(20),
  freeze_writer varchar2(30),
  oper_status varchar2(30),
  wm_lockmode varchar2(5),
  isrefreshed integer,
  freeze_owner varchar2(30),
  session_duration integer,
  implicit_sp_cnt integer default 0 ,
  cr_status varchar2(20),
  sync_parver integer,
  last_change date default sysdate,
  depth integer,
  mp_root varchar2(30) default null);
insert into wmsys.wm$workspaces_table#(select workspace,parent_workspace,current_version,decode(parent_version, -1, null, parent_version),post_version,verlist,owner,createtime,description,workspace_lock_id,freeze_status,freeze_mode,freeze_writer,oper_status,wm_lockmode,isrefreshed,freeze_owner,session_duration,implicit_sp_cnt,cr_status,sync_parver,last_change,depth,mp_root from wmsys.wm$workspaces_table);
commit;
drop view wmsys.wm$workspaces_table;
drop table wmsys.wm$workspaces_table$ purge;
alter table wmsys.wm$workspaces_table# rename to wm$workspaces_table;
alter table wmsys.wm$workspaces_table add constraint workspace_lock_id_unq unique(workspace_lock_id);
alter table wmsys.wm$workspaces_table add constraint wm$workspaces_pk primary key(workspace);
create index wmsys.wm$workspaces_mp_idx on wmsys.wm$workspaces_table(mp_root);
create index wmsys.wm$ws_tab_pws_ind on wmsys.wm$workspaces_table(parent_workspace);
create index wmsys.wm$ws_tab_pver_ind on wmsys.wm$workspaces_table(parent_version);
update wmsys.wm$env_vars set value = '11.2.0.1.0', hidden=0 where name = 'OWM_VERSION';
commit;
declare
  cursor ver_tabs is
    select owner, table_name, hist, validtime
    from wmsys.wm$versioned_tables ;

  already_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_null, -01451);

begin
  for ver_rec in ver_tabs loop
    begin
      execute immediate 'alter table ' || ver_rec.owner || '.' || ver_rec.table_name || '_LT modify (wm_nextver null)'  ;
    exception when already_null then null ;
    end;

    if (ver_rec.validtime=1)  then
      begin
        execute immediate 'alter table ' || ver_rec.owner || '.' || ver_rec.table_name || '_LT modify (wm_version null)'  ;
      exception when already_null then null ;
      end ;

      begin
        execute immediate 'alter table ' || ver_rec.owner || '.' || ver_rec.table_name || '_VT modify (wm_version null)'  ;
      exception when already_null then null ;
      end ;

      begin
        execute immediate 'alter table ' || ver_rec.owner || '.' || ver_rec.table_name || '_VT modify (wm_nextver null)'  ;
      exception when already_null then null ;
      end ;
    end if ;
  end loop ;
end;
/
declare
  no_grant EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_grant, -1927);
begin
  for trec in(select distinct owner from wmsys.wm$versioned_tables) loop
    wmsys.wm$execSQL('grant select on wmsys.wm$nextver_table to ' || trec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$version_hierarchy_table to ' || trec.owner) ;
    wmsys.wm$execSQL('grant select on wmsys.wm$version_table to ' || trec.owner || ' with grant option');

    if ((substr(:prv_version, 1, 3) = 'A.2' and nlssort(:prv_version, 'nls_sort=ascii7') >= nlssort('A.2.0.5.0', 'nls_sort=ascii7')) or
        (substr(:prv_version, 1, 3) = 'B.2' and nlssort(:prv_version, 'nls_sort=ascii7') >= nlssort('B.2.0.2.0', 'nls_sort=ascii7'))) then
      wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to ' || trec.owner || ' with grant option');
    else
      wmsys.wm$execSQL('grant select on wmsys.wm$modified_tables to ' || trec.owner) ;
      wmsys.wm$execSQL('grant select on wmsys.wm$workspaces_table to ' || trec.owner);
    end if ;
  end loop;
end;
/
drop type wmsys.wm$nextver_exp_tab_type  ;
drop type wmsys.wm$nextver_exp_type ;
drop type wmsys.wm$ident_tab_type ;
delete wmsys.wm$env_vars where name in ('CONSTRAINT_HASH_TABLE_SIZE', 'DIFF_MODIFIED_ONLY', 'EXPORTED_OWM_VERSION')  ;
delete wmsys.wm$hint_table where (hint_id in(1130, 1133, 1242) or hint_id>5000) and isdefault=1 ;
commit ;
create type wmsys.wm$conflict_payload_type TIMESTAMP '2001-07-29:12:06:11' OID '8A3DB78598D25DE2E034080020EDC61B' wrapped 
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
d
e7 db
n4nZA7v5WRSRS1em71F78cP5SUIwg5n0dLhcFnJcof9yDNn6WdH0llrYR/quWfSWJlZaQ8B0
K6W/m8Ayy8xQ57Kfsp7LUnRSXKmpfMbKFyjGyu+yCx0upNFENucI0jJExdKyqZtMqSNpjlf4
+L6VB/hbQltbV3uYOe9ZZX98Z3jZs/rGPXKznA5jGeL3OEoia3wy5wJgZ+8qO4imoqgh2A==


/
create sequence wmsys.wm$row_sync_id_sequence start with 11 nocache;
declare
  c number ;
begin
  for seq_rec in (select * from dba_sequences where sequence_owner = 'WMSYS' and sequence_name like 'WM$%' and min_value=-1) loop
    execute immediate 'select wmsys.' || seq_rec.sequence_name || '.nextval from sys.dual' into c ;
    execute immediate 'alter sequence wmsys.' || seq_rec.sequence_name || ' minvalue 1' ;
  end loop ;
end;
/
create or replace function wmsys.wm$convertDbVersion wrapped 
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
8
26f 158
+fMjHMLJDvP94+Lj7g4GCp4ixaEwgxDxJJkVfC+VkPg+SC+D5vP2Mi31fU8KslpGFGJIRJWv
NUSUTJLuAHmNFt9eFe3+Er9x8Zx6XH6V7j8ESK7GBbnP1989uc8xT0rcAubxKwxsDhjpo9vg
BqxnXJ75Pqa3b2end1051JTRaUbDPrhMvz3EPQhVUPK4r1cpVr+F3LMj/XIcMdGiL6mZ5d2w
u7cA0Gen+paPEiEJzpvM4Bfw3Sz2+w9qaV+kBWI3DDpEOhsWKTcbGxbNN+G2iYFnXrZGAFBH
NkMg4xegvDMZ7WSLfuyqEyiD7V4kd61z6zTS0ez/uKWmWImJfQ==

/
create or replace function wmsys.wm$getDbVersionStr wrapped 
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
8
117 ff
YRW+MRCq396JIrQuiRNngZ7cNm8wg3lyLpmsZy85j//5GK0waectSqFb/oyjEbG0iJSurMqz
a+G2kvh5LEA4EpAXGb+ft/3cxYK4JPjGYR8us5/E64GsEFsrCUiyjiZDmHfRNWtbaVpt/7Fa
b7wgyq9mSoYv08Ew6Cg+PugzGOU1rna3ugFuOa8hPK3t9RRUcya9YDJOoZHOVpK+EQ1ACQsC
zCYQQYh4Zq/5ke14ByhK4dOuq/dHHBZc8uw=

/
declare
  invalid_package EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_package, -04043);

  cursor pkgs_cur is
  select object_name
  from dba_objects
  where owner = 'WMSYS' and
        object_name in ('LTADM', 'LT_CTX_PKG', 'LTUTIL') and
        object_type = 'PACKAGE' ;
begin

  for p_rec in pkgs_cur loop
    begin
      execute immediate 'drop package wmsys.' || p_rec.object_name ;
    exception when invalid_package then null;
    end ;
  end loop ;
end;
/
create or replace package wmsys.lt_ctx_pkg wrapped 
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
92 ba
mnppkM34iSeg7HZ8vJwH9MFX5MQwg5m49TOf9b9chT70rtEm45aF3OqldIsJabiZgcfLCNL+
Xri/sgi9CAi/MzPSx06xqXyUFXbWbgB21l/1jmdRuOLo5sj2WhHILHHdqzEauA+UH3JwgCws
taVnJB8PLHXgrp0v6r+xykT20eokH/Y5pt1DSfA=

/
create or replace package wmsys.ltUtil wrapped 
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
74 ae
FOm0GG886ln6DGOIk/L/Bsi2TIkwgwDZf8vWfHRg7v8AlSR83bRZWllIuF5tPOlKhJXzyAS+
nezR2K67Ez7ciQT4zEp5B13VyNlVsVgIEHhlwiM7VIUGt1agxFC/BPyBFqtMIhjbuRsprsCY
UJlR//Q71i0f6+sr1HvLnCwofBxm

/
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
13d e7
sTgMrUZ1L7mj9HQXnOR6xa83wdYwgzvwLZ4VZy+iO3MYYlZm4wJ55YHCnHa+BZkS/YTl73Am
kLXQNX+s599hIIvX9RGj2L3RxCnPRJw8pmEXjNFlDsjfFJFmurtf6OYIfT7GN6GPRuCriWrL
QYl/UOHEfJjtpeGXIGqNAzMgjCreM7OgOji85YRaC4MoOE5KwkqkEOXHDD71Fk5r8Y6dSvQK
wDJb9HBcEw==

/
create or replace type wmsys.wm_concat_impl wrapped 
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
d
1de 144
SczirR4C83iP0EFUi9lglEs/Glcwg43IAK5qZ3RAWE7VehsJb6yiWxvGMuJgv5yFwdUs2b0y
5lHdqduaST5NHazykH4pjUHGP8044M5onFUFHrkpjHq7mg+mA3mRsolcraP69JR8r7SaZZNc
6rjj8mVEtFElOQ0KZEU9geXewXyI7C90rfH6BDhxtw7Hl8vwbBi9I0Jde/dV1kdC31OZAtRa
EekVXf1pYdjz4MsAHuGyNH61NfAyHDLgJOQufjhFehkj0T/oW/SAryCbeH5tIk6vWT+KugR6
RdILV+oEVFUpIKe5Res7XNfXlR8SjTen

/
create or replace function wmsys.wm_concat wrapped 
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
8
53 96
antgYqrbNGLSC7Re+71hueZFyT4wg0SvLZ6pyi+mUCJD1KOsoxPiallQXtwu7BTsCmx9/hIg
+ln6MEC75cHHT8YFQPvfjqPM1MuiY1Z0kXN0TQ0W8KE1SkAqjh/+tB/q+oI45dREmV5OHaYy
H/E=

/
create or replace function wmsys.wm$disallowQnDML wrapped 
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
8
ac eb
Vog7SShcem+MaQL08P20YQ+fvmUwgwDwAJkVfI6mkPjVGcrDNZ6QdnsmEKdn+Bih8lLF92B0
26ITJ7W8D4+faLLEIBFJky58TMHtvZejJKRxh43dzN9uqffb4a1883ktcI77oI1XGBo7e100
i72afDcPceTyPrUtDLHegIGe4EJ/+2AywqsZj+Tn/CZfcxgDLI/5UNaz+4ke7gP+eABNszAf
BgFvqEMxikQ7ESpn

/
grant execute on wmsys.wm$convertDBVersion to public;
grant execute on wmsys.wm$getDbVersionStr to public ;
grant execute on wmsys.wm$disallowQnDML to public ;
begin
  for vrec in (select v.owner, v.view_name, v.text
               from wmsys.wm$versioned_tables vt, dba_views v, dba_dependencies dd
               where vt.owner = v.owner and
                     v.view_name like vt.table_name || '%' and
                     v.text_length < 30000 and
                     v.owner = dd.owner and
                     v.view_name = dd.name and
                     dd.referenced_owner = 'WMSYS' and
                     dd.referenced_name = 'LT_CTX_PKG' and
                     dd.referenced_type = 'PACKAGE') loop

    if (instr(vrec.text, 'wmsys.lt_ctx_pkg.wm$disallowQnDML')>0) then
      execute immediate 'create or replace view ' || vrec.owner || '.' || vrec.view_name || ' as ' ||
                        replace(vrec.text, 'wmsys.lt_ctx_pkg.wm$disallowQnDML', 'wmsys.wm$disallowQnDML') ;
    end if ;
  end loop ;
end;
/
create or replace view wmsys.dba_wm_versioned_tables as
select /*+ ORDERED */ t.table_name, t.owner,
       disabling_ver state,
       t.hist history,
       decode(t.notification, 0, 'NO', 1, 'YES') notification,
       substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
       wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
       wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
       decode(t.validtime, 0, 'NO', 1, 'YES') validtime
from   wmsys.wm$versioned_tables t, dba_views u
where  t.table_name = u.view_name and t.owner = u.owner
WITH READ ONLY;
create or replace view wmsys.all_wm_versioned_tables as
 select /*+ ORDERED */ t.table_name, t.owner,
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
 select /*+ ORDERED */ t.table_name, t.owner,
        disabling_ver state,
        t.hist history,
        decode(t.notification, 0, 'NO', 1, 'YES') notification,
        substr(notifyWorkspaces,2,length(notifyworkspaces)-2) notifyworkspaces,
        wmsys.ltadm.AreThereConflicts(t.owner, t.table_name) conflict,
        wmsys.ltadm.AreThereDiffs(t.owner, t.table_name) diff,
        decode(t.validtime, 0, 'NO', 1, 'YES') validtime
 from wmsys.wm$versioned_tables t, all_tables at
 where t.table_name = at.table_name and t.owner = at.owner
WITH READ ONLY;
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
where t.owner = (select username from all_users where user_id=userenv('schemaid'))
WITH READ ONLY;
create or replace view wmsys.user_workspaces as
select st.workspace, st.workspace_lock_id workspace_id, st.parent_workspace, ssp.savepoint parent_savepoint,
       st.owner, st.createTime, st.description,
       decode(st.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(st.oper_status, null, st.freeze_mode,'INTERNAL') freeze_mode,
       decode(st.freeze_mode, '1WRITER_SESSION', s.username, st.freeze_writer) freeze_writer,
       decode(st.session_duration, 0, st.freeze_owner, s.username) freeze_owner,
       decode(st.freeze_status, 'UNLOCKED', null, decode(st.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(st.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')),
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
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
from   wmsys. wm$workspaces_table st, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  st.owner = (select username from all_users where user_id=userenv('schemaid')) and ((ssp.position is null) or ( ssp.position =
	(select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and
       st.parent_version = ssp.version (+) and
       st.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(st.freeze_owner, 1, instr(st.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(st.freeze_owner, instr(st.freeze_owner, ',')+1)
WITH READ ONLY;
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
       decode(admin, 0, 'NO',
                     1, 'YES') grantable
from wmsys.wm$workspace_priv_table where grantee in
   (select role from session_roles
    UNION ALL
    select 'WM_ADMIN_ROLE' from dual where (select username from all_users where user_id=userenv('schemaid')) = 'SYS'
    UNION ALL
    select username from all_users where user_id=userenv('schemaid')
    UNION ALL
    select 'PUBLIC' from dual)
WITH READ ONLY;
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
 from wmsys.wm$workspaces_table s where owner = (select username from all_users where user_id=userenv('schemaid'))
WITH READ ONLY;
create or replace view wmsys.all_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')),
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
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
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  ((ssp.position is null) or ( ssp.position =
        (select min(position) from wmsys.wm$workspace_savepoints_table where version=ssp.version) )) and
       asp.parent_version  = ssp.version (+) and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
create or replace view wmsys.dba_workspaces as
select asp.workspace, asp.workspace_lock_id workspace_id, asp.parent_workspace, ssp.savepoint parent_savepoint,
       asp.owner, asp.createTime, asp.description,
       decode(asp.freeze_status,'LOCKED','FROZEN',
                              'UNLOCKED','UNFROZEN') freeze_status,
       decode(asp.oper_status, null, asp.freeze_mode,'INTERNAL') freeze_mode,
       decode(asp.freeze_mode, '1WRITER_SESSION', s.username, asp.freeze_writer) freeze_writer,
       decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, 1, instr(asp.freeze_writer, ',')-1), null) sid,
       decode(asp.freeze_mode, '1WRITER_SESSION', substr(asp.freeze_writer, instr(asp.freeze_writer, ',')+1), null) serial#,
       decode(asp.session_duration, 0, asp.freeze_owner, s.username) freeze_owner,
       decode(asp.freeze_status, 'UNLOCKED', null, decode(asp.session_duration, 1, 'YES', 'NO')) session_duration,
       decode(asp.session_duration, 1,
                     decode((select 1 from dual
                             where s.sid=sys_context('lt_ctx', 'cid') and s.serial#=sys_context('lt_ctx', 'serial#')),
                           1, 'YES', 'NO'),
             null) current_session,
       decode(rst.workspace,null,'INACTIVE','ACTIVE') resolve_status,
       rst.resolve_user,
       mp_root mp_root_workspace
from   wmsys.wm$workspaces_table asp, wmsys.wm$workspace_savepoints_table ssp,
       wmsys.wm$resolve_workspaces_table  rst, v$session s
where  nvl(ssp.is_implicit,1) = 1 and
       asp.parent_version  = ssp.version (+) and
       asp.workspace = rst.workspace (+) and
       to_char(s.sid(+)) = substr(asp.freeze_owner, 1, instr(asp.freeze_owner, ',')-1)  and
       to_char(s.serial#(+)) = substr(asp.freeze_owner, instr(asp.freeze_owner, ',')+1)
WITH READ ONLY;
create or replace view wmsys.wm$workspace_sessions_view as
select st.username, wt.workspace, st.sid, st.saddr
from   v$lock dl,
       wmsys.wm$workspaces_table wt,
       v$session st
where  dl.type    = 'UL' and
       dl.id1 - 1 = wt.workspace_lock_id and
       dl.sid     = st.sid;
create or replace view wmsys.dba_workspace_sessions as
select sut.username,
       sut.workspace,
       sut.sid,
       decode(t.ses_addr, null, 'INACTIVE','ACTIVE') status
from   wmsys.wm$workspace_sessions_view sut,
       v$transaction t
where  sut.saddr = t.ses_addr (+)
WITH READ ONLY;
update wmsys.wm$workspaces_table
set freeze_owner  = substr(freeze_owner, 1, instr(freeze_owner, ',', 1, 2)-1),
    freeze_writer = substr(freeze_writer, 1, instr(freeze_writer, ',', 1, 2)-1)
where instr(freeze_writer, ',', 1, 2)>0 ;
update wmsys.wm$resolve_workspaces_table
set oldfreezewriter  = substr(oldfreezewriter, 1, instr(oldfreezewriter, ',', 1, 2)-1)
where instr(oldfreezewriter, ',', 1, 2)>0 ;
commit ;
create or replace view wmsys.wm_installation as
 select name, value
 from wmsys.wm$env_vars where hidden=0
union
 select name, value
 from wmsys.wm$sysparam_all_values sv
 where isdefault = 'YES' and
       not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name)
WITH READ ONLY ;
create or replace view wmsys.dba_wm_vt_errors as
  select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
  from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str, 4000, 1) sql_str
        from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
       wmsys.wm$vt_errors_table et
  where vt.owner = et.owner
    and vt.table_name = et.table_name
    and vt.index_type = et.index_type
    and vt.index_field = et.index_field
 union all
  select null, null, decode(lt.group#, 10, 'DROP USER COMMAND', 'UNKNOWN OPERATION'), lt.sql_str, lte.status, lte.error_msg
  from (select lt.group#, lt.order#, dbms_lob.substr(lt.sql_str, 4000, 1) sql_str from wmsys.wm$log_table lt) lt,
       wmsys.wm$log_table_errors lte
  where lt.group# = lte.group#
    and lt.order# = lte.order# ;
create or replace view wmsys.user_wm_ind_columns as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position,
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid'))
and t1.index_name = t2.index_name
and t1.constraint_type != 'P'
union
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_name, t2.column_position-1,
t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, user_ind_columns t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid'))
and t1.index_name = t2.index_name
and t1.constraint_type = 'P'
and t2.column_name not in ('VERSION','DELSTATUS') ;
create or replace view wmsys.all_wm_ind_columns as
select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name,
t2.column_position, t2.column_length,  t2.descend
from wmsys.wm$constraints_table t1, all_ind_columns t2
where t1.index_owner = t2.index_owner
and t1.index_name = t2.index_name
and t1.constraint_type != 'P'
union
select /*+ USE_NL(t1 t2) */ t2.index_owner, t2.index_name, t1.owner, t1.table_name, t2.column_name,
t2.column_position-1, t2.column_length, t2.descend
from wmsys.wm$constraints_table t1, all_ind_columns t2
where t1.index_owner = t2.index_owner
and t1.index_name = t2.index_name
and t1.constraint_type = 'P'
and t2.column_name not in ('VERSION','DELSTATUS') ;
create or replace view wmsys.all_wm_tab_triggers
(
  trigger_owner,
  trigger_name,
  table_owner,
  table_name,
  trigger_type,
  status,
  when_clause,
  description,
  trigger_body,
  TAB_MERGE_WO_REMOVE,
  TAB_MERGE_W_REMOVE,
  WSPC_MERGE_WO_REMOVE,
  WSPC_MERGE_W_REMOVE,
  DML,
  TABLE_IMPORT
)
as
(select trig_owner_name,
        trig_name,
        table_owner_name,
        table_name,
        wmsys.ltUtil.getTrigTypes(trig_flag),
        status,
        when_clause,
        description,
        trig_code,
        decode(bitand(event_flag, 1), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 2), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 4), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 8), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 16), 0, 'OFF', 'ON'),
        decode(bitand(event_flag, 1024), 0, 'OFF', 'ON')
 from   wmsys.wm$udtrig_info
 where  (trig_owner_name   = (select username from all_users where user_id=userenv('schemaid'))    OR
         table_owner_name  = (select username from all_users where user_id=userenv('schemaid'))    OR
         EXISTS (
           SELECT 1
           FROM   user_sys_privs
           WHERE  privilege = 'CREATE ANY TRIGGER'
         )
         OR
         EXISTS
         ( SELECT 1
           FROM   session_roles sr, role_sys_privs rsp
           WHERE  sr.role       = rsp.role     AND
                  rsp.privilege = 'CREATE ANY TRIGGER' ))  AND
         internal_type   = 'USER_DEFINED')
with READ ONLY;
create or replace view wmsys.user_wm_tab_triggers
(
  trigger_name,
  table_owner,
  table_name,
  trigger_type,
  status,
  when_clause,
  description,
  trigger_body,
  TAB_MERGE_WO_REMOVE,
  TAB_MERGE_W_REMOVE,
  WSPC_MERGE_WO_REMOVE,
  WSPC_MERGE_W_REMOVE,
  DML,
  TABLE_IMPORT
)
as
select trig_name,
       table_owner_name,
       table_name,
       wmsys.ltUtil.getTrigTypes(trig_flag),
       status,
       when_clause,
       description,
       trig_code,
       decode(bitand(event_flag, 1), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 2), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 4), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 8), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 16), 0, 'OFF', 'ON'),
       decode(bitand(event_flag, 1024), 0, 'OFF', 'ON')
from   wmsys.wm$udtrig_info
where  trig_owner_name = (select username from all_users where user_id=userenv('schemaid'))  and
       internal_type   = 'USER_DEFINED'
with READ ONLY;
create or replace view wmsys.wm$all_locks_view as
select t.table_owner, t.table_name,
       decode(wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),
              'ROW_LOCKMODE'), 'E', 'EXCLUSIVE', 'S', 'SHARED', 'VE', 'VERSION EXCLUSIVE', 'WE', 'WORKSPACE EXCLUSIVE') Lock_mode,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKUSER') Lock_owner,
       wmsys.lt_ctx_pkg.getltlockinfo(translate(t.info USING CHAR_CS),'ROW_LOCKSTATE') Locking_state
from (select table_owner, table_name, info from
      table( cast(wmsys.ltadm.get_lock_table() as wmsys.wm$lock_table_type))) t
with READ ONLY ;
create or replace view wmsys.all_wm_locked_tables as
select /*+ ORDERED */ t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state
from wmsys.wm$all_locks_view t, all_views s
where t.table_owner = s.owner and t.table_name = s.view_name
with READ ONLY;
create or replace view wmsys.user_wm_locked_tables as
select t.table_owner, t.table_name, t.Lock_mode, t.Lock_owner, t.Locking_state
from wmsys.wm$all_locks_view t
where t.table_owner = (select username from all_users where user_id=userenv('schemaid'))
with READ ONLY;
create or replace view wmsys.wm$all_nextver_view as
  select version, next_vers, workspace, split
  from wmsys.wm$nextver_table
WITH READ ONLY;
create public synonym wm$all_nextver_view for wmsys.wm$all_nextver_view ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$all_nextver_view to public with grant option');
create or replace view wmsys.wm$current_child_nextvers_view as
select nvt.next_vers
from wmsys.wm$nextver_table nvt, wmsys.wm$version_table vt
where
(
   nvt.workspace = vt.workspace and
   vt.anc_workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
   vt.anc_version  >= decode(sys_context('lt_ctx','version'),
                              null,(SELECT current_version
                                    FROM wmsys.wm$workspaces_table
                                    WHERE workspace = 'LIVE'),
                              -1,(select current_version
                                  from wmsys.wm$workspaces_table
                                  where workspace = sys_context('lt_ctx','state')),
                              sys_context('lt_ctx','version')
                          )
)
union all
select nvt.next_vers
from wmsys.wm$nextver_table nvt
where nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
      nvt.version > decode(sys_context('lt_ctx','version'),
                            null,(SELECT current_version
                                  FROM wmsys.wm$workspaces_table
                                  WHERE workspace = 'LIVE'),
                            -1,(select current_version
                                from wmsys.wm$workspaces_table
                                where workspace = sys_context('lt_ctx','state')),
                            sys_context('lt_ctx','version')
                          )
WITH READ ONLY ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_child_nextvers_view to public with grant option');
create public synonym wm$current_child_nextvers_view for wmsys.wm$current_child_nextvers_view ;
create or replace view wmsys.wm$current_hierarchy_view as
   select version, parent_version, workspace
   from wmsys.wm$version_hierarchy_table
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create public synonym wm$current_hierarchy_view for wmsys.wm$current_hierarchy_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_hierarchy_view to public with grant option');
create or replace view wmsys.wm$current_savepoints_view as
   select workspace, savepoint, version, position, is_implicit, owner, createtime, description
   from wmsys.wm$workspace_savepoints_table
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE')
WITH READ ONLY;
create public synonym wm$current_savepoints_view for wmsys.wm$current_savepoints_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_savepoints_view to public with grant option');
create or replace view wmsys.wm$current_ver_view as
(select current_version
  from wmsys.wm$workspaces_table
  where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
        and ( sys_context('lt_ctx', 'version') is null or
              sys_context('lt_ctx', 'version') = -1))
 union all
 (select to_number(sys_context('lt_ctx', 'version')) from dual where
   sys_context('lt_ctx', 'version') is not null and
   sys_context('lt_ctx', 'version') != -1) WITH READ ONLY;
create public synonym wm$current_ver_view for wmsys.wm$current_ver_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$current_ver_view to public with grant option');
create or replace view wmsys.wm$mw_parvers_view as
select unique parent_vers from wmsys.wm$version_view where
  version in ( select current_version from wmsys.wm$workspaces_table
                where workspace in (select workspace from wmsys.wm$mw_table) );
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_parvers_view to public with grant option');
create or replace view wmsys.wm$mw_versions_view as
select distinct version, modified_by from
(
select vht.version, vht.workspace modified_by from
wmsys.wm$mw_table mw, wmsys.wm$version_table vt, wmsys.wm$version_hierarchy_table vht
where mw.workspace = vt.workspace
and vt.anc_workspace = vht.workspace
and vht.version <= vt.anc_version
union all
select vht.version, vht.workspace modified_by from
wmsys.wm$mw_table mw, wmsys.wm$version_hierarchy_table vht
where mw.workspace = vht.workspace
);
create public synonym wm$mw_versions_view for wmsys.wm$mw_versions_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$mw_versions_view to public with grant option');
create or replace view wmsys.wm$parent_hierarchy_view as
   select version, parent_version, workspace
   from wmsys.wm$version_hierarchy_table
   where workspace = sys_context('lt_ctx','parent_state')
WITH READ ONLY;
create public synonym wm$parent_hierarchy_view for wmsys.wm$parent_hierarchy_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$parent_hierarchy_view to public with grant option');
create or replace view wmsys.wm$parent_workspace_view as
  select workspace, parent_workspace, current_version, parent_version, post_version,
         verlist, owner, createtime, description, workspace_lock_id, freeze_status,
         freeze_mode, freeze_writer, oper_status, wm_lockmode, isrefreshed, freeze_owner,
         session_duration, implicit_sp_cnt, cr_status, sync_parver, last_change
  from wmsys.wm$workspaces_table
  where workspace = SYS_CONTEXT('lt_ctx','parent_state')
WITH READ ONLY;
create public synonym wm$parent_workspace_view for wmsys.wm$parent_workspace_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$parent_workspace_view to public with grant option');
create or replace view wmsys.wm$versions_in_live_view  (parent_vers) as
             (select version
              from wmsys.wm$version_hierarchy_table
              where workspace = 'LIVE')
WITH READ ONLY;
execute wmsys.wm$execSQL('grant select on wmsys.wm$versions_in_live_view to public with grant option');
create public synonym wm$versions_in_live_view for wmsys.wm$versions_in_live_view;
create or replace view wmsys.wm$ver_bef_inst_parvers_view as
 (select parent_vers
  from wmsys.wm$version_view
  where version = sys_context('lt_ctx','ver_before_instant'))
WITH READ ONLY;
create public synonym wm$ver_bef_inst_parvers_view for wmsys.wm$ver_bef_inst_parvers_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$ver_bef_inst_parvers_view to public with grant option');
create or replace view wmsys.wm$ver_bef_inst_nextvers_view as
         select next_vers
         from wmsys.wm$nextver_table
         where version IN
           (SELECT parent_vers FROM wmsys.wm$ver_bef_inst_parvers_view)
WITH READ ONLY;
create public synonym wm$ver_bef_inst_nextvers_view for wmsys.wm$ver_bef_inst_nextvers_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$ver_bef_inst_nextvers_view to public with grant option');
create or replace view wmsys.wm$table_parvers_view  (table_name,parent_vers) as
         (select table_name,version
          from wmsys.wm$modified_tables
          where workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
                version   <=
            decode(sys_context('lt_ctx','version'),
                   null,(SELECT current_version
                           FROM wmsys.wm$workspaces_table
                           WHERE workspace = 'LIVE'),
                   -1,(select current_version
                       from wmsys.wm$workspaces_table
                       where workspace = sys_context('lt_ctx','state')),
                   sys_context('lt_ctx','version')))
          union all
         (select table_name,vht.version
          from wmsys.wm$modified_tables vht, wmsys.wm$version_table vt
          where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')  and
                vht.workspace = vt.anc_workspace and
                vht.version  <= vt.anc_version)
WITH READ ONLY;
create or replace view wmsys.wm$table_versions_in_live_view  (table_name,parent_vers) as
             (select table_name,version
              from wmsys.wm$modified_tables
              where workspace = 'LIVE')
WITH READ ONLY;
create or replace view wmsys.wm$table_ws_parvers_view  (table_name,parent_vers) as
  (select table_name,version
   from wmsys.wm$modified_tables
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE'))
   union all
      (select vht.table_name,vht.version
       from wmsys.wm$modified_tables vht, wmsys.wm$version_table vt
       where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
WITH READ ONLY;
create or replace view wmsys.wm$current_nextvers_view as
select /*+ INDEX(nvt WM$NEXTVER_TABLE_NV_INDX) */ nvt.next_vers, nvt.version
             from wmsys.wm$nextver_table nvt
where
(
 (
   nvt.workspace = nvl(sys_context('lt_ctx','state'),'LIVE') and
    nvt.version   <=   decode(sys_context('lt_ctx','version'),
                       null,(SELECT current_version
                               FROM wmsys.wm$workspaces_table
                               WHERE workspace = 'LIVE'),
                       -1,(select current_version
                           from wmsys.wm$workspaces_table
                           where workspace = sys_context('lt_ctx','state')),
                           sys_context('lt_ctx','version')
                          )
 )
 or
 ( exists ( select 1 from wmsys.wm$version_table vt
                    where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                          nvt.workspace = vt.anc_workspace and
                          nvt.version  <= vt.anc_version )
 )
);
create or replace view wmsys.wm$curConflict_parvers_view (parent_vers, vtid) as
  select version, vtid
  from wmsys.wm$modified_tables
  where workspace = SYS_CONTEXT('lt_ctx','conflict_state')
WITH READ ONLY;
create or replace view wmsys.wm$curConflict_nextvers_view as
select version, next_vers, workspace, split, cpv.vtid
from wmsys.wm$nextver_table nt, wmsys.wm$curConflict_parvers_view cpv
where nt.version = cpv.parent_vers
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_parvers_view (parent_vers, vtid, afterSync)
as
 (select version, vtid,  decode(sign(mt.version - wt.sync_parver), -1, 'NO','YES')
  from wmsys.wm$modified_tables mt, wmsys.wm$workspaces_table wt
  where mt.workspace = SYS_CONTEXT('lt_ctx','parent_conflict_state') and
        wt.workspace = SYS_CONTEXT('lt_ctx','conflict_state')
        and mt.version >= decode(sign(wt.parent_version - wt.sync_parver),-1,
                                 (wt.parent_version+1), sync_parver)
 )
WITH READ ONLY;
create or replace view wmsys.wm$parConflict_nextvers_view as
select version, next_vers, workspace, split, ppv.vtid, ppv.afterSync
from wmsys.wm$nextver_table nt, wmsys.wm$parConflict_parvers_view ppv
where nt.version = ppv.parent_vers
WITH READ ONLY;
create or replace view wmsys.wm$base_version_view as
select decode(sign(vt1.anc_version - vt2.anc_version),
              1, vt2.anc_version, vt1.anc_version) version,
       decode(sys_context('lt_ctx', 'isAncestor'), 'false','NO',
              decode(decode(sign(vt1.anc_version - vt2.anc_version),
                     1, vt2.anc_version, vt1.anc_version),
                     wmt.current_version, 'YES', 'NO')) isCRAnc
from (select vt1.anc_version
      from wmsys.wm$version_table vt1
      where vt1.workspace = sys_context('lt_ctx', 'diffWspc1') and
            vt1.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
      union all
      select decode(sys_context('lt_ctx', 'diffver1'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc1')),
                     sys_context('lt_ctx', 'diffver1'))
      from dual where sys_context('lt_ctx', 'anc_workspace') =
                      sys_context('lt_ctx', 'diffWspc1')
      ) vt1,
      (select vt2.anc_version
       from wmsys.wm$version_table vt2
       where vt2.workspace = sys_context('lt_ctx', 'diffWspc2') and
             vt2.anc_workspace = sys_context('lt_ctx', 'anc_workspace')
       union all
       select decode(sys_context('lt_ctx', 'diffver2'),
                    -1, (select current_version
                         from wmsys.wm$workspaces_table
                         where workspace = sys_context('lt_ctx', 'diffWspc2')),
                       sys_context('lt_ctx', 'diffver2'))
       from dual where sys_context('lt_ctx', 'anc_workspace') =
                       sys_context('lt_ctx', 'diffWspc2')
      ) vt2,
      wmsys.wm$workspaces_table wmt
where wmt.workspace = sys_context('lt_ctx', 'anc_workspace');
create or replace view wmsys.wm$base_hierarchy_view as
  select -1 version from dual union all
  select version from wmsys.wm$version_hierarchy_table
  start with version = (select version from wmsys.wm$base_version_view)
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$base_nextver_view as
  select next_vers from wmsys.wm$nextver_table
  where version in
  (select version from wmsys.wm$base_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$diff1_hierarchy_view as
  select * from wmsys.wm$version_hierarchy_table
  start with version =
             decode(sys_context('lt_ctx', 'diffver1'), -1,
             (select current_version from wmsys.wm$workspaces_table
              where workspace = sys_context('lt_ctx', 'diffWspc1')),
             sys_context('lt_ctx', 'diffver1'))
  connect by prior parent_version = version
WITH READ ONLY;
create or replace view wmsys.wm$diff2_hierarchy_view as
  select version from wmsys.wm$version_hierarchy_table
  start with version =
             decode(sys_context('lt_ctx', 'diffver2'), -1,
             (select current_version from wmsys.wm$workspaces_table
              where workspace = sys_context('lt_ctx', 'diffWspc2')),
             sys_context('lt_ctx', 'diffver2'))
  connect by prior parent_version  = version
WITH READ ONLY;
create or replace view wmsys.wm$diff1_nextver_view as
  select next_vers from wmsys.wm$nextver_table
  where version in
  (select version from wmsys.wm$diff1_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.wm$diff2_nextver_view as
  select next_vers from wmsys.wm$nextver_table
  where version in
  (select version from wmsys.wm$diff2_hierarchy_view)
WITH READ ONLY;
create or replace view wmsys.all_version_hview as
   select version, parent_version, workspace
   from wmsys.wm$version_hierarchy_table
WITH READ ONLY;
drop view wmsys.wm$all_version_hview_wdepth ;
create or replace view wmsys.all_version_hview_wdepth as
select vht.version, vht.parent_version, vht.workspace, wt.depth
from wmsys.wm$version_hierarchy_table vht, wmsys.wm$workspaces_table wt
where vht.workspace = wt.workspace;
execute wmsys.wm$execSQL('grant select on wmsys.all_version_hview_wdepth to public with grant option') ;
create or replace public synonym wm$all_version_hview_wdepth for wmsys.all_version_hview_wdepth ;
create or replace view wmsys.wm$parvers_view  (parent_vers) as
  (select version
   from wmsys.wm$version_hierarchy_table
   where workspace = nvl(sys_context('lt_ctx','state'),'LIVE'))
   union all
      (select vht.version
       from wmsys.wm$version_hierarchy_table vht, wmsys.wm$version_table vt
       where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE') and
                    vht.workspace = vt.anc_workspace and
                    vht.version  <= vt.anc_version)
WITH READ ONLY;
create or replace view wmsys.wm$current_mp_join_points(workspace,version) as
select mpwst.mp_leaf_workspace,  vht.version
from   wmsys.wm$mp_graph_workspaces_table mpwst, wmsys.wm$workspaces_table wt, wmsys.wm$version_hierarchy_table vht
where  mpwst.mp_graph_workspace  = sys_context('lt_ctx','state')  and
       mpwst.mp_leaf_workspace   = wt.workspace                   and
       wt.workspace              = vht.workspace                  and
       wt.parent_version         = vht.parent_version
WITH READ ONLY;
create or replace view wmsys.wm$modified_tables_view as
   select table_name, version, workspace from wmsys.wm$modified_tables
WITH READ ONLY;
create or replace view wmsys.wm$table_nextvers_view as
select /*+ INDEX(v1 WM$NEXTVER_TABLE_NV_INDX) USE_NL(v1 v2) */ v2.table_name, v1.next_vers
             from wmsys.wm$nextver_table v1,wmsys.wm$table_parvers_view v2
              where v1.version = v2.parent_vers ;
create public synonym wm$table_nextvers_view for wmsys.wm$table_nextvers_view;
execute wmsys.wm$execSQL('grant select on wmsys.wm$table_nextvers_view to public with grant option');
drop view wmsys.wm_replication_info ;
create or replace view wmsys.wm$replication_info as
select groupName, masterdefsite writerSite
from wmsys.wm$replication_table
WITH READ ONLY ;
execute wmsys.wm$execSQL('grant select on wmsys.wm$replication_info to public') ;
create or replace public synonym wm_replication_info for wmsys.wm$replication_info ;
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
               where vt.workspace  = nvl(sys_context('lt_ctx','state'),'LIVE')   and
                     vht.workspace = vt.anc_workspace and
                     vht.version  <= vt.anc_version )
      ) ;
create or replace view wmsys.wm$mw_nextvers_view as
select nvt.next_vers
from wmsys.wm$nextver_table  nvt
where  nvt.workspace in (select workspace from wmsys.wm$mw_table)
       or
       exists (select 1
               from wmsys.wm$version_table vt
               where vt.workspace in (select workspace from wmsys.wm$mw_table) and
                     nvt.workspace = vt.anc_workspace and
                     nvt.version  <= vt.anc_version) ;
create or replace view wmsys.wm$mw_versions_view_9i as
select version, modified_by, wm_concat(workspace) seen_by
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
group by (version,modified_by) ;
create or replace view wmsys.all_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace GRAPH_WORKSPACE,
       decode(mpg.mp_graph_flag,'R','ROOT_WORKSPACE','I','INTERMEDIATE_WORKSPACE','L','LEAF_WORKSPACE') GRAPH_FLAG
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.all_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
create or replace view wmsys.all_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
       decode(mp.isRefreshed,0,'NO','YES') ISREFRESHED, decode(mp.parent_flag,'DP','DEFAULT_PARENT','ADDITIONAL_PARENT') PARENT_FLAG
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.all_workspaces aw
where mp.workspace = aw.workspace ;
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
 where rwt.owner = (select username from all_users where user_id=userenv('schemaid')) ;
create or replace view wmsys.all_wm_constraints as
select /*+ ORDERED */ ct.owner, constraint_name, constraint_type, table_name, search_condition, status, index_owner, index_name, index_type
from wmsys.wm$constraints_table ct, all_views av
where ct.owner = av.owner and
      ct.table_name = av.view_name ;
create or replace view wmsys.all_wm_cons_columns as
select /*+ ORDERED */ t1.*
from wmsys.wm$cons_columns t1, all_views t2
where t1.owner = t2.owner and
      t1.table_name = t2.view_name;
create or replace view wmsys.all_wm_ind_expressions as
select /*+ USE_NL(t1 t2) */ t2.index_owner,t2.index_name, t1.owner, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, all_ind_expressions t2
where t1.index_owner = t2.index_owner and
      t1.index_name = t2.index_name ;
create or replace view wmsys.all_wm_modified_tables as
select table_name, workspace, savepoint
from
     (select distinct o.table_name, o.workspace,
             nvl(s.savepoint, 'LATEST') savepoint,
             min(s.is_implicit) imp, count(s.version) counter
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s, all_views a
      where substr(o.table_name, 1, instr(table_name,'.')-1) = a.owner and
            substr(o.table_name, instr(table_name,'.')+1) = a.view_name and
            o.version = s.version (+)
      group by o.table_name, o.workspace, savepoint)
where (imp = 0 or imp is null or counter = 1) ;
create or replace view wmsys.all_wm_ric_info as
select /*+ ORDERED */ ct_owner, ct_name, pt_owner, pt_name, ric_name, rtrim(ct_cols,',') ct_cols, rtrim(pt_cols,',') pt_cols, pt_unique_const_name r_constraint_name, my_mode delete_rule, status
from wmsys.wm$ric_table rt, all_views uv
where uv.view_name = rt.ct_name and
      uv.owner = rt.ct_owner;
create or replace view wmsys.all_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
 from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str
       from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et, all_tables at
 where vt.owner = et.owner
   and vt.table_name = et.table_name
   and vt.index_type = et.index_type
   and vt.index_field = et.index_field
   and vt.owner = at.owner
   and vt.table_name || '_LT' = at.table_name
union all
 select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
 from (select t1.owner,t1.table_name,t1.disabling_ver state,nt.index_type,nt.index_field,dbms_lob.substr(nt.sql_str,4000,1) sql_str
       from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
      wmsys.wm$vt_errors_table et, all_tables at
 where vt.owner = et.owner
   and vt.table_name = et.table_name
   and vt.index_type = et.index_type
   and vt.index_field = et.index_field
   and vt.owner = at.owner
   and vt.table_name = at.table_name
   and not exists(select 1 from all_tables at2
                  where at2.owner = at.owner
                    and at2.table_name = at.table_name || '_LT') ;
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
where alt.workspace = spt.workspace ;
create or replace view wmsys.dba_removed_workspaces as
select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
       createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
from wmsys.wm$removed_workspaces_table rwt ;
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
where spt.workspace is null ;
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
where alt.workspace = spt.workspace ;
create or replace view wmsys.user_mp_graph_workspaces as
select mpg.mp_leaf_workspace, mpg.mp_graph_workspace graph_workspace,
       decode(mpg.mp_graph_flag,'R', 'ROOT_WORKSPACE', 'I', 'INTERMEDIATE_WORKSPACE', 'L', 'LEAF_WORKSPACE') graph_flag
from wmsys.wm$mp_graph_workspaces_table mpg, wmsys.user_workspaces uw
where mpg.mp_leaf_workspace = uw.workspace ;
create or replace view wmsys.user_mp_parent_workspaces as
select mp.workspace mp_leaf_workspace,mp.parent_workspace,mp.creator,mp.createtime,
       decode(mp.isRefreshed,0,'NO','YES') IsRefreshed, decode(mp.parent_flag, 'DP', 'DEFAULT_PARENT', 'ADDITIONAL_PARENT') parent_flag
from wmsys.wm$mp_parent_workspaces_table mp, wmsys.user_workspaces uw
where mp.workspace = uw.workspace ;
create or replace view wmsys.user_removed_workspaces as
select owner, workspace_name, workspace_id, parent_workspace_name, parent_workspace_id,
       createtime, retiretime, description, mp_root_id mp_root_workspace_id, decode(rwt.isRefreshed, 1, 'YES', 'NO') continually_refreshed
from wmsys.wm$removed_workspaces_table rwt
where rwt.owner = (select username from all_users where user_id=userenv('schemaid')) ;
create or replace view wmsys.user_wm_cons_columns as
select /*+ ORDERED */ t1.*
from wmsys.wm$cons_columns t1, user_views t2
where t1.owner = (select username from all_users where user_id=userenv('schemaid')) and
      t1.table_name = t2.view_name;
create or replace view wmsys.user_wm_constraints as
select /*+ ORDERED */ constraint_name, constraint_type, table_name, search_condition, status, index_owner, index_name, index_type
from wmsys.wm$constraints_table ct, user_views uv
where ct.owner = (select username from all_users where user_id=userenv('schemaid')) and
      ct.table_name = uv.view_name ;
create or replace view wmsys.user_wm_ind_expressions as
select /*+ ORDERED */ t2.index_name, t1.table_name, t2.column_expression, t2.column_position
from wmsys.wm$constraints_table t1, user_ind_expressions t2
where t1.index_owner = (select username from all_users where user_id=userenv('schemaid')) and
      t1.index_name = t2.index_name ;
create or replace view wmsys.user_wm_modified_tables as
select table_name, workspace, savepoint
from
      (select distinct o.table_name, o.workspace,
              nvl(s.savepoint, 'LATEST') savepoint,
              min(s.is_implicit) imp, count(s.version) counter
      from wmsys.wm$modified_tables o, wmsys.wm$workspace_savepoints_table s
      where substr(o.table_name, 1, instr(table_name,'.')-1) = (select username from all_users where user_id=userenv('schemaid')) and
            o.version = s.version (+)
      group by o.table_name, o.workspace, savepoint)
where (imp = 0 or imp is null or counter = 1) ;
create or replace view wmsys.user_wm_ric_info as
select ct_owner, ct_name, pt_owner, pt_name, ric_name, rtrim(ct_cols,',') ct_cols, rtrim(pt_cols,',') pt_cols,
       pt_unique_const_name r_constraint_name, my_mode delete_rule, status
from wmsys.wm$ric_table rt, user_views uv
where uv.view_name = rt.ct_name and
      rt.ct_owner = (select username from all_users where user_id=userenv('schemaid')) ;
create or replace view wmsys.user_wm_vt_errors as
select vt.owner,vt.table_name,vt.state,vt.sql_str,et.status,et.error_msg
from (select t1.owner, t1.table_name, t1.disabling_ver state, nt.index_type, nt.index_field, dbms_lob.substr(nt.sql_str,4000,1) sql_str
      from wmsys.wm$versioned_tables t1, table(t1.undo_code) nt) vt,
     wmsys.wm$vt_errors_table et
where vt.owner = et.owner and
      vt.table_name = et.table_name and
      vt.index_type = et.index_type and
      vt.index_field = et.index_field and
      vt.owner = (select username from all_users where user_id=userenv('schemaid')) ;
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
where ult.workspace = spt.workspace ;
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
      dt.column_name = di.column_name ;
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
      ) ;
create or replace view wmsys.wm$current_workspace_view as
select workspace, parent_workspace, current_version, parent_version, post_version, verlist, owner, createtime, description,
       workspace_lock_id, freeze_status, freeze_mode, freeze_writer, oper_status, wm_lockmode, isrefreshed, freeze_owner,
       session_duration, implicit_sp_cnt, cr_status, sync_parver, last_change
from wmsys.wm$workspaces_table
where workspace = nvl(SYS_CONTEXT('lt_ctx','state'),'LIVE')
WITH READ ONLY ;
create or replace view wmsys.all_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable
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
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS','NO','YES') removable
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table asi,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table group by parent_workspace) max,
     (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = asi.workspace and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.user_workspace_savepoints as
select t.savepoint, t.workspace,
       decode(t.is_implicit, 0, 'NO', 1, 'YES') implicit, t.position,
       t.owner, t.createTime, t.description,
       decode(sign(t.version - max.pv), -1, 'NO', 'YES') canRollbackTo,
       decode(t.is_implicit || decode(parent_vers.parent_version, null, 'NOT_EXISTS', 'EXISTS'), '1EXISTS', 'NO', 'YES') removable
from wmsys.wm$workspace_savepoints_table t, wmsys.wm$workspaces_table u,
     (select max(parent_version) pv, parent_workspace pw from wmsys.wm$workspaces_table group by parent_workspace) max,
     (select unique parent_version from wmsys.wm$workspaces_table) parent_vers
where t.workspace = u.workspace and
      u.owner = (select username from all_users where user_id=userenv('schemaid')) and
      t.workspace = max.pw (+) and
      t.version = parent_vers.parent_version (+)
WITH READ ONLY ;
create or replace view wmsys.wm$conf1_hierarchy_view as
select version, parent_version, workspace
from wmsys.wm$version_hierarchy_table
start with version = (select current_version
                      from wmsys.wm$workspaces_table
                      where workspace = sys_context('lt_ctx', 'conflict_state'))
connect by prior parent_version = version
WITH READ ONLY ;
create or replace view wmsys.wm$conf2_hierarchy_view as
select version, parent_version, workspace
from wmsys.wm$version_hierarchy_table
start with version = (select current_version
                      from wmsys.wm$workspaces_table
                      where workspace = sys_context('lt_ctx', 'parent_conflict_state'))
connect by prior parent_version = version
WITH READ ONLY ;
create or replace view wmsys.wm$conf_base_hierarchy_view as
select version from wmsys.wm$version_hierarchy_table
  start with version = sys_context('lt_ctx', 'confbasever')
  connect by prior parent_version = version
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
       decode(admin, 0, 'NO',
                     1, 'YES') grantable
from wmsys.wm$workspace_priv_table where grantee in
   (select role from session_roles
    union all
    select 'WM_ADMIN_ROLE' from dual where (select username from all_users where user_id=userenv('schemaid')) = 'SYS')
WITH READ ONLY;
declare
  cursor vertab is
    select owner, table_name, hist, validtime
    from wmsys.wm$versioned_tables ;

  cursor nttab is
    select nt.owner, nt.table_name, nt.nt_store, vt.hist
    from wmsys.wm$versioned_tables vt, wmsys.wm$nested_columns_table nt
    where vt.owner = nt.owner and vt.table_name = vt.table_name ;

  procedure rename_column(tab_owner varchar2, tab_name varchar2, from_col varchar2, to_col varchar2) is
    cnt integer ;
  begin
    select count(*) into cnt
    from dba_tab_cols
    where owner = upper(tab_owner) and
          table_name = upper(tab_name) and
          column_name = upper(from_col) and
          user_generated = 'YES' ;

    if (cnt=1) then
      execute immediate 'alter table ' || tab_owner || '.' || tab_name || ' rename column ' || from_col || ' to ' || to_col ;
    end if ;
  end ;
begin
  for verrec in vertab loop
    rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_version', 'version') ;
    rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_nextver', 'nextver') ;
    rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_delstatus', 'delstatus') ;
    rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_ltlock', 'ltlock') ;

    if (verrec.hist <> 'NONE') then
      rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_createtime', 'createtime') ;
      rename_column(verrec.owner, verrec.table_name || '_LT', 'wm_retiretime', 'retiretime') ;
    end if ;

    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_childstate', 'childstate') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_parentstate', 'parentstate') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_snapshotchild', 'snapshotchild') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_versionchild', 'versionchild') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_snapshotparent', 'snapshotparent') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_versionparent', 'versionparent') ;
    rename_column(verrec.owner, verrec.table_name || '_AUX', 'wm_value', 'value') ;

    if (verrec.validtime=1) then
      rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_rid', 'rid') ;
      rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_version', 'version') ;
      rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_nextver', 'nextver') ;
      rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_delstatus', 'delstatus') ;
      rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_ltlock', 'ltlock') ;

      if (verrec.hist <> 'NONE') then
        rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_createtime', 'createtime') ;
        rename_column(verrec.owner, verrec.table_name || '_VT', 'wm_retiretime', 'retiretime') ;
      end if ;
    end if ;
  end loop;

  for ntrec in nttab loop
    rename_column(ntrec.owner, ntrec.table_name || '_LT', 'WM_' || ntrec.nt_store, 'WM$' || ntrec.nt_store) ;
    rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'WM_' || ntrec.nt_store, 'WM$' || ntrec.nt_store) ;

    rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_version', 'version') ;
    rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_nextver', 'nextver') ;
    rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_delstatus', 'delstatus') ;
    rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_ltlock', 'ltlock') ;

    if (ntrec.hist <> 'NONE') then
      rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_createtime', 'createtime') ;
      rename_column(ntrec.owner, ntrec.nt_store || '_LT', 'wm_retiretime', 'retiretime') ;
    end if ;
  end loop ;
end;
/
declare
  cnt integer ;
begin
  for vt_rec in (select vtid, owner, table_name from wmsys.wm$versioned_tables) loop
    select count(*) into cnt
    from wmsys.wm$modified_tables
    where table_name = vt_rec.owner || '.' || vt_rec.table_name and
          version = 0 ;

    if (cnt=0) then
      insert into wmsys.wm$modified_tables values(vt_rec.vtid, vt_rec.owner || '.' || vt_rec.table_name, 0, 'LIVE') ;
      commit ;
    end if ;
  end loop;
end;
/
revoke alter session from wmsys ;
revoke create indextype from wmsys ;
revoke create operator from wmsys ;
revoke create session from wmsys ;
revoke create type from wmsys ;
revoke inherit any privileges from wmsys ;
revoke create user from wmsys ;
revoke drop user from wmsys ;
revoke inherit privileges on user sys from wmsys ;
grant connect, resource to wmsys ;
grant select any dictionary to wmsys with admin option ;
grant select on sys.dba_views to wmsys with grant option ;
grant execute on sys.dbms_lob to wmsys with grant option ;
grant execute on sys.aq$_history to wmsys with grant option ;
drop type wmsys.wm$oper_lockvalues_array_type ;
drop type wmsys.wm$oper_lockvalues_type ;
create or replace type wmsys.IntToStr_array_type is varray(50) of varchar2(50) ;
/
create or replace type wmsys.trigOptionsType is varray(15) of varchar2(100) ;
/
create or replace type wmsys.oper_lockvalues_type wrapped 
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
d
5e 7d
LlIgANKXSyegLxxB8Z3ogJ+Uqt8wg5n0dLhchZZaYhhy+q7/0QxHPi5iSpYmVlpcuHQrpb+b
wDLLs+e4dJ7H0r0yXKXSmVIyv7IlzLjL6R/7f2mVIZTYiKZrn/0I

/
create or replace type wmsys.oper_lockvalues_array_type as varray(50) of wmsys.oper_lockvalues_type ;
/
drop type wmsys.wm$lock_table_type ;
drop type wmsys.wm$lock_info_type ;
create type wmsys.wm$lock_info_type timestamp '2001-07-29:12:06:07' OID '8A3DB78598BD5DE2E034080020EDC61B' wrapped 
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
d
86 9a
dUu/IehjseaaMx+QoVfFHanq/2Uwg5n0dLhcFnJc+vqu/0pyRwzZ0JYmVlpDwHQrpb+bwDLL
s+dS9ZtS8P4o/seyCefHdMAzuHRlJXx/UHfuCakd46skgA/qRG4nenNo5Dh+U6uEHR0uLkT2
OaZKRsqe

/
create type wmsys.wm$lock_table_type timestamp '2001-07-29:12:06:07' OID '8A3DB78598C35DE2E034080020EDC61B'
as table of wmsys.wm$lock_info_type ;
/
execute wmsys.wm$execSQL('grant execute on wmsys.wm$lock_table_type to public');
exec dbms_aqadm.stop_queue(queue_name => 'WMSYS.WM$EVENT_QUEUE');
exec dbms_aqadm.drop_queue(queue_name => 'WMSYS.WM$EVENT_QUEUE');
exec dbms_aqadm.drop_queue_table(queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE', force => true);
drop type wmsys.wm$event_type ;
create or replace type wmsys.wm$event_type timestamp '2003-05-20:10:08:59' OID 'BE1A0D04EFDE6F80E034080020B6D531' wrapped 
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
d
142 e7
MW5BczEfwDyYRCQnNB8uYnBS8Aowg5n0dLhcFnJcoWIM19X0liZWWkPAdCulv5vAMsvMULiy
x4GZ9P7H0jJcZzk4SjX/HEo1YKtAOTnse3FaZe75NRmv+0r/4k3sj6tfs3dbVzk3fmexQF4Q
EUv2L+gSuAooUvWbUpWG+4IhgUpr8whneK2SOYxNKP6ySnQ8mf5cCJkd8hLhkC/TLOF0rS5E
9jmm/Gtgow==

/
begin
  dbms_aqadm.create_queue_table(queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
                                storage_clause => 'nested table user_data.aux_params store as WM$EVENT_AUX_PARAMS_NT',
                                multiple_consumers => TRUE,
                                queue_payload_type => 'WMSYS.WM$EVENT_TYPE');
end ;
/
begin
  dbms_aqadm.create_queue(queue_name => 'WMSYS.WM$EVENT_QUEUE',
                          queue_table => 'WMSYS.WM$EVENT_QUEUE_TABLE',
                          comment => 'OWM Events Queue');
end;
/
begin
  dbms_aqadm.start_queue(queue_name => 'WMSYS.WM$EVENT_QUEUE');
end;
/
grant select on wmsys.aq$wm$event_queue_table to aq_administrator_role, wm_admin_role ;
grant select on wmsys.aq$wm$event_queue_table_s to aq_administrator_role, wm_admin_role ;
grant select on wmsys.aq$wm$event_queue_table_r to aq_administrator_role, wm_admin_role ;
begin
  for vt_rec in (select owner, table_name, hist from wmsys.wm$versioned_tables) loop
    execute immediate 'alter table ' || vt_rec.owner || '.' || vt_rec.table_name || '_AUX modify (childstate varchar2(30))' ;
    execute immediate 'alter table ' || vt_rec.owner || '.' || vt_rec.table_name || '_AUX modify (parentstate varchar2(30))' ;

    if (vt_rec.hist='NONE') then
      execute immediate 'drop view ' || vt_rec.owner || '.' || vt_rec.table_name || '_HIST' ;
    end if ;
  end loop;
end;
/
drop view wmsys.wm$exp_map ;
drop table wmsys.wm$exp_map_tbl ;
drop type wmsys.wm$exp_map_tab ;
drop type wmsys.wm$exp_map_type ;
delete sys.impcalloutreg$ where tag='WMSYS' ;
commit ;
create or replace public synonym all_workspaces_internal for wmsys.all_workspaces_internal ;
create or replace public synonym wm$all_version_hview_wdepth for wmsys.all_version_hview_wdepth;
create or replace public synonym wm$base_hierarchy_view for wmsys.wm$base_hierarchy_view;
create or replace public synonym wm$base_nextver_view for wmsys.wm$base_nextver_view;
create or replace public synonym wm$base_version_view for wmsys.wm$base_version_view;
create or replace public synonym wm$conf1_hierarchy_view for wmsys.wm$conf1_hierarchy_view;
create or replace public synonym wm$conf1_nextver_view for wmsys.wm$conf1_nextver_view;
create or replace public synonym wm$conf2_hierarchy_view for wmsys.wm$conf2_hierarchy_view;
create or replace public synonym wm$conf2_nextver_view for wmsys.wm$conf2_nextver_view;
create or replace public synonym wm$conf_base_hierarchy_view for wmsys.wm$conf_base_hierarchy_view;
create or replace public synonym wm$conf_base_nextver_view for wmsys.wm$conf_base_nextver_view;
create or replace public synonym wm$curconflict_nextvers_view for wmsys.wm$curconflict_nextvers_view;
create or replace public synonym wm$curconflict_parvers_view for wmsys.wm$curconflict_parvers_view;
create or replace public synonym wm$current_child_versions_view for wmsys.wm$current_child_versions_view;
create or replace public synonym wm$current_cons_nextvers_view for wmsys.wm$current_cons_nextvers_view;
create or replace public synonym wm$current_cons_versions_view for wmsys.wm$current_cons_versions_view;
create or replace public synonym wm$current_nextvers_view for wmsys.wm$current_nextvers_view;
create or replace public synonym wm$current_parvers_view for wmsys.wm$current_parvers_view;
create or replace public synonym wm$current_workspace_view for wmsys.wm$current_workspace_view;
create or replace public synonym wm$diff1_hierarchy_view for wmsys.wm$diff1_hierarchy_view;
create or replace public synonym wm$diff1_nextver_view for wmsys.wm$diff1_nextver_view;
create or replace public synonym wm$diff2_hierarchy_view for wmsys.wm$diff2_hierarchy_view;
create or replace public synonym wm$diff2_nextver_view for wmsys.wm$diff2_nextver_view;
create or replace public synonym wm$mw_nextvers_view for wmsys.wm$mw_nextvers_view;
create or replace public synonym wm$mw_versions_view_9i for wmsys.wm$mw_versions_view_9i;
create or replace public synonym wm$parconflict_nextvers_view for wmsys.wm$parconflict_nextvers_view;
create or replace public synonym wm$parconflict_parvers_view for wmsys.wm$parconflict_parvers_view;
create or replace public synonym wm$parvers_view for wmsys.wm$parvers_view;
create or replace public synonym wm$table_parvers_view for wmsys.wm$table_parvers_view;
create or replace public synonym wm$table_versions_in_live_view for wmsys.wm$table_versions_in_live_view;
create or replace public synonym wm$table_ws_parvers_view for wmsys.wm$table_ws_parvers_view;
create or replace public synonym wm_concat for wmsys.wm_concat;
create or replace public synonym wm_replication_info for wmsys.wm$replication_info;
grant select on wmsys.all_mp_graph_workspaces to public with grant option;
grant select on wmsys.all_mp_parent_workspaces to public with grant option;
grant select on wmsys.all_removed_workspaces to public with grant option;
grant select on wmsys.all_version_hview to public with grant option;
grant select on wmsys.all_version_hview_wdepth to public with grant option;
grant select on wmsys.all_wm_constraints to public with grant option;
grant select on wmsys.all_wm_cons_columns to public with grant option;
grant select on wmsys.all_wm_ind_columns to public with grant option;
grant select on wmsys.all_wm_ind_expressions to public with grant option;
grant select on wmsys.all_wm_locked_tables to public with grant option;
grant select on wmsys.all_wm_modified_tables to public with grant option;
grant select on wmsys.all_wm_ric_info to public with grant option;
grant select on wmsys.all_wm_tab_triggers to public with grant option;
grant select on wmsys.all_wm_versioned_tables to public with grant option;
grant select on wmsys.all_wm_vt_errors to public with grant option;
grant select on wmsys.all_workspaces to public with grant option;
grant select on wmsys.all_workspaces_internal to public with grant option;
grant select on wmsys.all_workspace_privs to public with grant option;
grant select on wmsys.all_workspace_savepoints to public with grant option;
grant execute on wmsys.lt_ctx_pkg to public;
grant execute on wmsys.lt_export_pkg to public;
grant execute on wmsys.owm_vt_pkg to public;
grant select on wmsys.role_wm_privs to public with grant option;
grant select on wmsys.user_mp_graph_workspaces to public with grant option;
grant select on wmsys.user_mp_parent_workspaces to public with grant option;
grant select on wmsys.user_removed_workspaces to public with grant option;
grant select on wmsys.user_wm_constraints to public with grant option;
grant select on wmsys.user_wm_cons_columns to public with grant option;
grant select on wmsys.user_wm_ind_columns to public with grant option;
grant select on wmsys.user_wm_ind_expressions to public with grant option;
grant select on wmsys.user_wm_locked_tables to public with grant option;
grant select on wmsys.user_wm_modified_tables to public with grant option;
grant select on wmsys.user_wm_privs to public with grant option;
grant select on wmsys.user_wm_ric_info to public with grant option;
grant select on wmsys.user_wm_tab_triggers to public with grant option;
grant select on wmsys.user_wm_versioned_tables to public with grant option;
grant select on wmsys.user_wm_vt_errors to public with grant option;
grant select on wmsys.user_workspaces to public with grant option;
grant select on wmsys.user_workspace_privs to public with grant option;
grant select on wmsys.user_workspace_savepoints to public with grant option;
grant select on wmsys.wm$all_locks_view to public with grant option;
grant select on wmsys.wm$base_hierarchy_view to public with grant option;
grant select on wmsys.wm$base_nextver_view to public with grant option;
grant select on wmsys.wm$base_version_view to public with grant option;
grant select on wmsys.wm$conf1_hierarchy_view to public with grant option;
grant select on wmsys.wm$conf1_nextver_view to public with grant option;
grant select on wmsys.wm$conf2_hierarchy_view to public with grant option;
grant select on wmsys.wm$conf2_nextver_view to public with grant option;
grant select on wmsys.wm$conf_base_hierarchy_view to public with grant option;
grant select on wmsys.wm$conf_base_nextver_view to public with grant option;
grant select on wmsys.wm$curconflict_nextvers_view to public with grant option;
grant select on wmsys.wm$curconflict_parvers_view to public with grant option;
grant select on wmsys.wm$current_child_versions_view to public with grant option;
grant select on wmsys.wm$current_cons_nextvers_view to public with grant option;
grant select on wmsys.wm$current_cons_versions_view to public with grant option;
grant select on wmsys.wm$current_mp_join_points to public with grant option;
grant select on wmsys.wm$current_nextvers_view to public with grant option;
grant select on wmsys.wm$current_parvers_view to public with grant option;
grant select on wmsys.wm$current_workspace_view to public with grant option;
grant select on wmsys.wm$diff1_hierarchy_view to public with grant option;
grant select on wmsys.wm$diff1_nextver_view to public with grant option;
grant select on wmsys.wm$diff2_hierarchy_view to public with grant option;
grant select on wmsys.wm$diff2_nextver_view to public with grant option;
grant execute on wmsys.wm$ed_undo_code_node_type to public;
grant execute on wmsys.wm$ed_undo_code_table_type to public;
grant execute on wmsys.wm$event_type to public with grant option;
grant execute on wmsys.wm$lock_table_type to public;
grant select on wmsys.wm$modified_tables_view to public with grant option;
grant select on wmsys.wm$mp_join_points to public with grant option;
grant select on wmsys.wm$mw_nextvers_view to public with grant option;
grant select on wmsys.wm$mw_versions_view_9i to public with grant option;
grant select on wmsys.wm$net_diff1_hierarchy_view to public with grant option;
grant select on wmsys.wm$net_diff2_hierarchy_view to public with grant option;
grant execute on wmsys.wm$nv_pair_nt_type to public with grant option;
grant execute on wmsys.wm$nv_pair_type to public with grant option;
grant select on wmsys.wm$parconflict_nextvers_view to public with grant option;
grant select on wmsys.wm$parconflict_parvers_view to public with grant option;
grant select on wmsys.wm$parvers_view to public with grant option;
grant select on wmsys.wm$replication_info to public;
grant select on wmsys.wm$table_parvers_view to public with grant option;
grant select on wmsys.wm$table_versions_in_live_view to public with grant option;
grant select on wmsys.wm$table_ws_parvers_view to public with grant option;
grant execute on wmsys.wm_concat to public;
grant execute on wmsys.wm_concat_impl to public;
grant execute on wmsys.wm_error to public;
grant select on wmsys.wm_events_info to public with grant option;
grant select on wmsys.wm_installation to public with grant option;
grant execute on wmsys.wm_period to public with grant option;
exec wmsys.wm$execSQL('grant execute on wmsys.ltadm to imp_full_database') ;
exec wmsys.wm$execSQL('grant delete on wmsys.wm$version_hierarchy_table to imp_full_database') ;
exec wmsys.wm$execSQL('grant delete on wmsys.wm$workspaces_table to imp_full_database') ;
exec wmsys.wm$execSQL('grant delete on wmsys.wm$workspace_priv_table to imp_full_database') ;
exec wmsys.wm$execSQL('revoke select on dba_removed_workspaces from select_catalog_role') ;
exec wmsys.wm$execSQL('revoke select on dba_wm_vt_errors from select_catalog_role') ;
exec wmsys.wm$execSQL('revoke select on dba_workspace_sessions from select_catalog_role') ;
drop view wmsys.all_wm_policies ;
drop view wmsys.user_wm_policies ;
drop public synonym all_wm_policies ;
drop public synonym user_wm_policies ;
alter type wmsys.wm_period drop MAP member function wm_period_map return varchar2 cascade ;
drop type body wmsys.wm_period ;
