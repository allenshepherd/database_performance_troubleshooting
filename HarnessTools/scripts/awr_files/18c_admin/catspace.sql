Rem $Header: rdbms/admin/catspace.sql /main/124 2016/05/20 18:49:00 drosash Exp $
Rem
Rem catspace.sql
Rem
Rem Copyright (c) 1998, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catspace.sql - CATalog SPACE management 
Rem
Rem    DESCRIPTION
Rem      declares all space management views and includes relevant space
Rem      management related packages.
Rem
Rem    NOTES
Rem      currently dbms_space is in dbmsutil.sql - we should probably move 
Rem      that here.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catspace.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catspace.sql
Rem SQL_PHASE: CATSPACE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    drosash     05/11/16 - Bug 23245222: change RIM for LEAF
Rem    drosash     02/09/16 - Bug 22096152: make dba_temp_files to join with ts$
Rem    nrcorcor    01/04/16 - Bug 22493242 - field chunk_tablespace missing
Rem                           from user_tablespaces
Rem    smuthuli    12/02/15 - 20733052: Fix objname char length for long
Rem                           identifiers
Rem    rmacnico    12/01/15 - Bug 22293392: change cachecompress to memcompress
Rem    rmacnico    11/24/15 - Bug 22186707: def_cellcache in user_tablespaces
Rem    drosash     11/20/15 - Bug 22271488: Redefinition of DBA_TEMP_FREE_SPACE
Rem    jerrede     08/28/15 - Remove catctl tags sql fails in database versions
Rem                           lower than 12
Rem    drosash     08/24/15 - Bug 21611780: Replace dba_temp_files with 
Rem                           dba_temp_files_inst
Rem    jerrede     08/18/15 - Add Tags to Generate Upgrade Sql
Rem    nrcorcor    08/04/15 - Bug 20865214 - newly added datafile not tracked 
Rem    drosash     07/17/15 - Bug 21389839: add view dba_temp_files_inst
Rem    aditigu     07/06/15 - Bug 21437329: add column for inmemory for service
Rem    smuthuli    06/28/15 - 32679: Ghost Data Removal
Rem    smuthuli    04/16/15 - Add objn to sys_dba_segs view
Rem    jcanovi     04/14/15 - lrg-15926632: do not show binary xml token sets
Rem    rmacnico    03/15/15 - Proj 47506: CELLCACHE
Rem    ankikuma    02/17/15 - Add DEF_INDEX_COMPRESSION and INDEX_COMPRESS_FOR
Rem                           to DBA_TABLESPACES and USER_TABLESPACES
Rem    awitkows    02/16/15 - correct *_tablespaces
Rem    shrgauta    01/28/15 - Bug 10173496, add table wri$_segadv_attrib
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    jkrismer    10/06/14 - bug 19529472 ignore ora-955 
Rem    smuthuli    09/15/14 - Bug 13539672/Project 41272 lost write protection
Rem    awitkows    06/10/14 - Proj 47411: local temp tablespaces
Rem    garysmit    04/10/14 - Bug 18385644: IMC syntax changes
Rem    andmuell    01/28/14 - bug18059873: from 12.1 OLTP compress_for becomes
Rem                           ADVANCED
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jekamp      11/22/13 - do not display NO INMEMORY in INMEMORY_DISTRIBUTE
Rem    jekamp      09/30/13 - Project 35591: New IMC syntax
Rem    weizhang    08/22/13 - bug 17342465: fix DBA_UNDO_EXTENTS for CDB
Rem                           skip ts with KTT_MISSING_TRANSPORT flag
Rem    xha         08/20/13 - Update IMC level flags
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    xha         06/06/13 - Bug 16829223: IMC level flags and map by flags
Rem    jekamp      03/01/13 - IMC preload flag
Rem    kdusanj     01/25/13 - Bug 15996460: Removing hints from user_free_space
Rem                           and dba_free_space to improve query performance
Rem    jkrismer    12/28/12 - Bug 13814203 ktsapsblk and 8258529 ktsapsext
Rem    weizhang    10/31/12 - bug 14832256: add con_id checking predicate
Rem                           in dba_temp_free_space
Rem    smuthuli    10/26/12 - rename ilmstat to heat map stat
Rem    smuthuli    09/25/12 - Heatmap Top N objects and tablespaces support
Rem    smuthuli    07/22/12 - ILM stats
Rem    smuthuli    06/19/12 - ILM Stat Segment
Rem    jekamp      05/09/12 - extend seg$ and ts$ flags to ub8
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gravipat    12/28/11 - lrg 6606340: Push con_id predicate into the sub
Rem                           query in dba_data_files & dba_temp_files
Rem    anthkim     12/12/11 - In-Memory Columnar Snapshot Store
Rem    teclee      08/23/11 - Add HCC row level locking info on COMPRESS_FOR
Rem    gaggoel     05/02/11 - DBA_TEMP_FREE_SPACE view correction for rac setup
Rem    traney      03/31/11 - 35209: long identifiers dictionary upgrade
Rem    gravipat    03/11/11 - change dba_data_files, dba_temp_files to show
Rem                           files that belong to the current container only
Rem    gaggoel     01/27/11 - updating the comment for MAXBYTES and MAXBLOCKS
Rem    rmacnico    06/11/09 - ARCHIVE LOW/HIGH
Rem    rmacnico    04/14/09 - Bug 8360974: dba_tables and AdvCmp
Rem    adalee      03/04/09  - new seg$ cachehint values
Rem    shsong      02/12/09  - Bug 8251884: add online/offline status to
Rem                            DBA_TEMP_FILES
Rem    weizhang    12/04/08  - bug 6658672: ts alert not considering disk free
Rem                            space
Rem    skiyer      11/18/08 -  7499672:correct missing predicate in
Rem                           DBA_FREE_SPACE_COALESCED_TMP3
Rem    weizhang    02/19/08 - storage clause INITIAL/NEXT for ASSM segment
Rem    bemeng      11/13/07 - use seg$ to get space usage in ts_quotas views
Rem    skiyer      08/21/07 - 6084512:Filter dropped undo seg from
Rem                           dba_undo_extents
Rem    bemeng      07/10/07 - dba_temp_free_space: group sort seg info by ts
Rem    bemeng      06/25/07 - dba_temp_free_space: add outer join
Rem    vmarwah     05/23/07 - Compress for operation in *_TABLESPACES
Rem    bemeng      04/11/07 - move advisor related segments to sysaux tbs
Rem    smuthuli    03/08/07 - securefile name changes
Rem    slynn       10/12/06 - smartfile->securefile
Rem    skiyer      10/09/06 - 5527591:Include filespchdr blocks in  tbs_metrics
Rem    skiyer      09/28/06 - 5549540:Deduct recyclebin object from tbs_metrics
Rem    bemeng      08/25/06 - fix new temp space view
Rem    adalee      08/07/06 - add ENCRYPTED column to *_TABLESPACES
Rem    atsukerm    04/03/06 - add predicate_evaluation column to tablespaces 
Rem                           family 
Rem    bemeng      02/23/06 - create temp space views
Rem    smuthuli    03/09/06 - project 18567: securefiles
Rem    mabhatta    05/30/06 - adding SMU11 support to dba_undo_segments 
Rem    weizhang    03/23/06 - bug 5029334: speed up dba_extents query
Rem    skiyer      03/13/06 - 5083393:DBA_FREE_SPACE change for file_id 
Rem                           correction 
Rem    jklebane    11/03/05 - #(4702510). Remove join order hints from 
Rem                           dba_extents 
Rem    weizhang    05/05/05 - speed up dba_auto_segadv_ctl query
Rem    nireland    02/26/05 - Add hints to user_free_space for bitmapped
Rem                           recyclebin. #4058932
Rem    nireland    02/21/05 - Add recyclebin to dba_free_space_coalesced. 
Rem                           #4069128 
Rem    nireland    12/20/04 - Add dropped tbs column for quotas. #2856726 
Rem    smuthuli    12/02/04 - move space quota views in here 
Rem    nireland    12/06/04 - Fix EM / sys_dba_segs problem. #3965060 
Rem    smuthuli    06/15/04 - speed up asa_recommendations
Rem    bemeng      05/02/04 - dba_data_files: join x$kccfe for online status
Rem    smuthuli    05/05/04 - auto space advisor 
Rem    vmarwah     03/15/04 - Bug 3492682: fix the DBA_FREE_SPACE views 
Rem    bemeng      12/31/03 - add hints in DBA_FREE_SPACE
Rem    nmukherj    11/16/03 - changed the view DBA_SEGMENTS: bug2948717
Rem    smuthuli    09/17/03 - add DBA_TABLESPACE_USAGE_METRICS 
Rem    mdilman     09/02/03 - change BIGFILE column values for dba_tablespaces 
Rem    vmarwah     08/11/03 - account for rbin space 
Rem    nireland    04/23/03 - Fix DBA_UNDO_EXTENTS. #2816521
Rem    bemeng      04/01/03 - add public synonym for v$filespace_usage
Rem    mdilman     09/17/02 - add BIGFILE column to DBA_TABLESPACES
Rem    wyang       09/12/02 - add RETENTION to dba_tablespaces and 
Rem                           user_tablespaces
Rem    qyu         08/12/02 - support lob shared segment  
Rem    hbaer       08/08/02 -  bug 2474106: COMPRESSION in *_TABLESPACES
Rem    vkarra      08/08/02 - tablespace groups
Rem    wyang       12/05/01 - deprecate commit time for DBA_UNDO_EXTENTS
Rem    yuli        07/23/01 - add column FORCE_LOGGING to dba_tablespaces
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;)
Rem    jklebane    02/20/01 - 1614732 :remove hints; rearrange sel list
Rem    smuthuli    03/14/01 - freelist* = NULL for bitmap segs
Rem    smuthuli    02/26/01 - add STATUS to DBA_UNDO_EXTENTS
Rem    smuthuli    01/11/01 - rename dba_smu_extents to dba_undo_extents
Rem    apareek     08/11/00 - multiple bsz - DBA_TABLESPACES
Rem    smuthuli    10/06/00 - add block_size to dba/user_tablespaces
Rem    vkarra      09/28/00 - update to reflect new syntax
Rem    smuthuli    08/07/00 - add dba_smu_extents.
Rem    smuthuli    07/18/00 - differentiate permanent versus undo tablespaces
Rem    smuthuli    07/18/00 - fix sys_dba_segs for SMU
Rem    vkarra      06/18/00 - bitmap segments
Rem    smuthuli    08/12/99 - add space views for OEM folks
Rem    smuthuli    07/12/99 - rename dbmsspace.sql to dbmsspc.sql
Rem    nireland    06/21/99 - Remove meaningless values for temp tbs. #891996  
Rem    rshaikh     05/24/99 - remove com so views dont show in dictionary view
Rem    akruglik    07/01/98 - modify definition of SYS_OBJECTS to include LOB 
Rem                           partitions and subpartitions
Rem    bhimatsi    06/22/98 - fix space views to use correct file#
Rem    jwlee       04/29/98 - add column PLUGGED_IN to dba_tablespaces
Rem    sbasu       04/27/98 - add index subpartition to sys_objects list
Rem    nireland    04/24/98 - Don't show dropped tablespaces in
Rem                           USER_TABLESPACES. #553723
Rem    bhimatsi    04/14/98 - bitmap ts - fixed views synonyms
Rem    bhimatsi    04/08/98 - tempfiles - view changes
Rem    bhimatsi    04/03/98 - dba_temp_files - fix
Rem    atsukerm    03/31/98 - revised bitmapped syntax.
Rem    bhimatsi    03/26/98 - temp tablespaces
Rem    bhimatsi    03/26/98 - temp tablespaces
Rem    bhimatsi    03/20/98 - bitmapped ts - temp tablespaces
Rem    atsukerm    03/19/98 - put hints in the dba_extents.
Rem    bhimatsi    03/11/98 - fix _segs
Rem    bhimatsi    03/07/98 - eliminate index_stats
Rem    bhimatsi    02/27/98 - create file for space mgmgmt views and procedure
Rem    bhimatsi    02/27/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
--
-- We should not drop/recreate wri$_segadv_attrib.  If table and definition
-- does change then request user to drop this table as part of patch 
-- pre-install instructions.
--

CREATE TABLE wri$_segadv_attrib(
  attribute#            number,
  attribvalue           number,
  descr                 varchar2(128),
  spare                 timestamp(6)
) tablespace SYSAUX;


-- load in the dbms_space_admin package
@@dbmsspc
-- load in the plb for above
@@prvtspad.plb

-- now define the views - this has to be done in this order as the view
-- depends on functions from dbms_space_admin package

remark  FAMILY "SEGMENTS"
remark  Storage for all types of segments
remark  This family has no ALL member.
remark  define SYS_OBJECTS for use by segments views
remark  The sys_objects view is a basis for segments views 
remark  The sys_user_segs view is a basis for user_segments and 
remark  user_extents views
remark  The sys_dba_segs view is a basis for dba_segments and 
remark  dba_extents views
remark  the value of extents/blocks in coming out of sys_user_segs and
remark  sys_dba_segs is correct only only for non-bitmapped tablespaces
remark  for bitmapped tablespaces, we have a procedure which we execute
remark  on the view on top of these to reduce the calls to the least
remark  selective set
remark
remark IMPORTANT NOTE ON SYS_OBJECTS : The definition for sys_objects is
remark is replicated in kttm.c. So if you ever want to change the definition
remark of sys_objects please notify the owner of kttm.c.
remark 
create or replace view SYS_OBJECTS
    (OBJECT_TYPE, OBJECT_TYPE_ID, SEGMENT_TYPE_ID,
     OBJECT_ID, HEADER_FILE, HEADER_BLOCK, TS_NUMBER)
as
select decode(bitand(t.property, 8192), 8192, 'NESTED TABLE', 'TABLE'), 2, 5,
       t.obj#, t.file#, t.block#, t.ts#
from sys.tab$ t
where bitand(t.property, 1024) = 0               /* exclude clustered tables */
union all
select 'TABLE PARTITION', 19, 5,
       tp.obj#, tp.file#, tp.block#, tp.ts#
from sys.tabpart$ tp
union all
select 'CLUSTER', 3, 5,
       c.obj#, c.file#, c.block#, c.ts#
from sys.clu$ c
union all
select decode(i.type#, 8, 'LOBINDEX', 'INDEX'), 1, 6,
       i.obj#, i.file#, i.block#, i.ts#
from sys.ind$ i
where i.type# in (1, 2, 3, 4, 6, 7, 8, 9)
union all
select 'INDEX PARTITION', 20, 6,
       ip.obj#, ip.file#, ip.block#, ip.ts#
from sys.indpart$ ip
union all
select 'LOBSEGMENT', 21, 8,
       l.lobj#, l.file#, l.block#, l.ts#
from sys.lob$ l
where (bitand(l.property, 64) = 0) or
      (bitand(l.property, 128) = 128)
union all
select 'TABLE SUBPARTITION', 34, 5,
       tsp.obj#, tsp.file#, tsp.block#, tsp.ts#
       from sys.tabsubpart$ tsp
union all
select 'INDEX SUBPARTITION', 35, 6,
       isp.obj#, isp.file#, isp.block#, isp.ts#
from sys.indsubpart$ isp
union all
select decode(lf.fragtype$, 'P', 'LOB PARTITION', 'LOB SUBPARTITION'),
       decode(lf.fragtype$, 'P', 40, 41), 8,
       lf.fragobj#, lf.file#, lf.block#, lf.ts#
from sys.lobfrag$ lf
/
grant select on SYS_OBJECTS to select_catalog_role
/
create or replace view SYS_USER_SEGS
    (SEGMENT_NAME,
     PARTITION_NAME,
     SEGMENT_TYPE, OBJECT_TYPE_ID, SEGMENT_TYPE_ID,
     SEGMENT_SUBTYPE, TABLESPACE_ID, TABLESPACE_NAME, BLOCKSIZE,
     HEADER_FILE, HEADER_BLOCK,
     BYTES, BLOCKS, EXTENTS, 
     INITIAL_EXTENT, NEXT_EXTENT, 
     MIN_EXTENTS, MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION, 
     PCT_INCREASE,
     FREELISTS, FREELIST_GROUPS, BUFFER_POOL_ID, FLASH_CACHE,
     CELL_FLASH_CACHE, SEGMENT_FLAGS, SEGMENT_OBJD, SEGMENT_OBJN)
as
select o.name,
       o.subname,
       so.object_type, so.object_type_id, s.type#,
       decode(bitand(s.spare1, 2097408), 2097152, 'SECUREFILE', 256, 'ASSM', 'MSSM'),
       ts.ts#, ts.name, ts.blocksize,
       s.file#, s.block#,
       s.blocks * ts.blocksize, s.blocks, s.extents, 
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize, 
       s.minexts, s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       to_char(decode(bitand(s.spare1, 2097152), 2097152, 
              decode(s.lists, 0, 'NONE', 1, 'AUTO', 2, 'MIN', 3, 'MAX', 
                     4, 'DEFAULT', 'INVALID'), NULL)),
       decode(bitand(s.spare1, 2097152), 2097152, s.groups, NULL),
       decode(bitand(ts.flags, 3), 1, to_number(NULL), 
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1, 0), s.hwmincr,
       so.object_id
from sys.obj$ o, sys.ts$ ts, sys.sys_objects so, sys.seg$ s
where s.file# = so.header_file
  and s.block# = so.header_block
  and s.ts# = so.ts_number
  and s.ts# = ts.ts#
  and o.obj# = so.object_id
  and o.owner# = userenv('SCHEMAID')
  and s.type# = so.segment_type_id
  and o.type# = so.object_type_id
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
                  and bitand(t.property, power(2,65)) = 0))
      or
      (o.type# = 6 and 1 = (select 1
                from sys.seq$ s
                where s.obj# = o.obj#
                  and bitand(s.flags, 1024) = 0)))
union all
select un.name, NULL,
       decode(s.type#, 1, 'ROLLBACK', 10, 'TYPE2 UNDO'), 0, s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize,
       s.file#, s.block#,
       s.blocks * ts.blocksize, s.blocks, s.extents,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize, s.minexts, 
       s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, s.extpct,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1, 0), s.hwmincr, 0
