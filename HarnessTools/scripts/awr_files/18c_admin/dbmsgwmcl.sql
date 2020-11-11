Rem
Rem $Header: rdbms/admin/dbmsgwmcl.sql /main/33 2016/12/21 08:31:34 lenovak Exp $
Rem
Rem dbmsgwmcl.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmcl.sql - Global Workload Management Cloud administration
Rem
Rem    DESCRIPTION
Rem      Defines the interfaces for dbms_gsm_cloudadmin package that is
Rem      used for cloud administration performed by GSM and GSMCTL.
Rem
Rem    NOTES
Rem      This package is only loaded on the GSM cloud catalog database.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmcl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmcl.sql
Rem SQL_PHASE: DBMSGWMCL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lenovak     11/21/16 - Bug 25121878: add nodupupdate to
Rem                           createShardCatalog
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    sdball      07/22/16 - Bug 24324684: move sessioninfo inside package
Rem    sdball      01/15/16 - New signature for addVNCR
Rem    dcolello    11/13/15 - add dbms_gsm_xdb package
Rem    dcolello    11/11/15 - add agent_port parameter to cloud procedures
Rem    sdball      09/30/15 - Add isSysUpdate
Rem    dcolello    07/28/15 - add createShardCatalog
Rem    dcolello    06/25/15 - add setEncryptedDDL
Rem    dcolello    12/10/14 - add agent_password to modifyCatalog
Rem    lenovak     12/10/14 - modify catalg' region
Rem    sdball      06/03/14 - Add masterNotAllowed
Rem    cechen      03/31/14 - PKI support for patchset upgrade 
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    sdball      01/09/14 - Updates fro sharding
Rem    sdball      01/03/14 - Fixed for new shard schema
Rem    cechen      11/01/13 - move PKI to dbmsgwmpl.sql
Rem    cechen      08/22/13 - add PKI key set/get manipulation
Rem    lenovak     07/29/13 - shard support
Rem    lenovak     07/12/13 - force catalog creation
Rem    sdball      05/22/13 - New interface for getMasterLock
Rem    itaranov    04/24/13 - Import/export support functions, gsm killing
Rem    sdball      04/08/13 - Add region_weights to modifyRegion
Rem    nbenadja    04/01/13 - Add checkGSMDown procedure.
Rem    sdball      02/14/13 - Add cancelAllChanges
Rem    sdball      01/14/13 - Consolidate boolean values
Rem    sdball      08/14/12 - Add oracle_home and hostname parameters to addGSM
Rem    sdball      08/06/12 - Add MaskPolicy
Rem    sdball      06/13/12 - Support for number of instances
Rem    sdball      05/18/12 - Add VerifyCatalog
Rem    sdball      02/15/12 - Variables for GSM limits
Rem    sdball      01/23/12 - Add rougeGSM
Rem    sdball      01/12/12 - Add syncParameters
Rem    sdball      12/05/11 - change gsm_pooladmin_role to gsm_gsm_pooladmin_role
Rem    sdball      11/30/11 - Add auto VNCR functionality
Rem    sdball      11/28/11 - auto VNCR functionality
Rem    lenovak     11/08/11 - remove database pool admin
Rem    lenovak     07/22/11 - vncr support
Rem    mjstewar    07/22/11 - Allow buddy region to be NULL for modifyRegion
Rem    mjstewar    04/27/11 - Second GSM transaction
Rem    mjstewar    02/02/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL dbmsgwmcl.log

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Database package for GSM cloud administrator functions.
--*****************************************************************************

CREATE OR REPLACE PACKAGE dbms_gsm_cloudadmin AS


--*****************************************************************************
-- Package Public Types
--*****************************************************************************

-----------------
-- Name list type 
-----------------
TYPE name_list_type IS TABLE OF varchar2(dbms_gsm_common.max_ident)
   index by binary_integer;

--*****************************************************************************
-- Package Public Constants
--*****************************************************************************

gsm_master_lock_name    constant    varchar2(19) := 'ORA$GSM_MASTER_LOCK';
no_lock                 constant    number := 99; -- lock not granted (GDS)
rogueGSM                constant    number := 99;
masterNotAllowed        constant    number := 98; -- GSM is not allowed to
                                                  -- get master lock
MaxGSM                  constant    number := 5;

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************



--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************

maxwait     constant    integer := 32767;            -- Wait forever

FUNCTION ran_create_catalog
RETURN BOOLEAN;

PROCEDURE unset_create_catalog;

-------------------------------------------------------------------------------
--
-- PROCEDURE     getMasterLock
--
-- Description:
--     Request the GSM catalog master lock in exclusive mode.
--
-- Parameters:
--     timeout:  the number of seconds to wait for the lock
--               "maxwait" means to wait forever
--     lock_handle: handle used to identify the lock
--                  should be passed to releaseMasterLock to release the lock
--                  size can be up to 128
--
-- Returns:
--      0 - success
--      1 - timeout
--      2 - deadlock
--      3 - parameter error
--      4 - already own lock
--      5 - illegal lock handle
--     99 - Lock not granted (due to GDS checking)
--
-- Notes:
--     The routine uses dbms_lock.allocate_unique, so will always do a
--     transaction commit.
--
--     Lock is held until it is explicitly released or session terminates.
-------------------------------------------------------------------------------  

FUNCTION getMasterLock( timeout     IN  integer default maxwait,
                        lock_handle OUT varchar2,
                        gsm_name    IN  varchar2 default NULL,
                        gsm_vers    IN  varchar2 default NULL )
 RETURN integer;

-------------------------------------------------------------------------------
--
-- PROCEDURE     releaseMasterLock
--
-- Description:
--     Release the GSM catalog master lock acquired previously by getMasterLock.
--
-- Parameters:
--     lock_handle: handle returned by getMasterLock
--
-- Returns:
--      0 - success
--      3 - parameter error
--      4 - don't own lock
--      5 - illegal lock handle
--
-- Notes:
--
-------------------------------------------------------------------------------  

FUNCTION releaseMasterLock( lock_handle IN varchar2 )
 RETURN integer;


-------------------------------------------------------------------------------
--
-- PROCEDURE     createCloud
--
-- Description:
--     Creates a cloud entry in the cloud catalog.
--
-- Parameters:
--     cloud_name: name to give the cloud.
--
-- Notes:
--     Currently the catalog only supports one cloud.
-------------------------------------------------------------------------------      
PROCEDURE createCatalog(cloud_name IN varchar2 default NULL,
                       autoVNCR IN number default  dbms_gsm_common.isTrue,
                       instances IN number default NULL,
                       force IN number default  dbms_gsm_common.isFalse,
                       agent_password IN varchar2 default NULL);
PROCEDURE createShardCatalog(cloud_name IN varchar2 default NULL,
                       autoVNCR IN number default  dbms_gsm_common.isTrue,
                       force IN number default  dbms_gsm_common.isFalse,
                       sdb IN varchar2 default 'orasdb',
                       repl IN number default dbms_gsm_common.reptype_dg,
                       agent_password IN varchar2 default NULL,
                       repfactor IN number default NULL,
                       chunks IN number default NULL,
                       protectmode IN number default NULL,
                       sharding IN number default dbms_gsm_utility.sh_system,
                       shardspace IN name_list_type default CAST(NULL AS name_list_type),
                       regions IN name_list_type default CAST(NULL AS name_list_type),
                       instances IN number default NULL,
                       agent_port IN number default NULL,
                       no_dupupdate IN number default  dbms_gsm_common.isFalse);
PROCEDURE createCloud( cloud_name IN varchar2 default NULL,
                       autoVNCR IN number default  dbms_gsm_common.isTrue,
                       instances IN number default NULL,
                       force IN number default  dbms_gsm_common.isFalse,
                       agent_password IN varchar2 default NULL,
                       repl IN number default NULL,
                       repfactor IN number default NULL,
                       chunks IN number default NULL,
                       protectmode IN number default NULL,
                       sharding IN number default dbms_gsm_utility.not_sharded,
                       agent_port IN number default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyCatalog
--
-- Description:
--     Modifies information in the cloud catalog
--
-- Parameters:
--     autoVNCR: boolean - isTrue = Turn on autoVNCR
--                         isFalse = Turn off autoVNCR
--     cat_region varchar2  - region where catalog is located
--     agent_password: remote scheduler agent password
--     agent_port: remote scheduler agent registration port

-- Notes:
--     Currently the catalog only supports one cloud.
-------------------------------------------------------------------------------
PROCEDURE modifyCatalog(autoVNCR IN number default NULL, 
                        cat_region IN varchar2 default NULL,
			agent_password IN varchar2 default NULL,
                        agent_port IN number default NULL);
-------------------------------------------------------------------------------
--
-- PROCEDURE     removeCloud
--
-- Description:
--     Removes the cloud entry from the cloud catalog.
--
-- Parameters:
--     cloud_name: name of the cloud to remove.      
--
-- Notes:
--     Currently the catalog only supports one cloud.
------------------------------------------------------------------------------- 
PROCEDURE removeCatalog( cloud_name IN varchar2 default NULL );  -- TODO: remove
PROCEDURE removeCloud( cloud_name IN varchar2 default NULL );


-------------------------------------------------------------------------------
--
-- PROCEDURE     addGSM
--
-- Description:
--     Adds a GSM to the cloud.        
--
-- Parameters:
--     gsm_name:             GSM alias name
--     gsm_endpoint1:        Listener endpoint
--     gsm_endpoint2:        TODO:?
--     local_ons_port:       Local ONS port for ONS server process
--     remote_ons_port:      Remote ONS port of ONS server process
--     region_name:          The GSM region, if NULL will use the default.
--     gsm_number:           Unique number assigned to the GSM
--
-- Notes:
--     Updates the "_remote_gsm" parameter on the catalog database to point
--     to the new GSM.
--
--     region_name can be NULL if there is only one region in the cloud.
--     In which case the GSM will be added to that region.
--
--     No assumptions should be made about gsm_number other than it is 
--     unique for the cloud.  For example, the caller should not assume that it
--     is a monotonically increasing number.
------------------------------------------------------------------------------- 

PROCEDURE addGSM( gsm_name        IN  varchar2,
                  gsm_endpoint1   IN  varchar2,
                  gsm_endpoint2   IN  varchar2,
                  local_ons_port  IN  number,
                  remote_ons_port IN  number,
                  region_name     IN  varchar2 default NULL,
                  gsm_number      OUT number,
                  gsm_oracle_home IN  varchar2 default NULL,
                  gsm_hostname    IN  varchar2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     syncParameters
--
-- Description:
--     Syncronize spfile parameter values using database information        
--
-- Parameters:
--    NONE
--
-- Notes:
--    Currently updates the _gsm and _cloud_name parameters. These values are
--    required for the catalog database instance and will not be set on
--    data-guard standby databases (since createCatalog is never run there). 
--    This function will be executed as part of the database open notifier
--    callback on any primary database that is a catalog database
--
------------------------------------------------------------------------------
PROCEDURE syncParameters;

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyGSM
--
-- Description:
--     Changes a GSM attributes.
--
-- Parameters:
--     gsm_name:             GSM alias name
--     gsm_endpoint1:        Listener endpoint
--     gsm_endpoint2:        TODO:?
--     local_ons_port:       Local ONS port for ONS server process
--     remote_ons_port:      Remote ONS port of ONS server process
--     region_name:          The GSM region.
--
-- Notes:
--     One or more of the attributes can be changed on each call.
--
--     If "gsm_endpoint1" is changed, then will update the "_remote_gsm" 
--     parameter on the catalog database with the new endpoint.
------------------------------------------------------------------------------- 
PROCEDURE modifyGSM( gsm_name        IN  varchar2,
                     gsm_endpoint1   IN  varchar2 default NULL,
                     gsm_endpoint2   IN  varchar2 default NULL,
                     local_ons_port  IN  number   default NULL,
                     remote_ons_port IN  number   default NULL,
                     region_name     IN  varchar2 default NULL );


-------------------------------------------------------------------------------
--
-- PROCEDURE     removeGSM
--
-- Description:
--     Removes a GSM from the cloud.        
--
-- Parameters:
--     gsm_name:             GSM alias name
--            
-- Notes:
--    It is up to the caller to insure that the GSM has been stopped.
--
--    Will remove this GSM endpoint from the "_remote_gsm" parameter on the
--    catalog database.
------------------------------------------------------------------------------- 
PROCEDURE removeGSM( gsm_name        IN  varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     disconnectGSM
--
-- Description:
--     Kills GSM session.        
--
-- Parameters:
--     gsm_name:             GSM alias name
--     kill_level:           if 0 kill sesssion, if 1 the same immediate,
--                           if 2 disconnect session
--            
-- Notes:
--
------------------------------------------------------------------------------- 
PROCEDURE disconnectGSM( gsm_name IN  varchar2, kill_level number default 2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     addVNCR
--
-- Description:
--     Adds VNCR to Cloud        
--
-- Parameters:
--     name:             VNCR name
--     group_id:            VNCR group id
--            
-- Notes:
--    Group id could be NULL. If set, it allows group removal of VNCRs
------------------------------------------------------------------------------- 
PROCEDURE addVNCR( name        IN  varchar2, 
                   group_id in varchar2 default NULL,
                   updateRequestTable  IN number 
                     default dbms_gsm_utility.updateTrue);
                     
PROCEDURE addVNCR( name        IN  varchar2, 
                   group_id in varchar2 default NULL,
               updateRequestTable  IN number 
                 default dbms_gsm_utility.updateTrue,
                 hostname      IN   varchar2 default null,
                 host_id       OUT  number,
                 ignore_dups   IN   boolean default TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     removeVNCR
--
-- Description:
--     removes VNCR from Cloud        
--
-- Parameters:
--     name:             VNCR name
--     group_id:            VNCR group id
--            
-- Notes:
--    One and only one of either group id or name could be NULL. 
------------------------------------------------------------------------------- 
PROCEDURE removeVNCR( name IN  varchar2 default NULL, 
                      group_id in varchar2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE     createSubscriber
--
-- Description:
--     Add an AQ subscriber to the change log queue.
--
-- Parameters:
--     gsm_name:    Subscriber name should be a name of one of the GSMs in
--                  the cloud.      
--
-- Notes:
--    
------------------------------------------------------------------------------- 
PROCEDURE createSubscriber( gsm_name IN varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     removeSubscriber
--
-- Description:
--     Remove an AQ subscriber to the change log queue.        
--
-- Parameters:
--     gsm_name:    The name used originally to subscribe to the queue.
--                  The name should have been a name of one of the GSMs in
--                  the cloud.      
--
-- Notes:
--    
------------------------------------------------------------------------------- 
PROCEDURE removeSubscriber( gsm_name IN varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     addRegion
--
-- Description:
--     Adds a region to the cloud.        
--
-- Parameters:
--     region_name:      The name to give to the region.
--     buddy_name:       The name of the buddy region.     
--
-- Notes:
--    
------------------------------------------------------------------------------- 
PROCEDURE addRegion( region_name IN varchar2,
                     buddy_name  IN varchar2 default NULL );


-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyRegion
--
-- Description:
--     Modifies a region.        
--
-- Parameters:
--     region_name:      The name of the region to modify.
--     buddy_name:       The name of a buddy region to assign to the region.
--                       Can be NULL.     
--
-- Notes:
--    
------------------------------------------------------------------------------- 
PROCEDURE modifyRegion( region_name     IN varchar2,
                        buddy_name      IN varchar2 default NULL,
                        region_weights  IN varchar2 default NULL);


-------------------------------------------------------------------------------
--
-- PROCEDURE     removeRegion
--
-- Description:
--     Removes a region from the cloud.       
--
-- Parameters:
--     region_name:      The name of the region.      
--
-- Notes:
--     The region should be empty of GSMs and databases.
--
--     The last region in the cloud cannot be removed.
------------------------------------------------------------------------------- 
PROCEDURE removeRegion( region_name IN varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     addDatabasePool
--
-- Description:
--     Adds a database pool to the cloud.        
--
-- Parameters:
--     database_pool_name:    The name to give to the database pool.      
--
-- Notes:
--    
------------------------------------------------------------------------------- 
PROCEDURE addDatabasePool( database_pool_name IN varchar2,
                           replication_type   IN number DEFAULT NULL,
                           pool_type          IN number DEFAULT NULL ); 

-------------------------------------------------------------------------------
--
-- PROCEDURE     modifyGDSPool
--
-- Description:
--     modifies a database pool in the cloud.        
--
-- Parameters:
--     database_pool_name:    The name to give to the database pool.  
--     state             :    New pool state    
--
-- Notes:
--    
------------------------------------------------------------------------------- 
--PROCEDURE modifyGDSPool( database_pool_name IN varchar2, 
--						 state IN number default NULL
--						 );
--
---------------------------------------------------------------------------------
--
-- PROCEDURE     addShardedPool
--
-- Description:
--     Adds a sharded pool to the cloud.        
--
-- Parameters:
--     shard_pool_name:    The name to give to the shard pool.     
--     shards:             Number of shards (for constrainted configuration)
--     chunks_in_shard:    number of chunks per shard (default 256)  
--
-- Notes:
--    
------------------------------------------------------------------------------- 
--PROCEDURE addShardedPool( shard_pool_name IN varchar2,
--						  chunks_in_shard IN number default 256);
--
---------------------------------------------------------------------------------
--
-- PROCEDURE     addShard
--
-- Description:
--     Adds a sharded the cloud.        
--
-- Parameters:
--     shard_name:    The name to give to the shard pool.  
--     shard_pool_name:    The name to give to the shard pool.     
--     chunks_in_shard:    number of chunks per shard (default 256)  
--
-- Notes:
--    
------------------------------------------------------------------------------- 
--PROCEDURE addShard      ( shard_name IN varchar2,
--						  shard_pool_name IN varchar2,
--						  chunks_in_shard IN number default NULL);                          
--						  
---------------------------------------------------------------------------------
--
-- PROCEDURE     removeDatabasePool
--
-- Description:
--     Removes a database pool from the cloud.        
--
-- Parameters:
--     database_pool_name:    The name of the database pool.            
--
-- Notes:
--     The pool should be empty, i.e. it should no longer have any
--     databases or services.
------------------------------------------------------------------------------- 
PROCEDURE removeDatabasePool( database_pool_name IN varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     removeDatabasePoolAdmin
--
-- Description:
--     Adds an administrator for a database pool.        
--
-- Parameters:
--     database_pool_name:    The name of the database pool. 
--     user_name:             The name of user to become administrator for the
--                            pool.
--
-- Notes:
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
--
--     The user is revoked VPD access to the cloud information about the
--     database pool.
--
--     
-------------------------------------------------------------------------------       
PROCEDURE removeDatabasePoolAdmin( database_pool_name IN varchar2 default NULL, 
                                user_name          IN varchar2 );

-------------------------------------------------------------------------------
--
-- PROCEDURE     addDatabasePoolAdmin
--
-- Description:
--     Adds an administrator for a database pool.        
--
-- Parameters:
--     database_pool_name:    The name of the database pool. 
--     user_name:             The name of user to become administrator for the
--                            pool.
--
-- Notes:
--     database_pool_name can be NULL if there is only one database pool
--     in the cloud.  In which case the command will default to that pool.
--
--     The user is granted VPD access to the cloud information about the
--     database pool.
--
--     TODO: the user is also given "gsm_pooladmin_role".
-------------------------------------------------------------------------------       
PROCEDURE addDatabasePoolAdmin( database_pool_name IN varchar2 default NULL, 
                                user_name          IN varchar2 );


-------------------------------------------------------------------------------
--
-- PROCEDURE     poolVpdPredicate
--
-- Description:
--     Enforces VPD read security for database pool tables.      
--
-- Parameters:
--     Standard VPD function parameters.      
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION  poolVpdPredicate( obj_schema varchar2,
                            obj_name   varchar2 ) RETURN varchar2;

-------------------------------------------------------------------------------
--
-- PROCEDURE     MaskPolicy
--
-- Description:
--     Enforces VPD masking for select on database table    
--
-- Parameters:
--     Standard VPD function parameters.      
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION MaskPolicy ( obj_schema varchar2, 
                      obj_name   varchar2)  RETURN varchar2;
-------------------------------------------------------------------------------
--
-- PROCEDURE     isSysUpdate
--
-- Description:
--     Enforces VPD update restrictions for ddl_requests 
--
-- Parameters:
--     Standard VPD function parameters.      
--
-- Notes:
--    
-------------------------------------------------------------------------------                      
FUNCTION isSysUpdate ( obj_schema varchar2, 
                       obj_name   varchar2) 
   RETURN varchar2;
-------------------------------------------------------------------------------
--
-- FUNCTION     VerifyCatalog
--
-- Description:
--     Perform various cross-check verifications on the catalog data      
--
-- Parameters:
--     NONE    
--
-- Notes:
--    
------------------------------------------------------------------------------- 
FUNCTION VerifyCatalog
RETURN NUMBER;

-------------------------------------------------------------------------------
--
-- PROCEDURE     cancelAllChanges
--
-- Description:
--       Cancel (and rollback) all outstanding catalog changes
--
-- Parameters:
--       NONE
--
-- Notes:
--       This procedure requires that there are no GSM servers running, and it
--       will get the "master lock" to prevent any from becoming master while
--       it is running
--
--       This is an "escape hatch" to be used only under customer support
--       supervision. Usually the GSM will perform the right cleanup
--       automatically while it is running or as soon as it re-starts
--       after shutdown or crash.
-------------------------------------------------------------------------------
PROCEDURE cancelAllChanges;


-------------------------------------------------------------------------------
--
-- FUNCTION     importBegin
--
-- Description:
--     Clear tables and other possibly important stuff
--
-- Parameters:
--     NONE
--
-------------------------------------------------------------------------------

PROCEDURE importBegin;


-------------------------------------------------------------------------------
--
-- FUNCTION     importEnd
--
-- Description:
--     Update sequences, and other possible stuff after successful import
--
-- Parameters:
--     NONE
--
-------------------------------------------------------------------------------

PROCEDURE importEnd;

-------------------------------------------------------------------------------
--
-- PROCEDURE    checkGSMDown 
--
-- Description:
--       Checks whether a GSM is disconnecting from the catalog database.
--       If it is a GSM then post the alert GSM down.
--
-- Parameters:
--       None.
--
-------------------------------------------------------------------------------
PROCEDURE checkGSMDown;
-------------------------------------------------------------------------------
--
-- PROCEDURE     doEncryptGSMPwd
--
-- Description:
--  Encrypt database.GSM_PASSWORD and store in database.ENCRYPTED_GSM_PASSWORD        
--
-- Parameters:
--      NULL
--
------------------------------------------------------------------------------- 
PROCEDURE doEncryptGSMPwd;
-------------------------------------------------------------------------------
--
-- PROCEDURE     setEncryptedGSMPwd
--
-- Description:
--     Sets value for gsmadmin_internal.database.ENCRYPTED_GSM_PASSWORD        
--
-- Parameters:
--     dbname:        The name of the database. 
--     encpwd:        content of encrypted password
--     
------------------------------------------------------------------------------- 
PROCEDURE setEncryptedGSMPwd( dbname varchar2,
                              encpwd   RAW);
-------------------------------------------------------------------------------
--
-- PROCEDURE     setEncryptedDDL
--
-- Description:
--     Sets value for gsmadmin_internal.ddl_requests.DDL_TEXT        
--
-- Parameters:
--     ddl_id:        DDL request id 
--     enctxt:        content of encrypted DDL request
--     
------------------------------------------------------------------------------- 
PROCEDURE setEncryptedDDL( ddl_id number,
                           enctxt   RAW);
------------------------------------------------------------------------------- 
-- PROCEDURE     genDataObjNumber
--
-- Description:
--     generates ranges of data object numbers       
--
-- Parameters:
--     db_id    IN NUMBER - database identifier,
--     curr_max IN NUMBER - current maximum,
--     min_num IN NUMBER  - returnd min number,
--     max_num IN NUMBER -returned max number
--     
-------------------------------------------------------------------------------
PROCEDURE genDataObjNumber( db_id    IN NUMBER,
                            curr_max IN NUMBER );                                 
PROCEDURE genDataObjNumber( db_id    IN NUMBER,
                            curr_max IN NUMBER,
                            min_num OUT NUMBER,
                            max_num OUT NUMBER,
                            no_commit IN NUMBER default
                                         dbms_gsm_common.isFalse );                              

--*****************************************************************************
-- End of Package Public Procedures
--*****************************************************************************


END dbms_gsm_cloudadmin;

/

show errors



CREATE OR REPLACE PACKAGE dbms_gsm_xdb AUTHID CURRENT_USER AS

--*****************************************************************************
-- NOTE: This package is executable by GSM admins in order for GDSCTL
--       to set the XDB port during 'create shardcatalog'.  It runs as
--       an invoker's rights package.
--*****************************************************************************

--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE     setXDBPort
--
-- Description:
--       Set the XDB port for the Scheduler Agent using
--       DBMS_XDB_CONFIG.SETHTTPPORT()      
--
-- Parameters:
--       agent_port            Port number for XDB to use.  If NULL and
--                             not current value is set, then will
--                             default to 8080.
--    
------------------------------------------------------------------------------- 

PROCEDURE setXDBPort(agent_port IN number default NULL);

END dbms_gsm_xdb;

/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
