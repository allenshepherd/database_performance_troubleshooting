Rem
Rem $Header: rdbms/admin/xsrs.sql /main/7 2014/02/20 12:45:54 surman Exp $
Rem
Rem xsrs.sql
Rem
Rem Copyright (c) 2009, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsrs.sql - XS Roleset adminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_ROLESET package for role set adminstrative interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsrs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsrs.sql
Rem SQL_PHASE: XSRS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        07/07/11 - Amin Sec Prj enhancement: Add Invoker rights
Rem                           package wrapper
Rem    yiru        05/17/11 - Admin Sec Prj2: Change to definer rights package
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and
Rem                           rolling upgrade support at package level
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE XS_ROLESET AUTHID CURRENT_USER AS

-- Enable log based replication for this package
PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Roleset creation API
  PROCEDURE create_roleset (
    name        IN VARCHAR2,
    role_list   IN XS$NAME_LIST:=NULL,
    description IN VARCHAR2:=NULL);

-- Add a role to the role set
  PROCEDURE add_roles (
    role_set       IN VARCHAR2,
    role           IN VARCHAR2);

-- Add a list of roles to the role set
  PROCEDURE add_roles (
    role_set  IN VARCHAR2,
    role_list IN XS$NAME_LIST);

-- Remove all roles from the role set
  PROCEDURE remove_roles (
    role_set IN VARCHAR2);

-- Remove a role from the role set
  PROCEDURE remove_roles (
    role_set IN VARCHAR2,
    role     IN VARCHAR2);

-- Remove a list of roles from the role set
  PROCEDURE remove_roles (
    role_set  IN VARCHAR2,
    role_list IN XS$NAME_LIST);

-- Set the description of a roleset
  PROCEDURE set_description (
    role_set    IN VARCHAR2,
    description IN VARCHAR2);

-- Delete the role set. A roleset is not referenced anywhere. So no delete 
-- option is needed.
  PROCEDURE delete_roleset (
    role_set IN VARCHAR2);


END XS_ROLESET;
/

show errors;

@?/rdbms/admin/sqlsessend.sql
