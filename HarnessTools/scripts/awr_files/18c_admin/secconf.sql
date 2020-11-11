Rem
Rem $Header: rdbms/admin/secconf.sql /main/19 2017/06/30 18:37:09 amunnoli Exp $
Rem
Rem secconf.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      secconf.sql - SECure CONFiguration script
Rem
Rem    DESCRIPTION
Rem      Secure configuration settings for the database include a reasonable
Rem      default password profile, password complexity checks, audit settings
Rem      (enabled, with admin actions audited), and as many revokes from PUBLIC
Rem      as possible. In the first phase, only the default password profile is
Rem      included.
Rem
Rem
Rem    NOTES
Rem      Only invoked for newly created databases, not for upgraded databases
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/secconf.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/secconf.sql
Rem SQL_PHASE: SECCONF
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/execsec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    06/23/17 - Bug 26040105: Update ORA_CIS_RECOMMENDATIONS per
Rem                           V2.0.0 (12-28-2016) FOR CIS BENCHMARK
Rem    anupkk      01/10/17 - Proj# 67576: Enable audit on ALTER DATABASE
Rem                           DICTIONARY by default
Rem    anupkk      10/29/15 - Bug-22122810 : Removing repeated privileges in
Rem                           ORA_SECURECONFIG definition
Rem    ssonawan    02/04/14 - Bug 20383779: audit BECOME USER by default
Rem    sumkumar    12/26/14 - Project 46885: inactive account time defaulted
Rem                           to UNLIMITED for DEFAULT profile
Rem    amunnoli    09/02/14 - Bug 19499532: Add comments to OOB audit policies
Rem    risgupta    02/17/14 - Bug 18174384: Remove Logon/Logoff actions from
Rem                           ORA_SECURECONFIG audit policy
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    vpriyans    09/21/13 - Bug 17299076: Added ORA_CIS_RECOMMENDATIONS audit
Rem                           policy
Rem    jkati       02/04/13 - bug#16080525: Enable audit on DBMS_RLS by default
Rem    amunnoli    02/18/13 - Bug #16310544: add CREATE/DROP/ALTER PLUGGABLE
Rem                           DB actions to default audit configuration
Rem    vpriyans    06/05/12 - Bug 12904308: Audit CREATE DIRECTORY by default
Rem    vpriyans    03/22/12 - Bug 13413683: Rename predefined audit policies
Rem                           and add few more actions and privileges
Rem    nkgopal     09/08/11 - Bug 12794116: Configure Audit based on input
Rem                           argument
Rem    apsrivas    09/30/08 - bug 7428539: Add missing audit settings
Rem    asurpur     06/16/06 - audit changes for sec config 
Rem    rburns      06/12/06 - secure configuration script 
Rem    rburns      06/12/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Secure configuration settings. Currently, only the default password
Rem profile is included, without the password complexity check and has
Rem the recommended audit settings. We will add the revokes from PUBLIC, and 
Rem the password complexity checks.

-- Create password profile without a password complexity routine, for backward
-- compatibility. Add the routine if possible without breaking tests

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 180
PASSWORD_GRACE_TIME 7
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_REUSE_MAX UNLIMITED
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME 1
INACTIVE_ACCOUNT_TIME UNLIMITED;

-- Turn on auditing options

PROMPT Do you wish to configure 11g style Audit Configuration OR
PROMPT Do you wish to configure 12c Unified Audit Policies?
PROMPT Enter RDBMS_11G for former or RDBMS_UNIAUD for latter

DECLARE
  USER_CHOICE               VARCHAR2(100);
  RDBMS11_CHOICE  CONSTANT  VARCHAR2(20) := 'RDBMS_11G';
  UNIAUD_CHOICE   CONSTANT  VARCHAR2(20) := 'RDBMS_UNIAUD';
