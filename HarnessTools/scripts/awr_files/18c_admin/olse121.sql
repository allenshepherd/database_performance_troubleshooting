Rem
Rem $Header: rdbms/admin/olse121.sql /main/20 2017/10/13 03:49:13 risgupta Exp $
Rem
Rem olse121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olse121.sql - Downgrade 12.1.0.2 to 12.1.0.1
Rem
Rem    DESCRIPTION
Rem      Downgrades Oracle Label Security from 12.1.0.2 to 12.1.0.1
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/olse121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/olse121.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/olsdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    10/04/17 - Bug 26912490: Update objauth$ for
Rem                           SYS.OLS_ENFORCEMENT without IF check
Rem    risgupta    08/05/17 - Bug 26562372: Update objauth$ for updating obj
Rem                           privilege grants for SYS.OLS_ENFORCEMENT
Rem    risgupta    06/28/17 - Bug 26246240: Update obj privilege grants for
Rem                           SYS.OLS_ENFORCEMENT
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    anupkk      03/06/17 - Bug 25387289: Add call to olse122.sql
Rem    risgupta    08/01/16 - Bug 23634413: Update export registrations in
Rem                           sys.exppkgact$ and sys.expdepact$, Revoke EXECUTE
Rem                           on lbacsys.lbac_services, lbac_standard from SYS
Rem    anupkk      04/04/16 - Bug 22917286: Undo changes for bug 20505982
Rem    yanchuan    03/06/16 - Bug 20505982: revoke
Rem                           READ on lbacsys.dba_sa_policies,
Rem                           READ on lbacsys.dba_sa_table_policies,
Rem                           EXECUTE on lbacsys.lbac_policy_admin from SYS
Rem    risgupta    01/04/15 - RTI 18837063: Drop privs_to_char_n function,
Rem                           Drop CDB_*/DBA_* views when downgrading to 
Rem                           12.1.0.1
Rem    risgupta    11/27/15 - Bug 22267756: Set current schema to LBACSYS
Rem    risgupta    11/18/15 - Bug 22162088: Use fully qualifed name while
Rem                           altering OLS tables
Rem    anupkk      07/24/15 - BUG 21493559: corrected the incorrect column name
Rem    risgupta    05/18/15 - Bug 20435157: resize policy_name in ols$pol to 30
Rem    risgupta    03/17/15 - Bug 18053101: Grant CREATE TRIGGER privilege
Rem                           to LBACSYS
Rem    risgupta    09/26/14 - LRG 13374615: Check for prv_version before 
Rem                           granting/revoking privileges to/from LBACSYS  
Rem    risgupta    06/10/14 - Proj 36685: Add olse122
Rem    cdilling    11/12/13 - remove revoke on ols_util_wrapper as package is
Rem                           dropped first anyway
Rem    aramappa    09/23/13 - Bug 17490352: Handle exception 1927 on REVOKE
Rem    aramappa    09/22/13 - Bug 17526251, 17512943: Grant privileges 
Rem                           to LBACSYS
Rem    aramappa    07/29/13 - bug 16593436:grant ALTER ANY TABLE privilege to
Rem                           LBACSYS
Rem    aramappa    07/29/13 - Created

EXECUTE DBMS_REGISTRY.DOWNGRADING('OLS');

-- Bug 25387289: Add olse122 to downgrade to 12.2.0.1 from latest version
@@olse122.sql

-- Bug 22267756: Set current schema to LBACSYS
ALTER SESSION SET CURRENT_SCHEMA = LBACSYS;

-- 12.2 to lower version
-- Proj 36685: Drop lbac_lgstndby_util package
DROP PACKAGE LBACSYS.lbac_lgstndby_util;
 
-- Bug 18053101: Grant CREATE TRIGGER privilege to LBACSYS
GRANT CREATE TRIGGER TO LBACSYS;

-- Bug 20435157: resize policy_name in ols$pol to 30
ALTER TABLE LBACSYS.ols$pol  MODIFY pol_name VARCHAR2(30);
ALTER TABLE LBACSYS.ols$pol  MODIFY pol_role VARCHAR2(30);

-- RTI 18837063: Drop privs_to_char_n package and synonym
DROP PUBLIC SYNONYM PRIVS_TO_CHAR_N;
DROP FUNCTION LBACSYS.PRIVS_TO_CHAR_N;

-- Bug 23634413: Update export registrations in sys.exppkgact$ 
-- and sys.expdepact$
UPDATE sys.exppkgact$ SET SCHEMA = 'LBACSYS', PACKAGE = 'LBAC_UTL'
  WHERE SCHEMA = 'SYS' and PACKAGE = 'LBAC_EXP';
COMMIT;

UPDATE sys.expdepact$ SET SCHEMA = 'LBACSYS', PACKAGE = 'LBAC_UTL'
  WHERE SCHEMA = 'SYS' and PACKAGE = 'LBAC_EXP';
