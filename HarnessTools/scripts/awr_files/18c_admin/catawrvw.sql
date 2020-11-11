Rem Copyright (c) 2003, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catawrvw.sql - Catalog script for AWR Views
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR Views. Used to create the  
Rem      Workload Repository Schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catawrvw.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catawrvw.sql
Rem SQL_PHASE: CATAWRVW
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catawrtv.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       11/28/17 - bug 27078828: Add AWR_CDB_* views
Rem    cgervasi    06/26/17 - bug26339298: add wrh$_asm_disk_stat_summary
Rem    yingzhen    02/27/17 - Add DBA_HIST_PROCESS_WAITTIME view
Rem    yingzhen    05/03/16 - bug 22151899: Add Recovery Progress to AWR
Rem    osuro       05/03/16 - add DBA_HIST_CON_SYSTEM_EVENT
Rem    kmorfoni    03/24/16 - Remove predicates on dbid from DBA_HIST% views
Rem    kmorfoni    03/01/16 - add con_id in AWR tables without con_dbid
Rem    ardesai     01/04/16 - read flushed con_id
Rem    osuro       02/12/16 - Add DBA_HIST_WR_SETTINGS view
Rem    yingzhen    02/02/16 - Bug 20421055, remove CDBR_HIST, CDBP_HIST views
Rem                           Create CDB_HIST views on top of AWR_PDB views
Rem    yingzhen    10/23/15 - Bug 22101741: Set dba_hist to awr_root by default
Rem    yingzhen    11/12/15 - Bug 22176929: Add view_location to wr_control
Rem    yingzhen    10/21/15 - add DBA_HIST_CON_SYSSTAT view
Rem    yingzhen    10/06/15 - Bug 21575534: change dba_hist view location
Rem    osuro       09/03/15 - add DBA_HIST_CON_SYS_TIME_MODEL views
Rem    bsprunt     08/26/15 - Bug 21652015: add instance_caging column
Rem    bsprunt     08/21/15 - Bug 21460115: DBA_HIST_RSRC_[PDB_]METRIC views
Rem    osuro       08/05/15 - add DBA_HIST_CON_SYSMETRIC_* views
Rem    cgervasi    07/07/15 - add cell_db time-related columns
Rem    arbalakr    05/13/15 - Enable ASH flush inside a PDB
Rem    yingzhen    05/27/15 - add WRH$_CHANNEL_WAITS
Rem    suelee      04/29/15 - Bug 20898764: PGA limit
Rem    bsprunt     04/16/15 - Bug 15931539: add missing fields to
Rem                           DBA_HIST_RSRC_CONSUMER_GROUP
Rem    bsprunt     04/16/15 - Bug 20556913: add v$rsrcpdbmetric_[history]
Rem    bsprunt     04/16/15 - Bug 20185348: persist v$rsrcmgrmetric_history
Rem    yujwang     04/08/15 - add IS_REPLAY_SYNC_TOKEN_HOLDER to 
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem    arbalakr    02/27/15 - Bug 18822045: Add microseconds per row to ASH
Rem    rmorant     03/03/15 - Bug20330091 corrected DBA_HIST_DATABASE_INSTANCE
Rem    osuro       02/11/15 - renamed pdb snapshot param name
Rem    amorimur    12/23/14 - modify DBA_HIST_CURRENT_BLOCK_SERVER
Rem    amorimur    12/22/14 - add DBA_HIST_LMS_STATS
Rem    ardesai     12/08/14 - Redfine the DBA_HIST views to work based on pdb
Rem                           underscore parameter
Rem    drosash     09/19/14 - Proj 47411: Local Temp Tablespaces
Rem    ardesai     07/19/14 - Changes from myuin_pdb3
Rem                             -- add DBA_HIST_PDB_IN_SNAP
Rem    thbaby      06/10/14 - 18971004: remove INT$ views for OBL cases
Rem    yingzhen    05/07/14 - bug 18648666:map con_id in 2 cell views to 0
Rem    spapadom    05/05/14 - Added deltas to dba_hist_im_seg_stat
Rem    cgervasi    04/16/14 - bug18604160: cell_config add confval_hash
Rem    spapadom    03/04/14 - DBA_HIST_ views for IM Segment stats.
Rem    spapadom    02/18/14 - 17667161:Make DBA_HIST views container_data
Rem    miglees     02/16/14 - Add in_inmemory_repopulate to ASH
Rem    cgervasi    01/21/14 - bug18057967: add DBA_HIST_CELL_DB,
Rem                           DBA_HIST_CELL_OPEN_ALERTS
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    arbalakr    11/21/13 - Bug17425096: Add Full plan hash value to ASH
Rem    cgervasi    11/06/13 - add DBA_HIST_CELL_IOREASON/CELL_IOREASON_NAME
Rem    chinkris    10/10/13 - DBA_HIST_ACTIVE_SESS_HISTORY: rename in_imc_query
Rem                           and in_imc_load to in_inmemory_query and 
Rem                           in_inmemory_populate
Rem    thbaby      09/30/13 - 17518642: add INT$DBA_HIST_CELL_GLOBAL
Rem    shiyadav    09/26/13 - bug 17348607: modify dba_hist_dyn_remaster_stats
Rem    chinkris    09/16/13 - In-memory Columnar: add in_imc_query and 
Rem                           in_imc_load to DBA_HIST_ACTIVE_SESS_HISTORY             
Rem    thbaby      08/28/13 - 14515351: add INT$ views for sharing=object
Rem    cgervasi    08/20/13 - add DBA_HIST_CELL_GLOBAL and 
Rem                           DBA_HIST_CELL_METRIC_DESC
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    cgervasi    06/19/13 - add cellstats
Rem    sidatta     12/20/12 - Adding DBA_HIST_CELL_CONFIG
Rem    svaziran    10/23/12 - bug 14076977: awr report within a PDB
Rem    shiyadav    05/31/12 - bug 13548980: add block_size in WRH$_TABLESPACE
Rem    arbalakr    04/09/12 - Bug 13893883 do not join on con_dbid with name
Rem                           tables in DBA_HIST_ACTIVE_SESS_HISTORY
Rem    ilistvin    04/17/12 - bug13957872: remove con_dbid constraint
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ilistvin    03/02/12 - do not join on con_dbid with name tables
Rem    lzheng      11/01/11 - add wrh$_sess_sga_stats,wrh$_replication_tbl_stats
Rem                           and wrh$_replication_txn_stats for gg/xstream 
Rem    hayu        07/14/11 - add dbop columns to ASH views
Rem    ilistvin    06/30/11 - add CONTAINER_DATA clauses
Rem    ilistvin    06/21/11 - bug12653701: remove dba_hist_pluggable_database
Rem    kyagoub     05/03/11 - set con_dbid to zero in sqltext and sqlstat view
Rem    arbalakr    04/06/11 - Project 35499: Add PDB Attributes to
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem    ilistvin    03/17/11 - CDB Changes
Rem    bdagevil    03/14/10 - add px_flags column to
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem    dongfwan    02/22/10 - Bug 9266913: add snap_timezone to wrm$_snapshot
Rem    sburanaw    02/04/10 - add db replay callid to ASH
Rem    jomcdon     12/31/09 - bug 9212250: add PQQ fields to AWR tables
Rem    ilistvin    11/23/09 - bug8811401: add DBA_HIST_TABLESPACE view
Rem    amadan      11/19/09 - Bug 9115881 Add and Update AQ related AWR views 
Rem    arbalakr    11/12/09 - truncate module/action to max lengths in
Rem                           X$MODACT_LENGTH
Rem    sriganes    07/24/09 - bug 8413874: add multi-valued parameters in AWR
Rem    mfallen     03/20/09 - bug 8347956: add flash cache columns
Rem    akini       03/16/09 - add dba_hist_ash_snapshot
Rem    arbalakr    03/16/09 - bug 8283759: add hostname, port num to ASH view
Rem    arbalakr    02/24/09 - add DBA_HIST_SQLCOMMAND_NAME/TOPLEVELCALL_NAME
Rem    arbalakr    02/23/09 - bug 7350685: add sql_opname,top_level_call#/name
Rem                           to ASH view
Rem    amysoren    02/05/09 - bug 7483450: add foreground values to
Rem                           waitclassmetric
Rem    mfallen     01/04/09 - bug 7650345: add new sqlstat and seg_stat columns
Rem    bdagevil    01/02/09 - add STASH columns to ASH view
Rem    ilistvin    10/22/08 - add DBA_HIST_PLAN_OPTION_NAME and
Rem                           DBA_HIST_PLAN_OPERATION_NAME
Rem    sburanaw    09/29/08 - is_captured/is_replayed, capture/replay_overhead
Rem                           to ash
Rem    ushaft      08/19/08 - add columns to ASH view
Rem    sburanaw    08/15/08 - expose time_mode, is_sqlid_current, in_capture,
Rem                           in_replay in ASH
Rem    amysoren    08/14/08 - add ash bit for sequence load
Rem    mfallen     05/15/08 - bug 7029198: add dba_hist_dyn_remaster_stats
Rem    akini       04/23/08 - added DBA_HIST_IOSTAT_DETAIL
Rem    jgiloni     04/15/08 - Shared Server AWR Stats
Rem    mfallen     03/12/08 - bug 6861722: add dba_hist_db_cache_advice column
Rem    sburanaw    12/11/07 - add blocking_inst_id, ecid to ASH
Rem    pbelknap    03/23/07 - add parsing_user_id to sqlstat
Rem    mlfeng      04/18/07 - platform name to database_instance, 
Rem                           bug with join in iostat views
Rem    sburanaw    03/02/07 - rename column top_sql* to top_level_sql* in
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem                           redefine ash session_type
Rem                           remove in_background column
Rem    ushaft      02/08/07 - add IC_CLIENT_STATS, IC_DEVICE_STATS, 
Rem                           MEM_DYNAMIC_COMP, INTERCONNECT_PINGS
Rem    veeve       03/08/07 - add flags to DBA_HIST_ASH
Rem    amadan      02/10/07 - add first_activity_time to
Rem                           DBA_HIST_PERSISTENT_QUEUES
Rem    mlfeng      12/21/06 - add snap_flag to dba_hist_snapshot
Rem    suelee      01/02/07 - Disable IORM
Rem    ilistvin    11/09/06 - move views with package dependencies to
Rem                           catawrpd.sql
Rem    pbelknap    11/20/06 - add flag column to DBA_HIST_SQLSTAT
Rem    mlfeng      10/25/06 - do not join with BL table
Rem    sburanaw    08/04/06 - rename "time_model" columns to "in_" columns,
Rem                           remove parse columns, redefine session_type     
Rem    sburanaw    08/03/06 - add current_row# to dba_hist_active_sess_history
Rem    ushaft      08/03/06 - add column to pga_target_advice
Rem    mlfeng      07/21/06 - add interconnect table 
Rem    suelee      07/25/06 - Fix units for Resource Manager views 
Rem    mlfeng      07/17/06 - add sum squares 
Rem    veeve       06/23/06 - add new 11g columns to DBA_HIST_ASH
Rem    mlfeng      06/17/06 - remove union all from Baseline tables 
Rem    mlfeng      06/11/06 - add last_time_computed 
Rem    mlfeng      05/20/06 - add columns to baselines 
Rem    suelee      05/18/06 - Add IO statistics tables 
Rem    gngai       04/14/06 - added coloredsql view
Rem    ushaft      05/26/06 - added 16 columns to DBA_HIST_INST_CACHE_TRANSFER
Rem    amadan      05/16/06 - add DBA_HIST_PERSISTENT_QUEUES 
Rem    mlfeng      05/14/06 - add memory views 
Rem    amysoren    05/17/06 - DBA_HIST_SYSTEM_EVENT changes 
Rem    veeve       03/01/06 - modified DBA_HIST_ASH to show eflushed rows
Rem    veeve       02/10/06 - add qc_session_serial# to ASH 
Rem    adagarwa    04/25/05 - Added PL/SQL stack fields to DBA_HIST_ASH
Rem    mlfeng      05/10/05 - add event histogram, mutex sleep 
Rem    mlfeng      05/26/05 - Fix tablespace space usage view
Rem    veeve       03/10/05 - made DBA_HIST_ASH.QC* NULL when invalid
Rem    adagarwa    03/04/05 - Added force_matching_sig,blocking_sesison_srl#
Rem                           to DBA_HIST_ACTIVE_SESS_HISTORY
Rem    narora      03/07/05 - add queue_id to WRH$_BUFFERED_QUEUES 
Rem    kyagoub     09/12/04 - add bind_data to dba_hist_sqlstat 
Rem    veeve       10/19/04 - add p1text,p2text,p3text to 
Rem                           dba_hist_active_sess_history 
Rem    mlfeng      09/21/04 - add parsing_schema_name 
Rem    mlfeng      07/27/04 - add new sql columns, new tables 
Rem    bdagevil    08/02/04 - fix DBA_HIST_SQLBIND view 
Rem    mlfeng      05/21/04 - add topnsql column 
Rem    ushaft      05/26/04 - added DBA_HIST_STREAMS_POOL_ADVICE
Rem    ushaft      05/15/04 - add views for WRH$_COMP_IOSTAT, WRH$_SGA_TARGET..
Rem    bdagevil    05/26/04 - add timestamp column in explain plan 
Rem    bdagevil    05/13/04 - add other_xml column 
Rem    narora      05/20/04 - add wrh$_sess_time_stats, streams tables
Rem    veeve       05/12/04 - made DBA_HIST_ASH similiar to its V$
Rem                           add blocking_session,xid to DBA_HIST_ASH
Rem    mlfeng      04/26/04 - p1, p2, p3 for event name 
Rem    mlfeng      01/30/04 - add gc buffer busy 
Rem    mlfeng      01/12/04 - class -> instance cache transfer 
Rem    mlfeng      12/09/03 - fix bug with baseline view 
Rem    mlfeng      11/24/03 - remove rollstat, add latch_misses_summary
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    mlfeng      08/29/03 - sync up with v$ changes
Rem    mlfeng      08/27/03 - add rac tables 
Rem    mlfeng      07/10/03 - add service stats
Rem    nmacnaug    08/13/03 - remove unused statistic 
Rem    mlfeng      08/04/03 - remove address columns from ash, sql_bind 
Rem    mlfeng      07/25/03 - add group_name to metric name
Rem    gngai       08/01/03 - changed event class metrics
Rem    mramache    06/24/03 - hintset_applied -> sql_profile
Rem    gngai       06/17/03 - changed dba_hist_sysmetric_history
Rem    gngai       06/24/03 - fixed wrh$ views to use union all
Rem    mlfeng      06/03/03 - add wrh$_instance_recovery columns
Rem    mramache    05/20/03 - add plsql/java time columns to DBA_HIST_SQLSTAT
Rem    veeve       04/22/03 - Modified DBA_HIST_ACTIVE_SESS_HISTORY
Rem                           sql_hash_value OUT, sql_id IN, sql_address OUT
Rem    bdagevil    04/23/03 - undostat views: use sql_id instead of signature
Rem    mlfeng      04/22/03 - Modify signature/hash value to sql_id
Rem    mlfeng      04/14/03 - Modify DBA_HIST_SQLSTAT, DBA_HIST_SQLTEXT
Rem    mlfeng      04/11/03 - Add DBA_HIST_OPTIMIZER_ENV
Rem    bdagevil    04/28/03 - merge new file
Rem    mlfeng      03/17/03 - Adding hash to name tables
Rem    mlfeng      04/01/03 - add block size to datafile, tempfile
Rem    veeve       03/05/03 - rename service_id to service_hash
Rem                           in DBA_HIST_ACTIVE_SESS_HISTORY
Rem    mlfeng      03/05/03 - add SQL Bind view
Rem    mlfeng      03/04/03 - add new dba_hist views to sync with catswrtb
Rem    mlfeng      03/04/03 - remove wrh$_idle_event
Rem    mlfeng      02/13/03 - modify dba_hist_event_name
Rem    mlfeng      01/27/03 - mlfeng_swrf_reporting
Rem    mlfeng      01/24/03 - update undostat view
Rem    mlfeng      01/16/03 - Creation of DBA_HIST views
Rem    mlfeng      01/16/03 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

