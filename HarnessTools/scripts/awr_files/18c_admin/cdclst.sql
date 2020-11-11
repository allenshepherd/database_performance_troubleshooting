Rem
Rem $Header: rdbms/admin/cdclst.sql /main/10 2017/01/21 02:46:24 youjuki Exp $
Rem
Rem catclst.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdclst.sql - defines views for clustering clause of a table
Rem
Rem    DESCRIPTION
Rem      Oracle 12.1 provides a clustering clause on a table see:
Rem      project 35621. For example  
Rem         CREATE TABLE t1 (c1 NUMBER, c2 number, c3 NUMBER)
Rem         CLUSTERING BY DIMENSIONS (c1, c2)
Rem
Rem      This file provides dictionary views for the clustering clause of
Rem      a table
Rem
Rem    NOTES
Rem      Must be run while connectd as SYS or INTERNAL
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdclst.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdclst.sql
Rem SQL_PHASE: CDCLST
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youjuki     01/17/17 - bug 24923302: Fix in DBA_CLUSTERING_JOINS
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    mziauddi    03/04/14 - #(18316994) add WITH_ZONEMAP column to
Rem                           *_CLUSTERING_TABLES views
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jnarasin    10/28/11 - dont show tables from recycle bin
Rem    awitkows    09/20/11 - rename multidimensional to interleaved
Rem    awitkows    07/12/11 - add valid flag
Rem    jnarasin    05/13/11 - Add Clustering views
Rem    awitkows    04/11/11 - dictionary views for table clustering clause
Rem    awitkows    04/11/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

rem DBA_CLUSTERING_TABLES
rem bitand(o.flags, 128) = 0 condition is used to determine if the table
rem is part of recycle bin

create or replace view DBA_CLUSTERING_TABLES
   (owner, table_name, clustering_type, on_load, on_datamovement, valid, 
    with_zonemap, last_load_clst, last_datamove_clst)
as
select u.name, o.name, 
  case when c.clstfunc = 1 then 'INTERLEAVED'
       else 'LINEAR'
  end,
  decode(bitand(c.flags, 1), 0, 'NO', 'YES'),
  decode(bitand(c.flags, 2), 0, 'NO', 'YES'),
  decode(bitand(c.flags, 4), 0, 'YES', 'NO'),
  decode(bitand(c.flags, 8), 0, 'NO', 'YES'),
  clstlastload,
  clstlastdm
from sys.user$ u, sys.clst$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = c.clstobj#
  and bitand(o.flags, 128) = 0
/
comment on table DBA_CLUSTERING_TABLES is
'Description of the clustering clause of tables accessible to dba'
/
comment on column DBA_CLUSTERING_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_CLUSTERING_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_CLUSTERING_TABLES.CLUSTERING_TYPE is
'Clustering type'
/
comment on column DBA_CLUSTERING_TABLES.ON_LOAD is
'Will Oracle cluster data on load'
/
comment on column DBA_CLUSTERING_TABLES.ON_DATAMOVEMENT is
'Will Oracle cluster data on data movement, for example partition move'
/
comment on column DBA_CLUSTERING_TABLES.VALID is
'Is clustering valid. It is invalid if dimension does not have pk/uk constraint'
/
comment on column DBA_CLUSTERING_TABLES.WITH_ZONEMAP is
'Is a zonemap also created with clustering'
/
comment on column DBA_CLUSTERING_TABLES.LAST_LOAD_CLST is
'Last time the clustering occured on load'
/
comment on column DBA_CLUSTERING_TABLES.LAST_DATAMOVE_CLST is
'Last time the clustering occured on data movement, for example partition move'
/
create or replace public synonym DBA_CLUSTERING_TABLES for DBA_CLUSTERING_TABLES
/
grant select on DBA_CLUSTERING_TABLES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTERING_TABLES','CDB_CLUSTERING_TABLES');
grant select on SYS.CDB_CLUSTERING_TABLES to select_catalog_role
/
create or replace public synonym CDB_CLUSTERING_TABLES for SYS.CDB_CLUSTERING_TABLES
/

