Rem
Rem $Header: rdbms/admin/dvu121.sql /main/63 2017/09/01 00:54:21 lutan Exp $
Rem
Rem dvu121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvu121.sql - Upgrade from 12.1.0.1 to 12.1.0.2
Rem
Rem    DESCRIPTION
Rem      Since the MAIN label is in 12.1.0.2 now, the upgrade then can 
Rem      only start from 12.1.0.1 to 12.1.0.2. Eventually, the script 
Rem      supports upgrade from 12.1.0.1 to 12.2.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dvu121.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dvu121.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dvdbmig.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lutan       08/17/17 - Bug 26631353: correct wrong usage of container
Rem                           clause in grant statements
Rem    youyang     06/30/17 - bug26095086: avoid revoking privileges if dv is
Rem                           not configured
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    risgupta    11/14/16 - Bug 24971682: Move downgrade changes for 24557076
Rem                           here
Rem    namoham     09/13/16 - Call dvu122.sql to upgrade from 12.1.0.2 to the
Rem                           current version
Rem    vperiwal    07/07/16 - 23726702: remove ORA-65173
Rem    jibyun      06/10/16 - Bug 23552766: revoke READ on LINK$ from
Rem                           DV_SECANALYST
Rem    kaizhuan    04/19/16 - Bug 22751770: rename function
Rem                           current_container_scope to get_required_scope
Rem    youyang     04/13/16 - bug22865694:move ras roles to system privilege
Rem                           and roles realm
Rem    yapli       04/06/16 - Bug 23062248: Ignore ORA-001 for dv upgrade rerun
Rem    namoham     03/10/16 - Bug 22854607: mask ORA-942 and ORA-4043
Rem    yapli       01/02/16 - Bug 22226617: Revoke select on user$ from dvsys
Rem    yapli       12/01/15 - Bug 22226586: Revoke select on sys.user$ from
Rem                           dv_secanalyst
Rem    gaurameh    11/03/15 - Bug 21045941 - adding rule$ for parameter
Rem                           CURSOR_BIND_CAPTURE_DESTINATION
Rem    youyang     10/19/15 - bug22015917,22085057:remove connect by when 
Rem                           granting privileges on dbms_rls
Rem    svivian     09/23/15 - Bug 21882092: handle ORA-04042
Rem    kaizhuan    09/17/15 - Bug 21609808: revoke create/drop directory
Rem                           and execute on sys.utl_file privileges from dvsys
Rem    sanbhara    08/20/15 - Bug 21299474 - adding scope to
Rem                           reaml$,rule$,rule_set$. also removing changes
Rem                           from Bug fix for 21475200.
Rem    yanchuan    08/18/15 - Bug 21451812: DV_OWNER User should be able to
Rem                           grant EXECUTE ON SYS.DBMS_RLS after upgrade
Rem    yanchuan    08/18/15 - Bug 21451692: remove the DV AQ rules/rule sets,
Rem                           remove Oracle Data Dictionary realm
Rem    jibyun      08/05/15 - Bug 21519712: remove unnecessary object privilege
Rem                           grants to DVF and DV_ADMIN
Rem    jibyun      08/04/15 - Bug 21519014: drop DV_ADMIN_DIR directory if
Rem                           exists
Rem    yapli       07/27/15 - Bug 21475200: Modify maxvalue of dv sequences
Rem    jibyun      07/13/15 - Bug 21438955: initialize realm_type of default
Rem                           realms
Rem    jibyun      07/06/15 - Bug 21223263: revoke INHERIT privilege on SYS
Rem                           from DVSYS
Rem    namoham     06/05/15 - Bug 20216779: remove catmacc, catmacd statements
Rem    sanbhara    06/02/15 - Bug 21158282 - adding DVPS_COMMAND_RULE_ALTS.
Rem    namoham     05/27/15 - Bug 21133991: remove ku$_* changes
Rem    yanchuan    05/18/15 - Bug 20682570/20796194: increase
Rem                           MAX_CLAUSE_PARA_LEN to 128
Rem    mjgreave    03/23/15 - Bug 20284345: disallow change of 
Rem                           LOG_ARCHIVE_MIN_SUCCEED_DEST and 
Rem                           LOG_ARCHIVE_TRACE
Rem    kaizhuan    05/07/15 - Bug 20984533: Add default command rules to 
Rem                           protect parameter _DYNAMIC_RLS_POLICIES
Rem    kaizhuan    03/27/15 - Project 46814: Support for DV application common
Rem                           policy
Rem    yapli       03/12/15 - Bug 18779967: Directly grant privileges to DVSYS
Rem    sanbhara    03/09/15 - Project 46814 - common command rule support
Rem    msoudaga    02/20/15 - Bug 16028065: remove role DELETE_CATALOG_ROLE
Rem    kaizhuan    02/09/15 - Bug 20412469: Alter columns clause_id#,
Rem                           parameter_name, event_name, component_name,
Rem                           action_name in table command_rule$ to NOT NULL;
Rem    kaizhuan    02/09/15 - Bug 20313334: Update rules 3, 4, 5, 6, 7 with new                      
Rem                           function role_granted_enabled_varchar.
Rem    namoham     01/13/15 - Bug 20282732: add DV support for FLASHBACK TABLE
Rem    kaizhuan    01/23/15 - Bug 20394885: Add CHANGE PASSWORD back to 
Rem                           code_t$ table
Rem    jibyun      01/16/15 - Bug 20360103: When adding a column, do not
Rem                           specify a default value
Rem    namoham     12/10/14 - Project 36761: support Maint auth, FBA, Purge
Rem    kaizhuan    11/21/14 - Proj 46812
Rem    jibyun      11/20/14 - Project 46812: support for training mode
Rem    yanchuan    11/10/14 - Project 36761: remove unused packages
Rem    yapli       11/04/14 - Bug 19252338: Adding new default factors
Rem    jibyun      08/06/14 - Project 46812: support for Database Vault policy
Rem    namoham     07/24/14 - Bug 19263135: Create common view for
Rem                           sys.dba_dv_status view
Rem    kaizhuan    07/11/14 - Lrg 12596835: when truncate DV tables,
Rem                           ignore 'table or view does not exist' error.
Rem    namoham     07/07/14 - Bug 19127377: add changes for PREPROCESSOR auth
Rem    jibyun      06/13/14 - Bug 18354501: grant DV_OWNER commonly in the CDB
Rem                           root
Rem    jibyun      06/12/14 - Bug 18745788: add the CONNECT role to Oracle
Rem                           System Privilege and Role Management Realm as a
Rem                           protected object
Rem    jibyun      05/21/14 - Bug 18733351: Enhance EUS support for DV roles
Rem    jibyun      03/04/14 - Bug 17368273: remove unnecessary privs from DVSYS
Rem    vperiwal    01/03/14 - Bug 16705698: ignore error 65173
Rem    namoham     12/16/13 - Bug 17969287: add sys.dba_dv_status view
Rem    jheng       11/08/13 - Bug 17752539: revoke privs for DV hardning
Rem    kaizhuan    10/17/13 - Bug 17623149: drop sequences and views which are
Rem                           no longer used by DV.
Rem    kaizhuan    09/26/13 - Bug 17342864: drop packages and tables which are
Rem                           no longer used.
Rem    kaizhuan    08/15/13 - Bug 17045932: grant DV_ACCTMGR role to 
Rem                           dv account manager users in the CDB$ROOT
Rem                           with 'container=all'.
Rem    namoham     07/24/13 - Bug 15988264: Add dvsys.dba_dv_status view
Rem    jibyun      06/03/13 - Bug 16903007: remove static realm support
Rem    sanbhara    04/09/13 - Bug 16623800 - creating the variable ALL_SCHEMA.
Rem    kaizhuan    02/01/13 - Bug 15943291: Add DV protection on role 
Rem                           AUDIT_VIEWER and AUDIT_ADMIN.
Rem    kaizhuan    03/08/13 - Created
Rem


