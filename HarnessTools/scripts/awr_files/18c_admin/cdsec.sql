Rem
Rem $Header: rdbms/admin/cdsec.sql /main/29 2017/02/16 22:41:34 rthatte Exp $
Rem
Rem cdsec.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdsec.sql - Catalog DSEC.bsq views
Rem
Rem    DESCRIPTION
Rem      Privilege objects
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in dsec.bsq.  
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdsec.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdsec.sql
Rem SQL_PHASE: CDSEC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rthatte     01/19/17 - Bug 23753068: Reduce privileges to AUDIT_ADMIN
Rem    yohu        07/18/16 - Project 62656: Direct integration with generic 
Rem                           directory services
Rem    sumkumar    06/08/16 - Bug 23550113: define DBA_ROLES.ROLE_ID
Rem    akruglik    11/16/15 - (21193922): App Common users/roles/rpofiles will
Rem    akruglik    11/16/15 - (21193922): App Common users/roles/profiles will
Rem                           have both COMMON and APP_COMMON bits set
Rem    juilin      22/07/15 - Bug 21458522 rename syscontext IS_FEDERATION_PDB
Rem    sumkumar    09/11/15 - Bug 21839718: define DBA_ROLES.IMPLICIT
Rem    akruglik    06/30/15 - Get rid of scope column
Rem    akruglik    06/15/15 - get rid of COMMON column in session_roles/privs
Rem    akruglik    04/20/15 - move to deprecate COMMON column in session_roles
Rem                           and session_privs
Rem    skayoor     12/09/14 - Bug 20203506: Use ora_check_sys_privilege
Rem    skayoor     11/30/14 - Bug 15989804: Display common privilege info
Rem    akruglik    11/05/14 - Project 47234: add DBA_ROLES.SCOPE
Rem    skayoor     09/12/14 - Bug 15989804: Display common privilege info
Rem    skayoor     09/11/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - Bug 17795079: grant READ ANY TABLE to sys with
Rem                           admin option
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    pyam        02/06/13 - add ORACLE_MAINTAINED column
Rem    talliu      01/16/13 - Modify comments for common colume
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    surman      11/14/12 - 12876907: Add ORACLE_SCRIPT
Rem    pknaggs     08/09/12 - Bug #14479124: fix DBA_ROLES for Exclusive Mode.
Rem    youyang     04/19/12 - lrg6926898:grant sys privileges with admin option
Rem    jmadduku    04/02/12 - Bug 13855016: proper match for mixed case
Rem                           usernames in DBA_CONNECT_ROLE_GRANTEES
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    weihwang    06/01/11 - Proj#23920: add USER/ALL/DBA_CODE_ROLE_PRIVS views
Rem    amunnoli    02/24/11 - Proj-26873grant select on dba_roles to AUDIT_ADMIN
Rem    krajaman    12/26/10 - krajaman_consolidated_database_phase6
Rem    akruglik    12/21/10 - DB Consolidation: add COMMON column to \*_USERS
Rem                           and DBA_ROLES
Rem    akruglik    11/18/10 - DB Consolidation: add COMMON column to various
Rem                           views describing privileges granted to roles
Rem    ssonawan    02/05/08 - bug 6757203: fix DBA_ROLES view definition to
Rem                           correctly describe role's authentication type
Rem    achoi       09/11/06 - fix bug 5508217
Rem    cdilling    08/08/06 - Add cataudit.sql
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

@@cataudit

remark
remark  FAMILY "PRIVILEGE MAP"
remark  Tables for mapping privilege numbers to privilege names.
remark
remark  SYSTEM_PRIVILEGE_MAP now in sql.bsq
remark
remark  TABLE_PRIVILEGE_MAP now in sql.bsq
remark
remark
remark  FAMILY "PRIVS"
remark

create or replace view SESSION_PRIVS
    (PRIVILEGE)
