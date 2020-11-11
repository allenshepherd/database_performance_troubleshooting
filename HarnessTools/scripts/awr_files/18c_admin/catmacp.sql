Rem
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem    NAME
Rem      catmacp.sql
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for CODE$ table.(data fault)
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacp.sql
Rem SQL_PHASE: CATMACP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    sjavagal  09/05/17 - Bug 26325568: New APIs to authorize user creation
Rem                         and roles/sys-privs grant during datapump import
Rem    jibyun    06/22/17 - Bug 26308167: add a new paramter, skip_default, to
Rem                         get_factor_context
Rem    qinwu     02/22/17 - proj 70151: support db capture and replay auth
Rem    jibyun    01/30/17 - Bug 24604117: enquote user names from SYS_CONTEXT
Rem                         and add validate_name to dbms_macutl
Rem    risgupta  01/15/17 - Proj 67579: PL/SQL Changes for DV Simulation
Rem                         Mode Enhancements
Rem    jibyun    11/17/16 - Bug 25115178: qualify all the referneced objects
Rem    jibyun    11/08/16 - Bug 23698273: fix dbms_macutl.is_dvsys_owner
Rem    dalpern   10/15/16 - bug 22665467: add DV checks on DEBUG [CONNECT]
Rem    youyang   08/13/16 - XbranchMerge youyang_bug-24360574_12.2.0.1 from
Rem                         st_rdbms_12.2.0.1.0
Rem    youyang   07/29/16 - bug24360574:replace default USER with current 
Rem                         user in dbms_macutl
Rem    gaurameh  05/25/16 - Bug 22470419: enquote default username in 
Rem                         user_has_role_varchar function 
Rem    kaizhuan  04/19/16 - Bug 22751770: rename function 
Rem                         current_container_scope to get_required_scope
Rem    yapli     03/02/16 - Bug 22840314: Change training api to simulation
Rem    youyang   02/15/16 - bug22672722:add index functions
Rem    sanbhara  02/02/16 - Bug 22584525 - adding new rule for Alter System
Rem                         Dump command rule to allow dump of segment headers.
Rem    jibyun    02/01/16 - Bug 22296366: qualify objects referenced internally
Rem    jibyun    11/01/15 - introduce DIAGNOSTIC authorization
Rem    juilin    22/07/15 - Bug 21458522 rename syscontext IS_FEDERATION_ROOT
Rem    sanbhara  08/20/15 - Bug 21299474 - adding scope to
Rem                         add_cmd_rule_to_policy().
Rem    jibyun    04/07/15 - Bug 20716092: Term Federation should not be used
Rem    kaizhuan  03/25/15 - Project 46814: Support for DV common policy
Rem       sanbha 03/09/15 - Project 46814 - common command rule support
Rem       jibyun 01/22/15 - Bug 20398212: long identifier support
Rem      namoham 12/14/14 - Project 36761: support maintenance authorization
Rem    kaizhuan  01/16/15 - Bug 20313334: Add functions current_container_scope
Rem                         and role_granted_enabled_varchar. Add parameter 
Rem                         scope to functions user_has_role and 
Rem                         user_has_role_varchar.
Rem      namoham 12/14/14 - Project 36761: support maintenance authorization
Rem     kaizhuan 11/24/14 - Project 46812: Support command rule fine grained
Rem                         level protection for ALTER SYSTEM/SESSION
Rem       jibyun 11/17/14 - Project 46812: support TRAINING mode
Rem     yanchuan 11/10/14 - Project 36761: add Supplemental Logging Pragmas
Rem                         for DV admin APIs to support Procedural Replication
Rem                         and remove packages that are not used any more
Rem       jibyun 08/06/14 - Project 46812: support for Database Vault policy
Rem      namoham 07/09/14 - Bug 19127377: add PREPROCESSOR authorization
Rem       jibyun 05/20/14 - Bug 18733351: add SESSION_ENABLED_ROLE functions
Rem                         for EUS support
Rem     aketkar  04/29/14 - sql patch metadata seed
Rem       jibyun 03/31/14 - Project 46812: add new admin procedures for
Rem                         managing CONNECT command rules
Rem     kaizhuan 09/26/13 - Bug 17342864: Remove packages which are no
Rem                         longer used.
Rem       namoha 07/23/13 - Bug 15938449: add get_event_status to dbms_macutl 
Rem                         package, and create dvsys.event_status view
Rem     yanchuan 08/31/12 - bug 14456083: add procedure authorize_tts_user and
Rem                         unauthorize_tts_user into DVSYS.dbms_macadm, remove
Rem                         param rulename from (un)authorize_datapump_user 
Rem       sanbha 08/30/12 - Bug 14484831 - changing parameter in
Rem                         DVSYS.FACTOR$_priv.create_row().
Rem       youyan 08/20/12 - bug14462640:remove check_is_drop_object_maint
Rem       sanbha 07/19/12 - Bug 14306557 - introducing
Rem                         dbms_macadm.enable_dv_patch_admin_audit.
Rem       youyan 03/13/12 - bug10088587:add DDL authorization
Rem     kaizhuan 02/18/12 - Bug 12670283: Add procedure dv_sanity_check 
Rem                         into package dbms_macadm
Rem       jibyun 03/12/12 - Bug 13728213: add disable_dv_dictionary_accts and
Rem                         enable_dv_dictionary_accts in dbms_macadm
Rem       youyan 12/23/11 - add proxy user authorization
Rem       sanbha 02/15/12 - Bug 13643954 - modifying realm$_priv.create_row
Rem                         procedure.
Rem       jibyun 12/05/11 - Bug 13454343: always have the kernel to insert
Rem                         audit logs
Rem       sanbha 11/21/11 - removing the directory parameter from add_nls_data
Rem                         - bug 13386839.
Rem     yanchuan 10/11/11 - Bug 12776828: admin procedure name changes
Rem     yanchuan 09/16/11 - Bug 12909622/12932570: remove obsolete code, mark
Rem                         uncovered code as NF, and clean code
Rem       jibyun 07/26/11 - Bug 7118790: Add enable_oradebug and
Rem                         disable_oradebug to dbms_macadm
Rem       sanbha 08/10/11 - Adding a new optional parameter to add_nls_data.
Rem       cchui  06/20/11 - remove calls to lbacsys.ols_init_session
Rem       youyan 06/04/11 - convert rule engine
Rem       jheng  05/25/11 - Proj 32973: add extra input profile parameter
Rem       youyan 04/26/11 - add owner uid to dictionary table
Rem       sanbha 04/22/11 - Project 24121 - Add DV configure and Enforce
Rem                         procedures to DBMS_MACADM.
Rem       jibyun 04/13/11 - Bug 12356827: Add check_goldengate_redo_access to
Rem                         dbms_macutl
Rem       youyan 02/08/10 - add mandatory realm
Rem       jibyun 02/18/11 - Bug 11662436: Add check_xstream_admin to
Rem                         dbms_macutl
Rem       jibyun 02/10/11 - Bug 11662436: Add check_goldengate_admin to 
Rem                         dbms_macutl
Rem       sanbha 02/03/11 - Bug Fix 10225918.
Rem       dvekar 01/07/11 - Bug 9068994 add is_drop_user_allow_varchar fn.
Rem       jheng  08/02/10 - Bug 9941304: add is_mac_label_set; change
Rem                         set_label_audit_raise to label_audit_raise
Rem       jheng  01/14/09 - add scheduler authorization procedure
Rem       srtata 12/26/08 - static rule sets
Rem       rupara 12/18/08 - Bug 7657506
Rem       youyan 11/19/08 - add check_is_drop_object_maint in
Rem                         dbms_macsec_events
Rem       jibyun 05/13/08 - Bug 7550987: Add dbms_macutl.check_streams_admin 
Rem                         function
Rem       jsamue 10/27/08 - remove error messages
Rem       ssonaw 09/25/08 - Bug-6938843: Add functions for seeded rules 
Rem       jibyun 05/13/08 - Bug 7550987: Add dbms_macutl.check_streams_admin 
Rem                         function
Rem       clei   05/30/08 - Bug 6435192: Add enable_dv_check/disable_dv_check
Rem       jibyun 04/27/08 - Fix Bug 6908550
Rem       jibyun 04/07/08 - Fix Bug 5926711: add a new parameter, p_user, to
Rem                         audit procedures
Rem       rupara 03/27/08 - Add authorize_datapump_user procedure
Rem       clei   02/18/08 - Add enable_event and disable_event
Rem       jibyun 10/31/07 - To fix Bug 6441524
Rem       jibyun 07/18/07 - To fix Bug 6068504
Rem       rupara 02/23/07 - Bug fix 5900679
Rem       rupara 11/17/06 - bug 5594883
Rem       rvissa 12/01/06 -  alter system set schema
Rem       clei   12/07/06 - remove VPD dependencies
Rem       cchuiu 07/05/06 - add more functions for cmd rules enforcement 
Rem       cchui  07/04/06 - fix char string buffer too small in 
Rem                         dvsys.event.set 
Rem       fjlee  06/07/06 - add delete_row w/o p_id
Rem       jcimin 05/02/06 - cleanup embedded file boilerplate 
Rem       jcimin 05/02/06 - created admin/catmacp.sql 
Rem       sgaetj 11/08/05 - unit test fixes 
Rem       sgaetj 11/03/05 - NLS support changes
Rem       sgaetj 08/11/05 - sgaetjen_dvschema
Rem       sgaetj 08/05/05 - Merge into ADE with Protected Schema
Rem       sgaetj 07/29/05 - Created
Rem       sgaetj 07/28/05 - dos2unix
Rem    raustin   Thu Dec 16 13:28:36 EST 2004 - Generated
Rem
Rem
Rem

Rem Set the current schema to dvsys
Rem This script should do this within itself as it can be called by relod scripts also
Rem apart from catmac.sql


@@?/rdbms/admin/sqlsessstart.sql

ALTER SESSION SET CURRENT_SCHEMA = DVSYS; 

Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for dbms_output replacement package
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macout
AS
    /**
    * Turn on tracing.
    */
    PROCEDURE enable;
    PRAGMA SUPPLEMENTAL_LOG_DATA(enable, NONE);

    /**
    * Turn off tracing.
    */
    PROCEDURE disable;
    PRAGMA SUPPLEMENTAL_LOG_DATA(disable, NONE);

    /**
    * Add text to the output (with a new line)
    * @param s String
    */
    PROCEDURE put_line( s IN VARCHAR2 );
    PRAGMA SUPPLEMENTAL_LOG_DATA(put_line, NONE);

    /**
    * Same as put_line.
    * @param s String
    */
    PROCEDURE pl( s IN VARCHAR2 );
    PRAGMA SUPPLEMENTAL_LOG_DATA(pl, NONE);

    /**
    * Retrieve a line of text from the buffer.  The line is deleted from
    * the line buffer.
    * @param n Line number
    */
    FUNCTION get_line( n IN NUMBER ) RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES( get_line, WNDS, RNDS );

    /**
    * Number of lines in the buffer.
    * @return Number of lines in the buffer
    */
    FUNCTION get_line_COUNT RETURN NUMBER;

    /**
    * Is the trace facility enabled.
    * @return An indicator that the trace facility is enabled for this session
    */
    FUNCTION is_enabled RETURN BOOLEAN;

    PRAGMA RESTRICT_REFERENCES( get_line_COUNT, WNDS, RNDS, WNPS );

    PRAGMA RESTRICT_REFERENCES( dbms_macout, WNDS, RNDS, WNPS, RNPS );
END;
/
show errors;

BEGIN
EXECUTE IMMEDIATE
'CREATE SYNONYM dvsys.out FOR dvsys.dbms_macout';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --synonym already created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for public Data Vault Administration APIs
Rem
Rem
Rem
Rem

-- Types for dbms_macutl.get_event_status function
BEGIN
  EXECUTE IMMEDIATE 'drop type dvsys.event_status_table_type';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-4043) THEN  NULL;-- ignore type does not exist 
    ELSE RAISE;
    END IF;
END;
/
  
CREATE OR REPLACE TYPE DVSYS.event_status_row_type AS object
(
  event   number,
  enabled varchar2(5)
)
/

CREATE TYPE DVSYS.event_status_table_type 
  AS TABLE OF DVSYS.event_status_row_type
/


