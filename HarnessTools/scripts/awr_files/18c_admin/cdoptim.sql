Rem
Rem cdoptim.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdoptim.sql - Catalog DOPTIM.bsq views
Rem
Rem    DESCRIPTION
Rem      statistic objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in doptim.bsq. 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdoptim.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdoptim.sql
Rem SQL_PHASE: CDOPTIM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuyzhang    05/16-17 - #(25372534): move the view *_tab_col_statistics
Rem                           to catost.sql
Rem    cwidodo     12/19/16 - #(23068526) : change query in
Rem                           *_expression_statistics
Rem    cwidodo     01/11/17 - #(22895315): move *_expression_statistics to
Rem                           catost.sql
Rem    rafsanto    07/06/16 - Bug 23316402: Indextypes sys privs
Rem    jiayan      07/30/15 - #20663978: fix mon_mods_v definition
Rem    ddas        06/17/15 - proj 47170: persistent IMC statistics
Rem    jiayan      06/01/15 - proj 47047 - add expression usage tracking views
Rem    sudurai     04/09/15 - proj 49581 - optimizer stats encryption
Rem    schakkap    03/14/15 - proj 46828: support for scan rate
Rem    schakkap    03/10/15 - proj 46828: add mon_mods_v
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    gravipat    11/06/13 - 17709056: remove duplicate CDB_OPTSTAT_OPERATIONS
Rem                           creation
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    amelidis    06/06/13 - 14595152: add HIST_FOR_INCREM_STATS to NOTES
Rem                           column in DBA/ALL/USER_[SUB]PART_COL_STATISTICS
Rem    hosu        01/03/13 - 15840654: fix gtt stats in dba_tab_col_statistics 
Rem    hosu        01/03/13 - 15840654: fix gtt stats in dba_tab_col_statistics
Rem    hosu        09/12/12 - 14228225: add more contents to "notes"
Rem    hosu        07/31/12 - 14395801: add notes to stats view
Rem    acakmak     07/26/12 - create cdb views for dba_optstat_operations and
Rem                           dba_optstat_operation_tasks
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    acakmak     02/07/12 - Project 41376: Move family of "COL_PENDING_STATS"
Rem                           views to catost.sql
Rem    acakmak     12/15/11 - Check identifying flags for (top-)freq histograms
Rem    acakmak     10/17/11 - Add extra checks for top-freq histogram type in
Rem                           column stats views
Rem    acakmak     08/29/11 - Project 31794: New histogram types
Rem    hosu        09/26/11 - rename session private stats table
Rem    hosu        08/11/11 - project 31794: support GTT session private stats -
                              add SCOPE column to stats views
Rem    ptearle     04/06/10 - 8354888: create public synonym for
Rem                           DBA_TAB_MODIFICATIONS
Rem    ruparame    03/15/10 - Bug 9192924 Add SYS_OP_DV_CHECK to sensitive columns
Rem    hosu        12/27/07 - 6684794: use staleness defined in table 
Rem                           preference (move these views to catost.sql)
Rem    yzhu        04/12/07 - #(5958445) set partition stale status based on 
Rem                           last_analyzed time of that partition
Rem    mzait       02/08/07 - replace private by pending
Rem    mzait       12/14/06 - Allow cluster indexes to show in private
Rem                           statistics
Rem    schakkap    09/27/06 - TAB_COL_STATISTICS now shows hidden column stats
Rem    schakkap    09/20/06 - move catost.sql contents
Rem                           move statistics views from cdpart.sql
Rem    yhu         05/26/06 - Add MAINTENANCE_TYPE in *_ASSOCIATIONS 
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
Rem 
Rem  Family "SUBPART_COL_STATISTICS"
Rem   These views contain column statistics and histogram information
Rem   for table subpartitions.
Rem
create or replace view TSP$ as
select tsp.obj#, tcp.bo#, c.intcol#, c.type#,
      decode(bitand(c.property, 1), 1, a.name, c.name) cname, tsp.rowcnt
      from sys.col$ c, sys.tabsubpart$ tsp, sys.tabcompart$ tcp, attrcol$ a 
      where tsp.pobj# = tcp.obj# and tcp.bo# = c.obj#
      and bitand(c.property,32768) != 32768    /* not unused columns */
      and c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+)
/
grant select on TSP$ to select_catalog_role
/

create or replace view USER_SUBPART_COL_STATISTICS 
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tsp.cname, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end, 
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', ''),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tsp$ tsp
where o.obj# = tsp.obj#
  and tsp.obj# = h.obj#(+) and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_COL_STATISTICS
   for USER_SUBPART_COL_STATISTICS 
/
grant read on USER_SUBPART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then  h.hival
            else null
       end, 
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end,
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', ''),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end 
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or tsp.bo# in
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
create or replace public synonym ALL_SUBPART_COL_STATISTICS
   for ALL_SUBPART_COL_STATISTICS 
/
grant read on ALL_SUBPART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_SUBPART_COL_STATISTICS 
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tsp.cname, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then  h.hival
            else null
       end, 
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt
            when bitand(h.spare2, 64) > 0
              then h.row_cnt
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end,
       h.sample_size, h.timestamp#,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       decode(bitand(h.spare2, 8), 8, 'INCREMENTAL ', '') ||
         decode(bitand(h.spare2, 128), 128, 'HIST_FOR_INCREM_STATS ', '') ||
         decode(bitand(h.spare2, 256), 256, 'HISTOGRAM_ONLY ', '') ||
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', ''),
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tsp.obj# = hg.obj# and tsp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end 
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tsp$ tsp, user$ u
where o.obj# = tsp.obj# and tsp.obj# = h.obj#(+)
  and tsp.intcol# = h.intcol#(+)
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_COL_STATISTICS
   for DBA_SUBPART_COL_STATISTICS
