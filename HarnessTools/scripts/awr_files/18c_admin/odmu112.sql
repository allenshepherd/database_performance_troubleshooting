Rem
Rem $Header: rdbms/admin/odmu112.sql /main/2 2017/05/28 22:46:08 stanaya Exp $
Rem
Rem odmu112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      odmu112.sql - Script to drop dmsys schema during database component upgrade
Rem
Rem    DESCRIPTION
Rem      This script performs DMSYS removal
Rem
Rem    NOTES
Rem      The script is invoked as part of rdbms component upgrade to 12g 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/odmu112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/odmu112.sql
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr       04/29/11 - Created
Rem
Rem
Rem   Drop DMSYS and associated public synonyms

COLUMN :dmsys_name NEW_VALUE odm_file NOPRINT;
VARIABLE dmsys_name VARCHAR2(30)
DECLARE
  dmsys_exists char(1);
BEGIN
   select null into dmsys_exists from sys.user$ where name='DMSYS';
     :dmsys_name := '@dmsysrem.sql';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     :dmsys_name := dbms_registry.nothing_script;
END;
/
SELECT :dmsys_name from DUAL;
@&odm_file

commit;