rem USER_CLUSTERING_TABLES

create or replace view USER_CLUSTERING_TABLES
   (owner, table_name, clustering_type, on_load, on_datamovement, valid, 
    with_zonemap, last_load_clst, last_datamove_clst)
as 
select owner, table_name, clustering_type, on_load, on_datamovement, valid, 
       with_zonemap, last_load_clst, last_datamove_clst
from   DBA_CLUSTERING_TABLES
WHERE  OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_CLUSTERING_TABLES is
'Description of the clustering clause of tables created by the user'
/
comment on column USER_CLUSTERING_TABLES.OWNER is
'Owner of the table'
/
comment on column USER_CLUSTERING_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_CLUSTERING_TABLES.CLUSTERING_TYPE is
'Clustering type'
/
comment on column USER_CLUSTERING_TABLES.ON_LOAD is
'Will Oracle cluster data on load'
/
comment on column USER_CLUSTERING_TABLES.ON_DATAMOVEMENT is
'Will Oracle cluster data on data movement, for example partition move'
/
comment on column USER_CLUSTERING_TABLES.VALID is
'Is clustering valid. It is invalid if dimension does not have pk/uk constraint'
/
comment on column USER_CLUSTERING_TABLES.WITH_ZONEMAP is
'Is a zonemap also created with clustering'
/
comment on column USER_CLUSTERING_TABLES.LAST_LOAD_CLST is
'Last time the clustering occured on load'
/
comment on column USER_CLUSTERING_TABLES.LAST_DATAMOVE_CLST is
'Last time the clustering occured on data movement, for example partition move'
/
create or replace public synonym USER_CLUSTERING_TABLES for USER_CLUSTERING_TABLES
/
grant read on USER_CLUSTERING_TABLES to PUBLIC
/

rem ALL_CLUSTERING_TABLES

create or replace view ALL_CLUSTERING_TABLES
   (owner, table_name, clustering_type, on_load, on_datamovement, valid, 
    with_zonemap, last_load_clst, last_datamove_clst)
as 
select c.owner, c.table_name, c.clustering_type, c.on_load, c.on_datamovement, 
       c.valid, c.with_zonemap, c.last_load_clst, c.last_datamove_clst
from   DBA_CLUSTERING_TABLES c, ALL_TABLES t
WHERE  c.OWNER = t.OWNER 
AND    c.TABLE_NAME = t.TABLE_NAME
/
comment on table ALL_CLUSTERING_TABLES is
'Description of the clustering clause of tables accessible to the user'
/
comment on column ALL_CLUSTERING_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_CLUSTERING_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_CLUSTERING_TABLES.CLUSTERING_TYPE is
'Clustering type'
/
comment on column ALL_CLUSTERING_TABLES.ON_LOAD is
'Will Oracle cluster data on load'
/
comment on column ALL_CLUSTERING_TABLES.ON_DATAMOVEMENT is
'Will Oracle cluster data on data movement, for example partition move'
/
comment on column ALL_CLUSTERING_TABLES.VALID is
'Is clustering valid. It is invalid if dimension does not have pk/uk constraint'
/
comment on column ALL_CLUSTERING_TABLES.WITH_ZONEMAP is
'Is a zonemap also created with clustering'
/
comment on column ALL_CLUSTERING_TABLES.LAST_LOAD_CLST is
'Last time the clustering occured on load'
/
comment on column ALL_CLUSTERING_TABLES.LAST_DATAMOVE_CLST is
'Last time the clustering occured on data movement, for example partition move'
/
create or replace public synonym ALL_CLUSTERING_TABLES for ALL_CLUSTERING_TABLES
/
grant read on ALL_CLUSTERING_TABLES to PUBLIC
/

Rem DBA_CLUSTERING_KEYS
rem bitand(o.flags, 128) = 0 condition is used to determine if the table
rem is part of recycle bin

create or replace view DBA_CLUSTERING_KEYS
   (owner, table_name, detail_owner, detail_name, detail_column, 
    position, groupid)