/
grant select on DBA_SUBPART_COL_STATISTICS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SUBPART_COL_STATISTICS','CDB_SUBPART_COL_STATISTICS');
grant select on SYS.CDB_SUBPART_COL_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_SUBPART_COL_STATISTICS for SYS.CDB_SUBPART_COL_STATISTICS
/

Rem
Rem  Family "ASSOCIATIONS"
Rem  Info on user defined statistics associations
Rem
create or replace view DBA_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#, 
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
/
create or replace public synonym DBA_ASSOCIATIONS for DBA_ASSOCIATIONS
/
grant select on DBA_ASSOCIATIONS to select_catalog_role
/
Comment on table DBA_ASSOCIATIONS is
'All associations'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column DBA_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column DBA_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column DBA_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column DBA_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/
Comment on column DBA_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/


execute CDBView.create_cdbview(false,'SYS','DBA_ASSOCIATIONS','CDB_ASSOCIATIONS');
grant select on SYS.CDB_ASSOCIATIONS to select_catalog_role
/
create or replace public synonym CDB_ASSOCIATIONS for SYS.CDB_ASSOCIATIONS
/

create or replace view USER_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#,
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_ASSOCIATIONS for USER_ASSOCIATIONS
/
grant read on USER_ASSOCIATIONS to public with grant option
/
Comment on table USER_ASSOCIATIONS is
'All assocations defined by the user'
/
Comment on column USER_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column USER_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - table, type, package or function'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column USER_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column USER_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column USER_ASSOCIATIONS.INTERFACE_VERSION is
'Interface number of Statistics type interface implemented'
/
Comment on column USER_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/

create or replace view ALL_ASSOCIATIONS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, OBJECT_TYPE, STATSTYPE_SCHEMA,
   STATSTYPE_NAME, DEF_SELECTIVITY, DEF_CPU_COST, DEF_IO_COST, DEF_NET_COST,
   INTERFACE_VERSION, MAINTENANCE_TYPE )
as
  select u.name, o.name, c.name,
         decode(a.property, 1, 'COLUMN', 2, 'TYPE', 3, 'PACKAGE', 4,
                'FUNCTION', 5, 'INDEX', 6, 'INDEXTYPE', 'INVALID'),
         u1.name, o1.name,a.default_selectivity,
         a.default_cpu_cost, a.default_io_cost, a.default_net_cost,
         a.interface_version#,
         decode (bitand(a.spare2, 1), 1, 'SYSTEM_MANAGED', 'USER_MANAGED')
   from  sys.association$ a, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
         sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u1, sys.col$ c
   where a.obj#=o.obj# and o.owner#=u.user#
   AND   a.statstype#=o1.obj# (+) and o1.owner#=u1.user# (+)
   AND   a.obj# = c.obj#  (+)  and a.intcol# = c.intcol# (+)
   and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
       or
       ( o.type# in (8, 9)   /* package or function */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-140 /* CREATE PROCEDURE */,
                                        -141 /* CREATE ANY PROCEDURE */,
                                        -142 /* ALTER ANY PROCEDURE */,
                                        -143 /* DROP ANY PROCEDURE */,
                                        -144 /* EXECUTE ANY PROCEDURE */)
                 )
       )
       or
       ( o.type# in (13)     /* type */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-180 /* CREATE TYPE */,
                                        -181 /* CREATE ANY TYPE */,
                                        -182 /* ALTER ANY TYPE */,
                                        -183 /* DROP ANY TYPE */,
                                        -184 /* EXECUTE ANY TYPE */)
                 )
       )
       or
       ( o.type# in (1)     /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
       or
       ( o.type# in (32)     /* indextype */
         and
         exists (select null from v$enabledprivs
                  where priv_number =-212 /* EXECUTE ANY INDEXTYPE */
                )
       )
    )
/
create or replace public synonym ALL_ASSOCIATIONS for ALL_ASSOCIATIONS
/
grant read on ALL_ASSOCIATIONS to PUBLIC with grant option
/
Comment on table ALL_ASSOCIATIONS is
'All associations available to the user'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_OWNER is
'Owner of the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_NAME is
'Object name for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.COLUMN_NAME is
'Column name in the object for which the association is being defined'
/
Comment on column ALL_ASSOCIATIONS.OBJECT_TYPE is
'Schema type of the object - column, type, package or function'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_SCHEMA is
'Owner of the statistics type'
/
Comment on column ALL_ASSOCIATIONS.STATSTYPE_NAME is
'Name of Statistics type which contains the cost, selectivity or stats funcs'
/
Comment on column ALL_ASSOCIATIONS.DEF_SELECTIVITY is
'Default Selectivity if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_CPU_COST is
'Default CPU cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_IO_COST is
'Default I/O cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.DEF_NET_COST is
'Default Networking cost if any of the object'
/
Comment on column ALL_ASSOCIATIONS.INTERFACE_VERSION is
'Version number of Statistics type interface implemented'
/
Comment on column ALL_ASSOCIATIONS.MAINTENANCE_TYPE is
'Whether it is system managed or user managed'
/

