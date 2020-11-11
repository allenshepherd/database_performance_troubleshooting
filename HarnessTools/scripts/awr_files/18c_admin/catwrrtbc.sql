Rem
Rem $Header: rdbms/admin/catwrrtbc.sql /main/23 2017/11/16 14:50:00 josmamar Exp $
Rem
Rem catwrrtbc.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrtbc.sql - Catalog script for 
Rem                      the Workload Capture tables
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary tables for the 
Rem      Workload Capture infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem      Almost all DML on the tables defined in 
Rem      this script comes from DBMS_WORKLOAD_CAPTURE.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrtbc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrtbc.sql
Rem SQL_PHASE: CATWRRTBC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrtb.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    josmamar    11/13/17 - bug 26989795: long sql text support
Rem    qinwu       09/06/17 - bug 18488916: sql with sess/pdb switch container
Rem    qinwu       06/07/17 - bug 25975538: sql text and support for remapping
Rem    josmamar    05/11/17 - bug 22374149: add WRR$_CAPTURE_FILES table
Rem    qinwu       03/20/17 - proj 70152: add columns for capture encryption
Rem    yberezin    09/08/15 - don't use SYSTEM tablespace
Rem    quotran     06/24/15 - bug 21610276: support always-on capture
Rem    yberezin    01/29/15 - bug 20381239: long IDs
Rem    qinwu       12/20/14 - proj 47326: ADD columns for PL/SQL subcalls
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    yberezin    11/08/13 - bug 17391276: introduce OS time for
Rem                           capture/replay start
Rem    yberezin    04/30/12 - bug 14004148
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    traney      03/31/11 - 35209: long identifiers dictionary upgrade
Rem    lgalanis    03/24/09 - add support for STS capture with Capture and
Rem                           Replay
Rem    rcolle      09/08/08 - add flags to WRR$_CAPTURE_UC_GRAPH
Rem    sburanaw    06/19/08 - added workload_id to wrr$_captures
Rem    rcolle      05/08/08 - add WRR$_CAPTURE_UC_GRAPH
Rem    veeve       02/19/07 - added dbversion, awr_* to wrr$_captures
Rem    veeve       02/19/07 - added _tstart, _tend cols to wrr$_capture_stats
Rem    veeve       08/03/06 - added dbid, dbname, last_prep_version
Rem    veeve       07/13/06 - added capture_size
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       01/25/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ================================================================
Rem      ######################################################
Rem      CREATING THE COMMON SCHEMA (SHARED BY CAPTURE & REPLAY)
Rem      ######################################################
Rem ================================================================


Rem %%%%%%%%%%%%
Rem WRR$_FILTERS
Rem %%%%%%%%%%%%
Rem
Rem Table that stores information about 
Rem various types of filters used during
Rem workload captures or replay.
Rem

create table WRR$_FILTERS
( wrr_id                    number          not null
 ,filter_type               varchar2(30)    not null  /* not M_IDEN */
 ,name                      varchar2(128)   not null
 ,attribute                 varchar2(128)   not null
 ,value                     varchar2(4000)  not null
 ,constraint WRR$_FILTERS_PK primary key
    (wrr_id, filter_type, name)
) tablespace SYSAUX
/

comment on column WRR$_FILTERS.FILTER_TYPE is
'One of "CAPTURE" or "REPLAY"'
/


Rem ================================================================
Rem      #####################################################
Rem      CREATING THE WORKLOAD CAPTURE INFRASTRUCTURE SCHEMA
Rem      #####################################################
Rem ================================================================


Rem =========================================================
Rem Creating the Database Property that remembers if the 
Rem database is in the CAPTURE mode.
Rem
Rem  Set to CAPTURE  : By DBMS_WORKLOAD_CAPTURE.START_CAPTURE
Rem  Reset to NULL   : By DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE
Rem  Read            : During instance startup by kecrDBOpen()
Rem =========================================================
Rem
Rem NOTE: This property name is duplicated in KECR_DBPROPERTY_NAME
Rem
insert into PROPS$
        select  'WORKLOAD_CAPTURE_MODE', NULL, 
                'CAPTURE implies workload capture is in progress'
        from    sys.dual
        where   not exists (select  'x'
                            from    PROPS$
                            where   name = 'WORKLOAD_CAPTURE_MODE')
/
update PROPS$ 
set    value$ = NULL
where  name = 'WORKLOAD_CAPTURE_MODE'
/
commit
/

Rem =================================================================
Rem Creating the tables used by the Workload Capture infrastructure
Rem =================================================================
Rem

Rem %%%%%%%%%%%%%%%
Rem WRR$_CAPTURES
Rem %%%%%%%%%%%%%%%
Rem
Rem Table that stores information (name, target_dir, 
Rem start_scn, stats etc) about all workload captures
Rem that has happened in this database.
Rem

