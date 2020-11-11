Rem
Rem $Header: rdbms/admin/dbmsspm.sql /main/21 2016/05/16 09:49:54 aarvanit Exp $
Rem
Rem dbmsspm.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsspm.sql - SQL Plan Management package specification
Rem
Rem    DESCRIPTION
Rem      Specifications of DBMS_SPM package interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsspm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsspm.sql
Rem SQL_PHASE: DBMSSPM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ddas        05/06/16 - #(23225370) correct comments for configure()
Rem    aarvanit    04/21/16 - bug #22271179: add dbid in load_plans_from_awr
Rem    jftorres    08/13/15 - lrg 17739327: update pack_stgtab documentation to
Rem                           reflect allowed origin values
Rem    jftorres    05/26/15 - proj 45826: merge configure procedures, add 
Rem                           alternate plan limit to evolve
Rem    jftorres    02/17/14 - proj 45826: add overloaded configure to handle
Rem                           SQL autocapture filters, load_plans_from_awr
Rem    mziauddi    01/21/15 - Long identifiers support
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    ddas        08/22/11 - SPM Evolve Advisor
Rem    yzhu        05/11/09 - add drop_migrated_stored_outline
Rem    yzhu        11/12/08 - add migrate_stored_outline (outline list format)
Rem    yzhu        01/14/08 - add migrate_stored_outline()
Rem    mziauddi    05/22/07 - #(6054748) Use MAXINT and MAXINT-1 to represent
Rem                           NO_LIMIT and AUTO_LIMIT
Rem    mziauddi    03/28/07 - #(5960851) add load_plans_from_cursor_cache with
Rem                           attribute_name, attribute_value representing
Rem                           selection of plans for multiple statements
Rem    hosu        04/03/07 - update comments
Rem    hosu        03/05/07 - move some functions to dbms_spm_internal; change
Rem                           execution privilege of dbms_spm 
Rem    mziauddi    01/31/07 - add evolve_sql_plan_baseline()
Rem    ddas        01/29/07 - purge_sql_plan_baseline -> drop_sql_plan_baseline
Rem    mziauddi    11/29/06 - correct handling of sql_handle, plan_name in
Rem                           alter_* and drop_* functions
Rem    hosu        11/07/06 - change comments for create/pack/unpack staging
Rem                           table
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    mziauddi    09/14/06 - remove EXPLAIN_PLAN_BASELINE
Rem    mziauddi    09/12/06 - remove administer_spm role
Rem    hosu        09/05/06 - structure filters for packing
Rem    mziauddi    08/18/06 - add enabled status to load_plans_from_*()
Rem                           functions
Rem    hosu        08/07/06 - import/export baselines
Rem    mziauddi    08/01/06 - change minimum plan_retention_weeks to 5 from 1
Rem    hosu        07/26/06 - add auto_purge_sql_plan_baseline
Rem    mziauddi    07/19/06 - remove load_plans_of_stored_outlines 
Rem    mziauddi    07/10/06 - add load_plans_from_cursor_cache() without 
Rem                           sql_text/sql_handle parameter 
Rem    mziauddi    07/05/06 - overload load_plans_from_cursor_cache() to 
Rem                           accept either sql_handle or sql_text 
Rem    mziauddi    06/22/06 - add drop_sql_plan_baseline function 
Rem    mziauddi    06/13/06 - change set_plan_status to
Rem                           alter_sql_plan_baseline 
Rem    mziauddi    04/10/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
-- Library where 3GL callouts will reside
-------------------------------------------------------------------------------
CREATE OR REPLACE LIBRARY dbms_spm_lib TRUSTED AS STATIC
/
show errors;
/

