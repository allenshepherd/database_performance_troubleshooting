Rem
Rem $Header: rdbms/admin/dbmsxdbschmig.sql /main/6 2015/05/06 04:18:22 tojhuan Exp $
Rem
Rem dbmsxdbschmig.sql
Rem
Rem Copyright (c) 2012, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdbschmig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem     this package defines structures to migrate an xml schema from a user
Rem     'a' to a user 'b' without moving the data.
Rem     For now this is an undocumented package. It was requested to enable 
Rem     editioning 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxdbschmig.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxdbschmig.sql
Rem SQL_PHASE: DBMSXDBSCHMIG 
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/xdbptrl1.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     05/06/15 - 20920043: adjust the lengths for string variables
Rem                           to 128 for those holding usernames
Rem    aketkar     04/29/14 - sql patch metadata seed
Rem    qyu         03/18/13 - Common start and end scripts
Rem    bhammers    01/14/13 - add cleanup procedure
Rem    bhammers    06/14/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PACKAGE sys.xdb_migrateschema IS

-- Procedures to move an xml schema from user A to user B
-- see impl for comments
PROCEDURE moveSchemas;
PROCEDURE cleanup;
end xdb_migrateschema;
/
show errors;


BEGIN
 execute immediate ('DROP TABLE xdb$moveSchemaTab');
 EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
 execute immediate ('CREATE TABLE xdb$moveSchemaTab (schema_url VARCHAR2(4000), 
                                schemaOwnerFrom VARCHAR2(128),
                                schemaOwnerTo VARCHAR2(128),
                                schema CLOB,
  CONSTRAINT xdb$moveSchemaTabC1 UNIQUE (schema_url, schemaOwnerFrom))
');
 EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

show errors;


@?/rdbms/admin/sqlsessend.sql
