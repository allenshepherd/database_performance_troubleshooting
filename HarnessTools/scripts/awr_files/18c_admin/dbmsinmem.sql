Rem
Rem dbmsinmem.sql
Rem
Rem Copyright (c) 2013, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsinmem.sql - DBMS_INMEMORY Package
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsinmem.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsinmem.plb
Rem SQL_PHASE: DBMSINMEM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aumishra    04/30/16 - Bug 23177430: Add ime_drop_expressions
Rem    miglees     04/16/16 - Bug 22980084: Move deallocate_versions
Rem                           from DBMS_INMEMORY_ADMIN
Rem    miglees     04/16/16 - Bug 22980084: Make package invokers rights
Rem    amylavar    04/20/15 - Procedure to recode the column store to 
Rem                           the latest version of the dictionary
Rem    nmukherj    04/09/15 - external procedure for IMCU old version garbage
Rem                           collection
Rem    pkapil      09/29/14 - bug 19702021 : extending execution of repopulate
Rem                           to any user with select privilege
Rem    kdnguyen    08/26/14 - Bug 19510008: move enabling/enabling fs to 
Rem                           dbms_inmemory_admin package. 
Rem    siteotia    06/12/14 - forward merge of bug-18604119
Rem    apfwkr      06/06/14 - Backport siteotia_bug-18781641 from main.
Rem    siteotia    05/23/14 - Bug 18781641:Added the PL/SQL procedures
Rem                           for enabling and disabling faststart.
Rem    siteotia    05/16/14 - Bug 18604119:Add procedure for populate      
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    miglees     08/01/13 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_inmemory authid current_user as

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  -------------------------------------------------------------------------
  -- PROCEDURE repopulate
  -------------------------------------------------------------------------
  -- Description :
  --   Repopulate the in-memory representation of the specified
  --   table/partition if an in-memory representation exists.
  --
  -- Input parameters:
  --   schema_Name    - User owning the object
  --   table_name     - Name of the table whose in-memory representation
  --                    is to be repopulated.
  --   partition_name - If partition name is not null, 
  --                    then repopulate the specified partition 
  --   force          - Repopulate required with force(TRUE/FALSE).

  procedure repopulate(
        schema_name      in varchar2,
        table_name       in varchar2,
        partition_name   in varchar2 DEFAULT NULL,
        force            in boolean  DEFAULT FALSE);
  
  -------------------------------------------------------------------------
  -- PROCEDURE populate
  -------------------------------------------------------------------------
  -- Description :
  --   Populate the in-memory representation of the specified
  --   table/partition if an in-memory representation exists.
  --
  -- Input parameters:
  --   schema_Name    - User owning the object
  --   table_name     - Name of the table whose in-memory representation
  --                    is to be populated.
  --   partition_name - If partition name is not null, 
  --                    then repopulate the specified partition 

  procedure populate(
        schema_name      in varchar2,
        table_name       in varchar2,
        partition_name   in varchar2 DEFAULT NULL);

  -------------------------------------------------------------------------
  -- PROCEDURE segment_deallocate_versions
  -------------------------------------------------------------------------
  -- Description :
  --   Walk through the segment and deallocate in-memory extents for 
  --   old SMU and IMCU versions 
  --
  -- Input parameters:
  --   schema_Name    - User owning the object
  --   table_name     - Name of the table 
  --   partition_name - If partition name is not null, 
  --                    then work on  the specified partition 
  --   spcpressure    - If TRUE, will break retention of IMCUs

  procedure segment_deallocate_versions(
        schema_name      in varchar2,
        table_name       in varchar2,
        partition_name   in varchar2 DEFAULT NULL,
        spcpressure      in boolean DEFAULT FALSE);

  -------------------------------------------------------------------------
  -- PROCEDURE ime_drop_expressions
  -------------------------------------------------------------------------
  -- Description :
  --   Drop a particular SYS_IME expression or all SYS_IME expressions in 
  --   a table
  -- Input parameters:
  --   schema_Name    - Owner of the table
  --   table_name     - Table name
  --   column_name    - If column_name is NULL, then drop all SYS_IMEs in the
  --                    table, else just the requested column

  procedure ime_drop_expressions(
        schema_name      in varchar2,
        table_name       in varchar2,
        column_name      in varchar2 DEFAULT NULL);

end;
/

GRANT EXECUTE ON sys.dbms_inmemory TO PUBLIC;
/
create or replace public synonym dbms_inmemory for sys.dbms_inmemory
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_INMEMORY_LIB TRUSTED AS STATIC;
/

@?/rdbms/admin/sqlsessend.sql
