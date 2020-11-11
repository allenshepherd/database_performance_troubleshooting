Rem
Rem $Header: rdbms/admin/cdexttab.sql /main/10 2017/02/08 14:26:26 xihua Exp $
Rem
Rem cdexttab.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdexttab.sql - Catalog DEXTTAB.bsq views
Rem 
Rem      Previously known as catxpart
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for external organized tables 
Rem      This script contains catalog views for objects in dexttab.bsq.
Rem
Rem    NOTES
Rem      Must be run while connectd as SYS or INTERNAL.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdexttab.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdexttab.sql
Rem SQL_PHASE: CDEXTTAB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rmacnico    11/04/16 - Proj 60643: inmemory external tables
Rem    cochang     10/19/15 - 21093653: use bitand to decode property
Rem    sdoraisw    06/22/15 - 21069544:check subname in *EXTERNAL_TABLES
Rem    sdoraisw    02/13/15 - proj47082:add views for partitioned tables
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cdilling    05/09/06 - 
Rem    psuvarna    12/27/05 - #4715104: CASE construct for ACCESS_PARAMETERS
Rem    hsbedi      07/22/02 - external table property flag
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    abrumm      02/21/01 - add [USER,ALL]_EXTERNAL_[TABLES,LOCATIONS]
Rem    abrumm      02/16/01 - store access parms as LOB in dictionary
Rem    abrumm      10/12/00 - dba_external_locations: get default directory
Rem    abrumm      10/10/00 - add decode for reject_limit
Rem    evoss       06/21/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem FAMILY "EXTERNAL_TABLES"
Rem (USER_, ALL_, DBA_)
Rem

create or replace view USER_EXTERNAL_TABLES
  (TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY,
   INMEMORY,
   INMEMORY_COMPRESSION)
as
select o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN'),
       case when bitand(xt.property,16)=16 then 'ENABLED' else 'DISABLED' end,
       decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
from sys.external_tab$ xt, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.subname IS NULL
  and o.obj# = xt.obj#
/
comment on table USER_EXTERNAL_TABLES is
'Description of the user''s own external tables'
/
comment on column USER_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column USER_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column USER_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column USER_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column USER_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column USER_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column USER_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column USER_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column USER_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
comment on column USER_EXTERNAL_TABLES.INMEMORY is
'Whether inmemory is enabled on the external table'
/
comment on column USER_EXTERNAL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
create or replace public synonym USER_EXTERNAL_TABLES for USER_EXTERNAL_TABLES
/
grant read on USER_EXTERNAL_TABLES to PUBLIC with grant option
/


create or replace view ALL_EXTERNAL_TABLES
  (OWNER,
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY,
   INMEMORY,
   INMEMORY_COMPRESSION)
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN'),
       case when bitand(xt.property,16)=16 then 'ENABLED' else 'DISABLED' end,
       decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
from sys.external_tab$ xt, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.subname IS NULL
  and o.obj#   = xt.obj#
  and ( o.owner# = userenv('SCHEMAID')
        or o.obj# in
            ( select oa.obj# from sys.objauth$ oa
              where grantee# in (select kzsrorol from x$kzsro)
            )
        or    /* user has system privileges */
          exists ( select null from v$enabledprivs
                   where priv_number in (-45 /* LOCK ANY TABLE */,
                                         -47 /* SELECT ANY TABLE */,
                                         -397/* READ ANY TABLE */)
                 )
      )
/
comment on table ALL_EXTERNAL_TABLES is
'Description of the external tables accessible to the user'
/
comment on column ALL_EXTERNAL_TABLES.OWNER is
'Owner of the external table'
/
comment on column ALL_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column ALL_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column ALL_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column ALL_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column ALL_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column ALL_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column ALL_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column ALL_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column ALL_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
comment on column ALL_EXTERNAL_TABLES.INMEMORY is
'Whether inmemory is enabled on the external table'
/
comment on column ALL_EXTERNAL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
create or replace public synonym ALL_EXTERNAL_TABLES for ALL_EXTERNAL_TABLES
/
grant read on ALL_EXTERNAL_TABLES to PUBLIC with grant option
/
                                      

create or replace view DBA_EXTERNAL_TABLES
  (OWNER,
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY,
   INMEMORY,
   INMEMORY_COMPRESSION)
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN'),
       case when bitand(xt.property,16)=16 then 'ENABLED' else 'DISABLED' end,
       decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
from sys.external_tab$ xt, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.subname IS NULL
  and o.obj# = xt.obj#
