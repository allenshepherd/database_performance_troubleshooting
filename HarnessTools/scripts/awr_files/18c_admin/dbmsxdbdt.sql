Rem
Rem $Header: rdbms/admin/dbmsxdbdt.sql /main/1 2014/08/28 06:28:29 raeburns Exp $
Rem
Rem dbmsxdbdt.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdbdt.sql - DBMS XDB DataTypes
Rem
Rem    DESCRIPTION
Rem      Includes functions and procedures for XDB datatypes
Rem
Rem    NOTES
Rem      Moved from catxdbdt.sql to be reloaded by xdbrelod.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsxdbdt.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsxdbdt.sql 
Rem    SQL_PHASE: DBMSXDBDT
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbload.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    07/07/14 - create EXTNAME2INTNAME and INITXDBSCHEMA for reload
Rem    raeburns    07/07/14 - Created
Rem

@?/rdbms/admin/sqlsessstart.sql

Rem Function that creates the database schema object corr. to the root
Rem XDB schema.
create or replace procedure xdb.xdb$InitXDBSchema
 is language C name "INIT_XDBSCHEMA"
 library XMLSCHEMA_LIB;
/

Rem Function that converts an external schema name (URL) to
Rem the internal representation (XDxxxx). An optional schema owner
Rem name can be passed in. Of course, the executing user needs to
Rem have permissions to read the path corresponding to the URL.
create or replace function xdb.xdb$ExtName2IntName
  (schemaURL IN VARCHAR2, schemaOwner IN VARCHAR2 := '')
return varchar2 authid current_user deterministic
is external name "EXT2INT_NAME" library XMLSCHEMA_LIB with context
parameters (context, schemaURL OCIString, schemaOwner OCIString,
            return INDICATOR sb4, return OCIString);
/

grant execute on xdb.xdb$ExtName2IntName to public;

@?/rdbms/admin/sqlsessend.sql
