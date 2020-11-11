Rem
Rem $Header: rdbms/admin/dbmsedu.sql /main/8 2017/09/20 15:58:47 brwolf Exp $
Rem
Rem dbmsedu.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsedu.sql - Package header for DBMS_EDITION
Rem
Rem    DESCRIPTION
Rem     This file contains the public interface for the Edition API.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsedu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsedu.sql
Rem SQL_PHASE: DBMSEDU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    brwolf      08/30/17 - add Clean_Unusable_Editions procedure
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sylin       09/26/12 - Add invalid_edition exception
Rem    traney      08/15/12 - 14407652: add compare_edition
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    traney      09/06/11 - 25695: add Set_Null_Column_Values_To_Expr api
Rem    achoi       08/09/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_editions_utilities AUTHID CURRENT_USER AS 
---------------------------------------------------------------------
-- Overview
-- This pkg implements the Edition API, which provides helper function
-- for edition related operations
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS with execute access granted to PUBLIC.
-- It runs with invokers rights, i.e., with the security profile of
-- the caller.
--------------------

-- EXCEPTION
  insuf_priv exception;
  pragma exception_init(insuf_priv, -38817);

  missing_tab exception;
  pragma exception_init(missing_tab, -942);

  invalid_edition exception;
  pragma exception_init(invalid_edition, -38802);

  -- The relationship between any two editions can be determined by the
  -- following return values
  IDENTICAL  constant integer := 0;
  ANCESTOR   constant integer := 1;
  DESCENDENT constant integer := 2;
  UNRELATED  constant integer := 3;
-- PUBLIC FUNCTION

  /* Given the table name, set the all the Editioning views in all editions
     to read-only or read write.

     NOTE:
       User must have the following privileges:
         1. owner of the table or has ALTER ANY TABLE system privileges
         2. "USE" object privilege on all the editions which the views are
            definied.       

     PARAMETERS:
       table_name - the base table of the editioning views
       owner      - the base table schema. The default (or null) is the current
                    schema.
       read_only  - true if set the views to read-only; false (or null) will
                    set the views to read/write. Default is true.

     EXCEPTIONS:
       INSUF_PRIV exception will be raised if the user doesn't have the above
       privileges.
  */
  PROCEDURE set_editioning_views_read_only(
                 table_name IN VARCHAR2,
                 owner      IN VARCHAR2 DEFAULT NULL,
                 read_only  IN BOOLEAN  DEFAULT TRUE);

  /* 
    Procedure: Set_Null_Column_Values_To_Expr
    
    Replaces null values in a replacement column with the value of an
    expression. The expression evaluation cost is deferred to future updates
    and queries.
    
    Parameters:
    
      table_name - A potentially schema-qualified table name.
      column_name - The name of the column to be updated.
      expression - An expression composed of columns in the same table,
                   constants, and SQL functions.
   */
  PROCEDURE Set_Null_Column_Values_To_Expr(table_name IN VARCHAR2,
                                           column_name IN VARCHAR2,
                                           expression IN VARCHAR2);

  /* 
    Function: compare_edition
    
    Compare the two given editions to determine their parent/child relation.
    
    Parameters:
    
      ed1objn - The object number of the first edition to be compared.
      ed2objn - The object number of the second edition to be compared.
    
    Returns:
    
      The relationship between the editions.
        IDENTICAL  if the editions are the same.
        ANCESTOR   if the first edition is an ancestor of the second edition.
        DESCENDENT if the first edition is a descendant of the second edition.
        UNRELATED  if the editions are not related.

     EXCEPTIONS:
       INVALID_EDITION exception will be raised if either ed1objn or ed2objn
       is an invalid edition object number.
   */
  FUNCTION compare_edition(ed1objn IN INTEGER, ed2objn IN INTEGER)
    RETURN INTEGER;

  /*
    Procedure: Clean_Unusable_Editions

    Formally drops covered objects in unusable editions, and drops empty
    unusable editions if possible.

    NOTE:
      User must have the privilege DROP ANY EDITION

    EXCEPTIONS:
      INSUF_PRIV exception will be raised if the user doesn't have the above
      privilege.
  */
  PROCEDURE Clean_Unusable_Editions;
END dbms_editions_utilities;
/
GRANT EXECUTE ON sys.dbms_editions_utilities TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_editions_utilities
  FOR sys.dbms_editions_utilities;

@?/rdbms/admin/sqlsessend.sql
