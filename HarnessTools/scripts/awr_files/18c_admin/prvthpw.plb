@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE PACKAGE kupw$worker wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
6c3 2fe
p9cxupP34zbmuLk4tqkVEFHAi2Qwg/BcALcFyi8uzQ817hVBXQka7Sc11ViC4UAo+MPMY0Vm
WBP6aJpyZjiQbAzsjPc3EPgIM2Jhyv9QyhL4/v4LtQjBc83+2tYE3MLgZnsHexp9s3+l2qN+
Ac1BQby7ueoZuhc2K7Oo9jUnnwSzYs6p0d4RLZrrAZ3Rj9u9aGQsxwzHPYkV6AECet+h/INL
9K7RKlNK0eHffUpybMQ9w9UpYjZS8uqG/6E5fnNOHV37Q9aEEV66bAditF2V9LxjkUVHeOaI
ItOfDJYsy+nSZ2222sJlf3zo8HxhmILRNDaPniB60ceCLVZ6/2LQDJSL1nsn8xqz2NRZoXeX
Z42jdElejQbYoXthXirIqnuGor8mVqK/2uwH7EbefBQ49cq+af/CkqvkA7KIteAwRQ5OXbtp
vAD0CpUlyVCldUDSoWE8U8isHc1OZFmaSEeVxapedx0ygjhpYO0hMTiO3jsOCAAMglIJpi/h
7ZyO8AhKpH5Y3Jo6T8ERzSISh3mxc933MK2Bl6UfjqLFFpX6sVADwAR7bSisbuWwVG+tqq/A
bils2ZXbnASC3/44cJ3f4pBDJL3CkI3lJUTD27IM/PKyzEQJdQkd2AcaS4hwlOgfONbP6jXP
89vwzOcjrHtI0Klqh1N9blKCg31Ws7qgkz3ybaeA8J9kpAj9JekGgaWlu3xoqhiwqtlvD7s+
ZhL9M8ei3CgylRFv4vjk5uumP/gogR9+DQ==

/
grant execute on SYS.KUPW$WORKER to public;
CREATE OR REPLACE VIEW sys.ku$_table_est_view (
                cols, rowcnt, avgrln, object_schema, object_name) AS
        SELECT  t.cols, t.rowcnt, t.avgrln, u.name, o.name
        FROM    SYS.OBJ$ O, SYS.TAB$ T, SYS.USER$ U
        WHERE   t.obj# = o.obj# AND
                o.owner# = u.user# AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT READ ON sys.ku$_table_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_partition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                partition_name) AS
        SELECT  t.cols, tp.rowcnt, tp.avgrln, u.name, ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, SYS.TABPART$ TP,
                SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tp.bo# AND
                ot.owner# = u.user# AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'));
GRANT READ ON sys.ku$_partition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_subpartition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                subpartition_name) AS
        SELECT  t.cols, tp.rowcnt, tp.avgrln, u.name, ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, sys.tabcompart$ tcp, 
                SYS.TABSUBPART$ TP, SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tcp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tcp.bo# AND
                tp.pobj# = tcp.obj# and
                ot.owner# = u.user# AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT READ ON sys.ku$_subpartition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_object_status_view (
                status, owner, name, type) AS
        SELECT  o.status, u.name, o.name,
                decode(o.type#, 4, 'VIEW', 7, 'PROCEDURE', 8, 'FUNCTION',
                       9, 'PACKAGE', 11, 'PACKAGE_BODY', 12, 'TRIGGER',
                       13, 'TYPE', 22, 'LIBRARY')
        FROM    sys.obj$ o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# IN (4, 7, 8, 9, 11, 12, 13, 22) AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT READ ON sys.ku$_object_status_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_table_exists_view (
                object_schema, object_long_name) AS
        SELECT  u.name, o.name
        FROM    sys.obj$ o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# = 2 AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT READ ON sys.ku$_table_exists_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_refpar_level (
                refpar_level, owner, name) AS
        SELECT  sys.dbms_metadata_util.ref_par_level(t.obj#), u.name, o.name
        FROM    sys.obj$ o, sys.tab$ t, sys.user$ u
        where   u.user# = o.owner# AND o.obj# = t.obj# AND
                bitand(t.property, 32+64+128+256+512) = 32 AND
                EXISTS(SELECT * from sys.partobj$ po
                       WHERE  po.obj# = t.obj# AND po.parttype = 5) AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                 EXISTS (SELECT * FROM sys.session_roles
                         WHERE role='SELECT_CATALOG_ROLE'))
