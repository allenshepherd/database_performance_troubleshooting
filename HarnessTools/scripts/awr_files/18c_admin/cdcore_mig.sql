Rem
Rem $Header: rdbms/admin/cdcore_mig.sql /main/16 2017/07/07 10:11:59 yuyzhang Exp $
Rem
Rem cdcore_mig.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdcore_mig.sql - cdcore migration views
Rem
Rem    DESCRIPTION
Rem      Creates cdcore views whose definitions are dependent on columns in
Rem    bootstrap tables.
Rem
Rem    NOTES
Rem      Run from cdcore.sql and utlmmigtbls.sql.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdcore_mig.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdcore_mig.sql
Rem SQL_PHASE: CDCORE_MIG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cdcore.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuyzhang    06/16/17 - #(25372534): add two columns TABLE_ID and
Rem                           COLUMN_INT_ID to *_tab_cols_v$ 
Rem    zqiu        07/29/16 - annotate case column def with column name
Rem    thbaby      05/09/16 - Bug 23181611: add crepatchid/modpatchid to OBJ$
Rem    thbaby      10/30/15 - bug 21939181: support for app id/version
Rem    jiayan      06/16/15 - #20906782: add HYBRID_GLOBAL_NDV to notes column
Rem                           of *_tab_cols_v$
Rem    jcanovi     05/13/15 - 20997166: check for null values while excluding
Rem                           binary xml token set objects
Rem    jcanovi     04/14/15 - lrg-15926632: Exclude token sets from *_ind_cols
Rem    jcanovi     03/18/15 - Bug 20730496: Exclude binary xml granular token
Rem                           set objects from catalog views.
Rem    traney      12/12/14 - 20184217: check for null linkname
Rem    sudurai     11/25/14 - proj 49581 - optimizer stats encryption
Rem    wesmith     11/23/14 - Project 47511: modify *_tab_cols_v$ views
Rem    wesmith     05/05/14 - Project 47511: data-bound collation
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    amelidis    06/06/13 - 14595152: add HIST_FOR_INCREM_STATS to notes
Rem                           column in dba/all/user_tab_cols_v$
Rem    traney      09/26/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
  
--
-- FAMILY "EDITION OBJ" - Objects annotated with edition information
-- These views are for internal use only.
--
-- "_CURRENT_EDITION_OBJ" describes all objects visible in the current
-- edition. Starting with release 11 of the Oracle DB, any views exposing
-- metadata for versionable objects (package, function, procedure, object
-- type, view, synonym, library, trigger and assembly) must use this view
-- instead of obj$.
--
-- "_ACTUAL_EDITION_OBJ" describes all actual objects (not stubs) in all
-- editions. Use this view instead of obj$ to describe all versions of
-- a versionable object.
--
-- In both views, the owner# in is the base user# (not the adjunt schema).
--
-- "_BASE_USER" describes all users (base and adjunt) in user$. This view will
-- always show the base username if it is an adjunt schema. If the view is
-- joining (user$, obj$) directly and the join is producing versionable
-- object rows, then use this view instead of user$.
-- 

declare
  obj_id number;
  column_exists number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='OBJ$' and linkname is null;
  select count(*) into column_exists from col$
   where obj# = obj_id and name='SIGNATURE';
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='DFLCOLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;
  execute immediate q'!
create or replace force view !' ||
  case when propsrow_exists = 1 then '"_CURRENT_EDITION_OBJ_MIG"'
  else '"_CURRENT_EDITION_OBJ"' end || q'!
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      signature,
      spare7,
      spare8,
      spare9,
      dflcollid,
      creappid,
      creverid,
      crepatchid,
      modappid,
      modverid,
      modpatchid,
      spare10,
      spare11,
      spare12,
      spare13,
      spare14,
      owner#,
      defining_edition
 )
