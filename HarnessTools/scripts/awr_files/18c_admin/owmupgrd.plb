@@?/rdbms/admin/sqlsessstart.sql
@@owmcmdv.plb 'UPGRADE'
select * from wm_installation order by name ;
column file_name new_value comp_file noprint;
var owm_script varchar2(128);
begin
  :owm_script := dbms_registry.nothing_script;

  if (:old_owm_version_for_upgrade = 'NOT_INSTALLED') then
    raise_application_error(-20000, 'Workspace Manager not installed.  Cannot upgrade.') ;

  elsif (:old_owm_version_for_upgrade = 'NO INSTALL - Migrating Tables') then
    raise_application_error(-20000, 'All versioned tables must have a ''VERSIONED'' status before upgrading.') ;

  elsif (:old_owm_version_for_upgrade = 'NO INSTALL - Replication') then
    raise_application_error(-20000, 'Disable replication support before upgrading to a newer version.') ;

  elsif (:old_owm_version_for_upgrade < nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
    raise_application_error(-20000, 'Upgrade from this version is not supported.') ;

  elsif (:old_owm_version_for_upgrade is not null) then
    :owm_script := 'owmuany.plb' ;

  else
    raise_application_error(-20000, 'Unable to determine current version. Cannot upgrade at this time.') ;
  end if ;
end;
/
select :owm_script as file_name from sys.dual ;
@@&comp_file
@@?/rdbms/admin/sqlsessend.sql