Rem ************************************************************************* 
Rem Creating the Workload Repository History (DBA_HIST) Catalog Views ...
Rem ************************************************************************* 

/***************************************
 *     DBA_HIST_DATABASE_INSTANCE
 ***************************************/

create or replace view DBA_HIST_DATABASE_INSTANCE
as select * from AWR_CDB_DATABASE_INSTANCE
/

comment on table DBA_HIST_DATABASE_INSTANCE is
'Database Instance Information'
/
create or replace public synonym DBA_HIST_DATABASE_INSTANCE 
    for DBA_HIST_DATABASE_INSTANCE
/
grant select on DBA_HIST_DATABASE_INSTANCE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DATABASE_INSTANCE','CDB_HIST_DATABASE_INSTANCE');
grant select on SYS.CDB_HIST_DATABASE_INSTANCE to select_catalog_role
/
create or replace public synonym CDB_HIST_DATABASE_INSTANCE for SYS.CDB_HIST_DATABASE_INSTANCE
/

/***************************************
 *        DBA_HIST_SNAPSHOT
 ***************************************/

/* only the valid snapshots (status = 0) will be displayed) */
create or replace view DBA_HIST_SNAPSHOT
as select * from AWR_CDB_SNAPSHOT
/

comment on table DBA_HIST_SNAPSHOT is
'Snapshot Information'
/
create or replace public synonym DBA_HIST_SNAPSHOT 
    for DBA_HIST_SNAPSHOT
/
grant select on DBA_HIST_SNAPSHOT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SNAPSHOT','CDB_HIST_SNAPSHOT');
grant select on SYS.CDB_HIST_SNAPSHOT to select_catalog_role
/
create or replace public synonym CDB_HIST_SNAPSHOT for SYS.CDB_HIST_SNAPSHOT
/

/***************************************
 *        DBA_HIST_SNAP_ERROR
 ***************************************/

/* shows error information for each snapshot */
create or replace view DBA_HIST_SNAP_ERROR
as select * from AWR_CDB_SNAP_ERROR
/
comment on table DBA_HIST_SNAP_ERROR is
'Snapshot Error Information'
/
create or replace public synonym DBA_HIST_SNAP_ERROR
    for DBA_HIST_SNAP_ERROR
/
grant select on DBA_HIST_SNAP_ERROR to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SNAP_ERROR','CDB_HIST_SNAP_ERROR');
grant select on SYS.CDB_HIST_SNAP_ERROR to select_catalog_role
/
create or replace public synonym CDB_HIST_SNAP_ERROR for SYS.CDB_HIST_SNAP_ERROR
/

/***************************************
 *        DBA_HIST_COLORED_SQL
 ***************************************/

/* shows list of colored SQL IDs */
create or replace view DBA_HIST_COLORED_SQL
as select * from AWR_CDB_COLORED_SQL
/
comment on table DBA_HIST_COLORED_SQL is
'Marked SQLs for snapshots'
/
create or replace public synonym DBA_HIST_COLORED_SQL
    for DBA_HIST_COLORED_SQL
/
grant select on DBA_HIST_COLORED_SQL to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_COLORED_SQL','CDB_HIST_COLORED_SQL');
grant select on SYS.CDB_HIST_COLORED_SQL to select_catalog_role
/
create or replace public synonym CDB_HIST_COLORED_SQL for SYS.CDB_HIST_COLORED_SQL
/

/***************************************
 *    DBA_HIST_BASELINE_METADATA
 ***************************************/
create or replace view DBA_HIST_BASELINE_METADATA
as select * from AWR_CDB_BASELINE_METADATA
/

comment on table DBA_HIST_BASELINE_METADATA is
'Baseline Metadata Information'
/
create or replace public synonym DBA_HIST_BASELINE_METADATA
    for DBA_HIST_BASELINE_METADATA
/
grant select on DBA_HIST_BASELINE_METADATA to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BASELINE_METADATA','CDB_HIST_BASELINE_METADATA');
grant select on SYS.CDB_HIST_BASELINE_METADATA to select_catalog_role
/
create or replace public synonym CDB_HIST_BASELINE_METADATA for SYS.CDB_HIST_BASELINE_METADATA
/

/************************************
 *   DBA_HIST_BASELINE_TEMPLATE
 ************************************/

create or replace view DBA_HIST_BASELINE_TEMPLATE
as select * from AWR_CDB_BASELINE_TEMPLATE
/

comment on table DBA_HIST_BASELINE_TEMPLATE is
'Baseline Template Information'
/
create or replace public synonym DBA_HIST_BASELINE_TEMPLATE
    for DBA_HIST_BASELINE_TEMPLATE
/
grant select on DBA_HIST_BASELINE_TEMPLATE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BASELINE_TEMPLATE','CDB_HIST_BASELINE_TEMPLATE');
grant select on SYS.CDB_HIST_BASELINE_TEMPLATE to select_catalog_role
/
create or replace public synonym CDB_HIST_BASELINE_TEMPLATE for SYS.CDB_HIST_BASELINE_TEMPLATE
/

/***************************************
 *       DBA_HIST_WR_CONTROL
 ***************************************/

create or replace view DBA_HIST_WR_CONTROL
as select * from AWR_CDB_WR_CONTROL
/
comment on table DBA_HIST_WR_CONTROL is
'Workload Repository Control Information'
/
create or replace public synonym DBA_HIST_WR_CONTROL 
    for DBA_HIST_WR_CONTROL
/
grant select on DBA_HIST_WR_CONTROL to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_WR_CONTROL','CDB_HIST_WR_CONTROL');
grant select on SYS.CDB_HIST_WR_CONTROL to select_catalog_role
/
create or replace public synonym CDB_HIST_WR_CONTROL for SYS.CDB_HIST_WR_CONTROL
/

/***************************************
 *      DBA_HIST_TABLESPACE
 ***************************************/

create or replace view DBA_HIST_TABLESPACE
as select * from AWR_CDB_TABLESPACE
/

comment on table DBA_HIST_TABLESPACE is
  'Tablespace Static Information'
/
create or replace public synonym DBA_HIST_TABLESPACE
    for DBA_HIST_TABLESPACE
/
grant select on DBA_HIST_TABLESPACE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TABLESPACE','CDB_HIST_TABLESPACE');
grant select on SYS.CDB_HIST_TABLESPACE to select_catalog_role
/
create or replace public synonym CDB_HIST_TABLESPACE for SYS.CDB_HIST_TABLESPACE
/

/***************************************
 *        DBA_HIST_DATAFILE
 ***************************************/


create or replace view DBA_HIST_DATAFILE
as select * from AWR_CDB_DATAFILE
/
comment on table DBA_HIST_DATAFILE is
'Names of Datafiles'
/
create or replace public synonym DBA_HIST_DATAFILE for DBA_HIST_DATAFILE
/
grant select on DBA_HIST_DATAFILE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DATAFILE','CDB_HIST_DATAFILE');
grant select on SYS.CDB_HIST_DATAFILE to select_catalog_role
/
create or replace public synonym CDB_HIST_DATAFILE for SYS.CDB_HIST_DATAFILE
/

/*****************************************
 *        DBA_HIST_FILESTATXS
 *****************************************/
create or replace view DBA_HIST_FILESTATXS
as select * from AWR_CDB_FILESTATXS
/

comment on table DBA_HIST_FILESTATXS is
'Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_FILESTATXS for DBA_HIST_FILESTATXS
/
grant select on DBA_HIST_FILESTATXS to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_FILESTATXS','CDB_HIST_FILESTATXS');
grant select on SYS.CDB_HIST_FILESTATXS to select_catalog_role
/
create or replace public synonym CDB_HIST_FILESTATXS for SYS.CDB_HIST_FILESTATXS
/

/***************************************
 *        DBA_HIST_TEMPFILE
 ***************************************/

create or replace view DBA_HIST_TEMPFILE
as select * from AWR_CDB_TEMPFILE
/
comment on table DBA_HIST_TEMPFILE is
'Names of Temporary Datafiles'
/
create or replace public synonym DBA_HIST_TEMPFILE for DBA_HIST_TEMPFILE
/
grant select on DBA_HIST_TEMPFILE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TEMPFILE','CDB_HIST_TEMPFILE');
grant select on SYS.CDB_HIST_TEMPFILE to select_catalog_role
/
create or replace public synonym CDB_HIST_TEMPFILE for SYS.CDB_HIST_TEMPFILE
/

/*****************************************
 *        DBA_HIST_TEMPSTATXS
 *****************************************/
create or replace view DBA_HIST_TEMPSTATXS
as select * from AWR_CDB_TEMPSTATXS
/

comment on table DBA_HIST_TEMPSTATXS is
'Temporary Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TEMPSTATXS for DBA_HIST_TEMPSTATXS
/
grant select on DBA_HIST_TEMPSTATXS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TEMPSTATXS','CDB_HIST_TEMPSTATXS');
grant select on SYS.CDB_HIST_TEMPSTATXS to select_catalog_role
/
create or replace public synonym CDB_HIST_TEMPSTATXS for SYS.CDB_HIST_TEMPSTATXS
/

/***************************************
 *        DBA_HIST_COMP_IOSTAT
 ***************************************/

create or replace view DBA_HIST_COMP_IOSTAT
as select * from AWR_CDB_COMP_IOSTAT
/
comment on table DBA_HIST_COMP_IOSTAT is
'I/O stats aggregated on component level'
/
create or replace public synonym DBA_HIST_COMP_IOSTAT 
  for DBA_HIST_COMP_IOSTAT
/
grant select on DBA_HIST_COMP_IOSTAT to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_COMP_IOSTAT','CDB_HIST_COMP_IOSTAT');
grant select on SYS.CDB_HIST_COMP_IOSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_COMP_IOSTAT for SYS.CDB_HIST_COMP_IOSTAT
/

/***************************************
 *        DBA_HIST_SQLSTAT
 ***************************************/

create or replace view DBA_HIST_SQLSTAT
as select * from AWR_CDB_SQLSTAT
/

comment on table DBA_HIST_SQLSTAT is
'SQL Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SQLSTAT for DBA_HIST_SQLSTAT
/
grant select on DBA_HIST_SQLSTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQLSTAT','CDB_HIST_SQLSTAT');
grant select on SYS.CDB_HIST_SQLSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_SQLSTAT for SYS.CDB_HIST_SQLSTAT
/

/***************************************
 *        DBA_HIST_SQLTEXT
 ***************************************/

create or replace view DBA_HIST_SQLTEXT
as select * from AWR_CDB_SQLTEXT
/
comment on table DBA_HIST_SQLTEXT is
'SQL Text'
/
create or replace public synonym DBA_HIST_SQLTEXT for DBA_HIST_SQLTEXT
/
grant select on DBA_HIST_SQLTEXT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQLTEXT','CDB_HIST_SQLTEXT');
grant select on SYS.CDB_HIST_SQLTEXT to select_catalog_role
/
create or replace public synonym CDB_HIST_SQLTEXT for SYS.CDB_HIST_SQLTEXT
/

/***************************************
 *       DBA_HIST_SQL_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SQL_SUMMARY
as select * from AWR_CDB_SQL_SUMMARY
/

comment on table DBA_HIST_SQL_SUMMARY is
'Summary of SQL Statistics'
/
create or replace public synonym DBA_HIST_SQL_SUMMARY 
   for DBA_HIST_SQL_SUMMARY
/
grant select on DBA_HIST_SQL_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQL_SUMMARY','CDB_HIST_SQL_SUMMARY');
grant select on SYS.CDB_HIST_SQL_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_SQL_SUMMARY for SYS.CDB_HIST_SQL_SUMMARY
/

/***************************************
 *        DBA_HIST_SQL_PLAN
 ***************************************/

create or replace view DBA_HIST_SQL_PLAN
as select * from AWR_CDB_SQL_PLAN
/
comment on table DBA_HIST_SQL_PLAN is
'SQL Plan Information'
/
create or replace public synonym DBA_HIST_SQL_PLAN for DBA_HIST_SQL_PLAN
/
grant select on DBA_HIST_SQL_PLAN to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQL_PLAN','CDB_HIST_SQL_PLAN');
grant select on SYS.CDB_HIST_SQL_PLAN to select_catalog_role
/
create or replace public synonym CDB_HIST_SQL_PLAN for SYS.CDB_HIST_SQL_PLAN
/

/***************************************
 *        DBA_HIST_SQL_BIND_METADATA
 ***************************************/

create or replace view DBA_HIST_SQL_BIND_METADATA
as select * from AWR_CDB_SQL_BIND_METADATA
/

comment on table DBA_HIST_SQL_BIND_METADATA is
'SQL Bind Metadata Information'
/
create or replace public synonym DBA_HIST_SQL_BIND_METADATA 
  for DBA_HIST_SQL_BIND_METADATA
/
grant select on DBA_HIST_SQL_BIND_METADATA to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQL_BIND_METADATA','CDB_HIST_SQL_BIND_METADATA');
grant select on SYS.CDB_HIST_SQL_BIND_METADATA to select_catalog_role
/
create or replace public synonym CDB_HIST_SQL_BIND_METADATA for SYS.CDB_HIST_SQL_BIND_METADATA
/

/***************************************
 *      DBA_HIST_OPTIMIZER_ENV
 ***************************************/

create or replace view DBA_HIST_OPTIMIZER_ENV
as select * from AWR_CDB_OPTIMIZER_ENV
/
comment on table DBA_HIST_OPTIMIZER_ENV is
'Optimizer Environment Information'
/
create or replace public synonym DBA_HIST_OPTIMIZER_ENV 
   for DBA_HIST_OPTIMIZER_ENV
/
grant select on DBA_HIST_OPTIMIZER_ENV to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_OPTIMIZER_ENV','CDB_HIST_OPTIMIZER_ENV');
grant select on SYS.CDB_HIST_OPTIMIZER_ENV to select_catalog_role
/
create or replace public synonym CDB_HIST_OPTIMIZER_ENV for SYS.CDB_HIST_OPTIMIZER_ENV
/

/***************************************
 *        DBA_HIST_EVENT_NAME
 ***************************************/

create or replace view DBA_HIST_EVENT_NAME
as select * from AWR_CDB_EVENT_NAME
/

comment on table DBA_HIST_EVENT_NAME is
'Event Names'
/
create or replace public synonym DBA_HIST_EVENT_NAME for DBA_HIST_EVENT_NAME
/
grant select on DBA_HIST_EVENT_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_EVENT_NAME','CDB_HIST_EVENT_NAME');
grant select on SYS.CDB_HIST_EVENT_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_EVENT_NAME for SYS.CDB_HIST_EVENT_NAME
/

/***************************************
 *      DBA_HIST_SYSTEM_EVENT
 ***************************************/

create or replace view DBA_HIST_SYSTEM_EVENT
as select * from AWR_CDB_SYSTEM_EVENT
/

comment on table DBA_HIST_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSTEM_EVENT 
    for DBA_HIST_SYSTEM_EVENT
/
grant select on DBA_HIST_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SYSTEM_EVENT','CDB_HIST_SYSTEM_EVENT');
grant select on SYS.CDB_HIST_SYSTEM_EVENT to select_catalog_role
/
create or replace public synonym CDB_HIST_SYSTEM_EVENT for SYS.CDB_HIST_SYSTEM_EVENT
/

/***************************************
 *      DBA_HIST_CON_SYSTEM_EVENT
 ***************************************/

create or replace view DBA_HIST_CON_SYSTEM_EVENT
as select * from AWR_CDB_CON_SYSTEM_EVENT
/

comment on table DBA_HIST_CON_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_CON_SYSTEM_EVENT 
    for DBA_HIST_CON_SYSTEM_EVENT
/
grant select on DBA_HIST_CON_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CON_SYSTEM_EVENT','CDB_HIST_CON_SYSTEM_EVENT');
grant select on SYS.CDB_HIST_CON_SYSTEM_EVENT to select_catalog_role
/
create or replace public synonym CDB_HIST_CON_SYSTEM_EVENT for SYS.CDB_HIST_CON_SYSTEM_EVENT
/

