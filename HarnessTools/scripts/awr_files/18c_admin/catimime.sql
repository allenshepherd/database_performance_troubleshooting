Rem
Rem $Header: rdbms/admin/catimime.sql /main/4 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catimime.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catimime.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Views for In-Memory Expressions feature
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catimime.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catimime.sql 
Rem    SQL_PHASE: CATIMIME
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    aumishra    01/04/17 - Add IME dictionary table
Rem    aumishra    08/05/16 - XbranchMerge aumishra_expcap from
Rem                           st_rdbms_12.2.0.1.0
Rem    aumishra    07/26/16 - Bug 24336479: Fix con_id predicate in views
Rem    aumishra    04/26/16 - Bug 23177430: Add views to see captured IME list
Rem    aumishra    04/26/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/* In-Memory Expression Dictionary Table */

create table im_ime$
(
  action_name   varchar2(100) not null,/* Action name, e.g. "WINDOW CAPTURE" */
  action_state  varchar2(10)  not null,   /* Action state, e.g. "OPEN/CLOSE" */
  last_modified timestamp     not null
)
/

insert into im_ime$ values ('CAPTURE WINDOW', 'DEFAULT', systimestamp)
/

commit;

/* In-Memory Expression Views */

/* USER_IM_EXPRESSIONS: USER view to obtain list of auto-captured expressions
   currently enabled for in-memory storage for tables owned by the user */
create or replace view USER_IM_EXPRESSIONS
(TABLE_NAME, OBJECT_NUMBER, COLUMN_NAME, SQL_EXPRESSION)
as
(select a.TABLE_NAME, a.OBJN as OBJECT_NUMBER, b.NAME as COLUMN_NAME, 
        b.DEFAULT$ as SQL_EXPRESSION
   from sys.x$kdzcolcl a, sys.col$ b, sys.obj$ o
   where a.objn = o.obj# and
         o.owner# = userenv('SCHEMAID') and
         a.con_id in (select SYS_CONTEXT('USERENV', 'CON_ID') from sys.dual) and
         a.objn = b.obj# and
         a.internal_column_id = b.intcol# and
         b.name like 'SYS!_IME%' escape '!' and
         b.name not like 'SYS!_IME!_OSON!_%' escape '!' and
         a.inmemory_compression in ('DEFAULT', 'NO MEMCOMPRES', 'FOR DML',
                                    'FOR QUERY LOW', 'FOR QUERY HIGH',
                                    'FOR CAPACITY LOW', 'FOR CAPACITY HIGH'))
order by a.table_name, b.name;
/

comment on table USER_IM_EXPRESSIONS is
'Automatically captured expressions enabled for in-memory storage'
/
comment on column USER_IM_EXPRESSIONS.TABLE_NAME is
'Table name'
/
comment on column USER_IM_EXPRESSIONS.OBJECT_NUMBER is
'Object number'
/
comment on column USER_IM_EXPRESSIONS.COLUMN_NAME is
'Column name of auto-captured in-memory expression'
/
comment on column USER_IM_EXPRESSIONS.SQL_EXPRESSION is
'Expression text'
/
grant read on USER_IM_EXPRESSIONS to PUBLIC with grant option
/
create or replace public synonym USER_IM_EXPRESSIONS for SYS.USER_IM_EXPRESSIONS
/

/* DBA_IM_EXPRESSIONS: DBA view to obtain list of auto-captured expressions
                       currently enabled for in-memory storage */
create or replace view DBA_IM_EXPRESSIONS
(OWNER, TABLE_NAME, OBJECT_NUMBER, COLUMN_NAME, SQL_EXPRESSION)
as
(select a.OWNER, a.TABLE_NAME, a.OBJN as OBJECT_NUMBER, 
        b.NAME as COLUMN_NAME, b.DEFAULT$ as SQL_EXPRESSION
   from sys.x$kdzcolcl a, sys.col$ b
   where a.objn = b.obj# and
         a.internal_column_id = b.intcol# and
         a.con_id in (select SYS_CONTEXT('USERENV', 'CON_ID') from sys.dual) and
         b.name like 'SYS!_IME%' escape '!' and
         b.name not like 'SYS!_IME!_OSON!_%' escape '!' and
         a.inmemory_compression in ('DEFAULT', 'NO MEMCOMPRES', 'FOR DML',
                                    'FOR QUERY LOW', 'FOR QUERY HIGH',
                                    'FOR CAPACITY LOW', 'FOR CAPACITY HIGH'))  
order by a.owner, a.table_name, b.name;
/

comment on table DBA_IM_EXPRESSIONS is
'Automatically captured expressions enabled for in-memory storage'
/
comment on column DBA_IM_EXPRESSIONS.OWNER is
'Table owner'
/
comment on column DBA_IM_EXPRESSIONS.TABLE_NAME is
'Table name'
/
comment on column DBA_IM_EXPRESSIONS.OBJECT_NUMBER is
'Object number'
/
comment on column DBA_IM_EXPRESSIONS.COLUMN_NAME is
'Column name of auto-captured in-memory expression'
/
comment on column DBA_IM_EXPRESSIONS.SQL_EXPRESSION is
'Expression text'
/
grant select on DBA_IM_EXPRESSIONS to select_catalog_role
/
create or replace public synonym DBA_IM_EXPRESSIONS for SYS.DBA_IM_EXPRESSIONS
/

@?/rdbms/admin/sqlsessend.sql