from sys.ts$ ts, sys.undo$ un, sys.seg$ s
where s.file# = un.file#
  and s.block# = un.block#
  and s.ts# = un.ts#
  and s.ts# = ts.ts#
  and s.user# = userenv('SCHEMAID')
  and s.type# in (1, 10)
  and un.status$ != 1  
union all
select to_char(f.file#) || '.' || to_char(s.block#),
       NULL,
       decode(s.type#, 2, 'DEFERRED ROLLBACK', 3, 'TEMPORARY',
                      4, 'CACHE', 9, 'SPACE HEADER', 'UNDEFINED'), 0, s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize,
       s.file#, s.block#,
       s.blocks * ts.blocksize, s.blocks, s.extents,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1, 0), s.hwmincr, 0
from sys.ts$ ts, sys.seg$ s, sys.file$ f
where s.ts# = ts.ts#
  and s.ts# = f.ts#
  and s.file# = f.relfile#
  and s.user# = userenv('SCHEMAID')
  and s.type# not in (1, 5, 6, 8, 10,11)
union all
select 'HEATMAP',
       NULL, 'SYSTEM STATISTICS', 0, s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize,
       s.file#, s.block#,
       s.blocks * ts.blocksize, s.blocks, s.extents,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize, 
       s.minexts, s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, decode(bitand(ts.flags, 3), 1, to_number(NULL), 
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1, 0), s.hwmincr, 0
from sys.ts$ ts, sys.seg$ s, sys.file$ f
where s.ts# = ts.ts#
  and s.ts# = f.ts#
  and s.file# = f.relfile#
  and s.user# = userenv('SCHEMAID')
  and s.type# = 11
/
grant select on SYS_USER_SEGS to select_catalog_role
/
Rem Note that the way dataobj number is returned from this view. It is taken
Rem from obj$ and undo$ rather than seg$. these are going to be same and hence
Rem it is ok. The reason it is done this way is because we use the same
Rem view for migrate purposes and at that time, seg$ doesnt have the objd
Rem also note that undo segment no is passed for objd for undo segs. this
Rem is exactly what we wish. 
create or replace view SYS_DBA_SEGS
    (OWNER, SEGMENT_NAME,
     PARTITION_NAME,
     SEGMENT_TYPE, OBJECT_TYPE_ID, SEGMENT_TYPE_ID,
     SEGMENT_SUBTYPE, TABLESPACE_ID, TABLESPACE_NAME, BLOCKSIZE,
     HEADER_FILE, HEADER_BLOCK,
     BYTES, BLOCKS, EXTENTS, 
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION,
     PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
     RELATIVE_FNO, BUFFER_POOL_ID, FLASH_CACHE, CELL_FLASH_CACHE,
     SEGMENT_FLAGS, SEGMENT_OBJD, SEGMENT_OBJN)
as
select NVL(u.name, 'SYS'), o.name, o.subname,
       so.object_type, so.object_type_id,  s.type#,
       decode(bitand(s.spare1, 2097408), 2097152, 'SECUREFILE', 256, 'ASSM', 'MSSM'),
       ts.ts#, ts.name, ts.blocksize,
       f.file#, s.block#,
       NVL(s.blocks, 0) * ts.blocksize, NVL(s.blocks, 0), s.extents, 
       s.iniexts * ts.blocksize, 
       s.extsize * ts.blocksize,
       s.minexts, s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       to_char(decode(bitand(s.spare1, 2097152), 2097152, 
              decode(s.lists, 0, 'NONE', 1, 'AUTO', 2, 'MIN', 3, 'MAX',
                     4, 'DEFAULT', 'INVALID'), NULL)),
       decode(bitand(s.spare1, 2097152), 2097152, s.groups, NULL),
       decode(bitand(ts.flags, 3), 1, to_number(NULL), 
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       s.file#, bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1,0), 
       decode(bitand(s.spare1, 1), 1,  s.hwmincr, o.dataobj#), so.object_id
from sys.user$ u, sys.obj$ o, sys.ts$ ts, sys.sys_objects so, sys.seg$ s,
     sys.file$ f
where s.file# = so.header_file
  and s.block# = so.header_block
  and s.ts# = so.ts_number
  and s.ts# = ts.ts#
  and o.obj# = so.object_id
  and o.owner# = u.user# (+)
  and s.type# = so.segment_type_id
  and o.type# = so.object_type_id
  and s.ts# = f.ts#
  and s.file# = f.relfile#
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
                  and bitand(t.property, power(2,65)) = 0))
      or
      (o.type# = 6 and 1 = (select 1
                from sys.seq$ s
                where s.obj# = o.obj#
                  and bitand(s.flags, 1024) = 0)))
union all
select NVL(u.name, 'SYS'), un.name, NULL,
       decode(s.type#, 1, 'ROLLBACK', 10, 'TYPE2 UNDO'),0,  s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize, f.file#, s.block#,
       NVL(s.blocks, 0) * ts.blocksize, NVL(s.blocks, 0), s.extents,
       s.iniexts * ts.blocksize, s.extsize * ts.blocksize, s.minexts, 
       s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, s.extpct,
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       s.file#, bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1,0), un.us#, 0
from sys.user$ u, sys.ts$ ts, sys.undo$ un, sys.seg$ s, sys.file$ f
where s.file# = un.file#
  and s.block# = un.block#
  and s.ts# = un.ts#
  and s.ts# = ts.ts#
  and s.user# = u.user# (+)
  and s.type# in (1, 10)
  and un.status$ != 1
  and un.ts# = f.ts#
  and un.file# = f.relfile#
union all
select NVL(u.name, 'SYS'), to_char(f.file#) || '.' || to_char(s.block#), NULL,
       decode(s.type#, 2, 'DEFERRED ROLLBACK', 3, 'TEMPORARY',
                      4, 'CACHE', 9, 'SPACE HEADER', 'UNDEFINED'),0, s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize,
       f.file#, s.block#,
       NVL(s.blocks, 0) * ts.blocksize, NVL(s.blocks, 0), s.extents,
       s.iniexts * ts.blocksize, 
       s.extsize * ts.blocksize,
       s.minexts, s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       s.file#, bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1,0), s.hwmincr, 0
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.file$ f
where s.ts# = ts.ts#
  and s.user# = u.user# (+)
  and s.type# not in (1, 5, 6, 8, 10, 11)
  and s.ts# = f.ts#
  and s.file# = f.relfile#
union all
select NVL(u.name, 'SYS'), 'HEATMAP', NULL, 'SYSTEM STATISTICS', 0, s.type#,
       NULL, ts.ts#, ts.name, ts.blocksize,
       f.file#, s.block#,
       NVL(s.blocks, 0) * ts.blocksize, NVL(s.blocks, 0), s.extents,
       s.iniexts * ts.blocksize,
       s.extsize * ts.blocksize,
       s.minexts, s.maxexts, 
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       NULL, NULL, decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)), 
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       s.file#, bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1,0), s.hwmincr, 0
from sys.user$ u, sys.ts$ ts, sys.seg$ s, sys.file$ f
where s.ts# = ts.ts#
  and s.user# = u.user# (+)
  and s.type# = 11
  and s.ts# = f.ts#
  and s.file# = f.relfile#
/
grant select on SYS_DBA_SEGS to select_catalog_role
/
remark USER_SEGMENTS masks out tablespace number from sys_user_segs
create or replace view USER_SEGMENTS
    (SEGMENT_NAME,
     PARTITION_NAME,
     SEGMENT_TYPE, SEGMENT_SUBTYPE,
     TABLESPACE_NAME,
     BYTES, BLOCKS, EXTENTS, 
     INITIAL_EXTENT, NEXT_EXTENT, 
     MIN_EXTENTS, MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION,
     PCT_INCREASE, FREELISTS,            
     FREELIST_GROUPS, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_DUPLICATE,
     INMEMORY_COMPRESSION, CELLMEMORY)
