Rem $Header: rdbms/admin/dbmsrmanvpc.sql /st_rdbms_18.0/1 2017/12/21 11:23:51 molagapp Exp $
Rem
Rem dbmsrvpc.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrmanvpc.sql - upgrade to VPD model.
Rem
Rem    DESCRIPTION
Rem      A script to upgrade rman VPC user schemas to a new VPD model.
Rem
Rem    NOTES
Rem      This script has to be executed as SYS user. It detects what RMAN base
Rem      catalog schemas are upgraded to a VPD compatible catalog and upgrades
Rem      the corresponding VPC schemas as well, performing removal of unneeded
Rem      database objects and revoking unnecessary privileges.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    molagapp    12/20/17 - Fix 5 digit version interpretation
Rem    stanaya     01/24/17 - Bug-25237021 : adding sql metadata
Rem    ardrai      12/02/16 - Bug 21849312:ora-1918 create/upgrade catalog
Rem    vbegun      01/30/15 - disabling vpd support out of the box
Rem    vbegun      10/29/13 - no VPC schema case
Rem    vbegun      10/11/13 - Created
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsrmanvpc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsrmanvpc.sql
Rem SQL_PHASE:DBMSRMANVPC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: NONE
Rem END SQL_FILE_METADATA

SET DEFINE "^" TRIMSPOOL ON TAB OFF PAGES 50000 LINES 32767 FEEDBACK OFF
SET VERIFY OFF SERVEROUTPUT ON SIZE UNLIMITED FORMAT TRUNCATED
WHENEVER OSERROR EXIT 1
WHENEVER SQLERROR EXIT 1

SET HEADING OFF
SELECT 'Checking the operating user... '
    || CASE
         WHEN USER = 'SYS'
         THEN 'Passed'
         ELSE 'Failed: the user must be SYS'
       END
  FROM dual;
PROMPT
SET TERMOUT OFF
SELECT CASE WHEN USER <> 'SYS' THEN 1/0 END FROM dual;
  
COLUMN script NEW_VALUE script
SELECT COALESCE(
         REGEXP_SUBSTR(
           TRIM(SYS_CONTEXT('USERENV', 'MODULE'))
         , '^[[:digit:]]{2}@[< ](.*(/|\\))*(.*)$'
         , 1, 1, 'i', 3
         )
       , 'dbmsrmanvpc.sql'
       ) script
  FROM dual
/
SET TERMOUT ON HEADING ON

COLUMN  1 NEW_VALUE  1
COLUMN  2 NEW_VALUE  2
COLUMN  3 NEW_VALUE  3
COLUMN  4 NEW_VALUE  4
COLUMN  5 NEW_VALUE  5
COLUMN  6 NEW_VALUE  6
COLUMN  7 NEW_VALUE  7
COLUMN  8 NEW_VALUE  8
COLUMN  9 NEW_VALUE  9
COLUMN 10 NEW_VALUE 10
SELECT '' AS "1", '' AS "2", '' AS "3", '' AS "4", '' AS "5"
     , '' AS "6", '' AS "7", '' AS "8", '' AS "9", '' AS "10"
  FROM dual
 WHERE ROWNUM = 0
/

VAR list_of_owners1 VARCHAR2(4000)
VAR list_of_owners2 VARCHAR2(4000)
VAR scan            NUMBER
VAR vpd             NUMBER
VAR novpd           NUMBER
VAR e               NUMBER

DECLARE
  TYPE argv_t IS TABLE OF user_users.username%TYPE;
  l_argv                           CONSTANT argv_t := argv_t(
    '^^1', '^^2', '^^3', '^^4', '^^5'
  , '^^6', '^^7', '^^8', '^^9', '^^10'
  );
  l_dummy                          VARCHAR2(1);
  l_scan                           BOOLEAN := FALSE;
  l_vpd                            BOOLEAN := FALSE;
  l_novpd                          BOOLEAN := FALSE;
  l_all                            BOOLEAN := FALSE;
  l_owners                         argv_t := argv_t();
  l_user_name                      user_users.username%TYPE;

  PROCEDURE p (
    l_message                      IN VARCHAR2
  , l_crlf                         IN BOOLEAN DEFAULT TRUE
  )
  IS
  BEGIN
    IF (l_crlf)
    THEN
      dbms_output.put_line(l_message);
    ELSE
      dbms_output.put(l_message);
    END IF;
  END p; 

  PROCEDURE el
  IS
  BEGIN
    dbms_output.put_line('');
  END el;

  PROCEDURE usage
  IS
  BEGIN
    p(q'{Usage: ^^script -vpd <base catalog schema name>
       ^^script -novpd <base catalog schema name>
       ^^script -scan [<base catalog schema name>]
       ^^script <base catalog schema name> [...]
       ^^script -all

This script performs an upgrade of RMAN base catalog and corresponding
VPC users schemas to a new VPD model.

-vpd command grants required privileges to support VPD protected catalog.
Connect to RMAN base catalog and perform UPGRADE CATALOG after the VPD
privileges are granted.

-novpd command removes VPD support: cleans up the base catalog schema,
revokes grants and removes database objects to disable VPD facilities.
This is only possible when there are no existing VPC users registered
in that catalog.

-scan command performs a scan of RMAN base catalog owner schemas and
reports on granted roles and VPC users status.

After UPGRADE CATALOG is performed for the base catalog schemas a cleanup
of VPC schemas has to take place for that the RMAN base catalog schema
names have to be supplied as command line parameters.  Up to 10 schema
names can be supplied per script execution.  When -all is specified the
script attempts to detect the RMAN base catalog schemas automatically
and perform the upgrade.
}');
  END usage;

