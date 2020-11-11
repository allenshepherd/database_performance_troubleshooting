Rem
Rem $Header: rdbms/admin/catgdtab.sql /main/10 2017/08/02 17:40:16 jemaldon Exp $
Rem
Rem catgdtab.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catgdtab.sql - Catalog scripts for Global Dictionary
Rem
Rem    DESCRIPTION
Rem      Defines objects needed for join groups
Rem
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catgdtab.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catgdtab.sql 
Rem    SQL_PHASE: CATGDTAB 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jemaldon    07/18/17 - Bug 26351822: add unique key to im_domain$
Rem    soumadat    04/19/17 - Bug 23093019: Global Dictionary decoupled from
Rem                           (objn,colid) structure
Rem    prgaharw    03/30/17 - b24624106: Use v$ in joingroups view for clarity
Rem    agsaha      01/13/17 - Bug 24706257 : Add PK-FK and unique key
Rem                           constraints in im_domain$ and im_joingroup$
Rem                           tables
Rem    wanma       11/15/16 - Bug 24826690: rename "segdict" with "globaldict"                  
Rem    prgaharw    08/19/16 - XbranchMerge prgaharw_bug-24426390 from
Rem                           st_rdbms_12.2.0.1.0
Rem    prgaharw    08/09/16 - b24426390: Add tabcompart$ to DBA_JOINGROUPS
Rem    prgaharw    03/02/16 - 22829534 - Remove unnecessary container id column
Rem    amylavar    01/01/16 - Add views
Rem    amylavar    04/09/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create sequence sys.im_domainseq$ increment by 1 start with 1 nocycle
/

create table im_joingroup$
(
  name          varchar2(128) not null,                   /* join group name */
  owner#        number not null,                             /* owner number */
  domain#       number not null,                            /* domain number */
  constraint    im_joingroup_pk primary key(domain#),
  constraint    im_joingroup_uk unique (name, owner#) 
)
/

create table im_domain$
(
  objn          number not null,                            /* object number */
  col#          number not null,                            /* column number */
  domain#       number not null,                            /* domain number */
  flags         number null,                                        /* flags */
  constraint    im_domain_fk foreign key(domain#) references 
                im_joingroup$(domain#) on delete cascade,
  constraint    im_domain_uk unique (objn, col#)
)
/

/* User join groups view */
create or replace view USER_JOINGROUPS
(JOINGROUP_NAME, TABLE_OWNER, TABLE_NAME, 
 COLUMN_NAME, FLAGS, GD_ADDRESS)
as
select JOINGROUP_NAME, TABLE_OWNER, TABLE_NAME, 
       COLUMN_NAME, a.FLAGS as FLAGS, b.head_address as GD_ADDRESS
from
(select id.objn, id.col#, jg.name as JOINGROUP_NAME, o.name as TABLE_NAME, 
        u1.name as TABLE_OWNER,
        oc.name as COLUMN_NAME, id.flags as FLAGS, id.domain# as domain#
   from im_domain$ id, im_joingroup$ jg, obj$ o, user$ u1, user$ u2,
        col$ oc
  where id.domain# = jg.domain# and
        id.flags = 1 and
        id.objn = o.obj# and
        u1.user# = o.owner# and 
        u2.user# = jg.owner# and 
        id.objn = oc.obj# and 
        id.col# = oc.segcol# and
        u2.user# = userenv('SCHEMAID')) a
left outer join
        v$im_globaldict b
    on a.domain# = b.domain#
/

comment on table USER_JOINGROUPS is
 'Join groups belonging to the user'
/
comment on column USER_JOINGROUPS.JOINGROUP_NAME is
 'Join group name'
/
comment on column USER_JOINGROUPS.TABLE_OWNER is
 'Table owner'
/
comment on column USER_JOINGROUPS.TABLE_NAME is
 'Table name'
/
comment on column USER_JOINGROUPS.COLUMN_NAME is
 'Column name'
/
comment on column USER_JOINGROUPS.FLAGS is
 'Flags'
/
comment on column USER_JOINGROUPS.GD_ADDRESS is
 'Global dictionary address'
/
grant read on USER_JOINGROUPS to public
/
create or replace public synonym user_joingroups for sys.user_joingroups
/

/* DBA join groups view */
create or replace view DBA_JOINGROUPS
(JOINGROUP_OWNER, JOINGROUP_NAME, TABLE_OWNER, TABLE_NAME, 
 COLUMN_NAME, FLAGS, GD_ADDRESS)
as
select JOINGROUP_OWNER, JOINGROUP_NAME, TABLE_OWNER, TABLE_NAME, 
       COLUMN_NAME, a.FLAGS as FLAGS, b.head_address as GD_ADDRESS
from
(select id.objn, id.col#, jg.name as JOINGROUP_NAME, o.name as TABLE_NAME, 
        u1.name as TABLE_OWNER, u2.name as JOINGROUP_OWNER,
        oc.name as COLUMN_NAME, id.flags as FLAGS,  id.domain# as domain#
   from im_domain$ id, im_joingroup$ jg, obj$ o, user$ u1, user$ u2,
        col$ oc
  where id.domain# = jg.domain# and
        id.flags = 1 and
        id.objn = o.obj# and
        u1.user# = o.owner# and 
        u2.user# = jg.owner# and 
        id.objn = oc.obj# and 
        id.col# = oc.segcol#) a
left outer join
        v$im_globaldict b 
     on a.domain# = b.domain#
/

comment on table DBA_JOINGROUPS is
 'Join groups in the database'
/
comment on column DBA_JOINGROUPS.JOINGROUP_OWNER is
 'Join group owner'
/
comment on column DBA_JOINGROUPS.JOINGROUP_NAME is
 'Join group name'
/
comment on column DBA_JOINGROUPS.TABLE_OWNER is
 'Table owner'
/
comment on column DBA_JOINGROUPS.TABLE_NAME is
 'Table name'
/
comment on column DBA_JOINGROUPS.COLUMN_NAME is
 'Column name'
/
comment on column DBA_JOINGROUPS.FLAGS is
 'Flags'
/
comment on column DBA_JOINGROUPS.GD_ADDRESS is
 'Global dictionary address'
/
grant select on DBA_JOINGROUPS to select_catalog_role
/
create or replace public synonym dba_joingroups for sys.dba_joingroups
/

execute CDBView.create_cdbview(false,'SYS','DBA_JOINGROUPS','CDB_JOINGROUPS');
grant select on SYS.CDB_JOINGROUPS to select_catalog_role
/
create or replace public synonym CDB_JOINGROUPS for SYS.CDB_JOINGROUPS
/

@?/rdbms/admin/sqlsessend.sql