/***************************************
 *      DBA_HIST_BG_EVENT_SUMMARY
 ***************************************/

create or replace view DBA_HIST_BG_EVENT_SUMMARY
as select * from AWR_CDB_BG_EVENT_SUMMARY
/

comment on table DBA_HIST_BG_EVENT_SUMMARY is
'Summary of Background Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BG_EVENT_SUMMARY 
   for DBA_HIST_BG_EVENT_SUMMARY
/
grant select on DBA_HIST_BG_EVENT_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BG_EVENT_SUMMARY','CDB_HIST_BG_EVENT_SUMMARY');
grant select on SYS.CDB_HIST_BG_EVENT_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_BG_EVENT_SUMMARY for SYS.CDB_HIST_BG_EVENT_SUMMARY
/


/***************************************
 *      DBA_HIST_CHANNEL_WAITS
 ***************************************/

create or replace view DBA_HIST_CHANNEL_WAITS
as select * from AWR_CDB_CHANNEL_WAITS
/
comment on table DBA_HIST_CHANNEL_WAITS is
'Channel Watis'
/
create or replace public synonym DBA_HIST_CHANNEL_WAITS
        for DBA_HIST_CHANNEL_WAITS
/
grant select on DBA_HIST_CHANNEL_WAITS to select_catalog_role
/
execute CDBView.create_cdbview(false, 'SYS', 'AWR_PDB_CHANNEL_WAITS', 'CDB_HIST_CHANNEL_WAITS');
grant select on SYS.CDB_HIST_CHANNEL_WAITS to select_catalog_role
/
create or replace public synonym CDB_HIST_CHANNEL_WAITS for SYS.CDB_HIST_CHANNEL_WAITS
/



/***************************************
 *        DBA_HIST_WAITSTAT
 ***************************************/

create or replace view DBA_HIST_WAITSTAT
as select * from AWR_CDB_WAITSTAT
/

comment on table DBA_HIST_WAITSTAT is
'Wait Historical Statistics Information'
/
create or replace public synonym DBA_HIST_WAITSTAT for DBA_HIST_WAITSTAT
/
grant select on DBA_HIST_WAITSTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_WAITSTAT','CDB_HIST_WAITSTAT');
grant select on SYS.CDB_HIST_WAITSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_WAITSTAT for SYS.CDB_HIST_WAITSTAT
/

/***************************************
 *      DBA_HIST_ENQUEUE_STAT
 ***************************************/

create or replace view DBA_HIST_ENQUEUE_STAT
as select * from AWR_CDB_ENQUEUE_STAT
/

comment on table DBA_HIST_ENQUEUE_STAT is
'Enqueue Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ENQUEUE_STAT 
    for DBA_HIST_ENQUEUE_STAT
/
grant select on DBA_HIST_ENQUEUE_STAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ENQUEUE_STAT','CDB_HIST_ENQUEUE_STAT');
grant select on SYS.CDB_HIST_ENQUEUE_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_ENQUEUE_STAT for SYS.CDB_HIST_ENQUEUE_STAT
/

/***************************************
 *        DBA_HIST_LATCH_NAME
 ***************************************/

create or replace view DBA_HIST_LATCH_NAME
as select * from AWR_CDB_LATCH_NAME
/

comment on table DBA_HIST_LATCH_NAME is
'Latch Names'
/
create or replace public synonym DBA_HIST_LATCH_NAME for DBA_HIST_LATCH_NAME
/
grant select on DBA_HIST_LATCH_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LATCH_NAME','CDB_HIST_LATCH_NAME');
grant select on SYS.CDB_HIST_LATCH_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_LATCH_NAME for SYS.CDB_HIST_LATCH_NAME
/

/***************************************
 *        DBA_HIST_LATCH
 ***************************************/

create or replace view DBA_HIST_LATCH 
as select * from AWR_CDB_LATCH
/

comment on table DBA_HIST_LATCH is
'Latch Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH for DBA_HIST_LATCH
/
grant select on DBA_HIST_LATCH to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LATCH','CDB_HIST_LATCH');
grant select on SYS.CDB_HIST_LATCH to select_catalog_role
/
create or replace public synonym CDB_HIST_LATCH for SYS.CDB_HIST_LATCH
/

/***************************************
 *      DBA_HIST_LATCH_CHILDREN
 ***************************************/

create or replace view DBA_HIST_LATCH_CHILDREN
as select * from AWR_CDB_LATCH_CHILDREN
/

comment on table DBA_HIST_LATCH_CHILDREN is
'Latch Children Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_CHILDREN 
    for DBA_HIST_LATCH_CHILDREN
/
grant select on DBA_HIST_LATCH_CHILDREN to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LATCH_CHILDREN','CDB_HIST_LATCH_CHILDREN');
grant select on SYS.CDB_HIST_LATCH_CHILDREN to select_catalog_role
/
create or replace public synonym CDB_HIST_LATCH_CHILDREN for SYS.CDB_HIST_LATCH_CHILDREN
/

/***************************************
 *        DBA_HIST_LATCH_PARENT
 ***************************************/

create or replace view DBA_HIST_LATCH_PARENT
as select * from AWR_CDB_LATCH_PARENT
/

comment on table DBA_HIST_LATCH_PARENT is
'Latch Parent Historical Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_PARENT 
    for DBA_HIST_LATCH_PARENT
/
grant select on DBA_HIST_LATCH_PARENT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LATCH_PARENT','CDB_HIST_LATCH_PARENT');
grant select on SYS.CDB_HIST_LATCH_PARENT to select_catalog_role
/
create or replace public synonym CDB_HIST_LATCH_PARENT for SYS.CDB_HIST_LATCH_PARENT
/

/***************************************
 *    DBA_HIST_LATCH_MISSES_SUMMARY
 ***************************************/

create or replace view DBA_HIST_LATCH_MISSES_SUMMARY
as select * from AWR_CDB_LATCH_MISSES_SUMMARY
/

comment on table DBA_HIST_LATCH_MISSES_SUMMARY is
'Latch Misses Summary Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_MISSES_SUMMARY 
    for DBA_HIST_LATCH_MISSES_SUMMARY
/
grant select on DBA_HIST_LATCH_MISSES_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LATCH_MISSES_SUMMARY','CDB_HIST_LATCH_MISSES_SUMMARY');
grant select on SYS.CDB_HIST_LATCH_MISSES_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_LATCH_MISSES_SUMMARY for SYS.CDB_HIST_LATCH_MISSES_SUMMARY
/

/***************************************
 *    DBA_HIST_EVENT_HISTOGRAM
 ***************************************/

create or replace view DBA_HIST_EVENT_HISTOGRAM
as select * from AWR_CDB_EVENT_HISTOGRAM
/

comment on table DBA_HIST_EVENT_HISTOGRAM is
'Event Histogram Historical Statistics Information'
/
create or replace public synonym DBA_HIST_EVENT_HISTOGRAM 
    for DBA_HIST_EVENT_HISTOGRAM
/
grant select on DBA_HIST_EVENT_HISTOGRAM to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_EVENT_HISTOGRAM','CDB_HIST_EVENT_HISTOGRAM');
grant select on SYS.CDB_HIST_EVENT_HISTOGRAM to select_catalog_role
/
create or replace public synonym CDB_HIST_EVENT_HISTOGRAM for SYS.CDB_HIST_EVENT_HISTOGRAM
/

/***************************************
 *    DBA_HIST_MUTEX_SLEEP
 ***************************************/

create or replace view DBA_HIST_MUTEX_SLEEP
as select * from AWR_CDB_MUTEX_SLEEP
/

comment on table DBA_HIST_MUTEX_SLEEP is
'Mutex Sleep Summary Historical Statistics Information'
/
create or replace public synonym DBA_HIST_MUTEX_SLEEP 
    for DBA_HIST_MUTEX_SLEEP
/
grant select on DBA_HIST_MUTEX_SLEEP to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MUTEX_SLEEP','CDB_HIST_MUTEX_SLEEP');
grant select on SYS.CDB_HIST_MUTEX_SLEEP to select_catalog_role
/
create or replace public synonym CDB_HIST_MUTEX_SLEEP for SYS.CDB_HIST_MUTEX_SLEEP
/

/***************************************
 *        DBA_HIST_LIBRARYCACHE
 ***************************************/

create or replace view DBA_HIST_LIBRARYCACHE
as select * from AWR_CDB_LIBRARYCACHE
/

comment on table DBA_HIST_LIBRARYCACHE is
'Library Cache Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LIBRARYCACHE 
    for DBA_HIST_LIBRARYCACHE
/
grant select on DBA_HIST_LIBRARYCACHE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LIBRARYCACHE','CDB_HIST_LIBRARYCACHE');
grant select on SYS.CDB_HIST_LIBRARYCACHE to select_catalog_role
/
create or replace public synonym CDB_HIST_LIBRARYCACHE for SYS.CDB_HIST_LIBRARYCACHE
/

/***************************************
 *     DBA_HIST_DB_CACHE_ADVICE
 ***************************************/

create or replace view DBA_HIST_DB_CACHE_ADVICE
as select * from AWR_CDB_DB_CACHE_ADVICE
/

comment on table DBA_HIST_DB_CACHE_ADVICE is
'DB Cache Advice History Information'
/
create or replace public synonym DBA_HIST_DB_CACHE_ADVICE
    for DBA_HIST_DB_CACHE_ADVICE
/
grant select on DBA_HIST_DB_CACHE_ADVICE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DB_CACHE_ADVICE','CDB_HIST_DB_CACHE_ADVICE');
grant select on SYS.CDB_HIST_DB_CACHE_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_DB_CACHE_ADVICE for SYS.CDB_HIST_DB_CACHE_ADVICE
/

/***************************************
 *     DBA_HIST_BUFFER_POOL_STAT
 ***************************************/

create or replace view DBA_HIST_BUFFER_POOL_STAT
as select * from AWR_CDB_BUFFER_POOL_STAT
/
comment on table DBA_HIST_BUFFER_POOL_STAT is
'Buffer Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFER_POOL_STAT
    for DBA_HIST_BUFFER_POOL_STAT
/
grant select on DBA_HIST_BUFFER_POOL_STAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BUFFER_POOL_STAT','CDB_HIST_BUFFER_POOL_STAT');
grant select on SYS.CDB_HIST_BUFFER_POOL_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_BUFFER_POOL_STAT for SYS.CDB_HIST_BUFFER_POOL_STAT
/

/***************************************
 *     DBA_HIST_ROWCACHE_SUMMARY
 ***************************************/

create or replace view DBA_HIST_ROWCACHE_SUMMARY
as select * from AWR_CDB_ROWCACHE_SUMMARY
/

comment on table DBA_HIST_ROWCACHE_SUMMARY is
'Row Cache Historical Statistics Information Summary'
/
create or replace public synonym DBA_HIST_ROWCACHE_SUMMARY
    for DBA_HIST_ROWCACHE_SUMMARY
/
grant select on DBA_HIST_ROWCACHE_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ROWCACHE_SUMMARY','CDB_HIST_ROWCACHE_SUMMARY');
grant select on SYS.CDB_HIST_ROWCACHE_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_ROWCACHE_SUMMARY for SYS.CDB_HIST_ROWCACHE_SUMMARY
/

/***************************************
 *        DBA_HIST_SGA
 ***************************************/

create or replace view DBA_HIST_SGA
as select * from AWR_CDB_SGA
/

comment on table DBA_HIST_SGA is
'SGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGA for DBA_HIST_SGA
/
grant select on DBA_HIST_SGA to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SGA','CDB_HIST_SGA');
grant select on SYS.CDB_HIST_SGA to select_catalog_role
/
create or replace public synonym CDB_HIST_SGA for SYS.CDB_HIST_SGA
/

/***************************************
 *        DBA_HIST_SGASTAT
 ***************************************/

create or replace view DBA_HIST_SGASTAT
as select * from AWR_CDB_SGASTAT
/

comment on table DBA_HIST_SGASTAT is
'SGA Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGASTAT for DBA_HIST_SGASTAT
/
grant select on DBA_HIST_SGASTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SGASTAT','CDB_HIST_SGASTAT');
grant select on SYS.CDB_HIST_SGASTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_SGASTAT for SYS.CDB_HIST_SGASTAT
/

/***************************************
 *        DBA_HIST_PGASTAT
 ***************************************/

create or replace view DBA_HIST_PGASTAT
as select * from AWR_CDB_PGASTAT
/

comment on table DBA_HIST_PGASTAT is
'PGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PGASTAT for DBA_HIST_PGASTAT
/
grant select on DBA_HIST_PGASTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PGASTAT','CDB_HIST_PGASTAT');
grant select on SYS.CDB_HIST_PGASTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_PGASTAT for SYS.CDB_HIST_PGASTAT
/

/***************************************
 *   DBA_HIST_PROCESS_MEM_SUMMARY
 ***************************************/

create or replace view DBA_HIST_PROCESS_MEM_SUMMARY
as select * from AWR_CDB_PROCESS_MEM_SUMMARY
/

comment on table DBA_HIST_PROCESS_MEM_SUMMARY is
'Process Memory Historical Summary Information'
/
create or replace public synonym DBA_HIST_PROCESS_MEM_SUMMARY 
   for DBA_HIST_PROCESS_MEM_SUMMARY
/
grant select on DBA_HIST_PROCESS_MEM_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PROCESS_MEM_SUMMARY','CDB_HIST_PROCESS_MEM_SUMMARY');
grant select on SYS.CDB_HIST_PROCESS_MEM_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_PROCESS_MEM_SUMMARY for SYS.CDB_HIST_PROCESS_MEM_SUMMARY
/

/***************************************
 *        DBA_HIST_RESOURCE_LIMIT
 ***************************************/

create or replace view DBA_HIST_RESOURCE_LIMIT
as select * from AWR_CDB_RESOURCE_LIMIT
/

comment on table DBA_HIST_RESOURCE_LIMIT is
'Resource Limit Historical Statistics Information'
/
create or replace public synonym DBA_HIST_RESOURCE_LIMIT 
    for DBA_HIST_RESOURCE_LIMIT
/
grant select on DBA_HIST_RESOURCE_LIMIT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RESOURCE_LIMIT','CDB_HIST_RESOURCE_LIMIT');
grant select on SYS.CDB_HIST_RESOURCE_LIMIT to select_catalog_role
/
create or replace public synonym CDB_HIST_RESOURCE_LIMIT for SYS.CDB_HIST_RESOURCE_LIMIT
/

/***************************************
 *    DBA_HIST_SHARED_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_SHARED_POOL_ADVICE
as select * from AWR_CDB_SHARED_POOL_ADVICE
/

comment on table DBA_HIST_SHARED_POOL_ADVICE is
'Shared Pool Advice History'
/
create or replace public synonym DBA_HIST_SHARED_POOL_ADVICE 
    for DBA_HIST_SHARED_POOL_ADVICE
/
grant select on DBA_HIST_SHARED_POOL_ADVICE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SHARED_POOL_ADVICE','CDB_HIST_SHARED_POOL_ADVICE');
grant select on SYS.CDB_HIST_SHARED_POOL_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_SHARED_POOL_ADVICE for SYS.CDB_HIST_SHARED_POOL_ADVICE
/

/***************************************
 *    DBA_HIST_STREAMS_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_STREAMS_POOL_ADVICE
as select * from AWR_CDB_STREAMS_POOL_ADVICE
/

comment on table DBA_HIST_STREAMS_POOL_ADVICE is
'Streams Pool Advice History'
/
create or replace public synonym DBA_HIST_STREAMS_POOL_ADVICE 
    for DBA_HIST_STREAMS_POOL_ADVICE
/
grant select on DBA_HIST_STREAMS_POOL_ADVICE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_STREAMS_POOL_ADVICE','CDB_HIST_STREAMS_POOL_ADVICE');
grant select on SYS.CDB_HIST_STREAMS_POOL_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_STREAMS_POOL_ADVICE for SYS.CDB_HIST_STREAMS_POOL_ADVICE
/

/***************************************
 *     DBA_HIST_SQL_WORKAREA_HSTGRM
 ***************************************/

