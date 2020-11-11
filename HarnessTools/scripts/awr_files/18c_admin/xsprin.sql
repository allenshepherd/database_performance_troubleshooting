Rem
Rem $Header: rdbms/admin/xsprin.sql /main/15 2016/06/18 00:40:31 yohu Exp $
Rem
Rem xsprin.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsprin.sql - XS Principal adminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_PRINCIPAL package for ACL adminstrative interface
Rem
Rem    NOTES
Rem    Please check for any upgrade/downgrade impact when modifying this file.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsprin.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsprin.sql
Rem SQL_PHASE: XSPRIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpspec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yohu        06/17/16 - Bug 22334884: Remove internal URL
Rem    raeburns    06/11/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    yohu        06/29/14 - Proj 46902: Sesion privilege scoping
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    snadhika    09/26/13 - Bug 17475434 : set_password fails during 
Rem                           rolling upgrade
Rem    yiru        09/16/13 - Bug 17336570:replicate verifier for set_password
Rem    snadhika    06/10/13 - Bug 16507734 : SHA-512 verifier support
Rem    pradeshm    07/03/13 - Proj#46908: new api for setting: profile,user
Rem                           status, own password
Rem    pradeshm    07/02/12 - Support 'no role', modify 'all role' behavior for
Rem                           add_proxy_user, Bug:14096396
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        07/07/11 - Admin Sec Prj enhancement: Add Invoker rights
Rem                           package wrapper
Rem    snadhika    06/10/11 - Single session proxy support (Project # 34785)
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and
Rem                           rolling upgrade support at package level
Rem    yiru        05/13/11 - Change to definer rights package
Rem    yiru        01/22/10 - Cleanup
Rem    jnarasin    11/26/09 - Late Binding Txn 3
Rem    yiru        08/10/09 - Add set_user_default_roles_all call
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Type definition for roles granted to the principals
CREATE OR REPLACE TYPE XS$ROLE_GRANT_TYPE FORCE AS OBJECT (

-- Member Variables
-- Constants defined in other packages cannot be recognized in a type.
-- e.g.  XS_ADMIN_UTIL.XSNAME_MAXLEN
-- name   VARCHAR2(XS_ADMIN_UTIL.XSNAME_MAXLEN),
  name          VARCHAR2(130),
-- Start date of the effective date
  start_date    TIMESTAMP WITH TIME ZONE,
-- End date of the effective date
  end_date      TIMESTAMP WITH TIME ZONE,

  CONSTRUCTOR FUNCTION XS$ROLE_GRANT_TYPE (
    name       IN VARCHAR2,
    start_date IN TIMESTAMP WITH TIME ZONE:= NULL,
    end_date   IN TIMESTAMP WITH TIME ZONE:= NULL)
  RETURN SELF AS RESULT,

-- Return the name of the role
  MEMBER FUNCTION get_role_name RETURN VARCHAR2,

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
CREATE OR REPLACE TYPE XS$ROLE_GRANT_LIST AS VARRAY(1000) OF XS$ROLE_GRANT_TYPE;
/

-- Package XS_PRINCIPAL contains procedures and functions to create, update,
-- and delete principals.
CREATE OR REPLACE PACKAGE XS_PRINCIPAL AUTHID CURRENT_USER AS

-- Public constants  
-- The following constants define the user's status.
  ACTIVE          CONSTANT PLS_INTEGER := 1;
  INACTIVE        CONSTANT PLS_INTEGER := 2;
  UNLOCK          CONSTANT PLS_INTEGER := 3;
  EXPIRED         CONSTANT PLS_INTEGER := 4;
  LOCKED          CONSTANT PLS_INTEGER := 5;

-- The following constants define dynamic role scope.
  SESSION_SCOPE   CONSTANT PLS_INTEGER := 0;
  REQUEST_SCOPE   CONSTANT PLS_INTEGER := 1;

-- The following constants define the Verifier type.
  XS_SHA512       CONSTANT PLS_INTEGER := 2 ;
  XS_SALTED_SHA1  CONSTANT PLS_INTEGER := 1 ;

-- Enable log based replication for this package
  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Principal creation APIs.
  PROCEDURE create_user (
    name            IN VARCHAR2,    
    schema          IN VARCHAR2    := NULL,
    status          IN PLS_INTEGER := ACTIVE,                     
    start_date      IN TIMESTAMP WITH TIME ZONE := NULL,
    end_date        IN TIMESTAMP WITH TIME ZONE := NULL,
    guid            IN RAW         := NULL,
    external_source IN VARCHAR2    := NULL,
    description     IN VARCHAR2    := NULL,
    acl             IN VARCHAR2    := NULL);

  PROCEDURE create_role (
    name            IN VARCHAR2,
    enabled         IN BOOLEAN  := FALSE,
    start_date      IN TIMESTAMP WITH TIME ZONE:= NULL,
    end_date        IN TIMESTAMP WITH TIME ZONE:= NULL,
    guid            IN RAW      := NULL,
    external_source IN VARCHAR2 := NULL,
    description     IN VARCHAR2 := NULL);

  PROCEDURE create_dynamic_role (
    name            IN VARCHAR2,
    duration        IN PLS_INTEGER := NULL,
    scope           IN PLS_INTEGER := SESSION_SCOPE,
    description     IN VARCHAR2    := NULL,
    acl             IN VARCHAR2    := NULL);

-- Grant a role to a principal
  PROCEDURE grant_roles (
    grantee        IN VARCHAR2,
    role           IN VARCHAR2,
    start_date     IN TIMESTAMP WITH TIME ZONE:= NULL,
    end_date       IN TIMESTAMP WITH TIME ZONE:= NULL);

-- Grant a list of roles to a principal
  PROCEDURE grant_roles (
    grantee   IN VARCHAR2,
    role_list IN XS$ROLE_GRANT_LIST);

-- Revoke all roles from a principal.
  PROCEDURE revoke_roles (
    grantee IN VARCHAR2);

-- Revoke a role from a principal
  PROCEDURE revoke_roles (
    grantee IN VARCHAR2,
    role    IN VARCHAR2);

-- Revoke a list of roles from a principal
  PROCEDURE revoke_roles (
    grantee      IN VARCHAR2,
    role_list    IN XS$NAME_LIST);

-- Add a proxy user to a lightweight user.
-- proxy_user will proxy to and act on behalf of target_user.
-- If the target_roles is null, only xspublic and xsswitch 
-- default roles will be enable for proxy user.
  PROCEDURE add_proxy_user (
    target_user  IN VARCHAR2,
    proxy_user   IN VARCHAR2,
    target_roles IN XS$NAME_LIST);

-- Add proxy user to a target user with all with all default enabled 
-- roles of target user. 
  PROCEDURE add_proxy_user (
    target_user  IN VARCHAR2,
    proxy_user   IN VARCHAR2);

-- Add a proxy user to db user
  PROCEDURE add_proxy_to_dbuser (
     database_user IN VARCHAR2,
     proxy_user    IN VARCHAR2,
     is_external   IN BOOLEAN := FALSE);

-- Remove a proxy user from db user
  PROCEDURE remove_proxy_from_dbuser (
    database_user IN VARCHAR2,
    proxy_user    IN VARCHAR2);

-- Remove all existing proxy users from a target user.
  PROCEDURE remove_proxy_users (
    target_user IN VARCHAR2);

-- Remove a proxy user from a target user.
  PROCEDURE remove_proxy_users (
    target_user IN VARCHAR2,
    proxy_user  IN VARCHAR2);

-- Update effective date of a user/role.
  PROCEDURE set_effective_dates (
    principal  IN VARCHAR2,
    start_date IN TIMESTAMP WITH TIME ZONE:= NULL,
    end_date   IN TIMESTAMP WITH TIME ZONE:= NULL);

-- Update the duration of a dynamic role.
  PROCEDURE set_dynamic_role_duration (
    role      IN VARCHAR2,
    duration  IN PLS_INTEGER);

-- Update the scope attribute of a dynamic role
  PROCEDURE set_dynamic_role_scope (
    role  IN VARCHAR2,
    scope IN PLS_INTEGER);

-- Enables/disables the role by default. This API only works on regular roles.
  PROCEDURE enable_by_default (
    role      IN VARCHAR2,
    enabled   IN BOOLEAN := TRUE);

-- Enables/disables all directly granted roles for a user by default.
-- This API only works on users.
 PROCEDURE enable_roles_by_default (
    user      IN VARCHAR2,
    enabled   IN BOOLEAN := TRUE);

-- Update the schema that a lightweight user owns. Only apply for LW user.
  PROCEDURE set_user_schema (
    user    IN VARCHAR2,
    schema  IN VARCHAR2);

-- Set GUID. The guid only can be set if the principal is from an external
-- source and the previous guid is null.
  PROCEDURE set_guid (
    principal IN VARCHAR2,
    guid      IN RAW);

-- Set/modify the user status that a lightweight user owns.
  PROCEDURE set_user_status (
    user   IN VARCHAR2,
    status IN PLS_INTEGER);

-- Set the description of a principal.
  PROCEDURE set_description (
    principal     IN VARCHAR2,
    description   IN VARCHAR2);

-- Set ACL
  PROCEDURE set_acl (
    principal IN VARCHAR2, 
    acl       IN VARCHAR2);

-- Set profile
  PROCEDURE set_profile(
    user      IN VARCHAR2,
    profile   IN VARCHAR2);

-- Set password.
  PROCEDURE set_password (
    user       IN VARCHAR2,
    password   IN VARCHAR2,
    type       IN PLS_INTEGER := XS_SHA512,
    opassword  IN VARCHAR2 := NULL);
    PRAGMA SUPPLEMENTAL_LOG_DATA(set_password, NONE);

-- set_verifier Wrapper.
  PROCEDURE set_verifier (
    user      IN VARCHAR2,
    verifier  IN VARCHAR2,
    type      IN PLS_INTEGER := XS_SHA512);
    PRAGMA SUPPLEMENTAL_LOG_DATA(set_verifier, NONE);

-- Delete the principal.
  PROCEDURE delete_principal (
    principal     IN VARCHAR2,
    delete_option IN PLS_INTEGER:=XS_ADMIN_UTIL.DEFAULT_OPTION);

END XS_PRINCIPAL;

/
show errors;

@?/rdbms/admin/sqlsessend.sql
