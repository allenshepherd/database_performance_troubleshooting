Rem
Rem $Header: rdbms/admin/catapp_mig.sql /main/1 2015/04/02 11:20:57 huntran Exp $
Rem
Rem catapp_mig.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catapp_mig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catapp_mig.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catapp_mig.sql
Rem    SQL_PHASE: CATAPP_MIG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catapp.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huntran     03/05/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- view "_DBA_GG_AUTO_CDR_TABLES"
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(100);
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='TAB$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='ACDRROWTSINTCOL#';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    use_new_cols := TRUE;
  end if;

  execute immediate q'!
create or replace force view "_DBA_GG_AUTO_CDR_TABLES"
  (table_owner, table_name, acdrflags, tombstone_table, row_resolution_column,
   acdrdefaulttime)
as select !' ||
case when use_new_cols THEN
'u.name, o.name, t.acdrflags,
          o2.name,
          c.name,
          t.acdrdefaulttime
from sys.tab$ t, sys.col$ c, sys.user$ u, sys.obj$ o, sys.obj$ o2
where bitand(t.acdrflags, 1) = 1 /* auto cdr enabled */
      and t.obj# = o.obj# and u.user# = o.owner#
      and t.obj# = c.obj# and t.acdrrowtsintcol# = c.intcol#
      and t.acdrtsobj# = o2.obj#(+)'
else
  'null, null, null, null, null, null from dual where 1 = 0'
end;

exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

-- view "_DBA_GG_AUTO_CDR_COLUMNS"
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(100);
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='ACDRRESCOL#';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    use_new_cols := TRUE;
  end if;

  execute immediate q'!
create or replace force view "_DBA_GG_AUTO_CDR_COLUMNS"
  (table_owner, table_name, column_group_name, column_name, resolution_column)
as select  !' ||
case when use_new_cols THEN
q'!u.name,  o.name,
   nvl(cg.column_group_name, 'IMPLICIT_COLUMNS$'),
   c.name, c2.name
from sys.tab$ t, sys.obj$ o, sys.user$ u, sys.col$ c, sys.col$ c2,
     sys.apply$_auto_cdr_column_groups cg
where t.obj# = o.obj# and o.owner# = u.user# and
      bitand(acdrflags, 1) = 1 /* auto cdr enabled */
      and c.obj# = c2.obj#
      and c.acdrrescol# = c2.INTCOL# /* has resolution col */
      and c.obj# = t.obj#
      and cg.obj#(+)= t.obj#
      and cg.column_group_id(+) = c2.INTCOL#
union
select u.name,  o.name, 'DELTA$', c.name, NULL
from sys.tab$ t, sys.obj$ o, sys.user$ u, sys.col$ c
where t.obj# = o.obj# and o.owner# = u.user# and
      bitand(acdrflags, 1) = 1 /* auto cdr enabled */
      and c.acdrrescol# = 10000 /* delta */
      and c.obj# = t.obj#!'
else
  'null, null, null, null, null from dual where 1 = 0'
end;

exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
