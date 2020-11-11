Rem
Rem $Header: rdbms/admin/dbmsgwmdb.sql /main/40 2017/04/26 15:38:34 itaranov Exp $
Rem
Rem dbmsgsmdb.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwsmdb.sql - Global Workload Management DataBase administration 
Rem
Rem    DESCRIPTION
Rem      Defines the interface for dbms_gsm_dbadmin package that is used for 
Rem      database administration performed by GSM 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmdb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmdb.sql
Rem SQL_PHASE: DBMSGWMDB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    itaranov    04/04/17 - restore chunk additional parameter
Rem    itaranov    12/13/16 - Bug 24695992: Chunk split native code impl via kkpo
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    itaranov    06/09/16 - Add set ddl timout safe wrapper
Rem    lenovak     06/08/16 - project 62462 Sharding for RAC affinity
Rem    itaranov    05/05/16 - remove groundts since its private
Rem    itaranov    05/05/16 - restore chunk
Rem    itaranov    04/28/16 - restoreChunk for test purposes
Rem    lenovak     03/23/16 - bugfix 22912460
Rem    lenovak     02/22/16 - gdsctloutput for catalog_requests
Rem    itaranov    02/17/16 - Split chunk ids, amend
Rem    itaranov    12/07/15 - Move num2linear
Rem    dcolello    10/24/15 - sharding object rename for production
Rem    sdball      10/09/15 - Bug 21967902: Add GWM_RAC_SIHA
Rem    lenovak     08/31/15 - remove sendFile API
Rem    sdball      06/10/15 - Support for long identifiers
Rem    ralekra     03/24/15 - Add support for OGG replication
Rem    sdball      03/11/15 - Add executeGenericProcedure
Rem    ditalian    01/29/15 - add split chunk
Rem    lenovak     10/24/14 - Add setCatalogLink.
Rem    nbenadja    09/12/14 - Add getgroundTS().
Rem    itaranov    01/30/14 - Add setChunks procedure
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    sdball      08/26/13 - LRG 9180681: callSrvctl does not need to be
Rem                           public
Rem    sdball      08/15/13 - Add db_type to getHostInfo
Rem    sdball      08/09/13 - add inst_list to startService
Rem    lenovak     07/29/13 - shard support
Rem    lenovak     07/11/13 - validate cloud name before adding to catalog
Rem    itaranov    03/19/13 - Add sync function
Rem    sdball      03/18/13 - Changes to support admin managed databases
Rem    sdball      03/05/13 - New parameter for removeDatabase
Rem    nbenadja    01/11/13 - Store CPU and IO threshold in the GDS catalog.
Rem    sdball      01/11/13 - Bug 16013287: stop service "force" flag is not
Rem                           correctly handled
Rem    itaranov    11/01/12 - Split modifyService in two functions
Rem    sdball      06/13/12 - Support for number of instances
Rem    sdball      04/24/12 - Support for cross-chck verification
Rem    sdball      03/26/12 - Change addDatabase params
Rem    sdball      11/30/11 - Auto VNCR functionality
Rem    zzeng       11/21/11 - Change default for proxy_db,delete_to_move to 0
Rem    skyathap    11/10/11 - add proxy info to service routines
Rem    nbenadja    10/28/11 - Add revomeAllServices procedure
Rem    mdilman     10/24/11 - add proxy_database and primary_database params
Rem    mdilman     08/11/11 - add getCRSinfo
Rem    skyathap    08/10/11 - Add locality info to service routines
Rem    mdilman     07/26/11 - add modifyGSM and modifyDatabase
Rem    mdilman     07/09/11 - add RAC specific service attributes
Rem    mjstewar    04/27/11 - Second GSM transaction
Rem    lenovak     03/01/11 - remove and validate procedures  
Rem    mdilman     02/07/11 - add procedures
Rem    mjstewar    02/02/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL dbmsgwmdb.log

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Database package for GSM pool database functions.
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_dbadmin AS
--*****************************************************************************
-- Private Types
--*****************************************************************************
TYPE target IS RECORD (db_name varchar2(dbms_gsm_common.max_ident), 
                       conn_id varchar2(512), 
                       role varchar2(30), 
                       dblink varchar2(256), 
                       jobid number);
