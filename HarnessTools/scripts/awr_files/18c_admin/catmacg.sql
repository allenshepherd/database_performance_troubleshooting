Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem    NAME
Rem      catmacg.sql
Rem    DESCRIPTION
Rem      data vault support script
Rem    NOTES
Rem      Must be compiled after dbms_output package.
Rem      Found on asktom.oracle.com
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacg.sql
Rem SQL_PHASE: CATMACG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    amunnoli  02/28/17 - Bug 25245797:DV unified audit views moved to AUDSYS
Rem    qinwu     02/22/17 - proj 70151: support db capture and replay auth
Rem    risgupta  01/27/17 - Proj 67579: Grant to DV_ADMIN the EXECUTE
Rem                         privilege on nested table datatypes
Rem    dalpern   11/29/16 - rti 19892854: DBA_DV_DEBUG_CONNECT_AUTH SYNONYM
Rem    dalpern   10/15/16 - bug 22665467: add DV checks on DEBUG [CONNECT]
Rem    yanchuan  03/16/16 - Bug 20505982: Grant to SYS
Rem                         the Execute privilege on CONFIGURE_DV_INTERNAL
Rem    yapli     03/02/16 - Bug 22840314: Change training api to simulation
Rem    youyang   02/15/16 - bug22672722:add index function
Rem    jibyun    02/01/16 - Bug 22296366: qualify objects referenced internally
Rem                         and create public synonyms for DVSYS objects
Rem    yapli     01/14/16 - Bug 22226617: change to grant READ on sys objects
Rem    jibyun    11/01/15 - introduce DIAGNOSTIC authorization
Rem    yanchuan  07/27/15 - Bug 21299533: support for Database Vault
Rem                         Authorization
Rem    sanbhara  06/02/15 - Bug 21158282 - adding ku$_dv_comm_rule_alts_v.
Rem    namoham   12/14/14 - Project 36761: support maintenance authorization
Rem    kaizhuan  11/21/14 - Project 46812: Support command rule fine grained
Rem                         level protection for ALTER SYSTEM/SESSION
Rem    jibyun    11/17/14 - Project 46812: support TRAINING mode
Rem    jibyun    08/06/14 - Project 46812: support for Database Vault policy
Rem    namoham   07/07/14 - Bug 19127377: grant select on preprocessor view
Rem    aketkar   04/29/14 - sql patch metadata seed
Rem    namoham   12/16/13 - Bug 17969287: grant select on dvsys.dba_dv_status 
Rem                         to sys
Rem    kaizhuan  09/23/13 - Bug 17342864: remove grants on tables 
Rem                         and views which are dropped.
Rem    namoham   07/24/13 - Bug 15938449: grant select on two views
Rem                         Bug 15988264: add public synonym 
Rem    yanchuan  08/22/12 - bug 14456083: create and grant necessary
Rem                         role/privileges to provide DV protection support
Rem                         for transportable Datapump operations
Rem    sanbhara  07/19/12 - Bug 14306557 - adding grants on view
Rem                         dba_dv_patch_admin_audit.
Rem    jibyun    05/01/12 - Bug 14015928: grant EXECUTE on dbms_macutl to
Rem                         DV_ADMIN, instead of PUBLIC
Rem    youyang   03/13/12 - bug10088587:add DDL authorization
Rem    jibyun    03/12/12 - Bug 13728213: add disable_dv_dictionary_accts,
Rem                         enable_dv_dictionary_accts
Rem    jibyun    03/15/12 - Bug 5918695: introduce DV_AUDIT_CLEANUP role
Rem    youyang   01/18/12 - add grants on dba_dv_proxy_auth
Rem    sanbhara  10/14/11 - grant select on DV auditing views to DV_SECANALYST
Rem                         and DV_MONITOR.
Rem    jibyun    07/27/11 - Bug 7118790: grant select on dba_dv_oradebug to
Rem                         DV_MONITOR and DV_SECANALYST
Rem    sanbhara  07/20/11 - Project 24121 - removing grant of DV_PUBLIC to
Rem                         PUBLIC.
Rem    youyang   05/14/11 - remove dvsys.is_rls_authorized_by_realm
Rem    sanbhara  04/29/11 - Project 24121 - Removing dependency on DV_PUBLIC.
Rem    jibyun    04/13/11 - Bug 12356827: Add DV_GOLDENGATE_REDO_ACCESS role to
Rem                         control Golden Gate OCI API for redo access
Rem    jibyun    02/18/11 - Bug 11662436: Add DV_XSTREAM_ADMIN role for
Rem                         XSTREAM capture under Database Vault
Rem    jibyun    02/10/11 - Bug 11662436: Add DV_GOLDENGATE_ADMIN role for 
Rem                         Golden Gate Extract under Database Vault
Rem    jheng     12/04/10 - add grant on dba_dv_datapump_auth
Rem    jheng     02/18/09 - Grant select on dba_dv_job_auth to dv_secanalyst
Rem    clei      12/10/08 - DV_PATCH -> DV_PATCH_ADMIN
Rem    jibyun    05/09/08 - Bug 7550987: Create DV_STREAMS_ADMIN role
Rem    jibyun    10/18/08 - Bug 7489862: Add admin option to the grants of
Rem                         dv_admin, dv_secanalyst, dv_public to dv_owner
Rem    jsamuel   10/28/08 - remove error messages
Rem    ruparame  08/18/08 - Bug 7319691: Create DV_MONITOR role
Rem    clei      08/28/08 - bug 6435192: add dv_patch role
Rem    pknaggs   07/07/08 - bug 6938028: add Factor and Role support for DVPS.
Rem    youyang   05/22/08 - Bug fix:7022650, update dv_secanalyst role to read
Rem                         the dvsys.audit_trail$ table
Rem    pknaggs   04/11/08 - bug 6938028: Database Vault protected schema.
Rem    jibyun    10/31/07 - To fix Bug 6441524
Rem    jciminsk  05/02/06 - cleanup embedded file boilerplate 
Rem    jciminsk  05/02/06 - created admin/catmacg.sql 
Rem    sgaetjen  08/11/05 - sgaetjen_dvschema
Rem    sgaetjen  08/05/05 - Merge into ADE with Protected Schema 
Rem    sgaetjen  07/28/05 - dos2unix
Rem    raustin   01/31/05 - Created spec


