Rem
Rem $Header: rdbms/admin/dbmstsdpe.sql /main/7 2017/07/12 02:21:54 amunnoli Exp $
Rem
Rem dbmstsdpe.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstsdpe.sql - DBMS TSDP Enforcement
Rem
Rem    DESCRIPTION
Rem      This file has the PL/SQL package declaration to create, enable or 
Rem      apply Transparent Sensitive Data Protection policies.
Rem
Rem    NOTES
Rem      This script is called by dbmstsdp.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmstsdpe.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmstsdpe.sql
Rem SQL_PHASE: DBMSTSDPE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmstsdp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    07/07/17 - Bug 26370268: mark global varible as constant
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dgraj       08/13/13 - Bug #17304316: Support Unified Audit in TSDP
Rem    dgraj       08/10/13 - Bug #13716791: Support FGA in TSDP
Rem    dgraj       08/14/13 - Bug #13716803: Support Column Encryption in TSDP
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    dgraj       09/16/11 - Proj 32079, Transparent Sensitive Data
Rem                           Protection
Rem    dgraj       09/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_tsdp_protect AUTHID CURRENT_USER AS

DATATYPE CONSTANT INTEGER := 1 ;
LENGTH CONSTANT INTEGER := 2 ;
SCHEMA_NAME CONSTANT INTEGER := 3;
TABLE_NAME CONSTANT INTEGER := 4 ;

TSDP_PARAM_MAX CONSTANT INTEGER := 4000;

type FEATURE_OPTIONS is table of varchar2(4000) index by varchar2(30);

type POLICY_CONDITIONS is table of varchar2(4000) index by PLS_INTEGER; 

REDACT CONSTANT INTEGER := 1 ;
UNIFIED_AUDIT CONSTANT INTEGER := 2 ;
VPD CONSTANT INTEGER := 3 ;
COLUMN_ENCRYPTION CONSTANT INTEGER := 4 ;
FGA CONSTANT INTEGER := 5 ;

-- Bug 26370268: Mark the global variable as CONSTANT
tsdp$default_condition CONSTANT POLICY_CONDITIONS := POLICY_CONDITIONS();

-- ADD_POLICY : This procedure is used to create a Protection Policy.
-- Parameters:     
-- policy_name - Name of the Policy being created. The maximum length for this
--               identifier is M_IDEN. This follows the Oracle naming
--               convention.
-- security_feature - The Oracle Security Feature with which the policy is
--                    associated. Allowed values:
--                    DBMS_TSDP_PROTECT.REDACT
--                    DBMS_TSDP_PROTECT.VPD
--                    DBMS_TSDP_PROTECT.FGA
--                    DBMS_TSDP_PROTECT.COLUMN_ENCRYPTION             
-- policy_enable_options - This parameter should be initialized with the
--                         parameter-value pairs corresponding to the security
--                         feature.                
-- policy_apply_condition - This parameter should be initialized with the
--                          property-value pairs that must be satisfied in
--                          order to apply the corresponding
--                          policy_enable_options.
--                          This is an associative array with  Property as the
--                          key (PLS_INTEGER).
--                          Example:
--                example_policy_condition(<Property>)= <property_value>.
--                          Permissible values for Property are:
--                          DBMS_TSDP_PROPERTY.DATATYPE
--                          DBMS_TSDP_PROPERTY.LENGTH
--                          DBMS_TSDP_PROPERTY.PARENT_SCHEMA
--                          DBMS_TSDP_PROPERTY.PARENT_TABLE

PROCEDURE ADD_POLICY (
 policy_name             IN VARCHAR2, 
 security_feature        IN PLS_INTEGER,
 policy_enable_options   IN FEATURE_OPTIONS,
 policy_apply_condition  IN POLICY_CONDITIONS default tsdp$default_condition); 

-- ALTER_POLICY : This procedure can be used to alter an existing TSDP Policy.
-- Parameters:     
-- policy_name - Name of the Policy to alter.
-- policy_enable_options - This parameter should be initialized with the
--                         parameter-value pairs corresponding to the security
--                         feature.
-- policy_apply_condition - This parameter should be initialized with the
--                          property-value pairs that must be satisfied in
--                          order to apply the corresponding
--                          policy_enable_options.

PROCEDURE ALTER_POLICY (
 policy_name		 IN VARCHAR2,
 policy_enable_options   IN FEATURE_OPTIONS,
 policy_apply_condition  IN POLICY_CONDITIONS default tsdp$default_condition);