as 
select u1.name, o1.name,  u2.name, o2.name, c.name, k.position, k.groupid
from sys.user$ u1, sys.clstkey$ k, sys.obj$ o1,
     sys.user$ u2, sys.obj$ o2, sys.col$ c
where o1.owner# = u1.user#
  and o1.obj# = k.clstobj#
  and o2.owner# = u2.user#
  and o2.obj# = k.tabobj#
  and c.obj# = k.tabobj#
  and c.intcol# = k.intcol#
  and bitand(o1.flags, 128) = 0
  and bitand(o2.flags, 128) = 0
/
comment on table DBA_CLUSTERING_KEYS is
'Description of the keys of the clustering clause of tables accessible to dba'
/
comment on column DBA_CLUSTERING_KEYS.OWNER is
'Owner of the table on which clustering clause is defined'
/
comment on column DBA_CLUSTERING_KEYS.TABLE_NAME is
'Name of the table on which clustering clause is defined'
/
comment on column DBA_CLUSTERING_KEYS.DETAIL_OWNER is
'Owner of the detailed table contributing to the clustering keys'
/
comment on column DBA_CLUSTERING_KEYS.DETAIL_NAME is
'Name of the detailed table contributing to the clustering keys'
/
comment on column DBA_CLUSTERING_KEYS.POSITION is
'Name of the detailed table column for the clustering keys'
/
comment on column DBA_CLUSTERING_KEYS.POSITION is
'Position of the column in the clustering clause'
/
comment on column DBA_CLUSTERING_KEYS.GROUPID is
'Group of the column in the clustering clause'
/
create or replace public synonym DBA_CLUSTERING_KEYS for DBA_CLUSTERING_KEYS
/
grant select on DBA_CLUSTERING_KEYS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTERING_KEYS','CDB_CLUSTERING_KEYS');
grant select on SYS.CDB_CLUSTERING_KEYS to select_catalog_role
/
create or replace public synonym CDB_CLUSTERING_KEYS for SYS.CDB_CLUSTERING_KEYS
/

Rem USER_CLUSTERING_KEYS

create or replace view USER_CLUSTERING_KEYS
   (owner, table_name, detail_owner, detail_name, detail_column, 
    position, groupid)
as 
select owner, table_name, detail_owner, detail_name, detail_column, 
       position, groupid
from DBA_CLUSTERING_KEYS
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_CLUSTERING_KEYS is
'Description of the keys of the clustering clause of tables created by the user'
/
comment on column USER_CLUSTERING_KEYS.OWNER is
'Owner of the table on which clustering clause is defined'
/
comment on column USER_CLUSTERING_KEYS.TABLE_NAME is
'Name of the table on which clustering clause is defined'
/
comment on column USER_CLUSTERING_KEYS.DETAIL_OWNER is
'Owner of the detailed table contributing to the clustering keys'
/
comment on column USER_CLUSTERING_KEYS.DETAIL_NAME is
'Name of the detailed table contributing to the clustering keys'
/
comment on column USER_CLUSTERING_KEYS.POSITION is
'Name of the detailed table column for the clustering keys'
/
comment on column USER_CLUSTERING_KEYS.POSITION is
'Position of the column in the clustering clause'
/
comment on column USER_CLUSTERING_KEYS.GROUPID is
'Group of the column in the clustering clause'
/
create or replace public synonym USER_CLUSTERING_KEYS for USER_CLUSTERING_KEYS
/
grant read on USER_CLUSTERING_KEYS to PUBLIC
/

Rem ALL_CLUSTERING_KEYS

create or replace view ALL_CLUSTERING_KEYS
   (owner, table_name, detail_owner, detail_name, detail_column, 
    position, groupid)
as 
select k.owner, k.table_name, k.detail_owner, k.detail_name, k.detail_column, 
       k.position, k.groupid