create table WRR$_CAPTURES
( id                        number          not null
 ,name                      varchar2(128)   not null
 ,dbid                      number          not null
 ,dbname                    varchar2(10)    not null
 ,dbversion                 varchar2(17)    not null
 ,directory                 varchar2(128)   not null
 ,dir_path                  varchar2(4000)  not null
 ,dir_path_shared           varchar2(10)    not null
 ,status                    varchar2(40)    not null
 ,start_time                date            not null
 ,end_time                  date
 ,start_scn                 number          not null
 ,end_scn                   number
 ,default_action            varchar2(30)    not null
 ,awr_dbid                  number
 ,awr_begin_snap            number
 ,awr_end_snap              number
 ,awr_exported              number
 ,error_code                number
 ,error_msg                 varchar2(512)
 ,comments                  varchar2(4000)
 ,last_prep_version         varchar2(128)
 ,workload_id               varchar2(40)
 ,sqlset_owner              varchar2(128)
 ,sqlset_name               varchar2(128)
 ,internal_start_time       integer
 ,plsql_mode                integer
 ,capture_type              integer
 ,encryption                varchar2(128)
 ,encryption_verifier       raw(512)
 ,constraint WRR$_CAPTURES_PK primary key
    (id)
) tablespace SYSAUX
/

comment on column WRR$_CAPTURES.STATUS is
'One of "IN PROGRESS", "COMPLETED" or "FAILED"'
/

comment on column WRR$_CAPTURES.DEFAULT_ACTION is
'One of "INCLUDE" or "EXCLUDE"'
/


Rem %%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_BUCKETS
Rem %%%%%%%%%%%%%%%
Rem
Rem Table that stores information about each bucket
Rem containing capture data
Rem

create table WRR$_CAPTURE_BUCKETS
( capture_id                number          not null
 ,bucket_id                 integer         not null
 ,constraint WRR$_CAPTURE_BUCKETS_PK primary key
   (capture_id, bucket_id)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_ID
Rem %%%%%%%%%%%%%%%%%
Rem
Rem Sequence to generate WRR$_CAPTURE.ID
Rem
create sequence WRR$_CAPTURE_ID
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem %%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_STATS
Rem %%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores stats about workload capture
Rem within this database.
Rem

create table WRR$_CAPTURE_STATS
( id                        number
 ,instance_number           number
 ,startup_time              date
 ,host_name                 varchar2(64)
 ,parallel                  varchar2(3)
 ,capture_size              number
 ,dbtime                    number
 ,dbtime_tstart             number
 ,dbtime_tend               number
 ,user_calls                number
 ,user_calls_tstart         number
 ,user_calls_tend           number
 ,user_calls_empty          number
 ,txns                      number
 ,txns_tstart               number
 ,txns_tend                 number
 ,connects                  number
 ,connects_tstart           number
 ,connects_tend             number
 ,errors                    number
 ,plsql_subcall_size        integer
 ,plsql_calls               integer
 ,plsql_subcalls            integer
 ,plsql_dbtime              integer 
 ,constraint WRR$_CAPTURE_STATS_PK primary key
    (id,instance_number,startup_time)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_UC_GRAPH
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the user calls metric history for the exported captures.
Rem

create table WRR$_CAPTURE_UC_GRAPH
( id                        number
 ,time                      date
 ,user_calls                number
 ,flags                     number
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_FILES
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the information related to the capture files. 
Rem

create table WRR$_CAPTURE_FILES
( capture_id            number
 ,cap_file_id           integer         not null
 ,seq_number            integer
 ,slave_id              integer         not null
 ,file_name             varchar2(30)
 ,file_path             varchar2(4000)
 ,login_time            number
 ,login_wallclock       number
 ,logoff_time           number
 ,login_scn             number
 ,last_complete_call    number
 ,num_calls             integer
 ,gid                   integer
 ,db_time               integer
 ,conn_id               number
 ,constraint WRR$_CAPTURE_FILES_PK primary key
    (capture_id, cap_file_id)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_SQL_TMP
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem staging table for collecting sql info during preprocessing

CREATE TABLE WRR$_CAPTURE_SQL_TMP
( sql_id                varchar2(13)
 ,cap_sql_id            varchar2(13)
 ,cap_sql_id_number     integer
 ,oct_type              integer
 ,flags                 integer
 ,sql_text              varchar2(1000)
 ,sql_length            integer
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_SQLTEXT
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem table that stores sql text for captures
Rem sql_id is computed from the captured sqltext. cap_sql_id is the recorded 
Rem sql_id. Due to the capture bug that removed null terminators at the end,
Rem these two values may be different for old capture that contains this bug.


create table WRR$_CAPTURE_SQLTEXT
( capture_id            integer
 ,sql_id                varchar2(13)
 ,cap_sql_id            varchar2(13)
 ,cap_sql_id_number     integer
 ,oct_type              integer
 ,flags                 integer
 ,sql_text              varchar2(1000)
 ,sql_length            integer
 ,constraint WRR$_CAPTURE_SQLTEXT_PK primary key
    (capture_id, sql_id)
) tablespace sysaux
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_CAPTURE_LONG_SQLTEXT
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem table that stores the sql text that exceeds the 1000 characters

create table WRR$_CAPTURE_LONG_SQLTEXT
( capture_id            integer
 ,sql_id                varchar2(13)
 ,sql_fulltext          clob
 ,constraint WRR$_CAPTURE_LONG_SQLTEXT_PK primary key
    (capture_id, sql_id)
) tablespace sysaux
/

@?/rdbms/admin/sqlsessend.sql
