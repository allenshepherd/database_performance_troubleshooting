Rem
Rem $Header: rdbms/admin/pdbdba.sql /main/43 2017/08/23 10:35:38 akruglik Exp $
Rem
Rem pdbdba.sql
Rem
Rem Copyright (c) 2016, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      pdbdba.sql - grant privileges to a specified user/role (e.g. PDB_DBA)
Rem
Rem    DESCRIPTION
Rem      Grant privileges/roles to a specified user or role based on 
Rem      privileges/roles granted to another user or role.  Privileges/roles 
Rem      are restricted to reduce possibility of security issues in a Cloud PDB
Rem
Rem    NOTES
Rem      This script takes 2 arguments: 
Rem        - name of a source user/role (i.e. user/role whose privileges/roles 
Rem          are being partially duplicated) and 
Rem        - name of a target user/role (i.e. user/role to whom a subset of 
Rem          privileges/roles currently granted to "source user/role" will 
Rem          be granted.)
Rem      Both names are taken to be case-sensitive (i.e. this script will 
Rem      not attempt to uppercase them)
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/pdbdba.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/pdbdba.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    akruglik    08/21/17 - Bug 26639628: do not attempt to grant READ on
Rem                           JSON$USER_COLLECTION_METADATA if it does not
Rem                           exist
Rem    akruglik    08/16/17 - Bug 26633457: avoid trying to replicate
Rem                           privileges on cursor-duration types
Rem    aksshah     07/19/17 - Bug 26486410: Disable DBMS_DNFS package
Rem    risgupta    06/14/17 - Bug 26246240: Update CONFIGURE_OLS calls
Rem    sankejai    05/02/17 - Bug 25973874: do not grant execute on
Rem                           DBMS_SERVICE_PRVT
Rem    sankejai    04/26/17 - Bug 25957772: do not grant execute on
Rem                           DBMS_NETWORK_ACL_ADMIN
Rem    sankejai    04/19/17 - Bug 25839949: fix missing obj_type column
Rem    akruglik    04/17/17 - Lrg 20215745: avoid using regular expression
Rem                           operator when checking for XDB being set in
Rem                           _no_catalog parameter as it can cause the server
Rem                           to hang
Rem    sankejai    04/08/17 - Bug 25839949: Handle privileges on directory obj
Rem    akruglik    03/22/17 - XbranchMerge akruglik_noxdb_cleanup from
Rem                           st_rdbms_pt-dwcs
Rem    akruglik    03/13/17 - XbranchMerge akruglik_noxdb from st_rdbms_pt-dwcs
Rem    akruglik    03/10/17 - do not grant privileges on XDB objects if XDB
Rem                           schema was not installed
Rem    risgupta    08/02/16 - Bug 23639570: Update OLS_ENFORCEMENT calls
Rem    yanxie      06/27/16 - bug 23598384: grant select on all_sumdelta
Rem    hohung      06/01/16 - Bug 23477464: grant under any table privilege
Rem    hohung      06/01/16 - Bug 23477556: grant redefine any table privilege
Rem    amunnoli    05/27/16 - Bug 23482255:grant execute on DBMS_AUDIT_MGMT
Rem    alui        05/24/16 - Bug 23341943: do not grant execute on DBMS_WLM
Rem    akruglik    05/19/16 - Bug 23272470: grant WM_ADMIN_ROLE
Rem    akruglik    05/17/16 - Bug 23023367: undo earlier fix for bug 23023367 
Rem                           (do not grant MANAGE SCHEDULER)
Rem    akruglik    05/17/16 - Bug 23279077: do not grant CREATE [ANY] LIBRARY
Rem    skayoor     05/12/16 - Bug 23222571: Grant EXECUTE on DBMS_RLS
Rem    dvoss       05/09/16 - Bug 23262072: do not grant execute on 
Rem                           DBMS_LOGSTDBY or DBMS_ROLLING
Rem    akruglik    05/06/16 - Bug 23236571: don't grant EXECUTE on
Rem                           DBMS_SHARED_POOL
Rem    akruglik    05/03/16 - Bug 23218831: grant ADMINISTER ANY SQL TUNING SET
Rem                           privilege
Rem    akruglik    04/28/16 - Bug 23147238: do not grant EXECUTE on DBMS_JAVA
Rem    akruglik    04/21/16 - Bug 23045705: grant ADM_PARALLEL_EXECUTE_TASK
Rem    akruglik    04/21/16 - Bug 23143087: do not grant execute on
Rem                           DBMS_QOPATCH
Rem    akruglik    04/20/16 - Bug 23115321: do not grant EXECUTE on DBMS_IR
Rem    prshanth    04/18/16 - bug 23021124: do not grant exec on DBMS_MONITOR
Rem    akruglik    04/14/16 - Bug 23085003: grant ADMINISTER RESOURCE MANAGER
Rem    akruglik    04/14/16 - Bug 23092018: do not grant execute on
Rem                           DBMS_SERVER_TRACE
Rem    juilin      04/11/16 - bug 22968913: grant READ privilege on
Rem                           XDB.JSON$USER_COLLECTION_METADATA
Rem    akruglik    04/11/16 - bug 23078705: grant EXECUTE on CTX_ADM
Rem    akruglik    04/11/16 - bug 22910920: skip granting CREATE ANY CREDENTIAL
Rem    akruglik    04/07/16 - bug 22977654: grant EXECUTE on CTXSYS packages
Rem    akruglik    04/07/16 - bug 23007589: grant FORCE ANY TRANSACTION
Rem    akruglik    04/07/16 - bug 23009442: grant ON COMMIT REFRESH
Rem    akruglik    04/07/16 - bug 23014151: grant RESUMABLE
Rem    akruglik    04/07/16 - bug 23023367: grant MANAGE SCHEDULER
Rem    akruglik    04/07/16 - bug 23025341: grant OPTIMIZER_PROCESSING_RATE
Rem    akruglik    04/07/16 - bug 23033228: grant GATHER_SYSTEM_STATISTICS
Rem    akruglik    04/07/16 - bug 23045091: grant use on edition ora$base
Rem    akruglik    04/07/16 - bug 23045548: grant execute on UTL_RECOMP
Rem    akruglik    04/07/16 - bug 23051308: grant SODA_APP
Rem    akruglik    04/07/16 - bug 23054976: gran execute on 
Rem                           DBMS_FLASHBACK_ARCHIVE (undoing change made for 
Rem                           bug 22820258)
Rem    akruglik    04/07/16 - bug 23055045: grant under any type/view
Rem    juilin      04/06/16 - bug 23025550: grant analyze any dictionary, 
Rem                           merge any view, manage tablespace to PDB Admin
Rem    pjulsaks    04/05/16 - Bug 23002218: grant ANALYZE ANY privilege
Rem    akruglik    04/07/15 - bug 23034639: grant execute on 
Rem                           DBMS_ADVANCED_REWRITE
Rem    svaziran    04/04/16 - bug 23050864: do not grant exec on DBMS_HM
Rem    svaziran    04/04/16 - bug 23027082: do not grant exec on DBMS_ADR%
Rem    svaziran    04/04/16 - bug 23046540: do not grant exec on DBMS_SYSTEM
Rem    amunnoli    03/22/16 - Bug 22981651: grant AUDIT System Privileges
Rem    akruglik    03/18/16 - Bug 19347428: grant ctxapp
Rem    akruglik    03/16/16 - Bug 22924122: do not grant execute on
Rem                           DBMS_SERVICE to PDB Admin
Rem    qyu         03/15/16 - Bug 22917983: grant on xdb tables
Rem    akruglik    03/14/16 - Bug 22927454: grant execute on DBMS_INMEMORY
Rem    amunnoli    03/09/16 - Bug 22887440: grant TSDP specific privileges
Rem    rbolarr     03/08/16 - Bug 22865702: grant privileges for DB security
Rem    akruglik    03/08/16 - Bug 22709398: grant execute on DBMS_LOCK
Rem    akruglik    03/03/16 - Bug 22709398: grant execute on DBMS_REDACT
Rem    akruglik    03/03/16 - Bug 22820258: do not grant execute on 
Rem                           DBMS_FLASHBACK_ARCHIVE
Rem    akruglik    03/03/16 - Bug 22841963: add RESTRICTED SESSION privilege
Rem    akruglik    03/03/16 - Bug 22864357: handle identifiers besides grantee
Rem                           that need to be delimited
Rem    ssonawan    02/25/16 - Bug 22755546: PDB Express changes for audit
Rem    risgupta    02/15/16 - PDB Express: DB Security changes
Rem    akruglik    02/18/16 - (22697949) add UNLIMITED TABLESPACE and EXECUTE
Rem                           ANY + use args to specify source and target
Rem                           grantees
Rem    akruglik    02/09/16 - Grant object-specific EXECUTE privilegs and DEBUG
Rem                           privileges to PDB_DBA
Rem    akruglik    01/21/16 - script to grant privileges to pdb_dba role
Rem    akruglik    01/21/16 - Created
Rem

