Rem
Rem $Header: rdbms/admin/dve121.sql /main/62 2017/09/01 00:54:21 lutan Exp $
Rem
Rem dve121.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dve121.sql - Downgrade script from 12.2 to 12.1.*
Rem
Rem    DESCRIPTION
Rem      Since the MAIN label is in 12.2 now, the downgrade then can 
Rem      only start from 12.2 to 12.1.*.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dve121.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dve121.sql
Rem SQL_PHASE: DOWNGRADE
Rem SQL_STARTUP_MODE: DOWNGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dvdwgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lutan       08/17/17 - Bug 26631353: correct wrong usage of container
Rem                           clause in grant statements
Rem    youyang     05/23/17 - bug26001318:modify sql meta data
Rem    risgupta    11/14/16 - Bug 24971682: Move downgrade changes for 24557076
Rem                           here
Rem    dalpern     10/15/16 - bug 22665467: add DV checks on DEBUG [CONNECT]
Rem    namoham     09/14/16 - Call dve122.sql
Rem    jibyun      09/12/16 - XbranchMerge jibyun_bug-24616733 from
Rem                           st_rdbms_12.2.0.1.0
Rem    jibyun      09/08/16 - Bug 24616733: drop dvsys.event_level
Rem    jibyun      06/21/16 - RTI 19553302: drop public synonym for
Rem                           dvsys.dba_dv_dictionary_accts
Rem    sanbhara    06/20/16 - Bug 23606093 removing
Rem                           APPLICATION_TRACE_VIEWER,DBJAVASCRIPT,RDFCTX_ADMIN
Rem                           from dv realms.
Rem    yapli       04/19/16 - RTI 19364914: Change 'T' to 'S'
Rem    kaizhuan    04/15/16 - Bug 22751770: remove function GET_CONTAINER_SCOPE
Rem    youyang     03/31/16 - bug22865694:revoke read on xs$obj from dvsys
Rem    sanbhara    03/22/16 - Bug 22968446 - drop audit polocy ORA_DV_AUDPOL2.
Rem    yanchuan    03/16/16 - Bug 20505982: Revoke from SYS
Rem                           the Execute privilege on CONFIGURE_DV_INTERNAL
Rem    namoham     03/10/16 - Bug 22854607: mask ORA-942 and ORA-4043
Rem    yapli       03/03/16 - Bug 22840314: Change training api to simulation
Rem    youyang     02/16/16 - bug22672722: add index functions for DV
Rem    sanbhara    02/11/16 - Bug 22584525 - dropping rule 212, rule set 20.
Rem    jibyun      02/04/16 - Bug 22296366: remove Database Vault synonyms from
Rem                           Oracle Database Vault realm
Rem    yapli       01/02/16 - Bug 22226617: Replace _BASE_USER with user$
Rem    yapli       12/01/15 - Bug 22226586: Grant select on sys.user$ to
Rem                           dv_secanalyst
Rem    gaurameh    11/18/15 - Bug 21045941: revert back changes of bug fix
Rem    jibyun      11/01/15 - Remove DIAGNOSTIC authorization
Rem    kaizhuan    09/17/15 - Bug 21609808: grant create/drop directory
Rem                           and execute on sys.utl_file privileges to dvsys
Rem    yapli       08/23/15 - Bug 20588540: Remove new Oracle supplied roles
Rem                           from DV protection
Rem    sanbhara    08/20/15 - Bug 21299474 - removing the common* sequences.
Rem    yapli       07/29/15 - Bug 21475200: Modify maxvalue of dv sequences
Rem    yanchuan    07/27/15 - Bug 21299533: drop ku$_dv_auth_* related
Rem                           views and types
Rem    amunnoli    07/14/15 - Proj 46892: recreate dv unified audit trail views
Rem                           on v$unified_audit_trail
Rem    jibyun      06/29/15 - Bug 21223263: drop synonym dvsys.configure_dv and
Rem                           procedure sys.configure_dv
Rem    jibyun      06/25/15 - Bug 21299841: separate changes for 12.1.0.1
Rem                           and 12.1.0.2
Rem    youyang     06/24/15 - lrg16571767:drop scope from rule_t$ and
Rem                           rule_set_t$
Rem    sanbhara    06/02/15 - Bug 21158282 - dropping ku$_dv_comm_rule_alts_v.
Rem    yanchuan    05/19/15 - Bug 20682570/20796194: increase
Rem                           MAX_CLAUSE_PARA_LEN to 128
Rem    mjgreave    03/23/15 - Bug 20284345: disallow change of
Rem                           LOG_ARCHIVE_MIN_SUCCEED_DEST and
Rem                           LOG_ARCHIVE_TRACE
Rem    kaizhuan    05/06/15 - Bug 20984533: Delete default command rules that
Rem                           protect parameter _DYNAMIC_RLS_POLICIES
Rem    kaizhuan    04/27/15 - Bug 20917038: re-create view dba_dv_rule_set 
Rem                           during downgrade
Rem    yapli       04/16/15 - Bug 20747653: Enabling filtering out default DV
Rem                           objects
Rem    kaizhuan    04/14/15 - lrg 15796746: drop type ku$_dv_realm_member_t
Rem                           of higher version and re-create in lower version
Rem    kaizhuan    04/08/15 - lrg 15788602: drop column scope from realm_t$
Rem                           table
Rem    kaizhuan    03/28/15 - Project 46814
Rem    sanbhara    03/09/15 - Project 46814 - common command rule support
Rem    kaizhuan    02/09/15 - Bug 20412469: Alter columns clause_id#, 
Rem                           parameter_name, event_name, component_name,
Rem                           action_name in table command_rule$ to NULL;
Rem    namoham     01/13/15 - Bug 20282732: remove DV support for FLASHBACK
Rem                           TABLE
Rem    namoham     12/10/14 - Project 36761: Remove Maint./FBA/Pur support
Rem    jibyun      11/20/14 - Project 46812: support for training mode
Rem    kaizhuan    11/11/14 - Project 46812
Rem    yapli       11/04/14 - Bug 19252338: remove new default factors
Rem    jibyun      08/06/14 - Project 46812: Remove DV policy support
Rem    namoham     07/24/14 - Bug 19263135: Drop sys.cdb_dv_status
Rem    kaizhuan    07/23/14 - lrg 12596835: when create DV views which are
Rem                           removed from 12.1.0.2, ignore the
Rem                           'table or view does not exist' error.
Rem    namoham     07/07/14 - Bug 19127377: drop dvsys.dba_dv_preprocessor_auth
Rem    jibyun      06/12/14 - Bug 18745788: remove the CONNECT role from Oracle
Rem                           System Privilege and Role Management Realm
Rem    jibyun      05/21/14 - Bug 18733351: Reverse EUS support for DV roles
Rem    jibyun      03/31/14 - Project 46812: disable user-specific CONNECT
Rem                           command rule during downgrade
Rem    jibyun      03/04/14 - Bug 17368273: regrant privs/roles to DVSYS
Rem    namoham     12/16/13 - Bug 17969287: drop sys.dba_dv_status view
Rem    kaizhuan    10/18/13 - Bug 17623149: create sequences and views which are
Rem                           dropped during 12.1.0.2 upgrade
Rem    kaizhuan    09/10/13 - Bug 17342864: Modify owner/object_owner/grantee
Rem                           column back to NOT NULL.
Rem    sanbhara    08/08/13 - Bug 16499989 - dropping ORA_DV_AUDPOL audit
Rem                           policy.
Rem    namoham     07/24/13 - Bug 15938449/15988264: Drop functions and the 
Rem                           views dvsys.event_status and dvsys.dba_dv_status
Rem    kaizhuan    03/25/13 - Bug 15943291: Add DV protection on role AUDIT_VIEW
Rem                           and AUDIT_VIEWER.
Rem    kaizhuan    03/08/13 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

@@dve122.sql

define all_schema = 2147483636;

