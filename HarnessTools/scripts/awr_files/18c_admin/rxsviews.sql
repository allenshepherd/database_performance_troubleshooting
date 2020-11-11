Rem
Rem $Header: rdbms/admin/rxsviews.sql /main/45 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem rxsviews.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rxsviews.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/rxsviews.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/rxsviews.sql
Rem SQL_PHASE: RXSVIEWS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catts.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    thbaby      03/13/17 - Bug 25688154: upper case owner name
Rem    yanlili     11/16/16 - Bug 24799459: Added Legacy SSHA1 type for old
Rem                           12.1.0.1 SSHA1 verifier for RAS direct logon users
Rem    aanverma    06/10/16 - Bug 23515378: grant read on audit views
Rem    yanlili     09/29/15 - Lrg 18552097: Use the right owner 
Rem                           in ALL_XS_* views
Rem    yanlili     07/30/15 - Bug 20919937: A user with ADMIN_ANY_SEC_POLICY can
Rem                           not view objects under SYS scheam
Rem    amunnoli    06/16/15 - Proj 46892: Move creation of DBA_XS_AUDIT_TRAIL
Rem                           to catuat.sql
Rem    yanlili     04/23/15 - Fix bug 20131705: Allow object owner to view its
Rem                           own objects in ALL_XS_* views.
Rem    yanlili     03/16/15 - Fix bug 18086563: Change status in view 
Rem                           to reflect user effectiveness
Rem    rbolarr     02/02/15 - Bug 20254948: Fix for USER/DBA_XS_ACL_PARAMETERS
Rem    sumkumar    12/26/14 - Proj 46885: inactive account time
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    yanlili     11/14/14 - Fix bug 20019217: Change view
Rem                           DBA_XS_ENB_AUDIT_POLICIES name to
Rem                           DBA_XS_ENABLED_AUDIT_POLICIES
Rem    yanlili     11/12/14 - Fix bug 19913708: add view 
Rem                           ALL_XS_APPLICABLE_OBJECTS 
Rem    skayoor     09/11/14 - Proj 58196: Change Select priv to Read Priv
Rem    yohu        06/11/14 - Proj 46902: Sesion Privilege Scoping
Rem    yanlili     08/03/14 - Proj 46907: Schema level policy admin
Rem    pradeshm    04/28/14 - Fix lrg 11793444 : update USER_XS_PASSWORD_LIMITS
Rem                           view for common profiles
Rem    amunnoli    03/26/14 - Proj 46893: Modify DBA_XS_ENB_AUDIT_POLICIES view
Rem                           as per new definition of 
Rem                           AUDIT_UNIFIED_ENABLED_POLICIES view
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    yiru        12/20/13 - Add DB role to XS role grant in DBA_XS_ROLE_GRANTS
Rem    mincwang    10/13/13 - Bug 17475434: set_password fails in rolling
Rem                           upgrad
Rem    minx        09/18/13 - Fix Bug 17478619: Add data realm description 
Rem    pradeshm    09/10/13 - Fix bug 17420371: new column in dba_xs_users for
Rem                           direct logon user
Rem    pradeshm    08/07/13 - Fix Bug:17196865 New view for RAS users Password
Rem                           limit
Rem    yanlili     07/11/13 - Fix bug 16839438: fix PRINCIPAL_TYPE in 
Rem                           DBA_XS_ACES view
Rem    pradeshm    07/03/13 - Proj#46908: added account anf profile info in
Rem                           dba_xs_users and user_xs_users
Rem    weihwang    10/22/12 - Add row ACL and owner bypass in
Rem                           DBA_XS_APPLIED_POLICIES
Rem    yanlili     09/27/12 - Bug 14663294: Pre-seeded policy change
Rem    snadhika    07/06/12 - Bug # 14282356 - Incorrect view definition for
Rem                           dba_xs_session_roles
Rem    pradeshm    07/05/12 - Enhance view DBA_XS_PROXY_ROLES, Fix Bug :
Rem                           14096396
Rem    skwak       03/29/12 - Change ppname to pname for policy name
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    skwak       03/21/12 - Remove apply option from policy views
Rem    minx        02/14/12 - Namespace privilege enhancement
Rem    skwak       02/07/12 - Add statement type for policy views
Rem    ssonawan    01/13/12 - Bug 11883154: remove handler columns from view
Rem                           DBA_XS_AUDIT_POLICY_OPTIONS
Rem    weihwang    11/10/11 - Existing view redefinition
Rem    yanlili     08/26/11 - Add view DBA_XS_AUDIT_POLICY_OPTIONS, 
Rem                           DBA_XS_ENB_AUDIT_POLICIES, and
Rem                           DBA_XS_AUDIT_TRAIL
Rem    minx        06/18/11 - Remove APPS_FEATURE from dba_active_xs_session view
Rem    snadhika    06/07/11 - Added dba_active_xs_sessions view
Rem    yanlili     05/19/11 - Add audit configuration view
Rem    sankejai    02/19/11 - Move v/gv$xs_session_ns_attributes and
Rem                           v/gv$xs_session_roles to kqfv.h
Rem    skwak       01/30/11 - Modify view definition for DBA_XS_OBJECTS
Rem    yiru        11/01/10 - Fix lrg 4868553
Rem    snadhika    07/05/10 - Triton session enhancement project
Rem    yiru        05/11/10 - Drop6R cleanup before merge-down : add
Rem                           compatible views 
Rem    snadhika    10/22/09 - Added security class, acl related views
Rem    clei        10/01/09 - Add XDS views
Rem    yiru        09/07/09 - Views for namespace templates, session 
Rem                           namespace table
Rem    rbhatti     08/17/09 - Views for relational xs tables
Rem    rbhatti     08/17/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


/******************************************************************************
                               Object View
******************************************************************************/
-------------------------------------------------------------------------------
--                          DBA_XS_OBJECTS
-------------------------------------------------------------------------------

create or replace view DBA_XS_OBJECTS
(
  NAME,
  OWNER,
  ID,
  TYPE,
  STATUS
)
as 
select name, owner, id, 
       decode(type, 1, 'PRINCIPAL',
                    2, 'SECURITY CLASS',
                    3, 'ACL',
                    4, 'PRIVILEGE',
                    5, 'DATA SECURITY',
                    7, 'NAMESPACE TEMPLATE'),
       decode(status, 0, 'INVALID', 1, 'VALID', 2, 'EXTERNAL')
  from sys.xs$obj where type in (1, 2, 3, 4, 5, 7)
/

comment on table DBA_XS_OBJECTS is
'All the Real Application Security objects defined in the database'
/

comment on column DBA_XS_OBJECTS.NAME is
'Name of the object'
/

comment on column DBA_XS_OBJECTS.OWNER is
'Owner of the object'
/

comment on column DBA_XS_OBJECTS.ID is
'ID of the object'
/

comment on column DBA_XS_OBJECTS.TYPE is
'Type of the object'
/

comment on column DBA_XS_OBJECTS.STATUS is
'Status of the object'
/

create or replace public synonym DBA_XS_OBJECTS for DBA_XS_OBJECTS;

grant select on DBA_XS_OBJECTS to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_OBJECTS','CDB_XS_OBJECTS');
create or replace public synonym CDB_XS_OBJECTS for sys.CDB_XS_OBJECTS;
grant select on CDB_XS_OBJECTS to select_catalog_role;

/******************************************************************************
                               Principal Views
******************************************************************************/

-------------------------------------------------------------------------------
--                          DBA_XS_PRINCIPALS
-------------------------------------------------------------------------------

create or replace view DBA_XS_PRINCIPALS
(
  NAME, 
  GUID, 
  TYPE, 
  EXTERNAL_SOURCE, 
  DESCRIPTION
)
as
select o.name, p.guid, decode(p.type, 0, 'USER', 1, 'ROLE', 2, 'DYNAMIC ROLE'), 
       p.ext_src, p.description
  from sys.xs$prin p, sys.xs$obj o
 where o.id = p.prin#
/

comment on table DBA_XS_PRINCIPALS is
'All the Real Application Security principals defined in the database'
/

comment on column DBA_XS_PRINCIPALS.NAME is
'Name of the principal'
/

comment on column DBA_XS_PRINCIPALS.GUID is
'GUID of the principal'
/

comment on column DBA_XS_PRINCIPALS.TYPE is
'Type of the principal. Possible values are USER, ROLE, or DYNAMIC ROLE'
/

comment on column DBA_XS_PRINCIPALS.EXTERNAL_SOURCE is
'External source of the principal'
/

comment on column DBA_XS_PRINCIPALS.DESCRIPTION is
'Description of the principal'
/

create or replace public synonym DBA_XS_PRINCIPALS for DBA_XS_PRINCIPALS;

grant select on DBA_XS_PRINCIPALS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_PRINCIPALS','CDB_XS_PRINCIPALS');
create or replace public synonym CDB_XS_PRINCIPALS for sys.CDB_XS_PRINCIPALS;
grant select on CDB_XS_PRINCIPALS to select_catalog_role;

-------------------------------------------------------------------------------
--                          DBA_XS_USERS
-------------------------------------------------------------------------------