CREATE OR REPLACE PACKAGE DVSYS.dbms_macutl AS

  /********************/
  /* Global Constants */
  /********************/
  -- Yes constant for enabled and label_ind columns (Boolean TRUE)
  g_yes CONSTANT VARCHAR2(1) := 'Y';
  -- No constant for enabled and label_ind columns (Boolean FALSE)
  g_no  CONSTANT VARCHAR2(1) := 'N';
  -- constant for training mode
  -- Bug 22840314: Change 'T' for training to 'S' for simulation
  g_simulation CONSTANT VARCHAR2(1) := 'S';

  -- Factor audit_options: No audit
  g_audit_off                       CONSTANT NUMBER := 0;
  -- Factor audit_options: Always audit
  g_audit_always                    CONSTANT NUMBER := POWER(2,0);
  -- Factor audit_options: Audit if get_expr returns an error
  g_audit_on_get_error              CONSTANT NUMBER := POWER(2,1);
  -- Factor audit_options: Audit if get_expr is null
  g_audit_on_get_null               CONSTANT NUMBER := POWER(2,2);
  -- Factor audit_options: Audit if validation function returns error
  g_audit_on_validate_error         CONSTANT NUMBER := POWER(2,3);
  -- Factor audit_options: Audit if validation function is false
  g_audit_on_validate_false         CONSTANT NUMBER := POWER(2,4);
  -- Factor audit_options: Audit if no trust level
  g_audit_on_trust_level_null       CONSTANT NUMBER := POWER(2,5);
  -- Factor audit_options: Audit if trus level is negative
  g_audit_on_trust_level_neg        CONSTANT NUMBER := POWER(2,6);

  -- Fail_options: Fail with message
  g_fail_with_message   CONSTANT NUMBER := POWER(2,0);
  -- Fail_options: Fail with message
  g_fail_silently       CONSTANT NUMBER := POWER(2,1);

  -- Factor identify_by column: Fixed value in get_expr column
  g_identify_by_constant    CONSTANT NUMBER := 0;
  -- Factor identify_by column: Expression in get_expr column
  g_identify_by_method      CONSTANT NUMBER := 1;
  -- Factor identify_by column: Sub-factors via factor_link$ table
  g_identify_by_factor      CONSTANT NUMBER := 2;
  -- Factor identify_by session context
  g_identify_by_context     CONSTANT NUMBER := 3;

  -- Factor identify_by column:  Expression and Rule Set via factor_expr$ table
  -- g_identify_by_ruleset     CONSTANT NUMBER := 4;

  -- Factor eval_options: Evaluate once upon login
  g_eval_on_session CONSTANT NUMBER := 0;
  -- Factor eval_options: Re-evaluate on each access
  g_eval_on_access  CONSTANT NUMBER := 1;
  -- Factor eval_options: Evaluate once at database startup
  g_eval_on_startup  CONSTANT NUMBER := 2;

  -- Factor labeled_by column: Factor's identities are labeled
  g_labeled_by_self     CONSTANT NUMBER := 0;
  -- Factor labeled_by column: Derive label from sub-factor and merge algorithm
  g_labeled_by_factors  CONSTANT NUMBER := 1;

  -- Realm Objects: Wild card to indicate all object names or all object types
  g_all_object CONSTANT VARCHAR2(1) := '%';

  -- Rule Set audit_options: No auditing
  g_ruleset_audit_off            CONSTANT NUMBER := 0;
  -- Rule Set audit_options: Audit on Rule Set failure
  g_ruleset_audit_fail           CONSTANT NUMBER := POWER(2,0);
  -- Rule Set audit_options: Audit on Rule Set success
  g_ruleset_audit_success        CONSTANT NUMBER := POWER(2,1);

  -- Rule Set eval_options: Rule Set succeeds if all Rules are TRUE
  g_ruleset_eval_all             CONSTANT NUMBER := 1;
  -- Rule Set eval_options: Rule Set succeeds if any Rule is TRUE
  g_ruleset_eval_any             CONSTANT NUMBER := 2;

  -- Rule Set fail_options: Show error message
  g_ruleset_fail_show            CONSTANT NUMBER := 1;
  -- Rule Set fail_options: No error message
  g_ruleset_fail_silent          CONSTANT NUMBER := 2;

  -- Rule Set handler_options: No call to handler
  g_ruleset_handler_off          CONSTANT NUMBER := 0;
  -- Rule Set handler_options: Call handler on Rule Set failure
  g_ruleset_handler_fail         CONSTANT NUMBER := POWER(2,0);
  -- Rule Set handler_options: Call handler on Rule Set success
  g_ruleset_handler_success      CONSTANT NUMBER := POWER(2,1);

  -- Realm audit_options: No auditing
  g_realm_audit_off              CONSTANT NUMBER := 0;
  -- Realm audit_options: Audit on realm violation
  g_realm_audit_fail             CONSTANT NUMBER := POWER(2,0);
  -- Realm audit_options: Audit on successful realm access
  g_realm_audit_success          CONSTANT NUMBER := POWER(2,1);

  -- Realm authoriations: Participant
  g_realm_auth_participant       CONSTANT NUMBER := 0;
  -- Realm authoriations: Owner
  g_realm_auth_owner             CONSTANT NUMBER := 1;

  -- Code groups: Audit Event Descriptions
  g_codes_audit_events    CONSTANT VARCHAR2(30) := 'AUDIT_EVENTS';
  -- Code groups: Boolean values
  g_codes_boolean         CONSTANT VARCHAR2(30) := 'BOOLEAN';
  -- Code groups: DDL commands
  g_codes_ddl_cmds        CONSTANT VARCHAR2(30) := 'DDL_CMDS';
  -- Code groups: Factor audit_options
  g_codes_factor_audit    CONSTANT VARCHAR2(30) := 'FACTOR_AUDIT';
  -- Code groups: Factor eval_options
  g_codes_factor_eval     CONSTANT VARCHAR2(30) := 'FACTOR_EVALUATE';
  -- Code groups: Factor fail_options
  g_codes_factor_fail     CONSTANT VARCHAR2(30) := 'FACTOR_FAIL';
  -- Code groups: Factor identity_by
  g_codes_factor_identify CONSTANT VARCHAR2(30) := 'FACTOR_IDENTIFY';
  -- Code groups: Factor labeled_by
  g_codes_factor_label    CONSTANT VARCHAR2(30) := 'FACTOR_LABEL';
  -- Code groups: Database object types
  g_codes_db_object_type  CONSTANT VARCHAR2(30) := 'DB_OBJECT_TYPE';
  -- Code groups: OLS Policy merge algorithms
  g_codes_label_alg       CONSTANT VARCHAR2(30) := 'LABEL_ALG';
  -- Code groups: DV Error messages
  g_codes_messages        CONSTANT VARCHAR2(30) := 'DV_MESSAGES';
  -- Code groups: SQL relational operators
  g_codes_operators       CONSTANT VARCHAR2(30) := 'OPERATORS';
  -- Code groups: Realm audit_options
  g_codes_realm_audit     CONSTANT VARCHAR2(30) := 'REALM_AUDIT';
  -- Code groups: Rule Set audit_options
  g_codes_ruleset_audit   CONSTANT VARCHAR2(30) := 'RULESET_AUDIT';
  -- Code groups: Rule Set evaluate_options
  g_codes_ruleset_eval    CONSTANT VARCHAR2(30) := 'RULESET_EVALUATE';
  -- Code groups: Rule Set handler_options
  g_codes_ruleset_event   CONSTANT VARCHAR2(30) := 'RULESET_EVENT';
  -- Code groups: Rule Set fail_options
  g_codes_ruleset_fail    CONSTANT VARCHAR2(30) := 'RULESET_FAIL';
  -- Code groups: SQL Commands
  g_codes_sql_cmds        CONSTANT VARCHAR2(30) := 'SQL_CMDS';

  -- Context:   Namespace, Attribute, Value
  -- MACSEC/MACOLS context start with this
  g_context_prefix CONSTANT VARCHAR2(30) := 'MAC$';
  -- Factor Labels:    MAC$F$<policy>, <factor_name>, <factor label>
  g_context_factor_label CONSTANT VARCHAR2(30) := g_context_prefix||'F$';
  -- Session Labels:   MAC$S$<policy>, <session attribute>, <label>
  g_context_session_label CONSTANT VARCHAR2(30) := g_context_prefix||'S$';
  -- Factors:   MAC$FACTOR,<factor name>, <factor value>
  g_context_factor CONSTANT VARCHAR2(30) := g_context_prefix||'FACTOR';
  -- Realm:   MAC$REALM,<factor name>, <factor value>
  g_context_realm CONSTANT VARCHAR2(30) := g_context_prefix||'REALM';

  -- This is that label that a factor will a null label will default to
  g_min_policy_label CONSTANT VARCHAR2(30) := 'MIN_POLICY_LABEL';
  -- This is the highest label a user could set based on the factors
  -- (it does not take into account the user's label)
  g_max_session_label CONSTANT VARCHAR2(30) := 'MAX_SESSION_LABEL';
  -- The user's OLS session label at the time init_session is executed
  g_ols_session_label CONSTANT VARCHAR2(30) := 'OLS_SESSION_LABEL';
  -- This is what MACOLS decided the user's label should be set to
  -- after factoring in the above values.
  g_user_policy_label CONSTANT VARCHAR2(30) := 'USER_POLICY_LABEL';

  -- Variables to set scope of DV Realms, Command Rules, Rules, and Rule Sets.
  g_scope_local         CONSTANT NUMBER := 1;
  g_scope_common        CONSTANT NUMBER := 2;
 
  -- Constants to indicate ACTION strings for datapump authorization API.
  g_dp_act_all               CONSTANT VARCHAR2(30) := '%';
  g_dp_act_table             CONSTANT VARCHAR2(30) := 'TABLE';
  g_dp_act_grant             CONSTANT VARCHAR2(30) := 'GRANT';
  g_dp_act_create_user       CONSTANT VARCHAR2(30) := 'CREATE_USER';
  
  /**
  * Returns an indicator as to whether or not OLS is installed
  *
  * @return TRUE if OLS is installed
  */
  FUNCTION is_ols_installed RETURN BOOLEAN;


  /**
  * Returns an indicator as to whether or not OLS is installed
  *
  * @return Y if OLS is installed, N otherwise
  */
  FUNCTION is_ols_installed_varchar RETURN VARCHAR2;

  /**
  * Returns an indicator as to whether or not DV is enabled 
  *
  * @return TRUE if DV is enabled, FALSE otherwise
  */
  FUNCTION is_dv_enabled RETURN BOOLEAN;
 
  -- check DATAPUMP DV authorization at full database level
  FUNCTION check_full_dvauth RETURN BINARY_INTEGER;

  -- check DATAPUMP/TTS DV authorization for a specified tablespace
  FUNCTION check_ts_dvauth(ts_name IN VARCHAR2) RETURN BINARY_INTEGER;

  -- check DATAPUMP/TTS DV authorization for a specified table
  FUNCTION check_tab_dvauth(schema_name IN VARCHAR2,
                            table_name  IN VARCHAR2) RETURN BINARY_INTEGER;

  /**
  * Returns an indicator as to whether or not DV is enabled 
  *
  * @return Y if DV is enabled, N otherwise
  */
  FUNCTION is_dv_enabled_varchar RETURN VARCHAR2 ;

  /**
  * Returns an indicator as to whether or not OID enabled OLS is installed
  *
  * @return TRUE if OID enabled OLS is installed
  */
  FUNCTION is_oid_enabled_ols RETURN BOOLEAN;

  /**
  * Returns ldap user if OID enabled OLS is installed
  *
  * @return logon user
  */
  FUNCTION ols_ldap_user RETURN VARCHAR2;

  /**
  * Returns unique user ID whether user is from OID or standard database accounts
  *
  * @return unique user ID from OID or dbms_standard.login_user
  */
  FUNCTION unique_user RETURN VARCHAR2;

  /**
  * Looks up the value for a code within a code group
  *
  * @param p_code_group Code group - e.g. AUDIT_EVENTS or BOOLEAN
  * @return Value of the code
  */
  FUNCTION get_code_value(p_code_group VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2;

  /**
  * Looks up the id for a code within a code group
  *
  * @param p_code_group Code group - e.g. AUDIT_EVENTS or BOOLEAN
  * @return Id of the code
  */
  FUNCTION get_code_id(p_code_group VARCHAR2, p_code VARCHAR2) RETURN NUMBER;

  /**
  * Looks up an error message and replaces parameters accordingly
  *
  * @param p_message_code VARCHAR Message code
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  * @return Error message
  */
  FUNCTION get_message_label(p_message_code VARCHAR2,
                        p_parameter1   IN VARCHAR2 DEFAULT NULL,
                        p_parameter2   IN VARCHAR2 DEFAULT NULL,
                        p_parameter3   IN VARCHAR2 DEFAULT NULL,
                        p_parameter4   IN VARCHAR2 DEFAULT NULL,
                        p_parameter5   IN VARCHAR2 DEFAULT NULL,
                        p_parameter6   IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /**
  * Looks up an error message and replaces parameters accordingly
  *
  * @param p_message_code NUMBER Message code
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  * @return Error message
  */
  FUNCTION get_message_label(p_message_code NUMBER,
                        p_parameter1   IN VARCHAR2 DEFAULT NULL,
                        p_parameter2   IN VARCHAR2 DEFAULT NULL,
                        p_parameter3   IN VARCHAR2 DEFAULT NULL,
                        p_parameter4   IN VARCHAR2 DEFAULT NULL,
                        p_parameter5   IN VARCHAR2 DEFAULT NULL,
                        p_parameter6   IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  */
  PROCEDURE raise_error(p_message_code IN NUMBER);
  PRAGMA SUPPLEMENTAL_LOG_DATA(raise_error, NONE);

  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2);

  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2,
                        p_parameter5   IN VARCHAR2);

  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2,
                        p_parameter5   IN VARCHAR2,
                        p_parameter6   IN VARCHAR2);


  /**
  * Converts the audit_options value for a table to a VARCHAR2 form.
  *
  * @param p_table_name Name of a DV table with a audit_options column (e.g. realm$)
  * @param p_audit_options Audit_options column value (can be several options 'OR-ed' together')
  * @return Audit_options in VARCHAR2 form, separated by commas
  */
  FUNCTION decode_audit_options(p_table_name IN VARCHAR2,
                                p_audit_options IN NUMBER) RETURN VARCHAR2;

  /**
  * Constructs an XML document which contains the values for all of the factors.  Note that
  * the document is only intended for auditing or tracing and will be truncated if it is
  * longer than 4000 characters.
  *
  * @return XML document containing the factor context
  */
  FUNCTION get_factor_context(skip_default IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Concatenates the elements of an ora_name_list_t into a single VARCHAR2.
  *
  * @param p_sql_test Table of VARCHAR2 strings
  * @return Single string
  */
  FUNCTION get_sql_text(p_sql_text IN ora_name_list_t) RETURN VARCHAR2;

  /**
  * Checks whether the character is alphabetic.
  *
  * @param c String with one character
  * @return TRUE if the character is alphabetic
  */
  FUNCTION is_alpha(c IN varchar2) RETURN BOOLEAN;

  /**
  * Checks whether the character is numeric
  *
  * @param c String with one character
  * @return TRUE if the character is a digit
  */
  FUNCTION is_digit(c IN varchar2) RETURN BOOLEAN;

  /**
  * Alters a string to make it a legal Oracle identifier
  *
  * @param id Illegal identifier
  * @return Identifier
  */
  FUNCTION to_oracle_identifier(id IN varchar2) RETURN VARCHAR2;

  /**
  * Validates and canonicalizes the given user/role name
  *
  * @param   user/role name
  * @return  canonicalized name
  *
  * Note: This function will raise ORA-44003 if the given name is not 
  *       a valid SQL name.
  */
  FUNCTION validate_name(name IN varchar2) RETURN DBMS_ID;

  /**
  * Convenience procedure for generic disallowed operation exception.
  *
  * @param p_user User performing the operation
  */
  PROCEDURE raise_unauthorized_operation(p_user IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(raise_unauthorized_operation, NONE);

  /**
  * Determines whether a user is authorized to manage the DV configuration.  The
  * DVSYS user and users granted the DV_OWNER role are authorized.
  *
  * @param p_user     User to check
  * @param p_profile  Whether to capture role usage
  * @param p_scope    COMMON or LOCAL
  *
  * @return TRUE if user is authorized
  */
  FUNCTION is_dvsys_owner(p_user    IN VARCHAR2 DEFAULT 
                            sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE),
                          p_profile IN BOOLEAN DEFAULT TRUE,
                          p_scope   IN VARCHAR2 := 'LOCAL') RETURN BOOLEAN;

  /**
  * Verifies that a public-APIs are not being bypassed by users updating the DV
  * configuration.
  *
  * @param p_user User performing the operation
  */
  PROCEDURE check_dvsys_dml_allowed(p_user IN VARCHAR2 DEFAULT 
                                      sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE));
  PRAGMA SUPPLEMENTAL_LOG_DATA(check_dvsys_dml_allowed, NONE);

  /**
  * Checks for a string in the PL/SQL call stack
  *
  * @param p_search_term String to search for
  * @return TRUE if string is in the call stack
  */
  FUNCTION in_call_stack(p_search_term IN VARCHAR2) RETURN BOOLEAN;

  /**
  * Checks whether a user has a role granted directly or indirectly (via another role).
  *
  * @param p_role Role privilege to check for
  * @param p_user User
  * @param p_profile Whether to capture the role usage; When the role checked 
  *        is used, please set p_profile to TRUE
  * @param p_scope COMMON or LOCAL
  * @return TRUE if user has the role granted with the specified scope 
  */
  FUNCTION user_has_role(p_role IN VARCHAR2, 
                         p_user IN VARCHAR2 DEFAULT 
                            sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE),
                         p_profile IN BOOLEAN DEFAULT TRUE,
                         p_scope IN VARCHAR2 := 'LOCAL')
    RETURN BOOLEAN;

  /**
  * Checks whether 'alter system dump datafile' is only dumping header block.
  *
  */
  FUNCTION alter_system_dump_allowed 
    RETURN BOOLEAN;

  FUNCTION alter_system_dump_varchar
    RETURN VARCHAR2;

  /**
  * Checks whether the given role is enabled in the current session.
  *
  * @param p_role Role to check
  * @return TRUE if the role is enabled in the current session
  */
  FUNCTION session_enabled_role(p_role    IN VARCHAR2)
    RETURN BOOLEAN;


  /**
  * Checks whether a user or role may access an object via a object privilege
  * grant.  The object privilege may have been granted directly to the
  * specified user/role or may have been granted indirectly via another role.
  *
  * @param p_user User or Role
  * @param p_object_owner Object owner
  * @param p_object_name Object name
  * @param p_privilege Object privilege (SELECT, UPDATE, INSERT, ...)
  * @param p_profile Whether to capture the object privilege; When the 
  *        privilege checked by this function is used, please set p_profile 
  *        to TRUE.
  * @return TRUE if user/role has the privilege   
  */
  FUNCTION user_has_object_privilege(p_user         IN VARCHAR2,
                                     p_object_owner IN VARCHAR2,
                                     p_object_name  IN VARCHAR2,
                                     p_privilege    IN VARCHAR2,
                                     p_profile      IN BOOLEAN DEFAULT TRUE)
   RETURN BOOLEAN;

  /**
  * Checks whether a user has a role granted directly or indirectly (via another role).
  *
  * @param p_role Role privilege to check for
  * @param p_user User
  * @param p_profile Whether to capture the role usage; When the role checked 
  *        is used, please set p_profile to 1.
  * @param p_scope COMMON or LOCAL
  * @return Y if use has the role granted with the specified scope, N otherwise
  */
  FUNCTION user_has_role_varchar(p_role IN VARCHAR2, 
                                 p_user IN VARCHAR2 DEFAULT 
                                 sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE), 
                                 p_profile IN INTEGER DEFAULT 1,
                                 p_scope IN VARCHAR2 := 'LOCAL') 
   RETURN VARCHAR2;

  /**
  * Checks whether a user has a role granted directly or indirectly (via another role)
  * with a sufficient scope or the role currently is enabled in the session while 
  * the role is not granted.
  *
  * @param p_role Role privilege to check for
  * @param p_user User
  * @param p_scope COMMON or LOCAL
  * @param p_profile Whether to capture the role usage; When the role checked 
  *        is used, please set p_profile to 1.
  * @return Y if use has the role granted with the specified scope or
  *  the role is not granted but enabled in the session, N otherwise
  */
  FUNCTION role_granted_enabled_varchar(p_role IN VARCHAR2, 
                                        p_user IN VARCHAR2 DEFAULT 
                                           sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE), 
                                        p_profile IN INTEGER DEFAULT 1,
                                        p_scope IN VARCHAR2 := 'LOCAL')
   RETURN VARCHAR2;

  /**
  * Checks whether the given role is enabled in the current session.
  *  
  * @param p_role Role to check
  * @return Y if the role is enabled in the current session, N otherwise
  */
  FUNCTION session_enabled_role_varchar(p_role    IN VARCHAR2)
    RETURN VARCHAR2;

  /**
  * Checks whether a user has a system privilege, directly or indirectly (via a role).
  *
  * @param p_role System privilege to check for
  * @param p_user User
  * @param p_profile Whether to capture the system privilege; When the 
  *        privilege checked by this function is used, please set p_profile 
  *        to TRUE.
  * @return TRUE if use has the privilege
  */
  FUNCTION user_has_system_privilege(p_privilege IN VARCHAR2, 
                                     p_user IN VARCHAR2 DEFAULT 
                                        sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE), 
                                     p_profile IN BOOLEAN DEFAULT TRUE) 
   RETURN BOOLEAN;

  /**
  * Checks whether a user has a system privilege, directly or indirectly (via a role).
  *
  * @param p_role System privilege to check for
  * @param p_user User
  * @param p_profile Whether to capture the system privilege; When the 
  *        privilege checked by this function is used, please set p_profile 
  *        to TRUE.
  * @return Y if use has the privilege; N otherwise
  */
  FUNCTION user_has_system_priv_varchar (p_privilege IN VARCHAR2, 
                                         p_user IN VARCHAR2 DEFAULT 
                                            sys.dbms_assert.enquote_name(SYS_CONTEXT('USERENV', 'CURRENT_USER'), FALSE), 
                                         p_profile IN BOOLEAN DEFAULT TRUE) 
   RETURN VARCHAR2;

 /*
  * Checks whether the given user can perform Streams administrative operation. 
  * This is determined by whether the user has DV_STREAMS_ADMIN role. Note that
  * if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) the user has DV_STREAMS_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_streams_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform Golden Gate extract operation. 
  * This is determined by whether the user has DV_GOLDENGATE_ADMIN role. Note 
  * that if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) user has DV_GOLDENGATE_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_goldengate_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform XSTREAM capture operation. 
  * This is determined by whether the user has DV_XSTREAM_ADMIN role. Note 
  * that if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) user has DV_XSTREAM_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_xstream_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform Golden Gate extract operation
  * using the OCI interface. This is determined by whether the user has the 
  * DV_GOLDENGATE_REDO_ACCESS role. Note that if DV is not enabled, then this 
  * function always returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 
  *                 2) user has DV_GOLDENGATE_REDO_ACCESS role.
  *         FALSE otherwise.
  */
  FUNCTION check_goldengate_redo_access(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Obtain the pipelined table of status of the events 10079 and 24473.
  *
  * @return pipelined table
  */
  FUNCTION get_event_status RETURN dvsys.event_status_table_type PIPELINED;

  /**
  * Returns the month in Oracle MM format (01-12).
  * @param p_date Date
  * @return Month 01-12.
  */
  FUNCTION get_month(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the day in Oracle DD format (01-31).
  *
  * @param p_date Date
  * @return Day 01-31.
  */
  FUNCTION get_day(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the year in Oracle YYYY format (0001-9999).
  *
  * @param p_date Date
  * @return Year 0001-9999.
  */
  FUNCTION get_year(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the month in Oracle HH24 format (00-23).
  *
  * @param p_date Date
  * @return Hour 00-23.
  */
  FUNCTION get_hour(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the minute in Oracle MI format (00-59).
  *
  * @param p_date Date
  * @return Minute 00-59.
  */
  FUNCTION get_minute(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the seconds in Oracle SS format (00-59).
  *
  * @param p_date Date
  * @return Second 00-59.
  */
  FUNCTION get_second(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

END;
/

SHOW ERRORS;

Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for public Data Vault Administration APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macadm AS

  /* Global Constants */
  
  MANDATORY_REALM                  CONSTANT BINARY_INTEGER := 1; 
  FACTOR_TYPE_CREATION_AUDIT       CONSTANT PLS_INTEGER :=     20032;
  FACTOR_TYPE_DELETION_AUDIT       CONSTANT PLS_INTEGER :=     20033;
  FACTOR_TYPE_UPDATE_AUDIT         CONSTANT PLS_INTEGER :=     20034;
  FACTOR_TYPE_RENAME_AUDIT         CONSTANT PLS_INTEGER :=     20035;

  FACTOR_CREATION_AUDIT            CONSTANT PLS_INTEGER :=     20036;
  FACTOR_DELETION_AUDIT            CONSTANT PLS_INTEGER :=     20037;
  FACTOR_UPDATE_AUDIT              CONSTANT PLS_INTEGER :=     20038;
  FACTOR_RENAME_AUDIT              CONSTANT PLS_INTEGER :=     20039;

  ADD_FACTOR_LINK_AUDIT            CONSTANT PLS_INTEGER :=     20040;
  DELETE_FACTOR_LINK_AUDIT         CONSTANT PLS_INTEGER :=     20041;
  ADD_POLICY_FACTOR_AUDIT          CONSTANT PLS_INTEGER :=     20042;
  DELETE_POLICY_FACTOR_AUDIT       CONSTANT PLS_INTEGER :=     20043;

  IDENTITY_CREATION_AUDIT          CONSTANT PLS_INTEGER :=     20044;
  IDENTITY_DELETION_AUDIT          CONSTANT PLS_INTEGER :=     20045;
  IDENTITY_UPDATE_AUDIT            CONSTANT PLS_INTEGER :=     20046;
  CHANGE_IDENTITY_FACTOR_AUDIT     CONSTANT PLS_INTEGER :=     20047;
  CHANGE_IDENTITY_VALUE_AUDIT      CONSTANT PLS_INTEGER :=     20048;

  IDENTITY_MAP_CREATION_AUDIT      CONSTANT PLS_INTEGER :=     20049;
  IDENTITY_MAP_DELETION_AUDIT      CONSTANT PLS_INTEGER :=     20050;

  POLICY_LABEL_CREATION_AUDIT      CONSTANT PLS_INTEGER :=     20051;
  POLICY_LABEL_DELETION_AUDIT      CONSTANT PLS_INTEGER :=     20052;
  MAC_POLICY_CREATION_AUDIT        CONSTANT PLS_INTEGER :=     20053;
  MAC_POLICY_UPDATE_AUDIT          CONSTANT PLS_INTEGER :=     20054;
  MAC_POLICY_DELETION_AUDIT        CONSTANT PLS_INTEGER :=     20055;

  ROLE_CREATION_AUDIT              CONSTANT PLS_INTEGER :=     20056;
  ROLE_DELETION_AUDIT              CONSTANT PLS_INTEGER :=     20057;
  ROLE_UPDATE_AUDIT                CONSTANT PLS_INTEGER :=     20058;
  ROLE_RENAME_AUDIT                CONSTANT PLS_INTEGER :=     20059;

  DOMAIN_IDENTITY_CREATION_AUDIT   CONSTANT PLS_INTEGER :=     20060;
  DOMAIN_IDENTITY_DROP_AUDIT       CONSTANT PLS_INTEGER :=     20061;

  -- Constants for Database Vault policy states
  g_disabled CONSTANT NUMBER := 0;
  g_enabled  CONSTANT NUMBER := 1;
  g_simulation CONSTANT NUMBER := 2;
  g_partial  CONSTANT NUMBER := 3;

  -- Constants for Database Vault object types
  g_realm        CONSTANT NUMBER := 1;
  g_command_rule CONSTANT NUMBER := 2;

  /*****************************/
  /**Public Administration API */
  /*****************************/

  /**
  * Used to enable auditing on activities performed by user with
  * DV_PATCH_ADMIN role. If DV authorization is successful only because of 
  * a user having dv_patch_admin, we would not normally audit this event. But 
  * if this procedure is executed, we will record the event in the audit trail.
  */
  PROCEDURE enable_dv_patch_admin_audit;
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_dv_patch_admin_audit, AUTO_WITH_COMMIT);

  /**
  * Used to disable auditing on dv_patch_admin bypass of DV protection.
  */
  PROCEDURE disable_dv_patch_admin_audit;
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_dv_patch_admin_audit, AUTO_WITH_COMMIT);


  /**
  * Used to do the sanity check before configure DV. Check Items includes:
  * The total number of dvsys tables, views, packages package bodies
  * dvf packages, dvf package bodies, dvf functions
  * dependent lbacsys packages and all the dv roles' existence
  */
  PROCEDURE dv_sanity_check;
  PRAGMA SUPPLEMENTAL_LOG_DATA(dv_sanity_check, NONE);

  /**
  * Used to allow mixed case identifiers.  By default, they are not allowed.
  *
  * @param setting TRUE to allow mixed case
  */
  PROCEDURE set_preserve_case(setting IN BOOLEAN);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_preserve_case, NONE);

  /* Factor Type */

  /**
  * Create a Factor Type
  *
  * @param name Factor Type name
  * @param description Description
  */
  PROCEDURE create_factor_type
              (name        IN varchar2,
               description IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_factor_type, AUTO_WITH_COMMIT);

  /**
  * Delete a Factor Type
  *
  * @param name Factor Type name
  */
  PROCEDURE delete_factor_type
              (name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_factor_type, AUTO_WITH_COMMIT);

  /**
  * Update a Factor Type
  *
  * @param name Factor Type name
  * @param description New Description
  */
  PROCEDURE update_factor_type
              (name IN varchar2,
               description IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_factor_type, AUTO_WITH_COMMIT);

  /**
  * Rename a Factor Type
  *
  * @param old_name Previous Factor Type name
  * @param new_name New Factor Type name
  */
  PROCEDURE rename_factor_type
              (old_name IN varchar2,
               new_name    IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_factor_type, AUTO_WITH_COMMIT);

  /* Factor */

  /**
  * Create a Factor
  *
  * @param factor_name Factor Name
  * @param factor_type_name Factor Type Name
  * @param description Factor description
  * @param rule_set_name Rule Set Name (for assignment)
  * @param get_expr Expression for evaluating Factor
  * @param validate_expr Name of function to validate Factor
  * @param identify_by Options for determining the Factor's identity (see dbms_macutl)
  * @param labeled_by Options for labeling the Factor (see dbms_macutl)
  * @param eval_options Options for evaluating the Factor (see dbms_macutl)
  * @param audit_options Options for auditing the Factor (see dbms_macutl)
  * @param fail_options Options for reporting Factor errors (see dbms_macutl)
  *
  */
  PROCEDURE create_factor
              (factor_name      IN varchar2,
               factor_type_name IN varchar2,
               description      IN varchar2,
               rule_set_name    IN varchar2,
               get_expr         IN varchar2,
               validate_expr    IN varchar2,
               identify_by      IN number,
               labeled_by       IN number,
               eval_options     IN number,
               audit_options    IN number,
               fail_options     IN number,
               namespace           IN varchar2 DEFAULT NULL,
               namespace_attribute IN varchar2 DEFAULT NULL
               );
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_factor, AUTO_WITH_COMMIT);

  /**
  * Update a Factor
  *
  * @param factor_name Factor Name
  * @param factor_type_name Factor Type Name
  * @param description Factor description
  * @param rule_set_name Rule Set Name (for assignment)
  * @param get_expr Expression for evaluating Factor
  * @param validate_expr Name of function to validate Factor
  * @param identify_by Options for determining the Factor's identity (see dbms_macutl)
  * @param labeled_by Options for labeling the Factor (see dbms_macutl)
  * @param eval_options Options for evaluating the Factor (see dbms_macutl)
  * @param audit_options Options for auditing the Factor (see dbms_macutl)
  * @param fail_options Options for reporting Factor errors (see dbms_macutl)
  *
  */
  PROCEDURE update_factor
              (factor_name      IN varchar2,
               factor_type_name IN varchar2,
               description      IN varchar2,
               rule_set_name    IN varchar2,
               get_expr         IN varchar2,
               validate_expr    IN varchar2,
               identify_by      IN number,
               labeled_by       IN number,
               eval_options     IN number,
               audit_options    IN number,
               fail_options     IN number,
               namespace           IN varchar2 DEFAULT NULL,
               namespace_attribute IN varchar2 DEFAULT NULL
               );
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_factor, AUTO_WITH_COMMIT);

  /**
  * Delete a Factor
  *
  * @param factor_name Factor to delete
  *
  */
  PROCEDURE delete_factor
              (factor_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_factor, AUTO_WITH_COMMIT);

  /**
  * Rename a Factor
  *
  * @param factor_name Factor to rename
  *
  */
  PROCEDURE rename_factor
              (factor_name IN varchar2, new_factor_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_factor, AUTO_WITH_COMMIT);

  /**Factor Link **/

  /**
  * Specify a parent-child relationship for two factors.  The relationship may be
  * used for computing the Factor's identity or label.
  *
  * @param parent_factor_name Parent Factor name
  * @param child_factor_name Child Factor name
  * @param label_indicator Indication of whether the child contributes to the parent's label
  */
  PROCEDURE add_factor_link
              (parent_factor_name IN varchar2,
               child_factor_name  IN varchar2,
               label_indicator    IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_factor_link, AUTO_WITH_COMMIT);

  /**
  * Remove a parent-child relationship for two factors.
  *
  * @param parent_factor_name Parent Factor name
  * @param child_factor_name Child Factor name
  *
  */
  PROCEDURE delete_factor_link
              (parent_factor_name IN varchar2,
               child_factor_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_factor_link, AUTO_WITH_COMMIT);


  /* Policy Factor */

  /**
  * Specify that the label for a Factor contributes to the MAC OLS Label for a
  * policy.
  *
  * @param policy_name OLS Policy Name
  * @param factor_name Factor Name
  *
  */
  PROCEDURE add_policy_factor
              (policy_name IN varchar2,
               factor_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_policy_factor, AUTO_WITH_COMMIT);

  /**
  * Remove the Factor from contributing to the MAC OLS Label.
  *
  * @param policy_name OLS Policy Name
  * @param factor_name Factor Name
  *
  */
  PROCEDURE delete_policy_factor
              (policy_name IN varchar2,
               factor_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_policy_factor, AUTO_WITH_COMMIT);


  /**
  * Create an Identity.  Entities in the environment which will be labeled should be
  * given an identity (except for users, which are handled by OLS).
  *
  * @param factor_name Factor Name
  * @param value VARCHAR2 value associated with the identity
  * @param trust_level >0 for trust level, =0 for not trusted, <0 for distrust level
  *
  */
  PROCEDURE create_identity
              (factor_name IN varchar2,
               value       IN varchar2,
               trust_level IN number);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_identity, AUTO_WITH_COMMIT);

  /**
  * Update an Identity.
  *
  * @param factor_name Factor Name
  * @param value VARCHAR2 value associated with the identity
  * @param trust_level >0 for trust level, =0 for not trusted, <0 for distrust level
  *
  */
  PROCEDURE update_identity
              (factor_name IN varchar2,
               value       IN varchar2,
               trust_level IN number);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_identity, AUTO_WITH_COMMIT);

  /**
  * Associate an identity with a different Factor.
  *
  * @param factor_name Current Factor Name
  * @param value Value of the Identity to update
  * @param new_factor_name Factor Name
  *
  */
  PROCEDURE change_identity_factor
              (factor_name      IN varchar2,
               value            IN varchar2,
               new_factor_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(change_identity_factor, AUTO_WITH_COMMIT);

  /**
  * Update the value of an Identity.
  *
  * @param factor_name Factor Name
  * @param value Current value associated with the identity
  * @param new_value New Identity value
  *
  */
  PROCEDURE change_identity_value
              (factor_name IN varchar2,
               value       IN varchar2,
               new_value   IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(change_identity_value, AUTO_WITH_COMMIT);

  /**
  * Remove an Identity.
  *
  * @param factor_name Factor Name
  * @param value Value associated with the identity
  *
  */
  PROCEDURE delete_identity
              (factor_name IN varchar2,
               value       IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_identity, AUTO_WITH_COMMIT);

  /* Identity Map */

  /*
  * Define a set of tests that are used to derive the identity of a Factor from
  * the value of linked child factors (sub-factors).
  *
  * @param identity_factor_name Factor the identity map is for
  * @param identity_factor_value Value the Factor will assume if the Identity Map is TRUE
  * @param parent_factor_name Identifies the Factor Link the Map is related to
  * @param child_factor_name Identifies the Factor Link the Map is related to
  * @param operation Relational operator for the Map (i.e. <, >, =, ...)
  * @param operand1 Left operand for the relational operator
  * @param operand1 Right operand for the relational operator
  *
  */
  PROCEDURE create_identity_map
               (identity_factor_name  IN varchar2,
                identity_factor_value IN varchar2,
                parent_factor_name    IN varchar2,
                child_factor_name     IN varchar2,
                operation             IN varchar2,
                operand1              IN varchar2,
                operand2              IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_identity_map, AUTO_WITH_COMMIT);

  /*
  * Remove an Identity Map for a Factor.
  *
  * @param identity_factor_name Factor the identity map is for
  * @param identity_factor_value Value the Factor will assume if the Identity Map is TRUE
  * @param parent_factor_name Identifies the Factor Link the Map is related to
  * @param child_factor_name Identifies the Factor Link the Map is related to
  * @param operation Relational operator for the Map (i.e. <, >, =, ...)
  * @param operand1 Left operand for the relational operator
  * @param operand1 Right operand for the relational operator
  *
  */
  PROCEDURE delete_identity_map
               (identity_factor_name  IN varchar2,
                identity_factor_value IN varchar2,
                parent_factor_name    IN varchar2,
                child_factor_name     IN varchar2,
                operation             IN varchar2,
                operand1              IN varchar2,
                operand2              IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_identity_map, AUTO_WITH_COMMIT);

  /**Policy Label */

  /**
  * Label an Identity within a MAC OLS Policy.
  *
  * @param identity_factor_name Name of factor being labeled
  * @param identity_factor_value Value of Identity for the Factor being labeled
  * @param policy_name OLS Policy Name
  * @param label OLS Label
  *
  */
  PROCEDURE create_policy_label
              (identity_factor_name  IN varchar2,
               identity_factor_value IN varchar2,
               policy_name           IN varchar2,
               label                 IN varchar2);
               -- algorithm             IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_policy_label, AUTO_WITH_COMMIT);

  /**
  * Remove the Label from an Identity within a MAC OLS Policy.
  *
  * @param identity_factor_name Name of factor being labeled
  * @param identity_factor_value Value of Identity for the Factor being labeled
  * @param policy_name OLS Policy Name
  * @param label OLS Label
  *
  */
  PROCEDURE delete_policy_label
              (identity_factor_name  IN varchar2,
               identity_factor_value IN varchar2,
               policy_name           IN varchar2,
               label                 IN varchar2);
               -- algorithm             IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_policy_label, AUTO_WITH_COMMIT);

  /* MAC Policy Algorithm */

  /**
  * Specify the algorithm that is used to merge labels when computing the label for
  * a Factor, or the MAC OLS Session label.  The algorithm is a 3-letter acronym
  * (e.g. LII, HUU, ...).  Consult OLS documentation for details.
  *
  * @param policy_name OLS Policy Name
  * @param algorithm Merge algorithm
  *
  */
  PROCEDURE create_mac_policy
              (policy_name           IN varchar2,
               algorithm             IN varchar2,
               error_label           IN varchar2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_mac_policy, AUTO_WITH_COMMIT);

  /**
  * Specify the algorithm that is used to merge labels when computing the label for
  * a Factor, or the MAC OLS Session label.  The algorithm is a 3-letter acronym
  * (e.g. LII, HUU, ...).  Consult OLS documentation for details.
  *
  * @param policy_name OLS Policy Name
  * @param algorithm Merge algorithm
  *
  */
  PROCEDURE update_mac_policy
              (policy_name  IN varchar2,
               algorithm             IN varchar2,
               error_label           IN varchar2 DEFAULT NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_mac_policy, AUTO_WITH_COMMIT);

  /**
  * Deletes all DV objects related to an OLS policy.  This method should be called
  * after an OLS policy has been deleted to ensure that there are not any broken
  * references between DV and OLS.  Note that there is not any referential integrity
  * constraints between DV and OLS.  The affected objects are in the mac_policy$,
  * mac_policy_factor$, and policy_label$ tables.
  *
  * @param policy_name OLS Policy Name
  *
  */
  PROCEDURE delete_mac_policy_cascade(policy_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_mac_policy_cascade, AUTO_WITH_COMMIT);

  /* Realm */

  /**
  * Create a Realm
  *
  * @param realm_name Realm name
  * @param description Realm description
  * @param enabled Indication of whether the realm checking is on or off (g_yes/g_no)
  * @param audit_options How to audit realm (described in dbms_macutl)
  * @param realm_type Realm type
  * @param realm_scope Realm scope
  * @param pl_sql_stack Indication of whether to record PL/SQL stack
  *
  */
  PROCEDURE create_realm
              (realm_name  IN varchar2,
               description IN varchar2,
               enabled IN varchar2,
               audit_options IN number,
               realm_type    IN number default NULL,
               realm_scope   IN number := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack  IN boolean default FALSE) ;
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_realm, AUTO_WITH_COMMIT);

  /**
  * Update a Realm
  *
  * @param realm_name Realm name
  * @param description Realm description
  * @param enabled Indication of whether the realm checking is on or off (g_yes/g_no)
  * @param audit_options How to audit realm (described in dbms_macutl)
  * @param realm_type Realm type
  * @param realm_scope Realm scope
  * 
  */
  PROCEDURE update_realm
              (realm_name  IN varchar2,
               description IN varchar2,
               enabled IN varchar2,
               audit_options IN number default NULL,
               realm_type    IN number default NULL,
               pl_sql_stack  IN boolean default NULL) ;
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_realm, AUTO_WITH_COMMIT);

  /**
  * Rename a Realm
  *
  * @param realm_name Realm name
  * @param new_name New Realm name
  * @param realm_scope Realm scope
  *
  */
  PROCEDURE rename_realm
              (realm_name  IN varchar2,
               new_name    IN varchar2) ;
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_realm, AUTO_WITH_COMMIT);

  /**
  * Drop a Realm
  *
  * @param realm_name Realm name
  * @param realm_scope Realm scope
  *
  */
  PROCEDURE delete_realm
              (realm_name  IN varchar2) ;
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_realm, AUTO_WITH_COMMIT);

  /**
  * Deletes a DV realm, including the related Realm objects (realm_object$),
  * and authorizations (realm_auth$).
  *
  * @param realm_name Realm name
  * @param realm_scope Realm scope
  *
  */
  PROCEDURE delete_realm_cascade
              (realm_name  IN varchar2) ;
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_realm_cascade, AUTO_WITH_COMMIT);

  /**
  * Authorize a user or role to access a realm as a participant or owner.  The
  * authorization can be made conditional based on a Rule Set (i.e. only authorized
  * if the Rule Set evaluates to TRUE).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  * @param realm_scope Realm scope
  * @param auth_scope Authorization scope
  *
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2,
               auth_options  IN number,
               auth_scope    IN number := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_auth_to_realm, AUTO_WITH_COMMIT);

  /**
  * Authorize a user or role to access a realm as a participant.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  *
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2);

  /**
  * Authorize a user or role to access a realm as an owner or participant (no Rule Set).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  *
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               auth_options  IN number);

  /**
  * Authorize a user or role to access a realm as a participant (optional).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  *
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2);

  /**
  * Remove the authorization of a user or role to access a realm.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param realm_scope Realm scope
  * @param auth_scope Authorization scope
  *
  */
  PROCEDURE delete_auth_from_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               auth_scope    IN number := dvsys.dbms_macutl.g_scope_local);
               -- rule_set_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_auth_from_realm, AUTO_WITH_COMMIT);

  /**
  * Update the authorization of a user or role to access a realm.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  * @param realm_scope Realm scope
  * @param auth_scope Authorization scope
  *
  */
  PROCEDURE update_realm_auth
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2,
               auth_options  IN number,
               auth_scope    IN number := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_realm_auth, AUTO_WITH_COMMIT);

  /**
  * Register a set of objects for Realm protection.
  *
  * @param realm_name Realm name
  * @param object_owner Object owner
  * @param object_name Object name (Wild card % is allowed)
  * @param object_type Object type (Wild card % is allowed)
  * @param realm_scope Realm scope
  *
  */
  PROCEDURE add_object_to_realm
              (realm_name    IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               object_type   IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_object_to_realm, AUTO_WITH_COMMIT);

  /**
  * Remove a set of objects from Realm protection.
  *
  * @param realm_name Realm name
  * @param object_owner Object owner
  * @param object_name Object name (Wild card % is allowed)
  * @param object_type Object type (Wild card % is allowed)
  * @param realm_scope Realm scope
  *
  */
  PROCEDURE delete_object_from_realm
              (realm_name    IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               object_type   IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_object_from_realm, AUTO_WITH_COMMIT);

  /**
  * Enable/disable Event
  *
  * @param enable
  *
  */
  PROCEDURE enable_event(event IN number);
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_event, NONE);

  PROCEDURE disable_event(event IN number);
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_event, NONE);

  /* Rule Set */

  /**
  * Create a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param description Description
  * @param enabled Whether to evaluate Rule Set or ignore it
  * @param eval_options Evaluation options (see dbms_macutl)
  * @param audit_options Audit options (see dbms_macutl)
  * @param fail_options Fail options (see dbms_macutl)
  * @param fail_message Error message for failure
  * @param fail_code Error code to return on failure
  * @param handler_options Handler options (see dbms_macutl)
  * @param handler Handler method
  *
  */
  PROCEDURE create_rule_set
              (rule_set_name   IN varchar2,
               description     IN varchar2,
               enabled         IN varchar2,
               eval_options    IN number,
               audit_options   IN number,
               fail_options    IN number,
               fail_message    IN varchar2,
               fail_code       IN number,
               handler_options IN number,
               handler         IN varchar2,
               is_static       IN boolean default false,
               scope           IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_rule_set, AUTO_WITH_COMMIT);

  /**
  * Update a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param description Description
  * @param enabled Whether to evaluate Rule Set or ignore it
  * @param eval_options Evaluation options (see dbms_macutl)
  * @param audit_options Audit options (see dbms_macutl)
  * @param fail_options Fail options (see dbms_macutl)
  * @param fail_message Error message for failure
  * @param fail_code Error code to return on failure
  * @param handler_options Handler options (see dbms_macutl)
  * @param handler Handler method
  *
  */
  PROCEDURE update_rule_set
              (rule_set_name   IN varchar2,
               description     IN varchar2,
               enabled         IN varchar2,
               eval_options    IN number,
               audit_options   IN number,
               fail_options    IN number,
               fail_message    IN varchar2,
               fail_code       IN number,
               handler_options IN number,
               handler         IN varchar2,
               is_static       IN boolean default false);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_rule_set, AUTO_WITH_COMMIT);

  /**
  * Rename a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param new_name New rule set name
  *
  */
  PROCEDURE rename_rule_set
              (rule_set_name IN varchar2,
               new_name      IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_rule_set, AUTO_WITH_COMMIT);

  /**
  * Delete a Rule Set.
  *
  * @param rule_set_name Rule Set name
  *
  */
  PROCEDURE delete_rule_set
              (rule_set_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_rule_set, AUTO_WITH_COMMIT);

  /**
  * Add a Rule to a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  * @param rule_order Order of evaluation for Rule in Rule Set
  * @param enabled Whether or not the Rule is enabled
  *
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2,
               rule_order    IN number,
               enabled       IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_rule_to_rule_set, AUTO_WITH_COMMIT);

  /**
  * Add an enabled Rule to a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  * @param rule_order Order of evaluation for Rule in Rule Set
  *
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2,
               rule_order    IN number);

  /**
  * Add an enabled Rule to the end of Rule Set (i.e. evaluated last).
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  *
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2);

  /**
  * Delete a Rule from a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  *
  */
  PROCEDURE delete_rule_from_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_rule_from_rule_set, AUTO_WITH_COMMIT);

  /* Rule */

  /**
  * Create a Rule
  *
  * @param rule_name Rule name
  * @param rule_expr PL/SQL Boolean expression
  *
  */
  PROCEDURE create_rule
              (rule_name  IN varchar2,
               rule_expr  IN varchar2,
               scope      IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_rule, AUTO_WITH_COMMIT);

  /**
  * Update a Rule
  *
  * @param rule_name Rule name
  * @param rule_expr PL/SQL Boolean expression
  *
  */
  PROCEDURE update_rule
              (rule_name  IN varchar2,
               rule_expr  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_rule, AUTO_WITH_COMMIT);

  /**
  * Rename a Rule
  *
  * @param rule_name Rule name
  * @param new_name New Rule name
  *
  */
  PROCEDURE rename_rule
              (rule_name  IN varchar2,
               new_name   IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_rule, AUTO_WITH_COMMIT);

  /**
  * Delete a Rule
  *
  * @param rule_name Rule name
  *
  */
  PROCEDURE delete_rule
              (rule_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_rule, AUTO_WITH_COMMIT);

  /* Role */

  /**
  * Create a DV Secure Application Role.  Access to the role is protected
  * by a Rule Set.
  *
  * @param role_name Role name
  * @param enabled Whether the role is enabled or diabled
  * @param rule_set_name Rule Set to determine whether a user can set the role
  *
  *
  */
  PROCEDURE create_role
              (role_name IN varchar2,
               enabled   IN varchar2,
               rule_set_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_role, AUTO_WITH_COMMIT);

  /**
  * Delete a DV Secure Application Role.
  *
  * @param role_name Role name
  *
  *
  */
  PROCEDURE delete_role
              (role_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_role, AUTO_WITH_COMMIT);

  /**
  * Update a DV Secure Application Role.  Access to the role is protected
  * by a Rule Set.
  *
  * @param role_name Role name
  * @param enabled Whether the role is enabled or diabled
  * @param rule_set_name Rule Set to determine whether a user can set the role
  *
  *
  */
  PROCEDURE update_role
              (role_name IN varchar2,
               enabled   IN varchar2,
               rule_set_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_role, AUTO_WITH_COMMIT);

  /**
  * Rename a DV Secure Application Role.
  *
  * @param role_name Role name
  * @param new_role_name Role name
  *
  *
  */
  PROCEDURE rename_role
              (role_name IN varchar2,
               new_role_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_role, AUTO_WITH_COMMIT);

  /* Command Rule */

  /**
  * Protect a database command by associating it with a Rule Set.  The
  * command can only be executed if the Rule Set evaluates to TRUE.
  *
  * @param command SQL command to protect
  * @param rule_set_name Rule Set to protect command
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  * @param enabled Whether the command rule is enabled or disabled
  * @param clause_name clause name of the ALTER SYSTEM/SESSION command
  * @param parameter_name parameter name of the ALTER SYSTEM/SESSION command clause
  * @param event_name event name of the ALTER SYSTEM/SESSION set events scenario 
  * @param component_name component name of the ALTER SYSTEM/SESSION set events scenario 
  * @param action_name action name of the ALTER SYSTEM/SESSION set events scenario 
  * @param pl_sql_stack Whether to record PL/SQL stack for the command rule
  *
  */
  PROCEDURE create_command_rule
              (command IN varchar2,
               rule_set_name IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               enabled       IN varchar2,
               privilege_scope IN NUMBER DEFAULT NULL,
               clause_name IN varchar2 := '%',
               parameter_name IN varchar2 := '%',
               event_name IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name IN varchar2 := '%',
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack IN boolean default FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_command_rule, AUTO_WITH_COMMIT);

  /**
  * Drop a Command Rule declaration.
  *
  * @param command SQL command to protect
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  * @param clause_name clause name of the ALTER SYSTEM/SESSION command
  * @param parameter_name parameter name of the ALTER SYSTEM/SESSION command clause
  * @param event_name event name of the ALTER SYSTEM/SESSION set events scenario 
  * @param component_name component name of the ALTER SYSTEM/SESSION set events scenario 
  * @param action_name action name of the ALTER SYSTEM/SESSION set events scenario 
  *
  */
  PROCEDURE delete_command_rule
              (command IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               clause_name IN varchar2 := '%',
               parameter_name IN varchar2 := '%',
               event_name IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name IN varchar2 := '%',
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_command_rule, AUTO_WITH_COMMIT);

  /**
  * Update a Command Rule declaration.
  *
  * @param command SQL command to protect
  * @param rule_set_name Rule Set to protect command
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  * @param enabled Whether the command rule is enabled or disabled
  * @param clause_name clause name of the ALTER SYSTEM/SESSION command
  * @param parameter_name parameter name of the ALTER SYSTEM/SESSION command clause
  * @param event_name event name of the ALTER SYSTEM/SESSION set events scenario 
  * @param component_name component name of the ALTER SYSTEM/SESSION set events scenario 
  * @param action_name action name of the ALTER SYSTEM/SESSION set events scenario 
  * @param pl_sql_stack Whether to record PL/SQL stack for the command rule
  *
  */
  PROCEDURE update_command_rule
              (command IN varchar2,
               rule_set_name IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               enabled       IN varchar2,
               privilege_scope IN NUMBER DEFAULT NULL,
               clause_name IN varchar2 := '%',
               parameter_name IN varchar2 := '%',
               event_name IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name IN varchar2 := '%',
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack IN boolean default NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_command_rule, AUTO_WITH_COMMIT);

  /**
  * Create a CONNECT Command Rule declaration.
  *
  * @param user_name Name of the target user
  * @param rule_set_name Rule Set to protect the connection
  * @param enabled Whether the command rule is enabled or disabled
  *
  */
  PROCEDURE create_connect_command_rule
              (user_name     IN varchar2,
               rule_set_name IN varchar2,
               enabled       IN varchar2,
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_connect_command_rule, AUTO_WITH_COMMIT);

  /**
  * Update a CONNECT Command Rule declaration.
  *
  * @param user_name Name of the target user
  * @param rule_set_name Rule Set to protect the connection
  * @param enabled Whether the command rule is enabled or disabled
  *
  */
  PROCEDURE update_connect_command_rule
              (user_name     IN varchar2,
               rule_set_name IN varchar2,
               enabled       IN varchar2,
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_connect_command_rule, AUTO_WITH_COMMIT);

  /**
  * Delete a CONNECT Command Rule declaration.
  *
  * @param user_name Name of the target user
  *
  */
  PROCEDURE delete_connect_command_rule
              (user_name     IN varchar2,
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_connect_command_rule, AUTO_WITH_COMMIT);

  /**
  * Create a session event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SESSION set events scenario 
  * @param component_name component name of the ALTER SESSION set events scenario 
  * @param action_name action name of the ALTER SESSION set events scenario 
  *
  */
  PROCEDURE create_session_event_cmd_rule
              (rule_set_name  IN varchar2,
               enabled        IN varchar2,
               event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack   IN boolean default FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_session_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Update a session event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SESSION set events scenario 
  * @param component_name component name of the ALTER SESSION set events scenario 
  * @param action_name action name of the ALTER SESSION set events scenario 
  * @param pl_sql_stack Whether to record PL/SQL stack for the command rule
  *
  * @throws ORA 20081 Command not found
  * @throws ORA 20100 Command rule already defined
  * @throws ORA 20102 Error creating Command Rule
  */
  PROCEDURE update_session_event_cmd_rule
              (rule_set_name  IN varchar2,
               enabled        IN varchar2,
               event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack   IN boolean default NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_session_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Delete a session event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SESSION set events scenario 
  * @param component_name component name of the ALTER SESSION set events scenario 
  * @param action_name action name of the ALTER SESSION set events scenario 
  *
  */
  PROCEDURE delete_session_event_cmd_rule
              (event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_session_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Create a system event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SYSTEM set events scenario 
  * @param component_name component name of the ALTER SYSTEM set events scenario 
  * @param action_name action name of the ALTER SYSTEM set events scenario 
  * @param pl_sql_stack Whether to record PL/SQL stack for the command rule
  *
  */
  PROCEDURE create_system_event_cmd_rule
              (rule_set_name  IN varchar2,
               enabled        IN varchar2,
               event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack   IN boolean default FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_system_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Update a system event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SYSTEM set events scenario 
  * @param component_name component name of the ALTER SYSTEM set events scenario 
  * @param action_name action name of the ALTER SYSTEM set events scenario 
  * @param pl_sql_stack Whether to record PL/SQL stack for the command rule
  *
  * @throws ORA 20081 Command not found
  * @throws ORA 20100 Command rule already defined
  * @throws ORA 20102 Error creating Command Rule
  */
  PROCEDURE update_system_event_cmd_rule
              (rule_set_name  IN varchar2,
               enabled        IN varchar2,
               event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local,
               pl_sql_stack   IN boolean default NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_system_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Delete a system event command rule declaration
  *
  * @param rule_set_name Rule Set to protect command
  * @param enabled Whether the command rule is enabled or disabled
  * @param event_name event name of the ALTER SYSTEM set events scenario 
  * @param component_name component name of the ALTER SYSTEM set events scenario 
  * @param action_name action name of the ALTER SYSTEM set events scenario 
  *
  */
  PROCEDURE delete_system_event_cmd_rule
              (event_name     IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name    IN varchar2 := '%',
               scope          IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_system_event_cmd_rule, AUTO_WITH_COMMIT);

  /**
  * Returns information from the sys.v_$instance view.
  *
  *  @param p_parameter Column name in sys.v_$instance
  *  @return Value of column p_parameter in sys.v_$instance
  */
  FUNCTION get_instance_info(p_parameter IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Returns information from the sys.v_$session view for the current session
  *
  *  @param p_parameter Column name in sys.v_$session
  *  @return Value of column p_parameter in sys.v_$session
  */
  FUNCTION get_session_info(p_parameter IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Add a RAC database node to a domain. If the identity for the domain does
  * not exist the identity will be added.
  * Creates the required identity map information for the database hostname provided.
  * If the OLS policy is provided, domain will be added as a policy factor
  * if it is not already associated. If the label for the identity of this domain
  * does not exist the label will be added.
  * This call must be made with the instance running on the host specified.
  *
  * @param domain_name Name of the domain to add the host to
  * @param domain_host RAC host name being added to the domain
  * @param policy_name OLS Policy Name to label the domain for
  * @param label OLS Label to label the domain within this policy
  *
  */
  PROCEDURE create_domain_identity
              (domain_name IN varchar2,
               domain_host IN varchar2,
               policy_name IN varchar2 DEFAULT NULL,
               domain_label IN varchar2 DEFAULT NULL
               );
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_domain_identity, AUTO_WITH_COMMIT);

  /**
  * Remove a RAC database node from a domain.
  * Creates the required identity map information for the database hostname provided.
  *
  * @param domain_name Name of the domain to add the host to
  * @param domain_host RAC host name being added to the domain
  *
  */
  PROCEDURE drop_domain_identity
              (domain_name IN varchar2,
               domain_host IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_domain_identity, AUTO_WITH_COMMIT);

  /**
  * Returns the character set for the database
  *
  * @return character set for the database
  */
  FUNCTION get_db_charset RETURN VARCHAR2;

  /**
  * Returns the 3 character Oracle language for the current administration session
  * Based on set_ora_lang_from_java
  *
  * @return 3 character oracle language identifier for the administration current session
  */
  FUNCTION get_ora_lang RETURN VARCHAR2;

  /**
  * check to see if alter system set system_trig_enabled
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_trig_parm_varchar RETURN VARCHAR2;
 
  /**
  * check to see if following O7_DICTIONARY_ACCESSIBILITY 
  * is allowed: 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_o7_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if alter system set _dynamic_rls_policies
  * are allowed 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_dynrls_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if following ALTER SYSTEM security system parameters
  * are allowed :
  *    _SYSTEM_TRIG_ENABLED POLICIES
  *    O7_DICTIONARY_ACCESSIBILITY 
  *    _DYNAMIC_RLS_POLICIES 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_sys_sec_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if following ALTER SYSTEM dump or dest parameters
  * are allowed :
  *    MAX_DUMP_FILE_SIZE
  *    %DUMP%
  *    %_DEST%
  *    LOG_ARCHIVE%
  *    STANDBY_ARCHIVE%
  *    DB_RECOVERY_FILE_DEST_SIZE
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_dump_dest_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM backup restore parameters
  * are allowed :
  *    RECYCLEBIN
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_backup_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM database file parameters
  * are allowed :
  *    CONTROL_FILES
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_db_file_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM optimizer parameters
  * are allowed :
  *    OPTIMIZER_SECURE_VIEW_MERGING
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_optimizer_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM plsql parameters
  * are allowed :
  *    UTL_FILE_DIR
  *    PLSQL_DEBUG
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_plsql_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM security parameters
  * are allowed :
  *    AUDIT_SYS_OPERATIONS
  *    AUDIT_TRAIL
  *    AUDIT_SYSLOG_LEVEL
  *    REMOTE_OS_ROLES
  *    OS_ROLES
  *    SQL92_SECURITY
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_security_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if alter dvsys
  *
  * return 'Y' or 'N'
  */
  FUNCTION is_alter_user_allow_varchar(login_user VARCHAR2) RETURN VARCHAR2;

  FUNCTION is_drop_user_allow_varchar(login_user VARCHAR2) RETURN VARCHAR2;

  PROCEDURE authorize_datapump_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL,
       objname     IN VARCHAR2 DEFAULT NULL,
       action      IN VARCHAR2 DEFAULT NULL 
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_datapump_user, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_datapump_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL,
       objname     IN VARCHAR2 DEFAULT NULL,
       action      IN VARCHAR2 DEFAULT NULL 
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_datapump_user, AUTO_WITH_COMMIT);

  PROCEDURE auth_datapump_create_user(uname IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(auth_datapump_create_user, AUTO_WITH_COMMIT);

  PROCEDURE unauth_datapump_create_user(uname IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauth_datapump_create_user, AUTO_WITH_COMMIT);

  PROCEDURE auth_datapump_grant(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT '%'
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(auth_datapump_grant, AUTO_WITH_COMMIT);

  PROCEDURE unauth_datapump_grant(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT '%'
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauth_datapump_grant, AUTO_WITH_COMMIT);

  PROCEDURE authorize_tts_user(
       uname       IN VARCHAR2,
       tsname      IN VARCHAR2
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_tts_user, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_tts_user(
       uname       IN VARCHAR2,
       tsname      IN VARCHAR2
  );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_tts_user, AUTO_WITH_COMMIT);

  /* API to authorize a user to run jobs in the schema of other users. */
  PROCEDURE authorize_scheduler_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL
   );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_scheduler_user, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_scheduler_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL
   );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_scheduler_user, AUTO_WITH_COMMIT);
  
  /* APIs to authorize a user to proxy as another user. */
  PROCEDURE authorize_proxy_user
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_proxy_user, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_proxy_user
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_proxy_user, AUTO_WITH_COMMIT);

  /* APIs to authorize a user to execute DDLs on another user's schema. */
  PROCEDURE authorize_ddl
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_ddl, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_ddl
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_ddl, AUTO_WITH_COMMIT);

  /* APIs to authorize a user to execute PREPROCESSOR directive in external 
   * tables. 
   */
  PROCEDURE authorize_preprocessor
           ( uname       IN VARCHAR2 
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_preprocessor, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_preprocessor
           ( uname       IN VARCHAR2 
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_preprocessor, AUTO_WITH_COMMIT);

  /* APIs to authorize a user to execute maintenance related DDLs. */
  PROCEDURE authorize_maintenance_user
           ( uname       IN VARCHAR2,
             sname       IN VARCHAR2 DEFAULT NULL,
             objname     IN VARCHAR2 DEFAULT NULL,
             objtype     IN VARCHAR2 DEFAULT '%',
             action      IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_maintenance_user, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_maintenance_user
           ( uname       IN VARCHAR2,
             sname       IN VARCHAR2 DEFAULT NULL,
             objname     IN VARCHAR2 DEFAULT NULL,
             objtype     IN VARCHAR2 DEFAULT '%',
             action      IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_maintenance_user, AUTO_WITH_COMMIT);

  -- APIs to authorize a user as diagnostic admin who can access the following
  -- fixed tables/views: v$diag_trace_File_contents, v$diag_opt_trace_records,
  -- v$diag_sess_opt_trace_records, x$dbgtfview, x$dbgtfoptt, x$dbgtfsoptt.
  -- Note that the list above is as of 12.2, and additional tables/views may
  -- be added later in the future.
  PROCEDURE authorize_diagnostic_admin
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_diagnostic_admin, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_diagnostic_admin
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_diagnostic_admin, AUTO_WITH_COMMIT);

  -- Add a function to the index functions list for function based index.
  PROCEDURE add_index_function
           ( objname     IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_index_function, AUTO_WITH_COMMIT);

 -- Delete a function from the index functions list for function based index.
  PROCEDURE delete_index_function
           ( objname     IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_index_function, AUTO_WITH_COMMIT);

  /* APIs to authorize a user to connect another user's session to a PL/SQL
   * debugger.
   */
  PROCEDURE authorize_debug_connect
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_debug_connect, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_debug_connect
           ( uname       IN VARCHAR2 ,
             sname       IN VARCHAR2 DEFAULT NULL
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_debug_connect, AUTO_WITH_COMMIT);

  /* BUG FIX 10225918 - Procedure to insert DV metadata in supported languages. 
   Supported input Language values are :
   ENGLISH
   GERMAN
   SPANISH
   FRENCH
   ITALIAN
   JAPANESE
   KOREAN
   BRAZILIAN PORTUGUESE
   SIMPLIFIED CHINESE
   TRADITIONAL CHINESE
  */
  PROCEDURE add_nls_data(
       lang         IN VARCHAR2
   );
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_nls_data, AUTO_WITH_COMMIT);

  /*
  * Enable/disable DV enforcement
  */

  PROCEDURE enable_dv(strict_mode IN VARCHAR2 DEFAULT 'N');
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_dv, AUTO_WITH_COMMIT);

  PROCEDURE disable_dv;
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_dv, AUTO_WITH_COMMIT);

  -- Control ORADEBUG in Database Vault environment
  PROCEDURE enable_oradebug;
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_oradebug, AUTO_WITH_COMMIT);

  PROCEDURE disable_oradebug;
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_oradebug, AUTO_WITH_COMMIT);

  -- Control whether user can log into DVSYS and DVF accounts
  PROCEDURE enable_dv_dictionary_accts;
  PRAGMA SUPPLEMENTAL_LOG_DATA(enable_dv_dictionary_accts, AUTO_WITH_COMMIT);

  PROCEDURE disable_dv_dictionary_accts;
  PRAGMA SUPPLEMENTAL_LOG_DATA(disable_dv_dictionary_accts, AUTO_WITH_COMMIT);

  /**
  * Create a Database Vault policy
  *
  * @param policy_name:  Policy name
  * @param description:  Policy description
  * @param policy_state: Initial state of policy (DBMS_MACADM.G_DISABLED,
  *                                               DBMS_MACADM.G_ENABLED,
  *                                               DBMS_MACADM.G_SIMULATION,
  *                                               DBMS_MACADM.G_PARTIAL)
  * @param pl_sql_stack: Whether to record PL/SQL stack for the policy (TRUE,
  *                                                                     FALSE)
  */
  PROCEDURE create_policy
              (policy_name  IN varchar2,
               description  IN varchar2,
               policy_state IN number,
               pl_sql_stack IN boolean default FALSE);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_policy, AUTO_WITH_COMMIT);

  /**
  * Update the description of exiting Database Vault policy
  *
  * @param policy_name: Policy name
  * @param description: Policy description
  */
  PROCEDURE update_policy_description
              (policy_name IN varchar2,
               description IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_policy_description, AUTO_WITH_COMMIT);

  /**
  * Rename exiting Database Vault policy
  *
  * @param policy_name:     Policy name
  * @param new_policy_name: New policy name
  */
  PROCEDURE rename_policy
              (policy_name     IN varchar2, 
               new_policy_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(rename_policy, AUTO_WITH_COMMIT);

  /**
  * Drop exiting Database Vault policy
  *
  * @param policy_name:     Policy name
  */
  PROCEDURE drop_policy
              (policy_name IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_policy, AUTO_WITH_COMMIT);

  /**
  * Update the state of existing Database Vault policy
  *
  * @param policy_name:  Policy name
  * @param policy_state: Policy state (DBMS_MACADM.G_DISABLED,
  *                                    DBMS_MACADM.G_ENABLED,
  *                                    DBMS_MACADM.G_SIMULATION,
  *                                    DBMS_MACADM.G_PARTIAL)
  * @param pl_sql_stack: Whether to record PL/SQL stack for the policy (TRUE,
  *                                                                     FALSE)
  */
  PROCEDURE update_policy_state
              (policy_name         IN varchar2,
               policy_state        IN number,
               pl_sql_stack        IN boolean default NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_policy_state, AUTO_WITH_COMMIT);

  /**
  * Add a realm to Database Vault policy
  *
  * @param policy_name: Policy name
  * @param realm_name:  Realm name
  */
  PROCEDURE add_realm_to_policy
              (policy_name IN varchar2, 
               realm_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_realm_to_policy, AUTO_WITH_COMMIT);

  /**
  * Delete a realm from Database Vault policy
  *
  * @param policy_name: Policy name
  * @param realm_name:  Realm name
  */
  PROCEDURE delete_realm_from_policy
              (policy_name IN varchar2,
               realm_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_realm_from_policy, AUTO_WITH_COMMIT);

  /**
  * Add a command rule to Database Vault policy
  *
  * @param policy_name:     Policy name
  * @param command:         Command
  * @param object_owner:    Object owner
  * @param object_name:     Object name
  * @param clause_name:     Clause name
  * @param parameter_name:  Parameter name
  * @param event_name:      Event name
  * @param component_name:  Component name
  * @param action_name:     Action name
  */
  PROCEDURE add_cmd_rule_to_policy
              (policy_name  IN varchar2,    
               command      IN varchar2,
               object_owner IN varchar2,
               object_name  IN varchar2,
               clause_name IN varchar2 := '%',
               parameter_name IN varchar2 := '%',
               event_name IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name IN varchar2 := '%',
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_cmd_rule_to_policy, AUTO_WITH_COMMIT);

  /**
  * Delete a command rule from Database Vault policy
  * 
  * @param policy_name:     Policy name
  * @param command:         Command
  * @param object_owner:    Object owner
  * @param object_name:     Object name
  * @param clause_name:     Clause name
  * @param parameter_name:  Parameter name
  * @param event_name:      Event name
  * @param component_name:  Component name
  * @param action_name:     Action name
  */
  PROCEDURE delete_cmd_rule_from_policy
              (policy_name  IN varchar2,
               command      IN varchar2,
               object_owner IN varchar2,
               object_name  IN varchar2,
               clause_name IN varchar2 := '%',
               parameter_name IN varchar2 := '%',
               event_name IN varchar2 := '%',
               component_name IN varchar2 := '%',
               action_name IN varchar2 := '%',
               scope IN NUMBER := dvsys.dbms_macutl.g_scope_local);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_cmd_rule_from_policy, AUTO_WITH_COMMIT);

  /**
  * Add an owner to Database Vault policy
  *
  * @param policy_name: Policy name
  * @param owner_name:  Policy owner name
  */
  PROCEDURE add_owner_to_policy
              (policy_name IN varchar2,
               owner_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(add_owner_to_policy, AUTO_WITH_COMMIT);

  /**
  * Delete an owner from Database Vault policy
  *
  * @param policy_name: Policy name
  * @param owner_name:  Policy owner name
  */
  PROCEDURE delete_owner_from_policy
              (policy_name IN varchar2,
               owner_name  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(delete_owner_from_policy, AUTO_WITH_COMMIT);
  
  -- APIs to authorize a user as Database Replay admin to run capture and
  -- replay
  PROCEDURE authorize_dbcapture
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_dbcapture, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_dbcapture
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_dbcapture, AUTO_WITH_COMMIT);

  PROCEDURE authorize_dbreplay
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(authorize_dbreplay, AUTO_WITH_COMMIT);

  PROCEDURE unauthorize_dbreplay
           ( uname       IN VARCHAR2
           );
  PRAGMA SUPPLEMENTAL_LOG_DATA(unauthorize_dbreplay, AUTO_WITH_COMMIT);


END;
/

SHOW ERRORS;

Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for Data Vault Audit APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macaud AS

  /*********************/
  /*  Global Constants */
  /*********************/

  PROCEDURE create_admin_audit(actcode  IN PLS_INTEGER,
                               actobjnm IN varchar2,
                               actobjid IN PLS_INTEGER,
                               actcmd   IN varchar2,
                               retcode  IN PLS_INTEGER,
                               rsetid   IN PLS_INTEGER,
                               comment  IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_admin_audit, AUTO);

END;
/

SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC APIs for evaluating rules
Rem
Rem
Rem
Rem
Rem

/**
 * Package for capturing transient event data
 */
-- Fix for Bug 6068504: The procedures below are used to load the session
-- information to SYS_CONTEXT. The load information can be retrieved from
-- SYS_CONTEXT through designated procedures (e.g., dvsys.DV_SYSEVENT) 
-- during rule evaluation.
CREATE OR REPLACE PACKAGE dvsys.event IS

 PROCEDURE set_c (P_SYSEVENT        VARCHAR2,
                  P_LOGIN_USER      VARCHAR2,
                  P_INSTANCE_NUM    VARCHAR2,
                  P_DATABASE_NAME   VARCHAR2,
                  P_DICT_OBJ_TYPE   VARCHAR2,
                  P_DICT_OBJ_OWNER  VARCHAR2,
                  P_DICT_OBJ_NAME   VARCHAR2,
                  P_SQL_TEXT        VARCHAR2);
 PRAGMA SUPPLEMENTAL_LOG_DATA(set_c, NONE);

 PROCEDURE set (P_SYSEVENT        VARCHAR2,
                P_LOGIN_USER      VARCHAR2,
                P_INSTANCE_NUM    NUMBER,
                P_DATABASE_NAME   VARCHAR2,
                P_DICT_OBJ_TYPE   VARCHAR2,
                P_DICT_OBJ_OWNER  VARCHAR2,
                P_DICT_OBJ_NAME   VARCHAR2,
                P_SQL_TEXT        VARCHAR2);
 PRAGMA SUPPLEMENTAL_LOG_DATA(set, NONE);

 PROCEDURE setdefault;
 PRAGMA SUPPLEMENTAL_LOG_DATA(setdefault, NONE);

END event;
/

CREATE OR REPLACE PACKAGE BODY dvsys.event AS

 PROCEDURE set_c (P_SYSEVENT        VARCHAR2,
                  P_LOGIN_USER      VARCHAR2,
                  P_INSTANCE_NUM    VARCHAR2,
                  P_DATABASE_NAME   VARCHAR2,
                  P_DICT_OBJ_TYPE   VARCHAR2,
                  P_DICT_OBJ_OWNER  VARCHAR2,
                  P_DICT_OBJ_NAME   VARCHAR2,
                  P_SQL_TEXT        VARCHAR2) 
 IS LANGUAGE C
   NAME "kzvdvssetup"
   LIBRARY DVSYS.KZV$RUL_LIBT
   WITH CONTEXT
   PARAMETERS (CONTEXT, 
               P_SYSEVENT, P_SYSEVENT INDICATOR, 
               P_LOGIN_USER, P_LOGIN_USER INDICATOR, 
               P_INSTANCE_NUM, P_INSTANCE_NUM INDICATOR, 
               P_DATABASE_NAME, P_DATABASE_NAME INDICATOR, 
               P_DICT_OBJ_TYPE, P_DICT_OBJ_TYPE INDICATOR, 
               P_DICT_OBJ_OWNER, P_DICT_OBJ_OWNER INDICATOR,
               P_DICT_OBJ_NAME, P_DICT_OBJ_NAME INDICATOR, 
               P_SQL_TEXT, P_SQL_TEXT INDICATOR);

 PROCEDURE set (P_SYSEVENT        VARCHAR2,
                P_LOGIN_USER      VARCHAR2,
                P_INSTANCE_NUM    NUMBER,
                P_DATABASE_NAME   VARCHAR2,
                P_DICT_OBJ_TYPE   VARCHAR2,
                P_DICT_OBJ_OWNER  VARCHAR2,
                P_DICT_OBJ_NAME   VARCHAR2,
                P_SQL_TEXT        VARCHAR2) AS
   l_loginuser VARCHAR2(128);
   l_instancenum VARCHAR2(100);
   l_sqltext VARCHAR2(4000);
 BEGIN
   IF (P_LOGIN_USER IS NULL) OR (LENGTH(P_LOGIN_USER) = 0) THEN
      l_loginuser := SYS_CONTEXT ( 'USERENV','SESSION_USER' );
   ELSE 
      l_loginuser := P_LOGIN_USER;
   END IF;

   l_instancenum := TO_CHAR(P_INSTANCE_NUM);

   IF (P_SQL_TEXT IS NOT NULL) THEN
      l_sqltext := SUBSTRB(UPPER(P_SQL_TEXT), 1, 4000);
   ELSE 
      l_sqltext := '';
   END IF;

   dvsys.event.set_c(P_SYSEVENT, l_loginuser, l_instancenum, P_DATABASE_NAME, 
                     P_DICT_OBJ_TYPE, P_DICT_OBJ_OWNER, P_DICT_OBJ_NAME, l_sqltext);
 END;

 PROCEDURE setdefault AS
 BEGIN
   dvsys.event.set(SYS.SYSEVENT, SYS.LOGIN_USER, SYS.INSTANCE_NUM, SYS.DATABASE_NAME,
                   SYS.DICTIONARY_OBJ_TYPE, SYS.DICTIONARY_OBJ_OWNER, SYS.DICTIONARY_OBJ_NAME, '');
 END; 
END event;
/

/*
 * Utility functions to return event data for rule evaluation
 */
create or replace function dvsys.DV_SYSEVENT return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'SYSEVENT');
end;
/