TYPE target_set is table of target ;

-----------------------------------------------------------------------------
-- PROCEDURE     setDdlTimeout
--  
-- Description: set ddl_lock_timeout value to max(old_value, new_value)
-- Parameters: 
--     new_value - new value for ddl timeout
--
-- TODO: move to utilitiesi after branch
-----------------------------------------------------------------------------

PROCEDURE setDdlTimeout(new_value binary_integer);

--*****************************************************************************
-- Package Public Constants
--*****************************************************************************

-- RAC status values (must match defines for gwm_rac_status in gwm2.h
--
GWM_NORAC       constant  pls_integer := 0;  -- database not on RAC
GWM_RAC_ADMIN   constant  pls_integer := 1;  -- database on admin managed RAC
GWM_RAC_POLICY  constant  pls_integer := 2;  -- database on policy managed RAC
GWM_RAC_UNKNOWN constant  pls_integer := 3;  -- unknown RAC status
GWM_RAC_SIHA    constant  pls_integer := 4;  -- database on SIHA


  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     addDatabase
  --
  -- Description: 
  --     Adds this database to the GDS framework (cloud)
  -- 
  -- Parameters:   
  --     cloud_name - Name of the cloud (gds framework)
  --     dbpool_name - database pool to which database is added
  --     region_name - region of database
  --     db_number  - catalog assigned (generated) database number
  --     num_instances_reserved - number of instance slots reserved for
  --                             this database
  --     force - force the add if it has already been added
  --     cpu_thresh
  --     srlat_thresh
  --
  -- Notes:
  --    Sets a number of database parameters to hold GDS related values
  -----------------------------------------------------------------------------
  PROCEDURE addDatabase( cloud_name              IN varchar2,
                         dbpool_name             IN varchar2,
                         region_name             IN varchar2,
                         db_number               IN number, 
                         num_instances_reserved  IN number 
                              default dbms_gsm_common.max_inst_default,
                         force                   IN number 
			      default dbms_gsm_common.isFalse,
                         cpu_thresh              IN number default NULL,
                         srlat_thresh            IN number default NULL,
                         inShard                 IN number default dbms_gsm_common.isFalse,
                         chunks                  IN number DEFAULT 0);
						 
  
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     addDatabase
  --
  -- Description: 
  --     Adds this database to the GDS framework (cloud)
  -- 
  -- Parameters:   
  --     dsc - database object
  --
  -- Notes:
  --    Sets a number of database parameters to hold GDS related values
  -----------------------------------------------------------------------------
  PROCEDURE addDatabase( dsc IN database_dsc_t);						 

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     modifyDatabase
  --
  -- Description: changes the region of the database 
  -- 
  -- Parameters:   
  --   region_name - new region name
  --   cpu_thresh
  --   srlat_thresh
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE modifyDatabase( region_name          IN varchar2 ,
                            cpu_thresh IN number default NULL,
                            srlat_thresh IN number default NULL );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     validateDatabase
  --
  -- Description:  
  --    Validate database existence and return local DB info
  -- 
  -- Parameters:   
  --   dbpool - dbpool that database existis in
  --   db_unique_name - unique name of database
  --   instances - number of instances database currently has configured
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE validateDatabase( dbpool         IN  varchar2,
                              db_unique_name OUT varchar2,
                              instances      OUT number,
                              cloud_name     IN varchar2 default NULL);
   PROCEDURE validateDatabase( dbpool         IN  varchar2,
                              db_unique_name OUT varchar2);
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     removeDatabase
  --
  -- Description:
  --    Remove a database from the GDS framework (cloud)
  -- 
  -- Parameters:
  --    db_only - Remove only database?
  --              Else cascaded remove which removes all global services
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE removeDatabase (db_only   IN   boolean default FALSE);
  
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    addGSM 
  --
  -- Description:
  --    Inform database of a new GSM which has been added to the catalog
  -- 
  -- Parameters:   
  --   gsm_alias   - gsm name
  --   endpoint - GSM listen endpoint
  --   region_name - region in which GSM exists
  --   ons_port - ONS port for GSM
  --
  -- Notes:
  --   Triggers registration request in LREG for new GSM
  --    
  -----------------------------------------------------------------------------
  PROCEDURE addGSM( gsm_alias      IN  varchar2,
                    endpoint       IN  varchar2,
                    region_name    IN  varchar2,
                    ons_port       IN  number );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    modifyGSM 
  --
  -- Description:  
  --   Inform database of GSM attribute changes
  -- 
  -- Parameters:   
  --   gsm_alias   - GSM name
  --   endpoint - gsm listen endpoint
  --   region_name - region in which GSM exists
  --   ons_port - ONS port for GSM
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE modifyGSM( gsm_alias   IN  varchar2,
                       endpoint    IN  varchar2 default NULL,
                       region_name IN  varchar2 default NULL,
                       ons_port    IN  number   default NULL );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     removeGSM
  --
  -- Description:  
  --    inform database of GSM removal
  -- 
  -- Parameters:   
  --    gsm_alias - name of GSM
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE removeGSM( gsm_alias   IN varchar2 );


  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     addService
  --
  -- Description:  Creates a new global service in the database and CRS
  -- 
  -- Parameters:   
  --   service_name - short name of the service in the data dictionary
  --   network_name - long service name used in SQLNet connect descriptors  
  --   rlb_goal - RLB goal (service time, throuput, none)
  --   clb_goal - CLB goal (short, long)
  --   distr_trans - enables distributed transaction processing  
  --   aq_notifications - enables AQ notfications 
  --   aq_ha_notifications - used to disable HA AQ notfications 
  --   lag_property - determines whether specified max lag should be enforced  
  --   max_lag_value - maximum acceptable value for replication lag 
  --   failover_method - TAF failover method  
  --   failover_type - TAF failover type
  --   failover_retries - TAF failover retries     
  --   failover_delay - TAF failover delay 
  --   edition  - databse edition
  --   pdb - privite db id 
  --   parameters for transaction continuity:
  --     commit_outcome   
  --     retention_timeout 
  --     replay_initiation_timeout 
  --     session_state_consistency 
  --   sql_translation_profile - directs how to interpret non-Oracle SQL 
  --   role - database role (primary or physical/logical/snapshot standby)
  --   proxy_db - TRUE if service is created on primary database 
  --                    to be used on standby(s) 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --
  -- Note:
  --   Constants for use in arguments are defined in dbms_gsm_common
  -----------------------------------------------------------------------------
  PROCEDURE addService( service_name              IN varchar2,
                        network_name              IN varchar2,
                        rlb_goal                  IN number default NULL,
                        clb_goal                  IN number default NULL,
                        distr_trans               IN number default NULL,
                        aq_notifications          IN number default NULL,
                        aq_ha_notifications       IN number default NULL,
                        lag_property              IN number default NULL,
                        max_lag_value             IN number default NULL,
                        failover_method           IN varchar2 default NULL,
                        failover_type             IN varchar2 default NULL,
                        failover_retries          IN number default NULL,
                        failover_delay            IN number default NULL,
                        edition                   IN varchar2 default NULL,
                        pdb                       IN varchar2 default NULL,
                        commit_outcome            IN number default NULL,
                        retention_timeout         IN number default NULL,
                        replay_initiation_timeout IN number default NULL,
                        session_state_consistency IN varchar2 default NULL,
                        sql_translation_profile   IN varchar2 default NULL,
                        locality                  IN number default NULL,
                        region_failover           IN number default NULL,
                        role                      IN number default NULL,
                        proxy_db                  IN number default 0,
                        primary_db                OUT number );
                        
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     addService
  --
  -- Description:  Creates a new global service in the database and CRS
  -- 
  -- Parameters:   
  --   p_service  - service object 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --
  -- Note:
  --   Constants for use in arguments are defined in dbms_gsm_common
  -----------------------------------------------------------------------------
  PROCEDURE addService(  p_service IN service_dsc_t, primary_db    OUT number);                       

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     modifyService
  --
  -- Description:  Modifies all attributes of a global service 
  -- 
  -- Parameters:   
  --   service_name - short name of the service in the data dictionary
  --   rlb_goal - RLB goal (service time, throuput, none)
  --   clb_goal - CLB goal (short, long)
  --   distr_trans - enables distributed transaction processing  
  --   aq_notifications - enables AQ notfications 
  --   aq_ha_notifications - used to disable HA AQ notfications 
  --   lag_property - determines whether specified max lag should be enforced  
  --   max_lag_value - maximum acceptable value for replication lag 
  --   failover_method - TAF failover method  
  --   failover_type - TAF failover type
  --   failover_retries - TAF failover retries     
  --   failover_delay - TAF failover delay 
  --   edition  - databse edition
  --   pdb - privite db id 
  --   parameters for transaction continuity:
  --     commit_outcome   
  --     retention_timeout 
  --     replay_initiation_timeout 
  --     session_state_consistency 
  --   sql_translation_profile - directs how to interpret non-Oracle SQL 
  --   role - database role (primary or physical/logical/snapshot standby)
  --   network_number - network interface number to access the service
  --   server_pool - name of the server pool for the service
  --   cardinality - service cardinality on RAC (singleton or uniform)
  --   proxy_db - TRUE if service is modified on primary database 
  --                    to propagate modifications to standby(s) 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --   instances  - string containing primary/available instances
  --
  -- Note:
  --   Constants for use in arguments are defined in dbms_gsm_common
  --   Depricated, use 
  --     modifyServiceLocalParameters or
  --     modifyServiceGlobalParameters instead
  -----------------------------------------------------------------------------
  PROCEDURE modifyService( service_name           IN varchar2,
                        rlb_goal                  IN number default NULL,
                        clb_goal                  IN number default NULL,
                        distr_trans               IN number default NULL,
                        aq_notifications          IN number default NULL,
                        aq_ha_notifications       IN number default NULL,
                        lag_property              IN number default NULL,
                        max_lag_value             IN number default NULL,
                        failover_method           IN varchar2 default NULL,
                        failover_type             IN varchar2 default NULL,
                        failover_retries          IN number default NULL,
                        failover_delay            IN number default NULL,
                        edition                   IN varchar2 default NULL,
                        pdb                       IN varchar2 default NULL,
                        commit_outcome            IN number default NULL,
                        retention_timeout         IN number default NULL,
                        replay_initiation_timeout IN number default NULL,
                        session_state_consistency IN varchar2 default NULL,
                        sql_translation_profile   IN varchar2 default NULL,
                        locality                  IN number default NULL,
                        region_failover           IN number default NULL,
                        role                      IN number default NULL,
                        network_number            IN number default NULL,
                        server_pool               IN varchar2 default NULL,
                        cardinality               IN varchar2 default NULL,
                        proxy_db                  IN number default 0,
                        primary_db                OUT number,
                        instances                 IN varchar2 default NULL,
                        force                     IN number
                            default dbms_gsm_common.isFalse);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     modifyServiceLocalParameters
  --
  -- Description:  Modifies all local attributes of a global service 
  -- 
  -- Parameters:   
  --   service_name - short name of the service in the data dictionary
  --
  --   network_number - network interface number to access the service
  --   server_pool - name of the server pool for the service
  --   cardinality - service cardinality on RAC (singleton or uniform)
  -- 
  --   proxy_db - TRUE if service is modified on primary database 
  --                    to propagate modifications to standby(s) 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --
  -- Note:
  --   Constants for use in arguments are defined in dbms_gsm_common.
  -----------------------------------------------------------------------------

   PROCEDURE modifyServiceLocalParameters(
                        service_name              IN varchar2,
                        network_number            IN number,
                        server_pool               IN varchar2,
                        cardinality               IN varchar2,
                        instances                 IN varchar2 default NULL,
                        force                     IN number
                            default dbms_gsm_common.isFalse);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     modifyServiceGlobalParameters
  --
  -- Description:  Modifies all global attributes of a global service 
  -- 
  -- Parameters:   
  --   service_name - short name of the service in the data dictionary
  --
  --   rlb_goal - RLB goal (service time, throuput, none)
  --   clb_goal - CLB goal (short, long)
  --   distr_trans - enables distributed transaction processing  
  --   aq_notifications - enables AQ notfications 
  --   aq_ha_notifications - used to disable HA AQ notfications 
  --   lag_property - determines whether specified max lag should be enforced  
  --   max_lag_value - maximum acceptable value for replication lag 
  --   failover_method - TAF failover method  
  --   failover_type - TAF failover type
  --   failover_retries - TAF failover retries     
  --   failover_delay - TAF failover delay 
  --   edition  - databse edition
  --   pdb - privite db id 
  --   parameters for transaction continuity:
  --     commit_outcome   
  --     retention_timeout 
  --     replay_initiation_timeout 
  --     session_state_consistency 
  --   sql_translation_profile - directs how to interpret non-Oracle SQL 
  --   role - database role (primary or physical/logical/snapshot standby)
  --
  --   proxy_db - TRUE if service is modified on primary database 
  --                    to propagate modifications to standby(s) 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --
  -- Note:
  --   Constants for use in arguments are defined in dbms_gsm_common.
  --   This procedure sets all of the parameters to the given values.
  -----------------------------------------------------------------------------

  PROCEDURE modifyServiceGlobalParameters(
                        service_name              IN varchar2,
                        rlb_goal                  IN number,
                        clb_goal                  IN number,
                        distr_trans               IN number,
                        aq_notifications          IN number,
                        aq_ha_notifications       IN number,
                        lag_property              IN number,
                        max_lag_value             IN number,
                        failover_method           IN varchar2,
                        failover_type             IN varchar2,
                        failover_retries          IN number,
                        failover_delay            IN number,
                        edition                   IN varchar2,
                        pdb                       IN varchar2,
                        commit_outcome            IN number,
                        retention_timeout         IN number,
                        replay_initiation_timeout IN number,
                        session_state_consistency IN varchar2,
                        sql_translation_profile   IN varchar2,
                        locality                  IN number,
                        region_failover           IN number,
                        role                      IN number,
                        proxy_db                  IN number,
                        primary_db                OUT number,
                        force                     IN number
                            default dbms_gsm_common.isFalse);

-----------------------------------------------------------------------------
  --
  -- PROCEDURE     modifyServiceGlobalParameters
  --
  -- Description:  Modifies all global attributes of a global service
  -- Parameters:   
  --   p_service  - service object 
  --   primary_db - TRUE if this is primary database (OUT parameter)
  --
  -- Note:
    -----------------------------------------------------------------------------
  PROCEDURE modifyServiceGlobalParameters(
                            p_service IN service_dsc_t, 
                            primary_db    OUT number,
                            force                     IN number
                            default dbms_gsm_common.isFalse);



  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     removeService
  --
  -- Description:  Removes a service from CRS and / or the database.  
  -- 
  -- Parameters:   
  --   service_name
  --   proxy_db - TRUE if service is removed on primary database 
  --                    to be removed on standby(s) 
  --   delete_to_move - TRUE if service is removed to be moved to another db
  --   primary_db - TRUE if this is primary database (OUT parameter)

  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE removeService( service_name           IN varchar2,
                           proxy_db               IN number default 0,
                           delete_to_move         IN number default 0,
                           primary_db             OUT number );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     startService
  --
  -- Description:  
  --     Start a service on this database
  -- 
  -- Parameters:   
  --   service_name
  --   inst_list - list of instances to start on
  --
  -- Notes:
  --   inst_list is ignored for DB types other than admin-managed RAC
  --    
  -----------------------------------------------------------------------------
  PROCEDURE startService( service_name IN varchar2,
                          inst_list IN varchar2 DEFAULT NULL );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     stopService
  --
  -- Description:  
  --    Stop a service on this database
  -- 
  -- Parameters:   
  --   service_name
  --   options               Various stop option introduced afet 12.2 and
  --                         not relevant to GSM processing format:
  --                         opt1=val1;op2=val2;...opt_n=val_n;
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE stopService( service_name IN varchar2,
                         force        IN number
                             default dbms_gsm_common.isFalse,
                         options      IN varchar2 default NULL
                             );

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     addRegion
  --
  -- Description:  
  --    Inform database of addition of a new region in the datalog
  -- 
  -- Parameters:   
  --   region_name - name of the region
  -- buddy_region - name of its buddy
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE addRegion( region_name  IN varchar2,
                       buddy_region IN varchar2 default NULL);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    modifyRegion 
  --
  -- Description:  
  --   inform database of modification of region attributes
  -- 
  -- Parameters:   
  --   region_name - name of the region
  --   buddy_region - name of its buddy
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE modifyRegion( region_name  IN varchar2,
                          buddy_region IN varchar2 default NULL);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     removeRegion
  --
  -- Description:  
  --   inoform database of removal of a region
  -- 
  -- Parameters:   
  --   region_name - name of the region
  --
  -- Notes:
  --    

  -----------------------------------------------------------------------------
  PROCEDURE removeRegion( region_name IN varchar2 );
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    getHostInfo 
  --
  -- Description:  
  --       Gets information about connected host for GSM
  -- 
  -- Parameters:   
  --   ons_port   OUT   ONS port number
  --   scan_name  OUT   Cluster SCAN name (if appropriate)
  --   hostname   OUT   connected server host
  --   db_type    OUT   type of database
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  
  PROCEDURE getHostInfo (ons_port OUT varchar2,
                         scan_name OUT varchar2,
                         hostname OUT varchar2);
						 
  PROCEDURE getHostInfo (ons_port OUT varchar2,
                         scan_name OUT varchar2,
                         hostname OUT varchar2,
                         db_type  OUT char);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    getCRSinfo 
  --
  -- Description:  
  --    Get CRS information
  -- 
  -- Parameters:   
  --   ons_port - ONS port for CRS
  --   scan_name - scan name for CRS
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  PROCEDURE getCRSinfo( ons_port OUT varchar2, scan_name OUT varchar2,
                        rac_status OUT pls_integer );
  
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    getGSMinfo
  --
  -- Description:  
  --   Get information about the database for GSM
  -- 
  -- Parameters:   
  --   NONE
  --
  -- Returns:
  --   gsm_info - object containing information about the database for GSM
  --
  -- Notes:
  --    
  -----------------------------------------------------------------------------
  FUNCTION getGSMInfo
  return gsm_info;
  
  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    removeAllServices 
  --
  -- Description: stop and delete all the global services. 
  -- 
  -- Parameters:  None 
  --
  -- Notes:
  --    

  PROCEDURE removeAllServices;

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    sync 
  --
  -- Description: execute modifications on database side. 
  -- 
  -- Parameters: 
  --  dsc - describes the new state of database. 
  --        This parameter also is used to return 
  --        host info data and sync status.
  --
  --  warnings - output parameter used to return error messages
  --             occured during sync process.
  --
  -- Notes:
  --    
  
  PROCEDURE sync(dsc IN OUT database_dsc_t, warnings OUT warning_list_t);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    executeDDL 
  --
  -- Description: execute DDL statement
  -- 
  -- Parameters: 
  --  ddlid - DDL id
  --  schema_name - schema context
  --  ddl_text - text of ddl statement
  --  ddlaction - one of three actions
  --
  --
  -- Notes:
  --   
  PROCEDURE executeDDLPrvt(ddlid            IN OUT number, 
                     schema_name      IN     VARCHAR2,
                     ddl_text         IN     CLOB default NULL,
                     operation_type   IN     char,
                     params           IN     varchar2 DEFAULT NULL,
                     ddlaction        IN     number 
                        default dbms_gsm_common.execddl_default,
                     runddl           OUT    boolean);

-----------------------------------------------------------------------------
  --
  -- PROCEDURE    executeDDLCallback
  --
  -- Description: execute DDL statement callback
  -- 
  -- Parameters: 
  --  ddlid - DDL id
  --
  --
  -- Notes:
  --    
  PROCEDURE executeDDLCallback;  

  --
-----------------------------------------------------------------------------
  --
  PROCEDURE syncDDLParameter;               
  TYPE chunk_list_t IS TABLE OF NUMBER index by PLS_INTEGER;
  --
-----------------------------------------------------------------------------
  --
  -- PROCEDURE    recoverChunks
  --
  -- Description: recover Chunk information after unsuccesfull move or split
  -- 
  

  PROCEDURE recoverChunks;

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    setChunks
  --
  -- Description: initial chunk assignment to database
  -- 
  -- Parameters: 
  --  chunk_list - list of chunk identifiers
  --

  PROCEDURE setChunks(chunk_list IN chunk_list_t);


  -----------------------------------------------------------------------------
  --
  -- PROCEDURE    grabChunksFromCatalog
  --
  -- Description: get chunks from the catalog database
  --

  PROCEDURE grabChunksFromCatalog;

-----------------------------------------------------------------------------
  --
  -- PROCEDURE    setCatalogLink
  --
  -- Description: creates db link from shard to catalog
  -- 
  -- Parameters: 
  --  gsmusrpwd - password
  --  gsm_endpoint - end point
  --  no_check - doesn't check that db link is ok, 
  --             doesn't replace link if exists
  --
  -- Notes:
  --                         
PROCEDURE setCatalogLink(gsmusrpwd IN VARCHAR2, gsm_endpoint IN VARCHAR2,
                         no_check        IN number
                             default dbms_gsm_common.isFalse);

-----------------------------------------------------------------------------
--
-- PROCEDURE    ensureDBLink
--    
PROCEDURE ensureDBLink(db_name  IN  VARCHAR2, 
                       conn_str IN VARCHAR2, 
                       gsmusrpwd IN VARCHAR2 default NULL);

-----------------------------------------------------------------------------
--
-- PROCEDURE    moveChunk
  -- Parameters: 
  --  chunk_id - chunk identifier
  -- conn_str - target database connection string
  -- timeout - wait time for ongoing transactions to complete
  --  mode - 0 - default
--    
PROCEDURE moveChunk ( chunk_id BINARY_INTEGER, 
                          conn_str IN VARCHAR2, 
                          timeout BINARY_INTEGER,
                          move_mode BINARY_INTEGER,
                          gsmusrpwd IN VARCHAR2,
                          gdsctl_id IN BINARY_INTEGER default 0);
/*
-----------------------------------------------------------------------------
--
-- PROCEDURE    quisceMigrationSource
  -- Parameters: 
  --  chunk_id - chunk identifier
--    
PROCEDURE quisceMigrationSource ( chunk_id NUMBER);

-----------------------------------------------------------------------------
--
-- PROCEDURE    reconfigureTargets
  -- Parameters: 
  --  chunk_id - chunk identifier
--    
PROCEDURE reconfigureOGG (     chunk_id NUMBER, 
                               db_role IN BINARY_INTEGER 
					                 default dbms_gsm_common.movechunk_source,  
                               status IN BINARY_INTEGER
					               default dbms_gsm_common.movechunk_success);
*/
-- Parameters: 
--  chunk_id - chunk identifier
-- db_role -  database role (source or target)
-- status (success or fail)
--    
PROCEDURE finishMove ( chunk_id  IN BINARY_INTEGER,
                       db_role IN BINARY_INTEGER 
					           default dbms_gsm_common.movechunk_source,  
                       status IN BINARY_INTEGER
					          default dbms_gsm_common.movechunk_success,
					   timeout IN BINARY_INTEGER default 0);


                          
--PROCEDURE moveChunkOld ( targ_db  IN  VARCHAR2, 
--					  conn_str IN VARCHAR2, 
--					  gsmusrpwd IN VARCHAR2 default NULL,
--					  chunk_id IN NUMBER);

-----------------------------------------------------------------------------
--
-- PROCEDURE    restoreChunk
--
-- Restore chunk partitions reassigning their tablespaces 
--    and recreating them if needed.
--
-- Note : internal procedure, not for public use.
--

PROCEDURE restoreChunk(
    a_chunk_id       BINARY_INTEGER,
    a_shardspace_id  BINARY_INTEGER,
    do_remove        BINARY_INTEGER default 0,
    no_update_chunk  BINARY_INTEGER default 0);

-----------------------------------------------------------------------------
-- PROCEDURE    alterAllRefFragmentsUnitTest
--
-- unit test for various alter table ... partition ... statements
--

procedure alterAllRefFragmentsUnitTest(a_owner in varchar2, a_name in varchar2);

-----------------------------------------------------------------------------
--
-- PROCEDURE    splitChunk
--
PROCEDURE splitChunk(
    a_chunk_id       BINARY_INTEGER,
    target_chunk_id  BINARY_INTEGER,
    a_shardspace_id  BINARY_INTEGER);

-- For testing purposes. Not public.
PROCEDURE controlChunk ( chunkid BINARY_INTEGER, 
                         op BINARY_INTEGER,
                         p1 BINARY_INTEGER);


PROCEDURE exportMetadata(chunk_id IN NUMBER);
PROCEDURE importData(md_fname IN VARCHAR2);
-- PROCEDURE getGroundTSName( table_name IN VARCHAR2, ts_name OUT varchar2);

PROCEDURE getDBNumberRange( cur_number IN NUMBER,
                             range_min  IN OUT NUMBER,
                             range_max  IN OUT NUMBER);
							 
PROCEDURE configOGGReplication;

PROCEDURE executeGenericProcedure (payload         IN  varchar2, 
                                   change_type     IN  number,
                                   response_code   OUT number,
                                   response_info   OUT varchar2);
                                   
PROCEDURE send_gdsctl_msg (
                           message          IN   VARCHAR2,
                           gdsctl_sid       IN NUMBER,
                           message_type     IN   NUMBER 
                                            DEFAULT dbms_gsm_utility.msg_message);                                   
 -----------------------------------------------------------------------------
 --
 -- PROCEDURE    setRATableFamily
 --
 -- Description: Enable RAC affinity for table
 --
 -- Parameters:
 --  table_name    - name of the affinitized partition table
 --  chunks        - the number of created chunks
 --  dobj          - partitioned table  data object identifier
 --  service_name  - service name
 --  svc_id        - service identifier
 --
 PROCEDURE setRATableFamily( table_name IN VARCHAR, 
                             chunks OUT number, 
                             dobj IN OUT number,
                             service_name IN VARCHAR,
                             svc_id IN OUT number
                             );

 -- PROCEDURE    dropRATableFamily
 --
 -- Description: disable RAC affinity
 --
 PROCEDURE dropRATableFamily;        
 
 -- PROCEDURE    createRATableFamily
 --
 -- Description: Enable RAC affinity for table
 --
 -- Parameters:
 --  shard_owner    - schema owner
 --  shard_table    - name of the affinitized partition table
 --
 PROCEDURE createRATableFamily( shard_owner IN VARCHAR, 
                                shard_table IN VARCHAR);

 END dbms_gsm_dbadmin;

/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