@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW DVSYS.dv$out
AS
SELECT ROWNUM lineno, dvsys.dbms_macout.get_line( ROWNUM ) text
   FROM sys.all_objects
  WHERE ROWNUM < ( SELECT dvsys.dbms_macout.get_line_count FROM sys.dual );



Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates DV roles 
Rem
Rem
Rem
Rem
Rem

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_secanalyst';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_monitor';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_owner';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_acctmgr';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_public';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_patch_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN    
EXECUTE IMMEDIATE 'CREATE ROLE dv_streams_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE; 
     END IF;
END;   
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_goldengate_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_xstream_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_goldengate_redo_access';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_audit_cleanup';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_datapump_network_link';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_policy_owner';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants to PUBLIC for DVSYS functions
Rem
Rem
Rem
Rem

-- procedures and functions
GRANT EXECUTE ON dvsys.get_factor TO PUBLIC
/
GRANT EXECUTE ON dvsys.get_factor_label TO PUBLIC
/
GRANT EXECUTE ON dvsys.set_factor TO PUBLIC
/
GRANT EXECUTE ON dvsys.get_trust_level TO PUBLIC
/
GRANT EXECUTE ON dvsys.get_trust_level_for_identity TO PUBLIC
/
GRANT EXECUTE ON dvsys.role_is_enabled TO PUBLIC
/
GRANT EXECUTE ON dvsys.predicate_true TO PUBLIC
/
GRANT EXECUTE ON dvsys.is_secure_application_role TO PUBLIC
/
-- packages
GRANT EXECUTE ON dvsys.dbms_macsec_roles TO PUBLIC
/
GRANT EXECUTE ON dvsys.dbms_macols_session TO PUBLIC
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates  PUBLIC synonyms for DVSYS objects
Rem
Rem
Rem
Rem

