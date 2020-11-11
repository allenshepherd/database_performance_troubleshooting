Rem
Rem $Header: rdbms/admin/dbmsgwmpl.sql /main/60 2017/08/03 17:21:57 saratho Exp $
Rem
Rem dbmsgwmpl.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmpl.sql - Global Workload Management database Pool administration
Rem    DESCRIPTION
Rem      Defines the interface for dbms_gsm_pooladmin package that is used
Rem      for database pool administration performed by GSMCTL.
Rem
Rem    NOTES
Rem      This package is only loaded on the GSM cloud catalog database.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmpl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmpl.sql
Rem SQL_PHASE: DBMSGWMPL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/gbmdgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    saratho     06/14/17 - allow partial results in c-s query
Rem    saratho     04/12/17 - Bug 25816781: add getDBInfo for replace shard
Rem    sdball      03/31/17 - new parameters for addService and modifyService
Rem    sdball      03/24/17 - Changes for atomic move
Rem    lenovak     02/23/17 - recoverShard changes
Rem    dmaniyan    02/08/17 - Make assignChunkLocationsDG() public
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    sdball      11/04/16 - Update for PDB support
Rem    dcolello    10/20/16 - bug 23152783: implement set dataguard_property
Rem    dcolello    09/16/16 - add setDGProperty()
Rem    ralekra     07/27/16 - OGGReplicationDone is obsolete
Rem    sdball      06/14/16 - Add copy parameter to moveChunk
Rem    dcolello    06/09/16 - bug 23555990: avoid name conflict in checkSync()
Rem    sdball      05/18/16 - New signature for execSQLOnShard
Rem    sdball      05/11/16 - New peocedures for deploy status
Rem    ralekra     05/09/16 - make cross-shard chunk (re)configuration  
Rem                           procedures public to access them from OGG code
Rem    dcolello    04/27/16 - bug 22530860: validate character set of shard
Rem    ralekra     03/23/16 - add out param gsm_req# in executeOGGProcedure
Rem    sdball      03/18/16 - New signature for deploy
Rem    lenovak     02/22/16 - gdsctloutput for catalog_requests
Rem    dcolello    02/17/16 - bug 22743674: add serviceuserpassword
Rem    lenovak     02/04/16 - add gdsctl messages
Rem    dcolello    11/30/15 - remove getDevEnv
Rem    sdball      11/19/15 - Add execSQLOnShard
Rem    dcolello    11/03/15 - bug 22145801: add gg_password to addShard()
Rem    ditalian    09/17/15 - split chunk new signature
Rem    dcolello    07/29/15 - sharding terminology changes
Rem    ralekra     06/25/15 - OGG online move chunk support
Rem    sdball      06/10/15 - Support for long identifiers
Rem    dcolello    05/29/15 - remove obsolete retrieveCred() function
Rem    dcolello    05/18/15 - remove obsolete createDatabase() version
Rem    sdball      05/01/15 - Defs for modify procedures
Rem    ralekra     03/24/15 - Add support for OGG replication
Rem    sdball      03/25/15 - Support for manual sharding
Rem    sdball      03/04/15 - New types and definitions for 12.2 charding
Rem    sdball      03/11/15 - New functions for multi-target
Rem    lenovak     10/12/14 - add confirmMove and setRuntime. 
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    sdball      01/06/14 - Updates for sharding
Rem    sdball      01/03/14 - Fix for new shard schema
Rem    cechen      11/01/13 - add PKI key set/get manipulation
Rem                           use primary db name for adding stdby
Rem    cechen      08/22/13 - overloading addDB/ModifyDB for compatibility
Rem    sdball      08/15/13 - Add db_type to addDatabaseDone
Rem    lenovak     07/29/13 - shard support
Rem    sdball      03/07/13 - support admin managed RAC databases
Rem    sdball      02/26/13 - New interfaces for versioning
Rem    sdball      02/04/13 - New interface for modifyServiceOnDB
Rem                           New procedure catRollback
Rem    sdball      01/11/13 - Bug 15966879: pool name should be optional for
Rem                           sync
Rem    nbenadja    01/10/13 - Store database threshold values in GDS catalog.
Rem    itaranov    11/08/12 - Modify database do not need pool (14791200)
Rem    lenovak     11/07/12 - Add changeServiceState
Rem    itaranov    10/31/12 - Add null value description
Rem    sdball      09/21/12 - Add syncDatabase
Rem    sdball      08/31/12 - Update signature for updateDatabaseStatus
Rem    sdball      06/13/12 - Support for number of instances
Rem    lenovak     12/01/06 - change default service policy
Rem    sdball      11/28/11 - Auto VNCR functionality
Rem    sdball      11/03/11 - Add syncBrokerConfig
Rem    sdball      10/31/11 - support for removeBrokerConfig
Rem    sdball      10/24/11 - Changes for recovery of add service
Rem    lenovak     07/20/11 - add modifyDatabase
Rem    mjstewar    04/27/11 - Second GSM transaction
Rem    mjstewar    02/02/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL dbmsgwmpl.log

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Database package for GSM pool administrator functions.
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_pooladmin AS


--*****************************************************************************
-- Package Public Types
--*****************************************************************************


-----------------
-- Name list type 
-----------------
TYPE name_list_type IS TABLE OF varchar2(dbms_gsm_common.max_ident)
   index by binary_integer;

-----
--- chunk types
----

TYPE chunk_list IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
TYPE shardid_list IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER ;
TYPE shard2chunk_map  is TABLE of shard_t  index BY pls_integer;
--*****************************************************************************
-- Package Public Constants
--*****************************************************************************
cs_readwrite             constant  number := 0;
cs_readonly              constant  number := 1;
prv_key                  constant  number := 0;
pub_key                  constant  number := 1;
prk_enc_str              constant  number := 2;

-- Broker config status
undeployed               constant  number := 0; -- initial add state
deploy_ready             constant  number := 1; -- ready to deploy
broker_configured        constant  number := 2; -- ready to go

-- move chunk errors (for moveFailed, see also ngsmocchk in ngsmoc.h)
move_ok                  constant number := 0;
move_notarget            constant number := 1; -- no target DB
move_nosrc               constant number := 2; -- no source db
move_fail                constant number := 3; -- general failure to move

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************



--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************

--*****************************************************************************
-- Package private constants
--*****************************************************************************
-- Action parameter
logical                     constant  number := 1;
physical                    constant  number := 2;

-- Force parameter
force_off                   constant  number := 0;
force_on                    constant  number := 1;

-- gen_aq_notification parameter
gen_aq_off                  constant  number := 0;
gen_aq_on                   constant  number := 1;

-- templates for create/modify database sid, files, credential and job
sid_tmpl                    constant  varchar2(2) := 'sh';
file_tmpl                   constant  varchar2(11) := 'SHARD_FILE_';
cred_tmpl                   constant  varchar2(11) := 'SHARD_CRED_';
job_tmpl                    constant  varchar2(10) := 'SHARD_JOB_';

-------------------------------------------------------------------------------
--
-- PROCEDURE     changeServiceState
--
-- Description:
--       update service state, sends notification with new service state
--
-- Parameters:
--       service_name:         The name of the service to check.
--       database_pool_name:   The database pool to check.
--       database_name:        The db unique name of the database.
--       new_state:            New state of service.
--       gen_notification:     Send AQ notification
-- 
--
-- Returns:
--
-- Notes:
--    
-------------------------------------------------------------------------------
PROCEDURE changeServiceState(  service_name IN varchar2,
                               pool_name    IN varchar2,
                               db_name      IN varchar2,
                               new_state   IN varchar2,
                               gen_notification IN number default 0);