----------------------------------------------------------------------------------------------------
-- BEGIN: Project 46812 - Database Vault Policy and Fine grained protection for ALTER SYSTEM/SESSION
----------------------------------------------------------------------------------------------------

alter table dvsys.command_rule$ add CLAUSE_ID# NUMBER DEFAULT 0 NOT NULL;
alter table dvsys.command_rule$ add PARAMETER_NAME VARCHAR2 (128) DEFAULT '%' NOT NULL;
alter table dvsys.command_rule$ add EVENT_NAME VARCHAR2 (128) DEFAULT '%' NOT NULL;
alter table dvsys.command_rule$ add COMPONENT_NAME VARCHAR2 (128) DEFAULT '%' NOT NULL;
alter table dvsys.command_rule$ add ACTION_NAME VARCHAR2 (128) DEFAULT '%' NOT NULL;

--Bug 20412469: If this is a re-upgrade after a downgrade (columns already exists before upgrade)
--1. Update all the columns values to the higer version default value
--2. Alter columns claude_id#, parameter_name, event_name,
--   component_name, action_name in command_rule$ table to NOT NULL.
--Bug 23062248: Ignore ORA-001 during dv upgrade rerun
BEGIN
  execute immediate 'update dvsys.command_rule$ set clause_id#=0, parameter_name=''%'', event_name=''%'', component_name=''%'', action_name=''%''';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already inserted
    IF SQLCODE IN (-00001) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
