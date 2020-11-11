Rem
Rem $Header: rdbms/admin/catumftv.sql /main/3 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catumftv.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catumftv.sql - Catalog for Unified Manageability Framework (UMF) 
Rem                     Users, Tables and Views.
Rem
Rem    DESCRIPTION
Rem      Creates the UMF schema and views. 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catumftv.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catumftv.sql 
Rem    SQL_PHASE: CATUMFTV
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    msabesan    09/12/15 - bug 21826062: move catumfusr.sql to catpdeps.sql
Rem    spapadom    06/18/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create UMF schema. 
@@catumftb

--Create UMF views. 
@@catumfvw

@?/rdbms/admin/sqlsessend.sql
