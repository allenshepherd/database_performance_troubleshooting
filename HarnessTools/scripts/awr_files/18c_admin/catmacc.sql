--
-- Copyright (c) 2006, 2017, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      catmacc.sql
--
--    DESCRIPTION
--       Creates the Data Vault tables and constraints for DVSYS schema
--
--    NOTES
--    This script is run by dvsys during install in catmac
--    It is also run by SYS with the DV_PATCH_ADMIN role from catmacpatch
--    All object names should qualified.
--
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacc.sql
Rem SQL_PHASE: CATMACC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
--    MODIFIED   (MM/DD/YY)
--    sjavagal    09/05/17 - Bug 26325568: Update ku$_ type and view related to
--                           dba_dv_datapump_auth with ACTION name column
--    mjgreave    06/12/17 - Bug 26584641: add unique object ids for ku$ view
--    jibyun      06/23/17 - Bug 26308167: increase the size of
--                           authentication_method in simulation_log$
--    gaurameh    06/12/17 - Bug 26257953: add unique id for ku$ view
--    qinwu       02/28/17 - proj 70151: support db capture and replay auth
--    risgupta    02/23/17 - Bug 25548633: Resolve security vunerability in
--                           DV_ID_TO_NAME
--    amunnoli    01/30/17 - Bug 25245797: do not reference UNIFIED_AUDIT_TRAIL
--                           with SYS prefix, but with AUDSYS prefix
--    risgupta    01/15/17 - Proj 67579: Metadata Changes for DV Simulation
--                           Mode Enhancements
--    gaurameh    01/04/17 - Bug 25296876: add unique id for ku$ views
--    jibyun      11/17/16 - Bug 25115178: qualify all the referneced objects
--    dalpern     10/15/16 - bug 22665467: add DV checks on DEBUG [CONNECT]
--    namoham     09/08/16 - Bug 24582583: increase the length of
--                           audit_trail.os_process field
--    kaizhuan    04/15/16 - Bug 22751770: remove function GET_CONTAINER_SCOPE
--    youyang     03/30/16 - bug22865694:show ras user in dba_dv_proxy_auth
--    yapli       03/01/16 - Bug 22840314: Change training api to simulation
--    youyang     02/15/16 - bug22672722:add index function in dv_auth
--    jibyun      02/01/16 - Bug 22296366: qualify objects referenced
--                           internally
--    yapli       01/26/16 - Bug 22558559: Filter double records in dvsys views
--    yapli       01/02/16 - Bug 22226617: Replace user$ with _BASE_USER
--    jibyun      11/23/15 - Bug 22246524: include ID in dba_dv_training_log
--    jibyun      11/01/15 - introduce DIAGNOSTIC authorization
--    youyang     09/23/15 - bug21793661: add unique id for ku$ views
--    sanbhara    08/14/15 - Bug 21299474 - adding scope field to
--                           realm$,rule$,rule_set$.
--    juilin      07/22/15  - Bug 21458522 rename syscontext IS_FEDERATION_ROOT
--    yanchuan    07/27/15 - Bug 21299533: support for Database Vault
--                           Authorization
--    amunnoli    07/07/15 - Proj 46892: Create DV Unified audit trail on
--                           UNIFIED_AUDIT_TRAIL, not on V$UNIFIED_AUDIT_TRAIL
--    namoham     06/24/15 - Bug 20216779: set dv_auth$.action for DDL to %
--    namoham     05/27/15 - Bug 21133991: drop and create dvsys.ku$_* types
--    yapli       05/27/15 - Bug 21143678: Change identifier declaration to 128
--    sanbhara    05/26/15 - adding realm_type to ku$_dv_realm_t.
--    yanchuan    05/18/15 - Bug 20682570/20796194: increase
--                           MAX_CLAUSE_PARA_LEN to 128
--    yapli       04/07/15 - Bug 20747653: Enabling filtering out default DV
--                           objects
--    kaizhuan    03/17/15 - Project 46814: support DV common policy
--    sanbhara    03/09/15 - Project 46814 - common command rule support
--    jibyun      01/05/15 - Update DP types for long identifier support
--    namoham     12/14/14 - Project 36761: Maintenance authorization
--    kaizhuan    11/21/14 - Project 46812: Support command rule fine grained
--                           level protection for ALTER SYSTEM/SESSION
--    jibyun      11/17/14 - Project 46812: support TRAINING mode
--    jibyun      08/16/14 - Project 46812: support for Database Vault policy
--    namoham     07/24/14 - Bug 19263135: Create common view for
--                           sys.dba_dv_status
--    namoham     07/07/14 - Bug 19127377: create dba_dv_preprocessor_auth view
--    aketkar     04/29/14 - sql patch metadata seed
--    namoham     12/16/13 - Bug 17969287: create sys.dba_dv_status view
--    kaizhuan    09/10/13 - Bug 17342864: modify tables command_rule$,
--                           realm_auth$, realm_object$ unique key contraints
--                           and change owner/object_owner/grantee column from
--                           NOT NULL to NULL.
--    namoham     07/24/13 - Bug 15988264: Add dba_dv_status view 
--    jibyun      06/03/13 - Bug 16903007: remove static realm support
--    sanbhara    02/19/13 - Bug 16291881 - fixing dvlang to use bind
--                           variables.
--    jibyun      09/25/12 - Bug 14663267: add NOT NULL to enabled in
--                           rule_set_rule$
--    yanchuan    07/17/12 - bug 14456083: add view DVSYS.dba_dv_tts_auth
--    kaizhuan    07/25/12 - Bug 8420170: extend object_type column size
--                           from 19 to 32
--    sanbhara    07/19/12 - Bug 14306557 - adding dba_dv_patch_admin_audit
--                           view.
--    youyang     03/13/12 - bug10088587:add DDL authorization
--    jibyun      04/13/12 - Bug 13962309: DV_AUDIT_CLEANUP_GRANTEES view
--    jibyun      03/12/12 - Bug 13728213: DVSYS.dba_dv_dictionary_accts view
--    sanbhara    02/28/12 - Bug 13699578 - introducing temporary tables for
--                           *_t$ tables.
--    youyang     01/17/12 - add proxy authorization views
--    jibyun      01/25/12 - Bug 13618172: add additional outer join to
--                           dv$realm_auth and dba_dv_realm_auth views
--    sanbhara    11/21/11 - Create Views for Enforcement and Configuration
--                           change audit records on V$UNIFIED_AUDIT_TRAIL.
--    youyang     11/15/11 - lrg6549711: use dbms_assert in dvsys.dvlang
--    youyang     09/28/11 - fix lrg 5946195 to change view definition
--    srtata      08/29/11 - rename lbac$pol to ols$pol
--    sanbhara    08/29/11 - Create Views for Enforcement and Configuration
--                           change audit records.
--    sanbhara    07/25/11 - Project 24123 - add columns grantee and 
--                           enabled_status to dvsys.audit_tral$.
--    jibyun      07/27/11 - Bug 7118790: insert ORADEBUG row to DV_AUTH$ to
--                           enable ORADEBUG by default
--    srtata      06/28/11 - OLS rearch: new schema
--    youyang     04/26/11 - add static realm
--    youyang     04/26/11 - change user name to id
--    youyang     05/17/11 - bug12395489: lower case user name in dv roles
--                           grantees list
--    sanbhara    04/25/11 - Project 24121 - adding dvsys.enforce$ table.
--    traney      03/30/11 - 35209: long identifiers dictionary upgrade
--    youyang     02/08/10 - add realm type to realm
--    jheng       01/03/11 - add uesr ID# columns in dv_auth$
--    jheng       01/02/11 - fix bug 8501924
--    jheng       12/04/10 - add dba_dv_datapump_auth view
--    youyang     07/18/10 - Bug9671705: change definition of
--                           DVSYS.dba_dv_user_privs and
--                           DVSYS.dba_dv_user_privs_all
--    ruparame    03/30/09 - Bug 8393717 Change the datapump rule set name to
--                           Allow Oracle Data Pump Operation
--    youyang     03/27/09 - Bug 8385541: to qualify session_roles
--    jheng       02/17/09 - create DV Job table to store metadata
--    jsamuel     02/17/09 - bug 8248684 - fix insert into dvsys.config
--    jsamuel     02/03/09 - qualify view names for Data Pump schemas
--    srtata      12/29/08 - static rulesets
--    jsamuel     10/27/08 - remove error messages with anonymous blocks
--    clei        09/03/08 - Bug 6435192: add config$
--    ruparame    08/18/08 - Bug 7319691: Create DV_MONITOR role
--    pknaggs     07/07/08 - bug 6938028: add Factor and Role support for DVPS.
--    pknaggs     04/11/08 - bug 6938028: Database Vault Protected Schema.
--    jibyun      11/16/07 - To fix Bug 6497886
--    jibyun      07/30/07 - To fix Bug 6068504: add row cache for rule set
--    prramakr    07/11/07 - fix for bugs, 6110305, 6110298
--    jiyang      11/27/06 - update views for true multilingual support
--    cchui       06/30/06 - add views to see grantees of DV roles 
--    sgaetjen    05/17/06 - increase length of factor description 
--    jciminsk    05/02/06 - cleanup embedded file boilerplate 
--    jciminsk    05/02/06 - created admin/catmacc.sql 
--    ayalaman    04/06/06 - temporary table for command context 
--    sgaetjen    01/10/06 - add space for multibyte 
--    sgaetjen    01/03/06 - add UK on factor.name 
--    sgaetjen    11/14/05 - add unique constraints to language specific names 
--    sgaetjen    11/08/05 - unit test fixes 
--    sgaetjen    11/03/05 - add MAC OLS policy error label, add NLS tables
--    sgaetjen    08/11/05 - sgaetjen_dvschema
--    sgaetjen    07/28/05 - dos2unix
--    sgaetjen    07/25/05 - ADE check in
--    raustin     11/30/04 - Created

-- DV enforcement status, at this point DV cannot be enforced.
-- The status will be updated to 1 when DV installation is completed.


@@?/rdbms/admin/sqlsessstart.sql

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS.CONFIG$ (STATUS NUMBER unique)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

DECLARE
NUM NUMBER;

BEGIN
SELECT COUNT(*) INTO NUM FROM DVSYS.CONFIG$;
IF NUM = 0 THEN 
EXECUTE IMMEDIATE 'INSERT INTO DVSYS.CONFIG$ (STATUS) VALUES (0)';
 END IF;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

--DV enforcement status

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS.ENFORCE$ (STATUS NUMBER unique)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

DECLARE
NUM NUMBER;

BEGIN
SELECT COUNT(*) INTO NUM FROM DVSYS.ENFORCE$;
IF NUM = 0 THEN 
EXECUTE IMMEDIATE 'INSERT INTO DVSYS.ENFORCE$ (STATUS) VALUES (0)';
 END IF;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/


BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."MAC_POLICY$"
(
"ID#" NUMBER NOT NULL,
"POLICY_ID#" NUMBER NOT NULL,
"ALGORITHM_CODE_ID#" NUMBER NOT NULL,
"ERROR_LABEL" VARCHAR2 (4000),
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."CODE$"
(
"ID#" NUMBER NOT NULL,
"CODE_GROUP" VARCHAR2 (128) NOT NULL,
"CODE" VARCHAR2 (128) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."CODE_T$"
(
"ID#" NUMBER NOT NULL,
"VALUE" VARCHAR2 (4000),
"DESCRIPTION" VARCHAR2 (1024),
"LANGUAGE" VARCHAR2 (3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."MAC_POLICY_FACTOR$"
(
"ID#" NUMBER NOT NULL,
"FACTOR_ID#" NUMBER NOT NULL,
"MAC_POLICY_ID#" NUMBER NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."FACTOR$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"FACTOR_TYPE_ID#" NUMBER NOT NULL,
"ASSIGN_RULE_SET_ID#" NUMBER,
"GET_EXPR" VARCHAR2 (1024),
"VALIDATE_EXPR" VARCHAR2 (1024),
"IDENTIFIED_BY" NUMBER NOT NULL,
"NAMESPACE" VARCHAR2(128),
"NAMESPACE_ATTRIBUTE" VARCHAR2(128),
"LABELED_BY" NUMBER NOT NULL,
"EVAL_OPTIONS" NUMBER NOT NULL,
"AUDIT_OPTIONS" NUMBER NOT NULL,
"FAIL_OPTIONS" NUMBER NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."FACTOR_T$"
(
"ID#" NUMBER NOT NULL,
"DESCRIPTION" VARCHAR2 (4000),
"LANGUAGE" VARCHAR2 (3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."FACTOR_TYPE$"
(
"ID#" NUMBER NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."FACTOR_TYPE_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"DESCRIPTION" VARCHAR2 (1024),
"LANGUAGE" VARCHAR2 (3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."COMMAND_RULE$"
(
"ID#" NUMBER NOT NULL,
"CODE_ID#" NUMBER NOT NULL,
"RULE_SET_ID#" NUMBER NOT NULL,
"OBJECT_OWNER" VARCHAR2 (128),
"OBJECT_OWNER_UID#" NUMBER NOT NULL,
"OBJECT_NAME" VARCHAR2 (128) NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"PRIVILEGE_SCOPE" NUMBER,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE,
"CLAUSE_ID#" NUMBER DEFAULT 0 NOT NULL,
"PARAMETER_NAME" VARCHAR2 (128) DEFAULT ''%'' NOT NULL,
"EVENT_NAME" VARCHAR2 (128) DEFAULT ''%'' NOT NULL,
"COMPONENT_NAME" VARCHAR2 (128) DEFAULT ''%'' NOT NULL,
"ACTION_NAME" VARCHAR2 (128) DEFAULT ''%'' NOT NULL,
"SCOPE" NUMBER DEFAULT 1,
"PL_SQL_STACK" NUMBER DEFAULT 0
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."FACTOR_LINK$"
(
"ID#" NUMBER NOT NULL,
"PARENT_FACTOR_ID#" NUMBER NOT NULL,
"CHILD_FACTOR_ID#" NUMBER NOT NULL,
"LABEL_IND" VARCHAR2 (1) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."ROLE$"
(
"ID#" NUMBER NOT NULL,
"ROLE" VARCHAR2 (128) NOT NULL,
"RULE_SET_ID#" NUMBER NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."IDENTITY$"
(
"ID#" NUMBER NOT NULL,
"FACTOR_ID#" NUMBER NOT NULL,
"VALUE" VARCHAR2 (1024) NOT NULL,
"TRUST_LEVEL" NUMBER,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."IDENTITY_MAP$"
(
"ID#" NUMBER NOT NULL,
"IDENTITY_ID#" NUMBER NOT NULL,
"FACTOR_LINK_ID#" NUMBER,
"OPERATION_CODE_ID#" NUMBER NOT NULL,
"OPERAND1" VARCHAR2 (1024),
"OPERAND2" VARCHAR2 (1024),
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."RULE$"
(
"ID#" NUMBER NOT NULL,
"RULE_EXPR" VARCHAR2 (1024) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE,
"SCOPE" NUMBER DEFAULT 1
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."RULE_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"LANGUAGE" VARCHAR2(3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."POLICY_LABEL$"
(
"ID#" NUMBER NOT NULL,
"IDENTITY_ID#" NUMBER NOT NULL,
"POLICY_ID#" NUMBER NOT NULL,
"LABEL_ID#" NUMBER NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."RULE_SET_RULE$"
(
"ID#" NUMBER NOT NULL,
"RULE_SET_ID#" NUMBER NOT NULL,
"RULE_ID#" NUMBER NOT NULL,
"RULE_ORDER" NUMBER NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."RULE_SET$"
(
"ID#" NUMBER NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"EVAL_OPTIONS" NUMBER NOT NULL,
"AUDIT_OPTIONS" NUMBER NOT NULL,
"FAIL_OPTIONS" NUMBER NOT NULL,
"FAIL_CODE" VARCHAR2 (10),
"HANDLER_OPTIONS" NUMBER NOT NULL,
"HANDLER" VARCHAR2 (1024),
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE,
"SCOPE" NUMBER DEFAULT 1
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."RULE_SET_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"DESCRIPTION" VARCHAR2 (1024),
"FAIL_MESSAGE" VARCHAR2 (80),
"LANGUAGE" VARCHAR2(3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."REALM_OBJECT$"
(
"ID#" NUMBER NOT NULL,
"REALM_ID#" NUMBER NOT NULL,
"OWNER" VARCHAR2 (128),
"OWNER_UID#" NUMBER NOT NULL,
"OBJECT_NAME" VARCHAR2 (128) NOT NULL,
"OBJECT_TYPE" VARCHAR2 (32) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."REALM_AUTH$"
(
"ID#" NUMBER NOT NULL,
"REALM_ID#" NUMBER NOT NULL,
"GRANTEE" VARCHAR2 (128),
"GRANTEE_UID#" NUMBER NOT NULL,
"AUTH_RULE_SET_ID#" NUMBER,
"AUTH_OPTIONS" NUMBER,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE ,
"SCOPE" NUMBER DEFAULT 1
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."REALM$"
(
"ID#" NUMBER NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"AUDIT_OPTIONS" NUMBER NOT NULL,
"REALM_TYPE" NUMBER,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (128),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (128),
"UPDATE_DATE" DATE,
"SCOPE" NUMBER DEFAULT 1,
"PL_SQL_STACK" NUMBER DEFAULT 0
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."REALM_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"DESCRIPTION" VARCHAR2 (1024),
"LANGUAGE" VARCHAR2(3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-- Bug 24582583
-- ACTION_NAME value is taken from dvsys.code_t$.value field which is of
-- length 4000. Increase the field size to match it.
-- OS_PROCESS value is taken from sys.gv_$session.process field which is
-- of length 24. Increase the field size to match it.
--
-- Note1: AUDIT_OPTION usually records a DV provided table name which cannot
-- exceed 128 characters, but here, we set AUDIT_OPTION to 4000. This field
-- is kept as it is as it does not affect the functionality. Further, we may
-- record additional information in this field in the future.
--
-- Note2: ACTION_COMMAND stores the SQL string. Currently it is set to 4000.
-- We may set to CLOB to accomodate for SQL strings longer than 4000.
BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS.AUDIT_TRAIL$
(
ID# NUMBER,
OS_USERNAME VARCHAR2 (255),
USERNAME VARCHAR2 (128),
USERHOST VARCHAR2 (128),
TERMINAL VARCHAR2 (255),
TIMESTAMP DATE,
OWNER VARCHAR2 (128),
OBJ_NAME VARCHAR2 (128),
ACTION NUMBER NOT NULL,
ACTION_NAME VARCHAR2 (4000),
ACTION_OBJECT_ID NUMBER,
ACTION_OBJECT_NAME VARCHAR2 (128),
ACTION_COMMAND VARCHAR2 (4000),
AUDIT_OPTION VARCHAR2 (4000),
RULE_SET_ID NUMBER,
RULE_SET_NAME VARCHAR2 (128),
RULE_ID NUMBER,
RULE_NAME VARCHAR2 (128),
FACTOR_CONTEXT VARCHAR2 (4000),
COMMENT_TEXT VARCHAR2 (4000),
SESSIONID NUMBER NOT NULL,
ENTRYID NUMBER NOT NULL,
STATEMENTID NUMBER NOT NULL,
RETURNCODE NUMBER NOT NULL,
EXTENDED_TIMESTAMP TIMESTAMP(6) WITH TIME ZONE,
PROXY_SESSIONID NUMBER,
GLOBAL_UID VARCHAR2 (32),
INSTANCE_NUMBER NUMBER,
OS_PROCESS VARCHAR2 (24),
CREATED_BY VARCHAR2 (128),
CREATE_DATE DATE,
UPDATED_BY VARCHAR2 (128),
UPDATE_DATE DATE,
GRANTEE VARCHAR2 (128),
ENABLED_STATUS VARCHAR2 (1)
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$enforcement_audit
AS SELECT
     ID#
   , OS_USERNAME
   , USERNAME
   , USERHOST
   , TERMINAL
   , TIMESTAMP
   , OWNER
   , OBJ_NAME
   , ACTION
   , ACTION_NAME
   , ACTION_OBJECT_ID
   , ACTION_OBJECT_NAME
   , ACTION_COMMAND
   , AUDIT_OPTION
   , RULE_SET_ID
   , RULE_SET_NAME
   , RULE_ID
   , RULE_NAME
   , FACTOR_CONTEXT
   , COMMENT_TEXT
   , SESSIONID
   , ENTRYID
   , STATEMENTID
   , RETURNCODE
   , EXTENDED_TIMESTAMP
   , PROXY_SESSIONID
   , GLOBAL_UID
   , INSTANCE_NUMBER
   , OS_PROCESS
   , CREATED_BY
   , CREATE_DATE
   , UPDATED_BY
   , UPDATE_DATE
FROM DVSYS.AUDIT_TRAIL$ where ACTION < 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$configuration_audit
AS SELECT
     ID#
   , OS_USERNAME
   , USERNAME
   , USERHOST
   , TERMINAL
   , TIMESTAMP
   , OWNER
   , OBJ_NAME
   , ACTION
   , ACTION_NAME
   , ACTION_OBJECT_ID
   , ACTION_OBJECT_NAME
   , ACTION_COMMAND
   , AUDIT_OPTION
   , RULE_SET_ID
   , RULE_SET_NAME
   , RULE_ID
   , RULE_NAME
   , FACTOR_CONTEXT
   , COMMENT_TEXT
   , SESSIONID
   , ENTRYID
   , STATEMENTID
   , RETURNCODE
   , EXTENDED_TIMESTAMP
   , PROXY_SESSIONID
   , GLOBAL_UID
   , INSTANCE_NUMBER
   , OS_PROCESS
   , CREATED_BY
   , CREATE_DATE
   , UPDATED_BY
   , UPDATE_DATE
   , GRANTEE
   , ENABLED_STATUS
FROM DVSYS.AUDIT_TRAIL$ where ACTION > 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW AUDSYS.dv$configuration_audit
(
     OS_USER
   , USERID
   , HOST_NAME
   , TERMINAL
   , EVENT_TIMESTAMP
   , OBJ_OWNER
   , OBJ_NAME
   , DV_ACTION_CODE
   , DV_ACTION_NAME
   , DV_ACTION_OBJECT_NAME
   , SQL_TEXT
   , DV_RULE_SET_NAME
   , DV_FACTOR_CONTEXT
   , DV_COMMENT
   , SESSIONID
   , ENTRY_ID
   , STATEMENT_ID
   , DV_RETURN_CODE
   , PROXY_USERID
   , GLOBAL_USERID
   , INSTANCE_ID
   , OS_PROCESS
   , DV_GRANTEE
   , DV_OBJECT_STATUS
)
AS SELECT
     OS_USERNAME
   , DBUSERNAME
   , USERHOST
   , TERMINAL
   , EVENT_TIMESTAMP
   , OBJECT_SCHEMA
   , OBJECT_NAME
   , DV_ACTION_CODE
   , DV_ACTION_NAME
   , DV_ACTION_OBJECT_NAME
   , SQL_TEXT 
   , DV_RULE_SET_NAME
   , DV_FACTOR_CONTEXT
   , DV_COMMENT
   , SESSIONID
   , ENTRY_ID
   , STATEMENT_ID
   , DV_RETURN_CODE
   , DBPROXY_USERNAME
   , GLOBAL_USERID
   , INSTANCE_ID
   , OS_PROCESS
   , DV_GRANTEE
   , DV_OBJECT_STATUS
FROM audsys.unified_audit_trail where audit_type = ''Database Vault'' and DV_ACTION_CODE > 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW AUDSYS.dv$enforcement_audit
(
     OS_USER
   , USERID
   , HOST_NAME
   , TERMINAL
   , EVENT_TIMESTAMP
   , OBJ_OWNER
   , OBJ_NAME
   , DV_ACTION_CODE
   , DV_ACTION_NAME
   , DV_ACTION_OBJECT_NAME
   , SQL_TEXT
   , DV_RULE_SET_NAME
   , DV_FACTOR_CONTEXT
   , DV_COMMENT
   , SESSIONID
   , ENTRY_ID
   , STATEMENT_ID
   , DV_RETURN_CODE
   , PROXY_USERID
   , GLOBAL_USERID
   , INSTANCE_ID
   , OS_PROCESS
   , DV_GRANTEE
   , DV_OBJECT_STATUS
)
AS SELECT
     OS_USERNAME
   , DBUSERNAME
   , USERHOST
   , TERMINAL
   , EVENT_TIMESTAMP
   , OBJECT_SCHEMA
   , OBJECT_NAME
   , DV_ACTION_CODE
   , DV_ACTION_NAME
   , DV_ACTION_OBJECT_NAME
   , SQL_TEXT 
   , DV_RULE_SET_NAME
   , DV_FACTOR_CONTEXT
   , DV_COMMENT
   , SESSIONID
   , ENTRY_ID
   , STATEMENT_ID
   , DV_RETURN_CODE
   , DBPROXY_USERNAME
   , GLOBAL_USERID
   , INSTANCE_ID
   , OS_PROCESS
   , DV_GRANTEE
   , DV_OBJECT_STATUS
FROM audsys.unified_audit_trail where audit_type = ''Database Vault'' and DV_ACTION_CODE < 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-- table to store the DV authorization metadata
-- This table is created as a dummy table on 11.2 to store the DV Job 
-- authorization user information. It might be useful for upgrading in
-- future, when rule set evalution method used in DV/Job txn  and datapunmp txn
-- is replaced by row cache table.
BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."DV_AUTH$"
(
"GRANT_TYPE"  VARCHAR2 (19) NOT NULL,
"GRANTEE" VARCHAR2 (128),
"GRANTEE_ID" NUMBER,
"OBJECT_OWNER" VARCHAR2 (128),
"OBJECT_OWNER_ID" NUMBER,
"OBJECT_NAME" VARCHAR2 (128),
"OBJECT_TYPE" VARCHAR2 (32),
"ACTION" VARCHAR2 (30) DEFAULT ''%''
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-- Insert ORADEBUG row to DV_AUTH$ so that ORADEBUG is enabled by default.
BEGIN
EXECUTE IMMEDIATE 'INSERT INTO DVSYS.DV_AUTH$ (GRANT_TYPE)
                     SELECT ''ORADEBUG'' FROM DUAL
                     WHERE NOT EXISTS (SELECT 1 FROM DVSYS.DV_AUTH$
                                       WHERE GRANT_TYPE = ''ORADEBUG'')';
END;
/

-- Use 2147483636 as uid for '%'.
define all_schema = 2147483636;

-- Insert DDL, %, % to DV_AUTH$ so that DDL is enabled by default.
BEGIN
EXECUTE IMMEDIATE 'INSERT INTO DVSYS.DV_AUTH$ 
  (GRANT_TYPE, GRANTEE_ID, OBJECT_OWNER_ID, OBJECT_NAME, OBJECT_TYPE, ACTION)
     SELECT ''DDL'', &all_schema, &all_schema,''%'', ''%'', ''%'' FROM DUAL
     WHERE NOT EXISTS 
           (SELECT 1 FROM DVSYS.DV_AUTH$ 
            WHERE GRANT_TYPE = ''DDL'' 
                  AND GRANTEE_ID = &all_schema
                  AND OBJECT_OWNER_ID = &all_schema
                  AND OBJECT_NAME = ''%''
                  AND OBJECT_TYPE = ''%''
                  AND ACTION = ''%'')';
END;
/

-- command context current used for drop user cascade context 
BEGIN
EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE DVSYS.DV$CMDCONTEXT
 (cmdtype VARCHAR2(30),
  status VARCHAR(10))
on commit preserve rows';

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."AUDIT_TRAIL$"
ADD CONSTRAINT "AUDIT_TRAIL$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/


BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY$"
ADD CONSTRAINT "MAC_POLICY$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."CODE$"
ADD CONSTRAINT "CODE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY_FACTOR$"
ADD CONSTRAINT "MAC_POLICY_FACTOR$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR$"
ADD CONSTRAINT "FACTOR$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR$"
ADD CONSTRAINT "FACTOR$_UK1" UNIQUE
(
"NAME"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_T$"
ADD CONSTRAINT "FACTOR_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_TYPE$"
ADD CONSTRAINT "FACTOR_TYPE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_TYPE_T$"
ADD CONSTRAINT "FACTOR_TYPE_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_TYPE_T$"
ADD CONSTRAINT "FACTOR_TYPE_T$_UK2" UNIQUE
(
"NAME"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_LINK$"
ADD CONSTRAINT "FACTOR_LINK$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_LINK$"
ADD CONSTRAINT "FACTOR_LINK$_UK1" UNIQUE
(
"PARENT_FACTOR_ID#",
"CHILD_FACTOR_ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."ROLE$"
ADD CONSTRAINT "ROLE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."ROLE$"
ADD CONSTRAINT "ROLE$_UK1" UNIQUE
(
"ROLE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY$"
ADD CONSTRAINT "IDENTITY$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY$"
ADD CONSTRAINT "IDENTITY$_UK1" UNIQUE
(
"FACTOR_ID#",
"VALUE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
ADD CONSTRAINT "IDENTITY_MAP$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE$"
ADD CONSTRAINT "RULE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_T$"
ADD CONSTRAINT "RULE_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_T$"
ADD CONSTRAINT "RULE_T$_UK2" UNIQUE
(
"NAME"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_LABEL$"
ADD CONSTRAINT "IDENTITY_LABEL$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_LABEL$"
ADD CONSTRAINT "POLICY_LABEL$_UK1" UNIQUE
(
"IDENTITY_ID#",
"POLICY_ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_RULE$"
ADD CONSTRAINT "RULE_SET_RULE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_RULE$"
ADD CONSTRAINT "RULE_SET_RULE$_UK1" UNIQUE
(
"RULE_SET_ID#",
"RULE_ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET$"
ADD CONSTRAINT "RULE_SET$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_T$"
ADD CONSTRAINT "RULE_SET_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_T$"
ADD CONSTRAINT "RULE_SET_T$_UK2" UNIQUE
(
"NAME"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$"
ADD CONSTRAINT "REALM_OBJECT$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
ADD CONSTRAINT "REALM_AUTH$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM$"
ADD CONSTRAINT "REALM$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_T$"
ADD CONSTRAINT "REALM_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_T$"
ADD CONSTRAINT "REALM_T$_UK2" UNIQUE
(
"NAME"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY$"
ADD CONSTRAINT "MAC_POLICY$_FK1" FOREIGN KEY
(
"ALGORITHM_CODE_ID#"
)
REFERENCES DVSYS."CODE$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY_FACTOR$"
ADD CONSTRAINT "MAC_POLICY_FACTOR$_FK" FOREIGN KEY
(
"FACTOR_ID#"
)
REFERENCES DVSYS."FACTOR$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY_FACTOR$"
ADD CONSTRAINT "MAC_POLICY_FACTOR$_FK1" FOREIGN KEY
(
"MAC_POLICY_ID#"
)
REFERENCES DVSYS."MAC_POLICY$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR$"
ADD CONSTRAINT "FACTOR$_FK" FOREIGN KEY
(
"FACTOR_TYPE_ID#"
)
REFERENCES DVSYS."FACTOR_TYPE$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR$"
ADD CONSTRAINT "FACTOR$_FK1" FOREIGN KEY
(
"ASSIGN_RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_FK" FOREIGN KEY
(
"RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_FK1" FOREIGN KEY
(
"CODE_ID#"
)
REFERENCES DVSYS."CODE$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_LINK$"
ADD CONSTRAINT "FACTOR_LINK$_FK" FOREIGN KEY
(
"PARENT_FACTOR_ID#"
)
REFERENCES DVSYS."FACTOR$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."FACTOR_LINK$"
ADD CONSTRAINT "FACTOR_LINK$_FK1" FOREIGN KEY
(
"CHILD_FACTOR_ID#"
)
REFERENCES DVSYS."FACTOR$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."ROLE$"
ADD CONSTRAINT "ROLE$_FK" FOREIGN KEY
(
"RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/


BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY$"
ADD CONSTRAINT "IDENTITY$_FK" FOREIGN KEY
(
"FACTOR_ID#"
)
REFERENCES DVSYS."FACTOR$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
ADD CONSTRAINT "IDENTITY_MAP$_FK" FOREIGN KEY
(
"IDENTITY_ID#"
)
REFERENCES DVSYS."IDENTITY$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
ADD CONSTRAINT "IDENTITY_MAP$_FK1" FOREIGN KEY
(
"FACTOR_LINK_ID#"
)
REFERENCES DVSYS."FACTOR_LINK$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
ADD CONSTRAINT "IDENTITY_MAP$_FK2" FOREIGN KEY
(
"OPERATION_CODE_ID#"
)
REFERENCES DVSYS."CODE$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_LABEL$"
ADD CONSTRAINT "IDENTITY_LABEL$_FK" FOREIGN KEY
(
"IDENTITY_ID#"
)
REFERENCES DVSYS."IDENTITY$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_RULE$"
ADD CONSTRAINT "RULE_SET_RULE$_FK" FOREIGN KEY
(
"RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."RULE_SET_RULE$"
ADD CONSTRAINT "RULE_SET_RULE$_FK1" FOREIGN KEY
(
"RULE_ID#"
)
REFERENCES DVSYS."RULE$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$"
ADD CONSTRAINT "REALM_OBJECT$_FK" FOREIGN KEY
(
"REALM_ID#"
)
REFERENCES DVSYS."REALM$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
ADD CONSTRAINT "REALM_AUTH$_FK" FOREIGN KEY
(
"REALM_ID#"
)
REFERENCES DVSYS."REALM$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
ADD CONSTRAINT "REALM_AUTH$_FK1" FOREIGN KEY
(
"AUTH_RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY$"
ADD CONSTRAINT "MAC_POLICY$_UK1" UNIQUE
(
POLICY_ID#
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/


BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."CODE$"
ADD CONSTRAINT "CODE$_UK1" UNIQUE
(
CODE_GROUP
, CODE
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."MAC_POLICY_FACTOR$"
ADD CONSTRAINT "MAC_POLICY_FACTOR$_UK1" UNIQUE
(
FACTOR_ID#
,MAC_POLICY_ID#
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_UK1" UNIQUE
(
CODE_ID#
,CLAUSE_ID#
,PARAMETER_NAME
,EVENT_NAME
,COMPONENT_NAME
,ACTION_NAME
,OBJECT_OWNER_UID#
,OBJECT_NAME
,SCOPE
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$"
ADD CONSTRAINT "REALM_OBJECT$_UK1" UNIQUE
(
REALM_ID#
, OWNER_UID#
, OBJECT_NAME
, OBJECT_TYPE
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
ADD CONSTRAINT "REALM_AUTH$_UK1" UNIQUE
(
REALM_ID#
, GRANTEE_UID#
, AUTH_OPTIONS
, SCOPE
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."CODE_T$"
ADD CONSTRAINT "CODE_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.COMMAND_RULE$_FK_IDX        ON DVSYS.COMMAND_RULE$       (RULE_SET_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.COMMAND_RULE$_FK1_IDX       ON DVSYS.COMMAND_RULE$       (CODE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.FACTOR$_FK_IDX              ON DVSYS.FACTOR$             (FACTOR_TYPE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.FACTOR$_FK1_IDX             ON DVSYS.FACTOR$             (ASSIGN_RULE_SET_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.FACTOR_LINK$_FK_IDX         ON DVSYS.FACTOR_LINK$        (PARENT_FACTOR_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.FACTOR_LINK$_FK1_IDX        ON DVSYS. FACTOR_LINK$       (CHILD_FACTOR_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY$_FK_IDX            ON DVSYS.IDENTITY$           (FACTOR_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY_LABEL$_FK_IDX      ON DVSYS.POLICY_LABEL$       (IDENTITY_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY_MAP$_FK_IDX        ON DVSYS.IDENTITY_MAP$       (IDENTITY_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY_MAP$_FK1_IDX       ON DVSYS.IDENTITY_MAP$       (FACTOR_LINK_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY_MAP$_FK2_IDX       ON DVSYS.IDENTITY_MAP$       (OPERATION_CODE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.IDENTITY_MAP$_UK_IDX ON DVSYS.IDENTITY_MAP$(IDENTITY_ID#, FACTOR_LINK_ID#, OPERATION_CODE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.MAC_POLICY$_FK_IDX          ON DVSYS.MAC_POLICY$         (ALGORITHM_CODE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.MAC_POLICY_FACTOR$_FK_IDX   ON DVSYS.MAC_POLICY_FACTOR$  (FACTOR_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.MAC_POLICY_FACTOR$_FK1_IDX  ON DVSYS.MAC_POLICY_FACTOR$  (MAC_POLICY_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.REALM_AUTH$_FK_IDX          ON DVSYS.REALM_AUTH$         (REALM_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.REALM_AUTH$_FK1_IDX         ON DVSYS.REALM_AUTH$         (AUTH_RULE_SET_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.REALM_OBJECT$_FK_IDX        ON DVSYS.REALM_OBJECT$       (REALM_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.ROLE$_FK_IDX                ON DVSYS.ROLE$               (RULE_SET_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.RULE_SET_RULE$_FK_IDX       ON DVSYS.RULE_SET_RULE$      (RULE_SET_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE INDEX DVSYS.RULE_SET_RULE$_FK1_IDX      ON DVSYS.RULE_SET_RULE$      (RULE_ID#)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates sequences for the DVSYS schema.
Rem
Rem
Rem
Rem
Rem

BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."AUDIT_TRAIL$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."FACTOR_LINK$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."COMMAND_RULE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."CODE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."MAC_POLICY_FACTOR$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."REALM_OBJECT$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."RULE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."MAC_POLICY$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."POLICY_LABEL$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."ROLE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."FACTOR$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."IDENTITY$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."RULE_SET$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."RULE_SET_RULE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."IDENTITY_MAP$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."FACTOR_TYPE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."REALM_AUTH$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."REALM$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC Supporting Objects
Rem
Rem
Rem
Rem
Rem

--- Create the libraries for trusted implementations
CREATE OR REPLACE CONTEXT mac$factor USING DVSYS.dbms_macsec;
-- CREATE OR REPLACE CONTEXT mac$realm USING DVSYS.dbms_macsec;

CREATE OR REPLACE LIBRARY DVSYS.KZV$UTL_LIBT TRUSTED IS STATIC
/
CREATE OR REPLACE LIBRARY DVSYS.KZV$FAC_LIBT TRUSTED IS STATIC
/
CREATE OR REPLACE LIBRARY DVSYS.KZV$RUL_LIBT TRUSTED AS STATIC
/
CREATE OR REPLACE LIBRARY DVSYS.KZV$ADM_LIBT TRUSTED AS STATIC
/
CREATE OR REPLACE LIBRARY DVSYS.KZV$RSRC_LIBT TRUSTED AS STATIC
/

/**
 * Create the one and only evaluation context based on this metadata.
 * The name of this evaluation context will be used by all rule classes
 * created for the Datavault application
 */

DECLARE
  rmdvt sys.re$variable_type_list;
BEGIN
  rmdvt := sys.re$variable_type_list(
            sys.re$variable_type('dv$dummy','number',null,null));
  dbms_rule_adm.create_evaluation_context('DV$RULE_EVALCTX', null, rmdvt);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -24145) THEN NULL; --evaluation context already created
     ELSE RAISE;
     END IF;
END;
/

commit;
Rem
Rem
Rem
Rem    Create a function which will return the correct language that should 
Rem    be used by all the language dependent DV views created below
Rem
Rem
CREATE OR REPLACE FUNCTION dvsys.dvlang(lid IN NUMBER, langtab_no IN NUMBER)
RETURN VARCHAR2
AS
  l_lcnt NUMBER default 0;
  l_lang VARCHAR2(3);
  l_tab  VARCHAR2(128);
  l_stmt VARCHAR2(256);
  l_cursor    int;
  l_status    int;
BEGIN
  l_lang := LOWER(SYS_CONTEXT('USERENV','LANG'));
  l_tab :=
    CASE langtab_no
      WHEN 1 THEN 'CODE_T$'
      WHEN 2 THEN 'FACTOR_T$'
      WHEN 3 THEN 'FACTOR_TYPE_T$'
      WHEN 4 THEN 'RULE_T$'
      WHEN 5 THEN 'RULE_SET_T$'
      WHEN 6 THEN 'REALM_T$'
      WHEN 7 THEN 'POLICY_T$'
    END;

  l_stmt := 'SELECT COUNT(*) FROM ' || l_tab || ' WHERE id# = :id AND language = :lang';
  l_cursor := sys.dbms_sql.open_cursor;
  sys.dbms_sql.parse( l_cursor, l_stmt, sys.dbms_sql.native );
  sys.dbms_sql.bind_variable( l_cursor, ':id', lid );
  sys.dbms_sql.bind_variable( l_cursor, ':lang', l_lang );
  sys.dbms_sql.define_column( l_cursor, 1, l_lcnt );
  l_status := sys.dbms_sql.execute( l_cursor );
  if ( sys.dbms_sql.fetch_rows(l_cursor) > 0 )
    then
        sys.dbms_sql.column_value( l_cursor, 1, l_lcnt );
  end if;
  sys.dbms_sql.close_cursor(l_cursor);

  if (l_lcnt = 0) then
    return 'us';
  else
    return l_lang;
  end if;
END;
/
show errors;

Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table CODE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$code
(
      ID#
    , CODE_GROUP
    , CODE
    , VALUE
    , LANGUAGE
    , DESCRIPTION
    , VERSION
    , CREATED_BY
    , CREATE_DATE
    , UPDATED_BY
    , UPDATE_DATE
)
AS SELECT
      m.ID#
    , m.CODE_GROUP
    , m.CODE
    , d.VALUE
    , d.LANGUAGE
    , d.DESCRIPTION
    , m.VERSION
    , m.CREATED_BY
    , m.CREATE_DATE
    , m.UPDATED_BY
    , m.UPDATE_DATE
FROM dvsys.code$ m, dvsys.code_t$ d
WHERE m.id# = d.id#
      AND d.language = DVSYS.dvlang(d.id#, 1)
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table FACTOR_TYPE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$factor_type
(
      ID#
    , NAME
    , DESCRIPTION
    , VERSION
    , CREATED_BY
    , CREATE_DATE
    , UPDATED_BY
    , UPDATE_DATE
)
AS SELECT
      m.ID#
    , d.NAME
    , d.DESCRIPTION
    , m.VERSION
    , m.CREATED_BY
    , m.CREATE_DATE
    , m.UPDATED_BY
    , m.UPDATE_DATE
FROM dvsys.factor_type$ m, dvsys.factor_type_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 3) 
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table RULE_SET$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$rule_set
(
      id#
    , name
    , description
    , enabled
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
    , fail_message
    , fail_code
    , handler_options
    , handler
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
    , is_static
    , common
    , inherited
)
AS SELECT
      m.id#
    , d.name
    , d.description
    , m.enabled
    , m.eval_options - DECODE(bitand(m.eval_options, 128) , 128, 128, 0)
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
    , d.fail_message
    , m.fail_code
    , m.handler_options
    , m.handler
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
    , DECODE(bitand(m.eval_options, 128) , 128, 'TRUE', 'FALSE')
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 5)
    AND deval.code = TO_CHAR(m.eval_options -
                             DECODE(bitand(m.eval_options,128) , 128, 128, 0))
    AND deval.code_group = 'RULESET_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = 'RULESET_FAIL'
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$rule
(
      id#
    , name
    , rule_expr
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
    , common
    , inherited
)
AS SELECT
      m.id#
    , d.name
    , m.rule_expr
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 4) 
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table RULE_SET_RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$rule_set_rule
(
      id#
    , rule_set_id#
    , rule_set_name
    , rule_id#
    , rule_name
    , rule_expr
    , enabled
    , rule_order
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
    , common
    , inherited
)
AS SELECT
      m.id#
    , m.rule_set_id#
    , d1.name
    , m.rule_id#
    , d2.name
    , d2.rule_expr
    , m.enabled
    , m.rule_order
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
    , d1.common
    , d1.inherited
FROM dvsys.rule_set_rule$ m
     ,dvsys.dv$rule_set d1
     ,dvsys.dv$rule d2
WHERE
    d1.id# = m.rule_set_id#
    and d2.id# = m.rule_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table COMMAND_RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$command_rule
(
      id#
    , code_id#
    , command
    , clause_id#
    , clause_name
    , parameter_name
    , event_name
    , component_name
    , action_name
    , rule_set_id#
    , rule_set_name
    , object_owner
    , object_name
    , enabled
    , privilege_scope
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
    , common
    , inherited
)
AS
SELECT
      s.id#
    , s.code_id#
    , s.code
    , s.clause_id#
    , NVL(c.clause_name, '%')
    , s.parameter_name
    , s.event_name
    , s.component_name
    , s.action_name
    , s.rule_set_id#
    , s.rule_set_name
    , s.object_owner
    , s.object_name
    , s.enabled
    , s.privilege_scope
    , s.version
    , s.created_by
    , s.create_date
    , s.updated_by
    , s.update_date
    , s.common
    , s.inherited
FROM
    (SELECT
           m.id#
         , m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , m.rule_set_id#
         , d1.name as rule_set_name
         , u.name as object_owner
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , m.version
         , m.created_by
         , m.create_date
         , m.updated_by
         , m.update_date
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
         ,sys."_BASE_USER" u
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = u.user#
     UNION
     SELECT
           m.id#
         , m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , m.rule_set_id#
         , d1.name
         , '%'
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , m.version
         , m.created_by
         , m.create_date
         , m.updated_by
         , m.update_date
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = &all_schema ) s
LEFT JOIN (select distinct code_id#, clause_id#, clause_name from sys.v_$code_clause ) c
    ON s.code_id# = c.code_id#
       AND s.clause_id# = c.clause_id#
/



Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table FACTOR$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$factor
(
      id#
    , name
    , description
    , factor_type_id#
    , factor_type_name
    , assign_rule_set_id#
    , assign_rule_set_name
    , get_expr
    , validate_expr
    , identified_by
    , identified_by_meaning
    , namespace
    , namespace_attribute
    , labeled_by
    , labeled_by_meaning
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.name
    , d.description
    , m.factor_type_id#
    , dft.name
    , m.assign_rule_set_id#
    , drs.name
    , m.get_expr
    , m.validate_expr
    , m.identified_by
    , did.value
    , m.namespace
    , m.namespace_attribute
    , m.labeled_by
    , dlabel.value
    , m.eval_options
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.factor$ m
    , dvsys.factor_t$ d
    , dvsys.dv$factor_type dft
    , dvsys.dv$rule_set drs
    , dvsys.dv$code did
    , dvsys.dv$code dlabel
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 2)
    AND dft.id# = m.factor_type_id#
    AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = 'FACTOR_IDENTIFY'
    AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = 'FACTOR_LABEL'
    AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = 'FACTOR_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = 'FACTOR_FAIL'
    AND drs.id#  (+)= m.assign_rule_set_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table FACTOR_LINK$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$factor_link
(
      id#
    , parent_factor_id#
    , parent_factor_name
    , child_factor_id#
    , child_factor_name
    , label_ind
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.parent_factor_id#
    , d1.name
    , m.child_factor_id#
    , d2.name
    , m.label_ind
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.factor_link$ m
    , dvsys.dv$factor d1
    , dvsys.dv$factor d2
WHERE
     d1.id# = m.parent_factor_id#
    AND d2.id# = m.child_factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table IDENTITY$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$identity
(
      id#
    , factor_id#
    , factor_name
    , value
    , trust_level
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.factor_id#
    , d1.name
    , m.value
    , m.trust_level
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.identity$ m,
   dvsys.dv$factor d1
WHERE
    d1.id# = m.factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table IDENTITY_MAP$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$identity_map
(
      id#
    , identity_id#
    , identity_value
    , factor_id#
    , factor_name
    , factor_link_id#
    , operation_code_id#
    , operation_code
    , operation_value
    , operand1
    , operand2
    , parent_factor_name
    , child_factor_name
    , label_ind
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.identity_id#
    , d1.value
    , d6.id#
    , d6.name
    , m.factor_link_id#
    , m.operation_code_id#
    , d2.code
    , d2.value
    , m.operand1
    , m.operand2
    , d4.name
    , d5.name
    , d3.label_ind
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.identity_map$ m
    , dvsys.identity$ d1
    , dvsys.dv$code d2
    , dvsys.factor_link$ d3
    , dvsys.dv$factor d4
    , dvsys.dv$factor d5
    , dvsys.dv$factor d6
WHERE
    d1.id# = m.identity_id#
    AND d2.id# = m.operation_code_id#
    AND d3.id# (+)= m.factor_link_id#
    AND d4.id# (+)= d3.parent_factor_id#
    AND d5.id# (+)= d3.child_factor_id#
    AND d6.id# = d1.factor_id#

/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table MAC_POLICY$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$mac_policy
(
      id#
    , policy_id#
    , policy_name
    , algorithm_code_id#
    , algorithm_code
    , algorithm_meaning
    , error_label
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.policy_id#
    , d1.pol_name
    , m.algorithm_code_id#
    , d2.code
    , d2.value
    , m.error_label
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.mac_policy$ m
    , lbacsys.ols$pol d1
    , dvsys.dv$code d2
WHERE
        d1.pol# = m.policy_id#
    AND d2.id# = m.algorithm_code_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table MAC_POLICY_FACTOR$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$mac_policy_factor
(
      id#
    , factor_id#
    , factor_name
    , mac_policy_id#
    , policy_id#
    , mac_policy_name
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.factor_id#
    , d1.name
    , d3.id#
    , d3.policy_id#
    , d2.pol_name
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.mac_policy_factor$ m
    , dvsys.dv$factor d1
    , lbacsys.ols$pol d2
    , dvsys.mac_policy$ d3
WHERE
    d1.id# = m.factor_id#
    AND d3.id# = m.mac_policy_id#
    AND d2.pol# = policy_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the view lbacsys.ols$pol.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$ols_policy
(
     policy_id
    , policy_name
)
AS SELECT
     d1.pol#
    , d1.pol_name
FROM
    lbacsys.ols$pol d1
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the view lbacsys.lbac$lab$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$ols_policy_label
(
      policy_id
    , policy_name
    , label_id
    , label
)
AS SELECT
      d2.pol#
    , d2.pol_name
    , d3.tag#
    , d3.slabel -- or labeltochar(d3.lab#)
FROM
     lbacsys.ols$pol d2
    , lbacsys.ols$lab d3
WHERE
    d2.pol# = d3.pol#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table POLICY_LABEL$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$policy_label
(
      id#
    , identity_id#
    , identity_value
    , factor_id#
    , factor_name
    , policy_id#
    , policy_name
    , label_id#
    , label
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.identity_id#
    , d1.value
    , d4.id#
    , d4.name
    , m.policy_id#
    , d2.pol_name
    , m.label_id#
    , d3.slabel -- or labeltochar(d3.lab#)
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM
    policy_label$ m
    , identity$ d1
    , lbacsys.ols$pol d2
    , lbacsys.ols$lab d3
    , factor$ d4
WHERE
    d1.id# = m.identity_id#
    AND d2.pol# = m.policy_id#
    AND d3.tag# = m.label_id#
    AND d4.id# = d1.factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table REALM$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$realm
(
      id#
    , name
    , description
    , audit_options
    , realm_type
    , common
    , inherited 
    , enabled
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , d.name
    , d.description
    , m.audit_options
    , m.realm_type
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
    , m.enabled
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 6) 
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table REALM_AUTH$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$realm_auth
(
      id#
    , realm_id#
    , realm_name
    , common_realm
    , inherited_realm
    , grantee
    , auth_rule_set_id#
    , auth_rule_set_name
    , auth_options
    , auth_options_meaning
    , common_auth
    , inherited_auth
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.realm_id#
    , d1.name
    , d1.common
    , d1.inherited
    , u.name
    , m.auth_rule_set_id#
    , d2.name
    , m.auth_options
    , c.value
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common_auth
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited_auth
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
    , (select user#, name from sys."_BASE_USER"
       union     
       select id as user#, name from sys.xs$obj where type = 1) u
WHERE
    d1.id# (+)= m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
    AND m.grantee_uid# = u.user#
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table REALM_OBJECT$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$realm_object
(
      id#
    , realm_id#
    , realm_name
    , common_realm
    , inherited_realm
    , owner
    , object_name
    , object_type
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS 
SELECT
      m.id#
    , m.realm_id#
    , d.name
    , d.common
    , d.inherited
    , u.name
    , m.object_name
    , m.object_type
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_object$ m, dvsys.dv$realm d, sys."_BASE_USER" u
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = u.user#
UNION
SELECT
      m.id#
    , m.realm_id#
    , d.name
    , d.common
    , d.inherited
    , '%'
    , m.object_name
    , m.object_type
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = &all_schema
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table ROLE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$role
(
      id#
    , role
    , rule_set_id#
    , rule_name
    , enabled
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.role
    , m.rule_set_id#
    , d.name
    , m.enabled
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.role$ m, dvsys.dv$rule_set d
WHERE m.rule_set_id# = d.id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a meaning-based view with primary and foreign keys for the table ROLE$.
Rem
Rem

Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$sys_grantee
(
      grantee_name
    , grantee_type
)
AS
SELECT
      u.username
    , 'USER'
FROM sys.dba_users u
UNION
SELECT
      r.role
    , 'ROLE'
FROM
    sys.dba_roles r
/

create or replace view DVSYS.DV_OWNER_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_OWNER'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys."_BASE_USER" where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_OWNER'))
/

create or replace view DVSYS.DV_ADMIN_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_ADMIN'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys."_BASE_USER" where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_ADMIN'))
/

create or replace view DVSYS.DV_SECANALYST_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_SECANALYST'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys."_BASE_USER" where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_SECANALYST'))
/

create or replace view DVSYS.DV_MONITOR_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_MONITOR'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys."_BASE_USER" where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_MONITOR'))
/

create or replace view DVSYS.DV_AUDIT_CLEANUP_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_AUDIT_CLEANUP'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys."_BASE_USER" where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_AUDIT_CLEANUP'))
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a view for object .
Rem
Rem

Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$sys_object
(
OBJECT_ID
,OWNER
,OBJECT_NAME
,SUBOBJECT_NAME
,DATA_OBJECT_ID
,OBJECT_TYPE
,CREATED
,LAST_DDL_TIME
,TIMESTAMP
,STATUS
,TEMPORARY
,GENERATED
,SECONDARY
)
AS SELECT
OBJECT_ID
,OWNER
,OBJECT_NAME
,SUBOBJECT_NAME
,DATA_OBJECT_ID
,OBJECT_TYPE
,CREATED
,LAST_DDL_TIME
,TIMESTAMP
,STATUS
,TEMPORARY
,GENERATED
,SECONDARY
FROM sys.dba_objects
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a view for object owners.
Rem
Rem

Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dv$sys_object_owner
(
      username
)
AS
SELECT
      u.username
FROM sys.dba_users u
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table CODE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_code
(
     CODE_GROUP
    , CODE
    , VALUE
    , LANGUAGE
    , DESCRIPTION
)
AS SELECT
      m.CODE_GROUP
    , m.CODE
    , d.VALUE
    , d.LANGUAGE
    , d.DESCRIPTION
FROM dvsys.code$ m, dvsys.code_t$ d
WHERE m.id# = d.id#
      AND d.language = DVSYS.dvlang(d.id#, 1) 
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table COMMAND_RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_command_rule
(
      command
    , clause_name
    , parameter_name
    , event_name
    , component_name
    , action_name
    , rule_set_name
    , object_owner
    , object_name
    , enabled
    , privilege_scope
    , common
    , inherited
    , id#
    , oracle_supplied
    , pl_sql_stack
)
AS
SELECT
      s.code
    , NVL(c.clause_name, '%')
    , s.parameter_name
    , s.event_name
    , s.component_name
    , s.action_name
    , s.rule_set_name
    , s.object_owner
    , s.object_name
    , s.enabled
    , s.privilege_scope
    , s.common
    , s.inherited
    , s.id#
    , CASE WHEN (s.id# < 5000) 
           THEN 'YES'
           ELSE 'NO'
      END
    , s.pl_sql_stack
FROM
    (SELECT
           m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , d1.name as rule_set_name
         , u.name as object_owner
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
         , m.id#
         , decode(m.pl_sql_stack, 0, 'NO',
                                  1, 'YES') pl_sql_stack
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
         ,sys."_BASE_USER" u
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = u.user#
     UNION
     SELECT
           m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , d1.name
         , '%'
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
         , m.id#
         , decode(m.pl_sql_stack, 0, 'NO',
                                  1, 'YES') pl_sql_stack
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = &all_schema) s
LEFT JOIN (select distinct code_id#, clause_id#, clause_name from sys.v_$code_clause ) c
    ON s.code_id# = c.code_id#
       AND s.clause_id# = c.clause_id#
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table FACTOR$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_factor
(
      name
    , description
    , factor_type_name
    , assign_rule_set_name
    , get_expr
    , validate_expr
    , identified_by
    , identified_by_meaning
    , namespace
    , namespace_attribute
    , labeled_by
    , labeled_by_meaning
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
    , id#
    , oracle_supplied
)
AS SELECT
      m.name
    , d.description
    , dft.name
    , drs.name
    , m.get_expr
    , m.validate_expr
    , m.identified_by
    , did.value
    , m.namespace
    , m.namespace_attribute
    , m.labeled_by
    , dlabel.value
    , m.eval_options
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
    , m.id#
    , CASE WHEN m.id# < 5000 THEN 'YES' ELSE 'NO' END
FROM dvsys.factor$ m
    , dvsys.factor_t$ d
    , dvsys.dv$factor_type dft
    , dvsys.dv$rule_set drs
    , dvsys.dv$code did
    , dvsys.dv$code dlabel
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 2) 
    AND dft.id# = m.factor_type_id#
    AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = 'FACTOR_IDENTIFY'
    AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = 'FACTOR_LABEL'
    AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = 'FACTOR_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = 'FACTOR_FAIL'
    AND drs.id#  (+)= m.assign_rule_set_id#
/


Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table FACTOR_LINK$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_factor_link
(
      parent_factor_name
    , child_factor_name
    , label_ind
)
AS SELECT
      d1.name
    , d2.name
    , m.label_ind
FROM dvsys.factor_link$ m
    , dvsys.dv$factor d1
    , dvsys.dv$factor d2
WHERE
     d1.id# = m.parent_factor_id#
    AND d2.id# = m.child_factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table FACTOR_TYPE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_factor_type
(
      NAME
    , DESCRIPTION
)
AS SELECT
      d.NAME
    , d.DESCRIPTION
FROM dvsys.factor_type$ m, dvsys.factor_type_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 3)
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table IDENTITY$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_identity
(
      factor_name
    , value
    , trust_level
)
AS SELECT
      d1.name
    , m.value
    , m.trust_level
FROM dvsys.identity$ m, dvsys.dv$factor d1
WHERE
    d1.id# = m.factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table IDENTITY_MAP$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_identity_map
(
      factor_name
    , identity_value
    , operation_code
    , operation_value
    , operand1
    , operand2
    , parent_factor_name
    , child_factor_name
    , label_ind
)
AS SELECT
      d6.name
    , d1.value
    , d2.code
    , d2.value
    , m.operand1
    , m.operand2
    , d4.name
    , d5.name
    , d3.label_ind
FROM dvsys.identity_map$ m
    , dvsys.identity$ d1
    , dvsys.dv$code d2
    , dvsys.factor_link$ d3
    , dvsys.dv$factor d4
    , dvsys.dv$factor d5
    , dvsys.dv$factor d6
WHERE
    d1.id# = m.identity_id#
    AND d2.id# = m.operation_code_id#
    AND d3.id# (+)= m.factor_link_id#
    AND d4.id# (+)= d3.parent_factor_id#
    AND d5.id# (+)= d3.child_factor_id#
    AND d6.id# = d1.factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table MAC_POLICY$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_mac_policy
(
      policy_name
    , algorithm_code
    , algorithm_meaning
    , error_label
)
AS SELECT
      d1.pol_name
    , d2.code
    , d2.value
    , m.error_label
FROM dvsys.mac_policy$ m
    , lbacsys.ols$pol d1
    , dvsys.dv$code d2
WHERE
        d1.pol# = m.policy_id#
    AND d2.id# = m.algorithm_code_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table MAC_POLICY_FACTOR$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_mac_policy_factor
(
      factor_name
    , mac_policy_name
)
AS SELECT
      d1.name
    , d2.pol_name
FROM dvsys.mac_policy_factor$ m
    , dvsys.dv$factor d1
    , lbacsys.ols$pol d2
    , dvsys.mac_policy$ d3
WHERE
    d1.id# = m.factor_id#
    AND d3.id# = m.mac_policy_id#
    AND d2.pol# = policy_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table POLICY_LABEL$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_policy_label
(
     identity_value
    , factor_name
    , policy_name
    , label
)
AS SELECT
      d1.value
    , d4.name
    , d2.pol_name
    , d3.slabel -- or labeltochar(d3.lab#)
FROM
    policy_label$ m
    , identity$ d1
    , lbacsys.ols$pol d2
    , lbacsys.ols$lab d3
    , factor$ d4
WHERE
    d1.id# = m.identity_id#
    AND d2.pol# = m.policy_id#
    AND d3.tag# = m.label_id#
    AND d4.id# = d1.factor_id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table REALM$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm
(
      name
    , description
    , audit_options
    , realm_type
    , common
    , inherited 
    , enabled
    , id#
    , oracle_supplied
    , pl_sql_stack
)
AS SELECT
      d.name
    , d.description
    , m.audit_options
    , decode(m.realm_type, 0, 'REGULAR',
                           1, 'MANDATORY')
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
    , m.enabled
    , m.id#
    , CASE WHEN (m.id# < 5000) OR
                (1000000000 <= m.id# AND m.id# < 1000005000)
           THEN 'YES'
           ELSE 'NO'
      END
    , decode(m.pl_sql_stack, 0, 'NO',
                             1, 'YES')
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 6)
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table REALM_AUTH$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm_auth
(
      realm_name
    , common_realm
    , inherited_realm
    , grantee
    , auth_rule_set_name
    , auth_options
    , common_auth
    , inherited_auth
)
AS SELECT
      d1.name
    , d1.common
    , d1.inherited
    , u.name
    , d2.name
    , c.value
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common_auth
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited_auth
FROM dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
    , (select user#, name from sys."_BASE_USER"
       union
       select id as user#, name from sys.xs$obj where type = 1) u
WHERE
    d1.id# (+)= m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
    AND m.grantee_uid# = u.user#
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table REALM_OBJECT$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm_object
(
      realm_name
    , common_realm
    , inherited_realm
    , owner
    , object_name
    , object_type
)
AS SELECT
     d.name
    , d.common
    , d.inherited
    , u.name
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d, sys."_BASE_USER" u
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = u.user#
UNION
SELECT
     d.name
    , d.common
    , d.inherited
    , '%'
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = &all_schema
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table ROLE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_role
(
      role
    , rule_name
    , enabled
    , id#
    , oracle_supplied
)
AS SELECT
      m.role
    , d.name
    , m.enabled
    , m.id#
    , CASE WHEN m.id# < 5000 THEN 'YES' ELSE 'NO' END
FROM dvsys.role$ m, dvsys.dv$rule_set d
WHERE m.rule_set_id# = d.id#
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule
(
      name
    , rule_expr
    , common
    , inherited
    , id#
    , oracle_supplied
)
AS SELECT
      d.name
    , m.rule_expr
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
    , m.id#
    , CASE WHEN (m.id# < 5000)
           THEN 'YES'
           ELSE 'NO'
      END
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 4)
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table RULE_SET_RULE$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set_rule
(
      rule_set_name
    , rule_name
    , rule_expr
    , enabled
    , rule_order
    , common
    , inherited
)
AS SELECT
      d1.name
    , d2.name
    , d2.rule_expr
    , m.enabled
    , m.rule_order
    , d1.common
    , d1.inherited
FROM dvsys.rule_set_rule$ m
     ,dvsys.dv$rule_set d1
     ,dvsys.dv$rule d2
WHERE
    d1.id# = m.rule_set_id#
    and d2.id# = m.rule_id#
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the table RULE_SET$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set
(
      rule_set_name
    , description
    , enabled
    , eval_options_meaning
    , audit_options
    , fail_options_meaning
    , fail_message
    , fail_code
    , handler_options
    , handler
    , is_static
    , common
    , inherited
    , id#
    , oracle_supplied
)
AS SELECT
      d.name
    , d.description
    , m.enabled
    , deval.value
    , m.audit_options
    , dfail.value
    , d.fail_message
    , m.fail_code
    , m.handler_options
    , m.handler
    , DECODE(bitand(m.eval_options, 128) , 128, 'TRUE', 'FALSE')
    , decode(m.scope, 1, 'NO',
                      2, 'YES',
                      3, 'YES') common
    , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
           THEN 'YES'
           ELSE 'NO'
      END inherited
    , m.id#
    , CASE WHEN (m.id# < 5000)
           THEN 'YES'
           ELSE 'NO'
      END
FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 5)
    AND deval.code  = TO_CHAR(m.eval_options -
                             DECODE(bitand(m.eval_options,128) , 128, 128, 0))
    AND deval.code_group = 'RULESET_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = 'RULESET_FAIL'
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates DBA views for the DV privilege management reports.
Rem
Rem
Rem
Rem
Rem
-- Bug 9671705 change definition of dba_dv_user_privs and dba_dv_user_privs_all
CREATE OR REPLACE VIEW DVSYS.dba_dv_user_privs
(
      USERNAME
    , ACCESS_TYPE
    , PRIVILEGE
    , OWNER
    , OBJECT_NAME
)
AS SELECT
      dbu.name
    , decode(ue.name,dbu.name,'DIRECT',ue.name)
    , tpm.name
    , u.name
    , o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys."_BASE_USER" u,
    sys."_BASE_USER" ue,
    sys."_BASE_USER" dbu,
    sys.table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee# in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_user_privs_all
(
      USERNAME
    , ACCESS_TYPE
    , PRIVILEGE
    , OWNER
    , OBJECT_NAME
)
AS SELECT
      dbu.name
    , decode(ue.name,dbu.name,'DIRECT',ue.name)
    , tpm.name
    , u.name
    , o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys."_BASE_USER" u,
    sys."_BASE_USER" ue,
    sys."_BASE_USER" dbu,
    sys.table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee#  in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
UNION ALL
SELECT dbu.name
       ,DECODE(ue.name,dbu.name,'DIRECT',ue.name)
       ,spm.name
       ,DECODE (INSTR(spm.name,' ANY '),0, NULL, '%')
       ,DECODE (INSTR(spm.name,' ANY '),0, NULL, '%')
FROM sys.sysauth$ oa,
     sys."_BASE_USER" ue,
     sys."_BASE_USER" dbu,
     sys.system_privilege_map spm
WHERE
      oa.privilege# = spm.privilege
  AND oa.grantee# = ue.user#
  AND oa.privilege# < 0
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee#  in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_pub_privs
(
      USERNAME
    , ACCESS_TYPE
    , PRIVILEGE
    , OWNER
    , OBJECT_NAME
)
AS SELECT
      'PUBLIC'
    , decode(oa.grantee#,1,'DIRECT',ue.name)
    , tpm.name
    , u.name
    , o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys."_BASE_USER" u,
    sys."_BASE_USER" ue,
    sys.table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND (oa.grantee# = 1
        or
       oa.grantee# in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=1))
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates a DBA views for job auth and datapump auth from DV_AUTH$.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE VIEW DVSYS.dba_dv_job_auth
(
      grantee
    , schema
)
AS SELECT
    u1.name
  , u2.name
FROM dvsys.dv_auth$ da, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1, 
     sys."_BASE_USER" u2
WHERE grant_type = 'JOB' and da.grantee_id = u1.user# and 
      da.object_owner_id = u2.user#
UNION
SELECT 
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE grant_type = 'JOB' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_datapump_auth
(
      grantee
    , schema
    , object
    , action
)
AS SELECT
    u1.name
  , u2.name
  , da.object_name
  , da.action
FROM dvsys.dv_auth$ da, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1,
     sys."_BASE_USER" u2
WHERE da.grant_type = 'DATAPUMP' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
  , da.object_name
  , da.action
FROM dvsys.dv_auth$ da, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'DATAPUMP' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_tts_auth
(
      grantee
    , tsname
)
AS SELECT
    u1.name
  , da.object_name 
FROM dvsys.dv_auth$ da, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'TTS' and da.grantee_id = u1.user#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_proxy_auth
(
      grantee
    , schema
)
AS SELECT
    u1.name
  , u2.name
FROM dvsys.dv_auth$ da, 
(select user#, name from sys."_BASE_USER" 
 union 
 select id as user#, name from sys.xs$obj where type = 1) u1, 
(select user#, name from sys."_BASE_USER" 
 union 
 select id as user#, name from sys.xs$obj where type = 1) u2
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, 
(select user#, name from sys."_BASE_USER" 
 union 
 select id as user#, name from sys.xs$obj where type = 1) u1
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da,
(select user#, name from sys."_BASE_USER" 
 union 
 select id as user#, name from sys.xs$obj where type = 1) u2
WHERE grant_type = 'PROXY' and da.grantee_id = &all_schema and
      da.object_owner_id = u2.user#
UNION
SELECT
    '%'
  , '%'
FROM dvsys.dv_auth$ da
WHERE grant_type = 'PROXY' and da.grantee_id = &all_schema and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_ddl_auth
(
      grantee
    , schema
)
AS SELECT
    u1.name
  , u2.name
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1, 
     sys."_BASE_USER" u2
WHERE grant_type = 'DDL' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE grant_type = 'DDL' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u2
WHERE grant_type = 'DDL' and da.grantee_id = &all_schema and
      da.object_owner_id = u2.user#
UNION
SELECT
    '%'
  , '%'
FROM dvsys.dv_auth$ da
WHERE grant_type = 'DDL' and da.grantee_id = &all_schema and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_maintenance_auth
(
      grantee
    , schema
    , object
    , object_type
    , action
)
AS SELECT
    u1.name
  , u2.name
  , da.object_name
  , da.object_type
  , da.action
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1, 
     sys."_BASE_USER" u2
WHERE da.grant_type = 'MAINTENANCE' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
  , da.object_name
  , da.object_type
  , da.action
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'MAINTENANCE' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
  , da.object_name
  , da.object_type
  , da.action
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u2
WHERE da.grant_type = 'MAINTENANCE' and da.grantee_id = &all_schema and
      da.object_owner_id = u2.user#
UNION
SELECT
    '%'
  , '%'
  , da.object_name
  , da.object_type
  , da.action
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u1
WHERE da.grant_type = 'MAINTENANCE' and da.grantee_id = &all_schema and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_auth
(
      grant_type
    , grantee
    , schema
    , object_name
    , object_type
)
AS SELECT
    grant_type
  , u1.name
  , u2.name
  , da.object_name
  , da.object_type
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1, 
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u2
WHERE da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    grant_type
  , u1.name
  , '%'
  , object_name
  , object_type
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    grant_type
  , '%'
  , u2.name
  , object_name
  , object_type
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u2
WHERE da.grantee_id = &all_schema and
      da.object_owner_id = u2.user#
UNION
SELECT
    grant_type
  , '%'
  , '%'
  , object_name
  , object_type
FROM dvsys.dv_auth$ da
WHERE da.grantee_id = &all_schema and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_preprocessor_auth
(
      grantee
)
AS SELECT
    u1.name
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'PREPROCESSOR' and da.grantee_id = u1.user#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_diagnostic_auth
(
      grantee
)
AS SELECT
    u1.name
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'DIAGNOSTIC' and da.grantee_id = u1.user#
UNION
SELECT
    '%'
FROM dvsys.dv_auth$ da
WHERE grant_type = 'DIAGNOSTIC' and da.grantee_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_index_function
(
      object_name
)
AS SELECT
    object_name
FROM dvsys.dv_auth$ da
WHERE da.grant_type = 'INDEX_FUNCTION'
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_dbcapture_auth
(
      grantee
)
AS SELECT
    u1.name
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'DBCAPTURE' and da.grantee_id = u1.user#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_dbreplay_auth
(
      grantee
)
AS SELECT
    u1.name
FROM dvsys.dv_auth$ da,
     (select user#, name from sys."_BASE_USER"
      union
      select id as user#, name from sys.xs$obj where type = 1) u1
WHERE da.grant_type = 'DBREPLAY' and da.grantee_id = u1.user#
/

Rem    DESCRIPTION
Rem      Creates a DBA view for the state (enabled or disabled) of 
Rem      DV_PATCH_ADMIN audit from DV_AUTH$.
Rem
CREATE OR REPLACE VIEW DVSYS.dba_dv_patch_admin_audit
(
    state
)
AS 
SELECT DECODE(cnt, 0, 'DISABLED', 'ENABLED') 
FROM (SELECT COUNT(*) cnt FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'DVPATCHAUDIT')
/

Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the state (enabled or disabled) of 
Rem      ORADEBUG from DV_AUTH$.
Rem
CREATE OR REPLACE VIEW DVSYS.dba_dv_oradebug
(
    state
)
AS 
SELECT DECODE(cnt, 0, 'DISABLED', 'ENABLED') 
FROM (SELECT COUNT(*) cnt FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'ORADEBUG')
/

Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the state (enabled or disabled) of
Rem      Database Vault accouts (DVSYS and DVF) from DV_AUTH$.
Rem
CREATE OR REPLACE VIEW DVSYS.dba_dv_dictionary_accts
(
    state
)
AS
SELECT DECODE(cnt, 0, 'DISABLED', 'ENABLED')
FROM (SELECT COUNT(*) cnt FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'DV_ACCTS')
/

Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the DEBUG CONNECT authorization from DV_AUTH$.
Rem
CREATE OR REPLACE VIEW DVSYS.dba_dv_debug_connect_auth
(
      grantee
    , schema
)
AS SELECT
    u1.name
  , u2.name
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u1, sys."_BASE_USER" u2
WHERE grant_type = 'DEBUG_CONNECT' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u1
WHERE grant_type = 'DEBUG_CONNECT' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u2
WHERE grant_type = 'DEBUG_CONNECT' and da.grantee_id = &all_schema and
      da.object_owner_id = u2.user#
UNION
SELECT
    '%'
  , '%'
FROM dvsys.dv_auth$ da
WHERE grant_type = 'DEBUG_CONNECT' and da.grantee_id = &all_schema and
      da.object_owner_id = &all_schema
/

--------------------------------------------------------
--
--  Project 46812: Support for Database Vault Policy
--      ( Tables, constraints, views, and sequences )
--
--------------------------------------------------------

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."POLICY$"
(
"ID#" NUMBER NOT NULL,
"STATE" NUMBER NOT NULL,
"PL_SQL_STACK" NUMBER DEFAULT 0
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."POLICY_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (128) NOT NULL,
"DESCRIPTION" VARCHAR2 (1024),
"LANGUAGE" VARCHAR2(3) NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."POLICY_OBJECT$"
(
"ID#" NUMBER NOT NULL,
"POLICY_ID#" NUMBER NOT NULL,
"OBJECT_TYPE" NUMBER NOT NULL,
"OBJECT_ID#" NUMBER NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS."POLICY_OWNER$"
(
"ID#" NUMBER NOT NULL,
"POLICY_ID#" NUMBER NOT NULL,
"OWNER_ID#" NUMBER NOT NULL
)'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY$"
ADD CONSTRAINT "POLICY$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE'
;  
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_T$"
ADD CONSTRAINT "POLICY$_UK1" UNIQUE
(
  "ID#",
  "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_T$"
ADD CONSTRAINT "POLICY$_UK2" UNIQUE
(
  "NAME",
  "LANGUAGE"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OBJECT$"
ADD CONSTRAINT "POLICY_OBJECT$_PK1" PRIMARY KEY
(
  "ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OWNER$"
ADD CONSTRAINT "POLICY_OWNER$_PK1" PRIMARY KEY
(
  "ID#"
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OBJECT$"
ADD CONSTRAINT "POLICY_OBJECT$_FK" FOREIGN KEY
(
  "POLICY_ID#"
)
REFERENCES DVSYS."POLICY$"
(
  "ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OWNER$"
ADD CONSTRAINT "POLICY_OWNER$_FK" FOREIGN KEY
(
  "POLICY_ID#"
)
REFERENCES DVSYS."POLICY$"
(
  "ID#"
) ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OBJECT$"
ADD CONSTRAINT "POLICY_OBJECT$_UK1" UNIQUE
(
  POLICY_ID#
, OBJECT_TYPE
, OBJECT_ID#
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."POLICY_OWNER$"
ADD CONSTRAINT "POLICY_OWNER$_UK1" UNIQUE
(
  POLICY_ID#
, OWNER_ID#
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

CREATE OR REPLACE VIEW DVSYS.dv$policy
(
    id#
  , name
  , description
  , state
  , pl_sql_stack
)
AS SELECT
    p.id#
  , pt.name
  , pt.description
  , p.state
  , decode(p.pl_sql_stack, 0, 'NO',
                           1, 'YES')
FROM dvsys.policy$ p, dvsys.policy_t$ pt
WHERE p.id# = pt.id# AND
      pt.language = DVSYS.dvlang(pt.id#, 7);

CREATE OR REPLACE VIEW DVSYS.dba_dv_command_rule_id
(     id#
    , command
    , clause_name
    , parameter_name
    , event_name
    , component_name
    , action_name
    , rule_set_name
    , object_owner
    , object_name
    , enabled
    , privilege_scope
    , common
    , inherited
)
AS 
SELECT
      s.id#
    , s.code
    , NVL(c.clause_name, '%')
    , s.parameter_name
    , s.event_name
    , s.component_name
    , s.action_name
    , s.rule_set_name
    , s.object_owner
    , s.object_name
    , s.enabled
    , s.privilege_scope
    , s.common
    , s.inherited
FROM
    (SELECT
           m.id#
         , m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , d1.name as rule_set_name
         , u.name as object_owner
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
         ,sys."_BASE_USER" u
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = u.user#
     UNION
     SELECT
           m.id#
         , m.code_id#
         , d2.code
         , m.clause_id#
         , m.parameter_name
         , m.event_name
         , m.component_name
         , m.action_name
         , d1.name as rule_set_name
         , '%' as object_owner
         , m.object_name
         , m.enabled
         , m.privilege_scope
         , decode(m.scope, 1, 'NO',
                           2, 'YES',
                           3, 'YES') common
         , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
                     (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
                THEN 'YES'
                ELSE 'NO'
           END inherited
     FROM dvsys.command_rule$ m
         ,dvsys.dv$rule_set d1
         ,dvsys.dv$code d2
     WHERE
         d1.id# = m.rule_set_id#
         AND d2.id# = m.code_id#
         AND m.object_owner_uid# = &all_schema) s
LEFT JOIN (select distinct code_id#, clause_id#, clause_name from sys.v_$code_clause ) c
    ON s.code_id# = c.code_id#
       AND s.clause_id# = c.clause_id#
/

CREATE OR REPLACE VIEW DVSYS.DBA_DV_POLICY
(
    policy_name
  , description
  , state
  , id#
  , oracle_supplied
  , pl_sql_stack
)
AS SELECT
    pt.name
  , pt.description
  , decode(p.state, 0, 'DISABLED',
                    1, 'ENABLED',
                    2, 'SIMULATION',
                    3, 'PARTIAL')
  , p.id#
  , CASE WHEN p.id# < 5000 THEN 'YES' ELSE 'NO' END
  , decode(p.pl_sql_stack, 0, 'NO',
                           1, 'YES')
FROM dvsys.policy$ p, dvsys.policy_t$ pt
WHERE p.id# = pt.id# AND
      pt.language = DVSYS.dvlang(pt.id#, 7)
/

CREATE OR REPLACE VIEW DVSYS.DBA_DV_POLICY_OBJECT
(
    policy_name
  , object_type
  , realm_name
  , command
  , command_obj_owner
  , command_obj_name
  , command_clause
  , command_parameter
  , command_event
  , command_component
  , command_action
  , common
  , inherited
)
AS SELECT
    p.name
  , decode(po.object_type, 1, 'REALM',
                           2, 'COMMAND RULE')
  , case when po.object_type = 1 
           then (select r.name 
                 from dvsys.dv$realm r 
                 where r.id# = po.object_id#)
         else NULL
    end
  , case when po.object_type = 2
           then (select c.command 
                 from dvsys.dba_dv_command_rule_id c 
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.object_owner
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.object_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.clause_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.parameter_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.event_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.component_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.action_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 1
           then (select r.common
                 from dvsys.dv$realm r
                 where r.id# = po.object_id#) 
         else NULL
     end
  , case when po.object_type = 1
           then (select r.inherited
                 from dvsys.dv$realm r
                 where r.id# = po.object_id#) 
         else NULL
     end
FROM dvsys.policy_t$ p, dvsys.policy_object$ po
WHERE  
  p.id# = po.policy_id# AND p.language = DVSYS.dvlang(p.id#, 7)
/

CREATE OR REPLACE VIEW DVSYS.DBA_DV_POLICY_OWNER
(
    policy_name
  , policy_owner 
)
AS SELECT
    p.name
  , u.username
FROM dvsys.policy_t$ p, dvsys.policy_owner$ po, sys.dba_users u
WHERE
  p.id# = po.policy_id# AND po.owner_id# = u.user_id AND
  p.language = DVSYS.dvlang(p.id#, 7)
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_policy
(
    policy_name
  , description
  , state
  , id#
  , oracle_supplied
  , pl_sql_stack
)
AS SELECT
    pt.name
  , pt.description
  , decode(p.state, 0, 'DISABLED',  
                    1, 'ENABLED',
                    2, 'SIMULATION',
                    3, 'PARTIAL')
  , p.id#
  , CASE WHEN p.id# < 5000 THEN 'YES' ELSE 'NO' END
  , decode(p.pl_sql_stack, 0, 'NO',
                           1, 'YES')
FROM dvsys.policy$ p, dvsys.policy_t$ pt, dvsys.policy_owner$ po
WHERE p.id# = po.policy_id# AND p.id# = pt.id# AND
      pt.language = DVSYS.dvlang(pt.id#, 7) AND
      po.owner_id# = sys_context('userenv', 'current_userid')
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_policy_object
(
    policy_name
  , object_type
  , realm_name
  , command
  , command_obj_owner
  , command_obj_name
  , command_clause
  , command_parameter
  , command_event
  , command_component
  , command_action
  , common
  , inherited 
)
AS SELECT
    p.name
  , decode(po.object_type, 1, 'REALM',
                           2, 'COMMAND RULE')
  , case when po.object_type = 1
           then (select r.name
                 from dvsys.dv$realm r
                 where r.id# = po.object_id#)
         else NULL
    end
  , case when po.object_type = 2
           then (select c.command
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.object_owner
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.object_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.clause_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.parameter_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.event_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.component_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 2
           then (select c.action_name
                 from dvsys.dba_dv_command_rule_id c
                 where c.id# = po.object_id#)
         else NULL
     end
  , case when po.object_type = 1
           then (select r.common
                 from dvsys.dv$realm r
                 where r.id# = po.object_id#) 
         else NULL
     end
  , case when po.object_type = 1
           then (select r.inherited
                 from dvsys.dv$realm r
                 where r.id# = po.object_id#) 
         else NULL
     end
FROM dvsys.policy_t$ p, dvsys.policy_object$ po, dvsys.policy_owner$ pow
WHERE
  p.id# = po.policy_id# AND p.id# = pow.policy_id# AND
  pow.owner_id# = sys_context('userenv', 'current_userid') AND
  p.language = DVSYS.dvlang(p.id#, 7)
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_realm
(
    name
  , description
  , audit_options
  , realm_type
  , common_realm
  , inherited_realm 
  , enabled
  , id#
  , oracle_supplied
)
AS SELECT
    d.name
  , d.description
  , m.audit_options
  , decode(m.realm_type, 0, 'REGULAR',
                         1, 'MANDATORY')
  , decode(m.scope, 1, 'NO',
                    2, 'YES',
                    3, 'YES') common_realm
  , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
              (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
         THEN 'YES'
         ELSE 'NO'
    END inherited_realm
  , m.enabled
  , m.id#
  , CASE WHEN (m.id# < 5000) OR
              (1000000000 <= m.id# AND m.id# < 1000005000)
         THEN 'YES'
         ELSE 'NO'
    END
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id# AND
    d.language = DVSYS.dvlang(d.id#, 6) AND
    m.id# IN (SELECT object_id#
              FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
              WHERE pb.policy_id# = pw.policy_id# AND
                    pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                    pb.object_type = 1) -- dvsys.dbms_macutl.G_REALM
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_realm_auth
(
    realm_name
  , common_realm
  , inherited_realm
  , grantee
  , auth_rule_set_name
  , auth_options
  , common_auth
  , inherited_auth
)
AS SELECT
    d1.name
  , d1.common
  , d1.inherited
  , u.name
  , d2.name
  , c.value
  , decode(m.scope, 1, 'NO',
                    2, 'YES',
                    3, 'YES') common_auth
  , CASE WHEN (m.scope = 2 and sys_context('USERENV','IS_APPLICATION_PDB') = 'YES') or
              (m.scope = 3 and sys_context('USERENV','CON_ID') != 1)
         THEN 'YES'
         ELSE 'NO'
    END inherited_auth
FROM  dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
    , (select user#, name from sys."_BASE_USER"
       union
       select id as user#, name from sys.xs$obj where type = 1) u
WHERE
    d1.id# (+)= m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
    AND m.grantee_uid# = u.user#
    AND d1.id# IN (SELECT object_id#
                   FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
                   WHERE pb.policy_id# = pw.policy_id# AND
                         pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                         pb.object_type = 1) --dvsys.dbms_macutl.G_REALM
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_realm_object
(
      realm_name
    , common_realm
    , inherited_realm 
    , owner
    , object_name
    , object_type
)
AS SELECT
     d.name
    , d.common
    , d.inherited
    , u.name
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d, sys."_BASE_USER" u
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = u.user#
    AND d.id# IN (SELECT object_id#
                   FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
                   WHERE pb.policy_id# = pw.policy_id# AND
                         pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                         pb.object_type = 1) --dvsys.dbms_macutl.G_REALM
UNION
SELECT
     d.name
    , d.common
    , d.inherited
    , '%'
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = &all_schema
    AND d.id# IN (SELECT object_id#
                   FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
                   WHERE pb.policy_id# = pw.policy_id# AND
                         pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                         pb.object_type = 1) --dvsys.dbms_macutl.G_REALM
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_command_rule
(
      command
    , clause_name
    , parameter_name
    , event_name
    , component_name
    , action_name
    , rule_set_name
    , object_owner
    , object_name
    , enabled
    , privilege_scope
    , id#
    , oracle_supplied
)
AS
SELECT
      s.code
    , NVL(c.clause_name, '%')
    , s.parameter_name
    , s.event_name
    , s.component_name
    , s.action_name
    , s.rule_set_name
    , s.object_owner
    , s.object_name
    , s.enabled
    , s.privilege_scope
    , s.id#
    , CASE WHEN (s.id# < 5000)
           THEN 'YES'                                                           
           ELSE 'NO'                                                            
      END
FROM
    (SELECT
          m.code_id#
        , d2.code
        , m.clause_id#
        , m.parameter_name
        , m.event_name
        , m.component_name
        , m.action_name
        , d1.name as rule_set_name
        , u.name as object_owner
        , m.object_name
        , m.enabled
        , m.privilege_scope
        , m.id#
     FROM dvsys.command_rule$ m
        ,dvsys.dv$rule_set d1
        ,dvsys.dv$code d2
        ,sys."_BASE_USER" u
     WHERE
        d1.id# = m.rule_set_id#
        AND d2.id# = m.code_id#
        AND m.object_owner_uid# = u.user#
        AND m.id# IN (SELECT object_id#
                  FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
                  WHERE pb.policy_id# = pw.policy_id# AND
                        pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                        pb.object_type = 2) -- dvsys.dbms_macutl.G_COMMAND_RULE
     UNION
     SELECT
          m.code_id#
        , d2.code
        , m.clause_id#
        , m.parameter_name
        , m.event_name
        , m.component_name
        , m.action_name
        , d1.name as rule_set_name
        , '%' as object_owner
        , m.object_name
        , m.enabled
        , m.privilege_scope
        , m.id#
     FROM dvsys.command_rule$ m
        ,dvsys.dv$rule_set d1
        ,dvsys.dv$code d2
     WHERE
        d1.id# = m.rule_set_id#
        AND d2.id# = m.code_id#
        AND m.object_owner_uid# = &all_schema
        AND m.id# IN (SELECT object_id#
                  FROM dvsys.policy_object$ pb, dvsys.policy_owner$ pw
                  WHERE pb.policy_id# = pw.policy_id# AND
                        pw.owner_id# =  sys_context('userenv', 'current_userid') AND
                        pb.object_type = 2)) s -- dvsys.dbms_macutl.G_COMMAND_RULE
LEFT JOIN (select distinct code_id#, clause_id#, clause_name from sys.v_$code_clause ) c
    ON s.code_id# = c.code_id#
    AND s.clause_id# = c.clause_id#
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_rule_set
(
      rule_set_name
    , description
    , enabled
    , eval_options_meaning
    , audit_options
    , fail_options_meaning
    , fail_message
    , fail_code
    , handler_options
    , handler
    , is_static
    , id#
    , oracle_supplied
)
AS SELECT
      d.name
    , d.description
    , m.enabled
    , deval.value
    , m.audit_options
    , dfail.value
    , d.fail_message
    , m.fail_code
    , m.handler_options
    , m.handler
    , DECODE(bitand(m.eval_options, 128) , 128, 'TRUE', 'FALSE')
    , m.id#
    , CASE WHEN (m.id# < 5000)
           THEN 'YES'
           ELSE 'NO'
      END
FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 5)
    AND deval.code  = TO_CHAR(m.eval_options -
                             DECODE(bitand(m.eval_options,128) , 128, 128, 0))
    AND deval.code_group = 'RULESET_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = 'RULESET_FAIL'
    AND (d.name IN (SELECT pora.auth_rule_set_name
                    FROM dvsys.policy_owner_realm_auth pora) OR
         d.name IN (SELECT pocr.rule_set_name
                    FROM dvsys.policy_owner_command_rule pocr))
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_rule_set_rule
(
      rule_set_name
    , rule_name
    , rule_expr
    , enabled
    , rule_order
)
AS SELECT
      d1.name
    , d2.name 
    , d2.rule_expr
    , m.enabled
    , m.rule_order
FROM dvsys.rule_set_rule$ m
     ,dvsys.dv$rule_set d1
     ,dvsys.dv$rule d2
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.rule_id#
    AND d1.name IN (SELECT pors.rule_set_name
                          FROM dvsys.policy_owner_rule_set pors)
/

CREATE OR REPLACE VIEW DVSYS.policy_owner_rule
(
      name
    , rule_expr
    , id#
    , oracle_supplied
)
AS SELECT
      d.name
    , m.rule_expr
    , m.id#
    , CASE WHEN (m.id# < 5000)
           THEN 'YES'
           ELSE 'NO'
      END
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 4)
    AND name in (SELECT porsr.rule_name
                 FROM dvsys.policy_owner_rule_set_rule porsr)
/

BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."POLICY$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."POLICY_OBJECT$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."POLICY_OWNER$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

------------------------------------------------------------------------------
--              Database Vault Protected Schema (DVPS) Interface
--                       for Data Pump export/import 
------------------------------------------------------------------------------
-- Bug 21133991 - Replace "create or replace type" statements with "drop type
-- and create type" statements as "create or replace type" could fail several
-- ways includ the following cases (For this bug, it failed to replace
-- dvsys.ku$_dv_realm_member_t type due to reason #2):
-- 1. Another type or table is dependent on the type
-- 2. The type is altered previously
-- These types are not storing any  persistent information. Hence, it is
-- safe to forcefully drop them.

-- UDT and object-view for the 'DVPS_IMPORT_STAGING_REALM' homogeneous type
-- (xmltag: 'DVPS_IMPORT_STAGING_REALM_T', XSLT: rdbms/xml/xsl/kudvsta.xsl),
-- as well as for the 'DVPS_DROP_IMPORT_STAGING_REALM' homogeneous type 
-- (xmltag: 'DVPS_DISR_T', XSLT: rdbms/xml/xsl/kudvstad.xsl).
begin
execute immediate 'drop type dvsys.ku$_dv_isr_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_isr_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1)                              /* UDT minor version # */
)
/

-- The ku$_dv_isr_view contains one row if any Database Vault
-- Realm-protected schema exists in the database, i.e. if any schema has
-- been passed as the object_owner in a call to ADD_OBJECT_TO_REALM.
-- The REALM_ID# sequence starts at 5000, so Realms with REALM_ID# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with realm_id# 5000 is a
-- "seeded" Realm, created by the Database Vault installation, and
-- should not be exported.
create or replace force view dvsys.ku$_dv_isr_view
       of dvsys.ku$_dv_isr_t
  with object identifier (vers_major) as
  select '0','0'
    from sys.dual
   where (sys_context('USERENV','CURRENT_USERID') = 1279990
          or exists (select 1
                       from sys.session_roles
                      where role='DV_OWNER'))
     and exists (select 1
                   from dvsys.realm_object$ objects_in_realm
                  where objects_in_realm.REALM_ID# > 5000)
/

show errors;

-- UDT and object-view for 'DVPS_STAGING_REALM_MEMBERSHIP' homogeneous type,
-- (xmltag: 'DVPS_STAGING_REALM_MEMBERSHP_T', XSLT rdbms/xml/xsl/kudvstam.xsl)
-- corresponding to xmltag 'DVPS_STAGING_REALM_MEMBERSHP_T'.
begin
execute immediate 'drop type dvsys.ku$_dv_isrm_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_isrm_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  schema_name   varchar2(128)    /* schema to be protected by Staging Realm */
)
/

-- The ku$_dv_isrm_view lists all of the schema names which have 
-- been passed as the object_owner in a call to ADD_OBJECT_TO_REALM.
-- These schemas will be added to a new Realm created as the first step
-- of Full Database Import with the name 'Datapump Import Staging 
-- Realm for Database Vault', using a wildcard for both object_name and 
-- object_type, so that any imported objects in these schemas 
-- will automatically be protected.
-- The REALM_ID# sequence starts at 5000, so Realms with REALM_ID# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with realm_id# 5000 is a
-- "seeded" Realm, created by the Database Vault installation, and
-- should not be exported.
create or replace force view dvsys.ku$_dv_isrm_view
       of dvsys.ku$_dv_isrm_t
  with object identifier (schema_name) as
  select '0','0',
         realm_objects.object_owner
    from (select distinct(objects_in_realm.owner) object_owner
            from dvsys.dv$realm_object objects_in_realm
           where objects_in_realm.REALM_ID# > 5000) realm_objects
   where (sys_context('USERENV','CURRENT_USERID') = 1279990
          or exists (select 1 
                       from sys.session_roles
                      where role='DV_OWNER'))
/

show errors;

-- UDT and object-view for the 'DVPS_REALM' homogeneous type.
-- (xmltag: 'DVPS_REALM_T', XSLT: rdbms/xml/xsl/kudvrlm.xsl),
-- representing Database Vault Realms created using CREATE_REALM.
begin
execute immediate 'drop type dvsys.ku$_dv_realm_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_realm_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),              /* name of database vault realm */
  description   varchar2(1024),      /* description of database vault realm */
  language      varchar2(3),               /* language of realm description */
  realm_type    number,                                       /* realm type */
  realm_scope   number,                                      /* realm scope */
  enabled       varchar2(1),       /* enabled state of database vault realm */
  audit_options varchar2(78)       /* audit options of database vault realm */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view dvsys.ku$_dv_realm_view
       of dvsys.ku$_dv_realm_t
  with object identifier (name, realm_scope) as
  select '0','0',
          rlmt.name,
          rlmt.description,
          rlmt.language,
          rlm.realm_type,
          decode(rlm.scope, 1, 1, 2, 2, 3, 2),
          rlm.enabled,
          decode(rlm.audit_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS+'||
                    'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL)',
                 to_char(rlm.audit_options))
  from    dvsys.realm$        rlm,
          dvsys.realm_t$      rlmt
  where   rlm.id# = rlmt.id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_REALM_MEMBERSHIP' homogeneous type,
-- (xmltag: 'DVPS_REALM_MEMBERSHIP_T', XSLT: rdbms/xml/xsl/kudvrlmm.xsl),
-- representing realm protections created using ADD_OBJECT_TO_REALM.
begin
execute immediate 'drop type dvsys.ku$_dv_realm_member_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_realm_member_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  name          varchar2(128),              /* name of database vault realm */
  object_owner  varchar2(128),   /* owner of object protected by this realm */
  object_name   varchar2(128),    /* name of object protected by this realm */
  object_type   varchar2(32)      /* type of object protected by this realm */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view dvsys.ku$_dv_realm_member_view
       of ku$_dv_realm_member_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          rlmt.name,
          rlmo.owner,
          rlmo.object_name,
          rlmo.object_type
  from    dvsys.realm_t$        rlmt,
          dvsys.dv$realm_object rlmo
  where   rlmo.realm_id# = rlmt.id#
    and   rlmt.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_REALM_AUTHORIZATION' homogeneous type
-- (xmltag: 'DVPS_REALM_AUTHORIZATION_T', XSLT: rdbms/xml/xsl/kudvrlma.xsl),
-- representing Realm participants/owners added using ADD_AUTH_TO_REALM.
begin
execute immediate 'drop type dvsys.ku$_dv_realm_auth_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_realm_auth_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  realm_name    varchar2(128),              /* name of database vault realm */
  grantee       varchar2(128),        /* owner of (or participant in) realm */
  rule_set_name varchar2(128),     /* rule set used to authorize (optional) */
  auth_options  varchar2(42),       /* authorization (participant or owner) */
  auth_scope    number                         /* realm authorization scope */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view dvsys.ku$_dv_realm_auth_view
       of dvsys.ku$_dv_realm_auth_t
  with object identifier (realm_name, grantee, auth_scope) as
  select '0','0',
          rlmt.name,
          rlma.grantee,
          rs.name,
          decode(rlma.auth_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_OWNER',
                 to_char(rlma.auth_options)),
          decode(rlma.common_auth, 'YES', 2, 'NO', 1)
  from    dvsys.realm_t$                 rlmt,
          dvsys.dv$realm_auth            rlma,
          (select m.id#,
                  d.name
             from dvsys.rule_set$   m,
                  dvsys.rule_set_t$ d
            where m.id# = d.id#)         rs
  where   rlmt.id# = rlma.realm_id#
    and   rs.id# (+)= rlma.auth_rule_set_id#
    and   rlmt.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE' homogeneous type
-- (xmltag: 'DVPS_RULE_T', XSLT: rdbms/xml/xsl/kudvrul.xsl),
-- representing Rules added using CREATE_RULE.
-- This object-view is similar to the DVSYS.dv$rule view.
begin
execute immediate 'drop type dvsys.ku$_dv_rule_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_rule_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  rule_name     varchar2(128),                              /* name of Rule */
  rule_expr     varchar2(1024),       /* PL/SQL boolean expression for Rule */
  language      varchar2(3),                       /* language of Rule name */
  scope         number
)
/

-- The rule$.id# sequence starts at 5000, so Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
-- In addition, Rules which are members of the Rule Set with the name
-- 'Allow Oracle Data Pump Operation' (which has a rule_set_id# of 8) should 
-- not be exported, as they are system-managed Rules created 
-- by means of the dbms_macadm.authorize_datapump_user API.
create or replace force view dvsys.ku$_dv_rule_view
       of dvsys.ku$_dv_rule_t
  with object identifier (rule_name, scope) as
  select '0','0',
          rult.name,
          rul.rule_expr,
          rult.language,
          decode(rul.scope, 1, 1,
                            2, 2,
                            3, 2)
  from    dvsys.rule$                   rul,
          dvsys.rule_t$                 rult
  where   rul.id# = rult.id#
    and   rul.id# >= 5000
    and   rul.id# not in (select rule_id#
                            from dvsys.rule_set_rule$
                           where rule_set_id# = 8)
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE_SET' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_T', XSLT: rdbms/xml/xsl/kudvruls.xsl),
-- representing Rule Sets added using CREATE_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set view.
begin
execute immediate 'drop type dvsys.ku$_dv_rule_set_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_rule_set_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(128),                        /* name of Rule Set */
  description     varchar2(1024),                /* description of Rule Set */
  language        varchar2(3),          /* language of Rule Set description */
  enabled         varchar2(1),      /* the Rule Set is enabled ('Y' or 'N') */
  eval_options    varchar2(36),                 /* evaluate all or any Rule */
  audit_options   varchar2(78),  /* auditing: off, on failure or on success */
  fail_options    varchar2(39),    /* show an error message, or stay silent */
  fail_message    varchar2(80),      /* error message to display on failure */
  fail_code       varchar2(10),   /* code to associate with failure message */
  handler_options varchar2(43),  /* error handler: off, on fail, on success */
  handler         varchar2(1024),/* PL/SQL routine for custom event handler */
  scope           number
)
/

-- The rule_set$.id# sequence starts at 5000, so Rule Sets with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. 
create or replace force view dvsys.ku$_dv_rule_set_view
       of dvsys.ku$_dv_rule_set_t
  with object identifier (rule_set_name, scope) as
  select '0','0',
          rulst.name,
          rulst.description,
          rulst.language,
          ruls.enabled,
          decode(ruls.eval_options,
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_EVAL_ALL',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_EVAL_ANY',
                 to_char(ruls.eval_options)),
          decode(ruls.audit_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS+'||
                    'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL)',
                 to_char(ruls.audit_options)),
          decode(ruls.fail_options,
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_FAIL_SHOW',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_FAIL_SILENT',
                 to_char(ruls.fail_options)),
          rulst.fail_message,
          ruls.fail_code,
          decode(ruls.handler_options,
                 0,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_FAIL+'||
                    'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_SUCCESS)',
                 to_char(ruls.handler_options)),
          ruls.handler,
          decode(ruls.scope, 1, 1,
                             2, 2,
                             3, 2)
  from    dvsys.rule_set$               ruls,
          dvsys.rule_set_t$             rulst
  where   ruls.id# = rulst.id#
    and   ruls.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE_SET_MEMBERSHIP' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_MEMBERSHIP_T', XSLT: rdbms/xml/xsl/kudvrsm.xsl),
-- representing the Rules added to a Rule Set using ADD_RULE_TO_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set_rule view.
begin
execute immediate 'drop type dvsys.ku$_dv_rule_set_member_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_rule_set_member_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  oidval          raw(16),                                     /* unique id */
  rule_set_name   varchar2(128),                        /* name of Rule Set */
  rule_name       varchar2(128),                            /* name of Rule */
  rule_order      number,                         /* unused in this release */
  enabled         varchar2(1)       /* the Rule Set is enabled ('Y' or 'N') */
)
/

-- The rule_set$.id# sequence starts at 5000, so Rule Sets with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. 
create or replace force view dvsys.ku$_dv_rule_set_member_view
       of dvsys.ku$_dv_rule_set_member_t
  with object identifier (oidval) as
  select '0','0', sys_guid(),
          rulst.name,
          rult.name,
          rsr.rule_order, 
          rsr.enabled
  from    dvsys.rule_set_rule$          rsr,
          dvsys.rule_set$               ruls,
          dvsys.rule_set_t$             rulst,
          dvsys.rule$                   rul,
          dvsys.rule_t$                 rult
  where   ruls.id# = rsr.rule_set_id#
    and   ruls.id# = rulst.id#
    and    rul.id# = rsr.rule_id#
    and    rul.id# = rult.id#
    and   ruls.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_COMMAND_RULE' homogeneous type
-- (xmltag: 'DVPS_COMMAND_RULE_T', XSLT: rdbms/xml/xsl/kudvcr.xsl),
-- representing the Command Rules created using CREATE_COMMAND_RULE.
-- This object-view selects directly from the DVSYS.dv$command_rule view.
begin
execute immediate 'drop type dvsys.ku$_dv_command_rule_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_command_rule_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  oidval          raw(16),                                     /* unique id */
  command         varchar2(128),                /* SQL statement to protect */
  rule_set_name   varchar2(128),                        /* name of Rule Set */
  object_owner    varchar2(128),                            /* schema owner */
  object_name     varchar2(128),       /* object name (may be wildcard '%') */
  enabled         varchar2(1),  /* the Command Rule is enabled ('Y' or 'N') */
  scope           number
)
/

-- The command_rule$.id# sequence starts at 5000, so Command Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
create or replace force view dvsys.ku$_dv_command_rule_view
       of dvsys.ku$_dv_command_rule_t
  with object identifier (oidval) as
  select '0','0', sys_guid(),
          cvcr.command,
          cvcr.rule_set_name,
          cvcr.object_owner, 
          cvcr.object_name,
          cvcr.enabled,
          decode(cr.scope, 1, 1,
                           2, 2,
                           3, 2)
  from    dvsys.dv$command_rule cvcr, dvsys.command_rule$ cr
  where   cvcr.id# >= 5000 and cvcr.id# = cr.id#
    and   cvcr.command <> 'ALTER SYSTEM' 
    and   cvcr.command <> 'ALTER SESSION'
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;


-- UDT and object-view for 'DVPS_COMMAND_RULE_ALTS' homogeneous type
-- (xmltag: 'DVPS_COMMAND_RULE_ALTS_T', XSLT: rdbms/xml/xsl/kudvcralts.xsl),
-- representing the Command Rules created using CREATE_COMMAND_RULE.
-- This object-view selects directly from the DVSYS.dv$command_rule view.
begin
execute immediate 'drop type dvsys.ku$_dv_comm_rule_alts_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create or replace type dvsys.ku$_dv_comm_rule_alts_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  oidval          raw(16),                                     /* unique id */
  command         varchar2(128),                /* SQL statement to protect */
  rule_set_name   varchar2(128),                        /* name of Rule Set */
  object_owner    varchar2(128),                            /* schema owner */
  object_name     varchar2(128),       /* object name (may be wildcard '%') */
  enabled         varchar2(1),  /* the Command Rule is enabled ('Y' or 'N') */
  clause_name     varchar2(100),    /* name of clause (may be wildcard '%') */
  parameter_name  varchar2(128),                   /* clause parameter name */
  event_name      varchar2(128),                              /* event name */
  component_name  varchar2(128),                       /* event target name */
  action_name     varchar2(128),                       /* event action name */
  scope           number
)
/

-- The command_rule$.id# sequence starts at 5000, so Command Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
create or replace force view dvsys.ku$_dv_comm_rule_alts_v
       of dvsys.ku$_dv_comm_rule_alts_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          cvcr.command,
          cvcr.rule_set_name,
          '%', 
          '%',
          cvcr.enabled,
          cvcr.clause_name,
          cvcr.parameter_name,
          cvcr.event_name,
          cvcr.component_name,
          cvcr.action_name,
          decode(cr.scope, 1, 1,
                           2, 2,
                           3, 2)
  from    dvsys.dv$command_rule cvcr, dvsys.command_rule$ cr
  where   cvcr.id# >= 5000 and cvcr.id# = cr.id#
    and   (cvcr.command = 'ALTER SYSTEM' or cvcr.command = 'ALTER SESSION')
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;


-- UDT and object-view for 'DVPS_ROLE' homogeneous type
-- (xmltag: 'DVPS_ROLE_T', XSLT: rdbms/xml/xsl/kudvrol.xsl),
-- representing the Roles created using CREATE_ROLE.
-- This object-view is based on the DVSYS.dba_dv_role view.
begin
execute immediate 'drop type dvsys.ku$_dv_role_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_role_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  role               varchar2(128),                            /* Role name */
  enabled            varchar2(1),                      /* Enabled? (Y or N) */
  rule_set_name      varchar2(128)                         /* Rule Set name */
)
/

-- The dvsys.role$_seq sequence for role$.id# starts at 5000,
-- so Roles with id# less than 5000 are reserved for internal use
-- by Database Vault, and should not be exported.
create or replace force view dvsys.ku$_dv_role_view
       of dvsys.ku$_dv_role_t
  with object identifier (role) as
  select '0','0',
         roles.role,
         roles.enabled,
         rulst.name
    from dvsys.role$         roles,
         dvsys.rule_set$     ruls,
         dvsys.rule_set_t$   rulst
   where roles.rule_set_id# = ruls.id#
     and ruls.id# = rulst.id#
     and roles.id# >= 5000
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR' homogeneous type
-- (xmltag: 'DVPS_FACTOR_T', XSLT: rdbms/xml/xsl/kudvf.xsl),
-- representing the Factors created using CREATE_FACTOR.
-- This object-view is based on the DVSYS.dba_dv_factor view.
begin
execute immediate 'drop type dvsys.ku$_dv_factor_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_factor_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  factor_name        varchar2(128),                          /* Factor name */
  factor_type_name   varchar2(128),                     /* Factor Type name */
  description        varchar2(4000),                         /* Description */
  language           varchar2(3),         /* language of Factor description */
  rule_set_name      varchar2(128),                        /* Rule Set name */
  get_expr           varchar2(1024),                      /* Get expression */
  validate_expr      varchar2(1024),                 /* Validate expression */
  identify_by        varchar2(40),                           /* Identify by */
  labeled_by         varchar2(40),                            /* Labeled by */
  eval_options       varchar2(40),                          /* Eval options */
  audit_options      varchar2(400),                        /* Audit options */
  fail_options       varchar2(37)                           /* Fail options */
)
/

-- The dvsys.factor$_seq sequence for factor$.id# starts at 5000,
-- so Factors with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
-- The use of substr removes the initial " || " from the audit_options string.
create or replace force view dvsys.ku$_dv_factor_view
       of dvsys.ku$_dv_factor_t
  with object identifier (factor_name) as
  select '0','0',
         m.name,
         dft.name,
         d.description,
         d.language,
         drs.name,
         m.get_expr,
         m.validate_expr,
         decode(m.identified_by,
                 0,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_CONSTANT', 
                 1,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_METHOD',
                 2,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_FACTOR',
                 3,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_CONTEXT',
                 4,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_RULESET',
                 to_char(m.identified_by)),
         decode(m.labeled_by,
                 0,'DVSYS.DBMS_MACUTL.G_LABELED_BY_SELF', 
                 1,'DVSYS.DBMS_MACUTL.G_LABELED_BY_FACTORS',
                 to_char(m.labeled_by)),
         decode(m.eval_options,
                 0,'DVSYS.DBMS_MACUTL.G_EVAL_ON_SESSION', 
                 1,'DVSYS.DBMS_MACUTL.G_EVAL_ON_ACCESS',
                 2,'DVSYS.DBMS_MACUTL.G_EVAL_ON_STARTUP',
                 to_char(m.eval_options)),
         decode(m.audit_options,
                0,'DVSYS.DBMS_MACUTL.G_AUDIT_OFF', 
                substr(
                  decode(bitand(m.audit_options,power(2,0)),
                        power(2,0),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ALWAYS',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,1)),
                        power(2,1),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_GET_ERROR',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,2)),
                        power(2,2),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_GET_NULL',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,3)),
                        power(2,3),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_VALIDATE_ERROR',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,4)),
                        power(2,4),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_VALIDATE_FALSE',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,5)),
                        power(2,5),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_TRUST_LEVEL_NULL',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,6)),
                        power(2,6),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_TRUST_LEVEL_NEG',
                        0,''), 5)),
         decode(m.fail_options,
                 1,'DVSYS.DBMS_MACUTL.G_FAIL_WITH_MESSAGE', 
                 2,'DVSYS.DBMS_MACUTL.G_FAIL_SILENTLY',
                 to_char(m.fail_options))
   from dvsys.factor$         m,
        dvsys.factor_t$       d,
        dvsys.factor_type_t$  dft,
        dvsys.rule_set_t$     drs
  where m.id# = d.id#
    and dft.id# = m.factor_type_id#
    and drs.id#  (+)= m.assign_rule_set_id#
    and m.id# >= 5000
    and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
         EXISTS ( SELECT * FROM sys.session_roles
                  WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR_LINK' homogeneous type
-- (xmltag: 'DVPS_FACTOR_LINK_T', XSLT: rdbms/xml/xsl/kudvfl.xsl),
-- representing the Factor Links created using ADD_FACTOR_LINK.
-- This object-view is based on the DVSYS.dba_dv_factor_link view.
begin
execute immediate 'drop type dvsys.ku$_dv_factor_link_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_factor_link_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  parent_factor_name varchar2(128),                   /* Parent Factor name */
  child_factor_name  varchar2(128),                    /* Child Factor name */
  label_indicator    varchar2(1) /* Contributes to label of parent (Y or N) */
)
/

-- The dvsys.factor_link$_seq sequence for factor_link$.id# starts at 5000,
-- so Factor Links with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view dvsys.ku$_dv_factor_link_view
       of dvsys.ku$_dv_factor_link_t
  with object identifier (parent_factor_name) as
  select '0','0',
          d1.name,
          d2.name,
          m.label_ind
  from    dvsys.factor_link$   m,
          dvsys.factor$        d1,
          dvsys.factor$        d2
  where   d1.id# = m.parent_factor_id#
    and   d2.id# = m.child_factor_id#
    and   m.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR_TYPE' homogeneous type
-- (xmltag: 'DVPS_FACTOR_TYPE_T', XSLT: rdbms/xml/xsl/kudvft.xsl),
-- representing the Factor Types created using CREATE_FACTOR_TYPE.
-- This object-view is based on the DVSYS.dba_dv_factor_type view.
begin
execute immediate 'drop type dvsys.ku$_dv_factor_type_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_factor_type_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  name            varchar2(128),                        /* Factor type name */
  description     varchar2(1024),  /* Description of purpose of Factor type */
  language        varchar2(3)        /* language of Factor type description */
)
/

-- The dvsys.factor_type$_seq sequence for factor_type$.id# starts at 5000,
-- so Factor Types with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view dvsys.ku$_dv_factor_type_view
       of dvsys.ku$_dv_factor_type_t
  with object identifier (name) as
  select '0','0',
          factt.name,
          factt.description,
          factt.language
  from    dvsys.factor_type$            fact,
          dvsys.factor_type_t$          factt
  where   fact.id# = factt.id#
    and   fact.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_IDENTITY' homogeneous type
-- (xmltag: 'DVPS_IDENTITY_T', XSLT: rdbms/xml/xsl/kudvid.xsl),
-- representing the Identities created using CREATE_IDENTITY.
-- This object-view is based on the DVSYS.dba_dv_identity view.
begin
execute immediate 'drop type dvsys.ku$_dv_identity_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_identity_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  factor_name     varchar2(128),                        /* Factor type name */
  value           varchar2(1024),  /* Description of purpose of Factor type */
  trust_level     number    /* Trust, relative to other ids for same Factor */
)
/

-- The dvsys.dvsys.identity$_seq sequence for identity$.id# starts at 5000,
-- so Identities  with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view dvsys.ku$_dv_identity_view
       of dvsys.ku$_dv_identity_t
  with object identifier (factor_name) as
  select '0','0',
          fac.name,
          iden.value,
          iden.trust_level
  from    dvsys.factor$                 fac,
          dvsys.identity$               iden
  where   fac.id# = iden.factor_id#
    and   fac.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_IDENTITY_MAP' homogeneous type
-- (xmltag: 'DVPS_IDENTITY_MAP_T', XSLT: rdbms/xml/xsl/kudvidm.xsl),
-- representing the Identity Maps created using CREATE_IDENTITY_MAP.
-- This object-view is based on the DVSYS.dba_dv_identity_map view.
begin
execute immediate 'drop type dvsys.ku$_dv_identity_map_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_identity_map_t as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  identity_factor_name     varchar2(128),          /* Factor the map is for */
  identity_factor_value    varchar2(1024),     /* Value the map will assume */
  parent_factor_name       varchar2(128),             /* parent Factor link */
  child_factor_name        varchar2(128),              /* child Factor link */
  operation                varchar2(30),             /* relational operator */
  operand1                 varchar2(30),                    /* left operand */
  operand2                 varchar2(30)                    /* right operand */
)
/

-- The dvsys.identity_map$_seq sequence for identity_map$.id# starts at 5000,
-- so Identity Maps  with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view dvsys.ku$_dv_identity_map_view
       of dvsys.ku$_dv_identity_map_t
  with object identifier (identity_factor_name) as
  select '0','0',
          d6.name,
          d1.value,
          d4.name,
          d5.name,
          d2.code,
          m.operand1,
          m.operand2
  from    dvsys.identity_map$           m,
          dvsys.identity$               d1,
          dvsys.code$                   d2,
          dvsys.factor_link$            d3,
          dvsys.factor$                 d4,
          dvsys.factor$                 d5,
          dvsys.factor$                 d6
  where   d1.id# = m.identity_id#
    and   m.id# >= 5000
    and   d2.id# = m.operation_code_id#
    and   d2.code_group = 'OPERATORS'
    and   d3.id# (+)= m.factor_link_id#
    and   d4.id# (+)= d3.parent_factor_id#
    and   d5.id# (+)= d3.child_factor_id#
    and   d6.id# = d1.factor_id#
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

-- UDT and object-view for the 'DVPS_DV_POLICY' homogeneous type.
-- (xmltag: 'DVPS_DV_POLICY_T', XSLT: rdbms/xml/xsl/kudvpol.xsl),
-- representing Database Vault Policies created using CREATE_POLICY.
begin
execute immediate 'drop type dvsys.ku$_dv_policy_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_policy_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  policy_name   varchar2(128),                         /* name of DV policy */
  description   varchar2(1024),                 /* description of DV policy */
  policy_state  varchar2(50)                          /* state of DV policy */
)
/

-- The policy ID less than 5000 is reserved for internal usages (e.g., default
-- policies) and should not be exported.
create or replace force view dvsys.ku$_dv_policy_v
       of dvsys.ku$_dv_policy_t
  with object identifier (policy_name) as
  select '0','0',
          pt.name,
          pt.description,
          decode(p.state,
                 0, 'DVSYS.DBMS_MACADM.G_DISABLED',
                 1, 'DVSYS.DBMS_MACADM.G_ENABLED',
                 2, 'DVSYS.DBMS_MACADM.G_SIMULATION',
                 3, 'DVSYS.DBMS_MACADM.G_PARTIAL',
                 to_char(p.state))
  from    dvsys.policy$ p, dvsys.policy_t$ pt
  where   p.id# >= 5000 and p.id# = pt.id# and
          pt.language = dvsys.dvlang(pt.id#, 7)
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                       from sys.session_roles
                       where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_POLICY_OBJ_R' homogeneous type.
-- (xmltag: 'DVPS_DV_POLICY_OBJ_R_T', XSLT: rdbms/xml/xsl/kudvpolobjr.xsl),
-- representing realms added to Database Vault Policy by ADD_REALM_TO_POLICY.
begin
execute immediate 'drop type dvsys.ku$_dv_policy_obj_r_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_policy_obj_r_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  policy_name   varchar2(128),                         /* name of DV policy */
  realm_name    varchar2(128)                           /* name of DV realm */
)
/

-- The ID# less than 5000 is reserved for internal usages (e.g., default
-- policies) and should not be exported.
create or replace force view dvsys.ku$_dv_policy_obj_r_v
       of dvsys.ku$_dv_policy_obj_r_t
  with object identifier (policy_name, realm_name) as
  select '0','0',
          p.name,
          rt.name
  from    dvsys.policy_t$      p,
          dvsys.policy_object$ po,
          dvsys.realm_t$       rt
  where   po.id# >= 5000
    and   po.object_type = 1  -- realm
    and   po.policy_id# = p.id#
    and   po.object_id# = rt.id#
    and   p.language = dvsys.dvlang(p.id#, 7)
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_POLICY_OBJ_C' homogeneous type.
-- (xmltag: 'DVPS_DV_POLICY_OBJ_C_T', XSLT: rdbms/xml/xsl/kudvpolobjc.xsl),
-- representing command rules added to Database Vault Policy by 
-- ADD_COMMAND_RULE_TO_POLICY.
begin
execute immediate 'drop type dvsys.ku$_dv_policy_obj_c_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_policy_obj_c_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  oidval          raw(16),                                     /* unique id */
  policy_name     varchar2(128),                       /* name of DV policy */
  command         varchar2(128),                                 /* command */
  object_owner    varchar2(128),                            /* object owner */
  object_name     varchar2(128),                             /* object name */
  scope           number
)
/

-- The ID# less than 5000 is reserved for internal usages (e.g., default
-- policies) and should not be exported (exclude the alter system/session command rules).
create or replace force view dvsys.ku$_dv_policy_obj_c_v
       of dvsys.ku$_dv_policy_obj_c_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          p.name,
          cr.command,
          cr.object_owner,
          cr.object_name,
          decode(crtab.scope, 1, 1,
                              2, 2,
                              3, 2)
  from    dvsys.policy_t$               p,
          dvsys.policy_object$          po,
          dvsys.dba_dv_command_rule_id  cr,
          dvsys.command_rule$           crtab
  where   po.id# >= 5000 and cr.id# = crtab.id#
    and   po.object_type = 2  -- command rule
    and   cr.command <> 'ALTER SYSTEM' 
    and   cr.command <> 'ALTER SESSION'
    and   po.policy_id# = p.id#
    and   po.object_id# = cr.id#
    and   p.language = DVSYS.dvlang(p.id#, 7)
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_POLICY_OBJ_C_ALTS' homogeneous type.
-- (xmltag: 'DVPS_DV_POLICY_OBJ_C_ALTS_T', 
--  XSLT: rdbms/xml/xsl/kudvpolobjcalts.xsl),
-- representing command rules added to Database Vault Policy by 
-- ADD_COMMAND_RULE_TO_POLICY.
begin
execute immediate 'drop type dvsys.ku$_dv_policy_obj_c_alts_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_policy_obj_c_alts_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  oidval          raw(16),                                     /* unique id */
  policy_name     varchar2(128),                       /* name of DV policy */
  command         varchar2(128),                                 /* command */
  object_owner    varchar2(128),                            /* object owner */
  object_name     varchar2(128),                             /* object name */
  clause_name     varchar2(100),    /* name of clause (may be wildcard '%') */
  parameter_name  varchar2(128),                   /* clause parameter name */
  event_name      varchar2(128),                              /* event name */
  component_name  varchar2(128),                       /* event target name */
  action_name     varchar2(128),                       /* event action name */
  scope           number
)
/

-- The ID# less than 5000 is reserved for internal usages (e.g., default
-- policies) and should not be exported. (ALTER SYSTEM/SESSION command rules)
-- Please note that size of the PRIMARY KEY-based object identifier of
-- an object view should not exceed the maximum size of 4000 bytes.
-- Since object_owner and object_name are always % for ALTER SYSTEM/SESSION
-- command rules, thus no need to put these two in the object identifier.
create or replace force view dvsys.ku$_dv_policy_obj_c_alts_v
       of dvsys.ku$_dv_policy_obj_c_alts_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          p.name,
          cr.command,
          '%',
          '%',
          cr.clause_name,
          cr.parameter_name,
          cr.event_name,
          cr.component_name,
          cr.action_name,
          decode(crtab.scope, 1, 1,
                              2, 2,
                              3, 2)
  from    dvsys.policy_t$               p,
          dvsys.policy_object$          po,
          dvsys.dba_dv_command_rule_id  cr,
          dvsys.command_rule$           crtab
  where   po.id# >= 5000 and cr.id# = crtab.id#
    and   po.object_type = 2  -- command rule
    and   (cr.command = 'ALTER SYSTEM' or cr.command = 'ALTER SESSION')
    and   po.policy_id# = p.id#
    and   po.object_id# = cr.id#
    and   p.language = DVSYS.dvlang(p.id#, 7)
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_POLICY_OWNER' homogeneous type.
-- (xmltag: 'DVPS_DV_POLICY_OBJ_OWNER_T', XSLT: rdbms/xml/xsl/kudvpolowner.xsl),
-- representing Database Vault Policy owner created by ADD_OWNER_TO_POLICY.
begin
execute immediate 'drop type dvsys.ku$_dv_policy_owner_t force';
  exception
  when others then
  if sqlcode in ( -04043) then null; -- object does not exist
  else raise;
  end if;
end;
/

create type dvsys.ku$_dv_policy_owner_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  policy_name   varchar2(128),                         /* name of DV policy */
  owner_name    varchar2(128)                       /* name of policy owner */
)
/

create or replace force view dvsys.ku$_dv_policy_owner_v
       of dvsys.ku$_dv_policy_owner_t
  with object identifier (policy_name, owner_name) as
  select '0','0',
          pov.policy_name,
          pov.policy_owner
  from    dvsys.dba_dv_policy_owner pov
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_DP' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_DP_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Data Pump
-- granted by AUTHORIZE_DATAPUMP_USER.
create or replace type dvsys.ku$_dv_auth_dp_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  grantee_name  varchar2(128),                           /* name of grantee */
  schema_name   varchar2(128),                    /* name of granted schema */
  object_name   varchar2(128),                    /* name of granted object */
  action        varchar2(30)                           /* authorized action */
)
/

create or replace force view dvsys.ku$_dv_auth_dp_v
       of dvsys.ku$_dv_auth_dp_t
  with object identifier (oidval) as
  select '0','0', sys_guid(),
          d.grantee,
          d.schema,
          d.object,
          d.action
  from    dvsys.dba_dv_datapump_auth d
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_TTS' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_TTS_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Transportable Data Pump
-- granted by AUTHORIZE_TTS_USER.
create or replace type dvsys.ku$_dv_auth_tts_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_name  varchar2(128),                           /* name of grantee */
  ts_name       varchar2(128)                 /* name of granted tablespace */
)
/

create or replace force view dvsys.ku$_dv_auth_tts_v
       of dvsys.ku$_dv_auth_tts_t
  with object identifier (grantee_name, ts_name) as
  select '0','0',
          t.grantee,
          t.tsname
  from    dvsys.dba_dv_tts_auth t
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_JOB' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_JOB_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Scheduler
-- granted by AUTHORIZE_SCHEDULER_USER.
create or replace type dvsys.ku$_dv_auth_job_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  grantee_name  varchar2(128),                           /* name of grantee */
  schema_name   varchar2(128)                     /* name of granted schema */
)
/

create or replace force view dvsys.ku$_dv_auth_job_v
       of dvsys.ku$_dv_auth_job_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          j.grantee,
          j.schema
  from    dvsys.dba_dv_job_auth j
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_PROXY' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_PROXY_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for PROXY
-- granted by AUTHORIZE_PROXY_USER.
create or replace type dvsys.ku$_dv_auth_proxy_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  grantee_name  varchar2(128),                           /* name of grantee */
  schema_name   varchar2(128)                     /* name of granted schema */
)
/

create or replace force view dvsys.ku$_dv_auth_proxy_v
       of dvsys.ku$_dv_auth_proxy_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          p.grantee,
          p.schema
  from    dvsys.dba_dv_proxy_auth p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_DDL' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_DDL_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for DDL
-- granted by AUTHORIZE_DDL.
create or replace type dvsys.ku$_dv_auth_ddl_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  grantee_name  varchar2(128),                           /* name of grantee */
  schema_name   varchar2(128)                     /* name of granted schema */
)
/

create or replace force view dvsys.ku$_dv_auth_ddl_v
       of dvsys.ku$_dv_auth_ddl_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          d.grantee,
          d.schema
  from    dvsys.dba_dv_ddl_auth d
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_PREP' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_PREP_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Preprocessor
-- granted by AUTHORIZE_PREPROCESSOR.
create or replace type dvsys.ku$_dv_auth_prep_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_name  varchar2(128)                            /* name of grantee */
)
/

create or replace force view dvsys.ku$_dv_auth_prep_v
       of dvsys.ku$_dv_auth_prep_t
  with object identifier (grantee_name) as
  select '0','0',
          p.grantee
  from    dvsys.dba_dv_preprocessor_auth p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_MAINT' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_MAINT_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Maintenance
-- granted by AUTHORIZE_MAINTENANCE_USER.
create or replace type dvsys.ku$_dv_auth_maint_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  oidval        raw(16),                                       /* unique id */
  grantee_name  varchar2(128),                           /* name of grantee */
  schema_name   varchar2(128),                    /* name of granted schema */
  object_name   varchar2(128),                    /* name of granted object */
  object_type   varchar2(128),                    /* type of granted object */
  action        varchar2(128)                             /* name of action */
)
/

create or replace force view dvsys.ku$_dv_auth_maint_v
       of dvsys.ku$_dv_auth_maint_t
  with object identifier (oidval) as
  select '0','0',sys_guid(),
          m.grantee,
          m.schema,
          m.object,
          m.object_type,
          m.action
  from    dvsys.dba_dv_maintenance_auth m
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_DIAG' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_DIAG_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Diagnostic
-- granted by AUTHORIZE_DIAGNOSTIC_ADMIN.
create or replace type dvsys.ku$_dv_auth_diag_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_name  varchar2(128)                            /* name of grantee */
)
/

create or replace force view dvsys.ku$_dv_auth_diag_v
       of dvsys.ku$_dv_auth_diag_t
  with object identifier (grantee_name) as
  select '0','0',
          p.grantee
  from    dvsys.dba_dv_diagnostic_auth p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_INDEX_FUNC' homogeneous type.
-- (xmltag: 'DVPS_DV_INDEX_FUNC_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for index functions 
-- added by ADD_INDEX_FUNCTION.
create or replace type dvsys.ku$_dv_index_func_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  object_name   varchar2(128)                           /* name of function */
)
/

create or replace force view dvsys.ku$_dv_index_func_v
       of dvsys.ku$_dv_index_func_t
  with object identifier (object_name) as
  select '0','0',
          p.object_name
  from    dvsys.dba_dv_index_function p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_DBCAPTURE' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_DBCAPTURE_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Workload_Capture
-- granted by AUTHORIZE_DBCAPTURE.
create or replace type dvsys.ku$_dv_auth_dbcapture_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_name  varchar2(128)                            /* name of grantee */
)
/

create or replace force view dvsys.ku$_dv_auth_dbcapture_v
       of dvsys.ku$_dv_auth_dbcapture_t
  with object identifier (grantee_name) as
  select '0','0',
          p.grantee
  from    dvsys.dba_dv_dbcapture_auth p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_AUTH_DBREPLAY' homogeneous type.
-- (xmltag: 'DVPS_DV_AUTH_DBREPLAY_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault Authorization for Workload_Replay
-- granted by AUTHORIZE_DBREPLAY.
create or replace type dvsys.ku$_dv_auth_dbreplay_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_name  varchar2(128)                            /* name of grantee */
)
/

create or replace force view dvsys.ku$_dv_auth_dbreplay_v
       of dvsys.ku$_dv_auth_dbreplay_t
  with object identifier (grantee_name) as
  select '0','0',
          p.grantee
  from    dvsys.dba_dv_dbreplay_auth p
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_ORADEBUG' homogeneous type.
-- (xmltag: 'DVPS_DV_ORADEBUG_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault controlling ORADEBUG
-- granted by ENABLE_ORADEBUG.
create or replace type dvsys.ku$_dv_oradebug_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  state         varchar2(128)                             /* ORADEBUG state */
)
/

create or replace force view dvsys.ku$_dv_oradebug_v
       of dvsys.ku$_dv_oradebug_t
  with object identifier (state) as
  select '0','0',
          o.state
  from    dvsys.dba_dv_oradebug o
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_DV_ACCTS' homogeneous type.
-- (xmltag: 'DVPS_DV_ACCTS_T', XSLT: rdbms/xml/xsl/kudvauth.xsl),
-- representing Database Vault controlling DVSYS/DVF Accounts
-- granted by ENABLE_DV_DICTIONARY_ACCTS.
create or replace type dvsys.ku$_dv_accts_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  state         varchar2(128)                   /* DVSYS/DVF Accounts state */
)
/

create or replace force view dvsys.ku$_dv_accts_v
       of dvsys.ku$_dv_accts_t
  with object identifier (state) as
  select '0','0',
          a.state
  from    dvsys.dba_dv_dictionary_accts a
  where   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- Bug 15988264: Create dba_dv_status view
create or replace view dvsys.dba_dv_status as
select 'DV_CONFIGURE_STATUS' as name,
       DECODE(status, '1', 'TRUE', 'FALSE') as status
from dvsys.config$
union
select 'DV_ENABLE_STATUS' AS name, value AS status
from sys.v_$option
where parameter = 'Oracle Database Vault'
/

-- This SYS view is necessary to allow users with SELECT ANY DICTIONARY to 
-- query DV status.
create or replace view sys.dba_dv_status as
select * from dvsys.dba_dv_status
with read only
/

exec sys.CDBView.create_cdbview(false, 'SYS', 'DBA_DV_STATUS', 'CDB_DV_STATUS');

show errors;

-- the following tables are for internal use by dbms_macadm.add_nls_data() procedure only.
-- they help in the error free loading of information from the *.dlf xml files into the 
-- database after which the data is merged with the original *_t$ tables.
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.realm_t$_temp as (select * from dvsys.realm_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.code_t$_temp as (select * from dvsys.code_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.factor_t$_temp as (select * from dvsys.factor_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.factor_type_t$_temp as (select * from dvsys.factor_type_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.rule_t$_temp as (select * from dvsys.rule_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.rule_set_t$_temp as (select * from dvsys.rule_set_t$ where 1=2)';
  EXCEPTION
    when others then 
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

  BEGIN
    EXECUTE IMMEDIATE 'create table dvsys.policy_t$_temp as (select * from dvsys.policy_t$ where 1=2)';
  EXCEPTION
    when others then
    if sqlcode in (-955) then  NULL;-- ignore name already used error
    else raise;
    end if;
  END;

END;
/

-- Proj 67579: Add varray type for recording PL/SQL unit names
BEGIN
EXECUTE IMMEDIATE 'create or replace type dvsys.plsql_stack_array force 
                   as varray(1024) of varchar2(500)';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if table doesnt exist
    IF SQLCODE IN (-22866) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
create or replace public synonym plsql_stack_array for dvsys.plsql_stack_array;

-- Proj 67579: Add nested table type for recording IDs of violated DV objects
BEGIN
EXECUTE IMMEDIATE 'create or replace type dvsys.simulation_ids force
                   as table of number';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if table doesnt exist
    IF SQLCODE IN (-22866) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
create or replace public synonym simulation_ids for dvsys.simulation_ids;

-- Proj 67579: Add nested table type for displaying names of 
-- violated DV objects.
BEGIN
EXECUTE IMMEDIATE 'create or replace type dvsys.dv_obj_name force
                   as table of varchar2(128)';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if table doesnt exist
    IF SQLCODE IN (-22866) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
create or replace public synonym dv_obj_name for dvsys.dv_obj_name;

-- Proj 46812: support TRAINING mode
-- Bug 22840314: Rename TRAINING_LOG$ to SIMULATION_LOG$
BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE DVSYS.SIMULATION_LOG$
(
ID# NUMBER NOT NULL,
USERNAME VARCHAR2 (128) NOT NULL,
ACTION NUMBER NOT NULL,
VIOLATION_TYPE NUMBER NOT NULL,
REALM_ID NUMBER,
COMMAND_RULE_ID NUMBER,
RULE_SET_ID NUMBER,
OBJECT_OWNER VARCHAR2 (128),
OBJECT_NAME VARCHAR2 (128),
OBJECT_TYPE VARCHAR2 (128),
RETURNCODE NUMBER NOT NULL,
SQLTEXT VARCHAR2(4000),
FACTOR_CONTEXT VARCHAR2(4000),
TIMESTAMP TIMESTAMP(6) WITH TIME ZONE,
AUTHENTICATION_METHOD VARCHAR2(20),
CLIENT_IP VARCHAR2(45),
DB_DOMAIN VARCHAR2(128),
DATABASE_HOSTNAME VARCHAR2(128),
DATABASE_INSTANCE VARCHAR2(5),
DATABASE_IP VARCHAR2(45),
DATABASE_NAME VARCHAR2(128),
DOMAIN VARCHAR2(4000),
ENTERPRISE_IDENTITY VARCHAR2(1024),
IDENTIFICATION_TYPE VARCHAR2(14),
LANG VARCHAR2(10),
LANGUAGE VARCHAR2(100),
MACHINE VARCHAR2(64),
NETWORK_PROTOCOL VARCHAR2(4),
PROXY_ENTERPRISE_IDENTITY VARCHAR2(1024),
PROXY_USER VARCHAR2(128),
SESSION_USER VARCHAR2(128),
DV$_DBLINK_INFO VARCHAR2(128),
DV$_MODULE VARCHAR2(64),
DV$_CLIENT_IDENTIFIER VARCHAR2(64),
REALM_ID_LIST DVSYS.SIMULATION_IDS,
COMMAND_RULE_ID_LIST DVSYS.SIMULATION_IDS,
RULE_SET_ID_LIST DVSYS.SIMULATION_IDS,
PL_SQL_STACK dvsys.plsql_stack_array
)
NESTED TABLE realm_id_list STORE AS realm_id_tab,
NESTED TABLE command_rule_id_list store as command_rule_id_tab,
NESTED TABLE rule_set_id_list store as rule_set_id_tab '
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-- Proj 67579: Add function to return realm_type for a given nested table
-- of violated DV objects
CREATE OR REPLACE function dvsys.dv_id_to_type (A in dvsys.simulation_ids)
return VARCHAR2 as
i         integer := 0;
rlm_type  VARCHAR2(9) := NULL;
begin
  IF (A.count > 0) THEN
    SELECT realm_type INTO rlm_type FROM dba_dv_realm
    WHERE id# = A(1);
  END IF;
  RETURN rlm_type;
end;
/

-- Proj 67579: Add function to return object names for a given nested table
-- of violated DV objects
CREATE OR REPLACE function dvsys.dv_id_to_name (A   in dvsys.simulation_ids,
                                                dv_obj_type in pls_integer)
return dvsys.dv_obj_name as
name_list dv_obj_name := dv_obj_name();
i         integer := 0;
dv_name   varchar2(128);
stmt      varchar2(50);
begin
  IF (A.count > 0) THEN

    -- Set Execute Statement
    IF (dv_obj_type = 1) THEN -- Realm
      stmt := 'SELECT name FROM dvsys.dv$realm where id# = :1';
    ELSIF (dv_obj_type = 2) THEN -- Rule Set
      stmt := 'SELECT name FROM dvsys.dv$rule_set where id# = :1';
    ELSE
      raise_application_error(-20000,
                              'invalid input value for parameter dv_obj_type');
    END IF;

    FOR i in 1..A.count LOOP
      name_list.extend;
      EXECUTE IMMEDIATE stmt INTO dv_name USING IN A(i);
      name_list(i) := dv_name;
    END LOOP;
  END IF;
  RETURN name_list;
end;
/

-- Proj 67579: Add function to convert PL/SQL unit name varray
-- to concatenated string clob.
CREATE OR REPLACE FUNCTION dvsys.stack_varray_to_clob(va IN dvsys.plsql_stack_array)
RETURN CLOB IS
cl      CLOB;
BEGIN
  IF (va.count = 0) THEN
    RETURN NULL;
  END IF;
  
  FOR i in 1..va.count LOOP
    IF i = 1 THEN
      cl := cl || va(i);
    ELSE
      cl := cl || ' <= ' || va(i);
    END IF;
  END LOOP;

  RETURN cl;
END;
/

CREATE OR REPLACE VIEW DVSYS.DBA_DV_SIMULATION_LOG
(
  id,
  username,
  command,
  violation_type,
  realm_name,
  realm_type,
  object_owner,
  object_name,
  object_type,
  rule_set_name,
  returncode,
  sqltext,
  authentication_method,
  client_ip,
  db_domain,
  database_hostname,
  database_instance,
  database_ip,
  database_name,
  domain,
  enterprise_identity,
  identification_type,
  lang,
  language,
  machine,
  network_protocol,
  proxy_enterprise_identity,
  proxy_user,
  session_user,
  dv$_dblink_info,
  dv$_module,
  dv$_client_identifier,
  factor_context,
  timestamp,
  pl_sql_stack
)
AS SELECT
  tl.id#,
  tl.username,
  c1.code,
  c2.value,
  dvsys.dv_id_to_name(tl.realm_id_list, 1),
  substr(dvsys.dv_id_to_type(tl.realm_id_list), 0, 9),
  tl.object_owner,
  tl.object_name,
  tl.object_type,
  dvsys.dv_id_to_name(tl.rule_set_id_list, 2),
  tl.returncode,
  tl.sqltext,
  tl.authentication_method,
  tl.client_ip,
  tl.db_domain,
  tl.database_hostname,
  tl.database_instance,
  tl.database_ip,
  tl.database_name,
  tl.domain,
  tl.enterprise_identity,
  tl.identification_type,
  tl.lang,
  tl.language,
  tl.machine,
  tl.network_protocol,
  tl.proxy_enterprise_identity,
  tl.proxy_user,
  tl.session_user,
  tl.dv$_dblink_info,
  tl.dv$_module,
  tl.dv$_client_identifier,
  tl.factor_context,
  tl.timestamp,
  dvsys.stack_varray_to_clob(tl.pl_sql_stack) 
  FROM DVSYS.SIMULATION_LOG$ tl, dvsys.dv$code c1, dvsys.dv$code c2
  WHERE c1.id# = tl.action and c1.code_group = 'SQL_CMDS' and
        c2.code = TO_CHAR(tl.violation_type) and
        c2.code_group = 'SIMULATION_VIOLATION'
/

BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."TRAINING_LOG$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql

