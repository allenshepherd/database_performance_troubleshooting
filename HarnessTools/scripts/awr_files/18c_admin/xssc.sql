Rem
Rem $Header: rdbms/admin/xssc.sql /main/10 2015/08/19 11:54:51 raeburns Exp $
Rem
Rem xssc.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xssc.sql - XS Security Class sdminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_SECURITY_CLASS package for security class adminstrative interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xssc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xssc.sql
Rem SQL_PHASE: XSSC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    taahmed     02/10/12 - remove defacl
Rem    taahmed     12/16/11 - implied priv identified under scope of sec class
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        07/06/11 - Admin Sec Prj enhancement: Add Invoker rights 
Rem                           package wrapper
Rem    yiru        05/17/11 - Admin Sec Prj2: Change to definer rights package
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and 
Rem                           rolling upgrade support at package level
Rem    yiru        09/24/09 - Add exception
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Type for privilege
CREATE OR REPLACE TYPE XS$PRIVILEGE FORCE AS OBJECT (

-- Name of the privilege
name             VARCHAR2(261),

-- Implied privileges
implied_priv_list XS$NAME_LIST,

-- Description for the privilege
description      VARCHAR2(4000),

-- Constructor Function
CONSTRUCTOR FUNCTION XS$PRIVILEGE
                    (name              IN VARCHAR2,                     
                     implied_priv_list IN XS$NAME_LIST := NULL,
                     description       IN VARCHAR2 := NULL)
                     RETURN SELF AS RESULT,

-- Get name of the privilege
MEMBER FUNCTION GET_NAME RETURN VARCHAR2,
-- Get description of the privilege
MEMBER FUNCTION GET_DESCRIPTION RETURN VARCHAR2,
-- get implied privilege
MEMBER FUNCTION GET_IMPLIED_PRIVILEGES RETURN XS$NAME_LIST,

-- Set description for the privilege
MEMBER PROCEDURE SET_DESCRIPTION (description IN VARCHAR2),

-- Set a list of implied privileges for the aggregate privilege
MEMBER PROCEDURE SET_IMPLIED_PRIVILEGES (implied_priv_list IN XS$NAME_LIST)
);
/

show errors;

CREATE OR REPLACE TYPE XS$PRIVILEGE_LIST AS VARRAY(1000) OF XS$PRIVILEGE;
/

show errors;


CREATE OR REPLACE PACKAGE XS_SECURITY_CLASS AUTHID CURRENT_USER AS

-- Enable log based replication for this package
PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Create a security class
PROCEDURE CREATE_SECURITY_CLASS (
          name          IN VARCHAR2,          
          priv_list     IN XS$PRIVILEGE_LIST,          
          parent_list   IN XS$NAME_LIST:= NULL,
          description   IN VARCHAR2:= NULL
          ) ;

-- Add a parent security class
PROCEDURE ADD_PARENTS (
          sec_class IN VARCHAR2,
          parent    IN VARCHAR2
          );

-- Add a list of parent security classes
PROCEDURE ADD_PARENTS (
          sec_class   IN VARCHAR2,
          parent_list IN XS$NAME_LIST
          );

-- Remove all parent security classes
PROCEDURE REMOVE_PARENTS (
          sec_class IN VARCHAR2
          );

-- Remove a parent security class
PROCEDURE REMOVE_PARENTS (
          sec_class IN VARCHAR2,
          parent    IN VARCHAR2
          );

-- Remove a list of parent security classes
PROCEDURE REMOVE_PARENTS (
          sec_class     IN VARCHAR2,
          parent_list   IN XS$NAME_LIST
          );

-- Add a privilege to existing list of privileges (if any) of the
-- security class
PROCEDURE ADD_PRIVILEGES (
          sec_class         IN VARCHAR2,
          priv              IN VARCHAR2,          
          implied_priv_list IN XS$NAME_LIST:=NULL,
          description       IN VARCHAR2:=NULL              
          );

-- Add a list of privileges to existing list of privileges (if any) of the
-- security class
PROCEDURE ADD_PRIVILEGES (
          sec_class     IN VARCHAR2,
          priv_list     IN XS$PRIVILEGE_LIST
          );

-- Set privileges for the security class
PROCEDURE REMOVE_PRIVILEGES (
          sec_class     IN VARCHAR2
          );

-- Remove a privilege from the security (if the privilege is present)
PROCEDURE REMOVE_PRIVILEGES (
          sec_class   IN VARCHAR2,
          priv        IN VARCHAR2
          );

-- Remove a list of privileges from the security (if the privileges are
-- present)
PROCEDURE REMOVE_PRIVILEGES (
          sec_class       IN VARCHAR2,
          priv_list       IN XS$NAME_LIST
          );

-- Add implied privilege (single)
PROCEDURE ADD_IMPLIED_PRIVILEGES (
          sec_class       IN VARCHAR2,
          priv            IN VARCHAR2,
          implied_priv    IN VARCHAR2
          );

-- Add implied privileges (multiple)
PROCEDURE ADD_IMPLIED_PRIVILEGES (
          sec_class         IN VARCHAR2,
          priv              IN VARCHAR2,
          implied_priv_list IN XS$NAME_LIST
          );

-- Remove implied privilege (single)
PROCEDURE REMOVE_IMPLIED_PRIVILEGES (
          sec_class         IN VARCHAR2,
          priv            IN VARCHAR2,
          implied_priv    IN VARCHAR2
          );

-- Remove implied privileges (multiple)
PROCEDURE REMOVE_IMPLIED_PRIVILEGES (
          sec_class         IN VARCHAR2,
          priv              IN VARCHAR2,
          implied_priv_list IN XS$NAME_LIST
          );

-- Remove all implied privileges
PROCEDURE REMOVE_IMPLIED_PRIVILEGES (
          sec_class       IN VARCHAR2,
          priv            IN VARCHAR2
          );

-- Set description of the security class
PROCEDURE SET_DESCRIPTION (
          sec_class      IN VARCHAR2,
          description    IN VARCHAR2
          );

-- Delete the security class
PROCEDURE DELETE_SECURITY_CLASS (
          sec_class       IN VARCHAR2,
          delete_option   IN PLS_INTEGER:= XS_ADMIN_UTIL.DEFAULT_OPTION
          );

END XS_SECURITY_CLASS;
/

show errors;


@?/rdbms/admin/sqlsessend.sql