/       
comment on table DBA_EXTERNAL_TABLES is
'Description of the external tables accessible to the DBA'
/
comment on column DBA_EXTERNAL_TABLES.OWNER is
'Owner of the external table'
/
comment on column DBA_EXTERNAL_TABLES.TABLE_NAME is
'Name of the external table'
/
comment on column DBA_EXTERNAL_TABLES.TYPE_OWNER is
'Owner of the implementation type for the external table access driver'
/
comment on column DBA_EXTERNAL_TABLES.TYPE_NAME is
'Name of the implementation type for the external table access driver'
/
comment on column DBA_EXTERNAL_TABLES.DEFAULT_DIRECTORY_OWNER is
'Owner of the default directory for the external table'
/
comment on column DBA_EXTERNAL_TABLES.DEFAULT_DIRECTORY_NAME is
'Name of the default directory for the external table'
/
comment on column DBA_EXTERNAL_TABLES.REJECT_LIMIT is
'Reject limit for the external table'
/
comment on column DBA_EXTERNAL_TABLES.ACCESS_TYPE is
'Type of access parameters for the external table (CLOB/BLOB)'
/
comment on column DBA_EXTERNAL_TABLES.ACCESS_PARAMETERS is
'Access parameters for the external table'
/
comment on column DBA_EXTERNAL_TABLES.PROPERTY is
'Property of the external table'
/
comment on column DBA_EXTERNAL_TABLES.INMEMORY is
'Whether inmemory is enabled on the external table'
/
comment on column DBA_EXTERNAL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
create or replace public synonym DBA_EXTERNAL_TABLES for DBA_EXTERNAL_TABLES
/
grant select on DBA_EXTERNAL_TABLES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_EXTERNAL_TABLES','CDB_EXTERNAL_TABLES');
grant select on SYS.CDB_EXTERNAL_TABLES to select_catalog_role
/
create or replace public synonym CDB_EXTERNAL_TABLES for SYS.CDB_EXTERNAL_TABLES
/

Rem  FAMILY XTERNAL_PART_TABLES
Rem   The XTERNAL_PART_TABLES family of views describes the object level 
Rem   parameters in external_tab$ for partitioned external tables.
create or replace view USER_XTERNAL_PART_TABLES
  (TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY)
as
select o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o, sys.partobj$ po
where o.obj# = po.obj# and
      o.obj# = xt.obj# and
      o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_XTERNAL_PART_TABLES for USER_XTERNAL_PART_TABLES
/
grant read on USER_XTERNAL_PART_TABLES to PUBLIC with grant option
/
create or replace view ALL_XTERNAL_PART_TABLES
  (OWNER,
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY
   )
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o, sys.partobj$ po, sys.user$ u
where o.obj# = po.obj# and
      o.obj#   = xt.obj# and
      o.owner# = u.user# and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
     ( o.owner# = userenv('SCHEMAID')
        or o.obj# in
            ( select oa.obj# from sys.objauth$ oa
              where grantee# in (select kzsrorol from x$kzsro)
            )
        or    /* user has system privileges */
          exists ( select null from v$enabledprivs
                   where priv_number in (-45 /* LOCK ANY TABLE */,
                                         -47 /* SELECT ANY TABLE */,
                                         -397/* READ ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_XTERNAL_PART_TABLES for ALL_XTERNAL_PART_TABLES
/
grant read on ALL_XTERNAL_PART_TABLES to PUBLIC with grant option
/
create or replace view DBA_XTERNAL_PART_TABLES
  (OWNER, 
   TABLE_NAME,
   TYPE_OWNER,
   TYPE_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   REJECT_LIMIT,
   ACCESS_TYPE,
   ACCESS_PARAMETERS,
   PROPERTY
   )
as
select u.name, o.name, 'SYS', xt.type$, 'SYS', xt.default_dir,
       decode(xt.reject_limit, 2147483647, 'UNLIMITED', xt.reject_limit),
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end,
       decode(bitand(xt.property, 3), 2, 'REFERENCED', 1, 'ALL',     'UNKNOWN')
from sys.external_tab$ xt, sys.obj$ o, sys.partobj$ po, sys.user$ u
where  o.obj# = po.obj# and
       o.obj# = xt.obj# and
       o.owner# = u.user# and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_XTERNAL_PART_TABLES for DBA_XTERNAL_PART_TABLES
/
grant select on DBA_XTERNAL_PART_TABLES to select_catalog_role
/
execute CDBView.create_cdbview(false,'SYS', 'DBA_XTERNAL_PART_TABLES','CDB_XTERNAL_PART_TABLES');
grant select on SYS.CDB_XTERNAL_PART_TABLES to select_catalog_role
/
create or replace public synonym CDB_XTERNAL_PART_TABLES 
  for SYS.CDB_XTERNAL_PART_TABLES
/

Rem FAMILY "XTERNAL_TAB_PARTITIONS"
Rem   The XTERNAL_TAB_PARTITIONS family of views will describe, for each
Rem   external table partition, the partition level parameters in external_tab$
create or replace view USER_XTERNAL_TAB_PARTITIONS
  (TABLE_NAME,
   PARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
  )
as
select o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from sys.external_tab$ xt, sys.obj$ o, sys.tabpart$ tp, sys.tab$ t
where o.obj# = xt.obj# and
      o.obj# = tp.obj# and
      tp.bo# = t.obj# and
      o.owner# = userenv('SCHEMAID') and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, sys.obj$ o, sys.tabcompart$ tcp, sys.tab$ t
where  o.obj# = xt.obj# and
       o.obj# = tcp.obj# and
       tcp.bo# = t.obj# and
       o.owner# = userenv('SCHEMAID') and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_XTERNAL_TAB_PARTITIONS 
  for USER_XTERNAL_TAB_PARTITIONS
/
grant read on USER_XTERNAL_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_XTERNAL_TAB_PARTITIONS
  (TABLE_OWNER,
   TABLE_NAME,
   PARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
  )
as
select u.name, o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, sys.obj$ o, sys.tabpart$ tp, sys.user$ u, 
       sys.tab$ t
where  o.obj# = xt.obj# and
       o.obj# = tp.obj# and
       u.user# = o.owner# and
       tp.bo# = t.obj# and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
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
                                       -397/* READ ANY TABLE */)
                 )
      )