as
select o.*,
  !' || -- drop back into PL/SQL to define the columns conditionally
  case when use_new_cols then ''
  when (column_exists = 1 and column_exists_12_2 = 0) then
    'null, null, null, null, null, null, null, null, null, null, null, null, '
  else 'null, 0, 0, 0, null, null, null, null, null, null, null, null, null, null, null, null, ' end || q'!
       o.spare3, 
       case when (o.type# not in (select ue.type# from user_editioning$ ue
                                  where ue.user# = o.spare3) or
                  bitand(o.flags, 1048576) = 1048576 or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select eo.name from obj$ eo where eo.obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and (   /* non-versionable object */
          (   (    o.type# not in (select type# from user_editioning$ ue
                                  where ue.user# = o.spare3)
               and o.type# != 88)
           or bitand(o.flags, 1048576) = 1048576
           or bitand(u.spare1, 16) = 0)
          /* versionable object visible in current edition */
       or (    o.type# in (select ue.type# from user_editioning$ ue
                           where ue.user# = o.spare3)
           and (   (u.type# <> 2 and 
                    sys_context('userenv', 'current_edition_name') = 'ORA$BASE')
                or (u.type# = 2 and
                    u.spare2 = sys_context('userenv', 'current_edition_id'))
                or exists (select 1 from obj$ o2, user$ u2
                           where o2.type# = 88
                             and o2.dataobj# = o.obj#
                             and o2.owner# = u2.user#
                             and u2.type#  = 2
                             and u2.spare2 = 
                                  sys_context('userenv', 'current_edition_id'))
               )
          )
      )
  !';
exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

--
-- all real objects in all the editions
--
declare
  obj_id number;
  column_exists number;
  column_exists_12_2 number;
  propsrow_exists number;
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='OBJ$' and linkname is null;
  select count(*) into column_exists from col$
   where obj# = obj_id and name='SIGNATURE';
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='DFLCOLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';
  if column_exists_12_2 = 1 or propsrow_exists = 1 then
    use_new_cols := TRUE;
  end if;
  execute immediate q'!
create or replace force view  !' ||
  case when propsrow_exists = 1 then '"_ACTUAL_EDITION_OBJ_MIG"'
  else '"_ACTUAL_EDITION_OBJ"' end || q'!
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      signature,
      spare7,
      spare8,
      spare9,
      dflcollid,
      creappid,
      creverid,
      crepatchid,
      modappid,
      modverid,
      modpatchid,
      spare10,
      spare11,
      spare12,
      spare13,
      spare14,
      owner#,
      defining_edition
 )
as
select o.*,
  !' || -- drop back into PL/SQL to define the columns conditionally
  case when use_new_cols then ''
  when (column_exists = 1 and column_exists_12_2 = 0) then
    'null, null, null, null, null, null, null, null, null, null, null, null, '
  else 'null, 0, 0, 0, null, null, null, null, null, null, null, null, null, null, null, null, ' end || q'!
       o.spare3, 
       case when (o.type# not in (select ue.type# from user_editioning$ ue
                                  where ue.user# = o.spare3) or
                  bitand(o.flags, 1048576) = 1048576 or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select name from obj$ where obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and o.type# != 88
  !';
exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/


declare
  obj_id number;
  column_exists number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(4000);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists from col$
   where obj# = obj_id and name='EVALEDITION#';
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists = 1 or propsrow_exists = 1) then
    new_col_str := '
       case when c.evaledition# is null then null
         else (select name from obj$ where obj# = c.evaledition#) end,
       case when c.unusablebefore# is null then null
         else (select name from obj$ where obj# = c.unusablebefore#) end,
       case when c.unusablebeginning# is null then null
         else (select name from obj$ where obj# = c.unusablebeginning#) end,';

    if (column_exists_12_2 = 1 or propsrow_exists = 1) then
      new_col_str := new_col_str || '
         case when (c.type# in (1,8,9,96,112)) 
           then nls_collation_name(nvl(c.collid, 16382)) 
           else null end, 
         c.collintcol# ';
    else
      new_col_str := new_col_str || 'null, null';
    end if;

  else
    new_col_str := 'null, null, null, null, null';
  end if;

  execute immediate q'!
create or replace force view user_tab_cols_v$
    (TABLE_NAME, TABLE_ID, COLUMN_NAME, COLUMN_INT_ID,
     DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, NOTES, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID)
as
select o.name, o.obj#,
       c.name, c.intcol#,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            -- no histogram
            when h.row_cnt = 0 then 1
            -- hybrid histogram
	    when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            -- top-frequency histogram
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            -- frequency histogram
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            -- height-balanced histogram
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         -- The following bit only applies to table level column stats. It does
         -- not apply to partition/subpartition level stats so we do not have 
         -- to change *_part/subpart_col_statistics
         decode(bitand(h.spare2, 2048), 2048, 'HYBRID_GLOBAL_NDV', ''),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       -- warning! If you update stats related info, make sure to also update 
       -- GTT session private stats in cdoptim.sql
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
       decode(bitand(c.property, 17179869184), 17179869184, 'YES', 
              decode(bitand(c.property, 32), 32, 'NO', 'YES')),
       decode(bitand(c.property, 68719476736), 68719476736, 'YES', 'NO'),
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'YES', 274877906944, 'YES', 'NO'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys."_HIST_HEAD_DEC" h, 
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.obj# = t.obj#(+)
  and bitand(o.flags, 128) = 0
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                    /* cluster, view */
       or
       (o.type# = 2    /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 or
                            bitand(t.property, power(2,65)) = power(2,65)))))
  !';
exception
  when success_with_error then
    null;
end;
/

declare
  obj_id number;
  column_exists number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(4000);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists from col$
   where obj# = obj_id and name='EVALEDITION#';
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists = 1 or propsrow_exists = 1) then
    new_col_str := '
       case when c.evaledition# is null then null
         else (select name from obj$ where obj# = c.evaledition#) end,
       case when c.unusablebefore# is null then null
         else (select name from obj$ where obj# = c.unusablebefore#) end,
       case when c.unusablebeginning# is null then null
         else (select name from obj$ where obj# = c.unusablebeginning#) end,';

    if (column_exists_12_2 = 1 or propsrow_exists = 1) then
      new_col_str := new_col_str || '
         case when (c.type# in (1,8,9,96,112)) 
           then nls_collation_name(nvl(c.collid, 16382)) 
           else null end, 
         c.collintcol# ';
    else
      new_col_str := new_col_str || 'null, null';
    end if;

  else
    new_col_str := 'null, null, null, null, null';
  end if;

  execute immediate q'!
create or replace force view all_tab_cols_v$
    (OWNER, TABLE_NAME, TABLE_ID, COLUMN_NAME, COLUMN_INT_ID,
     DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, NOTES, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID)
as
select u.name, o.name, o.obj#,
       c.name, c.intcol#,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            -- no histogram
            when h.row_cnt = 0 then 1
            -- hybrid
	    when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            -- top-freq
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            -- freq
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            -- height
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'), -- global stats
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         decode(bitand(h.spare2, 2048), 2048, 'HYBRID_GLOBAL_NDV', ''),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       -- warning! If you update stats related info, make sure to also update 
       -- GTT session private stats in cdoptim.sql
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
       decode(bitand(c.property, 17179869184), 17179869184, 'YES', 
              decode(bitand(c.property, 32), 32, 'NO', 'YES')),
       decode(bitand(c.property, 68719476736), 68719476736, 'YES', 'NO'),
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'YES', 274877906944, 'YES', 'NO'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys."_HIST_HEAD_DEC" h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and bitand(o.flags, 128) = 0
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 or
                            bitand(t.property, power(2,65)) = power(2,65)))))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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

declare
  obj_id number;
  column_exists number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(4000);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='COL$' and linkname is null;
  select count(*) into column_exists from col$
   where obj# = obj_id and name='EVALEDITION#';
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='COLLID';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists = 1 or propsrow_exists = 1) then
    new_col_str := '
       case when c.evaledition# is null then null
         else (select name from obj$ where obj# = c.evaledition#) end,
       case when c.unusablebefore# is null then null
         else (select name from obj$ where obj# = c.unusablebefore#) end,
       case when c.unusablebeginning# is null then null
         else (select name from obj$ where obj# = c.unusablebeginning#) end,';

    if (column_exists_12_2 = 1 or propsrow_exists = 1) then
      new_col_str := new_col_str || '
         case when (c.type# in (1,8,9,96,112)) 
           then nls_collation_name(nvl(c.collid, 16382)) 
           else null end, 
         c.collintcol# ';
    else
      new_col_str := new_col_str || 'null, null';
    end if;

  else
    new_col_str := 'null, null, null, null, null';
  end if;

  execute immediate q'!
create or replace force view dba_tab_cols_v$
    (OWNER, TABLE_NAME, TABLE_ID, COLUMN_NAME, COLUMN_INT_ID,
     DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, NOTES, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN, SENSITIVE_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID)
as
select u.name, o.name, o.obj#,
       c.name, c.intcol#,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#, (select o.name from obj$ o
                                where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#, (select o.name from obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#, (select u.name from "_BASE_USER" u, obj$ o
                         where o.owner#=u.user# and o.obj#=ac.synobj#),
            ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), c.deflength,
       c.default$, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            -- no histogram
            when h.row_cnt = 0 then 1
            -- hybrid
	    when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            -- top-freq
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            -- freq
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            -- height
            else h.bucket_cnt
       end,                                                        /* NUM_BUCKETS */
       h.timestamp#, h.sample_size,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         decode(bitand(h.spare2, 2048), 2048, 'HYBRID_GLOBAL_NDV', ''),
       h.avgcln,
       c.spare3,
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(o.status, 1, decode(bitand(ac.flags, 256), 256, 'NO', 'YES'),
                        decode(bitand(ac.flags, 2), 2, 'NO',
                               decode(bitand(ac.flags, 4), 4, 'NO',
                                      decode(bitand(ac.flags, 8), 8, 'NO',
                                             'N/A')))),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       -- warning! If you update stats related info, make sure to also update 
       -- GTT session private stats in cdoptim.sql
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys.histgrm$ hg
                        where c.obj# = hg.obj# and c.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,                                                          /* HISTOGRAM */
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, attrcol$ rc where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
       decode(bitand(c.property, 17179869184), 17179869184, 'YES', 
              decode(bitand(c.property, 32), 32, 'NO', 'YES')),
       decode(bitand(c.property, 68719476736), 68719476736, 'YES', 'NO'),
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'YES', 274877906944, 'YES', 'NO'),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8796093022208),
                                          8796093022208, 'YES', 'NO')),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys."_HIST_HEAD_DEC" h, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys."_BASE_USER" ut, sys.tab$ t
