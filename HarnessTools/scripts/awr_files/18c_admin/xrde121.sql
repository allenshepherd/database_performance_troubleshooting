Rem
Rem $Header: rdbms/admin/xrde121.sql /st_rdbms_18.0/1 2017/11/28 09:52:41 surman Exp $
Rem
Rem xrde121.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrde121.sql - XDB RDBMS Dependents Downgrade to 12.1
Rem
Rem    DESCRIPTION
Rem      This script contains actions for downgrading to 12.1
Rem
Rem    NOTES
Rem     
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrde121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrde121.sql 
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrddwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      11/21/17 - XbranchMerge surman_bug-26281129 from main
Rem    surman      11/17/17 - 26281129: Support for new release model
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE DOWNGRADE
Rem    jorgrive    10/14/16 - 24784365: LCR XML: use dbms_pdb.convert_to_local 
Rem    amunnoli    10/02/16 - Bug 24667675:Rather than delete and re-register
Rem                           TSDP XML Schemas, use dbms_pdb.convert_to_local
Rem    surman      09/22/16 - 23113885: Post patching support
Rem    amunnoli    09/12/16 - Bug 24626291: Delete TSDP XML SCHEMA
Rem    raeburns    08/03/16 - Add XRD 12.2 up/down scripts
Rem    surman      07/21/16 - 23705955: patch_descriptor back to CLOB
Rem    surman      07/20/16 - 23170620: Add patch_directory
Rem    surman      07/14/16 - 22539225: Recreate constraint only if downgrading
Rem                           to 12.1.0.1
Rem    surman      06/21/16 - 22694961: Add datapatch_role
Rem    surman      03/27/16 - 22359063: Clear patch_descriptor column
Rem    surman      08/21/15 - 20772435: SQL registry changes to XDB safe
Rem                           scripts
Rem    raeburns    11/21/14 - XRD release-specific script
Rem    raeburns    11/21/14 - Created
Rem

Rem ========================================================================
Rem Downgrade from subsequent releases
Rem ========================================================================

@@xrde122.sql

Rem ========================================================================
Rem BEGIN Downgrade to 12.1
Rem ========================================================================

Rem ========================================================================
Rem BEGIN TSDP changes
Rem ========================================================================

-- Bug 24667675: Rather than deleting and re-registering the TSDP XML Schemas
-- to address invalid objects issue after downgrade a PDB to 12.1.0.2, use 
-- dbms_pdb.convert_to_local procedure to convert ALL TSDP Common Object types
-- to Local (as they were in 12.1.0.2).

DECLARE
  con_id    VARCHAR2(100);
  con_name  VARCHAR2(128);
  stmt      VARCHAR2(1000);
  obj_name  VARCHAR2(128);
  namespace NUMBER;
  type      cursor_type is ref cursor;
  query_crs cursor_type;

BEGIN
  
  con_id := sys_context('USERENV', 'CON_ID');
  con_name := sys_context('USERENV', 'CON_NAME');
  if (con_id <> 0) AND (con_name <> 'CDB$ROOT') then
    stmt := ' select object_name, namespace from dba_objects ' ||
            ' where owner = ''SYS'' and OBJECT_TYPE =''TYPE''' ||
            ' and SHARING = ''METADATA LINK'''  ||
            ' and (object_name like ''%ORATSDP%'' )';

    open query_crs for stmt;
    loop
      fetch query_crs into obj_name, namespace;
      exit when query_crs%NOTFOUND ;

      begin
        sys.dbms_pdb.convert_to_local('SYS', obj_name, namespace);
      exception when others then
        null;
      end;
    end loop;
    close query_crs;
  end if;
END;
/
       
Rem ========================================================================
Rem END TSDP changes
Rem ========================================================================

Rem *************************************************************************
Rem BEGIN 18774852, 17665117 & 17277459:
Rem Recreate the constraint on registry$sqlpatch to reflect original 12.1.0.1
Rem columns and drop the package and view.  The package and/or view will be
Rem recreated when catrelod is run in the downgraded database, and will not be
Rem invalid before we get there (because it does not exist).
Rem This allows the PDB plug in checks in the downgraded database to
Rem work properly.
Rem *************************************************************************
DECLARE
  prev_version varchar2(30);
