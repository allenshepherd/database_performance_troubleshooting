Rem
Rem $Header: rdbms/admin/dbmssrv.sql /main/50 2017/08/24 16:07:43 sroesch Exp $
Rem
Rem dbmssrv.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssrv.sql - DBMS_SERVICE and DBMS_SERVICE_PRVT definition
Rem
Rem    DESCRIPTION
Rem      Database services PL/SQL component.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmssrv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmssrv.sql
Rem SQL_PHASE: DBMSSRV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sroesch     07/11/17 - Bug 25944015: Raise internal error when stopping
Rem                                         an internal service
Rem    sroesch     07/03/17 - Bug 26272761: Fix service$ table during upgrade
Rem    sroesch     06/17/16 - Bug 23595546: Add constant for failover type
Rem                                         transaction
Rem    sroesch     09/04/15 - Bug 20826689: Add replay param to stop svc api
Rem    sroesch     08/05/15 - Bug 20232451: Merge service fields in ksuse struct
Rem    raeburns    06/09/15 - Use FORCE for types with only type dependents
Rem    sroesch     06/15/14 - Bug 21135251: Fix remote service stop
Rem    sroesch     05/04/15 - OJVM patching phase 2
Rem    sroesch     02/02/14 - Bug 20418865: Change failover restore parameter
Rem                                         from basic to level1
Rem    sroesch     01/19/14 - Bug 20319989: Make draining timeout a svc attribute
Rem    sroesch     12/18/14 - Add drain timeout to stop service procedure
Rem    sroesch     08/03/14 - Bug 19352936: Add topology interface to dbms_service
Rem    sroesch     06/11/14 - Add topology function
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sdball      06/20/13 - Bug 16619292: Resize svc_parameter_array type for
Rem                           longer parameter values
Rem    sroesch     03/21/13 - Bug 16471429: Should check case and db_domain
Rem                           when creating services
Rem    sroesch     12/26/12 - XbranchMerge sroesch_read_failure from
Rem                           st_rdbms_12.1.0.1
Rem    sroesch     12/17/12 - Bug 15998731: replace ORA-600
Rem                           [KSWSIMS_CHANGE:LOAD FAILED] with user error
Rem                           ORA-1013
Rem    sroesch     12/10/12 - XbranchMerge sroesch_bug-15882421 from main
Rem    sroesch     12/06/12 - Bug 15882421: Failure during migration to cdb
Rem    sroesch     07/26/12 - Bug 14313139: Add no replay option to
Rem                                         disconnect_session
Rem    sroesch     07/01/12 - Bug 14228184: Disable setting commit_outcome on
Rem                                         db svc and connecting with sysdba
Rem    sroesch     06/13/12 - Bug 13454604: Add node name parameter to start
Rem                                         and stop service
Rem    sroesch     06/11/12 - Bug 14157055: Prohibit deleting internal+db svcs
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sroesch     01/31/12 - Bug 13646589: Remove pdb parameter from old api
Rem    skyathap    11/03/11 - support service_context for dbms_service_prvt
Rem    sroesch     09/08/11 - Support Import of CRS service during PDB plug
Rem    sroesch     08/24/11 - LRG 5834587: delete old service on PDB unplug
Rem    sroesch     08/21/11 - Bug : always update cdb_service$
Rem    sroesch     06/28/11 - add pdb service integration
Rem    sroesch     02/25/11 - add private package for GSM
Rem    sroesch     01/03/11 - add new service attributes
Rem    pyam        11/22/10 - pdb as service attribute
Rem    achoi       09/21/09 - edition as service attribute
Rem    bnnguyen    05/09/08 - bug6665906
Rem    rburns      05/06/06 - split package body
Rem    sltam       04/19/06 - Bug 5171189: pass option to disconnect_session
Rem    dsemler     04/19/05 - correct error handling
Rem    dsemler     01/19/05 - add handling for db readonly
Rem    sourghos    12/30/04 - Fix bug 4043119
Rem    dsemler     06/03/04 - add taf and ha aq attributes to create and
Rem                           modify
Rem    dsemler     06/03/04 - update header for the ability to start/stop all
Rem                           service members
Rem    dsemler     05/14/04 - add dtp support,
Rem    dsemler     04/30/04 - remove goodness goal, add none
Rem    dsemler     04/13/04 - change create_service, add goal arg, create
Rem    dsemler     04/19/04 - remove default NULL on create_service
Rem                           network_name argument
Rem    sltam       07/21/03 - Fix bug 3013804, db_domain will not be appended
Rem                           to service_name in disconnect_session()
Rem    sltam       04/30/03 - bug2935173: Remove SET statements
Rem    dsemler     02/03/03 -
Rem    dsemler     12/06/02 -
Rem    dsemler     11/22/02 - create, delete, start and stop added
Rem    sltam       01/16/03 - fix bug 2754447
Rem    sltam       10/14/02 - sltam_rdbms10i_dbmssrv
Rem    sltam       10/11/02 -
Rem    sltam       10/04/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Create object and varray for name-value pair pl/sql api of
Rem package dbms_service
CREATE OR REPLACE TYPE svc_parameter_t FORCE IS OBJECT (param_name  VARCHAR2(100),
                                                  param_value VARCHAR2(100));
