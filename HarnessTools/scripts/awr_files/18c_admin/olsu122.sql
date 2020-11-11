Rem
Rem $Header: rdbms/admin/olsu122.sql /main/11 2017/10/13 03:49:13 risgupta Exp $
Rem
Rem olsu122.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      olsu122.sql - upgrade from 12201 to latest version.
Rem
Rem    DESCRIPTION
Rem      Upgrades Oracle Label Security to MAIN.
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsu122.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsu122.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdbmig.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    10/04/17 - Bug 26912490: Update objauth$ for
Rem                           LBACSYS.CONFIGURE_OLS without IF check
Rem    risgupta    08/05/17 - Bug 26562372: Update objauth$ for updating obj
Rem                           privilege grants for LBACSYS.CONFIGURE_OLS
Rem    risgupta    06/28/17 - Bug 26246240: Update obj privilege grants for
Rem                           LBACSYS.CONFIGURE_OLS
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    anupkk      02/22/17 - Bug 25387289: Replace select privilege with
Rem                           read privilege on ols$audit_actions
Rem    anupkk      02/22/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Bug 25387289: Revoke select privilege from public on ols$audit_actions.
-- Select privilege is granted for versions <= 112. The error when previous
-- versions > 112 should get supressed. Grant read privilege on
-- ols$audit_actions.
REVOKE SELECT ON lbacsys.ols$audit_actions FROM PUBLIC;
GRANT READ ON lbacsys.ols$audit_actions TO AUDIT_VIEWER, AUDIT_ADMIN;
 
-- Bug 26562372: Update privilege grants for LBACSYS.CONFIGURE_OLS procedure to
-- the new synonym, DROP old LBACSYS.CONFIGURE_OLS procedure.
DECLARE
  objsys     NUMBER := 0;
  objlbacsys NUMBER := 0;
  lbacsysnum NUMBER;
  stmt       VARCHAR2(100) :=
    'create or replace procedure sys.configure_ols authid current_user as begin null; end;';
BEGIN
  SELECT user# INTO lbacsysnum FROM sys.user$ where name = 'LBACSYS';

  BEGIN
    -- Get obj# for LBACSYS.CONFIGURE_OLS procedure.
    SELECT obj# INTO objlbacsys FROM sys.obj$ o
    WHERE o.owner#=lbacsysnum AND o.name = 'CONFIGURE_OLS'
    AND o.type# = 7;
  EXCEPTION
    -- Return if upgrading from versions <= 11.2 (No CONFIGURE_OLS procedure)
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  -- Create skeleton for SYS.CONFIGURE_OLS procedure.
  EXECUTE IMMEDIATE stmt;

  -- Get obj# for SYS.CONFIGURE_OLS procedure.
  SELECT obj# INTO objsys FROM sys.obj$ o
  WHERE o.owner#=0 AND o.name = 'CONFIGURE_OLS'
  AND o.type# = 7;

  -- Update objauth$ with new procedure's obj#.
  -- 1. Update obj#, grantor# for entries who have been granted by
  --    LBACSYS or anybody with GRANT ANY OBJECT privilege.
  UPDATE sys.objauth$ SET obj# = objsys, grantor# = 0
  WHERE obj# = objlbacsys AND grantor# = lbacsysnum;
  -- 2. Update obj# for entries who have been granted by user
  -- with GRANT option.
  UPDATE sys.objauth$ SET obj# = objsys WHERE obj# = objlbacsys
  AND grantor# <> lbacsysnum;
  COMMIT;

  -- Drop the LBACSYS.CONFIGURE_OLS procedure.
  EXECUTE IMMEDIATE 'DROP PROCEDURE LBACSYS.CONFIGURE_OLS';

  -- Create the priviate synonym.
  EXECUTE IMMEDIATE
    'CREATE OR REPLACE SYNONYM LBACSYS.CONFIGURE_OLS FOR SYS.CONFIGURE_OLS';
END;
/

@?/rdbms/admin/sqlsessend.sql
