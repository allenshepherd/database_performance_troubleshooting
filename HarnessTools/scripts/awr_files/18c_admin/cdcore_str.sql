Rem
Rem $Header: rdbms/admin/cdcore_str.sql /main/4 2017/11/16 03:09:32 amunnoli Exp $
Rem
Rem cdcore_str.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_str.sql - Catalog DCORE STaRt
Rem
Rem    DESCRIPTION
Rem      This script performs creates some views on which the other
Rem      views created in the cdcore_xxx.sql scripts depend.
Rem
Rem    NOTES
Rem      If this script is changed in a backport, then both catost.sql and
Rem      dbmspdb.sql need to be included in the transaction's 
Rem      SQL_BACKPORT_APPLY/ROLLBACK_FILES properties to recreate the
Rem      real versions of the dummy objects created here (the getlong function
Rem      and the _HIST_HEAD_DEC and _HISTGRM_DEC views) .
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_str.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdcore_str.sql
Rem    SQL_PHASE: CDCORE_STR
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    11/13/17 - Bug 27106549: add HAS_SENSITIVE_COLUMN column to
Rem                           *_ALL[OBJECT]_TABLES views
Rem    amunnoli    10/26/17 - Bug 26965236: add HAS_SENSITIVE_COLUMN column
Rem    aumehend    09/11/17 - Bug 26658062 : Add IMXT INMEMORY and COMPRESSION
Rem                           clause to USER_TABLES
Rem    raeburns    05/10/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    05/10/17 - Created
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

remark Define views that depend on new bootstrap table columns
@@cdcore_mig.sql

Rem Statistics columns that could contain sensitive values are encrypted.
Rem Here we are creating dummy views on top of statistics tables hist_head$ 
Rem and histgrm$. These dummy views will return the useless encrypted data 
Rem rather than the required plaintext statistics. We need to do this 
Rem because the DBMS_STATS_INTERNAL package and the Decrypt APIs are not 
Rem yet available at this time when the database is still being created.
Rem
Rem Later on in catost.sql, we will replace these dummy views with a new 
Rem definition that will call into the decrypt APIs in DBMS_CRYPTO_INTERNAL 
Rem package.
Rem
@@cdcore_stat.sql

Rem Reinitialize the session to create new objects directly
@@?/rdbms/admin/sqlsessstart.sql

Rem Create a "dummy" version of the getlong function for use in view creation.
Rem The "real" version is created in dbmspdb.sql after the required packages 
Rem have been created.

create or replace function getlong( opcode  in number,
                                    p_rowid in rowid ) return varchar2
as
begin
    return null;
end getlong;
/

Rem create or replace function getViewSecValue
Rem return number deterministic result_cache is
Rem value1 number;
Rem begin
Rem    select 1 into value1 from dual where exists (select null from v$system_parameter where (name = 'O7_DICTIONARY_ACCESSIBILITY' and value = 'TRUE'));
Rem    return  value1;
Rem    EXCEPTION WHEN NO_DATA_FOUND THEN
Rem     return 0;
Rem end;
Rem /
Rem 
Rem show errors;
Rem /

remark
remark Always shows base user name
remark
create or replace view "_BASE_USER"
  (USER#,
   TYPE#,
   DATATS#,
   TEMPTS#,
   CTIME,
   PTIME,
   EXPTIME,
   LTIME,
   RESOURCE$,
   AUDIT$,
   DEFROLE,
   DEFGRP#,
   DEFGRP_SEQ#,
   ASTATUS,
   LCOUNT,
   DEFSCHCLASS,
   EXT_USERNAME,
   SPARE1,
   SPARE2,
   SPARE6,
   NAME
  )
