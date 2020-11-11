Rem
Rem $Header: rdbms/admin/cdcore_tabs.sql /main/2 2017/11/19 19:54:55 amunnoli Exp $
Rem
Rem cdcore_tabs.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_tabs.sql - Catalog DCORE.bsq TABle viewS
Rem
Rem    DESCRIPTION
Rem      This script creates views related to table objects in dcore.bsq
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_tabs.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_tabs.sql
Rem    SQL_PHASE: CDCORE_TABS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    11/16/17 - Bug 27129759: Add HAS_SENSITIVE_COLUMN column
Rem    pjulsaks    05/11/17 - Bug 19552209: Add APPLICATION column
Rem    raeburns    04/23/17 - Bug 25825613: Restructure cdcore.sql
Rem                           Move getlong function to cdcore.sql so that it
Rem                           will not be created when this file is backported.
Rem    raeburns    04/23/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

remark
remark  FAMILY "TAB_COMMENTS"
remark  Comments on objects.
remark
create or replace view INT$DBA_TAB_COMMENTS PDB_LOCAL_ONLY
  SHARING=EXTENDED DATA 
    (OWNER, OWNERID, TABLE_NAME, OBJECT_ID, OBJECT_TYPE#, 
     TABLE_TYPE,
     COMMENTS, SHARING, ORIGIN_CON_ID, APPLICATION)
as
select u.name, u.user#, o.name, o.obj#, o.type#, 
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 150, 'HIERARCHY', 152, 'ANALYTIC VIEW', 'UNDEFINED'),
       c.comment$,
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID')),
       /* Bug 19552209: Add APPLICATION column for application object */
       case when bitand(o.flags, 134217728)>0 then 1 else 0 end 
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.com$ c
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# in (4)                                                /* view */
       or o.type# in (150)                                           /* hierarchy */
       or o.type# in (152)                                           /* analytic view */
       or
       (o.type# = 2                                                /* tables */
        AND         /* excluding iot-overflow, nested or mv container tables */
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192 OR
                            bitand(t.property, 67108864) = 67108864))))
  and o.obj# = c.obj#(+)
  and c.col#(+) is null
  and (SYS_CONTEXT('USERENV', 'CON_ID') = 0 or 
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' and 
           bitand(o.flags, 4194304)<>4194304) or
          SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'NO')
/
create or replace view USER_TAB_COMMENTS
    (TABLE_NAME,
     TABLE_TYPE,
     COMMENTS, ORIGIN_CON_ID)
as
select TABLE_NAME, TABLE_TYPE, COMMENTS, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_TAB_COMMENTS)
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table USER_TAB_COMMENTS is
'Comments on the tables and views owned by the user'
/
comment on column USER_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column USER_TAB_COMMENTS.TABLE_TYPE is
'Type of the object:  "TABLE" or "VIEW"'
/
comment on column USER_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
comment on column USER_TAB_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym USER_TAB_COMMENTS for USER_TAB_COMMENTS
/
grant read on USER_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS, ORIGIN_CON_ID)
as
select OWNER, TABLE_NAME, TABLE_TYPE, COMMENTS, ORIGIN_CON_ID
from INT$DBA_TAB_COMMENTS 
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
        or
        OBJ_ID(OWNER, TABLE_NAME, OBJECT_TYPE#, OBJECT_ID) 
        in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
           /* 2 is the type# for Table. See kgl.h for more info */
        ora_check_sys_privilege (ownerid, 2 ) = 1
       )
/
comment on table ALL_TAB_COMMENTS is
'Comments on tables and views accessible to the user'
/
comment on column ALL_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column ALL_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
comment on column ALL_TAB_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym ALL_TAB_COMMENTS for ALL_TAB_COMMENTS
/
grant read on ALL_TAB_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_TAB_COMMENTS
    (OWNER, TABLE_NAME,
     TABLE_TYPE,
     COMMENTS, ORIGIN_CON_ID)
as
select OWNER, TABLE_NAME,
       TABLE_TYPE,
       COMMENTS, ORIGIN_CON_ID
from INT$DBA_TAB_COMMENTS
/
create or replace public synonym DBA_TAB_COMMENTS for DBA_TAB_COMMENTS
/
grant select on DBA_TAB_COMMENTS to select_catalog_role
/
comment on table DBA_TAB_COMMENTS is
'Comments on all tables and views in the database'
/
comment on column DBA_TAB_COMMENTS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_TAB_COMMENTS.TABLE_TYPE is
'Type of the object'
/
comment on column DBA_TAB_COMMENTS.COMMENTS is
'Comment on the object'
/
comment on column DBA_TAB_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

execute CDBView.create_cdbview(false,'SYS','DBA_TAB_COMMENTS','CDB_TAB_COMMENTS');
grant select on SYS.CDB_TAB_COMMENTS to select_catalog_role
/
create or replace public synonym CDB_TAB_COMMENTS for SYS.CDB_TAB_COMMENTS
/

