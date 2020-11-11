rem 
rem $Header:
rem 
Rem Copyright (c) 1995, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem NAME
Rem   catadt.sql
Rem DESCRIPTION
Rem   This SQL script creates data dictionary views for showing meta-data
Rem   information for types and other object features in the RDBMS.
Rem NOTES
Rem   This script must be run while connected as SYS or INTERNAL.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catadt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catadt.sql
Rem SQL_PHASE: CATADT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cdobj.sql
Rem END SQL_FILE_METADATA
Rem
Rem MODIFIED
Rem     tojhuan    07/21/17  - Bug 25515456: un-desupport SQLJ types;
Rem                            restore type$ property flag 0x20000 for SQLJ and
Rem                            assign NPT a new property flag (0x10000000)
Rem     tojhuan    06/09/17  - Bug 24623721: server-side SQLJ is desupported;
Rem     skabraha   01/19/17  - support for non-persistable types
Rem     alejgarc   02/18/15  - BUG 20354135: Changing v$enableprivs querys for
Rem                            ora_check_sys_privilege func calls.
Rem     skayoor    11/30/14  - Proj 58196: Change Select priv to Read Priv
Rem     surman     01/23/14  - 13922626: Update SQL metadata
Rem     sasounda   11/19/13  - 17746252: handle KZSRAT when creating all_* view
Rem     talliu     06/28/13  - Add CDB view for DBA view
Rem     talliu     06/28/13  - Add CDB view for DBA view
Rem     ajbatta    05/16/13  - Bug 12432852: remove gratuitous joins to user$
Rem     rdecker    11/11/11  - 13020741: move plsql types to  plsql type views
Rem     rdecker    04/30/11  - Enhance views for PL/SQL types
Rem     yifeng     09/26/07  - bug 5987532 add length semantics information to
Rem                            ALL_COLL_TYPES and ALL_TYPE_ATTRS
Rem     atomar     04/19/07  - bug 5984502
Rem     skabraha   12/14/06  - add OLDIMAGE_COLUMNS views
Rem     achoi      04/14/06  - support application edition 
Rem     phchang    09/21/04  - lrg 1720097: change UNION ALL to UNION queries
Rem     phchang    07/08/04  - #2964278: avoid fts on ALL_TYPES, DBA_TYPES and 
Rem                            DBA_TYPE_ATTRS by making them Union All queries 
Rem     bbhowmic   11/21/03  - Bug 3258506 
Rem     cunnitha   02/07/03  - #2782260:filter out older versions 
Rem     phchang    11/13/02  - #2649563: make ALL_TYPE_ATTRS a UNION ALL query
Rem     qyu        11/01/02  - #2621434: fix xxx_coll_types 
Rem     mmorsi     05/28/02  - Fix for bug 2389429.
Rem     mmorsi     12/12/01  - Fix for bug 2147152.
Rem     ayoaz      08/20/01  - Support synonym in attributes and collections
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     allee      07/20/00  - fix SQLJ_TYPE_ATTRS family.
Rem     thoang     06/27/00  - Add user_type_versions 
Rem     allee      06/27/00  - new catalog defined for persistent JAVA object.
Rem     mmorsi     06/22/00  - TYPES views should return only the latest version.
Rem     rmurthy    06/28/00  - add typeid to xxx_types
Rem     allee      05/24/00 -  add FAMILY SQLJ_TYPES
Rem     rmurthy    04/21/00 -  type, attr, method - handle local&inherited
Rem     jwijaya    01/16/98 -  add ATTR_NO to _TYPE_ATTRS
Rem     jweisz     12/18/97 -  coll types for image compression flags          
Rem     cxcheng    12/31/96 -  fix bug in type views for invaild types
Rem     thoang     11/22/96 -  Update views for NCHAR
Rem     jwijaya    11/19/96 -  revise object terminologies
Rem     cxcheng    11/11/96 -  more changes to typecodes
Rem     cxcheng    11/08/96 -  change typecodes to match latest changes
Rem     jwijaya    10/14/96 -  fix coll_types comments
Rem     cxcheng    10/02/96 -  revert to version using type$.properties 64
Rem     jwijaya    07/18/96 -  add method_no;
Rem                            don't show pre-defined or built-in types
Rem     jwijaya    06/14/96 -  check for EXECUTE ANY TYPE
Rem     cxcheng    05/29/96 -  fix bugs
Rem     cxcheng    05/29/96 -  add charsetid and charsetform
Rem     asurpur    05/28/96 -  Dictionary Protection: granting privileges
Rem     mmonajje   05/22/96 -  Replace precision col name with precision#
Rem     tcheng     05/30/96 -  fix all_types, dba_types to skip sys-gen types
Rem     tcheng     05/09/96 -  don't display sys-gen types in USER_TYPES
Rem     jwijaya    05/09/96 -  NCHAR support
Rem     jwijaya    05/08/96 -  continue work
Rem     jwijaya    04/29/96 -  test the views
Rem     jwijaya    03/22/96 -  revisit type tables
Rem     jwijaya    11/29/95 -  Creation 
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "TYPES"
remark
remark  Views for showing information about types:
remark  USER_TYPES, ALL_TYPES, and DBA_TYPES
remark
create or replace view USER_TYPES
    (TYPE_NAME, TYPE_OID,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE, PERSISTABLE,
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS, TYPEID)
as
select o.name, t.toid,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(t.properties, 268435456), 268435456, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods, t.typeid
from sys.type$ t, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" so,
     sys.user$ su
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the most recent version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.package_obj# IS NULL  -- no PL/SQL types
/
comment on table USER_TYPES is
'Description of the user''s own types'
/
comment on column USER_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column USER_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column USER_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column USER_TYPES.ATTRIBUTES is
'Number of attributes (if any) in the type'
/
comment on column USER_TYPES.METHODS is
'Number of methods (if any) in the type'
/
comment on column USER_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column USER_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column USER_TYPES.FINAL is
'Is the type a final type?'
/
comment on column USER_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column USER_TYPES.PERSISTABLE is
'Is the type a persistable type?'
/
comment on column USER_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column USER_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column USER_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column USER_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
comment on column USER_TYPES.TYPEID is
'Type id value of the type'
/
create or replace public synonym USER_TYPES for USER_TYPES
/
grant read on USER_TYPES to PUBLIC with grant option
/

create or replace view ALL_TYPES
    (OWNER, TYPE_NAME, TYPE_OID,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE, PERSISTABLE,
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS, TYPEID)
as
select u.name, o.name, t.toid,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(t.properties, 268435456), 268435456, 'NO', 'YES'),        
       su.name, so.name, t.local_attrs, t.local_methods, t.typeid
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o, 
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the most recent version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.package_obj# IS NULL  -- no PL/SQL types
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
       )
UNION 
select null, o.name, t.toid,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(t.properties, 268435456), 268435456, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods, t.typeid
from sys.type$ t, sys."_CURRENT_EDITION_OBJ" o,
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where bitand(t.properties, 64) = 64  -- u.name is null
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the most recent version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.package_obj# IS NULL  -- no PL/SQL types
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_TYPES is
'Description of types accessible to the user'
/
comment on column ALL_TYPES.OWNER is
'Owner of the type'
/
comment on column ALL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column ALL_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column ALL_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column ALL_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column ALL_TYPES.METHODS is
'Number of methods in the type'
/
comment on column ALL_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column ALL_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column ALL_TYPES.FINAL is
'Is the type a final type?'
/
comment on column ALL_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column ALL_TYPES.PERSISTABLE is
'Is the type a persistable type?'
/
comment on column ALL_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column ALL_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column ALL_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column ALL_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
comment on column ALL_TYPES.TYPEID is
'Type id value of the type'
/
create or replace public synonym ALL_TYPES for ALL_TYPES
/
grant read on ALL_TYPES to PUBLIC with grant option
/

