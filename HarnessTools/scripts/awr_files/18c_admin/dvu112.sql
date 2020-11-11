Rem
Rem $Header: rdbms/admin/dvu112.sql /main/56 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dvu112.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvu112.sql - DV Upgrade Script from 11.2.0.1 to current version 
Rem
Rem    DESCRIPTION
Rem      Upgrade Database Vault in Oracle 11.2.0.1 to current version
Rem
Rem    NOTES
Rem      This file is currently used by dvpatch.sql for patchset from 11.2.0.1 
Rem      to 11.2.0.2. After the patchset is released, this file will be used 
Rem      as upgrade script.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dvu112.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dvu112.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dvdbmig.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    yanchuan    08/18/15 - Bug 21451692: move removing ODD realm to dvu121
Rem    namoham     06/02/15 - Bug 20216779: remove catmacc, catmacd statements
Rem    namoham     05/28/15 - Bug 21133991: remove ku$_* type changes
Rem    namoham     05/13/15 - Bug 20518449: fix DVSYS.DV_AUTH$.GRANTEE length
Rem    msoudaga    02/23/15 - Bug 16028065: Removal of DELETE_CATALOG_ROLE
Rem    kaizhuan    01/23/15 - Bug20394885: Add CHANGE PASSWORD back to 
Rem                           code_t$ table
Rem    youyang     05/06/13 - bug16765611:add exception block for insert
Rem                           statements
Rem    kaizhuan    03/12/13 - Bug 16232283: run dvu121 after upgrade to 12g
Rem    sanbhara    02/19/13 - Bug 16291881 - updating dvlang to use bind
Rem                           variables.
Rem    youyang     10/12/12 - Bug14757586: add support for alter session
Rem    sanbhara    09/24/12 - Bug 14642504 - cleaning up realm_object$
Rem                           metadata.
Rem    jibyun      09/25/12 - Bug 14663267: enabled in rule_set_rule$ should
Rem                           not contain NULL
Rem    yanchuan    08/28/12 - bug 14456083: dictionary changes to provide
Rem                           DV protection support for transportable
Rem                           Datapump operations
Rem    youyang     08/20/12 - bug14462640:drop package DVSYS.dbms_macsec_events
Rem    kaizhuan    08/16/12 - Bug 13689262: Add command rule support for 
Rem                           create/alter/drop pluggable database SQL commands
Rem    kaizhuan    07/12/12 - Bug 8420170: delete SQL commands and DB object
Rem                           types which DV does not support from code$ table
Rem                           and code_t$ table
Rem    sanbhara    07/19/12 - Bug 14306557 - adding dba_dv_patch_admin_audit
Rem                           view.
Rem    sanbhara    07/27/12 - LRG 7133228 - changing insert statement into
Rem                           realm_object$ so as not to insert duplicate
Rem                           recordwhen upgrading from betaTwo to 12.1 or when
Rem                           rerunning upgrade script.
Rem    jibyun      05/01/12 - Bug 14015928: grant EXECUTE on dbms_macutl to
Rem                           DV_ADMIN, instead of PUBLIC
Rem    youyang     03/13/12 - bug10088587:add DDL authorization
Rem    jibyun      04/13/12 - Bug 13962309: create DV_AUDIT_CLEANUP_GRANTEES
Rem                           view
Rem    jibyun      03/12/12 - Bug 13728213: add disable_database_vault_accts
Rem                           and enable_database_vault_accts
Rem    jibyun      03/15/12 - Bug 5918695: introduce DV_AUDIT_CLEANUP role
Rem    sanbhara    02/28/12 - Bug 13699578 - add calls to add_nls_data for each
Rem                           language.
Rem    youyang     01/07/12 - add proxy user authorization auditing code
Rem    sanbhara    02/15/12 - Bug 13643954 - adding new audit codes for Command
Rem                           Rule violations.
Rem    jibyun      01/25/12 - Bug 13618172: add additional outer join to
Rem                           dv$realm_auth and dba_dv_realm_auth views
Rem    srtata      12/28/11 - bug 13533383: access to DBA_OLS_STATUS
Rem    kaizhuan    12/06/11 - Bug 10253750: Remove objects SYSMAN, 
Rem                           MGMT_VIEW, MGMT_USER 
Rem                           from the defautl EM realm
Rem    youyang     11/17/11 - lrg6549710
Rem    sanbhara    11/16/11 - Bug 13063727 fix.
Rem    jibyun      10/18/11 - Bug 13109138: ALTER TABLE on DVSYS for long
Rem                           identifier support
Rem    youyang     09/28/11 - fix lrg 5946195
Rem    savallu     09/15/11 - p#(autodop_31271): Add optimizer_processing_rate
Rem                           role to Database Vault realm
Rem    srtata      08/29/11 - rename lbac$pol to ols$pol
Rem    jibyun      07/27/11 - Bug 7118789: insert the ORADEBUG row to
Rem                           DVSYS.DV_AUTH
Rem    sanbhara    07/28/11 - Project 24121 - grants to dvsys to exec
Rem                           dbms_system and create and drop directory so
Rem                           dbms_macadm.add_nls_data works.
Rem    sanbhara    07/25/11 - Project 24123 - add columns grantee and 
Rem                           enabled_status to dvsys.audit_trail$ and add new
Rem                           rows to dvsys.code$ and dvsys.code_t$.
Rem    sanbhara    07/12/11 - Project 24121 - migrating objects from ODD realm
Rem                           to new realms in 12g and deleting ODD realm.
Rem    srtata      06/28/11 - OLS rearch recreate views with new schema
Rem    youyang     06/14/11 - remove sync_rules
Rem    youyang     04/26/11 - name to id conversion
Rem    youyang     04/26/11 - add static realm
Rem    jheng       06/02/11 - bug 12619283
Rem    youyang     05/17/11 - fix bug 12395489
Rem    sanbhara    05/09/11 - Project 24121 - add DV grants to PUBLIC.
Rem    jibyun      04/13/11 - Bug 12356827: Add DV_GOLDENGATE_REDO_ACCESS role
Rem                           to control Golden Gate OCI API for redo access
Rem    youyang     07/20/10 - mandatory realm
Rem    jibyun      02/18/11 - Bug 11662436: Add DV_XSTREAM_ADMIN role for 
Rem                           XSTREAM capture under Database Vault
Rem    jibyun      02/10/11 - Bug 11662436: Create DV_GOLDENGATE_ADMIN role for
Rem                           Golden Gate Extract under Database Vault
Rem    sanbhara    02/09/11 - Bug Fix 10225918.
Rem    dvekaria    01/14/11 - Bug 9068994.
Rem    jheng       01/02/11 - fix bug 8501924
Rem    jheng       12/04/10 - add dba_dv_datapump_auth view
Rem    youyang     07/19/10 - change definition of dba_dv_user_privs and
Rem                           dba_dv_user_privs_all
Rem    sanbhara    07/19/10 - Bug 9871112
Rem    vigaur      06/22/10 - Create file
Rem    vigaur      06/22/10 - Created
Rem

