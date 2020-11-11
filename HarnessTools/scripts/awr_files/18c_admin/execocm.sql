Rem
Rem $Header: emll/admin/scripts/execocm.sql /st_emll_12.1.2.0.1/3 2015/09/09 21:35:13 dkuhn Exp $
Rem
Rem execocm.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execocm.sql - EXECute Oracle Configuration Manager job.
Rem
Rem    DESCRIPTION
Rem      This script submits and runs the database configuration collection
Rem      job as part of database creation.
Rem
Rem    NOTES
Rem      Create directory object for use by the job to create the configuration
Rem      file at.
Rem      This script should be run while connected as "SYS".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkuhn       09/03/15 - XbranchMerge dkuhn_pdbcheck from main
Rem    dkuhn       08/11/15 - XbranchMerge dkuhn_bug-21456791 from main
Rem    dkuhn       06/29/15 - XbranchMerge dkuhn_fixgrant from main
Rem    dkuhn       09/01/15 - Don't execute code if connected to PDB
Rem    dkuhn       08/05/15 - bug 21456791: Add grant
Rem    dkuhn       06/17/15 - Fix grant
Rem    dkuhn       10/23/14 - bug 19840940: Don't run collect job immediately
Rem    dkuhn       09/16/14 - fixtrans
Rem    dkuhn       09/08/14 - add pdb check
Rem    dkuhn       05/14/14 - Fix error checking
Rem    jsutton     10/10/13 - make sure oracle_ocm exists
Rem    jsutton     10/08/13 - add privs
Rem    jsutton     09/24/12 - use enquote_literal for acl name
Rem    jsutton     01/18/12 - grant restricted session
Rem    ckalivar    01/09/12 - bug 11069555: add DBMS_SQL execute permissions to
Rem                           ORACLE_OCM user, incase public user dont have it
Rem    jsutton     09/21/11 - check if in upgrade mode, skip acl stuff if so
Rem    jsutton     09/19/11 - add grants
Rem    jsutton     08/15/11 - check view validity
Rem    jsutton     07/11/11 - Fix for upgrade path
Rem    jsutton     07/06/11 - Ensure ACL set up for access to UTL_INADDR
Rem    jsutton     07/20/09 - Add priv grants for utl_inaddr
Rem    glavash     08/20/08 - grant required prives to user
Rem    dkapoor     07/31/07 - remove stats job
Rem    dkapoor     05/04/07 - stop old job
Rem    dkapoor     01/04/07 - drop job before creating one
Rem    dkapoor     09/20/06 - give priv only if not given to public
Rem    dkapoor     09/13/06 - grant execute on dbms_scheduler
Rem    dkapoor     07/26/06 - do not use define 
Rem    dkapoor     07/21/06 - use create_replace_dir 
Rem    dkapoor     06/06/06 - move directory creation after installing the 
Rem                           packages 
Rem    dkapoor     05/23/06 - Created
Rem

-- If connected to a CDB database, then _oracle_script should be set to TRUE
DECLARE
  l_is_cdb VARCHAR2(5) := 'NO';
BEGIN
  execute immediate 'SELECT UPPER(CDB) FROM V$DATABASE' into l_is_cdb;
  IF l_is_cdb = 'YES' THEN
    execute immediate 'ALTER SESSION SET "_oracle_script" = TRUE';
  END IF;
EXCEPTION
  WHEN OTHERS THEN null;
END;
/

DECLARE
  l_vers v$instance.version%TYPE;
BEGIN
  SELECT LPAD(version,10,'0') INTO l_vers FROM v$instance;
  IF l_vers >= '12.1.0.0.0' THEN
    -- This privilege is necessary in 12c when making calls to 
    -- ORACLE_OCM.MGMT_CONFIG_UTL.create_replace_dir_obj. The create_replace_dir_obj
    -- procedure should only be called from within execocm.sql.
    execute immediate 'GRANT INHERIT PRIVILEGES ON USER SYS TO ORACLE_OCM';
  END IF;
END;
/

DECLARE
  l_vers            v$instance.version%TYPE;
  l_dirobj_priv_cnt NUMBER;
  l_user_cnt        NUMBER;
  l_pkg_cnt         NUMBER;
  l_priv_cnt        NUMBER;
  l_comp_cnt        NUMBER;
  l_acl_count       NUMBER;
  l_acl_priv        NUMBER;
  l_acl_name        VARCHAR2(4000);
  l_stat            VARCHAR2(4000);
  l_is_cdb          VARCHAR2(4) := 'NO';
  l_con_id          NUMBER;