--End Bug 23062248

alter table dvsys.command_rule$ modify (CLAUSE_ID# DEFAULT 0 NOT NULL);
alter table dvsys.command_rule$ modify (PARAMETER_NAME DEFAULT '%' NOT NULL);
alter table dvsys.command_rule$ modify (EVENT_NAME DEFAULT '%' NOT NULL);
alter table dvsys.command_rule$ modify (COMPONENT_NAME DEFAULT '%' NOT NULL);
alter table dvsys.command_rule$ modify (ACTION_NAME DEFAULT '%' NOT NULL);

--end bug 20412469
-- this will be re-created when running catmacc.sql in dvdbmig.sql
alter table dvsys.command_rule$ drop constraint COMMAND_RULE$_UK1;

--------------------------------------------
-- END : Database Vault Policy
--------------------------------------------

-- Bug 18354501
DECLARE
  CURSOR dvo_cur IS
    select grantee
    from dba_role_privs
    where granted_role='DV_OWNER' and common='NO' and admin_option = 'YES' and grantee <> 'DVSYS';
  l_con_id NUMBER;
BEGIN
  SELECT sys_context('USERENV', 'CON_ID') INTO l_con_id from dual;

  -- In the CDB root, re-grant DV_OWNER commonly to users who has already been 
  -- granted DV_OWNER locally with admin option.
  IF l_con_id = 1 THEN
    FOR c in dvo_cur LOOP
      execute immediate 'GRANT dv_owner TO '||'"'||c.grantee||'"'||' WITH ADMIN OPTION';
    END LOOP;
  END IF;
END;
/

-- Bug 17342864

--modify owner/object_owner/grantee column to NULL
--For DV enforcement, we only use user id for the DV check and
--no longer use user name. So user name is not necessary for the 
--unique key for tables realm_object$, realm_auth$ and command_rule$.
--We drop the unique keys for these tables and re-create them without
--using user name.

-- Bug 20216779: recreated when catmacc.sql is run in dvdbmig.sql
alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1;
alter table dvsys.realm_object$ drop constraint REALM_OBJECT$_UK1;

delete from dvsys.command_rule$ where object_owner_uid# IS NULL;

delete from dvsys.realm_object$ where owner_uid# IS NULL;

delete from dvsys.realm_auth$ where grantee_uid# IS NULL;

-- Bug 16028065: during upgrade from 12.1 to 12.2, we need to delete 
-- role delete_catalog_role if it still exists
DECLARE
  role_exists INTEGER;
BEGIN
  BEGIN
    SELECT count(*) INTO role_exists FROM DVSYS.realm_object$ WHERE object_name = 'DELETE_CATALOG_ROLE' AND object_type = 'ROLE';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF role_exists IS NOT NULL THEN
    DELETE FROM DVSYS.realm_object$ WHERE object_name = 'DELETE_CATALOG_ROLE' AND object_type = 'ROLE';
  END IF;
END;
/

--For DV enforcement, we only use user id for the DV policy check and
--no longer use user name. So the column storing user name is not necessary
--to be NOT NULL. On the other hand, we use user id for DV enforcement,
--the column storing user id should has the NOT NULL restriction.
alter table dvsys.realm_auth$ modify grantee varchar2(128) NULL;
alter table dvsys.realm_auth$ modify grantee_uid# number NOT NULL;
alter table dvsys.realm_object$ modify owner varchar(128) NULL;
alter table dvsys.realm_object$ modify owner_uid# number NOT NULL;
alter table dvsys.command_rule$ modify object_owner varchar(128) NULL;
alter table dvsys.command_rule$ modify object_owner_uid# number NOT NULL;

drop package DVSYS.COMMAND_RULE$_priv;
drop package DVSYS.FACTOR$_priv;
drop package DVSYS.REALM_AUTH$_priv;
drop package DVSYS.REALM$_priv;
drop package DVSYS.REALM_OBJECT$_priv;
drop package DVSYS.RULE_SET$_priv;
drop package DVSYS.RULE_SET_RULE$_priv;
drop package DVSYS.RULE$_priv;
drop package DVSYS.DBMS_MACDVUTL;
drop package DVSYS.DBMS_MACVPD;
drop package DVSYS.REALM_COMMAND_RULE$_priv;
drop package DVSYS.CODE$_priv;
drop package DVSYS.DOCUMENT$_priv;
drop package DVSYS.FACTOR_SCOPE$_priv;
drop package DVSYS.MONITOR_RULE$_priv;
drop package DVSYS.DBMS_MACSEC_MONITOR;
drop package DVSYS.FACTOR_LINK$_priv;
drop package DVSYS.FACTOR_TYPE$_priv;
drop package DVSYS.IDENTITY$_priv;
drop package DVSYS.IDENTITY_MAP$_priv;
drop package DVSYS.MAC_POLICY$_priv;
drop package DVSYS.MAC_POLICY_FACTOR$_priv;
drop package DVSYS.POLICY_LABEL$_priv;
drop package DVSYS.ROLE$_priv;
drop package DVSYS.DBMS_MACSEC_ROLE_ADMIN;

--lrg 12596835
BEGIN
  EXECUTE IMMEDIATE 'truncate table DVSYS."REALM_COMMAND_RULE$"';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'truncate table DVSYS."DOCUMENT$"';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'truncate table DVSYS."FACTOR_SCOPE$"';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'truncate table DVSYS."MONITOR_RULE$"';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'truncate table DVSYS."MONITOR_RULE_T$"';
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
    ELSE RAISE;
    END IF;
END;
/

-- end Bug 17342864

-- Begin bug 17623149 

drop sequence DVSYS.DOCUMENT$_SEQ;
drop sequence DVSYS.MONITOR_RULE$_SEQ;
drop sequence DVSYS.REALM_COMMAND_RULE$_SEQ;
drop sequence DVSYS.FACTOR_SCOPE$_SEQ;

drop view DVSYS.dv$document;
drop view DVSYS.dv$realm_command_rule;
drop view DVSYS.dv$factor_scope;
drop view DVSYS.dv$monitor_rule;
drop view DVSYS.dba_dv_document;
drop view DVSYS.dba_dv_realm_command_rule;
drop view DVSYS.dba_dv_factor_scope;
drop view DVSYS.dba_dv_monitor_rule;

-- End bug 17623149 

--Begin bug 17752539
--On 12101, DV_CONFIGURE() did not remove these privileges from CDB$ROOT 
--successfully. It only removed grants for legacy DB. So during the upgrade,
--privileges only need to be removed for CDB$ROOT.
DECLARE
    configured  NUMBER;
    -- procedure to revoke DV hardening privs
    PROCEDURE revoke_priv(grantee varchar2, priv varchar2)
    AS
      id   number := 0;
      stmt varchar2(4000) := 'REVOKE ' || priv || ' FROM ' || grantee; 
    BEGIN     
      select sys_context('USERENV','CON_ID') into id from sys.dual;
      -- remove local grants on the current container for CDB environment.
      -- Note, in legacy DB, Oracle default grants were already revoked on 
      -- 12101 during configure_dv. If customers regrant these privileges
      -- after dv configuration, these grants will not be revoked during 
      -- upgrade.
      -- Bug 26631353: add container=current when removing local grants;
      -- remove common grants on the current container for CDB envionment.
      BEGIN
        IF (id > 0) THEN
          EXECUTE IMMEDIATE stmt;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -1952,  -1927, -1951, -4042 ) THEN NULL;
          /*Ignore errors for privilege not granted */
          ELSE RAISE;
          END IF;
      END;
      BEGIN
      	IF (id > 0) THEN
  	  EXECUTE IMMEDIATE stmt || ' container=current';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE IN ( -1952,  -1927, -1951, -4042 ) THEN NULL;
          /*Ignore errors for privilege not granted */
          ELSE RAISE;
          END IF;
      END;
    END;