union all -- COMPOSITE PARTITIONS
select u.name, o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, sys.obj$ o, sys.tabcompart$ tcp, sys.user$ u,
       sys.tab$ t
where  o.obj# = xt.obj# and
       o.obj# = tcp.obj# and
       u.user# = o.owner# and
       tcp.bo# = t.obj# and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
        or tcp.bo# in
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
                                       -397/* READ ANY TABLE */)
                )
      )
/
create or replace public synonym ALL_XTERNAL_TAB_PARTITIONS 
  for ALL_XTERNAL_TAB_PARTITIONS
/
grant read on ALL_XTERNAL_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_XTERNAL_TAB_PARTITIONS
  (TABLE_OWNER,
   TABLE_NAME,
   PARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
  )
as
select u.name, o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from sys.external_tab$ xt, sys.obj$ o, sys.tabpart$ tp, sys.user$ u,  
      sys.tab$ t
where o.obj# = xt.obj# and
      o.obj# = tp.obj# and
      o.owner# = u.user# and
      tp.bo# = t.obj# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select u.name, o.name, o.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, sys.obj$ o, sys.tabcompart$ tcp, sys.user$ u,
       sys.tab$ t
where  o.obj# = xt.obj# and
       o.obj# = tcp.obj# and
       o.owner# = u.user# and
       tcp.bo# = t.obj# and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_XTERNAL_TAB_PARTITIONS 
  for DBA_XTERNAL_TAB_PARTITIONS
/
grant select on DBA_XTERNAL_TAB_PARTITIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_XTERNAL_TAB_PARTITIONS', 'CDB_XTERNAL_TAB_PARTITIONS');
grant select on SYS.CDB_XTERNAL_TAB_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_XTERNAL_TAB_PARTITIONS
  for SYS.CDB_XTERNAL_TAB_PARTITIONS
/

Rem FAMILY "XTERNAL_TAB_SUBPARTITIONS"
Rem   The XTERNAL_TAB_SUBPARTITIONS family of views describes, for each table
Rem   subpartition, the (subpartition level) external parameters stored in
Rem   external_tab$.
create or replace view USER_XTERNAL_TAB_SUBPARTITIONS
  (TABLE_NAME,
   PARTITION_NAME,
   SUBPARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
   )
as
select po.name, po.subname, so.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, sys.obj$ so, sys.obj$ po, sys.tabcompart$ tcp,
       sys.tabsubpart$ tsp, sys.tab$ t
where so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tsp.pobj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      po.owner# = userenv('SCHEMAID') and
      so.owner# = userenv('SCHEMAID') and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and
      so.remoteowner IS NULL and
      so.linkname IS NULL