remark
remark  FAMILY "VIEWS" and "VIEWS_AE"
remark  All relevant information about views, except columns.
remark
remark  The VIEWS_AE family shows this information for views
remark  in all editions
remark

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME** SHARING=EXTENDED DATA
    (OWNER, OWNERID, VIEW_NAME, OBJECT_ID, OBJECT_TYPE#, TEXT_LENGTH, TEXT, TEXT_VC, 
     TYPE_TEXT_LENGTH, TYPE_TEXT, OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, 
     VIEW_TYPE, SUPERVIEW_NAME, EDITIONING_VIEW, READ_ONLY, **EDITION-COL-NAME**
     CONTAINER_DATA, BEQUEATH, SHARING, ORIGIN_CON_ID, DEFAULT_COLLATION,
     CONTAINERS_DEFAULT, CONTAINER_MAP, EXTENDED_DATA_LINK, 
     EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN)
as
select u.name, u.user#, o.name, o.obj#, o.type#, v.textlength, v.text, 
       getlong(1, v.rowid),
       t.typetextlength, t.typetext,
       t.oidtextlength, t.oidtext, t.typeowner, t.typename,
       decode(bitand(v.property, 134217728), 134217728,
              (select sv.name from superobj$ h, **OBJ-VIEW-NAME** sv
              where h.subobj# = o.obj# and h.superobj# = sv.obj#), null),
       decode(bitand(v.property, 32), 32, 'Y', 'N'),
       decode(bitand(v.property, 16384), 16384, 'Y', 'N'),
       **EDITION-COL**
       decode(bitand(v.property/4294967296, 134217728), 134217728, 'Y', 'N'),
       decode(bitand(o.flags,8),8,'CURRENT_USER','DEFINER'), 
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID')),
       nls_collation_name(nvl(o.dflcollid, 16382)),
       -- CONTAINERS_DEFAULT
       decode(bitand(v.property, power(2,72)), power(2,72), 'YES', 'NO'),
       -- CONTAINER_MAP
       decode(bitand(v.property, power(2,80)), power(2,80), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK
       decode(bitand(v.property, power(2,52)), power(2,52), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK_MAP
       decode(bitand(v.property, power(2,79)), power(2,79), 'YES', 'NO'),
       -- HAS_SENSITIVE_COLUMN
       decode(bitand(v.property, power(2,89)), power(2,89), 'YES', 'NO')
from **OBJ-VIEW-NAME** o, sys.view$ v, sys.user$ u, sys.typed_view$ t
where o.obj# = v.obj#
  and o.obj# = t.obj#(+)
  and o.owner# = u.user#!';

  base_view_name constant dbms_id := 'int$dba_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    'o.defining_edition, ';

  base_obj_view constant varchar2(ora_max_name_len*2 + 3) :=
    'sys."_CURRENT_EDITION_OBJ"';
  ae_obj_view   constant varchar2(ora_max_name_len*2 + 3) := 
    'sys."_ACTUAL_EDITION_OBJ"';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**EDITION-COL-NAME**', base_ed_col_name);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL-NAME**', ae_ed_col_name);

  base_stmt := replace(base_stmt, '**EDITION-COL**', base_ed_col);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL**', ae_ed_col);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, **EDITION-COL-NAME** CONTAINER_DATA, BEQUEATH,
     ORIGIN_CON_ID, DEFAULT_COLLATION, CONTAINERS_DEFAULT, CONTAINER_MAP,
     EXTENDED_DATA_LINK, EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN)
as
select OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC,
       TYPE_TEXT_LENGTH, TYPE_TEXT, OID_TEXT_LENGTH, OID_TEXT, 
       VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME, EDITIONING_VIEW, 
       READ_ONLY, **EDITION-COL** CONTAINER_DATA, BEQUEATH, ORIGIN_CON_ID,
       DEFAULT_COLLATION, CONTAINERS_DEFAULT, CONTAINER_MAP,
       EXTENDED_DATA_LINK, EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN
from **OBJ-VIEW-NAME**!';

  base_view_name constant dbms_id := 'dba_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_obj_view constant varchar2(ora_max_name_len) := 'int$dba_views';
  ae_obj_view   constant varchar2(ora_max_name_len) := 'int$dba_views_ae';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**EDITION-COL-NAME**', base_ed_col_name);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL-NAME**', ae_ed_col_name);

  base_stmt := replace(base_stmt, '**EDITION-COL**', base_ed_col);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL**', ae_ed_col);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

create or replace public synonym DBA_VIEWS for DBA_VIEWS
/
create or replace public synonym DBA_VIEWS_AE for DBA_VIEWS_AE
/
grant select on DBA_VIEWS to select_catalog_role
/
grant select on DBA_VIEWS_AE to select_catalog_role
/

comment on table DBA_VIEWS is
'Description of all views in the database'
/
comment on table DBA_VIEWS_AE is
'Description of all views in the database'
/

comment on column DBA_VIEWS.OWNER is
'Owner of the view'
/
comment on column DBA_VIEWS_AE.OWNER is
'Owner of the view'
/

comment on column DBA_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column DBA_VIEWS_AE.VIEW_NAME is
'Name of the view'
/

comment on column DBA_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column DBA_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/

comment on column DBA_VIEWS.TEXT is
'View text'
/
comment on column DBA_VIEWS_AE.TEXT is
'View text'
/

comment on column DBA_VIEWS.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/
comment on column DBA_VIEWS_AE.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/

comment on column DBA_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column DBA_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/

comment on column DBA_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column DBA_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/

comment on column DBA_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/

comment on column DBA_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column DBA_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/

comment on column DBA_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column DBA_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/

comment on column DBA_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column DBA_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is an object view'
/

comment on column DBA_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column DBA_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/

comment on column DBA_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column DBA_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/

comment on column DBA_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column DBA_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/

comment on column DBA_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/

comment on column DBA_VIEWS.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/
comment on column DBA_VIEWS_AE.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/

comment on column DBA_VIEWS.BEQUEATH is
'An indicator of whether the view is invoker rights'
/
comment on column DBA_VIEWS_AE.BEQUEATH is
'An indicator of whether the view is invoker rights'
/

comment on column DBA_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column DBA_VIEWS_AE.ORIGIN_CON_ID is
'ID of Container where row originates'
/

comment on column DBA_VIEWS.DEFAULT_COLLATION is
'Default collation for the view'
/
comment on column DBA_VIEWS_AE.DEFAULT_COLLATION is
'Default collation for the view'
/

comment on column DBA_VIEWS.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/
comment on column DBA_VIEWS_AE.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/

comment on column DBA_VIEWS.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/
comment on column DBA_VIEWS_AE.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/

comment on column DBA_VIEWS.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/
comment on column DBA_VIEWS_AE.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/

comment on column DBA_VIEWS.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/
comment on column DBA_VIEWS_AE.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/

comment on column DBA_VIEWS.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/
comment on column DBA_VIEWS_AE.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/

execute CDBView.create_cdbview(false,'SYS','DBA_VIEWS','CDB_VIEWS');
grant select on SYS.CDB_VIEWS to select_catalog_role
/
create or replace public synonym CDB_VIEWS for SYS.CDB_VIEWS
/
execute CDBView.create_cdbview(false,'SYS','DBA_VIEWS_AE','CDB_VIEWS_AE');
grant select on SYS.CDB_VIEWS_AE to select_catalog_role
/
create or replace public synonym CDB_VIEWS_AE for SYS.CDB_VIEWS_AE
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, **EDITION-COL-NAME** CONTAINER_DATA, BEQUEATH,
     ORIGIN_CON_ID, DEFAULT_COLLATION, CONTAINERS_DEFAULT, CONTAINER_MAP,
     EXTENDED_DATA_LINK, EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN)