as
select segment_name, partition_name, segment_type, segment_subtype,
      tablespace_name,
       decode(bitand(segment_flags, 131072), 131072, blocks,
           (decode(bitand(segment_flags,1),1,
            dbms_space_admin.segment_number_blocks(tablespace_id, header_file,
            header_block, segment_type_id, buffer_pool_id, segment_flags,
            segment_objd, blocks), blocks)))*blocksize,
       decode(bitand(segment_flags, 131072), 131072, blocks,
           (decode(bitand(segment_flags,1),1,
            dbms_space_admin.segment_number_blocks(tablespace_id, header_file,
            header_block, segment_type_id, buffer_pool_id, segment_flags,
            segment_objd, blocks), blocks))),
       decode(bitand(segment_flags, 131072), 131072, extents,
           (decode(bitand(segment_flags,1),1,
           dbms_space_admin.segment_number_extents(tablespace_id, header_file,
           header_block, segment_type_id, buffer_pool_id, segment_flags,
           segment_objd, extents) , extents))),
       initial_extent, next_extent,
       min_extents, max_extents, max_size, retention, minretention,
       pct_increase, freelists, freelist_groups,
       decode(buffer_pool_id, 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(flash_cache, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(cell_flash_cache, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       -- INMEMORY
       decode (bitand(segment_flags, 4294967296), 
                          4294967296, 'ENABLED', 'DISABLED'),
       -- INMEMORY_PRIORITY
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 34359738368), 34359738368,
                decode(bitand(segment_flags, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null),
       -- INMEMORY_DISTRIBUTE
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 8589934592), 8589934592,
                        decode(bitand(segment_flags, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null),
       -- INMEMORY_DUPLICATE
       decode(bitand(segment_flags, 4294967296), 4294967296,
                   decode(bitand(segment_flags, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null),
       -- INMEMORY_COMPRESSSION
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null),
       decode(bitand(segment_flags, 4362862139015168),
            281474976710656, 'DISABLED',
            703687441776640, 'NO MEMCOMPRESS',
           1266637395197952, 'MEMCOMPRESS FOR QUERY', 
           2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
from sys_user_segs
/
comment on table USER_SEGMENTS is
'Storage allocated for all database segments'
/
comment on column USER_SEGMENTS.SEGMENT_NAME is
'Name, if any, of the segment'
/
comment on column USER_SEGMENTS.PARTITION_NAME is
'Partition/Subpartition Name, if any, of the segment'
/
comment on column USER_SEGMENTS.SEGMENT_TYPE is
'Type of segment:  "TABLE", "CLUSTER", "INDEX", "ROLLBACK", "DEFERRED ROLLBACK", "TEMPORARY", "SPACE HEADER", "TYPE2 UNDO" or "CACHE"'
/
comment on column USER_SEGMENTS.SEGMENT_SUBTYPE is
'SubType of Lob segment:  "SECUREFILE", "ASSM", "MSSM", NULL'
/
comment on column USER_SEGMENTS.TABLESPACE_NAME is
'Name of the tablespace containing the segment'
/
comment on column USER_SEGMENTS.BYTES is
'Size, in bytes, of the segment'
/
comment on column USER_SEGMENTS.BLOCKS is
'Size, in Oracle blocks, of the segment'
/
comment on column USER_SEGMENTS.EXTENTS is
'Number of extents allocated to the segment'
/
comment on column USER_SEGMENTS.INITIAL_EXTENT is
'Size, in bytes, of the initial extent of the segment'
/
comment on column USER_SEGMENTS.NEXT_EXTENT is
'Size, in bytes, of the next extent to be allocated to the segment' 
/
comment on column USER_SEGMENTS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column USER_SEGMENTS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column USER_SEGMENTS.MAX_SIZE is
'Maximum number of blocks allowed in the segment'
/
comment on column USER_SEGMENTS.RETENTION is
'Retention option for SECUREFILE segment'
/
comment on column USER_SEGMENTS.MINRETENTION is
'Minimum Retention Duration for SECUREFILE segment'
/
comment on column USER_SEGMENTS.PCT_INCREASE is
'Percent by which to increase the size of the next extent to be allocated'
/
comment on column USER_SEGMENTS.FREELISTS is
'Number of process freelists allocated to this segment'
/
comment on column USER_SEGMENTS.FREELIST_GROUPS is
'Number of freelist groups allocated to this segment'
/
comment on column USER_SEGMENTS.BUFFER_POOL is
'The default buffer pool to be used for blocks from this segment'
/
comment on column USER_SEGMENTS.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column USER_SEGMENTS.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column USER_SEGMENTS.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column USER_SEGMENTS.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column USER_SEGMENTS.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column USER_SEGMENTS.CELLMEMORY is
'Cell columnar cache'
/
create or replace public synonym USER_SEGMENTS for USER_SEGMENTS
/
grant read on USER_SEGMENTS to PUBLIC with grant option
/
remark DBA_SEGMENTS masks out tablespace number from sys_dba_segs
create or replace view DBA_SEGMENTS
    (OWNER, SEGMENT_NAME,
     PARTITION_NAME,
     SEGMENT_TYPE, SEGMENT_SUBTYPE,
     TABLESPACE_NAME,
     HEADER_FILE, HEADER_BLOCK,
     BYTES, BLOCKS, EXTENTS, 
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION,
     PCT_INCREASE, 
     FREELISTS, FREELIST_GROUPS,
     RELATIVE_FNO, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE,
     INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_DUPLICATE,
     INMEMORY_COMPRESSION, CELLMEMORY)
as
select owner, segment_name, partition_name, segment_type, 
       segment_subtype, tablespace_name,
       header_file, header_block,
       decode(bitand(segment_flags, 131072), 131072, blocks,
           (decode(bitand(segment_flags,1),1,
            dbms_space_admin.segment_number_blocks(tablespace_id, relative_fno,
            header_block, segment_type_id, buffer_pool_id, segment_flags,
            segment_objd, blocks), blocks)))*blocksize,
       decode(bitand(segment_flags, 131072), 131072, blocks,
           (decode(bitand(segment_flags,1),1,
            dbms_space_admin.segment_number_blocks(tablespace_id, relative_fno,
            header_block, segment_type_id, buffer_pool_id, segment_flags,
            segment_objd, blocks), blocks))),
       decode(bitand(segment_flags, 131072), 131072, extents, 
           (decode(bitand(segment_flags,1),1,
           dbms_space_admin.segment_number_extents(tablespace_id, relative_fno,
           header_block, segment_type_id, buffer_pool_id, segment_flags,
           segment_objd, extents) , extents))),
       initial_extent, next_extent, min_extents, max_extents, max_size,
       retention, minretention,
       pct_increase, freelists, freelist_groups, relative_fno,
       decode(buffer_pool_id, 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(flash_cache, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(cell_flash_cache, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       -- INMEMORY
       decode (bitand(segment_flags, 4294967296),
                          4294967296, 'ENABLED', 'DISABLED'),
       -- INMEMORY_PRIORITY
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 34359738368), 34359738368,
                decode(bitand(segment_flags, 61572651155456),
                8796093022208, 'LOW',
                17592186044416, 'MEDIUM',
                35184372088832, 'HIGH',
                52776558133248, 'CRITICAL', 'NONE'),
                'NONE'),
                null),
       -- INMEMORY_DISTRIBUTE
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 8589934592), 8589934592,
                        decode(bitand(segment_flags, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        'UNKNOWN'),
                  null),
       -- INMEMORY_DUPLICATE
       decode(bitand(segment_flags, 4294967296), 4294967296,
                   decode(bitand(segment_flags, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', 'UNKNOWN'),
                 null),
       -- INMEMORY_COMPRESSSION
       decode(bitand(segment_flags, 4294967296), 4294967296,
                decode(bitand(segment_flags, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null),
       decode(bitand(segment_flags, 4362862139015168),
            281474976710656, 'DISABLED',
            703687441776640, 'NO MEMCOMPRESS',
           1266637395197952, 'MEMCOMPRESS FOR QUERY', 
           2392537302040576, 'MEMCOMPRESS FOR CAPACITY', null)
from sys_dba_segs
/
create or replace public synonym DBA_SEGMENTS for DBA_SEGMENTS
/
grant select on DBA_SEGMENTS to select_catalog_role
/
comment on table DBA_SEGMENTS is
'Storage allocated for all database segments'
/
comment on column DBA_SEGMENTS.OWNER is
'Username of the segment owner'
/
comment on column DBA_SEGMENTS.SEGMENT_NAME is
'Name, if any, of the segment'
/
comment on column DBA_SEGMENTS.PARTITION_NAME is
'Partition/Subpartition Name, if any, of the segment'
/
comment on column DBA_SEGMENTS.SEGMENT_TYPE is
'Type of segment:  "TABLE", "CLUSTER", "INDEX", "ROLLBACK",
"DEFERRED ROLLBACK", "TEMPORARY","SPACE HEADER", "TYPE2 UNDO"
 or "CACHE"'
/
comment on column DBA_SEGMENTS.SEGMENT_SUBTYPE is
'SubType of Lob segment:  "SECUREFILE", "ASSM", "MSSM", NULL'
/
comment on column DBA_SEGMENTS.TABLESPACE_NAME is
'Name of the tablespace containing the segment'
/
comment on column DBA_SEGMENTS.HEADER_FILE is
'ID of the file containing the segment header'
/
comment on column DBA_SEGMENTS.HEADER_BLOCK is
'ID of the block containing the segment header'
/
comment on column DBA_SEGMENTS.BYTES is
'Size, in bytes, of the segment'
/
comment on column DBA_SEGMENTS.BLOCKS is
'Size, in Oracle blocks, of the segment'
/
comment on column DBA_SEGMENTS.EXTENTS is
'Number of extents allocated to the segment'
/
comment on column DBA_SEGMENTS.INITIAL_EXTENT is
'Size, in bytes, of the initial extent of the segment'
/
comment on column DBA_SEGMENTS.NEXT_EXTENT is
'Size, in bytes, of the next extent to be allocated to the segment' 
/
comment on column DBA_SEGMENTS.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_SEGMENTS.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_SEGMENTS.MAX_SIZE is
'Maximum number of blocks allowed in the segment'
/
comment on column DBA_SEGMENTS.RETENTION is
'Retention option for SECUREFILE segment'
/
comment on column DBA_SEGMENTS.MINRETENTION is
'Minimum Retention Duration for SECUREFILE segment'
/
comment on column DBA_SEGMENTS.PCT_INCREASE is
'Percent by which to increase the size of the next extent to be allocated'
/
comment on column DBA_SEGMENTS.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_SEGMENTS.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_SEGMENTS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/
comment on column DBA_SEGMENTS.BUFFER_POOL is
'The default buffer pool to be used for segments blocks'
/
comment on column DBA_SEGMENTS.INMEMORY is
'Whether in-memory is enabled or not'
/
comment on column DBA_SEGMENTS.INMEMORY_PRIORITY is
'User defined priority in which in-memory column store object is loaded'
/
comment on column DBA_SEGMENTS.INMEMORY_DISTRIBUTE is
'How the in-memory columnar store object is distributed'
/
comment on column DBA_SEGMENTS.INMEMORY_COMPRESSION is
'Compression level for the in-memory column store option'
/
comment on column DBA_SEGMENTS.INMEMORY_DUPLICATE is
'How the in-memory column store object is duplicated'
/
comment on column DBA_SEGMENTS.CELLMEMORY is
'Cell columnar cache'
/

execute CDBView.create_cdbview(false,'SYS','DBA_SEGMENTS','CDB_SEGMENTS');
grant select on SYS.CDB_SEGMENTS to select_catalog_role
/
create or replace public synonym CDB_SEGMENTS for SYS.CDB_SEGMENTS
/

remark
remark DBA_SEGMENTS_OLD masks out tablespace number from sys_dba_segs
create or replace view DBA_SEGMENTS_OLD
    (OWNER, SEGMENT_NAME,
     PARTITION_NAME,
     SEGMENT_TYPE,
     TABLESPACE_NAME,
     HEADER_FILE, HEADER_BLOCK,
     BYTES, BLOCKS, EXTENTS, 
     INITIAL_EXTENT, NEXT_EXTENT,
     MIN_EXTENTS, MAX_EXTENTS, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
     RELATIVE_FNO, BUFFER_POOL)
as
select owner, segment_name, partition_name, segment_type, tablespace_name,
       header_file, header_block,
       dbms_space_admin.segment_number_blocks(tablespace_id, relative_fno,
       header_block, segment_type_id, buffer_pool_id, segment_flags,
       segment_objd, blocks)*blocksize,
       dbms_space_admin.segment_number_blocks(tablespace_id, relative_fno,
       header_block, segment_type_id, buffer_pool_id, segment_flags,
       segment_objd, blocks),
       dbms_space_admin.segment_number_extents(tablespace_id, relative_fno,
       header_block, segment_type_id, buffer_pool_id, segment_flags,
       segment_objd, extents),
       initial_extent, next_extent, min_extents, max_extents, pct_increase,
       freelists, freelist_groups, relative_fno,
       decode(buffer_pool_id, 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT')
from sys_dba_segs
/
create or replace public synonym DBA_SEGMENTS_OLD for DBA_SEGMENTS_OLD
/
grant select on DBA_SEGMENTS_OLD to select_catalog_role
/
comment on table DBA_SEGMENTS_OLD is
'Storage allocated for all database segments'
/
comment on column DBA_SEGMENTS_OLD.OWNER is
'Username of the segment owner'
/
comment on column DBA_SEGMENTS_OLD.SEGMENT_NAME is
'Name, if any, of the segment'
/
comment on column DBA_SEGMENTS_OLD.PARTITION_NAME is
'Partition/Subpartition Name, if any, of the segment'
/
comment on column DBA_SEGMENTS_OLD.SEGMENT_TYPE is
'Type of segment:  "TABLE", "CLUSTER", "INDEX", "ROLLBACK",
"DEFERRED ROLLBACK", "TEMPORARY","SPACE HEADER", "TYPE2 UNDO"
 or "CACHE"'
/
comment on column DBA_SEGMENTS_OLD.TABLESPACE_NAME is
'Name of the tablespace containing the segment'
/
comment on column DBA_SEGMENTS_OLD.HEADER_FILE is
'ID of the file containing the segment header'
/
comment on column DBA_SEGMENTS_OLD.HEADER_BLOCK is
'ID of the block containing the segment header'
/
comment on column DBA_SEGMENTS_OLD.BYTES is
'Size, in bytes, of the segment'
/
comment on column DBA_SEGMENTS_OLD.BLOCKS is
'Size, in Oracle blocks, of the segment'
/
comment on column DBA_SEGMENTS_OLD.EXTENTS is
'Number of extents allocated to the segment'
/
comment on column DBA_SEGMENTS_OLD.INITIAL_EXTENT is
'Size, in bytes, of the initial extent of the segment'
/
comment on column DBA_SEGMENTS_OLD.NEXT_EXTENT is
'Size, in bytes, of the next extent to be allocated to the segment' 
/
comment on column DBA_SEGMENTS_OLD.MIN_EXTENTS is
'Minimum number of extents allowed in the segment'
/
comment on column DBA_SEGMENTS_OLD.MAX_EXTENTS is
'Maximum number of extents allowed in the segment'
/
comment on column DBA_SEGMENTS_OLD.PCT_INCREASE is
'Percent by which to increase the size of the next extent to be allocated'
/
comment on column DBA_SEGMENTS_OLD.FREELISTS is
'Number of process freelists allocated in this segment'
/
comment on column DBA_SEGMENTS_OLD.FREELIST_GROUPS is
'Number of freelist groups allocated in this segment'
/
comment on column DBA_SEGMENTS_OLD.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/
comment on column DBA_SEGMENTS_OLD.BUFFER_POOL is
'The default buffer pool to be used for segments blocks'
/

execute CDBView.create_cdbview(false,'SYS','DBA_SEGMENTS_OLD','CDB_SEGMENTS_OLD');
grant select on SYS.CDB_SEGMENTS_OLD to select_catalog_role
/
create or replace public synonym CDB_SEGMENTS_OLD for SYS.CDB_SEGMENTS_OLD
/

remark
remark  FAMILY "EXTENTS"
remark  Extents associated with their segments.
remark
create or replace view USER_EXTENTS
    (SEGMENT_NAME, PARTITION_NAME, SEGMENT_TYPE, TABLESPACE_NAME,
     EXTENT_ID, BYTES, BLOCKS)
as
select ds.segment_name, ds.partition_name, ds.segment_type, 
       ds.tablespace_name, e.ext#, e.length * ds.blocksize, e.length
from sys.uet$ e, sys.sys_user_segs ds
where e.segfile# = ds.header_file
  and e.segblock# = ds.header_block
  and e.ts# = ds.tablespace_id
  and bitand(NVL(ds.segment_flags,0), 1) = 0
  and bitand(NVL(ds.segment_flags,0), 65536) = 0
union all
select /*+ ordered use_nl(e) */
       ds.segment_name, ds.partition_name, ds.segment_type, 
       ds.tablespace_name, e.ktfbueextno, e.ktfbueblks * ds.blocksize,
       e.ktfbueblks
from sys.sys_user_segs ds, sys.x$ktfbue e
where e.ktfbuesegfno = ds.header_file
  and e.ktfbuesegbno = ds.header_block
  and e.ktfbuesegtsn = ds.tablespace_id
  and bitand(NVL(ds.segment_flags,0), 1) = 1
  and bitand(NVL(ds.segment_flags,0), 65536) = 0
/
comment on table USER_EXTENTS is
'Extents comprising segments owned by the user'
/
comment on column USER_EXTENTS.SEGMENT_NAME is
'Name of the segment associated with the extent'
/
comment on column USER_EXTENTS.PARTITION_NAME is
'Partition/Subpartition Name, if any, of the segment'
/
comment on column USER_EXTENTS.TABLESPACE_NAME is
'Name of the tablespace containing the extent'
/
comment on column USER_EXTENTS.SEGMENT_TYPE is
'Type of the segment'
/
comment on column USER_EXTENTS.EXTENT_ID is
'Extent number in the segment'
/
comment on column USER_EXTENTS.BYTES is
'Size of the extent in bytes'
/
comment on column USER_EXTENTS.BLOCKS is
'Size of the extent in ORACLE blocks'
/
create or replace public synonym USER_EXTENTS for USER_EXTENTS
/
grant read on USER_EXTENTS to PUBLIC with grant option
/
create or replace view DBA_EXTENTS
    (OWNER, SEGMENT_NAME, PARTITION_NAME, SEGMENT_TYPE, TABLESPACE_NAME,
     EXTENT_ID, FILE_ID, BLOCK_ID,
     BYTES, BLOCKS, RELATIVE_FNO)
as
select ds.owner, ds.segment_name, ds.partition_name, ds.segment_type, 
       ds.tablespace_name,
       e.ext#, f.file#, e.block#, e.length * ds.blocksize, e.length, e.file#
from sys.uet$ e, sys.sys_dba_segs ds, sys.file$ f
where e.segfile# = ds.relative_fno
  and e.segblock# = ds.header_block
  and e.ts# = ds.tablespace_id
  and e.ts# = f.ts#
  and e.file# = f.relfile#
  and bitand(NVL(ds.segment_flags,0), 1) = 0
  and bitand(NVL(ds.segment_flags,0), 65536) = 0
union all
select 
       ds.owner, ds.segment_name, ds.partition_name, ds.segment_type, 
       ds.tablespace_name,
       e.ktfbueextno, f.file#, e.ktfbuebno,
       e.ktfbueblks * ds.blocksize, e.ktfbueblks, e.ktfbuefno
from sys.sys_dba_segs ds, sys.x$ktfbue e, sys.file$ f
where e.ktfbuesegfno = ds.relative_fno
  and e.ktfbuesegbno = ds.header_block
  and e.ktfbuesegtsn = ds.tablespace_id
  and ds.tablespace_id = f.ts#
  and e.ktfbuefno = f.relfile#
  and bitand(NVL(ds.segment_flags, 0), 1) = 1
  and bitand(NVL(ds.segment_flags,0), 65536) = 0
/
create or replace public synonym DBA_EXTENTS for DBA_EXTENTS
/
grant select on DBA_EXTENTS to select_catalog_role
/
comment on table DBA_EXTENTS is
'Extents comprising all segments in the database'
/
comment on column DBA_EXTENTS.OWNER is
'Owner of the segment associated with the extent'
/
comment on column DBA_EXTENTS.SEGMENT_NAME is
'Name of the segment associated with the extent'
/
comment on column DBA_EXTENTS.PARTITION_NAME is
'Partition/Subpartition Name, if any, of the segment'
/
comment on column DBA_EXTENTS.TABLESPACE_NAME is
'Name of the tablespace containing the extent'
/
comment on column DBA_EXTENTS.SEGMENT_TYPE is
'Type of the segment'
/
comment on column DBA_EXTENTS.FILE_ID is
'Name of the file containing the extent'
/
comment on column DBA_EXTENTS.BLOCK_ID is
'Starting block number of the extent'
/
comment on column DBA_EXTENTS.EXTENT_ID is
'Extent number in the segment'
/
comment on column DBA_EXTENTS.BYTES is
'Size of the extent in bytes'
/
comment on column DBA_EXTENTS.BLOCKS is
'Size of the extent in ORACLE blocks'
/
comment on column DBA_EXTENTS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/

execute CDBView.create_cdbview(false,'SYS','DBA_EXTENTS','CDB_EXTENTS');
grant select on SYS.CDB_EXTENTS to select_catalog_role
/
create or replace public synonym CDB_EXTENTS for SYS.CDB_EXTENTS
/

remark
remark
remark This view is a sister view of dba_extents. It shows the extent
remark information for System Managed Undo segments only. The additional
remark columns expose the commit times for the extents.
remark commit_jtime and commit_wtime are deprecated.
remark NULL will be returned for them. 
remark
create or replace view DBA_UNDO_EXTENTS
     (OWNER, SEGMENT_NAME, TABLESPACE_NAME, EXTENT_ID, FILE_ID, BLOCK_ID,
     BYTES, BLOCKS, RELATIVE_FNO, COMMIT_JTIME, COMMIT_WTIME, STATUS)
as
select /*+ ordered use_nl(e) use_nl(f) */
       'SYS', u.name, t.name,
       e.ktfbueextno, f.file#, e.ktfbuebno,
       e.ktfbueblks * t.BLOCKSIZE, e.ktfbueblks, e.ktfbuefno,
       nullif(e.ktfbuectm, e.ktfbuectm),
       nullif(e.ktfbuestt, e.ktfbuestt), 
       decode(e.ktfbuesta, 1, 'ACTIVE', 2, 'EXPIRED', 3, 'UNEXPIRED', 
              'UNDEFINED')
from undo$ u, ts$ t, sys.x$ktfbue e, sys.file$ f
where
e.ktfbuesegfno = u.file#
and e.ktfbuesegbno = u.block#
and e.ktfbuesegtsn = u.ts#
and (u.spare1 = 1 or u.spare1 = 2)
and u.status$ != 1
and t.ts# = u.ts#
and e.ktfbuefno = f.relfile#
and u.ts# = f.ts#
and (bitand(t.flags, 16777216) = 0)
/
create or replace public synonym DBA_UNDO_EXTENTS for DBA_UNDO_EXTENTS
/
grant select on DBA_UNDO_EXTENTS to select_catalog_role
/
comment on table DBA_UNDO_EXTENTS is
'Extents comprising all segments in the system managed undo tablespaces'
/
comment on column DBA_UNDO_EXTENTS.OWNER is
'Owner of the segment associated with the extent'
/
comment on column DBA_UNDO_EXTENTS.SEGMENT_NAME is
'Name of the segment associated with the extent'
/
comment on column DBA_UNDO_EXTENTS.TABLESPACE_NAME is
'Name of the tablespace containing the extent'
/
comment on column DBA_UNDO_EXTENTS.FILE_ID is
'Name of the file containing the extent'
/
comment on column DBA_UNDO_EXTENTS.BLOCK_ID is
'Starting block number of the extent'
/
comment on column DBA_UNDO_EXTENTS.EXTENT_ID is
'Extent number in the segment'
/
comment on column DBA_UNDO_EXTENTS.BYTES is
'Size of the extent in bytes'
/
comment on column DBA_UNDO_EXTENTS.BLOCKS is
'Size of the extent in ORACLE blocks'
/
comment on column DBA_UNDO_EXTENTS.RELATIVE_FNO is
'Relative number of the file containing the segment header'
/
comment on column DBA_UNDO_EXTENTS.COMMIT_JTIME is
'Commit Time of the undo in the extent expressed as Julian date'
/
comment on column DBA_UNDO_EXTENTS.COMMIT_WTIME is
'Commit Time of the undo in the extent expressed as wall clock time'
/
comment on column DBA_UNDO_EXTENTS.STATUS is
'Transaction Status of the undo in the extent '
/

execute CDBView.create_cdbview(false,'SYS','DBA_UNDO_EXTENTS','CDB_UNDO_EXTENTS');
grant select on SYS.CDB_UNDO_EXTENTS to select_catalog_role
/
create or replace public synonym CDB_UNDO_EXTENTS for SYS.CDB_UNDO_EXTENTS
/

remark 
remark  This view selects all the used extents in locally managed 
remark  tablespaces. Built on top of x$ktfbue.
remark
create or replace view DBA_LMT_USED_EXTENTS
        (SEGMENT_FILEID, SEGMENT_BLOCK, TABLESPACE_ID, 
         EXTENT_ID, FILEID, BLOCK, LENGTH)
as
select  u.ktfbuesegfno, u.ktfbuesegbno, u.ktfbuesegtsn,
        u.ktfbueextno, u.ktfbuefno, u.ktfbuebno, u.ktfbueblks
from    sys.x$ktfbue u
where   not exists (select * from sys.recyclebin$ rb
                    where u.ktfbuesegtsn = rb.ts#
                      and u.ktfbuesegfno = rb.file#
                      and u.ktfbuesegbno = rb.block#)
/
create or replace public synonym DBA_LMT_USED_EXTENTS for DBA_LMT_USED_EXTENTS
/
grant select on DBA_LMT_USED_EXTENTS to select_catalog_role
/
comment on table DBA_LMT_USED_EXTENTS is
'All extents in the locally managed tablespaces'
/
comment on column DBA_LMT_USED_EXTENTS.SEGMENT_FILEID is
'File number of segment header of the extent'
/
comment on column DBA_LMT_USED_EXTENTS.SEGMENT_BLOCK is
'Block number of segment header of the extent'
/
comment on column DBA_LMT_USED_EXTENTS.TABLESPACE_ID is
'ID of the tablespace containing the extent'
/
comment on column DBA_LMT_USED_EXTENTS.EXTENT_ID is
'Extent number in the segment'
/
comment on column DBA_LMT_USED_EXTENTS.FILEID is
'File Number of the extent'
/
comment on column DBA_LMT_USED_EXTENTS.BLOCK is
'Starting block number of the extent'
/
comment on column DBA_LMT_USED_EXTENTS.LENGTH is
'Number of blocks in the extent'
/

execute CDBView.create_cdbview(false,'SYS','DBA_LMT_USED_EXTENTS','CDB_LMT_USED_EXTENTS');
grant select on SYS.CDB_LMT_USED_EXTENTS to select_catalog_role
/
create or replace public synonym CDB_LMT_USED_EXTENTS for SYS.CDB_LMT_USED_EXTENTS
/

remark
remark  This view selects the used extents in dictionary managed
remark  tablespaces. Built on top of uet$
remark
create or replace view DBA_DMT_USED_EXTENTS
        (SEGMENT_FILEID, SEGMENT_BLOCK, TABLESPACE_ID,
         EXTENT_ID, FILEID, BLOCK, LENGTH)
as
select  u.segfile#, u.segblock#, u.ts#,
        u.ext#, u.file#, u.block#, u.length 
from    sys.uet$ u
where   not exists (select * from sys.recyclebin$ rb
                    where u.ts# = rb.ts#
                      and u.segfile# = rb.file#
                      and u.segblock# = rb.block#)
/
create or replace public synonym DBA_DMT_USED_EXTENTS for DBA_DMT_USED_EXTENTS
/
grant select on DBA_DMT_USED_EXTENTS to select_catalog_role
/
comment on table DBA_DMT_USED_EXTENTS is
'All extents in the dictionary managed tablespaces'
/
comment on column DBA_DMT_USED_EXTENTS.SEGMENT_FILEID is
'File number of segment header of the extent'
/
comment on column DBA_DMT_USED_EXTENTS.SEGMENT_BLOCK is
'Block number of segment header of the extent'
/
comment on column DBA_DMT_USED_EXTENTS.TABLESPACE_ID is
'ID of the tablespace containing the extent'
/
comment on column DBA_DMT_USED_EXTENTS.EXTENT_ID is
'Extent number in the segment'
/
comment on column DBA_DMT_USED_EXTENTS.FILEID is
'File Number of the extent'
/
comment on column DBA_DMT_USED_EXTENTS.BLOCK is
'Starting block number of the extent'
/
comment on column DBA_DMT_USED_EXTENTS.LENGTH is
'Number of blocks in the extent'
/

execute CDBView.create_cdbview(false,'SYS','DBA_DMT_USED_EXTENTS','CDB_DMT_USED_EXTENTS');
grant select on SYS.CDB_DMT_USED_EXTENTS to select_catalog_role
/
create or replace public synonym CDB_DMT_USED_EXTENTS for SYS.CDB_DMT_USED_EXTENTS
/

remark
remark  FAMILY "FREE_SPACE"
remark  Free extents.
remark  This family has no ALL member.
remark
create or replace view USER_FREE_SPACE
    (TABLESPACE_NAME, FILE_ID, BLOCK_ID,
     BYTES, BLOCKS, RELATIVE_FNO)
as
select ts.name, fi.file#, f.block#,
       f.length * ts.blocksize, f.length, f.file#
from sys.fet$ f, sys.ts$ ts, sys.file$ fi
where f.ts# = ts.ts#
  and f.ts# = fi.ts#
  and f.file# = fi.relfile#
  and ts.bitmapped = 0
  and (ts.ts# in
         (select tsq.ts#
          from sys.tsq$ tsq
          where tsq.user# = userenv('SCHEMAID') and tsq.maxblocks != 0)
       or exists
          (select null
           from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)
      )
union all
select 
       ts.name, fi.file#, f.ktfbfebno,
       f.ktfbfeblks * ts.blocksize, f.ktfbfeblks, f.ktfbfefno
from sys.ts$ ts, sys.x$ktfbfe f, sys.file$ fi
where ts.ts# = f.ktfbfetsn
  and f.ktfbfetsn = fi.ts#
  and f.ktfbfefno = fi.relfile#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) <> 4503599627370496
  and (ts.ts# in
         (select tsq.ts#
          from sys.tsq$ tsq
          where tsq.user# = userenv('SCHEMAID') and tsq.maxblocks != 0)
       or exists
          (select null
           from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)
      )
union all
select 
       ts.name, fi.file#, u.ktfbuebno,
       u.ktfbueblks * ts.blocksize, u.ktfbueblks, u.ktfbuefno
from sys.recyclebin$ rb, sys.ts$ ts, sys.x$ktfbue u, sys.file$ fi
where ts.ts# = rb.ts#
  and rb.ts# = fi.ts#
  and rb.file# = fi.relfile#
  and u.ktfbuesegtsn = rb.ts#
  and u.ktfbuesegfno = rb.file#
  and u.ktfbuesegbno = rb.block#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) <> 4503599627370496
  and (ts.ts# in
         (select tsq.ts#
          from sys.tsq$ tsq
          where tsq.user# = userenv('SCHEMAID') and tsq.maxblocks != 0)
       or exists
          (select null
           from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)
      )
union all
select ts.name, fi.file#, u.block#,
       u.length * ts.blocksize, u.length, u.file#
from sys.ts$ ts, sys.uet$ u, sys.file$ fi, sys.recyclebin$ rb
where ts.ts# = u.ts#
  and u.ts# = fi.ts#
  and u.segfile# = fi.relfile#
  and u.ts# = rb.ts#
  and u.segfile# = rb.file#
  and u.segblock# = rb.block#
  and ts.bitmapped = 0
  and (ts.ts# in
         (select tsq.ts#
          from sys.tsq$ tsq
          where tsq.user# = userenv('SCHEMAID') and tsq.maxblocks != 0)
       or exists
          (select null
           from sys.v$enabledprivs
           where priv_number = -15 /* UNLIMITED TABLESPACE */)
      )
union all
select
       ts.name, fi.file#, f.extent_start,
       (f.extent_length_blocks_2K /(ts.blocksize/2048)) * ts.blocksize,
       (f.extent_length_blocks_2K /(ts.blocksize/2048)), fi.relfile#
from sys.ts$ ts, sys.new_lost_write_extents$ f, sys.file$ fi
where ts.ts# = f.extent_datafile_tsid
  and f.extent_datafile_tsid = fi.ts#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) = 4503599627370496
/
comment on table USER_FREE_SPACE is
'Free extents in tablespaces accessible to the user'
/
comment on column USER_FREE_SPACE.TABLESPACE_NAME is
'Name of the tablespace containing the extent'
/
comment on column USER_FREE_SPACE.FILE_ID is
'ID number of the file containing the extent'
/
comment on column USER_FREE_SPACE.BLOCK_ID is
'Starting block number of the extent'
/
comment on column USER_FREE_SPACE.BYTES is
'Size of the extent in bytes'
/
comment on column USER_FREE_SPACE.BLOCKS is
'Size of the extent in ORACLE blocks'
/
comment on column USER_FREE_SPACE.RELATIVE_FNO is
'Relative number of the file containing the extent'
/
create or replace public synonym USER_FREE_SPACE for USER_FREE_SPACE
/
grant read on USER_FREE_SPACE to PUBLIC with grant option
/
create or replace view DBA_FREE_SPACE
    (TABLESPACE_NAME, FILE_ID, BLOCK_ID,
     BYTES, BLOCKS, RELATIVE_FNO)
as
select ts.name, fi.file#, f.block#,
       f.length * ts.blocksize, f.length, f.file#
from sys.ts$ ts, sys.fet$ f, sys.file$ fi
where ts.ts# = f.ts#
  and f.ts# = fi.ts#
  and f.file# = fi.relfile#
  and ts.bitmapped = 0
union all
select 
       ts.name, fi.file#, f.ktfbfebno,
       f.ktfbfeblks * ts.blocksize, f.ktfbfeblks, f.ktfbfefno
from sys.ts$ ts, sys.x$ktfbfe f, sys.file$ fi
where ts.ts# = f.ktfbfetsn
  and f.ktfbfetsn = fi.ts#
  and f.ktfbfefno = fi.relfile#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) <> 4503599627370496
union all
select 
       ts.name, fi.file#, u.ktfbuebno,
       u.ktfbueblks * ts.blocksize, u.ktfbueblks, u.ktfbuefno
from sys.recyclebin$ rb, sys.ts$ ts, sys.x$ktfbue u, sys.file$ fi
where ts.ts# = rb.ts#
  and rb.ts# = fi.ts#
  and u.ktfbuefno = fi.relfile#
  and u.ktfbuesegtsn = rb.ts#
  and u.ktfbuesegfno = rb.file#
  and u.ktfbuesegbno = rb.block#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) <> 4503599627370496
union all
select ts.name, fi.file#, u.block#,
       u.length * ts.blocksize, u.length, u.file#
from sys.ts$ ts, sys.uet$ u, sys.file$ fi, sys.recyclebin$ rb
where ts.ts# = u.ts#
  and u.ts# = fi.ts#
  and u.segfile# = fi.relfile#
  and u.ts# = rb.ts#
  and u.segfile# = rb.file#
  and u.segblock# = rb.block#
  and ts.bitmapped = 0
union all
select
       ts.name, fi.file#, f.extent_start,
       (f.extent_length_blocks_2K /(ts.blocksize/2048)) * ts.blocksize,
       (f.extent_length_blocks_2K / (ts.blocksize/2048)), fi.relfile#
from sys.ts$ ts, sys.new_lost_write_extents$ f, sys.file$ fi
where ts.ts# = f.extent_datafile_tsid
  and f.extent_datafile_tsid = fi.ts#
  and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
  and bitand(ts.flags, 4503599627370496) = 4503599627370496
/
create or replace public synonym DBA_FREE_SPACE for DBA_FREE_SPACE
/
grant select on DBA_FREE_SPACE to select_catalog_role
/
comment on table DBA_FREE_SPACE is
'Free extents in all tablespaces'
/
comment on column DBA_FREE_SPACE.TABLESPACE_NAME is
'Name of the tablespace containing the extent'
/
comment on column DBA_FREE_SPACE.FILE_ID is
'ID number of the file containing the extent'
/
comment on column DBA_FREE_SPACE.BLOCK_ID is
'Starting block number of the extent'
/
comment on column DBA_FREE_SPACE.BYTES is
'Size of the extent in bytes'
/
comment on column DBA_FREE_SPACE.BLOCKS is
'Size of the extent in ORACLE blocks'
/
comment on column DBA_FREE_SPACE.RELATIVE_FNO is
'Relative number of the file containing the extent'
/

execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE','CDB_FREE_SPACE');
grant select on SYS.CDB_FREE_SPACE to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE for SYS.CDB_FREE_SPACE
/

remark 
remark Free extents in locally managed tablespaces
remark Built on top of x$ktfbfe
remark
create or replace view DBA_LMT_FREE_SPACE 
        (TABLESPACE_ID, FILE_ID, BLOCK_ID, BLOCKS)
as
select  ktfbfetsn, ktfbfefno, ktfbfebno, ktfbfeblks
from    x$ktfbfe
/
create or replace public synonym DBA_LMT_FREE_SPACE for DBA_LMT_FREE_SPACE
/
grant select on DBA_LMT_FREE_SPACE to select_catalog_role
/
comment on table DBA_LMT_FREE_SPACE is
'Free extents in all locally managed tablespaces'
/
comment on column DBA_LMT_FREE_SPACE.TABLESPACE_ID is
'ID of the tablespace containing the extent'
/
comment on column DBA_LMT_FREE_SPACE.FILE_ID is
'ID number of the file containing the extent'
/
comment on column DBA_LMT_FREE_SPACE.BLOCK_ID is
'Starting block number of the extent'
/
comment on column DBA_LMT_FREE_SPACE.BLOCKS is
'Size of the extent in blocks'
/

execute CDBView.create_cdbview(false,'SYS','DBA_LMT_FREE_SPACE','CDB_LMT_FREE_SPACE');
grant select on SYS.CDB_LMT_FREE_SPACE to select_catalog_role
/
create or replace public synonym CDB_LMT_FREE_SPACE for SYS.CDB_LMT_FREE_SPACE
/

remark
remark Free extents in dictionary managed tablespaces
remark Built on top of fet$
remark
create or replace view DBA_DMT_FREE_SPACE
        (TABLESPACE_ID, FILE_ID, BLOCK_ID, BLOCKS)
as
select  ts#, file#, block#, length
from    fet$
/
create or replace public synonym DBA_DMT_FREE_SPACE for DBA_DMT_FREE_SPACE
/
grant select on DBA_DMT_FREE_SPACE to select_catalog_role
/
comment on table DBA_DMT_FREE_SPACE is
'Free extents in all dictionary managed tablespaces'
/
comment on column DBA_DMT_FREE_SPACE.TABLESPACE_ID is
'ID of the tablespace containing the extent'
/
comment on column DBA_DMT_FREE_SPACE.FILE_ID is
'ID number of the file containing the extent'
/
comment on column DBA_DMT_FREE_SPACE.BLOCK_ID is
'Starting block number of the extent'
/
comment on column DBA_DMT_FREE_SPACE.BLOCKS is
'Size of the extent in blocks'
/

execute CDBView.create_cdbview(false,'SYS','DBA_DMT_FREE_SPACE','CDB_DMT_FREE_SPACE');
grant select on SYS.CDB_DMT_FREE_SPACE to select_catalog_role
/
create or replace public synonym CDB_DMT_FREE_SPACE for SYS.CDB_DMT_FREE_SPACE
/

remark
remark  FAMILY "FREE_SPACE_COALESCED"
remark  Free extents which are Coalesced
remark  This family has only DBA member
remark 
remark This view is just used for constructing the main view.
remark Coalesced free extents and blocks in dictionary managed tablespaces.
remark and also the same for objects in the recyclebin.
remark 
create or replace view DBA_FREE_SPACE_COALESCED_TMP1
as
  select a.ts#, count(*) extents_coalesced, sum(a.length) blocks_coalesced
    from sys.fet$ a
  where not exists (
    select * 
      from sys.fet$ b
    where b.ts# = a.ts# 
      and b.file# = a.file# 
      and a.block# = b.block# + b.length)
  group by ts#
union all
  select u.ts#, count(*) extents_coalesced, sum(u.length) blocks_coalesced
    from sys.uet$ u, sys.ts$ ts, sys.recyclebin$ rb
  where ts.ts# = u.ts#
    and u.ts# = rb.ts#
    and u.segfile# = rb.file#
    and u.segblock# = rb.block#
    and ts.bitmapped = 0
    and not exists (
      select *
        from sys.uet$ ub
      where u.ts# = ub.ts#
        and u.file# = ub.file#
        and u.block# = ub.block# + ub.length)
  group by u.ts#
/
grant select on DBA_FREE_SPACE_COALESCED_TMP1 to select_catalog_role
/
REM comment on table DBA_FREE_SPACE_COALESCED_TMP1 is
REM 'Coalesced Free Extents for all dictionary Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP1.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP1.extents_coalesced is
'Number of Coalesced Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP1.blocks_coalesced is
'Total Coalesced Free Oracle Blocks in Tablespace'
/

execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP1','CDB_FREE_SPACE_COALESCED_TMP1');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP1 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP1 for SYS.CDB_FREE_SPACE_COALESCED_TMP1
/

remark
remark This view is just used for constructing the main view.
remark Total free extents and blocks for dictionary managed tablespaces
remark and also used extents resident in the recyclebin.
remark
create or replace view
  DBA_FREE_SPACE_COALESCED_TMP2(ts#, total_extents, total_blocks)
as
  select ts#, count(*), sum(length)
    from sys.fet$
  group by ts#
union all
  select u.ts#, count(*), sum(u.length)
    from sys.uet$ u, sys.ts$ ts, sys.recyclebin$ rb
  where ts.ts# = u.ts#
    and u.ts# = rb.ts#
    and u.segfile# = rb.file#
    and u.segblock# = rb.block#
    and ts.bitmapped = 0
  group by u.ts#
/
grant select on DBA_FREE_SPACE_COALESCED_TMP2 to select_catalog_role
/
REM comment on table DBA_FREE_SPACE_COALESCED_TMP2 is
REM 'Free Extents in dictionary Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP2.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP2.total_extents is
'Number of Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP2.total_blocks is
'Total Free Blocks in Tablespace'
/
execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP2','CDB_FREE_SPACE_COALESCED_TMP2');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP2 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP2 for SYS.CDB_FREE_SPACE_COALESCED_TMP2
/

remark
remark This view is just used for constructing the main view.
remark Here we get free extents and also used extents (which are in the 
remark recyclebin) for bitmapped tablespaces.
remark
create or replace view 
  DBA_FREE_SPACE_COALESCED_TMP3(ts#, total_extents, total_blocks)
as
  select /*+ ordered */ ktfbfetsn, count(*), sum(ktfbfeblks)
    from sys.x$ktfbfe
  group by ktfbfetsn
union all
  select /*+ ordered use_nl(e) */ ktfbuesegtsn, count(*), sum(ktfbueblks)
    from sys.ts$ ts , sys.recyclebin$ rb, sys.x$ktfbue e
    where ts.ts# = e.ktfbuesegtsn
      and e.ktfbuesegtsn = rb.ts#
      and e.ktfbuesegfno = rb.file#
      and e.ktfbuesegbno = rb.block#
      and ts.bitmapped <> 0
      and ts.online$ in (1,4)
      and ts.contents$ = 0
  group by ktfbuesegtsn
/
grant select on DBA_FREE_SPACE_COALESCED_TMP3 to select_catalog_role
/
REM comment on table DBA_FREE_SPACE_COALESCED_TMP3 is
REM 'Free Extents in locally managed Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP3.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP3.total_extents is
'Number of Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP3.total_blocks is
'Total Free Blocks in Tablespace'
/
execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP3','CDB_FREE_SPACE_COALESCED_TMP3');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP3 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP3 for SYS.CDB_FREE_SPACE_COALESCED_TMP3
/
remark
remark This view is just used for constructing the main view.
remark This collates bitmapped extents.
remark
create or replace view
  DBA_FREE_SPACE_COALESCED_TMP4(ts#, total_extents, total_blocks)
as
  select ts#, sum(total_extents), sum(total_blocks)
    from DBA_FREE_SPACE_COALESCED_TMP3
  group by ts#
/
grant select on DBA_FREE_SPACE_COALESCED_TMP4 to select_catalog_role
/
REM comment on table DBA_FREE_SPACE_COALESCED_TMP4 is
REM 'Free Extents in locally managed Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP4.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP4.total_extents is
'Number of Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP4.total_blocks is
'Total Free Blocks in Tablespace'
/
execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP4','CDB_FREE_SPACE_COALESCED_TMP4');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP4 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP4 for SYS.CDB_FREE_SPACE_COALESCED_TMP4
/

remark
remark This view is just used for constructing the main view.
remark
create or replace view 
  DBA_FREE_SPACE_COALESCED_TMP5(ts#, total_extents, total_blocks)
as
  select ts#, sum(total_extents), sum(total_blocks)
    from DBA_FREE_SPACE_COALESCED_TMP2
  group by ts# 
/   
grant select on DBA_FREE_SPACE_COALESCED_TMP5 to select_catalog_role
/   
REM comment on table DBA_FREE_SPACE_COALESCED_TMP5 is
REM 'Free Extents in dictionary managed Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP5.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP5.total_extents is
'Number of Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP5.total_blocks is
'Total Free Blocks in Tablespace'
/
execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP5','CDB_FREE_SPACE_COALESCED_TMP5');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP5 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP5 for SYS.CDB_FREE_SPACE_COALESCED_TMP5
/

remark
remark This view is just used for constructing the main view.
remark
create or replace view
  DBA_FREE_SPACE_COALESCED_TMP6(ts#, extents_coalesced, blocks_coalesced)
as
  select ts#, sum(extents_coalesced), sum(blocks_coalesced)
    from DBA_FREE_SPACE_COALESCED_TMP1
  group by ts#
/
grant select on DBA_FREE_SPACE_COALESCED_TMP6 to select_catalog_role
/
REM comment on table DBA_FREE_SPACE_COALESCED_TMP6 is
REM 'Coalesced Free Extents for all dictionary Tablespaces'
REM /
comment on column DBA_FREE_SPACE_COALESCED_TMP6.ts# is
'Number of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP6.extents_coalesced is
'Number of Coalesced Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED_TMP6.blocks_coalesced is
'Total Coalesced Free Oracle Blocks in Tablespace'
/
execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED_TMP6','CDB_FREE_SPACE_COALESCED_TMP6');
grant select on SYS.CDB_FREE_SPACE_COALESCED_TMP6 to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED_TMP6 for SYS.CDB_FREE_SPACE_COALESCED_TMP6
/

remark
remark MAIN VIEW for this family
remark Free extents which do not have any other free extents before them are
remark considered coalesced. This implies that if there is contiguous free
remark space represented as 5 free extents, then we consider the first of
remark these to be coalesced and the rest 4 to be non coalesced.
remark
create or replace view DBA_FREE_SPACE_COALESCED
    (TABLESPACE_NAME, TOTAL_EXTENTS, EXTENTS_COALESCED, PERCENT_EXTENTS_COALESCED, TOTAL_BYTES, BYTES_COALESCED, TOTAL_BLOCKS, BLOCKS_COALESCED, PERCENT_BLOCKS_COALESCED)
as
select name,total_extents, extents_coalesced, 
       extents_coalesced/total_extents*100,total_blocks*c.blocksize, 
       blocks_coalesced*c.blocksize, total_blocks, blocks_coalesced,
       blocks_coalesced/total_blocks*100
from DBA_FREE_SPACE_COALESCED_TMP6 a, DBA_FREE_SPACE_COALESCED_TMP5 b, 
      sys.ts$ c 
where a.ts#=b.ts# and a.ts#=c.ts#
union all
select name, total_extents, total_extents, 100, total_blocks*c.blocksize,
       total_blocks*c.blocksize, total_blocks, total_blocks, 100
from DBA_FREE_SPACE_COALESCED_TMP4 b, sys.ts$ c
where b.ts# = c.ts#
/
create or replace public synonym DBA_FREE_SPACE_COALESCED
   for DBA_FREE_SPACE_COALESCED
/
grant select on DBA_FREE_SPACE_COALESCED to select_catalog_role
/
comment on table DBA_FREE_SPACE_COALESCED is
'Statistics on Coalesced Space in Tablespaces'
/
comment on column DBA_FREE_SPACE_COALESCED.TABLESPACE_NAME is
'Name of Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.TOTAL_EXTENTS is
'Total Number of Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.EXTENTS_COALESCED is
'Total Number of Coalesced Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.PERCENT_EXTENTS_COALESCED is
'Percentage of Coalesced Free Extents in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.TOTAL_BYTES is
'Total Number of Free Bytes in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.BYTES_COALESCED is
'Total Number of Coalesced Free Bytes in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.TOTAL_BLOCKS is
'Total Number of Free Oracle Blocks in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.BLOCKS_COALESCED is
'Total Number of Coalesced Free Oracle Blocks in Tablespace'
/
comment on column DBA_FREE_SPACE_COALESCED.PERCENT_BLOCKS_COALESCED is
'Percentage of Coalesced Free Oracle Blocks in Tablespace'
/

execute CDBView.create_cdbview(false,'SYS','DBA_FREE_SPACE_COALESCED','CDB_FREE_SPACE_COALESCED');
grant select on SYS.CDB_FREE_SPACE_COALESCED to select_catalog_role
/
create or replace public synonym CDB_FREE_SPACE_COALESCED for SYS.CDB_FREE_SPACE_COALESCED
/

remark
remark  FAMILY "DATA_FILES"
remark  Information about database files.
remark  This family has a DBA member only.
remark  (we also have added filext$ for compatibility with 7.2 release)
remark
create or replace view DBA_DATA_FILES
    (FILE_NAME, FILE_ID, TABLESPACE_NAME,
     BYTES, BLOCKS, STATUS, RELATIVE_FNO, AUTOEXTENSIBLE,
     MAXBYTES, MAXBLOCKS, INCREMENT_BY, USER_BYTES, USER_BLOCKS, ONLINE_STATUS,
     LOST_WRITE_PROTECT)
as
select v.name, f.file#, ts.name,
       ts.blocksize * f.blocks, f.blocks,
       decode(f.status$, 1, 'INVALID', 2, 'AVAILABLE', 'UNDEFINED'),
       f.relfile#, decode(f.inc, 0, 'NO', 'YES'),
       ts.blocksize * f.maxextend, f.maxextend, f.inc,
       ts.blocksize * (f.blocks - 1), f.blocks - 1,
       decode(fe.fetsn, 0, decode(bitand(fe.festa, 2), 0, 'SYSOFF', 'SYSTEM'),
       decode(bitand(fe.festa, 18), 0, 'OFFLINE', 2, 'ONLINE', 'RECOVER')),
       decode(bitand(f.spare2, 3), NULL, 'OFF', 0, 'OFF', 1, 'ENABLED', 2, 
       'SUSPEND')
from sys.file$ f, sys.ts$ ts, sys.v$dbfile v,
     (select * from x$kccfe
      where (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))) fe
where v.file# = f.file#
  and f.spare1 is NULL
  and f.ts# = ts.ts#
  and fe.fenum = f.file#
union all
select
       v.name,f.file#, ts.name,
       decode(hc.ktfbhccval, 0, ts.blocksize * hc.ktfbhcsz, NULL),
       decode(hc.ktfbhccval, 0, hc.ktfbhcsz, NULL),
       decode(f.status$, 1, 'INVALID', 2, 'AVAILABLE', 'UNDEFINED'),
       f.relfile#,
       decode(hc.ktfbhccval, 0, decode(hc.ktfbhcinc, 0, 'NO', 'YES'), NULL),
       decode(hc.ktfbhccval, 0, ts.blocksize * hc.ktfbhcmaxsz, NULL),
       decode(hc.ktfbhccval, 0, hc.ktfbhcmaxsz, NULL),
       decode(hc.ktfbhccval, 0, hc.ktfbhcinc, NULL),
       decode(hc.ktfbhccval, 0, hc.ktfbhcusz * ts.blocksize, NULL),
       decode(hc.ktfbhccval, 0, hc.ktfbhcusz, NULL),
       decode(fe.fetsn, 0, decode(bitand(fe.festa, 2), 0, 'SYSOFF', 'SYSTEM'),
       decode(bitand(fe.festa, 18), 0, 'OFFLINE', 2, 'ONLINE', 'RECOVER')),
       decode(bitand(f.spare2, 3), NULL, 'OFF', 0, 'OFF', 1, 'ENABLED', 2, 'SUSPEND')
from sys.v$dbfile v, sys.file$ f, sys.x$ktfbhc hc, sys.ts$ ts,
     (select * from x$kccfe
      where (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))) fe
where v.file# = f.file#
  and f.spare1 is NOT NULL
  and v.file# = hc.ktfbhcafno
  and hc.ktfbhctsn = ts.ts#
  and fe.fenum = f.file#
/
create or replace public synonym DBA_DATA_FILES for DBA_DATA_FILES
/
grant select on DBA_DATA_FILES to select_catalog_role
/
comment on table DBA_DATA_FILES is
'Information about database data files'
/
comment on column DBA_DATA_FILES.FILE_NAME is
'Name of the database data file'
/
comment on column DBA_DATA_FILES.FILE_ID is
'ID of the database data file'
/
comment on column DBA_DATA_FILES.TABLESPACE_NAME is
'Name of the tablespace to which the file belongs'
/
comment on column DBA_DATA_FILES.BYTES is
'Size of the file in bytes'
/
comment on column DBA_DATA_FILES.BLOCKS is
'Size of the file in ORACLE blocks'
/
comment on column DBA_DATA_FILES.STATUS is
'File status:  "INVALID" or "AVAILABLE"'
/
comment on column DBA_DATA_FILES.RELATIVE_FNO is
'Tablespace-relative file number'
/
comment on column DBA_DATA_FILES.AUTOEXTENSIBLE is
'Autoextensible indicator:  "YES" or "NO"'
/
comment on column DBA_DATA_FILES.MAXBYTES is
'Maximum autoextensible file size in bytes'
/
comment on column DBA_DATA_FILES.MAXBLOCKS is
'Maximum autoextensible file size in blocks'
/
comment on column DBA_DATA_FILES.INCREMENT_BY is
'Default increment for autoextension'
/
comment on column DBA_DATA_FILES.USER_BYTES is
'Size of the useful portion of file in bytes'
/
comment on column DBA_DATA_FILES.USER_BLOCKS is
'Size of the useful portion of file in ORACLE blocks'
/
comment on column DBA_DATA_FILES.ONLINE_STATUS IS
'Online status of the file'
/
comment on column DBA_DATA_FILES.LOST_WRITE_PROTECT IS
'Lost write protection status of file - also check tablespace setting'
/
execute CDBView.create_cdbview(false,'SYS','DBA_DATA_FILES','CDB_DATA_FILES');
grant select on SYS.CDB_DATA_FILES to select_catalog_role
/
create or replace public synonym CDB_DATA_FILES for SYS.CDB_DATA_FILES
/

create or replace view FILEXT$
    (FILE#, MAXEXTEND, INC)
as
select f.file_id, f.maxblocks, f.increment_by
from sys.dba_data_files f where f.increment_by <> 0
/
comment on table FILEXT$ is
'Information about extensible files'
/
comment on column FILEXT$.FILE# is
'ID of the database file'
/
comment on column FILEXT$.MAXEXTEND is
'Maximum size of the file in ORACLE blocks'
/
comment on column FILEXT$.INC is
'Default increment for autoextension'
/
grant select on FILEXT$ to select_catalog_role
/
remark
remark  FAMILY "TABLESPACES"
remark  CREATE TABLESPACE parameters, except datafiles.
remark  This family has no ALL member.
remark
create or replace view USER_TABLESPACES
    (TABLESPACE_NAME, BLOCK_SIZE, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS,
     MAX_EXTENTS, MAX_SIZE, PCT_INCREASE, MIN_EXTLEN,
     STATUS, CONTENTS, LOGGING, FORCE_LOGGING,
     EXTENT_MANAGEMENT, ALLOCATION_TYPE, 
     SEGMENT_SPACE_MANAGEMENT, DEF_TAB_COMPRESSION, RETENTION, BIGFILE,
     PREDICATE_EVALUATION, ENCRYPTED, COMPRESS_FOR,
     DEF_INMEMORY, DEF_INMEMORY_PRIORITY, DEF_INMEMORY_DISTRIBUTE,
     DEF_INMEMORY_COMPRESSION, DEF_INMEMORY_DUPLICATE, SHARED,
     DEF_INDEX_COMPRESSION, INDEX_COMPRESS_FOR, DEF_CELLMEMORY,
     DEF_INMEMORY_SERVICE, DEF_INMEMORY_SERVICE_NAME, LOST_WRITE_PROTECT,
     CHUNK_TABLESPACE)
as select ts.name, ts.blocksize, ts.blocksize * ts.dflinit,
          decode(bitand(ts.flags, 3), 1, to_number(NULL), 
                        ts.blocksize * ts.dflincr), 
          ts.dflminext,
          decode(ts.contents$, 1, to_number(NULL), ts.dflmaxext), 
          decode(bitand(ts.flags, 4096), 4096, ts.affstrength, NULL),
          decode(bitand(ts.flags, 3), 1, to_number(NULL), ts.dflextpct),
          ts.blocksize * ts.dflminlen,
          decode(ts.online$, 1, 'ONLINE', 2, 'OFFLINE',
                 4, 'READ ONLY', 'UNDEFINED'),
          decode(ts.contents$, 0, 
                (decode(bitand(ts.flags, 4503599627370512), 16, 'UNDO', 
                 4503599627370496, 'LOST WRITE PROTECTION',  
                 'PERMANENT')), 1, 'TEMPORARY'),
          decode(bitand(ts.dflogging, 1), 0, 'NOLOGGING', 1, 'LOGGING'),
          decode(bitand(ts.dflogging, 2), 0, 'NO', 2, 'YES'),
          decode(ts.bitmapped, 0, 'DICTIONARY', 'LOCAL'),
          decode(bitand(ts.flags, 3), 0, 'USER', 1, 'SYSTEM', 2, 'UNIFORM',
                 'UNDEFINED'),
          decode(bitand(ts.flags,32), 32,'AUTO', 'MANUAL'),
          --DEF_TAB_COMPRESSION (KTT_COMPRESSED || KTT_TBL_COMPRESSED)
          decode(bitand(ts.flags,64+2251799813685248), 0, 'DISABLED', 
                        64, 'ENABLED', 2251799813685248, 'ENABLED', 
                        (64+2251799813685248), 'ENABLED'),
          decode(bitand(ts.flags,16), 16, (decode(bitand(ts.flags, 512), 512,
                 'GUARANTEE', 'NOGUARANTEE')), 'NOT APPLY'),
          decode(bitand(ts.flags,256), 256, 'YES', 'NO'),
          decode(tsattr.storattr, 1, 'STORAGE', 'HOST'),
          decode(bitand(ts.flags,16384), 16384, 'YES', 'NO'),
          --COMPRESS_FOR ktstsflg (ktt3.h)
          decode(bitand(ts.flags,64+2251799813685248), 0, null,
            (case when bitand(ts.flags,  65536) = 65536 
                    then 'ADVANCED'
                  when bitand(ts.flags, (131072+262144)) = 131072 
                    then concat('QUERY LOW',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, (131072+262144)) = 262144 
                    then concat('QUERY HIGH',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, (131072+262144)) = (131072+262144) 
                    then concat('ARCHIVE LOW',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, 524288) = 524288 
                    then concat('ARCHIVE HIGH',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  else 'BASIC' end)),
          --DEF_INMEMORY ktstsflg (ktt3.h)
          decode(bitand(ts.flags, 2203318222848),
                  4294967296,     'ENABLED',
                  2199023255552,  'DISABLED', 'DISABLED'),
          --DEF_INMEMORY_PRIORITY
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 34359738368), 34359738368, 
                        decode(bitand(ts.flags, 123145302310912),
                        17592186044416, 'LOW',
                        35184372088832, 'MEDIUM',
                        52776558133248, 'HIGH',
                        70368744177664, 'CRITICAL', 'NONE'),
                        'NONE'),
                 null),
          --DEF_INMEMORY_DISTRIBUTE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 8589934592), 8589934592,
                        decode(bitand(ts.flags, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        null),
                  null),
          --DEF_INMEMORY_COMPRESSION
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null),
          --DEF_INMEMORY_DUPLICATE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 13194139533312),
                         4398046511104, 'NO DUPLICATE',
                         8796093022208, 'DUPLICATE',
                         13194139533312, 'DUPLICATE ALL', null),
                 null),
          --SHARED
          -- Bits: 0x800000000002
          decode(bitand(ts.flags, 18155135997837312),
                 140737488355328, 'LOCAL_ON_LEAF',
                 18155135997837312, 'LOCAL_ON_ALL', 'SHARED') shared,
          --DEF_INDEX_COMPRESSION (KTT_COMPRESSED || KTT_IDX_COMPRESSED)
          decode(bitand(ts.flags,(64+281474976710656)), 0, 'DISABLED',
                        64, 'ENABLED', 281474976710656, 'ENABLED',
                        (64+281474976710656), 'ENABLED'),
          --INDEX_COMPRESS_FOR
          -- Bits: 0x1000000000000 and 0x6000000000000 and F0000
          decode(bitand(ts.flags, 64), 0,
                    (decode(bitand(ts.flags, 281474976710656), 0, null,
                            (decode(bitand(ts.flags,
                                     (562949953421312 + 1125899906842624)),
                             0,                'NONE',
                             562949953421312,  'ADVANCED LOW',
                             1125899906842624, 'ADVANCED HIGH', 'UNKNOWN')))),
                    (decode(bitand(ts.flags, (65536+131072+262144+524288)),
                             0,                'NONE', 
                             -- table OLTP
                             65536,            'ADVANCED LOW', 
                             -- table Query Low
                             131072,           'ADVANCED HIGH',
                             -- table Query High
                             262144,           'ADVANCED HIGH',
                             -- table Archive Low
                             (131072+262144),  'ADVANCED HIGH',
                             -- table Archive High
                             524288,           'ADVANCED HIGH', 'UNKNOWN'))),
          -- DEF_CELLMEMORY ktstsflg (ktt3.h)
          -- 0xF80000000000000
          decode(bitand(ts.flags, 1116892707587883008),
                         36028797018963968, 'ENABLED', 
                         72057594037927936, 'DISABLED',
                        180143985094819840, 'NO CACHECOMPRESS',
                        324259173170675712, 'FOR QUERY', 
                        612489549322387456, 'FOR CAPACITY', null),
          -- DEF_INMEMORY_SERVICE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 1152921504606846976),
                        1152921504606846976,
                        decode(bitand(svc.svcflags,7),
                               1, 'DEFAULT',
                               2, 'NONE',
                               3, 'ALL',
                               4, 'USER_DEFINED',
                               'DEFAULT'),
                        'DEFAULT'),
                 null),
          -- DEF_INMEMORY_SERVICE_NAME
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 1152921504606846976),
                        1152921504606846976, svc.svcname, null),
                  null),
          -- LOST_WRITE_PROTECT
          -- Bits: 0x2000000000000000 and 0x4000000000000000
          -- KTT_LOST_ENABLED and KTT_LOST_SUSPEND (suspended)
          decode(bitand(ts.flags, 6917529027641081856), 0, 'OFF',
                  2305843009213693952, 'ENABLED',
                  4611686018427387904, 'SUSPEND'),
          --Bit: 0x8000000000000000 
          --CHUNK_TABLESPACE
          decode(bitand(ts.flags,9223372036854775808),9223372036854775808,'Y','N')
from sys.ts$ ts, x$kcfistsa tsattr, sys.imsvcts$ svc
where ts.online$ != 3 
and bitand(flags,2048) != 2048
      and (   exists (select null from sys.tsq$ tsq
                 where tsq.ts# = ts.ts#
                   and tsq.user# = userenv('SCHEMAID') and 
                   (tsq.blocks > 0 or tsq.maxblocks != 0))
           or exists
              (select null
              from sys.v$enabledprivs
              where priv_number = -15 /* UNLIMITED TABLESPACE */))
      and ts.ts# = tsattr.tsid and ts.ts# = svc.ts# (+)
/
comment on table USER_TABLESPACES is
'Description of accessible tablespaces'
/
comment on column USER_TABLESPACES.TABLESPACE_NAME is
'Tablespace name'
/
comment on column USER_TABLESPACES.BLOCK_SIZE is
'Tablespace block size'
/
comment on column USER_TABLESPACES.INITIAL_EXTENT is
'Default initial extent size'
/
comment on column USER_TABLESPACES.NEXT_EXTENT is
'Default incremental extent size'
/
comment on column USER_TABLESPACES.MIN_EXTENTS is
'Default minimum number of extents'
/
comment on column USER_TABLESPACES.MAX_EXTENTS is
'Default maximum number of extents'
/
comment on column USER_TABLESPACES.MAX_SIZE is
'Default maximum size of segments'
/
comment on column USER_TABLESPACES.PCT_INCREASE is
'Default percent increase for extent size'
/
comment on column USER_TABLESPACES.MIN_EXTLEN is
'Minimum extent size for the tablespace'
/
comment on column USER_TABLESPACES.STATUS is
'Tablespace status: "ONLINE", "OFFLINE", or "READ ONLY"'
/
comment on column USER_TABLESPACES.CONTENTS is
'Tablespace contents: "PERMANENT", or "TEMPORARY"'
/
comment on column USER_TABLESPACES.LOGGING is
'Default logging attribute'
/
comment on column USER_TABLESPACES.FORCE_LOGGING is
'Tablespace force logging mode'
/
comment on column USER_TABLESPACES.EXTENT_MANAGEMENT is
'Extent management tracking: "DICTIONARY" or "LOCAL"'
/
comment on column USER_TABLESPACES.ALLOCATION_TYPE is
'Type of extent allocation in effect for this tablespace'
/
comment on column USER_TABLESPACES.SEGMENT_SPACE_MANAGEMENT is
'Segment space management tracking: "AUTO" or "MANUAL"'
/ 
comment on column USER_TABLESPACES.DEF_TAB_COMPRESSION is
'Default table compression enabled or not: "ENABLED" or "DISABLED"'
/
comment on column USER_TABLESPACES.RETENTION is
'Undo tablespace retention: "GUARANTEE", "NOGUARANTEE" or "NOT APPLY"'
/
comment on column USER_TABLESPACES.BIGFILE is
'Bigfile tablespace indicator: "YES" or "NO"'
/
comment on column USER_TABLESPACES.PREDICATE_EVALUATION is
'Predicates evaluated by: "HOST" or "STORAGE"'
/ 
comment on column USER_TABLESPACES.ENCRYPTED is
'Encrypted tablespace indicator: "YES" or "NO"'
/
comment on column USER_TABLESPACES.COMPRESS_FOR is
'Default compression for what kind of operations'
/
comment on column USER_TABLESPACES.DEF_INMEMORY is
'Default in-memory attribute'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_PRIORITY is
'Default priority in which in-memory column store objects are loaded'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_DISTRIBUTE is
'Default for how in-memory columnar store objects are distributed'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_COMPRESSION is
'Default compression level for the in-memory column store option'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_DUPLICATE is
'Default for how in-memory column store objects are duplicated'
/
comment on column USER_TABLESPACES.SHARED is
'Local temp tablespace type: "LOCAL_ON_LEAF" or "LOCAL_ON_ALL" or "SHARED"'
/
comment on column USER_TABLESPACES.DEF_INDEX_COMPRESSION is
'Default index compression enabled or not: "ENABLED" or "DISABLED"'
/
comment on column USER_TABLESPACES.INDEX_COMPRESS_FOR is
'Default index compression level: "ADVANCED HIGH/LOW" or "NONE"'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_SERVICE is
'How the in-memory columnar store objects are distributed for service'
/
comment on column USER_TABLESPACES.DEF_INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store objects are distributed'
/
comment on column USER_TABLESPACES.LOST_WRITE_PROTECT is
'LOST_WRITE indicator: "OFF" or "ENABLED" or "SUSPEND" - also check dba_data_files'
/
comment on column USER_TABLESPACES.DEF_CELLMEMORY is
'Default for columnar compression in storage cell flash cache'
/
create or replace public synonym USER_TABLESPACES for USER_TABLESPACES
/
grant read on USER_TABLESPACES to PUBLIC with grant option
/
create or replace view DBA_TABLESPACES
    (TABLESPACE_NAME, BLOCK_SIZE, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS,
     MAX_EXTENTS, MAX_SIZE, PCT_INCREASE, MIN_EXTLEN,
     STATUS, CONTENTS, LOGGING, FORCE_LOGGING, EXTENT_MANAGEMENT, 
     ALLOCATION_TYPE, PLUGGED_IN,
     SEGMENT_SPACE_MANAGEMENT, DEF_TAB_COMPRESSION, RETENTION, BIGFILE,
     PREDICATE_EVALUATION, ENCRYPTED, COMPRESS_FOR, 
     DEF_INMEMORY, DEF_INMEMORY_PRIORITY, DEF_INMEMORY_DISTRIBUTE,
     DEF_INMEMORY_COMPRESSION, DEF_INMEMORY_DUPLICATE, SHARED,
     DEF_INDEX_COMPRESSION, INDEX_COMPRESS_FOR, DEF_CELLMEMORY,
     DEF_INMEMORY_SERVICE, DEF_INMEMORY_SERVICE_NAME, LOST_WRITE_PROTECT,
     CHUNK_TABLESPACE)
as select ts.name, ts.blocksize, ts.blocksize * ts.dflinit,
          decode(bitand(ts.flags, 3), 1, to_number(NULL), 
                 ts.blocksize * ts.dflincr), 
          ts.dflminext,
          decode(ts.contents$, 1, to_number(NULL), ts.dflmaxext), 
          decode(bitand(ts.flags, 4096), 4096, ts.affstrength, NULL),
          decode(bitand(ts.flags, 3), 1, to_number(NULL), ts.dflextpct),
          ts.blocksize * ts.dflminlen,
          decode(ts.online$, 1, 'ONLINE', 2, 'OFFLINE',
                 4, 'READ ONLY', 'UNDEFINED'),
          decode(ts.contents$, 0,
                (decode(bitand(ts.flags, 4503599627370512), 16, 'UNDO',
                 4503599627370496, 'LOST WRITE PROTECTION',
                 'PERMANENT')), 1, 'TEMPORARY'), 
          decode(bitand(ts.dflogging, 1), 0, 'NOLOGGING', 1, 'LOGGING'),
          decode(bitand(ts.dflogging, 2), 0, 'NO', 2, 'YES'),
          decode(ts.bitmapped, 0, 'DICTIONARY', 'LOCAL'),
          decode(bitand(ts.flags, 3), 0, 'USER', 1, 'SYSTEM', 2, 'UNIFORM',
                 'UNDEFINED'),
          decode(ts.plugged, 0, 'NO', 'YES'),
          decode(bitand(ts.flags,32), 32,'AUTO', 'MANUAL'),
          --DEF_TAB_COMPRESSION (KTT_COMPRESSED || KTT_TBL_COMPRESSED)
          decode(bitand(ts.flags,64+2251799813685248), 0, 'DISABLED', 
                        64, 'ENABLED', 2251799813685248, 'ENABLED', 
                        (64+2251799813685248), 'ENABLED'),  
          decode(bitand(ts.flags,16), 16, (decode(bitand(ts.flags, 512), 512, 
                 'GUARANTEE', 'NOGUARANTEE')), 'NOT APPLY'), 
          decode(bitand(ts.flags,256), 256, 'YES', 'NO'),
          decode(tsattr.storattr, 1, 'STORAGE', 'HOST'),
          decode(bitand(ts.flags,16384), 16384, 'YES', 'NO'),
          --COMPRESS_FOR ktstsflg (ktt3.h)
          decode(bitand(ts.flags,(64+2251799813685248)), 0, null,
            (case when bitand(ts.flags,  65536) = 65536 
                    then 'ADVANCED'
                  when bitand(ts.flags, (131072+262144)) = 131072 
                    then concat('QUERY LOW',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, (131072+262144)) = 262144 
                    then concat('QUERY HIGH',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, (131072+262144)) = (131072+262144) 
                    then concat('ARCHIVE LOW',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  when bitand(ts.flags, 524288) = 524288 
                    then concat('ARCHIVE HIGH',
                                decode(bitand(ts.flags, 4194304), 4194304,
                                       ' ROW LEVEL LOCKING', ''))
                  else 'BASIC' end)),
          --DEF_INMEMORY ktstsflg (ktt3.h)
          decode(bitand(ts.flags, 2203318222848),
                  4294967296,     'ENABLED',
                  2199023255552,  'DISABLED', 'DISABLED'),
          --DEF_INMEMORY_PRIORITY
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 34359738368), 34359738368,
                        decode(bitand(ts.flags, 123145302310912),
                        17592186044416, 'LOW',
                        35184372088832, 'MEDIUM',
                        52776558133248, 'HIGH',
                        70368744177664, 'CRITICAL', 'NONE'),
                        'NONE'),
                 null),
          --DEF_INMEMORY_DISTRIBUTE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 8589934592), 8589934592,
                        decode(bitand(ts.flags, 206158430208),
                        68719476736,   'BY ROWID RANGE',
                        137438953472,  'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        null),
                  null),
          --DEF_INMEMORY_COMPRESSION
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 841813590016),
                              17179869184,  'NO MEMCOMPRESS',
                              274877906944, 'FOR DML',
                              292057776128, 'FOR QUERY LOW',
                              549755813888, 'FOR QUERY HIGH',
                              566935683072, 'FOR CAPACITY LOW',
                              824633720832, 'FOR CAPACITY HIGH', 'UNKNOWN'),
                 null),
          --DEF_INMEMORY_DUPLICATE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 13194139533312),
                         4398046511104, 'NO DUPLICATE',
                         8796093022208, 'DUPLICATE',
                         13194139533312, 'DUPLICATE ALL', null),
                 null),
          --SHARED
          decode(bitand(ts.flags, 18155135997837312), 
                 140737488355328, 'LOCAL_ON_LEAF',
                 18155135997837312, 'LOCAL_ON_ALL', 'SHARED') shared,
          --DEF_INDEX_COMPRESSION (KTT_COMPRESSED || KTT_IDX_COMPRESSED)
          decode(bitand(ts.flags,(64+281474976710656)), 0, 'DISABLED',
                         64, 'ENABLED', 281474976710656, 'ENABLED',
                         (64+281474976710656), 'ENABLED'),
          --INDEX_COMPRESS_FOR
          decode(bitand(ts.flags, 64), 0,
                    (decode(bitand(ts.flags, 281474976710656), 0, null,
                            (decode(bitand(ts.flags,
                                     (562949953421312 + 1125899906842624)),
                             0,                'NONE',
                             562949953421312,  'ADVANCED LOW',
                             1125899906842624, 'ADVANCED HIGH', 'UNKNOWN')))),
                    (decode(bitand(ts.flags, (65536+131072+262144+524288)),
                             0,                'NONE', 
                             -- table OLTP
                             65536,            'ADVANCED LOW', 
                             -- table Query Low
                             131072,           'ADVANCED HIGH',
                             -- table Query High
                             262144,           'ADVANCED HIGH',
                             -- table Archive Low
                             (131072+262144),  'ADVANCED HIGH',
                             -- table Archive High
                             524288,           'ADVANCED HIGH', 'UNKNOWN'))),
           -- DEF_CELLMEMORY ktstsflg (ktt3.h)
           -- 0xF80000000000000
                decode(bitand(ts.flags, 1116892707587883008),
                              36028797018963968, 'ENABLED', 
                              72057594037927936, 'DISABLED',
                             180143985094819840, 'NO MEMCOMPRESS',
                             324259173170675712, 'FOR QUERY', 
                             612489549322387456, 'FOR CAPACITY', null),
          -- DEF_INMEMORY_SERVICE
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 1152921504606846976),
                        1152921504606846976,
                        decode(bitand(svc.svcflags,7),
                               1, 'DEFAULT',
                               2, 'NONE',
                               3, 'ALL',
                               4, 'USER_DEFINED',
                               'DEFAULT'),
                        'DEFAULT'),
                 null),
          -- DEF_INMEMORY_SERVICE_NAME
          decode(bitand(ts.flags, 4294967296), 4294967296,
                 decode(bitand(ts.flags, 1152921504606846976),
                        1152921504606846976, svc.svcname, null),
                 null),
           -- LOST_WRITE_PROTECT
           -- Bits: 0x2000000000000000 and 0x4000000000000000
           -- KTT_LOST_ENABLED and KTT_LOST_SUSPEND (suspended)
           decode(bitand(ts.flags, 6917529027641081856), 0, 'OFF',
                  2305843009213693952, 'ENABLED',
                  4611686018427387904, 'SUSPEND'),
           -- Bit: 0x8000000000000000
           --CHUNK_TABLEPSACE
          decode(bitand(ts.flags,9223372036854775808),9223372036854775808,'Y','N')
