Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem $Header: rdbms/admin/dbmsrlsa.sql /main/26 2017/10/19 15:31:10 chliang Exp $
Rem
Rem dbmsrlsa.sql
Rem
Rem Copyright (c) 1998, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrlsa.sql - Row Level Security Adminstrative interface
Rem
Rem    DESCRIPTION
Rem      dbms_rls package for row level security adminstrative interface
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrlsa.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrlsa.sql
Rem SQL_PHASE: DBMSRLSA
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    chliang     08/20/17 - 23598405: make dbms_xds an invoker rights pkg
Rem    anupkk      08/20/16 - XbranchMerge anupkk_bug-24372897 from
Rem                           st_rdbms_12.2.0.1.0
Rem    anupkk      08/03/16 - Bug 24372897: Make dbms_rls invoker right
Rem                           and unpragma''d
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    aramappa    06/06/11 - Proj 31942 - support new OLS policy type
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and 
Rem                           rolling upgrade support for package dbms_xds
Rem    aamirish    02/27/11 - Project 35490: Adding new procedures and
Rem                           constants to dbms_rls
Rem    skwak       01/29/11 - Modify XDS APIs for multiple XDS policy support
Rem    skwak       04/08/10 - Add enable_olap_policy procedure
Rem    clei        10/26/09 - remove REFRESH_DSD and dbms_xdsutl
Rem    clei        10/01/09 - DBMS_XDS argument dsd_path -> policy_name
Rem    akoeller    04/15/08 - Fusion Security Static ACL MV Refresh
Rem    sramakri    12/07/07 - add xds$refresh_static_acl and set_trace_level
Rem    ajadams     11/10/08 - add _with_commit to supplemental_log_data pragma
Rem    clei        10/22/07 - new DBMS_XDS API for XDS enhancements
Rem    pknaggs     08/31/07 - DSD schema: aclids to aclFiles or aclDirectory.
Rem    preilly     03/26/07 - Pragma dbms_xds to not replicate in Logical
Rem                           Standby
Rem    clei        01/08/07 - remove DV_INTERNAL
Rem    fjlee       04/27/06 - XbranchMerge ayalaman_dv_overlay_5112125_0418 
Rem                           from st_rdbms_10.2 
Rem    clei        03/15/06 - remove grant to XDB
Rem    clei        02/11/06 - add dbms_xdsutl
Rem    clei        12/19/05 - add dbms_xds
Rem    cchui       04/02/06 - XbranchMerge cchui_skip_function_call from 
Rem                           st_rdbms_10.2dv 
Rem    cchui       03/28/06 - add new type for Data Vault 
Rem    clei        10/13/03 - ALL_COLUMNS -> ALL_ROWS
Rem    clei        08/13/03 - add security relevant column option
Rem    clei        05/28/02 - policy types, sec relevant cols, and predicate sz
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    clei        04/12/01 - support static policy 
Rem    dmwong      08/16/00 - rename UI to grouped_policies.
Rem    dmwong      02/09/00 - add groups for refresh and enable
Rem    dmwong      01/25/00 - add group extension
Rem    clei        03/16/98 -
Rem    clei        02/24/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_rls AUTHID CURRENT_USER AS

  STATIC                     CONSTANT   BINARY_INTEGER := 1;
  SHARED_STATIC              CONSTANT   BINARY_INTEGER := 2;
  CONTEXT_SENSITIVE          CONSTANT   BINARY_INTEGER := 3;
  SHARED_CONTEXT_SENSITIVE   CONSTANT   BINARY_INTEGER := 4;
  DYNAMIC                    CONSTANT   BINARY_INTEGER := 5;
  XDS1                       CONSTANT   BINARY_INTEGER := 6;
  XDS2                       CONSTANT   BINARY_INTEGER := 7;
  XDS3                       CONSTANT   BINARY_INTEGER := 8;
  OLS                        CONSTANT   BINARY_INTEGER := 9;

  -- security relevant columns options, default is null
  ALL_ROWS                   CONSTANT   BINARY_INTEGER := 1;

  -- Type of refresh on static acl mv
  XDS_ON_COMMIT_MV  CONSTANT BINARY_INTEGER := 0;  
  XDS_ON_DEMAND_MV  CONSTANT BINARY_INTEGER := 1;  
  XDS_SCHEDULED_MV  CONSTANT BINARY_INTEGER := 2;  

  -- Type of static acl mv
  XDS_SYSTEM_GENERATED_MV  CONSTANT BINARY_INTEGER := 0;  
  XDS_USER_SPECIFIED_MV  CONSTANT BINARY_INTEGER := 1;  

  -- alter options for a row level security policy
  ADD_ATTRIBUTE_ASSOCIATION       CONSTANT   BINARY_INTEGER := 1;
  REMOVE_ATTRIBUTE_ASSOCIATION    CONSTANT   BINARY_INTEGER := 2;


  -- ------------------------------------------------------------------------
  -- add_policy -  add a row level security policy to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant column option
  --   namespace       - name of application context namespace
  --   attribute       - name of application context attribute

  PROCEDURE add_policy(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       policy_name     IN VARCHAR2,
                       function_schema IN VARCHAR2 := NULL,
                       policy_function IN VARCHAR2,
                       statement_types IN VARCHAR2 := NULL,
                       update_check    IN BOOLEAN  := FALSE,
                       enable          IN BOOLEAN  := TRUE,
                       static_policy   IN BOOLEAN  := FALSE,
                       policy_type     IN BINARY_INTEGER := NULL,
                       long_predicate BOOLEAN  := FALSE,
                       sec_relevant_cols IN VARCHAR2  := NULL,
                       sec_relevant_cols_opt IN BINARY_INTEGER := NULL,
                       namespace       IN VARCHAR2 := NULL,
                       attribute       IN VARCHAR2 := NULL);
 
  -- alter_policy -  alter a row level security policy
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   alter_option    - addition/removal of attribute association
  --   namespace       - name of application context namespace
  --   attribute       - name of application context attribute
 
  PROCEDURE alter_policy(object_schema IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       policy_name     IN VARCHAR2,
                       alter_option    IN BINARY_INTEGER := NULL,
                       namespace       IN VARCHAR2,
                       attribute       IN VARCHAR2);

  -- alter_grouped_policy -  alter a row level security policy of a
  --                         policy group
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be added
  --   alter_option    - addition/removal of attribute association
  --   namespace       - name of application context namespace
  --   attribute       - name of application context attribute
 
  PROCEDURE alter_grouped_policy(object_schema   IN VARCHAR2 := NULL,
                                 object_name     IN VARCHAR2,
                                 policy_group    IN VARCHAR2 := 'SYS_DEFAULT',
                                 policy_name     IN VARCHAR2,
                                 alter_option    IN BINARY_INTEGER := NULL,
                                 namespace       IN VARCHAR2,
                                 attribute       IN VARCHAR2);

  -- drop_policy - drop a row level security policy from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be dropped
 
  PROCEDURE drop_policy(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2,
                        policy_name   IN VARCHAR2); 

  -- refresh_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be refreshed
 
  PROCEDURE refresh_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL); 

  -- enable_policy - enable or disable a security policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy
 
  PROCEDURE enable_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE );

  -- create_policy_group - create a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be created

  PROCEDURE create_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- ------------------------------------------------------------------------
  -- add_grouped_policy -  add a row level security policy to a policy group
  --                        for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy group to be added
  --   policy_name     - name of policy to be added
  --   function_schema - schema of the policy function, current user if NULL
  --   policy_function - function to generate predicates for this policy
  --   statement_types - statement type that the policy apply, default is any
  --   update_check    - policy checked against updated or inserted value?
  --   enable          - policy is enabled?
  --   static_policy   - policy is static (predicate is always the same)?
  --   policy_type     - policy type - overwrite static_policy if non-null
  --   long_predicate  - max predicate length 4000 bytes (default) or 32K
  --   sec_relevant_cols - list of security relevant columns
  --   sec_relevant_cols_opt - security relevant columns option
  --   namespace       - name of application context namespace
  --   attribute       - name of application context attribute

  PROCEDURE add_grouped_policy(object_schema   IN VARCHAR2 := NULL,
                                object_name     IN VARCHAR2,
                                policy_group    IN VARCHAR2 := 'SYS_DEFAULT',
                                policy_name     IN VARCHAR2,
                                function_schema IN VARCHAR2 := NULL,
                                policy_function IN VARCHAR2,
                                statement_types IN VARCHAR2 := NULL,
                                update_check    IN BOOLEAN  := FALSE,
                                enable          IN BOOLEAN  := TRUE,
                                static_policy   IN BOOLEAN  := FALSE,
                                policy_type     IN BINARY_INTEGER := NULL,
                                long_predicate BOOLEAN  := FALSE,
                                sec_relevant_cols IN VARCHAR2  := NULL,
                              sec_relevant_cols_opt IN BINARY_INTEGER := NULL,
                                namespace       IN VARCHAR2 := NULL,
                                attribute       IN VARCHAR2 := NULL);


  -- ------------------------------------------------------------------------
  -- add_policy_context -  add a driving context to a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE add_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- delete_policy_group - drop a policy group for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group    - name of policy to be dropped

  PROCEDURE delete_policy_group(object_schema IN VARCHAR2 := NULL,
                                object_name   IN VARCHAR2,
                                policy_group  IN VARCHAR2);


  -- drop_grouped_policy - drop a row level security policy from a policy
  --                          group of a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of policy to be dropped
  --   policy_name     - name of policy to be dropped

  PROCEDURE drop_grouped_policy(object_schema IN VARCHAR2 := NULL,
                                   object_name   IN VARCHAR2,
                                   policy_group  IN VARCHAR2 := 'SYS_DEFAULT',
                                   policy_name   IN VARCHAR2);

  -- ------------------------------------------------------------------------
  -- drop_policy_context -  drop a driving context from a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   namespace       - namespace of driving context
  --   attribute       - attribute of driving context

  PROCEDURE drop_policy_context(object_schema   IN VARCHAR2 := NULL,
                        object_name     IN VARCHAR2,
                        namespace       IN VARCHAR2,
                        attribute       IN VARCHAR2);

  -- refresh_grouped_policy - invalidate all cursors associated with the policy
  --                  if no argument provides, all cursors with
  --                  policies involved will be invalidated
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_group     - name of group of the policy to be refreshed
  --   policy_name     - name of policy to be refreshed

  PROCEDURE refresh_grouped_policy(object_schema IN VARCHAR2 := NULL,
                           object_name   IN VARCHAR2 := NULL,
                           group_name    IN VARCHAR2 := NULL,
                           policy_name   IN VARCHAR2 := NULL);

  -- enable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE enable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2,
                          enable        IN BOOLEAN := TRUE);

  -- disable_grouped_policy - enable or disable a policy for a table or view
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the table/view, current user if NULL
  --   object_name     - name of table or view
  --   policy_name     - name of policy to be enabled or disabled
  --   enable          - TRUE to enable the policy, FALSE to disable the policy

  PROCEDURE disable_grouped_policy(object_schema IN VARCHAR2 := NULL,
                          object_name   IN VARCHAR2,
                          group_name    IN VARCHAR2,
                          policy_name   IN VARCHAR2);