create or replace view DBA_TYPES
    (OWNER, TYPE_NAME, TYPE_OID,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE, PERSISTABLE, 
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS, TYPEID)
as
select u.name, o.name, t.toid,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(t.properties, 268435456), 268435456, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods, t.typeid
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o,
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.package_obj# IS NULL  -- filter out PL/SQL types
UNION 
select null, o.name, t.toid,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(t.properties, 268435456), 268435456, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods, t.typeid
from sys.type$ t, sys."_CURRENT_EDITION_OBJ" o,
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where bitand(t.properties, 64) = 64  -- u.name is null
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.package_obj# IS NULL  -- filter out PL/SQL types
/
comment on table DBA_TYPES is
'Description of all types in the database'
/
comment on column DBA_TYPES.OWNER is
'Owner of the type'
/
comment on column DBA_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column DBA_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column DBA_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column DBA_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column DBA_TYPES.METHODS is
'Number of methods in the type'
/
comment on column DBA_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column DBA_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column DBA_TYPES.FINAL is
'Is the type a final type?'
/
comment on column DBA_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column DBA_TYPES.PERSISTABLE is
'Is the type a persistable type?'
/
comment on column DBA_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column DBA_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column DBA_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column DBA_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
comment on column DBA_TYPES.TYPEID is
'Type id value of the type'
/
create or replace public synonym DBA_TYPES for DBA_TYPES
/
grant select on DBA_TYPES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TYPES','CDB_TYPES');
grant select on SYS.CDB_TYPES to select_catalog_role
/
create or replace public synonym CDB_TYPES for SYS.CDB_TYPES
/

remark
remark  FAMILY "COLL_TYPES"
remark
remark  Views for showing information about named collection types
remark  (also categorized under named primitive types):
remark  USER_COLL_TYPES, ALL_COLL_TYPES, and DBA_COLL_TYPES
remark
create or replace view USER_COLL_TYPES
    (TYPE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_MOD, ELEM_TYPE_OWNER, ELEM_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ELEM_STORAGE, 
     NULLS_STORED)
as
select o.name, co.name, c.upper_bound,
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER')),
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)),
       c.length, c.precision, c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES')
from sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = c.toid
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
  and c.package_obj# IS NULL -- filter out plsql types
/
comment on table USER_COLL_TYPES is
'Description of the user''s own named collection types'
/
comment on column USER_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column USER_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column USER_COLL_TYPES.UPPER_BOUND is
'Size of the FIXED ARRAY type or maximum size of the VARYING ARRAY type'
/
comment on column USER_COLL_TYPES.ELEM_TYPE_MOD is
'Type modifier of the element'
/
comment on column USER_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column USER_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column USER_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column USER_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column USER_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column USER_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column USER_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column USER_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
create or replace public synonym USER_COLL_TYPES for USER_COLL_TYPES
/
grant read on USER_COLL_TYPES to PUBLIC with grant option
/
create or replace view ALL_COLL_TYPES
    (OWNER, TYPE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_MOD, ELEM_TYPE_OWNER, ELEM_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ELEM_STORAGE, 
     NULLS_STORED, CHAR_USED)
as
select u.name, o.name, co.name, c.upper_bound,
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER')),
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)),
       c.length, c.precision, c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(c.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = c.toid
  and o.subname IS NULL -- only the most recent version
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
  and c.package_obj# IS NULL -- filter out plsql types
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
         ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
/
comment on table ALL_COLL_TYPES is
'Description of named collection types accessible to the user'
/
comment on column ALL_COLL_TYPES.OWNER is
'Owner of the type'
/
comment on column ALL_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column ALL_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column ALL_COLL_TYPES.UPPER_BOUND is
'Size of the FIXED ARRAY type or maximum size of the VARYING ARRAY type'
/
comment on column ALL_COLL_TYPES.ELEM_TYPE_MOD is
'Type modifier of the element'
/
comment on column ALL_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column ALL_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column ALL_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column ALL_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column ALL_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column ALL_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column ALL_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column ALL_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
comment on column ALL_COLL_TYPES.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
create or replace public synonym ALL_COLL_TYPES for ALL_COLL_TYPES
/
grant read on ALL_COLL_TYPES to PUBLIC with grant option
/
create or replace view DBA_COLL_TYPES
    (OWNER, TYPE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_MOD, ELEM_TYPE_OWNER, ELEM_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME,ELEM_STORAGE, 
     NULLS_STORED)
as
select u.name, o.name, co.name, c.upper_bound,
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER')),
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)),
       c.length, c.precision, c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = u.user#
  and o.oid$ = c.toid
  and o.subname IS NULL -- only the most recent version
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
  and c.package_obj# IS NULL -- filter out plsql types
/
comment on table DBA_COLL_TYPES is
'Description of all named collection types in the database'
/
comment on column DBA_COLL_TYPES.OWNER is
'Owner of the type'
/
comment on column DBA_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column DBA_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column DBA_COLL_TYPES.UPPER_BOUND is
'Size of the FIXED ARRAY type or maximum size of the VARYING ARRAY type'
/
comment on column DBA_COLL_TYPES.ELEM_TYPE_MOD is
'Type modifier of the element'
/
comment on column DBA_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column DBA_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column DBA_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column DBA_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column DBA_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column DBA_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column DBA_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column DBA_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
create or replace public synonym DBA_COLL_TYPES for DBA_COLL_TYPES
/
grant select on DBA_COLL_TYPES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_COLL_TYPES','CDB_COLL_TYPES');
grant select on SYS.CDB_COLL_TYPES to select_catalog_role
/
create or replace public synonym CDB_COLL_TYPES for SYS.CDB_COLL_TYPES
/

remark
remark  FAMILY "TYPE_ATTRS"
remark
remark  Views for showing attribute information of object types:
remark  USER_TYPE_ATTRS, ALL_TYPE_ATTRS, and DBA_TYPE_ATTRS
remark
create or replace view USER_TYPE_ATTRS
    (TYPE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, INHERITED)
as
select o.name, a.name,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o 
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a, 
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = t.toid
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and t.package_obj# IS NULL -- filter out plsql types
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
/
comment on table USER_TYPE_ATTRS is
'Description of attributes of the user''s own types'
/
comment on column USER_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column USER_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column USER_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column USER_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column USER_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column USER_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column USER_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column USER_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column USER_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column USER_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column USER_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
create or replace public synonym USER_TYPE_ATTRS for USER_TYPE_ATTRS
/
grant read on USER_TYPE_ATTRS to PUBLIC with grant option
/
create or replace view ALL_TYPE_ATTRS
    (OWNER, TYPE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, 
     ATTR_NO, INHERITED, CHAR_USED)
as
select u.name , o.name, a.name,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO'),
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and o.oid$ = t.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and t.package_obj# IS NULL -- filter out plsql types
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
  and a.attr_version# = at.version#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_TYPE_ATTRS is
'Description of attributes of types accessible to the user'
/
comment on column ALL_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column ALL_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column ALL_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column ALL_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column ALL_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column ALL_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column ALL_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column ALL_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column ALL_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column ALL_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column ALL_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
comment on column ALL_TYPE_ATTRS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
create or replace public synonym ALL_TYPE_ATTRS for ALL_TYPE_ATTRS
/
grant read on ALL_TYPE_ATTRS to PUBLIC with grant option
/

create or replace view DBA_TYPE_ATTRS
    (OWNER, TYPE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, INHERITED)
as
select u.name, o.name, a.name,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and o.oid$ = t.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and t.package_obj# IS NULL -- filter out plsql types
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
  and a.attr_version# = at.version#