where o.obj# = c.obj#
  and o.owner# = u.user#
  and o.obj# = t.obj#(+)
  and c.obj# = h.obj#(+) and c.intcol# = h.intcol#(+)  
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 or
                            bitand(t.property, power(2,65)) = power(2,65)))))
  !';
exception
  when success_with_error then
    null;
end;
/

-- view user_ind_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
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

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view user_ind_columns_v$
    (INDEX_NAME, TABLE_NAME, COLUMN_NAME,
     COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID)
as
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and ic.bo# = base.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5) /* table or cluster namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where base.obj# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
union all
select idx.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
               from sys.col$ tc, attrcol$ ac
               where tc.intcol# = c.intcol#-1
                 and tc.obj# = c.obj#
                 and tc.obj# = ac.obj#(+)
                 and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i,
       sys.attrcol$ ac
where c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where base.obj# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
  !';
exception
  when success_with_error then
    null;
end;
/

-- view all_ind_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
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

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view all_ind_columns_v$
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where base.obj# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
  and (idx.owner# = userenv('SCHEMAID') or
       base.owner# = userenv('SCHEMAID')
       or
       base.obj# in ( select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                   )
        or
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

-- view dba_ind_columns_v$
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
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

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    new_col_str := 'c.collintcol#';
  else
    new_col_str := 'null';
  end if;

  execute immediate q'!
create or replace force view dba_ind_columns_v$
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID)
as
select io.name, idx.name, bo.name, base.name,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(tc.property, 1), 1, ac.name, tc.name)
              from sys.col$ tc, attrcol$ ac
              where tc.intcol# = c.intcol#-1
                and tc.obj# = c.obj#
                and tc.obj# = ac.obj#(+)
                and tc.intcol# = ac.intcol#(+)),
              decode(ac.name, null, c.name, ac.name)),
       ic.pos#, c.length, c.spare3,
       decode(bitand(c.property, 131072), 131072, 'DESC', 'ASC'),
  !' || -- drop back into PL/SQL to define the columns conditionally
  new_col_str || q'!
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i, sys.attrcol$ ac
where ic.bo# = c.obj#
  and decode(bitand(i.property,1024),0,ic.intcol#,ic.spare2) = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where base.obj# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
  !';
exception
  when success_with_error then
    null;
end;
/

@?/rdbms/admin/sqlsessend.sql
