Rem
Rem $Header: rdbms/admin/olsrle.sql /main/2 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olsrle.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsrle.sql - Recompile Lbac_Events package
Rem
Rem    DESCRIPTION
Rem      Validate lbac_events on which OLS DDL triggers depend. If not 
Rem      validated here these triggers fire when utlrp is invoked with
Rem      lbac_events still in an invalid package state.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsrle.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsrle.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    aramappa    02/03/12 - bug 13653782:validate lbac_events package
Rem    aramappa    02/03/12 - Created
Rem

SET ECHO ON

DECLARE
  objid NUMBER;
BEGIN
  IF dbms_registry.is_loaded('OLS') IS NOT NULL THEN
  BEGIN
    SELECT object_id into objid from dba_objects WHERE
           object_name='LBAC_EVENTS' AND status = 'INVALID' 
           AND object_type='PACKAGE BODY';
    dbms_utility.validate(objid);
    EXCEPTION
    WHEN OTHERS THEN
      RETURN;
    END;
  END IF; 
END;
/
