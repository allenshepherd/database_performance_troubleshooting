Rem
Rem $Header: rdbms/admin/dbmsamgt.sql /main/23 2017/06/15 05:13:43 amunnoli Exp $
Rem
Rem dbmsamgt.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsamgt.sql - DBMS_AUDIT_MGMT package
Rem
Rem    DESCRIPTION
Rem      This will install the interfaces for DBMS_AUDIT_MGMT package
Rem      and the tables required by the package.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsamgt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsamgt.sql
Rem SQL_PHASE: DBMSAMGT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    01/30/17 - Bug 25245797: Recreate DBMS_AUDIT_MGMT package
Rem                           under AUDSYS schema
Rem    amunnoli    04/02/16 - Bug 23038047:pass container_guid to transfer proc
Rem    amunnoli    07/17/15 - Bug 21369600:API to alter the AUDSYS.AUD$UNIFIED
Rem                           table partition interval
Rem    amunnoli    03/25/15 - Proj 46892: Improve read performance of UAT
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    nkgopal     08/01/13 - ER 16863206,15868492: Add
Rem                           GET_LAST_ARCHIVE_TIMESTAMP
Rem    nkgopal     07/16/13 - Bug 14168362: Support dbid/guid based cleanup,
Rem                           add drop_old_unified_audit_tables
Rem    nkgopal     03/27/13 - Bug 16518691: Add is_cleanup_initialized2
Rem    vpriyans    08/20/12 - Bug 14404098: Defined Constants
Rem                           flush_current_instance and flush_all_instances
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    vpriyans    10/10/11 - to create a public synonym for dbms_audit_mgmt
Rem                           package
Rem    nkgopal     08/19/11 - Bug 12794380: Next Generation to Unified
Rem    nkgopal     08/18/11 - Proj 32480: Support CONTAINER argument for Global
Rem                           operations
Rem    nkgopal     06/16/11 - Proj 16526: Add load_next_gen_audit_files
Rem    nkgopal     06/08/11 - Bug 10406931: Add amgt$datapump
Rem    nkgopal     04/12/11 - Proj 16526: Add AUDIT_TRAIL_NEXT_GENERATION
Rem    amunnoli    02/24/11 - Proj 26873:Grant execute on dbms_audit_mgmt to
Rem                           AUDIT_ADMIN role
Rem    nkgopal     03/31/09 - Bug 8392745: Add FILE_DELETE_BATCH_SIZE
Rem    nkgopal     02/24/09 - Bug 8272269: Add AUD_TAB_MOVEMENT_FLAG
Rem    nkgopal     12/03/08 - Bug 7576198: Default value for
Rem                           RAC_INSTANCE_NUMBER will be null
Rem    ssonawan    03/28/08 - Bug 6887943: add move_dbaudit_tables() 
Rem    nkgopal     03/13/08 - Bug 6810355: Add DB_DELETE_BATCH_SZ
Rem    rahanum     11/02/07 - Merge dbms_audit_mgmt
Rem    nkgopal     05/22/07 - DBMS_AUDIT_MGMT package
Rem    nkgopal     05/22/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create a TYPE to hold the list of PDB names for audit SQL Propagation
create or replace TYPE aud_pdb_list IS VARRAY(4098) OF VARCHAR2(128);
/
create or replace public synonym aud_pdb_list for sys.aud_pdb_list;
grant execute on aud_pdb_list to audsys;

-- SYS owned function to return the list of PDB names
create or replace function get_aud_pdb_list return aud_pdb_list
is
  m_pdb_list aud_pdb_list;
BEGIN

  BEGIN
  -- Lrg 19715106: Avoid replaying the AUDIT APIs in Application ROOT CLONE 
  -- container. Connection to Application ROOT CLONE
  -- container is not allowed and it raises ORA-65252. PDB$SEED is expected 
  -- to be in READ-ONLY mode.
  SELECT *
   BULK COLLECT INTO m_pdb_list
   FROM (select NAME FROM V$CONTAINERS WHERE NAME <> 'PDB$SEED'
         AND APPLICATION_ROOT_CLONE <> 'YES'
         order by con_id desc);

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END;

  RETURN m_pdb_list;
