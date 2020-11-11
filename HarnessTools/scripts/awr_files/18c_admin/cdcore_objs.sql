Rem
Rem $Header: rdbms/admin/cdcore_objs.sql /main/1 2017/05/20 12:22:50 raeburns Exp $
Rem
Rem cdcore_objs.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_objs.sql - Catalog DCORE.bsq OBJect-related viewS
Rem
Rem    DESCRIPTION
Rem      This script creates views on obj$
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_objs.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_objs.sql
Rem    SQL_PHASE:CDCORE_OBJS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/28/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    04/28/17 - Created
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

create or replace view DATABASE_PROPERTIES
  (PROPERTY_NAME, PROPERTY_VALUE, DESCRIPTION)
as
  select name, value$, comment$
  from x$props
/
comment on table DATABASE_PROPERTIES is
'Permanent database properties'
/
comment on column DATABASE_PROPERTIES.PROPERTY_NAME is
'Property name'
/
comment on column DATABASE_PROPERTIES.PROPERTY_VALUE is
'Property value'
/
comment on column DATABASE_PROPERTIES.DESCRIPTION is
'Property description'
/
create or replace public synonym DATABASE_PROPERTIES for DATABASE_PROPERTIES
/
grant read on DATABASE_PROPERTIES to PUBLIC with grant option
/

Rem
Rem Create the corresponding cdb view cdb_properties
Rem
execute CDBView.create_cdbview(false,'SYS','DATABASE_PROPERTIES','CDB_PROPERTIES');
create or replace public synonym CDB_PROPERTIES for CDB_PROPERTIES
/
grant select on CDB_PROPERTIES to select_catalog_role
/

Rem     GLOBAL DATABASE NAME

create or replace view GLOBAL_NAME ( GLOBAL_NAME ) as
       select value$ from sys.props$ where name = 'GLOBAL_DB_NAME'
/
comment on table GLOBAL_NAME is 'global database name'
/
comment on column GLOBAL_NAME.GLOBAL_NAME is 'global database name'
/
grant read on GLOBAL_NAME to public with grant option
/
create or replace public synonym GLOBAL_NAME for GLOBAL_NAME
/

remark
remark  FAMILY "CATALOG"
remark  Objects which may be used as tables in SQL statements:
remark  Tables, Views, Synonyms.
remark

create or replace view USER_CATALOG
    (TABLE_NAME,
     TABLE_TYPE)
as
select o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys."_CURRENT_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
/
comment on table USER_CATALOG is
'Tables, Views, Synonyms and Sequences owned by the user'
/
comment on column USER_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column USER_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym USER_CATALOG for USER_CATALOG
/
create or replace public synonym CAT for USER_CATALOG
/
grant read on USER_CATALOG to PUBLIC with grant option
/
remark
remark  This view shows all tables, views, synonyms, and sequences owned by the
remark  user and those tables, views, synonyms, and sequences that PUBLIC
remark  has been granted access.
remark
create or replace view ALL_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o
where o.owner# = u.user#
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and o.linkname is null
  and (o.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
       or
       obj# in ( select obj#  /* directly granted privileges */
                 from sys.objauth$
                 where grantee# in ( select kzsrorol
                                      from x$kzsro
                                    )
                )
       or
       (
          o.type# in (2, 4, 5, 6) /* table, view, synonym and sequence */
          and
          /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
       )
      )
/
comment on table ALL_CATALOG is
'All tables, views, synonyms, sequences accessible to the user'
/
comment on column ALL_CATALOG.OWNER is
'Owner of the object'
/
comment on column ALL_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column ALL_CATALOG.TABLE_TYPE is
'Type of the object'
/
create or replace public synonym ALL_CATALOG for ALL_CATALOG
/
grant read on ALL_CATALOG to PUBLIC with grant option
/
create or replace view DBA_CATALOG
    (OWNER, TABLE_NAME,
     TABLE_TYPE)
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o
where o.owner# = u.user#
  and o.linkname is null
  and ((o.type# in (4, 5, 6))
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
/
create or replace public synonym DBA_CATALOG for DBA_CATALOG
/
grant select on DBA_CATALOG to select_catalog_role
/
comment on table DBA_CATALOG is
'All database Tables, Views, Synonyms, Sequences'
/
comment on column DBA_CATALOG.OWNER is
'Owner of the object'
/
comment on column DBA_CATALOG.TABLE_NAME is
'Name of the object'
/
comment on column DBA_CATALOG.TABLE_TYPE is
'Type of the object'
/

execute CDBView.create_cdbview(false,'SYS','DBA_CATALOG','CDB_CATALOG');
grant select on SYS.CDB_CATALOG to select_catalog_role
/
create or replace public synonym CDB_CATALOG for SYS.CDB_CATALOG
/

remark
remark  FAMILY "OBJECTS" and "OBJECTS_AE"
remark  List of objects, including creation and modification times.
remark
remark  The OBJECTS_AE family shows this information for objects
remark  in all editions
remark

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE,
     CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED,
     SECONDARY, NAMESPACE, EDITION_NAME, SHARING, EDITIONABLE,
     ORACLE_MAINTAINED, APPLICATION, DEFAULT_COLLATION, DUPLICATED, 
     SHARDED, CREATED_APPID, CREATED_VSNID, MODIFIED_APPID, MODIFIED_VSNID)
as
select o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      **NON-EXISTENT-NAME**
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY',  24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, CASE (SELECT BITAND(s.xpflags, 8388608 + 34359738368)
                                FROM sum$ s
                                WHERE s.obj#=o.obj#)
                          WHEN 8388608 THEN 'REWRITE EQUIVALENCE'
                          WHEN 34359738368 THEN 'MATERIALIZED ZONEMAP'
                          ELSE 'MATERIALIZED VIEW'
                          END,
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL',  87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE',
                      115, 'UNIFIED AUDIT POLICY',
                      144, 'MINING MODEL PARTITION',
                      148, 'LOCKDOWN PROFILE',
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW',
                      'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EXTENDED DATA LINK', &mdl, 'METADATA LINK', 
              &dl, 'DATA LINK', 'NONE'),
       case when o.type# in (4,5,7,8,9,11,12,13,14,22,87,114) then
           decode(bitand(o.flags, 1048576), 0, 'Y', 1048576, 'N', 'Y')
         else null end,
       decode(bitand(o.flags, 4194304), 4194304, 'Y', 'N'),
       decode(bitand(o.flags, 134217728), 134217728, 'Y', 'N'),
       case when o.type# in (2,4,7,8,9,12,13) then
           nls_collation_name(nvl(o.dflcollid, 16382))
         when (o.type# = 42 
               and exists
               (SELECT 1
                FROM sum$ s
                WHERE s.obj#=o.obj#
                -- not rewrite equivalence or zone map
                and bitand(s.xpflags, 8388608 + 34359738368) = 0)) then 
           nls_collation_name(nvl(o.dflcollid, 16382))
         else null end,
       decode(bitand(o.flags, 2684354560),
                     0, 'N', 
                     2147483648, 'Y', /* KQDOBREF set */
                      536870912, 'Y', /* KQDOBOAS set */
                     2684354560, 'Y', /* both KQDOBREF and KQDOBOAS set */
                     'N'),
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       -- CREATED_APPID
       o.CREAPPID,
       -- CREATED_VSNID
       o.CREVERID,
       -- MODIFIED_APPID,
       o.MODAPPID,
       -- MODIFIED_VSNID,
       o.MODVERID
from **OBJ-VIEW-NAME** o
where o.owner# = userenv('SCHEMAID')
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */
                       **NON-EXISTENT-TYPE**)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 8, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
  -- Exclude XML Token set objects */
  and (o.type# not in (1 /* INDEXES */,
                       2 /* TABLES */,
                       6 /* SEQUENCE */)
      or
      (o.type# = 1 and not exists (select 1
                from sys.ind$ i, sys.tab$ t, sys.obj$ io
                where i.obj# = o.obj#
                  and io.obj# = i.bo#
                  and io.type# = 2
                  and i.bo# = t.obj#
                  and bitand(t.property, power(2,65)) =  power(2,65)))
      or
      (o.type# = 2 and 1 = (select 1
                from sys.tab$ t
                where t.obj# = o.obj#
                  and (bitand(t.property, power(2,65)) = 0
                         or t.property is null)))
      or
      (o.type# = 6 and 1 = (select 1
                from sys.seq$ s
                where s.obj# = o.obj#
                  and (bitand(s.flags, 1024) = 0 or s.flags is null))))