BEGIN

  -- bug 26095086: revoking privilege from database roles for hardening 
  -- during upgrade should happen only when dv has been configured before.
  select status into configured from dvsys.config$;
  
  IF configured = 1 THEN
     revoke_priv('DBA', 'BECOME USER');
     revoke_priv('DBA', 'SELECT ANY TRANSACTION');
     revoke_priv('DBA', 'CREATE ANY JOB');
     revoke_priv('DBA', 'CREATE EXTERNAL JOB');
     revoke_priv('DBA', 'EXECUTE ANY PROGRAM');
     revoke_priv('DBA', 'EXECUTE ANY CLASS');
     revoke_priv('DBA', 'MANAGE SCHEDULER');
     revoke_priv('DBA', 'DEQUEUE ANY QUEUE');
     revoke_priv('DBA', 'ENQUEUE ANY QUEUE');
     revoke_priv('DBA', 'MANAGE ANY QUEUE');
     revoke_priv('IMP_FULL_DATABASE', 'BECOME USER');
     revoke_priv('IMP_FULL_DATABASE', 'MANAGE ANY QUEUE');
     revoke_priv('SCHEDULER_ADMIN', 'CREATE ANY JOB');
     revoke_priv('SCHEDULER_ADMIN', 'CREATE EXTERNAL JOB');
     revoke_priv('SCHEDULER_ADMIN', 'EXECUTE ANY PROGRAM');
     revoke_priv('SCHEDULER_ADMIN', 'EXECUTE ANY CLASS');
     revoke_priv('SCHEDULER_ADMIN', 'MANAGE SCHEDULER');
     revoke_priv('EXECUTE_CATALOG_ROLE', 'EXECUTE ON SYS.DBMS_LOGMNR');
     revoke_priv('EXECUTE_CATALOG_ROLE', 'EXECUTE ON SYS.DBMS_LOGMNR_D');   
     revoke_priv('EXECUTE_CATALOG_ROLE', 'EXECUTE ON SYS.DBMS_LOGMNR_LOGREP_DICT');
     revoke_priv('EXECUTE_CATALOG_ROLE', 'EXECUTE ON SYS.DBMS_LOGMNR_SESSION');
     revoke_priv('EXECUTE_CATALOG_ROLE', 'EXECUTE ON SYS.DBMS_FILE_TRANSFER');
     --revoke_priv('PUBLIC', 'EXECUTE ON UTL_FILE'); already revoked on 12101.
     revoke_priv('DVSYS', 'CONNECT');
     revoke_priv('DVF', 'CONNECT');
  END IF;
