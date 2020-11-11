Rem
Rem $Header: rdbms/admin/c1201000_wrr.sql /main/2 2016/11/15 10:55:10 qinwu Exp $
Rem
Rem c1201000_wrr.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      c1201000_wrr.sql
Rem
Rem    DESCRIPTION
Rem      Workload Capture and Replay upgrade script
Rem
Rem    NOTES
Rem      Notice that we have two types of tables: repository tables that store
Rem      information across upgrades and downgrades (e.g. wrr$_captures,
Rem      wrr$_replays) and working tables whose contents are invalidated by
Rem      upgrades and downgrades (e.g. wrr$_replay_scn_order). The working
Rem      tables are populated by processing capture and used during replay;
Rem      re-preprocessing is a requirement after an upgrade or downgrade.
Rem      Dropping and recreating a working table when upgrading or downgrading
Rem      is perfectly OK.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    03/24/16 - Created

-- Add columns introduced in 12.1.0.2
ALTER TABLE wrr$_captures ADD( internal_start_time INTEGER );
ALTER TABLE wrr$_replays  ADD( divergence_load_status VARCHAR2(5) );
ALTER TABLE wrr$_replays  ADD( internal_start_time INTEGER );

-- Add columns introduced in 12.2
ALTER TABLE wrr$_captures ADD(plsql_mode   INTEGER);
ALTER TABLE wrr$_captures ADD(capture_type INTEGER);

ALTER TABLE wrr$_capture_stats ADD(plsql_subcall_size INTEGER);
ALTER TABLE wrr$_capture_stats ADD(plsql_calls        INTEGER);
ALTER TABLE wrr$_capture_stats ADD(plsql_subcalls     INTEGER);
ALTER TABLE wrr$_capture_stats ADD(plsql_dbtime       INTEGER);

ALTER TABLE wrr$_replay_stats ADD (plsql_calls    INTEGER);
ALTER TABLE wrr$_replay_stats ADD (plsql_subcalls INTEGER);
ALTER TABLE wrr$_replay_stats ADD (plsql_dbtime   INTEGER);

-- BEGIN bug 20867498: long ids
ALTER TABLE wrr$_masking_definition MODIFY owner_name  VARCHAR2(128);
ALTER TABLE wrr$_masking_definition MODIFY table_name  VARCHAR2(128);
ALTER TABLE wrr$_masking_definition MODIFY column_name VARCHAR2(128);
-- END bug 20867498: long ids

-- BEGIN bug 21497629: long ids
ALTER TABLE wrr$_captures MODIFY name              VARCHAR2(128);
ALTER TABLE wrr$_captures MODIFY directory         VARCHAR2(128);
ALTER TABLE wrr$_captures MODIFY last_prep_version VARCHAR2(128);
ALTER TABLE wrr$_captures MODIFY sqlset_owner      VARCHAR2(128);
ALTER TABLE wrr$_captures MODIFY sqlset_name       VARCHAR2(128);

ALTER TABLE wrr$_replays MODIFY name         VARCHAR2(128);
ALTER TABLE wrr$_replays MODIFY directory    VARCHAR2(128);
ALTER TABLE wrr$_replays MODIFY sqlset_owner VARCHAR2(128);
ALTER TABLE wrr$_replays MODIFY sqlset_name  VARCHAR2(128);

ALTER TABLE wrr$_replay_seq_data MODIFY seq_name VARCHAR2(128);
ALTER TABLE wrr$_replay_seq_data MODIFY seq_bnm  VARCHAR2(128);
ALTER TABLE wrr$_replay_seq_data MODIFY seq_bow  VARCHAR2(128);
-- END bug 21497629: long ids

-- BEGIN bug 21787780
ALTER TABLE wrr$_captures MODIFY dbversion VARCHAR2( 17);
ALTER TABLE wrr$_captures MODIFY error_msg VARCHAR2(512);