set serveroutput on

define source=&&1
define target=&&2

-- This script will examine three dictionary views:
-- - DBA_ROLE_PRIVS (only SELECT_CATALOG_ROLE and XDBADMIN for now)
-- - DBA_TAB_PRIVS (SELECT/READ/EXECUTE)
-- - DBA_SYS_PRIVS (CREATE/ALTER/DROP/COMMENT/LOCK/READ/SELECT/EXECUTE/DEBUG/
--                  INSERT/DELETE/UPDATE/RESTRICTED SESSION/
--                  GRANT ANY OBJECT PRIVILEGE (to allow grantee, among other 
--                  things, to revoke privileges granted to PUBLIC) 
--   except for privileges related to directories and database links
-- looking for privileges granted to the "source" user/role and grant them and
-- UNLIMITED TABLESPACE (if the target is not a role), PURGE DBA_RECYCLEBIN 
-- and RESOURCE  to "target" user/role WITH GRANT/ADMIN OPTION (where 
-- appropriate)
DECLARE
  delim_grantee VARCHAR2(200) := DBMS_ASSERT.ENQUOTE_NAME('&target', FALSE);

  cursor c is
    --
    -- roles
    --
    select granted_role as role, null as priv, null as obj_owner, 
           null as obj_name, null as obj_type, 0 as edition,
           ' WITH ADMIN OPTION' as opt
      from dba_role_privs 
     where grantee='&source'
        and granted_role in 
              ('SELECT_CATALOG_ROLE', 'XDBADMIN', 
               'GATHER_SYSTEM_STATISTICS', 'OPTIMIZER_PROCESSING_RATE',
               'WM_ADMIN_ROLE')
    union all
    --
    -- roles not granted to DBA
    --
    select role, null as priv, null as obj_owner, 
           null as obj_name, null as obj_type, 0 as edition,
           ' WITH ADMIN OPTION' as opt 
      from dba_roles
     where role in ('RESOURCE', 'AQ_ADMINISTRATOR_ROLE', 'CTXAPP', 'SODA_APP',
                    'ADM_PARALLEL_EXECUTE_TASK')
    union all
    --
    -- object privs
    -- NOTES: 
    --   - ALL object privs should go in the first in-line view below (p) 
    --     to ensuire that we add WGO only when the grantee is a user (since 
    --     object privs cannot be granted to a role WITH GRANT OPTION)
    --   - privileges on CONSUMER_GROUPs, PROGRAMs and EVALUATION CONTEXTs
    --     are visible through DBA_TAB_PRIVS but cannot be granted using 
    --     GRANT statement; fortunately, we can detect them by checking 
    --     whether dba_tab_privs.type != 'UNKNOWN'
    --   - privilges on JAVA RESOURCEs also cannot be granted using GRANT 
    --     statement, so these will be skipped as well
    --
    select p.role, p.priv, p.obj_owner, p.obj_name, p.obj_type, edition,
           decode(r.role, NULL, ' WITH GRANT OPTION', NULL) as opt
    from (select NULL as role, p.privilege as priv, p.owner as obj_owner,
                 p.table_name as obj_name, p.type as obj_type, 0 as edition
            from dba_tab_privs p
           where p.grantee='&source'
             and p.privilege in ('SELECT', 'READ', 'WRITE', 'EXECUTE')
             and p.type NOT IN ('UNKNOWN', 'JAVA RESOURCE')
             and not (    p.owner = 'SYS' 
                      and p.table_name in 
                            ('DBMS_SERVICE', 'DBMS_SERVICE_PRVT', 'DBMS_WLM',
                             'DBMS_SYSTEM', 'DBMS_HM', 'DBMS_ADR_APP',
                             'DBMS_ADR', 'DBMS_ADR_INTERNAL',
                             'HM_SQLTK_INTERNAL', 'DBMS_SERVER_TRACE',
                             'DBMS_MONITOR', 'DBMS_IR', 'DBMS_QOPATCH', 
                             'DBMS_JAVA', 'DBMS_SHARED_POOL', 'DBMS_DNFS',
                             'DBMS_LOGSTDBY', 'DBMS_ROLLING',
                             'DBMS_NETWORK_ACL_ADMIN'))
             -- Bug 26633457: exclude privileges on cursor-duration types
             and not (    p.type = 'TYPE' 
                      and exists 
                            (select NULL 
                               from dba_types t, sys.type$ tt
                               where p.owner=t.owner 
                                 and p.table_name=t.type_name 
                                 and t.type_oid=tt.toid 
                                 and bitand(tt.properties, 8388608)=8388608))
          union all
          --
          -- dml privileges on tables owned by XDB
          --
          select NULL as role, p.privilege as priv, p.owner as obj_owner,
                 p.table_name as obj_name, p.type as obj_type, 0 as edition
            from dba_tab_privs p
           where p.grantee='&source'
             and p.grantor='XDB'
             and p.owner='XDB'
             and p.privilege in ('INSERT', 'DELETE', 'UPDATE')
          union all
          --
          -- object privileges not granted to DBA
          --
          --
          -- READ privilege on XDB.JSON$USER_COLLECTION_METADATA
          -- 
          -- NOTE: Do no try to grant it if XDB schema has not been created
          --
          select null as role, 'READ' as priv, owner as obj_owner, 
                 object_name as obj_name, null as obj_type,
                 0 as edition
            from dba_objects 
           where owner='XDB' 
             and object_name='JSON$USER_COLLECTION_METADATA'
             and object_type='VIEW'
          union all
          -- 
          -- SELECT privilege on SYS.ALL_SUMDELTA
          --
          select null as role, 'SELECT' as priv, 'SYS' as obj_owner,
                 'ALL_SUMDELTA' as obj_name, null as obj_type, 0 as edition
           from dual
          union all 
          --
          -- EXECUTE on packages owned by SYS
          -- 
          select null as role, 'EXECUTE' as priv, 'SYS' as obj_owner, 
                 object_name as obj_name, object_type as obj_type, 0 as edition
            from dba_objects
           where owner = 'SYS' 
             and object_type = 'PACKAGE'
             and object_name in 
                   ('DBMS_REDACT', 'DBMS_LOCK', 'DBMS_LOB', 'DBMS_SPM', 
                    'DBMS_INMEMORY', 'DBMS_REDEFINITION', 'DBMS_AQ', 
                    'DBMS_AQADM', 'UTL_RECOMP', 'DBMS_ADVANCED_REWRITE',
                    'DBMS_RLS')
          union all
          -- 
          -- EXECUTE on packages owned by XDB
          -- 
          select null as role, 'EXECUTE' as priv, 'XDB' as obj_owner, 
                 object_name as obj_name, object_type as obj_type, 0 as edition
            from dba_objects
           where owner = 'XDB' 
             and object_type = 'PACKAGE'
             and object_name in 
                   ('DBMS_SODA_ADMIN')
          union all
          -- 
          -- EXECUTE on packages owned by CTXSYS
          -- 
          select null as role, 'EXECUTE' as priv, 'CTXSYS' as obj_owner, 
                 object_name as obj_name, object_type as obj_type, 0 as edition
            from dba_objects
           where owner = 'CTXSYS' 
             and object_type = 'PACKAGE'
             and object_name in 
                   ('CTX_DDL', 'CTX_OUTPUT', 'CTX_THES', 'CTX_ULEXER',
                    'CTX_ENTITY', 'CTX_TREE', 'CTX_ANL', 'CTX_ADM')
          union all
          --
          -- USE ON EDITION ORA$BASE
          --
         select null as role, 'USE' as priv, 'SYS' as obj_owner, 
                 edition_name as obj_name, null as obj_type, 1 as edition
            from dba_editions
           where edition_name='ORA$BASE') p, 
         dba_roles r right outer join 
           (select '&target' as name from dual) nm 
           on r.role=nm.name
    union all
    --
    -- system privs
    --
    select NULL as role, privilege as priv, null as obj_owner, 
           null as obj_name, null as obj_type, 0 as edition,
           ' WITH ADMIN OPTION' as opt
      from dba_sys_privs
     where grantee='&source'
       and ((    privilege like 'CREATE %' 
             and privilege not in ('CREATE CREDENTIAL', 
                                   'CREATE ANY CREDENTIAL', 
                                   'CREATE EXTERNAL JOB',
                                   'CREATE LIBRARY', 'CREATE ANY LIBRARY'))  or
            privilege like 'ALTER %'                  or
            privilege like 'DROP %'                   or
            privilege like 'COMMENT %'                or
            privilege like 'LOCK %'                   or
            privilege like 'READ %'                   or
            privilege like 'SELECT %'                 or
            privilege like 'EXECUTE %'                or
            privilege like 'DEBUG %'                  or
            privilege like 'INSERT %'                 or
            privilege like 'DELETE %'                 or
            privilege like 'UPDATE %'                 or
            privilege like 'AUDIT %'                  or
            privilege like 'ADMINISTER %SQL TUNING SET' or
            privilege  in ('RESTRICTED SESSION',
                           'GRANT ANY OBJECT PRIVILEGE',
                           'QUERY REWRITE',
                           'ADMINISTER SQL MANAGEMENT OBJECT',
                           'GLOBAL QUERY REWRITE',
                           'ADVISOR',
                           'ADMINISTER DATABASE TRIGGER',
                           'CHANGE NOTIFICATION',
                           'ADMINISTER RESOURCE MANAGER',
                           'ANALYZE ANY DICTIONARY',
                           'MERGE ANY VIEW',
                           'MANAGE TABLESPACE',
                           'UNDER ANY TYPE',
                           'UNDER ANY VIEW',
                           'UNDER ANY TABLE',
			   'REDEFINE ANY TABLE',
                           'RESUMABLE',
                           'ON COMMIT REFRESH',
                           'FORCE ANY TRANSACTION',
                           'ANALYZE ANY'))
       and privilege not like '% DIRECTORY'
       and privilege not like '% DATABASE LINK'
    union all
    --
    -- UNLIMITED TABLESPACE (system priv that cannot be granted to a role)
    --
    select null as role, 'UNLIMITED TABLESPACE' as priv, null as obj_owner, 
           null as obj_name, null as obj_type, 0 as edition,
           ' WITH ADMIN OPTION' as opt 
     from  dba_users
     where username = '&target'
    union all
    --
    -- need to grant PURGE DBA_RECYCLEBIN to enable PURGE DBA_RECYCLEBIN 
    -- operation since we are not granting SYSDBA
    --
    select null as role, 'PURGE DBA_RECYCLEBIN' as priv, null as obj_owner, 
           null as obj_name, null as obj_type, 0 as edition,
           ' WITH ADMIN OPTION' as opt 
     from dual;
BEGIN
  FOR privs in c
    LOOP
      declare 
        stmt        VARCHAR2(1000);
        -- will ignore ORA-22812 which complains about attempting to grant on
        -- a nested table column's storage table (such as
        -- "SYS"."HS_PARTITION_COL_NAME")
        ntc_storage_tbl EXCEPTION;
        PRAGMA EXCEPTION_INIT(ntc_storage_tbl, -22812);
      BEGIN
        --  grant role or privilege
        if privs.role is not null then
          stmt := 
            'GRANT ' || DBMS_ASSERT.ENQUOTE_NAME(privs.role, FALSE) || ' ';
        else
          stmt := 'GRANT ' || privs.priv || ' ';
        end if;

        -- if object privilege, add 'on owner.object'
        if privs.obj_owner is not null then
          stmt :=  stmt || 'ON ';

          if privs.edition = 1 then
	    -- handle privileges on editions
            stmt :=  stmt || 'EDITION ';
          elsif privs.obj_type in ('DIRECTORY') then
            -- handle privileges on directories
            stmt := stmt || privs.obj_type || ' ';
          end if;

          stmt :=  stmt || 
            DBMS_ASSERT.ENQUOTE_NAME(privs.obj_owner, FALSE) || '.' ||
            DBMS_ASSERT.ENQUOTE_NAME(privs.obj_name, FALSE) || ' ';
        end if;

        -- add 'to grantee'
        stmt := stmt || 'TO ' || delim_grantee;

        -- if with grant|admin option, add it
        if privs.opt is not null then
          stmt := stmt || privs.opt;
        end if;

        -- execute assembled statement
        EXECUTE IMMEDIATE stmt;
      EXCEPTION
        WHEN ntc_storage_tbl THEN
          NULL;
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Failed statement: ' || stmt);
          RAISE;
      END;
    END LOOP;