BEGIN
 -- The following code was added to ensure OCM code is not executed while connected
 -- to a PDB database. The associated bug number is 19792374.
 -- This next select returns information required to determine if connected to a PDB or not.
 BEGIN
   execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'', ''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
 EXCEPTION
   WHEN OTHERS THEN
     null;
 END;
 -- The pseudo logic is do nothing if connected to a PDB, all other scenarios run the code.
 -- YES and con_id = 1, means connected to root container.
 -- YES and con_id > 1, means connected to a PDB.
 -- NO or NULL means connected to a normal (non-container/PDB) database.
 IF l_is_cdb = 'YES' and l_con_id > 1  THEN
   -- Inside PDB, do nothing.
   NULL;
 ELSE
   -- If not connected to a PDB, then execute the code.

  BEGIN

    select count(*) into l_user_cnt from dba_users where username = 'ORACLE_OCM';
    IF l_user_cnt <> 0 THEN

      select count(*) into l_priv_cnt from dba_tab_privs where 
        GRANTEE ='ORACLE_OCM' and TABLE_NAME='UTL_FILE' and 
        upper(PRIVILEGE) = 'EXECUTE';
      IF l_priv_cnt = 0 THEN
        -- Grant priv only if its not already given.
        execute immediate 'GRANT EXECUTE ON SYS.UTL_FILE TO ORACLE_OCM';
      END IF;

      select count(*) into l_priv_cnt from dba_tab_privs where 
        GRANTEE ='ORACLE_OCM' and TABLE_NAME='DBMS_SCHEDULER' and 
        upper(PRIVILEGE) = 'EXECUTE';
      IF l_priv_cnt = 0 THEN
        -- Grant priv only if its not given.
        execute immediate 'GRANT EXECUTE ON SYS.DBMS_SCHEDULER TO ORACLE_OCM';
      END IF;

      select count(*) into l_priv_cnt from dba_tab_privs where 
        GRANTEE ='ORACLE_OCM' and TABLE_NAME='UTL_INADDR' and 
        upper(PRIVILEGE) = 'EXECUTE';
      IF l_priv_cnt = 0 THEN
        -- Grant priv only if its not given.
        execute immediate 'GRANT EXECUTE ON SYS.UTL_INADDR TO ORACLE_OCM';
      END IF;

      select count(*) into l_priv_cnt from dba_tab_privs where
         GRANTEE ='ORACLE_OCM' and TABLE_NAME='DBMS_SQL' and
         upper(PRIVILEGE) = 'EXECUTE';
      IF l_priv_cnt = 0 THEN
         -- Grant priv only if its not given to public.
         execute immediate 'GRANT EXECUTE ON SYS.DBMS_SQL TO ORACLE_OCM';
      END IF;

      -- Grant RESTRICTED SESSION 
      execute immediate 'GRANT RESTRICTED SESSION TO ORACLE_OCM';

      -- need to set up ACL if DB version > 11
      select LPAD(version,10,'0') into l_vers from v$instance;
      -- Grant privilege to use UTL_INADDR via ACL if necessary
      IF l_vers >= '11.0.0.0.0' THEN
        -- Skip over ACL/XML DB steps if in UPGRADE mode
        select status into l_stat from dba_registry where comp_id='CATPROC';
        if l_stat <> 'UPGRADING' then
          -- check for XML DB installed
          execute immediate 'select count(*) from dba_registry '||
            'where COMP_NAME = ''Oracle XML Database'' and STATUS = ''VALID'''into l_comp_cnt ;
          IF l_comp_cnt > 0 THEN
            BEGIN
              -- make sure DBA_NETWORK_ACLS view exists (may not in upgrade path)
              execute immediate 'select count(*) from dba_objects '||
                'where object_type=''VIEW'' and object_name=''DBA_NETWORK_ACLS'' and STATUS=''VALID''' 
                into l_comp_cnt;
              IF l_comp_cnt > 0 THEN
                -- check for ACL assigned to localhost
                execute immediate 'select count(*) from dba_network_acls where host=''localhost''' into l_acl_count;
                IF (l_acl_count = 0) THEN
                  -- create ACL and assign to localhost
                  execute immediate 
                    'BEGIN '||
                    '  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(''oracle-sysman-ocm-Resolve-Access.xml'', ' ||
                       '''OCM User Resolve Network Access using UTL_INADDR'', ''ORACLE_OCM'', TRUE, ''resolve'');' ||
                    '  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(''oracle-sysman-ocm-Resolve-Access.xml'', ''localhost'');' ||
                    '  COMMIT;' ||
                    'END;';
                ELSE
                  -- ACL for localhost exists
                  -- check for resolve privilege for OCM user
                  execute immediate
                    'SELECT acl, DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID(aclid, ''ORACLE_OCM'', ''resolve'') ' ||
                    '  FROM dba_network_acls WHERE host = ''localhost'''
                    INTO l_acl_name, l_acl_priv;
                  IF (l_acl_priv IS NULL OR l_acl_priv = 0) THEN
                    -- add resolve privilege
                    execute immediate
                      'BEGIN ' ||
                      '  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(' || DBMS_ASSERT.ENQUOTE_LITERAL(l_acl_name) || ', ' || 
                        '''ORACLE_OCM'', TRUE, ''resolve'');' ||
                      '  COMMIT;' ||
                      'END;';
                  END IF;
                END IF;
              END IF;
            EXCEPTION 
              WHEN OTHERS THEN NULL;
            END;
          END IF;
        END IF;
      END IF;
    END IF;

    SELECT count(*) into l_pkg_cnt from dba_objects
      where owner = 'ORACLE_OCM' and object_type='PACKAGE BODY' and object_name='MGMT_CONFIG_UTL';

    IF l_pkg_cnt <> 0 THEN
      ORACLE_OCM.MGMT_CONFIG_UTL.create_replace_dir_obj;
      select count(*) into l_dirobj_priv_cnt from dba_tab_privs 
        where GRANTEE ='ORACLE_OCM' and TABLE_NAME='ORACLE_OCM_CONFIG_DIR' and upper(PRIVILEGE) = 'READ';
      IF l_dirobj_priv_cnt = 0 THEN
        execute immediate 'GRANT READ ON DIRECTORY ORACLE_OCM_CONFIG_DIR TO ORACLE_OCM';
      END IF;
      select count(*) into l_dirobj_priv_cnt from dba_tab_privs
        where GRANTEE ='ORACLE_OCM' and TABLE_NAME='ORACLE_OCM_CONFIG_DIR' and upper(PRIVILEGE) = 'WRITE';
      IF l_dirobj_priv_cnt = 0 THEN
        execute immediate 'GRANT WRITE ON DIRECTORY ORACLE_OCM_CONFIG_DIR TO ORACLE_OCM';
      END IF;
      -- add grants for 2nd directory
      select count(*) into l_dirobj_priv_cnt from dba_tab_privs 
        where GRANTEE ='ORACLE_OCM' and TABLE_NAME='ORACLE_OCM_CONFIG_DIR2' and upper(PRIVILEGE) = 'READ';
       IF l_dirobj_priv_cnt = 0 THEN
        execute immediate 'GRANT READ ON DIRECTORY ORACLE_OCM_CONFIG_DIR2 TO ORACLE_OCM';
       END IF;
       select count(*) into l_dirobj_priv_cnt from dba_tab_privs
         where GRANTEE ='ORACLE_OCM' and TABLE_NAME='ORACLE_OCM_CONFIG_DIR2' and upper(PRIVILEGE) = 'WRITE';
       IF l_dirobj_priv_cnt = 0 THEN
         execute immediate 'GRANT WRITE ON DIRECTORY ORACLE_OCM_CONFIG_DIR2 TO ORACLE_OCM';
       END IF;

      COMMIT;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20007,SQLERRM);
  END;
 END IF; -- IF connected to a PDB or not.
END;
/

-- remove old dba jobs, if exists
DECLARE
job_num NUMBER;
CURSOR job_cursor is
    SELECT job
    FROM dba_jobs
    WHERE schema_user = 'ORACLE_OCM'
    AND (what like 'ORACLE_OCM.MGMT_CONFIG.%' 
     OR what like 'ORACLE_OCM.MGMT_DB_LL_METRICS.%');
BEGIN
   FOR r in job_cursor LOOP
     sys.DBMS_IJOB.REMOVE(r.job);
     COMMIT;
   END LOOP;
END;
/

DECLARE
  l_user_cnt        NUMBER;
  l_is_cdb          VARCHAR2(4) := 'NO';
  l_con_id          NUMBER;
BEGIN
  -- The following code was added to ensure OCM code is not executed while connected
  -- to a PDB database. The associated bug number is 19792374.
  -- This next select returns information required to determine if connected to a PDB or not.
  BEGIN
    execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'', ''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;
  -- The pseudo logic is do nothing if connected to a PDB, all other scenarios run the code.
  -- YES and con_id = 1, means connected to root container.
  -- YES and con_id > 1, means connected to a PDB.
  -- NO or NULL means connected to a normal (non-container/PDB) database.
  IF l_is_cdb = 'YES' and l_con_id > 1  THEN
    -- Inside PDB, do nothing.
    NULL;
  ELSE
    -- If not connected to a PDB, then execute the code.
    select count(*) into l_user_cnt from dba_users where username = 'ORACLE_OCM';
    IF l_user_cnt <> 0 THEN
      execute immediate 'GRANT MANAGE SCHEDULER TO ORACLE_OCM';
    END IF;
  END IF; -- IF connected to a PDB or not.
END;
/

-- stop the job 
DECLARE
  l_pkg_cnt        NUMBER;
BEGIN
  SELECT count(*) into l_pkg_cnt from dba_objects
    where owner = 'ORACLE_OCM' and object_type='PACKAGE BODY' and object_name='MGMT_CONFIG';
  IF l_pkg_cnt <> 0 THEN
    BEGIN
      -- call to stop the job
      ORACLE_OCM.MGMT_CONFIG.stop_job;   
    EXCEPTION
      WHEN OTHERS THEN
        -- ignore any exception
        null;
    END;
  END IF;
END;
/

-- submit the job and run now
DECLARE
  l_pkg_cnt        NUMBER;
  l_is_cdb         VARCHAR2(4) := 'NO';
  l_con_id         NUMBER;
BEGIN
   -- Check first to see if connected to a PDB.
   BEGIN
     execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'', ''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
   EXCEPTION
     WHEN OTHERS THEN
        null;
   END;
  -- Pseudo logic is do nothing if connected to a PDB, all other scenarios submit the job.
  -- YES and con_id = 1, means connected to root container.
  -- YES and con_id > 1, means connected to a PDB 
  -- NO or NULL means connected to a normal (non-container/PDB) database.
  IF l_is_cdb = 'YES' and l_con_id > 1  THEN
    NULL;
  ELSE
    SELECT count(*) into l_pkg_cnt from dba_objects
      where owner = 'ORACLE_OCM' and object_type='PACKAGE BODY' and object_name='MGMT_CONFIG';
    IF l_pkg_cnt <> 0 THEN
      ORACLE_OCM.MGMT_CONFIG.submit_job;
      -- Do NOT run the collection job immediately when creating data dictionary objects.
      -- ORACLE_OCM.MGMT_CONFIG.run_now;
    END IF;
  END IF; -- IF connected to a PDB or not.
END;
/

DECLARE
  l_user_cnt        NUMBER;
  l_is_cdb          VARCHAR2(4) := 'NO';
  l_con_id          NUMBER;
BEGIN
  -- The following code was added to ensure OCM code is not executed while connected
  -- to a PDB database. The associated bug number is 19792374.
  -- This next select returns information required to determine if connected to a PDB or not.
  BEGIN
    execute immediate 'SELECT UPPER(CDB), SYS_CONTEXT(''USERENV'', ''CON_ID'') FROM V$DATABASE' into l_is_cdb, l_con_id;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;
  -- The pseudo logic is do nothing if connected to a PDB, all other scenarios run the code.
  -- YES and con_id = 1, means connected to root container.
  -- YES and con_id > 1, means connected to a PDB.
  -- NO or NULL means connected to a normal (non-container/PDB) database.
  IF l_is_cdb = 'YES' and l_con_id > 1  THEN
    -- Inside PDB, do nothing.
    NULL;
  ELSE
    -- If not connected to a PDB, then execute the code.
    select count(*) into l_user_cnt from dba_users where username = 'ORACLE_OCM';
    IF l_user_cnt <> 0 THEN
      execute immediate 'REVOKE MANAGE SCHEDULER FROM ORACLE_OCM';
      BEGIN
        execute immediate 'REVOKE RESTRICTED SESSION FROM ORACLE_OCM';
        EXCEPTION
          WHEN OTHERS THEN
          raise_application_error(-20007,SQLERRM);
      END;
    END IF; -- IF l_user_cnt <> 0
  END IF; -- IF connected to a PDB or not.
END;
/

DECLARE
  l_user_cnt NUMBER;
  l_vers     v$instance.version%TYPE;
BEGIN
  SELECT lPAD(version,10,'0') INTO l_vers FROM v$instance;
  IF l_vers >= '12.1.0.0.0' THEN
    SELECT COUNT(*) INTO l_user_cnt FROM dba_users WHERE username = 'ORACLE_OCM';
    IF l_user_cnt <> 0 THEN
      -- Ensure this privilege is revoked, the privilege should only be in place
      -- while executing execocm.sql.
      execute immediate 'REVOKE INHERIT PRIVILEGES ON USER SYS FROM ORACLE_OCM';
    END IF;
  END IF;
END;
/

-- If connected to a CDB database, set _oracle_script to FALSE at end of script
DECLARE
  l_is_cdb VARCHAR2(5) := 'NO';
BEGIN
  execute immediate 'SELECT UPPER(CDB) FROM V$DATABASE' into l_is_cdb;
  IF l_is_cdb = 'YES' THEN
    execute immediate 'ALTER SESSION SET "_oracle_script" = FALSE';
  END IF;
EXCEPTION
  WHEN OTHERS THEN null;
END;
/
