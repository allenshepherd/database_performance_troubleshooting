Rem
Rem $Header: rdbms/admin/dbmsoptim.sql /st_rdbms_18.0/1 2018/03/08 00:14:09 shvmalik Exp $
Rem
Rem dbmsoptim.sql
Rem
Rem Copyright (c) 2016, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsoptim.sql - package to manage optimizer fixes 
Rem
Rem    DESCRIPTION
Rem      This package is created to manage (enable/disable) optimizer fixes
Rem      provided as part of PSU/bundle 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsoptim.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsoptim.sql
Rem    SQL_PHASE: PATCH
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shvmalik    07/19/17 - #26476244: porting dbms_optim package
Rem    shvmalik    07/19/17 - Created
Rem    shvmalik    07/19/17 - #25509369: fixing compilation warnings
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PACKAGE dbms_optim_bundle AUTHID CURRENT_USER AS

---------------------------------------------------------------------------
--
-- PACKAGE NOTES
-- This package is created to manage (enable/disable) optimizer fixes
-- provided as part of PSU/bundle. By optimizer fixes, we mean, any fix
-- provided as part of bundle which has a fix_control and can possibly 
-- cause a plan change.
--
-- SECURITY
-- This package is only accessible to user SYS by default. You can control 
-- access to these routines by only granting execute to privileged users. 
-- Access to routines in this package should be exposed at pl/sql level 
-- very carefully.
--
-- USAGE:
-- User can invoke below procedure to enable/disable optimizer related fixes
--  enable_optim_fixes(action IN VARCHAR2, 
--                     scope IN VARCHAR2, 
--                     current_setting_precedence IN VARCHAR2)
--   Input arguments: 
--    action ( IN )
--      to enable/disable optimizer fixes
--      Acceptable values are 'ON'/'OFF'
--      Default is 'OFF'
--    scope ( IN )
--      scope of enabling/disabling the fixes
--      Acceptable values are MEMORY/SPFILE/BOTH/INITORA
--      MEMORY/SPFILE/BOTH: These three input values when used will
--                           enable/disable fixes in given scope
--      INITORA: This input value will just display the content to be 
--               added to init.ora to manage the fixes.
--      'current_setting_precedence' has no signifincance when scope=INITORA
--      Default is 'MEMORY'
--    current_setting_precedence (IN)
--      precedence of current setting over bundle's setting
--      Acceptable values are YES/NO
--      YES: current env settings take precedence in case of conflict
--      NO:  bundle settings take precedence in case of conflict
--      It does not hold any significance when SCOPE=INITORA
--      Default is 'YES'
-- Input values are case in-sensitive.
--
-- USAGE EXAMPLE:
-- 1. exec dbms_optim_bundle.enable_optim_fixes('ON','MEMORY', 'NO');
--    This will switch ON all optimizer fixes in memory which are present 
--    in bundle without considering their current env setting as 
--    current_setting_precedence is set to 'NO'
--
-- 2. exec dbms_optim_bundle.enable_optim_fixes('ON','BOTH', 'YES');
--    In case of non-conflicting values, this will switch ON all bundle related 
--    optimizer fixes in MEMORY and SPFILE both.
--    In case of conflict between bundle and current env setting, current
--    env will be given precedence.
--    It will also retain any additional setting already present in spfile.
--
-- 3. exec dbms_optim_bundle.enable_optim_fixes;
--    This will take default input values and  will work accordingly.
--
-- 4. exec dbms_optim_bundle.enable_optim_fixes('ON', 'INITORA');
--    This will display the command to be added to init.ora file.
--    It will not execute anything. It will just display what could
--    be added to init.ora file to make it work.
--
-- ERRORS:
-- Application errors used are:
--   -20001  user-supplied value error 
--   -20002  internal/other errors

PROCEDURE enable_optim_fixes(action IN VARCHAR2 default 'OFF', 
                             scope IN VARCHAR2 default 'MEMORY',
                             current_setting_precedence IN VARCHAR2 default 'YES');

-- USAGE:
-- User can invoke below procedure to display opimizer bug#s applied
-- as part of given PSU/bundle
--
-- getBugsforBundle(bundle IN NUMBER);
--
--  Input arguments:
--    bundle ( IN ): bundle Id
--    Possible Input Values:
--      1...N:  Display optimizer Bug#s for all bundles upto the specified Bundle
--      NULL:   Display optimizer Bug#s for default bundle i.e. latest bundle
--
-- USAGE EXAMPLE:
-- 1. exec dbms_optim_bundle.getBugsforBundle(9);
--    This will display bug#s for all bundles upto bundle 9
--
-- 2. exec dbms_optim_bundle.getBugsforBundle;
--    This will display bug#s for latest applied bundle
--
-- ERRORS:
-- Application errors used are:
--   -20001  user-supplied value error 
--   -20002  internal/other errors

PROCEDURE getBugsforBundle(bundleId IN NUMBER default NULL);
-- USAGE:
-- User can invoke below procedure to display bundle-ids and bundle-names
-- which have fixes with _fix_controls i.e. fixes which may cause plan change.
--
-- listBundlesWithFCFixes
--
--  Input arguments: None
--
-- USAGE EXAMPLE:
-- 1. exec dbms_optim_bundle.listBundlesWithFCFixes;
--    This will display all bundle-ids and names which have
--    fixes with _fix_controls.
--
-- ERRORS:
-- Application errors used are:
--   -20001  user-supplied value error 
--   -20002  internal/other errors
PROCEDURE listBundlesWithFCFixes;

END dbms_optim_bundle;
/

show errors;