BEGIN
  SELECT prv_version INTO prev_version FROM registry$
    WHERE cid = 'CATPROC';

  IF prev_version < '12.1.0.2' THEN
    -- 22539225: Only recreate the constraint if we are downgrading to 12.1.0.1
    -- not 12.1.0.2
    EXECUTE IMMEDIATE
      'ALTER TABLE registry$sqlpatch DROP CONSTRAINT registry$sqlpatch_pk';
    EXECUTE IMMEDIATE
      'ALTER TABLE registry$sqlpatch ADD
         (CONSTRAINT registry$sqlpatch_pk
            PRIMARY KEY (patch_id, action, action_time))';
  END IF;
END;
/

Rem 23113885: Restore size of status column.  The table has been truncated
Rem by this point so we do not need to worry about existing data.
alter table registry$sqlpatch modify (status varchar2(15));


Rem 20772435: We don't need to change bundle_data back to XMLType, since
Rem both 12.2 and 12.1.0.2.0 have it as XMLType.  

Rem 23705955: Drop patch_descriptor column and change it to CLOB.  It's always
Rem CLOB in 12.1.0.2.
BEGIN
  EXECUTE IMMEDIATE 
    'alter table registry$sqlpatch drop column patch_descriptor';
  EXECUTE IMMEDIATE
    'alter table registry$sqlpatch add (patch_descriptor CLOB)';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode = -904 THEN
      null;
    ELSE
      raise;
    END IF;
END;
/

Rem 23170620: Clear patch_directory column
Rem 26281129: Catch ORA-942 as the table may not exist if we have upgraded
Rem from 11.2
BEGIN
  EXECUTE IMMEDIATE
    'UPDATE registry$sqlpatch SET patch_directory = NULL';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode = -942 THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

DROP PACKAGE dbms_sqlpatch;
DROP PUBLIC SYNONYM dbms_sqlpatch;

DROP VIEW dba_registry_sqlpatch;
DROP PUBLIC SYNONYM dba_registry_sqlpatch;

DROP VIEW cdb_registry_sqlpatch;
DROP PUBLIC SYNONYM CDB_registry_sqlpatch;

Rem *************************************************************************
Rem END 18774852, 17665117 & 17277459
Rem *************************************************************************

Rem *************************************************************************
Rem 22694961: Drop datapatch role
Rem *************************************************************************
DECLARE
  cnt NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO cnt
    FROM dba_roles
    WHERE role = 'DATAPATCH_ROLE';

  IF cnt != 0 THEN
    EXECUTE IMMEDIATE 'DROP ROLE datapatch_role';
  END IF;
END;
/

Rem *************************************************************************
Rem 24784365: convert LCR XML Schema to local
Rem *************************************************************************

DECLARE
    con_id    VARCHAR2(100);
    con_name  VARCHAR2(128);
    stmt      VARCHAR2(1000);
    obj_name  VARCHAR2(128);
    namespace NUMBER;
    type      cursor_type is ref cursor;
    query_crs cursor_type;
BEGIN
    con_id := sys_context('USERENV', 'CON_ID');
    con_name := sys_context('USERENV', 'CON_NAME');
    IF (con_id <> 0) AND (con_name <> 'CDB$ROOT') THEN
      stmt := ' select o.name, o.namespace from SYS.OBJ$ o, ' ||
            '   sys.user$ u ' ||
            ' where u.name = ''SYS'' and u.user# = o.owner# ' ||
            ' and o.name in (''LCR_ANYDATA_T'', ' ||
            ' ''LCR_COLUMN_VALUE_T'', ''LCR_DATETIME_FORMAT_T'', ' ||
            ' ''LCR_EXTRA_ATTRIBUTE_T'', ''LCR_EXTRA_ATTRIBUTE_VALUES_T'', ' ||
            ' ''LCR_EXTRA_ATTRIBUTE_VALUE_T'', ''LCR_NEW_VALUES_T'', ' ||
            ' ''LCR_OLD_NEW_VALUE_T'', ''LCR_OLD_VALUES_T'', ''ROW_LCR_T'', ' ||
            ' ''DDL_LCR_T'')';

      OPEN query_crs FOR stmt;
      LOOP
        FETCH query_crs INTO obj_name, namespace;
        EXIT WHEN query_crs%NOTFOUND;        

        BEGIN
          sys.dbms_pdb.convert_to_local('SYS', obj_name, namespace);
        EXCEPTION WHEN OTHERS THEN
           NULL;
        END;

      END LOOP;
    END IF;
END;
/

Rem ========================================================================
Rem END Downgrade to 12.1
Rem ========================================================================

Rem ========================================================================
Rem END xrde121.sql
Rem ========================================================================

