Rem
Rem $Header: rdbms/admin/catamgt.sql /main/26 2017/01/13 01:25:36 amunnoli Exp $
Rem
Rem catamgt.sql
Rem
Rem Copyright (c) 2007, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catamgt.sql - CAT Audit Management Packages
Rem
Rem    DESCRIPTION
Rem      This will install the DBMS_AUDIT_MGMT package
Rem      and the views exposed by the package.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catamgt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catamgt.sql
Rem SQL_PHASE: CATAMGT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    09/26/16 - Proj 67567: Register audsys.aud$unified for
Rem                           import/export
Rem    aanverma    06/10/16 - Bug 23515378: grant read on audit views
Rem    amunnoli    03/23/15 - Bug 13716158:fga_log$ now also has current_user
Rem    gclaborn    07/02/14 - 18844843: grant flashback on SYS views
Rem    nkgopal     06/19/14 - Lrg 12347520: re-create fga_log$for_export_tbl
Rem                           table
Rem    nkgopal     04/16/14 - Proj 35931: FGA_LOG$ now also has rls$info column
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    nkgopal     07/16/13 - Bug 14168362: Add dbid, pdb guid to
Rem                           DBA_AUDIT_MGMT_LAST_ARCH_TS
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    amunnoli    01/16/13 - Bug 16066652: Add Last archive timestamp,
Rem                           container columns to DBA_AUDIT_MGMT_CLEANUP_JOBS
Rem    nkgopal     06/28/12 - Bug 14029047: Network import failure for FGA_LOG$
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    nkgopal     01/06/12 - Bug 13561170
Rem    vpriyans    10/10/11 - to fix bug 12924577
Rem    nkgopal     09/20/11 - Bug 12936792
Rem    nkgopal     08/19/11 - Bug 12794380: Next Generation to Unified
Rem    nkgopal     05/27/11 - Bug 10406931: Register DAM_CONFIG_PARAM$,
Rem                           DAM_CLEANUP_JOBS$ and DAM_CLEANUP_EVENTS$ with
Rem                           Datapump for export
Rem    nkgopal     04/20/11 - Proj 16526: Add AUDIT_TRAIL_NEXT_GENERATION
Rem                           types/values
Rem    sarchak     04/03/09 - Bug 8406799,retaining existing configuration in
Rem                           DAM_CONFIG_PARAM$
Rem    nkgopal     03/31/09 - Bug 8392745: Add FILE DELETE BATCH SIZE
Rem    nkgopal     10/22/08 - Bug 7427306: Add default Max limits to Files
Rem    nkgopal     04/08/08 - Bug 6954407: DBMS_* views to DBA_* views
Rem                           Create public synonyms to all views
Rem    nkgopal     03/13/08 - Bug 6810355: Add DB DELETE Batch size
Rem    nkgopal     01/11/08 - 
Rem    rahanum     11/02/07 - Merge dbms_audit_mgmt
Rem    nkgopal     06/27/07 - Add comments to views
Rem    ssonawan    06/26/07 - update DBMS_AUDIT_MGMT_CONFIG_PARAMS view def
Rem    nkgopal     06/20/07 - Load DBMS_AUDIT_MGMT package
Rem    nkgopal     06/20/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem The views for external use

Rem Configuration parameters
CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CONFIG_PARAMS
(
   PARAMETER_NAME,
   PARAMETER_VALUE,
   AUDIT_TRAIL
)
AS 
SELECT PARAMETER_NAME,
       (CASE 
            WHEN cfg.PARAM_ID = 22 THEN STRING_VALUE
            WHEN cfg.PARAM_ID = 33 THEN
              decode(NUMBER_VALUE,
                     1, 'QUEUED WRITE MODE',
                     2, 'IMMEDIATE WRITE MODE',
                        'UNKNOWN MODE')
            ELSE
                CASE
                    WHEN NUMBER_VALUE = 0 THEN 'NOT SET'
                    ELSE TO_CHAR(NUMBER_VALUE)
                END
        END),
       decode(cfg.AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
             51, 'UNIFIED AUDIT TRAIL',
                 'UNKNOWN AUDIT TRAIL')