ALTER TABLE wrr$_replays MODIFY dbversion       VARCHAR2( 17);
ALTER TABLE wrr$_replays MODIFY error_msg       VARCHAR2(512);
ALTER TABLE wrr$_replays MODIFY filter_set_name VARCHAR2(128);
ALTER TABLE wrr$_replays MODIFY schedule_name   VARCHAR2(128);
-- END bug 21787780

begin
  execute immediate 'REVOKE SELECT ON wrr$_replay_call_filter FROM PUBLIC';
exception
  when others then null;
end;
/

-- BEGIN bug 22713655

-- During upgrade, it happens that the views user_tables and user_tab_columns
-- get invalidated and so are unusable - that's why the function.
-- NULL cname     => check the table existence
-- not-NULL cname => check the column existence
create or replace function wrr_exists( tname varchar2, cname varchar2 )
    return boolean as
begin
  -- NULL cname => select count(*); otherwise select count(cname)
  execute immediate 'select count('|| nvl(cname,'*') ||') from '||tname;
  return true;
exception
  when others then return false;
end;
/

begin
  -- wrr$_replays, tail of the definition
  -- 12.1.0.2  our old patch  MAIN
  -- --------  -------------  -------------------------
  --                          plsql_mode
  --                          connect_time_auto_correct
  --           rac_mode       rac_mode
  --                          flags

  if not wrr_exists('wrr$_replays', 'rac_mode') then  -- 12.1.0.2
    execute immediate
    'ALTER TABLE wrr$_replays ADD(plsql_mode                INTEGER,
                                  connect_time_auto_correct INTEGER,
                                  rac_mode                  INTEGER,
                                  flags                     INTEGER)';
    return;
  end if;

  if wrr_exists('wrr$_replays', 'flags') then return; end if;

  -- old patch - we have to reorder the columns
  execute immediate
  'create global temporary table wrr$_replays_tmp
                as select * from wrr$_replays';

  execute immediate 'drop table wrr$_replays purge';

  execute immediate
  'create table WRR$_REPLAYS
  ( id                        number          not null
   ,name                      varchar2(128)   not null
   ,dbid                      number          not null
   ,dbname                    varchar2(10)    not null
   ,dbversion                 varchar2(17)    not null
   ,directory                 varchar2(128)   not null
   ,dir_path                  varchar2(4000)  not null
   ,capture_id                number
   ,status                    varchar2(40)    not null
   ,prepare_time              date
   ,start_time                date
   ,end_time                  date
   ,num_clients               number          not null
   ,num_clients_done          number          not null
   ,default_action            varchar2(30)    not null
   ,synchronization           number          not null
   ,connect_time_scale        number          not null
   ,think_time_scale          number          not null
   ,think_time_auto_correct   number          not null
   ,scale_up_multiplier       number          default 1 not null
   ,awr_dbid                  number
   ,awr_begin_snap            number
   ,awr_end_snap              number
   ,awr_exported              number
   ,error_code                number
   ,error_msg                 varchar2(512)
   ,comments                  varchar2(4000)
   ,preprocessing_id          number
   ,replay_dir_number         number
   ,replay_type               varchar2(10)
   ,divergence_details_status varchar2(40)
   ,sqlset_owner              varchar2(128)
   ,sqlset_name               varchar2(128)
   ,sqlset_cap_interval       number
   ,filter_set_name           varchar2(128)
   ,schedule_name             varchar2(128)
   ,num_admins                number
   ,divergence_load_status    varchar2(5)
   ,internal_start_time       integer
   ,plsql_mode                integer
   ,connect_time_auto_correct integer
   ,rac_mode                  integer
   ,flags                     integer
   ,constraint WRR$_REPLAYS_PK primary key (id)
  ) tablespace SYSAUX';

  execute immediate
  'insert into wrr$_replays    -- NULLs for the new columns
  select id, name,dbid, dbname, dbversion, directory, dir_path, capture_id,
         status, prepare_time, start_time, end_time, num_clients,
         num_clients_done, default_action, synchronization,
         connect_time_scale, think_time_scale, think_time_auto_correct,
         scale_up_multiplier, awr_dbid, awr_begin_snap, awr_end_snap,
         awr_exported, error_code, error_msg, comments, preprocessing_id,
         replay_dir_number, replay_type, divergence_details_status,
         sqlset_owner, sqlset_name, sqlset_cap_interval, filter_set_name,
         schedule_name, num_admins, divergence_load_status,
         internal_start_time, NULL, NULL, rac_mode, NULL
  from wrr$_replays_tmp';
  commit;

  execute immediate 'drop table wrr$_replays_tmp purge';