from   DBA_CLUSTERING_KEYS k, ALL_TABLES t
WHERE  k.OWNER = t.OWNER 
AND    k.TABLE_NAME = t.TABLE_NAME
/ 
comment on table ALL_CLUSTERING_KEYS is
'Description of the keys of the clustering clause of tables accessible to the user'
/
comment on column ALL_CLUSTERING_KEYS.OWNER is
'Owner of the table on which clustering clause is defined'
/
comment on column ALL_CLUSTERING_KEYS.TABLE_NAME is
'Name of the table on which clustering clause is defined'
/
comment on column ALL_CLUSTERING_KEYS.DETAIL_OWNER is
'Owner of the detailed table contributing to the clustering keys'
/
comment on column ALL_CLUSTERING_KEYS.DETAIL_NAME is
'Name of the detailed table contributing to the clustering keys'
/
comment on column ALL_CLUSTERING_KEYS.POSITION is
'Name of the detailed table column for the clustering keys'
/
comment on column ALL_CLUSTERING_KEYS.POSITION is
'Position of the column in the clustering clause'
/
comment on column ALL_CLUSTERING_KEYS.GROUPID is
'Group of the column in the clustering clause'
/
create or replace public synonym ALL_CLUSTERING_KEYS for ALL_CLUSTERING_KEYS
/
grant read on ALL_CLUSTERING_KEYS to PUBLIC
/


REM
REM dba_clustering_dimensions view on clstdimension$
REM bitand(o.flags, 128) = 0 condition is used to determine if the table
REM is part of recycle bin
REM

create or replace view DBA_CLUSTERING_DIMENSIONS 
  (OWNER, TABLE_NAME, DIMENSION_OWNER, DIMENSION_NAME) 
as
select u.NAME, o.NAME, u2.NAME, o2.NAME
from   USER$ u, OBJ$ o, USER$ u2, OBJ$ o2, CLSTDIMENSION$ d
where  u.USER#    = o.OWNER#
and    d.CLSTOBJ# = o.OBJ#
and    u2.USER#   = o2.OWNER#
and    d.TABOBJ#  = o2.OBJ#
and    bitand(o.FLAGS,  128) = 0
and    bitand(o2.FLAGS, 128) = 0
/
comment on table DBA_CLUSTERING_DIMENSIONS is
'All dimension details about clustering tables in the database'
/
comment on column DBA_CLUSTERING_DIMENSIONS.OWNER is
'Owner of the clustering table'
/
comment on column DBA_CLUSTERING_DIMENSIONS.TABLE_NAME is
'Name of the clustering table'
/
comment on column DBA_CLUSTERING_DIMENSIONS.DIMENSION_OWNER is
'Owner of the dimension table'
/
comment on column DBA_CLUSTERING_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension table'
/
create or replace public synonym DBA_CLUSTERING_DIMENSIONS for DBA_CLUSTERING_DIMENSIONS
/
grant select on DBA_CLUSTERING_DIMENSIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTERING_DIMENSIONS','CDB_CLUSTERING_DIMENSIONS');
grant select on SYS.CDB_CLUSTERING_DIMENSIONS to select_catalog_role
/
create or replace public synonym CDB_CLUSTERING_DIMENSIONS for SYS.CDB_CLUSTERING_DIMENSIONS
/

REM
REM all_clustering_dimensions view on clstdimension$
REM

create or replace view ALL_CLUSTERING_DIMENSIONS 
  (OWNER, TABLE_NAME, DIMENSION_OWNER, DIMENSION_NAME) 
as
select d.OWNER, d.TABLE_NAME, d.DIMENSION_OWNER, d.DIMENSION_NAME
from   DBA_CLUSTERING_DIMENSIONS d, ALL_TABLES t
WHERE  d.OWNER = t.OWNER 
AND    d.TABLE_NAME = t.TABLE_NAME
/ 
comment on table ALL_CLUSTERING_DIMENSIONS is
'All dimension details about clustering tables the user owns or has system privileges'
/
comment on column ALL_CLUSTERING_DIMENSIONS.OWNER is
'Owner of the clustering table'
/
comment on column ALL_CLUSTERING_DIMENSIONS.TABLE_NAME is
'Name of the clustering table'
/
comment on column ALL_CLUSTERING_DIMENSIONS.DIMENSION_OWNER is
'Owner of the dimension table'
/
comment on column ALL_CLUSTERING_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension table'
/
create or replace public synonym ALL_CLUSTERING_DIMENSIONS for ALL_CLUSTERING_DIMENSIONS
/
grant read on ALL_CLUSTERING_DIMENSIONS to PUBLIC
/

