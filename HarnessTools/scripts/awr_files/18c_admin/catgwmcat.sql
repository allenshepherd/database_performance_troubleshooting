Rem
Rem $Header: rdbms/admin/catgwmcat.sql /main/110 2017/09/20 12:33:26 nbenadja Exp $
Rem
Rem catgwmcat.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catgwmcat.sql - Catalog script for GSM on the catalog database
Rem
Rem    DESCRIPTION
Rem      Installation/upgrade script for GSM components on the cloud
Rem      catalog database.
Rem
Rem      Run the script like this:
Rem
Rem         catgwmcat.sql
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catgwmcat.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catgwmcat.sql
Rem SQL_PHASE: CATGWMCAT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpend.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    itaranov    08/28/17 - v$listener_networks grant
Rem    dcolello    08/23/17 - bug 26513341: add dbid to container_database
Rem    dmaniyan    08/04/17 - Bug 26546365: Add max_chunk_num to table_family
Rem    dmaniyan    06/27/17 - 25443435: Add new column - consistent
Rem    alestrel    06/12/17 - Bug 25992935. Replacing dbms_isched for
Rem                           dbms_isched_agent
Rem    nbenadja    05/05/17 - Fix bug#22145819: Add ddl_intcode for OGG.
Rem    lenovak     05/04/17 - Bug 25989904: grant drop index
Rem    saratho     04/12/17 - adding column database_flags in cloud table
Rem    sdball      03/31/17 - Add failover_restore to service
Rem    dmaniyan    03/22/17 - Bug 25476616:Add child_obj# column to TS_SET_TABLE
Rem    sdball      02/22/17 - Updated for PDB support
Rem    zzeng       01/12/17 - Fix SHARD_NAME for LOCAL_CHUNKS
Rem    sdball      11/02/16 - Update schema to support PDBs
Rem    arjusing    10/03/16 - Bug 23260076: grant select on sha_databases to
Rem                           gds_catalog_select
Rem    arjusing    09/15/16 - Bug 20878412: grant inherit any privileges to
Rem                           gsmadmin_internal
Rem    sdball      08/19/16 - Bug 24319952: grant exempt access to
Rem                           gsmadmin_internal
Rem    vidgovin    08/12/16 - XbranchMerge vidgovin_incrdep2 from
Rem                           st_rdbms_12.2.0.1.0
Rem    vidgovin    08/08/16 - Bug 24428345 - Add orig_ddl_text, ddl_flag to
Rem                           ddl_requests table
Rem    dmaniyan    08/08/16 - Bug 21535006: Grant gds_catalog_select to gsmuser
Rem    sdball      08/05/16 - LRG 19633236: remove constraint in cloud
Rem    itaranov    08/05/16 - XbranchMerge itaranov_bug-24328811 from
Rem                           st_rdbms_12.2.0.1.0
Rem    dmaniyan    07/20/16 - XbranchMerge dmaniyan_secbugs from main
Rem    dcolello    07/19/16 - XbranchMerge dcolello_shfix21 from main
Rem    itaranov    07/19/16 - bug 23740777: cr_gsm_requests dependency
Rem    dcolello    07/14/16 - allow gsmcatuser to use -agent_port 
Rem                             on create shardcatalog
Rem    dcolello    06/24/16 - bug 22151011: move triggers after body creation
Rem    dmaniyan    06/15/16 - Bug 23505098 : Limit index priv on ddl requests
Rem    dcolello    06/01/16 - fix comments
Rem    lenovak     05/26/16 - remove user$ privilege
Rem    sdball      05/11/16 - new ps_order in partition_set
Rem    sdball      04/28/16 - Bug 23199869 : Fix idempotency issue 
Rem    dmaniyan    04/10/16 - Bug 22485421 : Create all chunks table
Rem    vidgovin    04/06/16 - Bug 21533800
Rem    lenovak     04/05/16 - bugfix 23032790
Rem    sdball      03/09/16 - move ddl_requests to sys for security
Rem    itaranov    03/09/16 - shardspaceid to partitionset
Rem    lenovak     03/03/16 - RAC affinity schema changes
Rem    sdball      02/24/16 - Bug 22368133: remove delete action from
Rem                           cr_gsm_requests
Rem    lenovak     02/22/16 - gdsctloutput for catalog_requests
Rem    dcolello    02/17/16 - bug 22743674: add svcusercredential
Rem    dcolello    02/12/16 - add comment for new gdsctl warning message type
Rem    lenovak     02/08/16 - Bug 22669300 fix
Rem    sdball      02/05/16 - Add profile to gsmcatuser
Rem    lenovak     02/04/16 - add gdsctl messages
Rem    yunkzhan    01/28/16 - Change SHART_TS to create segment immediately
Rem                           to avoid ORA-08176 in flashback queries.
Rem    vidgovin    12/07/15 - Bug 22204627 - Add ddl_requests_pwd
Rem    sdball      12/03/15 - Bug 22288229: create views for opatchauto (and
Rem                           others)
Rem    nbenadja    11/25/15 - grant select on dictionary tables to
Rem                           gsmadmin_internal
Rem    dcolello    11/21/15 - VNCR table change for patching support
Rem    dcolello    11/20/15 - more grants for automatic scheduler setup
Rem    ditalian    11/18/15 - make shardspace_id in shard_ts nullable
Rem    dcolello    11/16/15 - remove old schema object names
Rem    ditalian    11/05/15 - make chunk_number in shard_ts nullable
Rem    dcolello    11/03/15 - bug 22145787: make response_info larger
Rem    dcolello    10/19/15 - object rename for production
Rem    lenovak     10/10/15 - new grants to gsmadmin_internal
Rem    sdball      09/25/15 - Bug 21304186: Revioke inherit privs
Rem    lenovak     09/16/15 - more extra privs to gsmadmin_internal
Rem    lenovak     08/31/15 - extra privs to gsmadmin_internal
Rem    sdball      08/10/15 - Bug 20884124: New grants for gsmadmin_role
Rem    dcolello    07/28/15 - add columns to CLOUD table for new syntax
Rem    itaranov    07/23/15 - 21482492 Localchunks def revisited
Rem    dmaniyan    07/14/15 - Bug 21095569: Drop tablespace set issue
Rem    ditalian    07/13/15 - bug #21338419: grant access to dba_tablespaces
Rem    nbenadja    06/26/15 - Add new a privilege to gsmadmin_internal.
Rem    itaranov    06/16/15 - Fix LOCAL_CHUNKS for OGG support
Rem    lenovak     06/15/15 - grant execute on dbms_utility
Rem    sdball      06/05/15 - Support for long identifiers
Rem    sdball      05/15/15 - New field orig_chunks
Rem    sdball      04/02/15 - ddl_num should default to 0 in database table for
Rem                           upgrade
Rem    sdball      03/31/15 - More updates for 12.2 sharding
Rem    lenovak     03/30/15 - grant dba_constraints to gsmadmin_internal
Rem    jorgrive    03/23/15 - add columns in table database
Rem    sdball      03/10/15 - Add targets to gsm_request
Rem    ditalian    03/09/15 - grant privileges for split
Rem    sdball      03/04/15 - More additions for 12.2 sharding
Rem    dcolello    12/10/14 - create database support
Rem    lenovak     12/10/14 - catalog region
Rem    itaranov    12/09/14 - After-merge chunks fix
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    sdball      10/17/14 - Sharding changes for 12.2
Rem    nbenadja    09/12/14 - Add the ts_set_tables.
Rem    ralekra     09/08/14 - Catalog changes required by OGG
Rem    nbenadja    08/04/14 - Add key_level to the sharkey_columns primary key.
Rem    pyam        05/27/14 - fix table column ordering
Rem    itaranov    06/20/14 - LOCAL_CHUNK related views
Rem    devghosh    04/08/14 - bug17709018: add grant
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    sdball      12/18/13 - Add tables for shard support
Rem    sdball      12/05/13 - Add ddl_requests for sharding
Rem    cechen      08/22/13 - add domains for PKI keys in database and cloud
Rem    sdball      08/15/13 - Add db_type field to database table
Rem    lenovak     07/29/13 - shard support
Rem    lenovak     07/11/13 - grant select from cloud to pooladmins
Rem    sdball      06/12/13 - Remove primary key requirement from gsm_requests
Rem    sdball      05/15/13 - Add data_vers to cloud
Rem    sdball      05/06/13 - Add weights to region
Rem    thbaby      05/06/13 - 16768773: remove creation of CDB_SERVICES
Rem    itaranov    04/24/13 - Grant killing sessions to gsmadmin_internal
Rem    nbenadja    04/22/13 - Add logoff trigger.
Rem    itaranov    03/25/13 - Grant privs to import
Rem    sdball      03/13/13 - Add instance fields and types for admin DBs
Rem    sdball      02/26/13 - Grant select on v_$version
Rem    nbenadja    02/21/13 - grant the use of dbms_server_alert package.
Rem    akruglik    02/05/13 - (bug 16194686) disambiguate reference to
Rem                           gv$active_services in ALTER USER SET
Rem                           CONTAINER_DATA statement
Rem    sdball      01/18/13 - Add versions and database parameters
Rem    sdball      01/11/13 - Grant select on sessions.
Rem    nbenadja    01/10/13 - Extend database table to store threshold values.
Rem    aikumar     11/27/12 - bug-15925294:Change dbms_lock_allocated_v2 back
Rem                           to dbms_lock_allocated
Rem    lenovak     11/07/12 - runtime status flags to the catalog
Rem    rpang       10/11/12 - Use new dbms_network_acl_admin API
Rem    nbenadja    10/11/12 - Add container_data for grants in CDB.
Rem    sdball      08/28/12 - Add ACLs for GSMADMIN_INTERNAL
Rem    sdball      08/03/12 - Add gds_catalog_select role
Rem    nbenadja    07/30/12 - Grant select on gv_$active_services.
Rem    nbenadja    06/23/12 - Fix multiple CDB returned from gv$_database.
Rem    sdball      06/13/12 - Support for number of instances
Rem    nbenadja    06/21/12 - Re-create cdb_services, in case it hasnt been
Rem                           created during an upgrade.
Rem    nbenadja    06/21/12 - Handle CDB databases.
Rem    nbenadja    06/15/12 - Grant select_catalog_role to gsmadmin_internal.
Rem    sdball      06/07/12 - grant gv$instance to gsmadmin_internal
Rem    sdball      06/04/12 - Support for non-unique service name
Rem    sdball      06/04/12 - Defer DBMS_RLS calls to catalog creation because
Rem                           they require EE (Bug 14143065)
Rem    nbenadja    05/09/12 - Hande services in PDBs.
Rem    sdball      05/08/12 - Create verify objects
Rem    sdball      04/16/12 - dbms_lock_allocated is now dbms_lock_allocated_v2
Rem    sdball      03/26/12 - move PLB and SQL to correct installers
Rem    sdball      03/12/12 - Remove packages to corret install location
Rem                           Remove gsm_admin user
Rem                           Grant privs on DBMS_LOCK
Rem    sdball      02/22/12 - grant gsm_change_message only to
Rem                           gsmadmin_internal
Rem    sdball      01/04/12 - Refferential integrity checks
Rem    sdball      12/13/11 - Checking parameters
Rem    sdball      12/05/11 - change pooladmin_role to gsm_pooladmin_role
Rem    sdball      11/29/11 - Autovncr functionality
Rem    sdball      11/09/11 - Add gv_$lock for RAC
Rem    sdball      10/28/11 - gsmadmin_internal needs select on dba_locks
Rem    sdball      10/28/11 - gsmadmin_internal needs CREATE JOB privilege
Rem    sdball      10/25/11 - Add date field to gsm_requests
Rem    sdball      10/19/11 - use v_$ rather than gv_$ tables.
Rem                           add mastergsm field to cloud table
Rem    lenovak     08/22/11 - grant ALTER SYSTEM to gsm_admin_role
Rem    lenovak     07/22/11 - vncr support
Rem    mjstewar    07/21/11 - Change region_sequence
Rem    mjstewar    04/25/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL catgwmcat.log

