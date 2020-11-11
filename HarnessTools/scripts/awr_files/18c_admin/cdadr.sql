Rem
Rem $Header: rdbms/admin/cdadr.sql /main/1 2015/09/02 15:25:30 svaziran Exp $
Rem
Rem cdadr.sql
Rem
Rem Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdadr.sql - Catalog Automatic Diagnostic Repository (ADR) views
Rem
Rem    DESCRIPTION
Rem      ADR objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in ADR layer
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdadr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdadr.sql
Rem    SQL_PHASE: CDADR
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    svaziran    08/25/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem -- APPLICATION_TRACE_VIEWER role is needed so that users with this role
Rem -- could connect to the database and view application trace records
Rem
create role APPLICATION_TRACE_VIEWER;

Rem -- grants on v_$ views related to application trace data
grant select on v_$diag_app_trace_file to application_trace_viewer;
grant select on v_$diag_sql_trace_records to application_trace_viewer;
grant select on v_$diag_opt_trace_records to application_trace_viewer;
grant select on v_$diag_sess_sql_trace_records to application_trace_viewer;
grant select on v_$diag_sess_opt_trace_records to application_trace_viewer;

@?/rdbms/admin/sqlsessend.sql