END;
/

--------------------------------------------------------------------------
--------------      Provision Steps for DB Security         --------------
--------------------------------------------------------------------------

DECLARE
  delim_grantee VARCHAR2(200) := DBMS_ASSERT.ENQUOTE_NAME('&target', FALSE);
  cnt number;
BEGIN
  IF (('&&source' = 'DBA') AND ('&&target' != 'PDB_DBA')) THEN
    -- If Oracle Label Security is enabled,  Configure and Enable OLS and grant
    -- OLS-related privileges and roles to the target user WITH ADMIN OPTION
    SELECT count(*) INTO cnt FROM dba_registry r
      WHERE r.comp_name = 'Oracle Label Security'
        AND r.status = 'VALID';

    IF cnt = 1 THEN
      -- NOTE: we need to use EXECUTE IMMEDIATE to SYS.CONFIGURE_OLS and 
      --   SYS.OLS_ENFORCEMENT.ENABLE_OLS because otherwise we will get a 
      --   compile-time error that looks like
      --     PLS-00201: identifier 'SYS.CONFIGURE_OLS' must be declared
      -- if OLS is not installed
      EXECUTE IMMEDIATE 'CALL SYS.CONFIGURE_OLS()';
      EXECUTE IMMEDIATE 'CALL SYS.OLS_ENFORCEMENT.ENABLE_OLS()';

      -- OLS related grants
      EXECUTE IMMEDIATE 'GRANT EXEMPT ACCESS POLICY, LBAC_DBA TO '||
                        delim_grantee || ' WITH ADMIN OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_SYSDBA TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_COMPONENTS TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_LABEL_ADMIN TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_USER_ADMIN TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_POLICY_ADMIN TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON SA_AUDIT_ADMIN TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
      EXECUTE IMMEDIATE 'GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO ' ||
                        delim_grantee || ' WITH GRANT OPTION';
    END IF;

    -- RAS related grants
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON XS_ADMIN_CLOUD_UTIL TO '||
                      delim_grantee || ' WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT XS_SESSION_ADMIN TO '||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT XS_NAMESPACE_ADMIN TO '||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT XS_CACHE_ADMIN TO '||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT XS_CONNECT TO '||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT PROVISIONER TO '||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON XS_DIAG TO '||
                      delim_grantee || ' WITH GRANT OPTION';

