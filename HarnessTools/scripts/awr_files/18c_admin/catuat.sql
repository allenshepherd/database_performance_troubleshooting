Rem
Rem $Header: rdbms/admin/catuat.sql /main/9 2017/06/15 05:13:43 amunnoli Exp $
Rem
Rem catuat.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catuat.sql
Rem
Rem    DESCRIPTION
Rem      Creates the unified audit internal tables, views, packages
Rem
Rem    NOTES
Rem      Must be run while connected to SYS.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catuat.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catuat.sql
Rem    SQL_PHASE: CATUAT
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    01/29/17 - Bug 25245797: Recreate UNIFIED_AUDIT_TRAIL under
Rem                           AUDSYS schema
Rem    amunnoli    11/01/16 - Bug 24974960: make aud$unified as partitioned
Rem    amunnoli    09/30/16 - Bug 24762999: Do not handle ORA-955 for creation
Rem                           of AUDSYS.AUD$UNIFIED table
Rem    amunnoli    06/01/16 - Bug 23515378: grant read on audit views
Rem    risgupta    05/05/16 - Bug 23189437: Add comments for columns in
Rem                           UNIFIED_AUDIT_TRAIL view 
Rem    amunnoli    03/09/16 - Bug 22899818:Handle upgrade issues of AUD$UNIFIED
Rem    amunnoli    10/18/15 - Fix ROLE column comment
Rem    amunnoli    07/08/15 - bug 21576381:Fix the event_timestamp TZ issue
Rem    amunnoli    06/24/15 - Proj 46892:Create unified audit trail dependents
Rem    amunnoli    06/13/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Project 46892 - Introduce a new relational table AUDSYS.AUD$UNIFIED.
Rem Structure of this table should be same as that of GV$UNIFIED_AUDIT_TRAIL.
Rem ER 13716158 - Add CURRENT_USER column to capture the effective user name
Rem Bug 24974960 - Make this table as always partitioned, irrespective of db 
Rem editions
Rem

-- Turns off partition check --
-- We would like to create a partitioned table even when Partitioning Option 
-- is not Enabled.
alter session set events  '14524 trace name context forever, level 1';

