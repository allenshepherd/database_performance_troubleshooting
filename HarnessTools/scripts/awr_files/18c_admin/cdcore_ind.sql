Rem
Rem $Header: rdbms/admin/cdcore_ind.sql /main/2 2017/06/26 16:01:20 pjulsaks Exp $
Rem
Rem cdcore_ind.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_ind.sql - Catalog DCORE.bsq INDex views
Rem
Rem    DESCRIPTION
Rem      This script creates views for dcore.bsq index objects
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_ind.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_ind.sql
Rem    SQL_PHASE: CDCORE_IND
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    raeburns    04/28/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    04/28/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "INDEXES"
remark  CREATE INDEX parameters.
remark
create or replace view USER_INDEXES
    (INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED, ORPHANED_ENTRIES,
     INDEXING)
as
select o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 1073741824), 1073741824, 'ADVANCED HIGH',
              decode(bitand(i.flags, 32), 0, 'DISABLED', 
                     decode(bitand(i.flags, 2147483648), 0, 'ENABLED', 
                            2147483648, 'ADVANCED LOW'))),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       to_number(decode(bitand(i.property, 2),2, null, i.initrans)),
       to_number(decode(bitand(i.property, 2),2, null, i.maxtrans)),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                    decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES')),
       decode(bitand(i.flags, 268435456), 268435456, 'YES', 'NO'),
       decode(bitand(i.flags, 8388608), 8388608, 'PARTIAL', 'FULL')
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 8, 9)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
  and (io.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where i.bo# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
/
comment on table USER_INDEXES is
'Description of the user''s own indexes'
/
comment on column USER_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column USER_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column USER_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column USER_INDEXES.UNIQUENESS is
'Uniqueness status of the index:  "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column USER_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column USER_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column USER_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column USER_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_INDEXES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_INDEXES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column USER_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column USER_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column USER_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_INDEXES.LOGGING is
'Logging attribute'
/
comment on column USER_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column USER_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_INDEXES.NUM_ROWS is
'Number of rows in the index'
/
comment on column USER_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column USER_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column USER_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column USER_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column USER_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column USER_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column USER_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column USER_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column USER_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column USER_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column USER_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column USER_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column USER_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column USER_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column USER_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column USER_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column USER_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column USER_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column USER_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column USER_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column USER_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/
create or replace public synonym USER_INDEXES for USER_INDEXES
/
create or replace public synonym IND for USER_INDEXES
/
grant read on USER_INDEXES to PUBLIC with grant option
/
remark
remark  This view does not include cluster indexes on clusters
remark  containing tables which are accessible to the user.
remark
create or replace view ALL_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS,  FREELIST_GROUPS, PCT_FREE, LOGGING,
     BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED, ORPHANED_ENTRIES,
     INDEXING)
 as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name, 'TABLE',
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 1073741824), 1073741824, 'ADVANCED HIGH',
              decode(bitand(i.flags, 32), 0, 'DISABLED', 
                     decode(bitand(i.flags, 2147483648), 0, 'ENABLED', 
                            2147483648, 'ADVANCED LOW'))),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INRPOGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',            
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),             
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES')),
       decode(bitand(i.flags, 268435456), 268435456, 'YES', 'NO'),
       decode(bitand(i.flags, 8388608), 8388608, 'PARTIAL', 'FULL')
