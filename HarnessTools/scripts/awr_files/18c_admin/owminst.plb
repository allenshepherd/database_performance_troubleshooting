@@?/rdbms/admin/sqlsessstart.sql
alter session set nls_length_semantics=byte;
@@owmwmsys.plb
begin
  dbms_registry.loading('OWM', 'Oracle Workspace Manager', 'VALIDATE_OWM', 'WMSYS');
end;
/
@@owmcpkgs.plb
execute wmsys.owm_vscript_pkg.upgradeOWM('INSTALL') ;
@@owmcvws.plb
@@owmcpkgb.plb
revoke inherit privileges on user sys from wmsys ;
create or replace public synonym dbms_wm for wmsys.lt ;
create or replace synonym dbms_wm for wmsys.ltsys ;
select owner, name, type, line, position, substr(regexp_substr(text, '^[[:alnum:] :/-]+: (.*)', 1, 1, 'i', 1), 1, 100) text, attribute, message_number
from dba_errors
where owner = 'WMSYS'
order by 1,2,3,4,5,8;
select * from wmsys.wm$migration_error_view ;
declare
  ver wmsys.ltUtil.wm$ident ;
begin
  if (1=1) then
    dbms_registry.loaded('OWM');
  else
    select value into ver
    from wmsys.wm$env_vars
    where name = 'OWM_VERSION' and
          hidden = 1;

    dbms_registry.loaded('OWM', ver, 'Oracle Workspace Manager Release ' || ver || ' - Production');
  end if ;

  execute immediate 'begin sys.validate_owm; end;' ;
end;
/
@@?/rdbms/admin/sqlsessend.sql