-- packages
CREATE OR REPLACE PUBLIC SYNONYM dbms_macadm FOR dvsys.dbms_macadm
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_macsec_roles FOR dvsys.dbms_macsec_roles
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_macutl FOR dvsys.dbms_macutl
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_macols_session for dvsys.dbms_macols_session
/

-- procedures and functions
CREATE OR REPLACE PUBLIC SYNONYM get_factor FOR dvsys.get_factor
/
CREATE OR REPLACE PUBLIC SYNONYM get_factor_label FOR dvsys.get_factor_label
/
CREATE OR REPLACE PUBLIC SYNONYM set_factor FOR dvsys.set_factor
/
CREATE OR REPLACE PUBLIC SYNONYM get_trust_level FOR dvsys.get_trust_level
/
CREATE OR REPLACE PUBLIC SYNONYM get_trust_level_for_identity FOR dvsys.get_trust_level_for_identity
/
CREATE OR REPLACE PUBLIC SYNONYM role_is_enabled FOR dvsys.role_is_enabled
/
CREATE OR REPLACE PUBLIC SYNONYM is_secure_application_role FOR dvsys.is_secure_application_role
/
CREATE OR REPLACE PUBLIC SYNONYM dv_database_name FOR dvsys.dv_database_name
/
CREATE OR REPLACE PUBLIC SYNONYM dv_dict_obj_name FOR dvsys.dv_dict_obj_name
/
CREATE OR REPLACE PUBLIC SYNONYM dv_dict_obj_owner FOR dvsys.dv_dict_obj_owner
/
CREATE OR REPLACE PUBLIC SYNONYM dv_dict_obj_type FOR dvsys.dv_dict_obj_type
/
CREATE OR REPLACE PUBLIC SYNONYM dv_instance_num FOR dvsys.dv_instance_num
/
CREATE OR REPLACE PUBLIC SYNONYM dv_job_invoker FOR dvsys.dv_job_invoker
/
CREATE OR REPLACE PUBLIC SYNONYM dv_job_owner FOR dvsys.dv_job_owner
/
CREATE OR REPLACE PUBLIC SYNONYM dv_login_user FOR dvsys.dv_login_user
/
CREATE OR REPLACE PUBLIC SYNONYM dv_sql_text FOR dvsys.dv_sql_text
/
CREATE OR REPLACE PUBLIC SYNONYM dv_sysevent FOR dvsys.dv_sysevent
/