-- VPD related grants
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_RLS TO '||
                      delim_grantee || ' WITH GRANT OPTION';

-- Data Redaction related grants
    EXECUTE IMMEDIATE 'GRANT EXEMPT REDACTION POLICY TO '||
                      delim_grantee || ' WITH ADMIN OPTION';

-- Bug 22887440: TSDP related grants
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_TSDP_MANAGE TO '||
                      delim_grantee || ' WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_TSDP_PROTECT TO '||
                      delim_grantee || ' WITH GRANT OPTION';

-- Bug 22755546: The target user should be granted AUDIT_ADMIN and
-- AUDIT_VIEWER roles WITH ADMIN. So target user can grant these
-- audit related roles to other required users/roles in the PDB.
    EXECUTE IMMEDIATE 'GRANT AUDIT_ADMIN, AUDIT_VIEWER TO ' ||
                      delim_grantee || ' WITH ADMIN OPTION';
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_FGA TO ' ||
                      delim_grantee || ' WITH GRANT OPTION';
-- Bug 23482255: Grant execute on DBMS_AUDIT_MGMT is needed for AVDF usecase.
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_AUDIT_MGMT TO ' ||
                      delim_grantee || ' WITH GRANT OPTION';

-- Bug 22756785: The target user should be granted CAPTURE_ADMIN role
-- WITH ADMIN for Privilege Analysis.
    EXECUTE IMMEDIATE 'GRANT CAPTURE_ADMIN TO ' ||
                      delim_grantee || ' WITH ADMIN OPTION';
  
  END IF;
END;
/

--------------------------------------------------------------------------
------------      End:Provision Steps for DB Security         ------------
--------------------------------------------------------------------------
