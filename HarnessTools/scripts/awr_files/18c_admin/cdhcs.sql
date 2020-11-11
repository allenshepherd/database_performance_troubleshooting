Rem
Rem $Header: rdbms/admin/cdhcs.sql /main/22 2017/01/30 23:32:04 sfeinste Exp $
Rem
Rem cdhcs.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdhcs.sql - Catalog creation for Hierarchy Cube Sql
Rem
Rem    DESCRIPTION
Rem      This loads the catalog for the Hierarchy Cube metadata
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sfeinste    11/30/16 - Proj 70791: add dyn_all_cache to analytic view
Rem    jhartsin    11/03/16 - remove MVIEW_NAME from *_AVIEW_LVLGRPS
Rem    almurphy    07/27/16 - add REFERENCES DISTINCT to ANALYTIC VIEW
Rem    jcarey      04/19/16 - bug 23131240 - remove unnecessary columns
Rem    jcarey      02/26/16 - bug 20555676 - shared clause
Rem    mstasiew    01/04/16 - Add XXX_ANALYTIC_VIEW_ATTR_CLASS
Rem    beiyu       12/15/15 - Bug 20619944: add level_type column
Rem    sfeinste    12/04/15 - Fix DATA_PRECISION/DATA_SCALE columns
Rem    beiyu       11/27/15 - Bug 21861041: rm user$ USER_ANALYTIC_VIEW_LVLGRPS
Rem    sfeinste    10/28/15 - Bug 21542146: xxx_HIER_LEVEL_ID_ATTRS
Rem    smesropi    10/08/15 - Bug 21171628: Rename HCS views
Rem    ghicks      09/10/15 - remove 'with grant option' from grants to public
Rem    mstasiew    07/23/15 - Bug 21496106: *HIER_CUBE_COLUMNS.ROLE BASE/CALC
Rem    mstasiew    07/08/15 - Bug 21417275: XXX_HIER_DIM_LEVEL_ATTRS ROLE col
Rem    ghicks      07/07/15 - Bug 21208995: fix ALL_xxx sys privilege checks
Rem    mdombros    06/06/15 - Bug 21163869: create hier cube level grouping views
Rem    smesropi    05/18/15 - Bug 20555264: Add aggr col to hcs cube and meas
Rem    beiyu       05/07/15 - Bug 20549214: change privileges for all_xxx views
Rem    mstasiew    04/28/15 - Bug 20898181 XXX_HIER_CUBE_COLUMNS dtype cols
Rem    smesropi    03/18/15 - Bug 20569626: Dimension name should be NULL for 
Rem                           measures in xxx_HIER_CUBE_COLUMNS
Rem    mstasiew    12/30/14 - Bug 20448392 add XXX_HIER_COLUMNS datatype cols
Rem    smesropi    10/27/14 - Modified XXX_HIER_DIM_LEVEL_ATTRS to include
Rem                           all the determined attributes
Rem    smesropi    09/21/14 - Fixed views XXX_HIER_DIM_TABLES
Rem    sfeinste    09/15/14 - Rename MDS -> HCS
Rem    smesropi    08/21/14 - Add join path and join condition element views
Rem    smesropi    08/18/14 - Modified privilege numbers 
Rem    smesropi    08/02/14 - Replaced HIER_ATTR_CLASSIFICATIONS with 
Rem                           HIER_HIER_ATTR_CLASS. Added HIER_HIER_ATTRIBUTES
Rem    smesropi    07/21/14 - Modified Hier and Cube COLUMNS views
Rem    smesropi    06/19/14 - Get COMPILE_STATE from obj$
Rem    smesropi    05/02/14 - Replaced is_time with dim_type
Rem    smesropi    04/15/14 - Removed src# from mds_src_col$
Rem    smesropi    03/18/14 - Removed col_id from mds_src_col$
Rem    sfeinste    03/12/14 - LANGUAGE column in classification views
Rem    smesropi    01/08/14 - Modified HIER_DIM_ORDER_ATTRS and 
Rem                           HIER_CUBE_CUBE_KEYS
Rem    smesropi    12/05/13 - Added HIER_CUBE_LEVELS, HIER_CUBE_HIER_CLASS,
Rem                           HIER_CUBE_LEVEL_CLASS, and HIER_CUBE_COLUMNS
Rem    smesropi    10/23/13 - Renamed hierarchy and cube tables
Rem    smesropi    08/28/13 - Update HIER_CUBE_CUBE_KEYS
Rem    smesropi    07/17/13 - Updated
Rem    smesropi    04/19/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdhcs.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: CDHCS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

create or replace view INT$DBA_ATTR_DIM_ORDER_ATT SHARING=EXTENDED DATA
as
select u.name owner,
       o.name DIMENSION_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       dl.lvl_name LEVEL_NAME,
       DECODE(lo.aggr_func, 1, 'MIN', 2, 'MAX') AGG_FUNC,
       da.attr_name ATTRIBUTE_NAME,
       lo.order_num ORDER_NUM,
       DECODE(lo.is_asc, 1, 'ASC',0, 'DESC') CRITERIA,
       DECODE(lo.null_first, 1, 'FIRST', 0, 'LAST') NULLS_POSITION,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from hcs_dim_attr$ da, hcs_dim_lvl$ dl, hcs_lvl_ord$ lo, user$ u, 
       sys.obj$ o
where o.owner# = u.user#
       and lo.dim# = o.obj#
       and dl.lvl# = lo.dim_lvl#
       and da.attr# = lo.attr#
       and o.obj# = dl.dim#
       and o.obj# = da.dim#
/

create or replace view DBA_ATTRIBUTE_DIM_ORDER_ATTRS
as
select OWNER, DIMENSION_NAME, LEVEL_NAME, AGG_FUNC, ATTRIBUTE_NAME,
       ORDER_NUM, CRITERIA, NULLS_POSITION,  ORIGIN_CON_ID
from   INT$DBA_ATTR_DIM_ORDER_ATT
/

comment on table DBA_ATTRIBUTE_DIM_ORDER_ATTRS is
'Attribute Dimension order by elements in the database'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.OWNER is
'Owner of attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.ATTRIBUTE_NAME is
       'Name of the order attribute'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.LEVEL_NAME is
       'Level name of the order by, NULL if parent child dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.CRITERIA is
       'Criteria of using the order attribute: ASC or DESC'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.NULLS_POSITION is
       'Position of the NULLs: FIRST or LAST'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.AGG_FUNC is
       'Aggregation function of the order by; MIN, MAX, or NULL if parent child dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.ORDER_NUM is
       'Order number of the attribute in the list of order attributes'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.ORIGIN_CON_ID is
       'ID of Container where row originates'
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_ORDER_ATTRS
       FOR SYS.DBA_ATTRIBUTE_DIM_ORDER_ATTRS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_ORDER_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_ORDER_ATTRS','CDB_ATTRIBUTE_DIM_ORDER_ATTRS');
grant select on SYS.CDB_ATTRIBUTE_DIM_ORDER_ATTRS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_ORDER_ATTRS
for SYS.CDB_ATTRIBUTE_DIM_ORDER_ATTRS
/

create or replace view USER_ATTRIBUTE_DIM_ORDER_ATTRS
       as
select DIMENSION_NAME, LEVEL_NAME, AGG_FUNC,
         ATTRIBUTE_NAME, ORDER_NUM, CRITERIA, NULLS_POSITION,
         ORIGIN_CON_ID     
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_ORDER_ATT)
where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_ORDER_ATTRS is
'Attribute dimension order by elements in the database'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.ATTRIBUTE_NAME is
       'Name of the order attribute'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.LEVEL_NAME is
       'Level name of the order by, NULL if parent child dimension'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.CRITERIA is
       'Criteria of using the order attribute: ASC or DESC'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.NULLS_POSITION is
       'Position of the NULLs: FIRST or LAST'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.AGG_FUNC is
       'Aggregation function of the order by; MIN, MAX, or NULL if parent child dimension'
/
comment on column USER_ATTRIBUTE_DIM_ORDER_ATTRS.ORDER_NUM is
       'Order number of the attribute in the list of order attributes'
/
comment on column DBA_ATTRIBUTE_DIM_ORDER_ATTRS.ORIGIN_CON_ID is
       'ID of Container where row originates'
/
CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_ORDER_ATTRS
FOR SYS.USER_ATTRIBUTE_DIM_ORDER_ATTRS
/
/
grant read on USER_ATTRIBUTE_DIM_ORDER_ATTRS to public
/

create or replace view ALL_ATTRIBUTE_DIM_ORDER_ATTRS
       as
select OWNER, DIMENSION_NAME, LEVEL_NAME, AGG_FUNC, ATTRIBUTE_NAME,
       ORDER_NUM, CRITERIA, NULLS_POSITION, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_ORDER_ATT
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
       (select obj#
       from sys.objauth$
       where grantee# in (select kzsrorol from x$kzsro )
       )        
       or /* user has sys privs */
       ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_ORDER_ATTRS is
'Attribute dimension order by elements in the database'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.OWNER is
'Owner of attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.ATTRIBUTE_NAME is
'Name of the order attribute'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.LEVEL_NAME is
'Level name of the order by, NULL if parent child dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.CRITERIA is
'Criteria of using the order attribute: ASC or DESC'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.NULLS_POSITION is
'Position of the NULLs: FIRST or LAST'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.AGG_FUNC is
'Aggregation function of the order by; MIN, MAX, or NULL if parent child dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.ORDER_NUM is
'Order number of the attribute in the list of order attributes'
/
comment on column ALL_ATTRIBUTE_DIM_ORDER_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_ORDER_ATTRS
FOR SYS.ALL_ATTRIBUTE_DIM_ORDER_ATTRS
/
grant read on ALL_ATTRIBUTE_DIM_ORDER_ATTRS to public
/

--Create views for classifications
create or replace view INT$DBA_ATTR_DIM_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name dimension_name,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV', 'CON_ID')) origin_con_id
from sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_dim$ d
where u.user# = o.owner#
      and c.obj# = o.obj#
      and c.obj_type = '1' -- ATTRIBUTE DIMENSION
      and d.obj# = c.obj#
/

create or replace view DBA_ATTRIBUTE_DIM_CLASS
as 
select OWNER, DIMENSION_NAME, CLASSIFICATION, VALUE, LANGUAGE,
       ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_CLASS
/

comment on table DBA_ATTRIBUTE_DIM_CLASS is
'Attribute Dimension Classifications in the database'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.OWNER is
'Owner of the attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.DIMENSION_NAME is
'Dimension name of owning attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.CLASSIFICATION is
'Name of attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.VALUE is
'Value of attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.LANGUAGE is
'Language of attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.ORDER_NUM is
'Order number of attribute dimension classification'
/
comment on column DBA_ATTRIBUTE_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_CLASS
FOR SYS.DBA_ATTRIBUTE_DIM_CLASS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_CLASS', 'CDB_ATTRIBUTE_DIM_CLASS');
grant select on SYS.CDB_ATTRIBUTE_DIM_CLASS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_CLASS 
for SYS.CDB_ATTRIBUTE_DIM_CLASS
/

create or replace view USER_ATTRIBUTE_DIM_CLASS
as
select dimension_name, classification, value, language, order_num,
       origin_con_id
from  NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_CLASS)
where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_CLASS is
'Attribute dimension classifications in the database'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.DIMENSION_NAME is
'Dimension name of owning attribute dimension classification'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.CLASSIFICATION is
'Name of attribute dimension classification'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.VALUE is
'Value of attribute dimension classification'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.LANGUAGE is
'Language of attribute dimension classification'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.ORDER_NUM is
'Order number of attribute dimension classification'
/
comment on column USER_ATTRIBUTE_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_CLASS
FOR SYS.USER_ATTRIBUTE_DIM_CLASS
/
grant read on USER_ATTRIBUTE_DIM_CLASS to public
/

create or replace view ALL_ATTRIBUTE_DIM_CLASS
as
select owner,
       dimension_name,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from   INT$DBA_ATTR_DIM_CLASS
where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
      or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_CLASS is
'Attribute dimension classifications in the database'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.OWNER is
'Owner of the attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.DIMENSION_NAME is
'Dimension name of owning attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.CLASSIFICATION is
'Name of attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.VALUE is
'Value of attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.LANGUAGE is
'Language of attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.ORDER_NUM is
'Order number of attribute dimension classification'
/
comment on column ALL_ATTRIBUTE_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_CLASS
FOR SYS.ALL_ATTRIBUTE_DIM_CLASS
/
grant read on ALL_ATTRIBUTE_DIM_CLASS to public
/

create or replace view INT$DBA_ATTR_DIM_ATTR_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name dimension_name,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       a.attr_name attribute_name,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from  sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_dim_attr$ a
where u.user# = o.owner#
      and c.obj# = o.obj#
      and c.obj_type = '4' -- DIM ATTR
      and a.dim# = c.obj#
      and a.attr# = c.sub_obj#
/

create or replace view DBA_ATTRIBUTE_DIM_ATTR_CLASS 
as
select OWNER, DIMENSION_NAME, ATTRIBUTE_NAME, CLASSIFICATION,
      VALUE, LANGUAGE, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_ATTR_CLASS
/

/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.OWNER is
'Owner of the attribute dimension attribute classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.DIMENSION_NAME is
'Name of owning attribute dimension of the attribute'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of owning attribute of the classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.CLASSIFICATION is
'Name of attribute dimension attribute classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.VALUE is
'Value of attribute dimension attribute classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.LANGUAGE is
'Language of attribute dimension attribute classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.ORDER_NUM is
'Order number of attribute dimension attribute classification'
/
comment on column DBA_ATTRIBUTE_DIM_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_ATTR_CLASS
FOR SYS.DBA_ATTRIBUTE_DIM_ATTR_CLASS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_ATTR_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_ATTR_CLASS', 'CDB_ATTRIBUTE_DIM_ATTR_CLASS');
grant select on SYS.CDB_ATTRIBUTE_DIM_ATTR_CLASS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_ATTR_CLASS
for SYS.CDB_ATTRIBUTE_DIM_ATTR_CLASS
/

create or replace view USER_ATTRIBUTE_DIM_ATTR_CLASS
as
select dimension_name, attribute_name, classification, value,
       language, order_num, origin_con_id
from  NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_ATTR_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_ATTR_CLASS is
'Attributed dimension attribute classifications in the database'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.DIMENSION_NAME is
'Name of owning attribute Ddmension of the attribute'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of owning attribute of the classification'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.CLASSIFICATION is
'Name of attribute dimension attribute classification'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.VALUE is
'Value of attribute dimension attribute classification'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.LANGUAGE is
'Language of attribute dimension attribute classification'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.ORDER_NUM is
'Order number of attribute dimension attribute classification'
/
comment on column USER_ATTRIBUTE_DIM_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_ATTR_CLASS
FOR SYS.USER_ATTRIBUTE_DIM_ATTR_CLASS
/
grant read on USER_ATTRIBUTE_DIM_ATTR_CLASS to public
/

create or replace view ALL_ATTRIBUTE_DIM_ATTR_CLASS
as
select owner,
       dimension_name,
       attribute_name,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from INT$DBA_ATTR_DIM_ATTR_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_ATTR_CLASS is
'Attribute dimension attribute classifications in the database'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.OWNER is
'Owner of the attribute dimension attribute classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.DIMENSION_NAME is
'Name of owning attribute dimension of the attribute'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of owning attribute of the classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.CLASSIFICATION is
'Name of attribute dimension attribute classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.VALUE is
'Value of attribute dimension Attribute classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.LANGUAGE is
'Language of attribute dimension attribute classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.ORDER_NUM is
'Order number of attribute dimension attribute classification'
/
comment on column ALL_ATTRIBUTE_DIM_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_ATTR_CLASS
FOR SYS.ALL_ATTRIBUTE_DIM_ATTR_CLASS
/
grant read on ALL_ATTRIBUTE_DIM_ATTR_CLASS to public
/

create or replace view INT$DBA_ATTR_DIM_LVL_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name dimension_name,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       l.lvl_name level_name,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_dim_lvl$ l
where u.user# = o.owner#
      and c.obj# = o.obj#
      and c.obj_type = '5' -- DIM LEVEL
      and l.dim# = c.obj#
      and l.lvl# = c.sub_obj#
/

create or replace view DBA_ATTRIBUTE_DIM_LVL_CLASS 
       as
select OWNER, DIMENSION_NAME, LEVEL_NAME, CLASSIFICATION, 
       VALUE, LANGUAGE, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_LVL_CLASS
/

/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.OWNER is
'Owner of the attribute dimension Level classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.DIMENSION_NAME is
'Name of owning attribute dimension of the Level'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.LEVEL_NAME is
'Name of owning level of the classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.CLASSIFICATION is
'Name of attribute dimension level classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.VALUE is
'Value of attribute dimension level classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.LANGUAGE is
'Language of attribute dimension level classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.ORDER_NUM is
'Order number of attribute dimension level classification'
/
comment on column DBA_ATTRIBUTE_DIM_LVL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_LVL_CLASS
FOR SYS.DBA_ATTRIBUTE_DIM_LVL_CLASS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_LVL_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_LVL_CLASS', 'CDB_ATTRIBUTE_DIM_LVL_CLASS');
grant select on SYS.CDB_ATTRIBUTE_DIM_LVL_CLASS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_LVL_CLASS
for SYS.CDB_ATTRIBUTE_DIM_LVL_CLASS
/

create or replace view USER_ATTRIBUTE_DIM_LVL_CLASS
as
select dimension_name, level_name, classification, value,
       language, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_LVL_CLASS)
where owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_LVL_CLASS is
'Attribute dimension level classifications in the database'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.DIMENSION_NAME is
'Name of owning attribute dimension of the level'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.LEVEL_NAME is
'Name of owning level of the classification'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.CLASSIFICATION is
'Name of attribute dimension level classification'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.VALUE is
'Value of attribute dimension level classification'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.LANGUAGE is
'Language of attribute dimension level classification'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.ORDER_NUM is
'Order number of attribute dimension level classification'
/
comment on column USER_ATTRIBUTE_DIM_LVL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_LVL_CLASS
FOR SYS.USER_ATTRIBUTE_DIM_LVL_CLASS
/
grant read on USER_ATTRIBUTE_DIM_LVL_CLASS to public
/

create or replace view ALL_ATTRIBUTE_DIM_LVL_CLASS
as
select owner,
       dimension_name,
       level_name,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from  INT$DBA_ATTR_DIM_LVL_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_LVL_CLASS is
'Attribute dimension level classifications in the database'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.OWNER is
'Owner of the attribute dimension level classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.DIMENSION_NAME is
'Name of owning attribute dimension of the level'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.LEVEL_NAME is
'Name of owning level of the classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.CLASSIFICATION is
'Name of attribute dimension level classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.VALUE is
'Value of attribute dimension level classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.LANGUAGE is
'Language of attribute dimension level classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.ORDER_NUM is
'Order number of attribute dimension level classification'
/
comment on column ALL_ATTRIBUTE_DIM_LVL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_LVL_CLASS
FOR SYS.ALL_ATTRIBUTE_DIM_LVL_CLASS
/
grant read on ALL_ATTRIBUTE_DIM_LVL_CLASS to public
/

create or replace view INT$DBA_HIER_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name hier_name,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_hierarchy$ h
where o.owner# = u.user#
      and c.obj# = o.obj#
      and c.obj_type = '2' -- HIERARCHY
      and h.obj# = c.obj#
/

create or replace view DBA_HIER_CLASS
  as
  select OWNER, HIER_NAME, CLASSIFICATION, VALUE, LANGUAGE, ORDER_NUM,
    ORIGIN_CON_ID
  from INT$DBA_HIER_CLASS