BEGIN

  USER_CHOICE := '&1';

  -- Audit policy to audit user account and privilege management
  EXECUTE IMMEDIATE 
    'CREATE AUDIT POLICY ORA_ACCOUNT_MGMT ' ||
                 'ACTIONS CREATE USER, ALTER USER, DROP USER, ' ||
                         'CREATE ROLE, DROP ROLE, ALTER ROLE, ' ||
                         'SET ROLE, GRANT, REVOKE';
  EXECUTE IMMEDIATE
    'COMMENT ON AUDIT POLICY ORA_ACCOUNT_MGMT IS '||
      '''Audit policy containing audit options for auditing account ' ||
        'management actions ''';


  -- Audit policy to audit Database parameter settings
  EXECUTE IMMEDIATE 
    'CREATE AUDIT POLICY ORA_DATABASE_PARAMETER '||
                 'ACTIONS ALTER DATABASE, ALTER SYSTEM, CREATE SPFILE';
  EXECUTE IMMEDIATE
    'COMMENT ON AUDIT POLICY ORA_DATABASE_PARAMETER IS '||
     ''' Audit policy containing audit options to audit changes '||
       ' in database parameters''';

  -- Audit Logon by failures
  EXECUTE IMMEDIATE
    'CREATE AUDIT POLICY ORA_LOGON_FAILURES ACTIONS LOGON';
  EXECUTE IMMEDIATE
    'COMMENT ON AUDIT POLICY ORA_LOGON_FAILURES IS '||
     '''Audit policy containing audit options to capture logon failures''';

  -- Audit policy containing all Secure Configuration audit-options
  -- Bug 20383779: audit BECOME USER by default in Unified Audit
  EXECUTE IMMEDIATE 
    'CREATE AUDIT POLICY ORA_SECURECONFIG ' ||
                 'PRIVILEGES ALTER ANY TABLE, CREATE ANY TABLE, ' ||
                            'DROP ANY TABLE, CREATE ANY PROCEDURE, ' ||
                            'DROP ANY PROCEDURE, ALTER ANY PROCEDURE, '||
                            'GRANT ANY PRIVILEGE, ' ||
                            'GRANT ANY OBJECT PRIVILEGE, GRANT ANY ROLE, '||
                            'AUDIT SYSTEM, CREATE EXTERNAL JOB, ' || 
                            'CREATE ANY JOB, CREATE ANY LIBRARY, ' ||
                            'EXEMPT ACCESS POLICY, CREATE USER, ' ||
                            'DROP USER, ALTER DATABASE, ALTER SYSTEM, '||
                            'CREATE PUBLIC SYNONYM, DROP PUBLIC SYNONYM, ' ||
                            'CREATE SQL TRANSLATION PROFILE, ' ||
                            'CREATE ANY SQL TRANSLATION PROFILE, ' ||
                            'DROP ANY SQL TRANSLATION PROFILE, ' ||
                            'ALTER ANY SQL TRANSLATION PROFILE, ' ||
                            'TRANSLATE ANY SQL, EXEMPT REDACTION POLICY, ' ||
                            'PURGE DBA_RECYCLEBIN, LOGMINING, ' ||
                            'ADMINISTER KEY MANAGEMENT, BECOME USER ' ||
                 'ACTIONS ALTER USER, CREATE ROLE, ALTER ROLE, DROP ROLE, '||
                         'SET ROLE, CREATE PROFILE, ALTER PROFILE, ' ||
                         'DROP PROFILE, CREATE DATABASE LINK, ' ||
                         'ALTER DATABASE LINK, DROP DATABASE LINK, '||
                         'CREATE DIRECTORY, DROP DIRECTORY, '||
                         'CREATE PLUGGABLE DATABASE, ' ||
                         'DROP PLUGGABLE DATABASE, '||
                         'ALTER PLUGGABLE DATABASE, '||
                         'EXECUTE ON DBMS_RLS, '||
                         'ALTER DATABASE DICTIONARY';
  EXECUTE IMMEDIATE
    'COMMENT ON AUDIT POLICY ORA_SECURECONFIG IS '||
      '''Audit policy containing audit options as per database '||
        'security best practices''';


  -- Bug 17299076: audit policy with CIS recommended audit options
  -- Bug 26040105: Update ORA_CIS_RECOMMENDATIONS policy per V2.0.0 
  -- (12-28-2016) FOR CIS BENCHMARK
  EXECUTE IMMEDIATE
    'CREATE AUDIT POLICY ORA_CIS_RECOMMENDATIONS '||
              'PRIVILEGES SELECT ANY DICTIONARY, ALTER SYSTEM '||
                 'ACTIONS CREATE USER, ALTER USER, DROP USER, ' ||
                         'CREATE ROLE, DROP ROLE, ALTER ROLE, ' ||
                         'GRANT, REVOKE, CREATE DATABASE LINK, '||
                         'ALTER DATABASE LINK, DROP DATABASE LINK, '||
                         'CREATE PROFILE, ALTER PROFILE, DROP PROFILE, '||
                         'CREATE SYNONYM, DROP SYNONYM, '||
                         'CREATE PROCEDURE, DROP PROCEDURE, '||
                         'ALTER PROCEDURE, ALTER SYNONYM, CREATE FUNCTION, '||
                         'CREATE PACKAGE, CREATE PACKAGE BODY, '||
                         'ALTER FUNCTION, ALTER PACKAGE, ALTER SYSTEM, '||
                         'ALTER PACKAGE BODY, DROP FUNCTION, '||
                         'DROP PACKAGE, DROP PACKAGE BODY, '||
                         'CREATE TRIGGER, ALTER TRIGGER, '||
                         'DROP TRIGGER';
  EXECUTE IMMEDIATE 
    'COMMENT ON AUDIT POLICY ORA_CIS_RECOMMENDATIONS IS '||
      '''Audit policy containing audit options as per CIS recommendations''';

  IF USER_CHOICE = RDBMS11_CHOICE THEN
    -- 11g Secure Audit Configuration
    -- Bug 20383779: audit BECOME USER by default in Traditional Audit

    EXECUTE IMMEDIATE 'AUDIT ALTER ANY TABLE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE ANY TABLE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DROP ANY TABLE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE ANY PROCEDURE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DROP ANY PROCEDURE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER ANY PROCEDURE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT GRANT ANY PRIVILEGE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT GRANT ANY OBJECT PRIVILEGE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT GRANT ANY ROLE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT AUDIT SYSTEM BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE EXTERNAL JOB BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE ANY JOB BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE ANY LIBRARY BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE PUBLIC DATABASE LINK BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT EXEMPT ACCESS POLICY BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER USER BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE USER BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ROLE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE SESSION BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DROP USER BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER DATABASE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER SYSTEM BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DROP PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DATABASE LINK BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT SYSTEM AUDIT BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT PUBLIC SYNONYM BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT SYSTEM GRANT BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE SQL TRANSLATION PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT CREATE ANY SQL TRANSLATION PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DROP ANY SQL TRANSLATION PROFILE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ALTER ANY SQL TRANSLATION PROFILE BY ACCESS'; 
    EXECUTE IMMEDIATE 'AUDIT TRANSLATE ANY SQL BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT PURGE DBA_RECYCLEBIN BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT LOGMINING BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT EXEMPT REDACTION POLICY BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT ADMINISTER KEY MANAGEMENT BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT DIRECTORY BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT PLUGGABLE DATABASE BY ACCESS';
    EXECUTE IMMEDIATE 'AUDIT BECOME USER BY ACCESS';

    -- Audit configurarion on Common object in PDB is not supported.
    -- Hence execute AUDIT on DBMS_RLS in non-CDB and CDB$ROOT.
    IF (SYS_CONTEXT('USERENV', 'CON_ID') in (0,1)) THEN
      EXECUTE IMMEDIATE 'AUDIT EXECUTE ON DBMS_RLS BY ACCESS';
    END IF;

  ELSIF USER_CHOICE = UNIAUD_CHOICE THEN
    -- 12c Secure Audit Configuration

     -- Enable ORA_SECURECONFIG for all users
     EXECUTE IMMEDIATE 'AUDIT POLICY ORA_SECURECONFIG';
     -- Also enable Logon failures. Bug 18174384
     EXECUTE IMMEDIATE 'AUDIT POLICY ORA_LOGON_FAILURES WHENEVER NOT SUCCESSFUL';

  ELSE
    DBMS_OUTPUT.PUT_LINE('Invalid Input "' || USER_CHOICE ||
                         '". Please try again');
  END IF;

END;
/


@?/rdbms/admin/sqlsessend.sql
