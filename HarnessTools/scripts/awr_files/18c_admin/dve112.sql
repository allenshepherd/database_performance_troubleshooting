Rem
Rem $Header: rdbms/admin/dve112.sql /main/41 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dve112.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dve112.sql - Downgrade DV from current version to 11.1
Rem
Rem    DESCRIPTION
Rem      - This script will be called by cmpdwpth.sql for patch downgrades
Rem      - Also invoked by dve111.sql for version downgrades
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dve112.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dve112.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: DOWNGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dvdwgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    yanchuan    08/18/15 - Bug 21451692: update ID# for
Rem                           Oracle Data Dictionary realm
Rem    jibyun      08/05/15 - Bug 21519712: grant EXECUTE on DVSYS.GET_FACTOR
Rem                           to DVF when downgrading to 11.2
Rem    jibyun      08/04/15 - Bug 21519014: create DV_ADMIN_DIR directory when
Rem                           downgrading to 11.2.0.3 or 11.2.0.4
Rem    msoudaga    01/17/15 - Bug 16028065: Remove role DELETE_CATALOG_ROLE
Rem    kaizhuan    03/12/13 - Bug 16232283: add dve121.sql 
Rem    sanbhara    12/10/12 - LRG 6940078 - reverting back rules using 
Rem                           user_has_role() to not enclose second 
Rem                           parameter in double quotes.
Rem    youyang     10/12/12 - Bug14757586: add support for alter session
Rem    sanbhara    09/24/12 - Bug 14642504 - cleaning up realm_object$
Rem                           metadata.
Rem    yanchuan    08/31/12 - bug 14456083: remove view DVSYS.dba_dv_tts_auth,
Rem                           remove TTS DV auth/unauth code,
Rem                           remove role grants and realm protection for
Rem                           DV_DATAPUMP_NETWORK_LINK
Rem    kaizhuan    08/16/12 - Bug 13689262: Remove command rule support for 
Rem                           create/alter/drop pluggable database SQl commands
Rem    kaizhuan    07/12/12 - Bug 8420170: Add back SQL commands and DB object
Rem                           types back to the code$ table and code_t$ table
Rem    sanbhara    07/19/12 - Bug 14306557 - drop view
Rem                           dba_dv_patch_admin_audit.
Rem    kaizhuan    05/11/12 - Bug 14008196: remove SYSMAN references 
Rem    youyang     03/13/12 - bug10088587:remove ddl authorization code
Rem    jibyun      04/13/12 - Bug 13962309: drop DV_AUDIT_CLEANUP_GRANTEES view
Rem    kaizhuan    04/03/12 - Bug 13887685: fix SQL injection vulnerability 
Rem                           in procedure insert datapump and job auth from 
Rem                           dvsys.dv_auth$ to their rule sets 
Rem    yanchuan    03/30/12 - LRG 6851190: drop dvsys/sys.dv$*_audit,
Rem                           dvsys.dba_dv_proxy_auth views,
Rem                           dvsys.configure_dv procedure
Rem    jibyun      03/12/12 - Bug 13728213: delete the DV_ACCTS row from
Rem                           DVSYS.DV_AUTH and drop dba_dv_dictionary_accts
Rem    sanbhara    03/29/12 - Bug 13333301 - drop package dbms_macdvutl.
Rem    jibyun      03/15/12 - Bug 5918695: drop DV_AUDIT_CLEANUP role
Rem    sanbhara    02/29/12 - Bug 13699578 - truncate the temporary metadata
Rem                           tables *_t$_temp.
Rem    youyang     01/07/12 - remove proxy user authorization auditing code
Rem    sanbhara    02/17/12 - Bug 13643954 - deleting from code$ and code_t$
Rem                           where id# = 664.
Rem    srtata      12/28/11 - bug 13533383: access to DBA_OLS_STATUS
Rem    kaizhuan    12/06/11 - Bug 10253750: Add objects SYSMAN, MGMT_VIEW, 
Rem                           MGMT_USER and the auth assigned to SYSMAN 
Rem                           back to the EM Realm
Rem    sanbhara    11/17/11 - Removing New rows added in 12.1 in code$ and
Rem                           code_t$.
Rem    jibyun      10/18/11 - Bug 13109138: Remove dbms_macadm.sync_rule
Rem    srtata      08/29/11 - lbac$ tables clean up
Rem    jibyun      07/27/11 - Bug 7118789: delete the ORADEBUG row from
Rem                           DVSYS.DV_AUTH
Rem    sanbhara    07/28/11 - Project 24121 - revoke grants to dvsys to exec
Rem                           dbms_system and create and drop directory so
Rem                           dbms_macadm.add_nls_data works.
Rem    sanbhara    07/12/11 - Project 24121 - adding ODD realm and moving
Rem                           objects from new realms in 12g to ODD realm.
Rem    srtata      06/28/11 - OLS rearch recreate views with new schema
Rem    youyang     04/26/11 - downgrade for name to id conversion
Rem    jibyun      04/13/11 - Bug 12356827: Clean up DV_GOLDENGATE_REDO_ACCESS
Rem                           role
Rem    jibyun      02/18/11 - Bug 11662436: Clean up DV_XSTREAM role
Rem    jibyun      02/10/11 - Bug 11662436: Clean up DV_GOLDENGATE_ADMIN role 
Rem    sanbhara    02/09/11 - Bug Fix 10225918.
Rem    dvekaria    01/24/11 - fix bug 9068994 
Rem    jheng       01/02/11 - fix bug 8501924
Rem    jheng       12/04/10 - drop dba_dv_datapump_auth
Rem    vigaur      06/02/10 - Create dve112.sql script
Rem    vigaur      06/02/10 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

