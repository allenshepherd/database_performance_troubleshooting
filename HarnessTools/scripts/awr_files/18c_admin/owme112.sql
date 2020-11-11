@@?/rdbms/admin/sqlsessstart.sql
create or replace procedure wmsys.wm$execSQL wrapped 
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
7
50 89
dissuYqIKCKeARN5ycFFH9yr2n0wg5nnm7+fMr2ywFwWclyhO1ouy8vSs6YGj8jKAnzGyhco
xsrvLkRycNFJ6r+uJNFERLHn6sFQL+pErg8P6h+ugMqZUYPs2T1ylez7pqdtlPc=

/
exec dbms_registry.downgrading('OWM');
execute wmsys.owm_mig_pkg.modifySystemTriggers('DISABLE_E') ;
var prv_version varchar2(30);
begin
  :prv_version := null ;

  begin
    select wmsys.ltUtil.wm$convertVersionStr(prv_version) into :prv_version
    from sys.registry$
    where cid='OWM';

  exception when no_data_found then null ;
  end;

  if (:prv_version is null) then
    :prv_version := 'B.2.0.1.0' ;
  end if ;
end ;
/
execute wmsys.owm_mig_pkg.AllLwDisableVersioning(:prv_version) ;
@@owmr1120.plb
declare
  ver  varchar2(100) ;
begin
  dbms_utility.compile_schema('WMSYS', compile_all=>FALSE) ;

  for trec in (select owner, object_name from dba_objects where owner = 'WMSYS' and object_name like 'SYSTP%') loop
    execute immediate 'drop type WMSYS.' || sys.dbms_assert.enquote_name(trec.object_name, false) ;
  end loop ;

  select value into ver
  from wmsys.wm$env_vars
  where name = 'OWM_VERSION' ;

  dbms_registry.downgraded('OWM', ver);
end;
/
@@?/rdbms/admin/sqlsessend.sql
