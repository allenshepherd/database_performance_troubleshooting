Rem
Rem $Header: rdbms/admin/catawrpd.sql /st_rdbms_18.0/2 2017/12/08 15:09:01 osuro Exp $
Rem
Rem catawrpd.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catawrpd.sql - AWR views with Package Dependencies
Rem
Rem    DESCRIPTION
Rem     AWR views that are defined using packages 
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catawrpd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catawrpd.sql
Rem SQL_PHASE: CATAWRPD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/depssvrm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       12/07/17 - bug 27230424: Add predicate for SQLBIND views
Rem    osuro       11/28/17 - bug 27078828: Add AWR_CDB_* views
Rem    kmorfoni    05/16/16 - Bug 23279437: remove con_id from AWR tables
Rem    kmorfoni    04/22/16 - Bug 23176751: Remove join with v$database
Rem    kmorfoni    04/08/16 - Bug 23071193: Fix DBA_HIST_SQLBIND
Rem    kmorfoni    03/25/16 - Bug 22978680: create AWRIV$_ROOT_% views
Rem    kmorfoni    03/04/16 - Use correct con_id value in views
Rem    osuro       02/25/16 - Bug 22741414: add AWR_ROOT and AWR_PDB views
Rem    thbaby      06/10/14 - 18971004: remove INT$ views for OBL cases
Rem    spapadom    02/18/14 - container_data to DBA_HIST views (Bug17667161)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    thbaby      08/28/13 - 14515351: add INT$ views for sharing=object
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    svaziran    11/01/12 - 14076977: AWR report within a PDB
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ilistvin    07/05/11 - add CON_ID column
Rem    ilistvin    11/09/06 - AWR views with package dependencies
Rem    ilistvin    11/09/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

/***************************************
 *        AWR_CDB_BASELINE
 ***************************************/
create or replace view AWR_CDB_BASELINE
container_data container_data_admit_null con_id_filter sharing=extended data
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time,
   end_snap_id, end_snap_time, moving_window_size, creation_time,
   expiration, template_name, last_time_computed, CON_ID)
as
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
union all
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
/

comment on table AWR_CDB_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym AWR_CDB_BASELINE 
    for AWR_CDB_BASELINE
/
grant select on AWR_CDB_BASELINE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_ROOT_BASELINE
 ***************************************/
create or replace view AWR_ROOT_BASELINE
       container_data sharing=object
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time,
   end_snap_id, end_snap_time, moving_window_size, creation_time,
   expiration, template_name, last_time_computed, CON_ID)
as
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
union all
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
/

comment on table AWR_ROOT_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym AWR_ROOT_BASELINE 
    for AWR_ROOT_BASELINE
/
grant select on AWR_ROOT_BASELINE to SELECT_CATALOG_ROLE
/



/***************************************
 *        AWR_PDB_BASELINE
 ***************************************/
create or replace view AWR_PDB_BASELINE
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time,
   end_snap_id, end_snap_time, moving_window_size, creation_time,
   expiration, template_name, last_time_computed, CON_ID)
as
select bl.dbid, bl.baseline_id,
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
union all
select bl.dbid, bl.baseline_id,
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed),
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
/
comment on table AWR_PDB_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym AWR_PDB_BASELINE 
    for AWR_PDB_BASELINE
/
grant select on AWR_PDB_BASELINE to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_BASELINE
 ***************************************/
create or replace view DBA_HIST_BASELINE
as select * from AWR_CDB_BASELINE
/
comment on table DBA_HIST_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym DBA_HIST_BASELINE 
    for DBA_HIST_BASELINE
/
grant select on DBA_HIST_BASELINE to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BASELINE','CDB_HIST_BASELINE');
grant select on SYS.CDB_HIST_BASELINE to select_catalog_role
/
create or replace public synonym CDB_HIST_BASELINE for SYS.CDB_HIST_BASELINE
/



/***************************************
 *     AWR_CDB_BASELINE_DETAILS
 ***************************************/
create or replace view AWR_CDB_BASELINE_DETAILS
container_data container_data_admit_null con_id_filter sharing=extended data
  (dbid, instance_number, 
   baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time, 
   end_snap_id, end_snap_time,
   shutdown, error_count, pct_total_time, 
   last_time_computed,
   moving_window_size, creation_time, 
   expiration, template_name, CON_ID)
as
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
union all
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
/

comment on table AWR_CDB_BASELINE_DETAILS is
'Baseline Stats on per Instance Level'
/
create or replace public synonym AWR_CDB_BASELINE_DETAILS
    for AWR_CDB_BASELINE_DETAILS
/
grant select on AWR_CDB_BASELINE_DETAILS to SELECT_CATALOG_ROLE
/


/***************************************
 *     AWR_ROOT_BASELINE_DETAILS
 ***************************************/