END;
/

--End bug 17752539

-- Bug 21451812: find the users who have been granted the EXECUTE on
-- SYS.DBMS_RLS privilege from DVSYS, and grant this privilege to those users
-- Note: this must be done before revoking EXECUTE on DBMS_RLS from DVSYS.
DECLARE
-- query to get all the descendent grantees from the ancestor 'DVSYS'
-- for the EXECUTE privilege on SYS.DBMS_RLS

-- Bug 22015917: Remove connect by from the query, since after SYS grants
-- the privilege again to the first level grantee, the original indirect 
-- level grants chain will be maintained.
-- Bug 22085057: In PDB, for existing common grant, skip the grant since 
-- it has been done on the root.
  CURSOR find_grantees IS
    SELECT grantee, common, grantable
      FROM dba_tab_privs
     WHERE owner = 'SYS' AND table_name = 'DBMS_RLS' AND privilege = 'EXECUTE'
           and grantor = 'DVSYS';
  l_gra_option_clause varchar2(30);
  l_con_scope_clause  varchar2(30);
  id number;
BEGIN
  select sys_context('USERENV','CON_ID') into id from sys.dual;

  FOR c IN find_grantees LOOP
     IF (c.grantable = 'YES') THEN
       l_gra_option_clause := ' WITH GRANT OPTION';
     ELSE
       l_gra_option_clause := '';
     END IF;

     -- Bug 26631353: add container=current for local grants in CDB environment
     IF (c.common = 'NO') and (id > 0) THEN
       l_con_scope_clause := ' CONTAINER=CURRENT';
     ELSE
       l_con_scope_clause := '';
     END IF;

     EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_RLS TO "' || c.grantee ||
                       '"' || l_gra_option_clause || l_con_scope_clause;

  END LOOP;
END;
/
-- end Bug 21451812

-- Bug 17368273: remove unnecessary privs/roles from DVSYS
DECLARE
    -- procedure to revoke privileges/roles
    PROCEDURE revoke_from_dvsys(priv varchar2)
    AS
      stmt varchar2(4000) := 'REVOKE ' || priv || ' FROM DVSYS'; 
    BEGIN
      -- Bug 26631353: remove grants on legacy DB, and remove common
      -- grants on all containers for CDB enviornment.
      EXECUTE IMMEDIATE stmt;
    EXCEPTION
      WHEN OTHERS THEN
        -- Ignore errors for privilege not granted.
        -- Bug 20216779 - ignore errors for non-existent roles. With this
        -- fix, depending on the lower version, certain roles such as 
        -- DV_AUDIT_CLEANUP are created only after dvu121 script is run 
        -- as catmacg.sql is run later.
        IF SQLCODE IN ( -1952,  -1927, -1951, -01919 ) THEN 
          NULL; -- Noop.
        ELSE RAISE;
        END IF;
    END;