-- views
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_auth FOR dvsys.dba_dv_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_code FOR dvsys.dba_dv_code
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_command_rule FOR dvsys.dba_dv_command_rule
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_command_rule_id FOR dvsys.dba_dv_command_rule_id
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_datapump_auth FOR dvsys.dba_dv_datapump_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_ddl_auth FOR dvsys.dba_dv_ddl_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_debug_connect_auth FOR dvsys.dba_dv_debug_connect_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_diagnostic_auth FOR dvsys.dba_dv_diagnostic_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_dictionary_accts FOR dvsys.dba_dv_dictionary_accts
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_factor FOR dvsys.dba_dv_factor
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_factor_link FOR dvsys.dba_dv_factor_link
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_factor_type FOR dvsys.dba_dv_factor_type
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_identity FOR dvsys.dba_dv_identity
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_identity_map FOR dvsys.dba_dv_identity_map
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_job_auth FOR dvsys.dba_dv_job_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_mac_policy FOR dvsys.dba_dv_mac_policy
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_mac_policy_factor FOR dvsys.dba_dv_mac_policy_factor
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_maintenance_auth FOR dvsys.dba_dv_maintenance_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_oradebug FOR dvsys.dba_dv_oradebug
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_patch_admin_audit FOR dvsys.dba_dv_patch_admin_audit
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_policy FOR dvsys.dba_dv_policy
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_policy_label FOR dvsys.dba_dv_policy_label
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_policy_object FOR dvsys.dba_dv_policy_object
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_policy_owner FOR dvsys.dba_dv_policy_owner
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_preprocessor_auth FOR dvsys.dba_dv_preprocessor_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_proxy_auth FOR dvsys.dba_dv_proxy_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_pub_privs FOR dvsys.dba_dv_pub_privs
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_realm FOR dvsys.dba_dv_realm
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_realm_auth FOR dvsys.dba_dv_realm_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_realm_object FOR dvsys.dba_dv_realm_object
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_role FOR dvsys.dba_dv_role
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_rule FOR dvsys.dba_dv_rule
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_rule_set FOR dvsys.dba_dv_rule_set
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_rule_set_rule FOR dvsys.dba_dv_rule_set_rule
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_simulation_log FOR dvsys.dba_dv_simulation_log
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_tts_auth FOR dvsys.dba_dv_tts_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_user_privs FOR dvsys.dba_dv_user_privs
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_user_privs_all FOR dvsys.dba_dv_user_privs_all
/
CREATE OR REPLACE PUBLIC SYNONYM dv_admin_grantees FOR dvsys.dv_admin_grantees
/
CREATE OR REPLACE PUBLIC SYNONYM dv_audit_cleanup_grantees FOR dvsys.dv_audit_cleanup_grantees
/
CREATE OR REPLACE PUBLIC SYNONYM dv_monitor_grantees FOR dvsys.dv_monitor_grantees
/
CREATE OR REPLACE PUBLIC SYNONYM dv_owner_grantees FOR dvsys.dv_owner_grantees
/
CREATE OR REPLACE PUBLIC SYNONYM dv_secanalyst_grantees FOR dvsys.dv_secanalyst_grantees
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_dbcapture_auth FOR dvsys.dba_dv_dbcapture_auth
/
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_dbreplay_auth FOR dvsys.dba_dv_dbreplay_auth
/


-- SYS objects
CREATE OR REPLACE PUBLIC SYNONYM configure_dv FOR sys.configure_dv
/
CREATE OR REPLACE PUBLIC SYNONYM cdb_dv_status FOR sys.cdb_dv_status
/
-- Bug 15988264
CREATE OR REPLACE PUBLIC SYNONYM dba_dv_status FOR sys.dba_dv_status
/


Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for DVSYS Administration role (DV_ADMIN)
Rem
Rem
Rem
Rem
Rem

-- give the manager table and view access
GRANT dv_secanalyst TO dv_admin
/

-- packages
-- we only want them to be able to use the API for CRUD
-- the triggers use the rest of these packages
-- the dbms_macsec_roles is granted to public
GRANT EXECUTE ON dvsys.dbms_macadm TO dv_admin
/

GRANT EXECUTE ON dvsys.dbms_macout TO dv_admin
/
GRANT EXECUTE ON dvsys.dbms_macutl TO dv_admin
/
GRANT SELECT ON dvsys.dv$out TO dv_admin
/

