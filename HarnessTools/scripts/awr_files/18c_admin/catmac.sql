Rem
Rem Copyright (c) 2004, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmac.sql - Install mandatory access control configuration schema and packages.
Rem
Rem    DESCRIPTION
Rem      This is the main install script for installing the database objects
Rem      required for Oracle Database vault.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA and requires that passwords be specified for
Rem      SYSDBA, DV_OWNER and DV_ACCOUNT_MANAGER
Rem
Rem        Parameter 1 = account default tablespace
Rem        Parameter 2 = account temp tablespace
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmac.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmac.sql
Rem SQL_PHASE: CATMAC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE 
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jibyun      08/11/16 - XbranchMerge jibyun_bug-24380389 from
Rem                           st_rdbms_12.2.0.1.0
Rem    jibyun      08/02/16 - Bug 24380389: remove parameter for SYS password
Rem    yapli       02/17/16 - Bug 22733681: Set nls_length_semantics = byte
Rem    namoham     04/29/15 - Bug 16570807: Add sanity check for default DV
Rem                           user/role conflicts
Rem    aketkar     04/29/14 - sql patch metadata seed
Rem    sanbhara    07/09/13 - Bug 16704912 - adding calls to sqlsessstart.sql
Rem                           and sqlsessend.sql instead of directly modifying
Rem                           _oracle_script parameter.
Rem    sankejai    10/12/11 - set _oracle_script=TRUE
Rem    jaeblee     08/26/11 - 12914214: remove connects
Rem    sanbhara    07/28/11 - Project 24121 - move DV_ADMIN_DIR creation to
Rem                           dbms_macadm.add_nls_data.
Rem    sanbhara    05/24/11 - Project 24121 - remove parameters 4-7 for
Rem                           dv_owner and dv_acctmgr.
Rem    sankejai    04/11/11 - set _oracle_script in session after connect
Rem    sanbhara   01/31/11 - Bug Fix 10225918.
Rem    srtata     03/17/09 - removed OLS logon trigger
Rem    jsamuel    01/12/09 - call catmaca audit statements for DV
Rem    jsamuel    09/30/08 - passwordless patching and simplify catmac
Rem    youyang    09/18/08 - Bug 6739582: DBCA failes when use dot for
Rem                          dvowner's password
Rem    pknaggs    04/20/08 - bug 6938028: Database Vault Protected Schema.
Rem    pknaggs    06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs    05/29/07 - 5716741: sysdba can't do account management.
Rem    ruparame   02/22/07 - Adding Network IP privileges to DVSYS
Rem    ruparame   02/20/07 - 
Rem    ruparame   01/20/07 - DV/ DBCA Integration
Rem    ruparame   01/13/07 - DV/DBCA Integration
Rem    ruparame   01/10/07 - DV/DBCA Integration
Rem    mxu        01/26/07 - Fix error
Rem    rvissapr   12/01/06 - add validate_dv
Rem    jciminsk   05/02/06 - catmacp.plb to prvtmacp.plb, to cleanup naming 
Rem    jciminsk   05/02/06 - created admin/catmac.sql 
Rem    jciminsk   05/02/06 - created admin/catmac.sql 
Rem    tchorma    02/04/06 - Disable LBACSYS triggers before performing 
Rem                          installation 
Rem    sgaetjen   11/10/05 - add exit to end of script for options install 
Rem    sgaetjen   08/19/05 - Comment out OLS recompile 
Rem    sgaetjen   08/18/05 - Refactor for OUI 
Rem    sgaetjen   08/11/05 - sgaetjen_dvschema
Rem    sgaetjen   08/10/05 - OLS init check 
Rem    sgaetjen   08/03/05 - correct comments 
Rem    sgaetjen   08/03/05 - corrected parameter for sys password 
Rem    sgaetjen   08/03/05 - need to supply password for SYS now 
Rem    sgaetjen   08/02/05 - add DVF package body compile 
Rem    sgaetjen   07/30/05 - separate DVSYS and SYS commands 
Rem    sgaetjen   07/28/05 - dos2unix
Rem    sgaetjen   07/25/05 - Created.

