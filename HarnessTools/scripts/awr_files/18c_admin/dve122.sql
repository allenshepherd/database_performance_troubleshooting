Rem
Rem $Header: rdbms/admin/dve122.sql /main/13 2017/09/29 20:24:33 sjavagal Exp $
Rem
Rem dve122.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dve122.sql - Downgrade to 12.2.0.1
Rem
Rem    DESCRIPTION
Rem      Downgrade DV to 12.2.0.1 from current/latest version
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sjavagal    09/05/17 - Bug 26325568: Update dv_auth$.action to '%' for 
Rem                           DATAPUMP grant_type
Rem    mjgreave    08/11/17 - Bug 26584641: restore prior views
Rem    jibyun      08/22/17 - Bug 26612996: CSW_USR_ROLE ans SPATIAL_CSW_ADMIN
Rem                           roles are deprecated in 18.1
Rem    jibyun      06/23/17 - Bug 26338289: add the JAVA_DEPLOY role to realm
Rem                           for default protection
Rem    raeburns    06/18/17 - RTI 20258949: restore prior release tables
Rem    amunnoli    06/02/17 - Bug 25245797: move DV UNIAUD views back to SYS
Rem    youyang     05/18/17 - add sql meta data
Rem    qinwu       03/07/17 - proj 70151: support db capture and replay auth
Rem    dalpern     02/23/17 - rti 19892854: DBA_DV_DEBUG_CONNECT_AUTH SYNONYM
Rem    risgupta    01/15/17 - Proj 67579: Downgrade changes for DV Simulation
Rem                           Mode Enhancements
Rem    risgupta    11/14/16 - Bug 24971682: Move downgrade changes for 24557076
Rem                           to dve121.sql
Rem    jibyun      09/22/16 - Bug 24557076: Revert change to DV_OWNER
Rem    namoham     09/16/16 - Bug 18357008: restore audit_trail$ field lengths
Rem    namoham     09/14/16 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dve122.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dve122.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dvdwgrd.sql
Rem    END SQL_FILE_METADATA

-- first statement
EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

-- Bug 24582583 - revert back to old lengths
update dvsys.audit_trail$ set action_name = substr(action_name, 1, 128);
alter table dvsys.audit_trail$ modify action_name varchar2(128);
update dvsys.audit_trail$ set os_process = substr(os_process, 1, 16);
alter table dvsys.audit_trail$ modify os_process varchar2(16);

