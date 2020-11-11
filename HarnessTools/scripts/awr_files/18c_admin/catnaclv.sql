Rem
Rem $Header: rdbms/admin/catnaclv.sql /main/14 2016/07/22 16:30:00 rpang Exp $
Rem
Rem catnaclv.sql
Rem
Rem Copyright (c) 2012, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnaclv.sql - Network ACL Views
Rem
Rem    DESCRIPTION
Rem      This script creates the views required to define the access control
Rem      list (ACL) for PL/SQL network-related utility packages.
Rem
Rem    NOTES
Rem      This script should be run as "SYS".
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catnaclv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catnaclv.sql
Rem SQL_PHASE: CATNACLV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       07/14/16 - Bug 23751056: string compare in binary collation
Rem    rpang       06/20/16 - 23620391: exclude Oracle-supplied schemas in
Rem                           NACL$_ACE_EXP
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    gclaborn    07/02/14 - 18844843: grant flashback on SYS views
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    rpang       07/29/13 - 16839438: export ACE principal types using 12.1.0.1
Rem                           values
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    rpang       10/06/12 - lrg 7256879: add ACE export view
Rem    rpang       07/10/12 - Remove name_map export view
Rem    rpang       05/15/12 - 14054925: rename import package
Rem    rpang       04/23/12 - 9950582: add new HTTP / SMTP privileges
Rem    rpang       04/10/12 - 13941768: view cleanup
Rem    rpang       03/30/12 - Grant export views to select_catalog_role
Rem    rpang       02/13/12 - Network ACL triton migration
Rem    rpang       02/13/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem DBA network ACL assignments view
Rem