BEGIN
  :vpd := 0;
  :novpd := 0;
  :scan := 0;
  FOR i IN 1..l_argv.COUNT
  LOOP
    IF (l_argv(i) IS NOT NULL)
    THEN
      l_owners.EXTEND;
      l_owners(l_owners.COUNT) := UPPER(l_argv(i));
      IF (NOT (l_all OR l_vpd OR l_novpd OR l_scan)
          AND l_owners.COUNT = 1
      )
      THEN
        IF (l_owners(l_owners.COUNT) = '-ALL')
        THEN
          l_all := TRUE;
          l_owners(l_owners.COUNT) := 'owner';
          CONTINUE;
        END IF;
        IF (l_owners(l_owners.COUNT) = '-VPD')
        THEN
          l_vpd := TRUE; :vpd := 1;
          l_owners.DELETE;
          CONTINUE;
        END IF;
        IF (l_owners(l_owners.COUNT) = '-NOVPD')
        THEN
          l_novpd := TRUE; :novpd := 1;
          l_owners.DELETE;
          CONTINUE;
        END IF;
        IF (l_owners(l_owners.COUNT) = '-SCAN')
        THEN
          l_scan := TRUE; :scan := 1;
          l_owners(l_owners.COUNT) := 'owner';
          CONTINUE;
        END IF;
      END IF;
    END IF;
  END LOOP;

  IF (   (l_owners.COUNT = 0 OR l_all OR l_vpd OR l_novpd)
     AND l_owners.COUNT <> 1
  )
  THEN
    usage(); :e := 0; RETURN;
  END IF;

  IF (l_vpd)
  THEN
    p( 'Granting VPD privileges to the owner of the base catalog schema '
    || l_owners(l_owners.COUNT)
    );
    :list_of_owners1 := '''' || l_owners(l_owners.COUNT) || '''';
    el();
  ELSIF (l_novpd)
  THEN
    p( 'Removing VPD support in the base catalog schema '
    || l_owners(l_owners.COUNT)
    );
    :list_of_owners1 := '''' || l_owners(l_owners.COUNT) || '''';
    el();
  ELSIF (l_scan)
  THEN
    IF (l_owners.COUNT > 2)
    THEN
      usage(); :e := 0; RETURN;
    END IF;
    IF (l_owners(l_owners.COUNT) = 'owner')
    THEN
      :list_of_owners1 := 'owner';
    ELSE
      :list_of_owners1 := '''' || l_owners(l_owners.COUNT) || '''';
      BEGIN
        l_user_name := l_owners(l_owners.COUNT);
        SELECT 'x'
          INTO l_dummy
          FROM dba_users
         WHERE username = l_user_name;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN p( 'Base catalog owner schema ' || l_owners(l_owners.COUNT)
             || ' does not exist!'
             );
             :e := 1; RETURN;
      END;
    END IF;
    p( 'RMAN base catalog owners schemas report as of '
    || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
    );
    el();
    p(RPAD('=', 80, '='));
    p(q'{Acronyms used:
VPC -- Virtual Private Catalog users
VPD -- RECOVERY_CATALOG_OWNER_VPD role
RCO -- RECOVERY_CATALOG_OWNER role
RCU -- RECOVERY_CATALOG_USER role
}'
    );
  ELSE
    IF (l_owners(l_owners.COUNT) <> 'owner')
    THEN
      FOR i IN 1..l_owners.COUNT
      LOOP
        :list_of_owners1 := :list_of_owners1
                         || ''''
                         || l_owners(i)
                         || ''''
                         || CASE
                              WHEN i <> l_owners.COUNT
                              THEN ', '
                            END;
        :list_of_owners2 := :list_of_owners2
                         || l_owners(i)
                         || CASE
                              WHEN i <> l_owners.COUNT
                              THEN ', '
                            END;
      END LOOP;
      p('The VPC user schemas of the following catalogs: ', FALSE);
      p(:list_of_owners2, FALSE);
      p(' are going to be upgraded to a new VPD model');
      el();
    ELSE
      :list_of_owners1 := 'owner';
    END IF;
  END IF;