-- tables need to remove dep. in UI for views and can remove these
GRANT SELECT ON dvsys.code$ TO dv_admin;
GRANT SELECT ON dvsys.code_t$ TO dv_admin;
GRANT SELECT ON dvsys.command_rule$ TO dv_admin;
GRANT SELECT ON dvsys.factor$ TO dv_admin;
GRANT SELECT ON dvsys.factor_t$ TO dv_admin;
GRANT SELECT ON dvsys.factor_link$ TO dv_admin;
GRANT SELECT ON dvsys.factor_type$ TO dv_admin;
GRANT SELECT ON dvsys.factor_type_t$ TO dv_admin;
GRANT SELECT ON dvsys.identity$ TO dv_admin;
GRANT SELECT ON dvsys.identity_map$ TO dv_admin;
GRANT SELECT ON dvsys.mac_policy$ TO dv_admin;
GRANT SELECT ON dvsys.mac_policy_factor$ TO dv_admin;
GRANT SELECT ON dvsys.policy_label$ TO dv_admin;
GRANT SELECT ON dvsys.realm$ TO dv_admin;
GRANT SELECT ON dvsys.realm_t$ TO dv_admin;
GRANT SELECT ON dvsys.realm_auth$ TO dv_admin;
GRANT SELECT ON dvsys.realm_object$ TO dv_admin;
GRANT SELECT ON dvsys.role$ TO dv_admin;
GRANT SELECT ON dvsys.rule$ TO dv_admin;
GRANT SELECT ON dvsys.rule_t$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set_t$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set_rule$ TO dv_admin;
GRANT SELECT ON dvsys.dv_auth$ to dv_admin;
GRANT SELECT ON dvsys.dv$policy to dv_admin;
GRANT SELECT ON dvsys.policy$ to dv_admin;
GRANT SELECT ON dvsys.policy_t$ to dv_admin;
GRANT SELECT ON dvsys.policy_object$ to dv_admin;
GRANT SELECT ON dvsys.policy_owner$ to dv_admin;
GRANT SELECT ON dvsys.simulation_log$ to dv_admin;
GRANT DELETE ON dvsys.simulation_log$ to dv_admin;
GRANT SELECT ON dvsys.dba_dv_simulation_log to dv_admin;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants for DV roles (DV_OWNER,DV_SECANALYST) on DV objects
Rem
Rem
Rem
Rem
Rem

-- DV_MONITOR
GRANT READ ON sys.gv_$code_clause TO dv_monitor;
GRANT READ ON sys.v_$code_clause TO dv_monitor;
GRANT SELECT ON dvsys.audit_trail$ TO dv_monitor;
GRANT SELECT ON dvsys.dv$enforcement_audit TO dv_monitor;
GRANT SELECT ON dvsys.dv$configuration_audit TO dv_monitor;
GRANT SELECT ON dvsys.dv$realm_auth TO dv_monitor;
GRANT SELECT ON dvsys.dv$rule_set TO dv_monitor;
GRANT SELECT ON dvsys.dv$rule_set_rule TO dv_monitor;
GRANT SELECT ON dvsys.dv$realm_object TO dv_monitor;
GRANT SELECT ON dvsys.dv$sys_grantee TO dv_monitor;
GRANT SELECT ON dvsys.dv$sys_object_owner TO dv_monitor;
GRANT SELECT ON dvsys.dv$command_rule TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_code TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_command_rule TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_job_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_datapump_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_tts_auth TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_oradebug to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_proxy_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_ddl_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_preprocessor_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_maintenance_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_diagnostic_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_debug_connect_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_dictionary_accts to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_patch_admin_audit to dv_monitor;
GRANT SELECT ON dvsys.dv$policy TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_policy to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_policy_object to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_policy_owner to dv_monitor;
-- Bug 15938449
GRANT SELECT on dvsys.event_status to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_index_function to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_dbcapture_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_dbreplay_auth to dv_monitor;

-- DV_SECANALYST
GRANT READ ON sys.gv_$code_clause TO dv_secanalyst;
GRANT READ ON sys.v_$code_clause TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_job_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_datapump_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_tts_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_oradebug to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_proxy_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_ddl_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_preprocessor_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_maintenance_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_diagnostic_auth to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_debug_connect_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_dictionary_accts to dv_secanalyst;
GRANT SELECT ON dvsys.audit_trail$ TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$enforcement_audit TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$configuration_audit TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_code TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor_link TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor_type TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_identity TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_identity_map TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_mac_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_mac_policy_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_role TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule_set TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule_set_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_user_privs TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_pub_privs TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_user_privs_all TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$code TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor_link TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor_type TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$identity TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$identity_map TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$mac_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$mac_policy_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$ols_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$ols_policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$role TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule_set TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule_set_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_grantee TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_object_owner TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_patch_admin_audit to dv_secanalyst;
GRANT SELECT ON dvsys.dv$policy to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_policy to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_policy_object to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_policy_owner to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_command_rule_id TO dv_secanalyst;
-- Bug 15938449
GRANT SELECT on dvsys.event_status to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_index_function to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_dbcapture_auth to dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_dbreplay_auth to dv_secanalyst;