-- DROP_POLICY : The overloaded DBMS_TSDP_PROTECT.DROP_POLICY can be used to
--               drop a TSDP Policy or one of its Condition-Enable_Options
--               combinations.
--               The combination of Policy_Condition and Policy_Enable_Options
--               can be dropped from a TSDP Policy by giving the
--               policy_apply_condition parameter.
--               The Default Condition-Default Options combination can also be
--               dropped (if it exists for The Policy) by passing an empty 
--               associative array of type DBMS_TSDP_PROTECT.POLICY_CONDITION.
-- Parameters:
-- policy_name             - Name of the TSDP Policy that is to be dropped.
-- Policy_enable_condition - This parameter should be initialized with the
--                           property-value pairs.

PROCEDURE DROP_POLICY (
 policy_name             IN VARCHAR2,
 policy_apply_condition  IN POLICY_CONDITIONS);

PROCEDURE DROP_POLICY (
 policy_name             IN VARCHAR2);

-- ASSOCIATE_POLICY : This procedure can be used to associate/dis-associate a
--                    TSDP Policy with a Sensitive Column Type.
-- Parameters:
-- Policy_name - Name of the TSDP Policy.
-- Sensitive_type - Name of the Sensitive Column Type.
-- Associate - Associate or Dis-associate. TRUE implies Associate.

PROCEDURE ASSOCIATE_POLICY (
 policy_name             IN VARCHAR2,
 sensitive_type          IN VARCHAR2,
 associate               IN BOOLEAN DEFAULT TRUE);

-- ENABLE_PROTECTION_SOURCE : This procedure can be used to enable protection
--                            based on the source of truth for the sensitive
--                            columns.
-- Parameters:
-- discovery_sourcename - Name of the discovery source. This could be the ADM
--                        name or the database user.

PROCEDURE ENABLE_PROTECTION_SOURCE (
 discovery_source	IN VARCHAR2);

-- DISABLE_PROTECTION_SOURCE : This procedure can be used to disable protection
--                             based on the source of truth for the sensitive
--                             columns.
-- Parameters:
-- discovery_sourcename - Name of the discovery source. This could be the ADM
--                        name or the database user.

PROCEDURE DISABLE_PROTECTION_SOURCE (
 discovery_source       IN VARCHAR2);

-- ENABLE_PROTECTION_COLUMN : This procedure can be used to enable protection
--                            for columns.
-- Parameters:     
-- Schema_name - The name of the schema containing the column.
-- Table_name  - The table containing the column.          
-- column_name - The column name.
-- policy      - Optional policy name. If given, only this policy is enabled.

PROCEDURE ENABLE_PROTECTION_COLUMN (
  schema_name		IN VARCHAR2 default '%',
  table_name		IN VARCHAR2 default '%',
  column_name		IN VARCHAR2 default '%',
  policy                IN VARCHAR2 DEFAULT NULL);

-- DISABLE_PROTECTION_COLUMN : This procedure can be used to disable protection
--                             for columns.
-- Parameters:     
-- Schema_name - The name of the schema containing the column.
-- Table_name  - The table containing the column.          
-- column_name - The column name.
-- policy      - Optional policy name. If given, only this policy is disabled.

PROCEDURE DISABLE_PROTECTION_COLUMN (
  schema_name           IN VARCHAR2 default '%',
  table_name            IN VARCHAR2 default '%',
  column_name           IN VARCHAR2 default '%',
  policy                IN VARCHAR2 DEFAULT NULL);

-- ENABLE_PROTECTION_TYPE : This procedure can be used to enable protection
--                          for a Sensitive Column Type.
-- Parameters:
-- sensitive_type - Name of the Sensitive Column Type.

PROCEDURE ENABLE_PROTECTION_TYPE (
  sensitive_type	IN VARCHAR2);

-- DISABLE_PROTECTION_TYPE : This procedure can be used to disable protection
--                           for a Sensitive Column Type.
-- Parameters:
-- sensitive_type - Name of the Sensitive Column Type.

PROCEDURE DISABLE_PROTECTION_TYPE (
  sensitive_type        IN VARCHAR2);

END dbms_tsdp_protect;
/

create public synonym dbms_tsdp_protect for dbms_tsdp_protect
/



@?/rdbms/admin/sqlsessend.sql