-----------------------------------------------------------------
------- Changes for downgrading to 12.1.0.2 and 12.1.0.1  -------
-----------------------------------------------------------------
-- bug 22865694 begin
BEGIN
  execute immediate 'revoke read on sys.xs$obj from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_proxy_auth
(
      grantee
    , schema
)
AS SELECT
    u1.name
  , u2.name
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u1, sys."_BASE_USER" u2
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u1
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da, sys."_BASE_USER" u2
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

-- bug 22865694 end

--Bug 22968446 - drop audit policy ORA_DV_AUDPOL2
noaudit policy ORA_DV_AUDPOL2;
drop audit policy ORA_DV_AUDPOL2;

--Begin Bug 22226617
GRANT SELECT ON sys.user$ TO dvsys WITH GRANT OPTION;

BEGIN
  execute immediate 'revoke read on sys.gv_$code_clause from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$code_clause from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$code_clause from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$code_clause from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$enforcement_audit from AUDIT_VIEWER';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$enforcement_audit from AUDIT_ADMIN';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$enforcement_audit from DV_SECANALYST';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$enforcement_audit from DV_MONITOR';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$configuration_audit from AUDIT_VIEWER';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$configuration_audit from AUDIT_ADMIN';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$configuration_audit from DV_SECANALYST';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dv$configuration_audit from DV_MONITOR';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_users from dv_acctmgr';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_profiles from dv_acctmgr';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_audit_trail from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_audit_trail from dv_monitor';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_users from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_roles from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_role_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_tab_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_col_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_tables from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_views from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_clusters from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_indexes from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_tab_columns from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_objects from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_sys_privs from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_policies from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_java_policy from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_triggers from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$session from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$instance from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$instance from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$session from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$database from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$parameter from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.exu9rls from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_profiles from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.objauth$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.sysauth$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.obj$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.tab$ from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.table_privilege_map from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.system_privilege_map from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$pwfile_users from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.all_source from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_dependencies from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_directories from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_ts_quotas from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

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

BEGIN
  execute immediate 'revoke read on sys.v_$resource_limit from dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_dependencies from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$instance from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$instance from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$session from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$session from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$database from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$parameter from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_role_privs from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_sys_privs  from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_tab_privs  from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_synonyms from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_application_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.proxy_roles from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_users from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_objects from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_nested_tables from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_context from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.objauth$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.sysauth$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.obj$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.tab$ from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys."_BASE_USER" from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.table_privilege_map from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.system_privilege_map from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.dba_recyclebin from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on SYS.DUAL from DVSYS';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.gv_$code_clause from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  execute immediate 'revoke read on sys.v_$code_clause from dvsys';
EXCEPTION
  WHEN OTHERS THEN
    -- ignore if already revoked.
    IF SQLCODE IN (-1927, -1951, -65092) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

--catmacg
GRANT SELECT ON sys.gv_$code_clause TO dv_monitor
/
GRANT SELECT ON sys.v_$code_clause TO dv_monitor
/
GRANT SELECT ON sys.gv_$code_clause TO dv_secanalyst
/
GRANT SELECT ON sys.v_$code_clause TO dv_secanalyst
/
GRANT SELECT ON sys.dv$enforcement_audit TO AUDIT_VIEWER, AUDIT_ADMIN, DV_SECANALYST, DV_MONITOR;
/
GRANT SELECT ON sys.dv$configuration_audit TO AUDIT_VIEWER, AUDIT_ADMIN, DV_SECANALYST, DV_MONITOR;
/

--catmacr
GRANT SELECT ON sys.dba_users TO dv_acctmgr
/
GRANT SELECT ON sys.dba_profiles TO dv_acctmgr
/
GRANT SELECT ON sys.dba_audit_trail TO dv_secanalyst
/
GRANT SELECT ON sys.dba_audit_trail TO dv_monitor
/
GRANT SELECT ON sys.dba_users TO dv_secanalyst
/
GRANT SELECT ON sys.dba_roles TO dv_secanalyst
/
GRANT SELECT ON sys.dba_role_privs TO dv_secanalyst
/
GRANT SELECT ON sys.dba_tab_privs TO dv_secanalyst
/
GRANT SELECT ON sys.dba_col_privs TO dv_secanalyst
/
GRANT SELECT ON sys.dba_tables TO dv_secanalyst
/
GRANT SELECT ON sys.dba_views TO dv_secanalyst
/
GRANT SELECT ON sys.dba_clusters TO dv_secanalyst
/
GRANT SELECT ON sys.dba_indexes TO dv_secanalyst
/
GRANT SELECT ON sys.dba_tab_columns TO dv_secanalyst
/
GRANT SELECT ON sys.dba_objects TO dv_secanalyst
/
GRANT SELECT ON sys.dba_sys_privs TO dv_secanalyst
/
GRANT SELECT ON sys.dba_policies TO dv_secanalyst
/
-- Bug 22854607: mask object does not exist error
BEGIN
  execute immediate 'GRANT SELECT ON sys.dba_java_policy TO dv_secanalyst';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-942, -4043) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

GRANT SELECT ON sys.dba_triggers TO dv_secanalyst
/
GRANT SELECT ON sys.gv_$session TO dv_secanalyst
/
GRANT SELECT ON sys.v_$instance TO dv_secanalyst
/
GRANT SELECT ON sys.gv_$instance TO dv_secanalyst
/
GRANT SELECT ON sys.v_$session TO dv_secanalyst
/
GRANT SELECT ON sys.v_$database TO dv_secanalyst
/
GRANT SELECT ON sys.v_$parameter TO dv_secanalyst
/
GRANT SELECT ON sys.exu9rls TO dv_secanalyst
/
GRANT SELECT ON sys.dba_profiles TO dv_secanalyst
/
GRANT SELECT ON sys.objauth$ TO dv_secanalyst
/
GRANT SELECT ON sys.sysauth$ TO dv_secanalyst
/
GRANT SELECT ON sys.obj$ TO dv_secanalyst
/
GRANT SELECT ON sys.tab$ TO dv_secanalyst
/
GRANT SELECT ON sys.table_privilege_map TO dv_secanalyst
/
GRANT SELECT ON sys.system_privilege_map TO dv_secanalyst
/
GRANT SELECT ON sys.v_$pwfile_users TO dv_secanalyst
/
GRANT SELECT ON sys.all_source TO dv_secanalyst
/
GRANT SELECT ON sys.dba_dependencies TO dv_secanalyst
/
GRANT SELECT ON sys.dba_directories TO dv_secanalyst
/
GRANT SELECT ON sys.dba_ts_quotas TO dv_secanalyst
/
GRANT SELECT ON sys.link$ TO dv_secanalyst
/
GRANT SELECT ON sys.v_$resource_limit TO dv_secanalyst
/

--catmacs
GRANT SELECT ON sys.dba_dependencies TO dvsys
/
GRANT SELECT ON sys.v_$instance TO dvsys
/
GRANT SELECT ON sys.gv_$instance TO dvsys
/
GRANT SELECT ON sys.gv_$session TO dvsys
/
GRANT SELECT ON sys.v_$session TO dvsys
/
GRANT SELECT ON sys.v_$database TO dvsys
/
GRANT SELECT ON sys.v_$parameter TO dvsys
/
GRANT SELECT ON sys.dba_roles TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_role_privs TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_sys_privs  TO dvsys
/
GRANT SELECT ON sys.dba_tab_privs  TO dvsys
/
GRANT SELECT ON sys.dba_synonyms TO dvsys
/
GRANT SELECT ON sys.dba_application_roles TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.proxy_roles TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_users TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_objects TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_nested_tables TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_context TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.objauth$ TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.sysauth$ TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.obj$ TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.tab$ TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys."_BASE_USER" TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.table_privilege_map TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.system_privilege_map TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.dba_recyclebin TO dvsys
/
GRANT SELECT ON SYS.DUAL TO DVSYS
/
GRANT SELECT ON sys.gv_$code_clause to dvsys WITH GRANT OPTION
/
GRANT SELECT ON sys.v_$code_clause to dvsys WITH GRANT OPTION
/