create or replace function dvsys.DV_LOGIN_USER return VARCHAR2 as
begin
   -- Fix for Bug 6068504
   return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'LOGIN_USER');
end;
/

create or replace function dvsys.DV_INSTANCE_NUM return NUMBER as
begin  
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'INSTANCE_NUM');
end;
/

create or replace function dvsys.DV_DATABASE_NAME return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DATABASE_NAME');
end;
/

create or replace function dvsys.DV_DICT_OBJ_TYPE return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_TYPE');
end;
/

create or replace function dvsys.DV_DICT_OBJ_OWNER return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_OWNER');
end;
/

create or replace function dvsys.DV_DICT_OBJ_NAME return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_NAME');
end;
/

create or replace function dvsys.DV_SQL_TEXT return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'SQL_TEXT');
end;
/

create or replace function dvsys.DV_JOB_INVOKER return VARCHAR2 as
begin  
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'JOB_INVOKER');
end;
/

create or replace function dvsys.DV_JOB_OWNER return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'JOB_OWNER');
end;
/

create or replace function dvsys.CLAUSE_NAME return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'CLAUSE_NAME');
end;
/

create or replace function dvsys.PARAMETER_NAME return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'PARAMETER_NAME');
end;
/

create or replace function dvsys.PARAMETER_VALUE return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'PARAMETER_VALUE');
end;
/