/

comment on table DBA_HIER_CLASS is
'Hierarchy Classifications in the database'
/
comment on column DBA_HIER_CLASS.OWNER is
'Owner of the Hierarchy  classification'
/
comment on column DBA_HIER_CLASS.HIER_NAME is
'Hierarchy name of owning Hierarchy classification'
/
comment on column DBA_HIER_CLASS.CLASSIFICATION is
'Name of Hierarchy classification'
/
comment on column DBA_HIER_CLASS.VALUE is
'Value of Hierarchy classification'
/
comment on column DBA_HIER_CLASS.LANGUAGE is
'Language of Hierarchy classification'
/
comment on column DBA_HIER_CLASS.ORDER_NUM is
'Order number of Hierarchy classification'
/
comment on column DBA_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_CLASS
FOR SYS.DBA_HIER_CLASS
/
GRANT SELECT ON DBA_HIER_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_CLASS', 'CDB_HIER_CLASS');
grant select on SYS.CDB_HIER_CLASS to select_catalog_role
/
create or replace public synonym CDB_HIER_CLASS
for SYS.CDB_HIER_CLASS
/

create or replace view USER_HIER_CLASS
as
select hier_name, classification, value, language,
       order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_CLASS is
'Hierarchy classifications in the database'
/
comment on column USER_HIER_CLASS.HIER_NAME is
'Hierarchy name of owning Hierarchy classification'
/
comment on column USER_HIER_CLASS.CLASSIFICATION is
'Name of Hierarchy classification'
/
comment on column USER_HIER_CLASS.VALUE is
'Value of Hierarchy classification'
/
comment on column USER_HIER_CLASS.LANGUAGE is
'Language of Hierarchy classification'
/
comment on column USER_HIER_CLASS.ORDER_NUM is
'Order number of Hierarchy classification'
/
comment on column USER_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_CLASS
FOR SYS.USER_HIER_CLASS
/
grant read on USER_HIER_CLASS to public
/

create or replace view ALL_HIER_CLASS
as
select owner,
       hier_name,
       classification,
       value,
       language,
       order_num,
       ORIGIN_CON_ID
from INT$DBA_HIER_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            ) 
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_CLASS is
'Hierarchy classifications in the database'
/
comment on column ALL_HIER_CLASS.OWNER is
'Owner of the Hierarchy  classification'
/
comment on column ALL_HIER_CLASS.HIER_NAME is
'Hierarchy name of owning Hierarchy classification'
/
comment on column ALL_HIER_CLASS.CLASSIFICATION is
'Name of Hierarchy classification'
/
comment on column ALL_HIER_CLASS.VALUE is
'Value of Hierarchy classification'
/
comment on column ALL_HIER_CLASS.LANGUAGE is
'Language of Hierarchy classification'
/
comment on column ALL_HIER_CLASS.ORDER_NUM is
'Order number of Hierarchy classification'
/
comment on column ALL_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_CLASS
FOR SYS.ALL_HIER_CLASS
/
grant read on ALL_HIER_CLASS to public
/

create or replace view INT$DBA_AVIEW_LEVELS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_ALIAS,
       avh.hier_alias HIER_ALIAS,
       avl.lvl_name LEVEL_NAME,
       avl.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, user$ u, hcs_av_hier$ avh, hcs_av_dim$ avd, 
     hcs_av_lvl$ avl
where o.owner# = u.user#
      and avl.av# = o.obj#
      and avh.av# = avl.av#
      and avd.av# = avh.av#
      and avl.av_dim# = avh.av_dim#
      and avh.av_dim# = avd.av_dim#
      and avl.av_hier# = avh.hier#
/

create or replace view DBA_ANALYTIC_VIEW_LEVELS 
  (OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, LEVEL_NAME,
  ORDER_NUM, ORIGIN_CON_ID)
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, LEVEL_NAME,
  ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_LEVELS
/
comment on table DBA_ANALYTIC_VIEW_LEVELS is
'Analytic view Levels in the database'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.OWNER is
'Owner of the analytic view level'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.ORDER_NUM is
'Order number of analytic view level'
/
comment on column DBA_ANALYTIC_VIEW_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_LEVELS
FOR SYS.DBA_ANALYTIC_VIEW_LEVELS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_LEVELS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_LEVELS', 'CDB_ANALYTIC_VIEW_LEVELS');
grant select on SYS.CDB_ANALYTIC_VIEW_LEVELS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_LEVELS
for SYS.CDB_ANALYTIC_VIEW_LEVELS
/

create or replace view USER_ANALYTIC_VIEW_LEVELS
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, LEVEL_NAME,
       ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_LEVELS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_LEVELS is
'Analytic view levels in the database'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.ORDER_NUM is
'Order number of analytic view level'
/
comment on column USER_ANALYTIC_VIEW_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_LEVELS
FOR SYS.USER_ANALYTIC_VIEW_LEVELS
/
grant read on USER_ANALYTIC_VIEW_LEVELS to public
/
create or replace view ALL_ANALYTIC_VIEW_LEVELS
as
select owner,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       LEVEL_NAME,
       ORDER_NUM,      
       ORIGIN_CON_ID
from INT$DBA_AVIEW_LEVELS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_LEVELS is
'Analytic view levels in the database'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.OWNER is
'Owner of the analytic view level'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.ORDER_NUM is
'Order number of analytic view level'
/
comment on column ALL_ANALYTIC_VIEW_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_LEVELS
FOR SYS.ALL_ANALYTIC_VIEW_LEVELS
/
grant read on ALL_ANALYTIC_VIEW_LEVELS to public
/

create or replace view INT$DBA_AVIEW_LVLGRPS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avl.cache_type CACHE_TYPE,
       ll.dim_alias DIMENSION_ALIAS,
       ll.hier_alias HIER_ALIAS,
       ll.level_name LEVEL_NAME,
       NULL MEASURE_NAME,
       avl.order_num AV_LVLGRP_ORDER,
       ll.order_num LEVEL_MEAS_ORDER,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from obj$ o, user$ u, hcs_av_lvlgrp$ avl, 
     hcs_lvlgrp_lvls$ ll
where o.owner# = u.user#
      and avl.av# = o.obj#
      and ll.av# = avl.av#
      and avl.lvlgrp# = ll.lvlgrp#
union all
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avl.cache_type CACHE_TYPE,
       'MEASURES',
       'MEASURES',
       NULL,
       mm.meas_name MEASURE_NAME,
       avl.order_num AV_LVLGRP_ORDER,
       mm.order_num LEVEL_MEAS_ORDER,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from obj$ o, user$ u, hcs_av_lvlgrp$ avl, 
     hcs_measlst_measures$ mm
where o.owner# = u.user#
      and avl.av# = o.obj#
      and mm.av# = avl.av#
      and avl.measlst# = mm.measlst#
/

create or replace view DBA_ANALYTIC_VIEW_LVLGRPS
as
select OWNER, ANALYTIC_VIEW_NAME, CACHE_TYPE, DIMENSION_ALIAS, 
      HIER_ALIAS, LEVEL_NAME, MEASURE_NAME, AV_LVLGRP_ORDER, 
      LEVEL_MEAS_ORDER, ORIGIN_CON_ID
from INT$DBA_AVIEW_LVLGRPS
/

comment on table DBA_ANALYTIC_VIEW_LVLGRPS is
'Analytic View Level Groupings for an analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.OWNER is
'Owner of the analytic view level grouping'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.CACHE_TYPE is
'Materialized View name associated to this level group'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the level grouping'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the level grouping'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.LEVEL_NAME is
'Name of the level within the hierarchy in the level grouping'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.MEASURE_NAME is
'Measure name within this measure list'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.AV_LVLGRP_ORDER is
'Order of the level groups in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.LEVEL_MEAS_ORDER is
'Order of the Levels/Measures in the level group'
/
comment on column DBA_ANALYTIC_VIEW_LVLGRPS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_LVLGRPS
FOR SYS.DBA_ANALYTIC_VIEW_LVLGRPS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_LVLGRPS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_LVLGRPS', 'CDB_ANALYTIC_VIEW_LVLGRPS');
grant select on SYS.CDB_ANALYTIC_VIEW_LVLGRPS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_LVLGRPS
for SYS.CDB_ANALYTIC_VIEW_LVLGRPS
/

create or replace view USER_ANALYTIC_VIEW_LVLGRPS
as
select ANALYTIC_VIEW_NAME, CACHE_TYPE, DIMENSION_ALIAS,
       HIER_ALIAS, LEVEL_NAME, MEASURE_NAME, AV_LVLGRP_ORDER,
       LEVEL_MEAS_ORDER, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_LVLGRPS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_LVLGRPS is
'Level groupings for an analytic view'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.CACHE_TYPE is
'Materialized View name associated to this level group'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the level grouping'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the level grouping'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.LEVEL_NAME is
'Name of the level within the hierarchy in the level grouping'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.MEASURE_NAME is
'Measure name within this measure list'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.AV_LVLGRP_ORDER is
'Order of the level groups in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.LEVEL_MEAS_ORDER is
'Order of the levels/measures in the level group'
/
comment on column USER_ANALYTIC_VIEW_LVLGRPS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_LVLGRPS
FOR SYS.USER_ANALYTIC_VIEW_LVLGRPS
/
grant read on USER_ANALYTIC_VIEW_LVLGRPS to public
/

create or replace view ALL_ANALYTIC_VIEW_LVLGRPS
as
select owner,
       ANALYTIC_VIEW_NAME,
       CACHE_TYPE,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       LEVEL_NAME,
       MEASURE_NAME,
       AV_LVLGRP_ORDER,
       LEVEL_MEAS_ORDER,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_LVLGRPS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_LVLGRPS is
'Level groupings for an analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.OWNER is
'Owner of the analytic view level grouping'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.CACHE_TYPE is
'Materialized View name associated to this level group'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the level grouping'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the level grouping'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.LEVEL_NAME is
'Name of the level within the hierarchy in the level grouping'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.MEASURE_NAME is
'Measure Name within this measure list'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.AV_LVLGRP_ORDER is
'Order of the level groups in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.LEVEL_MEAS_ORDER is
'Order of the levels/measures in the level group'
/
comment on column ALL_ANALYTIC_VIEW_LVLGRPS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_LVLGRPS
FOR SYS.ALL_ANALYTIC_VIEW_LVLGRPS
/
grant read on ALL_ANALYTIC_VIEW_LVLGRPS to public
/

create or replace view INT$DBA_AVIEW_ATTR_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       avd.alias DIMENSION_ALIAS,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avh.hier_alias HIER_ALIAS,
       avc.col_name ATTRIBUTE_NAME,
       c.clsfction_name CLASSIFICATION,
       c.clsfction_value VALUE,
       c.clsfction_lang language,
       c.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from obj$ o, hcs_av_clsfctn$ c, user$ u, hcs_av_hier$ avh, 
     hcs_av_dim$ avd, hcs_av_col$ avc
where o.owner# = u.user#
      and c.av# = o.obj#
      and avh.av# = c.av#
      and avd.av# = avh.av#
      and c.av_dim# = avh.av_dim#
      and avh.av_dim# = avd.av_dim#
      and c.av_hier# = avh.hier#
      and avc.av# = c.av#
      and avc.av_dim# = c.av_dim#
      and avc.av_hier# = c.av_hier#
      and avc.sub_obj# = c.sub_obj#
      and avc.sub_obj_type = c.obj_type
      and avc.role not in (5, 6)
      and c.obj_type in (4, 11) -- DIM OR HIER ATTRIBUTE
/

create or replace view DBA_ANALYTIC_VIEW_ATTR_CLASS
as
select owner, analytic_view_name, dimension_alias, hier_alias,
       attribute_name, classification, value, language, order_num,
       origin_con_id
from int$DBA_AVIEW_ATTR_CLASS
/

comment on table DBA_ANALYTIC_VIEW_ATTR_CLASS is
'Analytic view attribute classifications in the database'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.OWNER is
'Owner of the analytic view attribute classification'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of the attribute within the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.CLASSIFICATION is
'Name of analytic view attribute classification'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.VALUE is
'Value of attribute classification'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.LANGUAGE is
'Language of attribute classification'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.ORDER_NUM is
'Order number of attribute classification'
/
comment on column DBA_ANALYTIC_VIEW_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_ATTR_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_ATTR_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_ATTR_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_ATTR_CLASS', 'CDB_ANALYTIC_VIEW_ATTR_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_ATTR_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_ATTR_CLASS
for SYS.CDB_ANALYTIC_VIEW_ATTR_CLASS
/

create or replace view USER_ANALYTIC_VIEW_ATTR_CLASS
as
select ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       ATTRIBUTE_NAME,
       CLASSIFICATION,
       VALUE,
       language,
       ORDER_NUM,
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_ATTR_CLASS)
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_ATTR_CLASS is
'Analytic view attribute classifications in the database'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of the attribute within in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.CLASSIFICATION is
'Name of analytic view attribute classification'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.VALUE is
'Value of attribute classification'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.LANGUAGE is
'Language of attribute classification'
/
comment on column USER_ANALYTIC_VIEW_ATTR_CLASS.ORDER_NUM is
'Order number of attribute classification'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_ATTR_CLASS
FOR SYS.USER_ANALYTIC_VIEW_ATTR_CLASS
/
grant read on USER_ANALYTIC_VIEW_ATTR_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_ATTR_CLASS
as
select owner,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       ATTRIBUTE_NAME,
       CLASSIFICATION,
       VALUE,
       language,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_ATTR_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_ATTR_CLASS is
'analytic view attribute classifications in the database'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.OWNER is
'Owner of the analytic view attribute classification'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.ATTRIBUTE_NAME is
'Name of the attribute within the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.CLASSIFICATION is
'Name of analytic view attribute classification'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.VALUE is
'Value of attribute classification'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.LANGUAGE is
'Language of attribute classification'
/
comment on column ALL_ANALYTIC_VIEW_ATTR_CLASS.ORDER_NUM is
'Order number of attribute classification'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_ATTR_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_ATTR_CLASS
/
grant read on ALL_ANALYTIC_VIEW_ATTR_CLASS to public
/

create or replace view INT$DBA_AVIEW_HIER_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_ALIAS,
       avh.hier_alias HIER_ALIAS,
       c.clsfction_name CLASSIFICATION,
       c.clsfction_value VALUE,
       c.clsfction_lang language,
       c.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_av_clsfctn$ c, user$ u, hcs_av_hier$ avh, hcs_av_dim$ avd
where o.owner# = u.user#
      and c.av# = o.obj#
      and avh.av# = c.av#
      and c.obj_type = '8' -- ANALYTIC VIEW HIERARCHY
      and c.av_dim# = avd.av_dim#
      and avh.hier# = c.av_hier#
      and avh.av_dim# = avd.av_dim#
      and avh.av# = avd.av#
/

create or replace view DBA_ANALYTIC_VIEW_HIER_CLASS 
as
SELECT OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, CLASSIFICATION,
  VALUE, LANGUAGE, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_HIER_CLASS
/


comment on table DBA_ANALYTIC_VIEW_HIER_CLASS is
'Analytic view hierarchy Classifications in the database'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.OWNER is
'Owner of the analytic view hierarchy classification'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.CLASSIFICATION is
'Name of analytic view hierarchy classification'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.VALUE is
'Value of hierarchy classification'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.LANGUAGE is
'Language of hierarchy classification'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.ORDER_NUM is
'Order number of hierarchy classification'
/
comment on column DBA_ANALYTIC_VIEW_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_HIER_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_HIER_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_HIER_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_HIER_CLASS', 'CDB_ANALYTIC_VIEW_HIER_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_HIER_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_HIER_CLASS
for SYS.CDB_ANALYTIC_VIEW_HIER_CLASS
/

create or replace view USER_ANALYTIC_VIEW_HIER_CLASS
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, CLASSIFICATION,
       VALUE, language, ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_HIER_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_HIER_CLASS is
'Analytic view hierarchy classifications in the database'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.CLASSIFICATION is
'Name of analytic view hierarchy classification'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.VALUE is
'Value of hierarchy classification'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.LANGUAGE is
'Language of hierarchy classification'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.ORDER_NUM is
'Order number of hierarchy classification'
/
comment on column USER_ANALYTIC_VIEW_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_HIER_CLASS
FOR SYS.USER_ANALYTIC_VIEW_HIER_CLASS
/
grant read on USER_ANALYTIC_VIEW_HIER_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_HIER_CLASS
as
select owner,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       CLASSIFICATION,
       VALUE,
       language,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_HIER_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_HIER_CLASS is
'Analytic view hierarchy classifications in the database'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.OWNER is
'Owner of the analytic view hierarchy classification'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.CLASSIFICATION is
'Name of analytic view hierarchy classification'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.VALUE is
'Value of hierarchy classification'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.LANGUAGE is
'Language of hierarchy classification'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.ORDER_NUM is
'Order number of hierarchy classification'
/
comment on column ALL_ANALYTIC_VIEW_HIER_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_HIER_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_HIER_CLASS
/
grant read on ALL_ANALYTIC_VIEW_HIER_CLASS to public
/

create or replace view INT$DBA_AVIEW_LEVEL_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_ALIAS,
       avh.hier_alias HIER_ALIAS,
       avl.lvl_name LEVEL_NAME,
       c.clsfction_name CLASSIFICATION,
       c.clsfction_value VALUE,
       c.clsfction_lang language,
       c.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, hcs_av_clsfctn$ c, user$ u, 
     hcs_av_hier$ avh, hcs_av_dim$ avd, hcs_av_lvl$ avl
where o.owner# = u.user#
      and c.av# = o.obj#
      and avh.av# = c.av#
      and avd.av# = avh.av#
      and c.av_dim# = avh.av_dim#
      and avh.av_dim# = avd.av_dim#
      and c.av_hier# = avh.hier#
      and avl.av# = c.av#
      and avl.av_dim# = c.av_dim#
      and avl.av_hier# = c.av_hier#
      and avl.lvl# = c.sub_obj#
      and c.obj_type = '9' -- ANALYTIC VIEW LEVEL
/

create or replace view DBA_ANALYTIC_VIEW_LEVEL_CLASS 
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, LEVEL_NAME, 
       CLASSIFICATION, VALUE, LANGUAGE, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_LEVEL_CLASS
/

comment on table DBA_ANALYTIC_VIEW_LEVEL_CLASS is
'Analytic View Level Classifications in the database'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.OWNER is
'Owner of the analytic view level classification'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.CLASSIFICATION is
'Name of analytic view level classification'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.VALUE is
'Value of level classification'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.LANGUAGE is
'Language of level classification'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.ORDER_NUM is
'Order number of level classification'
/
comment on column DBA_ANALYTIC_VIEW_LEVEL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_LEVEL_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_LEVEL_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_LEVEL_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_LEVEL_CLASS', 'CDB_ANALYTIC_VIEW_LEVEL_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_LEVEL_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_LEVEL_CLASS
for SYS.CDB_ANALYTIC_VIEW_LEVEL_CLASS
/

create or replace view USER_ANALYTIC_VIEW_LEVEL_CLASS
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_ALIAS, LEVEL_NAME,
       CLASSIFICATION, VALUE, language, ORDER_NUM, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_LEVEL_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_LEVEL_CLASS is
'Analytic view level classifications in the database'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.CLASSIFICATION is
'Name of analytic view level classification'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.VALUE is
'Value of level classification'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.LANGUAGE is
'Language of level classification'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.ORDER_NUM is
'Order number of level classification'
/
comment on column USER_ANALYTIC_VIEW_LEVEL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_LEVEL_CLASS
FOR SYS.USER_ANALYTIC_VIEW_LEVEL_CLASS
/
grant read on USER_ANALYTIC_VIEW_LEVEL_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_LEVEL_CLASS
as
select owner,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_ALIAS,
       LEVEL_NAME,
       CLASSIFICATION,
       VALUE,
       language,
       ORDER_NUM,
       origin_con_id