@@dve121.sql

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."IDENTITY_MAP$"
ADD CONSTRAINT "IDENTITY_MAP_UK1" UNIQUE
(
IDENTITY_ID#
,FACTOR_LINK_ID#
,OPERATION_CODE_ID#
,OPERAND1
,OPERAND2
)
 ENABLE'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275, -01450) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP INDEX DVSYS.IDENTITY_MAP$_UK_IDX';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-01418) THEN NULL; -- ignore if index does not exist
    ELSE RAISE;
    END IF;    
END;
/

-- Bug 6503742
update DVSYS.FACTOR$ SET GET_EXPR = 'UTL_INADDR.GET_HOST_ADDRESS(DVSYS.DBMS_MACADM.GET_INSTANCE_INFO(''HOST_NAME''))' where name='Database_IP';

-- restore name from id
alter table dvsys.command_rule$ drop constraint COMMAND_RULE$_UK1;
alter table dvsys.realm_object$ drop constraint REALM_OBJECT$_UK1;
alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1;

-- UID 2147483636 represents all user/object names '%'
variable all_schema number;
begin
  select 2147483636 into :all_schema from dual;
end;
/

variable object_owner_none VARCHAR2(30);
begin
   :object_owner_none := '%';
end;
/

update dvsys.command_rule$ a set object_owner = (select name from sys.user$ where user# = a.object_owner_uid#) where a.object_owner_uid# <> :all_schema and (select name from sys.user$ where user# = a.object_owner_uid#) IS NOT NULL;
update dvsys.command_rule$ set object_owner = '%' where object_owner_uid# = :all_schema;

update dvsys.realm_object$ a set owner = (select name from sys.user$ where user# = a.owner_uid#) where a.owner_uid# <> :all_schema and (select name from sys.user$ where user# = a.owner_uid#) IS NOT NULL;
update dvsys.realm_object$ set owner = '%' where owner_uid# = :all_schema;

update dvsys.realm_auth$ a set grantee = (select name from sys.user$ where user# = a.grantee_uid#) where (select name from sys.user$ where user# = a.grantee_uid#) IS NOT NULL;

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_UK1" UNIQUE
(
CODE_ID#
,OBJECT_OWNER
,OBJECT_NAME
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
, OWNER
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
, GRANTEE
, AUTH_OPTIONS
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

CREATE OR REPLACE VIEW DVSYS.dv$command_rule
(
      id#
    , code_id#
    , command
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
)
AS SELECT
      m.id#
    , m.code_id#
    , d2.code
    , m.rule_set_id#
    , d1.name
    , m.object_owner
    , m.object_name
    , m.enabled
    , m.privilege_scope
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.command_rule$ m
    ,dvsys.dv$rule_set d1
    ,dvsys.dv$code d2
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
/

CREATE OR REPLACE VIEW DVSYS.dv$realm_auth
(
      id#
    , realm_id#
    , realm_name
    , grantee
    , auth_rule_set_id#
    , auth_rule_set_name
    , auth_options
    , auth_options_meaning
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
    , m.grantee
    , m.auth_rule_set_id#
    , d2.name
    , m.auth_options
    , c.value
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
WHERE
    d1.id# = m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
/

CREATE OR REPLACE VIEW DVSYS.dv$realm_object
(
      id#
    , realm_id#
    , realm_name
    , owner
    , object_name
    , object_type
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.realm_id#
    , d.name
    , m.owner
    , m.object_name
    , m.object_type
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_command_rule
(
      command
    , rule_set_name
    , object_owner
    , object_name
    , enabled
    , privilege_scope
)
AS SELECT
      d2.code
    , d1.name
    , m.object_owner
    , m.object_name
    , m.enabled
    , m.privilege_scope
FROM dvsys.command_rule$ m
    ,dvsys.dv$rule_set d1
    ,dvsys.dv$code d2
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm_auth
(
      realm_name
    , grantee
    , auth_rule_set_name
    , auth_options
)
AS SELECT
      d1.name
    , m.grantee
    , d2.name
    , c.value
FROM dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
WHERE
    d1.id# = m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm_object
(
      realm_name
    , owner
    , object_name
    , object_type
)
AS SELECT
     d.name
    , m.owner
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id#
/

create or replace force view dvsys.ku$_dv_isrm_view
       of dvsys.ku$_dv_isrm_t
  with object identifier (schema_name) as
  select '0','0',
         realm_objects.object_owner
    from (select distinct(objects_in_realm.owner) object_owner
            from dvsys.realm_object$ objects_in_realm
           where objects_in_realm.REALM_ID# > 5000) realm_objects
   where (sys_context('USERENV','CURRENT_USERID') = 1279990
          or exists (select 1 
                       from sys.session_roles
                      where role='DV_OWNER'))
/

create or replace force view dvsys.ku$_dv_realm_member_view
       of ku$_dv_realm_member_t
  with object identifier (object_name, name) as
  select '0','0',
          rlmt.name,
          rlmo.owner,
          rlmo.object_name,
          rlmo.object_type
  from    dvsys.realm$        rlm,
          dvsys.realm_t$      rlmt,
          dvsys.realm_object$ rlmo
  where   rlm.id# = rlmt.id#
    and   rlmo.realm_id# = rlm.id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

create or replace force view dvsys.ku$_dv_realm_auth_view
       of dvsys.ku$_dv_realm_auth_t
  with object identifier (realm_name, grantee) as
  select '0','0',
          rlmt.name,
          rlma.grantee,
          rs.name,
          decode(rlma.auth_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_OWNER',
                 to_char(rlma.auth_options))
  from    dvsys.realm$                   rlm,
          dvsys.realm_t$                 rlmt,
          dvsys.realm_auth$              rlma,
          (select m.id#,
                  d.name
             from dvsys.rule_set$   m,
                  dvsys.rule_set_t$ d
            where m.id# = d.id#)         rs
  where   rlm.id# = rlma.realm_id#
    and   rlm.id# = rlmt.id#
    and   rs.id# (+)= rlma.auth_rule_set_id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

-- Bug 7137958
update dvsys.dv_auth$ a set a.grantee = (select name from sys.user$ where user# = a.grantee_id);
update dvsys.dv_auth$ a set a.object_owner =  (select name from sys.user$ where user# = a.object_owner_id) where object_owner_id is not NULL and object_owner_id <> :all_schema;
update dvsys.dv_auth$ a set object_owner = '%' where object_owner_id = :all_schema or object_owner_id is NULL;

drop view dvsys.dba_dv_datapump_auth;
-- Bug 7118790
drop view dvsys.dba_dv_oradebug;
drop view DVSYS.dba_dv_proxy_auth;
drop view DVSYS.dba_dv_ddl_auth;
drop view DVSYS.dba_dv_auth;

-- bug 14456083: remove view DVSYS.dba_dv_tts_auth
revoke select on dvsys.dba_dv_tts_auth from dv_monitor;
revoke select on dvsys.dba_dv_tts_auth from dv_secanalyst;
drop view DVSYS.dba_dv_tts_auth;

-- Bug 13728213
drop view dvsys.dba_dv_dictionary_accts;

delete from dvsys.dv_auth$ where grant_type = 'DDL' and grantee_id = :all_schema and object_owner_id = :all_schema;
alter table dvsys.dv_auth$ drop column grantee_id;
alter table dvsys.dv_auth$ drop column object_owner_id;

-- Bug 14306557
delete from dvsys.dv_auth$ where grant_type = 'DVPATCHAUDIT';
drop view dvsys.dba_dv_patch_admin_audit;


CREATE OR REPLACE VIEW DVSYS.dba_dv_job_auth
(
      grantee
    , schema
)
AS SELECT
    grantee
  , object_owner
FROM dvsys.dv_auth$
WHERE grant_type = 'JOB' 
/

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.3.0' THEN

    -- "Allow Oracle Data Pump Operation" rule set
    BEGIN
    INSERT INTO DVSYS.RULE_SET$ (ID#,ENABLED,EVAL_OPTIONS,AUDIT_OPTIONS,FAIL_OPTIONS,HANDLER_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
    VALUES(8,'Y',2,1,1,0,1,USER,SYSDATE,USER,SYSDATE);

       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;
   
    END;

    --- "Allow Scheduler Job" rule set
    BEGIN
    INSERT INTO DVSYS.RULE_SET$ (ID#,ENABLED,EVAL_OPTIONS,AUDIT_OPTIONS,FAIL_OPTIONS,HANDLER_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) 
    VALUES (10,'Y',2,1,1,0,1,USER,SYSDATE,USER,SYSDATE);

       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;

    END;

    BEGIN 
    INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
    VALUES(10,8,2,1,'Y',1,USER,SYSDATE,USER,SYSDATE);

       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;
  
    END;

    BEGIN
    INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
    VALUES(18,10,2,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
  
       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;

    END;

    BEGIN
    INSERt INTO DVSYS.rule_set_t$(id#, language, name, description) values
    (8, 'us', 'Allow Oracle Data Pump Operation', 'Rule set that controls the objects that can be exported or imported by the Oracle Data Pump user.');
       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;

    END;

    BEGIN
    INSERt INTO DVSYS.rule_set_t$(id#, language, name, description) values
    (10, 'us', 'Allow Scheduler Job', 'Rule set that stores DV scheduler job authorized users.');
       EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
         ELSE RAISE;
         END IF;

    END;
  END IF;
END;
/

-- insert datapump and job auth from dvsys.dv_auth$ to their rule sets
DECLARE
  cursor cur is select grant_type, grantee, object_owner, object_name 
                from dvsys.dv_auth$;
  previous_version varchar2(30);
  l_rule_name dvsys.dv$rule.name%TYPE;
  l_seq  NUMBER;
  l_grantee VARCHAR2(130);
  l_object_owner VARCHAR(130);
  l_object_name VARCHAR(130);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  --The block only need to be executed when downgrade to 11.2.0.1 or 11.2.0.2
  IF previous_version < '11.2.0.3.0' THEN
    FOR ee IN cur LOOP
      IF ee.grantee IS NOT NULL THEN
        l_grantee := Dbms_Assert.Enquote_Literal(
                       replace(ee.grantee,'''',''''''));
        l_object_owner := Dbms_Assert.Enquote_Literal(
                            replace(ee.object_owner,'''',''''''));
        l_object_name := Dbms_Assert.Enquote_Literal(
                           replace(ee.object_name, '''', ''''''));

        IF ee.grant_type = 'JOB' THEN
          SELECT dvsys.rule$_seq.nextval INTO l_seq FROM DUAL;
          l_rule_name := 'DV$' || TO_CHAR(l_seq);
  
          IF (ee.object_owner IS NOT NULL) AND (ee.object_owner != '%') THEN
            INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                     CREATED_BY,CREATE_DATE,
                                     UPDATED_BY,UPDATE_DATE)
            VALUES
            (l_seq, '(dvsys.dv_job_invoker = ' || l_grantee  || 
                    ') AND (dvsys.dv_job_owner = ' || l_object_owner || ')', 
             1,USER,SYSDATE,USER,SYSDATE);
          ELSE
            INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION, 
                                     CREATED_BY,CREATE_DATE,
                                     UPDATED_BY,UPDATE_DATE) 
            VALUES
            (l_seq, 'dvsys.dv_job_invoker = ' || l_grantee, 1,
             USER,SYSDATE,USER,SYSDATE);
          END IF;
          INSERT INTO DVSYS.rule_t$(id#, name, language) VALUES
          (l_seq, l_rule_name, 'us');
          INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,
                                            RULE_ORDER,ENABLED,VERSION,
                                            CREATED_BY,CREATE_DATE,
                                            UPDATED_BY,UPDATE_DATE)
          VALUES(dvsys.rule_set_rule$_seq.NEXTVAL, 10, l_seq, 1,'Y',1,USER,
                 SYSDATE,USER,SYSDATE);    

        ELSIF ee.grant_type = 'DATAPUMP' THEN
          SELECT dvsys.rule$_seq.nextval INTO l_seq FROM DUAL;
          l_rule_name := 'DVDP$' || TO_CHAR(l_seq);
  
          IF (ee.object_name IS NOT NULL) AND (ee.object_name != '%') THEN
            INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                     CREATED_BY,CREATE_DATE,
                                     UPDATED_BY,UPDATE_DATE)
            VALUES
            (l_seq, '(dvsys.dv_login_user = ' || l_grantee ||
                    ') AND (dvsys.dv_dict_obj_owner = ' || l_object_owner ||
                    ') AND (dvsys.dv_dict_obj_name = ' || l_object_name || ')', 
             1,USER,SYSDATE,USER,SYSDATE);
  
          ELSIF (ee.object_owner IS NOT NULL) AND (ee.object_owner != '%') THEN
            INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                     CREATED_BY,CREATE_DATE,
                                     UPDATED_BY,UPDATE_DATE)
            VALUES
            (l_seq, '(dvsys.dv_login_user = ' || l_grantee ||
                    ') AND (dvsys.dv_dict_obj_owner = ' || l_object_owner || ')',
             1,USER,SYSDATE,USER,SYSDATE);
          ELSE
            INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                     CREATED_BY,CREATE_DATE,
                                     UPDATED_BY,UPDATE_DATE)
            VALUES
            (l_seq, 'dvsys.dv_login_user = ' || l_grantee, 1,
             USER,SYSDATE,USER,SYSDATE);
          END IF;

          INSERT INTO DVSYS.rule_t$(id#, name, language) VALUES
          (l_seq, l_rule_name, 'us');
  
          INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,
                                            RULE_ORDER,ENABLED,VERSION,
                                            CREATED_BY,CREATE_DATE,
                                            UPDATED_BY,UPDATE_DATE)
          VALUES(dvsys.rule_set_rule$_seq.NEXTVAL, 8, l_seq, 1,'Y',1,USER,
                 SYSDATE,USER,SYSDATE);
        END IF;
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

-- Bug 9068994 Handle downgrade of Drop User
BEGIN
UPDATE DVSYS.RULE_SET$ SET EVAL_OPTIONS = 2 WHERE ID# =3;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

DELETE FROM DVSYS.RULE_SET_RULE$
WHERE ID# = 19
AND   RULE_SET_ID# = 3
AND   RULE_ID# = 22;

DELETE FROM DVSYS.rule$ WHERE ID# = 22;

DELETE FROM DVSYS.rule_t$ WHERE ID# = 22;

-- Remove DV_GOLDENGATE_ADMIN role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_GOLDENGATE_ADMIN');

-- Remove the realm protection for DV_GOLDENGATE_ADMIN.
delete from DVSYS.realm_object$ where
  object_name = 'DV_GOLDENGATE_ADMIN' and object_type = 'ROLE';

-- Remove DV_XSTREAM_ADMIN role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_XSTREAM_ADMIN');

-- Remove the realm protection for DV_XSTREAM_ADMIN.
delete from DVSYS.realm_object$ where
  object_name = 'DV_XSTREAM_ADMIN' and object_type = 'ROLE';

-- Remove DV_GOLDENGATE_REDO_ACCESS role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_GOLDENGATE_REDO_ACCESS');

-- Remove the realm protection for DV_GOLDENGATE_REDO_ACCESS.
delete from DVSYS.realm_object$ where
  object_name = 'DV_GOLDENGATE_REDO_ACCESS' and object_type = 'ROLE';

-- Remove DV_AUDIT_CLEANUP role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_AUDIT_CLEANUP');

-- Revoke privileges from DV_AUDIT_CLEANUP.
revoke SELECT ON dvsys.audit_trail$ from DV_AUDIT_CLEANUP;
revoke DELETE ON dvsys.audit_trail$ from DV_AUDIT_CLEANUP;
revoke SELECT ON dvsys.dv$enforcement_audit from DV_AUDIT_CLEANUP;
revoke DELETE ON dvsys.dv$enforcement_audit from DV_AUDIT_CLEANUP;
revoke SELECT ON dvsys.dv$configuration_audit from DV_AUDIT_CLEANUP;
revoke DELETE ON dvsys.dv$configuration_audit from DV_AUDIT_CLEANUP;

-- Remove the realm protection for DV_AUDIT_CLEANUP.
delete from DVSYS.realm_object$ where
  object_name = 'DV_AUDIT_CLEANUP' and object_type = 'ROLE';

-- Drop DV_AUDIT_CLEANUP_GRANTEES view
drop view DV_AUDIT_CLEANUP_GRANTEES;

-- Remove DV_DATAPUMP_NETWORK_LINK role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_DATAPUMP_NETWORK_LINK');
REVOKE EXECUTE ON dvsys.check_full_dvauth FROM dv_datapump_network_link;
REVOKE EXECUTE ON dvsys.check_ts_dvauth FROM dv_datapump_network_link;
REVOKE EXECUTE ON dvsys.check_tab_dvauth FROM dv_datapump_network_link;

-- Remove DV_DATAPUMP_NETWORK_LINK related stand-alone functions
drop function dvsys.check_full_dvauth;
drop function dvsys.check_ts_dvauth;
drop function dvsys.check_tab_dvauth;

-- Remove the realm protection for DV_DATAPUMP_NETWORK_LINK
delete from DVSYS.realm_object$ where
  object_name = 'DV_DATAPUMP_NETWORK_LINK' and object_type = 'ROLE';

-- Remove the row corresponding to LBACSYS.DBA_OLS_STATUS
delete from DVSYS.realm_object$ where
  object_name = 'DBA_OLS_STATUS' and object_type = 'VIEW' and owner = 'LBACSYS';

--Project 24121 - revoke new grants to dvsys
REVOKE EXECUTE ON sys.utl_file FROM dvsys
/
REVOKE EXECUTE ON sys.dbms_system FROM dvsys
/
REVOKE CREATE ANY DIRECTORY FROM dvsys
/
REVOKE DROP ANY DIRECTORY FROM dvsys
/
REVOKE SELECT ON sys.dba_dependencies FROM dvsys
/

-- Bug 21451692: update realm ID# for Oracle Data Dictionary realm if there is
DECLARE
  ood_realm_currid  NUMBER := 0;
BEGIN

  BEGIN
    SELECT id# into ood_realm_currid FROM DVSYS.realm_t$ WHERE name = 'Oracle Data Dictionary' and language = 'us';

    -- if there was ODD realm, change the ID# of ODD realm to 1
    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$" MODIFY CONSTRAINT "REALM_OBJECT$_FK" DISABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$" MODIFY CONSTRAINT "REALM_AUTH$_FK" DISABLE';

    UPDATE DVSYS.realm$ SET ID# = 1 WHERE ID# = ood_realm_currid;
    UPDATE DVSYS.realm_t$ SET ID# = 1 WHERE ID# = ood_realm_currid;
    UPDATE DVSYS.realm_object$ SET REALM_ID# = 1 WHERE REALM_ID# = ood_realm_currid;
    UPDATE DVSYS.realm_auth$ SET REALM_ID# = 1 WHERE REALM_ID# = ood_realm_currid;

    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$" MODIFY CONSTRAINT "REALM_OBJECT$_FK" ENABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$" MODIFY CONSTRAINT "REALM_AUTH$_FK" ENABLE';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    -- if SELECT INTO statement shows no ODD realm, then ignore and continue
  END;

END;
/
--end Bug 21451692: update realm ID# for Oracle Data Dictionary realm

--Project 24121 add ODD realm to realm$ and realm_t$.

BEGIN 
INSERT INTO DVSYS.REALM$ (ID#,ENABLED,AUDIT_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(1,'Y',1,1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
INSERT INTO DVSYS.realm_t$ (description, id#, language, name) 
VALUES ('Defines the realm for the Oracle Catalog schemas, SYS, SYSTEM, MDSYS, etc. Also controls the ability to grant system privileges and database administrator roles.', 1, 'us', 'Oracle Data Dictionary');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

--Project 24121 migrate new objects and authorizations from the 3 new realms to ODD realm.

DECLARE
  realm_obj_row_id NUMBER;
  auth_row_id NUMBER;
BEGIN

FOR realm_obj_row in (select * from DVSYS.realm_object$ where (realm_id# = 8 OR realm_id# = 9 OR realm_id# = 10) AND id# >=5000) LOOP

    BEGIN
      DELETE from DVSYS.realm_object$ where id# = realm_obj_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    

    BEGIN
      SELECT DVSYS.realm_object$_seq.NEXTVAL INTO realm_obj_row_id FROM dual;
      INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
      VALUES(realm_obj_row_id,1,realm_obj_row.owner,realm_obj_row.owner_uid#,realm_obj_row.object_name,realm_obj_row.object_type,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;
END LOOP; 

FOR auth_row in (select * from DVSYS.realm_auth$ where (realm_id# = 8 OR realm_id# = 9 OR realm_id# = 10) AND id# >=5000) LOOP
  
    BEGIN
      DELETE from DVSYS.realm_auth$ where id# = auth_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    

    BEGIN
      SELECT DVSYS.realm_auth$_seq.NEXTVAL INTO auth_row_id FROM dual;
      INSERT INTO DVSYS.realm_auth$(id#,realm_id#,grantee,grantee_uid#,auth_rule_set_id#,auth_options,version,created_by,create_date,updated_by,update_date) 
      VALUES (auth_row_id,1,auth_row.grantee,auth_row.grantee_uid#,NULL,1,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;
END LOOP;

END;
/


--Project 24121 move default objects and authorizations to ODD realm

variable sys_schema number;
variable system_schema number;
begin 
  select user# into :sys_schema from sys.user$ where name = 'SYS';
  select user# into :system_schema from sys.user$ where name = 'SYSTEM';
end;
/

CREATE SEQUENCE realm_object$_seq_temp_dg START WITH 1000 
/

BEGIN 
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
VALUES(realm_object$_seq_temp_dg.nextval,1,'SYS',:sys_schema,'%','%',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

--Bug 14642504
BEGIN 
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(realm_object$_seq_temp_dg.nextval,2,'SYSTEM',:system_schema,'AUD$','TABLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 16028065: adding realm protection
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(realm_object$_seq_temp_dg.nextval,9,:object_owner_none,:all_schema,'DELETE_CATALOG_ROLE','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

DECLARE
  realm_obj_row_id NUMBER;
  auth_row_id NUMBER;
BEGIN

FOR realm_obj_row in (select * from DVSYS.realm_object$ where (realm_id# = 8 OR realm_id# = 9 OR realm_id# = 10) AND id# <5000) LOOP

    BEGIN
      DELETE from DVSYS.realm_object$ where id# = realm_obj_row.id#;
        EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    

    BEGIN
      SELECT realm_object$_seq_temp_dg.NEXTVAL INTO realm_obj_row_id FROM dual;
      INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
      VALUES(realm_obj_row_id,1,realm_obj_row.owner,realm_obj_row.owner_uid#,realm_obj_row.object_name,realm_obj_row.object_type,1,USER,SYSDATE,USER,SYSDATE);
        EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
          ELSE RAISE;
          END IF;
    END;
END LOOP; 

END;
/


BEGIN
INSERT INTO DVSYS.realm_auth$(id#,realm_id#,grantee,grantee_uid#,auth_rule_set_id#,auth_options,version,created_by,create_date,updated_by,update_date)
 VALUES(1,1,'SYS',:sys_schema,NULL,1,1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
DELETE FROM DVSYS.realm_auth$ where (realm_id# = 8 OR realm_id# = 9 OR realm_id# = 10) AND id# <5000; 
--id# < 5000 are only left for these realms anyway
END;
/

--Project 24121 delete the three new realms from realm$ and realm_t$.

BEGIN
DELETE FROM DVSYS.realm$ where id# = 8 OR id# = 9 OR id# = 10;
   EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
DELETE FROM DVSYS.realm_t$ where id# = 8 OR id# = 9 OR id# = 10;
   EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Bug 7118790: delete ORADEBUG row from DV_AUTH$
BEGIN
  DELETE FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'ORADEBUG';
    EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Bug 13728213: delete DV_ACCTS row from DV_AUTH$
BEGIN
  DELETE FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'DV_ACCTS';
    EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- recreate views as per old schema

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
    , lbacsys.lbac$pol d1
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
    , lbacsys.lbac$pol d2
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
Rem      Creates a meaning-based view with primary and foreign keys for the view lbacsys.lbac$pol.
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
    lbacsys.lbac$pol d1
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
     lbacsys.lbac$pol d2
    , lbacsys.lbac$lab d3
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
    , lbacsys.lbac$pol d2
    , lbacsys.lbac$lab d3
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
    , lbacsys.lbac$pol d1
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
    , lbacsys.lbac$pol d2
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
    , lbacsys.lbac$pol d2
    , lbacsys.lbac$lab d3
    , factor$ d4
WHERE
    d1.id# = m.identity_id#
    AND d2.pol# = m.policy_id#
    AND d3.tag# = m.label_id#
    AND d4.id# = d1.factor_id#
/

-- Alter DVSYS tables to reverse long identifier support
alter table DVSYS."DOCUMENT$" modify "DOC_REVISION" VARCHAR2(30);
alter table DVSYS."DOCUMENT$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."DOCUMENT$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."MAC_POLICY$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."MAC_POLICY$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."CODE$" modify "CODE_GROUP" VARCHAR2(30);
alter table DVSYS."CODE$" modify "CODE" VARCHAR2(30);
alter table DVSYS."CODE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."CODE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."MAC_POLICY_FACTOR$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."MAC_POLICY_FACTOR$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR$" modify "NAME" VARCHAR2(30);
alter table DVSYS."FACTOR$" modify "NAMESPACE" VARCHAR2(30);
alter table DVSYS."FACTOR$" modify "NAMESPACE_ATTRIBUTE" VARCHAR2(30);
alter table DVSYS."FACTOR$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_SCOPE$" modify "GRANTEE" VARCHAR2(30);
alter table DVSYS."FACTOR_SCOPE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_SCOPE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_TYPE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_TYPE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_TYPE_T$" modify "NAME" VARCHAR2(90);
alter table DVSYS."COMMAND_RULE$" modify "OBJECT_OWNER" VARCHAR2(30);
alter table DVSYS."COMMAND_RULE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."COMMAND_RULE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_LINK$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."FACTOR_LINK$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."ROLE$" modify "ROLE" VARCHAR2(30);
alter table DVSYS."ROLE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."ROLE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."IDENTITY$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."IDENTITY$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."IDENTITY_MAP$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."IDENTITY_MAP$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."RULE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."RULE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_T$" modify "NAME" VARCHAR2(90);
alter table DVSYS."POLICY_LABEL$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."POLICY_LABEL$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_SET_RULE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_SET_RULE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_SET$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_SET$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."RULE_SET_T$" modify "NAME" VARCHAR2(90);
alter table DVSYS."REALM_OBJECT$" modify "OWNER" VARCHAR2(30);
alter table DVSYS."REALM_OBJECT$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_OBJECT$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_AUTH$" modify "GRANTEE" VARCHAR2(30);
alter table DVSYS."REALM_AUTH$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_AUTH$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_COMMAND_RULE$" modify "OBJECT_OWNER" VARCHAR2(30);
alter table DVSYS."REALM_COMMAND_RULE$" modify "GRANTEE" VARCHAR2(30);
alter table DVSYS."REALM_COMMAND_RULE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_COMMAND_RULE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."REALM$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."REALM$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."REALM_T$" modify "NAME" VARCHAR2(90);
alter table DVSYS."MONITOR_RULE$" modify "CREATED_BY" VARCHAR2(30);
alter table DVSYS."MONITOR_RULE$" modify "UPDATED_BY" VARCHAR2(30);
alter table DVSYS."MONITOR_RULE_T$" modify "NAME" VARCHAR2(90);
alter table DVSYS."AUDIT_TRAIL$" modify USERNAME VARCHAR2(30);
alter table DVSYS."AUDIT_TRAIL$" modify OWNER VARCHAR2(30);
alter table DVSYS."AUDIT_TRAIL$" modify RULE_SET_NAME VARCHAR2(90);
alter table DVSYS."AUDIT_TRAIL$" modify RULE_NAME VARCHAR2(90);
alter table DVSYS."AUDIT_TRAIL$" modify CREATED_BY VARCHAR2(30);
alter table DVSYS."AUDIT_TRAIL$" modify UPDATED_BY VARCHAR2(30);
alter table DVSYS."DV_AUTH$" modify "GRANTEE" VARCHAR2(30);
alter table DVSYS."DV_AUTH$" modify "OBJECT_OWNER" VARCHAR2(30);

update DVSYS."AUDIT_TRAIL$" set GRANTEE = NULL;
update DVSYS."AUDIT_TRAIL$" set ENABLED_STATUS = NULL;

-- Add objects MGMT_USER role and MGMT_VIEW role back to the EM realm

BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date) VALUES(realm_object$_seq_temp_dg.nextval,7,'MGMT_VIEW',(select user# from sys.user$ where name='MGMT_VIEW'),'%','%',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN 
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date) VALUES(realm_object$_seq_temp_dg.nextval,7,:object_owner_none,:all_schema,'MGMT_USER','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

DROP SEQUENCE realm_object$_seq_temp_dg 
/

delete from dvsys.code$
where id# > 600 AND id# < 673;

delete from dvsys.code_t$
where id# > 600 AND id# < 673;

truncate table dvsys.realm_t$_temp;
truncate table dvsys.code_t$_temp;
truncate table dvsys.factor_t$_temp;
truncate table dvsys.factor_type_t$_temp;
truncate table dvsys.rule_t$_temp;
truncate table dvsys.rule_set_t$_temp;

drop view dvsys.dv$enforcement_audit;
drop view dvsys.dv$configuration_audit;
drop view sys.dv$enforcement_audit;
drop view sys.dv$configuration_audit;

drop procedure dvsys.configure_dv;

drop package dvsys.dbms_macdvutl;

--bug 8420170
update dvsys.code$ set code='CREATE SNAPSHOT LOG' where id#=71;
update dvsys.code$ set code='ALTER SNAPSHOT LOG' where id#=72;
update dvsys.code$ set code='DROP SNAPSHOT LOG' where id#=73;
update dvsys.code$ set code='CREATE SNAPSHOT' where id#=74;
update dvsys.code$ set code='ALTER SNAPSHOT' where id#=75;
update dvsys.code$ set code='DROP SNAPSHOT' where id#=76;
delete from dvsys.code$ where id#=196;
update dvsys.code$ set id#=301 where id#=212;
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(302,'SQL_CMDS','ALTER EDITION',1,USER,SYSDATE,USER,SYSDATE);
update dvsys.code$ set id#=303 where id#=214;
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(491,'DB_OBJECT_TYPE','CONSUMER GROUP',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(492,'DB_OBJECT_TYPE','CONTEXT',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(494,'DB_OBJECT_TYPE','DIRECTORY',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(495,'DB_OBJECT_TYPE','EVALUATION CONTEXT',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(500,'DB_OBJECT_TYPE','JAVA CLASS',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(501,'DB_OBJECT_TYPE','JAVA DATA',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(502,'DB_OBJECT_TYPE','JAVA RESOURCE',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(504,'DB_OBJECT_TYPE','JOB CLASS',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(506,'DB_OBJECT_TYPE','LOB',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(507,'DB_OBJECT_TYPE','LOB PARTITION',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(508,'DB_OBJECT_TYPE','SNAPSHOT',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(514,'DB_OBJECT_TYPE','QUEUE',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(515,'DB_OBJECT_TYPE','RESOURCE PLAN',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(517,'DB_OBJECT_TYPE','RULE',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(518,'DB_OBJECT_TYPE','RULE SET',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(519,'DB_OBJECT_TYPE','SCHEDULE',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(523,'DB_OBJECT_TYPE','TABLE PARTITION',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(529,'DB_OBJECT_TYPE','WINDOW',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(530,'DB_OBJECT_TYPE','WINDOW GROUP',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(531,'DB_OBJECT_TYPE','XML SCHEMA',1,USER,SYSDATE,USER,SYSDATE);
update dvsys.code$ set code='SNAPSHOT LOG' where id#=532;
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(534,'FACTOR_IDENTIFY','3',1,USER,SYSDATE,USER,SYSDATE);

delete from dvsys.code_t$ where id#=196;
delete from dvsys.code_t$ where id#=212;
delete from dvsys.code_t$ where id#=214;
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(491,'CONSUMER GROUP','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(492,'CONTEXT','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(494,'DIRECTORY','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(495,'EVALUATION CONTEXT','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(500,'JAVA CLASS','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(501,'JAVA DATA','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(502,'JAVA RESOURCE','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(504,'JOB CLASS','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(506,'LOB','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(507,'LOB PARTITION','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(508,'MATERIALIZED VIEW','','us') ;
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(514,'QUEUE','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(515,'RESOURCE PLAN','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(517,'RULE','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(518,'RULE SET','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(519,'SCHEDULE','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(523,'TABLE PARTITION','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(529,'WINDOW','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(530,'WINDOW GROUP','','us');
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(531,'XML SCHEMA','','us');
delete from dvsys.code_t$ where id#=533;
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(534,'By Context','','us');

alter table dvsys.realm_object$ modify object_type varchar2(19);
alter table dvsys.dv_auth$ modify object_type varchar2(19);
alter type dvsys.ku$_dv_realm_member_t modify attribute object_type varchar2(19) cascade;

--Bug 13689262
delete from dvsys.code$ where id#=226;
delete from dvsys.code$ where id#=227;
delete from dvsys.code$ where id#=228;

delete from dvsys.code_t$ where id#=226;
delete from dvsys.code_t$ where id#=227;
delete from dvsys.code_t$ where id#=228;

--Bug14757586
delete from dvsys.code$ where id#=42;
delete from dvsys.code_t$ where id#=42;

--lrg #6940078
DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.3.0' THEN

    update dvsys.rule$ set rule_expr = 'dvsys.dv_login_user = dvsys.dv_dict_obj_name' where id#=10;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ACCTMGR'', dvsys.dv_login_user) = ''Y''' where id#=3;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DBA'', dvsys.dv_login_user) = ''Y''' where id#=4;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ADMIN'', dvsys.dv_login_user) = ''Y''' where id#=5;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_OWNER'', dvsys.dv_login_user) = ''Y''' where id#=6;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''LBAC_DBA'', dvsys.dv_login_user) = ''Y''' where id#=7;
    update dvsys.rule$ set rule_expr = '(DVSYS.DBMS_MACUTL.USER_HAS_SYSTEM_PRIV_VARCHAR(''EXEMPT ACCESS POLICY'', dvsys.dv_login_user) = ''N'') OR USER = ''SYS''' where id#=9;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_ALTER_USER_ALLOW_VARCHAR(dvsys.dv_login_user) = ''Y''' where id#=14;
    update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_DROP_USER_ALLOW_VARCHAR(dvsys.dv_login_user) = ''Y''' where id#=22;
    commit;

  END IF;
END;
/ 

-- Bug 21519712: grant EXECUTE on DVSYS.GET_FACTOR to DVF when downgrading to 11.2.
grant EXECUTE on DVSYS.GET_FACTOR to DVF;

-- Bug 21519014: create DV_ADMIN_DIR directory if we are downgrading to 
-- 11.2.0.3 or 11.2.0.4.
DECLARE
 v_OH_path varchar2(255);
 v_dlf_path    varchar2(255);
 v_pfid number;
 PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
 PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;
 previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version > '11.2.0.2.0' THEN

    sys.dbms_system.get_env('ORACLE_HOME',v_OH_path);
    SELECT platform_id INTO v_pfid FROM v$database;

    IF (v_pfid = PLATFORM_WINDOWS32 OR v_pfid = PLATFORM_WINDOWS64) THEN
      v_dlf_path := v_OH_path||'\dv\admin\';
    ELSE
      v_dlf_path := v_OH_path||'/dv/admin/';
    END IF;

    EXECUTE IMMEDIATE 'create or replace directory DV_ADMIN_DIR AS'''|| v_dlf_path || '''';
    EXECUTE IMMEDIATE 'grant read on directory DV_ADMIN_DIR to dvsys';

  END IF;
END;
/

EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '11.2.0');
