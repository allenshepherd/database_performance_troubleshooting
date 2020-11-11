Rem
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem    NAME
Rem      catmacdd.sql - Data pump support for Database vault protected schema
Rem
Rem    DESCRIPTION
Rem      Data Pump support for Database Vault Protected Schema.
Rem
Rem      Insert rows into sys.metaview$ to register the real Data Pump types,
Rem      which are created in the DVSYS schema (by the Database Vault
Rem      installation script rdbms/admin/catmacc.sql).
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacdd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacdd.sql
Rem SQL_PHASE: CATMACDD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    qinwu     01/19/17 - proj 70151: support db capture and replay auth
Rem    youyang   02/15/16 - bug22672722:dv support for index functions
Rem    jibyun    11/01/15 - introduce DIAGNOSTIC authorization
Rem    yanchuan  07/27/15 - Bug 21299533: support for Database Vault
Rem                         Authorization
Rem    sanbhara  06/01/15 - Bug 21158282 - adding DVPS_COMMAND_RULE_ALTS.
Rem    kaizhuan  11/11/14 - Project 46812
Rem    jibyun    08/06/14 - Project 46812: support for Database Vault policy
Rem    aketkar   04/29/14 - sql patch metadata seed
Rem    vigaur    06/23/10 - Add set current schema
Rem    jsamuel   10/24/08 - execute in anonymous block
Rem    pknaggs   07/07/08 - bug 6938028: add Factor and Role support for DVPS.
Rem    pknaggs   06/20/08 - bug 6938028: Database Vault Protected Schema.
Rem    pknaggs   06/20/08 - Created
Rem
Rem
Rem

@@?/rdbms/admin/sqlsessstart.sql

ALTER SESSION SET CURRENT_SCHEMA = SYS;

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM',0,0,'ORACLE',1002000200,
  'DVPS_REALM_T',
  'KU$_DV_REALM_T','DVSYS','KU$_DV_REALM_VIEW');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_REALM_MEMBERSHIP_T',
  'KU$_DV_REALM_MEMBER_T','DVSYS','KU$_DV_REALM_MEMBER_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_AUTHORIZATION',0,0,'ORACLE',1002000200,
  'DVPS_REALM_AUTHORIZATION_T',
  'KU$_DV_REALM_AUTH_T','DVSYS','KU$_DV_REALM_AUTH_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_IMPORT_STAGING_REALM_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_STAGING_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_STAGING_REALM_MEMBERSHP_T',
  'KU$_DV_ISRM_T','DVSYS','KU$_DV_ISRM_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DROP_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_DISR_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE',0,0,'ORACLE',1002000200,
  'DVPS_RULE_T',
  'KU$_DV_RULE_T','DVSYS','KU$_DV_RULE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_T',
  'KU$_DV_RULE_SET_T','DVSYS','KU$_DV_RULE_SET_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_MEMBERSHIP_T',
  'KU$_DV_RULE_SET_MEMBER_T','DVSYS','KU$_DV_RULE_SET_MEMBER_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_COMMAND_RULE',0,0,'ORACLE',1002000200,
  'DVPS_COMMAND_RULE_T',
  'KU$_DV_COMMAND_RULE_T','DVSYS','KU$_DV_COMMAND_RULE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_COMMAND_RULE_ALTS',0,0,'ORACLE',1202000000,
  'DVPS_COMMAND_RULE_ALTS_T',
  'KU$_DV_COMM_RULE_ALTS_T','DVSYS','KU$_DV_COMM_RULE_ALTS_V');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_ROLE',0,0,'ORACLE',1002000200,
  'DVPS_ROLE_T',
  'KU$_DV_ROLE_T','DVSYS','KU$_DV_ROLE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_T',
  'KU$_DV_FACTOR_T','DVSYS','KU$_DV_FACTOR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_LINK',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_LINK_T',
  'KU$_DV_FACTOR_LINK_T','DVSYS','KU$_DV_FACTOR_LINK_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_TYPE',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_TYPE_T',
  'KU$_DV_FACTOR_TYPE_T','DVSYS','KU$_DV_FACTOR_TYPE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_T',
  'KU$_DV_IDENTITY_T','DVSYS','KU$_DV_IDENTITY_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY_MAP',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_MAP_T',
  'KU$_DV_IDENTITY_MAP_T','DVSYS','KU$_DV_IDENTITY_MAP_VIEW');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

REM  ===============================================
REM    Data Pump support for Database Vault Policy
REM  ===============================================

