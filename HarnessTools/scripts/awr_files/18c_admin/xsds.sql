Rem
Rem $Header: rdbms/admin/xsds.sql /main/17 2016/11/21 10:11:03 bidu Exp $
Rem
Rem xsds.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsds.sql - XS Data Security Policy adminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_DATA_SECURITY package specification for policy adminstrative 
Rem      interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsds.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsds.sql
Rem SQL_PHASE: XSDS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bidu        09/29/16 - Bug 22545933: Enable Replication for
Rem                           XS_DATA_SECURITY_UTIL
Rem    bidu        06/29/16 - bug 23597785: change XS_DATA_SECURITY_UTIL to
Rem                           invoker rights
Rem    raeburns    06/11/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    minwei      08/21/14 - Bug#17925485: change objnametype to 130
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    minx        09/18/13 - Fix Bug 17478619: Add data realm description 
Rem    minwei      06/29/12 - Bug 13105099:Support multiple ACLMV on one table
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    skwak       03/21/12 - Remove apply option
Rem    weihwang    02/24/12 - Owner bypass enhancement
Rem    xiaobma     02/27/12 - Bug 13784524: Add package XS_DATA_SECURITY_UTIL
Rem    skwak       01/05/12 - Add statement type to apply_object_policy
Rem    skwak       08/16/11 - Add apply/remove/enable/disable policy
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        07/06/11 - Admin Sec Prj enhancement: Add Invoker rights 
Rem                           package wrapper
Rem    yiru        05/17/11 - Admin Sec Prj2: Change to definer rights package
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and 
Rem                           rolling upgrade support at package level
Rem    weihwang    09/15/09 - Added is_parameterized in rule based instance set
Rem                           type. Changed xs$instance_set_type_list to
Rem                           xs$instance_set_list. Removed rewrite_threshold.
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create a type for key
CREATE OR REPLACE TYPE XS$KEY_TYPE FORCE AS OBJECT (

primary_key      VARCHAR2(130),
foreign_key      VARCHAR2(4000),

-- Foreign key type; 1 = col name, 2 = col value
foreign_key_type NUMBER,

-- Constructor function
CONSTRUCTOR FUNCTION XS$KEY_TYPE
                     (primary_key      IN VARCHAR2,
                      foreign_key      IN VARCHAR2,
                      foreign_key_type IN NUMBER)
                      RETURN SELF AS RESULT,

-- Get the primary key of the key
MEMBER FUNCTION GET_PRIMARY_KEY RETURN VARCHAR2,
-- Get the foreign key of the key
MEMBER FUNCTION GET_FOREIGN_KEY RETURN VARCHAR2,
-- Get the foreign key type
MEMBER FUNCTION GET_FOREIGN_KEY_TYPE RETURN NUMBER,

-- Set the primary key of the key
MEMBER PROCEDURE SET_PRIMARY_KEY(primary_key IN VARCHAR2),
-- Set the foreign key of the key
MEMBER PROCEDURE SET_FOREIGN_KEY(foreign_key IN VARCHAR2),
-- Set the foreign key type
MEMBER PROCEDURE SET_FOREIGN_KEY_TYPE(foreign_key_type IN NUMBER)
);
/
show errors;

CREATE OR REPLACE TYPE XS$KEY_LIST FORCE AS VARRAY(1000) OF XS$KEY_TYPE;
/

