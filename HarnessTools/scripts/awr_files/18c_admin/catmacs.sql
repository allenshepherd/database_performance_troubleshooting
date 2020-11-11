Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmacs.sql
Rem
Rem    DESCRIPTION
Rem       Creates the Data Vault accounts for DVSYS, DVF
Rem       and grants the basic privileges 
Rem
Rem    NOTES
Rem      Run as SYSDBA
Rem        Parameter 1 = account default TS
Rem        Parameter 2 = account temp TS
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacs.sql
Rem SQL_PHASE: CATMACS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    06/14/17 - Bug 26246240: Update CONFIGURE_OLS calls
Rem    jibyun      04/21/17 - create DVSYS and DVF without password
Rem    risgupta    08/02/16 - Bug 23639570: Update OLS_ENFORCEMENT calls
Rem    yapli       06/16/16 - RTI 19487042: change default pwd for dvsys & dvf
Rem    youyang     03/30/16 - bug22865694:add grant on xs$obj
Rem    yapli       01/02/16 - Bug 22226617: Revoke select on user$ from dvsys
Rem    kaizhuan    09/17/15 - Bug 21609808: remove create/drop directory
Rem                           and execute on sys.utl_file privileges from dvsys 
Rem    jibyun      06/29/15 - Bug 21223263: do not grant INHERIT privilege on
Rem                           SYS to DVSYS
Rem    namoham     06/10/15 - Bug 20216779: make the script runnable in upgrade
Rem    yapli       03/10/15 - Bug 18779967
Rem    kaizhuan    11/21/14 - Project 46812: grant select on view 
Rem                           [g]v$code_clause to dvsys
Rem    aketkar     04/29/14 - sql patch metadata seed
Rem    jibyun      03/04/14 - Bug 17368273: remove unnecessary privs from DVSYS
Rem    srtata      08/29/11 - rename lbac$pol to ols$pol
Rem    rpang       08/03/11 - Proj 32719: grant inherit privileges
Rem    sanbhara    07/28/11 - Project 24121 - grants to dvsys to exec
Rem                           dbms_system and create and drop directory so
Rem                           dbms_macadm.add_nls_data works.
Rem    sanbhara    07/12/11 - Project 24121 - granting exec on UTL_FILE,
Rem                           lbacsys.configure_ols, and
Rem                           lbacsys.ols_enforcement to DVSYS.
Rem    cchui       06/18/11 - update with new OLS tables
Rem    jmadduku    02/17/11 - Proj32507: Grant Unlimited Tablespace with
Rem                           RESOURCE role
Rem    jsamuel     10/01/08 - simplfy patching
Rem    pknaggs     04/11/08 - bug 6938028: Database Vault protected schema.
Rem    pknaggs     06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs     05/31/07 - 5716741: sysdba can't do account management.
Rem    ruparame    01/10/07 - DV/DBCA Integration
Rem    rvissapr    12/01/06 - move PLSQL out of catmacs.sql into dvmacfnc.sql
Rem    jciminsk    05/02/06 - cleanup embedded file boilerplate 
Rem    jciminsk    05/02/06 - created admin/catmacs.sql 
Rem    sgaetjen    08/16/05 - Quote installer passwords, remove install accounts
Rem    sgaetjen    08/11/05 - sgaetjen_dvschema
Rem    sgaetjen    08/11/05 - Incorrect parameter placement 
Rem    sgaetjen    08/10/05 - Alter OLS account password 
Rem    sgaetjen    08/03/05 - Correct comments 
Rem    sgaetjen    08/03/05 - add commands to change system accounts using 
Rem                           installed password 
Rem    sgaetjen    08/01/05 - remove lock statement for DVSYS/DVF 
Rem    sgaetjen    07/30/05 - need to unlock account for install 
Rem    sgaetjen    07/28/05 - dos2unix
Rem    sgaetjen    07/25/05 - Created



@@?/rdbms/admin/sqlsessstart.sql

SET VERIFY OFF

Rem Bug 20216779 - make catmacs.sql runnable during upgrade.
Rem always expect DVSYS user to exist during upgrade. Anonymous
Rem block is added to mask the user exists error during upgrade.
BEGIN
  EXECUTE IMMEDIATE 'CREATE USER dvsys NO AUTHENTICATION
                     DEFAULT TABLESPACE &1
                     TEMPORARY TABLESPACE &2';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1920) THEN NULL; --user already created
     ELSE RAISE;
     END IF;
