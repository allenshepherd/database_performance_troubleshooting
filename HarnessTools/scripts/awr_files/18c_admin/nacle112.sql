Rem
Rem $Header: rdbms/admin/nacle112.sql /main/4 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem nacle112.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      nacle112.sql - Network ACL downgrade to 11.2
Rem
Rem    DESCRIPTION
Rem      This script upgrades network ACLs from the current release to 11.2
Rem
Rem    NOTES
Rem      This script should be invoked only when XDB is present after upgrade
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/nacle112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/nacle112.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       06/13/12 - Fix downgrade
Rem    rpang       04/16/12 - Add privilege map to XS downgrade
Rem    rpang       02/20/12 - Created
Rem

set serveroutput on

declare

  -- Network XDB security class and namespace
  NETWORK_SC  constant varchar2(32) := 'network';
  NETWORK_NS  constant varchar2(32) := 'plsql';

  -- XDB ACL path prefix
  XDB_ACL_PREFIX constant varchar2(32) := '/sys/acls/';

  aclpath  varchar2(4000); -- XDB ACL path
  id       raw(16);        -- XDB ACL ID
  priv_map xs_object_migration.name_map; -- Privilege name map

  table_not_found  exception;
  pragma exception_init(table_not_found, -00942);

  function acl_path(name in varchar2) return varchar2 as
    path varchar2(4000);
  begin
    path := name;
    if (path not like '%.xml') then
      path := path || '.xml';
    end if;
    if (path not like '/%') then
      path := XDB_ACL_PREFIX || path;
    end if;
    return path;
  end;

begin

  -- New-to-old privilege name map
  priv_map('RESOLVE')                 := 'resolve';
  priv_map('CONNECT')                 := 'connect';
  priv_map('USE_CLIENT_CERTIFICATES') := 'use-client-certificates';
  priv_map('USE_PASSWORDS')           := 'use-passwords';

  -- Retrieve distinct network and wallet ACLs (IDs)
  for r in (select o.id, nvl(nm.xname, o.name) path, o.name
              from dba_xs_acls a, dba_xs_objects o, nacl$_name_map nm
             where a.security_class = 'NETWORK_SC' and
                   a.security_class_owner = 'SYS' and
                   a.name = o.name and
                   a.owner = o.owner and
                   o.id = nm.acl# (+)) loop

    begin
      aclpath := acl_path(r.path);

      -- Convert XML ACL to Triton ACL
      xs_object_migration.downgrade(
        object_name      => r.name,
        object_type      => xs_object_migration.objtype_acl,
        target_path      => aclpath,
        acl_sec_name     => NETWORK_SC,
        object_namespace => NETWORK_NS,
        priv_map         => priv_map);

      -- Save the XDB ACL ID
      select a.object_id into id
        from xdb.xdb$acl a, path_view p
       where XMLCast(XMLQuery(
               'declare default element namespace
                  "http://xmlns.oracle.com/xdb/XDBResource.xsd";
                fn:data(/Resource/XMLRef)'
               passing p.res returning content) as ref XMLType) = ref(a) and
             equals_path(p.res, aclpath) = 1;

      -- Insert as dynamic SQL in case the sys tables are not installed
      -- in the db after downgrade (ORA-00942: table or view does not exist).
      begin
        execute immediate
          'insert into net$_acl (host, lower_port, upper_port, aclid)
             (select host, lower_port, upper_port, :1
                from nacl$_host h where h.acl# = :2)' using id, r.id;
      exception
        when table_not_found then null;
      end;

      begin
        execute immediate
          'insert into wallet$_acl (wallet_path, aclid)
             (select wallet_path, :1
                from nacl$_wallet w where w.acl# = :2)' using id, r.id;
      exception
        when table_not_found then null;
      end;

    exception
      when others then
        dbms_output.put_line('Network ACL '||r.name||' failed to migrate: '||
                             sqlerrm);
        for a in (select host, lower_port, upper_port
                    from nacl$_host h where h.acl# = r.id) loop
          dbms_output.put_line('ACL assigned to host '||a.host||':'||
                               case when a.lower_port is null and
                                         a.upper_port is null then '*'
                                    else a.lower_port||'-'||a.upper_port end);
        end loop;
        for a in (select wallet_path
                    from nacl$_wallet w where w.acl# = r.id) loop
          dbms_output.put_line('ACL assigned to wallet path '||a.wallet_path);
        end loop;
    end;

  end loop;

end;
/

set serveroutput off