create or replace view AWR_ROOT_BASELINE_DETAILS
       container_data sharing=object
  (dbid, instance_number, 
   baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time, 
   end_snap_id, end_snap_time,
   shutdown, error_count, pct_total_time, 
   last_time_computed,
   moving_window_size, creation_time, 
   expiration, template_name, CON_ID)
as
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
union all
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
/

comment on table AWR_ROOT_BASELINE_DETAILS is
'Baseline Stats on per Instance Level'
/
create or replace public synonym AWR_ROOT_BASELINE_DETAILS
    for AWR_ROOT_BASELINE_DETAILS
/
grant select on AWR_ROOT_BASELINE_DETAILS to SELECT_CATALOG_ROLE
/


/***************************************
 *     AWR_PDB_BASELINE_DETAILS
 ***************************************/
create or replace view AWR_PDB_BASELINE_DETAILS
  (dbid, instance_number, 
   baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time, 
   end_snap_id, end_snap_time,
   shutdown, error_count, pct_total_time, 
   last_time_computed,
   moving_window_size, creation_time, 
   expiration, template_name, CON_ID)
as
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
union all
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name,
       decode(con_dbid_to_id(bl.dbid), 1, 0, con_dbid_to_id(bl.dbid)) con_id
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
/
comment on table AWR_PDB_BASELINE_DETAILS is
'Baseline Stats on per Instance Level'
/
create or replace public synonym AWR_PDB_BASELINE_DETAILS
    for AWR_PDB_BASELINE_DETAILS
/
grant select on AWR_PDB_BASELINE_DETAILS to SELECT_CATALOG_ROLE
/


/***************************************
*     DBA_HIST_BASELINE_DETAILS
 ***************************************/
create or replace view DBA_HIST_BASELINE_DETAILS
as select * from AWR_CDB_BASELINE_DETAILS
/
comment on table DBA_HIST_BASELINE_DETAILS is
'Baseline Stats on per Instance Level'
/
create or replace public synonym DBA_HIST_BASELINE_DETAILS
    for DBA_HIST_BASELINE_DETAILS
/
grant select on DBA_HIST_BASELINE_DETAILS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_BASELINE_DETAILS','CDB_HIST_BASELINE_DETAILS');
grant select on SYS.CDB_HIST_BASELINE_DETAILS to select_catalog_role
/
create or replace public synonym CDB_HIST_BASELINE_DETAILS for SYS.CDB_HIST_BASELINE_DETAILS
/


/***************************************
 *     AWR_CDB_SQLBIND
 ***************************************/
create or replace view AWR_CDB_SQLBIND 
   (SNAP_ID, DBID, INSTANCE_NUMBER, 
    SQL_ID, NAME, POSITION, DUP_POSITION, DATATYPE, DATATYPE_STRING,
    CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, WAS_CAPTURED,
    LAST_CAPTURED, VALUE_STRING, VALUE_ANYDATA, CON_DBID, CON_ID)
as 
select snap_id                                                 snap_id,
       dbid                                                    dbid,
       instance_number                                         instance_number,
       sql_id                                                  sql_id,
       name                                                    name, 
       position                                                position, 
       nvl2(cap_bv, v.cap_bv.dup_position, dup_position)       dup_position,
       nvl2(cap_bv, v.cap_bv.datatype, datatype)               datatype,
       nvl2(cap_bv, v.cap_bv.datatype_string, datatype_string) datatype_string,
       nvl2(cap_bv, v.cap_bv.character_sid, character_sid)     character_sid,
       nvl2(cap_bv, v.cap_bv.precision, precision)             precision,
       nvl2(cap_bv, v.cap_bv.scale, scale)                     scale,
       nvl2(cap_bv, v.cap_bv.max_length, max_length)           max_length,
       nvl2(cap_bv, 'YES', 'NO')                               was_captured,
       nvl2(cap_bv, v.cap_bv.last_captured, NULL)              last_captured,
       nvl2(cap_bv, v.cap_bv.value_string, NULL)               value_string,
       nvl2(cap_bv, v.cap_bv.value_anydata, NULL)              value_anydata,
       con_dbid                                                con_dbid,
       con_id                                                  con_id
from
(select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length,
        sbm.con_dbid,
        sbm.con_id
 from   AWR_CDB_SNAPSHOT sn, AWR_CDB_SQL_BIND_METADATA sbm, 
        AWR_CDB_SQLSTAT sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.dbid           = sql.dbid
        and sbm.sql_id         = sql.sql_id
        and sbm.con_dbid       = sql.con_dbid) v
/

comment on table AWR_CDB_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym AWR_CDB_SQLBIND for AWR_CDB_SQLBIND
/
grant select on AWR_CDB_SQLBIND to SELECT_CATALOG_ROLE
/


/***************************************
 *     AWR_ROOT_SQLBIND
 ***************************************/
create or replace view AWR_ROOT_SQLBIND 
   (SNAP_ID, DBID, INSTANCE_NUMBER, 
    SQL_ID, NAME, POSITION, DUP_POSITION, DATATYPE, DATATYPE_STRING,
    CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, WAS_CAPTURED,
    LAST_CAPTURED, VALUE_STRING, VALUE_ANYDATA, CON_DBID, CON_ID)
