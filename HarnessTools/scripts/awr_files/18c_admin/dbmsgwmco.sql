Rem
Rem $Header: rdbms/admin/dbmsgwmco.sql /main/48 2017/04/11 16:29:21 sdball Exp $
Rem
Rem dbmsgwmco.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmco.sql - Global Workload Management administration
Rem
Rem    DESCRIPTION
Rem      Defines the interfaces for dbms_gsm_common package that is used
Rem      for common definitions and procedures used for GSM.
Rem
Rem    NOTES
Rem      This package should not contain any definitions or functions
Rem      that require that the GSM cloud catalog tables be defined on the 
Rem      database.
Rem
Rem      It is primarily for defintions and functions shared by the
Rem      dbms_gsm_dbadmin and dbms_gsm_pooladmin/dbms_gsm_cloudadmin
Rem      packages.  It is loaded on both global service databases and the
Rem      GSM cloud catalog database.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmco.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmco.sql
Rem SQL_PHASE: DBMSGWMCO
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdball      03/31/17 - values for failover_restore
Rem    sdball      02/22/17 - Update set/get parm functions for PDB
Rem    saratho     02/08/17 - add isNonOracleCloud()
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    dcolello    04/26/16 - bug 23141895: check indicators in gwm_getmsg
Rem    zzeng       04/06/16 - Add writeToGWMTracing for CLOB
Rem    yulcho      03/23/16 - add verifyUET
Rem    lenovak     02/04/16 - add gdsctl messages
Rem    sdball      01/29/16 - Restrict access to setDBParameter
Rem    sdball      12/11/15 - Remove hostname and oracle_home from
Rem                           database_dsc_t
Rem    itaranov    12/07/15 - Move num2linear
Rem    dcolello    11/21/15 - add fields to database_dsc_t for patching
Rem    dcolello    11/16/15 - remove old schema object names
Rem    dcolello    10/25/15 - sharding object rename for production
Rem    dcolello    07/28/15 - add reptype, sharding, DataGuard constants
Rem    itaranov    07/23/15 - Add getDBParameter to workaround v$parameter
Rem    sdball      06/10/15 - Support for long identifiers
Rem    sdball      03/13/15 - Update gsm_info for sharding
Rem    sdball      03/04/15 - New definitions for 12.2 sharding
Rem    sdball      11/24/14 - Proj 46694: enhance gsm_info 
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    nbenadja    01/09/14 - Move isCDB function.
Rem    sdball      08/15/13 - Add db_type to database_dsc_t
Rem    lenovak     07/29/13 - shard support
Rem    sdball      05/20/13 - add DBIsDowngradeable
Rem    itaranov    04/24/13 - Admin managed support for sync
Rem    itaranov    03/25/13 - Safe types deletion
Rem    itaranov    03/19/13 - Add sync datatypes
Rem    sdball      03/18/13 - Add inst_list_to_inst_string
Rem    sdball      02/26/13 - Add db_vers to gsm_info
Rem    sdball      01/31/13 - Add params_to_dbparam_list
Rem    nbenadja    01/23/13 - Add the function setDBParameter.
Rem    nbenadja    01/16/13 - Add cpu and IO threshold parameter.
Rem    sdball      10/05/12 - Add checkDBCompat
Rem    sdball      08/28/12 - Add gwmSubnet
Rem    sdball      08/21/12 - Add services_t and related types for service
Rem                           checking in verify
Rem    sdball      08/02/12 - Add reRegisterDB
Rem    sdball      06/28/12 - Add serviceChange definition
Rem    sdball      06/13/12 - Change default max instances to 10
Rem    sdball      06/07/12 - Add factoring.
Rem    sdball      05/18/12 - Add getMsg
Rem    sdball      04/24/12 - Add instance_list
Rem    skyathap    11/10/11 - constants for service_context
Rem    skyathap    11/04/11 - constants for service_context
Rem    nbenadja    09/20/11 - Add tracing functions
Rem    skyathap    08/19/11 - tweak constants for service definition to use in
Rem                           gsm_flags
Rem    nbenadja    08/12/11 - Add function existGSM().
Rem    mdilman     07/09/11 - add constants for RAC specific service parameters
Rem    mjstewar    04/26/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL dbmsgwmco.log

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Public Types Needed for Package
--*****************************************************************************

