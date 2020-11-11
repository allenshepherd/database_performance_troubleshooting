Rem
Rem $Header: rdbms/admin/dbmstsdpm.sql /main/4 2014/02/20 12:45:47 surman Exp $
Rem
Rem dbmstsdpm.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstsdpm.sql - DBMS TSDP Management
Rem
Rem    DESCRIPTION
Rem      The file has the PL/SQL package declaration to manage the Sensitive
Rem      Data List and Sensitive Column Types for Transparent Sensitive Data
Rem      Management
Rem
Rem    NOTES
Rem      This script is called by dbmstsdp.sql.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmstsdpm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmstsdpm.sql
Rem SQL_PHASE: DBMSTSDPM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmstsdp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add Add SQL patching tags
Rem    dgraj       02/23/12 - Enhancement 13485095: Add force push flag for
Rem                           IMPORT_DISCOVERY_RESULT
Rem    dgraj       10/17/11 - Add internal Datapump package
Rem    dgraj       09/16/11 - Proj 32079, Transparent Sensitive Data
Rem                           Protection
Rem    dgraj       09/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- DBMS_TSDP_MANAGE package is used to manage the list of sensitive columns
-- and sensitive types in the database.

CREATE OR REPLACE PACKAGE dbms_tsdp_manage AUTHID CURRENT_USER AS 

DB     CONSTANT INTEGER := 1;
ADM    CONSTANT INTEGER := 2;
CUSTOM CONSTANT INTEGER := 3;

-- IMPORT_DISCOVERY_RESULT : Used to import Sensitive Columns for an ADM
--                           instance as a Clob.
-- Parameters:
-- discovery_result - The list of sensitive columns, along with the optional 
--                    list of (the definitions of) the Sensitive Column Types 
--                    as a clob.        
-- discovery_source - The source of the import. The discovery_source 
--                    identifies the list of imported sensitive columns. 
--                    In case of ADM, this should be the ADM name.
-- force            - TRUE/FALSE.TRUE implies the result will be imported even
--                    though some of the columns are already identified as 
--                    sensitive. The attributes of these duplicate columns
--                    are overwritten with the attributes corresponding to this
--                    import. Default is FALSE.

PROCEDURE IMPORT_DISCOVERY_RESULT (
 discovery_result                IN CLOB,
 discovery_source                IN VARCHAR2,
 force                           IN BOOLEAN DEFAULT FALSE);

-- IMPORT_DISCOVERY_RESULT: Used to import Sensitive Columns for an ADM 
--                          instance as XMLType.
-- Parameters:
-- discovery_result - The list of sensitive columns, along with the optional 
--                    list of (the definitions of) the Sensitive Column Types 
--                    in XML format        
-- discovery_source - The source of the import. The discovery_source 
--                    identifies the list of imported sensitive columns. 
--                    In case of ADM, this should be the ADM name.
-- force            - TRUE/FALSE.TRUE imploes the result will be imported even
--                    though some of the columns are already identified as 
--                    sensitive. The attributes of these duplicate columns
--                    are overwritten with the attributes corresponding to this
--                    import.

PROCEDURE IMPORT_DISCOVERY_RESULT (
 discovery_result                IN XMLTYPE,
 discovery_source                IN VARCHAR2,
 force                           IN BOOLEAN DEFAULT FALSE);

-- REMOVE_DISCOVERY_RESULT: Used to remove Sensitive Columns corresponding to
--                          an ADM instance
-- Parameters:
-- discovery_source: The source of the import. In case of ADM, this should
--                   be the ADM name, the results of which is to be removed.

PROCEDURE REMOVE_DISCOVERY_RESULT (
 discovery_source                IN VARCHAR2);

-- ADD_SENSITIVE_COLUMN: Used to add a Column to the Sensitive Column List.
-- Parameters:
-- schema_name    - Schema to which the column belongs.
-- table_name     - Table containing the column.
-- column_name    - The sensitive column name.
-- sensitive_type - The identifier of the Sensitive Column Type.
-- user_comment   - User comment regarding the sensitive column.

PROCEDURE ADD_SENSITIVE_COLUMN (
 schema_name                     IN VARCHAR2,
 table_name                      IN VARCHAR2,
 column_name                     IN VARCHAR2,
 sensitive_type                  IN VARCHAR2,
 user_comment                    IN VARCHAR2 default NULL);