WHENEVER SQLERROR CONTINUE;

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

@@?/rdbms/admin/sqlsessstart.sql

-- Bug 16570807
-- Sanity check to make sure default DV users and roles do not conflict
-- with existing users/roles. We perform this check only when catmac.sql
-- is run for the first time or when catmac.sql is run after running
-- dvremov.sql. For subsequent runnings of catmac.sql this check is 
-- ignored. Note that if there is a DV user/role conflict, catmac.sql simply
-- does not run subsequent catmac*.sql scripts. The conflict(s)
-- should be resolved before catmac.sql can be run successfully to
-- the completion.

VARIABLE catmacdd_fn VARCHAR2(30);
VARIABLE catmacs_fn VARCHAR2(30);
VARIABLE catmacc_fn VARCHAR2(30);
VARIABLE dvmacfnc_fn VARCHAR2(30);
VARIABLE catmacp_fn VARCHAR2(30);
VARIABLE prvtmacp_fn VARCHAR2(30);
VARIABLE catmacg_fn VARCHAR2(30);
VARIABLE catmacr_fn VARCHAR2(30);
VARIABLE catmacd_fn VARCHAR2(30);
VARIABLE catmact_fn VARCHAR2(30);
VARIABLE catmaca_fn VARCHAR2(30);
VARIABLE catmach_fn VARCHAR2(30);
VARIABLE catmacpre_fn VARCHAR2(30);

COLUMN :catmacdd_fn NEW_VALUE catmacdd_file NOPRINT
COLUMN :catmacs_fn NEW_VALUE catmacs_file NOPRINT
COLUMN :catmacc_fn NEW_VALUE catmacc_file NOPRINT
COLUMN :dvmacfnc_fn NEW_VALUE dvmacfnc_file NOPRINT
COLUMN :catmacp_fn NEW_VALUE catmacp_file NOPRINT
COLUMN :prvtmacp_fn NEW_VALUE prvtmacp_file NOPRINT
COLUMN :catmacg_fn NEW_VALUE catmacg_file NOPRINT
COLUMN :catmacr_fn NEW_VALUE catmacr_file NOPRINT
COLUMN :catmacd_fn NEW_VALUE catmacd_file NOPRINT
COLUMN :catmact_fn NEW_VALUE catmact_file NOPRINT
COLUMN :catmaca_fn NEW_VALUE catmaca_file NOPRINT
COLUMN :catmach_fn NEW_VALUE catmach_file NOPRINT
COLUMN :catmacpre_fn NEW_VALUE catmacpre_file NOPRINT

BEGIN
  :catmacdd_fn  := 'nothing.sql';
  :catmacs_fn   := 'nothing.sql';
  :catmacc_fn   := 'nothing.sql';
  :dvmacfnc_fn  := 'nothing.sql';
  :catmacp_fn   := 'nothing.sql';
  :prvtmacp_fn  := 'nothing.sql';
  :catmacg_fn   := 'nothing.sql';
  :catmacr_fn   := 'nothing.sql';
  :catmacd_fn   := 'nothing.sql';
  :catmact_fn   := 'nothing.sql';
  :catmaca_fn   := 'nothing.sql';
  :catmach_fn   := 'nothing.sql';
  :catmacpre_fn := 'nothing.sql';
END;
/

DECLARE
  -- holds both users and roles
  TYPE usrarr_t IS VARRAY(16) OF VARCHAR2(30);
  usrarr usrarr_t;
  cntusr NUMBER := 0;
  cntdv NUMBER := 0;