END;
/
SET TERMOUT OFF
COLUMN list_of_owners1 NEW_VALUE list_of_owners1
COLUMN list_of_owners2 NEW_VALUE list_of_owners2
SELECT :list_of_owners1 list_of_owners1
     , :list_of_owners2 list_of_owners2
     , COALESCE(:list_of_owners1, TO_CHAR(1 / 0))
     , 1 / :e
  FROM dual;
SET TERMOUT ON

DECLARE
  TYPE users_t IS TABLE OF user_users.username%TYPE;
  l_debug                          BOOLEAN := FALSE;

  lc_users                         SYS_REFCURSOR;
  l_user_name                      user_users.username%TYPE;

  SUBTYPE short_string_t IS VARCHAR2(32);
  gc_vpc_version                   CONSTANT VARCHAR2(15) := '12.01.00.01.00';
  l_version                        VARCHAR2(15);
  TYPE h_t IS TABLE OF short_string_t INDEX BY user_users.username%TYPE;
  l_extrainfo                      h_t;

  l_dummy                          VARCHAR2(1);
  l_ddl_error                      BOOLEAN := FALSE;
  l_upgraded_vpc                   users_t := users_t();
  l_successful_vpc                 users_t := users_t();
  l_problematic_vpc                users_t;
  l_catalogs                       users_t := users_t();
  l_problematic_cat                users_t := users_t();

  -- a given base catalog had associated VPC users
  l_had_vpc_users                  BOOLEAN;
  -- a status of the base catalog owner VPD setup
  l_had_vpd_setup                  BOOLEAN;

  PROCEDURE p (
    l_message                      IN VARCHAR2
  , l_crlf                         IN BOOLEAN DEFAULT TRUE
  )
  IS
  BEGIN
    IF (l_crlf)
    THEN
      dbms_output.put_line(l_message);
    ELSE
      dbms_output.put(l_message);
    END IF;
  END p; 

  PROCEDURE el
  IS
  BEGIN
    dbms_output.put_line('');
  END el;

  PROCEDURE t
  IS
  BEGIN
    p(RPAD('-', 40, '-'));
  END t;

  PROCEDURE tt
  IS
  BEGIN
    p(RPAD('=', 40, '='));
  END tt;

  PROCEDURE t2csv (
    i_title                        IN VARCHAR2 DEFAULT NULL
  , i_table                        IN users_t
  , i_crlf                         IN BOOLEAN DEFAULT FALSE
    -- extra qualifier
  , i_eq                           IN BOOLEAN DEFAULT FALSE
  )
  IS
  BEGIN
    IF (i_title IS NOT NULL AND i_table.COUNT > 0)
    THEN
      p(i_title, i_crlf);
    END IF;
    FOR i IN 1..i_table.COUNT
    LOOP
      p(i_table(i) || CASE
                        WHEN i_eq AND l_extrainfo.EXISTS(i_table(i))
                        THEN ' [' || l_extrainfo(i_table(i)) || ']'
                      END
                   || CASE
                        WHEN i <> i_table.COUNT
                        THEN ', '
                      END
      , FALSE
      );
    END LOOP;
    p('', i_title IS NOT NULL AND i_table.COUNT > 0);
  END t2csv;

  PROCEDURE do_ddl (
    i_stmt                         IN VARCHAR2
  , i_warning                      IN BOOLEAN DEFAULT FALSE
  , i_show_errors                  IN BOOLEAN DEFAULT TRUE
  )
  IS
    e_not_granted                  EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_not_granted, -1951);
  BEGIN
    IF (l_debug)
    THEN
      p(i_stmt);
    END IF;
    BEGIN
      EXECUTE IMMEDIATE i_stmt;
    EXCEPTION
      WHEN e_not_granted
      THEN NULL;
      WHEN OTHERS
      THEN IF (i_show_errors)
           THEN
              p( CASE WHEN i_warning THEN 'Warning: ' ELSE 'Error: ' END
              || 'ORA' || SQLCODE || ': ' || i_stmt
              );
           END IF;
           l_ddl_error := TRUE;
    END;
  END do_ddl;

  PROCEDURE drop_synonym (
    i_synonym_name                 IN user_synonyms.synonym_name%TYPE
  , i_user_name                    IN user_users.username%TYPE
                                      DEFAULT l_user_name
  )
  IS
  BEGIN
    do_ddl('DROP SYNONYM ' || i_user_name || '.' || i_synonym_name);
  END drop_synonym;

  PROCEDURE drop_view (
    i_view_name                    IN user_views.view_name%TYPE
  , i_user_name                    IN user_users.username%TYPE
                                      DEFAULT l_user_name
  )
  IS
  BEGIN
    do_ddl('DROP VIEW "' || i_user_name || '"."' || i_view_name || '"');
  END drop_view;

  PROCEDURE revoke_priv (
    i_priv_name                    IN user_role_privs.granted_role%TYPE
  , i_user_name                    IN user_users.username%TYPE
                                      DEFAULT l_user_name
  , i_report_errors                IN BOOLEAN DEFAULT FALSE
  )
  IS
    l_prev_ddl_error               BOOLEAN;
  BEGIN
    IF (i_report_errors)
    THEN
      do_ddl('REVOKE ' || i_priv_name || ' FROM "' || i_user_name || '"');
    ELSE
      l_prev_ddl_error := l_ddl_error;
      do_ddl(
        i_stmt        => 'REVOKE ' || i_priv_name
                      || ' FROM "' || i_user_name || '"'
      , i_show_errors => FALSE
      );
      l_ddl_error := l_prev_ddl_error;
    END IF;
  END revoke_priv;

  PROCEDURE grant_priv (
    i_priv_name                    IN VARCHAR2
  , i_user_name                    IN user_users.username%TYPE
                                      DEFAULT l_user_name
  )
  IS
  BEGIN
    do_ddl('GRANT ' || i_priv_name || ' TO "' || i_user_name || '"');
  END grant_priv;

  PROCEDURE a (
    i_table                        IN OUT NOCOPY users_t
  , i_user_name                    IN user_users.username%TYPE
  , i_condition                    IN BOOLEAN DEFAULT TRUE
  )
  IS
  BEGIN
    IF (i_condition)
    THEN
      i_table.EXTEND;
      i_table(i_table.COUNT) := i_user_name;
    END IF;
  END a;

  FUNCTION has_vpc_users (
    i_user_name                    IN user_users.username%TYPE
  )
  RETURN BOOLEAN
  IS
    l_catowner                     VARCHAR2(130);
  BEGIN
    l_catowner := dbms_assert.enquote_name(i_user_name);
    EXECUTE IMMEDIATE
      REGEXP_REPLACE (
        'SELECT ''x'' FROM %o.vpc_users WHERE ROWNUM = 1 HAVING COUNT(*) = 1'
      , '%o'
      , l_catowner
      )
    INTO l_dummy;
    RETURN l_dummy IS NOT NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RETURN FALSE;
  END has_vpc_users;