/
comment on table DBA_TYPE_ATTRS is
'Description of attributes of all types in the database'
/
comment on column DBA_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column DBA_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column DBA_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column DBA_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column DBA_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column DBA_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column DBA_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column DBA_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column DBA_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column DBA_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column DBA_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
create or replace public synonym DBA_TYPE_ATTRS for DBA_TYPE_ATTRS
/
grant select on DBA_TYPE_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TYPE_ATTRS','CDB_TYPE_ATTRS');
grant select on SYS.CDB_TYPE_ATTRS to select_catalog_role
/
create or replace public synonym CDB_TYPE_ATTRS for SYS.CDB_TYPE_ATTRS
/

remark
remark  FAMILY "TYPE_METHODS"
remark
remark  Views for showing method information of object types:
remark  USER_TYPE_METHODS, ALL_TYPE_METHODS, and DBA_TYPE_METHODS
remark
create or replace view USER_TYPE_METHODS
    (TYPE_NAME, METHOD_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select o.name, m.name, m.method#,
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys."_CURRENT_EDITION_OBJ" o, sys.method$ m
where o.owner# = userenv('SCHEMAID')
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
/
comment on table USER_TYPE_METHODS is
'Description of methods of the user''s own types'
/
comment on column USER_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column USER_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column USER_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column USER_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column USER_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column USER_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column USER_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column USER_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column USER_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column USER_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym USER_TYPE_METHODS for USER_TYPE_METHODS
/
grant read on USER_TYPE_METHODS to PUBLIC with grant option
/
create or replace view ALL_TYPE_METHODS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select u.name, o.name, m.name, m.method#,
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_TYPE_METHODS is
'Description of methods of types accessible to the user'
/
comment on column ALL_TYPE_METHODS.OWNER is
'Owner of the type'
/
comment on column ALL_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column ALL_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column ALL_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column ALL_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column ALL_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column ALL_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column ALL_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column ALL_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column ALL_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym ALL_TYPE_METHODS for ALL_TYPE_METHODS
/
grant read on ALL_TYPE_METHODS to PUBLIC with grant option
/
create or replace view DBA_TYPE_METHODS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select u.name, o.name, m.name, m.method#,
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
/
comment on table DBA_TYPE_METHODS is
'Description of methods of all types in the database'
/
comment on column DBA_TYPE_METHODS.OWNER is
'Owner of the type'
/
comment on column DBA_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column DBA_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column DBA_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column DBA_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column DBA_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column DBA_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column DBA_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column DBA_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column DBA_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym DBA_TYPE_METHODS for DBA_TYPE_METHODS
/
grant select on DBA_TYPE_METHODS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TYPE_METHODS','CDB_TYPE_METHODS');
grant select on SYS.CDB_TYPE_METHODS to select_catalog_role
/
create or replace public synonym CDB_TYPE_METHODS for SYS.CDB_TYPE_METHODS
/

remark
remark  FAMILY "METHOD_PARAMS"
remark
remark  Views for showing method parameter information of object types:
remark  USER_METHOD_PARAMS, ALL_METHOD_PARAMS, and
remark  DBA_METHOD_PARAMS
remark
create or replace view USER_METHOD_PARAMS
    (TYPE_NAME, METHOD_NAME, METHOD_NO,
     PARAM_NAME, PARAM_NO, PARAM_MODE, PARAM_TYPE_MOD,
     PARAM_TYPE_OWNER, PARAM_TYPE_NAME, CHARACTER_SET_NAME)
as
select o.name, m.name, m.method#,
       p.name, p.parameter#,
       decode(bitand(p.properties, 768), 768, 'IN OUT',
              decode(bitand(p.properties, 256), 256, 'IN',
                     decode(bitand(p.properties, 512), 512, 'OUT'))),
       decode(bitand(p.properties, 32768), 32768, 'REF',
              decode(bitand(p.properties, 16384), 16384, 'POINTER')),
       decode(bitand(pt.properties, 64), 64, null, pu.name),
       decode(pt.typecode,
              9, decode(p.charsetform, 2, 'NVARCHAR2', po.name),
              96, decode(p.charsetform, 2, 'NCHAR', po.name),
              112, decode(p.charsetform, 2, 'NCLOB', po.name),
              po.name),
       decode(p.charsetform, 1, 'CHAR_CS',         
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(p.charsetid),
                             4, 'ARG:'||p.charsetid)
from sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.parameter$ p,
     sys."_CURRENT_EDITION_OBJ" po, sys.user$ pu, sys.type$ pt
where o.owner# = userenv('SCHEMAID')
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = p.toid
  and m.version# = p.version#
  and m.method# = p.method#
  and p.param_toid = po.oid$
  and po.owner# = pu.user#
  and p.param_toid = pt.toid
  and p.param_version# = pt.version#
/
comment on table USER_METHOD_PARAMS is
'Description of method parameters of the user''s own types'
/
comment on column USER_METHOD_PARAMS.TYPE_NAME is
'Name of the type'
/
comment on column USER_METHOD_PARAMS.METHOD_NAME is
'Name of the method'
/
comment on column USER_METHOD_PARAMS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column USER_METHOD_PARAMS.PARAM_NAME is
'Name of the parameter'
/
comment on column USER_METHOD_PARAMS.PARAM_NO is
'Parameter number or position'
/
comment on column USER_METHOD_PARAMS.PARAM_MODE is
'Mode of the parameter'
/
comment on column USER_METHOD_PARAMS.PARAM_TYPE_MOD is
'Type modifier of the parameter'
/
comment on column USER_METHOD_PARAMS.PARAM_TYPE_OWNER is
'Owner of the type of the parameter'
/
comment on column USER_METHOD_PARAMS.PARAM_TYPE_NAME is
'Name of the type of the parameter'
/
comment on column USER_METHOD_PARAMS.CHARACTER_SET_NAME is
'Character set name of the parameter'
/
create or replace public synonym USER_METHOD_PARAMS for USER_METHOD_PARAMS
/
grant read on USER_METHOD_PARAMS to PUBLIC with grant option
/
create or replace view ALL_METHOD_PARAMS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO,
     PARAM_NAME, PARAM_NO, PARAM_MODE, PARAM_TYPE_MOD,
     PARAM_TYPE_OWNER, PARAM_TYPE_NAME, CHARACTER_SET_NAME)
as
select u.name, o.name, m.name, m.method#,
       p.name, p.parameter#,
       decode(bitand(p.properties, 768), 768, 'IN OUT',
              decode(bitand(p.properties, 256), 256, 'IN',
                     decode(bitand(p.properties, 512), 512, 'OUT'))),
       decode(bitand(p.properties, 32768), 32768, 'REF',
              decode(bitand(p.properties, 16384), 16384, 'POINTER')),
       decode(bitand(pt.properties, 64), 64, null, pu.name),
       decode(pt.typecode,
              9, decode(p.charsetform, 2, 'NVARCHAR2', po.name),
              96, decode(p.charsetform, 2, 'NCHAR', po.name),
              112, decode(p.charsetform, 2, 'NCLOB', po.name),
              po.name),
       decode(p.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(p.charsetid),
                             4, 'ARG:'||p.charsetid)
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.parameter$ p,
     sys."_CURRENT_EDITION_OBJ" po, sys.user$ pu, sys.type$ pt
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = p.toid
  and m.version# = p.version#
  and m.method# = p.method#
  and p.param_toid = po.oid$
  and po.owner# = pu.user#
  and p.param_toid = pt.toid
  and p.param_version# = pt.version#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       ora_check_sys_privilege (o.owner#, o.type#) = 1
       )