FROM DAM_CONFIG_PARAM$ cfg, DAM_PARAM_TAB$ prm
WHERE prm.PARAMETER# = cfg.PARAM_ID
/
comment on table DBA_AUDIT_MGMT_CONFIG_PARAMS is
'The view displays the currently configured audit trail properties that are defined by the DBMS_AUDIT_MGMT PL/SQL package'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.PARAMETER_NAME is
'Name of the Property'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.PARAMETER_VALUE is
'Value of the Property'
/
comment on column DBA_AUDIT_MGMT_CONFIG_PARAMS.AUDIT_TRAIL is
'Audit Trail(s) for which the property is configured'
/
create or replace public synonym DBA_AUDIT_MGMT_CONFIG_PARAMS for 
DBA_AUDIT_MGMT_CONFIG_PARAMS
/
--Bug 12924577
--Allow audit_admin role to select from dba_audit_mgmt_config_params
--
grant read on DBA_AUDIT_MGMT_CONFIG_PARAMS to AUDIT_ADMIN
/

execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_MGMT_CONFIG_PARAMS','CDB_AUDIT_MGMT_CONFIG_PARAMS');
grant read on SYS.CDB_AUDIT_MGMT_CONFIG_PARAMS to AUDIT_ADMIN
/
create or replace public synonym CDB_AUDIT_MGMT_CONFIG_PARAMS for SYS.CDB_AUDIT_MGMT_CONFIG_PARAMS
/



CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_LAST_ARCH_TS
(
   AUDIT_TRAIL,
   RAC_INSTANCE,
   LAST_ARCHIVE_TS,
   DATABASE_ID,
   CONTAINER_GUID
)
AS
SELECT decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             51, 'UNIFIED AUDIT TRAIL',
                 'UNKNOWN AUDIT TRAIL'),
       RAC_INSTANCE#,
       decode(AUDIT_TRAIL_TYPE#,
              1, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, '0:00'),
              2, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, '0:00'),
              4, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, TZ_OFFSET(sessiontimezone)),
              8, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, TZ_OFFSET(sessiontimezone)),
             51, FROM_TZ(LAST_ARCHIVE_TIMESTAMP, '0:00'),
                 LAST_ARCHIVE_TIMESTAMP),
       DATABASE_ID,
       CONTAINER_GUID
FROM DAM_LAST_ARCH_TS$
/
comment on table DBA_AUDIT_MGMT_LAST_ARCH_TS is
'The Last Archive Timestamps set for the Audit Trail Clean up'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.AUDIT_TRAIL is
'The Audit Trail for which the Last Archive Timestamp applies'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.RAC_INSTANCE is
'The RAC Instance Number for which the Last Archive Timestamp applies. Zero implies ''Not Applicable'''
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.LAST_ARCHIVE_TS is
'The Timestamp of the last audit record or audit file that has been archived'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.DATABASE_ID is
'The Database ID of the audit records, if purging old audit data'
/
comment on column DBA_AUDIT_MGMT_LAST_ARCH_TS.CONTAINER_GUID is
'The Container GUID of the audit records, if purging old audit data'
/
create or replace public synonym DBA_AUDIT_MGMT_LAST_ARCH_TS for 
DBA_AUDIT_MGMT_LAST_ARCH_TS
/

--
--Allow audit_admin role to select from dba_audit_mgmt_last_arch_ts
--

grant read on DBA_AUDIT_MGMT_LAST_ARCH_TS to AUDIT_ADMIN
/

execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_MGMT_LAST_ARCH_TS','CDB_AUDIT_MGMT_LAST_ARCH_TS');
grant read on SYS.CDB_AUDIT_MGMT_LAST_ARCH_TS to AUDIT_ADMIN 
/
create or replace public synonym CDB_AUDIT_MGMT_LAST_ARCH_TS for SYS.CDB_AUDIT_MGMT_LAST_ARCH_TS
/



CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CLEANUP_JOBS
(
   JOB_NAME,
   JOB_STATUS,
   AUDIT_TRAIL,
   JOB_FREQUENCY,
   USE_LAST_ARCHIVE_TIMESTAMP,
   JOB_CONTAINER
)
AS
SELECT JOB_NAME,
       decode(JOB_STATUS,
              0, 'DISABLED',
              1, 'ENABLED',
                 'UNKNOWN'),
       decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
             51, 'UNIFIED AUDIT TRAIL',
                 'UNKNOWN AUDIT TRAIL'),
       JOB_FREQUENCY,
       decode(bitand(job_flags, 1), 1, 'NO', 'YES'),
       decode(bitand(job_flags, 2), 2, 'ALL', 'CURRENT')
FROM DAM_CLEANUP_JOBS$
/
comment on table DBA_AUDIT_MGMT_CLEANUP_JOBS is
'The view displays the currently configured audit trail purge jobs'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_NAME is
'The name of the Audit Trail Purge Job'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_STATUS is
'The current status of the Audit Trail Purge Job'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.AUDIT_TRAIL is
'The Audit Trail for which the Audit Trail Purge Job is configured'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_FREQUENCY is
'The frequency at which the Audit Trail Purge Job runs'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.USE_LAST_ARCHIVE_TIMESTAMP is
'Indicates if cleanup invocation will use Last Archive Timestamp'
/
comment on column DBA_AUDIT_MGMT_CLEANUP_JOBS.JOB_CONTAINER is
'Indicates in which Container cleanup will be performed'
/
create or replace public synonym DBA_AUDIT_MGMT_CLEANUP_JOBS for 
DBA_AUDIT_MGMT_CLEANUP_JOBS
/
--
--Allow audit_admin role to select from dba_audit_mgmt_cleanup_jobs
--
grant read on DBA_AUDIT_MGMT_CLEANUP_JOBS to AUDIT_ADMIN
/

execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_MGMT_CLEANUP_JOBS','CDB_AUDIT_MGMT_CLEANUP_JOBS');
grant read on SYS.CDB_AUDIT_MGMT_CLEANUP_JOBS to AUDIT_ADMIN 
/
create or replace public synonym CDB_AUDIT_MGMT_CLEANUP_JOBS for SYS.CDB_AUDIT_MGMT_CLEANUP_JOBS
/



CREATE OR REPLACE VIEW DBA_AUDIT_MGMT_CLEAN_EVENTS
(
   AUDIT_TRAIL,
   RAC_INSTANCE,
   CLEANUP_TIME,
   DELETE_COUNT,
   WAS_FORCED
)
AS
SELECT decode(AUDIT_TRAIL_TYPE#,
              1, 'STANDARD AUDIT TRAIL',
              2, 'FGA AUDIT TRAIL',
              3, 'STANDARD AND FGA AUDIT TRAIL',
              4, 'OS AUDIT TRAIL',
              8, 'XML AUDIT TRAIL',
             12, 'OS AND XML AUDIT TRAIL',
             15, 'ALL AUDIT TRAILS',
             51, 'UNIFIED AUDIT TRAIL',
                 'UNKNOWN AUDIT TRAIL'),
        RAC_INSTANCE#,
        FROM_TZ(CLEANUP_TIME, '0:00'),
        DELETE_COUNT,
        decode(WAS_FORCED,
               0, 'NO',
               1, 'YES',
               null)