from INT$DBA_AVIEW_LEVEL_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_LEVEL_CLASS is
'analytic view level classifications in the database'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.OWNER is
'Owner of the analytic view level classification'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.ANALYTIC_VIEW_NAME is
'Name of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.HIER_ALIAS is
'Alias of the hierarchy within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.LEVEL_NAME is
'Name of the level within the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.CLASSIFICATION is
'Name of analytic view level classification'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.VALUE is
'Value of level classification'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.LANGUAGE is
'Language of level classification'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.ORDER_NUM is
'Order number of level classification'
/
comment on column ALL_ANALYTIC_VIEW_LEVEL_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_LEVEL_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_LEVEL_CLASS
/
grant read on ALL_ANALYTIC_VIEW_LEVEL_CLASS to public
/

create or replace view INT$DBA_HIER_HIER_ATTR_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name hier_name,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       ha.attr_name HIER_ATTR_NAME,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_hier_attr$ ha
where u.user# = o.owner#
      and c.obj# = o.obj#
      and c.obj_type = '11' -- HIERARCHICAL ATTRIBUTE
      and ha.hier# = c.obj#
      and ha.attr# = c.sub_obj#
/

create or replace view DBA_HIER_HIER_ATTR_CLASS
as 
select OWNER, HIER_NAME, HIER_ATTR_NAME, CLASSIFICATION, VALUE, LANGUAGE,
    ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_HIER_HIER_ATTR_CLASS
/

comment on table DBA_HIER_HIER_ATTR_CLASS is
'Hierarchy hierarchical attribute classifications in the database'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.OWNER is
'Owner of the hierarchical attribute classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.HIER_NAME is
'Name of owning hierarchy of the hierarchical attribute'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.HIER_ATTR_NAME is
'Name of owning hierarchical attribute of the classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.CLASSIFICATION is
'Name of hierarchical attribute classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.VALUE is
'Value of hierarchical attribute classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.LANGUAGE is
'Language of hierarchical attribute classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.ORDER_NUM is
'Order number of hierarchical attribute classification'
/
comment on column DBA_HIER_HIER_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_HIER_ATTR_CLASS
FOR SYS.DBA_HIER_HIER_ATTR_CLASS
/
GRANT SELECT ON DBA_HIER_HIER_ATTR_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_HIER_ATTR_CLASS', 'CDB_HIER_HIER_ATTR_CLASS');
grant select on SYS.CDB_HIER_HIER_ATTR_CLASS to select_catalog_role
/
create or replace public synonym CDB_HIER_HIER_ATTR_CLASS
for SYS.CDB_HIER_HIER_ATTR_CLASS
/

create or replace view USER_HIER_HIER_ATTR_CLASS
as
select hier_name, HIER_ATTR_NAME, classification,
       value, language, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_HIER_ATTR_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_HIER_ATTR_CLASS is
'Hierarchical attribute classifications in the database'
/
comment on column USER_HIER_HIER_ATTR_CLASS.HIER_NAME is
'Name of owning hierarchy of the hierarchical attribute'
/
comment on column USER_HIER_HIER_ATTR_CLASS.HIER_ATTR_NAME is
'Name of owning hierarchical attribute of the classification'
/
comment on column USER_HIER_HIER_ATTR_CLASS.CLASSIFICATION is
'Name of hierarchical attribute classification'
/
comment on column USER_HIER_HIER_ATTR_CLASS.VALUE is
'Value of hierarchical attribute classification'
/
comment on column USER_HIER_HIER_ATTR_CLASS.LANGUAGE is
'Language of hierarchical attribute classification'
/
comment on column USER_HIER_HIER_ATTR_CLASS.ORDER_NUM is
'Order number of hierarchical attribute classification'
/
comment on column USER_HIER_HIER_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_HIER_ATTR_CLASS
FOR SYS.USER_HIER_HIER_ATTR_CLASS
/
grant read on USER_HIER_HIER_ATTR_CLASS to public
/

create or replace view ALL_HIER_HIER_ATTR_CLASS
as
select owner,
       hier_name,
       HIER_ATTR_NAME,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from INT$DBA_HIER_HIER_ATTR_CLASS
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_HIER_ATTR_CLASS is
'Hierarchical attribute classifications in the database'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.OWNER is
'Owner of the hierarchical attribute classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.HIER_NAME is
'Name of owning hierarchy of the hierarchical attribute'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.HIER_ATTR_NAME is
'Name of owning hierarchical attribute of the classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.CLASSIFICATION is
'Name of hierarchical attribute classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.VALUE is
'Value of hierarchical attribute classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.LANGUAGE is
'Language of hierarchical attribute classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.ORDER_NUM is
'Order number of hierarchical attribute classification'
/
comment on column ALL_HIER_HIER_ATTR_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_HIER_ATTR_CLASS
FOR SYS.ALL_HIER_HIER_ATTR_CLASS
/
grant read on ALL_HIER_HIER_ATTR_CLASS to public
/

create or replace view INT$DBA_HIER_HIER_ATTRIBUTES SHARING=EXTENDED DATA
as
select u.name owner,
       o.name hier_name,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       ha.attr_name HIER_ATTR_NAME,
       ha.expr EXPRESSION,
       ha.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, user$ u, hcs_hier_attr$ ha
where u.user# = o.owner#
      and ha.hier# = o.obj#
/

create or replace view DBA_HIER_HIER_ATTRIBUTES
as 
select OWNER, HIER_NAME, HIER_ATTR_NAME, EXPRESSION, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_HIER_HIER_ATTRIBUTES
/

comment on table DBA_HIER_HIER_ATTRIBUTES is
'Attribute dimension attributes in the database'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.OWNER is
'Owner of the hierarchical attribute'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.HIER_NAME is
'Name of the owning hierarchy of the hierarchical attribute'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.HIER_ATTR_NAME is
'Name of the hierarchical attribute'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.EXPRESSION is
'Expression defining the hierarchical attribute'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.ORDER_NUM is
'Order number of hierarchical attribute within the hierarchy'
/
comment on column DBA_HIER_HIER_ATTRIBUTES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_HIER_ATTRIBUTES
FOR SYS.DBA_HIER_HIER_ATTRIBUTES
/
GRANT SELECT ON DBA_HIER_HIER_ATTRIBUTES to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_HIER_ATTRIBUTES', 'CDB_HIER_HIER_ATTRIBUTES');
grant select on SYS.CDB_HIER_HIER_ATTRIBUTES to select_catalog_role
/
create or replace public synonym CDB_HIER_HIER_ATTRIBUTES
for SYS.CDB_HIER_HIER_ATTRIBUTES
/

create or replace view USER_HIER_HIER_ATTRIBUTES
as
select hier_name, HIER_ATTR_NAME, EXPRESSION, ORDER_NUM,
       origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_HIER_ATTRIBUTES)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_HIER_ATTRIBUTES is
'Attribute dimension attributes in the database'
/
comment on column USER_HIER_HIER_ATTRIBUTES.HIER_NAME is
'Name of the owning hierarchy of the hierarchical attribute'
/
comment on column USER_HIER_HIER_ATTRIBUTES.HIER_ATTR_NAME is
'Name of the hierarchical attribute'
/
comment on column USER_HIER_HIER_ATTRIBUTES.EXPRESSION is
'Expression defining the hierarchical attribute'
/
comment on column USER_HIER_HIER_ATTRIBUTES.ORDER_NUM is
'Order number of hierarchical attribute within the hierarchy'
/
comment on column USER_HIER_HIER_ATTRIBUTES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_HIER_ATTRIBUTES
FOR SYS.USER_HIER_HIER_ATTRIBUTES
/
grant read on USER_HIER_HIER_ATTRIBUTES to public
/

create or replace view ALL_HIER_HIER_ATTRIBUTES
as
select owner,
       hier_name,
       HIER_ATTR_NAME,
       EXPRESSION,
       ORDER_NUM,
       origin_con_id
from INT$DBA_HIER_HIER_ATTRIBUTES
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_HIER_ATTRIBUTES is
'attribute dimension Attributes in the database'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.HIER_NAME is
'Name of the owning Hierarchy of the Hierarchical Attribute'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.OWNER is
'Owner of the Hierarchical Attribute'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.HIER_ATTR_NAME is
'Name of the Hierarchical Attribute'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.EXPRESSION is
'Expression defining the hierarchical attribute'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.ORDER_NUM is
'Order number of Hierarchical Attribute within the Hierarchy'
/
comment on column ALL_HIER_HIER_ATTRIBUTES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_HIER_ATTRIBUTES
FOR SYS.ALL_HIER_HIER_ATTRIBUTES
/
grant read on ALL_HIER_HIER_ATTRIBUTES to public
/

-- ANALYTIC_VIEW_CLASS
create or replace view INT$DBA_AVIEW_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_analytic_view$ av
where u.user# = o.owner#
      and c.obj# = o.obj#
      and c.obj_type = '3' -- ANALYTIC VIEW
      and av.obj# = c.obj#
/

create or replace view DBA_ANALYTIC_VIEW_CLASS
as 
  select OWNER, ANALYTIC_VIEW_NAME, CLASSIFICATION, VALUE, LANGUAGE, ORDER_NUM,
  ORIGIN_CON_ID
from INT$DBA_AVIEW_CLASS
/

comment on table DBA_ANALYTIC_VIEW_CLASS is
'Analytic View Classifications in the database'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.OWNER is
'Owner of the analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.ANALYTIC_VIEW_NAME is
'analytic view name of owning analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.CLASSIFICATION is
'Name of analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.VALUE is
'Value of analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.LANGUAGE is
'Language of analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.ORDER_NUM is
'Order number of analytic view classification'
/
comment on column DBA_ANALYTIC_VIEW_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_CLASS', 'CDB_ANALYTIC_VIEW_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_CLASS
for SYS.CDB_ANALYTIC_VIEW_CLASS
/

create or replace view USER_ANALYTIC_VIEW_CLASS
as
select analytic_view_name, classification, value, language,
       order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_CLASS)
where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_CLASS is
'Analytic view classifications in the database'
/
comment on column USER_ANALYTIC_VIEW_CLASS.ANALYTIC_VIEW_NAME is
'Analytic view name of owning analytic view classification'
/
comment on column USER_ANALYTIC_VIEW_CLASS.CLASSIFICATION is
'Name of analytic view classification'
/
comment on column USER_ANALYTIC_VIEW_CLASS.VALUE is
'Value of analytic view classification'
/
comment on column USER_ANALYTIC_VIEW_CLASS.LANGUAGE is
'Language of analytic view classification'
/
comment on column USER_ANALYTIC_VIEW_CLASS.ORDER_NUM is
'Order number of analytic view classification'
/
comment on column USER_ANALYTIC_VIEW_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_CLASS
FOR SYS.USER_ANALYTIC_VIEW_CLASS
/
grant read on USER_ANALYTIC_VIEW_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_CLASS
as
select owner,
       analytic_view_name,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from INT$DBA_AVIEW_CLASS
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_CLASS is
'Analytic view classifications in the database'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.OWNER is
'Owner of the analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.ANALYTIC_VIEW_NAME is
'analytic view  name of owning analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.CLASSIFICATION is
'Name of analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.VALUE is
'Value of analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.LANGUAGE is
'Language of analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.ORDER_NUM is
'Order number of analytic view classification'
/
comment on column ALL_ANALYTIC_VIEW_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_CLASS
/
grant read on ALL_ANALYTIC_VIEW_CLASS to public
/

create or replace view INT$DBA_AVIEW_MEAS_CLASS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       m.meas_name measure_name,
       c.clsfction_name classification,
       c.clsfction_value value,
       c.clsfction_lang language,
       c.order_num order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from   sys.obj$ o, hcs_clsfctn$ c, user$ u, hcs_av_meas$ m
where   u.user# = o.owner#
        and c.obj# = o.obj#
        and c.obj_type = '7' -- MEASURE
        and m.av# = c.obj#
        and m.meas# = c.sub_obj#
/

create or replace view DBA_ANALYTIC_VIEW_MEAS_CLASS 
as
select OWNER, ANALYTIC_VIEW_NAME, MEASURE_NAME, CLASSIFICATION, VALUE,
        LANGUAGE, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_MEAS_CLASS
/

comment on table DBA_ANALYTIC_VIEW_MEAS_CLASS is
'Analytic View measure classifications in the database'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.OWNER is
'Owner of the analytic view measure classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.ANALYTIC_VIEW_NAME is
'Name of owning analytic view of the measure'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.MEASURE_NAME is
'Name of owning measure of the classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.CLASSIFICATION is
'Name of analytic view measure classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.VALUE is
'Value of analytic view measure classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.LANGUAGE is
'Language of analytic view measure classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.ORDER_NUM is
'Order number of analytic view measure classification'
/
comment on column DBA_ANALYTIC_VIEW_MEAS_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_MEAS_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_MEAS_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_MEAS_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_MEAS_CLASS', 'CDB_ANALYTIC_VIEW_MEAS_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_MEAS_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_MEAS_CLASS
for SYS.CDB_ANALYTIC_VIEW_MEAS_CLASS
/

create or replace view USER_ANALYTIC_VIEW_MEAS_CLASS
as
select analytic_view_name, measure_name, classification, value,
       language, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_MEAS_CLASS)
where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')

/

comment on table USER_ANALYTIC_VIEW_MEAS_CLASS is
'Analytic view measure classifications in the database'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.ANALYTIC_VIEW_NAME is
'Name of owning analytic view of the measure'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.MEASURE_NAME is
'Name of owning measure of the classification'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.CLASSIFICATION is
'Name of analytic view measure classification'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.VALUE is
'Value of analytic view measure classification'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.LANGUAGE is
'Language of analytic view measure classification'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.ORDER_NUM is
'Order number of analytic view measure classification'
/
comment on column USER_ANALYTIC_VIEW_MEAS_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_MEAS_CLASS
FOR SYS.USER_ANALYTIC_VIEW_MEAS_CLASS
/
grant read on USER_ANALYTIC_VIEW_MEAS_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_MEAS_CLASS
as
select owner,
       analytic_view_name,
       measure_name,
       classification,
       value,
       language,
       order_num,
       origin_con_id
from INT$DBA_AVIEW_MEAS_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_MEAS_CLASS is
'Analytic view measure classifications in the database'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.OWNER is
'Owner of the analytic view measure classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.ANALYTIC_VIEW_NAME is
'Name of owning analytic view of the measure'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.MEASURE_NAME is
'Name of owning measure of the classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.CLASSIFICATION is
'Name of analytic view measure classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.VALUE is
'Value of analytic view measure classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.LANGUAGE is
'Language of analytic view measure classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.ORDER_NUM is
'Order number of analytic view measure classification'
/
comment on column ALL_ANALYTIC_VIEW_MEAS_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_MEAS_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_MEAS_CLASS
/
grant read on ALL_ANALYTIC_VIEW_MEAS_CLASS to public
/

-- Create views on analytic view dimension classifications

create or replace view INT$DBA_AVIEW_DIM_CLASS SHARING=EXTENDED DATA
as
select u.name OWNER,
       co.name ANALYTIC_VIEW_NAME,
       co.owner# owner_id,
       co.obj# object_id,
       co.type# object_type,
       avd.alias DIMENSION_ALIAS,
       c.clsfction_name CLASSIFICATION,
       c.clsfction_value VALUE,
       c.clsfction_lang language,
       c.order_num ORDER_NUM,
       case when bitand(co.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ co, hcs_av_dim$ avd, hcs_clsfctn$ c, user$ u
where co.owner# = u.user#
      and avd.av# = co.obj#
      and co.obj# = c.obj#
      and c.obj_type = '6' -- ANALYTIC VIEW DIM
      and avd.av_dim# = c.sub_obj#
/

create or replace view DBA_ANALYTIC_VIEW_DIM_CLASS 
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, CLASSIFICATION, VALUE,
    LANGUAGE, ORDER_NUM, origin_con_id
from INT$DBA_AVIEW_DIM_CLASS
/

comment on table DBA_ANALYTIC_VIEW_DIM_CLASS is
'Classifications of the analytic view dimensions in the database'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.OWNER is
'Owner of the analytic view dimension'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.CLASSIFICATION is
'Name of analytic view dimension classification'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.VALUE is
'Value of analytic view dimension classification'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.LANGUAGE is
'Language of analytic view dimension classification'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.ORDER_NUM is
'Order of the classification in the list of classifications 
 associated with the dimension key'
/
comment on column DBA_ANALYTIC_VIEW_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_DIM_CLASS
FOR SYS.DBA_ANALYTIC_VIEW_DIM_CLASS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_DIM_CLASS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_DIM_CLASS', 'CDB_ANALYTIC_VIEW_DIM_CLASS');
grant select on SYS.CDB_ANALYTIC_VIEW_DIM_CLASS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_DIM_CLASS
for SYS.CDB_ANALYTIC_VIEW_DIM_CLASS
/

create or replace view USER_ANALYTIC_VIEW_DIM_CLASS
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, CLASSIFICATION, VALUE,
       language, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_DIM_CLASS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_DIM_CLASS is
'Classifications of the analytic view dimensions in the database'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.CLASSIFICATION is
'Name of analytic view dimension classification'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.VALUE is
'Value of analytic view dimension classification'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.LANGUAGE is
'Language of analytic view dimension classification'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.ORDER_NUM is
'Order of the classification in the list of classifications 
 associated with the dimension key'
/
comment on column USER_ANALYTIC_VIEW_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_DIM_CLASS
FOR SYS.USER_ANALYTIC_VIEW_DIM_CLASS
/
grant read on USER_ANALYTIC_VIEW_DIM_CLASS to public
/

create or replace view ALL_ANALYTIC_VIEW_DIM_CLASS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       CLASSIFICATION,
       VALUE,
       language,
       order_num,
       origin_con_id
from INT$DBA_AVIEW_DIM_CLASS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_DIM_CLASS is
'Classifications of the analytic view dimensions in the database'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.OWNER is
'Owner of the analytic view dimension'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.CLASSIFICATION is
'Name of analytic view dimension classification'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.VALUE is
'Value of analytic view dimension classification'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.LANGUAGE is
'Language of analytic view dimension classification'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.ORDER_NUM is
'Order of the classification in the list of classifications 
 associated with the dimension key'
/
comment on column ALL_ANALYTIC_VIEW_DIM_CLASS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_DIM_CLASS
FOR SYS.ALL_ANALYTIC_VIEW_DIM_CLASS
/
grant read on ALL_ANALYTIC_VIEW_DIM_CLASS to public
/

-- Create views on attribute dimension

create or replace view INT$DBA_ATTR_DIM SHARING=EXTENDED DATA
as
select u.name owner,
       o.name dimension_name,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,       
       DECODE(d.dim_type, 1, 'STANDARD', 2, 'TIME') DIMENSION_TYPE,
       d.all_member_name ALL_MEMBER_NAME,
       d.all_member_caption ALL_MEMBER_CAPTION,
       d.all_member_desc ALL_MEMBER_DESCRIPTION,
     --MEMBER_NAME_ATTR,
     --MEMBER_CAPTION_ATTR,
     --MEMBER_DESCRIPTION_ATTR,
       DECODE(o.status, 0, 'N/A', 1, 'VALID', 'INVALID') COMPILE_STATE,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_dim$ d, user$ u
where o.owner# = u.user#
      and d.obj# = o.obj#
/
create or replace view DBA_ATTRIBUTE_DIMENSIONS 
AS
select OWNER, DIMENSION_NAME, DIMENSION_TYPE, ALL_MEMBER_NAME, 
       ALL_MEMBER_CAPTION, ALL_MEMBER_DESCRIPTION, COMPILE_STATE, 
       ORIGIN_CON_ID
from INT$DBA_ATTR_DIM;


comment on table DBA_ATTRIBUTE_DIMENSIONS is
'Attribute dimensions in the database'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.DIMENSION_TYPE is
'Indication of whether the attribute dimension is a time dimension'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_NAME is
'ALL member name of the attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_CAPTION is
'ALL member caption of the attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'ALL member description of the attribute dimension'
/
--comment on column DBA_ATTRIBUTE_DIMENSIONS.MEMBER_NAME_ATTR is
--'Member name attribute of PARENT CHILD attribute dimension'
--/
--comment on column DBA_ATTRIBUTE_DIMENSIONS.MEMBER_CAPTION_ATTR is
--'Member caption attribute of PARENT CHILD attribute dimension'
--/
--comment on column DBA_ATTRIBUTE_DIMENSIONS.MEMBER_DESCRIPTION_ATTR is
--'Member description attribute of PARENT CHILD attribute dimension'
--/
comment on column DBA_ATTRIBUTE_DIMENSIONS.COMPILE_STATE is
'Compile state of the attribute dimension: N/A, VALID, or INVALID'
/
comment on column DBA_ATTRIBUTE_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIMENSIONS
FOR SYS.DBA_ATTRIBUTE_DIMENSIONS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIMENSIONS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIMENSIONS', 'CDB_ATTRIBUTE_DIMENSIONS');
grant select on SYS.CDB_ATTRIBUTE_DIMENSIONS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIMENSIONS
for SYS.CDB_ATTRIBUTE_DIMENSIONS
/

create or replace view USER_ATTRIBUTE_DIMENSIONS
as
select dimension_name, DIMENSION_TYPE, ALL_MEMBER_NAME,
       ALL_MEMBER_CAPTION, ALL_MEMBER_DESCRIPTION,
     --MEMBER_NAME_ATTR,
     --MEMBER_CAPTION_ATTR,
     --MEMBER_DESCRIPTION_ATTR,
       COMPILE_STATE, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM)