create or replace view DBA_NETWORK_ACLS
(HOST, LOWER_PORT, UPPER_PORT, ACL, ACLID, ACL_OWNER)
as
select h.host, h.lower_port, h.upper_port, nvl(nm.xname, o.name),
       sys_xsid_to_raw(h.acl#), o.owner
  from sys.nacl$_host h, dba_xs_objects o, sys.nacl$_name_map nm
 where h.acl# = o.id (+) and o.id = nm.acl# (+)
/
create or replace public synonym DBA_NETWORK_ACLS for DBA_NETWORK_ACLS
/
grant select on DBA_NETWORK_ACLS to select_catalog_role
/
comment on table DBA_NETWORK_ACLS is
'Access control lists assigned to restrict access to network hosts through PL/SQL network utility packages'
/
comment on column DBA_NETWORK_ACLS.HOST is
'Network host'
/
comment on column DBA_NETWORK_ACLS.LOWER_PORT is
'Lower bound of the port range'
/
comment on column DBA_NETWORK_ACLS.UPPER_PORT is
'Upper bound of the port range'
/
comment on column DBA_NETWORK_ACLS.ACL is
'The name of the access control list'
/
comment on column DBA_NETWORK_ACLS.ACLID is
'The object ID of the access control list'
/
comment on column DBA_NETWORK_ACLS.ACL_OWNER is
'The owner of the access control list'
/


execute CDBView.create_cdbview(false,'SYS','DBA_NETWORK_ACLS','CDB_NETWORK_ACLS');
grant select on SYS.CDB_NETWORK_ACLS to select_catalog_role
/
create or replace public synonym CDB_NETWORK_ACLS for SYS.CDB_NETWORK_ACLS
/

Rem
Rem DBA network ACL privileges view
Rem

create or replace view DBA_NETWORK_ACL_PRIVILEGES
(ACL, ACLID, PRINCIPAL, PRIVILEGE, IS_GRANT, INVERT, START_DATE, END_DATE,
 ACL_OWNER)
as
select nvl(nm.xname, ace.acl), sys_xsid_to_raw(o.id),
       ace.principal,
       decode(ace.privilege,
              'RESOLVE', 'resolve',
              'CONNECT', 'connect',
              'USE_CLIENT_CERTIFICATES', 'use-client-certificates',
              'USE_PASSWORDS', 'use-passwords',
              'HTTP', 'http',
              'HTTP_PROXY', 'http-proxy',
              'SMTP', 'smtp', ace.privilege),
       decode(ace.grant_type, 'GRANT', 'true', 'DENY', 'false'),
       decode(ace.inverted_principal, 'YES', 'true', 'NO', 'false'),
       ace.start_date, ace.end_date, o.owner
  from dba_xs_aces ace, dba_xs_objects o, sys.nacl$_name_map nm
 where nlssort(ace.acl,   'NLS_SORT=BINARY') =
       nlssort(o.name,    'NLS_SORT=BINARY')
   and nlssort(ace.owner, 'NLS_SORT=BINARY') =
       nlssort(o.owner,   'NLS_SORT=BINARY')
   and o.id in (select acl# from sys.nacl$_host) and o.id = nm.acl# (+)
/
create or replace public synonym DBA_NETWORK_ACL_PRIVILEGES
for DBA_NETWORK_ACL_PRIVILEGES
/
grant select on DBA_NETWORK_ACL_PRIVILEGES to select_catalog_role
/
comment on table DBA_NETWORK_ACL_PRIVILEGES is
'Privileges defined in network access control lists'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.ACL is
'The name of the access control list'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.ACLID is
'The object ID of the access control list'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.PRINCIPAL is
'Principal the privilege is applied to'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.PRIVILEGE is
'Privilege'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.IS_GRANT is
'Is the privilege granted or denied'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.INVERT is
'true if the access control entry contains invert principal, false otherwise'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.START_DATE is
'Start-date of the access control entry'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.END_DATE is
'End-date of the access control entry'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.ACL_OWNER is
'The owner of the access control list'
/


execute CDBView.create_cdbview(false,'SYS','DBA_NETWORK_ACL_PRIVILEGES','CDB_NETWORK_ACL_PRIVILEGES');
grant select on SYS.CDB_NETWORK_ACL_PRIVILEGES to select_catalog_role
/
create or replace public synonym CDB_NETWORK_ACL_PRIVILEGES for SYS.CDB_NETWORK_ACL_PRIVILEGES
/

Rem
Rem User network ACL privileges view
Rem   Show the hosts the current user has privileges on. The "resolve"
Rem   privilege will apply only to hosts with no (null) port range.
Rem

create or replace view USER_NETWORK_ACL_PRIVILEGES
(HOST, LOWER_PORT, UPPER_PORT, PRIVILEGE, STATUS)
as
select host, lower_port, upper_port,
       decode(privilege,
              'RESOLVE', 'resolve',
              'CONNECT', 'connect',
              'HTTP', 'http',
              'HTTP_PROXY', 'http-proxy',
              'SMTP', 'smtp', privilege),
       decode(status, 0, 'DENIED', 1, 'GRANTED', null)
  from (select h.host, h.lower_port, h.upper_port, xo.name privilege,
               sys_check_privilege(sys_xsid_to_raw(xo.id), h.acl#, null) status
          from sys.nacl$_host h, dba_xs_objects xo
         where nlssort(xo.owner, 'NLS_SORT=BINARY') =
               nlssort('SYS',    'NLS_SORT=BINARY')
           and xo.name in ('RESOLVE', 'CONNECT', 'HTTP', 'HTTP_PROXY', 'SMTP')
           and xo.type = 'PRIVILEGE')
 where status in (0, 1)
/
grant read on USER_NETWORK_ACL_PRIVILEGES to PUBLIC
/
create or replace public synonym USER_NETWORK_ACL_PRIVILEGES
for USER_NETWORK_ACL_PRIVILEGES
/
comment on table USER_NETWORK_ACL_PRIVILEGES is
'User privileges to access network hosts through PL/SQL network utility packages'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.HOST is
'Network host'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.LOWER_PORT is
'Lower bound of the port range'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.UPPER_PORT is
'Upper bound of the port range'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.PRIVILEGE is
'Privilege'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.STATUS is
'Privilege status'
/

Rem
Rem DBA host ACL assignments view
Rem

create or replace view DBA_HOST_ACLS
(HOST, LOWER_PORT, UPPER_PORT, ACL, ACLID, ACL_OWNER)
as
select h.host, h.lower_port, h.upper_port, nvl(nm.xname, o.name),
       sys_xsid_to_raw(h.acl#), o.owner
  from sys.nacl$_host h, dba_xs_objects o, sys.nacl$_name_map nm
 where h.acl# = o.id (+) and o.id = nm.acl# (+)
/
create or replace public synonym DBA_HOST_ACLS for DBA_HOST_ACLS
/
grant select on DBA_HOST_ACLS to select_catalog_role
/
comment on table DBA_HOST_ACLS is
'Access control lists assigned to restrict access to network hosts through PL/SQL network utility packages'
/
comment on column DBA_HOST_ACLS.HOST is
'Network host'
/
comment on column DBA_HOST_ACLS.LOWER_PORT is
'Lower bound of the port range'
/
comment on column DBA_HOST_ACLS.UPPER_PORT is
'Upper bound of the port range'
/
comment on column DBA_HOST_ACLS.ACL is
'The name of the access control list'
/
comment on column DBA_HOST_ACLS.ACLID is
'The object ID of the access control list'
/
comment on column DBA_HOST_ACLS.ACL_OWNER is
'The owner of the access control list'
/


execute CDBView.create_cdbview(false,'SYS','DBA_HOST_ACLS','CDB_HOST_ACLS');
grant select on SYS.CDB_HOST_ACLS to select_catalog_role
/
create or replace public synonym CDB_HOST_ACLS for SYS.CDB_HOST_ACLS
/

Rem
Rem DBA wallet ACL assignments view
Rem

create or replace view DBA_WALLET_ACLS
(WALLET_PATH, ACL, ACLID, ACL_OWNER)
as
select w.wallet_path, nvl(nm.xname, o.name), sys_xsid_to_raw(w.acl#),
       o.owner
  from sys.nacl$_wallet w, dba_xs_objects o, sys.nacl$_name_map nm
 where w.acl# = o.id (+) and o.id = nm.acl# (+)
/
create or replace public synonym DBA_WALLET_ACLS for DBA_WALLET_ACLS
/
grant select on DBA_WALLET_ACLS to select_catalog_role
/
comment on table DBA_WALLET_ACLS is
'Access control lists assigned to restrict access to wallets through PL/SQL network utility packages'
/
comment on column DBA_WALLET_ACLS.WALLET_PATH is
'Wallet path'
/
comment on column DBA_WALLET_ACLS.ACL is
'The name of the access control list'
/
comment on column DBA_WALLET_ACLS.ACLID is
'The object ID of the access control list'
/
comment on column DBA_WALLET_ACLS.ACL_OWNER is
'The owner of the access control list'
/


execute CDBView.create_cdbview(false,'SYS','DBA_WALLET_ACLS','CDB_WALLET_ACLS');
grant select on SYS.CDB_WALLET_ACLS to select_catalog_role
/
create or replace public synonym CDB_WALLET_ACLS for SYS.CDB_WALLET_ACLS
/

Rem
Rem DBA host ACE view
Rem

create or replace view DBA_HOST_ACES
(HOST, LOWER_PORT, UPPER_PORT, ACE_ORDER, START_DATE, END_DATE,
 GRANT_TYPE, INVERTED_PRINCIPAL, PRINCIPAL, PRINCIPAL_TYPE, PRIVILEGE)
as
select h.host, h.lower_port, h.upper_port,
       ace.ace_order, ace.start_date, ace.end_date,
       ace.grant_type, ace.inverted_principal,
       ace.principal, ace.principal_type, ace.privilege
  from sys.nacl$_host h, dba_xs_objects o, dba_xs_aces ace
 where h.acl# = o.id
   and nlssort(o.owner,   'NLS_SORT=BINARY') =
       nlssort(ace.owner, 'NLS_SORT=BINARY')
   and nlssort(o.name,    'NLS_SORT=BINARY') =
       nlssort(ace.acl,   'NLS_SORT=BINARY')
/
create or replace public synonym DBA_HOST_ACES for DBA_HOST_ACES
/
grant select on DBA_HOST_ACES to select_catalog_role
/
comment on table DBA_HOST_ACES is
'Access control entries defined in host access control lists'
/
comment on column DBA_HOST_ACES.HOST is
'Network host'
/
comment on column DBA_HOST_ACES.LOWER_PORT is
'Lower bound of the port range'
/
comment on column DBA_HOST_ACES.UPPER_PORT is
'Upper bound of the port range'
/
comment on column DBA_HOST_ACES.ACE_ORDER is
'Order number of the access control entry'
/
comment on column DBA_HOST_ACES.START_DATE is
'Start-date of the access control entry'
/
comment on column DBA_HOST_ACES.END_DATE is
'End-date of the access control entry'
/
comment on column DBA_HOST_ACES.GRANT_TYPE is
'Whether the access control entry grants or denies the privilege'
/
comment on column DBA_HOST_ACES.INVERTED_PRINCIPAL is
'Whether the principal is inverted or not'
/
comment on column DBA_HOST_ACES.PRINCIPAL is
'Principal the privilege is applied to'
/
comment on column DBA_HOST_ACES.PRINCIPAL_TYPE is
'Type of the principal'
/
comment on column DBA_HOST_ACES.PRIVILEGE is
'Privilege'
/


execute CDBView.create_cdbview(false,'SYS','DBA_HOST_ACES','CDB_HOST_ACES');
grant select on SYS.CDB_HOST_ACES to select_catalog_role
/
create or replace public synonym CDB_HOST_ACES for SYS.CDB_HOST_ACES
/

Rem
Rem DBA wallet ACE view
Rem

create or replace view DBA_WALLET_ACES
(WALLET_PATH, ACE_ORDER, START_DATE, END_DATE,
 GRANT_TYPE, INVERTED_PRINCIPAL, PRINCIPAL, PRINCIPAL_TYPE, PRIVILEGE)
as
select w.wallet_path,
       ace.ace_order, ace.start_date, ace.end_date,
       ace.grant_type, ace.inverted_principal,
       ace.principal, ace.principal_type, ace.privilege
  from sys.nacl$_wallet w, dba_xs_objects o, dba_xs_aces ace
 where w.acl# = o.id
   and nlssort(o.owner,   'NLS_SORT=BINARY') =
       nlssort(ace.owner, 'NLS_SORT=BINARY')
   and nlssort(o.name,    'NLS_SORT=BINARY') =
       nlssort(ace.acl,   'NLS_SORT=BINARY')
/
create or replace public synonym DBA_WALLET_ACES for DBA_WALLET_ACES
/
grant select on DBA_WALLET_ACES to select_catalog_role
/
comment on table DBA_WALLET_ACES is
'Access control entries defined in wallet access control lists'
/
comment on column DBA_WALLET_ACES.WALLET_PATH is
'Wallet path'
/
comment on column DBA_WALLET_ACES.ACE_ORDER is
'Order number of the access control entry'
/
comment on column DBA_WALLET_ACES.START_DATE is
'Start-date of the access control entry'
/
comment on column DBA_WALLET_ACES.END_DATE is
'End-date of the access control entry'
/
comment on column DBA_WALLET_ACES.GRANT_TYPE is
'Whether the access control entry grants or denies the privilege'
/
comment on column DBA_WALLET_ACES.INVERTED_PRINCIPAL is
'Whether the principal is inverted or not'
/
comment on column DBA_WALLET_ACES.PRINCIPAL is
'Principal the privilege is applied to'
/
comment on column DBA_WALLET_ACES.PRINCIPAL_TYPE is
'Type of the principal'
/
comment on column DBA_WALLET_ACES.PRIVILEGE is
'Privilege'
/


execute CDBView.create_cdbview(false,'SYS','DBA_WALLET_ACES','CDB_WALLET_ACES');
grant select on SYS.CDB_WALLET_ACES to select_catalog_role
/
create or replace public synonym CDB_WALLET_ACES for SYS.CDB_WALLET_ACES
/

Rem
Rem User host ACE view
Rem

create or replace view USER_HOST_ACES
(HOST, LOWER_PORT, UPPER_PORT, PRIVILEGE, STATUS)
as
select host, lower_port, upper_port, privilege,
       decode(status, 0, 'DENIED', 1, 'GRANTED', null)
  from (select h.host, h.lower_port, h.upper_port, xo.name privilege,
               sys_check_privilege(sys_xsid_to_raw(xo.id), h.acl#, null) status
          from sys.nacl$_host h, dba_xs_objects xo
         where nlssort(xo.owner, 'NLS_SORT=BINARY') =
               nlssort('SYS',    'NLS_SORT=BINARY')
           and xo.name in ('RESOLVE', 'CONNECT', 'HTTP', 'HTTP_PROXY', 'SMTP')
           and xo.type = 'PRIVILEGE')
 where status in (0, 1)
/
grant read on USER_HOST_ACES to PUBLIC
/
create or replace public synonym USER_HOST_ACES for USER_HOST_ACES
/
comment on table USER_HOST_ACES is
'Status of access control entries for user to access network hosts through PL/SQL host utility packages'
/
comment on column USER_HOST_ACES.HOST is
'Network host'
/
comment on column USER_HOST_ACES.LOWER_PORT is
'Lower bound of the port range'
/
comment on column USER_HOST_ACES.UPPER_PORT is
'Upper bound of the port range'
/
comment on column USER_HOST_ACES.PRIVILEGE is
'Privilege'
/
comment on column USER_HOST_ACES.STATUS is
'Privilege status'
/

Rem
Rem User wallet ACE view
Rem

create or replace view USER_WALLET_ACES
(WALLET_PATH, PRIVILEGE, STATUS)
as
select wallet_path, privilege,
       decode(status, 0, 'DENIED', 1, 'GRANTED', null)
  from (select w.wallet_path, xo.name privilege,
               sys_check_privilege(sys_xsid_to_raw(xo.id), w.acl#, null) status
          from sys.nacl$_wallet w, dba_xs_objects xo
         where nlssort(xo.owner, 'NLS_SORT=BINARY') =
               nlssort('SYS',    'NLS_SORT=BINARY')
           and xo.name in ('USE_CLIENT_CERTIFICATES', 'USE_PASSWORDS')
           and xo.type = 'PRIVILEGE')
 where status in (0, 1)
/
grant read on USER_WALLET_ACES to PUBLIC
/
create or replace public synonym USER_WALLET_ACES for USER_WALLET_ACES
/
comment on table USER_WALLET_ACES is
'Status of access control entries for user to access wallets through PL/SQL network utility packages'
/
comment on column USER_WALLET_ACES.WALLET_PATH is
'Wallet path'
/
comment on column USER_WALLET_ACES.PRIVILEGE is
'Privilege'
/
comment on column USER_WALLET_ACES.STATUS is
'Privilege status'
/

Rem
Rem DBA ACL name map
Rem

create or replace view DBA_ACL_NAME_MAP
(XDB_NAME, ACL, ACL_OWNER)
as
select nm.xname, o.name, o.owner
  from sys.nacl$_name_map nm, dba_xs_objects o
 where nm.acl# = o.id (+)
/
create or replace public synonym DBA_ACL_NAME_MAP for DBA_ACL_NAME_MAP
/
grant select on DBA_ACL_NAME_MAP to select_catalog_role
/
comment on table DBA_ACL_NAME_MAP is
'New names of the access control lists for PL/SQL network utility packages from old XDB names'
/
comment on column DBA_ACL_NAME_MAP.XDB_NAME is
'The old XDB name of the access control list'
/
comment on column DBA_ACL_NAME_MAP.ACL is
'The new name of the access control list'
/
comment on column DBA_ACL_NAME_MAP.ACL_OWNER is
'The owner of the access control list'
/


execute CDBView.create_cdbview(false,'SYS','DBA_ACL_NAME_MAP','CDB_ACL_NAME_MAP');
grant select on SYS.CDB_ACL_NAME_MAP to select_catalog_role
/
create or replace public synonym CDB_ACL_NAME_MAP for SYS.CDB_ACL_NAME_MAP
/

Rem
Rem Views for export of ACL assignments. These views are used to export the
Rem network ACLs and their ACEs for used by the import callout registered
Rem to handle these view imports. The matching empty tables are created to
Rem allow Datapump to retrieve the metadata of the views.
Rem

create or replace view NACL$_HOST_EXP
(HOST, LOWER_PORT, UPPER_PORT, ACL_NAME, ACL_OWNER)
as
select h.host, h.lower_port, h.upper_port, o.name, o.owner
  from sys.nacl$_host h, dba_xs_objects o
 where h.acl# = o.id
/
grant select on NACL$_HOST_EXP to select_catalog_role
/
grant flashback on NACL$_HOST_EXP to select_catalog_role
/
create table NACL$_HOST_EXP_TBL as
select * from NACL$_HOST_EXP where 0=1
/
grant select on NACL$_HOST_EXP_TBL to select_catalog_role
/

create or replace view NACL$_WALLET_EXP
(WALLET_PATH, ACL_NAME, ACL_OWNER)
as
select w.wallet_path, o.name, o.owner
  from sys.nacl$_wallet w, dba_xs_objects o
 where w.acl# = o.id
/
grant select on NACL$_WALLET_EXP to select_catalog_role
/
grant flashback on NACL$_WALLET_EXP to select_catalog_role
/
create table NACL$_WALLET_EXP_TBL as
select * from NACL$_WALLET_EXP where 0=1
/
grant select on NACL$_WALLET_EXP_TBL to select_catalog_role
/

Rem 16839438: export principal type using 12.1.0.1 values for compatibility
Rem 23620391: exclude Oracle-supplied schemas
create or replace view NACL$_ACE_EXP
as
select acl, owner, ace_order, start_date, end_date, grant_type,
       inverted_principal, principal,
       decode(principal_type, 'APPLICATION', 'APPLICATION USER',
                              'DATABASE', 'DATABASE USER', 
                              'EXTERNAL', 'EXTERNAL USER',
                              principal_type) principal_type,
       privilege, security_class, security_class_owner
  from dba_xs_aces
 where (acl, owner) in
       (select name, owner from dba_xs_objects
         where id in (select acl# from sys.nacl$_host
                       union all
                      select acl# from sys.nacl$_wallet)) and
       (principal, principal_type) not in
       (select username, 'DATABASE' from dba_users
         where oracle_maintained = 'Y')
/
grant select on NACL$_ACE_EXP to select_catalog_role
/
grant flashback on NACL$_ACE_EXP to select_catalog_role
/
create table NACL$_ACE_EXP_TBL as
select * from NACL$_ACE_EXP where 0=1
/
grant select on NACL$_ACE_EXP_TBL to select_catalog_role
/

Rem
Rem Register network ACL views and package for export/import
Rem

delete from sys.impcalloutreg$ where tag = 'NETWORK_ACL'
/
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  values ('DBMS_NETWORK_ACL_ADMIN', 'SYS', 'NETWORK_ACL', 3, 1000, 0,
          'SYS', 'NACL$_HOST_EXP', 4, 'Network ACL')
/
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  values ('DBMS_NETWORK_ACL_ADMIN', 'SYS', 'NETWORK_ACL', 3, 1000, 0,
          'SYS', 'NACL$_WALLET_EXP', 4, 'Network ACL')
/
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  values ('DBMS_NETWORK_ACL_ADMIN', 'SYS', 'NETWORK_ACL', 3, 1001, 0,
          'SYS', 'NACL$_ACE_EXP', 4, 'Network ACL')
/

commit;

@?/rdbms/admin/sqlsessend.sql
