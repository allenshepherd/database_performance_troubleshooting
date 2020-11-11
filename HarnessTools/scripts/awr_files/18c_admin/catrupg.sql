Rem
Rem $Header: rdbms/admin/catrupg.sql /main/15 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catrupg.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrupg.sql - Catalog Rolling UPGrade views
Rem
Rem    DESCRIPTION
Rem      Rolling upgrade views
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catrupg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catrupg.sql
Rem SQL_PHASE: CATRUPG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    tchorma     06/07/17 - bug 26234638 - remove unneccesary grant to SYS
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dvoss       12/27/13 - fix header
Rem    sslim       08/30/13 - Bug 17389434: Report FarSync role
Rem    sslim       08/13/13 - Bug 17264010: Do not validate version
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    sslim       11/05/12 - Bug 14582062: update statistics table
Rem    sslim       10/11/12 - Bug 14582187: Rollback support and UI changes
Rem    sslim       07/27/12 - Bug 13088334: remove CONFIGURING engine state
Rem    sslim       05/31/12 - Add RAC column to DBA_ROLLING_DATABASES
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sslim       03/23/12 - Remove view info unusable by the user
Rem    sslim       09/28/11 - add synonyms for dba views
Rem    sslim       09/01/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace view dba_rolling_databases
as
  select d.rdbid, d.dbid, d.dbun,
         decode (bitand(d.attributes, 16777456), 
           16,      'PRIMARY', 
           32,      'PHYSICAL', 
           64,      'LOGICAL', 
           128,     'SNAPSHOT',
      16777216,     'FAR SYNC',
                    'UNKNOWN') role,
         decode (bitand(d.attributes, 3840),
           256,     'MOUNTED',
           512,     'OPEN READ WRITE',
          1024,     'OPEN READ ONLY',
          2048,     'OPEN UPGRADE',
                    'UNKNOWN') open_mode,
         decode (bitand(d.attributes, 1), 
           0, 'NO', 'YES') participant, 
         d.version, 
         decode (d.engine_status, 
           3,       'NOT APPLICABLE', 
           2,       'RUNNING',
           1,       'STOPPED', 
                    'UNKNOWN') engine_status,
         decode (bitand(d.attributes, 8),
           8,       'YES',
                    'NO') rac, 
         decode (bitand(d.attributes, 1572864), 
           1572864, 'FINISHED',
           524288,  'STARTED',
           0,       'NOT STARTED', 
                    'UNKNOWN') update_progress, 
         decode (d.prod_rscn, 0, NULL, d.prod_rscn) prod_rscn,
         decode (d.prod_rid, 0, NULL, d.prod_rid) prod_rid,
         decode (d.prod_scn, 0, NULL, d.prod_scn) prod_scn,
         decode (d.redo_source, 0, NULL, d2.dbun) redo_source,
         decode (d.cons_rscn, 0, NULL, d.cons_rscn) cons_rscn,
         decode (d.cons_rid, 0, NULL, d.cons_rid) cons_rid,
         decode (d.cons_scn, 0, NULL, d.cons_scn) cons_scn,
         d.update_time
       from system.rolling$databases d, system.rolling$databases d2,
            system.rolling$status s 
     where d.revision = d2.revision
       and d.revision = s.revision
       and (((d.redo_source > 0) and 
             (d.redo_source = d2.rdbid)) or
            ((d.redo_source = 0) and
             (d.rdbid = d2.rdbid)))
   order by d.revision, d.rdbid
/
create or replace public synonym dba_rolling_databases 
  for dba_rolling_databases