/

CREATE OR REPLACE TYPE svc_parameter_list_t IS VARRAY(100) OF svc_parameter_t;
/

CREATE OR REPLACE LIBRARY dbms_service_lib TRUSTED IS STATIC;
/

CREATE OR REPLACE PACKAGE dbms_service as

 ------------
 --  OVERVIEW
 --
 --  This package allows an application to manage services and sessions
 --  connected with a specific service name.
 --
 --  Oracle Real Application Cluster (RAC) has a functionality to manage
 --  service names across instances. This package allows the creation,
 --  deletion, starting and stopping of services in both RAC and single
 --  instance. 
 --  Additionally it provides the ability to disconnect all sessions which 
 --  connect to the instance with a service name when RAC removes that 
 --  service name from the instance.

 ----------------
 --  INSTALLATION
 --
 --  This package should be installed under SYS schema.
 --
 --  SQL> @dbmssrv
 --
 -----------
 --  EXAMPLE
 --
 --  Disconnect all sessions in the local instance which connected
 --  using service name foo.us.oracle.com.
 --
 --    dbms_service.disconnect_session('foo.us.oracle.com');
 --
 --  dbms_service.disconnect_session() does not return until all
 --  corresponding sessions disconnected. Therefore, dbms_job package or
 --  put the SQL session in background if the caller does not want to
 --  wait for all corresponding sessions disconnected.
 --
 --  An option can be passed to disconnect_session(). If option is
 --  dbms_service.disconnect_session_immediate, sessions will be 
 --  disconnected immediately.
 --
 --    dbms_service.disconnect_session('foo.us.oracle.com', 
 --                                      dbms_service.immediate);
 --

 --------------------------
 --  IMPLEMENTATION DETAILS
 --
 --  dbms_service.disconnect_session() calls SQL statement
 --
 --    ALTER SYSTEM DISCONNECT SESSION sid, serial option
 --
 --  The default value of option is POST_TRANSCATION.
 -- 
 --  
 ------------
 --  SECURITY
 --
 --  The execute privilage of the package is granted to DBA role only.

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  -- Options for disconnect session
  post_transaction CONSTANT NUMBER := 0;
  immediate        CONSTANT NUMBER := 1;
  noreplay         CONSTANT NUMBER := 2;

  PROCEDURE tag_session(service_name IN VARCHAR2,
                        guid         IN VARCHAR2);
  -- Tag all sessions connected with a specific service with a GUID.
  --
  --  Input parameter(s):
  --    service_name
  --      service name of the sessions to be tagged. 
  --    guid
  --      Mark the sessions with a guid

  PROCEDURE disconnect_session(service_name      IN VARCHAR2,
                               disconnect_option IN NUMBER
                                                 DEFAULT post_transaction,
                               guid              IN VARCHAR2 DEFAULT NULL);
  --  Disconnect sessions which connect to the local instance with
  --  the specified service name.
  --
  --  Input parameter(s):
  --    service_name
  --      service name of the sessions to be disconnected. 
  --    disconnect_option
  --      option to be passed to 'alter system disconnect session'.
  --      its value can be dbms_service.post_transaction,
  --      dbms_service.immediate or dbms_session.noreplay.
  --
  --      post_transaction : wait for current transaction to complete
  --      immediate        : disconnect session immediately
  --      noreplay         : disconnect session immediately and current
  --                         transaction will not be replayed if
  --                         application continuity is enabled.
  --
  --      The default value is dbms_service.post_transaction
  --    guid
  --      Mark the sessions with a guid before invoking disconnect session

  procedure kill_session(service_name  in varchar2,
                         kill_option   in number default immediate);
  --  Kill sessions which connect to the local instance with
  --  the specified service name.
  --
  --  Input parameter(s):
  --    service_name - Sessions belonging to this service will be killed
  --    kill_option  - How to kill the session
  --      immediate        : disconnect session immediately
  --      noreplay         : disconnect session immediately and current
  --                         transaction will not be replayed if
  --                         application continuity is enabled.

  type svc_parameter_array is table of varchar2(100) index by varchar2(100);

  PROCEDURE create_service(service_name    IN VARCHAR2,
                           network_name    IN VARCHAR2,
                           parameter_array IN svc_parameter_array);
  --  Creates a new service$ entry for this service name
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    network_name
  --      the full network name for the service. This will usually be the same
  --      as the service_name.
  --    parameter_array
  --      associative array with name/value pairs of the service attributes.
  --      The following list describes the supported names.
  --
  --      goal
  --        the workload management goal directive of the service. Valid values
  --        are : DBMS_SERVICE.GOAL_SERVICE_TIME,
  --              DBMS_SERVICE.GOAL_THROUGHPUT,
  --              DBMS_SERVICE.GOAL_NONE.
  --      dtp 
  --        declares the service to be for DTP or distributed transactions.
  --      aq_ha_notifications
  --        determines whether HA events are sent via AQ for this service.
  --      failover_method
  --        the TAF failover method for the service
  --      failover_type
  --        the TAF failover type for the service
  --      failover_retries
  --        the TAF failover retries for the service
  --      failover_delay
  --        the TAF failover delay for the service
  --      edition
  --        the initial session edition
  --      commit_outcome
  --        persist outcome of transactions
  --      retention_timeout
  --        timeout when the transaction outcome is retained
  --      replay_initiation_timeout
  --        timeout when replayed is disabled
  --      session_state_consistency
  --        Consistency of session state: static or dynamic
  --      sql_translation_name
  --        Name of SQL translation unit

  PROCEDURE create_service(service_name        IN VARCHAR2, 
                           network_name        IN VARCHAR2,
                           goal                IN NUMBER   DEFAULT NULL,
                           dtp                 IN BOOLEAN  DEFAULT NULL,
                           aq_ha_notifications IN BOOLEAN  DEFAULT NULL,
                           failover_method     IN VARCHAR2 DEFAULT NULL,
                           failover_type       IN VARCHAR2 DEFAULT NULL,
                           failover_retries    IN NUMBER   DEFAULT NULL,
                           failover_delay      IN NUMBER   DEFAULT NULL,
                           clb_goal            IN NUMBER   DEFAULT NULL,
                           edition             IN VARCHAR2 DEFAULT NULL);
  --  Creates a new service$ entry for this service name
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    net_name
  --      the full network name for the service. This will usually be the same
  --      as the service_name.
  --    goal
  --      the workload management goal directive for the service. Valid values
  --      are : DBMS_SERVICE.GOAL_SERVICE_TIME,
  --            DBMS_SERVICE.GOAL_THROUGHPUT,
  --            DBMS_SERVICE.GOAL_NONE.
  --    dtp 
  --      declares the service to be for DTP or distributed transactions.
  --    aq_ha_notifications
  --      determines whether HA events are sent via AQ for this service.
  --    failover_method
  --      the TAF failover method for the service
  --    failover_type
  --      the TAF failover type for the service
  --    failover_retries
  --      the TAF failover retries for the service
  --    failover_delay
  --      the TAF failover delay for the service
  --    edition
  --      the initial session edition

  PROCEDURE modify_service(service_name    IN VARCHAR2,
                           parameter_array IN svc_parameter_array);
  --  Modifies an existing service
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    parameter_array
  --      associative array with name/value pairs of the service attributes.
  --      The following list describes the supported names.
  --
  --      goal
  --        the workload management goal directive of the service. Valid values
  --        defined under create_service above.
  --      dtp 
  --        declares the service to be for DTP or distributed transactions.
  --      aq_ha_notifications
  --        determines whether HA events are sent via AQ for this service.
  --      failover_method
  --        the TAF failover method for the service
  --      failover_type
  --        the TAF failover type for the service
  --      failover_retries
  --        the TAF failover retries for the service
  --      failover_delay
  --        the TAF failover delay for the service
  --      edition
  --        the initial session edition
  --      commit_outcome
  --        persist outcome of transactions
  --      retention_timeout
  --        timeout when the transaction outcome is retained
  --      replay_initiation_timeout
  --        timeout when replayed is disabled
  --      session_state_consistency
  --        Consistency of session state: static or dynamic
  --      sql_translation_name
  --        Name of SQL translation unit

  PROCEDURE modify_service(service_name        IN VARCHAR2,
                           goal                IN NUMBER   DEFAULT NULL,
                           dtp                 IN BOOLEAN  DEFAULT NULL,
                           aq_ha_notifications IN BOOLEAN  DEFAULT NULL,
                           failover_method     IN VARCHAR2 DEFAULT NULL,
                           failover_type       IN VARCHAR2 DEFAULT NULL,
                           failover_retries    IN NUMBER   DEFAULT NULL,
                           failover_delay      IN NUMBER   DEFAULT NULL,
                           clb_goal            IN NUMBER   DEFAULT NULL,
                           edition             IN VARCHAR2 DEFAULT NULL,
                           modify_edition      IN BOOLEAN  DEFAULT FALSE);
  --  Modifies an existing service
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    goal
  --      the workload management goal directive for the service. Valid values
  --      defined under create_service above.
  --    dtp 
  --      declares the service to be for DTP or distributed transactions.
  --    aq_ha_notifications
  --      determines whether HA events are sent via AQ for this service.
  --    failover_method
  --      the TAF failover method for the service
  --    failover_type
  --      the TAF failover type for the service
  --    failover_retries
  --      the TAF failover retries for the service
  --    failover_delay
  --      the TAF failover delay for the service
  --    edition
  --      the initial session edition
  --    modify_edition
  --      true if edition is to be modified

  PROCEDURE delete_service(service_name IN VARCHAR2);
  --  Marks a service$ entry as deleted.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.

  PROCEDURE start_service(service_name  IN VARCHAR2,
                          instance_name IN VARCHAR2 DEFAULT NULL);
  --  In single instance exclusive alters the service_name IOP to contain
  --  this service_name. In RAC will optionally on the instance specified.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    instance_name 
  --      The instance on which to start the service. NULL results in starting
  --      of the service on the local instance.
  --      In single instance this can only be the current 
  --      instance or NULL.
  --      Specify DBMS_SERVICE.ALL_INSTANCES to start the service on all
  --      configured instances.

  PROCEDURE stop_service(service_name  IN VARCHAR2, 
                         instance_name IN VARCHAR2 DEFAULT NULL,
                         stop_option   IN VARCHAR2 DEFAULT NULL,
                         drain_timeout IN NUMBER   DEFAULT NULL,
                         replay        IN BOOLEAN  DEFAULT TRUE);
  --  In single instance exclusive alters the service_name IOP to remove
  --  this service_name. In RAC will call out to CRS to stop the service
  --  optionally on the instance specified. Calls clscrs_stop_resource.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    instance_name 
  --      The instance on which to stop the service. NULL results in stopping
  --      of the service locally.
  --      In single instance this can only be the current 
  --      instance or NULL. The default in RAC and exclusive case is NULL.
  --      Specify DBMS_SERVICE.ALL_INSTANCES to start the service on all
  --      configured instances.
  --    stop_option
  --      Specifies how the sessions connected to the service should be stopped.
  --    drain_timeout
  --      Specifies if the stop command should allow the sessions to drain and
  --      if they do not drain, to kill them. This parameter specifies how long
  --      the sessions have time to drain.
  --    replay
  --      Enable application continuity replay 
  -------------
  --  CONSTANTS
  --

  --  Constants for use in calling arguments.
  goal_none                 CONSTANT NUMBER := 0;
  goal_service_time         CONSTANT NUMBER := 1;
  goal_throughput           CONSTANT NUMBER := 2;

  all_instances             CONSTANT VARCHAR2(2) := '*';

  -- Connection Balancing Goal arguments
  clb_goal_short            CONSTANT NUMBER := 1;
  clb_goal_long             CONSTANT NUMBER := 2;

  -- TAF failover attribute arguments
  failover_method_none      CONSTANT VARCHAR2(5)  := 'NONE';
  failover_method_basic     CONSTANT VARCHAR2(6)  := 'BASIC';

  failover_type_none        CONSTANT VARCHAR2(5)  := 'NONE';
  failover_type_session     CONSTANT VARCHAR2(8)  := 'SESSION';
  failover_type_select      CONSTANT VARCHAR2(7)  := 'SELECT';
  failover_type_transaction CONSTANT VARCHAR2(12) := 'TRANSACTION';

  failover_restore_none     CONSTANT VARCHAR2(5)  := 'NONE';
  failover_restore_basic    CONSTANT VARCHAR2(7)  := 'LEVEL1';

  -- Stop option attribute arguments
  stop_option_none          CONSTANT VARCHAR2(5)  := 'NONE';
  stop_option_immediate     CONSTANT VARCHAR2(10) := 'IMMEDIATE';
  stop_option_transactional CONSTANT VARCHAR2(14) := 'TRANSACTIONAL';

  -------------------------
  --  ERRORS AND EXCEPTIONS
  --
  --  When adding errors remember to add a corresponding exception below.

  err_null_service_name       CONSTANT NUMBER := -44301;
  err_null_network_name       CONSTANT NUMBER := -44302;
  err_service_exists          CONSTANT NUMBER := -44303;
  err_service_does_not_exist  CONSTANT NUMBER := -44304;
  err_service_in_use          CONSTANT NUMBER := -44305;
  err_service_name_too_long   CONSTANT NUMBER := -44306;
  err_network_prefix_too_long CONSTANT NUMBER := -44307;
  err_not_initialized         CONSTANT NUMBER := -44308;
  err_general_failure         CONSTANT NUMBER := -44309;
  err_max_services_exceeded   CONSTANT NUMBER := -44310;
  err_service_not_running     CONSTANT NUMBER := -44311;
  err_database_closed         CONSTANT NUMBER := -44312;
  err_invalid_instance        CONSTANT NUMBER := -44313;
  err_network_exists          CONSTANT NUMBER := -44314;
  err_null_attributes         CONSTANT NUMBER := -44315;
  err_invalid_argument        CONSTANT NUMBER := -44316;
  err_database_readonly       CONSTANT NUMBER := -44317;
  err_max_sn_length           CONSTANT NUMBER := -44318;
  err_aq_service              CONSTANT NUMBER := -44319;
  err_glb_service             CONSTANT NUMBER := -44320;
  err_invalid_pdb_name        CONSTANT NUMBER := -44771;
  err_crs_api                 CONSTANT NUMBER := -44772;
  err_pdb_closed              CONSTANT NUMBER := -44773;
  err_pdb_invalid             CONSTANT NUMBER := -44774;
  err_pdb_name                CONSTANT NUMBER := -44775;
  err_pdb_exp                 CONSTANT NUMBER := -44776;
  err_pdb_fail                CONSTANT NUMBER := -44777;
  err_tg_rettm                CONSTANT NUMBER := -44778;
  err_tg_repto                CONSTANT NUMBER := -44779;
  err_tg_co                   CONSTANT NUMBER := -44780;
  err_tg_aq                   CONSTANT NUMBER := -44781;
  err_crs_fail                CONSTANT NUMBER := -44782;
  err_mxrlbsvc                CONSTANT NUMBER := -44783;
  err_delint                  CONSTANT NUMBER := -44784;
  err_tg_dbsvc                CONSTANT NUMBER := -44785;
  err_pdb_imp                 CONSTANT NUMBER := -44786;
  err_inv_stop                CONSTANT NUMBER := -44791;
  err_stop_intl               CONSTANT NUMBER := -44793;
  err_intr                    CONSTANT NUMBER :=  -1013;

  null_service_name           EXCEPTION;
  null_network_name           EXCEPTION;
  service_exists              EXCEPTION;
  service_does_not_exist      EXCEPTION;
  service_in_use              EXCEPTION;
  service_name_too_long       EXCEPTION;
  network_prefix_too_long     EXCEPTION;
  not_initialized             EXCEPTION;
  general_failure             EXCEPTION;
  max_services_exceeded       EXCEPTION;
  service_not_running         EXCEPTION;
  database_closed             EXCEPTION;
  invalid_instance            EXCEPTION;
  network_exists              EXCEPTION;
  null_attributes             EXCEPTION;
  invalid_argument            EXCEPTION;
  database_readonly           EXCEPTION;
  max_sn_length               EXCEPTION;
  aq_service                  EXCEPTION;
  glb_service                 EXCEPTION;
  invalid_pdb_name            EXCEPTION;
  crs_api_failed              EXCEPTION;
  pdb_closed                  EXCEPTION;
  pdb_invalid                 EXCEPTION;
  pdb_name                    EXCEPTION;
  pdb_exp                     EXCEPTION;
  pdb_fail                    EXCEPTION;
  tg_rettm                    EXCEPTION;
  tg_repto                    EXCEPTION;
  tg_co                       EXCEPTION;
  tg_aq                       EXCEPTION;
  crs_fail                    EXCEPTION;
  mxrlbsvc                    EXCEPTION;
  delint                      EXCEPTION;
  tg_dbsvc                    EXCEPTION;
  pdb_imp                     EXCEPTION;
  inv_stop                    EXCEPTION;
  stop_intl                   EXCEPTION;
  intr                        EXCEPTION;

  PRAGMA EXCEPTION_INIT(null_service_name,       -44301);
  PRAGMA EXCEPTION_INIT(null_network_name,       -44302);
  PRAGMA EXCEPTION_INIT(service_exists,          -44303);
  PRAGMA EXCEPTION_INIT(service_does_not_exist,  -44304);
  PRAGMA EXCEPTION_INIT(service_in_use,          -44305);
  PRAGMA EXCEPTION_INIT(service_name_too_long,   -44306);
  PRAGMA EXCEPTION_INIT(network_prefix_too_long, -44307);
  PRAGMA EXCEPTION_INIT(not_initialized,         -44308);
  PRAGMA EXCEPTION_INIT(general_failure,         -44309);
  PRAGMA EXCEPTION_INIT(max_services_exceeded,   -44310);
  PRAGMA EXCEPTION_INIT(service_not_running,     -44311);
  PRAGMA EXCEPTION_INIT(database_closed,         -44312);
  PRAGMA EXCEPTION_INIT(invalid_instance,        -44313);
  PRAGMA EXCEPTION_INIT(network_exists,          -44314);
  PRAGMA EXCEPTION_INIT(null_attributes,         -44315);
  PRAGMA EXCEPTION_INIT(invalid_argument,        -44316);
  PRAGMA EXCEPTION_INIT(database_readonly,       -44317);
  PRAGMA EXCEPTION_INIT(max_sn_length,           -44318);
  PRAGMA EXCEPTION_INIT(aq_service,              -44319);
  PRAGMA EXCEPTION_INIT(glb_service,             -44320);
  PRAGMA EXCEPTION_INIT(invalid_pdb_name,        -44771);
  PRAGMA EXCEPTION_INIT(crs_api_failed,          -44772);
  PRAGMA EXCEPTION_INIT(pdb_closed,              -44773);
  PRAGMA EXCEPTION_INIT(pdb_invalid,             -44774);
  PRAGMA EXCEPTION_INIT(pdb_name,                -44775);
  PRAGMA EXCEPTION_INIT(pdb_exp,                 -44776);
  PRAGMA EXCEPTION_INIT(pdb_fail,                -44777);
  PRAGMA exception_init(tg_rettm,                -44778);
  PRAGMA EXCEPTION_INIT(tg_repto,                -44779);
  PRAGMA EXCEPTION_INIT(tg_co,                   -44780);
  PRAGMA EXCEPTION_INIT(tg_aq,                   -44781);
  PRAGMA EXCEPTION_INIT(crs_fail,                -44782);
  PRAGMA EXCEPTION_INIT(mxrlbsvc,                -44783);
  PRAGMA EXCEPTION_INIT(delint,                  -44784);
  PRAGMA EXCEPTION_INIT(tg_dbsvc,                -44785);
  PRAGMA EXCEPTION_INIT(pdb_imp,                 -44786);
  PRAGMA EXCEPTION_INIT(inv_stop,                -44791);
  PRAGMA EXCEPTION_INIT(stop_intl,               -44793);
  PRAGMA EXCEPTION_INIT(intr,                     -1013);