where owner=SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIMENSIONS is
'attribute dimensions in the database'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.DIMENSION_TYPE is
'Indication of whether the attribute dimension is a time dimension'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_NAME is
'ALL member name of the attribute dimension'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_CAPTION is
'ALL member caption of the attribute dimension'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'ALL member description of the attribute dimension'
/
--comment on column USER_ATTRIBUTE_DIMENSIONS.MEMBER_NAME_ATTR is
--'Member name attribute of PARENT CHILD attribute dimension'
--/
--comment on column USER_ATTRIBUTE_DIMENSIONS.MEMBER_CAPTION_ATTR is
--'Member caption attribute of PARENT CHILD attribute dimension'
--/
--comment on column USER_ATTRIBUTE_DIMENSIONS.MEMBER_DESCRIPTION_ATTR is
--'Member description attribute of PARENT CHILD attribute dimension'
--/
comment on column USER_ATTRIBUTE_DIMENSIONS.COMPILE_STATE is
'Compile state of the attribute dimension: N/A, VALID, or INVALID'
/
comment on column USER_ATTRIBUTE_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIMENSIONS
FOR SYS.USER_ATTRIBUTE_DIMENSIONS
/
grant read on USER_ATTRIBUTE_DIMENSIONS to public
/

create or replace view ALL_ATTRIBUTE_DIMENSIONS
as
select owner,
       dimension_name,
       DIMENSION_TYPE,
       ALL_MEMBER_NAME,
       ALL_MEMBER_CAPTION,
       ALL_MEMBER_DESCRIPTION,
     --MEMBER_NAME_ATTR,
     --MEMBER_CAPTION_ATTR,
     --MEMBER_DESCRIPTION_ATTR,
       COMPILE_STATE,
       origin_con_id
from INT$DBA_ATTR_DIM 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIMENSIONS is
'attribute dimensions in the database'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.DIMENSION_TYPE is
'Indication of whether the attribute dimension is a time dimension'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_NAME is
'ALL member name of the attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_CAPTION is
'ALL member caption of the attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'ALL member description of the attribute dimension'
/
--comment on column ALL_ATTRIBUTE_DIMENSIONS.MEMBER_NAME_ATTR is
--'Member name attribute of PARENT CHILD attribute dimension'
--/
--comment on column ALL_ATTRIBUTE_DIMENSIONS.MEMBER_CAPTION_ATTR is
--'Member caption attribute of PARENT CHILD attribute dimension'
--/
--comment on column ALL_ATTRIBUTE_DIMENSIONS.MEMBER_DESCRIPTION_ATTR is
--'Member description attribute of PARENT CHILD attribute dimension'
--/
comment on column ALL_ATTRIBUTE_DIMENSIONS.COMPILE_STATE is
'Compile state of the attribute dimension: N/A, VALID, or INVALID'
/
comment on column ALL_ATTRIBUTE_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIMENSIONS
FOR SYS.ALL_ATTRIBUTE_DIMENSIONS
/
grant read on ALL_ATTRIBUTE_DIMENSIONS to public
/

create or replace view INT$DBA_ATTR_DIM_ATTRS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name DIMENSION_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       da.attr_name ATTRIBUTE_NAME,
       sc.table_alias TABLE_ALIAS,
       sc.src_col_name COLUMN_NAME,
       da.order_num,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, SYS.obj$ co, 
     hcs_dim_attr$ da, hcs_dim$ d, hcs_src_col$ sc, user$ u
where o.owner# = u.user#
      and da.dim# = o.obj#
      and d.obj# = da.dim#
      and da.src_col# = sc.src_col#
      and sc.obj_type = 4 -- HCSDDL_DICT_TYPE_ATTR
      and da.dim# = sc.obj#
      and co.obj# = sc.obj#
      and co.owner# = o.owner#
/


create or replace view DBA_ATTRIBUTE_DIM_ATTRS
as
select OWNER, DIMENSION_NAME, ATTRIBUTE_NAME, TABLE_ALIAS, COLUMN_NAME,
    ORDER_NUM, origin_con_id
from INT$DBA_ATTR_DIM_ATTRS
/

comment on table DBA_ATTRIBUTE_DIM_ATTRS is
'Attribute dimension attributes in the database'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension of the Attribute'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.OWNER is
'Owner of the attribute dimension attribute'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.ATTRIBUTE_NAME is
'Name of the attribute owned by the attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.COLUMN_NAME is
'Column name in the table or view on which this attribute is defined'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.ORDER_NUM is
'Order number of attribute dimension attribute within the Dimension'
/
comment on column DBA_ATTRIBUTE_DIM_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_ATTRS
FOR SYS.DBA_ATTRIBUTE_DIM_ATTRS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_ATTRS', 'CDB_ATTRIBUTE_DIM_ATTRS');
grant select on SYS.CDB_ATTRIBUTE_DIM_ATTRS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_ATTRS
for SYS.CDB_ATTRIBUTE_DIM_ATTRS
/

create or replace view USER_ATTRIBUTE_DIM_ATTRS
as
select DIMENSION_NAME, ATTRIBUTE_NAME, TABLE_ALIAS,
       COLUMN_NAME, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_ATTRS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_ATTRS is
'Attribute dimension attributes in the database'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension of the attribute'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.ATTRIBUTE_NAME is
'Name of the Attribute owned by the attribute dimension'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.COLUMN_NAME is
'Column name in the table or view on which this attribute is defined'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.ORDER_NUM is
'Order number of attribute dimension Attribute within the Dimension'
/
comment on column USER_ATTRIBUTE_DIM_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_ATTRS
FOR SYS.USER_ATTRIBUTE_DIM_ATTRS
/
grant read on USER_ATTRIBUTE_DIM_ATTRS to public
/

create or replace view ALL_ATTRIBUTE_DIM_ATTRS
as
select owner,
       DIMENSION_NAME,
       ATTRIBUTE_NAME,
       TABLE_ALIAS,
       COLUMN_NAME,
       order_num,
       origin_con_id
from INT$DBA_ATTR_DIM_ATTRS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_ATTRS is
'Attribute dimension attributes in the database'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension of the attribute'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.OWNER is
'Owner of the attribute dimension attribute'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.ATTRIBUTE_NAME is
'Name of the Attribute owned by the attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.COLUMN_NAME is
'Column name in the table or view on which this attribute is defined'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.ORDER_NUM is
'Order number of attribute dimension Attribute within the Dimension'
/
comment on column ALL_ATTRIBUTE_DIM_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_ATTRS
FOR SYS.ALL_ATTRIBUTE_DIM_ATTRS
/
grant read on ALL_ATTRIBUTE_DIM_ATTRS to public
/

create or replace view INT$DBA_ATTR_DIM_TABLES SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name DIMENSION_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       src.owner TABLE_OWNER,
       src.name TABLE_NAME,
       src.alias TABLE_ALIAS,
       src.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from hcs_src$ src, sys.obj$ o, user$ u, hcs_dim$ dim
where o.owner# = u.user#
      and src.hcs_obj# = o.obj#
      and o.obj# = dim.obj#
/

create or replace view DBA_ATTRIBUTE_DIM_TABLES
as
select OWNER, DIMENSION_NAME, TABLE_OWNER, TABLE_NAME, TABLE_ALIAS,
    ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_TABLES
/

comment on table DBA_ATTRIBUTE_DIM_TABLES is
'Attribute dimension tables in the database'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.TABLE_OWNER is
'Owner of the table or view on which the attribute dimension is defined'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.TABLE_NAME is
'Name of the table or view on which the attribute dimension is defined'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.TABLE_ALIAS is
'Alias specified for the table or view, or TABLE_NAME if not specified'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.ORDER_NUM is
'Order of the table in the list of tables in the USING clause'
/
comment on column DBA_ATTRIBUTE_DIM_TABLES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_TABLES
FOR SYS.DBA_ATTRIBUTE_DIM_TABLES
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_TABLES to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_TABLES', 'CDB_ATTRIBUTE_DIM_TABLES');
grant select on SYS.CDB_ATTRIBUTE_DIM_TABLES to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_TABLES
for SYS.CDB_ATTRIBUTE_DIM_TABLES
/

create or replace view USER_ATTRIBUTE_DIM_TABLES
as
select DIMENSION_NAME, TABLE_OWNER, TABLE_NAME, TABLE_ALIAS,
       order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_TABLES)
where owner=SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_TABLES is
'Attribute dimension tables in the database'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.TABLE_OWNER is
'Owner of the table or view on which the attribute dimension is defined'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.TABLE_NAME is
'Name of the table or view on which the attribute dimension is defined'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.TABLE_ALIAS is
'Alias specified for the table or view, or TABLE_NAME if not specified'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.ORDER_NUM is
'Order of the table in the list of tables in the USING clause'
/
comment on column USER_ATTRIBUTE_DIM_TABLES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_TABLES
FOR SYS.USER_ATTRIBUTE_DIM_TABLES
/
grant read on USER_ATTRIBUTE_DIM_TABLES to public
/

create or replace view ALL_ATTRIBUTE_DIM_TABLES
as
select OWNER,
       DIMENSION_NAME,
       TABLE_OWNER,
       TABLE_NAME,
       TABLE_ALIAS,
       order_num,
       origin_con_id
from INT$DBA_ATTR_DIM_TABLES
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_TABLES is
'Attribute dimension tables in the database'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.DIMENSION_NAME is
'Name of the attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.TABLE_OWNER is
'Owner of the table or view on which the attribute dimension is defined'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.TABLE_NAME is
'Name of the table or view on which the attribute dimension is defined'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.TABLE_ALIAS is
'Alias specified for the table or view, or TABLE_NAME if not specified'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.ORDER_NUM is
'Order of the table in the list of tables in the USING clause'
/
comment on column ALL_ATTRIBUTE_DIM_TABLES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_TABLES
FOR SYS.ALL_ATTRIBUTE_DIM_TABLES
/
grant read on ALL_ATTRIBUTE_DIM_TABLES to public
/

create or replace view INT$DBA_ATTR_DIM_LEVELS SHARING=EXTENDED DATA
as
select u.name owner,
       o.name DIMENSION_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       dl.lvl_name LEVEL_NAME,
       DECODE(dl.skip_when_null, 0, 'N', 1, 'Y') SKIP_WHEN_NULL,
       DECODE(dl.lvl_type, 1, 'STANDARD', 2, 'YEARS', 3, 'HALF_YEARS', 
	4, 'QUARTERS', 5, 'MONTHS', 6, 'WEEKS', 7, 'DAYS',
	8, 'HOURS', 9, 'MINUTES', 10, 'SECONDS')  LEVEL_TYPE,
       dl.member_name MEMBER_NAME_EXPR,
       dl.member_caption MEMBER_CAPTION_EXPR,
       dl.member_desc MEMBER_DESCRIPTION_EXPR,
       order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_dim_lvl$ dl, user$ u
where o.owner# = u.user#
      and dl.dim# = o.obj#
/

create or replace view DBA_ATTRIBUTE_DIM_LEVELS
as
select OWNER, DIMENSION_NAME, LEVEL_NAME, SKIP_WHEN_NULL,
    LEVEL_TYPE, MEMBER_NAME_EXPR, MEMBER_CAPTION_EXPR,
    MEMBER_DESCRIPTION_EXPR, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_LEVELS
/

comment on table DBA_ATTRIBUTE_DIM_LEVELS is
'Attribute dimension Levels in the database'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.OWNER is
'Owner of the attribute dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.DIMENSION_NAME is
'Name of the owning attribute dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.LEVEL_NAME is
'Name of the attribute dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.SKIP_WHEN_NULL is
'Indication of whether to skip the level when the key is NULL: Y or N'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.LEVEL_TYPE is
'Type of attribute dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.MEMBER_NAME_EXPR is
'Member name expression of Dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.MEMBER_CAPTION_EXPR is
'Member caption expression of Dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.MEMBER_DESCRIPTION_EXPR is
'Member description expression of Dimension Level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.ORDER_NUM is
'Order number of Dimension Level within the Dimension'
/
comment on column DBA_ATTRIBUTE_DIM_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_LEVELS
FOR SYS.DBA_ATTRIBUTE_DIM_LEVELS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_LEVELS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_LEVELS', 'CDB_ATTRIBUTE_DIM_LEVELS');
grant select on SYS.CDB_ATTRIBUTE_DIM_LEVELS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_LEVELS
for SYS.CDB_ATTRIBUTE_DIM_LEVELS
/

create or replace view USER_ATTRIBUTE_DIM_LEVELS
as
select DIMENSION_NAME, LEVEL_NAME, SKIP_WHEN_NULL,
       LEVEL_TYPE, MEMBER_NAME_EXPR, MEMBER_CAPTION_EXPR, 
       MEMBER_DESCRIPTION_EXPR, order_num, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_LEVELS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_LEVELS is
'Attribute dimension Levels in the database'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.DIMENSION_NAME is
'Name of the owning attribute dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.LEVEL_NAME is
'Name of the attribute dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.SKIP_WHEN_NULL is
'Indication of whether to skip the level when the key is NULL: Y or N'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.LEVEL_TYPE is
'Type of attribute dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.MEMBER_NAME_EXPR is
'Member name expression of Dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.MEMBER_CAPTION_EXPR is
'Member caption expression of Dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.MEMBER_DESCRIPTION_EXPR is
'Member description expression of Dimension Level'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.ORDER_NUM is
'Order number of Dimension Level within the Dimension'
/
comment on column USER_ATTRIBUTE_DIM_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_LEVELS
FOR SYS.USER_ATTRIBUTE_DIM_LEVELS
/
grant read on USER_ATTRIBUTE_DIM_LEVELS to public
/

create or replace view ALL_ATTRIBUTE_DIM_LEVELS
as
select owner,
       DIMENSION_NAME,
       LEVEL_NAME,
       SKIP_WHEN_NULL,
       LEVEL_TYPE,
       MEMBER_NAME_EXPR,
       MEMBER_CAPTION_EXPR,
       MEMBER_DESCRIPTION_EXPR,
       order_num ,
       origin_con_id
from INT$DBA_ATTR_DIM_LEVELS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_LEVELS is
'Attribute dimension Levels in the database'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.OWNER is
'Owner of the attribute dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.DIMENSION_NAME is
'Name of the owning attribute dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.LEVEL_NAME is
'Name of the attribute dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.SKIP_WHEN_NULL is
'Indication of whether to skip the level when the key is NULL: Y or N'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.LEVEL_TYPE is
'Type of attribute dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.MEMBER_NAME_EXPR is
'Member name expression of Dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.MEMBER_CAPTION_EXPR is
'Member caption expression of Dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.MEMBER_DESCRIPTION_EXPR is
'Member description expression of Dimension Level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.ORDER_NUM is
'Order number of Dimension Level within the Dimension'
/
comment on column ALL_ATTRIBUTE_DIM_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_LEVELS
FOR SYS.ALL_ATTRIBUTE_DIM_LEVELS
/
grant read on ALL_ATTRIBUTE_DIM_LEVELS to public
/

create or replace view INT$DBA_HIERARCHIES SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name HIER_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       h.dim_owner DIMENSION_OWNER,
       h.dim_name DIMENSION_NAME,
       --da.attr_name PARENT_ATTR,
       NULL PARENT_ATTR,
       DECODE(o.status, 0, 'N/A', 1, 'VALID', 'INVALID') COMPILE_STATE,
     --DECODE(h.val_state, 1, 'VALID', 2, 'NEEDS_VALIDATE', 3, 'ERROR') VALID_STATE,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from  sys.obj$ o, user$ u, hcs_hierarchy$ h -- , hcs_dim_attr$ da
where o.owner# = u.user#
      and h.obj# = o.obj#
      -- joins to get attr name from dim_attr$
      --and da.dim# = do.obj#
      --and h.par_attr# = da.attr#
/

create or replace view DBA_HIERARCHIES 
as 
select OWNER, HIER_NAME, DIMENSION_OWNER, DIMENSION_NAME,
        PARENT_ATTR, COMPILE_STATE, ORIGIN_CON_ID
from INT$DBA_HIERARCHIES
/


comment on table DBA_HIERARCHIES is
'Hierarchies in the database'
/
comment on column DBA_HIERARCHIES.OWNER is
'Owner of the hierarchy'
/
comment on column DBA_HIERARCHIES.HIER_NAME is
'Name of the hierarchy'
/
comment on column DBA_HIERARCHIES.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column DBA_HIERARCHIES.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column DBA_HIERARCHIES.PARENT_ATTR is
'Name of the attribute representing parent for a parent-child hierarchy, 
 NULL for level hierarchies'
/
comment on column DBA_HIERARCHIES.COMPILE_STATE is
'Compile state of the Hierarchy: N/A, VALID, or INVALID'
/
--comment on column DBA_HIERARCHIES.VALID_STATE is
--'Validity state of the Hierarchy: VALID, NEED_VALIDATE, or ERROR'
--/
comment on column DBA_HIERARCHIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIERARCHIES
FOR SYS.DBA_HIERARCHIES
/
GRANT SELECT ON DBA_HIERARCHIES to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIERARCHIES', 'CDB_HIERARCHIES');
grant select on SYS.CDB_HIERARCHIES to select_catalog_role
/
create or replace public synonym CDB_HIERARCHIES
for SYS.CDB_HIERARCHIES
/

