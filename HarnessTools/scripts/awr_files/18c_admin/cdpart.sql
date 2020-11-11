rem 
rem $Header:
rem 
Rem Copyright (c) 1988, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem NAME
Rem   cdpart.sql - Catalog DPART.bsq views
Rem  (Previously known as CATPART.SQL)
Rem 
Rem FUNCTION
Rem   Creates data dictionary views for the partitioning table.
Rem 
Rem DESCRIPTION
Rem   This script contains catalog views for objects in dpart.bsq.
Rem
Rem NOTES
Rem   1. Must be run when connected to SYS or INTERNAL.
Rem   2. This script is standalone, but it is also run from catalog.sql.
Rem   3. To drop these views run CATNOPRT.SQL.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdpart.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdpart.sql
Rem SQL_PHASE: CDPART
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem MODIFIED
Rem    pjulsaks   06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    rodfuent   04/07/17 - Bug 25741730: Add DOMIDX_OPSTATUS to
Rem                          *_IND_SUBPARTITIONS views
Rem    siteotia   10/18/16 - Project 68493: MEMOPTIMIZE(IMOLTP) DDL Changes.
Rem    agardner   10/27/16 - Bug 19662815: correct all/dba_tab partitions
Rem    rmacnico   06/02/16 - Bug 23479733: Cellmemory composite subpartitions
Rem    rmacnico   03/30/16 - Bug 23018570: partobj$.spare3
Rem    rmacnico   12/01/15 - Bug 22293392: change cachecompress to memcompress
Rem    rmacnico   12/01/15 - Bug 22186966: CELLMEMORY in USER_TAB_SUBPARTITIONS 
Rem    aditigu    10/22/15 - Bug 21238674: changed key for imsvc$
Rem    hegliu     08/11/15 - 21563940: add read_only, indexing, compression to
Rem                          *_SUBPARTITION_TEMPLATES
Rem    aditigu    07/06/15 - Bug 21437329: add column for inmemory for service
Rem    aditigu    01/28/15 - Bug 20433683: IMC priority should be NULL when 
Rem                          unspecified
Rem    hlili      01/22/15 - bug 20366781: reuse KKPAC_INTERVAL_PARTN flag for
Rem                          autolist partitioning
Rem    rmacnico   01/15/15 - Proj 47506: CELLCACHE
Rem    hegliu     01/07/15 - bug 20312978: add INTERVAL_SUBPARTITION and
Rem                          AUTOLIST_SUBPARTITION
Rem    skayoor    11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    wesmith    11/24/14 - Project 47511: data-bound collation
Rem    sasounda   11/23/14 - add AUTOLIST to user_part_indexes
Rem    echong     10/24/14 - local domain index support on composite
Rem                          partitioned tables
Rem    sasounda   10/22/14 - proj 47115: add cols for autolist partitioning
Rem    garysmit   09/15/14 - Bug 19598441: Fix inmemory dist values
Rem    garysmit   06/26/14 - 18875781 - wrong value for inmemory_compression
Rem    garysmit   04/10/14 - Bug 18385644: IMC syntax
Rem    surman     12/29/13 - 13922626: Update SQL metadata
Rem    jekamp     11/22/13 - Bug 17752984: DBA_TAB_PARTITIONS and composite
Rem                          tables
Rem    sasounda   11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    jekamp     09/30/13 - Project 35591: New IMC syntax
Rem    xha        08/20/13 - Update IMC level flags
Rem    smuthuli   08/07/13 - IMC Support for preload prioritization
Rem    talliu     06/28/13 - Add CDB view for DBA view
Rem    xha        06/06/13 - Bug 16829223: IMC level flags and map by flags
Rem    jekamp     03/05/13 - IMC preload option
Rem    jekamp     12/10/12 - Clean up IMC flags
Rem    xihua      10/11/12 - Index Compression Factoring Change
Rem    geadon     10/08/12 - bug 14621938: add INDEX_ORPHANED_ENTRY_V$ view
Rem    amylavar   09/25/12 - New 12.0 syntax for ACO/HCC
Rem    jekamp     07/02/12 - Add IMC to PART_TABLES
Rem    jekamp     05/09/12 - extend seg$ and ts$ flags to ub8
Rem    surman     03/27/12 - 13615447: Add SQL patching tags
Rem    araghava   02/18/12 - filter out hidden partitions from tabcompart and
Rem                          tabsubpart
Rem    anthkim    12/09/11 - In-Memory Columnar Snapshot Store: parser and dict
Rem    araghava   11/29/11 - proj-35496: filter out hidden partitions
Rem    hschiu     10/14/11 - Proj#30969: rename OLTPHIGH/LOW to OLTP HIGH/LOW
Rem    teclee     08/24/11 - Add HCC row level locking info on COMPRESS_FOR
Rem    sursridh   07/01/11 - Proj 32995: support for partial indexes.
Rem    kshergil   06/17/11 - proj#30969: index OLTP compression
Rem    sursridh   03/22/11 - Project 32995: Orphaned entry optimization for
Rem                          index maintenance.
Rem    slynn      06/09/10 - Fix lrg-4689610: views don't handle def. seg
Rem                          creation.
Rem    sursridh   05/21/10 - Bug 8937971: Return freelists, freelist_groups
Rem                          correctly for deferred case.
Rem    geadon     04/08/10 - interval attribute for ref partitioned tables
Rem    kquinn     03/06/10 - 9444204: add predicate to dba/all_lob_templates
Rem    vaselvap   02/15/10 - 8334498: Change PARTITION view families to compute
Rem                          (sub)partition position in situ.  
Rem    sursridh   12/29/09 - Bug 9091681: SEGMENT_CREATED for IOTs.
Rem    atomar     12/14/09 - bug 9208109
Rem    sursridh   09/29/09 - Project 31043: Deferred segment creation for
Rem                          partitioned objects.
Rem    slynn      04/17/08 - Fix SecureFile Retention Problems.
Rem    bvaranas   11/06/08 - Support deferred segment creation for partitioned
Rem                          objects
Rem    rmacnico   06/11/09 - ARCHIVE LOW/HIGH
Rem    bvaranas   05/22/09 - Expose interval in *_tab_partitions
Rem    rmacnico   04/16/09 - Bug 8252432 - archive compressiohn levels
Rem    adalee     03/06/09 - new cachehint
Rem    ramekuma   03/16/09 - Fix storage parameters in *_IND_PARTITIONS,
Rem                          *_IND_SUBPARTITIONS views for deferred segments
Rem    ramekuma   11/04/08 - add SEGMENT_CREATED to *_IND_PARTITIONS,
Rem                          *_IND_SUBPARTITIONS
Rem    schakrab   03/23/08 - print out nested table partition information 
Rem    weizhang   03/13/08 - storage clause INITIAL/NEXT for ASSM segment
Rem    geadon     01/28/08 - bug 6642210: fix part_indexes for ref ptn local
Rem                          index
Rem    schoi      07/19/07 - add 'compress_for' column to _part_tables view
Rem    baleti     07/15/07 - fix typo user_lob_part
Rem    vmarwah    06/29/07 - bug-6145832: composite partition compress bit fix
Rem    vmarwah    05/23/07 - Compression Type for views
Rem    slynn      05/17/07 - Fix bug-6059863: _part_lobs returns incorrect
Rem                          values for SecureFiles.
Rem    slynn      11/20/06 - remove SYNC
Rem    shshanka   02/06/07 - #(5865983) - Add interval to part views
Rem    slynn      10/12/06 - smartfile->securefile
Rem    schakkap   09/20/06 - move statistics views to cdoptim.sql
Rem    smuthuli   09/05/06 - SmartFile support
Rem    slynn      07/31/06 - change csce keywords.
Rem    bvaranas   07/13/06 - Bug 5307067: Print out range subpartitioning 
Rem                          information for user_part_tables 
Rem    jforsyth   06/14/06 - typo
Rem    jforsyth   06/06/06 - CSCE columns in lob views empty for NOLOCAL
Rem    geadon     05/24/06 - changes for partition by reference 
Rem    cdilling   05/09/06  - Rename catpart.sql to cdpart.sql
Rem    jforsyth   03/07/06  - shifting encryption, compression, and sharing 
Rem                           flags 
Rem    jforsyth   03/06/06  - adding ENCRYPT, COMPRESS, and SHARE columns to 
Rem                           lob views 
Rem    mbaloglu   03/06/06  - Add SYNC column to LOB_PARTITIONS views 
Rem    geadon     01/19/06  - Handle ts# = KTSINV for ref-part tables 
Rem    mtakahar   10/28/05  - #(4704779) fix wrong histogram type
Rem    bvaranas   05/17/05  - Bug 4339223: Modify definitions of 
Rem                           partitioning views to better use index on obj$
Rem    mtakahar   01/18/05  - #(3536027) fix wrong histogram type shown
Rem    mtakahar   09/09/04  - mon_mods$ -> mon_mods_all$
Rem    vshukla    07/12/04  - #(3699607): hide *IND|LOB|*PARTITIONS entries 
Rem                           for an unusable table 
Rem    schakkap   06/08/04  - stale_stats column for *STATISTICS views.
Rem                           table_owner, table_name, stattype_locked
Rem                             for *IND_STATISTICS views.
Rem                           expose physical part# in *partv views.
Rem    vshukla    05/25/04  - fix iot join condition 
Rem    vshukla    05/06/04  - add STATUS field to *_PART_TABLES, filter out 
Rem                           rows belonging to unusable tables 
Rem    mtakahar   12/18/03  - fix NUM_BUCKETS/HISTOGRAM columns
Rem    kshergil   11/03/03  - 3092470: remove LOB indexes from 
Rem                           ALL_PART_INDEXES and ALL_IND_[SUB]PARTITIONS
Rem    schakkap   10/29/03  - #(3223755): fix *_IND_STATISTICS views 
Rem    schakkap   09/09/03  - comment on stattype_locked 
Rem    vshukla    09/15/03  - #3087013: add the missing the predicate in 
Rem                           [USER | DBA | ALL]_lob_[sub]partitions
Rem    koi        06/17/03  - 2994527: change *_TAB_PARTITIONS for IOT LOGGING
Rem    araghava   05/08/03  - add COMPRESSION to *_IND_SUBPARTITIONS
Rem    schakkap   04/15/03  - Change values for lock bits
Rem    schakkap   01/01/03  - lock/unlock statistics
Rem    schakkap   12/17/02 -  add missing cols for *_TAB_STATS and *_IND_STATS
Rem                          *_TAB_STATS -> *_TAB_STATISTICS
Rem                          *_IND_STATS -> *_IND_STATISTICS
Rem                          fixed table stats in *_TAB_STATISTICS
Rem    mtyulene   10/20/02 - add [ALL DBA USER]_TAB_STATS AND
Rem                          [ALL DBA USER]_IND_STATS
Rem    mtakahar   08/06/02 - #(2352663) fix num_buckets, add histogram col
Rem    arithikr   01/16/02 - 1534815: fix dba_part_indexes view
Rem    attran     12/05/01 - List Sub_PIOT.
Rem    araghava   11/21/01 - 1912886: use row_number function to get 
Rem                          partition_position.
Rem    shshanka   11/16/01 - Fix user_lob_templates view.
Rem    vshukla    10/28/01 - hsc: row movement course correction!.
Rem    vshukla    09/26/01 - modify *_PART_TABLES, *_TAB_[SUB]PARTITIONS.
Rem                          to include compression/row movement.
Rem    sbedarka   10/01/01 - #(1551726) correct COMPOSITE column typo
Rem    aime       08/28/01 - Fix view ALL_IND_SUBPARTITIONS
Rem    sbasu      08/16/01 - modify views for Range List partitioning.
Rem    shshanka   07/17/01 - Add views on top of defsubpart$ and defsubpartlob$.
Rem    gviswana   05/24/01 - CREATE AND REPLACE SYNONYM
Rem    htseng     04/12/01 - eliminate execute twice (remove ;).
Rem    smuthuli   03/15/01 - pctused,freelist,flgroups=NULL for bitmapsegs
Rem    spsundar   10/17/00 - fix *_ind_partitions for null tblspc for dom idx
Rem    attran     04/28/00 - PIOT: List Partitioning *_PART_TABLES.
Rem    ayalaman   03/28/00 - overflow statistics for IOT
Rem    spsundar   02/14/00 - update *_part_indexes and *_ind_partitions
Rem    sbasu      02/03/00 - support for List partitioning
Rem    attran     09/22/99 - PIOT: TABPART$/blkcnt
Rem    qyu        09/16/99 - undo cache reads lob mode logging fix
Rem    qyu        07/27/99 - keep YES/NO value in cache columns for lob
Rem    tlee       06/28/99 - cache reads lob mode logging fix
Rem    attran     03/31/99 - PIOT: definitions of *_PART_TABLES
Rem    qyu        03/04/99 - add CACHE READS lob mode
Rem    thoang     11/13/98 - Mod views to return attribute name for ADT col    
Rem    mjaganna   11/12/98 - Fix PIOT view related bugs (750662)
Rem    ielayyan   11/02/98 - 748786, make ALL_ views visible to grantee
Rem    sbasu      09/08/98 - replace 2147483647 with NULL in decode expressions 
Rem                          for deftiniexts, defextsize, defminexts, defmaxexts,
Rem                          defextpct in *_PART_TABLE and *_PART_INDEXES views 
Rem    tlee       08/19/98 - remove to_char of extsize in lob_subpartitions
Rem    amozes     07/24/98 - global index stats                                
Rem    smuthuli   07/30/98 - Bug 696705
Rem    amozes     08/24/98 - expose endpoint actual value                      
Rem    ayalaman   07/21/98 - change tab_partitions views to show iot tabpart
Rem    akruglik   07/22/98 - in *_PART_LOBS and *_LOB_PARTITIONS (describing 
Rem                          Composite partitions) DEFAULT BUFFER_POOL will be
Rem                          represented by 0, not NULL
Rem    ayalaman   06/12/98 - add guess stats to user_ind_partitions
Rem    akruglik   05/29/98 - correct predicate in _PART_LOBS views             
Rem    amozes     06/01/98 - analyze composite statistics                      
Rem    ayalaman   06/05/98 - add COMPRESSION to *_ind_part views
Rem    syeung     05/08/98 - store unspecified dflt logging attr. for Composite
Rem                          partition in _TAB_PARTITIONS and _IND_PARTITIONS 
Rem                          views
Rem    akruglik   05/14/98 - modify definitions of *_LOB_[SUB]PARTITIONS to 
Rem                          display CHUNK size of physical fragments in bytes 
Rem                          rahter than blocks
Rem    akruglik   05/01/98 - define {USER|ALL|DBA}_PART_LOBS, 
Rem                          {USER|ALL|DBA}_LOB_PARTITIONS, and 
Rem                          {USER|ALL|DBA}_LOB_SUBPARTITIONS
Rem    syeung     02/24/98 - default tablespace for Composite partition can no
Rem                          longer be KTSNINV (i.e. remove outer join in 
Rem                          _TAB_PARTITIONS views for Composite table)
Rem    amozes     03/27/98 - add new stats information                         
Rem    sbasu      02/25/98 - support for range-composite part. local indexes
Rem                          change ref. comppart$->tabcompart$
Rem    thoang     12/15/97 - Modified views to exclude unused columns.
Rem    syeung     12/31/97 - code cleanups for partitioning project:
Rem                          - rename EXTHASH->HASH & remove HYBRID from 
Rem                            partitioning_type of {USER|ALL|DBA}_PART_TABLES
Rem                             and {USER|ALL|DBA}_PART_INDEXES views 
Rem                          - remove TABLESPACE_COUNT from _PART_TABLES and
Rem                            {USER|ALL|DBA}_TAB_PARTITIONS views
Rem                          - remove {USER|ALL|DBA}_TABLESPACE_LISTS views
Rem                          - change ref. to hybpart$->comppart$
Rem    syeung     12/16/97 - boolean column HYBRID in ALL_TAB_PARTITIONS & DBA_
Rem    syeung     12/09/97 - decode deflists and defgroups in USER_TAB_PARTITIO
Rem    syeung     11/17/97 - add object_type for _TABLESPACE_LISTS views
Rem    sbasu      11/10/97 - alter definition of alignment field in PART_INDEXES
Rem                          family of views to correctly display local 
Rem                          SYSTEM partitioned indexes
Rem    akruglik   11/03/97 - default number of subpartitions may ne upto 64K, 
Rem    syeung     11/01/97 - refer to partobj$.spare2 for tscnt
Rem    syeung     10/07/97 - use hybpart$ for Hybrid partition information
Rem                          so the expression in *_PART_TABLES should use 
Rem                          mod 65536
Rem    nireland   09/19/97 - Remove magic numbers. #502160
Rem    akruglik   09/11/97 - add OBJECT_TYPE column to *_PART_KEY_COLUMNS views
Rem    sbasu      07/30/97 - #504196: Add freelist_groups to *_IND_PARTITIONS
Rem    syeung     07/03/97 - add SUBPART_KEY_COLUMNS family
Rem    akruglik   06/09/97 - Hybrid partitioning will no longer be
Rem                          determinable by checking patytype - subparttype
Rem                          should be checked instead
Rem    akruglik   05/21/97 - alter WHERE-clause of {USER|ALL|DBA}_PART_INDEXES
Rem                          so it does not rely on system-specific value of 
Rem                          KTSNINV
Rem    aho        04/18/97 - partitioned cache
Rem    syeung     05/07/97 - pti 8.1 project
Rem    akruglik   05/02/97 - 8.1 Partitioning Project: 
Rem                          alter definitions of view in PART_TABLES and 
Rem                          PART_INDEXES families to correctly display 
Rem                          PARTITIONING_TYPE of objects partitioned by 
Rem                          System, Extensible Hash and Hybrid
Rem    achaudhr   03/10/97 - #(454169): catnopart.sql -> catnoprt.sql
Rem    achaudhr   11/22/96 - PART_COL_STATISTICS: reorder columns
Rem    ssamu      08/13/96 - fix view xxx_part_key_columns to show index partit
Rem    mmonajje   05/20/96 - Replace timestamp col name with timestamp#
Rem    atsukerm   05/13/96 - tablespace-relative DBAs - fix TAB_PARTITIONS and
Rem                          IND_PARTITIONS
Rem    asurpur    04/08/96 - Dictionary Protection Implementation
Rem    jwijaya    03/29/96 - test for hidden columns
Rem    achaudhr   03/21/96 - fix PART_HISTOGRAMS
Rem    akruglik   03/21/96 - another change related to default tablespace of
Rem                          LOCAL indexes - since we are using an outer join
Rem                          in the definition of user|all|dba_part_indexes, 
Rem                          there is no reason to decode po.defts#
Rem    akruglik   03/20/96 - definitions of {user|dba|all}_part_indexes need to
Rem    akruglik   03/12/96 - change qualification of 
Rem                          {user|dba|all}_part_indexes to account for the 
Rem                          fact that LOCAL indexes may have no default 
Rem                          TABLESPACE associated with them
Rem    akruglik   02/28/96 - add def_logging and logging attributes to
Rem                          {USER | ALL | DBA}_PART_{INDEXES | TABLES} and 
Rem                          {USER | ALL | DBA}_{IND | TAB}_PARTITIONS
Rem    sbasu      11/21/95 - Add STATUS field to {USER|ALL_DBA}_IND_PARTITIONS and modify names 
Rem    achaudhr   10/30/95 - Create the views
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark Define views whose definitions are dependent on new bootstrap table 
remark columns
@@cdpart_mig.sql

