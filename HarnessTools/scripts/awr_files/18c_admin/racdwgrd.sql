Rem
Rem $Header: rdbms/admin/racdwgrd.sql /main/2 2017/06/19 12:23:31 nlee Exp $
Rem
Rem racdwgrd.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      racdwgrd.sql - RAC DoWnGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script downgrades RAC from the current release to
Rem      the release from which the DB was upgraded. 
Rem
Rem    NOTES
Rem      It is invoked by cmpdwgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/racdwgrd.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/racdwgrd.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/cmpdbdwg.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nlee        06/12/17 - RTI 20354827: change 'DROP SYNONYM' to 'DROP
Rem                           PUBLIC SYNONYM'.
Rem    nlee        02/09/17 - new file
Rem    nlee        02/09/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

DECLARE
  p_prv_version sys.registry$.prv_version%type;
BEGIN
  -- Get the previous version of the RAC component
  SELECT prv_version INTO p_prv_version
  FROM sys.registry$ WHERE cid='RAC';

  IF p_prv_version IS NULL THEN
     EXECUTE IMMEDIATE 'DROP PACKAGE SYS."DBMS_CLUSTDB"';
     EXECUTE IMMEDIATE 'DROP VIEW SYS."EXT_TO_OBJ_VIEW"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "EXT_TO_OBJ"';
     EXECUTE IMMEDIATE 'DROP VIEW SYS."FILE_PING"';
     EXECUTE IMMEDIATE 'DROP VIEW SYS."FILE_LOCK"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_STATISTICS"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_LATCH"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_CONVERT_LOCAL"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_CONVERT_REMOTE"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_TRAFFIC_CONTROLLER"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "V$GES_RESOURCE"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_STATISTICS"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_LATCH"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_CONVERT_LOCAL"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_CONVERT_REMOTE"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_TRAFFIC_CONTROLLER"';
     EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "GV$GES_RESOURCE"';
     EXECUTE IMMEDIATE 'DELETE FROM SYS.REGISTRY$ WHERE cid = ''RAC''';
  ELSE
     sys.dbms_registry.downgraded('RAC', p_prv_version);
  END IF;

END;
/

@?/rdbms/admin/sqlsessend.sql