FROM DAM_CLEANUP_EVENTS$
ORDER BY SERIAL#
/
comment on table DBA_AUDIT_MGMT_CLEAN_EVENTS is
'The history of cleanup events'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.AUDIT_TRAIL is
'The Audit Trail that was cleaned at the time of the event'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.RAC_INSTANCE is
'The Instance Number indiccating the RAC Instance that was cleaned up at the time of the event. Zero implies ''Not Applicable'''
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.CLEANUP_TIME is
'The Timestamp in GMT when the cleanup event completed'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.DELETE_COUNT is
'The number of audit records or audit files that were deleted at the time of the event'
/
comment on column DBA_AUDIT_MGMT_CLEAN_EVENTS.WAS_FORCED is
'Indicates whether or not a Forced Cleanup occured. Forced Cleanup bypasses the Last Archive Timestamp set'
/
create or replace public synonym DBA_AUDIT_MGMT_CLEAN_EVENTS for 
DBA_AUDIT_MGMT_CLEAN_EVENTS
/

--
--Allow audit_admin role to select from dba_audit_mgmt_cleanup_events
--

grant read on DBA_AUDIT_MGMT_CLEAN_EVENTS to AUDIT_ADMIN
/

execute CDBView.create_cdbview(false,'SYS','DBA_AUDIT_MGMT_CLEAN_EVENTS','CDB_AUDIT_MGMT_CLEAN_EVENTS');
grant read on SYS.CDB_AUDIT_MGMT_CLEAN_EVENTS to AUDIT_ADMIN 
/
create or replace public synonym CDB_AUDIT_MGMT_CLEAN_EVENTS for SYS.CDB_AUDIT_MGMT_CLEAN_EVENTS
/


-- INSERT Properties supported
-- These IDs map to the constants defined in DBMS_AUDIT_MGMT package
-- Truncate the tables before INSERT

CREATE OR REPLACE PROCEDURE INSERT_INTO_DAMPARAMTAB$ 
           (t_parameter                IN  PLS_INTEGER,
            t_parameter_name           IN  VARCHAR2
           )
IS
    m_sql_stmt       VARCHAR2(2000);
