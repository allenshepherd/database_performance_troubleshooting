Rem
Rem $Header: rdbms/admin/dbmssqls.sql /main/1 2017/05/02 14:15:36 aarvanit Exp $
Rem
Rem dbmssqls.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssqls.sql - DBMS SQL Set
Rem
Rem    DESCRIPTION
Rem     This package contains the procedure and function declaration for SQL 
Rem     Tuning Sets
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssqls.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssqls.sql
Rem    SQL_PHASE: DBMSSQLS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aarvanit    11/01/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

------------------------------------------------------------------------------
--                     DBMS_SQLSET FUNCTION DESCRIPTIONS                    --
------------------------------------------------------------------------------
--  SQL Tuning Set functions
-----------------------------
--    DDL
--     create_sqlset:        create a SQL tuning set (create DDL)
--     drop_sqlset:          drop a SQL tuning set   (drop DDL)
--
--    DML
--     delete_sqlset:        delete statements from SQL tuning set (delete DML)
--     load_sqlset:          load statements into SQL tuning set   (insert DML)
--     update_sqlset:        update statements in a SQL tuning set (update DML)
--
--     capture_cursor_cache: incrementally capture statements from the cursor 
--                           cache into a SQL tuning set, repeating over a 
--                           fixed interval.
--
--
--    add/remove_reference: add/remove a reference to a SQL tuning set
--    
--    select_cursor_cache/workload_repository/sqlset: select statements from
--                           a data source and return them in a format ready to
--                           be inserted into a SQL tuning set.
--    select_sql_trace:      same as the above, only for SQL trace files
--    select_sqlpa_task:     same as the above, only for a SPA trial  
--
--    Import/Export
--      create_stgtab: create staging table
--      pack_stgtab:   dump SQL tuning set(s) into staging table
--      unpack_stgtab: create SQL tuning set(s) from staging table data
--      remap_stgtab:  update data in staging table

