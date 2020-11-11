Rem
Rem $Header: rdbms/admin/catnoclust.sql /main/2 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnoclust.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoclust.sql - Remove CLUSTer database specific components
Rem
Rem    DESCRIPTION
Rem      Remove all cluster database specific views
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoclust.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoclust.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    eyho        08/16/11 - remove RAC components
Rem    eyho        08/16/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

EXECUTE dbms_registry.removing('RAC');

DROP public synonym v$ges_latch;
DROP public synonym v$ges_statistics;
DROP public synonym v$ges_convert_local;
DROP public synonym v$ges_convert_remote;
DROP public synonym v$ges_traffic_controller;
DROP public synonym v$ges_resource;
DROP public synonym gv$ges_statistics;
DROP public synonym gv$ges_latch;
DROP public synonym gv$ges_convert_local;
DROP public synonym gv$ges_convert_remote;
DROP public synonym gv$ges_traffic_controller;
DROP public synonym gv$ges_resource;
DROP public synonym ext_to_obj;
REVOKE select on ext_to_obj_view from select_catalog_role;
REVOKE select on file_ping from select_catalog_role;
REVOKE select on file_lock from select_catalog_role;
DROP view file_lock;
DROP view ext_to_obj_view;
DROP view file_ping;
DROP PACKAGE dbms_clustdb;

EXECUTE dbms_registry.removed('RAC');