CREATE TABLE AUDSYS.AUD$UNIFIED (
 INST_ID                                    NUMBER,
 AUDIT_TYPE                                 NUMBER,
 SESSIONID                                  NUMBER,
 PROXY_SESSIONID                            NUMBER,
 OS_USER                                    VARCHAR2(128),
 HOST_NAME                                  VARCHAR2(128),
 TERMINAL                                   VARCHAR2(30),
 INSTANCE_ID                                NUMBER,
 DBID                                       NUMBER,
 AUTHENTICATION_TYPE                        VARCHAR2(1024),
 USERID                                     VARCHAR2(128),
 PROXY_USERID                               VARCHAR2(128),
 EXTERNAL_USERID                            VARCHAR2(1024),
 GLOBAL_USERID                              VARCHAR2(32),
 CLIENT_PROGRAM_NAME                        VARCHAR2(48),
 DBLINK_INFO                                VARCHAR2(4000),
 XS_USER_NAME                               VARCHAR2(128),
 XS_SESSIONID                               RAW(33),
 ENTRY_ID                                   NUMBER NOT NULL,
 STATEMENT_ID                               NUMBER NOT NULL,
 EVENT_TIMESTAMP                            TIMESTAMP NOT NULL,
 ACTION                                     NUMBER NOT NULL,
 RETURN_CODE                                NUMBER NOT NULL,
 OS_PROCESS                                 VARCHAR2(16),
 TRANSACTION_ID                             RAW(8),
 SCN                                        NUMBER,
 EXECUTION_ID                               VARCHAR2(64),
 OBJ_OWNER                                  VARCHAR2(128),
 OBJ_NAME                                   VARCHAR2(128),
 SQL_TEXT                                   CLOB,
 SQL_BINDS                                  CLOB,
 APPLICATION_CONTEXTS                       VARCHAR2(4000),
 CLIENT_IDENTIFIER                          VARCHAR2(64),
 NEW_OWNER                                  VARCHAR2(128),
 NEW_NAME                                   VARCHAR2(128),
 OBJECT_EDITION                             VARCHAR2(128),
 SYSTEM_PRIVILEGE_USED                      VARCHAR2(1024),
 SYSTEM_PRIVILEGE                           NUMBER,
 AUDIT_OPTION                               NUMBER,
 OBJECT_PRIVILEGES                          VARCHAR2(35),
 ROLE                                       VARCHAR2(128),
 TARGET_USER                                VARCHAR2(128),
 EXCLUDED_USER                              VARCHAR2(128),
 EXCLUDED_SCHEMA                            VARCHAR2(128),
 EXCLUDED_OBJECT                            VARCHAR2(128),
 CURRENT_USER                               VARCHAR2(128),
 ADDITIONAL_INFO                            VARCHAR2(4000),
 UNIFIED_AUDIT_POLICIES                     VARCHAR2(4000),
 FGA_POLICY_NAME                            VARCHAR2(128),
 XS_INACTIVITY_TIMEOUT                      NUMBER,
 XS_ENTITY_TYPE                             VARCHAR2(32),
 XS_TARGET_PRINCIPAL_NAME                   VARCHAR2(128),
 XS_PROXY_USER_NAME                         VARCHAR2(128),
 XS_DATASEC_POLICY_NAME                     VARCHAR2(128),
 XS_SCHEMA_NAME                             VARCHAR2(128),
 XS_CALLBACK_EVENT_TYPE                     VARCHAR2(32),
 XS_PACKAGE_NAME                            VARCHAR2(128),
 XS_PROCEDURE_NAME                          VARCHAR2(128),
 XS_ENABLED_ROLE                            VARCHAR2(128),
 XS_COOKIE                                  VARCHAR2(1024),
 XS_NS_NAME                                 VARCHAR2(128),
 XS_NS_ATTRIBUTE                            VARCHAR2(4000),
 XS_NS_ATTRIBUTE_OLD_VAL                    VARCHAR2(4000),
 XS_NS_ATTRIBUTE_NEW_VAL                    VARCHAR2(4000),
 DV_ACTION_CODE                             NUMBER,
 DV_ACTION_NAME                             VARCHAR2(30),
 DV_EXTENDED_ACTION_CODE                    NUMBER,
 DV_GRANTEE                                 VARCHAR2(128),
 DV_RETURN_CODE                             NUMBER,
 DV_ACTION_OBJECT_NAME                      VARCHAR2(128),
 DV_RULE_SET_NAME                           VARCHAR2(90),
 DV_COMMENT                                 VARCHAR2(4000),
 DV_FACTOR_CONTEXT                          VARCHAR2(4000),
 DV_OBJECT_STATUS                           VARCHAR2(1),
 OLS_POLICY_NAME                            VARCHAR2(128),
 OLS_GRANTEE                                VARCHAR2(128),
 OLS_MAX_READ_LABEL                         VARCHAR2(4000),
 OLS_MAX_WRITE_LABEL                        VARCHAR2(4000),
 OLS_MIN_WRITE_LABEL                        VARCHAR2(4000),
 OLS_PRIVILEGES_GRANTED                     VARCHAR2(128),
 OLS_PROGRAM_UNIT_NAME                      VARCHAR2(128),
 OLS_PRIVILEGES_USED                        VARCHAR2(128),
 OLS_STRING_LABEL                           VARCHAR2(4000),
 OLS_LABEL_COMPONENT_TYPE                   VARCHAR2(12),
 OLS_LABEL_COMPONENT_NAME                   VARCHAR2(30),
 OLS_PARENT_GROUP_NAME                      VARCHAR2(30),
 OLS_OLD_VALUE                              VARCHAR2(4000),
 OLS_NEW_VALUE                              VARCHAR2(4000),
 RMAN_SESSION_RECID                         NUMBER,
 RMAN_SESSION_STAMP                         NUMBER,
 RMAN_OPERATION                             VARCHAR2(20),
 RMAN_OBJECT_TYPE                           VARCHAR2(20),
 RMAN_DEVICE_TYPE                           VARCHAR2(5),
 DP_TEXT_PARAMETERS1                        VARCHAR2(512),
 DP_BOOLEAN_PARAMETERS1                     VARCHAR2(512),
 DIRECT_PATH_NUM_COLUMNS_LOADED             NUMBER,
 RLS_INFO                                   CLOB,
 KSACL_USER_NAME                            VARCHAR2(128),
 KSACL_SERVICE_NAME                         VARCHAR2(512),
 KSACL_SOURCE_LOCATION                      VARCHAR2(48),
 CON_ID                                     NUMBER
 )
 LOB (SQL_TEXT, SQL_BINDS, RLS_INFO) STORE AS(TABLESPACE SYSAUX)
 PARTITION BY RANGE (EVENT_TIMESTAMP) INTERVAL(INTERVAL '1' MONTH)
 (PARTITION aud_unified_p0 VALUES LESS THAN
 (TO_TIMESTAMP('2014-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
 TABLESPACE SYSAUX) TABLESPACE SYSAUX;

-- Turns on partition check --
alter session set events  '14524 trace name context off';

comment on table AUDSYS.AUD$UNIFIED is
'Unified Audit internal table, which holds the unified audit records'
/

grant read on sys.gv_$unified_audit_trail to audsys;
grant read on sys.all_unified_audit_actions to PUBLIC;

Rem Project 46892
Rem UNIFIED_AUDIT_TRAIL is now UNION ALL on gv$unified_audit_trail and
Rem new relational table AUDSYS.AUD$UNIFIED

remark
remark  FAMILY "UNIFIED AUDIT FACILITY VIEW"
remark
create or replace view AUDSYS.UNIFIED_AUDIT_TRAIL
        (
         AUDIT_TYPE,
         SESSIONID,
         PROXY_SESSIONID,
         OS_USERNAME,
         USERHOST,
         TERMINAL,
         INSTANCE_ID,
         DBID,
         AUTHENTICATION_TYPE,
         DBUSERNAME,
         DBPROXY_USERNAME,
         EXTERNAL_USERID,
         GLOBAL_USERID,
         CLIENT_PROGRAM_NAME,
         DBLINK_INFO,
         XS_USER_NAME,
         XS_SESSIONID,
         ENTRY_ID,
         STATEMENT_ID,
         EVENT_TIMESTAMP,
         ACTION_NAME,
         RETURN_CODE,
         OS_PROCESS,
         TRANSACTION_ID,
         SCN,
         EXECUTION_ID,
         OBJECT_SCHEMA,
         OBJECT_NAME,
         SQL_TEXT,
         SQL_BINDS,
         APPLICATION_CONTEXTS,
         CLIENT_IDENTIFIER,
         NEW_SCHEMA,
         NEW_NAME,
         OBJECT_EDITION,
         SYSTEM_PRIVILEGE_USED,
         SYSTEM_PRIVILEGE,
         AUDIT_OPTION,
         OBJECT_PRIVILEGES,
         ROLE,
         TARGET_USER,
         EXCLUDED_USER,
         EXCLUDED_SCHEMA,
         EXCLUDED_OBJECT,
         CURRENT_USER,
         ADDITIONAL_INFO,
         UNIFIED_AUDIT_POLICIES,
         FGA_POLICY_NAME,
         XS_INACTIVITY_TIMEOUT,
         XS_ENTITY_TYPE,
         XS_TARGET_PRINCIPAL_NAME,
         XS_PROXY_USER_NAME,
         XS_DATASEC_POLICY_NAME,
         XS_SCHEMA_NAME,
         XS_CALLBACK_EVENT_TYPE,
         XS_PACKAGE_NAME,
         XS_PROCEDURE_NAME,
         XS_ENABLED_ROLE,
         XS_COOKIE,
         XS_NS_NAME,
         XS_NS_ATTRIBUTE,
         XS_NS_ATTRIBUTE_OLD_VAL,
         XS_NS_ATTRIBUTE_NEW_VAL,
         DV_ACTION_CODE,
         DV_ACTION_NAME,
         DV_EXTENDED_ACTION_CODE,
         DV_GRANTEE,
         DV_RETURN_CODE,
         DV_ACTION_OBJECT_NAME,
         DV_RULE_SET_NAME,
         DV_COMMENT,
         DV_FACTOR_CONTEXT,
         DV_OBJECT_STATUS,
         OLS_POLICY_NAME,
         OLS_GRANTEE,
         OLS_MAX_READ_LABEL,
         OLS_MAX_WRITE_LABEL,
         OLS_MIN_WRITE_LABEL,
         OLS_PRIVILEGES_GRANTED,
         OLS_PROGRAM_UNIT_NAME,
         OLS_PRIVILEGES_USED,
         OLS_STRING_LABEL,
         OLS_LABEL_COMPONENT_TYPE,
         OLS_LABEL_COMPONENT_NAME,
         OLS_PARENT_GROUP_NAME,
         OLS_OLD_VALUE,
         OLS_NEW_VALUE,
         RMAN_SESSION_RECID,
         RMAN_SESSION_STAMP,
         RMAN_OPERATION,
         RMAN_OBJECT_TYPE,
         RMAN_DEVICE_TYPE,
         DP_TEXT_PARAMETERS1,
         DP_BOOLEAN_PARAMETERS1,
         DIRECT_PATH_NUM_COLUMNS_LOADED,
         RLS_INFO,
         KSACL_USER_NAME,
         KSACL_SERVICE_NAME,
         KSACL_SOURCE_LOCATION
         )
as
(select  act.component,
         sessionid,
         proxy_sessionid,
         os_user,
         host_name,
         terminal,
         instance_id,
         dbid,
         authentication_type,
         userid,
         proxy_userid,
         external_userid,
         global_userid,
         client_program_name,
         dblink_info,
         xs_user_name,
         xs_sessionid,
         entry_id,
         statement_id,
         cast(event_timestamp as timestamp with local time zone),
         act.name,
         return_code,
         os_process,
         transaction_id,
         scn,
         execution_id,
         obj_owner,
         obj_name,
         sql_text,
         sql_binds,
         application_contexts,
         client_identifier,
         new_owner,
         new_name,
         object_edition,
         system_privilege_used,
         spx.name,
         aom.name,
         object_privileges,
         role,
         target_user,
         excluded_user,
         excluded_schema,
         excluded_object,
         current_user,
         additional_info,
         unified_audit_policies,
         fga_policy_name,
         xs_inactivity_timeout,
         xs_entity_type,
         xs_target_principal_name,
         xs_proxy_user_name,
         xs_datasec_policy_name,
         xs_schema_name,
         xs_callback_event_type,
         xs_package_name,
         xs_procedure_name,
         xs_enabled_role,
         xs_cookie,
         xs_ns_name,
         xs_ns_attribute,
         xs_ns_attribute_old_val,
         xs_ns_attribute_new_val,
         dv_action_code,
         dv_action_name,
         dv_extended_action_code,
         dv_grantee,
         dv_return_code,
         dv_action_object_name,
         dv_rule_set_name,
         dv_comment,
         dv_factor_context,
         dv_object_status,
         ols_policy_name,
         ols_grantee,
         ols_max_read_label,
         ols_max_write_label,
         ols_min_write_label,
         ols_privileges_granted,
         ols_program_unit_name,
         ols_privileges_used,
         ols_string_label,
         ols_label_component_type,
         ols_label_component_name,
         ols_parent_group_name,
         ols_old_value,
         ols_new_value,
         rman_session_recid,
         rman_session_stamp,
         rman_operation,
         rman_object_type,
         rman_device_type,
         dp_text_parameters1,
         dp_boolean_parameters1,
         direct_path_num_columns_loaded,
         rls_info,
         ksacl_user_name,
         ksacl_service_name,
         ksacl_source_location
from sys.gv_$unified_audit_trail uview, sys.all_unified_audit_actions act,
     sys.system_privilege_map spx, sys.stmt_audit_option_map aom
where   uview.action = act.action   (+)
  and - uview.system_privilege = spx.privilege (+)
  and   uview.audit_option = aom.option#   (+)
  and   uview.audit_type = act.type
UNION ALL
select  act1.component,
         sessionid,
         proxy_sessionid,
         os_user,
         host_name,
         terminal,
         instance_id,
         dbid,
         authentication_type,
         userid,
         proxy_userid,
         external_userid,
         global_userid,
         client_program_name,
         dblink_info,
         xs_user_name,
         xs_sessionid,
         entry_id,
         statement_id,
         cast((from_tz(event_timestamp, '00:00') at local) as timestamp),
         act1.name,
         return_code,
         os_process,
         transaction_id,
         scn,
         execution_id,
         obj_owner,
         obj_name,
         sql_text,
         sql_binds,
         application_contexts,
         client_identifier,
         new_owner,
         new_name,
         object_edition,
         system_privilege_used,
         spx1.name,
         aom1.name,
         object_privileges,
         role,
         target_user,
         excluded_user,
         excluded_schema,
         excluded_object,
         current_user,
         additional_info,
         unified_audit_policies,
         fga_policy_name,
         xs_inactivity_timeout,
         xs_entity_type,
         xs_target_principal_name,
         xs_proxy_user_name,
         xs_datasec_policy_name,
         xs_schema_name,
         xs_callback_event_type,
         xs_package_name,
         xs_procedure_name,
         xs_enabled_role,
         xs_cookie,
         xs_ns_name,
         xs_ns_attribute,
         xs_ns_attribute_old_val,
         xs_ns_attribute_new_val,
         dv_action_code,
         dv_action_name,
         dv_extended_action_code,
         dv_grantee,
         dv_return_code,
         dv_action_object_name,
         dv_rule_set_name,
         dv_comment,
         dv_factor_context,
         dv_object_status,
         ols_policy_name,
         ols_grantee,
         ols_max_read_label,
         ols_max_write_label,
         ols_min_write_label,
         ols_privileges_granted,
         ols_program_unit_name,
         ols_privileges_used,
         ols_string_label,
         ols_label_component_type,
         ols_label_component_name,
         ols_parent_group_name,
         ols_old_value,
         ols_new_value,
         rman_session_recid,
         rman_session_stamp,
         rman_operation,
         rman_object_type,
         rman_device_type,
         dp_text_parameters1,
         dp_boolean_parameters1,
         direct_path_num_columns_loaded,
         rls_info,
         ksacl_user_name,
         ksacl_service_name,
         ksacl_source_location
from audsys.aud$unified auduni, sys.all_unified_audit_actions act1,
     sys.system_privilege_map spx1, sys.stmt_audit_option_map aom1
where   auduni.action = act1.action   (+)
  and - auduni.system_privilege = spx1.privilege (+)
  and   auduni.audit_option = aom1.option#   (+)
  and   auduni.audit_type = act1.type)
/

comment on table AUDSYS.UNIFIED_AUDIT_TRAIL is
'All audit trail entries'
/

create or replace public synonym UNIFIED_AUDIT_TRAIL for AUDSYS.UNIFIED_AUDIT_TRAIL
/
grant read on AUDSYS.UNIFIED_AUDIT_TRAIL to audit_admin
/
grant read on AUDSYS.UNIFIED_AUDIT_TRAIL to audit_viewer
/

comment on column UNIFIED_AUDIT_TRAIL.AUDIT_TYPE is
'Type of the Audit Record'
/
comment on column UNIFIED_AUDIT_TRAIL.SESSIONID is
'Audit Session Identifier of the User session'
/
comment on column UNIFIED_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy Audit Session Identifier in case of Proxy User session'
/
comment on column UNIFIED_AUDIT_TRAIL.OS_USERNAME is
'Operating System logon user name of the user whose actions were audited'
/
comment on column UNIFIED_AUDIT_TRAIL.USERHOST is
'Client host machine name'
/
comment on column UNIFIED_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column UNIFIED_AUDIT_TRAIL.INSTANCE_ID is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column UNIFIED_AUDIT_TRAIL.DBID is
'Database Identifier of the audited database'
/
comment on column UNIFIED_AUDIT_TRAIL.AUTHENTICATION_TYPE is
'Type of Authentication for the session user'
/
comment on column UNIFIED_AUDIT_TRAIL.DBUSERNAME is
'Name of the user whose actions were audited'
/
comment on column UNIFIED_AUDIT_TRAIL.DBPROXY_USERNAME is
'Name of the Proxy User in case of Proxy User sessions'
/
comment on column UNIFIED_AUDIT_TRAIL.EXTERNAL_USERID is
'External Identifier for externally authenticated users'
/
comment on column UNIFIED_AUDIT_TRAIL.GLOBAL_USERID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column UNIFIED_AUDIT_TRAIL.CLIENT_PROGRAM_NAME is
'Client Program Name which issued the commands in user session'
/
comment on column UNIFIED_AUDIT_TRAIL.DBLINK_INFO is
'Value of SYS_CONTEXT(''USERENV'', ''DBLINK_INFO'')'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_USER_NAME is
'Real Application User name'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_SESSIONID is
'Real Application User Session Identifier'
/
comment on column UNIFIED_AUDIT_TRAIL.ENTRY_ID is
'Numeric ID for each audit trail entry in the session'
/
comment on column UNIFIED_AUDIT_TRAIL.STATEMENT_ID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column UNIFIED_AUDIT_TRAIL.EVENT_TIMESTAMP is
'Timestamp of the creation of audit trail entry in session''s time zone'
/
comment on column UNIFIED_AUDIT_TRAIL.ACTION_NAME is
'Name of the action executed by the user'
/
comment on column UNIFIED_AUDIT_TRAIL.RETURN_CODE is
'Oracle error code generated by the action.  Zero if the action succeeded'
/
comment on column UNIFIED_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column UNIFIED_AUDIT_TRAIL.TRANSACTION_ID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column UNIFIED_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column UNIFIED_AUDIT_TRAIL.EXECUTION_ID is
'Execution Context Identifier for each action'
/
comment on column UNIFIED_AUDIT_TRAIL.OBJECT_SCHEMA is
'Schema name of object affected by the action'
/
comment on column UNIFIED_AUDIT_TRAIL.OBJECT_NAME is
'Name of the object affected by the action'
/
comment on column UNIFIED_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column UNIFIED_AUDIT_TRAIL.SQL_BINDS is
'Bind variable data of the query'
/
comment on column UNIFIED_AUDIT_TRAIL.APPLICATION_CONTEXTS is
'SemiColon seperate list of Application Context Namespace, Attribute, Value information in (APPCTX_NSPACE,APPCTX_ATTRIBUTE=<value>) format'
/
comment on column UNIFIED_AUDIT_TRAIL.CLIENT_IDENTIFIER is
'Client identifier in each Oracle session'
/
comment on column UNIFIED_AUDIT_TRAIL.NEW_SCHEMA is
'The schema of the object named in the NEW_NAME column'
/
comment on column UNIFIED_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column UNIFIED_AUDIT_TRAIL.OBJECT_EDITION is
'The edition of the object affected by the action'
/
comment on column UNIFIED_AUDIT_TRAIL.SYSTEM_PRIVILEGE_USED is
'System privilege used to execute the action'
/
comment on column UNIFIED_AUDIT_TRAIL.SYSTEM_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column UNIFIED_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the audit statement'
/
comment on column UNIFIED_AUDIT_TRAIL.OBJECT_PRIVILEGES is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column UNIFIED_AUDIT_TRAIL.ROLE is
'Role granted/revoked/set by a GRANT/REVOKE/SET ROLE statement'
/
comment on column UNIFIED_AUDIT_TRAIL.TARGET_USER is
'User on whom the GRANT/REVOKE/AUDIT/NOAUDIT statement was executed'
/
comment on column UNIFIED_AUDIT_TRAIL.EXCLUDED_USER is
'User who was excluded when the AUDIT/NOAUDIT statement was executed'
/
comment on column UNIFIED_AUDIT_TRAIL.EXCLUDED_SCHEMA is
'Schema of EXCLUDED_OBJECT'
/
comment on column UNIFIED_AUDIT_TRAIL.EXCLUDED_OBJECT is
'Object which was excluded when the SET ROLE/ALTER PLUGGABLE DATABASE statement was executed'
/
comment on column UNIFIED_AUDIT_TRAIL.CURRENT_USER is
'Effective user for the statement execution'
/
comment on column UNIFIED_AUDIT_TRAIL.ADDITIONAL_INFO is
'Text comment on the audit trail entry'
/
comment on column UNIFIED_AUDIT_TRAIL.UNIFIED_AUDIT_POLICIES is
'Unified Audit Policies that caused the audit trail entry'
/
comment on column UNIFIED_AUDIT_TRAIL.FGA_POLICY_NAME is
'Fine-Grained Audit Policy that caused the audit trail entry'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_INACTIVITY_TIMEOUT is
'Inactivity timeout of the Real Application Security session'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_ENTITY_TYPE is
'Type of the Real Application Security entity'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_TARGET_PRINCIPAL_NAME is
'Target principal name in Real Application Security operations'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_PROXY_USER_NAME is
'Real Application Security proxy user'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_DATASEC_POLICY_NAME is
'Real Application Security policy enabled or disabled'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_SCHEMA_NAME is
'Schema in enable, disable Real Application Security policy and global callback'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_CALLBACK_EVENT_TYPE is
'Real Application Security global callback event type'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_PACKAGE_NAME is
'Real Application Security callback package for global callback'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_PROCEDURE_NAME is
'Real Application Security callback procedure for global callback'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_ENABLED_ROLE is
'Enabled Real Application Security role'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_COOKIE is
'Real Application Security session cookie'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_NS_NAME is
'Real Application Security session namespace'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_NS_ATTRIBUTE is
'Real Application Security session namespace attribute'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_NS_ATTRIBUTE_OLD_VAL is
'Old value of the Real Application Security session namespace'
/
comment on column UNIFIED_AUDIT_TRAIL.XS_NS_ATTRIBUTE_NEW_VAL is
'New value of the Real Application Security session namespace'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_ACTION_CODE is
'Numeric action type code for Database Vault'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_ACTION_NAME is
'Name of the action whose numeric code appears in the DV_ACTION_CODE column'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_EXTENDED_ACTION_CODE is
'Numeric action type code for Database Vault administration'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_GRANTEE is
'Name of the user whose Database Vault authorization was modified'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_RETURN_CODE is
'Database Vault specific error code'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_ACTION_OBJECT_NAME is
'The unique name of the Database Vault object that was modified'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_RULE_SET_NAME is
'The unique name of the rule set that was executing and caused the audit event to trigger'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_COMMENT is
'Text comment on the audit trail entry'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_FACTOR_CONTEXT is
'XML document containing Database Vault factor identifiers for the current session'
/
comment on column UNIFIED_AUDIT_TRAIL.DV_OBJECT_STATUS is
'Indicates whether a particular Database Vault object is enabled or disabled'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_POLICY_NAME is
'Oracle Label Security policy for which this audit record is generated'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_GRANTEE is
'User whose OLS authorization was modified'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_MAX_READ_LABEL is
'Maximum read OLS label assigned to a user'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_MAX_WRITE_LABEL is
'Maximum write OLS label assigned to a user'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_MIN_WRITE_LABEL is
'Minimum write OLS label assigned to a user'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_PRIVILEGES_GRANTED is
'OLS privileges assigned to a user or a trusted stored procedure'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_PROGRAM_UNIT_NAME is
'Trusted stored procedure whose authorization was modified or executed'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_PRIVILEGES_USED is
'OLS privileges used for an event'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_STRING_LABEL is
'String representation of the OLS label'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_LABEL_COMPONENT_TYPE is
'Type of the OLS label component'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_LABEL_COMPONENT_NAME is
'Name of the OLS label component'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_PARENT_GROUP_NAME is
'Name of the parent of the OLS group'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_OLD_VALUE is
'Old value for OLS ALTER events'
/
comment on column UNIFIED_AUDIT_TRAIL.OLS_NEW_VALUE is
'New value for OLS ALTER events'
/
comment on column UNIFIED_AUDIT_TRAIL.RMAN_SESSION_RECID is
'RMAN Record Id'
/
comment on column UNIFIED_AUDIT_TRAIL.RMAN_SESSION_STAMP is
'RMAN Session Stamp'
/
comment on column UNIFIED_AUDIT_TRAIL.RMAN_OPERATION is
'RMAN Operation'
/
comment on column UNIFIED_AUDIT_TRAIL.RMAN_OBJECT_TYPE is
'RMAN Object Involved'
/
comment on column UNIFIED_AUDIT_TRAIL.RMAN_DEVICE_TYPE is
'Device Involved in RMAN Session'
/
comment on column UNIFIED_AUDIT_TRAIL.DP_TEXT_PARAMETERS1 is
'Audited DataPump parameters that have text values'
/
comment on column UNIFIED_AUDIT_TRAIL.DP_BOOLEAN_PARAMETERS1 is
'Audited DataPump parameters that have boolean values'
/
comment on column UNIFIED_AUDIT_TRAIL.DIRECT_PATH_NUM_COLUMNS_LOADED is
'Direct Path API load - number of columns loaded'
/
comment on column UNIFIED_AUDIT_TRAIL.RLS_INFO is
'RLS predicates along with the RLS policy names used for the object accessed'
/
comment on column UNIFIED_AUDIT_TRAIL.KSACL_USER_NAME is
'The connecting user name'
/
comment on column UNIFIED_AUDIT_TRAIL.KSACL_SERVICE_NAME is
'The target DB service name'
/
comment on column UNIFIED_AUDIT_TRAIL.KSACL_SOURCE_LOCATION is
'The source location of the initiating connection'
/

execute CDBView.create_cdbview(false, 'AUDSYS', 'UNIFIED_AUDIT_TRAIL','CDB_UNIFIED_AUDIT_TRAIL');
create or replace public synonym CDB_UNIFIED_AUDIT_TRAIL for AUDSYS.CDB_UNIFIED_AUDIT_TRAIL
/
grant read on AUDSYS.CDB_UNIFIED_AUDIT_TRAIL to audit_admin
/
grant read on AUDSYS.CDB_UNIFIED_AUDIT_TRAIL to audit_viewer
/

---------------------------------------------------------------------
--- XS View for audit records: DBA_XS_AUDIT_TRAIL ----------------------
---------------------------------------------------------------------

create or replace view sys.vw_x$aud_xs_actions container_data
(ADDR, INDX, INST_ID, CON_ID, ACTION_NAME) as select
ADDR, INDX, INST_ID, CON_ID, ACTION_NAME from sys.x$aud_xs_actions;

grant read on sys.vw_x$aud_xs_actions to audsys;
grant read on sys.dba_xs_audit_policy_options to audsys;

create or replace view AUDSYS.DBA_XS_AUDIT_TRAIL
(
  USERID,
  ACTION,
  ACTION_NAME,
  OBJ_OWNER,
  OBJ_NAME,
  RETURN_CODE,
  XS_USER_NAME,
  XS_SESSIONID,
  XS_INACTIVITY_TIMEOUT,
  XS_ENTITY_TYPE,
  XS_TARGET_PRINCIPAL_NAME,
  XS_PROXY_USER_NAME,
  XS_DATASEC_POLICY_NAME,
  XS_SCHEMA_NAME,
  XS_CALLBACK_EVENT_TYPE,
  XS_PACKAGE_NAME,
  XS_PROCEDURE_NAME,
  XS_ENABLED_ROLE,
  XS_COOKIE,
  XS_NS_NAME,
  XS_NS_ATTRIBUTE,
  XS_NS_ATTRIBUTE_OLD_VAL,
  XS_NS_ATTRIBUTE_NEW_VAL,
  EVENT_TIMESTAMP
)
as
select audtrail.dbusername, xsacts.indx, xsacts.action_name,
       audtrail.object_schema, audtrail.object_name, audtrail.return_code,
       audtrail.xs_user_name, audtrail.xs_sessionid,
       audtrail.xs_inactivity_timeout, audtrail.xs_entity_type,
       audtrail.xs_target_principal_name, audtrail.xs_proxy_user_name,
       audtrail.xs_datasec_policy_name, audtrail.xs_schema_name,
       audtrail.xs_callback_event_type, audtrail.xs_package_name,
       audtrail.xs_procedure_name, audtrail.xs_enabled_role,
       audtrail.xs_cookie, audtrail.xs_ns_name, audtrail.xs_ns_attribute,
       audtrail.xs_ns_attribute_old_val, audtrail.xs_ns_attribute_new_val,
       audtrail.event_timestamp
from audsys.unified_audit_trail audtrail, sys.vw_x$aud_xs_actions xsacts,
     sys.dba_xs_audit_policy_options xspol
where (xspol.policy_name = 'ORA_RAS_SESSION_MGMT'
      OR xspol.policy_name = 'ORA_RAS_POLICY_MGMT')
      and audtrail.action_name = xsacts.action_name
      and xsacts.action_name = xspol.audit_option
      and audtrail.audit_type = 'XS'
order by event_timestamp
/

comment on table AUDSYS.DBA_XS_AUDIT_TRAIL is
'Describes all XS related audit records'
/

create or replace public synonym DBA_XS_AUDIT_TRAIL for AUDSYS.DBA_XS_AUDIT_TRAIL
/
grant read on AUDSYS.DBA_XS_AUDIT_TRAIL to AUDIT_ADMIN;
grant read on AUDSYS.DBA_XS_AUDIT_TRAIL to AUDIT_VIEWER;

comment on column DBA_XS_AUDIT_TRAIL.USERID is
'Name of the user whose actions were audited'
/

comment on column DBA_XS_AUDIT_TRAIL.ACTION is
'Numeric audit trail action type code'
/

comment on column DBA_XS_AUDIT_TRAIL.ACTION_NAME is
'Name of the audit option'
/

comment on column DBA_XS_AUDIT_TRAIL.OBJ_OWNER is
'Owner of the object affected by the action'
/

comment on column DBA_XS_AUDIT_TRAIL.OBJ_NAME is
'Name of the object affected by the action'
/

comment on column DBA_XS_AUDIT_TRAIL.RETURN_CODE is
'Oracle error code generated by the action'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_USER_NAME is
'Name of the XS user'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_SESSIONID is
'Identifer of the XS session'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_INACTIVITY_TIMEOUT is
'Inactivity timeout of the XS session'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_ENTITY_TYPE is
'Type of the XS entity. Possible values are USER,ROLE,
 ROLESET, SECURITYCLASS, ACL, DATASECURITY and NSTEMPLATE'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_TARGET_PRINCIPAL_NAME is
'Target principal name in XS operations. Possible operations are 
set verifier, set password, add proxy, remove proxy,
switch user, assign user, create session, grant roles'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_PROXY_USER_NAME is
'Name of the XS proxy user'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_DATASEC_POLICY_NAME is
'Name of the XS data security policy enabled or disabled'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_SCHEMA_NAME is
'Name of the schema in enable, disable data security and global callback operation'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_CALLBACK_EVENT_TYPE is
'XS global callback event type'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_PACKAGE_NAME is
'XS callback package name for the global callback'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_PROCEDURE_NAME is
'XS callback procedure name for the global callback'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_ENABLED_ROLE is
'The role that is enabled'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_COOKIE is
'XS session cookie'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_NS_NAME is
'Name of XS session namespace'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_NS_ATTRIBUTE is
'Name of XS session namespace attribute'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_NS_ATTRIBUTE_OLD_VAL is
'The old value of XS session namespace attribute'
/

comment on column DBA_XS_AUDIT_TRAIL.XS_NS_ATTRIBUTE_NEW_VAL is
'The new value of XS session namespace attribute'
/

comment on column DBA_XS_AUDIT_TRAIL.EVENT_TIMESTAMP is
'Timestamp of audit record'
/

execute SYS.CDBView.create_cdbview(false,'AUDSYS','DBA_XS_AUDIT_TRAIL','CDB_XS_AUDIT_TRAIL');
create or replace public synonym CDB_XS_AUDIT_TRAIL for audsys.CDB_XS_AUDIT_TRAIL;
grant read on AUDSYS.CDB_XS_AUDIT_TRAIL to AUDIT_ADMIN;
grant read on AUDSYS.CDB_XS_AUDIT_TRAIL to AUDIT_VIEWER;

Rem Proj 35931: DBMS_AUDIT_UTIL
@@dbmsaudutl.sql

-- Bug 25245797: Following privileges are required to be granted to AUDSYS
-- for the successful redefinition of DBMS_AUDIT_MGMT package under AUDSYS

grant read on sys.v_$database to audsys;
grant read on sys.v_$containers to audsys;
grant read on sys.gv_$instance to audsys;
grant read on sys.v_$option to audsys;
grant read on sys.v_$instance to audsys;
grant read on sys.v_$version to audsys;

grant insert on SYS.DAM_LAST_ARCH_TS$ to audsys;
grant delete on SYS.DAM_LAST_ARCH_TS$ to audsys;
grant update on SYS.DAM_LAST_ARCH_TS$ to audsys;
grant insert on SYS.DAM_CONFIG_PARAM$ to audsys;
grant update on SYS.DAM_CONFIG_PARAM$ to audsys;
grant delete on SYS.DAM_CONFIG_PARAM$ to audsys;
grant update on SYS.DAM_CLEANUP_JOBS$ to audsys;
grant delete on SYS.DAM_CLEANUP_JOBS$ to audsys;
grant insert on SYS.DAM_CLEANUP_JOBS$ to audsys;

grant execute on sys.dbms_session to audsys;
grant execute on sys.dbms_assert to audsys;
grant execute on sys.DBMS_SQL to audsys;
grant execute on sys.DBMS_INTERNAL_LOGSTDBY to audsys;
grant execute on sys.DBMS_PDB_EXEC_SQL to audsys;
grant execute on SYS.DBMS_LOCK to audsys;
grant execute on SYS.DBMS_STATS to audsys;
grant execute on SYS.DBMS_SCHEDULER to audsys;

grant alter session to audsys;
grant analyze any dictionary to audsys;
grant select any dictionary to audsys;
grant create job to audsys;
grant set container to audsys;

@?/rdbms/admin/sqlsessend.sql