-- DV_AUDIT_CLEANUP
GRANT SELECT ON dvsys.audit_trail$ TO dv_audit_cleanup;
GRANT DELETE ON dvsys.audit_trail$ TO dv_audit_cleanup;
GRANT SELECT ON dvsys.dv$enforcement_audit TO dv_audit_cleanup;
GRANT DELETE ON dvsys.dv$enforcement_audit TO dv_audit_cleanup;
GRANT SELECT ON dvsys.dv$configuration_audit TO dv_audit_cleanup;
GRANT DELETE ON dvsys.dv$configuration_audit TO dv_audit_cleanup;

-- DV_DATAPUMP_NETWORK_LINK
GRANT EXECUTE ON dvsys.check_full_dvauth TO dv_datapump_network_link;
GRANT EXECUTE ON dvsys.check_ts_dvauth TO dv_datapump_network_link;
GRANT EXECUTE ON dvsys.check_tab_dvauth TO dv_datapump_network_link;

-- DV_POLICY_OWNER
GRANT EXECUTE ON dvsys.dbms_macadm TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_policy TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_policy_object TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_realm TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_realm_auth TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_realm_object TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_command_rule TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_rule_set TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_rule TO dv_policy_owner;
GRANT SELECT ON dvsys.policy_owner_rule_set_rule TO dv_policy_owner;

-- DV_OWNER
-- give the manager table and view access and execute privs that the DV administrator role has
GRANT dv_admin TO dv_owner with admin option;
GRANT dv_patch_admin to dv_owner with admin option;
GRANT dv_streams_admin to dv_owner with admin option;
GRANT dv_secanalyst TO dv_owner with admin option;
GRANT dv_public TO dv_owner with admin option;
GRANT dv_monitor to dv_owner with admin option;
GRANT dv_goldengate_admin to dv_owner with admin option;
GRANT dv_xstream_admin to dv_owner with admin option;
GRANT dv_goldengate_redo_access to dv_owner with admin option;
GRANT dv_audit_cleanup to dv_owner with admin option;
GRANT dv_datapump_network_link to dv_owner with admin option;
GRANT dv_policy_owner to dv_owner with admin option;

-- The SELECT privilege on the Datapump views needs to be granted 
-- to the dv_owner, for macsys to be able to use Datapump to export 
-- the Protected Schema.
--
grant SELECT on dvsys.ku$_dv_realm_view             to dv_owner;
grant SELECT on dvsys.ku$_dv_realm_member_view      to dv_owner;
grant SELECT on dvsys.ku$_dv_realm_auth_view        to dv_owner;
grant SELECT on dvsys.ku$_dv_isr_view               to dv_owner;
grant SELECT on dvsys.ku$_dv_isrm_view              to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_view              to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_set_view          to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_set_member_view   to dv_owner;
grant SELECT on dvsys.ku$_dv_command_rule_view      to dv_owner;
grant SELECT on dvsys.ku$_dv_comm_rule_alts_v       to dv_owner;
grant SELECT on dvsys.ku$_dv_role_view              to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_view            to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_link_view       to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_type_view       to dv_owner;
grant SELECT on dvsys.ku$_dv_identity_view          to dv_owner;
grant SELECT on dvsys.ku$_dv_identity_map_view      to dv_owner;
grant SELECT on dvsys.ku$_dv_policy_v               to dv_owner;
grant SELECT on dvsys.ku$_dv_policy_obj_r_v         to dv_owner;
grant SELECT on dvsys.ku$_dv_policy_obj_c_v         to dv_owner;
grant SELECT on dvsys.ku$_dv_policy_obj_c_alts_v    to dv_owner;
grant SELECT on dvsys.ku$_dv_policy_owner_v         to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_dp_v              to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_tts_v             to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_job_v             to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_proxy_v           to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_ddl_v             to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_prep_v            to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_maint_v           to dv_owner;
grant SELECT on dvsys.ku$_dv_oradebug_v             to dv_owner;
grant SELECT on dvsys.ku$_dv_accts_v                to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_diag_v            to dv_owner;
grant SELECT on dvsys.ku$_dv_index_func_v           to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_dbcapture_v       to dv_owner;
grant SELECT on dvsys.ku$_dv_auth_dbreplay_v        to dv_owner;