create or replace view DBA_HIST_SQL_WORKAREA_HSTGRM 
as select * from AWR_CDB_SQL_WORKAREA_HSTGRM
/

comment on table DBA_HIST_SQL_WORKAREA_HSTGRM is
'SQL Workarea Histogram History'
/
create or replace public synonym DBA_HIST_SQL_WORKAREA_HSTGRM 
    for DBA_HIST_SQL_WORKAREA_HSTGRM
/
grant select on DBA_HIST_SQL_WORKAREA_HSTGRM to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQL_WORKAREA_HSTGRM','CDB_HIST_SQL_WORKAREA_HSTGRM');
grant select on SYS.CDB_HIST_SQL_WORKAREA_HSTGRM to select_catalog_role
/
create or replace public synonym CDB_HIST_SQL_WORKAREA_HSTGRM for SYS.CDB_HIST_SQL_WORKAREA_HSTGRM
/

/***************************************
 *     DBA_HIST_PGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_PGA_TARGET_ADVICE
as select * from AWR_CDB_PGA_TARGET_ADVICE
/

comment on table DBA_HIST_PGA_TARGET_ADVICE is
'PGA Target Advice History'
/
create or replace public synonym DBA_HIST_PGA_TARGET_ADVICE
    for DBA_HIST_PGA_TARGET_ADVICE
/
grant select on DBA_HIST_PGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PGA_TARGET_ADVICE','CDB_HIST_PGA_TARGET_ADVICE');
grant select on SYS.CDB_HIST_PGA_TARGET_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_PGA_TARGET_ADVICE for SYS.CDB_HIST_PGA_TARGET_ADVICE
/

/***************************************
 *     DBA_HIST_SGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_SGA_TARGET_ADVICE
as select * from AWR_CDB_SGA_TARGET_ADVICE
/

comment on table DBA_HIST_SGA_TARGET_ADVICE is
'SGA Target Advice History'
/
create or replace public synonym DBA_HIST_SGA_TARGET_ADVICE
    for DBA_HIST_SGA_TARGET_ADVICE
/
grant select on DBA_HIST_SGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SGA_TARGET_ADVICE','CDB_HIST_SGA_TARGET_ADVICE');
grant select on SYS.CDB_HIST_SGA_TARGET_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_SGA_TARGET_ADVICE for SYS.CDB_HIST_SGA_TARGET_ADVICE
/

/***************************************
 *   DBA_HIST_MEMORY_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_MEMORY_TARGET_ADVICE
as select * from AWR_CDB_MEMORY_TARGET_ADVICE
/

comment on table DBA_HIST_MEMORY_TARGET_ADVICE is
'Memory Target Advice History'
/
create or replace public synonym DBA_HIST_MEMORY_TARGET_ADVICE
    for DBA_HIST_MEMORY_TARGET_ADVICE
/
grant select on DBA_HIST_MEMORY_TARGET_ADVICE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MEMORY_TARGET_ADVICE','CDB_HIST_MEMORY_TARGET_ADVICE');
grant select on SYS.CDB_HIST_MEMORY_TARGET_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_MEMORY_TARGET_ADVICE for SYS.CDB_HIST_MEMORY_TARGET_ADVICE
/

/***************************************
 *    DBA_HIST_MEMORY_RESIZE_OPS
 ***************************************/

create or replace view DBA_HIST_MEMORY_RESIZE_OPS
as select * from AWR_CDB_MEMORY_RESIZE_OPS
/

comment on table DBA_HIST_MEMORY_RESIZE_OPS is
'Memory Resize Operations History'
/
create or replace public synonym DBA_HIST_MEMORY_RESIZE_OPS
    for DBA_HIST_MEMORY_RESIZE_OPS
/
grant select on DBA_HIST_MEMORY_RESIZE_OPS to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MEMORY_RESIZE_OPS','CDB_HIST_MEMORY_RESIZE_OPS');
grant select on SYS.CDB_HIST_MEMORY_RESIZE_OPS to select_catalog_role
/
create or replace public synonym CDB_HIST_MEMORY_RESIZE_OPS for SYS.CDB_HIST_MEMORY_RESIZE_OPS
/

/***************************************
 *    DBA_HIST_INSTANCE_RECOVERY
 ***************************************/

create or replace view DBA_HIST_INSTANCE_RECOVERY
as select * from AWR_CDB_INSTANCE_RECOVERY
/

comment on table DBA_HIST_INSTANCE_RECOVERY is
'Instance Recovery Historical Statistics Information'
/
create or replace public synonym DBA_HIST_INSTANCE_RECOVERY 
    for DBA_HIST_INSTANCE_RECOVERY
/
grant select on DBA_HIST_INSTANCE_RECOVERY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_INSTANCE_RECOVERY','CDB_HIST_INSTANCE_RECOVERY');
grant select on SYS.CDB_HIST_INSTANCE_RECOVERY to select_catalog_role
/
create or replace public synonym CDB_HIST_INSTANCE_RECOVERY for SYS.CDB_HIST_INSTANCE_RECOVERY
/


/***************************************
 *    DBA_HIST_RECOVERY_PROGRESS
 ***************************************/
create or replace view DBA_HIST_RECOVERY_PROGRESS
as select * from AWR_CDB_RECOVERY_PROGRESS
/

comment on table DBA_HIST_RECOVERY_PROGRESS is
'Recovery Progress Stats Instance Wide'
/
create or replace public synonym DBA_HIST_RECOVERY_PROGRESS
    for DBA_HIST_RECOVERY_PROGRESS
/
grant select on DBA_HIST_RECOVERY_PROGRESS to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RECOVERY_PROGRESS','CDB_HIST_RECOVERY_PROGRESS');
grant select on SYS.CDB_HIST_RECOVERY_PROGRESS to select_catalog_role
/
create or replace public synonym CDB_HIST_RECOVERY_PROGRESS for SYS.CDB_HIST_RECOVERY_PROGRESS
/


/***************************************
 *    DBA_HIST_JAVA_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_JAVA_POOL_ADVICE
as select * from AWR_CDB_JAVA_POOL_ADVICE
/

comment on table DBA_HIST_JAVA_POOL_ADVICE is
'Java Pool Advice History'
/
create or replace public synonym DBA_HIST_JAVA_POOL_ADVICE 
    for DBA_HIST_JAVA_POOL_ADVICE
/
grant select on DBA_HIST_JAVA_POOL_ADVICE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_JAVA_POOL_ADVICE','CDB_HIST_JAVA_POOL_ADVICE');
grant select on SYS.CDB_HIST_JAVA_POOL_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_JAVA_POOL_ADVICE for SYS.CDB_HIST_JAVA_POOL_ADVICE
/

/***************************************
 *    DBA_HIST_THREAD
 ***************************************/

create or replace view DBA_HIST_THREAD
as select * from AWR_CDB_THREAD
/

comment on table DBA_HIST_THREAD is
'Thread Historical Statistics Information'
/
create or replace public synonym DBA_HIST_THREAD 
    for DBA_HIST_THREAD
/
grant select on DBA_HIST_THREAD to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_THREAD','CDB_HIST_THREAD');
grant select on SYS.CDB_HIST_THREAD to select_catalog_role
/
create or replace public synonym CDB_HIST_THREAD for SYS.CDB_HIST_THREAD
/

/***************************************
 *        DBA_HIST_STAT_NAME
 ***************************************/

create or replace view DBA_HIST_STAT_NAME
as select * from AWR_CDB_STAT_NAME
/

comment on table DBA_HIST_STAT_NAME is
'Statistic Names'
/
create or replace public synonym DBA_HIST_STAT_NAME for DBA_HIST_STAT_NAME
/
grant select on DBA_HIST_STAT_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_STAT_NAME','CDB_HIST_STAT_NAME');
grant select on SYS.CDB_HIST_STAT_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_STAT_NAME for SYS.CDB_HIST_STAT_NAME
/

/***************************************
 *        DBA_HIST_SYSSTAT
 ***************************************/

create or replace view DBA_HIST_SYSSTAT
as select * from AWR_CDB_SYSSTAT
/

comment on table DBA_HIST_SYSSTAT is
'System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSSTAT for DBA_HIST_SYSSTAT
/
grant select on DBA_HIST_SYSSTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SYSSTAT','CDB_HIST_SYSSTAT');
grant select on SYS.CDB_HIST_SYSSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_SYSSTAT for SYS.CDB_HIST_SYSSTAT
/


/***************************************
 *        DBA_HIST_CON_SYSSTAT
 ***************************************/

create or replace view DBA_HIST_CON_SYSSTAT
as select * from AWR_CDB_CON_SYSSTAT
/

comment on table DBA_HIST_CON_SYSSTAT is
'System Historical Statistics Information Per PDB'
/
create or replace public synonym DBA_HIST_CON_SYSSTAT for DBA_HIST_CON_SYSSTAT
/
grant select on DBA_HIST_CON_SYSSTAT to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CON_SYSSTAT','CDB_HIST_CON_SYSSTAT');
grant select on SYS.CDB_HIST_CON_SYSSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_CON_SYSSTAT for SYS.CDB_HIST_CON_SYSSTAT
/


/***************************************
 *        DBA_HIST_SYS_TIME_MODEL
 ***************************************/

create or replace view DBA_HIST_SYS_TIME_MODEL
as select * from AWR_CDB_SYS_TIME_MODEL
/

comment on table DBA_HIST_SYS_TIME_MODEL is
'System Time Model Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYS_TIME_MODEL 
   for DBA_HIST_SYS_TIME_MODEL
/
grant select on DBA_HIST_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SYS_TIME_MODEL','CDB_HIST_SYS_TIME_MODEL');
grant select on SYS.CDB_HIST_SYS_TIME_MODEL to select_catalog_role
/
create or replace public synonym CDB_HIST_SYS_TIME_MODEL for SYS.CDB_HIST_SYS_TIME_MODEL
/

/***************************************
 *        DBA_HIST_CON_SYS_TIME_MODEL
 ***************************************/

create or replace view DBA_HIST_CON_SYS_TIME_MODEL
as select * from AWR_CDB_CON_SYS_TIME_MODEL
/

comment on table DBA_HIST_CON_SYS_TIME_MODEL is
'PDB System Time Model Historical Statistics Information'
/
create or replace public synonym DBA_HIST_CON_SYS_TIME_MODEL 
   for DBA_HIST_CON_SYS_TIME_MODEL
/
grant select on DBA_HIST_CON_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CON_SYS_TIME_MODEL','CDB_HIST_CON_SYS_TIME_MODEL');
grant select on SYS.CDB_HIST_CON_SYS_TIME_MODEL to select_catalog_role
/
create or replace public synonym CDB_HIST_CON_SYS_TIME_MODEL for SYS.CDB_HIST_CON_SYS_TIME_MODEL
/

/***************************************
 *        DBA_HIST_OSSTAT_NAME
 ***************************************/

create or replace view DBA_HIST_OSSTAT_NAME
as select * from AWR_CDB_OSSTAT_NAME
/

comment on table DBA_HIST_OSSTAT_NAME is
'Operating System Statistic Names'
/
create or replace public synonym DBA_HIST_OSSTAT_NAME 
  for DBA_HIST_OSSTAT_NAME
/
grant select on DBA_HIST_OSSTAT_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_OSSTAT_NAME','CDB_HIST_OSSTAT_NAME');
grant select on SYS.CDB_HIST_OSSTAT_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_OSSTAT_NAME for SYS.CDB_HIST_OSSTAT_NAME
/

/***************************************
 *        DBA_HIST_OSSTAT
 ***************************************/

create or replace view DBA_HIST_OSSTAT
as select * from AWR_CDB_OSSTAT
/

comment on table DBA_HIST_OSSTAT is
'Operating System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_OSSTAT 
   for DBA_HIST_OSSTAT
/
grant select on DBA_HIST_OSSTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_OSSTAT','CDB_HIST_OSSTAT');
grant select on SYS.CDB_HIST_OSSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_OSSTAT for SYS.CDB_HIST_OSSTAT
/

/***************************************
 *      DBA_HIST_PARAMETER_NAME
 ***************************************/

create or replace view DBA_HIST_PARAMETER_NAME
as select * from AWR_CDB_PARAMETER_NAME
/

comment on table DBA_HIST_PARAMETER_NAME is
'Parameter Names'
/
create or replace public synonym DBA_HIST_PARAMETER_NAME 
    for DBA_HIST_PARAMETER_NAME
/
grant select on DBA_HIST_PARAMETER_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PARAMETER_NAME','CDB_HIST_PARAMETER_NAME');
grant select on SYS.CDB_HIST_PARAMETER_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_PARAMETER_NAME for SYS.CDB_HIST_PARAMETER_NAME
/

/***************************************
 *        DBA_HIST_PARAMETER
 ***************************************/

create or replace view DBA_HIST_PARAMETER
as select * from AWR_CDB_PARAMETER
/

comment on table DBA_HIST_PARAMETER is
'Parameter Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PARAMETER 
    for DBA_HIST_PARAMETER
/
grant select on DBA_HIST_PARAMETER to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PARAMETER','CDB_HIST_PARAMETER');
grant select on SYS.CDB_HIST_PARAMETER to select_catalog_role
/
create or replace public synonym CDB_HIST_PARAMETER for SYS.CDB_HIST_PARAMETER
/

/***************************************
 *        DBA_HIST_MVPARAMETER
 ***************************************/

create or replace view DBA_HIST_MVPARAMETER
as select * from AWR_CDB_MVPARAMETER
/

comment on table DBA_HIST_MVPARAMETER is
'Multi-valued Parameter Historical Statistics Information'
/
create or replace public synonym DBA_HIST_MVPARAMETER 
    for DBA_HIST_MVPARAMETER
/
grant select on DBA_HIST_MVPARAMETER to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MVPARAMETER','CDB_HIST_MVPARAMETER');
grant select on SYS.CDB_HIST_MVPARAMETER to select_catalog_role
/
create or replace public synonym CDB_HIST_MVPARAMETER for SYS.CDB_HIST_MVPARAMETER
/

/***************************************
 *        DBA_HIST_UNDOSTAT
 ***************************************/

create or replace view DBA_HIST_UNDOSTAT
as select * from AWR_CDB_UNDOSTAT
/

comment on table DBA_HIST_UNDOSTAT is
'Undo Historical Statistics Information'
/
create or replace public synonym DBA_HIST_UNDOSTAT 
    for DBA_HIST_UNDOSTAT
/
grant select on DBA_HIST_UNDOSTAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_UNDOSTAT','CDB_HIST_UNDOSTAT');
grant select on SYS.CDB_HIST_UNDOSTAT to select_catalog_role
/
create or replace public synonym CDB_HIST_UNDOSTAT for SYS.CDB_HIST_UNDOSTAT
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
Rem drop view DBA_HIST_SEG_STAT;

create or replace view DBA_HIST_SEG_STAT
as select * from AWR_CDB_SEG_STAT
/

comment on table DBA_HIST_SEG_STAT is
' Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SEG_STAT 
    for DBA_HIST_SEG_STAT
/
grant select on DBA_HIST_SEG_STAT to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SEG_STAT','CDB_HIST_SEG_STAT');
grant select on SYS.CDB_HIST_SEG_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_SEG_STAT for SYS.CDB_HIST_SEG_STAT
/

/***************************************
 *        DBA_HIST_SEG_STAT_OBJ
 ***************************************/

create or replace view DBA_HIST_SEG_STAT_OBJ
as select * from AWR_CDB_SEG_STAT_OBJ
/

comment on table DBA_HIST_SEG_STAT_OBJ is
'Segment Names'
/
create or replace public synonym DBA_HIST_SEG_STAT_OBJ 
    for DBA_HIST_SEG_STAT_OBJ
/
grant select on DBA_HIST_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SEG_STAT_OBJ','CDB_HIST_SEG_STAT_OBJ');
grant select on SYS.CDB_HIST_SEG_STAT_OBJ to select_catalog_role
/
create or replace public synonym CDB_HIST_SEG_STAT_OBJ for SYS.CDB_HIST_SEG_STAT_OBJ
/