remark
remark  FAMILY "PART_TABLES"
remark   This family of views will describe the object level partitioning 
remark   information for partitioned tables. 
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_PART_TABLES 
  (TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_COMPRESS_FOR, DEF_BUFFER_POOL,
   DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   REF_PTN_CONSTRAINT_NAME, INTERVAL, AUTOLIST, INTERVAL_SUBPARTITION,
   AUTOLIST_SUBPARTITION, IS_NESTED,
   DEF_SEGMENT_CREATION, DEF_INDEXING, DEF_INMEMORY,
   DEF_INMEMORY_PRIORITY, DEF_INMEMORY_DISTRIBUTE, DEF_INMEMORY_COMPRESSION,
   DEF_INMEMORY_DUPLICATE, DEF_READ_ONLY, DEF_CELLMEMORY, DEF_INMEMORY_SERVICE,
   DEF_INMEMORY_SERVICE_NAME)
as 
select o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'),
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defpctused), 
       po.definitrans,
       po.defmaxtrans, 
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(mod(trunc(po.spare2/4294967296),256), 3),
                       0, 'NONE', 1, 'ENABLED', 2, 'DISABLED', 'UNKNOWN'),
       -- compression info is in byte 4 of spare2
       case bitand(mod(trunc(po.spare2/4294967296),256), 127) -- 6 bits in use
         when 0 then NULL
         when 1 then 'BASIC'                                 -- 00000001
         when 2 then NULL
         when 5 then 'ADVANCED'                              -- 00000101
         when 9 then 'QUERY LOW'                             -- 00001001
         when 17 then 'QUERY HIGH'                           -- 00010001
         when 25 then 'ARCHIVE LOW'                          -- 00011001
         when 33 then 'ARCHIVE HIGH'                         -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'          -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'         -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'        -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'       -- 01100001
                 else 'UNKNOWN' end,                         -- internal
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       (select c.name from sys.con$ c, sys.cdef$ cd
          where c.con# = cd.con# and cd.obj# = o.obj#
            and cd.type# = 4 and bitand(cd.defer, 512) != 0),
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end, 
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end, -- autolist subpartitioning
       decode(bitand(t.property,8224), 8224, 'YES', 'NO'),
       decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE'),
       decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON'),
       -- DEF_INMEMORY
       --  defimcflags_kkpacocd (kkpac.h) 
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3) -- bits 0,1
         when 0 then 'NONE' 
         when 1 then 'ENABLED'
         when 2 then 'DISABLED'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_PRIORITY
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7) 
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7) 
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DISTRIBUTE
       case bitand(mod(trunc(po.spare2/1099511627776),256), 103)
         when 0 then NULL                             -- first 3 bit,5,6
         when 1 then NULL
         when 2 then NULL
         when 5 then 'AUTO'
         when 37 then 'BY ROWID RANGE'
         when 69 then 'BY PARTITION'
         when 101 then 'BY SUBPARTITION'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_COMPRESSION
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 395)
         when 0 then NULL                              -- bits 0,1,3,7,8
         when 1 then NULL
         when 2 then NULL
         when 9 then 'NO MEMCOMPRESS'
         when 129 then 'FOR DML'
         when 137 then 'FOR QUERY LOW'
         when 257 then 'FOR QUERY HIGH'
         when 265 then 'FOR CAPACITY LOW'
         when 385 then 'FOR CAPACITY HIGH'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DUPLICATE
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3073)
         when 0 then NULL                               -- bits 0,1,10,11
         when 1 then NULL
         when 2 then NULL
         when 1025 then 'NO DUPLICATE'
         when 2049 then 'DUPLICATE'
         when 3073 then 'DUPLICATE ALL'
         else 'UNKNOWN' end,
       decode(bitand(po.flags, 65536), 65536, 'YES', 'NO'),
       -- DEF_CELLMEMORY
       --  defccflags_kkpacpcd (kkpac.h) 
       decode(bitand(po.spare3, 16711680),
               196608, 'DISABLED',
               327680, 'NO MEMCOMPRESS',
               589824, 'MEMCOMPRESS FOR QUERY',
              1114112, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- DEF_INMEMORY_SERVICE
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     decode(bitand(svc.svcflags,7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            5, 'DEFAULT'), NULL), NULL),
       -- DEF_INMEMORY_SERVICE_NAME
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     svc.svcname, NULL), NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t, sys.imsvc$ svc
where  o.obj# = po.obj# and po.defts# = ts.ts# (+) and t.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) = 0 and o.obj# = svc.obj# (+) and
       svc.subpart#(+) is null
union all -- NON-IOT and IOT
select o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'),
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       null,
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       NULL  -- ref-partitioned IOT is not supported so skip the sub-query,
       ,case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
             else po.interval_str end  -- Select interval_str anyways
       ,case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
             then 'YES' else 'NO' end -- autolist partitioning
       ,case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end -- interval subpartitioning
       ,case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end -- autolist subpartitioning
       ,'N/A'
       , decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE')
       , decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON')
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , decode(bitand(po.flags, 65536), 65536, 'YES', 'NO')
       , NULL
       , NULL
       , NULL
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = userenv('SCHEMAID') and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) != 0
/ 
create or replace public synonym USER_PART_TABLES for USER_PART_TABLES 
/
grant read on USER_PART_TABLES to PUBLIC with grant option
/
create or replace view ALL_PART_TABLES 
  (OWNER, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_COMPRESS_FOR, DEF_BUFFER_POOL,
   DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   REF_PTN_CONSTRAINT_NAME, INTERVAL, AUTOLIST, INTERVAL_SUBPARTITION,
   AUTOLIST_SUBPARTITION, IS_NESTED,
   DEF_SEGMENT_CREATION,
   DEF_INDEXING, DEF_INMEMORY, 
   DEF_INMEMORY_PRIORITY, DEF_INMEMORY_DISTRIBUTE, DEF_INMEMORY_COMPRESSION,
   DEF_INMEMORY_DUPLICATE, DEF_READ_ONLY, DEF_CELLMEMORY, DEF_INMEMORY_SERVICE,
   DEF_INMEMORY_SERVICE_NAME)
as 
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols,
       mod(trunc(po.spare2/256), 256), 
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree,
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defpctused),
       po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.deflists),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.defgroups),
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(mod(trunc(po.spare2/4294967296),256), 3),
                       0, 'NONE', 1, 'ENABLED', 2, 'DISABLED', 'UNKNOWN'),
       -- compression info is in byte 4 of spare2
       case bitand(mod(trunc(po.spare2/4294967296),256), 127) -- 6 bits in use
         when 0 then NULL
         when 1 then 'BASIC'                                 -- 00000001
         when 2 then NULL
         when 5 then 'ADVANCED'                              -- 00000101
         when 9 then 'QUERY LOW'                             -- 00001001
         when 17 then 'QUERY HIGH'                           -- 00010001
         when 25 then 'ARCHIVE LOW'                          -- 00011001
         when 33 then 'ARCHIVE HIGH'                         -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'          -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'         -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'        -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'       -- 01100001
                 else 'UNKNOWN' end,                         -- internal ilevels
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       (select c.name from sys.con$ c, sys.cdef$ cd
          where c.con# = cd.con# and cd.obj# = o.obj#
            and cd.type# = 4 and bitand(cd.defer, 512) != 0),
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end, 
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end, -- autolist subpartitioning
       decode(bitand(t.property,8224), 8224, 'YES', 'NO'),
       decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE'),
       decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON'),
       -- DEF_INMEMORY
       --  defimcflags_kkpacocd (kkpac.h)
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3) -- bits 0,1
         when 0 then 'NONE' 
         when 1 then 'ENABLED'
         when 2 then 'DISABLED'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_PRIORITY
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7) 
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7)
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DISTRIBUTE
       case bitand(mod(trunc(po.spare2/1099511627776),256), 103)
         when 0 then NULL                              -- first 3 bits,5,6
         when 1 then NULL
         when 2 then NULL
         when 5 then 'AUTO'
         when 37 then 'BY ROWID RANGE'
         when 69 then 'BY PARTITION'
         when 101 then 'BY SUBPARTITION'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_COMPRESSION
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 395)
         when 0 then NULL                              -- bits 0,1,3,7,8
         when 1 then NULL
         when 2 then NULL
         when 9 then 'NO MEMCOMPRESS'
         when 129 then 'FOR DML'
         when 137 then 'FOR QUERY LOW'
         when 257 then 'FOR QUERY HIGH'
         when 265 then 'FOR CAPACITY LOW'
         when 385 then 'FOR CAPACITY HIGH'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DUPLICATE
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3073)
         when 0 then NULL                              -- bits 0,1,10,11
         when 1 then NULL
         when 2 then NULL
         when 1025 then 'NO DUPLICATE'
         when 2049 then 'DUPLICATE'
         when 3073 then 'DUPLICATE ALL'
         else 'UNKNOWN' end,
       decode(bitand(po.flags, 65536), 65536, 'YES', 'NO'),
       -- DEF_CELLMEMORY
       --  defccflags_kkpacpcd (kkpac.h) 
       decode(bitand(po.spare3, 16711680),
               196608, 'DISABLED',
               327680, 'NO MEMCOMPRESS',
               589824, 'MEMCOMPRESS FOR QUERY',
              1114112, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- DEF_INMEMORY_SERVICE
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     decode(bitand(svc.svcflags,7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            5, 'DEFAULT'), NULL), NULL),
       -- DEF_INMEMORY_SERVICE_NAME
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     svc.svcname, NULL), NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t, sys.user$ u,
       sys.imsvc$ svc
where  o.obj# = po.obj# and po.defts# = ts.ts# (+) and t.obj# = o.obj# and
       o.owner# = u.user# and 
       bitand(t.property, 64 + 128) = 0 and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
        or o.obj# in
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      ) and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
union all -- NON-IOT and IOT
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols,
       mod(trunc(po.spare2/256), 256), 
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       null,
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       NULL  -- ref-partitioned IOT is not supported so skip the sub-query,
       ,case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
             else po.interval_str end
       ,case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
             then 'YES' else 'NO' end -- autolist partitioning
       ,case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end -- interval subpartitioning
       ,case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
             then 'YES' else 'NO' end -- autolist subpartitioning
       ,'N/A'
       , decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE')
       , decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON')
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , decode(bitand(po.flags, 65536), 65536, 'YES', 'NO')
       , NULL
       , NULL
       , NULL
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t, sys.user$ u 
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = u.user# and 
       bitand(t.property, 64 + 128) != 0 and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (o.owner# = userenv('SCHEMAID')
        or o.obj# in
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/ 
create or replace public synonym ALL_PART_TABLES for ALL_PART_TABLES 
/
grant read on ALL_PART_TABLES to PUBLIC with grant option
/
create or replace view DBA_PART_TABLES 
  (OWNER, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT, 
   SUBPARTITIONING_KEY_COUNT, STATUS,
   DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_PCT_USED, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_COMPRESSION, DEF_COMPRESS_FOR, DEF_BUFFER_POOL,
   DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   REF_PTN_CONSTRAINT_NAME, INTERVAL, AUTOLIST, 
   INTERVAL_SUBPARTITION, AUTOLIST_SUBPARTITION,
   IS_NESTED, DEF_SEGMENT_CREATION, DEF_INDEXING, DEF_INMEMORY, 
   DEF_INMEMORY_PRIORITY, DEF_INMEMORY_DISTRIBUTE, DEF_INMEMORY_COMPRESSION,
   DEF_INMEMORY_DUPLICATE, DEF_READ_ONLY, DEF_CELLMEMORY, DEF_INMEMORY_SERVICE,
   DEF_INMEMORY_SERVICE_NAME)
as 
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       ts.name, po.defpctfree, 
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.defpctused),
       po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),po.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), po.defgroups),
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(mod(trunc(po.spare2/4294967296),256), 3),
                       0, 'NONE', 1, 'ENABLED', 2, 'DISABLED', 'UNKNOWN'),
       -- compression info is in byte 4 of spare2
       case bitand(mod(trunc(po.spare2/4294967296),256), 127) -- 6 bits in use
         when 0 then NULL
         when 1 then 'BASIC'                                 -- 00000001
         when 2 then NULL
         when 5 then 'ADVANCED'                              -- 00000101
         when 9 then 'QUERY LOW'                             -- 00001001
         when 17 then 'QUERY HIGH'                           -- 00010001
         when 25 then 'ARCHIVE LOW'                          -- 00011001
         when 33 then 'ARCHIVE HIGH'                         -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'          -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'         -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'        -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'       -- 01100001
                 else 'UNKNOWN' end,                         -- internal
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       (select c.name from sys.con$ c, sys.cdef$ cd
          where c.con# = cd.con# and cd.obj# = o.obj#
            and cd.type# = 4 and bitand(cd.defer, 512) != 0),
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end,
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end, -- autolist subpartitioning
       decode(bitand(t.property,8224), 8224, 'YES', 'NO'),
       decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE'),
       decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON'),
       -- DEF_INMEMORY
       -- defimcflags_kkpacocd (kkpac.h)
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3) -- bits 0,1
         when 0 then 'NONE' 
         when 1 then 'ENABLED'
         when 2 then 'DISABLED'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_PRIORITY
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7) 
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(po.spare2/4503599627370496),64), 7)
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DISTRIBUTE
       case bitand(mod(trunc(po.spare2/1099511627776),256), 103)
         when 0 then NULL                              -- first 3 bits,5,6
         when 1 then NULL
         when 2 then NULL
         when 5 then 'AUTO'
         when 37 then 'BY ROWID RANGE'
         when 69 then 'BY PARTITION'
         when 101 then 'BY SUBPARTITION'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_COMPRESSION
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 395)
         when 0 then NULL                              -- bits 0,1,3,7,8
         when 1 then NULL
         when 2 then NULL
         when 9 then 'NO MEMCOMPRESS'
         when 129 then 'FOR DML'
         when 137 then 'FOR QUERY LOW'
         when 257 then 'FOR QUERY HIGH'
         when 265 then 'FOR CAPACITY LOW'
         when 385 then 'FOR CAPACITY HIGH'
         else 'UNKNOWN' end,
       -- DEF_INMEMORY_DUPLICATE
       case bitand(mod(trunc(po.spare2/1099511627776),4096), 3073)
         when 0 then NULL                              -- bits 0,1,10,11
         when 1 then NULL
         when 2 then NULL
         when 1025 then 'NO DUPLICATE'
         when 2049 then 'DUPLICATE'
         when 3073 then 'DUPLICATE ALL'
         else 'UNKNOWN' end,
       decode(bitand(po.flags, 65536), 65536, 'YES', 'NO'),
       -- DEF_CELLMEMORY
       --  defccflags_kkpacpcd (kkpac.h) 
       decode(bitand(po.spare3, 16711680),
               196608, 'DISABLED',
               327680, 'NO MEMCOMPRESS',
               589824, 'MEMCOMPRESS FOR QUERY',
              1114112, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- DEF_INMEMORY_SERVICE
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     decode(bitand(svc.svcflags,7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            5, 'DEFAULT'), NULL), NULL),
       -- DEF_INMEMORY_SERVICE_NAME
       decode(bitand(po.spare2, 1099511627776),1099511627776,
              decode(bitand(po.spare3,16777216), 16777216, 
                     svc.svcname, NULL), NULL)