show errors;
-- Create a type of Realm constraint
CREATE OR REPLACE TYPE XS$REALM_CONSTRAINT_TYPE FORCE AS OBJECT (
-- Member variables
realm_type    NUMBER,

-- Member evaluation rule 
realm              VARCHAR2(4000),
-- acl list of instance set
acl_list              XS$NAME_LIST,
-- isStatic variable for instance set. Stored as INTEGER. No boolean datatype 
-- for objects. False is stored as 0 and TRUE is stored as 1
is_static          INTEGER,

--description
description        VARCHAR2(4000),
-- Indicate if the realm is parameterized.
parameterized      INTEGER,

-- parent schema name for inherited from
parent_schema      VARCHAR2(130),
-- parent object name for inherited from
parent_object      VARCHAR2(130),
-- keys for inherited from
key_list           XS$KEY_LIST,
-- when condition for inherited from
when_condition     VARCHAR2(4000),


-- Constructor function - row_level realm
CONSTRUCTOR FUNCTION XS$REALM_CONSTRAINT_TYPE
                     (realm                  IN VARCHAR2,
                      acl_list               IN XS$NAME_LIST,
                      is_static              IN BOOLEAN := FALSE,
                      description            IN VARCHAR2 :=NULL)
                      RETURN SELF AS RESULT,

-- Constructor function - parameterized row_level realm
CONSTRUCTOR FUNCTION XS$REALM_CONSTRAINT_TYPE
                     (realm                  IN VARCHAR2,                      
                      is_static              IN BOOLEAN := FALSE)
                      RETURN SELF AS RESULT,

-- Constructor function - master realm
CONSTRUCTOR FUNCTION XS$REALM_CONSTRAINT_TYPE
                     (parent_schema  IN VARCHAR2,
                      parent_object  IN VARCHAR2,
                      key_list       IN XS$KEY_LIST,
                      when_condition IN VARCHAR2:= NULL)
                      RETURN SELF AS RESULT,

-- Accessor functions
-- Get the type
MEMBER FUNCTION GET_TYPE RETURN NUMBER,

-- Get the realm
MEMBER FUNCTION GET_REALM RETURN VARCHAR2,
-- Get the acls 
MEMBER FUNCTION GET_ACLS RETURN XS$NAME_LIST,
-- Is static or dynamic ?
MEMBER FUNCTION IS_DYNAMIC_REALM RETURN BOOLEAN,

MEMBER FUNCTION IS_STATIC_REALM RETURN BOOLEAN,

MEMBER FUNCTION GET_DESCRIPTION RETURN VARCHAR2,

-- Is parameterized ?
MEMBER FUNCTION IS_PARAMETERIZED_REALM RETURN BOOLEAN,

-- Get the keys of inherited_from
MEMBER FUNCTION GET_KEYS RETURN XS$KEY_LIST,
-- Get the parent schema name for inherited from
MEMBER FUNCTION GET_PARENT_SCHEMA RETURN VARCHAR2,
-- Get the parent object name for inherited from
MEMBER FUNCTION GET_PARENT_OBJECT RETURN VARCHAR2,
-- Get when for inherited from
MEMBER FUNCTION GET_WHEN_CONDITION RETURN VARCHAR2,

-- Set the member realm
MEMBER PROCEDURE SET_REALM(realm IN VARCHAR2),

-- Add acls to te realm
MEMBER PROCEDURE ADD_ACLS(acl      IN VARCHAR2),
MEMBER PROCEDURE ADD_ACLS(acl_list IN XS$NAME_LIST),
-- Set the acls of the realm
MEMBER PROCEDURE SET_ACLS(acl_list IN XS$NAME_LIST),
-- Set static or dynamic
MEMBER PROCEDURE SET_DYNAMIC,
MEMBER PROCEDURE SET_STATIC,
-- Set Description
MEMBER PROCEDURE SET_DESCRIPTION(description IN VARCHAR2),
-- Add keys
MEMBER PROCEDURE ADD_KEYS(key IN XS$KEY_TYPE),
MEMBER PROCEDURE ADD_KEYS(key_list IN XS$KEY_LIST),
-- Set the keys
MEMBER PROCEDURE SET_KEYS(key_list IN XS$KEY_LIST),
-- Set the parent schema of the inherited from
MEMBER PROCEDURE SET_PARENT_SCHEMA(parent_schema IN VARCHAR2),
-- Set the parent object of the inherited from
MEMBER PROCEDURE SET_PARENT_OBJECT(parent_object IN VARCHAR2),
-- Set when value of the inherited from
MEMBER PROCEDURE SET_WHEN_CONDITION(when_condition IN VARCHAR2)
);
/
show errors;
-- Create a list of realm constraint type
CREATE OR REPLACE TYPE XS$REALM_CONSTRAINT_LIST AS VARRAY(1000)
                       OF XS$REALM_CONSTRAINT_TYPE;
/
show errors;

-- Create a type for column(attribute) security
CREATE OR REPLACE TYPE XS$COLUMN_CONSTRAINT_TYPE FORCE AS OBJECT (

-- column list
column_list        XS$LIST,
-- privilege for column security
privilege          VARCHAR2(261),

-- Constructor function
CONSTRUCTOR FUNCTION XS$COLUMN_CONSTRAINT_TYPE
                     (column_list  IN XS$LIST,
                      privilege    IN VARCHAR2)
                      return SELF AS RESULT,

-- get column list
MEMBER FUNCTION GET_COLUMNS RETURN XS$LIST,
-- Get the privilege for column security
MEMBER FUNCTION GET_PRIVILEGE RETURN VARCHAR2,

-- Add a column to column security
MEMBER PROCEDURE ADD_COLUMNS(column IN VARCHAR2),
-- Add columns to column security
MEMBER PROCEDURE ADD_COLUMNS(column_list IN XS$LIST),
-- Set the columns  of column  security
MEMBER PROCEDURE SET_COLUMNS(column_list IN XS$LIST),
-- Set the privilege of the column security
MEMBER PROCEDURE SET_PRIVILEGE(privilege IN VARCHAR2)
);
/