-------------------------------------------------------------------------------
--
-- PROCEDURE     addBrokerConfig
--
-- Description:
--       Makes a database pool a Data Guard broker configuration.      
--
-- Parameters:
--       db_unique_name:               db_unique name for the primary
--                                     database in a Data Guard broker
--                                     configuration.
--       database_pool_name:           The name of the database pool.
--       database_connect_string:      Connect string for the database.
--       password:                     Encrypted password for the database.
--       region:                       Region in which to put the databases.
--       num_standbys:                 The number of standby databases to 
--                                     reserve for the broker config.
--
-- Notes:
--     addBrokerConfig is implemented as follows:
--       1. GSMCTL invokes this routine and it:
--          a. adds the primary database entry to the catalog with status "I"
--          b. assigns the database a unique number and reserves a range of
--             numbers for the standbys
--          c. generates a GSM change message indicating that an Add
--             Brokerconfig has been done.  Included in the message is the
--             number of database id's reserved for the config
--             (-num_standbys S) [Note that this number will be greater than
--             the input parameter "num_standbys" to this routine to allow for
--             the addition of new standbys during the processing of this
--             command], and the number of instances reserved for
--             each database in the config (-num_instances I).
--       2. The Master GSM is notified of the change and then:
--          a. modifies the primary database to become part of the cloud
--          b. invokes addDatabaseDone to clear the "I" status for the
--             primary database and optionally add the scan address and
--             ons port for the primary database
--          c. queries the primary for the names of all the standbys
--          d. modifies the standbys to become part of the cloud
--          e. invokes addDatabaseInternal for each standby to add the
--             standby database to the catalog, set its status appropriately,
--             optionally add the database's scan and ons port, and
--             generate a 'DatabaseDone' AQ notification.  All the GSMs
--             process this message and update their internal data structures
--             accordingly.
-- 
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
-- 
--     If region_name is NULL and there is a single region defined, then
--     the primary database is put into that region.  If more than one
--     region is defined, then the database will be given a NULL region.
-------------------------------------------------------------------------------

PROCEDURE addBrokerConfig( db_unique_name           IN varchar2,
                           database_pool_name       IN varchar2 default NULL,
                           database_connect_string  IN varchar2,
                           password                 IN varchar2 default NULL,
                           region                   IN varchar2 default NULL,
                           num_standbys             IN number default 1,
                           instances                IN number default NULL,
                           encpassword              IN RAW  default NULL);


-- TODO: make num_standbys required when GSM code has been modified?
-------------------------------------------------------------------------------
--
-- PROCEDURE     removeBrokerConfig
--
-- Description:
--       Removes entire broker configuration (all databases and services)    
--
-- Parameters:
--
--       database_pool_name:       The name of the database pool.
--       action:                   logical or physical;
--                                 logical will update as removed (first phase)
--                                 physical will remove database records
--       gen_aq_notification       gen_aq_on or gen_aq_off
--                                 determines if AQ notification is generated
--
-- Notes:
--    This procedure will remove all databases and services for the provided
--    database pool after verifying that it is a broker configuration. The
--    "force" option is used for databases and services since the operation
--    is not yet recoverable; the assumption is that all databases and services
--    must eventually be removed. WARNING: this operaion is not reversible and
--    complete removal must be completed once initiated.
-- TODO: recover this somehow if it goes wrong in GSM?
-------------------------------------------------------------------------------
PROCEDURE removeBrokerConfig(database_pool_name    IN varchar2,
                             action                IN number default logical,
                             gen_aq_notification   IN number default gen_aq_on);