create or replace view DBA_XS_USERS
(
  NAME,
  GUID,
  EXTERNAL_SOURCE,
  ROLES_DEFAULT_ENABLED,
  STATUS,
  ACCOUNT_STATUS,
  LOCK_DATE,
  EXPIRY_DATE,
  PROFILE,
  SCHEMA,
  START_DATE,
  END_DATE,
  DIRECT_LOGON_USER,
  VERIFIER_TYPE,
  ACL,
  DESCRIPTION
)
as
select o.name, p.guid, p.ext_src, decode(p.enable, 0, 'NO', 1, 'YES'), 
       case when ((p.start_date is NULL and p.end_date is NULL) or 
                  (p.start_date is NULL and systimestamp <= p.end_date) or 
                  (p.end_date is NULL and systimestamp >= p.start_date) or
                  (systimestamp between p.start_date and p.end_date)) and 
                  p.status = 1 then 'ACTIVE' else 'INACTIVE' end,
       m.status,
       decode(mod(p.astatus, 16), 4, p.ltime,
                                  5, p.ltime,
                                  6, p.ltime,
                                  8, p.ltime,
                                  9, p.ltime,
                                  10, p.ltime, to_date(NULL)),
       decode(mod(p.astatus, 16),
              1, p.exptime,
              2, p.exptime,
              5, p.exptime,
              6, p.exptime,
              9, p.exptime,
              10,p.exptime,
              decode(p.ptime, '', to_date(NULL),
                decode(pr.limit#, 2147483647, to_date(NULL),
                 decode(pr.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), p.ptime +
                     dp.limit#/86400),
                   p.ptime + pr.limit#/86400)))), 
       decode(p.profile#, NULL, NULL, pn.name),
       p.schema, p.start_date, p.end_date, 
       decode(xsver.user#, NULL, 'NO', 'YES'),
       decode(xsver.type#, 3, 'LEGACY SALTED SHA1',
                           2, 'SHA512',
                           1, 'SALTED SHA1',''), 
       decode(p.objacl#, NULL, NULL, 
              (select o2.name from sys.xs$obj o2 
              where o2.id = p.objacl#)),
       p.description 
  from sys.xs$prin p, sys.xs$obj o, sys.user_astatus_map m,
       sys.profname$ pn, sys.profile$ pr, sys.profile$ dp, 
       sys.xs$verifiers xsver
  where o.id = p.prin# and p.type = 0 and ((p.astatus = m.status#) or 
       (p.astatus = (m.status# + 16 - BITAND(m.status#, 16))))
       and p.profile# = pn.profile# 
       and p.profile# = pr.profile# 
       and pr.type# = 1 and pr.resource# = 1 
       and dp.profile# = 0
       and dp.type#=1
       and dp.resource#=1
       and p.prin# = xsver.user#(+)
/

comment on table DBA_XS_USERS is
'All the Real Application Security users defined in the database'
/

comment on column DBA_XS_USERS.NAME is
'Name of the user'
/

comment on column DBA_XS_USERS.GUID is
'GUID of the user'
/

comment on column DBA_XS_USERS.EXTERNAL_SOURCE is
'External source of the user'
/

comment on column DBA_XS_USERS.ROLES_DEFAULT_ENABLED is
'Indicates whether all the roles granted to the user are default enabled (YES) 
or not (NO)'
/

comment on column DBA_XS_USERS.STATUS is
'Status of the user. Possible values are ACTIVE, INACTIVE'
/

comment on column DBA_XS_USERS.ACCOUNT_STATUS is
'Direct Login status of the user caused due to profile associated with the user'
/

comment on column DBA_XS_USERS.LOCK_DATE is
'Direct login account locking date'
/

comment on column DBA_XS_USERS.EXPIRY_DATE is
'Direct login account expiry date'
/

comment on column DBA_XS_USERS.PROFILE is
'Name of database profile associated with the user'
/

comment on column DBA_XS_USERS.SCHEMA is
'User schema'
/

comment on column DBA_XS_USERS.START_DATE is
'Effective start date for the user'
/

comment on column DBA_XS_USERS.END_DATE is
'Effective end date for the user'
/
comment on column DBA_XS_USERS.DIRECT_LOGON_USER is
'Indicates whether this user has direct logon capability'
/
comment on column DBA_XS_USERS.VERIFIER_TYPE is
'Type of the verifier(e.g. LEGACY SALTED SHA1, SALTED SHA1, SHA512) assigned to the direct logon user'
/
comment on column DBA_XS_USERS.ACL is
'ACL set on the user'
/

comment on column DBA_XS_USERS.DESCRIPTION is
'Description of the user'
/

create or replace public synonym DBA_XS_USERS for DBA_XS_USERS
/

grant select on DBA_XS_USERS to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_USERS','CDB_XS_USERS');
create or replace public synonym CDB_XS_USERS for sys.CDB_XS_USERS;
grant select on CDB_XS_USERS to select_catalog_role;

-------------------------------------------------------------------------------
--                          USER_XS_USERS
-------------------------------------------------------------------------------
create or replace view USER_XS_USERS
(
  NAME,
  STATUS,
  ACCOUNT_STATUS,
  LOCK_DATE,
  EXPIRY_DATE,
  DIRECT_LOGON_USER,
  DESCRIPTION
)
as
select name, status, account_status, lock_date, expiry_date, 
 direct_logon_user, description
from dba_xs_users
where name = xs_sys_context('XS$SESSION','CURRENT_XS_USER')

/

comment on table USER_XS_USERS is
'Account information for the current user'
/

comment on column USER_XS_USERS.NAME is
'Name of the current user'
/

comment on column USER_XS_USERS.STATUS is
'Status of the current user. Possible values are ACTIVE, INACTIVE'
/

comment on column USER_XS_USERS.ACCOUNT_STATUS is
'Direct login account status for the current user'
/

comment on column USER_XS_USERS.LOCK_DATE is
'Account Lock date for direct login session for the current user'
/

comment on column USER_XS_USERS.EXPIRY_DATE is
'Account Expire date for direct login session for the current user'
/

comment on column DBA_XS_USERS.DIRECT_LOGON_USER is
'Indicates whether this user has direct logon capability'
/

comment on column USER_XS_USERS.DESCRIPTION is
'Description of the user'
/

create or replace public synonym USER_XS_USERS for USER_XS_USERS;

grant read on USER_XS_USERS to public;

-------------------------------------------------------------------------------
--                          USER_XS_PASSWORD_LIMITS
-------------------------------------------------------------------------------
create or replace view USER_XS_PASSWORD_LIMITS
(
  RESOURCE_NAME, 
  LIMIT
)
as select
  m.name,
  decode(u.limit#,
         2147483647, decode(u.resource#, 4, 'NULL', 'UNLIMITED'),
         -1, 0,
         0, decode(p.limit#,
                   2147483647, decode(p.resource#, 4, 'NULL', 'UNLIMITED'),
                   -1, 0,
                   decode(p.resource#,
                          4, po.name,
                          1, trunc(p.limit#/86400, 4),
                          2, trunc(p.limit#/86400, 4),
                          5, trunc(p.limit#/86400, 4),
                          6, trunc(p.limit#/86400, 4),
                          7, trunc(p.limit#/86400, 4), p.limit#)),
         decode(u.resource#,
                4, decode(nvl(SYS_CONTEXT('USERENV','CON_NAME'),
                                'CDB$ROOT'), 'CDB$ROOT', uo.name,
                              decode(bitand(n.flags,1), 1,
                                 'FROM ROOT', uo.name)),
                1, trunc(u.limit#/86400, 4),
                2, trunc(u.limit#/86400, 4),
                5, trunc(u.limit#/86400, 4),
                6, trunc(u.limit#/86400, 4),
                7, trunc(u.limit#/86400, 4),
                u.limit#))
  from sys.profile$ u, sys.profile$ p, sys.obj$ uo, sys.obj$ po,
       sys.resource_map m, sys.rxs$sessions xsse, sys.xs$prin xspr, 
       sys.profname$ n
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 1
  and m.type# = 1
  and uo.obj#(+) = u.limit#
  and po.obj#(+) = p.limit#
  and xsse.userid = xspr.prin#
  and u.profile# = xspr.profile#
  and u.profile# = n.profile# 
  and xsse.sid = xs_sys_context('XS$SESSION', 'SESSION_ID')
  and BITAND(xsse.flag,32) = 32
/
comment on table USER_XS_PASSWORD_LIMITS is
'Display password limits for currently logged on application user'
/
comment on column USER_XS_PASSWORD_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_XS_PASSWORD_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_XS_PASSWORD_LIMITS for USER_XS_PASSWORD_LIMITS
/
grant read on USER_XS_PASSWORD_LIMITS to PUBLIC
/


-------------------------------------------------------------------------------
--                          DBA_XS_ROLES
-------------------------------------------------------------------------------

create or replace view DBA_XS_ROLES
(
  NAME,
  GUID,
  EXTERNAL_SOURCE,
  DEFAULT_ENABLED,
  START_DATE,
  END_DATE,
  DESCRIPTION
)
as
select o.name, p.guid, p.ext_src, decode(p.enable, 0, 'NO', 1, 'YES'), 
       p.start_date, p.end_date, p.description
  from sys.xs$prin p, sys.xs$obj o
 where o.id = p.prin# and p.type = 1
/

comment on table DBA_XS_ROLES is
'All the Real Application Security roles defined in the database'
/

comment on column DBA_XS_ROLES.NAME is
'Name of the role'
/

comment on column DBA_XS_ROLES.GUID is
'GUID of the role'
/

comment on column DBA_XS_ROLES.EXTERNAL_SOURCE is
'External source of the role'
/

comment on column DBA_XS_ROLES.DEFAULT_ENABLED is
'Indicates whether the role is default enabled (YES) or not (NO)'
/

comment on column DBA_XS_ROLES.START_DATE is
'Effective start date for the role'
/

comment on column DBA_XS_ROLES.END_DATE is
'Effective end date for the role'
/

comment on column DBA_XS_ROLES.DESCRIPTION is
'Description of the role'
/

create or replace public synonym DBA_XS_ROLES for DBA_XS_ROLES;

grant select on DBA_XS_ROLES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ROLES','CDB_XS_ROLES');
create or replace public synonym CDB_XS_ROLES for sys.CDB_XS_ROLES;
grant select on CDB_XS_ROLES to select_catalog_role;

-------------------------------------------------------------------------------
--                          DBA_XS_DYNAMIC_ROLES
-------------------------------------------------------------------------------

create or replace view DBA_XS_DYNAMIC_ROLES
(
  NAME,
  GUID,
  DURATION,
  SYSTEM_DEFINED,
  SCOPE,
  ACL,
  DESCRIPTION
)
as
select o.name, p.guid, p.duration,
       decode(p.system, 0, 'NO', 1, 'YES'), 
       decode(p.scope, 0, 'SESSION', 1, 'REQUEST'), 
       decode(p.objacl#, NULL, NULL,
              (select o2.name from sys.xs$obj o2
               where o2.id = p.objacl#)),
       p.description
  from sys.xs$prin p, sys.xs$obj o
 where o.id = p.prin# and p.type = 2
/

comment on table DBA_XS_DYNAMIC_ROLES is
'All the Real Application Security dynamic roles defined in the database'
/

comment on column DBA_XS_DYNAMIC_ROLES.NAME is
'Name of the dynamic role'
/

comment on column DBA_XS_DYNAMIC_ROLES.GUID is
'GUID of the dynamic role'
/

comment on column DBA_XS_DYNAMIC_ROLES.DURATION is
'Duration (in minutes) for which the role is active'
/

comment on column DBA_XS_DYNAMIC_ROLES.SYSTEM_DEFINED is
'Indicates whether the dynamic role is system-defined'
/

comment on column DBA_XS_DYNAMIC_ROLES.SCOPE is
'Indicates whether the scope of the dynamic role is SESSION or REQUEST'
/

comment on column DBA_XS_DYNAMIC_ROLES.ACL is
'ACL set on the dynamic role'
/

comment on column DBA_XS_DYNAMIC_ROLES.DESCRIPTION is
'Description of the dynamic role'
/

create or replace public synonym DBA_XS_DYNAMIC_ROLES for DBA_XS_DYNAMIC_ROLES
/

grant select on DBA_XS_DYNAMIC_ROLES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_DYNAMIC_ROLES','CDB_XS_DYNAMIC_ROLES');
create or replace public synonym CDB_XS_DYNAMIC_ROLES for sys.CDB_XS_DYNAMIC_ROLES;
grant select on CDB_XS_DYNAMIC_ROLES to select_catalog_role;

-------------------------------------------------------------------------------
--                          DBA_XS_EXTERNAL_PRINCIPALS
-------------------------------------------------------------------------------

create or replace view DBA_XS_EXTERNAL_PRINCIPALS
(
 NAME
)
as
select o.name from sys.xs$obj o where o.type = 1 and o.status = 2
/

comment on table DBA_XS_EXTERNAL_PRINCIPALS is
'All the Real Application Security external principals'
/

comment on column DBA_XS_EXTERNAL_PRINCIPALS.NAME is
'Name of the external principal'
/

create or replace public synonym 
DBA_XS_EXTERNAL_PRINCIPALS for DBA_XS_EXTERNAL_PRINCIPALS
/

grant select on DBA_XS_EXTERNAL_PRINCIPALS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_EXTERNAL_PRINCIPALS','CDB_XS_EXTERNAL_PRINCIPALS');
create or replace public synonym CDB_XS_EXTERNAL_PRINCIPALS for sys.CDB_XS_EXTERNAL_PRINCIPALS;
grant select on CDB_XS_EXTERNAL_PRINCIPALS to select_catalog_role;

/******************************************************************************
                               Role Grant Views
******************************************************************************/
-------------------------------------------------------------------------------
--                          DBA_XS_ROLE_GRANTS
-------------------------------------------------------------------------------

create or replace view DBA_XS_ROLE_GRANTS
(
  GRANTEE,
  GRANTED_ROLE,
  GRANTED_ROLE_TYPE,
  START_DATE,
  END_DATE
)
as
select o1.name, o2.name, 'APPLICATION', rg.start_date, rg.end_date
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$role_grant rg
 where o1.id = rg.grantee# and o2.id = rg.role#
union
select o1.name, u1.name, 'DATABASE', NULL, NULL
  from sys.xs$obj o1, sys.sysauth$ sa, sys.user$ u1
 where o1.id = sa.grantee# and u1.user# = sa.privilege#;
/

comment on table DBA_XS_ROLE_GRANTS is
'All the Real Application Security role grants'
/

comment on column DBA_XS_ROLE_GRANTS.GRANTEE is
'Name of the grantee'
/

comment on column DBA_XS_ROLE_GRANTS.GRANTED_ROLE is
'Name of the granted role'
/

comment on column DBA_XS_ROLE_GRANTS.GRANTED_ROLE_TYPE is
'Type of the granted role'
/

comment on column DBA_XS_ROLE_GRANTS.START_DATE is
'Effective start date of the role grant'
/

comment on column DBA_XS_ROLE_GRANTS.END_DATE is
'Effective end date of the role grant'
/

create or replace public synonym 
DBA_XS_ROLE_GRANTS for DBA_XS_ROLE_GRANTS
/

grant select on DBA_XS_ROLE_GRANTS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ROLE_GRANTS','CDB_XS_ROLE_GRANTS');
create or replace public synonym CDB_XS_ROLE_GRANTS for sys.CDB_XS_ROLE_GRANTS;
grant select on CDB_XS_ROLE_GRANTS to select_catalog_role;

-------------------------------------------------------------------------------
--                          DBA_XS_PROXY_ROLES
-------------------------------------------------------------------------------

create or replace view DBA_XS_PROXY_ROLES
(
  PROXY_USER,
  PROXY_USER_TYPE,
  TARGET_USER,
  TARGET_USER_TYPE,
  TARGET_ROLE
)
as
select o1.name, 'RAS_USER', o2.name, 'RAS_USER', o3.name
  from sys.xs$proxy_role pr, sys.xs$obj o1, sys.xs$obj o2,sys.xs$obj o3
  where pr.proxy# = o1.id and  pr.client# = o2.id and pr.role# = o3.id
union
select o1.name, 'RAS_USER', o2.name, 'RAS_USER', 'ALL_ROLES'
  from sys.xs$proxy_role pr, sys.xs$obj o1, sys.xs$obj o2
  where pr.proxy# = o1.id and  pr.client# = o2.id and pr.role# is NULL
union
select o1.name, DECODE(o1.status,1,'RAS_USER',2,'EXTERNAL_RAS_USER'), 
       u.name, 'DATABASE_USER', 'ALL_ROLES'
  from sys.xs$proxy_role pr, sys.xs$obj o1, sys.user$ u
  where pr.proxy# = o1.id and  pr.client# = u.user# and pr.role# is NULL
/

comment on table DBA_XS_PROXY_ROLES is
'All the Real Application Security proxy role grants'
/

comment on column DBA_XS_PROXY_ROLES.PROXY_USER is
'Name of the proxy user'
/

comment on column DBA_XS_PROXY_ROLES.PROXY_USER_TYPE is
'Type of the proxy user'
/

comment on column DBA_XS_PROXY_ROLES.TARGET_USER is
'Name of the target user'
/

comment on column DBA_XS_PROXY_ROLES.TARGET_USER_TYPE is
'Type of the target user'
/

comment on column DBA_XS_PROXY_ROLES.TARGET_ROLE is
'Name of the target role'
/

create or replace public synonym 
DBA_XS_PROXY_ROLES for DBA_XS_PROXY_ROLES
/

grant select on DBA_XS_PROXY_ROLES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_PROXY_ROLES','CDB_XS_PROXY_ROLES');
create or replace public synonym CDB_XS_PROXY_ROLES for sys.CDB_XS_PROXY_ROLES;
grant select on CDB_XS_PROXY_ROLES to select_catalog_role;

/******************************************************************************
                            Namespace Template Views
******************************************************************************/
-------------------------------------------------------------------------------
--                          DBA_XS_NS_TEMPLATES
-------------------------------------------------------------------------------

create or replace view DBA_XS_NS_TEMPLATES
(
  NAME,
  HANDLER_SCHEMA,
  HANDLER_PACKAGE,
  HANDLER_FUNCTION,
  HANDLER_STATUS,
  ACL,
  DESCRIPTION
)
as
select o1.name, n.hschema, n.hpname, n.hfname, 
       decode(n.hfname, null, null, 
              decode((select 1
                        from sys.all_arguments a
                       where a.owner = n.hschema                -- match schema
                         and ((a.package_name = n.hpname)       -- in a package
                              or ((n.hpname is null)       -- outside a package
                                  and (a.package_name is null)))
                         and a.object_name = n.hfname    -- match function name
                       group by a.overload
                      having sum(decode(a.data_type,              -- Match type
                                        decode(a.position,    -- Match position
                                               0, 'BINARY_INTEGER',
                                               1, 'RAW',
                                               2, 'VARCHAR2',
                                               3, 'VARCHAR2',
                                               4, 'VARCHAR2',
                                               5, 'VARCHAR2',
                                               6, 'BINARY_INTEGER',  
                                                  chr(0)),    1,
                                        -1)) = 7
                         and sum(decode(a.in_out,               -- Match in out
                                        decode(a.position,    -- Match position
                                               0, 'OUT',
                                                  'IN'),      1,
                                        -1)) = 7
                     ), 
                     1, 'VALID', 'INVALID')),
       o2.name, n.description
  from sys.xs$obj o1, sys.xs$nstmpl n, sys.xs$obj o2
 where o1.id = n.ns# and o2.id = n.acl#
/

comment on table DBA_XS_NS_TEMPLATES is
'All the Real Application Security namespace templates'
/

comment on column DBA_XS_NS_TEMPLATES.NAME is
'Name of the namespace template'
/

comment on column DBA_XS_NS_TEMPLATES.HANDLER_SCHEMA is
'Schema of the event handler function'
/

comment on column DBA_XS_NS_TEMPLATES.HANDLER_PACKAGE is
'Package of the event handler function'
/

comment on column DBA_XS_NS_TEMPLATES.HANDLER_FUNCTION is
'Name of the event handler function'
/

comment on column DBA_XS_NS_TEMPLATES.ACL is
'Name of the acl assocaited with the namespace template'
/

comment on column DBA_XS_NS_TEMPLATES.HANDLER_STATUS is
'Indicates whether the event handler function is VALID or INVALID'
/

comment on column DBA_XS_NS_TEMPLATES.DESCRIPTION is
'Description of the namespace template'
/

create or replace public synonym DBA_XS_NS_TEMPLATES
for DBA_XS_NS_TEMPLATES
/

grant select on DBA_XS_NS_TEMPLATES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_NS_TEMPLATES','CDB_XS_NS_TEMPLATES');
create or replace public synonym CDB_XS_NS_TEMPLATES for sys.CDB_XS_NS_TEMPLATES;
grant select on CDB_XS_NS_TEMPLATES to select_catalog_role;

-------------------------------------------------------------------------------
--                       DBA_XS_NS_TEMPLATE_ATTRIBUTES
-------------------------------------------------------------------------------

create or replace view DBA_XS_NS_TEMPLATE_ATTRIBUTES
(
  ATTRIBUTE,
  NAMESPACE, 
  DEFAULT_VALUE,
  FIRSTREAD_EVENT,
  MODIFY_EVENT)
as
select na.attr_name, o.name, na.def_value,
       decode(bitand(na.event_cbk, 1), 1, 'YES', 'NO'),
       decode(bitand(na.event_cbk, 2), 2, 'YES', 'NO')
  from sys.xs$obj o, sys.xs$nstmpl_attr na
 where o.id = na.ns#
/

comment on table DBA_XS_NS_TEMPLATE_ATTRIBUTES is
'All the attributes of Real Application Security namespace templates'
/

comment on column DBA_XS_NS_TEMPLATE_ATTRIBUTES.ATTRIBUTE is
'Name of the attribute'
/

comment on column DBA_XS_NS_TEMPLATE_ATTRIBUTES.NAMESPACE is
'Name of the namespace template in which the attribute is defined'
/

comment on column DBA_XS_NS_TEMPLATE_ATTRIBUTES.DEFAULT_VALUE
is 'Default value of the attribute'
/

comment on column DBA_XS_NS_TEMPLATE_ATTRIBUTES.FIRSTREAD_EVENT is
'Indicates whether the event handler function will be invoked at the first time of reading the attribute (YES) or not (NO)'
/

comment on column DBA_XS_NS_TEMPLATE_ATTRIBUTES.MODIFY_EVENT is
'Indicates whether the event handler function will be invoked at the time of modifyig the attribute (YES) or not (NO)'
/

create or replace public synonym DBA_XS_NS_TEMPLATE_ATTRIBUTES
for DBA_XS_NS_TEMPLATE_ATTRIBUTES
/

grant select on DBA_XS_NS_TEMPLATE_ATTRIBUTES to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_NS_TEMPLATE_ATTRIBUTES','CDB_XS_NS_TEMPLATE_ATTRIBUTES');
create or replace public synonym CDB_XS_NS_TEMPLATE_ATTRIBUTES for sys.CDB_XS_NS_TEMPLATE_ATTRIBUTES;
grant select on CDB_XS_NS_TEMPLATE_ATTRIBUTES to select_catalog_role;


/******************************************************************************
                            Security Class Views
******************************************************************************/

-------------------------------------------------------------------------------
--                       DBA_XS_SECURITY_CLASSES
-------------------------------------------------------------------------------

create or replace view DBA_XS_SECURITY_CLASSES
(
  NAME,
  OWNER,
  DESCRIPTION
)
as
select o.name, o.owner, s.description 
  from sys.xs$obj o, sys.xs$seccls s
 where o.id = s.sc#;
/

comment on table DBA_XS_SECURITY_CLASSES is
'All the Real Application Security security classes defined in the database'
/

comment on column DBA_XS_SECURITY_CLASSES.NAME is
'Name of the security class'
/

comment on column DBA_XS_SECURITY_CLASSES.OWNER is
'Owner of the security class'
/

comment on column DBA_XS_SECURITY_CLASSES.DESCRIPTION is
'Description of the security class'
/

create or replace public synonym 
DBA_XS_SECURITY_CLASSES for DBA_XS_SECURITY_CLASSES
/

grant select on DBA_XS_SECURITY_CLASSES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_SECURITY_CLASSES','CDB_XS_SECURITY_CLASSES');
create or replace public synonym CDB_XS_SECURITY_CLASSES for sys.CDB_XS_SECURITY_CLASSES;
grant select on CDB_XS_SECURITY_CLASSES to select_catalog_role;

-------------------------------------------------------------------------------
--                       ALL_XS_SECURITY_CLASSES
-------------------------------------------------------------------------------

create or replace view ALL_XS_SECURITY_CLASSES
(
  NAME,
  OWNER,
  DESCRIPTION
)
as
select DISTINCT o.name, o.owner, s.description 
from sys.xs$obj o, sys.xs$seccls s, sys.xs$obj o2
where o.id = s.sc# and
      ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o.owner != 'SYS') or
       o.owner = sys_context('USERENV','CURRENT_USER') or
       (o.owner=o2.owner and o2.name='XS$SCHEMA_ACL' and o2.type=3 and
        ORA_CHECK_ACL(TO_ACLID(o2.owner||'.XS$SCHEMA_ACL'), 'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_SECURITY_CLASSES is
'All the Real Application Security security classes accessible to the current user'
/

comment on column ALL_XS_SECURITY_CLASSES.NAME is
'Name of the security class'
/

comment on column ALL_XS_SECURITY_CLASSES.OWNER is
'Owner of the security class'
/

comment on column ALL_XS_SECURITY_CLASSES.DESCRIPTION is
'Description of the security class'
/

create or replace public synonym 
ALL_XS_SECURITY_CLASSES for ALL_XS_SECURITY_CLASSES
/

grant read on ALL_XS_SECURITY_CLASSES to public;

-------------------------------------------------------------------------------
--                       USER_XS_SECURITY_CLASSES
-------------------------------------------------------------------------------

create or replace view USER_XS_SECURITY_CLASSES
(
  NAME,
  DESCRIPTION
)
as
select name, description from sys.dba_xs_security_classes
 where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_SECURITY_CLASSES is
'All the Real Application Security security classes owned by the current user'
/

comment on column USER_XS_SECURITY_CLASSES.NAME is
'Name of the security class'
/

comment on column USER_XS_SECURITY_CLASSES.DESCRIPTION is
'Description of the security class'
/

create or replace public synonym 
USER_XS_SECURITY_CLASSES for USER_XS_SECURITY_CLASSES
/

grant read on USER_XS_SECURITY_CLASSES to public;


-------------------------------------------------------------------------------
--                      DBA_XS_SECURITY_CLASS_DEP
-------------------------------------------------------------------------------

create or replace view DBA_XS_SECURITY_CLASS_DEP
(
  SECURITY_CLASS,
  OWNER,
  PARENT,
  PARENT_OWNER
)
as
select o1.name, o1.owner, o2.name, o2.owner
from sys.xs$obj o1, sys.xs$obj o2, sys.xs$seccls_h sh
where o1.id = sh.sc# and o2.id = sh.parent_sc#;
/

comment on table DBA_XS_SECURITY_CLASS_DEP is
'The dependencies between all the Real Application Security security classes defined in the database'
/

comment on column DBA_XS_SECURITY_CLASS_DEP.SECURITY_CLASS is
'Name of the security class'
/

comment on column DBA_XS_SECURITY_CLASS_DEP.OWNER is
'Owner of the security class'
/

comment on column DBA_XS_SECURITY_CLASS_DEP.PARENT is
'Name of the parent security class'
/

comment on column DBA_XS_SECURITY_CLASS_DEP.PARENT_OWNER is
'Owner of the parent security class'
/

create or replace public synonym 
DBA_XS_SECURITY_CLASS_DEP for DBA_XS_SECURITY_CLASS_DEP
/

grant select on DBA_XS_SECURITY_CLASS_DEP to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_SECURITY_CLASS_DEP','CDB_XS_SECURITY_CLASS_DEP');
create or replace public synonym CDB_XS_SECURITY_CLASS_DEP for sys.CDB_XS_SECURITY_CLASS_DEP;
grant select on CDB_XS_SECURITY_CLASS_DEP to select_catalog_role;

-------------------------------------------------------------------------------
--                      ALL_XS_SECURITY_CLASS_DEP
-------------------------------------------------------------------------------

create or replace view ALL_XS_SECURITY_CLASS_DEP
(
  SECURITY_CLASS,
  OWNER,
  PARENT,
  PARENT_OWNER
)
as
select DISTINCT o1.name, o1.owner, o2.name, o2.owner
from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$seccls_h sh
where o1.id = sh.sc# and o2.id = sh.parent_sc# and
      ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or 
       o1.owner = sys_context('USERENV','CURRENT_USER') or
       (o1.owner=o3.owner and o3.name='XS$SCHEMA_ACL' and o3.type=3 and
        ORA_CHECK_ACL(TO_ACLID(o3.owner||'.XS$SCHEMA_ACL'), 
                      'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_SECURITY_CLASS_DEP is
'All the Real Application Security class dependencies of the security classes
that are accessible to the current user'
/

comment on column ALL_XS_SECURITY_CLASS_DEP.SECURITY_CLASS is
'Name of the security class'
/

comment on column ALL_XS_SECURITY_CLASS_DEP.OWNER is
'Owner of the security class'
/

comment on column ALL_XS_SECURITY_CLASS_DEP.PARENT is
'Name of the parent security class'
/

comment on column ALL_XS_SECURITY_CLASS_DEP.PARENT_OWNER is
'Owner of the parent security class'
/

create or replace public synonym 
ALL_XS_SECURITY_CLASS_DEP for ALL_XS_SECURITY_CLASS_DEP
/

grant read on ALL_XS_SECURITY_CLASS_DEP to public;

-------------------------------------------------------------------------------
--                      USER_XS_SECURITY_CLASS_DEP
-------------------------------------------------------------------------------

create or replace view USER_XS_SECURITY_CLASS_DEP
(
  SECURITY_CLASS,
  PARENT,
  PARENT_OWNER
)
as
select security_class, parent, parent_owner from sys.dba_xs_security_class_dep
where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_SECURITY_CLASS_DEP is
'All the Real Application Security class dependencies of the security classes
that are owned by the current user'
/

comment on column USER_XS_SECURITY_CLASS_DEP.SECURITY_CLASS is
'Name of the security class'
/

comment on column USER_XS_SECURITY_CLASS_DEP.PARENT is
'Name of the parent security class'
/

comment on column USER_XS_SECURITY_CLASS_DEP.PARENT_OWNER is
'Owner of the parent security class'
/

create or replace public synonym 
USER_XS_SECURITY_CLASS_DEP for USER_XS_SECURITY_CLASS_DEP
/

grant read on USER_XS_SECURITY_CLASS_DEP to public;

-------------------------------------------------------------------------------
--                      DBA_XS_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view DBA_XS_PRIVILEGES
(
  NAME,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER,
  DESCRIPTION
)
as
select o1.name, o2.name, o2.owner, p.description
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$priv p
 where o1.id = p.priv# and o2.id = p.sc#
/

comment on table DBA_XS_PRIVILEGES is
'All the Real Application Security privileges defined in the database'
/

comment on column DBA_XS_PRIVILEGES.NAME is
'Name of the privilege'
/

comment on column DBA_XS_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege'
/

comment on column DBA_XS_PRIVILEGES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the privilege'
/

comment on column DBA_XS_PRIVILEGES.DESCRIPTION is
'Description of the privilege'
/

create or replace public synonym DBA_XS_PRIVILEGES for DBA_XS_PRIVILEGES
/

grant select on DBA_XS_PRIVILEGES to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_PRIVILEGES','CDB_XS_PRIVILEGES');
create or replace public synonym CDB_XS_PRIVILEGES for sys.CDB_XS_PRIVILEGES;
grant select on CDB_XS_PRIVILEGES to select_catalog_role;

-------------------------------------------------------------------------------
--                      ALL_XS_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view ALL_XS_PRIVILEGES
(
  NAME,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER,
  DESCRIPTION
)
as
select DISTINCT o1.name, o2.name, o2.owner, p.description
from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$priv p
where o1.id = p.priv# and o2.id = p.sc# and
      ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o2.owner != 'SYS') or
       o2.owner = sys_context('USERENV','CURRENT_USER') or
       (o2.owner=o3.owner and o3.name='XS$SCHEMA_ACL' and o3.type=3 and
        ORA_CHECK_ACL(TO_ACLID(o3.owner||'.XS$SCHEMA_ACL'), 
                      'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_PRIVILEGES is
'All the Real Application Security privileges scoped by the security classes accessible to the current user'
/

comment on column ALL_XS_PRIVILEGES.NAME is
'Name of the privilege'
/

comment on column ALL_XS_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege'
/

comment on column ALL_XS_PRIVILEGES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the privilege'
/

comment on column ALL_XS_PRIVILEGES.DESCRIPTION is
'Description of the privilege'
/

create or replace public synonym ALL_XS_PRIVILEGES for ALL_XS_PRIVILEGES
/

grant read on ALL_XS_PRIVILEGES to public;

-------------------------------------------------------------------------------
--                      USER_XS_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view USER_XS_PRIVILEGES
(
  NAME,
  SECURITY_CLASS,
  DESCRIPTION
)
as
select name, security_class, description from sys.dba_xs_privileges
 where security_class_owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_PRIVILEGES is
'All the Real Application Security privileges scoped by the security classes owned by the current user'
/

comment on column USER_XS_PRIVILEGES.NAME is
'Name of the privilege'
/

comment on column USER_XS_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege'
/

comment on column USER_XS_PRIVILEGES.DESCRIPTION is
'Description of the privilege'
/

create or replace public synonym USER_XS_PRIVILEGES for USER_XS_PRIVILEGES
/

grant read on USER_XS_PRIVILEGES to public;


-------------------------------------------------------------------------------
--                      DBA_XS_IMPLIED_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view DBA_XS_IMPLIED_PRIVILEGES
(
  PRIVILEGE,
  IMPLIED_PRIVILEGE,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER
)
as
select o1.name, o2.name, o3.name, o3.owner
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$aggr_priv agp
 where o1.id = agp.aggr_priv# and o2.id = agp.implied_priv# and 
       o3.id = agp.sc#
/

comment on table DBA_XS_IMPLIED_PRIVILEGES is
'All the Real Application Security implied privileges defined in the database'
/

comment on column DBA_XS_IMPLIED_PRIVILEGES.PRIVILEGE is
'Name of the privilege that has implied privileges'
/

comment on column DBA_XS_IMPLIED_PRIVILEGES.IMPLIED_PRIVILEGE is
'Name of the implied privilege'
/

comment on column DBA_XS_IMPLIED_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege and the implied privilege'
/

comment on column DBA_XS_IMPLIED_PRIVILEGES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the privilege and the implied privilege'
/

create or replace public synonym 
DBA_XS_IMPLIED_PRIVILEGES for DBA_XS_IMPLIED_PRIVILEGES
/

grant select on DBA_XS_IMPLIED_PRIVILEGES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_IMPLIED_PRIVILEGES','CDB_XS_IMPLIED_PRIVILEGES');
create or replace public synonym CDB_XS_IMPLIED_PRIVILEGES for sys.CDB_XS_IMPLIED_PRIVILEGES;
grant select on CDB_XS_IMPLIED_PRIVILEGES to select_catalog_role;

-------------------------------------------------------------------------------
--                      ALL_XS_IMPLIED_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view ALL_XS_IMPLIED_PRIVILEGES
(
  PRIVILEGE,
  IMPLIED_PRIVILEGE,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER
)
as
select DISTINCT o1.name, o2.name, o3.name, o3.owner
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$obj o4, 
       sys.xs$aggr_priv agp
 where o1.id = agp.aggr_priv# and o2.id = agp.implied_priv# and 
       o3.id = agp.sc# and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o3.owner != 'SYS') 
        or 
        o3.owner = sys_context('USERENV','CURRENT_USER') or
        (o3.owner=o4.owner and o4.name='XS$SCHEMA_ACL' and o4.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o4.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_IMPLIED_PRIVILEGES is
'All the Real Application Security implied privileges scoped by the security classes accessible to the current user'
/

comment on column ALL_XS_IMPLIED_PRIVILEGES.PRIVILEGE is
'Name of the privilege that has implied privileges'
/

comment on column ALL_XS_IMPLIED_PRIVILEGES.IMPLIED_PRIVILEGE is
'Name of the implied privilege'
/

comment on column ALL_XS_IMPLIED_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege and the implied privilege'
/

comment on column ALL_XS_IMPLIED_PRIVILEGES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the privilege and the implied privilege'
/

create or replace public synonym 
ALL_XS_IMPLIED_PRIVILEGES for ALL_XS_IMPLIED_PRIVILEGES
/

grant read on ALL_XS_IMPLIED_PRIVILEGES to public;

-------------------------------------------------------------------------------
--                      USER_XS_IMPLIED_PRIVILEGES
-------------------------------------------------------------------------------

create or replace view USER_XS_IMPLIED_PRIVILEGES
(
  PRIVILEGE,
  IMPLIED_PRIVILEGE,
  SECURITY_CLASS
)
as
select privilege, implied_privilege, security_class 
  from sys.dba_xs_implied_privileges
 where security_class_owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_IMPLIED_PRIVILEGES is
'All the Real Application Security implied privileges scoped by the security classes owned by the current user'
/

comment on column USER_XS_IMPLIED_PRIVILEGES.PRIVILEGE is
'Name of the privilege that has implied privileges'
/

comment on column USER_XS_IMPLIED_PRIVILEGES.IMPLIED_PRIVILEGE is
'Name of the implied privilege'
/

comment on column USER_XS_IMPLIED_PRIVILEGES.SECURITY_CLASS is
'Name of the security class that scopes the privilege and the implied privilege'
/

create or replace public synonym 
USER_XS_IMPLIED_PRIVILEGES for USER_XS_IMPLIED_PRIVILEGES
/

grant read on USER_XS_IMPLIED_PRIVILEGES to public;


/******************************************************************************
                                 ACL Views
******************************************************************************/
-------------------------------------------------------------------------------
--                             DBA_XS_ACLS
-------------------------------------------------------------------------------

create or replace view DBA_XS_ACLS
(
  NAME, 
  OWNER,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER,
  PARENT_ACL,
  PARENT_ACL_OWNER,
  INHERITANCE_TYPE,
  DESCRIPTION
)
as
select o1.name, o1.owner, o2.name, o2.owner, o3.name, o3.owner, 
       decode(a.acl_flag,1,'EXTENDED',2,'CONSTRAINED','NONE'), a.description
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$acl a
 where o1.id = a.acl# and o2.id(+) = a.sc# and o3.id(+) = a.parent_acl#
/

comment on table DBA_XS_ACLS is
'All the Real Application Security ACLs defined in the database'
/

comment on column DBA_XS_ACLS.NAME is
'Name of the ACL'
/

comment on column DBA_XS_ACLS.OWNER is
'Owner of the ACL'
/

comment on column DBA_XS_ACLS.SECURITY_CLASS is
'Name of the security class associated with ACL'
/

comment on column DBA_XS_ACLS.SECURITY_CLASS_OWNER is
'Owner of the security class associated with ACL'
/

comment on column DBA_XS_ACLS.PARENT_ACL is
'Name of the parent ACL'
/

comment on column DBA_XS_ACLS.PARENT_ACL_OWNER is
'Owner of the parent ACL'
/

comment on column DBA_XS_ACLS.INHERITANCE_TYPE is
'Inheritance type of the ACL'
/

comment on column DBA_XS_ACLS.DESCRIPTION is
'Description of the ACL'
/

create or replace public synonym DBA_XS_ACLS for DBA_XS_ACLS
/

grant select on DBA_XS_ACLS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ACLS','CDB_XS_ACLS');
create or replace public synonym CDB_XS_ACLS for sys.CDB_XS_ACLS;
grant select on CDB_XS_ACLS to select_catalog_role;

-------------------------------------------------------------------------------
--                             ALL_XS_ACLS
-------------------------------------------------------------------------------

create or replace view ALL_XS_ACLS
(
  NAME, 
  OWNER,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER,
  PARENT_ACL,
  PARENT_ACL_OWNER,
  INHERITANCE_TYPE,
  DESCRIPTION
)
as
select DISTINCT o1.name, o1.owner, o2.name, o2.owner, o3.name, o3.owner, 
       decode(a.acl_flag,1,'EXTENDED',2,'CONSTRAINED','NONE'), a.description
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$obj o4, sys.xs$acl a
 where o1.id = a.acl# and o2.id(+) = a.sc# and o3.id(+) = a.parent_acl# and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or
        o1.owner = sys_context('USERENV','CURRENT_USER') or
        (o1.owner=o4.owner and o4.name='XS$SCHEMA_ACL' and o4.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o4.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1)) and
        o1.name != 'XS$SCHEMA_ACL';
/

comment on table ALL_XS_ACLS is
'All the Real Application Security ACLs accessible to the current user'
/

comment on column ALL_XS_ACLS.NAME is
'Name of the ACL'
/

comment on column ALL_XS_ACLS.OWNER is
'Owner of the ACL'
/

comment on column ALL_XS_ACLS.SECURITY_CLASS is
'Name of the security class associated with ACL'
/

comment on column ALL_XS_ACLS.SECURITY_CLASS_OWNER is
'Owner of the security class associated with ACL'
/

comment on column ALL_XS_ACLS.PARENT_ACL is
'Name of the parent ACL'
/

comment on column ALL_XS_ACLS.PARENT_ACL_OWNER is
'Owner of the parent ACL'
/

comment on column ALL_XS_ACLS.INHERITANCE_TYPE is
'Inheritance type of the ACL'
/

comment on column ALL_XS_ACLS.DESCRIPTION is
'Description of the ACL'
/

create or replace public synonym ALL_XS_ACLS for ALL_XS_ACLS
/

grant read on ALL_XS_ACLS to public;

-------------------------------------------------------------------------------
--                             USER_XS_ACLS
-------------------------------------------------------------------------------

create or replace view USER_XS_ACLS
(
  NAME, 
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER,
  PARENT_ACL,
  PARENT_ACL_OWNER,
  INHERITANCE_TYPE,
  DESCRIPTION
)
as
select name, security_class, security_class_owner, 
       parent_acl, parent_acl_owner, inheritance_type, description
  from sys.dba_xs_acls
 where owner = sys_context('USERENV','CURRENT_USER') and
       name != 'XS$SCHEMA_ACL';
/

comment on table USER_XS_ACLS is
'All the Real Application Security ACLs owned by the current user'
/

comment on column USER_XS_ACLS.NAME is
'Name of the ACL'
/

comment on column USER_XS_ACLS.SECURITY_CLASS is
'Name of the security class associated with ACL'
/

comment on column USER_XS_ACLS.SECURITY_CLASS_OWNER is
'Owner of the security class associated with ACL'
/

comment on column USER_XS_ACLS.PARENT_ACL is
'Name of the parent ACL'
/

comment on column USER_XS_ACLS.PARENT_ACL_OWNER is
'Owner of the parent ACL'
/

comment on column USER_XS_ACLS.INHERITANCE_TYPE is
'Inheritance type of the ACL'
/

comment on column USER_XS_ACLS.DESCRIPTION is
'Description of the ACL'
/

create or replace public synonym USER_XS_ACLS for USER_XS_ACLS
/

grant read on USER_XS_ACLS to public;

-------------------------------------------------------------------------------
--                             DBA_XS_ACES
-------------------------------------------------------------------------------

create or replace view DBA_XS_ACES
(
  ACL,
  OWNER,
  ACE_ORDER,
  START_DATE,
  END_DATE,
  GRANT_TYPE,
  INVERTED_PRINCIPAL, 
  PRINCIPAL,
  PRINCIPAL_TYPE, 
  PRIVILEGE,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER
)
as
select o1.name, o1.owner, ace.order#, ace.start_date, ace.end_date, 
       decode (ace.ace_type, 1, 'GRANT', 0, 'DENY'),
       decode (ace.prin_invert, 1, 'YES', 0, 'NO'),
       case ace.prin_type
            when 2 then (select u.name from sys.user$ u 
                          where u.user# = ace.prin#)
            else        (select o.name from sys.xs$obj o where o.id = ace.prin#)
       end,
       decode (ace.prin_type, 1, 'APPLICATION',
                              2, 'DATABASE',
                              4, 'EXTERNAL'),
       o2.name, o3.name, o3.owner 
  from sys.xs$acl acl, sys.xs$ace ace, sys.xs$ace_priv ace_priv,
       sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3
 where acl.acl# = ace.acl# and 
       ace.acl# = ace_priv.acl# and ace.order# = ace_priv.ace_order# and
       o1.id = ace.acl# and o2.id = ace_priv.priv# and o3.id(+) = acl.sc#
/

comment on table DBA_XS_ACES is
'All the Real Application Security ACES defined in database'
/

comment on column DBA_XS_ACES.ACL is
'Name of the ACL'
/

comment on column DBA_XS_ACES.OWNER is
'Owner of the ACL'
/

comment on column DBA_XS_ACES.ACE_ORDER is
'Order number of the ACE in the ACL'
/

comment on column DBA_XS_ACES.START_DATE is
'Effective start date of the ACE'
/

comment on column DBA_XS_ACES.END_DATE is
'Effective end date of the ACE'
/

comment on column DBA_XS_ACES.GRANT_TYPE is
'Indicates whether the ACE GRANT or DENY the privileges'
/

comment on column DBA_XS_ACES.INVERTED_PRINCIPAL is
'Indicates whether the principal is inverted (YES) or not (NO)'
/

comment on column DBA_XS_ACES.PRINCIPAL_TYPE is
'Type of the principal'
/

comment on column DBA_XS_ACES.PRIVILEGE is
'Name of the privilege'
/

comment on column DBA_XS_ACES.SECURITY_CLASS is
'Name of the security class that scopes the ACL'
/

comment on column DBA_XS_ACES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the ACL'
/

create or replace public synonym DBA_XS_ACES for DBA_XS_ACES
/

grant select on DBA_XS_ACES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ACES','CDB_XS_ACES');
create or replace public synonym CDB_XS_ACES for sys.CDB_XS_ACES;
grant select on CDB_XS_ACES to select_catalog_role;

-------------------------------------------------------------------------------
--                             ALL_XS_ACES
-------------------------------------------------------------------------------

create or replace view ALL_XS_ACES
(
  ACL,
  OWNER,
  ACE_ORDER,
  START_DATE,
  END_DATE,
  GRANT_TYPE,
  INVERTED_PRINCIPAL, 
  PRINCIPAL,
  PRINCIPAL_TYPE, 
  PRIVILEGE,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER
)
as
select DISTINCT o1.name, o1.owner, ace.order#, ace.start_date, ace.end_date, 
       decode (ace.ace_type, 1, 'GRANT', 0, 'DENY'),
       decode (ace.prin_invert, 1, 'YES', 0, 'NO'),
       case ace.prin_type
            when 2 then (select u.name from sys.user$ u 
                          where u.user# = ace.prin#)
            else        (select o.name from sys.xs$obj o where o.id = ace.prin#)
       end,
       decode (ace.prin_type, 1, 'APPLICATION',
                              2, 'DATABASE',
                              4, 'EXTERNAL'),
       o2.name, o3.name, o3.owner 
  from sys.xs$acl acl, sys.xs$ace ace, sys.xs$ace_priv ace_priv,
       sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$obj o4
 where acl.acl# = ace.acl# and 
       ace.acl# = ace_priv.acl# and ace.order# = ace_priv.ace_order# and
       o1.id = ace.acl# and o2.id = ace_priv.priv# and o3.id(+) = acl.sc# and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or
        o1.owner = sys_context('USERENV','CURRENT_USER') or
        (o1.owner=o4.owner and o4.name='XS$SCHEMA_ACL' and o4.type=3 and
        ORA_CHECK_ACL(TO_ACLID(o4.owner||'.XS$SCHEMA_ACL'), 
                      'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_ACES is
'All the Real Application Security ACES of the ACLs accessible to the current user'
/

comment on column ALL_XS_ACES.ACL is
'Name of the ACL'
/

comment on column ALL_XS_ACES.OWNER is
'Owner of the ACL'
/

comment on column ALL_XS_ACES.ACE_ORDER is
'Order number of the ACE in the ACL'
/

comment on column ALL_XS_ACES.START_DATE is
'Effective start date of the ACE'
/

comment on column ALL_XS_ACES.END_DATE is
'Effective end date of the ACE'
/

comment on column ALL_XS_ACES.GRANT_TYPE is
'Indicates whether the ACE GRANT or DENY the privileges'
/

comment on column ALL_XS_ACES.INVERTED_PRINCIPAL is
'Indicates whether the principal is inverted (YES) or not (NO)'
/

comment on column ALL_XS_ACES.PRINCIPAL_TYPE is
'Type of the principal'
/

comment on column ALL_XS_ACES.PRIVILEGE is
'Name of the privilege'
/

comment on column ALL_XS_ACES.SECURITY_CLASS is
'Name of the security class that scopes the ACL'
/

comment on column ALL_XS_ACES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the ACL'
/

create or replace public synonym ALL_XS_ACES for ALL_XS_ACES
/

grant read on ALL_XS_ACES to public;

-------------------------------------------------------------------------------
--                             USER_XS_ACES
-------------------------------------------------------------------------------

create or replace view USER_XS_ACES
(
  ACL,
  ACE_ORDER,
  START_DATE,
  END_DATE,
  GRANT_TYPE,
  INVERTED_PRINCIPAL, 
  PRINCIPAL,
  PRINCIPAL_TYPE, 
  PRIVILEGE,
  SECURITY_CLASS,
  SECURITY_CLASS_OWNER
)
as
select acl, ace_order, start_date, end_date,
       grant_type, inverted_principal, principal, principal_type, 
       privilege, security_class, security_class_owner
  from sys.dba_xs_aces
 where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_ACES is
'All the Real Application Security ACES of the ACLs owned by the current user'
/

comment on column USER_XS_ACES.ACL is
'Name of the ACL'
/

comment on column USER_XS_ACES.ACE_ORDER is
'Order number of the ACE in the ACL'
/

comment on column USER_XS_ACES.START_DATE is
'Effective start date of the ACE'
/

comment on column USER_XS_ACES.END_DATE is
'Effective end date of the ACE'
/

comment on column USER_XS_ACES.GRANT_TYPE is
'Indicates whether the ACE GRANT or DENY the privileges'
/

comment on column USER_XS_ACES.INVERTED_PRINCIPAL is
'Indicates whether the principal is inverted (YES) or not (NO)'
/

comment on column USER_XS_ACES.PRINCIPAL_TYPE is
'Type of the principal'
/

comment on column USER_XS_ACES.PRIVILEGE is
'Name of the privilege'
/

comment on column USER_XS_ACES.SECURITY_CLASS is
'Name of the security class that scopes the ACL'
/

comment on column USER_XS_ACES.SECURITY_CLASS_OWNER is
'Owner of the security class that scopes the ACL'
/

create or replace public synonym USER_XS_ACES for USER_XS_ACES
/

grant read on USER_XS_ACES to public;


/******************************************************************************
                             Data Security Views
******************************************************************************/
-------------------------------------------------------------------------------
--                          DBA_XS_POLICIES
-------------------------------------------------------------------------------

create or replace view DBA_XS_POLICIES
(
  NAME,
  OWNER,
  CREATE_TIME,
  MODIFY_TIME,
  DESCRIPTION
)
as
select o.name, o.owner, d.ctime, d.mtime, d.description
  from sys.xs$dsec d, sys.xs$obj o
 where o.id = d.xdsid#
/

comment on table DBA_XS_POLICIES is
'All the Real Application Security data security policies defined in the database'
/

comment on column DBA_XS_POLICIES.NAME is
'Name of the data security policy'
/

comment on column DBA_XS_POLICIES.OWNER is
'owner of the data security policy'
/

comment on column DBA_XS_POLICIES.CREATE_TIME is
'Creation time of the data security policy'
/

comment on column DBA_XS_POLICIES.MODIFY_TIME is
'Modification time of the data security policy'
/

comment on column DBA_XS_POLICIES.DESCRIPTION is
'Description of the data security policy'
/
create or replace public synonym DBA_XS_POLICIES for DBA_XS_POLICIES
/

grant select on DBA_XS_POLICIES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_POLICIES','CDB_XS_POLICIES');
create or replace public synonym CDB_XS_POLICIES for sys.CDB_XS_POLICIES;
grant select on CDB_XS_POLICIES to select_catalog_role;

-------------------------------------------------------------------------------
--                          ALL_XS_POLICIES
-------------------------------------------------------------------------------

create or replace view ALL_XS_POLICIES
(
  NAME,
  OWNER,
  CREATE_TIME,
  MODIFY_TIME,
  DESCRIPTION
)
as
select DISTINCT o.name, o.owner, d.ctime, d.mtime, d.description
  from sys.xs$dsec d, sys.xs$obj o, sys.xs$obj o2
 where o.id = d.xdsid# and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o.owner != 'SYS') or
        o.owner = sys_context('USERENV','CURRENT_USER') or
        (o.owner=o2.owner and o2.name='XS$SCHEMA_ACL' and o2.type=3 and 
         ORA_CHECK_ACL(TO_ACLID(o2.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_POLICIES is
'All the Real Application Security data security policies accessible to the current user'
/

comment on column ALL_XS_POLICIES.NAME is
'Name of the data security policy'
/

comment on column ALL_XS_POLICIES.OWNER is
'owner of the data security policy'
/

comment on column ALL_XS_POLICIES.CREATE_TIME is
'Creation time of the data security policy'
/

comment on column ALL_XS_POLICIES.MODIFY_TIME is
'Modification time of the data security policy'
/

comment on column ALL_XS_POLICIES.DESCRIPTION is
'Description of the data security policy'
/
create or replace public synonym ALL_XS_POLICIES for ALL_XS_POLICIES
/

grant read on ALL_XS_POLICIES to public;

-------------------------------------------------------------------------------
--                          USER_XS_POLICIES
-------------------------------------------------------------------------------

create or replace view USER_XS_POLICIES
(
  NAME,
  CREATE_TIME,
  MODIFY_TIME,
  DESCRIPTION
)
as
select name, create_time, modify_time, description
  from sys.dba_xs_policies
 where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_POLICIES is
'All the Real Application Security data security policies owned by the current user'
/

comment on column USER_XS_POLICIES.NAME is
'Name of the data security policy'
/

comment on column USER_XS_POLICIES.CREATE_TIME is
'Creation time of the data security policy'
/

comment on column USER_XS_POLICIES.MODIFY_TIME is
'Modification time of the data security policy'
/

comment on column USER_XS_POLICIES.DESCRIPTION is
'Description of the data security policy'
/
create or replace public synonym USER_XS_POLICIES for USER_XS_POLICIES
/

grant read on USER_XS_POLICIES to public;

-------------------------------------------------------------------------------
--                          DBA_XS_REALM_CONSTRAINTS
-------------------------------------------------------------------------------

create or replace view DBA_XS_REALM_CONSTRAINTS
(
  POLICY,
  POLICY_OWNER,
  REALM_ORDER,
  REALM_TYPE,
  STATIC,
  REALM,
  REALM_DESCRIPTION,
  ACL,
  ACL_OWNER,
  PARENT_OBJECT,
  PARENT_SCHEMA
)
as
select o1.name, o1.owner, il.order#, 
       decode(il.type, 
              1, decode(bitand(ir.flags, 1), 0, 'REGULAR', 'PARAMETERIZED'),
              'INHERITED'),
       decode(ir.static, 1, 'STATIC ', 'DYNAMIC'),
       decode(il.type, 1, ir.rule, null),
       ir.description,
       acl.name, acl.owner, ih.parent_object, ih.parent_schema
  from sys.xs$instset_list il,
       sys.xs$instset_rule ir,
       sys.xs$instset_inh  ih,
       (select ia.xdsid#, ia.order#, o2.name, o2.owner 
          from sys.xs$instset_acl  ia, sys.xs$obj o2
         where ia.acl# = o2.id) acl,
       sys.xs$obj o1
 where il.xdsid# = ir.xdsid#(+)  and
       il.order# = ir.order#(+)  and
       il.xdsid# = acl.xdsid#(+) and
       il.order# = acl.order#(+) and
       il.xdsid# = ih.xdsid#(+)  and
       il.order# = ih.order#(+)  and
       il.xdsid# = o1.id
/

comment on table DBA_XS_REALM_CONSTRAINTS is
'All the Real Application Security realms defined in the database'
/

comment on column DBA_XS_REALM_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column DBA_XS_REALM_CONSTRAINTS.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column DBA_XS_REALM_CONSTRAINTS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column DBA_XS_REALM_CONSTRAINTS.REALM_TYPE is
'The type of the realm. Possible values are REGULAR, PARAMETERIZED, and INHERITED'
/

comment on column DBA_XS_REALM_CONSTRAINTS.STATIC is
'Indicates whether the realm is static (YES) or not (NO)'
/

comment on column DBA_XS_REALM_CONSTRAINTS.REALM is
'The realm'
/
comment on column DBA_XS_REALM_CONSTRAINTS.REALM_DESCRIPTION is
'The realm description'
/

comment on column DBA_XS_REALM_CONSTRAINTS.ACL is
'Name of the associated ACL for REGULAR realm'
/

comment on column DBA_XS_REALM_CONSTRAINTS.ACL_OWNER is
'Owner of the associated ACL for REGULAR realm'
/

comment on column DBA_XS_REALM_CONSTRAINTS.PARENT_OBJECT is
'Name of the parent object if the type of the realm is INHERITED'
/

comment on column DBA_XS_REALM_CONSTRAINTS.PARENT_SCHEMA is
'Schema of the parent object if the type of the realm is INHERITED'
/

create or replace public synonym 
DBA_XS_REALM_CONSTRAINTS for DBA_XS_REALM_CONSTRAINTS
/

grant select on DBA_XS_REALM_CONSTRAINTS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_REALM_CONSTRAINTS','CDB_XS_REALM_CONSTRAINTS');
create or replace public synonym CDB_XS_REALM_CONSTRAINTS for sys.CDB_XS_REALM_CONSTRAINTS;
grant select on CDB_XS_REALM_CONSTRAINTS to select_catalog_role;

-------------------------------------------------------------------------------
--                          ALL_XS_REALM_CONSTRAINTS
-------------------------------------------------------------------------------

create or replace view ALL_XS_REALM_CONSTRAINTS
(
  POLICY,
  POLICY_OWNER,
  REALM_ORDER,
  REALM_TYPE,
  STATIC,
  REALM,
  REALM_DESCRIPTION,
  ACL,
  ACL_OWNER,
  PARENT_OBJECT,
  PARENT_SCHEMA
)
as
select DISTINCT o1.name, o1.owner, il.order#, 
       decode(il.type, 
              1, decode(bitand(ir.flags, 1), 0, 'REGULAR', 'PARAMETERIZED'),
              'INHERITED'),
       decode(ir.static, 1, 'STATIC ', 'DYNAMIC'),
       decode(il.type, 1, ir.rule, null),
       ir.description,
       acl.name, acl.owner, ih.parent_object, ih.parent_schema
  from sys.xs$instset_list il,
       sys.xs$instset_rule ir,
       sys.xs$instset_inh  ih,
       (select ia.xdsid#, ia.order#, o2.name, o2.owner 
          from sys.xs$instset_acl  ia, sys.xs$obj o2
         where ia.acl# = o2.id) acl,
       sys.xs$obj o1, sys.xs$obj o3
 where il.xdsid# = ir.xdsid#(+)  and
       il.order# = ir.order#(+)  and
       il.xdsid# = acl.xdsid#(+) and
       il.order# = acl.order#(+) and
       il.xdsid# = ih.xdsid#(+)  and
       il.order# = ih.order#(+)  and
       il.xdsid# = o1.id         and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or
        o1.owner  = sys_context('USERENV','CURRENT_USER') or
        (o1.owner=o3.owner and o3.name='XS$SCHEMA_ACL' and o3.type=3 AND
         ORA_CHECK_ACL(TO_ACLID(o3.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_REALM_CONSTRAINTS is
'All the Real Application Security realms accessible to the current user'
/

comment on column ALL_XS_REALM_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column ALL_XS_REALM_CONSTRAINTS.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column ALL_XS_REALM_CONSTRAINTS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column ALL_XS_REALM_CONSTRAINTS.REALM_TYPE is
'The type of the realm. Possible values are REGULAR, PARAMETERIZED, and INHERITED'
/

comment on column ALL_XS_REALM_CONSTRAINTS.STATIC is
'Indicates whether the realm is static (YES) or not (NO)'
/

comment on column ALL_XS_REALM_CONSTRAINTS.REALM is
'The realm'
/
comment on column ALL_XS_REALM_CONSTRAINTS.REALM_DESCRIPTION is
'The realm description'
/

comment on column ALL_XS_REALM_CONSTRAINTS.ACL is
'Name of the associated ACL for REGULAR realm'
/

comment on column ALL_XS_REALM_CONSTRAINTS.ACL_OWNER is
'Owner of the associated ACL for REGULAR realm'
/

comment on column ALL_XS_REALM_CONSTRAINTS.PARENT_OBJECT is
'Name of the parent object if the type of the realm is INHERITED'
/

comment on column ALL_XS_REALM_CONSTRAINTS.PARENT_SCHEMA is
'Schema of the parent object if the type of the realm is INHERITED'
/

create or replace public synonym 
ALL_XS_REALM_CONSTRAINTS for ALL_XS_REALM_CONSTRAINTS
/

grant read on ALL_XS_REALM_CONSTRAINTS to public;

-------------------------------------------------------------------------------
--                          USER_XS_REALM_CONSTRAINTS
-------------------------------------------------------------------------------
create or replace view USER_XS_REALM_CONSTRAINTS
(
  POLICY,
  REALM_ORDER,
  REALM_TYPE,
  STATIC,
  REALM,
  REALM_DESCRIPTION,
  ACL,
  ACL_OWNER,
  PARENT_OBJECT,
  PARENT_SCHEMA
)
as
select policy, realm_order, realm_type, static, realm, realm_description, acl, acl_owner,
       parent_object, parent_schema
  from sys.dba_xs_realm_constraints
 where policy_owner  = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_REALM_CONSTRAINTS is
'All the Real Application Security realms owned by the current user'
/

comment on column USER_XS_REALM_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column USER_XS_REALM_CONSTRAINTS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column USER_XS_REALM_CONSTRAINTS.REALM_TYPE is
'The type of the realm. Possible values are REGULAR, PARAMETERIZED, and INHERITED'
/

comment on column USER_XS_REALM_CONSTRAINTS.STATIC is
'Indicates whether the realm is static (YES) or not (NO)'
/

comment on column USER_XS_REALM_CONSTRAINTS.REALM is
'The realm'
/

comment on column USER_XS_REALM_CONSTRAINTS.REALM_DESCRIPTION is
'The realm description'
/

comment on column USER_XS_REALM_CONSTRAINTS.ACL is
'Name of the associated ACL for REGULAR realm'
/

comment on column USER_XS_REALM_CONSTRAINTS.ACL_OWNER is
'Owner of the associated ACL for REGULAR realm'
/

comment on column USER_XS_REALM_CONSTRAINTS.PARENT_OBJECT is
'Name of the parent object if the type of the realm is INHERITED'
/

comment on column USER_XS_REALM_CONSTRAINTS.PARENT_SCHEMA is
'Schema of the parent object if the type of the realm is INHERITED'
/

create or replace public synonym 
USER_XS_REALM_CONSTRAINTS for USER_XS_REALM_CONSTRAINTS
/

grant read on USER_XS_REALM_CONSTRAINTS to public;


-------------------------------------------------------------------------------
--                      DBA_XS_INHERITED_REALMS
-------------------------------------------------------------------------------

create or replace view DBA_XS_INHERITED_REALMS
(
  POLICY,
  POLICY_OWNER,
  REALM_ORDER,
  PARENT_OBJECT,
  PARENT_SCHEMA,
  PRIMARY_KEY,
  FOREIGN_KEY,
  FOREIGN_KEY_TYPE
)
as
select o.name, o.owner, ih.order#, ih.parent_object, ih.parent_schema,
       ihk.pkey, ihk.fkey,
       decode(ihk.fkey_type, 1, 'NAME', 2, 'VALUE')
  from sys.xs$instset_inh  ih,
       sys.xs$instset_inh_key ihk,
       sys.xs$obj o
 where ih.xdsid# = ihk.xdsid#(+) and
       ih.order# = ihk.order#(+) and
       ih.xdsid# = o.id
/

comment on table DBA_XS_INHERITED_REALMS is
'All the Real Application Security inherited realms defined in the database'
/

comment on column DBA_XS_INHERITED_REALMS.POLICY is
'Name of the data security policy'
/

comment on column DBA_XS_INHERITED_REALMS.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column DBA_XS_INHERITED_REALMS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column DBA_XS_INHERITED_REALMS.PARENT_OBJECT is
'Name of the parent object'
/

comment on column DBA_XS_INHERITED_REALMS.PARENT_SCHEMA is
'Schema of the parent object'
/

comment on column DBA_XS_INHERITED_REALMS.PRIMARY_KEY is
'The column name in the master table'
/

comment on column DBA_XS_INHERITED_REALMS.FOREIGN_KEY is
'The column name or column value in the detail table'
/

comment on column DBA_XS_INHERITED_REALMS.FOREIGN_KEY_TYPE is
'Type of the foreign key. Possible values are NAME and VALUE'
/

create or replace public synonym 
DBA_XS_INHERITED_REALMS for DBA_XS_INHERITED_REALMS
/

grant select on DBA_XS_INHERITED_REALMS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_INHERITED_REALMS','CDB_XS_INHERITED_REALMS');
create or replace public synonym CDB_XS_INHERITED_REALMS for sys.CDB_XS_INHERITED_REALMS;
grant select on CDB_XS_INHERITED_REALMS to select_catalog_role;

-------------------------------------------------------------------------------
--                      ALL_XS_INHERITED_REALMS
-------------------------------------------------------------------------------

create or replace view ALL_XS_INHERITED_REALMS
(
  POLICY,
  POLICY_OWNER,
  REALM_ORDER,
  PARENT_OBJECT,
  PARENT_SCHEMA,
  PRIMARY_KEY,
  FOREIGN_KEY,
  FOREIGN_KEY_TYPE
)
as
select DISTINCT o.name, o.owner, ih.order#, ih.parent_object, ih.parent_schema,
       ihk.pkey, ihk.fkey,
       decode(ihk.fkey_type, 1, 'NAME', 2, 'VALUE')
  from sys.xs$instset_inh  ih,
       sys.xs$instset_inh_key ihk,
       sys.xs$obj o, sys.xs$obj o2
 where ih.xdsid# = ihk.xdsid#(+) and
       ih.order# = ihk.order#(+) and
       ih.xdsid# = o.id          and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o.owner != 'SYS') or
        o.owner  = sys_context('USERENV','CURRENT_USER') or
        (o.owner=o2.owner and o2.name='XS$SCHEMA_ACL' and o2.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o2.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_INHERITED_REALMS is
'All the Real Application Security inherited realms accessible to the current user'
/

comment on column ALL_XS_INHERITED_REALMS.POLICY is
'Name of the data security policy'
/

comment on column ALL_XS_INHERITED_REALMS.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column ALL_XS_INHERITED_REALMS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column ALL_XS_INHERITED_REALMS.PARENT_OBJECT is
'Name of the parent object'
/

comment on column ALL_XS_INHERITED_REALMS.PARENT_SCHEMA is
'Schema of the parent object'
/

comment on column ALL_XS_INHERITED_REALMS.PRIMARY_KEY is
'The column name in the master table'
/

comment on column ALL_XS_INHERITED_REALMS.FOREIGN_KEY is
'The column name or column value in the detail table'
/

comment on column ALL_XS_INHERITED_REALMS.FOREIGN_KEY_TYPE is
'Type of the foreign key. Possible values are NAME and VALUE'
/

create or replace public synonym 
ALL_XS_INHERITED_REALMS for ALL_XS_INHERITED_REALMS
/

grant read on ALL_XS_INHERITED_REALMS to public;

-------------------------------------------------------------------------------
--                      USER_XS_INHERITED_REALMS
-------------------------------------------------------------------------------

create or replace view USER_XS_INHERITED_REALMS
(
  POLICY,
  REALM_ORDER,
  PARENT_OBJECT,
  PARENT_SCHEMA,
  PRIMARY_KEY,
  FOREIGN_KEY,
  FOREIGN_KEY_TYPE
)
as
select policy, realm_order, parent_object, parent_schema, primary_key,
       foreign_key, foreign_key_type
  from sys.dba_xs_inherited_realms
 where policy_owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_INHERITED_REALMS is
'All the Real Application Security inherited realms owned by the current user'
/

comment on column USER_XS_INHERITED_REALMS.POLICY is
'Name of the data security policy'
/

comment on column USER_XS_INHERITED_REALMS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column USER_XS_INHERITED_REALMS.PARENT_OBJECT is
'Name of the parent object'
/

comment on column USER_XS_INHERITED_REALMS.PARENT_SCHEMA is
'Schema of the parent object'
/

comment on column USER_XS_INHERITED_REALMS.PRIMARY_KEY is
'The column name in the master table'
/

comment on column USER_XS_INHERITED_REALMS.FOREIGN_KEY is
'The column name or column value in the detail table'
/

comment on column USER_XS_INHERITED_REALMS.FOREIGN_KEY_TYPE is
'Type of the foreign key. Possible values are NAME and VALUE'
/

create or replace public synonym 
USER_XS_INHERITED_REALMS for USER_XS_INHERITED_REALMS
/

grant read on USER_XS_INHERITED_REALMS to public;


-------------------------------------------------------------------------------
--                      DBA_XS_ACL_PARAMETERS
-------------------------------------------------------------------------------

-- Type used to store the list of parameters parsed from a realm.
create or replace type xs$realm_parameter_table is table of varchar2(4000)
/

-- This function extracts all the ACL parameters used in a realm.
create or replace 
function get_realm_parameters(realm in varchar2) return xs$realm_parameter_table
as
  cnt         pls_integer;
  param       varchar2(4000);
  pattern     varchar2(129);
  rule_params xs$realm_parameter_table := xs$realm_parameter_table();
begin
  pattern := '&[[:alpha:]][[:alnum:]$#_]*';
  -- Get the list of parameters from the membership rule.
  cnt := 1;
  LOOP
    -- Find one parameter.
    param := regexp_substr(realm, pattern, 1, cnt, 'i');
    
    EXIT WHEN (param IS NULL);
    
    rule_params.extend(1);
    rule_params(cnt) := substr(param, 2);             -- Delete the symbol "&'.

    cnt := cnt + 1;
  END LOOP;
  return rule_params;
end;
/

create or replace view DBA_XS_ACL_PARAMETERS
(
  POLICY,
  POLICY_OWNER,
  ACL,
  ACL_OWNER,
  PARAMETER,
  DATATYPE,
  VALUE,
  REALM_ORDER,
  REALM
)
as
select o1.name, o1.owner,
       o2.name, o2.owner,
       ap.pname,
       decode(pp.type, 1, 'NUMBER', 2, 'VARCHAR', 3, 'DATE', 4, 'TIMESTAMP'),
       decode(pp.type, 1, to_char(ap.pvalue1), ap.pvalue2),
	   apir.order#, apir.rule
  from sys.xs$policy_param pp, sys.xs$acl_param ap,
       sys.xs$obj o1, sys.xs$obj o2,
       (select ap.xdsid#, ap.acl#, ap.pname, ir.order#, ir.rule
       	   from sys.xs$acl_param ap, sys.xs$instset_rule ir
          where ap.xdsid# = ir.xdsid# and bitand(ir.flags, 1) = 1 and
        	ap.pname in
       		(select * from table(sys.get_realm_parameters(ir.rule)))) apir
  where pp.xdsid# = ap.xdsid#(+) and
	pp.pname = ap.pname(+) and
       	o1.id = pp.xdsid# and
       	ap.acl# = o2.id(+) and
       	ap.xdsid# = apir.xdsid#(+) and
       	ap.acl# = apir.acl#(+) and
       	ap.pname = apir.pname(+)
/

comment on table DBA_XS_ACL_PARAMETERS is
'All the Real Application Security ACL parameters defined in the database'
/

comment on column DBA_XS_ACL_PARAMETERS.POLICY is
'Name of the data security policy where the ACL parameter is defined'
/

comment on column DBA_XS_ACL_PARAMETERS.POLICY_OWNER is
'Owner of the data security policy where the ACL parameter is defined'
/

comment on column DBA_XS_ACL_PARAMETERS.ACL is
'Name of the ACL'
/

comment on column DBA_XS_ACL_PARAMETERS.ACL_OWNER is
'Owner of the ACL'
/

comment on column DBA_XS_ACL_PARAMETERS.PARAMETER is
'Name of the ACL parameter'
/

comment on column DBA_XS_ACL_PARAMETERS.DATATYPE is
'Datatype of the ACL parameter'
/

comment on column DBA_XS_ACL_PARAMETERS.VALUE is
'Value of the ACL parameter'
/

comment on column DBA_XS_ACL_PARAMETERS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column DBA_XS_ACL_PARAMETERS.REALM is
'The realm that contains the ACL parameter'
/

create or replace public synonym 
DBA_XS_ACL_PARAMETERS for DBA_XS_ACL_PARAMETERS
/

grant select on DBA_XS_ACL_PARAMETERS to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ACL_PARAMETERS','CDB_XS_ACL_PARAMETERS');
create or replace public synonym CDB_XS_ACL_PARAMETERS for sys.CDB_XS_ACL_PARAMETERS;
grant select on CDB_XS_ACL_PARAMETERS to select_catalog_role;

create or replace view ALL_XS_ACL_PARAMETERS
(
  POLICY,
  POLICY_OWNER,
  ACL,
  ACL_OWNER,
  PARAMETER,
  DATATYPE,
  VALUE,
  REALM_ORDER,
  REALM
)
as
select DISTINCT o1.name, o1.owner,
       o2.name, o2.owner,
       ap.pname, 
       decode(pp.type, 1, 'NUMBER', 2, 'VARCHAR', 3, 'DATE', 4, 'TIMESTAMP'),
       decode(pp.type, 1, to_char(ap.pvalue1), ap.pvalue2),
       apir.order#, apir.rule
  from sys.xs$acl_param ap, sys.xs$policy_param pp,
       sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3,
       (select ap.xdsid#, ap.acl#, ap.pname, ir.order#, ir.rule
          from sys.xs$acl_param ap, sys.xs$instset_rule ir
         where ap.xdsid# = ir.xdsid# and bitand(ir.flags, 1) = 1 and
               ap.pname in 
               (select * from table(sys.get_realm_parameters(ir.rule)))) apir
 where o1.id = ap.xdsid# and o2.id = ap.acl# and 
       ap.xdsid# = apir.xdsid#(+) and
       ap.acl# = apir.acl#(+) and
       ap.pname = apir.pname(+) and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or
        o1.owner  = sys_context('USERENV','CURRENT_USER') or
        (o1.owner=o3.owner and o3.name='XS$SCHEMA_ACL' and o3.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o3.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_ACL_PARAMETERS is
'All the Real Application Security ACL parameters defined in the data security policies accessbile to the current user'
/

comment on column ALL_XS_ACL_PARAMETERS.POLICY is
'Name of the data security policy where the ACL parameter is defined'
/

comment on column ALL_XS_ACL_PARAMETERS.POLICY_OWNER is
'Owner of the data security policy where the ACL parameter is defined'
/

comment on column ALL_XS_ACL_PARAMETERS.ACL is
'Name of the ACL'
/

comment on column ALL_XS_ACL_PARAMETERS.ACL_OWNER is
'Owner of the ACL'
/

comment on column ALL_XS_ACL_PARAMETERS.PARAMETER is
'Name of the ACL parameter'
/

comment on column ALL_XS_ACL_PARAMETERS.DATATYPE is
'Datatype of the ACL parameter'
/

comment on column ALL_XS_ACL_PARAMETERS.VALUE is
'Value of the ACL parameter'
/

comment on column ALL_XS_ACL_PARAMETERS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column ALL_XS_ACL_PARAMETERS.REALM is
'The realm that contains the ACL parameter'
/

create or replace public synonym 
ALL_XS_ACL_PARAMETERS for ALL_XS_ACL_PARAMETERS
/

grant read on ALL_XS_ACL_PARAMETERS to public;

-------------------------------------------------------------------------------
--                      USER_XS_ACL_PARAMETERS
-------------------------------------------------------------------------------
create or replace view USER_XS_ACL_PARAMETERS
(
  POLICY,
  ACL,
  ACL_OWNER,
  PARAMETER,
  DATATYPE,
  VALUE,
  REALM_ORDER,
  REALM
)
as
select policy, acl, acl_owner, parameter, datatype, value, realm_order, realm
  from sys.dba_xs_acl_parameters
 where policy_owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_ACL_PARAMETERS is
'All the Real Application Security ACL parameters defined in the data security policies owned by the current user'
/

comment on column USER_XS_ACL_PARAMETERS.POLICY is
'Name of the data security policy where the ACL parameter is defined'
/

comment on column USER_XS_ACL_PARAMETERS.ACL is
'Name of the ACL'
/

comment on column USER_XS_ACL_PARAMETERS.ACL_OWNER is
'Owner of the ACL'
/

comment on column USER_XS_ACL_PARAMETERS.PARAMETER is
'Name of the ACL parameter'
/

comment on column USER_XS_ACL_PARAMETERS.DATATYPE is
'Datatype of the ACL parameter'
/

comment on column USER_XS_ACL_PARAMETERS.VALUE is
'Value of the ACL parameter'
/

comment on column USER_XS_ACL_PARAMETERS.REALM_ORDER is
'The order of the realm within the data security policy'
/

comment on column USER_XS_ACL_PARAMETERS.REALM is
'The realm that contains the ACL parameter'
/

create or replace public synonym 
USER_XS_ACL_PARAMETERS for USER_XS_ACL_PARAMETERS
/

grant read on USER_XS_ACL_PARAMETERS to public;

-------------------------------------------------------------------------------
--                          DBA_XS_COLUMN_CONSTRAINTS
-------------------------------------------------------------------------------

create or replace view DBA_XS_COLUMN_CONSTRAINTS
(
  POLICY,
  OWNER,
  COLUMN_NAME,
  PRIVILEGE
)
as
select o1.name, o1.owner, c.attr_name, o2.name
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$attr_sec c
 where o1.id = c.xdsid# and o2.id = c.priv#
 order by o1.name, c.attr_name
/

comment on table DBA_XS_COLUMN_CONSTRAINTS is
'All the Real Application Security column constraints defined in the database'
/

comment on column DBA_XS_COLUMN_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column DBA_XS_COLUMN_CONSTRAINTS.OWNER is
'Owner of the data security policy'
/

comment on column DBA_XS_COLUMN_CONSTRAINTS.COLUMN_NAME is
'Name of the column that the column constraint is enforced'
/

comment on column DBA_XS_COLUMN_CONSTRAINTS.PRIVILEGE is
'Name of the privilege required to access the column'
/

create or replace public synonym 
DBA_XS_COLUMN_CONSTRAINTS for DBA_XS_COLUMN_CONSTRAINTS
/

grant select on DBA_XS_COLUMN_CONSTRAINTS to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_COLUMN_CONSTRAINTS','CDB_XS_COLUMN_CONSTRAINTS');
create or replace public synonym CDB_XS_COLUMN_CONSTRAINTS for sys.CDB_XS_COLUMN_CONSTRAINTS;
grant select on CDB_XS_COLUMN_CONSTRAINTS to select_catalog_role;

-------------------------------------------------------------------------------
--                          ALL_XS_COLUMN_CONSTRAINTS
-------------------------------------------------------------------------------

create or replace view ALL_XS_COLUMN_CONSTRAINTS
(
  POLICY,
  OWNER,
  COLUMN_NAME,
  PRIVILEGE
)
as
select DISTINCT o1.name, o1.owner, c.attr_name, o2.name
  from sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3, sys.xs$attr_sec c
 where o1.id = c.xdsid# and o2.id = c.priv# and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and o1.owner != 'SYS') or
        o1.owner  = sys_context('USERENV','CURRENT_USER') or
        (o1.owner=o3.owner and o3.name='XS$SCHEMA_ACL' and o3.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o3.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1))
 order by o1.name, c.attr_name
/

comment on table ALL_XS_COLUMN_CONSTRAINTS is
'All the Real Application Security column constraints accessible to the current user'
/

comment on column ALL_XS_COLUMN_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column ALL_XS_COLUMN_CONSTRAINTS.OWNER is
'Owner of the data security policy'
/

comment on column ALL_XS_COLUMN_CONSTRAINTS.COLUMN_NAME is
'Name of the column that the column constraint is enforced'
/

comment on column ALL_XS_COLUMN_CONSTRAINTS.PRIVILEGE is
'Name of the privilege required to access the column'
/

create or replace public synonym 
ALL_XS_COLUMN_CONSTRAINTS for ALL_XS_COLUMN_CONSTRAINTS
/

grant read on ALL_XS_COLUMN_CONSTRAINTS to public;

-------------------------------------------------------------------------------
--                          USER_XS_COLUMN_CONSTRAINTS
-------------------------------------------------------------------------------

create or replace view USER_XS_COLUMN_CONSTRAINTS
(
  POLICY,
  COLUMN_NAME,
  PRIVILEGE
)
as
select policy, column_name, privilege
  from sys.dba_xs_column_constraints
 where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_XS_COLUMN_CONSTRAINTS is
'All the Real Application Security column constraints owned by the current user'
/

comment on column USER_XS_COLUMN_CONSTRAINTS.POLICY is
'Name of the data security policy'
/

comment on column USER_XS_COLUMN_CONSTRAINTS.COLUMN_NAME is
'Name of the column that the column constraint is enforced'
/

comment on column USER_XS_COLUMN_CONSTRAINTS.PRIVILEGE is
'Name of the privilege required to access the column'
/

create or replace public synonym 
USER_XS_COLUMN_CONSTRAINTS for USER_XS_COLUMN_CONSTRAINTS
/

grant read on USER_XS_COLUMN_CONSTRAINTS to public;

-------------------------------------------------------------------------------
--                          DBA_XS_APPLIED_POLICIES
-------------------------------------------------------------------------------
create or replace view DBA_XS_APPLIED_POLICIES
( 
  SCHEMA,
  OBJECT,
  POLICY,
  POLICY_OWNER,
  SEL,
  INS,
  UPD,
  DEL,
  IDX,
  ROW_ACL,
  OWNER_BYPASS,
  STATUS
)
as
select u.name, o.name, r.pname, r.pfschma,
       decode(bitand(r.stmt_type,1), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,4), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,8), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2048), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,16384), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2097152), 0, 'NO', 'YES'),
       decode(r.enable_flag, 0, 'DISABLED', 'ENABLED')
  from sys.user$ u, sys.obj$ o, sys.rls$ r
 where u.user# = o.owner# and r.obj# = o.obj# and 
       r.gname = 'SYS_XDS$POLICY_GROUP';
/

comment on table DBA_XS_APPLIED_POLICIES is
'All the database objects on which Real Application Security data security policies are enabled'
/

comment on column DBA_XS_APPLIED_POLICIES.SCHEMA is
'Schema of the object'
/

comment on column DBA_XS_APPLIED_POLICIES.OBJECT is
'Name of the object'
/

comment on column DBA_XS_APPLIED_POLICIES.POLICY is
'Name of the data security policy'
/

comment on column DBA_XS_APPLIED_POLICIES.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column DBA_XS_APPLIED_POLICIES.SEL is
'Policy enabled for SELECT statements'
/

comment on column DBA_XS_APPLIED_POLICIES.INS is
'Policy enabled for INSERT statements'
/

comment on column DBA_XS_APPLIED_POLICIES.UPD is
'Policy enabled for UPDATE statements'
/

comment on column DBA_XS_APPLIED_POLICIES.DEL is
'Policy enabled for DELETE statements'
/

comment on column DBA_XS_APPLIED_POLICIES.IDX is
'Policy enabled for INDEX statements'
/

comment on column DBA_XS_APPLIED_POLICIES.ROW_ACL is
'Object has row ACL column'
/

comment on column DBA_XS_APPLIED_POLICIES.OWNER_BYPASS is
'Policy bypassed by object owner'
/

comment on column DBA_XS_APPLIED_POLICIES.STATUS is
'Indicates whether the data security policy is enabled or disabled'
/

create or replace public synonym 
DBA_XS_APPLIED_POLICIES for DBA_XS_APPLIED_POLICIES
/

grant select on DBA_XS_APPLIED_POLICIES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_APPLIED_POLICIES','CDB_XS_APPLIED_POLICIES');
create or replace public synonym CDB_XS_APPLIED_POLICIES for sys.CDB_XS_APPLIED_POLICIES;
grant select on CDB_XS_APPLIED_POLICIES to select_catalog_role;

-------------------------------------------------------------------------------
--                          ALL_XS_APPLIED_POLICIES
-------------------------------------------------------------------------------
create or replace view ALL_XS_APPLIED_POLICIES
( 
  SCHEMA,
  OBJECT,
  POLICY,
  POLICY_OWNER,
  SEL,
  INS,
  UPD,
  DEL,
  IDX,
  ROW_ACL,
  OWNER_BYPASS,
  STATUS
)
as
select DISTINCT u.name, o.name, r.pname, r.pfschma,
       decode(bitand(r.stmt_type,1), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,4), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,8), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2048), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,16384), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2097152), 0, 'NO', 'YES'),
       decode(r.enable_flag, 0, 'DISABLED', 'ENABLED')
  from sys.user$ u, sys.obj$ o, sys.xs$obj o2, sys.rls$ r
 where u.user# = o.owner# and r.obj# = o.obj# and 
       r.gname = 'SYS_XDS$POLICY_GROUP' and
       ((ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 and r.pfschma != 'SYS') 
        or
        r.pfschma = sys_context('USERENV','CURRENT_USER') or
        (r.pfschma=o2.owner and o2.name='XS$SCHEMA_ACL' and o2.type=3 and
         ORA_CHECK_ACL(TO_ACLID(o2.owner||'.XS$SCHEMA_ACL'), 
                       'ADMIN_SEC_POLICY')=1));
/

comment on table ALL_XS_APPLIED_POLICIES is
'All the database objects on which Real Application Security data security policies accessible to the current user are enabled'
/

comment on column ALL_XS_APPLIED_POLICIES.SCHEMA is
'Schema of the object'
/

comment on column ALL_XS_APPLIED_POLICIES.OBJECT is
'Name of the object'
/

comment on column ALL_XS_APPLIED_POLICIES.POLICY is
'Name of the data security policy'
/

comment on column ALL_XS_APPLIED_POLICIES.POLICY_OWNER is
'Owner of the data security policy'
/

comment on column ALL_XS_APPLIED_POLICIES.SEL is
'Policy enabled for SELECT statements'
/

comment on column ALL_XS_APPLIED_POLICIES.INS is
'Policy enabled for INSERT statements'
/

comment on column ALL_XS_APPLIED_POLICIES.UPD is
'Policy enabled for UPDATE statements'
/

comment on column ALL_XS_APPLIED_POLICIES.DEL is
'Policy enabled for DELETE statements'
/

comment on column ALL_XS_APPLIED_POLICIES.IDX is
'Policy enabled for INDEX statements'
/

comment on column ALL_XS_APPLIED_POLICIES.ROW_ACL is
'Object has row ACL column'
/

comment on column ALL_XS_APPLIED_POLICIES.OWNER_BYPASS is
'Policy bypassed by object owner'
/

comment on column ALL_XS_APPLIED_POLICIES.STATUS is
'Indicates whether the data security policy is enabled or disabled'
/

create or replace public synonym 
ALL_XS_APPLIED_POLICIES for ALL_XS_APPLIED_POLICIES
/

grant read on ALL_XS_APPLIED_POLICIES to public;

-------------------------------------------------------------------------------
--                          DBA_XS_MODIFIED_POLICIES
-------------------------------------------------------------------------------
create or replace view DBA_XS_MODIFIED_POLICIES
(
  POLICY,
  OBJECT
)
as
select r.pname, o2.name
from sys.rls$ r, sys.xs$dsec d, sys.xs$obj o1, sys.obj$ o2
where r.ora_rowscn < d.ora_rowscn and 
      d.xdsid# = o1.id and
      o1.name = r.pname and 
      o2.obj# = r.obj#; 
/

comment on table DBA_XS_MODIFIED_POLICIES is
'All Triton policies that were modified after being applied on one or more objects'
/

comment on column DBA_XS_MODIFIED_POLICIES.POLICY is
'Name of the data security policy'
/

comment on column DBA_XS_MODIFIED_POLICIES.OBJECT is
'Name of the object'
/

grant select on DBA_XS_MODIFIED_POLICIES to select_catalog_role;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_MODIFIED_POLICIES','CDB_XS_MODIFIED_POLICIES');
create or replace public synonym CDB_XS_MODIFIED_POLICIES for sys.CDB_XS_MODIFIED_POLICIES;
grant select on CDB_XS_MODIFIED_POLICIES to select_catalog_role;

/******************************************************************************
                                Session Views
******************************************************************************/
-------------------------------------------------------------------------------
--                            DBA_XS_SESSIONS
-------------------------------------------------------------------------------

create or replace view DBA_XS_SESSIONS 
(
  USER_NAME,
  SESSIONID,
  PROXY_USER,
  COOKIE,
  CREATE_TIME,
  AUTH_TIME,
  ACCESS_TIME,
  INACTIVE_TIMEOUT
)
as
select s.username, s.sid, o.name, s.cookie, s.createtime, s.authtime, 
       s.accesstime, s.inactivetimeout
  from sys.rxs$sessions s, sys.xs$obj o
 where s.proxyid = o.id(+)
  with read only
/

comment on table DBA_XS_SESSIONS is
'All the application sessions in the database'
/

comment on column DBA_XS_SESSIONS.USER_NAME is
'User name of the application session'
/

comment on column DBA_XS_SESSIONS.SESSIONID is
'Application session ID'
/

comment on column DBA_XS_SESSIONS.PROXY_USER is
'Name of the proxy user'
/

comment on column DBA_XS_SESSIONS.COOKIE is
'Cookie associated with the application session'
/

comment on column DBA_XS_SESSIONS.CREATE_TIME is
'Creation time of the application session'
/

comment on column DBA_XS_SESSIONS.AUTH_TIME is
'The most recent authentication time of the application session'
/

comment on column DBA_XS_SESSIONS.ACCESS_TIME is
'The most recent access time of the application session'
/

comment on column DBA_XS_SESSIONS.INACTIVE_TIMEOUT is
'Application session inactivity timeout'
/

create or replace public synonym DBA_XS_SESSIONS for DBA_XS_SESSIONS
/

grant select on DBA_XS_SESSIONS to dba;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_SESSIONS','CDB_XS_SESSIONS');
create or replace public synonym CDB_XS_SESSIONS for sys.CDB_XS_SESSIONS;
grant select on CDB_XS_SESSIONS to dba;

-------------------------------------------------------------------------------
--                            DBA_XS_ACTIVE_SESSIONS
-------------------------------------------------------------------------------

create or replace view DBA_XS_ACTIVE_SESSIONS 
(
  USER_NAME,
  SESSIONID,
  DATABASE_SESSIONID,
  PROXY_USER,
  COOKIE,
  CREATE_TIME,
  AUTH_TIME,
  ACCESS_TIME,
  INACTIVE_TIMEOUT
)
as
select s.username, s.sid, v.db_sid, o.name, s.cookie, s.createtime, s.authtime, 
       s.accesstime, s.inactivetimeout
  from sys.rxs$sessions s, sys.xs$obj o, sys.v$xs_sessions v
 where o.id(+) = s.proxyid and s.sid = v.sid
  with read only;
/

comment on table DBA_XS_ACTIVE_SESSIONS is
'All the attached application sessions in the database'
/

comment on column DBA_XS_ACTIVE_SESSIONS.USER_NAME is
'User name of the application session'
/

comment on column DBA_XS_ACTIVE_SESSIONS.SESSIONID is
'Application session ID'
/

comment on column DBA_XS_ACTIVE_SESSIONS.DATABASE_SESSIONID  is
'ID of the database sesssion that the application session is attached to'
/

comment on column DBA_XS_ACTIVE_SESSIONS.PROXY_USER is
'Name of the proxy user'
/

comment on column DBA_XS_ACTIVE_SESSIONS.COOKIE is
'Cookie associated with the application session'
/

comment on column DBA_XS_ACTIVE_SESSIONS.CREATE_TIME is
'Creation time of the application session'
/

comment on column DBA_XS_ACTIVE_SESSIONS.AUTH_TIME is
'The most recent authentication time of the application session'
/

comment on column DBA_XS_ACTIVE_SESSIONS.ACCESS_TIME is
'The most recent access time of the application session'
/

comment on column DBA_XS_ACTIVE_SESSIONS.INACTIVE_TIMEOUT is
'Application session inactivity timeout'
/

create or replace public synonym 
DBA_XS_ACTIVE_SESSIONS for DBA_XS_ACTIVE_SESSIONS
/

grant select on DBA_XS_ACTIVE_SESSIONS to dba;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ACTIVE_SESSIONS','CDB_XS_ACTIVE_SESSIONS');
create or replace public synonym CDB_XS_ACTIVE_SESSIONS for sys.CDB_XS_ACTIVE_SESSIONS;
grant select on CDB_XS_ACTIVE_SESSIONS to dba;

-------------------------------------------------------------------------------
--                        DBA_XS_SESSION_ROLES
-------------------------------------------------------------------------------

create or replace view DBA_XS_SESSION_ROLES
(
  SESSIONID, 
  ROLE
) 
as
  select sid, rolename
    from sys.rxs$session_roles 
   where bitand(roleflags,1) = 1 with read only
/

comment on table DBA_XS_SESSION_ROLES is
'Roles enabled in application sessions'
/

comment on column DBA_XS_SESSION_ROLES.SESSIONID is
'Application session ID'
/

comment on column DBA_XS_SESSION_ROLES.ROLE is
'Name of the role'
/

create or replace public synonym DBA_XS_SESSION_ROLES for DBA_XS_SESSION_ROLES
/

grant select on DBA_XS_SESSION_ROLES to dba;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_SESSION_ROLES','CDB_XS_SESSION_ROLES');
create or replace public synonym CDB_XS_SESSION_ROLES for sys.CDB_XS_SESSION_ROLES;
grant select on CDB_XS_SESSION_ROLES to dba;

-------------------------------------------------------------------------------
--                      DBA_XS_SESSION_NS_ATTRIBUTES
-------------------------------------------------------------------------------

create or replace view DBA_XS_SESSION_NS_ATTRIBUTES
(
  SESSIONID, 
  ATTRIBUTE,
  NAMESPACE,
  VALUE,
  DEFAULT_VALUE,
  FIRSTREAD_EVENT,
  MODIFY_EVENT
)
as
select sid, attrname, nsname, attrvalue, attr_default_value,
       decode(bitand(flags, 1),'YES', 'NO'), 
       decode(bitand(flags, 2),'YES', 'NO')
  from sys.rxs$session_appns with read only
/

comment on table DBA_XS_SESSION_NS_ATTRIBUTES is
'Namespace attributes in application sessions as of the last saved state'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.SESSIONID is
'Application session ID'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.ATTRIBUTE is
'Name of the attribute'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.NAMESPACE is
'Name of the namespace'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.VALUE is
'Value of the attribute'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.DEFAULT_VALUE is
'Default value of the attribute'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.FIRSTREAD_EVENT is
'Indicates whether the handler function will be invoked at the first time of reading the attribute (YES) or not (NO)'
/

comment on column DBA_XS_SESSION_NS_ATTRIBUTES.MODIFY_EVENT is
'Indicates whether the handler function will be invoked at the time of modifying the attribute (YES) or not (NO)'
/

create or replace public synonym DBA_XS_SESSION_NS_ATTRIBUTES
for DBA_XS_SESSION_NS_ATTRIBUTES
/

grant select on DBA_XS_SESSION_NS_ATTRIBUTES to dba;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_SESSION_NS_ATTRIBUTES','CDB_XS_SESSION_NS_ATTRIBUTES');
create or replace public synonym CDB_XS_SESSION_NS_ATTRIBUTES for sys.CDB_XS_SESSION_NS_ATTRIBUTES;
grant select on CDB_XS_SESSION_NS_ATTRIBUTES to dba;

/******************************************************************************
                                Audit Views
******************************************************************************/
-------------------------------------------------------------------------------
--                      DBA_XS_AUDIT_POLICY_OPTIONS
-------------------------------------------------------------------------------

create or replace view DBA_XS_AUDIT_POLICY_OPTIONS
(
  POLICY_NAME,
  AUDIT_CONDITION,
  AUDIT_OPTION,
  CONDITION_EVAL_OPT,
  COMMON
)
as
select policy_name, audit_condition, audit_option, condition_eval_opt, common
  from sys.audit_unified_policies
 where audit_option_type='XS ACTION'
/

comment on table DBA_XS_AUDIT_POLICY_OPTIONS is
'Describes auditing options defined under all XS security specific 
audit policies'
/

comment on column DBA_XS_AUDIT_POLICY_OPTIONS.POLICY_NAME is
'Name of the Audit policy'
/

comment on column DBA_XS_AUDIT_POLICY_OPTIONS.AUDIT_CONDITION is
'Condition associated with the Audit policy'
/

comment on column DBA_XS_AUDIT_POLICY_OPTIONS.AUDIT_OPTION is
'Auditing option defined in the Audit policy'
/

comment on column DBA_XS_AUDIT_POLICY_OPTIONS.CONDITION_EVAL_OPT is
'Evaluation option associated with the Audit policy''s Condition.
 The possible values are STATEMENT, SESSION, INSTANCE, NONE'
/

comment on column DBA_XS_AUDIT_POLICY_OPTIONS.COMMON is
'Whether the audit policy is a Common Audit Policy or Local. It is NULL 
in case of nonconsolidated databases'
/

create or replace public synonym DBA_XS_AUDIT_POLICY_OPTIONS for 
DBA_XS_AUDIT_POLICY_OPTIONS
/

grant read on DBA_XS_AUDIT_POLICY_OPTIONS to AUDIT_ADMIN;
grant read on DBA_XS_AUDIT_POLICY_OPTIONS to AUDIT_VIEWER;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_AUDIT_POLICY_OPTIONS','CDB_XS_AUDIT_POLICY_OPTIONS');
create or replace public synonym CDB_XS_AUDIT_POLICY_OPTIONS for sys.CDB_XS_AUDIT_POLICY_OPTIONS;
grant read on CDB_XS_AUDIT_POLICY_OPTIONS to AUDIT_ADMIN;
grant read on CDB_XS_AUDIT_POLICY_OPTIONS to AUDIT_VIEWER;
-------------------------------------------------------------------------------
--                     DBA_XS_ENABLED_AUDIT_POLICIES
-------------------------------------------------------------------------------

create or replace view DBA_XS_ENABLED_AUDIT_POLICIES
(
  USER_NAME,
  POLICY_NAME,
  ENABLED_OPT,
  ENABLED_OPTION,
  ENTITY_NAME,
  ENTITY_TYPE,
  SUCCESS,
  FAILURE
)
as
select enb_pol.user_name, enb_pol.policy_name, enb_pol.enabled_opt, 
       enb_pol.enabled_option, enb_pol.entity_name, enb_pol.entity_type,
       enb_pol.success, enb_pol.failure 
  from sys.audit_unified_enabled_policies enb_pol, 
       sys.audit_unified_policies pol
 where enb_pol.policy_name = pol.policy_name and
       pol.audit_option_type='XS ACTION'
/

comment on table DBA_XS_ENABLED_AUDIT_POLICIES is
'Describes all XS related audit policy''s enablement to users'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.USER_NAME is
'Deprecated - Use ENTITY_NAME column instead'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.POLICY_NAME is
'Name of the Audit policy'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.ENABLED_OPT is
'Deprecated - Use ENABLED_OPTION column instead'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.ENABLED_OPTION is
'Enabled option of the Audit policy. The possible values are BY USER, 
 EXCEPT USER, BY GRANTED ROLE, INVALID'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.ENTITY_NAME is
'Database entity on which the Audit policy is enabled'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.ENTITY_TYPE is
'Database entity type - User or Role'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.SUCCESS is
'Is the Audit policy enabled for auditing successful events. The possible
values are YES or NO'
/

comment on column DBA_XS_ENABLED_AUDIT_POLICIES.FAILURE is
'Is the Audit policy enabled for auditing unsuccessful events.The possible 
values are YES or NO'
/

create or replace public synonym DBA_XS_ENB_AUDIT_POLICIES for 
DBA_XS_ENABLED_AUDIT_POLICIES
/

create or replace public synonym DBA_XS_ENABLED_AUDIT_POLICIES for 
DBA_XS_ENABLED_AUDIT_POLICIES
/

grant read on DBA_XS_ENABLED_AUDIT_POLICIES to AUDIT_ADMIN;
grant read on DBA_XS_ENABLED_AUDIT_POLICIES to AUDIT_VIEWER;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_ENABLED_AUDIT_POLICIES','CDB_XS_ENABLED_AUDIT_POLICIES');
create or replace public synonym CDB_XS_ENB_AUDIT_POLICIES for sys.CDB_XS_ENABLED_AUDIT_POLICIES;
create or replace public synonym CDB_XS_ENABLED_AUDIT_POLICIES for sys.CDB_XS_ENABLED_AUDIT_POLICIES;
grant read on CDB_XS_ENABLED_AUDIT_POLICIES to AUDIT_ADMIN;
grant read on CDB_XS_ENABLED_AUDIT_POLICIES to AUDIT_VIEWER;

-------------------------------------------------------------------------------
--                          DBA_XS_PRIVILEGE_GRANTS
-------------------------------------------------------------------------------

create or replace view DBA_XS_PRIVILEGE_GRANTS
(
  PRIVILEGE,
  GRANTEE,
  GRANTEE_TYPE,
  SCHEMA
)
as
select privilege, principal, principal_type,
  decode(acl, 'XS$SCHEMA_ACL', owner, NULL)
  from DBA_XS_ACES
 where privilege in ('ADMIN_ANY_SEC_POLICY', 'ADMIN_SEC_POLICY', 'APPLY_SEC_POLICY');
/

comment on table DBA_XS_PRIVILEGE_GRANTS is
'All the Real Application Security system or schema level privilege grants in the database'
/

comment on column DBA_XS_PRIVILEGE_GRANTS.PRIVILEGE is
'Name of the privilege'
/

comment on column DBA_XS_PRIVILEGE_GRANTS.GRANTEE is
'Name of the user to whom access was granted'
/

comment on column DBA_XS_PRIVILEGE_GRANTS.GRANTEE_TYPE is
'Type of the grantee. Possible values are DB or XS'
/

comment on column DBA_XS_PRIVILEGE_GRANTS.SCHEMA is
'Schema of the privilege'
/

create or replace public synonym 
DBA_XS_PRIVILEGE_GRANTS for DBA_XS_COLUMN_CONSTRAINTS
/

grant select on DBA_XS_PRIVILEGE_GRANTS to select_catalog_role;


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_XS_PRIVILEGE_GRANTS','CDB_XS_PRIVILEGE_GRANTS');
create or replace public synonym CDB_XS_PRIVILEGE_GRANTS for sys.CDB_XS_PRIVILEGE_GRANTS;
grant select on CDB_XS_PRIVILEGE_GRANTS to select_catalog_role;

-------------------------------------------------------------------------------
--                          ALL_XS_APPLICABLE_OBJECTS
-------------------------------------------------------------------------------

create or replace view ALL_XS_APPLICABLE_OBJECTS
(
  OWNER,
  OBJECT_NAME,
  TYPE
)
as
select OWNER, TABLE_NAME, 'TABLE'
  from sys.DBA_TABLES
 where /* User has ADMIN_ANY_SEC_POLICY or APPLY_SEC_POLICY on itself */
       ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1 or
       ORA_CHECK_PRIVILEGE('APPLY_SEC_POLICY')=1
union
select t.OWNER, TABLE_NAME, 'TABLE'
  from sys.DBA_TABLES t, sys.xs$obj o
 where /* User has APPLY_SEC_POLICY on table schema */
       t.owner=o.owner and o.name='XS$SCHEMA_ACL' and o.type=3 and 
       ORA_CHECK_ACL(TO_ACLID(o.owner||'.XS$SCHEMA_ACL'),'APPLY_SEC_POLICY')=1
union
select OWNER, VIEW_NAME, 'VIEW'
  from sys.DBA_VIEWS
 where ORA_CHECK_PRIVILEGE('ADMIN_ANY_SEC_POLICY')=1
union
select v.OWNER, VIEW_NAME, 'VIEW'
  from sys.DBA_VIEWS v, sys.xs$obj o 
 where v.owner=o.owner and o.name='XS$SCHEMA_ACL' and o.type=3 and 
       ORA_CHECK_ACL(TO_ACLID(o.owner||'.XS$SCHEMA_ACL'),'APPLY_SEC_POLICY')=1;
/

comment on table ALL_XS_APPLICABLE_OBJECTS is
'All the tables or views to which the current user can apply data security policies'
/

comment on column ALL_XS_APPLICABLE_OBJECTS.OWNER is
'Owner of the object'
/

comment on column ALL_XS_APPLICABLE_OBJECTS.OBJECT_NAME is
'Name of the object'
/

comment on column ALL_XS_APPLICABLE_OBJECTS.TYPE is
'Type of the object'
/

create or replace public synonym ALL_XS_APPLICABLE_OBJECTS for ALL_XS_APPLICABLE_OBJECTS
/

grant read on ALL_XS_APPLICABLE_OBJECTS to public;

@?/rdbms/admin/sqlsessend.sql
