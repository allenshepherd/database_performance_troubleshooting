Rem
Rem $Header: rdbms/admin/catawrpdbvw.sql /st_rdbms_18.0/3 2018/03/27 07:00:31 kmorfoni Exp $
Rem
Rem catawrpdbvw.sql
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catawrpdbvw.sql - Catalog script for AWR PDB Views
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR PDB Views. Used to create the  
Rem      Workload Repository Schema. 
Rem
Rem    NOTES
Rem        NOTE: these are temporary and later we change behaviour of
Rem              existing DBA hist views
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catawrpdbvw.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catawrpdbvw.sql
Rem SQL_PHASE: CATAWRPDBVW
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catawrtv.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni    03/22/18 - Backport kmorfoni_bug-27592466 from main
Rem    kmorfoni    02/23/18 - Bug 27592466: Mask ip_address in CLUSTER_INTERCON
Rem    kmorfoni    01/26/18 - Backport kmorfoni_bug-27259386 from
Rem                           st_rdbms_pt-dwcs
Rem    kmorfoni    01/24/18 - Bug 27435537: Mask program info in ASH
Rem    kmorfoni    01/05/18 - Bug 27346644: Mask machine info in ASH
Rem    kmorfoni    12/21/17 - Mask system data in AWR_PDB_DATABASE_INSTANCE
Rem    kmorfoni    11/06/17 - Mask/filter system data
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    kmorfoni    08/16/17 - Add begin_interval_time_tz, end_interval_time_tz
Rem                           to AWR_PDB_SNAPSHOT
Rem    quotran     07/27/17 - Bug 26526331: support AWR incremental flushing
Rem    yingzhen    07/18/17 - Bug 26405015 view mem_dynamic_comp not per PDB
Rem    cgervasi    06/23/17 - bug26338046: awr_pdb_disk_stat_summary
Rem    quotran     04/21/17 - Add im_db_block_changes_total[delta] to 
Rem                           wrh$_seg_stat
Rem    kmorfoni    04/18/17 - Add open_time_tz to AWR_PDB_PDB_IN_SNAP
Rem    kmorfoni    04/04/17 - Add snap_id in awr_pdb_pdb_instance
Rem    kmorfoni    03/24/17 - Add startup_time_tz, open_time_tz to
Rem                           wrm$_pdb_instance
Rem    quotran     03/21/17 - Bug 24845711: Deprecate awr_pdb_im_seg_stat*
Rem    cgervasi    02/27/17 - do not expose pmem columns
Rem    yingzhen    02/27/17 - Add awr_pdb_process_waittime view
Rem    quotran     01/16/17 - Bug 18204711: Add obsolete_count into
Rem                           wrh$_sqlstat
Rem    kmorfoni    12/20/16 - Add src_dbid, src_dbname to AWR_PDB_WR_CONTROL
Rem    cgervasi    11/16/16 - bug24952170: awr_pdb_cell_db add
Rem                           is_current_src_db flag
Rem    cgervasi    08/31/16 - bug24575927: dba_hist_asm_diskgroup_stat: add
Rem                           num_failgroups,state
Rem    yakagi      07/19/16 - bug 23756361: modify AWR_PDB_SEG_STAT
Rem    arbalakr    07/11/16 - Add is_instance_wide column to
Rem                           process_mem_summary views
Rem    quotran     06/27/16 - Add cdb_root_dbid into awr_pdb_database_instance
Rem    bsprunt     06/14/16 - bug 23255144: improve AWR_RSRC_PDB_METRIC view
Rem    kmorfoni    05/16/16 - Bug 23279437: remove con_id from AWR tables
Rem    yingzhen    05/03/16 - bug 22151899: Add Recovery Progress to AWR
Rem    cgervasi    05/06/16 - pmem disk support
Rem    osuro       05/03/16 - add awr_pdb_con_system_event
Rem    osuro       04/08/16 - rename awr_pdb_wr_settings owner_dbid column
Rem    bsprunt     04/04/16 - Bug 23041882: add AVG_CPU_UTILIZATION column
Rem                           to AWR_PDB_RSRC_[PDB_]METRIC
Rem    bsprunt     04/04/16 - Bug 22782461: do not filter with con_dbid_to_id()
Rem    quotran     03/03/16 - Add cdb,edition,db_unique_name,database_role to
Rem                           awr_pdb_database_instance
Rem    kmorfoni    03/01/16 - add con_id column in AWR tables without con_dbid
Rem    tltang      02/25/16 - Bug 22524017: Add IN_TABLESPACE_ENCRYPTION
Rem    ardesai     01/05/16 - added con_id column
Rem    bsprunt     02/16/16 - Bug 22650421: plan name DBA_HIST_RSRC_PDB_METRIC
Rem    osuro       02/12/16 - Add AWR_PDB_WR_SETTINGS view
Rem    bsprunt     02/04/16 - Bug 22011870: WRH$_RSRC_[PDB_]METRIC columns
Rem    yingzhen    02/02/16 - Bug 20421055, remove CDBR_HIST, CDBP_HIST views
Rem                           Create CDB_HIST views on top of AWR_PDB views
Rem    drosash     12/01/15 - Bug 22294834: Eliminate join with ts$ from
Rem                           awr view definitions
Rem    yingzhen    11/12/15 - Bug 22176929: Add view_location to wr_control
Rem    aikumar     11/03/15 - bug 21866774: Add/remove columns from
Rem                           PDBA_HIST_RSRC_PDB_METRIC
Rem    yingzhen    10/30/15 - Modify AWR_PDB_TEMPFILE, _TABLESPACE_STAT
Rem    yingzhen    10/21/15 - add AWR_PDB_CON_SYSSTAT views
Rem    osuro       10/08/15 - Bug 21861010: Fix con_id in AWR CON_* views
Rem    yingzhen    08/17/15 - Rename AWR_PDB views to awr_pdb
Rem    osuro       09/03/15 - add AWR_PDB_CON_SYS_TIME_MODEL views
Rem    bsprunt     08/26/15 - Bug 21652015: add instance_caging column
Rem    bsprunt     08/21/15 - Bug 21460115: DBA_HIST_RSRC_[PDB_]METRIC views
Rem    osuro       08/05/15 - add AWR_PDB_CON_SYSMETRIC_* views
Rem    cgervasi    07/07/15 - add cell_db time-related columns
Rem    arbalakr    05/13/15 - Enable ASH flush inside a PDB
Rem    yingzhen    05/27/15 - Bug 20802034: flush v$channel_waits
Rem    suelee      04/29/15 - Bug 20898764: PGA limit
Rem    bsprunt     04/16/15 - Bug 15931539: add missing fields to
Rem                           DBA_HIST_RSRC_CONSUMER_GROUP
Rem    amorimur    01/05/15 - modify CR/CURRENT_BLOCK_SERVER, add LMS_STATS
Rem    ardesai     12/14/14 - DBA hist views to get the data from PDB SYSAUX
Rem                           space
Rem    ardesai     09/26/14 - Created
Rem


/* Implement the convention that instance-wide stat views get a con_id of 0 */
define KEWR_INSTSTAT_CONID = 0; 

@@?/rdbms/admin/sqlsessstart.sql

Rem ************************************************************************* 
Rem Creating the Workload Repository History (AWR_PDB) Catalog Views ...
Rem ************************************************************************* 

/***************************************
 *     AWR_PDB_DATABASE_INSTANCE
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_DBINST_HOSTNM SDM_TYPE MASK_ALL '' 'host_name'

create or replace view AWR_PDB_DATABASE_INSTANCE
  (DBID, INSTANCE_NUMBER, STARTUP_TIME, PARALLEL, VERSION, 
   DB_NAME, INSTANCE_NAME, HOST_NAME, LAST_ASH_SAMPLE_ID, 
   PLATFORM_NAME, CDB, EDITION, DB_UNIQUE_NAME, 
   DATABASE_ROLE, CDB_ROOT_DBID,
   CON_ID, STARTUP_TIME_TZ)
as
select dbid, instance_number, startup_time, parallel, version, 
       db_name, instance_name,
       &KEWR_MASK_DBINST_HOSTNM, -- Use macro to mask sensitive column
       last_ash_sample_id,
       platform_name, cdb, edition, db_unique_name, 
       database_role, cdb_root_dbid,
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id,
       startup_time_tz
from WRM$_DATABASE_INSTANCE
/

comment on table AWR_PDB_DATABASE_INSTANCE is
'Database Instance Information'
/
create or replace public synonym AWR_PDB_DATABASE_INSTANCE 
    for AWR_PDB_DATABASE_INSTANCE
/
grant select on AWR_PDB_DATABASE_INSTANCE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SNAPSHOT
 ***************************************/

/* only the valid snapshots (status = 0) will be displayed) */
create or replace view AWR_PDB_SNAPSHOT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STARTUP_TIME, 
   BEGIN_INTERVAL_TIME, END_INTERVAL_TIME,
   FLUSH_ELAPSED, SNAP_LEVEL, ERROR_COUNT, SNAP_FLAG, SNAP_TIMEZONE,
   BEGIN_INTERVAL_TIME_TZ, END_INTERVAL_TIME_TZ,
   CON_ID)
as
select snap_id, dbid, instance_number, startup_time, 
       begin_interval_time, end_interval_time,
       flush_elapsed, snap_level, error_count, snap_flag, snap_timezone,
       begin_interval_time_tz, end_interval_time_tz,
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRM$_SNAPSHOT
where status = 0;
/

comment on table AWR_PDB_SNAPSHOT is
'Snapshot Information'
/
create or replace public synonym AWR_PDB_SNAPSHOT 
    for AWR_PDB_SNAPSHOT
/
grant select on AWR_PDB_SNAPSHOT to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SNAP_ERROR
 ***************************************/

/* shows error information for each snapshot */
create or replace view AWR_PDB_SNAP_ERROR
  (SNAP_ID, DBID, INSTANCE_NUMBER, TABLE_NAME, ERROR_NUMBER, STEP_ID, CON_ID)
as select snap_id, dbid, instance_number, table_name, error_number, step_id,
          decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from wrm$_snap_error;
/
comment on table AWR_PDB_SNAP_ERROR is
'Snapshot Error Information'
/
create or replace public synonym AWR_PDB_SNAP_ERROR
    for AWR_PDB_SNAP_ERROR
/
grant select on AWR_PDB_SNAP_ERROR to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_COLORED_SQL
 ***************************************/

/* shows list of colored SQL IDs */
create or replace view AWR_PDB_COLORED_SQL
  (dbid, sql_id, create_time, CON_ID)
as select dbid, sql_id, create_time,
          decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from wrm$_colored_sql where owner = 1;
/
comment on table AWR_PDB_COLORED_SQL is
'Marked SQLs for snapshots'
/
create or replace public synonym AWR_PDB_COLORED_SQL
    for AWR_PDB_COLORED_SQL
/
grant select on AWR_PDB_COLORED_SQL to SELECT_CATALOG_ROLE
/



/***************************************
 *    AWR_PDB_BASELINE_METADATA
 ***************************************/
create or replace view AWR_PDB_BASELINE_METADATA
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, end_snap_id, moving_window_size, 
   creation_time, expiration, template_name,
   last_time_computed, CON_ID)
as
select dbid, baseline_id, 
       baseline_name, baseline_type,
       start_snap_id, end_snap_id,
       moving_window_size, creation_time,
       expiration, template_name, last_time_computed,
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from
  WRM$_BASELINE
/
comment on table AWR_PDB_BASELINE_METADATA is
'Baseline Metadata Information'
/
create or replace public synonym AWR_PDB_BASELINE_METADATA
    for AWR_PDB_BASELINE_METADATA
/
grant select on AWR_PDB_BASELINE_METADATA to SELECT_CATALOG_ROLE
/



/************************************
 *   AWR_PDB_BASELINE_TEMPLATE
 ************************************/

create or replace view AWR_PDB_BASELINE_TEMPLATE
  (dbid, template_id, template_name, template_type,
   baseline_name_prefix, start_time, end_time,
   day_of_week, hour_in_day, duration,
   expiration, repeat_interval, last_generated, CON_ID)
as
select dbid, template_id, template_name, template_type,
       baseline_name_prefix, start_time, end_time,
       day_of_week, hour_in_day, duration,
       expiration, repeat_interval, last_generated,
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from
  WRM$_BASELINE_TEMPLATE
/
comment on table AWR_PDB_BASELINE_TEMPLATE is
'Baseline Template Information'
/
create or replace public synonym AWR_PDB_BASELINE_TEMPLATE
    for AWR_PDB_BASELINE_TEMPLATE
/
grant select on AWR_PDB_BASELINE_TEMPLATE to SELECT_CATALOG_ROLE
/




/***************************************
 *       AWR_PDB_WR_CONTROL
 ***************************************/

create or replace view AWR_PDB_WR_CONTROL
  (DBID, SNAP_INTERVAL, RETENTION, TOPNSQL, CON_ID, SRC_DBID, SRC_DBNAME)
as
select dbid, snap_interval, retention, 
       decode(topnsql, 2000000000, 'DEFAULT', 
                       2000000001, 'MAXIMUM',
                       to_char(topnsql, '999999999')) topnsql,
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id,
       decode(src_dbid, 0, dbid, src_dbid) src_dbid,
       src_dbname
from WRM$_WR_CONTROL
/
comment on table AWR_PDB_WR_CONTROL is
'Workload Repository Control Information'
/
create or replace public synonym AWR_PDB_WR_CONTROL 
    for AWR_PDB_WR_CONTROL
/
grant select on AWR_PDB_WR_CONTROL to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_TABLESPACE
 ***************************************/

create or replace view AWR_PDB_TABLESPACE
  (DBID, TS#, TSNAME, CONTENTS, SEGMENT_SPACE_MANAGEMENT, 
   EXTENT_MANAGEMENT, BLOCK_SIZE, CON_DBID, CON_ID)
as
select tbs.dbid, tbs.ts#, tbs.tsname, tbs.contents, 
       tbs.segment_space_management, tbs.extent_management, tbs.block_size,
       decode(tbs.con_dbid, 0, tbs.dbid, tbs.con_dbid), 
       decode(tbs.per_pdb, 0, 0,
         con_dbid_to_id(
           decode(tbs.con_dbid, 0, tbs.dbid, tbs.con_dbid))) con_id 
  from WRH$_TABLESPACE tbs
/

comment on table AWR_PDB_TABLESPACE is
  'Tablespace Static Information'
/
create or replace public synonym AWR_PDB_TABLESPACE
    for AWR_PDB_TABLESPACE
/
grant select on AWR_PDB_TABLESPACE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_DATAFILE
 ***************************************/


create or replace view AWR_PDB_DATAFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE, CON_DBID, CON_ID) 
as
select d.dbid, d.file#, d.creation_change#,
       d.filename, d.ts#, coalesce(t.tsname, d.tsname) tsname, d.block_size,
       decode(d.con_dbid, 0, d.dbid, d.con_dbid), 
       decode(d.per_pdb, 0, 0,
         con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id 
from WRH$_DATAFILE d LEFT OUTER JOIN WRH$_TABLESPACE t 
     on (d.dbid = t.dbid
         and d.ts# = t.ts# 
         and d.con_dbid = t.con_dbid)
/
comment on table AWR_PDB_DATAFILE is
'Names of Datafiles'
/
create or replace public synonym AWR_PDB_DATAFILE for AWR_PDB_DATAFILE
/
grant select on AWR_PDB_DATAFILE to SELECT_CATALOG_ROLE
/




/*****************************************
 *        AWR_PDB_FILESTATXS
 *****************************************/
create or replace view AWR_PDB_FILESTATXS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME, OPTIMIZED_PHYBLKRD,
   CON_DBID, CON_ID ) 