BEGIN EXECUTE IMMEDIATE 'DROP TYPE database_dsc_t FORCE';
  EXCEPTION WHEN others THEN
    IF sqlcode = -4043 THEN NULL; ELSE raise; END IF; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TYPE service_dsc_list_t FORCE';
  EXCEPTION WHEN others THEN
    IF sqlcode = -4043 THEN NULL; ELSE raise; END IF; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TYPE warning_list_t FORCE';
  EXCEPTION WHEN others THEN
    IF sqlcode = -4043 THEN NULL; ELSE raise; END IF; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TYPE gsm_info FORCE';
  EXCEPTION WHEN others THEN
    IF sqlcode = -4043 THEN NULL; ELSE raise; END IF; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP TYPE message_param_list FORCE';
  EXCEPTION WHEN others THEN
    IF sqlcode = -4043 THEN NULL; ELSE raise; END IF; END;
/

-- Needed so that "create or replace" will work below
BEGIN

EXECUTE IMMEDIATE 'DROP TYPE gsm_list_t';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/

BEGIN

EXECUTE IMMEDIATE 'DROP TYPE region_list_t';
EXCEPTION
WHEN others THEN
  IF sqlcode = -4043 THEN NULL;
       -- suppress error for non-existent type
  ELSE raise;
  END IF;

END;
/


CREATE OR REPLACE TYPE gsm_t FORCE IS OBJECT ( 
                             name      varchar2(128),
                             endpoint  varchar2(4000),
                             ons_port  number,
                             region    varchar2(128) );
/

CREATE OR REPLACE TYPE region_t FORCE IS OBJECT ( 
                             name      varchar2(128),
                             buddy     varchar2(128) );
/

CREATE OR REPLACE TYPE instance_t FORCE IS OBJECT ( 
                        virt_name      varchar2(128),
                        instance_name  varchar2(128) );
/

CREATE OR REPLACE TYPE service_t FORCE IS OBJECT (
                                  svc_name        varchar2(64),
                                  svc_network_name              varchar2(512),
                                  svc_failover_method           varchar2(64),
                                  svc_failover_type             varchar2(64),
                                  svc_failover_retries          number(10),
                                  svc_failover_delay            number(10),
                                  svc_runtime_balance           varchar2(12),
                                  svc_dtp                       varchar2(1),
                                  svc_notification              varchar2(3),
                                  svc_load_balance              varchar2(5),
                                  svc_edition                   varchar2(128),
                                  svc_commit_outcome            varchar2(3),
                                  svc_retention_timeout         number,
                                  svc_replay_initiation_timeout number,
                                  svc_session_state_consistency varchar2(128),
                                  svc_pdb                       varchar2(128),
                                  svc_sql_translation_profile   varchar2(261),
                                  svc_lag                       varchar(128),
                                  svc_locality                  number,
                                  svc_region_failover           number);
/
show errors

-- This type describes all possible service modifictaions, that can be made using
-- sync function. While previous type describes service for user, this one is 
-- used by GSM to tell database about the service.

create or replace type service_dsc_t force as object(
  service_name              varchar2(100), 
  network_name              varchar2(512),
  rlb_goal                  number,
  clb_goal                  number, 
  distr_trans               number,
  aq_notifications          number,
  lag_property              number,
  max_lag_value             number, 
  failover_method           varchar2(64),
  failover_type             varchar2(64),
  failover_retries          number,
  failover_delay            number,
  edition                   varchar2(128),
  pdb                       varchar2(128),
  commit_outcome            number,
  retention_timeout         number,
  replay_initiation_timeout number,
  session_state_consistency varchar2(128),
  sql_translation_profile   varchar2(261),
  locality                  number,
  region_failover           number,
  role                      number,
  network_number            number, 
  server_pool               varchar2(128),
  cardinality               number,
  
  proxy_db                  number,
  to_be_started             number,
  do_modify_local           number,
  instances                 varchar2(4000),
  -- This parameter specifies the proxy service.
  is_public                 number,
  aq_ha_notifications       number,
  drain_timeout             number,
  stop_option               varchar2(13),
  failover_restore          varchar2(64),
  CONSTRUCTOR FUNCTION service_dsc_t (SELF IN OUT NOCOPY service_dsc_t, 
                                      name VARCHAR2)
                                     RETURN SELF AS RESULT 
);
/
CREATE OR REPLACE TYPE chunkrange_t FORCE IS OBJECT ( 
                                         chk_from  number,
                                         chk_to    number );