as
select spm.name
from sys.v$enabledprivs ep, system_privilege_map spm
where spm.privilege = ep.priv_number
/
comment on table SESSION_PRIVS is
'Privileges which the user currently has set'
/
comment on column SESSION_PRIVS.PRIVILEGE is
'Privilege Name'
/
create or replace public synonym SESSION_PRIVS for SESSION_PRIVS
/
grant read on SESSION_PRIVS to PUBLIC with grant option
/


remark
remark  FAMILY "ROLES"
remark

create or replace view SESSION_ROLES
    (ROLE)
as
select u.name
from x$kzsro,user$ u
where kzsrorol!=userenv('SCHEMAID') and kzsrorol!=1 and u.user#=kzsrorol
/
comment on table SESSION_ROLES is
'Roles which the user currently has enabled.'
/
comment on column SESSION_ROLES.ROLE is
'Role name'
/
create or replace public synonym SESSION_ROLES for SESSION_ROLES
/
grant read on SESSION_ROLES to PUBLIC with grant option
/
create or replace view ROLE_SYS_PRIVS
    (ROLE, PRIVILEGE, ADMIN_OPTION, COMMON, INHERITED)
as
/* Locally granted Privileges */
select u.name,spm.name,decode(min(mod(option$, 2)),1,'YES','NO'), 'NO', 'NO'
from  sys.user$ u, sys.system_privilege_map spm, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
  and u.user#=sa.grantee# and sa.privilege#=spm.privilege
  and bitand(nvl(option$, 0), 4) = 0
group by u.name, spm.name
union all
/* Commonly granted Privileges */
select u.name,spm.name,decode(min(bitand(option$,16)),16,'YES','NO'), 'YES',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from  sys.user$ u, sys.system_privilege_map spm, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
  and u.user#=sa.grantee# and sa.privilege#=spm.privilege
  and bitand(option$,8) = 8
