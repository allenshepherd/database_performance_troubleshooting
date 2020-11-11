Rem
Rem $Header: rdbms/admin/catols.sql /main/20 2017/09/14 17:35:42 raeburns Exp $
Rem
Rem catols.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catols.sql - Install OLS packages.
Rem
Rem    DESCRIPTION
Rem      This is the main rdbms/admin install script for installing
Rem      Oracle Label Security which implement Label Based access
Rem      controls on rows of data.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catols.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catols.sql
Rem    SQL_PHASE: CATOLS 
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/10/17 - Bug 26255427: Store version_full for components
Rem    risgupta    02/16/16 - Bug 22733719: Must explictly set
Rem                           NLS_LENGTH_SEMANTICS to BYTE
Rem    youyang     06/23/11 - add pdb support
Rem    srtata      06/08/11 - OLS rearchitecture: proj 31942
Rem    sanbhara    05/20/11 - Project 24121 - removing need for shutdown at end
Rem                           of catols execution.
Rem    srtata      02/16/09 - remove logon trigger
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    srtata      03/12/03 - remove compatible check
Rem    srtata      04/25/02 - remove startup trigger.
Rem    srtata      02/22/02 - update to release_version.
Rem    srtata      02/22/02 - update to 9.2.0.1.0.
Rem    shwong      02/04/02 - create LBACSYS before dbms_registry.loading()
Rem    shwong      11/30/01 - modify dbms_registry.loading() parameters
Rem    shwong      10/10/01 - add OLS to registry
Rem    gmurphy     04/12/01 - remove connect & reorder trigger disables
Rem    gmurphy     04/06/01 - disable triggers after catlbac
Rem    gmurphy     03/15/01 - run as SYSDBA
Rem    gmurphy     03/02/01 - check compatible & cycle database once
Rem    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
Rem    gmurphy     01/29/01 - call catlbacs rather than lbacsys
Rem    gmurphy     01/15/01 - rename installlbac.sql to catols.sql
Rem    rsripada    12/29/00 - modify for use by dbCA
Rem    rsripada    10/16/00 - update for 8.1.7
Rem    cchui       05/03/00 - LBAC and secure access installation script

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

-- Enable OLS database triggers and restart the database, so users,
-- including SYS can logon to the server after this point.
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;

BEGIN
  dbms_registry.loaded('OLS'); -- use default versions and banner
  SYS.validate_ols;
END;
/
commit;

--shutdown immediate
--Project 24121 - calling following procedure to initialize all memory
--objects to complete label security installation.
exec LBACSYS.lbac_events.comp_install;

@?/rdbms/admin/sqlsessend.sql