as 
select snap_id                                                 snap_id,
       dbid                                                    dbid,
       instance_number                                         instance_number,
       sql_id                                                  sql_id,
       name                                                    name, 
       position                                                position, 
       nvl2(cap_bv, v.cap_bv.dup_position, dup_position)       dup_position,
       nvl2(cap_bv, v.cap_bv.datatype, datatype)               datatype,
       nvl2(cap_bv, v.cap_bv.datatype_string, datatype_string) datatype_string,
       nvl2(cap_bv, v.cap_bv.character_sid, character_sid)     character_sid,
       nvl2(cap_bv, v.cap_bv.precision, precision)             precision,
       nvl2(cap_bv, v.cap_bv.scale, scale)                     scale,
       nvl2(cap_bv, v.cap_bv.max_length, max_length)           max_length,
       nvl2(cap_bv, 'YES', 'NO')                               was_captured,
       nvl2(cap_bv, v.cap_bv.last_captured, NULL)              last_captured,
       nvl2(cap_bv, v.cap_bv.value_string, NULL)               value_string,
       nvl2(cap_bv, v.cap_bv.value_anydata, NULL)              value_anydata,
       con_dbid                                                con_dbid,
       con_id                                                  con_id
from
(select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length,
        sbm.con_dbid,
        sbm.con_id
 from   AWR_ROOT_SNAPSHOT sn, AWR_ROOT_SQL_BIND_METADATA sbm, 
        AWR_ROOT_SQLSTAT sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.dbid           = sql.dbid
        and sbm.sql_id         = sql.sql_id
        and sbm.con_dbid       = sql.con_dbid) v
/

comment on table AWR_ROOT_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym AWR_ROOT_SQLBIND for AWR_ROOT_SQLBIND
/
grant select on AWR_ROOT_SQLBIND to SELECT_CATALOG_ROLE
/


/***************************************
 *     AWR_PDB_SQLBIND
 ***************************************/
create or replace view AWR_PDB_SQLBIND 
   (SNAP_ID, DBID, INSTANCE_NUMBER, 
    SQL_ID, NAME, POSITION, DUP_POSITION, DATATYPE, DATATYPE_STRING,
    CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, WAS_CAPTURED,
    LAST_CAPTURED, VALUE_STRING, VALUE_ANYDATA, CON_DBID, CON_ID)
as 
select snap_id                                                 snap_id,
       dbid                                                    dbid,
       instance_number                                         instance_number,
       sql_id                                                  sql_id,
       name                                                    name, 
       position                                                position, 
       nvl2(cap_bv, v.cap_bv.dup_position, dup_position)       dup_position,
       nvl2(cap_bv, v.cap_bv.datatype, datatype)               datatype,
       nvl2(cap_bv, v.cap_bv.datatype_string, datatype_string) datatype_string,
       nvl2(cap_bv, v.cap_bv.character_sid, character_sid)     character_sid,
       nvl2(cap_bv, v.cap_bv.precision, precision)             precision,
       nvl2(cap_bv, v.cap_bv.scale, scale)                     scale,
       nvl2(cap_bv, v.cap_bv.max_length, max_length)           max_length,
       nvl2(cap_bv, 'YES', 'NO')                               was_captured,
       nvl2(cap_bv, v.cap_bv.last_captured, NULL)              last_captured,
       nvl2(cap_bv, v.cap_bv.value_string, NULL)               value_string,
       nvl2(cap_bv, v.cap_bv.value_anydata, NULL)              value_anydata,
       con_dbid                                                con_dbid,
       con_id                                                  con_id
from
(select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length,
        sbm.con_dbid,
        sbm.con_id
 from   AWR_PDB_SNAPSHOT sn, AWR_PDB_SQL_BIND_METADATA sbm, 
        AWR_PDB_SQLSTAT sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.dbid           = sql.dbid
        and sbm.sql_id         = sql.sql_id
        and sbm.con_dbid       = sql.con_dbid) v
/

comment on table AWR_PDB_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym AWR_PDB_SQLBIND for AWR_PDB_SQLBIND
/
grant select on AWR_PDB_SQLBIND to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_SQLBIND
 ***************************************/
create or replace view DBA_HIST_SQLBIND 
as select * from AWR_CDB_SQLBIND
/

comment on table DBA_HIST_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym DBA_HIST_SQLBIND for DBA_HIST_SQLBIND
/
grant select on DBA_HIST_SQLBIND to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','AWR_PDB_SQLBIND','CDB_HIST_SQLBIND');
grant select on SYS.CDB_HIST_SQLBIND to select_catalog_role
/
create or replace public synonym CDB_HIST_SQLBIND for SYS.CDB_HIST_SQLBIND
/


@?/rdbms/admin/sqlsessend.sql
