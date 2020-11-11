Rem
Rem $Header: rdbms/admin/catolsd.sql /main/9 2016/02/29 02:23:03 risgupta Exp $
Rem
Rem catolsd.sql
Rem
Rem Copyright (c) 2002, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catolsd.sql - Install OLS packages with OID support
Rem
Rem    DESCRIPTION
Rem      This is the main rdbms/admin install script for installing
Rem      Oracle Label Security which implement Label Based access
Rem      controls on rows of data.  In addition, it enables OID support.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catolsd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catolsd.sql
Rem SQL_PHASE: CATOLSD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE 
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    02/23/16 - Bug 22733719: Must explictly set
Rem                           NLS_LENGTH_SEMANTICS to BYTE
Rem    aketkar     04/28/14 - sql metadata seed
Rem    sanbhara    07/07/11 - Project 24121 - removing requirement for shutdown
Rem                           immediate.
Rem    srtata      06/08/11 - OLS rearchitecture
Rem    srtata      02/16/09 - remove logon trigger
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    srtata      04/10/03 - remove compatible check
Rem    shwong      01/17/03 - add prvtsad.sql
Rem    shwong      11/04/02 - shwong_bug-2640184
Rem    shwong      10/24/02 - Created

@@?/rdbms/admin/sqlsessstart.sql

WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------

-- Bug 22733719: Must explictly set NLS_LENGTH_SEMANTICS to BYTE
alter session set NLS_LENGTH_SEMANTICS=BYTE;

-- Disable all OLS database triggers so the script can be re-run,
-- if desired.
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;
-- Create the LBACSYS account
@@catlbacs
-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols', 'LBACSYS');

-- Load underlying opaque types and LBACSYS table
@@prvtolsopq.plb
@@catolsdd.sql

-- Load All OLS packages
@@prvtolsdd.plb

-- Create views
@@catolsddv.sql
-- Add grants to packages and views
@@prvtolsgrnt.plb
--install dip package ( which depends on views)
@@prvtolsdip.plb


-- Update properties as OID enabled
@@prvtolsldap.plb

-- Enable OLS database triggers and restart the database, so users,
-- including SYS can logon to the server after this point.
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;

BEGIN
  dbms_registry.loaded('OLS', dbms_registry.release_version, 
            'Oracle Label Security Release ' || 
            dbms_registry.release_version    ||
            ' - ' || dbms_registry.release_status); 
  SYS.validate_ols;
END;
/
commit;

--shutdown immediate
--Project 24121 - calling following procedure to initialize all memory
--objects to complete label security installation.
exec LBACSYS.lbac_events.comp_install;

@?/rdbms/admin/sqlsessend.sql