-- Alter DVSYS tables for long identifier support
alter table DVSYS."DOCUMENT$" modify "DOC_REVISION" VARCHAR2(128);
alter table DVSYS."DOCUMENT$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."DOCUMENT$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."MAC_POLICY$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."MAC_POLICY$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."CODE$" modify "CODE_GROUP" VARCHAR2(128);
alter table DVSYS."CODE$" modify "CODE" VARCHAR2(128);
alter table DVSYS."CODE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."CODE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."MAC_POLICY_FACTOR$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."MAC_POLICY_FACTOR$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR$" modify "NAME" VARCHAR2(128);
alter table DVSYS."FACTOR$" modify "NAMESPACE" VARCHAR2(128);
alter table DVSYS."FACTOR$" modify "NAMESPACE_ATTRIBUTE" VARCHAR2(128);
alter table DVSYS."FACTOR$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_SCOPE$" modify "GRANTEE" VARCHAR2(128);
alter table DVSYS."FACTOR_SCOPE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_SCOPE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_TYPE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_TYPE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_TYPE_T$" modify "NAME" VARCHAR2(128);
alter table DVSYS."COMMAND_RULE$" modify "OBJECT_OWNER" VARCHAR2(128);
alter table DVSYS."COMMAND_RULE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."COMMAND_RULE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_LINK$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."FACTOR_LINK$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."ROLE$" modify "ROLE" VARCHAR2(128);
alter table DVSYS."ROLE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."ROLE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."IDENTITY$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."IDENTITY$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."IDENTITY_MAP$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."IDENTITY_MAP$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."RULE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."RULE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_T$" modify "NAME" VARCHAR2(128);
alter table DVSYS."POLICY_LABEL$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."POLICY_LABEL$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_SET_RULE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_SET_RULE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_SET$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_SET$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."RULE_SET_T$" modify "NAME" VARCHAR2(128);
alter table DVSYS."REALM_OBJECT$" modify "OWNER" VARCHAR2(128);
alter table DVSYS."REALM_OBJECT$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_OBJECT$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_AUTH$" modify "GRANTEE" VARCHAR2(128);
alter table DVSYS."REALM_AUTH$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_AUTH$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_COMMAND_RULE$" modify "OBJECT_OWNER" VARCHAR2(128);
alter table DVSYS."REALM_COMMAND_RULE$" modify "GRANTEE" VARCHAR2(128);
alter table DVSYS."REALM_COMMAND_RULE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_COMMAND_RULE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."REALM$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."REALM$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."REALM_T$" modify "NAME" VARCHAR2(128);
alter table DVSYS."MONITOR_RULE$" modify "CREATED_BY" VARCHAR2(128);
alter table DVSYS."MONITOR_RULE$" modify "UPDATED_BY" VARCHAR2(128);
alter table DVSYS."MONITOR_RULE_T$" modify "NAME" VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify USERNAME VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify OWNER VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify RULE_SET_NAME VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify RULE_NAME VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify CREATED_BY VARCHAR2(128);
alter table DVSYS."AUDIT_TRAIL$" modify UPDATED_BY VARCHAR2(128);
alter table DVSYS."DV_AUTH$" modify "GRANTEE" VARCHAR2(128);
alter table DVSYS."DV_AUTH$" modify "OBJECT_OWNER" VARCHAR2(128);