Rem
Rem Family "USTATS"
Rem User defined statistics
Rem
create or replace view DBA_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
/
create or replace public synonym DBA_USTATS for DBA_USTATS
/
grant select on DBA_USTATS to select_catalog_role
/
Comment on table DBA_USTATS is
'All statistics collected on either tables or indexes'
/
Comment on column DBA_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column DBA_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column DBA_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column DBA_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column DBA_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column DBA_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column DBA_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column DBA_USTATS.STATISTICS is
'User collected statistics for the object'
/


execute CDBView.create_cdbview(false,'SYS','DBA_USTATS','CDB_USTATS');
grant select on SYS.CDB_USTATS to select_catalog_role
/
create or replace public synonym CDB_USTATS for SYS.CDB_USTATS
/

create or replace view USER_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    o.owner#=userenv('SCHEMAID')
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#  and o.owner#=userenv('SCHEMAID')
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    o.owner#= userenv('SCHEMAID')
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    o.owner#=userenv('SCHEMAID')
/
create or replace public synonym USER_USTATS for USER_USTATS
/
grant read on USER_USTATS to public with grant option
/
Comment on table USER_USTATS is
'All statistics on tables or indexes owned by the user'
/
Comment on column USER_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column USER_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column USER_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column USER_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column USER_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column USER_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column USER_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column USER_USTATS.STATISTICS is
'User collected statistics for the object'
/

create or replace view ALL_USTATS
  (OBJECT_OWNER, OBJECT_NAME, PARTITION_NAME, OBJECT_TYPE, ASSOCIATION,
   COLUMN_NAME, STATSTYPE_SCHEMA, STATSTYPE_NAME, STATISTICS)
as
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=2 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.intcol#=c.intcol# and s.statstype#=o1.obj#
  and    o1.owner#=u1.user# and c.obj#=s.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all    -- partition case
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         c.name, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1, sys.col$ c,
         sys.ustats$ s, sys.tabpart$ t, sys.obj$ o2
  where  bitand(s.property, 3)=2 and s.obj# = o.obj#
  and    s.obj# = t.obj# and t.bo# = o2.obj# and o2.owner# = u.user#
  and    s.intcol# = c.intcol# and s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    t.bo#=c.obj#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (2)  /* table */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */,
                                        -42 /* ALTER ANY TABLE */)
                 )
       )
    )
union all
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
          NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.obj$ o, sys.ustats$ s,
         sys.user$ u1, sys.obj$ o1
  where  bitand(s.property, 3)=1 and s.obj#=o.obj# and o.owner#=u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user# and o.type#=1
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
union all -- index partition
  select u.name, o.name, o.subname,
         decode (bitand(s.property, 3), 1, 'INDEX', 2, 'COLUMN'),
         decode (bitand(s.property, 12), 8, 'DIRECT', 4, 'IMPLICIT'),
         NULL, u1.name, o1.name, s.statistics
  from   sys.user$ u, sys.user$ u1, sys.obj$ o, sys.obj$ o1,
         sys.ustats$ s, sys.indpart$ i, sys.obj$ o2
  where  bitand(s.property, 3)=1 and s.obj# = o.obj#
  and    s.obj# = i.obj# and i.bo# = o2.obj# and o2.owner# = u.user#
  and    s.statstype#=o1.obj# and o1.owner#=u1.user#
  and    ( o.owner#=userenv('SCHEMAID')
           or
        o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or
       ( o.type# in (1)  /* index */
         and
         exists (select null from v$enabledprivs
                  where priv_number in (-71 /* CREATE ANY INDEX */,
                                        -72 /* ALTER ANY INDEX */,
                                        -73 /* DROP ANY INDEX */)
                 )
       )
    )
/
create or replace public synonym ALL_USTATS for ALL_USTATS
/
grant read on ALL_USTATS to public with grant option
/
Comment on table ALL_USTATS is
'All statistics'
/
Comment on column ALL_USTATS.OBJECT_OWNER is
'Owner of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.OBJECT_NAME is
'Name of the table or index for which the statistics have been collected'
/
Comment on column ALL_USTATS.PARTITION_NAME is
'Name of the partition (if applicable) for which the stats have been collected'
/
Comment on column ALL_USTATS.OBJECT_TYPE is
'Type of the object - Column or Index'
/
Comment on column ALL_USTATS.ASSOCIATION is
'If the statistics type association is direct or implicit'
/
Comment on column ALL_USTATS.COLUMN_NAME is
'Column name, if property is column for which statistics have been collected'
/
Comment on column ALL_USTATS.STATSTYPE_SCHEMA is
'Schema of statistics type which was used to collect the statistics '
/
Comment on column ALL_USTATS.STATSTYPE_NAME is
'Name of statistics type which was used to collect statistics'
/
Comment on column ALL_USTATS.STATISTICS is
'User collected statistics for the object'
/

Rem
Rem Family "TAB_MODIFICATIONS"
Rem
Rem These views provide information about the amount and type of
Rem modifications made to rows in a table.
Rem

