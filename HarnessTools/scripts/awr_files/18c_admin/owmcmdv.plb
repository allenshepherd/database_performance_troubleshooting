var old_owm_version_for_upgrade varchar2(128);
declare
  tab_owner    varchar2(128) ;
  tab_name     varchar2(128) ;
  release_ver  varchar2(128) ;
  cname        varchar2(128) ;
  cnt          integer;
  pdbstatus    number;

  function wm$convertVersionStr(version_str varchar2) return varchar2 is
    lpos integer := 1;
    npos integer ;

    ver_str     varchar2(100) := version_str ;
    hex_db_ver  varchar2(100);
    db_ver      varchar2(5);
    curnum      varchar2(100) ;
  begin
    if (regexp_substr(version_str, '^[[:digit:].]+$') is null) then
      return version_str ;
    end if ;

    if (substr(version_str, -1) <> '.') then
      ver_str := ver_str || '.' ;
    end if ;

    loop
      npos := instr(ver_str, '.', lpos, 1) ;
      exit when npos = 0 ;

      curnum := to_number(substr(ver_str, lpos, npos-lpos));
      lpos := npos+1 ;

      db_ver :=
        case
          when (curnum>=10 and curnum<=30) then chr(curnum + 55)
          when (curnum>=0 and curnum<=9) then chr(curnum + 48)
          else 'X'
        end ;

      if (hex_db_ver is not null) then
        hex_db_ver := hex_db_ver || '.' || db_ver ;
      else
        hex_db_ver := db_ver ;
      end if ;
    end loop ;

    return hex_db_ver ;
  end;
begin
  select decode(sys_context('userenv', 'cdb_name'), null, null, sys_context('userenv', 'con_name')) into cname
  from sys.dual ;

  if (cname is null) then
    pdbstatus := -1 ;
  elsif (cname = 'CDB$ROOT') then
    pdbstatus := 0 ;
  else
    pdbstatus := 1 ;
  end if;

  if (pdbstatus <> 1) then
    begin
      select version into release_ver
      from dba_registry
      where comp_id = 'OWM' ;

    exception when no_data_found then null;
      release_ver := 'NO_REGISTRY' ;
    end ;

    if (release_ver = 'NO_REGISTRY') then
      begin
        select owner, object_name into tab_owner, tab_name
        from dba_objects
        where owner in ('SYSTEM', 'WMSYS') and
              object_name = 'WM$ENV_VARS' and
              object_type in ('TABLE', 'VIEW') ;

        release_ver := 'INSTALLED' ;

      exception when no_data_found then null;
        release_ver := 'NOT_INSTALLED' ;
      end ;
    end if ;

    if (release_ver = 'INSTALLED') then
      begin
        execute immediate
          'select value
           from ' || tab_owner || '.' || tab_name || '
           where name = ''OWM_VERSION''' into release_ver;

      exception when no_data_found then null;
      end ;
    end if ;

    if (release_ver = 'INSTALLED') then
      select count(*) into cnt
      from dba_objects
      where owner = 'SYSTEM' and
            object_name = 'WM$LOCKROWS_INFO' and
            object_type = 'TABLE' ;

      if (cnt = 1) then
        release_ver := '9.0.1.0.0';
      else
        release_ver := 'BETA RELEASE';
      end if;
    end if ;

    if ('&1' = 'UPGRADE') then
      begin
        select owner, object_name into tab_owner, tab_name
        from dba_objects
        where owner in ('SYS', 'WMSYS') and
              object_name = 'WM$VERSIONED_TABLES' and
              object_type in ('TABLE', 'VIEW') ;

        execute immediate
          'select count(*)
           from ' || tab_owner || '.' || tab_name || '
           where disabling_ver <> ''VERSIONED''' into cnt ;

        if (cnt>0) then
          release_ver := 'NO INSTALL - Migrating Tables' ;
        end if ;

      exception when no_data_found then
        release_ver := 'NOT_INSTALLED' ;
      end ;

      begin
        select owner, object_name into tab_owner, tab_name
        from dba_objects
        where owner in ('SYS', 'WMSYS') and
              object_name = 'WM$REPLICATION_TABLE' and
              object_type in ('TABLE', 'VIEW') ;

        execute immediate
          'select count(*)
           from ' || tab_owner || '.' || tab_name || '
           where status = ''E''' into cnt ;

        if (cnt>0) then
          release_ver := 'NO INSTALL - Replication' ;
        end if ;

      exception when no_data_found then
        if (nlssort(wm$convertVersionStr(release_ver), 'nls_sort=ascii7') < nlssort('C.2.0.0.0', 'nls_sort=ascii7')) then
          release_ver := 'NOT_INSTALLED' ;
        end if ;
      end ;
    end if ;

    :old_owm_version_for_upgrade := wm$convertVersionStr(release_ver) ;

  else
    select version into release_ver
    from dba_registry
    where comp_id = 'OWM';

    :old_owm_version_for_upgrade := wm$convertVersionStr(release_ver) ;

    select count(*) into cnt
    from dba_triggers
    where owner = 'WMSYS' and
          trigger_name = 'NO_VM_DDL' and
          status = 'ENABLED' ;

    if (cnt>0) then
      execute immediate 'alter trigger wmsys.no_vm_ddl disable' ;
    end if ;

    execute immediate
      'create or replace view wmsys.wm_installation sharing=none as
         select cast(''OWM_VERSION'' as varchar2(128)) name, cast(version as varchar2(4000)) value
         from sys.registry$
         where cid = ''OWM''' ;
  end if ;
end;
/
select :old_owm_version_for_upgrade from sys.dual ;