as
select VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC, TYPE_TEXT_LENGTH, 
       TYPE_TEXT, OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, 
       VIEW_TYPE, SUPERVIEW_NAME, EDITIONING_VIEW, READ_ONLY, **EDITION-COL**
       CONTAINER_DATA, BEQUEATH, ORIGIN_CON_ID, DEFAULT_COLLATION,
       CONTAINERS_DEFAULT, CONTAINER_MAP, EXTENDED_DATA_LINK, 
       EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN
from **OBJ-VIEW-NAME**
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')!';

  base_view_name constant dbms_id := 'user_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_obj_view constant varchar2(ora_max_name_len*2 + 2) :=
    'no_root_sw_for_local(int$dba_views)';
  ae_obj_view   constant varchar2(ora_max_name_len*2 + 2) := 
    'no_root_sw_for_local(int$dba_views_ae)';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**EDITION-COL-NAME**', base_ed_col_name);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL-NAME**', ae_ed_col_name);

  base_stmt := replace(base_stmt, '**EDITION-COL**', base_ed_col);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL**', ae_ed_col);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

comment on table USER_VIEWS is
'Description of the user''s own views'
/
comment on table USER_VIEWS_AE is
'Description of the user''s own views'
/

comment on column USER_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column USER_VIEWS_AE.VIEW_NAME is
'Name of the view'
/

comment on column USER_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column USER_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/

comment on column USER_VIEWS.TEXT is
'View text'
/
comment on column USER_VIEWS_AE.TEXT is
'View text'
/

comment on column USER_VIEWS.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/
comment on column USER_VIEWS_AE.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/

comment on column USER_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column USER_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/

comment on column USER_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column USER_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/

comment on column USER_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/

comment on column USER_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column USER_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/

comment on column USER_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is a object view'
/
comment on column USER_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is a object view'
/

comment on column USER_VIEWS.VIEW_TYPE is
'Type of the view if the view is a object view'
/
comment on column USER_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is a object view'
/

comment on column USER_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column USER_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/

comment on column USER_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column USER_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/

comment on column USER_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column USER_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/

comment on column USER_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/