from sys.ts$ ts, sys.seg$ s, sys.user$ iu, sys.obj$ io,
     sys.user$ u, sys.ind$ i, sys.obj$ o, sys.user$ itu, sys.obj$ ito,
     sys.deferred_stg$ ds
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and io.type# = 2 /* tables */
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (io.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where i.bo# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
  and (io.owner# = userenv('SCHEMAID')
        or
       io.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
          /* user has system privileges */
        ora_check_sys_privilege ( io.owner#, io.type#) = 1
      )
/
comment on table ALL_INDEXES is
'Descriptions of indexes on tables accessible to the user'
/
comment on column ALL_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column ALL_INDEXES.STATUS is
'Whether the non-partitioned index is in USABLE or not'
/
comment on column ALL_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column ALL_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column ALL_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column ALL_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column ALL_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column ALL_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column ALL_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column ALL_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column ALL_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column ALL_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-organized table top index'
/
comment on column ALL_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column ALL_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_INDEXES.LOGGING is
'Logging attribute'
/
comment on column ALL_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column ALL_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column ALL_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column ALL_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column ALL_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column ALL_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column ALL_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column ALL_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column ALL_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column ALL_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column ALL_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column ALL_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column ALL_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column ALL_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column ALL_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column ALL_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column ALL_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column ALL_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column ALL_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column ALL_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column ALL_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column ALL_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/
create or replace public synonym ALL_INDEXES for ALL_INDEXES
/
grant read on ALL_INDEXES to PUBLIC with grant option
/
create or replace view DBA_INDEXES
    (OWNER, INDEX_NAME,
     INDEX_TYPE,
     TABLE_OWNER, TABLE_NAME,
     TABLE_TYPE,
     UNIQUENESS,
     COMPRESSION, PREFIX_LENGTH,
     TABLESPACE_NAME, INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, PCT_THRESHOLD, INCLUDE_COLUMN,
     FREELISTS, FREELIST_GROUPS, PCT_FREE, LOGGING, BLEVEL,
     LEAF_BLOCKS, DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY,
     AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, STATUS,
     NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, DEGREE, INSTANCES, PARTITIONED,
     TEMPORARY, GENERATED, SECONDARY, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, USER_STATS, DURATION, PCT_DIRECT_ACCESS,
     ITYP_OWNER, ITYP_NAME, PARAMETERS, GLOBAL_STATS, DOMIDX_STATUS,
     DOMIDX_OPSTATUS, FUNCIDX_STATUS, JOIN_INDEX, IOT_REDUNDANT_PKEY_ELIM,
     DROPPED,VISIBILITY, DOMIDX_MANAGEMENT, SEGMENT_CREATED, ORPHANED_ENTRIES,
     INDEXING)
as
select u.name, o.name,
       decode(bitand(i.property, 16), 0, '', 'FUNCTION-BASED ') ||
        decode(i.type#, 1, 'NORMAL'||
                          decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN'),
       iu.name, io.name,
       decode(io.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                       4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 'UNDEFINED'),
       decode(bitand(i.property, 1), 0, 'NONUNIQUE', 1, 'UNIQUE', 'UNDEFINED'),
       decode(bitand(i.flags, 1073741824), 1073741824, 'ADVANCED HIGH',
              decode(bitand(i.flags, 32), 0, 'DISABLED', 
                     decode(bitand(i.flags, 2147483648), 0, 'ENABLED', 
                            2147483648, 'ADVANCED LOW'))),
       i.spare2,
       decode(bitand(i.property, 34), 0, decode(i.type#, 9, null, ts.name), 
           2, null, decode(i.ts#, 0, null, ts.name)),
       decode(bitand(i.property, 2),0, i.initrans, null),
       decode(bitand(i.property, 2),0, i.maxtrans, null),
       decode(bitand(i.flags, 67108864), 67108864, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(i.flags, 67108864), 67108864, 
              ds.minext_stg, s.minexts), 
       decode(bitand(i.flags, 67108864), 67108864,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(i.flags, 67108864), 67108864, 
                            ds.pctinc_stg, s.extpct)),
       decode(i.type#, 4, mod(i.pctthres$,256), NULL), i.trunccnt,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
       decode(bitand(o.flags, 2), 2, 1, 
              decode(bitand(i.flags, 67108864), 67108864, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(o.flags, 2), 2, 1, 
                     decode(bitand(i.flags, 67108864), 67108864,
                            decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                            decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(i.property, 2),0,i.pctfree$,null),
       decode(bitand(i.property, 2), 2, NULL,
                decode(bitand(i.flags, 4), 0, 'YES', 'NO')),
       i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
       decode(bitand(i.property, 2), 2,
                   decode(i.type#, 9, decode(bitand(i.flags, 8),
                                        8, 'INPROGRS', 'VALID'), 'N/A'),
                     decode(bitand(i.flags, 1), 1, 'UNUSABLE',
                            decode(bitand(i.flags, 8), 8, 'INPROGRS',
                                                            'VALID'))),
       rowcnt, samplesize, analyzetime,
       decode(i.degree, 32767, 'DEFAULT', nvl(i.degree,1)),
       decode(i.instances, 32767, 'DEFAULT', nvl(i.instances,1)),
       decode(bitand(i.property, 2), 2, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 4), 0, 'N', 4, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(i.flags, 67108864), 67108864, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                
       decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(i.property, 64), 64, 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
              decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
       itu.name, ito.name, i.spare4,
       decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
       decode(i.type#, 9, decode(o.status, 5, 'IDXTYP_INVLD',
                                           1, 'VALID'),  ''),
       decode(i.type#, 9, decode(bitand(i.flags, 16), 16, 'FAILED', 'VALID'), ''),
       decode(bitand(i.property, 16), 0, '',
              decode(bitand(i.flags, 1024), 0, 'ENABLED', 'DISABLED')),
       decode(bitand(i.property, 1024), 1024, 'YES', 'NO'),
       decode(bitand(i.property, 16384), 16384, 'YES', 'NO'),
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(i.flags,2097152),2097152,'INVISIBLE','VISIBLE'),
       decode(i.type#, 9, decode(bitand(i.property, 2048), 2048,
                               'SYSTEM_MANAGED', 'USER_MANAGED'), ''),
       decode(bitand(i.flags, 67108864), 67108864, 'NO',
              decode(bitand(i.property, 2), 2, 'N/A', 'YES')),
       decode(bitand(i.flags, 268435456), 268435456, 'YES', 'NO'),
       decode(bitand(i.flags, 8388608), 8388608, 'PARTIAL', 'FULL')
from sys.ts$ ts, sys.seg$ s,
     sys.user$ iu, sys.obj$ io, sys.user$ u, sys.ind$ i, sys.obj$ o,
     sys.user$ itu, sys.obj$ ito, sys.deferred_stg$ ds
where u.user# = o.owner#
  and o.obj# = i.obj#
  and i.bo# = io.obj#
  and io.owner# = iu.user#
  and bitand(i.flags, 4096) = 0
  and bitand(o.flags, 128) = 0
  and i.ts# = ts.ts# (+)
  and i.file# = s.file# (+)
  and i.block# = s.block# (+)
  and i.ts# = s.ts# (+)
  and i.obj# = ds.obj# (+)
  and i.indmethod# = ito.obj# (+)
  and ito.owner# = itu.user# (+)
  and (io.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where io.obj# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
/
create or replace public synonym DBA_INDEXES for DBA_INDEXES
/
grant select on DBA_INDEXES to select_catalog_role
/
comment on table DBA_INDEXES is
'Description for all indexes in the database'
/
comment on column DBA_INDEXES.STATUS is
'Whether non-partitioned index is in UNUSABLE state or not'
/
comment on column DBA_INDEXES.OWNER is
'Username of the owner of the index'
/
comment on column DBA_INDEXES.INDEX_NAME is
'Name of the index'
/
comment on column DBA_INDEXES.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_INDEXES.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_INDEXES.TABLE_TYPE is
'Type of the indexed object'
/
comment on column DBA_INDEXES.UNIQUENESS is
'Uniqueness status of the index: "UNIQUE",  "NONUNIQUE", or "BITMAP"'
/
comment on column DBA_INDEXES.COMPRESSION is
'Compression property of the index: "ENABLED",  "DISABLED", or NULL'
/
comment on column DBA_INDEXES.PREFIX_LENGTH is
'Number of key columns in the prefix used for compression'
/
comment on column DBA_INDEXES.TABLESPACE_NAME is
'Name of the tablespace containing the index'
/
comment on column DBA_INDEXES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_INDEXES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_INDEXES.INITIAL_EXTENT is
'Size of the initial extent'
/
comment on column DBA_INDEXES.NEXT_EXTENT is
'Size of secondary extents'
/
comment on column DBA_INDEXES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_INDEXES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_INDEXES.PCT_THRESHOLD is
'Threshold percentage of block space allowed per index entry'
/
comment on column DBA_INDEXES.INCLUDE_COLUMN is
'User column-id for last column to be included in index-only table top index'
/
comment on column DBA_INDEXES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_INDEXES.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column DBA_INDEXES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_INDEXES.LOGGING is
'Logging attribute'
/
comment on column DBA_INDEXES.BLEVEL is
'B-Tree level'
/
comment on column DBA_INDEXES.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_INDEXES.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_INDEXES.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_INDEXES.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_INDEXES.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_INDEXES.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_INDEXES.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_INDEXES.DEGREE is
'The number of threads per instance for scanning the partitioned index'
/
comment on column DBA_INDEXES.INSTANCES is
'The number of instances across which the partitioned index is to be scanned'
/
comment on column DBA_INDEXES.PARTITIONED is
'Is this index partitioned? YES or NO'
/
comment on column DBA_INDEXES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_INDEXES.GENERATED is
'Was the name of this index system generated?'
/
comment on column DBA_INDEXES.SECONDARY is
'Is the index object created as part of icreate for domain indexes?'
/
comment on column DBA_INDEXES.BUFFER_POOL is
'The default buffer pool to be used for index blocks'
/
comment on column DBA_INDEXES.FLASH_CACHE is
'The default flash cache hint to be used for index blocks'
/
comment on column DBA_INDEXES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for index blocks'
/
comment on column DBA_INDEXES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_INDEXES.DURATION is
'If index on temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_INDEXES.PCT_DIRECT_ACCESS is
'If index on IOT, then this is percentage of rows with Valid guess'
/
comment on column DBA_INDEXES.ITYP_OWNER is
'If domain index, then this is the indextype owner'
/
comment on column DBA_INDEXES.ITYP_NAME is
'If domain index, then this is the name of the associated indextype'
/
comment on column DBA_INDEXES.PARAMETERS is
'If domain index, then this is the parameter string'
/
comment on column DBA_INDEXES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_INDEXES.DOMIDX_STATUS is
'Is the indextype of the domain index valid'
/
comment on column DBA_INDEXES.DOMIDX_OPSTATUS is
'Status of the operation on the domain index'
/
comment on column DBA_INDEXES.FUNCIDX_STATUS is
'Is the Function-based Index DISABLED or ENABLED?'
/
comment on column DBA_INDEXES.JOIN_INDEX is
'Is this index a join index?'
/
comment on column DBA_INDEXES.IOT_REDUNDANT_PKEY_ELIM is
'Were redundant primary key columns eliminated from iot secondary index?'
/
comment on column DBA_INDEXES.DROPPED is
'Whether index is dropped and is in Recycle Bin'
/
comment on column DBA_INDEXES.VISIBILITY is
'Whether the index is VISIBLE or INVISIBLE to the optimizer'
/
comment on column DBA_INDEXES.DOMIDX_MANAGEMENT is
'If this a domain index, then whether it is system managed or user managed'
/
comment on column DBA_INDEXES.SEGMENT_CREATED is 
'Whether the index segment has been created'
/

execute CDBView.create_cdbview(false,'SYS','DBA_INDEXES','CDB_INDEXES');
grant select on SYS.CDB_INDEXES to select_catalog_role
/
create or replace public synonym CDB_INDEXES for SYS.CDB_INDEXES
/

remark
remark  FAMILY "IND_COLUMNS"
remark  Displays information on which columns are contained in which
remark  indexes
remark
alter view user_ind_columns_v$ compile;

create or replace view USER_IND_COLUMNS
as select 
     INDEX_NAME, TABLE_NAME, COLUMN_NAME,
     COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID
from user_ind_columns_v$
/
comment on table USER_IND_COLUMNS is
'COLUMNs comprising user''s INDEXes and INDEXes on user''s TABLES'
/
comment on column USER_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column USER_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column USER_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column USER_IND_COLUMNS.DESCEND is
'DESC if this column is sorted descending on disk, otherwise ASC'
/
comment on column USER_IND_COLUMNS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/
create or replace public synonym USER_IND_COLUMNS for USER_IND_COLUMNS
/
grant read on USER_IND_COLUMNS to PUBLIC with grant option
/

alter view all_ind_columns_v$ compile;

create or replace view ALL_IND_COLUMNS
as select 
     INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID
from all_ind_columns_v$
/
comment on table ALL_IND_COLUMNS is
'COLUMNs comprising INDEXes on accessible TABLES'
/
comment on column ALL_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column ALL_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column ALL_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column ALL_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'
/
comment on column ALL_IND_COLUMNS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/
create or replace public synonym ALL_IND_COLUMNS for ALL_IND_COLUMNS
/
grant read on ALL_IND_COLUMNS to PUBLIC with grant option
/

alter view dba_ind_columns_v$ compile;

execute CDBView.create_cdbview(false,'SYS','DBA_IND_COLUMNS_V$','CDB_IND_COLUMNS_V$');

create or replace view DBA_IND_COLUMNS
as select
     INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME,
     COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH,
     CHAR_LENGTH, DESCEND, COLLATED_COLUMN_ID
from dba_ind_columns_v$
/
create or replace public synonym DBA_IND_COLUMNS for DBA_IND_COLUMNS
/
grant select on DBA_IND_COLUMNS to select_catalog_role
/
comment on table DBA_IND_COLUMNS is
'COLUMNs comprising INDEXes on all TABLEs and CLUSTERs'
/
comment on column DBA_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_COLUMNS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_COLUMNS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_COLUMNS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_IND_COLUMNS.COLUMN_POSITION is
'Position of column or attribute within index'
/
comment on column DBA_IND_COLUMNS.COLUMN_LENGTH is
'Maximum length of the column or attribute, in bytes'
/
comment on column DBA_IND_COLUMNS.CHAR_LENGTH is
'Maximum length of the column or attribute, in characters'
/
comment on column DBA_IND_COLUMNS.DESCEND is
'DESC if this column is sorted in descending order on disk, otherwise ASC'
/
comment on column DBA_IND_COLUMNS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/

execute CDBView.create_cdbview(false,'SYS','DBA_IND_COLUMNS','CDB_IND_COLUMNS');
grant select on SYS.CDB_IND_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_IND_COLUMNS for SYS.CDB_IND_COLUMNS
/

remark
remark  FAMILY "IND_EXPRESSIONS"
remark  Displays information on which functional index expressions
remark
create or replace view USER_IND_EXPRESSIONS
    (INDEX_NAME, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and ic.bo# = base.obj#
  and ic.intcol# = c.intcol#
  and base.owner# = userenv('SCHEMAID')
  and base.namespace in (1, 5)
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where i.bo# = t.obj#
             and (bitand(t.property, power(2,65)) = 0 or t.property is null)))
union all
select idx.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and c.obj# = base.obj#
  and i.bo# = base.obj#
  and base.owner# != userenv('SCHEMAID')
  and ic.intcol# = c.intcol#
  and idx.owner# = userenv('SCHEMAID')
  and idx.namespace = 4 /* index namespace */
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
/
comment on table USER_IND_EXPRESSIONS is
'Functional index expressions in user''s indexes and indexes on user''s tables'
/
comment on column USER_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column USER_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym USER_IND_EXPRESSIONS for USER_IND_EXPRESSIONS
/
grant read on USER_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view ALL_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where i.bo# = t.obj#
             and bitand(t.property, power(2,65)) = 0 or t.property is null))
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
          /* user has system privileges */
        ora_check_sys_privilege ( base.owner#, base.type#) = 1
        or
        ora_check_sys_privilege ( idx.owner#, idx.type#) = 1
      )
/
comment on table ALL_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on accessible TABLES'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column ALL_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column ALL_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/
create or replace public synonym ALL_IND_EXPRESSIONS for ALL_IND_EXPRESSIONS
/
grant read on ALL_IND_EXPRESSIONS to PUBLIC with grant option
/
create or replace view DBA_IND_EXPRESSIONS
    (INDEX_OWNER, INDEX_NAME,
     TABLE_OWNER, TABLE_NAME, COLUMN_EXPRESSION, COLUMN_POSITION)
as
select io.name, idx.name, bo.name, base.name, c.default$, ic.pos#
from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic,
     sys.user$ io, sys.user$ bo, sys.ind$ i
where bitand(ic.spare1,1) = 1       /* an expression */
  and (bitand(i.property,1024) = 0) /* not bmji */
  and ic.bo# = c.obj#
  and ic.intcol# = c.intcol#
  and ic.bo# = base.obj#
  and io.user# = idx.owner#
  and bo.user# = base.owner#
  and ic.obj# = idx.obj#
  and idx.obj# = i.obj#
  and i.type# in (1, 2, 3, 4, 6, 7, 9)
  and (base.type# != 2 or 1 = (select 1 /* Exclude Binary XML Token set indexes */
           from sys.tab$ t
           where i.bo# = t.obj#
             and bitand(t.property, power(2,65)) = 0 or t.property is null))
/
create or replace public synonym DBA_IND_EXPRESSIONS for DBA_IND_EXPRESSIONS
/
grant select on DBA_IND_EXPRESSIONS to select_catalog_role
/
comment on table DBA_IND_EXPRESSIONS is
'FUNCTIONAL INDEX EXPRESSIONs on all TABLES and CLUSTERS'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_IND_EXPRESSIONS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_OWNER is
'Table or cluster owner'
/
comment on column DBA_IND_EXPRESSIONS.TABLE_NAME is
'Table or cluster name'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_EXPRESSION is
'Functional index expression defining the column'
/
comment on column DBA_IND_EXPRESSIONS.COLUMN_POSITION is
'Position of column or attribute within index'
/


execute CDBView.create_cdbview(false,'SYS','DBA_IND_EXPRESSIONS','CDB_IND_EXPRESSIONS');
grant select on SYS.CDB_IND_EXPRESSIONS to select_catalog_role
/
create or replace public synonym CDB_IND_EXPRESSIONS for SYS.CDB_IND_EXPRESSIONS
/

create or replace view INDEX_STATS as
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstlvl              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave,
        kdxstncd        del_lf_cmp_rows,
        kdxstncp        prg_lf_cmp_rows,
        kdxstncr        lf_cmp_rows,
        kdxstlcr        lf_cmp_rows_len,
        kdxstnur        lf_uncmp_rows,
        kdxstlur        lf_uncmp_rows_len,
        kdxstlsr        lf_suf_rows_len,
        kdxstlcu        lf_cmp_rows_uncmp_len,
        kdxstrcc        lf_cmp_recmp_count,
        kdxstlvl        lf_cmp_lock_vec_len,
        kdxstncb        lf_cmp_blks,
        kdxstnub        lf_uncmp_blks
  from obj$ o, ind$ i, seg$ s, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = i.file#
  and  s.block# = i.block#
  and  s.ts# = i.ts#
  and  i.obj#   = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstlvl              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave,
        kdxstncd        del_lf_cmp_rows,
        kdxstncp        prg_lf_cmp_rows,
        kdxstncr        lf_cmp_rows,
        kdxstlcr        lf_cmp_rows_len,
        kdxstnur        lf_uncmp_rows,
        kdxstlur        lf_uncmp_rows_len,
        kdxstlsr        lf_suf_rows_len,
        kdxstlcu        lf_cmp_rows_uncmp_len,
        kdxstrcc        lf_cmp_recmp_count,
        kdxstlvl        lf_cmp_lock_vec_len,
        kdxstncb        lf_cmp_blks,
        kdxstnub        lf_uncmp_blks
  from obj$ o, seg$ s, indpart$ ip, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = ip.file#
  and  s.block# = ip.block#
  and  s.ts#    = ip.ts#
  and  ip.obj#  = o.obj#
union all
 select kdxstrot+1      height,
        kdxstsbk        blocks,
        o.name,
        o.subname       partition_name,
        kdxstlrw        lf_rows,
        kdxstlbk        lf_blks,
        kdxstlln        lf_rows_len,
        kdxstlub        lf_blk_len,
        kdxstbrw        br_rows,
        kdxstbbk        br_blks,
        kdxstbln        br_rows_len,
        kdxstbub        br_blk_len,
        kdxstdrw        del_lf_rows,
        kdxstdln        del_lf_rows_len,
        kdxstdis        distinct_keys,
        kdxstmrl        most_repeated_key,
        kdxstlbk*kdxstlub+kdxstbbk*kdxstbub     btree_space,
        kdxstlln+kdxstbln+kdxstlvl              used_space,
        ceil(((kdxstlln+kdxstbln)*100)/
        (kdxstlbk*kdxstlub+kdxstbbk*kdxstbub))
                                                pct_used,
        kdxstlrw/decode(kdxstdis, 0, 1, kdxstdis) rows_per_key,
        kdxstrot+1+(kdxstlrw+kdxstdis)/(decode(kdxstdis, 0, 1, kdxstdis)*2)
                                                blks_gets_per_access,
        kdxstnpr        pre_rows,
        kdxstpln        pre_rows_len,
        kdxstokc        opt_cmpr_count,
        kdxstpsk        opt_cmpr_pctsave,
        kdxstncd        del_lf_cmp_rows,
        kdxstncp        prg_lf_cmp_rows,
        kdxstncr        lf_cmp_rows,
        kdxstlcr        lf_cmp_rows_len,
        kdxstnur        lf_uncmp_rows,
        kdxstlur        lf_uncmp_rows_len,
        kdxstlsr        lf_suf_rows_len,
        kdxstlcu        lf_cmp_rows_uncmp_len,
        kdxstrcc        lf_cmp_recmp_count,
        kdxstlvl        lf_cmp_lock_vec_len,
        kdxstncb        lf_cmp_blks,
        kdxstnub        lf_uncmp_blks
  from obj$ o, seg$ s, indsubpart$ isp, x$kdxst
 where kdxstobj = o.obj# and kdxstfil = s.file#
  and  kdxstblk = s.block#
  and  kdxsttsn = s.ts#
  and  s.file#  = isp.file#
  and  s.block# = isp.block#
  and  s.ts#    = isp.ts#
  and  isp.obj#  = o.obj#
/
comment on table INDEX_STATS is
'statistics on the b-tree'
/
comment on column index_stats.height is
'height of the b-tree'
/
comment on column index_stats.blocks is
'blocks allocated to the segment'
/
comment on column index_stats.name is
'name of the index'
/
comment on column index_stats.partition_name is
'name of the index partition, if partitioned'
/
comment on column index_stats.lf_rows is
'number of leaf rows (values in the index)'
/
comment on column index_stats.lf_blks is
'number of leaf blocks in the b-tree'
/
comment on column index_stats.lf_rows_len is
'sum of the lengths of all the leaf rows'
/
comment on column index_stats.lf_blk_len is
'useable space in a leaf block'
/
comment on column index_stats.br_rows is
'number of branch rows'
/
comment on column index_stats.br_blks is
'number of branch blocks in the b-tree'
/
comment on column index_stats.br_rows_len is
'sum of the lengths of all the branch blocks in the b-tree'
/
comment on column index_stats.br_blk_len is
'useable space in a branch block'
/
comment on column index_stats.del_lf_rows is
'number of deleted leaf rows in the index'
/
comment on column index_stats.del_lf_rows_len is
'total length of all deleted rows in the index'
/
comment on column index_stats.distinct_keys is
'number of distinct keys in the index'
/
comment on column index_stats.most_repeated_key is
'how many times the most repeated key is repeated'
/
comment on column index_stats.btree_space is
'total space currently allocated in the b-tree'
/
comment on column index_stats.used_space is
'total space that is currently being used in the b-tree'
/
comment on column index_stats.pct_used is
'percent of space allocated in the b-tree that is being used'
/
comment on column index_stats.rows_per_key is
'average number of rows per distinct key'
/
comment on column index_stats.blks_gets_per_access is
'Expected number of consistent mode block gets per row. This assumes that a row chosen at random from the table is being searched for using the index'
/
comment on column index_stats.pre_rows is
'number of prefix rows (values in the index)'
/
comment on column index_stats.pre_rows_len is
'sum of lengths of all prefix rows'
/
comment on column index_stats.opt_cmpr_count is
'optimal prefix compression count for the index'
/
comment on column index_stats.opt_cmpr_pctsave is
'percentage storage saving expected from optimal prefix compression'
/
comment on column index_stats.del_lf_cmp_rows is
'number of deleted rows that are within a CU'
/
comment on column index_stats.prg_lf_cmp_rows is
'number of purged rows that are within a CU'
/
comment on column index_stats.lf_cmp_rows is
'number of rows that are in a CU or prefix compressed'
/
comment on column index_stats.lf_cmp_rows_len is
'sum of lengths of all prefix rows and CUs'
/
comment on column index_stats.lf_uncmp_rows is
'number of rows that are neither in a CU nor prefix compressed'
/
comment on column index_stats.lf_uncmp_rows_len is
'sum of lengths of rows that are neither in a CU nor prefix compressed'
/
comment on column index_stats.lf_suf_rows_len is
'sum of lengths of suffix rows'
/
comment on column index_stats.lf_cmp_rows_uncmp_len is
'sum of the uncompressed lengths of rows that are in a CU or prefix compressed'
/
comment on column index_stats.lf_cmp_recmp_count is
'sum of CU recompression counts'
/
comment on column index_stats.lf_cmp_lock_vec_len is
'sum of CU lock vector lengths'
/
comment on column index_stats.lf_cmp_blks is
'number of blocks that have a CU or nonzero prefix column count'
/
comment on column index_stats.lf_uncmp_blks is
'number of blocks that do not have a CU and have a zero prefix column count'
/
create or replace public synonym INDEX_STATS for INDEX_STATS
/
grant read on INDEX_STATS to public with grant option
/
create or replace view INDEX_HISTOGRAM as
 select hist.indx * power(2, stats.kdxstscl-4)  repeat_count,
        hist.kdxhsval                           keys_with_repeat_count
        from  x$kdxst stats, x$kdxhs hist
/
comment on table INDEX_HISTOGRAM is
'statistics on keys with repeat count'
/
comment on column index_histogram.repeat_count is
'number of times that a key is repeated'
/
comment on column index_histogram.keys_with_repeat_count is
'number of keys that are repeated REPEAT_COUNT times'
/
create or replace public synonym INDEX_HISTOGRAM for INDEX_HISTOGRAM
/
grant read on INDEX_HISTOGRAM to public with grant option
/

remark
remark  FAMILY "JOIN_IND_COLUMNS"
remark  Displays information on the join conditions of join
remark  indexes
remark
create or replace view USER_JOIN_IND_COLUMNS
    (INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and oi.owner# = userenv('SCHEMAID')
/
comment on table USER_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column USER_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column USER_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym USER_JOIN_IND_COLUMNS for USER_JOIN_IND_COLUMNS
/
grant read on USER_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
  and (oi.owner# = userenv('SCHEMAID')
        or
       oti.owner# = userenv('SCHEMAID')
        or
       oto.owner# = userenv('SCHEMAID')
        or
       oti.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
       oto.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
          /* user has system privileges */
         ora_check_sys_privilege ( oi.owner#, oi.type#) = 1
        or
         ora_check_sys_privilege ( oti.owner#, oti.type#) = 1
        or
         ora_check_sys_privilege ( oto.owner#, oto.type#) = 1
       )
/
comment on table ALL_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column ALL_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column ALL_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym ALL_JOIN_IND_COLUMNS for ALL_JOIN_IND_COLUMNS
/
grant read on ALL_JOIN_IND_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_JOIN_IND_COLUMNS
    (INDEX_OWNER, INDEX_NAME,
     INNER_TABLE_OWNER, INNER_TABLE_NAME, INNER_TABLE_COLUMN,
     OUTER_TABLE_OWNER, OUTER_TABLE_NAME, OUTER_TABLE_COLUMN)
as
select
  ui.name, oi.name,
  uti.name, oti.name, ci.name,
  uto.name, oto.name, co.name
from
  sys.user$ ui, sys.user$ uti, sys.user$ uto,
  sys.obj$ oi, sys.obj$ oti, sys.obj$ oto,
  sys.col$ ci, sys.col$ co,
  sys.jijoin$ ji
where ji.obj# = oi.obj#
  and oi.owner# = ui.user#
  and ji.tab1obj# = oti.obj#
  and oti.owner# = uti.user#
  and ci.obj# = oti.obj#
  and ji.tab1col# = ci.intcol#
  and ji.tab2obj# = oto.obj#
  and oto.owner# = uto.user#
  and co.obj# = oto.obj#
  and ji.tab2col# = co.intcol#
/
comment on table DBA_JOIN_IND_COLUMNS is
'Join Index columns comprising the join conditions'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_OWNER is
'Index owner'
/
comment on column DBA_JOIN_IND_COLUMNS.INDEX_NAME is
'Index name'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_OWNER is
'Table owner of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_NAME is
'Table name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.INNER_TABLE_COLUMN is
'Column name of inner table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_OWNER is
'Table owner of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_NAME is
'Table name of outer table (table closer to the fact table)'
/
comment on column DBA_JOIN_IND_COLUMNS.OUTER_TABLE_COLUMN is
'Column name of outer table (table closer to the fact table)'
/
create or replace public synonym DBA_JOIN_IND_COLUMNS for DBA_JOIN_IND_COLUMNS
/
grant select on DBA_JOIN_IND_COLUMNS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_JOIN_IND_COLUMNS','CDB_JOIN_IND_COLUMNS');
grant select on SYS.CDB_JOIN_IND_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_JOIN_IND_COLUMNS for SYS.CDB_JOIN_IND_COLUMNS
/

@?/rdbms/admin/sqlsessend.sql
 