as
select f.snap_id, f.dbid, f.instance_number, 
       f.file#, f.creation_change#, d.filename, 
       d.ts#, coalesce(t.tsname, d.tsname) tsname, d.block_size,
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time, 
       optimized_phyblkrd, decode(f.con_dbid, 0, f.dbid, f.con_dbid),
       decode(f.per_pdb, 0, 0,
         con_dbid_to_id(decode(f.con_dbid, 0, f.dbid, f.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_FILESTATXS f, WRH$_DATAFILE d, WRH$_TABLESPACE t
where      f.dbid             = d.dbid
      and  f.file#            = d.file#
      and  f.creation_change# = d.creation_change#
      and  f.snap_id          = sn.snap_id
      and  f.dbid             = sn.dbid
      and  f.instance_number  = sn.instance_number
      and  f.con_dbid         = d.con_dbid
      and  d.dbid             = t.dbid(+)
      and  d.ts#              = t.ts#(+)
      and  d.con_dbid         = t.con_dbid(+)
/

comment on table AWR_PDB_FILESTATXS is
'Datafile Historical Statistics Information'
/
create or replace public synonym AWR_PDB_FILESTATXS for AWR_PDB_FILESTATXS
/
grant select on AWR_PDB_FILESTATXS to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_TEMPFILE
 ***************************************/

create or replace view AWR_PDB_TEMPFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE, CON_DBID, CON_ID)
as
select d.dbid, d.file#, d.creation_change#, 
       d.filename, d.ts#, coalesce(t.tsname, d.tsname) tsname, d.block_size,
       decode(d.con_dbid, 0, d.dbid, d.con_dbid), 
       decode(d.per_pdb, 0, 0,
         con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id
from WRH$_TEMPFILE d LEFT OUTER JOIN WRH$_TABLESPACE t
     on (d.dbid = t.dbid
         and d.ts# = t.ts# 
         and d.con_dbid = t.con_dbid)
/
comment on table AWR_PDB_TEMPFILE is
'Names of Temporary Datafiles'
/
create or replace public synonym AWR_PDB_TEMPFILE for AWR_PDB_TEMPFILE
/
grant select on AWR_PDB_TEMPFILE to SELECT_CATALOG_ROLE
/




/*****************************************
 *        AWR_PDB_TEMPSTATXS
 *****************************************/
create or replace view AWR_PDB_TEMPSTATXS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME, CON_DBID, CON_ID) 
as
select t.snap_id, t.dbid, t.instance_number, 
       t.file#, t.creation_change#, d.filename, 
       d.ts#, coalesce(z.tsname, d.tsname) tsname, d.block_size, 
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time,
       decode(t.con_dbid, 0, t.dbid, t.con_dbid), 
       decode(t.per_pdb, 0, 0,
         con_dbid_to_id(decode(t.con_dbid, 0, t.dbid, t.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_TEMPSTATXS t, WRH$_TEMPFILE d, WRH$_TABLESPACE z
where     t.dbid             = d.dbid
      and t.file#            = d.file#
      and t.creation_change# = d.creation_change#
      and t.con_dbid         = d.dbid
      and sn.snap_id         = t.snap_id
      and sn.dbid            = t.dbid
      and sn.instance_number = t.instance_number
      and d.dbid             = z.dbid(+)
      and d.ts#              = z.ts#(+)
      and d.con_dbid         = z.con_dbid(+)
/

comment on table AWR_PDB_TEMPSTATXS is
'Temporary Datafile Historical Statistics Information'
/
create or replace public synonym AWR_PDB_TEMPSTATXS for AWR_PDB_TEMPSTATXS
/
grant select on AWR_PDB_TEMPSTATXS to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_COMP_IOSTAT
 ***************************************/

create or replace view AWR_PDB_COMP_IOSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, COMPONENT, 
   FILE_TYPE, IO_TYPE, OPERATION, BYTES, IO_COUNT, CON_DBID, CON_ID)
as
select io.snap_id, io.dbid, io.instance_number, io.component,
       io.file_type, io.io_type, io.operation, io.bytes, io.io_count,
       decode(io.con_dbid, 0, io.dbid, io.con_dbid),
       decode(io.per_pdb, 0, 0,
         con_dbid_to_id(decode(io.con_dbid, 0, io.dbid, io.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_COMP_IOSTAT io
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
/
comment on table AWR_PDB_COMP_IOSTAT is
'I/O stats aggregated on component level'
/
create or replace public synonym AWR_PDB_COMP_IOSTAT 
  for AWR_PDB_COMP_IOSTAT
/
grant select on AWR_PDB_COMP_IOSTAT to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SQLSTAT
 ***************************************/

create or replace view AWR_PDB_SQLSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SQL_ID, PLAN_HASH_VALUE, 
   OPTIMIZER_COST, OPTIMIZER_MODE, OPTIMIZER_ENV_HASH_VALUE,
   SHARABLE_MEM, LOADED_VERSIONS, VERSION_COUNT,
   MODULE, ACTION,
   SQL_PROFILE, FORCE_MATCHING_SIGNATURE, 
   PARSING_SCHEMA_ID, PARSING_SCHEMA_NAME, PARSING_USER_ID, 
   FETCHES_TOTAL, FETCHES_DELTA, 
   END_OF_FETCH_COUNT_TOTAL, END_OF_FETCH_COUNT_DELTA,
   SORTS_TOTAL, SORTS_DELTA, 
   EXECUTIONS_TOTAL, EXECUTIONS_DELTA, 
   PX_SERVERS_EXECS_TOTAL, PX_SERVERS_EXECS_DELTA, 
   LOADS_TOTAL, LOADS_DELTA, 
   INVALIDATIONS_TOTAL, INVALIDATIONS_DELTA,
   PARSE_CALLS_TOTAL, PARSE_CALLS_DELTA, DISK_READS_TOTAL, 
   DISK_READS_DELTA, BUFFER_GETS_TOTAL, BUFFER_GETS_DELTA,
   ROWS_PROCESSED_TOTAL, ROWS_PROCESSED_DELTA, CPU_TIME_TOTAL,
   CPU_TIME_DELTA, ELAPSED_TIME_TOTAL, ELAPSED_TIME_DELTA,
   IOWAIT_TOTAL, IOWAIT_DELTA, CLWAIT_TOTAL, CLWAIT_DELTA,
   APWAIT_TOTAL, APWAIT_DELTA, CCWAIT_TOTAL, CCWAIT_DELTA,
   DIRECT_WRITES_TOTAL, DIRECT_WRITES_DELTA, PLSEXEC_TIME_TOTAL,
   PLSEXEC_TIME_DELTA, JAVEXEC_TIME_TOTAL, JAVEXEC_TIME_DELTA,
   IO_OFFLOAD_ELIG_BYTES_TOTAL, IO_OFFLOAD_ELIG_BYTES_DELTA,
   IO_INTERCONNECT_BYTES_TOTAL, IO_INTERCONNECT_BYTES_DELTA,
   PHYSICAL_READ_REQUESTS_TOTAL, PHYSICAL_READ_REQUESTS_DELTA,
   PHYSICAL_READ_BYTES_TOTAL, PHYSICAL_READ_BYTES_DELTA,
   PHYSICAL_WRITE_REQUESTS_TOTAL, PHYSICAL_WRITE_REQUESTS_DELTA,
   PHYSICAL_WRITE_BYTES_TOTAL, PHYSICAL_WRITE_BYTES_DELTA,
   OPTIMIZED_PHYSICAL_READS_TOTAL, OPTIMIZED_PHYSICAL_READS_DELTA,
   CELL_UNCOMPRESSED_BYTES_TOTAL, CELL_UNCOMPRESSED_BYTES_DELTA,
   IO_OFFLOAD_RETURN_BYTES_TOTAL, IO_OFFLOAD_RETURN_BYTES_DELTA,
   BIND_DATA, FLAG, OBSOLETE_COUNT, CON_DBID, CON_ID)
as
select sql.snap_id, sql.dbid, sql.instance_number,
       sql_id, plan_hash_value, 
       optimizer_cost, optimizer_mode, optimizer_env_hash_value,
       sharable_mem, loaded_versions, version_count,
       substrb(module,1,(select ksumodlen from x$modact_length)) module, 
       substrb(action,1,(select ksuactlen from x$modact_length)) action,
       sql_profile, force_matching_signature, 
       parsing_schema_id, parsing_schema_name, parsing_user_id,
       fetches_total, fetches_delta, 
       end_of_fetch_count_total, end_of_fetch_count_delta,
       sorts_total, sorts_delta, 
       executions_total, executions_delta, 
       px_servers_execs_total, px_servers_execs_delta, 
       loads_total, loads_delta, 
       invalidations_total, invalidations_delta,
       parse_calls_total, parse_calls_delta, disk_reads_total, 
       disk_reads_delta, buffer_gets_total, buffer_gets_delta,
       rows_processed_total, rows_processed_delta, cpu_time_total,
       cpu_time_delta, elapsed_time_total, elapsed_time_delta,
       iowait_total, iowait_delta, clwait_total, clwait_delta,
       apwait_total, apwait_delta, ccwait_total, ccwait_delta,
       direct_writes_total, direct_writes_delta, plsexec_time_total,
       plsexec_time_delta, javexec_time_total, javexec_time_delta,
       io_offload_elig_bytes_total, io_offload_elig_bytes_delta,
       io_interconnect_bytes_total, io_interconnect_bytes_delta,
       physical_read_requests_total, physical_read_requests_delta,
       physical_read_bytes_total, physical_read_bytes_delta,
       physical_write_requests_total, physical_write_requests_delta,
       physical_write_bytes_total, physical_write_bytes_delta,
       optimized_physical_reads_total, optimized_physical_reads_delta,
       cell_uncompressed_bytes_total, cell_uncompressed_bytes_delta,
       io_offload_return_bytes_total, io_offload_return_bytes_delta, 
       bind_data, sql.flag, obsolete_count,
       decode(sql.con_dbid, 0, sql.dbid, sql.con_dbid),
       decode(sql.per_pdb, 0, 0,
         con_dbid_to_id(decode(sql.con_dbid, 0, sql.dbid, sql.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SQLSTAT sql
  where     sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
/

comment on table AWR_PDB_SQLSTAT is
'SQL Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SQLSTAT for AWR_PDB_SQLSTAT
/
grant select on AWR_PDB_SQLSTAT to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SQLTEXT
 ***************************************/

create or replace view AWR_PDB_SQLTEXT
  (DBID, SQL_ID, SQL_TEXT, COMMAND_TYPE, CON_DBID, CON_ID)
as
select dbid, sql_id, sql_text, command_type,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
from WRH$_SQLTEXT
/
comment on table AWR_PDB_SQLTEXT is
'SQL Text'
/
create or replace public synonym AWR_PDB_SQLTEXT for AWR_PDB_SQLTEXT
/
grant select on AWR_PDB_SQLTEXT to SELECT_CATALOG_ROLE
/




/***************************************
 *       AWR_PDB_SQL_SUMMARY
 ***************************************/

create or replace view AWR_PDB_SQL_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, TOTAL_SQL, TOTAL_SQL_MEM,
   SINGLE_USE_SQL, SINGLE_USE_SQL_MEM, CON_DBID, CON_ID)
as
select ss.snap_id, ss.dbid, ss.instance_number, 
       total_sql, total_sql_mem,
       single_use_sql, single_use_sql_mem,
       decode(ss.con_dbid, 0, ss.dbid, ss.con_dbid),
       decode(ss.per_pdb, 0, 0,
         con_dbid_to_id(decode(ss.con_dbid, 0, ss.dbid, ss.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SQL_SUMMARY ss
where     sn.snap_id         = ss.snap_id
      and sn.dbid            = ss.dbid
      and sn.instance_number = ss.instance_number
/

comment on table AWR_PDB_SQL_SUMMARY is
'Summary of SQL Statistics'
/
create or replace public synonym AWR_PDB_SQL_SUMMARY 
   for AWR_PDB_SQL_SUMMARY
/
grant select on AWR_PDB_SQL_SUMMARY to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_SQL_PLAN
 ***************************************/

create or replace view AWR_PDB_SQL_PLAN
  (DBID, SQL_ID, PLAN_HASH_VALUE, ID, OPERATION, OPTIONS,
   OBJECT_NODE, OBJECT#, OBJECT_OWNER, OBJECT_NAME,
   OBJECT_ALIAS, OBJECT_TYPE, OPTIMIZER,
   PARENT_ID, DEPTH, POSITION, SEARCH_COLUMNS, COST, CARDINALITY,
   BYTES, OTHER_TAG, PARTITION_START, PARTITION_STOP, PARTITION_ID,
   OTHER, DISTRIBUTION, CPU_COST, IO_COST, TEMP_SPACE, 
   ACCESS_PREDICATES, FILTER_PREDICATES,
   PROJECTION, TIME, QBLOCK_NAME, REMARKS, TIMESTAMP, OTHER_XML,
   CON_DBID, CON_ID)
as
select dbid, sql_id, plan_hash_value, id, operation, options,
       object_node, object#, object_owner, object_name, 
       object_alias, object_type, optimizer,
       parent_id, depth, position, search_columns, cost, cardinality,
       bytes, other_tag, partition_start, partition_stop, partition_id,
       other, distribution, cpu_cost, io_cost, temp_space, 
       access_predicates, filter_predicates,
       projection, time, qblock_name, remarks, timestamp, other_xml,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
from WRH$_SQL_PLAN
/
comment on table AWR_PDB_SQL_PLAN is
'SQL Plan Information'
/
create or replace public synonym AWR_PDB_SQL_PLAN for AWR_PDB_SQL_PLAN
/
grant select on AWR_PDB_SQL_PLAN to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SQL_BIND_METADATA
 ***************************************/

create or replace view AWR_PDB_SQL_BIND_METADATA
  (DBID, SQL_ID, NAME, POSITION, DUP_POSITION, 
   DATATYPE, DATATYPE_STRING, 
   CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, CON_DBID, CON_ID)
as
select dbid, sql_id, name, position, dup_position, 
       datatype, datatype_string, 
       character_sid, precision, scale, max_length,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_SQL_BIND_METADATA 
/

comment on table AWR_PDB_SQL_BIND_METADATA is
'SQL Bind Metadata Information'
/
create or replace public synonym AWR_PDB_SQL_BIND_METADATA 
  for AWR_PDB_SQL_BIND_METADATA
/
grant select on AWR_PDB_SQL_BIND_METADATA to SELECT_CATALOG_ROLE
/



/***************************************
 *      AWR_PDB_OPTIMIZER_ENV
 ***************************************/

create or replace view AWR_PDB_OPTIMIZER_ENV
  (DBID, OPTIMIZER_ENV_HASH_VALUE, OPTIMIZER_ENV, CON_DBID, CON_ID)
as
select dbid, optimizer_env_hash_value, optimizer_env, 
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
from WRH$_OPTIMIZER_ENV
/
comment on table AWR_PDB_OPTIMIZER_ENV is
'Optimizer Environment Information'
/
create or replace public synonym AWR_PDB_OPTIMIZER_ENV 
   for AWR_PDB_OPTIMIZER_ENV
/
grant select on AWR_PDB_OPTIMIZER_ENV to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_EVENT_NAME
 ***************************************/

create or replace view AWR_PDB_EVENT_NAME
  (DBID, EVENT_ID, EVENT_NAME, PARAMETER1, PARAMETER2, PARAMETER3, 
   WAIT_CLASS_ID, WAIT_CLASS, CON_DBID, CON_ID)
as
select dbid, event_id, event_name, parameter1, parameter2, parameter3, 
       wait_class_id, wait_class,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from WRH$_EVENT_NAME
/

comment on table AWR_PDB_EVENT_NAME is
'Event Names'
/
create or replace public synonym AWR_PDB_EVENT_NAME for AWR_PDB_EVENT_NAME
/
grant select on AWR_PDB_EVENT_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_SYSTEM_EVENT
 ***************************************/

create or replace view AWR_PDB_SYSTEM_EVENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO,
   TOTAL_WAITS_FG, TOTAL_TIMEOUTS_FG, TIME_WAITED_MICRO_FG, CON_DBID, CON_ID)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro,
       total_waits_fg, total_timeouts_fg, time_waited_micro_fg,
       decode(e.con_dbid, 0, e.dbid, e.con_dbid), 
       con_dbid_to_id(decode(e.con_dbid, 0, e.dbid, e.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SYSTEM_EVENT e, WRH$_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
/

comment on table AWR_PDB_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SYSTEM_EVENT 
    for AWR_PDB_SYSTEM_EVENT
/
grant select on AWR_PDB_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_CON_SYSTEM_EVENT
 ***************************************/

create or replace view AWR_PDB_CON_SYSTEM_EVENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO,
   TOTAL_WAITS_FG, TOTAL_TIMEOUTS_FG, TIME_WAITED_MICRO_FG, CON_DBID, CON_ID)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro,
       total_waits_fg, total_timeouts_fg, time_waited_micro_fg,
       e.con_dbid,
       con_dbid_to_id(decode(e.con_dbid, 0, e.dbid, e.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_CON_SYSTEM_EVENT e, WRH$_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
/

comment on table AWR_PDB_CON_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym AWR_PDB_CON_SYSTEM_EVENT 
    for AWR_PDB_CON_SYSTEM_EVENT
/
grant select on AWR_PDB_CON_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_BG_EVENT_SUMMARY
 ***************************************/

create or replace view AWR_PDB_BG_EVENT_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO, CON_DBID, CON_ID) 
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro,
       decode(e.con_dbid, 0, e.dbid, e.con_dbid), 
       decode(e.per_pdb, 0, 0,
         con_dbid_to_id(decode(e.con_dbid, 0, e.dbid, e.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_BG_EVENT_SUMMARY e, WRH$_EVENT_NAME en
where     sn.snap_id         = e.snap_id
      and sn.dbid            = e.dbid
      and sn.instance_number = e.instance_number
      and e.event_id         = en.event_id
      and e.dbid             = en.dbid
/

comment on table AWR_PDB_BG_EVENT_SUMMARY is
'Summary of Background Event Historical Statistics Information'
/
create or replace public synonym AWR_PDB_BG_EVENT_SUMMARY 
   for AWR_PDB_BG_EVENT_SUMMARY
/
grant select on AWR_PDB_BG_EVENT_SUMMARY to SELECT_CATALOG_ROLE
/




/***************************************
 *       AWR_PDB_CHANNEL_WAITS
 ***************************************/

create or replace view AWR_PDB_CHANNEL_WAITS
  (SNAP_ID, DBID, INSTANCE_NUMBER, CHANNEL, MESSAGES_PUBLISHED,
   WAIT_COUNT, WAIT_TIME_USEC, CON_DBID, CON_ID)
as
select cw.snap_id, cw.dbid, cw.instance_number,
       channel, messages_published, wait_count, wait_time_usec,
       decode(cw.con_dbid, 0, cw.dbid, cw.con_dbid), 
       decode(cw.per_pdb, 0, 0,
         con_dbid_to_id(decode(cw.con_dbid, 0, cw.dbid, cw.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_CHANNEL_WAITS cw
  where     sn.snap_id         = cw.snap_id
        and sn.dbid            = cw.dbid
        and sn.instance_number = cw.instance_number
/

comment on table AWR_PDB_CHANNEL_WAITS is
'Channel Waits Information'
/
create or replace public synonym AWR_PDB_CHANNEL_WAITS for AWR_PDB_CHANNEL_WAITS
/
grant select on AWR_PDB_CHANNEL_WAITS to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_WAITSTAT
 ***************************************/

create or replace view AWR_PDB_WAITSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, CLASS,
   WAIT_COUNT, TIME, CON_DBID, CON_ID) 
as
select wt.snap_id, wt.dbid, wt.instance_number, 
       class, wait_count, time,
       decode(wt.con_dbid, 0, wt.dbid, wt.con_dbid), 
       decode(wt.per_pdb, 0, 0,
         con_dbid_to_id(decode(wt.con_dbid, 0, wt.dbid, wt.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_WAITSTAT wt
  where     sn.snap_id         = wt.snap_id
        and sn.dbid            = wt.dbid
        and sn.instance_number = wt.instance_number
/

comment on table AWR_PDB_WAITSTAT is
'Wait Historical Statistics Information'
/
create or replace public synonym AWR_PDB_WAITSTAT for AWR_PDB_WAITSTAT
/
grant select on AWR_PDB_WAITSTAT to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_ENQUEUE_STAT
 ***************************************/

create or replace view AWR_PDB_ENQUEUE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, EQ_TYPE, REQ_REASON, TOTAL_REQ#,
   TOTAL_WAIT#, SUCC_REQ#, FAILED_REQ#, CUM_WAIT_TIME, EVENT#,
   CON_DBID, CON_ID) 
as
select eq.snap_id, eq.dbid, eq.instance_number, 
       eq_type, req_reason, total_req#,
       total_wait#, succ_req#, failed_req#, cum_wait_time, event#,
       decode(eq.con_dbid, 0, eq.dbid, eq.con_dbid), 
       decode(eq.per_pdb, 0, 0,
         con_dbid_to_id(decode(eq.con_dbid, 0, eq.dbid, eq.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_ENQUEUE_STAT eq
  where     sn.snap_id         = eq.snap_id
        and sn.dbid            = eq.dbid
        and sn.instance_number = eq.instance_number
/

comment on table AWR_PDB_ENQUEUE_STAT is
'Enqueue Historical Statistics Information'
/
create or replace public synonym AWR_PDB_ENQUEUE_STAT 
    for AWR_PDB_ENQUEUE_STAT
/
grant select on AWR_PDB_ENQUEUE_STAT to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_LATCH_NAME
 ***************************************/

create or replace view AWR_PDB_LATCH_NAME
  (DBID, LATCH_HASH, LATCH_NAME, CON_DBID, CON_ID)
as
select dbid, latch_hash, latch_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_LATCH_NAME
/

comment on table AWR_PDB_LATCH_NAME is
'Latch Names'
/
create or replace public synonym AWR_PDB_LATCH_NAME for AWR_PDB_LATCH_NAME
/
grant select on AWR_PDB_LATCH_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_LATCH
 ***************************************/

create or replace view AWR_PDB_LATCH
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME, CON_DBID, CON_ID) 
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time,
       decode(l.con_dbid, 0, l.dbid, l.con_dbid), 
       decode(l.per_pdb, 0, 0,
         con_dbid_to_id(decode(l.con_dbid, 0, l.dbid, l.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_LATCH l, WRH$_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
/

comment on table AWR_PDB_LATCH is
'Latch Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LATCH for AWR_PDB_LATCH
/
grant select on AWR_PDB_LATCH to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_LATCH_CHILDREN
 ***************************************/

create or replace view AWR_PDB_LATCH_CHILDREN
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, CHILD#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME, CON_DBID, CON_ID)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, child#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time,
       decode(l.con_dbid, 0, l.dbid, l.con_dbid), 
       decode(l.per_pdb, 0, 0,
         con_dbid_to_id(decode(l.con_dbid, 0, l.dbid, l.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_LATCH_CHILDREN l, WRH$_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
/

comment on table AWR_PDB_LATCH_CHILDREN is
'Latch Children Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LATCH_CHILDREN 
    for AWR_PDB_LATCH_CHILDREN
/
grant select on AWR_PDB_LATCH_CHILDREN to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_LATCH_PARENT
 ***************************************/

create or replace view AWR_PDB_LATCH_PARENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME, CON_DBID, CON_ID)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time,
       decode(l.con_dbid, 0, l.dbid, l.con_dbid), 
       decode(l.per_pdb, 0, 0,
         con_dbid_to_id(decode(l.con_dbid, 0, l.dbid, l.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_LATCH_PARENT l, WRH$_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
/

comment on table AWR_PDB_LATCH_PARENT is
'Latch Parent Historical Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LATCH_PARENT 
    for AWR_PDB_LATCH_PARENT
/
grant select on AWR_PDB_LATCH_PARENT to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_LATCH_MISSES_SUMMARY
 ***************************************/

create or replace view AWR_PDB_LATCH_MISSES_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARENT_NAME, WHERE_IN_CODE,
   NWFAIL_COUNT, SLEEP_COUNT, WTR_SLP_COUNT, CON_DBID, CON_ID)
as
select l.snap_id, l.dbid, l.instance_number, parent_name, where_in_code,
       nwfail_count, sleep_count, wtr_slp_count,
       decode(l.con_dbid, 0, l.dbid, l.con_dbid), 
       decode(l.per_pdb, 0, 0,
         con_dbid_to_id(decode(l.con_dbid, 0, l.dbid, l.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_LATCH_MISSES_SUMMARY l
where      l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
/

comment on table AWR_PDB_LATCH_MISSES_SUMMARY is
'Latch Misses Summary Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LATCH_MISSES_SUMMARY 
    for AWR_PDB_LATCH_MISSES_SUMMARY
/
grant select on AWR_PDB_LATCH_MISSES_SUMMARY to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_EVENT_HISTOGRAM
 ***************************************/

create or replace view AWR_PDB_EVENT_HISTOGRAM
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   WAIT_TIME_MILLI, WAIT_COUNT, CON_DBID, CON_ID)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       e.wait_time_milli, e.wait_count,
       decode(e.con_dbid, 0, e.dbid, e.con_dbid), 
       decode(e.per_pdb, 0, 0,
         con_dbid_to_id(decode(e.con_dbid, 0, e.dbid, e.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_EVENT_HISTOGRAM e, WRH$_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
/

comment on table AWR_PDB_EVENT_HISTOGRAM is
'Event Histogram Historical Statistics Information'
/
create or replace public synonym AWR_PDB_EVENT_HISTOGRAM 
    for AWR_PDB_EVENT_HISTOGRAM
/
grant select on AWR_PDB_EVENT_HISTOGRAM to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_MUTEX_SLEEP
 ***************************************/

create or replace view AWR_PDB_MUTEX_SLEEP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   MUTEX_TYPE, LOCATION, SLEEPS, WAIT_TIME, CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, 
       mutex_type, location, sleeps, wait_time,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid), 
       decode(m.per_pdb, 0, 0,
         con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_MUTEX_SLEEP m
where      m.snap_id          = sn.snap_id
      and  m.dbid             = sn.dbid
      and  m.instance_number  = sn.instance_number
/

comment on table AWR_PDB_MUTEX_SLEEP is
'Mutex Sleep Summary Historical Statistics Information'
/
create or replace public synonym AWR_PDB_MUTEX_SLEEP 
    for AWR_PDB_MUTEX_SLEEP
/
grant select on AWR_PDB_MUTEX_SLEEP to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_LIBRARYCACHE
 ***************************************/

create or replace view AWR_PDB_LIBRARYCACHE
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAMESPACE, GETS, 
   GETHITS, PINS, PINHITS, RELOADS, INVALIDATIONS, 
   DLM_LOCK_REQUESTS, DLM_PIN_REQUESTS, DLM_PIN_RELEASES, 
   DLM_INVALIDATION_REQUESTS, DLM_INVALIDATIONS, CON_DBID, CON_ID)
as
select lc.snap_id, lc.dbid, lc.instance_number, namespace, gets, 
       gethits, pins, pinhits, reloads, invalidations, 
       dlm_lock_requests, dlm_pin_requests, dlm_pin_releases, 
       dlm_invalidation_requests, dlm_invalidations,
       decode(lc.con_dbid, 0, lc.dbid, lc.con_dbid), 
       decode(lc.per_pdb, 0, 0,
         con_dbid_to_id(decode(lc.con_dbid, 0, lc.dbid, lc.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_LIBRARYCACHE lc
  where     sn.snap_id         = lc.snap_id
        and sn.dbid            = lc.dbid
        and sn.instance_number = lc.instance_number
/

comment on table AWR_PDB_LIBRARYCACHE is
'Library Cache Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LIBRARYCACHE 
    for AWR_PDB_LIBRARYCACHE
/
grant select on AWR_PDB_LIBRARYCACHE to SELECT_CATALOG_ROLE
/




/***************************************
 *     AWR_PDB_DB_CACHE_ADVICE
 ***************************************/

create or replace view AWR_PDB_DB_CACHE_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, BPID, BUFFERS_FOR_ESTIMATE,
   NAME, BLOCK_SIZE, ADVICE_STATUS, SIZE_FOR_ESTIMATE, 
   SIZE_FACTOR, PHYSICAL_READS, BASE_PHYSICAL_READS,
   ACTUAL_PHYSICAL_READS, ESTD_PHYSICAL_READ_TIME, CON_DBID, CON_ID)
as
select db.snap_id, db.dbid, db.instance_number, 
       bpid, buffers_for_estimate,
       name, block_size, advice_status, size_for_estimate, 
       size_factor, physical_reads, base_physical_reads,
       actual_physical_reads, estd_physical_read_time,
       decode(db.con_dbid, 0, db.dbid, db.con_dbid), 
       decode(db.per_pdb, 0, 0,
         con_dbid_to_id(decode(db.con_dbid, 0, db.dbid, db.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_DB_CACHE_ADVICE db
where      db.snap_id          = sn.snap_id
      and  db.dbid             = sn.dbid
      and  db.instance_number  = sn.instance_number
/

comment on table AWR_PDB_DB_CACHE_ADVICE is
'DB Cache Advice History Information'
/
create or replace public synonym AWR_PDB_DB_CACHE_ADVICE
    for AWR_PDB_DB_CACHE_ADVICE
/
grant select on AWR_PDB_DB_CACHE_ADVICE to SELECT_CATALOG_ROLE
/




/***************************************
 *     AWR_PDB_BUFFER_POOL_STAT
 ***************************************/

create or replace view AWR_PDB_BUFFER_POOL_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, ID, NAME, BLOCK_SIZE, SET_MSIZE,
   CNUM_REPL, CNUM_WRITE, CNUM_SET, BUF_GOT, SUM_WRITE, SUM_SCAN,
   FREE_BUFFER_WAIT, WRITE_COMPLETE_WAIT, BUFFER_BUSY_WAIT,
   FREE_BUFFER_INSPECTED, DIRTY_BUFFERS_INSPECTED,
   DB_BLOCK_CHANGE, DB_BLOCK_GETS, CONSISTENT_GETS,
   PHYSICAL_READS, PHYSICAL_WRITES, CON_DBID, CON_ID) 
as
select bp.snap_id, bp.dbid, bp.instance_number, 
       id, name, block_size, set_msize,
       cnum_repl, cnum_write, cnum_set, buf_got, sum_write, sum_scan,
       free_buffer_wait, write_complete_wait, buffer_busy_wait,
       free_buffer_inspected, dirty_buffers_inspected,
       db_block_change, db_block_gets, consistent_gets,
       physical_reads, physical_writes,
       decode(bp.con_dbid, 0, bp.dbid, bp.con_dbid), 
       decode(bp.per_pdb, 0, 0,
         con_dbid_to_id(decode(bp.con_dbid, 0, bp.dbid, bp.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_BUFFER_POOL_STATISTICS bp
  where     sn.snap_id         = bp.snap_id
        and sn.dbid            = bp.dbid
        and sn.instance_number = bp.instance_number
/
comment on table AWR_PDB_BUFFER_POOL_STAT is
'Buffer Pool Historical Statistics Information'
/
create or replace public synonym AWR_PDB_BUFFER_POOL_STAT
    for AWR_PDB_BUFFER_POOL_STAT
/
grant select on AWR_PDB_BUFFER_POOL_STAT to SELECT_CATALOG_ROLE
/




/***************************************
 *     AWR_PDB_ROWCACHE_SUMMARY
 ***************************************/

create or replace view AWR_PDB_ROWCACHE_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER, TOTAL_USAGE,
   USAGE, GETS, GETMISSES, SCANS, SCANMISSES, SCANCOMPLETES,
   MODIFICATIONS, FLUSHES, DLM_REQUESTS, DLM_CONFLICTS, 
   DLM_RELEASES, CON_DBID, CON_ID)
as
select rc.snap_id, rc.dbid, rc.instance_number, 
       parameter, total_usage,
       usage, gets, getmisses, scans, scanmisses, scancompletes,
       modifications, flushes, dlm_requests, dlm_conflicts, 
       dlm_releases,
       decode(rc.con_dbid, 0, rc.dbid, rc.con_dbid), 
       decode(rc.per_pdb, 0, 0,
         con_dbid_to_id(decode(rc.con_dbid, 0, rc.dbid, rc.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_ROWCACHE_SUMMARY rc
  where     sn.snap_id         = rc.snap_id
        and sn.dbid            = rc.dbid
        and sn.instance_number = rc.instance_number
/

comment on table AWR_PDB_ROWCACHE_SUMMARY is
'Row Cache Historical Statistics Information Summary'
/
create or replace public synonym AWR_PDB_ROWCACHE_SUMMARY
    for AWR_PDB_ROWCACHE_SUMMARY
/
grant select on AWR_PDB_ROWCACHE_SUMMARY to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_SGA
 ***************************************/

create or replace view AWR_PDB_SGA
 (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE, CON_DBID, CON_ID)
as
select sga.snap_id, sga.dbid, sga.instance_number, name, value,
       decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid), 
       decode(sga.per_pdb, 0, 0,
         con_dbid_to_id(decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SGA sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
/

comment on table AWR_PDB_SGA is
'SGA Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SGA for AWR_PDB_SGA
/
grant select on AWR_PDB_SGA to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_SGASTAT
 ***************************************/

create or replace view AWR_PDB_SGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, POOL, BYTES, CON_DBID, CON_ID) 
as
select sga.snap_id, sga.dbid, sga.instance_number, name, pool, bytes,
       decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid), 
       decode(sga.per_pdb, 0, 0,
         con_dbid_to_id(decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SGASTAT sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
/

comment on table AWR_PDB_SGASTAT is
'SGA Pool Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SGASTAT for AWR_PDB_SGASTAT
/
grant select on AWR_PDB_SGASTAT to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_PGASTAT
 ***************************************/

create or replace view AWR_PDB_PGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE, CON_DBID, CON_ID) 
as
select pga.snap_id, pga.dbid, pga.instance_number, name, value,
       decode(pga.con_dbid, 0, pga.dbid, pga.con_dbid), 
       decode(pga.per_pdb, 0, 0,
         con_dbid_to_id(decode(pga.con_dbid, 0, pga.dbid, pga.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_PGASTAT pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
/

comment on table AWR_PDB_PGASTAT is
'PGA Historical Statistics Information'
/
create or replace public synonym AWR_PDB_PGASTAT for AWR_PDB_PGASTAT
/
grant select on AWR_PDB_PGASTAT to SELECT_CATALOG_ROLE
/




/***************************************
 *   AWR_PDB_PROCESS_MEM_SUMMARY
 ***************************************/

create or replace view AWR_PDB_PROCESS_MEM_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   CATEGORY, IS_INSTANCE_WIDE, 
   NUM_PROCESSES, NON_ZERO_ALLOCS, 
   USED_TOTAL, ALLOCATED_TOTAL, ALLOCATED_AVG, 
   ALLOCATED_STDDEV, ALLOCATED_MAX, MAX_ALLOCATED_MAX, CON_DBID, CON_ID)
as
select pmem.snap_id, pmem.dbid, pmem.instance_number,
       category, decode(pmem.per_pdb_nn, 0, 1, 0) is_instance_wide,
       num_processes, non_zero_allocs, 
       used_total, allocated_total, allocated_total / num_processes, 
       allocated_stddev, allocated_max, max_allocated_max,
       decode(pmem.con_dbid, 0, pmem.dbid, pmem.con_dbid), 
       decode(pmem.per_pdb, 0, 0,
         con_dbid_to_id(
           decode(pmem.con_dbid, 0, pmem.dbid, pmem.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_PROCESS_MEMORY_SUMMARY pmem
  where     sn.snap_id         = pmem.snap_id
        and sn.dbid            = pmem.dbid
        and sn.instance_number = pmem.instance_number
/

comment on table AWR_PDB_PROCESS_MEM_SUMMARY is
'Process Memory Historical Summary Information'
/
create or replace public synonym AWR_PDB_PROCESS_MEM_SUMMARY 
   for AWR_PDB_PROCESS_MEM_SUMMARY
/
grant select on AWR_PDB_PROCESS_MEM_SUMMARY to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_RESOURCE_LIMIT
 ***************************************/

create or replace view AWR_PDB_RESOURCE_LIMIT
  (SNAP_ID, DBID, INSTANCE_NUMBER, RESOURCE_NAME, 
   CURRENT_UTILIZATION, MAX_UTILIZATION, INITIAL_ALLOCATION,
   LIMIT_VALUE, CON_DBID, CON_ID)
as
select rl.snap_id, rl.dbid, rl.instance_number, resource_name, 
       current_utilization, max_utilization, initial_allocation,
       limit_value,
       decode(rl.con_dbid, 0, rl.dbid, rl.con_dbid), 
       decode(rl.per_pdb, 0, 0,
         con_dbid_to_id(decode(rl.con_dbid, 0, rl.dbid, rl.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RESOURCE_LIMIT rl
  where     sn.snap_id         = rl.snap_id
        and sn.dbid            = rl.dbid
        and sn.instance_number = rl.instance_number
/

comment on table AWR_PDB_RESOURCE_LIMIT is
'Resource Limit Historical Statistics Information'
/
create or replace public synonym AWR_PDB_RESOURCE_LIMIT 
    for AWR_PDB_RESOURCE_LIMIT
/
grant select on AWR_PDB_RESOURCE_LIMIT to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_SHARED_POOL_ADVICE
 ***************************************/

create or replace view AWR_PDB_SHARED_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SHARED_POOL_SIZE_FOR_ESTIMATE,
   SHARED_POOL_SIZE_FACTOR, ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS,
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR, 
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS, CON_DBID, CON_ID)
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       shared_pool_size_for_estimate,
       shared_pool_size_factor, estd_lc_size, estd_lc_memory_objects,
       estd_lc_time_saved, estd_lc_time_saved_factor, 
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits,
       decode(sp.con_dbid, 0, sp.dbid, sp.con_dbid), 
       decode(sp.per_pdb, 0, 0,
         con_dbid_to_id(decode(sp.con_dbid, 0, sp.dbid, sp.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SHARED_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
/

comment on table AWR_PDB_SHARED_POOL_ADVICE is
'Shared Pool Advice History'
/
create or replace public synonym AWR_PDB_SHARED_POOL_ADVICE 
    for AWR_PDB_SHARED_POOL_ADVICE
/
grant select on AWR_PDB_SHARED_POOL_ADVICE to SELECT_CATALOG_ROLE
/



/***************************************
 *    AWR_PDB_STREAMS_POOL_ADVICE
 ***************************************/

create or replace view AWR_PDB_STREAMS_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SIZE_FOR_ESTIMATE,
   SIZE_FACTOR, ESTD_SPILL_COUNT, ESTD_SPILL_TIME,
   ESTD_UNSPILL_COUNT, ESTD_UNSPILL_TIME, CON_DBID, CON_ID) 
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       size_for_estimate, size_factor, 
       estd_spill_count, estd_spill_time, 
       estd_unspill_count, estd_unspill_time, 
       decode(sp.con_dbid, 0, sp.dbid, sp.con_dbid), 
       decode(sp.per_pdb, 0, 0,
         con_dbid_to_id(decode(sp.con_dbid, 0, sp.dbid, sp.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_STREAMS_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
/

comment on table AWR_PDB_STREAMS_POOL_ADVICE is
'Streams Pool Advice History'
/
create or replace public synonym AWR_PDB_STREAMS_POOL_ADVICE 
    for AWR_PDB_STREAMS_POOL_ADVICE
/
grant select on AWR_PDB_STREAMS_POOL_ADVICE to SELECT_CATALOG_ROLE
/




/***************************************
 *     AWR_PDB_SQL_WORKAREA_HSTGRM
 ***************************************/

create or replace view AWR_PDB_SQL_WORKAREA_HSTGRM
  (SNAP_ID, DBID, INSTANCE_NUMBER, LOW_OPTIMAL_SIZE, 
   HIGH_OPTIMAL_SIZE, OPTIMAL_EXECUTIONS, ONEPASS_EXECUTIONS,
   MULTIPASSES_EXECUTIONS, TOTAL_EXECUTIONS, CON_DBID, CON_ID) 
as
select swh.snap_id, swh.dbid, swh.instance_number, low_optimal_size, 
       high_optimal_size, optimal_executions, onepass_executions,
       multipasses_executions, total_executions,
       decode(swh.con_dbid, 0, swh.dbid, swh.con_dbid), 
       decode(swh.per_pdb, 0, 0,
         con_dbid_to_id(decode(swh.con_dbid, 0, swh.dbid, swh.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SQL_WORKAREA_HISTOGRAM swh
  where     sn.snap_id         = swh.snap_id
        and sn.dbid            = swh.dbid
        and sn.instance_number = swh.instance_number
/

comment on table AWR_PDB_SQL_WORKAREA_HSTGRM is
'SQL Workarea Histogram History'
/
create or replace public synonym AWR_PDB_SQL_WORKAREA_HSTGRM 
    for AWR_PDB_SQL_WORKAREA_HSTGRM
/
grant select on AWR_PDB_SQL_WORKAREA_HSTGRM to SELECT_CATALOG_ROLE
/



/***************************************
 *     AWR_PDB_PGA_TARGET_ADVICE
 ***************************************/

create or replace view AWR_PDB_PGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, PGA_TARGET_FOR_ESTIMATE,
   PGA_TARGET_FACTOR, ADVICE_STATUS, BYTES_PROCESSED,
   ESTD_TIME, ESTD_EXTRA_BYTES_RW, 
   ESTD_PGA_CACHE_HIT_PERCENTAGE, ESTD_OVERALLOC_COUNT, CON_DBID, CON_ID)
as
select pga.snap_id, pga.dbid, pga.instance_number, 
       pga_target_for_estimate,
       pga_target_factor, advice_status, bytes_processed,
       estd_time, estd_extra_bytes_rw, 
       estd_pga_cache_hit_percentage, estd_overalloc_count,
       decode(pga.con_dbid, 0, pga.dbid, pga.con_dbid), 
       decode(pga.per_pdb, 0, 0,
         con_dbid_to_id(decode(pga.con_dbid, 0, pga.dbid, pga.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_PGA_TARGET_ADVICE pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
/

comment on table AWR_PDB_PGA_TARGET_ADVICE is
'PGA Target Advice History'
/
create or replace public synonym AWR_PDB_PGA_TARGET_ADVICE
    for AWR_PDB_PGA_TARGET_ADVICE
/
grant select on AWR_PDB_PGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/



/***************************************
 *     AWR_PDB_SGA_TARGET_ADVICE
 ***************************************/

create or replace view AWR_PDB_SGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SGA_SIZE, SGA_SIZE_FACTOR,
   ESTD_DB_TIME, ESTD_PHYSICAL_READS, CON_DBID, CON_ID)
as
select sga.snap_id, sga.dbid, sga.instance_number, 
       sga.sga_size, sga.sga_size_factor, sga.estd_db_time,   
       sga.estd_physical_reads,
       decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid), 
       decode(sga.per_pdb, 0, 0,
         con_dbid_to_id(decode(sga.con_dbid, 0, sga.dbid, sga.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SGA_TARGET_ADVICE sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
/

comment on table AWR_PDB_SGA_TARGET_ADVICE is
'SGA Target Advice History'
/
create or replace public synonym AWR_PDB_SGA_TARGET_ADVICE
    for AWR_PDB_SGA_TARGET_ADVICE
/
grant select on AWR_PDB_SGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_MEMORY_TARGET_ADVICE
 ***************************************/

create or replace view AWR_PDB_MEMORY_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   MEMORY_SIZE, MEMORY_SIZE_FACTOR, ESTD_DB_TIME, 
   ESTD_DB_TIME_FACTOR, VERSION, CON_DBID, CON_ID)
as
select mem.snap_id, mem.dbid, mem.instance_number, 
       memory_size, memory_size_factor, 
       estd_db_time, estd_db_time_factor, version,
       decode(mem.con_dbid, 0, mem.dbid, mem.con_dbid), 
       decode(mem.per_pdb, 0, 0,
         con_dbid_to_id(decode(mem.con_dbid, 0, mem.dbid, mem.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_MEMORY_TARGET_ADVICE mem
  where     sn.snap_id         = mem.snap_id
        and sn.dbid            = mem.dbid
        and sn.instance_number = mem.instance_number
/

comment on table AWR_PDB_MEMORY_TARGET_ADVICE is
'Memory Target Advice History'
/
create or replace public synonym AWR_PDB_MEMORY_TARGET_ADVICE
    for AWR_PDB_MEMORY_TARGET_ADVICE
/
grant select on AWR_PDB_MEMORY_TARGET_ADVICE to SELECT_CATALOG_ROLE
/



/***************************************
 *    AWR_PDB_MEMORY_RESIZE_OPS
 ***************************************/

create or replace view AWR_PDB_MEMORY_RESIZE_OPS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   COMPONENT, OPER_TYPE, START_TIME, END_TIME,
   TARGET_SIZE, OPER_MODE, PARAMETER, INITIAL_SIZE,
   FINAL_SIZE, STATUS, CON_DBID, CON_ID)
as
select mro.snap_id, mro.dbid, mro.instance_number, 
       component, oper_type, start_time, end_time,
       target_size, oper_mode, parameter, initial_size,
       final_size, mro.status,
       decode(mro.con_dbid, 0, mro.dbid, mro.con_dbid), 
       decode(mro.per_pdb, 0, 0,
         con_dbid_to_id(decode(mro.con_dbid, 0, mro.dbid, mro.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_MEMORY_RESIZE_OPS mro
  where     sn.snap_id         = mro.snap_id
        and sn.dbid            = mro.dbid
        and sn.instance_number = mro.instance_number
/

comment on table AWR_PDB_MEMORY_RESIZE_OPS is
'Memory Resize Operations History'
/
create or replace public synonym AWR_PDB_MEMORY_RESIZE_OPS
    for AWR_PDB_MEMORY_RESIZE_OPS
/
grant select on AWR_PDB_MEMORY_RESIZE_OPS to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_INSTANCE_RECOVERY
 ***************************************/

create or replace view AWR_PDB_INSTANCE_RECOVERY
  (SNAP_ID, DBID, INSTANCE_NUMBER, RECOVERY_ESTIMATED_IOS,
   ACTUAL_REDO_BLKS, TARGET_REDO_BLKS, LOG_FILE_SIZE_REDO_BLKS,
   LOG_CHKPT_TIMEOUT_REDO_BLKS, LOG_CHKPT_INTERVAL_REDO_BLKS,
   FAST_START_IO_TARGET_REDO_BLKS, TARGET_MTTR, ESTIMATED_MTTR,
   CKPT_BLOCK_WRITES, OPTIMAL_LOGFILE_SIZE, ESTD_CLUSTER_AVAILABLE_TIME,
   WRITES_MTTR, WRITES_LOGFILE_SIZE, WRITES_LOG_CHECKPOINT_SETTINGS,
   WRITES_OTHER_SETTINGS, WRITES_AUTOTUNE, WRITES_FULL_THREAD_CKPT,
   CON_DBID, CON_ID)
as
select ir.snap_id, ir.dbid, ir.instance_number, recovery_estimated_ios,
       actual_redo_blks, target_redo_blks, log_file_size_redo_blks,
       log_chkpt_timeout_redo_blks, log_chkpt_interval_redo_blks,
       fast_start_io_target_redo_blks, target_mttr, estimated_mttr,
       ckpt_block_writes, optimal_logfile_size, estd_cluster_available_time,
       writes_mttr, writes_logfile_size, writes_log_checkpoint_settings,
       writes_other_settings, writes_autotune, writes_full_thread_ckpt,
       decode(ir.con_dbid, 0, ir.dbid, ir.con_dbid), 
       decode(ir.per_pdb, 0, 0,
         con_dbid_to_id(decode(ir.con_dbid, 0, ir.dbid, ir.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_INSTANCE_RECOVERY ir
  where     sn.snap_id         = ir.snap_id
        and sn.dbid            = ir.dbid
        and sn.instance_number = ir.instance_number
/

comment on table AWR_PDB_INSTANCE_RECOVERY is
'Instance Recovery Historical Statistics Information'
/
create or replace public synonym AWR_PDB_INSTANCE_RECOVERY 
    for AWR_PDB_INSTANCE_RECOVERY
/
grant select on AWR_PDB_INSTANCE_RECOVERY to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_RECOVERY_PROGRESS
 ***************************************/

create or replace view AWR_PDB_RECOVERY_PROGRESS
  (SNAP_ID, DBID, INSTANCE_NUMBER, START_TIME, TYPE,
   ITEM, UNITS, SOFAR, TOTAL, TIMESTAMP, CON_DBID, CON_ID)
as
select rp.snap_id, rp.dbid, rp.instance_number, start_time, type,
       item, units, sofar, total, timestamp,
       decode(rp.con_dbid, 0, rp.dbid, rp.con_dbid),
       decode(rp.per_pdb, 0, 0,
         con_dbid_to_id(decode(rp.con_dbid, 0, rp.dbid, rp.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RECOVERY_PROGRESS rp
  where     sn.snap_id = rp.snap_id
        and sn.dbid    = rp.dbid
        and sn.instance_number = rp.instance_number
/

comment on table AWR_PDB_RECOVERY_PROGRESS is
'Recovery Progress'
/
create or replace public synonym AWR_PDB_RECOVERY_PROGRESS
    for AWR_PDB_RECOVERY_PROGRESS
/
grant select on AWR_PDB_RECOVERY_PROGRESS to SELECT_CATALOG_ROLE
/


/***************************************
 *    AWR_PDB_JAVA_POOL_ADVICE
 ***************************************/

create or replace view AWR_PDB_JAVA_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   JAVA_POOL_SIZE_FOR_ESTIMATE, JAVA_POOL_SIZE_FACTOR, 
   ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS, 
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR,
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS, CON_DBID, CON_ID)
as
select jp.snap_id, jp.dbid, jp.instance_number, 
       java_pool_size_for_estimate, java_pool_size_factor, 
       estd_lc_size, estd_lc_memory_objects, 
       estd_lc_time_saved, estd_lc_time_saved_factor,
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits,
       decode(jp.con_dbid, 0, jp.dbid, jp.con_dbid), 
       decode(jp.per_pdb, 0, 0,
         con_dbid_to_id(decode(jp.con_dbid, 0, jp.dbid, jp.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_JAVA_POOL_ADVICE jp
  where     sn.snap_id         = jp.snap_id
        and sn.dbid            = jp.dbid
        and sn.instance_number = jp.instance_number
/

comment on table AWR_PDB_JAVA_POOL_ADVICE is
'Java Pool Advice History'
/
create or replace public synonym AWR_PDB_JAVA_POOL_ADVICE 
    for AWR_PDB_JAVA_POOL_ADVICE
/
grant select on AWR_PDB_JAVA_POOL_ADVICE to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_THREAD
 ***************************************/

create or replace view AWR_PDB_THREAD
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   THREAD#, THREAD_INSTANCE_NUMBER, STATUS,
   OPEN_TIME, CURRENT_GROUP#, SEQUENCE#, CON_DBID, CON_ID)
as
select th.snap_id, th.dbid, th.instance_number, 
       thread#, thread_instance_number, th.status,
       open_time, current_group#, sequence#,
       decode(th.con_dbid, 0, th.dbid, th.con_dbid), 
       decode(th.per_pdb, 0, 0,
         con_dbid_to_id(decode(th.con_dbid, 0, th.dbid, th.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_THREAD th
  where     sn.snap_id         = th.snap_id
        and sn.dbid            = th.dbid
        and sn.instance_number = th.instance_number
/

comment on table AWR_PDB_THREAD is
'Thread Historical Statistics Information'
/
create or replace public synonym AWR_PDB_THREAD 
    for AWR_PDB_THREAD
/
grant select on AWR_PDB_THREAD to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_STAT_NAME
 ***************************************/

create or replace view AWR_PDB_STAT_NAME
  (DBID, STAT_ID, STAT_NAME, CON_DBID, CON_ID)
as
select dbid, stat_id, stat_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_STAT_NAME
/

comment on table AWR_PDB_STAT_NAME is
'Statistic Names'
/
create or replace public synonym AWR_PDB_STAT_NAME for AWR_PDB_STAT_NAME
/
grant select on AWR_PDB_STAT_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_SYSSTAT
 ***************************************/

create or replace view AWR_PDB_SYSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID) 
as
select s.snap_id, s.dbid, s.instance_number, 
       s.stat_id, nm.stat_name, value,
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SYSSTAT s, WRH$_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
/

comment on table AWR_PDB_SYSSTAT is
'System Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SYSSTAT for AWR_PDB_SYSSTAT
/
grant select on AWR_PDB_SYSSTAT to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_CON_SYSSTAT
 ***************************************/

create or replace view AWR_PDB_CON_SYSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID)
as
select s.snap_id, s.dbid, s.instance_number,
       s.stat_id, nm.stat_name, s.value, s.con_dbid,
       con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid)) con_id
from  WRH$_CON_SYSSTAT s, WRH$_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
/

comment on table AWR_PDB_CON_SYSSTAT is
'System Historical Statistics Information Per PDB'
/
create or replace public synonym AWR_PDB_CON_SYSSTAT for AWR_PDB_CON_SYSSTAT
/
grant select on AWR_PDB_CON_SYSSTAT to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SYS_TIME_MODEL
 ***************************************/

create or replace view AWR_PDB_SYS_TIME_MODEL
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID)
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value, 
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SYS_TIME_MODEL s, WRH$_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
/

comment on table AWR_PDB_SYS_TIME_MODEL is
'System Time Model Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SYS_TIME_MODEL 
   for AWR_PDB_SYS_TIME_MODEL
/
grant select on AWR_PDB_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_CON_SYS_TIME_MODEL
 ***************************************/

create or replace view AWR_PDB_CON_SYS_TIME_MODEL
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID)
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value, 
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_CON_SYS_TIME_MODEL s, WRH$_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
/

comment on table AWR_PDB_CON_SYS_TIME_MODEL is
'PDB System Time Model Historical Statistics Information'
/
create or replace public synonym AWR_PDB_CON_SYS_TIME_MODEL 
   for AWR_PDB_CON_SYS_TIME_MODEL
/
grant select on AWR_PDB_CON_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_OSSTAT_NAME
 ***************************************/

create or replace view AWR_PDB_OSSTAT_NAME
  (DBID, STAT_ID, STAT_NAME, CON_DBID, CON_ID)
as
select dbid, stat_id, stat_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_OSSTAT_NAME
/

comment on table AWR_PDB_OSSTAT_NAME is
'Operating System Statistic Names'
/
create or replace public synonym AWR_PDB_OSSTAT_NAME 
  for AWR_PDB_OSSTAT_NAME
/
grant select on AWR_PDB_OSSTAT_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_OSSTAT
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_OSSTAT_VALUE SDM_TYPE MASK_IWD 's' 'value'

create or replace view AWR_PDB_OSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID)
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name,
       &KEWR_MASK_OSSTAT_VALUE, -- Use macro to mask sensitive column
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       decode(s.per_pdb, 0, 0,
         con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_OSSTAT s, WRH$_OSSTAT_NAME nm
where     s.stat_id          = nm.stat_id
      and s.dbid             = nm.dbid
      and s.snap_id          = sn.snap_id
      and s.dbid             = sn.dbid
      and s.instance_number  = sn.instance_number
/

-- Undefine the macro
undefine KEWR_MASK_OSSTAT_VALUE

comment on table AWR_PDB_OSSTAT is
'Operating System Historical Statistics Information'
/
create or replace public synonym AWR_PDB_OSSTAT 
   for AWR_PDB_OSSTAT
/
grant select on AWR_PDB_OSSTAT to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_PARAMETER_NAME
 ***************************************/

create or replace view AWR_PDB_PARAMETER_NAME
  (DBID, PARAMETER_HASH, PARAMETER_NAME, CON_DBID, CON_ID)
as
select dbid, parameter_hash, parameter_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_PARAMETER_NAME 
where (translate(parameter_name,'_','#') not like '#%')
/

comment on table AWR_PDB_PARAMETER_NAME is
'Parameter Names'
/
create or replace public synonym AWR_PDB_PARAMETER_NAME 
    for AWR_PDB_PARAMETER_NAME
/
grant select on AWR_PDB_PARAMETER_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_PARAMETER
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_PARAMETER_VALUE SDM_TYPE MASK_IWD 'p' 'value'

create or replace view AWR_PDB_PARAMETER
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER_HASH,
   PARAMETER_NAME, VALUE, ISDEFAULT, ISMODIFIED, CON_DBID, CON_ID)
as
select p.snap_id, p.dbid, p.instance_number, 
       p.parameter_hash, pn.parameter_name, 
       &KEWR_MASK_PARAMETER_VALUE, -- Use macro to mask sensitive column
       isdefault, ismodified,
       decode(p.con_dbid, 0, p.dbid, p.con_dbid), 
       decode(p.per_pdb, 0, 0,
         con_dbid_to_id(decode(p.con_dbid, 0, p.dbid, p.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_PARAMETER p, WRH$_PARAMETER_NAME pn
where     p.parameter_hash   = pn.parameter_hash
      and p.dbid             = pn.dbid
      and p.snap_id          = sn.snap_id
      and p.dbid             = sn.dbid
      and p.instance_number  = sn.instance_number
/

-- Undefine the macro
undefine KEWR_MASK_PARAMETER_VALUE

comment on table AWR_PDB_PARAMETER is
'Parameter Historical Statistics Information'
/
create or replace public synonym AWR_PDB_PARAMETER 
    for AWR_PDB_PARAMETER
/
grant select on AWR_PDB_PARAMETER to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_MVPARAMETER
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_MVPARAMETER_VALUE SDM_TYPE MASK_IWD 'mp' 'value'

create or replace view AWR_PDB_MVPARAMETER
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER_HASH,
   PARAMETER_NAME, ORDINAL, VALUE, ISDEFAULT, ISMODIFIED, CON_DBID, CON_ID)
as
select mp.snap_id, mp.dbid, mp.instance_number, 
       mp.parameter_hash, pn.parameter_name, 
       mp.ordinal,
       &KEWR_MASK_MVPARAMETER_VALUE, -- Use macro to mask sensitive column
       mp.isdefault, mp.ismodified,
       decode(mp.con_dbid, 0, mp.dbid, mp.con_dbid), 
       decode(mp.per_pdb, 0, 0,
         con_dbid_to_id(decode(mp.con_dbid, 0, mp.dbid, mp.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_MVPARAMETER mp, WRH$_PARAMETER_NAME pn
where     mp.parameter_hash   = pn.parameter_hash
      and mp.dbid             = pn.dbid
      and mp.snap_id          = sn.snap_id
      and mp.dbid             = sn.dbid
      and mp.instance_number  = sn.instance_number
/

-- Undefine the macro
undefine KEWR_MASK_MVPARAMETER_VALUE

comment on table AWR_PDB_MVPARAMETER is
'Multi-valued Parameter Historical Statistics Information'
/
create or replace public synonym AWR_PDB_MVPARAMETER 
    for AWR_PDB_MVPARAMETER
/
grant select on AWR_PDB_MVPARAMETER to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_UNDOSTAT
 ***************************************/

create or replace view AWR_PDB_UNDOSTAT
  (BEGIN_TIME, END_TIME, DBID, INSTANCE_NUMBER, SNAP_ID, UNDOTSN,
   UNDOBLKS, TXNCOUNT, MAXQUERYLEN, MAXQUERYSQLID,
   MAXCONCURRENCY, UNXPSTEALCNT, UNXPBLKRELCNT, UNXPBLKREUCNT, 
   EXPSTEALCNT, EXPBLKRELCNT, EXPBLKREUCNT, SSOLDERRCNT, 
   NOSPACEERRCNT, ACTIVEBLKS, UNEXPIREDBLKS, EXPIREDBLKS,
   TUNED_UNDORETENTION, CON_DBID, CON_ID)
as
select begin_time, end_time, ud.dbid, ud.instance_number, 
       ud.snap_id, undotsn,
       undoblks, txncount, maxquerylen, maxquerysqlid,
       maxconcurrency, unxpstealcnt, unxpblkrelcnt, unxpblkreucnt, 
       expstealcnt, expblkrelcnt, expblkreucnt, ssolderrcnt, 
       nospaceerrcnt, activeblks, unexpiredblks, expiredblks,
       tuned_undoretention,
       decode(ud.con_dbid, 0, ud.dbid, ud.con_dbid), 
       decode(ud.per_pdb, 0, 0,
         con_dbid_to_id(decode(ud.con_dbid, 0, ud.dbid, ud.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_UNDOSTAT ud
  where     sn.snap_id         = ud.snap_id
        and sn.dbid            = ud.dbid
        and sn.instance_number = ud.instance_number
/

comment on table AWR_PDB_UNDOSTAT is
'Undo Historical Statistics Information'
/
create or replace public synonym AWR_PDB_UNDOSTAT 
    for AWR_PDB_UNDOSTAT
/
grant select on AWR_PDB_UNDOSTAT to SELECT_CATALOG_ROLE
/



/*****************************************************************************
 *   AWR_PDB_SEG_STAT
 *
 * Note: In WRH$_SEG_STAT, we have renamed the GC CR/Current Blocks 
 *       Served columns to GC CR/Current Blocks Received.  For 
 *       compatibility reasons, we will keep the Served columns 
 *       in the AWR_PDB_SEG_STAT view in case any product has a
 *       dependency on the column name.  We will remove this column
 *       after two releases (remove in release 12).
 *
 *       To obsolete the columns, simply remove the following:
 *          GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
 *          GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
 *****************************************************************************/
drop view AWR_PDB_SEG_STAT;

create or replace view AWR_PDB_SEG_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, OBJ#, DATAOBJ#, 
   LOGICAL_READS_TOTAL, LOGICAL_READS_DELTA,
   BUFFER_BUSY_WAITS_TOTAL, BUFFER_BUSY_WAITS_DELTA,
   DB_BLOCK_CHANGES_TOTAL, DB_BLOCK_CHANGES_DELTA,
   PHYSICAL_READS_TOTAL, PHYSICAL_READS_DELTA, 
   PHYSICAL_WRITES_TOTAL, PHYSICAL_WRITES_DELTA,
   PHYSICAL_READS_DIRECT_TOTAL, PHYSICAL_READS_DIRECT_DELTA,
   PHYSICAL_WRITES_DIRECT_TOTAL, PHYSICAL_WRITES_DIRECT_DELTA,
   ITL_WAITS_TOTAL, ITL_WAITS_DELTA,
   ROW_LOCK_WAITS_TOTAL, ROW_LOCK_WAITS_DELTA, 
   GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
   GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
   GC_BUFFER_BUSY_TOTAL, GC_BUFFER_BUSY_DELTA,
   GC_CR_BLOCKS_RECEIVED_TOTAL, GC_CR_BLOCKS_RECEIVED_DELTA,
   GC_CU_BLOCKS_RECEIVED_TOTAL, GC_CU_BLOCKS_RECEIVED_DELTA,
   GC_REMOTE_GRANTS_TOTAL, GC_REMOTE_GRANTS_DELTA,
   SPACE_USED_TOTAL, SPACE_USED_DELTA,
   SPACE_ALLOCATED_TOTAL, SPACE_ALLOCATED_DELTA,
   TABLE_SCANS_TOTAL, TABLE_SCANS_DELTA,
   CHAIN_ROW_EXCESS_TOTAL, CHAIN_ROW_EXCESS_DELTA,
   PHYSICAL_READ_REQUESTS_TOTAL, PHYSICAL_READ_REQUESTS_DELTA,
   PHYSICAL_WRITE_REQUESTS_TOTAL, PHYSICAL_WRITE_REQUESTS_DELTA,
   OPTIMIZED_PHYSICAL_READS_TOTAL, OPTIMIZED_PHYSICAL_READS_DELTA,
   IM_SCANS_TOTAL, IM_SCANS_DELTA,
   POPULATE_CUS_TOTAL, POPULATE_CUS_DELTA,
   REPOPULATE_CUS_TOTAL, REPOPULATE_CUS_DELTA,
   IM_DB_BLOCK_CHANGES_TOTAL, IM_DB_BLOCK_CHANGES_DELTA,
   CON_DBID, CON_ID)
as
select seg.snap_id, seg.dbid, seg.instance_number, ts#, obj#, dataobj#, 
       logical_reads_total, logical_reads_delta,
       buffer_busy_waits_total, buffer_busy_waits_delta,
       db_block_changes_total, db_block_changes_delta,
       physical_reads_total, physical_reads_delta, 
       physical_writes_total, physical_writes_delta,
       physical_reads_direct_total, physical_reads_direct_delta,
       physical_writes_direct_total, physical_writes_direct_delta,
       itl_waits_total, itl_waits_delta,
       row_lock_waits_total, row_lock_waits_delta, 
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       gc_buffer_busy_total, gc_buffer_busy_delta,
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       gc_remote_grants_total, gc_remote_grants_delta,
       space_used_total, space_used_delta,
       space_allocated_total, space_allocated_delta,
       table_scans_total, table_scans_delta,
       chain_row_excess_total, chain_row_excess_delta,
       physical_read_requests_total, physical_read_requests_delta,
       physical_write_requests_total, physical_write_requests_delta,
       optimized_physical_reads_total, optimized_physical_reads_delta,
       im_scans_total, im_scans_delta,
       populate_cus_total, populate_cus_delta,
       repopulate_cus_total, repopulate_cus_delta,
       im_db_block_changes_total, im_db_block_changes_delta,
       decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid), 
       decode(seg.per_pdb, 0, 0,
         con_dbid_to_id(decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SEG_STAT seg
where     seg.snap_id         = sn.snap_id
      and seg.dbid            = sn.dbid
      and seg.instance_number = sn.instance_number
/

comment on table AWR_PDB_SEG_STAT is
' Historical Statistics Information'
/
create or replace public synonym AWR_PDB_SEG_STAT 
    for AWR_PDB_SEG_STAT
/
grant select on AWR_PDB_SEG_STAT to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_SEG_STAT_OBJ
 ***************************************/

create or replace view AWR_PDB_SEG_STAT_OBJ
  (DBID, TS#, OBJ#, DATAOBJ#, OWNER, OBJECT_NAME, 
   SUBOBJECT_NAME, OBJECT_TYPE, TABLESPACE_NAME, PARTITION_TYPE, CON_DBID,
   CON_ID)
as
select so.dbid, so.ts#, so.obj#, so.dataobj#, so.owner, so.object_name, 
       so.subobject_name, so.object_type, 
       coalesce(ts.tsname, tablespace_name) tablespace_name,
       so.partition_type,
       decode(so.con_dbid, 0, so.dbid, so.con_dbid),
       decode(so.per_pdb, 0, 0,
         con_dbid_to_id(decode(so.con_dbid, 0, so.dbid, so.con_dbid))) con_id
from WRH$_SEG_STAT_OBJ so LEFT OUTER JOIN WRH$_TABLESPACE ts
     on (so.dbid = ts.dbid
         and so.ts# = ts.ts# 
         and so.con_dbid = ts.con_dbid)
/
comment on table AWR_PDB_SEG_STAT_OBJ is
'Segment Names'
/
create or replace public synonym AWR_PDB_SEG_STAT_OBJ 
    for AWR_PDB_SEG_STAT_OBJ
/
grant select on AWR_PDB_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_METRIC_NAME
 ***************************************/

/* The Metric Id will remain the same across releases */
create or replace view AWR_PDB_METRIC_NAME
  (DBID, GROUP_ID, GROUP_NAME, METRIC_ID, METRIC_NAME, METRIC_UNIT,
   CON_DBID, CON_ID)
as
select dbid, group_id, group_name, metric_id, metric_name, metric_unit,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_METRIC_NAME
/
comment on table AWR_PDB_METRIC_NAME is
'Segment Names'
/
create or replace public synonym AWR_PDB_METRIC_NAME
    for AWR_PDB_METRIC_NAME
/
grant select on AWR_PDB_METRIC_NAME to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_SYSMETRIC_HISTORY
 ***************************************/

create or replace view AWR_PDB_SYSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT, CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, value, mn.metric_unit,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid),
       con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid)) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SYSMETRIC_HISTORY m, WRH$_METRIC_NAME mn
where       m.group_id       = mn.group_id
      and   m.metric_id      = mn.metric_id
      and   m.dbid           = mn.dbid
      and   sn.snap_id       = m.snap_id
      and sn.dbid            = m.dbid
      and sn.instance_number = m.instance_number
/

comment on table AWR_PDB_SYSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym AWR_PDB_SYSMETRIC_HISTORY 
    for AWR_PDB_SYSMETRIC_HISTORY
/
grant select on AWR_PDB_SYSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/




/***************************************
 *      AWR_PDB_SYSMETRIC_SUMMARY
 ***************************************/

create or replace view AWR_PDB_SYSMETRIC_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, METRIC_UNIT, NUM_INTERVAL, 
   MINVAL, MAXVAL, AVERAGE, STANDARD_DEVIATION, SUM_SQUARES, CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, mn.metric_unit, 
       num_interval, minval, maxval, average, standard_deviation, sum_squares,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid),
       con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid)) con_id       
  from AWR_PDB_SNAPSHOT sn, WRH$_SYSMETRIC_SUMMARY m, WRH$_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
/

comment on table AWR_PDB_SYSMETRIC_SUMMARY is
'System Metrics History'
/
create or replace public synonym AWR_PDB_SYSMETRIC_SUMMARY 
    for AWR_PDB_SYSMETRIC_SUMMARY
/
grant select on AWR_PDB_SYSMETRIC_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *      AWR_PDB_CON_SYSMETRIC_HIST
 ***************************************/

create or replace view AWR_PDB_CON_SYSMETRIC_HIST
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT, CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, value, mn.metric_unit,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid),
       con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid)) con_id       
from AWR_PDB_SNAPSHOT sn, WRH$_CON_SYSMETRIC_HISTORY m, WRH$_METRIC_NAME mn
where       m.group_id       = mn.group_id
      and   m.metric_id      = mn.metric_id
      and   m.dbid           = mn.dbid
      and   sn.snap_id       = m.snap_id
      and sn.dbid            = m.dbid
      and sn.instance_number = m.instance_number
/

comment on table AWR_PDB_CON_SYSMETRIC_HIST is
'PDB System Metrics History'
/
create or replace public synonym AWR_PDB_CON_SYSMETRIC_HIST 
    for AWR_PDB_CON_SYSMETRIC_HIST
/
grant select on AWR_PDB_CON_SYSMETRIC_HIST to SELECT_CATALOG_ROLE
/



/***************************************
 *      AWR_PDB_CON_SYSMETRIC_SUMM
 ***************************************/

create or replace view AWR_PDB_CON_SYSMETRIC_SUMM
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, METRIC_UNIT, NUM_INTERVAL, 
   MINVAL, MAXVAL, AVERAGE, STANDARD_DEVIATION, SUM_SQUARES, CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, mn.metric_unit, 
       num_interval, minval, maxval, average, standard_deviation, sum_squares,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid),
       con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid)) con_id       
  from AWR_PDB_SNAPSHOT sn, WRH$_CON_SYSMETRIC_SUMMARY m, WRH$_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
/

comment on table AWR_PDB_CON_SYSMETRIC_SUMM is
'PDB System Metrics Summary'
/
create or replace public synonym AWR_PDB_CON_SYSMETRIC_SUMM 
    for AWR_PDB_CON_SYSMETRIC_SUMM
/
grant select on AWR_PDB_CON_SYSMETRIC_SUMM to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB__SESSMETRIC_HISTORY
 ***************************************/

create or replace view AWR_PDB_SESSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, SESSID,
   SERIAL#, INTSIZE, GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT,
   CON_DBID, CON_ID)
as
select m.snap_id, m.dbid, m.instance_number, begin_time, end_time, sessid,
       serial#, intsize, m.group_id, m.metric_id, mn.metric_name, 
       value, mn.metric_unit,
       decode(m.con_dbid, 0, m.dbid, m.con_dbid),
       decode(m.per_pdb, 0, 0,
         con_dbid_to_id(decode(m.con_dbid, 0, m.dbid, m.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SESSMETRIC_HISTORY m, WRH$_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
/

comment on table AWR_PDB_SESSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym AWR_PDB_SESSMETRIC_HISTORY 
    for AWR_PDB_SESSMETRIC_HISTORY
/
grant select on AWR_PDB_SESSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_FILEMETRIC_HISTORY
 ***************************************/

create or replace view AWR_PDB_FILEMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, FILEID, CREATIONTIME, BEGIN_TIME,
   END_TIME, INTSIZE, GROUP_ID, AVGREADTIME, AVGWRITETIME, PHYSICALREAD,
   PHYSICALWRITE, PHYBLKREAD, PHYBLKWRITE, CON_DBID, CON_ID)
as
select fm.snap_id, fm.dbid, fm.instance_number, 
       fileid, creationtime, begin_time,
       end_time, intsize, group_id, avgreadtime, avgwritetime, 
       physicalread, physicalwrite, phyblkread, phyblkwrite,
       decode(fm.con_dbid, 0, fm.dbid, fm.con_dbid),
       decode(fm.per_pdb, 0, 0,
         con_dbid_to_id(decode(fm.con_dbid, 0, fm.dbid, fm.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_FILEMETRIC_HISTORY fm
  where     sn.snap_id         = fm.snap_id
        and sn.dbid            = fm.dbid
        and sn.instance_number = fm.instance_number
/

comment on table AWR_PDB_FILEMETRIC_HISTORY is
'File Metrics History'
/
create or replace public synonym AWR_PDB_FILEMETRIC_HISTORY 
    for AWR_PDB_FILEMETRIC_HISTORY
/
grant select on AWR_PDB_FILEMETRIC_HISTORY to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_WAITCLASSMET_HISTORY
 ***************************************/

create or replace view AWR_PDB_WAITCLASSMET_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, WAIT_CLASS_ID, WAIT_CLASS,
   BEGIN_TIME, END_TIME, INTSIZE, GROUP_ID, AVERAGE_WAITER_COUNT,
   DBTIME_IN_WAIT, TIME_WAITED, WAIT_COUNT, TIME_WAITED_FG, WAIT_COUNT_FG,
   CON_DBID, CON_ID)
as
select em.snap_id, em.dbid, em.instance_number, 
       em.wait_class_id, wn.wait_class, begin_time, end_time, intsize, 
       group_id, average_waiter_count, dbtime_in_wait,
       time_waited, wait_count, time_waited_fg, wait_count_fg,
       decode(em.con_dbid, 0, em.dbid, em.con_dbid),
       decode(em.per_pdb, 0, 0,
         con_dbid_to_id(decode(em.con_dbid, 0, em.dbid, em.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_WAITCLASSMETRIC_HISTORY em,
       (select wait_class_id, wait_class from wrh$_event_name
        group by wait_class_id, wait_class) wn
  where     em.wait_class_id   = wn.wait_class_id
        and sn.snap_id         = em.snap_id
        and sn.dbid            = em.dbid
        and sn.instance_number = em.instance_number
/

comment on table AWR_PDB_WAITCLASSMET_HISTORY is
'Wait Class Metric History'
/
create or replace public synonym AWR_PDB_WAITCLASSMET_HISTORY 
    for AWR_PDB_WAITCLASSMET_HISTORY
/
grant select on AWR_PDB_WAITCLASSMET_HISTORY to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_DLM_MISC
 ***************************************/

create or replace view AWR_PDB_DLM_MISC
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   STATISTIC#, NAME, VALUE, CON_DBID, CON_ID)
as
select dlm.snap_id, dlm.dbid, dlm.instance_number,
       statistic#, name, value,
       decode(dlm.con_dbid, 0, dlm.dbid, dlm.con_dbid),
       decode(dlm.per_pdb, 0, 0,
         con_dbid_to_id(decode(dlm.con_dbid, 0, dlm.dbid, dlm.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_DLM_MISC dlm
  where     sn.snap_id         = dlm.snap_id
        and sn.dbid            = dlm.dbid
        and sn.instance_number = dlm.instance_number
/

comment on table AWR_PDB_DLM_MISC is
'Distributed Lock Manager Miscellaneous Historical Statistics Information'
/
create or replace public synonym AWR_PDB_DLM_MISC 
    for AWR_PDB_DLM_MISC
/
grant select on AWR_PDB_DLM_MISC to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_CR_BLOCK_SERVER
 ***************************************/

create or replace view AWR_PDB_CR_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 CR_REQUESTS, CURRENT_REQUESTS, 
 DATA_REQUESTS, UNDO_REQUESTS, TX_REQUESTS, 
 CURRENT_RESULTS, PRIVATE_RESULTS, ZERO_RESULTS,
 DISK_READ_RESULTS, FAIL_RESULTS,
 FAIRNESS_DOWN_CONVERTS, FLUSHES, BUILDS,
 LIGHT_WORKS, ERRORS, CON_DBID, CON_ID)
as
select crb.snap_id, crb.dbid, crb.instance_number,
       cr_requests, current_requests, 
       data_requests, undo_requests, tx_requests, 
       current_results, private_results, zero_results,
       disk_read_results, fail_results,
       fairness_down_converts, flushes, builds,
       light_works, errors,
       decode(crb.con_dbid, 0, crb.dbid, crb.con_dbid),
       decode(crb.per_pdb, 0, 0,
         con_dbid_to_id(decode(crb.con_dbid, 0, crb.dbid, crb.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_CR_BLOCK_SERVER crb
  where     sn.snap_id         = crb.snap_id
        and sn.dbid            = crb.dbid
        and sn.instance_number = crb.instance_number
/
comment on table AWR_PDB_CR_BLOCK_SERVER is
'Consistent Read Block Server Historical Statistics'
/
create or replace public synonym AWR_PDB_CR_BLOCK_SERVER 
    for AWR_PDB_CR_BLOCK_SERVER
/
grant select on AWR_PDB_CR_BLOCK_SERVER to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_CURRENT_BLOCK_SERVER
 ***************************************/

create or replace view AWR_PDB_CURRENT_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 PIN0,   PIN1,   PIN10,   PIN100,   PIN1000,   PIN10000,
 FLUSH0, FLUSH1, FLUSH10, FLUSH100, FLUSH1000, FLUSH10000,
 CON_DBID, CON_ID)
as
select cub.snap_id, cub.dbid, cub.instance_number,
       pin0,   pin1,   pin10,   pin100,   pin1000,   pin10000,
       flush0, flush1, flush10, flush100, flush1000, flush10000,
       decode(cub.con_dbid, 0, cub.dbid, cub.con_dbid),
       decode(cub.per_pdb, 0, 0,
         con_dbid_to_id(decode(cub.con_dbid, 0, cub.dbid, cub.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_CURRENT_BLOCK_SERVER cub
  where     sn.snap_id         = cub.snap_id
        and sn.dbid            = cub.dbid
        and sn.instance_number = cub.instance_number
/
comment on table AWR_PDB_CURRENT_BLOCK_SERVER is
'Current Block Server Historical Statistics'
/
create or replace public synonym AWR_PDB_CURRENT_BLOCK_SERVER 
    for AWR_PDB_CURRENT_BLOCK_SERVER
/
grant select on AWR_PDB_CURRENT_BLOCK_SERVER to SELECT_CATALOG_ROLE
/




/***************************************
 *    AWR_PDB_INST_CACHE_TRANSFER
 ***************************************/

create or replace view AWR_PDB_INST_CACHE_TRANSFER
(SNAP_ID, DBID, INSTANCE_NUMBER, 
 INSTANCE, CLASS, CR_BLOCK, CR_BUSY, CR_CONGESTED, 
 CURRENT_BLOCK, CURRENT_BUSY, CURRENT_CONGESTED
 ,lost ,cr_2hop ,cr_3hop ,current_2hop ,current_3hop 
 ,cr_block_time ,cr_busy_time ,cr_congested_time ,current_block_time 
 ,current_busy_time ,current_congested_time ,lost_time ,cr_2hop_time
 ,cr_3hop_time ,current_2hop_time ,current_3hop_time, CON_DBID, CON_ID
)
as
select ict.snap_id, ict.dbid, ict.instance_number, 
       instance, class, cr_block, cr_busy, cr_congested, 
       current_block, current_busy, current_congested
      ,lost ,cr_2hop ,cr_3hop ,current_2hop ,current_3hop
      ,cr_block_time ,cr_busy_time ,cr_congested_time ,current_block_time
      ,current_busy_time ,current_congested_time ,lost_time ,cr_2hop_time
      ,cr_3hop_time ,current_2hop_time ,current_3hop_time,
       decode(ict.con_dbid, 0, ict.dbid, ict.con_dbid),
       decode(ict.per_pdb, 0, 0,
         con_dbid_to_id(decode(ict.con_dbid, 0, ict.dbid, ict.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_INST_CACHE_TRANSFER ict
  where     sn.snap_id         = ict.snap_id
        and sn.dbid            = ict.dbid
        and sn.instance_number = ict.instance_number
/
comment on table AWR_PDB_INST_CACHE_TRANSFER is
'Instance Cache Transfer Historical Statistics'
/
create or replace public synonym AWR_PDB_INST_CACHE_TRANSFER 
    for AWR_PDB_INST_CACHE_TRANSFER
/
grant select on AWR_PDB_INST_CACHE_TRANSFER to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_PLAN_OPERATION_NAME
 ***************************************/

create or replace view AWR_PDB_PLAN_OPERATION_NAME
  (DBID, OPERATION_ID, OPERATION_NAME, CON_DBID, CON_ID)
as
select dbid, operation_id, operation_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_PLAN_OPERATION_NAME
/

comment on table AWR_PDB_PLAN_OPERATION_NAME is
'Optimizer Explain Plan Operation Names'
/
create or replace public synonym AWR_PDB_PLAN_OPERATION_NAME 
  for AWR_PDB_PLAN_OPERATION_NAME
/
grant select on AWR_PDB_PLAN_OPERATION_NAME to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_PLAN_OPTION_NAME
 ***************************************/

create or replace view AWR_PDB_PLAN_OPTION_NAME
  (DBID, OPTION_ID, OPTION_NAME, CON_DBID, CON_ID)
as
select dbid, option_id, option_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_PLAN_OPTION_NAME
/

comment on table AWR_PDB_PLAN_OPTION_NAME is
'Optimizer Explain Plan Option Names'
/
create or replace public synonym AWR_PDB_PLAN_OPTION_NAME 
  for AWR_PDB_PLAN_OPTION_NAME
/
grant select on AWR_PDB_PLAN_OPTION_NAME to SELECT_CATALOG_ROLE
/



/*****************************************
 *   AWR_PDB_SQLCOMMAND_NAME
 *****************************************/

create or replace view AWR_PDB_SQLCOMMAND_NAME
  (DBID, COMMAND_TYPE, COMMAND_NAME, CON_DBID, CON_ID)
as
select dbid, command_type, command_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_SQLCOMMAND_NAME
/

comment on table AWR_PDB_SQLCOMMAND_NAME is
'Sql command types'
/
create or replace public synonym AWR_PDB_SQLCOMMAND_NAME
  for AWR_PDB_SQLCOMMAND_NAME
/
grant select on AWR_PDB_SQLCOMMAND_NAME to SELECT_CATALOG_ROLE
/



/*****************************************
 *   AWR_PDB_TOPLEVELCALL_NAME
 *****************************************/

create or replace view AWR_PDB_TOPLEVELCALL_NAME
  (DBID, TOP_LEVEL_CALL#,TOP_LEVEL_CALL_NAME, CON_DBID, CON_ID)
as
select dbid, top_level_call#, top_level_call_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
from WRH$_TOPLEVELCALL_NAME
/

comment on table AWR_PDB_TOPLEVELCALL_NAME is
'Oracle top level call type'
/
create or replace public synonym AWR_PDB_TOPLEVELCALL_NAME
  for AWR_PDB_TOPLEVELCALL_NAME
/
grant select on AWR_PDB_TOPLEVELCALL_NAME to SELECT_CATALOG_ROLE
/



/***************************************
 *    AWR_PDB_ACTIVE_SESS_HISTORY
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_ASH_MACHINE SDM_TYPE MASK_ALL 'ash' 'machine'
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_ASH_PROGRAM SDM_TYPE MASK_ALL 'ash' 'program'

create or replace view AWR_PDB_ACTIVE_SESS_HISTORY
 ( /* ASH/AWR meta attributes */
   SNAP_ID, DBID, INSTANCE_NUMBER, 
   SAMPLE_ID, SAMPLE_TIME, SAMPLE_TIME_UTC,USECS_PER_ROW,
   /* Session/User attributes */
   SESSION_ID, SESSION_SERIAL#, 
   SESSION_TYPE, 
   FLAGS,
   USER_ID,
   /* SQL attributes */
   SQL_ID, IS_SQLID_CURRENT, SQL_CHILD_NUMBER, SQL_OPCODE, SQL_OPNAME,
   FORCE_MATCHING_SIGNATURE,
   TOP_LEVEL_SQL_ID, 
   TOP_LEVEL_SQL_OPCODE,
   /* SQL Plan/Execution attributes */
   SQL_PLAN_HASH_VALUE, 
   SQL_FULL_PLAN_HASH_VALUE,
   SQL_ADAPTIVE_PLAN_RESOLVED,
   SQL_PLAN_LINE_ID, 
   SQL_PLAN_OPERATION, SQL_PLAN_OPTIONS,
   SQL_EXEC_ID, 
   SQL_EXEC_START,
   /* PL/SQL attributes */
   PLSQL_ENTRY_OBJECT_ID, 
   PLSQL_ENTRY_SUBPROGRAM_ID, 
   PLSQL_OBJECT_ID, 
   PLSQL_SUBPROGRAM_ID, 
   /* PQ attributes */
   QC_INSTANCE_ID, QC_SESSION_ID, QC_SESSION_SERIAL#, PX_FLAGS,
   /* Wait event attributes */
   EVENT, 
   EVENT_ID, 
   SEQ#, 
   P1TEXT, P1, 
   P2TEXT, P2, 
   P3TEXT, P3, 
   WAIT_CLASS, 
   WAIT_CLASS_ID,
   WAIT_TIME, 
   SESSION_STATE,
   TIME_WAITED,
   BLOCKING_SESSION_STATUS,
   BLOCKING_SESSION,
   BLOCKING_SESSION_SERIAL#,
   BLOCKING_INST_ID,
   BLOCKING_HANGCHAIN_INFO,
   /* Session's working context */
   CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#,
   TOP_LEVEL_CALL#, TOP_LEVEL_CALL_NAME,
   CONSUMER_GROUP_ID, 
   XID,
   REMOTE_INSTANCE#,
   TIME_MODEL,
   IN_CONNECTION_MGMT,
   IN_PARSE,
   IN_HARD_PARSE,
   IN_SQL_EXECUTION,
   IN_PLSQL_EXECUTION,
   IN_PLSQL_RPC,
   IN_PLSQL_COMPILATION,
   IN_JAVA_EXECUTION,
   IN_BIND,
   IN_CURSOR_CLOSE,
   IN_SEQUENCE_LOAD,
   IN_INMEMORY_QUERY,
   IN_INMEMORY_POPULATE,
   IN_INMEMORY_PREPOPULATE,
   IN_INMEMORY_REPOPULATE,
   IN_INMEMORY_TREPOPULATE,
   IN_TABLESPACE_ENCRYPTION,
   CAPTURE_OVERHEAD,
   REPLAY_OVERHEAD,
   IS_CAPTURED,
   IS_REPLAYED,
   IS_REPLAY_SYNC_TOKEN_HOLDER,
   /* Application attributes */
   SERVICE_HASH, PROGRAM, MODULE, ACTION, CLIENT_ID, 
   MACHINE,
   PORT, ECID,
   /* DB Replay info */
   DBREPLAY_FILE_ID, DBREPLAY_CALL_COUNTER,
   /* STASH columns */
   TM_DELTA_TIME,
   TM_DELTA_CPU_TIME,
   TM_DELTA_DB_TIME,
   DELTA_TIME,
   DELTA_READ_IO_REQUESTS,
   DELTA_WRITE_IO_REQUESTS,
   DELTA_READ_IO_BYTES,
   DELTA_WRITE_IO_BYTES,
   DELTA_INTERCONNECT_IO_BYTES,
   PGA_ALLOCATED,
   TEMP_SPACE_ALLOCATED,
   /* dbop attributes */
   DBOP_NAME,
   DBOP_EXEC_ID,
   /* PDB Attributes */
   CON_DBID, CON_ID)
as
select /* ASH/AWR meta attributes */
       ash.snap_id, ash.dbid, ash.instance_number, 
       ash.sample_id, ash.sample_time, ash.sample_time_utc,
       ash.usecs_per_row,
       /* Session/User attributes */
       ash.session_id, ash.session_serial#, 
       decode(ash.session_type, 1,'FOREGROUND', 'BACKGROUND'),
       ash.flags,
       ash.user_id,
       /* SQL attributes */
       ash.sql_id, 
       decode(bitand(ash.flags, power(2, 4)), NULL, 'N', 0, 'N', 'Y'),
       ash.sql_child_number, ash.sql_opcode,
       (select command_name
          from WRH$_SQLCOMMAND_NAME s
         where s.command_type = ash.sql_opcode
           and s.dbid = ash.dbid
           and s.con_dbid = ash.dbid) as sql_opname,
       ash.force_matching_signature,
       decode(ash.top_level_sql_id, NULL, ash.sql_id, ash.top_level_sql_id),
       decode(ash.top_level_sql_id, NULL, ash.sql_opcode, 
              ash.top_level_sql_opcode),
       /* SQL Plan/Execution attributes */
       ash.sql_plan_hash_value,
       ash.sql_full_plan_hash_value,
       ash.sql_adaptive_plan_resolved,
       decode(ash.sql_plan_line_id, 0, to_number(NULL), ash.sql_plan_line_id),
       (select operation_name
          from WRH$_PLAN_OPERATION_NAME pn
         where  pn.operation_id = ash.sql_plan_operation# 
           and  pn.dbid = ash.dbid 
           and  pn.con_dbid = ash.dbid) as sql_plan_operation,
       (select option_name
          from WRH$_PLAN_OPTION_NAME po
         where  po.option_id = ash.sql_plan_options# 
           and  po.dbid = ash.dbid 
           and  po.con_dbid = ash.dbid) as sql_plan_options,
       decode(ash.sql_exec_id, 0, to_number(NULL), ash.sql_exec_id),
       ash.sql_exec_start,
       /* PL/SQL attributes */
       decode(ash.plsql_entry_object_id,0,to_number(NULL),
              ash.plsql_entry_object_id),
       decode(ash.plsql_entry_object_id,0,to_number(NULL),
              ash.plsql_entry_subprogram_id),
       decode(ash.plsql_object_id,0,to_number(NULL),
              ash.plsql_object_id),
       decode(ash.plsql_object_id,0,to_number(NULL),
              ash.plsql_subprogram_id),
       /* PQ attributes */
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_instance_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_serial#),
       decode(ash.px_flags,      0, to_number(NULL), ash.px_flags),
       /* Wait event attributes */
       decode(ash.wait_time, 0, evt.event_name, NULL),
       decode(ash.wait_time, 0, evt.event_id,   NULL),
       ash.seq#, 
       evt.parameter1, ash.p1, 
       evt.parameter2, ash.p2, 
       evt.parameter3, ash.p3, 
       decode(ash.wait_time, 0, evt.wait_class,    NULL),
       decode(ash.wait_time, 0, evt.wait_class_id, NULL),
       ash.wait_time, 
       decode(ash.wait_time, 0, 'WAITING', 'ON CPU'),
       ash.time_waited,
       (case when ash.blocking_session = 4294967295
               then 'UNKNOWN'
             when ash.blocking_session = 4294967294
               then 'GLOBAL'
             when ash.blocking_session = 4294967293
               then 'UNKNOWN'
             when ash.blocking_session = 4294967292
               then 'NO HOLDER'
             when ash.blocking_session = 4294967291
               then 'NOT IN WAIT'
             else 'VALID'
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session_serial#
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295 
               then to_number(NULL)
             else ash.blocking_inst_id
          end), 
       (case when ash.blocking_session between 4294967291 and 4294967295 
               then NULL
             else decode(bitand(ash.flags, power(2, 3)), NULL, 'N', 
                         0, 'N', 'Y')
          end),
       /* Session's working context */
       ash.current_obj#, ash.current_file#, ash.current_block#, 
       ash.current_row#, ash.top_level_call#,
       (select top_level_call_name
          from WRH$_TOPLEVELCALL_NAME t
         where top_level_call# = ash.top_level_call#
           and t.dbid = ash.dbid
           and t.con_dbid = ash.dbid) as top_level_call_name,
       decode(ash.consumer_group_id, 0, to_number(NULL), 
              ash.consumer_group_id),
       ash.xid,
       decode(ash.remote_instance#, 0, to_number(NULL), ash.remote_instance#),
       ash.time_model,
       decode(bitand(ash.time_model,power(2, 3)),0,'N','Y') 
                                                         as in_connection_mgmt,
       decode(bitand(ash.time_model,power(2, 4)),0,'N','Y')as in_parse,
       decode(bitand(ash.time_model,power(2, 7)),0,'N','Y')as in_hard_parse,
       decode(bitand(ash.time_model,power(2,10)),0,'N','Y')as in_sql_execution,
       decode(bitand(ash.time_model,power(2,11)),0,'N','Y')
                                                         as in_plsql_execution,
       decode(bitand(ash.time_model,power(2,12)),0,'N','Y')as in_plsql_rpc,
       decode(bitand(ash.time_model,power(2,13)),0,'N','Y')
                                                       as in_plsql_compilation,
       decode(bitand(ash.time_model,power(2,14)),0,'N','Y')
                                                       as in_java_execution,
       decode(bitand(ash.time_model,power(2,15)),0,'N','Y')as in_bind,
       decode(bitand(ash.time_model,power(2,16)),0,'N','Y')as in_cursor_close,
       decode(bitand(ash.time_model,power(2,17)),0,'N','Y')as in_sequence_load,
       decode(bitand(ash.time_model,power(2,18)),0,'N','Y')as in_inmemory_query,
       decode(bitand(ash.time_model,power(2,19)),0,'N','Y')
                                                        as in_inmemory_populate,
       decode(bitand(ash.time_model,power(2,20)),0,'N','Y')
                                                     as in_inmemory_prepopulate,
       decode(bitand(ash.time_model,power(2,21)),0,'N','Y')
                                                      as in_inmemory_repopulate,
       decode(bitand(ash.time_model,power(2,22)),0,'N','Y')
                                                     as in_inmemory_trepopulate,
       decode(bitand(ash.time_model,power(2,23)),0,'N','Y')
                                               as in_tablespace_encryption,
       decode(bitand(ash.flags,power(2,5)),NULL,'N',0,'N','Y')
                                                       as capture_overhead,
       decode(bitand(ash.flags,power(2,6)), NULL,'N',0,'N','Y' )
                                                           as replay_overhead,
       decode(bitand(ash.flags,power(2,0)),NULL,'N',0,'N','Y') as is_captured,
       decode(bitand(ash.flags,power(2,2)), NULL,'N',0,'N','Y' )as is_replayed,
       decode(bitand(ash.flags,power(2,8)), NULL,'N',0,'N','Y')
             as is_replay_sync_token_holder,
       /* Application attributes */
       ash.service_hash,
       &KEWR_MASK_ASH_PROGRAM, -- Use macro to mask sensitive column
       substrb(ash.module,1,(select ksumodlen from x$modact_length)) module,
       substrb(ash.action,1,(select ksuactlen from x$modact_length)) action,
       ash.client_id,
       &KEWR_MASK_ASH_MACHINE, -- Use macro to mask sensitive column
       ash.port, ash.ecid,
       /* DB Replay info */
       ash.dbreplay_file_id, ash.dbreplay_call_counter,
       /* stash columns */
       ash.tm_delta_time,
       ash.tm_delta_cpu_time,
       ash.tm_delta_db_time,
       ash.delta_time,
       ash.delta_read_io_requests,
       ash.delta_write_io_requests,
       ash.delta_read_io_bytes,
       ash.delta_write_io_bytes,
       ash.delta_interconnect_io_bytes,
       ash.pga_allocated,
       ash.temp_space_allocated,
       ash.dbop_name,
       ash.dbop_exec_id,
       decode(ash.con_dbid, 0, ash.dbid, ash.con_dbid),
       decode(ash.per_pdb, 0, 0,
         con_dbid_to_id(decode(ash.con_dbid, 0, ash.dbid, ash.con_dbid))) con_id
from WRM$_SNAPSHOT sn, WRH$_ACTIVE_SESSION_HISTORY ash, WRH$_EVENT_NAME evt
where      ash.snap_id          = sn.snap_id(+)
      and  ash.dbid             = sn.dbid(+)
      and  ash.instance_number  = sn.instance_number(+)
      and  ash.dbid             = evt.dbid(+)
      and  ash.event_id         = evt.event_id(+)
/

comment on table AWR_PDB_ACTIVE_SESS_HISTORY is
'Active Session Historical Statistics Information'
/
create or replace public synonym AWR_PDB_ACTIVE_SESS_HISTORY 
    for AWR_PDB_ACTIVE_SESS_HISTORY
/
grant select on AWR_PDB_ACTIVE_SESS_HISTORY to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_ASH_SNAPSHOTS
 ***************************************/
create or replace view AWR_PDB_ASH_SNAPSHOT
 as
select snap_id, dbid, instance_number, startup_time, begin_interval_time,
       end_interval_time, flush_elapsed, snap_level, status, error_count,
       bl_moved, snap_flag, snap_timezone,
       decode(con_dbid_to_id(s.dbid), 1, 0, con_dbid_to_id(s.dbid)) con_id
  from wrm$_snapshot s 
 where s.status in (0,1)        
   and s.flush_elapsed is not null 
   and (s.snap_id,dbid,instance_number) not in 
       (select e.snap_id,dbid,instance_number 
          from WRM$_SNAP_ERROR e
         where e.table_name = 'WRH$_ACTIVE_SESSION_HISTORY');
       
/
-- create a public synonym for the view
create or replace public synonym AWR_PDB_ASH_SNAPSHOT
  for AWR_PDB_ASH_SNAPSHOT
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE
grant select on AWR_PDB_ASH_SNAPSHOT to SELECT_CATALOG_ROLE
/



/***************************************
 *      AWR_PDB_TABLESPACE_STAT
 ***************************************/

create or replace view AWR_PDB_TABLESPACE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, TSNAME, CONTENTS, 
   STATUS, SEGMENT_SPACE_MANAGEMENT, EXTENT_MANAGEMENT,
   IS_BACKUP, CON_DBID, CON_ID)
as
select tbs.snap_id, tbs.dbid, tbs.instance_number, tbs.ts#, tsname, contents, 
       tbs.status, segment_space_management, extent_management,
       is_backup,
       decode(tbs.con_dbid, 0, tbs.dbid, tbs.con_dbid), 
       decode(tbs.per_pdb, 0, 0,
         con_dbid_to_id(decode(tbs.con_dbid, 0, tbs.dbid, tbs.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_TABLESPACE_STAT tbs
where      tbs.snap_id          = sn.snap_id
      and  tbs.dbid             = sn.dbid
      and  tbs.instance_number  = sn.instance_number
/

comment on table AWR_PDB_TABLESPACE_STAT is
'Tablespace Historical Statistics Information'
/
create or replace public synonym AWR_PDB_TABLESPACE_STAT 
    for AWR_PDB_TABLESPACE_STAT
/
grant select on AWR_PDB_TABLESPACE_STAT to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_LOG
 ***************************************/

create or replace view AWR_PDB_LOG
  (SNAP_ID, DBID, INSTANCE_NUMBER, GROUP#, THREAD#, SEQUENCE#,
   BYTES, MEMBERS, ARCHIVED, STATUS, FIRST_CHANGE#, FIRST_TIME,
   CON_DBID, CON_ID)
as
select log.snap_id, log.dbid, log.instance_number, 
       group#, thread#, sequence#, bytes, members, 
       archived, log.status, first_change#, first_time,
       decode(log.con_dbid, 0, log.dbid, log.con_dbid),
       decode(log.per_pdb, 0, 0,
         con_dbid_to_id(decode(log.con_dbid, 0, log.dbid, log.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_LOG log
  where     sn.snap_id         = log.snap_id
        and sn.dbid            = log.dbid
        and sn.instance_number = log.instance_number
/

comment on table AWR_PDB_LOG is
'Log Historical Statistics Information'
/
create or replace public synonym AWR_PDB_LOG 
    for AWR_PDB_LOG
/
grant select on AWR_PDB_LOG to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_MTTR_TARGET_ADVICE
 ***************************************/

create or replace view AWR_PDB_MTTR_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, MTTR_TARGET_FOR_ESTIMATE,
   ADVICE_STATUS, DIRTY_LIMIT, 
   ESTD_CACHE_WRITES, ESTD_CACHE_WRITE_FACTOR, 
   ESTD_TOTAL_WRITES, ESTD_TOTAL_WRITE_FACTOR,
   ESTD_TOTAL_IOS, ESTD_TOTAL_IO_FACTOR, CON_DBID, CON_ID)
as
select mt.snap_id, mt.dbid, mt.instance_number, mttr_target_for_estimate,
       advice_status, dirty_limit, 
       estd_cache_writes, estd_cache_write_factor, 
       estd_total_writes, estd_total_write_factor,
       estd_total_ios, estd_total_io_factor,
       decode(mt.con_dbid, 0, mt.dbid, mt.con_dbid),
       decode(mt.per_pdb, 0, 0,
         con_dbid_to_id(decode(mt.con_dbid, 0, mt.dbid, mt.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_MTTR_TARGET_ADVICE mt
  where     sn.snap_id         = mt.snap_id
        and sn.dbid            = mt.dbid
        and sn.instance_number = mt.instance_number
/

comment on table AWR_PDB_MTTR_TARGET_ADVICE is
'Mean-Time-To-Recover Target Advice History'
/
create or replace public synonym AWR_PDB_MTTR_TARGET_ADVICE 
    for AWR_PDB_MTTR_TARGET_ADVICE
/
grant select on AWR_PDB_MTTR_TARGET_ADVICE to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_TBSPC_SPACE_USAGE
 ***************************************/

create or replace view AWR_PDB_TBSPC_SPACE_USAGE
  (SNAP_ID, DBID, TABLESPACE_ID, TABLESPACE_SIZE,
   TABLESPACE_MAXSIZE, TABLESPACE_USEDSIZE, RTIME, CON_DBID, CON_ID)
as
select tb.snap_id, tb.dbid, tablespace_id, tablespace_size,
       tablespace_maxsize, tablespace_usedsize, rtime,
       decode(tb.con_dbid, 0, tb.dbid, tb.con_dbid),
       decode(tb.per_pdb, 0, 0,
         con_dbid_to_id(decode(tb.con_dbid, 0, tb.dbid, tb.con_dbid))) con_id
  from (select distinct snap_id, dbid 
          from AWR_PDB_SNAPSHOT) sn, 
       WRH$_TABLESPACE_SPACE_USAGE tb
  where     sn.snap_id         = tb.snap_id
        and sn.dbid            = tb.dbid
/

comment on table AWR_PDB_TBSPC_SPACE_USAGE is
'Tablespace Usage Historical Statistics Information'
/
create or replace public synonym AWR_PDB_TBSPC_SPACE_USAGE 
    for AWR_PDB_TBSPC_SPACE_USAGE
/
grant select on AWR_PDB_TBSPC_SPACE_USAGE to SELECT_CATALOG_ROLE
/




/*********************************
 *     AWR_PDB_SERVICE_NAME
 *********************************/

create or replace view AWR_PDB_SERVICE_NAME
  (DBID, SERVICE_NAME_HASH, SERVICE_NAME, CON_DBID, CON_ID)
as
select dbid, service_name_hash, service_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_SERVICE_NAME sn
/
comment on table AWR_PDB_SERVICE_NAME is
'Service Names'
/
create or replace public synonym AWR_PDB_SERVICE_NAME 
    for AWR_PDB_SERVICE_NAME
/
grant select on AWR_PDB_SERVICE_NAME to SELECT_CATALOG_ROLE
/




/*********************************
 *     AWR_PDB_SERVICE_STAT
 *********************************/

create or replace view AWR_PDB_SERVICE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME,
   STAT_ID, STAT_NAME, VALUE, CON_DBID, CON_ID)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, sv.service_name, 
       nm.stat_id, nm.stat_name, value,
       decode(st.con_dbid, 0, st.dbid, st.con_dbid),
       decode(st.per_pdb, 0, 0,
         con_dbid_to_id(decode(st.con_dbid, 0, st.dbid, st.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SERVICE_STAT st, 
       WRH$_SERVICE_NAME sv, WRH$_STAT_NAME nm
  where    st.service_name_hash = sv.service_name_hash
      and  st.dbid              = sv.dbid
      and  st.stat_id           = nm.stat_id
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  st.con_dbid          = sv.con_dbid
/
comment on table AWR_PDB_SERVICE_STAT is
'Historical Service Statistics'
/
create or replace public synonym AWR_PDB_SERVICE_STAT 
    for AWR_PDB_SERVICE_STAT
/
grant select on AWR_PDB_SERVICE_STAT to SELECT_CATALOG_ROLE
/



/***********************************
 *   AWR_PDB_SERVICE_WAIT_CLASS
 ***********************************/

create or replace view AWR_PDB_SERVICE_WAIT_CLASS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME, 
   WAIT_CLASS_ID, WAIT_CLASS, TOTAL_WAITS, TIME_WAITED, CON_DBID, CON_ID)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, nm.service_name, 
       wait_class_id, wait_class, total_waits, time_waited,
       decode(st.con_dbid, 0, st.dbid, st.con_dbid),
       decode(st.per_pdb, 0, 0,
         con_dbid_to_id(decode(st.con_dbid, 0, st.dbid, st.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SERVICE_WAIT_CLASS st, 
       WRH$_SERVICE_NAME nm
  where    st.service_name_hash = nm.service_name_hash
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  st.con_dbid          = nm.con_dbid
/
comment on table AWR_PDB_SERVICE_WAIT_CLASS is
'Historical Service Wait Class Statistics'
/
create or replace public synonym AWR_PDB_SERVICE_WAIT_CLASS 
    for AWR_PDB_SERVICE_WAIT_CLASS
/
grant select on AWR_PDB_SERVICE_WAIT_CLASS to SELECT_CATALOG_ROLE
/




/***********************************
 *   AWR_PDB_SESS_TIME_STATS
 ***********************************/

create or replace view AWR_PDB_SESS_TIME_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER, SESSION_TYPE, MIN_LOGON_TIME,
   SUM_CPU_TIME, SUM_SYS_IO_WAIT, SUM_USER_IO_WAIT, CON_DBID, 
   SESSION_MODULE, CON_ID)
as
select st.snap_id, st.dbid, st.instance_number, st.session_type,
       st.min_logon_time, st.sum_cpu_time, st.sum_sys_io_wait,
       st.sum_user_io_wait, 
       decode(st.con_dbid, 0, st.dbid, st.con_dbid),
       st.session_module,
       decode(st.per_pdb, 0, 0,
         con_dbid_to_id(decode(st.con_dbid, 0, st.dbid, st.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SESS_TIME_STATS st
  where    st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
/
comment on table AWR_PDB_SESS_TIME_STATS is
'CPU And I/O Time For High Utilization Streams/GoldenGate/XStream sessions'
/
create or replace public synonym AWR_PDB_SESS_TIME_STATS
    for AWR_PDB_SESS_TIME_STATS
/
grant select on AWR_PDB_SESS_TIME_STATS to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_STREAMS_CAPTURE
 ***************************************/

create or replace view AWR_PDB_STREAMS_CAPTURE
  (SNAP_ID, DBID, INSTANCE_NUMBER, CAPTURE_NAME, STARTUP_TIME, LAG,
   TOTAL_MESSAGES_CAPTURED, TOTAL_MESSAGES_ENQUEUED,
   ELAPSED_RULE_TIME, ELAPSED_ENQUEUE_TIME,
   ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME, CON_DBID, CON_ID)
as
select cs.snap_id, cs.dbid, cs.instance_number, cs.capture_name, 
       cs.startup_time, cs.lag,
       cs.total_messages_captured, cs.total_messages_enqueued,
       cs.elapsed_rule_time, cs.elapsed_enqueue_time,
       cs.elapsed_redo_wait_time, cs.elapsed_pause_time,
       decode(cs.con_dbid, 0, cs.dbid, cs.con_dbid),
       decode(cs.per_pdb, 0, 0,
         con_dbid_to_id(decode(cs.con_dbid, 0, cs.dbid, cs.con_dbid))) con_id
  from wrh$_streams_capture cs, AWR_PDB_SNAPSHOT sn
  where     cs.session_module = 'Streams'
        and sn.snap_id          = cs.snap_id
        and sn.dbid             = cs.dbid
        and sn.instance_number  = cs.instance_number
/

comment on table AWR_PDB_STREAMS_CAPTURE is
'STREAMS Capture Historical Statistics Information'
/
create or replace public synonym AWR_PDB_STREAMS_CAPTURE
    for AWR_PDB_STREAMS_CAPTURE
/
grant select on AWR_PDB_STREAMS_CAPTURE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_CAPTURE
 ***************************************/
create or replace view AWR_PDB_CAPTURE
  (SNAP_ID, DBID, INSTANCE_NUMBER, CAPTURE_NAME, STARTUP_TIME, LAG,
   TOTAL_MESSAGES_CAPTURED, TOTAL_MESSAGES_ENQUEUED,
   ELAPSED_RULE_TIME, ELAPSED_ENQUEUE_TIME,
   ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME, CON_DBID,
   EXTRACT_NAME, BYTES_REDO_MINED, BYTES_SENT,
   SESSION_MODULE, CON_ID)
as
select cs.snap_id, cs.dbid, cs.instance_number, cs.capture_name,
       cs.startup_time, cs.lag,
       cs.total_messages_captured, cs.total_messages_enqueued,
       cs.elapsed_rule_time, cs.elapsed_enqueue_time,
       cs.elapsed_redo_wait_time, cs.elapsed_pause_time,
       decode(cs.con_dbid, 0, cs.dbid, cs.con_dbid),
       cs.extract_name,
       cs.bytes_redo_mined, cs.bytes_sent, cs.session_module,
       decode(cs.per_pdb, 0, 0,
         con_dbid_to_id(decode(cs.con_dbid, 0, cs.dbid, cs.con_dbid))) con_id
  from wrh$_streams_capture cs, AWR_PDB_SNAPSHOT sn
  where sn.snap_id              = cs.snap_id
        and sn.dbid             = cs.dbid
        and sn.instance_number  = cs.instance_number
/

comment on table AWR_PDB_CAPTURE is
'Streams/GoldenGate/XStream Capture Historical Statistics Information'
/
create or replace public synonym AWR_PDB_CAPTURE
    for AWR_PDB_CAPTURE
/
grant select on AWR_PDB_CAPTURE to SELECT_CATALOG_ROLE
/




/***********************************************
 *        AWR_PDB_STREAMS_APPLY_SUM
 ***********************************************/

create or replace view AWR_PDB_STREAMS_APPLY_SUM
  (SNAP_ID, DBID, INSTANCE_NUMBER, APPLY_NAME, STARTUP_TIME,
   READER_TOTAL_MESSAGES_DEQUEUED, READER_LAG,
   coord_total_received, coord_total_applied, coord_total_rollbacks,
   coord_total_wait_deps, coord_total_wait_cmts, coord_lwm_lag,
   server_total_messages_applied, server_elapsed_dequeue_time,
   server_elapsed_apply_time, CON_DBID, CON_ID)
as
select sas.snap_id, sas.dbid, sas.instance_number, sas.apply_name,
       sas.startup_time, sas.reader_total_messages_dequeued, sas.reader_lag,
       sas.coord_total_received, sas.coord_total_applied,
       sas.coord_total_rollbacks, sas.coord_total_wait_deps,
       sas.coord_total_wait_cmts, sas.coord_lwm_lag,
       sas.server_total_messages_applied, sas.server_elapsed_dequeue_time,
       sas.server_elapsed_apply_time,
       decode(sas.con_dbid, 0, sas.dbid, sas.con_dbid),
       decode(sas.per_pdb, 0, 0,
         con_dbid_to_id(decode(sas.con_dbid, 0, sas.dbid, sas.con_dbid))) con_id
  from wrh$_streams_apply_sum sas, AWR_PDB_SNAPSHOT sn
  where     sas.session_module = 'Streams'
        and sn.snap_id          = sas.snap_id
        and sn.dbid             = sas.dbid
        and sn.instance_number  = sas.instance_number
/

comment on table AWR_PDB_STREAMS_APPLY_SUM is
'STREAMS Apply Historical Statistics Information'
/
create or replace public synonym AWR_PDB_STREAMS_APPLY_SUM
    for AWR_PDB_STREAMS_APPLY_SUM
/
grant select on AWR_PDB_STREAMS_APPLY_SUM to SELECT_CATALOG_ROLE
/



/***********************************************
 *        AWR_PDB_APPLY_SUMMARY
 ***********************************************/

create or replace view AWR_PDB_APPLY_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, APPLY_NAME, STARTUP_TIME,
   READER_TOTAL_MESSAGES_DEQUEUED, READER_LAG,
   coord_total_received, coord_total_applied, coord_total_rollbacks,
   coord_total_wait_deps, coord_total_wait_cmts, coord_lwm_lag,
   server_total_messages_applied, server_elapsed_dequeue_time,
   server_elapsed_apply_time, CON_DBID,
   replicat_name, unassigned_complete_txn, 
   total_lcrs_retried, total_transactions_retried, 
   total_errors, session_module, CON_ID)
as
select sas.snap_id, sas.dbid, sas.instance_number, sas.apply_name,
       sas.startup_time, sas.reader_total_messages_dequeued, sas.reader_lag,
       sas.coord_total_received, sas.coord_total_applied,
       sas.coord_total_rollbacks, sas.coord_total_wait_deps,
       sas.coord_total_wait_cmts, sas.coord_lwm_lag,
       sas.server_total_messages_applied, sas.server_elapsed_dequeue_time,
       sas.server_elapsed_apply_time, 
       decode(sas.con_dbid, 0, sas.dbid, sas.con_dbid),
       sas.replicat_name, sas.unassigned_complete_txn, 
       sas.total_lcrs_retried,
       sas.total_transactions_retried, sas.total_errors, sas.session_module,
       decode(sas.per_pdb, 0, 0,
         con_dbid_to_id(decode(sas.con_dbid, 0, sas.dbid, sas.con_dbid))) con_id
  from wrh$_streams_apply_sum sas, AWR_PDB_SNAPSHOT sn
  where sn.snap_id              = sas.snap_id
        and sn.dbid             = sas.dbid
        and sn.instance_number  = sas.instance_number
/

comment on table AWR_PDB_APPLY_SUMMARY is
'Streams/Goldengate/XStream Apply Historical Statistics Information'
/
create or replace public synonym AWR_PDB_APPLY_SUMMARY
    for AWR_PDB_APPLY_SUMMARY
/
grant select on AWR_PDB_APPLY_SUMMARY to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_BUFFERED_QUEUES
 *****************************************/

create or replace view AWR_PDB_BUFFERED_QUEUES
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME, STARTUP_TIME,
   QUEUE_ID, NUM_MSGS, SPILL_MSGS, CNUM_MSGS, CSPILL_MSGS, EXPIRED_MSGS,
   OLDEST_MSGID, OLDEST_MSG_ENQTM, QUEUE_STATE,
   ELAPSED_ENQUEUE_TIME, ELAPSED_DEQUEUE_TIME, ELAPSED_TRANSFORMATION_TIME,
   ELAPSED_RULE_EVALUATION_TIME, ENQUEUE_CPU_TIME, DEQUEUE_CPU_TIME,
   LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME, CON_DBID, CON_ID)
as
select qs.snap_id, qs.dbid, qs.instance_number, qs.queue_schema, qs.queue_name,
       qs.startup_time, qs.queue_id, qs.num_msgs, qs.spill_msgs, qs.cnum_msgs,
       qs.cspill_msgs, qs.expired_msgs, qs.oldest_msgid, qs.oldest_msg_enqtm,
       qs.queue_state, qs.elapsed_enqueue_time,
       qs.elapsed_dequeue_time, qs.elapsed_transformation_time,
       qs.elapsed_rule_evaluation_time, qs.enqueue_cpu_time, 
       qs.dequeue_cpu_time, qs.last_enqueue_time, qs.last_dequeue_time,
       decode(qs.con_dbid, 0, qs.dbid, qs.con_dbid),
       decode(qs.per_pdb, 0, 0,
         con_dbid_to_id(decode(qs.con_dbid, 0, qs.dbid, qs.con_dbid))) con_id
  from wrh$_buffered_queues qs, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = qs.snap_id
        and sn.dbid             = qs.dbid
        and sn.instance_number  = qs.instance_number
/

comment on table AWR_PDB_BUFFERED_QUEUES is
'STREAMS Buffered Queues Historical Statistics Information'
/
create or replace public synonym AWR_PDB_BUFFERED_QUEUES
    for AWR_PDB_BUFFERED_QUEUES
/
grant select on AWR_PDB_BUFFERED_QUEUES to SELECT_CATALOG_ROLE
/



/**********************************************
 *        AWR_PDB_BUFFERED_SUBSCRIBERS
 **********************************************/

create or replace view AWR_PDB_BUFFERED_SUBSCRIBERS
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME,
   SUBSCRIBER_ID, SUBSCRIBER_NAME, SUBSCRIBER_ADDRESS, SUBSCRIBER_TYPE,
   STARTUP_TIME, LAST_BROWSED_SEQ, LAST_BROWSED_NUM, LAST_DEQUEUED_SEQ,
   LAST_DEQUEUED_NUM, CURRENT_ENQ_SEQ, NUM_MSGS, CNUM_MSGS,
   TOTAL_DEQUEUED_MSG, TOTAL_SPILLED_MSG, EXPIRED_MSGS, MESSAGE_LAG, 
   ELAPSED_DEQUEUE_TIME, DEQUEUE_CPU_TIME, LAST_DEQUEUE_TIME, OLDEST_MSGID, 
   OLDEST_MSG_ENQTM, CON_DBID, CON_ID)
as
select ss.snap_id, ss.dbid, ss.instance_number, ss.queue_schema, ss.queue_name,
       ss.subscriber_id, ss.subscriber_name, ss.subscriber_address,
       ss.subscriber_type, ss.startup_time, ss.last_browsed_seq,
       ss.last_browsed_num, ss.last_dequeued_seq, ss.last_dequeued_num,
       ss.current_enq_seq, ss.num_msgs, ss.cnum_msgs,
       ss.total_dequeued_msg, ss.total_spilled_msg, ss.expired_msgs, 
       ss.message_lag, ss.elapsed_dequeue_time, ss.dequeue_cpu_time,
       ss.last_dequeue_time, ss.oldest_msgid, ss.oldest_msg_enqtm,
       decode(ss.con_dbid, 0, ss.dbid, ss.con_dbid),
       decode(ss.per_pdb, 0, 0,
         con_dbid_to_id(decode(ss.con_dbid, 0, ss.dbid, ss.con_dbid))) con_id
  from wrh$_buffered_subscribers ss, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = ss.snap_id
        and sn.dbid             = ss.dbid
        and sn.instance_number  = ss.instance_number
/

comment on table AWR_PDB_BUFFERED_SUBSCRIBERS is
'STREAMS Buffered Queue Subscribers Historical Statistics Information'
/
create or replace public synonym AWR_PDB_BUFFERED_SUBSCRIBERS
    for AWR_PDB_BUFFERED_SUBSCRIBERS
/
grant select on AWR_PDB_BUFFERED_SUBSCRIBERS to SELECT_CATALOG_ROLE
/



/**********************************************
 *        AWR_PDB_RULE_SET
 **********************************************/

create or replace view AWR_PDB_RULE_SET
  (SNAP_ID, DBID, INSTANCE_NUMBER, OWNER, NAME,
  STARTUP_TIME, CPU_TIME, ELAPSED_TIME, EVALUATIONS, SQL_FREE_EVALUATIONS,
  SQL_EXECUTIONS, RELOADS, CON_DBID, CON_ID)
as
select rs.snap_id, rs.dbid, rs.instance_number,
       rs.owner, rs.name, rs.startup_time, rs.cpu_time, rs.elapsed_time,
       rs.evaluations, rs.sql_free_evaluations, rs.sql_executions, rs.reloads,
       decode(rs.con_dbid, 0, rs.dbid, rs.con_dbid),
       decode(rs.per_pdb, 0, 0,
         con_dbid_to_id(decode(rs.con_dbid, 0, rs.dbid, rs.con_dbid))) con_id
  from wrh$_rule_set rs, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = rs.snap_id
        and sn.dbid             = rs.dbid
        and sn.instance_number  = rs.instance_number
/

comment on table AWR_PDB_RULE_SET is
'Rule sets historical statistics information'
/
create or replace public synonym AWR_PDB_RULE_SET
    for AWR_PDB_RULE_SET
/
grant select on AWR_PDB_RULE_SET to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_PERSISTENT_QUEUES
 *****************************************/

create or replace view AWR_PDB_PERSISTENT_QUEUES
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME, QUEUE_ID, 
   FIRST_ACTIVITY_TIME, ENQUEUED_MSGS, DEQUEUED_MSGS, BROWSED_MSGS,
   ELAPSED_ENQUEUE_TIME, ELAPSED_DEQUEUE_TIME, ENQUEUE_CPU_TIME, 
   DEQUEUE_CPU_TIME, AVG_MSG_AGE, DEQUEUED_MSG_LATENCY, 
   ELAPSED_TRANSFORMATION_TIME, 
   ELAPSED_RULE_EVALUATION_TIME, ENQUEUED_EXPIRY_MSGS, ENQUEUED_DELAY_MSGS,
   MSGS_MADE_EXPIRED, MSGS_MADE_READY, LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME,
   LAST_TM_EXPIRY_TIME, LAST_TM_READY_TIME, ENQUEUE_TRANSACTIONS,
   DEQUEUE_TRANSACTIONS, EXECUTION_COUNT, CON_DBID, CON_ID)
as
select pqs.snap_id, pqs.dbid, pqs.instance_number, pqs.queue_schema, 
       pqs.queue_name,pqs.queue_id, pqs.first_activity_time, pqs.enqueued_msgs,
       pqs.dequeued_msgs, pqs.browsed_msgs, pqs.elapsed_enqueue_time, 
       pqs.elapsed_dequeue_time, pqs.enqueue_cpu_time, pqs.dequeue_cpu_time,
       pqs.avg_msg_age, pqs.dequeued_msg_latency,
       pqs.elapsed_transformation_time, pqs.elapsed_rule_evaluation_time,
       pqs.enqueued_expiry_msgs, pqs.enqueued_delay_msgs, 
       pqs.msgs_made_expired, pqs.msgs_made_ready, pqs.last_enqueue_time,
       pqs.last_dequeue_time, pqs.last_tm_expiry_time, pqs.last_tm_ready_time,
       pqs.enqueue_transactions, pqs.dequeue_transactions, pqs.execution_count,
       decode(pqs.con_dbid, 0, pqs.dbid, pqs.con_dbid),
       decode(pqs.per_pdb, 0, 0,
         con_dbid_to_id(decode(pqs.con_dbid, 0, pqs.dbid, pqs.con_dbid))) con_id
  from wrh$_persistent_queues pqs, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = pqs.snap_id
        and sn.dbid             = pqs.dbid
        and sn.instance_number  = pqs.instance_number
/

comment on table AWR_PDB_PERSISTENT_QUEUES is
'STREAMS AQ Persistent Queues Historical Statistics Information'
/
create or replace public synonym AWR_PDB_PERSISTENT_QUEUES
    for AWR_PDB_PERSISTENT_QUEUES
/
grant select on AWR_PDB_PERSISTENT_QUEUES to SELECT_CATALOG_ROLE
/



/**********************************************
 *        AWR_PDB_PERSISTENT_SUBS
 **********************************************/

create or replace view AWR_PDB_PERSISTENT_SUBS
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME,
   SUBSCRIBER_ID, SUBSCRIBER_NAME, SUBSCRIBER_ADDRESS, SUBSCRIBER_TYPE,
   FIRST_ACTIVITY_TIME, ENQUEUED_MSGS, DEQUEUED_MSGS, AVG_MSG_AGE,BROWSED_MSGS,
   EXPIRED_MSGS, DEQUEUED_MSG_LATENCY, LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME,
   ELAPSED_DEQUEUE_TIME,DEQUEUE_CPU_TIME,DEQUEUE_TRANSACTIONS, EXECUTION_COUNT,
   CON_DBID, CON_ID)
as
select pss.snap_id, pss.dbid, pss.instance_number,
       pss.queue_schema, pss.queue_name, pss.subscriber_id,
       pss.subscriber_name, pss.subscriber_address, pss.subscriber_type,
       pss.first_activity_time, pss.enqueued_msgs, pss.dequeued_msgs, 
       pss.avg_msg_age, pss.browsed_msgs,
       pss.expired_msgs, pss.dequeued_msg_latency, pss.last_enqueue_time,
       pss.last_dequeue_time, pss.elapsed_dequeue_time,pss.dequeue_cpu_time,
       pss.dequeue_transactions, pss.execution_count,
       decode(pss.con_dbid, 0, pss.dbid, pss.con_dbid),
       decode(pss.per_pdb, 0, 0,
         con_dbid_to_id(decode(pss.con_dbid, 0, pss.dbid, pss.con_dbid))) con_id
  from wrh$_persistent_subscribers pss, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = pss.snap_id
        and sn.dbid             = pss.dbid
        and sn.instance_number  = pss.instance_number
/

comment on table AWR_PDB_PERSISTENT_SUBS is
'STREAMS AQ Persistent Queue Subscribers Historical Statistics Information'
/
create or replace public synonym AWR_PDB_PERSISTENT_SUBS
    for AWR_PDB_PERSISTENT_SUBS
/
grant select on AWR_PDB_PERSISTENT_SUBS to SELECT_CATALOG_ROLE
/



/***********************************
 *   AWR_PDB_SESS_SGA_STATS
 ***********************************/

create or replace view AWR_PDB_SESS_SGA_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER, OBJECT_NAME, SESSION_TYPE,
   SESSION_MODULE, SGA_USED, SGA_ALLOCATED, CON_DBID, CON_ID)
as
select st.snap_id, st.dbid, st.instance_number, st.object_name,
       st.session_type, st.session_module, st.sga_used, st.sga_allocated,
       decode(st.con_dbid, 0, st.dbid, st.con_dbid),
       decode(st.per_pdb, 0, 0,
         con_dbid_to_id(decode(st.con_dbid, 0, st.dbid, st.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_SESS_SGA_STATS st
  where    st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
/
comment on table AWR_PDB_SESS_SGA_STATS is
'SGA Usage Stats For High Utilization GoldenGate/XStream Sessions'
/
create or replace public synonym AWR_PDB_SESS_SGA_STATS
    for AWR_PDB_SESS_SGA_STATS
/
grant select on AWR_PDB_SESS_SGA_STATS to SELECT_CATALOG_ROLE
/



/**************************************
 *   AWR_PDB_REPLICATION_TBL_STATS
 **************************************/

create or replace view AWR_PDB_REPLICATION_TBL_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   APPLY_NAME, TABLE_NAME, TABLE_OWNER, SESSION_MODULE,
   TOTAL_INSERTS, TOTAL_UPDATES, TOTAL_DELETES, 
   CDR_SUCCESSFUL, CDR_FAILED, REPERR_CNT, HANDLE_COLLISIONS, 
   CON_DBID, CON_ID)
as
select rt.snap_id, rt.dbid, rt.instance_number, rt.apply_name,
       rt.table_name, rt.table_owner, rt.session_module,
       rt.total_inserts, rt.total_updates, 
       rt.total_deletes, rt.cdr_successful, rt.cdr_failed, rt.reperr_cnt, 
       rt.handle_collisions, 
       decode(rt.con_dbid, 0, rt.dbid, rt.con_dbid),
       decode(rt.per_pdb, 0, 0,
         con_dbid_to_id(decode(rt.con_dbid, 0, rt.dbid, rt.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_REPLICATION_TBL_STATS rt
  where    rt.snap_id           = sn.snap_id
      and  rt.dbid              = sn.dbid
      and  rt.instance_number   = sn.instance_number
/
comment on table AWR_PDB_REPLICATION_TBL_STATS is
'Replication Table Stats For GoldenGate/XStream Sessions'
/
create or replace public synonym AWR_PDB_REPLICATION_TBL_STATS
    for AWR_PDB_REPLICATION_TBL_STATS
/
grant select on AWR_PDB_REPLICATION_TBL_STATS to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_REPLICATION_TXN_STATS
 *****************************************/
create or replace view AWR_PDB_REPLICATION_TXN_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER, OBJECT_NAME, SESSION_TYPE,
   SESSION_MODULE, SOURCE_DATABASE, SOURCE_TXN_ID, FIRST_LCR_TIME, 
   TOTAL_LCRS_COUNT, CON_DBID, CON_ID)
as
select rt.snap_id, rt.dbid, rt.instance_number,
       rt.object_name, rt.session_type, rt.session_module, rt.source_database, 
       rt.source_txn_id, rt.first_lcr_time, rt.total_lcrs_count,
       decode(rt.con_dbid, 0, rt.dbid, rt.con_dbid),
       decode(rt.per_pdb, 0, 0,
         con_dbid_to_id(decode(rt.con_dbid, 0, rt.dbid, rt.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_REPLICATION_TXN_STATS rt
  where    rt.snap_id           = sn.snap_id
      and  rt.dbid              = sn.dbid
      and  rt.instance_number   = sn.instance_number
/
comment on table AWR_PDB_REPLICATION_TXN_STATS is
'Replication Transaction Stats For GoldenGate/XStream Sessions'
/
create or replace public synonym AWR_PDB_REPLICATION_TXN_STATS
    for AWR_PDB_REPLICATION_TXN_STATS
/
grant select on AWR_PDB_REPLICATION_TXN_STATS to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_IOSTAT_FUNCTION
 ***************************************/

create or replace view AWR_PDB_IOSTAT_FUNCTION
  (SNAP_ID, DBID, INSTANCE_NUMBER, FUNCTION_ID, FUNCTION_NAME, 
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, LARGE_READ_REQS, LARGE_WRITE_REQS,
   NUMBER_OF_WAITS, WAIT_TIME, CON_DBID, CON_ID) 
as
select io.snap_id, io.dbid, io.instance_number, 
       nm.function_id, nm.function_name, 
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, 
       io.large_read_reqs, io.large_write_reqs,
       io.number_of_waits, io.wait_time,
       decode(io.con_dbid, 0, io.dbid, io.con_dbid),
       decode(io.per_pdb, 0, 0,
         con_dbid_to_id(decode(io.con_dbid, 0, io.dbid, io.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_IOSTAT_FUNCTION io, 
       WRH$_IOSTAT_FUNCTION_NAME nm
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and io.function_id     = nm.function_id
        and io.dbid            = nm.dbid
/
comment on table AWR_PDB_IOSTAT_FUNCTION is
'Historical I/O statistics by function'
/
create or replace public synonym AWR_PDB_IOSTAT_FUNCTION 
  for AWR_PDB_IOSTAT_FUNCTION
/
grant select on AWR_PDB_IOSTAT_FUNCTION to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_IOSTAT_FUNCTION_NAME
 ***************************************/

create or replace view AWR_PDB_IOSTAT_FUNCTION_NAME
  (DBID, FUNCTION_ID, FUNCTION_NAME, CON_DBID, CON_ID)
as
select dbid, 
       function_id, 
       function_name,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from WRH$_IOSTAT_FUNCTION_NAME
/
comment on table AWR_PDB_IOSTAT_FUNCTION_NAME is
'Function names for historical I/O statistics'
/
create or replace public synonym AWR_PDB_IOSTAT_FUNCTION_NAME 
  for AWR_PDB_IOSTAT_FUNCTION_NAME
/
grant select on AWR_PDB_IOSTAT_FUNCTION_NAME to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_IOSTAT_FILETYPE
 ***************************************/

create or replace view AWR_PDB_IOSTAT_FILETYPE
  (SNAP_ID, DBID, INSTANCE_NUMBER, FILETYPE_ID, FILETYPE_NAME,
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, SMALL_SYNC_READ_REQS,
   LARGE_READ_REQS, LARGE_WRITE_REQS,
   SMALL_READ_SERVICETIME, SMALL_WRITE_SERVICETIME, SMALL_SYNC_READ_LATENCY, 
   LARGE_READ_SERVICETIME, LARGE_WRITE_SERVICETIME, RETRIES_ON_ERROR, 
   CON_DBID, CON_ID)
as
select io.snap_id, io.dbid, io.instance_number, 
       nm.filetype_id, nm.filetype_name,
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, io.small_sync_read_reqs,
       io.large_read_reqs, io.large_write_reqs,
       io.small_read_servicetime, io.small_write_servicetime, 
       io.small_sync_read_latency, 
       io.large_read_servicetime, io.large_write_servicetime, 
       io.retries_on_error,
       decode(io.con_dbid, 0, io.dbid, io.con_dbid),
       decode(io.per_pdb, 0, 0,
         con_dbid_to_id(decode(io.con_dbid, 0, io.dbid, io.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_IOSTAT_FILETYPE io, WRH$_IOSTAT_FILETYPE_NAME nm
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and io.filetype_id     = nm.filetype_id
        and io.dbid            = nm.dbid
/
comment on table AWR_PDB_IOSTAT_FILETYPE is
'Historical I/O statistics by file type'
/
create or replace public synonym AWR_PDB_IOSTAT_FILETYPE 
  for AWR_PDB_IOSTAT_FILETYPE
/
grant select on AWR_PDB_IOSTAT_FILETYPE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_IOSTAT_FILETYPE_NAME
 ***************************************/

create or replace view AWR_PDB_IOSTAT_FILETYPE_NAME
  (DBID, FILETYPE_ID, FILETYPE_NAME, CON_DBID, CON_ID)
as
select dbid, 
       filetype_id, 
       filetype_name, 
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from WRH$_IOSTAT_FILETYPE_NAME
/
comment on table AWR_PDB_IOSTAT_FILETYPE_NAME is
'File type names for historical I/O statistics'
/
create or replace public synonym AWR_PDB_IOSTAT_FILETYPE_NAME 
  for AWR_PDB_IOSTAT_FILETYPE_NAME
/
grant select on AWR_PDB_IOSTAT_FILETYPE_NAME to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_IOSTAT_DETAIL
 ***************************************/

create or replace view AWR_PDB_IOSTAT_DETAIL
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FUNCTION_ID, FUNCTION_NAME, FILETYPE_ID, FILETYPE_NAME,
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, LARGE_READ_REQS, LARGE_WRITE_REQS,
   NUMBER_OF_WAITS, WAIT_TIME, CON_DBID, CON_ID) 
as
select io.snap_id, io.dbid, io.instance_number, 
       io.function_id, nmfn.function_name, 
       io.filetype_id, nmft.filetype_name,
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, 
       io.large_read_reqs, io.large_write_reqs,
       io.number_of_waits, io.wait_time,
       decode(io.con_dbid, 0, io.dbid, io.con_dbid),
       decode(io.per_pdb, 0, 0,
         con_dbid_to_id(decode(io.con_dbid, 0, io.dbid, io.con_dbid))) con_id
  from  AWR_PDB_SNAPSHOT sn, WRH$_IOSTAT_DETAIL io, 
        WRH$_IOSTAT_FUNCTION_NAME nmfn, WRH$_IOSTAT_FILETYPE_NAME nmft
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and io.function_id     = nmfn.function_id
        and io.dbid            = nmfn.dbid
        and io.filetype_id     = nmft.filetype_id
        and io.dbid            = nmft.dbid
/
comment on table AWR_PDB_IOSTAT_DETAIL is
'Historical I/O statistics by function and filetype'
/
create or replace public synonym AWR_PDB_IOSTAT_DETAIL
  for AWR_PDB_IOSTAT_DETAIL
/
grant select on AWR_PDB_IOSTAT_DETAIL to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_RSRC_CONSUMER_GROUP
 ***************************************/

create or replace view AWR_PDB_RSRC_CONSUMER_GROUP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   SEQUENCE#,
   CONSUMER_GROUP_ID, 
   CONSUMER_GROUP_NAME, 
   REQUESTS,
   CPU_WAIT_TIME, 
   CPU_WAITS,
   CONSUMED_CPU_TIME,
   YIELDS,
   ACTIVE_SESS_LIMIT_HIT,
   UNDO_LIMIT_HIT,
   SWITCHES_IN_CPU_TIME,
   SWITCHES_OUT_CPU_TIME,
   SWITCHES_IN_IO_MEGABYTES,
   SWITCHES_OUT_IO_MEGABYTES,
   SWITCHES_IN_IO_REQUESTS,
   SWITCHES_OUT_IO_REQUESTS,
   SWITCHES_IN_IO_LOGICAL,
   SWITCHES_OUT_IO_LOGICAL,
   SWITCHES_IN_ELAPSED_TIME,
   SWITCHES_OUT_ELAPSED_TIME,
   PGA_LIMIT_SESSIONS_KILLED,
   SQL_CANCELED,
   ACTIVE_SESS_KILLED,
   IDLE_SESS_KILLED,
   IDLE_BLKR_SESS_KILLED,
   QUEUED_TIME,
   QUEUE_TIME_OUTS,
   IO_SERVICE_TIME,
   IO_SERVICE_WAITS,
   SMALL_READ_MEGABYTES,
   SMALL_WRITE_MEGABYTES,
   LARGE_READ_MEGABYTES,
   LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQUESTS,
   SMALL_WRITE_REQUESTS,
   LARGE_READ_REQUESTS,
   LARGE_WRITE_REQUESTS,
   PQS_QUEUED,
   PQ_QUEUED_TIME,
   PQ_QUEUE_TIME_OUTS,
   PQS_COMPLETED,
   PQ_SERVERS_USED,
   PQ_ACTIVE_TIME,
   CON_DBID, CON_ID)
as
select 
  cg.snap_id,
  cg.dbid,
  cg.instance_number,
  cg.sequence#,
  cg.consumer_group_id,
  cg.consumer_group_name,
  cg.requests,
  cg.cpu_wait_time,
  cg.cpu_waits,
  cg.consumed_cpu_time,
  cg.yields,
  cg.active_sess_limit_hit,
  cg.undo_limit_hit,
  cg.switches_in_cpu_time,
  cg.switches_out_cpu_time,
  cg.switches_in_io_megabytes,
  cg.switches_out_io_megabytes,
  cg.switches_in_io_requests,
  cg.switches_out_io_requests,
  cg.switches_in_io_logical,
  cg.switches_out_io_logical,
  cg.switches_in_elapsed_time,
  cg.switches_out_elapsed_time,
  cg.pga_limit_sessions_killed,
  cg.sql_canceled,
  cg.active_sess_killed,
  cg.idle_sess_killed,
  cg.idle_blkr_sess_killed,
  cg.queued_time,
  cg.queue_time_outs,
  cg.io_service_time,
  cg.io_service_waits,
  cg.small_read_megabytes,
  cg.small_write_megabytes,
  cg.large_read_megabytes,
  cg.large_write_megabytes,
  cg.small_read_requests,
  cg.small_write_requests,
  cg.large_read_requests,
  cg.large_write_requests,
  nvl(cg.pqs_queued, 0),
  nvl(cg.pq_queued_time, 0),
  nvl(cg.pq_queue_time_outs, 0),
  nvl(cg.pqs_completed, 0),
  nvl(cg.pq_servers_used, 0),
  nvl(cg.pq_active_time, 0),
  decode(cg.con_dbid, 0, cg.dbid, cg.con_dbid),
  decode(cg.per_pdb, 0, 0,
    con_dbid_to_id(decode(cg.con_dbid, 0, cg.dbid, cg.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RSRC_CONSUMER_GROUP cg
  where     sn.snap_id         = cg.snap_id
        and sn.dbid            = cg.dbid
        and sn.instance_number = cg.instance_number
/
comment on table AWR_PDB_RSRC_CONSUMER_GROUP is
'Historical resource consumer group statistics'
/
create or replace public synonym AWR_PDB_RSRC_CONSUMER_GROUP 
  for AWR_PDB_RSRC_CONSUMER_GROUP
/
grant select on AWR_PDB_RSRC_CONSUMER_GROUP to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_RSRC_PLAN
 ***************************************/

create or replace view AWR_PDB_RSRC_PLAN
  (SNAP_ID, DBID, INSTANCE_NUMBER, SEQUENCE#, START_TIME, END_TIME, 
   PLAN_ID, PLAN_NAME, CPU_MANAGED, PARALLEL_EXECUTION_MANAGED,
   INSTANCE_CAGING, CON_DBID, CON_ID)
as
select 
  pl.snap_id,
  pl.dbid,
  pl.instance_number,
  pl.sequence#,
  pl.start_time, 
  pl.end_time, 
  pl.plan_id, 
  pl.plan_name, 
  pl.cpu_managed,
  nvl(pl.parallel_execution_managed, 'OFF'),
  pl.instance_caging,
  decode(pl.con_dbid, 0, pl.dbid, pl.con_dbid),
  decode(pl.per_pdb, 0, 0,
    con_dbid_to_id(decode(pl.con_dbid, 0, pl.dbid, pl.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RSRC_PLAN pl
  where     sn.snap_id         = pl.snap_id
        and sn.dbid            = pl.dbid
        and sn.instance_number = pl.instance_number
/
comment on table AWR_PDB_RSRC_PLAN is
'Historical resource plan statistics'
/
create or replace public synonym AWR_PDB_RSRC_PLAN 
  for AWR_PDB_RSRC_PLAN
/
grant select on AWR_PDB_RSRC_PLAN to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_RSRC_METRIC
 ***************************************/

create or replace view AWR_PDB_RSRC_METRIC
  (SNAP_ID,
   DBID,
   INSTANCE_NUMBER,
   BEGIN_TIME,
   END_TIME,
   INTSIZE_CSEC,
   SEQUENCE#,
   CONSUMER_GROUP_ID,
   CPU_CONSUMED_TIME,
   CPU_WAIT_TIME,
   AVG_RUNNING_SESSIONS,
   AVG_WAITING_SESSIONS,
   AVG_CPU_UTILIZATION,
   IO_REQUESTS,
   IO_MEGABYTES,
   IOPS,
   IOMBPS,
   AVG_ACTIVE_PARALLEL_STMTS,
   AVG_QUEUED_PARALLEL_STMTS,
   AVG_ACTIVE_PARALLEL_SERVERS,
   AVG_QUEUED_PARALLEL_SERVERS,
   CON_DBID,
   CON_ID)
as
select
  rm.snap_id,
  rm.dbid,
  rm.instance_number,
  rm.begin_time,
  rm.end_time,
  rm.intsize_csec,                                           /* centiseconds */
  rm.sequence#,
  rm.consumer_group_id,
  rm.cpu_consumed_time,                                      /* milliseconds */
  rm.cpu_wait_time,                                          /* milliseconds */
  rm.cpu_consumed_time  / (10 * rm.intsize_csec),    /* avg running sessions */
  rm.cpu_wait_time      / (10 * rm.intsize_csec),    /* avg waiting sessions */
  decode(rm.os_num_cpus, 0, 0,
         (10 * rm.cpu_consumed_time / rm.intsize_csec / rm.os_num_cpus)),
  rm.io_requests,                                                /* requests */
  rm.io_megabytes,                                              /* megabytes */
  rm.io_requests  / (rm.intsize_csec / 100),      /* I/O requests per second */
  rm.io_megabytes / (rm.intsize_csec / 100),     /* I/O megabytes per second */
  rm.pq_active_time / (10 * rm.intsize_csec),   /* avg active parallel stmts */
  rm.pq_queued_time / (10 * rm.intsize_csec),   /* avg queued parallel stmts */
  rm.ps_active_time / (10 * rm.intsize_csec),/* avg running parallel servers */
  rm.ps_queued_time / (10 * rm.intsize_csec),/* avg parallel servers requested
                                              * by queued parallel servers   */
  decode(rm.con_dbid, 0, rm.dbid, rm.con_dbid),
  decode(rm.per_pdb, 0, 0,
    con_dbid_to_id(decode(rm.con_dbid, 0, rm.dbid, rm.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RSRC_METRIC rm 
  where     rm.dbid            = sn.dbid
        and rm.snap_id         = sn.snap_id
        and rm.instance_number = sn.instance_number
/

comment on table AWR_PDB_RSRC_METRIC is
'Historical resource manager metrics'
/
create or replace public synonym AWR_PDB_RSRC_METRIC 
  for AWR_PDB_RSRC_METRIC
/
grant select on AWR_PDB_RSRC_METRIC to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_RSRC_PDB_METRIC
 ***************************************/

create or replace view AWR_PDB_RSRC_PDB_METRIC
  (SNAP_ID,
   DBID,
   INSTANCE_NUMBER,
   BEGIN_TIME,
   END_TIME,
   INTSIZE_CSEC,
   SEQUENCE#,
   CPU_CONSUMED_TIME,
   CPU_WAIT_TIME,
   AVG_RUNNING_SESSIONS,
   AVG_WAITING_SESSIONS,
   AVG_CPU_UTILIZATION,
   IOPS,
   IOMBPS,
   IOPS_THROTTLE_EXEMPT,
   IOMBPS_THROTTLE_EXEMPT,
   AVG_IO_THROTTLE,
   AVG_ACTIVE_PARALLEL_STMTS,
   AVG_QUEUED_PARALLEL_STMTS,
   AVG_ACTIVE_PARALLEL_SERVERS,
   AVG_QUEUED_PARALLEL_SERVERS,
   SGA_BYTES,
   BUFFER_CACHE_BYTES,
   SHARED_POOL_BYTES,
   PGA_BYTES,
   PLAN_ID,
   CON_DBID,
   CON_ID)
as
select
  rm.snap_id,
  rm.dbid,
  rm.instance_number,
  rm.begin_time,
  rm.end_time,
  rm.intsize_csec,                                           /* centiseconds */
  rm.sequence#,
  rm.cpu_consumed_time,                                      /* milliseconds */
  rm.cpu_wait_time,                                          /* milliseconds */
  rm.cpu_consumed_time  / (10 * rm.intsize_csec),    /* avg running sessions */
  rm.cpu_wait_time      / (10 * rm.intsize_csec),    /* avg waiting sessions */
  decode(rm.os_num_cpus, 0, 0,
         (10 * rm.cpu_consumed_time / rm.intsize_csec / rm.os_num_cpus)),
  rm.io_requests  / (rm.intsize_csec / 100),      /* I/O requests per second */
  rm.io_megabytes / (rm.intsize_csec / 100),     /* I/O megabytes per second */
  rm.io_requests_throttle_exempt  / (rm.intsize_csec / 100), 
                           /* I/O requests per second exempt from throttling */
  rm.io_megabytes_throttle_exempt / (rm.intsize_csec / 100),  
                          /* I/O megabytes per second exempt from throttling */
  decode(rm.io_requests, 0, 0,      /* avg I/O throttle time per I/O request */
         rm.io_throttle_time / rm.io_requests),
  rm.pq_active_time / (10 * rm.intsize_csec),   /* avg active parallel stmts */
  rm.pq_queued_time / (10 * rm.intsize_csec),   /* avg queued parallel stmts */
  rm.ps_active_time / (10 * rm.intsize_csec),/* avg running parallel servers */
  rm.ps_queued_time / (10 * rm.intsize_csec),/* avg parallel servers requested
                                              * by queued parallel servers   */
  rm.sga_bytes,                                                     /* bytes */
  rm.buffer_cache_bytes,                                            /* bytes */
  rm.shared_pool_bytes,                                             /* bytes */
  rm.pga_bytes,                                                     /* bytes */
  rm.plan_id,
  decode(rm.con_dbid, 0, rm.dbid, rm.con_dbid),
  decode(rm.per_pdb, 0, 0,
    con_dbid_to_id(decode(rm.con_dbid, 0, rm.dbid, rm.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_RSRC_PDB_METRIC rm
  where     rm.dbid            = sn.dbid
        and rm.snap_id         = sn.snap_id
        and rm.instance_number = sn.instance_number
/
comment on table AWR_PDB_RSRC_PDB_METRIC is
'Historical resource manager metrics by PDB'
/
create or replace public synonym AWR_PDB_RSRC_PDB_METRIC 
  for AWR_PDB_RSRC_PDB_METRIC
/
grant select on AWR_PDB_RSRC_PDB_METRIC to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CLUSTER_INTERCON
 ***************************************/

-- Define macro to mask sensitive system data column.
-- Pass: macro name, macro type, scope, table alias, sensitive column name
@@?/rdbms/admin/awrmacro.sql KEWR_MASK_CI_IP SDM_TYPE MASK_ALL 'ci' 'ip_address'

create or replace view AWR_PDB_CLUSTER_INTERCON
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, IP_ADDRESS, 
   IS_PUBLIC, SOURCE, CON_DBID, CON_ID)
as
select 
  sn.snap_id, sn.dbid, sn.instance_number,
  ci.name,
  &KEWR_MASK_CI_IP, -- Use macro to mask sensitive column
  ci.is_public, ci.source,
  decode(ci.con_dbid, 0, ci.dbid, ci.con_dbid),
  decode(ci. per_pdb, 0, 0,
    con_dbid_to_id(decode(ci.con_dbid, 0, ci.dbid, ci.con_dbid))) con_id
 from AWR_PDB_SNAPSHOT sn, WRH$_CLUSTER_INTERCON ci
 where     sn.snap_id         = ci.snap_id
       and sn.dbid            = ci.dbid
       and sn.instance_number = ci.instance_number
/

-- Undefine the macro
undefine KEWR_MASK_CI_IP

comment on table AWR_PDB_CLUSTER_INTERCON is
'Cluster Interconnect Historical Stats'
/
create or replace public synonym AWR_PDB_CLUSTER_INTERCON 
  for AWR_PDB_CLUSTER_INTERCON
/
grant select on AWR_PDB_CLUSTER_INTERCON to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_MEM_DYNACIC_COMP
 ***************************************/

create or replace view AWR_PDB_MEM_DYNAMIC_COMP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   component ,current_size, min_size, max_size,
   user_specified_size, oper_count, last_oper_type,
   last_oper_mode, last_oper_time, granule_size, CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.component ,t.current_size, t.min_size, t.max_size,
  t.user_specified_size, t.oper_count, t.last_oper_type,
  t.last_oper_mode, t.last_oper_time, t.granule_size,
  decode(t.con_dbid, 0, t.dbid, t.con_dbid),
  con_dbid_to_id(decode(t.con_dbid, 0, t.dbid, t.con_dbid)) con_id
 from AWR_PDB_SNAPSHOT sn, WRH$_MEM_DYNAMIC_COMP t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
/
comment on table AWR_PDB_MEM_DYNAMIC_COMP is
'Historical memory component sizes'
/
create or replace public synonym AWR_PDB_MEM_DYNAMIC_COMP
  for AWR_PDB_MEM_DYNAMIC_COMP
/
grant select on AWR_PDB_MEM_DYNAMIC_COMP to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_IC_CLIENT_STATS
 ***************************************/

create or replace view AWR_PDB_IC_CLIENT_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   name, bytes_sent, bytes_received, CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.name, t.bytes_sent, t.bytes_received,
  decode(t.con_dbid, 0, t.dbid, t.con_dbid),
  decode(t.per_pdb, 0, 0,
    con_dbid_to_id(decode(t.con_dbid, 0, t.dbid, t.con_dbid))) con_id
 from AWR_PDB_SNAPSHOT sn, WRH$_IC_CLIENT_STATS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
/
comment on table AWR_PDB_IC_CLIENT_STATS is
'Historical interconnect client statistics'
/
create or replace public synonym AWR_PDB_IC_CLIENT_STATS
  for AWR_PDB_IC_CLIENT_STATS
/
grant select on AWR_PDB_IC_CLIENT_STATS to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_IC_DEVICE_STATS
 ***************************************/

create or replace view AWR_PDB_IC_DEVICE_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   if_name ,ip_addr ,net_mask ,flags ,mtu ,bytes_received,
   packets_received, receive_errors ,receive_dropped,
   receive_buf_or ,receive_frame_err, bytes_sent ,packets_sent,
   send_errors ,sends_dropped ,send_buf_or, send_carrier_lost,
   CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.if_name ,t.ip_addr ,t.net_mask ,t.flags ,t.mtu ,t.bytes_received,
  t.packets_received, t.receive_errors ,t.receive_dropped,
  t.receive_buf_or ,t.receive_frame_err, t.bytes_sent ,t.packets_sent,
  t.send_errors ,t.sends_dropped ,t.send_buf_or, t.send_carrier_lost,
  decode(t.con_dbid, 0, t.dbid, t.con_dbid),
  decode(t.per_pdb, 0, 0,
    con_dbid_to_id(decode(t.con_dbid, 0, t.dbid, t.con_dbid))) con_id
 from AWR_PDB_SNAPSHOT sn, WRH$_IC_DEVICE_STATS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
/
comment on table AWR_PDB_IC_DEVICE_STATS is
'Historical interconnect device statistics'
/
create or replace public synonym AWR_PDB_IC_DEVICE_STATS
  for AWR_PDB_IC_DEVICE_STATS
/
grant select on AWR_PDB_IC_DEVICE_STATS to SELECT_CATALOG_ROLE
/




/***************************************
 *        AWR_PDB_INTERCONNECT_PINGS
 ***************************************/

create or replace view AWR_PDB_INTERCONNECT_PINGS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   target_instance, cnt_500b, wait_500b, waitsq_500b,
   cnt_8k, wait_8k, waitsq_8k, CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.target_instance, t.cnt_500b, t.wait_500b, t.waitsq_500b,
  t.cnt_8k, t.wait_8k, t.waitsq_8k,
  decode(t.con_dbid, 0, t.dbid, t.con_dbid),
  decode(t.per_pdb, 0, 0,
    con_dbid_to_id(decode(t.con_dbid, 0, t.dbid, t.con_dbid))) con_id
 from AWR_PDB_SNAPSHOT sn, WRH$_INTERCONNECT_PINGS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
/
comment on table AWR_PDB_INTERCONNECT_PINGS is
'Instance to instance ping stats'
/
create or replace public synonym AWR_PDB_INTERCONNECT_PINGS
  for AWR_PDB_INTERCONNECT_PINGS
/
grant select on AWR_PDB_INTERCONNECT_PINGS to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_DISPATCHER
 ***************************************/

create or replace view AWR_PDB_DISPATCHER
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   name, serial#, idle, busy, wait, totalq, sampled_total_conn,
   CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  d.name, d.serial#, d.idle, d.busy, d.wait, d.totalq, d.sampled_total_conn,
  decode(d.con_dbid, 0, d.dbid, d.con_dbid),
  decode(d.per_pdb, 0, 0,
    con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_DISPATCHER d
where     sn.snap_id         = d.snap_id
      and sn.dbid            = d.dbid
      and sn.instance_number = d.instance_number
/
comment on table AWR_PDB_DISPATCHER is
'Dispatcher statistics'
/
create or replace public synonym AWR_PDB_DISPATCHER
    for AWR_PDB_DISPATCHER
/
grant select on AWR_PDB_DISPATCHER to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_SHARED_SERVER_SUMMARY
 ***************************************/

create or replace view AWR_PDB_SHARED_SERVER_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   num_samples, sample_time, 
   sampled_total_conn, sampled_active_conn,
   sampled_total_srv, sampled_active_srv,
   sampled_total_disp, sampled_active_disp,
   srv_busy, srv_idle, srv_in_net, srv_out_net, srv_messages, srv_bytes,
   cq_wait, cq_totalq,
   dq_totalq, CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  s.num_samples, s.sample_time, 
  s.sampled_total_conn, s.sampled_active_conn,
  s.sampled_total_srv, s.sampled_active_srv,
  s.sampled_total_disp, s.sampled_active_disp,
  s.srv_busy, s.srv_idle, s.srv_in_net, s.srv_out_net, 
  s.srv_messages, s.srv_bytes,
  s.cq_wait, s.cq_totalq,
  s.dq_totalq,
  decode(s.con_dbid, 0, s.dbid, s.con_dbid),
  decode(s.per_pdb, 0, 0,
    con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SHARED_SERVER_SUMMARY s
where     sn.snap_id         = s.snap_id
      and sn.dbid            = s.dbid
      and sn.instance_number = s.instance_number
/
comment on table AWR_PDB_SHARED_SERVER_SUMMARY is
'Shared Server summary statistics'
/
create or replace public synonym AWR_PDB_SHARED_SERVER_SUMMARY
  for AWR_PDB_SHARED_SERVER_SUMMARY
/
grant select on AWR_PDB_SHARED_SERVER_SUMMARY to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_DYN_REMASTER_STATS
 ***************************************/

create or replace view AWR_PDB_DYN_REMASTER_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   remaster_type, remaster_ops, remaster_time, remastered_objects, 
   quiesce_time, freeze_time, cleanup_time, 
   replay_time, fixwrite_time, sync_time, 
   resources_cleaned, replayed_locks_sent, 
   replayed_locks_received, current_objects, CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
   s.remaster_type, s.remaster_ops, s.remaster_time, s.remastered_objects,
   s.quiesce_time, s.freeze_time, s.cleanup_time,
   s.replay_time, s.fixwrite_time, s.sync_time,
   s.resources_cleaned, s.replayed_locks_sent,
   s.replayed_locks_received, s.current_objects,
   decode(s.con_dbid, 0, s.dbid, s.con_dbid),
   decode(s.per_pdb, 0, 0,
     con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_DYN_REMASTER_STATS s
where     sn.snap_id         = s.snap_id
      and sn.dbid            = s.dbid
      and sn.instance_number = s.instance_number
/
comment on table AWR_PDB_DYN_REMASTER_STATS is
'Dynamic remastering statistics'
/
create or replace public synonym AWR_PDB_DYN_REMASTER_STATS
  for AWR_PDB_DYN_REMASTER_STATS
/
grant select on AWR_PDB_DYN_REMASTER_STATS to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_LMS_STATS
 ***************************************/

create or replace view AWR_PDB_LMS_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   pid, priority, priority_changes
   , CON_DBID, CON_ID)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
   s.pid, s.priority, s.priority_changes,
   decode(s.con_dbid, 0, s.dbid, s.con_dbid),
   decode(s.per_pdb, 0, 0,
     con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_LMS_STATS s
where     sn.snap_id         = s.snap_id
      and sn.dbid            = s.dbid
      and sn.instance_number = s.instance_number
/
comment on table AWR_PDB_LMS_STATS is
'LMS statistics'
/
create or replace public synonym AWR_PDB_LMS_STATS
  for AWR_PDB_LMS_STATS
/
grant select on AWR_PDB_LMS_STATS to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_PERSISTENT_QMN_CACHE
 *****************************************/

create or replace view AWR_PDB_PERSISTENT_QMN_CACHE
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_TABLE_ID, TYPE, STATUS,
   NEXT_SERVICE_TIME, WINDOW_END_TIME, TOTAL_RUNS, TOTAL_LATENCY,
   TOTAL_ELAPSED_TIME, TOTAL_CPU_TIME, TMGR_ROWS_PROCESSED,
   TMGR_ELAPSED_TIME, TMGR_CPU_TIME, LAST_TMGR_PROCESSING_TIME,
   DEQLOG_ROWS_PROCESSED, DEQLOG_PROCESSING_ELAPSED_TIME,
   DEQLOG_PROCESSING_CPU_TIME, LAST_DEQLOG_PROCESSING_TIME,
   DEQUEUE_INDEX_BLOCKS_FREED, HISTORY_INDEX_BLOCKS_FREED , 
   TIME_INDEX_BLOCKS_FREED, INDEX_CLEANUP_COUNT, INDEX_CLEANUP_ELAPSED_TIME,
   INDEX_CLEANUP_CPU_TIME, LAST_INDEX_CLEANUP_TIME, CON_DBID, CON_ID)
as
select pqc.snap_id, pqc.dbid, pqc.instance_number, pqc.queue_table_id,
       pqc.type, pqc.status, pqc.next_service_time, pqc.window_end_time,
       pqc.TOTAL_RUNS, pqc.TOTAL_LATENCY, pqc.TOTAL_ELAPSED_TIME,
       pqc.TOTAL_CPU_TIME, pqc.TMGR_ROWS_PROCESSED, pqc.TMGR_ELAPSED_TIME,
       pqc.TMGR_CPU_TIME, pqc.LAST_TMGR_PROCESSING_TIME,
       pqc.DEQLOG_ROWS_PROCESSED, pqc.DEQLOG_PROCESSING_ELAPSED_TIME,
       pqc.DEQLOG_PROCESSING_CPU_TIME, pqc.LAST_DEQLOG_PROCESSING_TIME,
       pqc.DEQUEUE_INDEX_BLOCKS_FREED, pqc.HISTORY_INDEX_BLOCKS_FREED,
       pqc.TIME_INDEX_BLOCKS_FREED, pqc.INDEX_CLEANUP_COUNT,
       pqc.INDEX_CLEANUP_ELAPSED_TIME, pqc.INDEX_CLEANUP_CPU_TIME, 
       pqc.LAST_INDEX_CLEANUP_TIME,
       decode(pqc.con_dbid, 0, pqc.dbid, pqc.con_dbid),
       decode(pqc.per_pdb, 0, 0,
         con_dbid_to_id(decode(pqc.con_dbid, 0, pqc.dbid, pqc.con_dbid))) con_id
  from wrh$_persistent_qmn_cache pqc, AWR_PDB_SNAPSHOT sn
  where     sn.snap_id          = pqc.snap_id
        and sn.dbid             = pqc.dbid
        and sn.instance_number  = pqc.instance_number
/

comment on table AWR_PDB_PERSISTENT_QMN_CACHE is
'STREAMS AQ Persistent QMN Cache Historical Statistics Information'
/
create or replace public synonym AWR_PDB_PERSISTENT_QMN_CACHE
    for AWR_PDB_PERSISTENT_QMN_CACHE
/
grant select on AWR_PDB_PERSISTENT_QMN_CACHE to SELECT_CATALOG_ROLE
/


/***************************************
 *   AWR_PDB_PDB_INSTANCE
 ***************************************/
create or replace view AWR_PDB_PDB_INSTANCE
  (DBID, INSTANCE_NUMBER, STARTUP_TIME, 
   CON_DBID, OPEN_TIME, OPEN_MODE, PDB_NAME, CON_ID, SNAP_ID,
   STARTUP_TIME_TZ, OPEN_TIME_TZ)
as
select dbid, instance_number, startup_time, 
       CON_DBID, OPEN_TIME, OPEN_MODE, PDB_NAME, 
       con_dbid_to_id(con_dbid) con_id, snap_id,
       startup_time_tz, open_time_tz
       from wrm$_pdb_instance
/
comment on table AWR_PDB_PDB_INSTANCE is
'Pluggable Database Instance Information'
/
create or replace public synonym AWR_PDB_PDB_INSTANCE
   for AWR_PDB_PDB_INSTANCE
/
grant select on AWR_PDB_PDB_INSTANCE to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_PDB_IN_SNAP
 ***************************************/
create or replace view AWR_PDB_PDB_IN_SNAP
  (SNAP_ID, DBID, INSTANCE_NUMBER, CON_DBID, FLAG, CON_ID, OPEN_TIME_TZ)
as
select snap_id, dbid, instance_number, decode(con_dbid, 0, dbid, con_dbid), 
       flag, con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid)) con_id,
       open_time_tz
       from wrm$_pdb_in_snap
/
comment on table AWR_PDB_PDB_IN_SNAP is
'Pluggable Databases in a snapshot'
/
create or replace public synonym AWR_PDB_PDB_IN_SNAP
   for AWR_PDB_PDB_IN_SNAP
/
grant select on AWR_PDB_PDB_IN_SNAP to SELECT_CATALOG_ROLE
/


/**************************************
 *   AWR_PDB_CELL_CONFIG
 ***************************************/
create or replace view AWR_PDB_CELL_CONFIG
  (DBID, CURRENT_SNAP_ID,
   CELLNAME, CELLHASH, CONFTYPE, CONFVAL_HASH, CONFVAL, CON_DBID, CON_ID)
as
select dbid, CURRENT_SNAP_ID,
       CELLNAME, CELLHASH, CONFTYPE, CONFVAL_HASH, CONFVAL,
       decode(con_dbid, 0, dbid, con_dbid),
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_CELL_CONFIG
/

comment on table AWR_PDB_CELL_CONFIG is 
'Exadata configuration information'
/  
create or replace public synonym AWR_PDB_CELL_CONFIG
  for AWR_PDB_CELL_CONFIG
/  
grant select on AWR_PDB_CELL_CONFIG to SELECT_CATALOG_ROLE
/



/**************************************
 *   AWR_PDB_CELL_CONFIG_DETAIL
 ***************************************/
create or replace view AWR_PDB_CELL_CONFIG_DETAIL
  (SNAP_ID, DBID, 
   CELLNAME, CELLHASH, CONFTYPE, CONFVAL_HASH, CONFVAL, CON_DBID, CON_ID)
as
select d.snap_id, d.dbid, 
       c.CELLNAME, d.CELLHASH, d.CONFTYPE, d.CONFVAL_HASH, c.CONFVAL,
       decode(d.con_dbid, 0, d.dbid, d.con_dbid),
       decode(d.per_pdb, 0, 0,
         con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id
  from WRH$_CELL_CONFIG c,
       WRH$_CELL_CONFIG_DETAIL d
 where c.dbid = d.dbid
   and c.cellhash = d.cellhash
   and c.conftype = d.conftype
   and c.confval_hash = d.confval_hash
/

comment on table AWR_PDB_CELL_CONFIG_DETAIL is 
'Exadata configuration information per snapshot'
/  
create or replace public synonym AWR_PDB_CELL_CONFIG_DETAIL
  for AWR_PDB_CELL_CONFIG_DETAIL
/  
grant select on AWR_PDB_CELL_CONFIG_DETAIL to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_ASM_DISKGROUP
 ***************************************/
create or replace view AWR_PDB_ASM_DISKGROUP
  (DBID, 
   CURRENT_SNAP_ID, GROUP_NUMBER, NAME, TYPE, CON_DBID, CON_ID)
as
select dbid,
       CURRENT_SNAP_ID, GROUP_NUMBER, NAME, TYPE,
       decode(con_dbid, 0, dbid, con_dbid),
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_ASM_DISKGROUP
/  

comment on table AWR_PDB_ASM_DISKGROUP is 
'ASM Diskgroups connected to this Database'
/  
create or replace public synonym AWR_PDB_ASM_DISKGROUP
  for AWR_PDB_ASM_DISKGROUP
/  
grant select on AWR_PDB_ASM_DISKGROUP to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_ASM_DISKGROUP_STAT
 ***************************************/
create or replace view AWR_PDB_ASM_DISKGROUP_STAT
  (SNAP_ID, DBID, 
   GROUP_NUMBER, TOTAL_MB, FREE_MB, NUM_DISK, NUM_FAILGROUP, STATE,
   CON_DBID, CON_ID)
as
select snap_id, dbid,     
       GROUP_NUMBER, TOTAL_MB, FREE_MB, NUM_DISK, NUM_FAILGROUP, STATE,
       decode(con_dbid, 0, dbid, con_dbid),
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_ASM_DISKGROUP_STAT
/  

comment on table AWR_PDB_ASM_DISKGROUP_STAT is
'Statistics for ASM Diskgroup connected to this Database'
/  
create or replace public synonym AWR_PDB_ASM_DISKGROUP_STAT
  for AWR_PDB_ASM_DISKGROUP_STAT
/   
grant select on AWR_PDB_ASM_DISKGROUP_STAT to SELECT_CATALOG_ROLE
/



/***************************************
 *   AWR_PDB_ASM_BAD_DISK
 ***************************************/
create or replace view AWR_PDB_ASM_BAD_DISK
  (SNAP_ID, DBID,
    GROUP_NUMBER, NAME, PATH, STATUS, CON_DBID, CON_ID)
as
select tb.snap_id, tb.dbid,
       GROUP_NUMBER, NAME, PATH, STATUS,
       decode(con_dbid, 0, tb.dbid, con_dbid),
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, tb.dbid, con_dbid))) con_id
  from (select distinct snap_id, dbid
          from AWR_PDB_SNAPSHOT) sn,
       WRH$_ASM_BAD_DISK tb
  where sn.snap_id = tb.snap_id
    and sn.dbid    = tb.dbid
/

comment on table AWR_PDB_ASM_BAD_DISK is
'Non-Online ASM Disks'
/
create or replace public synonym AWR_PDB_ASM_BAD_DISK
  for AWR_PDB_ASM_BAD_DISK
/
grant select on AWR_PDB_ASM_BAD_DISK to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_CELL_NAME
 *****************************************/
create or replace view AWR_PDB_CELL_NAME
(DBID, SNAP_ID, CELL_HASH, CELL_NAME, 
 CON_DBID, CON_ID)
as
select d.dbid,
       d.snap_id,
       c.cellhash cell_hash,
       extractvalue(xmltype(c.confval),'/cli-output/cell/name') cell_name,
       decode(d.con_dbid, 0, d.dbid, d.con_dbid) con_dbid,
       decode(d.per_pdb, 0, 0,
         con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id
  from wrh$_cell_config_detail d,
       wrh$_cell_config c
 where d.dbid = c.dbid
   and d.cellhash = c.cellhash
   and d.conftype = c.conftype
   and d.confval_hash = c.confval_hash
   and c.conftype = 'CELL'
/

comment on table AWR_PDB_CELL_NAME is
'Exadata Cell names'
/
create or replace public synonym AWR_PDB_CELL_NAME
   for AWR_PDB_CELL_NAME
/
grant select on AWR_PDB_CELL_NAME to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_CELL_DISKTYPE
 *****************************************/
create or replace view AWR_PDB_CELL_DISKTYPE
(DBID, SNAP_ID, CELL_HASH, CELL_NAME,
 HARD_DISK_TYPE, FLASH_DISK_TYPE, 
 NUM_CELL_DISKS, NUM_GRID_DISKS, 
 NUM_HARD_DISKS, NUM_FLASH_DISKS, 
 MAX_DISK_IOPS, MAX_FLASH_IOPS, MAX_DISK_MBPS, MAX_FLASH_MBPS,
 MAX_CELL_DISK_IOPS, MAX_CELL_FLASH_IOPS, 
 MAX_CELL_DISK_MBPS, MAX_CELL_FLASH_MBPS,
 CONFVAL,
 CON_DBID, CON_ID)
as
select d.dbid,
       d.snap_id,
       c.cellhash cell_hash,
       extractvalue(xmltype(c.confval),'/cli-output/context/@cell') cell_name,
       extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/hardDiskType') hard_disk_type,
       extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/flashDiskType') flash_disk_type,
       to_number(extractvalue(xmltype(c.confval),
                   '/cli-output/not-set/numCellDisks'))  num_cell_disks,
       to_number(extractvalue(xmltype(c.confval),
                   '/cli-output/not-set/numGridDisks'))  num_grid_disks,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numHardDisks'))  num_hard_disks,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numFlashDisks'))  num_flash_disks,
       to_number(
         extractvalue(xmltype(c.confval),'/cli-output/not-set/maxPDIOPS'))
                                                            max_disk_iops,
       to_number(
         extractvalue(xmltype(c.confval),'/cli-output/not-set/maxFDIOPS'))
                                                           max_flash_iops,
       to_number(
         extractvalue(xmltype(c.confval),'/cli-output/not-set/maxPDMBPS'))
                                                           max_disk_mbps,
       to_number(
         extractvalue(xmltype(c.confval),'/cli-output/not-set/maxFDMBPS'))
                                                         max_flash_mbps,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numHardDisks')) *
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/maxPDIOPS'))  max_cell_disk_iops,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numFlashDisks')) *
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/maxFDIOPS'))  max_cell_flash_iops,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numHardDisks')) *
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/maxPDMBPS'))  max_cell_disk_mbps,
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/numFlashDisks')) *
       to_number(extractvalue(xmltype(c.confval),
                    '/cli-output/not-set/maxFDMBPS'))  max_cell_flash_mbps,
       c.confval,
       decode(d.con_dbid, 0, d.dbid, d.con_dbid) con_dbid,
       decode(d.per_pdb, 0, 0,
         con_dbid_to_id(decode(d.con_dbid, 0, d.dbid, d.con_dbid))) con_id
  from wrh$_cell_config_detail d,
       wrh$_cell_config c
 where d.dbid = c.dbid
   and d.cellhash = c.cellhash
   and d.conftype = c.conftype
   and d.confval_hash = c.confval_hash
   and c.conftype = 'AWRXML'
/

comment on table AWR_PDB_CELL_DISKTYPE is
'Exadata Cell disk types'
/
create or replace public synonym AWR_PDB_CELL_DISKTYPE
   for AWR_PDB_CELL_DISKTYPE
/
grant select on AWR_PDB_CELL_DISKTYPE to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_CELL_DISK_NAME
 *****************************************/
-- tmp workaround for ORA-7445 bug16457282
-- use xmlsequence instead of xmltable
create or replace view AWR_PDB_CELL_DISK_NAME
(DBID, SNAP_ID, CELL_HASH, DISK_ID, DISK_NAME, DISK, 
 CON_DBID, CON_ID)
as
select dbid,
       snap_id,
       cell_hash,
       to_number(substr(id,length(id)-8+1),'XXXXXXXX') disk_id,
       disk_name,
       disk,
       decode(con_dbid, 0, dbid, con_dbid) con_dbid,
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from (
    select d.dbid, d.con_dbid,
           d.snap_id, d.per_pdb,
           d.cellhash cell_hash,
           extractvalue(value(t),'/celldisk/id') id,
           extractvalue(value(t),'/celldisk/name') disk_name,
           extractvalue(value(t),'/celldisk/diskType') disk
      from wrh$_cell_config_detail d,
           wrh$_cell_config c,
           table(xmlsequence(extract(xmltype(c.confval),
                                    '/cli-output/celldisk'))) t
     where d.dbid = c.dbid
       and d.cellhash = c.cellhash
       and d.conftype = c.conftype
       and d.confval_hash = c.confval_hash
       and c.conftype = 'CELLDISK')
/

comment on table AWR_PDB_CELL_DISK_NAME is
'Exadata Cell disk names'
/
create or replace public synonym AWR_PDB_CELL_DISK_NAME
   for AWR_PDB_CELL_DISK_NAME
/
grant select on AWR_PDB_CELL_DISK_NAME to SELECT_CATALOG_ROLE
/



/*****************************************
 *        AWR_PDB_CELL_GLOBAL_SUMMARY
 *****************************************/
create or replace view AWR_PDB_CELL_GLOBAL_SUMMARY
  (SNAP_ID, DBID, CELL_HASH, INCARNATION_NUM, 
   NUM_SAMPLES,
   CPU_USAGE_SUM, SYS_USAGE_SUM, USER_USAGE_SUM,
   NETWORK_BYTES_RECD_SUM, NETWORK_BYTES_SENT_SUM,
   CPU_USAGE_SUMX2, SYS_USAGE_SUMX2, USER_USAGE_SUMX2,
   NETWORK_BYTES_RECD_SUMX2, NETWORK_BYTES_SENT_SUMX2,
   CPU_USAGE_AVG, SYS_USAGE_AVG, USER_USAGE_AVG,
   NETWORK_BYTES_RECD_AVG, NETWORK_BYTES_SENT_AVG,
   CON_DBID, CON_ID)
as
select cg.snap_id, cg.dbid, cg.cell_hash, cg.incarnation_num,
       num_samples,
       cpu_usage_sum, sys_usage_sum, user_usage_sum,
       network_bytes_recd_sum, network_bytes_sent_sum,
       cpu_usage_sumx2, sys_usage_sumx2, user_usage_sumx2,
       network_bytes_recd_sumx2, network_bytes_sent_sumx2,
       cpu_usage_sum/num_samples cpu_usage_avg, 
       sys_usage_sum/num_samples sys_usage_avg, 
       user_usage_sum/num_samples user_usage_avg,
       network_bytes_recd_sum/num_samples network_bytes_recd_avg, 
       network_bytes_sent_sum/num_samples network_bytes_sent_avg,
       decode(cg.con_dbid, 0, cg.dbid, cg.con_dbid),
       decode(cg.per_pdb, 0, 0,
         con_dbid_to_id(decode(cg.con_dbid, 0, cg.dbid, cg.con_dbid))) con_id
  from wrh$_cell_global_summary cg, 
      (select distinct snap_id, dbid
         from AWR_PDB_SNAPSHOT)  sn
  where     sn.snap_id          = cg.snap_id
        and sn.dbid             = cg.dbid
/

comment on table AWR_PDB_CELL_GLOBAL_SUMMARY is
'Cell Global Summary Statistics'
/
create or replace public synonym AWR_PDB_CELL_GLOBAL_SUMMARY
    for AWR_PDB_CELL_GLOBAL_SUMMARY
/
grant select on AWR_PDB_CELL_GLOBAL_SUMMARY to SELECT_CATALOG_ROLE
/




/*****************************************
 *        AWR_PDB_CELL_DISK_SUMMARY
 *****************************************/
create or replace view AWR_PDB_CELL_DISK_SUMMARY
  (SNAP_ID, DBID, CELL_HASH, INCARNATION_NUM, 
   DISK_ID, 
   NUM_SAMPLES,
   DISK_UTILIZATION_SUM,
   READS_SUM, READ_MB_SUM, WRITES_SUM, WRITE_MB_SUM,
   IO_REQUESTS_SUM, IO_MB_SUM,
   SERVICE_TIME_SUM,WAIT_TIME_SUM,
   SMALL_READS_SUM,SMALL_WRITES_SUM,LARGE_READS_SUM,LARGE_WRITES_SUM,
   SMALL_READ_BYTES_SUM,SMALL_WRITE_BYTES_SUM,
   LARGE_READ_BYTES_SUM,LARGE_WRITE_BYTES_SUM,
   SMALL_READ_LATENCY_SUM, SMALL_WRITE_LATENCY_SUM,
   LARGE_READ_LATENCY_SUM, LARGE_WRITE_LATENCY_SUM,
   APP_IO_REQUESTS_SUM, APP_IO_BYTES_SUM, APP_IO_LATENCY_SUM,
   DISK_UTILIZATION_SUMX2,
   READS_SUMX2, READ_MB_SUMX2, WRITES_SUMX2, WRITE_MB_SUMX2,
   IO_REQUESTS_SUMX2, IO_MB_SUMX2,
   SERVICE_TIME_SUMX2,WAIT_TIME_SUMX2,
   SMALL_READS_SUMX2,SMALL_WRITES_SUMX2,LARGE_READS_SUMX2,LARGE_WRITES_SUMX2,
   SMALL_READ_BYTES_SUMX2,SMALL_WRITE_BYTES_SUMX2,
   LARGE_READ_BYTES_SUMX2,LARGE_WRITE_BYTES_SUMX2,
   SMALL_READ_LATENCY_SUMX2, SMALL_WRITE_LATENCY_SUMX2,
   LARGE_READ_LATENCY_SUMX2, LARGE_WRITE_LATENCY_SUMX2,
   APP_IO_REQUESTS_SUMX2, APP_IO_BYTES_SUMX2, APP_IO_LATENCY_SUMX2,
   DISK_UTILIZATION_AVG,
   READS_AVG, READ_MB_AVG, WRITES_AVG, WRITE_MB_AVG,
   IO_REQUESTS_AVG, IO_MB_AVG,
   SERVICE_TIME_AVG,
   SMALL_READS_AVG,SMALL_WRITES_AVG,LARGE_READS_AVG,LARGE_WRITES_AVG,
   SMALL_READ_BYTES_AVG,SMALL_WRITE_BYTES_AVG,
   LARGE_READ_BYTES_AVG,LARGE_WRITE_BYTES_AVG,
   SMALL_READ_LATENCY_AVG, SMALL_WRITE_LATENCY_AVG,
   LARGE_READ_LATENCY_AVG, LARGE_WRITE_LATENCY_AVG,
   APP_IO_REQUESTS_AVG, APP_IO_BYTES_AVG, APP_IO_LATENCY_AVG,
   CON_DBID, CON_ID)
as
select cd.snap_id, cd.dbid, cd.cell_hash, cd.incarnation_num,
       cd.disk_id disk_id,
       num_samples,
       disk_utilization_sum,
       reads_sum, read_mb_sum, writes_sum, write_mb_sum,
       io_requests_sum, io_mb_sum,
       service_time_sum,wait_time_sum,
       small_reads_sum,small_writes_sum,large_reads_sum,large_writes_sum,
       small_read_bytes_sum,small_write_bytes_sum,
       large_read_bytes_sum,large_write_bytes_sum,
       small_read_latency_sum, small_write_latency_sum,
       large_read_latency_sum, large_write_latency_sum,
       app_io_requests_sum, app_io_bytes_sum, app_io_latency_sum,
       disk_utilization_sumx2,
       reads_sumx2, read_mb_sumx2, writes_sumx2, write_mb_sumx2,
       io_requests_sumx2, io_mb_sumx2,
       service_time_sumx2,wait_time_sumx2,
       small_reads_sumx2,small_writes_sumx2,
       large_reads_sumx2,large_writes_sumx2,
       small_read_bytes_sumx2,small_write_bytes_sumx2,
       large_read_bytes_sumx2,large_write_bytes_sumx2,
       small_read_latency_sumx2, small_write_latency_sumx2,
       large_read_latency_sumx2, large_write_latency_sumx2,
       app_io_requests_sumx2, app_io_bytes_sumx2, app_io_latency_sumx2,
       disk_utilization_sum/num_samples disk_utilization_avg,
       reads_sum/num_samples      reads_avg, 
       read_mb_sum/num_samples    read_mb_avg, 
       writes_sum/num_samples     writes_avg, 
       write_mb_sum/num_samples   write_mb_avg,
       io_requests_sum/num_samples         io_requests_avg,
       io_mb_sum/num_samples      io_mb_avg,
       service_time_sum/num_samples service_time_avg,
       small_reads_sum/num_samples      small_reads_avg,
       small_writes_sum/num_samples     small_writes_avg,
       large_reads_sum/num_samples      large_reads_avg,
       large_writes_sum/num_samples     large_writes_avg,
       small_read_bytes_sum/num_samples   small_read_bytes_avg,
       small_write_bytes_sum/num_samples  small_write_bytes_avg,
       large_read_bytes_sum/num_samples   large_read_bytes_avg,
       large_write_bytes_sum/num_samples  large_write_bytes_avg,
       small_read_latency_sum/num_samples small_read_latency_avg,
       small_write_latency_sum/num_samples small_write_latency_avg,
       large_read_latency_sum/num_samples  large_read_latency_avg, 
       large_write_latency_sum/num_samples large_write_latency_avg,
       app_io_requests_sum/num_samples app_io_requests_avg, 
       app_io_bytes_sum/num_samples   app_io_bytes_avg,
       app_io_latency_sum/num_samples app_io_latency_avg,
       decode(cd.con_dbid, 0, cd.dbid, cd.con_dbid),
       decode(cd.per_pdb, 0, 0,
         con_dbid_to_id(decode(cd.con_dbid, 0, cd.dbid, cd.con_dbid))) con_id
  from wrh$_cell_disk_summary cd,
      (select distinct snap_id, dbid
         from AWR_PDB_SNAPSHOT)  sn
  where     sn.snap_id          = cd.snap_id
        and sn.dbid             = cd.dbid
/

comment on table AWR_PDB_CELL_DISK_SUMMARY is
'Cell Disk Summary Statistics'
/
create or replace public synonym AWR_PDB_CELL_DISK_SUMMARY
    for AWR_PDB_CELL_DISK_SUMMARY
/
grant select on AWR_PDB_CELL_DISK_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_METRIC_DESC
 ***************************************/

create or replace view AWR_PDB_CELL_METRIC_DESC
  (DBID, METRIC_ID, METRIC_NAME, METRIC_TYPE, CON_DBID, CON_ID)
as
select dbid, metric_id, metric_name, metric_type,
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from WRH$_CELL_METRIC_DESC
/


comment on table AWR_PDB_CELL_METRIC_DESC is
'Cell Metric Names'
/
create or replace public synonym AWR_PDB_CELL_METRIC_DESC 
                     for AWR_PDB_CELL_METRIC_DESC
/
grant select on AWR_PDB_CELL_METRIC_DESC to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_IOREASON_NAME
 ***************************************/

create or replace view AWR_PDB_CELL_IOREASON_NAME
  (DBID, REASON_ID, REASON_NAME, CON_DBID, CON_ID)
as
select dbid, reason_id, reason_name, 
       decode(con_dbid, 0, dbid, con_dbid), 
       decode(con_dbid_to_id(dbid), 1, 0, con_dbid_to_id(dbid)) con_id
  from WRH$_CELL_IOREASON_NAME
/


comment on table AWR_PDB_CELL_IOREASON_NAME is
'Cell IO Reason Names'
/
create or replace public synonym AWR_PDB_CELL_IOREASON_NAME 
                     for AWR_PDB_CELL_IOREASON_NAME
/
grant select on AWR_PDB_CELL_IOREASON_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_GLOBAL
 ***************************************/

create or replace view AWR_PDB_CELL_GLOBAL
  (SNAP_ID, DBID, CELL_HASH, INCARNATION_NUM, 
   METRIC_ID, METRIC_NAME, METRIC_VALUE, 
   CON_DBID, CON_ID) 
as
select s.snap_id, s.dbid, s.cell_hash, s.incarnation_num,
       s.metric_id, nm.metric_name, s.metric_value,
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       decode(s.per_pdb, 0, 0,
         con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from WRH$_CELL_GLOBAL s,
     WRH$_CELL_METRIC_DESC nm,
    (select distinct snap_id, dbid
       from AWR_PDB_SNAPSHOT) sn 
where      s.metric_id        = nm.metric_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
/


comment on table AWR_PDB_CELL_GLOBAL is
'Cell Global Statistics Information'
/
create or replace public synonym AWR_PDB_CELL_GLOBAL for AWR_PDB_CELL_GLOBAL
/
grant select on AWR_PDB_CELL_GLOBAL to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_IOREASON
 ***************************************/

create or replace view AWR_PDB_CELL_IOREASON
  (SNAP_ID, DBID, CELL_HASH, INCARNATION_NUM, 
   REASON_ID, REASON_NAME, REQUESTS, BYTES,
   CON_DBID, CON_ID) 
as
select s.snap_id, s.dbid, s.cell_hash, s.incarnation_num,
       s.reason_id, nm.reason_name, s.requests, s.bytes,
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       decode(s.per_pdb, 0, 0,
         con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from WRH$_CELL_IOREASON s,
     WRH$_CELL_IOREASON_NAME nm,
    (select distinct snap_id, dbid
       from AWR_PDB_SNAPSHOT) sn 
where      s.reason_id        = nm.reason_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
/


comment on table AWR_PDB_CELL_IOREASON is
'Cell IO Reason Statistics Information'
/
create or replace public synonym AWR_PDB_CELL_IOREASON for AWR_PDB_CELL_IOREASON
/
grant select on AWR_PDB_CELL_IOREASON to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_DB
 ***************************************/

create or replace view AWR_PDB_CELL_DB
  (SNAP_ID, DBID, CELL_HASH, INCARNATION_NUM, 
   SRC_DBID, SRC_DBNAME, 
   DISK_REQUESTS, DISK_BYTES, FLASH_REQUESTS, FLASH_BYTES,
   DISK_SMALL_IO_REQS, DISK_LARGE_IO_REQS,
   FLASH_SMALL_IO_REQS, FLASH_LARGE_IO_REQS,
   DISK_SMALL_IO_SERVICE_TIME, DISK_SMALL_IO_QUEUE_TIME,
   DISK_LARGE_IO_SERVICE_TIME, DISK_LARGE_IO_QUEUE_TIME,
   FLASH_SMALL_IO_SERVICE_TIME, FLASH_SMALL_IO_QUEUE_TIME,
   FLASH_LARGE_IO_SERVICE_TIME, FLASH_LARGE_IO_QUEUE_TIME,
   IS_CURRENT_SRC_DB,
   CON_DBID, CON_ID) 
as
select s.snap_id, s.dbid, s.cell_hash, s.incarnation_num,
       s.src_dbid, s.src_dbname, 
       s.disk_requests, s.disk_bytes, s.flash_requests, s.flash_bytes,
       s.disk_small_io_reqs, s.disk_large_io_reqs,
       s.flash_small_io_reqs, s.flash_large_io_reqs,
       s.disk_small_io_service_time, s. disk_small_io_queue_time,
       s.disk_large_io_service_time, s.disk_large_io_queue_time,
       s.flash_small_io_service_time, s. flash_small_io_queue_time,
       s.flash_large_io_service_time, s.flash_large_io_queue_time,
       s.is_current_src_db,
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       decode(s.per_pdb, 0, 0,
         con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from WRH$_CELL_DB s,
    (select distinct snap_id, dbid
       from AWR_PDB_SNAPSHOT) sn 
where  s.snap_id          = sn.snap_id
  and  s.dbid             = sn.dbid
/


comment on table AWR_PDB_CELL_DB is
'Cell Database IO Statistics Information'
/
create or replace public synonym AWR_PDB_CELL_DB for AWR_PDB_CELL_DB
/
grant select on AWR_PDB_CELL_DB to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_CELL_OPEN_ALERTS
 ***************************************/

create or replace view AWR_PDB_CELL_OPEN_ALERTS
  (SNAP_ID, DBID, CELL_HASH, 
   BEGIN_TIME, SEQ_NO, MESSAGE, STATEFUL, SEVERITY, CELL_ALERT_SUMMARY,
   CON_DBID, CON_ID) 
as
select s.snap_id, s.dbid, s.cell_hash, 
       s.begin_time, s.seq_no, s.message, 
       decode(s.stateful,1,'Y','N') stateful,
       s.severity,
       s.cell_alert_summary,
       decode(s.con_dbid, 0, s.dbid, s.con_dbid), 
       decode(s.per_pdb, 0, 0,
         con_dbid_to_id(decode(s.con_dbid, 0, s.dbid, s.con_dbid))) con_id
from WRH$_CELL_OPEN_ALERTS s,
    (select distinct snap_id, dbid
       from AWR_PDB_SNAPSHOT) sn 
where  s.snap_id          = sn.snap_id
  and  s.dbid             = sn.dbid
/


comment on table AWR_PDB_CELL_OPEN_ALERTS is
'Cell Open Alerts Information'
/
create or replace public synonym AWR_PDB_CELL_OPEN_ALERTS for AWR_PDB_CELL_OPEN_ALERTS
/
grant select on AWR_PDB_CELL_OPEN_ALERTS to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_IM_SEG_STAT
 *  This view is deprecated starting from 12.2.0.2
 ***************************************/

create or replace view AWR_PDB_IM_SEG_STAT 
(SNAP_ID, DBID, INSTANCE_NUMBER, TS#, OBJ#, DATAOBJ#, MEMBYTES, SCANS,
SCANS_DELTA, DB_BLOCK_CHANGES, DB_BLOCK_CHANGES_DELTA, 
POPULATE_CUS, POPULATE_CUS_DELTA, REPOPULATE_CUS, REPOPULATE_CUS_DELTA, 
CON_DBID, CON_ID) 
as 
select seg.snap_id, seg.dbid, seg.instance_number, ts#, 
obj#, dataobj#, 0, 
im_scans_total as scans, im_scans_delta as scans_delta, 
im_db_block_changes_total as db_block_changes, 
im_db_block_changes_delta as db_block_changes_delta,
populate_cus_total as populate_cus, populate_cus_delta,
repopulate_cus_total as repopulate_cus, repopulate_cus_delta, 
decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid), 
decode(seg.per_pdb, 0, 0,
       con_dbid_to_id(decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_SEG_STAT seg
where 
        seg.snap_id         = sn.snap_id 
    and seg.dbid            = sn.dbid 
    and seg.instance_number = sn.instance_number 
    and ((seg.im_scans_total > 0) or (seg.populate_cus_total > 0) or
         (seg.repopulate_cus_total > 0) or (seg.im_db_block_changes_total > 0))
union
select seg.snap_id, seg.dbid, seg.instance_number, ts#, 
obj#, dataobj#, membytes, 
scans, scans_delta, 
db_block_changes,  db_block_changes_delta, 
populate_cus, populate_cus_delta,
repopulate_cus, repopulate_cus_delta,  
decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid), 
decode(seg.per_pdb, 0, 0,
       con_dbid_to_id(decode(seg.con_dbid, 0, seg.dbid, seg.con_dbid))) con_id
from AWR_PDB_SNAPSHOT sn, WRH$_IM_SEG_STAT seg
where 
        seg.snap_id         = sn.snap_id 
    and seg.dbid            = sn.dbid 
    and seg.instance_number = sn.instance_number 
/

comment on table AWR_PDB_IM_SEG_STAT is 
' Historical IM Segment Statistics Information'
/

create or replace public synonym AWR_PDB_IM_SEG_STAT
        for AWR_PDB_IM_SEG_STAT
/
grant select on AWR_PDB_IM_SEG_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        AWR_PDB_IM_SEG_STAT_OBJ
 *  This view is deprecated starting from 12.2.0.2
 ***************************************/

create or replace view AWR_PDB_IM_SEG_STAT_OBJ 
(DBID, TS#, OBJ#, DATAOBJ#, OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_TYPE, 
 TABLESPACE_NAME, CON_DBID, CON_ID)
as 
select so.dbid, so.ts#, so.obj#, so.dataobj#, so.owner, so.object_name, 
       so.subobject_name, so.object_type, 
       coalesce(ts.tsname, tablespace_name) tablespace_name,
       decode(so.con_dbid, 0, so.dbid, so.con_dbid),
       decode(so.per_pdb, 0, 0,
         con_dbid_to_id(decode(so.con_dbid, 0, so.dbid, so.con_dbid))) con_id 
from WRH$_IM_SEG_STAT_OBJ so LEFT OUTER JOIN WRH$_TABLESPACE ts
     on (so.dbid = ts.dbid 
         and so.ts# = ts.ts#
         and so.con_dbid = ts.con_dbid)
union
select so.dbid, so.ts#, so.obj#, so.dataobj#, so.owner, so.object_name, 
       so.subobject_name, so.object_type, 
       coalesce(ts.tsname, tablespace_name) tablespace_name,
       decode(so.con_dbid, 0, so.dbid, so.con_dbid),
       decode(so.per_pdb, 0, 0,
         con_dbid_to_id(decode(so.con_dbid, 0, so.dbid, so.con_dbid))) con_id 
from WRH$_SEG_STAT_OBJ so LEFT OUTER JOIN WRH$_TABLESPACE ts
     on (so.dbid = ts.dbid 
         and so.ts# = ts.ts#
         and so.con_dbid = ts.con_dbid)
/
comment on table AWR_PDB_IM_SEG_STAT_OBJ is 
'IM Segment Names'
/
create or replace public synonym AWR_PDB_IM_SEG_STAT_OBJ 
        for AWR_PDB_IM_SEG_STAT_OBJ 
/
grant select on AWR_PDB_IM_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/ 




/***************************************
 *        AWR_PDB_WR_SETTINGS
 ***************************************/
create or replace view AWR_PDB_WR_SETTINGS
  (LOCAL_AWRDBID,VIEW_LOCATION,CON_ID)
as
select se.local_awrdbid,
       decode(se.view_location,0,'AWR_ROOT',1,'AWR_PDB','INVALID'),
       decode(con_dbid_to_id(se.local_awrdbid), 1, 0,
              con_dbid_to_id(se.local_awrdbid)) con_id
from WRM$_WR_SETTINGS se
/
comment on table AWR_PDB_WR_SETTINGS is
'Workload Repository Settings'
/
create or replace public synonym AWR_PDB_WR_SETTINGS
  for AWR_PDB_WR_SETTINGS
/
grant select on AWR_PDB_WR_SETTINGS to SELECT_CATALOG_ROLE
/


/***************************************
 *       AWR_PDB_PROCESS_WAITTIME
 ***************************************/
create or replace view AWR_PDB_PROCESS_WAITTIME
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   PROCESS_TYPE, DESCRIPTION, WAIT_CLASS_TYPE, VALUE,
   CON_DBID, CON_ID)
as
select cw.snap_id, cw.dbid, cw.instance_number,
       process_type, description, wait_class_type, value,
       decode(cw.con_dbid, 0, cw.dbid, cw.con_dbid),
       decode(cw.per_pdb, 0, 0,
         con_dbid_to_id(decode(cw.con_dbid, 0, cw.dbid, cw.con_dbid))) con_id
  from AWR_PDB_SNAPSHOT sn, WRH$_PROCESS_WAITTIME cw
  where     sn.snap_id         = cw.snap_id
        and sn.dbid            = cw.dbid
        and sn.instance_number = cw.instance_number
/

comment on table AWR_PDB_PROCESS_WAITTIME is 'cpu and wait time by process types'
/
create or replace public synonym AWR_PDB_PROCESS_WAITTIME for AWR_PDB_PROCESS_WAITTIME
/
grant select on AWR_PDB_PROCESS_WAITTIME to SELECT_CATALOG_ROLE
/

/***************************************
 *   AWR_PDB_ASM_DISK_STAT_SUMMARY
 ***************************************/
create or replace view AWR_PDB_ASM_DISK_STAT_SUMMARY
       container_data sharing=object
  (SNAP_ID, DBID, INSTANCE_NUMBER, GROUP_NUMBER,
   READS, WRITES, READ_ERRS, WRITE_ERRS, READ_TIMEOUT, WRITE_TIMEOUT,
   READ_TIME, WRITE_TIME, BYTES_READ, BYTES_WRITTEN,
   CON_DBID, CON_ID)
as
select snap_id, dbid, instance_number, GROUP_NUMBER,
       READS, WRITES, READ_ERRS, WRITE_ERRS, READ_TIMEOUT, WRITE_TIMEOUT,
       READ_TIME, WRITE_TIME, BYTES_READ, BYTES_WRITTEN,
       decode(con_dbid, 0, dbid, con_dbid),
       decode(per_pdb, 0, 0,
         con_dbid_to_id(decode(con_dbid, 0, dbid, con_dbid))) con_id
  from WRH$_ASM_DISK_STAT_SUMMARY
/  

comment on table AWR_PDB_ASM_DISK_STAT_SUMMARY is
'Statistics for ASM Disk summary statistics'
/  
create or replace public synonym AWR_PDB_ASM_DISK_STAT_SUMMARY
  for AWR_PDB_ASM_DISK_STAT_SUMMARY
/   
grant select on AWR_PDB_ASM_DISK_STAT_SUMMARY to SELECT_CATALOG_ROLE
/


@?/rdbms/admin/sqlsessend.sql



