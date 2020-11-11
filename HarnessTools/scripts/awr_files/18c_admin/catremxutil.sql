Rem
Rem $Header: rdbms/admin/catremxutil.sql /main/4 2017/04/07 17:26:54 qyu Exp $
Rem
Rem catremxutil.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catremxutil.sql - remove xutil packages 
Rem
Rem    DESCRIPTION
Rem     remove xutil packages and views
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catremxutil.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catremxutil.sql
Rem SQL_PHASE: CATREMXUTIL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         04/04/17 - 25070346: drop synonym first
Rem    jcanovi     07/28/15 - 21473765: Also drop synonyms
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    bhammers    07/22/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop PUBLIC SYNONYM DBMS_XMLSTORAGE_MANAGE;

drop PACKAGE XDB.DBMS_XMLSTORAGE_MANAGE;

drop PUBLIC SYNONYM DBMS_XMLSCHEMA_ANNOTATE;

drop PACKAGE XDB.DBMS_XMLSCHEMA_ANNOTATE;

drop PUBLIC SYNONYM DBMS_XDB_CONSTANTS;
  
drop PACKAGE XDB.DBMS_XDB_CONSTANTS;


@?/rdbms/admin/sqlsessend.sql
