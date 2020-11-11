Rem
Rem $Header: rdbms/admin/initsjty.sql /main/1 2017/07/21 12:49:43 tojhuan Exp $
Rem
Rem initsjty.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      initsqljt.sql - initialization for sqlj types
Rem
Rem    DESCRIPTION
Rem      load java classes required for sqljtype validation 
Rem      and generation of helper classes.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/initsjty.sql
Rem    SQL_SHIPPED_FILE:
Rem    SQL_PHASE: INITSJTY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     07/21/17 - Bug 25515456: bring back package dbms_sqljtype
Rem    srirkris    10/10/13 - Add prvtsjty.plb and dbmssjty
Rem    varora      09/01/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

call sys.dbms_java.loadjava('-v -r rdbms/jlib/sqljtype.jar');

@@dbmssjty.sql
@@prvtsjty.plb

@?/rdbms/admin/sqlsessend.sql