from sys.ts$ ts, sys.x$kcfistsa tsattr, sys.imsvcts$ svc
where ts.online$ != 3 
and bitand(flags,2048) != 2048
and ts.ts# = tsattr.tsid
and ts.ts# = svc.ts# (+)
/
create or replace public synonym DBA_TABLESPACES for DBA_TABLESPACES
/
grant select on DBA_TABLESPACES to select_catalog_role
/
comment on table DBA_TABLESPACES is
'Description of all tablespaces'
/
comment on column DBA_TABLESPACES.TABLESPACE_NAME is
'Tablespace name'
/
comment on column DBA_TABLESPACES.BLOCK_SIZE is
'Tablespace block size'
/
comment on column DBA_TABLESPACES.INITIAL_EXTENT is
'Default initial extent size'
/
comment on column DBA_TABLESPACES.NEXT_EXTENT is
'Default incremental extent size'
/
comment on column DBA_TABLESPACES.MIN_EXTENTS is
'Default minimum number of extents'
/
comment on column DBA_TABLESPACES.MAX_SIZE is
'Default maximum size of segments'
/
comment on column DBA_TABLESPACES.PCT_INCREASE is
'Default percent increase for extent size'
/
comment on column DBA_TABLESPACES.MIN_EXTLEN is
'Minimum extent size for the tablespace'
/
comment on column DBA_TABLESPACES.STATUS is
'Tablespace status: "ONLINE", "OFFLINE", or "READ ONLY"'
/
comment on column DBA_TABLESPACES.CONTENTS is
'Tablespace contents: "PERMANENT", or "TEMPORARY"'
/
comment on column DBA_TABLESPACES.LOGGING is
'Default logging attribute'
/
comment on column DBA_TABLESPACES.FORCE_LOGGING is
'Tablespace force logging mode'
/
comment on column DBA_TABLESPACES.EXTENT_MANAGEMENT is
'Extent management tracking: "DICTIONARY" or "LOCAL"'
/
comment on column DBA_TABLESPACES.ALLOCATION_TYPE is
'Type of extent allocation in effect for this tablespace'
/
comment on column DBA_TABLESPACES.SEGMENT_SPACE_MANAGEMENT is
'Segment space management tracking: "AUTO" or "MANUAL"'
/ 
comment on column DBA_TABLESPACES.DEF_TAB_COMPRESSION is
'Default table compression enabled or not: "ENABLED" or "DISABLED"'
/
comment on column DBA_TABLESPACES.RETENTION is
'Undo tablespace retention: "GUARANTEE", "NOGUARANTEE" or "NOT APPLY"'
/
comment on column DBA_TABLESPACES.BIGFILE is
'Bigfile tablespace indicator: "YES" or "NO"'
/
comment on column DBA_TABLESPACES.PREDICATE_EVALUATION is
'Predicates evaluated by: "HOST" or "STORAGE"'
/ 
comment on column DBA_TABLESPACES.ENCRYPTED is
'Encrypted tablespace indicator: "YES" or "NO"'
/
comment on column DBA_TABLESPACES.COMPRESS_FOR is
'Default compression for what kind of operations'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY is
'Default in-memory attribute'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_PRIORITY is
'Default priority in which in-memory column store objects are loaded'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_DISTRIBUTE is
'Default for how in-memory columnar store objects are distributed'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_COMPRESSION is
'Default compression level for the in-memory column store option'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_DUPLICATE is
'Default for how in-memory column store objects are duplicated'
/
comment on column DBA_TABLESPACES.SHARED is
'Local temp tablespace type: "LOCAL_ON_LEAF" or "LOCAL_ON_ALL" or "SHARED"'
/
comment on column DBA_TABLESPACES.DEF_INDEX_COMPRESSION is
'Default index compression enabled or not: "ENABLED" or "DISABLED"'
/
comment on column DBA_TABLESPACES.INDEX_COMPRESS_FOR is
'Default index compression level: "ADVANCED HIGH/LOW" or "NONE"'
/
comment on column DBA_TABLESPACES.DEF_CELLMEMORY is
'Default for columnar compression in storage cell flash cache'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_SERVICE is
'How the in-memory columnar store objects are distributed for service'
/
comment on column DBA_TABLESPACES.DEF_INMEMORY_SERVICE_NAME is
'Service on which the in-memory columnar store objects are distributed'
/
comment on column DBA_TABLESPACES.LOST_WRITE_PROTECT is
'LOST_WRITE indicator: "OFF" or "ENABLED" or "SUSPEND" '
/
execute CDBView.create_cdbview(false,'SYS','DBA_TABLESPACES','CDB_TABLESPACES');
grant select on SYS.CDB_TABLESPACES to select_catalog_role
/
create or replace public synonym CDB_TABLESPACES for SYS.CDB_TABLESPACES
/

