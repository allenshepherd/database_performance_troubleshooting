@@?/rdbms/admin/sqlsessstart.sql
declare
  cnt  integer;
begin
  select count(*) into cnt
  from dba_users
  where username = 'WMSYS';

  if (cnt=1) then
    return ;
  end if ;

  select count(*) into cnt
  from dba_tablespaces
  where tablespace_name = 'SYSAUX';

  if (cnt > 0) then
    execute immediate 'create user wmsys identified by wmsys account lock password expire default tablespace SYSAUX';
  end if;
end;
/
begin
  for trig_rec in (select trigger_name from dba_triggers where owner = 'WMSYS') loop
    execute immediate 'alter trigger wmsys.' || trig_rec.trigger_name || ' disable';
  end loop ;

  for trig_rec in (select trigger_name
                   from dba_triggers
                   where owner = 'SYS' and
                         trigger_name in ('NO_VM_CREATE', 'NO_VM_DROP', 'NO_VM_DROP_A', 'NO_VM_ALTER', 'SYS_LOGOFF', 'SYS_LOGON')) loop
    execute immediate 'drop trigger sys.' || trig_rec.trigger_name ;
  end loop ;
end ;
/
begin
  for p_rec in (select object_name from dba_objects where owner = 'WMSYS' and object_type='PACKAGE') loop
    execute immediate 'drop package wmsys.' || p_rec.object_name ;
  end loop ;
end;
/
@@owmasrts.plb
@@owmasrtb.plb
@@owmvpkgs.plb
@@owmvpkgb.plb
declare
  wm$ident_len integer := 128 ;

  type_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(type_error, -22324);

  function wm$objectExists(obj_name varchar2, obj_owner varchar2 default 'WMSYS', obj_type varchar2 default 'TABLE') return boolean is
    cnt integer ;
  begin
    select count(*) into cnt
    from dba_objects
    where owner = upper(obj_owner) and
          object_name = upper(obj_name) and
          object_type = upper(obj_type) ;

    return (cnt>0) ;
  end ;
