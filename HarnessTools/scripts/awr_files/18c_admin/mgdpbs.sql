Rem
Rem $Header: rdbms/admin/mgdpbs.sql /main/8 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem mgdpbs.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      mgdpbs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/mgdpbs.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/mgdpbs.sql
Rem    SQL_PHASE: MGDPBS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    hgong       09/03/15 - remove call to dbms_registry
Rem    hgong       01/17/13 - add mgd_id_lookup_table
Rem    hgong       05/20/10 - add mgd_id_xml_validator and mgd$sequence_category
Rem    hgong       07/12/06 - edit comments 
Rem    hgong       05/16/06 - rename MGD_ID_META to MGD_ID_UTL 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create public synonyms 
Rem    hgong       03/31/06 - create public synonyms 
Rem    hgong       03/31/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

prompt .. Creating Oracle IDCode Privileges for Types and Packages
  
GRANT EXECUTE ON mgd_id TO PUBLIC;
GRANT EXECUTE ON mgd_id_component TO PUBLIC;
GRANT EXECUTE ON mgd_id_component_varray TO PUBLIC;
GRANT EXECUTE ON DBMS_MGD_ID_UTL TO PUBLIC;

--prompt .. Granting SELECT to user and default views supporting the idcode

GRANT SELECT  ON mgd_id_category TO PUBLIC;
GRANT SELECT  ON mgd_id_scheme TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE  ON user_mgd_id_category TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_mgd_id_scheme TO PUBLIC;
GRANT SELECT  ON mgd_id_xml_validator TO PUBLIC;
GRANT SELECT  ON mgd_id_lookup_table TO PUBLIC;
GRANT SELECT  ON mgd$sequence_category TO PUBLIC;

prompt .. Creating Oracle IDCode Public Synonymns  

CREATE PUBLIC SYNONYM mgd_id FOR mgd_id;
CREATE PUBLIC SYNONYM mgd_id_component FOR mgd_id_component;
CREATE PUBLIC SYNONYM mgd_id_component_varray FOR mgd_id_component_varray;
CREATE PUBLIC SYNONYM DBMS_MGD_ID_UTL FOR DBMS_MGD_ID_UTL;

CREATE PUBLIC SYNONYM mgd_id_category FOR mgd_id_category;
CREATE PUBLIC SYNONYM mgd_id_scheme FOR mgd_id_scheme;
CREATE PUBLIC SYNONYM user_mgd_id_category FOR user_mgd_id_category;
CREATE PUBLIC SYNONYM user_mgd_id_scheme FOR user_mgd_id_scheme;
CREATE PUBLIC SYNONYM mgd_id_xml_validator FOR mgd_id_xml_validator;
CREATE PUBLIC SYNONYM mgd_id_lookup_table FOR mgd_id_lookup_table;

/****************************** PROCEDURES *********************************/
/*** VALIDATION Procedures for MGD                                       ***/
/***************************************************************************/
create or replace procedure sys.validate_mgd as
  retnum  NUMBER;
begin
  -- ensure that mgd objects are all valid --
  select 1 into retnum from all_objects 
     where owner = 'MGDSYS' 
       and status != 'VALID'
       and (object_name like 'MGD%' or 
            object_name like 'DBMS_MGD%' or 
            object_type = 'JAVA CLASS')
       and rownum < 2;

  --sys.dbms_registry.invalid('MGD');
  dbms_output.put_line('MGD has invalid objects.');
exception
  when no_data_found then
    --sys.dbms_registry.valid('MGD');
    dbms_output.put_line('MGD is valid');
end;
/
SHOW ERRORS;
/

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