prompt
prompt
prompt Starting Oracle GSM Catalog DB Installation ...
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

--*****************
-- Create GSM Roles
--*****************

----------------
-- gsmadmin_role
----------------

-- Create role for GSM cloud administrator
CREATE ROLE gsmadmin_role;
GRANT connect to gsmadmin_role;

GRANT execute on gsmadmin_internal.dbms_gsm_common to gsmadmin_role;

-----------------
-- gsm_pooladmin_role
-----------------

-- Create role GSM pool administrator
CREATE ROLE gsm_pooladmin_role;
GRANT connect to gsm_pooladmin_role;

GRANT execute on gsmadmin_internal.dbms_gsm_common to gsm_pooladmin_role;
/

-- Create gds_catalog_select role
CREATE ROLE gds_catalog_select;
GRANT gds_catalog_select to gsmuser_role;  

--*****************
-- Create GSM Users
--*****************

--------------------
-- gsmadmin_internal
--------------------

-- gsmadmin_internal user exists on all databases,
-- but we need to give it some more privileges on the cloud
-- catalog database.

-- So that dbms_gsm_cloudadmin can execute dbms_aqadm.add_subscriber()
grant execute on dbms_aqadm to gsmadmin_internal;

-- So that dbms_gsm_cloudamdin can execute dbms_aq.enqueue()
grant execute on dbms_aq to gsmadmin_internal;

-- So that we can grab locks
grant execute on dbms_lock to gsmadmin_internal;

-- for environment variables
grant execute on dbms_system to gsmadmin_internal;
 
-- So that we can use alerts 
grant execute on sys.dbms_server_alert to gsmadmin_internal;

-- So that we can create VPD policies in dbms_gsm_cloudadmin
grant execute on sys.dbms_rls to gsmadmin_internal;

-- So that dbms_gsm_cloudadmin can execute dbms_aqadm.purge_table()
grant aq_administrator_role to gsmadmin_role;

-- So the VPD routine can select from dba_role_privs
grant select on dba_role_privs to gsmadmin_internal;

-- So that dbms_gsm_utility can get current RDBMS version
grant select on v_$version to gsmadmin_internal;

-- So that LOCAL_CHUNKS had column info
grant select on sys.col$ to gsmadmin_internal with grant option;

-- So that dbms_gsm_cloudadmin can check if spfile is set.
grant select on v_$parameter to gsmadmin_internal;

-- so that we can check for GSM master lock
grant select on sys.dbms_lock_allocated to gsmadmin_internal;

-- so that we can check for GSM master lock
grant select on sys.gv_$lock to gsmadmin_internal;

-- for parameter checking
grant select on sys.dba_tab_columns to gsmadmin_internal;

-- so that we can check for CDB database 
grant select on sys.gv_$database to gsmadmin_internal;

-- so we can check running instances
grant select on sys.gv_$instance to gsmadmin_internal;
grant select on sys.v_$instance to gsmadmin_internal;

-- so we can find and kill service sessions
grant select on sys.gv_$session to gsmadmin_internal;
grant select on sys.v_$session to gsmadmin_internal;

-- so we can access privilege table
grant select any dictionary to gsmadmin_internal;

-- Because we create sequences within the schema
grant create sequence to gsmadmin_internal;

-- Bug 20878412: To enable shard ddl propagation 
grant inherit privileges on user sys to gsmadmin_internal;
grant inherit any privileges to gsmadmin_internal;

-- So that we can assign users to the gsm_pooladmin_role
grant grant any role to gsmadmin_internal;

-- So that we can lock/unlock the gsmcatuser account
grant alter user to gsmadmin_internal;

-- So that gsm will be able to exec alter system register on catalog
grant alter system to gsmadmin_role;

-- for alter session enable shard ddl
grant alter session to gsmadmin_role;

-- So we can set up the scheduler
grant execute on sys.dbms_isched_agent to gsmadmin_internal;

-- So that we can create and update ACLs in dbms_gsm_cloudadmin.setupACLs
grant execute on dbms_network_acl_admin to gsmadmin_internal;
grant select on dba_network_acls to gsmadmin_internal;

-- Grant killing sessions to gsmadmin_internal (for import)
grant alter system to gsmadmin_internal;

-- so that we can crerate jobs
grant create job to gsmadmin_internal;
grant create any credential to gsmadmin_internal;
grant select on dba_credentials to gsmadmin_internal;
grant create external job to gsmadmin_internal;

-- and monitor them
grant select on dba_scheduler_job_run_details to gsmadmin_internal;
grant select on dba_scheduler_external_dests to gsmadmin_internal;

-- For shard user creation.
grant grant any privilege to gsmadmin_internal;

-- For CDB databases
grant select on sys.dba_services to gsmadmin_internal;
grant select on sys.cdb_services to gsmadmin_internal;

grant select on sys.gv_$active_services to gsmadmin_internal;

-- so we can create dblinks for chunk moves

grant create database link to gsmadmin_internal;
grant create any job to gsmadmin_internal;
grant create any table to gsmadmin_internal;
grant select any table to gsmadmin_internal;
grant alter any table to gsmadmin_internal;
grant alter any index to gsmadmin_internal;
grant lock any table to gsmadmin_internal;
grant unlimited tablespace to gsmadmin_internal;
grant create tablespace to gsmadmin_internal;
grant drop tablespace to gsmadmin_internal;
grant DATAPUMP_EXP_FULL_DATABASE to gsmadmin_internal;
grant DATAPUMP_IMP_FULL_DATABASE to gsmadmin_internal;
grant select on dba_constraints to gsmadmin_internal;
grant select on dba_tab_partitions to gsmadmin_internal;
grant select on dba_tab_subpartitions to gsmadmin_internal;
grant select on dba_part_tables to gsmadmin_internal;
grant select on dba_part_indexes to gsmadmin_internal;
grant select on dba_indexes to gsmadmin_internal;
grant select on DBA_IND_PARTITIONS to gsmadmin_internal;
grant select on DBA_IND_SUBPARTITIONS to gsmadmin_internal;
grant alter tablespace to gsmadmin_internal;
grant select on dba_constraints to gsmadmin_internal;
grant select on sys.V_$RESTORE_POINT to GSMADMIN_INTERNAL;
grant drop any index to gsmadmin_internal;
grant read on sys.V_$LISTENER_NETWORK to GSMADMIN_INTERNAL;

-- so we can move data under VPD restrictions
grant exempt access policy to gsmuser;

grant execute on dbms_utility to gsmadmin_internal;
-- SHARDMERGE_TODO: This grant does not work during upgrade
-- ORA-22930: directory does not exist
-- grant read,write on directory DATA_PUMP_DIR to gsmadmin_internal;

-- for remote query execution
grant execute on sys.dbms_gsm_fixed to sysdg;
grant execute on UTL_RAW to gsmadmin_internal;
grant execute on sys.dbms_sys_sql to gsmadmin_internal;
grant alter session to gsmadmin_internal;
grant execute on sys.dbms_pipe to gsmadmin_internal;

-- data objectnumber generation
grant select on sys.obj$ to gsmadmin_internal;
grant execute on sys.dbms_shared_pool to gsmadmin_internal;

-- So that we can create SYS_SHARD_TS for move in user-defined sharding.
grant select on dba_tablespaces to gsmadmin_internal;

--for affinity-based routing
grant select on sys.partcol$ to gsmadmin_internal;
grant select on sys.col$ to gsmadmin_internal;
grant select on sys.tabpart$ to gsmadmin_internal;
grant read on GV_$GCSPFMASTER_INFO to gsmadmin_internal;
grant read on GV_$GWM_RAC_AFFINITY to gsmadmin_internal;