-- As Streams APIs (MAINTAIN_*) use Datapump during instantiation,
-- DV_STREAMS_ADMIN need to have access to these views.
grant SELECT on dvsys.ku$_dv_realm_view             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_realm_member_view      to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_realm_auth_view        to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_isr_view               to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_isrm_view              to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_view              to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_set_view          to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_set_member_view   to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_command_rule_view      to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_comm_rule_alts_v       to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_role_view              to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_view            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_link_view       to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_type_view       to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_identity_view          to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_identity_map_view      to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_policy_v               to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_policy_obj_r_v         to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_policy_obj_c_v         to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_policy_obj_c_alts_v    to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_policy_owner_v         to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_dp_v              to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_tts_v             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_job_v             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_proxy_v           to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_ddl_v             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_prep_v            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_maint_v           to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_oradebug_v             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_accts_v                to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_diag_v            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_index_func_v           to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_dbcapture_v       to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_auth_dbreplay_v        to dv_streams_admin;

--Grant select on the Auditing views
-- Bug 25245797: DV unified audit views are moved under AUDSYS schema
GRANT READ ON AUDSYS.dv$enforcement_audit TO AUDIT_VIEWER, AUDIT_ADMIN, DV_SECANALYST, DV_MONITOR;
GRANT READ ON AUDSYS.dv$configuration_audit TO AUDIT_VIEWER, AUDIT_ADMIN, DV_SECANALYST, DV_MONITOR;

-- Bug 15988264
GRANT SELECT ON dvsys.dba_dv_status TO select_catalog_role;

-- Manually grant select on dvsys.dba_dv_status to sys
-- This manual step is required as catmacg script is run by sys and sys cannot
-- grant a privilege to itself using GRANT statement.
BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#) VALUES ((SELECT obj# FROM sys.obj$ WHERE name = ''DBA_DV_STATUS'' AND owner# = 1279990 AND type# = 4), 1279990, 0, 9, sys.object_grant.nextval)';
    EXCEPTION
      WHEN OTHERS THEN
      IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
      ELSE RAISE;
      END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO sys.objauth$ (obj#, grantor#, grantee#, privilege#, sequence#) VALUES ((SELECT obj# FROM sys.obj$ WHERE name = ''CONFIGURE_DV_INTERNAL'' AND owner# = 1279990 AND type# = 9), 1279990, 0, 12, sys.object_grant.nextval)';
    EXCEPTION
      WHEN OTHERS THEN
      IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
      ELSE RAISE;
      END IF;
END;
/

-- Proj 67579: Grant EXECUTE ON nested table types.
GRANT EXECUTE ON DVSYS.PLSQL_STACK_ARRAY TO DV_ADMIN;
GRANT EXECUTE ON DVSYS.SIMULATION_IDS TO DV_ADMIN;
GRANT EXECUTE ON DVSYS.DV_OBJ_NAME TO DV_ADMIN;

@?/rdbms/admin/sqlsessend.sql