from   sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.tab$ t, sys.user$ u,
       sys.imsvc$ svc
where  o.obj# = po.obj# and po.defts# = ts.ts# (+) and t.obj# = o.obj# and
       o.owner# = u.user# and o.subname IS NULL and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       (bitand(t.property, 64 + 128) = 0) and o.obj# = svc.obj# (+) and
       svc.subpart#(+) is null
union all -- NON-IOT and IOT
select u.name, o.name, 
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                           5, 'REFERENCE', 'UNKNOWN'), 
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256),
       decode(bitand(t.trigflag, 1073741824), 1073741824, 'UNUSABLE', 'VALID'),
       NULL, TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,--decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       NULL,--decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       NULL,--decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       NULL,--decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       NULL,--decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       NULL,--decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       TO_NUMBER(NULL),TO_NUMBER(NULL),--po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       null,
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       NULL  -- ref-partitioned IOT is not supported so skip the sub-query
       , case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
              else po.interval_str end
       ,case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
              then 'YES' else 'NO' end -- autolist partitioning
       ,case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end -- interval subpartitioning
       ,case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end -- autolist subpartitioning
       ,'N/A'
       , decode(bitand(po.flags, 6144), 4096, 'YES', 2048, 'NO', 'NONE')
       , decode(bitand(po.flags, 8192), 8192, 'OFF', 'ON')
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , decode(bitand(po.flags, 65536), 65536, 'YES', 'NO')
       , NULL
       , NULL
       , NULL
from   sys.obj$ o, sys.partobj$ po, sys.tab$ t, sys.user$ u
where  o.obj# = po.obj# and t.obj# = o.obj# and
       o.owner# = u.user# and o.subname IS NULL and 
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(t.property, 64 + 128) != 0
/ 
create or replace public synonym DBA_PART_TABLES for DBA_PART_TABLES
/
grant select on DBA_PART_TABLES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PART_TABLES','CDB_PART_TABLES');
grant select on SYS.CDB_PART_TABLES to select_catalog_role
/
create or replace public synonym CDB_PART_TABLES for SYS.CDB_PART_TABLES
/

remark
remark  FAMILY "PART_INDEXES"
remark   This family of views will describe the object level partitioning
remark   information for partitioned indexes.
remark
create or replace view USER_PART_INDEXES
  (INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, 
   PARTITIONING_KEY_COUNT, SUBPARTITIONING_KEY_COUNT, 
   LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME, 
   DEF_PCT_FREE, DEF_INI_TRANS, DEF_MAX_TRANS, DEF_INITIAL_EXTENT, 
   DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE, 
   DEF_FREELISTS, DEF_FREELIST_GROUPS, DEF_LOGGING, DEF_BUFFER_POOL,
   DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_PARAMETERS, INTERVAL, AUTOLIST, INTERVAL_SUBPARTITION,
   AUTOLIST_SUBPARTITION)
as 
select io.name, o.name,
        decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 
                            5, 'REFERENCE', 'UNKNOWN'),
        decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                    3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                    'UNKNOWN'),
       po.partcnt, mod(trunc(po.spare2/65536), 65536), 
       po.partkeycols,  mod(trunc(po.spare2/256), 256),
       decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       po.parameters,
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end,
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end -- autolist subpartitioning
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and i.obj# = io.obj#
       and o.obj# = i.bo# and io.owner# = userenv('SCHEMAID') and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
       and io.subname IS NULL
/ 
create or replace public synonym USER_PART_INDEXES for USER_PART_INDEXES
/
grant read on USER_PART_INDEXES to PUBLIC with grant option
/
create or replace view ALL_PART_INDEXES
  (OWNER, INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE, 
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT,
   SUBPARTITIONING_KEY_COUNT, LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME,
   DEF_PCT_FREE, DEF_INI_TRANS, DEF_MAX_TRANS, DEF_INITIAL_EXTENT,
   DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE,
   DEF_FREELISTS, DEF_FREELIST_GROUPS, DEF_LOGGING, DEF_BUFFER_POOL,
   DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_PARAMETERS, INTERVAL, AUTOLIST, INTERVAL_SUBPARTITION,
   AUTOLIST_SUBPARTITION)
as 
select u.name, io.name, o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
                           5, 'REFERENCE', 'UNKNOWN'),
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'), 
       po.partcnt, mod(trunc(po.spare2/65536), 65536), 
       po.partkeycols, mod(trunc(po.spare2/256), 256),
       decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct, NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       po.parameters,
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end,
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end -- autolist subpartitioning
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i,
       sys.user$ u
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and
       i.obj# = io.obj# and o.obj# = i.bo# and u.user# = io.owner# and
       i.type# != 8 and      /* not LOB index */ 
       io.subname IS NULL and 
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in ( select obj#
                    from objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/ 
create or replace public synonym ALL_PART_INDEXES for ALL_PART_INDEXES
/
grant read on ALL_PART_INDEXES to PUBLIC with grant option
/
create or replace view DBA_PART_INDEXES
  (OWNER, INDEX_NAME, TABLE_NAME, PARTITIONING_TYPE, SUBPARTITIONING_TYPE,
   PARTITION_COUNT, DEF_SUBPARTITION_COUNT, PARTITIONING_KEY_COUNT,
   SUBPARTITIONING_KEY_COUNT,
   LOCALITY, ALIGNMENT, DEF_TABLESPACE_NAME, DEF_PCT_FREE, DEF_INI_TRANS, 
   DEF_MAX_TRANS, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, DEF_MAX_SIZE, 
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL, DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_PARAMETERS, INTERVAL, AUTOLIST, INTERVAL_SUBPARTITION,
   AUTOLIST_SUBPARTITION)
as 
select u.name, io.name, o.name,
       decode(po.parttype, 1, 'RANGE', 2, 'HASH', 3, 'SYSTEM', 4, 'LIST',
                           5, 'REFERENCE', 'UNKNOWN'),
       decode(mod(po.spare2, 256), 0, 'NONE', 1, 'RANGE', 2, 'HASH', 
                                   3, 'SYSTEM', 4, 'LIST', 5, 'REFERENCE',
                                   'UNKNOWN'), 
       po.partcnt, mod(trunc(po.spare2/65536), 65536), po.partkeycols, 
       mod(trunc(po.spare2/256), 256), decode(bitand(po.flags, 1), 1, 'LOCAL',    'GLOBAL'),
       decode(po.partkeycols, 0, 'NONE', decode(bitand(po.flags,2), 2, 'PREFIXED', 'NON_PREFIXED')),       
       ts.name, po.defpctfree, po.definitrans,
       po.defmaxtrans,
       decode(po.deftiniexts, NULL, 'DEFAULT', po.deftiniexts),
       decode(po.defextsize, NULL, 'DEFAULT', po.defextsize),
       decode(po.defminexts, NULL, 'DEFAULT', po.defminexts),
       decode(po.defmaxexts, NULL, 'DEFAULT', po.defmaxexts),
       decode(po.defmaxsize, NULL, 'DEFAULT', po.defmaxsize),
       decode(po.defextpct,  NULL, 'DEFAULT', po.defextpct),
       po.deflists, po.defgroups,
       decode(po.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(po.spare1, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(po.spare1, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(po.spare1, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       po.parameters,
       case when (po.parttype = 5 and bitand(po.flags, 64) = 64) then 'YES'
            else po.interval_str end,
       case when (po.parttype = 4 and bitand(po.flags, 64) = 64)
            then 'YES' else 'NO' end, -- autolist partitioning
       case when (mod(po.spare2, 256) = 1 and bitand(po.flags, 32768) = 32768)
            then po.subptn_interval_str end, -- interval subpartitioning
       case when (mod(po.spare2, 256) = 4 and bitand(po.flags, 32768) = 32768)
            then 'YES' else 'NO' end -- autolist subpartitioning
from   sys.obj$ io, sys.obj$ o, sys.partobj$ po, sys.ts$ ts, sys.ind$ i,
       sys.user$ u
where  io.obj# = po.obj# and po.defts# = ts.ts# (+) and
       i.obj# = io.obj# and o.obj# = i.bo# and u.user# = io.owner# and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL 
       and io.subname IS NULL
/ 
create or replace public synonym DBA_PART_INDEXES for DBA_PART_INDEXES
/
grant select on DBA_PART_INDEXES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PART_INDEXES','CDB_PART_INDEXES');
grant select on SYS.CDB_PART_INDEXES to select_catalog_role
/
create or replace public synonym CDB_PART_INDEXES for SYS.CDB_PART_INDEXES
/

remark
remark  FAMILY "PART_KEY_COLUMNS"
remark   This family of views will describe the partitioning key columns for
remark   all partitioned objects.
remark
remark   using an UNION rather than an OR for speed.
alter view user_part_key_columns_v$ compile;

create or replace view USER_PART_KEY_COLUMNS
as select
  NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from user_part_key_columns_v$
/
create or replace public synonym USER_PART_KEY_COLUMNS
   for USER_PART_KEY_COLUMNS
/
grant read on USER_PART_KEY_COLUMNS to PUBLIC with grant option
/

alter view all_part_key_columns_v$ compile;

create or replace view ALL_PART_KEY_COLUMNS
as select
  OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from all_part_key_columns_v$
/
create or replace public synonym ALL_PART_KEY_COLUMNS for ALL_PART_KEY_COLUMNS
/
grant read on ALL_PART_KEY_COLUMNS to PUBLIC with grant option
/

alter view dba_part_key_columns_v$ compile;

execute CDBView.create_cdbview(false,'SYS','DBA_PART_KEY_COLUMNS_V$','CDB_PART_KEY_COLUMNS_V$');

create or replace view DBA_PART_KEY_COLUMNS
as select
  OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from dba_part_key_columns_v$
/
create or replace public synonym DBA_PART_KEY_COLUMNS for DBA_PART_KEY_COLUMNS
/
grant select on DBA_PART_KEY_COLUMNS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PART_KEY_COLUMNS','CDB_PART_KEY_COLUMNS');
grant select on SYS.CDB_PART_KEY_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_PART_KEY_COLUMNS for SYS.CDB_PART_KEY_COLUMNS
/

remark 
remark  The following views are created because the fragment# in the 
remark  dictionaries no longer go from 1->n. Instead they go from a->b
remark  Further we now allows holes in the number sequence.
remark  These views are used to replicate the old behaviour of fragment#s.
remark  The phypart# is exposed in these views. It can be used in place
remark  of partition position where holes are not an issue. 
remark  eg:  It is used in *_IND_STATISTICS views in join to find 
remark  corresponding table partition of an index partition.
remark  Using part# will be slow because of row_number() function.

create or replace view tabpartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, ts#, file#, block#, 
   pctfree$, pctused$, initrans, maxtrans, flags, analyzetime, samplesize, 
   rowcnt, blkcnt, empcnt, avgspc, chncnt, avgrln, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, ts#, file#, block#, pctfree$, pctused$, 
          initrans, maxtrans, flags, analyzetime, samplesize, rowcnt, blkcnt, 
          empcnt, avgspc, chncnt, avgrln, part#
from tabpart$
where bitand(flags, 8388608) = 0           /* filter out hidden partitions */
/

grant select on tabpartv$ to select_catalog_role
/

create or replace view tabcompartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, subpartcnt, flags,
   defts#, defpctfree, defpctused, definitrans, defmaxtrans, definiexts,
   defextsize, defminexts, defmaxexts, defmaxsize,
   defextpct, deflists, defgroups,
   deflogging, defbufpool, analyzetime, samplesize, rowcnt, blkcnt,
   empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#), 
          hiboundlen, hiboundval, subpartcnt, flags, defts#, defpctfree, 
          defpctused, definitrans, defmaxtrans, definiexts,
          defextsize, defminexts, defmaxexts,defmaxsize,
          defextpct, deflists, defgroups,
          deflogging, defbufpool, analyzetime, samplesize, rowcnt, blkcnt,
          empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3, part#
from tabcompart$
where bitand(flags, 8388608) = 0           /* filter out hidden partitions */
/

grant select on tabcompartv$ to select_catalog_role
/

create or replace view tabsubpartv$
  (obj#, dataobj#, pobj#, subpart#, flags, ts#, file#, block#, pctfree$,
   pctused$, initrans, maxtrans, analyzetime, samplesize, rowcnt, blkcnt,
   empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3,
   hiboundlen, hiboundval, physubpart#)
as select obj#, dataobj#, pobj#, 
          row_number() over (partition by pobj# order by subpart#), 
          flags, ts#, file#, block#, pctfree$,
          pctused$, initrans, maxtrans, analyzetime, samplesize, rowcnt, 
          blkcnt, empcnt, avgspc, chncnt, avgrln, spare1, spare2, spare3,
          hiboundlen, hiboundval, subpart#
from tabsubpart$
where bitand(flags, 8388608) = 0          /* filter out hidden partitions */
/

grant select on tabsubpartv$ to select_catalog_role
/

create or replace view indpartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, flags, ts#, file#, 
   block#, pctfree$, pctthres$, initrans, maxtrans, analyzetime, samplesize,
   rowcnt, blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, spare1,
   spare2, spare3, inclcol, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, flags, ts#, file#, block#,
          pctfree$, pctthres$, initrans, maxtrans, analyzetime, samplesize,
          rowcnt, blevel, leafcnt, distkey, lblkkey, dblkkey, clufac, spare1,
          spare2, spare3, inclcol, part#
from indpart$
where bitand(flags, 8388608) = 0           /* filter out hidden partitions */
/

grant select on indpartv$ to select_catalog_role
/

create or replace view indcompartv$
  (obj#, dataobj#, bo#, part#, hiboundlen, hiboundval, subpartcnt, flags, 
   defts#, defpctfree, definitrans, defmaxtrans, definiexts, defextsize,
   defminexts, defmaxexts, defmaxsize, 
   defextpct, deflists, defgroups, deflogging,
   defbufpool, analyzetime, samplesize, rowcnt, blevel, leafcnt, distkey,
   lblkkey, dblkkey, clufac, spare1, spare2, spare3, phypart#)
as select obj#, dataobj#, bo#, 
          row_number() over (partition by bo# order by part#),
          hiboundlen, hiboundval, subpartcnt, flags, defts#,
          defpctfree, definitrans, defmaxtrans, definiexts, defextsize,
          defminexts, defmaxexts, defmaxsize, 
          defextpct, deflists, defgroups, deflogging,
          defbufpool, analyzetime, samplesize, rowcnt, blevel, leafcnt, 
          distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3, part#
from indcompart$
where bitand(flags, 8388608) = 0          /* filter out hidden partitions */
/

grant select on indcompartv$ to select_catalog_role
/

create or replace view indsubpartv$
  (obj#, dataobj#, pobj#, subpart#, flags, ts#, file#, block#, pctfree$,
   initrans, maxtrans, analyzetime, samplesize, rowcnt, blevel, leafcnt,
   distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3,
   hiboundlen, hiboundval, physubpart#)
as select obj#, dataobj#, pobj#, 
          row_number() over (partition by pobj# order by subpart#),
          flags, ts#, file#, block#, pctfree$,
          initrans, maxtrans, analyzetime, samplesize, rowcnt, blevel, leafcnt,
          distkey, lblkkey, dblkkey, clufac, spare1, spare2, spare3,
          hiboundlen, hiboundval, subpart#
from indsubpart$
where bitand(flags, 8388608) = 0           /* filter out hidden partitions */
/

grant select on indsubpartv$ to select_catalog_role
/

create or replace view lobfragv$
  (fragobj#, parentobj#, tabfragobj#, indfragobj#, frag#, fragtype$,
   ts#, file#, block#, chunk, pctversion$, fragflags, fragpro,
   spare1, spare2, spare3)
as select fragobj#, parentobj#, tabfragobj#, indfragobj#,
          row_number() over (partition by parentobj# order by frag#),
          fragtype$, ts#, file#, block#, chunk, pctversion$, fragflags, 
          fragpro, spare1, spare2, spare3
from lobfrag$
where bitand(fragflags, 67108864) = 0        /* filter out hidden fragments */
/

grant select on lobfragv$ to select_catalog_role
/

create or replace view lobcomppartv$
  (partobj#, lobj#, tabpartobj#, indpartobj#, part#, defts#, defchunk,
   defpctver$, defflags, defpro, definiexts, defextsize, defminexts,
   defmaxexts, defmaxsize, defretention, defmintime,
   defextpct, deflists, defgroups, defbufpool,
   spare1, spare2, spare3)
as select partobj#, lobj#, tabpartobj#, indpartobj#,
          row_number() over (partition by lobj# order by part#),
          defts#, defchunk, defpctver$, defflags, defpro, definiexts, 
          defextsize, defminexts, defmaxexts, defmaxsize, defretention,
          defmintime, defextpct, deflists, 
          defgroups, defbufpool, spare1, spare2, spare3
from lobcomppart$
where bitand(defflags, 67108864) = 0        /* filter out hidden fragments */
/

grant select on lobcomppartv$ to select_catalog_role
/

remark
remark  FAMILY "TAB_PARTITIONS"
remark   This family of views will describe, for each table partition, the
remark   partition level information, the storage parameters for the 
remark   partition, and various partition statistics determined by ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_TAB_PARTITIONS
  (TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   MAX_SIZE, PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, 
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN,SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS,
   USER_STATS, IS_NESTED, PARENT_TABLE_PARTITION, INTERVAL, SEGMENT_CREATED,
   INDEXING, READ_ONLY, INMEMORY,
   INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, CELLMEMORY, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as 
select o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by o.name order by tp.part#), 
       ts.name, tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, 
       decode(bitand(tp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tp.flags, 65536) = 65536) then
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
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 16384), 0, 'NO', 'YES'),
       case bitand(o.flags, 16384)   --is the object a nested table partition? 
       when  16384 then
       (select o1.subname
        from obj$ o1
        where o1.obj#=
        (select tp1.obj#
         from tabpartv$ tp1, tabpartv$ tp2, ntab$ nt
         where tp2.bo# = tp.bo#
         and tp2.obj# = tp.obj#
         and tp1.part# = tp2.part#
         and tp1.bo#=nt.obj#
         and nt.ntab#=tp.bo#))   
       else
         null 
       end,
       decode(bitand(tp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h)
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960), 
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
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
                        68719476736,  'BY ROWID RANGE',
                        137438953472,   'BY PARTITION',
                        206158430208,  'BY SUBPARTITION',
                        0,             'AUTO'),
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              null),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', null),
                 null)
       end,
       -- CELLMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tp.flags, power(2,30)), power(2,30), 
                               'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tp.flags, power(2,31)), power(2,31),
                               'ENABLED', 'DISABLED')
from   obj$ o, tabpart$ tp, ts$ ts, sys.seg$ s, sys.tab$ t, 
       sys.deferred_stg$ ds, sys.imsvc$ svc
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and tp.obj# = ds.obj#(+) and 
       tp.file#=s.file#(+) and tp.block#=s.block#(+) and tp.ts#=s.ts#(+) and 
       bitand(t.property, 64) != 64 and 
       bitand(tp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.owner# = userenv('SCHEMAID')
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
union all -- IOT PARTITIONS
select o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by o.name order by tp.part#), NULL,
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL), TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A', 'N/A',
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL, NULL, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A', 'N/A',
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
       'N/A', 'N/A'
from   obj$ o, tabpart$ tp, tab$ t
where  o.obj# = tp.obj# and
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(t.property, 64) = 64 and 
       o.owner# = userenv('SCHEMAID')
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select o.name, 'YES', o.subname, tcp.subpartcnt,
       tcp.hiboundval, tcp.hiboundlen, 
       row_number() over (partition by o.name order by tcp.part#), 
       ts.name, tcp.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defpctused), 
       tcp.definitrans, tcp.defmaxtrans,
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defmaxsize, tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32,  to_number(NULL),tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(tcp.spare2, 3), 1, 'ENABLED', 2, 'DISABLED', 'NONE'),
       decode(bitand(tcp.spare2, 1), 0, null,
         case bitand(tcp.spare2, 127) -- 1st 7 bits used
         when 1 then 'BASIC'                               -- 00000001
         when 5 then 'ADVANCED'                            -- 00000101
         when 9 then 'QUERY LOW'                           -- 00001001
         when 17 then 'QUERY HIGH'                         -- 00010001
         when 25 then 'ARCHIVE LOW'                        -- 00011001
         when 33 then 'ARCHIVE HIGH'                       -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'        -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'       -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'      -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'     -- 01100001
                 else 'UNKNOWN' end),                      -- internal ilevels
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(bitand(tcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A',
       decode(bitand(tcp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tcp.spare2, 768), 256, 'NO', 512, 'YES', 'NONE'),
       decode(bitand(tcp.spare2, 3072), 1024, 'ON', 2048, 'OFF', 'NONE'),
       decode(bitand(tcp.spare2, 12288), 4096, 'YES',8192, 'NO', 'NONE'),
       -- INMEMORY
       -- defimcflags_kkpacpcd
       decode(bitand(tcp.spare2, 196608), 
              0,      'NONE',
              65536,  'ENABLED',
              131072, 'DISABLED', 'UNKNOWN'),
       -- INMEMORY_PRIORITY
       case bitand(mod(trunc(tcp.spare2/65536),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- INMEMORY_DISTRIBUTE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 262144), 262144,
                     decode(bitand(tcp.spare2, (2097152+4194304)),
                     0,         'AUTO',
                     2097152,   'BY ROWID RANGE',
                     4194304,   'BY PARTITION',
                     6291456,   'BY SUBPARTITION'),
              null), null),
       -- INMEMORY_COMPRESSION
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, (524288+8388608+16777216)),
                              524288,             'NO MEMCOMPRESS',
                              8388608,            'FOR DML',
                              (524288+8388608),   'FOR QUERY LOW',
                              16777216,           'FOR QUERY HIGH',
                              (524288+16777216),  'FOR CAPACITY LOW',
                              (8388608+16777216), 'FOR CAPACITY HIGH',
                     null),
              null),
       -- INMEMORY_DUPLICATE
       decode (bitand(tcp.spare2, 65536), 65536,
               decode(bitand(tcp.spare2, (67108864+134217728)),
                              67108864,   'NO DUPLICATE',
                              134217728,  'DUPLICATE',
                              (67108864+134217728),  'DUPLICATE ALL',
                              null),
                null),
       -- CELLMEMORY
       decode(bitand(tcp.spare2, 133143986176),
              8589934592,  'DISABLED',
              21474836480, 'NO MEMCOMPRESS',
              38654705664, 'MEMCOMPRESS FOR QUERY',
              73014444032, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- INMEMORY_SERVICE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     decode(bitand(svc.svcflags, 7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            'DEFAULT'),
                     null),
              null),
       -- INMEMORY_SERVICE_NAME
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     svc.svcname, null),
              null),
       'N/A', 'N/A'
from   obj$ o, tabcompart$ tcp, ts$ ts, tab$ t, imsvc$ svc
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and 
       o.owner# = userenv('SCHEMAID') and
       bitand(t.property, 64) != 64 and 
       bitand(tcp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       tcp.bo# = t.obj# and
       (bitand(t.trigflag, 1073741824) != 1073741824) and
       o.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym USER_TAB_PARTITIONS for USER_TAB_PARTITIONS
/
grant read on USER_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_TAB_PARTITIONS
  (TABLE_OWNER, TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   MAX_SIZE, PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS,
   USER_STATS, IS_NESTED, PARENT_TABLE_PARTITION, INTERVAL, SEGMENT_CREATED,
   INDEXING, READ_ONLY,
   INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, CELLMEMORY, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as 
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tp.part#), 
       ts.name, tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, 
       decode(bitand(tp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tp.flags, 65536) = 65536) then
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
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 16384), 0, 'NO', 'YES'),
       case bitand(o.flags, 16384)   --is the object a nested table partition? 
       when  16384 then
       (select o1.subname
        from obj$ o1
        where o1.obj#=
        (select tp1.obj#
         from tabpartv$ tp1, tabpartv$ tp2, ntab$ nt
         where tp2.bo# = tp.bo#
         and tp2.obj# = tp.obj#
         and tp1.part# = tp2.part#
         and tp1.bo#=nt.obj#
         and nt.ntab#=tp.bo#))   
       else
         null 
       end,
       decode(bitand(tp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960),
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
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
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,  'NO MEMCOMPRESS',
                              8,  'FOR DML',
                              10, 'FOR QUERY LOW',
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
       case when (bitand(tp.flags, 65536) = 65536) then
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
       -- CELLMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tp.flags, power(2,30)), power(2,30),
                               'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tp.flags, power(2,31)), power(2,31),
                               'ENABLED', 'DISABLED')
from   obj$ o, tabpart$ tp, ts$ ts, sys.seg$ s, user$ u, tab$ t, 
       deferred_stg$ ds, imsvc$ svc
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and u.user# = o.owner# and 
       tp.obj# = ds.obj#(+) and 
       tp.file#=s.file#(+) and tp.block#=s.block#(+) and tp.ts#=s.ts#(+) and 
       bitand(t.property, 64) != 64 and 
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
       bitand(tp.flags, 8388608) = 0 and   /* filter out hidden partitions */
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      ) and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
union all -- IOT PARTITIONS
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tp.part#), NULL, 
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL), TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A', 'N/A',
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL, NULL, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A', 'N/A',
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
       'N/A', 'N/A'
from   obj$ o, tabpart$ tp, user$ u, tab$ t
where  o.obj# = tp.obj# and o.owner# = u.user# and 
       tp.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(t.property, 64) = 64 and 
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all -- COMPOSITE PARTITIONS
select u.name, o.name, 'YES', o.subname, tcp.subpartcnt, 
       tcp.hiboundval, tcp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tcp.part#), 
       ts.name, tcp.defpctfree, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defpctused),
       tcp.definitrans, tcp.defmaxtrans, 
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defmaxsize, tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(tcp.spare2, 3), 1, 'ENABLED', 2, 'DISABLED', 'NONE'),
       decode(bitand(tcp.spare2, 1), 0, null,
         case bitand(tcp.spare2, 127) -- 1st 7 bits used
         when 1 then 'BASIC'                             -- 00000001
         when 5 then 'ADVANCED'                          -- 00000101
         when 9 then 'QUERY LOW'                         -- 00001001
         when 17 then 'QUERY HIGH'                       -- 00010001
         when 25 then 'ARCHIVE LOW'                      -- 00011001
         when 33 then 'ARCHIVE HIGH'                     -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'      -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'     -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'    -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'   -- 01100001
                 else 'UNKNOWN' end),                    -- internal
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(bitand(tcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A',
       decode(bitand(tcp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tcp.spare2, 768), 256, 'NO', 512, 'YES', 'NONE'),
       decode(bitand(tcp.spare2, 3072), 1024, 'ON', 2048, 'OFF', 'NONE'),
       decode(bitand(tcp.spare2, 12288), 4096, 'YES',8192, 'NO','NONE'),
       -- INMEMORY
       -- defimcflags_kkpacpcd
       decode(bitand(tcp.spare2, 196608),
              0,      'NONE',
              65536,  'ENABLED',
              131072, 'DISABLED', 'UNKNOWN'),
       -- INMEMORY_PRIORITY
       case bitand(mod(trunc(tcp.spare2/65536),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- INMEMORY_DISTRIBUTE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 262144), 262144,
                     decode(bitand(tcp.spare2, (2097152+4194304)),
                     0,         'AUTO',
                     2097152,   'BY ROWID RANGE',
                     4194304,   'BY PARTITION',
                     6291456,   'BY SUBPARTITION'),
              null), null),
       -- INMEMORY_COMPRESSION
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, (524288+8388608+16777216)),
                              524288,             'NO MEMCOMPRESS',
                              8388608,            'FOR DML',
                              (524288+8388608),   'FOR QUERY LOW',
                              16777216,           'FOR QUERY HIGH',
                              (524288+16777216),  'FOR CAPACITY LOW',
                              (8388608+16777216), 'FOR CAPACITY HIGH',
                     null),
              null),
       -- INMEMORY_DUPLICATE
       decode (bitand(tcp.spare2, 65536), 65536,
               decode(bitand(tcp.spare2, (67108864+134217728)),
                              67108864,   'NO DUPLICATE',
                              134217728,  'DUPLICATE',
                              (67108864+134217728),  'DUPLICATE ALL',
                null), null),
       -- CELLMEMORY 
       decode(bitand(tcp.spare2, 133143986176),
              8589934592,  'DISABLED',
              21474836480, 'NO MEMCOMPRESS',
              38654705664, 'MEMCOMPRESS FOR QUERY',
              73014444032, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- INMEMORY_SERVICE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     decode(bitand(svc.svcflags, 7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            'DEFAULT'),
                     null),
              null),
       -- INMEMORY_SERVICE_NAME
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     svc.svcname, null),
              null),
       'N/A', 'N/A'