create or replace view DVSYS.DV_OWNER_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_OWNER'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
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
      where decode((select type# from sys.user$ where name = grantee),
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
      where decode((select type# from sys.user$ where name = grantee),
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
      where decode((select type# from sys.user$ where name = grantee),
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
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_AUDIT_CLEANUP'))
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
    sys.user$ u,
    sys.user$ ue,
    sys.user$ dbu,
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
    sys.user$ u,
    sys.user$ ue,
    sys.user$ dbu,
    table_privilege_map tpm
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
     sys.user$ ue,
     sys.user$ dbu,
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
    ,ACCESS_TYPE
    ,PRIVILEGE
    ,OWNER
    ,OBJECT_NAME
)
AS SELECT
    dbu.name
    ,   decode(ue.name,dbu.name,'DIRECT',ue.name)
    ,   tpm.name
    ,   u.name
    ,   o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys.user$ u,
    sys.user$ ue,
    sys.user$ dbu,
    sys.table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND dbu.type# = 1
  AND (oa.grantee# = 1)
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
FROM dvsys.dv_auth$ da, sys.user$ u1, sys.user$ u2
WHERE grant_type = 'JOB' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, sys.user$ u1
WHERE grant_type = 'JOB' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_datapump_auth
(
      grantee
    , schema
    , object
)
AS SELECT
    u1.name
  , u2.name
  , da.object_name
FROM dvsys.dv_auth$ da, sys.user$ u1, sys.user$ u2
WHERE da.grant_type = 'DATAPUMP' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
  , da.object_name
FROM dvsys.dv_auth$ da, sys.user$ u1
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
FROM dvsys.dv_auth$ da, sys.user$ u1
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
FROM dvsys.dv_auth$ da, sys.user$ u1, sys.user$ u2
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, sys.user$ u1
WHERE grant_type = 'PROXY' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da, sys.user$ u2
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
FROM dvsys.dv_auth$ da, sys.user$ u1, sys.user$ u2
WHERE grant_type = 'DDL' and da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    u1.name
  , '%'
FROM dvsys.dv_auth$ da, sys.user$ u1
WHERE grant_type = 'DDL' and da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    '%'
  , u2.name
FROM dvsys.dv_auth$ da, sys.user$ u2
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
FROM dvsys.dv_auth$ da, sys.user$ u1, sys.user$ u2
WHERE da.grantee_id = u1.user# and
      da.object_owner_id = u2.user#
UNION
SELECT
    grant_type
  , u1.name
  , '%'
  , object_name
  , object_type
FROM dvsys.dv_auth$ da, sys.user$ u1
WHERE da.grantee_id = u1.user# and
      da.object_owner_id = &all_schema
UNION
SELECT
    grant_type
  , '%'
  , u2.name
  , object_name
  , object_type
FROM dvsys.dv_auth$ da, sys.user$ u2
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

--End Bug 22226617

--Begin Bug 22226586
GRANT SELECT ON sys.user$ TO dv_secanalyst;
--End Bug 22226586

-- Bug 21609808
GRANT CREATE ANY DIRECTORY TO dvsys
/
GRANT DROP ANY DIRECTORY TO dvsys
/
GRANT EXECUTE ON sys.utl_file TO dvsys
/
--end bug 21609808 

-- Bug 24557076: Grant back the revoked privileges to DV_OWNER
GRANT GRANT ANY ROLE TO dv_owner;
GRANT ADMINISTER DATABASE TRIGGER TO dv_owner;
GRANT ALTER ANY TRIGGER TO dv_owner;
GRANT EXECUTE ON SYS.DBMS_RLS TO dv_owner;
--end bug 24557076

--Begin Bug20588540
--delete schema
delete from dvsys.realm_object$
where owner = 'XS$NULL' and object_name = '%' and object_type = '%';

--delete roles
delete from dvsys.realm_object$
where object_name = 'ADM_PARALLEL_EXECUTE_TASK' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'APEX_ADMINISTRATOR_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'AUTHENTICATEDUSER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'CAPTURE_ADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'CDB_DBA' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'CSW_USR_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DATAPUMP_EXP_FULL_DATABASE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DATAPUMP_IMP_FULL_DATABASE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DBFS_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DBMS_MDX_INTERNAL' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'EM_EXPRESS_ALL' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'EM_EXPRESS_BASIC' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'GDS_CATALOG_SELECT' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'GGSYS_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'GSMADMIN_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'GSMUSER_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'GSM_POOLADMIN_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'HS_ADMIN_EXECUTE_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'HS_ADMIN_SELECT_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'JMXSERVER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'OEM_ADVISOR' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'OLAP_XS_ADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'ORDADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'PDB_DBA' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'PROVISIONER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'RECOVERY_CATALOG_OWNER_VPD' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'RECOVERY_CATALOG_USER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'SODA_APP' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'SPATIAL_CSW_ADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'SYSUMF_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'WM_ADMIN_ROLE' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XDBADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XDB_SET_INVOKER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XDB_WEBSERVICES' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XDB_WEBSERVICES_OVER_HTTP' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XDB_WEBSERVICES_WITH_PUBLIC' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XS_CACHE_ADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XS_CONNECT' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XS_NAMESPACE_ADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XS_SESSION_ADMIN' and object_type = 'ROLE';
--End Bug20588540

-- Bug 23606093

delete from dvsys.realm_object$
where object_name = 'APPLICATION_TRACE_VIEWER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DBJAVASCRIPT' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'RDFCTX_ADMIN' and object_type = 'ROLE';

delete from dvsys.realm_object$
where object_name = 'XSBYPASS' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSCACHEADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSDISPATCHER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSNAMESPACEADMIN' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSPROVISIONER' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSSESSIONADMIN' and object_type = 'ROLE';

delete from dvsys.realm_object$
where object_name = 'XSAUTHENTICATED' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DBMS_AUTH' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'DBMS_PASSWD' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'MIDTIER_AUTH' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'XSSWITCH' and object_type = 'ROLE';
delete from dvsys.realm_object$
where object_name = 'EXTERNAL_DBMS_AUTH' and object_type = 'ROLE';
-- End Bug 23606093

-- Bug 22296366
delete from dvsys.realm_object$ 
where owner = 'PUBLIC' and object_type = 'SYNONYM';
drop public synonym dbms_macols_session;
drop public synonym dv_database_name;
drop public synonym dv_dict_obj_name;
drop public synonym dv_dict_obj_owner;
drop public synonym dv_dict_obj_type;
drop public synonym dv_instance_num;
drop public synonym dv_job_invoker;
drop public synonym dv_job_owner;
drop public synonym dv_login_user;
drop public synonym dv_sql_text;
drop public synonym dv_sysevent;
drop public synonym dba_dv_auth;
drop public synonym dba_dv_code;
drop public synonym dba_dv_command_rule;
drop public synonym dba_dv_command_rule_id;
drop public synonym dba_dv_datapump_auth;
drop public synonym dba_dv_ddl_auth;
drop public synonym dba_dv_diagnostic_auth;
drop public synonym dba_dv_dictionary_accts;
drop public synonym dba_dv_factor;
drop public synonym dba_dv_factor_link;
drop public synonym dba_dv_factor_type;
drop public synonym dba_dv_identity;
drop public synonym dba_dv_identity_map;
drop public synonym dba_dv_job_auth;
drop public synonym dba_dv_mac_policy;
drop public synonym dba_dv_mac_policy_factor;
drop public synonym dba_dv_maintenance_auth;
drop public synonym dba_dv_oradebug;
drop public synonym dba_dv_patch_admin_audit;
drop public synonym dba_dv_policy;
drop public synonym dba_dv_policy_label;
drop public synonym dba_dv_policy_object;
drop public synonym dba_dv_policy_owner;
drop public synonym dba_dv_preprocessor_auth;
drop public synonym dba_dv_proxy_auth;
drop public synonym dba_dv_pub_privs;
drop public synonym dba_dv_realm;
drop public synonym dba_dv_realm_auth;
drop public synonym dba_dv_realm_object;
drop public synonym dba_dv_role;
drop public synonym dba_dv_rule;
drop public synonym dba_dv_rule_set;
drop public synonym dba_dv_rule_set_rule;
drop public synonym dba_dv_simulation_log;
drop public synonym dba_dv_tts_auth;
drop public synonym dba_dv_user_privs;
drop public synonym dba_dv_user_privs_all;
drop public synonym dv_admin_grantees;
drop public synonym dv_audit_cleanup_grantees;
drop public synonym dv_monitor_grantees;
drop public synonym dv_owner_grantees;
drop public synonym dv_secanalyst_grantees;
drop public synonym configure_dv;
drop public synonym cdb_dv_status;

-- Begin Bug 21475200
alter sequence dvsys.command_rule$_seq nomaxvalue;
alter sequence dvsys.rule$_seq nomaxvalue;
alter sequence dvsys.rule_set$_seq nomaxvalue;
alter sequence dvsys.realm$_seq nomaxvalue;
-- End Bug 21475200

-- Project 46892
BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW SYS.dv$configuration_audit
AS SELECT
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
FROM sys.v$unified_audit_trail where audit_type in (select unique audit_type from sys.v$unified_audit_record_format where component = ''Database Vault'') and DV_ACTION_CODE > 20000'
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
AS SELECT
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
FROM sys.v$unified_audit_trail where audit_type in (select unique audit_type from sys.v$unified_audit_record_format where component = ''Database Vault'') and DV_ACTION_CODE < 20000'
;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

-- Begin Bug 21158282
DROP VIEW dvsys.ku$_dv_comm_rule_alts_v;
DROP TYPE dvsys.ku$_dv_comm_rule_alts_t;
DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_COMMAND_RULE_ALTS' and version = 1202000000 and model = 'ORACLE';
-- End Bug 21158282

-- Begin Bug 20747653
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

CREATE OR REPLACE VIEW DVSYS.dba_dv_role
(
      role
    , rule_name
    , enabled
)
AS SELECT
      m.role
    , d.name
    , m.enabled
FROM dvsys.role$ m, dvsys.dv$rule_set d
WHERE m.rule_set_id# = d.id#
/
-- End Bug 20747653

-- Project 46814

--updating tables
delete from dvsys.command_rule$ where scope <> 1;
delete from dvsys.rule_set_rule$ rsr where rsr.RULE_SET_ID# in (select rs.id# from dvsys.rule_set$ rs where scope <> 1);
delete from dvsys.rule_set_t$ rst where rst.id# in (select rs.id# from dvsys.rule_set$ rs where scope <> 1);
delete from dvsys.rule_set$ where scope <> 1; 
delete from dvsys.rule_t$ rt where rt.id# in (select r.id# from dvsys.rule$ r where scope <> 1);
delete from dvsys.rule$ where scope <> 1; 

-- lrg 16571767:drop these columns since lower version packages did not
-- specify columns list when inserting, so cannot be recompiled with 
-- these new columns. 

alter table dvsys.rule$ drop column scope;
alter table dvsys.rule_set$ drop column scope;

-- updating the views

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
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 4) 
/

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
FROM dvsys.rule_set_rule$ m
     ,dvsys.dv$rule_set d1
     ,dvsys.dv$rule d2
WHERE
    d1.id# = m.rule_set_id#
    and d2.id# = m.rule_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule
(
      name
    , rule_expr
)
AS SELECT
      d.name
    , m.rule_expr
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 4)
/

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

--bug 20917038
CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set_rule
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
    and d2.id# = m.rule_id#
/
--end bug 20917038

--updating the ku$* datapump views.
-- UDT and object-view for 'DVPS_RULE' homogeneous type
-- (xmltag: 'DVPS_RULE_T', XSLT: rdbms/xml/xsl/kudvrul.xsl),
-- representing Rules added using CREATE_RULE.
-- This object-view is similar to the DVSYS.dv$rule view.
create or replace type dvsys.ku$_dv_rule_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  rule_name     varchar2(128),                              /* name of Rule */
  rule_expr     varchar2(1024),       /* PL/SQL boolean expression for Rule */
  language      varchar2(3)                        /* language of Rule name */
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
  with object identifier (rule_name) as
  select '0','0',
          rult.name,
          rul.rule_expr,
          rult.language
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


-- UDT and object-view for 'DVPS_RULE_SET' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_T', XSLT: rdbms/xml/xsl/kudvruls.xsl),
-- representing Rule Sets added using CREATE_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set view.
create or replace type dvsys.ku$_dv_rule_set_t as object
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
  handler         varchar2(1024) /* PL/SQL routine for custom event handler */
)
/

-- The rule_set$.id# sequence starts at 5000, so Rule Sets with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. 
create or replace force view dvsys.ku$_dv_rule_set_view
       of dvsys.ku$_dv_rule_set_t
  with object identifier (rule_set_name) as
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
          ruls.handler
  from    dvsys.rule_set$               ruls,
          dvsys.rule_set_t$             rulst
  where   ruls.id# = rulst.id#
    and   ruls.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/


-- UDT and object-view for 'DVPS_RULE_SET_MEMBERSHIP' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_MEMBERSHIP_T', XSLT: rdbms/xml/xsl/kudvrsm.xsl),
-- representing the Rules added to a Rule Set using ADD_RULE_TO_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set_rule view.
create or replace type dvsys.ku$_dv_rule_set_member_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
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
  with object identifier (rule_set_name,rule_name) as
  select '0','0',
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

delete from dvsys.realm_t$ rlmt where rlmt.id# in (select rlm.id# from dvsys.realm$ rlm where scope <> 1);
delete from dvsys.realm$ where scope <> 1;

alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1;

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
ADD CONSTRAINT "REALM_AUTH$_UK1" UNIQUE
(
REALM_ID#
, GRANTEE_UID#
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

CREATE OR REPLACE VIEW DVSYS.dv$realm
(
      id#
    , name
    , description
    , audit_options
    , realm_type
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
    , u.name
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
    , sys.user$ u
WHERE
    d1.id# (+)= m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
    AND m.grantee_uid# = u.user#
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
AS 
SELECT
      m.id#
    , m.realm_id#
    , d.name
    , u.name
    , m.object_name
    , m.object_type
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm_object$ m, dvsys.dv$realm d, sys.user$ u
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = u.user#
UNION
SELECT
      m.id#
    , m.realm_id#
    , d.name
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

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm
(
      name
    , description
    , audit_options
    , realm_type
    , enabled
)
AS SELECT
      d.name
    , d.description
    , m.audit_options
    , decode(m.realm_type, 0, 'REGULAR',
                           1, 'MANDATORY')
    , m.enabled
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(d.id#, 6)
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
    , u.name
    , d2.name
    , c.value
FROM dvsys.realm_auth$ m
    , dvsys.dv$realm d1
    , dvsys.dv$rule_set d2
    , dvsys.dv$code c
    , sys.user$ u
WHERE
    d1.id# (+)= m.realm_id#
    AND d2.id# (+)= m.auth_rule_set_id#
    AND c.code_group (+) = 'REALM_OPTION'
    AND c.code (+) = TO_CHAR(m.auth_options)
    AND m.grantee_uid# = u.user#
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
    , u.name
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d, sys.user$ u
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = u.user#
UNION
SELECT
     d.name
    , '%'
    , m.object_name
    , m.object_type
FROM dvsys.realm_object$ m, dvsys.dv$realm d
WHERE
    d.id# = m.realm_id# AND m.owner_uid# = &all_schema
/

create or replace type dvsys.ku$_dv_realm_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),              /* name of database vault realm */
  description   varchar2(1024),      /* description of database vault realm */
  language      varchar2(3),               /* language of realm description */
  enabled       varchar2(1),       /* enabled state of database vault realm */
  audit_options varchar2(78)       /* audit options of database vault realm */
)
/

create or replace force view dvsys.ku$_dv_realm_view
       of dvsys.ku$_dv_realm_t
  with object identifier (name) as
  select '0','0',
          rlmt.name,
          rlmt.description,
          rlmt.language,
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

--lrg 15796746: drop type ku$_dv_realm_member_t and re-create it
drop type dvsys.ku$_dv_realm_member_t force;

create or replace type dvsys.ku$_dv_realm_member_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),              /* name of database vault realm */
  object_owner  varchar2(128),   /* owner of object protected by this realm */
  object_name   varchar2(128),    /* name of object protected by this realm */
  object_type   varchar2(32)      /* type of object protected by this realm */
)
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
          dvsys.dv$realm_object rlmo
  where   rlm.id# = rlmt.id#
    and   rlmo.realm_id# = rlm.id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

create or replace type dvsys.ku$_dv_realm_auth_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  realm_name    varchar2(128),              /* name of database vault realm */
  grantee       varchar2(128),        /* owner of (or participant in) realm */
  rule_set_name varchar2(128),     /* rule set used to authorize (optional) */
  auth_options  varchar2(42)        /* authorization (participant or owner) */
)
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
          dvsys.dv$realm_auth            rlma,
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

show errors;

-- end project 46814

--Project 46812

drop function dvsys.CLAUSE_NAME;
drop function dvsys.PARAMETER_NAME;
drop function dvsys.PARAMETER_VALUE;
drop function dvsys.EVENT_NAME;
drop function dvsys.EVENT_LEVEL;
drop function dvsys.EVENT_TARGET;
drop function dvsys.EVENT_ACTION;
drop function dvsys.EVENT_ACTION_LEVEL;

--delete default command rules/rules/rule sets added in 12.2
delete from dvsys.command_rule$ where id# = 12; 
delete from dvsys.command_rule$ where id# = 13; 
delete from dvsys.command_rule$ where id# = 14; 
delete from dvsys.command_rule$ where id# = 15; 
delete from dvsys.command_rule$ where id# = 16; 
delete from dvsys.command_rule$ where id# = 17; 
delete from dvsys.command_rule$ where id# = 18; 
delete from dvsys.command_rule$ where id# = 19; 
delete from dvsys.command_rule$ where id# = 20; 
delete from dvsys.command_rule$ where id# = 21; 
delete from dvsys.command_rule$ where id# = 22; 
delete from dvsys.command_rule$ where id# = 23; 
delete from dvsys.command_rule$ where id# = 24; 
delete from dvsys.command_rule$ where id# = 25; 
delete from dvsys.command_rule$ where id# = 26; 
delete from dvsys.command_rule$ where id# = 28; 
delete from dvsys.command_rule$ where id# = 29; 

delete from dvsys.rule_set_rule$ where id# = 20;
delete from dvsys.rule_set_rule$ where id# = 21;
delete from dvsys.rule_set_rule$ where id# = 22;
delete from dvsys.rule_set_rule$ where id# = 23;
delete from dvsys.rule_set_rule$ where id# = 24;
delete from dvsys.rule_set_rule$ where id# = 25;
delete from dvsys.rule_set_rule$ where id# = 26;
delete from dvsys.rule_set_rule$ where id# = 27;
delete from dvsys.rule_set_rule$ where id# = 28;
delete from dvsys.rule_set_rule$ where id# = 29;
delete from dvsys.rule_set_rule$ where id# = 30;
delete from dvsys.rule_set_rule$ where id# = 31;

delete from dvsys.rule$ where id# = 200;
delete from dvsys.rule$ where id# = 201;
delete from dvsys.rule$ where id# = 202;
delete from dvsys.rule$ where id# = 203;
delete from dvsys.rule$ where id# = 204;
delete from dvsys.rule$ where id# = 205;
delete from dvsys.rule$ where id# = 206;
delete from dvsys.rule$ where id# = 207;
delete from dvsys.rule$ where id# = 208;
delete from dvsys.rule$ where id# = 209;
delete from dvsys.rule$ where id# = 210;
delete from dvsys.rule$ where id# = 211;
delete from dvsys.rule$ where id# = 212;

delete from dvsys.rule_t$ where id# = 200;
delete from dvsys.rule_t$ where id# = 201;
delete from dvsys.rule_t$ where id# = 202;
delete from dvsys.rule_t$ where id# = 203;
delete from dvsys.rule_t$ where id# = 204;
delete from dvsys.rule_t$ where id# = 205;
delete from dvsys.rule_t$ where id# = 206;
delete from dvsys.rule_t$ where id# = 207;
delete from dvsys.rule_t$ where id# = 208;
delete from dvsys.rule_t$ where id# = 209;
delete from dvsys.rule_t$ where id# = 210;
delete from dvsys.rule_t$ where id# = 211;
delete from dvsys.rule_t$ where id# = 212;

delete from dvsys.rule_set$ where id# = 11;
delete from dvsys.rule_set$ where id# = 12;
delete from dvsys.rule_set$ where id# = 13;
delete from dvsys.rule_set$ where id# = 14;
delete from dvsys.rule_set$ where id# = 15;
delete from dvsys.rule_set$ where id# = 16;
delete from dvsys.rule_set$ where id# = 17;
delete from dvsys.rule_set$ where id# = 18;
delete from dvsys.rule_set$ where id# = 19;
delete from dvsys.rule_set$ where id# = 20;

delete from dvsys.rule_set_t$ where id# = 11;
delete from dvsys.rule_set_t$ where id# = 12;
delete from dvsys.rule_set_t$ where id# = 13;
delete from dvsys.rule_set_t$ where id# = 14;
delete from dvsys.rule_set_t$ where id# = 15;
delete from dvsys.rule_set_t$ where id# = 16;
delete from dvsys.rule_set_t$ where id# = 17;
delete from dvsys.rule_set_t$ where id# = 18;
delete from dvsys.rule_set_t$ where id# = 19;
delete from dvsys.rule_set_t$ where id# = 20;

update dvsys.command_rule$ set clause_id#=0, parameter_name='%', event_name='%', component_name='%', action_name='%' where id#=10;

delete from dvsys.command_rule$ where (clause_id# > 0 and code_id# = 49) or (clause_id# > 0 and code_id# = 42);

alter table dvsys.command_rule$ drop constraint COMMAND_RULE$_UK1;

BEGIN
EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
ADD CONSTRAINT "COMMAND_RULE$_UK1" UNIQUE
(
CODE_ID#
,OBJECT_OWNER_UID#
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

--Bug 20412469: alter columns claude_id#, parameter_name, event_name,
--component_name, action_name in command_rule$ table to NULL.
alter table dvsys.command_rule$ modify (clause_id# NULL);
alter table dvsys.command_rule$ modify (parameter_name NULL);
alter table dvsys.command_rule$ modify (event_name NULL);
alter table dvsys.command_rule$ modify (component_name NULL);
alter table dvsys.command_rule$ modify (action_name NULL);

--end bug 20412469

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
AS
SELECT
      m.id#
    , m.code_id#
    , d2.code
    , m.rule_set_id#
    , d1.name
    , u.name
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
    ,sys.user$ u
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
    AND m.object_owner_uid# = u.user#
UNION
SELECT
      m.id#
    , m.code_id#
    , d2.code
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
FROM dvsys.command_rule$ m
    ,dvsys.dv$rule_set d1
    ,dvsys.dv$code d2
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
    AND m.object_owner_uid# = &all_schema
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
AS
SELECT
      d2.code
    , d1.name
    , u.name
    , m.object_name
    , m.enabled
    , m.privilege_scope
FROM dvsys.command_rule$ m
    ,dvsys.dv$rule_set d1
    ,dvsys.dv$code d2
    ,sys.user$ u
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
    AND m.object_owner_uid# = u.user#
UNION
SELECT
      d2.code
    , d1.name
    , '%'
    , m.object_name
    , m.enabled
    , m.privilege_scope
FROM dvsys.command_rule$ m
    ,dvsys.dv$rule_set d1
    ,dvsys.dv$code d2
WHERE
    d1.id# = m.rule_set_id#
    AND d2.id# = m.code_id#
    AND m.object_owner_uid# = &all_schema
/

-- UDT and object-view for 'DVPS_COMMAND_RULE' homogeneous type
-- (xmltag: 'DVPS_COMMAND_RULE_T', XSLT: rdbms/xml/xsl/kudvcr.xsl),
-- representing the Command Rules created using CREATE_COMMAND_RULE.
-- This object-view selects directly from the DVSYS.dv$command_rule view.
create or replace type dvsys.ku$_dv_command_rule_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  command         varchar2(30),                 /* SQL statement to protect */
  rule_set_name   varchar2(90),                         /* name of Rule Set */
  object_owner    varchar2(30),                             /* schema owner */
  object_name     varchar2(128),       /* object name (may be wildcard '%') */
  enabled         varchar2(1)   /* the Command Rule is enabled ('Y' or 'N') */
)
/

-- The command_rule$.id# sequence starts at 5000, so Command Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
create or replace force view dvsys.ku$_dv_command_rule_view
       of dvsys.ku$_dv_command_rule_t
  with object identifier (rule_set_name) as
  select '0','0',
          command,
          rule_set_name,
          object_owner,
          object_name,
          enabled
  from    dvsys.dv$command_rule         cvcr
  where   cvcr.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

--end Project 46812

delete from DVSYS.realm_object$ where realm_id#=9 and object_type='ROLE' and object_name='CONNECT';

-------------------------------------------------
-- BEGIN: Project 46812 - Database Vault Policy
-------------------------------------------------
-- Disable foreign key constraints before truncate.
ALTER TABLE dvsys.policy_object$ disable constraint policy_object$_fk;
ALTER TABLE dvsys.policy_owner$ disable constraint policy_owner$_fk;
-- Truncate tables.
TRUNCATE TABLE dvsys.policy_object$;
TRUNCATE TABLE dvsys.policy_owner$;
TRUNCATE TABLE dvsys.policy$;
TRUNCATE TABLE dvsys.policy_t$;

-- Drop sequences.
DROP SEQUENCE dvsys.policy$_seq;
DROP SEQUENCE dvsys.policy_object$_seq;
DROP SEQUENCE dvsys.policy_owner$_seq;

-- Drop views.
DROP VIEW dvsys.dv$policy;
DROP VIEW dvsys.dba_dv_command_rule_id;
DROP VIEW dvsys.dba_dv_policy;
DROP VIEW dvsys.dba_dv_policy_object;
DROP VIEW dvsys.dba_dv_policy_owner;
DROP VIEW dvsys.policy_owner_policy;
DROP VIEW dvsys.policy_owner_policy_object;
DROP VIEW dvsys.policy_owner_realm;
DROP VIEW dvsys.policy_owner_realm_auth;
DROP VIEW dvsys.policy_owner_realm_object;
DROP VIEW dvsys.policy_owner_command_rule;
DROP VIEW dvsys.policy_owner_rule_set;
DROP VIEW dvsys.policy_owner_rule_set_rule;
DROP VIEW dvsys.policy_owner_rule;

-- Remove DV_POLICY_OWNER role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_POLICY_OWNER');

-- Revoke privilege from DV_POLICY_OWNER.
REVOKE EXECUTE ON dvsys.dbms_macadm FROM dv_policy_owner;

-- Remove the realm protection for DV_POLICY_OWNER.
delete from DVSYS.realm_object$ where
  object_name = 'DV_POLICY_OWNER' and object_type = 'ROLE';

-- Remove audit codes related to DV policy manangement.
delete from dvsys.code$ where id# >= 675 and id# <= 685;

-- Remove Data Pump support for DV policy.
DROP VIEW dvsys.ku$_dv_policy_v;
DROP VIEW dvsys.ku$_dv_policy_obj_r_v;
DROP VIEW dvsys.ku$_dv_policy_obj_c_v;
DROP VIEW dvsys.ku$_dv_policy_obj_c_alts_v;
DROP VIEW dvsys.ku$_dv_policy_owner_v;
DROP TYPE dvsys.ku$_dv_policy_t;
DROP TYPE dvsys.ku$_dv_policy_obj_r_t;
DROP TYPE dvsys.ku$_dv_policy_obj_c_t;
DROP TYPE dvsys.ku$_dv_policy_obj_c_alts_t;
DROP TYPE dvsys.ku$_dv_policy_owner_t;

-- Bug 21299533: Remove Data Pump support for DV authorization.
DROP VIEW dvsys.ku$_dv_auth_dp_v;
DROP VIEW dvsys.ku$_dv_auth_tts_v;
DROP VIEW dvsys.ku$_dv_auth_job_v;
DROP VIEW dvsys.ku$_dv_auth_proxy_v;
DROP VIEW dvsys.ku$_dv_auth_ddl_v;
DROP VIEW dvsys.ku$_dv_auth_prep_v;
DROP VIEW dvsys.ku$_dv_auth_maint_v;
DROP VIEW dvsys.ku$_dv_oradebug_v;
DROP VIEW dvsys.ku$_dv_accts_v;
DROP VIEW dvsys.ku$_dv_auth_diag_v;
DROP VIEW dvsys.ku$_dv_index_func_v;
DROP TYPE dvsys.ku$_dv_auth_dp_t;
DROP TYPE dvsys.ku$_dv_auth_tts_t;
DROP TYPE dvsys.ku$_dv_auth_job_t;
DROP TYPE dvsys.ku$_dv_auth_proxy_t;
DROP TYPE dvsys.ku$_dv_auth_ddl_t;
DROP TYPE dvsys.ku$_dv_auth_prep_t;
DROP TYPE dvsys.ku$_dv_auth_maint_t;
DROP TYPE dvsys.ku$_dv_oradebug_t;
DROP TYPE dvsys.ku$_dv_accts_t;
DROP TYPE dvsys.ku$_dv_auth_diag_t;
DROP TYPE dvsys.ku$_dv_index_func_t;

DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_DV_POLICY' and version = 1202000000 and model = 'ORACLE';
DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_DV_POLICY_OBJ_R' and version = 1202000000 and model = 'ORACLE';
DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_DV_POLICY_OBJ_C' and version = 1202000000 and model = 'ORACLE';
DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_DV_POLICY_OBJ_C_ALTS' and version = 1202000000 and model = 'ORACLE';
DELETE FROM sys.metaview$
  WHERE TYPE = 'DVPS_DV_POLICY_OWNER' and version = 1202000000 and model = 'ORACLE';

--------------------------------------------
-- END : Database Vault Policy
--------------------------------------------

--------------------------------------------
-- Project 46812: Training mode
--------------------------------------------
TRUNCATE TABLE dvsys.simulation_log$;
DROP PUBLIC SYNONYM dba_dv_simulation_log;
DROP VIEW dvsys.dba_dv_simulation_log;
DELETE FROM dvsys.code$ WHERE code_group = 'SIMULATION_VIOLATION';
DROP SEQUENCE dvsys.training_log$_seq;

-- Disable all the realms and command rules in the training mode.
UPDATE dvsys.realm$ SET enabled = 'N' WHERE enabled in ('S', 's');
UPDATE dvsys.command_rule$ SET enabled = 'N' WHERE enabled in ('S', 's');
commit;
--------------------------------------------
-- END : Training mode
--------------------------------------------

-- Project 46812: Disable user-specific CONNECT command rules.
update dvsys.command_rule$ set enabled = 'N' where code_id# = 300 and object_owner_uid# <> 2147483636;

-- Bug 21223263: drop synonym dvsys.configure_dv and procedure sys.configure_dv.
drop synonym dvsys.configure_dv;
drop procedure sys.configure_dv;
-- grant INHERIT PRIVILEGES on SYS to DVSYS so that SYS can run dvsys.configure_dv, 
-- which will be created by prvtmacp during dvrelod.
grant INHERIT PRIVILEGES on user SYS to DVSYS;

-- Bug 20505982: remove object privilege grant on dvsys.configure_dv_internal from sys and drop the package.
DELETE FROM sys.objauth$ WHERE obj# = (SELECT obj# FROM sys.obj$ WHERE name = 'CONFIGURE_DV_INTERNAL' AND owner# = 1279990 AND type# = 9) AND grantee# = 0 AND privilege# = 12;
-- drop both package header and package body with following statement.
drop package DVSYS.CONFIGURE_DV_INTERNAL;

-- Bug 19263135
drop view sys.cdb_dv_status;

-- Bug 19127377
delete from dvsys.dv_auth$ where grant_type = 'PREPROCESSOR';
drop view dvsys.dba_dv_preprocessor_auth;
delete from dvsys.code$ where id# > 672 AND id# < 675;
delete from dvsys.code_t$ where id# > 672 AND id# < 675;

-- Project 36761
delete from dvsys.dv_auth$ where grant_type = 'MAINTENANCE';
drop view dvsys.dba_dv_maintenance_auth;
delete from dvsys.code$ where id# in (197, 198, 199, 200, 201, 218, 219, 220, 686, 687);
delete from dvsys.code_t$ where id# in (197, 198, 199, 200, 201, 218, 219, 220, 686, 687);
-- End project 36761

-- Remove DIAGNOSTIC authorization support
delete from dvsys.dv_auth$ where grant_type = 'DIAGNOSTIC';
drop view dvsys.dba_dv_diagnostic_auth;
delete from dvsys.code$ where id# in (688, 689); 
delete from dvsys.code_t$ where id# in (688, 689);

-- Remove index functions
delete from dvsys.dv_auth$ where grant_type = 'INDEX_FUNCTION';
drop view dvsys.dba_dv_index_function;
delete from dvsys.code$ where id# in (690, 691);
delete from dvsys.code_t$ where id# in (690, 691);

-- Begin bug 20282732
delete from dvsys.code$ where id# = 205;
delete from dvsys.code_t$ where id# = 205;
-- End bug 20282732

-- Bug 17368273: Grant privs/roles to DVSYS
DECLARE
    -- procedure to grant privileges/roles to DVSYS
    PROCEDURE grant_to_dvsys(priv varchar2)
    AS
      stmt varchar2(4000) := 'GRANT ' || priv || ' TO DVSYS'; 
    BEGIN
      -- Bug 26631353: grant on legacy DB,
      -- and all containers for CDB enviornment.
      EXECUTE IMMEDIATE stmt;
    END;
BEGIN
  grant_to_dvsys('RESOURCE');
  grant_to_dvsys('DV_SECANALYST');
  grant_to_dvsys('DV_MONITOR');
  grant_to_dvsys('DV_ADMIN');
  grant_to_dvsys('DV_OWNER');
  grant_to_dvsys('DV_ACCTMGR');
  grant_to_dvsys('DV_PUBLIC');
  grant_to_dvsys('DV_PATCH_ADMIN');
  grant_to_dvsys('DV_STREAMS_ADMIN');
  grant_to_dvsys('DV_GOLDENGATE_ADMIN');
  grant_to_dvsys('DV_XSTREAM_ADMIN');
  grant_to_dvsys('DV_GOLDENGATE_REDO_ACCESS');
  grant_to_dvsys('DV_AUDIT_CLEANUP');
  grant_to_dvsys('DV_DATAPUMP_NETWORK_LINK');
  grant_to_dvsys('DV_POLICY_OWNER');
  grant_to_dvsys('ADMINISTER DATABASE TRIGGER');
  grant_to_dvsys('CREATE EVALUATION CONTEXT');
  grant_to_dvsys('CREATE LIBRARY');
  grant_to_dvsys('CREATE RULE');
  grant_to_dvsys('CREATE RULE SET');
  grant_to_dvsys('CREATE SYNONYM');
  grant_to_dvsys('CREATE VIEW');
  grant_to_dvsys('EXECUTE on sys.dbms_crypto');
  grant_to_dvsys('EXECUTE on sys.dbms_registry');
  grant_to_dvsys('EXECUTE on sys.dbms_rls');
  grant_to_dvsys('SELECT on sys.dba_policies');
  grant_to_dvsys('SELECT on sys.exu9rls');
END;
/

-- Bug 18733351: reverse the change to rule expressions.
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ACCTMGR'', ''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 3;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 4;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ADMIN'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 5;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_OWNER'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# =6;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''LBAC_DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id# = 7;

-- revert changes of bug fix 21045941
update dvsys.rule$ set rule_expr = 'DVSYS.parameter_name =''STANDBY_ARCHIVE_DEST'' OR DVSYS.parameter_name =''DB_RECOVERY_FILE_DEST_SIZE'' OR DVSYS.parameter_name LIKE ''%LOG_ARCHIVE_DEST%'' OR DVSYS.parameter_name NOT LIKE ''%_DEST%''' where id# = 211;

drop function DVSYS.GET_REQUIRED_SCOPE;

-- Bug 19252338: remove new default factors.
delete dvsys.factor$ where id# = 18;
delete dvsys.factor$ where id# = 19;
delete dvsys.factor$ where id# = 20;
execute dvf.dbms_macsec_function.drop_factor_function('DV$_Module');
execute dvf.dbms_macsec_function.drop_factor_function('DV$_Client_Identifier');
execute dvf.dbms_macsec_function.drop_factor_function('DV$_Dblink_Info');
delete dvsys.factor_t$ where id# = 18;
delete dvsys.factor_t$ where id# = 19;
delete dvsys.factor_t$ where id# = 20;

-------------------------------------------------------
-------   Changes for downgrading to 12.1.0.1   -------
-------------------------------------------------------

variable pre_version varchar2(30);
-- remember the previous version to which we are downgrading.
begin
  SELECT prv_version INTO :pre_version FROM registry$
  WHERE cid = 'CATPROC';
end;
/

BEGIN
  IF :pre_version < '12.1.0.2' THEN
    delete from DVSYS.realm_object$ where realm_id#=9 and object_type='ROLE' and object_name='AUDIT_ADMIN';
    delete from DVSYS.realm_object$ where realm_id#=9 and object_type='ROLE' and object_name='AUDIT_VIEWER';
  END IF;
END;
/

BEGIN
  IF :pre_version < '12.1.0.2' THEN
    execute immediate 'noaudit policy ORA_DV_AUDPOL';
    execute immediate 'drop audit policy ORA_DV_AUDPOL';
  END IF;
END;
/

BEGIN
  IF :pre_version < '12.1.0.2' THEN
    execute immediate 'drop public synonym dba_dv_status';
    execute immediate 'drop view dvsys.event_status';
    execute immediate 'drop view sys.dba_dv_status';
    execute immediate 'drop view dvsys.dba_dv_status';
    execute immediate 'drop type dvsys.event_status_table_type';
    execute immediate 'drop type dvsys.event_status_row_type';
  END IF;
END;
/

-- Bug 17342864
--modify owner/object_owner/grantee column back to NOT NULL
--During the 12.1.0.1 upgrade to MAIN, we remove user name from the
--unique key contraints for table realm_object$, realm_auth$ and
--command_rule$. So we drop them and re-create the unique key 
--contraints with the user name.
BEGIN
  IF :pre_version < '12.1.0.2' THEN

    execute immediate 'alter table dvsys.realm_object$ drop constraint REALM_OBJECT$_UK1';
    execute immediate 'alter table dvsys.realm_auth$ drop constraint REALM_AUTH$_UK1';
    execute immediate 'alter table dvsys.command_rule$ drop constraint COMMAND_RULE$_UK1';
    
    update dvsys.realm_object$ a set owner = (select name from sys.user$ where user# = a.owner_uid#) where a.owner_uid# <> &all_schema and (select name from sys.user$ where user# = a.owner_uid#) IS NOT NULL;
    update dvsys.realm_object$ set owner = '%' where owner_uid# = &all_schema;
    delete from dvsys.realm_object$ where owner IS NULL;

    update dvsys.realm_auth$ a set grantee = (select name from sys.user$ where user# = a.grantee_uid#) where (select name from sys.user$ where user# = a.grantee_uid#) IS NOT NULL;
    delete from dvsys.realm_auth$ where grantee IS NULL;

    update dvsys.command_rule$ a set object_owner = (select name from sys.user$ where user# = a.object_owner_uid#) where a.object_owner_uid# <> &all_schema and (select name from sys.user$ where user# = a.object_owner_uid#) IS NOT NULL;
    update dvsys.command_rule$ set object_owner = '%' where object_owner_uid# = &all_schema;
    delete from dvsys.command_rule$ where object_owner IS NULL;

    --In 12.1.0.1, the column storing user name is NOT NULL
    --and the column storing user id doesn't have the NOT NUL restriction.
    execute immediate 'alter table dvsys.realm_auth$ modify grantee varchar2(128) NOT NULL';
    execute immediate 'alter table dvsys.realm_auth$ modify grantee_uid# number NULL';
    execute immediate 'alter table dvsys.realm_object$ modify owner varchar(128) NOT NULL';
    execute immediate 'alter table dvsys.realm_object$ modify owner_uid# number NULL';
    execute immediate 'alter table dvsys.command_rule$ modify object_owner varchar(128) NOT NULL';
    execute immediate 'alter table dvsys.command_rule$ modify object_owner_uid# number NULL';

    -- Create unique constraints with the user name
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_AUTH$"
                         ADD CONSTRAINT "REALM_AUTH$_UK1" UNIQUE
                         (
                           REALM_ID#
                         , GRANTEE
                         , GRANTEE_UID#
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

    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."REALM_OBJECT$"
                         ADD CONSTRAINT "REALM_OBJECT$_UK1" UNIQUE
                         (
                           REALM_ID#
                         , OWNER
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

    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE DVSYS."COMMAND_RULE$"
                         ADD CONSTRAINT "COMMAND_RULE$_UK1" UNIQUE
                         (
                           CODE_ID#
                         , OBJECT_OWNER
                         , OBJECT_OWNER_UID#
                         , OBJECT_NAME
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

  END IF;
END;
/

-- Begin bug17623149 
BEGIN
  IF :pre_version < '12.1.0.2' THEN

    BEGIN
      EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."DOCUMENT$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00955) THEN NULL; --object has already been created      
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."MONITOR_RULE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00955) THEN NULL; --object has already been created      
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."REALM_COMMAND_RULE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00955) THEN NULL; --object has already been created      
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE 'CREATE SEQUENCE DVSYS."FACTOR_SCOPE$_SEQ" START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE ORDER';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00955) THEN NULL; --object has already been created      
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dv$document        
      (       
            ID#       
          , NAME      
          , DOC_TYPE  
          , DOC_REVISION      
          , ENABLED   
          , XML_DATA  
          , VERSION   
          , CREATED_BY        
          , CREATE_DATE       
          , UPDATED_BY        
          , UPDATE_DATE       
      )       
      AS SELECT       
            ID#       
          , NAME      
          , DOC_TYPE  
          , DOC_REVISION      
          , ENABLED   
          , XML_DATA  
          , VERSION   
          , CREATED_BY        
          , CREATE_DATE       
          , UPDATED_BY        
          , UPDATE_DATE       
      FROM dvsys.document$';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dv$realm_command_rule      
      (       
            id#       
          , realm_id# 
          , realm_name        
          , code_id#  
          , command   
          , rule_set_id#      
          , rule_set_name     
          , object_owner      
          , object_name       
          , grantee   
          , privilege_scope   
          , enabled   
          , version   
          , created_by        
          , create_date       
          , updated_by        
          , update_date       
      )       
      AS SELECT       
            m.id#     
          , d3.id#    
          , d3.name   
          , m.code_id#        
          , d2.code   
          , m.rule_set_id#    
          , d1.name   
          , m.object_owner    
          , m.object_name     
          , m.grantee 
          , m.privilege_scope 
          , m.enabled 
          , m.version 
          , m.created_by      
          , m.create_date     
          , m.updated_by      
          , m.update_date     
      FROM dvsys.realm_command_rule$ m        
          ,dvsys.dv$rule_set d1       
          ,dvsys.dv$code d2   
          ,dvsys.dv$realm d3  
      WHERE   
          d1.id# = m.rule_set_id#     
          AND d2.id# = m.code_id#     
          AND d3.id# = m.realm_id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dv$factor_scope    
      (       
            id#       
          , name      
          , grantee   
          , version   
          , created_by        
          , create_date       
          , updated_by        
          , update_date       
      )       
      AS SELECT       
            m.id#     
          , d.name    
          , m.grantee 
          , m.version 
          , m.created_by      
          , m.create_date     
          , m.updated_by      
          , m.update_date     
      FROM dvsys.factor_scope$ m, dvsys.dv$factor d   
      WHERE   
          m.factor_id# = d.id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dv$monitor_rule    
      (       
           id#        
         , name       
         , description        
         , monitor_rule_set_id#       
         , monitor_rule_set_name      
         , restart_freq       
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
         , m.monitor_rule_set_id#     
         , drs.name   
         , m.restart_freq     
         , m.enabled  
         , m.version  
         , m.created_by       
         , m.create_date      
         , m.updated_by       
         , m.update_date      
      FROM dvsys.monitor_rule$ m      
         , dvsys.monitor_rule_t$ d    
         , dvsys.dv$rule_set drs      
      WHERE   
         m.id# = d.id#        
         AND d.language = DVSYS.dvlang(d.id#, 7)      
         AND drs.id#  = m.monitor_rule_set_id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dba_dv_document    
      (       
            NAME      
          , DOC_TYPE  
          , DOC_REVISION      
          , ENABLED   
          , XML_DATA  
      )       
      AS SELECT       
            NAME      
          , DOC_TYPE  
          , DOC_REVISION      
          , ENABLED   
          , XML_DATA  
      FROM dvsys.document$';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dba_dv_realm_command_rule  
      (       
           realm_name 
         , command    
         , rule_set_name      
         , object_owner       
         , object_name        
         , grantee    
         , privilege_scope    
         , enabled    
      )       
      AS SELECT       
           d3.name    
         , d2.code    
         , d1.name    
         , m.object_owner     
         , m.object_name      
         , m.grantee  
         , m.privilege_scope  
         , m.enabled  
      FROM dvsys.realm_command_rule$ m        
         ,dvsys.dv$rule_set d1        
         ,dvsys.dv$code d2    
         ,dvsys.dv$realm d3   
      WHERE   
         d1.id# = m.rule_set_id#      
         AND d2.id# = m.code_id#      
         AND d3.id# = m.realm_id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dba_dv_factor_scope        
      (       
            factor_name       
          , grantee   
      )       
      AS SELECT       
             d.name   
           , m.grantee        
      FROM dvsys.factor_scope$ m, dvsys.dv$factor d   
      WHERE   
           m.factor_id# = d.id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

    BEGIN
      EXECUTE IMMEDIATE '
      CREATE OR REPLACE VIEW DVSYS.dba_dv_monitor_rule        
      (       
            name      
          , description       
          , monitor_rule_set_name     
          , restart_freq      
          , enabled   
      )       
      AS SELECT       
            d.name    
          , d.description     
          , drs.name  
          , m.restart_freq    
          , m.enabled 
      FROM dvsys.monitor_rule$ m      
          , dvsys.monitor_rule_t$ d   
          , dvsys.dv$rule_set drs     
      WHERE   
          m.id# = d.id#       
          AND d.language = DVSYS.dvlang(d.id#, 7)     
          AND drs.id#  = m.monitor_rule_set_id#';
    EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -00942) THEN NULL; --ignore table or view does not exist
      ELSE RAISE;
      END IF;
    END;

  END IF;
END;
/

-- Remove DEBUG CONNECT authorization support
delete from dvsys.dv_auth$ where grant_type = 'DEBUG_CONNECT';
drop view dvsys.dba_dv_debug_connect_auth;
delete from dvsys.code$ where id# in (692, 693); 
delete from dvsys.code_t$ where id# in (692, 693);

EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '12.1.0');