comment on column USER_VIEWS.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/
comment on column USER_VIEWS_AE.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/

comment on column USER_VIEWS.BEQUEATH is
'An indicator of whether the view is invoker rights'
/
comment on column USER_VIEWS_AE.BEQUEATH is
'An indicator of whether the view is invoker rights'
/

comment on column USER_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column USER_VIEWS_AE.ORIGIN_CON_ID is
'ID of Container where row originates'
/

comment on column USER_VIEWS.DEFAULT_COLLATION is
'Default collation for the view'
/
comment on column USER_VIEWS_AE.DEFAULT_COLLATION is
'Default collation for the view'
/

comment on column USER_VIEWS.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/
comment on column USER_VIEWS_AE.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/

comment on column USER_VIEWS.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/
comment on column USER_VIEWS_AE.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/

comment on column USER_VIEWS.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/
comment on column USER_VIEWS_AE.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/

comment on column USER_VIEWS.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/
comment on column USER_VIEWS_AE.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/

comment on column USER_VIEWS.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/
comment on column USER_VIEWS_AE.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/

create or replace public synonym USER_VIEWS for USER_VIEWS
/
grant read on USER_VIEWS to PUBLIC with grant option
/
create or replace public synonym USER_VIEWS_AE for USER_VIEWS_AE
/
grant read on USER_VIEWS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC, TYPE_TEXT_LENGTH, TYPE_TEXT,
     OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
     EDITIONING_VIEW, READ_ONLY, **EDITION-COL-NAME** CONTAINER_DATA, BEQUEATH,
     ORIGIN_CON_ID, DEFAULT_COLLATION, CONTAINERS_DEFAULT, CONTAINER_MAP,
     EXTENDED_DATA_LINK, EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN)
as
select OWNER, VIEW_NAME, TEXT_LENGTH, TEXT, TEXT_VC,TYPE_TEXT_LENGTH, TYPE_TEXT,
       OID_TEXT_LENGTH, OID_TEXT, VIEW_TYPE_OWNER, VIEW_TYPE, SUPERVIEW_NAME,
       EDITIONING_VIEW, READ_ONLY, **EDITION-COL** CONTAINER_DATA, BEQUEATH,
       ORIGIN_CON_ID, DEFAULT_COLLATION, CONTAINERS_DEFAULT, CONTAINER_MAP,
       EXTENDED_DATA_LINK, EXTENDED_DATA_LINK_MAP, HAS_SENSITIVE_COLUMN
from **OBJ-VIEW-NAME**
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OBJ_ID(OWNER, VIEW_NAME, 4, OBJECT_ID) in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
           /* 4 is the type# for Views. See kgl.h for more info */
          exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                  )
      )!';

  base_view_name constant dbms_id := 'all_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len + 2) := 'edition_name, ';

  base_obj_view constant varchar2(ora_max_name_len) := 'int$dba_views';
  ae_obj_view   constant varchar2(ora_max_name_len) := 'int$dba_views_ae';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**EDITION-COL-NAME**', base_ed_col_name);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL-NAME**', ae_ed_col_name);

  base_stmt := replace(base_stmt, '**EDITION-COL**', base_ed_col);
  ae_stmt   := replace(ae_stmt, '**EDITION-COL**', ae_ed_col);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

comment on table ALL_VIEWS is
'Description of views accessible to the user'
/
comment on table ALL_VIEWS_AE is
'Description of views accessible to the user'
/

comment on column ALL_VIEWS.OWNER is
'Owner of the view'
/
comment on column ALL_VIEWS_AE.OWNER is
'Owner of the view'
/

comment on column ALL_VIEWS.VIEW_NAME is
'Name of the view'
/
comment on column ALL_VIEWS_AE.VIEW_NAME is
'Name of the view'
/

comment on column ALL_VIEWS.TEXT_LENGTH is
'Length of the view text'
/
comment on column ALL_VIEWS_AE.TEXT_LENGTH is
'Length of the view text'
/

comment on column ALL_VIEWS.TEXT is
'View text'
/
comment on column ALL_VIEWS_AE.TEXT is
'View text'
/

comment on column ALL_VIEWS.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/
comment on column ALL_VIEWS_AE.TEXT_VC is
'Possibly truncated view text as VARCHAR2'
/

comment on column ALL_VIEWS.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/
comment on column ALL_VIEWS_AE.TYPE_TEXT_LENGTH is
'Length of the type clause of the object view'
/

comment on column ALL_VIEWS.TYPE_TEXT is
'Type clause of the object view'
/
comment on column ALL_VIEWS_AE.TYPE_TEXT is
'Type clause of the object view'
/

comment on column ALL_VIEWS.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS_AE.OID_TEXT_LENGTH is
'Length of the WITH OBJECT OID clause of the object view'
/

comment on column ALL_VIEWS.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/
comment on column ALL_VIEWS_AE.OID_TEXT is
'WITH OBJECT OID clause of the object view'
/