REM
REM user_clustering_dimensions view on clstdimension$
REM

create or replace view USER_CLUSTERING_DIMENSIONS 
  (TABLE_NAME, DIMENSION_OWNER, DIMENSION_NAME) 
as
select d.TABLE_NAME, d.DIMENSION_OWNER, d.DIMENSION_NAME
from   DBA_CLUSTERING_DIMENSIONS d
WHERE  d.OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/ 
comment on table USER_CLUSTERING_DIMENSIONS is
'All dimension details about clustering tables owned by the user'
/
comment on column USER_CLUSTERING_DIMENSIONS.TABLE_NAME is
'Name of the clustering table'
/
comment on column DBA_CLUSTERING_DIMENSIONS.DIMENSION_OWNER is
'Owner of the dimension table'
/
comment on column DBA_CLUSTERING_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension table'
/
create or replace public synonym USER_CLUSTERING_DIMENSIONS for USER_CLUSTERING_DIMENSIONS
/
grant read on USER_CLUSTERING_DIMENSIONS to PUBLIC
/

REM
REM dba_clustering_joins view on clstjoin$
REM bitand(o.flags, 128) = 0 condition is used to determine if the table
REM is part of recycle bin
REM

create or replace view DBA_CLUSTERING_JOINS
  (OWNER, TABLE_NAME, TAB1_OWNER, TAB1_NAME, TAB1_COLUMN, 
   TAB2_OWNER, TAB2_NAME, TAB2_COLUMN)
as
select u.NAME, o.NAME, u2.NAME, o2.NAME, c2.NAME, u3.NAME, o3.NAME, c3.NAME
from   USER$ u, OBJ$ o, USER$ u2, OBJ$ o2, COL$ c2, USER$ u3, OBJ$ o3, COL$ c3, 
       CLSTJOIN$ j
where  u.USER#     = o.OWNER#
and    j.CLSTOBJ#  = o.OBJ#
and    u2.USER#    = o2.OWNER#
and    j.TAB1OBJ#  = o2.OBJ#
and    j.TAB1OBJ#  = c2.OBJ#
and    j.INT1COL#  = c2.INTCOL#
and    u3.USER#    = o3.OWNER#
and    j.TAB2OBJ#  = o3.OBJ#
and    j.TAB2OBJ#  = c3.OBJ#
and    j.INT2COL#  = c3.INTCOL#
and    bitand(o.FLAGS,  128) = 0
and    bitand(o2.FLAGS, 128) = 0
and    bitand(o3.FLAGS, 128) = 0
/
comment on table DBA_CLUSTERING_JOINS is
'All join details about clustering tables in the database'
/
comment on column DBA_CLUSTERING_JOINS.OWNER is
'Owner of the clustering table'
/
comment on column DBA_CLUSTERING_JOINS.TABLE_NAME is
'Name of the clustering table'
/
comment on column DBA_CLUSTERING_JOINS.TAB1_OWNER is
'Owner of the first dimension table'
/
comment on column DBA_CLUSTERING_JOINS.TAB1_NAME is
'Name of the first dimension table'
/
comment on column DBA_CLUSTERING_JOINS.TAB1_COLUMN is
'Name of the first dimension table column'
/
comment on column DBA_CLUSTERING_JOINS.TAB2_OWNER is
'Owner of the second dimension table'
/
comment on column DBA_CLUSTERING_JOINS.TAB2_NAME is
'Name of the second dimension table'
/
comment on column DBA_CLUSTERING_JOINS.TAB2_COLUMN is
'Name of the second dimension table column'
/
create or replace public synonym DBA_CLUSTERING_JOINS for DBA_CLUSTERING_JOINS
/
grant select on DBA_CLUSTERING_JOINS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTERING_JOINS','CDB_CLUSTERING_JOINS');
grant select on SYS.CDB_CLUSTERING_JOINS to select_catalog_role
/
create or replace public synonym CDB_CLUSTERING_JOINS for SYS.CDB_CLUSTERING_JOINS
/

