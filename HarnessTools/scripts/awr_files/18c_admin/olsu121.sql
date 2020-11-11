Rem
Rem $Header: rdbms/admin/olsu121.sql /main/15 2017/10/13 03:49:13 risgupta Exp $
Rem
Rem olsu121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsu121.sql - Upgrade from 12.1.0.x
Rem
Rem    DESCRIPTION
Rem      Upgrades Oracle Label Security from 12.1.0.x
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/olsu121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsu121.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/olsdbmig.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    10/04/17 - Bug 26912490: Update objauth$ for
Rem                           LBACSYS.OLS_ENFORCEMENT without IF check
Rem    risgupta    08/05/17 - Bug 26562372: Update objauth$ for updating obj
Rem                           privilege grants for LBACSYS.OLS_ENFORCEMENT
Rem    risgupta    06/28/17 - Bug 26246240: Update obj privilege grants for
Rem                           LBACSYS.OLS_ENFORCEMENT
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    anupkk      03/06/17 - Bug 25387289: Invoke olsu122.sql
Rem    risgupta    08/01/16 - Bug 23634413: Update export registrations in
Rem                           sys.exppkgact$ and sys.expdepact$, GRANT EXECUTE
Rem                           on LBACSYS.LBAC_SERVICES, LBAC_STANDARD to SYS
Rem    anupkk      05/20/16 - Bug 22917286: Undo changes for bug 20505982
Rem    anupkk      05/13/16 - Bug 23264000: Set labeling function bit during
Rem                           upgrade
Rem    yanchuan    03/06/16 - Bug 20505982: grant
Rem                           READ on lbacsys.dba_sa_policies,
Rem                           READ on lbacsys.dba_sa_table_policies,
Rem                           EXECUTE on lbacsys.lbac_policy_admin to SYS
Rem    risgupta    11/27/15 - Bug 22267756: use fully qualified name for
Rem                           non-LBACSYS objects, move upgrade actions from
Rem                           12.1.0.2 to 12.2 here
Rem    nkgopal     05/26/14 - Proj# 35931: call 12.2 upgrade file
Rem    jkati       09/25/13 - bug#16904811 : fix sequences to start with latest
Rem                           values to avoid unique constraint errors
Rem    aramappa    09/23/13 - Bug 17490352: Handle exception 01952 in REVOKE
Rem    aramappa    09/22/13 - Bug 17526251, 17512943: Revoke privileges 
Rem                           from LBACSYS
Rem    aramappa    07/29/13 - bug 16593436: revoke object and system privilege
Rem                           from LBACSYS
Rem    aramappa    07/29/13 - Created

-- Bug 16593436: Revoke privilege from LBACSYS
-- revoke system privileges

-- Bug 17490352: The REVOKEs for the system privileges got syncd to the PDB
-- during the PDB open, before the PDB was upgraded. Next when the PDB upgrade
-- happened the ORA-1952 was thrown because the REVOKE was already syncd 
-- before. Going by this explanation for the ORA-01952, revokes of the object 
-- level grants may also fail with a ORA-01927. Also ignore the 1927 to make 
-- sure we do not hit errors like the 1952.

-- The ORA-01952 is thrown for system privilege revokes and ORA-01927 for
-- object level revokes. Each error is for its own type of revoke, a system
-- level revoke cannot throw a ORA-01927 and vice-versa.

BEGIN
  EXECUTE IMMEDIATE 'REVOKE ALTER ANY TABLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE ANY TABLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE LIBRARY FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE PUBLIC SYNONYM FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE DROP PUBLIC SYNONYM FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ANY TABLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE DELETE ANY TABLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INSERT ANY TABLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE ALTER ANY TRIGGER FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE DROP ANY ROLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER SYS FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INHERIT ANY PRIVILEGES FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- revoke system privileges
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE ANY CONTEXT FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE DROP ANY CONTEXT FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ANY PROCEDURE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE VIEW FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE ROLE FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- revoke object privileges
-- bug 17512943: REVOKE grants on EXPDEPACT$, EXPPKGACT$ here
-- instead of olsu112.sql. The original bug to remove these
-- privileges was fixed in 12.1.0.2. So the upgrade changes
-- need to happen here in olsu121.sql and not olsu112.sql
BEGIN
  EXECUTE IMMEDIATE 'REVOKE All ON SYS.EXPDEPACT$ FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE All ON SYS.EXPPKGACT$ FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.USER$ FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.AUDIT_ACTIONS FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.STMT_AUDIT_OPTION_MAP FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.V_$PARAMETER FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.V_$VERSION FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.V_$CONTEXT FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON SYS.DBA_TAB_COMMENTS FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_RLS FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- grant select on "_BASE_USER", CREATE TRIGGER
