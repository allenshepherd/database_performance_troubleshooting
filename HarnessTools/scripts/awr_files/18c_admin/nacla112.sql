Rem
Rem $Header: rdbms/admin/nacla112.sql /main/6 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem nacla112.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      nacla112.sql - Network ACL Anonymous block upgrade from 11.2
Rem
Rem    DESCRIPTION
Rem      This script upgrades network ACLs from 11.2 to the current release
Rem
Rem    NOTES
Rem      This script should be invoked only when XDB is present before upgrade
Rem      and requires the XS migration package.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/nacla112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/nacla112.sql
Rem    SQL_PHASE: NACLA112
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       04/28/15 - Bug 20723336: skip resolve priv in host+port acl
Rem    rpang       10/03/12 - Remove network ACL security class and resconfig
Rem    rpang       05/15/12 - 14054925: fix upgrade conflict
Rem    rpang       04/16/12 - Add privilege map to XS upgrade
Rem    rpang       02/19/12 - Created
Rem

declare

  -- New Real Application Security network ACL security class
  NETWORK_SC constant varchar2(32) := 'NETWORK_SC';

  -- Pre-12.1 network ACL prefix
  NETWORK_ACL_PREFIX constant varchar2(32) := 'PRE_12_1_NETWORK_ACL_';

  -- Old XDB ACL resource config for delete callback
  XDB_ACL_RC constant varchar2(80) := '/sys/apps/plsql/xs/netaclrc.xml';

  acl_seq  integer := 0;                 -- ACL sequence number
  acl_name dba_xs_objects.name%type;     -- new ACL name
  priv_map xs_object_migration.name_map; -- Privilege name map

  table_not_found    exception;
  res_cfg_not_found  exception;
  pragma exception_init(table_not_found,   -00942);
  pragma exception_init(res_cfg_not_found, -31130);

  -- Copy network host ACL while stripping the resolve privilege
  function copy_host_acl(aclid raw) return varchar2 as
    acl  xmltype;
    path varchar2(4000);
  begin
    acl_seq := acl_seq + 1;
    path := '/sys/acls/' || NETWORK_ACL_PREFIX ||
                to_char(acl_seq, 'fm0XXXXXXXXXXXXXXX') || '.xml';
    select xmlquery(
      'declare default element namespace "http://xmlns.oracle.com/xdb/acl.xsd";
       declare namespace plsql="http://xmlns.oracle.com/plsql";
         copy $acl := . modify delete node $acl/acl/ace/privilege/plsql:resolve
         return $acl'
       passing object_value returning content) into acl
      from xdb.xdb$acl
     where object_id = aclid;
    if (not dbms_xdb_repos.createResource(path, acl)) then
      raise program_error;
    end if;
    return path;
  end;

  -- Delete network host ACL
  procedure delete_host_acl(path varchar2) as
  begin
    dbms_xdb_repos.deleteResource(path);
  end;

  -- Migrate XDB network ACL to new ACL
  function migrate_xdb_acl(path in varchar2,
                           dsc  in varchar2) return varchar2 as
    name dba_xs_objects.name%type; -- ACL name
  begin
    acl_seq := acl_seq + 1;
    name := NETWORK_ACL_PREFIX || to_char(acl_seq, 'fm0XXXXXXXXXXXXXXX');
    xs_object_migration.upgrade(
      object_path  => path,
      object_type  => xs_object_migration.objtype_acl,
      target_name  => name,
      acl_sec_name => NETWORK_SC,
      priv_map     => priv_map);
    xs_acl.set_description(name, dsc);
    return name;
  end;

