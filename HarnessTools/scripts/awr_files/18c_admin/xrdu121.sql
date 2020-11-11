Rem
Rem $Header: rdbms/admin/xrdu121.sql /st_rdbms_18.0/1 2017/12/05 20:25:20 atomar Exp $
Rem
Rem xrdu121.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdu121.sql - XDB RDBMS Dependents Upgrade from 12.1
Rem
Rem    DESCRIPTION
Rem      This script contains actions for upgrading from 12.1
Rem
Rem    NOTES
Rem     
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdu121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdu121.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrdupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    atomar      11/19/17 - bug 27107844
Rem    pyam        09/27/17 - 26787343: wrap ALTER REGISTRY$SQLPATCH in plsql
Rem    sanagara    04/21/17 - 25804457: CLOB to XMLTYPE conversion
Rem                           in registry$sqlpatch moved to xrdu122.sql
Rem    raeburns    08/03/16 - Add XRD 12.2 up/down scripts
Rem    surman      07/20/16 - 23170620: Add patch_directory
Rem    surman      07/15/16 - 23705955: Change patch_descriptor to XMLType
Rem    surman      06/29/16 - 23113885: Post patching support
Rem    surman      06/21/16 - 22694961: Add datapatch_role
Rem    surman      05/05/16 - 23025340: Add install_id
Rem    atomar      02/01/16 - bug 22642228 upgrade unsharded AQ views
Rem    surman      01/26/16 - 22582783: Use CreateXML
Rem    surman      01/20/16 - 22359063: Add patch descriptor
Rem    rpang       11/13/15 - Bug 22100322: increase epg$_auth.dad_name size
Rem    surman      08/21/15 - 20772435: SQL registry changes to XDB safe
Rem                           scripts
Rem    jorgrive    01/23/15 - Bug 20317551: exception 31000 for lcr xml schema
Rem    raeburns    12/12/14 - Bug 18747400: Annotate TSDP schema
Rem    jorgrive    12/04/14 - Upgrade Lcr xml schema
Rem    raeburns    11/21/14 - XRD release-specific script
Rem    raeburns    11/21/14 - Created
Rem

Rem ======================================================
Rem BEGIN XRD upgrade from 12.1
Rem ======================================================

-- Delete LCR xml schema, re-registered again when catxrd.sql runs catxlcr.sql
-- Bug 18734501

DECLARE
  schema_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_not_exists,-31000);
BEGIN
  dbms_xmlschema.deleteSchema(
                  'http://xmlns.oracle.com/streams/schemas/lcr/streamslcr.xsd',
                  dbms_xmlschema.DELETE_CASCADE);
  EXCEPTION
  WHEN schema_not_exists THEN
    NULL;
 END;
/

Rem
Rem Delete TSDP schemas; re-created when catxrd.sql is run
Rem Do not exist for upgrade from 11.2
Rem Bug 18747400

DECLARE
  schema_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_not_exists,-31000);
BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
                 'http://xmlns.oracle.com/sdm/sensitivedata_12_1.xsd',
                 DBMS_XMLSCHEMA.DELETE_CASCADE);
EXCEPTION
  WHEN schema_not_exists THEN
    NULL;
END;
/

DECLARE
  schema_not_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_not_exists,-31000);
BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
                 'http://xmlns.oracle.com/sdm/sensitivetypes_12_1.xsd',
                 DBMS_XMLSCHEMA.DELETE_CASCADE);
EXCEPTION
  WHEN schema_not_exists THEN
    NULL;
END;
/

Rem *************************************************************************
Rem Begin registry$sqlpatch changes
Rem 17665117 & 17277459 : Add patch UID and bundle columns 
Rem 14563594: Add version 
Rem 19315691: Change bundle_data to CLOB
Rem 20772435: bundle_data back to XMLType
Rem 22359063: Add patch_descriptor
Rem 23025340: Add install_id
Rem 23170620: Add patch_directory
Rem 23113885: Increase length of status and add post_logfile
Rem *************************************************************************

Rem 26787343: The starting state of registry$sqlpatch can vary based on which
Rem PSU is being used (e.g. - 170117DBPSU contains PATCH_DIRECTORY while
Rem 160719DBPSU does not). For Replay Upgrade, we need to capture all ALTER
Rem TABLE statements, even those that would normally hit ORA-2443. Therefore,
Rem we wrap them in PL/SQL. Since we are in upgrade mode, the errors will
Rem be suppressed in the recursive statement, and the outerlying PL/SQL will
Rem be executed without errors and thus captured.

begin
  execute immediate 'alter table registry$sqlpatch drop constraint registry$sqlpatch_pk';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (version varchar2(20))';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (patch_uid number)';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (flags varchar2(10))';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (bundle_series varchar2(30))';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (bundle_id number)';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (bundle_data XMLType)
    XMLType column bundle_data store as clob';
end;
/

-- 18764751: Update new columns so they will not violate constraints
-- 19928926: Trap ORA-942 as this is not suppressed during upgrade
begin
  execute immediate 'update registry$sqlpatch set version = 0, patch_uid = 0';
exception
  when others then
    if sqlcode = -942 then
      null;
    else
      raise;
    end if;
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (
    constraint registry$sqlpatch_pk PRIMARY KEY
      (patch_id, patch_uid, version, action, action_time))';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (patch_descriptor XMLType)
    XMLType column patch_descriptor store as clob';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (install_id number)';
end;
/

begin
  execute immediate 'alter table registry$sqlpatch add (patch_directory blob)';
end;
/

alter table registry$sqlpatch modify (status varchar2(25));

begin
  execute immediate 'alter table registry$sqlpatch add (post_logfile varchar2(500))';
end;
/

Rem *************************************************************************
Rem End registry$sqlpatch changes
Rem *************************************************************************

Rem *************************************************************************
Rem 22694961: Create datapatch role
Rem *************************************************************************

DECLARE
  cnt NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO cnt
    FROM dba_roles
    WHERE role = 'DATAPATCH_ROLE';

  IF cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE ROLE datapatch_role';
  END IF;
END;
/

Rem *************************************************************************
Rem Bug 22100322: Increase epg$_auth.dadname size
Rem *************************************************************************

alter table epg$_auth modify dadname varchar2(128)
/

Rem *************************************************************************
Rem End Bug 22100322: Increase epg$_auth.dadname size
Rem *************************************************************************

Rem =========================================================================
Rem END upgrade unsharded Queue View
Rem =========================================================================

Rem ======================================================
Rem END XRD upgrade from 12.1
Rem ======================================================

Rem ======================================================
Rem Upgrade from subsequent releases
Rem ======================================================

@@xrdu122.sql

Rem ======================================================
Rem END XRD xrdu121.sql
Rem ======================================================