from   obj$ o, tabcompart$ tcp, ts$ ts, user$ u, tab$ t, imsvc$ svc
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and u.user# = o.owner# and
       tcp.bo# = t.obj# 
       and bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(t.property, 64) != 64 and 
       bitand(tcp.flags, 8388608) = 0 and   /* filter out hidden partitions */
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      ) and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym ALL_TAB_PARTITIONS for ALL_TAB_PARTITIONS
/
grant read on ALL_TAB_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_TAB_PARTITIONS
  (TABLE_OWNER, TABLE_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, TABLESPACE_NAME, PCT_FREE, PCT_USED, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT,
   MAX_SIZE, PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED, BUFFER_POOL, 
   FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS,
   USER_STATS, IS_NESTED, PARENT_TABLE_PARTITION, INTERVAL, SEGMENT_CREATED,
   INDEXING, READ_ONLY, INMEMORY,
   INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, CELLMEMORY, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as 
select u.name, o.name, 'NO', o.subname, 0,
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tp.part#), 
       ts.name, tp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tp.pctused$), 
       tp.initrans, tp.maxtrans, 
       decode(bitand(tp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tp.flags, 65536) = 65536) then
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
       tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln,
       tp.samplesize, tp.analyzetime,
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(o.flags, 16384), 0, 'NO', 'YES'),
       case bitand(o.flags, 16384)   --is the object a nested table partition? 
       when  16384 then
       (select o1.subname
        from obj$ o1
        where o1.obj#=
        (select tp1.obj#
         from tabpartv$ tp1, tabpartv$ tp2, ntab$ nt
         where tp2.bo# = tp.bo#
         and tp2.obj# = tp.obj#
         and tp1.part# = tp2.part#
         and tp1.bo#=nt.obj#
         and nt.ntab#=tp.bo#))  
       else
         null 
       end,
       decode(bitand(tp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960),
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
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
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              null),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', null),
                null)
       end,
       -- CELLMEMORY
       case when (bitand(tp.flags, 65536) = 65536) then
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
       case when (bitand(tp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tp.flags, power(2,30)), power(2,30), 
              'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tp.flags, power(2,31)), power(2,31), 
              'ENABLED', 'DISABLED')
from   obj$ o, tabpart$ tp, ts$ ts, sys.seg$ s, user$ u, tab$ t, 
       sys.deferred_stg$ ds, sys.imsvc$ svc
where  o.obj# = tp.obj# and ts.ts# = tp.ts# and u.user# = o.owner# and 
       tp.obj# = ds.obj#(+) and
       tp.file#=s.file#(+) and tp.block#=s.block#(+) and tp.ts#=s.ts#(+) and
       bitand(t.property, 64) != 64 and 
       bitand(tp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       tp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
union all -- IOT PARTITIONS
select u.name, o.name, 'NO', o.subname, 0, 
       tp.hiboundval, tp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tp.part#), NULL, 
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL), TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),TO_NUMBER(NULL),
       TO_NUMBER(NULL),TO_NUMBER(NULL),
       NULL,
       'N/A', 'N/A',
       tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), 0, tp.chncnt, tp.avgrln, 
       tp.samplesize, tp.analyzetime, NULL, NULL, NULL,
       decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A', 'N/A',
       decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tp.flags, 67108864), 67108864, 'YES', 'NO'),
       'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
       'N/A', 'N/A'
from   obj$ o, tabpart$ tp, user$ u, tab$ t
where  o.obj# = tp.obj# and o.owner# = u.user# and 
       tp.bo# = t.obj# and bitand(t.property, 64) = 64 and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union all -- COMPOSITE PARTITIONS