-- Create a list of column constraint for column security
CREATE OR REPLACE TYPE XS$COLUMN_CONSTRAINT_LIST
                       IS VARRAY(1000) of XS$COLUMN_CONSTRAINT_TYPE;
/
show errors;

-- Create DATA SECURITY package
CREATE OR REPLACE PACKAGE XS_DATA_SECURITY AUTHID CURRENT_USER AS

-- Apply policy options 
  APPLY_DYNAMIC_IS          CONSTANT   PLS_INTEGER := 1;
  APPLY_ACLOID_COLUMN       CONSTANT   PLS_INTEGER := 2;
  APPLY_STATIC_IS           CONSTANT   PLS_INTEGER := 3;

-- Enable log based replication for this package
PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Create data security policy
PROCEDURE CREATE_POLICY (
          name                     IN VARCHAR2,          
          realm_constraint_list    IN  XS$REALM_CONSTRAINT_LIST,
          column_constraint_list   IN  XS$COLUMN_CONSTRAINT_LIST := NULL,
          description              IN VARCHAR2 := NULL                    
          );

-- Add a realm constraint to data security
PROCEDURE APPEND_REALM_CONSTRAINTS (
          policy                IN VARCHAR2,
          realm_constraint      IN XS$REALM_CONSTRAINT_TYPE
          );

-- Add a list of realm constraints to data security
PROCEDURE APPEND_REALM_CONSTRAINTS (
          policy                IN VARCHAR2,
          realm_constraint_list IN XS$REALM_CONSTRAINT_LIST
          );

-- Remove all realm constraints
PROCEDURE REMOVE_REALM_CONSTRAINTS (
          policy                IN VARCHAR2
          );

-- Add a column constraint to data security
PROCEDURE ADD_COLUMN_CONSTRAINTS (
          policy             IN VARCHAR2,
          column_constraint  IN XS$COLUMN_CONSTRAINT_TYPE
          );

-- Add column constraints to data security
PROCEDURE ADD_COLUMN_CONSTRAINTS (
          policy                   IN VARCHAR2,
          column_constraint_list   IN XS$COLUMN_CONSTRAINT_LIST
          );

-- Remove all column constraints of data security
PROCEDURE REMOVE_COLUMN_CONSTRAINTS (
          policy                IN VARCHAR2
          );

-- Create an ACL paramter
PROCEDURE CREATE_ACL_PARAMETER (
          policy               IN VARCHAR2,
          parameter            IN VARCHAR2,
          param_type           IN NUMBER
          );

-- Delete an ACL parameter
PROCEDURE DELETE_ACL_PARAMETER (
          policy                IN VARCHAR2,
          parameter             IN VARCHAR2,
          delete_option         IN PLS_INTEGER := XS_ADMIN_UTIL.DEFAULT_OPTION
          );
          
-- Set the description of data security
PROCEDURE SET_DESCRIPTION (
          policy                 IN VARCHAR2,
          description            IN VARCHAR2
          );


-- Delete data security policy
PROCEDURE DELETE_POLICY(
          policy                IN VARCHAR2,
          delete_option         IN PLS_INTEGER := XS_ADMIN_UTIL.DEFAULT_OPTION
          );

-- apply_object_policy -  Apply XDS policy on a table
PROCEDURE APPLY_OBJECT_POLICY(
          policy          IN VARCHAR2,
          schema          IN VARCHAR2,
          object          IN VARCHAR2,
          row_acl         IN BOOLEAN  := FALSE,
          owner_bypass    IN BOOLEAN  := FALSE,
          statement_types IN VARCHAR2 := NULL,
          aclmv           IN VARCHAR2 := NULL
          );
 
-- enable_object_policy - disable an XDS policy for a table
PROCEDURE ENABLE_OBJECT_POLICY(
          policy IN VARCHAR2,
          schema IN VARCHAR2,
          object IN VARCHAR2
          );

-- disable_object_policy - disable an XDS policy for a table
PROCEDURE DISABLE_OBJECT_POLICY(
          policy IN VARCHAR2,
          schema IN VARCHAR2,
          object IN VARCHAR2
          );