comment on column ALL_VIEWS.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/
comment on column ALL_VIEWS_AE.VIEW_TYPE_OWNER is
'Owner of the type of the view if the view is an object view'
/

comment on column ALL_VIEWS.VIEW_TYPE is
'Type of the view if the view is an object view'
/
comment on column ALL_VIEWS_AE.VIEW_TYPE is
'Type of the view if the view is an object view'
/

comment on column ALL_VIEWS.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/
comment on column ALL_VIEWS_AE.SUPERVIEW_NAME is
'Name of the superview, if view is a subview'
/

comment on column ALL_VIEWS.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/
comment on column ALL_VIEWS_AE.EDITIONING_VIEW is
'An indicator of whether the view is an Editioning View'
/

comment on column ALL_VIEWS.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/
comment on column ALL_VIEWS_AE.READ_ONLY is
'An indicator of whether the view is a Read Only View'
/

comment on column ALL_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the object is defined'
/

comment on column ALL_VIEWS.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/
comment on column ALL_VIEWS_AE.CONTAINER_DATA is
'An indicator of whether the view contains Container-specific data'
/

comment on column ALL_VIEWS.BEQUEATH is
'An indicator of whether the view is invoker rights'
/
comment on column ALL_VIEWS_AE.BEQUEATH is
'An indicator of whether the view is invoker rights'
/

comment on column ALL_VIEWS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column ALL_VIEWS_AE.ORIGIN_CON_ID is
'ID of Container where row originates'
/

comment on column ALL_VIEWS.DEFAULT_COLLATION is
'Default collation for the view'
/
comment on column ALL_VIEWS_AE.DEFAULT_COLLATION is
'Default collation for the view'
/

comment on column ALL_VIEWS.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/
comment on column ALL_VIEWS_AE.CONTAINERS_DEFAULT is
'Whether the view is enabled for CONTAINERS() by default'
/

comment on column ALL_VIEWS.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/
comment on column ALL_VIEWS_AE.CONTAINER_MAP is 
'Whether the view is enabled for use with container_map database property'
/

comment on column ALL_VIEWS.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/
comment on column ALL_VIEWS_AE.EXTENDED_DATA_LINK is 
'Whether the view is enabled for fetching extended data link from Root'
/

comment on column ALL_VIEWS.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/
comment on column ALL_VIEWS_AE.EXTENDED_DATA_LINK_MAP is 
'Whether the view is enabled for use with extended data link map'
/

comment on column ALL_VIEWS.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/
comment on column ALL_VIEWS_AE.HAS_SENSITIVE_COLUMN is
'Whether the view has one or more sensitive columns'
/

create or replace public synonym ALL_VIEWS for ALL_VIEWS
/
grant read on ALL_VIEWS to PUBLIC with grant option
/
create or replace public synonym ALL_VIEWS_AE for ALL_VIEWS_AE
/
grant read on ALL_VIEWS_AE to PUBLIC with grant option
/

remark
remark  FAMILY "CONSTRAINTS"
remark
create or replace view INT$INT$DBA_CONSTRAINTS SHARING=EXTENDED DATA 
    (OWNER, OWNERID, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, OBJECT_ID, OBJECT_TYPE#, SEARCH_CONDITION, 
     SEARCH_CONDITION_VC, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, SHARING, ORIGIN_CON_ID)
