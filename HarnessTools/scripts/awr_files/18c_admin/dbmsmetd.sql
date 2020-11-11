Rem
Rem $Header: rdbms/admin/dbmsmetd.sql /main/4 2015/04/11 08:26:36 sdavidso Exp $
Rem
Rem dbmsmetd.sql
Rem
Rem Copyright (c) 2004, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     dbmsmetd.sql - Package header for DBMS_METADATA_DPBUILD.
Rem     NOTE - Package body is in:
Rem            rdbms/src/server/datapump/ddl/prvtmetd.sql
Rem    DESCRIPTION
Rem     This file contains the package header for DBMS_METADATA_DPBUILD,
Rem     an invoker's rights package that creates the data pump 
Rem     heterogeneous object types
Rem
Rem    FUNCTIONS / PROCEDURES
Rem 
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsmetd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsmetd.sql
Rem SQL_PHASE: DBMSMETD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdavidso    04/01/15 - lrg-15578500 - add set_debug()
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE DBMS_METADATA_DPBUILD AUTHID CURRENT_USER AS

---------------------------
-- PROCEDURES AND FUNCTIONS
--

-- SET_DEBUG: Set the internal debug switch.

 PROCEDURE set_debug( on_off IN BOOLEAN ); 

-- create procedures for various heterogeneous objects.

 PROCEDURE create_table_export;

 PROCEDURE create_schema_export;

 PROCEDURE create_database_export;

 PROCEDURE create_transportable_export;

END DBMS_METADATA_DPBUILD;
/
GRANT EXECUTE ON sys.dbms_metadata_dpbuild TO EXECUTE_CATALOG_ROLE; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_metadata_dpbuild
 FOR sys.dbms_metadata_dpbuild;



@?/rdbms/admin/sqlsessend.sql
