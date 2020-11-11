Rem
Rem $Header: rdbms/admin/olspatch.sql /main/11 2017/05/28 22:45:57 stanaya Exp $
Rem
Rem olspatch.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olspatch.sql - Oracle Label Security patch script
Rem
Rem    DESCRIPTION
Rem      This script is used to apply bugfixes to the OLS component.It is run 
Rem      in the context of catpatch.sql, after the RDBMS catalog.sql and 
Rem      catproc.sql scripts are run. It is run with a special EVENT set which
Rem      causes CREATE OR REPLACE statements to only recompile objects if the 
Rem      new source is different than the source stored in the database.
Rem      Tables, types, and public interfaces should not be changed here.
Rem
Rem    NOTES
Rem      Called from catpatch.sql
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olspatch.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olspatch.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    11/27/15 - Bug 22267756: Set current schema to LBACSYS
Rem    aramappa    07/29/13 - Bug 16593436: Add olsu121. Remove grant 
Rem                           on dbms_zhelp for upgrade to 12.1.0.2
Rem    jkati       07/01/11 - grant execute on sys.dbms_zhelp to lbacsys
Rem    srtata      06/29/11 - OLS rearch:12g
Rem    mjgreave    05/05/08 - Add support for OID enabled OLS.
Rem    srtata      02/26/08 - remove olsdap.sql as now it is 11.1.0 version and
Rem                           this script was intending to patch 92 DB
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/17/02 - call olsdap.sql
Rem    srtata      07/22/02 - srtata_bug-2434758_main
Rem    srtata      06/26/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols', 'LBACSYS');

-- Bug 22267756: Set current schema to LBACSYS
ALTER SESSION SET CURRENT_SCHEMA = LBACSYS;

-- upgrade from 12.1.0.1 to 12.1.0.2
@@olsu121.sql

--  Check if we need to run OID specific scripts later
COLUMN prvtolsldap NEW_VALUE prvtolsldap_script NOPRINT;

select
  decode(count(*), 1, 'prvtolsldap.plb', 'nothing.sql') as prvtolsldap
  from lbacsys.ols$props where name = 'OID_STATUS_FLAG'and value$ = 1;

-- Load underlying opaque types 
@@prvtolsopq.plb

-- Load All OLS packages
@@prvtolsdd.plb

-- Create views
@@catolsddv.sql
-- Add grants to packages and views
@@prvtolsgrnt.plb
--install dip package ( which depends on views)
@@prvtolsdip.plb

-- Run OID specific scripts - these may be null scripts if not OID enabled
@@&prvtolsldap_script

-- Bug 22267756: Reset current schema to SYS
ALTER SESSION SET CURRENT_SCHEMA = SYS;

BEGIN
  dbms_registry.loaded('OLS');
  SYS.validate_ols;
END;
/
commit;