union all
select l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID', 'N', 'N', 'N', NULL, NULL,
       'NONE', NULL, 'N', 'N', NULL, 'N', 'N', 
       -- CREATED_APPID
       NULL, 
       -- CREATED_VSNID
       NULL, 
       -- MODIFIED_APPID
       NULL, 
       -- MODIFIED_VSNID
       NULL
from sys.link$ l
where l.owner# = userenv('SCHEMAID')!';

  base_view_name constant dbms_id := 'user_objects';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ne_name   constant varchar2(32767) := '';
  ae_ne_name     constant varchar2(32767) := q'!10, 'NON-EXISTENT',!';

  base_ne_type   constant varchar2(32767) := q'!, 10 /* NON-EXISTENT */!';
  ae_ne_type     constant varchar2(32767) := '';

  base_obj_view constant varchar2(ora_max_name_len*2 + 3) :=
    'sys."_CURRENT_EDITION_OBJ"';
  ae_obj_view   constant varchar2(ora_max_name_len*2 + 3) := 
    'sys."_ACTUAL_EDITION_OBJ"';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-NAME**', base_ne_name);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-NAME**', ae_ne_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-TYPE**', base_ne_type);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-TYPE**', ae_ne_type);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

comment on table USER_OBJECTS is
'Objects owned by the user'
/
comment on table USER_OBJECTS_AE is
'Objects owned by the user'
/

comment on column USER_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/

comment on column USER_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column USER_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/

comment on column USER_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column USER_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/

comment on column USER_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column USER_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/

comment on column USER_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column USER_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/

comment on column USER_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column USER_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/

comment on column USER_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column USER_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/

comment on column USER_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column USER_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/

comment on column USER_OBJECTS.STATUS is
'Status of the object'
/
comment on column USER_OBJECTS_AE.STATUS is
'Status of the object'
/

comment on column USER_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/

comment on column USER_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column USER_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/

comment on column USER_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/

comment on column USER_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column USER_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/

comment on column USER_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/
comment on column USER_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/

comment on column USER_OBJECTS.EDITIONABLE is
'Object is considered editionable'
/
comment on column USER_OBJECTS_AE.EDITIONABLE is
'Object is considered editionable'
/

comment on column USER_OBJECTS.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/
comment on column USER_OBJECTS_AE.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/

comment on column USER_OBJECTS.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column USER_OBJECTS_AE.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/

comment on column USER_OBJECTS.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/
comment on column USER_OBJECTS_AE.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/

comment on column USER_OBJECTS.DEFAULT_COLLATION is
'Default collation for the object'
/
comment on column USER_OBJECTS_AE.DEFAULT_COLLATION is
'Default collation for the object'
/

comment on column USER_OBJECTS.CREATED_APPID is
'ID of Application that created object'
/
comment on column USER_OBJECTS_AE.CREATED_APPID is
'ID of Application that created object'
/

comment on column USER_OBJECTS.CREATED_VSNID is 
'ID of Application Version that created object'
/
comment on column USER_OBJECTS_AE.CREATED_VSNID is
'ID of Application Version that created object'
/

comment on column USER_OBJECTS.MODIFIED_APPID is
'ID of Application that last modified object'
/
comment on column USER_OBJECTS_AE.MODIFIED_APPID is
'ID of Application that last modified object'
/

comment on column USER_OBJECTS.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/
comment on column USER_OBJECTS_AE.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/

create or replace public synonym USER_OBJECTS for USER_OBJECTS
/
create or replace public synonym OBJ for USER_OBJECTS
/
create or replace public synonym USER_OBJECTS_AE for USER_OBJECTS_AE
/
grant read on USER_OBJECTS to PUBLIC with grant option
/
grant read on USER_OBJECTS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME, SHARING,
     EDITIONABLE, ORACLE_MAINTAINED, APPLICATION, DEFAULT_COLLATION,
     DUPLICATED, SHARDED, CREATED_APPID, CREATED_VSNID, MODIFIED_APPID,
     MODIFIED_VSNID)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      **NON-EXISTENT-NAME**
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, CASE (SELECT BITAND(s.xpflags, 8388608 + 34359738368)
                                FROM sum$ s
                                WHERE s.obj#=o.obj#)
                          WHEN 8388608 THEN 'REWRITE EQUIVALENCE'
                          WHEN 34359738368 THEN 'MATERIALIZED ZONEMAP'
                          ELSE 'MATERIALIZED VIEW'
                          END,
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                      114, 'SQL TRANSLATION PROFILE',
                      115, 'UNIFIED AUDIT POLICY',
                      144, 'MINING MODEL PARTITION',
                      148, 'LOCKDOWN PROFILE',
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EXTENDED DATA LINK', &mdl, 'METADATA LINK', 
              &dl, 'DATA LINK', 'NONE'),
       case when o.type# in (4,5,7,8,9,11,12,13,14,22,87,114) then
           decode(bitand(o.flags, 1048576), 0, 'Y', 1048576, 'N', 'Y')
         else null end,
       decode(bitand(o.flags, 4194304), 4194304, 'Y', 'N'),
       decode(bitand(o.flags, 134217728), 134217728, 'Y', 'N'),
       case when o.type# in (2,4,7,8,9,12,13) then
           nls_collation_name(nvl(o.dflcollid, 16382))
         when (o.type# = 42 
               and exists
               (SELECT 1
                FROM sum$ s
                WHERE s.obj#=o.obj#
                -- not rewrite equivalence or zone map
                and bitand(s.xpflags, 8388608 + 34359738368) = 0)) then 
           nls_collation_name(nvl(o.dflcollid, 16382))
         else null end,
       decode(bitand(o.flags, 2684354560),
                     0, 'N', 
                     2147483648, 'Y', /* KQDOBREF set */
                      536870912, 'Y', /* KQDOBOAS set */
                     2684354560, 'Y', /* both KQDOBREF and KQDOBOAS set */
                     'N'),
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       -- CREATED_APPID
       o.CREAPPID,
       -- CREATED_VSNID
       o.CREVERID,
       -- MODIFIED_APPID,
       o.MODAPPID,
       -- MODIFIED_VSNID,
       o.MODVERID