group by u.name, spm.name
union all
/* Federationally granted Privileges */
select u.name,spm.name,decode(min(bitand(option$,128)),128,'YES','NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from  sys.user$ u, sys.system_privilege_map spm, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
  and u.user#=sa.grantee# and sa.privilege#=spm.privilege
  and bitand(option$,64) = 64
group by u.name, spm.name
/
comment on table ROLE_SYS_PRIVS is
'System privileges granted to roles'
/
comment on column ROLE_SYS_PRIVS.ROLE is
'Role name'
/
comment on column ROLE_SYS_PRIVS.PRIVILEGE is
'System Privilege'
/
comment on column ROLE_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column ROLE_SYS_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column ROLE_SYS_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ROLE_SYS_PRIVS for ROLE_SYS_PRIVS
/
grant read on ROLE_SYS_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_TAB_PRIVS
    (ROLE, OWNER, TABLE_NAME, COLUMN_NAME, PRIVILEGE, GRANTABLE, COMMON, 
     INHERITED)
as
/* Locally granted Privileges */
select u1.name,u2.name,o.name,col$.name,tpm.name,
       decode(max(mod(oa.option$,2)), 1, 'YES', 'NO'), 'NO', 'NO'
from  sys.user$ u1,sys.user$ u2,sys.table_privilege_map tpm,
      sys.objauth$ oa,sys."_CURRENT_EDITION_OBJ" o,sys.col$
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=oa.grantee# and oa.privilege#=tpm.privilege
   and oa.obj#=o.obj# and oa.obj#=col$.obj#(+) and oa.col#=col$.col#(+)
   and u2.user#=o.owner#
  and (col$.property IS NULL OR bitand(col$.property, 32) = 0 )
  and bitand(nvl(oa.option$, 0), 4) = 0
group by u1.name,u2.name,o.name,col$.name,tpm.name
union all
/* Commonly granted Privileges */
select u1.name,u2.name,o.name,col$.name,tpm.name,
       decode(max(bitand(oa.option$,16)), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from  sys.user$ u1,sys.user$ u2,sys.table_privilege_map tpm,
      sys.objauth$ oa,sys."_CURRENT_EDITION_OBJ" o,sys.col$
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=oa.grantee# and oa.privilege#=tpm.privilege
   and oa.obj#=o.obj# and oa.obj#=col$.obj#(+) and oa.col#=col$.col#(+)
   and u2.user#=o.owner#
  and (col$.property IS NULL OR bitand(col$.property, 32) = 0 )
  and bitand(oa.option$,8) = 8
group by u1.name,u2.name,o.name,col$.name,tpm.name
union all
/* Federationally granted Privileges */
select u1.name,u2.name,o.name,col$.name,tpm.name,
       decode(max(bitand(oa.option$,128)), 128, 'YES', 'NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from  sys.user$ u1,sys.user$ u2,sys.table_privilege_map tpm,
      sys.objauth$ oa,sys."_CURRENT_EDITION_OBJ" o,sys.col$
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=oa.grantee# and oa.privilege#=tpm.privilege
   and oa.obj#=o.obj# and oa.obj#=col$.obj#(+) and oa.col#=col$.col#(+)
   and u2.user#=o.owner#
  and (col$.property IS NULL OR bitand(col$.property, 32) = 0 )
  and bitand(oa.option$,64) = 64
group by u1.name,u2.name,o.name,col$.name,tpm.name
/

comment on table ROLE_TAB_PRIVS is
'Table privileges granted to roles'
/
comment on column ROLE_TAB_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_TAB_PRIVS.TABLE_NAME is
'Table Name or Sequence Name'
/
comment on column ROLE_TAB_PRIVS.COLUMN_NAME is
'Column Name if applicable'
/
comment on column ROLE_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column ROLE_TAB_PRIVS.GRANTABLE is
'Grant was with the GRANT option'
/
comment on column ROLE_TAB_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column ROLE_TAB_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ROLE_TAB_PRIVS for ROLE_TAB_PRIVS
/
grant read on ROLE_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ROLE_ROLE_PRIVS
    (ROLE, GRANTED_ROLE, ADMIN_OPTION, COMMON, INHERITED)
as
/* Locally granted Roles */
select u1.name,u2.name,decode(min(mod(option$, 2)),1,'YES','NO'), 'NO', 'NO'
from  sys.user$ u1, sys.user$ u2, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=sa.grantee# and u2.user#=sa.privilege#
  and bitand(nvl(option$, 0), 4) = 0
group by u1.name,u2.name
union all
/* Commonly granted Roles */
select u1.name,u2.name,decode(min(bitand(option$,16)),16,'YES','NO'), 
       'YES', decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from  sys.user$ u1, sys.user$ u2, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=sa.grantee# and u2.user#=sa.privilege#
  and bitand(option$,8) = 8
group by u1.name,u2.name
union all
/* Federationally granted Roles */
select u1.name,u2.name,decode(min(bitand(option$,128)),128,'YES','NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from  sys.user$ u1, sys.user$ u2, sys.sysauth$ sa
where grantee# in
   (select distinct(privilege#)
    from sys.sysauth$ sa
    where privilege# > 0
    connect by prior sa.privilege# = sa.grantee#
    start with grantee#=userenv('SCHEMAID') or grantee#=1 or grantee# in
      (select kzdosrol from x$kzdos))
   and u1.user#=sa.grantee# and u2.user#=sa.privilege#
  and bitand(option$,64) = 64
group by u1.name,u2.name
/
comment on table ROLE_ROLE_PRIVS is
'Roles which are granted to roles'
/
comment on column ROLE_ROLE_PRIVS.ROLE is
'Role Name'
/
comment on column ROLE_ROLE_PRIVS.GRANTED_ROLE is
'Role which was granted'
/
comment on column ROLE_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column ROLE_ROLE_PRIVS.COMMON is
'Role was granted commonly'
/
comment on column ROLE_ROLE_PRIVS.INHERITED is
'Was role grant inherited from another container'
/
create or replace public synonym ROLE_ROLE_PRIVS for ROLE_ROLE_PRIVS
/
grant read on ROLE_ROLE_PRIVS to PUBLIC with grant option
/

remark
remark Bug #14479124: The PASSWORD_REQUIRED and AUTHENTICATION_TYPE columns
remark of the DBA_ROLES view need to take into account the presence of the
remark new 11G and 12C verifiers, which exist in spare4 (prefixed by S: and 
remark T: respectively), since if a secure role is created in Exclusive Mode
remark (i.e. when the sqlnet.ora parameter SQLNET.ALLOWD_LOGON_VERSION_SERVER
remark is set to either "11" or "12"), the user$.password column will
remark be completely empty, and the verifier(s) for the secure
remark role will instead be populated into the user$.spare4 column.
remark
remark Bug 23550113: In 12.2, we revoked SELECT permission on user$ from
remark various Oracle supplied  users/roles. However, some of the PL/SQL
remark packages owned by these users are still referring to USER$.
remark Most of them are related to USER$.USER# retrieval, which should now
remark use {ALL|DBA}_USERS.USER_ID. However, in some cases, we also need to
remark retrieve the USER# corresponding to a role. So we need a ROLE_ID
remark column in DBA_ROLES view to be able to retrieve the user# in USER$.
remark
create or replace view DBA_ROLES (ROLE, ROLE_ID, PASSWORD_REQUIRED,
                                  AUTHENTICATION_TYPE,
                                  COMMON, ORACLE_MAINTAINED, INHERITED,
                                  IMPLICIT, EXTERNAL_NAME)
as
select name, user#,
             decode(password, null,          
                     decode(spare4, null, 'NO',
                       decode(REGEXP_INSTR(spare4, '[ST]:'), 0, 'NO',
                              'YES')),
                              'EXTERNAL',    'EXTERNAL',
                              'GLOBAL',      'GLOBAL',
                              'YES'),
             decode(password, null,
                     decode(spare4, null, 'NONE',
                       decode(REGEXP_INSTR(spare4, '[ST]:'), 0, 'NONE',
                              'PASSWORD')),
                              'EXTERNAL',    'EXTERNAL',
                              'GLOBAL',      'GLOBAL',
                              'APPLICATION', 'APPLICATION',
                              'PASSWORD'),
             decode(bitand(spare1, 4224), 0, 'NO', 'YES'),
             decode(bitand(spare1, 256), 256, 'Y', 'N'),
             decode(bitand(spare1, 4224), 
                    128, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 
                                1, 'NO', 'YES'),
                    4224, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                                 'YES', 'YES', 'NO'),
                    'NO'),
             decode(bitand(spare1, 32768), 32768, 'YES', 'NO'),
             ext_username
from  user$
where type# = 0 and name not in ('PUBLIC', '_NEXT_USER')
/
create or replace public synonym DBA_ROLES for DBA_ROLES
/
grant select on DBA_ROLES to select_catalog_role
/
grant read on DBA_ROLES to AUDIT_ADMIN
/
comment on table DBA_ROLES is
'All Roles which exist in the database'
/
comment on column DBA_ROLES.ROLE is
'Role Name'
/
comment on column DBA_ROLES.ROLE_ID is
'ID number of the role'
/
comment on column DBA_ROLES.PASSWORD_REQUIRED is
'Deprecated from 11.2 -- use AUTHENTICATION_TYPE instead'
/
comment on column DBA_ROLES.AUTHENTICATION_TYPE is
'Indicates authentication mechanism for the role'
/
comment on column DBA_ROLES.COMMON is
'Indicates whether this role is Common'
/
comment on column DBA_ROLES.ORACLE_MAINTAINED is
'Denotes whether the role was created, and is maintained, by Oracle-supplied scripts. A role for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column DBA_ROLES.INHERITED is
'Was role definition inherited from another container'
/
comment on column DBA_ROLES.IMPLICIT is
'Was this role a common role created by an implicit application'
/
comment on column DBA_ROLES.EXTERNAL_NAME is
'Role external name'
/

execute CDBView.create_cdbview(false,'SYS','DBA_ROLES','CDB_ROLES');
grant select on SYS.CDB_ROLES to select_catalog_role
/
grant read on SYS.CDB_ROLES to AUDIT_ADMIN 
/
create or replace public synonym CDB_ROLES for SYS.CDB_ROLES
/

remark
remark  FAMILY "SYS GRANTS"
remark
remark
create or replace view USER_SYS_PRIVS
    (USERNAME, PRIVILEGE, ADMIN_OPTION, COMMON, INHERITED)
as
/* Locally granted Privileges */
select decode(sa.grantee#,1,'PUBLIC',su.name),spm.name,
       decode(min(mod(option$, 2)),1,'YES','NO'), 'NO', 'NO'
from  sys.system_privilege_map spm, sys.sysauth$ sa, sys.user$ su
where ((sa.grantee#=userenv('SCHEMAID') and su.user#=sa.grantee#)
       or sa.grantee#=1)
  and sa.privilege#=spm.privilege
  and bitand(nvl(option$, 0), 4) = 0
group by decode(sa.grantee#,1,'PUBLIC',su.name),spm.name
union all
/* Commonly granted Privileges */
select decode(sa.grantee#,1,'PUBLIC',su.name),spm.name,
       decode(min(bitand(option$,16)),16,'YES','NO'), 
       'YES', decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from  sys.system_privilege_map spm, sys.sysauth$ sa, sys.user$ su
where ((sa.grantee#=userenv('SCHEMAID') and su.user#=sa.grantee#)
       or sa.grantee#=1)
  and sa.privilege#=spm.privilege
  and bitand(option$,8) = 8
group by decode(sa.grantee#,1,'PUBLIC',su.name),spm.name
union all
/* Federationally granted Privileges */
select decode(sa.grantee#,1,'PUBLIC',su.name),spm.name,
       decode(min(bitand(option$,128)),128,'YES','NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, sys.user$ su
where ((sa.grantee#=userenv('SCHEMAID') and su.user#=sa.grantee#)
       or sa.grantee#=1)
  and sa.privilege#=spm.privilege
  and bitand(option$,64) = 64
group by decode(sa.grantee#,1,'PUBLIC',su.name),spm.name
/
comment on table USER_SYS_PRIVS is
'System privileges granted to current user'
/
comment on column USER_SYS_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column USER_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column USER_SYS_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column USER_SYS_PRIVS.INHERITED is
'Was role grant inherited from another container'
/
create or replace public synonym USER_SYS_PRIVS for USER_SYS_PRIVS
/
grant read on USER_SYS_PRIVS to PUBLIC with grant option
/
create or replace view DBA_SYS_PRIVS
    (GRANTEE, PRIVILEGE, ADMIN_OPTION, COMMON, INHERITED)
as
/* Locally granted Privileges */
select u.name,spm.name,decode(min(mod(option$, 2)),1,'YES','NO'), 
       'NO', 'NO'
from  sys.system_privilege_map spm, sys.sysauth$ sa, user$ u
where sa.grantee#=u.user# and sa.privilege#=spm.privilege
  and bitand(nvl(option$, 0), 4) = 0
group by u.name,spm.name
union all
/* Commonly granted Privileges */
select u.name,spm.name,decode(min(bitand(option$, 16)),16,'YES','NO'), 
       'YES', decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from  sys.system_privilege_map spm, sys.sysauth$ sa, user$ u
where sa.grantee#=u.user# and sa.privilege#=spm.privilege
  and bitand(option$,8) = 8
group by u.name,spm.name
union all
/* Federationally granted Privileges */
select u.name,spm.name,decode(min(bitand(option$, 128)),128,'YES','NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from  sys.system_privilege_map spm, sys.sysauth$ sa, user$ u
where sa.grantee#=u.user# and sa.privilege#=spm.privilege
  and bitand(option$,64) = 64
group by u.name,spm.name
/
create or replace public synonym DBA_SYS_PRIVS for DBA_SYS_PRIVS
/
grant select on DBA_SYS_PRIVS to select_catalog_role
/
comment on table DBA_SYS_PRIVS is
'System privileges granted to users and roles'
/
comment on column DBA_SYS_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_SYS_PRIVS.PRIVILEGE is
'System privilege'
/
comment on column DBA_SYS_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column DBA_SYS_PRIVS.COMMON is
'Privilege is common'
/
comment on column DBA_SYS_PRIVS.INHERITED is
'Was role grant inherited from another container'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SYS_PRIVS','CDB_SYS_PRIVS');
grant select on SYS.CDB_SYS_PRIVS to select_catalog_role
/
create or replace public synonym CDB_SYS_PRIVS for SYS.CDB_SYS_PRIVS
/

remark
remark  FAMILY "PROXIES"
remark  Allowed proxy authentication methods
remark
create or replace view USER_PROXIES
    (CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE)
as
select u.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE'),
       (select u.name from sys.user$ u where pr.role# = u.user#)
from sys.user$ u, sys.proxy_info$ p, sys.proxy_role_info$ pr
where u.user#  = p.client#
  and p.proxy#  = pr.proxy#(+)
  and p.client# = pr.client#(+)
  and p.proxy# = userenv('SCHEMAID')
/
comment on table USER_PROXIES is
'Description of connections the user is allowed to proxy'
/
comment on column USER_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column USER_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column USER_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column USER_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
create or replace public synonym USER_PROXIES for USER_PROXIES
/
grant read on USER_PROXIES to PUBLIC with grant option
/

create or replace view DBA_PROXIES
    (PROXY, CLIENT, AUTHENTICATION, AUTHORIZATION_CONSTRAINT, ROLE, PROXY_AUTHORITY)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE',
                      16, 'PROXY MAY ACTIVATE ALL CLIENT ROLES'),
       (select u.name from sys.user$ u where pr.role# = u.user#),
       case p.flags when 16 then 'DIRECTORY' else 'DATABASE' end
from sys.user$ u1, sys.user$ u2,
     sys.proxy_info$ p, sys.proxy_role_info$ pr
where u1.user#(+)  = p.proxy#
  and u2.user#     = p.client#
  and p.proxy#     = pr.proxy#(+)
  and p.client#    = pr.client#(+)
/
comment on table DBA_PROXIES is
'Information about all proxy connections'
/
comment on column DBA_PROXIES.PROXY is
'Name of the proxy user'
/
comment on column DBA_PROXIES.CLIENT is
'Name of the client user who the proxy user can act on behalf of'
/
comment on column DBA_PROXIES.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column DBA_PROXIES.AUTHORIZATION_CONSTRAINT is
'Indicates the proxy''s authority to exercise roles on client''s behalf'
/
comment on column DBA_PROXIES.ROLE is
'Name of the role referenced in authorization constraint'
/
comment on column DBA_PROXIES.PROXY_AUTHORITY is
'Indicates where proxy permissions are managed'
/
create or replace public synonym DBA_PROXIES for DBA_PROXIES
/
grant select on DBA_PROXIES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PROXIES','CDB_PROXIES');
grant select on SYS.CDB_PROXIES to select_catalog_role
/
create or replace public synonym CDB_PROXIES for SYS.CDB_PROXIES
/

rem Contains a list of all proxy users and the clients upon whose behalf they
rem can act
create or replace view PROXY_USERS
    (PROXY, CLIENT, AUTHENTICATION, FLAGS)
as
select u1.name,
       u2.name,
       decode(p.credential_type#, 0, 'NO',
                                  5, 'YES'),
       decode(p.flags, 0, null,
                       1, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       2, 'NO CLIENT ROLES MAY BE ACTIVATED',
                       4, 'PROXY MAY ACTIVATE ROLE',
                       5, 'PROXY MAY ACTIVATE ALL CLIENT ROLES',
                       8, 'PROXY MAY NOT ACTIVATE ROLE')
from sys.user$ u1, sys.user$ u2, sys.proxy_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
/
comment on table PROXY_USERS is
'List of proxy users and the client on whose behalf they can act.'
/
comment on column PROXY_USERS.PROXY is
'Name of a proxy user'
/
comment on column PROXY_USERS.CLIENT is
'Name of the client user who the proxy user can act as'
/
comment on column PROXY_USERS.AUTHENTICATION is
'Indicates whether proxy is required to supply client''s authentication credentials'
/
comment on column PROXY_USERS.FLAGS is
'Flags associated with the proxy/client pair'
/
create or replace public synonym PROXY_USERS for PROXY_USERS
/
grant select on PROXY_USERS to SELECT_CATALOG_ROLE
/

rem List of roles that may executed by a proxy user on behalf of a client.
create or replace view PROXY_ROLES (PROXY, CLIENT, ROLE)
as
select u1.name,
       u2.name,
       u3.name
from sys.user$ u1, sys.user$ u2, sys.user$ u3, sys.proxy_role_info$ p
where u1.user# = p.proxy#
  and u2.user# = p.client#
  and u3.user# = p.role#
/
comment on table PROXY_ROLES is
'Table of roles that a proxy can set on behalf of a client'
/
comment on column PROXY_ROLES.PROXY is
'Name of a proxy user'
/
comment on column PROXY_ROLES.CLIENT is
'Name of the client user who the proxy user acts as'
/
comment on column PROXY_ROLES.ROLE is
'Name of the role that the proxy can execute'
/
create or replace public synonym PROXY_ROLES for PROXY_ROLES
/
grant select on PROXY_ROLES to SELECT_CATALOG_ROLE
/

rem List of all proxies, clients and roles.
create or replace view PROXY_USERS_AND_ROLES (PROXY, CLIENT, FLAGS, ROLE)
as
select u.proxy,
       u.client,
       u.flags,
       r.role
from sys.proxy_users u, sys.proxy_roles r
where u.proxy  = r.proxy
  and u.client = r.client
/
comment on table PROXY_USERS_AND_ROLES is
'List of all proxies, clients and roles.'
/
comment on column PROXY_USERS_AND_ROLES.PROXY is
'Name of the proxy user'
/
comment on column PROXY_USERS_AND_ROLES.CLIENT is
'Name of the client user'
/
comment on column PROXY_USERS_AND_ROLES.FLAGS is
'Flags corresponding to the proxy/client combination'
/
comment on column PROXY_USERS_AND_ROLES.ROLE is
'Name of the role that a proxy can execute while acting on behalf of the
client'
/
create or replace public synonym PROXY_USERS_AND_ROLES
   for PROXY_USERS_AND_ROLES
/
grant select on PROXY_USERS_AND_ROLES to SELECT_CATALOG_ROLE
/

create or replace view DBA_CONNECT_ROLE_GRANTEES
  (GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'CONNECT'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = 'CONNECT');
/
comment on table DBA_CONNECT_ROLE_GRANTEES is
'Information regarding which users are granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.GRANTEE is
'User or schema to which CONNECT is granted'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.PATH_OF_CONNECT_ROLE_GRANT is
'The path of role inheritence through which the grantee is granted CONNECT'
/
comment on column DBA_CONNECT_ROLE_GRANTEES.ADMIN_OPT is
'If the grantee was granted the CONNECT role with Admin Option'
/
create or replace public synonym DBA_CONNECT_ROLE_GRANTEES
for DBA_CONNECT_ROLE_GRANTEES
/
grant select on DBA_CONNECT_ROLE_GRANTEES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CONNECT_ROLE_GRANTEES','CDB_CONNECT_ROLE_GRANTEES');
grant select on SYS.CDB_CONNECT_ROLE_GRANTEES to select_catalog_role
/
create or replace public synonym CDB_CONNECT_ROLE_GRANTEES for SYS.CDB_CONNECT_ROLE_GRANTEES
/

REM FAMILY "CODE_ROLE_PRIVS" 
REM This family of views show roles attached to program units
create or replace view USER_CODE_ROLE_PRIVS 
(OBJECT_NAME, OBJECT_TYPE, ROLE) 
as
(
select o.name, decode(o.type#, 7,  'PROCEDURE',
                               8,  'FUNCTION',
                               9,  'PACKAGE',
                               13, 'TYPE',
                                   'UNDEFINED'),
       r.name
 from sys."_CURRENT_EDITION_OBJ" o, sys.user$ r, sys.codeauth$ c
where o.obj# = c.obj#
  and c.privilege# = r.user#
  and o.owner# = userenv('SCHEMAID')
)
/
comment on table USER_CODE_ROLE_PRIVS is
'Roles attached to the program units owned by current user'
/
comment on column USER_CODE_ROLE_PRIVS.OBJECT_NAME is
'Object name'
/
comment on column USER_CODE_ROLE_PRIVS.OBJECT_TYPE is
'Object type'
/
comment on column USER_CODE_ROLE_PRIVS.ROLE is
'Attached role name'
/
create or replace public synonym USER_CODE_ROLE_PRIVS for USER_CODE_ROLE_PRIVS
/
grant read on USER_CODE_ROLE_PRIVS to PUBLIC with grant option
/

create or replace view ALL_CODE_ROLE_PRIVS 
(OWNER, OBJECT_NAME, OBJECT_TYPE, ROLE) 
as
(
select u.name, o.name, decode(o.type#, 7,  'PROCEDURE',
                               8,  'FUNCTION',
                               9,  'PACKAGE',
                               13, 'TYPE',
                                   'UNDEFINED'),
       r.name
  from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ r,  
       sys.codeauth$ c
 where o.obj# = c.obj#
   and c.privilege# = r.user#
   and u.user# = o.owner#
   and (o.owner# = userenv('SCHEMAID')
    or
    (
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                 and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                    7 /* LOCK */,     9 /* SELECT */,
                                    10 /* UPDATE */, 12 /* EXECUTE */,
                                    11 /* USAGE */,  16 /* CREATE */,
                                    17 /* READ */,   18 /* WRITE  */))
    )
    or 
      ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
)
/
comment on table ALL_CODE_ROLE_PRIVS is
'Roles attached to the program units accessible to the user'
/
comment on column ALL_CODE_ROLE_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_CODE_ROLE_PRIVS.OBJECT_NAME is
'Object name'
/
comment on column ALL_CODE_ROLE_PRIVS.OBJECT_TYPE is
'Object type'
/
comment on column ALL_CODE_ROLE_PRIVS.ROLE is
'Attached role name'
/
create or replace public synonym ALL_CODE_ROLE_PRIVS for ALL_CODE_ROLE_PRIVS
/
grant read on ALL_CODE_ROLE_PRIVS to PUBLIC with grant option
/


create or replace view DBA_CODE_ROLE_PRIVS 
(OWNER, OBJECT_NAME, OBJECT_TYPE, ROLE) 
as
(
select u.name, o.name, decode(o.type#, 7,  'PROCEDURE',
                               8,  'FUNCTION',
                               9,  'PACKAGE',
                               13, 'TYPE',
                                   'UNDEFINED'),
      r.name
 from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ r, sys.codeauth$ c
where o.obj# = c.obj#
  and c.privilege# = r.user#
  and u.user# = o.owner#
)
/
comment on table DBA_CODE_ROLE_PRIVS is
'Roles attached to the program units'
/
comment on column DBA_CODE_ROLE_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_CODE_ROLE_PRIVS.OBJECT_NAME is
'Object name'
/
comment on column DBA_CODE_ROLE_PRIVS.OBJECT_TYPE is
'Object type'
/
comment on column DBA_CODE_ROLE_PRIVS.ROLE is
'Attached role name'
/
create or replace public synonym DBA_CODE_ROLE_PRIVS for DBA_CODE_ROLE_PRIVS
/
grant select on DBA_CODE_ROLE_PRIVS to select_catalog_role
/
grant read any table, select any table, delete any table, update any table, insert any table to sys with admin option
/

execute CDBView.create_cdbview(false,'SYS','DBA_CODE_ROLE_PRIVS','CDB_CODE_ROLE_PRIVS');
grant select on SYS.CDB_CODE_ROLE_PRIVS to select_catalog_role
/
create or replace public synonym CDB_CODE_ROLE_PRIVS for SYS.CDB_CODE_ROLE_PRIVS
/


@?/rdbms/admin/sqlsessend.sql