/***************************************
 *        DBA_HIST_METRIC_NAME
 ***************************************/

/* The Metric Id will remain the same across releases */
create or replace view DBA_HIST_METRIC_NAME
as select * from AWR_CDB_METRIC_NAME
/
comment on table DBA_HIST_METRIC_NAME is
'Segment Names'
/
create or replace public synonym DBA_HIST_METRIC_NAME
    for DBA_HIST_METRIC_NAME
/
grant select on DBA_HIST_METRIC_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_METRIC_NAME','CDB_HIST_METRIC_NAME');
grant select on SYS.CDB_HIST_METRIC_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_METRIC_NAME for SYS.CDB_HIST_METRIC_NAME
/

/***************************************
 *      DBA_HIST_SYSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_HISTORY
as select * from AWR_CDB_SYSMETRIC_HISTORY
/

comment on table DBA_HIST_SYSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_HISTORY 
    for DBA_HIST_SYSMETRIC_HISTORY
/
grant select on DBA_HIST_SYSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SYSMETRIC_HISTORY','CDB_HIST_SYSMETRIC_HISTORY');
grant select on SYS.CDB_HIST_SYSMETRIC_HISTORY to select_catalog_role
/
create or replace public synonym CDB_HIST_SYSMETRIC_HISTORY for SYS.CDB_HIST_SYSMETRIC_HISTORY
/

/***************************************
 *      DBA_HIST_SYSMETRIC_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_SUMMARY
as select * from AWR_CDB_SYSMETRIC_SUMMARY
/

comment on table DBA_HIST_SYSMETRIC_SUMMARY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_SUMMARY 
    for DBA_HIST_SYSMETRIC_SUMMARY
/
grant select on DBA_HIST_SYSMETRIC_SUMMARY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SYSMETRIC_SUMMARY','CDB_HIST_SYSMETRIC_SUMMARY');
grant select on SYS.CDB_HIST_SYSMETRIC_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_SYSMETRIC_SUMMARY for SYS.CDB_HIST_SYSMETRIC_SUMMARY
/

/***************************************
 *      DBA_HIST_CON_SYSMETRIC_HIST
 ***************************************/

create or replace view DBA_HIST_CON_SYSMETRIC_HIST
as select * from AWR_CDB_CON_SYSMETRIC_HIST
/

comment on table DBA_HIST_CON_SYSMETRIC_HIST is
'PDB System Metrics History'
/
create or replace public synonym DBA_HIST_CON_SYSMETRIC_HIST
    for DBA_HIST_CON_SYSMETRIC_HIST
/
grant select on DBA_HIST_CON_SYSMETRIC_HIST to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CON_SYSMETRIC_HIST','CDB_HIST_CON_SYSMETRIC_HIST');
grant select on SYS.CDB_HIST_CON_SYSMETRIC_HIST to select_catalog_role
/
create or replace public synonym CDB_HIST_CON_SYSMETRIC_HIST for SYS.CDB_HIST_CON_SYSMETRIC_HIST
/

/***************************************
 *      DBA_HIST_CON_SYSMETRIC_SUMM
 ***************************************/

create or replace view DBA_HIST_CON_SYSMETRIC_SUMM
as select * from AWR_CDB_CON_SYSMETRIC_SUMM
/

comment on table DBA_HIST_CON_SYSMETRIC_SUMM is
'PDB System Metrics Summary'
/
create or replace public synonym DBA_HIST_CON_SYSMETRIC_SUMM
    for DBA_HIST_CON_SYSMETRIC_SUMM
/
grant select on DBA_HIST_CON_SYSMETRIC_SUMM to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CON_SYSMETRIC_SUMM','CDB_HIST_CON_SYSMETRIC_SUMM');
grant select on SYS.CDB_HIST_CON_SYSMETRIC_SUMM to select_catalog_role
/
create or replace public synonym CDB_HIST_CON_SYSMETRIC_SUMM for SYS.CDB_HIST_CON_SYSMETRIC_SUMM
/

/***************************************
 *   DBA_HIST_SESSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SESSMETRIC_HISTORY
as select * from AWR_CDB_SESSMETRIC_HISTORY
/

comment on table DBA_HIST_SESSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SESSMETRIC_HISTORY 
    for DBA_HIST_SESSMETRIC_HISTORY
/
grant select on DBA_HIST_SESSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SESSMETRIC_HISTORY','CDB_HIST_SESSMETRIC_HISTORY');
grant select on SYS.CDB_HIST_SESSMETRIC_HISTORY to select_catalog_role
/
create or replace public synonym CDB_HIST_SESSMETRIC_HISTORY for SYS.CDB_HIST_SESSMETRIC_HISTORY
/

/***************************************
 *        DBA_HIST_FILEMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_FILEMETRIC_HISTORY
as select * from AWR_CDB_FILEMETRIC_HISTORY
/

comment on table DBA_HIST_FILEMETRIC_HISTORY is
'File Metrics History'
/
create or replace public synonym DBA_HIST_FILEMETRIC_HISTORY 
    for DBA_HIST_FILEMETRIC_HISTORY
/
grant select on DBA_HIST_FILEMETRIC_HISTORY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_FILEMETRIC_HISTORY','CDB_HIST_FILEMETRIC_HISTORY');
grant select on SYS.CDB_HIST_FILEMETRIC_HISTORY to select_catalog_role
/
create or replace public synonym CDB_HIST_FILEMETRIC_HISTORY for SYS.CDB_HIST_FILEMETRIC_HISTORY
/

/***************************************
 *    DBA_HIST_WAITCLASSMET_HISTORY
 ***************************************/

create or replace view DBA_HIST_WAITCLASSMET_HISTORY
as select * from AWR_CDB_WAITCLASSMET_HISTORY
/

comment on table DBA_HIST_WAITCLASSMET_HISTORY is
'Wait Class Metric History'
/
create or replace public synonym DBA_HIST_WAITCLASSMET_HISTORY 
    for DBA_HIST_WAITCLASSMET_HISTORY
/
grant select on DBA_HIST_WAITCLASSMET_HISTORY to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_WAITCLASSMET_HISTORY','CDB_HIST_WAITCLASSMET_HISTORY');
grant select on SYS.CDB_HIST_WAITCLASSMET_HISTORY to select_catalog_role
/
create or replace public synonym CDB_HIST_WAITCLASSMET_HISTORY for SYS.CDB_HIST_WAITCLASSMET_HISTORY
/

/***************************************
 *        DBA_HIST_DLM_MISC
 ***************************************/

create or replace view DBA_HIST_DLM_MISC
as select * from AWR_CDB_DLM_MISC
/

comment on table DBA_HIST_DLM_MISC is
'Distributed Lock Manager Miscellaneous Historical Statistics Information'
/
create or replace public synonym DBA_HIST_DLM_MISC 
    for DBA_HIST_DLM_MISC
/
grant select on DBA_HIST_DLM_MISC to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DLM_MISC','CDB_HIST_DLM_MISC');
grant select on SYS.CDB_HIST_DLM_MISC to select_catalog_role
/
create or replace public synonym CDB_HIST_DLM_MISC for SYS.CDB_HIST_DLM_MISC
/

/***************************************
 *    DBA_HIST_CR_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CR_BLOCK_SERVER
as select * from AWR_CDB_CR_BLOCK_SERVER
/
comment on table DBA_HIST_CR_BLOCK_SERVER is
'Consistent Read Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CR_BLOCK_SERVER 
    for DBA_HIST_CR_BLOCK_SERVER
/
grant select on DBA_HIST_CR_BLOCK_SERVER to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CR_BLOCK_SERVER','CDB_HIST_CR_BLOCK_SERVER');
grant select on SYS.CDB_HIST_CR_BLOCK_SERVER to select_catalog_role
/
create or replace public synonym CDB_HIST_CR_BLOCK_SERVER for SYS.CDB_HIST_CR_BLOCK_SERVER
/

/***************************************
 *    DBA_HIST_CURRENT_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CURRENT_BLOCK_SERVER
as select * from AWR_CDB_CURRENT_BLOCK_SERVER
/
comment on table DBA_HIST_CURRENT_BLOCK_SERVER is
'Current Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CURRENT_BLOCK_SERVER 
    for DBA_HIST_CURRENT_BLOCK_SERVER
/
grant select on DBA_HIST_CURRENT_BLOCK_SERVER to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CURRENT_BLOCK_SERVER','CDB_HIST_CURRENT_BLOCK_SERVER');
grant select on SYS.CDB_HIST_CURRENT_BLOCK_SERVER to select_catalog_role
/
create or replace public synonym CDB_HIST_CURRENT_BLOCK_SERVER for SYS.CDB_HIST_CURRENT_BLOCK_SERVER
/

/***************************************
 *    DBA_HIST_INST_CACHE_TRANSFER
 ***************************************/

create or replace view DBA_HIST_INST_CACHE_TRANSFER
as select * from AWR_CDB_INST_CACHE_TRANSFER
/
comment on table DBA_HIST_INST_CACHE_TRANSFER is
'Instance Cache Transfer Historical Statistics'
/
create or replace public synonym DBA_HIST_INST_CACHE_TRANSFER 
    for DBA_HIST_INST_CACHE_TRANSFER
/
grant select on DBA_HIST_INST_CACHE_TRANSFER to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_INST_CACHE_TRANSFER','CDB_HIST_INST_CACHE_TRANSFER');
grant select on SYS.CDB_HIST_INST_CACHE_TRANSFER to select_catalog_role
/
create or replace public synonym CDB_HIST_INST_CACHE_TRANSFER for SYS.CDB_HIST_INST_CACHE_TRANSFER
/

/***************************************
 *        DBA_HIST_PLAN_OPERATION_NAME
 ***************************************/

create or replace view DBA_HIST_PLAN_OPERATION_NAME
as select * from AWR_CDB_PLAN_OPERATION_NAME
/

comment on table DBA_HIST_PLAN_OPERATION_NAME is
'Optimizer Explain Plan Operation Names'
/
create or replace public synonym DBA_HIST_PLAN_OPERATION_NAME 
  for DBA_HIST_PLAN_OPERATION_NAME
/
grant select on DBA_HIST_PLAN_OPERATION_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PLAN_OPERATION_NAME','CDB_HIST_PLAN_OPERATION_NAME');
grant select on SYS.CDB_HIST_PLAN_OPERATION_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_PLAN_OPERATION_NAME for SYS.CDB_HIST_PLAN_OPERATION_NAME
/

/***************************************
 *        DBA_HIST_PLAN_OPTION_NAME
 ***************************************/

create or replace view DBA_HIST_PLAN_OPTION_NAME
as select * from AWR_CDB_PLAN_OPTION_NAME
/

comment on table DBA_HIST_PLAN_OPTION_NAME is
'Optimizer Explain Plan Option Names'
/
create or replace public synonym DBA_HIST_PLAN_OPTION_NAME 
  for DBA_HIST_PLAN_OPTION_NAME
/
grant select on DBA_HIST_PLAN_OPTION_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PLAN_OPTION_NAME','CDB_HIST_PLAN_OPTION_NAME');
grant select on SYS.CDB_HIST_PLAN_OPTION_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_PLAN_OPTION_NAME for SYS.CDB_HIST_PLAN_OPTION_NAME
/

/*****************************************
 *   DBA_HIST_SQLCOMMAND_NAME
 *****************************************/

create or replace view DBA_HIST_SQLCOMMAND_NAME
as select * from AWR_CDB_SQLCOMMAND_NAME
/

comment on table DBA_HIST_SQLCOMMAND_NAME is
'Sql command types'
/
create or replace public synonym DBA_HIST_SQLCOMMAND_NAME
  for DBA_HIST_SQLCOMMAND_NAME
/
grant select on DBA_HIST_SQLCOMMAND_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQLCOMMAND_NAME','CDB_HIST_SQLCOMMAND_NAME');
grant select on SYS.CDB_HIST_SQLCOMMAND_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_SQLCOMMAND_NAME for SYS.CDB_HIST_SQLCOMMAND_NAME
/

/*****************************************
 *   DBA_HIST_TOPLEVELCALL_NAME
 *****************************************/

create or replace view DBA_HIST_TOPLEVELCALL_NAME
as select * from AWR_CDB_TOPLEVELCALL_NAME
/

comment on table DBA_HIST_TOPLEVELCALL_NAME is
'Oracle top level call type'
/
create or replace public synonym DBA_HIST_TOPLEVELCALL_NAME
  for DBA_HIST_TOPLEVELCALL_NAME
/
grant select on DBA_HIST_TOPLEVELCALL_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TOPLEVELCALL_NAME','CDB_HIST_TOPLEVELCALL_NAME');
grant select on SYS.CDB_HIST_TOPLEVELCALL_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_TOPLEVELCALL_NAME for SYS.CDB_HIST_TOPLEVELCALL_NAME
/

/***************************************
 *    DBA_HIST_ACTIVE_SESS_HISTORY
 ***************************************/

create or replace view DBA_HIST_ACTIVE_SESS_HISTORY
as select * from AWR_CDB_ACTIVE_SESS_HISTORY
/

comment on table DBA_HIST_ACTIVE_SESS_HISTORY is
'Active Session Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ACTIVE_SESS_HISTORY 
    for DBA_HIST_ACTIVE_SESS_HISTORY
/
grant select on DBA_HIST_ACTIVE_SESS_HISTORY to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ACTIVE_SESS_HISTORY','CDB_HIST_ACTIVE_SESS_HISTORY');
grant select on SYS.CDB_HIST_ACTIVE_SESS_HISTORY to select_catalog_role
/
create or replace public synonym CDB_HIST_ACTIVE_SESS_HISTORY for SYS.CDB_HIST_ACTIVE_SESS_HISTORY
/

/***************************************
 *        DBA_HIST_ASH_SNAPSHOTS
 ***************************************/
create or replace view DBA_HIST_ASH_SNAPSHOT
as select * from AWR_CDB_ASH_SNAPSHOT
/

-- create a public synonym for the view
create or replace public synonym DBA_HIST_ASH_SNAPSHOT
  for DBA_HIST_ASH_SNAPSHOT
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE
grant select on DBA_HIST_ASH_SNAPSHOT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ASH_SNAPSHOT','CDB_HIST_ASH_SNAPSHOT');
grant select on SYS.CDB_HIST_ASH_SNAPSHOT to select_catalog_role
/
create or replace public synonym CDB_HIST_ASH_SNAPSHOT for SYS.CDB_HIST_ASH_SNAPSHOT
/

/***************************************
 *      DBA_HIST_TABLESPACE_STAT
 ***************************************/

create or replace view DBA_HIST_TABLESPACE_STAT
as select * from AWR_CDB_TABLESPACE_STAT
/

comment on table DBA_HIST_TABLESPACE_STAT is
'Tablespace Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TABLESPACE_STAT 
    for DBA_HIST_TABLESPACE_STAT
/
grant select on DBA_HIST_TABLESPACE_STAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TABLESPACE_STAT','CDB_HIST_TABLESPACE_STAT');
grant select on SYS.CDB_HIST_TABLESPACE_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_TABLESPACE_STAT for SYS.CDB_HIST_TABLESPACE_STAT
/

/***************************************
 *        DBA_HIST_LOG
 ***************************************/

create or replace view DBA_HIST_LOG
as select * from AWR_CDB_LOG
/

comment on table DBA_HIST_LOG is
'Log Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LOG 
    for DBA_HIST_LOG
/
grant select on DBA_HIST_LOG to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LOG','CDB_HIST_LOG');
grant select on SYS.CDB_HIST_LOG to select_catalog_role
/
create or replace public synonym CDB_HIST_LOG for SYS.CDB_HIST_LOG
/