/
grant select on dba_rolling_databases to select_catalog_role
/
comment on table dba_rolling_databases is 
'List of all databases eligible for configuration with rolling upgrade'
/
comment on column dba_rolling_databases.rdbid is 
'Rolling upgrade database identifier'
/
comment on column dba_rolling_databases.dbid is 
'Oracle database identifier'
/
comment on column dba_rolling_databases.dbun is 
'Database unique name'
/
comment on column dba_rolling_databases.role is 
'Database role'
/
comment on column dba_rolling_databases.open_mode is 
'Open mode information'
/
comment on column dba_rolling_databases.participant is 
'Is the database participating in the rolling upgrade - YES or NO'
/
comment on column dba_rolling_databases.version is 
'RDBMS version number'
/
comment on column dba_rolling_databases.engine_status is 
'Running status of the MRP-recovery or LSP-apply process'
/
comment on column dba_rolling_databases.update_progress is 
'Update progress of the changes from the future primary'
/
comment on column dba_rolling_databases.prod_rscn is 
'Resetlogs SCN at which redo is currently being produced'
/
comment on column dba_rolling_databases.prod_rid is 
'Resetlogs ID at which redo is currently being produced'
/
comment on column dba_rolling_databases.prod_scn is 
'Last SCN at which redo was produced'
/
comment on column dba_rolling_databases.cons_rscn is 
'Resetlogs SCN at which redo is currently being consumed'
/
comment on column dba_rolling_databases.cons_rid is 
'Resetlogs ID at which redo is currently being consumed'
/
comment on column dba_rolling_databases.cons_scn is 
'Last SCN at which redo was consumed'
/
comment on column dba_rolling_databases.redo_source is 
'Database unique name of the producer of redo being consumed'
/
comment on column dba_rolling_databases.update_time is 
'Time of the last record update'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_DATABASES','CDB_ROLLING_DATABASES');
grant select on SYS.CDB_rolling_databases to select_catalog_role
/
create or replace public synonym CDB_rolling_databases for SYS.CDB_rolling_databases
/

create or replace view dba_rolling_events
as
  select eventid, event_time, 
         decode(type, 1, 'INFO', 2, 'NOTICE', 3, 'WARNING', 
                      4, 'ERROR', 5, 'DEBUG', 'NONE') type, 
         message, status, instid, revision 
       from system.rolling$events 
   order by eventid
/
create or replace public synonym dba_rolling_events
  for dba_rolling_events
/
grant select on dba_rolling_events to select_catalog_role
/
comment on table dba_rolling_events is 
'List of all events reported from DBMS_ROLLING PL/SQL package'
/
comment on column dba_rolling_events.eventid is 
'Event identifier which identifies event order'
/
comment on column dba_rolling_events.event_time is 
'Time associated with the event'
/
comment on column dba_rolling_events.status is 
'Status code associated with an event'
/
comment on column dba_rolling_events.type is 
'Type of event: INFO, NOTICE, WARNING, or ERROR'
/
comment on column dba_rolling_events.message is 
'Text describing the event details'
/
comment on column dba_rolling_events.instid is 
'Instruction ID associated with an event'
/
comment on column dba_rolling_events.revision is 
'Plan revision number associated with an event'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_EVENTS','CDB_ROLLING_EVENTS');
grant select on SYS.CDB_rolling_events to select_catalog_role
/
create or replace public synonym CDB_rolling_events for SYS.CDB_rolling_events
/

create or replace view dba_rolling_parameters
as
  select d.dbun scope,  
         decode(p.type, 4, 'RUNTIME', 5, 'USER', 'UNKNOWN') type, 
         p.name, p.descrip description, 
         p.curval, p.lstval, p.defval, p.minval, p.maxval
       from system.rolling$parameters p left join 
            (select * from system.rolling$databases 
               where revision = 
                 (select revision from system.rolling$status)) d
            on p.scope = d.rdbid 
     where type = 4 or type = 5 
   order by type, scope nulls first, name
/
create or replace public synonym dba_rolling_parameters
  for dba_rolling_parameters
/
grant select on dba_rolling_parameters to select_catalog_role
/
comment on table dba_rolling_parameters is 
'List of parameters to configure rolling upgrade'
/
comment on column dba_rolling_parameters.scope is
'Database unique name associated with a parameter'
/
comment on column dba_rolling_parameters.type is
'Type of parameter'
/
comment on column dba_rolling_parameters.name is
'Name of the parameter'
/
comment on column dba_rolling_parameters.description is
'Description of the parameter'
/
comment on column dba_rolling_parameters.curval is
'Current value of the parameter'
/
comment on column dba_rolling_parameters.lstval is
'Prior value of the parameter'
/
comment on column dba_rolling_parameters.defval is
'Default value of the parameter'
/
comment on column dba_rolling_parameters.minval is
'Minimum value of the parameter'
/
comment on column dba_rolling_parameters.maxval is
'Maximum value of the parameter'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_PARAMETERS','CDB_ROLLING_PARAMETERS');
grant select on SYS.CDB_rolling_parameters to select_catalog_role
/
create or replace public synonym CDB_rolling_parameters for SYS.CDB_rolling_parameters
/