-- The following view gives the aggregate information of DML modifications
-- from mon_mods_all$ and x$ksxmme (maps to ksxm SGA table). This view
-- is used in *TAB_MODIFICATIONS view and *[TAB/IND]_STATISTICS views to
-- get current DML modifications.
-- KSXMF_RESET_MODS (512) is set when info from mon_mods_all$ is in 
-- ksxm hash table element. So do not get value from mon_mods_all$
-- in this case.
--
create or replace view mon_mods_v
  (obj#, inserts, updates, deletes, timestamp, flags, drop_segments)
as 
select 
  nvl(m.obj#, x.objn),
  decode(bitand(m.flags, 512), 512, 0, nvl(m.inserts, 0)) + nvl(x.ins, 0), 
  decode(bitand(m.flags, 512), 512, 0, nvl(m.updates, 0)) + nvl(x.upd, 0), 
  decode(bitand(m.flags, 512), 512, 0, nvl(m.deletes, 0)) + nvl(x.del, 0), 
  m.timestamp,
  case when m.flags is null or bitand(m.flags, 512) = 512 then x.flags
       else m.flags +  -- at this point m.flags is not null
            case when bitand(m.flags, 1) = 0 and bitand(x.flags, 1) = 1 then 1
                 else 0 -- if x.flags is null, we add 0
            end
  end,
  decode(bitand(m.flags, 512), 512, 0, nvl(m.drop_segments, 0)) + 
    nvl(x.dropseg, 0)
from sys.mon_mods_all$ m full outer join
     (select objn, sum(ins) ins, sum(upd) upd, sum(del) del, 
      max(bitand(flags, 1)) flags, sum(dropseg) dropseg 
      from sys.gv$dml_stats group by objn) x
on m.obj# = x.objn
/

grant select on mon_mods_v to select_catalog_role
/

create or replace view USER_TAB_MODIFICATIONS
(TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS, UPDATES,
 DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tab$ t
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.obj# = t.obj#
union all
  select o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
  from sys.mon_mods_v m, sys.obj$ o
  where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and o.type#=19
union all
select o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2
where o.owner# = userenv('SCHEMAID') and o.obj# = m.obj# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table USER_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column USER_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column USER_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column USER_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column USER_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column USER_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column USER_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column USER_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym USER_TAB_MODIFICATIONS for USER_TAB_MODIFICATIONS
/
grant read on USER_TAB_MODIFICATIONS to PUBLIC with grant option
/

create or replace view ALL_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -397/* READ ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -397/* READ ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
      and (o.owner# = userenv('SCHEMAID')
           or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in (select kzsrorol from x$kzsro))
           or /* user has system privileges */
             exists (select null from v$enabledprivs
                       where priv_number in (-45 /* LOCK ANY TABLE */,
                                             -47 /* SELECT ANY TABLE */,
                                             -397/* READ ANY TABLE */,
                                             -48 /* INSERT ANY TABLE */,
                                             -49 /* UPDATE ANY TABLE */,
                                             -50 /* DELETE ANY TABLE */,
                                             -165/* ANALYZE ANY */))
          )
/
comment on table ALL_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column ALL_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column ALL_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column ALL_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column ALL_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column ALL_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column ALL_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column ALL_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym ALL_TAB_MODIFICATIONS for ALL_TAB_MODIFICATIONS
/
grant read on ALL_TAB_MODIFICATIONS to PUBLIC with grant option
/

create or replace view DBA_TAB_MODIFICATIONS
(TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, INSERTS,
 UPDATES, DELETES, TIMESTAMP, TRUNCATED, DROP_SEGMENTS)
as
select u.name, o.name, null, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tab$ t, sys.user$ u
where o.obj# = m.obj# and o.obj# = t.obj# and o.owner# = u.user#
union all
select u.name, o.name, o.subname, null,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.user$ u
where o.owner# = u.user# and o.obj# = m.obj# and o.type#=19
union all
select u.name, o.name, o2.subname, o.subname,
       m.inserts, m.updates, m.deletes, m.timestamp,
       decode(bitand(m.flags,1),1,'YES','NO'),
       m.drop_segments
from sys.mon_mods_v m, sys.obj$ o, sys.tabsubpart$ tsp, sys.obj$ o2,
     sys.user$ u
where o.obj# = m.obj# and o.owner# = u.user# and
      o.obj# = tsp.obj# and o2.obj# = tsp.pobj#
/
comment on table DBA_TAB_MODIFICATIONS is
'Information regarding modifications to tables'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_OWNER is
'Owner of modified table'
/
comment on column DBA_TAB_MODIFICATIONS.TABLE_NAME is
'Modified table'
/
comment on column DBA_TAB_MODIFICATIONS.PARTITION_NAME is
'Modified partition'
/
comment on column DBA_TAB_MODIFICATIONS.SUBPARTITION_NAME is
'Modified subpartition'
/
comment on column DBA_TAB_MODIFICATIONS.INSERTS is
'Approximate number of rows inserted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.UPDATES is
'Approximate number of rows updated since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.DELETES is
'Approximate number of rows deleted since last analyze'
/
comment on column DBA_TAB_MODIFICATIONS.TIMESTAMP is
'Timestamp of last time this row was modified'
/
comment on column DBA_TAB_MODIFICATIONS.TRUNCATED is
'Was this object truncated since the last analyze?'
/
comment on column DBA_TAB_MODIFICATIONS.DROP_SEGMENTS is
'Number of (sub)partition segment dropped since the last analyze?'
/
create or replace public synonym DBA_TAB_MODIFICATIONS for DBA_TAB_MODIFICATIONS
/
grant select on DBA_TAB_MODIFICATIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_MODIFICATIONS','CDB_TAB_MODIFICATIONS');
grant select on SYS.CDB_TAB_MODIFICATIONS to select_catalog_role
/
create or replace public synonym CDB_TAB_MODIFICATIONS for SYS.CDB_TAB_MODIFICATIONS
/

Rem
Rem OPTSTAT_OPERATIONS
Rem This view contains history of statistics operations performed
Rem using dbms_stats package.
Rem
create or replace view DBA_OPTSTAT_OPERATIONS
  (ID, OPERATION, TARGET, START_TIME, END_TIME, STATUS, 
   JOB_NAME, SESSION_ID, NOTES) as 
  select id, operation, target, start_time, end_time, 
         case status when 0 then 'PENDING'
                     when 1 then 'IN PROGRESS'
                     when 2 then 'COMPLETED'
                     when 3 then 'FAILED'
                     when 4 then 'SKIPPED'
                     when 5 then 'TIMED OUT'
              else 'UNKNOWN: ' || status end status, 
         job_name, session_id, notes
  from sys.wri$_optstat_opr
/
create or replace public synonym DBA_OPTSTAT_OPERATIONS for 
DBA_OPTSTAT_OPERATIONS
/
grant select on DBA_OPTSTAT_OPERATIONS to select_catalog_role
/
comment on table DBA_OPTSTAT_OPERATIONS is
'History of statistics operations performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.ID is
'Internal identifier for the operation'
/
comment on column DBA_OPTSTAT_OPERATIONS.OPERATION is
'Operation name'
/
comment on column DBA_OPTSTAT_OPERATIONS.TARGET is
'Target on which operation performed'
/
comment on column DBA_OPTSTAT_OPERATIONS.START_TIME is
'Start time of operation'
/
comment on column DBA_OPTSTAT_OPERATIONS.END_TIME is
'End time of operation'
/
comment on column DBA_OPTSTAT_OPERATIONS.STATUS is
'Operation completion status'
/
comment on column DBA_OPTSTAT_OPERATIONS.JOB_NAME is
'Name of the scheduler job in which the operation runs'
/
comment on column DBA_OPTSTAT_OPERATIONS.SESSION_ID is
'Id of the session in which the operation runs'
/
comment on column DBA_OPTSTAT_OPERATIONS.NOTES is
'Additional notes about the operation'
/

Rem
Rem Create the corresponding cdb view cdb_optstat_operations
Rem
execute CDBView.create_cdbview(false,'SYS','DBA_OPTSTAT_OPERATIONS','CDB_OPTSTAT_OPERATIONS');
grant select on SYS.CDB_OPTSTAT_OPERATIONS to select_catalog_role
/
create or replace public synonym CDB_OPTSTAT_OPERATIONS for SYS.CDB_OPTSTAT_OPERATIONS
/

Rem
Rem OPTSTAT_OPERATION_TASKS
Rem This view contains history of tasks that are performed
Rem as part of statistics gathering operations. Each
Rem task represents a target object to be processed in
Rem the parent operation.
Rem
create or replace view DBA_OPTSTAT_OPERATION_TASKS
  (OPID, TARGET, TARGET_OBJN, TARGET_TYPE, TARGET_SIZE, 
   START_TIME, END_TIME, STATUS, JOB_NAME, ESTIMATED_COST, 
   BATCHING_COEFF, ACTIONS, PRIORITY, FLAGS, NOTES) as 
  select op_id, target, target_objn, 
         case target_type when 1 then 'TABLE'
                          when 2 then 'TABLE (GLOBAL STATS ONLY)'
                          when 3 then 'TABLE (COORDINATOR JOB)'
                          when 4 then 'TABLE PARTITION'
                          when 5 then 'TABLE SUBPARTITION'
                          when 6 then 'INDEX'
                          when 7 then 'INDEX PARTITION'
                          when 8 then 'INDEX SUBPARTITION'
                          else to_char(target_type) end target_type, 
         target_size, start_time, end_time, 
         case status when 0 then 'PENDING'
                     when 1 then 'IN PROGRESS'
                     when 2 then 'COMPLETED'
                     when 3 then 'FAILED'
                     when 4 then 'SKIPPED'
                     when 5 then 'TIMED OUT'
              else 'UNKNOWN: ' || status end status,
         job_name, estimated_cost,
         batching_coeff, actions, priority, flags, notes
  from sys.wri$_optstat_opr_tasks
/
create or replace public synonym DBA_OPTSTAT_OPERATION_TASKS for 
DBA_OPTSTAT_OPERATION_TASKS
/
grant select on DBA_OPTSTAT_OPERATION_TASKS to select_catalog_role
/
comment on table DBA_OPTSTAT_OPERATION_TASKS is
'Tasks that are performed as part of statistics operations'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.OPID is
'Internal identifier for the operation that the task belongs to'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.TARGET is
'Target name in the form of OWNER.TABLE.PART'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.TARGET_OBJN is
'Target object number'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.TARGET_SIZE is
'Target size in terms of the number of blocks'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.TARGET_TYPE is
'Target type (e.g., TABLE, INDEX, etc.)'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.START_TIME is
'Task start time'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.END_TIME is
'Task end time'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.STATUS is
'Task completion status'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.JOB_NAME is
'Name of the scheduler job in which the task runs'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.ESTIMATED_COST is
'Estimated cost of the task'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.BATCHING_COEFF is
'Ratio of the task cost and the internal batching threshold'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.ACTIONS is
'Number of extra subtasks (e.g., histograms) done in this task'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.PRIORITY is
'Rank/priority of the target in its group'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.FLAGS is
'Internal flags for the task'
/
comment on column DBA_OPTSTAT_OPERATION_TASKS.NOTES is
'Additional notes about the task'
/

Rem
Rem Create the corresponding cdb view cdb_optstat_operation_tasks
Rem
execute CDBView.create_cdbview(false,'SYS','DBA_OPTSTAT_OPERATION_TASKS','CDB_OPTSTAT_OPERATION_TASKS');
grant select on SYS.CDB_OPTSTAT_OPERATION_TASKS to select_catalog_role
/
create or replace public synonym CDB_OPTSTAT_OPERATION_TASKS for SYS.CDB_OPTSTAT_OPERATION_TASKS
/

Rem
Rem Family "TAB_STATS_HISTORY"
Rem Views for displaying the statistics update time from history
Rem
create or replace view ALL_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select /*+ rule */ u.name, o.name, null, null, h.savtime
  from sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
    and (o.owner# = userenv('SCHEMAID')
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
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from  sys.user$ u, sys.obj$ o, sys.obj$ ot,
        sys.wri$_optstat_tab_history h
  where h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
        and ot.name = o.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime <= systimestamp  -- exclude pending statistics
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u, sys.obj$ osp, obj$ ocp,  sys.obj$ ot, 
        sys.tabsubpart$ tsp, sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj#
        and tsp.pobj# = ocp.obj# and osp.owner# = u.user#
        and ot.name = ocp.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime <= systimestamp  -- exclude pending statistics
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and  h.savtime <= systimestamp  -- exclude pending statistics
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
/
create or replace public synonym ALL_TAB_STATS_HISTORY for
ALL_TAB_STATS_HISTORY
/
grant read on ALL_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table ALL_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column ALL_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/

create or replace view DBA_TAB_STATS_HISTORY
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select u.name, o.name, null, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.savtime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.user$ u,  sys.obj$ osp, obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
    and tsp.pobj# = ocp.obj# and osp.owner# = u.user#
    and h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- fixed tables
  select 'SYS', t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and h.savtime <= systimestamp  -- exclude pending statistics
/
create or replace public synonym DBA_TAB_STATS_HISTORY for
DBA_TAB_STATS_HISTORY
/
grant select on DBA_TAB_STATS_HISTORY to select_catalog_role
/
comment on table DBA_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column DBA_TAB_STATS_HISTORY.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_STATS_HISTORY','CDB_TAB_STATS_HISTORY');
grant select on SYS.CDB_TAB_STATS_HISTORY to select_catalog_role
/
create or replace public synonym CDB_TAB_STATS_HISTORY for SYS.CDB_TAB_STATS_HISTORY
/

create or replace view USER_TAB_STATS_HISTORY
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, 
   STATS_UPDATE_TIME) as
  -- tables
  select o.name, null, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 
    and  o.owner# = userenv('SCHEMAID')
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- partitions
  select o.name, o.subname, null, h.savtime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 
    and  o.owner# = userenv('SCHEMAID')
    and  h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- sub partitions
  select osp.name, ocp.subname, osp.subname, h.savtime
  from  sys.obj$ osp, sys.obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
    and tsp.pobj# = ocp.obj# and osp.owner# = userenv('SCHEMAID')
    and h.savtime <= systimestamp  -- exclude pending statistics
  union all
  -- fixed tables
  select t.kqftanam, null, null, h.savtime
  from  sys.x$kqfta t, sys.wri$_optstat_tab_history h
  where t.kqftaobj = h.obj#
    and userenv('SCHEMAID') = 0  /* SYS */
    and  h.savtime <= systimestamp  -- exclude pending statistics
/
create or replace public synonym USER_TAB_STATS_HISTORY for
USER_TAB_STATS_HISTORY
/
grant read on USER_TAB_STATS_HISTORY to PUBLIC with grant option
/
comment on table USER_TAB_STATS_HISTORY is
'History of table statistics modifications'
/
comment on column USER_TAB_STATS_HISTORY.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_STATS_HISTORY.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_STATS_HISTORY.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_STATS_HISTORY.STATS_UPDATE_TIME is
'Time of statistics update'
/

Rem
Rem Family "TAB_STAT_PREFS"
Rem Table statistics preferences
Rem
create or replace view ALL_TAB_STAT_PREFS
  (OWNER, TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select u.name, o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o, user$ u
where p.obj#=o.obj#
  and u.user#=o.owner#
  and o.type#=2
  and (o.owner# = userenv('SCHEMAID')
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
create or replace public synonym ALL_TAB_STAT_PREFS for
ALL_TAB_STAT_PREFS
/
grant read on ALL_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table ALL_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column ALL_TAB_STAT_PREFS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column ALL_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/

create or replace view DBA_TAB_STAT_PREFS
  (OWNER, TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select u.name, o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o, user$ u
where p.obj#=o.obj#
  and u.user#=o.owner#
  and o.type#=2
/
create or replace public synonym DBA_TAB_STAT_PREFS for
DBA_TAB_STAT_PREFS
/
grant read on DBA_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table DBA_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column DBA_TAB_STAT_PREFS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column DBA_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_STAT_PREFS','CDB_TAB_STAT_PREFS');
grant read on SYS.CDB_TAB_STAT_PREFS to PUBLIC with grant option 
/
create or replace public synonym CDB_TAB_STAT_PREFS for SYS.CDB_TAB_STAT_PREFS
/

create or replace view USER_TAB_STAT_PREFS
  (TABLE_NAME, PREFERENCE_NAME, PREFERENCE_VALUE)
AS
select o.name, p.pname, p.valchar 
from  sys.optstat_user_prefs$ p, obj$ o
where p.obj#=o.obj#
  and o.type#=2
  and o.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_TAB_STAT_PREFS for
USER_TAB_STAT_PREFS
/
grant read on USER_TAB_STAT_PREFS to PUBLIC with grant option
/
comment on table USER_TAB_STAT_PREFS is
'Statistics preferences for tables'
/
comment on column USER_TAB_STAT_PREFS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_STAT_PREFS.PREFERENCE_NAME is
'Preference name'
/
comment on column USER_TAB_STAT_PREFS.PREFERENCE_VALUE is
'Preference value'
/

Rem
Rem Family "TAB_PENDING_STATS"
Rem Table pending statistics
Rem
create or replace view ALL_TAB_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, IM_IMCU_COUNT, IM_BLOCK_COUNT, SCAN_RATE, SAMPLE_SIZE,
   LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize,
         h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime > systimestamp
    and (o.owner# = userenv('SCHEMAID')
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
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize,
         h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.obj$ ot,
         sys.wri$_optstat_tab_history h
  where h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
        and ot.name = o.name and ot.type# = 2 and ot.owner# = u.user#
        and h.savtime > systimestamp
        and (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate,
         h.samplesize, h.analyzetime
  from  sys.user$ u, sys.obj$ osp, obj$ ocp,  sys.obj$ ot, 
        sys.tabsubpart$ tsp, sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
        and ot.name = ocp.name and ot.type# = 2 and ot.owner# = u.user#
        and  h.savtime > systimestamp
        and  (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
create or replace public synonym ALL_TAB_PENDING_STATS for
ALL_TAB_PENDING_STATS
/
grant read on ALL_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_TAB_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_TAB_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column ALL_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column ALL_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column ALL_TAB_PENDING_STATS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column ALL_TAB_PENDING_STATS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column ALL_TAB_PENDING_STATS.SCAN_RATE is
'Scan rate for the object'
/
comment on column ALL_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column ALL_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view DBA_TAB_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, IM_IMCU_COUNT, IM_BLOCK_COUNT, SCAN_RATE, SAMPLE_SIZE,
   LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize, h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 and o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize,
         h.analyzetime
  from   sys.user$ u, sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 and o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate,
         h.samplesize, h.analyzetime
  from  sys.user$ u,  sys.obj$ osp, obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# and
        tsp.pobj# = ocp.obj# and osp.owner# = u.user#
    and h.savtime > systimestamp
/
create or replace public synonym DBA_TAB_PENDING_STATS for
DBA_TAB_PENDING_STATS
/
grant read on DBA_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_TAB_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_TAB_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column DBA_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column DBA_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column DBA_TAB_PENDING_STATS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column DBA_TAB_PENDING_STATS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column DBA_TAB_PENDING_STATS.SCAN_RATE is
'Scan rate for the object'
/
comment on column DBA_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column DBA_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_PENDING_STATS','CDB_TAB_PENDING_STATS');
grant read on SYS.CDB_TAB_PENDING_STATS to PUBLIC with grant option 
/
create or replace public synonym CDB_TAB_PENDING_STATS for SYS.CDB_TAB_PENDING_STATS
/

create or replace view USER_TAB_PENDING_STATS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, NUM_ROWS, 
   BLOCKS, AVG_ROW_LEN, IM_IMCU_COUNT, IM_BLOCK_COUNT, SCAN_RATE, SAMPLE_SIZE,
   LAST_ANALYZED)
AS
  -- tables
  select o.name, null, null, h.rowcnt, h.blkcnt, h.avgrln, 
         h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize,
         h.analyzetime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 2 
         and o.owner# = userenv('SCHEMAID')
         and h.savtime > systimestamp
  union all
  -- partitions
  select o.name, o.subname, null, h.rowcnt, h.blkcnt, 
         h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate, h.samplesize,
         h.analyzetime
  from   sys.obj$ o, sys.wri$_optstat_tab_history h
  where  h.obj# = o.obj# and o.type# = 19 
         and o.owner# = userenv('SCHEMAID')
         and h.savtime > systimestamp
  union all
  -- sub partitions
  select osp.name, ocp.subname, osp.subname, h.rowcnt, 
         h.blkcnt, h.avgrln, h.im_imcu_count, h.im_block_count, h.scanrate,
         h.samplesize, h.analyzetime
  from  sys.obj$ osp, sys.obj$ ocp,  sys.tabsubpart$ tsp, 
        sys.wri$_optstat_tab_history h
  where h.obj# = osp.obj# and osp.type# = 34 and osp.obj# = tsp.obj# 
        and tsp.pobj# = ocp.obj# 
        and osp.owner# = userenv('SCHEMAID')
        and h.savtime > systimestamp
/
create or replace public synonym USER_TAB_PENDING_STATS for
USER_TAB_PENDING_STATS
/
grant read on USER_TAB_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_TAB_PENDING_STATS is
'History of table statistics modifications'
/
comment on column USER_TAB_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_PENDING_STATS.NUM_ROWS is
'Number of rows'
/
comment on column USER_TAB_PENDING_STATS.BLOCKS is
'Number of blocks'
/
comment on column USER_TAB_PENDING_STATS.AVG_ROW_LEN is
'Average row length'
/
comment on column USER_TAB_PENDING_STATS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column USER_TAB_PENDING_STATS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column USER_TAB_PENDING_STATS.SCAN_RATE is
'Scan rate for the object'
/
comment on column USER_TAB_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column USER_TAB_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

Rem
Rem Family "IND_PENDING_STATS"
Rem Index pending statistics
Rem
create or replace view ALL_IND_PENDING_STATS
  (OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and (o.owner# = userenv('SCHEMAID')
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
  union all
  -- partitions
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and (o.owner# = userenv('SCHEMAID')
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
  union all
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and (o.owner# = userenv('SCHEMAID')
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
  union all
  -- sub partitions
  select ui.name, oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, sys.user$ ui,
         sys.wri$_optstat_ind_history h
  where  ui.user# = oi.owner#
    and  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  (ot.owner# = userenv('SCHEMAID')
        or ot.obj# in
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
create or replace public synonym ALL_IND_PENDING_STATS for
ALL_IND_PENDING_STATS
/
grant read on ALL_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on column ALL_IND_PENDING_STATS.OWNER is
'Index owner name'
/
comment on column ALL_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column ALL_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column ALL_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column ALL_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column ALL_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column ALL_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column ALL_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column ALL_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column ALL_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column ALL_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column ALL_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column ALL_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column ALL_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column ALL_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

create or replace view DBA_IND_PENDING_STATS
  (OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.user$ u,  sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  u.user# = o.owner#   -- user(i) X obj(i)
    and  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select ui.name, oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, sys.user$ ui,
         sys.wri$_optstat_ind_history h
  where  ui.user# = oi.owner#
    and  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
/
create or replace public synonym DBA_IND_PENDING_STATS for
DBA_IND_PENDING_STATS
/
grant read on DBA_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on column DBA_IND_PENDING_STATS.OWNER is
'Index owner name'
/
comment on column DBA_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column DBA_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column DBA_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column DBA_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column DBA_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column DBA_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column DBA_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column DBA_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column DBA_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column DBA_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column DBA_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column DBA_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column DBA_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column DBA_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/


execute CDBView.create_cdbview(false,'SYS','DBA_IND_PENDING_STATS','CDB_IND_PENDING_STATS');
grant read on SYS.CDB_IND_PENDING_STATS to PUBLIC with grant option 
/
create or replace public synonym CDB_IND_PENDING_STATS for SYS.CDB_IND_PENDING_STATS
/

create or replace view USER_IND_PENDING_STATS
  (INDEX_NAME, TABLE_OWNER, TABLE_NAME, PARTITION_NAME, 
   SUBPARTITION_NAME, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS, 
   AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR, 
   NUM_ROWS, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- indexes 
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  o.obj#  = i.obj#     -- obj(i)  X ind
    and  h.obj#  = i.obj#     -- stat    X ind
    and  i.bo#   = ot.obj#    -- ind     X obj(t) 
    and  ut.user# = ot.owner# -- user(t) X obj(t)
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, indpart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, ut.name, ot.name, o.subname, null, 
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey, 
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ o,  sys.ind$ i, indcompart$ ip, 
         sys.user$ ut, sys.obj$ ot, sys.wri$_optstat_ind_history h
  where  ip.bo# = i.obj# 
    and  h.obj# = ip.obj# 
    and  i.bo#  = ot.obj# 
    and  o.obj# = ip.obj#
    and  ut.user# = ot.owner#
    and  o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select oi.name, ut.name, ot.name, os.name, os.subname,
         h.blevel, h.leafcnt, h.distkey, h.lblkkey, h.dblkkey,
         h.clufac, h.rowcnt, h.samplesize, h.analyzetime
  from   sys.obj$ os, sys.indsubpart$ isp, sys.indcompart$ icp,
         sys.user$ ut, sys.obj$ ot, 
         sys.obj$ oi,  sys.ind$ i, 
         sys.wri$_optstat_ind_history h
  where  os.obj#  = isp.obj# 
    and  h.obj#   = isp.obj#
    and  isp.pobj#= icp.obj#
    and  icp.bo#  = i.obj#
    and  oi.obj#  = i.obj#   
    and  i.bo#    = ot.obj#   
    and  ut.user# = ot.owner#
    and  oi.type# = 1
    and  os.type# = 35       
    and  ot.type# = 2        
    and  os.namespace = 4 and os.remoteowner IS NULL and os.linkname IS NULL
    and  i.type# in (1, 2, 3, 4, 6, 7, 8)
    and  bitand(i.flags, 4096) = 0  -- not a fake index
    and  h.savtime > systimestamp
    and  ot.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_IND_PENDING_STATS for
USER_IND_PENDING_STATS
/
grant read on USER_IND_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_IND_PENDING_STATS is
'Pending statistics of indexes, partitions, and subpartitions'
/
comment on column USER_IND_PENDING_STATS.INDEX_NAME is
'Index name'
/
comment on column USER_IND_PENDING_STATS.TABLE_OWNER is
'Table owner name'
/
comment on column USER_IND_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column USER_IND_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column USER_IND_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column USER_IND_PENDING_STATS.BLEVEL is
'Number of levels in the index'
/
comment on column USER_IND_PENDING_STATS.LEAF_BLOCKS is
'Number of leaf blocks in the index'
/
comment on column USER_IND_PENDING_STATS.DISTINCT_KEYS is
'Number of distinct keys in the index'
/
comment on column USER_IND_PENDING_STATS.AVG_LEAF_BLOCKS_PER_KEY is
'Average number of leaf blocks per key'
/
comment on column USER_IND_PENDING_STATS.AVG_DATA_BLOCKS_PER_KEY is
'Average number of data blocks per key'
/
comment on column USER_IND_PENDING_STATS.CLUSTERING_FACTOR is
'Clustering factor'
/
comment on column USER_IND_PENDING_STATS.NUM_ROWS is
'Number of rows in the index'
/
comment on column USER_IND_PENDING_STATS.SAMPLE_SIZE is
'Sample size'
/
comment on column USER_IND_PENDING_STATS.LAST_ANALYZED is
'Time of last analyze'
/

@?/rdbms/admin/sqlsessend.sql
