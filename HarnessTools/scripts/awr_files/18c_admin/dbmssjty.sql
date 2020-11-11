Rem
Rem $Header: rdbms/admin/dbmssjty.sql /main/1 2017/07/21 12:49:43 tojhuan Exp $
Rem
Rem dbmssjty.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmssjty.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmssjty.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmssjty.sql
Rem    SQL_PHASE: DBMSSJTY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     07/21/17 - Bug 25515456: bring back package dbms_sqljtype
Rem    mmorsi      02/21/01 - Adding the validation of the class name.
Rem    varora      11/14/00 - missing /
Rem    varora      09/27/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_sqljtype AS

  FUNCTION VALIDATETYPE(typeName varchar2, schemaName varchar2) return number;

  FUNCTION VALIDATECLASS(supertoid RAW, schemaName varchar2, className varchar2) return number;

END dbms_sqljtype;
/

@?/rdbms/admin/sqlsessend.sql