/

show errors

create or replace type BODY service_dsc_t AS
  CONSTRUCTOR FUNCTION service_dsc_t (SELF IN OUT NOCOPY service_dsc_t,
                                      name VARCHAR2 )
                                     RETURN SELF AS RESULT IS
  BEGIN
    SELF.service_name := name;
    RETURN;
  END;                                    
END;                                      
/
show errors
CREATE OR REPLACE TYPE chunkrange_t FORCE IS OBJECT ( 
                                         chk_from  number,
                                         chk_to    number );
/

show errors

create or replace type warning_t force as object (
  code int, 
  message varchar2(1024)
);
/
show errors

GRANT execute on gsmadmin_internal.gsm_t to PUBLIC;
GRANT execute on gsmadmin_internal.region_t to PUBLIC;
GRANT execute on gsmadmin_internal.instance_t to PUBLIC;
GRANT execute on gsmadmin_internal.service_t to PUBLIC;
GRANT execute on gsmadmin_internal.service_dsc_t to PUBLIC;
GRANT execute on gsmadmin_internal.chunkrange_t to PUBLIC;
GRANT execute on gsmadmin_internal.warning_t to PUBLIC;

CREATE OR REPLACE TYPE gsm_list_t IS TABLE OF gsm_t;
/

CREATE OR REPLACE TYPE region_list_t IS TABLE OF region_t;
/

CREATE OR REPLACE TYPE instance_list_t IS TABLE OF instance_t;
/

CREATE OR REPLACE TYPE service_list_t IS TABLE OF service_t;
/

CREATE OR REPLACE TYPE param_value_t FORCE is OBJECT (value_string varchar2(1024));
/

CREATE OR REPLACE TYPE service_dsc_list_t IS TABLE OF service_dsc_t;
/

CREATE OR REPLACE TYPE warning_list_t IS TABLE OF warning_t;
/
CREATE OR REPLACE TYPE chunkrange_list_t IS TABLE OF chunkrange_t;
/

GRANT execute on gsmadmin_internal.gsm_list_t to PUBLIC;
GRANT execute on gsmadmin_internal.region_list_t to PUBLIC;
GRANT execute on gsmadmin_internal.instance_list_t to PUBLIC;
GRANT execute on gsmadmin_internal.service_list_t to PUBLIC;
GRANT EXECUTE ON gsmadmin_internal.param_value_t TO PUBLIC;
GRANT execute on gsmadmin_internal.service_dsc_list_t to PUBLIC;
GRANT execute on gsmadmin_internal.warning_list_t to PUBLIC;
GRANT execute on gsmadmin_internal.chunkrange_list_t to PUBLIC;



create or replace type shard_t force as object (
  db_id NUMBER, 
  conn_str VARCHAR2(256),
  chunks number_list
);
/
show errors
/
GRANT execute on gsmadmin_internal.shard_t to PUBLIC;
/
CREATE OR REPLACE TYPE shard_list_t IS TABLE OF shard_t;
/
GRANT execute on gsmadmin_internal.shard_list_t to PUBLIC;


CREATE OR REPLACE TYPE message_param is OBJECT (param_string varchar2(400));
/

CREATE OR REPLACE TYPE message_param_list is varray(8) of message_param;
/

CREATE OR REPLACE TYPE param_value_list_t IS TABLE OF param_value_t;
/

GRANT EXECUTE ON gsmadmin_internal.message_param_list TO PUBLIC;
/

GRANT EXECUTE ON gsmadmin_internal.message_param TO PUBLIC;
/

GRANT EXECUTE ON gsmadmin_internal.param_value_list_t TO PUBLIC;
/
show errors