variable realm_obj_max_id number;
begin
  select max(id#) into :realm_obj_max_id from DVSYS.realm_object$ where id# < 5000;
end;
/

-- Bug 26338289 - Add JAVA_DEPLOY back to OSPRM realm
BEGIN
  INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
  VALUES(:realm_obj_max_id+1,9,'%',2147483636,'JAVA_DEPLOY','ROLE',1,USER,SYSDATE,USER,SYSDATE);
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/
-- Bug 26612996: Add CSW_USR_ROLE and SPATIAL_CSW_ADMIN roles to realm
BEGIN
  INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
  VALUES(:realm_obj_max_id+2,9,'%',2147483636,'CSW_USR_ROLE','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
  INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,owner_uid#,object_name,object_type,version,created_by,create_date,updated_by,update_date)
  VALUES(:realm_obj_max_id+3,9,'%',2147483636,'SPATIAL_CSW_ADMIN','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

-- Proj 67579: Downgrade Changes for DV Simulation Mode Enhancements
drop function dvsys.stack_varray_to_clob;
drop function dvsys.dv_id_to_name;
drop function dvsys.dv_id_to_type;

alter table dvsys.simulation_log$ drop column authentication_method; 
alter table dvsys.simulation_log$ drop column client_ip;
alter table dvsys.simulation_log$ drop column db_domain;
alter table dvsys.simulation_log$ drop column database_hostname;
alter table dvsys.simulation_log$ drop column database_instance;
alter table dvsys.simulation_log$ drop column database_ip;
alter table dvsys.simulation_log$ drop column database_name;
alter table dvsys.simulation_log$ drop column domain;
alter table dvsys.simulation_log$ drop column enterprise_identity;
alter table dvsys.simulation_log$ drop column identification_type;
alter table dvsys.simulation_log$ drop column lang;
alter table dvsys.simulation_log$ drop column language;
alter table dvsys.simulation_log$ drop column machine;
alter table dvsys.simulation_log$ drop column network_protocol;
alter table dvsys.simulation_log$ drop column proxy_enterprise_identity;
alter table dvsys.simulation_log$ drop column proxy_user;
alter table dvsys.simulation_log$ drop column session_user;
alter table dvsys.simulation_log$ drop column dv$_dblink_info;
alter table dvsys.simulation_log$ drop column dv$_module;
alter table dvsys.simulation_log$ drop column dv$_client_identifier;
alter table dvsys.simulation_log$ drop column realm_id_list;
alter table dvsys.simulation_log$ drop column command_rule_id_list;
alter table dvsys.simulation_log$ drop column rule_set_id_list;
alter table dvsys.simulation_log$ drop column pl_sql_stack;

drop public synonym dv_obj_name;
drop type dvsys.dv_obj_name;

drop public synonym simulation_ids;
drop type dvsys.simulation_ids force;

drop public synonym plsql_stack_array;
drop type dvsys.plsql_stack_array force;

alter table dvsys.command_rule$ drop column pl_sql_stack;
alter table dvsys.realm$ drop column pl_sql_stack;
alter table dvsys.policy$ drop column pl_sql_stack;

truncate table dvsys.simulation_log$;

-----------------------------------------------------------------------
--- End: Project 67579 Changes
-----------------------------------------------------------------------

-----------------------------------------------------------------------
--- Begin: Bug 25245797 Changes
-----------------------------------------------------------------------

-- DROP AUDSYS owned DV UNIAUD views
DROP VIEW AUDSYS.dv$enforcement_audit;
DROP VIEW AUDSYS.dv$configuration_audit;

-- Re-create the DV UNIAUD views back in SYS schema
BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW SYS.dv$configuration_audit
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
FROM unified_audit_trail where audit_type = ''Database Vault'' and DV_ACTION_CODE > 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW SYS.dv$enforcement_audit
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
FROM unified_audit_trail where audit_type = ''Database Vault'' and DV_ACTION_CODE < 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-----------------------------------------------------------------------
--- End: Bug 25245797 Changes
-----------------------------------------------------------------------

-- PUBLIC SYNONYM was added in 12.2.0.2, RTI 19892854.
begin
  delete from dvsys.realm_object$ where owner='PUBLIC' and
    object_type='SYNONYM' and object_name='DBA_DV_DEBUG_CONNECT_AUTH';
  execute immediate 'drop PUBLIC SYNONYM dba_dv_debug_connect_auth';
exception
when others then
  if sqlcode in (-01432) then null;
  else raise;
  end if;
end;
/

-- Proj 70151: remove DBREPLAY authorization support
delete from dvsys.realm_object$ 
where owner = 'PUBLIC' and object_type = 'SYNONYM' and 
      object_name in ('DBA_DV_DBCAPTURE_AUTH', 'DBA_DV_DBREPLAY_AUTH');

drop public synonym dba_dv_dbcapture_auth;
drop public synonym dba_dv_dbreplay_auth;

drop view dvsys.ku$_dv_auth_dbcapture_v;
drop view dvsys.ku$_dv_auth_dbreplay_v;

drop type dvsys.ku$_dv_auth_dbcapture_t;
drop type dvsys.ku$_dv_auth_dbreplay_t;

delete from dvsys.dv_auth$ where grant_type = 'DBCAPTURE';
drop view dvsys.dba_dv_dbcapture_auth;
delete from dvsys.code$ where id# in (694, 695); 
delete from dvsys.code_t$ where id# in (694, 695);

delete from dvsys.dv_auth$ where grant_type = 'DBREPLAY';
drop view dvsys.dba_dv_dbreplay_auth;
delete from dvsys.code$ where id# in (696, 697); 
delete from dvsys.code_t$ where id# in (696, 697);

-----------------------------------------------------------------------
--- End: Project 70151 Changes
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--  BEGIN RTI 12596835: Restore tables dropped in dvu122.sql and
--  not restored in prior release dvrelod.sql scripts
-----------------------------------------------------------------------

--------------------------------------------------------------------
-- DVSYS."REALM_COMMAND_RULE$";
--------------------------------------------------------------------

CREATE TABLE DVSYS."REALM_COMMAND_RULE$"
(
"ID#" NUMBER NOT NULL,
"REALM_ID#" NUMBER NOT NULL,
"CODE_ID#" NUMBER NOT NULL,
"RULE_SET_ID#" NUMBER NOT NULL,
"OBJECT_OWNER" VARCHAR2 (30) NOT NULL,
"OBJECT_NAME" VARCHAR2 (128) NOT NULL,
"GRANTEE" VARCHAR2 (30) NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"PRIVILEGE_SCOPE" NUMBER,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (30),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (30),
"UPDATE_DATE" DATE
);

ALTER TABLE DVSYS."REALM_COMMAND_RULE$"
ADD CONSTRAINT "REALM_COMMAND_RULE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE;

ALTER TABLE DVSYS."REALM_COMMAND_RULE$"
ADD CONSTRAINT "REALM_COMMAND_RULE$_FK" FOREIGN KEY
(
"RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE;

ALTER TABLE DVSYS."REALM_COMMAND_RULE$"
ADD CONSTRAINT "REALM_COMMAND_RULE$_FK1" FOREIGN KEY
(
"CODE_ID#"
)
REFERENCES DVSYS."CODE$"
(
"ID#"
) ENABLE;

ALTER TABLE DVSYS."REALM_COMMAND_RULE$"
ADD CONSTRAINT "REALM_COMMAND_RULE$_FK2" FOREIGN KEY
(
"REALM_ID#"
)
REFERENCES DVSYS."REALM$"
(
"ID#"
) ENABLE;

CREATE INDEX DVSYS.REALM_COMMAND_RULE$_FK_IDX  ON DVSYS.REALM_COMMAND_RULE$ (RULE_SET_ID#);

CREATE INDEX DVSYS.REALM_COMMAND_RULE$_FK1_IDX ON DVSYS.REALM_COMMAND_RULE$ (CODE_ID#);

CREATE INDEX DVSYS.REALM_COMMAND_RULE$_FK2_IDX ON DVSYS.REALM_COMMAND_RULE$ (REALM_ID#);

--------------------------------------------------------------------
-- DVSYS."DOCUMENT$";
--------------------------------------------------------------------

CREATE TABLE DVSYS."DOCUMENT$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (255) NOT NULL,
"DOC_TYPE" NUMBER NOT NULL,
"DOC_REVISION" VARCHAR2 (30) NOT NULL,
"ENABLED" NUMBER NOT NULL,
"XML_DATA" CLOB NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (30),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (30),
"UPDATE_DATE" DATE
);

ALTER TABLE DVSYS."DOCUMENT$"
ADD CONSTRAINT "DOCUMENT$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE;

ALTER TABLE DVSYS."DOCUMENT$"
ADD CONSTRAINT "DOCUMENT$_UK1" UNIQUE
(
"NAME"
)
 ENABLE;



--------------------------------------------------------------------
-- DVSYS."FACTOR_SCOPE$";
--------------------------------------------------------------------

CREATE TABLE DVSYS."FACTOR_SCOPE$"
(
"ID#" NUMBER NOT NULL,
"FACTOR_ID#" NUMBER NOT NULL,
"GRANTEE" VARCHAR2 (30) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (30),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (30),
"UPDATE_DATE" DATE
);

ALTER TABLE DVSYS."FACTOR_SCOPE$"
ADD CONSTRAINT "FACTOR_SCOPE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE;

ALTER TABLE DVSYS."FACTOR_SCOPE$"
ADD CONSTRAINT "FACTOR_SCOPE$_FK" FOREIGN KEY
(
"FACTOR_ID#"
)
REFERENCES DVSYS."FACTOR$"
(
"ID#"
) ENABLE;

ALTER TABLE DVSYS."FACTOR_SCOPE$"
ADD CONSTRAINT "FACTOR_SCOPE$_UK1" UNIQUE
(
"FACTOR_ID#"
, "GRANTEE"
)
 ENABLE;

CREATE INDEX DVSYS.FACTOR_SCOPE$_FK_IDX        ON DVSYS.FACTOR_SCOPE$       (FACTOR_ID#);

--------------------------------------------------------------------
-- DVSYS."MONITOR_RULE$";
--------------------------------------------------------------------

CREATE TABLE DVSYS."MONITOR_RULE$"
(
"ID#" NUMBER NOT NULL,
"MONITOR_RULE_SET_ID#" NUMBER NOT NULL,
"RESTART_FREQ" NUMBER NOT NULL,
"ENABLED" VARCHAR2 (1) NOT NULL,
"VERSION" NUMBER,
"CREATED_BY" VARCHAR2 (30),
"CREATE_DATE" DATE,
"UPDATED_BY" VARCHAR2 (30),
"UPDATE_DATE" DATE
);

ALTER TABLE DVSYS."MONITOR_RULE$"
ADD CONSTRAINT "MONITOR_RULE$_PK1" PRIMARY KEY
(
"ID#"
)
 ENABLE;

ALTER TABLE DVSYS."MONITOR_RULE$"
ADD CONSTRAINT "MONITOR_RULE$_FK1" FOREIGN KEY
(
"MONITOR_RULE_SET_ID#"
)
REFERENCES DVSYS."RULE_SET$"
(
"ID#"
) ENABLE;

CREATE INDEX DVSYS.MONITOR_RULE$_FK1_IDX ON 
   DVSYS.MONITOR_RULE$ (MONITOR_RULE_SET_ID#)

--------------------------------------------------------------------
-- DVSYS."MONITOR_RULE_T$";
--------------------------------------------------------------------

CREATE TABLE DVSYS."MONITOR_RULE_T$"
(
"ID#" NUMBER NOT NULL,
"NAME" VARCHAR2 (90) NOT NULL,
"DESCRIPTION" VARCHAR2 (1024),
"LANGUAGE" VARCHAR2(3) NOT NULL
);

ALTER TABLE DVSYS."MONITOR_RULE_T$"
ADD CONSTRAINT "MONITOR_RULE_T$_UK1" UNIQUE
(
"ID#"
, "LANGUAGE"
)
 ENABLE;

ALTER TABLE DVSYS."MONITOR_RULE_T$"
ADD CONSTRAINT "MONITOR_RULE_T$_UK2" UNIQUE
(
"NAME"
, "LANGUAGE"
)
 ENABLE;
-----------------------------------------------------------------------
--  END RTI 12596835:  Restore tables dropped in dvu122.sql and
--  not restored in prior release dvrelod.sql scripts
-----------------------------------------------------------------------

-----------------------------------------------------------------------
--  Bug 26584641: Recreate views modified by fix for bug 26584641 
-----------------------------------------------------------------------

create or replace type dvsys.ku$_dv_comm_rule_alts_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
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
);
/

create or replace force view dvsys.ku$_dv_comm_rule_alts_v
       of dvsys.ku$_dv_comm_rule_alts_t
  with object identifier (command, clause_name, parameter_name, event_name,
                          component_name, action_name, scope) as
  select '0','0',
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
                        where role='DV_OWNER' ));
/

create or replace type dvsys.ku$_dv_policy_obj_c_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  policy_name     varchar2(128),                       /* name of DV policy */
  command         varchar2(128),                                 /* command */
  object_owner    varchar2(128),                            /* object owner */
  object_name     varchar2(128),                             /* object name */
  scope           number
);
/

create or replace force view dvsys.ku$_dv_policy_obj_c_v
       of dvsys.ku$_dv_policy_obj_c_t
  with object identifier (policy_name, command, object_owner, object_name) as
  select '0','0',
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
                        where role='DV_OWNER' ));
/

create or replace type dvsys.ku$_dv_policy_obj_c_alts_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
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
);
/

create or replace force view dvsys.ku$_dv_policy_obj_c_alts_v
       of dvsys.ku$_dv_policy_obj_c_alts_t
  with object identifier (policy_name, command,
                          clause_name, parameter_name, event_name,
                          component_name, action_name) as
  select '0','0',
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
                        where role='DV_OWNER' ));
/
-----------------------------------------------------------------------
--  End bug 26584641: Recreate views modified by fix for bug 26584641 
-----------------------------------------------------------------------

-----------------------------------------------------------------------
--  BEGIN Bug 26325568: Update action values for datapump  
-----------------------------------------------------------------------
-- Delete rows that was introduced due to Bug fix #26325568. The older
-- version of databases do not need these authorizations. The only other 
-- possible rows are action = 'TABLE' and action = '%'. 
DELETE FROM dvsys.dv_auth$ 
  WHERE 
  grant_type = 'DATAPUMP' AND
  (action = 'GRANT' OR action = 'CREATE_USER');

-- If action = 'TABLE' or action = '%' change the action to '%'. 
-- Older version of databases do not need action value for datapump 
-- authorization. 
UPDATE dvsys.dv_auth$ SET 
  action = '%' 
  WHERE 
  grant_type = 'DATAPUMP';

-----------------------------------------------------------------------
--  END Bug 26325568: Update action values for datapump  
-----------------------------------------------------------------------

-- last statement
EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '12.2.0');
