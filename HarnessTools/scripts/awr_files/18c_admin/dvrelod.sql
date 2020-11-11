Rem
Rem $Header: rdbms/admin/dvrelod.sql /main/7 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dvrelod.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvrelod.sql - Oracle Database Vault Reload Script
Rem
Rem    DESCRIPTION
Rem      This script is used to reload DV packages after a downgrade.
Rem    The dictionary objects are reset to the old release by the "e" script,
Rem    this reload script processes the "old" scripts to reload the "old"
Rem    version of the component using the "old" server.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dvrelod.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dvrelod.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: DOWNGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    NOTES
Rem     Called from Catrelod.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    namoham     06/03/15 - Bug 20216779: run catmacc.sql in lower version
Rem    sanbhara    09/29/11 - lrg 5834042 fix - removing call to sync_rules
Rem                           since the procedure has been removed in 12.1.
Rem                           Also removing call to catmacd.sql. Any changes 
Rem                           to DV metadata needs to be reflected in the dvuXXX
Rem                           and dveXXX scripts and not rely on catmacd being 
Rem                           reloaded.
Rem    ruparame    12/18/08 - Bug 7657506
Rem    ssonawan    12/02/08 - lrg 3706796: move sync_rules from dve111.sql
Rem    jheng       10/17/08 - invoking catmacd.sql for bug 7449805
Rem    mxu         01/26/07 - Fix error
Rem    rvissapr    12/01/06 - Database Vault Reload Script
Rem    rvissapr    12/01/06 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

--
-- Add Database Vault to the registry
--

Begin
 DBMS_REGISTRY.LOADING(comp_id     =>  'DV', 
                       comp_name   =>  'Oracle Database Vault', 
                       comp_proc   =>  'VALIDATE_DV', 
                       comp_schema =>  'DVSYS',
                       comp_schemas =>  dbms_registry.schema_list_t('DVF'));
End;
/


--
-- Reload all the packages, functions and procedures from previous release
--


ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

@@dvmacfnc.plb

-- Improvement bug 20216779
-- call catmacc.sql here so that we don't need to add "create or replace"
-- statements to dve versions above 121.
-- Please note that drop view/type statements should still be added
-- to dve script.
@@catmacc.sql

@@catmacp.sql

@@prvtmacp.plb

@@catmact.sql

--
-- Done Loading DV. Now Validate 
--

Begin
 dbms_registry.loaded('DV');
                      
 sys.validate_dv;
End;
/
   
ALTER SESSION SET CURRENT_SCHEMA = SYS;

COMMIT;
