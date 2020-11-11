Rem
Rem $Header: rdbms/admin/dbmscrs.sql /main/2 2014/02/20 12:45:52 surman Exp $
Rem
Rem dbmscrs.sql
Rem
Rem Copyright (c) 2013, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscrs.sql - Simple Sql that can be used before dictionary
Rem                    is upgraded.
Rem
Rem    DESCRIPTION
Rem      Simple Sql that is used in prvtcr.sql and before the database is
Rem      fully upgraded.
Rem
Rem    NOTES
Rem      No Dependencies in this SQL only simple SQL that can be called
Rem      from C Scripts.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jerrede     02/04/13 - Support CDB Upgrades.
Rem    jerrede     02/04/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmscrs.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmscrs.sql
Rem    SQL_PHASE: DBMSCRS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cdstrt.sql
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem -------------------------------------------------------------------------
Rem DBMS REGISTRY PACKAGE
Rem -------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry_simple AS

FUNCTION  is_db_consolidated RETURN BOOLEAN;

FUNCTION  is_db_root         RETURN BOOLEAN;

FUNCTION  is_db_pdb          RETURN BOOLEAN;

FUNCTION  is_db_pdb_seed     RETURN BOOLEAN;

END dbms_registry_simple;
/

show errors


@?/rdbms/admin/sqlsessend.sql