BEGIN
  revoke_from_dvsys('RESOURCE');
  revoke_from_dvsys('DV_SECANALYST');
  revoke_from_dvsys('DV_MONITOR');
  revoke_from_dvsys('DV_ADMIN');
  revoke_from_dvsys('DV_OWNER');
  revoke_from_dvsys('DV_ACCTMGR');
  revoke_from_dvsys('DV_PUBLIC');
  revoke_from_dvsys('DV_PATCH_ADMIN');
  revoke_from_dvsys('DV_STREAMS_ADMIN');
  revoke_from_dvsys('DV_GOLDENGATE_ADMIN');
  revoke_from_dvsys('DV_XSTREAM_ADMIN');
  revoke_from_dvsys('DV_GOLDENGATE_REDO_ACCESS');
  revoke_from_dvsys('DV_AUDIT_CLEANUP');
  revoke_from_dvsys('DV_DATAPUMP_NETWORK_LINK');
  revoke_from_dvsys('ADMINISTER DATABASE TRIGGER');
  revoke_from_dvsys('CREATE EVALUATION CONTEXT');
  revoke_from_dvsys('CREATE LIBRARY');
  revoke_from_dvsys('CREATE RULE');
  revoke_from_dvsys('CREATE RULE SET');
  revoke_from_dvsys('CREATE SYNONYM');
  revoke_from_dvsys('CREATE VIEW');
  revoke_from_dvsys('EXECUTE on sys.dbms_crypto');
  revoke_from_dvsys('EXECUTE on sys.dbms_registry');
  revoke_from_dvsys('EXECUTE on sys.dbms_rls');
  revoke_from_dvsys('SELECT on sys.dba_policies');
  revoke_from_dvsys('SELECT on sys.exu9rls');
END;
/

-- Bug 18733351: update rule expressions to recognize session enabled roles.
-- Bug 20313334: update the rule expressions with scope check, omit downgrade changes.
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.ROLE_GRANTED_ENABLED_VARCHAR(''DV_ACCTMGR'', ''"''||dvsys.dv_login_user||''"'', 1, dvsys.get_required_scope) = ''Y''' where id# = 3;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.ROLE_GRANTED_ENABLED_VARCHAR(''DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 4;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.ROLE_GRANTED_ENABLED_VARCHAR(''DV_ADMIN'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 5;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.ROLE_GRANTED_ENABLED_VARCHAR(''DV_OWNER'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 6;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.ROLE_GRANTED_ENABLED_VARCHAR(''LBAC_DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 7;

-- Bug 21045941: Allow CURSOR_BIND_CAPTURE_DESTINATION parameter to be altered.
update dvsys.rule$ set rule_expr = 'DVSYS.parameter_name = ''STANDBY_ARCHIVE_DEST'' OR DVSYS.parameter_name = ''DB_RECOVERY_FILE_DEST_SIZE'' OR DVSYS.parameter_name LIKE ''%LOG_ARCHIVE_DEST%'' OR DVSYS.parameter_name LIKE ''%CURSOR_BIND_CAPTURE_DESTINATION%'' OR DVSYS.parameter_name NOT LIKE ''%_DEST%''' where id# = 211;

-- Bug 21451692: remove the DV AQ rules/rule sets
declare
  cursor find_aq_rules is
    select object_name from dba_objects
    where object_type = 'RULE' and owner = 'DVSYS';
  cursor find_aq_rulesets is
    select object_name from dba_objects
    where object_type = 'RULE SET' and owner = 'DVSYS';
begin
  for c in find_aq_rules loop

     begin
       dbms_rule_adm.drop_rule('DVSYS.' || c.object_name, TRUE);
     exception
       when others then NULL;
     end;

  end loop;

  for c in find_aq_rulesets loop

     begin
       dbms_rule_adm.drop_rule_set('DVSYS.' || c.object_name, TRUE);
     exception
       when others then NULL;
     end;

  end loop;

end; 
/ 
-- end Bug 21451692: remove the DV AQ rules/rule sets

-- Bug 21438955: initialize realm_type of default realms if not done.
update dvsys.realm$ set realm_type = 0 where realm_type is null;

-- Bug 21451692: remove Oracle Data Dictionary realm
DECLARE
  ood_realmobj_cnt NUMBER;
  ood_realm_newid  NUMBER;