END dbms_rls;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_rls FOR sys.dbms_rls
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_rls TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_xds AUTHID CURRENT_USER AS

  ENABLE_DYNAMIC_IS          CONSTANT   BINARY_INTEGER := 1;
  ENABLE_ACLOID_COLUNM       CONSTANT   BINARY_INTEGER := 2;
  ENABLE_STATIC_IS           CONSTANT   BINARY_INTEGER := 3;

  -- Valid values for ACLMV refresh_mode
  ACLMV_ON_DEMAND            CONSTANT VARCHAR2(9) := 'ON DEMAND';
  ACLMV_ON_COMMIT            CONSTANT VARCHAR2(9) := 'ON COMMIT';

  -- Type of refresh on static acl mv
  XDS_ON_COMMIT_MV  CONSTANT BINARY_INTEGER := 0;  
  XDS_ON_DEMAND_MV  CONSTANT BINARY_INTEGER := 1;  
  XDS_SCHEDULED_MV  CONSTANT BINARY_INTEGER := 2;  

  -- Type of static acl mv
  XDS_SYSTEM_GENERATED_MV  CONSTANT BINARY_INTEGER := 0;  
  XDS_USER_SPECIFIED_MV  CONSTANT BINARY_INTEGER := 1;  

  -- Enable log based replication for this package
  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

  -- enable_xds -  Enables XDS for a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object
  --   enable_option   - enable option 
  --                     ENABLE_DYNAMIC_IS: enable XDS with dynamic instance
  --                       set support only.
  --                     ENABLE_ACLOID_COLUNM: enable XDS with dynamic instance
  --                       set support and SYS_ACLOID column avaliable
  --                       for static ACLID storage.
  --                     ENABLE_STATIC_IS: enable XDS with dynamic and static
  --                       instance set support.
  --                     NULL (default): re-enable with the current option or
  --                       ENABLE_DYNAMIC_IS if it is enabled the first time.
  --   policy_name     - Triton XDS policy name
  --   usermv_name     - user can optionally supply an ACL-MV instead of the
  --                     system generated one. If NULL, system will generate
  --                     a complete-refresh MV and use it
  
  PROCEDURE enable_xds(object_schema   IN VARCHAR2 := NULL,
                       object_name     IN VARCHAR2,
                       enable_option   IN BINARY_INTEGER := NULL,
                       policy_name     IN VARCHAR2,
                       usermv_name     IN VARCHAR2 := NULL);

  ----------------------------------------------------------------------------

  -- disable_xds - disable an XDS policy for a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object
  PROCEDURE disable_xds(object_schema IN VARCHAR2 := NULL,
                        object_name   IN VARCHAR2,
                        policy_name   IN VARCHAR2 := NULL);

  ----------------------------------------------------------------------------

  -- drop_xds - drop an XDS policy from a table
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object

  PROCEDURE drop_xds(object_schema IN VARCHAR2 := NULL,
                     object_name   IN VARCHAR2,
                     policy_name   IN VARCHAR2 := NULL);
 
  ----------------------------------------------------------------------------

  -- enable_olap_policy - enable OLAP policy for a table
  --
  -- INPUT PARAMETERS
  --   xchema_name   - schema owning the object, current schema if NULL
  --   logical_name  - name of object
  --   policy_name   - name of policy
  --   overwrite     - option to overwrite existing policy

  PROCEDURE enable_olap_policy(schema_nm   IN VARCHAR2 := NULL,
                               logical_nm  IN VARCHAR2,
                               policy_nm   IN VARCHAR2,
                               overwrite   IN BOOLEAN := FALSE);

  ----------------------------------------------------------------------------

  -- disable_olap_policy - disable OLAP policy for a table
  --
  -- INPUT PARAMETERS
  --   xchema_name   - schema owning the object, current schema if NULL
  --   logical_name  - name of object

  PROCEDURE disable_olap_policy(schema_nm   IN VARCHAR2 := NULL,
                                logical_nm  IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- drop_olap_policy - drop OLAP policy from a table
  --
  -- INPUT PARAMETERS
  --   xchema_name   - schema owning the object, current schema if NULL
  --   logical_name  - name of object

  PROCEDURE drop_olap_policy(schema_nm   IN VARCHAR2 := NULL,
                             logical_nm  IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- schedule_static_acl_refresh
  --             - schedule automatic refresh of an ACLMV for a given table.
  --             - this function will change the refresh mode of the
  --               corresponding ACLMV to "ON DEMAND"
  --
  -- INPUT PARAMETERS
  --   schema_name   - schema owning the object, current user if NULL
  --   table_name     - name of object
  --   start_date      - time of first refresh to occur
  --   repeat_interval - schedule interval
  --   comments        - comments

  PROCEDURE schedule_static_acl_refresh(
          schema_name   IN VARCHAR2 := NULL,
          table_name     IN VARCHAR2,
          start_date      IN TIMESTAMP WITH TIME ZONE := NULL,
          repeat_interval IN VARCHAR2 := NULL,
          comments        IN VARCHAR2 := NULL);

  ----------------------------------------------------------------------------

  -- alter_static_acl_refresh
  --             - alter the refresh mode for a ACLMV for a given table
  --             - this function will remove any refresh schedule for this
  --               ACLMV (see schedule_static_acl_refresh)
  --
  -- INPUT PARAMETERS
  --   schema_name   - schema owning the object, current user if NULL
  --   table_name    - name of object
  --   refresh_mode  - refresh mode for internal ACLMV. 'ON DEMAND' or
  --                     'ON COMMIT' are the only legal values

  PROCEDURE alter_static_acl_refresh(schema_name IN VARCHAR2 := NULL,
                                     table_name   IN VARCHAR2,
                                     refresh_mode  IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- purge_acl_refresh_history
  --           - purge contents of XDS_ACL_REFRESH_STATUS view for this 
  --             table's ACLMV
  --
  -- INPUT PARAMETERS
  --   object_schema   - schema owning the object, current user if NULL
  --   object_name     - name of object
  --   purge_date      - date of scheduled purge - immediate if omitted

  PROCEDURE purge_acl_refresh_history(object_schema IN VARCHAR2 := NULL,
                                      object_name   IN VARCHAR2,
                                      purge_date    IN DATE := NULL);

  ----------------------------------------------------------------------------

  -- xds$refresh_static_acl (not documented)
  --           - scheduler callback procedure to refresh the acl-mv on a table
  --
  -- INPUT PARAMETERS
  --   schema_name     - schema owning the table
  --   table_name      - name of table
  --   mview_name      - name of miew
  --   job_name        - name of job

  procedure  xds$refresh_static_acl(
                          schema_name IN VARCHAR2,
                          table_name  IN VARCHAR2,
                          mview_name IN VARCHAR2,
                          job_name   IN VARCHAR2);

  ----------------------------------------------------------------------------

  -- set_trace_level
  --            sets the trace level (used for debugging, not documented)
  --            The tracing info of the scheduled mv refresh is logged
  --            in aclmv$_reflog table, and is useful for debugging. 
  -- 
  -- INPUT PARAMETERS
  --   schema_name   - schema owning the object
  --   table_name    - name of object
  --   level         - the trace level

  PROCEDURE set_trace_level(schema_name  IN VARCHAR2,
                            table_name   IN VARCHAR2,
                            level        IN NUMBER);

END dbms_xds;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_xds FOR sys.dbms_xds
/

--
-- Grant execute right to EXECUTE_CATALOG_ROLE
--
GRANT EXECUTE ON sys.dbms_xds TO execute_catalog_role
/

@?/rdbms/admin/sqlsessend.sql