as
select ou.name, ou.user#, oc.name,
       decode(c.type#, 1, 'C', 2, 'P', 3, 'U',
              4, 'R', 5, 'V', 6, 'O', 7,'C', 8, 'H', 9, 'F',
              10, 'F', 11, 'F', 13, 'F', '?'),
       o.name, o.obj#, o.type#, c.condition, 
       getlong(2, c.rowid), 
       ru.name, rc.name,
       decode(c.type#, 4,
              decode(c.refact, 1, 'CASCADE', 2, 'SET NULL', 'NO ACTION'),
              NULL),
       decode(c.type#, 5, 'ENABLED',
              decode(c.enabled, NULL, 'DISABLED', 'ENABLED')),
       decode(bitand(c.defer, 1), 1, 'DEFERRABLE', 'NOT DEFERRABLE'),
       decode(bitand(c.defer, 2), 2, 'DEFERRED', 'IMMEDIATE'),
       decode(bitand(c.defer, 4), 4, 'VALIDATED', 'NOT VALIDATED'),
       decode(bitand(c.defer, 8), 8, 'GENERATED NAME', 'USER NAME'),
       decode(bitand(c.defer,16),16, 'BAD', null),
       decode(bitand(c.defer,32),32, 'RELY', null),
       c.mtime,
       decode(c.type#, 2, ui.name, 3, ui.name, null),
       decode(c.type#, 2, oi.name, 3, oi.name, null),
       decode(bitand(c.defer, 256), 256,
              decode(c.type#, 4,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)
                                or ro.status in (3, 5)) then 'INVALID'
                          else null end,
                     case when (bitand(c.defer, 128) = 128
                                or o.status in (3, 5)) then 'INVALID'
                          else null end
                    ),
              null),
       decode(bitand(c.defer, 256), 256, 'DEPEND ON VIEW', null), 
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.con$ oc, sys.con$ rc, sys."_BASE_USER" ou, sys."_BASE_USER" ru,
     sys."_CURRENT_EDITION_OBJ" ro, sys."_CURRENT_EDITION_OBJ" o, sys.cdef$ c,
     sys.obj$ oi, sys.user$ ui
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and c.type# != 8        /* don't include hash expressions */
  and (c.type# < 14 or c.type# > 17)    /* don't include supplog cons   */
  and (c.type# != 12)                   /* don't include log group cons */
  and c.rcon# = rc.con#(+)
  and c.enabled = oi.obj#(+)
  and oi.owner# = ui.user#(+)
  and rc.owner# = ru.user#(+)
  and c.robj# = ro.obj#(+)
/

-- INT$DBA_CONSTRAINTS has two object types - a view and a table.
-- The dictionary information about linked views is stored only in ROOT,
-- with a dummy obj$ row in PDB to indicate this. Hence we can use common
-- data view mechanism to fetch view constraints.
-- The dictionary information about linked tables however is stored in
-- all the containers. Hence using common data view mechanism would fetch
-- duplicate constraints. So we added a condition that if the object is
-- not a linked table then fetch the constraint and if it is a linked
-- table then fetch the constraint only if the origin con id is root or
-- non-cdb.
create or replace view INT$DBA_CONSTRAINTS
    (OWNER, OWNERID, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, OBJECT_ID, OBJECT_TYPE#, SEARCH_CONDITION, 
     SEARCH_CONDITION_VC, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, SHARING, ORIGIN_CON_ID)
as
select OWNER, OWNERID, CONSTRAINT_NAME, CONSTRAINT_TYPE,
       TABLE_NAME, OBJECT_ID, OBJECT_TYPE#, SEARCH_CONDITION, 
       SEARCH_CONDITION_VC, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
       DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
       BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
       INVALID, VIEW_RELATED, SHARING, ORIGIN_CON_ID
from   INT$INT$DBA_CONSTRAINTS INT$INT$DBA_CONSTRAINTS
where  INT$INT$DBA_CONSTRAINTS.OBJECT_TYPE# = 4         /* views */
       OR (INT$INT$DBA_CONSTRAINTS.OBJECT_TYPE# = 2     /* tables */
           AND (INT$INT$DBA_CONSTRAINTS.ORIGIN_CON_ID
                = TO_NUMBER(SYS_CONTEXT('USERENV', 'CON_ID'))))
/

-- Even though DBA_CONSTRAINTS and INT$DBA_CONSTRAINTS look very similar 
-- in their definitions, we need both these views because DBA_CONSTRAINTS
-- selects fewer columns than INT$DBA_CONSTRAINTS.
create or replace view DBA_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
     R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, ORIGIN_CON_ID)
as
select OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
       TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
       R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
       DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
       BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
       INVALID, VIEW_RELATED, ORIGIN_CON_ID
from   INT$DBA_CONSTRAINTS 
/

create or replace public synonym DBA_CONSTRAINTS for DBA_CONSTRAINTS
/
grant select on DBA_CONSTRAINTS to select_catalog_role
/
comment on table DBA_CONSTRAINTS is
'Constraint definitions on all tables'
/
comment on column DBA_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column DBA_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column DBA_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column DBA_CONSTRAINTS.SEARCH_CONDITION_VC is
'Possibly truncated text of search condition for table check'
/
comment on column DBA_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column DBA_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column DBA_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column DBA_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column DBA_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column DBA_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column DBA_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column DBA_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column DBA_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column DBA_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column DBA_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column DBA_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column DBA_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/
comment on column DBA_CONSTRAINTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/


execute CDBView.create_cdbview(false,'SYS','DBA_CONSTRAINTS','CDB_CONSTRAINTS');
grant select on SYS.CDB_CONSTRAINTS to select_catalog_role
/
create or replace public synonym CDB_CONSTRAINTS for SYS.CDB_CONSTRAINTS
/

create or replace view USER_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
     R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, ORIGIN_CON_ID)
as
select OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
       TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
       R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
       DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
       BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
       INVALID, VIEW_RELATED, ORIGIN_CON_ID
from   NO_ROOT_SW_FOR_LOCAL(INT$INT$DBA_CONSTRAINTS) INT$INT$DBA_CONSTRAINTS
where  INT$INT$DBA_CONSTRAINTS.OBJECT_TYPE# = 4   /* views */
  and  INT$INT$DBA_CONSTRAINTS.OWNER=SYS_CONTEXT('USERENV', 'CURRENT_USER')
union all 
select OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
       TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
       R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
       DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
       BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
       INVALID, VIEW_RELATED, ORIGIN_CON_ID
from   NO_COMMON_DATA(INT$INT$DBA_CONSTRAINTS) INT$INT$DBA_CONSTRAINTS
where  INT$INT$DBA_CONSTRAINTS.OBJECT_TYPE# = 2 /* tables */
  and  INT$INT$DBA_CONSTRAINTS.OWNER=SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_CONSTRAINTS is
'Constraint definitions on user''s own tables'
/
comment on column USER_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column USER_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column USER_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column USER_CONSTRAINTS.SEARCH_CONDITION_VC is
'Possibly truncated text of search condition for table check'
/
comment on column USER_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column USER_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column USER_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column USER_CONSTRAINTS.STATUS is
'Enforcement status of constraint -  ENABLED or DISABLED'
/
comment on column USER_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column USER_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column USER_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column USER_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column USER_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column USER_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column USER_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column USER_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by the constraint'
/
comment on column USER_CONSTRAINTS.INDEX_NAME is
'The index used by the constraint'
/
comment on column USER_CONSTRAINTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
grant read on USER_CONSTRAINTS to public with grant option
/
create or replace public synonym USER_CONSTRAINTS for USER_CONSTRAINTS
/
create or replace view ALL_CONSTRAINTS
    (OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
     TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
     R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
     DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
     BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
     INVALID, VIEW_RELATED, ORIGIN_CON_ID)
as
select OWNER, CONSTRAINT_NAME, CONSTRAINT_TYPE,
       TABLE_NAME, SEARCH_CONDITION, SEARCH_CONDITION_VC, 
       R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE, STATUS,
       DEFERRABLE, DEFERRED, VALIDATED, GENERATED,
       BAD, RELY, LAST_CHANGE, INDEX_OWNER, INDEX_NAME,
       INVALID, VIEW_RELATED, ORIGIN_CON_ID
from INT$DBA_CONSTRAINTS 
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OBJ_ID(OWNER, TABLE_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                       where grantee# in ( select kzsrorol
                                           from x$kzsro
                                         )
          )
        or /* user has system privileges */
        ora_check_sys_privilege ( ownerid, object_type# ) = 1
      )
