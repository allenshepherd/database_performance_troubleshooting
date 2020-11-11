Rem
Rem $Header: rdbms/admin/catgwm.sql /main/15 2016/10/17 14:57:37 sdball Exp $
Rem
Rem catgwm.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catgwm.sql - Catalog script for GSM
Rem
Rem    DESCRIPTION
Rem      Creates roles and users for GSM.
Rem
Rem    NOTES
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catgwm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catgwm.sql
Rem SQL_PHASE: CATGWM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdball      10/11/16 - Bug 24824274: unlimited sysaux for
Rem                           gsmadmin_internal
Rem    sdball      02/04/16 - Bug 22501277: Create profile for GSM users
Rem    dcolello    11/21/15 - grant select on v_$dispatcher_config 
Rem                           to gsmadmin_internal
Rem    sdball      09/25/15 - Bug 21304186: Revoke inherit privs
Rem    sdball      06/10/15 - Support for long identifiers
Rem    sdball      10/23/14 - Changes for 12.2 sharding
Rem    ralekra     09/08/14 - Catalog changes required by OGG
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    pyam        06/25/13 - change gsm_change_message to CREATE + ALTER
Rem    sdball      02/06/13 - New types for database parameters and instances
Rem    sdball      06/08/12 - gran cdb_services to gsmadmin_internal.
Rem    nbenadja    10/31/11 - Add privileges to gsmadmin
Rem    sdball      10/19/11 - use v_$ rather than gv_$ tables.
Rem    sdball      09/27/11 - Move privs to catgw.sql (needed for all
Rem                           databases).
Rem    mjstewar    04/12/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SET ECHO ON
-- SPOOL catgwm.log

--*****************
-- Create GSM Roles
--*****************

---------------
-- gsmuser_role
---------------

-- Create role for GSM USER
CREATE ROLE gsmuser_role;
GRANT connect to gsmuser_role;

grant select on gv_$instance                to gsmuser_role;
grant select on gv_$osstat                  to gsmuser_role;
grant select on gv_$sysmetric_history       to gsmuser_role;
grant select on gv_$sysmetric               to gsmuser_role;
grant select on gv_$servicemetric_history   to gsmuser_role;
grant select on gv_$servicemetric           to gsmuser_role;
grant select on gv_$active_services         to gsmuser_role;
grant select on gv_$session                 to gsmuser_role;

grant select on v_$dg_broker_config         to gsmuser_role;
grant select on gv_$dg_broker_config        to gsmuser_role;



--*****************
-- Create GSM Users
--*****************

--------------------
-- gsmadmin_internal
--------------------

-- gsmadmin_internal owns the GSM administrative packages

CREATE USER gsmadmin_internal identified by gsm
  account lock password expire
  default tablespace sysaux
  quota unlimited on sysaux;

-- So that packages can count number of list values for _gsm parameter
grant select on v_$parameter2 to gsmadmin_internal;

-- So that packages can do 'alter system set'
grant alter system to gsmadmin_internal;

-- So we can create jobs
grant manage scheduler to gsmadmin_internal;

-- So that packages can query current dispatcher config for scheduler setup
grant select on v_$dispatcher_config to gsmadmin_internal;

-- So that we can select from dba_services
grant select on sys.dba_services to gsmadmin_internal;

grant select on sys.gv_$active_services to gsmadmin_internal;

-- revike inherit privs
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 
    'REVOKE INHERIT PRIVILEGES ON USER gsmadmin_internal FROM public';
exception
  when already_revoked then
    null;
end;
/


----------
-- gsmuser
----------

-- GSM process connects to GSM databases as gsmuser.
 
CREATE USER gsmuser identified by gsm
  account lock password expire;

DECLARE
  conId   NUMBER := 0;
BEGIN
  begin
    execute immediate
      'select SYS_CONTEXT(''USERENV'', ''CON_ID'') from sys.dual'
      into conId;
  exception
    WHEN OTHERS THEN
       IF SQLCODE = -2003 THEN conId := 0; ELSE RAISE; END IF;
  end;

  IF conId = 0 THEN
    declare
      already_exists exception;
      pragma exception_init(already_exists,-02379);
    begin
      execute immediate 
        'CREATE PROFILE gsm_prof LIMIT FAILED_LOGIN_ATTEMPTS 10000000';
    exception when already_exists then null;
    end;
    execute immediate 'ALTER USER gsmuser PROFILE gsm_prof';
  END IF;