REM Registger types with metaview$
REM   DVPS_DV_POLICY             - Database Vault policy
REM   DVPS_DV_POLICY_OBJ_R       - Reamls under Database Vault policy
REM   DVPS_DV_POLICY_OBJ_C       - Command rules under Database Vault policy
REM   DVPS_DV_POLICY_OBJ_C_ALTS  - Command rules under Database Vault policy 
Rem                                (alter system/session command rule)
REM   DVPS_DV_POLICY_OWNER       - Database Vault policy owner

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_POLICY',0,0,'ORACLE',1202000000,
  'DVPS_DV_POLICY_T',
  'KU$_DV_POLICY_T','DVSYS','KU$_DV_POLICY_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_POLICY_OBJ_R',0,0,'ORACLE',1202000000,
  'DVPS_DV_POLICY_OBJ_R_T',
  'KU$_DV_POLICY_OBJ_R_T','DVSYS','KU$_DV_POLICY_OBJ_R_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_POLICY_OBJ_C',0,0,'ORACLE',1202000000,
  'DVPS_DV_POLICY_OBJ_C_T',
  'KU$_DV_POLICY_OBJ_C_T','DVSYS','KU$_DV_POLICY_OBJ_C_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_POLICY_OBJ_C_ALTS',0,0,'ORACLE',1202000000,
  'DVPS_DV_POLICY_OBJ_C_ALTS_T',
  'KU$_DV_POLICY_OBJ_C_ALTS_T','DVSYS','KU$_DV_POLICY_OBJ_C_ALTS_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_POLICY_OWNER',0,0,'ORACLE',1202000000,
  'DVPS_DV_POLICY_OWNER_T',
  'KU$_DV_POLICY_OWNER_T','DVSYS','KU$_DV_POLICY_OWNER_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

REM  ======================================================
REM    END of Data Pump support for Database Vault Policy
REM  ======================================================

REM  ====================================================
REM    Data Pump support for Database Vault Authorization
REM  ====================================================

REM Registger types with metaview$
REM   DVPS_DV_AUTH_DP          - Database Vault authorization for Data Pump
REM   DVPS_DV_AUTH_TTS         - Database Vault authorization for
REM                              transportable Data Pump
REM   DVPS_DV_AUTH_JOB         - Database Vault authorization for Scheduler
REM   DVPS_DV_AUTH_PROXY       - Database Vault authorization for Proxy User
REM   DVPS_DV_AUTH_DDL         - Database Vault authorization for DDL
REM   DVPS_DV_AUTH_PREP        - Database Vault authorization for Preprocessor
REM   DVPS_DV_AUTH_MAINT       - Database Vault authorization for Maintenance
REM   DVPS_DV_ORADEBUG         - Database Vault control for ORADEBUG
REM   DVPS_DV_ACCTS            - Database Vault control for DVSYS/DVF Accounts

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_DP',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_DP_T',
  'KU$_DV_AUTH_DP_T','DVSYS','KU$_DV_AUTH_DP_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_TTS',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_TTS_T',
  'KU$_DV_AUTH_TTS_T','DVSYS','KU$_DV_AUTH_TTS_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_JOB',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_JOB_T',
  'KU$_DV_AUTH_JOB_T','DVSYS','KU$_DV_AUTH_JOB_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_PROXY',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_PROXY_T',
  'KU$_DV_AUTH_PROXY_T','DVSYS','KU$_DV_AUTH_PROXY_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_DDL',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_DDL_T',
  'KU$_DV_AUTH_DDL_T','DVSYS','KU$_DV_AUTH_DDL_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_PREP',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_PREP_T',
  'KU$_DV_AUTH_PREP_T','DVSYS','KU$_DV_AUTH_PREP_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_MAINT',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_MAINT_T',
  'KU$_DV_AUTH_MAINT_T','DVSYS','KU$_DV_AUTH_MAINT_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_DIAG',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_DIAG_T',
  'KU$_DV_AUTH_DIAG_T','DVSYS','KU$_DV_AUTH_DIAG_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_INDEX_FUNC',0,0,'ORACLE',1202000000,
  'DVPS_DV_INDEX_FUNC_T',
  'KU$_DV_INDEX_FUNC_T','DVSYS','KU$_DV_INDEX_FUNC_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_ORADEBUG',0,0,'ORACLE',1202000000,
  'DVPS_DV_ORADEBUG_T',
  'KU$_DV_ORADEBUG_T','DVSYS','KU$_DV_ORADEBUG_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_ACCTS',0,0,'ORACLE',1202000000,
  'DVPS_DV_ACCTS_T',
  'KU$_DV_ACCTS_T','DVSYS','KU$_DV_ACCTS_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_DBCAPTURE',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_DBCAPTURE_T',
  'KU$_DV_AUTH_DBCAPTURE_T','DVSYS','KU$_DV_AUTH_DBCAPTURE_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
 insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DV_AUTH_DBREPLAY',0,0,'ORACLE',1202000000,
  'DVPS_DV_AUTH_DBREPLAY_T',
  'KU$_DV_AUTH_DBREPLAY_T','DVSYS','KU$_DV_AUTH_DBREPLAY_V');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/


REM  ===========================================================
REM    END of Data Pump support for Database Vault Authorization
REM  ===========================================================

@?/rdbms/admin/sqlsessend.sql

