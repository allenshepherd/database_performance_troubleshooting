Rem
Rem $Header: rdbms/admin/catnomgd.sql /main/8 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnomgd.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnomgd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnomgd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnomgd.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       09/03/15 - remove call to dbms_registry
Rem    hgong       01/17/13 - drop mgd_id_lookup_table
Rem    hgong       02/14/11 - drop pbs mgd_id_xml_validator
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       05/25/06 - moved the uninstallation statements to mgdrm.sql
Rem    hgong       03/31/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

--EXECUTE dbms_registry.removing('MGD');

--select comp_name,version,status from dba_registry;

prompt .. Dropping MGDSYS Java components
call sys.dbms_java.dropjava('-schema MGDSYS rdbms/jlib/mgd_idcode.jar');

prompt .. Dropping the Oracle MGDSYS user with cascade option 
DROP USER MGDSYS CASCADE;

prompt .. Dropping Public Synonyms

DROP PUBLIC SYNONYM mgd_id;
DROP PUBLIC SYNONYM mgd_id_component;
DROP PUBLIC SYNONYM mgd_id_component_varray;
DROP PUBLIC SYNONYM DBMS_MGD_ID_UTL;
DROP PUBLIC SYNONYM mgd_id_category;
DROP PUBLIC SYNONYM mgd_id_scheme;
DROP PUBLIC SYNONYM user_mgd_id_category;
DROP PUBLIC SYNONYM user_mgd_id_scheme;
DROP PUBLIC SYNONYM mgd_id_xml_validator;
DROP PUBLIC SYNONYM mgd_id_lookup_table;

--select comp_name,version,status from dba_registry;

------------------------------------------------------
-- No need to call removed, because MGDSYS is dropped
------------------------------------------------------
--EXECUTE dbms_registry.removed('MGD');

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