begin
  if (not wm$objectExists('WM$ED_UNDO_CODE_NODE_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$ed_undo_code_node_type TIMESTAMP ''2001-07-29:12:08:55'' OID ''8A3DA47750525DCEE034080020EDC61B'' authid definer
         as object (index_type   integer,
                    index_field  integer,
                    sql_str      clob)' ;
  end if ;

  if (not wm$objectExists('WM$ED_UNDO_CODE_TABLE_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$ed_undo_code_table_type TIMESTAMP ''2001-07-29:12:08:55'' OID ''8A3DA47750585DCEE034080020EDC61B''
         as table of wmsys.wm$ed_undo_code_node_type' ;
  end if ;

  if (wm$objectExists('WM$LOCK_TABLE_TYPE', obj_type=>'TYPE')) then
    execute immediate 'drop type wmsys.wm$lock_table_type' ;
  end if ;

  if (wm$objectExists('WM$LOCK_INFO_TYPE', obj_type=>'TYPE')) then
    execute immediate 'drop type wmsys.wm$lock_info_type' ;
  end if ;

  if (not wm$objectExists('WM$LOCK_INFO_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$lock_info_type TIMESTAMP ''2001-07-29:12:06:07'' OID ''8A3DB78598BD5DE2E034080020EDC61B'' authid definer
         as object (table_owner  varchar2(' || wm$ident_len || '),
                    table_name   varchar2(' || wm$ident_len || '),
                    info         varchar2(100))' ;
  end if ;

  if (not wm$objectExists('WM$LOCK_TABLE_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$lock_table_type TIMESTAMP ''2001-07-29:12:06:07'' OID ''8A3DB78598C35DE2E034080020EDC61B''
        as table of wmsys.wm$lock_info_type' ;
  end if ;

  if (not wm$objectExists('WM$NEXTVER_EXP_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$nextver_exp_type authid definer
         as object (next_vers  integer,
                    orig_nv    varchar2(500),
                    rid        varchar2(100))' ;
  end if ;

  if (not wm$objectExists('WM$NEXTVER_EXP_TAB_TYPE', obj_type=>'TYPE')) then
    execute immediate 'create or replace type wmsys.wm$nextver_exp_tab_type as table of wmsys.wm$nextver_exp_type' ;
  end if ;

  if (not wm$objectExists('WM$NV_PAIR_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$nv_pair_type TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE1A0D04EFD56F80E034080020B6D531'' authid definer
         as object (name   varchar2(100),
                    value  clob)' ;
  end if ;

  if (not wm$objectExists('WM$NV_PAIR_NT_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$nv_pair_nt_type TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE2E13E3081301C7E034080020B6D531''
        as table of WMSYS.WM$NV_PAIR_TYPE' ;
  end if ;

  if (not wm$objectExists('WM$EVENT_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$event_type TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE1A0D04EFDE6F80E034080020B6D531'' authid definer
         as object (event_name             varchar2(' || wm$ident_len || '),
                    workspace_name         varchar2(' || wm$ident_len || '),
                    parent_workspace_name  varchar2(' || wm$ident_len || '),
                    user_name              varchar2(' || wm$ident_len || '),
                    table_name             varchar2(' || wm$ident_len || '),
                    aux_params             wmsys.wm$nv_pair_nt_type)' ;
  end if ;

  if (not wm$objectExists('WM$OPER_LOCKVALUES_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$oper_lockvalues_type authid definer
         as object (parValue    integer,
                    curValue    integer,
                    interValue  integer)' ;
  end if ;

  if (not wm$objectExists('WM$OPER_LOCKVALUES_ARRAY_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$oper_lockvalues_array_type as varray(50) of wmsys.wm$oper_lockvalues_type' ;
  end if ;

  if (not wm$objectExists('WM$IDENT_TAB_TYPE', obj_type=>'TYPE')) then
    execute immediate 'create or replace type wmsys.wm$ident_tab_type as table of varchar2(' || wm$ident_len || ')' ;
  end if ;

  if (not wm$objectExists('WM_PERIOD', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm_period TIMESTAMP ''2003-05-21:10:52:30'' OID ''BE2DC636D843039BE034080020EDC61B'' authid definer
         as object (validfrom timestamp with time zone,
                    validtill timestamp with time zone)';
  end if ;

  begin
    execute immediate 'alter type wmsys.wm_period add MAP member function wm_period_map return varchar2 cascade' ;
  exception when type_error then null ;
  end;

  if (not wm$objectExists('WM$EXP_MAP_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$exp_map_type authid definer
         as object (code     integer,
                    nfield1  number,
                    nfield2  number,
                    nfield3  number,
                    vfield1  varchar2(128),
                    vfield2  varchar2(128),
                    vfield3  clob)' ;
  end if ;

  if (not wm$objectExists('WM$EXP_MAP_TAB', obj_type=>'TYPE')) then
    execute immediate 'create or replace type wmsys.wm$exp_map_tab as table of wmsys.wm$exp_map_type' ;
  end if ;

  if (not wm$objectExists('WM$METADATA_MAP_TYPE', obj_type=>'TYPE')) then
    execute immediate
      'create or replace type wmsys.wm$metadata_map_type authid definer
         as object (code           integer,
                    nfield1        number,
                    nfield2        number,
                    nfield3        number,
                    vfield1        varchar2(128),
                    vfield2        varchar2(128),
                    vfield3        clob,
                    wm_version     integer,
                    wm_nextver     varchar2(500),
                    wm_delstatus   number,
                    wm_ltlock      varchar2(150),
                    wm_createtime  timestamp with time zone,
                    wm_retiretime  timestamp with time zone,
                    wm_validfrom   timestamp with time zone,
                    wm_validtill   timestamp with time zone)' ;
  end if ;

  if (not wm$objectExists('WM$METADATA_MAP_TAB', obj_type=>'TYPE')) then
    execute immediate 'create or replace type wmsys.wm$metadata_map_tab as table of wmsys.wm$metadata_map_type' ;
  end if ;

  for trec in (select object_name
               from dba_objects
               where owner = 'WMSYS' and
                     object_type = 'TYPE' and
                     status <> 'VALID') loop
    execute immediate 'alter type WMSYS.' || sys.dbms_assert.enquote_name(trec.object_name, false) || ' compile' ;
  end loop ;
end ;
/
create or replace type body wmsys.wm_period wrapped 
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
e
db ef
IQMBRbtfSUi1VSiJ59958/Z/MQIwgxDwa8sVfI7ps/gYwUVsFnZY/IN4FpMFQ4F5aVwdDC82
rK+KhpOEfOfiU+pubnFKAOaGMkaxYgDRch5zdBuOpiszcLPfWlDL3C0Iy0rfgVrUHok+qChd
cIkaM/HfLDuvkFLZFR8DroicqEBGSRsmV7LYl8yfYMRdeQ05Uuet66CUlEeC45NdOgrCKUUP
DYdKsylFhQ0jHdFt2m4=

/
declare
  no_grant EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_grant, -01927);
begin
  
  wmsys.owm_vscript_pkg.wm$addRecord('ALTER ANY INDEX', null, null, 'WMSYS', ctype=>'SYSPRIV', firstE=>true) ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY INDEX', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY INDEX', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER ANY PROCEDURE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY PROCEDURE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY PROCEDURE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE ANY PROCEDURE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER SESSION', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  

  
  

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DELETE ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('INSERT ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('UPDATE ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER ANY TRIGGER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY TRIGGER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY TRIGGER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE ANY TYPE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER USER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE USER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP USER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY VIEW', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY VIEW', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ALTER ANY SEQUENCE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CREATE ANY SEQUENCE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DROP ANY SEQUENCE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT ANY SEQUENCE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  wmsys.owm_vscript_pkg.wm$addRecord('ADMINISTER DATABASE TRIGGER', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  
  
  
  wmsys.owm_vscript_pkg.wm$addRecord('INHERIT ANY PRIVILEGES', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('LOCK ANY TABLE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT ANY DICTIONARY', null, null, 'WMSYS', ctype=>'SYSPRIV') ;
  wmsys.owm_vscript_pkg.wm$addRecord('UNLIMITED TABLESPACE', null, null, 'WMSYS', ctype=>'SYSPRIV') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_AQ', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_AQ_BQVIEW', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_AQADM', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_LOB', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_LOCK', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_REGISTRY', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_RLS', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'DBMS_UTILITY', 'WMSYS', ctype=>'PACKAGE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'SYS', 'UTL_FILE', 'WMSYS', ctype=>'PACKAGE') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('INSERT', 'SYS', 'NOEXP$', 'WMSYS', ctype=>'TABLE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DELETE', 'SYS', 'NOEXP$', 'WMSYS', ctype=>'TABLE') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('INHERIT PRIVILEGES', null, 'SYS', 'WMSYS', ctype=>'USER') ;

  
  for priv_rec in (select granted_role privilege, grantee, admin_option, 'ROLE' ctype, common
                    from dba_role_privs
                    where grantee = 'WMSYS' and
                          granted_role <> 'WM_ADMIN_ROLE'
                   union all
                    select privilege, grantee, admin_option, 'SYSPRIV' ctype, common
                    from dba_sys_privs
                    where grantee = 'WMSYS') loop

    wmsys.owm_vscript_pkg.wm$checkExistingRecord(priv_rec.privilege, null, null, priv_rec.grantee, priv_rec.admin_option, priv_rec.common, priv_rec.ctype) ;
  end loop ;

  
  for priv_rec in (select privilege, grantee, owner, table_name, grantable, type, common
                   from dba_tab_privs dtp
                   where grantee = 'WMSYS' and
                         type <> 'USER' and
                         (owner || '.' || table_name) not like 'SYS.QT%BUFFER' and
                         (owner || '.' || table_name) not in ('SYS.AQ$_UNFLUSHED_DEQUEUES') and
                         not exists(select 1
                                    from dba_nested_tables nt
                                    where dtp.owner = nt.owner and
                                          dtp.table_name = nt.table_name)
                  union all
                   select privilege, grantee, null, table_name, grantable, type, common
                   from dba_tab_privs
                   where (grantee = 'WMSYS' or table_name = 'WMSYS') and
                         type = 'USER') loop

    wmsys.owm_vscript_pkg.wm$checkExistingRecord(priv_rec.privilege, priv_rec.owner, priv_rec.table_name, priv_rec.grantee, priv_rec.grantable, priv_rec.common, priv_rec.type) ;
  end loop ;

  wmsys.owm_vscript_pkg.wm$execRecords ;
end ;
/
@@?/rdbms/admin/sqlsessend.sql