create or replace function dvsys.EVENT_NAME return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'EVENT_NAME');
end;
/

create or replace function dvsys.EVENT_LEVEL return VARCHAR2 as
begin
  return TO_NUMBER(SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'EVENT_LEVEL'));
end;
/

create or replace function dvsys.EVENT_TARGET return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'EVENT_TARGET');
end;
/

create or replace function dvsys.EVENT_ACTION return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'EVENT_ACTION');
end;
/

create or replace function dvsys.EVENT_ACTION_LEVEL return VARCHAR2 as
begin
  return TO_NUMBER(SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'EVENT_ACTION_LEVEL'));
end;
/

--  Bug 20313334: return the required privilege/role appropriate scope
--                based on the current container.
--  1. CDB$ROOT or App Root       -> COMMON
--  2. Legacy DB, PDB, or App PDB -> LOCAL
create or replace function dvsys.GET_REQUIRED_SCOPE return VARCHAR2 as
  checkScope varchar2(12) := 'LOCAL';
  l_con_id number;
  isAppRoot varchar(3);  
begin
  select sys_context('USERENV','CON_ID') into l_con_id from sys.dual;

  IF l_con_id = 0 THEN    --legacy db
    checkScope := 'LOCAL';
  ELSIF l_con_id = 1 THEN -- cdb$root
    checkScope := 'COMMON';
  ELSE
    select sys_context('USERENV','IS_APPLICATION_ROOT') into isAppRoot from sys.dual;
    IF isAppRoot = 'YES' THEN -- app root
      checkScope := 'COMMON';
    ELSE                  -- pdb
      checkScope := 'LOCAL';
    END IF;
  END IF;
  
  return checkScope;