as
select USER#,TYPE#,DATATS#,TEMPTS#,CTIME,PTIME,EXPTIME,LTIME,
       RESOURCE$,AUDIT$,DEFROLE,DEFGRP#,DEFGRP_SEQ#,ASTATUS,
       LCOUNT,DEFSCHCLASS,EXT_USERNAME,SPARE1,SPARE2,SPARE6,
       decode(u.type#, 2, substr(u.ext_username, 0, 30), u.name)
from sys.user$ u
/


rem
rem V5 views required for other Oracle products
rem

create or replace view syscatalog_
    (tname, creator, creatorid, tabletype, remarks)
  as
  select o.name, u.name, o.owner#,
         decode(o.type#, 2, 'TABLE', 4, 'VIEW', 6, 'SEQUENCE','?'), c.comment$
  from  sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.com$ c
  where u.user# = o.owner#
  and (o.type# in (4, 6, 150, 152)     /* view, sequence, hierarchies and analytic views */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
    and o.linkname is null
    and o.obj# = c.obj#(+)
    and ( o.owner# = userenv('SCHEMAID')
          or o.obj# in
             (select oa.obj#
              from   sys.objauth$ oa
              where  oa.grantee# in (userenv('SCHEMAID'), 1)
              )
          or
          (
            (o.type# in (4,6,150,152) /* view, sequence, hierarchies and analytic views */
             or
             (o.type# = 2 /* tables, excluding iot-overflow and nested tables */
              and
              not exists (select null
                            from sys.tab$ t
                           where t.obj# = o.obj#
                             and (bitand(t.property, 512) = 512 or
                                  bitand(t.property, 8192) = 8192))))
          and
          /* user has system privileges */
           ora_check_sys_privilege ( o.owner#, o.type# ) = 1
          )
       )
/
grant select on syscatalog_ to select_catalog_role
/
create or replace view syscatalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from syscatalog_
/
grant read on syscatalog to public with grant option;
create or replace synonym system.syscatalog for syscatalog;
rem
rem The catalog view returns almost all tables accessible to the user
rem except tables in SYS and SYSTEM ("dictionary tables").
rem
create or replace view catalog (tname, creator, tabletype, remarks) as
  select tname, creator, tabletype, remarks
  from  syscatalog_
  where creatorid not in (select user# from sys.user$ where name in
        ('SYS','SYSTEM'))
/
grant read on catalog to public with grant option;
create or replace synonym system.catalog for catalog;

create or replace view tab (tname, tabtype, clusterid) as
   select o.name,
      decode(o.type#, 2, 'TABLE', 3, 'CLUSTER', 150, 'HIERARCHY', 152, 'ANALYTIC VIEW',
             4, 'VIEW', 5, 'SYNONYM'), t.tab#
  from  sys.tab$ t, sys."_CURRENT_EDITION_OBJ" o
  where o.owner# = userenv('SCHEMAID')
  and o.type# >=2
  and o.type# <=5
  and o.linkname is null
  and o.obj# = t.obj# (+)
/
grant read on tab to public with grant option;
create or replace synonym system.tab for tab;
create or replace public synonym tab for tab;
create or replace view col
  (tname, colno, cname, coltype, width, scale, precision, nulls, defaultval,
   character_set_name) as
  select t.name, c.col#, c.name,
         decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                         2, decode(c.scale, null,
                                   decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                  'NUMBER'),
                         8, 'LONG',
                         9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                         12, 'DATE',
                         23, 'RAW', 24, 'LONG RAW',
                         69, 'ROWID',
                         96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                         100, 'BINARY_FLOAT',
                         101, 'BINARY_DOUBLE',
                         105, 'MLSLABEL',
                         106, 'MLSLABEL',
                         111, 'REF '||'"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                         113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                         121, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         122, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         123, '"'||ut.name||'"'||'.'||'"'||ot.name||'"',
                         178, 'TIME(' ||c.scale|| ')',
                         179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                         180, 'TIMESTAMP(' ||c.scale|| ')',
                         181, 'TIMESTAMP(' ||c.scale|| ')'||' WITH TIME ZONE',
                         231, 'TIMESTAMP(' ||c.scale|| ')'||' WITH LOCAL TIME ZONE',
                         182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                         183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                               c.scale || ')',
                         208, 'UROWID',
                         'UNDEFINED'),
         c.length, c.scale, c.precision#,
         decode(sign(c.null$),-1,'NOT NULL - DISABLED', 0, 'NULL',
        'NOT NULL'), c.default$,
         decode(c.charsetform, 1, 'CHAR_CS',
                               2, 'NCHAR_CS',
                               3, NLS_CHARSET_NAME(c.charsetid),
                               4, 'ARG:'||c.charsetid)
  from  sys.col$ c, sys."_CURRENT_EDITION_OBJ" t, sys.coltype$ ac,
        sys.obj$ ot, sys."_BASE_USER" ut
  where t.obj# = c.obj#
  and   t.type# in (2, 3, 4)
  and   t.owner# = userenv('SCHEMAID')
  and   bitand(c.property, 32) = 0 /* not hidden column */
  and   c.obj# = ac.obj#(+)
  and   c.intcol# = ac.intcol#(+)
  and   ac.toid = ot.oid$(+)
  and   ot.owner# = ut.user#(+)
/
grant read on col to public with grant option;
create or replace synonym system.col for col;
create or replace public synonym col for col;


create or replace view syssegobj
    (obj#, file#, block#, type, pctfree$, pctused$) as
  select obj#,
       decode(bitand(property, 32+64), 0, file#, to_number(null)),
       decode(bitand(property, 32+64), 0, block#, to_number(null)),
       'TABLE',
       decode(bitand(property, 32+64), 0, mod(pctfree$, 100), to_number(null)),
       decode(bitand(property, 32+64), 0, pctused$, to_number(null))
  from sys.tab$
  union all
  select obj#, file#, block#, 'CLUSTER', pctfree$, pctused$ from sys.clu$
  union all
  select obj#, file#, block#, 'INDEX', to_number(null), to_number(null)
         from sys.ind$
/
grant read on syssegobj to public with grant option;
create or replace view tabquotas (tname, type, objno, nextext, maxext, pinc,
                       pfree, pused) as
  select t.name, so.type, t.obj#,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                s.extsize * ts.blocksize),
  s.maxexts,
  decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
  so.pctfree$, decode(bitand(ts.flags, 32), 32, to_number(NULL), so.pctused$)
  from  sys.ts$ ts, sys.seg$ s, sys.obj$ t, syssegobj so
  where t.owner# = userenv('SCHEMAID')
  and   t.obj# = so.obj#
  and   so.file# = s.file#
  and   so.block# = s.block#
  and   s.ts# = ts.ts#
/
grant read on tabquotas to public with grant option;
create or replace synonym system.tabquotas for tabquotas;

rem ### do we need to fix this for bitmapped tablespaces
create or replace view sysfiles (tsname, fname, blocks) as
  select ts.name, dbf.name, f.blocks
  from  sys.ts$ ts, sys.file$ f, sys.v$dbfile dbf
  where ts.ts# = f.ts#(+) and dbf.file# = f.file# and f.status$ = 2
/
grant read on sysfiles to public with grant option;
create or replace synonym system.sysfiles for sysfiles;
create or replace view synonyms
    (sname, syntype, creator, tname, database, tabtype) as
  select s.name,
         decode(s.owner#,1,'PUBLIC','PRIVATE'), t.owner, t.name, 'LOCAL',
         decode(ot.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER', 4, 'VIEW',
                         5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                         8, 'FUNCTION', 9, 'PACKAGE', 22, 'LIBRARY',
                         29, 'JAVA CLASS', 87, 'ASSEMBLY', 'UNDEFINED')
  from  sys."_CURRENT_EDITION_OBJ" s, sys."_CURRENT_EDITION_OBJ" ot, 
        sys.syn$ t, sys.user$ u
  where s.obj# = t.obj#
    and ot.linkname is null
    and s.type# = 5
    and ot.name = t.name
    and t.owner = u.name
    and ot.owner# = u.user#
    and s.owner# in (1,userenv('SCHEMAID'))
    and t.node is null
union all
  select s.name, decode(s.owner#, 1, 'PUBLIC', 'PRIVATE'),
         t.owner, t.name, t.node, 'REMOTE'
  from  sys."_CURRENT_EDITION_OBJ" s, sys.syn$ t
  where s.obj# = t.obj#
    and s.type# = 5
    and s.owner# in (1, userenv('SCHEMAID'))
    and t.node is not null
/
grant read on synonyms to public with grant option;
create or replace view publicsyn (sname, creator, tname, database, tabtype) as
  select sname, creator, tname, database, tabtype
  from  synonyms
  where syntype = 'PUBLIC'
/
grant read on publicsyn to public with grant option;
create or replace synonym system.publicsyn for publicsyn;

remark
remark  FAMILY "TABLES"
remark  CREATE TABLE parameters.
remark
create or replace view USER_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL,  FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE, CLUSTERING, 
     ACTIVITY_TRACKING, DML_TIMESTAMP, HAS_IDENTITY, CONTAINER_DATA,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, DEFAULT_COLLATION, DUPLICATED, SHARDED, EXTERNAL,
     CELLMEMORY, CONTAINERS_DEFAULT, CONTAINER_MAP, EXTENDED_DATA_LINK, 
     EXTENDED_DATA_LINK_MAP, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME, 
     CONTAINER_MAP_OBJECT, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE, 
     HAS_SENSITIVE_COLUMN)
as
select o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',                                    
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
           decode(bitand(t.property, 8388608), 8388608,
                  'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216   -- 0x1000000
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES',
              decode(bitand(t.property, 32), 32, 'N/A', 'NO')),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO', 
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',
                     4398046511104,'MANUAL','DEFAULT'),
       decode(bitand(t.property, 18014398509481984), 18014398509481984, 
                     'YES', 'NO'),
       case when bitand(t.property, 1125899906842624) = 1125899906842624
                 then 'ROW ACCESS TRACKING'
            when bitand(t.property, 2251799813685248) = 2251799813685248
                 then 'SEGMENT ACCESS TRACKING'
        end,
       case when bitand(t.property, 844424930131968) = 844424930131968
                 then 'ROW CREATION/MODIFICATION'
            when bitand(t.property, 281474976710656) = 281474976710656
                 then 'ROW MODIFICATION'
            when bitand(t.property, 562949953421312) = 562949953421312
                 then 'ROW CREATION'
        end,
       decode(bitand(t.property, 288230376151711744), 288230376151711744, 
              'YES', 'NO'),
       decode(bitand(t.property/4294967296, 134217728), 134217728, 'YES', 'NO'),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
         decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456), 
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED', 
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,  
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,   'FOR DML',
                              10,  'FOR QUERY LOW',
                              64,  'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       nls_collation_name(nvl(o.dflcollid, 16382)),
       decode(bitand(o.flags, 2147483648), 0, 'N', 2147483648, 'Y', 'N'),
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'MEMCOMPRESS FOR QUERY', 
             8200, 'MEMCOMPRESS FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- CONTAINERS_DEFAULT
       decode(bitand(t.property, power(2,72)), power(2,72), 'YES', 'NO'),
       -- CONTAINER_MAP
       decode(bitand(t.property, power(2,80)), power(2,80), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK
       decode(bitand(t.property, power(2,52)), power(2,52), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK_MAP
       decode(bitand(t.property, power(2,79)), power(2,79), 'YES', 'NO'),
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- CONTAINER_MAP_OBJECT 
       decode(bitand(t.property, power(2,87)), power(2,87), 'YES', 'NO'),
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
       -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.external_tab$ xt,
     sys."_CURRENT_EDITION_OBJ" o,
     sys.deferred_stg$ ds, sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, 
     x$ksppi ksppi, sys.imsvc$ svc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
  and bitand(t.property, power(2,65)) = 0 -- Do not show granular token sets
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
comment on table USER_TABLES is
'Description of the user''s own relational tables'
/
comment on column USER_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column USER_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column USER_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
comment on column USER_TABLES.CLUSTERING is
'Whether table has clustering clause or not'
/
comment on column USER_TABLES.ACTIVITY_TRACKING is
'ILM activity tracking mode'
/
comment on column USER_TABLES.DML_TIMESTAMP is
'ILM row modification or creation timestamp tracking mode'
/
comment on column USER_TABLES.HAS_IDENTITY is
'Whether the table has an identity column'
/
comment on column USER_TABLES.CONTAINER_DATA is
'An indicator of whether the table contains Container-specific data'
/
comment on column USER_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column USER_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column USER_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column USER_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column USER_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column USER_TABLES.DEFAULT_COLLATION is
'Default collation for the table'
/
comment on column USER_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column USER_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column USER_TABLES.CONTAINERS_DEFAULT is
'Whether the table is enabled for CONTAINERS() by default'
/
comment on column USER_TABLES.CONTAINER_MAP is 
'Whether the table is enabled for use with container_map database property'
/
comment on column USER_TABLES.EXTENDED_DATA_LINK is 
'Whether the table is enabled for fetching extended data link from Root'
/
comment on column USER_TABLES.EXTENDED_DATA_LINK_MAP is 
'Whether the table is enabled for use with extended data link map'
/
comment on column USER_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column USER_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column USER_TABLES.CONTAINER_MAP_OBJECT is 
'Whether the table is used as the value of container_map database property'
/
comment on column USER_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column USER_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column USER_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/

create or replace public synonym USER_TABLES for USER_TABLES
/
create or replace public synonym TABS for USER_TABLES
/
grant read on USER_TABLES to PUBLIC with grant option
/
create or replace view USER_OBJECT_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE, 
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),           
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                              decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
        decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456),
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED',
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,  
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10,  'FOR QUERY LOW',
                              64, 'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'MEMCOMPRESS FOR QUERY', 
             8200, 'MEMCOMPRESS FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
        -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.external_tab$ xt, sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu,
     sys.col$ tc, sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su,
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds, sys.imsvc$ svc
where o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
comment on table USER_OBJECT_TABLES is
'Description of the user''s own object tables'
/
comment on column USER_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table
entry belongs'
/
comment on column USER_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column USER_OBJECT_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column USER_OBJECT_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column USER_OBJECT_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column USER_OBJECT_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column USER_OBJECT_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column USER_OBJECT_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column USER_OBJECT_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column USER_OBJECT_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column USER_OBJECT_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column USER_OBJECT_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column USER_OBJECT_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column USER_OBJECT_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
create or replace public synonym USER_OBJECT_TABLES for USER_OBJECT_TABLES
/
grant read on USER_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view USER_ALL_TABLES
    (TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE,
     NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED, 
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN
from user_tables
union all
select TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN
from user_object_tables
/
comment on table USER_ALL_TABLES is
'Description of all object and relational tables owned by the user''s'
/
comment on column USER_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column USER_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column USER_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column USER_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column USER_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column USER_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column USER_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column USER_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column USER_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column USER_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column USER_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column USER_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column USER_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column USER_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column USER_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column USER_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column USER_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column USER_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column USER_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column USER_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column USER_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column USER_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column USER_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column USER_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column USER_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column USER_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column USER_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column USER_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column USER_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column USER_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column USER_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column USER_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column USER_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column USER_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column USER_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column USER_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column USER_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column USER_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column USER_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column USER_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column USER_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column USER_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column USER_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column USER_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column USER_ALL_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column USER_ALL_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column USER_ALL_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column USER_ALL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column USER_ALL_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column USER_ALL_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column USER_ALL_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column USER_ALL_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column USER_ALL_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column USER_ALL_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column USER_ALL_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column USER_ALL_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
create or replace public synonym USER_ALL_TABLES for USER_ALL_TABLES
/
grant read on USER_ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE, CLUSTERING,
     ACTIVITY_TRACKING, DML_TIMESTAMP, HAS_IDENTITY, CONTAINER_DATA,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, DEFAULT_COLLATION, DUPLICATED, SHARDED, EXTERNAL,
     CELLMEMORY, CONTAINERS_DEFAULT, CONTAINER_MAP, EXTENDED_DATA_LINK,
     EXTENDED_DATA_LINK_MAP, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME,
     CONTAINER_MAP_OBJECT, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select u.name, o.name,
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       decode(bitand(t.property, 64), 0, t.avgspc, null),
       t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),                             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES',
              decode(bitand(t.property, 32), 32, 'N/A', 'NO')),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',    
                 4398046511104,'MANUAL','DEFAULT'),
       decode(bitand(t.property, 18014398509481984), 18014398509481984, 
                     'YES', 'NO'),
       case when bitand(t.property, 1125899906842624) = 1125899906842624
                 then 'ROW ACCESS TRACKING'
            when bitand(t.property, 2251799813685248) = 2251799813685248
                 then 'SEGMENT ACCESS TRACKING'
       end,
       case when bitand(t.property, 844424930131968) = 844424930131968
                 then 'ROW CREATION/MODIFICATION'
            when bitand(t.property, 281474976710656) = 281474976710656
                 then 'ROW MODIFICATION'
            when bitand(t.property, 562949953421312) = 562949953421312
                 then 'ROW CREATION'
       end,
       decode(bitand(t.property, 288230376151711744), 288230376151711744, 
              'YES', 'NO'),
       decode(bitand(t.property/4294967296, 134217728), 134217728, 'YES', 'NO'),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
         decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456),
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED',
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10,  'FOR QUERY LOW',
                              64, 'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       nls_collation_name(nvl(o.dflcollid, 16382)),
       decode(bitand(o.flags, 2147483648), 0, 'N', 2147483648, 'Y', 'N'),
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'MEMCOMPRESS FOR QUERY', 
             8200, 'MEMCOMPRESS FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- CONTAINERS_DEFAULT
       decode(bitand(t.property, power(2,72)), power(2,72), 'YES', 'NO'),
       -- CONTAINER_MAP
       decode(bitand(t.property, power(2,80)), power(2,80), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK
       decode(bitand(t.property, power(2,52)), power(2,52), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK_MAP
       decode(bitand(t.property, power(2,79)), power(2,79), 'YES', 'NO'),
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- CONTAINER_MAP_OBJECT 
       decode(bitand(t.property, power(2,87)), power(2,87), 'YES', 'NO'),
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
       -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t,
     sys.external_tab$ xt, sys."_CURRENT_EDITION_OBJ" o,
     sys.obj$ cx, sys.user$ cu, 
     (select /*+ no_merge */ ksppcv.ksppstvl 
      from x$ksppcv ksppcv, x$ksppi ksppi
      where ksppi.ksppinm = '_dml_monitoring_enabled' and
            ksppi.indx = ksppcv.indx
     ) ksppcv, 
     sys.deferred_stg$ ds, sys.imsvc$ svc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.obj# = ds.obj# (+)
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         ora_check_sys_privilege (o.owner#, o.type#) = 1
      )
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and bitand(t.property, power(2,65)) = 0 -- Do not show granular token sets
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
comment on table ALL_TABLES is
'Description of relational tables accessible to the user'
/
comment on column ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column ALL_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
comment on column ALL_TABLES.CLUSTERING is
'Whether table has clustering clause or not'
/
comment on column ALL_TABLES.ACTIVITY_TRACKING is
'ILM activity tracking mode'
/
comment on column ALL_TABLES.DML_TIMESTAMP is
'ILM row modification or creation timestamp tracking mode'
/
comment on column ALL_TABLES.HAS_IDENTITY is
'Whether the table has an identity column'
/
comment on column ALL_TABLES.CONTAINER_DATA is
'An indicator of whether the table contains Container-specific data'
/
comment on column ALL_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column ALL_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column ALL_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column ALL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column ALL_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column ALL_TABLES.DEFAULT_COLLATION is
'Default collation for the table'
/
comment on column ALL_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column ALL_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column ALL_TABLES.CONTAINERS_DEFAULT is
'Whether the table is enabled for CONTAINERS() by default'
/
comment on column ALL_TABLES.CONTAINER_MAP is 
'Whether the table is enabled for use with container_map database property'
/
comment on column ALL_TABLES.EXTENDED_DATA_LINK is 
'Whether the table is enabled for fetching extended data link from Root'
/
comment on column ALL_TABLES.EXTENDED_DATA_LINK_MAP is 
'Whether the table is enabled for use with extended data link map'
/
comment on column ALL_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column ALL_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column ALL_TABLES.CONTAINER_MAP_OBJECT is 
'Whether the table is used as the value of container_map database property'
/
comment on column ALL_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column ALL_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column ALL_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
create or replace public synonym ALL_TABLES for ALL_TABLES
/
grant read on ALL_TABLES to PUBLIC with grant option
/
create or replace view ALL_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
         decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456),
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED',
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10,  'FOR QUERY LOW',
                              64, 'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'MEMCOMPRESS FOR QUERY', 
             8200, 'MEMCOMPRESS FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
        -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.external_tab$ xt, sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu,
     sys.col$ tc, sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su,
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds, sys.imsvc$ svc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.type# <> 10
  and ty.owner# = tu.user#
  and t.bobj# = co.obj# (+)
  and t.obj# = ds.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
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
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
comment on table ALL_OBJECT_TABLES is
'Description of all object tables accessible to the user'
/
comment on column ALL_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column ALL_OBJECT_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column ALL_OBJECT_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column ALL_OBJECT_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column ALL_OBJECT_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column ALL_OBJECT_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column ALL_OBJECT_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
create or replace public synonym ALL_OBJECT_TABLES for ALL_OBJECT_TABLES
/
comment on column ALL_OBJECT_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
grant read on ALL_OBJECT_TABLES to PUBLIC with grant option
/
create or replace view ALL_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE, 
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE, 
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN
from all_tables
union all
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN
from all_object_tables
/
comment on table ALL_ALL_TABLES is
'Description of all object and relational tables accessible to the user'
/
comment on column ALL_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column ALL_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column ALL_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column ALL_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column ALL_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column ALL_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column ALL_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column ALL_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column ALL_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column ALL_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column ALL_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column ALL_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column ALL_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column ALL_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column ALL_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column ALL_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column ALL_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column ALL_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column ALL_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column ALL_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column ALL_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column ALL_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column ALL_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column ALL_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column ALL_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column ALL_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column ALL_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column ALL_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column ALL_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column ALL_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column ALL_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column ALL_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column ALL_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column ALL_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column ALL_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column ALL_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column ALL_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column ALL_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column ALL_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column ALL_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column ALL_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column ALL_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column ALL_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column ALL_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column ALL_ALL_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column ALL_ALL_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column ALL_ALL_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column ALL_ALL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column ALL_ALL_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column ALL_ALL_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column ALL_ALL_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column ALL_ALL_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column ALL_ALL_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column ALL_ALL_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column ALL_ALL_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column ALL_ALL_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
create or replace public synonym ALL_ALL_TABLES for ALL_ALL_TABLES
/
grant read on ALL_ALL_TABLES to PUBLIC with grant option
/
create or replace view DBA_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR,DROPPED, READ_ONLY,
     SEGMENT_CREATED,RESULT_CACHE, CLUSTERING,
     ACTIVITY_TRACKING, DML_TIMESTAMP, HAS_IDENTITY, CONTAINER_DATA,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, DEFAULT_COLLATION, DUPLICATED, SHARDED, EXTERNAL,
     CELLMEMORY, CONTAINERS_DEFAULT, CONTAINER_MAP, EXTENDED_DATA_LINK,
     EXTENDED_DATA_LINK_MAP, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME,
     CONTAINER_MAP_OBJECT, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       decode(bitand(t.property, 17179869184), 17179869184, 
                     ds.initial_stg * ts.blocksize,
                     s.iniexts * ts.blocksize), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.next_stg * ts.blocksize, 
              s.extsize * ts.blocksize),
       decode(bitand(t.property, 17179869184), 17179869184, 
              ds.minext_stg, s.minexts), 
       decode(bitand(t.property, 17179869184), 17179869184,
              ds.maxext_stg, s.maxexts),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184, 
                       decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                       decode(s.lists, 0, 1, s.lists)))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, 
                decode(bitand(t.property, 17179869184), 17179869184,
                       decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                       decode(s.groups, 0, 1, s.groups)))),
       decode(bitand(t.property, 32+64), 0,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO'), null),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES',
              decode(bitand(t.property, 1), 0, 'NO', 'YES')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 3), 
                            1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 12)/4, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
              decode(bitand(decode(bitand(t.property, 17179869184), 17179869184, 
                            ds.bfp_stg, s.cachehint), 48)/16, 
                            1, 'KEEP', 2, 'NONE', 'DEFAULT')),             
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.trigflag, 2097152), 2097152, 'YES',
              decode(bitand(t.property, 32), 32, 'N/A', 'NO')),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       decode(bitand(t.property,16492674416640),2199023255552,'FORCE',     
                4398046511104,'MANUAL','DEFAULT'),
       decode(bitand(t.property, 18014398509481984), 18014398509481984, 
                     'YES', 'NO'),
       case when bitand(t.property, 1125899906842624) = 1125899906842624
                 then 'ROW ACCESS TRACKING'
            when bitand(t.property, 2251799813685248) = 2251799813685248
                 then 'SEGMENT ACCESS TRACKING'
        end,
       case when bitand(t.property, 844424930131968) = 844424930131968
                 then 'ROW CREATION/MODIFICATION'
            when bitand(t.property, 281474976710656) = 281474976710656
                 then 'ROW MODIFICATION'
            when bitand(t.property, 562949953421312) = 562949953421312
                 then 'ROW CREATION'
        end,
       decode(bitand(t.property, 288230376151711744), 288230376151711744, 
              'YES', 'NO'),
       decode(bitand(t.property/4294967296, 134217728), 134217728, 'YES', 'NO'),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
         decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456),
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED',
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10,  'FOR QUERY LOW',
                              64, 'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       nls_collation_name(nvl(o.dflcollid, 16382)),
       decode(bitand(o.flags, 2147483648), 0, 'N', 2147483648, 'Y', 'N'), 
       decode(bitand(o.flags, 1073741824), 0, 'N', 1073741824, 'Y', 'N'),
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'MEMCOMPRESS FOR QUERY', 
             8200, 'MEMCOMPRESS FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- CONTAINERS_DEFAULT
       decode(bitand(t.property, power(2,72)), power(2,72), 'YES', 'NO'),
       -- CONTAINER_MAP
       decode(bitand(t.property, power(2,80)), power(2,80), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK
       decode(bitand(t.property, power(2,52)), power(2,52), 'YES', 'NO'),
       -- EXTENDED_DATA_LINK_MAP
       decode(bitand(t.property, power(2,79)), power(2,79), 'YES', 'NO'),
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- CONTAINER_MAP_OBJECT 
       decode(bitand(t.property, power(2,87)), power(2,87), 'YES', 'NO'),
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
       -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t,
     sys.external_tab$ xt, sys."_CURRENT_EDITION_OBJ" o,
     sys.obj$ cx, sys.user$ cu, x$ksppcv ksppcv, x$ksppi ksppi, 
     sys.deferred_stg$ ds, sys.imsvc$ svc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 0
  and bitand(o.flags, 128) = 0
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.obj# = ds.obj# (+)
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
  and bitand(t.property, power(2,65)) = 0 -- Do not show granular token sets
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
create or replace public synonym DBA_TABLES for DBA_TABLES
/
grant select on DBA_TABLES to select_catalog_role
/
comment on table DBA_TABLES is
'Description of all relational tables in the database'
/
comment on column DBA_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_TABLES.READ_ONLY is
'Whether table is read only or not'
/
comment on column DBA_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column DBA_TABLES.RESULT_CACHE is
'The result cache mode annotation for the table'
/
comment on column DBA_TABLES.CLUSTERING is
'Whether table has clustering clause or not'
/
comment on column DBA_TABLES.ACTIVITY_TRACKING is
'ILM activity tracking mode'
/
comment on column DBA_TABLES.DML_TIMESTAMP is
'ILM row modification or creation timestamp tracking mode'
/
comment on column DBA_TABLES.HAS_IDENTITY is
'Whether the table has an identity column'
/
comment on column DBA_TABLES.CONTAINER_DATA is
'An indicator of whether the table contains Container-specific data'
/
comment on column DBA_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column DBA_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column DBA_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column DBA_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column DBA_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column DBA_TABLES.DEFAULT_COLLATION is
'Default collation for the table'
/
comment on column DBA_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column DBA_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column DBA_TABLES.CONTAINERS_DEFAULT is
'Whether the table is enabled for CONTAINERS() by default'
/
comment on column DBA_TABLES.CONTAINER_MAP is 
'Whether the table is enabled for use with container_map database property'
/
comment on column DBA_TABLES.EXTENDED_DATA_LINK is 
'Whether the table is enabled for fetching extended data link from Root'
/
comment on column DBA_TABLES.EXTENDED_DATA_LINK_MAP is 
'Whether the table is enabled for use with extended data link map'
/
comment on column DBA_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column DBA_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column DBA_TABLES.CONTAINER_MAP_OBJECT is 
'Whether the table is used as the value of container_map database property'
/
comment on column DBA_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column DBA_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast data ingestion'
/
comment on column DBA_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
execute CDBView.create_cdbview(false,'SYS','DBA_TABLES','CDB_TABLES');
grant select on SYS.CDB_TABLES to select_catalog_role
/
create or replace public synonym CDB_TABLES for SYS.CDB_TABLES
/

create or replace view DBA_OBJECT_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select u.name, o.name, 
       decode(bitand(t.property,2151678048), 0, ts.name, 
              decode(t.ts#, 0, null, ts.name)),
       decode(bitand(t.property, 1024), 0, null, co.name),
       decode((bitand(t.property, 512)+bitand(t.flags, 536870912)),
              0, null, co.name),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       decode(bitand(t.property, 32+64), 0, mod(t.pctfree$, 100), 64, 0, null),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
          decode(bitand(t.property, 32+64), 0, t.pctused$, 64, 0, null)),
       decode(bitand(t.property, 32), 0, t.initrans, null),
       decode(bitand(t.property, 32), 0, t.maxtrans, null),
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
         decode(bitand(o.flags, 2), 2, 1, decode(s.groups, 0, 1, s.groups))),
       decode(bitand(t.property, 32), 32, null,
                decode(bitand(t.flags, 32), 0, 'YES', 'NO')),
       decode(bitand(t.flags,1), 0, 'Y', 1, 'N', '?'),
       t.rowcnt,
       decode(bitand(t.property, 64), 0, t.blkcnt, null),
       decode(bitand(t.property, 64), 0, t.empcnt, null),
       t.avgspc, t.chncnt, t.avgrln, t.avgspc_flb,
       decode(bitand(t.property, 64), 0, t.flbcnt, null),
       lpad(decode(t.degree, 32767, 'DEFAULT', nvl(t.degree,1)),10),
       lpad(decode(t.instances, 32767, 'DEFAULT', nvl(t.instances,1)),10),
       lpad(decode(bitand(t.flags, 8), 8, 'Y', 'N'),5),
       decode(bitand(t.flags, 6), 0, 'ENABLED', 'DISABLED'),
       t.samplesize, t.analyzetime,
       decode(bitand(t.property, 32), 32, 'YES', 'NO'),
       decode(bitand(t.property, 64), 64, 'IOT',
               decode(bitand(t.property, 512), 512, 'IOT_OVERFLOW',
               decode(bitand(t.flags, 536870912), 536870912, 'IOT_MAPPING', null))),
       decode(bitand(t.property, 4096), 4096, 'USER-DEFINED',
                                              'SYSTEM GENERATED'),
       nvl2(ac.synobj#, su.name, tu.name),
       nvl2(ac.synobj#, so.name, ty.name),
       decode(bitand(o.flags, 2), 0, 'N', 2, 'Y', 'N'),
       decode(bitand(o.flags, 16), 0, 'N', 16, 'Y', 'N'),
       decode(bitand(t.property, 8192), 8192, 'YES', 'NO'),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 3), 1, 'KEEP', 2, 'RECYCLE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 12)/4, 1, 'KEEP', 2, 'NONE',
             'DEFAULT')),
       decode(bitand(o.flags, 2), 2, 'DEFAULT',
             decode(bitand(s.cachehint, 48)/16, 1, 'KEEP', 2, 'NONE', 
             'DEFAULT')),
       decode(bitand(t.flags, 131072), 131072, 'ENABLED', 'DISABLED'),
       decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
       decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 2), 0, NULL,
          decode(bitand(t.property, 8388608), 8388608,
                 'SYS$SESSION', 'SYS$TRANSACTION')),
       decode(bitand(t.flags, 1024), 1024, 'ENABLED', 'DISABLED'),
       decode(bitand(o.flags, 2), 2, 'NO',
           decode(bitand(t.property, 2147483648), 2147483648, 'NO',
              decode(ksppcv.ksppstvl, 'TRUE', 'YES', 'NO'))),
       decode(bitand(t.property, 1024), 0, null, cu.name),
       decode(bitand(t.flags, 8388608), 8388608, 'ENABLED', 'DISABLED'),
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then 
          decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
          decode(bitand(ds.flags_stg, 4), 4, 
          case when bitand(ds.cmpflag_stg, 3) = 1 then 'BASIC'
               when bitand(ds.cmpflag_stg, 3) = 2 then 'ADVANCED'
               else concat(decode(ds.cmplvl_stg, 1, 'QUERY LOW',
                                                 2, 'QUERY HIGH',
                                                 3, 'ARCHIVE LOW',
                                                    'ARCHIVE HIGH'),
                           decode(bitand(ds.flags_stg, 524288), 524288,
                                  ' ROW LEVEL LOCKING', '')) end,
               null)
       else
         decode(bitand(s.spare1, 2048), 0, null,
         case when bitand(s.spare1, 16777216) = 16777216 
                   then 'ADVANCED'
              when bitand(s.spare1, 100663296) = 33554432  -- 0x2000000
                   then concat('QUERY LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 67108864  -- 0x4000000
                   then concat('QUERY HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 100663296) = 100663296 -- 0x2000000+0x4000000
                   then concat('ARCHIVE LOW',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              when bitand(s.spare1, 134217728) = 134217728 -- 0x8000000
                   then concat('ARCHIVE HIGH',
                               decode(bitand(s.spare1, 2147483648),
                                      2147483648, ' ROW LEVEL LOCKING', ''))
              else 'BASIC' end)
       end,
       decode(bitand(o.flags, 128), 128, 'YES', 'NO'),
       decode(bitand(t.property, 17179869184), 17179869184, 'NO',
              decode(bitand(t.property, 32), 32, 'N/A', 'YES')),
       -- INMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
         decode(bitand(xt.property,16), 16, 'ENABLED', 'DISABLED')
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- flags/imcflag_stg (stgdef.h)
         decode(bitand(ds.flags_stg, 6291456),
             2097152, 'ENABLED',
             4194304, 'DISABLED', 'DISABLED')
       else
         -- ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 70373039144960),
             4294967296,     'ENABLED',
             70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 4), 4,
                decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 7936),
                256, 'NONE',
                512, 'LOW',
                1024, 'MEDIUM',
                2048, 'HIGH',
                4096, 'CRITICAL', 'UNKNOWN'), null),
                'NONE'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 34359738368), 34359738368,
                decode(bitand(s.spare1, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null)
       end,
       -- INMEMORY_DISTRIBUTE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 1), 1,
                       decode(bitand(ds.imcflag_stg, (16+32)),
                              16,  'BY ROWID RANGE',
                              32,  'BY PARTITION',
                              48,  'BY SUBPARTITION',
                               0,  'AUTO'),
                  null), null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 8589934592), 8589934592,
                        decode(bitand(s.spare1, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 2147483648 ) = 2147483648) then
             decode(bitand(xt.property, (16+32+64+128)),
                         (16+32), 'NO MEMCOMPRESS',
                         (16+64), 'FOR DML',
                      (16+32+64), 'FOR QUERY LOW',
                        (16+128), 'FOR QUERY HIGH',
                     (16+128+32), 'FOR CAPACITY LOW',
                     (16+128+64), 'FOR CAPACITY HIGH', NULL)
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10,  'FOR QUERY LOW',
                              64, 'FOR QUERY HIGH',
                              66, 'FOR CAPACITY LOW',
                              72, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null)
       end,
       -- INMEMORY_DUPLICATE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              'UNKNOWN'),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null)
       end,
       decode(bitand(t.property, 2147483648), 2147483648, 'YES', 'NO'),
       -- CELLMEMORY
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         -- deferred segment: stgccflags (stgdef.h)
         decode(ccflag_stg, 
             8194, 'NO MEMCOMPRESS',
             8196, 'FOR QUERY', 
             8200, 'FOR CAPACITY',
             16384, 'DISABLED', null)
       else
         -- created segment: ktsscflg (ktscts.h)
         decode(bitand(s.spare1, 4362862139015168),
              281474976710656, 'DISABLED',
              703687441776640, 'NO MEMCOMPRESS',
             1266637395197952, 'MEMCOMPRESS FOR QUERY', 
             2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'UNKNOWN'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(t.property, 32) = 32) then
         null
       when (bitand(t.property, 17179869184) = 17179869184) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       svc.svcname, null),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       svc.svcname, null),
                null)
       end,
       -- MEMOPTIMIZE_READ
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,91)), power(2,91),
                        'ENABLED', 'DISABLED')
       end,
       -- MEMOPTIMIZE_WRITE
       case when bitand(t.property, 32) = 32 
              then 'N/A'
       else
          decode(bitand(t.property, power(2,92)), power(2,92),
                        'ENABLED', 'DISABLED')
       end,
        -- HAS_SENSITIVE_COLUMN 
       decode(bitand(t.property, power(2,89)), power(2,89), 'YES', 'NO')
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.obj$ co, sys.tab$ t, sys.obj$ o,
     sys.external_tab$ xt, sys.coltype$ ac, sys.obj$ ty, sys."_BASE_USER" tu,
     sys.col$ tc, sys.obj$ cx, sys.user$ cu, sys.obj$ so, sys."_BASE_USER" su,
     x$ksppcv ksppcv, x$ksppi ksppi, sys.deferred_stg$ ds, sys.imsvc$ svc