BEGIN
  -- check if DV is installed
  EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.registry$ WHERE cid = ''DV''
                     AND namespace = ''SERVER'''
  INTO cntdv;

  -- Make catmac script re-runnable by not checking default user/role conflicts
  -- if DV is already installed
  IF (cntdv = 0) THEN -- DV not installed
    -- Note: Please add new DV users/roles to this array
    usrarr := usrarr_t('DVSYS', 'DVF',
                       'DV_ACCTMGR', 'DV_OWNER', 'DV_ADMIN', 'DV_SECANALYST',
                       'DV_PUBLIC', 'DV_PATCH_ADMIN', 'DV_MONITOR', 
                       'DV_STREAMS_ADMIN', 'DV_GOLDENGATE_ADMIN',
                       'DV_XSTREAM_ADMIN', 'DV_GOLDENGATE_REDO_ACCESS', 
                       'DV_AUDIT_CLEANUP', 'DV_DATAPUMP_NETWORK_LINK', 
                       'DV_POLICY_OWNER');

    FOR i IN usrarr.first .. usrarr.last
    LOOP
      EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.user$ WHERE name = ''' ||
                         usrarr(i) || ''''
      INTO cntusr;
      IF (cntusr > 0) THEN
        -- The error is output as one line as DBCA cannot handle multiple lines
        RAISE_APPLICATION_ERROR (-20000, 'Prerequisite check for Database Vault installation failed. Name ''' || usrarr(i) || ''' conflicts with another user or role name. ''' || usrarr(i) || ''' is a default user/role created by the Database Vault installation process. ''' || usrarr(i) || ''' user or role must be dropped prior to installing Database Vault.');
      END IF;
    END LOOP;
  END IF; -- cntdv check

  :catmacdd_fn  := 'catmacdd.sql';
  :catmacs_fn   := 'catmacs.sql';
  :catmacc_fn   := 'catmacc.sql';
  :dvmacfnc_fn  := 'dvmacfnc.plb';
  :catmacp_fn   := 'catmacp.sql';
  :prvtmacp_fn  := 'prvtmacp.plb';
  :catmacg_fn   := 'catmacg.sql';
  :catmacr_fn   := 'catmacr.sql';
  :catmacd_fn   := 'catmacd.sql';
  :catmact_fn   := 'catmact.sql';
  :catmaca_fn   := 'catmaca.sql';
  :catmach_fn   := 'catmach.sql';
  :catmacpre_fn := 'catmacpre.sql';

  -- Disable the rest of the OLS triggers before DV install
  EXECUTE IMMEDIATE 'ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER LBACSYS.lbac$after_create DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE';
END;
/

-- bug 6938028: Database Vault Protected Schema.
-- Insert the rows into metaview$ for the real Data Pump types.
SELECT :catmacdd_fn FROM SYS.DUAL;
@@&catmacdd_file

-- Create the DV accounts
SELECT :catmacs_fn FROM SYS.DUAL;
@@&catmacs_file &1 &2 

-- Load MACSEC Factor Convenience Functions
SELECT :dvmacfnc_fn FROM SYS.DUAL;
@@&dvmacfnc_file

-- Load underlying DVSYS objects
SELECT :catmacc_fn FROM SYS.DUAL;
@@&catmacc_file

-- Load MAC packages.
SELECT :catmacp_fn FROM SYS.DUAL;
SELECT :prvtmacp_fn FROM SYS.DUAL;
@@&catmacp_file
@@&prvtmacp_file

-- tracing view
-- grants on DV objects to DV roles
-- create public synonyms for DV objects
SELECT :catmacg_fn FROM SYS.DUAL;
@@&catmacg_file

-- Load MAC roles.
SELECT :catmacr_fn FROM SYS.DUAL;
@@&catmacr_file

-- Load MAC seed data. Load NLS seed data from catmacd.sql - Bug Fix 10225918.
SELECT :catmacd_fn FROM SYS.DUAL;
@@&catmacd_file

-- create the DV login 
SELECT :catmact_fn FROM SYS.DUAL;
@@&catmact_file

-- establish DV audit policy
SELECT :catmaca_fn FROM SYS.DUAL;
@@&catmaca_file

--Removes privleges from the DVSYS and DVF accounts
--used during the install
SELECT :catmach_fn FROM SYS.DUAL;
@@&catmach_file

-- Other installation steps
-- Create DV owner and DV account manager accounts 
SELECT :catmacpre_fn FROM SYS.DUAL;
@@&catmacpre_file

commit;

@?/rdbms/admin/sqlsessend.sql