end;
/

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_rules AS

  /**
  * Evaluates a Rule Set in accordance with the options specified in the
  * rule_set$ table.
  * @param p_rule_set Rule Set Name
  * @param x_result Whether Rule Set evaluated to TRUE or FALSE.  Note: NULL result returns as FALSE
  * @param x_rule Name of last Rule evaluated
  * @param x_rule_error True if a rule raised an error
  * @param x_handler_error True if the rule set handler raised an error
  * @param x_error_code If x_rule_error or x_handler_error, returns the error code
  * @param x_error_text If x_rule_error or x_handler_error, returns the error code
  */
  PROCEDURE evaluate(p_rule_set      IN  VARCHAR2,
                     p_sql_text      IN  VARCHAR2,
                     x_result        OUT BOOLEAN,
                     x_rule          OUT VARCHAR2,
                     x_rule_error    OUT BOOLEAN,
                     x_handler_error OUT BOOLEAN,
                     x_error_code    OUT NUMBER,
                     x_error_text    OUT VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(evaluate, NONE);

  PROCEDURE evaluate_tr(p_rule_set    IN NUMBER,
                        p_eval_ret    IN OUT BINARY_INTEGER,
                        p_error_code  IN OUT BINARY_INTEGER,
                        p_error_text  IN OUT VARCHAR2) as
    LANGUAGE C
    NAME "kzvdversetev"
    LIBRARY DVSYS.KZV$RUL_LIBT
    WITH CONTEXT PARAMETERS(context, p_rule_set OCINUMBER, p_eval_ret,
                            p_error_code, p_error_text);
  PRAGMA SUPPLEMENTAL_LOG_DATA(evaluate_tr, NONE);


  /**
  * This is a temporary wrapper for evaluate.  OCI cannot pass BOOLEAN
  * variables to or from PL/SQL.  Therefore, we need a wrapper that
  * converts booleans to integers.
  */
  PROCEDURE evaluate_wr(p_rule_set      IN  VARCHAR2,
                         x_result        OUT INTEGER,
                         x_rule          OUT VARCHAR2,
                         x_rule_error    OUT INTEGER,
                         x_handler_error OUT INTEGER,
                         x_error_code    OUT NUMBER,
                         x_error_text    OUT VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(evaluate_wr, NONE);

END;
/

show errors;


CREATE OR REPLACE PROCEDURE dvsys.evaluate_rule_set(
                        p_rule_set      IN  VARCHAR2,
                        x_result        OUT INTEGER,
                        x_rule          OUT VARCHAR2,
                        x_rule_error    OUT INTEGER,
                        x_handler_error OUT INTEGER,
                        x_error_code    OUT NUMBER,
                        x_error_text    OUT VARCHAR2)
  IS
    x_result_bool        BOOLEAN;
    x_rule_error_bool    BOOLEAN;
    x_handler_error_bool BOOLEAN;
  BEGIN
    -- buffer overflow checks
    IF (LENGTH(p_rule_set) > 90) THEN
        DVSYS.DBMS_MACUTL.RAISE_ERROR(47951,'p_rule_set');
    END IF;

    DVSYS.DBMS_MACSEC_RULES.EVALUATE(
             p_rule_set,
             NULL,
             x_result_bool,
             x_rule,
             x_rule_error_bool,
             x_handler_error_bool,
             x_error_code,
             x_error_text);

    IF (x_result_bool) THEN
      x_result := 1;
    ELSE
      x_result := 0;
    END IF;

    IF (x_rule_error_bool) THEN
      x_rule_error := 1;
    ELSE
      x_rule_error := 0;
    END IF;

    IF (x_handler_error_bool) THEN
      x_handler_error := 1;
    ELSE
      x_handler_error := 0;
    END IF;
  END;
/

show errors;


Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec AS

  -- Audit action codes
  G_SECURE_ROLE_AUDIT_CODE CONSTANT PLS_INTEGER := 10006;

  /**
  * Set value of a Factor (if allowed by the assignment Rule Set)
  *
  * @param p_factor Factor name
  * @param p_value Value to assign to Factor
  */
  PROCEDURE set_factor(p_factor IN VARCHAR2,
                       p_value  IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_factor, NONE);

  /**
  * Returns the value of a factor.  Note that this method will return the
  * value cached in the context if the eval_option is set for evaluate on
  * session.
  *
  * @param p_factor Factor name
  */
  FUNCTION get_factor(p_factor IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Returns the label of a factor.
  *
  * @param p_factor Factor name
  * @param p_policy_name OLS Policy name
  */
  FUNCTION get_factor_label(p_factor IN VARCHAR2, p_policy_name IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Get Trust Level of a Factor
  *
  * @param p_factor Factor name
  * @return > 0 indicates level of trust, 0 is no trust, < 0 indicates distrust
  */
  FUNCTION get_trust_level(p_factor IN VARCHAR2) RETURN NUMBER;

  /**
  * Get Trust Level of a Factor Identity
  *
  * @param p_factor Factor name
  * @param p_identity Identity value
  * @return > 0 indicates level of trust, 0 is no trust, < 0 indicates distrust
  */
  FUNCTION get_trust_level(p_factor   IN VARCHAR2,
                           p_identity IN VARCHAR2) RETURN NUMBER;

  /**
  * This method determines if a Secure Application Role is enabled
  * for use.
  * @param p_role Role name
  * @return TRUE if a SET ROLE command can be issued
  */
  FUNCTION role_is_enabled(p_role IN VARCHAR2) RETURN BOOLEAN;

  /** Fix for Bug 6441524
  * Checks whether or not the given role is a secure application role
  *
  * @param role name
  * @return TRUE if the role is a secure application role; FALSE otherwise
  */
  FUNCTION is_secure_application_role(p_role VARCHAR2) RETURN BOOLEAN;  

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACOLS APIs
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macols AS

  -- Audit action codes
  G_MAC_OLS_INIT_AUDIT_CODE    CONSTANT PLS_INTEGER := 10009;

  /**
  * Initializes MACOLS and sets the user's session label.  This method should
  * be called during the Login trigger processing, after MACSEC init_session
  * has completed.  This method should only be called if OLS is installed -
  * see dbms_macutl.is_ols_installed.  At a high level, the processing performs
  * the following:
  *
  * for each OLS policy + merge algorithm
  *    determine the user's OLS label for the session;
  *    for each labeled factor loop
  *       compute the label of the factor based on the policy algorithm;
  *    end loop;
  *    merge the factor labels together using the policy algorithm to compute
  *      the maximum possible label for the user's session (MACOLS label);
  *    if the user's OLS label dominates the MAXOLS label then
  *      merge the labels using the algorithm to compute the user's new session label;
  *    end if;
  *  cache the factor labels, MACOLS label, and session labels in the user's context
  *   set the user's session label for the policy;
  * end loop;
  */
  PROCEDURE init_session;
  PRAGMA SUPPLEMENTAL_LOG_DATA(init_session, NONE);

  -- Methods below are exposed temporarily for debugging
  /**
  * Determines the lowest sensitivity level for a policy.
  *
  * @param p_mac_policy_id Id of policy from mac_policy$ table
  * @return Label of lowest sensitivity
  */
  FUNCTION min_policy_label_of(p_mac_policy_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Computes the label of a factor for the specified policy
  *
  * @param p_mac_policy_id Id of policy from mac_policy$ table
  * @return Label of factor
  */
  FUNCTION label_of(p_mac_policy_id IN NUMBER,
                    p_factor_id     IN NUMBER) RETURN VARCHAR2;

  /**
  * Create the contexts used to cache MACOLS labels.  One context is
  * created to cache the labels for each Factor, and another is
  * create to cache session related label values (see dbms_macutl).
  *
  * @param p_policy_name OLS Policy Name
  *
  */
  PROCEDURE create_macols_contexts(p_policy_name IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(create_macols_contexts, AUTO_WITH_COMMIT);

  /**
  * Drop the contexts used to cache MACOLS labels.
  *
  * @param p_policy_name OLS Policy Name
  *
  */
  PROCEDURE drop_macols_contexts(p_policy_name IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(drop_macols_contexts, AUTO_WITH_COMMIT);

  /**
  /**
  * Sets a value in a MACOLS context
  *
  * @param p_policy_name OLS Policy Name
  * @param p_context_type Context name (see dbms_macutl for helpful constants)
  * @param p_label Label value
  */
  PROCEDURE update_policy_label_context(p_policy_name  IN VARCHAR2,
                                        p_context_type IN VARCHAR2,
                                        p_label        IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(update_policy_label_context, NONE);

END;
/
show errors;
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC Secure Application Role Manager
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_roles AUTHID CURRENT_USER AS

  /**
  * Checks whether the user invoking the method is authorized to use
  * the specified DV Secure Application Role.  The authorization is
  * determined by checking the Rule Set associted with the role.
  *
  * @param p_role Secure Application Role name
  * @return TRUE if user is allowed to set the role
  */
  FUNCTION can_set_role(p_role IN VARCHAR2) RETURN BOOLEAN ;

  /**
  * Issues the SET ROLE command for a DV Secure Application Role.  Before
  * the SET ROLE is issued, the can_set_role method is called to check
  * the Rule Set associated with the role.
  *
  * @param p_role Secure Application Role name
  * @throws Exception if user is not authorized
  */
  PROCEDURE set_role(p_role IN VARCHAR2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(set_role, NONE);

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACOLS APIs for integrating into the LBACSYS.SA_SESSION package
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macols_session AS

    -- Audit action codes
    G_MAC_OLS_UPGRADE_AUDIT_CODE CONSTANT PLS_INTEGER := 10010;

    /**
    * Is OLS policy is protected by MAC OLS under DV
    *
    * @param policy_name OLS Policy Name
    */
    FUNCTION is_mac_policy(policy_name VARCHAR2) RETURN NUMBER;
    
    /**
    * Is the max_session_label of the  mac OLS policy set
    *
    * @param policy_name OLS Policy Name    
    */
   FUNCTION is_mac_label_set(policy_name VARCHAR2) RETURN NUMBER;

    /**
    * Can the label be set under MAC OLS for this policy beyond max session label
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    */
    FUNCTION can_set_label(policy_name VARCHAR2,label VARCHAR2) RETURN NUMBER;

    /**
    * Set the MAC OLS session context variable for the attribute specified
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    * @param attribute session context attribute
    */
    PROCEDURE set_policy_label_context(policy_name VARCHAR2,label VARCHAR2,attribute VARCHAR2);
    PRAGMA SUPPLEMENTAL_LOG_DATA(set_policy_label_context, NONE);

    /**
    * Audit invalid attempt to set/change the label for this policy
    * beyond max session label and raise the appropriate exception
    * This procedure is invoked by sa_session.set_label, 
    * sa_session.set_access_profile, sa_session.restore_default_labels 
    * in two cases: a. the label to set is beyond the max session label; 
    * b. the max_session_label is NULL.
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    * @param proc_name Name of the procedure/function invoking this procedure.
    */
    PROCEDURE label_audit_raise(policy_name VARCHAR2 ,
       label VARCHAR2, 
       proc_name VARCHAR2) ;
    PRAGMA SUPPLEMENTAL_LOG_DATA(label_audit_raise, NONE);

    /**
    * MAC OLS processing to merge default session label for the policy
    * with the labels of any factors associated to the policy after the
    * SA_SESSION restore_default_labels method is called
    *
    * @param policy_name OLS Policy Name
    * @param x_session_label resulting session label after the merge
    * @param x_mac_label resulting MAX session label after the merge
    */
    PROCEDURE restore_default_labels(policy_name IN VARCHAR2
           , x_session_label OUT VARCHAR2
           , x_mac_label OUT VARCHAR2) ;
    PRAGMA SUPPLEMENTAL_LOG_DATA(restore_default_labels, NONE);

    /**
    * MAC OLS processing to merge default session label for the policy
    * with the exist MAX session label after the
    * SA_SESSION set_access_profile method is called
    *
    * @param policy_name OLS Policy Name
    * @param user_name OLS Policy User Name
    * @param p_max_session_label existing MAX session label for the policy
    * @param x_new_max_session_label new MAX session label for the policy
    */
    FUNCTION set_access_profile(policy_name VARCHAR2 ,
            user_name VARCHAR2,
            p_max_session_label IN VARCHAR2,
            x_new_session_label OUT VARCHAR2) RETURN NUMBER ;

END;
/
show errors;


Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to check_full_dvauth,
Rem                          check_ts_dvauth,
Rem                          check_tab_dvauth in dbms_macutl package.  
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.check_full_dvauth RETURN BINARY_INTEGER
IS
BEGIN
  RETURN dvsys.dbms_macutl.check_full_dvauth;
END;
/
CREATE OR REPLACE FUNCTION dvsys.check_ts_dvauth
                             (ts_name IN VARCHAR2) RETURN BINARY_INTEGER
IS
BEGIN
  RETURN dvsys.dbms_macutl.check_ts_dvauth(ts_name);
END;
/
CREATE OR REPLACE FUNCTION dvsys.check_tab_dvauth
                             (schema_name IN VARCHAR2,
                              table_name  IN VARCHAR2) RETURN BINARY_INTEGER
IS
BEGIN
  RETURN dvsys.dbms_macutl.check_tab_dvauth(schema_name, table_name);
END;
/
SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to get_factor in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.get_factor
                            (p_factor IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_factor(p_factor => p_factor);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_factor_label
                            (p_factor IN VARCHAR2, p_policy_name IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_factor_label(p_factor => p_factor, p_policy_name => p_policy_name);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_trust_level(p_factor IN VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_trust_level(p_factor => p_factor);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_trust_level_for_identity(p_factor IN VARCHAR2,
                           p_identity IN VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_trust_level(p_factor => p_factor, p_identity => p_identity);
END;
/

SHOW ERRORS;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to init_session in dbms_macols package.  
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PROCEDURE dvsys.macols_init_session
IS
BEGIN
  dvsys.dbms_macols.init_session;
EXCEPTION
  -- Try to suppress stack trace
  WHEN OTHERS THEN
    --RAISE;
    NULL;
END;
/
SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to set_factor in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PROCEDURE dvsys.set_factor(p_factor IN VARCHAR2,
                                       p_value  IN VARCHAR2)
IS
BEGIN
  dvsys.dbms_macsec.set_factor(p_factor => p_factor,
                         p_value  => p_value);
END;
/
SHOW ERRORS;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to role_is_enabled in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.role_is_enabled(p_role IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  RETURN dvsys.dbms_macsec.role_is_enabled(p_role => p_role);
END;
/
SHOW ERRORS;

Rem Fix for Bug 6441524
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to is_secure_application role in dbms_macsec package.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.is_secure_application_role(p_role VARCHAR2) 
RETURN BOOLEAN IS
BEGIN
  RETURN dvsys.dbms_macsec.is_secure_application_role(p_role => p_role);
END;
/
SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to dbms_macvpd packages for
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.predicate_true(p_owner IN VARCHAR2,
  p_object_name IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
    return '0=0';
END;
/
SHOW ERRORS;

Rem ===========================================================================
Rem Please place any views that depend on DV PL/SQL procedures/functions below
Rem here.
Rem ===========================================================================
Rem ==============================START VIEW===================================
Rem The following code should ideally be in catmacc.sql. However, there is a
Rem dependency issue of placing this code in catmacc.sql. In DV installation/
Rem migration scripts, catmacc is executed before catmacp. Since the following
Rem view utilizes a PL/SQL function from dbms_macutl package, the view 
Rem creation fails if the code is placed in catmacc. In order to address this
Rem issue, we place only this view at the end of catmacp script. All the other
Rem views that do not depend on PL/SQL functions/procedures are continued to 
Rem be placed in catmacc.
Rem       

CREATE OR REPLACE VIEW DVSYS.event_status AS 
  SELECT * FROM TABLE(DVSYS.dbms_macutl.get_event_status())
/

Rem ===============================END VIEW====================================

show errors;


@?/rdbms/admin/sqlsessend.sql