/***************************************
 *        DBA_HIST_MTTR_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_MTTR_TARGET_ADVICE
as select * from AWR_CDB_MTTR_TARGET_ADVICE
/

comment on table DBA_HIST_MTTR_TARGET_ADVICE is
'Mean-Time-To-Recover Target Advice History'
/
create or replace public synonym DBA_HIST_MTTR_TARGET_ADVICE 
    for DBA_HIST_MTTR_TARGET_ADVICE
/
grant select on DBA_HIST_MTTR_TARGET_ADVICE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MTTR_TARGET_ADVICE','CDB_HIST_MTTR_TARGET_ADVICE');
grant select on SYS.CDB_HIST_MTTR_TARGET_ADVICE to select_catalog_role
/
create or replace public synonym CDB_HIST_MTTR_TARGET_ADVICE for SYS.CDB_HIST_MTTR_TARGET_ADVICE
/

/***************************************
 *        DBA_HIST_TBSPC_SPACE_USAGE
 ***************************************/

create or replace view DBA_HIST_TBSPC_SPACE_USAGE
as select * from AWR_CDB_TBSPC_SPACE_USAGE
/

comment on table DBA_HIST_TBSPC_SPACE_USAGE is
'Tablespace Usage Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TBSPC_SPACE_USAGE 
    for DBA_HIST_TBSPC_SPACE_USAGE
/
grant select on DBA_HIST_TBSPC_SPACE_USAGE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_TBSPC_SPACE_USAGE','CDB_HIST_TBSPC_SPACE_USAGE');
grant select on SYS.CDB_HIST_TBSPC_SPACE_USAGE to select_catalog_role
/
create or replace public synonym CDB_HIST_TBSPC_SPACE_USAGE for SYS.CDB_HIST_TBSPC_SPACE_USAGE
/

/*********************************
 *     DBA_HIST_SERVICE_NAME
 *********************************/

create or replace view DBA_HIST_SERVICE_NAME
as select * from AWR_CDB_SERVICE_NAME
/
comment on table DBA_HIST_SERVICE_NAME is
'Service Names'
/
create or replace public synonym DBA_HIST_SERVICE_NAME 
    for DBA_HIST_SERVICE_NAME
/
grant select on DBA_HIST_SERVICE_NAME to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SERVICE_NAME','CDB_HIST_SERVICE_NAME');
grant select on SYS.CDB_HIST_SERVICE_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_SERVICE_NAME for SYS.CDB_HIST_SERVICE_NAME
/

/*********************************
 *     DBA_HIST_SERVICE_STAT
 *********************************/

create or replace view DBA_HIST_SERVICE_STAT
as select * from AWR_CDB_SERVICE_STAT
/
comment on table DBA_HIST_SERVICE_STAT is
'Historical Service Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_STAT 
    for DBA_HIST_SERVICE_STAT
/
grant select on DBA_HIST_SERVICE_STAT to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SERVICE_STAT','CDB_HIST_SERVICE_STAT');
grant select on SYS.CDB_HIST_SERVICE_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_SERVICE_STAT for SYS.CDB_HIST_SERVICE_STAT
/

/***********************************
 *   DBA_HIST_SERVICE_WAIT_CLASS
 ***********************************/

create or replace view DBA_HIST_SERVICE_WAIT_CLASS
as select * from AWR_CDB_SERVICE_WAIT_CLASS
/
comment on table DBA_HIST_SERVICE_WAIT_CLASS is
'Historical Service Wait Class Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_WAIT_CLASS 
    for DBA_HIST_SERVICE_WAIT_CLASS
/
grant select on DBA_HIST_SERVICE_WAIT_CLASS to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SERVICE_WAIT_CLASS','CDB_HIST_SERVICE_WAIT_CLASS');
grant select on SYS.CDB_HIST_SERVICE_WAIT_CLASS to select_catalog_role
/
create or replace public synonym CDB_HIST_SERVICE_WAIT_CLASS for SYS.CDB_HIST_SERVICE_WAIT_CLASS
/

/***********************************
 *   DBA_HIST_SESS_TIME_STATS
 ***********************************/

create or replace view DBA_HIST_SESS_TIME_STATS
as select * from AWR_CDB_SESS_TIME_STATS
/
comment on table DBA_HIST_SESS_TIME_STATS is
'CPU And I/O Time For High Utilization Streams/GoldenGate/XStream sessions'
/
create or replace public synonym DBA_HIST_SESS_TIME_STATS
    for DBA_HIST_SESS_TIME_STATS
/
grant select on DBA_HIST_SESS_TIME_STATS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SESS_TIME_STATS','CDB_HIST_SESS_TIME_STATS');
grant select on SYS.CDB_HIST_SESS_TIME_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_SESS_TIME_STATS for SYS.CDB_HIST_SESS_TIME_STATS
/

/***************************************
 *        DBA_HIST_STREAMS_CAPTURE
 ***************************************/

create or replace view DBA_HIST_STREAMS_CAPTURE
as select * from AWR_CDB_STREAMS_CAPTURE
/

comment on table DBA_HIST_STREAMS_CAPTURE is
'STREAMS Capture Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_CAPTURE
    for DBA_HIST_STREAMS_CAPTURE
/
grant select on DBA_HIST_STREAMS_CAPTURE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_STREAMS_CAPTURE','CDB_HIST_STREAMS_CAPTURE');
grant select on SYS.CDB_HIST_STREAMS_CAPTURE to select_catalog_role
/
create or replace public synonym CDB_HIST_STREAMS_CAPTURE for SYS.CDB_HIST_STREAMS_CAPTURE
/

/***************************************
 *        DBA_HIST_CAPTURE
 ***************************************/
create or replace view DBA_HIST_CAPTURE
as select * from AWR_CDB_CAPTURE
/

comment on table DBA_HIST_CAPTURE is
'Streams/GoldenGate/XStream Capture Historical Statistics Information'
/
create or replace public synonym DBA_HIST_CAPTURE
    for DBA_HIST_CAPTURE
/
grant select on DBA_HIST_CAPTURE to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CAPTURE','CDB_HIST_CAPTURE');
grant select on SYS.CDB_HIST_CAPTURE to select_catalog_role
/
create or replace public synonym CDB_HIST_CAPTURE for SYS.CDB_HIST_CAPTURE
/

/***********************************************
 *        DBA_HIST_STREAMS_APPLY_SUM
 ***********************************************/

create or replace view DBA_HIST_STREAMS_APPLY_SUM
as select * from AWR_CDB_STREAMS_APPLY_SUM
/

comment on table DBA_HIST_STREAMS_APPLY_SUM is
'STREAMS Apply Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_APPLY_SUM
    for DBA_HIST_STREAMS_APPLY_SUM
/
grant select on DBA_HIST_STREAMS_APPLY_SUM to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_STREAMS_APPLY_SUM','CDB_HIST_STREAMS_APPLY_SUM');
grant select on SYS.CDB_HIST_STREAMS_APPLY_SUM to select_catalog_role
/
create or replace public synonym CDB_HIST_STREAMS_APPLY_SUM for SYS.CDB_HIST_STREAMS_APPLY_SUM
/

/***********************************************
 *        DBA_HIST_APPLY_SUMMARY
 ***********************************************/

create or replace view DBA_HIST_APPLY_SUMMARY
as select * from AWR_CDB_APPLY_SUMMARY
/

comment on table DBA_HIST_APPLY_SUMMARY is
'Streams/Goldengate/XStream Apply Historical Statistics Information'
/
create or replace public synonym DBA_HIST_APPLY_SUMMARY
    for DBA_HIST_APPLY_SUMMARY
/
grant select on DBA_HIST_APPLY_SUMMARY to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_APPLY_SUMMARY','CDB_HIST_APPLY_SUMMARY');
grant select on SYS.CDB_HIST_APPLY_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_APPLY_SUMMARY for SYS.CDB_HIST_APPLY_SUMMARY
/

/*****************************************
 *        DBA_HIST_BUFFERED_QUEUES
 *****************************************/

create or replace view DBA_HIST_BUFFERED_QUEUES
as select * from AWR_CDB_BUFFERED_QUEUES
/

comment on table DBA_HIST_BUFFERED_QUEUES is
'STREAMS Buffered Queues Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_QUEUES
    for DBA_HIST_BUFFERED_QUEUES
/
grant select on DBA_HIST_BUFFERED_QUEUES to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BUFFERED_QUEUES','CDB_HIST_BUFFERED_QUEUES');
grant select on SYS.CDB_HIST_BUFFERED_QUEUES to select_catalog_role
/
create or replace public synonym CDB_HIST_BUFFERED_QUEUES for SYS.CDB_HIST_BUFFERED_QUEUES
/

/**********************************************
 *        DBA_HIST_BUFFERED_SUBSCRIBERS
 **********************************************/

create or replace view DBA_HIST_BUFFERED_SUBSCRIBERS
as select * from AWR_CDB_BUFFERED_SUBSCRIBERS
/

comment on table DBA_HIST_BUFFERED_SUBSCRIBERS is
'STREAMS Buffered Queue Subscribers Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_SUBSCRIBERS
    for DBA_HIST_BUFFERED_SUBSCRIBERS
/
grant select on DBA_HIST_BUFFERED_SUBSCRIBERS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BUFFERED_SUBSCRIBERS','CDB_HIST_BUFFERED_SUBSCRIBERS');
grant select on SYS.CDB_HIST_BUFFERED_SUBSCRIBERS to select_catalog_role
/
create or replace public synonym CDB_HIST_BUFFERED_SUBSCRIBERS for SYS.CDB_HIST_BUFFERED_SUBSCRIBERS
/

/**********************************************
 *        DBA_HIST_RULE_SET
 **********************************************/

create or replace view DBA_HIST_RULE_SET
as select * from AWR_CDB_RULE_SET
/

comment on table DBA_HIST_RULE_SET is
'Rule sets historical statistics information'
/
create or replace public synonym DBA_HIST_RULE_SET
    for DBA_HIST_RULE_SET
/
grant select on DBA_HIST_RULE_SET to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RULE_SET','CDB_HIST_RULE_SET');
grant select on SYS.CDB_HIST_RULE_SET to select_catalog_role
/
create or replace public synonym CDB_HIST_RULE_SET for SYS.CDB_HIST_RULE_SET
/

/*****************************************
 *        DBA_HIST_PERSISTENT_QUEUES
 *****************************************/

create or replace view DBA_HIST_PERSISTENT_QUEUES
as select * from AWR_CDB_PERSISTENT_QUEUES
/

comment on table DBA_HIST_PERSISTENT_QUEUES is
'STREAMS AQ Persistent Queues Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_QUEUES
    for DBA_HIST_PERSISTENT_QUEUES
/
grant select on DBA_HIST_PERSISTENT_QUEUES to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PERSISTENT_QUEUES','CDB_HIST_PERSISTENT_QUEUES');
grant select on SYS.CDB_HIST_PERSISTENT_QUEUES to select_catalog_role
/
create or replace public synonym CDB_HIST_PERSISTENT_QUEUES for SYS.CDB_HIST_PERSISTENT_QUEUES
/

/**********************************************
 *        DBA_HIST_PERSISTENT_SUBS
 **********************************************/

create or replace view DBA_HIST_PERSISTENT_SUBS
as select * from AWR_CDB_PERSISTENT_SUBS
/

comment on table DBA_HIST_PERSISTENT_SUBS is
'STREAMS AQ Persistent Queue Subscribers Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_SUBS
    for DBA_HIST_PERSISTENT_SUBS
/
grant select on DBA_HIST_PERSISTENT_SUBS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PERSISTENT_SUBS','CDB_HIST_PERSISTENT_SUBS');
grant select on SYS.CDB_HIST_PERSISTENT_SUBS to select_catalog_role
/
create or replace public synonym CDB_HIST_PERSISTENT_SUBS for SYS.CDB_HIST_PERSISTENT_SUBS
/

/***********************************
 *   DBA_HIST_SESS_SGA_STATS
 ***********************************/

create or replace view DBA_HIST_SESS_SGA_STATS
as select * from AWR_CDB_SESS_SGA_STATS
/
comment on table DBA_HIST_SESS_SGA_STATS is
'SGA Usage Stats For High Utilization GoldenGate/XStream Sessions'
/
create or replace public synonym DBA_HIST_SESS_SGA_STATS
    for DBA_HIST_SESS_SGA_STATS
/
grant select on DBA_HIST_SESS_SGA_STATS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SESS_SGA_STATS','CDB_HIST_SESS_SGA_STATS');
grant select on SYS.CDB_HIST_SESS_SGA_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_SESS_SGA_STATS for SYS.CDB_HIST_SESS_SGA_STATS
/

/**************************************
 *   DBA_HIST_REPLICATION_TBL_STATS
 **************************************/

create or replace view DBA_HIST_REPLICATION_TBL_STATS
as select * from AWR_CDB_REPLICATION_TBL_STATS
/
comment on table DBA_HIST_REPLICATION_TBL_STATS is
'Replication Table Stats For GoldenGate/XStream Sessions'
/
create or replace public synonym DBA_HIST_REPLICATION_TBL_STATS
    for DBA_HIST_REPLICATION_TBL_STATS
/
grant select on DBA_HIST_REPLICATION_TBL_STATS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_REPLICATION_TBL_STATS','CDB_HIST_REPLICATION_TBL_STATS');
grant select on SYS.CDB_HIST_REPLICATION_TBL_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_REPLICATION_TBL_STATS for SYS.CDB_HIST_REPLICATION_TBL_STATS
/

/*****************************************
 *        DBA_HIST_REPLICATION_TXN_STATS
 *****************************************/
create or replace view DBA_HIST_REPLICATION_TXN_STATS
as select * from AWR_CDB_REPLICATION_TXN_STATS
/
comment on table DBA_HIST_REPLICATION_TXN_STATS is
'Replication Transaction Stats For GoldenGate/XStream Sessions'
/
create or replace public synonym DBA_HIST_REPLICATION_TXN_STATS
    for DBA_HIST_REPLICATION_TXN_STATS
/
grant select on DBA_HIST_REPLICATION_TXN_STATS to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_REPLICATION_TXN_STATS','CDB_HIST_REPLICATION_TXN_STATS');
grant select on SYS.CDB_HIST_REPLICATION_TXN_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_REPLICATION_TXN_STATS for SYS.CDB_HIST_REPLICATION_TXN_STATS
/

/***************************************
 *        DBA_HIST_IOSTAT_FUNCTION
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FUNCTION
as select * from AWR_CDB_IOSTAT_FUNCTION
/
comment on table DBA_HIST_IOSTAT_FUNCTION is
'Historical I/O statistics by function'
/
create or replace public synonym DBA_HIST_IOSTAT_FUNCTION 
  for DBA_HIST_IOSTAT_FUNCTION
/
grant select on DBA_HIST_IOSTAT_FUNCTION to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IOSTAT_FUNCTION','CDB_HIST_IOSTAT_FUNCTION');
grant select on SYS.CDB_HIST_IOSTAT_FUNCTION to select_catalog_role
/
create or replace public synonym CDB_HIST_IOSTAT_FUNCTION for SYS.CDB_HIST_IOSTAT_FUNCTION
/

/***************************************
 *        DBA_HIST_IOSTAT_FUNCTION_NAME
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FUNCTION_NAME
as select * from AWR_CDB_IOSTAT_FUNCTION_NAME
/
comment on table DBA_HIST_IOSTAT_FUNCTION_NAME is
'Function names for historical I/O statistics'
/
create or replace public synonym DBA_HIST_IOSTAT_FUNCTION_NAME 
  for DBA_HIST_IOSTAT_FUNCTION_NAME
/
grant select on DBA_HIST_IOSTAT_FUNCTION_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IOSTAT_FUNCTION_NAME','CDB_HIST_IOSTAT_FUNCTION_NAME');
grant select on SYS.CDB_HIST_IOSTAT_FUNCTION_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_IOSTAT_FUNCTION_NAME for SYS.CDB_HIST_IOSTAT_FUNCTION_NAME
/

/***************************************
 *        DBA_HIST_IOSTAT_FILETYPE
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FILETYPE
as select * from AWR_CDB_IOSTAT_FILETYPE
/
comment on table DBA_HIST_IOSTAT_FILETYPE is
'Historical I/O statistics by file type'
/
create or replace public synonym DBA_HIST_IOSTAT_FILETYPE 
  for DBA_HIST_IOSTAT_FILETYPE
/
grant select on DBA_HIST_IOSTAT_FILETYPE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IOSTAT_FILETYPE','CDB_HIST_IOSTAT_FILETYPE');
grant select on SYS.CDB_HIST_IOSTAT_FILETYPE to select_catalog_role
/
create or replace public synonym CDB_HIST_IOSTAT_FILETYPE for SYS.CDB_HIST_IOSTAT_FILETYPE
/

/***************************************
 *        DBA_HIST_IOSTAT_FILETYPE_NAME
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FILETYPE_NAME
as select * from AWR_CDB_IOSTAT_FILETYPE_NAME
/
comment on table DBA_HIST_IOSTAT_FILETYPE_NAME is
'File type names for historical I/O statistics'
/
create or replace public synonym DBA_HIST_IOSTAT_FILETYPE_NAME 
  for DBA_HIST_IOSTAT_FILETYPE_NAME
/
grant select on DBA_HIST_IOSTAT_FILETYPE_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IOSTAT_FILETYPE_NAME','CDB_HIST_IOSTAT_FILETYPE_NAME');
grant select on SYS.CDB_HIST_IOSTAT_FILETYPE_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_IOSTAT_FILETYPE_NAME for SYS.CDB_HIST_IOSTAT_FILETYPE_NAME
/

/***************************************
 *        DBA_HIST_IOSTAT_DETAIL
 ***************************************/

