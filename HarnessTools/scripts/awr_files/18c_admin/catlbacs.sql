-- $Header: rdbms/src/server/security/ols/admin/lbacsys.sql /main/26 2017/04/27 20:05:31 risgupta Exp $
--
-- lbacsys.sql
--
-- Copyright (c) 2008, 2017, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      lbacsys.sql
--
--    DESCRIPTION
--       Creates the LBACSYS user and grants the necessary privileges
--
--    NOTES
--      Run as SYS      
--      The compatible init parm must be set to 8.1.0 (does not default
--          in the NDE test environment
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/src/server/security/ols/admin/catlbacs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catlbacs.sql
Rem SQL_PHASE: CATLBACS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catols.sql
Rem END SQL_FILE_METADATA
Rem
--
--    MODIFIED   (MM/DD/YY)
--    risgupta    04/12/17 - Bug 25121695: Use fully qualified names 
--                           for references 
--    anupkk      03/20/17 - Bug 25406198: Create LBACSYS with no
--                           authentication
--    risgupta    02/27/15 - Bug 18053101: Remove CREATE TRIGGER privilege
--    aketkar     04/28/14 - Bug 18331292: Adding sql metadata seed
--    risgupta    04/16/14 - Bug 18594751: Set strong default password for
--                           LBACSYS
--    aramappa    09/19/13 - Bug 17526251: Remove more system/object privileges
--    aramappa    08/28/13 - bug 16593436: Remove system/object privileges
--    risgupta    08/02/13 - LRG 9037231 - Use registry$ to check if LBACSYS
--                           was created by OLS install script
--    aramappa    04/04/13 - Bug# 16593494,16593502,16593597,16593628: Remove
--                           GRANT ALL on EXPPKGACT$ and EXPDEPACT$. Grant only
--                           necessary privileges on EXPDEPACT$ to LBACSYS
--    aramappa    03/28/13 - bug# 16560973:error if the user LBACSYS or role
--                           LBAC_DBA already exist
--    jkati       05/11/12 - bug#14002092 : grant inherit any privileges to
--                           lbacsys
--    rpang       08/03/11 - Proj 32719: grant inherit privileges
--    sanbhara    07/09/11 - aud$ will no longer move to system by default.
--                           This will be done only when OLS is configured.
--                           Moving inserts into exppkgact$ to configure_ols.
--    jkati       06/18/11 - register system procedural action in LBAC_UTL
--    jmadduku    02/10/11 - Proj32507: Grant Unlimited Tablespace with
--                           RESOURCE role
--    sarchak     04/14/08 - Bug 6925041,Creating aud$ in correct tablespace.
--    nkgopal     01/23/08 - I_AUD1 index is dropped in this release
--    mjgreave    08/24/04 - use system tablespace for lbacsys #(3838614)
--    srtata      07/22/04 - remove connect role for lbacsys 
--    cchui       05/04/04 - grant select on v_$instance to lbacsys 
--    shwong      11/30/01 - grant dbms_registry to lbacsys
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     04/06/01 - add index to system.aud$ table
--    gmurphy     04/02/01 - LBAC_DBA to lbacsys.sql
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/13/01 - change for upgrade script
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    rsripada    09/29/00 - move aud$ to system
--    cchui       08/21/00 - give lbacsys GRANT OPTION on dba_role_privs
--    rsripada    05/12/00 - add PL/SQL block to drop all contexts,roles
--    cchui       05/01/00 - drop all triggers
--    rsripada    03/02/00 - remove DATATYPE variable
--    rsripada    02/24/00 - grant drop role to lbacsys
--    rsripada    02/21/00 - define DATATYPE
--    rburns      02/16/00 - add select on v_tcsh 6.05.00 (Cornell) 94/19/06 (s
--    rsripada    02/02/00 - add grants on selects to sys dd tables
--    rsripada    01/19/00 - add aud$ related statements from other sql scripts
--    rsripada    01/13/00 - drop lbac_ctx context
--    rsripada    12/22/99 - add grant  select on dba_role_privs  to lbacsys
--    rsripada    12/07/99 - Grant create role to lbacsys
--    cchui       11/19/99 - update exppkgact$ for import/export
--    cchui       10/21/99 - drop synonym for aud$
--    rsripada    10/12/99 - grant some more privileges to LBACSYS
--    kraghura    10/06/99 - adding echo
--    cchui       09/15/99 - grant create any table to lbacsys
--    rsripada    08/25/99 - invalidate after_drop trigger
--    rsripada    08/20/99 - grant select on v_$parameter,copy aud$
--    rsripada    08/16/99 - grant select on v_$session
--    rburns      07/28/99 - removed grants on SYS tables 
--    vpesati     07/27/99 - add EXECUTE ANY PROCEDURE priv
--    vpesati     07/23/99 - grant privs on sys dd tables
--    vpesati     07/12/99 - add grant on DBMS_RLS
--    rburns      07/06/99 - Add privileges for public synonyms
--    vpesati     07/02/99 - add user cascade
--    rburns      06/24/99 - Add privileges for MLS
--    rburns      06/02/99 - Created
--

-- bug# 16560973: error if LBACSYS user already exists

@@?/rdbms/admin/sqlsessstart.sql

DOC
#######################################################################
#######################################################################
    The following procedure will cause an error if a user or role with 
    the name LBACSYS is found in the database. LBACSYS is an internal 
    user created by OLS and therefore the existing user or role LBACSYS
    should be dropped before installing OLS.

        To drop the user LBACSYS use the command: 
          "DROP USER LBACSYS CASCADE".
        To drop the role LBACSYS use the command: 
          "DROP ROLE LBACSYS".
#######################################################################
#######################################################################
#
WHENEVER SQLERROR EXIT;

DECLARE
  USER_EXISTS EXCEPTION;
  PRAGMA EXCEPTION_INIT(USER_EXISTS,-01920);
  cnt NUMBER := 0;
BEGIN
  -- create LBACSYS user
  EXECUTE IMMEDIATE 'CREATE USER LBACSYS NO AUTHENTICATION DEFAULT
                     TABLESPACE SYSTEM';
EXCEPTION WHEN USER_EXISTS THEN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.registry$ WHERE cid=''OLS''
                       AND namespace=''SERVER'''
    INTO cnt;

    IF (cnt = 0) THEN
      RAISE_APPLICATION_ERROR (-20000, 'user name ''LBACSYS'' conflicts with
         another user or role name. ''LBACSYS'' is a default user account 
         created by the OLS installation process. ''LBACSYS'' role or 
         user must be dropped prior to installing OLS. To drop the user 
         ''LBACSYS'' use the command: DROP USER LBACSYS CASCADE, and to 
         drop the role ''LBACSYS'' use the command: DROP ROLE LBACSYS.');
    END IF;
  END;
END;
/

-- bug# 16560973: error if lbac_dba role already exists
DOC
#######################################################################
#######################################################################
    The following procedure will cause an error if a user or role with 
    the name LBAC_DBA is found in the database. LBAC_DBA is an internal 
    role created by OLS and therefore the existing role or user LBAC_DBA
    should be dropped before installing OLS.

        To drop the role LBAC_DBA use the command: 
          "DROP ROLE LBAC_DBA".
        To drop the user LBAC_DBA use the command: 
          "DROP USER LBAC_DBA CASCADE".
#######################################################################
#######################################################################
#
DECLARE
  ROLE_EXISTS EXCEPTION;
  PRAGMA EXCEPTION_INIT(ROLE_EXISTS,-01921);
  cnt NUMBER := 0;
BEGIN
-- create LBAC_DBA role
  EXECUTE IMMEDIATE 'CREATE ROLE LBAC_DBA';
EXCEPTION WHEN ROLE_EXISTS THEN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.registry$ WHERE cid=''OLS''
                       AND namespace=''SERVER'''
    INTO cnt;

    IF (cnt = 0) THEN
      EXECUTE IMMEDIATE 'DROP USER LBACSYS CASCADE';
      RAISE_APPLICATION_ERROR (-20000, 'role name ''LBAC_DBA'' conflicts with
           another user or role name. ''LBAC_DBA'' is an internal role 
           created by the OLS installation process. ''LBAC_DBA'' role or 
           user must be dropped prior to installing OLS. To drop the role 
           ''LBAC_DBA'' use the command: DROP ROLE LBAC_DBA, and to drop 
           the user ''LBAC_DBA'' use the command: DROP USER LBAC_DBA CASCADE.');
    END IF;       
  END;
END;
/
WHENEVER SQLERROR CONTINUE;

-- grant LBAC_DBA to LBACSYS
GRANT LBAC_DBA to LBACSYS WITH ADMIN OPTION;

GRANT  RESOURCE, UNLIMITED TABLESPACE TO LBACSYS;

GRANT CREATE SESSION TO LBACSYS;

GRANT ADMINISTER DATABASE TRIGGER TO LBACSYS;
GRANT EXECUTE ON SYS.DBMS_REGISTRY TO LBACSYS;
GRANT SELECT ON SYS.V_$SESSION TO LBACSYS;
GRANT SELECT ON SYS.GV_$SESSION TO LBACSYS;
GRANT SELECT ON SYS.V_$INSTANCE TO LBACSYS;
GRANT SELECT ON SYS.GV_$INSTANCE TO LBACSYS;
GRANT SELECT ON SYS.DBA_ROLE_PRIVS TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON SYS.OBJ$ TO LBACSYS;
GRANT SELECT ON SYS.COL$ TO LBACSYS;
GRANT SELECT ON SYS.COLTYPE$ TO LBACSYS;
GRANT SELECT ON SYS."_BASE_USER" TO LBACSYS;
DECLARE
  ALREADY_REVOKED EXCEPTION;
  PRAGMA EXCEPTION_INIT(ALREADY_REVOKED,-01927);
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER LBACSYS FROM PUBLIC';
EXCEPTION
  WHEN ALREADY_REVOKED THEN
    NULL;
END;
/


GRANT EXECUTE ON dbms_priv_capture to LBACSYS;

-- create aud$ table in system schema, drop the aud$ table in sys
-- schema and create a private synonym under sys for aud$.
-- Project 24121: No longer move aud$ to system by default. aud$ 
-- will be moved only when OLS is enabled the first time.

-- For import/export
-- UTL package uses get_object_grant helper function from DBMS_ZHELP 
-- to export the object grants from LBACSYS. We need to grant execute 
-- on that security helper package.
GRANT EXECUTE ON SYS.DBMS_ZHELP TO LBACSYS;
DELETE FROM sys.exppkgact$ WHERE PACKAGE = 'LBAC_UTL';
--Moved inserts into exppkgact$ to configure_ols.

@?/rdbms/admin/sqlsessend.sql