BEGIN
  IF (:scan = 0)
  THEN
    BEGIN
      SELECT 'x'
        INTO l_dummy
        FROM dba_roles
       WHERE role IN (
               'RECOVERY_CATALOG_OWNER'
             , 'RECOVERY_CATALOG_OWNER_VPD'
             , 'RECOVERY_CATALOG_USER'
             )
      HAVING COUNT(*) = 3;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN NULL;
    END;

    IF (l_dummy IS NULL)
    THEN
      p(q'{Required Recovery Manager roles do not exist!
Execute '?/rdbms/admin/dbmsrmansys.sql' after connecting to 
a catalog database as SYS to create required roles.
}');
      :e := 0; RETURN;
    END IF;
  END IF;

  -- -scan
  IF (:scan = 1)
  THEN
    :e := 0;
    RETURN;
  END IF;

  FOR c IN (
    SELECT owner
      FROM dba_tables t
     WHERE table_name = 'VPC_USERS'
       AND owner IN (^^list_of_owners1)
       AND (
               :vpd = 1
            OR :novpd = 1
            OR 2 = (
                 SELECT COUNT(*)
                   FROM dba_tab_columns c
                  WHERE c.owner = t.owner
                    AND c.table_name = t.table_name
                    AND c.column_name IN ('FILTER_USER', 'FILTER_UID')
               )
           AND 2 = (
                 SELECT COUNT(*)
                   FROM dba_objects o
                  WHERE o.owner = t.owner
                    AND o.object_name = 'DBMS_RCVCAT'
                    AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
               )
           AND 2 = (
                 SELECT COUNT(*)
                   FROM dba_objects o
                  WHERE o.owner = t.owner
                    AND o.object_name = 'DBMS_RCVMAN'
                    AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
               )
           )
     ORDER BY
           owner
  )
  LOOP
    -- -vpd
    IF (:vpd = 1)
    THEN
      a(l_catalogs, c.owner);
      revoke_priv('recovery_catalog_owner', c.owner, FALSE);
      grant_priv('recovery_catalog_owner_vpd', c.owner);
      CONTINUE;
    END IF;

    -- -novpd
    IF (:novpd = 1)
    THEN
      a(l_catalogs, c.owner);
      IF (has_vpc_users(c.owner))
      THEN
        a(l_problematic_cat, c.owner);
        l_extrainfo(c.owner) := 'Existing VPC users';
      ELSE
        p('Revoking privileges from RECOVERY_CATALOG_USER role...');
        FOR t IN (
           SELECT DISTINCT table_name
             FROM dba_tab_privs
            WHERE grantee = 'RECOVERY_CATALOG_USER'
              AND owner = c.owner
            ORDER BY
                  table_name
        )
        LOOP
          revoke_priv(
             'ALL ON '
          || dbms_assert.enquote_name(c.owner, FALSE)
          || '.'
          || dbms_assert.enquote_name(t.table_name, FALSE)
          , 'RECOVERY_CATALOG_USER'
          , FALSE
          );
          IF (l_ddl_error)
          THEN
            a(l_problematic_cat, c.owner);
            EXIT;
          END IF;
        END LOOP;
        CONTINUE WHEN l_ddl_error;
        p('Dropping on-logon trigger...');
        FOR t IN (
          SELECT trigger_name
            FROM dba_triggers
           WHERE owner = c.owner
             AND trigger_name = 'VPC_CONTEXT_TRG'
        )
        LOOP
          do_ddl (
            i_stmt => 'DROP TRIGGER '
            || dbms_assert.enquote_name(c.owner, FALSE)
            || '.'
            || t.trigger_name
          , i_show_errors => TRUE
          );
          a(l_problematic_cat, c.owner, l_ddl_error);
        END LOOP;
        CONTINUE WHEN l_ddl_error;
        p('Dropping VPD policies...');
        FOR p IN (
          SELECT object_name
               , policy_name
            FROM dba_policies
           WHERE object_owner = c.owner
           ORDER BY
                 object_name
        )
        LOOP
          dbms_rls.drop_policy (
            object_schema => dbms_assert.enquote_name(c.owner, FALSE)
          , object_name   => p.object_name
          , policy_name   => p.policy_name
          );
        END LOOP;
        p('Granting/revoking roles from/to ' || c.owner || '...');
        grant_priv('recovery_catalog_owner', c.owner);
        revoke_priv('recovery_catalog_owner_vpd', c.owner, TRUE);
        a(l_problematic_cat, c.owner, l_ddl_error);
        CONTINUE WHEN l_ddl_error;
      END IF;
      CONTINUE;
    END IF;

    -- -all or supplied base catalog schemas
    a(l_catalogs, c.owner);
    BEGIN
      EXECUTE IMMEDIATE
        'SELECT version FROM ' || dbms_assert.enquote_name(c.owner, FALSE)
         || '.rcver'
      INTO l_version;

      -- Append .00 for older version of catalog schema that track only
      -- first 4 digits.
      IF (LENGTH(l_version) = 12) THEN
         l_version := '.00';
      END IF;

      a(l_problematic_cat, c.owner, (l_version < gc_vpc_version));
      l_extrainfo(c.owner) := l_version;
      CONTINUE WHEN l_version < gc_vpc_version;
    EXCEPTION
      WHEN OTHERS
      THEN a(l_problematic_cat, c.owner);
           CONTINUE;
    END;
    l_had_vpc_users := FALSE;
    OPEN lc_users
     FOR 'SELECT filter_user FROM '
      || dbms_assert.enquote_name(c.owner, FALSE)
      || '.vpc_users ORDER BY filter_user';
    LOOP
      FETCH lc_users INTO l_user_name;
      EXIT WHEN lc_users%NOTFOUND;
      l_had_vpc_users := TRUE;
      l_ddl_error := FALSE;

      tt();
      p(  'Upgrading the VPC user schemas registered in the base catalog of '
       || c.owner
      );
      t();
      p('Upgrading: ' || l_user_name);
      a(l_upgraded_vpc, l_user_name);

      p('Synonyms...');
      FOR s IN (
        SELECT synonym_name
          FROM dba_synonyms
         WHERE table_owner = c.owner
           AND owner = l_user_name
           AND synonym_name NOT IN ('DBMS_RCVCAT', 'DBMS_RCVMAN')
         ORDER BY
               synonym_name
      )
      LOOP
        drop_synonym(s.synonym_name, l_user_name);
      END LOOP;

      p('Views...');
      FOR v IN (
        SELECT view_name
          FROM dba_views
         WHERE owner = l_user_name
           AND (  view_name LIKE 'RC~_%' ESCAPE '~'
               OR view_name LIKE 'RCI~_%' ESCAPE '~'
               OR view_name LIKE '~_RS~_RC~_%' ESCAPE '~'
               OR view_name LIKE '~_RS~_RCI~_%' ESCAPE '~'
               )
         ORDER BY
               view_name
      )
      LOOP
        drop_view(v.view_name, l_user_name);
      END LOOP;

      p('Cleanup of privileges...');
      FOR p IN (
        SELECT privilege name
          FROM dba_sys_privs
         WHERE grantee = l_user_name
         UNION
        SELECT granted_role
          FROM dba_role_privs
         WHERE grantee = l_user_name
      )
      LOOP
        revoke_priv(p.name, l_user_name);
      END LOOP;

      p('Grant of privileges...');
      grant_priv('create session, recovery_catalog_user', l_user_name);

      a(l_successful_vpc, l_user_name, (NOT l_ddl_error));
    END LOOP;
    CLOSE lc_users;

    t();
    p('Removing old VPC views in the base catalog of ' || c.owner || '...');
    l_ddl_error := FALSE;
    FOR v IN (
      SELECT view_name
        FROM dba_views
       WHERE view_name LIKE '%~_V' ESCAPE '~'
         AND owner = c.owner
    )
    LOOP
      drop_view(v.view_name, c.owner);
    END LOOP;

    IF (NOT l_ddl_error)
    THEN
      -- if a base catalog owner has a VPD trigger setup it means
      -- the VPD catalog upgrade already took place and we have to
      -- reconcile the privileges
      SELECT MIN('x')
        INTO l_dummy
        FROM dba_triggers
       WHERE owner = c.owner
         AND trigger_name = 'VPC_CONTEXT_TRG';
    
      l_had_vpd_setup := l_dummy IS NOT NULL;
    
      IF (l_had_vpc_users OR l_had_vpd_setup)
      THEN
        -- if a base catalog owner had VPC users registered or
        -- already had a VPD setup we reconcile the privileges
        revoke_priv('recovery_catalog_owner', c.owner);
        grant_priv('recovery_catalog_owner_vpd', c.owner);
      END IF;
    END IF;

    a(l_problematic_cat, c.owner, l_ddl_error);
  END LOOP;

  l_problematic_vpc := l_upgraded_vpc MULTISET EXCEPT l_successful_vpc;

  tt();
  IF (l_catalogs.COUNT > 0)
  THEN
    IF (:vpd = 1)
    THEN
      p('VPD SETUP STATUS:');
      IF (l_problematic_cat.COUNT > 0)
      THEN
        :e := 1;
        t2csv(
          i_title => 'Unable to grant required privileges to the base catalog '
                  || 'owner for VPD upgrade '
        , i_table => l_problematic_cat
        , i_eq    => TRUE
        );
      ELSE
        :e := 0;
        p('VPD privileges granted successfully!');
        p('Connect to RMAN base catalog and perform UPGRADE CATALOG.');
      END IF;
    ELSIF (:novpd = 1)
    THEN
      p('VPD REMOVAL STATUS:');
      IF (l_problematic_cat.COUNT > 0)
      THEN
        :e := 1;
        t2csv(
          i_title => 'Unable to remove VPD support from to the base catalog '
        , i_table => l_problematic_cat
        , i_eq    => TRUE
        );
      ELSE
        :e := 0;
        p('VPD support is removed successfully!');
      END IF;
    ELSE
      p('UPGRADE STATUS:');
      t2csv(
        i_title => 'The VPC user schemas of these catalogs: '
      , i_table => l_catalogs
      );
      IF (   l_problematic_vpc.COUNT = 0
         AND l_successful_vpc.COUNT >= 0
         AND l_problematic_cat.COUNT = 0
         )
      THEN
        :e := 0;
        p('have been successfully upgraded to the new VPD model!');
      ELSE
        :e := 1;
        p('have NOT been successfully upgraded to the new VPD model!!!');
        t2csv(
          i_title => 'The problematic VPC user schemas: '
        , i_table => l_problematic_vpc
        );
        t2csv(
          i_title => 'The problematic or ineligible for the VPD upgrade '
                  || 'base catalog schemas are: '
        , i_table => l_problematic_cat
        , i_eq    => TRUE
        );
      END IF;
    END IF;
  ELSE
    :e := 1;
    p('No eligible RMAN catalogs have been found!');
  END IF;
