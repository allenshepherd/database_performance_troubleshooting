Rem
Rem $Header: rdbms/admin/dbmssqlu.sql /main/57 2017/09/26 16:43:22 aarvanit Exp $
Rem
Rem dbmssqlu.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssqlu.sql - DBMS SQLtune Utility packages
Rem
Rem    DESCRIPTION
Rem      This file contains the specifications of two utility packages 
Rem      dbms_sqltune_util0 and dbms_sqltune_util1. Each package defines 
Rem      various utility procedures and functions used by sql tuning features 
Rem      such as sqltune through dbms_sqltune and dbms_sqltune_internal 
Rem      packages and SQLPI through prvt_sqlpi internal package. 
Rem      The implementation of both packages is located in sqltune/prvtsqlu.sql.
Rem 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmssqlu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmssqlu.sql
Rem SQL_PHASE: DBMSSQLU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aarvanit    09/15/17 - bug #20130712: add is_session_monitored in util1
Rem    msabesan    08/29/17 - bug 26712379: add function is_exadata_profile
Rem    aarvanit    08/02/17 - bug #25564281: move resolve_exec_name to util1
Rem    msabesan    08/02/17 - bug #26370201: move global variable sqlt_rmt_ctx
Rem                           to prvtsqlu.sql
Rem    msabesan    03/07/17 - bug #24521177: is_create_tuning_task replaced by
Rem                           db_link_reqd
Rem    aarvanit    01/25/17 - bug #25309132: resolve_username: remove validate
Rem                           flag, return enquoted username
Rem    aarvanit    01/09/17 - bug #25340045: check_obj_priv: add accessible by
Rem    msabesan    12/05/16 - Bug Bug 24327414: add accessible by to 
Rem                           get_seq_remote
Rem    sshastry    06/27/16 - a. Add is_imported_cdb and is_imported_pdb api's
Rem                           b. Add wrapper function 
Rem                              dbms_sqltune_util2.resolve_database_type for 
Rem                              dbms_sqltune_util1.resolve_db_type 
Rem    aarvanit    04/14/16 - bug #22271179: add PDB-level AWR snapshot support
Rem    msabesan    03/03/16 - Bug# 22135039: replace get_db_link with
Rem                           get_db_link_to_prim
Rem    aarvanit    02/03/16 - bug #22610532: add varr_to_hints_xml, 
Rem                           get_sqlset_userbinds and check_obj_priv functions
Rem    msabesan    11/30/15 - bug#22272345: add user_id to init_remote_context
Rem    aarvanit    09/22/15 - bug #20408481: add is_ras_user function
Rem    msabesan    08/22/15 - bug21763839: change value of PARAM_DBLINK_TO
Rem    msabesan    07/15/15 - bug 21119919: remove subst_qry_len
Rem    msabesan    06/23/15 - bug 21075879: add get_seq_remote
Rem    lvbcheng    02/27/15 - 20529556: parsing schema to 128
Rem    aarvanit    01/06/15 - add function to parameterize AWR_VIEW_TEXT
Rem    aarvanit    12/01/14 - add support for imported AWR in STS, tuning and 
Rem                           analysis tasks
Rem    msabesan    12/10/14 - project 47327: add remCtx_rec, 
Rem                         - init_remote_context
Rem                         - add remote query support
Rem                         - add add_subst_pattern, get_sqlset_refId_remote
Rem                         - get_subst_query
Rem    bhavenka    07/01/14 - make validate_name more generic
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    kyagoub     11/05/12 - lrgdbconqma1: add function cdbcon_id_to_dbid
Rem    shjoshi     11/02/12 - bug14568395: Add con_id to resolve_username
Rem    cgervasi    11/01/12 - add cdb_is_root, cdb_is_pdb
Rem    bhavenka    10/11/12 - add con_dbid to sql task object
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     02/27/12 - Move get_timing_info to dbms_sqltune_util2
Rem    msabesan    02/01/12 - add  funtion cdbcon_name2ids 
Rem    shjoshi     01/28/12 - Add fn is_bind_masked 
Rem    shjoshi     10/20/11 - bug12653777: Add get_dbid_from_conid
Rem    ddas        08/22/11 - SPM Evolve Advisor
Rem    shjoshi     05/25/11 - Add cdbcon_id_to_dbid
Rem    kyagoub     05/03/11 - add cdbcon_dbid_to_name callout to util0
Rem    kyagoub     04/01/11 - project-35499: add cdb container name
Rem    pbelknap    04/18/10 - add constants for sqlset2
Rem    pbelknap    12/12/09 - #8451247: callout for ksugctm()
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    hayu        03/04/09 - update task_spaobj
Rem    shjoshi     01/22/09 - Add type task_spataskobj and 
Rem                           init_task_spataskobj()
Rem    shjoshi     01/16/09 - Add OBJ_SPA_EXEC_PROP# to dbms_sqltune_util1
Rem    shjoshi     09/16/08 - Add OBJ_SPA_TASK# to dbms_sqltune_util1
Rem    shjoshi     08/20/08 - Add function resolve_exec_name
Rem    kyagoub     04/02/08 - add flags to task_sqlobj
Rem    pbelknap    05/09/08 - #5521613: add dbms_sqltune_util2.check_priv
Rem    kyagoub     12/20/07 - add convert sqlset action to spa
Rem    pbelknap    09/06/07 - report_sql_monitor_xml: disable force pq
Rem    pbelknap    06/21/07 - stats_xml to other_xml
Rem    kyagoub     05/25/07 - rename spa advisor
Rem    kyagoub     04/10/07 - add execution type ids
Rem    hosu        02/28/07 - move SMB object type id constants to 
Rem                           dbms_smb_internal
Rem    pbelknap    03/19/07 - remove get_task_names_from_ids
Rem    pbelknap    02/21/07 - add unmap for task_id, owner_id, execution_id
Rem    pbelknap    02/08/07 - add description to sqlset metadata
Rem    pbelknap    12/07/06 - remove exec_name_list, avoid INLIST injections
Rem    pbelknap    01/10/07 - add dbms_sqltune_util2
Rem    pbelknap    08/21/06 - add constant for opm types
Rem    pbelknap    08/18/06 - add get_wkldtype_name
Rem    nachen      08/01/06 - add exec_frequecy to task_sqlobj
Rem    kyagoub     07/11/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                    dbms_sqltune_util0 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util0
--
-- DESCRIPTION:
--     This package is defined to hold sqltune internal utility procedures and 
--     functions that do not access dictionary objects. Some of these utilities
--     are called as part of upgrade and downgrade scripts. 
--
-- NOTICE:
--     The functions/procedures you add to this package MUST not refer to any
--     dictionary objects, such as tables, views, etc., or any other packages
--     that are defined on such objects. 
--     When dictionary objects are altered in the upgrade/downgrade scripts,
--     the packages using them become invalid and this breaks upgrade/downgrade
--     process. So we MUST be very careful. 
--     Notice also that the functions of this package are also used by other
--     packages such as dbms_sqltune and dbms_sqltune_internal. 
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       extract_bind
--       extract_binds
--       sqltext_to_signature
--       sqltext_to_sqlid
--       validate_sqlid
--       is_bind_masked
--       get_binds_count
--       cdbcon_dbid_to_name
--       cdbcon_id_to_dbid
--       cdbcon_name2ids
--       cdb_is_root
--       cdb_is_pdb
--       add_subst_pattern
--       get_subst_query
--       set_db_link_to_prim
--       get_db_link_to_prim
--       check_obj_priv
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util0 AS

  -----------------------------------------------------------------------------
  --                 section for constants and global variables              --
  -----------------------------------------------------------------------------
  
  INVALID_SQL EXCEPTION;
  PRAGMA EXCEPTION_INIT(INVALID_SQL, -900);

  -- substitution patterns
  PAT_BEG CONSTANT VARCHAR2(11)  := '$#CDB#$MT1$';
  PAT_END CONSTANT VARCHAR2(11)  := '$#CDB#$MT2$';
  
  --  This record represents a remote context with db link to a remote db.
  --  The remote context is required when executing a remote query.
  TYPE sqltune_remote_ctx IS RECORD (
    db_link_to    VARCHAR2(4000) := NULL          -- db link to a remote db
  );
  
     
  -----------------------------------------------------------------------------
  --                    procedure/function specifications                    --
  -----------------------------------------------------------------------------


  ------------------------------ sqltext_to_signature -------------------------
  -- 
  -- NAME:  
  --     sqltext_to_signature - sql text to its signature 
  -- 
  -- DESCRIPTION: 
  --     This function returns a sql text's signature.  
  --     The signature can be used to identify sql text in dba_sql_profiles.
  --
  -- PARAMETERS:  
  --     sql_text    (IN) - (REQUIRED) sql text whose signature is required
  --     force_match (IN) - If TRUE this function returns the FORCE maching 
  --                        signature. Otherwise, it return the EXACT signature
  --
  -- RETURNS: 
  --     the signature of the specified sql text
  -----------------------------------------------------------------------------
  FUNCTION sqltext_to_signature(
    sql_text    IN CLOB, 
    force_match IN BINARY_INTEGER := 0)
  RETURN NUMBER;

  ------------------------------ sqltext_to_sqlid -----------------------------
  --
  -- NAME: 
  --     sqltext_to_signature - sql text to its signature
  --
  -- DESCRIPTION:  
  --     This function returns a sql text's id. 
  --     The signature can, for example, be used to identify sql text in 
  --     v$sqlXXX views. 
  --
  -- PARAMETERS:  
  --     sql_text    (IN) - (REQUIRED) sql text whose signature is required
  --
  -- RETURNS: 
  --     sqlid of the specified sql text
  -----------------------------------------------------------------------------
  FUNCTION sqltext_to_sqlid(sql_text IN CLOB) 
  RETURN VARCHAR2; 

  -------------------------------- validate_sqlid -----------------------------
  --
  -- NAME: 
  --     validate_sqlid - VALIDATE syntax of a SQL ID
  --
  -- DESCRIPTION:  
  --     This function checks to make sure that a sql id provided by a client
  --     is valid by converting it to a ub8 and back and checking to make sure
  --     there is no change.
  --
  -- PARAMETERS:  
  --     sql_id      (IN) - (REQUIRED) sql id to validate
  --
  -- RETURNS: 
  --     1 if valid, 0 otherwise.
  -----------------------------------------------------------------------------
  FUNCTION validate_sqlid(sql_id IN VARCHAR2)
  RETURN BINARY_INTEGER;

  --------------------------------- extract_bind ------------------------------
  -- NAME: 
  --     extract_bind 
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column captured in v$sql and a
  --     bind position, this function returns the value of the bind
  --     variable at that position in the SQL statement. Bind position
  --     start at 1. This function returns value and type information for
  --     the bind (see object type SQL_BIND).
  --
  -- PARAMETERS:
  --     bind_data (IN) - value of bind_data column from v$sql
  --     position  (IN) - bind position in the statement (starts from 1)
  --
  -- RETURN:
  --     This function will return NULL if one of the condition below is
  --     true:
  --       - the specified bind variable was not captured (only interesting
  --         bind values used by the optimizer are captured) 
  --       - bind position is invalid or out-of-bound
  --       - the specified bind_data is NULL.
  --                                 
  -- NOTE:  
  --     name of the bind in SQL_BIND object is not populated by this function
  ----------------------------------------------------------------------------
  FUNCTION extract_bind(
    bind_data  IN RAW,
    bind_pos   IN PLS_INTEGER)
  RETURN SQL_BIND;

  --------------------------------- extract_binds -----------------------------
  -- NAME: 
  --     extract_binds 
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column captured in v$sql
  --     this function returns the collection (list) of bind values
  --     associated to the corresponding SQL statement. 
  --
  -- PARAMETERS:
  --     bind_data (IN) - value of bind_data column from v$sql
  --
  -- RETURN:
  --     This function returns collection (list) of bind values of 
  --     type sql_bind. 
  --                                 
  -- NOTE:  
  --     For the content of a bind value, refert to function extract_bind
  -----------------------------------------------------------------------------
  FUNCTION extract_binds(
    bind_data  IN RAW)
  RETURN SQL_BIND_SET PIPELINED;

  -------------------------------- is_bind_masked -----------------------------
  -- NAME: 
  --     is_bind_masked
  --
  -- DESCRIPTION:
  --     This function examines a flag to determine if a bind at a given pos
  --     is masked
  --
  -- PARAMETERS:
  --     bind_pos           (IN) - bind position in the stmt (starts from 1)
  --     masked_binds_flag  (IN) - flag to indicate which binds are masked
  --
  -- RETURN:
  --     1 if bind at specified posn is masked, 0 otherwise
  --                                 
  ----------------------------------------------------------------------------
  FUNCTION is_bind_masked(
    bind_pos          IN PLS_INTEGER,
    masked_binds_flag IN RAW DEFAULT NULL)
  RETURN NUMBER;

  ------------------------------- get_binds_count -----------------------------
  -- NAME: 
  --     get_binds_count
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column in raw type this function 
  --     returns the number of bind values contained in the column.
  --
  -- PARAMETERS:
  --     bind_data  (IN) - value of bind_data column from v$sql
  --                       
  -- RETURN:
  --     Number of bind values in the bind data
  --
  -- EXCEPTIONS:
  --     None
  -----------------------------------------------------------------------------
  FUNCTION get_binds_count(bind_data IN RAW) RETURN PLS_INTEGER;

  ----------------------------- cdbcon_dbid_to_name ---------------------------
  --
  -- NAME: 
  --     cdbcon_dbid_to_name - CDB CONtainer DBID TO NAME
  --
  -- DESCRIPTION:  
  --     This function returns a container name given a container dbid. 
  --
  -- PARAMETERS:  
  --     con_dbid    (IN) - (REQUIRED) CDB container dbid 
  --
  -- RETURNS: 
  --     sqlid of the specified sql text
  -----------------------------------------------------------------------------
  FUNCTION cdbcon_dbid_to_name(con_dbid IN NUMBER) 
  RETURN VARCHAR2; 

  ----------------------------- cdbcon_id_to_dbid -----------------------------
  --
  -- NAME: 
  --     cdbcon_id_to_dbid - CDB CONtainer ID TO DBID
  --
  -- DESCRIPTION:  
  --     This procedure returns a container dbid given a container id. 
  --
  -- PARAMETERS:  
  --     con_id    (IN)  - (REQUIRED) CDB container id 
  --     con_dbid  (OUT) - CDB container dbid 
  --
  -- RETURNS: 
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE cdbcon_id_to_dbid(con_id IN PLS_INTEGER, con_dbid OUT NUMBER);
  FUNCTION cdbcon_id_to_dbid(con_id IN PLS_INTEGER) RETURN NUMBER;


  ----------------------------- cdbcon_name2ids-- -----------------------------
  --
  -- NAME: 
  --     cdbcon_name2ids - CDB CONtainer NAME TO DBID,CON_ID
  --
  -- DESCRIPTION:  
  --     This procedure returns a container dbid and container id given 
  --     a container name. 
  --
  -- PARAMETERS:  
  --     con_name    (IN)  - (REQUIRED) CDB container name 
  --     con_id      (OUT) - CDB container id
  --     con_dbid    (OUT) - CDB container dbid 
  --
  -- RETURNS: 
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE cdbcon_name2ids(
    con_name IN         VARCHAR2, 
    con_id   OUT        PLS_INTEGER, 
    con_dbid OUT        NUMBER);
  
  ----------------------------- cdb_is_root -----------------------------------
  --
  -- NAME: 
  --     cdb_is_root - CDB is root
  --
  -- DESCRIPTION:  
  --     This procedure returns TRUE if this is the root container of a CDB
  --     FALSE is returned for PDBs and for non-CDB
  --
  -- PARAMETERS:  
  --     con_name    (OUT) - CDB container name
  --     con_id      (OUT) - CDB container id
  --
  --
  -- RETURNS: 
  --     NONE
  -----------------------------------------------------------------------------
  FUNCTION cdb_is_root(
    con_name OUT        VARCHAR2, 
    con_id   OUT        NUMBER)
  RETURN BOOLEAN;

  ----------------------------- cdb_is_pdb ------------------------------------
  --
  -- NAME: 
  --     cdb_is_pdb - CDB is pdb
  --
  -- DESCRIPTION:  
  --     This procedure returns TRUE if this is a PDB in a CDB 
  --     FALSE is returned for root and for non-CDB
  --
  -- PARAMETERS:  
  --     con_name    (OUT) - CDB container name
  --     con_id      (OUT) - CDB container id
  --
  --
  -- RETURNS: 
  --     NONE
  -----------------------------------------------------------------------------
  FUNCTION cdb_is_pdb(
    con_name OUT        VARCHAR2, 
    con_id   OUT        NUMBER)
  RETURN BOOLEAN;

  ---------------------------- add_subst_pattern ------------------------------
  --
  -- NAME: 
  --     add_subst_pattern - add substitution pattern
  --
  -- DESCRIPTION:  
  --     This function returns :
  --     pattern added table/view name for remote queries 
  --     OR
  --     input table/view name as it is for local queries
  --
  -- PARAMETERS:  
  --     tbl_name     (IN) -  table/view name
  --     
  -- RETURNS: 
  --     table/view name with db_link compliance pattern/ as it is
  -- NOTES:
  -- This function mimics macro KESUTLPAT_STR.    
  -----------------------------------------------------------------------------
  FUNCTION add_subst_pattern(tbl_name IN VARCHAR2)
  RETURN  VARCHAR2;
  
  ---------------------------- get_subst_query -------------------------------
  -- NAME: 
  --    get_subst_query
  --
  -- DESCRIPTION:
  --     This function gets substituted query for the
  --     given original query.
  --    
  --   
  -- PARAMETERS:
  --    orig_qry        (IN)  - original sql query
  --    subst_qry       (OUT) - substituted query.
  --
  -- NOTES
  --   db_links are added to tables/views for remote queries.
  --   local query remains as it is.
  ----------------------------------------------------------------------------
  PROCEDURE get_subst_query(
    orig_qry      IN  VARCHAR2,
    subst_qry     OUT VARCHAR2);
  
  ---------------------------- set_db_link_to_prim------------------------------
  -- NAME: 
  --    set_db_link_to_prim    
  --
  -- DESCRIPTION:
  --    This procedure sets db_link to primary db
  --    
  --   
  -- PARAMETERS:
  --     db_link_to (IN)- db link to primary db
  -- 
  -- RETURNS
  --     VOID
  --
  -----------------------------------------------------------------------------
  PROCEDURE set_db_link_to_prim(db_link_to IN  VARCHAR2);
 
  ---------------------------- get_db_link_to_prim------------------------------
  -- NAME: 
  --    get_db_link_to_prim    
  --
  -- DESCRIPTION:
  --    This procedure returns db_link to a primary db
  --    
  --   
  -- PARAMETERS:
  --     VOID
  -- 
  -- RETURNS
  --    db_link
  --
  -----------------------------------------------------------------------------
  FUNCTION get_db_link_to_prim
  RETURN VARCHAR2;

  ------------------------------ check_dv_access ------------------------------
  -- NAME: 
  --     check_dv_access
  --
  -- DESCRIPTION:
  --     This function checks whether a user has select access on an object
  --     when Database Vault is enabled
  --
  -- PARAMETERS:
  --     user_name         (IN) - user for whom we check privileges
  --     object_owner      (IN) - object owner
  --     object_name       (IN) - object name
  --     object_type       (IN) - object type
  --
  -- RETURN:
  --     0: Command rule or Realm check failure
  --     1: Success or DV is not enabled
  --
  -- NOTES:
  --     This function should be used ONLY for DV realm checks and not for 
  --     general select privilege checking.
  --     If DV is not enabled this function will return TRUE. 
  --     If user_name is NULL this function will check if SYS has privileges
  --     on the object.
  --
  ---------------------------------------------------------------------------- 
  FUNCTION check_dv_access(user_name    IN VARCHAR2 := NULL,
                           object_owner IN VARCHAR2,
                           object_name  IN VARCHAR2,
                           object_type  IN VARCHAR2 := NULL)
  RETURN BINARY_INTEGER
  ACCESSIBLE BY (PACKAGE SYS.DBMS_SQLTUNE);