create or replace view USER_HIERARCHIES
as
select HIER_NAME, DIMENSION_OWNER, DIMENSION_NAME,
       --da.attr_name PARENT_ATTR,
       PARENT_ATTR, COMPILE_STATE,
     --DECODE(h.val_state, 1, 'VALID', 2, 'NEEDS_VALIDATE', 3, 'ERROR') VALID_STATE,
     ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIERARCHIES)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER') 
/

comment on table USER_HIERARCHIES is
'Hierarchies in the database'
/
comment on column USER_HIERARCHIES.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column USER_HIERARCHIES.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column USER_HIERARCHIES.HIER_NAME is
'Name of the hierarchy'
/
comment on column USER_HIERARCHIES.PARENT_ATTR is
'Name of the attribute representing parent for a parent-child hierarchy, 
 NULL for level hierarchies'
/
comment on column USER_HIERARCHIES.COMPILE_STATE is
'Compile state of the Hierarchy: N/A, VALID, or INVALID'
/
--comment on column USER_HIERARCHIES.VALID_STATE is
--'Validity state of the Hierarchy: VALID, NEED_VALIDATE, or ERROR'
--/
comment on column USER_HIERARCHIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIERARCHIES
FOR SYS.USER_HIERARCHIES
/
grant read on USER_HIERARCHIES to public
/

create or replace view ALL_HIERARCHIES
as
select OWNER,
       HIER_NAME,
       DIMENSION_OWNER,
       DIMENSION_NAME,
       --da.attr_name PARENT_ATTR,
       PARENT_ATTR,
       COMPILE_STATE,
     --DECODE(h.val_state, 1, 'VALID', 2, 'NEEDS_VALIDATE', 3, 'ERROR') VALID_STATE,
     origin_con_id
from INT$DBA_HIERARCHIES
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIERARCHIES is
'Hierarchies in the database'
/
comment on column ALL_HIERARCHIES.OWNER is
'Owner of the hierarchy'
/
comment on column ALL_HIERARCHIES.HIER_NAME is
'Name of the hierarchy'
/
comment on column ALL_HIERARCHIES.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column ALL_HIERARCHIES.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column ALL_HIERARCHIES.PARENT_ATTR is
'Name of the attribute representing parent for a parent-child hierarchy, 
 NULL for level hierarchies'
/
comment on column ALL_HIERARCHIES.COMPILE_STATE is
'Compile state of the Hierarchy: N/A, VALID, or INVALID'
/
--comment on column ALL_HIERARCHIES.VALID_STATE is
--'Validity state of the Hierarchy: VALID, NEED_VALIDATE, or ERROR'
--/
comment on column ALL_HIERARCHIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIERARCHIES
FOR SYS.ALL_HIERARCHIES
/
grant read on ALL_HIERARCHIES to public
/

create or replace view INT$DBA_HIER_LEVELS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name HIER_NAME,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       hl.lvl_name LEVEL_NAME,
       hl.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, user$ u, hcs_hierarchy$ h, hcs_hr_lvl$ hl
where o.owner# = u.user#
      and h.obj# = o.obj#
      and hl.hier# = h.obj#
/

create or replace view DBA_HIER_LEVELS 
as
select OWNER, HIER_NAME, LEVEL_NAME, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_HIER_LEVELS
/

comment on table DBA_HIER_LEVELS is
'Hierarchy levels in the database'
/
comment on column DBA_HIER_LEVELS.OWNER is
'Owner of the hierarchy'
/
comment on column DBA_HIER_LEVELS.HIER_NAME is
'Name of owning hierarchy in the database'
/
comment on column DBA_HIER_LEVELS.LEVEL_NAME is
'Name of hierarchy level in the database'
/
comment on column DBA_HIER_LEVELS.ORDER_NUM is
'Order number of hierarchy level in the sequence'
/
comment on column DBA_HIERARCHIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_LEVELS
FOR SYS.DBA_HIER_LEVELS
/
GRANT SELECT ON DBA_HIER_LEVELS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_LEVELS', 'CDB_HIER_LEVELS');
grant select on SYS.CDB_HIER_LEVELS to select_catalog_role
/
create or replace public synonym CDB_HIER_LEVELS
for SYS.CDB_HIER_LEVELS
/

create or replace view USER_HIER_LEVELS
as
select HIER_NAME, LEVEL_NAME, ORDER_NUM, origin_con_id
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_LEVELS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_LEVELS is
'Hierarchy levels in the database'
/
comment on column USER_HIER_LEVELS.HIER_NAME is
'Name of owning hierarchy in the database'
/
comment on column USER_HIER_LEVELS.LEVEL_NAME is
'Name of hierarchy level in the database'
/
comment on column USER_HIER_LEVELS.ORDER_NUM is
'Order number of hierarchy level in the sequence'
/
comment on column USER_HIER_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_LEVELS
FOR SYS.USER_HIER_LEVELS
/
grant read on USER_HIER_LEVELS to public
/

create or replace view ALL_HIER_LEVELS
as
select OWNER,
       HIER_NAME,
       LEVEL_NAME,
       ORDER_NUM,
       origin_con_id
from INT$DBA_HIER_LEVELS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_LEVELS is
'Hierarchy levels in the database'
/
comment on column ALL_HIER_LEVELS.OWNER is
'Owner of the hierarchy'
/
comment on column ALL_HIER_LEVELS.HIER_NAME is
'Name of owning hierarchy in the database'
/
comment on column ALL_HIER_LEVELS.LEVEL_NAME is
'Name of hierarchy level in the database'
/
comment on column ALL_HIER_LEVELS.ORDER_NUM is
'Order number of hierarchy level in the sequence'
/
comment on column ALL_HIER_LEVELS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_LEVELS
FOR SYS.ALL_HIER_LEVELS
/
grant read on ALL_HIER_LEVELS to public
/

create or replace view INT$DBA_HIER_LEVEL_ID_ATTRS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.owner# owner_id,
       o.obj# object_id,
       o.type# object_type,
       o.name HIER_NAME,
       hl.lvl_name LEVEL_NAME,
       hl.attr_name ATTRIBUTE_NAME,
       hl.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from obj$ o, user$ u, hcs_hierarchy$ h, hcs_hr_lvl_id$ hl
where o.owner# = u.user#
      and h.obj# = o.obj#
      and hl.hier# = h.obj#
/

create or replace view DBA_HIER_LEVEL_ID_ATTRS
as 
select OWNER, 
       HIER_NAME, 
       LEVEL_NAME, 
       ATTRIBUTE_NAME,
       ORDER_NUM,
       origin_con_id
from INT$DBA_HIER_LEVEL_ID_ATTRS;

comment on table DBA_HIER_LEVEL_ID_ATTRS is
'Hierarchy Level ID Attributes in the database'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.OWNER is
'Owner of the Hierarchy'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.HIER_NAME is
'Name of owning Hierarchy in the database'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.LEVEL_NAME is
'Name of Hierarchy Level in the database'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.ATTRIBUTE_NAME is
'Name of Attribute in the database'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.ORDER_NUM is
'Order number of Attribute in the sequence'
/
comment on column DBA_HIER_LEVEL_ID_ATTRS.ORIGIN_CON_ID is
'Original con_id of Attribute in the sequence'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_LEVEL_ID_ATTRS
FOR SYS.DBA_HIER_LEVEL_ID_ATTRS
/
GRANT SELECT ON DBA_HIER_LEVEL_ID_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_LEVEL_ID_ATTRS', 'CDB_HIER_LEVEL_ID_ATTRS');
grant select on SYS.CDB_HIER_LEVEL_ID_ATTRS to select_catalog_role
/
create or replace public synonym CDB_HIER_LEVEL_ID_ATTRS
for SYS.CDB_HIER_LEVEL_ID_ATTRS
/

create or replace view USER_HIER_LEVEL_ID_ATTRS
as
select HIER_NAME,
       LEVEL_NAME,
       ATTRIBUTE_NAME,
       ORDER_NUM,
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_LEVEL_ID_ATTRS)
where owner = sys_context('USERENV','CURRENT_USER')
/

comment on table USER_HIER_LEVEL_ID_ATTRS is
'Hierarchy Level ID Attributes in the database'
/
comment on column USER_HIER_LEVEL_ID_ATTRS.HIER_NAME is
'Name of owning Heirarchy in the database'
/
comment on column USER_HIER_LEVEL_ID_ATTRS.LEVEL_NAME is
'Name of Hierarchy Level in the database'
/
comment on column USER_HIER_LEVEL_ID_ATTRS.ATTRIBUTE_NAME is
'Name of Attribute in the database'
/
comment on column USER_HIER_LEVEL_ID_ATTRS.ORDER_NUM is
'Order number of Attribute in the sequence'
/
comment on column USER_HIER_LEVEL_ID_ATTRS.ORIGIN_CON_ID is
'Original con_id of Attribute in the sequence'
/


CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_LEVEL_ID_ATTRS
FOR SYS.USER_HIER_LEVEL_ID_ATTRS
/
grant read on USER_HIER_LEVEL_ID_ATTRS to public
/

create or replace view ALL_HIER_LEVEL_ID_ATTRS
as
select OWNER,
       HIER_NAME,
       LEVEL_NAME,
       ATTRIBUTE_NAME,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_HIER_LEVEL_ID_ATTRS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_LEVEL_ID_ATTRS is
'Hierarchy Level ID Attributes in the database'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.OWNER is
'Owner of the Hierarchy'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.HIER_NAME is
'Name of owning Hierarchy in the database'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.LEVEL_NAME is
'Name of Hierarchy Level in the database'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.ATTRIBUTE_NAME is
'Name of Attribute in the database'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.ORDER_NUM is
'Order number of Attribute in the sequence'
/
comment on column ALL_HIER_LEVEL_ID_ATTRS.ORIGIN_CON_ID is
'Original CON_ID of Attribute in the sequence'
/


CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_LEVEL_ID_ATTRS
FOR SYS.ALL_HIER_LEVEL_ID_ATTRS
/
grant read on ALL_HIER_LEVEL_ID_ATTRS to public
/