remark 
remark  Following views related to temporary tablespaces
remark  FAMILY "TEMP_FILES"
remark  Information about database temp files on per instance basis.
remark  This family has a DBA member only.
remark  ### we should probably not use kccfn here
create or replace view DBA_TEMP_FILES
    (FILE_NAME, FILE_ID, TABLESPACE_NAME,
     BYTES, BLOCKS, STATUS, RELATIVE_FNO, AUTOEXTENSIBLE,
     MAXBYTES, MAXBLOCKS, INCREMENT_BY, USER_BYTES, USER_BLOCKS,
     SHARED, INST_ID)
as
select /*+ ordered use_nl(hc) */
       ti.file_name, ti.file_id, ts.name,
       decode(ti.current_value, 0, ts.blocksize * ti.blocks, NULL),
       decode(ti.current_value, 0, ti.blocks, NULL),
       ti.status,
       decode(ti.current_value, 0, ti.relative_fno, NULL),
       decode(ti.current_value, 0, decode(ti.increment_by, 0, 'NO', 'YES'), NULL),
       decode(ti.current_value, 0, ts.blocksize * ti.maxblocks, NULL),
       decode(ti.current_value, 0, ti.maxblocks, NULL),
       decode(ti.current_value, 0, ti.increment_by, NULL),
       decode(ti.current_value, 0, ts.blocksize * ti.user_blocks, NULL),
       decode(ti.current_value, 0, ti.user_blocks, NULL),
       decode(bitand(ts.flags, 18155135997837312),
              140737488355328, 'LOCAL_ON_LEAF',
              18155135997837312, 'LOCAL_ON_ALL', 'SHARED'),
       null as inst_id
 from v$tempfile_info_instance ti,
      sys.ts$ ts