END dbms_sqltune_util0; 
/
show errors; 


-------------------------------------------------------------------------------
--                    dbms_sqltune_util1 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util1
--
-- DESCRIPTION:
--     As opposed to dbms_sqltune_util0, this package is for sqltune 
--     and sqlpi internal utility procedures and functions that might access 
--     dictionary objects.  It should be used for all general utility 
--     functions that can/need to be DEFINER's rights. If a function only needs
--     to be accessible from the dbms_sqltune/sqldiag/etc feature layer, do
--     not put it here, but rather in the infrastructure layer (prvssqlf). This
--     layer is for code that should be globally accessible, even from the
--     internal package.
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       get_sqlset_identifier
--       get_sqlset_con_dbid
--       get_sqlset_nb_stmts
--       get_view_text
--       get_awr_query_text
--       validate_task_status
--       get_execution_type
--       init_task_wkldobj
--       init_task_spaobj
--       get_wkldtype_name
--       validate_name
--       alter_session_parameter
--       restore_session_parameter
--       get_current_time
--       get_dbid_from_conid
--       resolve_db_type
--       get_awr_view_location
--       is_running_fake_cc_test
--       is_standby
--       check_stby_oper
--       get_seq_remote
--       get_task_name
--       init_remote_context
--       copy_clob
--       is_adaptive_plan
--       replace_awr_view_prefix
--       resolve_exec_name
--       is_exadata_profile
--       is_session_monitored
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util1 AS

  -----------------------------------------------------------------------------
  --                 section for constants and global variables              --
  -----------------------------------------------------------------------------

  -- target object ids which are defined in OBJ_XXX_NUM keat constants  
  OBJ_SQL#             CONSTANT NUMBER       :=  7;     -- obj 
  OBJ_SQLSET#          CONSTANT NUMBER       :=  8;     -- obj 
  OBJ_AUTO_SQLWKLD#    CONSTANT NUMBER       :=  22;    -- obj 
  OBJ_SPA_EXEC_PROP#   CONSTANT NUMBER       :=  23;    -- SPA exec property
  OBJ_SPA_TASK#        CONSTANT NUMBER       :=  24;    -- SPA task obj 
  OBJ_SPM_EVOLVE_TASK# CONSTANT NUMBER       :=  25;    -- SPM evolve task obj 

  -- Execution types 
  --   Names:
  SQLTUNE      CONSTANT VARCHAR2(10) := 'TUNE SQL';
  TEST_EXECUTE CONSTANT VARCHAR2(12) := 'TEST EXECUTE';
  EXPLAIN_PLAN CONSTANT VARCHAR2(12) := 'EXPLAIN PLAN';
  COMPARE      CONSTANT VARCHAR2(19) := 'COMPARE PERFORMANCE';
  STS2TRIAL    CONSTANT VARCHAR2(19) := 'CONVERT SQLSET';
  SQLDIAG      CONSTANT VARCHAR2(19) := 'SQL DIAGNOSIS';
  SPMEVOLVE    CONSTANT VARCHAR2(14) := 'SPM EVOLVE';

  --   IDs: 
  SQLTUNE# CONSTANT PLS_INTEGER := 1;                          /* Sql tuning */
  EXECUTE# CONSTANT PLS_INTEGER := 2;                    /* SQL test execute */
  EXPLAIN# CONSTANT PLS_INTEGER := 3;                    /* SQL explain plan */
  SQLDIAG# CONSTANT PLS_INTEGER := 4;                       /* SQL diagnosis */
  COMPARE# CONSTANT PLS_INTEGER := 5;                   /* compare for SQLPA */
  EVOLVE#  CONSTANT PLS_INTEGER := 6;                          /* SPM Evolve */

  -- DB link owner for remote queries
  TASK_DBLINK_OWNER CONSTANT VARCHAR2(3)   := 'SYS';

  -- DB link user for remote queries
  TASK_DBLINK_USER  CONSTANT VARCHAR2(7)   := 'SYS$UMF';

  -- parameter name for a DB link to a remote db
  PARAM_DBLINK_TO    CONSTANT VARCHAR2(16) := 'DATABASE_LINK_TO';

  --
  -- task_wkldobj, task_sqlobj, property_map
  --
  -- The task_wkldobj structure stores information about the input to
  -- a tuning task.  We examine it during the parts of the report where 
  -- we need to have different logic depending on the target object.  The
  -- 'props' field is a hashtable mapping property names to values, and the
  -- 'sql' field defines the current SQL we are operating on.  For 
  -- single-statement tasks it is populated with the sql target object.
  --
  -- For STSes the workload is the same for all executions so we just load
  -- it up once.  For the automatic sql workload, it is different in each 
  -- execution so we have to refresh the data.
  --
  -- We also define constants for valid property names here.
  TYPE property_map IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32767);
  TYPE task_sqlobj IS RECORD(
    obj_id              NUMBER,
    sql_id              VARCHAR2(13),
    plan_hash_value     NUMBER,
    parsing_schema_name DBMS_ID,
    sql_text            CLOB,
    other_xml           CLOB,
    exec_frequency      NUMBER,
    flags               BINARY_INTEGER,
    con_name            varchar2(30),
    con_dbid            NUMBER
  ); 

  TYPE task_wkldobj IS RECORD(
    adv_id    NUMBER,          -- advisor id#
    task_name VARCHAR2(30),    -- name of the current task
    type      NUMBER,          -- one of OBJ_XXX_NUM keat constants
    obj_id    NUMBER,          -- object id of target object
    props     property_map,    -- (name, value) pairs describing the target
    cursql    task_sqlobj,     -- SQL object for the current statement
    is_cdb    BOOLEAN          -- checks if this ia cdb env
  );

  TYPE task_spaobj IS RECORD(
    exec1_name        VARCHAR2(32767),  -- the execution name of trial one
    exec1_type_num    NUMBER,           -- the execution type of trial one
    comp_exec_name    VARCHAR2(32767),  -- compare exec name, max length ?
    ce_obj_id         NUMBER,           -- obj id of comp env 
    target_obj_type   NUMBER,           -- could be SQLSET or SQL
    target_obj_id     NUMBER,           -- id of the target object of SPA task
    wkld              task_wkldobj      -- has the target obj id
  );  
    
  -- Constants used as property names in the 'props' hashtable

  -- STS properties
  PROP_SQLSET_NAME   CONSTANT VARCHAR2(30) := 'SQLSET_NAME';   -- sts name
  PROP_SQLSET_OWNER  CONSTANT VARCHAR2(30) := 'SQLSET_OWNER';  -- sts owner
  PROP_SQLSET_ID     CONSTANT VARCHAR2(30) := 'SQLSET_ID';     -- sts id
  PROP_SQLSET_DESC   CONSTANT VARCHAR2(30) := 'SQLSET_DESC';   -- sts desc

  -- Shared properties for multi-statement targets
  PROP_NB_SQL        CONSTANT VARCHAR2(30) := 'NB_STMTS';   -- total #stmts
                                                            -- (NOT # in rept)
  PROP_CON_DBID      CONSTANT VARCHAR2(30) := 'CON_DBID';

  -- properties for STS2 (compare STS)
  PROP_SQLSET_NAME2  CONSTANT VARCHAR2(30) := 'SQLSET_NAME2';
  PROP_SQLSET_OWNER2 CONSTANT VARCHAR2(30) := 'SQLSET_OWNER2';
  PROP_SQLSET_ID2    CONSTANT VARCHAR2(30) := 'SQLSET_ID2';   
  PROP_SQLSET_DESC2  CONSTANT VARCHAR2(30) := 'SQLSET_DESC2'; 
  PROP_NB_SQL2       CONSTANT VARCHAR2(30) := 'NB_STMTS2';
  PROP_CON_DBID2     CONSTANT VARCHAR2(30) := 'CON_DBID2';

  -- Automatic Workload properties
  PROP_SUM_ELAPSED   CONSTANT VARCHAR2(30) := 'SUM_ELAPSED'; -- sum of elapsed
                                                               
  -- Single statement properties
  PROP_SQL_ID         CONSTANT VARCHAR2(30) := 'SQL_ID';
  PROP_PARSING_SCHEMA CONSTANT VARCHAR2(30) := 'PARSING_SCHEMA';
  PROP_SQL_TEXT       CONSTANT VARCHAR2(30) := 'SQL_TEXT';
  PROP_TUNE_STATS     CONSTANT VARCHAR2(30) := 'TUNE_STATS';

  -- Parse modes for query
  PARSE_MOD_SQLSET  CONSTANT VARCHAR2(6) := 'SQLSET'     ;
  PARSE_MOD_AWR     CONSTANT VARCHAR2(4) := 'AWR'        ;
  PARSE_MOD_CURSOR  CONSTANT VARCHAR2(5) := 'V$SQL'      ;      
  PARSE_MOD_CAPCC   CONSTANT VARCHAR2(8) := 'V$SQLCAP'   ;
  PARSE_MOD_PROFILE CONSTANT VARCHAR2(10):= 'SQLPROFILE' ;   

  -- Different types for validate_name
  TYPE_STS   CONSTANT BINARY_INTEGER := 0;
  TYPE_DBOP  CONSTANT BINARY_INTEGER := 1;

  --
  -- Database type constants
  -- Describe the type of database that corresponds to the dbid value that 
  -- is passed as parameter to resolve_db_type function.
  -- 
  DB_TYPE_ROOT CONSTANT VARCHAR(4) := 'ROOT';
  DB_TYPE_PDB  CONSTANT VARCHAR(3) := 'PDB';
  DB_TYPE_IMP  CONSTANT VARCHAR(8) := 'IMPORTED';

  --
  -- AWR view prefixes
  -- Describe the location of AWR views that corresponds to a dbid value.
  -- Returned by get_awr_view_location function.
  --
  AWR_VIEW_ROOT CONSTANT VARCHAR(8) := 'AWR_ROOT';
  AWR_VIEW_PDB  CONSTANT VARCHAR(7) := 'AWR_PDB';

  -----------------------------------------------------------------------------
  --                  public utility procedures and functions                --
  -----------------------------------------------------------------------------

  ---------------------------- get_sqlset_identifier --------------------------
  -- NAME: 
  --     get_sqlset_identifier 
  --
  -- DESCRIPTION:
  --     This function gets the SqlSet identifier ginven its name
  --
  -- PARAMETERS:
  --     sts_name  (IN) - sqlset name
  --     sts_owner (IN) - owner of sqlset
  --
  -- RETURN:
  --     The SqlSet id.
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_identifier(sts_name  IN VARCHAR2, sts_owner IN VARCHAR2) 
  RETURN NUMBER;

  ---------------------------- get_sqlset_con_dbid --------------------------
  -- NAME: 
  --     get_sqlset_con_dbid 
  --
  -- DESCRIPTION:
  --     This function gets the container DB id given STS id
  --
  -- PARAMETERS:
  --     sts_id  (IN) - SQL tuning set id
  --
  -- RETURN:
  --     Container DB id.
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_con_dbid(sts_id  IN NUMBER) 
  RETURN NUMBER;

  ----------------------------- get_sqlset_nb_stmts ---------------------------
  -- NAME: 
  --     get_sqlset_nb_stmts 
  --
  -- DESCRIPTION:
  --     This function gets number of SQL statements in a SQL tuning set
  --
  -- PARAMETERS:
  --     sts_id  (IN) - SQL tuning set id
  --
  -- RETURN:
  --     Number of SQL in SQL tuning sets.
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_nb_stmts(sts_id IN NUMBER) 
  RETURN NUMBER;  

  ------------------------------------ get_view_text --------------------------
  -- NAME: 
  --     get_view_text 
  --
  -- DESCRIPTION:
  --     This function is used to return the text of the sql to capture plans 
  --     given a parse mode
  --
  -- PARAMETERS:
  --     parse_mode (IN) - parsing mode (PARSE_MOD_XXX constants)
  --
  -- RETURN:
  --     plan query text corresponding to the parsing mode
  --
  -- NOTE:
  --     Do not use this function with PARSE_MOD_AWR. Use get_awr_query_text
  --     instead, which builds an optimized SQL statement for capturing plans 
  --     from AWR.
  -----------------------------------------------------------------------------
  FUNCTION get_view_text(parse_mode IN VARCHAR2) 
  RETURN VARCHAR2;

  ----------------------------get_awr_query_text ------------------------------
  -- NAME: 
  --     get_awr_query_text 
  --
  -- DESCRIPTION:
  --     This function builds the text of the SQL statement that captures plans 
  --     from AWR based on the flags passed as parameters
  --
  -- PARAMETERS:
  --     con_dbid_bind   (IN) - optionally include :con_dbid bind
  --     stmt_bind       (IN) - optionally include :sql_id, :phv, and :con_dbid 
  --                            binds to target a single (statement, plan)
  --     begin_snap_op   (IN) - optionally include begin_snap: '>' or '>='
  --     stats_only      (IN) - if TRUE then select only from DBA_HIST_SQLSTAT, 
  --                            otherwise join with DBA_HIST_SQLTEXT and 
  --                            DBA_HIST_OPTIMIZER_ENV
  --     cmd_type_filter (IN) - set TRUE if no basic_filter is specified to
  --                            consider only certain types of statements: 
  --                            1: create table, 2: insert, 3: select, 
  --                            6: update, 7: delete, 189: merge
  --     awr_view        (IN) - AWR view location, allowed values are:
  --                            AWR_VIEW_ROOT and AWR_VIEW_PDB 
  --
  -- RETURN:
  --     uniform AWR view query text
  --
  -- NOTES:
  --     1. It is important to only reference tables and views that the user can
  --        also access, since we run the select_xxx queries as invoker rights.
  --
  --     2. The predicate on the flag column of sqlstat is there to ensure that 
  --        we only select sqls that have a full set of data in AWR
  --        (see bug #5659183).
  -----------------------------------------------------------------------------
  FUNCTION get_awr_query_text(
    con_dbid_bind   IN BOOLEAN := FALSE,
    stmt_bind       IN BOOLEAN := FALSE,
    begin_snap_op   IN NUMBER  := 0, 
    stats_only      IN BOOLEAN := FALSE,
    cmd_type_filter IN BOOLEAN := FALSE,
    awr_view        IN VARCHAR2 := AWR_VIEW_ROOT) 
  RETURN VARCHAR2;

  ------------------------------ validate_task_status -------------------------
  -- NAME:
  --     validate_task_status: check whether the task status is valid to 
  --                           be reported
  --
  -- DESCRIPTION:
  --     A task report cannot be generated if the task status is INITIAL
  --     or CANCELED
  --
  -- PARAMETERS:
  --     tid        (IN)     - task identifier
  --
  -- RETURN:
  --     VOID
  --
  -- NOTE:
  --     This function supports remote execution either via UMF or by task
  --     parameters.
  -----------------------------------------------------------------------------
  PROCEDURE validate_task_status(tid IN NUMBER);

  ----------------------------- get_execution_type ----------------------------
  -- NAME:
  --     get_execution_type: get type of a task execution 
  --                     
  --
  -- DESCRIPTION:
  --     This functin retrieve the type of a given task execution
  --
  -- PARAMETERS:
  --     tid        (IN)     - task identifier
  --     ename      (IN)     - name of the execution
  --
  -- RETURN:
  --     VOID
  --
  -- NOTE:
  --     This function supports remote execution either via UMF or by task
  --     parameters.
  -----------------------------------------------------------------------------
  FUNCTION get_execution_type(tid VARCHAR2, ename VARCHAR2) 
  RETURN VARCHAR2;

  ------------------------------ init_task_wkldobj ----------------------------
  -- NAME: 
  --     init_task_wkldobj: initialize the task_wkldobj structure 
  --                        specifying the target of this tuning task.
  --
  -- DESCRIPTION:
  --     This procedure initializes our structure of that defines the object
  --     type of the workload as well as all of its properties.  We pass 
  --     it to different functions in the report that need to have logic about
  --     the input.
  --
  -- PARAMETERS:
  --     tid        (IN)         - task ID
  --     begin_exec (IN)         - first execution name for the report
  --                               (auto wkld only)
  --     end_exec   (IN)         - last execution name for the report 
  --                               (auto wkld only)
  --     target     (OUT NOCOPY) - initialized task_wkldobj structure
  --
  -- RETURN:
  --     VOID
  --
  -- RAISES:
  --     NO_DATA_FOUND if the workload object cannot be located
  --
  -- NOTE:
  --     This function supports remote execution either via UMF or by task
  --     parameters.
  -----------------------------------------------------------------------------
  PROCEDURE init_task_wkldobj(
    tid        IN         NUMBER,       
    begin_exec IN         VARCHAR2 := NULL,
    end_exec   IN         VARCHAR2 := NULL, 
    wkld       OUT NOCOPY task_wkldobj);

  ---------------------------- init_task_spaobj -------------------------------
  -- NAME: 
  --     init_task_spaobj: initialize the task_spaobj structure specifying
  --                       the target of this tuning task.
  --
  -- DESCRIPTION:
  --     This procedure initializes our structure of that defines the object
  --     type of SPA task whose regressions will be tuned by the tuning task.
  --
  -- PARAMETERS:
  --     tid             (IN)         - task ID
  --     comp_exec_name  (IN)         - execution name of compare performance
  --                                    trial for the SPA task
  --     spa_task     (OUT NOCOPY)    - initialized task_wkldobj structure
  --
  -- RETURN:
  --     VOID
  --
  -----------------------------------------------------------------------------
  PROCEDURE init_task_spaobj(
    tid              IN         NUMBER, 
    task_name        IN         VARCHAR2,
    comp_exec_name   IN         VARCHAR2,
    spa_task         OUT NOCOPY task_spaobj);

  ------------------------------ get_wkldtype_name ----------------------------
  -- NAME: 
  --     get_wkldtype_name
  --
  -- DESCRIPTION:
  --     This function returns the string version of the workload type 
  --     number.
  --
  -- PARAMETERS:
  --     type_num  (IN) - OBJ_XXX# constant
  --
  -- RETURN:
  --     Workload type name
  -----------------------------------------------------------------------------
  FUNCTION get_wkldtype_name(type_num IN NUMBER)
  RETURN   VARCHAR2;

  --------------------------------- validate_name -----------------------------
  -- NAME: 
  --     validate_name
  --
  -- DESCRIPTION:
  --     This function checks whether a given name (e.g. sqlset name) is valid.
  --     It is just a syntactic checker, i.e., it does not check whether the 
  --     object actually exists.
  --
  -- PARAMETERS:
  --     name       (IN) - name to validate
  --     type       (IN) - type of identifier to validate
  --
  -- RETURN:
  --     VOID if the name is valid, otherwise an appropriate error
  ---------------------------------------------------------------------------- 
  PROCEDURE validate_name(name IN VARCHAR2, type IN BINARY_INTEGER := NULL);

  -------------------------- alter_session_parameter -------------------------
  -- NAME: 
  --     alter_session_parameter
  --
  -- DESCRIPTION:
  --     This function sets the indicated parameter to a hardcoded value 
  --     if it is currently different, and returns a boolean value indicating
  --     whether or not the value had to be changed.
  --
  --     It is designed to be pretty generic so we can use it for different
  --     parameters but not so generic to cause SQL injections.  Right now
  --     it won't work for anything more than a simple on/off value.  
  --     Values are hardcoded because for the simple boolean scenario it is 
  --     unlikely that we would need to change a session parameter to have
  --     different values.  Typical usage model is as follows:
  --
  --     prm_set := alter_session_parameter(PNUM_XXX);
  --
  --     ...
  --
  --     if (prm_set) then
  --       restore_session_parameter(PNUM_XXX);
  --     end if;
  --
  -- PARAMETERS:
  --     pnum  (IN) - parameter number as PNUM_XXX constant
  --         PNUM_SYSPLS_OBEY_FORCE: set _parallel_syspls_obey_force to FALSE
  --           
  --
  -- RETURN:
  --     TRUE if the parameter value needed to be changed
  ---------------------------------------------------------------------------- 
  PNUM_SYSPLS_OBEY_FORCE CONSTANT NUMBER := 1;    -- change from TRUE to FALSE

  FUNCTION alter_session_parameter(pnum IN NUMBER)
  RETURN BOOLEAN; 

  -------------------------- restore_session_parameter -----------------------
  -- NAME: 
  --     restore_session_parameter
  --
  -- DESCRIPTION:
  --     This function follows up on a call to set_session_parameter by
  --     clearing it back to its initial value.  It should only be called 
  --     when the set function returns TRUE indicating the value was changed.
  --
  -- PARAMETERS:
  --     pnum  (IN) - parameter number as PNUM_XXX constant
  --
  -- RETURN:
  --     NONE
  ---------------------------------------------------------------------------- 
  PROCEDURE restore_session_parameter(pnum IN NUMBER);

  ------------------------------- get_current_time ---------------------------
  -- NAME: 
  --     get_current_time
  --
  -- DESCRIPTION:
  --     Just a wrapper around ksugctm().
  --
  -- PARAMETERS:
  --     None
  --
  -- RETURN:
  --     current time (from ksugctm) as DATE
  ---------------------------------------------------------------------------- 
  FUNCTION get_current_time 
  RETURN DATE;

  ----------------------------- get_dbid_from_conid ---------------------------
  --
  -- NAME: 
  --     get_dbid_from_conid - Get con Dbid From Conid
  --
  -- DESCRIPTION:  
  --     This function returns the container dbid for a container id. If not in 
  --     in a cdb environment, it simply returns the dbid from v$database.
  --
  -- PARAMETERS:  
  --     con_id    (IN)  - (REQUIRED) CDB container id 
  --
  -- RETURNS: 
  --     con_dbid for the given con_id
  -----------------------------------------------------------------------------
  FUNCTION get_dbid_from_conid(con_id IN PLS_INTEGER)
  RETURN NUMBER;  

  -------------------------------- resolve_db_type ----------------------------
  -- NAME: 
  --     resolve_db_type
  --
  -- DESCRIPTION:
  --     This function resolves the type of database that corresponds to the 
  --     dbid given as parameter. It is used by get_awr_view_location function
  --     to determine the location of AWR views.
  --
  -- PARAMETERS:
  --     dbid            (IN)  - database id 
  --                       
  -- RETURN:
  --     Returned type can be 'ROOT', 'PDB' or 'IMPORTED'.
  --
  -----------------------------------------------------------------------------
  FUNCTION resolve_db_type(dbid IN NUMBER) 
  RETURN VARCHAR2;

  ----------------------------- get_awr_view_location -------------------------
  -- NAME: 
  --     get_awr_view_location
  --
  -- DESCRIPTION:
  --     This function determines the location/prefix of the AWR view to use
  --     for the database that corresponds to the dbid parameter.
  --
  -- PARAMETERS:
  --     dbid            (IN)  - database id
  --                       
  -- RETURN:
  --     Returned type can be 'AWR_ROOT' or 'AWR_PDB'.
  --
  -----------------------------------------------------------------------------
  FUNCTION get_awr_view_location(dbid IN NUMBER) 
  RETURN VARCHAR2;

  --------------------------- is_running_fake_cc_test -------------------------
  -- NAME: 
  --     is_running_fake_cc_test: check if we are running the fake cc tests
  --
  --
  -- DESCRIPTION:
  --     Determine from _sta_control, if we are running fake cursor cache 
  --     tests. The capture  sts queries are parsed differently for those tests.
  --
  -- PARAMETERS:
  --     MONE
  --
  -- RETURN:
  --     TRUE if we are running fake cc tests, FALSE otherwise 
  ---------------------------------------------------------------------------- 
  FUNCTION is_running_fake_cc_test
  RETURN BOOLEAN;
    
  ---------------------------- is_standby -----------------------------
  -- NAME: 
  --    is_standby
  --
  -- DESCRIPTION:
  --    check current DB is a physical standby.
  --   
  -- PARAMETERS:
  --    
  --
  -- RETURNS
  --    boolean : When a DB is a physical standby TRUE is returned, 
  --              otherwise FALSE.
  -----------------------------------------------------------------------------
  FUNCTION is_standby
  return BOOLEAN; 
  
  --------------------------- check_stby_oper --------------------------------
  -- NAME: 
  --    check_stby_oper
  --
  -- DESCRIPTION:
  --    This procedure raises an error if it is called from a standby db and
  --    returns otherwise.
  --   
  -- PARAMETERS:
  --    VOID
  --
  -- RETURNS:
  --    VOID 
  --
  -----------------------------------------------------------------------------
  PROCEDURE check_stby_oper;

  ---------------------------- get_seq_remote ------------------------
  -- NAME: 
  --    get_seq_remote
  --
  -- DESCRIPTION:
  --    This PL/SQL function to get sequence from primary 
  --    when it is required at standby.
  --    
  --   
  -- PARAMETERS:
  --    seq_name(IN)  - sequence name
  --    ref_id  (OUT) - sqlset reference id
  --
  -- NOTES:
  --   Sequence like WRI$_SQLSET_REF_ID_SEQ is defined with NOCACHE .
  --   Only cached sequence can be accessed on standby. Therefore ref_id
  --   is retrieved from primary. To retrieve ref_id the following query need
  --   to be executed: 
  --    SELECT sys.wri$_sqlset_ref_id_seq.NEXTVAL FROM DUAL  
  --   We can't execute this query remotely by adding a db link to dual
  --   as it is always try to get a local ref_id. Therefore this query
  --   need to be executed via OCI using a remote service context.  
  --   To serve such purpose, get_sqlset_ref_id_callout is calling 
  --   a C function. 
  -----------------------------------------------------------------------------
  PROCEDURE get_seq_remote(seq_name IN VARCHAR2, ref_id OUT NUMBER) 
  ACCESSIBLE BY (PACKAGE SYS.DBMS_SQLTUNE_INTERNAL);

  ---------------------------- get_task_name ---------------------------------
  -- NAME: 
  --    get_task_name
  --
  -- DESCRIPTION:
  --    This function gets task_name of a given task_id
  --    
  --   
  -- PARAMETERS:
  --     task_id    (IN) - task id
  -- RETURNS
  --     task name
  --
  -----------------------------------------------------------------------------
  FUNCTION get_task_name(task_id    IN NUMBER)
  RETURN VARCHAR2;
  
  ---------------------------- init_remote_context ----------------------------
  -- NAME: 
  --    init_remote_context
  --
  -- DESCRIPTION:
  --    This procedure initialize db_links to/from a remote db
  --    to global variable sqlt_rmt_ctx.
  --   
  -- PARAMETERS:
  --     task_name      (IN)  - task name
  --     db_link_to     (IN)  - database link to remote db
  --     db_link_reqd   (IN)  - database link required
  --     user_id        (IN)  - logged in user id
  -- RETURNS
  --    VOID
  -- NOTES
  -- remote context is required for a remote query.
  -- init_remote_context is called for sql tuning advisor APIs like 
  -- create_tuning_task, execute_tuning_task.
  --
  -----------------------------------------------------------------------------
  PROCEDURE init_remote_context(
    task_name        IN VARCHAR2             := NULL,
    db_link_to       IN VARCHAR2             := NULL,
    db_link_reqd     IN BOOLEAN              := FALSE,
    user_id          IN BINARY_INTEGER       := -1 );
      
  ---------------------------- copy_clob -----------------------------
  -- NAME: 
  --    copy clob
  --
  -- DESCRIPTION:
  --    This procedure returns copying values from remote/local CLOB
  --    to local/remote CLOB
  --    
  --   
  -- PARAMETERS:
  --     inCLOB (IN) - remote/local CLOB
  --     outCLOB(IN/OUT)- local/remote CLOB 
  -- 
  -- RETURNS
  --  void  
  --
  -----------------------------------------------------------------------------
  PROCEDURE copy_clob(
    inCLOB IN CLOB, 
    outCLOB IN OUT NOCOPY CLOB);

  ------------------------------ is_adaptive_plan ----------------------------
  -- NAME: 
  --    is_adaptive_plan
  --
  -- DESCRIPTION:
  --    This function returns TRUE when the specified plan is an adaptive one
  --    
  --   
  -- PARAMETERS:
  --     task_id (IN)  - Identifier of the task
  --     exec_name(IN) - Execution name
  --     plan_id       - Identifier of the execution plan
  --     plan_hash     - Hash value of the execution plan
  --
  -- RETURNS
  --     BOOLEAN: TRUE when the specified plan is adaptive; FALSE otherwise 
  --
  -----------------------------------------------------------------------------
  FUNCTION is_adaptive_plan(
    task_id   IN   NUMBER,
    exec_name IN   VARCHAR2,
    plan_id   IN   NUMBER,
    plan_hash IN   NUMBER)
  RETURN BOOLEAN;

  -------------------------- replace_awr_view_prefix --------------------------
  -- NAME:
  --   replace_awr_view_prefix
  --
  -- DESCRIPTION:
  --   Replaces awr view prefix in the sql text with p_awr_view_prefix 
  --
  -- PARAMETERS:
  --   p_qry                (IN OUT) - sql to replace
  --   p_awr_view_prefix    (IN OUT) - awr view prefix
  --
  -- RETURNS
  --   modified sql
  --
  PROCEDURE replace_awr_view_prefix( 
    p_qry               IN OUT varchar2,
    p_awr_view_prefix   IN OUT varchar2);

  ------------------------------- resolve_exec_name ---------------------------
  -- NAME: 
  --     resolve_exec_name
  --
  -- DESCRIPTION:
  --     This function validates the execution name of a SPA task to ensure 
  --     it was a Compare Performance (type id 5) while if NULL was supplied,
  --     it returns the name of the most recent compare execution for the  
  --     given SPA task.
  --
  -- PARAMETERS:
  --     task_name         (IN)     - name of the SPA task whose execution we
  --                                  are examining
  --     compare_exec_name (IN/OUT) - execution name
  --                       
  -- RETURN:
  --     TRUE if exec_name was valid or we found a valid compare execution 
  --     name of the given SPA task, FALSE otherwise
  --
  -----------------------------------------------------------------------------
  FUNCTION resolve_exec_name(
    task_name   IN     VARCHAR2, 
    task_owner  IN     VARCHAR2,
    exec_name   IN OUT VARCHAR2)
  RETURN NUMBER;

  ---------------------------- is_exadata_profile -----------------------------
  -- NAME: 
  --    is_exadata_profile
  --
  -- DESCRIPTION:
  --    check whether an Exadata-aware profile exists
  --    for a task referenced by a given task_id
  --   
  -- PARAMETERS:
  --    tid (IN) - task id
  --
  -- RETURNS
  --    boolean : IF Exadata-aware profile exists TRUE is returned, 
  --              otherwise FALSE.
  -----------------------------------------------------------------------------
  FUNCTION is_exadata_profile(tid number)
  return BOOLEAN;

  ----------------------------- is_session_monitored -------------------------
  -- NAME: 
  --     is_session_monitored
  --
  -- DESCRIPTION:
  --     This function checks whether there is an active database operation 
  --     that is monitoring a given session.
  --
  -- PARAMETERS:
  --     session_id (IN) - ID of the session
  --                       
  -- RETURN:
  --     TRUE if there is an active DBOP in status EXECUTING or QUEUED for that
  --     session, FALSE otherwise.
  --
  -----------------------------------------------------------------------------
  FUNCTION is_session_monitored(session_id IN NUMBER) 
  RETURN BOOLEAN;

END dbms_sqltune_util1; 
/
show errors; 

-------------------------------------------------------------------------------
--                    dbms_sqltune_util2 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util2
--
-- DESCRIPTION:
--     This package is for shared utility functions that need to be part of
--     an INVOKER rights package.  Like the other dbms_sqltune_utilX packages,
--     it should NOT be documented.  If a function only needs
--     to be accessible from the dbms_sqltune/sqldiag/etc feature layer, do
--     not put it here, but rather in the infrastructure layer (prvssqlf). This
--     layer is for code that should be globally accessible, even from the
--     internal package.
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       resolve_username
--       validate_snapshot
--       sql_binds_ntab_to_varray
--       sql_binds_varray_to_ntab
--       check_priv
--       get_timing_info
--       is_ras_user
--       varr_to_hints_xml
--       get_sqlset_userbinds
--       resolve_database_type
--       is_imported_cdb
--       is_imported_pdb
-- 
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util2 AUTHID CURRENT_USER AS

  --
  -- Database type constants
  -- Describe the type of database that corresponds to the dbid value that 
  -- is passed as parameter to resolve_db_type function.
  -- 
  DB_TYPE_ROOT CONSTANT VARCHAR(4) := 'ROOT';
  DB_TYPE_PDB  CONSTANT VARCHAR(3) := 'PDB';
  DB_TYPE_IMP  CONSTANT VARCHAR(8) := 'IMPORTED';

  -- String constants
  STR_YES   constant varchar2(3) := 'yes';
  STR_NO    constant varchar2(3) := 'no';

  ------------------------------ resolve_username -----------------------------
  -- NAME: 
  --     resolve_username
  --
  -- DESCRIPTION:
  --     When passed a NULL username, this function returns the current schema
  --     owner. Otherwise, it validates the username and returns a normalized
  --     one, i.e.:
  --       - if the username is case-sensitive it removes the double quotes
  --       - else it converts it to uppercase.
  --
  -- PARAMETERS:
  --     user_name    (IN) - the name of the schema to resolve
  --     con_id       (IN) - id of container in which to resolve user_name
  --
  -- RETURN:
  --     normalized schema
  -- 
  -- NOTES
  --     This function is currently used by:
  --       1. SQLset APIs in order to set the sqlset_owner when NULL.
  --       2. Staging table APIs in order to set the staging_schema_owner when
  --          NULL.
  --       3. create_tuning/analysis/diagnosis_task (parsing_schema flavor) in
  --          order to set the parsing_schema when NULL.
  --       4. create_sql_plan_baseline in order to set the parsing_schema when 
  --          NULL.
  --     Note that in all cases the returned schema is used for name resolution
  --     NOT for privilege loading. This function should NOT be used when the 
  --     returned username will be used later on for loading privileges, for 
  --     instance as the owner of an advisor task. This is because the function 
  --     will return the CURRENT_SCHEMA instead of the CURRENT_OWNER when the 
  --     user_name passed is NULL. CURRENT_SCHEMA is not safe since it can 
  --     be modified via 'alter session set current_schema'. 
  -----------------------------------------------------------------------------
  FUNCTION resolve_username(user_name IN VARCHAR2,
                            con_id    IN NUMBER := NULL)
  RETURN VARCHAR2;

  -------------------------------- validate_snapshot --------------------------
  -- NAME: 
  --     validate_snapshot
  --
  -- DESCRIPTION:
  --     This function checks whether a snapshot id interval is valid.
  --     It raises an error if passed an invalid interval.
  --
  -- PARAMETERS:
  --     begin_snap (IN) - begin snapshot id
  --     end_snap   (IN) - end snapshot id
  --     awr_dbid   (IN) - database id
  --     incl_bid   (IN) - TRUE:  fully-inclusive [begin_snap, end_snap]
  --                       FALSE: half-inclusive  (begin_snap, end_snap]
  --
  -- RETURN:
  --      VOID
  --
  -- NOTE:
  --     This function supports remote execution either via UMF or by task
  --     parameters.
  -----------------------------------------------------------------------------
  PROCEDURE validate_snapshot(
    begin_snap IN NUMBER, 
    end_snap   IN NUMBER,
    awr_dbid   IN NUMBER  := NULL,
    incl_bid   IN BOOLEAN := FALSE);

  --------------------------- sql_binds_ntab_to_varray ------------------------
  -- NAME: 
  --     sql_binds_ntab_to_varray
  --
  -- DESCRIPTION:
  --     This function converts the sql binds data from the nested table stored
  --     in the staging table on an unpack/pack to the varray type used in the
  --     SQLSET_ROW. It is called by the unpack_stgtab_sqlset function since it
  --     needs to pass binds as a VARRAY to the load_sqlset function
  --
  -- PARAMETERS:
  --     binds_nt      (IN)  - list of binds for a single statement, in the
  --                           sql_binds nested table type
  --                       
  -- RETURN:
  --     Corresponding varray type (sql_binds_varray) to the input, which is
  --     an ordered list of bind values, of type ANYDATA.
  --     If given null as input this function returns null.
  --
  -----------------------------------------------------------------------------
  FUNCTION sql_binds_ntab_to_varray(binds_ntab IN SQL_BIND_SET)
  RETURN SQL_BINDS;

  ------------------------- sql_binds_varray_to_ntab -------------------------
  -- NAME: 
  --     sql_binds_varray_to_ntab
  --
  -- DESCRIPTION:
  --     This function converts the sql binds data from a VARRAY as it exists
  --     in SQLSET_ROW into a nested table that can be stored in the staging 
  --     table.
  --     It is called by pack_stgtab_sqlset as it inserts into the staging 
  --     table from the output of a call to select_sqlset.
  --
  -- PARAMETERS:
  --     binds_varray      (IN)  - list of binds for a single statement, in the
  --                               sql_binds VARRAY type
  --                       
  -- RETURN:
  --     Corresponding nested table type (sql_bind_set) to the input, which is
  --     a list of (position, value) pairs for the information in STMT_BINDS.
  --     If given null as input this function returns null.
  --
  -----------------------------------------------------------------------------
  FUNCTION sql_binds_varray_to_ntab(binds_varray IN SQL_BINDS)
  RETURN SQL_BIND_SET;

  ----------------------------------- check_priv ------------------------------
  -- NAME: 
  --     check_priv
  --
  -- DESCRIPTION:
  --     This function does a callout into the kernel to check for the given 
  --     system privilege.  It returns TRUE or FALSE based on whether the
  --     current user has the privilege enabled.  This replaces the old-style
  --     privilege detection through SQL with the added benefit that it allows
  --     auditing of the privilege.  This function is just a wrapper around
  --     kzpcap.  This is used for the ADVISOR, ADMINISTER SQL TUNING SET,
  --     and ADMINISTER ANY SQL TUNING SET privileges.
  --
  --     NOTE that this function should only be used when checking privileges
  --     from an INVOKER rights package.  In the callout function we do not
  --     switch the user prior to calling kzpcap, so we rely on the proper
  --     security context already being in effect prior to calling this 
  --     function.  If you call it after switching into a DEFINER rights 
  --     package, it will end up checking if SYS has the priv, not the user.
  --     If you have any questions about its proper use, please consult the 
  --     file owner.
  --
  -- PARAMETERS:
  --     priv (IN) - privilege name
  --                       
  -- RETURN:
  --     TRUE if priv is enabled, FALSE otherwise
  --
  -----------------------------------------------------------------------------
  FUNCTION check_priv(priv IN VARCHAR2)
  RETURN BOOLEAN;

  ------------------------------ get_timing_info ------------------------------
  -- NAME: 
  --     get_timing_info
  --
  -- DESCRIPTION:
  --     This function allows one to get elapsed and CPU timing information
  --     for a section of PL/SQL code
  --
  -- PARAMETERS:
  --     phase          (IN)      - When called: 0 for start, 1 for end
  --     elapsed_time  (IN/OUT)  - When "phase" is 0, OUT parameter storing
  --                               current timestamp. When "phase" is 1, used
  --                               both as IN/OUT to return elpased time.
  --     cpu_time      (IN/OUT)  - When "phase" is 0, OUT parameter storing
  --                               current cpu time. When "phase" is 1, used
  --                               both as IN/OUT to return cpu time.
  --
  -- DESCRIPTION
  --   Use this procedure to measure the elapsed/cpu time of a region of
  --   code:
  --     get_timing_info(0, elapsed, cpu_time);
  --     ...
  --     get_timing_info(1, elapsed, cpu_time);
  --
  -- RETURN:
  --     None
  --
  ---------------------------------------------------------------------------- 
  PROCEDURE get_timing_info(
    phase      IN      BINARY_INTEGER,
    elapsed    IN OUT  NUMBER,
    cpu        IN OUT  NUMBER);

  ------------------------------- is_ras_user --------------------------------
  -- NAME: 
  --     is_ras_user
  --
  -- DESCRIPTION:
  --     This utility function returns TRUE or FALSE based on whether the 
  --     current user is a Real Application Security User (RAS) user. This 
  --     function is used by create_tuning_task, schedule_tuning_task and
  --     create_analysis_task. 
  --
  -- PARAMETERS:
  --                       
  -- RETURN:
  --     TRUE if the current user is a RAS user, FALSE otherwise
  --
  -----------------------------------------------------------------------------
  FUNCTION is_ras_user
  RETURN BOOLEAN;

  ------------------------------- varr_to_hints_xml --------------------------- 
  -- NAME: 
  --     varr_to_hints_xml
  --
  -- DESCRIPTION:
  --     This function converts sqlprof_attr object type to XML format
  --
  -- PARAMETERS:
  --      sqlprof_attr (IN) - hints in attribute format
  --
  -- RETURN:
  --      hints in their XML format 
  --
  -- EXCEPTIONS:
  --      None
  --
  -----------------------------------------------------------------------------
  FUNCTION varr_to_hints_xml(varr IN sqlprof_attr)
  RETURN CLOB;

  ----------------------------- get_sqlset_userbinds --------------------------
  -- NAME: 
  --     get_sqlset_userbinds
  --
  -- DESCRIPTION:
  --     This function gets the list of binds of a given SQL statement from 
  --     a table and converts the list of binds into a varray as required by 
  --     sqlset_row. This function is used in dbms_sqltune.unpack_sqlsets_bulk
  --
  -- PARAMETERS:
  --     sql_id          (IN)  - SQL id 
  --     plan_hash_value (IN)  - plan hash value 
  --     sqlset_name     (IN)  - SQLset name
  --     sqlset_owner    (IN)  - SQLset owner
  --     table_name      (IN)  - name of the table that contains the binds
  --                       
  -- RETURN:
  --     Corresponding varray type (sql_binds_varray) to the input, which is
  --     an ordered list of bind values, of type ANYDATA.
  --     This function returns null if there are no binds. 
  --
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_userbinds(sql_id          IN VARCHAR2, 
                                plan_hash_value IN NUMBER,
                                sqlset_name     IN VARCHAR2, 
                                sqlset_owner    IN VARCHAR2, 
                                table_name      IN VARCHAR2)
  RETURN SQL_BINDS;


  -------------------------- resolve_database_type ----------------------------
  -- NAME: 
  --     resolve_database_type
  --
  -- DESCRIPTION:
  --     This function resolves the type of database that corresponds to the 
  --     dbid given as parameter. It is used by get_awr_view_location function
  --     to determine the location of AWR views.
  --
  -- PARAMETERS:
  --     dbid            (IN)  - database id 
  --                       
  -- RETURN:
  --     Returned type can be 'ROOT', 'PDB' or 'IMPORTED'.
  --
  -----------------------------------------------------------------------------
  FUNCTION resolve_database_type(dbid IN NUMBER) 
  RETURN VARCHAR2;

  ---------------------------- is_imported_cdb --------------------------------
  -- NAME: is_imported_cdb
  --
  -- DESCRIPTION: Checks whether the dbid is imported cdb or not
  --
  -- PARAMETERS:
  --   dbid   (IN) - dbid
  --
  -- RETURNS:
  --    boolean true if dbid is imported cdb
  --    boolean false if dbid is not imported cdb
  --
  function is_imported_cdb (
    p_dbid            IN number)
  return varchar2;

  ---------------------------- is_imported_pdb --------------------------------
  -- NAME: is_imported_pdb
  --
  -- DESCRIPTION: Checks whether the dbid is imported cdb or not
  --
  -- PARAMETERS:
  --   dbid   (IN) - dbid
  --
  -- RETURNS:
  --    boolean true if dbid is imported pdb
  --    boolean false if dbid is not imported pdb
  --
  function is_imported_pdb (
    p_dbid            IN number)
  return varchar2;

END dbms_sqltune_util2;
/
show errors;
/

GRANT EXECUTE ON DBMS_SQLTUNE_UTIL2 TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