END;
/

Rem Revoke automatic grant of INHERIT PRIVILEGES from public, grant on SYS
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'REVOKE INHERIT PRIVILEGES ON USER dvsys FROM public';
exception
  when already_revoked then
    null;
end;
/

Rem Bug 20216779 - make catmacs.sql runnable during upgrade.
Rem always expect DVF user to exist during upgrade. Anonymous
Rem block is added to mask the user exists error during upgrade.
BEGIN
  EXECUTE IMMEDIATE 'CREATE USER dvf NO AUTHENTICATION
                     DEFAULT TABLESPACE &1
                     TEMPORARY TABLESPACE &2';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1920) THEN NULL; --user already created
     ELSE RAISE;
     END IF;
END;
/

Rem Revoke automatic grant of INHERIT PRIVILEGES from public
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 'REVOKE INHERIT PRIVILEGES ON USER dvf FROM public';
exception
  when already_revoked then
    null;
end;
/

GRANT CREATE PROCEDURE TO dvf
/

SET VERIFY ON
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants for Data Vault DVSYS user account
Rem
Rem
Rem
Rem

GRANT UNLIMITED TABLESPACE TO dvsys
/

GRANT EXECUTE ON sys.dbms_session TO dvsys
/
-- Privilege execute on dbms_system package is not necessary for DVSYS,
-- however, without such privilege would cause DB creation failure
-- on windows label. Need more investigation.
GRANT EXECUTE ON sys.dbms_system TO dvsys
/
GRANT READ ON sys.dba_dependencies TO dvsys
/

------------------------- OLS --------------------
-- these OLS grants need to be moved to an alternate script
-- that is selectively run based on configuration

GRANT SELECT ON lbacsys.ols$pol TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON lbacsys.ols$polt TO dvsys 
/
GRANT SELECT ON lbacsys.ols$lab TO dvsys  WITH GRANT OPTION
/
GRANT SELECT ON lbacsys.ols$levels TO dvsys
/
GRANT EXECUTE ON lbacsys.sa_session TO DVSYS
/
GRANT SELECT ON LBACSYS.ols$props TO DVSYS
/
GRANT EXECUTE ON SYS.ols_enforcement TO DVSYS
/
GRANT EXECUTE ON SYS.configure_ols TO DVSYS
/
GRANT EXECUTE ON LBACSYS.NUMERIC_DOMINATES TO DVSYS
/
GRANT EXECUTE ON LBACSYS.NUMERIC_LABEL_TO_CHAR TO DVSYS
/
GRANT EXECUTE ON LBACSYS.NUMERIC_STRICTLY_DOMINATES TO DVSYS
/
GRANT EXECUTE ON LBACSYS.SA_UTL TO DVSYS
/
GRANT EXECUTE ON LBACSYS.TO_NUMERIC_LABEL TO DVSYS
/
------------------------- ORACLE SYS SCHEMA  --------------------

GRANT READ ON sys.v_$instance TO dvsys
/

GRANT READ ON sys.gv_$instance TO dvsys
/

GRANT READ ON sys.gv_$session TO dvsys
/

GRANT READ ON sys.v_$session TO dvsys
/

GRANT READ ON sys.v_$database TO dvsys
/

GRANT READ ON sys.v_$parameter TO dvsys
/

GRANT READ ON sys.dba_roles TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.dba_role_privs TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.dba_sys_privs  TO dvsys
/

GRANT READ ON sys.dba_tab_privs  TO dvsys
/

GRANT READ ON sys.dba_synonyms TO dvsys
/

GRANT READ ON sys.dba_application_roles TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.proxy_roles TO dvsys  WITH GRANT OPTION
/

GRANT READ ON sys.dba_users TO dvsys  WITH GRANT OPTION
/

GRANT READ ON sys.dba_objects TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.dba_nested_tables TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.dba_context TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.objauth$ TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.sysauth$ TO dvsys  WITH GRANT OPTION
/