from **OBJ-VIEW-NAME** o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  and (o.type# not in (1  /* INDEX - handled below */
                       **NON-EXISTENT-TYPE**)
       or
       (o.type# = 1 and 1 = (select 1
                             from sys.ind$ i
                            where i.obj# = o.obj#
                              and i.type# in (1, 2, 3, 4, 6, 7, 9))))
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
  -- Exclude XML Token set objects */
  and (o.type# not in (1 /* INDEXES */,
                       2 /* TABLES */,
                       6 /* SEQUENCE */)
      or
      (o.type# = 1 and not exists (select 1
                from sys.ind$ i, sys.tab$ t, sys.obj$ io
                where i.obj# = o.obj#
                  and io.obj# = i.bo#
                  and io.type# = 2
                  and i.bo# = t.obj#
                  and bitand(t.property, power(2,65)) =  power(2,65)))
      or
      (o.type# = 2 and 1 = (select 1
                from sys.tab$ t
                where t.obj# = o.obj#
                  and (bitand(t.property, power(2,65)) = 0
                         or t.property is null)))
      or
      (o.type# = 6 and 1 = (select 1
                from sys.seq$ s
                where s.obj# = o.obj#
                  and (bitand(s.flags, 1024) = 0 or s.flags is null))))
  and
  (
    o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
    or
    (
      /* non-procedural objects */
      o.type# not in (7, 8, 9, 11, 12, 13, 14, 28, 29, 30, 56, 93)
      and
      o.obj# in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (3 /* DELETE */,   6 /* INSERT */,
                                      7 /* LOCK */,     9 /* SELECT */,
                                      10 /* UPDATE */, 12 /* EXECUTE */,
                                      11 /* USAGE */,  16 /* CREATE */,
                                      17 /* READ */,   18 /* WRITE  */ ))
    )
    or
    (
       o.type# in (7, 8, 9, 28, 29, 30, 56) /* prc, fcn, pkg */
       and
       (
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        or /* user has system privileges */
         ora_check_sys_privilege ( o.owner#, o.type#) = 1
       )
    )
    or
    (
       o.type# in (19) /* partitioned table objects */
       and
       (
       exists (select bo# from tabpart$ where obj# = o.obj# and
               bo# in  (select obj# from sys.objauth$
                        where grantee# in (select kzsrorol from x$kzsro)
                        and privilege# in (9 /* SELECT */, 17 /* READ */))
              )
       or
       exists (select bo# from tabcompart$ where obj# = o.obj# and
               bo# in  (select obj# from sys.objauth$
                        where grantee# in (select kzsrorol from x$kzsro)
                        and privilege# in (9 /* SELECT */, 17 /* READ */))
               )
       )
    )
    or
    (
       o.type# in (34) /* sub-partitioned table objects */
       and
       exists (select cp.bo# from tabsubpart$ sp, tabcompart$ cp
               where sp.obj# = o.obj# and sp.pobj# = cp.obj# and
                     cp.bo# in  (select obj# from sys.objauth$
                     where  grantee# in (select kzsrorol from x$kzsro)
                     and privilege# in (9 /* SELECT */, 17 /* READ */))
              )
    )
    or
    (
       o.type# in (12) /* trigger */
       and
       (
         exists (select null from sys.trigger$ t, sys.objauth$ oa
                  where bitand(t.property, 24) = 0
                    and t.obj# = o.obj#
                    and oa.obj# = t.baseobject
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or /* user has system privileges */
         ora_check_sys_privilege (o.owner#, o.type#) = 1
       )
    )
    or
    (
       o.type# = 11 /* pkg body */
       and
       (
         exists (select null
                   from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                        sys.objauth$ oa
                  where specobj.owner# = o.owner#
                    and specobj.name = o.name
                    and specobj.type# = 9 /* pkg */
                    and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                    and oa.obj# = specobj.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# = 26 /* DEBUG */)
         or /* user has system privileges */
         ora_check_sys_privilege (o.owner#, o.type#) = 1
       )
    )
    or
    (
       o.type# in (1) /* index */
       and
       exists (select i.obj# from ind$ i
               where i.obj# = o.obj#    
                 and exists (select null from sys.objauth$ oa
                             where oa.obj# = i.bo#
                               and oa.grantee# in (select kzsrorol
                                                   from x$kzsro)
                            )
              )
    )
    or
    ( o.type# = 13 /* type */
      and
      (
        exists (select null from sys.objauth$ oa
                 where oa.obj# = o.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        or /* user has system privileges */
         ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
    )
    or
    (
      o.type# = 14 /* type body */
      and
      (
        exists (select null
                  from sys."_ACTUAL_EDITION_OBJ" specobj, sys.dependency$ dep,
                       sys.objauth$ oa
                 where specobj.owner# = o.owner#
                   and specobj.name = o.name
                   and specobj.type# = 13 /* type */
                   and dep.d_obj# = o.obj# and dep.p_obj# = specobj.obj#
                   and oa.obj# = specobj.obj#
                   and oa.grantee# in (select kzsrorol from x$kzsro)
                   and oa.privilege# = 26 /* DEBUG */)
        or /* user has system privileges */
         ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
    )
    or
    (
       o.type# in 
       (
        1, /* index */
        2, /* table */
        3, /* view */
        4, /* synonym */
        5, /* table partn */
        6, /* sequence */
        19, /* index partn */
        20, /* table subpartn */
        22, /* library */
        23, /* directory */
        32, /* indextype */
        33, /* operator */   
        34, /* index subpartn */
        35, /* cluster */
        42, /* summary */
        44, /* context */
        46, /* rule set */
        48, /* resource consumer group */
        59, /* rule */
        62, /* evaluation context */
        66, /* scheduler job */
        67, /* scheduler program */
        68, /* scheduler job class */
        79, /* scheduler chain */
        81, /* file group */
        82, /* mining model */
        87, /* assembly */
        92, /* cube dimension */
        94, /* measure folder */
        95, /* cube build process */
        100 /* file watcher */
       )
       and
          /* user has system privileges */
       ora_check_sys_privilege (o.owner#, o.type#) = 1
    )
    or
    (
      o.type# = 55 /* XML schema */
      and
      1 = (select /*+ NO_MERGE */ xml_schema_name_present.is_schema_present(o.name, u2.id2) id1 from (select /*+ NO_MERGE */ userenv('SCHEMAID') id2 from dual) u2)
      /* we need a sub-query instead of the directy invoking
       * xml_schema_name_present, because inside a view even the function
       * arguments are evaluated as definers rights.
       */
    )
    or 
    (
     /* scheduler windows, scheduler groups, schedules and destinations */
     /* no privileges are needed to view these objects */
     o.type# in (69, 72, 74, 101)
    )
    or
    (
     o.type# = 57 /* edition */
    )
    or
    (
      o.type# = 93 /* cube */
      and 
      (o.obj# in 
            ( select obj#  /* directly granted privileges */
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or
       (
        /* user has system privileges */
        ora_check_sys_privilege ( o.owner#, o.type#) = 1
       )
      )   
      and  /* require access to all Dimensions of the Cube */
      ( 1 = ( SELECT decode(have_all_dim_access, null, 1, have_all_dim_access)
              FROM
                ( SELECT
                    obj#,
                    MIN(have_dim_access) have_all_dim_access
                  FROM
                    ( SELECT
                        c.obj# obj#,
                        ( CASE
                          WHEN
                            ( do.owner# in ( userenv('SCHEMAID'), 1 )  /* public objects */
                              or do.obj# in
                              ( select obj#  /* directly granted privileges */
                                from sys.objauth$
                                where grantee# in ( select kzsrorol from x$kzsro )
                              )
                              or  /* user has system privileges */
                              ora_check_sys_privilege ( do.owner#, do.type#) = 1
                            )
                          THEN 1
                          ELSE 0
                          END ) have_dim_access
                      FROM
                        olap_cubes$ c,
                        dependency$ d,
                        obj$ do
                      WHERE
                        do.obj# = d.p_obj#
                        AND do.type# = 92 /* CUBE DIMENSION */
                        AND c.obj# = d.d_obj#
                    )
                  GROUP BY obj# ) da
              WHERE
                o.obj#=da.obj#(+)     
            )
      )
    )
    or
    (
       o.type# = 114 /* sql translation profile */
       and
       (
         exists (select null from sys.objauth$ oa
                  where oa.obj# = o.obj#
                    and oa.grantee# in (select kzsrorol from x$kzsro)
                    and oa.privilege# in (0 /* ALTER */, 29 /* USE */))
         or
         /* user has system privileges */
         ora_check_sys_privilege ( o.owner#, o.type#) = 1
       )
    )
    or
    (
       o.type# in (
                   150, /* hierarchy */
                   151, /* attribute dimension */
                   152  /* analytic view */
                  )
       and ora_check_sys_privilege(o.owner#, o.type#) = 1
    )
  )!';

  base_view_name constant dbms_id := 'all_objects';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ne_name   constant varchar2(32767) := '';
  ae_ne_name     constant varchar2(32767) := q'!10, 'NON-EXISTENT',!';

  base_ne_type   constant varchar2(32767) := q'!, 10 /* NON-EXISTENT */!';
  ae_ne_type     constant varchar2(32767) := '';

  base_obj_view constant varchar2(ora_max_name_len*2 + 3) :=
    'sys."_CURRENT_EDITION_OBJ"';
  ae_obj_view   constant varchar2(ora_max_name_len*2 + 3) := 
    'sys."_ACTUAL_EDITION_OBJ"';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-NAME**', base_ne_name);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-NAME**', ae_ne_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-TYPE**', base_ne_type);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-TYPE**', ae_ne_type);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

comment on table ALL_OBJECTS is
'Objects accessible to the user'
/
comment on table ALL_OBJECTS_AE is
'Objects accessible to the user'
/

comment on column ALL_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_OBJECTS_AE.OWNER is
'Username of the owner of the object'
/

comment on column ALL_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/

comment on column ALL_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column ALL_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/

comment on column ALL_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/

comment on column ALL_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column ALL_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/

comment on column ALL_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column ALL_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/

comment on column ALL_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column ALL_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/

comment on column ALL_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column ALL_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/

comment on column ALL_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column ALL_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/

comment on column ALL_OBJECTS.STATUS is
'Status of the object'
/
comment on column ALL_OBJECTS_AE.STATUS is
'Status of the object'
/

comment on column ALL_OBJECTS.TEMPORARY is
'Can the current session only see data that it placed in this object itself?'
/
comment on column ALL_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it placed in this object itself?'
/

comment on column ALL_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column ALL_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/

comment on column ALL_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/

comment on column ALL_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column ALL_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/

comment on column ALL_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/
comment on column ALL_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/

comment on column ALL_OBJECTS.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/
comment on column ALL_OBJECTS_AE.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/

comment on column ALL_OBJECTS.EDITIONABLE is
'Object is considered editionable'
/
comment on column ALL_OBJECTS_AE.EDITIONABLE is
'Object is considered editionable'
/

comment on column ALL_OBJECTS.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column ALL_OBJECTS_AE.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/

comment on column ALL_OBJECTS.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/
comment on column ALL_OBJECTS_AE.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/

comment on column ALL_OBJECTS.DEFAULT_COLLATION is
'Default collation for the object'
/
comment on column ALL_OBJECTS_AE.DEFAULT_COLLATION is
'Default collation for the object'
/

comment on column ALL_OBJECTS.CREATED_APPID is
'ID of Application that created object'
/
comment on column ALL_OBJECTS_AE.CREATED_APPID is
'ID of Application that created object'
/

comment on column ALL_OBJECTS.CREATED_VSNID is
'ID of Application Version that created object'
/
comment on column ALL_OBJECTS_AE.CREATED_VSNID is
'ID of Application Version that created object'
/

comment on column ALL_OBJECTS.MODIFIED_APPID is
'ID of Application that last modified object'
/
comment on column ALL_OBJECTS_AE.MODIFIED_APPID is
'ID of Application that last modified object'
/

comment on column ALL_OBJECTS.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/
comment on column ALL_OBJECTS_AE.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/

create or replace public synonym ALL_OBJECTS for ALL_OBJECTS
/
grant read on ALL_OBJECTS to PUBLIC with grant option
/
create or replace public synonym ALL_OBJECTS_AE for ALL_OBJECTS_AE
/
grant read on ALL_OBJECTS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID,
     OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS,
     TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME, SHARING,
     EDITIONABLE, ORACLE_MAINTAINED, APPLICATION, DEFAULT_COLLATION,
     DUPLICATED, SHARDED, CREATED_APPID, CREATED_VSNID, MODIFIED_APPID,
     MODIFIED_VSNID)
as
select u.name, o.name, o.subname, o.obj#, o.dataobj#,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
                      7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                      **NON-EXISTENT-NAME**
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY',
                      19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
                      22, 'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30, 'JAVA RESOURCE',
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      34, 'TABLE SUBPARTITION', 35, 'INDEX SUBPARTITION',
                      40, 'LOB PARTITION', 41, 'LOB SUBPARTITION',
                      42, CASE (SELECT BITAND(s.xpflags, 8388608 + 34359738368)
                                FROM sum$ s
                                WHERE s.obj#=o.obj#)
                          WHEN 8388608 THEN 'REWRITE EQUIVALENCE'
                          WHEN 34359738368 THEN 'MATERIALIZED ZONEMAP'
                          ELSE 'MATERIALIZED VIEW'
                          END,
                      43, 'DIMENSION',
                      44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
                      48, 'CONSUMER GROUP',
                      51, 'SUBSCRIPTION', 52, 'LOCATION',
                      55, 'XML SCHEMA', 56, 'JAVA DATA',
                      57, 'EDITION', 59, 'RULE',
                      60, 'CAPTURE', 61, 'APPLY',
                      62, 'EVALUATION CONTEXT',
                      66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
                      72, 'SCHEDULER GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
                      81, 'FILE GROUP', 82, 'MINING MODEL', 87, 'ASSEMBLY',
                      90, 'CREDENTIAL', 92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      100, 'FILE WATCHER', 101, 'DESTINATION',
                      111, 'CONTAINER',
                      114, 'SQL TRANSLATION PROFILE',
                      115, 'UNIFIED AUDIT POLICY',
                      144, 'MINING MODEL PARTITION',
                      148, 'LOCKDOWN PROFILE',
                      150, 'HIERARCHY', 
                      151, 'ATTRIBUTE DIMENSION',
                      152, 'ANALYTIC VIEW',
                     'UNDEFINED'),
       o.ctime, o.mtime,
       to_char(o.stime, 'YYYY-MM-DD:HH24:MI:SS'),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       o.namespace,
       o.defining_edition,
       decode(bitand(o.flags, &sharing_bits), 
              &edl+&mdl, 'EXTENDED DATA LINK', &mdl, 'METADATA LINK', 
              &dl, 'DATA LINK', 'NONE'),
       case when o.type# in (4,5,7,8,9,11,12,13,14,22,87,114) then
           decode(bitand(o.flags, 1048576), 0, 'Y', 1048576, 'N', 'Y')
         else null end,
       decode(bitand(o.flags, 4194304), 4194304, 'Y', 'N'),
       decode(bitand(o.flags, 134217728), 134217728, 'Y', 'N'),
       case when o.type# in (2,4,7,8,9,12,13) then
           nls_collation_name(nvl(o.dflcollid, 16382))
         when (o.type# = 42 
               and exists
               (SELECT 1
                FROM sum$ s
                WHERE s.obj#=o.obj#
                -- not rewrite equivalence or zone map
                and bitand(s.xpflags, 8388608 + 34359738368) = 0)) then 
           nls_collation_name(nvl(o.dflcollid, 16382))
         else null end,
       decode(bitand(o.flags, 2684354560),
                     0, 'N', 
                     2147483648, 'Y', /* KQDOBREF set */
                      536870912, 'Y', /* KQDOBOAS set */
                     2684354560, 'Y', /* both KQDOBREF and KQDOBOAS set */
                     'N'),
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       -- CREATED_APPID
       o.CREAPPID,
       -- CREATED_VSNID
       o.CREVERID,
       -- MODIFIED_APPID,
       o.MODAPPID,
       -- MODIFIED_VSNID,
       o.MODVERID
from **OBJ-VIEW-NAME** o, sys.user$ u
where o.owner# = u.user#
  and o.linkname is null
  **NON-EXISTENT-TYPE**
  and o.name != '_NEXT_OBJECT'
  and o.name != '_default_auditing_options_'
  and bitand(o.flags, 128) = 0
  -- Exclude XML Token set objects */
  and (o.type# not in (1 /* INDEXES */,
                       2 /* TABLES */,
                       6 /* SEQUENCE */)
      or
      (o.type# = 1 and not exists (select 1
                from sys.ind$ i, sys.tab$ t, sys.obj$ io
                where i.obj# = o.obj#
                  and io.obj# = i.bo#
                  and io.type# = 2
                  and i.bo# = t.obj#
                  and bitand(t.property, power(2,65)) =  power(2,65)))
      or
      (o.type# = 2 and 1 = (select 1
                from sys.tab$ t
                where t.obj# = o.obj#
                  and (bitand(t.property, power(2,65)) = 0
                        or t.property is null)))
      or
      (o.type# = 6 and 1 = (select 1
                from sys.seq$ s
                where s.obj# = o.obj#
                  and (bitand(s.flags, 1024) = 0 or s.flags is null))))
union all
select u.name, l.name, NULL, to_number(null), to_number(null),
       'DATABASE LINK',
       l.ctime, to_date(null), NULL, 'VALID','N','N', 'N', NULL, NULL,
       'NONE', NULL, 'N', 'N', NULL, 'N', 'N', 
       -- CREATED_APPID
       NULL, 
       -- CREATED_VSNID
       NULL, 
       -- MODIFIED_APPID
       NULL, 
       -- MODIFIED_VSNID
       NULL
from sys.link$ l, sys.user$ u
where l.owner# = u.user#!';

  base_view_name constant dbms_id := 'dba_objects';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ne_name   constant varchar2(32767) := '';
  ae_ne_name     constant varchar2(32767) := q'!10, 'NON-EXISTENT',!';

  base_ne_type   constant varchar2(32767) :=
    q'! and o.type# !=  10 /* NON-EXISTENT */!';
  ae_ne_type     constant varchar2(32767) := '';

  base_obj_view constant varchar2(ora_max_name_len*2 + 3) :=
    'sys."_CURRENT_EDITION_OBJ"';
  ae_obj_view   constant varchar2(ora_max_name_len*2 + 3) := 
    'sys."_ACTUAL_EDITION_OBJ"';

  base_stmt varchar2(32767) := view_text;
  ae_stmt   varchar2(32767) := view_text;
begin
  base_stmt := replace(base_stmt, '**VIEW-NAME**', base_view_name);
  ae_stmt   := replace(ae_stmt, '**VIEW-NAME**', ae_view_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-NAME**', base_ne_name);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-NAME**', ae_ne_name);

  base_stmt := replace(base_stmt, '**NON-EXISTENT-TYPE**', base_ne_type);
  ae_stmt   := replace(ae_stmt, '**NON-EXISTENT-TYPE**', ae_ne_type);

  base_stmt := replace(base_stmt, '**OBJ-VIEW-NAME**', base_obj_view);
  ae_stmt   := replace(ae_stmt, '**OBJ-VIEW-NAME**', ae_obj_view);

  execute immediate base_stmt;

  execute immediate ae_stmt;
end;
/

create or replace public synonym DBA_OBJECTS for DBA_OBJECTS
/
create or replace public synonym DBA_OBJECTS_AE for DBA_OBJECTS_AE
/

grant select on DBA_OBJECTS to select_catalog_role
/
grant select on DBA_OBJECTS_AE to select_catalog_role
/

grant read on DBA_OBJECTS to AUDIT_ADMIN
/
grant read on DBA_OBJECTS_AE to AUDIT_ADMIN
/

comment on table DBA_OBJECTS is
'All objects in the database'
/
comment on table DBA_OBJECTS_AE is
'All objects in the database'
/

comment on column DBA_OBJECTS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_OBJECTS_AE.OWNER is
'Username of the owner of the object'
/

comment on column DBA_OBJECTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJECTS_AE.OBJECT_NAME is
'Name of the object'
/

comment on column DBA_OBJECTS.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/
comment on column DBA_OBJECTS_AE.SUBOBJECT_NAME is
'Name of the sub-object (for example, partititon)'
/

comment on column DBA_OBJECTS.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_OBJECTS_AE.OBJECT_ID is
'Object number of the object'
/

comment on column DBA_OBJECTS.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/
comment on column DBA_OBJECTS_AE.DATA_OBJECT_ID is
'Object number of the segment which contains the object'
/

comment on column DBA_OBJECTS.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJECTS_AE.OBJECT_TYPE is
'Type of the object'
/

comment on column DBA_OBJECTS.CREATED is
'Timestamp for the creation of the object'
/
comment on column DBA_OBJECTS_AE.CREATED is
'Timestamp for the creation of the object'
/

comment on column DBA_OBJECTS.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/
comment on column DBA_OBJECTS_AE.LAST_DDL_TIME is
'Timestamp for the last DDL change (including GRANT and REVOKE) to the object'
/

comment on column DBA_OBJECTS.TIMESTAMP is
'Timestamp for the specification of the object'
/
comment on column DBA_OBJECTS_AE.TIMESTAMP is
'Timestamp for the specification of the object'
/

comment on column DBA_OBJECTS.STATUS is
'Status of the object'
/
comment on column DBA_OBJECTS_AE.STATUS is
'Status of the object'
/

comment on column DBA_OBJECTS.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECTS_AE.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/

comment on column DBA_OBJECTS.GENERATED is
'Was the name of this object system generated?'
/
comment on column DBA_OBJECTS_AE.GENERATED is
'Was the name of this object system generated?'
/

comment on column DBA_OBJECTS.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECTS_AE.SECONDARY is
'Is this a secondary object created as part of icreate for domain indexes?'
/

comment on column DBA_OBJECTS.NAMESPACE is
'Namespace for the object'
/
comment on column DBA_OBJECTS_AE.NAMESPACE is
'Namespace for the object'
/

comment on column DBA_OBJECTS.EDITION_NAME is
'Name of the edition in which the object is actual'
/
comment on column DBA_OBJECTS_AE.EDITION_NAME is
'Name of the edition in which the object is actual'
/

comment on column DBA_OBJECTS.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/
comment on column DBA_OBJECTS_AE.SHARING is
'Is this a Metadata Link, an Object Link or neither?'
/

comment on column DBA_OBJECTS.EDITIONABLE is
'Object is considered editionable'
/
comment on column DBA_OBJECTS_AE.EDITIONABLE is
'Object is considered editionable'
/

comment on column DBA_OBJECTS.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column DBA_OBJECTS_AE.ORACLE_MAINTAINED is
'Denotes whether the object was created, and is maintained, by Oracle-supplied scripts. An object for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/

comment on column DBA_OBJECTS.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/
comment on column DBA_OBJECTS_AE.APPLICATION is
'Denotes whether the object is part of an Application Container.'
/

comment on column DBA_OBJECTS.DEFAULT_COLLATION is
'Default collation for the object'
/
comment on column DBA_OBJECTS_AE.DEFAULT_COLLATION is
'Default collation for the object'
/

comment on column DBA_OBJECTS.CREATED_APPID is
'ID of Application that created object'
/
comment on column DBA_OBJECTS_AE.CREATED_APPID is
'ID of Application that created object'
/

comment on column DBA_OBJECTS.CREATED_VSNID is
'ID of Application Version that created object'
/
comment on column DBA_OBJECTS_AE.CREATED_VSNID is
'ID of Application Version that created object'
/

comment on column DBA_OBJECTS.MODIFIED_APPID is
'ID of Application that last modified object'
/
comment on column DBA_OBJECTS_AE.MODIFIED_APPID is
'ID of Application that last modified object'
/

comment on column DBA_OBJECTS.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/
comment on column DBA_OBJECTS_AE.MODIFIED_VSNID is
'ID of Application Version that last modified object'
/

execute CDBView.create_cdbview(false,'SYS','DBA_OBJECTS','CDB_OBJECTS');
grant select on SYS.CDB_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_OBJECTS for SYS.CDB_OBJECTS
/
execute CDBView.create_cdbview(false,'SYS','DBA_OBJECTS_AE','CDB_OBJECTS_AE');
grant select on SYS.CDB_OBJECTS_AE to select_catalog_role
/
create or replace public synonym CDB_OBJECTS_AE for SYS.CDB_OBJECTS_AE
/

Rem
Rem DBA view to identify INVALID objects before/after an upgrade
Rem
Rem This view eliminates old versions of object types from the DBA_OBJECTS
Rem view.  These objects may be invalid after an upgrade due to changes made
Rem during the upgrade, but they are no longer used.

create or replace view DBA_INVALID_OBJECTS
as
select * from DBA_OBJECTS
where STATUS = 'INVALID' and
  (OBJECT_TYPE != 'TYPE' or (OBJECT_TYPE='TYPE' and SUBOBJECT_NAME is null));

create or replace public synonym DBA_INVALID_OBJECTS for DBA_INVALID_OBJECTS;

grant select on DBA_INVALID_OBJECTS to select_catalog_role;

execute CDBView.create_cdbview(false,'SYS','DBA_INVALID_OBJECTS','CDB_INVALID_OBJECTS');
grant select on SYS.CDB_INVALID_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_INVALID_OBJECTS for SYS.CDB_INVALID_OBJECTS
/

remark  The EDITIONING_VIEWS_AE family shows this relationship for editioning
remark  views in all editions
remark

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (VIEW_NAME, TABLE_NAME **EDITION-COL-NAME**)
as
select ev_obj.name, ev.base_tbl_name **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.ev$ ev
where 
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV */
       ev_obj.obj# = ev.ev_obj#
       /* ensure that the EV belongs to the current schema */
  and  ev_obj.owner# = userenv('SCHEMAID')!';

  base_view_name constant dbms_id := 'user_editioning_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table USER_EDITIONING_VIEWS is
'Descriptions of the user''s own Editioning Views'
/
comment on table USER_EDITIONING_VIEWS_AE is
'Descriptions of the user''s own Editioning Views'
/

comment on column USER_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column USER_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column USER_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/

comment on column USER_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym USER_EDITIONING_VIEWS 
  for USER_EDITIONING_VIEWS
/
grant read on USER_EDITIONING_VIEWS to PUBLIC with grant option
/

create or replace public synonym USER_EDITIONING_VIEWS_AE 
  for USER_EDITIONING_VIEWS_AE
/
grant read on USER_EDITIONING_VIEWS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, VIEW_NAME, TABLE_NAME **EDITION-COL-NAME**)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _*_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
  and  (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
         ora_check_sys_privilege (ev_obj.owner#, ev_obj.type#) = 1
      )!';

  base_view_name constant dbms_id := 'all_editioning_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table ALL_EDITIONING_VIEWS is
'Description of Editioning Views accessible to the user'
/
comment on table ALL_EDITIONING_VIEWS_AE is
'Description of Editioning Views accessible to the user'
/

comment on column ALL_EDITIONING_VIEWS.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS_AE.OWNER is
'Owner of an Editioning View'
/

comment on column ALL_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column ALL_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column ALL_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/

comment on column ALL_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym ALL_EDITIONING_VIEWS for ALL_EDITIONING_VIEWS
/
grant read on ALL_EDITIONING_VIEWS to PUBLIC with grant option
/
create or replace public synonym ALL_EDITIONING_VIEWS_AE for ALL_EDITIONING_VIEWS_AE
/
grant read on ALL_EDITIONING_VIEWS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER, VIEW_NAME, TABLE_NAME **EDITION-COL-NAME**)
as
select ev_user.name, ev_obj.name, ev.base_tbl_name **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.ev$ ev, sys.user$ ev_user
where 
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
       ev_obj.obj# = ev.ev_obj#
       /* join _*_EDITION_OBJ row pertaining to EV to USER$ to get */
       /* EV owner name */
  and  ev_obj.owner# = ev_user.user#!';

  base_view_name constant dbms_id := 'dba_editioning_views';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table DBA_EDITIONING_VIEWS is
'Description of all Editioning Views in the database'
/
comment on table DBA_EDITIONING_VIEWS_AE is
'Description of all Editioning Views in the database'
/

comment on column DBA_EDITIONING_VIEWS.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS_AE.OWNER is
'Owner of an Editioning View'
/

comment on column DBA_EDITIONING_VIEWS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEWS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column DBA_EDITIONING_VIEWS.TABLE_NAME is
'Name of an Editioning View''s base table'
/
comment on column DBA_EDITIONING_VIEWS_AE.TABLE_NAME is
'Name of an Editioning View''s base table'
/

comment on column DBA_EDITIONING_VIEWS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym DBA_EDITIONING_VIEWS for DBA_EDITIONING_VIEWS
/
grant select on DBA_EDITIONING_VIEWS to select_catalog_role
/

create or replace public synonym DBA_EDITIONING_VIEWS_AE for DBA_EDITIONING_VIEWS_AE
/
grant select on DBA_EDITIONING_VIEWS_AE to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONING_VIEWS','CDB_EDITIONING_VIEWS');
grant select on SYS.CDB_EDITIONING_VIEWS to select_catalog_role
/
create or replace public synonym CDB_EDITIONING_VIEWS for SYS.CDB_EDITIONING_VIEWS
/
execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONING_VIEWS_AE','CDB_EDITIONING_VIEWS_AE');
grant select on SYS.CDB_EDITIONING_VIEWS_AE to select_catalog_role
/
create or replace public synonym CDB_EDITIONING_VIEWS_AE for SYS.CDB_EDITIONING_VIEWS_AE
/

remark
remark  FAMILY "EDITIONING_VIEW_COLS" and "EDITIONING_VIEW_COLS_AE"
remark  
remark  These views describe relationship between columns of Editioning 
remark  Views (a.k.a. EVs) and the table columns to which they map.
remark
remark  The EDITIONING_VIEW_COLS_AE views describe this relationship in
remark  all editions
remark

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME
     **EDITION-COL-NAME**)
as
select ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
       **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and ensure that the EV belongs to the current */
       /* schema */
  and  ev_obj.obj# = ev.ev_obj#
  and  ev_obj.owner# = userenv('SCHEMAID')!';

  base_view_name constant dbms_id := 'user_editioning_view_cols';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table USER_EDITIONING_VIEW_COLS is
'Relationship between columns of user''s Editioning Views and the table columns to which they map'
/
comment on table USER_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of user''s Editioning Views and the table columns to which they map'
/

comment on column USER_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column USER_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/

comment on column USER_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'The name of the column in the Editioning View'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'The name of the column in the Editioning View'
/

comment on column USER_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/

comment on column USER_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column USER_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

comment on column USER_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym USER_EDITIONING_VIEW_COLS for USER_EDITIONING_VIEW_COLS
/
grant read on USER_EDITIONING_VIEW_COLS to PUBLIC with grant option
/
create or replace public synonym USER_EDITIONING_VIEW_COLS_AE for USER_EDITIONING_VIEW_COLS_AE
/
grant read on USER_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME
     **EDITION-COL-NAME**)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
       **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _*_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
   and ev_obj.owner# = ev_user.user#
       /* make sure the EV is visible to the current user */
   and (ev_obj.owner# = userenv('SCHEMAID')
        or ev_obj.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
         ora_check_sys_privilege (ev_obj.owner#, ev_obj.type#) = 1
      )!';

  base_view_name constant dbms_id := 'all_editioning_view_cols';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table ALL_EDITIONING_VIEW_COLS is
'Relationship between columns of Editioning Views accessible to the user and the table columns to which they map'
/
comment on table ALL_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of Editioning Views accessible to the user and the table columns to which they map'
/

comment on column ALL_EDITIONING_VIEW_COLS.OWNER is
'Owner of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.OWNER is
'Owner of an Editioning View'
/

comment on column ALL_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column ALL_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/

comment on column ALL_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/

comment on column ALL_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/

comment on column ALL_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column ALL_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

comment on column ALL_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym ALL_EDITIONING_VIEW_COLS for ALL_EDITIONING_VIEW_COLS
/
grant read on ALL_EDITIONING_VIEW_COLS to PUBLIC with grant option
/
create or replace public synonym ALL_EDITIONING_VIEW_COLS_AE for ALL_EDITIONING_VIEW_COLS_AE
/
grant read on ALL_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/

declare
  view_text constant varchar2(32767) := q'!
create or replace view **VIEW-NAME**
    (OWNER,
     VIEW_NAME,
     VIEW_COLUMN_ID,
     VIEW_COLUMN_NAME,
     TABLE_COLUMN_ID,
     TABLE_COLUMN_NAME
     **EDITION-COL-NAME**)
as
select ev_user.name,
       ev_obj.name,
       view_col.col#,
       view_col.name,
       tbl_col.col#,
       tbl_col.name
       **EDITION-COL**
from   **OBJ-VIEW-NAME** ev_obj, sys.obj$ base_tbl_obj, 
       sys.ev$ ev, sys.evcol$ ev_col, sys.col$ view_col, sys.col$ tbl_col, 
       sys.user$ ev_user
where  /* get all columns of a given EV */
       ev.ev_obj# = ev_col.ev_obj# 
       /* join EVCOL$ to COL$ on EV id and column id to obtain EV column */
       /* name */
  and  ev_col.ev_obj# = view_col.obj#
  and  ev_col.ev_col_id = view_col.col#
       /* join EV$ to OBJ$ on base table owner id and base table name so we */
       /* can determine base table id */
  and  ev.base_tbl_owner# = base_tbl_obj.owner#
  and  ev.base_tbl_name   = base_tbl_obj.name
       /* exclude [sub]partitions by restricting base_tbl_obj.type# to */
       /* "table"; since COL$ will not contain rows for [sub]partitions, */
       /* this restriction is not, strictly speaking, necessary, but it */
       /* does ensure that the above join will return exactly one row */
  and base_tbl_obj.type# = 2
       /* join EVCOL$ row and OBJ$ row describing the EV's base table to */
       /* COL$ to obtain base table column id */
  and  base_tbl_obj.obj# = tbl_col.obj#
  and  ev_col.base_tbl_col_name = tbl_col.name
       /* join EV$ to _*_EDITION_OBJ on EV id so we can determine */
       /* name of the EV and id of its owner */
  and  ev_obj.obj# = ev.ev_obj#
       /* join _*_EDITION_OBJ row describing the EV to USER$ to get */
       /* owner name */
  and  ev_obj.owner# = ev_user.user#!';

  base_view_name constant dbms_id := 'dba_editioning_view_cols';
  ae_view_name   constant dbms_id := base_view_name || '_ae';

  base_ed_col_name constant varchar2(ora_max_name_len) := '';
  ae_ed_col_name   constant varchar2(ora_max_name_len + 2) := ', edition_name';

  base_ed_col constant varchar2(ora_max_name_len) := '';
  ae_ed_col   constant varchar2(ora_max_name_len*2 + 3) :=
    ', ev_obj.defining_edition';

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

comment on table DBA_EDITIONING_VIEW_COLS is
'Relationship between columns of all Editioning Views in the database and the table columns to which they map'
/
comment on table DBA_EDITIONING_VIEW_COLS_AE is
'Relationship between columns of all Editioning Views in the database and the table columns to which they map'
/

comment on column DBA_EDITIONING_VIEW_COLS.OWNER is
'Owner of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.OWNER is
'Owner of an Editioning View'
/

comment on column DBA_EDITIONING_VIEW_COLS.VIEW_NAME is
'Name of an Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_NAME is
'Name of an Editioning View'
/

comment on column DBA_EDITIONING_VIEW_COLS.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_ID is
'Column number within the Editioning View'
/

comment on column DBA_EDITIONING_VIEW_COLS.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.VIEW_COLUMN_NAME is
'Name of the column in the Editioning View'
/

comment on column DBA_EDITIONING_VIEW_COLS.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_ID is
'Column number of a table column to which this EV column maps'
/

comment on column DBA_EDITIONING_VIEW_COLS.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/
comment on column DBA_EDITIONING_VIEW_COLS_AE.TABLE_COLUMN_NAME is
'Name of a table column to which this EV column maps'
/

comment on column DBA_EDITIONING_VIEW_COLS_AE.EDITION_NAME is
'Name of the Application Edition where the Editioning View is defined'
/

create or replace public synonym DBA_EDITIONING_VIEW_COLS for DBA_EDITIONING_VIEW_COLS
/
grant read on DBA_EDITIONING_VIEW_COLS to PUBLIC with grant option
/
create or replace public synonym DBA_EDITIONING_VIEW_COLS_AE for DBA_EDITIONING_VIEW_COLS_AE
/
grant read on DBA_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option
/

execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONING_VIEW_COLS','CDB_EDITIONING_VIEW_COLS');
grant read on SYS.CDB_EDITIONING_VIEW_COLS to PUBLIC with grant option 
/
create or replace public synonym CDB_EDITIONING_VIEW_COLS for SYS.CDB_EDITIONING_VIEW_COLS
/
execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONING_VIEW_COLS_AE','CDB_EDITIONING_VIEW_COLS_AE');
grant read on SYS.CDB_EDITIONING_VIEW_COLS_AE to PUBLIC with grant option 
/
create or replace public synonym CDB_EDITIONING_VIEW_COLS_AE for SYS.CDB_EDITIONING_VIEW_COLS_AE
/


remark
remark  FAMILY "*_EDITIONS"
remark
remark  Describes all editions in the database
remark
create or replace view ALL_EDITIONS
    (EDITION_NAME, PARENT_EDITION_NAME, USABLE)
as
select o.name, po.name, decode(bitand(e.flags,1),1,'NO','YES')
from sys.obj$ o, sys.edition$ e, sys.obj$ po
where o.obj# = e.obj#
  and po.obj# (+)= e.p_obj#
/

comment on table ALL_EDITIONS is
'Describes all editions in the database'
/
comment on column ALL_EDITIONS.EDITION_NAME is
'Name of the edition'
/
comment on column ALL_EDITIONS.PARENT_EDITION_NAME is
'Name of the parent edition for this edition'
/
comment on column ALL_EDITIONS.USABLE is
'A value of ''YES'' means edition is usable and ''NO'' means unusable'
/
grant read on ALL_EDITIONS to public with grant option
/
create or replace public synonym ALL_EDITIONS for ALL_EDITIONS
/

create or replace view DBA_EDITIONS
    (EDITION_NAME, PARENT_EDITION_NAME, USABLE)
as
select o.name, po.name, decode(bitand(e.flags,1),1,'NO','YES')
from sys.obj$ o, sys.edition$ e, sys.obj$ po
where o.obj# = e.obj#
  and po.obj# (+)= e.p_obj#
/

comment on table DBA_EDITIONS is
'Describes all editions in the database'
/
comment on column DBA_EDITIONS.EDITION_NAME is
'Name of the edition'
/
comment on column DBA_EDITIONS.PARENT_EDITION_NAME is
'Name of the parent edition for this edition'
/
comment on column DBA_EDITIONS.USABLE is
'A value of ''YES'' means edition is usable and ''NO'' means unusable'
/
create or replace public synonym DBA_EDITIONS for DBA_EDITIONS
/
grant select on DBA_EDITIONS to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONS','CDB_EDITIONS');
grant select on SYS.CDB_EDITIONS to select_catalog_role
/
create or replace public synonym CDB_EDITIONS for SYS.CDB_EDITIONS
/



create or replace view USABLE_EDITIONS
    (EDITION_NAME, PARENT_EDITION_NAME)
as
select o.name, po.name
from sys.obj$ o, sys.edition$ e, sys.obj$ po
where o.obj# = e.obj#
  and po.obj# (+)= e.p_obj#
  and bitand(e.flags,1) = 0
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
       or /* All users have implicit USE priv on the db default edition */
         o.name = (select property_value
                   from database_properties 
                   where property_name = 'DEFAULT_EDITION')
      )
/

comment on table USABLE_EDITIONS is
'Describes all usable editions in the database'
/
comment on column USABLE_EDITIONS.EDITION_NAME is
'Name of the edition'
/
comment on column USABLE_EDITIONS.PARENT_EDITION_NAME is
'Name of the parent edition for this edition'
/
create or replace public synonym USABLE_EDITIONS for USABLE_EDITIONS
/
grant read on USABLE_EDITIONS to PUBLIC with grant option
/



remark
remark  FAMILY "*_EDITION_COMMENTS"
remark
remark Describe comments on all editions in the database
remark

create or replace view ALL_EDITION_COMMENTS
    (EDITION_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj# (+)
  and o.type# = 57
/

comment on table ALL_EDITION_COMMENTS is
'Describes comments on all editions in the database'
/
comment on column ALL_EDITION_COMMENTS.EDITION_NAME is
'Name of the edition'
/
comment on column ALL_EDITION_COMMENTS.COMMENTS is
'Edition comments'
/
grant read on ALL_EDITION_COMMENTS to public with grant option
/
create or replace public synonym ALL_EDITION_COMMENTS for ALL_EDITION_COMMENTS
/

create or replace view DBA_EDITION_COMMENTS
    (EDITION_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c
where o.obj# = c.obj# (+)
  and o.type# = 57
/

comment on table DBA_EDITION_COMMENTS is
'Describes comments on all editions in the database'
/
comment on column DBA_EDITION_COMMENTS.EDITION_NAME is
'Name of the edition'
/
comment on column DBA_EDITION_COMMENTS.COMMENTS is
'Edition comments'
/
create or replace public synonym DBA_EDITION_COMMENTS for DBA_EDITION_COMMENTS
/
grant select on DBA_EDITION_COMMENTS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_EDITION_COMMENTS','CDB_EDITION_COMMENTS');
grant select on SYS.CDB_EDITION_COMMENTS to select_catalog_role
/
create or replace public synonym CDB_EDITION_COMMENTS for SYS.CDB_EDITION_COMMENTS
/

remark
remark  FAMILY "EDITIONED_TYPES"
remark  List of object types that are editionable in a user's schema
remark
create or replace view USER_EDITIONED_TYPES (OBJECT_TYPE) as select
       decode(type#, 4, 'VIEW', 5, 'SYNONYM',
                     7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                     11, 'PACKAGE BODY', 12, 'TRIGGER',
                     13, 'TYPE', 14, 'TYPE BODY',
                     22, 'LIBRARY', 87, 'ASSEMBLY',
                     114, 'SQL TRANSLATION PROFILE',
                     'UNDEFINED')
from sys.user_editioning$
where user# = userenv('SCHEMAID') and type# != 10
/
comment on column USER_EDITIONED_TYPES.OBJECT_TYPE is
'Object type that is editionable'
/
create or replace public synonym USER_EDITIONED_TYPES for USER_EDITIONED_TYPES
/
grant read on USER_EDITIONED_TYPES to PUBLIC with grant option
/

create or replace view DBA_EDITIONED_TYPES (SCHEMA, OBJECT_TYPE)
as select u.name,
       decode(ue.type#, 4, 'VIEW', 5, 'SYNONYM',
                     7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                     11, 'PACKAGE BODY', 12, 'TRIGGER',
                     13, 'TYPE', 14, 'TYPE BODY',
                     22, 'LIBRARY', 87, 'ASSEMBLY',
                     114, 'SQL TRANSLATION PROFILE',
                     'UNDEFINED')
from sys.user_editioning$ ue, sys.user$ u
where ue.user# = u.user# and ue.type# != 10
/
comment on column DBA_EDITIONED_TYPES.SCHEMA is
'Schema in which the object types is editionable'
/
comment on column DBA_EDITIONED_TYPES.OBJECT_TYPE is
'Object type that is editionable'
/
create or replace public synonym DBA_EDITIONED_TYPES for DBA_EDITIONED_TYPES
/
grant select on DBA_EDITIONED_TYPES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_EDITIONED_TYPES','CDB_EDITIONED_TYPES');
grant select on SYS.CDB_EDITIONED_TYPES to select_catalog_role
/
create or replace public synonym CDB_EDITIONED_TYPES for SYS.CDB_EDITIONED_TYPES
/


create or replace view FLASHBACK_TRANSACTION_QUERY
as select xid, start_scn, start_timestamp,
          decode(commit_scn, 0, commit_scn, 281474976710655, NULL, commit_scn)
          commit_scn, commit_timestamp,
          logon_user, undo_change#, operation, table_name, table_owner,
          row_id, undo_sql
from sys.x$ktuqqry
/
comment on table FLASHBACK_TRANSACTION_QUERY is
'Description of the flashback transaction query view'
/
comment on column FLASHBACK_TRANSACTION_QUERY.XID is
'Transaction identifier'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_SCN is
'Transaction start SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.START_TIMESTAMP is
'Transaction start timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_SCN is
'Transaction commit SCN'
/
comment on column FLASHBACK_TRANSACTION_QUERY.COMMIT_TIMESTAMP is
'Transaction commit timestamp'
/
comment on column FLASHBACK_TRANSACTION_QUERY.LOGON_USER is
'Logon user for transaction'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_CHANGE# is
'1-based undo change number'
/
comment on column FLASHBACK_TRANSACTION_QUERY.OPERATION is
'forward operation for this undo'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_NAME is
'table name to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.TABLE_OWNER is
'owner of table to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.ROW_ID is
'rowid to which this undo applies'
/
comment on column FLASHBACK_TRANSACTION_QUERY.UNDO_SQL is
'SQL corresponding to this undo'
/
create or replace public synonym FLASHBACK_TRANSACTION_QUERY
     for FLASHBACK_TRANSACTION_QUERY
/
grant read on FLASHBACK_TRANSACTION_QUERY to public;
/

remark
remark  FAMILY "RESUMABLE"
remark  Resumable statement related information
remark
create or replace view DBA_RESUMABLE
    (USER_ID, SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID,
     STATUS, TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct S.USER# as USER_ID, R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
/
create or replace public synonym DBA_RESUMABLE for DBA_RESUMABLE
/
grant select on DBA_RESUMABLE to select_catalog_role
/
comment on table DBA_RESUMABLE is
'Resumable session information in the system'
/
comment on column DBA_RESUMABLE.USER_ID is
'User who own this resumable session'
/
comment on column DBA_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column DBA_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column DBA_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column DBA_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column DBA_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column DBA_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column DBA_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column DBA_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column DBA_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column DBA_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column DBA_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column DBA_RESUMABLE.ERROR_MSG is
'The current error message'
/

execute CDBView.create_cdbview(false,'SYS','DBA_RESUMABLE','CDB_RESUMABLE');
grant select on SYS.CDB_RESUMABLE to select_catalog_role
/
create or replace public synonym CDB_RESUMABLE for SYS.CDB_RESUMABLE
/

create or replace view USER_RESUMABLE
    (SESSION_ID, INSTANCE_ID, COORD_INSTANCE_ID, COORD_SESSION_ID, STATUS,
     TIMEOUT, START_TIME, SUSPEND_TIME, RESUME_TIME, NAME, SQL_TEXT,
     ERROR_NUMBER, ERROR_PARAMETER1, ERROR_PARAMETER2, ERROR_PARAMETER3,
     ERROR_PARAMETER4, ERROR_PARAMETER5, ERROR_MSG)
as
select distinct R.SID as SESSION_ID,
       R.INST_ID as INSTANCE_ID, P.QCINST_ID, P.QCSID,
       R.STATUS, R.TIMEOUT, NVL(T.START_TIME, R.SUSPEND_TIME) as START_TIME,
       R.SUSPEND_TIME, R.RESUME_TIME, R.NAME, Q.SQL_TEXT, R.ERROR_NUMBER,
       R.ERROR_PARAMETER1, R.ERROR_PARAMETER2, R.ERROR_PARAMETER3,
       R.ERROR_PARAMETER4, R.ERROR_PARAMETER5, R.ERROR_MSG
from GV$RESUMABLE R, GV$SESSION S, GV$TRANSACTION T, GV$SQL Q, GV$PX_SESSION P
where S.SID=R.SID and S.INST_ID=R.INST_ID
      and S.SADDR=T.SES_ADDR(+) and S.INST_ID=T.INST_ID(+)
      and S.SQL_ADDRESS=Q.ADDRESS(+) and S.INST_ID=Q.INST_ID(+)
      and S.SADDR=P.SADDR(+) and S.INST_ID=P.INST_ID(+)
      and R.ENABLED='YES' and NVL(T.SPACE(+),'NO')='NO'
      and S.USER# = userenv('SCHEMAID')
/
create or replace public synonym USER_RESUMABLE for USER_RESUMABLE
/
grant read on USER_RESUMABLE to public with grant option
/
comment on table USER_RESUMABLE is
'Resumable session information for current user'
/
comment on column USER_RESUMABLE.SESSION_ID is
'Session ID of this resumable session'
/
comment on column USER_RESUMABLE.INSTANCE_ID is
'Instance ID of this resumable session'
/
comment on column USER_RESUMABLE.COORD_INSTANCE_ID is
'Instance number of parallel query coordinator'
/
comment on column USER_RESUMABLE.COORD_SESSION_ID is
'Session number of parallel query coordinator'
/
comment on column USER_RESUMABLE.STATUS is
'Status of this resumable session'
/
comment on column USER_RESUMABLE.TIMEOUT is
'Timeout of this resumable session'
/
comment on column USER_RESUMABLE.START_TIME is
'Start time of the current transaction'
/
comment on column USER_RESUMABLE.SUSPEND_TIME is
'Suspend time of the current statement'
/
comment on column USER_RESUMABLE.RESUME_TIME is
'Resume time of the current statement'
/
comment on column USER_RESUMABLE.NAME is
'Name of this resumable session'
/
comment on column USER_RESUMABLE.SQL_TEXT is
'The current SQL text'
/
comment on column USER_RESUMABLE.ERROR_NUMBER is
'The current error number'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER1 is
'The 1st parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER2 is
'The 2nd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER3 is
'The 3rd parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER4 is
'The 4th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_PARAMETER5 is
'The 5th parameter to the current error message'
/
comment on column USER_RESUMABLE.ERROR_MSG is
'The current error message'
/


@?/rdbms/admin/sqlsessend.sql
 