CREATE OR REPLACE TYPE gsm_info IS OBJECT (
                         cloud_name     varchar2(128),
                         dbpool_name    varchar2(128),
                         region_name    varchar2(128),
                         database_num   number,
                         gsm_list       gsm_list_t,
                         instance_list  instance_list_t,
                         region_list    region_list_t,
                         service_list   service_list_t,
                         scan_name      varchar2(128),
                         ons_port       number,
                         dbrole         varchar(30),
                         cpu_threshold  number,
                         srlat_threshold number,
                         db_vers        number,
                         ddl_id number,
                         minobj_num number,
                         maxobj_num number,
                         reptype number,
                         file_convert varchar2(512),
                         file_dest varchar2(512),
                         chunk_list chunkrange_list_t,
  CONSTRUCTOR FUNCTION gsm_info (SELF IN OUT NOCOPY gsm_info)
                                     RETURN SELF AS RESULT);
/
show errors

create or replace type BODY gsm_info AS
  CONSTRUCTOR FUNCTION gsm_info (SELF IN OUT NOCOPY gsm_info )
                                     RETURN SELF AS RESULT IS
  BEGIN
    RETURN;
  END;                                    
END;                                      
/
show errors


GRANT execute on gsmadmin_internal.gsm_info to PUBLIC;
/
show errors

create or replace type database_dsc_t as object (
  version     number,

  do_sync_db   number,
  do_start_svc number,
  do_mod_local_svc number,

  want_ons_config number,
  
  db_number   number,
  cloud_name  varchar2(128),
  dbpool_name varchar2(128),
  region_name varchar2(128),
  shdgrp_name varchar2(128),
  shdgrp_id   number,
  num_inst    number,
  cpu_thld    number,
  disk_thld   number,
  do_force    number,
  chunks      number,
  service_list   service_dsc_list_t,
  region_list    region_list_t,
  gsm_list       gsm_list_t,
  
  ons_port  varchar2(256),
  scan_name varchar2(256),
  hostname  varchar2(256),
  db_type   char,
  
  sharding_type number,
  deploy_as number,
  status number,
  shardspace_name varchar2(128),
  shardspace_id number,
  repl_type number,
  MINNUM NUMBER,
  MAXNUM NUMBER,
  DBLPWD VARCHAR2(64),
  DBLEP VARCHAR2(256),
  CONSTRUCTOR FUNCTION database_dsc_t (SELF IN OUT NOCOPY database_dsc_t, 
                                      dbnum NUMBER)
                                     RETURN SELF AS RESULT 
);
/
show errors

create or replace type BODY database_dsc_t AS
  CONSTRUCTOR FUNCTION database_dsc_t (SELF IN OUT NOCOPY database_dsc_t,
                                      dbnum NUMBER )
                                     RETURN SELF AS RESULT IS
  BEGIN
    SELF.db_number := dbnum;
    RETURN;
  END;                                    
END;                                      
/
show errors

GRANT execute on gsmadmin_internal.database_dsc_t to PUBLIC;


--*****************************************************************************
-- Database package for common GSM functions and definitions.
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_common AS


--*****************************************************************************
-- Package Public Types
--*****************************************************************************
-- general max length of a name (same a M_IDEN in RDBMS C code)
max_ident                constant  number := 128;

-- generic TRUE/FALSE indicators for integer parameters. 
-- NOTE: This is necesary because Java/JDBC does not deal well with boolean
--       parameters in PL/SQL procedures. Something we should look sometime.
isFalse  constant  number := 0;
isTrue   constant  number := 1;

-- Update modes for catalog lock
noUpdate constant  number := 0;  -- catalog is not updated
updNoGSM constant  number := 1;  -- catalog Update does not require running GSM
updGSM   constant  number := 2;  -- catalog update requires running GSM

-- pool/catalog type
pool_notsharded constant number := 0;  -- pool/catalog is not sharded
pool_sharded constant number := 1;     -- pool/catalog is sharded

-- replication types supported
reptype_dg constant number := 0;  -- DataGuard
reptype_ogg constant number := 1;  -- GoldenGate

-- DataGuard protection modes
max_protection constant  number := 0;
max_availability constant  number := 1;
max_performance constant  number := 2;