create or replace view INT$DBA_HIER_COLUMNS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name HIER_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       hc.col_name COLUMN_NAME,
       DECODE(hc.role, 1, 'KEY', 2, 'AKEY', 3, 'HIER', 4, 'PROP') ROLE,
  DECODE(hc.data_type#, 1, decode(hc.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                 2, decode(hc.scale, null,
                            decode(hc.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                 8, 'LONG',
                 9, decode(hc.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                 12, 'DATE',
                 23, 'RAW', 24, 'LONG RAW',
                 69, 'ROWID',
                 96, decode(hc.charsetform, 2, 'NCHAR', 'CHAR'),
                 100, 'BINARY_FLOAT',
                 101, 'BINARY_DOUBLE',
                 105, 'MLSLABEL',
                 106, 'MLSLABEL',
                 112, decode(hc.charsetform, 2, 'NCLOB', 'CLOB'),
                 113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                 178, 'TIME(' ||hc.scale|| ')',
                 179, 'TIME(' ||hc.scale|| ')' || ' WITH TIME ZONE',
                 180, 'TIMESTAMP(' ||hc.scale|| ')',
                 181, 'TIMESTAMP(' ||hc.scale|| ')' || ' WITH TIME ZONE',
                 231, 'TIMESTAMP(' ||hc.scale|| ')' || ' WITH LOCAL TIME ZONE',
                 182, 'INTERVAL YEAR(' ||hc.precision#||') TO MONTH',
                 183, 'INTERVAL DAY(' ||hc.precision#||') TO SECOND(' ||
                        hc.scale || ')',
                 208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  hc.data_length DATA_LENGTH, 
  hc.precision# DATA_PRECISION, 
  hc.scale DATA_SCALE,
  case when hc.is_null = 1 THEN 'Y' ELSE 'N' END NULLABLE,
  decode(hc.charsetform, 1, 'CHAR_CS',
                         2, 'NCHAR_CS',
                         3, nls_charset_name(hc.charsetid),
                         4, 'ARG:'||hc.charsetid) CHARACTER_SET_NAME,
  decode(hc.charsetid, 0, to_number(NULL),
      nls_charset_decl_len(hc.data_length, hc.charsetid)) CHAR_COL_DECL_LENGTH,
  case when hc.data_type# in (1, 96)
       then decode(bitand(hc.property, 8388608), 0, 'B', 'C')
       else null end CHAR_USED,
       --DATA_TYPE_MOD,
       --DATA_TYPE_OWNER,
       --CHAR_LENGTH,
       --COLLATION,
       hc.ORDER_NUM ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, hcs_hier_col$ hc, user$ u
where o.owner# = u.user#
      and hc.hier# = o.obj#
/

create or replace view DBA_HIER_COLUMNS 
as
select OWNER, HIER_NAME, COLUMN_NAME, ROLE, DATA_TYPE, DATA_LENGTH,
    DATA_PRECISION, DATA_SCALE, NULLABLE, CHARACTER_SET_NAME,
    CHAR_COL_DECL_LENGTH, CHAR_USED, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_HIER_COLUMNS
/

comment on table DBA_HIER_COLUMNS is
'Hierarchy columns in the database'
/
comment on column DBA_HIER_COLUMNS.OWNER is
'Owner of hierarchy in the database'
/
comment on column DBA_HIER_COLUMNS.HIER_NAME is
'Name of hierarchy in the database'
/
comment on column DBA_HIER_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column  DBA_HIER_COLUMNS.ROLE is
'The role the attribute plays in the hierarchy.  One of: KEY, AKEY, or PROP'
/
comment on column DBA_HIER_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
--comment on column DBA_HIER_COLUMNS.DATA_TYPE_MOD is
--'Datatype modifier of the column'
--/
--comment on column DBA_HIER_COLUMNS.DATA_TYPE_OWNER is
--'Owner of the datatype of the column'
--/
comment on column DBA_HIER_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column DBA_HIER_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column DBA_HIER_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_HIER_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_HIER_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
--comment on column DBA_HIER_COLUMNS.CHAR_LENGTH is
--'Displays the length of the column in characters. This value only 
-- applies to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
--/
comment on column DBA_HIER_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_HIER_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
--comment on column DBA_HIER_COLUMNS.COLLATION is
--'The collation associated with this column.  This value only applies 
-- to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2.'
--/
comment on column DBA_HIER_COLUMNS.ORDER_NUM is
'Order of the column, with attributes first in the order of creation 
 followed by hierarchical attributes.'
/
comment on column DBA_HIER_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_COLUMNS
FOR SYS.DBA_HIER_COLUMNS
/
GRANT SELECT ON DBA_HIER_COLUMNS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_COLUMNS', 'CDB_HIER_COLUMNS');
grant select on SYS.CDB_HIER_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_HIER_COLUMNS
for SYS.CDB_HIER_COLUMNS
/

create or replace view USER_HIER_COLUMNS
as
select HIER_NAME, COLUMN_NAME, ROLE, DATA_TYPE, DATA_LENGTH, 
       DATA_PRECISION, DATA_SCALE, NULLABLE, CHARACTER_SET_NAME,
       CHAR_COL_DECL_LENGTH, CHAR_USED, 
       --DATA_TYPE_MOD,
       --DATA_TYPE_OWNER,
       --CHAR_LENGTH,
       --COLLATION,
       ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_COLUMNS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_COLUMNS is
'Hierarchy columns in the database'
/
comment on column USER_HIER_COLUMNS.HIER_NAME is
'Name of hierarchy in the database'
/
comment on column USER_HIER_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column  USER_HIER_COLUMNS.ROLE is
'The role the attribute plays in the hierarchy.  One of: KEY, AKEY, or PROP'
/
comment on column USER_HIER_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
--comment on column USER_HIER_COLUMNS.DATA_TYPE_MOD is
--'Datatype modifier of the column'
--/
--comment on column USER_HIER_COLUMNS.DATA_TYPE_OWNER is
--'Owner of the datatype of the column'
--/
comment on column USER_HIER_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column USER_HIER_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column USER_HIER_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_HIER_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_HIER_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
--comment on column USER_HIER_COLUMNS.CHAR_LENGTH is
--'Displays the length of the column in characters. This value only 
-- applies to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
--/
comment on column USER_HIER_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_HIER_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
--comment on column USER_HIER_COLUMNS.COLLATION is
--'The collation associated with this column.  This value only applies 
-- to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2.'
--/
comment on column USER_HIER_COLUMNS.ORDER_NUM is
'Order of the column, with attributes first in the order of creation 
 followed by hierarchical attributes.'
/
comment on column USER_HIER_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_COLUMNS
FOR SYS.USER_HIER_COLUMNS
/
grant read on USER_HIER_COLUMNS to public
/

create or replace view ALL_HIER_COLUMNS
as
select OWNER,
       HIER_NAME,
       COLUMN_NAME,
       ROLE,
       DATA_TYPE,
       DATA_LENGTH, 
       DATA_PRECISION, 
       DATA_SCALE,
       NULLABLE,
       CHARACTER_SET_NAME,
       CHAR_COL_DECL_LENGTH,
       CHAR_USED,
       --DATA_TYPE_MOD,
       --DATA_TYPE_OWNER,
       --CHAR_LENGTH,
       --COLLATION,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_HIER_COLUMNS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_COLUMNS is
'Hierarchy columns in the database'
/
comment on column ALL_HIER_COLUMNS.OWNER is
'Owner of hierarchy in the database'
/
comment on column ALL_HIER_COLUMNS.HIER_NAME is
'Name of hierarchy in the database'
/
comment on column ALL_HIER_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_HIER_COLUMNS.ROLE is
'The role the attribute plays in the hierarchy.  One of: KEY, AKEY, or PROP'
/
comment on column ALL_HIER_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
--comment on column ALL_HIER_COLUMNS.DATA_TYPE_MOD is
--'Datatype modifier of the column'
--/
--comment on column ALL_HIER_COLUMNS.DATA_TYPE_OWNER is
--'Owner of the datatype of the column'
--/
comment on column ALL_HIER_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column ALL_HIER_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column ALL_HIER_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_HIER_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_HIER_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
--comment on column ALL_HIER_COLUMNS.CHAR_LENGTH is
--'Displays the length of the column in characters. This value only 
-- applies to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
--/
comment on column ALL_HIER_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_HIER_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
--comment on column ALL_HIER_COLUMNS.COLLATION is
--'The collation associated with this column.  This value only applies 
-- to the following datatypes: CHAR, VARCHAR2, NCHAR, NVARCHAR2.'
--/
comment on column ALL_HIER_COLUMNS.ORDER_NUM is
'Order of the column, with attributes first in the order of creation 
 followed by hierarchical attributes.'
/
comment on column ALL_HIER_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_COLUMNS
FOR SYS.ALL_HIER_COLUMNS
/
grant read on ALL_HIER_COLUMNS to public
/

create or replace view INT$DBA_AVIEWS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       s.owner TABLE_OWNER,
       s.name TABLE_NAME,
       s.alias TABLE_ALIAS,
       UPPER(av.default_aggr) DEFAULT_AGGR,
       avm.meas_name DEFAULT_MEASURE,
       DECODE(o.status, 0, 'N/A', 1, 'VALID', 'INVALID') COMPILE_STATE,
       decode(av.dyn_all_cache, 0, 'N', 'Y') DYN_ALL_CACHE,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$  o, hcs_analytic_view$ av, hcs_src$ s, user$ u, hcs_av_meas$ avm
where o.owner# = u.user#
      and av.obj# = o.obj#
      and av.obj# = avm.av#
      and av.default_measure# = avm.meas#
      and s.hcs_obj# = av.obj#
/

create or replace view DBA_ANALYTIC_VIEWS
as
select OWNER, ANALYTIC_VIEW_NAME, TABLE_OWNER, TABLE_NAME, TABLE_ALIAS,
       DEFAULT_AGGR, DEFAULT_MEASURE, COMPILE_STATE, DYN_ALL_CACHE,
       ORIGIN_CON_ID
from INT$DBA_AVIEWS
/

comment on table DBA_ANALYTIC_VIEWS is
'Analytic views in the database'
/
comment on column DBA_ANALYTIC_VIEWS.OWNER is
'Owner of the analytic view'
/
comment on column DBA_ANALYTIC_VIEWS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEWS.TABLE_OWNER is
'Owner of the fact table or view on which the analytic view is defined'
/
comment on column DBA_ANALYTIC_VIEWS.TABLE_NAME is
'Name of the fact table or view on which the analytic view is defined'
/
comment on column DBA_ANALYTIC_VIEWS.TABLE_ALIAS is
'Alias of the fact table or view on which the analytic view is defined'
/
comment on column DBA_ANALYTIC_VIEWS.DEFAULT_AGGR is
'Default aggregation of the analytic view'
/
comment on column DBA_ANALYTIC_VIEWS.DEFAULT_MEASURE is
'Name of the default measure of the analytic view'
/
comment on column DBA_ANALYTIC_VIEWS.COMPILE_STATE is
'Compile state of the analytic view: N/A, VALID, or INVALID'
/
comment on column DBA_ANALYTIC_VIEWS.DYN_ALL_CACHE is
'Is cache dynamic across all levels enabled: Y or N'
/
comment on column DBA_ANALYTIC_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEWS
FOR SYS.DBA_ANALYTIC_VIEWS
/
GRANT SELECT ON DBA_ANALYTIC_VIEWS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEWS', 'CDB_ANALYTIC_VIEWS');
grant select on SYS.CDB_ANALYTIC_VIEWS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEWS
for SYS.CDB_ANALYTIC_VIEWS
/

create or replace view USER_ANALYTIC_VIEWS
as
select ANALYTIC_VIEW_NAME,
       TABLE_OWNER,
       TABLE_NAME,
       TABLE_ALIAS,
       DEFAULT_AGGR,
       DEFAULT_MEASURE,
       COMPILE_STATE,
       DYN_ALL_CACHE,
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEWS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEWS is
'Analytic views in the database'
/
comment on column USER_ANALYTIC_VIEWS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEWS.TABLE_OWNER is
'Owner of the fact table or view on which the analytic view is defined'
/
comment on column USER_ANALYTIC_VIEWS.TABLE_NAME is
'Name of the fact table or view on which the analytic view is defined'
/
comment on column USER_ANALYTIC_VIEWS.TABLE_ALIAS is
'Alias of the fact table or view on which the analytic view is defined'
/
comment on column USER_ANALYTIC_VIEWS.DEFAULT_AGGR is
'Default aggregation of the analytic view'
/
comment on column USER_ANALYTIC_VIEWS.DEFAULT_MEASURE is
'Name of the default measure of the analytic view'
/
comment on column USER_ANALYTIC_VIEWS.COMPILE_STATE is
'Compile state of the analytic view: N/A, VALID, or INVALID'
/
comment on column USER_ANALYTIC_VIEWS.DYN_ALL_CACHE is
'Is cache dynamic across all levels enabled: Y or N'
/
comment on column USER_ANALYTIC_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEWS
FOR SYS.USER_ANALYTIC_VIEWS
/
grant read on USER_ANALYTIC_VIEWS to public
/

create or replace view ALL_ANALYTIC_VIEWS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       TABLE_OWNER,
       TABLE_NAME,
       TABLE_ALIAS,
       DEFAULT_AGGR,
       DEFAULT_MEASURE,
       COMPILE_STATE,
       DYN_ALL_CACHE,
       ORIGIN_CON_ID
from INT$DBA_AVIEWS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEWS is
'Analytic views in the database'
/
comment on column ALL_ANALYTIC_VIEWS.OWNER is
'Owner of the analytic view'
/
comment on column ALL_ANALYTIC_VIEWS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEWS.TABLE_OWNER is
'Owner of the fact table or view on which the analytic view is defined'
/
comment on column ALL_ANALYTIC_VIEWS.TABLE_NAME is
'Name of the fact table or view on which the analytic view is defined'
/
comment on column ALL_ANALYTIC_VIEWS.TABLE_ALIAS is
'Alias of the fact table or view on which the analytic view is defined'
/
comment on column ALL_ANALYTIC_VIEWS.DEFAULT_AGGR is
'Default aggregation of the analytic view'
/
comment on column ALL_ANALYTIC_VIEWS.DEFAULT_MEASURE is
'Name of the default measure of the analytic view'
/
comment on column ALL_ANALYTIC_VIEWS.COMPILE_STATE is
'Compile state of the analytic view: N/A, VALID, or INVALID'
/
comment on column ALL_ANALYTIC_VIEWS.DYN_ALL_CACHE is
'Is cache dynamic across all levels enabled: Y or N'
/
comment on column ALL_ANALYTIC_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEWS
FOR SYS.ALL_ANALYTIC_VIEWS
/
grant read on ALL_ANALYTIC_VIEWS to public
/

create or replace view INT$DBA_AVIEW_DIMENSIONS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.dim_owner DIMENSION_OWNER,
       avd.dim_name DIMENSION_NAME,
       avd.alias DIMENSION_ALIAS,
       --DECODE(avd.leaves_only, 1, 'LEAVES ONLY') LEAVES_ONLY,
       DECODE(avd.dim_type, 1, 'STANDARD', 2, 'TIME') DIMENSION_TYPE,
       avd.all_member_name ALL_MEMBER_NAME,
       avd.all_member_caption ALL_MEMBER_CAPTION,
       avd.all_member_desc ALL_MEMBER_DESCRIPTION,
       decode(avd.ref_distinct, 0, 'N', 'Y') REFERENCES_DISTINCT,
       avd.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_av_dim$ avd, hcs_analytic_view$ av, user$ u
where o.owner# = u.user#
      and avd.av# = o.obj#
      and av.obj# = avd.av# -- probably redundant
/

create or replace view DBA_ANALYTIC_VIEW_DIMENSIONS
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_OWNER, DIMENSION_NAME, DIMENSION_ALIAS,
    DIMENSION_TYPE, ALL_MEMBER_NAME, ALL_MEMBER_CAPTION,
    ALL_MEMBER_DESCRIPTION, REFERENCES_DISTINCT, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_DIMENSIONS
/

comment on table DBA_ANALYTIC_VIEW_DIMENSIONS is
'Analytic view dimensions in the database'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.OWNER is
'Owner of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_ALIAS is
'Alias of the base analytic view dimension'
/
--comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.LEAVES_ONLY is
--'Indication of whether or not the analytic view Dimension only includes leaves'
--/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_TYPE is
'Type of the base analytic view dimension, either TIME or STANDARD'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_NAME is
'Name of the ALL member'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_CAPTION is
'Caption of the ALL member, or NULL if not specified'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'Description of the ALL member, or NULL if not specified'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.REFERENCES_DISTINCT is
'Does this dimension fact key reference distinct values of the hierarchy?'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ORDER_NUM is
'Order number of analytic view Dimension'
/
comment on column DBA_ANALYTIC_VIEW_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_DIMENSIONS
FOR SYS.DBA_ANALYTIC_VIEW_DIMENSIONS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_DIMENSIONS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_DIMENSIONS', 'CDB_ANALYTIC_VIEW_DIMENSIONS');
grant select on SYS.CDB_ANALYTIC_VIEW_DIMENSIONS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_DIMENSIONS
for SYS.CDB_ANALYTIC_VIEW_DIMENSIONS
/

create or replace view USER_ANALYTIC_VIEW_DIMENSIONS
as
select ANALYTIC_VIEW_NAME, DIMENSION_OWNER, DIMENSION_NAME, 
       DIMENSION_ALIAS, DIMENSION_TYPE, ALL_MEMBER_NAME, ALL_MEMBER_CAPTION,
       ALL_MEMBER_DESCRIPTION, REFERENCES_DISTINCT, ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_DIMENSIONS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_DIMENSIONS is
'Analytic view Dimensions in the database'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_ALIAS is
'Alias of the base analytic view dimension'
/
--comment on column USER_ANALYTIC_VIEW_DIMENSIONS.LEAVES_ONLY is
--'Indication of whether or not the analytic view Dimension only includes leaves'
--/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_TYPE is
'Type of the base analytic view dimension, either TIME or STANDARD'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_NAME is
'Name of the ALL member'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_CAPTION is
'Caption of the ALL member, or NULL if not specified'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'Description of the ALL member, or NULL if not specified'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.REFERENCES_DISTINCT is
'Does this dimension fact key reference distinct values of the hierarchy?'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ORDER_NUM is
'Order number of analytic view Dimension'
/
comment on column USER_ANALYTIC_VIEW_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_DIMENSIONS
FOR SYS.USER_ANALYTIC_VIEW_DIMENSIONS
/
grant read on USER_ANALYTIC_VIEW_DIMENSIONS to public
/

create or replace view ALL_ANALYTIC_VIEW_DIMENSIONS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       DIMENSION_OWNER,
       DIMENSION_NAME,
       DIMENSION_ALIAS,
       --DECODE(avd.leaves_only, 1, 'LEAVES ONLY') LEAVES_ONLY,
       DIMENSION_TYPE,
       ALL_MEMBER_NAME,
       ALL_MEMBER_CAPTION,
       ALL_MEMBER_DESCRIPTION,
       REFERENCES_DISTINCT,
       ORDER_NUM,       
       ORIGIN_CON_ID
from INT$DBA_AVIEW_DIMENSIONS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_DIMENSIONS is
'Analytic view Dimensions in the database'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.OWNER is
'Owner of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_OWNER is
'Owner of the base attribute dimension'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_NAME is
'Name of the base attribute dimension'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_ALIAS is
'Alias of the base analytic view dimension'
/
--comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.LEAVES_ONLY is
--'Indication of whether or not the analytic view Dimension only includes leaves'
--/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.DIMENSION_TYPE is
'Type of the base analytic view dimension, either TIME or STANDARD'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_NAME is
'Name of the ALL member'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_CAPTION is
'Caption of the ALL member, or NULL if not specified'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ALL_MEMBER_DESCRIPTION is
'Description of the ALL member, or NULL if not specified'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.REFERENCES_DISTINCT is
'Does this dimension fact key reference distinct values of the hierarchy?'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ORDER_NUM is
'Order number of analytic view Dimension'
/
comment on column ALL_ANALYTIC_VIEW_DIMENSIONS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_DIMENSIONS
FOR SYS.ALL_ANALYTIC_VIEW_DIMENSIONS
/
grant read on ALL_ANALYTIC_VIEW_DIMENSIONS to public
/
create or replace view INT$DBA_AVIEW_CALC_MEAS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avm.meas_name MEASURE_NAME,
       avm.expr MEAS_EXPRESSION,
       avm.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, hcs_av_meas$ avm, user$ u
where o.owner# = u.user#
      and avm.av# = o.obj#
      and avm.meas_type = 2  -- HCS_MEAS_CALC
/

create or replace view DBA_ANALYTIC_VIEW_CALC_MEAS
as 
select OWNER, ANALYTIC_VIEW_NAME, MEASURE_NAME, MEAS_EXPRESSION, ORDER_NUM, 
       ORIGIN_CON_ID
from INT$DBA_AVIEW_CALC_MEAS
/

comment on table DBA_ANALYTIC_VIEW_CALC_MEAS is
'Analytic view calculated measures in the database'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.OWNER is
'Owner of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.MEASURE_NAME is
'Name of the analytic view calculated measure'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.MEAS_EXPRESSION is
'Text of the expression'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.ORDER_NUM is
'Order number of the calculated measure within the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_CALC_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_CALC_MEAS
FOR SYS.DBA_ANALYTIC_VIEW_CALC_MEAS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_CALC_MEAS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_CALC_MEAS', 'CDB_ANALYTIC_VIEW_CALC_MEAS');
grant select on SYS.CDB_ANALYTIC_VIEW_CALC_MEAS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_CALC_MEAS
for SYS.CDB_ANALYTIC_VIEW_CALC_MEAS
/

create or replace view USER_ANALYTIC_VIEW_CALC_MEAS
as
select ANALYTIC_VIEW_NAME, MEASURE_NAME, MEAS_EXPRESSION, ORDER_NUM,
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_CALC_MEAS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_CALC_MEAS is
'Analytic view calculated measures in the database'
/
comment on column USER_ANALYTIC_VIEW_CALC_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_CALC_MEAS.MEASURE_NAME is
'Name of the analytic view calculated measure'
/
comment on column USER_ANALYTIC_VIEW_CALC_MEAS.MEAS_EXPRESSION is
'Text of the expression'
/
comment on column USER_ANALYTIC_VIEW_CALC_MEAS.ORDER_NUM is
'Order number of the calculated measure within the analytic view'
/
comment on column USER_ANALYTIC_VIEW_CALC_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_CALC_MEAS
FOR SYS.USER_ANALYTIC_VIEW_CALC_MEAS
/
grant read on USER_ANALYTIC_VIEW_CALC_MEAS to public
/

create or replace view ALL_ANALYTIC_VIEW_CALC_MEAS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       MEASURE_NAME,
       MEAS_EXPRESSION,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_CALC_MEAS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_CALC_MEAS is
'Analytic view calculated measures in the database'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.OWNER is
'Owner of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.MEASURE_NAME is
'Name of the analytic view calculated measure'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.MEAS_EXPRESSION is
'Text of the expression'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.ORDER_NUM is
'Order number of the calculated measure within the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_CALC_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_CALC_MEAS
FOR SYS.ALL_ANALYTIC_VIEW_CALC_MEAS
/
grant read on ALL_ANALYTIC_VIEW_CALC_MEAS to public
/

create or replace view INT$DBA_AVIEW_BASE_MEAS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avm.meas_name MEASURE_NAME,
       sc.table_alias TABLE_ALIAS,
       sc.src_col_name COLUMN_NAME,
       UPPER(avm.aggr) AGGR_FUNCTION,
       avm.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, hcs_av_meas$ avm, 
     hcs_analytic_view$ av, hcs_src_col$ sc, user$ u
where o.owner# = u.user#
      and avm.av# = o.obj#
      and av.obj# = avm.av#
      and avm.meas_type = 1  -- HCS_MEAS_BASE
      and sc.obj_type = 7   -- HCSDDL_DICT_TYPE_MEAS
      and avm.src_col# = sc.src_col#
      and avm.av# = sc.obj#
      and o.obj# = sc.obj#
/

create or replace view DBA_ANALYTIC_VIEW_BASE_MEAS
as
select OWNER, ANALYTIC_VIEW_NAME, MEASURE_NAME, TABLE_ALIAS, COLUMN_NAME, 
       AGGR_FUNCTION, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_BASE_MEAS
/

comment on table DBA_ANALYTIC_VIEW_BASE_MEAS is
'Analytic view base measures in the database'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.OWNER is
'Owner of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.MEASURE_NAME is
'Name of the analytic view measure'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.COLUMN_NAME is
'Column name in the table or view on which this measure is defined'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.AGGR_FUNCTION is
'Aggregation expression specified for this measure, or NULL if not specified'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.ORDER_NUM is
'Order number of the base measure within the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_BASE_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_BASE_MEAS
FOR SYS.DBA_ANALYTIC_VIEW_BASE_MEAS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_BASE_MEAS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_BASE_MEAS', 'CDB_ANALYTIC_VIEW_BASE_MEAS');
grant select on SYS.CDB_ANALYTIC_VIEW_BASE_MEAS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_BASE_MEAS
for SYS.CDB_ANALYTIC_VIEW_BASE_MEAS
/

create or replace view USER_ANALYTIC_VIEW_BASE_MEAS
as
select ANALYTIC_VIEW_NAME, MEASURE_NAME, TABLE_ALIAS, COLUMN_NAME,
       AGGR_FUNCTION, ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_BASE_MEAS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_BASE_MEAS is
'Analytic view base measures in the database'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.MEASURE_NAME is
'Name of the analytic view Base Measure'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.COLUMN_NAME is
'Column name in the table or view on which this measure is defined'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.AGGR_FUNCTION is
'Aggregation expression specified for this measure, or NULL if not specified'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.ORDER_NUM is
'Order number of the base measure within the analytic view'
/
comment on column USER_ANALYTIC_VIEW_BASE_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_BASE_MEAS
FOR SYS.USER_ANALYTIC_VIEW_BASE_MEAS
/
grant read on USER_ANALYTIC_VIEW_BASE_MEAS to public
/

create or replace view ALL_ANALYTIC_VIEW_BASE_MEAS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       MEASURE_NAME,
       TABLE_ALIAS,
       COLUMN_NAME,
       AGGR_FUNCTION,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_BASE_MEAS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_BASE_MEAS is
'Analytic view base measures in the database'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.OWNER is
'Owner of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.MEASURE_NAME is
'Name of the analytic view base measure'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.TABLE_ALIAS is
'Alias of the table or view in the USING clause to which the column belongs'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.COLUMN_NAME is
'Column name in the table or view on which this measure is defined'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.AGGR_FUNCTION is
'Aggregation expression specified for this measure, or NULL if not specified'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.ORDER_NUM is
'Order number of the base measure within the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_BASE_MEAS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_BASE_MEAS
FOR SYS.ALL_ANALYTIC_VIEW_BASE_MEAS
/
grant read on ALL_ANALYTIC_VIEW_BASE_MEAS to public
/

create or replace view INT$DBA_AVIEW_KEYS SHARING=EXTENDED DATA
as
select u.name OWNER, 
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_ALIAS,
       sc.table_alias AV_KEY_TABLE_ALIAS,
       sc.src_col_name AV_KEY_COLUMN,
       k.ref_attr_name REF_DIMENSION_ATTR,
       k.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from  user$ u, sys.obj$ o, hcs_analytic_view$ av, hcs_av_key$ k, 
      hcs_av_dim$ avd, hcs_src_col$ sc
where u.user# = o.owner#
      and av.obj# = o.obj#
      and av.obj# = k.av#
      and avd.av# = av.obj#
      and k.av_dim# = avd.av_dim#
      -- join for srcCol of analytic view key
      and k.src_col# = sc.src_col#
      and sc.obj# = k.av#
      and sc.obj_type = 10 -- HCSDDL_DICT_TYPE_AVKEY
/

create or replace view DBA_ANALYTIC_VIEW_KEYS 
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, AV_KEY_TABLE_ALIAS,
    AV_KEY_COLUMN, REF_DIMENSION_ATTR, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_KEYS
/

comment on table DBA_ANALYTIC_VIEW_KEYS is
'Analytic_view keys in the database'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.OWNER is
'Owner of analytic view'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.AV_KEY_TABLE_ALIAS is
'Table alias of the analytic view key column'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.AV_KEY_COLUMN is
'Name of the column for the analytic view key'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.REF_DIMENSION_ATTR is
'Name of the referenced dimension attribute'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.ORDER_NUM is
'Order number of the key in the list'
/
comment on column DBA_ANALYTIC_VIEW_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_KEYS
FOR SYS.DBA_ANALYTIC_VIEW_KEYS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_KEYS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_KEYS', 'CDB_ANALYTIC_VIEW_KEYS');
grant select on SYS.CDB_ANALYTIC_VIEW_KEYS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_KEYS
for SYS.CDB_ANALYTIC_VIEW_KEYS
/

create or replace view USER_ANALYTIC_VIEW_KEYS 
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, AV_KEY_TABLE_ALIAS,
       AV_KEY_COLUMN, REF_DIMENSION_ATTR, ORDER_NUM, ORIGIN_CON_ID
from  NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_KEYS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_KEYS is
'Analytic view keys in the database'
/
comment on column USER_ANALYTIC_VIEW_KEYS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_KEYS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_KEYS.AV_KEY_TABLE_ALIAS is
'Table alias of the analytic view key column'
/
comment on column USER_ANALYTIC_VIEW_KEYS.AV_KEY_COLUMN is
'Name of the column for the analytic view key'
/
comment on column USER_ANALYTIC_VIEW_KEYS.REF_DIMENSION_ATTR is
'Name of the referenced dimension attribute'
/
comment on column USER_ANALYTIC_VIEW_KEYS.ORDER_NUM is
'Order number of the key in the list'
/
comment on column USER_ANALYTIC_VIEW_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_KEYS
FOR SYS.USER_ANALYTIC_VIEW_KEYS
/
grant read on USER_ANALYTIC_VIEW_KEYS to public
/

create or replace view ALL_ANALYTIC_VIEW_KEYS 
as
select OWNER, 
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       AV_KEY_TABLE_ALIAS,
       AV_KEY_COLUMN,
       REF_DIMENSION_ATTR,
       ORDER_NUM,
       ORIGIN_CON_ID
from  INT$DBA_AVIEW_KEYS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_KEYS is
'Analytic view keys in the database'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.OWNER is
'Owner of analytic view'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.AV_KEY_TABLE_ALIAS is
'Table alias of the analytic view key column'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.AV_KEY_COLUMN is
'Name of the column for the analytic view key'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.REF_DIMENSION_ATTR is
'Name of the referenced dimension attribute'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.ORDER_NUM is
'Order number of the key in the list'
/
comment on column ALL_ANALYTIC_VIEW_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_KEYS
FOR SYS.ALL_ANALYTIC_VIEW_KEYS
/
grant read on ALL_ANALYTIC_VIEW_KEYS to public
/

create or replace view INT$DBA_AVIEW_HIERS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_ALIAS,
       avh.hier_owner HIER_OWNER,
       avh.hier_name HIER_NAME,
       avh.hier_alias HIER_ALIAS,       
       DECODE(avh.is_default, 0, 'N', 'Y') IS_DEFAULT,
       avh.ORDER_NUM ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
from sys.obj$ o, hcs_av_hier$ avh, hcs_av_dim$ avd, user$ u
where o.owner# = u.user#
      and avh.av# = o.obj#
      and avh.av_dim# = avd.av_dim#
      and avh.av# = avd.av#
/

create or replace view DBA_ANALYTIC_VIEW_HIERS 
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_OWNER, HIER_NAME,
    HIER_ALIAS,IS_DEFAULT, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_HIERS
/

comment on table DBA_ANALYTIC_VIEW_HIERS is
'Analytic view hierarchies in the database'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.OWNER is
'Owner of analytic view hierarchy'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.HIER_OWNER is
'Owner of the hierarchy'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.HIER_NAME is
'Name of the hierarchy'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.HIER_ALIAS is
'Alias specified for the hierarchy'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.IS_DEFAULT is
'Y if this is the default hierarchy for the dimension in the analytic view, N otherwise'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.ORDER_NUM is
'Order of the hierarchy within the list of hierarchies for the
 dimension in the analytic view'
/
comment on column DBA_ANALYTIC_VIEW_HIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_HIERS
FOR SYS.DBA_ANALYTIC_VIEW_HIERS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_HIERS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_HIERS', 'CDB_ANALYTIC_VIEW_HIERS');
grant select on SYS.CDB_ANALYTIC_VIEW_HIERS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_HIERS
for SYS.CDB_ANALYTIC_VIEW_HIERS
/

create or replace view USER_ANALYTIC_VIEW_HIERS
as
select ANALYTIC_VIEW_NAME, DIMENSION_ALIAS, HIER_OWNER, HIER_NAME,
       HIER_ALIAS, IS_DEFAULT, ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_HIERS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_HIERS is
'Analytic view hierarchies in the database'
/
comment on column USER_ANALYTIC_VIEW_HIERS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIERS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIERS.HIER_OWNER is
'Owner of the hierarchy'
/
comment on column USER_ANALYTIC_VIEW_HIERS.HIER_NAME is
'Name of the hierarchy'
/
comment on column USER_ANALYTIC_VIEW_HIERS.HIER_ALIAS is
'Alias specified for the hierarchy'
/
comment on column USER_ANALYTIC_VIEW_HIERS.IS_DEFAULT is
'Y if this is the default hierarchy for the dimension in the analytic view, N otherwise'
/
comment on column USER_ANALYTIC_VIEW_HIERS.ORDER_NUM is
'Order of the hierarchy within the list of hierarchies for the 
 dimension in the analytic view'
/
comment on column USER_ANALYTIC_VIEW_HIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_HIERS
FOR SYS.USER_ANALYTIC_VIEW_HIERS
/
grant read on USER_ANALYTIC_VIEW_HIERS to public
/

create or replace view ALL_ANALYTIC_VIEW_HIERS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       DIMENSION_ALIAS,
       HIER_OWNER,
       HIER_NAME,
       HIER_ALIAS,       
       IS_DEFAULT,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_HIERS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_HIERS is
'Analytic view hierarchies in the database'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.OWNER is
'Owner of analytic view hierarchy'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.ANALYTIC_VIEW_NAME is
'Name of the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.DIMENSION_ALIAS is
'Alias of the attribute dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.HIER_OWNER is
'Owner of the hierarchy'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.HIER_NAME is
'Name of the hierarchy'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.HIER_ALIAS is
'Alias specified for the hierarchy'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.IS_DEFAULT is
'Y if this is the default hierarchy for the dimension in the analytic view, N otherwise'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.ORDER_NUM is
'Order of the hierarchy within the list of hierarchies for the 
 dimension in the analytic view'
/
comment on column ALL_ANALYTIC_VIEW_HIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_HIERS
FOR SYS.ALL_ANALYTIC_VIEW_HIERS
/
grant read on ALL_ANALYTIC_VIEW_HIERS to public
/

create or replace view INT$DBA_AVIEW_COLUMNS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       avd.alias DIMENSION_NAME,
       avh.hier_alias HIER_NAME,
       avc.col_name COLUMN_NAME,
       DECODE(avc.role, 1, 'KEY', 2, 'AKEY', 3, 'HIER', 4, 'PROP') ROLE,
       DECODE(avc.data_type#, 1, decode(avc.charsetform, 2, 'NVARCHAR2', 
                 'VARCHAR2'),
                 2, decode(avc.scale, null,
                            decode(avc.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                 8, 'LONG',
                 9, decode(avc.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                 12, 'DATE',
                 23, 'RAW', 24, 'LONG RAW',
                 69, 'ROWID',
                 96, decode(avc.charsetform, 2, 'NCHAR', 'CHAR'),
                 100, 'BINARY_FLOAT',
                 101, 'BINARY_DOUBLE',
                 105, 'MLSLABEL',
                 106, 'MLSLABEL',
                 112, decode(avc.charsetform, 2, 'NCLOB', 'CLOB'),
                 113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                 178, 'TIME(' ||avc.scale|| ')',
                 179, 'TIME(' ||avc.scale|| ')' || ' WITH TIME ZONE',
                 180, 'TIMESTAMP(' ||avc.scale|| ')',
                 181, 'TIMESTAMP(' ||avc.scale|| ')' || ' WITH TIME ZONE',
                 231, 'TIMESTAMP(' ||avc.scale|| ')' || ' WITH LOCAL TIME ZONE',
                 182, 'INTERVAL YEAR(' ||avc.precision#||') TO MONTH',
                 183, 'INTERVAL DAY(' ||avc.precision#||') TO SECOND(' ||
                        avc.scale || ')',
                 208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
     avc.data_length DATA_LENGTH, 
     avc.precision# DATA_PRECISION, 
     avc.scale DATA_SCALE,
     case when avc.is_null = 1 THEN 'Y' ELSE 'N' END NULLABLE,
     decode(avc.charsetform, 1, 'CHAR_CS',
                         2, 'NCHAR_CS',
                         3, nls_charset_name(avc.charsetid),
                         4, 'ARG:'||avc.charsetid) CHARACTER_SET_NAME,
     decode(avc.charsetid, 0, to_number(NULL),
         nls_charset_decl_len(avc.data_length, avc.charsetid)) 
         CHAR_COL_DECL_LENGTH,
     case when avc.data_type# in (1, 96)
          then decode(bitand(avc.property, 8388608), 0, 'B', 'C')
          else null end CHAR_USED,
     avc.ORDER_NUM,
     case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
     to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_av_col$ avc, hcs_av_dim$ avd, 
     hcs_av_hier$ avh, user$ u
where o.owner# = u.user#
      and avc.av# = o.obj#
      and avd.av# = avc.av#
      and avd.av_dim# = avc.av_dim#
      and avc.av# = avh.av#
      and avc.av_dim# = avh.av_dim#
      and avc.av_hier# = avh.hier#
union all
select u.name owner,
       o.name ANALYTIC_VIEW_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       NULL DIMENSION_NAME,
       'MEASURES' HIER_NAME,
       avc.col_name COLUMN_NAME,
       DECODE(avc.role, 5, 'BASE', 6, 'CALC') ROLE,
       DECODE(avc.data_type#, 1, decode(avc.charsetform, 2, 'NVARCHAR2', 
                 'VARCHAR2'),
                 2, decode(avc.scale, null,
                            decode(avc.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                 8, 'LONG',
                 9, decode(avc.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                 12, 'DATE',
                 23, 'RAW', 24, 'LONG RAW',
                 69, 'ROWID',
                 96, decode(avc.charsetform, 2, 'NCHAR', 'CHAR'),
                 100, 'BINARY_FLOAT',
                 101, 'BINARY_DOUBLE',
                 105, 'MLSLABEL',
                 106, 'MLSLABEL',
                 112, decode(avc.charsetform, 2, 'NCLOB', 'CLOB'),
                 113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                 178, 'TIME(' ||avc.scale|| ')',
                 179, 'TIME(' ||avc.scale|| ')' || ' WITH TIME ZONE',
                 180, 'TIMESTAMP(' ||avc.scale|| ')',
                 181, 'TIMESTAMP(' ||avc.scale|| ')' || ' WITH TIME ZONE',
                 231, 'TIMESTAMP(' ||avc.scale|| ')' || ' WITH LOCAL TIME ZONE',
                 182, 'INTERVAL YEAR(' ||avc.precision#||') TO MONTH',
                 183, 'INTERVAL DAY(' ||avc.precision#||') TO SECOND(' ||
                        avc.scale || ')',
                 208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
     avc.data_length DATA_LENGTH, 
     avc.precision# DATA_PRECISION, 
     avc.scale DATA_SCALE,
     case when avc.is_null = 1 THEN 'Y' ELSE 'N' END NULLABLE,
     decode(avc.charsetform, 1, 'CHAR_CS',
                         2, 'NCHAR_CS',
                         3, nls_charset_name(avc.charsetid),
                         4, 'ARG:'||avc.charsetid) CHARACTER_SET_NAME,
     decode(avc.charsetid, 0, to_number(NULL),
     nls_charset_decl_len(avc.data_length, avc.charsetid)) CHAR_COL_DECL_LENGTH,
     case when avc.data_type# in (1, 96)
          then decode(bitand(avc.property, 8388608), 0, 'B', 'C')
         else null end CHAR_USED,
       --DATA_TYPE_MOD,
       --DATA_TYPE_OWNER,
       --CHAR_LENGTH,
       --COLLATION,
     avc.ORDER_NUM ORDER_NUM,
     case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
     to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_av_col$ avc, user$ u
where o.owner# = u.user#
      and avc.av# = o.obj#
      and avc.av_dim# is NULL
      and avc.av_hier# is NULL
/

create or replace view DBA_ANALYTIC_VIEW_COLUMNS 
as
select OWNER, ANALYTIC_VIEW_NAME, DIMENSION_NAME, HIER_NAME, COLUMN_NAME,
    ROLE, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE,
    CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH, CHAR_USED,
    ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_AVIEW_COLUMNS
/

comment on table DBA_ANALYTIC_VIEW_COLUMNS is
'Analytic view columns in the database'
/

comment on column DBA_ANALYTIC_VIEW_COLUMNS.OWNER is
'Owner of analytic view column'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.ANALYTIC_VIEW_NAME is
'Name of the owning analytic view'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.DIMENSION_NAME is
'Alias of the dimension in the analytic view (MEASURES for measures)'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.HIER_NAME is
'Alias of the hierarchy within DIM_NAME in the analytic view (MEASURES for measures)'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.ROLE is
'The role the attribute plays in the analytic view.  One of: KEY, AKEY, PROP, HIER, or MEAS'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.ORDER_NUM is
'Order of the column, with the hierarchy columns first followed by measure
 columns.  The columns for a given hierarchy are grouped together, with the
 ordering of the hierarchies determined by dimension/hierarchy order as created.
 Within a given hierarchy, attributes are listed first in order created
 followed by hierarchical attributes'
/
comment on column DBA_ANALYTIC_VIEW_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ANALYTIC_VIEW_COLUMNS
FOR SYS.DBA_ANALYTIC_VIEW_COLUMNS
/
GRANT SELECT ON DBA_ANALYTIC_VIEW_COLUMNS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ANALYTIC_VIEW_COLUMNS', 'CDB_ANALYTIC_VIEW_COLUMNS');
grant select on SYS.CDB_ANALYTIC_VIEW_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_ANALYTIC_VIEW_COLUMNS
for SYS.CDB_ANALYTIC_VIEW_COLUMNS
/

create or replace view USER_ANALYTIC_VIEW_COLUMNS
as
select ANALYTIC_VIEW_NAME, DIMENSION_NAME, HIER_NAME, COLUMN_NAME,
       ROLE, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE,
       NULLABLE,CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH, CHAR_USED,
       ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_AVIEW_COLUMNS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ANALYTIC_VIEW_COLUMNS is
'Analytic view columns in the database'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.ANALYTIC_VIEW_NAME is
'Name of the owning analytic view'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.DIMENSION_NAME is
'Alias of the dimension in the analytic view (MEASURES for measures)'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.HIER_NAME is
'Alias of the hierarchy within DIM_NAME in the analytic view (MEASURES for measures)'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.ROLE is
'The role the attribute plays in the analytic view.  One of: KEY, AKEY, PROP, HIER, 
 or MEAS'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.ORDER_NUM is
'Order of the column, with the hierarchy columns first followed by measure
 columns.  The columns for a given hierarchy are grouped together, with the
 ordering of the hierarchies determined by dimension/hierarchy order as created.
 Within a given hierarchy, attributes are listed first in order created
 followed by hierarchical attributes'
/
comment on column USER_ANALYTIC_VIEW_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ANALYTIC_VIEW_COLUMNS
FOR SYS.USER_ANALYTIC_VIEW_COLUMNS
/
grant read on USER_ANALYTIC_VIEW_COLUMNS to public
/

create or replace view ALL_ANALYTIC_VIEW_COLUMNS
as
select OWNER,
       ANALYTIC_VIEW_NAME,
       DIMENSION_NAME,
       HIER_NAME,
       COLUMN_NAME,
       ROLE,
       DATA_TYPE,
       DATA_LENGTH, 
       DATA_PRECISION, 
       DATA_SCALE,
       NULLABLE,
       CHARACTER_SET_NAME, 
       CHAR_COL_DECL_LENGTH, 
       CHAR_USED,
       --DATA_TYPE_MOD,
       --DATA_TYPE_OWNER,
       --CHAR_LENGTH,
       --COLLATION,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_AVIEW_COLUMNS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, ANALYTIC_VIEW_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ANALYTIC_VIEW_COLUMNS is
'Analytic view columns in the database'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.OWNER is
'Owner of analytic view column'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.ANALYTIC_VIEW_NAME is
'Name of the owning analytic view'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.DIMENSION_NAME is
'Alias of the dimension in the analytic view (MEASURES for measures)'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.HIER_NAME is
'Alias of the hierarchy within DIM_NAME in the analytic view (MEASURES for measures)'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.ROLE is
'The role the attribute plays in the analytic view.  One of: KEY, AKEY, PROP, HIER, 
 or MEAS'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.DATA_LENGTH is
'Length of the column (in bytes)'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.DATA_PRECISION is
'Decimal precision for NUMBER datatype; binary precision for 
 FLOAT datatype, NULL for all other datatypes'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.CHARACTER_SET_NAME is
'Name of the character set: CHAR_CS or NCHAR_CS'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.CHAR_USED is 
'B or C.  B indicates that the column uses BYTE length semantics.  
 C indicates that the column uses CHAR length semantics. NULL indicates 
 the datatype is not any of the following: CHAR, VARCHAR2, NCHAR, NVARCHAR2'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.ORDER_NUM is
'Order of the column, with the hierarchy columns first followed by measure
 columns.  The columns for a given hierarchy are grouped together, with the
 ordering of the hierarchies determined by dimension/hierarchy order as created.
 Within a given hierarchy, attributes are listed first in order created
 followed by hierarchical attributes'
/
comment on column ALL_ANALYTIC_VIEW_COLUMNS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ANALYTIC_VIEW_COLUMNS
FOR SYS.ALL_ANALYTIC_VIEW_COLUMNS
/
grant read on ALL_ANALYTIC_VIEW_COLUMNS to public
/

create or replace view INT$DBA_ATTR_DIM_KEYS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name DIMENSION_NAME,
       o.owner# OWNER_ID, 
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       dl.lvl_name LEVEL_NAME,
       DECODE(dlk.order_num, 0, 'N', 'Y') IS_ALTERNATE,
       da.attr_name ATTRIBUTE_NAME,
       dlka.order_num ATTR_ORDER_NUM,
       dlk.order_num KEY_ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from sys.obj$ o, hcs_dim_lvl_key$ dlk, hcs_dim_lvl$ dl, 
     hcs_dim_lvl_key_attr$ dlka, hcs_dim_attr$ da, user$ u
where o.owner# = u.user#
      and dlk.dim# = o.obj#
      and dl.lvl# = dlk.lvl#
      and dl.dim# = dlk.dim#
      and dlka.dim# = dlk.dim#
      and dlka.lvl# = dlk.lvl#
      and dlka.attr# = da.attr#
      and da.dim# = dlk.dim#
      and dlka.lvl_key# = dlk.lvl_key#
/

create or replace view DBA_ATTRIBUTE_DIM_KEYS 
as
select OWNER, DIMENSION_NAME, LEVEL_NAME, IS_ALTERNATE, ATTRIBUTE_NAME,
    ATTR_ORDER_NUM, KEY_ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_KEYS
/

/
comment on column DBA_ATTRIBUTE_DIM_KEYS.OWNER is
'Owner of attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.LEVEL_NAME is
'Level name of the key, NULL if PARENT CHILD dimension'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.IS_ALTERNATE is
'Indication of whether or not the dimension key is an alternate key'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.ATTRIBUTE_NAME is
'Name of the key attribute'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.ATTR_ORDER_NUM is
'Order of the attribute in the list of attributes comprising the key'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.KEY_ORDER_NUM is
'Order of the key in the list of keys (if alternate keys specified)'
/
comment on column DBA_ATTRIBUTE_DIM_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_KEYS
FOR SYS.DBA_ATTRIBUTE_DIM_KEYS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_KEYS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_KEYS', 'CDB_ATTRIBUTE_DIM_KEYS');
grant select on SYS.CDB_ATTRIBUTE_DIM_KEYS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_KEYS
for SYS.CDB_ATTRIBUTE_DIM_KEYS
/

create or replace view USER_ATTRIBUTE_DIM_KEYS
as
select DIMENSION_NAME, LEVEL_NAME, IS_ALTERNATE, ATTRIBUTE_NAME,
       ATTR_ORDER_NUM, KEY_ORDER_NUM, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_KEYS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_KEYS is
'attribute dimension keys in the database'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.LEVEL_NAME is
'Level name of the key, NULL if PARENT CHILD dimension'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.IS_ALTERNATE is
'Indication of whether or not the dimension key is an alternate key'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.ATTRIBUTE_NAME is
'Name of the key attribute'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.ATTR_ORDER_NUM is
'Order of the attribute in the list of attributes comprising the key'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.KEY_ORDER_NUM is
'Order of the key in the list of keys (if alternate keys specified)'
/
comment on column USER_ATTRIBUTE_DIM_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_KEYS
FOR SYS.USER_ATTRIBUTE_DIM_KEYS
/
grant read on USER_ATTRIBUTE_DIM_KEYS to public
/

create or replace view ALL_ATTRIBUTE_DIM_KEYS
as
select OWNER,
       DIMENSION_NAME,
       LEVEL_NAME,
       IS_ALTERNATE,
       ATTRIBUTE_NAME,
       ATTR_ORDER_NUM,
       KEY_ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_KEYS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_KEYS is
'attribute dimension keys in the database'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.OWNER is
'Owner of attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.LEVEL_NAME is
'Level name of the key, NULL if PARENT CHILD dimension'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.IS_ALTERNATE is
'Indication of whether or not the dimension key is an alternate key'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.ATTRIBUTE_NAME is
'Name of the key attribute'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.ATTR_ORDER_NUM is
'Order of the attribute in the list of attributes comprising the key'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.KEY_ORDER_NUM is
'Order of the key in the list of keys (if alternate keys specified)'
/
comment on column ALL_ATTRIBUTE_DIM_KEYS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_KEYS
FOR SYS.ALL_ATTRIBUTE_DIM_KEYS
/
grant read on ALL_ATTRIBUTE_DIM_KEYS to public
/

create or replace view INT$DBA_ATTR_DIM_LEVEL_ATTRS SHARING=EXTENDED DATA
as
select OWNER,
       DIMENSION_NAME, 
       OWNER_ID,
       OBJECT_ID,
       OBJECT_TYPE,
       LEVEL_NAME, 
       ATTRIBUTE_NAME, 
       decode(type, -1, 'PROP', 0, 'KEY', 'AKEY') ROLE,
       decode(is_minimal, 0, 'N', 'Y') IS_MINIMAL_DTM,
       KEY_ORDER_NUM, 
       TYPE,
       ROW_NUMBER() OVER(PARTITION BY OWNER, DIMENSION_NAME, LEVEL_NAME 
                         ORDER BY DECODE(TYPE,-1,1,0), KEY_ORDER_NUM, ORDER_NUM) - 1 ORDER_NUM,
       SHARING,
       ORIGIN_CON_ID
from (
select OWNER,
       DIMENSION_NAME, 
       OWNER_ID,
       OBJECT_ID,
       OBJECT_TYPE,
       LEVEL_NAME, 
       ATTRIBUTE_NAME, 
       KEY_ORDER_NUM TYPE, -- KEYS
       KEY_ORDER_NUM,
       0 IS_MINIMAL,
       ORDER_NUM,
       SHARING,
       ORIGIN_CON_ID
  from 
  (select u.name OWNER,
          o.name DIMENSION_NAME,
          o.owner# OWNER_ID,
          o.obj# OBJECT_ID,
          o.type# OBJECT_TYPE,
          dl.lvl_name LEVEL_NAME,
          da.attr_name ATTRIBUTE_NAME,
          dlk.order_num KEY_ORDER_NUM,
          dlka.order_num ORDER_NUM,
          ROW_NUMBER() OVER(PARTITION BY u.name, o.name, dl.lvl_name,
          da.attr_name ORDER BY dlk.order_num, dlka.order_num) ATR_ORD,
          case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
          to_number(sys_context('USERENV','CON_ID')) ORIGIN_CON_ID
   from sys.obj$ o, hcs_dim_lvl_key$ dlk, hcs_dim_lvl$ dl, 
        hcs_dim_lvl_key_attr$ dlka, hcs_dim_attr$ da, user$ u
   where o.owner# = u.user#
         and dlk.dim# = o.obj#
         and dl.lvl# = dlk.lvl#
         and dl.dim# = dlk.dim#
         and dlka.dim# = dlk.dim#
         and dlka.lvl# = dlk.lvl#
         and dlka.attr# = da.attr#
         and da.dim# = dlk.dim#
         and dlka.lvl_key# = dlk.lvl_key#
   )
where 1 = ATR_ORD
union all
select u.name OWNER,
       o.name DIMENSION_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       dl.lvl_name LEVEL_NAME,
       da.attr_name ATTRIBUTE_NAME,
       -1 TYPE, -- DETERMINED
       0 KEY_ORDER_NUM, --Dummy column for the union
       dda.in_minimal IS_MINIMAL,
       dda.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENG','CON_ID')) origin_con_id
from sys.obj$ o, hcs_dim_attr$ da, hcs_dim_lvl$ dl, 
     hcs_dim_dtm_attr$ dda, user$ u
where o.owner# = u.user#
      and dda.dim# = o.obj#
      and dl.lvl# = dda.lvl#
      and dl.dim# = dda.dim#
      and da.attr# = dda.attr#
      and da.dim# = dda.dim#
)
/

create or replace view DBA_ATTRIBUTE_DIM_LEVEL_ATTRS 
as
select OWNER, DIMENSION_NAME, LEVEL_NAME, ATTRIBUTE_NAME, ROLE, 
    IS_MINIMAL_DTM, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_LEVEL_ATTRS
/

comment on table DBA_ATTRIBUTE_DIM_LEVEL_ATTRS is
'Determined attributes of each Level in the database'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.OWNER is
'Owner of the attribute dimension level attribute'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.ATTRIBUTE_NAME is
'Name of the attribute determined by the level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.ROLE is
'Role of the attribute determined by the level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.LEVEL_NAME is
'Name of the dimension level, or NULL for parent child keys'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.IS_MINIMAL_DTM is
'Indication of whether the attribute minimally determined: Y or N'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.ORDER_NUM is
'Order of the attribute in the list of attributes determined by the level'
/
comment on column DBA_ATTRIBUTE_DIM_LEVEL_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_LEVEL_ATTRS
FOR SYS.DBA_ATTRIBUTE_DIM_LEVEL_ATTRS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_LEVEL_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_LEVEL_ATTRS', 'CDB_ATTRIBUTE_DIM_LEVEL_ATTRS');
grant select on SYS.CDB_ATTRIBUTE_DIM_LEVEL_ATTRS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_LEVEL_ATTRS
for SYS.CDB_ATTRIBUTE_DIM_LEVEL_ATTRS
/

create or replace view USER_ATTRIBUTE_DIM_LEVEL_ATTRS
as
select DIMENSION_NAME, 
       LEVEL_NAME, 
       ATTRIBUTE_NAME,
       ROLE,
       IS_MINIMAL_DTM,
       ORDER_NUM,
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_LEVEL_ATTRS)
where owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_LEVEL_ATTRS is
'Determined attributes of each level in the database'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.ATTRIBUTE_NAME is
'Name of the attribute determined by the level'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.ROLE is
'Role of the attribute determined by the level'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.LEVEL_NAME is
'Name of the dimension level, or NULL for parent child keys'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.IS_MINIMAL_DTM is
'Indication of whether the attribute minimally determined: Y or N'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.ORDER_NUM is
'Order of the attribute in the list of attributes determined by the level'
/
comment on column USER_ATTRIBUTE_DIM_LEVEL_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_LEVEL_ATTRS
FOR SYS.USER_ATTRIBUTE_DIM_LEVEL_ATTRS
/
grant read on USER_ATTRIBUTE_DIM_LEVEL_ATTRS to public
/

create or replace view ALL_ATTRIBUTE_DIM_LEVEL_ATTRS
as
select OWNER,
       DIMENSION_NAME, 
       LEVEL_NAME, 
       ATTRIBUTE_NAME, 
       ROLE,
       IS_MINIMAL_DTM,
       ORDER_NUM,
       ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_LEVEL_ATTRS
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/
comment on table ALL_ATTRIBUTE_DIM_LEVEL_ATTRS is
'Determined attributes of each level in the database'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.OWNER is
'Owner of the attribute dimension level attribute'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.DIMENSION_NAME is
'Name of the owning attribute dimension'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.ATTRIBUTE_NAME is
'Name of the attribute determined by the level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.ROLE is
'Role of the attribute determined by the level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.LEVEL_NAME is
'Name of the dimension level, or NULL for parent child keys'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.IS_MINIMAL_DTM is
'Indication of whether the attribute minimally determined: Y or N'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.ORDER_NUM is
'Order of the attribute in the list of attributes determined by the level'
/
comment on column ALL_ATTRIBUTE_DIM_LEVEL_ATTRS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_LEVEL_ATTRS
FOR SYS.ALL_ATTRIBUTE_DIM_LEVEL_ATTRS
/
grant read on ALL_ATTRIBUTE_DIM_LEVEL_ATTRS to public
/

create or replace view INT$DBA_ATTR_DIM_JOIN_PATHS SHARING=EXTENDED DATA
as
WITH
  cond_vars AS
    (SELECT
       lhsc.table_alias || '.' || lhsc.src_col_name || ' = ' ||
       rhsc.table_alias || '.' || rhsc.src_col_name cond,
       jce.dim# dimnum, jce.joinpath# joinpathnum, jce.order_num
     FROM hcs_dim_join_path$ djp, hcs_join_cond_elem$ jce, 
          hcs_src_col$ lhsc, hcs_src_col$ rhsc
     WHERE  jce.dim# = djp.dim#
            and jce.joinpath# = djp.joinpath#
            and jce.dim# = lhsc.obj# and jce.dim# = rhsc.obj# 
            and jce.lhs_src_col# = lhsc.src_col# 
            and jce.rhs_src_col# = rhsc.src_col# 
            and lhsc.obj_type = 12 
            and rhsc.obj_type = 12 
    ),
  all_cond_vars(cond, dimnum, joinpathnum, order_num) AS
    (SELECT cond, dimnum, joinpathnum, order_num
     FROM cond_vars
     WHERE order_num = 0
     UNION ALL
       (SELECT a.cond || ' AND ' || c.cond cond, c.dimnum, 
        c.joinpathnum, c.order_num
        FROM cond_vars c, all_cond_vars a
        WHERE c.joinpathnum = a.joinpathnum
              and c.dimnum = a.dimnum
              and c.order_num = a.order_num + 1
       )
    ),
  last_cond_vars AS
    (SELECT cond, dimnum, joinpathnum
     FROM
       (SELECT cond, dimnum, joinpathnum, order_num, 
           MAX(order_num) OVER (PARTITION BY dimnum, joinpathnum) max_order_num
        FROM all_cond_vars
       )
     WHERE order_num = max_order_num
    )
select u.name OWNER,
       o.name DIMENSION_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       djp.join_path_name JOIN_PATH_NAME,
       lcv.cond ON_CONDITION,
       djp.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from   sys.obj$ o, hcs_dim_join_path$ djp, user$ u, 
       last_cond_vars lcv
where  o.owner# = u.user#
       and djp.dim# = o.obj#
       and djp.joinpath# = lcv.joinpathnum
       and djp.dim# = lcv.dimnum
/

create or replace view DBA_ATTRIBUTE_DIM_JOIN_PATHS 
as
select OWNER, DIMENSION_NAME, JOIN_PATH_NAME, ON_CONDITION, ORDER_NUM, 
       ORIGIN_CON_ID
from INT$DBA_ATTR_DIM_JOIN_PATHS
/

comment on table DBA_ATTRIBUTE_DIM_JOIN_PATHS is
'Attribute dimension join paths in the database'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.OWNER is
'Owner of the attribute dimension join path'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.DIMENSION_NAME is
'Name of the owning attribute dimension join path'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the attribute dimension join path'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.ON_CONDITION is
'Condition of the attribute dimension join path'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.ORDER_NUM is
'Order number of Dimension join path within the Dimension'
/
comment on column DBA_ATTRIBUTE_DIM_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_ATTRIBUTE_DIM_JOIN_PATHS
FOR SYS.DBA_ATTRIBUTE_DIM_JOIN_PATHS
/
GRANT SELECT ON DBA_ATTRIBUTE_DIM_JOIN_PATHS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_ATTRIBUTE_DIM_JOIN_PATHS', 'CDB_ATTRIBUTE_DIM_JOIN_PATHS');
grant select on SYS.CDB_ATTRIBUTE_DIM_JOIN_PATHS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_DIM_JOIN_PATHS
for SYS.CDB_ATTRIBUTE_DIM_JOIN_PATHS
/

create or replace view USER_ATTRIBUTE_DIM_JOIN_PATHS
as
select OWNER, DIMENSION_NAME, JOIN_PATH_NAME, ON_CONDITION, ORDER_NUM, 
       ORIGIN_CON_ID
from   NO_ROOT_SW_FOR_LOCAL(INT$DBA_ATTR_DIM_JOIN_PATHS)
where  owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_ATTRIBUTE_DIM_JOIN_PATHS is
'attribute dimension join paths in the database'
/
comment on column USER_ATTRIBUTE_DIM_JOIN_PATHS.DIMENSION_NAME is
'Name of the owning attribute dimension join path'
/
comment on column USER_ATTRIBUTE_DIM_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the attribute dimension join path'
/
comment on column USER_ATTRIBUTE_DIM_JOIN_PATHS.ON_CONDITION is
'Condition of the attribute dimension join path'
/
comment on column USER_ATTRIBUTE_DIM_JOIN_PATHS.ORDER_NUM is
'Order number of dimension join path within the dimension'
/
comment on column USER_ATTRIBUTE_DIM_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_ATTRIBUTE_DIM_JOIN_PATHS
FOR SYS.USER_ATTRIBUTE_DIM_JOIN_PATHS
/
grant read on USER_ATTRIBUTE_DIM_JOIN_PATHS to public
/

create or replace view ALL_ATTRIBUTE_DIM_JOIN_PATHS
as
select OWNER, DIMENSION_NAME, JOIN_PATH_NAME, ON_CONDITION, ORDER_NUM, 
       ORIGIN_CON_ID
from   INT$DBA_ATTR_DIM_JOIN_PATHS
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, DIMENSION_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_ATTRIBUTE_DIM_JOIN_PATHS is
'Attribute dimension join paths in the database'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.OWNER is
'Owner of the attribute dimension join path'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.DIMENSION_NAME is
'Name of the owning attribute dimension join path'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the attribute dimension join path'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.ON_CONDITION is
'Condition of the attribute dimension join path'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.ORDER_NUM is
'Order number of Dimension join path within the Dimension'
/
comment on column ALL_ATTRIBUTE_DIM_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_ATTRIBUTE_DIM_JOIN_PATHS
FOR SYS.ALL_ATTRIBUTE_DIM_JOIN_PATHS
/
grant read on ALL_ATTRIBUTE_DIM_JOIN_PATHS to public
/

create or replace view INT$DBA_HIER_JOIN_PATHS SHARING=EXTENDED DATA
as
select u.name OWNER,
       o.name HIER_NAME,
       o.owner# OWNER_ID,
       o.obj# OBJECT_ID,
       o.type# OBJECT_TYPE,
       hjp.join_path_name JOIN_PATH_NAME,
       hjp.order_num ORDER_NUM,
       case when bitand(o.flags, 196608)>0 then 1 else 0 end sharing,
       to_number(sys_context('USERENV','CON_ID')) origin_con_id
from   sys.obj$ o, hcs_hier_join_path$ hjp, user$ u
where  o.owner# = u.user#
       and hjp.hier# = o.obj#
/

create or replace view DBA_HIER_JOIN_PATHS 
as
select OWNER, HIER_NAME, JOIN_PATH_NAME, ORDER_NUM, ORIGIN_CON_ID
from INT$DBA_HIER_JOIN_PATHS
/

comment on table DBA_HIER_JOIN_PATHS is
'Hierarchy join paths in the database'
/
comment on column DBA_HIER_JOIN_PATHS.OWNER is
'Owner of the hierarchy join path'
/
comment on column DBA_HIER_JOIN_PATHS.HIER_NAME is
'Name of the owning hierarchy join path'
/
comment on column DBA_HIER_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the hierarchy join path'
/
comment on column DBA_HIER_JOIN_PATHS.ORDER_NUM is
'Order number of join path within the hierarchy'
/
comment on column DBA_HIER_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_HIER_JOIN_PATHS
FOR SYS.DBA_HIER_JOIN_PATHS
/
GRANT SELECT ON DBA_HIER_JOIN_PATHS to select_catalog_role
/

execute CDBView.create_cdbview(false, 'SYS', 'DBA_HIER_JOIN_PATHS', 'CDB_HIER_JOIN_PATHS');
grant select on SYS.CDB_HIER_JOIN_PATHS to select_catalog_role
/
create or replace public synonym CDB_HIER_JOIN_PATHS
for SYS.CDB_HIER_JOIN_PATHS
/

create or replace view USER_HIER_JOIN_PATHS
as
select HIER_NAME, JOIN_PATH_NAME, ORDER_NUM, ORIGIN_CON_ID
from   NO_ROOT_SW_FOR_LOCAL(INT$DBA_HIER_JOIN_PATHS)
where  owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_HIER_JOIN_PATHS is
'Hierarchy join paths in the database'
/
comment on column USER_HIER_JOIN_PATHS.HIER_NAME is
'Name of the owning hierarchy join path'
/
comment on column USER_HIER_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the hierarchy join path'
/
comment on column USER_HIER_JOIN_PATHS.ORDER_NUM is
'Order number of join path within the hierarchy'
/
comment on column USER_HIER_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_HIER_JOIN_PATHS
FOR SYS.USER_HIER_JOIN_PATHS
/
grant read on USER_HIER_JOIN_PATHS to public
/

create or replace view ALL_HIER_JOIN_PATHS
as
select OWNER,
       HIER_NAME,
       JOIN_PATH_NAME,
       ORDER_NUM,
       ORIGIN_CON_ID
from   INT$DBA_HIER_JOIN_PATHS
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER='PUBLIC'
       or OBJ_ID(OWNER, HIER_NAME, OBJECT_TYPE, OBJECT_ID) in
            ( select obj#  -- directly granted privileges
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or ora_check_sys_privilege(owner_id, object_type) = 1
/

comment on table ALL_HIER_JOIN_PATHS is
'Hierarchy join paths in the database'
/
comment on column ALL_HIER_JOIN_PATHS.OWNER is
'Owner of the hierarchy join path'
/
comment on column ALL_HIER_JOIN_PATHS.HIER_NAME is
'Name of the owning hierarchy join path'
/
comment on column ALL_HIER_JOIN_PATHS.JOIN_PATH_NAME is
'Name of the hierarchy join path'
/
comment on column ALL_HIER_JOIN_PATHS.ORDER_NUM is
'Order number of join path within the hierarchy'
/
comment on column ALL_HIER_JOIN_PATHS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_HIER_JOIN_PATHS
FOR SYS.ALL_HIER_JOIN_PATHS
/
grant read on ALL_HIER_JOIN_PATHS to public
/

-- Stuff needed for AV cache
create or replace function av_cache_col (
  incol in varchar2, incolpos in number)
return varchar2
is
begin
  return incol;
end;
/
grant execute on sys.av_cache_col to public
/

@?/rdbms/admin/sqlsessend.sql