where o.owner# = u.user#
  and o.obj# = t.obj#
  and t.obj# = xt.obj# (+)
  and bitand(t.property, 1) = 1
  and bitand(o.flags, 128) = 0
  and t.obj# = tc.obj#
  and tc.name = 'SYS_NC_ROWINFO$'
  and tc.obj# = ac.obj#
  and tc.intcol# = ac.intcol#
  and ac.toid = ty.oid$
  and ty.owner# = tu.user#
  and ty.type# <> 10
  and t.bobj# = co.obj# (+)
  and t.ts# = ts.ts#
  and t.file# = s.file# (+)
  and t.block# = s.block# (+)
  and t.ts# = s.ts# (+)
  and t.obj# = ds.obj# (+)
  and t.dataobj# = cx.obj# (+)
  and cx.owner# = cu.user# (+)
  and ac.synobj# = so.obj# (+)
  and so.owner# = su.user# (+)
  and ksppi.indx = ksppcv.indx
  and ksppi.ksppinm = '_dml_monitoring_enabled'
  and t.obj# = svc.obj# (+)
  and svc.subpart#(+) is null
/
create or replace public synonym DBA_OBJECT_TABLES for DBA_OBJECT_TABLES
/
grant select on DBA_OBJECT_TABLES to select_catalog_role
/
comment on table DBA_OBJECT_TABLES is
'Description of all object tables in the database'
/
comment on column DBA_OBJECT_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_OBJECT_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_OBJECT_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_OBJECT_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_OBJECT_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_OBJECT_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_OBJECT_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_OBJECT_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_OBJECT_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_OBJECT_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_OBJECT_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_OBJECT_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_OBJECT_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_OBJECT_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_OBJECT_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_OBJECT_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_OBJECT_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_OBJECT_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_OBJECT_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_OBJECT_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_OBJECT_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_OBJECT_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_OBJECT_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_OBJECT_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_OBJECT_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_OBJECT_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_OBJECT_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_OBJECT_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_OBJECT_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_OBJECT_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYSTEM GENERATED'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_OBJECT_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_OBJECT_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_OBJECT_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_OBJECT_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_OBJECT_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_OBJECT_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_OBJECT_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_OBJECT_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_OBJECT_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_OBJECT_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_OBJECT_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_OBJECT_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_OBJECT_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_OBJECT_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_OBJECT_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column DBA_OBJECT_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column DBA_OBJECT_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column DBA_OBJECT_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column DBA_OBJECT_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column DBA_OBJECT_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column DBA_OBJECT_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column DBA_OBJECT_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/
execute CDBView.create_cdbview(false,'SYS','DBA_OBJECT_TABLES','CDB_OBJECT_TABLES');
grant select on SYS.CDB_OBJECT_TABLES to select_catalog_role
/
create or replace public synonym CDB_OBJECT_TABLES for SYS.CDB_OBJECT_TABLES
/

