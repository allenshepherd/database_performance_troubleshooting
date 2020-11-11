Rem
Rem $Header: rdbms/admin/catprofc.sql /main/14 2017/09/14 09:17:49 youyang Exp $
Rem
Rem catprofc.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catprofc.sql - Privilege capture table Creation
Rem
Rem    DESCRIPTION
Rem      Tables for privilege capture
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catprofc.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catprofc.sql
Rem SQL_PHASE: CATPROFC
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproftab.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youyang     08/16/17 - bug26634962:add default for run_seq#
Rem    youyang     05/27/14 - add cbac package array
Rem    jheng       01/10/14 - Bug 18056142: grant SELECT priv to capture_admin
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    youyang     12/18/13 - bug17974563:change ORA$PLSQL to ORA$DEPENDENCY
Rem    youyang     09/10/13 - add pl/sql capture
Rem    jheng       08/06/13 - Bug 16931220: change grant_path to varray
Rem    jheng       08/16/12 - Bug 14491844: add col userpriv#
Rem    jheng       07/18/12 - Change column enabled to boolean
Rem    jheng       05/21/12 - Bug 14003817: add id# to captured_priv$
Rem    jheng       04/24/12 - Bug 12696127: remove timestamp and sessionId
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jheng       12/01/11 - Change object names
Rem    jheng       10/07/11 - Bug 12804167
Rem    jheng       01/18/11 - add col# and option columns
Rem    jheng       08/25/10 - add session info
Rem    jheng       04/09/10 - Privilege profile tables
Rem    jheng       04/09/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- table to store capture metadata 
create table sys.priv_capture$(
  id#           number NOT NULL,         
  name          varchar2(128) NOT NULL,
  description   varchar2(1024) DEFAULT NULL,
  type          number DEFAULT 1,
  enabled       number DEFAULT 0,
  roles         sys.role_id_list,
  context       varchar2(4000) DEFAULT NULL,
  run_seq#      number DEFAULT 0,
  CONSTRAINT capture_pk PRIMARY KEY (name)
)
tablespace SYSAUX
/

grant select on sys.priv_capture$ to capture_admin;

-- default capture for PL/SQL compilation privileges
BEGIN
execute immediate 'insert into sys.priv_capture$ (id#, name) values (0, ''ORA$DEPENDENCY'')';
EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- table to store the capture run log
create table sys.capture_run_log$(
  capture       number NOT NULL, 
  run_seq#      number DEFAULT 0,
  start_time    timestamp DEFAULT NULL,
  end_time      timestamp DEFAULT NULL,
  syspriv_grant# number,
  objpriv_grant# number,
  run_name      varchar2(128))
tablespace SYSAUX
/

grant select on sys.capture_run_log$ to capture_admin;

-- table to captured privileges 
create table sys.captured_priv$(
  id#           number NOT NULL,
  os_user       varchar2(128),
  host          varchar2(128),
  module        varchar2(64),
  capture       number NOT NULL,
  run_seq#      number NOT NULL,
  user#         number not NULL,
  log_user#     number default NULL,
  role#         number default NULL,
  syspriv#      number default NULL,
  objpriv#      number default NULL,
  userpriv#     number default NULL,
  obj#          number default NULL,
  col#          number default NULL,
  option$       number default NULL,
  e_roles       sys.role_array,
  app_roles     sys.role_array,
  cbac_plist    sys.package_array)
tablespace SYSAUX
/

-- a separate table to store grant paths for used privileges
create table sys.priv_used_path$(
id#          number NOT NULL,
capture      NUMBER NOT NULL,
path         sys.grant_path,
run_seq#     NUMBER NOT NULL)
tablespace SYSAUX
/

--unused privilege
create table sys.priv_unused$(
  id#       NUMBER NOT NULL,
  capture   NUMBER NOT NULL,
  user#     NUMBER NOT NULL,
  syspriv#  NUMBER DEFAULT NULL,
  objpriv#  NUMBER DEFAULT NULL,
  userpriv# NUMBER DEFAULT NULL,
  obj#      NUMBER DEFAULT NULL,
  col#      NUMBER DEFAULT NULL,  
  option$   NUMBER DEFAULT NULL,
  run_seq#  NUMBER)
tablespace SYSAUX
/

-- a separate table to store the grant paths for unused privileges
create table sys.priv_unused_path$(
id#          number NOT NULL,
capture      NUMBER NOT NULL,
path         sys.grant_path,
run_seq#     NUMBER NOT NULL)
tablespace SYSAUX
/

create table sys.unused_grant$(
  capture#   NUMBER NOT NULL,
  run_seq#   NUMBER NOT NULL,
  grantee#   NUMBER NOT NULL,
  role#      NUMBER DEFAULT NULL,
  syspriv#   NUMBER DEFAULT NULL,
  objpriv#   NUMBER DEFAULT NULL,
  userpriv#  NUMBER DEFAULT NULL,
  obj#       NUMBER DEFAULT NULL,
  col#       NUMBER DEFAULT NULL,
  option$    NUMBER DEFAULT NULL)
tablespace SYSAUX
/

create sequence sys.priv_capture_seq$ start with 5000 increment by 1
NOCACHE NOCYCLE ORDER;
create sequence sys.priv_used_id$ start with 1 increment by 1
NOCACHE NOCYCLE ORDER;
create sequence sys.priv_unused_id$ start with 1 increment by 1
NOCACHE NOCYCLE ORDER;

@?/rdbms/admin/sqlsessend.sql