-- remove_object_policy - remove an XDS policy from a table
PROCEDURE REMOVE_OBJECT_POLICY(
          policy IN VARCHAR2,
          schema IN VARCHAR2,
          object IN VARCHAR2
          );

END XS_DATA_SECURITY;
/
show errors;

-- Bug 13784524: Create DATA SECURITY utility package
-- Bug 23597785: rename XS_DATA_SECURITY_UTIL to XS_DATA_SECURITY_UTIL_INT
CREATE OR REPLACE PACKAGE XS_DATA_SECURITY_UTIL_INT
ACCESSIBLE BY (PACKAGE XS_DATA_SECURITY_UTIL) AS

  TYPE OBJNAMETYPE IS table of VARCHAR2(130) index by binary_integer;
  TYPE OBJNUMTYPE IS table of NUMBER index by binary_integer;

  -- Valid values for ACLMV refresh_mode
  ACLMV_ON_DEMAND            CONSTANT VARCHAR2(9) := 'ON DEMAND';
  ACLMV_ON_COMMIT            CONSTANT VARCHAR2(9) := 'ON COMMIT';

  -- Type of refresh on static acl mv
  XS_ON_COMMIT_MV  CONSTANT BINARY_INTEGER := 0;
  XS_ON_DEMAND_MV  CONSTANT BINARY_INTEGER := 1;
  XS_SCHEDULED_MV  CONSTANT BINARY_INTEGER := 2;

  -- Type of static acl mv
  XS_SYSTEM_GENERATED_MV  CONSTANT BINARY_INTEGER := 0;
  XS_USER_SPECIFIED_MV  CONSTANT BINARY_INTEGER := 1;

-- Enable log based replication for this package 
-- PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

  -- schedule_static_acl_refresh
  --             - schedule automatic refresh of an ACLMV for a given table.
  --             - this function will change the refresh mode of the
  --               corresponding ACLMV to "ON DEMAND"
  --
  -- INPUT PARAMETERS
  --   cur_userid    - current user id
  --   schema_name   - schema owning the object, current user if NULL
  --   table_name     - name of object
  --   start_date      - time of first refresh to occur
  --   repeat_interval - schedule interval
  --   comments        - comments

  PROCEDURE schedule_static_acl_refresh(
          cur_userid  IN NUMBER,
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
  --   cur_userid    - current user id
  --   schema_name   - schema owning the object, current user if NULL
  --   table_name    - name of object
  --   refresh_mode  - refresh mode for internal ACLMV. 'ON DEMAND' or
  --                     'ON COMMIT' are the only legal values

  PROCEDURE alter_static_acl_refresh(cur_userid IN NUMBER,
                                     schema_name IN VARCHAR2 := NULL,
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
  -- xs$refresh_static_acl (not documented)
  --           - scheduler callback procedure to refresh the acl-mv on a table
  --
  -- INPUT PARAMETERS
  --   schema_name     - schema owning the table
  --   table_name      - name of table
  --   mview_name      - name of miew
  --   job_name        - name of job

  procedure  xs$refresh_static_acl(
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
 
END XS_DATA_SECURITY_UTIL_INT;
/

show errors;

-- Bug 23597785: Create XS_DATA_SECURITY_UTIL with invoker rights
CREATE OR REPLACE PACKAGE XS_DATA_SECURITY_UTIL AUTHID CURRENT_USER AS

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
  -- Bug 22545933: Enable log based replication for the procedure
  PRAGMA SUPPLEMENTAL_LOG_DATA(schedule_static_acl_refresh, AUTO_WITH_COMMIT);
  
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
  -- Bug 22545933: Enable log based replication for the procedure
  PRAGMA SUPPLEMENTAL_LOG_DATA(alter_static_acl_refresh, AUTO_WITH_COMMIT);

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
  -- Bug 22545933: Enable log based replication for the procedure
  PRAGMA SUPPLEMENTAL_LOG_DATA(purge_acl_refresh_history, AUTO_WITH_COMMIT);

  ----------------------------------------------------------------------------
  -- xs$refresh_static_acl (not documented)
  --           - scheduler callback procedure to refresh the acl-mv on a table
  --
  -- INPUT PARAMETERS
  --   schema_name     - schema owning the table
  --   table_name      - name of table
  --   mview_name      - name of miew
  --   job_name        - name of job

  procedure  xs$refresh_static_acl(
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
 
END XS_DATA_SECURITY_UTIL;
/

show errors;



@?/rdbms/admin/sqlsessend.sql