BEGIN

  SELECT count(*) into ood_realmobj_cnt FROM DVSYS.realm_object$ WHERE realm_id# = 1 AND id# >= 5000;

  IF ood_realmobj_cnt = 0 THEN

    -- delete ODD realm if there is no customer realm objects protected
    DELETE FROM DVSYS."REALM_AUTH$" where realm_id# = 1;
    DELETE FROM DVSYS."REALM_T$" where id# = 1;
    DELETE FROM DVSYS."REALM$" where id# = 1;

  ELSE

    -- change the ID# of ODD realm out of the default realm reserved range
    ood_realm_newid := dvsys.realm$_seq.NEXTVAL;

    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$" MODIFY CONSTRAINT "REALM_OBJECT$_FK" DISABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$" MODIFY CONSTRAINT "REALM_AUTH$_FK" DISABLE';

    UPDATE DVSYS.realm$ SET ID# = ood_realm_newid WHERE ID# = 1;
    UPDATE DVSYS.realm_t$ SET ID# = ood_realm_newid WHERE ID# = 1;
    UPDATE DVSYS.realm_object$ SET REALM_ID# = ood_realm_newid WHERE REALM_ID# = 1;
    UPDATE DVSYS.realm_auth$ SET REALM_ID# = ood_realm_newid WHERE REALM_ID# = 1;

    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$" MODIFY CONSTRAINT "REALM_OBJECT$_FK" ENABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$" MODIFY CONSTRAINT "REALM_AUTH$_FK" ENABLE';

  END IF;

END;
/
--end Bug 21451692: remove Oracle Data Dictionary realm

-- Project 36761
ALTER TABLE DVSYS.DV_AUTH$ ADD action VARCHAR2 (30);
-- Bug 20360103
UPDATE DVSYS.DV_AUTH$ set action = '%';
-- end Project 36761

-- Project 46814 - common DV policy support

alter table dvsys.command_rule$ add SCOPE NUMBER DEFAULT 1;
alter table dvsys.rule$ add SCOPE NUMBER DEFAULT 1;
alter table dvsys.rule_set$ add SCOPE NUMBER DEFAULT 1;

update dvsys.command_rule$ set scope = 1;
update dvsys.rule$ set scope = 1;
update dvsys.rule_set$ set scope = 1;

-- Bug 20216779: recreated when catmacc.sql is run in dvdbmig.sql
BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$" DROP CONSTRAINT "COMMAND_RULE$_UK1"';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -02260, -02261, -02275) THEN NULL;
       --ignore primary key errors and referential constraint error
     ELSE RAISE;
     END IF;
END;
/

-- END Project 46814

----------------------------------------------------------------------------------------------------
-- BEGIN: Project 46814 - Database Vault Application Common Policy
----------------------------------------------------------------------------------------------------

alter table dvsys.realm_auth$ add scope NUMBER DEFAULT 1;
alter table dvsys.realm$ add scope NUMBER DEFAULT 1;

--If this is a re-upgrade after a downgrade (columns already exists before upgrade)
--Update all the columns values to the higer version default value

update dvsys.realm$ set scope = 1;
update dvsys.realm_auth$ set scope = 1;

-- Bug 20216779: recreated when catmacc.sql is run in dvdbmig.sql
alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1;

-- END Project 46814

-- Bug 21223263: revoke INHERIT privilege on SYS from DVSYS
BEGIN
  execute immediate 'revoke inherit privileges on user SYS from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 21223263: drop DVSYS.configure_dv as SYS.configure_dv will be created
-- by prvtmacp.sql later.
BEGIN
  execute immediate 'drop procedure dvsys.configure_dv';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already dropped.
    IF SQLCODE IN (-4043) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 21519712: Remove SELECT on DVSYS.AUDIT_TRAIL$ from DV_ADMIN.
-- This grant is unnecessary as DV_ADMIN already has the privilege 
-- through DV_SECANALYST.
BEGIN
  execute immediate 'revoke select on dvsys.audit_trail$ from dv_admin';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if not granted.
    IF SQLCODE IN (-1927) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 21519712: Remove EXECUTE on DVSYS.GET_FACTOR from DVF.
-- This grant is unnecessary as DVF already has the privilege 
-- through PUBLIC.
BEGIN
  execute immediate 'revoke execute on dvsys.get_factor from dvf';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if not granted.
    IF SQLCODE IN (-1927) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 21519014: drop DV_ADMIN_DIR directory if exists.