-- is_primary
is_prim constant number := 0;
is_stby constant number := 1;
is_actstby constant number := 2;

--*****************************************************************************
-- Package Public Constants
--*****************************************************************************

max_inst_param_name     constant    varchar2(25) := '_gsm_max_instances_per_db';
max_inst_default        constant    number := 10;

max_regions_param_name  constant    varchar2(20) := '_gsm_max_num_regions';
max_regions_default     constant    number := 10;

gsm_parameter_name           constant varchar2(10) := '_gsm';
region_list_parameter_name   constant varchar2(16) := '_gsm_region_list';

cpu_thresh_param_name        constant varchar2(15) := '_gsm_cpu_thresh';
default_cpu_thresh           constant    number := 75;

srlat_thresh_param_name      constant varchar2(17) := '_gsm_srlat_thresh';
default_srlat_thresh         constant    number := 20;

-------------------------------------------------------------------------------
-- Service definitions
-- These constants are stored in the 'service' table and used in the 
-- 'addService' routines in the dbms_gsm_pooladmin and dbms_gsm_dbadmin
-- packages.
-------------------------------------------------------------------------------

-- DB Role
db_role_none           constant  number := 0;
db_role_primary        constant  number := 1;
db_role_phys_stby      constant  number := 2;
db_role_log_stby       constant  number := 3;
db_role_snap_stby      constant  number := 4;

-- RLB Goal
rlb_goal_none          constant  number := 0;
rlb_goal_service_time  constant  number := 1;
rlb_goal_throughput    constant  number := 2;

-- CLB Goal
clb_goal_none          constant  number := 0;
clb_goal_short         constant  number := 1;
clb_goal_long          constant  number := 2;

-- TAF policy
taf_none               constant  number := 0;
taf_basic              constant  number := 1;
taf_preconnect         constant  number := 2;

-- Policy
policy_manual          constant  number := 1;
policy_automatic       constant  number := 2;

-- Failover Method
failover_none          constant  varchar2(5) := 'NONE';
failover_basic         constant  varchar2(6) := 'BASIC';

-- Failover Type
failover_type_none     constant  varchar2(5)  := 'NONE';
failover_type_session  constant  varchar2(8)  := 'SESSION';
failover_type_select   constant  varchar2(7)  := 'SELECT';
failover_type_transact constant  varchar2(12) := 'TRANSACTION';
failover_type_auto     constant  varchar2(4)  := 'AUTO';

-- failover_restore
failover_restore_none  constant  varchar2(5)  := 'NONE';
failover_restore_l1    constant  varchar2(6)  := 'LEVEL1';

-- Commit Outcome
commit_outcome_off     constant  number := 0;
commit_outcome_on      constant  number := 1; 

-- Session State Consistency
session_state_static   constant  varchar2(7)  := 'STATIC';
session_state_dynamic  constant  varchar2(8)  := 'DYNAMIC';

-- Distributed Transaction
dtp_off                constant  number := 0;
dtp_on                 constant  number := 1; 

-- Preferred ALL DBS?
select_dbs             constant  number := 0;
prefer_all_dbs         constant  number := 1;

-- Failover Primary
failover_primary_off   constant  number := 0;
failover_primary_on    constant  number := 1;

-- HA Notification
ha_notification_off    constant  number := 0;
ha_notification_on     constant  number := 1;

-- AQ FAN Notification
aq_off                 constant  number := 0;
aq_on                  constant  number := 1;

-- Lag
any_lag                constant  number := 1;
specified_lag          constant  number := 0;

-- GSM_FLAGS - handy bitfield to pass several attributes to the db
-- attribute positions are specified here
gsmflagpos_locality    constant  number := 0;
gsmflagpos_regionfo    constant  number := 1;

-- Locality
service_anywhere       constant  number := 0;
service_local_only     constant  number := 1;

-- Region Failover
region_failover_off    constant  number := 0;
region_failover_on     constant  number := 1;

-- Instance Cardinality on RAC
cardinality_uniform    constant  varchar2(8)  := 'UNIFORM';
cardinality_singleton  constant  varchar2(10) := 'SINGLETON';

-- default drain timeout 
drain_default constant number := -1;

