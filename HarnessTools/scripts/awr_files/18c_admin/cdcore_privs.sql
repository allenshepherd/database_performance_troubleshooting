Rem
Rem $Header: rdbms/admin/cdcore_privs.sql /main/3 2017/10/10 03:05:55 kkamakot Exp $
Rem
Rem cdcore_privs.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_privs.sql - Catalog DCORE.bsq PRIVilege viewS
Rem
Rem    DESCRIPTION
Rem      This script creates views related to privilege objects in dcore.bsq
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_privs.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_privs.sql
Rem    SQL_PHASE: CDCORE_PRIVS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkamakot    10/03/17 - Bug 24297216: display latest type version
Rem                           privilege only for "TAB_PRIVS" family
Rem    jklebane    08/15/17 - #(26558603). Remove ORDERED hint from
Rem                           *_ROLE_PRIVS views
Rem    raeburns    04/28/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    04/28/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


rem
rem V6 views required for other Oracle products
rem

create or replace view TABLE_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR,
       SELECT_PRIV, INSERT_PRIV, DELETE_PRIV,
       UPDATE_PRIV, REFERENCES_PRIV, ALTER_PRIV, INDEX_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 7, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
     decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
       decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
              13, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 6, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 19, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             5, 2),'01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 10, 1, 0))), 0, 'N', 'S')),
    decode(substr(lpad(sum(decode(col#, null, power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0), 0)), 26, '0'),
             3, 2), '01', 'A', '11', 'G',
          decode(sum(decode(col#,
                            null, 0,
                            decode(privilege#, 11, 1, 0))), 0, 'N', 'S')),
   decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 25, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 15, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur, sys.user$ u
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, ur.name, ue.name
/
comment on table TABLE_PRIVILEGES is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column TABLE_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column TABLE_PRIVILEGES.OWNER is
'Owner of the object'
/
comment on column TABLE_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column TABLE_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column TABLE_PRIVILEGES.SELECT_PRIV is
'Permission to SELECT from the object?'
/
comment on column TABLE_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the object?'
/
comment on column TABLE_PRIVILEGES.DELETE_PRIV is
'Permission to DELETE from the object?'
/
comment on column TABLE_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the object?'
/
comment on column TABLE_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the object?'
/
comment on column TABLE_PRIVILEGES.ALTER_PRIV is
'Permission to ALTER the object?'
/
comment on column TABLE_PRIVILEGES.INDEX_PRIV is
'Permission to create/drop an INDEX on the object?'
/
comment on column TABLE_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym TABLE_PRIVILEGES for TABLE_PRIVILEGES
/
grant read on TABLE_PRIVILEGES to PUBLIC
/
create or replace view COLUMN_PRIVILEGES
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR,
       INSERT_PRIV, UPDATE_PRIV, REFERENCES_PRIV,
       CREATED)
as
select ue.name, u.name, o.name, c.name, ur.name,
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 13, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 5, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'),
    decode(substr(lpad(sum(power(10, privilege#*2) +
      decode(mod(option$,2), 1, power(10, privilege#*2 + 1), 0)), 26, '0'), 3, 2),
      '00', 'N', '01', 'Y', '11', 'G', 'N'), min(null)
from sys.objauth$ oa, sys.col$ c,sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue,
     sys.user$ ur, sys.user$ u
where oa.col# is not null
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  group by u.name, o.name, c.name, ur.name, ue.name
/
comment on table COLUMN_PRIVILEGES is
'Grants on columns for which the user is the grantor, grantee, owner, or
 an enabled role or PUBLIC is the grantee'
/
comment on column COLUMN_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column COLUMN_PRIVILEGES.OWNER is
'Username of the owner of the object'
/
comment on column COLUMN_PRIVILEGES.TABLE_NAME is
'Name of the object'
/
comment on column COLUMN_PRIVILEGES.COLUMN_NAME is
'Name of the column'
/
comment on column COLUMN_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column COLUMN_PRIVILEGES.INSERT_PRIV is
'Permission to INSERT into the column?'
/
comment on column COLUMN_PRIVILEGES.UPDATE_PRIV is
'Permission to UPDATE the column?'
/
comment on column COLUMN_PRIVILEGES.REFERENCES_PRIV is
'Permission to make REFERENCES to the column?'
/
comment on column COLUMN_PRIVILEGES.CREATED is
'Timestamp for the grant'
/
create or replace public synonym COLUMN_PRIVILEGES for COLUMN_PRIVILEGES
/
grant read on COLUMN_PRIVILEGES to PUBLIC
/

remark
remark  FAMILY "COL_PRIVS"
remark  Grants on columns.
remark
create or replace view USER_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE,
       COMMON, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(oa.option$,64) = 64
/
comment on table USER_COL_PRIVS is
'Grants on columns for which the user is the owner, grantor or grantee'
/
comment on column USER_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_COL_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column USER_COL_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_COL_PRIVS for USER_COL_PRIVS
/
grant read on USER_COL_PRIVS to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME,
       PRIVILEGE, GRANTABLE, COMMON, INHERITED)
as
/* Locally granted Privileges */
select ur.name, ue.name, u.name, o.name, c.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ur.name, ue.name, u.name, o.name, c.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ur.name, ue.name, u.name, o.name, c.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(oa.option$,64) = 64
/
comment on table ALL_COL_PRIVS is
'Grants on columns for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_COL_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_COL_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_COL_PRIVS for ALL_COL_PRIVS
/
grant read on ALL_COL_PRIVS to PUBLIC with grant option
/
create or replace view DBA_COL_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE,
       COMMON, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(oa.option$,8) = 8
union all
/* Federationallyly granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(oa.option$,64) = 64
/
create or replace public synonym DBA_COL_PRIVS for DBA_COL_PRIVS
/
grant select on DBA_COL_PRIVS to select_catalog_role
/
comment on table DBA_COL_PRIVS is
'All grants on columns in the database'
/
comment on column DBA_COL_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column DBA_COL_PRIVS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_COL_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_PRIVS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_COL_PRIVS.PRIVILEGE is
'Column Privilege'
/
comment on column DBA_COL_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column DBA_COL_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column DBA_COL_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
execute CDBView.create_cdbview(false,'SYS','DBA_COL_PRIVS','CDB_COL_PRIVS');
grant select on SYS.CDB_COL_PRIVS to select_catalog_role
/
create or replace public synonym CDB_COL_PRIVS for SYS.CDB_COL_PRIVS
/

remark
remark  FAMILY "COL_PRIVS_MADE"
remark  Grants on columns made by the user.
remark  This family has no DBA member.
remark
create or replace view USER_COL_PRIVS_MADE
      (GRANTEE, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE, COMMON,
       INHERITED)
as
/* Locally granted Privileges */
select ue.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(oa.option$,64) = 64
/
comment on table USER_COL_PRIVS_MADE is
'All grants on columns of objects owned by the user'
/
comment on column USER_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_COL_PRIVS_MADE.COMMON is
'Privilege was granted commonly'
/
comment on column USER_COL_PRIVS_MADE.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_COL_PRIVS_MADE for USER_COL_PRIVS_MADE
/
grant read on USER_COL_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE,
       COMMON, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(oa.option$,64) = 64
/
comment on table ALL_COL_PRIVS_MADE is
'Grants on columns for which the user is owner or grantor'
/
comment on column ALL_COL_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_MADE.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_MADE.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_MADE.PRIVILEGE is
'Column Privilege'
/
comment on column ALL_COL_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_COL_PRIVS_MADE.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_COL_PRIVS_MADE.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_COL_PRIVS_MADE for ALL_COL_PRIVS_MADE
/
grant read on ALL_COL_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "COL_PRIVS_RECD"
remark  Received grants on columns
remark
create or replace view USER_COL_PRIVS_RECD
      (OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE, COMMON,
       INHERITED)
as
/* Locally granted Privileges */
select u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(oa.option$,64) = 64
/
comment on table USER_COL_PRIVS_RECD is
'Grants on columns for which the user is the grantee'
/
comment on column USER_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column USER_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column USER_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_COL_PRIVS_RECD.PRIVILEGE is
'Column Privilege'
/
comment on column USER_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_COL_PRIVS_RECD.COMMON is
'Privilege was granted commonly'
/
comment on column USER_COL_PRIVS_RECD.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_COL_PRIVS_RECD for USER_COL_PRIVS_RECD
/
grant read on USER_COL_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_COL_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, COLUMN_NAME, GRANTOR, PRIVILEGE, GRANTABLE,
       COMMON, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'), 'NO', 'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, c.name, ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'), 'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.col$ c, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.obj# = c.obj#
  and oa.col# = c.col#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and oa.col# is not null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(oa.option$,64) = 64
/
comment on table ALL_COL_PRIVS_RECD is
'Grants on columns for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_COL_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_COL_PRIVS_RECD.OWNER is
'Username of the owner of the object'
/
comment on column ALL_COL_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_PRIVS_RECD.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_COL_PRIVS_RECD.PRIVILEGE is
'Column privilege'
/
comment on column ALL_COL_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_COL_PRIVS_RECD.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_COL_PRIVS_RECD.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_COL_PRIVS_RECD for ALL_COL_PRIVS_RECD
/
grant read on ALL_COL_PRIVS_RECD to PUBLIC with grant option
/

-- 18258385: Update USER_ROLE_PRIVS for proxy connections so only roles 
--           authorized to proxy user are visible in a proxy session.
remark
remark  FAMILY "ROLE_PRIVS"
remark
remark
create or replace view USER_ROLE_PRIVS
    (USERNAME, GRANTED_ROLE, ADMIN_OPTION, DELEGATE_OPTION, DEFAULT_ROLE, 
     OS_GRANTED, COMMON, INHERITED)
as
select groles.username, groles.granted_role, groles.admin_option, 
       groles.delegate_option, groles.default_role, groles.os_granted, 
       groles.common, groles.inherited
from 
(
/* Locally granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name) username, 
    u2.name granted_role,
    decode(min(bitand(nvl(option$, 0), 1)), 1, 'YES', 'NO') admin_option,
    decode(min(bitand(nvl(option$, 0), 2)), 2, 'YES', 'NO') delegate_option,
    decode(min(u1.defrole), 0, 'NO',
      1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'),
      2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
      3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO') default_role, 
    'NO' os_granted, 'NO' common, 'NO' inherited
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee# in (userenv('SCHEMAID'),1) and sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$, 0), 4) = 0
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union all
/* Commonly granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name) username, 
  u2.name granted_role,
  decode(min(bitand(nvl(option$, 0), 16)), 16, 'YES', 'NO') admin_option,
  decode(min(bitand(nvl(option$, 0), 32)), 32, 'YES', 'NO') delegate_option,
  decode(min(u1.defrole), 0, 'NO', 
    1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'),
    2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
    3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO') default_role,
  'NO' os_granted, 'YES' common, 
   decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES') inherited
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee# in (userenv('SCHEMAID'),1) and sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$,0), 8) = 8
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union all
/* Federationally granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name) username, 
  u2.name granted_role,
  decode(min(bitand(nvl(option$, 0), 128)), 128, 'YES', 'NO') admin_option,
  decode(min(bitand(nvl(option$, 0), 256)), 256, 'YES', 'NO') delegate_option,
  decode(min(u1.defrole), 0, 'NO', 
    1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'),
    2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
    3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO') default_role,
  'NO' os_granted, 'YES' common, 
  decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
         'YES', 'YES', 'NO') inherited
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee# in (userenv('SCHEMAID'),1) and sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$,0), 64) = 64
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union
select su.name username,u.name granted_role,
       decode(kzdosadm,'A','YES','NO') admin_option, NULL delegate_option,
       decode(kzdosdef,'Y','YES','NO') default_role, 
       'YES' os_granted, 'NO' common, 'NO' inherited
from sys.user$ u,x$kzdos, sys.user$ su
where u.user#=x$kzdos.kzdosrol and
      su.user#=userenv('SCHEMAID')
) groles
where sys_context('userenv', 'proxy_user') is null
      or
      (sys_context('userenv', 'proxy_user') is not null and
      (groles.default_role = 'YES' /* password protected roles cannot be enabled in proxy session so should not 
                                      be displayed here. Secure application roles though, should be displayed. */
       or EXISTS (select 1 from sys.user$ u where u.name = groles.granted_role and u.password = 'APPLICATION'))
      and /* password protected roles cannot be enabled in proxy session so should not be displayed here */
      (EXISTS (select 1 from 
               sys.proxy_info$ p where 
               p.client#=userenv('SCHEMAID') and 
               p.proxy# = sys_context('userenv', 'proxy_userid') 
               and BITAND(p.flags,2) =0 and (BITAND(p.flags,1)>0  or
       EXISTS (select 1 from sys.proxy_role_info$ pr, sys.user$ u where 
               p.client# = pr.client# and p.proxy# = pr.proxy# and
               ((BITAND(p.flags,4) > 0 and 
              (pr.role# = u.user# and u.name = groles.granted_role)) or 
             (BITAND(p.flags,8) > 0 and 
              (pr.role# = u.user# and u.name != groles.granted_role)))))) or 
              /* it could be a RAS proxy session. Since xs$proxy_role is not yet created,
               * assume RAS proxy session if no row found in proxy_info$.
               */
       NOT EXISTS (select 1 from 
                   sys.proxy_info$ p where 
                   p.client#=userenv('SCHEMAID') and 
                   p.proxy# = sys_context('userenv', 'proxy_userid'))))
/

comment on table USER_ROLE_PRIVS is
'Roles granted to current user'
/
comment on column USER_ROLE_PRIVS.USERNAME is
'User Name or PUBLIC'
/
comment on column USER_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column USER_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column USER_ROLE_PRIVS.DELEGATE_OPTION is
'Grant was with the DELEGATE option'
/
comment on column USER_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/
comment on column USER_ROLE_PRIVS.OS_GRANTED is
'Role is granted via the operating system (using OS_ROLES = TRUE)'
/
comment on column USER_ROLE_PRIVS.COMMON is
'Role was granted commonly'
/
comment on column USER_ROLE_PRIVS.INHERITED is
'Was role grant inherited from another container'
/
create or replace public synonym USER_ROLE_PRIVS for USER_ROLE_PRIVS
/
grant read on USER_ROLE_PRIVS to PUBLIC with grant option
/
create or replace view DBA_ROLE_PRIVS
    (GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DELEGATE_OPTION, DEFAULT_ROLE, 
     COMMON, INHERITED)
as
/* Locally granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(bitand(nvl(option$, 0), 1)), 1, 'YES', 'NO'),
       decode(min(bitand(nvl(option$, 0), 2)), 2, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 
              1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'),'NO'),
              2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
              3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO'), 
       'NO', 'NO'
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$, 0), 4) = 0
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union all
/* Commonly granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(bitand(nvl(option$, 0), 16)), 16, 'YES', 'NO'),
       decode(min(bitand(nvl(option$, 0), 32)), 32, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 
              1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'),'NO'),
              2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
              3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO'), 
       'YES', decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$, 0), 8) = 8
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
union all
/* Federationally granted Privileges */
select decode(sa.grantee#, 1, 'PUBLIC', u1.name), u2.name,
       decode(min(bitand(nvl(option$, 0), 128)), 128, 'YES', 'NO'),
       decode(min(bitand(nvl(option$, 0), 256)), 256, 'YES', 'NO'),
       decode(min(u1.defrole), 0, 'NO', 
              1, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'),'NO'),
              2, decode(min(ud.role#), NULL, 'NO', decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO')),
              3, decode(min(ud.role#), NULL, decode(min(u2.password), NULL, decode(min(u2.spare4), NULL, 'YES', 'NO'), 'NO'), 'NO'), 'NO'), 
       'YES', 
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sysauth$ sa, user$ u1, user$ u2, defrole$ ud
where sa.grantee#=ud.user#(+)
  and sa.privilege#=ud.role#(+) and u1.user#=sa.grantee#
  and u2.user#=sa.privilege#
  and bitand(nvl(option$, 0), 64) = 64
group by decode(sa.grantee#,1,'PUBLIC',u1.name),u2.name
/
create or replace public synonym DBA_ROLE_PRIVS for DBA_ROLE_PRIVS
/
grant select on DBA_ROLE_PRIVS to select_catalog_role
/
comment on table DBA_ROLE_PRIVS is
'Roles granted to users and roles'
/
comment on column DBA_ROLE_PRIVS.GRANTEE is
'Grantee Name, User or Role receiving the grant'
/
comment on column DBA_ROLE_PRIVS.GRANTED_ROLE is
'Granted role name'
/
comment on column DBA_ROLE_PRIVS.ADMIN_OPTION is
'Grant was with the ADMIN option'
/
comment on column DBA_ROLE_PRIVS.DELEGATE_OPTION is
'Grant was with the DELEGATE option'
/
comment on column DBA_ROLE_PRIVS.DEFAULT_ROLE is
'Role is designated as a DEFAULT ROLE for the user'
/
comment on column DBA_ROLE_PRIVS.COMMON is
'Role was granted commonly'
/
comment on column DBA_ROLE_PRIVS.INHERITED is
'Was role grant inherited from another container'
/

execute CDBView.create_cdbview(false,'SYS','DBA_ROLE_PRIVS','CDB_ROLE_PRIVS');
grant select on SYS.CDB_ROLE_PRIVS to select_catalog_role
/
create or replace public synonym CDB_ROLE_PRIVS for SYS.CDB_ROLE_PRIVS
/

remark
remark  FAMILY "TAB_PRIVS"
remark  Grants on objects.
remark
create or replace view USER_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE',
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'           
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(nvl(oa.option$, 0), 4) = 0
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(oa.option$,8) = 8
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (oa.grantor#, oa.grantee#, o.owner#)
  and bitand(oa.option$,64) = 64
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Locally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO',
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and userenv('SCHEMAID') in (ua.grantor#, ua.grantee#, ua.user#)
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User Privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES',
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and userenv('SCHEMAID') in (ua.grantor#, ua.grantee#, ua.user#)
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User Privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES',
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and userenv('SCHEMAID') in (ua.grantor#, ua.grantee#, ua.user#)
  and bitand(ua.option$,64) = 64
/
comment on table USER_TAB_PRIVS is
'Grants on objects for which the user is the owner, grantor or grantee'
/
comment on column USER_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column USER_TAB_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column USER_TAB_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_TAB_PRIVS for USER_TAB_PRIVS
/
grant read on USER_TAB_PRIVS to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS
      (GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, GRANTABLE,
       HIERARCHY, COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ur.name, ue.name, u.name, o.name, 
       tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'       
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(nvl(oa.option$, 0), 4) = 0
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Commonly granted Privileges */
select ur.name, ue.name, u.name, o.name, 
       tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(oa.option$,8) = 8
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Federationally granted Privileges */
select ur.name, ue.name, u.name, o.name, 
       tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and u.user# = o.owner#
  and oa.privilege# = tpm.privilege
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
  and bitand(oa.option$,64) = 64
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Locally granted User privileges */
select ur.name, ue.name, u.name, u.name, upm.name,
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and (ua.grantor# = userenv('SCHEMAID') or
       ua.grantee# in (select kzsrorol from x$kzsro) or
       ua.user# = userenv('SCHEMAID'))
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select ur.name, ue.name, u.name, u.name, upm.name,
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and (ua.grantor# = userenv('SCHEMAID') or
       ua.grantee# in (select kzsrorol from x$kzsro) or
       ua.user# = userenv('SCHEMAID'))
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User privileges */
select ur.name, ue.name, u.name, u.name, upm.name,
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and (ua.grantor# = userenv('SCHEMAID') or
       ua.grantee# in (select kzsrorol from x$kzsro) or
       ua.user# = userenv('SCHEMAID'))
  and bitand(ua.option$,64) = 64
/
comment on table ALL_TAB_PRIVS is
'Grants on objects for which the user is the grantor, grantee, owner,
 or an enabled role or PUBLIC is the grantee'
/
comment on column ALL_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS.TABLE_SCHEMA is
'Schema of the object'
/
comment on column ALL_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column ALL_TAB_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_TAB_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_TAB_PRIVS for ALL_TAB_PRIVS
/
grant read on ALL_TAB_PRIVS to PUBLIC with grant option
/
create or replace view DBA_TAB_PRIVS
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       66, 'SCHEDULER JOB',
                       68, 'JOB CLASS',
                       74, 'SCHEDULE',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(nvl(oa.option$, 0), 4) = 0
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       48, 'RESOURCE CONSUMER GROUP',
                       57, 'EDITION',
                       66, 'SCHEDULER JOB',
                       68, 'JOB CLASS',
                       74, 'SCHEDULE',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(oa.option$,8) = 8
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       48, 'RESOURCE CONSUMER GROUP',
                       57, 'EDITION',
                       66, 'SCHEDULER JOB',
                       68, 'JOB CLASS',
                       74, 'SCHEDULE',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and u.user# = o.owner#
  and bitand(oa.option$,64) = 64
  and (o.type# <> 13 or (o.type# = 13 and o.subname is null))
                                                      /* latest type version */
union all
/* Locally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name,
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name,
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name,
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and bitand(ua.option$,64) = 64
/
create or replace public synonym DBA_TAB_PRIVS for DBA_TAB_PRIVS
/
grant select on DBA_TAB_PRIVS to select_catalog_role
/
comment on table DBA_TAB_PRIVS is
'All grants on objects in the database'
/
comment on column DBA_TAB_PRIVS.GRANTEE is
'User to whom access was granted'
/
comment on column DBA_TAB_PRIVS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_PRIVS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_PRIVS.GRANTOR is
'Name of the user who performed the grant'
/
comment on column DBA_TAB_PRIVS.PRIVILEGE is
'Table Privilege'
/
comment on column DBA_TAB_PRIVS.GRANTABLE is
'Privilege is grantable'
/
comment on column DBA_TAB_PRIVS.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column DBA_TAB_PRIVS.COMMON is
'Privilege was granted commonly'
/
comment on column DBA_TAB_PRIVS.INHERITED is
'Was privilege grant inherited from another container'
/

execute CDBView.create_cdbview(false,'SYS','DBA_TAB_PRIVS','CDB_TAB_PRIVS');
grant select on SYS.CDB_TAB_PRIVS to select_catalog_role
/
create or replace public synonym CDB_TAB_PRIVS for SYS.CDB_TAB_PRIVS
/

remark
remark  FAMILY "TAB_PRIVS_MADE"
remark  Grants made on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_MADE
      (GRANTEE, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ue.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY',
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ ue, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and o.owner# = userenv('SCHEMAID')
  and bitand(oa.option$,64) = 64
union all
/* Locally granted User privileges */
select ue.name, u.name, ur.name,
       upm.name, 
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select ue.name, u.name, ur.name,
       upm.name, 
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User privileges */
select ue.name, u.name, ur.name,
       upm.name, 
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(ua.option$,64) = 64
/
comment on table USER_TAB_PRIVS_MADE is
'All grants on objects owned by the user'
/
comment on column USER_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column USER_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column USER_TAB_PRIVS_MADE.COMMON is
'Privilege was granted commonly'
/
comment on column USER_TAB_PRIVS_MADE.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_TAB_PRIVS_MADE for USER_TAB_PRIVS_MADE
/
grant read on USER_TAB_PRIVS_MADE to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_MADE
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE',
                      150, 'HIERARCHY',
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and userenv('SCHEMAID') in (o.owner#, oa.grantor#)
  and bitand(oa.option$,64) = 64
union all
/* Locally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(nvl(ua.option$, 0), 8) = 8
union all
/* Federationally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.user# = userenv('SCHEMAID')
  and bitand(nvl(ua.option$, 0), 64) = 64
/
comment on table ALL_TAB_PRIVS_MADE is
'User''s grants and grants on user''s objects'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_MADE.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_MADE.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_MADE.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_MADE.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_MADE.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column ALL_TAB_PRIVS_MADE.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_TAB_PRIVS_MADE.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_TAB_PRIVS_MADE for ALL_TAB_PRIVS_MADE
/
grant read on ALL_TAB_PRIVS_MADE to PUBLIC with grant option
/
remark
remark  FAMILY "TAB_PRIVS_RECD"
remark  Grants received on objects.
remark  This family has no DBA member.
remark
create or replace view USER_TAB_PRIVS_RECD
      (OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select u.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# = userenv('SCHEMAID')
  and bitand(oa.option$,64) = 64
union all
/* Locally granted User privileges */
select 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# = userenv('SCHEMAID')
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# = userenv('SCHEMAID')
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User privileges */
select 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# = userenv('SCHEMAID')
  and bitand(ua.option$,64) = 64
/
comment on table USER_TAB_PRIVS_RECD is
'Grants on objects for which the user is the grantee'
/
comment on column USER_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column USER_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column USER_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column USER_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column USER_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column USER_TAB_PRIVS_RECD.COMMON is
'Privilege was granted commonly'
/
comment on column USER_TAB_PRIVS_RECD.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym USER_TAB_PRIVS_RECD for USER_TAB_PRIVS_RECD
/
grant read on USER_TAB_PRIVS_RECD to PUBLIC with grant option
/
create or replace view ALL_TAB_PRIVS_RECD
      (GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE, GRANTABLE, HIERARCHY, 
       COMMON, TYPE, INHERITED)
as
/* Locally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(mod(oa.option$,2), 1, 'YES', 'NO'),
       decode(bitand(oa.option$,2), 2, 'YES', 'NO'), 'NO',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS', 
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       'NO'
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(nvl(oa.option$, 0), 4) = 0
union all
/* Commonly granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,16), 16, 'YES', 'NO'),
       decode(bitand(oa.option$,32), 32, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(oa.option$,8) = 8
union all
/* Federationally granted Privileges */
select ue.name, u.name, o.name, 
       ur.name, tpm.name,
       decode(bitand(oa.option$,128), 128, 'YES', 'NO'),
       decode(bitand(oa.option$,256), 256, 'YES', 'NO'), 'YES',
       decode (o.type#, 1, 'INDEX',
                        2, 'TABLE',
                        3, 'CLUSTER',
                        4, 'VIEW',
                        5, 'SYNONYM',
                        6, 'SEQUENCE',
                        7, 'PROCEDURE',
                        8, 'FUNCTION',
                        9, 'PACKAGE',
                       10, 'NON-EXISTENT',
                       11, 'PACKAGE BODY',
                       12, 'TRIGGER',
                       13, 'TYPE',
                       14, 'TYPE BODY',
                       19, 'TABLE PARTITION',
                       20, 'INDEX PARTITION',
                       21, 'LOB',
                       22, 'LIBRARY',
                       23, 'DIRECTORY',
                       24, 'QUEUE',
                       25, 'IOT',
                       26, 'REPLICATION OBJECT GROUP',
                       27, 'REPLICATION PROPAGATOR',
                       28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       31, 'JAVA JAR',
                       32, 'INDEXTYPE',
                       33, 'OPERATOR',
                       34, 'TABLE SUBPARTITION',
                       35, 'INDEX SUBPARTITION',
                       57, 'EDITION',
                       82, '(Data Mining) MODEL',
                       92, 'CUBE DIMENSION',
                       93, 'CUBE',
                       94, 'MEASURE FOLDER',
                       95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 
                      101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE', 'UNKNOWN'),
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.objauth$ oa, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.user$ ur,
     sys.user$ ue, table_privilege_map tpm
where oa.obj# = o.obj#
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and oa.col# is null
  and oa.privilege# = tpm.privilege
  and oa.grantee# in (select kzsrorol from x$kzsro)
  and bitand(oa.option$,64) = 64
union all
/* Locally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,1), 1, 'YES', 'NO'), 
       'NO', 
       'NO', 
       'USER',
       'NO'
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# in (select kzsrorol from x$kzsro)
  and bitand(nvl(ua.option$, 0), 4) = 0
union all
/* Commonly granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,16), 16, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# in (select kzsrorol from x$kzsro)
  and bitand(ua.option$,8) = 8
union all
/* Federationally granted User privileges */
select ue.name, 'SYS', u.name,
       ur.name, upm.name, 
       decode(bitand(ua.option$,128), 128, 'YES', 'NO'), 
       'NO', 
       'YES', 
       'USER',
       decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 'YES', 'YES', 'NO')
from sys.userauth$ ua, sys.user$ u, sys.user$ ur,
     sys.user$ ue, sys.user_privilege_map upm
where ua.user# = u.user#
  and ua.grantor# = ur.user#
  and ua.grantee# = ue.user#
  and ua.privilege# = upm.privilege
  and ua.grantee# in (select kzsrorol from x$kzsro)
  and bitand(ua.option$,64) = 64
/
comment on table ALL_TAB_PRIVS_RECD is
'Grants on objects for which the user, PUBLIC or enabled role is the grantee'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column ALL_TAB_PRIVS_RECD.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_PRIVS_RECD.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTOR is
'Name of the user who performed the grant'
/
comment on column ALL_TAB_PRIVS_RECD.PRIVILEGE is
'Table Privilege'
/
comment on column ALL_TAB_PRIVS_RECD.GRANTABLE is
'Privilege is grantable'
/
comment on column ALL_TAB_PRIVS_RECD.HIERARCHY is
'Privilege is with hierarchy option'
/
comment on column ALL_TAB_PRIVS_RECD.COMMON is
'Privilege was granted commonly'
/
comment on column ALL_TAB_PRIVS_RECD.INHERITED is
'Was privilege grant inherited from another container'
/
create or replace public synonym ALL_TAB_PRIVS_RECD for ALL_TAB_PRIVS_RECD
/
grant read on ALL_TAB_PRIVS_RECD to PUBLIC with grant option
/


@?/rdbms/admin/sqlsessend.sql
 