create or replace view DBA_ALL_TABLES
    (OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS, 
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, OBJECT_ID_TYPE,
     TABLE_TYPE_OWNER, TABLE_TYPE, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED, 
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN)
as
select OWNER, TABLE_NAME, TABLESPACE_NAME, CLUSTER_NAME, IOT_NAME, STATUS,
     PCT_FREE, PCT_USED,
     INI_TRANS, MAX_TRANS,
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, LOGGING,
     BACKED_UP, NUM_ROWS, BLOCKS, EMPTY_BLOCKS,
     AVG_SPACE, CHAIN_CNT, AVG_ROW_LEN,
     AVG_SPACE_FREELIST_BLOCKS, NUM_FREELIST_BLOCKS,
     DEGREE, INSTANCES, CACHE, TABLE_LOCK,
     SAMPLE_SIZE, LAST_ANALYZED, PARTITIONED,
     IOT_TYPE, NULL, NULL, NULL, TEMPORARY, SECONDARY, NESTED,
     BUFFER_POOL, FLASH_CACHE,
     CELL_FLASH_CACHE, ROW_MOVEMENT,
     GLOBAL_STATS, USER_STATS, DURATION, SKIP_CORRUPT, MONITORING,
     CLUSTER_OWNER, DEPENDENCIES, COMPRESSION, COMPRESS_FOR, DROPPED,
     SEGMENT_CREATED, 
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
     INMEMORY_DUPLICATE, EXTERNAL, CELLMEMORY, INMEMORY_SERVICE,
     INMEMORY_SERVICE_NAME, MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE,
     HAS_SENSITIVE_COLUMN
