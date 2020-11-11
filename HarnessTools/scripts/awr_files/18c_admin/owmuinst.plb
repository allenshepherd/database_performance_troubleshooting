@@?/rdbms/admin/sqlsessstart.sql
declare
  status_var  varchar2(128) ;
  sc_error    boolean := false ;

  cursor syn_cur is
    select owner, synonym_name
    from dba_synonyms
    where owner in ('PUBLIC', 'SYS') and
          table_owner = 'WMSYS' ;

  no_table_view EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_table_view, -00942);

  procedure wm$execSQLIgnoreExceptions(sql_stmt varchar2) is
    drop_package EXCEPTION;
    PRAGMA EXCEPTION_INIT(drop_package, -04043);

    drop_public_synonym EXCEPTION;
    PRAGMA EXCEPTION_INIT(drop_public_synonym, -01432);

    drop_trigger EXCEPTION;
    PRAGMA EXCEPTION_INIT(drop_trigger, -04080);

    role_does_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(role_does_not_exist, -01919);
  begin
    execute immediate sql_stmt;

  exception
    when no_table_view then null;
    when drop_package then null;
    when drop_public_synonym then null;
    when drop_trigger then null;
    when role_does_not_exist then null;
  end;

  procedure checkForErrorConditions is
    cnt    integer;

    busy_resource EXCEPTION;
    PRAGMA EXCEPTION_INIT(busy_resource, -00054);

    vt_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(vt_exists, -20172);

    compile_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(compile_exception, -65047);
  begin
    if ((case when sys_context('userenv', 'cdb_name') is null then null else sys_context('userenv', 'con_name') end) = 'CDB$ROOT') then
      for urec in (select con_id
                   from cdb_users
                   where username = 'WMSYS') loop
        if (urec.con_id <> sys_context('userenv', 'con_id')) then
          execute immediate 'begin WMSYS.WM_ERROR.RAISEERROR(wmsys.lt.WM_ERROR_383_NO); end;';
        end if ;
      end loop ;
    end if ;

    







    execute immediate 'lock table wmsys.wm$versioned_tables$ in exclusive mode nowait' ;
    execute immediate 'select count(*) from all_wm_versioned_tables' into cnt ;
    commit ;

    if (cnt > 0) then
      execute immediate 'begin WMSYS.WM_ERROR.RAISEERROR(wmsys.lt.WM_ERROR_172_NO); end;';
    end if;

  exception
    when no_table_view or compile_exception then null ;

    when busy_resource or vt_exists then
      
      rollback;
      raise;
  end ;

begin
  begin
    select status into status_var
    from dba_registry
    where comp_id = 'OWM' ;

    if (status_var <> 'REMOVING') then
      checkForErrorConditions ;
    end if ;

    dbms_registry.removing('OWM');

  exception when no_data_found then null ;
  end ;

  




  wm$execSQLIgnoreExceptions('drop public synonym dbms_wm');

  
  wm$execSQLIgnoreExceptions('drop trigger wmsys.no_vm_ddl');
  wm$execSQLIgnoreExceptions('drop trigger wmsys.no_vm_drop_a');

  
  for syn_rec in syn_cur loop
    if (syn_rec.owner = 'PUBLIC') then
      wm$execSQLIgnoreExceptions('drop public synonym ' || syn_rec.synonym_name);
    else
      wm$execSQLIgnoreExceptions('drop synonym ' || syn_rec.owner || '.' || syn_rec.synonym_name);
    end if ;
  end loop ;

  
  wm$execSQLIgnoreExceptions('drop context lt_ctx');
  wm$execSQLIgnoreExceptions('drop procedure sys.validate_owm') ;
  wm$execSQLIgnoreExceptions('drop role wm_admin_role');

  
  wm$execSQLIgnoreExceptions('truncate table wmsys.wm$mw_table$') ;

  
  delete sys.impcalloutreg$ where tag='WMSYS';
  commit;
end;
/
declare
  status_var varchar2(128) ;

  user_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(user_does_not_exist, -01918);
begin
  select status into status_var
  from dba_registry
  where comp_id = 'OWM' ;

  
  
  if (status_var = 'REMOVING') then
    execute immediate 'drop user wmsys cascade';
  end if ;

exception
  when user_does_not_exist then null;
  when no_data_found then null ;
end ;
/
@@?/rdbms/admin/sqlsessend.sql
