Rem
Rem $Header: rdbms/admin/catfinal.sql /main/2 2016/02/12 14:16:45 akruglik Exp $
Rem
Rem catfinal.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catfinal.sql - final stage of object, privilege, etc. creation
Rem
Rem    DESCRIPTION
Rem      This script implements final stage of creating DB objects, granting 
Rem      privleges, etc.  Statements run in this script may be generated 
Rem      dynamically to make use of obhects created/privileges granted/etc in 
Rem      the rest of the scripts
Rem
Rem    NOTES
Rem      No objects should be created (or altered or dropped) or privileges 
Rem      granted (or revoked) after this script is invoked.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catfinal.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akruglik    02/09/16 - LRG 19252712: do not invoke pdbdba.sq
Rem    akruglik    01/22/16 - script that must be run after all DBMS objects
Rem                           have been created, privileges have been granted,
Rem                           etc.
Rem    akruglik    01/22/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

@?/rdbms/admin/sqlsessend.sql