begin

  -- Old-to-new privilege name map
  priv_map('resolve')                 := 'RESOLVE';
  priv_map('connect')                 := 'CONNECT';
  priv_map('use-client-certificates') := 'USE_CLIENT_CERTIFICATES';
  priv_map('use-passwords')           := 'USE_PASSWORDS';

  -- Migrate pre-12.1 host ACLs. Query the old host ACL table as dynamic
  -- SQL in case the sys table is not installed in the db before upgrade
  -- (ORA-00942: table or view does not exist).
  declare
    c     sys_refcursor;
    h     nacl$_host%rowtype;
    aclid raw(16);
    path  varchar2(4000);
  begin
    open c for 'select host, lower_port, upper_port, path, aclid
                  from net$_acl, path_view
                 where aclid = sys_op_r2o(XMLCast(XMLQuery(
                        ''declare default element namespace
                           "http://xmlns.oracle.com/xdb/XDBResource.xsd";
                          fn:data(/Resource/XMLRef)''
                          passing res returning content)
                          as ref XMLType))';
    loop
      fetch c into h.host, h.lower_port, h.upper_port, path, aclid;
      exit when c%notfound;

      -- Bug 20723336: if the ACL is assigned to a host with port range, make a
      -- temp copy of the ACL while stripping the resolve privilege.
      if (h.lower_port is not null and h.upper_port is not null) then
        path := copy_host_acl(aclid);
      end if;

      -- Migrate XML network ACL to new ACL
      acl_name := migrate_xdb_acl(path,
        'Pre-12.1 ACL for host '||h.host||':'||
           case when h.lower_port is null and h.upper_port is null then '*'
                else h.lower_port||'-'||h.upper_port end);

      -- Append the host ACL and delete the ACL
      begin
        dbms_network_acl_admin.append_host_acl(
          h.host, h.lower_port, h.upper_port, acl_name);
      exception
        -- Invalid host error should never occur because port conflict should
        -- have been caught and resolved in pre-upgrade check (bug 20723336).
        when dbms_network_acl_admin.invalid_host then null;
      end;

      -- Bug 20723336: always remove temp host acl
      xs_acl.delete_acl(acl_name);
      if (h.lower_port is not null and h.upper_port is not null) then
        delete_host_acl(path);
      end if;

    end loop;
    close c;
  exception
    when table_not_found then null;
  end;

  -- Migrate pre-12.1 wallet ACLs. Query the old wallet ACL table as dynamic
  -- SQL in case the sys table is not installed in the db before upgrade
  -- (ORA-00942: table or view does not exist).
  declare
    c    sys_refcursor;
    w    nacl$_wallet%rowtype;
    path varchar2(4000);
  begin
    open c for 'select wallet_path, path
                  from wallet$_acl, path_view
                 where aclid = sys_op_r2o(XMLCast(XMLQuery(
                        ''declare default element namespace
                           "http://xmlns.oracle.com/xdb/XDBResource.xsd";
                          fn:data(/Resource/XMLRef)''
                          passing res returning content)
                          as ref XMLType))';
    loop
      fetch c into w.wallet_path, path;
      exit when c%notfound;

      -- Migrate XML network ACL to new ACL
      acl_name := migrate_xdb_acl(path,
        'Pre-12.1 ACL for wallet '||w.wallet_path);

      -- Append the wallet ACL and delete the ACL
      dbms_network_acl_admin.append_wallet_acl(w.wallet_path, acl_name);

      xs_acl.delete_acl(acl_name);

    end loop;
    close c;
  exception
    when table_not_found then null;
  end;

  -- Remove all network ACLs no matter if they are assigned or not
  for r in (select r.any_path
              from xdb.xdb$acl a, resource_view r
             where XMLExists(
                     'declare default element namespace
                        "http://xmlns.oracle.com/xdb/acl.xsd";
                         /acl/security-class[
                                     fn:namespace-uri-from-QName(fn:data(.)) = 
                                       "http://xmlns.oracle.com/plsql"
                                 and fn:local-name-from-QName(fn:data(.)) = 
                                       "network"]'
                     passing value(a))
               and ref(a) = XMLCast(XMLQuery(
                     'declare default element namespace
                        "http://xmlns.oracle.com/xdb/XDBResource.xsd";
                         fn:data(/Resource/XMLRef)'
                     passing r.res returning content) as ref XMLType)) loop
    begin
      -- Delete resource config on the ACL before removing the ACL
      dbms_resconfig.deleteResConfig(r.any_path, XDB_ACL_RC,
        dbms_resconfig.delete_resource);
    exception
      -- It is ok if the resource config is not associated (ORA-31130) because
      -- the resource config may have been removed from the ACL
      when res_cfg_not_found then null;
    end;
    dbms_xdb_repos.deleteResource(r.any_path);
  end loop;

  -- Reset reference count of network resource config
  update xdb.xdb$resconfig rc
     set refcount = 0
   where ref(rc) =
         (select XMLCast(XMLQuery(
                   'declare default element namespace "http://xmlns.oracle.com/xdb/XDBResource.xsd"; fn:data(/Resource/XMLRef)'
                   passing res returning content) as ref XMLType)
            from resource_view
           where equals_path(res, XDB_ACL_RC) = 1);

  -- Delete the PL/SQL folder with its security class and resource config
  if (dbms_xdb_repos.existsResource('/sys/apps/plsql')) then
    dbms_xdb_repos.deleteResource('/sys/apps/plsql',
      dbms_xdb_repos.delete_recursive);
  end if;

end;
/

Rem
Rem Truncate tables as dynamic SQL in case the tables are not installed
Rem in the db before upgrade (ORA-00942: table or view does not exist).
Rem

begin
  execute immediate 'truncate table net$_acl';
exception
  when others then
    if sqlcode = -00942 then null; else raise; end if;
end;
/

begin
  execute immediate 'truncate table wallet$_acl';
exception
  when others then
    if sqlcode = -00942 then null; else raise; end if;
end;
/
