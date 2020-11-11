declare
  found  integer ;
begin
  select 1 into found
  from dba_registry
  where comp_id = 'OWM' ;

  dbms_registry.upgrading('OWM', new_proc=>'VALIDATE_OWM');

exception when no_data_found then
  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
  dbms_registry.loaded('OWM', :old_owm_version_for_upgrade, 'Oracle Workspace Manager Release ' || :old_owm_version_for_upgrade);
  dbms_registry.upgrading('OWM');
end;
/
@@owmwmsys.plb
@@owmcpkgs.plb
begin
  wmsys.owm_vscript_pkg.upgradeOWM(:old_owm_version_for_upgrade) ;
end;
/
@@owmcvws.plb
@@owmcpkgb.plb
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;
execute wmsys.owm_mig_pkg.AllLwEnableVersioning(:old_owm_version_for_upgrade) ;
execute wmsys.owm_mig_pkg.recreatePtUpdDelTriggers;
execute wmsys.owm_mig_pkg.moveWMMetaData('SYSAUX') ;
execute wmsys.owm_mig_pkg.fixWMMetaData(:old_owm_version_for_upgrade) ;
execute wmsys.owm_mig_pkg.recompileAllObjects ;
execute wmsys.owm_mig_pkg.modifySystemTriggers('ENABLE_T') ;
revoke inherit privileges on user sys from wmsys ;
create or replace public synonym dbms_wm for wmsys.lt ;
create or replace synonym dbms_wm for wmsys.ltsys ;
select owner, name, type, line, position, substr(regexp_substr(text, '^[[:alnum:] :/-]+: (.*)', 1, 1, 'i', 1), 1, 100) text, attribute, message_number
from dba_errors
where owner = 'WMSYS' or
      owner in (select owner from wmsys.wm$versioned_tables)
order by 1,2,3,4,5,8;
select * from wmsys.wm$migration_error_view ;
declare
  ver wmsys.ltUtil.wm$ident ;
begin
  if (1=1) then
    dbms_registry.upgraded('OWM');
  else
    select value into ver
    from wmsys.wm$env_vars
    where name = 'OWM_VERSION' and
          hidden = 1;

    dbms_registry.upgraded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Production');
  end if ;

  execute immediate 'begin sys.validate_owm(:1); end;' using :old_owm_version_for_upgrade ;
end;
/
