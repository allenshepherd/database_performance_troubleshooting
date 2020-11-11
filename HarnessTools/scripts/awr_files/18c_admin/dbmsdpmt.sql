Rem
Rem $Header: rdbms/admin/dbmsdpmt.sql /main/2 2015/10/20 03:48:25 sogugupt Exp $
Rem
Rem dbmsqomt.sql
Rem
Rem Copyright (c) 2014, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsqomt.sql - dbms_dpmttab package specification
Rem
Rem    DESCRIPTION
Rem      Creation of dbms_dpmttab package specification 
Rem
Rem    NOTES - Package body is in:  
Rem      rdbms/src/client/datapump/dml/pump/prvtdpmt.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsqomt.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sogugupt    08/27/15 - Bug:19814527 Add procedures to remove the 
Rem                           datapump orphaned jobs
Rem    mjangir     11/18/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Creation of package dbms_dpmttab
CREATE OR REPLACE PACKAGE dbms_master_table AUTHID CURRENT_USER AS

-- Provides basic export info
PROCEDURE export_info(mt_name in VARCHAR2);

-- Provides basic import info
PROCEDURE import_info(mt_name in VARCHAR2);

-- Provides details of objects left to export, import
PROCEDURE objects_left_to_import(mt_name in VARCHAR2);
 
-- Provides details of table objects left to import
PROCEDURE table_objects_left_to_import(mt_name in VARCHAR2);

-- Provides remaining table data info
PROCEDURE import_remaining_tables(mt_name in VARCHAR2);

-- Get max creation levels for remaining tables
PROCEDURE import_max_creation_level(mt_name in VARCHAR2);

-- Get next creation levels for remaining tables
PROCEDURE import_next_creation_level(mt_name in VARCHAR2);

FUNCTION FORMAT_TABLE_DATA_MSG(
  table_data_size       IN      NUMBER ) RETURN VARCHAR2;

-- drop orphaned jobs that were failed due to some error 
PROCEDURE drop_orphaned_jobs;

-- drop orphaned jobs that were created before a certain date
PROCEDURE drop_orphaned_jobs_by_date(DATE1 IN DATE);

END dbms_master_table;
/

show error
---@?/rdbms/admin/sqlsessend.sql