where ti.tablespace_number = ts.ts#
  and decode(bitand(ts.flags, 18155135997837312),
              140737488355328, 'LOCAL_ON_LEAF',
              18155135997837312, 'LOCAL_ON_ALL', 'SHARED') = 'SHARED'
union
select /*+ ordered use_nl(hc) */
       ti.file_name, ti.file_id, ts.name,
       decode(ti.current_value, 0, ts.blocksize * ti.blocks, NULL),
       decode(ti.current_value, 0, ti.blocks, NULL),
       ti.status,
       decode(ti.current_value, 0, ti.relative_fno, NULL),
       decode(ti.current_value, 0, decode(ti.increment_by, 0, 'NO', 'YES'), NULL),
       decode(ti.current_value, 0, ts.blocksize * ti.maxblocks, NULL),
       decode(ti.current_value, 0, ti.maxblocks, NULL),
       decode(ti.current_value, 0, ti.increment_by, NULL),
       decode(ti.current_value, 0, ts.blocksize * ti.user_blocks, NULL),
       decode(ti.current_value, 0, ti.user_blocks, NULL),
       decode(bitand(ts.flags, 18155135997837312),
              140737488355328, 'LOCAL_ON_LEAF',
              18155135997837312, 'LOCAL_ON_ALL', 'SHARED'),
       ti.inst_id
 from gv$tempfile_info_instance ti,
      gv$instance inst,
      sys.ts$ ts
