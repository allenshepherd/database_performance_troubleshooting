Rem
Rem $Header: rdbms/admin/catadmprvs.sql /main/12 2015/02/25 16:47:32 yulcho Exp $
Rem
Rem catadmprvs.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catadmprvs.sql - Grant privileges to administrative users
Rem
Rem    DESCRIPTION
Rem      This script grants the required privileges to the following
Rem      administrative users:
Rem      1. SYSBACKUP
Rem      2. SYSDG
Rem      3. SYSKM
Rem
Rem    NOTES
Rem      Must be run connecting as SYS.
Rem
Rem      PLEASE RESPECT THE PRINCIPLE OF LEAST PRIVILEGE:
Rem      If you are modifying this script to grant more privileges, please
Rem      make sure that the additional privileges are absolutely necessary
Rem      for the target administrative user(s) to perform the intended tasks.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catadmprvs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catadmprvs.sql
Rem SQL_PHASE: CATADMPRVS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpend.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yulcho      02/23/15 - grant priv for dbms_dbcomp
Rem    molagapp    01/20/15 - Grant execute to dbms_preplugin_backup
Rem    sanbhara    09/17/14 - Bug 19631647 - adding select privilege on
Rem                           dba_procedures to sysrac.
Rem    sanbhara    08/19/14 - Bug 19467969 - more grants to SYSRAC.
Rem    sanbhara    06/13/14 - Project 46816 - adding support for SYSRAC.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    rmir        06/16/12 - Bug 13734917, SYSKM to access V$CLIENT_SECRETS,
Rem                           V$ENCRYPTION_KEYS
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    akruglik    10/27/11 - SYSBACKUP will be able to see all data from
Rem                           CONTAINER_DATA views and does not need an
Rem                           explicit CONTAINER_DATA predicate
Rem    akruglik    10/03/11 - (13056894): make it possible for sysbackup to see
Rem                           all data in CONTAINER_DATA objects in the Root
Rem    jibyun      05/15/11 - Project 5687: Grant the required privileges to
Rem                           administrative users
Rem    jibyun      03/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

alter session set "_ORACLE_SCRIPT"=true;

-----------------------------------------------------
-- Grant required privileges to administrative users
-----------------------------------------------------

-------------
-- SYSBACKUP
-------------
-- To perfrom backup and recovery tasks.
GRANT alter database                          TO sysbackup;
GRANT alter session                           TO sysbackup;
GRANT alter system                            TO sysbackup;
GRANT alter tablespace                        TO sysbackup;
GRANT audit any                               TO sysbackup;
GRANT create any directory                    TO sysbackup;
GRANT create any table                        TO sysbackup;
GRANT create any cluster                      TO sysbackup;
GRANT drop tablespace                         TO sysbackup;
GRANT resumable                               TO sysbackup;
GRANT unlimited tablespace                    TO sysbackup;
GRANT select any dictionary                   TO sysbackup;
GRANT select any transaction                  TO sysbackup;
GRANT select_catalog_role                     TO sysbackup;

GRANT execute on sys.dbms_rcvman              TO sysbackup;
GRANT execute on sys.dbms_backup_restore      TO sysbackup;
GRANT execute on sys.dbms_preplugin_backup    TO sysbackup;
GRANT execute on sys.dbms_ir                  TO sysbackup;
GRANT execute on sys.dbms_pipe                TO sysbackup;
GRANT execute on sys.dbms_sys_error           TO sysbackup;
GRANT execute on sys.dbms_tts                 TO sysbackup;
GRANT execute on sys.dbms_tdb                 TO sysbackup;
GRANT execute on sys.dbms_plugts              TO sysbackup;
GRANT execute on sys.dbms_plugtsp             TO sysbackup;
GRANT execute on sys.dbms_dbcomp              TO sysbackup;

GRANT delete on sys.apply$_source_schema      TO sysbackup;
GRANT insert on sys.apply$_source_schema      TO sysbackup;
GRANT select on system.logstdby$parameters    TO sysbackup;
GRANT delete on system.logstdby$parameters    TO sysbackup;
GRANT insert on system.logstdby$parameters    TO sysbackup;
GRANT select on appqossys.wlm_classifier_plan TO sysbackup;


---------
-- SYSDG
---------
-- To administer primary and physical standby databases.
GRANT alter database                               TO sysdg;
GRANT alter session                                TO sysdg;
GRANT alter system                                 TO sysdg;
GRANT select any dictionary                        TO sysdg;
GRANT execute on sys.dbms_drs                      TO sysdg;
GRANT execute on sys.dbms_dbcomp                   TO sysdg;
GRANT select  on sys.dba_capture                   TO sysdg;
GRANT select  on sys.dba_logstdby_events           TO sysdg;
GRANT select  on sys.dba_logstdby_log              TO sysdg;
GRANT select  on sys.dba_logstdby_history          TO sysdg;
GRANT select  on appqossys.wlm_classifier_plan     TO sysdg;
GRANT delete  on appqossys.wlm_classifier_plan     TO sysdg;

---------
-- SYSKM
---------
-- To perform encryption key management.
GRANT administer key management               TO syskm WITH ADMIN OPTION;

GRANT select on sys.v_$wallet                 TO syskm;
GRANT select on sys.gv_$wallet                TO syskm;

GRANT select on sys.v_$encryption_wallet      TO syskm;
GRANT select on sys.gv_$encryption_wallet     TO syskm;

GRANT select on sys.v_$encrypted_tablespaces  TO syskm;
GRANT select on sys.gv_$encrypted_tablespaces TO syskm;

GRANT select on sys.v_$database_key_info      TO syskm;
GRANT select on sys.gv_$database_key_info     TO syskm;

GRANT select on sys.v_$encryption_keys        TO syskm;
GRANT select on sys.gv_$encryption_keys       TO syskm;

GRANT select on sys.v_$client_secrets         TO syskm;
GRANT select on sys.gv_$client_secrets        TO syskm;

GRANT select on sys.dba_encrypted_columns     TO syskm;

---------
-- SYSRAC
---------
-- To be used by CRS agent to administer DB instances.
GRANT alter database                       TO sysrac;
GRANT alter session                        TO sysrac;
GRANT alter system                         TO sysrac;

GRANT select on sys.cdb_service$           TO sysrac;
GRANT select on sys.dba_services           TO sysrac;
GRANT select on sys.dba_procedures         TO sysrac;

GRANT execute on sys.dbms_drs              TO sysrac;
GRANT execute on sys.dbms_service          TO sysrac;
GRANT execute on sys.dbms_service_prvt     TO sysrac;
GRANT execute on sys.dbms_session          TO sysrac;
GRANT execute on sys.dbms_ha_alerts_prvt   TO sysrac;

GRANT execute on sys.dbms_server_alert     TO sysrac;
GRANT execute on sys.sys$rlbtyp            TO sysrac;
GRANT read on sys.recent_resource_incarnations$ TO sysrac;
GRANT aq_administrator_role                TO sysrac;

@?/rdbms/admin/sqlsessend.sql
