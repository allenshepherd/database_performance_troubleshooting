Rem
Rem catost.sql
Rem
Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catost.sql - Optimizer Statistics Tables and Views
Rem
Rem    DESCRIPTION
Rem      This file creates Optimizer Statistics tables and views that can not 
Rem      be created while running catalog.sql due to dependency on other objects.
Rem
Rem    NOTES
Rem      This file is run after all basic tables, views and objects required for
Rem      plsql execution are created. So any views/objects that depends on
Rem      these basic objects should be in this file.  For example 
Rem      *_stat_extensions views require a plsql function and hence created in
Rem      this file.
Rem
Rem      The optimizer tables and views are created in the following scripts.
Rem      (They are run in the order below.)
Rem
Rem      1- doptim.bsq
Rem
Rem         Called from sql.bsq during database creation time. sql.bsq contains 
Rem         all scripts used for creating basic dictionary tables for database 
Rem         operation.
Rem
Rem      2- cdoptim.sql
Rem 
Rem         Called from catalog.sql. Catalog.sql contains all scripts for 
Rem         creating basic catalog views.
Rem
Rem      3- catost.sql
Rem
Rem         Called during catproc time. catproc.sql creates all procedures, 
Rem         functions and depended views on these procedures and functions.
Rem         (pretty much everything that can not be done at catalog.sql run) 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catost.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catost.sql
Rem SQL_PHASE: CATOST
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cwidodo     10/24/17 - #(26898247): add SYS_OP_DV_CHECK to
Rem                           SQT_TAB_COL_STATISTICS
Rem    heheliu     09/28/17 - Bug 26803808: remove NO_PARALLEL hint from 
Rem                           *STATISTICS views.
Rem    tianlli     09/05/17 - 25115388: add data link table stats
Rem    cwidodo     07/07/17 - #(25463265): add SQT_TAB_STATISTICS,
Rem                           SQT_TAB_COL_STATISTICS and SQT_CORRECT_BIT
Rem    yuyzhang    06/02/17 - #(25372534): augment the notes column of 
Rem                           *_part/tab_col_statistics with synopsis type
Rem    yuyzhang    04/14/17 - proj #54799: 'UNKNOWN' staleness for
Rem                         - sharded/metadata linked tables
Rem    cwidodo     01/10/17 - #(22895315) : show new 'WINDOW' snapshot for
Rem                           *_expression_statistics
Rem    schakkap    06/30/16 - #(22182203) datapump support across versions
Rem    yuyzhang    05/06/16 - #23191397: correct parameters of 
Rem                           dbms_stats_internal.is_stale
Rem    hosu        03/15/16 - rti 18576172: add bl1 to _user_stat_varray
Rem    karpurus    03/08/16 - Bug 22229301:Adding SQLID and SQLENV 
Rem                           to "_user_stat"
Rem    sudurai     09/17/15 - Bug 21805805: Encrypt NUMBER data type in
Rem                           statistics tables.Changing DBMS_CRYPTO_STATS_INT
Rem                           to DBMS_CRYPTO_INTERNAL
Rem    sudurai     07/30/15 - Bug 21048490: Adding key management for STATS
Rem                           encryption
Rem    sudurai     06/22/15 - Bug 21258745: Moving STATS crypto APIs from
Rem                           DBMS_STATS_INTERNAL -> DBMS_CRYPTO_STATS_INT
Rem    jiayan      06/20/15 - #20906782: support hybrid synopsis format
Rem    ddas        06/17/15 - proj 47170: persistent IMC statistics
Rem    schakkap    03/10/15 - proj 46828: use mon_mods_v
Rem    jiayan      12/01/14 - proj 44162: unify stats staleness checks across
Rem                           all cursors and views
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    sudurai     11/06/14 - proj 49581 - optimizer stats encryption
Rem    jiayan      10/15/14 - Proj 57436: definition changes of "_user_stat" 
Rem                           and wri$_optstat_synopsis_head$
Rem    schakkap    07/15/14 - proj 46828: Add scanrate to tab_stats$
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    schakkap    09/18/13 - #(16579843) get synopses at table level
Rem    schakkap    07/11/13 - #(16988573) get synoses entries efficiently
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    amelidis    06/05/13 - 14595152: QOSP_HIST_IGNORE for hist_head$.spare2
Rem    schakkap    12/13/12 - lrg 8591545: fix stats history union all branch
Rem    acakmak     09/07/12 - Add constraint ep_repeat_count not null in 
Rem                           wri$_optstat_histgrm_history
Rem    hosu        09/06/12 - 14228225: more hist_head$ spare2 flags
Rem    schakkap    08/10/12 - #(14471033) Fix stats history, directive queries
Rem    hosu        04/16/12 - 13844984: remove synopsis# primary key constraint
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    acakmak     01/27/12 - Proj. 41376: Move wri$_optstat_histgrm_history and
Rem                           wri$_optstat_histhead_history here from doptim.bsq
Rem    schakkap    11/07/11 - #(9316756) Add _user_stat view
Rem    hosu        10/10/11 - change synopsis table from range-hash to list-hash
Rem    hosu        09/26/11 - rename session private stats table
Rem    acakmak     09/19/11 - Project 31794: Move histogram views into
Rem                           catost.sql from cdoptim.sql
Rem    hosu        09/08/11 - proj 31794: session private stats for global
Rem                           temporary table - add SCOPE column to stats views
Rem    ptearle     08/13/10 - 9447598: ignore items in the recyclebin
Rem    ptearle     07/22/10 - 9930151: quote names for dbms_stats calls
Rem    sursridh    04/16/10 - Use correct checks for IOTs in
Rem                           user_tab_statistics.
Rem    hosu        04/09/10 - reduce subpartition number in wri$_optstat_synopsis$
Rem    hosu        02/18/10 - move synopsis related tables from doptim.sql here
Rem    schakkap    07/14/08 - #(4921917) show stats lock on partitions
Rem    hosu        12/28/07 - 6684794: move statistics view dependent on dbms_stats 
Rem                           from cdoptim to catost
Rem    schakkap    10/01/06 - move optimizer tables and views to doptim.bsq and
Rem                           cdoptim.sql
Rem    hosu        06/20/06 - support expression clob in WRI$_OPTSTAT_HISTHEAD_
Rem                           HISTORY
Rem    mzait       06/15/06 - Add *_[TAB|IND|COL|HISTGRM]_PRIVATE_STATS 
Rem                           New dictionary views to show private stats 
Rem    mzait       06/13/06 - Add *_TAB_STAT_PREFS
Rem                           New dictionary views to show stats preferences
Rem    mzait       05/04/06 - Add support for statistics preferences 
Rem    hosu        04/17/06 - add new tables for incremental maintenance of 
Rem                           global stats
Rem    schakkap    12/09/03 - set pctfree to 1 for stats history tables 
Rem    schakkap    10/08/03 - support for changing defaults for dbms_stats 
Rem    schakkap    09/24/03 - remove owner column from USER_TAB_STATS_HISTORY 
Rem    schakkap    09/08/03 - *_TAB_STATS_HISTORY 
Rem    schakkap    05/31/03 - change OPTSTAT_SAVSKIP$ to OPTSTAT_HIST_CONTROL$
Rem    aime        04/25/03 - aime_going_to_main
Rem    schakkap    02/08/03 - schakkap_stat_history
Rem    schakkap    01/28/03 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Sql Plan Directive views: Depends on dbms_spd_internal package
Rem and hence it has to wait till package specs are created. Also
Rem the view "_user_stat" depends on SPD views hence it has to be
Rem created before them.
Rem
@@catspd.sql


Rem
Rem  Family "STAT_EXTENSIONS"
Rem  Displays statistics extensions
Rem

Rem The following function returns the extension, given the rowid of
Rem the column in col$. We can not create plsql functions during catalog
Rem time since it depends on ALL_ERRORS created in catproc time. Hence
Rem the function and views depending on the function are created in this
Rem file.
create or replace function get_stats_extension(
  colrowid rowid)  return clob is
  extn     long;
  extnclob clob;
begin

  select 
    c.default$ into extn
  from sys.col$ c
  where c.rowid = colrowid;

  extnclob := extn;

  if (substr(extnclob, 1, 20) = 'SYS_OP_COMBINED_HASH') then
    return substr(extnclob, 21);
  else
    return '(' || extnclob || ')';
  end if;

end get_stats_extension;
/

show  errors;

Rem =========================================================================
Rem BEGIN Synopsis tables
Rem =========================================================================

Rem Synopsis tables are partitioned. They would fail to be created
Rem in doptim.bsq. Parititoning features requrires querying data 
Rem dictionary tables that are created later than doptim.bsq.

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

