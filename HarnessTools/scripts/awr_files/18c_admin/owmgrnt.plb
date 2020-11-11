@@?/rdbms/admin/sqlsessstart.sql
begin
  
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'LT', 'PUBLIC', ctype=>'PACKAGE', firstE=>true) ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_MP_GRAPH_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_MP_PARENT_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_REMOVED_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_VERSION_HVIEW', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_CONSTRAINTS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_CONSTRAINT_VIOLATIONS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_CONS_COLUMNS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_IND_COLUMNS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_IND_EXPRESSIONS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_LOCKED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_MODIFIED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_POLICIES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_RIC_INFO', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_TAB_TRIGGERS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_VERSIONED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WM_VT_ERRORS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WORKSPACE_PRIVS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ALL_WORKSPACE_SAVEPOINTS', 'PUBLIC', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_REMOVED_WORKSPACES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WM_SYS_PRIVS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WM_VERSIONED_TABLES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WM_VT_ERRORS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WORKSPACES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WORKSPACE_PRIVS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WORKSPACE_SAVEPOINTS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'CDB_WORKSPACE_SESSIONS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_REMOVED_WORKSPACES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_SYS_PRIVS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_VERSIONED_TABLES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_VT_ERRORS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACES', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_PRIVS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_SAVEPOINTS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_SESSIONS', 'SELECT_CATALOG_ROLE', ctype=>'VIEW') ;

  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_REMOVED_WORKSPACES', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_SYS_PRIVS', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_VERSIONED_TABLES', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WM_VT_ERRORS', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACES', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_PRIVS', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_SAVEPOINTS', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'DBA_WORKSPACE_SESSIONS', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'ROLE_WM_PRIVS', 'PUBLIC', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_MP_GRAPH_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_MP_PARENT_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_REMOVED_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_CONSTRAINTS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_CONS_COLUMNS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_IND_COLUMNS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_IND_EXPRESSIONS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_LOCKED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_MODIFIED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_PRIVS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_POLICIES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_RIC_INFO', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_TAB_TRIGGERS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_VERSIONED_TABLES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WM_VT_ERRORS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WORKSPACES', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WORKSPACE_PRIVS', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'USER_WORKSPACE_SAVEPOINTS', 'PUBLIC', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'WM_COMPRESSIBLE_TABLES', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'WM_COMPRESS_BATCH_SIZES', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'WM_EVENTS_INFO', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'WM_INSTALLATION', 'PUBLIC', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('READ', 'WMSYS', 'WM_REPLICATION_INFO', 'PUBLIC', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM$EVENT_TYPE', 'PUBLIC', ctype=>'TYPE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM$NV_PAIR_NT_TYPE', 'PUBLIC', ctype=>'TYPE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM$NV_PAIR_TYPE', 'PUBLIC', ctype=>'TYPE') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_PERIOD', 'PUBLIC', ctype=>'TYPE') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE', 'AQ_ADMINISTRATOR_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE_R', 'AQ_ADMINISTRATOR_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE_S', 'AQ_ADMINISTRATOR_ROLE', ctype=>'VIEW') ;

  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE_R', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;
  wmsys.owm_vscript_pkg.wm$addRecord('SELECT', 'WMSYS', 'AQ$WM$EVENT_QUEUE_TABLE_S', 'WM_ADMIN_ROLE', ctype=>'VIEW') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_CONTAINS', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_EQUALS', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_GREATERTHAN', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_INTERSECTION', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_LDIFF', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_LESSTHAN', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_MEETS', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_OVERLAPS', 'PUBLIC', ctype=>'OPERATOR') ;
  wmsys.owm_vscript_pkg.wm$addRecord('EXECUTE', 'WMSYS', 'WM_RDIFF', 'PUBLIC', ctype=>'OPERATOR') ;

  for priv_rec in (select privilege, table_name, grantee, type, grantable, common
                   from dba_tab_privs
                   where owner = 'WMSYS') loop

    wmsys.owm_vscript_pkg.wm$checkExistingRecord(priv_rec.privilege, 'WMSYS', priv_rec.table_name, priv_rec.grantee, priv_rec.grantable, priv_rec.common, priv_rec.type) ;
  end loop ;

  wmsys.owm_vscript_pkg.wm$execRecords ;