/
create or replace public synonym USER_XTERNAL_TAB_SUBPARTITIONS
   for USER_XTERNAL_TAB_SUBPARTITIONS
/
grant read on USER_XTERNAL_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_XTERNAL_TAB_SUBPARTITIONS
  (TABLE_OWNER,
   TABLE_NAME,
   PARTITION_NAME,
   SUBPARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
   )
as
select u.name, po.name, po.subname, so.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from   sys.external_tab$ xt, obj$ po, obj$ so, tabcompart$ tcp, tabsubpart$ tsp,
       tab$ t, user$ u
where so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tcp.obj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      u.user# = po.owner# and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL and
      ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or tcp.bo# in
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
                                       -397/* READ ANY TABLE */)
                )
      )
/
create or replace public synonym ALL_XTERNAL_TAB_SUBPARTITIONS
   for ALL_XTERNAL_TAB_SUBPARTITIONS
/
grant read on ALL_XTERNAL_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_XTERNAL_TAB_SUBPARTITIONS
  (TABLE_OWNER,
   TABLE_NAME,
   PARTITION_NAME,
   SUBPARTITION_NAME,
   DEFAULT_DIRECTORY_OWNER,
   DEFAULT_DIRECTORY_NAME,
   ACCESS_TYPE,
   ACCESS_PARAMETERS
   )
as
select u.name, po.name, po.subname, so.subname, 'SYS', xt.default_dir,
       decode(xt.par_type, 1, 'BLOB', 2, 'CLOB',       'UNKNOWN'),
       case when xt.par_type = 2 then xt.param_clob else NULL end
from sys.external_tab$ xt, sys.obj$ so, sys.obj$ po, tabcompart$ tcp,
     sys.tabsubpart$ tsp, sys.tab$ t, sys.user$ u
where so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tsp.pobj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      u.user# = po.owner# and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and
      so.remoteowner IS NULL and
      so.linkname IS NULL
/
create or replace public synonym DBA_XTERNAL_TAB_SUBPARTITIONS
   for DBA_XTERNAL_TAB_SUBPARTITIONS
/
grant select on DBA_XTERNAL_TAB_SUBPARTITIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XTERNAL_TAB_SUBPARTITIONS', 'CDB_XTERNAL_TAB_SUBPARTITIONS');
grant select on SYS.CDB_XTERNAL_TAB_SUBPARTITIONS to select_catalog_role
/
create or replace public synonym CDB_XTERNAL_TAB_SUBPARTITIONS 
  for SYS.CDB_XTERNAL_TAB_SUBPARTITIONS
/


Rem
Rem FAMILY "EXTERNAL_LOCATIONS"
Rem (USER_, ALL_, DBA_)
Rem

