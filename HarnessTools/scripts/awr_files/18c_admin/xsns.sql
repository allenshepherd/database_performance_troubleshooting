Rem
Rem $Header: rdbms/admin/xsns.sql /main/9 2015/08/19 11:54:51 raeburns Exp $
Rem
Rem xsns.sql
Rem
Rem Copyright (c) 2009, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsns.sql - XS Namespace Template adminstrative interface
Rem
Rem    DESCRIPTION
Rem      XS_NAMEPSCE package for namespace template adminstrative interface
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsns.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsns.sql
Rem SQL_PHASE: XSNS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Bug 21322727: Use FORCE for types with only type dependents
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    minx        02/14/12 - Namespace Privilege Enhancement
Rem    yiru        08/04/11 - Admin APIs revision
Rem    yiru        07/07/11 - Admin Sec Prj enhancement: Add Invoker rights 
Rem                           package wrapper
Rem    yanlili     05/16/11 - Project 36762: Add log based replication and 
Rem                           rolling upgrade support at package level
Rem    snadhika    07/08/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Type definition for namespace template attribute
CREATE OR REPLACE TYPE XS$NS_ATTRIBUTE FORCE AS OBJECT (

-- Member Variables

-- Name of the namespace template attribute
-- Must be unique within a namespace template
-- Cannot be null
name              VARCHAR2(4000),

-- Default value assigned to the attribute
default_value     VARCHAR2(4000),

-- Trigger events associated with the attribute
-- Allowed values are :
-- 0 : NO_EVENT
-- 1 : FIRST_READ_EVENT
-- 2 : UPDATE_EVENT
-- 3 : FIRST_READ_PLUS_UPDATE_EVENT
attribute_events  NUMBER,

-- Constructor function
CONSTRUCTOR FUNCTION XS$NS_ATTRIBUTE
                    (name             IN VARCHAR2,
                     default_value    IN VARCHAR2 := NULL,
                     attribute_events IN NUMBER := 0)
                     RETURN SELF AS RESULT,

-- Return the name of the attribute
MEMBER FUNCTION GET_NAME RETURN VARCHAR2,

-- Return the default value of the attribute
MEMBER FUNCTION GET_DEFAULT_VALUE RETURN VARCHAR2,

-- Return the trigger events associated with attribute
MEMBER FUNCTION GET_ATTRIBUTE_EVENTS RETURN NUMBER,

-- Mutator procedures

-- Set the default value for the attribute
MEMBER PROCEDURE SET_DEFAULT_VALUE(default_value IN VARCHAR2),

-- Associate trigger events to the attribute
MEMBER PROCEDURE SET_ATTRIBUTE_EVENTS(attribute_events IN NUMBER)
);
/

show errors;

CREATE OR REPLACE TYPE XS$NS_ATTRIBUTE_LIST AS VARRAY(1000) OF XS$NS_ATTRIBUTE;
/

show errors;

-- Package XS_NS_TEMPLATE contains procedures and functions to create, update,
-- and delete namespace template.

CREATE OR REPLACE PACKAGE XS_NAMESPACE AUTHID CURRENT_USER AS

-- Attribute event
NO_EVENT                     CONSTANT PLS_INTEGER := 0;
FIRSTREAD_EVENT              CONSTANT PLS_INTEGER := 1;
UPDATE_EVENT                 CONSTANT PLS_INTEGER := 2;
FIRSTREAD_PLUS_UPDATE_EVENT  CONSTANT PLS_INTEGER := 3;

-- Enable log based replication for this package
PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO);

-- Document creation API. Only name is mandatory input.
PROCEDURE CREATE_TEMPLATE
         (name          IN VARCHAR2,          
          attr_list     IN XS$NS_ATTRIBUTE_LIST := NULL,
          schema        IN VARCHAR2 := NULL,
          package       IN VARCHAR2 := NULL,
          function      IN VARCHAR2 := NULL,
          acl           IN VARCHAR2 := 'SYS.NS_UNRESTRICTED_ACL',
          description   IN VARCHAR2 := NULL
          );

-- Set handler for attribute events
PROCEDURE SET_HANDLER
          (template IN VARCHAR2,
           schema   IN VARCHAR2,
           package  IN VARCHAR2,
           function IN VARCHAR2
           );

-- Add a attribute to the namespace template
PROCEDURE ADD_ATTRIBUTES
          (template          IN VARCHAR2,
           attribute         IN VARCHAR2,
           default_value     IN VARCHAR2 := NULL,
           attribute_events  IN PLS_INTEGER := XS_NAMESPACE.NO_EVENT);

-- Add a list of attributes to the namespace template
PROCEDURE ADD_ATTRIBUTES
          (template    IN VARCHAR2,
           attr_list   IN XS$NS_ATTRIBUTE_LIST);

-- Remove all attributes to the namespace template
PROCEDURE REMOVE_ATTRIBUTES
          (template    IN VARCHAR2);

-- Remove a single attribute from the namespace template
PROCEDURE REMOVE_ATTRIBUTES
          (template    IN VARCHAR2,
           attribute   IN VARCHAR2);

-- Remove a list of attribute from the namespace template
PROCEDURE REMOVE_ATTRIBUTES
          (template     IN VARCHAR2,
           attr_list    IN XS$LIST);

-- Set description
PROCEDURE SET_DESCRIPTION
          (template          IN VARCHAR2,
           description       IN VARCHAR2);

-- Delete the namespace template
PROCEDURE DELETE_TEMPLATE
          (template          IN VARCHAR2,
           delete_option     IN PLS_INTEGER:=XS_ADMIN_UTIL.DEFAULT_OPTION);

END XS_NAMESPACE;
/

show errors;


@?/rdbms/admin/sqlsessend.sql