COMMIT;

-- Bug 23634413: Drop sys.lbac_exp package
DROP PACKAGE sys.lbac_exp;

-- Bug 23639570: Drop sys.ols_enforcement private synonym
DROP SYNONYM LBACSYS.ols_enforcement;

-- Bug 23639570: -- This object privilege grant (EXECUTE on 
-- lbacsys.lbac_services, lbac_standard) are required for running 
-- SYS.ols_enforcement when DV is enabled. When downgrading
-- from 122 and later, need to revoke this object privilege.
DECLARE
  lbacsys_schema number;
BEGIN
  SELECT user# INTO lbacsys_schema FROM sys.user$ WHERE name = 'LBACSYS';

-- Since conducting object privilege revoke from revoker itself is not allowed
-- based on RDBMS behavior, thus we have to do direct delete from sys.objauth$
-- to implement this object privilege revoke.
-- Note: the object privilege number for EXECUTE is 12.
  DELETE FROM sys.objauth$ WHERE obj# = 
    ( SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_SERVICES' AND 
      owner# = lbacsys_schema and type# = 9) AND grantee# = 0 AND
      privilege# = 12;

  DELETE FROM sys.objauth$ WHERE obj# = 
    ( SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_STANDARD' AND 
      owner# = lbacsys_schema and type# = 9) AND grantee# = 0 AND
      privilege# = 12;
END;
/
COMMIT;

-- Bug 26562372: Update privilege grants for LBACSYS.OLS_ENFORCEMENT synonym to
-- the old package, DROP SYS.OLS_ENFORCEMENT package & related synonym.
DECLARE
  objsys     NUMBER := 0;
  objlbacsys NUMBER := 0;
  lbacsysnum NUMBER;
  stmt       VARCHAR2(100) :=
    'create or replace package lbacsys.ols_enforcement as end ols_enforcement;';
BEGIN
  -- Get obj# for SYS.OLS_ENFORCEMENT package.
  SELECT obj# INTO objsys FROM sys.obj$ o
  WHERE o.owner#=0 AND o.name = 'OLS_ENFORCEMENT'
  AND o.type# = 9;

  -- Drop the LBACSYS.OLS_ENFORCEMENT synonym.
  EXECUTE IMMEDIATE 'DROP SYNONYM LBACSYS.OLS_ENFORCEMENT';

  -- Create skeleton for LBACSYS.OLS_ENFORCEMENT package.
  EXECUTE IMMEDIATE stmt;

  SELECT user# INTO lbacsysnum FROM sys.user$ where name = 'LBACSYS';

  -- Get obj# for LBACSYS.OLS_ENFORCEMENT package.
  SELECT obj# INTO objlbacsys FROM sys.obj$ o
  WHERE o.owner#=lbacsysnum AND o.name = 'OLS_ENFORCEMENT'
  AND o.type# = 9;

  -- Update objauth$ with new package's obj#.
  -- 1. Update obj#, grantor# for entries who have been granted by
  --    SYS or anybody with GRANT ANY OBJECT privilege.
  UPDATE sys.objauth$ SET obj# = objlbacsys, grantor# = lbacsysnum
  WHERE obj# = objsys AND grantor# = 0;
  -- 2. Update obj# for entries who have been granted by user
  -- with GRANT option.
  UPDATE sys.objauth$ SET obj# = objlbacsys WHERE obj# = objsys
  AND grantor# <> 0;
  COMMIT;

  -- Drop the SYS.OLS_ENFORCEMENT package.
  EXECUTE IMMEDIATE 'DROP PACKAGE SYS.OLS_ENFORCEMENT';
END;
/

--lrg 13374615: Perform the following only if downgrading to 12.1.0.1 
--bug 16593436:grant privileges
-- system privileges
DECLARE
 prev_version  varchar2(30);
 TYPE view_crsr_t IS REF CURSOR;
 view_cursor      view_crsr_t;
 vname            sys.obj$.name%type;
 cnt              PLS_INTEGER;
 quoted_cdb_view  VARCHAR2(130);
 quoted_dba_view  VARCHAR2(130);
BEGIN
  SELECT prv_version INTO prev_version FROM SYS.registry$
  WHERE cid = 'OLS';

  IF prev_version < '12.1.0.2' THEN
    EXECUTE IMMEDIATE 'GRANT ALTER ANY TABLE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT CREATE LIBRARY TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT CREATE PUBLIC SYNONYM TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT DROP PUBLIC SYNONYM TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT SELECT ANY TABLE TO LBACSYS WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT DELETE ANY TABLE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT INSERT ANY TABLE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT ALTER ANY TRIGGER TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT CREATE ANY TABLE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT DROP ANY ROLE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER SYS TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT INHERIT ANY PRIVILEGES TO LBACSYS';

    -- Bug 17526251: grant system privileges
    EXECUTE IMMEDIATE 'GRANT CREATE ANY CONTEXT TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT DROP ANY CONTEXT TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ANY PROCEDURE TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW  TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT CREATE ROLE TO LBACSYS';

    -- object privileges
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_RLS TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$PARAMETER TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.AUDIT_ACTIONS TO LBACSYS WITH 
                       GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.STMT_AUDIT_OPTION_MAP TO LBACSYS
                       WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$VERSION TO LBACSYS
                       WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.V_$CONTEXT TO LBACSYS
                       WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.DBA_TAB_COMMENTS TO LBACSYS
                       WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT SELECT ON SYS.USER$ TO LBACSYS';
    -- Bug 17512943: grant ALL ON EXPDEPACT$, EXPPKGACT$ to LBACSYS
    EXECUTE IMMEDIATE 'GRANT ALL ON SYS.EXPPKGACT$ TO LBACSYS';
    EXECUTE IMMEDIATE 'GRANT ALL ON SYS.EXPDEPACT$ TO LBACSYS';

    -- Bug 17490352: The REVOKEs for the system privileges got syncd to the PDB
    -- during the PDB open, before the PDB was upgraded. Next when the PDB 
    -- upgrade happened the ORA-1952 was thrown because the REVOKE was already
    -- syncd before. Going by this explanation for the ORA-01952, revokes of 
    -- the object level grants may also fail with a ORA-01927. Also ignore the
    -- 1927 to make sure we do not hit errors like the 1952.

    -- The ORA-01952 is thrown for system privilege revokes and ORA-01927 for
    -- object level revokes. Each error is for its own type of revoke, a system
    -- level revoke cannot throw a ORA-01927 and vice-versa.

    BEGIN
      EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS."_BASE_USER" FROM LBACSYS';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE IN ( -1927 ) THEN NULL;
        ELSE RAISE;
        END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'REVOKE CREATE TRIGGER FROM LBACSYS';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE IN ( -1952 ) THEN NULL;
        ELSE RAISE;
        END IF;
    END;

    -- Recreate view here to use user$ intead of "_BASE_USER"
    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW LBACSYS.ols$policy_columns
       (owner, table_name, column_name, column_data_type)
    AS
    SELECT u.name, o.name,
           c.name,
           decode(c.type#, 2, decode(c.scale, null,
                                     decode(c.precision#, null, ''NUMBER''),
                                     ''NUMBER''),
                           58, ''OPAQUE'')
    FROM sys.col$ c, sys.obj$ o, sys.user$ u,
         sys.coltype$ ac, sys.obj$ ot
    WHERE o.obj# = c.obj#
      AND o.owner# = u.user#
      AND c.obj# = ac.obj#(+) AND c.intcol# = ac.intcol#(+)
      AND ac.toid = ot.oid$(+)
      AND ot.type#(+) = 13
      AND o.type# =  2';

    EXECUTE IMMEDIATE 'DROP PACKAGE SYS.ols_util_wrapper';

    -- RTI 18837063: Drop CDB_* views and synonyms if downgrading to 12.1.0.1
    -- Drop corresponding DBA_* views and synonyms to avoid CDB_* views during reloding.
    BEGIN
      OPEN view_cursor FOR 
        'select object_name from dba_objects where object_name like ''CDB_%''
         and owner = ''LBACSYS'' and object_type = ''VIEW''';
      LOOP
        FETCH view_cursor INTO vname;
        EXIT WHEN view_cursor%NOTFOUND;
        
        -- Drop the view and synonym if it exists.
        quoted_cdb_view := sys.dbms_assert.enquote_name(vname, FALSE);
        EXECUTE IMMEDIATE 
          'select count(*) from dba_synonyms s where s.owner = ''PUBLIC'' and s.synonym_name = :1' 
           INTO cnt USING vname;
        
        IF (cnt = 1) THEN
          EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || quoted_cdb_view;
        END IF;
        EXECUTE IMMEDIATE 'DROP VIEW "LBACSYS".' ||  quoted_cdb_view;    

        -- Drop the corresponding DBA_* view and synonym if it exists.
        quoted_dba_view := sys.dbms_assert.enquote_name('DBA' || substr(vname, 4), FALSE);
        EXECUTE IMMEDIATE 
          'select count(*) from dba_synonyms s where s.owner = ''PUBLIC'' and s.synonym_name = :1'
           INTO cnt USING 'DBA' || substr(vname, 4);

        IF (cnt = 1) THEN
          EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || quoted_dba_view;
        END IF;
        EXECUTE IMMEDIATE 'DROP VIEW "LBACSYS".' ||  quoted_dba_view;
        
      END LOOP;
    END;
  END IF;
END;
/

-- Bug 22267756: Reset current schema to SYS
ALTER SESSION SET CURRENT_SCHEMA = SYS;

EXECUTE DBMS_REGISTRY.DOWNGRADED('OLS', '12.1.0');
