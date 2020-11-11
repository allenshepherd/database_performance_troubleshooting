Rem
Rem $Header: rdbms/admin/xrde122.sql /st_rdbms_18.0/2 2018/02/23 11:47:57 surman Exp $
Rem
Rem xrde122.sql
Rem
Rem Copyright (c) 2014, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrde122.sql - XDB RDBMS Dependents Downgrade to 12.2
Rem
Rem    DESCRIPTION
Rem      This script contains actions for downgrading to 12.2
Rem
Rem    NOTES
Rem     
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrde122.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrde122.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrddwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      02/21/18 - Backport surman_bug-27283029 from main
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      02/05/18 - 27283029: Add dba_registry_sqlpatch_ru_info
Rem    surman      11/01/17 - 26281129: Support for new release model
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    surman      12/13/16 - 25230447: Post patching support
Rem    raeburns    08/03/16 - Created
Rem

Rem ========================================================================
Rem Downgrade from subsequent releases
Rem ========================================================================

--uncomment for next release
--@@xrdeNNN.sql

Rem ========================================================================
Rem BEGIN Downgrade to 12.2
Rem ========================================================================


Rem *************************************************************************
Rem Begin registry$sqlpatch changes
Rem *************************************************************************

Rem 26281129: Rename existing registry table, and restore the most recent
Rem 12.2 version of the table, if one exists.  This way after downgrade any
Rem SQL patches that were installed prior to the upgrade will still be present
Rem in the SQL registry.  Note that if the binary state is different post
Rem downgrade than it was pre upgrade, this will not reflect the actual binary
Rem state post downgrade.  Either way, datapatch should be run after the
Rem downgrade is complete, as it should be run after any changes to the
Rem binaries in the oracle home.  The view (and 12.2 version of the table if
Rem needed) will be recreated when catsqlreg.sql is called during the catalog
Rem creation in the downgraded database.

SET SERVEROUTPUT ON

DECLARE
  table_name_181 VARCHAR2(30);
  constraint_name_181 VARCHAR2(30);
  table_name_122 VARCHAR2(30);
  constraint_name_122 VARCHAR2(30);
BEGIN
  SELECT 'reg$sqlpatch$181$' || TO_CHAR(systimestamp, 'YYMMDDHH24MI'),
         'reg$sqlpatch_pk$181$' || TO_CHAR(systimestamp, 'YYMMDDHH24MI')
    INTO table_name_181, constraint_name_181
    FROM sys.dual;

  dbms_output.put_line('Renaming registry$sqlpatch to ' || table_name_181);

  -- We need to rename the index and constraint first
  BEGIN
    EXECUTE IMMEDIATE
      'ALTER INDEX registry$sqlpatch_pk RENAME TO ' || constraint_name_181;
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -1418 THEN
        NULL;  -- Suppress 'index does not exist' error
      ELSE
        RAISE;
      END IF;
  END;

  EXECUTE IMMEDIATE
    'ALTER TABLE registry$sqlpatch' ||
    '  RENAME CONSTRAINT registry$sqlpatch_pk TO ' || constraint_name_181;
  EXECUTE IMMEDIATE
    'ALTER TABLE registry$sqlpatch RENAME TO ' || table_name_181;

  -- The 12.2 backups will have a timestamp so we can use MAX to determine the
  -- most recent one.
  SELECT MAX(name)
    INTO table_name_122
    FROM obj$
    WHERE name LIKE 'REG$SQLPATCH$122$%';

  SELECT MAX(name)
    INTO constraint_name_122
    FROM obj$
    WHERE name LIKE 'REG$SQLPATCH_PK$122$%';

  IF table_name_122 IS NOT NULL THEN
    -- Found one, rename it to registry$sqlpatch
    dbms_output.put_line('Renaming ' || table_name_122 || ' to registry$sqlpatch');
    BEGIN
      EXECUTE IMMEDIATE
        'ALTER INDEX ' || constraint_name_122 ||
        '  RENAME TO registry$sqlpatch_pk';
    EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode = -1418 THEN
          NULL;  -- Suppress 'index does not exist' error
        ELSE
          RAISE;
        END IF;
    END;

    EXECUTE IMMEDIATE
      'ALTER TABLE ' || table_name_122 || 
      '  RENAME CONSTRAINT ' || constraint_name_122 ||
      '  TO registry$sqlpatch_pk';
    EXECUTE IMMEDIATE
      'ALTER TABLE ' || table_name_122 ||
      '  RENAME TO registry$sqlpatch';
  END IF;
END;
/

Rem Drop both state tables used internally by dbms_sqlpatch.
Rem dbms_sqlpatch_files does not exist in 12.2, and because of the foreign key
Rem constraint the 12.2 attempt to drop it will fail, resulting in compilation
Rem errors.
DROP TABLE dbms_sqlpatch_files CASCADE CONSTRAINTS;
DROP TABLE dbms_sqlpatch_state CASCADE CONSTRAINTS;

Rem 27283029: Drop the ru_info table and views as well
DROP TABLE registry$sqlpatch_ru_info;
DROP VIEW dba_registry_sqlpatch_ru_info;
DROP PUBLIC SYNONYM dba_registry_sqlpatch_ru_info;
DROP VIEW cdb_registry_sqlpatch_ru_info;
DROP PUBLIC SYNONYM cdb_registry_sqlpatch_ru_info;

SET SERVEROUTPUT OFF

Rem *************************************************************************
Rem End registry$sqlpatch changes
Rem *************************************************************************

Rem ========================================================================
Rem END Downgrade to 12.2
Rem ========================================================================

Rem ========================================================================
Rem END xrde122.sql
Rem ========================================================================