end;
/
declare
  syn_tab wmsys.ltUtil.wm$ident_tab_bin ;

  function existingSynonym(synonym_name wmsys.ltUtil.wm$ident) return boolean is
  begin
    for i in 1..syn_tab.count loop
      if (syn_tab(i) = synonym_name) then
        return true ;
      end if ;
    end loop ;

    return false ;
  end;
begin
  
  wmsys.owm_vscript_pkg.wm$addRecord('DBMS_WM', 'WMSYS', 'LT', ctype=>'SYNONYM', firstE=>true) ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_MP_GRAPH_WORKSPACES', 'WMSYS', 'ALL_MP_GRAPH_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_MP_PARENT_WORKSPACES', 'WMSYS', 'ALL_MP_PARENT_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_REMOVED_WORKSPACES', 'WMSYS', 'ALL_REMOVED_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_VERSION_HVIEW', 'WMSYS', 'ALL_VERSION_HVIEW', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_CONSTRAINTS', 'WMSYS', 'ALL_WM_CONSTRAINTS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_CONSTRAINT_VIOLATIONS', 'WMSYS', 'ALL_WM_CONSTRAINT_VIOLATIONS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_CONS_COLUMNS', 'WMSYS', 'ALL_WM_CONS_COLUMNS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_IND_COLUMNS', 'WMSYS', 'ALL_WM_IND_COLUMNS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_IND_EXPRESSIONS', 'WMSYS', 'ALL_WM_IND_EXPRESSIONS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_LOCKED_TABLES', 'WMSYS', 'ALL_WM_LOCKED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_MODIFIED_TABLES', 'WMSYS', 'ALL_WM_MODIFIED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_POLICIES', 'WMSYS', 'ALL_WM_POLICIES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_RIC_INFO', 'WMSYS', 'ALL_WM_RIC_INFO', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_TAB_TRIGGERS', 'WMSYS', 'ALL_WM_TAB_TRIGGERS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_VERSIONED_TABLES', 'WMSYS', 'ALL_WM_VERSIONED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WM_VT_ERRORS', 'WMSYS', 'ALL_WM_VT_ERRORS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WORKSPACES', 'WMSYS', 'ALL_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WORKSPACE_PRIVS', 'WMSYS', 'ALL_WORKSPACE_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('ALL_WORKSPACE_SAVEPOINTS', 'WMSYS', 'ALL_WORKSPACE_SAVEPOINTS', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_REMOVED_WORKSPACES', 'WMSYS', 'CDB_REMOVED_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WM_SYS_PRIVS', 'WMSYS', 'CDB_WM_SYS_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WM_VERSIONED_TABLES', 'WMSYS', 'CDB_WM_VERSIONED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WM_VT_ERRORS', 'WMSYS', 'CDB_WM_VT_ERRORS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WORKSPACES', 'WMSYS', 'CDB_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WORKSPACE_PRIVS', 'WMSYS', 'CDB_WORKSPACE_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WORKSPACE_SAVEPOINTS', 'WMSYS', 'CDB_WORKSPACE_SAVEPOINTS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('CDB_WORKSPACE_SESSIONS', 'WMSYS', 'CDB_WORKSPACE_SESSIONS', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_REMOVED_WORKSPACES', 'WMSYS', 'DBA_REMOVED_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WM_SYS_PRIVS', 'WMSYS', 'DBA_WM_SYS_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WM_VERSIONED_TABLES', 'WMSYS', 'DBA_WM_VERSIONED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WM_VT_ERRORS', 'WMSYS', 'DBA_WM_VT_ERRORS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WORKSPACES', 'WMSYS', 'DBA_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WORKSPACE_PRIVS', 'WMSYS', 'DBA_WORKSPACE_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WORKSPACE_SAVEPOINTS', 'WMSYS', 'DBA_WORKSPACE_SAVEPOINTS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('DBA_WORKSPACE_SESSIONS', 'WMSYS', 'DBA_WORKSPACE_SESSIONS', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('ROLE_WM_PRIVS', 'WMSYS', 'ROLE_WM_PRIVS', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('USER_MP_GRAPH_WORKSPACES', 'WMSYS', 'USER_MP_GRAPH_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_MP_PARENT_WORKSPACES', 'WMSYS', 'USER_MP_PARENT_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_REMOVED_WORKSPACES', 'WMSYS', 'USER_REMOVED_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_CONSTRAINTS', 'WMSYS', 'USER_WM_CONSTRAINTS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_CONS_COLUMNS', 'WMSYS', 'USER_WM_CONS_COLUMNS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_IND_COLUMNS', 'WMSYS', 'USER_WM_IND_COLUMNS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_IND_EXPRESSIONS', 'WMSYS', 'USER_WM_IND_EXPRESSIONS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_LOCKED_TABLES', 'WMSYS', 'USER_WM_LOCKED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_MODIFIED_TABLES', 'WMSYS', 'USER_WM_MODIFIED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_PRIVS', 'WMSYS', 'USER_WM_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_POLICIES', 'WMSYS', 'USER_WM_POLICIES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_RIC_INFO', 'WMSYS', 'USER_WM_RIC_INFO', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_TAB_TRIGGERS', 'WMSYS', 'USER_WM_TAB_TRIGGERS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_VERSIONED_TABLES', 'WMSYS', 'USER_WM_VERSIONED_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WM_VT_ERRORS', 'WMSYS', 'USER_WM_VT_ERRORS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WORKSPACES', 'WMSYS', 'USER_WORKSPACES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WORKSPACE_PRIVS', 'WMSYS', 'USER_WORKSPACE_PRIVS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('USER_WORKSPACE_SAVEPOINTS', 'WMSYS', 'USER_WORKSPACE_SAVEPOINTS', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('WM_COMPRESSIBLE_TABLES', 'WMSYS', 'WM_COMPRESSIBLE_TABLES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_COMPRESS_BATCH_SIZES', 'WMSYS', 'WM_COMPRESS_BATCH_SIZES', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_EVENTS_INFO', 'WMSYS', 'WM_EVENTS_INFO', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_INSTALLATION', 'WMSYS', 'WM_INSTALLATION', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_REPLICATION_INFO', 'WMSYS', 'WM_REPLICATION_INFO', ctype=>'SYNONYM') ;

  
  wmsys.owm_vscript_pkg.wm$addRecord('WM_CONTAINS', 'WMSYS', 'WM_CONTAINS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_EQUALS', 'WMSYS', 'WM_EQUALS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_GREATERTHAN', 'WMSYS', 'WM_GREATERTHAN', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_INTERSECTION', 'WMSYS', 'WM_INTERSECTION', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_LDIFF', 'WMSYS', 'WM_LDIFF', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_LESSTHAN', 'WMSYS', 'WM_LESSTHAN', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_MEETS', 'WMSYS', 'WM_MEETS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_OVERLAPS', 'WMSYS', 'WM_OVERLAPS', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_PERIOD', 'WMSYS', 'WM_PERIOD', ctype=>'SYNONYM') ;
  wmsys.owm_vscript_pkg.wm$addRecord('WM_RDIFF', 'WMSYS', 'WM_RDIFF', ctype=>'SYNONYM') ;

  for syn_rec in (select synonym_name, table_owner, table_name
                  from dba_synonyms
                  where owner = 'PUBLIC' and
                        table_owner = 'WMSYS') loop

    wmsys.owm_vscript_pkg.wm$checkExistingRecord(syn_rec.synonym_name, syn_rec.table_owner, syn_rec.table_name, ctype=>'SYNONYM') ;
  end loop ;

  wmsys.owm_vscript_pkg.wm$execRecords ;
end;
/
@@?/rdbms/admin/sqlsessend.sql