GRANT SELECT ON SYS."_BASE_USER" TO LBACSYS;
GRANT CREATE TRIGGER TO LBACSYS;

-- Recreate view to use "_BASE_USER". Do it here since catolsdd.sql is 
-- not invoked from olsdbmig.sql or olspatch.sql and because the view 
-- is NOT created in catolsddv.sql
CREATE OR REPLACE VIEW LBACSYS.ols$policy_columns
   (owner, table_name, column_name, column_data_type)
AS
SELECT u.name, o.name,
       c.name,
       decode(c.type#, 2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER'),
                                 'NUMBER'),
                       58, 'OPAQUE')
FROM sys.col$ c, sys.obj$ o, sys."_BASE_USER" u,
     sys.coltype$ ac, sys.obj$ ot
WHERE o.obj# = c.obj#
  AND o.owner# = u.user#
  AND c.obj# = ac.obj#(+) AND c.intcol# = ac.intcol#(+)
  AND ac.toid = ot.oid$(+)
  AND ot.type#(+) = 13
  AND o.type# =  2;  

-- bug#16904811 : update sequences to start with latest values 
-- from the lower version DB
declare
  nl_seqmax NUMBER :=0;
  tn_seqmax NUMBER :=0;
  curseqval NUMBER :=0;
  seqdiff   NUMBER :=0;
