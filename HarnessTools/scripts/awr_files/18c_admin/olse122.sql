Rem
Rem $Header: rdbms/admin/olse122.sql /main/9 2017/10/13 03:49:13 risgupta Exp $
Rem
Rem olse122.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olse122.sql - Downgrade to 12.2.0.x
Rem
Rem    DESCRIPTION
Rem      Downgrade OLS to 12.2.0.x from current/latest version.
Rem
Rem    NOTES
Rem      Called from olsdwgrd.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olse122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olse122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    10/04/17 - Bug 26912490: Update objauth$ for
Rem                           SYS.CONFIGURE_OLS without IF check
Rem    risgupta    08/04/17 - Bug 26562372: Update objauth$ for updating obj
Rem                           privilege grants for SYS.CONFIGURE_OLS
Rem    risgupta    06/28/17 - Bug 26246240: Update obj privilege grants for
Rem                           SYS.CONFIGURE_OLS
Rem    anupkk      06/14/17 - Bug 26236759: Revoke execute from audit_admin
Rem                           on lbacsys.ora_get_audited_label
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    anupkk      02/22/17 - Bug 25387289: Revoke read privilege and grant
Rem                           select privilege on OLS$AUDIT_ACTIONS 
Rem    risgupta    02/10/17 - Bug 24764742: Drop sys.is_ols_supported function
Rem    risgupta    11/14/16 - Bug 25029649: Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- first statement 
EXECUTE sys.DBMS_REGISTRY.DOWNGRADING('OLS');

-- Bug 25387289: Revoke read privilege. Grant select privilege on
-- OLS$AUDIT_ACTIONS only when previous version lower than 121.
REVOKE READ ON lbacsys.ols$audit_actions FROM AUDIT_VIEWER, AUDIT_ADMIN;

-- Bug 26236759: Revoke execute on LBACSYS.ORA_GET_AUDITED_LABEL from
-- AUDIT_ADMIN
REVOKE EXECUTE ON lbacsys.ora_get_audited_label FROM AUDIT_ADMIN;

DECLARE
  sql_stmt VARCHAR2(200) := NULL;
  cursor pol_cursor is SELECT pol_role FROM lbacsys.ols$pol;
BEGIN
  FOR i in pol_cursor LOOP
    sql_stmt := 'REVOKE READ ON lbacsys.ols$audit_actions FROM ' || 
                 dbms_assert.enquote_name(i.pol_role, FALSE);
    EXECUTE IMMEDIATE sql_stmt;
  END LOOP;
END;
/

BEGIN
  IF '&cat_prv_version' < '12.1.0.1' THEN
    EXECUTE IMMEDIATE 'GRANT SELECT ON lbacsys.ols$audit_actions TO PUBLIC'; 
  END IF;
END;
/

-- Bug 24764742: Drop sys.is_ols_supported function
DROP FUNCTION sys.is_ols_supported;

-- Bug 26562372: Update privilege grants for LBACSYS.CONFIGURE_OLS synonym to
-- the old procedure, DROP SYS.CONFIGURE_OLS procedure & related synonym.
DECLARE
  objsys     NUMBER := 0;
  objlbacsys NUMBER := 0;
  lbacsysnum NUMBER;
  stmt       VARCHAR2(100) :=
    'create or replace procedure lbacsys.configure_ols as begin null; end;';
BEGIN
  -- Get obj# for SYS.CONFIGURE_OLS procedure.
  SELECT obj# INTO objsys FROM sys.obj$ o
  WHERE o.owner#=0 AND o.name = 'CONFIGURE_OLS'
  AND o.type# = 7;

  -- Drop the LBACSYS.CONFIGURE_OLS synonym.
  EXECUTE IMMEDIATE 'DROP SYNONYM LBACSYS.CONFIGURE_OLS';

  -- Create skeleton for LBACSYS.CONFIGURE_OLS procedure.
  EXECUTE IMMEDIATE stmt;

  SELECT user# INTO lbacsysnum FROM sys.user$ where name = 'LBACSYS';

  -- Get obj# for LBACSYS.CONFIGURE_OLS procedure.
  SELECT obj# INTO objlbacsys FROM sys.obj$ o
  WHERE o.owner#=lbacsysnum AND o.name = 'CONFIGURE_OLS'
  AND o.type# = 7;

  -- Update objauth$ with new procedure's obj#.
  -- 1. Update obj#, grantor# for entries who have been granted by
  --    SYS or anybody with GRANT ANY OBJECT privilege.
  UPDATE sys.objauth$ SET obj# = objlbacsys, grantor# = lbacsysnum
  WHERE obj# = objsys AND grantor# = 0;
  -- 2. Update obj# for entries who have been granted by user
  -- with GRANT option.
  UPDATE sys.objauth$ SET obj# = objlbacsys WHERE obj# = objsys
  AND grantor# <> 0;
  COMMIT;

  -- Drop the SYS.CONFIGURE_OLS procedure.
  EXECUTE IMMEDIATE 'DROP PROCEDURE SYS.CONFIGURE_OLS';
END;
/

-- last statement  
EXECUTE sys.DBMS_REGISTRY.DOWNGRADED('OLS', '12.2.0');

@?/rdbms/admin/sqlsessend.sql