-- for shard view
grant select on v_$dg_broker_config to gsmadmin_internal with grant option;
/

alter session set "_oracle_script"=true;

DECLARE
 isCDB varchar2(3);
 stmt  varchar (1024);
BEGIN
  select distinct CDB into isCDB from gv_$database;
  IF (isCDB = 'YES')
  THEN
     stmt := 'grant set container to gsmadmin_internal container = all';
     execute immediate stmt;
     stmt :=  'grant alter session to gsmadmin_internal container = all';
     execute immediate stmt;
     stmt := 'alter user gsmadmin_internal set container_data = all' ||
              '  for cdb_services container = current';
     execute immediate stmt;
     stmt := 'alter user gsmadmin_internal set container_data = all' ||
              '  for "PUBLIC".gv$active_services container = current';
     execute immediate stmt;
 END IF;

END;
/

-------------
-- gsmcatuser
-------------

-- GSM process connects to GSM cloud catalog database as
-- gsmcatuser.  Password will be changed by GSM when first
-- GSM is added to the cloud.

CREATE USER gsmcatuser identified by gsm
  account lock password expire;
  
DECLARE
  conId   NUMBER := 0;
BEGIN
  begin
    execute immediate
      'select SYS_CONTEXT(''USERENV'', ''CON_ID'') from sys.dual'
      into conId;
  exception
    WHEN OTHERS THEN IF SQLCODE = -2003 THEN conId := 0; ELSE RAISE; END IF;
  end;

  IF conId = 0 THEN
    declare
      already_exists exception;
      pragma exception_init(already_exists,-02379);
    begin
      execute immediate
        'CREATE PROFILE gsm_prof LIMIT FAILED_LOGIN_ATTEMPTS 10000000';
    exception when already_exists then null;
    end;
    execute immediate 'ALTER USER gsmuser PROFILE gsm_prof';
  END IF;
END;
/

GRANT connect to gsmcatuser;

-- So that gsmcatuser can call dbms_aq.dequeue(), dbms_aq.listen()
grant execute on dbms_aq to gsmcatuser;

-- So that gsmcatuser can call dbms_aqadm.add_subscriber()
grant aq_administrator_role to gsmcatuser;

-- revike inherit privs
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 
    'REVOKE INHERIT PRIVILEGES ON USER gsmcatuser FROM public';
exception
  when already_revoked then
    null;
end;
/

-- needed to allow 'create shardcatalog -agent_port ...' to
--  succeed if gsmcatuser is creating the catalog since
--  DBMS_GSM_XDB is invoker's rights
grant inherit privileges on user gsmcatuser to gsmadmin_internal;

ALTER SESSION SET CURRENT_SCHEMA = gsmadmin_internal;

--****************************
-- Create Cloud Catalog Tables
--****************************

CREATE TABLE region (
   name         VARCHAR2(128) NOT NULL,
   num          NUMBER        NOT NULL,
   buddy_region NUMBER        DEFAULT NULL REFERENCES region(num),
   change_state CHAR(1)       DEFAULT NULL,
   weights      VARCHAR(500)  DEFAULT NULL,
   CS_WEIGHT    NUMBER ,      -- region weight for cross-shard ops
   PRIMARY KEY (name),
   CONSTRAINT num_unique UNIQUE (num)
 )
/
show errors

-- region_sequence is used for generating region.num.
-- GSM listener requires that region.num be in the range 0-9
CREATE SEQUENCE region_sequence minvalue 0 maxvalue 9 cache 9 cycle
/
show errors

CREATE TABLE gsm (
   name            VARCHAR2(128)   NOT NULL,
   num             NUMBER          NOT NULL,
   endpoint1       VARCHAR2(512)   NOT NULL,
   endpoint2       VARCHAR2(512)   NOT NULL,
   ons_port_local  NUMBER          NOT NULL,
   ons_port_remote NUMBER          NOT NULL,
   region_num      NUMBER          NOT NULL REFERENCES region(num),
   oracle_home     VARCHAR2(4000),
   hostname        VARCHAR2(256),
   version         VARCHAR2(30)    DEFAULT NULL, --GSM version
   change_state    CHAR(1)         DEFAULT NULL, 
   PRIMARY KEY (name)
 )
/
show errors

CREATE TABLE cloud (
   name               VARCHAR2(128) NOT NULL,
   encryption_key     VARCHAR2(30),
   change_seq#        NUMBER,
   next_db_num        NUMBER,
   mastergsm          VARCHAR2(128) DEFAULT NULL,
   autovncr           NUMBER(1)     DEFAULT 1,       -- boolean (1 TRUE, 0 FALSE)
   max_instances      NUMBER        DEFAULT NULL ,
   private_key        RAW(2000)     DEFAULT NULL,    -- PKI private key
   public_key         RAW(2000)     DEFAULT NULL,    -- PKI public key
   prvk_enc_str       RAW(1000)     DEFAULT NULL,    -- private key sig string 
   data_vers          VARCHAR2(30)  DEFAULT NULL,    -- Last update version
                                                     -- of catalog data
   last_ddl_num       NUMBER        DEFAULT 0,       --last ddl_num
   last_syncddl_num   NUMBER        DEFAULT 0,       --last sync ddl_num
   region_num         NUMBER,                        -- catalog region
   deploy_state       NUMBER        DEFAULT 0,
   objnum_gen         NUMBER        DEFAULT 1000000, -- object number generator
   sharding_type      NUMBER(1)     DEFAULT NULL,    -- 0 - not sharded
                                                     -- 1 - system managed
                                                     -- 2 - user-defined
                                                     -- 3 - composite
   replication_type   NUMBER(1)     DEFAULT NULL,    -- 0 - DataGuard
                                                     -- 1 - GoldenGate
   protection_mode    NUMBER(1)     DEFAULT NULL,    -- 0 - max protection
                                                     -- 1 - max availability 
                                                     -- 2 - max performance
   replication_factor NUMBER        DEFAULT NULL,
   chunk_count        NUMBER        DEFAULT NULL,
   database_flags     CHAR(1)       DEFAULT NULL,    -- 'C' - catalog
                                                     -- 'S' or null - shard
   PRIMARY KEY (name)
 )
/
show errors

CREATE SEQUENCE msg_sequence NOCACHE
/
show errors

CREATE TABLE GDSCTL_MESSAGES(
   session_id      NUMBER   NOT NULL,
   message         VARCHAR2(1024),
   msg_type        NUMBER   default 0,
   -- 0 -regular
   -- 1 -start message
   -- 2 - end message
   -- 3 - warning message
   message_id      NUMBER,
   message_date    DATE default SYSDATE
 )
/
show errors

CREATE SEQUENCE vncr_sequence
/
show errors

CREATE TABLE vncr(
   name            VARCHAR2(512)   NOT NULL,
   group_id        VARCHAR2(128),
   hostid          NUMBER          NOT NULL,
   hostname        VARCHAR2(256)
 )
/
show errors

-- need to ignore pre-existing key for downgrade->upgrade
BEGIN
   EXECUTE IMMEDIATE 
     'ALTER TABLE vncr ADD CONSTRAINT pk_vncr primary key(hostid)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-02260) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
show errors

ALTER TABLE vncr ADD CONSTRAINT vncr_name UNIQUE(name)
/
show errors

-- For compatibility with older code
CREATE OR REPLACE TRIGGER VNCR_INSERT 
BEFORE INSERT OR UPDATE
ON VNCR
FOR EACH ROW
BEGIN
  IF :new.hostid IS NULL THEN
    :new.hostid := VNCR_SEQUENCE.NEXTVAL;
  END IF;
END;
/
show errors

CREATE SEQUENCE gsm_sequence
/
show errors

CREATE TABLE database_pool (
   name             VARCHAR2(128) NOT NULL,
   broker_config    NUMBER(1),    -- boolean (1: TRUE, 0: FALSE),
   replication_type NUMBER(1)     DEFAULT NULL, -- 0 - DataGuard
                                                -- 1 - GoldenGate
   pool_type        NUMBER(1)     DEFAULT 0,    -- 0 - GDS
                                                -- 1 - Sharded
   PRIMARY KEY (name)
 )
/
show errors

CREATE TABLE database_pool_admin (
   pool_name VARCHAR2(128) REFERENCES database_pool(name),
   user_name VARCHAR2(128) NOT NULL,  -- references "user" table
   PRIMARY KEY (pool_name, user_name)
 )
/
show errors

-- for sharding
CREATE SEQUENCE shardspace_sequence
/
show errors

CREATE TABLE SHARD_SPACE (
   SHARDSPACE_ID    NUMBER        NOT NULL,
   NAME             VARCHAR2(128) NOT NULL,
   CHUNKS           NUMBER,
   ORIG_CHUNKS      NUMBER,  
   CHUNKS_CREATED   NUMBER(1),
   DATABASE_POOL    VARCHAR(128),
   PROTECTION_MODE  NUMBER(1),
   STATUS           NUMBER(1)     DEFAULT NULL,
   PRIMARY KEY (shardspace_id),
   CONSTRAINT ss_name_unique UNIQUE (name)
 ) 
/
show errors

ALTER TABLE shard_space ADD CONSTRAINT ss_in_pool
   FOREIGN KEY (database_pool)
   REFERENCES database_pool(name)
/
show errors

CREATE TABLE BROKER_CONFIGS (
   DRSET_NUMBER    NUMBER         NOT NULL,
   SHARDSPACE_ID   NUMBER         DEFAULT NULL,
   PROTECTION_MODE NUMBER(1),     -- redundant copy of shardspace value
   STATUS          NUMBER,
   PARAMETERS      dbparams_list  DEFAULT NULL,
   DBID            NUMBER         DEFAULT NULL,
   DB_NAME         VARCHAR2(30)   DEFAULT NULL,
   IS_MONITORED    NUMBER(1)      DEFAULT 0,    -- Boolean (1 TRUE, 0 FALSE)
   MINOBJ_NUM      NUMBER         DEFAULT NULL, --obj number range min
   MAXOBJ_NUM      NUMBER         DEFAULT NULL, --obj number range max 
   OBSERVER_STATE  VARCHAR2(512), -- observer state message   
   PRIMARY KEY (drset_number)
 )
