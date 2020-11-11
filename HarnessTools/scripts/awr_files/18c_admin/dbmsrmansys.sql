Rem
Rem Copyright (c) 2013, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrmansys.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrmansys.sql
Rem SQL_PHASE: DBMSRMANSYS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vbegun      02/22/16 - bug 22757320 workaround
Rem    ppatare     11/25/15 - bug 21497667
Rem    vbegun      03/16/15 - bug20713578
Rem    vbegun      01/30/15 - disabling vpd support out of the box
Rem    surman      02/11/14 - 13922626: Update SQL metadata
Rem    vbegun      10/29/13 - Created
Rem

SET TERMOUT OFF
@@?/rdbms/admin/sqlsessstart.sql
SET TERMOUT ON

--  Do not drop this role recovery_catalog_owner.
--  Drop this role will revoke this role from all rman users.
--  If this role exists, ORA-1921 is expected.
declare
  role_exists exception;
  pragma exception_init(role_exists, -1921);
begin
  execute immediate 'create role recovery_catalog_owner';
exception
  when role_exists
  then null;
end;
/
declare
  role_exists exception;
  pragma exception_init(role_exists, -1921);
begin
  execute immediate 'create role recovery_catalog_owner_vpd';
exception
  when role_exists
  then null;
end;
/
declare
  role_exists exception;
  pragma exception_init(role_exists, -1921);
begin
  execute immediate 'create role recovery_catalog_user';
exception
  when role_exists
  then null;
end;
/

grant create session,alter session,create synonym,create view,
 create database link,create table,create cluster,create sequence,
 create trigger,create procedure, create type to recovery_catalog_owner; 

-- Following are added for VPD support
grant execute on dbms_rls to recovery_catalog_owner_vpd;
grant create any synonym, drop any synonym, administer database trigger,
 recovery_catalog_owner to recovery_catalog_owner_vpd;
grant recovery_catalog_user to recovery_catalog_owner_vpd with admin option;

-- Bug 21497667 : Grant execute access on DBMS_LOCK package to 
-- recovery_catalog_owner and other catalog users. This is required because 
-- the dbms_lock was not accesible in the cdb-pdb environment, but it was 
-- accesible from non cdb environment 
grant execute on dbms_lock to recovery_catalog_owner, recovery_catalog_user,
 recovery_catalog_owner_vpd;

-- This detects all RMAN base catalogs deployed and does privileges adjustments
-- depending on the presence of the VPC users associated with that catalog and
-- its current VPD status
declare
  procedure r (
    i_priv                         in varchar2
  )
  is
  begin
    execute immediate 'revoke ' || i_priv
                   || ' from recovery_catalog_owner';
  exception
    when others
    then null;
  end;

  function has_vpc_users (
    i_catowner                     user_users.username%type
  )
  return boolean
  is
    l_dummy                        varchar2(1);
    l_has_filter_uid               number;
    l_catowner                     varchar2(130);
  begin
    l_catowner := dbms_assert.enquote_name(i_catowner);
    begin
      select 'x'
           , (
             select count(*)
               from dba_tab_columns c
              where c.owner = t.owner
                and c.table_name = t.table_name
                and c.column_name in ('FILTER_UID')
             )
        into l_dummy
           , l_has_filter_uid
        from dba_tables t
       where table_name = 'VPC_USERS'
         and owner = i_catowner
         and 1 = (
               select count(*)
                 from dba_tab_columns c
                where c.owner = t.owner
                  and c.table_name = t.table_name
                  and c.column_name in ('FILTER_USER')
             )
         and 2 = (
               select count(*)
                 from dba_objects o
                where o.owner = t.owner
                  and o.object_name = 'DBMS_RCVCAT'
                  and o.object_type in ('PACKAGE', 'PACKAGE BODY')
             )
         and 2 = (
               select count(*)
                 from dba_objects o
                where o.owner = t.owner
                  and o.object_name = 'DBMS_RCVMAN'
                  and o.object_type in ('PACKAGE', 'PACKAGE BODY')
             );
      if (l_has_filter_uid > 0)
      then
        execute immediate
          regexp_replace(
             'select ''x'' from %o.vpc_users u, dba_users du where'
          || ' u.filter_user = du.username and u.filter_uid = du.user_id '
          || ' and rownum = 1 having count(*) = 1'
          , '%o'
          , l_catowner
          )
        into l_dummy;
      else
        execute immediate
          regexp_replace(
             'select ''x'' from %o.vpc_users u, dba_users du where'
          || ' u.filter_user = du.username and rownum = 1 having count(*) = 1'
          , '%o'
          , l_catowner
          )
        into l_dummy;
      end if;
   exception
      when no_data_found
      then return false;
    end;
    return l_dummy is not null;
  end;

begin
  for u in (
    select u.username catowner
         , (
           select 'y'
             from dba_tab_privs t
            where t.grantee = r.granted_role
              and t.table_name = 'DBMS_RLS'
              and t.privilege = 'EXECUTE'
              and t.owner = 'SYS'
              and rownum = 1
           ) has_rls
         , (
           select 'y'
             from dba_triggers
            where owner = u.username
              and trigger_name = 'VPC_CONTEXT_TRG'
           ) has_trg
      from dba_role_privs r
         , dba_users u
     where r.granted_role = 'RECOVERY_CATALOG_OWNER'
       and r.grantee = u.username
  )
  loop
    if ((u.has_rls = 'y' and u.has_trg = 'y') or has_vpc_users(u.catowner))
    then
      execute immediate
         'grant recovery_catalog_owner_vpd to '
      || dbms_assert.enquote_name(u.catowner);
      execute immediate
         'revoke recovery_catalog_owner from '
      || dbms_assert.enquote_name(u.catowner);
    end if;
  end loop;

  r('drop any synonym');
  r('create any trigger');
  r('create any synonym');
  r('create public synonym');
  r('administer database trigger');
  r('recovery_catalog_user');
  r('execute on dbms_rls');
end;
/

SET TERMOUT OFF
@?/rdbms/admin/sqlsessend.sql
SET TERMOUT ON
