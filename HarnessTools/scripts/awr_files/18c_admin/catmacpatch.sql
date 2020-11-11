Rem
Rem
Rem catmacpatch.sql
Rem
Rem Copyright (c) 2008, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmacpatch.sql - Patches mandatory access control configuration schema and packages.
Rem
Rem    DESCRIPTION
Rem      This is the main patching script for patching the database objects
Rem      in Oracle Database vault.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA, no other passwords are needed for this
Rem      patching script.
Rem      This runs a subset of the scripts called by catmac (install driver)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/07/16 - 25191154: Add SQL metadata
Rem    sanbhara    02/02/11 - Bug Fix 10225918.
Rem    jsamuel     02/03/09 - remove set echo
Rem    jsamuel     09/26/08 - DV patching script
Rem    jsamuel     09/26/08 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catmacpatch.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catmacpatch.sql
Rem    SQL_PHASE:CATMACPATCH
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA

@@?/rdbms/admin/sqlsessstart.sql

WHENEVER SQLERROR CONTINUE;

-- bug 6938028: Database Vault Protected Schema.
-- Insert the rows into metaview$ for the real Data Pump types.
@@catmacdd.sql

-- Load MACSEC Factor Convenience Functions
@@dvmacfnc.plb

-- Load underlying DVSYS objects
@@catmacc.sql

-- Load MAC packages.
@@catmacp.sql
@@prvtmacp.plb

-- tracing view
-- grants on DV objects to DV roles
-- create public synonyms for DV objects
@@catmacg.sql

-- Load MAC roles.
@@catmacr.sql

--Bug 10225918 - removed call to catmacd.sql.


-- create the DV login and DDL triggers
-- establish DV audit policy
@@catmact.sql

commit;

@?/rdbms/admin/sqlsessend.sql

