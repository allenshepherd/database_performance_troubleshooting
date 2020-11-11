Rem
Rem $Header: rdbms/admin/mgdrelod.sql /main/4 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem mgdrelod.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      mgdrelod.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/mgdrelod.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/mgdrelod.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       05/25/06 - reload mgd
Rem    hgong       05/25/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

@catmgd.sql

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

