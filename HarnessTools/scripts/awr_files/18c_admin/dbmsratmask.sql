Rem
Rem $Header: rdbms/admin/dbmsratmask.sql /main/4 2017/04/17 21:33:15 pradeshm Exp $
Rem
Rem dbmsratmask.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsratmask.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsratmask.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsratmask.sql
Rem SQL_PHASE: DBMSRATMASK
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pradeshm    02/17/17 - Fix bug#25410917 : IR wrapper for dbms_rat_mask
Rem                           package
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    shjoshi     04/07/12 - bug13936064: Add remove_spa_peeked_binds
Rem    shjoshi     06/01/11 - Rename awr_purge to awr_purge_binds
Rem    sburanaw    12/09/10 - add awr_purge
Rem    sburanaw    11/21/10 - add script_id to dbr functions
Rem    shjoshi     11/09/10 - Add get_rat_version
Rem    shjoshi     10/31/10 - Add function-to-step mapping
Rem    shjoshi     07/27/10 - Add initialize_masking
Rem    shjoshi     07/27/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                   DBMS_RAT_MASK FUNCTION DESCRIPTION                      --
-------------------------------------------------------------------------------
---------------------
--  Main functions
---------------------
--   initialize_masking:       initialize a rat masking run
--   get_rat_version:          get version of kernel code of RAT masking
--   spa_extract_data:         identify and extract sensitive binds in STS
--   dbr_extract_data:         identify and extract sensitive binds in WCR
--   dbr_mask_data:            identify and replace sensitive binds in WCR
--   spa_mask_data:            identify and replace sensitive binds in STS
--   awr_purge_binds:          purge binds from AWR
--   cleanup_masking:          cleanup data related to specified masking script