/
show errors

ALTER TABLE broker_configs ADD CONSTRAINT bk_in_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

-- For shardgroup surrogate key
CREATE SEQUENCE shardgroup_sequence
/
show errors

CREATE TABLE SHARD_GROUP (
     SHARDGROUP_ID     NUMBER        NOT NULL, 
     NAME              VARCHAR2(128) NOT NULL, 
     REGION_NUM        NUMBER        DEFAULT NULL, 
     REPFACTOR         NUMBER,
     CHUNKS            NUMBER, 
     CHUNK_LOC_CREATED NUMBER(1)     DEFAULT 0,  -- boolean (1 TRUE, 0 FALSE)
     DEPLOY_AS         NUMBER(1)     DEFAULT 0,  -- 0 = primary
                                                 -- 1 = non-active standby
                                                 -- 2 = active standby
     SHARDSPACE_ID     NUMBER        NOT NULL,
     STATUS            NUMBER        DEFAULT NULL,
     DEST              NUMBER,
     PRIMARY KEY (shardgroup_id),
     CONSTRAINT sg_name_unique UNIQUE (name)
    ) 
/
show errors

ALTER TABLE shard_group ADD CONSTRAINT sg_in_region
   FOREIGN KEY (region_num)
   REFERENCES region(num)
/
show errors

ALTER TABLE shard_group ADD CONSTRAINT sg_in_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

-- ddl_requests needs to be in sys schema for security
CREATE TABLE sys.ddl_requests (
   ddl_num        NUMBER,
   ddl_text       CLOB          NOT NULL,
   pwd_count      NUMBER,
   schema_name    VARCHAR2(128) NOT NULL, -- really current user
                                          -- SHARD_TODO: need to fix this but
                                          --   requires a GSM change
   object_name    VARCHAR(128)  DEFAULT NULL,
   operation_type CHAR(1)       NOT NULL,     --'S' - sync signal (noop on db side)
                                              --'C' - DDL create object
                                              --'M' - DDL modify object
                                              --'D' - DDL drop object
                                              --'N' - New shardspace (GDSCTL)
                                              --'T' - New Table family
   object_type    NUMBER        DEFAULT NULL,
   params         VARCHAR(4000) DEFAULT NULL, -- same as gsm_change_message.params
   ignore_flag    NUMBER,
   sess_info      CLOB  DEFAULT NULL,
   shardspace     VARCHAR2(128) DEFAULT NULL,
   object_owner   VARCHAR2(128),
   op_code        CHAR(1) DEFAULT NULL,       -- Not used 
   orig_ddl_text  CLOB          DEFAULT  NULL,
   ddl_flag       NUMBER,
                                              -- 0 - Run ddl_text
                                              -- 1 - Replace with orig_ddl_text
   ddl_intcode    NUMBER        DEFAULT NULL, -- OGG DDL internal code
   PRIMARY KEY (ddl_num)
 )
/
show errors

GRANT SELECT,UPDATE,DELETE,INSERT ON sys.ddl_requests to gsmadmin_internal
/
show errors

CREATE OR REPLACE synonym ddl_requests FOR sys.ddl_requests
/
show errors

CREATE table sys.ddl_requests_pwd (
   ddl_num            NUMBER,
   pwd_begin          NUMBER,
   enc_pwd            RAW(128) NOT NULL
 )
/
show errors

GRANT SELECT,UPDATE,DELETE,INSERT ON sys.ddl_requests_pwd to gsmadmin_internal
/
show errors

CREATE OR REPLACE synonym ddl_requests_pwd FOR sys.ddl_requests_pwd
/
show errors

CREATE SEQUENCE drset_sequence START WITH 1 NOCACHE
/
show errors

CREATE TABLE container_database (
   name                   VARCHAR2(30)    NOT NULL,
   connect_string         VARCHAR2(512)   NOT NULL,
   status                 CHAR(1)         NOT NULL,  -- TBD
   scan_address           VARCHAR2(512)   DEFAULT NULL,
   ons_port               NUMBER          DEFAULT NULL,
   num_assigned_instances NUMBER          NOT NULL,
   srlat_thresh           NUMBER          DEFAULT 20,  -- disk threhold
   cpu_thresh             NUMBER          DEFAULT 75,  -- cpu threshold
   version                VARCHAR2(30)    DEFAULT NULL, -- database version
   db_type                CHAR(1)         DEFAULT NULL, -- 'N': Non RAC
                                                        -- 'A': Admin RAC
                                                        -- 'P': Policy RAC
                                                        -- 'U': Unknown
   encrypted_gsm_password RAW(2000)       DEFAULT NULL, -- enc gsm password
   hostid                 NUMBER          DEFAULT NULL, 
   oracle_home            VARCHAR2(4000)  DEFAULT NULL,
   create_state           CHAR(1)        DEFAULT NULL, -- 'N' – not created
                                                         -- 'C' - created
   DRSET_NUMBER           NUMBER         DEFAULT NULL,    
   DEPLOY_AS              NUMBER(1)      DEFAULT 0,  -- 0 = primary
                                                     -- 1 = non-active standby
                                                     -- 2 = active standby
   is_monitored           NUMBER(1)      DEFAULT 0,
   dg_params              dbparams_list,
   FLAGS                  NUMBER         DEFAULT NULL,  
   -- parameters from 'create cdb'
   DESTINATION            VARCHAR2(128)  DEFAULT NULL,
   CREDENTIAL             VARCHAR2(128)  DEFAULT NULL,
   DBPARAMFILE            VARCHAR2(128)  DEFAULT NULL,
   DBTEMPLATEFILE         VARCHAR2(128)  DEFAULT NULL,
   NETPARAMFILE           VARCHAR2(128)  DEFAULT NULL,
   -- database info passed from 'create cdb' to 'deploy'
   SYS_PASSWORD           VARCHAR2(128)  DEFAULT NULL,
   SYSTEM_PASSWORD        VARCHAR2(128)  DEFAULT NULL,
   SVCUSERCREDENTIAL      VARCHAR2(128)  DEFAULT NULL,
   DBNAME                 VARCHAR2(9)    DEFAULT NULL,
   DBDOMAIN               VARCHAR2(256)  DEFAULT NULL,
   DBUNIQUENAME           VARCHAR2(30)   DEFAULT NULL,
   INSTANCENAME           VARCHAR2(255)  DEFAULT NULL,
   RACK                   VARCHAR2(128)  DEFAULT NULL,
   DBID                   NUMBER         NOT NULL,
   PRIMARY KEY (name)
 )
 /
 show errors

-- generated internal DB number, this is a numeric unique value
-- assigned to each database which is as dense as possible
-- (avoids holes in the numbers), unlike databae_num, which is
-- generally very sparse because of holes left for multiple
-- instances on RAC (default 10 gaps per number)
CREATE SEQUENCE int_dbnum_sequence START WITH 1 NOCACHE
/
show errors