-- Service Reference while calling dbms_service_prvt to control whether
--  the call applies to the service definition in the DB &/or OCR
srvc_context_is_db     constant number := 1;
srvc_context_is_ocr    constant number := 2;

--ExecuteDDL action constants
execddl_default constant number := 0;
execddl_ignore  constant number := 1;
execddl_skip    constant number := 2;

--move chunk operation constants
movechunk_source constant number :=0;
movechunk_target constant number :=1;
movechunk_success constant number :=0;
movechunk_fail    constant number :=1;

--chunks constant
chunk_up       constant number :=0;
chunk_readonly constant number :=1;
chunk_down     constant number :=2;

ctrlchunk_readonly   constant number := chunk_readonly;
ctrlchunk_down       constant number := chunk_down;
ctrlchunk_up         constant number := chunk_up;
ctrlchunk_invalidate constant number := 11;

-- data object number generator;
objnum_range constant number:= 1000000;
objnum_wm constant number:= 10000;
--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************


--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************

-------------------------------------------------------------------------------
--
-- PROCEDURE     setGSMParameter
--
-- Description:
--       Changes the value of the _gsm parameter on a database.       
--
-- Parameters:
--       operation: "add_gsms" -> appends the input list to the current
--                                parameter value
--                  "replace_all_gsms" -> replaces the current parameter
--                                value with the input list
--                  "remove_gsms" -> removes the input list from the
--                                current parameter value
--                  "modify_gsms" -> modify one or more gsm entries
--       gsms: a list of GSMS to add/replace/remove
--
-- Notes:
--    
------------------------------------------------------------------------------- 

add_gsms                constant number := 0;
replace_all_gsms        constant number := 1;
remove_gsms             constant number := 2;
modify_gsms             constant number := 3;

PROCEDURE setGSMParameter( operation IN number,
                           gsms      IN gsm_list_t );

-------------------------------------------------------------------------------
--
-- PROCEDURE     setRegionListParameter
--
-- Description:
--       Changes the value of the _gsm_region_list parameter on a database.       
--
-- Parameters:
--       operation: "add_regions" -> appends the input list to the current
--                                   parameter value
--                  "remove_regions" -> removes the input list from the
--                                      current parameter value
--                  "modify_regions" -> modify one or more region entries
--       regions: a list of regions to add/replace/remove
--
-- Notes:
--    
------------------------------------------------------------------------------- 

add_regions                constant number := 0;
remove_regions             constant number := 1;
modify_regions             constant number := 2;

PROCEDURE setRegionListParameter( operation IN number,
                                  regions   IN region_list_t );

-------------------------------------------------------------------------------
--
-- FUNCTION    existGSM 
--
-- Description:
--       Checks if a gsm_alias already in the _gsm parameter on a database.       
--
-- Parameters:
--       gsm_alias: the name of the GSM. 
--
-- Returns :
--   TRUE : if the gsm_alias exists.
--   FALSE : otherwise.
--
-- Notes:
------------------------------------------------------------------------------- 

FUNCTION existGSM( gsm_alias varchar2) RETURN boolean;

-------------------------------------------------------------------------------
--
-- FUNCTION    isGWMTracing 
--
-- Description:
--       Checks if GWM module tracing is enabled.       
--
-- Parameters:
--       Nome 
--
-- Returns :
--   TRUE : if the GWM sql tracing is enabled.
--   FALSE : otherwise.
--
-- Notes:
------------------------------------------------------------------------------- 

FUNCTION isGWMTracing RETURN boolean;

-------------------------------------------------------------------------------
--
-- FUNCTION    reRegisterDB
--
-- Description:
--       Re-registers database with GSM listeners after some change       
--
-- Parameters:
--       Nome 
--
-- Returns :
--       NONE
--
-- Notes:
-------------------------------------------------------------------------------

PROCEDURE reRegisterDB;

-------------------------------------------------------------------------------
--
-- FUNCTION    checkDBCompat
--
-- Description:
--       Check that database level is compatible with GDS      
--
-- Parameters:
--       None
--
-- Returns :
--       BOOLEAN
--
-- Notes:
-------------------------------------------------------------------------------
FUNCTION checkDBCompat
RETURN BOOLEAN;

