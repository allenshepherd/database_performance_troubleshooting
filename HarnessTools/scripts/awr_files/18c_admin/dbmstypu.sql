Rem
Rem $Header: rdbms/admin/dbmstypu.sql /main/7 2017/04/19 00:27:13 skabraha Exp $
Rem
Rem dbmstypu.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmstypu.sql - Type Utility
Rem
Rem    DESCRIPTION
Rem      Provides routines to compile all types and reset type version
Rem      during downgrade.
Rem
Rem    NOTES
Rem     This package must be executed by the DBA only.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmstypu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmstypu.sql
Rem SQL_PHASE: DBMSTYPU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    04/12/17 - deprecate dbms_type_utility procedures
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    skabraha    02/15/02 - add delete_constructor_keyword
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    thoang      06/27/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- I am removing all procedure from the package as they are no longer
-- in use and they have too many security holes to leave around. Keeping
-- the package for possible future use. 

CREATE OR REPLACE PACKAGE dbms_type_utility AS 

  --
  PROCEDURE none;
 

END dbms_type_utility;
/

CREATE OR REPLACE PUBLIC SYNONYM DBMS_TYPE_UTILITY FOR DBMS_TYPE_UTILITY;


@?/rdbms/admin/sqlsessend.sql