/
comment on table ALL_CONSTRAINTS is
'Constraint definitions on accessible tables'
/
comment on column ALL_CONSTRAINTS.OWNER is
'Owner of the table'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_NAME is
'Name associated with constraint definition'
/
comment on column ALL_CONSTRAINTS.CONSTRAINT_TYPE is
'Type of constraint definition'
/
comment on column ALL_CONSTRAINTS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONSTRAINTS.SEARCH_CONDITION is
'Text of search condition for table check'
/
comment on column ALL_CONSTRAINTS.SEARCH_CONDITION_VC is
'Possibly truncated text of search condition for table check'
/
comment on column ALL_CONSTRAINTS.R_OWNER is
'Owner of table used in referential constraint'
/
comment on column ALL_CONSTRAINTS.R_CONSTRAINT_NAME is
'Name of unique constraint definition for referenced table'
/
comment on column ALL_CONSTRAINTS.DELETE_RULE is
'The delete rule for a referential constraint'
/
comment on column ALL_CONSTRAINTS.STATUS is
'Enforcement status of constraint - ENABLED or DISABLED'
/
comment on column ALL_CONSTRAINTS.DEFERRABLE is
'Is the constraint deferrable - DEFERRABLE or NOT DEFERRABLE'
/
comment on column ALL_CONSTRAINTS.DEFERRED is
'Is the constraint deferred by default -  DEFERRED or IMMEDIATE'
/
comment on column ALL_CONSTRAINTS.VALIDATED is
'Was this constraint system validated? -  VALIDATED or NOT VALIDATED'
/
comment on column ALL_CONSTRAINTS.GENERATED is
'Was the constraint name system generated? -  GENERATED NAME or USER NAME'
/
comment on column ALL_CONSTRAINTS.BAD is
'Creating this constraint should give ORA-02436.  Rewrite it before 2000 AD.'
/
comment on column ALL_CONSTRAINTS.RELY is
'If set, this flag will be used in optimizer'
/
comment on column ALL_CONSTRAINTS.LAST_CHANGE is
'The date when this column was last enabled or disabled'
/
comment on column ALL_CONSTRAINTS.INDEX_OWNER is
'The owner of the index used by this constraint'
/
comment on column ALL_CONSTRAINTS.INDEX_NAME is
'The index used by this constraint'
/
comment on column ALL_CONSTRAINTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
grant read on ALL_CONSTRAINTS to public with grant option
/

create or replace public synonym ALL_CONSTRAINTS for ALL_CONSTRAINTS
/

remark
remark  FAMILY "UNUSED_COL_TABS"
remark
remark  Views for showing information about tables with unused columns:
remark  USER_UNUSED_COL_TABS, ALL_UNUSED_COL_TABS, and DBA_UNUSED_COL_TABS
remark
create or replace view USER_UNUSED_COL_TABS
    (TABLE_NAME, COUNT)