create or replace view USER_EXTERNAL_LOCATIONS
        (TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.obj$ o, sys.external_tab$ xt
where o.owner# = userenv('SCHEMAID')
  and o.subname IS NULL
  and o.obj# = xl.obj#
  and o.obj# = xt.obj#
/       
comment on table USER_EXTERNAL_LOCATIONS is
'Description of the user''s external tables locations'
/
comment on column USER_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column USER_EXTERNAL_LOCATIONS.LOCATION is
'External table location clause'
/
comment on column USER_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column USER_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym USER_EXTERNAL_LOCATIONS
   for USER_EXTERNAL_LOCATIONS
/
grant read on USER_EXTERNAL_LOCATIONS to PUBLIC with grant option
/


create or replace view ALL_EXTERNAL_LOCATIONS
        (OWNER,
         TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.user$ u, sys.obj$ o, sys.external_tab$ xt
where o.owner# = u.user#
  and o.subname IS NULL
  and o.obj#   = xl.obj#
  and o.obj#   = xt.obj#
  and ( o.owner# = userenv('SCHEMAID')
        or o.obj# in
        ( select oa.obj# from sys.objauth$ oa
          where grantee# in (select kzsrorol from x$kzsro)
        )
        or    /* user has system privileges */
          exists ( select null from v$enabledprivs
                   where priv_number in (-45 /* LOCK ANY TABLE */,
                                         -47 /* SELECT ANY TABLE */,
                                         -397/* READ ANY TABLE */)
                 )
      )
/
comment on table ALL_EXTERNAL_LOCATIONS is
'Description of the external tables locations accessible to the user'
/
comment on column ALL_EXTERNAL_LOCATIONS.OWNER is
'Owner of the external table location'
/
comment on column ALL_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column ALL_EXTERNAL_LOCATIONS.LOCATION is
'External table location clause'
/
comment on column ALL_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column ALL_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym ALL_EXTERNAL_LOCATIONS
   for ALL_EXTERNAL_LOCATIONS
/
grant read on ALL_EXTERNAL_LOCATIONS to PUBLIC with grant option
/


create or replace view DBA_EXTERNAL_LOCATIONS
        (OWNER,
         TABLE_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.user$ u, sys.obj$ o, sys.external_tab$ xt
where o.owner# = u.user#
  and o.subname IS NULL
  and o.obj# = xl.obj#
  and o.obj# = xt.obj#
/       
comment on table DBA_EXTERNAL_LOCATIONS is
'Description of the external tables locations accessible to the DBA'
/
comment on column DBA_EXTERNAL_LOCATIONS.OWNER is
'Owner of the external table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.TABLE_NAME is
'Name of the corresponding external table'
/
comment on column DBA_EXTERNAL_LOCATIONS.LOCATION is
'External table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.DIRECTORY_OWNER is
'Owner of the directory containing the external table location'
/
comment on column DBA_EXTERNAL_LOCATIONS.DIRECTORY_NAME is
'Name of the directory containing the location'
/
create or replace public synonym DBA_EXTERNAL_LOCATIONS
   for DBA_EXTERNAL_LOCATIONS
/
grant select on DBA_EXTERNAL_LOCATIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_EXTERNAL_LOCATIONS','CDB_EXTERNAL_LOCATIONS');
grant select on SYS.CDB_EXTERNAL_LOCATIONS to select_catalog_role
/
create or replace public synonym CDB_EXTERNAL_LOCATIONS for SYS.CDB_EXTERNAL_LOCATIONS
/


Rem FAMILY "XTERNAL_LOC_PARTITIONS"
Rem The XTERNAL_LOC_PARTITIONS family of views will describe, for each
Rem external table partition, the (partition level) location list in
Rem external_location$
create or replace view USER_XTERNAL_LOC_PARTITIONS
        (TABLE_NAME,
         PARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o,
     sys.tabpart$ tp, sys.tab$ t
where o.obj# = xl.obj# and
      o.obj# = xt.obj# and
      o.obj# = tp.obj# and
      tp.bo# = t.obj# and
      o.owner# = userenv('SCHEMAID') and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from   sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o,
       sys.tabcompart$ tcp, sys.tab$ t
where  o.obj# = xl.obj# and
       o.obj# = xt.obj# and
       o.obj# = tcp.obj# and
       tcp.bo# = t.obj# and
       o.owner# = userenv('SCHEMAID') and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_XTERNAL_LOC_PARTITIONS for
   USER_XTERNAL_LOC_PARTITIONS
/
grant read on USER_XTERNAL_LOC_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_XTERNAL_LOC_PARTITIONS
        (OWNER,
         TABLE_NAME,
         PARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o, sys.tabpart$ tp,
     sys.user$ u, sys.tab$ t
where o.obj# = xl.obj# and
      o.obj# = xt.obj# and
      o.obj# = tp.obj# and
      u.user# = o.owner# and
      tp.bo# = t.obj# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or tp.bo# in
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
                                      -397/* READ ANY TABLE */)
               )
      )
union all -- COMPOSITE PARTITIONS
select u.name, o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from   sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o, sys.tabcompart$ tcp,
       sys.user$ u, sys.tab$ t
where o.obj# = xl.obj# and
      o.obj# = xt.obj# and
      o.obj# = tcp.obj# and
      u.user# = o.owner# and
      tcp.bo# = t.obj# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
       or tcp.bo# in
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
                                      -397/* READ ANY TABLE */)
               )
     )
/
create or replace public synonym  ALL_XTERNAL_LOC_PARTITIONS
   for  ALL_XTERNAL_LOC_PARTITIONS