/
GRANT READ ON sys.ku$_refpar_level TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_child_nested_tab_view (
                owner_name, parent_tab, child_tab, property) AS
        SELECT  u.name, op.name, ont.name, t.property
        FROM    sys.obj$ ont, sys.obj$ op, sys.user$ u, sys.ntab$ n, sys.tab$ t
        WHERE   op.owner# = u.user# AND n.obj# = op.obj# AND
                n.ntab# = ont.obj# AND t.obj# = ont.obj#
/
GRANT SELECT ON sys.ku$_child_nested_tab_view TO SELECT_CATALOG_ROLE
/
CREATE OR REPLACE VIEW ku$_all_tsltz_tab_cols(owner, table_name, column_name,
        qualified_col_name, nested, virtual_column) as
  with rw (p_obj#, d_obj#, property)  as
  (
        select p_obj#, d_obj#, property
        from   sys.dependency$
        where  p_obj# in
               (select distinct o.obj#
                from   sys.obj$ o, sys.attribute$ a
                where  o.oid$ = a.toid and
                       a.attr_toid = '00000000000000000000000000000041'
    union all
        select distinct o.obj#
        from   sys.obj$ o, sys.collection$ c
        where  o.oid$ = c.toid and
               c.elem_toid = '00000000000000000000000000000041')
    union all
        select d.p_obj#, d.d_obj#, d.property
        from   rw, sys.dependency$ d
        where  rw.d_obj# = d.p_obj# and bitand(rw.property, 1) = 1),
  va_of_tsltz_typ (name) as(
        select distinct o.name
        from   rw, sys.obj$ o, sys.coltype$ c
        where  rw.p_obj# = o.obj# and o.oid$ = c.toid and
               bitand(c.flags, 8) = 8),
  all_tsltz_candiate_tab_cols(owner, table_name, table_property, table_nested,
        column_name, data_type, qualified_col_name, virtual_column) as
       (select u.name, o.name, t.property,
               case when bitand(t.property, 8192) = 8192 then 1 else 0 end,
               c.name,
               case when c.type# = 231 then
                       'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE'
                    when c.type# in (58, 111, 121, 122, 123) then
                        nvl2(ac.synobj#, (select o.name from obj$ o
                                          where o.obj#=ac.synobj#), ot.name)
                    else 'UNDEFINED'
               end,
               decode(bitand(c.property, 1024), 1024,
                 (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
                  from   sys.col$ cl, attrcol$ rc
                  where  cl.intcol# = c.intcol#-1 and cl.obj# = c.obj# and
                         c.obj# = rc.obj#(+) and cl.intcol# = rc.intcol#(+)),
               decode(bitand(c.property, 1), 0, c.name,
                 (select tc.name
                  from   sys.attrcol$ tc
                  where  c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
               decode(c.property, 0, 0, decode(bitand(c.property, 8), 8, 1, 0))
        from   sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
               sys.coltype$ ac, sys.obj$ ot, sys.tab$ t
        where  o.obj# = c.obj# and o.owner# = u.user# and
               c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+) and
               ac.toid = ot.oid$(+) and ot.type#(+) = 13 and
               o.obj# = t.obj# and c.type# in (58, 111, 121, 122, 123, 231))
  select owner, table_name, column_name, qualified_col_name, table_nested,
         virtual_column
  from  all_tsltz_candiate_tab_cols
  where data_type like 'TIMESTAMP%WITH LOCAL TIME ZONE' or
        data_type in (select name from va_of_tsltz_typ)
/
GRANT SELECT ON sys.ku$_all_tsltz_tab_cols TO SELECT_CATALOG_ROLE;
CREATE OR REPLACE VIEW ku$_all_tsltz_tables(owner, table_name) as
        SELECT UNIQUE owner, table_name
        FROM   sys.ku$_all_tsltz_tab_cols
/
GRANT SELECT ON sys.ku$_all_tsltz_tables TO SELECT_CATALOG_ROLE;
/
CREATE OR REPLACE VIEW KU$_PART_COL_NAMES_VIEW(owner, table_name, col_name) as
  SELECT  u.name, o.name, c.name
  FROM    user$ u, obj$ o, sys.col$ c, partcol$ pc
  WHERE   pc.obj#=c.obj# and
          pc.intcol#=c.intcol# and
          pc.obj# = o.obj# and
          o.owner# = u.user# and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') in (o.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='SELECT_CATALOG_ROLE' ))
UNION ALL
  SELECT  u.name, o.name, c.name
  FROM    user$ u, obj$ o, sys.col$ c, subpartcol$ sc
  WHERE   sc.obj#=c.obj# and
          sc.intcol#=c.intcol# and
          sc.obj# = o.obj# and
          o.owner# = u.user# and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') in (o.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='SELECT_CATALOG_ROLE' ))
/
GRANT READ ON sys.ku$_part_col_names_view  TO PUBLIC
/
@?/rdbms/admin/sqlsessend.sql