/
comment on table ALL_METHOD_PARAMS is
'Description of method parameters of types accessible
to the user'
/
comment on column ALL_METHOD_PARAMS.OWNER is
'Onwer of the type'
/
comment on column ALL_METHOD_PARAMS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_METHOD_PARAMS.METHOD_NAME is
'Name of the method'
/
comment on column ALL_METHOD_PARAMS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column ALL_METHOD_PARAMS.PARAM_NAME is
'Name of the parameter'
/
comment on column ALL_METHOD_PARAMS.PARAM_NO is
'Parameter number or position'
/
comment on column ALL_METHOD_PARAMS.PARAM_MODE is
'Mode of the parameter'
/
comment on column ALL_METHOD_PARAMS.PARAM_TYPE_MOD is
'Type modifier of the parameter'
/
comment on column ALL_METHOD_PARAMS.PARAM_TYPE_OWNER is
'Owner of the type of the parameter'
/
comment on column ALL_METHOD_PARAMS.PARAM_TYPE_NAME is
'Name of the type of the parameter'
/
comment on column ALL_METHOD_PARAMS.CHARACTER_SET_NAME is
'Character set name of the parameter'
/
create or replace public synonym ALL_METHOD_PARAMS for ALL_METHOD_PARAMS
/
grant read on ALL_METHOD_PARAMS to PUBLIC with grant option
/
create or replace view DBA_METHOD_PARAMS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO,
     PARAM_NAME, PARAM_NO, PARAM_MODE, PARAM_TYPE_MOD,
     PARAM_TYPE_OWNER, PARAM_TYPE_NAME, CHARACTER_SET_NAME)
as
select u.name, o.name, m.name, m.method#,
       p.name, p.parameter#,
       decode(bitand(p.properties, 768), 768, 'IN OUT',
              decode(bitand(p.properties, 256), 256, 'IN',
                     decode(bitand(p.properties, 512), 512, 'OUT'))),
       decode(bitand(p.properties, 32768), 32768, 'REF',
              decode(bitand(p.properties, 16384), 16384, 'POINTER')),
       decode(bitand(pt.properties, 64), 64, null, pu.name),
       decode(pt.typecode,
              9, decode(p.charsetform, 2, 'NVARCHAR2', po.name),
              96, decode(p.charsetform, 2, 'NCHAR', po.name),
              112, decode(p.charsetform, 2, 'NCLOB', po.name),
              po.name),
       decode(p.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(p.charsetid),
                             4, 'ARG:'||p.charsetid)
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.parameter$ p,
     sys."_CURRENT_EDITION_OBJ" po, sys.user$ pu, sys.type$ pt
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = p.toid
  and m.version# = p.version#
  and m.method# = p.method#
  and p.param_toid = po.oid$
  and po.owner# = pu.user#
  and p.param_toid = pt.toid
  and p.param_version# = pt.version#
/
comment on table DBA_METHOD_PARAMS is
'Description of method parameters of all types in the database'
/
comment on column DBA_METHOD_PARAMS.OWNER is
'Onwer of the type'
/
comment on column DBA_METHOD_PARAMS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_METHOD_PARAMS.METHOD_NAME is
'Name of the method'
/
comment on column DBA_METHOD_PARAMS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column DBA_METHOD_PARAMS.PARAM_NAME is
'Name of the parameter'
/
comment on column DBA_METHOD_PARAMS.PARAM_NO is
'Parameter number or position'
/
comment on column DBA_METHOD_PARAMS.PARAM_MODE is
'Mode of the parameter'
/
comment on column DBA_METHOD_PARAMS.PARAM_TYPE_MOD is
'Type modifier of the parameter'
/
comment on column DBA_METHOD_PARAMS.PARAM_TYPE_OWNER is
'Owner of the type of the parameter'
/
comment on column DBA_METHOD_PARAMS.PARAM_TYPE_NAME is
'Name of the type of the parameter'
/
comment on column DBA_METHOD_PARAMS.CHARACTER_SET_NAME is
'Character set name of the parameter'
/
create or replace public synonym DBA_METHOD_PARAMS for DBA_METHOD_PARAMS
/
grant select on DBA_METHOD_PARAMS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_METHOD_PARAMS','CDB_METHOD_PARAMS');
grant select on SYS.CDB_METHOD_PARAMS to select_catalog_role
/
create or replace public synonym CDB_METHOD_PARAMS for SYS.CDB_METHOD_PARAMS
/

remark
remark  FAMILY "METHOD_RESULTS"
remark
remark  Views for showing method result information of object types:
remark  USER_METHOD_RESULTS, ALL_METHOD_RESULTS, and
remark  DBA_METHOD_RESULTS
remark
create or replace view USER_METHOD_RESULTS
    (TYPE_NAME, METHOD_NAME, METHOD_NO,
     RESULT_TYPE_MOD,
     RESULT_TYPE_OWNER, RESULT_TYPE_NAME, CHARACTER_SET_NAME)
as
select o.name, m.name, m.method#,
       decode(bitand(r.properties, 32768), 32768, 'REF',
              decode(bitand(r.properties, 16384), 16384, 'POINTER')),
       decode(bitand(rt.properties, 64), 64, null, ru.name),
       decode(rt.typecode,
              9, decode(r.charsetform, 2, 'NVARCHAR2', ro.name),
              96, decode(r.charsetform, 2, 'NCHAR', ro.name),
              112, decode(r.charsetform, 2, 'NCLOB', ro.name),
              ro.name),
       decode(r.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(r.charsetid),
                             4, 'ARG:'||r.charsetid)
from sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.result$ r,
     sys."_CURRENT_EDITION_OBJ" ro, sys.user$ ru, sys.type$ rt
where o.owner# = userenv('SCHEMAID')
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = r.toid
  and m.version# = r.version#
  and m.method# = r.method#
  and r.result_toid = ro.oid$
  and ro.owner# = ru.user#
  and r.result_toid = rt.toid
  and r.result_version# = rt.version#
/
comment on table USER_METHOD_RESULTS is
'Description of method results of the user''s own types'
/
comment on column USER_METHOD_RESULTS.TYPE_NAME is
'Name of the type'
/
comment on column USER_METHOD_RESULTS.METHOD_NAME is
'Name of the method'
/
comment on column USER_METHOD_RESULTS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column USER_METHOD_RESULTS.RESULT_TYPE_MOD is
'Type modifier of the result'
/
comment on column USER_METHOD_RESULTS.RESULT_TYPE_OWNER is
'Owner of the type of the result'
/
comment on column USER_METHOD_RESULTS.RESULT_TYPE_NAME is
'Name of the type of the result'
/
comment on column USER_METHOD_RESULTS.CHARACTER_SET_NAME is
'Character set name of the result'
/
create or replace public synonym USER_METHOD_RESULTS for USER_METHOD_RESULTS
/
grant read on USER_METHOD_RESULTS to PUBLIC with grant option
/
create or replace view ALL_METHOD_RESULTS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO,
     RESULT_TYPE_MOD,
     RESULT_TYPE_OWNER, RESULT_TYPE_NAME, CHARACTER_SET_NAME)
as
select u.name, o.name, m.name, m.method#,
       decode(bitand(r.properties, 32768), 32768, 'REF',
              decode(bitand(r.properties, 16384), 16384, 'POINTER')),
       decode(bitand(rt.properties, 64), 64, null, ru.name),
       decode(rt.typecode,
              9, decode(r.charsetform, 2, 'NVARCHAR2', ro.name),
              96, decode(r.charsetform, 2, 'NCHAR', ro.name),
              112, decode(r.charsetform, 2, 'NCLOB', ro.name),
              ro.name),
       decode(r.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(r.charsetid),
                             4, 'ARG:'||r.charsetid)
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.result$ r,
     sys."_CURRENT_EDITION_OBJ" ro, sys.user$ ru, sys.type$ rt
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = r.toid
  and m.version# = r.version#
  and m.method# = r.method#
  and r.result_toid = ro.oid$
  and ro.owner# = ru.user#
  and r.result_toid = rt.toid
  and r.result_version# = rt.version#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
        ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