as
select o.name, count(*)
from sys.col$ c, sys.obj$ o
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(c.property, 32768) = 32768             -- is unused columns
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  group by o.name
/
create or replace public synonym USER_UNUSED_COL_TABS for USER_UNUSED_COL_TABS
/
grant read on USER_UNUSED_COL_TABS to PUBLIC with grant option
/
comment on table USER_UNUSED_COL_TABS is
'User tables with unused columns'
/
Comment on column USER_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column USER_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace view ALL_UNUSED_COL_TABS
    (OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where o.owner# = u.user#
  and o.obj# = c.obj#
  and bitand(c.property,32768) = 32768              -- is unused column
  and bitand(c.property, 1) != 1                    -- not ADT attribute col
  and bitand(c.property, 1024) != 1024              -- not NTAB's setid col
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
       ora_check_sys_privilege ( o.owner#, o.type# ) = 1
      )
  group by u.name, o.name
/
comment on table ALL_UNUSED_COL_TABS is
'All tables with unused columns accessible to the user'
/
Comment on column ALL_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column ALL_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym ALL_UNUSED_COL_TABS for ALL_UNUSED_COL_TABS
/
grant read on ALL_UNUSED_COL_TABS to PUBLIC with grant option
/
create or replace view DBA_UNUSED_COL_TABS
(OWNER, TABLE_NAME, COUNT)
as
select u.name, o.name, count(*)
from sys.user$ u, sys.obj$ o, sys.col$ c
where c.obj# = o.obj#
      and bitand(c.property,32768) = 32768          -- is unused column
      and bitand(c.property, 1) != 1                -- not ADT attribute col
      and bitand(c.property, 1024) != 1024          -- not NTAB's setid col
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_UNUSED_COL_TABS is
'All tables with unused columns in the database'
/
Comment on column DBA_UNUSED_COL_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_UNUSED_COL_TABS.TABLE_NAME is
'Name of the table'
/
Comment on column DBA_UNUSED_COL_TABS.COUNT is
'Number of unused columns in table'
/
create or replace public synonym DBA_UNUSED_COL_TABS for DBA_UNUSED_COL_TABS
/
grant select on DBA_UNUSED_COL_TABS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_UNUSED_COL_TABS','CDB_UNUSED_COL_TABS');
grant select on SYS.CDB_UNUSED_COL_TABS to select_catalog_role
/
create or replace public synonym CDB_UNUSED_COL_TABS for SYS.CDB_UNUSED_COL_TABS
/

remark
remark  FAMILY "PARTIAL_DROP_TABS"
remark
remark  Views for showing tables with partial dropped columns:
remark  USER_PARTIAL_DROP_TABS, ALL_PARTIAL_DROP_TABS, DBA_PARTIAL_DROP_TABS
remark
create or replace view USER_PARTIAL_DROP_TABS
    (TABLE_NAME)
as
select o.name from sys.tab$ t, sys.obj$ o
where o.obj# = t.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(t.flags, 32768) = 32768
/
create or replace public synonym USER_PARTIAL_DROP_TABS
   for USER_PARTIAL_DROP_TABS
/
grant read on USER_PARTIAL_DROP_TABS to PUBLIC with grant option
/
comment on table USER_PARTIAL_DROP_TABS is
'User tables with unused columns'
/
Comment on column USER_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace view ALL_PARTIAL_DROP_TABS
    (OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where o.owner# = u.user#
  and o.obj# = t.obj#
  and bitand(t.flags,32768) = 32768
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
       ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  group by u.name, o.name
/
comment on table ALL_PARTIAL_DROP_TABS is
'All tables with patially dropped columns accessible to the user'
/
Comment on column ALL_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column ALL_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym ALL_PARTIAL_DROP_TABS
   for ALL_PARTIAL_DROP_TABS
/
grant read on ALL_PARTIAL_DROP_TABS to PUBLIC with grant option
/
create or replace view DBA_PARTIAL_DROP_TABS
(OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.user$ u, sys.obj$ o, sys.tab$ t
where t.obj# = o.obj#
      and bitand(t.flags,32768) = 32768
      and u.user# = o.owner#
      group by u.name, o.name
/
comment on table DBA_PARTIAL_DROP_TABS is
'All tables with partially dropped columns in the database'
/
Comment on column DBA_PARTIAL_DROP_TABS.OWNER is
'Owner of the table'
/
Comment on column DBA_PARTIAL_DROP_TABS.TABLE_NAME is
'Name of the table'
/
create or replace public synonym DBA_PARTIAL_DROP_TABS
   for DBA_PARTIAL_DROP_TABS
/
grant select on DBA_PARTIAL_DROP_TABS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PARTIAL_DROP_TABS','CDB_PARTIAL_DROP_TABS');
grant select on SYS.CDB_PARTIAL_DROP_TABS to select_catalog_role
/
create or replace public synonym CDB_PARTIAL_DROP_TABS for SYS.CDB_PARTIAL_DROP_TABS
/


@?/rdbms/admin/sqlsessend.sql
 