create or replace view dba_rolling_plan
as
  select p.revision, p.batchid, p.instid, d.dbun source, d2.dbun target,
         decode(p.phase, 1, 'NONE', 2, 'INIT', 3, 'BUILD PENDING', 
                4, 'BUILD', 5, 'START PENDING', 6, 'START', 
                7, 'SWITCH PENDING', 8, 'SWITCH', 9, 'FINISH PENDING', 
                10, 'FINISH', 11, 'ROLLBACK', 12, 'DONE', 13, 'DESTROY', 
                'UNKNOWN') phase, 
         decode(p.status, 1, 'PENDING', 2, 'SUCCESS', 3, 'ERROR', 
                          4, 'WARNING', 'UNKNOWN') status,
         decode(p.progress, 1, 'PENDING', 2, 'REQUESTING', 3, 'EXECUTING', 
                            4, 'REPLYING', 5, 'POSTING', 6, 'COMPLETE', 
                            7, 'ABORTING', 'UNKNOWN') progress, 
         p.description, p.exec_status, p.exec_info, p.exec_time, p.finish_time
       from system.rolling$plan p, system.rolling$databases d, 
            system.rolling$databases d2 
      where p.source = d.rdbid and p.target = d2.rdbid 
        and p.revision = d.revision and p.revision = d2.revision 
    order by p.revision, p.instid
/
create or replace public synonym dba_rolling_plan
  for dba_rolling_plan
/
grant select on dba_rolling_plan to select_catalog_role
/
comment on table dba_rolling_plan is 
'List of instructions which constitutes the upgrade plan'
/
comment on column dba_rolling_plan.revision is
'Plan revision number associated with an instruction'
/
comment on column dba_rolling_plan.batchid is
'Identifier for a batch of instructions which are requested together'
/
comment on column dba_rolling_plan.instid is
'Identifier for a single instruction'
/
comment on column dba_rolling_plan.source is
'Database unique name where an instruction is initiated'
/
comment on column dba_rolling_plan.target is
'Database unique name where an instruction executes'
/
comment on column dba_rolling_plan.phase is
'Rolling upgrade phase in which an instruction executes'
/
comment on column dba_rolling_plan.status is
'Scheduling status of the instruction'
/
comment on column dba_rolling_plan.progress is
'Execution Progress of the instruction'
/
comment on column dba_rolling_plan.description is
'Description of the instruction'
/
comment on column dba_rolling_plan.exec_status is
'Status code returned from instruction execution'
/
comment on column dba_rolling_plan.exec_info is
'Supplemental information obtained during instruction execution'
/
comment on column dba_rolling_plan.exec_time is
'Time of instruction execution'
/
comment on column dba_rolling_plan.finish_time is
'Time of instruction completion'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_PLAN','CDB_ROLLING_PLAN');
grant select on SYS.CDB_rolling_plan to select_catalog_role
/
create or replace public synonym CDB_rolling_plan for SYS.CDB_rolling_plan
/

create or replace view dba_rolling_statistics
as
  select name, 
         decode(type, 1, valuestr, 
                      2, to_char(valuenum),
                      3, to_char(valuets), 
                      4, to_char(valueint),
                      NULL) value, update_time 
        from system.rolling$statistics
      where bitand(attributes, 1) = 0
   order by rdbid, statid
/
create or replace public synonym dba_rolling_statistics
  for dba_rolling_statistics
/
grant select on dba_rolling_statistics to select_catalog_role
/
comment on table dba_rolling_statistics is 
'List of rolling upgrade statistics'
/
comment on column dba_rolling_statistics.name is
'Name of the statistic'
/
comment on column dba_rolling_statistics.value is
'Value of the statistic'
/
comment on column dba_rolling_statistics.update_time is
'Time of last update'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_STATISTICS','CDB_ROLLING_STATISTICS');
grant select on SYS.CDB_rolling_statistics to select_catalog_role
/
create or replace public synonym CDB_rolling_statistics for SYS.CDB_rolling_statistics
/

