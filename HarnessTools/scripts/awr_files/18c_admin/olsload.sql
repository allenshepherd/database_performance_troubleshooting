Rem
Rem $Header: rdbms/admin/olsload.sql /main/3 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olsload.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsload.sql - Oracle Label Security packages/views LOAD script.
Rem
Rem    DESCRIPTION
Rem      This script is used to compile OLS packages and views after a
Rem      upgrade/downgrade. The dictionary objects are upgraded/downgraded
Rem      to the new/old release by the "u"/"e" script, this load script 
Rem      processes the "new"/"old" scripts to recompile the "new"/"old" version
Rem      of OLS using the "new"/"old" server.
Rem
Rem    NOTES
Rem      Called from olsdbmig.sql & olsrelod.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/olsload.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsload.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    risgupta    09/14/15 - Bug 21748684: Move OLS packages' and views'
Rem                           recompilation here
Rem    risgupta    09/14/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(256)

DECLARE
oid_status NUMBER;

BEGIN
  SELECT COUNT(*) INTO oid_status FROM lbacsys.ols$props
                  WHERE name='OID_STATUS_FLAG' AND value$=1;
  IF oid_status = 1 THEN
    :file_name := 'prvtolsldap.plb';
  ELSE
    :file_name := sys.dbms_registry.nothing_script;
  END IF;
END;
/

-- Load underlying opaque types 
@@prvtolsopq.plb

-- Load All OLS packages
@@prvtolsdd.plb

-- Create views
@@catolsddv.sql
-- Add grants to packages and views
@@prvtolsgrnt.plb
--install dip package ( which depends on views)
@@prvtolsdip.plb

-- update OLS-OID properties 
SELECT :file_name FROM DUAL;
@@&comp_file

@?/rdbms/admin/sqlsessend.sql