BEGIN
    m_sql_stmt       := 'insert into sys.dam_param_tab$ '||
                        'values(:1,:2)';
    EXECUTE IMMEDIATE m_sql_stmt using t_parameter,t_parameter_name;
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00001) THEN  --ignore unique constraint violation
    -- Parameter name changed from CLEANUP TRACE LEVEL to 
    -- AUDIT MANAGEMENT TRACE LEVEL from 11.1.0.7 to 11.2
    IF ( t_parameter = 24 ) THEN
      m_sql_stmt    := 'update dam_param_tab$ set '||
                       'parameter_name=:1 where '||
                       'parameter#=24';
      EXECUTE IMMEDIATE m_sql_stmt using t_parameter_name;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Configuration already exists for '||t_parameter_name);
  ELSE RAISE;
  END IF;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (16, 'AUDIT FILE MAX SIZE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (17, 'AUDIT FILE MAX AGE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (21, 'DEFAULT CLEAN UP INTERVAL') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (22, 'DB AUDIT TABLESPACE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (23, 'DB AUDIT CLEAN BATCH SIZE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (24, 'AUDIT MANAGEMENT TRACE LEVEL') ;
END;
/

-- Parameter 25 is reserved for audit table movement flag. 
-- And must not be inserted in DAM_PARAM_TAB$

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (26, 'OS FILE CLEAN BATCH SIZE') ;
END;
/

BEGIN
  INSERT_INTO_DAMPARAMTAB$ (33, 'AUDIT WRITE MODE') ;
END;
/

CREATE OR REPLACE PROCEDURE INSERT_INTO_DAMCONFIGPARAMS$
           (t_param_id                IN  PLS_INTEGER,
            t_audit_trail_type        IN  PLS_INTEGER,
            t_number_value            IN  PLS_INTEGER ,
            t_string_value            IN  VARCHAR2
           )
IS
    m_sql_stmt         VARCHAR2(2000);
BEGIN
    IF ( t_number_value is  NULL ) THEN
      m_sql_stmt    := 'insert into sys.dam_config_param$ ' || 
                       'values(:1,:2,NULL,:3)';
      EXECUTE IMMEDIATE m_sql_stmt using t_param_id,t_audit_trail_type,
                        t_string_value;
    ELSE
      m_sql_stmt    := 'insert into sys.dam_config_param$ ' ||
                       'values(:1,:2,:3,:4)';
      EXECUTE IMMEDIATE m_sql_stmt using t_param_id,t_audit_trail_type,
                        t_number_value,t_string_value;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00001) THEN  --ignore unique constraint violation
      DBMS_OUTPUT.PUT_LINE('Configuration already exists for param_id : ' ||
                            t_param_id);
  ELSE RAISE;
  END IF;
END;
/

--(DB AUDIT TABLESPACE , AUD$, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(22, 1, NULL, 'SYSAUX') ;
END;
/

--(DB AUDIT TABLESPACE , FGA_LOG$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(22 , 2, NULL, 'SYSAUX') ;
END;
/

--(DB AUDIT TABLESPACE , UNIFIED AUDIT TRAIL, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(22 , 51, NULL, 'SYSAUX') ;
END;
/

-- Default OS/XML File Max Size and Age
--( AUDIT FILE MAX SIZE, OS Audit Trail, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(16 , 4 , 10000 , NULL) ;
END;
/

--( AUDIT FILE MAX SIZE, XML Audit Trail, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(16 , 8 , 10000 , NULL) ;
END;
/

--( AUDIT FILE MAX AGE, OS Audit Trail , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(17 , 4 , 5 , NULL) ;
END;
/

--( AUDIT FILE MAX AGE, XML Audit Trail , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(17 , 8 , 5 , NULL) ;
END;
/

-- Default Delete Batch Size
--( DB AUDIT CLEAN BATCH SIZE, AUD$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(23 , 1 , 10000 , NULL) ;
END;
/

--( DB AUDIT CLEAN BATCH SIZE, FGA_LOG$ , <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(23 , 2 , 10000 , NULL) ;
END;
/

-- Parameter 25 is reserved for audit table movement flag. 
-- And must not be inserted in DAM_PARAM_TAB$

--(OS FILE CLEAN BATCH SIZE,OS AUDIT TRAIL,<NUMBER_VALUE>,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$( 26 , 4 , 1000 , NULL );
END;
/

--(OS FILE CLEAN BATCH SIZE,XML AUDIT TRAIL,<NUMBER_VALUE>,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$( 26 , 8 , 1000 , NULL );
END;
/

--(UNIFIED AUDIT TRAIL WRITE MODE,UNIFIED AUDIT TRAIL,
--                <NUMBER_VALUE>,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(33, 51 , 1 , NULL );
END;
/

--(FILE MAX SIZE, UNIFIED AUDIT TRAIL, <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(16 , 51 , 10000 , NULL) ;
END;
/

--( AUDIT FILE MAX AGE, UNIFIED AUDIT TRAIL, 
--                <NUMBER_VALUE> ,<STRING_VALUE> )
BEGIN
  INSERT_INTO_DAMCONFIGPARAMS$(17 , 51 , 5 , NULL) ;
END;
/

DROP PROCEDURE INSERT_INTO_DAMPARAMTAB$
/
DROP PROCEDURE INSERT_INTO_DAMCONFIGPARAMS$
/

COMMIT
/

Rem Regsiter the following tables for Export with Datapump (sys.impcalloutreg$)
Rem
Rem First make sure SYSTEM.AUD$ is not exported (when OLS installed)
Rem Make an entry to SYS.NOEXP$
delete from sys.noexp$ where name = 'AUD$' and owner = 'SYSTEM';
insert into sys.noexp$ (owner, name, obj_type) values
('SYSTEM', 'AUD$', 2);
commit;

Rem
Rem Bug 14029047: 
Rem FGA_LOG$ will not be imported via Network Import because of its LONG column
Rem So, register a view without Long column
Rem 
create or replace view fga_log$for_export (
     sessionid, timestamp#, dbuid, osuid, oshst, clientid, extid, 
     obj$schema, obj$name, policyname, scn, sqltext, lsqltext, sqlbind,
     comment$text, 
     stmt_type, ntimestamp#, proxy$sid, user$guid, instance#, process#,
     xid, auditid, statement, entryid, dbid, lsqlbind, obj$edition, rls$info,
     current_user)
as
select
     sessionid, timestamp#, dbuid, osuid, oshst, clientid, extid, 
     obj$schema, obj$name, policyname, scn, sqltext, lsqltext, sqlbind,
     comment$text, /* No PLHOL column */
     stmt_type, ntimestamp#, proxy$sid, user$guid, instance#, process#,
     xid, auditid, statement, entryid, dbid, lsqlbind, obj$edition, rls$info,
     current_user
from sys.fga_log$
/
grant select on fga_log$for_export to select_catalog_role
/
grant flashback on fga_log$for_export to select_catalog_role
/
drop table fga_log$for_export_tbl
/
Rem Lrg 12347520: Re-create based on new fga_log$for_export columns
create table fga_log$for_export_tbl as select * from fga_log$for_export
where 0 = 1 /* just a table with no rows, required only for meta-data */
/
grant select on fga_log$for_export_tbl to select_catalog_role
/
Rem
Rem Also create a view to store current audit table tablespaces to help
Rem movement on the target database
Rem
create or replace view audtab$tbs$for_export (owner, name, ts_name)
as
select owner, table_name, tablespace_name from dba_tables
where owner = 'SYS' and (table_name = 'AUD$' or table_name = 'FGA_LOG$')
/
grant select on audtab$tbs$for_export to select_catalog_role
/
grant flashback on audtab$tbs$for_export to select_catalog_role
/
drop table audtab$tbs$for_export_tbl
/
create table audtab$tbs$for_export_tbl as select * from audtab$tbs$for_export
where 0 = 1
/
grant select on audtab$tbs$for_export_tbl to select_catalog_role
/

Rem Next Delete existing entries, if any
delete from sys.impcalloutreg$ where tag = 'AUDIT_TRAILS';

Rem
Rem Need to know Audit Trail Configuration first 
Rem
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 1, 0, 'SYS', 'DAM_CONFIG_PARAM$', 
  2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Also, send tablespace names
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 2, 0, 'SYS', 
 'AUDTAB$TBS$FOR_EXPORT', 4 /*view*/,
 'Database Audit Trails and their configuration');

Rem Now, Register both possible locations for AUD$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 3, 0, 'SYS', 'AUD$', 2 /*table*/,
 'Database Audit Trails and their configuration');
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 3, 0, 'SYSTEM', 'AUD$', 
  2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register FGA_LOG$ for 11.2.0.3 support
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 4, 8, 'SYS', 'FGA_LOG$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register FGA_LOG$FOR_EXPORT
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 5, 1, 'SYS', 'FGA_LOG$FOR_EXPORT', 
 4 /*view*/,
 'Database Audit Trails and their configuration');

Rem Next, register DAM_CLEANUP_JOBS$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 6, 0, 'SYS', 'DAM_CLEANUP_JOBS$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Next, register DAM_CLEANUP_EVENTS$
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 7, 0, 'SYS', 'DAM_CLEANUP_EVENTS$', 
 2 /*table*/,
 'Database Audit Trails and their configuration');

Rem Proj 67567: Register AUDSYS.AUD$UNIFIED table
insert into sys.impcalloutreg$
(package, schema, tag, class, level#, flags, tgt_schema, tgt_object, tgt_type,
 cmnt, beginning_tgt_version)
values
('AMGT$DATAPUMP','SYS', 'AUDIT_TRAILS',  3, 8, 0, 'AUDSYS', 
 'AUD$UNIFIED', 2 /*table*/,
 'Database Audit Trails and their configuration', '12.02.00.02.00');

commit;

Rem *************************************************************************

@?/rdbms/admin/sqlsessend.sql