/
grant read on ALL_XTERNAL_LOC_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_XTERNAL_LOC_PARTITIONS
        (OWNER,
         TABLE_NAME,
         PARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o, sys.tabpart$ tp,
     sys.user$ u,  sys.tab$ t
where o.obj# = xl.obj# and
      o.obj# = xt.obj# and
      o.obj# = tp.obj# and
      o.owner# = u.user# and
      tp.bo# = t.obj# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select u.name, o.name, o.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ o, sys.tabcompart$ tcp,
     sys.user$ u, sys.tab$ t
where o.obj# = xl.obj# and
      o.obj# = xt.obj# and
      o.obj# = tcp.obj# and
      o.owner# = u.user# and
      tcp.bo# = t.obj# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_XTERNAL_LOC_PARTITIONS
   for DBA_XTERNAL_LOC_PARTITIONS
/
grant select on DBA_XTERNAL_LOC_PARTITIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_XTERNAL_LOC_PARTITIONS', 'CDB_XTERNAL_LOC_PARTITIONS');
grant select on SYS.CDB_XTERNAL_LOC_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_XTERNAL_LOC_PARTITIONS 
  for SYS.CDB_XTERNAL_LOC_PARTITIONS 
/

Rem FAMILY "XTERNAL_LOC_SUBPARTITIONS"
Rem   The XTERNAL_LOC_SUBPARTITIONS family of views describes, for each table
Rem   subpartition, the (subpartition level) location list in external_location$
create or replace view USER_XTERNAL_LOC_SUBPARTITIONS
        (TABLE_NAME,
         PARTITION_NAME,
         SUBPARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select po.name, po.subname, so.subname, xl.name, 'SYS', nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, sys.obj$ so, sys.obj$ po,
     sys.tabcompart$ tcp, sys.tabsubpart$ tsp, sys.tab$ t
where so.obj# = xl.obj# and
      so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tsp.pobj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      po.owner# = userenv('SCHEMAID') and
      so.owner# = userenv('SCHEMAID') and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and
      so.remoteowner IS NULL and
      so.linkname IS NULL
/
create or replace public synonym USER_XTERNAL_LOC_SUBPARTITIONS for
   USER_XTERNAL_LOC_SUBPARTITIONS
/
grant read on USER_XTERNAL_LOC_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_XTERNAL_LOC_SUBPARTITIONS
        (TABLE_OWNER,
         TABLE_NAME,
         PARTITION_NAME,
         SUBPARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, po.name, po.subname, so.subname, xl.name, 'SYS', 
       nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl, sys.external_tab$ xt, obj$ po, obj$ so,
     tabcompart$ tcp, tabsubpart$ tsp, tab$ t, user$ u
where so.obj# = xl.obj# and
      so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tcp.obj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      u.user# = po.owner# and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and 
      so.remoteowner IS NULL and 
      so.linkname IS NULL and
      ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or tcp.bo# in
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
                                       -397/* READ ANY TABLE */)
                )
      )
/
create or replace public synonym ALL_XTERNAL_LOC_SUBPARTITIONS
   for ALL_XTERNAL_LOC_SUBPARTITIONS
/
grant read on ALL_XTERNAL_LOC_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_XTERNAL_LOC_SUBPARTITIONS
        (TABLE_OWNER,
         TABLE_NAME,
         PARTITION_NAME,
         SUBPARTITION_NAME,
         LOCATION,
         DIRECTORY_OWNER,
         DIRECTORY_NAME
        )
as
select u.name, po.name, po.subname, so.subname, xl.name, 'SYS',
       nvl(xl.dir, xt.default_dir)
from sys.external_location$ xl,
     sys.external_tab$ xt,
     sys.obj$ so,
     sys.obj$ po,
     tabcompart$ tcp,
     sys.tabsubpart$ tsp,
     sys.tab$ t,
     sys.user$ u
where so.obj# = xl.obj# and
      so.obj# = xt.obj# and
      so.obj# = tsp.obj# and
      po.obj# = tsp.pobj# and
      tcp.obj# = tsp.pobj# and
      tcp.bo# = t.obj# and
      u.user# = po.owner# and
      po.namespace = 1 and
      po.remoteowner IS NULL and
      po.linkname IS NULL and
      so.namespace = 1 and
      so.remoteowner IS NULL and
      so.linkname IS NULL
/
create or replace public synonym DBA_XTERNAL_LOC_SUBPARTITIONS
   for DBA_XTERNAL_LOC_SUBPARTITIONS
/
grant select on DBA_XTERNAL_LOC_SUBPARTITIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XTERNAL_LOC_SUBPARTITIONS', 'CDB_XTERNAL_LOC_SUBPARTITIONS');
grant select on SYS.CDB_XTERNAL_LOC_SUBPARTITIONS to select_catalog_role
/
create or replace public synonym CDB_XTERNAL_LOC_SUBPARTITIONS 
  for SYS.CDB_XTERNAL_LOC_SUBPARTITIONS
/

@?/rdbms/admin/sqlsessend.sql