from dba_tables
union all
select * from dba_object_tables
/
create or replace public synonym DBA_ALL_TABLES for DBA_ALL_TABLES
/
grant select on DBA_ALL_TABLES to select_catalog_role
/
comment on table DBA_ALL_TABLES is
'Description of all object and relational tables in the database'
/
comment on column DBA_ALL_TABLES.OWNER is
'Owner of the table'
/
comment on column DBA_ALL_TABLES.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ALL_TABLES.TABLESPACE_NAME is
'Name of the tablespace containing the table'
/
comment on column DBA_ALL_TABLES.CLUSTER_NAME is
'Name of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.IOT_NAME is
'Name of the index-only table, if any, to which the overflow or mapping table entry belongs'
/
comment on column DBA_ALL_TABLES.STATUS is
'Status of the table will be UNUSABLE if a previous DROP TABLE operation failed,
VALID otherwise'
/
comment on column DBA_ALL_TABLES.PCT_FREE is
'Minimum percentage of free space in a block'
/
comment on column DBA_ALL_TABLES.PCT_USED is
'Minimum percentage of used space in a block'
/
comment on column DBA_ALL_TABLES.INI_TRANS is
'Initial number of transactions'
/
comment on column DBA_ALL_TABLES.MAX_TRANS is
'Maximum number of transactions'
/
comment on column DBA_ALL_TABLES.INITIAL_EXTENT is
'Size of the initial extent in bytes'
/
comment on column DBA_ALL_TABLES.NEXT_EXTENT is
'Size of secondary extents in bytes'
/
comment on column DBA_ALL_TABLES.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_ALL_TABLES.PCT_INCREASE is
'Percentage increase in extent size'
/
comment on column DBA_ALL_TABLES.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_ALL_TABLES.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_ALL_TABLES.LOGGING is
'Logging attribute'
/
comment on column DBA_ALL_TABLES.BACKED_UP is
'Has table been backed up since last modification?'
/
comment on column DBA_ALL_TABLES.NUM_ROWS is
'The number of rows in the table'
/
comment on column DBA_ALL_TABLES.BLOCKS is
'The number of used blocks in the table'
/
comment on column DBA_ALL_TABLES.EMPTY_BLOCKS is
'The number of empty (never used) blocks in the table'
/
comment on column DBA_ALL_TABLES.AVG_SPACE is
'The average available free space in the table'
/
comment on column DBA_ALL_TABLES.CHAIN_CNT is
'The number of chained rows in the table'
/
comment on column DBA_ALL_TABLES.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_ALL_TABLES.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_ALL_TABLES.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_ALL_TABLES.DEGREE is
'The number of threads per instance for scanning the table'
/
comment on column DBA_ALL_TABLES.INSTANCES is
'The number of instances across which the table is to be scanned'
/
comment on column DBA_ALL_TABLES.CACHE is
'Whether the table is to be cached in the buffer cache'
/
comment on column DBA_ALL_TABLES.TABLE_LOCK is
'Whether table locking is enabled or disabled'
/
comment on column DBA_ALL_TABLES.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_ALL_TABLES.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_ALL_TABLES.PARTITIONED is
'Is this table partitioned? YES or NO'
/
comment on column DBA_ALL_TABLES.IOT_TYPE is
'If index-only table, then IOT_TYPE is IOT or IOT_OVERFLOW or IOT_MAPPING else NULL'
/
comment on column DBA_ALL_TABLES.OBJECT_ID_TYPE is
'If user-defined OID, then USER-DEFINED, else if system generated OID, then SYST
EM GENERATED'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE_OWNER is
'Owner of the type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TABLE_TYPE is
'Type of the table if the table is an object table'
/
comment on column DBA_ALL_TABLES.TEMPORARY is
'Can the current session only see data that it place in this object itself?'
/
comment on column DBA_ALL_TABLES.SECONDARY is
'Is this table object created as part of icreate for domain indexes?'
/
comment on column DBA_ALL_TABLES.NESTED is
'Is the table a nested table?'
/
comment on column DBA_ALL_TABLES.BUFFER_POOL is
'The default buffer pool to be used for table blocks'
/
comment on column DBA_ALL_TABLES.FLASH_CACHE is
'The default flash cache hint to be used for table blocks'
/
comment on column DBA_ALL_TABLES.CELL_FLASH_CACHE is
'The default cell flash cache hint to be used for table blocks'
/
comment on column DBA_ALL_TABLES.ROW_MOVEMENT is
'Whether partitioned row movement is enabled or disabled'
/
comment on column DBA_ALL_TABLES.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_ALL_TABLES.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_ALL_TABLES.DURATION is
'If temporary table, then duration is sys$session or sys$transaction else NULL'
/
comment on column DBA_ALL_TABLES.SKIP_CORRUPT is
'Whether skip corrupt blocks is enabled or disabled'
/
comment on column DBA_ALL_TABLES.MONITORING is
'Should we keep track of the amount of modification?'
/
comment on column DBA_ALL_TABLES.CLUSTER_OWNER is
'Owner of the cluster, if any, to which the table belongs'
/
comment on column DBA_ALL_TABLES.DEPENDENCIES is
'Should we keep track of row level dependencies?'
/
comment on column DBA_ALL_TABLES.COMPRESSION is
'Whether table compression is enabled or not'
/
comment on column DBA_ALL_TABLES.COMPRESS_FOR is
'Compress what kind of operations'
/
comment on column DBA_ALL_TABLES.DROPPED is
'Whether table is dropped and is in Recycle Bin'
/
comment on column DBA_ALL_TABLES.SEGMENT_CREATED is 
'Whether the table segment is created or not'
/
comment on column DBA_ALL_TABLES.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column DBA_ALL_TABLES.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column DBA_ALL_TABLES.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column DBA_ALL_TABLES.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column DBA_ALL_TABLES.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column DBA_ALL_TABLES.EXTERNAL is
'Whether the table is an  external table or not'
/
comment on column DBA_ALL_TABLES.CELLMEMORY is
'Cell columnar cache'
/
comment on column DBA_ALL_TABLES.INMEMORY_SERVICE is
'How the in-memory columnar store object is distributed for service'
/
comment on column DBA_ALL_TABLES.INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store object is distributed'
/
comment on column DBA_ALL_TABLES.MEMOPTIMIZE_READ is 
'Whether the table is enabled for Fast Key Based Access'
/
comment on column DBA_ALL_TABLES.MEMOPTIMIZE_WRITE is 
'Whether the table is enabled for Fast Data Ingestion'
/
comment on column DBA_ALL_TABLES.HAS_SENSITIVE_COLUMN is
'Whether the table has one or more sensitive columns'
/

execute CDBView.create_cdbview(false,'SYS','DBA_ALL_TABLES','CDB_ALL_TABLES');
grant select on SYS.CDB_ALL_TABLES to select_catalog_role
/
create or replace public synonym CDB_ALL_TABLES for SYS.CDB_ALL_TABLES
/

@?/rdbms/admin/sqlsessend.sql

 