GRANT READ ON sys.obj$ TO dvsys  WITH GRANT OPTION
/

GRANT READ ON sys.tab$ TO dvsys  WITH GRANT OPTION
/

GRANT READ ON sys."_BASE_USER" TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.xs$obj TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.table_privilege_map TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.system_privilege_map TO dvsys WITH GRANT OPTION
/

GRANT READ ON sys.dba_recyclebin TO dvsys
/

-- required to store MAC Secure and MAC OLS data
GRANT CREATE ANY CONTEXT TO dvsys
/

GRANT DROP ANY CONTEXT TO dvsys
/

GRANT READ ON SYS.ALL_OBJECTS TO DVSYS
/
GRANT READ ON SYS.ALL_REGISTRY_BANNERS TO DVSYS
/
GRANT READ ON SYS.ALL_USERS TO DVSYS
/
GRANT EXECUTE ON SYS.DATABASE_NAME TO DVSYS
/
GRANT EXECUTE ON SYS.DBMS_ASSERT TO DVSYS
/
GRANT EXECUTE ON SYS.DBMS_SQL TO DVSYS
/
GRANT EXECUTE ON SYS.DBMS_STATS TO DVSYS
/
GRANT EXECUTE ON SYS.DBMS_UTILITY TO DVSYS
/
GRANT EXECUTE ON SYS.DBMS_XMLSTORE TO DVSYS
/
GRANT EXECUTE ON SYS.DICTIONARY_OBJ_NAME TO DVSYS
/
GRANT EXECUTE ON SYS.DICTIONARY_OBJ_OWNER TO DVSYS
/
GRANT EXECUTE ON SYS.DICTIONARY_OBJ_TYPE TO DVSYS
/
GRANT READ ON SYS.DUAL TO DVSYS
/
GRANT EXECUTE ON SYS.INSTANCE_NUM TO DVSYS
/
GRANT EXECUTE ON SYS.LOGIN_USER TO DVSYS
/
GRANT EXECUTE ON SYS.PLITBLM TO DVSYS
/
GRANT EXECUTE ON SYS.ROLENAME_ARRAY TO DVSYS
/
GRANT EXECUTE ON SYS.ROLE_ARRAY TO DVSYS
/
GRANT READ ON SYS.SESSION_CONTEXT TO DVSYS
/
GRANT READ ON SYS.SESSION_ROLES TO DVSYS
/
GRANT EXECUTE ON SYS.SQL_TXT TO DVSYS
/
GRANT EXECUTE ON SYS.SYSEVENT TO DVSYS
/
GRANT EXECUTE ON SYS.UTL_INADDR TO DVSYS
/
GRANT EXECUTE ON SYS.UTL_LMS TO DVSYS
/
GRANT READ ON SYS.V_$OPTION TO DVSYS
/
GRANT READ ON SYS.V_$VERSION TO DVSYS
/
GRANT EXECUTE ON SYS.XMLTYPE TO DVSYS
/
-- for secure application roles
GRANT CREATE ROLE TO dvsys
/

-- grant select on [G]V$CODE_CLAUSE to dvsys
GRANT READ ON sys.gv_$code_clause to dvsys WITH GRANT OPTION
/

GRANT READ ON sys.v_$code_clause to dvsys WITH GRANT OPTION
/

-- add DV to the registry must be done after DVSYS and DVF account are created
-- Register DVF as an ancillary schema
-- During upgrade, ignore this statement
DECLARE
  cnt NUMBER := 0;
BEGIN
  SELECT count(*) INTO cnt FROM sys.registry$ WHERE cid = 'DV' AND namespace = 'SERVER';

  -- If DV is not in the registry, it implies that this is a fresh installation
  IF (cnt = 0) THEN
    DBMS_REGISTRY.LOADING(comp_id      =>  'DV', 
                          comp_name    =>  'Oracle Database Vault', 
                          comp_proc    =>  'VALIDATE_DV', 
                          comp_schema  =>  'DVSYS',
                          comp_schemas =>  dbms_registry.schema_list_t('DVF'));
  END IF;
END;
/

-- LRG 2864624 fix
-- Granting Network Access privileges to DVSYS
-- Moved to configure_dv
commit;


@?/rdbms/admin/sqlsessend.sql 