select u.name, o.name, 'YES', o.subname, tcp.subpartcnt, 
       tcp.hiboundval, tcp.hiboundlen, 
       row_number() over (partition by u.name, o.name order by tcp.part#), 
       ts.name,
       tcp.defpctfree, decode(bitand(ts.flags, 32), 32, to_number(NULL), 
       tcp.defpctused),
       tcp.definitrans, tcp.defmaxtrans, 
       tcp.definiexts, tcp.defextsize, tcp.defminexts, tcp.defmaxexts, 
       tcp.defmaxsize, tcp.defextpct, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.deflists),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tcp.defgroups),
       decode(tcp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       decode(bitand(tcp.spare2, 3), 1, 'ENABLED', 2, 'DISABLED', 'NONE'),
       decode(bitand(tcp.spare2, 1), 0, null,
         case bitand(tcp.spare2, 127) -- 1st 7 bits used
         when 1 then 'BASIC'                             -- 00000001
         when 5 then 'ADVANCED'                          -- 00000101
         when 9 then 'QUERY LOW'                         -- 00001001
         when 17 then 'QUERY HIGH'                       -- 00010001
         when 25 then 'ARCHIVE LOW'                      -- 00011001
         when 33 then 'ARCHIVE HIGH'                     -- 00100001
         when 73 then 'QUERY LOW ROW LEVEL LOCKING'      -- 01001001
         when 81 then 'QUERY HIGH ROW LEVEL LOCKING'     -- 01010001
         when 89 then 'ARCHIVE LOW ROW LEVEL LOCKING'    -- 01011001
         when 97 then 'ARCHIVE HIGH ROW LEVEL LOCKING'   -- 01100001
                 else 'UNKNOWN' end),                    -- internal ilevels
       tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt, tcp.avgrln,
       tcp.samplesize, tcp.analyzetime, 
       decode(bitand(tcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
       'N/A', 'N/A',
       decode(bitand(tcp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tcp.spare2, 768), 256, 'NO', 512, 'YES', 'NONE'),
       decode(bitand(tcp.spare2, 3072), 1024, 'ON', 2048, 'OFF', 'NONE'),
       decode(bitand(tcp.spare2, 12288), 4096, 'YES',8192, 'NO', 'NONE'),
       -- INMEMORY
       -- defimcflags_kkpacpcd
       decode(bitand(tcp.spare2, 196608),
              0,      'NONE',
              65536,  'ENABLED',
              131072, 'DISABLED', 'UNKNOWN'),
       -- INMEMORY_PRIORITY
       case bitand(mod(trunc(tcp.spare2/65536),4096), 17) -- bits 0,4
         when 0 then NULL
         when 1 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             else NULL end
         when 17 then
           case bitand(mod(trunc(tcp.spare2/268435456),16), 7)
             when 0 then 'NONE'
             when 1 then 'LOW'
             when 2 then 'MEDIUM'
             when 3 then 'HIGH'
             when 4 then 'CRITICAL'
             else 'UNKNOWN' end
         else 'UNKNOWN' end,
       -- INMEMORY_DISTRIBUTE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 262144), 262144,
                     decode(bitand(tcp.spare2, (2097152+4194304)),
                     0,         'AUTO',
                     2097152,   'BY ROWID RANGE',
                     4194304,   'BY PARTITION',
                     6291456,   'BY SUBPARTITION'),
              null), null),
       -- INMEMORY_COMPRESSION
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, (524288+8388608+16777216)),
                              524288,             'NO MEMCOMPRESS',
                              8388608,            'FOR DML',
                              (524288+8388608),   'FOR QUERY LOW',
                              16777216,           'FOR QUERY HIGH',
                              (524288+16777216),  'FOR CAPACITY LOW',
                              (8388608+16777216), 'FOR CAPACITY HIGH',
                     null),
              null),
       -- INMEMORY_DUPLICATE
       decode (bitand(tcp.spare2, 65536), 65536,
               decode(bitand(tcp.spare2, (67108864+134217728)),
                              67108864,   'NO DUPLICATE',
                              134217728,  'DUPLICATE',
                              (67108864+134217728),  'DUPLICATE ALL',
                              null),
                null),
       -- CELLMEMORY
       decode(bitand(tcp.spare2, 133143986176),
              8589934592,  'DISABLED',
              21474836480, 'NO MEMCOMPRESS',
              38654705664, 'MEMCOMPRESS FOR QUERY',
              73014444032, 'MEMCOMPRESS FOR CAPACITY',
              NULL),
       -- INMEMORY_SERVICE
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     decode(bitand(svc.svcflags, 7),
                            0, null,
                            1, 'DEFAULT',
                            2, 'NONE',
                            3, 'ALL',
                            4, 'USER_DEFINED',
                            'DEFAULT'),
                     null),
              null),
       -- INMEMORY_SERVICE_NAME
       decode(bitand(tcp.spare2, 65536), 65536,
              decode(bitand(tcp.spare2, 1099511627776), 1099511627776,
                     svc.svcname, null),
              null),
       'N/A','N/A'
from   obj$ o, tabcompart$ tcp, ts$ ts, user$ u, tab$ t, imsvc$ svc
where  o.obj# = tcp.obj# and tcp.defts# = ts.ts# and u.user# = o.owner# and
       tcp.bo# = t.obj# 
       and bitand(t.trigflag, 1073741824) != 1073741824
       and bitand(t.property, 64) != 64
       and bitand(tcp.flags, 8388608) = 0    /* filter out hidden partitions */
       and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
       and o.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym DBA_TAB_PARTITIONS for DBA_TAB_PARTITIONS
/
grant select on DBA_TAB_PARTITIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_PARTITIONS','CDB_TAB_PARTITIONS');
grant select on SYS.CDB_TAB_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_TAB_PARTITIONS for SYS.CDB_TAB_PARTITIONS
/

remark
remark  FAMILY "IND_PARTITIONS"
remark   This family of views will describe, for each index partition, the
remark   partition level information, the storage parameters for the 
remark   partition, and various partition statistics determined by ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_IND_PARTITIONS
  (INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, MAX_SIZE, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS,
   INTERVAL, SEGMENT_CREATED, ORPHANED_ENTRIES)