END dbms_service;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_service FOR dbms_service
/
 ---------------------------------
 --
 -- Grant only to DBA role
 --

GRANT EXECUTE ON dbms_service TO dba
/



CREATE OR REPLACE LIBRARY dbms_service_prvt_lib TRUSTED IS STATIC;
/

CREATE OR REPLACE PACKAGE dbms_service_prvt AS

 ------------
 --  OVERVIEW
 --
 --  This package allows an application to manage services and sessions
 --  connected with a specific service name. The difference to the previous
 --  package is that additional parameters like the global flag can be set.
 --
 --  Oracle Real Application Cluster (RAC) has a functionality to manage
 --  service names across instances. This package allows the creation,
 --  deletion,starting and stopping of services in both RAC and single
 --  instance. 
 --  Additionally it provides the ability to disconnect all sessions which 
 --  connect to the instance with a service name when RAC removes that 
 --  service name from the instance.

 ----------------
 --  CAUTION
 --
 -- This package was specifically defined with GSM in mind. Prospective users
 -- are advised to talk to the file owener before using this package.
 
 ----------------
 --  INSTALLATION
 --
 --  This package should be installed under SYS schema.
 --
 --  SQL> @dbmssrv
 --

 ------------
 --  SECURITY
 --
 --  The execute privilage of the package is granted to DBA role only.

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  TYPE svc_parameter_array IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);

  FUNCTION get_topology(service_name IN VARCHAR2) RETURN VARCHAR2;
  -- The topology function returns on which instances the specified service is
  -- currently active.
  --
  -- Input parameter(s):
  --   service_name for which to retrieve the topology

  PROCEDURE create_service(service_name        IN VARCHAR2,
                           network_name        IN VARCHAR2,
                           cluster_attributes  IN svc_parameter_array,
                           db_attributes       IN svc_parameter_array,
                           is_called_by_crs    IN BOOLEAN DEFAULT FALSE,
                           srvc_context        IN NUMBER DEFAULT 1);
  --  Creates a new service$ entry for this service name
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    network_name
  --      the full network name for the service. This will usually be the same
  --      as the service_name.
  --    cluster_attributes
  --      associative array with name/value pairs of the crs service
  --      attributes. The following list describes the supported names.
  --
  --      preferred_all 
  --        All databases in the pool are preferred
  --      preferred
  --        A comma separated list of preferred databases
  --      available
  --        A comma separated list of available databases
  --      locality
  --        Service region locality. Must be ANYWHERE or LOCAL_ONLY
  --      region_failover
  --        service is enabled for region failover
  --      role
  --        Database role the database must be in to start this service. 
  --        This only applies to database pools that have a data guard broker
  --        configuration.
  --      failover_primary
  --        Enable service to failover to primary. This is only applicable to
  --        services with the role PHYSICAL_STANDBY.
  --      lag
  --        Specifes the lag of the service.
  --      tafpolicy
  --        TAF client policy
  --      policy
  --        Management policy for the service. Can be automatic or manual.
  --    db_attributes
  --      associative array with name/value pairs of the database service 
  --      attributes. The following list describes the supported names.
  --
  --      goal
  --        the workload management goal directive of the service. Valid values
  --        are : DBMS_SERVICE.GOAL_SERVICE_TIME,
  --              DBMS_SERVICE.GOAL_THROUGHPUT,
  --              DBMS_SERVICE.GOAL_NONE.
  --      dtp 
  --        declares the service to be for DTP or distributed transactions.
  --      aq_ha_notifications
  --        determines whether HA events are sent via AQ for this service.
  --      failover_method
  --        the TAF failover method for the service
  --      failover_type
  --        the TAF failover type for the service
  --      failover_retries
  --        the TAF failover retries for the service
  --      failover_delay
  --        the TAF failover delay for the service
  --      edition
  --        the initial session edition
  --      pdb
  --        the initial pdb
  --      commit_outcome
  --        persist outcome of transactions
  --      retention_timeout
  --        timeout when the transaction outcome is retained
  --      replay_initiation_timeout
  --        timeout when replayed is disabled
  --      session_state_consistency
  --        Consistency of session state: static or dynamic
  --      sql_translation_name
  --        Name of SQL translation unit
  --      global
  --        global service
  --    is_called_by_crs
  --        Is this function invoked by CRS? (MUST ONLY BE SET BY CRS)
  --    srvc_context
  --        which service context does this apply to (DB &/or OCR)?

  PROCEDURE modify_service(service_name        IN VARCHAR2,
                           cluster_attributes  IN svc_parameter_array,
                           db_attributes       IN svc_parameter_array,
                           is_called_by_crs    IN BOOLEAN DEFAULT FALSE,
                           srvc_context        IN NUMBER DEFAULT 1);
  --  Modifies an existing service
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    cluster_attributes
  --      associative array with name/value pairs of the crs service
  --      attributes. The following list describes the supported names.
  --
  --      preferred_all 
  --        All databases in the pool are preferred
  --      preferred
  --        A comma separated list of preferred databases
  --      available
  --        A comma separated list of available databases
  --      locality
  --        Service region locality. Must be ANYWHERE or LOCAL_ONLY
  --      region_failover
  --        service is enabled for region failover
  --      role
  --        Database role the database must be in to start this service. 
  --        This only applies to database pools that have a data guard broker
  --        configuration.
  --      failover_primary
  --        Enable service to failover to primary. This is only applicable to
  --        services with the role PHYSICAL_STANDBY.
  --      lag
  --        Specifes the lag of the service.
  --      tafpolicy
  --        TAF client policy
  --      policy
  --        Management policy for the service. Can be automatic or manual.
  --    db_attributes
  --      associative array with name/value pairs of the database service 
  --      attributes. The following list describes the supported names.
  --
  --      goal
  --        the workload management goal directive of the service. Valid values
  --        defined under create_service above.
  --      dtp 
  --        declares the service to be for DTP or distributed transactions.
  --      aq_ha_notifications
  --        determines whether HA events are sent via AQ for this service.
  --      failover_method
  --        the TAF failover method for the service
  --      failover_type
  --        the TAF failover type for the service
  --      failover_retries
  --        the TAF failover retries for the service
  --      failover_delay
  --        the TAF failover delay for the service
  --      edition
  --        the initial session edition
  --      pdb
  --        the new pdb
  --      commit_outcome
  --        persist outcome of transactions
  --      retention_timeout
  --        timeout when the transaction outcome is retained
  --      replay_initiation_timeout
  --        timeout when replayed is disabled
  --      session_state_consistency
  --        Consistency of session state: static or dynamic
  --      sql_translation_name
  --        Name of SQL translation unit
  --    is_called_by_crs
  --        Is this function invoked by CRS? (MUST ONLY BE SET BY CRS)
  --    srvc_context
  --        which service context does this apply to (DB &/or OCR)?

  PROCEDURE delete_service(service_name     IN VARCHAR2,
                           is_called_by_crs IN BOOLEAN DEFAULT FALSE,
                           srvc_context     IN NUMBER DEFAULT 1);
  --  Marks a service$ entry as deleted.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    is_called_by_crs
  --        Is this function invoked by CRS? (MUST ONLY BE SET BY CRS)
  --    srvc_context
  --        which service context does this apply to (DB &/or OCR)?

  PROCEDURE start_service(service_name     IN VARCHAR2,
                          all_nodes        IN BOOLEAN DEFAULT FALSE,
                          is_called_by_crs IN BOOLEAN DEFAULT FALSE);
  --  In single instance starts the service with this service_name.
  --  In RAC will optionally start the service only on the instance specified.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    all_nodes
  --      Where shall the service be started? FALSE results in starting the
  --      the service on the local node.
  --      In single instance this can only be the current 
  --      instance or FALSE.
  --      Specify TRUE to start the service on all configured nodes.
  --    is_called_by_crs
  --      Is this function invoked by CRS? (MUST ONLY BE SET BY CRS)

  PROCEDURE stop_service(service_name     IN VARCHAR2, 
                         all_nodes        IN BOOLEAN  DEFAULT FALSE,
                         is_called_by_crs IN BOOLEAN  DEFAULT FALSE,
                         stop_option      IN VARCHAR2 DEFAULT NULL,
                         drain_timeout    IN NUMBER   DEFAULT NULL,
                         replay           IN BOOLEAN  DEFAULT TRUE);
  --  In single instance it stops the service specified by service_name.
  --  In RAC will call out to CRS to stop the service, optionally on the
  --  instance specified. Calls clscrs_stop_resource.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    all_nodes
  --      Where shall the service be stopped? FALSE results in stopping the
  --      the service on the local node.
  --      In single instance this can only be the current instance or FALSE.
  --      Specify TRUE to stop the service on all configured nodes.
  --    is_called_by_crs
  --      Is this function invoked by CRS? (MUST ONLY BE SET BY CRS)
  --    stop_option
  --      Specifies how the sessions connected to the service should be stopped.
  --    drain_timeout
  --      Specifies if the stop command should allow the sessions to drain and
  --      if they do not drain, to kill them. This parameter specifies how long
  --      the sessions have time to drain.
  --    replay
  --      Enable application continuity replay

  PROCEDURE rename_pdb_attribute(pdb_name     IN VARCHAR2,
                                 new_pdb_name IN VARCHAR2);
  -- Changes the pdb_name of all qualifying services to new_pdb_name
  -- Input parameter(s):
  --   pdb_name
  --     current pdb name
  --   new_pdb_name
  --     new pdb name


  FUNCTION is_java_service(service_name IN VARCHAR2) RETURN BOOLEAN;
  -- Returns TRUE if any of the session connected with this service have ever
  -- used java in the database.
  --
  -- Input parameters:
  --   service_name
  --     Name of the service to be queried

  FUNCTION get_hash(svc_name IN VARCHAR2) RETURN NUMBER;
  -- Computes the hash value for a service name

  PROCEDURE migrate_to_12_2;
  -- Updates the service data dictionary tables to 12.2.

END dbms_service_prvt;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_service_prvt FOR dbms_service_prvt
/
 ---------------------------------
 --
 -- Grant only to DBA role
 --

GRANT EXECUTE ON dbms_service_prvt TO dba
/


@?/rdbms/admin/sqlsessend.sql