REM
REM all_clustering_joins view on clstjoin$
REM

create or replace view ALL_CLUSTERING_JOINS
  (OWNER, TABLE_NAME, TAB1_OWNER, TAB1_NAME, TAB1_COLUMN, 
   TAB2_OWNER, TAB2_NAME, TAB2_COLUMN)
as
select j.OWNER, j.TABLE_NAME, j.TAB1_OWNER, j.TAB1_NAME, 
       j.TAB1_COLUMN, j.TAB2_OWNER, j.TAB2_NAME, 
       j.TAB2_COLUMN
from   DBA_CLUSTERING_JOINS j, ALL_TABLES t
WHERE  j.OWNER = t.OWNER 
AND    j.TABLE_NAME = t.TABLE_NAME
/ 
comment on table ALL_CLUSTERING_JOINS is
'All join details about clustering tables the user owns or has system privileges'
/
comment on column ALL_CLUSTERING_JOINS.OWNER is
'Owner of the clustering table'
/
comment on column ALL_CLUSTERING_JOINS.TABLE_NAME is
'Name of the clustering table'
/
comment on column ALL_CLUSTERING_JOINS.TAB1_OWNER is
'Owner of the first dimension table'
/
comment on column ALL_CLUSTERING_JOINS.TAB1_NAME is
'Name of the first dimension table'
/
comment on column ALL_CLUSTERING_JOINS.TAB1_COLUMN is
'Name of the first dimension table column'
/
comment on column ALL_CLUSTERING_JOINS.TAB2_OWNER is
'Owner of the second dimension table'
/
comment on column ALL_CLUSTERING_JOINS.TAB2_NAME is
'Name of the second dimension table'
/
comment on column ALL_CLUSTERING_JOINS.TAB2_COLUMN is
'Name of the second dimension table column'
/
create or replace public synonym ALL_CLUSTERING_JOINS for ALL_CLUSTERING_JOINS
/
grant read on ALL_CLUSTERING_JOINS to PUBLIC
/

REM
REM user_clustering_joins view on clstjoin$
REM

create or replace view USER_CLUSTERING_JOINS
  (TABLE_NAME, TAB1_OWNER, TAB1_NAME, TAB1_COLUMN, 
   TAB2_OWNER, TAB2_NAME, TAB2_COLUMN)
as
select j.TABLE_NAME, j.TAB1_OWNER, j.TAB1_NAME, 
       j.TAB1_COLUMN, j.TAB2_OWNER, j.TAB2_NAME, 
       j.TAB2_COLUMN
from   DBA_CLUSTERING_JOINS j
WHERE  j.OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/ 
comment on table USER_CLUSTERING_JOINS is
'All join details about clustering tables owned by the user'
/
comment on column USER_CLUSTERING_JOINS.TABLE_NAME is
'Name of the clustering table'
/
comment on column USER_CLUSTERING_JOINS.TAB1_OWNER is
'Owner of the first dimension table'
/
comment on column USER_CLUSTERING_JOINS.TAB1_NAME is
'Name of the first dimension table'
/
comment on column USER_CLUSTERING_JOINS.TAB1_COLUMN is
'Name of the first dimension table column'
/
comment on column USER_CLUSTERING_JOINS.TAB2_OWNER is
'Owner of the second dimension table'
/
comment on column USER_CLUSTERING_JOINS.TAB2_NAME is
'Name of the second dimension table'
/
comment on column USER_CLUSTERING_JOINS.TAB2_COLUMN is
'Name of the second dimension table column'
/
create or replace public synonym USER_CLUSTERING_JOINS for USER_CLUSTERING_JOINS
/
grant read on USER_CLUSTERING_JOINS to PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