CREATE TABLE database (
   name                   VARCHAR2(30)    NOT NULL,
   pool_name              VARCHAR2(128)   REFERENCES database_pool(name),
   region_num             NUMBER          DEFAULT NULL REFERENCES region(num),
   gsm_password           VARCHAR2(128)   NOT NULL,
   connect_string         VARCHAR2(512)   NOT NULL,
   database_num           NUMBER          NOT NULL,
   status                 CHAR(1)         NOT NULL,  -- 'D': default
                                                     -- 'I': incomplete add
                                                     -- 'S': needs reSync
                                                     -- 'R': logically removed
                                                     -- 'U': Undeployed (ignored by GSM)
   scan_address           VARCHAR2(512)   DEFAULT NULL,
   ons_port               NUMBER          DEFAULT NULL,
   num_assigned_instances NUMBER          NOT NULL,
   srlat_thresh           NUMBER          DEFAULT 20,  -- disk threshold
                                          -- Should be the same value as
                                          -- dbms_gsm_common.default_srlat_thresh
   cpu_thresh             NUMBER          DEFAULT 75,  -- cpu threshold
                                          -- Should be the same value as
                                          -- dbms_gsm_common.default_cpu_thresh 
   version                VARCHAR2(30)    DEFAULT NULL, -- database version
   db_type                CHAR(1)         DEFAULT NULL, -- 'N': Non RAC
                                                        -- 'A': Admin RAC
                                                        -- 'P': Policy RAC
                                                        -- 'U': Unknown
   encrypted_gsm_password RAW(2000)       DEFAULT NULL, -- enc gsm password
   hostid                 NUMBER          DEFAULT NULL, 
   oracle_home            VARCHAR2(4000)  DEFAULT NULL,
   shardgroup_id          NUMBER         DEFAULT NULL,
   ddl_num                NUMBER         DEFAULT 0,
   ddl_error              VARCHAR2(4000) DEFAULT NULL, --DDL error message. 
                                         -- If null, DB was unavailable
                                         -- this DB is subject for autorcv
   dpl_status             NUMBER         DEFAULT 0,    -- 0 - Not deployed
                                                       -- 1 - Deploy requested
                                                       -- 2 - Chunk deployment complete
                                                       -- 3 - Deployed
                                                       -- 4 - deployment error
   conv_state             CHAR(1)        DEFAULT NULL, -- 'S' - seed
                                                       -- 'C' - converted
   DRSET_NUMBER           NUMBER         DEFAULT NULL,    
   DEPLOY_AS              NUMBER(1)      DEFAULT 0,    -- 0 = primary
                                                       -- 1 = non-active standby
                                                       -- 2 = active standby
   is_monitored           NUMBER(1)      DEFAULT 0,    -- Boolean (1 TRUE, 0 FALSE)
   SHARDSPACE_ID          NUMBER         DEFAULT NULL,
   dg_params              dbparams_list,
   FLAGS                  NUMBER         DEFAULT NULL,  
   -- parameters from 'create database'
   DESTINATION            VARCHAR2(128)  DEFAULT NULL,
   CREDENTIAL             VARCHAR2(128)  DEFAULT NULL,
   DBPARAMFILE	          VARCHAR2(128)  DEFAULT NULL,
   DBTEMPLATEFILE         VARCHAR2(128)  DEFAULT NULL,
   NETPARAMFILE           VARCHAR2(128)  DEFAULT NULL,
   -- database info passed from 'create database' to 'deploy'
   SYS_PASSWORD           VARCHAR2(128)  DEFAULT NULL,
   SYSTEM_PASSWORD        VARCHAR2(128)  DEFAULT NULL,
   SVCUSERCREDENTIAL      VARCHAR2(128)  DEFAULT NULL,
   DBNAME                 VARCHAR2(9)    DEFAULT NULL,
   DBDOMAIN               VARCHAR2(256)  DEFAULT NULL,
   DBUNIQUENAME           VARCHAR2(30)   DEFAULT NULL,
   INSTANCENAME           VARCHAR2(255)  DEFAULT NULL,
   MINOBJ_NUM             NUMBER         DEFAULT NULL, --obj number range min
   MAXOBJ_NUM             NUMBER         DEFAULT NULL, --obj number range max
   -- Pending requests on this database. If gsm_request# is non-zero
   -- other fields may contains info about request for this DB
   GSM_REQUEST#           NUMBER         DEFAULT 0,
   response_code          NUMBER         DEFAULT NULL,
   response_info          VARCHAR2(4000) DEFAULT NULL,
   error_info             VARCHAR2(4000) DEFAULT NULL,
   -- internal dense DB number, not used externally
   -- must be populated by int_dbnum_sequence
   int_dbnum              NUMBER         DEFAULT 0,
   RACK                   VARCHAR2(128)  DEFAULT NULL,
    -- following columns are required by OGG only   
   cdb_name               VARCHAR2(128)  DEFAULT NULL, -- if db is a pdb, NULL if non-CDB
   gg_service             VARCHAR2(4000) DEFAULT NULL, -- OGG service descriptor
   gg_password            RAW(2000)      DEFAULT NULL, -- OGG admin password (encrypted)
   spare1                 VARCHAR2(4000) DEFAULT NULL,   
   spare2                 VARCHAR2(4000) DEFAULT NULL,
   -- used for PDB as shard support...do NOT use cdb_name above
   --   unless in OGG code
   container              VARCHAR2(128)  DEFAULT NULL,
   PRIMARY KEY (database_num)
 )
/
show errors

ALTER TABLE DATABASE ADD CONSTRAINT in_vncr
   FOREIGN KEY (hostid)
   REFERENCES vncr(hostid)
/
show errors

ALTER TABLE DATABASE ADD CONSTRAINT in_shardgroup
   FOREIGN KEY (shardgroup_id)
   REFERENCES shard_group(shardgroup_id)
/
show errors

ALTER TABLE DATABASE ADD CONSTRAINT in_drset
   FOREIGN KEY (drset_number)
   REFERENCES broker_configs(drset_number)
/
show errors

ALTER TABLE DATABASE ADD CONSTRAINT in_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

ALTER TABLE database ADD CONSTRAINT name_unique UNIQUE(name)
/
show errors

ALTER TABLE database ADD CONSTRAINT in_container
   FOREIGN KEY (container)
   REFERENCES container_database(name)
/
show errors

-- for 'create database'
CREATE SEQUENCE SID_SEQUENCE
/
show errors

CREATE SEQUENCE FILES_SEQUENCE
/
show errors

CREATE TABLE FILES (
   FILE_NAME VARCHAR2(128) NOT NULL,
   CONTENT   CLOB          NOT NULL,
   POOL_NAME VARCHAR2(128) REFERENCES database_pool(name),
   PRIMARY KEY (FILE_NAME)
 )
/
show errors

CREATE SEQUENCE CREDENTIAL_SEQUENCE
/
show errors

CREATE TABLE CREDENTIAL (
   CREDENTIAL_NAME VARCHAR2(128) NOT NULL,
   POOL_NAME       VARCHAR2(128) REFERENCES database_pool(name),
   PRIMARY KEY (CREDENTIAL_NAME)
 )
/
show errors

CREATE SEQUENCE family_sequence
/
show errors

CREATE TABLE TABLE_FAMILY ( 
    FAMILY_NAME         VARCHAR2(128 BYTE) NOT NULL,
    FAMILY_ID           NUMBER             NOT NULL,
    PARTITION_SET_TYPE  NUMBER             DEFAULT NULL, -- SHARDSPACE type
    SHARD_TYPE          NUMBER             DEFAULT NULL,
    MAX_CHUNK_NUM       NUMBER             DEFAULT 0,
    -- Possible types are: 1, 'RANGE', 2, 'HASH', 4, 'LIST', 0 NONE
    PRIMARY KEY (family_id)
 )
/
show errors

CREATE TABLE SHARDKEY_COLUMNS (
    FAMILY_ID  NUMBER        NOT NULL,
    KEY_LEVEL  NUMBER(1)     NOT NULL, -- 0 for shardspace key, 1 for shard key.   
    COL_NAME   VARCHAR2(128) NOT NULL,
    COL_SEQ    NUMBER        NOT NULL, -- Column number inside the key 
    -- (separate enumeration for group an shard keys)
    PRIMARY KEY (family_id, key_level, col_name)
 )
/
show errors

ALTER TABLE shardkey_columns ADD CONSTRAINT sc_in_family
   FOREIGN KEY (family_id)
   REFERENCES table_family(family_id)
/
show errors

CREATE TABLE service (
   name                      VARCHAR2(64)   NOT NULL,
   network_name              VARCHAR2(512)  NOT NULL,
   pool_name                 VARCHAR2(128)  REFERENCES database_pool(name),
   status                    CHAR(1),
                             -- 'S' (Started)
                             -- 'P' (Stopped)
   preferred_all             NUMBER(1),      
                             -- boolean (1 TRUE, 0 FALSE)
   locality                  NUMBER(1),      
                             -- anywhere (0), local_only (1)
   region_failover           NUMBER(1),      
                             -- boolean (1 TRUE, 0 FALSE)
   role                      NUMBER(1),      
                             -- primary (1), physical_standby (2), logical_standby (3)
   failover_primary          NUMBER(1),      
                             -- boolean (1 TRUE, 0 FALSE)
   any_lag                   NUMBER(1),      
                             -- boolean (1 TRUE, 0 FALSE)
   lag                       NUMBER,         
                             -- lag value if 'any_lag' is FALSE
   runtime_balance           NUMBER(1),      
                             -- none (0), service_time (1), throughput (2)
   load_balance              NUMBER(1),      
                             -- none (0), short (1), long (2)
   notification              NUMBER(1), 
                             -- boolean (1 TRUE, 0 FALSE)
   tafpolicy                 NUMBER(1),      
                             -- none (0), basic (1), preconnect (2)
   policy                    NUMBER(1),      
                             -- manual (1), automatic (2)
   dtp                       NUMBER(1),      
                             -- boolean (1 TRUE, O FALSE)
   failover_method           VARCHAR2(64),    
                             -- 'NONE' or 'BASIC'
   failover_type             VARCHAR2(64),    
                             -- 'NONE', 'SESSION', 'SELECT', 'TRANSACTION'
                             -- or 'AUTO'
   failover_retries          NUMBER,
   failover_delay            NUMBER,
   edition                   VARCHAR2(128),
   pdb                       VARCHAR2(128),
   commit_outcome            NUMBER,
                             -- boolean (1 TRUE, 0 FALSE)
   retention_timeout         NUMBER,
   replay_initiation_timeout NUMBER,
   session_state_consistency VARCHAR2(128),
                             -- 'STATIC' or 'DYNAMIC'
   sql_translation_profile   VARCHAR2(261),
   change_state              CHAR(1)        DEFAULT NULL,
   table_family              NUMBER         DEFAULT NULL,
   stop_option               VARCHAR2(13),
                             -- 'NORMAL' or 'IMMEDIATE' or 'TRANSACTIONAL'
   drain_timeout             NUMBER         DEFAULT NULL,
   failover_restore          VARCHAR2(64)   DEFAULT NULL,
                             -- NONE or LEVEL1
   PRIMARY KEY (name, pool_name)
 )
/
show errors

ALTER TABLE service ADD CONSTRAINT in_family
   FOREIGN KEY (table_family)
   REFERENCES table_family(family_id)
/
show errors

CREATE TABLE service_preferred_available (
   service_name    VARCHAR2(64),
   pool_name       VARCHAR2(128),
   database        VARCHAR2(30),
   preferred       NUMBER(1),     -- (1 preferred, 0 available)
   status          CHAR(1)        DEFAULT NULL,
                                  -- 'E' (Enabled)
                                  -- 'D' (Disabled)
   state           CHAR(1)        DEFAULT 'S',
                                  -- 'S' (Stopped)
                                  -- 'D' (Down - stopped by user)
                                  -- 'U' (Up and rUnning)
   dbparams        dbparams_list  DEFAULT NULL, -- database specific parameters
   instances       instance_list  DEFAULT NULL, -- list of preferred or
                                                -- available instances for
                                                -- admin managed clusters
                                                -- (not currently used)
   change_state    CHAR(1)        DEFAULT NULL
 )
  NESTED TABLE instances STORE AS instances_nt
/
show errors

ALTER TABLE service_preferred_available ADD constraint fk_db_spa 
   foreign key(database) references database(name)
/
show errors