-- ALTER_SENSITIVE_COLUMN : Used to alter the Sensitive Type and/or the Comment
--                          of a Column in the Sensitive Column List.
-- Parameters:
-- schema_name    - Schema to which the column belongs.
-- table_name     - Table containing the column.
-- column_name    - The sensitive column name.
-- sensitive_type - The identifier of the Sensitive Column Type.
-- user_comment   - User comment regarding the sensitive column.

PROCEDURE ALTER_SENSITIVE_COLUMN (
 schema_name                     IN VARCHAR2,
 table_name                      IN VARCHAR2,
 column_name                     IN VARCHAR2,
 sensitive_type                  IN VARCHAR2,
 user_comment                    IN VARCHAR2 default NULL);

-- DROP_SENSITIVE_COLUMN : Used to remove a Column from the Sensitive Column
--                         List.
-- Parameters:    
-- schema_name - Schema to which the column belongs.
-- table_name  - Table containing the column.
-- column_name - The sensitive column to be removed.

PROCEDURE DROP_SENSITIVE_COLUMN (
 schema_name                     IN VARCHAR2 DEFAULT '%',
 table_name                      IN VARCHAR2 DEFAULT '%',
 column_name                     IN VARCHAR2 DEFAULT '%');

-- IMPORT_SENSITIVE_TYPES : Used to import a list of Sensitive Column Types
--                          from a source as a Clob.
-- Parameters:   
-- sensitive_types - The list of Sensitive Column Types as a clob.
-- source          - The source of the import. The source identifies the list of
--                   imported Sensitive Column Types. In case of ADM, this
--                   should be the ADM name.

PROCEDURE IMPORT_SENSITIVE_TYPES (
 sensitive_types                 IN CLOB,
 source                          IN VARCHAR2);

-- IMPORT_SENSITIVE_TYPES : Used to import a list of Sensitive Column Types
--                          from a source as XMLType.
-- Parameters:   
-- sensitive_types - The list of Sensitive Column Types in XML Format.
-- source          - The source of the import. The source identifies the list of
--                   imported Sensitive Column Types. In case of ADM, this
--                   should be the ADM name.

PROCEDURE IMPORT_SENSITIVE_TYPES (
 sensitive_types                 IN XMLTYPE,
 source                          IN VARCHAR2);

-- ADD_SENSITIVE_TYPE : Used to create and add a Sensitive Column Type to the
--                      list Sensitive Column Types in the database.
-- Parameters:     
-- sensitive_type - Name of the Sensitive Column Type.
-- user_comment        - User comment regarding the sensitive column.

PROCEDURE ADD_SENSITIVE_TYPE (
 sensitive_type                  IN VARCHAR2,
 user_comment                    IN VARCHAR2 DEFAULT NULL);

-- DROP_SENSITIVE_TYPE : Used to drop a Sensitive Column Type from the list 
--                       Sensitive Column Types in the database.
-- Parameters:  
-- sensitive_type - Name of the Sensitive Column Type that is to be dropped.

PROCEDURE DROP_SENSITIVE_TYPE (
  sensitive_type                 IN VARCHAR2);

-- DROP_SENSITIVE_TYPE_SOURCE : Used to drop Sensitive Column Types
--                              corresponding to a Source from the list
--                              Sensitive Column Types in the database.
-- Parameters:
-- source_name - Name of the Source.

PROCEDURE DROP_SENSITIVE_TYPE_SOURCE (
  source                          IN VARCHAR2);

END dbms_tsdp_manage;
/

create public synonym dbms_tsdp_manage for dbms_tsdp_manage
/

-- Internal Datapump support package for TSDP

CREATE OR REPLACE PACKAGE tsdp$datapump AS

PROCEDURE INSTANCE_CALLOUT_IMP(
  obj_name         in      varchar2,
  obj_schema       in      varchar2,
  obj_type         in      number,
  prepost          in      pls_integer,
  action           out     varchar2,
  alt_name         out     varchar2);
  
END tsdp$datapump;
/

grant execute on sys.tsdp$datapump to execute_catalog_role
/

-- Function to check if xml validation is required or not.
-- Returns TRUE if required, FALSE otherwise.

CREATE OR REPLACE FUNCTION tsdp$validation_check 
  RETURN BOOLEAN AUTHID DEFINER
IS
  role    varchar2(20);
  primary boolean;
BEGIN

  BEGIN
    primary := FALSE;
    select database_role into role from sys.v$database;

    IF role = 'PRIMARY' THEN
      primary := TRUE;
    END IF;
 
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  RETURN primary;
END;
/

create public synonym tsdp$validation_check for tsdp$validation_check
/

grant execute on tsdp$validation_check to public
/


@?/rdbms/admin/sqlsessend.sql