END;
/

DEFINE y   = YES
DEFINE n   = NO
DEFINE v   = "|| dbms_assert.enquote_name(owner) || '.vpc_users'"
DEFINE vpd = RECOVERY_CATALOG_OWNER_VPD
DEFINE rco = RECOVERY_CATALOG_OWNER
DEFINE rcu = RECOVERY_CATALOG_USER
COLUMN owner                      FORMAT A20   -
  HEADING "RMAN Base Catalog|schema owner" WRAP ON
COLUMN vpcuser                    FORMAT A20   -
  HEADING "VPC user" WRAP ON
COLUMN recovery_catalog_owner_vpd FORMAT A4    -
  HEADING "VPD|role" JUSTIFY CENTER
COLUMN recovery_catalog_owner     FORMAT A4    -
  HEADING "RCO|role" JUSTIFY CENTER
COLUMN has_vpc_users              FORMAT 99999 -
  HEADING "VPC|count" JUSTIFY CENTER
COLUMN non_existing_vpc_users     FORMAT 99999 -
  HEADING "VPC dropped|from DB" JUSTIFY CENTER
SET HEADSEP "~"
COLUMN s FORMAT A1 HEADING "|~|"
SET HEADSEP "|"
COLUMN vpc_users_with_vpd         FORMAT 99999 -
  HEADING "VPC with|VPD role" JUSTIFY CENTER