as 
select io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       row_number() over (partition by io.name order by ip.part#), 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,
       ip.pctfree$, ip.initrans, ip.maxtrans, 
       decode(bitand(ip.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(ip.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(ip.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(ip.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(ip.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(ip.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(ip.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'),
       case
         when bitand(ip.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(ip.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), '','',
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from   obj$ io, indpart$ ip, ts$ ts, sys.seg$ s, ind$ i, tab$ t, 
       sys.deferred_stg$ ds
where  io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file#(+) and
       ip.block#=s.block#(+) and ip.ts#=s.ts#(+) and ip.obj# = ds.obj#(+) and
       io.owner# = userenv('SCHEMAID') and ip.bo# = i.obj# and 
       bitand(ip.flags, 8388608) = 0 and    /* filter out hidden partitions */
       i.type# != 9 and 
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
union all
select io.name, 'YES', io.subname,icp.subpartcnt, 
       icp.hiboundval, icp.hiboundlen, 
       row_number() over (partition by io.name order by icp.part#), 
       'N/A', ts.name,  
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       case
         when bitand(icp.spare3, 8) = 8 then 'ADVANCED LOW'
         when bitand(icp.spare3, 4) = 4 then 'ADVANCED HIGH' 
       else
         decode(bitand(icp.flags, 1024), 1024, 'ENABLED', 'DISABLED')
       end,
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(bitand(icp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), '','', 
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from   obj$ io, indcompart$ icp, ts$ ts, ind$ i, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and
       io.owner# = userenv('SCHEMAID') and
       i.type# != 9 and 
       icp.bo# = i.obj# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(icp.flags, 8388608) = 0 and    /* filter out hidden partitions */
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
union all
select io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       row_number() over (partition by io.name order by ip.part#), 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null,
       ip.pctfree$, ip.initrans, ip.maxtrans,  
       0, 0, 0, 0, 0, 0, 0,0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       'N/A',
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''),
       ipp.parameters,
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from   obj$ io, indpart$ ip, indpart_param$ ipp, ind$ i, tab$ t
where  io.obj# = ip.obj# and ip.obj# = ipp.obj# and
       ip.bo# = i.obj# and io.owner# = userenv('SCHEMAID') and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
union all
select io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, 
       row_number() over (partition by io.name order by icp.part#), 
       'N/A', null,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       0, 0, 0, 0, 0, 0, 0,0,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(icp.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''),
       ipp.parameters,
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from   obj$ io, indcompart$ icp, indpart_param$ ipp, ind$ i, tab$ t
where  io.obj# = icp.obj# and icp.obj# = ipp.obj# and
       icp.bo# = i.obj# and io.owner# = userenv('SCHEMAID') and
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824
/
create or replace public synonym USER_IND_PARTITIONS for USER_IND_PARTITIONS
/
grant read on USER_IND_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_IND_PARTITIONS
  (INDEX_OWNER, INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, MAX_SIZE, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS,
   INTERVAL, SEGMENT_CREATED, ORPHANED_ENTRIES)
as 
select u.name, io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       row_number() over (partition by u.name, io.name order by ip.part#), 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'),ts.name,
       ip.pctfree$, ip.initrans, ip.maxtrans, 
       decode(bitand(ip.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(ip.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(ip.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(ip.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(ip.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       case
         when bitand(ip.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(ip.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,                    
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),                      
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), '','',
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from obj$ io, indpart$ ip, ts$ ts, sys.seg$ s, ind$ i, sys.user$ u, tab$ t,
     sys.deferred_stg$ ds
where io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file#(+) and
      ip.block#=s.block#(+) and ip.ts#=s.ts#(+) and io.owner# = u.user# and 
      i.obj# = ip.bo# and i.bo# = t.obj# and ip.obj# = ds.obj#(+) and
      bitand(ip.flags, 8388608) = 0 and    /* filter out hidden partitions */
      bitand(t.trigflag, 1073741824) != 1073741824 and
      i.type# != 8 and      /* not LOB index */
      i.type# != 9 and      /* not DOMAIN index */ 
      io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
        (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    from objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, 
       row_number() over (partition by u.name, io.name order by icp.part#) ,
       'N/A', ts.name,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       case
         when bitand(icp.spare3, 8) = 8 then 'ADVANCED LOW'
         when bitand(icp.spare3, 4) = 4 then 'ADVANCED HIGH' 
       else
         decode(bitand(icp.flags, 1024), 1024, 'ENABLED', 'DISABLED')
       end,
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(bitand(icp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), '','', 
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from   obj$ io, indcompart$ icp, ts$ ts, ind$ i, user$ u, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and io.owner# = u.user# and
       i.obj# = icp.bo# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(icp.flags, 8388608) = 0 and    /* filter out hidden partitions */
       i.type# != 8 and      /* not LOB index */
       i.type# != 9 and      /* not DOMAIN index */
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
       (io.owner# = userenv('SCHEMAID') 
        or 
        i.bo# in (select oa.obj#
                 from sys.objauth$ oa
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      ) 
                   )
        or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, io.name, 'NO', io.subname, 0,
       ip.hiboundval, ip.hiboundlen, 
       row_number() over (partition by u.name, io.name order by ip.part#), 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')),
       null, ip.pctfree$, ip.initrans, ip.maxtrans, 
       0, 0, 0, 0, 0, 0, 0, 0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       'N/A',
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'), 
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''),
       ipp.parameters, 
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from obj$ io, indpart$ ip, ind$ i, sys.user$ u, indpart_param$ ipp, tab$ t
where io.obj# = ip.obj# and io.owner# = u.user# and 
      i.obj# = ip.bo# and ip.obj# = ipp.obj# and 
      i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
      io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
        (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    from objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, 
       row_number() over (partition by u.name, io.name order by icp.part#), 
       'N/A', null,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       0, 0, 0, 0, 0, 0, 0, 0,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
       decode(i.type#, 
             9, decode(bitand(icp.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''),
       ipp.parameters, 
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from obj$ io, indcompart$ icp, ind$ i, sys.user$ u, indpart_param$ ipp, tab$ t
where io.obj# = icp.obj# and io.owner# = u.user# and 
      i.obj# = icp.bo# and icp.obj# = ipp.obj# and 
      i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
      io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL and
        (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    from objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                   )
        or
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
create or replace public synonym ALL_IND_PARTITIONS for ALL_IND_PARTITIONS
/
grant read on ALL_IND_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_IND_PARTITIONS
  (INDEX_OWNER, INDEX_NAME, COMPOSITE, PARTITION_NAME, SUBPARTITION_COUNT, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, 
   PARTITION_POSITION, STATUS, TABLESPACE_NAME, PCT_FREE, INI_TRANS, MAX_TRANS,
   INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, MAX_EXTENT, MAX_SIZE, PCT_INCREASE, 
   FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, PCT_DIRECT_ACCESS, GLOBAL_STATS, DOMIDX_OPSTATUS, PARAMETERS,
   INTERVAL, SEGMENT_CREATED, ORPHANED_ENTRIES)
as 
select u.name, io.name, 'NO', io.subname, 0, 
       ip.hiboundval, ip.hiboundlen, 
       row_number() over (partition by u.name, io.name order by ip.part#),
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,
       ip.pctfree$,ip.initrans, ip.maxtrans, 
       decode(bitand(ip.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(ip.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(ip.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(ip.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(ip.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(ip.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       case
         when bitand(ip.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(ip.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,             
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(ip.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),               
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),'','',
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from   obj$ io, indpart$ ip, ts$ ts, sys.seg$ s, user$ u, ind$ i, tab$ t,
       sys.deferred_stg$ ds
where  io.obj# = ip.obj# and ts.ts# = ip.ts# and ip.file#=s.file#(+) and
       ip.block#=s.block#(+) and ip.ts#=s.ts#(+) and io.owner# = u.user# and
       i.obj# = ip.bo# and i.bo# = t.obj# and ip.obj# = ds.obj#(+) and
       i.type# != 9 and 
       bitand(ip.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
      union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt,
       icp.hiboundval, icp.hiboundlen, 
       row_number() over (partition by u.name, io.name order by icp.part#), 
       'N/A', ts.name,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       case
         when bitand(icp.spare3, 8) = 8 then 'ADVANCED LOW'
         when bitand(icp.spare3, 4) = 4 then 'ADVANCED HIGH' 
       else
         decode(bitand(icp.flags, 1024), 1024, 'ENABLED', 'DISABLED')
       end,
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       decode(bitand(icp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'),'','', 
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from   obj$ io, indcompart$ icp, ts$ ts, user$ u, ind$ i, tab$ t
where  io.obj# = icp.obj# and icp.defts# = ts.ts# (+) and 
       u.user# = io.owner# and i.obj# = icp.bo# and i.bo# = t.obj# and 
       i.type# != 9 and 
       bitand(t.trigflag, 1073741824) != 1073741824 and
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
      union all
select u.name, io.name, 'NO', io.subname, 0, 
       ip.hiboundval, ip.hiboundlen,
       row_number() over (partition by u.name, io.name order by ip.part#), 
       decode(bitand(ip.flags, 1), 1, 'UNUSABLE', 
                decode(bitand(ip.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null, ip.pctfree$, ip.initrans, ip.maxtrans, 
       0, 0, 0, 0, 0, 0, 0, 0,
       decode(mod(trunc(ip.flags / 4), 2), 0, 'YES', 'NO'), 
       'N/A',
       ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
       ip.clufac, ip.rowcnt, ip.samplesize, ip.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(ip.flags, 8), 0, 'NO', 'YES'), ip.pctthres$,
       decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(ip.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''), 
       ipp.parameters, 
       decode(bitand(ip.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(ip.flags, 262144), 262144, 'YES', 'NO')
from   obj$ io, indpart$ ip,  user$ u, ind$ i, indpart_param$ ipp, tab$ t
where  io.obj# = ip.obj# and io.owner# = u.user# and
       ip.bo# = i.obj# and ip.obj# = ipp.obj# and i.bo# = t.obj# and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
      union all
select u.name, io.name, 'YES', io.subname, icp.subpartcnt, 
       icp.hiboundval, icp.hiboundlen,
       row_number() over (partition by u.name, io.name order by icp.part#), 
       'N/A', null,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       0, 0, 0, 0, 0, 0, 0, 0,
       decode(icp.deflogging, 0, 'NONE', 1, 'YES', 2, 'NO', 'UNKNOWN'),
       'N/A',
       icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
       icp.clufac, icp.rowcnt, icp.samplesize, icp.analyzetime,
       'DEFAULT', 'DEFAULT', 'DEFAULT',
       decode(bitand(icp.flags, 8), 0, 'NO', 'YES'), TO_NUMBER(NULL),
       decode(bitand(icp.flags, 16), 0, 'NO', 'YES'),
       decode(i.type#, 
             9, decode(bitand(icp.flags, 8192), 8192, 'FAILED', 'VALID'),
             ''), 
       ipp.parameters, 
       decode(bitand(icp.flags, 32768), 32768, 'YES', 'NO'), 'N/A', 'N/A'
from   obj$ io, indcompart$ icp,  user$ u, ind$ i, indpart_param$ ipp, tab$ t
where  io.obj# = icp.obj# and io.owner# = u.user# and
       icp.bo# = i.obj# and icp.obj# = ipp.obj# and i.bo# = t.obj# and 
       bitand(t.trigflag, 1073741824) != 1073741824
       and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
/
create or replace public synonym DBA_IND_PARTITIONS for DBA_IND_PARTITIONS
/
grant select on DBA_IND_PARTITIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_IND_PARTITIONS','CDB_IND_PARTITIONS');
grant select on SYS.CDB_IND_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_IND_PARTITIONS for SYS.CDB_IND_PARTITIONS
/

remark
remark  FAMILY "TAB_SUBPARTITIONS"
remark   This family of views will describe, for each table subpartition,
remark   the subpartition level information, the storage parameters for the
remark   subpartition, and various subpartition statistics determined by
remark   ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_TAB_SUBPARTITIONS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS, USER_STATS,
   INTERVAL, SEGMENT_CREATED, INDEXING, READ_ONLY,
   INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME, CELLMEMORY,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as
select po.name, po.subname, so.subname,  
       tsp.hiboundval, tsp.hiboundlen, 
       dense_rank() over (partition by po.name order by tcp.part#),
       row_number() over (partition by po.name,po.subname
                          order by tsp.subpart#),
       ts.name,  tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans,
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tsp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tsp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tsp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tsp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tsp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'), 
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tsp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tsp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tsp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960),
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       case when (bitand(tsp.flags, 65536) = 65536) then
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
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tsp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (2+8+64+128)),
                              2,   'NO MEMCOMPRESS',
                              8,   'FOR DML',
                              10,  'FOR QUERY LOW',
                              64,  'FOR QUERY HIGH',
                              66,  'FOR CAPACITY LOW',
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
       case when (bitand(tsp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              null),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', null),
                null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(tsp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- CELLMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tsp.flags, power(2,30)), power(2,30),
                                'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tsp.flags, power(2,31)), power(2,31),
                                'ENABLED', 'DISABLED')
from   sys.obj$ so, sys.obj$ po, sys.tabcompart$ tcp, sys.tabsubpart$ tsp,
       sys.tab$ t, sys.ts$ ts, sys.seg$ s, sys.deferred_stg$ ds, sys.imsvc$ svc
where  so.obj# = tsp.obj# and po.obj# = tsp.pobj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       tsp.ts# = ts.ts# and tsp.obj# = ds.obj#(+) and 
       bitand(tcp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(tsp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       tsp.file# = s.file#(+) and tsp.block# = s.block#(+) 
       and tsp.ts# = s.ts#(+) and
       po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID')
       and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL 
       and tsp.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym USER_TAB_SUBPARTITIONS
   for USER_TAB_SUBPARTITIONS
/
grant read on USER_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_TAB_SUBPARTITIONS
  (TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS, USER_STATS,
   INTERVAL, SEGMENT_CREATED, INDEXING, READ_ONLY,
   INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME, CELLMEMORY,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as 
select u.name, po.name, po.subname, so.subname, 
       tsp.hiboundval, tsp.hiboundlen, 
       dense_rank() over (partition by po.name order by tcp.part#),
       row_number() over (partition by u.name, po.name, po.subname 
                          order by tsp.subpart#),
       ts.name, tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans,
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tsp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tsp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tsp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tsp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tsp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tsp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tsp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tsp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960),
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       case when (bitand(tsp.flags, 65536) = 65536) then
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
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       case when (bitand(tsp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              null),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', null),
                null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(tsp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- CELLMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tsp.flags, power(2,30)), power(2,30),
                                'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tsp.flags, power(2,31)), power(2,31),
                                'ENABLED', 'DISABLED')
from   obj$ po, obj$ so, tabcompart$ tcp, tabsubpart$ tsp, tab$ t,
       ts$ ts, sys.seg$ s, user$ u, sys.deferred_stg$ ds, sys.imsvc$ svc
where  so.obj# = tsp.obj# and po.obj# = tcp.obj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       ts.ts# = tsp.ts# and u.user# = po.owner# and tsp.file# = s.file#(+) and
       tsp.block# = s.block#(+) and tsp.ts# = s.ts#(+) and 
       tsp.obj# = ds.obj#(+) and
       bitand(tcp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(tsp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL and
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      ) and tsp.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym ALL_TAB_SUBPARTITIONS
   for ALL_TAB_SUBPARTITIONS
/
grant read on ALL_TAB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_TAB_SUBPARTITIONS
  (TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME,
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   TABLESPACE_NAME, PCT_FREE, PCT_USED,
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION,
   COMPRESS_FOR, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_SPACE, CHAIN_CNT,
   AVG_ROW_LEN, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, GLOBAL_STATS, USER_STATS,
   INTERVAL, SEGMENT_CREATED, INDEXING, READ_ONLY,
   INMEMORY, INMEMORY_PRIORITY, INMEMORY_DISTRIBUTE, INMEMORY_COMPRESSION,
   INMEMORY_DUPLICATE, INMEMORY_SERVICE, INMEMORY_SERVICE_NAME, CELLMEMORY,
   MEMOPTIMIZE_READ, MEMOPTIMIZE_WRITE)
as
select u.name, po.name, po.subname, so.subname, 
       tsp.hiboundval, tsp.hiboundlen, 
       dense_rank() over (partition by po.name order by tcp.part#),
       row_number() over (partition by u.name, po.name,po.subname 
                          order by tsp.subpart#),
       ts.name,  tsp.pctfree$, 
       decode(bitand(ts.flags, 32), 32, to_number(NULL), tsp.pctused$), 
       tsp.initrans, tsp.maxtrans,
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(tsp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(tsp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(tsp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(tsp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(tsp.flags, 65536), 65536, ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL), 
              decode(bitand(tsp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(tsp.flags / 4), 2), 0, 'YES', 'NO'),
       case when (bitand(tsp.flags, 65536) = 65536) then 
         decode(bitand(ds.flags_stg, 4), 4, 'ENABLED', 'DISABLED')
       else
         decode(bitand(s.spare1, 2048), 2048, 'ENABLED', 'DISABLED')
       end,
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt, 
       tsp.avgrln, tsp.samplesize, tsp.analyzetime,
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(tsp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(tsp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(tsp.flags, 65536), 65536, 'NO', 'YES'),
       decode(bitand(tsp.flags, 2097152), 2097152, 'OFF', 'ON'),
       decode(bitand(tsp.flags, 67108864), 67108864, 'YES', 'NO'),
       --INMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
          -- flags/imcflag_stg (stgdef.h
          decode(bitand(ds.flags_stg, 6291456),
                2097152, 'ENABLED',
                4194304, 'DISABLED', 'DISABLED')
       else
          -- ktsscflg (ktscts.h)
          decode(bitand(s.spare1, 70373039144960),
                4294967296, 'ENABLED',
                70368744177664, 'DISABLED', 'DISABLED')
       end,
       -- INMEMORY_PRIORITY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       case when (bitand(tsp.flags, 65536) = 65536) then
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
                        null),
                  null)
       end,
       -- INMEMORY_COMPRESSION
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       case when (bitand(tsp.flags, 65536) = 65536) then
        decode(bitand(ds.flags_stg, 2097152), 2097152,
               decode(bitand(ds.imcflag_stg, (8192+16384)),
                              8192,   'NO DUPLICATE',
                              16384,  'DUPLICATE',
                              24576,  'DUPLICATE ALL',
                              null),
                null)
       else
          decode(bitand(s.spare1, 4294967296), 4294967296,
                   decode(bitand(s.spare1, 6597069766656),
                           2199023255552, 'NO DUPLICATE',
                           4398046511104, 'DUPLICATE',
                           6597069766656, 'DUPLICATE ALL', null),
                null)
       end,
       -- INMEMORY_SERVICE
       case when (bitand(tsp.flags, 65536) = 65536) then
         decode(bitand(ds.flags_stg, 2097152), 2097152,
                decode(bitand(ds.imcflag_stg, 32768), 32768,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                null)
       else
         decode(bitand(s.spare1, 4294967296), 4294967296,
                decode(bitand(s.spare1, 9007199254740992), 9007199254740992,
                       decode(bitand(svc.svcflags, 7),
                              0, null,
                              1, 'DEFAULT',
                              2, 'NONE',
                              3, 'ALL',
                              4, 'USER_DEFINED', 'DEFAULT'), 'DEFAULT'),
                 null)
       end,
       -- INMEMORY_SERVICE_NAME
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- CELLMEMORY
       case when (bitand(tsp.flags, 65536) = 65536) then
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
       -- MEMOPTIMIZE_READ -> KKPACFRAGF_IMOLTP_KV
       decode(bitand(tsp.flags, power(2,30)), power(2,30),
                                'ENABLED', 'DISABLED'),
       -- MEMOPTIMIZE_WRITE -> KKPACFRAGF_IMOLTP_INGEST
       decode(bitand(tsp.flags, power(2,31)), power(2,31),
                                'ENABLED', 'DISABLED')
from   sys.obj$ so, sys.obj$ po, tabcompart$ tcp, sys.tabsubpart$ tsp, 
       sys.tab$ t, sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.deferred_stg$ ds,
       sys.imsvc$ svc
where  so.obj# = tsp.obj# and po.obj# = tsp.pobj# and tcp.obj# = tsp.pobj# and
       tcp.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       tsp.ts# = ts.ts# and u.user# = po.owner# and tsp.obj# = ds.obj#(+) and
       tsp.file# = s.file#(+) and tsp.block# = s.block#(+) and
       bitand(tcp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(tsp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       tsp.ts# = s.ts#(+)
       and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 1 and so.remoteowner IS NULL and so.linkname IS NULL
       and tsp.obj# = svc.obj# (+) and svc.subpart#(+) is null
/
create or replace public synonym DBA_TAB_SUBPARTITIONS
   for DBA_TAB_SUBPARTITIONS
/
grant select on DBA_TAB_SUBPARTITIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TAB_SUBPARTITIONS','CDB_TAB_SUBPARTITIONS');
grant select on SYS.CDB_TAB_SUBPARTITIONS to select_catalog_role
/
create or replace public synonym CDB_TAB_SUBPARTITIONS for SYS.CDB_TAB_SUBPARTITIONS
/

remark
remark  FAMILY "IND_SUBPARTITIONS"
remark   This family of views will describe, for each index subpartition,
remark   the subpartition level information, the storage parameters for the
remark   subpartition, and various subpartition statistics determined by
remark   ANALYZE.
remark   pctused, freelists, freelist groups are null for bitmap segments
remark
create or replace view USER_IND_SUBPARTITIONS
  (INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, GLOBAL_STATS, INTERVAL, SEGMENT_CREATED,
   DOMIDX_OPSTATUS, PARAMETERS)
as
select po.name, po.subname, so.subname, isp.hiboundval, isp.hiboundlen,
       dense_rank() over (partition by po.name order by icp.part#),
       row_number() over (partition by po.name,po.subname order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
       decode(bitand(isp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(isp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(isp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(isp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(isp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       case
         when bitand(isp.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(isp.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,      
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),        
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(isp.flags, 65536), 65536, 'NO', 'YES'), '', ''
from   sys.obj$ so, sys.obj$ po, sys.indsubpart$ isp, sys.indcompart$ icp,
       sys.ts$ ts, sys.seg$ s, sys.ind$ i, sys.tab$ t, sys.deferred_stg$ ds
where  so.obj# = isp.obj# and i.type# != 9 and /* not domain index */
       po.obj# = icp.obj# and icp.obj# = isp.pobj# and 
       isp.ts# = ts.ts# and
       isp.file# = s.file#(+) and isp.block# = s.block#(+) and 
       isp.ts# = s.ts#(+) and isp.obj# = ds.obj#(+) and
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID') and
       i.obj# = icp.bo# and i.bo# = t.obj# and
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL
union all
select po.name, po.subname, so.subname, isp.hiboundval, isp.hiboundlen, 
       dense_rank() over (partition by po.name order by icp.part#),
       row_number() over (partition by po.name,po.subname order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(isp.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null,  
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       'N/A',
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime, 
        'DEFAULT', 'DEFAULT', 'DEFAULT',     
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       'N/A', 
       decode(i.type#,
              9, decode(bitand(isp.flags, 8192), 8192, 'FAILED', 'VALID'),
              ''),
       ipp.parameters
from   sys.obj$ so, sys.obj$ po, sys.indsubpart$ isp, sys.indcompart$ icp,
       sys.ind$ i, sys.tab$ t, sys.indpart_param$ ipp
where  so.obj# = isp.obj# and 
       icp.obj# = isp.pobj# and i.obj# = icp.bo# and i.bo# = t.obj# and
       po.obj# = icp.obj# and icp.obj# = ipp.obj# and so.obj# = isp.obj# and  
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID') and
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL
/
create or replace public synonym USER_IND_SUBPARTITIONS
   for USER_IND_SUBPARTITIONS
/
grant read on USER_IND_SUBPARTITIONS to PUBLIC with grant option
/

create or replace view ALL_IND_SUBPARTITIONS
  (INDEX_OWNER, INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, GLOBAL_STATS, INTERVAL, SEGMENT_CREATED,
   DOMIDX_OPSTATUS, PARAMETERS)
as
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen, 
       dense_rank() over (partition by u.name, po.name order by icp.part#),
       row_number() over (partition by u.name, po.name, po.subname 
                          order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
       decode(bitand(isp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(isp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(isp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(isp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(isp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       case
         when bitand(isp.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(isp.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),               
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(isp.flags, 65536), 65536, 'NO', 'YES'), '', ''
from   obj$ so, sys.obj$ po, ind$ i, indcompart$ icp, indsubpart$ isp, 
       ts$ ts, seg$ s, user$ u, tab$ t, sys.deferred_stg$ ds
where  so.obj# = isp.obj# and i.type# != 9 and /* not domain index */
       po.obj# = icp.obj# and icp.obj# = isp.pobj# and
       i.obj# = icp.bo# and ts.ts# = isp.ts# and isp.file# = s.file#(+) and
       isp.block# = s.block#(+) and isp.ts# = s.ts#(+) and 
       isp.obj# = ds.obj#(+) and u.user# = po.owner# and
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       i.type# != 8 and      /* not LOB index */
       po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL and
       so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL and
       ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or i.bo# in
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen,
       dense_rank() over (partition by u.name, po.name order by icp.part#), 
       row_number() over (partition by u.name, po.name, po.subname 
                          order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(isp.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       'N/A',
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
        'DEFAULT', 'DEFAULT', 'DEFAULT',     
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       'N/A',
       decode(i.type#,
              9, decode(bitand(isp.flags, 8192), 8192, 'FAILED', 'VALID'),
              ''),
       ipp.parameters
from   obj$ so, sys.obj$ po, ind$ i, indcompart$ icp, indsubpart$ isp, 
       user$ u, tab$ t, sys.indpart_param$ ipp
where  so.obj# = isp.obj# and icp.obj# = ipp.obj# and
       po.obj# = icp.obj# and icp.obj# = isp.pobj# and
       i.obj# = icp.bo# and 
       u.user# = po.owner# and
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       i.bo# = t.obj# and bitand(t.trigflag, 1073741824) != 1073741824 and
       i.type# != 8 and      /* not LOB index */
       po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL and
       so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL and
       ((po.owner# = userenv('SCHEMAID') and so.owner# = userenv('SCHEMAID'))
        or i.bo# in
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
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/
create or replace public synonym ALL_IND_SUBPARTITIONS
   for ALL_IND_SUBPARTITIONS
/
grant read on ALL_IND_SUBPARTITIONS to PUBLIC with grant option
/

create or replace view DBA_IND_SUBPARTITIONS
  (INDEX_OWNER, INDEX_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   HIGH_VALUE, HIGH_VALUE_LENGTH, PARTITION_POSITION, SUBPARTITION_POSITION,
   STATUS, TABLESPACE_NAME, PCT_FREE, 
   INI_TRANS, MAX_TRANS, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENT, 
   MAX_EXTENT, MAX_SIZE,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS, LOGGING, COMPRESSION, BLEVEL, 
   LEAF_BLOCKS, 
   DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, 
   CLUSTERING_FACTOR, NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED, 
   BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   USER_STATS, GLOBAL_STATS, INTERVAL, SEGMENT_CREATED,
   DOMIDX_OPSTATUS, PARAMETERS)
as
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen, 
       dense_rank() over (partition by u.name, po.name order by icp.part#),
       row_number() over (partition by u.name, po.name, po.subname 
                          order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 'USABLE'), ts.name,  
       isp.pctfree$, isp.initrans, isp.maxtrans,
       decode(bitand(isp.flags, 65536), 65536, 
              ds.initial_stg * ts.blocksize, s.iniexts * ts.blocksize), 
       decode(bitand(isp.flags, 65536), 65536,
              ds.next_stg * ts.blocksize, s.extsize * ts.blocksize),
       decode(bitand(isp.flags, 65536), 65536, ds.minext_stg, s.minexts), 
       decode(bitand(isp.flags, 65536), 65536, ds.maxext_stg, s.maxexts),
       decode(bitand(isp.flags, 65536), 65536, 
              ds.maxsiz_stg * ts.blocksize, 
              decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL)),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     ds.pctinc_stg, s.extpct)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536, 
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(bitand(isp.flags, 65536), 65536,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       case
         when bitand(isp.flags, 1024) = 1024 then 'ENABLED'
       else
         case when (bitand(isp.flags, 65536) = 65536) then
           decode(bitand(ds.flags_stg, 4), 4, 
                  decode(bitand(ds.cmpflag_stg, 6),
                         4, 'ADVANCED LOW',
                         2, 'ADVANCED HIGH',
                         NULL),
                  'DISABLED')
         else
           decode(bitand(s.spare1, 2048), 2048,
                  decode(bitand(s.spare1, 16777216 + 1048576),
                         16777216, 'ADVANCED HIGH',
                         1048576, 'ADVANCED LOW',
                         NULL),
                  'DISABLED')
         end
       end,
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(isp.flags, 65536), 65536, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),          
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       decode(bitand(isp.flags, 65536), 65536, 'NO', 'YES'), '', ''
from   sys.obj$ so, sys.obj$ po, sys.indcompart$ icp, sys.indsubpart$ isp, 
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.ind$ i, sys.tab$ t, 
       sys.deferred_stg$ ds
where  so.obj# = isp.obj# and i.type# != 9 and /* not domain index */
       po.obj# = icp.obj# and
       icp.obj# = isp.pobj# and isp.ts# = ts.ts# and u.user# = po.owner# and 
       isp.file# = s.file#(+) and isp.block# = s.block#(+) and 
       isp.ts# = s.ts#(+) and isp.obj# = ds.obj#(+) and
       icp.bo# = i.obj# and i.bo# = t.obj# and 
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL
union all
select u.name, po.name, po.subname, so.subname, 
       isp.hiboundval, isp.hiboundlen,
       dense_rank() over (partition by u.name, po.name order by icp.part#), 
       row_number() over (partition by u.name, po.name, po.subname 
                          order by isp.subpart#),
       decode(bitand(isp.flags, 1), 1, 'UNUSABLE', 
               decode(bitand(isp.flags, 4096), 4096, 'INPROGRS', 'USABLE')), 
       null,
       icp.defpctfree, icp.definitrans, icp.defmaxtrans,
       icp.definiexts, icp.defextsize, icp.defminexts, icp.defmaxexts, 
       icp.defmaxsize, icp.defextpct, icp.deflists, icp.defgroups,
       decode(mod(trunc(isp.flags / 4), 2), 0, 'YES', 'NO'),
       'N/A',
       isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
       isp.clufac, isp.rowcnt, isp.samplesize, isp.analyzetime,
        'DEFAULT', 'DEFAULT', 'DEFAULT',     
       decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
       decode(bitand(isp.flags, 32768), 32768, 'YES', 'NO'),
       'N/A',
       decode(i.type#,
              9, decode(bitand(isp.flags, 8192), 8192, 'FAILED', 'VALID'),
              ''),
       ipp.parameters
from   sys.obj$ so, sys.obj$ po, sys.indcompart$ icp, sys.indsubpart$ isp, 
       sys.user$ u, sys.ind$ i, sys.tab$ t, 
       sys.indpart_param$ ipp
where  so.obj# = isp.obj# and icp.obj# = ipp.obj# and
       po.obj# = icp.obj# and
       icp.obj# = isp.pobj# and u.user# = po.owner# and 
       icp.bo# = i.obj# and i.bo# = t.obj# and 
       bitand(icp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(isp.flags, 8388608) = 0 and   /* filter out hidden partitions */
       bitand(t.trigflag, 1073741824) != 1073741824
       and po.namespace = 4 and po.remoteowner IS NULL and po.linkname IS NULL
       and so.namespace = 4 and so.remoteowner IS NULL and so.linkname IS NULL
/
create or replace public synonym DBA_IND_SUBPARTITIONS
   for DBA_IND_SUBPARTITIONS
/
grant select on DBA_IND_SUBPARTITIONS to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_IND_SUBPARTITIONS','CDB_IND_SUBPARTITIONS');
grant select on SYS.CDB_IND_SUBPARTITIONS to select_catalog_role
/
create or replace public synonym CDB_IND_SUBPARTITIONS for SYS.CDB_IND_SUBPARTITIONS
/

remark
remark  FAMILY "SUBPART_KEY_COLUMNS"
remark   This family of views will describe the subpartitioning key columns for
remark   all Range Composite (R+H) partitioned objects.
remark
remark   using an UNION rather than an OR for speed.
alter view user_subpart_key_columns_v$ compile;

create or replace view USER_SUBPART_KEY_COLUMNS
as select
  NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from user_subpart_key_columns_v$
/
create or replace public synonym USER_SUBPART_KEY_COLUMNS
   for USER_SUBPART_KEY_COLUMNS
/
grant read on USER_SUBPART_KEY_COLUMNS to PUBLIC with grant option
/

alter view all_subpart_key_columns_v$ compile;

create or replace view ALL_SUBPART_KEY_COLUMNS
as select
  OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from all_subpart_key_columns_v$
/
create or replace public synonym ALL_SUBPART_KEY_COLUMNS
   for ALL_SUBPART_KEY_COLUMNS
/
grant read on ALL_SUBPART_KEY_COLUMNS to PUBLIC with grant option
/

alter view dba_subpart_key_columns_v$ compile;

execute CDBView.create_cdbview(false,'SYS','DBA_SUBPART_KEY_COLUMNS_V$','CDB_SUBPART_KEY_COLUMNS_V$');

create or replace view DBA_SUBPART_KEY_COLUMNS
as select
  OWNER, NAME, OBJECT_TYPE, COLUMN_NAME, COLUMN_POSITION, COLLATED_COLUMN_ID
from dba_subpart_key_columns_v$
/
create or replace public synonym DBA_SUBPART_KEY_COLUMNS
   for DBA_SUBPART_KEY_COLUMNS
/
grant select on DBA_SUBPART_KEY_COLUMNS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SUBPART_KEY_COLUMNS','CDB_SUBPART_KEY_COLUMNS');
grant select on SYS.CDB_SUBPART_KEY_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_SUBPART_KEY_COLUMNS for SYS.CDB_SUBPART_KEY_COLUMNS
/

remark
remark  FAMILY "PART_LOBS"
remark   This family of views will describe the object level information
remark   for LOB columns contained in partitioned tables.
remark
create or replace view USER_PART_LOBS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS,
   DEF_MAX_SIZE, DEF_RETENTION, DEF_MINRET,
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL, DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_ENCRYPT, DEF_COMPRESS,
   DEF_DEDUPLICATE, DEF_SECUREFILE)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(plob.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defmaxsize, NULL, 'DEFAULT', plob.defmaxsize),
       decode(bitand(plob.defpro, 2048), 2048,
               decode(plob.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(plob.defflags, 32),
                      32, 'YES', 'NO')),
       decode(plob.defmintime,  NULL, 'DEFAULT', plob.defmintime),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',  
                                        16, 'NO', 256, 'NO', 512, 'YES', 
                                        'UNKNOWN'), 
       decode(bitand(plob.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defflags,4096), 4096, 'YES',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE', 
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro,2048), 2048, 'YES', 'NO')
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, sys.attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL  
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.subname IS NULL and lo.owner# = userenv('SCHEMAID')
/ 
create or replace public synonym USER_PART_LOBS for USER_PART_LOBS 
/
grant read on USER_PART_LOBS to PUBLIC with grant option
/
create or replace view ALL_PART_LOBS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, 
   DEF_MAX_SIZE, DEF_RETENTION, DEF_MINRET,
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL, DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_ENCRYPT, DEF_COMPRESS, 
   DEF_DEDUPLICATE, DEF_SECUREFILE)
as 
select u.name, 
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),       
       decode(plob.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defmaxsize, NULL, 'DEFAULT', plob.defmaxsize),
       decode(bitand(plob.defpro, 2048), 2048,
               decode(plob.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(plob.defflags, 32),
                      32, 'YES', 'NO')),
       decode(plob.defmintime,  NULL, 'DEFAULT', plob.defmintime),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',  
                                        16, 'NO', 256, 'NO', 512, 'YES', 'UNKNOWN'),
       decode(bitand(plob.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defflags,4096), 4096, 'YES',
                     decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro,2048), 2048, 'YES', 'NO')
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, sys.user$ u, sys.attrcol$ a
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL and lo.subname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL 
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
/ 
create or replace public synonym ALL_PART_LOBS for ALL_PART_LOBS 
/
grant read on ALL_PART_LOBS to PUBLIC with grant option
/
create or replace view DBA_PART_LOBS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_INDEX_NAME, DEF_CHUNK,
   DEF_PCTVERSION, DEF_CACHE, DEF_IN_ROW,
   DEF_TABLESPACE_NAME, DEF_INITIAL_EXTENT, DEF_NEXT_EXTENT, DEF_MIN_EXTENTS, 
   DEF_MAX_EXTENTS, 
   DEF_MAX_SIZE, DEF_RETENTION, DEF_MINRET,
   DEF_PCT_INCREASE, DEF_FREELISTS, DEF_FREELIST_GROUPS,
   DEF_LOGGING, DEF_BUFFER_POOL, DEF_FLASH_CACHE, DEF_CELL_FLASH_CACHE,
   DEF_ENCRYPT, DEF_COMPRESS,
   DEF_DEDUPLICATE, DEF_SECUREFILE)
as 
select u.name, 
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name, 
       io.name,
       plob.defchunk,
       plob.defpctver$,
       decode(bitand(plob.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(plob.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(plob.definiexts, NULL, 'DEFAULT', plob.definiexts),
       decode(plob.defextsize, NULL, 'DEFAULT', plob.defextsize),
       decode(plob.defminexts, NULL, 'DEFAULT', plob.defminexts),
       decode(plob.defmaxexts, NULL, 'DEFAULT', plob.defmaxexts),
       decode(plob.defmaxsize, NULL, 'DEFAULT', plob.defmaxsize),
       decode(bitand(plob.defpro, 2048), 2048,
               decode(plob.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(plob.defflags, 32),
                      32, 'YES', 'NO')),
       decode(plob.defmintime,  NULL, 'DEFAULT', plob.defmintime),
       decode(plob.defextpct,  NULL, 'DEFAULT', plob.defextpct),
       decode(plob.deflists,   NULL, 'DEFAULT', plob.deflists),
       decode(plob.defgroups,  NULL, 'DEFAULT', plob.defgroups),
       decode(bitand(plob.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',  
                                        16, 'NO', 256, 'NO', 512, 'YES', 
                                        'UNKNOWN'), 
       decode(bitand(plob.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(plob.defflags,4096), 4096, 'YES',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(plob.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(plob.defpro,2048), 2048, 'YES', 'NO')
from   sys.obj$ o, sys.col$ c, sys.lob$ l, sys.partlob$ plob, 
       sys.obj$ lo, sys.obj$ io, sys.ts$ ts, sys.user$ u, sys.attrcol$ a
where o.owner# = u.user#
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.ind# = io.obj#
  and l.lobj# = plob.lobj#
  and plob.defts# = ts.ts# (+)
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL and lo.subname IS NULL 
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_PART_LOBS for DBA_PART_LOBS
/
grant select on DBA_PART_LOBS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_PART_LOBS','CDB_PART_LOBS');
grant select on SYS.CDB_PART_LOBS to select_catalog_role
/
create or replace public synonym CDB_PART_LOBS for SYS.CDB_PART_LOBS
/

remark
remark  FAMILY "LOB_PARTITIONS"
remark   This family of views will describe partitions of LOB columns 
remark   belonging to partitioned tables
remark
create or replace view USER_LOB_PARTITIONS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by o.name, lo.name order by lf.frag#),
       'NO',
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                                   0, 'NONE', 1, 'AUTO',
                                                   2, 'MIN',  3, 'MAX',
                                                   4, 'DEFAULT', 'INVALID'), 
                             decode(bitand(lf.fragflags, 32), 32, 'YES',
                                                              'NO')),
                      decode(bitand(s.spare1, 2097152), 2097152,
                             decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                             2, 'MIN', 3, 'MAX',
                                             4, 'DEFAULT', 'INVALID'),
                             decode(bitand(lf.fragflags, 32), 32, 'YES',
                                                                  'NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2, 'NO', 16, 'NO', 256, 'NO', 512, 'YES', 'YES'), 
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),       
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro, 2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfrag$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.attrcol$ a, 
       sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.owner# = userenv('SCHEMAID')
union all
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by o.name, lo.name order by lcp.part#),
       'YES',
       lcp.defchunk,
       decode(bitand(lcp.defflags, 32), 0, lcp.defpctver$, to_number(NULL)),
       decode(bitand(lcp.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lcp.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defmaxsize, NULL, 'DEFAULT', lcp.defmaxsize),
       decode(bitand(lcp.defpro, 2048), 2048,
               decode(lcp.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(lcp.defflags, 32),
                      32, 'YES', 'NO')),
       decode(lcp.defmintime, NULL, 'DEFAULT', lcp.defmintime),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                  16, 'NO', 256, 'NO', 512, 'YES', 'UNKNOWN'),
       decode(bitand(lcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defflags,4096), 4096, 'YES',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defpro,2048), 2048, 'YES', 'NO'), 'N/A'
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, sys.partobj$ pobj, sys.tab$ t, sys.attrcol$ a
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and lo.owner# = userenv('SCHEMAID')
/ 
create or replace public synonym USER_LOB_PARTITIONS for USER_LOB_PARTITIONS 
/
grant read on USER_LOB_PARTITIONS to PUBLIC with grant option
/
create or replace view ALL_LOB_PARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION, 
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by u.name, o.name,lo.name order by lf.frag#),
       'NO',
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                                   0, 'NONE', 1, 'AUTO',
                                                   2, 'MIN',  3, 'MAX',
                                                   4, 'DEFAULT', 'INVALID'), 
                             decode(bitand(lf.fragflags, 32), 32, 'YES',
                                                            'NO')),
                      decode(bitand(s.spare1, 2097152), 2097152,
                             decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                             2, 'MIN', 3, 'MAX',
                                             4, 'DEFAULT', 'INVALID'),
                             decode(bitand(lf.fragflags, 32), 32, 'YES',
                                                            'NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2,'NO', 16, 'NO', 256, 'NO', 512,
                                           'YES', 'YES'), 
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro,2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfrag$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.attrcol$ a,
       sys.deferred_stg$ ds
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.ts# = ts.ts#
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL 
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
union all
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by u.name, o.name,lo.name order by lcp.part#),
       'YES',
       lcp.defchunk,
       decode(bitand(lcp.defflags, 32), 0, lcp.defpctver$, to_number(NULL)),
       decode(bitand(lcp.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lcp.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defmaxsize, NULL, 'DEFAULT', lcp.defmaxsize),
       decode(bitand(lcp.defpro, 2048), 2048,
               decode(lcp.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(lcp.defflags, 32), 32, 'YES', 'NO')),
       decode(lcp.defmintime, NULL, 'DEFAULT', lcp.defmintime),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                  16, 'NO', 256, 'NO', 512, 'YES', 'UNKNOWN'),
       decode(bitand(lcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defflags,4096), 4096, 'YES',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defpro,2048), 2048, 'YES', 'NO'), 'N/A'
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, partobj$ pobj, sys.tab$ t, sys.user$ u, sys.attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
/ 
create or replace public synonym ALL_LOB_PARTITIONS for ALL_LOB_PARTITIONS 
/
grant read on ALL_LOB_PARTITIONS to PUBLIC with grant option
/
create or replace view DBA_LOB_PARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, 
   PARTITION_NAME, LOB_PARTITION_NAME, LOB_INDPART_NAME, PARTITION_POSITION, 
   COMPOSITE, CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE, RETENTION, MINRETENTION,
   PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by u.name,o.name, lo.name order by lf.frag#),
       'NO',
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             decode(ds.lobret_stg, to_number(NULL), 'DEFAULT',
                                                   0, 'NONE', 1, 'AUTO',
                                                   2, 'MIN',  3, 'MAX',
                                                   4, 'DEFAULT', 'INVALID'), 
                             decode(bitand(lf.fragflags, 32), 32, 'YES', 'NO')),
                      decode(bitand(s.spare1, 2097152), 2097152,
                             decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                             2, 'MIN', 3, 'MAX',
                                             4, 'DEFAULT', 'INVALID'),
                             decode(bitand(lf.fragflags, 32), 32, 'YES',
                                                             'NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2, 'NO', 16, 'NO', 256, 'NO',
                                         512, 'YES', 'YES'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM',
              32768, 'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT',
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro,2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobfrag$ lf, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.attrcol$ a,
       sys.deferred_stg$ ds
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) = 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lf.parentobj#
  and lf.tabfragobj# = po.obj#
  and lf.fragobj# = lpo.obj#
  and lf.indfragobj# = lipo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.ts# = ts.ts#
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
union all
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       po.subname,
       lpo.subname,
       lipo.subname,
       row_number() over (partition by u.name, o.name,lo.name order by lcp.part#),
       'YES',
       lcp.defchunk,
       decode(bitand(lcp.defflags, 32), 0, lcp.defpctver$, to_number(NULL)),
       decode(bitand(lcp.defflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lcp.defpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       decode(lcp.definiexts, NULL, 'DEFAULT', lcp.definiexts),
       decode(lcp.defextsize, NULL, 'DEFAULT', lcp.defextsize),
       decode(lcp.defminexts, NULL, 'DEFAULT', lcp.defminexts),
       decode(lcp.defmaxexts, NULL, 'DEFAULT', lcp.defmaxexts),
       decode(lcp.defmaxsize, NULL, 'DEFAULT', lcp.defmaxsize),
       decode(bitand(lcp.defpro, 2048), 2048,
               decode(lcp.defretention,
                      to_number(NULL), 'DEFAULT',
                      0, 'NONE',
                      1, 'AUTO',
                      2, 'MIN',
                      3, 'MAX',
                      4, 'DEFAULT',
                      'INVALID'),
               decode(bitand(lcp.defflags, 32),
                      32, 'YES', 'NO')),
       decode(lcp.defmintime, NULL, 'DEFAULT', lcp.defmintime),
       decode(lcp.defextpct,  NULL, 'DEFAULT', lcp.defextpct),
       decode(lcp.deflists,   NULL, 'DEFAULT', lcp.deflists),
       decode(lcp.defgroups,  NULL, 'DEFAULT', lcp.defgroups),
       decode(bitand(lcp.defflags, 790), 0,'NONE', 4,'YES', 2,'NO',
                                  16, 'NO', 256, 'NO', 512, 'YES', 'UNKNOWN'),
       decode(bitand(lcp.defbufpool, 3), 1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 12)/4, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defbufpool, 48)/16, 1, 'KEEP', 2, 'NONE', 'DEFAULT'),
       decode(bitand(lcp.defflags,4096), 4096, 'YES',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lcp.defpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lcp.defpro,2048), 2048, 'YES', 'NO'), 'N/A'
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo, 
       sys.obj$ po, sys.obj$ lipo, 
       sys.ts$ ts, sys.partobj$ pobj, sys.tab$ t, sys.user$ u, attrcol$ a
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.tabpartobj# = po.obj#
  and lcp.partobj# = lpo.obj#
  and lcp.indpartobj# = lipo.obj#
  and lcp.defts# = ts.ts# (+)
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_LOB_PARTITIONS for DBA_LOB_PARTITIONS
/
grant select on DBA_LOB_PARTITIONS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOB_PARTITIONS','CDB_LOB_PARTITIONS');
grant select on SYS.CDB_LOB_PARTITIONS to select_catalog_role
/
create or replace public synonym CDB_LOB_PARTITIONS for SYS.CDB_LOB_PARTITIONS
/

remark
remark  FAMILY "LOB_SUBPARTITIONS"
remark   This family of views will describe subpartitions of LOB columns 
remark   belonging to partitioned tables
remark
create or replace view USER_LOB_SUBPARTITIONS 
  (TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE,
   RETENTION, MINRETENTION, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       row_number() over (partition by o.name, lo.name, lpo.subname 
                          order by lf.frag#),
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(bitand(lf.fragpro, 2048),
                            2048, decode(ds.lobret_stg,
                                         to_number(NULL), 'DEFAULT',
                                         0, 'NONE', 1, 'AUTO',
                                         2, 'MIN',  3, 'MAX',
                                         4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32, 'YES', 'NO')),
                     decode(bitand(s.spare1, 2097152), 2097152,
                            decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32, 'YES','NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2, 'NO', 16, 'NO', 256, 'NO',
                                         512, 'YES', 'YES'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro,2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo,
       sys.lobfrag$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.attrcol$ a,
       sys.deferred_stg$ ds
where o.owner# = userenv('SCHEMAID')
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym USER_LOB_SUBPARTITIONS
   for USER_LOB_SUBPARTITIONS 
/
grant read on USER_LOB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view ALL_LOB_SUBPARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE,
   RETENTION, MINRETENTION, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       row_number() over (partition by u.name, o.name, lo.name, lpo.subname 
                          order by lf.frag#),
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(bitand(lf.fragpro, 2048),
                            2048, decode(ds.lobret_stg,
                                         to_number(NULL), 'DEFAULT',
                                         0, 'NONE', 1, 'AUTO',
                                         2, 'MIN',  3, 'MAX',
                                         4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32,'YES', 'NO')),
                     decode(bitand(s.spare1, 2097152), 2097152,
                            decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32,'YES', 'NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2, 'NO', 16, 'NO', 256, 'NO',
                                         512, 'YES', 'YES'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro,2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo,
       sys.lobfrag$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.attrcol$ a,
       sys.deferred_stg$ ds
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
  and ((o.owner# = userenv('SCHEMAID') and lo.owner# = userenv('SCHEMAID'))
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
      )
/ 
create or replace public synonym ALL_LOB_SUBPARTITIONS
   for ALL_LOB_SUBPARTITIONS 
/
grant read on ALL_LOB_SUBPARTITIONS to PUBLIC with grant option
/
create or replace view DBA_LOB_SUBPARTITIONS 
  (TABLE_OWNER, TABLE_NAME, COLUMN_NAME, LOB_NAME, LOB_PARTITION_NAME, 
   SUBPARTITION_NAME, LOB_SUBPARTITION_NAME, LOB_INDSUBPART_NAME, 
   SUBPARTITION_POSITION, 
   CHUNK, PCTVERSION, CACHE, IN_ROW,
   TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, 
   MAX_EXTENTS, MAX_SIZE,
   RETENTION, MINRETENTION, PCT_INCREASE, FREELISTS, FREELIST_GROUPS,
   LOGGING, BUFFER_POOL, FLASH_CACHE, CELL_FLASH_CACHE, 
   ENCRYPT, COMPRESSION, DEDUPLICATION, SECUREFILE, SEGMENT_CREATED)
as 
select u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       lo.name,
       lpo.subname,
       spo.subname,
       lspo.subname,
       lispo.subname,
       row_number() over (partition by u.name, o.name, lo.name, lpo.subname 
                          order by lf.frag#),
       lf.chunk * ts.blocksize,
       decode(bitand(lf.fragflags, 32), 0, lf.pctversion$, to_number(NULL)),
       decode(bitand(lf.fragflags, 795), 1, 'NO', 2, 'NO', 8, 'CACHEREADS',
                                         16, 'CACHEREADS', 256, 'YES', 512, 
                                         'YES', 'YES'),
       decode(lf.fragpro, 0, 'NO', 2048, 'NO', 'YES'),
       ts.name,
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.initial_stg, s.iniexts) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.next_stg, s.extsize) * ts.blocksize), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.minext_stg, s.minexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432, 
                      ds.maxext_stg, s.maxexts)), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      ds.maxsiz_stg * ts.blocksize, 
                      decode(bitand(s.spare1, 4194304), 4194304, 
                             bitmapranges, NULL))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(bitand(lf.fragpro, 2048),
                            2048, decode(ds.lobret_stg,
                                         to_number(NULL), 'DEFAULT',
                                         0, 'NONE', 1, 'AUTO',
                                         2, 'MIN',  3, 'MAX',
                                         4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32,'YES', 'NO')),
                     decode(bitand(s.spare1, 2097152), 2097152,
                            decode(s.lists, 0, 'NONE', 1, 'AUTO', 
                                            2, 'MIN', 3, 'MAX',
                                            4, 'DEFAULT', 'INVALID'), 
                            decode(bitand(lf.fragflags, 32), 32,'YES', 'NO')))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                      decode(bitand(lf.fragpro, 2048), 2048,
                             ds.mintim_stg, NULL),
                      decode(bitand(s.spare1, 2097152), 2097152, 
                             s.groups, NULL))),
       to_char(decode(bitand(ts.flags, 3), 1, to_number(NULL),
                     decode(bitand(lf.fragflags, 33554432), 33554432, 
                           ds.pctinc_stg, s.extpct))),
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.frlins_stg, 0, 1, ds.frlins_stg),
                     decode(s.lists, 0, 1, s.lists))), 
       to_char(decode(bitand(lf.fragflags, 33554432), 33554432,
                     decode(ds.maxins_stg, 0, 1, ds.maxins_stg),
                     decode(s.groups, 0, 1, s.groups))),
       decode(bitand(lf.fragflags, 786), 2, 'NO', 16, 'NO', 256, 'NO',
                                         512, 'YES', 'YES'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 3), 
              1, 'KEEP', 2, 'RECYCLE', 'DEFAULT'),
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 12)/4, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),              
       decode(bitand(decode(bitand(lf.fragflags, 33554432), 33554432, ds.bfp_stg, s.cachehint), 48)/16, 
              1, 'KEEP', 2, 'NONE', 'DEFAULT'),       
       decode(bitand(lf.fragflags,4096), 4096, 'YES',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,57344), 8192, 'LOW', 16384, 'MEDIUM', 32768,
              'HIGH',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragflags,458752), 65536, 'LOB', 131072, 'OBJECT', 
              327680, 'LOB VALIDATE', 393216, 'OBJECT VALIDATE',
              decode(bitand(lf.fragpro,2048), 2048, 'NO', 'NONE')),
       decode(bitand(lf.fragpro,2048), 2048, 'YES', 'NO'),
       decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES')
from   sys.obj$ o, sys.col$ c, 
       sys.lob$ l, sys.obj$ lo, 
       sys.lobcomppart$ lcp, sys.obj$ lpo,
       sys.lobfrag$ lf, sys.obj$ lspo, 
       sys.obj$ spo, sys.obj$ lispo, 
       sys.partobj$ pobj, sys.tab$ t,
       sys.ts$ ts, sys.seg$ s, sys.user$ u, sys.attrcol$ a,
       sys.deferred_stg$ ds
where o.owner# = u.user#
  and pobj.obj# = o.obj#
  and o.obj# = t.obj#
  and bitand(t.trigflag, 1073741824) != 1073741824
  and mod(pobj.spare2, 256) != 0
  and o.obj# = c.obj#
  and c.obj# = l.obj#
  and c.intcol# = l.intcol#
  and l.lobj# = lo.obj#
  and l.lobj# = lcp.lobj#
  and lcp.partobj# = lpo.obj#
  and bitand(lcp.defflags, 67108864) = 0    /* filter out hidden fragments */
  and bitand(lf.fragflags, 67108864) = 0    /* filter out hidden fragments */
  and lf.parentobj# = lcp.partobj#
  and lf.tabfragobj# = spo.obj#
  and lf.fragobj# = lspo.obj#
  and lf.indfragobj# = lispo.obj#
  and lf.fragobj# = ds.obj#(+)
  and lf.ts# = s.ts#(+)
  and lf.file# = s.file#(+)
  and lf.block# = s.block#(+)
  and lf.ts# = ts.ts#
  and bitand(c.property,32768) != 32768           /* not unused column */
  and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and lo.namespace = 8 and lo.remoteowner IS NULL and lo.linkname IS NULL
/ 
create or replace public synonym DBA_LOB_SUBPARTITIONS
   for DBA_LOB_SUBPARTITIONS
/
grant select on DBA_LOB_SUBPARTITIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_LOB_SUBPARTITIONS','CDB_LOB_SUBPARTITIONS');
grant select on SYS.CDB_LOB_SUBPARTITIONS to select_catalog_role
/
create or replace public synonym CDB_LOB_SUBPARTITIONS for SYS.CDB_LOB_SUBPARTITIONS
/

remark Views for template descriptions
create or replace view USER_SUBPARTITION_TEMPLATES 
  (TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, TABLESPACE_NAME, 
  HIGH_BOUND, COMPRESSION, INDEXING, READ_ONLY)
as 
select o.name, st.spart_name, st.spart_position + 1, ts.name, st.hiboundval,
       decode(bitand(st.flags, 3), 2, 'NO', 1, 'YES', 'NONE'),
       decode(bitand(st.flags, 192), 128, 'OFF', 64, 'ON', 'NONE'),
       decode(bitand(st.flags, 402653184), 268435456, 'NO', 
              134217728, 'YES', 'NONE')
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL
/
create or replace public synonym USER_SUBPARTITION_TEMPLATES for 
       USER_SUBPARTITION_TEMPLATES
/
grant read on USER_SUBPARTITION_TEMPLATES to PUBLIC with grant option
/
create or replace view DBA_SUBPARTITION_TEMPLATES 
  (USER_NAME, TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, 
  TABLESPACE_NAME, HIGH_BOUND, COMPRESSION, INDEXING, READ_ONLY)
as 
select u.name, o.name, st.spart_name, st.spart_position + 1, ts.name, 
       st.hiboundval,
       decode(bitand(st.flags, 3), 2, 'NO', 1, 'YES', 'NONE'),
       decode(bitand(st.flags, 192), 128, 'OFF', 64, 'ON', 'NONE'),
       decode(bitand(st.flags, 402653184), 268435456, 'NO', 
              134217728, 'YES', 'NONE')
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts, sys.user$ u
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and o.subname IS NULL
/
create or replace public synonym DBA_SUBPARTITION_TEMPLATES for 
       DBA_SUBPARTITION_TEMPLATES
/
grant select on DBA_SUBPARTITION_TEMPLATES to  select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_SUBPARTITION_TEMPLATES','CDB_SUBPARTITION_TEMPLATES');
grant select on SYS.CDB_SUBPARTITION_TEMPLATES to select_catalog_role
/
create or replace public synonym CDB_SUBPARTITION_TEMPLATES for SYS.CDB_SUBPARTITION_TEMPLATES
/

create or replace view ALL_SUBPARTITION_TEMPLATES 
  (USER_NAME, TABLE_NAME, SUBPARTITION_NAME, SUBPARTITION_POSITION, 
  TABLESPACE_NAME, HIGH_BOUND, COMPRESSION, INDEXING, READ_ONLY)
as 
select u.name, o.name, st.spart_name, st.spart_position + 1, ts.name, 
       st.hiboundval,
       decode(bitand(st.flags, 3), 2, 'NO', 1, 'YES', 'NONE'),
       decode(bitand(st.flags, 192), 128, 'OFF', 64, 'ON', 'NONE'),
       decode(bitand(st.flags, 402653184), 268435456, 'NO', 
       134217728, 'YES', 'NONE')
from sys.obj$ o, sys.defsubpart$ st, sys.ts$ ts, sys.user$ u
where st.bo# = o.obj# and st.ts# = ts.ts#(+) and o.owner# = u.user# and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID') or
       o.obj# in (select oa.obj# from sys.objauth$ oa 
                  where grantee# in ( select kzsrorol from x$kzsro )) or
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -397/* READ ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))
/
create or replace public synonym ALL_SUBPARTITION_TEMPLATES for 
       ALL_SUBPARTITION_TEMPLATES
/
grant read on ALL_SUBPARTITION_TEMPLATES to PUBLIC with grant option
/
create or replace view USER_LOB_TEMPLATES
  (TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and o.owner# = userenv('SCHEMAID') and
      o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      lst.intcol# = ac.intcol#(+) and lst.bo# = ac.obj#(+)
/
create or replace public synonym USER_LOB_TEMPLATES for USER_LOB_TEMPLATES
/
grant read on USER_LOB_TEMPLATES to PUBLIC with grant option
/
create or replace view DBA_LOB_TEMPLATES
  (USER_NAME, TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select u.name, o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac, sys.user$ u
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and lst.intcol# = ac.intcol#(+) and 
      lst.bo# = ac.obj#(+) and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      o.owner# = u.user# and o.subname IS NULL
/
create or replace public synonym DBA_LOB_TEMPLATES for DBA_LOB_TEMPLATES
/
grant select on DBA_LOB_TEMPLATES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOB_TEMPLATES','CDB_LOB_TEMPLATES');
grant select on SYS.CDB_LOB_TEMPLATES to select_catalog_role
/
create or replace public synonym CDB_LOB_TEMPLATES for SYS.CDB_LOB_TEMPLATES
/

create or replace view ALL_LOB_TEMPLATES
  (USER_NAME, TABLE_NAME, LOB_COL_NAME, SUBPARTITION_NAME, LOB_SEGMENT_NAME, 
  TABLESPACE_NAME)
as
select u.name, o.name, decode(bitand(c.property, 1), 1, ac.name, c.name), 
       st.spart_name, lst.lob_spart_name, ts.name
from sys.obj$ o, sys.defsubpart$ st, sys.defsubpartlob$ lst, sys.ts$ ts, 
     sys.col$ c, sys.attrcol$ ac, sys.user$ u
where o.obj# = lst.bo# and st.bo# = lst.bo# and 
      st.spart_position =  lst.spart_position and 
      lst.lob_spart_ts# = ts.ts#(+) and c.obj# = lst.bo# and 
      c.intcol# = lst.intcol# and lst.intcol# = ac.intcol#(+) and 
      lst.bo# = ac.obj#(+) and o.owner# = u.user# and o.subname IS NULL and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID') or
       o.obj# in (select oa.obj# from sys.objauth$ oa 
                  where grantee# in ( select kzsrorol from x$kzsro )) or
       exists (select null from v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -397/* READ ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)))
/
create or replace public synonym ALL_LOB_TEMPLATES for ALL_LOB_TEMPLATES
/
grant read on ALL_LOB_TEMPLATES to PUBLIC with grant option
/

/* bug 14621938: add INDEX_ORPHANED_ENTRY_V$ as a public view over
 * index_orphaned_entry$ for use by the invoker's rights DBMS_PART package.
 */
create or replace view INDEX_ORPHANED_ENTRY_V$
  (INDEX_OWNER, INDEX_NAME, INDEX_SUBNAME, INDEX_OBJECT_ID, 
   TABLE_OWNER, TABLE_NAME, TABLE_SUBNAME, TABLE_OBJECT_ID, TYPE)
as 
select iu.name, iobj.name, iobj.subname, iobj.obj#,
       tu.name, tobj.name, tobj.subname, tobj.obj#, ioe.hidden
from user$ iu, obj$ iobj, index_orphaned_entry$ ioe,
     user$ tu, obj$ tobj
where iu.user# = iobj.owner# and iobj.obj# = ioe.indexobj#
  and tu.user# = tobj.owner#
  and ((iobj.type# = 1   /* index */
        and tobj.obj# = (select i.bo# from ind$ i where i.obj# = iobj.obj#))
      or
       (iobj.type# = 20  /* index partition */
        and tobj.obj# = (select i.bo# from ind$ i, indpart$ ip
                           where ip.obj# = iobj.obj# and ip.bo# = i.obj#))
      )
  and (iobj.owner# = userenv('SCHEMAID') 
       or
       exists (select null from v$enabledprivs
                 where priv_number in (-72 /* ALTER ANY INDEX */))
      )
/

grant read on INDEX_ORPHANED_ENTRY_V$ to public
/

@?/rdbms/admin/sqlsessend.sql