-------------------------------------------------------------------------------
--
-- PROCEDURE    writeToGWMTracing 
--
-- Description:
--       prints using the GWM tracing mechanism.       
--
-- Parameters:
--      phrase : text to write 
--
-- Returns :
--      None.
--
-- Notes:
------------------------------------------------------------------------------- 
FUNCTION  clobToTrace(phrase IN clob)
  RETURN varchar2;
PROCEDURE writeToGWMTracing(phrase IN varchar2);
PROCEDURE writeToGWMTracing(phrase IN varchar2, gdsctl_id NUMBER);

FUNCTION isNonOracleCloud
  RETURN BOOLEAN;

FUNCTION isUETenabled
  RETURN binary_integer;

PROCEDURE verifyUET(module IN binary_integer, test IN binary_integer,
                    stage  IN binary_integer, mesg IN varchar2);
PROCEDURE actionUET(module  IN binary_integer, test   IN binary_integer,
                    stage   IN binary_integer, action IN binary_integer,
                    use_val IN binary_integer, value  IN binary_integer);

PROCEDURE ChunkLowHigh (chunk_counter     IN    binary_integer,
                        total_chunks      IN    binary_integer, 
                        chunk_low         OUT   number,
                        chunk_high        OUT   number);
----------------------------------------------------------------------
-- Factoring. Is GDS licensed? (currently requires enterprise edition)
----------------------------------------------------------------------
PROCEDURE gwmFactor;

PROCEDURE region_params_to_region_list( region_list    OUT    region_list_t );
PROCEDURE gsm_params_to_gsm_list( gsm_list    OUT    gsm_list_t );
--------------------------------------------------------------
-- gets Message text given message number and parameters
--------------------------------------------------------------
PROCEDURE getMsg (message_number IN     binary_integer,
                  message_text   OUT    varchar2,
                  params         IN     message_param_list DEFAULT message_param_list());
----------------------------------------------------------
--
-- PROCEDURE    serviceChange 
--
-- Description:
--       Signal a service change for registration    
--
-- Parameters:
--      NONE
--
-- Returns :
--      None.
--
-- Notes:
----------------------------------------------------------
PROCEDURE  serviceChange;

----------------------------------------------------------
--
-- PROCEDURE     gwmSubnet
--
-- Description:
--        Get subnet string for this host (RAC only)   
--
-- Parameters:
--      subnet       OUT    returned subnet string
--
-- Returns :
--      None.
--
-- Notes:
----------------------------------------------------------

PROCEDURE gwmSubnet (subnet OUT varchar2);

----------------------------------------------------------
--
-- FUNCTION     DBIsDowngradeable
--
-- Description:
--        Is Database downgradeable?
--
-- Parameters:
--      None
--
-- Returns :
--      TRUE - DB is downgradeable
--      FALSE - DB is not downgradeable
--
-- Notes:
----------------------------------------------------------

FUNCTION DBIsDowngradeable
  RETURN boolean;

----------------------------------------------------------
--
-- FUNCTION     params_to_dbparam_list
--
-- Description:
--        Converts params string in NVP format to dbparams_list type  
--
-- Parameters:
--      params       IN     params string in NVP format
--      dbname       OUT    name of the database
--      dbparams     OUT    parameter collection in dbparams_list type
--
-- Returns :
--      TRUE - List was created
--      FALSE - string not in correct format (list not created)
--
-- Notes:
----------------------------------------------------------
FUNCTION params_to_dbparam_list ( params        IN        varchar2,
                                  dbname        OUT       varchar2,
                                  dbparams      OUT       dbparams_list )
RETURN boolean;

---------------------------------------------------------------------
--
-- PROCEDURE    setDBParameter, getDBParameter*, resetDBParameter
--
-- Description:
--        get,set,reset a gsm parameter in the database.   
--
-- Parameters:
--     pname             IN   parameter name
--     pvalue            IN   parameter value (set only)
--     pdb_id            IN   ID of pdb to get/set parameter in
--     db_uname          IN   db_unique_name of standby database
--                            in which to get/set parameter
--
-- Returns :
--      value of parameter (get only)
--
-- Notes:
---------------------------------------------------------------------
-- set single parameter
PROCEDURE setDBParameter (pname IN varchar2, pvalue IN varchar2)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
PROCEDURE setDBParameter (pname IN varchar2, pvalue IN varchar2,
                          pdb_id IN binary_integer, db_uname IN varchar2)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