BEGIN
  -- select the max nlabel among the dynamic labels
  -- dynamic labels start from 100000000 
  SELECT MAX(nlabel) INTO nl_seqmax FROM LBACSYS.ols$lab
    WHERE nlabel > 99999999;
  IF nl_seqmax > 0
  THEN
    -- select the current sequence value
    SELECT LBACSYS.ols$lab_sequence.NEXTVAL into curseqval FROM DUAL;
    seqdiff := nl_seqmax - curseqval;
    IF seqdiff > 0
    THEN
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.ols$lab_sequence INCREMENT BY '
                                                                    || seqdiff;
      EXECUTE IMMEDIATE 'SELECT LBACSYS.ols$lab_sequence.NEXTVAL FROM DUAL'
                                                            INTO curseqval;
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.ols$lab_sequence
                                                INCREMENT BY 1';
    END IF; -- seqdiff > 0
  END IF;   -- nl_seqmax > 0

  -- select the max tag#                                                          
  SELECT MAX(tag#) INTO tn_seqmax FROM LBACSYS.ols$lab;
  IF tn_seqmax > 0
  THEN
    -- select the current sequence value
    SELECT LBACSYS.ols$tag_sequence.nextval INTO curseqval FROM DUAL;
    seqdiff := tn_seqmax - curseqval;
    IF seqdiff > 0
    THEN
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.ols$tag_sequence INCREMENT BY '
                                                                    || seqdiff;
      EXECUTE IMMEDIATE 'SELECT LBACSYS.ols$tag_sequence.NEXTVAL FROM DUAL'
                                                    INTO curseqval;
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.ols$tag_sequence
                                                INCREMENT BY 1';
    END IF; -- seqdiff > 0
  END IF;   -- tn_seqmax > 0
END;
/

-- Bug 22267756: Move upgrade changes from 12.1.0.2 to 12.2 to this script
-- Bug 18053101: Revoke CREATE TRIGGER from LBACSYS
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE TRIGGER FROM LBACSYS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -1952 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 20435157: modify columns to support 128 bytes for policy names
ALTER TABLE LBACSYS.ols$pol  MODIFY pol_name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$pol  MODIFY pol_role VARCHAR2(128);

-- Bug 23264000: Set label function bit during upgrades
UPDATE lbacsys.ols$polt
SET    options = options + 512
WHERE  BITAND (options, 512) = 0 AND
       function IS NOT NULL;
COMMIT;

-- Bug 23634413: Update export registrations in sys.exppkgact$
-- and sys.expdepact$
UPDATE sys.exppkgact$ SET SCHEMA = 'SYS', PACKAGE = 'LBAC_EXP'
  WHERE SCHEMA = 'LBACSYS' and PACKAGE = 'LBAC_UTL';
COMMIT;

UPDATE sys.expdepact$ SET SCHEMA = 'SYS', PACKAGE = 'LBAC_EXP'
  WHERE SCHEMA = 'LBACSYS' and PACKAGE = 'LBAC_UTL';
COMMIT;

-- Bug 26562372: Update privilege grants for LBACSYS.OLS_ENFORCEMENT package to
-- the new synonym, DROP old LBACSYS.OLS_ENFORCEMENT package.
DECLARE
  objsys     NUMBER := 0;
  objlbacsys NUMBER := 0;
  lbacsysnum NUMBER;
  stmt       VARCHAR2(100) :=
    'create or replace package sys.ols_enforcement authid current_user as end ols_enforcement;';
BEGIN
  SELECT user# INTO lbacsysnum FROM sys.user$ where name = 'LBACSYS';

  BEGIN
    -- Get obj# for LBACSYS.OLS_ENFORCEMENT package.
    SELECT obj# INTO objlbacsys FROM sys.obj$ o
    WHERE o.owner#=lbacsysnum AND o.name = 'OLS_ENFORCEMENT'
    AND o.type# = 9;
  EXCEPTION
    -- Return if upgrading from versions <= 11.2 (No OLS_ENFORCEMENT
    -- package)
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;
  
  -- Create skeleton for SYS.OLS_ENFORCEMENT package.
  EXECUTE IMMEDIATE stmt;

  -- Get obj# for SYS.OLS_ENFORCEMENT package.
  SELECT obj# INTO objsys FROM sys.obj$ o
  WHERE o.owner#=0 AND o.name = 'OLS_ENFORCEMENT'
  AND o.type# = 9;

  -- Update objauth$ with new package's obj#.
  -- 1. Update obj#, grantor# for entries who have been granted by
  --    LBACSYS or anybody with GRANT ANY OBJECT privilege.
  UPDATE sys.objauth$ SET obj# = objsys, grantor# = 0
  WHERE obj# = objlbacsys AND grantor# = lbacsysnum;
  -- 2. Update obj# for entries who have been granted by user
  -- with GRANT option.
  UPDATE sys.objauth$ SET obj# = objsys WHERE obj# = objlbacsys
  AND grantor# <> lbacsysnum;
  COMMIT;

  -- Drop the LBACSYS.OLS_ENFORCEMENT package.
  EXECUTE IMMEDIATE 'DROP PACKAGE LBACSYS.OLS_ENFORCEMENT';

  -- Create the priviate synonym.
  EXECUTE IMMEDIATE
   'CREATE OR REPLACE SYNONYM LBACSYS.OLS_ENFORCEMENT FOR SYS.OLS_ENFORCEMENT';
END;
/

-- This object privilege grant (EXECUTE ON lbacsys.lbac_services, lbac_standard)
-- is required for running SYS.OLS_ENFORCEMENT if DV is enabled.
DECLARE
  -- Get LBACSYS user ID
  lbacsys_schema number;
BEGIN
  SELECT user# INTO lbacsys_schema FROM sys.user$ WHERE name = 'LBACSYS';

-- Since conducting object privilege grant to grantor itself is not allowed
-- based on RDBMS behavior, thus we have to do direct insert into sys.objauth$
-- to implement this object privilege grant.
-- Note: the object privilege number for EXECUTE is 12
  BEGIN
    INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#)
      VALUES
      ( (SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_SERVICES'
         AND owner# = lbacsys_schema AND type# = 9), lbacsys_schema, 0, 12,
        sys.object_grant.nextval );
  EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE IN (-00001) THEN NULL;   --ignore unique constraint violation
    ELSE RAISE;
    END IF;
  END;

  BEGIN
    INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#)
      VALUES
      ( (SELECT obj# FROM sys.obj$ WHERE name = 'LBAC_STANDARD'
         AND owner# = lbacsys_schema AND type# = 9), lbacsys_schema, 0, 12,
        sys.object_grant.nextval );
  EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE IN (-00001) THEN NULL;   --ignore unique constraint violation
    ELSE RAISE;
    END IF;
  END;
END;
/
COMMIT;

-- Invoke olsu122.sql for upgrade from 12.2.0.1 to latest version
@@olsu122.sql
