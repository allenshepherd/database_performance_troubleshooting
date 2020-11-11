Rem
Rem $Header: rdbms/admin/dvregrant.sql /main/3 2017/05/31 14:01:17 youyang Exp $
Rem
Rem dvregrant.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvregrant.sql - this script is to grant privileges locally
Rem
Rem    DESCRIPTION
Rem      In CDB environment, when root configures DV, a list of privs
Rem      are revoked COMMONLY from common roles as a hardening step. 
Rem      If a PDB depends on any of these privileges, it will need to 
Rem      grant the privilege LOCALLY to the common role. 
Rem
Rem      As a helper, this script grants all the revoked privileges 
Rem      locally on a PDB or root.
Rem
Rem    NOTES
Rem      This script needs to be run on the intended container as SYSDBA
Rem      or DBA user
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     05/22/17 - bug26001318:modify sql meta data
Rem    kaizhuan    04/09/14 - Bug 18542709: Grant back privileges to DBA role
Rem                           without ADMIN OPTION.
Rem    jheng       12/09/13 - Bug 17752539: script to re-grant DV hardening
Rem                           privileges
Rem    jheng       12/09/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dvregrant.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dvregrant.sql
Rem    SQL_PHASE: UTILITY 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA

grant BECOME USER to DBA;
grant SELECT ANY TRANSACTION to DBA;
grant CREATE ANY JOB to DBA;
grant CREATE EXTERNAL JOB to DBA;
grant EXECUTE ANY PROGRAM to DBA;
grant EXECUTE ANY CLASS to DBA;
grant MANAGE SCHEDULER to DBA;
grant DEQUEUE ANY QUEUE to DBA;
grant ENQUEUE ANY QUEUE to DBA;
grant MANAGE ANY QUEUE to DBA;

grant BECOME USER to IMP_FULL_DATABASE;
grant MANAGE ANY QUEUE to IMP_FULL_DATABASE;

grant CREATE ANY JOB to SCHEDULER_ADMIN with ADMIN OPTION;
grant CREATE EXTERNAL JOB to SCHEDULER_ADMIN with ADMIN OPTION;
grant EXECUTE ANY PROGRAM to SCHEDULER_ADMIN with ADMIN OPTION;
grant EXECUTE ANY CLASS to SCHEDULER_ADMIN with ADMIN OPTION;
grant MANAGE SCHEDULER to SCHEDULER_ADMIN with ADMIN OPTION;

grant EXECUTE ON SYS.DBMS_LOGMNR to EXECUTE_CATALOG_ROLE;
grant EXECUTE ON SYS.DBMS_LOGMNR_D to EXECUTE_CATALOG_ROLE;
grant EXECUTE ON SYS.DBMS_LOGMNR_LOGREP_DICT to EXECUTE_CATALOG_ROLE;
grant EXECUTE ON SYS.DBMS_LOGMNR_SESSION to EXECUTE_CATALOG_ROLE;
grant EXECUTE ON SYS.DBMS_FILE_TRANSFER to EXECUTE_CATALOG_ROLE;

