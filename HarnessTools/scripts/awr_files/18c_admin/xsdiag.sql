Rem
Rem $Header: rdbms/admin/xsdiag.sql /main/4 2014/02/20 12:45:46 surman Exp $
Rem
Rem xsdiag.sql
Rem
Rem Copyright (c) 2009, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xsdiag.sql - Header file for xs_diag package.
Rem
Rem    DESCRIPTION
Rem      This package is used to diagnose potential inconsistencies in triton.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/xsdiag.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/xsdiag.sql
Rem SQL_PHASE: XSDIAG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    weihwang    05/29/12 - change package to definer rights, change 
Rem                           xs$validation_table to on commit preserve rows
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    weihwang    08/28/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE XS_DIAG AUTHID CURRENT_USER AS

  -- Exeption when maximum number of messages allowed is set to be less than 1.
  ERR_INVALID_MSG_MAX CONSTANT NUMBER := -20028;
  EXCP_INVALID_MSG_MAX EXCEPTION;
  PRAGMA EXCEPTION_INIT(EXCP_INVALID_MSG_MAX, -20028);


/******************************************************************************
                       Validation Routines       

Input: 
  name               The name of object to be validated.
  error_limit        The maximum number of errors that may be stored in the 
                     validation table.
  policy             The name of the policy to be validated
  table_owner        The owner of the table/view.
  table_name         The name of the table/view.

Output:
  Return TRUE if the object is valid, otherwise return FALSE.

  For each identified inconsistency, a row will be inserted into 
  XS$VALIDATION_TABLE until the maximum number of inconisistencies that may be
  store has been reached.

  VALIDATE_DATA_SECURITY() provides three styles of policy validation:
  1. When policy is not null and table_name is null, the function will 
     validate the policy against all the tables that the policy is applied to.
     Note, when table_name is null, table_owner will be ignored even if it is 
     not null.

  2. When both policy and table_name are not null, the function will validate
     the policy against the specific table. If table_owner is not provided, the
     current schema will be used. 
 
  3. When policy is null and table name is not null, the function will validate
     all the policies applied to the table against the table. If table_owner is
     not provided, the current schema will be used. 

******************************************************************************/


  -- Validate principal.
  FUNCTION validate_principal(name         IN VARCHAR2, 
                              error_limit  IN PLS_INTEGER := 1) 
    RETURN BOOLEAN;                  

  -- Validate roleset.
  FUNCTION validate_roleset(name         IN VARCHAR2, 
                            error_limit  IN PLS_INTEGER := 1) 
    RETURN BOOLEAN;                  

  -- Validate security class.
  FUNCTION validate_security_class(name         IN VARCHAR2, 
                                   error_limit  IN PLS_INTEGER := 1)
    RETURN BOOLEAN;   
  
  -- Validate acl.
  FUNCTION validate_acl(name         IN VARCHAR2, 
                        error_limit  IN PLS_INTEGER := 1) 
    RETURN BOOLEAN;                  

  -- Validate data security policy against a specific table.
  FUNCTION validate_data_security(policy         IN VARCHAR2 := NULL, 
                                  table_owner    IN VARCHAR2 := NULL,
                                  table_name     IN VARCHAR2 := NULL,
                                  error_limit    IN PLS_INTEGER := 1) 
    RETURN BOOLEAN;

  -- Validate namespace template.
  FUNCTION validate_namespace_template(name         IN VARCHAR2,
                                       error_limit  IN PLS_INTEGER := 1)
    RETURN BOOLEAN;

  -- Validate an entire workspace.
  FUNCTION validate_workspace(error_limit  IN PLS_INTEGER := 1)
    RETURN BOOLEAN;

END XS_DIAG;
/
show errors;

/*******************************************************************************

                             Validation Table

This is the table used to store the identified inconsistencies. The table will 
be truncated each time when a validation routine is called by user. 

code              The message code.
description       The description of the identified inconsistency.
object            The object where the inconsistency is identified. The whole
                  path that leads to the object in the validation is recorded. 
note              Additional information that may help user to identify the
                  inconsistency.

*******************************************************************************/
CREATE GLOBAL TEMPORARY TABLE XS$VALIDATION_TABLE (
  code           NUMBER,
  description    VARCHAR2(4000),
  object         VARCHAR2(4000),
  note           VARCHAR2(4000)                                                     
) ON COMMIT PRESERVE ROWS;

@?/rdbms/admin/sqlsessend.sql