-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                    dbms_rat_mask package declaration                      --
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_rat_mask AUTHID CURRENT_USER AS 

  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  --                    procedure / function declarations                    --
  -----------------------------------------------------------------------------

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                      -----------------------------                      --
  --                        MAIN PROCEDURES/FUNCTIONS                        --
  --                      -----------------------------                      --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  ----------------------------- initialize_masking ---------------------------
  -- NAME: 
  --     initialize_masking - Initialize rat Masking run
  --
  -- DESCRIPTION
  --     This procedure parses the masking definition xml to extract values
  --     of masking parameters. It also inserts those values in the catalog
  --     tables of RAT masking.
  --
  -- PARAMETERS:
  --     user_name         (IN) - user executing the masking script
  --     package_name      (IN) - name of masking package
  --     mask_definition   (IN) - xml of masking definition
  --     control_xml       (IN) - control xml from masking definition
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE initialize_masking(
    user_name          IN VARCHAR2, 
    package_name       IN VARCHAR2,
    mask_definition    IN XMLTYPE,
    control_xml        IN XMLTYPE DEFAULT NULL);


  ------------------------------- get_rat_version ----------------------------
  -- NAME: 
  --     get_rat_version - Return the version number of RAT masking
  --
  -- DESCRIPTION
  --     This function returns the version number of RAT masking. It is used
  --     in the main data masking script to figure which version of rat 
  --     masking it is being used with.
  --
  -- PARAMETERS:
  --     NONE
  --
  -- RETURNS:
  --     version as a number
  --
  -----------------------------------------------------------------------------
  FUNCTION get_rat_version RETURN NUMBER;

  ------------------------------ spa_extract_data -----------------------------
  -- NAME: 
  --     spa_extract_data - SPA Extract Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the extract phase of rat 
  --     masking for SQL tuning sets. It makes a call out to the kernel 
  --     function which iterates over each stmt in each STS in the db and 
  --     extracts all sensitive bind values. 
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE spa_extract_data(script_id  IN NUMBER);

  ------------------------------ dbr_extract_data -----------------------------
  -- NAME: 
  --     dbr_extract_data - DB Replay Extract Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the extract phase of rat 
  --     masking for capture files. It makes a call out to the kernel 
  --     function which iterates over each stmt in each capture file and 
  --     extracts all sensitive bind values. 
  --
  -- PARAMETERS:
  --     capture_directory (IN) - directory having capture files to be masked
  --     script_id         (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE dbr_extract_data(
    capture_directory   IN VARCHAR2,
    script_id           IN NUMBER);

  ------------------------------ spa_mask_data --------------------------------
  -- NAME: 
  --     spa_mask_data - SPA Mask Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the mask phase of rat 
  --     masking for SQL tuning sets. It makes a call out to the kernel 
  --     function which iterates over each stmt in each STS in the db and 
  --     replaces the values of all sensitive binds with masked values.
  --     It also removes peeked binds present in the other_xml column of
  --     the plan lines table.
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE spa_mask_data(script_id  IN NUMBER);

  ------------------------------ dbr_mask_data --------------------------------
  -- NAME: 
  --     dbr_mask_data - DB Replay Mask Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the mask phase of rat 
  --     masking for capture files. It makes a call out to the kernel 
  --     function which iterates over each stmt in each cap file and 
  --     replaces the values of all sensitive binds with masked values.
  --     It also removes binds in AWR.
  --
  -- PARAMETERS:
  --     capture_directory   (IN) - capture directory
  --     script_id           (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE dbr_mask_data(
    capture_directory   IN VARCHAR2,
    script_id           IN NUMBER);


  ------------------------------ awr_purge_binds ------------------------------
  -- NAME: 
  --     awr_purge_binds - AWR Purge Binds
  --
  -- DESCRIPTION
  --     This procedure runs an update stmt to delete peeked binds from the 
  --     other_xml of the AWR plans table.
  --
  -- PARAMETERS:
  --     NONE
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE awr_purge_binds;


  --------------------------- remove_spa_peeked_binds -------------------------
  -- NAME: 
  --     remove_spa_peeked_binds - Remove SPA Peeked Binds
  --
  -- DESCRIPTION
  --     This procedure removes peeked binds from the advisor plans table.
  --
  -- PARAMETERS:
  --     task_id         (IN) - SPA task id
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE remove_spa_peeked_binds(task_id IN NUMBER);


  ----------------------------- cleanup_masking -------------------------------
  -- NAME: 
  --     cleanup_masking - Cleanup Masking run
  --
  -- DESCRIPTION
  --     This procedure removes data from all catalog tables related to the
  --     given script id. 
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE cleanup_masking(script_id IN NUMBER);

END dbms_rat_mask;
/
show errors;

------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
create or replace public synonym dbms_rat_mask for dbms_rat_mask
/

------------------------------------------------------------------------------
--            Granting the execution privilege to the dba role              --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_rat_mask TO dba
/

------------------------------------------------------------------------------
--                      DR internal package for masking 
--       All procedures are same as what defined in dbms_rat_mask. There is 
--       one to one procedure mapping between package dbms_rat_mask and
--       dbms_rat_mask_internal. This package is created under sys and 
--       execution on package is not granted to users.
--       All procedures are prefixed with i_ meaning internal.
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_rat_mask_internal ACCESSIBLE BY 
                                                        (SYS.dbms_rat_mask) AS 

  ----------------------------- i_initialize_masking -------------------------
  -- NAME: 
  --     i_initialize_masking - Initialize rat Masking run
  --
  -- DESCRIPTION
  --     This procedure parses the masking definition xml to extract values
  --     of masking parameters. It also inserts those values in the catalog
  --     tables of RAT masking.
  --
  -- PARAMETERS:
  --     user_name         (IN) - user executing the masking script
  --     package_name      (IN) - name of masking package
  --     mask_definition   (IN) - xml of masking definition
  --     control_xml       (IN) - control xml from masking definition
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE i_initialize_masking(
    user_name          IN VARCHAR2, 
    package_name       IN VARCHAR2,
    mask_definition    IN XMLTYPE,
    control_xml        IN XMLTYPE DEFAULT NULL);


  ------------------------------- i_get_rat_version---------------------------
  -- NAME: 
  --     i_get_rat_version - Return the version number of RAT masking
  --
  -- DESCRIPTION
  --     This function returns the version number of RAT masking. It is used
  --     in the main data masking script to figure which version of rat 
  --     masking it is being used with.
  --
  -- PARAMETERS:
  --     NONE
  --
  -- RETURNS:
  --     version as a number
  --
  -----------------------------------------------------------------------------
  FUNCTION i_get_rat_version RETURN NUMBER;

  ------------------------------ i_spa_extract_data ---------------------------
  -- NAME: 
  --     i_spa_extract_data - SPA Extract Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the extract phase of rat 
  --     masking for SQL tuning sets. It makes a call out to the kernel 
  --     function which iterates over each stmt in each STS in the db and 
  --     extracts all sensitive bind values. 
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --     user_id          (IN) - id of the current user executing IR package
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_spa_extract_data(script_id  IN NUMBER, user_id IN BINARY_INTEGER);

  ------------------------------ i_dbr_extract_data ---------------------------
  -- NAME: 
  --     i_dbr_extract_data - DB Replay Extract Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the extract phase of rat 
  --     masking for capture files. It makes a call out to the kernel 
  --     function which iterates over each stmt in each capture file and 
  --     extracts all sensitive bind values. 
  --
  -- PARAMETERS:
  --     capture_directory (IN) - directory having capture files to be masked
  --     script_id         (IN) - id of masking script
  --     user_id           (IN) - id of the current user executing IR package
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_dbr_extract_data(
    capture_directory   IN VARCHAR2,
    script_id           IN NUMBER,
    user_id             IN BINARY_INTEGER);

  ------------------------------ i_spa_mask_data ------------------------------
  -- NAME: 
  --     i_spa_mask_data - SPA Mask Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the mask phase of rat 
  --     masking for SQL tuning sets. It makes a call out to the kernel 
  --     function which iterates over each stmt in each STS in the db and 
  --     replaces the values of all sensitive binds with masked values.
  --     It also removes peeked binds present in the other_xml column of
  --     the plan lines table.
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --     user_id          (IN) - id of the current user executing IR package
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_spa_mask_data(script_id  IN NUMBER, user_id IN BINARY_INTEGER);

  ------------------------------ i_dbr_mask_data ------------------------------
  -- NAME: 
  --     i_dbr_mask_data - DB Replay Mask Data
  --
  -- DESCRIPTION
  --     This procedure is the plsql interface for the mask phase of rat 
  --     masking for capture files. It makes a call out to the kernel 
  --     function which iterates over each stmt in each cap file and 
  --     replaces the values of all sensitive binds with masked values.
  --     It also removes binds in AWR.
  --
  -- PARAMETERS:
  --     capture_directory  (IN) - capture directory
  --     script_id          (IN) - id of masking script
  --     user_id            (IN) - id of the current user executing IR package
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_dbr_mask_data(
    capture_directory   IN VARCHAR2,
    script_id           IN NUMBER,
    user_id             IN BINARY_INTEGER);


  ------------------------------ i_awr_purge_binds ---------------------------
  -- NAME: 
  --     i_awr_purge_binds - AWR Purge Binds
  --
  -- DESCRIPTION
  --     This procedure runs an update stmt to delete peeked binds from the 
  --     other_xml of the AWR plans table.
  --
  -- PARAMETERS:
  --     NONE
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_awr_purge_binds;


  --------------------------- i_remove_spa_peeked_binds -----------------------
  -- NAME: 
  --     i_remove_spa_peeked_binds - Remove SPA Peeked Binds
  --
  -- DESCRIPTION
  --     This procedure removes peeked binds from the advisor plans table.
  --
  -- PARAMETERS:
  --     task_id         (IN) - SPA task id
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_remove_spa_peeked_binds(task_id IN NUMBER);


  ----------------------------- i_cleanup_masking -----------------------------
  -- NAME: 
  --     i_cleanup_masking - Cleanup Masking run
  --
  -- DESCRIPTION
  --     This procedure removes data from all catalog tables related to the
  --     given script id. 
  --
  -- PARAMETERS:
  --     script_id        (IN) - id of masking script
  --
  -- RETURNS:
  --     NONE
  --
  -----------------------------------------------------------------------------
  PROCEDURE i_cleanup_masking(script_id IN NUMBER);

END dbms_rat_mask_internal;
/
show errors;

@?/rdbms/admin/sqlsessend.sql