--
-- Reload all the packages, functions and procedures from previous release
--

ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
DROP CONSTRAINT "IDENTITY_MAP_UK1"';
  EXCEPTION 
    WHEN OTHERS THEN
     IF SQLCODE IN (-02443) THEN NULL; -- not exist
     ELSE RAISE;
     END IF;    
END;
/

-- bug 7137958: extract datapump auth from ruleset and put it into 
-- DVSYS.DV_AUTH$ table; delete datapump rules and ruleset
Declare
  cursor cur is  select r1.name, r.rule_expr, r.id#
                 from dvsys.rule$ r, dvsys.rule_t$ r1,
                      dvsys.rule_set_rule$ rs,
                      dvsys.rule_set_t$ rt
                 where rt.name = 'Allow Oracle Data Pump Operation' and
                       rs.RULE_SET_ID# = 8 and rt.id#=rs.RULE_SET_ID# and
                       rs.rule_id# = r.id# and r1.id# = r.id#;
  l_parse_rule  VARCHAR2(4000);
  l_grantee     VARCHAR2(30);
  l_schema      VARCHAR2(30) := '%';
  l_object      VARCHAR2(30) := '%';
  l_start       number;
  l_end         number;
BEGIN
  FOR ee IN cur LOOP
    delete from dvsys.rule_set_rule$ 
    where rule_set_id#=8 and rule_id#=ee.id#;

    IF ee.name != 'False' THEN
      l_schema := '%';
      l_object := '%';

      l_parse_rule := TRIM(ee.rule_expr);
      l_start := INSTR(l_parse_rule, 'dv_login_user = ');

      IF l_start != 0 THEN
        -- extract grantee
        l_start := l_start + length('dv_login_user = ');
        l_end := INSTR(l_parse_rule, ')', l_start);
        IF l_end = 0 THEN
          l_end := length(l_parse_rule)+1;
        END IF;
        l_grantee := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-2);
        --- extract schema
        l_start := INSTR(l_parse_rule, 'dv_dict_obj_owner = ');
        IF l_start != 0 THEN
          l_start := l_start + length('dv_dict_obj_owner = ');
          l_end := INSTR(l_parse_rule, ')', l_start, 1)-1;
          l_schema := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-1);

          -- extract object name
          l_start := INSTR(l_parse_rule, 'dv_dict_obj_name = ');
          IF l_start!= 0 THEN
            l_start := l_start + length('dv_dict_obj_name = ');
            l_end := INSTR(l_parse_rule, ')', l_start, 1)-1;
            l_object := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-1);
          END IF; --end of extracting object name
        END IF; -- end of extracing schema 
      END IF; -- end of extracing grantee

      INSERT INTO DVSYS.DV_AUTH$(grant_type, grantee, object_owner,                                  object_name, object_type)
      VALUES ('DATAPUMP', l_grantee, l_schema, l_object, NULL);

      delete from dvsys.rule$ where id#=ee.id#;
      delete from dvsys.rule_t$ where id#=ee.id#;
    END IF; -- end of parsing no FALSE rule
  END LOOP;
  delete from dvsys.rule_set_rule$ where rule_set_id#=8;
  delete from dvsys.rule_set$ where id#=8;
  delete from dvsys.rule_set_t$ where id#=8;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

