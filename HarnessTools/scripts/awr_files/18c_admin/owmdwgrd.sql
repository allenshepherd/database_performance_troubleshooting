WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
@@?/rdbms/admin/sqlsessstart.sql
column file_name new_value comp_file noprint;
var owm_script varchar2(128);
declare
  prv_version varchar2(128) := substr(sys.dbms_registry.prev_version('OWM'), 1, 6) ;
begin
  if (prv_version = '11.2.0') then
    :owm_script := 'owme112.sql';

  elsif (prv_version = '12.1.0') then
    :owm_script := 'owme121.sql';

  elsif (prv_version = '12.2.0') then
    :owm_script := 'owme122.sql';

  else
    :owm_script := sys.dbms_registry.nothing_script;
  end if;
end;
/
select :owm_script as file_name from sys.dual ;
@@&comp_file
@@?/rdbms/admin/sqlsessend.sql