-------------------------------------------------------------------------------
--                       dbms_sqlset package declaration                     --
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_sqlset AUTHID CURRENT_USER AS

  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------

  --
  -- capture section constants
  --
  MODE_REPLACE_OLD_STATS CONSTANT NUMBER := dbms_sqltune.MODE_REPLACE_OLD_STATS;
  MODE_ACCUMULATE_STATS  CONSTANT NUMBER := dbms_sqltune.MODE_ACCUMULATE_STATS;

  --
  -- SQL tuning set constants
  --
  SINGLE_EXECUTION     CONSTANT POSITIVE := dbms_sqltune.SINGLE_EXECUTION;
  ALL_EXECUTIONS       CONSTANT POSITIVE := dbms_sqltune.ALL_EXECUTIONS;
  LIMITED_COMMAND_TYPE CONSTANT BINARY_INTEGER := 
                                       dbms_sqltune.LIMITED_COMMAND_TYPE;
  ALL_COMMAND_TYPE     CONSTANT BINARY_INTEGER := dbms_sqltune.ALL_COMMAND_TYPE;

  -- sqlset staging table constants
  STS_STGTAB_10_2_VERSION   CONSTANT NUMBER := 
                                     dbms_sqltune.STS_STGTAB_10_2_VERSION;
  STS_STGTAB_11_1_VERSION   CONSTANT NUMBER := 
                                     dbms_sqltune.STS_STGTAB_11_1_VERSION;
  STS_STGTAB_11_2_VERSION   CONSTANT NUMBER :=
                                     dbms_sqltune.STS_STGTAB_11_2_VERSION;
  STS_STGTAB_11_202_VERSION CONSTANT NUMBER :=                              
                                     dbms_sqltune.STS_STGTAB_11_202_VERSION;
  STS_STGTAB_12_1_VERSION   CONSTANT NUMBER :=
                                     dbms_sqltune.STS_STGTAB_12_1_VERSION;
  STS_STGTAB_12_2_VERSION   CONSTANT NUMBER :=
                                     dbms_sqltune.STS_STGTAB_12_2_VERSION;

  -- constant for recursive sql filter
  NO_RECURSIVE_SQL  CONSTANT VARCHAR2(30) := dbms_sqltune.NO_RECURSIVE_SQL;
  HAS_RECURSIVE_SQL CONSTANT VARCHAR2(30) := dbms_sqltune.HAS_RECURSIVE_SQL;

  -----------------------------------------------------------------------------
  --                    procedure / function declarations                    --
  -----------------------------------------------------------------------------

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                        ---------------------------                      --
  --                        SQLSET PROCEDURES/FUNCTIONS                      --
  --                        ---------------------------                      --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  
  -----------------------------------------------------------------------------
  --                                 Examples                                --
  -----------------------------------------------------------------------------
  -- In the following we give two examples that show how to use the package in 
  -- order to create, populate, manipulate and drop a sqlset. 
  -- The first example shows how to build a new sqlset by extracting 
  -- data from the Cursor cache, while the second one explains how to build a 
  -- sqlset from a USER defined workload. 
  --
  --------------------------------------------
  -- EXAMPLE 1: select from the cursor cache --
  --------------------------------------------
  --
  -- DECLARE
  --    sqlset_name  VARCHAR2(30);                            /* sqlset name */
  --    sqltset_cur  dbms_sqlset.sqlset_cursor;  /* a sqlset cursor variable */
  --    ref_id       NUMBER;                      /* a reference on a sqlset */
  -- BEGIN
  --
  --   /* Choose an name for the sqlset to create */
  --   sqlset_name := 'SQLSET_TEST_1';
  --
  --   /* Create an empty sqlset. You automatically become the owner of 
  --      this sqlset */
  --   dbms_sqlset.create_sqlset(sqlset_name, 'test purpose');
  --
  --   /***********************************************************************
  --    * Call the select_cursor_cache table function to order the sql        *
  --    * statements in the cursor cache by cpu_time (ranking measure1) and   *
  --    * then, select only that subset of statements, which contribute to 90%*
  --    * (result percentage) of total cpu_time, but not more than Only 100   *
  --    * statements, i.e., top 100 which represents (result_limit).          *
  --    * Only the firts ranking measure is spefied and the content of        *
  --    * the cursor cache is not filtered.                                   *
  --    *                                                                     *
  --    * The OPEN-FOR statement associates the sqlset cursor variable        *
  --    * with the SELECT-FROM-TABLE dynamic query which is used to call the  *
  --    * table function and fetch its results. Notice that you need not to   *
  --    * close the cursor. When this cursor is used to populate a Sql Tuning *
  --    * Set using the load_sqlset procedure, this later will close it for   *
  --    * you.                                                                *
  --    *                                                                     *
  --    * Notice the use of function VALUE(P) which takes as its argument,    *
  --    * the table alias for the table function and returns object instances *
  --    * corresponding to rows as retuned by the table function which are    *
  --    * instances of type SQLSET_ROW.                                     *
  --    * ********************************************************************/
  --   OPEN sqlset_cur FOR
  --     SELECT VALUE(P)                            /* use of function VALUE */
  --     FROM TABLE(
  --      dbms_sqlset.select_cursor_cache(NULL,              /* basic filter */
  --                                      NULL,             /* object filter */
  --                                     'cpu_time',        /* first ranking */
  --                                      NULL,            /* second ranking */
  --                                      NULL,             /* third ranking */
  --                                      0.9,                 /* percentage */
  --                                      100)                      /* top N */
  --               ) P;                                    /* table instance */
  --
  --
  --   /***********************************************************************
  --    * Call the load_sqlset procedure to populate the created              *
  --    * sqlset by the results of the cursor cache table function            *
  --    **********************************************************************/
  --    dbms_sqlset.load_sqlset(sqlset_name, sqlset_cur);
  --
  --   /***********************************************************************
  --    * Add a reference to the sqlset so that other users cannot            *
  --    * modified it, i.e., drop it, delete statement from it, update it or  *
  --    * load it. Like this, the sqlset is protected. User have only         *
  --    * a read-only access to the sqlset.                                   *
  --    * The add_reference function returns a reference ID that will be used *
  --    * later to deactivate the sqlset.                                     *
  --    **********************************************************************/
  --    ref_id := 
  --      dbms_sqlset.add_reference(sqlset_name, 'test sqlset: '|| sqlset_name);
  --
  --    /* process your sqlset */
  --    ...
  --    ...
  --    ...
  --
  --    /**********************************************************************
  --     * When your are done, remove the reference on the sqlset, so that it *
  --     * can be modified either by you (owner) or by another user who has a *
  --     * super privilege ADMINISTER ANY SQLSET, etc.                        *
  --     *********************************************************************/
  --     dbms_sqlset.remove_reference(sqlset_name, ref_id);
  --
  --
  --     /* Call the drop procedure to drop the sqlset */
  --     dbms_sqlset.drop_sqlset(sqlset_name);
  --     ...
  -- END
  --
  --------------------------------------------
  -- EXAMPLE 2: select from a user workload --
  --------------------------------------------
  --
  -- DECLARE
  --    sqlset_name VARCHAR2(30);                             /* sqlset name */
  --    sqlset_cur  dbms_sqlset.sqlset_cursor;   /* a sqlset cursor variable */
  --    ref_id      NUMBER;                       /* a reference on a sqlset */
  -- BEGIN
  --
  --   /* Choose an name for the sqlset to create */
  --   sqlset_name := 'SQLSET_TEST_2';
  --
  --   /* Create an empty sqlset. You automatically become the owner of 
  --      this SQLSET */
  --   dbms_sqlset.create_sqlset(sqlset_name, 'test purpose');
  --
  --   /***********************************************************************
  --    * In this example we suppose that the user workload is stored in      *
  --    * a single table USER_WORKLOAD_TABLE. We suppose that the table stores*
  --    * only the text of a set of SQL statements identified by their sql_id.*
  --    * Use the OPEN-FOR statement to associate the query that extracts the *
  --    * content of the user workload, with a sqlset cursor before loading it*
  --    * into the sqlset.                                                    *
  --    * Notice the use of the CONSTRUCTOR of the sqlset_row object type     *
  --    * This is IMPORTANT because the cursor MUST contain instances         *
  --    * of this type as required by the load_sqlset function. Otherwise an  *
  --    * error will occur and the SQLSET will not be loaded.                 *
  --    **********************************************************************/
  --    OPEN sqlset_cur FOR
  --      SELECT 
  --        SQLSET_ROW(sql_id, sql_text, null, null, null, null,
  --                   null, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, 0, 0, 0, 0
  --                   ) AS row 
  --        FROM user_workload_table;     
  --     
  --   /***********************************************************************
  --    * Call the load_sqlset procedure to populate the created sqlset with  *
  --    * the results of the cursor                                           *
  --    **********************************************************************/
  --   dbms_sqlset.load_sqlset(sqlsetname, sqlsetcur);
  --   
  --   /* the rest of the steps are similar to those in example 1 */
  --   ...
  --   ...
  --   ...
  -- END;
  --  
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  --                               type declarations                         --
  -----------------------------------------------------------------------------
  ----------------------------------- sqlset_cursor ---------------------------
  -- NAME: 
  --     sqlset_cursor 
  --
  -- DESCRIPTION: 
  --     define a cursor type for SQL statements with their related data. 
  --     This type is mainly used by the load_sqlset procedure as an argument  
  --     to populate a sqlset from a possible data source. See the load_sqlset 
  --     description for more details.   
  --
  -- NOTES:
  --    It is important to keep in mind that this cursor is WEAKLY DEFINED.
  --    A variable of type sqlStatCursor when it is used either as an input
  --    by the load_sqlset procedure or returned by all table functions, it 
  --    MUST contain rows of type sqlset_row.
  ----------------------------------------------------------------------------
  TYPE sqlset_cursor IS REF CURSOR;
  
  
  -----------------------------------------------------------------------------
  --                        procedure/function declarations                  --
  -----------------------------------------------------------------------------
  ---------------------------------- create_sqlset ----------------------------
  -- NAME:
  --     create_sqlset
  --
  -- DESCRIPTION:
  --     This procedure creates a sqlset object in the database.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name
  --    description  (IN) - the description of the sqlset
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  -----------------------------------------------------------------------------
  PROCEDURE create_sqlset(
    sqlset_name  IN VARCHAR2,
    description  IN VARCHAR2 := NULL,
    sqlset_owner IN VARCHAR2 := NULL);
  
  ---------------------------------- create_sqlset ----------------------------
  -- NAME: 
  --     create_sqlset
  --
  -- DESCRIPTION: 
  --     This procedure creates a sqlset object in the database.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name, can be NULL or omitted 
  --                        (in which case a name is generated automatically)
  --    description  (IN) - the description of the sqlset
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  --
  -- RETURNS:
  --     name of sqlset created.  This will be the name passed in or, if a name
  --     is omitted (or NULL arg passed), the name we automatically create for
  --     the sqlset
  -----------------------------------------------------------------------------
  FUNCTION create_sqlset(
    sqlset_name   IN VARCHAR2 := NULL,
    description   IN VARCHAR2 := NULL,
    sqlset_owner  IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  ----------------------------------- drop_sqlset -----------------------------
  -- NAME: 
  --     drop_sqlset
  --
  -- DESCRIPTION:
  --     This procedure is used to drop a sqlset if it is not active.
  --     When a sqlset is referenced by one or more clients 
  --     (e.g. SQL tune advisor), it cannot be dropped.
  --
  -- PARAMETERS:
  --     sqlset_name  (IN) - the sqlset name.
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current 
  --                         schema owner
  -----------------------------------------------------------------------------
  PROCEDURE drop_sqlset(
    sqlset_name   IN VARCHAR2,
    sqlset_owner  IN VARCHAR2 := NULL);
  
  -------------------------------- delete_sqlset ------------------------------
  -- NAME: 
  --     delete_sqlset
  --
  -- DESCRIPTION:
  --     Allows the deletion of a set of SQL statements from a sqlset.
  --
  -- PARAMETERS:
  --     sqlset_name  (IN) - the sqlset name
  --     basic_filter (IN) - SQL predicate to filter the SQL from the 
  --                         sqlset. This basic filter is used as 
  --                         a where clause on the sqlset content to 
  --                         select a desired subset of Sql from the Tuning Set
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current 
  --                         schema owner  
  -----------------------------------------------------------------------------
  PROCEDURE delete_sqlset(
    sqlset_name  IN VARCHAR2,
    basic_filter IN VARCHAR2 := NULL,  
    sqlset_owner IN VARCHAR2 := NULL);
  
  ---------------------------------- load_sqlset ------------------------------
  -- NAME: 
  --  load_sqlset
  --
  -- DESCRIPTION:
  --  This procedure populates the sqlset with a set of selected SQL.
  --
  -- PARAMETERS:
  --  sqlset_name        (IN) - the name of sqlset to populate
  --  populate_cursor    (IN) - the cursor reference to populate from
  --  load_option        (IN) - specifies how the statements will be loaded 
  --                            into the SQL tuning set. 
  --                            The possible values are: 
  --                             + INSERT (default):  add only new statements 
  --                             + UPDATE: update existing the SQL statements 
  --                             + MERGE: this is a combination of the two 
  --                                      other options. This option inserts 
  --                                      new statements and updates the 
  --                                      information of the existing ones. 
  --  update_option      (IN) - specifies how the existing statements will be 
  --                            updated. This parameter is considered only if 
  --                            load_option is specified with 'UPDATE'/'MERGE'
  --                            as an option. The possible values are:
  --                             + REPLACE (default): update the statement 
  --                                 using the new statistics, bind list, 
  --                                 object list, etc. 
  --                             + ACCUMULATE: when possible combine attributes
  --                                (e.g., statistics like elapsed_time, etc.) 
  --                                otherwise just replace the old values 
  --                                (e.g., module, action, etc.) by the new 
  --                                provided ones. The SQL statement attributes
  --                                that can be accumulated are: elapsed_time,
  --                                buffer_gets, disk_reads, row_processed, 
  --                                fetches, executions, end_of_fetch_count, 
  --                                stat_period and active_stat_period.
  --  update_attributes (IN) - specifies the list of a SQL statement attributes
  --                           to update during a merge or update operation.  
  --                           The possible values are:
  --                            + NULL (default): the content of the input 
  --                               cursor except the execution context. 
  --                               On other terms, it is equivalent to ALL 
  --                               without execution context like module,
  --                               action, etc. 
  --                            + BASIC: statistics and binds only.
  --                            + TYPICAL: BASIC + SQL plans (without 
  --                                   row source statistics) and without 
  --                                   object reference list. 
  --                            + ALL: all attributes including the execution
  --                                context attributes like module, action, etc
  --                            + List of comma separated attribute names to 
  --                                update: EXECUTION_CONTEXT,
  --                                        EXECUTION_STATISTICS,
  --                                        SQL_BINDS,
  --                                        SQL_PLAN,
  --                                        SQL_PLAN_STATISTICS: similar to
  --                                        SQL_PLAN + row source statistics.
  --  update_condition (IN) - specifies a where clause to execute the update 
  --                          operation. The update is performed only if 
  --                          the specified condition is true. The condition 
  --                          can refer to either the data source or 
  --                          destination. The condition must use the following
  --                          prefixes to refer to attributes from the source
  --                          or the destination:
  --                           + OLD: to refer to statement attributes from
  --                                  the SQL tuning set (destination)
  --                           + NEW: to refer to statements attributes from
  --                                  the input statements (source)
  --                         Example: 'new.executions >= old.executions'. 
  --  ignore_null     (IN) - If true do not update an attribute if the new 
  --                         value is null, i.e., do not override with null 
  --                         values unless it is intentional.
  --  commit_rows     (IN) - if a value is provided, the load will commit
  --                         after each set of that many statements is 
  --                         inserted.  If NULL is provided, the load will
  --                         commit only once, at the end of the operation.
  --  sqlset_owner    (IN) - the owner of the sqlset or null for current
  --                         schema owner.
  -- Exceptions:
  --  This procedure returns an error when sqlset_name is invalid 
  --  or a corresponding sqlset does not exist, the populate_cursor 
  --  is incorrect and cannot be executed.
  --  FIXME: other exceptions are raised by this procedure. Need to update 
  --         comments.
  -----------------------------------------------------------------------------
  PROCEDURE load_sqlset(
    sqlset_name       IN VARCHAR2,
    populate_cursor   IN sqlset_cursor,  
    load_option       IN VARCHAR2 := 'INSERT',  
    update_option     IN VARCHAR2 := 'REPLACE', 
    update_condition  IN VARCHAR2 :=  NULL,
    update_attributes IN VARCHAR2 :=  NULL, 
    ignore_null       IN BOOLEAN  :=  TRUE,
    commit_rows       IN POSITIVE :=  NULL,
    sqlset_owner      IN VARCHAR2 :=  NULL);

  ------------------------------- capture_cursor_cache ------------------------
  -- NAME: 
  --     capture_cursor_cache
  --
  -- DESCRIPTION:
  --     This procedure captures a workload from the cursor cache into a SQL
  --     tuning set, polling the cache multiple times over a time period and
  --     updating the workload data stored there.  It can execute over as long
  --     a period as required to capture an entire system workload.
  --
  --     Note that this procedure commits after each incremental capture of
  --     statements, so you can monitor its progress by looking at the sqlset
  --     views.  This operation is much more efficient than 
  --     select_cursor_cache/load_sqlset so it should be used whenever you need 
  --     to repeatedly capture a workload from the cursor cache.
  --
  --     ** ALSO NOTE ** This function does not capture the SQL present
  --     in the cursor cache when it is invoked, but rather it collects those
  --     SQL run over the 'time_limit' period in which it is executing.
  --
  -- PARAMETERS:
  --     sqlset_name     (IN)- the SQLSET name
  --     time_limit      (IN)- the total amount of time, in seconds, to execute
  --     repeat_interval (IN)- the amount of time, in seconds, to pause 
  --                           between sampling
  --     capture_option  (IN)- during capture, either insert new statements,
  --                           update existing ones, or both.  'INSERT', 
  --                           'UPDATE', or 'MERGE' just like load_option in
  --                           load_sqlset
  --     capture_mode    (IN)- capture mode (UPDATE and MERGE capture options).
  --                           Possible values:
  --                            + MODE_REPLACE_OLD_STATS - Replace statistics
  --                              when the number of executions seen is greater
  --                              than that stored in the STS
  --                            + MODE_ACCUMULATE_STATS - Add new values to 
  --                              current values for SQL we already store.
  --                              Note that this mode detects if a statement
  --                              has been aged out, so the final value for a
  --                              statistics will be the sum of the statistics
  --                              of all cursors that statement existed under.
  --     basic_filter    (IN)- filter to apply to cursor cache on each sampling
  --                            (see select_xxx)
  --     sqlset_owner    (IN)- the owner of the sqlset, or null for current
  --                           schema owner
  --     recursive_sql   (IN) - filter out the recursive SQL if NO_RECURSIVE_SQL
  -----------------------------------------------------------------------------
  PROCEDURE capture_cursor_cache(
    sqlset_name         IN VARCHAR2,
    time_limit          IN POSITIVE := 1800,
    repeat_interval     IN POSITIVE := 300,
    capture_option      IN VARCHAR2 := 'MERGE',
    capture_mode        IN NUMBER   := MODE_REPLACE_OLD_STATS,
    basic_filter        IN VARCHAR2 := NULL,
    sqlset_owner        IN VARCHAR2 := NULL,
    recursive_sql       IN VARCHAR2 := HAS_RECURSIVE_SQL);
    
  ----------------------------------- update_sqlset ---------------------------
  -- NAME: 
  --     update_sqlset
  --
  -- DESCRIPTION:
  --     This procedure updates selected string fields for a SQL statement 
  --     in a sqlset.
  --     Fields that could be updated are MODULE, ACTION, PARSING_SCHEMA_NAME 
  --     and OTHER.
  --
  -- PARAMETERS:
  --     sqlset_name     (IN) - the SQLSET name
  --     sql_id          (IN) - identifier of the statement to update
  --     plan_hash_value (IN) - plan hash value of a particular plan of 
  --                            the SQL 
  --     attribute_name  (IN) - the name of the attribute to modify. 
  --     attribute_value (IN) - the new value of the attribute
  --     sqlset_owner    (IN) - the owner of the sqlset, or null for current
  --                            schema owner
  -----------------------------------------------------------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    plan_hash_value IN NUMBER := NULL,
    attribute_name  IN VARCHAR2,
    attribute_value IN VARCHAR2 := NULL,
    sqlset_owner    IN VARCHAR2 := NULL);
  
  ----------------------------------- update_sqlset ---------------------------
  -- NAME: 
  --     update_sqlset
  --
  -- DESCRIPTION:
  --     This is an overloaded procedure of the previous one. It is provided 
  --     to be able to set numerical attributes of a SQL in a sqlset.
  --     The only NUMBER attribute that could be updated is PRIORITY. 
  --     If the statement has more than one plan (i.e., multiple plans with an 
  --     entry for every different plan_hash_value in plan table), 
  --     the attribute value will be then changed (replaced) for all plan 
  --     entries of the statement using the same (new) value. 
  --     To update the attribute value for a particular plan use the other 
  --     version of this procedure that, besides sql_id, it takes 
  --     a plan_hash_value as an argument. 
  --
  -- PARAMETERS: 
  --     sqlset_name     (IN) - the sqlset name
  --     sql_id          (IN) - identifier of the statement to update
  --     plan_hash_value (IN) - plan hash value of a particular plan of 
  --                            the SQL 
  --     attribute_name  (IN) - the name of the attribute to modify. 
  --     attribute_value (IN) - the new value of the attribute
  --     sqlset_owner    (IN) - the owner of the sqlset, or null for current
  --                            schema owner
  -----------------------------------------------------------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    plan_hash_value IN NUMBER := NULL,
    attribute_name  IN VARCHAR2,
    attribute_value IN NUMBER   := NULL,  
    sqlset_owner    IN VARCHAR2 := NULL);
  
  --------------------------------- add_reference -----------------------------
  -- NAME: 
  --     add_reference
  --
  -- DESCRIPTION:
  --     This function adds a new reference to an existing sqlset 
  --     to indicate its use by a client.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name.
  --    description  (IN) - description of the usage of sqlset.
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  --
  -- RETURN:
  --     The identifier of the added reference.
  -----------------------------------------------------------------------------
  FUNCTION add_reference(
    sqlset_name  IN VARCHAR2,
    description  IN VARCHAR2 := NULL,
    sqlset_owner IN VARCHAR2 := NULL)
  RETURN NUMBER;
    
  --------------------------------- remove_reference --------------------------
  -- NAME: 
  --     remove_reference
  --
  -- DESCRIPTION:
  --     This procedure is used to deactivate a sqlset to indicate it 
  --     is no longer used by the client.
  --
  -- PARAMETERS:
  --     name         (IN) - the SQLSET name
  --     reference_id (IN) - the identifier of the reference to remove. 
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current
  --                         schema owner
  --     force_remove (IN) - if 1: allow removing other users' references
  --
  -- NOTES:
  --     Setting force_remove to 1 only takes effect if the user has the 
  --     ADMINISTER ANY SQL TUNING SET privilege. Otherwise force_remove will 
  --     be ignored, i.e. only the references owned by the user will be removed
  -----------------------------------------------------------------------------
  PROCEDURE remove_reference(
    sqlset_name  IN VARCHAR2,
    reference_id IN NUMBER,
    sqlset_owner IN VARCHAR2 := NULL,
    force_remove IN NUMBER   := 0);
        
  ----------------------------------- select_sqlset ---------------------------
  -- NAME: 
  --     select_sqlset
  --
  -- DESCRIPTION:
  --     This is a table function to read sql tuning set content.
  --
  -- PARAMETERS:
  --     sqlset_name        (IN) - sqlset name to select from
  --     basic_filter       (IN) - SQL predicate to filter the SQL statements 
  --                               from the specified sqlset
  --     object_filter      (IN) - objects that should exist in the object list
  --                               of selected SQL.  Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL
  --     result_percentage  (IN) - a percentage on the sum of a ranking measure
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure         
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and 
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar to 
  --                                       SQL_PLAN + row source statistics. 
  --     plan_filter       (IN) - plan filter. It is applicable in case there 
  --                              are multiple plans (plan_hash_value) 
  --                              associated to the same statement. This filter
  --                              allows selecting one plan (plan_hash_value) 
  --                              only. Possible values are:
  --                              + LAST_GENERATED: plan with most recent 
  --                                                timestamp.
  --                              + FIRST_GENERATED: opposite to LAST_GENERATED
  --                              + LAST_LOADED: plan with most recent 
  --                                             first_load_time stat info. 
  --                              + FIRST_LOADED: opposite to LAST_LOADED
  --                              + MAX_ELAPSED_TIME: plan with max elapsed 
  --                                                  time
  --                              + MAX_BUFFER_GETS: plan with max buffer gets
  --                              + MAX_DISK_READS: plan with max disk reads
  --                              + MAX_DIRECT_WRITES: plan with max direct 
  --                                                   writes
  --                              + MAX_OPTIMIZER_COST: plan with max opt. cost
  --     sqlset_owner      (IN) - the owner of the sqlset, or null for current
  --                              schema owner
  --     recursive_sql     (IN) - filter out the recursive SQL 
  --                              if NO_RECURSIVE_SQL
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_sqlset( 
    sqlset_name       IN VARCHAR2,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    plan_filter       IN VARCHAR2 := NULL,
    sqlset_owner      IN VARCHAR2 := NULL,
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;
  
  ---------------------------- select_cursor_cache ----------------------------
  -- NAME: 
  --     select_cursor_cache
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     the Cursor Cache.
  --
  -- PARAMETERS:
  --     basic_filter       (IN) - SQL predicate to filter the SQL from the 
  --                               cursor cache.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from the
  --                               cursor cache.  Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL.
  --     result_percentage  (IN) - a percentage on the sum of a rank measure.
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure. 
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --
  --     recursive_sql       (IN) - filter out the recursive SQL 
  --                                if NO_RECURSIVE_SQL
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_cursor_cache(
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;  
  
  ------------------------- select_workload_repository ------------------------
  -- NAME: 
  --     select_workload_repository
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     the workload repository. It is used to collect SQL statements from all
  --     snapshots between begin_snap and and end_snap or from a specified
  --     baseline. 
  --
  -- PARAMETERS:
  --     begin_snap         (IN) - begin snapshot
  --     end_snap           (IN) - end snapshot
  --     baseline_name      (IN) - the name of the baseline period.   
  --     basic_filter       (IN) - SQL predicate to filter the SQL from AWR.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from AWR.
  --                               Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL.
  --     result_percentage  (IN) - a percentage on the sum of a rank measure.
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure.         
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --     recursive_sql       (IN) - filter out the recursive SQL 
  --                                if NO_RECURSIVE_SQL
  --     dbid                (IN) - dbid for imported or PDB-level AWR data
  --                                If NULL then the current dbid is used.
  --
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_workload_repository(
    begin_snap        IN NUMBER,
    end_snap          IN NUMBER,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL,
    dbid              IN NUMBER   := NULL)
  RETURN sys.sqlset PIPELINED;    
  
  -------------------------- select_workload_repository -----------------------
  FUNCTION select_workload_repository(
    baseline_name     IN VARCHAR2,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL,
    dbid              IN NUMBER   := NULL)
  RETURN sys.sqlset PIPELINED;        

  ------------------------------ select_sql_trace -----------------------------
  -- NAME: 
  --     select_sql_trace
  --
  -- DESCRIPTION:
  --     This table function reads the content of one or more trace 
  --     files and returns the sql statements it finds in the format
  --     of sqlset_row.
  --
  -- PARAMETERS:
  --     directory     (IN) - directory/location/path of the trace file(s).
  --                          This field is mandatory.
  --     file_name     (IN) - all or part of name of the trace file(s) 
  --                          to process. If NULL then the current or most 
  --                          recent file in the specified localtion/path 
  --                          will be used. '%' wildcards are supported for
  --                          matching trace file names.
  --     mapping_table_name       
  --                   (IN) - the mapping table name. Note that
  --                          the mapping table name is case insensitive.
  --                          If the mapping table name is NULL, the mappings
  --                          in the current database will be used.
  --     mapping_table_owner
  --                   (IN) - the mapping table owner. If it is NULL, the
  --                          current user will be used.
  --     select_mode   (IN) - It is the mode for selecting sqls from the trace.
  --                          SINGLE_EXECUTION: return one execution of a SQL.
  --                                            It is the default.
  --                          ALL_EXECUTIONS: return all executions.
  --
  --     options       (IN) - the options. 
  --                          LIMITED_COMMAND_TYPE: we only return the sqls
  --                          with the command types: CREATE, INSERT, SELECT,
  --                          UPDATE, DELETE, UPSERT. It is the default.
  --                          ALL_COMMAND_TYPE: return the sqls with all
  --                          command type.
  --     pattern_start (IN) - opening delimiting pattern of the trace file
  --                          section(s) to consider. NOT USED FOR NOW.
  --     pattern_end   (IN) - closing delimiting pattern of the trace file 
  --                          section(s) to process. NOT USED FOR NOW.
  --     result_limit  (IN) - top SQL from the (filtered) source. Default 
  --                          to MAXSB4 if NULL; 
  --
  -- return:
  --     This function returns a sqlset_row object.
  --
  ------------------------------------------------------------------------
  -- EXAMPLE: LOAD SQLs from SQL TRACE INTO STS and convert it into trial
  ------------------------------------------------------------------------
  --  /* turn on the SQL trace in the capture database */
  --  alter session set events '10046 trace name context forever, level 4'
  --
  --  /* create mapping table from the capture database */
  --  create table mapping as 
  --    select  object_id id, owner, substr(object_name, 1, 30) name 
  --    from  dba_objects 
  --    where object_type NOT IN ('CONSUMER GROUP', 'EVALUATION CONTEXT',
  --                              'FUNCTION', 'INDEXTYPE', 'JAVA CLASS',
  --                              'JAVA DATA', 'JAVA RESOURCE', 'LIBRARY',
  --                              'LOB', 'OPERATOR', 'PACKAGE',
  --                              'PACKAGE BODY', 'PROCEDURE', 'QUEUE',
  --                              'RESOURCE PLAN', 'TRIGGER', 'TYPE',
  --                              'TYPE BODY', 'SYNONYM') 
  --    union all 
  --    select  user_id id, username owner, null name 
  --    from  dba_users;
  --
  --  /* create the STS on the database running the SPA */
  --  dbms_sqlset.create_sqlset('my_sts', 'test purpose');
  --
  --  /* load the sqls into STS from SQL TRACE */
  --  DECLARE
  --     cur sys_refcursor;
  --  BEGIN
  --     OPEN cur for
  --       select value(p) 
  --         from TABLE(
  --            dbms_sqlset.select_sql_trace(
  --                    directory=>'SQL_TRACE_DIR', 
  --                    file_name=>'%trc',
  --                    mapping_table_name=>'mapping')) p;
  --    dbms_sqlset.load_sqlset('my_sts', cur);
  --  END;
  --  /
  --
  --  /* create a trial from the STS */
  --  var aname varchar2(30)
  --  exec :aname := dbms_sqlpa.create_analysis_task(
  --                                  sqlset_name => 'my_sts');
  --  exec dbms_sqlpa.execute_analysis_task(task_name =>:aname,
  --                                  execution_type => 'convert sqlset');
  -----------------------------------------------------------------------------
  FUNCTION select_sql_trace( 
    directory              IN VARCHAR2,
    file_name              IN VARCHAR2 := NULL,
    mapping_table_name     IN VARCHAR2 := NULL,
    mapping_table_owner    IN VARCHAR2 := NULL,
    select_mode            IN POSITIVE := SINGLE_EXECUTION,
    options                IN BINARY_INTEGER := LIMITED_COMMAND_TYPE,
    pattern_start          IN VARCHAR2 := NULL,
    pattern_end            IN VARCHAR2 := NULL,
    result_limit           IN POSITIVE := NULL)
  RETURN sys.sqlset PIPELINED;

  ----------------------------- select_sqlpa_task -----------------------------
  -- NAME: 
  --     select_sqlpa_task
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     a SQL performance analyzer task.  One example usage is for creating
  --     a SQL Tuning Set containing the subset of SQL statements that
  --     regressed during a SQL Performance Analyzer (SPA) experiment.
  --     Other arbitrary filters can also be specified.
  --
  -- PARAMETERS:
  --     task_name          (IN) - name of the SQL Performance Analyzer task
  --     task_owner         (IN) - owner of the SQL Performance Analyzer task.
  --                               If NULL, then assume the current user.
  --     execution_name     (IN) - name of the SQL Performance Analyzer task
  --                               execution (type COMPARE PERFORMANCE) from
  --                               which the change_filter will be applied.
  --                               If NULL, then assume the most recent
  --                               COMPARE PERFORMANCE execution.
  --     level_filter       (IN) - filter to specify which subset of SQLs
  --                               to include.  Same format as DBMS_SQLPA. 
  --                                 REPORT_ANALYSIS_TASK.LEVEL, with some
  --                                 possible strings removed.
  --                               IMPROVED        - improved SQL
  --                               REGRESSED (default) - regressed SQL
  --                               CHANGED         - SQL w/ changed perf
  --                               UNCHANGED       - SQL w/ unchanged perf
  --                               CHANGED_PLANS   - SQL w/ plan changes
  --                               UNCHANGED_PLANS - SQL w/ unchanged plans
  --                               ERRORS          - SQL with errors only
  --                               MISSING_SQL     - Missing SQLs (Across STS)
  --                               NEW_SQL         - New SQLs (Across STS)
  --     basic_filter       (IN) - SQL predicate to filter the SQL in
  --                               addition to the filters above.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from the
  --                               cursor cache.  Currently not supported.
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_sqlpa_task(
    task_name         IN VARCHAR2,
    task_owner        IN VARCHAR2 := NULL,
    execution_name    IN VARCHAR2 := NULL,
    level_filter      IN VARCHAR2 := 'REGRESSED',
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL')
  RETURN sys.sqlset PIPELINED;

  -----------------------------------------------------------------------------
  --          Pack / Unpack SQL tuning set procedures and functions          --
  --                                                                         --
  -- SQL tuning sets can be moved ("packed") from their location on a system --
  -- into an opaque table in any user schema.  You can then move that table  --
  -- to another system using the method of your choice (expdp/impdp,         --
  -- database link, etc), and then import them into the SQL tuning set       --
  -- schema on the new system ("unpack").                                    --
  --                                                                         --
  -----------------------------------------------------------------------------
  ---------------------------------
  -- EXAMPLE: PACK/UNPACK TWO STS --
  ---------------------------------
  --   /* Create a staging table to move to */                             
  --   dbms_sqlset.create_stgtab(table_name => 'STAGING_TABLE'); 
  --                                                                         
  --   /* Put two STS in the staging table */                                
  --   dbms_sqlset.pack_stgtab(sqlset_name => 'my_sts',     
  --                           staging_table_name => 'STAGING_TABLE');
  --   dbms_sqlset.pack_stgtab(sqlset_name => 'full_app_workload',
  --                           staging_table_name => 'STAGING_TABLE');
  --                                                                         
  --   /* transport STS_STAGING_TABLE to foreign system */                   
  --   ...
  --
  --   /* On new system, unpack both from staging table */
  --   dbms_sqlset.unpack_stgtab(sqlset_name => '%',
  --                             replace => TRUE,
  --                             staging_table_name => 'STAGING_TABLE');
  --
  -----------------------------------------------------------------------------

  ---------------------------------- create_stgtab ----------------------------
  -- NAME: 
  --     create_stgtab
  --
  -- DESCRIPTION:
  --     This procedure creates a staging table to be used by the pack
  --     procedure.  Call it once before issuing a pack call.  It can
  --     be called on multiple schemas if you would like to have different
  --     tuning sets in different staging tables.
  --
  --     Note that this is a DDL operation, so it does not occur within a
  --     transaction.  Users issuing the call must have permission to create
  --     a table in the schema provided.
  --
  -- PARAMETERS:
  --     table_name          (IN)   - name of table to create (case-sensitive)
  --     schema_name         (IN    - user schema to create table within, or
  --                                  NULL for current schema owner
  --                                  (case-sensitive)
  --     tablespace_name     (IN)   - tablespace to store the staging table in,
  --                                  or NULL for schema's default tablespace
  --                                  (case-sensitive)
  --     db_version          (IN)   - database version to decide the format of
  --                                  the staging table. It is possible to 
  --                                  create an older DB version staging table
  --                                  so that an STS can be exported to an 
  --                                  older DB version. 
  --                                  It can take one of the following values:
  --                                  NULL (default)          : current DB 
  --                                                            version
  --                                  STS_STGTAB_10_2_VERSION : 10.2 DB version
  --                                  STS_STGTAB_11_1_VERSION : 11.1 DB version
  --                                  STS_STGTAB_11_2_VERSION : 11.2 DB version
  -----------------------------------------------------------------------------
  PROCEDURE create_stgtab(
    table_name           IN VARCHAR2,
    schema_name          IN VARCHAR2 := NULL,                             
    tablespace_name      IN VARCHAR2 := NULL,
    db_version           IN NUMBER   := NULL);

  -------------------------------- pack_stgtab --------------------------------
  -- NAME: 
  --     pack_stgtab
  --
  -- DESCRIPTION:
  --     This function moves one or more STS from their location in the SYS
  --     schema to a staging table created by the create_stgtab function.
  --     It can be called several times to move more than one STS.  Users can
  --     then move the populated staging table to another system using any
  --     method of their choice, such as database link or datapump (expdp/
  --     impdp functions).  Users can then call unpack_stgtab to create the
  --     STS on the other system.
  --
  --     Note that this fct commits after packing each STS, so if it raises
  --     an error mid-execution, some STS may already be in the staging table.
  --
  -- PARAMETERS:
  --     sqlset_name          (IN)  - name of STS to pack (not NULL). 
  --                                  Wildcard characters ('%') are supported 
  --                                  to move multiple STS in a single call.
  --     sqlset_owner         (IN)  - name of STS owner, or NULL for current
  --                                  schema owner. Wildcard characters ('%') 
  --                                  are supported to pack STS from multiple
  --                                  owners in one call.
  --     staging_table_name   (IN)  - name of staging table, created by
  --                                  create_stgtab (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  --     db_version           (IN)  - database version to decide the format of
  --                                  the staging table. It is possible to 
  --                                  pack an STS to an older DB version 
  --                                  staging table so that it can be exported
  --                                  to an that version. 
  --                                  It can take one of the following values:
  --                                  NULL (default)          : current DB 
  --                                                            version
  --                                  STS_STGTAB_10_2_VERSION : 10.2 DB version
  --                                  STS_STGTAB_11_1_VERSION : 11.1 DB version
  --                                  STS_STGTAB_11_2_VERSION : 11.2 DB version
  -----------------------------------------------------------------------------
  PROCEDURE pack_stgtab(
    sqlset_name          IN VARCHAR2,
    sqlset_owner         IN VARCHAR2 := NULL,
    staging_table_name   IN VARCHAR2,
    staging_schema_owner IN VARCHAR2 := NULL,
    db_version           IN NUMBER   := NULL);
  
  ------------------------------ unpack_stgtab --------------------------------
  -- NAME: 
  --     unpack_stgtab
  --
  -- DESCRIPTION:
  --     Moves one or more STS from the staging table, as populated by a call
  --     to pack_stgtab and moved by the user, into the STS schema, making them
  --     proper STS. Users can drop the staging table after this procedure 
  --     completes successfully.
  --
  --     The unpack procedure commits after successfully loading each STS.  If
  --     it fails with one, no part of that STS will have been unpacked, but
  --     those which it saw previously will exist.  When failures occur due to
  --     sts name or owner conflicts, users should use the remap_stgtab
  --     function to patch the staging table, and then call this procedure 
  --     again to unpack those STS that remain.
  --
  -- PARAMETERS:
  --     sqlset_name          (IN)  - name of STS to unpack (not NULL). 
  --                                  Wildcard characters ('%') are supported 
  --                                  to unpack multiple STS in a single call.
  --                                  for example, just specify '%' to unpack
  --                                  all STS from the staging table.
  --     sqlset_owner         (IN)  - name of STS owner, or NULL for current
  --                                  schema owner.  Wildcards supported
  --     replace              (IN)  - replace STS if they already exist.
  --                                  If FALSE, function errors when trying to
  --                                  unpack an existing STS
  --     staging_table_name   (IN)  - name of staging table, moved after a call
  --                                  to pack_stgtab (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  -----------------------------------------------------------------------------
  PROCEDURE unpack_stgtab(
    sqlset_name          IN VARCHAR2 := '%',
    sqlset_owner         IN VARCHAR2 := NULL,
    replace              IN BOOLEAN,
    staging_table_name   IN VARCHAR2,
    staging_schema_owner IN VARCHAR2 := NULL);

  ---------------------------------- remap_stgtab -----------------------------
  -- NAME: 
  --     remap_stgtab
  --
  -- DESCRIPTION:
  --     Changes the sqlset names and owners in the staging table so that they
  --     can be unpacked with different values than they had on the host 
  --     system.
  --     Users should first check to see if the names they are changing to will
  --     conflict first -- this function does not enforce that constraint.
  --
  --     Users can call this procedure multiple times to remap more than one
  --     STS name/owner.  Note that this procedure only handles one STS per
  --     call.
  --
  -- PARAMETERS:
  --     old_sqlset_name      (IN)  - name of STS to target for a name/owner
  --                                  remap. Wildcards are NOT supported.
  --     old_sqlset_owner     (IN)  - name of STS owner to target for a
  --                                  remap.  NULL for current schema owner.
  --     new_sqlset_name      (IN)  - new name for STS. NULL to keep the same
  --                                  name.
  --     new_sqlset_owner     (IN)  - new owner name for STS.  NULL to keep the
  --                                  same owner name.
  --     staging_table_name   (IN)  - name of staging table (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  --     old_con_dbid         (IN)  - old container db id to target for a
  --                                  remap. NULL to keep the same.
  --     new_con_dbid        (IN)  -  new container db id to replace with. 
  --                                  NULL to keep the same.
  -----------------------------------------------------------------------------
  PROCEDURE remap_stgtab(
    old_sqlset_name        IN VARCHAR2,
    old_sqlset_owner       IN VARCHAR2 := NULL,
    new_sqlset_name        IN VARCHAR2 := NULL,
    new_sqlset_owner       IN VARCHAR2 := NULL,
    staging_table_name     IN VARCHAR2,
    staging_schema_owner   IN VARCHAR2 := NULL,
    old_con_dbid           IN NUMBER   := NULL,
    new_con_dbid           IN NUMBER   := NULL);

END dbms_sqlset;
/
show errors;

------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_sqlset FOR dbms_sqlset
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the public role           --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_sqlset TO public
/
show errors;

@?/rdbms/admin/sqlsessend.sql
 