COLUMN vpc_users_with_rco         FORMAT 99999 -
  HEADING "VPC with|RCO role" JUSTIFY CENTER
COLUMN vpc_users_with_rcu         FORMAT 99999 -
  HEADING "VPC with|RCU role" JUSTIFY CENTER
WITH bc AS
(
SELECT owner
     , (
       SELECT COUNT(*)
         FROM dba_tab_columns c
        WHERE c.owner = t.owner
          AND c.table_name = t.table_name
          AND c.column_name IN ('FILTER_UID')
       ) has_filter_uid
     , (
       SELECT NVL2(MIN(grantee), '^^y', '^^n')
         FROM dba_role_privs
        WHERE grantee = t.owner
          AND granted_role = '^^vpd'
       ) recovery_catalog_owner_vpd
     , (
       SELECT NVL2(MIN(grantee), '^^y', '^^n')
         FROM dba_role_privs
        WHERE grantee = t.owner
          AND granted_role = '^^rco'
       ) recovery_catalog_owner
  FROM dba_tables t 
 WHERE :scan = 1
   AND owner IN (^^list_of_owners1)
   AND table_name = 'VPC_USERS'
   AND 1 = (
         SELECT COUNT(*)
           FROM dba_tab_columns c
          WHERE c.owner = t.owner
            AND c.table_name = t.table_name
            AND c.column_name IN ('FILTER_USER')
       ) 
   AND 2 = (
         SELECT COUNT(*)
           FROM dba_objects o
          WHERE o.owner = t.owner
            AND o.object_name = 'DBMS_RCVCAT'
            AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
       ) 
   AND 2 = (
         SELECT COUNT(*)
           FROM dba_objects o
          WHERE o.owner = t.owner
            AND o.object_name = 'DBMS_RCVMAN'
            AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
       )
)
SELECT owner
     , recovery_catalog_owner_vpd
     , recovery_catalog_owner
     , (
         dbms_xmlgen.getxmltype (
           'SELECT COUNT(*) c FROM ' ^^v
         )
       ).extract('//C/text()').getnumberval() has_vpc_users
     , CASE
         WHEN has_filter_uid = 0
         THEN (
                dbms_xmlgen.getxmltype (
                   'SELECT COUNT(*) c FROM ' ^^v
                || ' WHERE NOT EXISTS (SELECT * FROM dba_users WHERE'
                || ' username = filter_user)'
                )
              ).extract('//C/text()').getnumberval()
         ELSE (
                dbms_xmlgen.getxmltype (
                   'SELECT COUNT(*) c FROM ' ^^v
                || ' WHERE NOT EXISTS (SELECT * FROM dba_users WHERE'
                || ' username = filter_user AND user_id = filter_uid)'
                )
              ).extract('//C/text()').getnumberval()
       END non_existing_vpc_users
     , '|' s
     , (
         dbms_xmlgen.getxmltype (
            'SELECT COUNT(*) c FROM dba_role_privs,' ^^v
         || ' WHERE grantee = filter_user'
         || '   AND granted_role = ''^^vpd'''
         )
       ).extract('//C/text()').getnumberval() vpc_users_with_vpd
     , (
         dbms_xmlgen.getxmltype (
            'SELECT COUNT(*) c FROM dba_role_privs,' ^^v
         || ' WHERE grantee = filter_user'
         || '   AND granted_role = ''^^rco'''
         )
       ).extract('//C/text()').getnumberval() vpc_users_with_rco
     , (
         dbms_xmlgen.getxmltype (
            'SELECT COUNT(*) c FROM dba_role_privs,' ^^v
         || ' WHERE grantee = filter_user'
         || '   AND granted_role = ''^rcu'''
         )
       ).extract('//C/text()').getnumberval() vpc_users_with_rcu
  FROM bc
 ORDER BY
       owner
