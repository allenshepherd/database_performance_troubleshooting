Rem
Rem $Header: rdbms/admin/catemxv.sql /main/11 2015/10/16 00:06:58 kyagoub Exp $
Rem
Rem catemxv.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catemxv.sql - EM Express file manager View definitions
Rem
Rem    DESCRIPTION
Rem      This file contains the view definitions for EM Express file manager
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catemxv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catemxv.sql
Rem SQL_PHASE: CATEMXV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kyagoub     09/18/15 - em_express_all: add resource manager admin
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    cgervasi    08/24/12 - add perfhub
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kyagoub     03/02/12 - add profile privileges to em_express_all role
Rem    kyagoub     02/13/12 - grant execute on dbms_auto_sqltune to
Rem                           em_express_all
Rem    bdagevil    01/22/12 - grant execute privilege only later
Rem    bdagevil    01/17/12 - grant em_express_all to dba
Rem    kyagoub     01/05/12 - create em_express_[basic/all] roles
Rem    yxie        05/17/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                            public view definitions                        --
-------------------------------------------------------------------------------

CREATE OR REPLACE VIEW REPORT_FILES
  AS SELECT f.name filename, XMLType(f.data) data
       FROM wri$_emx_files f;
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_FILES FOR REPORT_FILES
/

GRANT READ ON REPORT_FILES TO PUBLIC
/

Rem
Rem -- EM_EXPRESS_BASIC role is needed so that users with this
Rem -- role could connect to EM Express (UI) and browse its content 
Rem -- in order to monitor the database. 
Rem
create role EM_EXPRESS_BASIC;
 Rem 
 Rem -- minimum set of privileges to connect to EM express
 Rem -- and browse its content
 Rem 
 grant create session to em_express_basic;
 grant em express connect to em_express_basic;
 grant select_catalog_role to em_express_basic;
 grant select on v_$diag_incident to em_express_basic;

 Rem add execute on prvtemx_admin because prvtemx_admin.get_remote_undo_info() 
 Rem is executed by SQL
 grant execute on sys.prvtemx_admin to em_express_basic;

 Rem add execute on dbms_perf to allow em_express_basic to generate reports
 grant execute on sys.dbms_perf to em_express_basic;

Rem
Rem -- EM_EXPRESS_ALL role is needed so that users with this
Rem -- role could connect to EM Express (UI), browse its content, 
Rem -- and perfom tuning and administrative actions. 
Rem 
Rem -- NOTE the em_express_admin_roles contains all privileges granted 
Rem --      to em_express_basic
Rem
create role EM_EXPRESS_ALL;
 Rem 
 Rem -- admin role should include all privileges of the monitor role  
 Rem 
 grant em_express_basic to em_express_all; 

 Rem Having dba role should be enough to use anything in EM express
 grant em_express_all to dba; 

 Rem
 Rem -- more privileges to perform more administrative options.
 Rem -- like run/schedule and advisor, manage (any)sts, perform 
 Rem -- any SMO (e.g., SQL profile, SQL plan baseline) operations, etc.  
 Rem  
 Rem 
 grant advisor to em_express_all;
 grant create job to em_express_all;
 grant administer sql tuning set to em_express_all;
 grant administer any sql tuning set to em_express_all; 
 grant administer sql management object to em_express_all;
    
 Rem 
 Rem -- mainly for system parameters
 Rem 
 grant alter system to em_express_all;                     
    
 Rem 
 Rem -- tablespace privileges 
 Rem 
 grant create tablespace to em_express_all;
 grant drop tablespace to em_express_all;
 grant alter tablespace to em_express_all;

 Rem 
 Rem -- roles and privileges 
 Rem 
 grant grant any object privilege to em_express_all;
 grant grant any privilege to em_express_all;
 grant grant any role to em_express_all;
 grant create role to em_express_all;
 grant drop any role to em_express_all;
 grant alter any role to em_express_all;

 Rem 
 Rem -- users
 Rem 
 grant create user to em_express_all;
 grant drop user to em_express_all;
 grant alter user to em_express_all;

 Rem
 Rem -- configure auto-sqltune 
 Rem
 grant execute on sys.dbms_auto_sqltune to em_express_all;
 grant execute on sys.dbms_auto_task_admin to em_express_all;

 Rem
 Rem -- user profiles 
 Rem
 grant create profile to em_express_all; 
 grant alter profile to em_express_all;
 grant drop profile to em_express_all;

 Rem
 Rem -- set container for performing actions in CDB
 Rem
 grant set container to em_express_all;

 Rem
 Rem -- system privilege to execute package DBMS_RESOURCE_MANAGER
 Rem
 grant administer resource manager to em_express_all;

@?/rdbms/admin/sqlsessend.sql