create or replace view dba_rolling_status 
as
  select s.revision, 
         decode(s.status, 0, 'NO PLAN', 1, 'INITIALIZING', 2, 'CONFIGURING', 
                          3, 'BUILDING', 4, 'RUNNING', 5, 'READY', 
                          6, 'ERROR', 'UNKNOWN') status, 
         decode(s.phase, 1, 'NONE', 2, 'INIT', 3, 'BUILD PENDING',
                         4, 'BUILD', 5, 'START PENDING', 6, 'START', 
                         7, 'SWITCH PENDING', 8, 'SWITCH', 
                         9, 'FINISH PENDING', 10, 'FINISH', 11, 'ROLLBACK', 
                         12, 'DONE', 13, 'DESTROY', 'UNKNOWN') phase, 
         (select greatest(
            (select nvl(min(instid), 0) from system.rolling$plan 
               where revision = (select revision from system.rolling$status)
                 and status != 2 and status != 4 
                 and batchid = (select min(batchid) from system.rolling$plan
                                  where revision = (select revision 
                                                    from system.rolling$status)
                                    and status != 2 and status != 4)) ,
            (select nvl(max(instid)+1, 0) from system.rolling$plan
               where revision = (select revision from system.rolling$status)
                 and not exists (select 1 from system.rolling$plan
                                  where revision = (select revision 
                                                    from system.rolling$status)
                                    and status != 2 and status != 4)))
           from sys.dual)  next_instruction,
         (select count(instid) from system.rolling$plan p
            where p.revision = (select revision from system.rolling$status)
              and (p.status = 1 or p.status = 3)) remaining_instructions,
         s.instance coordinator_instance, s.pid coordinator_pid, 
         d.dbun original_primary, d2.dbun future_primary, 
         s.dbtotal total_databases, s.dbactive participating_databases, 
         s.init_time, s.build_time, s.start_time, s.switch_time, s.finish_time
       from system.rolling$status s, system.rolling$databases d,
            system.rolling$databases d2
     where s.oprimary = d.rdbid and s.fprimary = d2.rdbid
       and s.revision = d.revision and s.revision = d2.revision
/
create or replace public synonym dba_rolling_status
  for dba_rolling_status
/
grant select on dba_rolling_status to select_catalog_role
/
comment on table dba_rolling_status is 
'Overall status of the rolling upgrade'
/
comment on column dba_rolling_status.revision is
'Revision number of the current upgrade plan'
/
comment on column dba_rolling_status.status is
'Readiness of the facility to begin or resume a rolling upgrade'
/
comment on column dba_rolling_status.phase is
'Current phase of the rolling upgrade'
/
comment on column dba_rolling_status.next_instruction is
'Instruction ID of the next pending instruction'
/
comment on column dba_rolling_status.remaining_instructions is
'Number of remaining instructions to execute in the upgrade plan'
/
comment on column dba_rolling_status.coordinator_instance is
'Instance number from which the rolling upgrade is being coordinated'
/
comment on column dba_rolling_status.coordinator_pid is
'Process PID in which the rolling upgrade is being coordinated'
/
comment on column dba_rolling_status.original_primary is
'Database unique name of the original primary'
/
comment on column dba_rolling_status.future_primary is
'Database unique name of the future primary'
/
comment on column dba_rolling_status.total_databases is
'Number of total databases eligible to participate in the rolling upgrade'
/
comment on column dba_rolling_status.participating_databases is
'Number of databases configured to participate in the rolling upgrade'
/
comment on column dba_rolling_status.init_time is
'Time of the last call to DBMS_ROLLING.INIT_PLAN'
/
comment on column dba_rolling_status.build_time is
'Time of the last call to DBMS_ROLLING.BUILD'
/
comment on column dba_rolling_status.start_time is
'Time of the last call to DBMS_ROLLING.START_UPGRADE'
/
comment on column dba_rolling_status.switch_time is
'Time of the last call to DBMS_ROLLING.SWITCHOVER'
/
comment on column dba_rolling_status.finish_time is
'Time of the last call to DBMS_ROLLING.FINISH'
/



execute CDBView.create_cdbview(false,'SYS','DBA_ROLLING_STATUS','CDB_ROLLING_STATUS');
grant select on SYS.CDB_rolling_status to select_catalog_role
/
create or replace public synonym CDB_rolling_status for SYS.CDB_rolling_status
/

Rem Populate NOEXP$ to ensure rolling upgrade metadata is not exported
delete from sys.noexp$ where name like 'ROLLING$%';
delete from sys.noexp$ where name = 'ROLLING_EVENT_SEQ$';
insert into sys.noexp$
  select u.name, o.name, o.type#
      from sys.obj$ o, sys.user$ u
    where o.type# = 2
      and o.owner# = u.user# 
      and u.name = 'SYSTEM' 
      and (o.name like 'ROLLING$%' or o.name = 'ROLLING_EVENT_SEQ$');
commit;

@?/rdbms/admin/sqlsessend.sql