-- need to ignore pre-existing key for downgrade->upgrade
BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE service_preferred_available ADD constraint
      pk_spa primary key(service_name, pool_name, database)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-02260 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
show errors

-- need to ignore pre-existing key for downgrade->upgrade
BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE service_preferred_available ADD constraint
      fk_sp_spa foreign key(service_name, pool_name) references service(name, pool_name)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-02260 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
show errors

ALTER TABLE service_preferred_available ADD constraint spa_in_pool 
   foreign key(pool_name) references database_pool(name)
/
show errors


CREATE TABLE gsm_requests (
   change_seq#    NUMBER             NOT NULL,     -- copied from request
   request        gsm_change_message NOT NULL,
   failure_count  NUMBER             DEFAULT 0,
   error_message  VARCHAR2(4000)     DEFAULT NULL,
   status         CHAR(1)            DEFAULT 'N',  -- values 'N', 'D', 'F','A'
   change_date    DATE               DEFAULT SYSDATE,
   old_instances  instance_list      DEFAULT NULL, -- old instances for recovery
   error_num      NUMBER             DEFAULT NULL,
   ddl_num        NUMBER             DEFAULT NULL,
   parent_request NUMBER             DEFAULT NULL,
   PRIMARY KEY (change_seq#)
 )
 NESTED TABLE old_instances STORE AS old_instances_nt
/
show errors

ALTER TABLE gsm_requests ADD CONSTRAINT prnt_req
   FOREIGN KEY (parent_request)
   REFERENCES gsm_requests(change_seq#)
/
show errors

CREATE SEQUENCE cat_sequence
/
show errors

CREATE TABLE catalog_requests (
   cat_seq#       NUMBER,
   source_db      NUMBER      DEFAULT NULL, -- source database
   target_db      NUMBER      DEFAULT NULL, -- target database
   shspace_list   number_list DEFAULT NULL, -- shardspaces list
   exec_db        NUMBER      DEFAULT NULL,
   replica_num    NUMBER      DEFAULT NULL, -- needed by OGG only
   request_type   NUMBER,     -- 1 - move chunk, 2 - copy chunk
   obj_id         NUMBER,     -- ID of object that is the target of the request
                              -- for chunk move it is chunk ID
   status         NUMBER      DEFAULT 0,    -- status of request
   timeout        NUMBER      DEFAULT 0,    -- request timeout
   gsm_request#   NUMBER      DEFAULT NULL,  -- gsm_request number
   gdsctl_id      NUMBER      DEFAULT NULL  -- gsdsctl session id
 )
 nested table shspace_list store as shspace_nt
/
show errors

ALTER TABLE catalog_requests ADD CONSTRAINT cr_dbsrc
   FOREIGN KEY (source_db)
   REFERENCES database(database_num)
/
show errors

ALTER TABLE catalog_requests ADD CONSTRAINT cr_dbtrgt
   FOREIGN KEY (target_db)
   REFERENCES database(database_num)
/
show errors

ALTER TABLE catalog_requests ADD CONSTRAINT cr_database
   FOREIGN KEY (exec_db)
   REFERENCES database(database_num)
/
show errors


------------------------------------------------------------------------------
-- TABLES RELATED TO SHARDING
------------------------------------------------------------------------------

CREATE SEQUENCE cs_chunk_id
/
show errors

CREATE TABLE CHUNKS (
   CHUNK_NUMBER   NUMBER        NOT NULL ,
   SHARDSPACE_ID  NUMBER        DEFAULT NULL,  
   LOW_KEY        NUMBER        DEFAULT NULL,
   HIGH_KEY       NUMBER        DEFAULT NULL,
   BHIBOUNDVAL    BLOB          DEFAULT NULL,
   BLOBOUNDVAL    BLOB          DEFAULT NULL,
   STATE          NUMBER        DEFAULT 0, 
   -- Should be the same value as
   -- dbms_gsm_common.chunk_up
   RO_DBNUM       NUMBER        DEFAULT NULL, -- read only database id
   RW_DBNUM       NUMBER        DEFAULT NULL, -- read write database id
   CHUNK_ID       NUMBER        DEFAULT 0,    -- chunk id for cross sharding (catalog only)
   IS_RACAFF NUMBER DEFAULT 0, -- 1 if chunk is created for rac affinity
   PART_OBJ# NUMBER DEFAULT 0, -- RAC affinity: parittion object number
   PRIMARY KEY (chunk_number, shardspace_id)
 )
/
show errors

ALTER TABLE chunks ADD CONSTRAINT chunk_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

CREATE TABLE ALL_CHUNKS (
   CHUNK_NUMBER   NUMBER        NOT NULL ,
   SHARDSPACE_ID  NUMBER        DEFAULT NULL,  
   LOW_KEY        NUMBER        DEFAULT NULL,
   HIGH_KEY       NUMBER        DEFAULT NULL,
   PRIMARY KEY (chunk_number, shardspace_id)
 )
/
show errors

ALTER TABLE all_chunks ADD CONSTRAINT allchunk_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

CREATE TABLE CHUNK_LOC ( 
   CHUNK_NUMBER  NUMBER        NOT NULL,
   DATABASE_NUM  NUMBER        NOT NULL,
   SHARDSPACE_ID NUMBER,
   IN_MOVE       NUMBER(1)     DEFAULT 0,
   -- following columns are required by OGG only
   -- denormalize shardgroup_id
   SHARDGROUP_ID NUMBER,
   REPLICA_NUM   NUMBER        DEFAULT NULL,
   -- values in interval [1..repfactor]
   -- a "one" means "primary copy" in a shardgroup
   PRIMARY KEY (chunk_number, database_num)
 ) 
/
show errors

ALTER TABLE chunk_loc ADD CONSTRAINT cl_database
   FOREIGN KEY (database_num)
   REFERENCES database(database_num)
/
show errors

ALTER TABLE chunk_loc ADD CONSTRAINT cl_shardgroup
   FOREIGN KEY (shardgroup_id)
   REFERENCES shard_group(shardgroup_id)
/
show errors

ALTER TABLE chunk_loc ADD CONSTRAINT cl_shardspace
   FOREIGN KEY (shardspace_id)
   REFERENCES shard_space(shardspace_id)
/
show errors

ALTER TABLE chunk_loc ADD CONSTRAINT cl_chunk
   FOREIGN KEY (chunk_number, shardspace_id) 
   REFERENCES chunks(chunk_number, shardspace_id)
/
show errors

CREATE TABLE PARTITION_SET (
   SET_NAME       VARCHAR2(128) NOT NULL,
   HIBOUNDLEN     NUMBER,
   HIBOUNDVAL     CLOB,
   BHIBOUNDVAL    BLOB,
   LOBOUNDLEN     NUMBER,
   LOBOUNDVAL     CLOB,
   BLOBOUNDVAL    BLOB,
   SHARDSPACE_ID  NUMBER,
   FAMILY_ID      NUMBER NOT NULL,
   PS_ORDER       NUMBER DEFAULT NULL,
   PRIMARY KEY (set_name)
 )
/
show errors

ALTER TABLE partition_set ADD CONSTRAINT ps_family
   FOREIGN KEY (family_id)
   REFERENCES table_family(family_id)
/
show errors

CREATE TABLE TABLESPACE_SET (
   SET_NAME      VARCHAR2 (30 BYTE) NOT NULL ,
   SHARDSPACE_ID NUMBER NOT NULL,
   FAMILY_ID     NUMBER DEFAULT NULL,
   PARTITION_SET VARCHAR2 (128) DEFAULT NULL,
   PRIMARY KEY (set_name)
 )
/
show errors

--ALTER TABLE tablespace_set ADD CONSTRAINT ts_shardspace
--   FOREIGN KEY (shardspace_id)
--   REFERENCES shard_space(shardspace_id)
--/
--show errors

ALTER TABLE tablespace_set ADD CONSTRAINT ts_family
   FOREIGN KEY (family_id)
   REFERENCES table_family(family_id)
/
show errors

ALTER TABLE tablespace_set ADD CONSTRAINT ts_partset
   FOREIGN KEY (partition_set)
   REFERENCES partition_set(set_name)
/
show errors

CREATE TABLE SHARD_TS ( 
   TABLESPACE_NAME VARCHAR2(30)   NOT NULL,
   TABLESPACE_SET  VARCHAR2(30),
   CHUNK_NUMBER    NUMBER DEFAULT NULL, -- NULL for user-defined sharding
   SHARDSPACE_ID   NUMBER DEFAULT NULL, -- can be NULL for user-defined sharding
   MOVE_FLAG       NUMBER DEFAULT 0, -- if 1 then txn was set R/O during move
   PRIMARY KEY (tablespace_name),
   supplemental log group shard_ts$log_grp
    (tablespace_name, chunk_number) always
 ) SEGMENT CREATION IMMEDIATE TABLESPACE SYSTEM
/
show errors

ALTER TABLE shard_ts ADD CONSTRAINT sts_ts
   FOREIGN KEY (tablespace_set)
   REFERENCES tablespace_set(set_name)
/
show errors

ALTER TABLE shard_ts ADD CONSTRAINT sts_chunks
   FOREIGN KEY (chunk_number, shardspace_id)
   REFERENCES chunks(chunk_number, shardspace_id)
/
show errors

-- temporary: re-enable this once split chunk
--  inserts into new chunks info into 
--  chunks before inserting into shard_ts
ALTER TABLE shard_ts DISABLE CONSTRAINT sts_chunks
/
show errors

CREATE TABLE GLOBAL_TABLE (
   TABLE_NAME     VARCHAR2(128)  NOT NULL, 
   SCHEMA_NAME    VARCHAR2(128), 
   FAMILY_ID      NUMBER, 
   TABLE_OBJ#     NUMBER         NOT NULL, -- obj# in sys.obj$ table
   REF_TABLE_FLAG CHAR(1)        NOT NULL,
   SERVICE_ID     NUMBER         DEFAULT NULL,
   NUM_CHUNKS     NUMBER         DEFAULT NULL,
   CONSISTENT     NUMBER(1)      DEFAULT NULL,
   PRIMARY KEY (table_obj#)
 ) 
/
show errors

ALTER TABLE global_table ADD CONSTRAINT gt_family
   FOREIGN KEY (family_id)
   REFERENCES table_family(family_id)
/
show errors

CREATE TABLE TS_SET_TABLE (
   TABLESPACE_NAME VARCHAR2(30),
   TABLE_OBJ#      NUMBER,
   TS_USAGE_FLAG   CHAR(1)       NOT NULL,
   CHILD_OBJ#      NUMBER        DEFAULT NULL
 ) 
/
show errors

ALTER TABLE ts_set_table ADD CONSTRAINT ts_set_ts
   FOREIGN KEY (tablespace_name)
   REFERENCES tablespace_set(set_name)
/
show errors

ALTER TABLE ts_set_table ADD CONSTRAINT ts_set_gt
   FOREIGN KEY (table_obj#)
   REFERENCES global_table(table_obj#)
/
show errors

-- Table to hold DDL counter (1 column 1 row)
CREATE TABLE DDLID$ (
   ddlid      NUMBER NOT NULL,
   MINOBJ_NUM NUMBER DEFAULT NULL, --obj number range min
   MAXOBJ_NUM NUMBER DEFAULT NULL  --obj number range max
 )
/
show errors

-- Idempotency, if row exists already, nothing, else insert
DECLARE
   ddl_count    number;
BEGIN
   SELECT count(*) INTO ddl_count FROM ddlid$;
   IF ddl_count = 0 THEN
      INSERT INTO DDLID$ (ddlid) values (0);
   END IF;
END;
/
show errors

CREATE TABLE verify_history (
   run_number     NUMBER         NOT NULL,
   message_number NUMBER         NOT NULL,
   message_string VARCHAR(1000),
   message_date   DATE           NOT NULL
 )
/
show errors

GRANT SELECT on verify_history TO gsmadmin_role;
/
show errors

CREATE SEQUENCE verify_run_number
/
show errors

CREATE GLOBAL TEMPORARY TABLE CHUNKDATA_TMP (
DATAFILE_NAME VARCHAR2(512))
ON COMMIT PRESERVE ROWS
/
show errors
-------------------------
-- Create AQ Change Queue
-------------------------
DECLARE
  stmt  VARCHAR2(500);
BEGIN
    stmt := 'GRANT SELECT ON aq$_unflushed_dequeues to ' || 'gsmadmin_internal';
    EXECUTE IMMEDIATE stmt;

    dbms_aqadm.create_queue_table(
        queue_table => 'gsmadmin_internal.change_log_queue_table',
        multiple_consumers => TRUE,
        queue_payload_type => 'gsmadmin_internal.gsm_change_message',
        storage_clause => 'TABLESPACE "SYSAUX"',
        comment => 'Creating GSM change log queue table');

    dbms_aqadm.create_queue(
        queue_name => 'gsmadmin_internal.change_log_queue',
        queue_table => 'gsmadmin_internal.change_log_queue_table',
        comment => 'GSM Change Log Queue');
EXCEPTION
WHEN others THEN
  IF sqlcode = -24001 THEN NULL;
       -- suppress error for pre-existent queue table
  ELSE raise;
  END IF;
END;
/
show errors

-- This can only be done by the queue owner (gsmadmin_internal) or
-- SYS.  
BEGIN
  dbms_aqadm.grant_queue_privilege(
     privilege => 'dequeue',
     queue_name => 'gsmadmin_internal.change_log_queue',
     grantee => 'GSMCATUSER');
END;
/
show errors

BEGIN
  dbms_aqadm.grant_queue_privilege(
     privilege => 'enqueue',
     queue_name => 'gsmadmin_internal.change_log_queue',
     grantee => 'GSMADMIN_INTERNAL');
END;
/
show errors

BEGIN
   dbms_aqadm.start_queue('gsmadmin_internal.change_log_queue', 
                          TRUE, 
                          TRUE);
END;
/
show errors

----------------------------------
-- Grant resolve network privilege
----------------------------------

BEGIN
  dbms_network_acl_admin.append_host_ace(
    host => '*',
    ace => xs$ace_type(privilege_list => xs$name_list('RESOLVE'),  
                       principal_name => 'GSMADMIN_INTERNAL',  
                       principal_type => xs_acl.ptype_db));
END;
/
show errors

-----------------------
-- Set Table Privileges
-----------------------

GRANT select on cloud to gsmadmin_role, gds_catalog_select;
GRANT select on region to gsmadmin_role, gds_catalog_select;
GRANT select on gsm to gsmadmin_role, gds_catalog_select;
GRANT select on vncr to gsmadmin_role, gds_catalog_select;
GRANT select on database_pool to gsmadmin_role, gds_catalog_select;
GRANT select on database_pool_admin to gsmadmin_role, gds_catalog_select;
GRANT select on gsm_requests to gsmadmin_role, gds_catalog_select;
GRANT select on container_database to gsmadmin_role, gds_catalog_select;
GRANT select on database to gsmadmin_role, gds_catalog_select;
GRANT select on files to gsmadmin_role, gds_catalog_select;
GRANT select on credential to gsmadmin_role, gds_catalog_select;
GRANT select on service to gsmadmin_role, gds_catalog_select;
GRANT select on service_preferred_available to gsmadmin_role, gds_catalog_select;
GRANT select on shard_group to gsmadmin_role, gds_catalog_select;
GRANT select on tablespace_set to gsmadmin_role, gds_catalog_select;
GRANT select on shard_space to gsmadmin_role, gds_catalog_select;
GRANT select on broker_configs to gsmadmin_role, gds_catalog_select;
GRANT select on shardkey_columns to gsmadmin_role, gds_catalog_select;
GRANT select on partition_set to gsmadmin_role, gds_catalog_select;
GRANT select on catalog_requests to gsmadmin_role, gds_catalog_select;
GRANT select on chunk_loc to gsmadmin_role, gds_catalog_select;
GRANT select on chunks to gsmadmin_role, gds_catalog_select;
GRANT select on shard_ts to gsmadmin_role, gds_catalog_select;
GRANT select on global_table to gsmadmin_role, gds_catalog_select;
GRANT select on table_family to gsmadmin_role, gds_catalog_select;
GRANT select on sys.ddl_requests to gsmadmin_role, gds_catalog_select;
GRANT select on sys.ddl_requests_pwd to gsmadmin_role, gds_catalog_select;

-- Import catalog permissions.
GRANT insert on vncr to gsmadmin_role;
GRANT update on cloud to gsmadmin_role;
GRANT insert,update on region to gsmadmin_role;
GRANT insert on gsm to gsmadmin_role;

GRANT insert on container_database to gsmadmin_role;
GRANT insert on database to gsmadmin_role;
GRANT insert on files to gsmadmin_role;
GRANT insert on credential to gsmadmin_role;
GRANT insert on database_pool to gsmadmin_role;
GRANT insert on database_pool_admin to gsmadmin_role;
GRANT insert on service to gsmadmin_role;
GRANT insert on service_preferred_available to gsmadmin_role;
-- End import catalog permissions

GRANT select on database_pool to gsm_pooladmin_role;
GRANT select on container_database to gsm_pooladmin_role;
GRANT select on database to gsm_pooladmin_role;
GRANT select on files to gsm_pooladmin_role;
GRANT select on credential to gsm_pooladmin_role;
GRANT select on sys.ddl_requests to gsm_pooladmin_role;
GRANT select on sys.ddl_requests_pwd to gsm_pooladmin_role;
GRANT select on cloud to gsm_pooladmin_role;
GRANT select on service to gsm_pooladmin_role;
GRANT select on service_preferred_available to gsm_pooladmin_role;
GRANT select on gsm_requests to gsm_pooladmin_role;

-- Pool admin has to see regions in order to know which regions
-- to which to add databases.
GRANT select on region to gsm_pooladmin_role;

-- set type privs (so that GDSCTL can select types from tables)
GRANT execute on gsmadmin_internal.gsm_change_message to gsmadmin_role;
GRANT execute on gsmadmin_internal.dbparams_t to gsmadmin_role,
                                                 gsm_pooladmin_role;
GRANT execute on gsmadmin_internal.dbparams_list to gsmadmin_role,
                                                    gsm_pooladmin_role;
GRANT execute on gsmadmin_internal.rac_instance_t to gsmadmin_role,
                                                     gsm_pooladmin_role;
GRANT execute on gsmadmin_internal.instance_list to gsmadmin_role,
                                                    gsm_pooladmin_role;
GRANT execute on gsmadmin_internal.name_list to gsmadmin_role,
                                                    gsm_pooladmin_role;
GRANT execute on gsmadmin_internal.number_list to gsmadmin_role,
                                                    gsm_pooladmin_role;

GRANT select,insert,update,delete on gdsctl_messages to gsm_pooladmin_role, 
                                                        gsmadmin_role;
GRANT update,delete on gsm_requests to gsm_pooladmin_role, gsmadmin_role;
GRANT update on service_preferred_available to gsmcatuser;
GRANT update on container_database to gsmcatuser;
GRANT update on database to gsmcatuser;
GRANT update on broker_configs to gsmcatuser;
GRANT update on files to gsmcatuser;
GRANT update on credential to gsmcatuser;

GRANT gsmadmin_role, gsm_pooladmin_role to gsmcatuser;

-- session context for cross-shard
CREATE OR REPLACE CONTEXT shard_ctx USING gsmadmin_internal.dbms_gsm_pooladmin;

-- session context for ddl updates
CREATE OR REPLACE CONTEXT shard_ctx2 USING gsmadmin_internal.dbms_gsm_utility;

--------------------- LOCAL_CHUNKS view and it's friends (for clients)

create or replace view LOCAL_CHUNK_TYPES
  (TABFAM_ID, TABLE_NAME, SCHEMA_NAME,
    GROUP_TYPE, GROUP_COL_NUM,   --   number of columns in super key
    SHARD_TYPE, SHARD_COL_NUM,   --  number of columns in shard key
    DEF_VERSION,                 --  version of the shard definition
    SHARDGROUP_NAME
  )
as select
  TF.FAMILY_ID, GT.TABLE_NAME, GT.SCHEMA_NAME,
  decode(TF.PARTITION_SET_TYPE, 1, 'RANGE', 2, 'HASH', 4, 'LIST', 'NONE'),
  (select count(1) from SHARDKEY_COLUMNS PK where PK.FAMILY_ID = TF.FAMILY_ID and PK.KEY_LEVEL = 0),
  decode(TF.SHARD_TYPE, 1, 'RANGE', 2, 'HASH', 4, 'LIST', 'NONE'),
  (select count(1) from SHARDKEY_COLUMNS PK where PK.FAMILY_ID = TF.FAMILY_ID and PK.KEY_LEVEL = 1),
  D.ddlid, dbms_gsm_common.getParam_shardgroup_name
from
  GLOBAL_TABLE GT, TABLE_FAMILY TF, DDLID$ D
where GT.REF_TABLE_FLAG = 'R' AND 
  TF.FAMILY_ID = GT.FAMILY_ID
with read only
/

create or replace public synonym LOCAL_CHUNK_TYPES for LOCAL_CHUNK_TYPES
/

grant read on LOCAL_CHUNK_TYPES to PUBLIC with grant option
/
show errors

create or replace view LOCAL_CHUNK_COLUMNS
(
  TABFAM_ID,
  SHARD_LEVEL,    -- SUPERSHARDING 0 / SHARDING 1
  COL_NAME, COL_IDX_IN_KEY,
  EFF_TYPE,       -- type of the column, which is used for routing and it's format 
                  -- (currently, supposed to be the same as COL_TYPE)
  CHARACTER_SET,  -- Character set used on the database side in case of VARCHAR or NVARCHAR type
  COL_TYPE,       -- real type of the column (not important for client)
  COL_SIZE        -- size of a column if used (important for NCHAR/CHAR, 0 for anything else)
)
as
select
  GT.FAMILY_ID, PK.KEY_LEVEL, PK.COL_NAME, COL_SEQ,
  c.type#, c.charsetid, c.type#, c.length
from
  SYS.COL$ c, SHARDKEY_COLUMNS PK, GLOBAL_TABLE GT
where
  c.NAME = PK.COL_NAME AND c.obj# = GT.TABLE_OBJ# AND GT.REF_TABLE_FLAG = 'R'
with read only 
/
create or replace public synonym LOCAL_CHUNK_COLUMNS for LOCAL_CHUNK_COLUMNS
/
grant read on LOCAL_CHUNK_COLUMNS to PUBLIC with grant option
/
show errors

create or replace view LOCAL_CHUNKS
(
  CHUNK_NAME, SHARD_KEY_LOW, SHARD_KEY_HIGH, GROUP_KEY_LOW, GROUP_KEY_HIGH,
  PRIORITY, TABFAM_ID, GRP_ID, CHUNK_ID, STATE, SHARD_NAME, SHARDSPACE_NAME,
  INST_ID, CHUNK_UNIQUE_ID
)
as
with 
 LOCAL_CHUNK_LOC as
  (SELECT CLX.REPLICA_NUM PRIORITY, NVL(CLX.SHARDSPACE_ID, 0) SSID,
    CLX.CHUNK_NUMBER CHUNK_NUMBER, D.NAME DB_NAME FROM CHUNK_LOC CLX
      LEFT JOIN DATABASE D ON (D.DATABASE_NUM = CLX.DATABASE_NUM)
      WHERE CLX.DATABASE_NUM =
      dbms_gsm_common.getParam_db_num_gsm
      or 
      INSTR(dbms_gsm_common.getParam_gwm_database_flags,'C')
      !=0),
 LOCAL_CHUNK AS
  (SELECT NVL(C.SHARDSPACE_ID, 0) SHARDSPACE_ID, C.CHUNK_NUMBER CHUNK_NUMBER,
          C.BLOBOUNDVAL BLOBOUNDVAL, C.BHIBOUNDVAL BHIBOUNDVAL, C.STATE STATE,
          SS.NAME SHARDSPACE, C.PART_OBJ# PART_OBJECT_ID, C.CHUNK_ID CHUNK_UNIQUE_ID
     FROM CHUNKS C, SHARD_SPACE SS
    WHERE C.SHARDSPACE_ID = SS.SHARDSPACE_ID)
select
 'CHUNK_' || TO_CHAR(LC.SHARDSPACE_ID) || '_' || TO_CHAR(LC.CHUNK_NUMBER),
 LC.BLOBOUNDVAL, LC.BHIBOUNDVAL, PS.BLOBOUNDVAL, PS.BHIBOUNDVAL,
  (SELECT CL.PRIORITY FROM LOCAL_CHUNK_LOC CL
    WHERE LC.CHUNK_NUMBER = CL.CHUNK_NUMBER AND LC.SHARDSPACE_ID = CL.SSID
      AND ROWNUM < 2) PRIORITY,
  TF.FAMILY_ID, LC.SHARDSPACE_ID, LC.CHUNK_NUMBER, LC.STATE,
  CL.DB_NAME,
  LC.SHARDSPACE SHARDSPACE_NAME, 
  nvl2(LC.PART_OBJECT_ID,
       (CASE WHEN CM.INST_ID>0 THEN CM.INST_ID
       ELSE
                (SELECT FUTURE_MASTER FROM GV$GCSPFMASTER_INFO GC
                 WHERE  GC.INST_ID=USERENV('Instance') AND 
                        GC.DATA_OBJECT_ID = LC.PART_OBJECT_ID)
       END), 
       NULL), LC.CHUNK_UNIQUE_ID
from
  (LOCAL_CHUNK LC cross join TABLE_FAMILY TF)
    left outer join PARTITION_SET PS on (PS.SHARDSPACE_ID = LC.SHARDSPACE_ID)
    left outer join (select CHUNK_NUMBER, MIN(MASTER_INST) INST_ID
                     FROM GV$GWM_RAC_AFFINITY 
                     GROUP BY CHUNK_NUMBER) CM
               on  ( CM.CHUNK_NUMBER= LC.CHUNK_NUMBER)
    left outer join LOCAL_CHUNK_LOC CL on
        (LC.CHUNK_NUMBER = CL.CHUNK_NUMBER 
            AND LC.SHARDSPACE_ID = CL.SSID)
where
  LC.STATE in (0,1) --exclude chunks that are down
with read only
/

create or replace public synonym LOCAL_CHUNKS for LOCAL_CHUNKS
/

grant read on LOCAL_CHUNKS to PUBLIC with grant option
/
show errors

------------------------------------------------------------------------------
--
-- Usr visisble views for querying shard catalog
--
------------------------------------------------------------------------------

-- Sharded databases
CREATE OR REPLACE VIEW sha_databases
   (db_unique_name, region_name, connect_string, db_created, status, version,
    rac_type, shardgroup, last_ddl, ddl_error, deployment_state, dg_broker_id,
    shardspace, db_up, is_primary, db_host, oracle_home
   )
AS SELECT
   d.name,
   r.name,
   d.connect_string,
   CASE d.conv_state
      WHEN 'S' THEN 'N'
      WHEN 'C' THEN 'Y' 
      ELSE 'UNKNOWN' END,
   CASE d.status
      WHEN 'U' THEN 'UNDEPLOYED'
      WHEN 'R' THEN 'REPLICATON_CONFIGURED'
      WHEN 'D' THEN 'GSM_SET_UP'
      WHEN 'I' THEN 'ADD_INCOMPLETE'
      WHEN 'S' THEN 'NEEDS_RESYNC'
      ELSE 'UNKNOWN' END,
   dbms_gsm_utility.dbVersRevLookup(d.version),
   CASE d.db_type
      WHEN 'N' THEN 'NON_RAC'
      WHEN 'A' THEN 'ADMIN_RAC'
      WHEN 'P' THEN 'POLICY_RAC'
      WHEN 'S' THEN 'SIHA'
      WHEN 'U' THEN 'UNKNOWN'
      ELSE 'UNKNOWN' END,
   s.name,
   d.ddl_num,
   d.ddl_error,
   CASE d.dpl_status
      WHEN 0 THEN 'NOT_DEPLOYED'
      WHEN 1 THEN 'DEPLOY_REQUESTED'
      WHEN 2 THEN 'REPLICATION_CONFIGURED'
      WHEN 3 THEN 'HAS_CHUNKS'
      WHEN 4 THEN 'DEPLOYED'
      WHEN 5 THEN 'OGG DEPLOYED'
      ELSE 'UNKNOWN' END,
   d.drset_number,
   ss.name,
   CASE BITAND(d.flags, 1)
      WHEN 1 THEN 'Y'
      ELSE 'N' END,
   CASE BITAND(d.flags,2)
      WHEN 2 THEN 'Y'
      ELSE 'N' END,
   v.hostname,
   d.oracle_home
FROM database d
   LEFT JOIN region r ON (d.region_num = r.num)
   LEFT JOIN shard_group s ON (d.shardgroup_id = s.shardgroup_id)
   LEFT JOIN shard_space ss ON (d.shardspace_id = ss.shardspace_id)
   LEFT JOIN vncr v ON (d.hostid = v.hostid);
/

create or replace public synonym SHA_DATABASES for SHA_DATABASES
/

grant read on SHA_DATABASES to GSMADMIN_ROLE
/

grant select on sha_databases to gds_catalog_select
/

show errors
      
ALTER SESSION SET CURRENT_SCHEMA = SYS;

@?/rdbms/admin/sqlsessend.sql