/
comment on table ALL_METHOD_RESULTS is
'Description of method results of types accessible
to the user'
/
comment on column ALL_METHOD_RESULTS.OWNER is
'Onwer of the type'
/
comment on column ALL_METHOD_RESULTS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_METHOD_RESULTS.METHOD_NAME is
'Name of the method'
/
comment on column ALL_METHOD_RESULTS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column ALL_METHOD_RESULTS.RESULT_TYPE_MOD is
'Type modifier of the result'
/
comment on column ALL_METHOD_RESULTS.RESULT_TYPE_OWNER is
'Owner of the type of the result'
/
comment on column ALL_METHOD_RESULTS.RESULT_TYPE_NAME is
'Name of the type of the result'
/
comment on column ALL_METHOD_RESULTS.CHARACTER_SET_NAME is
'Character set name of the result'
/
create or replace public synonym ALL_METHOD_RESULTS for ALL_METHOD_RESULTS
/
grant read on ALL_METHOD_RESULTS to PUBLIC with grant option
/
create or replace view DBA_METHOD_RESULTS
    (OWNER, TYPE_NAME, METHOD_NAME, METHOD_NO,
     RESULT_TYPE_MOD,
     RESULT_TYPE_OWNER, RESULT_TYPE_NAME, CHARACTER_SET_NAME)
as
select u.name, o.name, m.name, m.method#,
       decode(bitand(r.properties, 32768), 32768, 'REF',
              decode(bitand(r.properties, 16384), 16384, 'POINTER')),
       decode(bitand(rt.properties, 64), 64, null, ru.name),
       decode(rt.typecode,
              9, decode(r.charsetform, 2, 'NVARCHAR2', ro.name),
              96, decode(r.charsetform, 2, 'NCHAR', ro.name),
              112, decode(r.charsetform, 2, 'NCLOB', ro.name),
              ro.name),
       decode(r.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(r.charsetid),
                             4, 'ARG:'||r.charsetid)
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.method$ m, sys.result$ r,
     sys."_CURRENT_EDITION_OBJ" ro, sys.user$ ru, sys.type$ rt
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and m.toid = r.toid
  and m.version# = r.version#
  and m.method# = r.method#
  and r.result_toid = ro.oid$
  and ro.owner# = ru.user#
  and r.result_toid = rt.toid
  and r.result_version# = rt.version#
/
comment on table DBA_METHOD_RESULTS is
'Description of method results of all types in the database'
/
comment on column DBA_METHOD_RESULTS.OWNER is
'Onwer of the type'
/
comment on column DBA_METHOD_RESULTS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_METHOD_RESULTS.METHOD_NAME is
'Name of the method'
/
comment on column DBA_METHOD_RESULTS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column DBA_METHOD_RESULTS.RESULT_TYPE_MOD is
'Type modifier of the result'
/
comment on column DBA_METHOD_RESULTS.RESULT_TYPE_OWNER is
'Owner of the type of the result'
/
comment on column DBA_METHOD_RESULTS.RESULT_TYPE_NAME is
'Name of the type of the result'
/
comment on column DBA_METHOD_RESULTS.CHARACTER_SET_NAME is
'Character set name of the result'
/
create or replace public synonym DBA_METHOD_RESULTS for DBA_METHOD_RESULTS
/
grant select on DBA_METHOD_RESULTS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_METHOD_RESULTS','CDB_METHOD_RESULTS');
grant select on SYS.CDB_METHOD_RESULTS to select_catalog_role
/
create or replace public synonym CDB_METHOD_RESULTS for SYS.CDB_METHOD_RESULTS
/

remark
remark  FAMILY "SQLJ_TYPES"
remark
remark  Views for showing information about types:
remark  USER_SQLJ_TYPES, ALL_SQLJ_TYPES, and DBA_SQLJ_TYPES
remark
create or replace view USER_SQLJ_TYPES
    (TYPE_NAME, TYPE_OID, EXTERNAL_NAME, USING,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE,
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS)
as
select o.name, t.toid, t.externname, 
       decode(t.externtype, 1, 'SQLData',
                            2, 'CustomDatum',
                            3, 'Serializable',
                            4, 'Serializable Internal',
                            5, 'ORAData',
                            'unknown'),
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods
from sys.type$ t, sys."_CURRENT_EDITION_OBJ" o, sys."_CURRENT_EDITION_OBJ" so,
     sys.user$ su
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.externtype < 5
/
comment on table USER_SQLJ_TYPES is
'Description of the user''s own types'
/
comment on column USER_SQLJ_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column USER_SQLJ_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column USER_SQLJ_TYPES.EXTERNAL_NAME is
'External class name of the type'
/
comment on column USER_SQLJ_TYPES.USING is
'Representation of the type'
/
comment on column USER_SQLJ_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column USER_SQLJ_TYPES.ATTRIBUTES is
'Number of attributes (if any) in the type'
/
comment on column USER_SQLJ_TYPES.METHODS is
'Number of methods (if any) in the type'
/
comment on column USER_SQLJ_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column USER_SQLJ_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column USER_SQLJ_TYPES.FINAL is
'Is the type a final type?'
/
comment on column USER_SQLJ_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column USER_SQLJ_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column USER_SQLJ_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column USER_SQLJ_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column USER_SQLJ_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
create or replace public synonym USER_SQLJ_TYPES for USER_SQLJ_TYPES
/
grant read on USER_SQLJ_TYPES to PUBLIC with grant option
/
create or replace view ALL_SQLJ_TYPES
    (OWNER, TYPE_NAME, TYPE_OID, EXTERNAL_NAME, USING,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE,
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS)
as
select decode(bitand(t.properties, 64), 64, null, u.name), o.name, t.toid,
       t.externname,
       decode(t.externtype, 1, 'SQLData',
                            2, 'CustomDatum',
                            3, 'Serializable',
                            4, 'Serializable Internal',
                            5, 'ORAData',
                            'unknown'),
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o,
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where o.owner# = u.user#
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.externtype < 5
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_SQLJ_TYPES is
'Description of types accessible to the user'
/
comment on column ALL_SQLJ_TYPES.OWNER is
'Owner of the type'
/
comment on column ALL_SQLJ_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column ALL_SQLJ_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column ALL_SQLJ_TYPES.EXTERNAL_NAME is
'External class name of the type'
/
comment on column ALL_SQLJ_TYPES.USING is
'Representation of the type'
/
comment on column ALL_SQLJ_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column ALL_SQLJ_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column ALL_SQLJ_TYPES.METHODS is
'Number of methods in the type'
/
comment on column ALL_SQLJ_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column ALL_SQLJ_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column ALL_SQLJ_TYPES.FINAL is
'Is the type a final type?'
/
comment on column ALL_SQLJ_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column ALL_SQLJ_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column ALL_SQLJ_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column ALL_SQLJ_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column ALL_SQLJ_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
create or replace public synonym ALL_SQLJ_TYPES for ALL_SQLJ_TYPES
/
grant read on ALL_SQLJ_TYPES to PUBLIC with grant option
/
create or replace view DBA_SQLJ_TYPES
    (OWNER, TYPE_NAME, TYPE_OID, EXTERNAL_NAME, USING,
     TYPECODE, ATTRIBUTES, METHODS,
     PREDEFINED, INCOMPLETE, FINAL, INSTANTIABLE,
     SUPERTYPE_OWNER, SUPERTYPE_NAME, LOCAL_ATTRIBUTES, LOCAL_METHODS)