where ti.inst_id = inst.inst_id
  and ti.tablespace_number = ts.ts#
  and ((decode(bitand(ts.flags, 18155135997837312),
              140737488355328, 'LOCAL_ON_LEAF',
              18155135997837312, 'LOCAL_ON_ALL', 'SHARED') = 'LOCAL_ON_ALL'
        and inst.instance_mode = 'REGULAR')
       or (decode(bitand(ts.flags, 18155135997837312),
              140737488355328, 'LOCAL_ON_LEAF',
              18155135997837312, 'LOCAL_ON_ALL', 'SHARED') 
           in ('LOCAL_ON_ALL', 'LOCAL_ON_LEAF')
        and inst.instance_mode = 'READ ONLY'))
/

create or replace public synonym DBA_TEMP_FILES for DBA_TEMP_FILES
/
grant select on DBA_TEMP_FILES to select_catalog_role
/
comment on table DBA_TEMP_FILES is
'Information about database temp files for all instances'
/
comment on column DBA_TEMP_FILES.FILE_NAME is
'Name of the database temp file'
/
comment on column DBA_TEMP_FILES.FILE_ID is
'ID of the database temp file'
/
comment on column DBA_TEMP_FILES.TABLESPACE_NAME is
'Name of the tablespace to which the file belongs'
/
comment on column DBA_TEMP_FILES.BYTES is
'Size of the file in bytes'
/
comment on column DBA_TEMP_FILES.BLOCKS is
'Size of the file in ORACLE blocks'
/
comment on column DBA_TEMP_FILES.STATUS is
'File status: "AVAILABLE"'
/
comment on column DBA_TEMP_FILES.RELATIVE_FNO is
'Tablespace-relative file number'
/
comment on column DBA_TEMP_FILES.AUTOEXTENSIBLE is
'Autoextensible indicator:  "YES" or "NO"'
/
comment on column DBA_TEMP_FILES.MAXBYTES is
'Maximum size of the file in bytes'
/
comment on column DBA_TEMP_FILES.MAXBLOCKS is
'Maximum size of the file in ORACLE blocks'
/
comment on column DBA_TEMP_FILES.INCREMENT_BY is
'Default increment for autoextension'
/
comment on column DBA_TEMP_FILES.USER_BYTES is
'Size of the useful portion of file in bytes'
/
comment on column DBA_TEMP_FILES.USER_BLOCKS is
'Size of the useful portion of file in ORACLE blocks'
/
comment on column DBA_TEMP_FILES.SHARED is
'Local temp tablespace type: "LOCAL_ON_LEAF" or "LOCAL_ON_ALL" or "SHARED"'
/
comment on column DBA_TEMP_FILES.INST_ID is
'Instance ID in which the temp file resides'
/

execute CDBView.create_cdbview(false,'SYS','DBA_TEMP_FILES','CDB_TEMP_FILES');
grant select on SYS.CDB_TEMP_FILES to select_catalog_role
/
create or replace public synonym CDB_TEMP_FILES for SYS.CDB_TEMP_FILES
/

create or replace view v_$temp_extent_map as select * from v$temp_extent_map;
create or replace public synonym v$temp_extent_map for v_$temp_extent_map;
grant select on v_$temp_extent_map to SELECT_CATALOG_ROLE;

create or replace view gv_$temp_extent_map as select * from gv$temp_extent_map;
create or replace public synonym gv$temp_extent_map for gv_$temp_extent_map;
grant select on gv_$temp_extent_map to SELECT_CATALOG_ROLE;

create or replace view v_$temp_extent_pool as select * from v$temp_extent_pool;
create or replace public synonym v$temp_extent_pool for v_$temp_extent_pool;
grant select on v_$temp_extent_pool to SELECT_CATALOG_ROLE;

create or replace view gv_$temp_extent_pool as select * from gv$temp_extent_pool;
create or replace public synonym gv$temp_extent_pool for gv_$temp_extent_pool;
grant select on gv_$temp_extent_pool to SELECT_CATALOG_ROLE;

create or replace view v_$temp_space_header as select * from v$temp_space_header;
create or replace public synonym v$temp_space_header for v_$temp_space_header;
grant select on v_$temp_space_header to SELECT_CATALOG_ROLE;

create or replace view gv_$temp_space_header as select * from gv$temp_space_header;
create or replace public synonym gv$temp_space_header
   for gv_$temp_space_header;
grant select on gv_$temp_space_header to SELECT_CATALOG_ROLE;

create or replace view v_$filespace_usage as select * from v$filespace_usage;
create or replace public synonym v$filespace_usage for v_$filespace_usage;
grant select on v_$filespace_usage to SELECT_CATALOG_ROLE;

create or replace view gv_$filespace_usage as select * from gv$filespace_usage;
create or replace public synonym gv$filespace_usage for gv_$filespace_usage;
grant select on gv_$filespace_usage to SELECT_CATALOG_ROLE;


remark
remark  FAMILY "TABLESPACE_GROUPS"
remark  CREATE TABLESPACE parameters, except datafiles.
remark  This family only has a DBA member.
remark
create or replace view DBA_TABLESPACE_GROUPS
    (GROUP_NAME,TABLESPACE_NAME)
as select ts2.name, ts.name
from ts$ ts, ts$ ts2
where ts.online$ != 3 
and bitand(ts.flags,1024) = 1024
    and ts.dflmaxext  = ts2.ts#
/
create or replace public synonym DBA_TABLESPACE_GROUPS for 
DBA_TABLESPACE_GROUPS
/
grant select on DBA_TABLESPACE_GROUPS to select_catalog_role
/
comment on table DBA_TABLESPACE_GROUPS is
'Description of all tablespace groups'
/
comment on column DBA_TABLESPACE_GROUPS.GROUP_NAME is
'Tablespace Group name'
/
comment on column DBA_TABLESPACE_GROUPS.TABLESPACE_NAME is
'Tablespace name'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TABLESPACE_GROUPS','CDB_TABLESPACE_GROUPS');
grant select on SYS.CDB_TABLESPACE_GROUPS to select_catalog_role
/
create or replace public synonym CDB_TABLESPACE_GROUPS for SYS.CDB_TABLESPACE_GROUPS
/

remark
remark  FAMILY "TABLESPACE_USAGE"
remark  This family only has a DBA member.
remark
create or replace view DBA_TABLESPACE_USAGE_METRICS
    (TABLESPACE_NAME, USED_SPACE, TABLESPACE_SIZE, USED_PERCENT)
as 
SELECT  t.name,
        tstat.kttetsused,
        tstat.kttetsmsize,
        (tstat.kttetsused / tstat.kttetsmsize) * 100
  FROM  sys.ts$ t, x$kttets tstat
  WHERE
        t.online$ != 3 and
        t.bitmapped <> 0 and
        t.contents$ = 0 and
        bitand(t.flags, 16) <> 16 and
        t.ts# = tstat.kttetstsn
union
 SELECT t.name, sum(f.allocated_space), sum(f.file_maxsize),
     (sum(f.allocated_space)/sum(f.file_maxsize))*100
     FROM sys.ts$ t, v$filespace_usage f
     WHERE
     t.online$ != 3 and
     t.bitmapped <> 0 and
     t.contents$ <> 0 and
     f.flag = 6 and
     t.ts# = f.tablespace_id
     GROUP BY t.name, f.tablespace_id, t.ts# 
union
 SELECT t.name, sum(f.allocated_space), sum(f.file_maxsize),
     (sum(f.allocated_space)/sum(f.file_maxsize))*100
     FROM sys.ts$ t, gv$filespace_usage f, gv$parameter param
     WHERE
     t.online$ != 3 and
     t.bitmapped <> 0 and
     f.inst_id = param.inst_id and
     param.name = 'undo_tablespace' and
     t.name = param.value and
     f.flag = 6 and
     t.ts# = f.tablespace_id
     GROUP BY t.name, f.tablespace_id, t.ts#
/

create or replace public synonym DBA_TABLESPACE_USAGE_METRICS for 
DBA_TABLESPACE_USAGE_METRICS
/
grant select on DBA_TABLESPACE_USAGE_METRICS to select_catalog_role
/
comment on table DBA_TABLESPACE_USAGE_METRICS is
'Description of all tablespace space usage metrics'
/
comment on column DBA_TABLESPACE_USAGE_METRICS.TABLESPACE_NAME is
'Tablespace name'
/
comment on column DBA_TABLESPACE_USAGE_METRICS.TABLESPACE_SIZE is
'Total size of the tablespace'
/
comment on column DBA_TABLESPACE_USAGE_METRICS.USED_SPACE is
'Total space consumed in the tablespace'
/
comment on column DBA_TABLESPACE_USAGE_METRICS.USED_PERCENT is
'% of used space, as a function of maximum possible tablespace size'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TABLESPACE_USAGE_METRICS','CDB_TABLESPACE_USAGE_METRICS');
grant select on SYS.CDB_TABLESPACE_USAGE_METRICS to select_catalog_role
/
create or replace public synonym CDB_TABLESPACE_USAGE_METRICS for SYS.CDB_TABLESPACE_USAGE_METRICS
/

Rem
Rem Auto Segment Advisor Control tables
Rem
Rem
--
-- We should not drop/recreate wri$_segadv_objlist.  If table and/or index
-- definition does change then request user to drop this table as part of
-- patch pre-install instructions.
--
begin
  execute immediate '
    CREATE TABLE wri$_segadv_objlist(
      auto_taskid   number,
      ts_id         number,
      objn          number,
      objd          number,
      status        varchar2(40),
      task_id       number,
      reason        varchar2(40),
      reason_value  number,
      creation_time timestamp(6),
      proc_taskid   number,
      end_time      timestamp(6),
      segment_owner     varchar2(128),
      segment_name      varchar2(128),
      partition_name    varchar2(128),
      segment_type      varchar2(18),
      tablespace_name   varchar2(30)
    )
     tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/
begin
  execute immediate '
    create index wri$_segadv_objlist_idx_aid on
    wri$_segadv_objlist(auto_taskid) tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/
begin
  execute immediate '
    create index wri$_segadv_objlist_idx_ts on
    wri$_segadv_objlist(ts_id) tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/
begin
  execute immediate '
    create index wri$_segadv_objlist_idx_obj on
    wri$_segadv_objlist(ts_id, objn, objd) tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/
begin
  execute immediate '
    create index wri$_segadv_objlist_idx_objd on
    wri$_segadv_objlist(objd) tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/

--
-- We should not drop/recreate wri$_segadv_cntrltab.  If table and definition
-- does change then request user to drop this table as part of patch 
-- pre-install instructions.
--
begin
  execute immediate '
    CREATE TABLE wri$_segadv_cntrltab(
      auto_taskid                    number,
      snapid                         number,
      segments_selected              number,
      segments_processed             number,
      tablespace_selected            number,
      tablespace_processed           number,
      recommendations_count          number,
      start_time                     timestamp(6),
      end_time                       timestamp(6),
      constraint wri$_segadv_cntrltab_pk primary key(auto_taskid)
      using index tablespace SYSAUX
    )
    tablespace SYSAUX';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/


Rem
REm Auto Segment Advisor Family of Views.
Rem
REm

CREATE OR REPLACE VIEW DBA_AUTO_SEGADV_CTL (AUTO_TASKID, TABLESPACE_NAME,
  SEGMENT_OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME,
  STATUS, REASON, REASON_VALUE,
  CREATION_TIME, PROCESSED_TASKID, END_TIME) as
select stats.auto_taskid, stats.tablespace_name, stats.segment_owner, 
       stats.segment_name, stats.segment_type, stats.partition_name, 
       stats.status, stats.reason, stats.reason_value,
       stats.creation_time, stats.proc_taskid, stats.end_time
from   wri$_segadv_objlist stats
/

comment on column DBA_AUTO_SEGADV_CTL.AUTO_TASKID is
'Creation Task id of the auto segment advisor job'
/
comment on column DBA_AUTO_SEGADV_CTL.TABLESPACE_NAME is
'Tablespace Name of the tablespace processed by the auto segment advisor'
/
comment on column DBA_AUTO_SEGADV_CTL.SEGMENT_OWNER is
'Owner of the segment processed by the auto segment advisor'
/
comment on column DBA_AUTO_SEGADV_CTL.SEGMENT_NAME is
'Name of the segment processed by the auto segment advisor'
/
comment on column DBA_AUTO_SEGADV_CTL.SEGMENT_TYPE is
'Type of the segment processed by the auto segment advisor'
/
comment on column DBA_AUTO_SEGADV_CTL.PARTITION_NAME is
'Name of the partition processed by the advisor'
/
comment on column DBA_AUTO_SEGADV_CTL.STATUS is
'Status of the auto advisor task for this segment or tablespace'
/
comment on column DBA_AUTO_SEGADV_CTL.REASON is
'Reason why this segment or tablespace is chosen for analysis'
/
comment on column DBA_AUTO_SEGADV_CTL.REASON_VALUE is
'Reason value for the segment or tablespace'
/
comment on column DBA_AUTO_SEGADV_CTL.CREATION_TIME is
'Time at which this entry was created'
/
comment on column DBA_AUTO_SEGADV_CTL.PROCESSED_TASKID is
'The auto task id that processed this segment'
/
comment on column DBA_AUTO_SEGADV_CTL.END_TIME is
'Time at which the segment was completely processed'
/
grant select on DBA_AUTO_SEGADV_CTL to select_catalog_role
/
grant read on DBA_AUTO_SEGADV_CTL to public
/
create or replace public synonym DBA_AUTO_SEGADV_CTL for 
            DBA_AUTO_SEGADV_CTL
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUTO_SEGADV_CTL','CDB_AUTO_SEGADV_CTL');
grant select on SYS.CDB_AUTO_SEGADV_CTL to select_catalog_role
/
grant read on SYS.CDB_AUTO_SEGADV_CTL to public 
/
create or replace public synonym CDB_AUTO_SEGADV_CTL for SYS.CDB_AUTO_SEGADV_CTL
/

CREATE OR REPLACE view DBA_AUTO_SEGADV_SUMMARY (
  AUTO_TASKID, SNAPID, SEGMENTS_SELECTED, SEGMENTS_PROCESSED, TABLESPACE_SELECTED,
  TABLESPACE_PROCESSED, RECOMMENDATIONS_COUNT, START_TIME, END_TIME) as
select 
  AUTO_TASKID, SNAPID, SEGMENTS_SELECTED, SEGMENTS_PROCESSED, TABLESPACE_SELECTED,
  TABLESPACE_PROCESSED, RECOMMENDATIONS_COUNT, START_TIME, END_TIME 
from wri$_segadv_cntrltab
/
comment on column DBA_AUTO_SEGADV_SUMMARY.AUTO_TASKID is
'Creation Task id of the auto segment advisor job'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.SNAPID is
'Minimum AWR Snapid that was used to process'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.SEGMENTS_SELECTED is
'Number of segments selected for analysis'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.SEGMENTS_PROCESSED is
'Number of segments successfully processed'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.TABLESPACE_SELECTED is
'Number of tablespaces selected for analysis'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.TABLESPACE_PROCESSED is
'Number of tablespaces successfully processed'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.RECOMMENDATIONS_COUNT is
'Number of recommendations generated'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.START_TIME is
'Time at which this task was started'
/
comment on column DBA_AUTO_SEGADV_SUMMARY.END_TIME is
'Time at which this task ended'
/
grant select on DBA_AUTO_SEGADV_SUMMARY to select_catalog_role
/
grant read on DBA_AUTO_SEGADV_SUMMARY to public
/
create or replace public synonym DBA_AUTO_SEGADV_SUMMARY for 
            DBA_AUTO_SEGADV_SUMMARY
