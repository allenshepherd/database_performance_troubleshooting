WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
@@?/rdbms/admin/sqlsessstart.sql
@@owmcmdv.plb 'RELOD'
begin
  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS') ;
end;
/
@@owmwmsys.plb
@@owmcpkgs.plb
begin
  wmsys.owm_vscript_pkg.upgradeOWM(:old_owm_version_for_upgrade) ;
end;
/
delete wmsys.wm$env_vars where name not in(select name from wmsys.wm$sysparam_all_values) and hidden=0;
commit ;
@@owmcvws.plb
@@owmcpkgb.plb
execute wmsys.owm_mig_pkg.enableversionTopoIndexTables ;
execute wmsys.owm_mig_pkg.AllLwEnableVersioning(:old_owm_version_for_upgrade) ;
execute wmsys.owm_mig_pkg.recreatePtUpdDelTriggers;
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
exec dbms_registry.loaded('OWM') ;
exec sys.validate_owm ;
@@?/rdbms/admin/sqlsessend.sql
