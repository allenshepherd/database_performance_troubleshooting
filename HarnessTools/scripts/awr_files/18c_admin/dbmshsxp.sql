Rem
Rem $Header: rdbms/admin/dbmshsxp.sql /main/4 2014/02/20 12:45:43 surman Exp $
Rem
Rem dbmshsxp.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmshsxp.sql - export action for SQL tuning base
Rem
Rem    DESCRIPTION
Rem      Implements export action which is automatically called by export
Rem      to export SQL tuning base. Generates Pl/SQL to create sql profiles,
Rem      which is stored by export in the export file, later to be invoked by 
Rem      import.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmshsxp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmshsxp.sql
Rem SQL_PHASE: DBMSHSXP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catsqltv.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    mramache    06/23/03 - sql profiles
Rem    aime        04/25/03 - aime_going_to_main
Rem    mramache    01/15/03 - mramache_5955_stb
Rem    mramache    01/13/03 - get rid of hard-tabs
Rem    atsukerm    12/23/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbmshsxp AUTHID CURRENT_USER AS

-- Generate PL/SQL for procedural actions
 FUNCTION system_info_exp(prepost IN PLS_INTEGER,
                          connectstring OUT VARCHAR2,
                          version IN VARCHAR2,
                          new_block OUT PLS_INTEGER)
 RETURN VARCHAR2;

END dbmshsxp;
/
CREATE OR REPLACE PUBLIC SYNONYM dbmshsxp
   for sys.dbmshsxp
/
GRANT EXECUTE ON dbmshsxp TO EXECUTE_CATALOG_ROLE
/

@?/rdbms/admin/sqlsessend.sql