end;
/

begin
  -- wrr$_replay_scn_order, tail of the table definition
  -- 12.1.0.2  our old patch     MAIN
  -- --------  -------------  ---------------
  --                          schedule_cap_id - part of the new PK
  --           call_elapsed   call_elapsed
  --           call_type      call_type

  if wrr_exists('wrr$_replay_scn_order','schedule_cap_id') then return; end if;

  -- the table has to be re-created
  execute immediate 'drop table wrr$_replay_scn_order purge';
end;
/

begin
  -- wrr$_replay_call_info
  -- 12.1.0.2       our old patch                 MAIN
  -- -------------  ----------------------------  -----------------------------
  -- doesn't exist  called: wrr$_replay_call_scn  called: wrr$_replay_call_info
  --                file_id                       file_id
  --                call_ctr                      call_ctr
  --                call_scn                      type
  --                                              value

  if wrr_exists('wrr$_replay_call_scn', null) then
    -- the table has to be replaced with the new one
    execute immediate 'drop table WRR$_REPLAY_CALL_SCN purge';
  end if;
end;
/

begin
  -- wrr$_workload_ex_objects
  -- 12.1.0.2       our old patch      MAIN
  -- -------------  -----------------  --------------
  -- doesn't exist  exists without PK  exists with PK

  if not wrr_exists('wrr$_workload_ex_objects', null) then return; end if;

  -- the easiest way is to re-create the table
  execute immediate 'drop table wrr$_workload_ex_objects purge';
end;
/

begin
  -- wrr$_replay_clients
  -- 12.1.0.2       our old patch  MAIN
  -- -------------  -------------  ---------------
  -- doesn't exist  wrc_id         wrc_id
  --                               schedule_cap_id
  --                inst_id        inst_id

  if not wrr_exists('wrr$_replay_clients', null) or
         wrr_exists('wrr$_replay_clients', 'schedule_cap_id') then
    return;
  end if;

  -- the table has to be re-created
  execute immediate 'drop table wrr$_replay_clients purge';
end;
/

begin
  -- wrr$_replay_tracked_commits, tail of the definition
  -- 12.1.0.2       our old patch      MAIN
  -- -------------  -----------------  ---------------------
  -- doesn't exist  commit_time        cap_commit_time
  --                commit_time_delta  cap_commit_time_delta
  --                                   rep_commit_time
  --                                   rep_commit_time_delta

  if not wrr_exists('wrr$_replay_tracked_commits', null) or
         wrr_exists('wrr$_replay_tracked_commits', 'cap_commit_time') then
    return;
  end if;

  -- the table has to be re-created
  execute immediate 'drop table wrr$_replay_tracked_commits purge';
end;
/

drop function wrr_exists;

-- END bug 22713655

-- BEGIN bug 24745792
BEGIN
  -- all upgrade scripts need to support rerun. So we need to catch the
  -- exception if PK already exists
  EXECUTE IMMEDIATE 'ALTER TABLE wrr$_replay_call_filter ' || 
  ' ADD CONSTRAINT wrr$_replay_call_filter_pk primary key ' || 
  ' (file_id, call_counter_begin, call_counter_end)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -02260 THEN 
      NULL; 
    ELSE 
      RAISE; 
    END IF;
END;
/
-- END bug 24745792