/


execute CDBView.create_cdbview(false,'SYS','DBA_AUTO_SEGADV_SUMMARY','CDB_AUTO_SEGADV_SUMMARY');
grant read on SYS.CDB_AUTO_SEGADV_SUMMARY to public 
/
create or replace public synonym CDB_AUTO_SEGADV_SUMMARY for SYS.CDB_AUTO_SEGADV_SUMMARY
/

Rem
Rem Temp Tables needed by the auto advisor
Rem
--
-- We should not drop/recreate wri$_adv_asa_reco_data.  If table definition
-- does change then request user to drop this table as part of patch 
-- pre-install instructions.
--
begin
  execute immediate '
    create global temporary table sys.wri$_adv_asa_reco_data 
    (task_id number, ctime timestamp, segowner varchar2(128), 
    segname varchar2(128), segtype varchar2(128), 
    partname varchar2(128), tsname varchar2(128), 
    benefit_type number,
    usp number, alsp number, rec number, chct number, cmd_id number,
    c1 varchar2(1000), c2 varchar2(1000), c3 varchar2(1000)) 
    on commit preserve rows';
  exception
    when others then
      if sqlcode != -955 then
        raise;
      end if;
end;
/
grant select, insert, delete on sys.wri$_adv_asa_reco_data to public
/

Rem
Rem Family : Heatmap
Rem
Rem Top N objects
Rem

drop   TABLE wri$_heatmap_top_objects;
CREATE TABLE wri$_heatmap_top_objects(
      task_time         date,
      object_owner      varchar2(128),
      object_name       varchar2(128),
      object_type       varchar2(18),
      tablespace_name   varchar2(30),
      segment_count     number,
      object_size       number,
      min_writetime     date,
      max_writetime     date,
      avg_writetime     date,
      min_readtime      date,
      max_readtime      date,
      avg_readtime      date,
      min_ftstime       date,
      max_ftstime       date,
      avg_ftstime       date,
      min_lookuptime    date,
      max_lookuptime    date,
      avg_lookuptime    date
)
tablespace SYSAUX;

Rem
Rem Dictionary View DBA_HEATMAP_TOP_OBJECTS
Rem
create or replace view DBA_HEATMAP_TOP_OBJECTS 
   (owner,object_name,object_type,
    tablespace_name, segment_count, object_size, 
    min_writetime, max_writetime, avg_writetime,
    min_readtime, max_readtime, avg_readtime,
    min_ftstime, max_ftstime, avg_ftstime,
    min_lookuptime, max_lookuptime, avg_lookuptime)
as
select 
    object_owner, object_name, object_type,
    tablespace_name, segment_count, object_size,
    min_writetime, max_writetime, avg_writetime,
    min_readtime, max_readtime, avg_readtime,
    min_ftstime, max_ftstime, avg_ftstime,
    min_lookuptime, max_lookuptime, avg_lookuptime
from sys.wri$_heatmap_top_objects
/
create or replace public synonym DBA_HEATMAP_TOP_OBJECTS
for DBA_HEATMAP_TOP_OBJECTS
/
grant select on DBA_HEATMAP_TOP_OBJECTS to select_catalog_role
/
comment on table DBA_HEATMAP_TOP_OBJECTS is
'Heatmap for Top N objects'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.owner is
'Object Owner'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.object_name is
'Object Name'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.object_type is
'Object type'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.tablespace_name is
'Tablespace name'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.segment_count is
'Segments in the tablespace'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.object_size is
'Size of the object in MB'
/
comment on column DBA_HEATMAP_TOP_OBJECTS.min_writetime is
'Minimum write time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.max_writetime is
'Maximum write time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.avg_writetime is
'Average write time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.min_readtime is
'Minimum read time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.max_readtime is
'Maximum read time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.avg_readtime is
'Average read time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.min_ftstime is
'Minimum full table scan time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.max_ftstime is
'Maximum full table scan time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.avg_ftstime is
'Average full table scan time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.min_lookuptime is
'Minimum lookup time of the object '
/
comment on column DBA_HEATMAP_TOP_OBJECTS.max_lookuptime is
'Maximum lookup time of the object ' 
/
comment on column DBA_HEATMAP_TOP_OBJECTS.avg_lookuptime is
'Average lookup time of the object ' 
/



execute CDBView.create_cdbview(false,'SYS','DBA_HEATMAP_TOP_OBJECTS','CDB_HEATMAP_TOP_OBJECTS');
grant select on SYS.CDB_HEATMAP_TOP_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_HEATMAP_TOP_OBJECTS for SYS.CDB_HEATMAP_TOP_OBJECTS
/

Rem
Rem Heatmap top N tablespaces 
Rem
drop table wri$_heatmap_top_tablespaces;
CREATE TABLE wri$_heatmap_top_tablespaces(
      task_time         date,
      tablespace_name   varchar2(128),
      segment_count     number,
      allocated_bytes   number,
      min_writetime     date,
      max_writetime     date,
      avg_writetime     date,
      min_readtime      date,
      max_readtime      date,
      avg_readtime      date,
      min_ftstime       date,
      max_ftstime       date,
      avg_ftstime       date,
      min_lookuptime    date,
      max_lookuptime    date,
      avg_lookuptime    date
)
tablespace SYSAUX;

Rem
Rem Dictionary View DBA_HEATMAP_TOP_TABLESPACES
Rem
create or replace view DBA_HEATMAP_TOP_TABLESPACES 
   ( tablespace_name, segment_count, allocated_bytes,
    min_writetime, max_writetime, avg_writetime,
    min_readtime, max_readtime, avg_readtime,
    min_ftstime, max_ftstime, avg_ftstime,
    min_lookuptime, max_lookuptime, avg_lookuptime)
as
select 
    tablespace_name, segment_count, allocated_bytes,
    min_writetime, max_writetime, avg_writetime,
    min_readtime, max_readtime, avg_readtime,
    min_ftstime, max_ftstime, avg_ftstime,
    min_lookuptime, max_lookuptime, avg_lookuptime
from sys.wri$_heatmap_top_tablespaces
/
create or replace public synonym DBA_HEATMAP_TOP_TABLESPACES
for DBA_HEATMAP_TOP_TABLESPACES
/
grant select on DBA_HEATMAP_TOP_TABLESPACES to select_catalog_role
/
comment on table DBA_HEATMAP_TOP_TABLESPACES is
'Heatmap for Top N tablespaces'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.tablespace_name is
'Tablespace name'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.segment_count is
'Segments in the tablespace'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.allocated_bytes is
'Total bytes allocated to the objects in the tablespace'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.min_writetime is
'Minimum write time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.max_writetime is
'Maximum write time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.avg_writetime is
'Average write time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.min_readtime is
'Minimum read time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.max_readtime is
'Maximum read time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.avg_readtime is
'Average read time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.min_ftstime is
'Minimum full table scan time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.max_ftstime is
'Maximum full table scan time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.avg_ftstime is
'Average full table scan time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.min_lookuptime is
'Minimum lookup time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.max_lookuptime is
'Maximum lookup time of objects tracked'
/
comment on column DBA_HEATMAP_TOP_TABLESPACES.avg_lookuptime is
'Average lookup time of objects tracked'
/




execute CDBView.create_cdbview(false,'SYS','DBA_HEATMAP_TOP_TABLESPACES','CDB_HEATMAP_TOP_TABLESPACES');
grant select on SYS.CDB_HEATMAP_TOP_TABLESPACES to select_catalog_role
/
create or replace public synonym CDB_HEATMAP_TOP_TABLESPACES for SYS.CDB_HEATMAP_TOP_TABLESPACES
/

Rem
Rem Auto Heat Map Top N Job Metadata
Rem 
drop table wri$_topn_metadata;
create table wri$_topn_metadata(
   task_id               number,
   task_starttime        date,
   task_completiontime   date,
   task_status           varchar2(10),
   tbs_processed         number,
   objects_processed     number
)
tablespace sysaux;

Rem
Rem Top N Helper Objects.
drop table sys.wri$_heatmap_topn_dep1;
create global temporary table sys.wri$_heatmap_topn_dep1 (
      object_name    varchar2(128),
      object_owner   varchar2(128),
      object_type    varchar2(128),
      segment_count  number,
      object_size    number)
on commit preserve rows;
grant select, insert, delete on sys.wri$_heatmap_topn_dep1 to public;

drop table sys.wri$_heatmap_topn_dep2;
create global temporary table sys.wri$_heatmap_topn_dep2 (
       object_name varchar2(128), 
       object_owner varchar2(128), 
       object_type varchar2(128),
       segment_count number, 
       object_size number)
on commit preserve rows;
grant select, insert, delete on sys.wri$_heatmap_topn_dep2 to public;


remark
remark  FAMILY "TS_QUOTAS"
remark  Tablespace quotas for users.
remark  This family has no ALL member.
remark
Rem
Rem  Performance improvement:
Rem    Get segments number of blocks from seg$.blocks. This column was
Rem    introduced in 10g. For databases that were upgraded from older
Rem    releases, dbms_space_admin.segment_number_blocks() is called to
Rem    gather the information.
Rem    View USER_TS is now useless. It is still left here just to avoid
Rem    any potential upgrade issue.
Rem
create or replace view USER_TS(uname, tsname, tsn)
as select user$.name, ts$.name, ts$.ts# from user$, ts$
/
create or replace view TBS_SPACE_USAGE(tsn, user#, blocks, maxblocks)
as select tsq$.ts#, tsq$.user#,
          NVL(sum(decode(bitand(seg$.spare1, 131072), 131072, seg$.blocks,
                         (decode(bitand(seg$.spare1, 1), 1,
                            dbms_space_admin.segment_number_blocks(tsq$.ts#,
                                   seg$.file#, seg$.block#, seg$.type#,
                                   seg$.cachehint, seg$.spare1,
                                   seg$.hwmincr, seg$.blocks), seg$.blocks)))),
              0),
          tsq$.maxblocks
from seg$, tsq$
where tsq$.ts# = seg$.ts# (+)
and   tsq$.user# = seg$.user# (+)
group by tsq$.ts#, tsq$.user#, tsq$.maxblocks
/
create or replace view USER_TS_QUOTAS
    (TABLESPACE_NAME, BYTES, MAX_BYTES, BLOCKS, MAX_BLOCKS, DROPPED)
as
select ts.name, spc.blocks * ts.blocksize,
       decode(spc.maxblocks, -1, -1, spc.maxblocks * ts.blocksize),
       spc.blocks, spc.maxblocks, decode(ts.online$, 3, 'YES', 'NO')
from sys.ts$ ts, sys.tbs_space_usage spc
where spc.tsn = ts.ts#
  and spc.user# = userenv('SCHEMAID')
/
comment on table USER_TS_QUOTAS is
'Tablespace quotas for the user'
/
comment on column USER_TS_QUOTAS.TABLESPACE_NAME is
'Tablespace name'
/
comment on column USER_TS_QUOTAS.BLOCKS is
'Number of ORACLE blocks charged to the user'
/
comment on column USER_TS_QUOTAS.MAX_BLOCKS is
'User''s quota in ORACLE blocks.  NULL if no limit'
/
comment on column USER_TS_QUOTAS.BYTES is
'Number of bytes charged to the user'
/
comment on column USER_TS_QUOTAS.MAX_BYTES is
'User''s quota in bytes.  NULL if no limit'
/
comment on column USER_TS_QUOTAS.DROPPED is
'Whether the tablespace has been dropped'
/
create or replace public synonym USER_TS_QUOTAS for USER_TS_QUOTAS
/
grant read on USER_TS_QUOTAS to PUBLIC with grant option
/
create or replace view DBA_TS_QUOTAS
    (TABLESPACE_NAME, USERNAME, BYTES, MAX_BYTES, BLOCKS, MAX_BLOCKS, DROPPED)
as
select ts.name, u.name, spc.blocks * ts.blocksize,
       decode(spc.maxblocks, -1, -1, spc.maxblocks * ts.blocksize),
       spc.blocks, spc.maxblocks, decode(ts.online$, 3, 'YES', 'NO')
from sys.ts$ ts, sys.tbs_space_usage spc, sys.user$ u
where spc.tsn  = ts.ts#
  and spc.user# = u.user#
  and spc.maxblocks != 0
/
create or replace public synonym DBA_TS_QUOTAS for DBA_TS_QUOTAS
/
grant select on DBA_TS_QUOTAS to select_catalog_role
/
comment on table DBA_TS_QUOTAS is
'Tablespace quotas for all users'
/
comment on column DBA_TS_QUOTAS.TABLESPACE_NAME is
'Tablespace name'
/
comment on column DBA_TS_QUOTAS.USERNAME is
'User with resource rights on the tablespace'
/
comment on column DBA_TS_QUOTAS.BLOCKS is
'Number of ORACLE blocks charged to the user'
/
comment on column DBA_TS_QUOTAS.MAX_BLOCKS is
'User''s quota in ORACLE blocks.  NULL if no limit'
/
comment on column DBA_TS_QUOTAS.BYTES is
'Number of bytes charged to the user'
/
comment on column DBA_TS_QUOTAS.MAX_BYTES is
'User''s quota in bytes.  NULL if no limit'
/
comment on column DBA_TS_QUOTAS.DROPPED is
'Whether the tablespace has been dropped'
/



execute CDBView.create_cdbview(false,'SYS','DBA_TS_QUOTAS','CDB_TS_QUOTAS');
grant select on SYS.CDB_TS_QUOTAS to select_catalog_role
/
create or replace public synonym CDB_TS_QUOTAS for SYS.CDB_TS_QUOTAS
/

Rem
Rem Temp Space Views
Rem
Rem   Use left outer join at
Rem     tsh.tablespace_name = ss.tablespace_name (+)
Rem   because sort segments may not havd ben created for all temp tablespaces.
Rem   And hence the nvl(ss.free_blocks, 0), because the outer join might
Rem   return null values.
create or replace view DBA_TEMP_FREE_SPACE
    (TABLESPACE_NAME, TABLESPACE_SIZE, ALLOCATED_SPACE, FREE_SPACE, SHARED, INST_ID) as
  SELECT tsh.tablespace_name,
         tsh.total_bytes/tsh.inst_count,
         tsh.bytes_used/tsh.inst_count,
         (tsh.bytes_free/tsh.inst_count) + (nvl(ss.free_blocks, 0) * ts$.blocksize),
         decode(bitand(ts$.flags, 18155135997837312),
                140737488355328, 'LOCAL_ON_LEAF',
                18155135997837312, 'LOCAL_ON_ALL', 'SHARED') shared,
         null as inst_id
    FROM (SELECT tablespace_name, sum(bytes_used + bytes_free) total_bytes,
                 sum(bytes_used) bytes_used, sum(bytes_free) bytes_free,
                 count(distinct inst_id) inst_count
            FROM gv$temp_space_header
            where (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))
            GROUP BY tablespace_name) tsh,
         (SELECT tablespace_name, sum(free_blocks) free_blocks
            FROM gv$sort_segment
            where (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))
            GROUP BY tablespace_name) ss,
         ts$
    WHERE ts$.name = tsh.tablespace_name and
          decode(bitand(ts$.flags, 18155135997837312),
                            140737488355328, 1,
                            18155135997837312, 1, 0) = 0 and
          tsh.tablespace_name = ss.tablespace_name (+)
   UNION
  SELECT tsh.tablespace_name,
         tsh.total_bytes,
         tsh.bytes_used,
         (tsh.bytes_free) + (nvl(ss.free_blocks, 0) * ts$.blocksize),
         decode(bitand(ts$.flags, 18155135997837312),
                140737488355328, 'LOCAL_ON_LEAF',
                18155135997837312, 'LOCAL_ON_ALL', 'SHARED') shared,
         tsh.inst_id
    FROM (SELECT tablespace_name, inst_id, sum(bytes_used + bytes_free) total_bytes,
                 sum(bytes_used) bytes_used, sum(bytes_free) bytes_free
            FROM gv$temp_space_header
            WHERE (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))
            GROUP BY tablespace_name, inst_id) tsh,
         (SELECT tablespace_name, inst_id, sum(free_blocks) free_blocks
            FROM gv$sort_segment
            WHERE (con_id is NULL or con_id = sys_context('USERENV', 'CON_ID'))
            GROUP BY tablespace_name, inst_id) ss,
         ts$
   WHERE ts$.name = tsh.tablespace_name and
         decode(bitand(ts$.flags, 18155135997837312),
                140737488355328, 1,
                18155135997837312, 1, 0) = 1 and
         tsh.tablespace_name = ss.tablespace_name (+);
/
create or replace public synonym DBA_TEMP_FREE_SPACE for
  DBA_TEMP_FREE_SPACE
/
grant select on DBA_TEMP_FREE_SPACE to select_catalog_role
/
comment on table DBA_TEMP_FREE_SPACE is
  'Summary of temporary space usage'
/
comment on column DBA_TEMP_FREE_SPACE.TABLESPACE_NAME is
  'Tablespace name'
/
comment on column DBA_TEMP_FREE_SPACE.TABLESPACE_SIZE is
  'Total size of the tablespace'
/
comment on column DBA_TEMP_FREE_SPACE.ALLOCATED_SPACE is
  'Total allocated space for sort segments'
/
comment on column DBA_TEMP_FREE_SPACE.FREE_SPACE is
  'Total free space available'
/
comment on column DBA_TEMP_FREE_SPACE.SHARED is
  'Type of temporary tablespace'
/
comment on column DBA_TEMP_FREE_SPACE.INST_ID is
  'Instance id of corresponding temporary tablespace'
/

execute CDBView.create_cdbview(false,'SYS','DBA_TEMP_FREE_SPACE','CDB_TEMP_FREE_SPACE');
grant select on SYS.CDB_TEMP_FREE_SPACE to select_catalog_role
/
create or replace public synonym CDB_TEMP_FREE_SPACE for SYS.CDB_TEMP_FREE_SPACE
/

@?/rdbms/admin/sqlsessend.sql