-- set parameter to list
PROCEDURE setDBParameter (pname IN varchar2, pvalues IN param_value_list_t)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
PROCEDURE setDBParameter (pname IN varchar2, pvalues IN param_value_list_t,
                          pdb_id IN binary_integer, db_uname IN varchar2)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
-- set region list
PROCEDURE setDBParameter (pname IN varchar2, pvalues IN region_list_t)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
PROCEDURE setDBParameter (pname IN varchar2, pvalues IN region_list_t,
                          pdb_id IN binary_integer, db_uname IN varchar2)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
-- reset parameter
PROCEDURE resetDBParameter (pname IN varchar2)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
PROCEDURE resetDBParameter (pname IN varchar2,
                            pdb_id IN binary_integer)
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);

-- get numeric parameter
FUNCTION getDBParameterNum(pname IN varchar2, pno IN BINARY_INTEGER)
RETURN BINARY_INTEGER
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE dbms_gsm_utility,
               PACKAGE ggsys.ggsharding,
               PROCEDURE executeDDL);
FUNCTION getDBParameterNum(pname IN varchar2, pno IN BINARY_INTEGER,
                           pdb_id IN binary_integer)
RETURN BINARY_INTEGER
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE dbms_gsm_utility,
               PACKAGE ggsys.ggsharding,
               PROCEDURE executeDDL);

-- get string parameter
FUNCTION getDBParameterStr(pname IN varchar2, pno IN BINARY_INTEGER)
RETURN VARCHAR2
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);
FUNCTION getDBParameterStr(pname IN varchar2, pno IN BINARY_INTEGER,
                           pdb_id IN binary_integer)
RETURN VARCHAR2
ACCESSIBLE BY (PACKAGE dbms_gsm_dbadmin, 
               PACKAGE dbms_gsm_pooladmin,
               PACKAGE dbms_gsm_common,
               PACKAGE dbms_gsm_cloudadmin,
               PACKAGE ggsys.ggsharding);

-- Public wrappers to get specific parameters which we are O.K. to let users see
FUNCTION getParam_shardgroup_name
RETURN VARCHAR2;
FUNCTION getParam_db_num_gsm
RETURN NUMBER;
FUNCTION getParam_gwm_database_flags
RETURN VARCHAR2;

 ----------------------------------------------------------------------------
PROCEDURE gsm_list_to_gsm_params( gsm_list    IN    gsm_list_t,
                                  gsm_params  OUT   param_value_list_t );

----------------------------------------------------------
--
-- FUNCTION    inst_list_to_inst_string 
--
-- Description:
--        convert instance_list to a string format.   
--
-- Parameters:
--     instances         IN   list of instances to convert
--
-- Returns :
--      Instance string in varchar2
--
-- Notes:
----------------------------------------------------------
FUNCTION inst_list_to_inst_string (instances     IN  instance_list)
RETURN varchar2;

----------------------------------------------------------
--
-- FUNCTION   isCDB 
--
-- Description:
--        Check if the database is a consolidated one.   
--
-- Parameters:
--       None.
--
-- Returns :
--       TRUE if the database is a consolidated one, FALSE otherwise. 
--
-- Notes:
----------------------------------------------------------
FUNCTION isCDB RETURN boolean;

----------------------------------------------------------
--
-- FUNCTION   updateChunks 
--
-- Description:
--        Refresh RDBMS chunks cache   
--
-- Parameters:
--       None.
--
-- Returns :
--       NONE
--
-- Notes:
----------------------------------------------------------
PROCEDURE updateChunks;


-----------------------------------------------------------------------------
--  
-- FUNCTION  num2linear
--  
-- Description: function to convert numbers to linear key representation
--  
-- Parameters: 
--  x - number
--  
--  
-- Notes:
--  
FUNCTION  num2linear(x number) return blob;

--*****************************************************************************
-- End of Package Public Procedures
--*****************************************************************************

END dbms_gsm_common;
/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
