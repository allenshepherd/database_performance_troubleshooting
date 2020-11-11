Rem
Rem $Header: rdbms/admin/cdrac.sql /main/17 2017/03/31 10:07:56 sroesch Exp $
Rem
Rem cdrac.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdrac.sql - Catalog DRAC.bsq views
Rem
Rem    DESCRIPTION
Rem      service objects
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in drac.bsq. 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdrac.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdrac.sql
Rem SQL_PHASE: CDRAC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sroesch     03/13/17 - Bug 25678327: Add auto-mode for failover_type
Rem    sroesch     04/07/15 - Bug 20830228: Add pq_svc to dba_services
Rem    sroesch     02/02/14 - Bug 20418865: Change failover restore parameter
Rem                                         from basic to level1
Rem    sroesch     01/19/14 - 20319989: Make draining timeout a svc attribute
Rem    sroesch     07/16/14 - Add failover_restore, stop_option to dba_services
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    skyathap    09/13/11 - gsm_flags column to dba_services view
Rem    sroesch     07/15/11 - change service$ column to sql_translation_profile
Rem    sroesch     05/04/11 - max_lag_time column to dba_services view
Rem    sroesch     01/03/11 - add new service parameters
Rem    pyam        11/22/10 - pdb as a service attribute
Rem    achoi       09/22/09 - edition as a service attribute
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


Rem Add workgroup services views
create or replace view DBA_SERVICES
as select SERVICE_ID, NAME, NAME_HASH, NETWORK_NAME,
          CREATION_DATE, CREATION_DATE_HASH,
          FAILOVER_METHOD, FAILOVER_TYPE, FAILOVER_RETRIES, FAILOVER_DELAY,
          MIN_CARDINALITY, MAX_CARDINALITY,
          decode(GOAL, 0, 'NONE', 1, 'SERVICE_TIME', 2, 'THROUGHPUT', NULL)
            GOAL,
          decode(bitand(FLAGS, 2), 2, 'Y', 'N') DTP,
          decode(bitand(FLAGS, 1), 1, 'YES', 0, 'NO') ENABLED,
          decode(bitand(NVL(FLAGS,0), 4), 4, 'YES',
                                   0, 'NO', 'NO') AQ_HA_NOTIFICATIONS,
          decode(bitand(NVL(FLAGS,0), 8), 8, 'LONG', 0, 'SHORT', 'SHORT') CLB_GOAL,
          EDITION,
          decode(bitand(NVL(FLAGS,0), 32), 32, 'YES', 0, 'NO', 'NO') COMMIT_OUTCOME,
          RETENTION_TIMEOUT,
          REPLAY_INITIATION_TIMEOUT,
          SESSION_STATE_CONSISTENCY,
          decode(bitand(NVL(FLAGS,0), 64), 64, 'YES', 0, 'NO', 'NO') GLOBAL_SERVICE,
          PDB,
          SQL_TRANSLATION_PROFILE,
          MAX_LAG_TIME,
          GSM_FLAGS,
          PQ_SVC,
          decode(STOP_OPTION, 0, 'NONE', 1, 'IMMEDIATE', 2, 'TRANSACTIONAL', NULL)
            STOP_OPTION,
          decode(FAILOVER_RESTORE, 0, 'NONE', 1, 'LEVEL1', 2, 'AUTO', NULL) FAILOVER_RESTORE,
          drain_timeout
   from service$
where DELETION_DATE is null
/

comment on column DBA_SERVICES.SERVICE_ID is
'The unique ID for this service'
/

comment on column DBA_SERVICES.NAME is
'The short name for the service'
/

comment on column DBA_SERVICES.NAME_HASH is
'The hash of the short name for the service'
/

comment on column DBA_SERVICES.NETWORK_NAME is
'The network name used to connect to the service'
/

comment on column DBA_SERVICES.CREATION_DATE is
'The date the service was created'
/

comment on column DBA_SERVICES.CREATION_DATE_HASH is
'The hash of the creation date'
/

comment on column DBA_SERVICES.FAILOVER_METHOD is
'The failover method (BASIC or NONE) for the service'
/

comment on column DBA_SERVICES.FAILOVER_TYPE is
'The failover type (SESSION or SELECT) for the service'
/

comment on column DBA_SERVICES.FAILOVER_RETRIES is
'The number of retries when failing over the service'
/

comment on column DBA_SERVICES.FAILOVER_DELAY is
'The delay between retries when failing over the service'
/

comment on column DBA_SERVICES.MIN_CARDINALITY is
'The minimum cardinality of this service to be maintained by director'
/

comment on column DBA_SERVICES.MAX_CARDINALITY is
'The maximum cardinality of this service to be allowed by director'
/

comment on column DBA_SERVICES.ENABLED is
'Indicates whether or not this service will be started/maintained by director'
/

comment on column DBA_SERVICES.AQ_HA_NOTIFICATIONS is
'Indicates whether AQ notifications are sent for HA events'
/

comment on column DBA_SERVICES.GOAL is
'The service workload management goal'
/

comment on column DBA_SERVICES.DTP is
'DTP flag for services'
/

comment on column DBA_SERVICES.CLB_GOAL is
'Connection load balancing goal for services'
/

comment on column DBA_SERVICES.EDITION is
'Initial session edition for services'
/

comment on column DBA_SERVICES.COMMIT_OUTCOME is
'Commit outcome is persisted'
/

comment on column DBA_SERVICES.RETENTION_TIMEOUT is
'How long (in secs) is the commit outcome stored before it is retained'
/

comment on column DBA_SERVICES.REPLAY_INITIATION_TIMEOUT is
'How long (in secs) can transaction be replayed after transaction start '
/

comment on column DBA_SERVICES.SESSION_STATE_CONSISTENCY is
'Type of non-transactional changes during a transaction'
/

comment on column DBA_SERVICES.GLOBAL_SERVICE is
'Service is used for global service management'
/

comment on column DBA_SERVICES.PDB is
'Service is created in a pluggable database'
/

comment on column DBA_SERVICES.SQL_TRANSLATION_PROFILE is
'Name of the SQL translation profile'
/

comment on column DBA_SERVICES.MAX_LAG_TIME is
'Maximum lag time of a global service'
/

comment on column DBA_SERVICES.GSM_FLAGS is
'Flags specific to a global service'
/

comment on column DBA_SERVICES.PQ_SVC is
'Name of associated parallel query rim service'
/

comment on column DBA_SERVICES.STOP_OPTION is
'Stop option for sessions of this service for planned maintenance'
/

comment on column DBA_SERVICES.FAILOVER_RESTORE is
'Shall sessions recover their commonly used session state (like NLS, schema) when they are failed over with TAF'
/

comment on column DBA_SERVICES.DRAIN_TIMEOUT is
'Number of seconds to wait for sessions to be drained'
/

create or replace public synonym DBA_SERVICES
     for DBA_SERVICES
/
grant select on DBA_SERVICES to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_SERVICES','CDB_SERVICES');
grant select on SYS.CDB_SERVICES to select_catalog_role
/
create or replace public synonym CDB_SERVICES for SYS.CDB_SERVICES
/

create or replace view ALL_SERVICES
as select * from dba_services
/
create or replace public synonym ALL_SERVICES
     for ALL_SERVICES
/
grant select on ALL_SERVICES to select_catalog_role
/

commit;

@?/rdbms/admin/sqlsessend.sql