------------------------------------------------------------------------------
-- DBMS_SPM PACKAGE SPECIFICATION
------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_spm AUTHID CURRENT_USER AS

  -- -------------------------------------------------------------------------
  -- DBMS_SPM CONSTANTS SECTION
  -- -------------------------------------------------------------------------

  --
  -- Special values for time_limit parameter of evolve_sql_plan_baseline().
  --
  NO_LIMIT       CONSTANT INTEGER := 2147483647;
  AUTO_LIMIT     CONSTANT INTEGER := 2147483647 - 1;

  --
  -- List of names as an input parameter to evolve_sql_plan_baseline().
  --
  TYPE  name_list  IS TABLE OF dbms_id;

  -- -------------------------------------------------------------------------
  -- DBMS_SPM PUBLIC FUNCTIONS/PROCEDURES
  -- -------------------------------------------------------------------------

  -- -------------------------------------------------------------------------
  -- NAME:
  --   configure
  --
  -- DESCRIPTION:
  --   Set configuration options for the SQL Management Base (SMB) as well as
  --   the maintenance of SQL plan baselines.
  --
  -- PARAMETERS:
  --   parameter_name  - One of the following possible values:
  --                     'SPACE_BUDGET_PERCENT'
  --                     'PLAN_RETENTION_WEEKS'
  --                     'AUTO_CAPTURE_SQL_TEXT' 
  --                     'AUTO_CAPTURE_PARSING_SCHEMA_NAME'
  --                     'AUTO_CAPTURE_MODULE'
  --                     'AUTO_CAPTURE_ACTION'
  --                     
  --   parameter_value - One of the following possible values:
  --                     NULL, or a value within the range 1..50 when
  --                     parameter_name is 'SPACE_BUDGET_PERCENT'.
  --
  --                     NULL, or value within the range 5..523 when
  --                     parameter_name is 'PLAN_RETENTION_WEEKS'.
  --
  --                     see below when parameter_name is LIKE 'AUTO_CAPTURE%'
  --   
  --   allow           - For auto capture filters, controls whether values
  --                     matching the filter are allowed or disallowed.
  --                     Ignored for other parameter names.
  --          
  -- NOTES:
  --   When parameter_name is 'SPACE_BUDGET_PERCENT', parameter_value is the
  --   maximal percent of the SYSAUX tablespace which should be used to store
  --   SQL Management Objects. When the space usage exceeds this percentage,
  --   alerts will be generated. A NULL parameter_value resets the percentage 
  --   to the default value of 10%. The value of allow is ignored.
  -- 
  --   When parameter_name is 'PLAN_RETENTION_WEEKS', parameter_value is the
  --   number of weeks plans are retained after their most recent use. A NULL
  --   parameter_value resets to the default value of 53 weeks, or 1 year plus
  --   a week. (This retains plans for annually executing queries.) The value
  --   of allow is ignored.
  --
  -- 
  --   When parameter_name is LIKE 'AUTO_CAPTURE%', parameter_value is a text
  --   filter for SQL Plan Management auto-capture, applying the predicate
  --     {SQL text/parsing schema name/module/action} LIKE parameter_value
  --   when allow = TRUE or 
  --     NOT({SQL text/parsing schema name/module/action} LIKE parameter_value)
  --   when allow = FALSE.
  --
  --   Multiple filters are permitted for each filter type, and adding a new 
  --   filter will not override previous ones. If multiple allow = TRUE 
  --   filters are specified for a single filter type, only one must be 
  --   satisfied; all allow = FALSE filters must be satisfied.
  --
  --   If allow is NULL, and a filter (parameter_name, parameter_value) was 
  --   previously specified, that filter is removed. If parameter_value
  --   is NULL, all filters specified for parameter_name are removed.
  --  
  --   These filters are only used when optimizer_capture_sql_plan_baselines is
  --   set to TRUE.
  --
  --   A limited amount of storage is allocated for the filters. If there is 
  --   not enough room for a new filter, this procedure will throw ORA-38150.
  --
  -- EXAMPLES (for filters):
  --   configure('AUTO_CAPTURE_SQL_TEXT', 'select a%', 'TRUE')
  --   => sql_text like 'select a%'
  --
  --   configure('AUTO_CAPTURE_PARSING_SCHEMA_NAME', 'SCOTT', 'FALSE')
  --   => NOT(parsing_schema_name LIKE 'SCOTT')
  --
  --   configure('AUTO_CAPTURE_SQL_TEXT', NULL, NULL)
  --   => remove existing filters, if any, on SQL text
  --
  --   configure('AUTO_CAPTURE_SQL_TEXT', 'select a%', NULL);
  --   => remove (sql_text like 'select a%') or (sql_text not like 'select a%')
  --
  --   configure('AUTO_CAPTURE_ACTION', 'R%', 'TRUE');
  --   configure('AUTO_CAPTURE_ACTION', '%E_', 'TRUE');
  --   => (action LIKE 'R%') or (action LIKE '%E_')
  --
  --   configure('AUTO_CAPTURE_MODULE', 'LOGGER', 'FALSE');
  --   configure('AUTO_CAPTURE_MODULE', 'UTIL__', 'FALSE');
  --   => NOT(module LIKE 'LOGGER') and NOT(module LIKE 'UTIL__')
  --
  -- ERRORS:
  --   ORA-38133: Invalid parameter name
  --   ORA-38134: Invalid parameter value
  --   ORA-38151: Module name too long
  --   ORA-38152: Action name too long
  --   ORA-38304: missing or invalid user name
  --   ORA-38150: not enough space for new filter
  -- 
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------
  PROCEDURE configure( parameter_name    IN VARCHAR2,
                       parameter_value   IN VARCHAR2 := NULL,
                       allow             IN BOOLEAN  := TRUE
                     );

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_sqlset
  --
  -- DESCRIPTION:
  --   Load plans from SQL tuning set as SQL plan baselines.
  --   This function can be used to seed the SQL Management Base (SMB) with
  --   SQL plan baselines created for a set of SQL statements using the plans
  --   that are loaded from a SQL tuning set (STS).
  --   To load plans from a remote system, the user has to first create an STS
  --   with plan information on remote system, export/import the STS from
  --   remote to local system, and then use this function.
  --   To load plans from Automatic Workload Repository (AWR), the user has to
  --   first create an STS using plan information stored in AWR snapshots, and
  --   then use this function.
  --   Upgrade to 11g is an interesting use case of this function. The user
  --   can capture pre-upgrade plans for a set of SQL statements into an STS,
  --   and then use this function to load the plans into SQL plan baselines.
  --
  -- PARAMETERS:
  --   sqlset_name    - Name of the STS from where to load the plans from.
  --   sqlset_owner   - Owner of STS. NULL means current schema is the owner.
  --   basic_filter   - A textual representation of a filter expression to be
  --                    applied to select only the qualifying plans from STS.
  --                    NULL means all plans in STS are selected.
  --   fixed          - Default 'NO' means the loaded plans will not change
  --                    the current 'fixed' property of the SQL plan baseline
  --                    into which they are loaded.
  --   enabled        - Default 'YES' means the loaded plans will be 
  --                    considered by the optimizer.
  --   commit_rows    - Number of SQL plans to load before doing a periodic
  --                    commit. This helps to shorten the undo log.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION load_plans_from_sqlset( sqlset_name        IN VARCHAR2,
                                   sqlset_owner       IN VARCHAR2 := NULL,
                                   basic_filter       IN VARCHAR2 := NULL,
                                   fixed              IN VARCHAR2 := 'NO',
                                   enabled            IN VARCHAR2 := 'YES',
                                   commit_rows        IN NUMBER   := 1000
                                 )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_cursor_cache (multiple statements form)
  --
  -- DESCRIPTION:
  --   Load plans from cursor cache as SQL plan baselines.
  --   This function can be used to load one or more plans present in the
  --   cursor cache for one or more SQL statements based on a plan selection
  --   criterion represented by argument pair attribute_name/attribute_value.
  --   The plans are selected from cursor cache based on the values specified
  --   for attribute_name and attribute_value.
  --
  -- PARAMETERS:
  --   attribute_name   - One of the following possible attribute names:
  --                      'SQL_TEXT',
  --                      'PARSING_SCHEMA_NAME',
  --                      'MODULE',
  --                      'ACTION'
  --   attribute_value  - The attribute value is used as a search pattern of
  --                      LIKE predicate if attribute name is 'SQL_TEXT'.
  --                      Otherwise, it is used as an equality search value.
  --                        (e.g. specifying attribute_name=>'SQL_TEXT', and
  --                        attribute_value=>'% HR-123 %' means applying
  --                        SQL_TEXT LIKE '% HR-123 %' as a selection filter.
  --                        Similarly, specifying attribute_name=>'MODULE',
  --                        and attribute_value=>'HR' means applying
  --                        MODULE = 'HR' as a plan selection filter).
  --                      The attribute value is upper-cased except when it
  --                      is enclosed in double quotes or attribute name is
  --                      'SQL_TEXT'.
  --   fixed            - Default 'NO' means the loaded plans will not change
  --                      the current 'fixed' property of SQL plan baseline
  --                      into which they are loaded.
  --   enabled          - Default 'YES' means the loaded plans will be 
  --                      considered by the optimizer.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- --------------------------------------------------------------------------

  FUNCTION load_plans_from_cursor_cache( attribute_name   IN VARCHAR2,
                                         attribute_value  IN VARCHAR2,
                                         fixed            IN VARCHAR2 := 'NO',
                                         enabled          IN VARCHAR2 := 'YES'
                                       )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_cursor_cache (single statement form)
  --
  -- DESCRIPTION:
  --   Load plans from cursor cache as SQL plan baselines.
  --   This function can be used to load one or more plans present in the
  --   cursor cache for a single SQL statement.
  --
  -- PARAMETERS:
  --   sql_id           - SQL statement identifier, which is used to identify
  --                      the plans in the cursor cache, and the SQL signature
  --                      associated to it is used to identify the SQL plan
  --                      baseline into which the plans are loaded. If the
  --                      SQL plan baseline doesn't exist it is created.
  --   plan_hash_value  - Plan identifier. Default NULL means load all plans
  --                      present in the cursor cache for given SQL statement.
  --   fixed            - Default 'NO' means the loaded plans will not change
  --                      the current 'fixed' property of SQL plan baseline
  --                      into which they are loaded.
  --   enabled          - Default 'YES' means the loaded plans will be 
  --                      considered by the optimizer.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- --------------------------------------------------------------------------

  FUNCTION load_plans_from_cursor_cache( sql_id           IN VARCHAR2,
                                         plan_hash_value  IN NUMBER := NULL,
                                         fixed            IN VARCHAR2 := 'NO',
                                         enabled          IN VARCHAR2 := 'YES'
                                       )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_cursor_cache (single statement, sql text form)
  --
  -- DESCRIPTION:
  --   Load plans from cursor cache as SQL plan baselines.
  --   This function can be used to load one or more plans present in the
  --   cursor cache for a single SQL statement.
  --
  -- PARAMETERS:
  --   sql_id           - SQL statement identifier, which is used to identify
  --                      the plans in the cursor cache.
  --   plan_hash_value  - Plan identifier. Default NULL means load all plans
  --                      present in the cursor cache for given SQL statement.
  --   sql_text         - SQL text to use in identifying the SQL plan baseline
  --                      into which the plans are loaded. If the SQL plan
  --                      baseline does not exist, it is created. The use of
  --                      SQL text is crucial when the user tunes a statement
  --                      possibly by adding hints to it and then wants to load
  --                      the resulting plan(s) into SQL plan baseline of the
  --                      original SQL statement.
  --   fixed            - Default 'NO' means the loaded plans will not change
  --                      the current 'fixed' property of SQL plan baseline
  --                      into which they are loaded.
  --   enabled          - Default 'YES' means the loaded plans will be 
  --                      considered by the optimizer.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- --------------------------------------------------------------------------

  FUNCTION load_plans_from_cursor_cache( sql_id           IN VARCHAR2,
                                         plan_hash_value  IN NUMBER := NULL,
                                         sql_text         IN CLOB,
                                         fixed            IN VARCHAR2 := 'NO',
                                         enabled          IN VARCHAR2 := 'YES'
                                       )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_cursor_cache (single statement, sql handle form)
  --
  -- DESCRIPTION:
  --   Load plans from cursor cache as SQL plan baselines.
  --   This function can be used to load one or more plans present in the
  --   cursor cache for a single SQL statement.
  --
  -- PARAMETERS:
  --   sql_id           - SQL statement identifier, which is used to identify
  --                      the plans in the cursor cache.
  --   plan_hash_value  - Plan identifier. Default NULL means load all plans
  --                      present in the cursor cache for given SQL statement.
  --   sql_handle       - SQL handle to use in identifying the plan baseline
  --                      into which the plans are loaded. The sql handle must
  --                      denote an existing SQL plan baseline. The use of sql
  --                      handle is crucial when the user tunes a SQL statement
  --                      possibly by adding hints to it and then wants to load
  --                      the resulting plan(s) into the SQL plan baseline of
  --                      original SQL statement.
  --   fixed            - Default 'NO' means the loaded plans will not change
  --                      the current 'fixed' property of SQL plan baseline
  --                      into which they are loaded.
  --   enabled          - Default 'YES' means the loaded plans will be 
  --                      considered by the optimizer.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- --------------------------------------------------------------------------

  FUNCTION load_plans_from_cursor_cache( sql_id           IN VARCHAR2,
                                         plan_hash_value  IN NUMBER := NULL,
                                         sql_handle       IN VARCHAR2,
                                         fixed            IN VARCHAR2 := 'NO',
                                         enabled          IN VARCHAR2 := 'YES'
                                       )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   load_plans_from_awr
  --
  -- DESCRIPTION:
  --   Load plans from AWR as SQL plan baselines.
  --   This function can be used to load the SQL Management Base (SMB) with
  --   SQL plan baselines for a set of SQL statements using the plans
  --   from the AWR.
  --
  -- PARAMETERS:
  --   begin_snap   - begin snapshot
  --   end_snap     - end snapshot
  --   basic_filter - SQL predicate to filter the SQL from AWR.
  --                  NULL means all plans in AWR are selected.
  --   fixed        - Default 'NO' means the loaded plans will not change
  --                  the current 'fixed' property of the SQL plan baseline
  --                  into which they are loaded. If 'YES', the property will
  --                  be set to 'YES'.
  --   enabled -      Default 'YES' means the loaded plans will be
  --                  considered by the optimizer.
  --   commit_rows  - Number of SQL plans to load before doing a periodic
  --                  commit. This helps to shorten the undo log.
  --   dbid         - dbid used for imported or PDB-level AWR data. 
  --                  If NULL then the current database dbid is used.
  --
  -- RETURN:
  --   Number of plans loaded.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION load_plans_from_awr( begin_snap   IN NUMBER,
                                end_snap     IN NUMBER,
                                basic_filter IN VARCHAR2 := NULL,
                                fixed        IN VARCHAR2 := 'NO',
                                enabled      IN VARCHAR2 := 'YES',
                                commit_rows  IN NUMBER   := 1000,
                                dbid         IN NUMBER   := NULL)
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   alter_sql_plan_baseline
  --
  -- DESCRIPTION:
  --   This function can be used to change the status/name/description of a
  --   single plan, or status/description of all plans of a SQL statement
  --   using the attribute name/value format. The function can be called
  --   numerous times, each time altering a different attribute of same plan
  --   or different plans of a sql statement.
  --
  -- PARAMETERS:
  --   sql_handle       - SQL statement handle. It identifies plans associated
  --                      with a SQL statement that are to be altered. If NULL
  --                      then plan name must be specified.
  --   plan_name        - Unique plan name. It identifies a specific plan.
  --                      Default NULL means alter all plans associated with
  --                      the SQL statement identified by sql_handle. If NULL
  --                      then sql handle must be specified.
  --   attribute_name   - One of the following possible attribute names:
  --                      'ENABLED',
  --                      'FIXED',
  --                      'AUTOPURGE',
  --                      'PLAN_NAME',
  --                      'DESCRIPTION'
  --   attribute_value  - If the attribute name denotes a plan status then
  --                      the legal values are: 'YES', 'NO'.
  --                      If the attribute name denotes a plan name then the
  --                      supplied value should not conflict with already
  --                      stored plan name.
  --                      If the attribute name denotes plan description then
  --                      any character string is allowed.
  --
  -- RETURN:
  --   Number of plans altered.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION alter_sql_plan_baseline( sql_handle         IN VARCHAR2 := NULL,
                                    plan_name          IN VARCHAR2 := NULL,
                                    attribute_name     IN VARCHAR2,
                                    attribute_value    IN VARCHAR2
                                  )
  RETURN PLS_INTEGER;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   drop_sql_plan_baseline
  --
  -- DESCRIPTION:
  --   This function can be used to drop a single plan, or all plans of a
  --   SQL statement.
  --
  -- PARAMETERS:
  --   sql_handle       - SQL statement handle. It identifies plans associated
  --                      with a SQL statement that are to be dropped. If NULL
  --                      then plan_name must be specified.
  --   plan_name        - Unique plan name. It identifies a specific plan.
  --                      Default NULL means drop all plans associated with
  --                      the SQL statement identified by sql_handle. If NULL
  --                      then sql handle must be specified.
  --
  -- RETURN:
  --   Number of plans dropped.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION drop_sql_plan_baseline( sql_handle         IN VARCHAR2 := NULL,
                                   plan_name          IN VARCHAR2 := NULL
                                 )
  RETURN PLS_INTEGER;


  -- -------------------------------------------------------------------------
  -- NAME:
  --   evolve_sql_plan_baseline
  --
  -- DESCRIPTION:
  --   This function can be used to evolve SQL plan baselines associated with
  --   one or more SQL statements. A SQL plan baseline is evolved when one or
  --   more of its non-accepted plans are changed to accepted plans. If asked
  --   by the user (i.e. parameter verify = 'YES'), the execution performance
  --   of each non-accepted plan is compared against the performance of a plan
  --   chosen from the associated SQL plan baseline. If the non-accepted plan
  --   performance is found to be better than SQL plan baseline performance
  --   then non-accepted plan is changed to an accepted plan, provided such
  --   action is permitted by the user (i.e. parameter commit = 'YES').
  --
  -- PARAMETERS:
  --   sql_handle     - SQL statement identifier. Unless plan_name specified,
  --                    NULL means consider all statements with non-accepted
  --                    plans in their SQL plan baselines.
  --   plan_name      - Plan identifier. Default NULL means consider all non-
  --                    accepted plans in the SQL plan baseline of either the
  --                    identified SQL statement or all SQL statements if
  --                    sql_handle is NULL.
  --   time_limit     - Time limit in number of minutes. This applies only if
  --                    verify = 'YES' (see next parameter). The time limit
  --                    is global and it is used in the following manner. The
  --                    time limit for first non-accepted plan verification
  --                    is set equal to the input value. The time limit for
  --                    second non-accepted plan verification is set equal to
  --                    (input value - time spent in first plan verification)
  --                    and so on. The default DBMS_SPM.AUTO_LIMIT means let
  --                    the system choose an appropriate time limit based on
  --                    the number of plan verifications required to be done.
  --                    The value DBMS_SPM.NO_LIMIT means no time limit.
  --                    A positive integer value represents a user specified
  --                    time limit.
  --   verify         - Whether to actually execute the plans and compare the
  --                    performance before changing non-accepted plans into
  --                    accepted plans. A performance verification involves
  --                    executing a non-accepted plan and a plan chosen from
  --                    corresponding SQL plan baseline and comparing their
  --                    performance statistics. If non-accepted plan shows
  --                    performance improvement, it is changed to an accepted
  --                    plan. Default 'YES' means verify that a non-accepted
  --                    plan gives better performance before changing it to
  --                    an accepted plan. And 'NO' means do not execute plans
  --                    but simply change non-accepted plans into accepted
  --                    plans.
  --   commit         - Whether to update the ACCEPTED status of non-accepted
  --                    plans from 'NO' to 'YES'. Default 'YES' means perform
  --                    updates of qualifying non-accepted plans and generate
  --                    a report that shows the updates and the result of
  --                    performance verification when verify = 'YES'. And
  --                    'NO' means generate a report without any updates.
  --                    Note that commit = 'NO' and verify = 'NO' represents
  --                    a no-op.
  --   alternate_plan_limit -
  --                    The maximum number of plans to load from alternate
  --                    sources during the evolve process. Defaults to 0.
  -- RETURN:
  --     A CLOB containing a formatted text report showing non-accepted plans
  --     in sequence, each with a possible change of its ACCEPTED status, and
  --     if verify = 'YES' the result of their performance verification.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION evolve_sql_plan_baseline(
                             sql_handle   IN VARCHAR2 := NULL,
                             plan_name    IN VARCHAR2 := NULL,
                             time_limit   IN INTEGER  := DBMS_SPM.AUTO_LIMIT,
                             verify       IN VARCHAR2 := 'YES',
                             commit       IN VARCHAR2 := 'YES',
                             alternate_plan_limit IN NUMBER   := 0
                                   )
  RETURN CLOB;


  -- -------------------------------------------------------------------------
  -- NAME:
  --   evolve_sql_plan_baseline (plan list format)
  --
  -- DESCRIPTION:
  --   This function can be used to evolve SQL plan baselines associated with
  --   one or more SQL statements. A SQL plan baseline is evolved when one or
  --   more of its non-accepted plans are changed to accepted plans. If asked
  --   by the user (i.e. parameter verify = 'YES'), the execution performance
  --   of each non-accepted plan is compared against the performance of a plan
  --   chosen from the associated SQL plan baseline. If the non-accepted plan
  --   performance is found to be better than SQL plan baseline performance
  --   then non-accepted plan is changed to an accepted plan, provided such
  --   action is permitted by the user (i.e. parameter commit = 'YES').
  --
  -- PARAMETERS:
  --   plan_list      - A list of plan names. Each plan in the list can belong
  --                    to same or different SQL statement.
  --   time_limit     - Time limit in number of minutes. This applies only if
  --                    verify = 'YES' (see next parameter). The time limit
  --                    is global and it is used in the following manner. The
  --                    time limit for first non-accepted plan verification
  --                    is set equal to the input value. The time limit for
  --                    second non-accepted plan verification is set equal to
  --                    (input value - time spent in first plan verification)
  --                    and so on. The default DBMS_SPM.AUTO_LIMIT means let
  --                    the system choose an appropriate time limit based on
  --                    the number of plan verifications required to be done.
  --                    The value DBMS_SPM.NO_LIMIT means no time limit.
  --                    A positive integer value represents a user specified
  --                    time limit.
  --   verify         - Whether to actually execute the plans and compare the
  --                    performance before changing non-accepted plans into
  --                    accepted plans. A performance verification involves
  --                    executing a non-accepted plan and a plan chosen from
  --                    corresponding SQL plan baseline and comparing their
  --                    performance statistics. If non-accepted plan shows
  --                    performance improvement, it is changed to an accepted
  --                    plan. Default 'YES' means verify that a non-accepted
  --                    plan gives better performance before changing it to
  --                    an accepted plan. And 'NO' means do not execute plans
  --                    but simply change non-accepted plans into accepted
  --                    plans.
  --   commit         - Whether to update the ACCEPTED status of non-accepted
  --                    plans from 'NO' to 'YES'. Default 'YES' means perform
  --                    updates of qualifying non-accepted plans and generate
  --                    a report that shows the updates and the result of
  --                    performance verification when verify = 'YES'. And
  --                    'NO' means generate a report without any updates.
  --                    Note that commit = 'NO' and verify = 'NO' represents
  --                    a no-op.
  --
  -- RETURN:
  --     A CLOB containing a formatted text report showing non-accepted plans
  --     in sequence, each with a possible change of its ACCEPTED status, and
  --     if verify = 'YES' the result of their performance verification.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- -------------------------------------------------------------------------

  FUNCTION evolve_sql_plan_baseline(
                             plan_list    IN DBMS_SPM.NAME_LIST,
                             time_limit   IN INTEGER  := DBMS_SPM.AUTO_LIMIT,
                             verify       IN VARCHAR2 := 'YES',
                             commit       IN VARCHAR2 := 'YES'
                                   )
  RETURN CLOB;

  -- -------------------------------------------------------------------------
  --  NAME: 
  --     create_stgtab_baseline
  --
  --  DESCRIPTION:
  --    This procedure creates a staging table that will be used to pack
  --    (import) SQL plan baselines into it.
  --
  --  PARAMETERS:
  --    table_name       - Name of staging table.
  --    table_owner      - Name of schema owner of staging table.
  --                       Default NULL means current schema is the owner.
  --    tablespace_name  - Name of tablespace.
  --                       Default NULL means create staging table in the
  --                       default tablespace.
  --
  -- REQUIRE:
  --    1. 'CREATE TABLE' and 'ADMINISTER SQL MANAGEMENT OBJECT' privilege
  --    2. tablespace quota
  -- -------------------------------------------------------------------------

  PROCEDURE create_stgtab_baseline( table_name       IN VARCHAR2,
                                    table_owner      IN VARCHAR2 := NULL,
                                    tablespace_name  IN VARCHAR2 := NULL
                                  );


  -- -------------------------------------------------------------------------
  -- NAME: 
  --    pack_stgtab_baseline
  --
  -- DESCRIPTION:
  --    This function packs (exports) SQL plan baselines into a staging table.
  --
  -- PARAMETERS:
  --    table_name              - name of the staging table (case insensitive 
  --                              unless double quoted)
  --    table_owner             - name of the schema owner of staging table
  --                              (case insensitive unless double quoted)
  --    sql_handle              - sql handle (case sensitive)
  --    plan_name               - plan name (case sensitive, % wildcards OK)
  --    sql_text                - sql text (case sensitive, % wildcards OK)
  --    creator                 - creator of plan baseline (case insensitive
  --                              unless double quoted)
  --    origin                  - Origin of plan baseline. Can be one of the
  --                              origins in the dba_sql_plan_baselines.origin
  --                              column, 'MANUAL-LOAD' (which passes all
  --                              origins that begin with 'MANUAL-LOAD'), or
  --                              'EVOLVE-LOAD' (which passes all origins that
  --                              begin with 'EVOLVE-LOAD').
  --    enabled                 - should be either 'YES' or 'NO' (case
  --                              insensitive)
  --    accepted                - should be either 'YES' or 'NO' (case
  --                              insensitive)
  --    fixed                   - should be either 'YES' or 'NO' (case
  --                              insensitive)
  --    module                  - module (case sensitive)
  --    action                  - action (case sensitive)
  -- 
  -- RETURN:
  --   Number of plan baselines packed
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  -- 
  -- Note:
  --   We support predefined filters rather than user-defined filters. We do 
  --   not allow users to inject an arbitrary filter into the query.
  -- -------------------------------------------------------------------------

  FUNCTION pack_stgtab_baseline ( table_name            IN VARCHAR2,
                                  table_owner           IN VARCHAR2 := NULL,
                                  sql_handle            IN VARCHAR2 := NULL,
                                  plan_name             IN VARCHAR2 := '%',
                                  sql_text              IN CLOB     := '%',
                                  creator               IN VARCHAR2 := NULL,
                                  origin                IN VARCHAR2 := NULL, 
                                  enabled               IN VARCHAR2 := NULL, 
                                  accepted              IN VARCHAR2 := NULL, 
                                  fixed                 IN VARCHAR2 := NULL, 
                                  module                IN VARCHAR2 := NULL,
                                  action                IN VARCHAR2 := NULL
                                )
  RETURN NUMBER;


  -- -------------------------------------------------------------------------
  -- NAME:
  --   unpack_stgtab_baseline
  --
  -- DESCRIPTION:
  --   This function unpacks (imports) plan baselines from a staging table.
  --
  -- Parameters:
  --    table_name              - name of the staging table (case insensitive 
  --                              unless double quoted)
  --    table_owner             - name of the schema owner of staging table
  --                              (case insensitive unless double quoted)
  --    sql_handle              - sql handle (case sensitive)
  --    plan_name               - plan name (case sensitive, % wildcards OK)
  --    sql_text                - sql text (case sensitive, % wildcards OK)
  --    creator                 - creator of plan baseline (case insensitive
  --                              unless double quoted)
  --    origin                  - origin of plan baseline, should be 
  --                              'MANUAL-LOAD', 'AUTO-CAPTURE',
  --                              'MANUAL-SQLTUNE' or 'AUTO-SQLTUNE' (case
  --                              insensitive) 
  --    enabled                 - should be either 'YES' or 'NO' (case
  --                              insensitive) 
  --    accepted                - should be either 'YES' or 'NO' (case
  --                              insensitive) 
  --    fixed                   - should be either 'YES' or 'NO' (case
  --                              insensitive) 
  --    module                  - module (case sensitive)
  --    action                  - action (case sensitive)
  --
  -- RETURN:
  --   Number of plans unpacked
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  --
  -- Note:
  --   We support predefined filters rather than user-defined filters. We do 
  --   not allow users to inject an arbitrary filter into the query. 
  -- -------------------------------------------------------------------------

  FUNCTION unpack_stgtab_baseline ( table_name            IN VARCHAR2,
                                    table_owner           IN VARCHAR2 := NULL,
                                    sql_handle            IN VARCHAR2 := NULL,
                                    plan_name             IN VARCHAR2 := '%',
                                    sql_text              IN CLOB     := '%',
                                    creator               IN VARCHAR2 := NULL,
                                    origin                IN VARCHAR2 := NULL, 
                                    enabled               IN VARCHAR2 := NULL, 
                                    accepted              IN VARCHAR2 := NULL, 
                                    fixed                 IN VARCHAR2 := NULL, 
                                    module                IN VARCHAR2 := NULL,
                                    action                IN VARCHAR2 := NULL
                                  )
  RETURN NUMBER;


  -- -------------------------------------------------------------------------
  -- NAME:
  --   migrate_stored_outline
  --
  -- DESCRIPTION:
  --   This function can be used to migrate stored outlines for one or more 
  --   sql statements to sql plan baselines in SMB. 
  --
  -- PARAMETERS:
  --   attribute_name   - One of the following possible attribute names:
  --                      'OUTLINE_NAME',
  --                      'SQL_TEXT',
  --                      'CATEGORY',
  --                      'ALL'
  --   attribute_value  - The attribute value is used as an equality search 
  --                      value. The attribute value used as a search pattern 
  --                      of LIKE predicate is NOT supported, mainly because
  --                      sql_text of a stored outline is internally stored as
  --                      LONG instead of CLOB.
  --                      
  --                      (e.g., specifying attribute_name=>'CATEGORY',
  --                       and attribute_value=>'HR' means applying
  --                       CATEGORY = 'HR' as an outline selection filter. In 
  --                       this case all the outlines under the 'HR' category
  --                       will be migrated to SQL plan baselines).
  --
  --                       Similarly, specifying attribute_name=>'SQL_TEXT', 
  --                       and attribute_value=>'% HR-123 %' will result in 
  --                       applying SQL_TEXT = '% HR-123 %' as an outline
  --                       selection filter. The LIKE predicate will not be
  --                       applied in this case.
  --
  --                      attribute_value cannot be NULL if attribute_name is
  --                      set to 'OUTLINE_NAME', 'SQL_TEXT' or 'CATEGORY'. 
  --
  --                      attribute_value wrapped in single quotes will be
  --                      converted to upper case. e.g. specifying
  --                      attribute_name=>'outline_name' and 
  --                      attribute_value=>'ms01' will result in applying 
  --                      OUTLINE_NAME = 'MS01' as selection filter.
  --        
  --                      attribute_value wrapped in double quotes will retain
  --                      its upper and lower cases. The double quotes will be
  --                      stripped off before applying the attribute_value as
  --                      selection filter. e.g. specifying
  --                      attribute_name=>'outline_name' and 
  --                      attribute_value=>'"ms01"' will result in applying 
  --                      OUTLINE_NAME = 'ms01' as selection filter.
  --                      
  --   fixed            - Whether the new SQL plan baselines created as the 
  --                      results of migration should be fixed or not. A fixed 
  --                      SQL plan baseline has higher priority to be chosen
  --                      over other non-fixed plans for the same SQL 
  --                      statement. However, a SQL plan baseline containing a
  --                      fixed plan cannot be evolved. The default value is 
  --                      'NO'.
  -- RETURN:
  --   A CLOB containing a text summary report showing the number of successes 
  --   and number of failures during the stored outline migration. In case of
  --   failures, the report will also show the causes of failure. 
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  --   "ALTER ANY OUTLINE" privilege
  -- -------------------------------------------------------------------------
  FUNCTION migrate_stored_outline( attribute_name     IN VARCHAR2,
                                   attribute_value    IN CLOB     := NULL,
                                   fixed              IN VARCHAR2 := 'NO'
                                 )
  RETURN CLOB;

  -- -------------------------------------------------------------------------
  -- NAME:
  --   migrate_stored_outline (outline list format)
  --
  -- DESCRIPTION:
  --   This function can be used to migrate stored outlines to sql plan 
  --   baselines in SMB given one or more outline names. 
  --
  -- PARAMETERS:
  --   outln_list   - a list of stored outline names
  --
  --   fixed        - Whether the new SQL plan baselines created as the 
  --                  results of migration should be fixed or not. A fixed 
  --                  SQL plan baseline has higher priority to be chosen
  --                  over other non-fixed plans for the same SQL 
  --                  statement. However, a SQL plan baseline containing a 
  --                  fixed plan cannot be evolved. The default value is 'NO'.
  -- RETURN:
  --   A CLOB containing a text summary report showing the number of successes 
  --   and number of failures during the stored outline migration. In case of
  --   failures, the report will also show the causes of failure. 
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  --   "ALTER ANY OUTLINE" privilege
  -- -------------------------------------------------------------------------
  FUNCTION migrate_stored_outline( outln_list    IN DBMS_SPM.NAME_LIST,
                                   fixed         IN VARCHAR2 := 'NO' 
                                 )
  RETURN CLOB;


  -- -------------------------------------------------------------------------
  -- NAME:
  --   drop_migrated_stored_outline
  --
  -- DESCRIPTION:
  --   This function can be used to drop all stored outlines that are already
  --   migrated to SQL plan baselines. 
  --
  -- PARAMETERS:
  --   None
  -- RETURN:
  --   Number of outlines dropped.
  --
  -- REQUIRE:
  --   "Administer SQL Management Object" privilege
  --   "DROP ANY OUTLINE" privilege
  --   "select on dba_outlines" privilege
  -- -------------------------------------------------------------------------
  FUNCTION drop_migrated_stored_outline
  RETURN PLS_INTEGER;


  ----------------- create_evolve_task - SQL handle format -------------------
  -- NAME: 
  --     create_evolve_task - Create an evolve task in order to evolve one or
  --     more plans for a given SQL statement (SQL handle format)
  --
  -- DESCRIPTION
  --     This function is called to prepare the evolution of one or more plans
  --     for a SQL statement given its handle.  The function mainly creates an
  --     advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sql_handle  (IN) - Handle of a SQL statement.  The default NULL means
  --                        consider all SQL statements with non-accepted
  --                        plans.
  --     plan_name   (IN) - Plan identifier.  The default NULL means consider
  --                        all non-accepted plans of the specified SQL handle
  --                        or all SQL statements if the SQL handle is NULL.
  --     time_limit  (IN) - Time limit in number of minutes.  The time limit
  --                        is global and it is used in the following manner.
  --                        The time limit for first non-accepted plan is equal
  --                        to the input value. The time limit for the second
  --                        non-accepted plan is equal to (input value - time
  --                        spent in first plan verification) and so on. The
  --                        default DBMS_SPM.AUTO_LIMIT means let the system
  --                        choose an appropriate time limit based on the
  --                        number of plan verifications required to be done.
  --                        The value DBMS_SPM.NO_LIMIT means no time limit.
  --     task_name   (IN) - Evolve task name   
  --     description (IN) - Description of the task (maximum 256 characters) 
  --
  -- RETURNS:
  --     SQL evolve task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_evolve_task( sql_handle  IN VARCHAR2  := NULL,
                               plan_name   IN VARCHAR2  := NULL,
                               time_limit  IN NUMBER    := DBMS_SPM.AUTO_LIMIT,
                               task_name   IN VARCHAR2  := NULL,
                               description IN VARCHAR2  := NULL
                             )
  RETURN VARCHAR2;


  ------------------- create_evolve_task - plan list format -------------------
  -- NAME: 
  --     create_evolve_task - Create an evolve task in order to evolve one or
  --     more given plans (plan list format)
  --
  -- DESCRIPTION
  --     This function is called to prepare the evolution of one or more given
  --     plans.  The function mainly creates an advisor task and sets its
  --     parameters. 
  --
  -- PARAMETERS:
  --     plan_list   (IN) - A list of plan names.  The plans may belong to
  --                        different SQL statements.
  --     time_limit  (IN) - Time limit in number of minutes.  The time limit
  --                        is global and it is used in the following manner.
  --                        The time limit for first non-accepted plan is equal
  --                        to the input value. The time limit for the second
  --                        non-accepted plan is equal to (input value - time
  --                        spent in first plan verification) and so on. The
  --                        default DBMS_SPM.AUTO_LIMIT means let the system
  --                        choose an appropriate time limit based on the
  --                        number of plan verifications required to be done.
  --                        The value DBMS_SPM.NO_LIMIT means no time limit.
  --     task_name   (IN) - Evolve task name   
  --     description (IN) - Description of the task (maximum 256 characters) 
  --
  -- RETURNS:
  --     SQL evolve task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_evolve_task( plan_list   IN DBMS_SPM.NAME_LIST,
                               time_limit  IN NUMBER    := DBMS_SPM.AUTO_LIMIT,
                               task_name   IN VARCHAR2  := NULL,
                               description IN VARCHAR2  := NULL
                             )
  RETURN VARCHAR2;


  -------------------------- set_evolve_task_parameter ------------------------
  -- NAME: 
  --     set_evolve_task_parameter - Set a parameter of an evolve task
  --
  -- DESCRIPTION
  --     This procedure is called to update the value of an evolve task
  --     parameter of type NUMBER.  The possible parameters are:
  --       TIME_LIMIT     : Global time limit (default DBMS_SPM.AUTO_LIMIT) in
  --                        minutes.  This is the total time allowed for the
  --                        task.
  --       ALTERNATE_PLAN_LIMIT   : The maximum number of plans to load from
  --                                alternate sources. Default is 10.
  --
  -- PARAMETERS:
  --     task_name    (IN) - Identifier of task
  --     parameter    (IN) - Name of the parameter to set
  --     value        (IN) - New value of the parameter 
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_evolve_task_parameter( task_name    IN VARCHAR2,
                                       parameter    IN VARCHAR2,
                                       value        IN NUMBER
                                     );


  -------------------------- set_evolve_task_parameter ------------------------
  -- NAME: 
  --     set_evolve_task_parameter - Set a parameter of an evolve task
  --
  -- DESCRIPTION
  --     This procedure is called to update the value of an evolve task
  --     parameter of type VARCHAR2.  The possible parameters are:
  --       ACCEPT_PLANS   : This parameter is only valid for the automatic
  --                        evolve task, SYS_AUTO_SPM_EVOLVE_TASK.  When
  --                        set to TRUE, all plans recommended by the task
  --                        will be automatically accepted.  When set to FALSE,
  --                        the task will verify the plans, but will not
  --                        implement any recommendations.  The default value
  --                        is TRUE.
  --       ALTERNATE_PLAN_SOURCE  : Determines which sources to search for
  --                                alternate plans: 'CURSOR_CACHE',
  --                                'AUTOMATIC_WORKLOAD_REPOSITORY', or 
  --                                'SQL_TUNING_SET'. Multiple values can be
  --                                combined by delimiting with '+', and
  --                                '' or NULL indicates none of the sources
  --                                should be used. The default value is 
  --                              'CURSOR_CACHE+AUTOMATIC_WORKLOAD_REPOSITORY'.
  --       ALTERNATE_PLAN_BASELINE: Value 'EXISTING' indicates that alternate
  --                                plans should be loaded for statements with
  --                                existing SQL plan baselines. Value 'NEW'
  --                                indicates that alternate plans should be
  --                                loaded for statements which do not have
  --                                a SQL plan baseline, in which case a new
  --                                baseline for the statement will be created.
  --                                Value 'EXISTING+NEW' will load alternate
  --                                plans in both cases.
  --
  -- PARAMETERS:
  --     task_name    (IN) - Identifier of task
  --     parameter    (IN) - Name of the parameter to set
  --     value        (IN) - New value of the parameter 
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_evolve_task_parameter( task_name    IN VARCHAR2,
                                       parameter    IN VARCHAR2,
                                       value        IN VARCHAR2
                                     );


  ----------------------------- execute_evolve_task ---------------------------
  -- NAME: 
  --     execute_evolve_task - Execute an evolve task
  --
  -- DESCRIPTION
  --     This function is called to execute a previously created evolve task. 
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to execute
  --     execution_name  (IN) - A name to qualify and identify an execution.
  --                            If not specified, it is generated by the
  --                            advisor and returned by the function.
  --     execution_desc  (IN) - Description of the execution (maximum 256
  --                            characters) 
  --
  -- RETURNS:
  --     Name of the new execution
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION execute_evolve_task( task_name       IN VARCHAR2,
                                execution_name  IN VARCHAR2  := NULL,
                                execution_desc  IN VARCHAR2  := NULL
                              )
  RETURN VARCHAR2;


  ---------------------------- interrupt_evolve_task --------------------------
  -- NAME: 
  --     interrupt_evolve_task - Interrupt an evolve task
  --
  -- DESCRIPTION
  --     This function is called to interrupt a currently executing evolve
  --     task.  The task will end its operations as it would at a normal exit
  --     and the user will be able to access the intermediate results.  The
  --     task may also be later resumed.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to interrupt
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     If the task is not currently executing, you will get an ORA-13609
  --     error.
  -----------------------------------------------------------------------------
  PROCEDURE interrupt_evolve_task( task_name IN VARCHAR2
                                 );


  ----------------------------- cancel_evolve_task ----------------------------
  -- NAME: 
  --     cancel_evolve_task - Cancel an evolve task
  --
  -- DESCRIPTION
  --     This function is called to cancel a currently executing evolve task.
  --     All intermediate results will be removed from the task.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to cancel
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     If the task is not currently executing, you will get an ORA-13609
  --     error.
  -----------------------------------------------------------------------------
  PROCEDURE cancel_evolve_task( task_name IN VARCHAR2
                              );


  ----------------------------- reset_evolve_task -----------------------------
  -- NAME: 
  --     reset_evolve_task - Reset an evolve task
  --
  -- DESCRIPTION
  --     This function is called to reset an evolve task to its initial state.
  --     All intermediate results will be removed from the task.  Call this
  --     procedure on a task that is not currently executing.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to reset
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE reset_evolve_task( task_name IN VARCHAR2
                             );


  ----------------------------- resume_evolve_task ----------------------------
  -- NAME: 
  --     resume_evolve_task - Resume an evolve task
  --
  -- DESCRIPTION
  --     This function is called to resume a previously interrupted task.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to resume
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE resume_evolve_task( task_name IN VARCHAR2
                              );


  ------------------------------ drop_evolve_task -----------------------------
  -- NAME: 
  --     drop_evolve_task - Drop an evolve task
  --
  -- DESCRIPTION
  --     This function is called to drop an evolve task.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to drop
  --
  -- RETURNS:
  --     Nothing
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE drop_evolve_task( task_name IN VARCHAR2
                            );


  ----------------------------- report_evolve_task ----------------------------
  -- NAME: 
  --     report_evolve_task - Report an evolve task
  --
  -- DESCRIPTION
  --     This function is called to display the results of an evolve task. 
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to report
  --     type            (IN) - Type of the report.  Possible values are TEXT,
  --                            HTML, XML.
  --     level           (IN) - Format of the report.  Possible values are
  --                            BASIC, TYPICAL, ALL.
  --     section         (IN) - Particular section in the report.  
  --                            Possible values are: 
  --                              SUMMARY,
  --                              FINDINGS,
  --                              PLANS,
  --                              INFORMATION,
  --                              ERRORS,
  --                              ALL.
  --     object_id       (IN) - Identifier of the advisor framework object that
  --                            represents a single plan.  If NULL, the report
  --                            will be generated for all objects.
  --     task_owner      (IN) - Owner of the evolve task.  Defaults to the
  --                            current schema owner.
  --     execution_name  (IN) - A name to qualify and identify an execution.
  --                            If NULL, the report will be generated for the
  --                            last task execution.
  --
  -- RETURNS:
  --     The report
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION report_evolve_task( task_name       IN VARCHAR2,
                               type            IN VARCHAR2 := 'TEXT',
                               level           IN VARCHAR2 := 'TYPICAL',
                               section         IN VARCHAR2 := 'ALL',
                               object_id       IN NUMBER   := NULL,
                               task_owner      IN VARCHAR2 := NULL,
                               execution_name  IN VARCHAR2 := NULL)
  RETURN CLOB;


  -------------------------- accept_sql_plan_baseline -------------------------
  -- NAME: 
  --     accept_sql_plan_baseline - Accept plan based on recommendation of
  --                                evolve task
  --
  -- DESCRIPTION
  --     This function is called to accept a plan based on the recommendation
  --     of an evolve task.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to implement
  --     object_id       (IN) - Identifier of the advisor framework object that
  --                            represents a single plan
  --     task_owner      (IN) - Owner of the evolve task.  Defaults to the
  --                            current schema owner.
  --     force           (IN) - Accept the plan even if the advisor did not
  --                            recommend such an action.  The default is
  --                            FALSE meaning only accept the plan if the
  --                            plan was verified and showed sufficient
  --                            improvement in benefit.
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE accept_sql_plan_baseline( task_name       IN VARCHAR2,
                                      object_id       IN NUMBER,
                                      task_owner      IN VARCHAR2 := NULL,
                                      force           IN BOOLEAN  := FALSE
                                    );


  --------------------------- implement_evolve_task ---------------------------
  -- NAME: 
  --     implement_evolve_task - Implement recommendations of evolve task
  --
  -- DESCRIPTION
  --     This function is called to implement the recommendations of an evolve
  --     task.
  --
  -- PARAMETERS:
  --     task_name       (IN) - Identifier of task to implement
  --     task_owner      (IN) - Owner of the evolve task.  Defaults to the
  --                            current schema owner.
  --     execution_name  (IN) - A name to qualify and identify an execution.
  --                            If NULL, the action will be taken for the
  --                            last task execution.
  --     force           (IN) - Accept all plans even if the advisor did not
  --                            recommend such an action.  The default is
  --                            FALSE meaning only accept those plans that
  --                            were verified and showed sufficient
  --                            improvement in benefit.
  --
  -- RETURNS:
  --     The number of plans accepted
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION implement_evolve_task( task_name       IN VARCHAR2,
                                  task_owner      IN VARCHAR2 := NULL,
                                  execution_name  IN VARCHAR2 := NULL,
                                  force           IN BOOLEAN  := FALSE
                                )
  RETURN NUMBER;


  --------------------------- report_auto_evolve_task -------------------------
  -- NAME: 
  --     report_auto_evolve_task - Report automatic evolve task
  --
  -- DESCRIPTION
  --     This function is called to display the results of an execution of
  --     the automatic evolve task. 
  --
  -- PARAMETERS:
  --     type            (IN) - Type of the report.  Possible values are TEXT,
  --                            HTML, XML.
  --     level           (IN) - Format of the report.  Possible values are
  --                            BASIC, TYPICAL, ALL.
  --     section         (IN) - Particular section in the report.  
  --                            Possible values are: 
  --                              SUMMARY,
  --                              FINDINGS,
  --                              PLANS,
  --                              INFORMATION,
  --                              ERRORS,
  --                              ALL.
  --     object_id       (IN) - Identifier of the advisor framework object that
  --                            represents a single plan.  If NULL, the report
  --                            will be generated for all objects.
  --     execution_name  (IN) - A name to qualify and identify an execution.
  --                            If NULL, the report will be generated for the
  --                            last task execution.
  --
  -- RETURNS:
  --     The report
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION report_auto_evolve_task(type           IN VARCHAR2 := 'TEXT',
                                   level          IN VARCHAR2 := 'TYPICAL',
                                   section        IN VARCHAR2 := 'ALL',
                                   object_id      IN NUMBER   := NULL,
                                   execution_name IN VARCHAR2 := NULL)
  RETURN CLOB;


END dbms_spm;
/
show errors;
/

-------------------------------------------------------------------------------
--                    Public synonym for the package                         --
-------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_spm FOR dbms_spm
/

-------------------------------------------------------------------------------
--           Grant the execute privilege on SPM package to public.           --
--           But ADMINISTER SQL MANAGEMENT OBJECT privilege is checked       --
--           before a user is allowed to execute.                            --
-------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_spm TO public
/
show errors;
/

@?/rdbms/admin/sqlsessend.sql