/
COLUMN vpcuser                   FORMAT A20 -
  HEADING "VPC user" WRAP ON
COLUMN vpc_user_with_vpd         FORMAT A4  -
  HEADING "VPD|role" JUSTIFY CENTER
COLUMN vpc_user_with_rco         FORMAT A4  -
  HEADING "RCO|role" JUSTIFY CENTER
COLUMN vpc_user_with_rcu         FORMAT A4  -
  HEADING "RCU|role" JUSTIFY CENTER
COLUMN non_existing_vpc_user     FORMAT A7  -
  HEADING "Dropped" JUSTIFY CENTER
BREAK ON OWNER SKIP 1
WITH bc AS
(
SELECT owner
  FROM dba_tables t 
 WHERE :scan = 1
   AND owner IN (^^list_of_owners1)
   AND table_name = 'VPC_USERS'
   AND 1 = (
         SELECT COUNT(*)
           FROM dba_tab_columns c
          WHERE c.owner = t.owner
            AND c.table_name = t.table_name
            AND c.column_name IN ('FILTER_USER')
       ) 
   AND 2 = (
         SELECT COUNT(*)
           FROM dba_objects o
          WHERE o.owner = t.owner
            AND o.object_name = 'DBMS_RCVCAT'
            AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
       ) 
   AND 2 = (
         SELECT COUNT(*)
           FROM dba_objects o
          WHERE o.owner = t.owner
            AND o.object_name = 'DBMS_RCVMAN'
            AND o.object_type IN ('PACKAGE', 'PACKAGE BODY')
       )
)
SELECT owner
     , u vpcuser
     , CASE WHEN v =  0 THEN '^^n' ELSE '^^y' END vpc_user_with_vpd
     , CASE WHEN co = 0 THEN '^^n' ELSE '^^y' END vpc_user_with_rco
     , CASE WHEN cu = 0 THEN '^^n' ELSE '^^y' END vpc_user_with_rcu
     , CASE WHEN e =  0 THEN '^^n' ELSE '^^y' END non_existing_vpc_user
  FROM (
       SELECT owner
            , dbms_xmlgen.getxmltype('
SELECT filter_user u
     , SUM(CASE WHEN granted_role = ''^^vpd'' THEN 1 ELSE 0 END) v
     , SUM(CASE WHEN granted_role = ''^^rco'' THEN 1 ELSE 0 END) co
     , SUM(CASE WHEN granted_role = ''^^rcu''  THEN 1 ELSE 0 END) cu
     , MAX(NVL2(username, 0, 1)) e
  FROM ' ^^v || '
  LEFT OUTER JOIN
       (
       SELECT grantee
            , granted_role
         FROM dba_role_privs
        WHERE granted_role IN (''^^vpd'', ''^^rco'', ''^rcu'')
       ) dba_role_privs
    ON (grantee = filter_user)
  LEFT OUTER JOIN
       dba_users
    ON (filter_user = username)
 GROUP BY
       filter_user
') x FROM bc
     ) x
     , XMLTABLE(
         '/ROWSET/ROW' PASSING x.x
         COLUMNS
           u  VARCHAR2(128) PATH 'U'
         , v  NUMBER PATH 'V'
         , co NUMBER PATH 'CO'
         , cu NUMBER PATH 'CU'
         , e  NUMBER PATH 'E'
       )
 ORDER BY
       owner
     , vpcuser
/
PROMPT
EXIT :e
