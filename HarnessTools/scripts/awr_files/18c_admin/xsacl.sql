Rem
Rem $Header: rdbms/admin/xsacl.sql /main/10 2015/08/19 11:54:51 raeburns Exp $
Rem
Rem xsacl.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsacl.sql - XS ACL adminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_ACL package for ACL adminstrative interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsacl.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsacl.sql
Rem SQL_PHASE: XSACL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    yiru        03/25/15 - Add API for Removing an ACL parameter value 
Rem                           associated with a policy
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        06/29/11 - Admin Sec Prj enhancement: Add Invoker rights 
Rem                           package wrapper
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and 
Rem                           rolling upgrade support at package level
Rem    yiru        05/13/11 - Admin Sec Prj2: Change to definer rights package
Rem    snadhika    04/15/10 - Triton session enhancement project
Rem    yiru        01/22/10 - cleanup
Rem    weihwang    10/15/09 - principal_format changed to principal_type
Rem    yiru        09/24/09 - Add exception
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Type definition for ACE
CREATE OR REPLACE TYPE XS$ACE_TYPE FORCE AS OBJECT (

-- Member Variables
  privilege_list      XS$NAME_LIST,
  is_grant_ace        NUMBER,
  is_invert_principal NUMBER,
  principal_name      VARCHAR2(130),
  principal_type      NUMBER,
  start_date          TIMESTAMP WITH TIME ZONE,
  end_date            TIMESTAMP WITH TIME ZONE,

  CONSTRUCTOR FUNCTION XS$ACE_TYPE (
    privilege_list   IN XS$NAME_LIST,
    granted          IN BOOLEAN := TRUE,
    inverted         IN BOOLEAN := FALSE,
    principal_name   IN VARCHAR2,
    principal_type   IN PLS_INTEGER := 1,
    start_date       IN TIMESTAMP WITH TIME ZONE := NULL,
    end_date         IN TIMESTAMP WITH TIME ZONE := NULL)
  RETURN SELF AS RESULT,

-- Set the privileges
  MEMBER PROCEDURE set_privileges(privilege_list IN XS$NAME_LIST),

-- Return the privileges
  MEMBER FUNCTION get_privileges RETURN XS$NAME_LIST,

-- Grant or deny
  MEMBER PROCEDURE set_grant(granted IN BOOLEAN),

-- Return true if it is granted.
  MEMBER FUNCTION is_granted RETURN BOOLEAN,

-- Invert or not
  MEMBER PROCEDURE set_inverted_principal(inverted IN BOOLEAN),

-- Return true if the principal is inverted.
  MEMBER FUNCTION is_inverted_principal RETURN BOOLEAN,

-- Set the principal
  MEMBER PROCEDURE set_principal(principal_name IN VARCHAR2),

-- Return the principal
  MEMBER FUNCTION get_principal RETURN VARCHAR2,

-- Set the principal format
  MEMBER PROCEDURE set_principal_type (principal_type IN PLS_INTEGER),

-- Return the principal format
  MEMBER FUNCTION get_principal_type RETURN PLS_INTEGER,

-- Set the start date
  MEMBER PROCEDURE set_start_date(start_date IN TIMESTAMP WITH TIME ZONE),

-- Return the start date
  MEMBER FUNCTION get_start_date RETURN TIMESTAMP WITH TIME ZONE,

-- Set the end date
  MEMBER PROCEDURE set_end_date(end_date IN TIMESTAMP WITH TIME ZONE),

-- Return the end date
  MEMBER FUNCTION get_end_date RETURN TIMESTAMP WITH TIME ZONE

);
/

show errors;
CREATE OR REPLACE TYPE XS$ACE_LIST AS VARRAY(1000) OF XS$ACE_TYPE;
/

CREATE OR REPLACE PACKAGE XS_ACL AUTHID CURRENT_USER AS

-- The following constants define the parent ACL type.
  EXTENDED              CONSTANT PLS_INTEGER := 1;
  CONSTRAINED           CONSTANT PLS_INTEGER := 2;  

-- The following constants define the principal's type.
  PTYPE_XS              CONSTANT PLS_INTEGER := 1;
  PTYPE_DB              CONSTANT PLS_INTEGER := 2;
  PTYPE_DN              CONSTANT PLS_INTEGER := 3;
  PTYPE_EXTERNAL        CONSTANT PLS_INTEGER := 4;

-- The following constants define the parameter value type.
  TYPE_NUMBER           CONSTANT PLS_INTEGER := 1;	
  TYPE_VARCHAR          CONSTANT PLS_INTEGER := 2;

-- Enable log based replication for this package
  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Create ACL API
  PROCEDURE create_acl (
    name            IN VARCHAR2,
    ace_list        IN XS$ACE_LIST,
    sec_class       IN VARCHAR2 := NULL,
    parent          IN VARCHAR2:=NULL,
    inherit_mode    IN PLS_INTEGER:=NULL,
    description     IN VARCHAR2 := NULL);

-- Append one ACE to the ACL
  PROCEDURE append_aces (
    acl  IN VARCHAR2,
    ace  IN XS$ACE_TYPE);

-- Append ACEs to the ACL
  PROCEDURE append_aces (
    acl      IN VARCHAR2,
    ace_list IN XS$ACE_LIST);

-- Remove all ACEs from the ACL
  PROCEDURE remove_aces (
    acl      IN VARCHAR2);

-- Set the secuirty class
  PROCEDURE set_security_class (
    acl       IN VARCHAR2,
    sec_class IN VARCHAR2);

-- Set the parent acl
  PROCEDURE set_parent_acl(
    acl          IN VARCHAR2,
    parent       IN VARCHAR2,
    inherit_mode IN PLS_INTEGER);

--Add a parameter value : NUMBER
  PROCEDURE add_acl_parameter (
    acl       IN VARCHAR2,
    policy    IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN NUMBER);

--Add a parameter value : VARCHAR2
  PROCEDURE add_acl_parameter (
    acl       IN VARCHAR2,
    policy    IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

--Remove all parameters
  PROCEDURE remove_acl_parameters (
    acl       IN VARCHAR2);

-- Remove a parameter
  PROCEDURE remove_acl_parameters (
    acl       IN VARCHAR2,
    parameter IN VARCHAR2);

-- Remove a parameter associate with a policy
  PROCEDURE remove_acl_parameters (
    acl       IN VARCHAR2,
    policy    IN VARCHAR2,
    parameter IN VARCHAR2);

-- Set description of ACL
  PROCEDURE set_description (
    acl         IN VARCHAR2,
    description IN VARCHAR2);

-- Delete the ACL
  PROCEDURE delete_acl (
    acl           IN VARCHAR2,
    delete_option IN PLS_INTEGER:=XS_ADMIN_UTIL.DEFAULT_OPTION);

END XS_ACL;
/

show errors;

@?/rdbms/admin/sqlsessend.sql