END;
/

create or replace public synonym get_aud_pdb_list for sys.get_aud_pdb_list;
grant execute on get_aud_pdb_list to audsys;

------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE audsys.dbms_audit_mgmt AS

  -- Constants

  -- Audit Trail types
  -- 
  AUDIT_TRAIL_AUD_STD           CONSTANT NUMBER := 1;
  AUDIT_TRAIL_FGA_STD           CONSTANT NUMBER := 2;
  --
  -- Both AUDIT_TRAIL_AUD_STD and AUDIT_TRAIL_FGA_STD
  AUDIT_TRAIL_DB_STD            CONSTANT NUMBER := 3;
  --
  AUDIT_TRAIL_OS                CONSTANT NUMBER := 4;
  AUDIT_TRAIL_XML               CONSTANT NUMBER := 8;
  --
  -- Both AUDIT_TRAIL_OS and AUDIT_TRAIL_XML
  AUDIT_TRAIL_FILES             CONSTANT NUMBER := 12;
  --
  -- All above audit trail types
  AUDIT_TRAIL_ALL               CONSTANT NUMBER := 15;

  --
  -- OS Audit File Configuration parameters
  OS_FILE_MAX_SIZE              CONSTANT NUMBER := 16;
  OS_FILE_MAX_AGE               CONSTANT NUMBER := 17;

  -- 
  -- 
  CLEAN_UP_INTERVAL             CONSTANT NUMBER := 21;
  DB_AUDIT_TABLEPSACE           CONSTANT NUMBER := 22;
  DB_DELETE_BATCH_SIZE          CONSTANT NUMBER := 23;
  TRACE_LEVEL                   CONSTANT NUMBER := 24;
  -- AUD_TAB_MOVEMENT_FLAG(23) will not be entered in DAM_CONFIG_PARAM$
  AUD_TAB_MOVEMENT_FLAG         CONSTANT NUMBER := 25;
  FILE_DELETE_BATCH_SIZE        CONSTANT NUMBER := 26;

  --
  -- Values for PURGE_JOB_STATUS
  PURGE_JOB_ENABLE              CONSTANT NUMBER := 31;
  PURGE_JOB_DISABLE             CONSTANT NUMBER := 32;

  --
  -- NG Audit Trail write mode configuration
  AUDIT_TRAIL_WRITE_MODE        CONSTANT NUMBER := 33;
  -- Values for Write mode 
  AUDIT_TRAIL_QUEUED_WRITE      CONSTANT NUMBER := 1;
  AUDIT_TRAIL_IMMEDIATE_WRITE   CONSTANT NUMBER := 2;
  --AUDIT_TRAIL_COMMIT_WRITE      CONSTANT NUMBER := 3;

  --
  -- Values for TRACE_LEVEL
  TRACE_LEVEL_DEBUG             CONSTANT PLS_INTEGER := 1;
  TRACE_LEVEL_ERROR             CONSTANT PLS_INTEGER := 2;

  -- UNIFIED Audit Trail
  AUDIT_TRAIL_UNIFIED           CONSTANT NUMBER := 51;

  -- 
  -- Values for CONTAINER
  CONTAINER_CURRENT             CONSTANT PLS_INTEGER := 1;
  CONTAINER_ALL                 CONSTANT PLS_INTEGER := 2;

  -- Values for FLUSH_TYPE
  FLUSH_CURRENT_INSTANCE        CONSTANT PLS_INTEGER := 1;
  FLUSH_ALL_INSTANCES           CONSTANT PLS_INTEGER := 2;

  -- Values for AUDSYS.AUD$UNIFIED table's Partition Interval
  DEFAULT_INTERVAL_NUMBER       CONSTANT PLS_INTEGER := 1;
  DEFAULT_INTERVAL_FREQUENCY    CONSTANT VARCHAR2(5) := 'MONTH';

  ----------------------------------------------------------------------------
  /*

  NOTE: The package can be split into two packages - one intended for use by
  AV collectors and the one by Audit Admin.

  The first 3 procedures will be mainly used by the Collectors and the rest
  must be executed by Audit Admins.

  Alternately, wrapper packages can be written to achieve this Seperation of
  Duty.

  */

  /* APIS REQUIRED BY COLLECTORS */
  ----------------------------------------------------------------------------

  -- set_last_archive_timestamp - Sets timestamp when last audit records 
  --                              were archived
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the last audit 
  --                                record timestamp is being set
  --   last_archive_time          - Timestamp when last audit record was 
  --                                archived
  --   rac_instance_number        - RAC instance number to which this applies
  --                                def. value = null(applies to no RAC node)
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT
  --   database_id                - Database ID (DBID) of the audit records
  --                                to cleanup. Default: NULL
  --   container_guid             - Container GUID of the audit records
  --                                to cleanup. Default: NULL
  
  PROCEDURE set_last_archive_timestamp
            (audit_trail_type           IN PLS_INTEGER,
             last_archive_time          IN TIMESTAMP,
             rac_instance_number        IN PLS_INTEGER := null,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT,
             database_id                IN NUMBER := null,
             container_guid             IN VARCHAR2 := null
            );
  
  ----------------------------------------------------------------------------

  -- clear_last_archive_timestamp - Deletes the timestamp set by 
  --                                set_last_archive_timestamp
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the last audit 
  --                                record timestamp was set
  --   rac_instance_number        - RAC instance number to which this applies
  --                                def. value = null(applies to no RAC node)
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT
  --   database_id                - Database ID (DBID) of the audit records
  --                                to cleanup. Default: NULL
  --   container_guid             - Container GUID of the audit records
  --                                to cleanup. Default: NULL
  
  PROCEDURE clear_last_archive_timestamp
            (audit_trail_type           IN PLS_INTEGER,
             rac_instance_number        IN PLS_INTEGER := null,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT,
             database_id                IN NUMBER := null,
             container_guid             IN VARCHAR2 := null
            );

  ----------------------------------------------------------------------------

  -- get_last_archive_timestamp - Retrieves the timestamp set by 
  --                              set_last_archive_timestamp for the current 
  --                              instance
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the last audit 
  --                                record timestamp was set
  -- RETURNS
  --   TIMESTAMP - Last Archive Timestamp in memory

  FUNCTION get_last_archive_timestamp
           (audit_trail_type           IN PLS_INTEGER)
  RETURN TIMESTAMP;

   -----------------------------------------------------------------------------

  -- get_audit_commit_delay - GETs the audit commit delay set in the db.
  --
  -- INPUT PARAMETERS
  --   None
  -- RETURNS
  --   PLS_INTEGER - AUD_AUDIT_COMMIT_DELAY
  -- 

  FUNCTION get_audit_commit_delay RETURN PLS_INTEGER;

  ----------------------------------------------------------------------------

  -- get_audit_trail_property_value - Retrieves the value of the property set 
  --                                  by set_audit_trail_property
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the property was set 
  --   audit_trail_property       - Property for which the value is to be
  --                                fetched
  -- RETURNS
  --   NUMBER - Value of the audit trail property in memory

  FUNCTION get_audit_trail_property_value
           (audit_trail_type           IN PLS_INTEGER,
            audit_trail_property       IN PLS_INTEGER)
  RETURN NUMBER;

  ----------------------------------------------------------------------------
 
  -- is_cleanup_initialized - Checks if Audit Cleanup is initialized for the 
  --                          audit trail type
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail to check initialization for.
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  -- RETURNS
  --   TRUE  - If audit trail is initialized for clean up.
  --   FALSE - otherwise.
  -- 

  FUNCTION is_cleanup_initialized
           (audit_trail_type           IN PLS_INTEGER,
            container                  IN PLS_INTEGER := CONTAINER_CURRENT)
  RETURN BOOLEAN;

  -- is_cleanup_initialized2 - Checks if Audit Cleanup is initialized for the 
  --                           audit trail type and returns VARCHAR2 type
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail to check initialization for.
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  -- RETURNS
  --   'TRUE'  - If audit trail is initialized for clean up.
  --   'FALSE' - otherwise.
  -- 

  FUNCTION is_cleanup_initialized2
           (audit_trail_type           IN     PLS_INTEGER,
            container                  IN     PLS_INTEGER := CONTAINER_CURRENT)
  RETURN VARCHAR2;

  -- is_cleanup_initialized - Checks if Audit Cleanup is initialized for the 
  --                          audit trail type (CDB version)
  --                          This function returns all PDB names that are not
  --                          initialized for cleanup
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail to check initialization for.
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  -- OUTPUT PARAMETERS
  --   uninitialized_pdb          - Array of uninitialized PDB names
  -- RETURNS
  --   TRUE  - If audit trail is initialized for clean up.
  --   FALSE - otherwise.
  -- 
  FUNCTION is_cleanup_initialized
           (audit_trail_type           IN     PLS_INTEGER,
            container                  IN     PLS_INTEGER := CONTAINER_CURRENT,
            uninitialized_pdbs         IN OUT DBMS_SQL.VARCHAR2S)
  RETURN BOOLEAN;

  -- get_cli_part_oranum - GETs the ORACLE NUMBER corresponding to the 
  --                       HIGH_VALUE of CLI Partition.
  --
  -- INPUT PARAMETERS
  -- partname - CLI Partition Name  
  -- RETURNS
  --   NUMBER - Oracle Number
  --
  -- NOTES
  --   HIGH_VALUE of the partition is stored in LONG type columns inside
  --   dba_tab_partitions. We this function to convert it to NUMBER. 


  FUNCTION get_cli_part_oranum
           (partname IN VARCHAR2)
  RETURN NUMBER;

  -- is_droppable_partition - IS aud$unified table PARTITION DROPPABLE? 
  --                   
  --
  -- INPUT PARAMETERS
  -- partname - aud$unified table's Partition Name
  -- lat      - Last Archive Timestamp mentioned during cleanup
  -- RETURNS
  --   NUMBER
  --     1 - if partition is droppable
  --     0 - otherwise
  -- 

  FUNCTION is_droppable_partition
           (partname in varchar2, lat in timestamp)
  RETURN NUMBER;

  -- get_part_highval_as_char - GETs the aud$unified table PARTition 
  --                            HIGH_VALUE AS varCHAR2.
  --
  -- INPUT PARAMETERS
  -- partname - aud$unified table's Partition Name  
  -- RETURNS
  --   VARCHAR2
  --
  -- NOTES
  --   HIGH_VALUE of the partition is stored in LONG type columns inside
  --   dba_tab_partitions. We need this function to convert it to VARCHAR2. 
  -- 

  FUNCTION get_part_highval_as_char
           (partname in varchar2)
  RETURN VARCHAR2;
 
  ----------------------------------------------------------------------------

  /* APIS NEED TO BE RUN BY AUDIT ADMINS */
  ----------------------------------------------------------------------------

  -- init_cleanup  - Initialize DBMS_AUDIT_MGMT
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which set-up must done.
  --   default_cleanup_interval   - Default interval at which clean up is
  --                                invoked.    
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT

  PROCEDURE init_cleanup
            (audit_trail_type           IN PLS_INTEGER,
             default_cleanup_interval   IN PLS_INTEGER,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT
            );

  ----------------------------------------------------------------------------

  -- set_audit_trail_location - Set destination for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which the location 
  --                                is being set
  --   audit_trail_location_value - Value of the location

  PROCEDURE set_audit_trail_location
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_location_value IN VARCHAR2
            );

  ----------------------------------------------------------------------------

  -- deinit_cleanup  - De-Initialize DBMS_AUDIT_MGMT
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which set-up must done.
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT

  PROCEDURE deinit_cleanup
            (audit_trail_type           IN PLS_INTEGER,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT);
  
  ----------------------------------------------------------------------------

  -- set_audit_trail_property - Set a property of an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail whose parameter must be set
  --   audit_trail_property       - Property that must be set
  --   audit_trail_property_value - Value to which the property must set

  PROCEDURE set_audit_trail_property
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_property       IN PLS_INTEGER,
             audit_trail_property_value IN PLS_INTEGER
            );

  ----------------------------------------------------------------------------

  -- clear_audit_trail_property - Clears a property of an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail whose parameter must be set
  --   audit_trail_property       - Property that must be cleared
  --   use_default_values         - Use default values after clearing the 
  --                                property, default value is FALSE.

  PROCEDURE clear_audit_trail_property
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_property       IN PLS_INTEGER,
             use_default_values         IN BOOLEAN := FALSE
            );

 ----------------------------------------------------------------------------
  
  -- clean_audit_trail - Deletes entries in audit trail according to the
  --                     timestamp set in set_last_archive_timestamp
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail which should be cleared
  --   use_last_arch_timestamp    - Use Last Archive Timestamp set.
  --                                default value = TRUE.
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT
  --   database_id                - Database ID (DBID) of the audit records
  --                                to cleanup. Default: NULL
  --   container_guid             - Container GUID of the audit records
  --                                to cleanup. Default: NULL

  PROCEDURE clean_audit_trail
            (audit_trail_type           IN PLS_INTEGER,
             use_last_arch_timestamp    IN BOOLEAN := TRUE,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT,
             database_id                IN NUMBER := null,
             container_guid             IN VARCHAR2 := null
            );
  
  ----------------------------------------------------------------------------

  -- create_purge_job - Creates a purge job for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_type           - Audit trail for which this job is created
  --   audit_trail_purge_interval - Interval to determine frequency of 
  --                                purge operation
  --   audit_trail_interval_unit  - Unit of measurement for 
  --                                audit_trail_purge_interval
  --   audit_trail_purge_name     - Name to identify this job
  --   use_last_arch_timestamp    - Use Last Archive Timestamp set.
  --                                default value = TRUE.
  --   container                  - Job to manage Current or All PDBs -
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT
  
  PROCEDURE create_purge_job
            (audit_trail_type           IN PLS_INTEGER,
             audit_trail_purge_interval IN PLS_INTEGER,
             audit_trail_purge_name     IN VARCHAR2,
             use_last_arch_timestamp    IN BOOLEAN := TRUE,
             container                  IN PLS_INTEGER := CONTAINER_CURRENT
            );
  
  ----------------------------------------------------------------------------
  
  -- set_purge_job_status - Set the status of the purge job
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name of the purge job created
  --   audit_trail_status_value   - Value to which the status must set
  
  PROCEDURE set_purge_job_status
            (audit_trail_purge_name     IN VARCHAR2,
             audit_trail_status_value   IN PLS_INTEGER
            );
  
  ----------------------------------------------------------------------------

  -- set_purge_job_interval - Set the interval of the purge job
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name of the purge job created
  --   audit_trail_interval_type  - Type of interval that must be set
  --   audit_trail_interval_value - Value to which the interval must set

  PROCEDURE set_purge_job_interval
            (audit_trail_purge_name     IN VARCHAR2,
             audit_trail_interval_value IN PLS_INTEGER
            );
  
  ----------------------------------------------------------------------------
  
  -- drop_purge_job - Drops the purge job for an audit trail
  --
  -- INPUT PARAMETERS
  --   audit_trail_purge_name     - Name to identify this job
  
  PROCEDURE drop_purge_job
            (audit_trail_purge_name     IN VARCHAR2
            );
 
  ----------------------------------------------------------------------------

  -- move_dbaudit_tables - Moves DB audit tables to specified tablespace 
  --
  -- INPUT PARAMETERS
  --   audit_trail_tbs - The table space to which to move the DB audit tables.
  --                     The default value is the SYSAUX tablespace.      
  
  PROCEDURE move_dbaudit_tables
            (audit_trail_tbs     IN VARCHAR2  DEFAULT 'SYSAUX'
            );
 
  ----------------------------------------------------------------------------

  -- set_debug_level - Sets the debug level for tracing
  --
  -- INPUT PARAMETERS
  --   debug_level - Number to identify the trace level

  PROCEDURE set_debug_level(debug_level IN PLS_INTEGER := TRACE_LEVEL_ERROR);
 
  ----------------------------------------------------------------------------

  -- flush_unified_audit_trail - Flushes all the in-memory queues
  --
  -- INPUT PARAMETERS
  --   flush_type     - Flush Local RAC node or all RAC nodes
  --                    The default value is FLUSH_CURRENT_INSTANCE
  --   container      - PDB Container to execute in 
  --                    CONTAINER_CURRENT or CONTAINER_ALL
  --                    Default : CONTAINER_CURRENT
  --
  
  PROCEDURE flush_unified_audit_trail
            (flush_type        IN PLS_INTEGER := FLUSH_CURRENT_INSTANCE,
             container         IN PLS_INTEGER := CONTAINER_CURRENT);
  pragma deprecate(flush_unified_audit_trail, 
               'DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL is deprecated!');

  ----------------------------------------------------------------------------

  -- load_unified_audit_files - Loads all spillover audit files to tables
  --
  --   container                  - PDB Container to execute in 
  --                                CONTAINER_CURRENT or CONTAINER_ALL
  --                                Default : CONTAINER_CURRENT
  --

  PROCEDURE load_unified_audit_files
            (container         IN PLS_INTEGER := CONTAINER_CURRENT);

  ----------------------------------------------------------------------------

  --  transfer_unified_audit_records - Procedure to transfer Unified Audit 
  --  records from CLI persistent storage to a relational table, 
  --  AUDSYS.AUD$UNIFIED
  --  Bug 23038047: This now takes CONTAINER_GUID as an argument to deal with
  --  multiple CLI_SWP$ tables associated with different GUID.
  --  When this procedure is called without mentioning the value for GUID,
  -- we will internally pick up the container's current GUID.

  PROCEDURE transfer_unified_audit_records
            (container_guid  IN VARCHAR2 := null);

  ----------------------------------------------------------------------------

  -- drop_old_unified_audit_tables - Drops the given Old Unified Audit 
  --                                 (CLI based) tables
  --
  --   container_guid             - Container GUID of the Unified Audit
  --                                table
  --

  PROCEDURE drop_old_unified_audit_tables
            (container_guid    IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- alter_partition_interval - Alters the interval of partitioned table 
  --                            AUDSYS.AUD$UNIFIED
  --
  --   interval_number        - Number indicating the partition interval
  --   interval_frequency     - Frequency of the partition interval
  --                            (YEAR, MONTH, DAY, HOUR, MINUTE, SECOND)    
  --

  PROCEDURE alter_partition_interval
            (interval_number       IN PLS_INTEGER := DEFAULT_INTERVAL_NUMBER,
             interval_frequency    IN VARCHAR2 := DEFAULT_INTERVAL_FREQUENCY);

END;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_audit_mgmt FOR audsys.dbms_audit_mgmt
/
CREATE OR REPLACE SYNONYM sys.dbms_audit_mgmt FOR audsys.dbms_audit_mgmt
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON audsys.dbms_audit_mgmt TO execute_catalog_role
/
GRANT EXECUTE ON audsys.dbms_audit_mgmt TO AUDIT_ADMIN
/


-- Internal Datapump support package
create or replace package amgt$datapump
as
  procedure instance_callout_imp(
                      obj_name         in      varchar2,
                      obj_schema       in      varchar2,
                      obj_type         in      number,
                      prepost          in      pls_integer,
                      action           out     varchar2,
                      alt_name         out     varchar2
                      );
end;
/

GRANT EXECUTE ON sys.amgt$datapump TO execute_catalog_role
/

@?/rdbms/admin/sqlsessend.sql