-------------------------------------------------------------------------------
--
-- PROCEDURE     syncBrokerConfig
--
-- Description:
--       Sync GSM's version of broker configuration with latest updates    
--
-- Parameters:
--
--       database_pool_name:       The name of the database pool.
--       database_name:            Name of primary database in BC (optional)
--
-- Notes:
--    This function simply notifies GSM through AQ and gsm_requests that the
--    broker configuration needs to be synced. GSM will do all the work.
-------------------------------------------------------------------------------
PROCEDURE syncBrokerConfig ( database_pool_name    IN varchar2 DEFAULT NULL,
                             database_name          IN varchar2 DEFAULT NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     setDGProperty
--
-- Description:
--       Sets a DataGuard property value for a shardgroup, shardspace, shard, 
--         or broker config.    
--
-- Parameters:
--
-- Notes:
   
-------------------------------------------------------------------------------
PROCEDURE setDGProperty(shardgroup_name IN varchar2 DEFAULT NULL,
                        shard_name      IN varchar2 DEFAULT NULL,
                        broker_name     IN varchar2 DEFAULT NULL,
                        shardspace_name IN varchar2 DEFAULT NULL,
                        prop_name       IN varchar2,
                        prop_value      IN varchar2 DEFAULT NULL,
                        prop_scope      IN varchar2 DEFAULT NULL,
                        prop_reset      IN number   DEFAULT 0);

-------------------------------------------------------------------------------
--
-- PROCEDURE     addCDB
--
-- Description:
--       Adds a new CDB to a sharding configuration. 
--
-- Parameters:
--
-- Notes:
--
-------------------------------------------------------------------------------
PROCEDURE addCDB( db_unique_name           IN varchar2,
                  database_connect_string  IN varchar2,
                  instances                IN number default NULL,
                  cpu                      IN number default NULL,
                  srlat                    IN number default NULL,
                  encpassword              IN RAW   default NULL,
                  dbhost                   IN varchar2 default NULL,
                  oracle_home              IN varchar2 default NULL,
                  dbid                     IN number default 0,
                  database_role            IN varchar2 default NULL,
                  rack                     IN varchar2 DEFAULT NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     createShard
--
-- Description:
--       Creates a new shard and adds it to a region and a database pool.      
--
-- Parameters:
--
-- Notes:
   
-------------------------------------------------------------------------------
PROCEDURE createShard(region                IN varchar2 DEFAULT NULL,
	              shardspace_name       IN varchar2 DEFAULT NULL,
                      shardgroup_name       IN varchar2 DEFAULT NULL,
                      deploy_as             IN number   DEFAULT NULL,
		      dest 		    IN varchar2,
	              cred		    IN varchar2 DEFAULT NULL,
                      dbparam	            IN varchar2 DEFAULT NULL,
                      dbtemplate   	    IN varchar2 DEFAULT NULL,
                      netparam	       	    IN varchar2 DEFAULT NULL,
                      osaccount             IN varchar2 DEFAULT NULL,
                      ospassword            IN varchar2 DEFAULT NULL,
                      windows_domain        IN varchar2 DEFAULT NULL,
                      dbparamcontent        IN clob DEFAULT NULL,
                      dbtemplatecontent     IN clob DEFAULT NULL,
                      netparamcontent       IN clob DEFAULT NULL,
                      rack                  IN varchar2 DEFAULT NULL,
                      gg_service            IN varchar2 DEFAULT NULL,
                      gg_password           IN varchar2 DEFAULT NULL,
                      syspassword           IN varchar2 DEFAULT NULL,
                      systempassword        IN varchar2 DEFAULT NULL,
                      serviceuserpassword   IN varchar2 DEFAULT NULL,
                      new_dbname            OUT varchar2);

-------------------------------------------------------------------------------
--
-- PROCEDURE     addDatabaseInternal
--
-- Description:
--       Adds a new database to a broker configuration.
--
-- Parameters:
--       db_unique_name:               db_unique name for the database to add 
--       database_pool_name:           The name of the database pool.
--       database_connect_string:      Connect string for the database.
--       password:                     Encrypted password for the database.
--       region:                       Region in which to put the database.
--       status:                       Configuration status to give the database
--       db_num:                       The database number assigned to this
--                                     standby by the GSM.  If NULL then the
--                                     this routine will assign the database
--                                     a number.
--       scan_address:                 If the database is RAC, its SCAN address
--       ons_port:                     If the database is RAC, its ONS port
--       hostname                      hostname or IP address for VNCR
--       db_vers                       GDS internal version of the database
--       prmdb_name                    name of primary DB to cp password from
--
-- Notes:
--     This is the final step of addBrokerConfig().  The master GSM invokes
--     this routine to add each standby database to the cloud catalog.
--     
--     The routine will generate a "database done" AQ notification.
-- 
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
-- 
--     If region_name is NULL and there is a single region defined, then
--     the primary database is put into that region.  If more than one
--     region is defined, then the database will be given a NULL region.
-------------------------------------------------------------------------------

PROCEDURE addDatabaseInternal( db_unique_name          IN varchar2,
                               database_pool_name      IN varchar2 default NULL,
                               database_connect_string IN varchar2,
                               password                IN varchar2 default NULL,
                               region                  IN varchar2 default NULL,
                               status                  IN char,
                               db_num                  IN number default NULL,
-- TODO: make db_num mandatory after GSM code is modified ?
                               scan_address            IN varchar2 default NULL,
                               ons_port                IN number default NULL,
                               hostname                IN varchar2 default NULL,
                               db_vers                 IN number default NULL,
                               prmdb_name              IN varchar2 default NULL,
                               db_type                  IN char default 'U');

-------------------------------------------------------------------------------
--
-- PROCEDURE     addDatabase
--
-- Description:
--       Adds a database to a region and a database pool.      
--
-- Parameters:
--       db_unique_name:               db_unique name for the database to
--                                       add to the pool.
--       database_pool_name:           The name of the database pool.
--       database_connect_string:      Connect string for the database.
--       password:                     Encrypted password for the database.
--       region:                       Region in which to put the database.
--       instances                     Number of instances reserved.
--       cpu_thresh                    CPU threshold value.
--       srlat_thresh                  Single read latency threshold. 
--
-- Notes:
--    The "Add Database" command is implemented in three phases:
--      1. GSMCTL invokes this routine and it: 
--           a. Adds the database entry to the cloud catalog
--           b. Set the status to "I" (incomplete)
--           c. Generates a GSM change message indicating that an
--              Add Database has been done
--      2. The Master GSM is notified of the change and then modifies
--         each database to become part of the cloud.  This involves adding
--         some GSM related hidden parameters.
--      3. The Master GSM then invokes addDatabaseDone() to clear the "I"
--         status for the database, optionally add the scan address and ons
--         port to the database's catalog entry, and generate a GSM change
--         message indicating that the add of the database completed.  All
--         the GSMs process this message and update their internal data
--         structures accordingly.
--  
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
-- 
--     region_name can be NULL if there is only one region in the cloud.
--     In which case the command will default to that region.    
-------------------------------------------------------------------------------
PROCEDURE addDatabase( db_unique_name           IN varchar2,
                       database_pool_name       IN varchar2 default NULL,
                       database_connect_string  IN varchar2,
                       password                 IN varchar2,
                       region                   IN varchar2 default NULL,
                       instances                IN number default NULL,
                       cpu                      IN number default NULL,
                       srlat                    IN number default NULL,
                       encpassword              IN RAW    default NULL,
                       dbhost                   IN varchar2 default NULL,
                       agent_port               IN number default NULL,
                       db_sid                   IN varchar2 default NULL,
                       oracle_home              IN varchar2 default NULL,
                       dbid                     IN number default 0,
                       conversion_status        IN varchar2 default NULL);

PROCEDURE addShard( db_unique_name              IN varchar2,
                       database_pool_name       IN varchar2 default NULL,
                       database_connect_string  IN varchar2,
                       password                 IN varchar2,
                       region                   IN varchar2 default NULL,
                       instances                IN number default NULL,
                       cpu                      IN number default NULL,
                       srlat                    IN number default NULL,
		       shardgroup_name          IN varchar2 default NULL,
                       encpassword              IN RAW default NULL,
                       shardspace_name          IN varchar2 default NULL,
                       deploy_as                IN number default NULL,
                       dbhost                   IN varchar2 default NULL,
                       agent_port               IN number default NULL,
                       db_sid                   IN varchar2 default NULL,
                       oracle_home              IN varchar2 default NULL,
                       dbid                     IN number default 0,
                       conversion_status        IN varchar2 default NULL,
                       rack                     IN varchar2 default NULL,
                       gg_service               IN varchar2 default NULL,
                       gg_password              IN varchar2 default NULL,
                       cdb                      IN varchar2 default NULL,
                       is_cdb                   IN boolean default FALSE,
                       replace                  IN varchar2 default NULL);

PROCEDURE addshardgroup (shardgroup_name       IN    varchar2,
                         region_name           IN    varchar2 DEFAULT NULL,
                         shardspace_name       IN    varchar2 DEFAULT NULL,
                         repfactor             IN    number   DEFAULT NULL,
                         deploy_as             IN    number   DEFAULT NULL);

PROCEDURE modifyshardgroup (shardgroup_name IN    varchar2,
                           region_name     IN    varchar2 DEFAULT NULL,
                           shardspace_name IN    varchar2 DEFAULT NULL,
                           repfactor       IN    number DEFAULT NULL,
                           deploy_as       IN    number DEFAULT NULL);

PROCEDURE removeshardgroup (shardgroup_name          IN    varchar2);

PROCEDURE addShardspace (shardspace_name IN       varchar2,
                         chunks          IN       number DEFAULT NULL,
                         protectmode     IN       number DEFAULT NULL);
                         
PROCEDURE modifyShardspace (shardspace_name     IN  varchar2,
                            chunks              IN  number DEFAULT NULL,
                            protectmode         IN  number DEFAULT NULL);

PROCEDURE removeShardspace (shardspace_name IN       varchar2);

--
-- PROCEDURE     modifyDatabase
--
-- Description:
--       modifies database  database pool.      
--
-- Parameters:
--       db_unique_name:               db_unique name 
--       database_pool_name:           The name of the database pool.
--       database_connect_string:      Connect string for the database.
--       password:                     Encrypted password for the database.
--       region:                       Region in which to put the database.
--       scan:                         Scan address
--       ons:                          ONS port
--       cpu_thresh                    CPU threshold value.
--       srlat_thresh                  Single read latency threshold. 
--
-- Notes:
--   This procedure is used for manual correction of db parameters
-------------------------------------------------------------------------------
PROCEDURE modifyDatabase ( db_unique_name           IN varchar2,
                           database_pool_name       IN varchar2 default NULL,
                           database_connect_string  IN varchar2 default NULL,
                           password                 IN varchar2 default NULL,
                           region                   IN varchar2 default NULL,
                           scan                     IN varchar2 default NULL,
                           ons                      IN number default NULL,
                           cpu                      IN number default NULL,
                           srlat                    IN number default NULL,
                           encpassword              IN RAW   default NULL);

PROCEDURE modifyShard ( db_unique_name           IN varchar2,
                           database_pool_name       IN varchar2 default NULL,
                           database_connect_string  IN varchar2 default NULL,
                           password                 IN varchar2 default NULL,
                           region                   IN varchar2 default NULL,
                           scan                     IN varchar2 default NULL,
                           ons                      IN number default NULL,
                           cpu                      IN number default NULL,
                           srlat                    IN number default NULL,
                           encpassword              IN RAW   default NULL,
			   dest 		    IN varchar2 default NULL,
			   cred			    IN varchar2 default NULL,
                           osaccount                IN varchar2 DEFAULT NULL,
                           ospassword               IN varchar2 DEFAULT NULL,
                           windows_domain           IN varchar2 DEFAULT NULL,
                           is_cdb                   IN boolean DEFAULT FALSE);

PROCEDURE modifyCDB ( db_unique_name           IN varchar2,
                           database_pool_name       IN varchar2 default NULL,
                           database_connect_string  IN varchar2 default NULL,
                           password                 IN varchar2 default NULL,
                           region                   IN varchar2 default NULL,
                           scan                     IN varchar2 default NULL,
                           ons                      IN number default NULL,
                           cpu                      IN number default NULL,
                           srlat                    IN number default NULL,
                           encpassword              IN RAW   default NULL,
			   dest 		    IN varchar2 default NULL,
			   cred			    IN varchar2 default NULL,
                           osaccount                IN varchar2 DEFAULT NULL,
                           ospassword               IN varchar2 DEFAULT NULL,
                           windows_domain           IN varchar2 DEFAULT NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     addDatabaseDone
--
-- Description:
--       Marks the end of "add database" processing.
--
-- Parameters:
--       db_unique_name:               db_unique name for the database 
--       database_pool_name:           The name of the database pool.
--       status:                       Configuration status to give the database.
--       scan_address:                 If the database is RAC, its SCAN address
--       ons_port:                     If the database is RAC, its ONS port
--       hostname                      host name or IP for autoVNCR
--       db_vers                       numeric cloud database version
--       db_type                       type of database
--
-- Notes:
--     This is the final step of addDatabase().  The master GSM invokes
--     this routine to complete "add database" processing.  The status,
--     scan_address, and ons_port of the database will be updated.  In
--     addition, a "database done" AQ notification will be made.
-------------------------------------------------------------------------------                
PROCEDURE addDatabaseDone( db_unique_name           IN varchar2,
                           database_pool_name       IN varchar2,
                           scan_address             IN varchar2 default NULL,
                           ons_port                 IN number default NULL,
                           hostname                 IN varchar2 default NULL,
                           db_vers                  IN number default NULL,
                           db_type                  IN char default 'U' );
-------------------------------------------------------------------------------
--
-- PROCEDURE     updateDatabaseStatus
--
-- Description:
--       Updates runtime status information for database
--
-- Parameters:
--       db_unique_name:               db_unique name for the database 
--       database_pool_name:           The name of the database pool.
--       status:                       Configuration status to give the database.
--       db_vers                       GSM internal DB version
--
-- Notes:
--     The master GSM invokes this routine to notify other GSMS on db status. 
--     If mastership will be switched, new master will be aware of current db 
--     status
-------------------------------------------------------------------------------
PROCEDURE updateDatabaseStatus ( db_unique_name      IN varchar2,
                                 database_pool_name  IN varchar2  default NULL,
                                 status              IN char DEFAULT NULL,
                                 db_vers             IN NUMBER DEFAULT NULL ); 

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyDatabaseDDLState
--
-- Description:
--       Updates DDL application results for given Database
--
-- Parameters:
--       db_unique_name:               db_unique name for the database 
--       ddlid:                        Id of failed DDL (NULL if DDL applied succesfully)
--       ddl_error                     DDL Error message
--       deploy_flag                   Chunk assignment notifier
--
-- Notes:
--     The master GSM invokes this routine to notify other GSMS on DDL status and
--     updat eit in catalog. 
--     If mastership will be switched, new master will be aware of current db 
--     status
-------------------------------------------------------------------------------
PROCEDURE modifyDatabaseDDLState ( db_unique_name      IN varchar2,
								   ddlid               IN NUMBER DEFAULT NULL,
								   ddl_error           IN VARCHAR2 DEFAULT NULL,
								   deploy_flag         IN NUMBER DEFAULT NULL);                                  
---------------------------------------------------------------------------------
--
-- PROCEDURE     removeDatabase
--
-- Description:
--       Remove a database from a database pool.      
--
-- Parameters:
--       db_unique_name:         db_unique name for the database to
--                                 add to the pool.
--       database_pool_name:     The name of the database pool.
--       action:                 logical:  Mark the database entry as removed 
--                                   (also generate change message)
--                               physical: Physically remove the database entry 
--                                   (but do not generate a change message)
--       force:                  Interactive user supplied the "-force" 
--                                 parameter.
--       gen_aq_notification:    Only valid if action = "physical"
--                               gen_aq_off:  Don't generate an AQ notification
--                               gen_aq_on:   Generate an AQ notification
--
-- Notes:
--    The "Remove Database" command is implemented in two phases:
--       1. GSMCTL invokes this routine and it: sets the status for the 
--          database to "R" (for removed), and generates a GSM change
--          message indicating that a Remove Database was done.
--       2. The Master GSM is notified of the change log entry and then
--          calls this routine again to physically remove the database
--          entry from the catalog.  By deferring the removal of the catalog
--          entry, the Master GSM is able to use the database credentials in 
--          the catalog to make the necessary changes on the database.
--
--    This routine may also be called with "physical" flag when an Add
--    Database command fails in order to drop the catalog database entry
--    for the database that could not be added.  In that case,
--    "gen_aq_notification" will be set to "gen_aq_off".
--
--    No checking is done other than verifying that the database is in the
--    catalog.  Entries from service_preferred_available are also removed. 
--
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------

PROCEDURE removeDatabase( db_unique_name           IN varchar2,
                          database_pool_name       IN varchar2 default NULL,
                          action                   IN number default logical,
                          force                    IN number default NULL,
                          gen_aq_notification      IN number default gen_aq_on,
                          ignore_missing           IN number 
                             default dbms_gsm_common.isFalse );


PROCEDURE removeShard (shard_list    IN name_list_type 
                              DEFAULT CAST(NULL AS name_list_type),
		       shardspace_list    IN name_list_type 
                              DEFAULT CAST(NULL AS name_list_type),
                       shardgroup_list    IN name_list_type 
                              DEFAULT CAST(NULL AS name_list_type),
                       force IN number DEFAULT NULL);

PROCEDURE removeCDB (cdb_list IN name_list_type 
                              DEFAULT CAST(NULL AS name_list_type),
                     force IN number DEFAULT NULL);


-------------------------------------------------------------------------------
--
-- PROCEDURE     addService
--
-- Description:
--       Add a service to a database pool.      
--
-- Parameters:
--
--   Note: all constants are defined in package dbms_gwm_common.
--
--       database_pool_name:  Name of the database pool hosting the service
--
--       service_name: Name of the service.  If the name has a "." in it
--                     then this name will also be used as the network
--                     service name.  Otherwise the network service name
--                     will be:
--                     <service_name>.<database_pool_name>.<cloud_name>
--
--       preferred_all: Define which databases should host the service.
--                      Allowed values are:
--           select_dbs - will select preferred and available databases in
--                        "preferred_dbs" and "available_dbs".
--           prefer_all_dbs - all databases in the pool are "preferred" 
--                            databases for this service.
--
--       preferred_dbs: list of database names to be preferred databases for
--                      the service.  "preferred_all" should be set to 
--                      "select_dbs".
--
--       available_dbs: list of database names to be available databases for
--                      the service.  "preferred_all" should be set to
--                      "select_dbs".
--
--       svc_locality: Specify the degree of service afinity to a region.
--                     Allowed values are:
--           service_anywhere - A client connection request is routed to the
--                              the best database that can satisfy the CLB
--                              goal for the requested service.
--           service_local_only - A client connection request is routed to the
--                                best database in the client region that can
--                                satisfy the CLB goal for the requested
--                                service.
--
--       region_failover: This policy is in effect when "svc_locality" is 
--                        set to "service_local_only".  Allowed values are:
--           region_failover_on - If there are no databases in the local
--                                region offering a service, instead of denying
--                                the client request, it is forwarded to the
--                                best database in another region that has
--                                the requested service started.
--           region_failover_off - Client connection requests are not 
--                                 forwarded outside the region.
--
--       db_role: Specifies the role a database must have before the service
--                can be started on it. This parameter is only valid for 
--                services in a Data Guard broker configuration.
--                Allowed values are:
--           db_role_none -  the service can be started on a database with
--                           any role.
--           db_role_primary - the service will only be started on a 
--                             database with primary role.
--           db_role_phys_stby - the service will only be started on a 
--                               physical standby database.
--           db_role_log_stby - the service will only be started on a
--                              logical standby database.
--           db_role_snap_stby - the service will only be started on a
--                               snapshot standby database.
--
--       failover_primary: Enables a service for failover to a primary
--                         database.  Applicable to only services with
--                         "db_role" = "db_role_phys_stby".
--                         Allowed values are:
--           failover_primary_off - turns off failover to the primary
--           failover_primary_on - turns on failover to the primary
--
--       rlb_goal: Run-time load balancing goal
--                 Allowed values are:
--           rlb_goal_none - Turns off run time load balancing.
--           rlb_goal_service_time
--           rlb_goal_throughput
--
--       clb_goal: Connection time load balancing goal
--                 Allowed values are:
--           clb_goal_none - Turns off connection load balancing.
--           clb_goal_short
--           clb_goal_long
--
--       ha_notification: HA notifications for this service
--                        Allowed values are:
--           ha_notification_off
--           ha_notification_on
--
--       taf_policy: TAF policy specification.
--                   Allowed values are:
--           taf_none
--           taf_basic
--           taf_preconnect
--
--       restart_policy: Management policy.
--                       Allowed values are:
--           policy_manual
--           policy_automatic
--
--       distr_trans: Enables distributed transaction processing.
--                    Allowed values are:
--           dtp_off
--           dtp_on
--
--       lag: Specifies if and how much lag is allowed for this service.
--            Allowed values are:
--           any_lag - any lag is tolerated for this service.
--           specified_lag - the lag specified in "max_lag" is the
--                           lag tolerated for this service.  This
--                           parameter is only valid for services
--                           in a Data Guard broker configuration.
--
--       max_lag: maximum lag if lag = "specified_lag"
--
--       TAF parameters:
--         failover_method: TAF failover method.  Allowed values are:
--            failover_none
--            failover_basic
--
--         failover_type: TAF failover type.  Allowed values are:
--            failover_type_none
--            failover_type_session
--            failover_type_select
--            failover_type_transact -
--
--         failover_retries: TAF failover retries
--
--         failover_delay: TAF failover delay.
--
--       Aplication continuity:
--         failover_restore: NONE or LEVEL1
--
--       edition: database edition
--
--       pdb: plugable database id
--
--       Parameters for transaction continuity:
--         commit_outcome: Allowed values are:
--           commit_outcome_off
--           commit_outcome_on
--
--         retention_timeout:
--
--         replay_initiation_timeout:
--
--         session_state_consistency: Allowed values are:
--           session_state_static
--           session_state_dynamic
--
--       sql_translation_profile: Directs how to interpret non-Oracle SQL
--       
-- Notes:
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
--
--    Status of the service is set to:
--        'P' (stopped) in the "service" table
--        'E' (enabled) in the "service_preferred_available" table
--    
-------------------------------------------------------------------------------
PROCEDURE addService( database_pool_name        IN varchar2 default NULL,
                      service_name              IN varchar2,
                      preferred_all             IN number default
                                          dbms_gsm_common.prefer_all_dbs,
                      preferred_dbs             IN name_list_type,
                      available_dbs             IN name_list_type,
                      svc_locality              IN number default 
                                          dbms_gsm_common.service_anywhere,
                      region_failover           IN number default
                                          dbms_gsm_common.region_failover_off,
                      db_role                   IN number default 
                                                dbms_gsm_common.db_role_none,
                      failover_primary          IN number default 
                                          dbms_gsm_common.failover_primary_off,
                      rlb_goal                  IN number default 
                                          dbms_gsm_common.rlb_goal_none,
                      clb_goal                  IN number default 
                                          dbms_gsm_common.clb_goal_none,
                      ha_notification           IN number default 
                                          dbms_gsm_common.ha_notification_on,
                      taf_policy                IN number default 
                                          dbms_gsm_common.taf_none, 
                      restart_policy            IN number default 
                                          dbms_gsm_common.policy_automatic,
                      distr_trans               IN number default 
                                          dbms_gsm_common.dtp_off,
                      lag                       IN number default
                                          dbms_gsm_common.any_lag,
                      max_lag                   IN number default 0, 
                      failover_method           IN varchar2 default 
                                          dbms_gsm_common.failover_none,
                      failover_type             IN varchar2 default 
                                          dbms_gsm_common.failover_type_none,
                      failover_retries          IN number default NULL,
                      failover_delay            IN number default NULL,
                      edition                   IN varchar2 default NULL,
                      pdb                       IN varchar2 default NULL,
                      commit_outcome            IN number default NULL,
                      retention_timeout         IN number default NULL,
                      replay_initiation_timeout IN number default NULL,
                      session_state_consistency IN varchar2 default NULL,
                      sql_translation_profile   IN varchar2 default NULL,
                      table_family              IN varchar2 default NULL,
                      drain_timeout             IN NUMBER   default NULL,
                      stop_option               IN varchar2 default NULL,
                      failover_restore          IN varchar2 default
                                         dbms_gsm_common.failover_restore_none);

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyService
--
-- Description:
--      Modify one or more attributes of a service.       
--
-- Parameters:
--      See addService() for a description.
--
-- Notes:
--      Changes are reflected only in new connections to the service.
--
--      edition and sql_translation_profile parameters may be set to NULL
--      by passing literal 'null' to them.
--      
--      database_pool_name can be NULL if there is only one database pool
--      in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE modifyService( database_pool_name        IN varchar2 default NULL,
                         service_name              IN varchar2,
                         svc_locality              IN number default NULL, 
                         region_failover           IN number default NULL,
                         db_role                   IN number default NULL,
                         failover_primary          IN number default NULL,
                         rlb_goal                  IN number default NULL,
                         clb_goal                  IN number default NULL,
                         ha_notification           IN number default NULL,
                         taf_policy                IN number default NULL,
                         restart_policy            IN number default NULL,
                         distr_trans               IN number default NULL,
                         lag                       IN number default NULL,
                         max_lag                   IN number default NULL,
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
                         force                     IN number
                            default dbms_gsm_common.isFalse,
                         drain_timeout             IN NUMBER   default NULL,
                         stop_option               IN varchar2 default NULL,
                         failover_restore          IN varchar2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     addServiceToDBs
--
-- Description:
--      Add an existing service to additional preferred and/or available
--      databases.       
--
-- Parameters:
--      database_pool_name   -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      preferred_dbs        -   A list of preferred databases to add the
--                               service to.
--      available_dbs        -   A list of available databases to add the
--                               service to.     
--
-- Notes:
--      It is an error if "preferred_all" is set for the service.
--
--      At least one preferred or available database should be set.
--
--      None of the preferred or available databases should already be 
--      a database for the service.
-- 
--      database_pool_name can be NULL if there is only one database pool
--      in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE addServiceToDBs( database_pool_name       IN varchar2 default NULL,
                           service_name             IN varchar2,
                           preferred_dbs            IN name_list_type,
                           available_dbs            IN name_list_type );

-------------------------------------------------------------------------------
--
-- PROCEDURE     moveServiceToDB
--
-- Description:
--      Move an existing service from one database to another.
--
-- Parameters:
--      database_pool_name   -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      old_db               -   Database to move service from.
--      new_db               -   Database to move service to.
--      force                -   User supplied the "force" parameter.
--
-- Notes:
--      The "force" parameter is passed on to the master GSM.
--
--      The service should not already be defined on the new database.
--
--      See removeDatabase for definitions for "force" parameter.
--
--      database_pool_name can be NULL if there is only one database pool
--      in the cloud.  In which case the command will default to that pool. 
-------------------------------------------------------------------------------
PROCEDURE moveServiceToDB( database_pool_name       IN varchar2 default NULL,
                           service_name             IN varchar2,
                           old_db                   IN varchar2,
                           new_db                   IN varchar2,
                           force                    IN number default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     makeDBsPreferred
--
-- Description:
--      Changes the specified databases to preferred databases for the
--      service.
--
-- Parameters:
--      database_pool_name   -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      dbs                  -   A list of names of the databases to make
--                               preferred for the service.
--      force                -   User supplied "force" parameter.
--                               TODO: what does it mean in this case?
--
-- Notes:
--      The service should already be defined on the databases.
--
--      The databases should be in the database pool and either not have
--      the service defined on them or be available databases for the
--      service.
--
--      It is an error if the service has "preferred_all" set.
--
--      See removeDatabase for definitions for "force" parameter.
-- 
--      database_pool_name can be NULL if there is only one database pool
--      in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE makeDBsPreferred( database_pool_name  IN varchar2 default NULL,
                            service_name        IN varchar2,
                            dbs                 IN name_list_type,
                            force               IN number default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyServiceConfig
--
-- Description:
--      Changes the set of preferred and available databases for a service.
--
-- Parameters:
--      database_pool_name   -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      preferred_all        -   Set to dbms_gsm_common.prefer_all_dbs if
--                               all databases in the pool should be set
--                               to preferred. 
--      preferred_dbs        -   The names of the databases to be set
--                               preferred for the service.
--      available_dbs        -   The names of the databases to be set
--                               available for the service.
--      force                -   User supplied "force" parameter.
--
-- Notes:
--      The "force" parameter is passed on to the master GSM.
--
--      If "preferred_all" is set to "prefer_all_dbs" then "preferred_dbs"
--      and "available_dbs" are ignored.
--
--      If "prefer_dbs" is set then the current preferred/available list is
--      cleared and new lists are built based on "preferred_dbs" and
--      "available_dbs".
--
--      See removeDatabase for definitions for "force" parameter.
--
--      database_pool_name can be NULL if there is only one database pool
--      in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE modifyServiceConfig( database_pool_name  IN varchar2 default NULL,
                               service_name        IN varchar2,
                               preferred_all       IN number,
                               preferred_dbs       IN name_list_type,
                               available_dbs       IN name_list_type,
                               force               IN number default NULL );
-------------------------------------------------------------------------------
--
-- FUNCTION     getServiceDBParams
--
-- Description:
--      Converts DB paramters in name_list_type to a parameter string.
--      Used primarily by GDSCTL/GSM to return parameter strings from
--      database object types
--
-- Parameters:
--      dbparam_names - list of parameter names
--      dbparam_values - list of parameter values
--
-- Returns:
--       varchar - string containing parameters in NVP format
--             
-- Notes:
-------------------------------------------------------------------------------
FUNCTION getServiceDBParams (dbparams IN dbparams_list)
RETURN varchar2;

-------------------------------------------------------------------------------
--
-- FUNCTION     getServiceLocalParams
--
-- Description:
--      Converts DB local parameter list types to a parameter string.
--      Used primarily by GDSCTL/GSM to return parameter strings from
--      database object types
--
-- Parameters:
--      dbparams - list of parameter names
--      instances - list of instances
--
-- Returns:
--       varchar - string containing parameters in NVP format
--             
-- Notes:
-------------------------------------------------------------------------------
FUNCTION getServiceLocalParams (dbparams    IN   dbparams_list, 
                                instances   IN   instance_list)
RETURN varchar2;

-------------------------------------------------------------------------------
--
-- PROCEDURE     getInstanceString
--
-- Description:
--      returns a list of preferred/available instances in string form
--
-- Parameters:
--      pool_name            -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      database_name        -   The database on which service is defined
--      instance_string      -   String containing instance list for this
--                               service in NVP format
--             
--
-------------------------------------------------------------------------------
PROCEDURE getInstanceString (service_name    IN    varchar2,
                             pool_name       IN    varchar2,
                             database_name   IN    varchar2,
                             instance_string OUT   varchar2);

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyServiceOnDB
--
-- Description:
--      Modifies the attributes of a service specific to a (RAC) database.
--
-- Parameters:
--      database_pool_name   -   The database pool in which the service
--                               is defined.
--      service_name         -   An existing service.
--      database_name        -   The database on which to change the
--                               service attributes.
--      params               -   A copy of the rest of the parameters
--                               supplied by the user.  Maximum size is
--                               1024.
--      dbparam_names        -   list of DB specific parameter names
--      dbparam_value        -   list of matching values for above names
--      palist_op            -   operation for preferred/available list
--                               'A' - Add this as new list (old list erased)
--                               'M' - Existing list is modified
--                               'D' - remove values fom existing list
--      preferred_list       -   list of preferred instances
--      available_list       -   list of available instances
--             
-- Notes:
--      The command is implemented in the Master GSM.  The catalog database
--      just passes the request on to the GSM.
--
-------------------------------------------------------------------------------
PROCEDURE modifyServiceOnDB( database_pool_name  IN varchar2 default NULL,
                             service_name        IN varchar2,
                             database_name       IN varchar2,
                             params              IN varchar2 DEFAULT NULL,
                             dbparam_names       IN name_list_type
                                 DEFAULT CAST(NULL AS name_list_type),
                             dbparam_values      IN name_list_type
                                 DEFAULT CAST(NULL AS name_list_type),
                             palist_op           IN char DEFAULT NULL,
                             preferred_list      IN name_list_type
                                 DEFAULT CAST(NULL AS name_list_type),
                             available_list      IN name_list_type
                                 DEFAULT CAST(NULL AS name_list_type),
                             force               IN number
                                 DEFAULT dbms_gsm_common.isFalse);
-------------------------------------------------------------------------------
--
-- PROCEDURE     removeService
--
-- Description:
--      Remove a service from a database pool.       
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.            
--
-- Notes:
--     No checking is done at this time other than verifying that the service
--     is in the "service" table.  Entries are also removed from 
--     the "service_preferred_available" table.
--
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE removeService( database_pool_name       IN varchar2 default NULL,
                         service_name             IN varchar2 );
						 
-------------------------------------------------------------------------------
--
-- PROCEDURE     removeServiceInternal
--
-- Description:
--      Remove a service from a database pool; called by GSM directly    
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       CalledByGSM           1 if called by GSM, 0 otherwise    
--       gen_aq_notification   gen_aq_on or gen_aq_off
--       force                 force removal even if service is running        
--
-- Notes:
-------------------------------------------------------------------------------
PROCEDURE removeServiceInternal( database_pool_name   IN varchar2 default NULL,
                                 service_name         IN varchar2, 
                                 CalledByGSM          IN number default 0,
                                 gen_aq_notification  IN number 
                                   default gen_aq_on,
                                 force                IN number default NULL );      
-------------------------------------------------------------------------------
--
-- PROCEDURE     startService
--
-- Description:
--       Start a service in a database pool.      
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       database_name:        The name of the database (db_unique_name).
--
-- Notes:
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
-- 
--    If service name is NULL then starts all the services in the pool.
--
--    If database_name is NULL then starts the service on all databases
--    where the service is defined. 
--
--    Status of service is changed to "S" in "service" table      
-------------------------------------------------------------------------------
PROCEDURE startService( database_pool_name      IN varchar2 default NULL,
                        service_name            IN varchar2 default NULL,
                        database_name           IN varchar2 default NULL );


-------------------------------------------------------------------------------
--
-- PROCEDURE     stopService
--
-- Description:
--       Stop a service in a database pool.      
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       database_name:        The name of the database (db_unique_name).
--       force:                The interactive user specified the "-force"
--                                parameter.   
--       options               Various stop option introduced afet 12.2 and
--                             not relevant to GSM processing
-- Notes:
--    See removeDatabase for definitions for "force" parameter.
--
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
--
--    If service name is NULL then stops all the services in the pool.
--
--    If database_name is NULL then stops the service on all databases
--    where the service is defined. 
--
--    Status of service is changed to "P" in "service" table    
-------------------------------------------------------------------------------
PROCEDURE stopService( database_pool_name       IN varchar2 default NULL,
                       service_name             IN varchar2 default NULL,
                       database_name            IN varchar2 default NULL,
                       force                    IN number default NULL,
                       options                  IN varchar2 default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     enableService
--
-- Description:
--       Enable a service in a database pool.      
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       database_name:        The name of the database (db_unique_name).
--            
-- Notes:
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
--  
--    If service name is NULL then enables all the services in the pool.
--
--    If database_name is NULL then enables the service on all databases
--    where the service is defined.  
--
--    Status of service is changed to "E" in "service_preferred_available" 
--    table.   
-------------------------------------------------------------------------------
PROCEDURE enableService( database_pool_name      IN varchar2 default NULL,
                         service_name            IN varchar2 default NULL,
                         database_name           IN varchar2 default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     disableService
--
-- Description:
--       Disable a service in a database pool.     
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       database_name:        The name of the database (db_unique_name).           
--
-- Notes:
--    database_pool_name can be NULL if there is only one database pool
--    in the cloud.  In which case the command will default to that pool.
-- 
--    If service name is NULL then disables all the services in the pool.
--
--    If database_name is NULL then disables the service on all databases
--    where the service is defined. 
--
--    Status of service is changed to "E" in "service_preferred_available" 
--    table.     
-------------------------------------------------------------------------------
PROCEDURE disableService( database_pool_name      IN varchar2 default NULL,
                          service_name            IN varchar2 default NULL,
                          database_name           IN varchar2 default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     relocateService
--
-- Description:
--       Relocate a service from one database to another. 
--       This operation does not change the underlying configuration of the
--       service.     
--
-- Parameters:
--       database_pool_name:   The name of the database pool.
--       service_name:         The name of the service.
--       old_database_name:    The name of the database (db_unique_name) from
--                                which to move the service.
--       new_database_name:    The name of the database (db_unique_name) to
--                                which to move the service.
--       force:                The interactive user specified the "-force"
--                                parameter.   
--
-- Notes:
--   The command is implemented in the Master GSM.  The catalog database
--   just passes the request on to the GSM.
--
--   See removeDatabase for definitions for "force" parameter.
--
--   database_pool_name can be NULL if there is only one database pool
--   in the cloud.  In which case the command will default to that pool.
-------------------------------------------------------------------------------
PROCEDURE relocateService( database_pool_name      IN varchar2 default NULL,
                           service_name            IN varchar2,
                           old_database_name       IN varchar2,
                           new_database_name       IN varchar2,
                           force                   IN number default NULL );

-------------------------------------------------------------------------------
--
-- PROCEDURE     syncDatabase
--
-- Description:
--       Send database sync AQ message to GSM
--
-- Parameters:
--       database_pool_name:       The name of the database pool.
--       database_name:            Name of database to sync (optional)
--
-- Notes:
--       Null database name will sync all databases in the pool
-------------------------------------------------------------------------------
PROCEDURE syncDatabase ( database_pool_name    IN varchar2 DEFAULT NULL,
                         database_name          IN varchar2 DEFAULT NULL);

PROCEDURE deploy (skip_move   in  NUMBER default dbms_gsm_common.isFalse);
PROCEDURE deploy_async(skip_move   in  NUMBER default dbms_gsm_common.isFalse);
PROCEDURE deploy_int (msg_id IN NUMBER,
                      skip_move IN number DEFAULT dbms_gsm_common.isFalse);

PROCEDURE getInfo (pool_name          IN  varchar2 DEFAULT NULL,
                   shardgroup_name    IN  varchar2 DEFAULT NULL,
                   cloud_name         OUT varchar2,
                   use_sysdba         OUT number,
                   shardspace_name    IN  varchar2 DEFAULT NULL);

PROCEDURE getInfo (pool_name          IN  varchar2 DEFAULT NULL,
                   shardgroup_name    IN  varchar2 DEFAULT NULL,
                   cloud_name         OUT varchar2,
                   use_sysdba         OUT number,
                   shardspace_name    IN  varchar2 DEFAULT NULL,
                   charset            OUT varchar2,
                   ncharset           OUT varchar2);
	
					   
----------------------------------------------------------------------------
--
-- PROCEDURE         getDBInfo
--
-- Description:
--       Get database specific info stored on catalog for cross validation
--
-- Parameters:
--       db_unique_name  - name of the database to query
--       minobj_number   - minobj_number for this database
--       maxobj_number   - maxobj_number for this database
--
----------------------------------------------------------------------------
PROCEDURE getDBInfo (db_unique_name   IN  varchar2,
                     minobj_number    OUT number,
                     maxobj_number    OUT number,
                     db_dbid          OUT number);

-------------------------------------------------------------------------------
-- PROCEDURE OGGReplicationDone (change    IN   gsm_change_message);
-------------------------------------------------------------------------------
--
-- PROCEDURE: executeOGGProcedure - executes a multi-shard OGG command
--
-- Description:
--    This procedure updates meta-data as needed, and then sends
--    AQ ogg_multi_target (93). When the GSM is done executing command
--    it updates gsm_requests and calls genericProcedureDone.
--
-- Parameters:
--       pool_name:       The name of the sharded pool
--       targets:         Target databes for the AQ message
--       payload:         command payload
--       gsm_req#         output, returns the id of the AQ message
-------------------------------------------------------------------------------
PROCEDURE executeOGGProcedure (pool_name IN varchar2, targets IN number_list,
                               payload   IN varchar2, gsm_req# OUT number);
------------------------------------------------------------------------------
--
-- PROCEDURE: genericProcedureDone - multi-shard OGG command is complete
--
-- Notes: this function is called after the GSM updates gsm_requests to say
--    that it has completed executing command for AQ 92/93
------------------------------------------------------------------------------
PROCEDURE genericProcedureDone (sequence_id  NUMBER,
                                change_id    NUMBER,
                                status       CHAR,
                                payload      VARCHAR2);
-------------------------------------------------------------------------------
--
-- PROCEDURE     executeDDLRequest
--
-- Description:
--       sends ddl statement
--
-- Parameters:
--       database_pool_name:       The name of the sharded pool.
--       ddl_request:              DDL request text
--       schema_name:              current session schema name
--
-- Notes:
--       Null database name will sync all databases in the pool
-------------------------------------------------------------------------------
--PROCEDURE executeDDLRequest ( database_pool_name    IN varchar2 DEFAULT NULL,
--							  ddl_request           IN CLOB DEFAULT NULL,
--							  schema_name           IN VARCHAR2);  
--							  
--
-------------------------------------------------------------------------------
--
-- PROCEDURE     recoverShardDDL
--
-- Description:
--       Recovers DDL on given shard:
--       - starts from the point of first failure
--       - if ignore action is specified marks DDL operation with flag
--       - if skip action is specified skips first DDL during recovery
--       - if shard is ok, does recovery starting from last ddl  
--
-- Parameters:
--       database_name:    If passed, GSM will try to recover on this db instead of randomly
--                         chosen primary DB
--       ddlaction:        Type of DDL action
--
-- Notes:
--       
-------------------------------------------------------------------------------
PROCEDURE recoverShardDDL ( 
							database_name IN varchar2 DEFAULT NULL ,
							ddlaction     IN NUMBER default dbms_gsm_common.execddl_default);  
--															
-------------------------------------------------------------------------------
--
-- PROCEDURE     catRollback
--
-- Description:
--       Perform rollback operation on catalog when distributed
--       change has failed on target database(s)
--
-- Parameters:
--       change       GSM change request
--
-- Notes:
--       This procedure is called from a trigger when gsm_requests status
--       is updated to 'A' (Aborted) by the GSM server
-------------------------------------------------------------------------------
PROCEDURE catRollback (change          IN   gsm_change_message,
                       old_instances   IN   instance_list);

-------------------------------------------------------------------------------
--
-- PROCEDURE     requestDone
--
-- Description:
--       Perform completion actions when change request is done
--
-- Parameters:
--       change      GSM change request
--
-- Notes:
--       This procedure is called from a trigger when gsm_requests status
--       is updated to 'D' (Done) or the row is deleted by the GSM server
-------------------------------------------------------------------------------
PROCEDURE requestDone (change    IN   gsm_change_message,
                       status    IN   char);

PROCEDURE requestDelete (request#   IN   number,
                         change    IN   gsm_change_message,
                         status    IN   char);
-------------------------------------------------------------------------------
--
-- PROCEDURE     strtolist
--
-- Description:
--       convert varchar2 string to name_list_type
--
-- Parameters:
--       lstring - string reprsenting a list
--
-- Notes:
--      Primarily for unit testing, this function allows us to call 
--      PL/SQL functions for complex types from SQLPLUS
-------------------------------------------------------------------------------
FUNCTION strtolist (lstring IN VARCHAR2)
return name_list_type;

FUNCTION strtonumlist (lstring IN VARCHAR2)
return number_list;

PROCEDURE AQTest (aq_num         IN   number,
                  targets        IN   number_list,
                  params         IN   varchar2 DEFAULT NULL,
				  update_table   IN   number);

-------------------------------------------------------------------------------
--
-- PROCEDURE    set_key 
--
-- Description:
--       Set PKI Keys and flags
--
-- Parameters:
--     key_name:              key type 
--     key_value:             value of key
--
-------------------------------------------------------------------------------


PROCEDURE set_key(key_type in number,
                  key_value in RAW);

-------------------------------------------------------------------------------
--
-- PROCEDURE    get_key
--
-- Description:
--       get the value of a key by name
--
-- Parameters:
--       key_type:          key type
--
-------------------------------------------------------------------------------
FUNCTION get_key(key_type in number) RETURN RAW;


PROCEDURE addRemoteCred(credential_name IN VARCHAR2, 
                        username    	IN VARCHAR2,
                        password     	IN VARCHAR2,
                        windows_domain 	IN VARCHAR2 default NULL,
                        poolname       IN VARCHAR2 default NULL);

PROCEDURE modifyRemoteCred(credential_name 	IN VARCHAR2, 
                        username    		IN VARCHAR2 default NULL,
                        password     		IN VARCHAR2 default NULL,
                        windows_domain 		IN VARCHAR2 default NULL);

PROCEDURE removeRemoteCred(credential_name IN VARCHAR2);

PROCEDURE addFile(filename IN VARCHAR2, 
                  contents IN CLOB,
                  poolname IN VARCHAR2 default NULL);

PROCEDURE retrieveFile(filename IN VARCHAR2, 
                       contents OUT CLOB);

PROCEDURE modifyFile(filename 	IN VARCHAR2, 
                     contents	IN CLOB);

PROCEDURE removeFile(filename IN VARCHAR2);

PROCEDURE moveChunk (chunks        IN  name_list_type,
                     source        IN  varchar2,
                     target        IN  varchar2 default NULL,
                     timeout       IN  number default 0,
                     verbose       IN  number default 0,
                     copy          IN  number default 0);
                     
PROCEDURE moveChunkAtomic (chunks        IN  name_list_type,
                     source        IN  varchar2,
                     target        IN  varchar2 default NULL,
                     timeout       IN  number default 0,
                     verbose       IN  number default 0,
                     copy          IN  number default 0,
                     internalCall  IN  number default  
                                       dbms_gsm_common.isFalse,
                     mmode         IN  number default 1 );                     

PROCEDURE updateMovechunk (chunks       IN     name_list_type
                            DEFAULT CAST(NULL AS name_list_type),
                           db_list      IN     name_list_type
                            DEFAULT CAST(NULL AS name_list_type),
                           verbose      IN     number default 0,
                           action       IN     number
                            default dbms_gsm_utility.restart_move);                     
PROCEDURE updateMoveState (chunk        IN     NUMBER,
                           gsmreq_id    IN     NUMBER,
                           state        IN     number default 0,
                           is_term      IN     number
                                           DEFAULT dbms_gsm_common.isFalse);

PROCEDURE confirmMove (source_db      IN   number,
                       target_db      IN   number,
                       chunk_id       IN   number);

PROCEDURE moveFailed (source_db     IN   number,
                      chunk_id      IN   number,
                      err_id        IN   number);

PROCEDURE splitChunk (chunks        IN name_list_type,
                      shardspaces   IN name_list_type);
                      
PROCEDURE checkSync (db_name    IN    varchar2);
FUNCTION GSMProcessingDeploy
RETURN boolean;

---Initial assignments of chunks to shards for crosshard query
PROCEDURE initCrossShards           (reptype   IN NUMBER);
---reassign chunks when an OGG shard goes down
PROCEDURE updateCrossShardOGGDBDown (db_num    IN NUMBER);
---reassign chunks when an OGG shard comes up
PROCEDURE updateCrossShardOGGDBUp   (db_num    IN NUMBER);
---reassign a single chunk on OGG
PROCEDURE assignChunkLocationsOGG   (chk       IN NUMBER,
                                     source_db IN NUMBER, 
                                     target_db IN NUMBER);

-------------------------------------------------------------------------------
--
-- PROCEDURE    setRuntimeStatus
--
-- Description:
--       stes runtime status for database
--
-- Parameters:
--       source_db:          database name
--       db_falgs            runtime state flags
-------------------------------------------------------------------------------
PROCEDURE setRuntimeStatus (source_db      IN   VARCHAR2,
                            db_flags IN NUMBER );   
                            
                                                
FUNCTION getShardConnectionInfo ( chunks_lst IN chunk_list, access_type IN NUMBER,
                                  exclusion_list  IN shardid_list,
                                  avail_chunks_pc OUT NUMBER) 
         RETURN shard2chunk_map;
         

PROCEDURE getShardConnectionInfo ( chunks_lst IN chunk_list, 
                                   access_type IN NUMBER,
                                   exclusion_list  IN shardid_list,
                                   p_shardlist OUT shard_list_t,
                                   chunks_cnt OUT NUMBER,
                                   avail_chunks_pc OUT NUMBER); 

 PROCEDURE startObserver ( database_name          IN varchar2 ,
                           BC_ID OUT NUMBER);    
                           
PROCEDURE execSQLOnShard    (shard_list     IN name_list_type
                              DEFAULT CAST(NULL AS name_list_type),
                             primary_only   IN  number default 0,
                             on_catalog     IN  number default 0,
                             statement      IN  varchar2,
                             write_ddl_req  IN  number 
                              default dbms_gsm_common.isFalse);                               

PROCEDURE assignChunkLocationsDG(chunk NUMBER, shgroup_id NUMBER);                                  

--*****************************************************************************
-- End of Package Public Procedures
--*****************************************************************************

END dbms_gsm_pooladmin;

/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
