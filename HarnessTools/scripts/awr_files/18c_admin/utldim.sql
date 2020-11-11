Rem
Rem $Header: rdbms/admin/utldim.sql /main/3 2017/05/28 22:46:12 stanaya Exp $
Rem
Rem utldim.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utldim.sql - UTiLity for dbms_dimension
Rem
Rem    DESCRIPTION
Rem      1. It creates a table DIMENSION_EXCEPTIONS IN the schema
Rem         of the current user.  The table is used
Rem         by DBMS_DIMENSION.VALIDATE_DIMENSION() to store
Rem         the results.  
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utldim.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utldim.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    mxiao       12/27/02 - mxiao_dbms_dimension
Rem    mxiao       12/19/02 - Created
Rem

CREATE TABLE dimension_exceptions
  (statement_id    VARCHAR2(30),            -- Client-supplied unique statement identifier
   owner           VARCHAR2(128) NOT NULL,   -- Owner of the dimension 
   table_name      VARCHAR2(128) NOT NULL,   -- Name of the base table
   dimension_name  VARCHAR2(128) NOT NULL,   -- Name of the dimension
   relationship    VARCHAR2(11) NOT NULL,   -- Name of the relationship that cause the dimension
                                            --   invalid, e.g. ATTRIBUTE, FOREIGN KEY, CHILD OF, etc
   bad_rowid       ROWID        NOT NULL)   -- Rowid of the 'bad' row.
/