END;
/

GRANT gsmuser_role to gsmuser;
-- GRANT sysdba to gsmuser;

-- revoke inherit privs
declare
  already_revoked exception;
  pragma exception_init(already_revoked,-01927);
begin
  execute immediate 
    'REVOKE INHERIT PRIVILEGES ON USER gsmuser FROM public';
exception
  when already_revoked then
    null;
end;
/
--CREATE USER gsmuser_internal identified by gsm 
--  account lock password expire;
--GRANT gsmuser_role to gsmuser_internal;
--GRANT sysoper to gsmuser_internal;

-- so that the GSM can create sharded objects on behalf of other users
grant unlimited tablespace to gsmuser;
grant create tablespace to gsmuser;

grant create any table                      to gsmuser;
grant create any index                      to gsmuser;
grant create any materialized view          to gsmuser;
grant create any procedure                  to gsmuser;
grant create any sequence                   to gsmuser;
grant create any synonym                    to gsmuser;
grant create any view                       to gsmuser;

grant alter any table                      to gsmuser;
grant alter any index                      to gsmuser;
grant alter any materialized view          to gsmuser;
grant alter any procedure                  to gsmuser;
grant alter any sequence                   to gsmuser;

grant drop any table                      to gsmuser;
grant drop any index                      to gsmuser;
grant drop any materialized view          to gsmuser;
grant drop any procedure                  to gsmuser;
grant drop any sequence                   to gsmuser;
grant drop any synonym                    to gsmuser;
grant drop any view                       to gsmuser;

ALTER SESSION SET CURRENT_SCHEMA = gsmadmin_internal;

-- Create types to hold database specific service information
--  We don't use 'OR REPLACE' or drop the type since they are
--  referenced in column definitions in database tables.

CREATE TYPE dbparams_t AS OBJECT (
    param_name     VARCHAR2(30),
    param_value    VARCHAR2(100))
/
show errors

CREATE TYPE dbparams_list IS VARRAY(10) OF dbparams_t
/
show errors

CREATE TYPE rac_instance_t AS OBJECT (
    instance_name  VARCHAR2(30),
    pref_or_avail  CHAR(1)          -- 'P' (preferred)
                                    -- 'A' (available)
)
/
show errors

CREATE TYPE instance_list IS TABLE OF rac_instance_t
/
show errors

CREATE OR REPLACE TYPE name_list IS TABLE OF VARCHAR2(128)
/
show errors

CREATE TYPE number_list IS TABLE OF number
/
show errors

-----------------------------------
-- Create Change Queue Message Type
-----------------------------------
CREATE TYPE gsm_change_message AS OBJECT (
   admin_id             NUMBER,
   change_id            NUMBER,
   seq#                 NUMBER,
   command              VARCHAR2(30),
   target               VARCHAR2(64),
   pool_name            VARCHAR2(30),     -- Only for pool admin actions
   additional_params    VARCHAR2(1024)    -- Additional parameters for the command
                                          -- Depends on the command and is not used
                                          -- for all commands.  Uses the same syntax
                                          -- as in the gsmctl command.  For example
                                          -- for START SERVICE may contain the 
                                          -- database name:
                                          --        "-database db_name"
)
/
show errors

-- to preserve type history between installed and upgraded databases,
-- we issue CREATE, then ALTER. The above creations match those in 12.1.0.1
ALTER TYPE gsm_change_message 
   MODIFY ATTRIBUTE additional_params VARCHAR(4000) CASCADE
/

ALTER TYPE dbparams_t
   MODIFY ATTRIBUTE param_name        VARCHAR2(128) CASCADE
/

ALTER TYPE rac_instance_t
   MODIFY ATTRIBUTE instance_name     VARCHAR2(128) CASCADE
/

ALTER TYPE gsm_change_message   
   MODIFY ATTRIBUTE command           VARCHAR2(128) CASCADE
/

ALTER TYPE gsm_change_message   
   MODIFY ATTRIBUTE target            VARCHAR2(128) CASCADE
/

ALTER TYPE gsm_change_message 
   MODIFY ATTRIBUTE pool_name         VARCHAR2(128) CASCADE
/

ALTER SESSION SET CURRENT_SCHEMA = SYS;

@?/rdbms/admin/sqlsessend.sql