create or replace view DBA_HIST_IOSTAT_DETAIL
as select * from AWR_CDB_IOSTAT_DETAIL
/
comment on table DBA_HIST_IOSTAT_DETAIL is
'Historical I/O statistics by function and filetype'
/
create or replace public synonym DBA_HIST_IOSTAT_DETAIL
  for DBA_HIST_IOSTAT_DETAIL
/
grant select on DBA_HIST_IOSTAT_DETAIL to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IOSTAT_DETAIL','CDB_HIST_IOSTAT_DETAIL');
grant select on SYS.CDB_HIST_IOSTAT_DETAIL to select_catalog_role
/
create or replace public synonym CDB_HIST_IOSTAT_DETAIL for SYS.CDB_HIST_IOSTAT_DETAIL
/

/***************************************
 *        DBA_HIST_RSRC_CONSUMER_GROUP
 ***************************************/

create or replace view DBA_HIST_RSRC_CONSUMER_GROUP
as select * from AWR_CDB_RSRC_CONSUMER_GROUP
/
comment on table DBA_HIST_RSRC_CONSUMER_GROUP is
'Historical resource consumer group statistics'
/
create or replace public synonym DBA_HIST_RSRC_CONSUMER_GROUP 
  for DBA_HIST_RSRC_CONSUMER_GROUP
/
grant select on DBA_HIST_RSRC_CONSUMER_GROUP to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RSRC_CONSUMER_GROUP','CDB_HIST_RSRC_CONSUMER_GROUP');
grant select on SYS.CDB_HIST_RSRC_CONSUMER_GROUP to select_catalog_role
/
create or replace public synonym CDB_HIST_RSRC_CONSUMER_GROUP for SYS.CDB_HIST_RSRC_CONSUMER_GROUP
/

/***************************************
 *        DBA_HIST_RSRC_PLAN
 ***************************************/

create or replace view DBA_HIST_RSRC_PLAN
as select * from AWR_CDB_RSRC_PLAN
/
comment on table DBA_HIST_RSRC_PLAN is
'Historical resource plan statistics'
/
create or replace public synonym DBA_HIST_RSRC_PLAN 
  for DBA_HIST_RSRC_PLAN
/
grant select on DBA_HIST_RSRC_PLAN to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RSRC_PLAN','CDB_HIST_RSRC_PLAN');
grant select on SYS.CDB_HIST_RSRC_PLAN to select_catalog_role
/
create or replace public synonym CDB_HIST_RSRC_PLAN for SYS.CDB_HIST_RSRC_PLAN
/


/***************************************
 *        DBA_HIST_RSRC_METRIC
 ***************************************/


create or replace view DBA_HIST_RSRC_METRIC
as select * from AWR_CDB_RSRC_METRIC
/
comment on table DBA_HIST_RSRC_METRIC is
'Historical resource manager metrics'
/
create or replace public synonym DBA_HIST_RSRC_METRIC 
  for DBA_HIST_RSRC_METRIC
/
grant select on DBA_HIST_RSRC_METRIC to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RSRC_METRIC','CDB_HIST_RSRC_METRIC');
grant select on SYS.CDB_HIST_RSRC_METRIC to select_catalog_role
/
create or replace public synonym CDB_HIST_RSRC_METRIC for SYS.CDB_HIST_RSRC_METRIC
/



/***************************************
 *        DBA_HIST_RSRC_PDB_METRIC
 ***************************************/


create or replace view DBA_HIST_RSRC_PDB_METRIC
as select * from AWR_CDB_RSRC_PDB_METRIC
/
comment on table DBA_HIST_RSRC_PDB_METRIC is
'Historical resource manager metrics by PDB'
/
create or replace public synonym DBA_HIST_RSRC_PDB_METRIC
  for DBA_HIST_RSRC_PDB_METRIC
/
grant select on DBA_HIST_RSRC_PDB_METRIC to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_RSRC_PDB_METRIC','CDB_HIST_RSRC_PDB_METRIC');
grant select on SYS.CDB_HIST_RSRC_PDB_METRIC to select_catalog_role
/
create or replace public synonym CDB_HIST_RSRC_PDB_METRIC for SYS.CDB_HIST_RSRC_PDB_METRIC
/



/***************************************
 *        DBA_HIST_CLUSTER_INTERCON
 ***************************************/

create or replace view DBA_HIST_CLUSTER_INTERCON
as select * from AWR_CDB_CLUSTER_INTERCON
/
comment on table DBA_HIST_CLUSTER_INTERCON is
'Cluster Interconnect Historical Stats'
/
create or replace public synonym DBA_HIST_CLUSTER_INTERCON 
  for DBA_HIST_CLUSTER_INTERCON
/
grant select on DBA_HIST_CLUSTER_INTERCON to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CLUSTER_INTERCON','CDB_HIST_CLUSTER_INTERCON');
grant select on SYS.CDB_HIST_CLUSTER_INTERCON to select_catalog_role
/
create or replace public synonym CDB_HIST_CLUSTER_INTERCON for SYS.CDB_HIST_CLUSTER_INTERCON
/

/***************************************
 *        DBA_HIST_MEM_DYNACIC_COMP
 ***************************************/

create or replace view DBA_HIST_MEM_DYNAMIC_COMP
as select * from AWR_CDB_MEM_DYNAMIC_COMP
/
comment on table DBA_HIST_MEM_DYNAMIC_COMP is
'Historical memory component sizes'
/
create or replace public synonym DBA_HIST_MEM_DYNAMIC_COMP
  for DBA_HIST_MEM_DYNAMIC_COMP
/
grant select on DBA_HIST_MEM_DYNAMIC_COMP to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_MEM_DYNAMIC_COMP','CDB_HIST_MEM_DYNAMIC_COMP');
grant select on SYS.CDB_HIST_MEM_DYNAMIC_COMP to select_catalog_role
/
create or replace public synonym CDB_HIST_MEM_DYNAMIC_COMP for SYS.CDB_HIST_MEM_DYNAMIC_COMP
/

/***************************************
 *        DBA_HIST_IC_CLIENT_STATS
 ***************************************/

create or replace view DBA_HIST_IC_CLIENT_STATS
as select * from AWR_CDB_IC_CLIENT_STATS
/
comment on table DBA_HIST_IC_CLIENT_STATS is
'Historical interconnect client statistics'
/
create or replace public synonym DBA_HIST_IC_CLIENT_STATS
  for DBA_HIST_IC_CLIENT_STATS
/
grant select on DBA_HIST_IC_CLIENT_STATS to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IC_CLIENT_STATS','CDB_HIST_IC_CLIENT_STATS');
grant select on SYS.CDB_HIST_IC_CLIENT_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_IC_CLIENT_STATS for SYS.CDB_HIST_IC_CLIENT_STATS
/

/***************************************
 *        DBA_HIST_IC_DEVICE_STATS
 ***************************************/

create or replace view DBA_HIST_IC_DEVICE_STATS
as select * from AWR_CDB_IC_DEVICE_STATS
/
comment on table DBA_HIST_IC_DEVICE_STATS is
'Historical interconnect device statistics'
/
create or replace public synonym DBA_HIST_IC_DEVICE_STATS
  for DBA_HIST_IC_DEVICE_STATS
/
grant select on DBA_HIST_IC_DEVICE_STATS to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','AWR_PDB_IC_DEVICE_STATS','CDB_HIST_IC_DEVICE_STATS');
grant select on SYS.CDB_HIST_IC_DEVICE_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_IC_DEVICE_STATS for SYS.CDB_HIST_IC_DEVICE_STATS
/

/***************************************
 *        DBA_HIST_INTERCONNECT_PINGS
 ***************************************/

create or replace view DBA_HIST_INTERCONNECT_PINGS
as select * from AWR_CDB_INTERCONNECT_PINGS
/
comment on table DBA_HIST_INTERCONNECT_PINGS is
'Instance to instance ping stats'
/
create or replace public synonym DBA_HIST_INTERCONNECT_PINGS
  for DBA_HIST_INTERCONNECT_PINGS
/
grant select on DBA_HIST_INTERCONNECT_PINGS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_INTERCONNECT_PINGS','CDB_HIST_INTERCONNECT_PINGS');
grant select on SYS.CDB_HIST_INTERCONNECT_PINGS to select_catalog_role
/
create or replace public synonym CDB_HIST_INTERCONNECT_PINGS for SYS.CDB_HIST_INTERCONNECT_PINGS
/

/***************************************
 *        DBA_HIST_DISPATCHER
 ***************************************/

create or replace view DBA_HIST_DISPATCHER
as select * from AWR_CDB_DISPATCHER
/
comment on table DBA_HIST_DISPATCHER is
'Dispatcher statistics'
/
create or replace public synonym DBA_HIST_DISPATCHER
    for DBA_HIST_DISPATCHER
/
grant select on DBA_HIST_DISPATCHER to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DISPATCHER','CDB_HIST_DISPATCHER');
grant select on SYS.CDB_HIST_DISPATCHER to select_catalog_role
/
create or replace public synonym CDB_HIST_DISPATCHER for SYS.CDB_HIST_DISPATCHER
/

/***************************************
 *        DBA_HIST_SHARED_SERVER_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SHARED_SERVER_SUMMARY
as select * from AWR_CDB_SHARED_SERVER_SUMMARY
/
comment on table DBA_HIST_SHARED_SERVER_SUMMARY is
'Shared Server summary statistics'
/
create or replace public synonym DBA_HIST_SHARED_SERVER_SUMMARY
  for DBA_HIST_SHARED_SERVER_SUMMARY
/
grant select on DBA_HIST_SHARED_SERVER_SUMMARY to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SHARED_SERVER_SUMMARY','CDB_HIST_SHARED_SERVER_SUMMARY');
grant select on SYS.CDB_HIST_SHARED_SERVER_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_SHARED_SERVER_SUMMARY for SYS.CDB_HIST_SHARED_SERVER_SUMMARY
/

/***************************************
 *        DBA_HIST_DYN_REMASTER_STATS
 ***************************************/

create or replace view DBA_HIST_DYN_REMASTER_STATS
as select * from AWR_CDB_DYN_REMASTER_STATS
/
comment on table DBA_HIST_DYN_REMASTER_STATS is
'Dynamic remastering statistics'
/
create or replace public synonym DBA_HIST_DYN_REMASTER_STATS
  for DBA_HIST_DYN_REMASTER_STATS
/
grant select on DBA_HIST_DYN_REMASTER_STATS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_DYN_REMASTER_STATS','CDB_HIST_DYN_REMASTER_STATS');
grant select on SYS.CDB_HIST_DYN_REMASTER_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_DYN_REMASTER_STATS for SYS.CDB_HIST_DYN_REMASTER_STATS
/

/***************************************
 *        DBA_HIST_LMS_STATS
 ***************************************/

create or replace view DBA_HIST_LMS_STATS
as select * from AWR_CDB_LMS_STATS
/
comment on table DBA_HIST_LMS_STATS is
'LMS statistics'
/
create or replace public synonym DBA_HIST_LMS_STATS
  for DBA_HIST_LMS_STATS
/
grant select on DBA_HIST_LMS_STATS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_LMS_STATS','CDB_HIST_LMS_STATS');
grant select on SYS.CDB_HIST_LMS_STATS to select_catalog_role
/
create or replace public synonym CDB_HIST_LMS_STATS for SYS.CDB_HIST_LMS_STATS
/

/*****************************************
 *        DBA_HIST_PERSISTENT_QMN_CACHE
 *****************************************/

create or replace view DBA_HIST_PERSISTENT_QMN_CACHE
as select * from  AWR_CDB_PERSISTENT_QMN_CACHE
/

comment on table DBA_HIST_PERSISTENT_QMN_CACHE is
'STREAMS AQ Persistent QMN Cache Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_QMN_CACHE
    for DBA_HIST_PERSISTENT_QMN_CACHE
/
grant select on DBA_HIST_PERSISTENT_QMN_CACHE to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PERSISTENT_QMN_CACHE','CDB_HIST_PERSISTENT_QMN_CACHE');
grant select on SYS.CDB_HIST_PERSISTENT_QMN_CACHE to select_catalog_role
/
create or replace public synonym CDB_HIST_PERSISTENT_QMN_CACHE for SYS.CDB_HIST_PERSISTENT_QMN_CACHE
/

/***************************************
 *   DBA_HIST_PDB_INSTANCE
 ***************************************/
create or replace view DBA_HIST_PDB_INSTANCE
as select * from AWR_CDB_PDB_INSTANCE
/

comment on table DBA_HIST_PDB_INSTANCE is
'Pluggable Database Instance Information'
/
create or replace public synonym DBA_HIST_PDB_INSTANCE
   for DBA_HIST_PDB_INSTANCE
/
grant select on DBA_HIST_PDB_INSTANCE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PDB_INSTANCE','CDB_HIST_PDB_INSTANCE');
grant select on SYS.CDB_HIST_PDB_INSTANCE to select_catalog_role
/
create or replace public synonym CDB_HIST_PDB_INSTANCE for SYS.CDB_HIST_PDB_INSTANCE
/

/***************************************
 *   DBA_HIST_PDB_IN_SNAP
 ***************************************/
create or replace view DBA_HIST_PDB_IN_SNAP
as select * from AWR_CDB_PDB_IN_SNAP
/
comment on table DBA_HIST_PDB_IN_SNAP is
'Pluggable Databases in a snapshot'
/
create or replace public synonym DBA_HIST_PDB_IN_SNAP
   for DBA_HIST_PDB_IN_SNAP
/
grant select on DBA_HIST_PDB_IN_SNAP to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_PDB_IN_SNAP','CDB_HIST_PDB_IN_SNAP');
grant select on SYS.CDB_HIST_PDB_IN_SNAP to select_catalog_role
/
create or replace public synonym CDB_HIST_PDB_IN_SNAP for SYS.CDB_HIST_PDB_IN_SNAP
/

/**************************************
 *   DBA_HIST_CELL_CONFIG
 ***************************************/
create or replace view DBA_HIST_CELL_CONFIG
as select * from AWR_CDB_CELL_CONFIG
/

comment on table DBA_HIST_CELL_CONFIG is 
'Exadata configuration information'
/  
create or replace public synonym DBA_HIST_CELL_CONFIG
  for DBA_HIST_CELL_CONFIG
/  
grant select on DBA_HIST_CELL_CONFIG to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_CONFIG','CDB_HIST_CELL_CONFIG');
grant select on SYS.CDB_HIST_CELL_CONFIG to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_CONFIG for SYS.CDB_HIST_CELL_CONFIG
/

/**************************************
 *   DBA_HIST_CELL_CONFIG_DETAIL
 ***************************************/
create or replace view DBA_HIST_CELL_CONFIG_DETAIL
as select * from AWR_CDB_CELL_CONFIG_DETAIL
/