Rem Table to store mapping relationship between partition groups 
Rem to synopis#. for example, 100 partitions are divided into 2 
Rem groups, partition 1 - 10 has one synopsis and partition 11 - 
Rem 100 has another synopsis
Rem if 1 partition corresponds to 1 group, we add a special row
Rem (obj#, ONE_TO_ONE) where obj# is the table's obj and ONE_TO_ONE
Rem marks the mapping from partitions to group is one to one.
create table wri$_optstat_synopsis_partgrp
( obj#   number not null,   /* obj# of a partition or a table */
  group# number not null                      /* group number */
) tablespace sysaux 
pctfree 1
enable row movement
/
create unique index i_wri$_optstat_synoppartgrp on 
  wri$_optstat_synopsis_partgrp (obj#)
  tablespace sysaux
/

Rem Table to store synopsis meta data
create table wri$_optstat_synopsis_head$ 
( bo#           number not null,    /* table obj# */
  group#        number not null,    /* partition group number */
  intcol#       number not null,             /* column number */
  synopsis#     number,
  split         number,     
              /* number of splits during creation of synopsis */
  analyzetime   date,
              /* time when this synopsis is gathered */
  spare1        number,
  spare2        blob
) tablespace sysaux 
pctfree 1
enable row movement
/
create unique index i_wri$_optstat_synophead on 
  wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
  tablespace sysaux
/

Rem Table to store the synopsis
create table wri$_optstat_synopsis$
( bo#           number not null,
  group#        number not null,
  intcol#       number not null,           
  hashvalue     number not null 
) 
partition by list(bo#) 
  subpartition by hash(group#) 
  subpartitions 32
(
  partition p0 values (0)
) 
tablespace sysaux
pctfree 1
enable row movement
/

create sequence group_num_seq start with 1 increment by 1;

create sequence synopsis_num_seq start with 1 increment by 1;

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

Rem =========================================================================
Rem END Synopsis tables
Rem =========================================================================

-- #(25372534): move the definition of *_tab_col_statistics and
-- *_part_col_statistics from cdoptim.sql to catost.sql.
-- The synopsis type is stored in wri$_optstat_synopsis_head$, which is
-- created early in this file. In order to expose the synopsis type info in
-- notes column of these DBA views, we have to move the difinition after the
--  creation of table wri$_optstat_synopsis_head$.
Rem
Rem Family "TAB_COL_STATISTICS"
Rem This family of views contains column statistics and histogram
Rem information for table columns.
Rem
create or replace view USER_TAB_COL_STATISTICS
    (TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM, SCOPE)
as
select table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats,
       notes || case when (hh.analyzetime is not null) then
                  decode(hh.spare1, null, ' ADAPTIVE_SAMPLING ',
                         ' HYPERLOGLOG ')
                else
                  null
                end,
       avg_col_len, HISTOGRAM, 
       'SHARED'
from user_tab_cols_v$ v, sys.wri$_optstat_synopsis_head$  hh
where last_analyzed is not null
  and v.column_int_id = hh.intcol#(+) and v.table_id = hh.bo#(+)
  and hh.group#(+) = 0
union all
select /* fixed table column stats */
       ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) 
                then h.row_cnt
             when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                   (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       null, -- notes
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'       
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys."_HIST_HEAD_DEC" h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and userenv('SCHEMAID') = 0  /* SYS */
UNION ALL
select /* session private stats for GTT */
       o.name                  table_name, 
       c.name                  column_name, 
       h.distcnt_kxttst_cs     num_distinct, 
       h.lowval_kxttst_cs      low_value, 
       h.hival_kxttst_cs       high_value,
       h.density_kxttst_cs     density, 
       h.null_cnt_kxttst_cs    num_nulls, 
       case when nvl(h.distcnt_kxttst_cs,0) = 0 then h.distcnt_kxttst_cs
            when h.row_cnt_kxttst_cs = 0 then 1
            when exists(select 1 from sys.x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs 
                          and c.intcol# = hg.intcol#_kxttst_hs
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) 
                 then h.row_cnt_kxttst_cs
            when bitand(h.spare2_kxttst_cs, 64) > 0
                then h.row_cnt_kxttst_cs
	    when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs > h.distcnt_kxttst_cs
                   and h.row_cnt_kxttst_cs = h.distcnt_kxttst_cs
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then h.row_cnt_kxttst_cs
            else h.bucket_cnt_kxttst_cs
       end num_buckets, 
       h.timestamp#_kxttst_cs  last_analyzed, 
       h.sample_size_kxttst_cs sample_size,
       decode(bitand(h.spare2_kxttst_cs, 2), 2, 'YES', 'NO') global_stats,
       decode(bitand(h.spare2_kxttst_cs, 1), 1, 'YES', 'NO') user_stats,
       null,  -- notes, 
       h.avgcln_kxttst_cs      avg_col_len, 
       case when nvl(h.row_cnt_kxttst_cs,0) = 0 then 'NONE'
            when exists(select 1 from sys.x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs 
                          and c.intcol# = hg.intcol#_kxttst_hs
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) then 'HYBRID'
            when bitand(h.spare2_kxttst_cs, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs >= h.distcnt_kxttst_cs                   
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,
       'SESSION'               scope
from x$kxttstecs h, obj$ o, col$ c, user_tables t
where h.obj#_kxttst_cs = o.obj# and
      o.name = t.table_name and      
      c.obj# = o.obj# and
      h.intcol#_kxttst_cs = c.intcol#
/
comment on table USER_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COL_STATISTICS.NOTES is
'Notes regarding special properties of the stats'
/
comment on column USER_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COL_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/

create or replace public synonym USER_TAB_COL_STATISTICS for USER_TAB_COL_STATISTICS
/
grant read on USER_TAB_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM, SCOPE)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, 
       user_stats,
       notes || case when (hh.analyzetime is not null) then
                  decode(hh.spare1, null, ' ADAPTIVE_SAMPLING ',
                         ' HYPERLOGLOG ')
                else
                  null
                end,
       avg_col_len, HISTOGRAM, 'SHARED'
from all_tab_cols_v$ v, sys.wri$_optstat_synopsis_head$  hh
where last_analyzed is not null
  and v.column_int_id = hh.intcol#(+) and v.table_id = hh.bo#(+)
  and hh.group#(+) = 0
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt        
             when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                   (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       null,  -- notes 
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'        
             when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                   (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'            
            else 'HEIGHT BALANCED'
       end,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys."_HIST_HEAD_DEC" h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
       and (userenv('SCHEMAID') = 0  /* SYS */
            or /* user has system privileges */
            exists (select null from v$enabledprivs
                    where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                   )
           )
UNION ALL
select /* session private stats for GTT */
       u.name                  owner,
       o.name                  table_name, 
       c.name                  column_name, 
       h.distcnt_kxttst_cs     num_distinct, 
       h.lowval_kxttst_cs      low_value, 
       h.hival_kxttst_cs       high_value,
       h.density_kxttst_cs     density, 
       h.null_cnt_kxttst_cs    num_nulls,
       case when nvl(h.distcnt_kxttst_cs,0) = 0 then h.distcnt_kxttst_cs
            when h.row_cnt_kxttst_cs = 0 then 1
            when exists(select 1 from sys.x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs 
                          and c.intcol# = hg.intcol#_kxttst_hs
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) 
                 then h.row_cnt_kxttst_cs
            when bitand(h.spare2_kxttst_cs, 64) > 0
                then h.row_cnt_kxttst_cs
	    when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs > h.distcnt_kxttst_cs
                   and h.row_cnt_kxttst_cs = h.distcnt_kxttst_cs
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then h.row_cnt_kxttst_cs
            else h.bucket_cnt_kxttst_cs
       end num_buckets,
       h.timestamp#_kxttst_cs  last_analyzed, 
       h.sample_size_kxttst_cs sample_size,
       decode(bitand(h.spare2_kxttst_cs, 2), 2, 'YES', 'NO') global_stats,
       decode(bitand(h.spare2_kxttst_cs, 1), 1, 'YES', 'NO') user_stats,
       null, -- notes
       h.avgcln_kxttst_cs      avg_col_len, 
       case when nvl(h.row_cnt_kxttst_cs,0) = 0 then 'NONE'
            when exists(select 1 from sys.x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs 
                          and c.intcol# = hg.intcol#_kxttst_hs
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) then 'HYBRID'
            when bitand(h.spare2_kxttst_cs, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs >= h.distcnt_kxttst_cs                   
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end,
       'SESSION'               scope
from x$kxttstecs h, obj$ o, col$ c, user$ u, all_tables t
where h.obj#_kxttst_cs = o.obj# and
      o.owner# = u.user# and
      o.name = t.table_name and      
      u.name = t.owner and
      c.obj# = o.obj# and
      h.intcol#_kxttst_cs = c.intcol#
/
comment on table ALL_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column ALL_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COL_STATISTICS.NOTES is
'Notes regarding special properties of the stats'
/
comment on column ALL_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COL_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/
create or replace public synonym ALL_TAB_COL_STATISTICS for ALL_TAB_COL_STATISTICS
/
grant read on ALL_TAB_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_TAB_COL_STATISTICS
    (OWNER, TABLE_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM, SCOPE)
as
select owner, table_name, column_name, num_distinct, low_value, high_value,
       density, num_nulls, num_buckets, last_analyzed, sample_size,
       global_stats, user_stats,
       notes || case when (hh.analyzetime is not null) then
                  decode(hh.spare1, null, ' ADAPTIVE_SAMPLING ', 
                         ' HYPERLOGLOG ')
                else
                  null
                end,
       avg_col_len, HISTOGRAM, 
       'SHARED'
from dba_tab_cols_v$ v, sys.wri$_optstat_synopsis_head$ hh
where last_analyzed is not null
  and v.column_int_id = hh.intcol#(+) and v.table_id = hh.bo#(+)
  and hh.group#(+) = 0
union all
select /* fixed table column stats */
       'SYS', ft.kqftanam, c.kqfconam,
       h.distcnt, h.lowval, h.hival,
       h.density, h.null_cnt,
       case when nvl(h.distcnt,0) = 0 then h.distcnt
            when h.row_cnt = 0 then 1
	    when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then h.row_cnt        
             when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                   (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then h.row_cnt           
            else h.bucket_cnt
       end,
       h.timestamp#, h.sample_size,
       decode(bitand(h.spare2, 2), 2, 'YES', 'NO'),
       decode(bitand(h.spare2, 1), 1, 'YES', 'NO'),
       null, -- notes
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where c.kqfcotob = hg.obj# and c.kqfcocno = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'        
             when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                   (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'            
            else 'HEIGHT BALANCED'
       end,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj,
         sys.x$kqfco c, sys."_HIST_HEAD_DEC" h
where
       ft.kqftaobj = fobj. obj#
       and c.kqfcotob = ft.kqftaobj
       and h.obj# = ft.kqftaobj
       and h.intcol# = c.kqfcocno
       /*
        * if fobj and st are not in sync (happens when db open read only
        * after upgrade), do not display stats.
        */
       and ft.kqftaver =
             fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
       and h.timestamp# is not null
UNION ALL
select /* session private stats for GTT */
       u.name                  owner,
       o.name                  table_name, 
       c.name                  column_name, 
       h.distcnt_kxttst_cs     num_distinct, 
       h.lowval_kxttst_cs      low_value, 
       h.hival_kxttst_cs       high_value,
       h.density_kxttst_cs     density, 
       h.null_cnt_kxttst_cs    num_nulls,
       case when nvl(h.distcnt_kxttst_cs,0) = 0 then h.distcnt_kxttst_cs
            when h.row_cnt_kxttst_cs = 0 then 1
            when exists(select 1 from sys.x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs 
                          and c.intcol# = hg.intcol#_kxttst_hs
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) 
                 then h.row_cnt_kxttst_cs
            when bitand(h.spare2_kxttst_cs, 64) > 0
                then h.row_cnt_kxttst_cs
	    when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs > h.distcnt_kxttst_cs
                   and h.row_cnt_kxttst_cs = h.distcnt_kxttst_cs
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then h.row_cnt_kxttst_cs
            else h.bucket_cnt_kxttst_cs
       end num_buckets,        
       h.timestamp#_kxttst_cs  last_analyzed, 
       h.sample_size_kxttst_cs sample_size,
       decode(bitand(h.spare2_kxttst_cs, 2), 2, 'YES', 'NO') global_stats,
       decode(bitand(h.spare2_kxttst_cs, 1), 1, 'YES', 'NO') user_stats,
       null, -- notes
       h.avgcln_kxttst_cs      avg_col_len, 
       case when nvl(h.row_cnt_kxttst_cs,0) = 0 then 'NONE'
            when exists(select 1 from x$kxttstehs hg
                        where c.obj# = hg.obj#_kxttst_hs
                          and c.intcol# = hg.intcol#_kxttst_hs 
                          and hg.ep_repeat_count_kxttst_hs > 0 
                          and rownum < 2) then 'HYBRID'
            when bitand(h.spare2_kxttst_cs, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2_kxttst_cs, 32) > 0 or
                  h.bucket_cnt_kxttst_cs > 2049 or
                  (h.bucket_cnt_kxttst_cs >= h.distcnt_kxttst_cs                    
                   and h.density_kxttst_cs*h.bucket_cnt_kxttst_cs < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end histogram,
       'SESSION'               scope
from x$kxttstecs h, obj$ o, user$ u, col$ c, dba_tables t
where h.obj#_kxttst_cs = o.obj# and
      o.owner# = u.user# and
      o.name = t.table_name and      
      u.name = t.owner and
      c.obj# = o.obj# and
      h.intcol#_kxttst_cs = c.intcol#
/
comment on table DBA_TAB_COL_STATISTICS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COL_STATISTICS.OWNER is
'Table, view or cluster owner'
/
comment on column DBA_TAB_COL_STATISTICS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COL_STATISTICS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COL_STATISTICS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COL_STATISTICS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COL_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COL_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COL_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COL_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COL_STATISTICS.NOTES is
'Notes regarding special properties of the stats'
/
comment on column DBA_TAB_COL_STATISTICS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COL_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/
create or replace public synonym DBA_TAB_COL_STATISTICS for DBA_TAB_COL_STATISTICS
/
grant select on DBA_TAB_COL_STATISTICS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_COL_STATISTICS','CDB_TAB_COL_STATISTICS');
grant select on SYS.CDB_TAB_COL_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_TAB_COL_STATISTICS for SYS.CDB_TAB_COL_STATISTICS
/

Rem 
Rem  Family "PART_COL_STATISTICS"
Rem   These views contain column statistics and histogram information
Rem   for table partitions.
Rem
create or replace view TP$ as
select tp.obj#, tp.bo#, c.intcol#, c.type#, 
      decode(bitand(c.property, 1), 1, a.name, c.name) cname, tp.rowcnt
      from sys.col$ c, sys.tabpart$ tp, attrcol$ a 
      where tp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
union
select tcp.obj#, tcp.bo#, c.intcol#, c.type#,
      decode(bitand(c.property, 1), 1, a.name, c.name) cname, tcp.rowcnt
      from sys.col$ c, sys.tabcompart$ tcp, attrcol$ a 
      where tcp.bo# = c.obj# and
      c.obj# = a.obj#(+) and c.intcol# = a.intcol#(+) and 
      bitand(c.property,32768) != 32768    /* not unused columns */
/
grant select on TP$ to select_catalog_role
/

create or replace view USER_PART_COL_STATISTICS 
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select o.name, o.subname, tp.cname, h.distcnt, 
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
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
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
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         case when (hh.analyzetime is not null) then
                decode(hh.spare1, null, 'ADAPTIVE_SAMPLING ',
                       'HYPERLOGLOG ')
              else
              null
         end notes,
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end
from  obj$ o, sys."_HIST_HEAD_DEC" h, tp$ tp,
      sys.wri$_optstat_synopsis_head$ hh
where o.obj# = tp.obj#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and tp.bo# = hh.bo#(+) and tp.intcol# = hh.intcol#(+)
  and hh.group#(+) = tp.obj# * 2
/
create or replace public synonym USER_PART_COL_STATISTICS
   for USER_PART_COL_STATISTICS 
/
grant read on USER_PART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view ALL_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, 
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
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
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
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         case when (hh.analyzetime is not null) then
                decode(hh.spare1, null, 'ADAPTIVE_SAMPLING ',
                       'HYPERLOGLOG ')
              else
                null
         end notes,
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tp$ tp, user$ u,
     sys.wri$_optstat_synopsis_head$  hh
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and tp.bo# = hh.bo#(+) and tp.intcol# = hh.intcol#(+)
  and hh.group#(+) = tp.obj# * 2
  and (o.owner# = userenv('SCHEMAID')
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
/
create or replace public synonym ALL_PART_COL_STATISTICS
   for ALL_PART_COL_STATISTICS 
/
grant read on ALL_PART_COL_STATISTICS to PUBLIC with grant option
/

create or replace view DBA_PART_COL_STATISTICS 
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, NUM_DISTINCT, LOW_VALUE,
   HIGH_VALUE, DENSITY, NUM_NULLS, NUM_BUCKETS, SAMPLE_SIZE, LAST_ANALYZED,
   GLOBAL_STATS, USER_STATS, NOTES, AVG_COL_LEN, HISTOGRAM)
as
select u.name, o.name, o.subname, tp.cname, h.distcnt, 
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
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
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
         decode(bitand(h.spare2, 512), 512, 'STATS_ON_LOAD ', '') ||
         case when (hh.analyzetime is not null) then
              decode(hh.spare1, null, 'ADAPTIVE_SAMPLING ',
                     'HYPERLOGLOG ')
              else
              null
         end notes,
       h.avgcln,
       case when nvl(h.row_cnt,0) = 0 then 'NONE'
            when exists(select 1 from sys."_HISTGRM_DEC" hg
                        where tp.obj# = hg.obj# and tp.intcol# = hg.intcol# 
                          and hg.ep_repeat_count > 0 and rownum < 2) then 'HYBRID'
            when bitand(h.spare2, 64) > 0
              then 'TOP-FREQUENCY'
            when (bitand(h.spare2, 32) > 0 or h.bucket_cnt > 2049 or
                  (h.bucket_cnt >= h.distcnt and h.density*h.bucket_cnt < 1))
                then 'FREQUENCY'           
            else 'HEIGHT BALANCED'
       end
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tp$ tp, user$ u,
     sys.wri$_optstat_synopsis_head$  hh
where o.obj# = tp.obj# and o.owner# = u.user#
  and tp.obj# = h.obj#(+) and tp.intcol# = h.intcol#(+)
  and o.type# = 19 /* TABLE PARTITION */
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and tp.bo# = hh.bo#(+) and tp.intcol# = hh.intcol#(+)
  and hh.group#(+) = tp.obj# * 2
/
create or replace public synonym DBA_PART_COL_STATISTICS
   for DBA_PART_COL_STATISTICS
/
grant select on DBA_PART_COL_STATISTICS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PART_COL_STATISTICS','CDB_PART_COL_STATISTICS');
grant select on SYS.CDB_PART_COL_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_PART_COL_STATISTICS for SYS.CDB_PART_COL_STATISTICS
/

Rem =========================================================================
Rem BEGIN Optimizer statistics history tables (Part 2).
Rem Only histogram and basic column statistics are placed here, as they are
Rem dependent on the creation of some partitioning-related dictionary tables.
Rem Other statistics history tables are at their original location in 
Rem doptim.bsq. We could not move all the history tables here, as these
Rem tables are referenced in prvtstas.sql which is run before catost.sql.
Rem =========================================================================

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

Rem
Rem Project 49581 - Encrypt Optimizer Statistics
Rem Here are the second set of calls for creating views on hist_head$ and
Rem histgrm$ tables. These views will decrypt the encrypted statistics. 
Rem
Rem Very first call for the view creation is in cdcore.sql
Rem There we will be creating views which will show the encrypted values
Rem from the tables.
Rem
Rem The view definition that is replaced here will show the decrypted
Rem values from underlying hist_head$ and histgrm$ tables if the statistics
Rem are encrypted. Decryption is done by calling into DBMS_CRYPTO_INTERNAL
Rem statsDecryptRaw, statsDecryptNum functions when the encryption bit is set.
Rem

-- Second set of calls for view creation on active statistics
create or replace force view "_HIST_HEAD_DEC" 
(
  obj#, 
  col#, 
  bucket_cnt,
  row_cnt, 
  cache_cnt, 
  null_cnt, 
  timestamp#, 
  sample_size, 
  minimum, 
  maximum, 
  distcnt, 
  lowval, 
  hival, 
  density, 
  intcol#, 
  spare1, 
  spare2, 
  avgcln, 
  spare3, 
  spare4 
)
as
select 
  obj#, 
  col#, 
  bucket_cnt, 
  row_cnt, 
  cache_cnt, 
  null_cnt, 
  timestamp#, 
  sample_size, 
  case when bitand(spare2,1024) = 1024 
    then dbms_crypto_internal.statsDecryptNum( obj#, intcol#, minimum_enc )
    else minimum
  end minimum,
  case when bitand(spare2,1024) = 1024
    then dbms_crypto_internal.statsDecryptNum( obj#, intcol#, maximum_enc )
     else maximum
  end maximum,
  distcnt,
  case when bitand(spare2,1024) = 1024
    then dbms_crypto_internal.statsDecryptRaw( obj#, intcol#, lowval )
    else lowval
  end lowval,
  case when bitand(spare2,1024) = 1024
    then dbms_crypto_internal.statsDecryptRaw( obj#, intcol#, hival )
    else hival
  end hival,
  density, 
  intcol#, 
  spare1, 
  spare2, 
  avgcln, 
  spare3, 
  spare4 
from hist_head$ h;


create or replace force view "_HISTGRM_DEC"
(
  obj#,
  col#,
  row#,
  bucket,
  endpoint,
  intcol#,
  epvalue,
  ep_repeat_count,
  epvalue_raw,
  spare1,
  spare2
)
as
select
  obj#,
  col#,
  row#,
  bucket,
  case when endpoint_enc is not null
    then dbms_crypto_internal.statsDecryptNum ( obj#, intcol#, endpoint_enc )
    else endpoint
  end endpoint,
  intcol#,
  epvalue,
  ep_repeat_count,
  case when endpoint_enc is not null
    then dbms_crypto_internal.statsDecryptRaw ( obj#, intcol#, epvalue_raw )
    else epvalue_raw
  end epvalue_raw,
  spare1,
  spare2
from histgrm$ hg;


Rem Column statistics history
create table wri$_optstat_histhead_history
 (obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  flags           number,                                           /* flags */
  null_cnt        number,                  /* number of nulls in this column */
  minimum         number,           /* minimum value (if 1-bucket histogram) */
  maximum         number,           /* minimum value (if 1-bucket histogram) */
  distcnt         number,                            /* # of distinct values */
  density         number,                                   /* density value */
  lowval          raw(1000),
                        /* lowest value of column (second lowest if default) */
  hival           raw(1000),
                      /* highest value of column (second highest if default) */
  avgcln          number,                           /* average column length */
  sample_distcnt  number,                /* sample number of distinct values */
  sample_size     number,             /* for estimated stats, size of sample */
  timestamp#      date,                   /* date of histogram's last update */
  expression      clob,                         /* extension of column group */
  colname         varchar2(128),              /* column name if an extension */
  savtime_date as (trunc(savtime)),                  /* date form of savtime */
  spare1          number,           
  spare2          number,
  spare3          number,            
  spare4          varchar2(1000),                        
  spare5          varchar2(1000),
  spare6          timestamp with time zone,
  minimum_enc     raw(1000),                      /* encrypted minimum value */ 
  maximum_enc     raw(1000)                       /* encrypted maximum value */
) 
partition by range (savtime_date)
interval (numtodsinterval(1,'day'))
(partition p_permanent values less than (to_date('01-01-1900', 'dd-mm-yyyy')))
tablespace sysaux
pctfree 1
enable row movement
/
create unique index i_wri$_optstat_hh_obj_icol_st on
  wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
  tablespace sysaux
/
create index i_wri$_optstat_hh_st on
  wri$_optstat_histhead_history (savtime)
  tablespace sysaux
/


Rem
Rem We are creating views on top of wri$_optstat_histhead_history  and
Rem wri$_optstat_histgrm_history. These views will decrypt the encrypted 
Rem statistics. 
Rem
create or replace force view "_OPTSTAT_HISTHEAD_HISTORY_DEC"
(
  obj#,
  intcol#,
  savtime,
  flags,
  null_cnt,
  minimum,
  maximum,
  distcnt,
  density,
  lowval,
  hival,
  avgcln,
  sample_distcnt,
  sample_size,
  timestamp#,
  expression,
  colname,
  savtime_date,
  spare1,
  spare2,
  spare3,
  spare4,
  spare5,
  spare6
)
as
select
  obj#,
  intcol#,
  savtime,
  flags,
  null_cnt,
  case when bitand(hh_h.flags,262144) = 262144
    then dbms_crypto_internal.statsDecryptNum( obj#, intcol#, hh_h.minimum_enc )
    else hh_h.minimum
  end minimum,
  case when bitand(hh_h.flags,262144) = 262144
    then dbms_crypto_internal.statsDecryptNum( obj#, intcol#, hh_h.maximum_enc )
    else hh_h.maximum
  end minimum,
  distcnt,
  density,
  case when bitand(hh_h.flags,262144) = 262144
    then dbms_crypto_internal.statsDecryptRaw( obj#, intcol#, hh_h.lowval )
    else hh_h.lowval
  end lowval,
  case when bitand(hh_h.flags,262144) = 262144
    then dbms_crypto_internal.statsDecryptRaw( obj#, intcol#, hh_h.hival )
    else hh_h.hival
  end hival,
  avgcln,
  sample_distcnt,
  sample_size,
  timestamp#,
  expression,
  colname,
  savtime_date,
  spare1,
  spare2,
  spare3,
  spare4,
  spare5,
  spare6
from sys.wri$_optstat_histhead_history hh_h;


Rem Histogram history
create table wri$_optstat_histgrm_history
( obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  bucket          number not null,                          /* bucket number */
  endpoint        number not null,                  /* endpoint hashed value */
  epvalue         varchar2(1000),              /* endpoint value information */
  colname         varchar2(128),              /* column name if an extension */
  ep_repeat_count number default 0 not null,    /* frequency of the endpoint */
  epvalue_raw     raw(1000),                           /* endpoint raw value */
  savtime_date as (trunc(savtime)),                  /* date form of savtime */
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone,
  endpoint_enc    raw(1000)                      /* encrypted endpoint value */
) 
partition by range (savtime_date)
interval (numtodsinterval(1,'day'))
(partition p_permanent values less than (to_date('01-01-1900', 'dd-mm-yyyy')))
tablespace sysaux
pctfree 1
enable row movement
/
create index i_wri$_optstat_h_obj#_icol#_st on 
  wri$_optstat_histgrm_history(obj#, intcol#, savtime, colname)
  tablespace sysaux
/
create index i_wri$_optstat_h_st on 
  wri$_optstat_histgrm_history(savtime)
  tablespace sysaux
/



Rem View for Histogram history table 
create or replace force view "_OPTSTAT_HISTGRM_HISTORY_DEC"
(
  obj#,
  intcol#,
  savtime,
  bucket,
  endpoint,
  epvalue,
  ep_repeat_count,
  epvalue_raw,
  savtime_date,
  spare1,
  spare2,
  spare3,
  spare4,
  spare5,
  spare6
)
as
select
  obj#,
  intcol#,
  savtime,
  bucket,
  case when endpoint_enc is not null 
    then dbms_crypto_internal.statsDecryptNum ( obj#, intcol#, 
                                                endpoint_enc )
    else endpoint
  end endpoint,
  epvalue,
  ep_repeat_count,
  case when endpoint_enc is not null 
    then dbms_crypto_internal.statsDecryptRaw ( obj#, intcol#, 
                                                epvalue_raw )
    else epvalue_raw
  end epvalue_raw,
  savtime_date,
  spare1,
  spare2,
  spare3,
  spare4,
  spare5,
  spare6
from wri$_optstat_histgrm_history;


-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

Rem =========================================================================
Rem END Optimizer statistics history tables (Part 2).
Rem =========================================================================


CREATE OR REPLACE VIEW ALL_STAT_EXTENSIONS
  (
  owner,
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    u.name, o.name, c.name,
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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
comment on table ALL_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column ALL_STAT_EXTENSIONS.OWNER is
'Owner of the extension'
/
comment on column ALL_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column ALL_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column ALL_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column ALL_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym ALL_STAT_EXTENSIONS for ALL_STAT_EXTENSIONS
/
grant read on ALL_STAT_EXTENSIONS to PUBLIC with grant option
/

CREATE OR REPLACE VIEW DBA_STAT_EXTENSIONS
  (
  owner,
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    u.name, o.name, c.name,
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
/
comment on table DBA_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column DBA_STAT_EXTENSIONS.OWNER is
'Owner of the extension'
/
comment on column DBA_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column DBA_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column DBA_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column DBA_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym DBA_STAT_EXTENSIONS for DBA_STAT_EXTENSIONS
/
grant select on DBA_STAT_EXTENSIONS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_STAT_EXTENSIONS','CDB_STAT_EXTENSIONS');
grant select on SYS.CDB_STAT_EXTENSIONS to select_catalog_role
/
create or replace public synonym CDB_STAT_EXTENSIONS for SYS.CDB_STAT_EXTENSIONS
/

CREATE OR REPLACE VIEW USER_STAT_EXTENSIONS
  (
  table_name,
  extension_name,
  extension,
  creator,
  droppable
  )
  AS
  SELECT 
    o.name, c.name, 
    sys.get_stats_extension(c.rowid),
    -- TODO use flags once it is available
    decode(substr(c.name, 1, 7), 'SYS_STU', 'USER', 'SYSTEM'),
    decode(substr(c.name, 1, 6), 'SYS_ST', 'YES', 'NO')
  FROM
    sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
  WHERE
      o.obj# = c.obj#
  and c.default$ is not null -- avoid join index columns
  and bitand(c.property, 8) = 8 -- virtual column
  and o.owner# = u.user#
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  --  tables, excluding iot - overflow and nested tables 
  and o.type# = 2 
  and not exists (select null
                  from sys.tab$ t
                  where t.obj# = o.obj#
                  and (bitand(t.property, 512) = 512 or
                       bitand(t.property, 8192) = 8192))
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_STAT_EXTENSIONS is
'Optimizer statistics extensions'
/
comment on column USER_STAT_EXTENSIONS.TABLE_NAME is
'Name of the table to which the extension belongs'
/
comment on column USER_STAT_EXTENSIONS.EXTENSION_NAME is
'Name of the statistics extension'
/
comment on column USER_STAT_EXTENSIONS.EXTENSION_NAME is
'The extension (the expression or column group)'
/
comment on column USER_STAT_EXTENSIONS.DROPPABLE is
'Is this extension drppable using dbms_stats.drop_extended_stats ?'
/
create or replace public synonym USER_STAT_EXTENSIONS for USER_STAT_EXTENSIONS
/
grant read on USER_STAT_EXTENSIONS to PUBLIC with grant option
/

Rem
Rem Family "TAB_STATISTICS"
Rem Table and index optimizer statistics 
Rem
Rem *_TAB_STATISTICS views can be used to display  statistics for
Rem tables(including fixed objects)/partitions.
Rem The view has the following union all branches
Rem   - tables
Rem   - non iot partitions
Rem   - iot partitions
Rem   - composite partitions
Rem   - subpartitions
Rem   - fixed objects
Rem stale_stats column values
Rem   null => if not analyzed or if it is fixed table
Rem   YES  => if truncated or if more than 10% modification
Rem   NO   => otherwise
Rem
-- INT$DATA_LINK_TAB_STATISTICS collects statistics related to data link tables
-- from ROOT using the data link infrastructure.
CREATE OR REPLACE VIEW INT$DATA_LINK_TAB_STATISTICS PDB_LOCAL_ONLY
  SHARING=EXTENDED DATA
 (
  owner,
  owner_id,
  table_name,
  object_id,
  object_type,
  object_type#,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  im_imcu_count,
  im_block_count,
  im_stat_update_time,
  scan_rate,
  sample_size,
  last_analyzed,
  global_stats,
  user_stats,
  stattype_locked,
  stale_stats,
  scope,
  sharing,
  origin_con_id,
  application
  )
  AS
  SELECT /* TABLES */
    u.name, o.owner#, o.name, o.obj#, 'TABLE', o.type#,
    t.rowcnt, decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)),
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)),
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)),
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      -- 1 represents metadata linked table in root
      -- 5 represents sharded Catalog
      -- for metadata linked table in root or sharded table in coordinator
      -- since the PDB/SHARDS will not actively notify the App Root or
      -- coordinator of their status, the staleness of at the App Root for
      -- metadata linked table or the stats for sharded table in coordinator
      -- is unknown.
      when (dbms_stats_internal.get_tab_share_type_view(o.flags, t.property)
        in (1,5)) then 'UNKNOWN'
      when (dbms_stats_internal.is_stale(t.obj#, null,
              null,
              (m.inserts + m.deletes + m.updates),
              t.rowcnt, m.flags) > 0) then 'YES'
      else  'NO'
    end,
    'SHARED', 1,
    to_number(sys_context('USERENV', 'CON_ID')),
    case when bitand(o.flags, 134217728)>0 then 1 else 0 end
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and bitand(o.flags, 131072) = 131072 -- data link table
/
CREATE OR REPLACE VIEW ALL_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  im_imcu_count,
  im_block_count,
  im_stat_update_time,
  scan_rate,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats,
  scope
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      -- 1 represents metadata linked table in root
      -- 5 represents sharded Catalog 
      -- for metadata linked table in root or sharded table in coordinator
      -- since the PDB/SHARDS will not actively notify the App Root or 
      -- coordinator of their status, the staleness of at the App Root for 
      -- metadata linked table or the stats for sharded table in coordinator
      -- is unknown.
      when (dbms_stats_internal.get_tab_share_type_view(o.flags, t.property)
        in (1,5)) then 'UNKNOWN'
      when (dbms_stats_internal.is_stale(t.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              t.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
    and bitand(o.flags, 131072) = 0 -- not a data link table
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_TIMESTAMP(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 64
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              tcp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and (o.owner# = userenv('SCHEMAID')
        or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              tsp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
    and (po.owner# = userenv('SCHEMAID') 
         or tcp.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
          exists (select null FROM v$enabledprivs
                  where priv_number in (-45 /* LOCK ANY TABLE */,
                                        -47 /* SELECT ANY TABLE */,
                                        -397/* READ ANY TABLE */,
                                        -48 /* INSERT ANY TABLE */,
                                        -49 /* UPDATE ANY TABLE */,
                                        -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_TIMESTAMP(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL,
    'SHARED'
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and (userenv('SCHEMAID') = 0  /* SYS */
         or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-237 /* SELECT ANY DICTIONARY */)
                 )
        )
  UNION ALL
  SELECT /* session private stats for GTT */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', ses.rowcnt_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.blkcnt_kxttst_ts, TO_NUMBER(NULL)), 
                                         /* property is 64 when IOT */
    decode(bitand(t.property, 64), 0, ses.empcnt_kxttst_ts, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, ses.avgspc_kxttst_ts, TO_NUMBER(NULL)),
    ses.chncnt_kxttst_ts, ses.avgrln_kxttst_ts, ses.avgspc_flb_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.flbcnt_kxttst_ts, TO_NUMBER(NULL)), 
    ses.cachedblk_kxttst_ts, ses.cachehit_kxttst_ts, null, null, null, null,
    ses.samplesize_kxttst_ts, ses.analyzetime_kxttst_ts,
    /* kketsflg = 8 (KQLDTVCF_GLS) */
    decode(bitand(ses.flags_kxttst_ts, 8), 0, 'NO', 'YES'),    
    /* kketsflg = 4 (KQLDTVCF_USS) */
    decode(bitand(ses.flags_kxttst_ts, 4), 0, 'NO', 'YES'),
    null,  /* no lock on session private stats */
    null,  /* session based dml monitoring not available */
    'SESSION'
  FROM
    sys.x$kxttstets ses, 
    sys.user$ u, sys.obj$ o, sys.tab$ t
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and t.obj# = ses.obj#_kxttst_ts 
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.subname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  SELECT /* Data link table statistics */
    owner, table_name, NULL, NULL, NULL,
    NULL, object_type, num_rows, blocks, empty_blocks,
    avg_space, chain_cnt, avg_row_len, avg_space_freelist_blocks,
    num_freelist_blocks, avg_cached_blocks, avg_cache_hit_ratio, im_imcu_count,
    im_block_count, im_stat_update_time, scan_rate, sample_size, last_analyzed,
    global_stats, user_stats, stattype_locked, stale_stats, scope
  FROM INT$DATA_LINK_TAB_STATISTICS
  WHERE (owner = sys_context('USERENV', 'CURRENT_USER')
         or OBJ_ID(owner, table_name, object_type#, object_id) in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               )
            )
         or /* user has system privileges */
         ora_check_sys_privilege (sys_context('USERENV', 'CURRENT_USERID'),
                                  object_type#) = 1
        )
    and (
         (APPLICATION = 1 and
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' or
           ORIGIN_CON_ID = CON_NAME_TO_ID(SYS_CONTEXT('USERENV', 
                                                      'APPLICATION_NAME'))))
         or   
         (APPLICATION = 0 and ORIGIN_CON_ID = 1) 
        )

/
create or replace public synonym ALL_TAB_STATISTICS for ALL_TAB_STATISTICS
/
grant read on ALL_TAB_STATISTICS to PUBLIC with grant option
/
comment on table ALL_TAB_STATISTICS is
'Optimizer statistics for all tables accessible to the user'
/
comment on column ALL_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column ALL_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column ALL_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column ALL_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column ALL_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column ALL_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column ALL_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column ALL_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column ALL_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_TAB_STATISTICS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column ALL_TAB_STATISTICS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column ALL_TAB_STATISTICS.IM_STAT_UPDATE_TIME is
'The timestamp of the most recent update to the inmemory statistics'
/
comment on column ALL_TAB_STATISTICS.SCAN_RATE is
'Scan rate for the object'
/
comment on column ALL_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column ALL_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column ALL_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column ALL_TAB_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/

CREATE OR REPLACE VIEW DBA_TAB_STATISTICS
 (
  owner,
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  im_imcu_count,
  im_block_count,
  im_stat_update_time,
  scan_rate,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats,
  scope
  )
  AS
  SELECT /* TABLES */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      -- 1 represents metadata linked table in root
      -- 5 represents sharded Catalog
      -- for metadata linked table in root or sharded table in coordinator
      -- since the PDB/SHARDS will not actively notify the App Root or 
      -- coordinator their status, the staleness of at the App Root for 
      -- metadata linked table or the stats for sharded table in coordinator
      -- is unknown. 
      when (dbms_stats_internal.get_tab_share_type_view(o.flags, t.property)
        in (1,5)) then 'UNKNOWN'
      when (dbms_stats_internal.is_stale(t.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              t.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and bitand(o.flags, 131072) = 0 -- not a data link table
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null,
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* IOT Partitions */
    u.name, o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_TIMESTAMP(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#,null,
             null,
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and tp.obj# = m.obj# (+)
    and bitand(tab.property, 64) = 64
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    u.name, o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when (dbms_stats_internal.is_stale(tab.obj#,null,
             null,
              (m.inserts + m.deletes + m.updates),
              tcp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ o, sys.tabcompartv$ tcp, 
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        o.owner# = u.user#
    and o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* SUBPARTITIONS */
    u.name, po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, null,
              null, 
              (m.inserts + m.deletes + m.updates),
              tsp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, 
    sys.tabsubpartv$ tsp,  sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and u.user# = po.owner# 
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* FIXED TABLES */
    'SYS', t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_TIMESTAMP(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL,
    'SHARED'
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
  UNION ALL
  SELECT /* session private stats for GTT */
    u.name, o.name, NULL, NULL, NULL, NULL, 'TABLE', ses.rowcnt_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.blkcnt_kxttst_ts, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, ses.empcnt_kxttst_ts, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, ses.avgspc_kxttst_ts, TO_NUMBER(NULL)),
    ses.chncnt_kxttst_ts, ses.avgrln_kxttst_ts, ses.avgspc_flb_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.flbcnt_kxttst_ts, TO_NUMBER(NULL)), 
    ses.cachedblk_kxttst_ts, ses.cachehit_kxttst_ts, null, null, null, null,
    ses.samplesize_kxttst_ts, ses.analyzetime_kxttst_ts,
    /* kketsflg = 8 (KQLDTVCF_GLS) */
    decode(bitand(ses.flags_kxttst_ts, 8), 0, 'NO', 'YES'),    
    /* kketsflg = 4 (KQLDTVCF_USS) */
    decode(bitand(ses.flags_kxttst_ts, 4), 0, 'NO', 'YES'),
    null,    /* no lock on session private stats */
    null,    /* session based dml monitoring not available */
    'SESSION'
  FROM sys.x$kxttstets ses, 
       sys.user$ u, sys.obj$ o, sys.tab$ t
  WHERE
        o.owner# = u.user#
    and o.obj# = t.obj#
    and t.obj# = ses.obj#_kxttst_ts
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* Data link table statistics */
    owner, table_name, NULL, NULL, NULL,
    NULL, object_type, num_rows, blocks, empty_blocks,
    avg_space, chain_cnt, avg_row_len, avg_space_freelist_blocks,
    num_freelist_blocks, avg_cached_blocks, avg_cache_hit_ratio, im_imcu_count,
    im_block_count, im_stat_update_time, scan_rate, sample_size, last_analyzed,
    global_stats, user_stats, stattype_locked, stale_stats, scope
  FROM INT$DATA_LINK_TAB_STATISTICS
  WHERE (
         (APPLICATION = 1 and
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' or
           ORIGIN_CON_ID = CON_NAME_TO_ID(SYS_CONTEXT('USERENV', 
                                                      'APPLICATION_NAME'))))
         or   
         (APPLICATION = 0 and ORIGIN_CON_ID = 1) 
        )
/
create or replace public synonym DBA_TAB_STATISTICS for DBA_TAB_STATISTICS
/
grant select on DBA_TAB_STATISTICS to select_catalog_role
/
comment on table DBA_TAB_STATISTICS is
'Optimizer statistics for all tables in the database'
/
comment on column DBA_TAB_STATISTICS.OWNER is
'Owner of the object'
/
comment on column DBA_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column DBA_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column DBA_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column DBA_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column DBA_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column DBA_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column DBA_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column DBA_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_TAB_STATISTICS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column DBA_TAB_STATISTICS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column DBA_TAB_STATISTICS.IM_STAT_UPDATE_TIME is
'The timestamp of the most recent update to the inmemory statistics'
/
comment on column DBA_TAB_STATISTICS.SCAN_RATE is
'Scan rate for the object'
/
comment on column DBA_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column DBA_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column DBA_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column DBA_TAB_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_STATISTICS','CDB_TAB_STATISTICS');
grant select on SYS.CDB_TAB_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_TAB_STATISTICS for SYS.CDB_TAB_STATISTICS
/

CREATE OR REPLACE VIEW USER_TAB_STATISTICS
 (
  table_name,
  partition_name,
  partition_position,
  subpartition_name,
  subpartition_position,
  object_type,
  num_rows,
  blocks,
  empty_blocks,
  avg_space,
  chain_cnt,
  avg_row_len,
  avg_space_freelist_blocks,
  num_freelist_blocks,
  avg_cached_blocks,
  avg_cache_hit_ratio,
  im_imcu_count,
  im_block_count,
  im_stat_update_time,
  scan_rate,
  sample_size,
  last_analyzed,
  global_stats, 
  user_stats,
  stattype_locked,
  stale_stats,
  scope
  )
  AS
  SELECT /* TABLES */
    o.name, NULL, NULL, NULL, NULL, 'TABLE', t.rowcnt,
    decode(bitand(t.property, 64), 0, t.blkcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.empcnt, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, t.avgspc, TO_NUMBER(NULL)),
    t.chncnt, t.avgrln, t.avgspc_flb,
    decode(bitand(t.property, 64), 0, t.flbcnt, TO_NUMBER(NULL)), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, t.samplesize, t.analyzetime,
    decode(bitand(t.flags, 512), 0, 'NO', 'YES'),
    decode(bitand(t.flags, 256), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
      when t.analyzetime is null then null
      -- 1 represents metadata linked table in root
      -- 5 represents sharded Catalog 
      -- for metadata linked table in root or sharded table in coordinator
      -- since the PDB/SHARDS will not actively notify the App Root or 
      -- coordinator their status, the staleness of at the App Root for 
      -- metadata linked table or the stats for sharded table in coordinator
      -- is unknown.
      when (dbms_stats_internal.get_tab_share_type_view(o.flags, t.property)
        in (1,5)) then 'UNKNOWN'
      when (dbms_stats_internal.is_stale(t.obj#, 
              null,
              null,
              (m.inserts + m.deletes + m.updates),
              t.rowcnt, m.flags) > 0) then 'YES' 
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.obj$ o, sys.tab$ t, sys.tab_stats$ ts, sys.mon_mods_v m
  WHERE
        o.obj# = t.obj#
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.obj# = ts.obj# (+)
    and t.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
    and bitand(o.flags, 131072) = 0 -- not a data link table
  UNION ALL
  SELECT /* PARTITIONS,  NOT IOT */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, tp.blkcnt, tp.empcnt, tp.avgspc,
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), 
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tp.samplesize, tp.analyzetime,
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, 
              null,
              null,
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab_stats$ ts, sys.tab$ tab, 
    sys.mon_mods_v m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and o.obj# = ts.obj# (+)
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* IOT Partitions */
    o.name, o.subname, tp.part#, NULL, NULL, 'PARTITION', 
    tp.rowcnt, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    tp.chncnt, tp.avgrln, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_TIMESTAMP(NULL), TO_NUMBER(NULL), tp.samplesize, tp.analyzetime, 
    decode(bitand(tp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, 
              null,
              null,
              (m.inserts + m.deletes + m.updates),
              tp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.obj$ o, sys.tabpartv$ tp, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        o.obj# = tp.obj#
    and tp.bo# = tab.obj#
    and bitand(tab.property, 64) = 64
    and tp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* COMPOSITE PARTITIONS */
    o.name, o.subname, tcp.part#, NULL, NULL, 'PARTITION', 
    tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc,
    tcp.chncnt, tcp.avgrln, NULL, NULL, ts.cachedblk, ts.cachehit,
    ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tcp.samplesize, tcp.analyzetime, 
    decode(bitand(tcp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tcp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tcp.analyzetime is null then null 
      when (dbms_stats_internal.is_stale(tab.obj#, 
              null,
              null,
              (m.inserts + m.deletes + m.updates),
              tcp.rowcnt, m.flags) > 0) then 'YES'
      else 'NO' 
    end,
    'SHARED'
  FROM
    sys.obj$ o, sys.tabcompartv$ tcp, sys.tab_stats$ ts, sys.tab$ tab,
    sys.mon_mods_v m
  WHERE
        o.obj# = tcp.obj#
    and tcp.bo# = tab.obj#
    and o.obj# = ts.obj# (+)
    and tcp.obj# = m.obj# (+)
    and o.owner# = userenv('SCHEMAID') 
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* SUBPARTITIONS */
    po.name, po.subname, tcp.part#,  so.subname, tsp.subpart#,
   'SUBPARTITION', tsp.rowcnt,
    tsp.blkcnt, tsp.empcnt, tsp.avgspc,
    tsp.chncnt, tsp.avgrln, NULL, NULL,
    ts.cachedblk, ts.cachehit, ts.im_imcu_count, ts.im_block_count,
    ts.im_stat_update_time, ts.scanrate, tsp.samplesize, tsp.analyzetime,
    decode(bitand(tsp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(tsp.flags, 8), 0, 'NO', 'YES'),
    decode(
      /* 
       * Following decode returns 1 if DATA stats locked for partition
       * or at table level.
       * Note that dbms_stats does n't allow locking subpartition stats.
       * If the composite partition is locked, all subpartitions are
       * considered locked. Hence decode checks for tcp entry.
       */
      decode(bitand(tab.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
      /* 
       * Following decode returns 2 if CACHE stats locked for partition
       * or at table level 
       */
      decode(bitand(tab.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
      /* if 0 => not locked, 3 => data and cache stats locked */
      0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL'),
    case 
      when tsp.analyzetime is null then null
      when (dbms_stats_internal.is_stale(tab.obj#, 
              null,
              null,
              (m.inserts + m.deletes + m.updates),
              tsp.rowcnt, m.flags) > 0) then 'YES'
      else  'NO' 
    end,
    'SHARED'
  FROM
    sys.obj$ po, sys.obj$ so, sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp,
    sys.tab_stats$ ts, sys.tab$ tab, sys.mon_mods_v m
  WHERE
        so.obj# = tsp.obj# 
    and po.obj# = tcp.obj# 
    and tcp.obj# = tsp.pobj#
    and tcp.bo# = tab.obj#
    and bitand(tab.property, 64) = 0
    and so.obj# = ts.obj# (+)
    and tsp.obj# = m.obj# (+)
    and po.owner# = userenv('SCHEMAID') 
    and po.namespace = 1 and po.remoteowner IS NULL and po.linkname IS NULL
    and bitand(po.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* FIXED TABLES */
    t.kqftanam, NULL, NULL, NULL, NULL, 'FIXED TABLE',
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.rowcnt), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), 
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.avgrln), 
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),
    TO_NUMBER(NULL), TO_NUMBER(NULL), TO_TIMESTAMP(NULL), TO_NUMBER(NULL),
    decode(nvl(fobj.obj#, 0), 0, TO_NUMBER(NULL), st.samplesize), 
    decode(nvl(fobj.obj#, 0), 0, TO_DATE(NULL), st.analyzetime), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 'YES')), 
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode(nvl(st.obj#, 0), 0, NULL, 
                  decode(bitand(st.flags, 1), 0, 'NO', 'YES'))),
    decode(nvl(fobj.obj#, 0), 0, NULL, 
           decode (bitand(fobj.flags, 67108864) + 
                     bitand(fobj.flags, 134217728), 
                   0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')),
    NULL,
    'SHARED'
    FROM sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
    where
    t.kqftaobj = fobj.obj#(+) 
    /* 
     * if fobj and st are not in sync (happens when db open read only
     * after upgrade), do not display stats.
     */
    and t.kqftaver = fobj.timestamp (+) - to_date('01-01-1991', 'DD-MM-YYYY')
    and t.kqftaobj = st.obj#(+)
    and userenv('SCHEMAID') = 0  /* SYS */
  UNION ALL
  SELECT /* session private stats for GTT */
    o.name, NULL, NULL, NULL, NULL, 'TABLE', ses.rowcnt_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.blkcnt_kxttst_ts, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, ses.empcnt_kxttst_ts, TO_NUMBER(NULL)), 
    decode(bitand(t.property, 64), 0, ses.avgspc_kxttst_ts, TO_NUMBER(NULL)),
    ses.chncnt_kxttst_ts, ses.avgrln_kxttst_ts, ses.avgspc_flb_kxttst_ts,
    decode(bitand(t.property, 64), 0, ses.flbcnt_kxttst_ts, TO_NUMBER(NULL)), 
    ses.cachedblk_kxttst_ts, ses.cachehit_kxttst_ts, null, null, null, null,
    ses.samplesize_kxttst_ts, ses.analyzetime_kxttst_ts,
    /* kketsflg = 8 (KQLDTVCF_GLS) */
    decode(bitand(ses.flags_kxttst_ts, 8), 0, 'NO', 'YES'),    
    /* kketsflg = 4 (KQLDTVCF_USS) */
    decode(bitand(ses.flags_kxttst_ts, 4), 0, 'NO', 'YES'),
    null,  /* no lock on session private stats */
    null,  /* session based dml monitoring not available */
    'SESSION'
  FROM
    sys.x$kxttstets ses,
    sys.obj$ o, sys.tab$ t
  WHERE
        o.obj# = t.obj# 
    and t.obj# = ses.obj#_kxttst_ts 
    and bitand(t.property, 1) = 0 /* not a typed table */ 
    and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
    and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
    and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  SELECT /* Data link table statistics */
    table_name, NULL, NULL, NULL,
    NULL, object_type, num_rows, blocks, empty_blocks,
    avg_space, chain_cnt, avg_row_len, avg_space_freelist_blocks,
    num_freelist_blocks, avg_cached_blocks, avg_cache_hit_ratio, im_imcu_count,
    im_block_count, im_stat_update_time, scan_rate, sample_size, last_analyzed,
    global_stats, user_stats, stattype_locked, stale_stats, scope
  FROM INT$DATA_LINK_TAB_STATISTICS
  WHERE owner = sys_context('USERENV', 'CURRENT_USER')
    and (
         (APPLICATION = 1 and
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' or
           ORIGIN_CON_ID = CON_NAME_TO_ID(SYS_CONTEXT('USERENV', 
                                                      'APPLICATION_NAME'))))
         or   
         (APPLICATION = 0 and ORIGIN_CON_ID = 1) 
        )
/
create or replace public synonym USER_TAB_STATISTICS for USER_TAB_STATISTICS
/
grant read on USER_TAB_STATISTICS to PUBLIC with grant option
/
comment on table USER_TAB_STATISTICS is
'Optimizer statistics of the user''s own tables'
/
comment on column USER_TAB_STATISTICS.TABLE_NAME is
'Name of the table'
/  
comment on column USER_TAB_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_TAB_STATISTICS.PARTITION_POSITION is
'Position of the partition within table'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_TAB_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_TAB_STATISTICS.OBJECT_TYPE is
'Type of the object (TABLE, PARTITION, SUBPARTITION)'
/  
comment on column USER_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/
comment on column USER_TAB_STATISTICS.BLOCKS is
'The number of used blocks in the object'
/
comment on column USER_TAB_STATISTICS.EMPTY_BLOCKS is
'The number of empty blocks in the object'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE is
'The average available free space in the object'
/
comment on column USER_TAB_STATISTICS.CHAIN_CNT is
'The number of chained rows in the object'
/
comment on column USER_TAB_STATISTICS.AVG_ROW_LEN is
'The average row length, including row overhead'
/
comment on column USER_TAB_STATISTICS.AVG_SPACE_FREELIST_BLOCKS is
'The average freespace of all blocks on a freelist'
/
comment on column USER_TAB_STATISTICS.NUM_FREELIST_BLOCKS is
'The number of blocks on the freelist'
/
comment on column USER_TAB_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_TAB_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_TAB_STATISTICS.IM_IMCU_COUNT is
'Number of IMCUs in the object'
/
comment on column USER_TAB_STATISTICS.IM_BLOCK_COUNT is
'Number of inmemory blocks in the object'
/
comment on column USER_TAB_STATISTICS.IM_STAT_UPDATE_TIME is
'The timestamp of the most recent update to the inmemory statistics'
/
comment on column USER_TAB_STATISTICS.SCAN_RATE is
'Scan rate for the object'
/
comment on column USER_TAB_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this table'
/
comment on column USER_TAB_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this table was analyzed'
/
comment on column USER_TAB_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_TAB_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column USER_TAB_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/

Rem
Rem Family "IND_STATISTICS"
Rem *_IND_STATISTICS views can be used to display  statistics for
Rem index/index partitions.
Rem The view has the following union all branches
Rem   - indexes (types 1, 2, 4, 6, 7, 8)
Rem   - cluster indexes (staleness, stattype_locked is different from above)
Rem   - partitions
Rem   - composite partitions
Rem   - subpartitions
Rem
Rem We don't display domain indexes since it is not available in dictionary 
Rem tables (ind$, indpart$ ...). So type 9 is excluded.
Rem
Rem index types:
Rem    normal : 1
Rem    bitmap : 2
Rem    cluster: 3
Rem    iot - top : 4
Rem    iot - nested : 5
Rem    secondary : 6
Rem    ansi : 7
Rem    lob : 8
Rem    cooperative index method (domain indexes) : 9
Rem stale_stats column values
Rem   null => if index/table (partition) is not analyzed 
Rem   YES  => if global index
Rem             if corresponding table is stale OR
Rem                the index is analyzed before table 
Rem           if local_index
Rem             if corresponding table partition is stale OR
Rem                the index partition is analyzed before table partition
Rem           if cluster index
Rem             if one of the tables in cluster is stale
Rem   NO   => otherwise
Rem
create or replace view ALL_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS, SCOPE
  )
  AS
  /* Non cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (dbms_stats_internal.is_stale(t.obj#, 
                  null,
                  null,
                  (m.inserts + m.deletes + m.updates),
                  t.rowcnt, m.flags) > 0)) then 'YES'
         else  'NO'
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_v m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      (dbms_stats_internal.is_stale(ot.obj#, 
                        null,
                        null,
                        (m.inserts + m.deletes + m.updates),
                        tab.rowcnt, m.flags) > 0)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_v m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end,
    'SHARED'
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3 /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      (dbms_stats_internal.is_stale(tp.bo#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_v m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and ip.bo# = i.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  and (io.owner# = userenv('SCHEMAID') 
        or
        i.bo# in (select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
  UNION ALL
  /* Composite partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tcp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and i.obj# = icp.bo# 
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  and (io.owner# = userenv('SCHEMAID') 
        or 
        i.bo# in (select oa.obj#
                  FROM sys.objauth$ oa
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      ) 
                   )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  UNION ALL
  /* Subpartitions */
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#, 
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tsp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and icp.bo# = i.obj# 
  and i.type# != 9  --  no domain indexes
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
  and (op.owner# = userenv('SCHEMAID')
        or i.bo# in
            (select oa.obj#
             FROM sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 FROM x$kzsro
                               ) 
            )
        or /* user has system privileges */
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
 UNION ALL
 SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    sesi.blevel_kxttst_is, sesi.leafcnt_kxttst_is, sesi.distkey_kxttst_is, 
    sesi.lblkkey_kxttst_is, sesi.dblkkey_kxttst_is, sesi.clufac_kxttst_is, 
    sesi.rowcnt_kxttst_is,
    sesi.cachedblk_kxttst_is, sesi.cachehit_kxttst_is, 
    sesi.samplesize_kxttst_is, sesi.analyzetime_kxttst_is,
    decode(bitand(sesi.flags_kxttst_is, 2048), 0, 'NO', 'YES'),
    decode(bitand(sesi.flags_kxttst_is, 64), 0, 'NO', 'YES'),
    null,  /* no lock on session private stats */
    null, /* session based dml monitoring not available */
    'SESSION'
  FROM
    sys.x$kxttsteis sesi,
    sys.user$ u, sys.ind$ i, sys.obj$ o, 
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and i.obj# = sesi.obj#_kxttst_is
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  and (o.owner# = userenv('SCHEMAID')
        or
       o.obj# in ( select obj#
                    FROM sys.objauth$
                    where grantee# in ( select kzsrorol
                                        FROM x$kzsro
                                      )
                   )
        or
         exists (select null FROM v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -397/* READ ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       )
/
create or replace public synonym ALL_IND_STATISTICS for ALL_IND_STATISTICS
/
grant read on ALL_IND_STATISTICS to PUBLIC with grant option
/
comment on table ALL_IND_STATISTICS is
'Optimizer statistics for all indexes on tables accessible to the user'
/
comment on column ALL_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column ALL_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column ALL_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column ALL_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column ALL_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column ALL_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column ALL_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column ALL_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column ALL_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column ALL_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column ALL_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column ALL_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column ALL_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column ALL_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column ALL_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column ALL_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column ALL_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column ALL_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column ALL_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column ALL_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column ALL_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column ALL_IND_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/

create or replace view DBA_IND_STATISTICS
  (
  OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS, SCOPE
  )
  AS
  /* Non cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
          (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (dbms_stats_internal.is_stale(t.obj#,
                  null,
                  null,
                  (m.inserts + m.deletes + m.updates),
                  t.rowcnt, m.flags) > 0)) then 'YES'
         else  'NO' 
    end,
    'SHARED'
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_v m
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Cluster indexes */
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      (dbms_stats_internal.is_stale(ot.obj#,
                        null,
                        null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_v m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end,
    'SHARED'
  FROM
    sys.user$ u, sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      (dbms_stats_internal.is_stale(tp.bo#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_v m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM 
    sys.obj$ io, sys.indpartv$ ip, 
    sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and io.owner# = u.user#
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Composite partitions */
  SELECT 
    u.name, io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tcp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.user$ u, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.owner# = u.user#
  and icp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Subpartitions */
  SELECT 
    u.name, op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#, 
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tsp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1),  -- local index
    'SHARED'
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.user$ u,  sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and u.user# = op.owner# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
UNION ALL
  SELECT
    u.name, o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    sesi.blevel_kxttst_is, sesi.leafcnt_kxttst_is, 
    sesi.distkey_kxttst_is, sesi.lblkkey_kxttst_is, 
    sesi.dblkkey_kxttst_is, sesi.clufac_kxttst_is, 
    sesi.rowcnt_kxttst_is,
    sesi.cachedblk_kxttst_is, sesi.cachehit_kxttst_is, 
    sesi.samplesize_kxttst_is, sesi.analyzetime_kxttst_is,
    decode(bitand(sesi.flags_kxttst_is, 2048), 0, 'NO', 'YES'),
    decode(bitand(sesi.flags_kxttst_is, 64), 0, 'NO', 'YES'),
    null,  /* no lock on session private stats */
    null,  /* session based dml monitoring not available */
    'SESSION'
  FROM
    sys.x$kxttsteis sesi,
    sys.user$ u, sys.ind$ i, sys.obj$ o, 
    sys.obj$ ot, sys.user$ ut
  WHERE
      u.user# = o.owner#
  and o.obj# = i.obj#
  and i.obj# = sesi.obj#_kxttst_is
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
/
create or replace public synonym DBA_IND_STATISTICS for DBA_IND_STATISTICS
/
grant select on DBA_IND_STATISTICS to select_catalog_role 
/
comment on table DBA_IND_STATISTICS is
'Optimizer statistics for all indexes in the database'
/
comment on column DBA_IND_STATISTICS.OWNER is
'Username of the owner of the index'
/
comment on column DBA_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column DBA_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column DBA_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column DBA_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column DBA_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column DBA_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column DBA_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column DBA_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column DBA_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column DBA_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column DBA_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column DBA_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column DBA_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column DBA_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column DBA_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column DBA_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column DBA_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column DBA_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column DBA_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column DBA_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column DBA_IND_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/


execute CDBView.create_cdbview(false,'SYS','DBA_IND_STATISTICS','CDB_IND_STATISTICS');
grant select on SYS.CDB_IND_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_IND_STATISTICS for SYS.CDB_IND_STATISTICS
/

create or replace view USER_IND_STATISTICS
  (
  INDEX_NAME, TABLE_OWNER, TABLE_NAME,
  PARTITION_NAME, PARTITION_POSITION,
  SUBPARTITION_NAME, SUBPARTITION_POSITION, OBJECT_TYPE,
  BLEVEL, LEAF_BLOCKS, 
  DISTINCT_KEYS, AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR, NUM_ROWS, 
  AVG_CACHED_BLOCKS, AVG_CACHE_HIT_RATIO,
  SAMPLE_SIZE, LAST_ANALYZED, GLOBAL_STATS, USER_STATS,
  STATTYPE_LOCKED, STALE_STATS, SCOPE
  )
  AS
  /* Non cluster indexes */
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case when
           (i.analyzetime is null or 
            t.analyzetime is null) then null
         when (i.analyzetime < t.analyzetime or
               (dbms_stats_internal.is_stale(t.obj#,
                  null,
                  null,
                  (m.inserts + m.deletes + m.updates),
                  t.rowcnt, m.flags) > 0)) then 'YES'
         else  'NO' 
    end,
    'SHARED'
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut, sys.tab$ t, sys.mon_mods_v m
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and ot.obj# = t.obj#
  and t.obj# = m.obj# (+)
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Cluster indexes */
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.rowcnt,
    ins.cachedblk, ins.cachehit, i.samplesize, i.analyzetime,
    decode(bitand(i.flags, 2048), 0, 'NO', 'YES'),
    decode(bitand(i.flags, 64), 0, 'NO', 'YES'),
    -- a cluster index is considered locked if any of the table in
    -- the cluster is locked.
    decode((select
           decode(nvl(sum(decode(bitand(t.trigflag, 67108864), 0, 0, 1)),0),
                  0, 0, 67108864) +
           decode(nvl(sum(decode(bitand(nvl(t.trigflag, 0), 134217728), 
                                 0, 0, 1)), 0),
                  0, 0, 134217728) 
           from  sys.tab$ t where i.bo# = t.bobj#),
           0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL'),
    case 
         when i.analyzetime is null then null
         when
           (select                                 -- STALE
              sum(case when
                      i.analyzetime < tab.analyzetime or
                      (dbms_stats_internal.is_stale(ot.obj#,
                        null,
                        null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)
                  then 1 else 0 end)
            from sys.tab$ tab, mon_mods_v m
            where
              m.obj#(+) = tab.obj# and tab.bobj# = i.bo#) > 0 then 'YES'
         else 'NO' end,
    'SHARED'
  FROM
    sys.ind$ i, sys.obj$ o, sys.ind_stats$ ins,
    sys.obj$ ot, sys.user$ ut
  WHERE
      o.obj# = i.obj#
  and bitand(i.flags, 4096) = 0
  and i.type# = 3  /* Cluster index */
  and i.obj# = ins.obj# (+)
  and i.bo# = ot.obj# 
  and ot.owner# = ut.user#
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Partitions */
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, ip.part#, NULL, NULL, 'PARTITION',
    ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, 
    ip.clufac, ip.rowcnt, ins.cachedblk, ins.cachehit,
    ip.samplesize, ip.analyzetime,
    decode(bitand(ip.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(ip.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabpartv$ tp, sys.tab$ t
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (ip.analyzetime is null or
                      tp.analyzetime is null) then null
                when (ip.analyzetime < tp.analyzetime  or
                      (dbms_stats_internal.is_stale(tp.bo#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabpartv$ tp, sys.mon_mods_v m 
       where tp.bo# = i.bo# and tp.phypart# = ip.phypart# and
             tp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1), -- local index
    'SHARED'
  FROM 
    sys.obj$ io, sys.indpartv$ ip, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE
      io.obj# = ip.obj# 
  and ip.obj# = ins.obj# (+)
  and ip.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Composite partitions */
  SELECT 
    io.name, ut.name, ot.name,
    io.subname, icp.part#, NULL, NULL, 'PARTITION',
    icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey, icp.dblkkey, 
    icp.clufac, icp.rowcnt, ins.cachedblk, ins.cachehit,
    icp.samplesize, icp.analyzetime,
    decode(bitand(icp.flags, 16), 0, 'NO', 'YES'), 
    decode(bitand(icp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding partn is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM sys.tabcompartv$ tcp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (icp.analyzetime is null or
                      tcp.analyzetime is null) then null
                when (icp.analyzetime < tcp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#,
                         null, 
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tcp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tabcompartv$ tcp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tcp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1), -- local index
    'SHARED'
  FROM
    sys.obj$ io, sys.indcompartv$ icp, sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      io.obj# = icp.obj# 
  and io.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and io.owner# = userenv('SCHEMAID') 
  and io.namespace = 4 and io.remoteowner IS NULL and io.linkname IS NULL
  and bitand(io.flags, 128) = 0 -- not in recycle bin
  UNION ALL
  /* Subpartitions */
  SELECT 
    op.name, ut.name, ot.name,
    op.subname, icp.part#, os.subname, isp.subpart#,
    'SUBPARTITION',
    isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey, 
    isp.clufac, isp.rowcnt, ins.cachedblk, ins.cachehit,
    isp.samplesize, isp.analyzetime,
    decode(bitand(isp.flags, 16), 0, 'NO', 'YES'),
    decode(bitand(isp.flags, 8), 0, 'NO', 'YES'),
    /* stattype_locked */
    (select 
       -- not a local index, just look at the lock at table level
       decode(bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728),
              0, NULL, 67108864, 'DATA', 134217728, 'CACHE', 'ALL')
       FROM sys.tab$ t
       where t.obj# = i.bo# and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       -- local index, we need to see if the corresponding composite partn 
       -- is locked
       decode(
       /* 
        * Following decode returns 1 if DATA stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 67108864) + bitand(tcp.flags, 32), 0, 0, 1) +
       /* 
        * Following decode returns 2 if CACHE stats locked for partition
        * or at table level 
        */
       decode(bitand(t.trigflag, 134217728) + bitand(tcp.flags, 64), 0, 0, 2),
       /* if 0 => not locked, 3 => data and cache stats locked */
       0, NULL, 1, 'DATA', 2, 'CACHE', 'ALL')
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.tab$ t
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tcp.bo# = t.obj# and
             bitand(po.flags, 1) = 1),  -- local index
    /* stale_stats */
    (select 
       case     when (i.analyzetime is null or
                      tab.analyzetime is null) then null
                when (i.analyzetime < tab.analyzetime  or
                      (dbms_stats_internal.is_stale(tab.obj#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tab.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM sys.tab$ tab, sys.mon_mods_v m 
       where tab.obj# = i.bo# and tab.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 0   -- not local index
     union all
     select
       case     when (isp.analyzetime is null or
                      tsp.analyzetime is null) then null
                when (isp.analyzetime < tsp.analyzetime  or
                      (dbms_stats_internal.is_stale(tcp.bo#,
                         null,
                         null,
                         (m.inserts + m.deletes + m.updates),
                         tsp.rowcnt, m.flags) > 0)) then 'YES'
                else 'NO'
       end
       FROM  sys.tabcompartv$ tcp, sys.tabsubpartv$ tsp, sys.mon_mods_v m 
       where tcp.bo# = i.bo# and tcp.phypart# = icp.phypart# and
             tsp.pobj# = tcp.obj# and  
             isp.physubpart# = tsp.physubpart# and
             tsp.obj# = m.obj# (+) and
             bitand(po.flags, 1) = 1), -- local index
    'SHARED'
  FROM
    sys.obj$ os, sys.obj$ op, sys.indcompartv$ icp, sys.indsubpartv$ isp, 
    sys.ind_stats$ ins,
    sys.ind$ i, sys.obj$ ot, sys.user$ ut, sys.partobj$ po
  WHERE  
      os.obj# = isp.obj# 
  and op.obj# = icp.obj# 
  and icp.obj# = isp.pobj# 
  and isp.obj# = ins.obj# (+)
  and icp.bo# = i.obj#
  and i.type# != 9  --  no domain indexes
  and i.bo# = ot.obj#
  and ot.type# = 2
  and ot.owner# = ut.user#
  and i.obj# = po.obj#
  and op.owner# = userenv('SCHEMAID')
  and op.namespace = 4 and op.remoteowner IS NULL and op.linkname IS NULL
  and bitand(op.flags, 128) = 0 -- not in recycle bin
UNION ALL
  SELECT
    o.name, ut.name, ot.name,
    NULL,NULL, NULL, NULL, 'INDEX',
    sesi.blevel_kxttst_is, sesi.leafcnt_kxttst_is, 
    sesi.distkey_kxttst_is, sesi.lblkkey_kxttst_is, 
    sesi.dblkkey_kxttst_is, sesi.clufac_kxttst_is, sesi.rowcnt_kxttst_is,
    sesi.cachedblk_kxttst_is, sesi.cachehit_kxttst_is, 
    sesi.samplesize_kxttst_is, sesi.analyzetime_kxttst_is,
    decode(bitand(sesi.flags_kxttst_is, 2048), 0, 'NO', 'YES'),
    decode(bitand(sesi.flags_kxttst_is, 64), 0, 'NO', 'YES'),
    null,       /* no lock on session private stats */
    null,       /* session based dml monitoring not available */
    'SESSION'
  FROM
    sys.x$kxttsteis sesi,
    sys.ind$ i, sys.obj$ o, 
    sys.obj$ ot, sys.user$ ut
  WHERE
      o.obj# = i.obj#
  and i.obj# = sesi.obj#_kxttst_is
  and bitand(i.flags, 4096) = 0
  and i.type# in (1, 2, 4, 6, 7, 8)
  and i.bo# = ot.obj# 
  and ot.type# = 2
  and ot.owner# = ut.user#
  and o.owner# = userenv('SCHEMAID') and o.subname IS NULL
  and o.namespace = 4 and o.remoteowner IS NULL and o.linkname IS NULL
  and bitand(o.flags, 128) = 0 -- not in recycle bin
/
create or replace public synonym USER_IND_STATISTICS for USER_IND_STATISTICS
/
grant read on USER_IND_STATISTICS to PUBLIC with grant option 
/
comment on table USER_IND_STATISTICS is
'Optimizer statistics for user''s own indexes'
/
comment on column USER_IND_STATISTICS.INDEX_NAME is
'Name of the index'
/
comment on column USER_IND_STATISTICS.TABLE_OWNER is
'Owner of the indexed object'
/
comment on column USER_IND_STATISTICS.TABLE_NAME is
'Name of the indexed object'
/
comment on column USER_IND_STATISTICS.PARTITION_NAME is
'Name of the partition'
/  
comment on column USER_IND_STATISTICS.PARTITION_POSITION is
'Position of the partition within index'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_NAME is
'Name of the subpartition'
/  
comment on column USER_IND_STATISTICS.SUBPARTITION_POSITION is
'Position of the subpartition within partition'
/  
comment on column USER_IND_STATISTICS.OBJECT_TYPE is
'Type of the object (INDEX, PARTITION, SUBPARTITION)'
/  
comment on column USER_IND_STATISTICS.NUM_ROWS is
'The number of rows in the index'
/
comment on column USER_IND_STATISTICS.BLEVEL is
'B-Tree level'
/
comment on column USER_IND_STATISTICS.LEAF_BLOCKS is
'The number of leaf blocks in the index'
/
comment on column USER_IND_STATISTICS.DISTINCT_KEYS is
'The number of distinct keys in the index'
/
comment on column USER_IND_STATISTICS.AVG_LEAF_BLOCKS_PER_KEY is
'The average number of leaf blocks per key'
/
comment on column USER_IND_STATISTICS.AVG_DATA_BLOCKS_PER_KEY is
'The average number of data blocks per key'
/
comment on column USER_IND_STATISTICS.CLUSTERING_FACTOR is
'A measurement of the amount of (dis)order of the table this index is for'
/
comment on column USER_IND_STATISTICS.AVG_CACHED_BLOCKS is
'Average number of blocks in buffer cache'
/
comment on column USER_IND_STATISTICS.AVG_CACHE_HIT_RATIO is
'Average cache hit ratio for the object'
/
comment on column USER_IND_STATISTICS.SAMPLE_SIZE is
'The sample size used in analyzing this index'
/
comment on column USER_IND_STATISTICS.LAST_ANALYZED is
'The date of the most recent time this index was analyzed'
/
comment on column USER_IND_STATISTICS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_IND_STATISTICS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_IND_STATISTICS.STATTYPE_LOCKED is
'type of statistics lock'
/
comment on column USER_IND_STATISTICS.STALE_STATS is
'Whether statistics for the object is stale or not'
/
comment on column USER_IND_STATISTICS.SCOPE is
'whether statistics for the object is shared or session'
/

Rem
Rem  Family "TAB_HISTOGRAMS"
Rem  The histograms (part of the statistics used by the cost-based
Rem    optimizer) on columns.
Rem  The TAB_COL_STATISTICS contain general information about
Rem    each histogram, including the number of buckets.
Rem  These views contains that actual histogram data.
Rem
create or replace view USER_TAB_HISTOGRAMS
    (TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT,
     SCOPE)
as
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       hg.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.endpoint
            else null
       end,
      case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when hg.epvalue is not null then epvalue
                 else dbms_stats.conv_raw( hg.epvalue_raw, c.type#)
                 end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.epvalue_raw 
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.ep_repeat_count
            else null
       end,
       'SHARED'
from sys.obj$ o, sys.col$ c, sys."_HISTGRM_DEC" hg, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = hg.obj# and c.intcol# = hg.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       ft.kqftanam,
       c.kqfconam,
       hg.bucket,
       hg.endpoint,
       case when hg.epvalue is not null then epvalue
            else dbms_stats.conv_raw(hg.epvalue_raw, c.KQFCODTY) end,
       hg.epvalue_raw,
       hg.ep_repeat_count,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys."_HISTGRM_DEC" hg
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and hg.obj# = ft.kqftaobj
  and hg.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and userenv('SCHEMAID') = 0  /* SYS */
union all
select /*+ ordered */ o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket_kxttst_hs,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then dbms_stats.conv_raw(h.epvalue_raw_kxttst_hs, c.type#) 
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count_kxttst_hs
            else null
       end,
       'SESSION'
from sys.obj$ o, sys.col$ c, sys.x$kxttstehs h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = userenv('SCHEMAID')
  and c.obj# = h.obj#_kxttst_hs and c.intcol# = h.intcol#_kxttst_hs
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
/
comment on table USER_TAB_HISTOGRAMS is
'Histograms on columns of user''s tables'
/
comment on column USER_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column USER_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/
comment on column USER_TAB_HISTOGRAMS.SCOPE is
'whether statistics for the object is shared or session'
/
create or replace public synonym USER_TAB_HISTOGRAMS for USER_TAB_HISTOGRAMS
/
grant read on USER_TAB_HISTOGRAMS to PUBLIC with grant option
/

Rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym USER_HISTOGRAMS for USER_TAB_HISTOGRAMS
/

create or replace view ALL_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT,
     SCOPE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       hg.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when hg.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(hg.epvalue_raw, c.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then hg.ep_repeat_count
            else null
       end,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HISTGRM_DEC" hg, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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
  and o.owner# = u.user#
  and c.obj# = hg.obj# and c.intcol# = hg.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       case when h.epvalue is not null then epvalue
            else dbms_stats.conv_raw(h.epvalue_raw, c.KQFCODTY) end,
       h.epvalue_raw,
       h.ep_repeat_count,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys."_HISTGRM_DEC" h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
  and (userenv('SCHEMAID') = 0  /* SYS */
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-237 /* SELECT ANY DICTIONARY */)
              )
      )
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket_kxttst_hs,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then dbms_stats.conv_raw(h.epvalue_raw_kxttst_hs, c.type#) 
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count_kxttst_hs
            else null
       end,
       'SESSION'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.x$kxttstehs h, sys.attrcol$ a
where o.obj# = c.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
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
  and o.owner# = u.user#
  and c.obj# = h.obj#_kxttst_hs and c.intcol# = h.intcol#_kxttst_hs
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
/
comment on table ALL_TAB_HISTOGRAMS is
'Histograms on columns of all tables visible to user'
/
comment on column ALL_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column ALL_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column ALL_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column ALL_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/
comment on column ALL_TAB_HISTOGRAMS.SCOPE is
'whether statistics for the object is shared or session'
/
create or replace public synonym ALL_TAB_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/
grant read on ALL_TAB_HISTOGRAMS to PUBLIC with grant option
/

Rem For backwark compatibility with ORACLE7's catalog
create or replace public synonym ALL_HISTOGRAMS for ALL_TAB_HISTOGRAMS
/

create or replace view DBA_TAB_HISTOGRAMS
    (OWNER, TABLE_NAME, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE,
     ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT,
     SCOPE)
as
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HISTGRM_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0,
       'SHARED'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj# and c.intcol# = h.intcol#
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and h.row_cnt = 0 and h.distcnt > 0
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
union all
select /*+ ordered */
       'SYS',
       ft.kqftanam,
       c.kqfconam,
       h.bucket,
       h.endpoint,
       case when h.epvalue is not null then epvalue
            else dbms_stats.conv_raw(h.epvalue_raw, c.KQFCODTY) end,
       h.epvalue_raw,
       h.ep_repeat_count,
       'SHARED'
from   sys.x$kqfta ft, sys.fixed_obj$ fobj, sys.x$kqfco c, sys."_HISTGRM_DEC" h
where  ft.kqftaobj = fobj. obj#
  and c.kqfcotob = ft.kqftaobj
  and h.obj# = ft.kqftaobj
  and h.intcol# = c.kqfcocno
  /*
   * if fobj and st are not in sync (happens when db open read only
   * after upgrade), do not display stats.
   */
  and ft.kqftaver =
         fobj.timestamp - to_date('01-01-1991', 'DD-MM-YYYY')
union all
select /*+ ordered */ u.name,
       o.name,
       decode(bitand(c.property, 1), 1, a.name, c.name),
       h.bucket_kxttst_hs,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then dbms_stats.conv_raw(h.epvalue_raw_kxttst_hs, c.type#) 
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw_kxttst_hs
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count_kxttst_hs
            else null
       end,
       'SESSION'
from sys.user$ u, sys.obj$ o, sys.col$ c, sys.x$kxttstehs h, sys.attrcol$ a
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = h.obj#_kxttst_hs and c.intcol# = h.intcol#_kxttst_hs
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))))
  and c.obj# = a.obj#(+)
  and c.intcol# = a.intcol#(+)
/
comment on table DBA_TAB_HISTOGRAMS is
'Histograms on columns of all tables'
/
comment on column DBA_TAB_HISTOGRAMS.OWNER is
'Owner of table'
/
comment on column DBA_TAB_HISTOGRAMS.TABLE_NAME is
'Table name'
/
comment on column DBA_TAB_HISTOGRAMS.COLUMN_NAME is
'Column name or attribute of object column'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column DBA_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/
comment on column DBA_TAB_HISTOGRAMS.SCOPE is
'whether statistics for the object is shared or session'
/
create or replace public synonym DBA_TAB_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/
grant select on DBA_TAB_HISTOGRAMS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_HISTOGRAMS','CDB_TAB_HISTOGRAMS');
grant select on SYS.CDB_TAB_HISTOGRAMS to select_catalog_role
/
create or replace public synonym CDB_TAB_HISTOGRAMS for SYS.CDB_TAB_HISTOGRAMS
/

Rem For backwark compatibility with ORACLE7 catalog
create or replace public synonym DBA_HISTOGRAMS for DBA_TAB_HISTOGRAMS
/

Rem
Rem  Family "PART_HISTOGRAMS"
Rem   These views contain the actual histogram data (end-points per
Rem   histogram) for histograms on table partitions.
Rem
create or replace view USER_PART_HISTOGRAMS
  (TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, tp$ tp
where o.obj# = h.obj# and h.obj# = tp.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null, 
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null, 
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_PART_HISTOGRAMS for USER_PART_HISTOGRAMS
/
grant read on USER_PART_HISTOGRAMS to PUBLIC with grant option
/
create or replace view ALL_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#      
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
                    from sys.objauth$
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
                    from sys.objauth$
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
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj#
      and tp.intcol# = h.intcol#
      and o.type# = 19 /* TABLE PARTITION */
      and h.row_cnt = 0 and h.distcnt > 0
      and o.owner# = u.user# and
      o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL and
      (o.owner# = userenv('SCHEMAID')
        or
        tp.bo# in ( select obj#
                    from sys.objauth$
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
create or replace public synonym ALL_PART_HISTOGRAMS for ALL_PART_HISTOGRAMS
/
grant read on ALL_PART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view DBA_PART_HISTOGRAMS
  (OWNER, TABLE_NAME, PARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select u.name,
       o.name, o.subname,
       tp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tp$ tp
where o.obj# = tp.obj# and tp.obj# = h.obj# 
  and tp.intcol# = h.intcol#
  and o.type# = 19 /* TABLE PARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_PART_HISTOGRAMS for DBA_PART_HISTOGRAMS
/
grant select on DBA_PART_HISTOGRAMS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PART_HISTOGRAMS','CDB_PART_HISTOGRAMS');
grant select on SYS.CDB_PART_HISTOGRAMS to select_catalog_role
/
create or replace public synonym CDB_PART_HISTOGRAMS for SYS.CDB_PART_HISTOGRAMS
/

Rem
Rem  Family "SUBPART_HISTOGRAMS"
Rem   These views contain the actual histogram data (end-points per
Rem   histogram) for histograms on table subpartitions.
Rem

create or replace view USER_SUBPART_HISTOGRAMS
  (TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tsp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, tsp$ tsp
where o.obj# = h.obj# and h.obj# = tsp.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_SUBPART_HISTOGRAMS
   for USER_SUBPART_HISTOGRAMS
/
grant read on USER_SUBPART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view ALL_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tsp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
                    from sys.objauth$
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
                    from sys.objauth$
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
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
  and (o.owner# = userenv('SCHEMAID')
        or
        tsp.bo# in ( select obj#
                    from sys.objauth$
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
create or replace public synonym ALL_SUBPART_HISTOGRAMS
   for ALL_SUBPART_HISTOGRAMS
/
grant read on ALL_SUBPART_HISTOGRAMS to PUBLIC with grant option
/

create or replace view DBA_SUBPART_HISTOGRAMS
  (OWNER, TABLE_NAME, SUBPARTITION_NAME, COLUMN_NAME, BUCKET_NUMBER, 
   ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, ENDPOINT_ACTUAL_VALUE_RAW, 
   ENDPOINT_REPEAT_COUNT)
as
select u.name,
       o.name, o.subname,
       tsp.cname,
       h.bucket,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, tsp.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
from sys.obj$ o, sys."_HISTGRM_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       0,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.minimum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
union
select u.name,
       o.name, o.subname,
       tsp.cname,
       1,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.maximum
            else null
       end,
       null,
       null,
       0
from sys.obj$ o, sys."_HIST_HEAD_DEC" h, sys.user$ u, tsp$ tsp
where o.obj# = tsp.obj# and tsp.obj# = h.obj#
  and tsp.intcol# = h.intcol#
  and o.type# = 34 /* TABLE SUBPARTITION */
  and h.row_cnt = 0 and h.distcnt > 0
  and o.owner# = u.user#
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_SUBPART_HISTOGRAMS
   for DBA_SUBPART_HISTOGRAMS
/
grant select on DBA_SUBPART_HISTOGRAMS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_SUBPART_HISTOGRAMS','CDB_SUBPART_HISTOGRAMS');
grant select on SYS.CDB_SUBPART_HISTOGRAMS to select_catalog_role
/
create or replace public synonym CDB_SUBPART_HISTOGRAMS for SYS.CDB_SUBPART_HISTOGRAMS
/

Rem
Rem Family "COL_PENDING_STATS"
Rem Column pending statistics
Rem
create or replace view ALL_COL_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end, 
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
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
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval 
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
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
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
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
  select u.name, op.name, op.subname, os.subname, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(op.name, op.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(op.name, op.owner#) = 1
            then h.hival
            else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and (os.owner# = userenv('SCHEMAID')
        or os.obj# in
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
create or replace public synonym ALL_COL_PENDING_STATS for
ALL_COL_PENDING_STATS
/
grant read on ALL_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_COL_PENDING_STATS.OWNER is
'Table owner name'
/
comment on column ALL_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column ALL_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column ALL_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column ALL_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column ALL_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column ALL_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column ALL_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/

create or replace view DBA_COL_PENDING_STATS
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select u.name, o.name, null, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, o.subname, null, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, h.distcnt, 
        case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.hival 
         else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and  h.savtime > systimestamp
/
create or replace public synonym DBA_COL_PENDING_STATS for
DBA_COL_PENDING_STATS
/
grant read on DBA_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_COL_PENDING_STATS.OWNER is
'Table owner name'
/
comment on column DBA_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column DBA_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column DBA_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column DBA_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column DBA_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column DBA_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column DBA_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/


execute CDBView.create_cdbview(false,'SYS','DBA_COL_PENDING_STATS','CDB_COL_PENDING_STATS');
grant read on SYS.CDB_COL_PENDING_STATS to PUBLIC with grant option 
/
create or replace public synonym CDB_COL_PENDING_STATS for SYS.CDB_COL_PENDING_STATS
/

create or replace view USER_COL_PENDING_STATS
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, DENSITY, NUM_NULLS, 
   AVG_COL_LEN, SAMPLE_SIZE, LAST_ANALYZED)
AS
  -- tables
  select o.name, null, null, c.name, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.type# = 2 
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, o.subname, null, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.hival
              else null
         end, 
         h.density, h.null_cnt, h.avgcln, h.sample_size, h.TIMESTAMP#
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select op.name, op.subname, os.subname, c.name, h.distcnt, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.lowval
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.hival
              else null
         end,
         h.density, h.null_cnt, h.avgcln, h.sample_size, 
         h.timestamp#
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and os.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_COL_PENDING_STATS for
USER_COL_PENDING_STATS
/
grant read on USER_COL_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_COL_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column USER_COL_PENDING_STATS.TABLE_NAME is
'Table name'
/
comment on column USER_COL_PENDING_STATS.PARTITION_NAME is
'Partition name'
/
comment on column USER_COL_PENDING_STATS.SUBPARTITION_NAME is
'Subpartition name'
/
comment on column USER_COL_PENDING_STATS.COLUMN_NAME is
'Column name'
/
comment on column USER_COL_PENDING_STATS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_COL_PENDING_STATS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_COL_PENDING_STATS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_COL_PENDING_STATS.DENSITY is
'The density of the column'
/
comment on column USER_COL_PENDING_STATS.NUM_NULLS is
'The number rows with value in the column'
/
comment on column USER_COL_PENDING_STATS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_COL_PENDING_STATS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_COL_PENDING_STATS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/

Rem
Rem Family "TAB_HISTGRM_PENDING_STATS"
Rem Histogram pending statistics
Rem
create or replace view ALL_TAB_HISTGRM_PENDING_STATS 
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE, 
   ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT)
AS
  -- tables
  select u.name, o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.endpoint
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then case when h.epvalue is not null then epvalue
                 else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.epvalue_raw
            else null
       end,
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
       end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
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
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
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
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
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
  select u.name, op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and (os.owner# = userenv('SCHEMAID')
        or os.obj# in
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
create or replace public synonym ALL_TAB_HISTGRM_PENDING_STATS for
ALL_TAB_HISTGRM_PENDING_STATS
/
grant read on ALL_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table ALL_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column ALL_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/

create or replace view DBA_TAB_HISTGRM_PENDING_STATS 
  (OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE,
   ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT)
AS
  -- tables
  select u.name, o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
  union all
  -- partitions
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  select u.name, o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
  union all
  -- sub partitions
  select u.name, op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.user$ u, sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and os.owner# = u.user#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
/
create or replace public synonym DBA_TAB_HISTGRM_PENDING_STATS for
DBA_TAB_HISTGRM_PENDING_STATS
/
grant read on DBA_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table DBA_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.OWNER is
'Name of the owner'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column DBA_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_HISTGRM_PENDING_STATS','CDB_TAB_HISTGRM_PENDING_STATS');
grant read on SYS.CDB_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option 
/
create or replace public synonym CDB_TAB_HISTGRM_PENDING_STATS for SYS.CDB_TAB_HISTGRM_PENDING_STATS
/

create or replace view USER_TAB_HISTGRM_PENDING_STATS 
  (TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, COLUMN_NAME, 
   ENDPOINT_NUMBER, ENDPOINT_VALUE, ENDPOINT_ACTUAL_VALUE,
   ENDPOINT_ACTUAL_VALUE_RAW, ENDPOINT_REPEAT_COUNT)
AS
  -- tables
  select o.name, null, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, 
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  h.obj# = c.obj# 
    and  h.intcol# = c.intcol#
    and  h.obj# = o.obj#
    and  o.owner# = u.user#
    and  o.type# = 2 
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- partitions
  select o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabpart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  select o.name, o.subname, null, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from   sys.user$ u, sys.obj$ o, sys.col$ c, sys.tabcompart$ t,
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where  t.bo# = c.obj# 
    and  t.obj# = o.obj#
    and  h.intcol# = c.intcol# 
    and  h.obj# = o.obj# 
    and  o.type# = 19 
    and  o.owner# = u.user#
    and  h.savtime > systimestamp
    and  o.owner# = userenv('SCHEMAID')
  union all
  -- sub partitions
  select op.name, op.subname, os.subname, c.name, 
         h.bucket, 
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.endpoint
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then case when h.epvalue is not null then epvalue
                   else dbms_stats.conv_raw(h.epvalue_raw, c.type#) end
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
              then h.epvalue_raw
              else null
         end,
         case when SYS_OP_DV_CHECK(os.name, os.owner#) = 1
            then h.ep_repeat_count
            else null
         end
  from  sys.obj$ os, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
        sys.col$ c, sys.obj$ op,
        sys."_OPTSTAT_HISTGRM_HISTORY_DEC" h
  where os.obj# = tsp.obj#
    and h.obj#  = tsp.obj# 
    and h.intcol#= c.intcol#
    and tsp.pobj#= tcp.obj#
    and tcp.bo#  = c.obj#
    and tcp.obj# = op.obj#
    and os.type# = 34 
    and h.savtime > systimestamp
    and os.owner# = userenv('SCHEMAID')
/
create or replace public synonym USER_TAB_HISTGRM_PENDING_STATS for
USER_TAB_HISTGRM_PENDING_STATS
/
grant read on USER_TAB_HISTGRM_PENDING_STATS to PUBLIC with grant option
/
comment on table USER_TAB_HISTGRM_PENDING_STATS is
'Pending statistics of tables, partitions, and subpartitions'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.PARTITION_NAME is
'Name of the partition'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.SUBPARTITION_NAME is
'Name of the subpartition'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_NUMBER is
'Endpoint number'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_VALUE is
'Normalized endpoint value'
/
comment on column USER_TAB_HISTGRM_PENDING_STATS.ENDPOINT_ACTUAL_VALUE is
'Actual endpoint value'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_ACTUAL_VALUE_RAW is
'Actual endpoint value in raw format'
/
comment on column USER_TAB_HISTOGRAMS.ENDPOINT_REPEAT_COUNT is
'Endpoint repeat count'
/

-- View that displays information as in user stat table
--
-- #(22182203) 
-- The following columns are added to the view to support datapump across 
-- different versions.
--
-- min_sc => minimum stats compatible 
--           The stats row coming from the view is supported in this stats 
--           compatible version or higher.
-- max_sc => maximum stats compatible
--           The stats row coming from the view is supported before this 
--           stats compatible version.
--           DSC_COMPATIBLE_MAX indicates that it is supported in all stats 
--           compatible versions after min_sc
--
-- To get all stats entries supported in a stats compatible version x, 
-- the query will have something like 
--   where min_sc <= x and  x < max_sc
--
create or replace view "_user_stat" as
select   
  type,
  version,
  flags,
  c1, c2, c3, c4, c5, c6,
  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
  d1, 
  t1,
  r1, r2, r3,
  ch1,
  cl1,
  bl1,
  min_sc,
  max_sc
from (
  --
  -- Type T, table, (sub)partition  statistics.
  -- The queries are similar to open_tab_stats_dict_cur, open_fxt_stats_dict_cur
  --
  -- T.1 Non partitioned tables
  select 
    'T' type,
    dbms_stats.get_stat_tab_version version,
    decode(bitand(t.flags, 512),512,2,0) + -- DSC_GLOBAL_STAT
    decode(bitand(t.flags, 256),256,1,0) flags,  -- DSC_USER_STAT
    o.name c1, null c2, null c3, null c4, u.name c5, null c6,
    t.rowcnt n1, 
    case  bitand(t.property, 128)
      when 128 then    --  iot with overflow
        (select tov.blkcnt from sys.tab$ tov
           where tov.obj# = t.bobj#)
      else
        t.blkcnt
    end n2, 
    t.avgrln n3, t.samplesize n4, 
    -- Note that im_imcu_count, im_block_count, scanrate are new in 12.2, 
    -- However the view will return this even if DSC_COMPATIBLE_1201. This 
    -- should not cause any issue when importing into 12.1 as it will just
    -- get ignored.
    null n5, tst.im_imcu_count n6, tst.im_block_count n7, tst.scanrate n8,
    t.chncnt n9, 
    tst.cachedblk n10, tst.cachehit n11, tst.logicalread n12, null n13, 
    t.analyzetime d1, 
    null t1, null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
    from sys.tab$ t,
         sys.tab_stats$ tst,
         sys.obj$ o,
         sys.user$ u
  where
    t.obj# = tst.obj# (+) and
    t.obj# = o.obj# and
    o.owner# = u.user# and
    bitand(t.property, 512) != 512 and          -- not an iot overflow
    bitand(t.flags, 536870912) != 536870912 and -- not an iot mapping table
    (bitand(t.flags,16) = 16 or                 -- has data stats
     tst.obj# is not null)                      -- has cache stats
  union all
  -- T.2 Partitioned tables
  select
    'T',
    dbms_stats.get_stat_tab_version,
    decode(bitand(tp.flags, 16),16,2,0)+
    decode(bitand(tp.flags, 8),8,1,0),
    op.name, op.subname, null, null, u.name, null,
    tp.rowcnt,
    case  bitand(t.property, 128)
      when 128 then    --  iot with overflow
        (select tov.blkcnt from sys.tabpart$ tov
           where tov.bo# = t.bobj# and tov.part# = tp.part#)
      else
        tp.blkcnt
    end blkcnt,
    tp.avgrln,  tp.samplesize, 
    null, tst.im_imcu_count, tst.im_block_count, tst.scanrate,        
    tp.chncnt,
    tst.cachedblk, tst.cachehit, tst.logicalread, tp.part#,
    tp.analyzetime, 
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.tabpartv$ tp, sys.obj$ op,
       sys.tab_stats$ tst, sys.tab$ t,
       sys.user$ u
  where
    op.obj# = tp.obj# and
    tp.bo# = t.obj# and
    tp.obj# = tst.obj# (+) and
    op.owner# = u.user# and        
    bitand(t.property, 512) != 512 and          -- not an iot overflow
    bitand(t.flags, 536870912) != 536870912 and -- not an iot mapping table
    (bitand(tp.flags,2) = 2 or tst.obj# is not null) -- has data/cache stats
  union all
  -- T.3 Partitions of composite partitioned tables 
  select
    'T',
    dbms_stats.get_stat_tab_version,
    decode(bitand(tp.flags, 16),16,2,0) +
    decode(bitand(tp.flags, 8),8,1,0),
    op.name, op.subname, null, null, u.name, null,
    tp.rowcnt, tp.blkcnt, tp.avgrln, tp.samplesize, 
    null, tst.im_imcu_count, tst.im_block_count, tst.scanrate,
    tp.chncnt,
    tst.cachedblk, tst.cachehit, tst.logicalread,
    tp.part#,  tp.analyzetime, 
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.obj$ op, sys.tabcompartv$ tp,
       sys.tab_stats$ tst, sys.user$ u
  where
    tp.obj# = op.obj# and
    tp.obj# = tst.obj# (+) and
    op.owner# = u.user# and        
    (bitand(tp.flags,2) = 2 or tst.obj# is not null) -- has data/cache stats
  union all
  -- T.4 Subpartitions of composite partitioned tables 
  select
    'T',
    dbms_stats.get_stat_tab_version,
    decode(bitand(ts.flags, 16),16,2,0) +
    decode(bitand(ts.flags, 8),8,1,0),
    os.name, op.subname, os.subname, null, u.name, null,
    ts.rowcnt, ts.blkcnt, ts.avgrln, ts.samplesize, 
    null, tst.im_imcu_count, tst.im_block_count, tst.scanrate,
    ts.chncnt,
    tst.cachedblk, tst.cachehit, tst.logicalread,
    ts.subpart#, ts.analyzetime, 
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.obj$ op, sys.tabcompart$ tp,
       sys.tabsubpartv$ ts, sys.obj$ os,
       sys.tab_stats$ tst, sys.user$ u
  where
    tp.obj# = op.obj# and
    ts.pobj# = tp.obj# and os.obj# = ts.obj# and
    ts.obj# = tst.obj# (+) and
    op.owner# = u.user# and
    (bitand(ts.flags,2) = 2 or tst.obj# is not null)  -- has data/cache stats
  union all
  -- T.5 Session private stats
  -- the cursor below is similar to get table stats for non partitioned
  -- table in shared mode 
  select 
    'T',
    dbms_stats.get_stat_tab_version,
    decode(bitand(ts.flags_kxttst_ts, 8),8,2,0) + 
                                    -- DSC_GLOBAL_STAT (KQLDTVCF_GLS 0x08)
    decode(bitand(ts.flags_kxttst_ts, 4),4,1,0) + 
                                    -- DSC_USER_STAT (KQLDTVCF_USS 0x04)
    2048, -- DSC_GTT_SES 
    o.name, null, null, null, u.name, null, -- C6
    ts.rowcnt_kxttst_ts, -- N1
    case  bitand(t.property, 128)
      when 128 then    --  iot with overflow
        (select tov.blkcnt from sys.tab$ tov
           where tov.obj# = t.bobj#)
      else
        ts.blkcnt_kxttst_ts
    end blkcnt, -- N2
    ts.avgrln_kxttst_ts, -- N3
    ts.samplesize_kxttst_ts, -- N4
    null, null, null, null,
    ts.chncnt_kxttst_ts, -- N9 
    ts.cachedblk_kxttst_ts, ts.cachehit_kxttst_ts, ts.logicread_kxttst_ts,
    null, -- N13
    ts.analyzetime_kxttst_ts, -- D1
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.x$kxttstets ts,
       sys.tab$ t,
       sys.obj$ o,
       sys.user$ u
  where
    ts.obj#_kxttst_ts = t.obj# and
    t.obj# = o.obj# and
    o.owner# = u.user# and
    bitand(t.property, 512) != 512 and          -- not an iot overflow
    bitand(t.flags, 536870912) != 536870912 and -- not an iot mapping table
    (bitand(ts.flags_kxttst_ts, 1) = 1 or    -- KQDS_DS set
     bitand(ts.flags_kxttst_ts, 6) <> 0)      -- KQDS_CBK or KQDS_CHR set
  union all
  -- T.6 Fixed tables 
  select /*+ ordered use_nl(fobj) use_nl(st) */
    'T', 
    dbms_stats.get_stat_tab_version,
    2 + decode(bitand(st.flags, 1),1,1,0),
    t.kqftanam, null, null, null, 'SYS', null,
    st.rowcnt, st.blkcnt, st.avgrln, st.samplesize, 
    null, st.im_imcu_count, st.im_block_count, st.scanrate, st.chncnt, 
    null, null, null, null,
    st.analyzetime,
    null, null, null, null, null, null, null bl1, 0, 
    dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.x$kqfta t, sys.fixed_obj$ fobj, sys.tab_stats$ st
  where
    t.kqftaobj = st.obj# and
    t.kqftaobj = fobj.obj# and bitand(fobj.flags, 1) = 1
  union all
  --
  -- Type C, column statistics
  -- The queries are similar to export_colstats_direct and 
  -- export_fxt_colstats_direct
  --
  -- C.1 Statistics of columns at table level
  select 
    'C' type, dbms_stats.get_stat_tab_version,
    bitand(h.spare2, 7) + -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2, 8), 0, 0, 128) +        -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2, 16), 0, 0, 1024) +      -- QOSP_HIST_SKIP
    decode(bitand(h.spare2, 32), 0, 0, 4096) +      -- QOSP_HIST_FREQ 
    decode(bitand(h.spare2, 64), 0, 0, 8192) +      -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2, 128), 0, 0, 16384) +    -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2, 256), 0, 0, 65536) +    -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2, 512), 0, 0, 131072) +   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2, 2048), 0, 0, 524288)    -- QOSP_HYBRID_GLOBAL_NDV
                                               flags,
    ot.name c1, null c2, null c3, c.name c4, u.name c5, null c6,
    h.distcnt n1, h.density n2, h.spare1 n3, h.sample_size n4, h.null_cnt n5,
    h.minimum n6, h.maximum n7, h.avgcln n8,
    to_number(decode(h.cache_cnt,0,null,1)) n9, 
    hg.bucket n10, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, null t1,
    h.lowval r1, h.hival r2, case when hg.epvalue is not null then
                                       utl_raw.cast_to_raw(hg.epvalue)
                             else hg.epvalue_raw end r3, null ch1,
    -- Store the expression of virtual columns for remap purpose
    --   0x00010000 =   65536 = virtual column
    --   0x0100     =     256 = system-generated column 
    --   0x0020     =      32 = hidden column
    decode(bitand(c.property, 65536+256+32), 65536+256+32,
           dbms_stats_internal.get_col_expr(c.rowid, c.property), null) cl1,
    null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u,  sys.obj$ ot, sys.col$ c,
       sys."_HIST_HEAD_DEC" h, sys."_HISTGRM_DEC" hg
  where
    ot.owner# = u.user# and ot.type# = 2 and
    c.obj# = ot.obj# and
    h.obj# = ot.obj# and h.intcol# = c.intcol# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol#
  union all
  -- C.2 Statistics of columns at partition level
  select
    'C' type,  dbms_stats.get_stat_tab_version,
    bitand(h.spare2, 7) + -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2, 8), 0, 0, 128) +        -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2, 16), 0, 0, 1024) +      -- QOSP_HIST_SKIP
    decode(bitand(h.spare2, 32), 0, 0, 4096) +      -- QOSP_HIST_FREQ 
    decode(bitand(h.spare2, 64), 0, 0, 8192) +      -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2, 128), 0, 0, 16384) +    -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2, 256), 0, 0, 65536) +    -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2, 512), 0, 0, 131072) +   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2, 2048), 0, 0, 524288)    -- QOSP_HYBRID_GLOBAL_NDV
                                               flags,
    ot.name c1, op.subname c2, null c3, c.name c4, u.name c5, null c6,
    h.distcnt n1, h.density n2, h.spare1 n3, h.sample_size n4, h.null_cnt n5,
    h.minimum n6, h.maximum n7, h.avgcln n8,
    to_number(decode(h.cache_cnt,0,null,1)) n9, 
    hg.bucket n10, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, null t1,
    h.lowval r1, h.hival r2, hg.epvalue_raw r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u,  sys.obj$ ot, sys.col$ c,
       sys.tabpart$ tp, sys.obj$ op,
       sys."_HIST_HEAD_DEC" h, sys."_HISTGRM_DEC" hg
  where
    ot.owner# = u.user# and
    ot.type# = 2 and
    c.obj# = ot.obj# and
    tp.bo# = ot.obj# and tp.obj# = op.obj# and
    h.obj# = op.obj# and h.intcol# = c.intcol# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol#
  union all
  -- C.3 Statistics of columns at composite partition level
  select
    'C' type, dbms_stats.get_stat_tab_version,
    bitand(h.spare2, 7) + -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2, 8), 0, 0, 128) +        -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2, 16), 0, 0, 1024) +      -- QOSP_HIST_SKIP
    decode(bitand(h.spare2, 32), 0, 0, 4096) +      -- QOSP_HIST_FREQ 
    decode(bitand(h.spare2, 64), 0, 0, 8192) +      -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2, 128), 0, 0, 16384) +    -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2, 256), 0, 0, 65536) +    -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2, 512), 0, 0, 131072) +   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2, 2048), 0, 0, 524288)    -- QOSP_HYBRID_GLOBAL_NDV
                                               flags,
    op.name c1, op.subname c2, null c3, c.name c4, u.name c5, null c6,
    h.distcnt n1, h.density n2, h.spare1 n3, h.sample_size n4, h.null_cnt n5,
    h.minimum n6, h.maximum n7, h.avgcln n8,
    to_number(decode(h.cache_cnt,0,null,1)) n9, 
    hg.bucket n10, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, null t1,
    h.lowval r1, h.hival r2, 
    case when hg.epvalue is not null then
              utl_raw.cast_to_raw(hg.epvalue)
         else hg.epvalue_raw end r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.col$ c,
       sys.tabcompart$ tp, sys.obj$ op,
       sys."_HIST_HEAD_DEC" h, sys."_HISTGRM_DEC" hg
  where
    op.owner# = u.user# and
    op.type# = 19 and
    tp.obj# = op.obj# and c.obj# = tp.bo# and
    h.obj# = op.obj# and h.intcol# = c.intcol# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol#
  union all
  -- C.4 Statistics of columns at sub partition level 
  select
    'C' type, dbms_stats.get_stat_tab_version,
    bitand(h.spare2, 7) + -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2, 8), 0, 0, 128) +        -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2, 16), 0, 0, 1024) +      -- QOSP_HIST_SKIP
    decode(bitand(h.spare2, 32), 0, 0, 4096) +      -- QOSP_HIST_FREQ 
    decode(bitand(h.spare2, 64), 0, 0, 8192) +      -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2, 128), 0, 0, 16384) +    -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2, 256), 0, 0, 65536) +    -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2, 512), 0, 0, 131072) +   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2, 2048), 0, 0, 524288)    -- QOSP_HYBRID_GLOBAL_NDV
                                               flags,
    op.name c1, op.subname c2, os.subname c3, c.name c4, u.name c5, null c6,
    h.distcnt n1, h.density n2, h.spare1 n3, h.sample_size n4, h.null_cnt n5,
    h.minimum n6, h.maximum n7, h.avgcln n8,
    to_number(decode(h.cache_cnt,0,null,1)) n9, 
    hg.bucket n10, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13, 
    h.timestamp# d1, null t1,
    h.lowval r1, h.hival r2, 
    case when hg.epvalue is not null then
              utl_raw.cast_to_raw(hg.epvalue)
         else hg.epvalue_raw end r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.col$ c,
       sys.tabcompart$ tp, sys.obj$ op,
       sys.tabsubpart$ ts, sys.obj$ os,
       sys."_HIST_HEAD_DEC" h, sys."_HISTGRM_DEC" hg
  where
    op.owner# = u.user# and
    op.type# = 19 and
    tp.obj# = op.obj# and c.obj# = tp.bo# and
    ts.pobj# = tp.obj# and ts.obj# = os.obj# and
    h.obj# = os.obj# and h.intcol# = c.intcol# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol#
  union all 
  -- C.5 Statistics of columns (session private stats)
  select 'C' type,  dbms_stats.get_stat_tab_version,
    bitand(h.spare2_kxttst_cs,7) + 
                       -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2_kxttst_cs, 8), 0, 0, 128) + 
                                              -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2_kxttst_cs, 16), 0, 0, 1024) + 
                                                      -- QOSP_HIST_SKIP 
    decode(bitand(h.spare2_kxttst_cs, 32), 0, 0, 4096) + 
                                                      -- QOSP_HIST_FREQ
    decode(bitand(h.spare2_kxttst_cs, 64), 0, 0, 8192) + 
                                                   -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2_kxttst_cs, 128), 0, 0, 16384) + 
                                                   -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2_kxttst_cs, 256), 0, 0, 65536) +    
                                                   -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2_kxttst_cs, 512), 0, 0, 131072) +    
                                                   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2_kxttst_cs, 2048), 0, 0, 524288) +
                                                   -- QOSP_HYBRID_GLOBAL_NDV
    2048 flags,                                          -- DSC_GTT_SES 
    o.name c1, null c2, null c3, c.name c4, u.name c5, null c6,
    h.distcnt_kxttst_cs n1, h.density_kxttst_cs n2, h.spare1_kxttst_cs n3, 
    h.sample_size_kxttst_cs n4, h.null_cnt_kxttst_cs n5,
    h.minimum_kxttst_cs n6, h.maximum_kxttst_cs n7, h.avgcln_kxttst_cs n8,
    to_number(decode(h.cache_cnt_kxttst_cs,0,null,1)) n9, 
    hg.bucket_kxttst_hs n10, hg.endpoint_kxttst_hs n11,
    hg.ep_repeat_count_kxttst_hs n12, null n13, 
    h.timestamp#_kxttst_cs d1, null t1,
    h.lowval_kxttst_cs r1, h.hival_kxttst_cs r2, 
    hg.epvalue_raw_kxttst_hs r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.col$ c,
       sys.x$kxttstecs h, sys.x$kxttstehs hg,
       sys.obj$ o, sys.user$ u
  where
    o.obj# = c.obj# and
    o.owner# = u.user# and 
    h.obj#_kxttst_cs = c.obj# and h.intcol#_kxttst_cs = c.intcol# and
    hg.obj#_kxttst_hs(+) = h.obj#_kxttst_cs and 
    hg.intcol#_kxttst_hs(+) = h.intcol#_kxttst_cs
  union all
  -- C.6 Statistics of columns of fixed tables
  select /*+ ordered */
    'C' type, dbms_stats.get_stat_tab_version,
    bitand(h.spare2, 7) + -- QOSP_USER_STAT + QOSP_GLOBAL_STAT + QOSP_EAVS 
    decode(bitand(h.spare2, 8), 0, 0, 128) + -- QOSP_GLOBAL_SYNOP_STAT 
    decode(bitand(h.spare2, 16), 0, 0, 1024) +      -- QOSP_HIST_SKIP
    decode(bitand(h.spare2, 32), 0, 0, 4096) +      -- QOSP_HIST_FREQ
    decode(bitand(h.spare2, 64), 0, 0, 8192) +      -- QOSP_HIST_TOPFREQ
    decode(bitand(h.spare2, 128), 0, 0, 16384) +    -- QOSP_HIST_IGNORE
    decode(bitand(h.spare2, 256), 0, 0, 65536) +    -- QOSP_HISTGRM_ONLY
    decode(bitand(h.spare2, 512), 0, 0, 131072) +   -- QOSP_STATS_ON_LOAD
    decode(bitand(h.spare2, 2048), 0, 0, 524288)    -- QOSP_HYBRID_GLOBAL_NDV
                                               flags,
    ot.kqftanam c1, null c2, null c3, c.kqfconam c4, 'SYS' c5, null c6,
    h.distcnt n1, h.density n2, h.spare1 n3, h.sample_size n4, h.null_cnt n5,
    h.minimum n6, h.maximum n7, h.avgcln n8,
    to_number(decode(h.cache_cnt,0,null,1)) n9, 
    hg.bucket n10, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, null t1,
    h.lowval r1, h.hival r2, 
    case when hg.epvalue is not null then
              utl_raw.cast_to_raw(hg.epvalue)
         else hg.epvalue_raw end r3, null ch1, null cl1, null bl1, 0,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.x$kqfta ot, sys.x$kqfco c,
       sys."_HIST_HEAD_DEC" h, sys."_HISTGRM_DEC" hg
  where
    c.kqfcotob = ot.kqftaobj and
    h.obj# = ot.kqftaobj and h.intcol# = c.kqfcocno and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol#
  union all
  --
  -- Type E, extensions
  --
  select 
    'E', dbms_stats.get_stat_tab_version,
    256,
    ot.name c1, null, null, c.name c4, u.name c5, null c6,
    null n1, null n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1, null r1, null r2, null r3, null ch1,
    dbms_stats_internal.get_default$(c.rowid) cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, sys.col$ c
  where  
    ot.owner# = u.user# and
    ot.type# = 2 and
    c.obj# = ot.obj# and
    bitand(c.property, 32) = 32 and 
    bitand(c.property, 65536) =  65536 and      
    substr(c.name, 1, 6) = 'SYS_ST'
  union all
  --
  -- Type P, table level preferences
  --
  select 
    'P', dbms_stats.get_stat_tab_version,
    null,
    o.name, p.pname, null, null, u.name, null c6,
    p.valnum, p.spare1 n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    p.chgtime d1, null t1, null r1, null r2, null r3, null ch1,
    to_clob(p.valchar) cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from optstat_user_prefs$ p, obj$ o, user$ u
  where p.obj#=o.obj# and o.owner#=u.user# 
  union all
  --
  -- Type H, synopses head
  --
  select /*+ ordered */
    'H', dbms_stats.get_stat_tab_version,
    null,
    ot.name, op.subname, null, c.name, u.name, null,
    h.split n1, h.spare1 n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    h.analyzetime d1, null t1, null r1, null r2, null r3, null ch1,
    null cl1, h.spare2 bl1,
    u.user# owner#,  
    -- #(22182203) HLL synopses are stored in spare2 and is supported from
    -- 12.2 onwards. The type of synopses will be set to 1 for HLL in spare1.
    -- Mark them as supported from 12.2.
    decode(h.spare1, 1,
           dbms_stats_internal.get_sc_1202,
           dbms_stats_internal.get_sc_1201) min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from
    sys.user$ u,
    sys.obj$ ot, 
    sys.wri$_optstat_synopsis_head$ h, 
    sys.obj$ op,
    sys.col$ c
  where 
    u.user# = ot.owner# and
    ot.obj# = h.bo# and
    h.group#/2 = op.obj#(+)  and
    h.bo# = c.obj# and
    h.intcol# = c.intcol#
  union all
  --
  -- Type B, synopses 
  --
  select /*+ ordered */
    'B', dbms_stats.get_stat_tab_version,
    null,
    ot.name c1, op.subname c2, null c3, c.name c4, u.name c5, null c6,
    null n1, null n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1, null r1, null r2, null r3, null ch1, s.hashVal cl1, 
    null bl1, u.user# owner#, 
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc    
  from
    sys.user$ u,
    sys.obj$ ot, 
    sys.wri$_optstat_synopsis_head$ h, 
    sys.obj$ op,
    table(dbms_stats_internal.compose_hashval_clob_rec(
            h.bo#, h.group#/2, h.group#)) s,
    sys.col$ c
  where 
    u.user# = ot.owner# and
    ot.obj# = h.bo# and
    h.group#/2 = op.obj#(+)  and
    h.intcol# = s.intcol# and
    h.bo# = c.obj# and
    h.intcol# = c.intcol#
  union all
  --
  -- Type I, index, (sub)partition  statistics.
  -- The queries are similar to get_indstats_dict
  --
  -- I.1 Non partitioned indexes
  select 
    'I',  dbms_stats.get_stat_tab_version,
    decode(bitand(i.flags, 2048),2048,2,0) +
    decode(bitand(i.flags, 64),64,1,0),
    o.name, null, null, ot.name, u.name, ut.name,
    i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
    i.blevel,  i.samplesize,
    decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
           decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
    ist.cachedblk, ist.cachehit, ist.logicalread, null, i.analyzetime,
    null, null, null, null, null, dbms_stats_internal.get_ind_cols(i.obj#),
    null bl1, u.user# owner#, 
    dbms_stats_internal.get_sc_1201 min_sc,
    dbms_stats_internal.get_sc_max max_sc
  from sys.ind$ i, sys.ind_stats$ ist, sys.obj$ o, sys.user$ u,
       sys.obj$ ot, sys.user$ ut
  where
    i.obj# = o.obj# and 
    o.owner# = u.user# and
    i.bo# = ot.obj# and
    ot.owner# = ut.user# and
    i.obj# = ist.obj# (+) and
    (bitand(i.flags,2) = 2 or ist.obj# is not null)
  union all
  -- I.2 Partitions
  select
    'I',  dbms_stats.get_stat_tab_version,
    decode(bitand(ip.flags, 16),16,2,0) +
    decode(bitand(ip.flags, 8),8,1,0),
    op.name, op.subname, null, null, u.name, null,
    ip.rowcnt, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, ip.clufac,
    ip.blevel,  ip.samplesize, ip.pctthres$,
    ist.cachedblk, ist.cachehit, ist.logicalread, ip.part#, ip.analyzetime,
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc,
     dbms_stats_internal.get_sc_max max_sc
  from sys.indpartv$ ip, sys.obj$ op,
       sys.ind_stats$ ist, sys.user$ u
  where
    op.obj# = ip.obj# and 
    op.owner# = u.user# and
    ip.obj# = ist.obj# (+) and
    (bitand(ip.flags,2) = 2 or ist.obj# is not null)
  union all
  -- I.3 Composite partitions
  select
    'I',  dbms_stats.get_stat_tab_version,
    decode(bitand(ip.flags, 16),16,2,0) +
    decode(bitand(ip.flags, 8),8,1,0),
    op.name, op.subname, null, null, u.name, null,
    ip.rowcnt, ip.leafcnt, ip.distkey, ip.lblkkey, ip.dblkkey, ip.clufac,
    ip.blevel,  ip.samplesize, null,
    ist.cachedblk, ist.cachehit, ist.logicalread, ip.part#, ip.analyzetime,
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.obj$ op, sys.indcompartv$ ip,
       sys.ind_stats$ ist, sys.user$ u
  where
    ip.obj# = op.obj# and
    op.owner# = u.user# and
    ip.obj# = ist.obj# (+) and
    (bitand(ip.flags,2) = 2 or ist.obj# is not null)
  union all
  -- I.4 Sub partitions
  select
    'I',  dbms_stats.get_stat_tab_version,
    decode(bitand(isp.flags, 16),16,2,0) +
    decode(bitand(isp.flags, 8),8,1,0),
    op.name, op.subname, os.subname, null, u.name, null,
    isp.rowcnt, isp.leafcnt, isp.distkey, isp.lblkkey,
    isp.dblkkey, isp.clufac,
    isp.blevel,  isp.samplesize, null,
    ist.cachedblk, ist.cachehit, ist.logicalread, isp.subpart#, 
    isp.analyzetime,
    null, null, null, null, null, null, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.obj$ op, sys.indcompart$ ip,
       sys.indsubpartv$ isp, sys.obj$ os,
       sys.ind_stats$ ist, sys.user$ u
  where
    ip.obj# = op.obj# and
    isp.pobj# = ip.obj# and os.obj# = isp.obj# and
    os.owner# = u.user# and
    isp.obj# = ist.obj# (+) and
    (bitand(isp.flags,2) = 2 or ist.obj# is not null)
  union all
  -- I.5 Session private index stats
  select
    'I',  dbms_stats.get_stat_tab_version,
    decode(bitand(ist.flags_kxttst_is, 2048),2048,2,0)+  -- KQLDINF_GLS 
    decode(bitand(ist.flags_kxttst_is, 64),64,1,0)+      -- KQLDINF_USS 
    2048, -- DSC_GTT_SES 
    o.name, null, null, ot.name, u.name, ut.name,
    ist.rowcnt_kxttst_is, ist.leafcnt_kxttst_is, 
    ist.distkey_kxttst_is, ist.lblkkey_kxttst_is, 
    ist.dblkkey_kxttst_is, ist.clufac_kxttst_is,
    ist.blevel_kxttst_is,
    ist.samplesize_kxttst_is,
    decode(bitand(i.flags, 128), 128, mod(trunc(i.pctthres$/256),256),
           decode(i.type#, 4, mod(trunc(i.pctthres$/256),256), NULL)),
    ist.cachedblk_kxttst_is, ist.cachehit_kxttst_is, 
    ist.logicalread_kxttst_is, null, ist.analyzetime_kxttst_is, 
    null, null, null, null, null, dbms_stats_internal.get_ind_cols(i.obj#),   
    null bl1, u.user# owner#, 
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.ind$ i, sys.x$kxttsteis ist,
       sys.obj$ o, sys.user$ u,
       sys.obj$ ot, sys.user$ ut
  where
    ist.obj#_kxttst_is = i.obj# and
    i.obj# = o.obj# and
    o.owner# = u.user# and
    i.bo# = ot.obj# and
    ot.owner# = ut.user# and
    (bitand(ist.flags_kxttst_is, 1) = 1 or  -- KQDS_DS set
     bitand(ist.flags_kxttst_is, 6) <> 0)   -- KQDS_CBK or KQDS_CHR set
  --
  -- Type t, table, (sub)partition  statistics history.
  -- The queries are similar to open_tab_stats_hist_cur
  --
  union all
  -- t.1 tables and partitions
  select
    't' type,
    dbms_stats.get_stat_tab_version version,
    t.flags flags,
    ot.name c1, ot.subname, null, null, u.name, null c6, 
    t.rowcnt n1, t.blkcnt, t.avgrln,  t.samplesize n4,
    null n5, t.im_imcu_count n6, t.im_block_count n7, t.scanrate n8,
    t.spare1 n9, t.cachedblk, t.cachehit, t.logicalread n12, null n13,
    t.analyzetime d1, t.savtime t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 
    min_sc, dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, sys.wri$_optstat_tab_history t
  where
    ot.owner# = u.user# and
    ot.type# in (2,19) and -- TABLE, [COMPOSITE] PARTITION
    ot.obj# = t.obj# 
  union all
  -- t.2 subpartitions of tables
  select
    't' type,
    dbms_stats.get_stat_tab_version version,
    t.flags flags,
    op.name c1, op.subname, os.subname, null, u.name c5, null c6,
    t.rowcnt n1, t.blkcnt, t.avgrln,  t.samplesize n4,
    null n5, t.im_imcu_count n6, t.im_block_count n7, t.scanrate n8,
    t.spare1 n9, t.cachedblk, t.cachehit, t.logicalread n12, null n13,
    t.analyzetime d1, t.savtime t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ os,
       sys.tabsubpart$ ts,  sys.obj$ op, sys.wri$_optstat_tab_history t
  where
    os.owner# = u.user# and
    os.type# = 34 and -- SUB PARTITION
    os.obj# = ts.obj# and ts.pobj# = op.obj# and op.type# = 19 and
    ts.obj# = t.obj#
  union all
  -- t.3 fixed tables
  select
    't' type,
    dbms_stats.get_stat_tab_version version,
    t.flags flags,
    ot.kqftanam c1, null, null, null, 'SYS' c5, null c6,
    t.rowcnt n1, t.blkcnt, t.avgrln, t.samplesize n4,
    null n5, t.im_imcu_count n6, t.im_block_count n7, t.scanrate n8,
    t.spare1 n9, t.cachedblk, t.cachehit, t.logicalread n12, null n13,
    t.analyzetime d1, t.savtime t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1, 0 owner#,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.x$kqfta ot, sys.wri$_optstat_tab_history t
  where ot.kqftaobj = t.obj#
  --
  -- Type i, index, (sub)partition  statistics history.
  -- The queries are similar to get_indstats_hist
  --
  union all
  -- i.1 INDEX and INDEX  [COMPOSITE] PARTITION
  select
    'i' type,  dbms_stats.get_stat_tab_version version,
    i.flags flags,
    oi.name c1, oi.subname, null, null, u.name, null c6, 
    i.rowcnt n1, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac n6,
    i.blevel n7,  i.samplesize, i.guessq n9, 
    i.cachedblk n10, i.cachehit, i.logicalread, null n13, 
    i.analyzetime d1, i.savtime t1, 
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ oi, sys.wri$_optstat_ind_history i
  where
    oi.owner# = u.user# and
    oi.type# in (1, 20) and -- INDEX, [COMPOSITE] PARTITION
    oi.obj# = i.obj#
  union all
  -- i.2 INDEX SUB PARTITION
  select
    'i' type,  dbms_stats.get_stat_tab_version version,
    i.flags flags,
    op.name c1, op.subname, os.subname, null, u.name, null c6, 
    i.rowcnt n1, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac n6,
    i.blevel n7,  i.samplesize, i.guessq n9, 
    i.cachedblk n10, i.cachehit, i.logicalread, null n13, 
    i.analyzetime d1, i.savtime t1, 
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ os,
       sys.indsubpart$ isp, sys.obj$ op,
       sys.wri$_optstat_ind_history i
  where
    os.owner# = u.user# and
    os.type# = 35 and -- SUB PARTITION
    os.obj# = isp.obj# and
    isp.pobj# = op.obj# and op.type# = 20 and
    isp.obj# = i.obj#
  --
  -- Type c, column statistics history.
  -- The queries are similar to open_colstats_hist_cur
  -- Note that if extensions are dropped when exporting
  -- stats, the entries in history will have intcol# = 0.
  -- These entries does not join with col$ and hence we
  -- directly get the column name from history for these
  -- cases. We don't need this for fixed tables as 
  -- extensions are not supported for them.
  --
  union all
  -- c.1 -- Columns of Tables and Partitions
  select 
    'c' type, dbms_stats.get_stat_tab_version version,
    h.flags flags,
    ot.name c1, ot.subname c2, null c3, 
    nvl(h.colname, -- h.colname not null only when an extension
        (select name from sys.col$ c
         where c.obj# = tab.bo# and 
               h.intcol# = c.intcol#)) c4,
    u.name c5, null c6,
    h.distcnt n1, h.density, h.sample_distcnt, h.sample_size n4, 
    h.null_cnt n5, h.minimum, h.maximum, h.avgcln n8, 
    null n9, hg.bucket, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, h.savtime t1,
    h.lowval r1, h.hival r2, case when hg.epvalue is not null then
                                       utl_raw.cast_to_raw(hg.epvalue)
                             else hg.epvalue_raw end r3, null ch1,
    expression cl1, null bl1, u.user# owner#,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u,  sys.obj$ ot, 
       sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h, 
       sys."_OPTSTAT_HISTGRM_HISTORY_DEC" hg,
       (select 2 type#, t.obj# obj#, t.obj# bo#
        from sys.tab$ t
        union all
        select 19 type#,  t.obj# obj#, t.bo# bo#
        from sys.tabpart$ t
        union all
        select 19 type#, t.obj# obj#, t.bo# bo#
        from sys.tabcompart$ t) tab
  where
    ot.owner# = u.user# and ot.type# in (2,19) and
    h.obj# = ot.obj# and
    ot.obj# = tab.obj# and
    ot.type# = tab.type# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol# and
    hg.savtime(+) = h.savtime
  union all
  -- c.2 -- Columns of Sub Partitions
  select 
    'c' type, dbms_stats.get_stat_tab_version version,
    h.flags flags,
    op.name c1, op.subname c2, os.subname c3, 
    nvl(h.colname, -- h.colname not null only when an extension
        (select name from sys.col$ c  
         where c.obj# = tcp.bo# and 
               h.intcol# = c.intcol#)) c4,
    u.name c5, null c6,
    h.distcnt n1, h.density, h.sample_distcnt, h.sample_size n4, 
    h.null_cnt n5, h.minimum, h.maximum, h.avgcln n8, 
    null n9, hg.bucket, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, h.savtime t1,
    h.lowval r1, h.hival r2, case when hg.epvalue is not null then
                                       utl_raw.cast_to_raw(hg.epvalue)
                             else hg.epvalue_raw end r3, null ch1,
    expression cl1, null bl1, u.user# owner#,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ op, sys.obj$ os,
       sys.tabsubpart$ ts, sys.tabcompart$ tcp,
       sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h, 
       sys."_OPTSTAT_HISTGRM_HISTORY_DEC" hg
  where
    os.owner# = u.user# and
    os.type# = 34 and -- SUB PARTITION
    os.obj# = ts.obj# and ts.pobj# = op.obj# and op.type# = 19 and
    ts.pobj# = tcp.obj# and
    ts.obj# = h.obj# and
    hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol# and
    hg.savtime(+) = h.savtime
  union all
  -- c.3 -- Columns of fixed tables
  select 
    'c' type, dbms_stats.get_stat_tab_version version,
    h.flags flags,
    ot.kqftanam c1, null c2, null c3, null c4, 'SYS' c5, null c6,
    h.distcnt n1, h.density, h.sample_distcnt, h.sample_size n4, 
    h.null_cnt n5, h.minimum, h.maximum, h.avgcln n8, 
    null n9, hg.bucket, hg.endpoint n11,
    hg.ep_repeat_count n12, null n13,
    h.timestamp# d1, h.savtime t1,
    h.lowval r1, h.hival r2, case when hg.epvalue is not null then
                                       utl_raw.cast_to_raw(hg.epvalue)
                             else hg.epvalue_raw end r3, null ch1,
    expression cl1, null bl1, 0 owner#,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
    from sys.x$kqfta ot, sys.x$kqfco c,
         sys."_OPTSTAT_HISTHEAD_HISTORY_DEC" h, 
         sys."_OPTSTAT_HISTGRM_HISTORY_DEC" hg
    where
      c.kqfcotob = ot.kqftaobj and
      h.obj# = c.kqfcotob and h.intcol# = c.kqfcocno and
      hg.obj#(+) = h.obj# and hg.intcol#(+) = h.intcol# and
      hg.savtime(+) = h.savtime
  union all
  -- 
  -- Type M, DML Modification monitoring information
  --
  -- M.1 Modifications for tables and [composite] partitions
  select
    'M' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    ot.name c1, ot.subname, null, null, u.name, null c6, 
    m.inserts n1, m.updates n2, m.deletes n3, m.flags n4,
    m.drop_segments n5, null, null, null n8,
    null n9, null, null, null n12, null n13,
    m.timestamp d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, sys.mon_mods_all$ m
  where
    ot.owner# = u.user# and
    ot.type# in (2,19) and -- TABLE, [COMPOSITE] PARTITION
    ot.obj# = m.obj# 
  union all
  -- M.2 Modifications for subpartitions of tables
  select
    'M' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    op.name c1, op.subname, os.subname, null, u.name c5, null c6,
    m.inserts n1, m.updates n2, m.deletes n3, m.flags n4,
    m.drop_segments n5, null, null, null n8,
    null n9, null, null, null n12, null n13,
    m.timestamp d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ os,
       sys.tabsubpart$ ts,  sys.obj$ op, sys.mon_mods_all$ m
  where
    os.owner# = u.user# and
    os.type# = 34 and -- SUB PARTITION
    os.obj# = ts.obj# and ts.pobj# = op.obj# and op.type# = 19 and
    ts.obj# = m.obj#
  union all
  -- 
  -- Type U, column Usage information
  --
  -- U.1 Column Usage of regular tables
  select
    'U' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    ot.name c1, null, null, c.name, u.name, null c6, 
    u.equality_preds n1, u.equijoin_preds n2, u.nonequijoin_preds n3,
    u.range_preds n4, u.like_preds n5, u.null_preds n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    u.timestamp d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, sys.col$ c, sys.col_usage$ u
  where
    ot.owner# = u.user# and
    ot.type# = 2 and -- TABLE
    ot.obj# = c.obj# and
    u.obj# = c.obj# and u.intcol# = c.intcol#
  union all
  -- U.2 Column Usage of fixed tables
  select
    'U' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    ot.kqftanam c1, null c2, null c3, null c4, 'SYS' c5, null c6,
    u.equality_preds n1, u.equijoin_preds n2, u.nonequijoin_preds n3,
    u.range_preds n4, u.like_preds n5, u.null_preds n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    u.timestamp d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1, 0 owner#,
    dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
    from sys.x$kqfta ot, sys.x$kqfco c, sys.col_usage$ u
    where
      c.kqfcotob = ot.kqftaobj and
      u.obj# = c.kqfcotob and u.intcol# = c.kqfcocno
  -- 
  -- Type G, column group Usage information
  --
  union all
  select
    'G' type,
    dbms_stats.get_stat_tab_version version,
    g.flags flags,
    ot.name c1, null, null, null, u.name, null c6, 
    null n1, null n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    g.timestamp d1, null t1,
    null r1, null r2, null r3, null ch1, to_clob(g.cols) cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, sys.col_group_usage$ g
  where
    ot.owner# = u.user# and
    ot.type# = 2 and -- TABLE
    ot.obj# = g.obj# 
  -- 
  -- Type L, statistics lock (and can store other metadata as well?)
  -- Lock bits are not stored in subpartitions, hence no query on tabsubpart$
  --
  union all
  select
    'L' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    ot.name c1, ot.subname c2, null, null, u.name, null c6, 
    o.lckflag n1, null n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    u.user# owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from sys.user$ u, sys.obj$ ot, 
       (select obj#, 
               decode(bitand(t.trigflag, 67108864), 0, 0, 1) +
               decode(bitand(t.trigflag, 134217728), 0, 0, 2) lckflag
        from tab$ t 
        where 
          (bitand(t.trigflag, 67108864) + bitand(t.trigflag, 134217728)) != 0
        union all
        select obj#, 
               decode(bitand(t.flags, 32), 0, 0, 1) +
               decode(bitand(t.flags, 64), 0, 0, 2) lckflag
        from tabpart$ t 
        where (bitand(t.flags, 32) + bitand(t.flags, 64)) != 0
        union all
        select obj#, 
               decode(bitand(t.flags, 32), 0, 0, 1) +
               decode(bitand(t.flags, 64), 0, 0, 2) lckflag
        from tabcompart$ t 
        where (bitand(t.flags, 32) + bitand(t.flags, 64)) != 0) o
  where
    ot.owner# = u.user# and
    ot.obj# = o.obj# 
  -- 
  -- Type D, Sql Plan Directives
  --
  -- #(22182203) Dynamic sampling result directive is supported only from
  -- 12.2. These type of directives and its objects are marked with
  -- correct DSC_COMPATIBLE values based on d.type.
  --
  -- We have 2 types of directives today
  --   DYNAMIC_SAMPLING (d.type is 1, supported since 12.1)
  --   DYNAMIC_SAMPLING_RESULT (d.type is 2, supported since 12.2)
  --
  union all
  select
    'D' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    null c1, null c2, null, null, to_char(d.dir_id) c5, null c6, 
    d.type n1, d.state n2, d.flags n3, f.type n4, f.reason n5, f.tab_cnt n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, to_clob(d.vc_one) cl1, null bl1,
    0 owner#,
    case when d.type = 1 then dbms_stats_internal.get_sc_1201
         else dbms_stats_internal.get_sc_1202 end min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from  opt_directive$ d, opt_finding$ f
  where d.f_id = f.f_id
  -- 
  -- Type O, Sql Plan Directive Objects
  -- This branch gives 12.1 version of SPD objects which does not
  -- get dynamic sampling result directive (see d.type = 1 predicate)
  --
  union all
  select
    'O' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    u.name c1, o.name c2, null, null, to_char(d.dir_id) c5, null c6, 
    o.type# n1, fo.flags n2, fo.nrows  n3, fo.obj_type  n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    0 owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_1202 max_sc
  from  sys.opt_directive$ d, opt_finding_obj$ fo, 
        (select obj#, owner#, type#, name from sys.obj$
         union all
         select object_id obj#, 0 owner#, 2 type#, name from  v$fixed_table) o,
        user$ u
  where d.f_id = fo.f_id and fo.f_obj# = o.obj# and o.owner# = u.user# and
  fo.obj_type = 1 and d.type = 1
  union all
  -- This branch gives 12.2 and above version of SPD objects
  select
    'O' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    u.name c1, o.name c2, null, null, to_char(d.dir_id) c5, null c6, 
    o.type# n1, fo.flags n2, fo.nrows  n3, fo.obj_type  n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    0 owner#, dbms_stats_internal.get_sc_1202 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from  sys.opt_directive$ d, opt_finding_obj$ fo, 
        (select obj#, owner#, type#, name from sys.obj$
         union all
         select object_id obj#, 0 owner#, 2 type#, name from  v$fixed_table) o,
        user$ u
  where d.f_id = fo.f_id and fo.f_obj# = o.obj# and o.owner# = u.user# and
  fo.obj_type = 1
  -- 
  -- Type O, Sql Plan Directive Objects - SQLID and SQLENV
  -- Applicable only for 12.2 and above
  --
  union all
  select
    'O' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    to_char(fo.f_obj#) c1, null c2, null, 
    null, to_char(d.dir_id) c5, null c6, 
    null n1, fo.flags n2, null  n3, fo.obj_type n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, null cl1, null bl1,
    0 owner#, dbms_stats_internal.get_sc_1202 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from  opt_directive$ d, opt_finding_obj$ fo 
  where d.f_id = fo.f_id and
    fo.obj_type in (4,5)
  -- 
  -- Type V, Sql Plan Directive Object columns
  --
  union all
  select
    'V' type,
    dbms_stats.get_stat_tab_version version,
    null flags,
    u.name c1, o.name c2, c.name c3, null, to_char(d.dir_id) c5, null c6, 
    o.type# n1, null n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    null d1, null t1,
    null r1, null r2, null r3, null ch1, 
    -- Store the expression of virtual columns for remap purpose
    --   0x00010000 =   65536 = virtual column
    --   0x0100     =     256 = system-generated column 
    --   0x0020     =      32 = hidden column
    decode(bitand(c.property, 65536+256+32), 65536+256+32,
           dbms_stats_internal.get_col_expr(c.rowidn, c.property), null) cl1,
    null bl1, 0 owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from opt_directive$ d,  "_BASE_OPT_FINDING_OBJ_COL" ft,
       (select obj#, owner#, type#, name from sys.obj$
         union all
         select object_id obj#, 0 owner#, 2 type#, name from  v$fixed_table) o,
       (select obj#, intcol#, name, rowid rowidn, property
        from sys.col$
        union all
        -- Virtual columns not allowed on fixed tables. So using null for 
        -- rowid and property
        select kqfcotob obj#, kqfcocno intcol#, kqfconam name, null rowidn,
               null property
        from sys.x$kqfco) c,
       user$ u 
  where d.f_id = ft.f_id and ft.f_obj# = o.obj# and
        o.owner# = u.user# and o.obj# = c.obj# and 
        ft.intcol# = c.intcol#
  -- 
  -- Type A, Global Preferences
  --
  union all
  select
    'A', dbms_stats.get_stat_tab_version,
    null flags,
    null c1, p.sname c2, null, null, null, null c6,
    p.sval1 n1, p.spare1 n2, null n3, null n4, null n5, null n6,
    null n7, null n8, null n9, null n10, null n11, null n12, null n13,
    p.sval2 d1, null t1, null r1, null r2, null r3, null ch1,
    to_clob(p.spare4) cl1, null bl1,
    0 owner#, dbms_stats_internal.get_sc_1201 min_sc, 
    dbms_stats_internal.get_sc_max max_sc
  from optstat_hist_control$ p
) v
where -- current user is owner
      v.owner# = SYS_CONTEXT('USERENV','CURRENT_USERID') or 
      -- Display Sql Plan Directives only if user has 
      -- Administer SQL Management Object privilege
      (type in ('D', 'O', 'V') and
       exists (select null from v$enabledprivs where priv_number = -327)) or
      -- object is owned by SYS and current user has ANALYZE ANY DICTIONARY
      -- privilege
      (type not in ('D', 'O', 'V') and v.owner# = 0 and  
       exists (select null from v$enabledprivs where priv_number = -262)) or
      -- object is NOT owned by SYS and current user has ANALYZE ANY
      (type not in ('D', 'O', 'V') and v.owner# != 0 and  -- ANALYZE ANY
       exists (select null from v$enabledprivs where priv_number = -165))
/

grant read on "_user_stat" to PUBLIC
/

-- Same as above view, except that the clob column is converted to a varray type.
-- clob reference over dblink is prohibited and hence the new view.
-- rti 18576172: b11 is a blob column. Seleting a remote persistent LOB, LOB
-- which corresponds to a table column, over a database link is fine. If 
-- the query on the remote returns a temporary LOB (temporary LOBs can be
-- generated by built in functions), we throw ORA-65503. bl1 is from
-- wri$_optstat_synopsis_head$.spare2. So it is fine to directly select
-- bl1.
create or replace view "_user_stat_varray"
(
  type,
  version,
  flags,
  c1, c2, c3, c4, c5, c6,
  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
  d1, 
  t1,
  r1, r2, r3,
  ch1,
  cl1, bl1, min_sc, max_sc) as
select   
  type,
  version,
  flags,
  c1, c2, c3, c4, c5, c6,
  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
  d1, 
  t1,
  r1, r2, r3,
  ch1,
  dbms_stats.clob_to_varray(cl1) cl1,
  bl1, min_sc, max_sc
from sys."_user_stat"
/

grant read on "_user_stat_varray" to PUBLIC
/

Rem
Rem Proj 47047: Views for expression usage tracking:
Rem ALL/DBA/USER_EXPRESSION_STATISTICS
Rem
Rem #(22895315) : definition changes of *_expression_statistics
Rem now includes a call to dbms_stats_internal package 
Rem and support WINDOW snapshot. 
Rem The reason *_expression_statistics definitions are moved  
Rem from cdoptim.sql to catost.sql is because dbms_stats_internal 
Rem package is not available when cdoptim script is run.  
Rem

CREATE OR REPLACE VIEW USER_EXPRESSION_STATISTICS
(TABLE_NAME, EXPRESSION_ID, SNAPSHOT, EVALUATION_COUNT, FIXED_COST,
 DYNAMIC_COST, EXPRESSION_TEXT, CREATED, LAST_MODIFIED) AS
select o.name, v.expid, decode(v.snapshot_id, 0, 'CUMULATIVE', 
                                              1, 'LATEST', 
                                              'WINDOW'),
       v.evaluation_count, h.fixed_cost,
       v.dynamic_cost, h.text, h.ctime, v.last_modified
from obj$ o, exp_head$ h, 
  -- latest expressions
  ((select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 1 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 1) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum)
  union all
  -- window expression if window capture mode is OPEN
  (select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 2 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 2) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum
  where dbms_stats_internal.check_window_capture_mode() = 1)
  union all
  -- window expressions if window capture mode is CLOSED
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count,
          dynamic_cost, last_modified
   from exp_stat$ where snapshot_id = 2 and 
        dbms_stats_internal.check_window_capture_mode() = 0)
  union all
  -- cumulative expressions
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count, 
          dynamic_cost, last_modified
  from exp_stat$ where snapshot_id = 0)) v
where v.objn = o.obj# and v.expid = h.exp_id
  and o.subname is null 
  -- checks for user privilege
  and o.owner# = userenv('SCHEMAID')
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym USER_EXPRESSION_STATISTICS for
USER_EXPRESSION_STATISTICS
/
grant read on USER_EXPRESSION_STATISTICS to PUBLIC with grant option
/
comment on table USER_EXPRESSION_STATISTICS is
'Expression Usage Tracking Statistics'
/
comment on column USER_EXPRESSION_STATISTICS.TABLE_NAME is
'Name of the table'
/
comment on column USER_EXPRESSION_STATISTICS.EXPRESSION_ID is
'Expression ID of the current expression'
/
comment on column USER_EXPRESSION_STATISTICS.SNAPSHOT is
'Type of Snapshot (cumulative, latest, or window) for the expression'
/
comment on column USER_EXPRESSION_STATISTICS.EVALUATION_COUNT is
'Number of times the expressions has been evaluated'
/
comment on column USER_EXPRESSION_STATISTICS.FIXED_COST is
'Optimizer Fixed Cost of evaluating the expression'
/
comment on column USER_EXPRESSION_STATISTICS.DYNAMIC_COST is
'Optimizer Dynamic Cost of evaluating the expression'
/
comment on column USER_EXPRESSION_STATISTICS.EXPRESSION_TEXT is
'Text of the expression'
/
comment on column USER_EXPRESSION_STATISTICS.CREATED is
'Time this expression is first evaluated'
/
comment on column USER_EXPRESSION_STATISTICS.LAST_MODIFIED is
'Time this expression is last evaluated'
/

CREATE OR REPLACE VIEW ALL_EXPRESSION_STATISTICS
(OWNER, TABLE_NAME, EXPRESSION_ID, SNAPSHOT, EVALUATION_COUNT, FIXED_COST,
 DYNAMIC_COST, EXPRESSION_TEXT, CREATED, LAST_MODIFIED) AS
select u.name, o.name, v.expid, decode(v.snapshot_id, 0, 'CUMULATIVE', 
                                                      1, 'LATEST', 
                                                      'WINDOW'),
       v.evaluation_count, h.fixed_cost,
       v.dynamic_cost, h.text, h.ctime, v.last_modified
from obj$ o, user$ u, exp_head$ h, 
  -- latest expressions
  ((select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 1 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 1) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum)
  union all
  -- window expression if window capture mode is OPEN
  (select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 2 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 2) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum
  where dbms_stats_internal.check_window_capture_mode() = 1)
  union all
  -- window expressions if window capture mode is CLOSED
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count,
          dynamic_cost, last_modified
   from exp_stat$ where snapshot_id = 2 and 
        dbms_stats_internal.check_window_capture_mode() = 0)
  union all
  -- cumulative expressions
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count, 
          dynamic_cost, last_modified
  from exp_stat$ where snapshot_id = 0)) v
where v.objn = o.obj# and v.expid = h.exp_id and o.owner# = u.user# 
  and o.subname is null 
  -- checks for privileges
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
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
create or replace public synonym ALL_EXPRESSION_STATISTICS for
ALL_EXPRESSION_STATISTICS
/
grant read on ALL_EXPRESSION_STATISTICS to PUBLIC with grant option
/
comment on table ALL_EXPRESSION_STATISTICS is
'Expression Usage Tracking Statistics'
/
comment on column ALL_EXPRESSION_STATISTICS.OWNER is
'Owner of the table'
/
comment on column ALL_EXPRESSION_STATISTICS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_EXPRESSION_STATISTICS.EXPRESSION_ID is
'Expression ID of the current expression'
/
comment on column ALL_EXPRESSION_STATISTICS.SNAPSHOT is
'Type of Snapshot (cumulative, latest or window) for the expression'
/
comment on column ALL_EXPRESSION_STATISTICS.EVALUATION_COUNT is
'Number of times the expressions has been evaluated'
/
comment on column ALL_EXPRESSION_STATISTICS.FIXED_COST is
'Optimizer Fixed Cost of evaluating the expression'
/
comment on column ALL_EXPRESSION_STATISTICS.DYNAMIC_COST is
'Optimizer Dynamic Cost of evaluating the expression'
/
comment on column ALL_EXPRESSION_STATISTICS.EXPRESSION_TEXT is
'Text of the expression'
/
comment on column ALL_EXPRESSION_STATISTICS.CREATED is
'Time this expression is first evaluated'
/
comment on column ALL_EXPRESSION_STATISTICS.LAST_MODIFIED is
'Time this expression is last evaluated'
/

CREATE OR REPLACE VIEW DBA_EXPRESSION_STATISTICS
(OWNER, TABLE_NAME, EXPRESSION_ID, SNAPSHOT, EVALUATION_COUNT, FIXED_COST,
 DYNAMIC_COST, EXPRESSION_TEXT, CREATED, LAST_MODIFIED) AS
select u.name, o.name, v.expid, decode(v.snapshot_id, 0, 'CUMULATIVE', 
                                                      1, 'LATEST', 
                                                      'WINDOW'),
       v.evaluation_count, h.fixed_cost,
       v.dynamic_cost, h.text, h.ctime, v.last_modified
from obj$ o, user$ u, exp_head$ h, 
  -- latest expressions
  ((select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 1 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 1) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum)
  union all
  -- window expression if window capture mode is OPEN
  (select nvl(ds.exp_id, ms.expid) expid, 
           nvl(ds.objn, ms.objnum) objn, 2 snapshot_id, 
           (nvl(ds.eval_count, 0) + nvl(ms.evalcnt, 0)) evaluation_count,
           nvl(ms.dyncost, ds.dynamic_cost) dynamic_cost,
           decode(ms.expid, null, ds.last_modified, systimestamp) last_modified
  from (select * from exp_stat$ where snapshot_id = 2) ds full outer join 
  (select expid, objnum, dyncost, evalcnt 
   from gv$exp_stats where evalcnt > 0) ms
  on ds.exp_id = ms.expid and ds.objn = ms.objnum
  where dbms_stats_internal.check_window_capture_mode() = 1)
  union all
  -- window expressions if window capture mode is CLOSED
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count,
          dynamic_cost, last_modified
   from exp_stat$ where snapshot_id = 2 and 
        dbms_stats_internal.check_window_capture_mode() = 0)
  union all
  -- cumulative expressions
  (select exp_id expid, objn, snapshot_id, eval_count evaluation_count, 
          dynamic_cost, last_modified
  from exp_stat$ where snapshot_id = 0)) v
where v.objn = o.obj# and v.expid = h.exp_id and o.owner# = u.user# 
  and o.subname is null 
  -- check for dba privileges
  and o.namespace = 1 and o.remoteowner IS NULL and o.linkname IS NULL
/
create or replace public synonym DBA_EXPRESSION_STATISTICS for
DBA_EXPRESSION_STATISTICS
/
grant read on DBA_EXPRESSION_STATISTICS to PUBLIC with grant option
/
comment on table DBA_EXPRESSION_STATISTICS is
'Expression Usage Tracking Statistics'
/
comment on column DBA_EXPRESSION_STATISTICS.OWNER is
'Owner of the table'
/
comment on column DBA_EXPRESSION_STATISTICS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_EXPRESSION_STATISTICS.EXPRESSION_ID is
'Expression ID of the current expression'
/
comment on column DBA_EXPRESSION_STATISTICS.SNAPSHOT is
'Type of Snapshot (cumulative, latest or window) for the expression'
/
comment on column DBA_EXPRESSION_STATISTICS.EVALUATION_COUNT is
'Number of times the expressions has been evaluated'
/
comment on column DBA_EXPRESSION_STATISTICS.FIXED_COST is
'Optimizer Fixed Cost of evaluating the expression'
/
comment on column DBA_EXPRESSION_STATISTICS.DYNAMIC_COST is
'Optimizer Dynamic Cost of evaluating the expression'
/
comment on column DBA_EXPRESSION_STATISTICS.EXPRESSION_TEXT is
'Text of the expression'
/
comment on column DBA_EXPRESSION_STATISTICS.CREATED is
'Time this expression is first evaluated'
/
comment on column DBA_EXPRESSION_STATISTICS.LAST_MODIFIED is
'Time this expression is last evaluated'
/

-- create CDB view
execute CDBView.create_cdbview(false,'SYS','DBA_EXPRESSION_STATISTICS','CDB_EXPRESSION_STATISTICS');
grant select on SYS.CDB_EXPRESSION_STATISTICS to select_catalog_role
/
create or replace public synonym CDB_EXPRESSION_STATISTICS for SYS.CDB_EXPRESSION_STATISTICS
/

Rem #(25463265): Create a new view SQT_TAB_STATISTICS, SQT_TAB_COL_STATISTICS,
Rem and SQT_CORRECT_BIT for statistics-based query transformation. 
Rem SQT_TAB_STATISTICS is a slimmed down version of ALL_TAB_STATISTICS, while
Rem SQT_TAB_COL_STATISTICS is a slimmed down version of ALL_TAB_COL_STATISTICS
Rem These views also have the same privilege checks as its ALL_* counterparts.
 
CREATE OR REPLACE VIEW SQT_TAB_STATISTICS
 (
  obj#,
  num_rows
  )
  AS
  SELECT
    t.obj#, t.rowcnt
  FROM
    sys.tab$ t, sys.obj$ o 
  WHERE 
        t.obj# = o.obj#
    and (o.owner# = userenv('SCHEMAID')
       or t.obj# in 
          (select oa.obj#
           FROM sys.objauth$ oa
           where grantee# in ( select kzsrorol
                               FROM x$kzsro
                             )
          )
       or 
       /* user has system privileges */
       exists (select null FROM v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -397/* READ ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)
             )) 
/
create or replace public synonym SQT_TAB_STATISTICS for SQT_TAB_STATISTICS
/
grant read on SQT_TAB_STATISTICS to PUBLIC with grant option
/
comment on table SQT_TAB_STATISTICS is
'Optimizer statistics for Statistics-based Query Transformation'
/
comment on column SQT_TAB_STATISTICS.OBJ# is
'Object number of the object'
/
comment on column SQT_TAB_STATISTICS.NUM_ROWS is
'The number of rows in the object'
/

CREATE OR REPLACE VIEW SQT_CORRECT_BIT
 (
  OBJ#,
  SPARE1
  )
  AS
  SELECT
    ts.obj#, ts.spare1
  FROM
    sys.tab_stats$ ts, sys.obj$ o
  WHERE
        ts.obj# = o.obj#
    and (o.owner# = userenv('SCHEMAID')
       or ts.obj# in 
          (select oa.obj#
           FROM sys.objauth$ oa
           where grantee# in ( select kzsrorol
                              FROM x$kzsro
                             )
          )
       or 
       /* user has system privileges */
       exists (select null FROM v$enabledprivs
               where priv_number in (-45 /* LOCK ANY TABLE */,
                                     -47 /* SELECT ANY TABLE */,
                                     -397/* READ ANY TABLE */,
                                     -48 /* INSERT ANY TABLE */,
                                     -49 /* UPDATE ANY TABLE */,
                                     -50 /* DELETE ANY TABLE */)
              )) 
/
create or replace public synonym SQT_CORRECT_BIT for SQT_CORRECT_BIT
/
grant read on SQT_CORRECT_BIT to PUBLIC with grant option
/
comment on table SQT_CORRECT_BIT is
'Optimizer Table for Correct Bit'
/
comment on column SQT_CORRECT_BIT.OBJ# is
'Object number of the object'
/
comment on column SQT_CORRECT_BIT.SPARE1 is
'The bit which determines whether stats is up to date with actual table'
/

create or replace view SQT_TAB_COL_STATISTICS
    (OBJ#, INTCOL#, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE, NUM_NULLS)
as
select h.obj#, h.intcol#, h.distcnt, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.lowval
            else null
       end, 
       case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
            then h.hival
            else null
       end, 
       h.null_cnt
from sys."_HIST_HEAD_DEC" h, sys.obj$ o
where
      h.obj# = o.obj#
  and (o.owner# = userenv('SCHEMAID')
     or h.obj# in
        (select oa.obj#
         FROM sys.objauth$ oa
         where grantee# in ( select kzsrorol
                             FROM x$kzsro
                           )
        )
     or 
     /* user has system privileges */
     exists (select null FROM v$enabledprivs
             where priv_number in (-45 /* LOCK ANY TABLE */,
                                   -47 /* SELECT ANY TABLE */,
                                   -397/* READ ANY TABLE */,
                                   -48 /* INSERT ANY TABLE */,
                                   -49 /* UPDATE ANY TABLE */,
                                   -50 /* DELETE ANY TABLE */)
            )) 
/
create or replace public synonym SQT_TAB_COL_STATISTICS for 
SQT_TAB_COL_STATISTICS
/
grant read on SQT_TAB_COL_STATISTICS to PUBLIC with grant option
/
comment on table SQT_TAB_COL_STATISTICS is
'Columns statistics of base tables for Statistics-based Query Transformation'
/
comment on column SQT_TAB_COL_STATISTICS.OBJ# is
'Object number of the object that contains the column'
/
comment on column SQT_TAB_COL_STATISTICS.INTCOL# is
'The column number identifier of the column'
/
comment on column SQT_TAB_COL_STATISTICS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column SQT_TAB_COL_STATISTICS.LOW_VALUE is
'The low value in the column'
/
comment on column SQT_TAB_COL_STATISTICS.HIGH_VALUE is
'The high value in the column'
/
comment on column SQT_TAB_COL_STATISTICS.NUM_NULLS is
'The number of nulls in the column'
/
@?/rdbms/admin/sqlsessend.sql
