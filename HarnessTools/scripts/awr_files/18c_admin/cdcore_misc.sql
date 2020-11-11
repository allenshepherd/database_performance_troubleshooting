Rem
Rem $Header: rdbms/admin/cdcore_misc.sql /main/1 2017/05/20 12:22:50 raeburns Exp $
Rem
Rem cdcore_misc.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_misc.sql - Catalog DCORE.bsq views for misc objects
Rem
Rem    DESCRIPTION
Rem      This script create views for lobs, rollback segments, sequences, 
Rem      and synonyms.  It also creates old views that are no longer
Rem      documented, but may be used in older applications.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_misc.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_misc.sql
Rem    SQL_PHASE:CDCORE_MISC
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

remark
remark  FAMILY "LOBS"
remark
remark  Views for showing information about LOBs:
remark  USER_LOBS, ALL_LOBS, and DBA_LOBS
remark
create or replace view USER_LOBS
    (TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE,
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       decode(bitand(l.property, 8),
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES', 512,
                                    'YES', 'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 'YES',
                                   'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property,2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.lob$ l, sys.obj$ lo,
     sys.obj$ io, sys.ts$ ts, sys.tab$ ta, sys.user$ ut, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and o.owner# = ut.user#
  and ut.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(plob.defflags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(plob.defflags, 32), 32, 
              decode(bitand(plob.defpro, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                          512, 'YES', 'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO', 512, 'YES',
                                         'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table USER_LOBS is
'Description of the user''s own LOBs contained in the user''s own tables'
/
comment on column USER_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column USER_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column USER_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column USER_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column USER_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column USER_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column USER_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column USER_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column USER_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column USER_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column USER_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column USER_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column USER_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column USER_LOBS.DEDUPLICATION is
'What kind of DEDUPLICATION is used for this lob?'
/
comment on column USER_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column USER_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column USER_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column USER_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column USER_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
comment on column USER_LOBS.RETENTION_TYPE is
'What kind of retention is inuse?'
/
comment on column USER_LOBS.RETENTION_VALUE is
'What is the retention value?'
/
create or replace public synonym USER_LOBS for USER_LOBS
/
grant read on USER_LOBS to PUBLIC with grant option
/
create or replace view ALL_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE,
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES', 512, 'YES',
                                    'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 'YES',
                                    'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768, 
              'HIGH',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO', 
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has System Privileges */
       ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32    /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(plob.defflags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(plob.defflags, 32), 32, 
              decode(bitand(plob.defpro, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                         512, 'YES', 'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO', 512, 'YES', 
                                        'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO', 'YES'),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u, sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has System Privileges */
       ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32         /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table ALL_LOBS is
'Description of LOBs contained in tables accessible to the user'
/
comment on column ALL_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column ALL_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column ALL_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column ALL_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column ALL_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column ALL_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column ALL_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column ALL_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column ALL_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column ALL_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column ALL_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column ALL_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column ALL_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column ALL_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column ALL_LOBS.DEDUPLICATION is
'What kind of deduplication is used for this lob?'
/
comment on column ALL_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column ALL_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column ALL_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column ALL_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column ALL_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
create or replace public synonym ALL_LOBS for ALL_LOBS
/
grant read on ALL_LOBS to PUBLIC with grant option
/
create or replace view DBA_LOBS
    (OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, TABLESPACE_NAME, INDEX_NAME,
     CHUNK, PCTVERSION, RETENTION, FREEPOOLS, CACHE, LOGGING, ENCRYPT, 
     COMPRESSION, DEDUPLICATION, IN_ROW, FORMAT, PARTITIONED, SECUREFILE, 
     SEGMENT_CREATED, RETENTION_TYPE, RETENTION_VALUE)
as
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name), lo.name,
       decode(bitand(l.property, 8), 
           8, decode(l.ts#, 2147483647, ts1.name, ts.name), ts.name),
       io.name,
       l.chunk * decode(bitand(l.property, 8), 8, ts1.blocksize,
                        ts.blocksize),
       decode(bitand(l.flags, 32), 0, l.pctversion$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, 
              decode(bitand(l.property, 2048), 2048, to_number(NULL),
                     l.retention), to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(l.flags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                   16, 'CACHEREADS', 256, 'YES',
                                   512, 'YES', 'YES'),
       decode(bitand(l.flags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 
                                       'YES', 'YES'),
       decode(bitand(l.flags, 4096), 4096, 'YES',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 32768, 
              'HIGH',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.flags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(l.property, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(l.property, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(l.property, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(l.property, 2048),
               2048, 
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, 0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(l.flags, 32), 32, 'YES', 'NO')),
       decode (bitand(l.property, 2048),
               2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, 2, ds.mintim_stg, to_number(NULL)),
                      decode(s.lists, 2, s.groups, to_number(NULL))))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.tab$ ta, sys.lob$ l,
     sys.obj$ lo, sys.obj$ io, sys.user$ u, sys.ts$ ts, sys.ts$ ts1,
     sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and bitand(o.flags, 128) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.ts# = ts.ts#(+)
  and u.tempts# = ts1.ts#
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) != 32           /* not partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
union all
select u.name, o.name,
       decode(bitand(c.property, 1), 1, ac.name, c.name),
       lo.name,
       NVL(ts1.name,
        (select ts2.name 
        from    ts$ ts2, partobj$ po 
        where   o.obj# = po.obj# and po.defts# = ts2.ts#)), 
       io.name,
       plob.defchunk * NVL(ts1.blocksize, NVL((
        select ts2.blocksize
        from   sys.ts$ ts2, sys.lobfrag$ lf
        where  l.lobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2),
        (select ts2.blocksize
        from   sys.ts$ ts2, sys.lobcomppart$ lcp, sys.lobfrag$ lf
        where  l.lobj# = lcp.lobj# and lcp.partobj# = lf.parentobj# and
               lf.ts# = ts2.ts# and rownum < 2))),
       decode(bitand(l.flags, 32), 0, plob.defpctver$, to_number(NULL)),
       decode(bitand(l.flags, 32), 32, l.retention, to_number(NULL)),
       decode(l.freepools, 0, to_number(NULL), 65534, to_number(NULL),
              65535, to_number(NULL), l.freepools),
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES',
                                         512, 'YES',  'YES'),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                        16,'NO', 256, 'NO',
                                        512, 'YES', 'UNKNOWN'),
       decode(bitand(plob.defflags, 4096), 4096, 'YES',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 57344), 8192, 'LOW', 16384, 'MEDIUM', 
              32768, 'HIGH',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags, 458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro, 2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro, 2), 2, 'YES', 'NO'),
       decode(c.type#, 113, 'NOT APPLICABLE ',
              decode(bitand(l.property, 512), 512,
                     'ENDIAN SPECIFIC', 'ENDIAN NEUTRAL ')),
       decode(bitand(ta.property, 32), 32, 'YES', 'NO'),
       decode(bitand(plob.defpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(l.property, 4096), 4096, 'NO',
              decode(bitand(ta.property, 32), 32, 'N/A', 'YES')),
       decode (bitand(plob.defpro, 2048), 2048,
               decode(bitand(ta.property, 17179869184), 17179869184,
                      decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                            0, 'NONE', 1, 'AUTO',
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'),
                      decode(s.lists, to_number(NULL), 'DEFAULT',
                                      0, 'NONE', 1, 'AUTO',
                                      2, 'MIN', 3, 'MAX',
                                      4, 'DEFAULT', 'INVALID')),
               decode(bitand(plob.defflags, 32), 32, 'YES', 'NO')),
       decode (bitand(plob.defpro, 2048),
               2048, decode(bitand(ta.property, 17179869184), 17179869184,
                            decode(ds.lobret_stg, 2, plob.defmintime,
                                   to_number(NULL)),
                            decode(s.lists, 2, plob.defmintime, to_number(NULL))
                           ))
from sys.obj$ o, sys.col$ c, sys.attrcol$ ac, sys.partlob$ plob,
     sys.lob$ l, sys.obj$ lo, sys.obj$ io, sys.ts$ ts1, sys.tab$ ta,
     sys.user$ u, sys.seg$ s, sys.deferred_stg$ ds
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts1.ts# (+)
  and c.obj# = ac.obj#(+)
  and c.intcol# = ac.intcol#(+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and o.obj# = ta.obj#
  and bitand(ta.property, 32) = 32                /* partitioned table */
  and l.file# = s.file#(+)
  and l.block# = s.block#(+)
  and l.ts# = s.ts#(+)
  and l.lobj# = ds.obj#(+)
/
comment on table DBA_LOBS is
'Description of LOBs contained in all tables'
/
comment on column DBA_LOBS.OWNER is
'Owner of the table containing the LOB'
/
comment on column DBA_LOBS.TABLE_NAME is
'Name of the table containing the LOB'
/
comment on column DBA_LOBS.COLUMN_NAME is
'Name of the LOB column or attribute'
/
comment on column DBA_LOBS.SEGMENT_NAME is
'Name of the LOB segment'
/
comment on column DBA_LOBS.TABLESPACE_NAME is
'Name of the tablespace containing the LOB segment'
/
comment on column DBA_LOBS.INDEX_NAME is
'Name of the LOB index'
/
comment on column DBA_LOBS.CHUNK is
'Size of the LOB chunk as a unit of allocation/manipulation in bytes'
/
comment on column DBA_LOBS.PCTVERSION is
'Maximum percentage of the LOB space used for versioning'
/
comment on column DBA_LOBS.RETENTION is
'Maximum time duration for versioning of the LOB space'
/
comment on column DBA_LOBS.FREEPOOLS is
'Number of freepools for this LOB segment'
/
comment on column DBA_LOBS.CACHE is
'Is the LOB accessed through the buffer cache?'
/
comment on column DBA_LOBS.LOGGING is
'Are changes to the LOB logged?'
/
comment on column DBA_LOBS.ENCRYPT is
'Is this lob encrypted?'
/
comment on column DBA_LOBS.COMPRESSION is
'What level of compression is used for this lob?'
/
comment on column DBA_LOBS.DEDUPLICATION is
'What kind of deduplication is used for this lob?'
/
comment on column DBA_LOBS.IN_ROW is
'Are some of the LOBs stored with the base row?'
/
comment on column DBA_LOBS.FORMAT is
'Is the LOB storage format dependent on the endianness of the platform?'
/
comment on column DBA_LOBS.PARTITIONED is
'Is the LOB column in a partitioned table?'
/
comment on column DBA_LOBS.SECUREFILE is
'Is the LOB a SECUREFILE LOB?'
/
comment on column DBA_LOBS.SEGMENT_CREATED is
'Is the LOB segment created?'
/
create or replace public synonym DBA_LOBS for DBA_LOBS
/
grant select on DBA_LOBS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOBS','CDB_LOBS');
grant select on SYS.CDB_LOBS to select_catalog_role
/
create or replace public synonym CDB_LOBS for SYS.CDB_LOBS
/

remark
remark  FAMILY "ROLLBACK_SEGS"
remark  CREATE ROLLBACK SEGMENT parameters.
remark  This family has a DBA member only.
remark
create or replace view DBA_ROLLBACK_SEGS
    (SEGMENT_NAME, OWNER, TABLESPACE_NAME, SEGMENT_ID, FILE_ID, BLOCK_ID,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     STATUS, INSTANCE_NUM, RELATIVE_FNO)
as
select un.name, decode(un.user#,1,'PUBLIC','SYS'),
       ts.name, un.us#, f.file#, un.block#,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(un.status$, 2, 'OFFLINE', 3, 'ONLINE',
                          4, 'UNDEFINED', 5, 'NEEDS RECOVERY',
                          6, 'PARTLY AVAILABLE', 'UNDEFINED'),
       decode(un.inst#, 0, NULL, un.inst#), un.file#
from sys.undo$ un, sys.seg$ s, sys.ts$ ts, sys.file$ f
where un.status$ != 1
  and un.ts# = s.ts#
  and un.file# = s.file#
  and un.block# = s.block#
  and s.type# in (1, 10)
  and s.ts# = ts.ts#
  and un.ts# = f.ts#
  and un.file# = f.relfile#
/
create or replace public synonym DBA_ROLLBACK_SEGS for DBA_ROLLBACK_SEGS
/
grant select on DBA_ROLLBACK_SEGS to select_catalog_role
/
comment on table DBA_ROLLBACK_SEGS is
'Description of rollback segments'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_NAME is
'Name of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.OWNER is
'Owner of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.TABLESPACE_NAME is
'Name of the tablespace containing the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.SEGMENT_ID is
'ID number of the rollback segment'
/
comment on column DBA_ROLLBACK_SEGS.FILE_ID is
'ID number of the file containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.BLOCK_ID is
'ID number of the block containing the segment header'
/
comment on column DBA_ROLLBACK_SEGS.INITIAL_EXTENT is
'Initial extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.NEXT_EXTENT is
'Secondary extent size in bytes'
/
comment on column DBA_ROLLBACK_SEGS.MIN_EXTENTS is
'Minimum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.MAX_EXTENTS is
'Maximum number of extents'
/
comment on column DBA_ROLLBACK_SEGS.PCT_INCREASE is
'Percent increase for extent size'
/
comment on column DBA_ROLLBACK_SEGS.STATUS is
'Rollback segment status'
/
comment on column DBA_ROLLBACK_SEGS.INSTANCE_NUM is
'Rollback segment owning parallel server instance number'
/
comment on column DBA_ROLLBACK_SEGS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/


execute CDBView.create_cdbview(false,'SYS','DBA_ROLLBACK_SEGS','CDB_ROLLBACK_SEGS');
grant select on SYS.CDB_ROLLBACK_SEGS to select_catalog_role
/
create or replace public synonym CDB_ROLLBACK_SEGS for SYS.CDB_ROLLBACK_SEGS
/

remark
remark  FAMILY "SEQUENCES"
remark  CREATE SEQUENCE information.
remark
create or replace view USER_SEQUENCES
  (SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER,
                  SCALE_FLAG, EXTEND_FLAG, SESSION_FLAG, KEEP_VALUE)
as select o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater,
      decode(bitand(s.flags, 16), 16, 'Y', 'N'),
      decode(bitand(s.flags, 2048), 2048, 'Y', 'N'),
      decode(bitand(s.flags, 64), 64, 'Y', 'N'),
      decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.seq$ s, sys.obj$ o
where o.owner# = userenv('SCHEMAID')
  and o.obj# = s.obj#
  and (bitand(s.flags, 1024) = 0 or s.flags is null)
/
comment on table USER_SEQUENCES is
'Description of the user''s own SEQUENCEs'
/
comment on column USER_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column USER_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column USER_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column USER_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column USER_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column USER_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column USER_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column USER_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
comment on column USER_SEQUENCES.SCALE_FLAG is
'Is this a scalable sequence?'
/
comment on column USER_SEQUENCES.EXTEND_FLAG is
'Does this scalable sequence''s generated values extend beyond max_value or min_value?'
/
comment on column USER_SEQUENCES.SESSION_FLAG is
'Is this a session sequence?'
/
comment on column USER_SEQUENCES.KEEP_VALUE is
'Are sequence values kept during replay after failure'
/
create or replace public synonym USER_SEQUENCES for USER_SEQUENCES
/
create or replace public synonym SEQ for USER_SEQUENCES
/
grant read on USER_SEQUENCES to PUBLIC with grant option
/
create or replace view ALL_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER,
                  SCALE_FLAG, EXTEND_FLAG, SESSION_FLAG, KEEP_VALUE)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater,
      decode(bitand(s.flags, 16), 16, 'Y', 'N'),
      decode(bitand(s.flags, 2048), 2048, 'Y', 'N'),
      decode(bitand(s.flags, 64), 64, 'Y', 'N'),
      decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
        or
        ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  and (bitand(s.flags, 1024) = 0 or s.flags is null)
/
comment on table ALL_SEQUENCES is
'Description of SEQUENCEs accessible to the user'
/
comment on column ALL_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column ALL_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column ALL_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column ALL_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column ALL_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column ALL_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column ALL_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column ALL_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column ALL_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
comment on column ALL_SEQUENCES.SCALE_FLAG is
'Is this a scalable sequence?'
/
comment on column ALL_SEQUENCES.EXTEND_FLAG is
'Does this scalable sequence''s generated values extend beyond max_value or min_value?'
/
comment on column ALL_SEQUENCES.SESSION_FLAG is
'Is this a session sequence?'
/
comment on column ALL_SEQUENCES.KEEP_VALUE is
'Are sequence values kept during replay after failure'
/
create or replace public synonym ALL_SEQUENCES for ALL_SEQUENCES
/
grant read on ALL_SEQUENCES to PUBLIC with grant option
/
create or replace view DBA_SEQUENCES
  (SEQUENCE_OWNER, SEQUENCE_NAME,
                  MIN_VALUE, MAX_VALUE, INCREMENT_BY,
                  CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER,
                  SCALE_FLAG, EXTEND_FLAG, SESSION_FLAG, KEEP_VALUE)
as select u.name, o.name,
      s.minvalue, s.maxvalue, s.increment$,
      decode (s.cycle#, 0, 'N', 1, 'Y'),
      decode (s.order$, 0, 'N', 1, 'Y'),
      s.cache, s.highwater,
      decode(bitand(s.flags, 16), 16, 'Y', 'N'),
      decode(bitand(s.flags, 2048), 2048, 'Y', 'N'),
      decode(bitand(s.flags, 64), 64, 'Y', 'N'),
      decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.seq$ s, sys.obj$ o, sys.user$ u
where u.user# = o.owner#
  and o.obj# = s.obj#
  and (bitand(s.flags, 1024) = 0 or s.flags is null)
/
create or replace public synonym DBA_SEQUENCES for DBA_SEQUENCES
/
grant select on DBA_SEQUENCES to select_catalog_role
/
comment on table DBA_SEQUENCES is
'Description of all SEQUENCEs in the database'
/
comment on column DBA_SEQUENCES.SEQUENCE_OWNER is
'Name of the owner of the sequence'
/
comment on column DBA_SEQUENCES.SEQUENCE_NAME is
'SEQUENCE name'
/
comment on column DBA_SEQUENCES.INCREMENT_BY is
'Value by which sequence is incremented'
/
comment on column DBA_SEQUENCES.MIN_VALUE is
'Minimum value of the sequence'
/
comment on column DBA_SEQUENCES.MAX_VALUE is
'Maximum value of the sequence'
/
comment on column DBA_SEQUENCES.CYCLE_FLAG is
'Does sequence wrap around on reaching limit?'
/
comment on column DBA_SEQUENCES.ORDER_FLAG is
'Are sequence numbers generated in order?'
/
comment on column DBA_SEQUENCES.CACHE_SIZE is
'Number of sequence numbers to cache'
/
comment on column DBA_SEQUENCES.LAST_NUMBER is
'Last sequence number written to disk'
/
comment on column DBA_SEQUENCES.SCALE_FLAG is
'Is this sequence scalable?'
/
comment on column DBA_SEQUENCES.EXTEND_FLAG is
'Does this scalable sequence''s generated values extend beyond max_value or min_value?'
/
comment on column DBA_SEQUENCES.SESSION_FLAG is
'Is this a session sequence?'
/
comment on column DBA_SEQUENCES.KEEP_VALUE is
'Are sequence values kept during replay after failure'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SEQUENCES','CDB_SEQUENCES');
grant select on SYS.CDB_SEQUENCES to select_catalog_role
/
create or replace public synonym CDB_SEQUENCES for SYS.CDB_SEQUENCES
/

remark
remark  FAMILY "SYNONYMS"
remark  CREATE SYNONYM information.
remark

rem The DBA_SYNONYMS view shows all synonyms in the database.
rem It is driven by the OBJ$ table,
rem restricting on type code 5 (synonym).
rem We join with the SYN$ table by object number,
rem to get the owner and name of the base object
rem that the synonym points to.
rem Note that despite the column names TABLE_OWNER and TABLE_NAME,
rem the base object might not be a table at all,
rem but rather a view, stored procedure, synonym, etc.
rem From SYN$, we also get the optional database link.
rem If the database link is null, then it's a local object.
rem Otherwise, it's a remote object.
rem Finally, we join with the USER$ table to get the name
rem of the user who owns the synonym, or PUBLIC.
rem

create or replace view INT$DBA_SYNONYMS SHARING=EXTENDED DATA 
    (OWNER, OWNERID, SYNONYM_NAME, OBJECT_TYPE#, TABLE_OWNER, 
     TABLE_NAME, DB_LINK, SHARING, ORIGIN_CON_ID)
as select u.name, u.user#, o.name, o.type#, s.owner, s.name, s.node, 
   case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
   to_number(sys_context('USERENV', 'CON_ID'))
from sys.user$ u, sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
/

create or replace view DBA_SYNONYMS 
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK, ORIGIN_CON_ID)
as 
select OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK,
       ORIGIN_CON_ID
from   INT$DBA_SYNONYMS 
/

create or replace public synonym DBA_SYNONYMS for DBA_SYNONYMS
/
grant select on DBA_SYNONYMS to select_catalog_role
/
comment on table DBA_SYNONYMS is
'All synonyms in the database'
/
comment on column DBA_SYNONYMS.OWNER is
'Username of the owner of the synonym'
/
comment on column DBA_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column DBA_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column DBA_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/
comment on column DBA_SYNONYMS.ORIGIN_CON_ID is
'ID of Container where row originates'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SYNONYMS','CDB_SYNONYMS');
grant select on SYS.CDB_SYNONYMS to select_catalog_role
/
create or replace public synonym CDB_SYNONYMS for SYS.CDB_SYNONYMS
/

rem
rem The view USER_SYNONYMS is identical to DBA_SYNONYMS,
rem except that we only look at synonyms owned by the current user,
rem by restricting on the owner id from OBJ$.
rem

create or replace view USER_SYNONYMS
    (SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK, ORIGIN_CON_ID)
as select SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK,
          ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_SYNONYMS) 
where OWNER=SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_SYNONYMS is
'The user''s private synonyms'
/
comment on column USER_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column USER_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column USER_SYNONYMS.DB_LINK is
'Database link referenced in a remote synonym'
/
comment on column USER_SYNONYMS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym SYN for USER_SYNONYMS
/
create or replace public synonym USER_SYNONYMS for USER_SYNONYMS
/
grant read on USER_SYNONYMS to PUBLIC with grant option
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_SYNONYMS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined for synonyms
rem (as opposed to those that are defined for some base object,
rem such as a table or view).
rem The view should not be publicly viewable (no grants or public synonyms).
rem

create or replace view "_INT$_ALL_SYNONYMS_FOR_SYN" SHARING=EXTENDED DATA
    (SYN_ID, SYN_OWNER, SYN_SYNONYM_NAME, SYN_TABLE_OWNER, SYN_TABLE_NAME,
     SYN_DB_LINK, BASE_SYN_ID, SHARING, ORIGIN_CON_ID)
as
select s.obj#, u.name, o.name, s.owner, s.name, 
       s.node, bo.obj#, 
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
     sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
where s.owner = bu.name         /* get the owner id for the base object */
  and bu.user# = bo.owner#      /* get the obj$ entry for the base object */
  and s.name = bo.name          /* get the obj$ entry for the base object */
  and bo.type# = 5              /* restrict to synonyms for synonyms */
  and o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
/

rem
rem Bug 25836652: do not project SYN_ID and BASE_SYN_ID, since they are 
rem meaningless outside of the originating container. Instead, rely on 
rem   SYN_OWNER        : owner of synonym
rem   SYN_TABLE_OWNER  : owner of base synonym
rem   SYN_SYNONYM_NAME : name of synonym
rem   SYN_TABLE_NAME   : name of base synonym
rem 
create or replace view "_ALL_SYNONYMS_FOR_SYNONYMS"
    (SYN_OWNER, SYN_SYNONYM_NAME, SYN_TABLE_OWNER, SYN_TABLE_NAME,
     SYN_DB_LINK, ORIGIN_CON_ID)
as
select SYN_OWNER, SYN_SYNONYM_NAME, SYN_TABLE_OWNER, 
       SYN_TABLE_NAME, SYN_DB_LINK, ORIGIN_CON_ID 
from   "_INT$_ALL_SYNONYMS_FOR_SYN" 
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_FOR_AUTH_OBJECTS is a support view for ALL_SYNONYMS.
rem This view is for internal use only and may change without notice.
rem It gives the list of synonyms that are defined directly
rem for an accessible object (and not for another synonym).
rem If the synonym is for an object via a database link,
rem then it wont appear here, because we have no way of knowing
rem whether remote objects are accessible or not.
rem The view should not be publicly viewable (no grants or public synonyms).
rem Bug 22833985: 
rem 1. Push nullness check on NODE inside "_INT$_ALL_SYNONYMS_FOR_AO"
rem 2. Check that base object of synonym is not another synonym
rem

create or replace view "_INT$_ALL_SYNONYMS_FOR_AO" SHARING=EXTENDED DATA 
    (SYN_ID, OWNER, OWNERID, SYNONYM_NAME, OBJECT_TYPE#, 
     BASE_OBJ_OWNER, BASE_OBJ_NAME, DB_LINK, 
     SHARING, ORIGIN_CON_ID)
as
select s.obj#, u.name, u.user#, o.name, o.type#, s.owner, s.name, s.node, 
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from  sys.user$ u, sys.syn$ s, sys."_CURRENT_EDITION_OBJ" o,
      sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
  and s.node is null
  and bo.name = s.name
  and bo.owner# = bu.user#
  and bu.name = s.owner
  and bo.type# <> 5
/

rem 
rem Bug 25836652: do not project SYN_ID, since it is meaningless outside 
rem of the originating container. Instead, project OWNER and SYNONYM_NAME.
rem

create or replace view "_ALL_SYNONYMS_FOR_AUTH_OBJECTS"
    (OWNER, SYNONYM_NAME, BASE_OBJ_OWNER, BASE_OBJ_NAME, ORIGIN_CON_ID)
as
select OWNER, SYNONYM_NAME, BASE_OBJ_OWNER, BASE_OBJ_NAME, ORIGIN_CON_ID
from "_INT$_ALL_SYNONYMS_FOR_AO" 
where 
      ora_check_sys_privilege ( ownerid, object_type#) = 1
   or
      exists
        (select null
         from sys.objauth$ ba, sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
         where bu.name = BASE_OBJ_OWNER
           and bo.name = BASE_OBJ_NAME
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
               )
        )
/

rem
rem bug 3369744:
rem The view _ALL_SYNONYMS_TREE is a support view for ALL_SYNONYMS.
rem The view is for internal use only and may change without notice.
rem It gives the hierarchical tree of synonyms that ultimately point
rem to a base object that is accessible by the current user and session.
rem It may perform poorly, due to the CONNECT BY clause.
rem It should not be made publicly viewable (no grants or public synonyms).
rem bug 22113854:
rem The correlated exists subquery predicate in START WITH clause may be
rem pushed into an index filter, leading to a suboptimal plan that executes
rem the subquery for every row in SYN$.  To avoid this, NO_PUSH_SUBQ hint
rem was added to this view.
rem Bug 25836652:
rem Do not project SYN_ID, since it is meaningless outside of the 
rem originating container. Instead, use SYN_OWNER and SYN_SYNONYM_NAME.
rem

create or replace view "_ALL_SYNONYMS_TREE"
    (SYN_OWNER, SYN_SYNONYM_NAME, SYN_TABLE_OWNER, 
     SYN_TABLE_NAME, SYN_DB_LINK, ORIGIN_CON_ID)
as
select s.syn_owner, s.syn_synonym_name, s.syn_table_owner, 
       s.syn_table_name, s.syn_db_link, s.origin_con_id
from sys."_ALL_SYNONYMS_FOR_SYNONYMS" s
/* user has any privs on ultimate base object */
start with exists (
  select /*+ NO_PUSH_SUBQ */ null
  from sys."_ALL_SYNONYMS_FOR_AUTH_OBJECTS" sa
  where s.syn_table_owner = sa.owner 
    and s.syn_table_name = sa.synonym_name
  )
connect by nocycle prior s.syn_owner = s.syn_table_owner and 
                   prior s.syn_synonym_name = s.syn_table_name
/

rem
rem The view ALL_SYNONYMS shows synonyms that are "accessible"
rem to the current user and session.
rem That includes all private synonyms (owned by the user);
rem plus all public synonyms;
rem plus synonyms that ultimately resolve to a base object
rem that is accessible to the current user and session.
rem The latter condition includes synonyms that resolve
rem through a chain of synonyms to an accessible base object.
rem Finally, if the user has special privileges,
rem then we also show all synonyms that point to local objects.
rem

create or replace view ALL_SYNONYMS
    (OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK, ORIGIN_CON_ID)
as
select OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK,
       ORIGIN_CON_ID
from INT$DBA_SYNONYMS 
where (
       OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER = 'PUBLIC' 
       or /* local object, and user has system privileges */
         (DB_LINK is null 
          and
          ora_check_sys_privilege ( ownerid, object_type#) = 1
         )
       or /* user has any privs on base object in local database */
        exists
        (select null
         from sys.objauth$ ba, sys."_CURRENT_EDITION_OBJ" bo, sys.user$ bu
         where DB_LINK is null 
           and bu.name = TABLE_OWNER
           and bo.name = TABLE_NAME
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
               )
        )
      )
union
select st.SYN_OWNER, st.SYN_SYNONYM_NAME, st.SYN_TABLE_OWNER, 
       st.SYN_TABLE_NAME, st.SYN_DB_LINK, st.ORIGIN_CON_ID
from sys."_ALL_SYNONYMS_TREE" st
/

comment on table ALL_SYNONYMS is
'All synonyms for base objects accessible to the user and session'
/
comment on column ALL_SYNONYMS.OWNER is
'Owner of the synonym'
/
comment on column ALL_SYNONYMS.SYNONYM_NAME is
'Name of the synonym'
/
comment on column ALL_SYNONYMS.TABLE_OWNER is
'Owner of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.TABLE_NAME is
'Name of the object referenced by the synonym'
/
comment on column ALL_SYNONYMS.DB_LINK is
'Name of the database link referenced in a remote synonym'
/
comment on column ALL_SYNONYMS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym ALL_SYNONYMS for ALL_SYNONYMS
/
grant read on ALL_SYNONYMS to PUBLIC with grant option
/


remark
remark  FAMILY "CLUSTERS"
remark  CREATE CLUSTER parameters.
remark
create or replace view INT$DBA_CLUSTERS 
    (OWNER, OWNERID, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL,  FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES, SHARING, ORIGIN_CON_ID)
as select u.name, u.user#, o.name, ts.name,
          mod(c.pctfree$, 100),
          decode(bitand(ts.flags, 32), 32, to_number(NULL), c.pctused$),
          c.size$,c.initrans,c.maxtrans,
          s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
          s.minexts, s.maxexts,
          decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.lists, 0, 1, s.lists)),
          decode(bitand(ts.flags, 32), 32, to_number(NULL),
            decode(s.groups, 0, 1, s.groups)),
          c.avgchn, decode(c.hashkeys, 0, 'INDEX', 'HASH'),
          decode(c.hashkeys, 0, NULL,
                 decode(c.func, 0, 'COLUMN', 1, 'DEFAULT',
                                2, 'HASH EXPRESSION', 3, 'DEFAULT2', NULL)),
          c.hashkeys,
          lpad(decode(c.degree, 32767, 'DEFAULT', nvl(c.degree,1)),10),
          lpad(decode(c.instances, 32767, 'DEFAULT', nvl(c.instances,1)),10),
          lpad(decode(bitand(c.flags, 8), 8, 'Y', 'N'), 5),
          decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
          decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
          lpad(decode(bitand(c.flags, 65536), 65536, 'Y', 'N'), 5),
          decode(bitand(c.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'), 
          case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
          to_number(sys_context('USERENV', 'CON_ID'))
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.clu$ c, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.ts# = ts.ts#
  and c.ts# = s.ts#
  and c.file# = s.file#
  and c.block# = s.block#
/

create or replace view DBA_CLUSTERS 
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL,  FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select OWNER, CLUSTER_NAME, TABLESPACE_NAME,
          PCT_FREE, PCT_USED, KEY_SIZE,
          INI_TRANS, MAX_TRANS,
          INITIAL_EXTENT, NEXT_EXTENT,
          MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
          FREELISTS, FREELIST_GROUPS,
          AVG_BLOCKS_PER_KEY,
          CLUSTER_TYPE, FUNCTION, HASHKEYS,
          DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
          CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES
from INT$DBA_CLUSTERS 
/
create or replace public synonym DBA_CLUSTERS for DBA_CLUSTERS
/
grant select on DBA_CLUSTERS to select_catalog_role
/
comment on table DBA_CLUSTERS is
'Description of all clusters in the database'
/
comment on column DBA_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column DBA_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column DBA_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column DBA_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column DBA_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column DBA_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column DBA_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column DBA_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column DBA_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column DBA_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column DBA_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column DBA_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column DBA_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTERS','CDB_CLUSTERS');
grant select on SYS.CDB_CLUSTERS to select_catalog_role
/
create or replace public synonym CDB_CLUSTERS for SYS.CDB_CLUSTERS
/

create or replace view USER_CLUSTERS
    (CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select CLUSTER_NAME, TABLESPACE_NAME,
          PCT_FREE, PCT_USED, KEY_SIZE,
          INI_TRANS, MAX_TRANS,
          INITIAL_EXTENT, NEXT_EXTENT,
          MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
          FREELISTS, FREELIST_GROUPS,
          AVG_BLOCKS_PER_KEY,
          CLUSTER_TYPE, FUNCTION, HASHKEYS,
          DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
          CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_CLUSTERS) 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table USER_CLUSTERS is
'Descriptions of user''s own clusters'
/
comment on column USER_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column USER_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column USER_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column USER_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column USER_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column USER_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column USER_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column USER_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column USER_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column USER_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column USER_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column USER_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column USER_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column USER_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column USER_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
create or replace public synonym USER_CLUSTERS for USER_CLUSTERS
/
create or replace public synonym CLU for USER_CLUSTERS
/
grant read on USER_CLUSTERS to PUBLIC with grant option
/
create or replace view ALL_CLUSTERS
    (OWNER, CLUSTER_NAME, TABLESPACE_NAME,
     PCT_FREE, PCT_USED, KEY_SIZE,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS,
     AVG_BLOCKS_PER_KEY,
     CLUSTER_TYPE, FUNCTION, HASHKEYS,
     DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES)
as select OWNER, CLUSTER_NAME, TABLESPACE_NAME,
          PCT_FREE, PCT_USED, KEY_SIZE,
          INI_TRANS, MAX_TRANS,
          INITIAL_EXTENT, NEXT_EXTENT,
          MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
          FREELISTS, FREELIST_GROUPS,
          AVG_BLOCKS_PER_KEY,
          CLUSTER_TYPE, FUNCTION, HASHKEYS,
          DEGREE, INSTANCES, CACHE, BUFFER_POOL, FLASH_CACHE,
          CELL_FLASH_CACHE, SINGLE_TABLE, DEPENDENCIES
from INT$DBA_CLUSTERS 
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or  /* user has system privileges */
       (
        /* 3 is the type# for CLUSTER. See kgl.h for more info */
        ora_check_sys_privilege ( ownerid, 3 ) = 1
       )
      )
/
create or replace public synonym ALL_CLUSTERS for ALL_CLUSTERS
/
grant read on ALL_CLUSTERS to PUBLIC with grant option
/
comment on table ALL_CLUSTERS is
'Description of clusters accessible to the user'
/
comment on column ALL_CLUSTERS.OWNER is
'Owner of the cluster'
/
comment on column ALL_CLUSTERS.CLUSTER_NAME is
'Name of the cluster'
/
comment on column ALL_CLUSTERS.TABLESPACE_NAME is
'Name of the tablespace containing the cluster'
/
comment on column ALL_CLUSTERS.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_CLUSTERS.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_CLUSTERS.KEY_SIZE is
'Estimated size of cluster key plus associated rows'
/
comment on column ALL_CLUSTERS.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_CLUSTERS.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_CLUSTERS.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_CLUSTERS.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_CLUSTERS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_CLUSTERS.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_CLUSTERS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_CLUSTERS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_CLUSTERS.AVG_BLOCKS_PER_KEY is
'Average number of blocks containing rows with a given cluster key'
/
comment on column ALL_CLUSTERS.CLUSTER_TYPE is
'Type of cluster: b-tree index or hash'
/
comment on column ALL_CLUSTERS.FUNCTION is
'If a hash cluster, the hash function'
/
comment on column ALL_CLUSTERS.HASHKEYS is
'If a hash cluster, the number of hash keys (hash buckets)'
/
comment on column ALL_CLUSTERS.DEGREE is
'The number of threads per instance for scanning the cluster'
/
comment on column ALL_CLUSTERS.INSTANCES is
'The number of instances across which the cluster is to be scanned'
/
comment on column ALL_CLUSTERS.CACHE is
'Whether the cluster is to be cached in the buffer cache'
/
comment on column ALL_CLUSTERS.BUFFER_POOL is
'The default buffer pool to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.FLASH_CACHE is
'The default flash cache hint to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for cluster blocks'
/
comment on column ALL_CLUSTERS.SINGLE_TABLE is
'Whether the cluster can contain only a single table'
/
comment on column ALL_CLUSTERS.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
remark
remark  FAMILY "CLU_COLUMNS"
remark  Mapping of cluster columns to table columns.
remark  This family has no ALL member.
remark
create or replace view USER_CLU_COLUMNS
    (CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc, sys.tab$ t,
     sys.attrcol$ ac
where oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and oc.owner#  = userenv('SCHEMAID')
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
comment on table USER_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column USER_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column USER_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column USER_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column USER_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/
create or replace public synonym USER_CLU_COLUMNS for USER_CLU_COLUMNS
/
grant read on USER_CLU_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_CLU_COLUMNS
    (OWNER, CLUSTER_NAME, CLU_COLUMN_NAME, TABLE_NAME, TAB_COLUMN_NAME)
as
select u.name, oc.name, cc.name, ot.name,
       decode(bitand(tc.property, 1), 1, ac.name, tc.name)
from sys.user$ u, sys.obj$ oc, sys.col$ cc, sys.obj$ ot, sys.col$ tc,
     sys.tab$ t, sys.attrcol$ ac
where oc.owner#  = u.user#
  and oc.obj#    = cc.obj#
  and t.bobj#    = oc.obj#
  and t.obj#     = tc.obj#
  and tc.segcol# = cc.segcol#
  and t.obj#     = ot.obj#
  and oc.type#   = 3
  and tc.obj#    = ac.obj#(+)
  and tc.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CLU_COLUMNS for DBA_CLU_COLUMNS
/
grant select on DBA_CLU_COLUMNS to select_catalog_role
/
comment on table DBA_CLU_COLUMNS is
'Mapping of table columns to cluster columns'
/
comment on column DBA_CLU_COLUMNS.OWNER is
'Owner of the cluster'
/
comment on column DBA_CLU_COLUMNS.CLUSTER_NAME is
'Cluster name'
/
comment on column DBA_CLU_COLUMNS.CLU_COLUMN_NAME is
'Key column in the cluster'
/
comment on column DBA_CLU_COLUMNS.TABLE_NAME is
'Clustered table name'
/
comment on column DBA_CLU_COLUMNS.TAB_COLUMN_NAME is
'Key column or attribute of object column in the table'
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLU_COLUMNS','CDB_CLU_COLUMNS');
grant select on SYS.CDB_CLU_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_CLU_COLUMNS for SYS.CDB_CLU_COLUMNS
/

remark
remark FAMILY CLUSTER_HASH_EXPRESSIONS
remark
create or replace view USER_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   us.user# = userenv('SCHEMAID')
/

comment on table USER_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for the user''s hash clusters'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column USER_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant read on USER_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym USER_CLUSTER_HASH_EXPRESSIONS for
 USER_CLUSTER_HASH_EXPRESSIONS
/

create or replace view ALL_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type#   = 8
and   c.obj#   = o.obj#
and   us.user# = o.owner#
and   ( us.user# = userenv('SCHEMAID')
        or  /* user has system privileges */
        ora_check_sys_privilege ( o.owner#, o.type# ) = 1
      )
/

comment on table ALL_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all accessible clusters'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Name of cluster'
/
comment on column ALL_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
grant read on ALL_CLUSTER_HASH_EXPRESSIONS to public with grant option
/
create or replace public synonym ALL_CLUSTER_HASH_EXPRESSIONS for
 ALL_CLUSTER_HASH_EXPRESSIONS
/

create or replace view DBA_CLUSTER_HASH_EXPRESSIONS
    (OWNER, CLUSTER_NAME, HASH_EXPRESSION)
as
select us.name, o.name, c.condition
from sys.cdef$ c, sys.user$ us, sys.obj$ o
where c.type# = 8
and c.obj#   = o.obj#
and us.user# = o.owner#
/

comment on table DBA_CLUSTER_HASH_EXPRESSIONS is
'Hash functions for all clusters'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.OWNER is
'Name of owner of cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.CLUSTER_NAME is
'Text of hash function of the cluster'
/
comment on column DBA_CLUSTER_HASH_EXPRESSIONS.HASH_EXPRESSION is
'Text of hash function of cluster'
/
create or replace public synonym DBA_CLUSTER_HASH_EXPRESSIONS for
 DBA_CLUSTER_HASH_EXPRESSIONS
/
grant select on DBA_CLUSTER_HASH_EXPRESSIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CLUSTER_HASH_EXPRESSIONS','CDB_CLUSTER_HASH_EXPRESSIONS');
grant select on SYS.CDB_CLUSTER_HASH_EXPRESSIONS to select_catalog_role
/
create or replace public synonym CDB_CLUSTER_HASH_EXPRESSIONS for SYS.CDB_CLUSTER_HASH_EXPRESSIONS
/

@?/rdbms/admin/sqlsessend.sql
 