comment on table DBA_HIST_CELL_CONFIG_DETAIL is 
'Exadata configuration information per snapshot'
/  
create or replace public synonym DBA_HIST_CELL_CONFIG_DETAIL
  for DBA_HIST_CELL_CONFIG_DETAIL
/  
grant select on DBA_HIST_CELL_CONFIG_DETAIL to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_CONFIG_DETAIL','CDB_HIST_CELL_CONFIG_DETAIL');
grant select on SYS.CDB_HIST_CELL_CONFIG_DETAIL to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_CONFIG_DETAIL for SYS.CDB_HIST_CELL_CONFIG_DETAIL
/

/***************************************
 *   DBA_HIST_ASM_DISKGROUP
 ***************************************/
create or replace view DBA_HIST_ASM_DISKGROUP
as select * from AWR_CDB_ASM_DISKGROUP
/  

comment on table DBA_HIST_ASM_DISKGROUP is 
'ASM Diskgroups connected to this Database'
/  
create or replace public synonym DBA_HIST_ASM_DISKGROUP
  for DBA_HIST_ASM_DISKGROUP
/  
grant select on DBA_HIST_ASM_DISKGROUP to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ASM_DISKGROUP','CDB_HIST_ASM_DISKGROUP');
grant select on SYS.CDB_HIST_ASM_DISKGROUP to select_catalog_role
/
create or replace public synonym CDB_HIST_ASM_DISKGROUP for SYS.CDB_HIST_ASM_DISKGROUP
/

/***************************************
 *   DBA_HIST_ASM_DISKGROUP_STAT
 ***************************************/
create or replace view DBA_HIST_ASM_DISKGROUP_STAT
as select * from AWR_CDB_ASM_DISKGROUP_STAT
/  

comment on table DBA_HIST_ASM_DISKGROUP_STAT is
'Statistics for ASM Diskgroup connected to this Database'
/  
create or replace public synonym DBA_HIST_ASM_DISKGROUP_STAT
  for DBA_HIST_ASM_DISKGROUP_STAT
/   
grant select on DBA_HIST_ASM_DISKGROUP_STAT to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ASM_DISKGROUP_STAT','CDB_HIST_ASM_DISKGROUP_STAT');
grant select on SYS.CDB_HIST_ASM_DISKGROUP_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_ASM_DISKGROUP_STAT for SYS.CDB_HIST_ASM_DISKGROUP_STAT
/

/***************************************
 *   DBA_HIST_ASM_BAD_DISK
 ***************************************/
create or replace view DBA_HIST_ASM_BAD_DISK
as select * from AWR_CDB_ASM_BAD_DISK
/

comment on table DBA_HIST_ASM_BAD_DISK is
'Non-Online ASM Disks'
/
create or replace public synonym DBA_HIST_ASM_BAD_DISK
  for DBA_HIST_ASM_BAD_DISK
/
grant select on DBA_HIST_ASM_BAD_DISK to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ASM_BAD_DISK','CDB_HIST_ASM_BAD_DISK');
grant select on SYS.CDB_HIST_ASM_BAD_DISK to select_catalog_role
/
create or replace public synonym CDB_HIST_ASM_BAD_DISK for SYS.CDB_HIST_ASM_BAD_DISK
/

/*****************************************
 *        DBA_HIST_CELL_NAME
 *****************************************/
create or replace view DBA_HIST_CELL_NAME
as select * from AWR_CDB_CELL_NAME
/

comment on table DBA_HIST_CELL_NAME is
'Exadata Cell names'
/
create or replace public synonym DBA_HIST_CELL_NAME
   for DBA_HIST_CELL_NAME
/
grant select on DBA_HIST_CELL_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_NAME','CDB_HIST_CELL_NAME');
grant select on SYS.CDB_HIST_CELL_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_NAME for SYS.CDB_HIST_CELL_NAME
/

/*****************************************
 *        DBA_HIST_CELL_DISKTYPE
 *****************************************/
create or replace view DBA_HIST_CELL_DISKTYPE
as select * from AWR_CDB_CELL_DISKTYPE
/

comment on table DBA_HIST_CELL_DISKTYPE is
'Exadata Cell disk types'
/
create or replace public synonym DBA_HIST_CELL_DISKTYPE
   for DBA_HIST_CELL_DISKTYPE
/
grant select on DBA_HIST_CELL_DISKTYPE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_DISKTYPE','CDB_HIST_CELL_DISKTYPE');
grant select on SYS.CDB_HIST_CELL_DISKTYPE to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_DISKTYPE for SYS.CDB_HIST_CELL_DISKTYPE
/

/*****************************************
 *        DBA_HIST_CELL_DISK_NAME
 *****************************************/
-- tmp workaround for ORA-7445 bug16457282
-- use xmlsequence instead of xmltable
create or replace view DBA_HIST_CELL_DISK_NAME
as select * from AWR_CDB_CELL_DISK_NAME
/

comment on table DBA_HIST_CELL_DISK_NAME is
'Exadata Cell disk names'
/
create or replace public synonym DBA_HIST_CELL_DISK_NAME
   for DBA_HIST_CELL_DISK_NAME
/
grant select on DBA_HIST_CELL_DISK_NAME to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_DISK_NAME','CDB_HIST_CELL_DISK_NAME');
grant select on SYS.CDB_HIST_CELL_DISK_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_DISK_NAME for SYS.CDB_HIST_CELL_DISK_NAME
/

/*****************************************
 *        DBA_HIST_CELL_GLOBAL_SUMMARY
 *****************************************/
create or replace view DBA_HIST_CELL_GLOBAL_SUMMARY
as select * from AWR_CDB_CELL_GLOBAL_SUMMARY
/

comment on table DBA_HIST_CELL_GLOBAL_SUMMARY is
'Cell Global Summary Statistics'
/
create or replace public synonym DBA_HIST_CELL_GLOBAL_SUMMARY
    for DBA_HIST_CELL_GLOBAL_SUMMARY
/
grant select on DBA_HIST_CELL_GLOBAL_SUMMARY to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_GLOBAL_SUMMARY','CDB_HIST_CELL_GLOBAL_SUMMARY');
grant select on SYS.CDB_HIST_CELL_GLOBAL_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_GLOBAL_SUMMARY for SYS.CDB_HIST_CELL_GLOBAL_SUMMARY
/



/*****************************************
 *        DBA_HIST_CELL_DISK_SUMMARY
 *****************************************/
create or replace view DBA_HIST_CELL_DISK_SUMMARY
as select * from AWR_CDB_CELL_DISK_SUMMARY
/

comment on table DBA_HIST_CELL_DISK_SUMMARY is
'Cell Disk Summary Statistics'
/
create or replace public synonym DBA_HIST_CELL_DISK_SUMMARY
    for DBA_HIST_CELL_DISK_SUMMARY
/
grant select on DBA_HIST_CELL_DISK_SUMMARY to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_DISK_SUMMARY','CDB_HIST_CELL_DISK_SUMMARY');
grant select on SYS.CDB_HIST_CELL_DISK_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_DISK_SUMMARY for SYS.CDB_HIST_CELL_DISK_SUMMARY
/

/***************************************
 *        DBA_HIST_CELL_METRIC_DESC
 ***************************************/

create or replace view DBA_HIST_CELL_METRIC_DESC
as select * from AWR_CDB_CELL_METRIC_DESC
/


comment on table DBA_HIST_CELL_METRIC_DESC is
'Cell Metric Names'
/
create or replace public synonym DBA_HIST_CELL_METRIC_DESC 
                     for DBA_HIST_CELL_METRIC_DESC
/
grant select on DBA_HIST_CELL_METRIC_DESC to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_METRIC_DESC','CDB_HIST_CELL_METRIC_DESC');
grant select on SYS.CDB_HIST_CELL_METRIC_DESC to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_METRIC_DESC for SYS.CDB_HIST_CELL_METRIC_DESC
/

/***************************************
 *        DBA_HIST_CELL_IOREASON_NAME
 ***************************************/

create or replace view DBA_HIST_CELL_IOREASON_NAME
as select * from AWR_CDB_CELL_IOREASON_NAME
/


comment on table DBA_HIST_CELL_IOREASON_NAME is
'Cell IO Reason Names'
/
create or replace public synonym DBA_HIST_CELL_IOREASON_NAME 
                     for DBA_HIST_CELL_IOREASON_NAME
/
grant select on DBA_HIST_CELL_IOREASON_NAME to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_IOREASON_NAME','CDB_HIST_CELL_IOREASON_NAME');
grant select on SYS.CDB_HIST_CELL_IOREASON_NAME to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_IOREASON_NAME for SYS.CDB_HIST_CELL_IOREASON_NAME
/

/***************************************
 *        DBA_HIST_CELL_GLOBAL
 ***************************************/

create or replace view DBA_HIST_CELL_GLOBAL
as select * from AWR_CDB_CELL_GLOBAL
/


comment on table DBA_HIST_CELL_GLOBAL is
'Cell Global Statistics Information'
/
create or replace public synonym DBA_HIST_CELL_GLOBAL for DBA_HIST_CELL_GLOBAL
/
grant select on DBA_HIST_CELL_GLOBAL to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_GLOBAL','CDB_HIST_CELL_GLOBAL');
grant select on SYS.CDB_HIST_CELL_GLOBAL to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_GLOBAL for SYS.CDB_HIST_CELL_GLOBAL
/

/***************************************
 *        DBA_HIST_CELL_IOREASON
 ***************************************/

create or replace view DBA_HIST_CELL_IOREASON
as select * from AWR_CDB_CELL_IOREASON
/


comment on table DBA_HIST_CELL_IOREASON is
'Cell IO Reason Statistics Information'
/
create or replace public synonym DBA_HIST_CELL_IOREASON for DBA_HIST_CELL_IOREASON
/
grant select on DBA_HIST_CELL_IOREASON to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_IOREASON','CDB_HIST_CELL_IOREASON');
grant select on SYS.CDB_HIST_CELL_IOREASON to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_IOREASON for SYS.CDB_HIST_CELL_IOREASON
/

/***************************************
 *        DBA_HIST_CELL_DB
 ***************************************/

create or replace view DBA_HIST_CELL_DB
as select * from AWR_CDB_CELL_DB
/


comment on table DBA_HIST_CELL_DB is
'Cell Database IO Statistics Information'
/
create or replace public synonym DBA_HIST_CELL_DB for DBA_HIST_CELL_DB
/
grant select on DBA_HIST_CELL_DB to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_DB','CDB_HIST_CELL_DB');
grant select on SYS.CDB_HIST_CELL_DB to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_DB for SYS.CDB_HIST_CELL_DB
/

/***************************************
 *        DBA_HIST_CELL_OPEN_ALERTS
 ***************************************/

create or replace view DBA_HIST_CELL_OPEN_ALERTS
as select * from AWR_CDB_CELL_OPEN_ALERTS
/


comment on table DBA_HIST_CELL_OPEN_ALERTS is
'Cell Open Alerts Information'
/
create or replace public synonym DBA_HIST_CELL_OPEN_ALERTS for DBA_HIST_CELL_OPEN_ALERTS
/
grant select on DBA_HIST_CELL_OPEN_ALERTS to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false,'SYS','AWR_PDB_CELL_OPEN_ALERTS','CDB_HIST_CELL_OPEN_ALERTS');
grant select on SYS.CDB_HIST_CELL_OPEN_ALERTS to select_catalog_role
/
create or replace public synonym CDB_HIST_CELL_OPEN_ALERTS for SYS.CDB_HIST_CELL_OPEN_ALERTS
/

/***************************************
 *        DBA_HIST_IM_SEG_STAT
 ***************************************/

create or replace view DBA_HIST_IM_SEG_STAT 
as select * from AWR_CDB_IM_SEG_STAT
/


comment on table DBA_HIST_IM_SEG_STAT is 
' Historical IM Segment Statistics Information'
/

create or replace public synonym DBA_HIST_IM_SEG_STAT
        for DBA_HIST_IM_SEG_STAT
/
grant select on DBA_HIST_IM_SEG_STAT to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false, 'SYS', 'AWR_PDB_IM_SEG_STAT','CDB_HIST_IM_SEG_STAT');
grant select on SYS.CDB_HIST_IM_SEG_STAT to select_catalog_role
/
create or replace public synonym CDB_HIST_IM_SEG_STAT for SYS.CDB_HIST_IM_SEG_STAT
/

/***************************************
 *        DBA_HIST_IM_SEG_STAT_OBJ
 ***************************************/

create or replace view DBA_HIST_IM_SEG_STAT_OBJ 
as select * from AWR_CDB_IM_SEG_STAT_OBJ
/
comment on table DBA_HIST_IM_SEG_STAT_OBJ is 
'IM Segment Names'
/
create or replace public synonym DBA_HIST_IM_SEG_STAT_OBJ 
        for DBA_HIST_IM_SEG_STAT_OBJ 
/
grant select on DBA_HIST_IM_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/ 


execute CDBView.create_cdbview(false, 'SYS', 'AWR_PDB_IM_SEG_STAT_OBJ', 'CDB_HIST_IM_SEG_STAT_OBJ'); 
grant select on SYS.CDB_HIST_IM_SEG_STAT_OBJ to select_catalog_role
/
create or replace public synonym CDB_HIST_IM_SEG_STAT_OBJ for SYS.CDB_HIST_IM_SEG_STAT_OBJ
/


/***************************************
 *        DBA_HIST_WR_SETTINGS
 ***************************************/
create or replace view DBA_HIST_WR_SETTINGS
as select * from AWR_CDB_WR_SETTINGS
/
comment on table DBA_HIST_WR_SETTINGS is
'Workload Repository Settings'
/
create or replace public synonym DBA_HIST_WR_SETTINGS
  for DBA_HIST_WR_SETTINGS
/
grant select on DBA_HIST_WR_SETTINGS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false, 'SYS', 'AWR_PDB_WR_SETTINGS', 'CDB_HIST_WR_SETTINGS');
grant select on SYS.CDB_HIST_WR_SETTINGS to select_catalog_role
/
create or replace public synonym CDB_HIST_WR_SETTINGS for SYS.CDB_HIST_WR_SETTINGS
/


/***************************************
 *        DBA_HIST_PROCESS_WAITTIME
 ***************************************/
create or replace view DBA_HIST_PROCESS_WAITTIME
as select * from AWR_CDB_PROCESS_WAITTIME
/
comment on table DBA_HIST_PROCESS_WAITTIME is
'cpu and wait time by process types'
/
create or replace public synonym DBA_HIST_PROCESS_WAITTIME
  for DBA_HIST_PROCESS_WAITTIME
/
grant select on DBA_HIST_PROCESS_WAITTIME to SELECT_CATALOG_ROLE
/

execute CDBView.create_cdbview(false, 'SYS', 'AWR_PDB_PROCESS_WAITTIME', 'CDB_HIST_PROCESS_WAITTIME');
grant select on SYS.CDB_HIST_PROCESS_WAITTIME to select_catalog_role
/
create or replace public synonym CDB_HIST_PROCESS_WAITTIME for SYS.CDB_HIST_PROCESS_WAITTIME
/

/***************************************
 *   DBA_HIST_ASM_DISK_STAT_SUMMARY
 ***************************************/
create or replace view DBA_HIST_ASM_DISK_STAT_SUMMARY
as select * from AWR_CDB_ASM_DISK_STAT_SUMMARY
/  

comment on table DBA_HIST_ASM_DISK_STAT_SUMMARY is
'Summary statistics for ASM Disks'
/  
create or replace public synonym DBA_HIST_ASM_DISK_STAT_SUMMARY
  for DBA_HIST_ASM_DISK_STAT_SUMMARY
/   
grant select on DBA_HIST_ASM_DISK_STAT_SUMMARY to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_ASM_DISK_STAT_SUMMARY','CDB_HIST_ASM_DISK_STAT_SUMMARY');
grant select on SYS.CDB_HIST_ASM_DISK_STAT_SUMMARY to select_catalog_role
/
create or replace public synonym CDB_HIST_ASM_DISK_STAT_SUMMARY for SYS.CDB_HIST_ASM_DISK_STAT_SUMMARY
/


@?/rdbms/admin/sqlsessend.sql
