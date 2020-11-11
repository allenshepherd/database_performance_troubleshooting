Rem
Rem $Header: rdbms/admin/catwrrvw.sql /main/4 2014/02/20 12:45:45 surman Exp $
Rem
Rem catwrrvw.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catwrrvw.sql - Catalog script for
Rem                     the Workload Capture and Replay views 
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary views for the
Rem      Workload Capture and Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrvw.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrvw.sql
Rem SQL_PHASE: CATWRRVW
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kmorfoni    11/03/11 - Create views for workload intelligence
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - add REPLAY dict
Rem    veeve       01/25/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Create the common (shared by Capture and Replay) views
Rem and the Capture infrastructure views
@@catwrrvwc.sql

Rem
Rem Create the Replay infrastructure view
@@catwrrvwp.sql

Rem 
Rem Create the views required for workload intelligence
@@catwrrwivw.sql

@?/rdbms/admin/sqlsessend.sql
