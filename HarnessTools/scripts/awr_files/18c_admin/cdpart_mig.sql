Rem
Rem $Header: rdbms/admin/cdpart_mig.sql /main/3 2017/08/03 17:44:03 wesmith Exp $
Rem
Rem cdpart_mig.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdpart_mig.sql - cdpart migration views
Rem
Rem    DESCRIPTION
Rem      Creates cdpart views whose definitions are dependent on columns in
Rem      bootstrap tables.
Rem
Rem    NOTES
Rem      Run from cdpart.sql and utlmmigtbls.sql.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdpart_mig.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdpart_mig.sql 
Rem    SQL_PHASE: CDPART_MIG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cdpart.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     08/07/17 - 22187143: fix dba_part_key_columns_v$,
Rem                           dba_subpart_key_columns_v$ for COLLATED_COLUMN_ID
Rem    traney      12/12/14 - 20184217: check for null linkname
Rem    wesmith     11/23/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- view user_part_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view user_part_key_columns_v$
  (NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ o, col$ c, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and c.obj#    = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union
select io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ io, col$ c, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
c.intcol# = pc.intcol# and io.owner# = userenv('SCHEMAID') and
  io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
  and io.subname IS NULL 
  and c.obj#    = a.obj#(+)
  and c.intcol# = a.intcol#(+)
  !';
exception
  when success_with_error then
    null;
end;
/

-- view all_part_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view all_part_key_columns_v$
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ o, col$ c, user$ u, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      c.obj#    = a.obj#(+) and c.intcol# = a.intcol#(+) and
      u.user# = o.owner# and o.subname IS NULL and 
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or pc.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union
select u.name, io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ io, col$ c, user$ u, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
     c.intcol# = pc.intcol# and u.user# = io.owner# and 
     c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
     io.subname IS NULL and
     io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
      (io.owner# = userenv('SCHEMAID')
       or i.bo# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  !';
exception
  when success_with_error then
    null;
end;
/

-- view dba_part_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view  !' ||
  case when propsrow_exists = 1 then '"DBA_PART_KEY_COLUMNS_V$_MIG"'
  else '"DBA_PART_KEY_COLUMNS_V$"' end || q'!
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ o, col$ c, user$ u, attrcol$ a
where pc.obj# = o.obj# and pc.obj# = c.obj# and c.intcol# = pc.intcol# and
      u.user# = o.owner# and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
      and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL 
      and o.subname IS NULL
union 
select u.name, io.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), pc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from partcol$ pc, obj$ io, col$ c, user$ u, ind$ i, attrcol$ a
where pc.obj# = i.obj# and i.obj# = io.obj# and i.bo# = c.obj# and 
        c.intcol# = pc.intcol# and u.user# = io.owner# 
        and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and
        io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
        and io.subname IS NULL
  !';
exception
  when success_with_error then
    null;
end;
/

-- view user_subpart_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view user_subpart_key_columns_v$
  (NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol# and o.owner# = userenv('SCHEMAID')
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.subname IS NULL
union
select o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, ind$ i, attrcol$ a
where  spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj#
       and c.intcol# = spc.intcol# and o.owner# = userenv('SCHEMAID')
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.subname IS NULL
  !';
exception
  when success_with_error then
    null;
end;
/

-- view all_subpart_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view all_subpart_key_columns_v$
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, user$ u, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# and
       c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
       o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or spc.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union
select u.name, o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, user$ u, ind$ i, attrcol$ a
where spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj# 
      and c.intcol# = spc.intcol#
      and u.user# = o.owner# and 
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      o.subname IS NULL and 
      o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or i.bo# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  !';
exception
  when success_with_error then
    null;
end;
/

-- view dba_subpart_key_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  new_col_str varchar2(100);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view  !' ||
  case when propsrow_exists = 1 then '"DBA_SUBPART_KEY_COLUMNS_V$_MIG"'
  else '"DBA_SUBPART_KEY_COLUMNS_V$"' end || q'!
  (OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID)
as
select u.name, o.name, 'TABLE', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, user$ u, attrcol$ a
where  spc.obj# = o.obj# and spc.obj# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# 
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.subname IS NULL
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union 
select u.name, o.name, 'INDEX', 
  decode(bitand(c.property, 1), 1, a.name, c.name), spc.pos#, 
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from   obj$ o, subpartcol$ spc, col$ c, user$ u, ind$ i, attrcol$ a
where  spc.obj# = i.obj# and i.obj# = o.obj# and i.bo# = c.obj#
       and c.intcol# = spc.intcol#
       and u.user# = o.owner# 
       and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
       and o.subname IS NULL
       and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  !';
exception
  when success_with_error then
    null;
end;
/

@?/rdbms/admin/sqlsessend.sql
