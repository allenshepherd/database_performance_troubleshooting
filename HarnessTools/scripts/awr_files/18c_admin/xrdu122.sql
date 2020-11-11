Rem
Rem $Header: rdbms/admin/xrdu122.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem xrdu122.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdu122.sql - XDB RDBMS Dependents Upgrade from 12.2
Rem
Rem    DESCRIPTION
Rem      This script contains actions for upgrading from 12.2
Rem
Rem    NOTES
Rem     
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdu122.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdu122.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrdupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      11/01/17 - 26281129: Support for new release model
Rem    pyam        10/18/17 - 26966759: check for no REGISTRY$SQLPATCH_TEMP
Rem    sanagara    04/26/17 - 25804457: CLOB to XMLTYPE conversion in
Rem                           registry$sqlpatch
Rem    surman      12/13/16 - 25230447: Post patching support
Rem    raeburns    08/03/16 - Created
Rem

Rem ======================================================
Rem BEGIN XRD upgrade from 12.2
Rem ======================================================

Rem *************************************************************************
Rem Begin registry$sqlpatch changes
Rem *************************************************************************

Rem 26281129: Rename existing registry table.  A new version will be created
Rem (along with the dba_registry_sqlpatch view) when catsqlreg.sql is called
Rem during the catalog creation.

SET SERVEROUTPUT ON

DECLARE
  table_name_122 VARCHAR2(30);
  constraint_name_122 VARCHAR2(30);
BEGIN
  SELECT 'reg$sqlpatch$122$' || TO_CHAR(systimestamp, 'YYMMDDHH24MI'),
         'reg$sqlpatch_pk$122$' || TO_CHAR(systimestamp, 'YYMMDDHH24MI')
    INTO table_name_122, constraint_name_122
    FROM sys.dual;

  dbms_output.put_line('Renaming registry$sqlpatch to ' || table_name_122);

  -- We need to rename the index and constraint first
  BEGIN
    EXECUTE IMMEDIATE
      'ALTER INDEX registry$sqlpatch_pk RENAME TO ' || constraint_name_122;
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
    '  RENAME CONSTRAINT registry$sqlpatch_pk TO ' || constraint_name_122;
  EXECUTE IMMEDIATE
    'ALTER TABLE registry$sqlpatch RENAME TO ' || table_name_122;
END;
/

SET SERVEROUTPUT OFF

Rem *************************************************************************
Rem End registry$sqlpatch changes
Rem *************************************************************************

Rem ======================================================
Rem END XRD upgrade from 12.2
Rem ======================================================

Rem ======================================================
Rem Upgrade from subsequent releases
Rem ======================================================

--uncomment for next release
--@@xrduNNN.sql

Rem ======================================================
Rem END xrdu122.sql
Rem ======================================================

