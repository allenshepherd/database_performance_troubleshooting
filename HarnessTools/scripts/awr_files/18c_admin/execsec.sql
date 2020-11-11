Rem
Rem $Header: rdbms/admin/execsec.sql /main/4 2014/02/20 12:45:54 surman Exp $
Rem
Rem execsec.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execsec.sql - secure configuration settings
Rem
Rem    DESCRIPTION
Rem      Secure configuration settings for the database include a reasonable
Rem      default password profile, password complexity checks, audit settings
Rem      (enabled, with admin actions audited), and as many revokes from PUBLIC
Rem      as possible. In the first phase, only the default password profile is
Rem      included.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execsec.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execsec.sql
Rem SQL_PHASE: EXECSEC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    nkgopal     09/09/11 - Bug 12794116: call secconf_file with
Rem                           UNIAUD_CHOICE
Rem    rburns      06/12/06 - add conditional 
Rem    nlewis      06/06/06 - change filename 
Rem    nlewis      06/05/06 - Secure configuration scripts 
Rem    nlewis      06/05/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem  Only run the secconf.sql script for new database creations, not
Rem  for upgrades or any other reruns of catproc.sql.  The version column
Rem  in registry$ is NULL while catproc.sql is running the first time
Rem  on a new database.

VARIABLE secconf_name VARCHAR2(256)                   
COLUMN :secconf_name NEW_VALUE secconf_file NOPRINT

DECLARE
   p_version          varchar2(30);
   p_disable_unified  varchar2(30);
BEGIN
   :secconf_name := '@nothing.sql';
   SELECT version INTO p_version FROM registry$
   WHERE cid='CATPROC';

   IF p_version IS NULL THEN

      BEGIN
        SELECT value into p_disable_unified FROM v$parameter
        WHERE name = '_unified_audit_policy_disabled';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_disable_unified := 'FALSE';
        WHEN OTHERS THEN
          p_disable_unified := 'TRUE';
          RAISE;
      END;

      IF p_disable_unified = 'FALSE' THEN
        :secconf_name := '@secconf.sql RDBMS_UNIAUD';
      ELSE
        :secconf_name := '@secconf.sql RDBMS_11G';
      END IF;
   END IF;
END;
/

SELECT :secconf_name FROM DUAL;
@&secconf_file


@?/rdbms/admin/sqlsessend.sql
