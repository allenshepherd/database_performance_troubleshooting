Rem
Rem $Header: rdbms/admin/catumfusr.sql /main/9 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catumfusr.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catumfusr.sql
Rem
Rem    DESCRIPTION
Rem      Catalog script for UMF Users and Roles.  
Rem
Rem    NOTES
Rem      Additional privileges for sysumf_role for packages are granted in 
Rem      the package creation files. Additional privileges for AWR,Staged and
Rem      UMF tables are added automatically by PLSQL, in execsvrm.sql. If new
Rem      tables are added to AWR or UMF, the privileges will be automatically
Rem      granted.
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catumfusr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catumfusr.sql 
Rem    SQL_PHASE: CATUMFUSR
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    msabesan    04/24/16 - bug 25927752: add privileges to sysumf_role
Rem    quotran     02/06/16 - bug 22626346
Rem    quotran     12/02/15 - bug 22299210
Rem    msabesan    11/24/15 - bug 22238240: remove grant user$ 
Rem    msabesan    09/12/15 - bug 21826062: remove wrh$_sqltext 
Rem    msabesan    08/23/15 - bug21763839: grant SELECT to user$
Rem    msabesan    03/11/15 - project 47327: grant sqltune related privileges 
Rem                         - to sysumf_role
Rem    spapadom    06/30/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


-- SYSUMF role 

CREATE ROLE sysumf_role;

GRANT READ ON sys.v_$database TO sysumf_role;

GRANT READ ON sys.v_$instance TO sysumf_role;

--**********************
-- Grant All TS$ Tables
--**********************
GRANT READ ON sys.ts$ TO sysumf_role;

GRANT READ ON sys.file$ TO sysumf_role;

GRANT READ ON sys.tabpart$ TO sysumf_role;

GRANT READ ON sys.partobj$ TO sysumf_role;

GRANT READ ON sys.indpart$ TO sysumf_role;

GRANT READ ON sys.ind$ TO sysumf_role;


--***************************************************
-- Grant privileges  on sqltune related packages,
-- tables , views and sequence to sysumf_role
--***************************************************

-- base tables 
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_tasks TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_objects TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_binds TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_parameters TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_exec_parameters-
 TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_def_parameters -
TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_executions TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_statistics TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_plan_hash TO - 
sysumf_role;   
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_plans TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_message_groups TO -
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_findings TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_recommendations TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_actions TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_rec_actions TO - 
 sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_rationale TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_rtn_plan TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_sqlt_plan_stats TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_usage TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_sqlset_references TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_inst_fdg TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_directive_instances TO -
 sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_journal TO sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_sqlset_references TO - 
sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_sqlset_definitions TO -
  sysumf_role;
GRANT SELECT, INSERT, DELETE, UPDATE ON sys.wri$_adv_directive_defs TO - 
sysumf_role;

-- views 
GRANT select_catalog_role TO sysumf_role;

-- sequence
GRANT SELECT ON sys.wri$_sqlset_ref_id_seq TO sysumf_role;
GRANT SELECT ON sys.wri$_adv_seq_msggroup  TO sysumf_role;

--privileges
grant ADVISOR to sysumf_role;
grant ADMINISTER SQL MANAGEMENT OBJECT to sysumf_role;

--**********************
-- Create SYSUMF user
--**********************
CREATE USER sys$umf IDENTIFIED BY sysumf ACCOUNT LOCK PASSWORD EXPIRE;

-- Revoke automatic grant of INHERIT PRIVILEGES from public
DECLARE
  already_revoked EXCEPTION;
  pragma exception_init(already_revoked,-01927);
BEGIN
  EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER SYS$UMF FROM public';
  EXCEPTION
   WHEN already_revoked THEN
     NULL;
END;
/

GRANT sysumf_role TO sys$umf; 
GRANT CREATE SESSION TO sys$umf;
@?/rdbms/admin/sqlsessend.sql