-- DV_ADMIN_DIR directory is created in 11.2.0.3 and 11.2.0.4.,
-- but it is no longer used since 12c.
BEGIN
  execute immediate 'drop directory DV_ADMIN_DIR';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if it does not exist.
    IF SQLCODE IN (-4043) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Begin bug 21475200
BEGIN
  execute immediate 'alter sequence DVSYS."COMMAND_RULE$_SEQ" maxvalue 999999999';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if maxvalue is made to less than the current value
    IF SQLCODE IN (-4009) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'alter sequence DVSYS."RULE$_SEQ" maxvalue 999999999';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if maxvalue is made to less than the current value
    IF SQLCODE IN (-4009) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'alter sequence DVSYS."RULE_SET$_SEQ" maxvalue 999999999';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if maxvalue is made to less than the current value
    IF SQLCODE IN (-4009) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'alter sequence DVSYS."REALM$_SEQ" maxvalue 999999999';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if maxvalue is made to less than the current value
    IF SQLCODE IN (-4009) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
-- End bug 21475200

-- Bug 21609808: revoke create/drop any directory privileges from DVSYS
--               revoke execute on sys.utl_file from DVSYS
BEGIN
  execute immediate 'revoke create any directory from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1952, -65092) THEN NULL;
    ELSE RAISE;
   END IF;
END;
/

BEGIN
  execute immediate 'revoke drop any directory from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1952, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke execute on sys.utl_file from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
--end bug 21609808

--begin bug 22226586
BEGIN
  execute immediate 'revoke select on sys.user$ from DV_SECANALYST';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
--end bug 22226586

--begin bug 22226617
BEGIN
  execute immediate 'revoke select on sys.user$ from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

--Revoke grants to sys objects in catmacr.sql
BEGIN
  execute immediate 'revoke select on sys.gv_$code_clause from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$code_clause from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$code_clause from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$code_clause from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_users from dv_acctmgr';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_profiles from dv_acctmgr';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_audit_trail from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_audit_trail from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_users from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_roles from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_role_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_tab_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_col_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_tables from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_views from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_clusters from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_indexes from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_tab_columns from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_objects from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_sys_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_policies from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_java_policy from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    -- Bug 22854607: mask object does not exist error
    IF SQLCODE IN (-1927, -1951, -65092, -942, -4043) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_triggers from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$session from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$instance from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$instance from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$session from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$database from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$parameter from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.exu9rls from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_profiles from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.objauth$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.sysauth$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.obj$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.tab$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.table_privilege_map from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.system_privilege_map from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$pwfile_users from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.all_source from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_dependencies from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_directories from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_ts_quotas from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.link$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$resource_limit from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

--Revoke grants to sys objects in catmacs.sql
BEGIN
  execute immediate 'revoke select on sys.dba_dependencies from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$instance from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$instance from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$session from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$session from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$database from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$parameter from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_role_privs from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_sys_privs  from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_tab_privs  from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_synonyms from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_application_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.proxy_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_users from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_objects from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_nested_tables from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_context from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.objauth$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.sysauth$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.obj$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.tab$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys."_BASE_USER" from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.table_privilege_map from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.system_privilege_map from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.dba_recyclebin from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on SYS.DUAL from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.gv_$code_clause from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke select on sys.v_$code_clause from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
--end bug 22226617

-- Bug 23552766
BEGIN
  execute immediate 'revoke read on sys.link$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Bug 24557076: Revoke unnecessary privileges from the DV_OWNER role.
BEGIN
 execute immediate 'REVOKE GRANT ANY ROLE FROM dv_owner';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1952, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
 execute immediate 'REVOKE ADMINISTER DATABASE TRIGGER FROM dv_owner';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1952, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
 execute immediate 'REVOKE ALTER ANY TRIGGER FROM dv_owner';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1952, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
 execute immediate 'REVOKE EXECUTE ON SYS.DBMS_RLS FROM dv_owner';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
-- end Bug 24557076
--begin bug 22865694
update DVSYS.realm_object$ set realm_id#=9 where object_name in ('PROVISIONER', 'XS_CACHE_ADMIN', 'XS_CONNECT', 'XS_NAMESPACE_ADMIN', 'XS_SESSION_ADMIN') and object_type = 'ROLE';

variable xsuserid  NUMBER;
begin
select user# into :xsuserid from sys.user$ where name='XS$NULL';
end;
/

update DVSYS.realm_object$ set realm_id#=9 where owner_uid# = :xsuserid;
--end bug 22865694

-- Call dvu122.sql for upgrade from 12.1.0.2 to the latest version
@@dvu122.sql