as
select decode(bitand(t.properties, 64), 64, null, u.name), o.name, t.toid,
       t.externname,
       decode(t.externtype, 1, 'SQLData',
                            2, 'CustomDatum',
                            3, 'Serializable',
                            4, 'Serializable Internal',
                            5, 'ORAData',
                            'unknown'),
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       t.attributes, t.methods,
       decode(bitand(t.properties, 16), 16, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 256), 256, 'YES', 0, 'NO'),
       decode(bitand(t.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(t.properties, 65536), 65536, 'NO', 'YES'),
       su.name, so.name, t.local_attrs, t.local_methods
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o,
     sys."_CURRENT_EDITION_OBJ" so, sys.user$ su
where o.owner# = u.user#
  and o.oid$ = t.tvoid
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.supertoid = so.oid$ (+) and so.owner# = su.user# (+)
  and t.externtype < 5
/
comment on table DBA_SQLJ_TYPES is
'Description of all types in the database'
/
comment on column DBA_SQLJ_TYPES.OWNER is
'Owner of the type'
/
comment on column DBA_SQLJ_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column DBA_SQLJ_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column DBA_SQLJ_TYPES.EXTERNAL_NAME is
'External class name of the type'
/
comment on column DBA_SQLJ_TYPES.USING is
'Representation of the type'
/
comment on column DBA_SQLJ_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column DBA_SQLJ_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column DBA_SQLJ_TYPES.METHODS is
'Number of methods in the type'
/
comment on column DBA_SQLJ_TYPES.PREDEFINED is
'Is the type a predefined type?'
/
comment on column DBA_SQLJ_TYPES.INCOMPLETE is
'Is the type an incomplete type?'
/
comment on column DBA_SQLJ_TYPES.FINAL is
'Is the type a final type?'
/
comment on column DBA_SQLJ_TYPES.INSTANTIABLE is
'Is the type an instantiable type?'
/
comment on column DBA_SQLJ_TYPES.SUPERTYPE_OWNER is
'Owner of the supertype (null if type is not a subtype)'
/
comment on column DBA_SQLJ_TYPES.SUPERTYPE_NAME is
'Name of the supertype (null if type is not a subtype)'
/
comment on column DBA_SQLJ_TYPES.LOCAL_ATTRIBUTES is
'Number of local (not inherited) attributes (if any) in the subtype'
/
comment on column DBA_SQLJ_TYPES.LOCAL_METHODS is
'Number of local (not inherited) methods (if any) in the subtype'
/
create or replace public synonym DBA_SQLJ_TYPES for DBA_SQLJ_TYPES
/
grant select on DBA_SQLJ_TYPES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SQLJ_TYPES','CDB_SQLJ_TYPES');
grant select on SYS.CDB_SQLJ_TYPES to select_catalog_role
/
create or replace public synonym CDB_SQLJ_TYPES for SYS.CDB_SQLJ_TYPES
/

remark
remark  FAMILY "TYPE_VERSIONS"
remark
remark  Views for showing information about types:
remark  USER_TYPE_VERSIONS, ALL_TYPE_VERSIONS, and DBA_TYPE_VERSIONS
remark

create or replace view USER_TYPE_VERSIONS
    (TYPE_NAME, VERSION#, TYPECODE, STATUS, LINE, TEXT, HASHCODE)
as
select o.name, t.version#,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       s.line, s.source,
       t.hashcode
from sys."_CURRENT_EDITION_OBJ" o, sys.source$ s, sys.type$ t
  where o.obj# = s.obj# and o.oid$ = t.tvoid and o.type# = 13
  and o.owner# = userenv('SCHEMAID');

comment on table USER_TYPE_VERSIONS is
'Description of each version of the user''s types'
/
comment on column USER_TYPE_VERSIONS.TYPE_NAME is
'Name of the type'
/
comment on column USER_TYPE_VERSIONS.VERSION# is
'Internal version number of the type'
/
comment on column USER_TYPE_VERSIONS.TYPECODE is
'Typecode of the type'
/
comment on column USER_TYPE_VERSIONS.STATUS is
'Status of the type'
/
comment on column USER_TYPE_VERSIONS.LINE is
'Line number of the type''s spec'
/
comment on column USER_TYPE_VERSIONS.TEXT is
'Text of the type''s spec'
/
comment on column USER_TYPE_VERSIONS.HASHCODE is
'Hashcode of the type'
/

create or replace public synonym USER_TYPE_VERSIONS for USER_TYPE_VERSIONS
/
grant read on USER_TYPE_VERSIONS to PUBLIC with grant option
/
create or replace view ALL_TYPE_VERSIONS
    (OWNER, TYPE_NAME, VERSION#, TYPECODE, STATUS, LINE, TEXT, HASHCODE)
as
select u.name, o.name, t.version#,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       s.line, s.source,
       t.hashcode
from sys."_CURRENT_EDITION_OBJ" o, sys.source$ s, sys.type$ t, user$ u
  where o.obj# = s.obj# and o.oid$ = t.tvoid and o.type# = 13
  and o.owner# = u.user# 
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/

comment on table ALL_TYPE_VERSIONS is
'Description of each type version accessible to the user'
/
comment on column ALL_TYPE_VERSIONS.OWNER is
'Owner of the type'
/
comment on column ALL_TYPE_VERSIONS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_TYPE_VERSIONS.VERSION# is
'Internal version number of the type'
/
comment on column ALL_TYPE_VERSIONS.TYPECODE is
'Typecode of the type'
/
comment on column ALL_TYPE_VERSIONS.STATUS is
'Status of the type'
/
comment on column ALL_TYPE_VERSIONS.LINE is
'Line number of the type''s spec'
/
comment on column ALL_TYPE_VERSIONS.TEXT is
'Text of the type''s spec'
/
comment on column ALL_TYPE_VERSIONS.HASHCODE is
'Hashcode of the type'
/

create or replace public synonym ALL_TYPE_VERSIONS for ALL_TYPE_VERSIONS
/
grant read on ALL_TYPE_VERSIONS to PUBLIC with grant option
/

create or replace view DBA_TYPE_VERSIONS
    (OWNER, TYPE_NAME, VERSION#, TYPECODE, STATUS, LINE, TEXT, HASHCODE)
as
select u.name, o.name, t.version#,
       decode(t.typecode, 108, 'OBJECT',
                          122, 'COLLECTION',
                          o.name),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       s.line, s.source,
       t.hashcode
from sys."_CURRENT_EDITION_OBJ" o, sys.source$ s, sys.type$ t, user$ u
  where o.obj# = s.obj# and o.oid$ = t.tvoid and o.type# = 13
  and o.owner# = u.user#;

comment on table DBA_TYPE_VERSIONS is
'Description of each type version in the database'
/
comment on column DBA_TYPE_VERSIONS.OWNER is
'Owner of the type'
/
comment on column DBA_TYPE_VERSIONS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_TYPE_VERSIONS.VERSION# is
'Internal version number of the type'
/
comment on column DBA_TYPE_VERSIONS.TYPECODE is
'Typecode of the type'
/
comment on column DBA_TYPE_VERSIONS.STATUS is
'Status of the type'
/
comment on column DBA_TYPE_VERSIONS.LINE is
'Line number of the type''s spec'
/
comment on column DBA_TYPE_VERSIONS.TEXT is
'Text of the type''s spec'
/
comment on column DBA_TYPE_VERSIONS.HASHCODE is
'Hashcode of the type'
/
create or replace public synonym DBA_TYPE_VERSIONS for DBA_TYPE_VERSIONS
/
grant select on DBA_TYPE_VERSIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TYPE_VERSIONS','CDB_TYPE_VERSIONS');
grant select on SYS.CDB_TYPE_VERSIONS to select_catalog_role
/
create or replace public synonym CDB_TYPE_VERSIONS for SYS.CDB_TYPE_VERSIONS
/

remark
remark  FAMILY "PENDING_CONV_TABLES"
remark
remark  Views for showing information about types:
remark  USER_PENDING_CONV_TABLES, ALL_PENDING_CONV_TABLES, and 
remark  DBA_PENDING_CONV_TABLES
remark

create or replace view USER_PENDING_CONV_TABLES
    (TABLE_NAME)
as
select o.name
from sys.obj$ o 
  where o.type# = 2 and o.status = 5 
  and bitand(o.flags, 4096) = 4096  /* type evolved flg */
  and o.owner# = userenv('SCHEMAID');

comment on table USER_PENDING_CONV_TABLES is
'All user''s tables which are not upgraded to the latest type version'
/
comment on column USER_PENDING_CONV_TABLES.TABLE_NAME is
'Name of the table'
/
create or replace public synonym USER_PENDING_CONV_TABLES
   for USER_PENDING_CONV_TABLES
/
grant read on USER_PENDING_CONV_TABLES to PUBLIC with grant option
/
create or replace view ALL_PENDING_CONV_TABLES
  (OWNER, TABLE_NAME)
as
select u.name, o.name 
from sys.obj$ o, user$ u
  where o.type# = 2 and o.status = 5 
  and bitand(o.flags, 4096) = 4096  /* type evolved flg */
  and o.owner# = u.user# 
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/

comment on table ALL_PENDING_CONV_TABLES is
'All tables accessible to the user which are not upgraded to the latest type version'
/
comment on column ALL_PENDING_CONV_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_PENDING_CONV_TABLES.TABLE_NAME is
'Name of the table'
/
create or replace public synonym ALL_PENDING_CONV_TABLES
   for ALL_PENDING_CONV_TABLES
/
grant read on ALL_PENDING_CONV_TABLES to PUBLIC with grant option
/

create or replace view DBA_PENDING_CONV_TABLES
  (OWNER, TABLE_NAME)
as
select u.name, o.name
from sys.obj$ o, user$ u
  where o.type# = 2 and o.status = 5
  and bitand(o.flags, 4096) = 4096  /* type evolved flg */
  and o.owner# = u.user#;

comment on table DBA_PENDING_CONV_TABLES is
'All tables which are not upgraded to the latest type version in the database'
/
comment on column DBA_PENDING_CONV_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_PENDING_CONV_TABLES.TABLE_NAME is
'Name of the table'
/
create or replace public synonym DBA_PENDING_CONV_TABLES
   for DBA_PENDING_CONV_TABLES
/
grant select on DBA_PENDING_CONV_TABLES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_PENDING_CONV_TABLES','CDB_PENDING_CONV_TABLES');
grant select on SYS.CDB_PENDING_CONV_TABLES to select_catalog_role
/
create or replace public synonym CDB_PENDING_CONV_TABLES for SYS.CDB_PENDING_CONV_TABLES
/

remark
remark  FAMILY "SQLJ_TYPE_ATTRS"
remark
remark  Views for showing attribute information of object types:
remark  USER_SQLJ_TYPE_ATTRS, ALL_SQLJ_TYPE_ATTRS, and DBA_SQLJ_TYPE_ATTRS
remark
create or replace view USER_SQLJ_TYPE_ATTRS
    (TYPE_NAME, ATTR_NAME, EXTERNAL_ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, INHERITED)
as
select o.name, a.name, a.externname,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       decode(bitand(at.properties, 64), 64, null, au.name),
       decode(at.typecode,
              9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
              96, decode(a.charsetform, 2, 'NCHAR', ao.name),
              112, decode(a.charsetform, 2, 'NCLOB', ao.name),
              ao.name),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a, 
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = t.toid
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
  and a.attr_version# = at.version#
  and t.externtype < 5
/
comment on table USER_SQLJ_TYPE_ATTRS is
'Description of attributes of the user''s own types'
/
comment on column USER_SQLJ_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column USER_SQLJ_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.EXTERNAL_ATTR_NAME is
'External name of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column USER_SQLJ_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column USER_SQLJ_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
create or replace public synonym USER_SQLJ_TYPE_ATTRS for USER_SQLJ_TYPE_ATTRS
/
grant read on USER_SQLJ_TYPE_ATTRS to PUBLIC with grant option
/
create or replace view ALL_SQLJ_TYPE_ATTRS
    (OWNER, TYPE_NAME, ATTR_NAME, EXTERNAL_ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, INHERITED)
as
select decode(bitand(t.properties, 64), 64, null, u.name), 
       o.name, a.name, a.externname,       
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       decode(bitand(at.properties, 64), 64, null, au.name),
       decode(at.typecode,
              9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
              96, decode(a.charsetform, 2, 'NCHAR', ao.name),
              112, decode(a.charsetform, 2, 'NCLOB', ao.name),
              ao.name),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = u.user#
  and o.oid$ = t.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
  and a.attr_version# = at.version#
  and t.externtype < 5
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_SQLJ_TYPE_ATTRS is
'Description of attributes of types accessible to the user'
/
comment on column ALL_SQLJ_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column ALL_SQLJ_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_SQLJ_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.EXTERNAL_ATTR_NAME is
'External name of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column ALL_SQLJ_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column ALL_SQLJ_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
create or replace public synonym ALL_SQLJ_TYPE_ATTRS for ALL_SQLJ_TYPE_ATTRS
/
grant read on ALL_SQLJ_TYPE_ATTRS to PUBLIC with grant option
/
create or replace view DBA_SQLJ_TYPE_ATTRS
    (OWNER, TYPE_NAME, ATTR_NAME, EXTERNAL_ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, INHERITED)
as
select decode(bitand(t.properties, 64), 64, null, u.name), 
       o.name, a.name, a.externname,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       decode(bitand(at.properties, 64), 64, null, au.name),
       decode(at.typecode,
              9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
              96, decode(a.charsetform, 2, 'NCHAR', ao.name),
              112, decode(a.charsetform, 2, 'NCLOB', ao.name),
              ao.name),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#, decode(bitand(nvl(a.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = u.user#
  and o.oid$ = t.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
  and a.attr_version# = at.version#
  and t.externtype < 5
/
comment on table DBA_SQLJ_TYPE_ATTRS is
'Description of attributes of all types in the database'
/
comment on column DBA_SQLJ_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column DBA_SQLJ_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_SQLJ_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.EXTERNAL_ATTR_NAME is
'External name of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column DBA_SQLJ_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column DBA_SQLJ_TYPE_ATTRS.INHERITED is
'Is the attribute inherited from the supertype ?'
/
create or replace public synonym DBA_SQLJ_TYPE_ATTRS for DBA_SQLJ_TYPE_ATTRS
/
grant select on DBA_SQLJ_TYPE_ATTRS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SQLJ_TYPE_ATTRS','CDB_SQLJ_TYPE_ATTRS');
grant select on SYS.CDB_SQLJ_TYPE_ATTRS to select_catalog_role
/
create or replace public synonym CDB_SQLJ_TYPE_ATTRS for SYS.CDB_SQLJ_TYPE_ATTRS
/

remark
remark  FAMILY "SQLJ_TYPE_METHODS"
remark
remark  Views for showing method information of object types:
remark  USER_SQLJ_TYPE_METHODS, ALL_SQLJ_TYPE_METHODS, and DBA_SQLJ_TYPE_METHODS
remark
create or replace view USER_SQLJ_TYPE_METHODS
    (TYPE_NAME, METHOD_NAME, EXTERNAL_VAR_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select o.name, m.name, m.externVarName, m.method#, 
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.method$ m
where o.owner# = userenv('SCHEMAID')
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = m.toid
  and t.version# = m.version#
  and t.externtype < 5
/
comment on table USER_SQLJ_TYPE_METHODS is
'Description of methods of the user''s own types'
/
comment on column USER_SQLJ_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column USER_SQLJ_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column USER_SQLJ_TYPE_METHODS.EXTERNAL_VAR_NAME is
'Name of the external variable'
/
comment on column USER_SQLJ_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column USER_SQLJ_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column USER_SQLJ_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column USER_SQLJ_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column USER_SQLJ_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column USER_SQLJ_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column USER_SQLJ_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column USER_SQLJ_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym USER_SQLJ_TYPE_METHODS
   for USER_SQLJ_TYPE_METHODS
/
grant read on USER_SQLJ_TYPE_METHODS to PUBLIC with grant option
/
create or replace view ALL_SQLJ_TYPE_METHODS
    (OWNER, TYPE_NAME, METHOD_NAME, EXTERNAL_VAR_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select u.name, o.name, m.name, m.externVarName, m.method#,
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.method$ m
where o.owner# = u.user#
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = m.toid
  and t.version# = m.version#
  and t.externtype < 5
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
          ora_check_sys_privilege (o.owner#, o.type#) = 1
  )
/
comment on table ALL_SQLJ_TYPE_METHODS is
'Description of methods of types accessible to the user'
/
comment on column ALL_SQLJ_TYPE_METHODS.OWNER is
'Owner of the type'
/
comment on column ALL_SQLJ_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_SQLJ_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column ALL_SQLJ_TYPE_METHODS.EXTERNAL_VAR_NAME is
'Name of the external variable'
/
comment on column ALL_SQLJ_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column ALL_SQLJ_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column ALL_SQLJ_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column ALL_SQLJ_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column ALL_SQLJ_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column ALL_SQLJ_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column ALL_SQLJ_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column ALL_SQLJ_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym ALL_SQLJ_TYPE_METHODS
   for ALL_SQLJ_TYPE_METHODS
/
grant read on ALL_SQLJ_TYPE_METHODS to PUBLIC with grant option
/
create or replace view DBA_SQLJ_TYPE_METHODS
    (OWNER, TYPE_NAME, METHOD_NAME, EXTERNAL_VAR_NAME, METHOD_NO, METHOD_TYPE,
     PARAMETERS, RESULTS, FINAL, INSTANTIABLE, OVERRIDING, INHERITED)
as
select u.name, o.name, m.name, m.externVarName, m.method#,
       decode(bitand(m.properties, 512), 512, 'MAP',
              decode(bitand(m.properties, 2048), 2048, 'ORDER', 'PUBLIC')),
       m.parameters#, m.results,
       decode(bitand(m.properties, 8), 8, 'NO', 'YES'),
       decode(bitand(m.properties, 65536), 65536, 'NO', 'YES'),
       decode(bitand(m.properties, 131072), 131072, 'YES', 'NO'),
       decode(bitand(nvl(m.xflags,0), 1), 1, 'YES', 'NO')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.method$ m
where o.owner# = u.user#
  and o.oid$ = m.toid
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = m.toid
  and t.version# = m.version#
  and t.externtype < 5
/
comment on table DBA_SQLJ_TYPE_METHODS is
'Description of methods of all types in the database'
/
comment on column DBA_SQLJ_TYPE_METHODS.OWNER is
'Owner of the type'
/
comment on column DBA_SQLJ_TYPE_METHODS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_SQLJ_TYPE_METHODS.METHOD_NAME is
'Name of the method'
/
comment on column DBA_SQLJ_TYPE_METHODS.EXTERNAL_VAR_NAME is
'Name of the external variable'
/
comment on column DBA_SQLJ_TYPE_METHODS.METHOD_NO is
'Method number for distinguishing overloaded method (not to be used as ID number)'
/
comment on column DBA_SQLJ_TYPE_METHODS.METHOD_TYPE is
'Type of the method'
/
comment on column DBA_SQLJ_TYPE_METHODS.PARAMETERS is
'Number of parameters to the method'
/
comment on column DBA_SQLJ_TYPE_METHODS.RESULTS is
'Number of results returned by the method'
/
comment on column DBA_SQLJ_TYPE_METHODS.FINAL is
'Is the method final ?'
/
comment on column DBA_SQLJ_TYPE_METHODS.INSTANTIABLE is
'Is the method instantiable ?'
/
comment on column DBA_SQLJ_TYPE_METHODS.OVERRIDING is
'Is the method overriding a supertype method ?'
/
comment on column DBA_SQLJ_TYPE_METHODS.INHERITED is
'Is the method inherited from the supertype ?'
/
create or replace public synonym DBA_SQLJ_TYPE_METHODS
   for DBA_SQLJ_TYPE_METHODS
/
grant select on DBA_SQLJ_TYPE_METHODS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SQLJ_TYPE_METHODS','CDB_SQLJ_TYPE_METHODS');
grant select on SYS.CDB_SQLJ_TYPE_METHODS to select_catalog_role
/
create or replace public synonym CDB_SQLJ_TYPE_METHODS for SYS.CDB_SQLJ_TYPE_METHODS
/

-- Gives all object tables and columns in 8.0 image format.

create or replace view DBA_OLDIMAGE_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME)
as
select u.name, o.name, 
       decode(c.name, 'SYS_NC_ROWINFO$', 'OBJECT TABLE', c.name) 
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.coltype$ t
where o.type# = 2 and    /* show only tables */
      o.owner# = u.user# and
      o.obj# = c.obj# and
      o.obj# = t.obj# and
      c.intcol# = t.intcol# and
      /* do not show attribute columns. If the attribute is in 8.0 image, that
        means the whole column is in 8.0 image. Now, this will still show
        top level ADT columns in an object table, which is redundant. */
      bitand(c.property, 1) = 0  and 
      bitand(t.flags, 128) <> 0;

comment on table  DBA_OLDIMAGE_COLUMNS is
'Gives all object tables and columns in old (8.0) image format'
/
comment on column DBA_OLDIMAGE_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_OLDIMAGE_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_OLDIMAGE_COLUMNS.COLUMN_NAME is
'Name of the top-level column'
/
create or replace public synonym DBA_OLDIMAGE_COLUMNS for 
DBA_OLDIMAGE_COLUMNS
/
grant select on DBA_OLDIMAGE_COLUMNS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_OLDIMAGE_COLUMNS','CDB_OLDIMAGE_COLUMNS');
grant select on SYS.CDB_OLDIMAGE_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_OLDIMAGE_COLUMNS for SYS.CDB_OLDIMAGE_COLUMNS
/

-- user version

create or replace view USER_OLDIMAGE_COLUMNS
    (OWNER, TABLE_NAME, COLUMN_NAME)
as
select u.name, o.name, 
       decode(c.name, 'SYS_NC_ROWINFO$', 'OBJECT TABLE', c.name) 
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.coltype$ t
where o.type# = 2 and    /* show only tables */
      o.owner# = userenv('SCHEMAID') and 
      o.owner# = u.user# and
      o.obj# = c.obj# and
      o.obj# = t.obj# and
      c.intcol# = t.intcol# and
      /* do not show attribute columns. If the attribute is in 8.0 image, that
        means the whole column is in 8.0 image. Now, this will still show
        top level ADT columns in an object table, which is redundant. */
      bitand(c.property, 1) = 0  and 
      bitand(t.flags, 128) <> 0;

comment on table  USER_OLDIMAGE_COLUMNS is
'Gives all object tables and columns in old (8.0) image format'
/
comment on column USER_OLDIMAGE_COLUMNS.OWNER is
'Owner of the table'
/
comment on column USER_OLDIMAGE_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column USER_OLDIMAGE_COLUMNS.COLUMN_NAME is
'Name of the top-level column'
/
create or replace public synonym USER_OLDIMAGE_COLUMNS for 
USER_OLDIMAGE_COLUMNS
/
grant read on USER_OLDIMAGE_COLUMNS to public with grant option
/


@?/rdbms/admin/sqlsessend.sql