--delete job rules and ruleset
Declare
  cursor cur is  select r.name, r.id#
                 from dvsys.rule_t$ r,
                      dvsys.rule_set_rule$ rs,
                      dvsys.rule_set_t$ rt
                 where rt.name = 'Allow Scheduler Job' and
                       rs.RULE_SET_ID# = 10 and rt.id#=rs.RULE_SET_ID# and
                       rs.rule_id# = r.id#;
BEGIN
  FOR ee in cur LOOP
    delete from dvsys.rule_set_rule$ 
    where rule_set_id#=10 and rule_id#=ee.id#;
    IF (ee.name != 'False') THEN
      delete from dvsys.rule$ where id#=ee.id#;
      delete from dvsys.rule_t$ where id#=ee.id#;
    END IF;
  END LOOP;
  delete from dvsys.rule_set_rule$ where rule_set_id#=10;
  delete from dvsys.rule_set$ where id#=10;
  delete from dvsys.rule_set_t$ where id#=10;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

-- update dv_auth$ null object name to '%'
BEGIN
UPDATE DVSYS.DV_AUTH$ SET object_name='%' where grant_type='JOB';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

-- Add name to id changes on tables.
-- Reserved KZDALLOBJSCH_DV(2147483636 represents all user/object names '%'
variable all_schema number;
begin
  select 2147483636 into :all_schema from dual;
end;
/

--add two more columns in dv_auth$
ALTER TABLE DVSYS.DV_AUTH$ ADD GRANTEE_ID NUMBER;
ALTER TABLE DVSYS.DV_AUTH$ ADD OBJECT_OWNER_ID NUMBER;

--set user IDs based on user name
UPDATE DVSYS.DV_AUTH$ da SET da.GRANTEE_ID = (SELECT user# FROM sys.user$ where name = da.grantee);
UPDATE DVSYS.DV_AUTH$ da SET da.OBJECT_OWNER_ID = (SELECT user# FROM sys.user$ where name = da.object_owner) WHERE da.object_owner IS NOT NULL and da.object_owner != '%';
UPDATE DVSYS.DV_AUTH$ da SET OBJECT_OWNER_ID = :all_schema WHERE da.object_owner is NULL or da.object_owner = '%';
UPDATE DVSYS.DV_AUTH$ SET OBJECT_TYPE='%' WHERE OBJECT_TYPE IS NULL;

-- Remove NULL constraint for column grantee
ALTER TABLE DVSYS.DV_AUTH$ DROP COLUMN GRANTEE;
ALTER TABLE DVSYS.DV_AUTH$ ADD GRANTEE VARCHAR2(128); 

-- Bug 8706788 - Remove WKSYS and WKUSER from ODD
-- Drop these users from the realm authorization list
delete from DVSYS.realm_auth$ where grantee = 'WKSYS' and realm_id#=1;
delete from DVSYS.realm_auth$ where grantee = 'WKUSER' and realm_id#=1;

-- Bug 6503742. Update database IP factor to use the new SERVER_HOST_IP sys_context
update DVSYS.FACTOR$ SET GET_EXPR = 'UPPER(SYS_CONTEXT(''USERENV'',''SERVER_HOST_IP''))' where name='Database_IP';

-- add realm type
alter table dvsys.realm$ add REALM_TYPE NUMBER;

update dvsys.realm$ set realm_type = 0;

-- Bug 9871112. Update the case sensitive factors to not use UPPER

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''ENTERPRISE_IDENTITY'')' where name='Enterprise_Identity';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''PROXY_ENTERPRISE_IDENTITY'')'  where name='Proxy_Enterprise_Identity';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''SESSION_USER'')' where name='Session_User';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''PROXY_USER'')' where name='Proxy_User';

-- Bug 9068994. Handle upgrade for Drop User.
BEGIN
UPDATE DVSYS.RULE_SET$ SET EVAL_OPTIONS = 1 WHERE ID# =3;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

--LRG 7133228 - moving this alter table to before the inserts into realm_object$.
alter table dvsys.realm_object$ add OWNER_UID# NUMBER;

-- Add name to id changes on tables.
alter table dvsys.command_rule$ add OBJECT_OWNER_UID# NUMBER;
alter table dvsys.command_rule$ drop constraint COMMAND_RULE$_UK1;

alter table dvsys.realm_object$ drop constraint REALM_OBJECT$_UK1;

alter table dvsys.realm_auth$ add GRANTEE_UID# NUMBER;
alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1;

update dvsys.command_rule$ a set object_owner_uid# = (select user# from sys.user$ where name= a.object_owner);
update dvsys.command_rule$ set object_owner_uid# = :all_schema where object_owner = '%' or object_owner is NULL; 
delete from dvsys.command_rule$ where object_owner_uid# IS NULL;

update dvsys.realm_object$ a set owner_uid# = (select user# from sys.user$ where name= a.owner);
update dvsys.realm_object$ set owner_uid# = :all_schema where owner = '%' or owner is NULL;
delete from dvsys.realm_object$ where owner_uid# IS NULL;

update dvsys.realm_auth$ a set grantee_uid# = (select user# from sys.user$ where name= a.grantee);
update dvsys.realm_auth$ set grantee_uid# = :all_schema where grantee = '%' or grantee is NULL;
delete from dvsys.realm_auth$ where grantee_uid# IS NULL;

-- End of name to id change
drop function dvsys.is_rls_authorized_by_realm;

update dvsys.rule$ set rule_expr = 'dvsys.dv_login_user = dvsys.dv_dict_obj_name' where id#=10;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ACCTMGR'', ''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=3;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=4;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ADMIN'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=5;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_OWNER'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=6;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''LBAC_DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=7;
update dvsys.rule$ set rule_expr = '(DVSYS.DBMS_MACUTL.USER_HAS_SYSTEM_PRIV_VARCHAR(''EXEMPT ACCESS POLICY'',''"''||dvsys.dv_login_user||''"'') = ''N'') OR USER = ''SYS''' where id#=9;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_ALTER_USER_ALLOW_VARCHAR(''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=14;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_DROP_USER_ALLOW_VARCHAR(''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=22;


--Project 24121 - here modifying the grants to DVSYS as necessary - needs to be before loading packages 
-- Bug 20216779: removing the grants as catmacs.sql is now run in dvdbmig.sql
-------------------------------------------------------------------------------------------------------
DROP PROCEDURE DVSYS.OLS_INIT_SESSION;

--Project 24121 - add new realms to realm$ table and remove ODD realm.

BEGIN


-- Bug 20216779: the following inserts cannot be removed even though they are 
-- inserted in catmacd as we populated them using user created ODD realm objects.
BEGIN 
INSERT INTO DVSYS.REALM$ (ID#,ENABLED,AUDIT_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(8,'Y',1,1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;

BEGIN 
INSERT INTO DVSYS.REALM$ (ID#,ENABLED,AUDIT_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(9,'Y',1,1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;

BEGIN 
INSERT INTO DVSYS.REALM$ (ID#,ENABLED,AUDIT_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(10,'Y',1,1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;

END;
/

--Project 24121 - add users other than those authorised by default in ODD realm to the 3 new realms. 

DECLARE
  auth_row_id NUMBER;
BEGIN
  FOR auth_row in (select * from DVSYS.realm_auth$ where realm_id# = 1 AND id# >=5000) LOOP
  
    BEGIN
      DELETE from DVSYS.realm_auth$ where id# = auth_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    

    BEGIN
      SELECT DVSYS.realm_auth$_seq.NEXTVAL INTO auth_row_id FROM dual;
      INSERT INTO DVSYS.realm_auth$(id#,realm_id#,grantee,grantee_uid#,auth_rule_set_id#,auth_options,version,created_by,create_date,updated_by,update_date) 
      VALUES (auth_row_id,8,auth_row.grantee,auth_row.grantee_uid#,NULL,1,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      SELECT DVSYS.realm_auth$_seq.NEXTVAL INTO auth_row_id FROM dual;
      INSERT INTO DVSYS.realm_auth$(id#,realm_id#,grantee,grantee_uid#,auth_rule_set_id#,auth_options,version,created_by,create_date,updated_by,update_date) 
      VALUES (auth_row_id,9,auth_row.grantee,auth_row.grantee_uid#,NULL,1,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      SELECT DVSYS.realm_auth$_seq.NEXTVAL INTO auth_row_id FROM dual;
      INSERT INTO DVSYS.realm_auth$(id#,realm_id#,grantee,grantee_uid#,auth_rule_set_id#,auth_options,version,created_by,create_date,updated_by,update_date) 
      VALUES (auth_row_id,10,auth_row.grantee,auth_row.grantee_uid#,NULL,1,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      DELETE FROM DVSYS.realm_auth$ WHERE id# = auth_row.id#;
    END;

  END LOOP;
END;
/

--Project 24121 - add objects other than those protected by default in ODD realm to the 3 new realms. 

DECLARE
  realm_obj_row_id NUMBER;
BEGIN
  FOR realm_obj_row in (select * from DVSYS.realm_object$ where realm_id# = 1 AND id# >=5000) LOOP

    BEGIN
      DELETE from DVSYS.realm_object$ where id# = realm_obj_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    

    BEGIN
      SELECT DVSYS.realm_object$_seq.NEXTVAL INTO realm_obj_row_id FROM dual;
      INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
      VALUES(realm_obj_row_id,8,realm_obj_row.owner,realm_obj_row.owner_uid#,realm_obj_row.object_name,realm_obj_row.object_type,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      SELECT DVSYS.realm_object$_seq.NEXTVAL INTO realm_obj_row_id FROM dual;
      INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
      VALUES(realm_obj_row_id,9,realm_obj_row.owner,realm_obj_row.owner_uid#,realm_obj_row.object_name,realm_obj_row.object_type,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      SELECT DVSYS.realm_object$_seq.NEXTVAL INTO realm_obj_row_id FROM dual;
      INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
      VALUES(realm_obj_row_id,10,realm_obj_row.owner,realm_obj_row.owner_uid#,realm_obj_row.object_name,realm_obj_row.object_type,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;

    BEGIN
      DELETE FROM DVSYS.realm_object$ WHERE id# = realm_obj_row.id#;
    END;

  END LOOP;
END;
/

--Project 24121 - add default objects to their respective new realms and delete them from the ODD realm.

variable parent_realm_id number;
begin
   select 1 into :parent_realm_id from dual;
end;
/

--Use % as owner of roles since roles don't have owner.
variable object_owner_none VARCHAR2(30);
begin
   :object_owner_none := '%';
end;
/

-- Use 2147483636 as uid for '%'.
variable all_schema number;
begin
  select 2147483636 into :all_schema from dual;
end;
/

-- Get sys and system user ID.
variable sys_schema number;
begin 
  select user# into :sys_schema from sys.user$ where name = 'SYS';
end;
/

variable system_schema number;
begin
  select user# into :system_schema from sys.user$ where name = 'SYSTEM';
end;
/

BEGIN
FOR realm_obj_row in (select * from DVSYS.realm_object$ where realm_id# = 1 AND id# <5000) LOOP
    BEGIN
      DELETE from DVSYS.realm_object$ where id# = realm_obj_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
END LOOP;
END;
/


--Project 24121 - add authorizations to default users to their respective new realms and delete them from the ODD realm.

BEGIN
DELETE FROM DVSYS.realm_auth$ where id# = 1;
   EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

 

--Project 24121 - here removing dependency on DV_PUBLIC by granting to PUBLIC
-----------------------------------------------------------------------------
-- here removing dependency on DV_PUBLIC by granting to PUBLIC
-- Bug 20216779: remove the grants as catmacg.sql is run in dvdbmig.sql
-- Revoke EXECUTE on dbms_macutl from dv_public.
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dvsys.dbms_macutl FROM dv_public';
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE IN (-1927) THEN NULL; -- already revoked.
    ELSE RAISE;
    END IF;
END;
/

-----------------------------------------------------------------------------
-- create the new enforce$ table and insert a 1 into config$.

--DV config status - during upgrade since old catmac has been run, it is 
--expected that DV_OWNER and DV_ACCTMGR roles have been granted to chosen
--users hence the status must be configured.

DECLARE
NUM NUMBER;

BEGIN
SELECT STATUS INTO NUM FROM DVSYS.CONFIG$;
IF NUM = 0 THEN 
EXECUTE IMMEDIATE 'UPDATE DVSYS.CONFIG$ SET STATUS=1';
 END IF;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/



-- add audit calls for new OLS schema
-- don't need to add audit stmts for renamed tables as audit opts are preserved
AUDIT GRANT ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT AUDIT ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT GRANT ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT RENAME ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER SUCCESSFUL;
AUDIT RENAME ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT EXECUTE ON LBACSYS.SA_LABEL_ADMIN BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT SELECT ON LBACSYS.OLS$LAB_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT SELECT ON LBACSYS.OLS$TAG_SEQUENCE BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT UPDATE ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT UPDATE ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$LAB BY ACCESS WHENEVER SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT SELECT ON LBACSYS.OLS$LAB BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT UPDATE ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT UPDATE ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$PROG BY ACCESS WHENEVER SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT SELECT ON LBACSYS.OLS$PROG BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT UPDATE ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT UPDATE ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT RENAME ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INSERT ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT INDEX ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT GRANT ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT DELETE ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT COMMENT ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT AUDIT ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$USER BY ACCESS WHENEVER SUCCESSFUL;
AUDIT ALTER ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;
AUDIT SELECT ON LBACSYS.OLS$USER BY ACCESS WHENEVER NOT SUCCESSFUL;



ALTER TABLE dvsys.audit_trail$ add GRANTEE VARCHAR2(128);
ALTER TABLE dvsys.audit_trail$ add ENABLED_STATUS VARCHAR2(1);

-- Remove objects SYSMAN, MGMT_VIEW, MGMT_USER from the default EM realm per 12c's requrement changes

-- Remove schema object SYSMAN
DELETE from DVSYS.realm_object$ where owner='SYSMAN' and realm_id#=7;

-- Remove schema object MGMT_VIEW
DELETE from DVSYS.realm_object$ where owner='MGMT_VIEW' and realm_id#=7;

-- Remove object MGMT_VIEW
DELETE from DVSYS.realm_object$ where object_name='MGMT_VIEW' and realm_id#=7;

-- Remove object MGMT_USER
DELETE from DVSYS.realm_object$ where object_name='MGMT_USER' and realm_id#=7;

-- Remove auth binding to SYSMAN in the EM Realm
DELETE from DVSYS.realm_auth$ where grantee='SYSMAN' and realm_id#=7;

--bug 8420170
alter table dvsys.realm_object$ modify object_type varchar2(32);
alter table dvsys.dv_auth$ modify object_type varchar2(32);

update dvsys.code$ set code='CREATE MATERIALIZED VIEW LOG' where id#=71;
update dvsys.code$ set code='ALTER MATERIALIZED VIEW LOG' where id#=72;
update dvsys.code$ set code='DROP MATERIALIZED VIEW LOG' where id#=73;
update dvsys.code$ set code='CREATE MATERIALIZED VIEW' where id#=74;
update dvsys.code$ set code='ALTER MATERIALIZED VIEW' where id#=75;
update dvsys.code$ set code='DROP MATERIALIZED VIEW' where id#=76;
update dvsys.code$ set id#=212 where id#=301;
delete from dvsys.code$ where id#=302;
update dvsys.code$ set id#=214 where id#=303;
delete from dvsys.code$ where id#=491;
delete from dvsys.code$ where id#=492;
delete from dvsys.code$ where id#=494;
delete from dvsys.code$ where id#=495;
delete from dvsys.code$ where id#=500;
delete from dvsys.code$ where id#=501;
delete from dvsys.code$ where id#=502;
delete from dvsys.code$ where id#=504;
delete from dvsys.code$ where id#=506;
delete from dvsys.code$ where id#=507;
delete from dvsys.code$ where id#=508;
delete from dvsys.code$ where id#=514;
delete from dvsys.code$ where id#=515;
delete from dvsys.code$ where id#=517;
delete from dvsys.code$ where id#=518;
delete from dvsys.code$ where id#=519;
delete from dvsys.code$ where id#=523;
delete from dvsys.code$ where id#=529;
delete from dvsys.code$ where id#=530;
delete from dvsys.code$ where id#=531;
update dvsys.code$ set code='MATERIALIZED VIEW LOG' where id#=532;
delete from dvsys.code$ where id#=534;

delete from dvsys.code_t$ where id#=491;
delete from dvsys.code_t$ where id#=492;
delete from dvsys.code_t$ where id#=494;
delete from dvsys.code_t$ where id#=495;
delete from dvsys.code_t$ where id#=500;
delete from dvsys.code_t$ where id#=501;
delete from dvsys.code_t$ where id#=502;
delete from dvsys.code_t$ where id#=504;
delete from dvsys.code_t$ where id#=506;
delete from dvsys.code_t$ where id#=507;
delete from dvsys.code_t$ where id#=508;
delete from dvsys.code_t$ where id#=514;
delete from dvsys.code_t$ where id#=515;
delete from dvsys.code_t$ where id#=517;
delete from dvsys.code_t$ where id#=518;
delete from dvsys.code_t$ where id#=519;
delete from dvsys.code_t$ where id#=523;
delete from dvsys.code_t$ where id#=529;
delete from dvsys.code_t$ where id#=530;
delete from dvsys.code_t$ where id#=531;
delete from dvsys.code_t$ where id#=534;

--drop package DVSYS.dbms_macsec_events
drop package body DVSYS.dbms_macsec_events;
drop package DVSYS.dbms_macsec_events;

-- Bug 14663267: the enabled column in rule_set_rule$ should not contain NULL
-- or empty string. If such values are found, update them to 'Y', which is 
-- a default value. Also, add NOT NULL constraint to the enabled column.
UPDATE dvsys.rule_set_rule$ SET enabled = 'Y' where enabled IS NULL or enabled = '';
ALTER TABLE dvsys.rule_set_rule$ MODIFY (enabled NOT NULL);

--Bug 14642504
delete from dvsys.realm_object$ where object_name = 'SYS%';
delete from dvsys.realm_object$ where object_name = 'SYSNT%';
delete from dvsys.realm_object$ where object_name = 'AQ%DATAPUMP%';
delete from dvsys.realm_object$ where object_name = 'AUD$' and owner = 'SYSTEM';

-- Call dvu121.sql for upgrade from 12.1.0.1 to the latest version
@@dvu121.sql

commit;
