Rem
Rem $Header: rdbms/admin/olsrelod.sql /main/11 2017/10/10 12:10:25 raeburns Exp $
Rem
Rem olsrelod.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsrelod.sql - Oracle Label Security RELOaD script.
Rem
Rem    DESCRIPTION
Rem      This script is used to reload OLS packages after a downgrade. 
Rem      The dictionary objects are reset to the old release by the "e" script,
Rem      this reload script processes the "old" scripts to reload the 
Rem      "old" version of the component using the "old" server.
Rem
Rem    NOTES
Rem      Called from catrelod.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsrelod.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsrelod.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catrelod.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/29/17 - Bug 26815460: use default values for .loaded
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    risgupta    11/27/15 - Bug 22267756: Set current schema to LBACSYS
Rem    risgupta    09/14/15 - Bug 21748684: use olsload.sql to reload OLS
Rem                           packages and views
Rem    mjgreave    02/23/15 - bug 20352942: change length of file_name1
Rem    sanbhara    09/29/11 - lrg 5834042 fix - lbac$props has been renamed to
Rem                           ols$props.
Rem    srtata      06/29/11 - OLS rearch:12g
Rem    cchui       10/13/04 - 3936531: use validate_ols 
Rem    srtata      03/31/04 - check if OID enabled OLS 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/18/02 - srtata_bug-2625076
Rem    srtata      10/16/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols','LBACSYS');

-- Bug 22267756: Set current schema to LBACSYS
ALTER SESSION SET CURRENT_SCHEMA = LBACSYS;

-- OLS Packages' and Views' Load Script
@@olsload.sql

-- Bug 22267756: Reset current schema to SYS
ALTER SESSION SET CURRENT_SCHEMA = SYS;

BEGIN
  dbms_registry.loaded('OLS');
  SYS.validate_ols;
END;
/
commit;

