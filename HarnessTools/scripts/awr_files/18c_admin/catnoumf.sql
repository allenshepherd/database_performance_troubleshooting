Rem
Rem $Header: rdbms/admin/catnoumf.sql /main/1 2014/09/10 23:16:54 spapadom Exp $
Rem
Rem catnoumf.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catnoumf.sql - CATalog NO Unified Manageability Framework (UMF).
Rem
Rem    DESCRIPTION
Rem      Drops the UMF schema.
Rem
Rem    NOTES
Rem      Run as SYSDBA.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoumf.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spapadom    05/06/14 - Created
Rem

DROP TABLE umf$_link;
DROP TABLE umf$_service;
DROP TABLE umf$_registration;
DROP TABLE umf$_topology;
DROP VIEW  umf_topology;





