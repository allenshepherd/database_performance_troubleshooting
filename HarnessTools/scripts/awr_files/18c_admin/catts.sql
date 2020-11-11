Rem
Rem $Header: rdbms/admin/catts.sql /main/60 2016/06/18 00:40:31 yohu Exp $
Rem
Rem catts.sql
Rem
Rem Copyright (c) 2009, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catts.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem    Please check for any upgrade/downgrade impact when modifying this file.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catts.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catts.sql
Rem SQL_PHASE: CATTS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yohu        06/17/16 - Bug 22334884: Remove internal URL
Rem    youyang     04/13/16 - bug22865694:add a comment for adding new ras role
Rem    yanlili     06/22/15 - Fix bug 20897609: Add xs_connect and
Rem                           xsconnect role
Rem    rbolarr     06/04/15 - Bug 17871008: Set Default Tablespace for XS$NULL
Rem    yanlili     05/26/15 - Bug 19880667: Remove XS_RESOURCE role from 12.2
Rem    mincwang    05/22/15 - Bug 19582638 - MISSING A SEEDED PRIVILEGE FOR RAS
Rem    rbolarr     05/14/15 - change lightweight to application
Rem    sramakri    11/21/14 - add missing Rem
Rem    yohu        10/10/14 - Bug 19762574: Do not grant MODIFY_SESSION system
Rem                           privilege to XSPUBLIC
Rem    yohu        08/19/14 - Proj 46902: Sesion Privilege Scoping
Rem    yiru        08/05/14 - Remove redundant set for _ORACLE_SCRIPT 
Rem    yanlili     08/03/14 - Proj 46907: Schema level policy admin
Rem    pyam        05/27/14 - fix table column ordering
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    pradeshm    07/03/13 - Proj#46908: Added new columns in principal table
Rem                           for password policy support, dropped profile
Rem                           column
Rem    yiru        04/02/13 - Fix Bug 16584046: use substrb for xs$acl_param_i3
Rem                           xs$nstmpl_attr_i1
Rem    minx        04/03/13 - Fix bug16369584: alter XS$NULL identified by
Rem                           an impossible hash value 
Rem    minx        11/08/12 - Fix bug15852980: change ace_flag to 3
Rem    yanlili     10/25/12 - Fix lrg 7171100: set _ORACLE_SCRIPT to true
Rem    minx        10/22/12 - Add XSDISPATCHER ROLE, Rename xs_nsattr_admin
Rem                           to xs_namespace_admin
Rem    yiru        10/01/12 - Add flag for oracle supplied objects
Rem    yanlili     09/25/12 - Consolidate four audit policies into two
Rem    rpang       08/08/12 - 6662951: add JDWP privilege
Rem    minx        07/23/12 - Fix bug# 14353015, add flag to xs$ace to mark 
Rem                           seeded ace
Rem    yanlili     07/16/12 - Fix bug 14148718,14325603: grant xs_session_admin
Rem                           to XSSESSIONADMIN; add container=current for the
Rem                           grants to take effect in all PDBs with db creation
Rem    mincwang    07/10/12 - privilege for trusted session
Rem    snadhika    07/06/12 - Bug # 14282163 - seeded dynamic role not marked
Rem                           as system dynamic roles
Rem    yiru        05/07/12 - Add index on priv# in xs$priv(delete performance)
Rem    mincwang    05/12/12 - fix bug 14039355
Rem    snadhika    05/07/12 - Bug # 14040966 - XSCACHEADMIN is default enabled
Rem    rpang       04/23/12 - 9950582: add new HTTP / SMTP privileges
Rem    yanlili     04/18/12 - Fix bug 13770348: Triton direct logon/logoff fail
Rem                           if sysaux tablespace is offline
Rem    rpang       04/12/12 - 13941768: rename network ACL privileges
Rem    snadhika    03/06/12 - Bug # 13240543, Session privilege check
Rem    rpang       03/28/12 - lrg 6858789: create network security class
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    snadhika    03/06/12 - Bug # 13240543, Session privilege check
Rem    minx        02/14/12 - Namespace privilege enhancement
Rem    taahmed     02/01/12 - default acl clnup
Rem    yiru        12/19/11 - fix the error in an ACE - XS_RESOURCE is DB role
Rem    skwak       12/06/11 - Add policy_schema to xs$olap_policy
Rem    snadhika    11/17/11 - Remove xspublic role grant from xsguest
Rem    taahmed     10/28/11 - sec class as priv uniqueness scope
Rem    weihwang    09/23/11 - deprecate function role, object acl
Rem    yanlili     08/30/11 - Proj 23934: Change TRITON to XS in pre-seeded
Rem                           audit policies 
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    snadhika    08/25/11 - Bug 12916823 - Chnage id for EXTERNAL_DBMS_AUTH
Rem                           as it is already used by another principal
Rem    weihwang    07/30/11 - Change ALL privileges security class to NULL
Rem    snadhika    07/11/11 - Make username and rolename in session tables
Rem                           as 128 char instead of 4000 char  
Rem    skwak       06/23/11 - Add default ACLs for session privilege check
Rem    yiru        06/13/11 - Admin sec project: add xs_resource role
Rem    snadhika    06/10/11 - Add EXTERNAL_DBMS_AUTH dynamic role 
Rem                           for Triton external user logon (project # 34785) 
Rem    yanlili     05/19/11 - Add pre-seeded audit policies
Rem    traney      03/31/11 - 35209: long identifiers dictionary upgrade
Rem    minx        03/09/11 - System namespace templte enhancement 
Rem    yiru        03/07/11 - Admin sec project: table changes and seeded data
Rem    yiru        01/19/11 - Add security context in rxs$sessions table
Rem    snadhika    01/31/11 - Added attach version# in rxs$sessions
Rem    snadhika    12/29/10 - Update NLS_TIMESTAMP_* columns in rxs$sessions
Rem    yiru        08/09/10 - Raise no error if seeded objects already exist -
Rem                           solve Reupgrade diffs
Rem    snadhika    05/31/10 - lrg # 4642137
Rem    yiru        05/09/10 - Full Drop6R cleanup before merge-down, 
Rem                           fix index xs$acl_param_i3 based on block size
Rem    snadhika    04/13/10 - Triton session enhancement project
Rem    skwak       04/08/10 - Add xs$olap_policy table
Rem    skwak       02/16/10 - Add index on xs$acl_param table
Rem    jnarasin    12/17/09 - Late Binding Txn 3
Rem    weihwang    11/16/09 - Added dynamic role XSSWITCH
Rem    snadhika    11/12/09 - seeded xsprovisoner role, added db role
Rem                           provisioner
Rem    snadhika    10/22/09 - seeded default ACL for system security class
Rem    weihwang    10/30/09 - Change seed object name to upper case
Rem    rbhatti     10/08/09 - Update xs$id_sequence max value
Rem    rbhatti     10/06/09 - Update xs$obj with dependency count coulmns
Rem    yiru        09/14/09 - Push ctime, mtime and description into entity 
Rem                           tables. Add ctime, mtime, description for seeded
Rem                           principals
Rem    rbhatti     09/09/09 - Update enable column comment in xs$prin
Rem    yiru        08/27/09 - Add workspace column in rxs$session_appns
Rem    snadhika    09/06/09 - Seed security class and privileges
Rem    weihwang    08/31/09 - Added uniqueness constraint in xs$ace_priv
Rem    yiru        08/27/09 - Add workspace column in rxs$session_appns
Rem    yiru        07/27/09 - Create policy parameter, ACL parameter value
Rem                           tables
Rem    yiru        07/15/09 - Create principal, roleset related tables
Rem    snadhika    06/23/09 - Create workspace, acl, security class 
Rem                           related tables
Rem

-- set this parameter for creating common objects in consolidated database
@@?/rdbms/admin/sqlsessstart.sql

-- Workspace table
create table xs$workspace (
  name           varchar2(128),
  type           number,  /* 0=built-in; 1=user */
  description    varchar2(4000),
  constraint xs$workspace_pk primary key (name)
);

-- Tenant table
create table xs$tenant (
  name           varchar2(128),                        /* name of the tenant */
  description    varchar2(4000),                                  /*comments */
  constraint xs$tenant_pk primary key (name)
);

-- Triton object table
create table xs$obj ( 
  name         varchar2(128),                          /* Triton entity name */
  ws           varchar2(128) default 'XS',
  owner        varchar2(128) default 'SYS',  /* 'SYS' or object owner schema */
  tenant       varchar2(128) default 'SYSTEM',  /* 'SYSTEM' or object tenant */
  id           number,                                   /* Triton entity ID */
  type         number,
  /* 1=prin, 2=sc, 3=acl, 4=priv, 5=dsec, 6=roleset 7=nstemplate*/
  status       number,
/* 0=invalid, 1=valid, 2=external other states to be decided by late binding */
  flags        number default 0,
  early_dep_cnt  number default 0,
  late_dep_cnt   number default 0,  
  aclid          number default null,
  constraint xs$obj_uk unique (name, owner, tenant, type),
  constraint xs$obj_pk primary key (id),
  constraint xs$obj_fk foreign key (tenant) 
    references xs$tenant (name)
);

-- Principal table
create table xs$prin (
  prin#             number,
  type              number,
                    /* 0=user, 1=role, 2=dyn role */
  guid              raw(16),
  ext_src           varchar2(128),  /* external sources */
  start_date        timestamp with time zone,
  end_date          timestamp with time zone,
  schema            varchar2(128),    /* user */
  tableSpace        varchar2(30),    /* user */
  credential        varchar2(128),    /* user */
  failedlogins      number,          /* user */
  enable            number default 0,/* user or role specific default setting, 
                                        0=FALSE, 1=TRUE */
  duration          number,          /* dyn role */
  system            number default 0,/* dyn role 0=FALSE, 1=TRUE */
  scope             number default 0,/* dyn role 0=session, 1=request */
  powner            varchar2(128),    /* code role - deprecated */
  pname             varchar2(128),    /* code role - deprecated */
  pfname            varchar2(128),    /* code role - deprecated */
  objacl#           number,          /* acl for principal - deprecated */
  note              varchar2(4000),
  status            number default 1,/* user */
                    /* 1=ACTIVE, 2=INACTIVE */
  ctime             timestamp,
  mtime             timestamp,
  description       varchar2(4000),
  profile#          number default 0,         /* profile assigned to user */
  ptime             date,
                    /* password change time, when password changed last time */
  exptime           date,                 /* actual password expiration time */
  ltime             date,                     /* time when account is locked */
  lslogontime       date,                       /*Last Successful Logon Time */
  astatus           number default 0,      /* password policy account status */
  constraint xs$prin_pk  primary key (prin#),
  constraint xs$prin_fk1 foreign key (prin#) references xs$obj(id)
  --Remove this foreign key since objacl# is no use right now.
  --constraint xs$prin_fk2 foreign key (objacl#) references xs$obj(id)
                                     /* late binding */
);

-- Role Grant table (lwt role-> lwt user/role).
create table xs$role_grant (
  grantee#      number,
  role#         number,
  granter#      number,      /* who created this rolegrant */
  start_date    timestamp with time zone,
  end_date      timestamp with time zone,
  constraint xs$role_grant_uk  unique (grantee#, role#),
  constraint xs$role_grant_fk1 foreign key (grantee#)
    references xs$prin(prin#),
  constraint xs$role_grant_fk2 foreign key (role#)
    references xs$prin(prin#)
);

-- Proxy Role table
create table xs$proxy_role (
  proxy#         number,     /* proxy user id */
  client#        number,     /* client user id (target user) */
  role#          number,     /* proxy role id */
  granter#       number,     /* who created this proxy grant */
  constraint xs$proxy_role_uk unique (proxy#, client#, role#),
  constraint xs$proxy_role_fk1 foreign key (proxy#)
    references xs$obj(id),   /* external user can also proxy */
  constraint xs$proxy_role_fk2 foreign key (role#)
    references xs$prin(prin#)
);

-- security class table
create table xs$seccls ( 
  sc#          number,
  ctime        timestamp,
  mtime        timestamp,
  description  varchar2(4000),
  constraint xs$seccls_pk primary key (sc#),
  constraint xs$seccls_fk1 foreign key (sc#) references xs$obj(id)
); 

-- security class hierarchy table
create table xs$seccls_h ( 
  sc#          number,
  parent_sc#   number,
  constraint xs$seccls_h_uk unique (sc#, parent_sc#),
  constraint xs$seccls_h_fk1 foreign key (sc#) references xs$seccls(sc#),
  constraint xs$seccls_h_fk2 foreign key (parent_sc#) 
    references xs$obj(id) /* late binding */ 
); 

-- privilege table
create table xs$priv (
  priv#        number,
  sc#          number,
  ctime        timestamp,
  mtime        timestamp,
  description  varchar2(4000),
  constraint   xs$sc_priv_uk unique (sc#, priv#),
  constraint   xs$priv_fk1 foreign key (priv#) references xs$obj(id),
  constraint   xs$priv_fk2 foreign key (sc#) references xs$seccls(sc#) 
);

-- Index on priv# in xs$priv
create index xs$priv_i1 on xs$priv(priv#);

-- aggregate privilege table
create table xs$aggr_priv (
  sc#              number,
  aggr_priv#       number,
  implied_priv#    number,
  constraint xs$aggr_priv_uk unique (sc#, aggr_priv#, implied_priv#),
  constraint xs$aggr_priv_fk1 
    foreign key (sc#, aggr_priv#) references xs$priv(sc#, priv#),
  constraint xs$aggr_priv_fk2 
    foreign key (implied_priv#) references xs$obj(id) /* late binding */
);


-- ACL table
create table xs$acl ( 
  acl#            number,
  sc#             number,
  parent_acl#     number,
  acl_flag        number default 0,
  /* 0 = none, 1 = extended, 2 = constrained, 3=system_constraing_acl */
  ctime             timestamp,
  mtime             timestamp,
  description       varchar2(4000),
  constraint xs$acl_pk primary key (acl#),
  constraint xs$acl_fk1 foreign key (acl#) references xs$obj(id),
  constraint xs$acl_fk2 foreign key (parent_acl#) references xs$obj(id), /* late binding */
  constraint xs$acl_fk3 foreign key (sc#) references xs$obj(id) /* late binding */
); 

-- ACE table
create table xs$ace ( 
  acl#          number,
  order#        number,
  ace_type      number default 1,   /* 1 = GRANT, 0 = DENY */
  prin#         number,
  prin_type     number,             /* 1=XS, 2=DB, 3=DN, 4=EXTERNAL*/
  prin_invert   number default 0,   /* 0 = FALSE, 1 = TRUE */
  start_date    timestamp,
  end_date      timestamp,
  ace_flag      number default 0,  /* bit 1: 0 = regular, 1 = seeded
                                      bit 2: 0 = user, 1 = oracle_supplied */
  constraint xs$ace_pk  primary key (acl#, order#),
  constraint xs$ace_fk1 foreign key (acl#) references xs$acl(acl#)
);

-- ACE Privilege table
create table xs$ace_priv (
  acl#         number, 
  ace_order#   number,
  priv#        number,
  constraint  xs$ace_priv_uk  unique (acl#, ace_order#, priv#),
  constraint xs$ace_priv_fk1 foreign key (acl#, ace_order#) 
    references xs$ace(acl#, order#),
  constraint xs$ace_priv_fk2 foreign key (priv#) references xs$obj(id) /* late binding */
);

-- Data Security policy table
create table xs$dsec (
  xdsid#        number,
  ctime             timestamp,
  mtime             timestamp,
  description       varchar2(4000),
  constraint xs$dsec_pk primary key (xdsid#),
  constraint xs$dsec_fk foreign key (xdsid#) references xs$obj(id)
);

--Policy parameter table (param metadata)
create table xs$policy_param (
  pname        varchar(128),
  xdsid#       number,  /* data security policy id# */
  type         number,  /* 1=NUMBER; 2=VARCHAR; 3=DATE; 4=Timestamp */
  constraint xs$policy_param primary key (pname, xdsid#),
  constraint xs$policy_param_fk1 foreign key (xdsid#)
    references xs$dsec(xdsid#)
);

-- ACL Parameter table (param values)
create table xs$acl_param (
  xdsid#      number,
  acl#        number,
  pname       varchar2(128),
  pvalue1     number,            /* number values */
  pvalue2     varchar2(4000),    /* string values */
  constraint  xs$acl_param_fk1 foreign key (pname, xdsid#)
    references xs$policy_param(pname, xdsid#),
  constraint  xs$acl_param_fk2 foreign key (acl#) references xs$acl(acl#)
);

create unique index xs$acl_param_i1 on xs$acl_param(pname, xdsid#, acl#);
create index xs$acl_param_i2 on xs$acl_param(pvalue1);

-- fix index xs$acl_param_i3 based on block size
declare
  bsz number; 
  xsaclparam_tok_bytes   number; 
 
begin 
  /* figure out block size and use appropriate token size */
  select t.block_size into bsz from user_tablespaces t, user_users u
      where u.default_tablespace = t.tablespace_name;

   if bsz < 4096 then
      xsaclparam_tok_bytes  := 400; 
   elsif bsz < 8192 then
      xsaclparam_tok_bytes  := 1000;
   else
      xsaclparam_tok_bytes  := 2000;
   end if; 
commit;
execute immediate 'create index xs$acl_param_i3 on xs$acl_param (substrb(pvalue2, 1,' || xsaclparam_tok_bytes || '))';
commit;
end;
/

-- Attribute security table
create table xs$attr_sec (
  xdsid#       number,
  attr_name    varchar2(128),
  priv#        number,
  constraint xs$attr_sec_uk  unique (xdsid#, attr_name, priv#),
  constraint xs$attr_sec_fk1 foreign key (xdsid#)
    references xs$dsec(xdsid#),
  constraint xs$attr_sec_fk2 foreign key (priv#) references xs$obj(id) /* late binding */
-- attr_name may require a referencial constraint
);

-- Instance set table
create table xs$instset_list (
  xdsid#       number,
  order#       number,
  type         number,
  /* 1=rule-based instance set; 2= inheritant instance set (master-detail) */
  constraint   xs$dsec_instset_uk  primary key (xdsid#, order#),
  constraint   xs$dsec_instset_fk  foreign key (xdsid#) references xs$dsec (xdsid#)
);

-- Regular instance set table
create table xs$instset_rule (
  xdsid#       number,
  order#       number,
  rule         varchar2(4000),
  static       number default 0, /* 0=dynamic instset; 1=static instset */
  flags        number default 0, 
  description  varchar2(4000) default null,
  /* reserved: 0x1=rule is parameterized, 0x2=has denies, etc */
  constraint xs$instset_rule_pk primary key (xdsid#, order#),
  constraint xs$instset_rule_fk foreign key (xdsid#, order#)
    references xs$instset_list(xdsid#, order#)
);

-- Instance set ACLs
create table xs$instset_acl (
  xdsid#       number,
  order#       number,
  acl#         number,
  acl_order#   number,
  constraint xs$instset_acl_fk1 foreign key (xdsid#, order#)
    references xs$instset_rule(xdsid#, order#),
  constraint xs$instset_acl_fk2 foreign key (acl#)
    references xs$obj(id) /* late binding */
);

-- Inheritance instance set table (master-detail policy)
create table xs$instset_inh (
  xdsid#         number,
  order#         number,
  parent_schema  varchar2(128),
  parent_object  varchar2(128),
  when           varchar2(4000),
  constraint xs$instset_inh_pk primary key (xdsid#, order#),
  constraint xs$instset_inh_fk foreign key (xdsid#, order#)
    references xs$instset_list(xdsid#, order#)
);

create table xs$instset_inh_key (
  xdsid#    number,
  order#    number,
  pkey      varchar2(128),    /* primary key (col name from master table) */
  fkey      varchar2(4000),  /* foreign key (col name or value in detail table */
  fkey_type number,          /* 1=fk is col name; 2=fk is col value */
  constraint xs$instset_inh_key_uk unique (xdsid#, order#, pkey),
  constraint xs$instset_inh_key_fk foreign key (xdsid#, order#)
    references xs$instset_inh(xdsid#, order#)
);

-- OLAP policy table
create table xs$olap_policy (
  schema_name   VARCHAR2(128),
  logical_name  VARCHAR2(128),
  policy_name   VARCHAR2(128),
  policy_schema VARCHAR2(128),
  enable        number
);

-- Roleset table
create table xs$roleset (
  rsid#        number,
  ctime        timestamp,
  mtime        timestamp,
  description  varchar2(4000),
  constraint   xs$roleset_pk primary key (rsid#),
  constraint   xs$roleset_fk foreign key (rsid#) references xs$obj(id)
);

-- Roleset Role table
create table xs$roleset_roles (
  rsid#       number,
  role#       number,
  constraint xs$roleset_roles_fk1 foreign key (rsid#)
    references xs$roleset(rsid#),
  constraint xs$roleset_roles_fk2 foreign key (role#)
    references xs$obj(id),  /* late binding */
  constraint xs$roleset_roles_uk unique (rsid#, role#)
);

-- Namespace Template tables
create table xs$nstmpl (
  ns#           number,
  acl#          number,
  hschema       varchar2(128),    /* handler schema name */
  hpname        varchar2(128),    /* handler package name */
  hfname        varchar2(128),    /* handler function name */
  ctime         timestamp,
  mtime         timestamp,
  description   varchar2(4000),
  constraint xs$nstmpl_pk primary key (ns#),
  constraint xs$nstmpl_fk1 foreign key (ns#) references xs$obj(id),
  constraint xs$nstmp1_fk2 foreign key (acl#) references xs$acl(acl#)
);

create table xs$nstmpl_attr (
  ns#           number,
  attr_name     varchar2(4000),
  def_value     varchar2(4000),
  event_cbk     number default 0,
  -- 0=no event callback, 1=first-read event, 
  -- 2=update event, 3=both first read and update
  constraint xs$nstmpl_attr_fk foreign key (ns#) references xs$nstmpl(ns#)
);

/************ Create Token - ID mapping tables *********************/
/* If the block size is less than 8K use smaller token sizes so
 * that index creation doesn't fail. (see bug 3928505)
 *
 * The max index key sizes for various block sizes are:
 *  2K max index key size = 1478 bytes (on Linux)
 *  4K max index key size = 3118 bytes (on Linux)
 *  8K max index key size = 6398 bytes (on Linux)
 *
 * For each of the various token column sizes below, the maximum token
 * length that would permit token-->id index creation was determined and
 * then a value 5% less (to account for any platform specific variance)
 * was picked as the token size.
 * 
 * Values of 1400 and 3000 was chosen for 2K and 4K respectively
 * taken from rdbms/admin/catxdbtm.sql
 *
 */

declare
  bsz number; 
  xsnstempl_tok_bytes   number; 
 
begin
    /* figure out block size and use appropriate token size */
   select t.block_size into bsz from user_tablespaces t, user_users u
      where u.default_tablespace = t.tablespace_name;

   if bsz < 4096 then
      xsnstempl_tok_bytes  := 400; 
   elsif bsz < 8192 then
      xsnstempl_tok_bytes  := 1000;
   else
     /* On a 64-bit sparc machine, it seems the limit is less than 6398 bytes 
        (on a Linux machine). So try a smaller size here by changing the token
        size from 4000 to 2000. This would put a more strict constraint for 
        the principal name, that is the first 2000 byte of a principal name 
        should be unique. */
      xsnstempl_tok_bytes  := 2000;
   end if; 
commit;
execute immediate 'create unique index xs$nstmpl_attr_i1 on xs$nstmpl_attr (ns#,substrb(attr_name, 1,' || xsnstempl_tok_bytes || '))';

commit;
end;
/

CREATE SEQUENCE xs$id_sequence
INCREMENT BY 1
MINVALUE 2147493648 
MAXVALUE 18446744073709551615
CACHE 20
ORDER;

-- IMPORTANT: When creating a new DB role with system privileges, 
-- please also add it to DV "System Privilege and Roles Realm" in catmacd.sql.
 
-- Create provisioner role
create role provisioner;

-- Create role for session privilege grant
create role xs_session_admin;

-- Create role for namespace attribute grant
create role xs_namespace_admin;

-- Create role for mid tier cache update
create role xs_cache_admin;

-- Added from 12.2: create role xs_connect 
create role xs_connect;
grant create session to xs_connect;

-- Create default workspace - 'XS'
-- Raise no error if XS workspace already exists
BEGIN
  insert into xs$workspace(name, type, description) values('XS', 0, 'System workspace');
  insert into xs$tenant(name, description) values('SYSTEM', 'System tenant');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

-- Add seed principals
-- Raise no error if seed prinicipals already exist

-- IMPORTANT: When creating a new RAS role with system privileges, 
-- please also add it to DV "System Privilege and Roles Realm" in catmacd.sql.

declare
RESERVED_ID              NUMBER := 2147483648;
PRIN_XSBYPASS            NUMBER := RESERVED_ID + 983;
PRIN_MIDTIER_AUTH        NUMBER := RESERVED_ID + 984;

PRIN_DBMS_PASSWD         NUMBER := RESERVED_ID + 985;
PRIN_DBMS_AUTH           NUMBER := RESERVED_ID + 986;
PRIN_XSAUTHENTICATED     NUMBER := RESERVED_ID + 987;

PRIN_XSGUEST             NUMBER := RESERVED_ID + 988;
PRIN_XSPUBLIC            NUMBER := RESERVED_ID + 989;
PRIN_XSPROVISIONER       NUMBER := RESERVED_ID + 990;
PRIN_XSSWITCH            NUMBER := RESERVED_ID + 991;
PRIN_EXTERNAL_DBMS_AUTH  NUMBER := RESERVED_ID + 995;

PRIN_XS_SESSION_ADMIN    NUMBER := RESERVED_ID + 992;
PRIN_XS_NAMESPACE_ADMIN  NUMBER := RESERVED_ID + 993;
PRIN_XS_CACHE_ADMIN      NUMBER := RESERVED_ID + 994;
PRIN_XS_DISPATCHER       NUMBER := RESERVED_ID + 996;

DEFAULT_OWNER            VARCHAR2(128) := 'SYS';
DEFAULT_TENANT           VARCHAR2(128) := 'SYSTEM';

begin

--create dynamic role xsauthenticated
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSAUTHENTICATED', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSAUTHENTICATED, 1, 1, 1);

insert into xs$prin(prin#, type, system, ctime, mtime, description) 
values( PRIN_XSAUTHENTICATED, 2, 1,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
        'A dynamic role granted to every authenticated application user');

--create dynamic role dbms_auth
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('DBMS_AUTH', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_DBMS_AUTH, 1, 1, 1);

insert into xs$prin(prin#, type, system, ctime, mtime, description) 
values( PRIN_DBMS_AUTH, 2, 1,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
        'A dynamic role granted to an application user authenticated via direct login to the database');

--create dynamic role dbms_passwd
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('DBMS_PASSWD', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_DBMS_PASSWD, 1, 1, 1);

insert into xs$prin(prin#, type, system, ctime, mtime, description) 
values( PRIN_DBMS_PASSWD, 2, 1,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
        'A dynamic role granted to an application user authenticated via direct login to the database using password');

--create dynamic role midtier_auth
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('MIDTIER_AUTH', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_MIDTIER_AUTH, 1, 1, 1);
insert into xs$prin(prin#, type, system, ctime, mtime, description) 
values( PRIN_MIDTIER_AUTH, 2, 1,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
        'A dynamic role granted to an application user authenticated via middle tier');

--create role xspublic
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSPUBLIC', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSPUBLIC , 1, 1, 1);
insert into xs$prin(prin#, type, enable, ctime, mtime, description)  
values(PRIN_XSPUBLIC , 1, 1,
       systimestamp at time zone '00:00', 
       systimestamp at time zone '00:00',
       'An application role enabled in every application user session');
-- Not needed because dependency on grant to xspublic is removed
-- insert into xs$role_grant(grantee#, role#) values(PRIN_XSPUBLIC , PRIN_XSAUTHENTICATED);
-- insert into xs$role_grant(grantee#, role#) values(PRIN_XSPUBLIC , PRIN_DBMS_AUTH);
-- insert into xs$role_grant(grantee#, role#) values(PRIN_XSPUBLIC , PRIN_DBMS_PASSWD);
-- insert into xs$role_grant(grantee#, role#) values(PRIN_XSPUBLIC , PRIN_MIDTIER_AUTH);

--create user xsguest
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSGUEST', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSGUEST, 1, 1, 1);

insert into xs$prin(prin#, type, ctime, mtime, description) 
values( PRIN_XSGUEST, 0,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
       'A system-defined application user typically reserved for anonymous access');

--create role xsbypass
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSBYPASS', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSBYPASS, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)  
values(PRIN_XSBYPASS, 1, 0,
       systimestamp at time zone '00:00', 
       systimestamp at time zone '00:00',
       'An application role used to bypass the restrictions imposed by system constraining ACL');

-- create role xsprovisioner
insert into xs$obj(name, owner, tenant, id, type, status, flags)
values('XSPROVISIONER', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSPROVISIONER, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)
values(PRIN_XSPROVISIONER, 1, 1,
       systimestamp at time zone '00:00',
       systimestamp at time zone '00:00',
       'An application role used to grant provision and callback privileges');


--create dynamic role XSSWITCH
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSSWITCH', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSSWITCH, 1, 1, 1);

insert into xs$prin(prin#, type, system, ctime, mtime, description)  
values(PRIN_XSSWITCH, 2, 1,
       systimestamp at time zone '00:00', 
       systimestamp at time zone '00:00',
       'An application dynamic role used to indicate that a proxy user was switched to a client user');

-- create role XSSESSIONADMIN
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSSESSIONADMIN', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XS_SESSION_ADMIN, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)  
values(PRIN_XS_SESSION_ADMIN, 1, 1,
       systimestamp at time zone '00:00', 
       systimestamp at time zone '00:00',
       'An application role used for session administration');

-- create role XSNAMESPACEADMIN
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('XSNAMESPACEADMIN', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XS_NAMESPACE_ADMIN, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)  
values(PRIN_XS_NAMESPACE_ADMIN, 1, 1,
       systimestamp at time zone '00:00', 
       systimestamp at time zone '00:00',
       'An application role used for namespace attribute administration');

-- create role XSCACHEADMIN
insert into xs$obj(name, owner, tenant, id, type, status, flags)
values('XSCACHEADMIN', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XS_CACHE_ADMIN, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)
values(PRIN_XS_CACHE_ADMIN, 1, 1,
       systimestamp at time zone '00:00',
       systimestamp at time zone '00:00',
       'An application role used for midtier cache administration');


-- create role XSDISPATCHER
insert into xs$obj(name, owner, tenant, id, type, status, flags)
values('XSDISPATCHER', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XS_DISPATCHER, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)
values(PRIN_XS_DISPATCHER, 1, 1,
       systimestamp at time zone '00:00',
       systimestamp at time zone '00:00',
       'An application role used for dispatcher');

-- Create Dynamic role EXTERNAL_DBMS_AUTH
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
values('EXTERNAL_DBMS_AUTH', DEFAULT_OWNER, DEFAULT_TENANT , PRIN_EXTERNAL_DBMS_AUTH, 1, 1, 1);

insert into xs$prin(prin#, type, system, ctime, mtime, description) 
values( PRIN_EXTERNAL_DBMS_AUTH, 2, 1,
        systimestamp at time zone '00:00', 
        systimestamp at time zone '00:00',
        'A dynamic role enabled in directly logged in external user session');

EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
end;
/

grant xs_cache_admin to XSCACHEADMIN CONTAINER=CURRENT;
grant xs_session_admin to XSSESSIONADMIN CONTAINER=CURRENT;
grant xs_session_admin, xs_cache_admin, xs_namespace_admin to XSDISPATCHER CONTAINER=CURRENT;

commit;

create table rxs$sessions
(
  username                varchar2(128)  not null, /* Light Weight User Name */
  userid                  number(10)     not null,   /* Light Weight User ID */
  userguid                raw(16)                , /* Light Weight User GUID */
  acloid                  number                 ,                 /* ACL ID */
  sid                     raw(16)        not null,/* Light Weight Session ID */
  cookie                  varchar2(1024)         ,                 /* Cookie */
  proxyguid               raw(16)                ,        /* Proxy User GUID */
  creatorid               number(10)     not null,        /* Creator User ID */
  updatorid               number(10)     not null,        /* Updator User ID */
  createtime              timestamp      not null,    /* Session Create time */
  authtime                timestamp      not null,
                                                 /* Last Authentication Time */
  accesstime              timestamp      not null,       /* Last Access Time */
  inactivetimeout         number(6)              ,     /* Inactivity Timeout */
  sessize                 number                 ,           /* Session Size */
  flag                    number                 ,   /* Indicates session modes
                                                 (trusted or secure), created 
                                                 by external principal      */
  proxyid                 number(10)             ,          /* Proxy User ID */
  effstartdate            timestamp              ,
                                                /* Effective User Start Date */
  effenddate              timestamp              ,/* Effective User End Date */
  rgversion               number(10)             ,     /* Role graph version */
  attachversion           number(10)             ,         /* Attach version */
  wspace                  varchar2(128)          ,         /* User Workspace */
  scversion               number(10)             ,/* Security context version */
  scinsid                 number             /* Security context Instance ID */
)
/
create unique index i_rxs$sessions1 on rxs$sessions(cookie)
/

create unique index rxs$sessions_i1 on rxs$sessions(sid)
/

create table rxs$session_roles
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  roleid          number(10)     not null ,                       /* Role ID */
  roleguid        raw(16)        not null ,                     /* Role GUID */
  rolename        varchar2(128)  not null ,                     /* Role Name */
  roleflags       number(10)     not null ,                    /* Role Flags */
  effstartdate    timestamp               ,     /* Effective Role Start Date */
  effenddate      timestamp               ,       /* Effective Role End Date */
  parentid        number(10)              ,                    /* Parent  ID */
  refcount        number(10)              ,                     /* Ref count */
  wspace          varchar2(128)                            /* Role Workspace */
)
/

create index rxs$session_roles_i1 on rxs$session_roles(sid)
/


create table rxs$session_appns
(
  sid                raw(16)        not null ,    /* Light Weight Session ID */
  nsname             varchar2(128)  not null ,             /* Namespace Name */
  attrname           varchar2(4000)          ,             /* Attribute Name */
  nsaclid            number(10)              ,       /* ACL ID for Namespace */
  nshandler          varchar2(400)           ,          /* Namespace Handler */
                               /* nshandler is "schema"."package"."function" */
  nsaudit            number(10)              ,              /* Audit Options */
  flags              number(10)              ,            /* Namespace Flags */
  attrvalue          varchar2(4000)          ,            /* Attribute Value */
  modtime            timestamp               ,          /* Modification time */
  attr_default_value varchar2(4000)          ,    /* Attribute default value */
  wspace             varchar2(128)                    /* Namespace Workspace */
)
/

create index rxs$session_appns_i1 on rxs$session_appns(sid)
/

commit;

-- Seed Security Class and Privileges
-- Raise no error if seeded security classes and privileges already exist
declare

RESERVED_ID                 NUMBER := 2147483648;
SC_DML_PRIV                 NUMBER := RESERVED_ID; 
PRIV_SELECT                 NUMBER := RESERVED_ID + 1;
PRIV_INSERT                 NUMBER := RESERVED_ID + 2; 
PRIV_UPDATE                 NUMBER := RESERVED_ID + 3;  
PRIV_DELETE                 NUMBER := RESERVED_ID + 4;
SC_SYSTEM_SEC               NUMBER := RESERVED_ID + 5;
PRIV_PROVISION              NUMBER := RESERVED_ID + 6; 
PRIV_CALLBACK               NUMBER := RESERVED_ID + 7;  
SC_SESSION_SEC              NUMBER := RESERVED_ID + 8;    
SC_NSTEMPL_SEC              NUMBER := RESERVED_ID + 9; 
SC_ALL                      NUMBER := RESERVED_ID + 10;
PRIV_ALL                    NUMBER := RESERVED_ID + 11;   
ACL_BYPASS                  NUMBER := RESERVED_ID + 12;
ACL_SYSTEM_SC               NUMBER := RESERVED_ID + 13; 
ACL_SESSION_SC              NUMBER := RESERVED_ID + 14;
ACL_NS_UNRESTRICTED         NUMBER := RESERVED_ID + 15;
PRIV_ADMIN_SEC_POLICY       NUMBER := RESERVED_ID + 19;
PRIV_ADMIN_ANY_SEC_POLICY   NUMBER := RESERVED_ID + 20;
PRIV_ADMIN_SESSION          NUMBER := RESERVED_ID + 21;
PRIV_CREATE_SESSION         NUMBER := RESERVED_ID + 22;  
PRIV_TERM_SESSION           NUMBER := RESERVED_ID + 23;   
PRIV_ATTACH_SESSION         NUMBER := RESERVED_ID + 24;
PRIV_MODIFY_SESSION         NUMBER := RESERVED_ID + 25;   
PRIV_ASSIGN_USER            NUMBER := RESERVED_ID + 26;   
PRIV_ADMIN_ANY_NAMESPACE    NUMBER := RESERVED_ID + 27;
PRIV_CREATE_TRUSTED_SESSION NUMBER := RESERVED_ID + 28;
PRIV_MODIFY_NAMESPACE       NUMBER := RESERVED_ID + 29;
PRIV_MODIFY_ATTRIBUTE       NUMBER := RESERVED_ID + 30;
PRIV_ADMIN_NAMESPACE        NUMBER := RESERVED_ID + 31;

NSTEMP_GLOBAL_VAR           NUMBER := RESERVED_ID + 32;

PRIV_APPLY_SEC_POLICY       NUMBER := RESERVED_ID + 33; /* added in 12.2.0.1 */
PRIV_SET_DYNAMIC_ROLES      NUMBER := RESERVED_ID + 34; /* added in 12.2.0.1 */

SC_NETWORK_SEC              NUMBER := RESERVED_ID + 40;
PRIV_RESOLVE                NUMBER := RESERVED_ID + 41;
PRIV_CONNECT                NUMBER := RESERVED_ID + 42;
PRIV_USE_CLIENT_CERTS       NUMBER := RESERVED_ID + 43;
PRIV_USE_PASSWORDS          NUMBER := RESERVED_ID + 44;
PRIV_HTTP                   NUMBER := RESERVED_ID + 45;
PRIV_HTTP_PROXY             NUMBER := RESERVED_ID + 46;
PRIV_SMTP                   NUMBER := RESERVED_ID + 47;
PRIV_JDWP                   NUMBER := RESERVED_ID + 48;

PRIN_MIDTIER_AUTH           NUMBER := RESERVED_ID + 984;
PRIN_XSPUBLIC               NUMBER := RESERVED_ID + 989;
PRIN_XSPROVISIONER          NUMBER := RESERVED_ID + 990;
PRIN_XS_SESSION_ADMIN       NUMBER := RESERVED_ID + 992;
PRIN_XS_NAMESPACE_ADMIN     NUMBER := RESERVED_ID + 993;
PRIN_XSCONNECT              NUMBER := RESERVED_ID + 997;
PRIN_DBPROVISIONER          NUMBER;
PRIN_DBA_ROLE               NUMBER;
PRIN_RESOURCE_ROLE          NUMBER;
PRIN_SESSION_ADMIN_ROLE     NUMBER;
PRIN_NAMESPACE_ADMIN_ROLE   NUMBER;

DEFAULT_OWNER            VARCHAR2(128) := 'SYS';
DEFAULT_TENANT           VARCHAR2(128) := 'SYSTEM';
PRIN_DB_PUBLIC           CONSTANT PLS_INTEGER := 1;
begin

begin
-- Create DML Privileges Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('DML', DEFAULT_OWNER, DEFAULT_TENANT, SC_DML_PRIV,2,1,1);

insert into xs$seccls values (SC_DML_PRIV,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'DML Privileges Security Class');

-- Create select Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SELECT', DEFAULT_OWNER, DEFAULT_TENANT, PRIV_SELECT,4,1,1);

insert into xs$priv values (PRIV_SELECT,SC_DML_PRIV,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Select Privilege');

-- Create insert Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('INSERT', DEFAULT_OWNER, DEFAULT_TENANT, PRIV_INSERT,4,1,1);

insert into xs$priv values (PRIV_INSERT,SC_DML_PRIV,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Insert Privilege');

-- Create update Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('UPDATE', DEFAULT_OWNER, DEFAULT_TENANT, PRIV_UPDATE,4,1,1);

insert into xs$priv values (PRIV_UPDATE,SC_DML_PRIV,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Update Privilege');

-- Create delete Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('DELETE', DEFAULT_OWNER, DEFAULT_TENANT, PRIV_DELETE,4,1,1);

insert into xs$priv values (PRIV_DELETE,SC_DML_PRIV,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Delete Privilege');

-- Create default ACL for System Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SYSTEMACL', DEFAULT_OWNER, DEFAULT_TENANT, 
                   ACL_SYSTEM_SC, 3, 1, 1);

-- Create System Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SYSTEM', DEFAULT_OWNER, DEFAULT_TENANT, SC_SYSTEM_SEC,2,1,1);

insert into xs$seccls values (SC_SYSTEM_SEC,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'System Security Class');

-- Make SYSTEM security class inherited from DML security class
insert into xs$seccls_h values(SC_SYSTEM_SEC, SC_DML_PRIV);

-- Create xsProvision Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('PROVISION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_PROVISION,4,1,1);  

insert into xs$priv values (PRIV_PROVISION,SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                        'Privilege for updating principal documents from FIDM');

-- Create xsCallback Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('CALLBACK', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_CALLBACK,4,1,1);

insert into xs$priv values (PRIV_CALLBACK,SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to register and update event handlers');

-- default ACL for System Security Class
insert into xs$acl values (ACL_SYSTEM_SC,SC_SYSTEM_SEC,null,0,
                           systimestamp at time zone '00:00',
                           systimestamp at time zone '00:00',
                          'Default ACL for System Security Class');

insert into xs$ace values (ACL_SYSTEM_SC,1,1,0,2,0,null,null,3);

insert into xs$ace values (ACL_SYSTEM_SC,2,1,PRIN_XSPROVISIONER,1,0,null,null,3);

select user# into PRIN_DBPROVISIONER from user$ where NAME = 'PROVISIONER';

insert into xs$ace values (ACL_SYSTEM_SC,3,1,PRIN_DBPROVISIONER,2,0,null,null,3);

/* xsProvision Privilege */
insert into xs$ace_priv values (ACL_SYSTEM_SC,1,PRIV_PROVISION);
insert into xs$ace_priv values (ACL_SYSTEM_SC,2,PRIV_PROVISION);
insert into xs$ace_priv values (ACL_SYSTEM_SC,3,PRIV_PROVISION);

/* xsCallback Privilege */
insert into xs$ace_priv values (ACL_SYSTEM_SC,1,PRIV_CALLBACK);
insert into xs$ace_priv values (ACL_SYSTEM_SC,2,PRIV_CALLBACK);
insert into xs$ace_priv values (ACL_SYSTEM_SC,3,PRIV_CALLBACK);

-- Create All Privileges Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ALL', DEFAULT_OWNER, DEFAULT_TENANT, SC_ALL,2,1,1);

insert into xs$seccls values (SC_ALL,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'All Security Class');

-- Create All Privileges
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ALL', DEFAULT_OWNER, DEFAULT_TENANT, PRIV_ALL,4,1,1);
-- ALL privilege is a special privilege (sc = null)that serves like a wildcard 
-- to imply all the privileges in the corresponding ACL's security class.
insert into xs$priv values (PRIV_ALL,null,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'All Privileges');

-- Create 'ADMIN_ANY_SEC_POLICY' Privileges - in SYSTEM security class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ADMIN_ANY_SEC_POLICY', DEFAULT_OWNER, DEFAULT_TENANT, 
                    PRIV_ADMIN_ANY_SEC_POLICY, 4, 1, 1);

insert into xs$priv values (PRIV_ADMIN_ANY_SEC_POLICY, SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege for any administrative operation');

-- Create 'ADMIN_SEC_POLICY' Privileges  - in SYSTEM security class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ADMIN_SEC_POLICY', DEFAULT_OWNER, DEFAULT_TENANT, 
                    PRIV_ADMIN_SEC_POLICY, 4, 1 ,1);

insert into xs$priv values (PRIV_ADMIN_SEC_POLICY, SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege for administering objects under a particular schema');
--'ADMIN_SEC_POLICY' is an aggregate privilege of "SELECT", "INSERT", "UPDATE",
-- "DELETE"
insert into xs$aggr_priv values (SC_SYSTEM_SEC,PRIV_ADMIN_SEC_POLICY,PRIV_SELECT);
insert into xs$aggr_priv values (SC_SYSTEM_SEC,PRIV_ADMIN_SEC_POLICY,PRIV_INSERT);
insert into xs$aggr_priv values (SC_SYSTEM_SEC,PRIV_ADMIN_SEC_POLICY,PRIV_UPDATE);
insert into xs$aggr_priv values (SC_SYSTEM_SEC,PRIV_ADMIN_SEC_POLICY,PRIV_DELETE);

-- Grant DBA role ADMIN_ANY_SEC_POLICY privilege
select user# into PRIN_DBA_ROLE from user$ where NAME = 'DBA';
insert into xs$ace values (ACL_SYSTEM_SC,4,1,PRIN_DBA_ROLE,2,0,null,null,3);
insert into xs$ace_priv values (ACL_SYSTEM_SC,4,PRIV_ADMIN_ANY_SEC_POLICY);

--Create privilege ADMIN_ANY_NAMESPACE and add to SYSTEM Security class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ADMIN_ANY_NAMESPACE', 'SYS', DEFAULT_TENANT, 
                   PRIV_ADMIN_ANY_NAMESPACE,4,1,1); 

insert into xs$priv values (PRIV_ADMIN_ANY_NAMESPACE, SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege for administering any namespace');

--Grant ADMIN_ANY_NAMESPACE Privilege to DBA, XSNAMESPACEADMIN, XS_NAMESPACE_ADMIN, 
-- and MIDTIER_AUTH
select user# into PRIN_NAMESPACE_ADMIN_ROLE from user$ where name = 'XS_NAMESPACE_ADMIN';
insert into xs$ace values (ACL_SYSTEM_SC,7,1,PRIN_DBA_ROLE,2,0,null,null,3);
insert into xs$ace values (ACL_SYSTEM_SC,8,1,PRIN_NAMESPACE_ADMIN_ROLE,2,0,null,null,3);
insert into xs$ace values (ACL_SYSTEM_SC,9,1,PRIN_XS_NAMESPACE_ADMIN,1,0,null,null,3);
insert into xs$ace values (ACL_SYSTEM_SC,10,1,PRIN_MIDTIER_AUTH,1,0,null,null,3);
insert into xs$ace_priv values (ACL_SYSTEM_SC,7,PRIV_ADMIN_ANY_NAMESPACE);
insert into xs$ace_priv values (ACL_SYSTEM_SC,8,PRIV_ADMIN_ANY_NAMESPACE);
insert into xs$ace_priv values (ACL_SYSTEM_SC,9,PRIV_ADMIN_ANY_NAMESPACE);
insert into xs$ace_priv values (ACL_SYSTEM_SC,10,PRIV_ADMIN_ANY_NAMESPACE);

-----------------------------------------------------------------------
-- SESSION privileges and default ACL
-----------------------------------------------------------------------
-- Create SESSION Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SESSION_SC', DEFAULT_OWNER, DEFAULT_TENANT, SC_SESSION_SEC,2,1,1);

-- Create default ACL for session security class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SESSIONACL', DEFAULT_OWNER, DEFAULT_TENANT, 
                   ACL_SESSION_SC, 3, 1, 1);

insert into xs$acl values (ACL_SESSION_SC,SC_SESSION_SEC,null,0,
                           systimestamp at time zone '00:00',
                           systimestamp at time zone '00:00',
                          'Default ACL for Session Security Class');

insert into xs$seccls values (SC_SESSION_SEC,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'Session Security Class');

-- Session privileges
-- Create createSession Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('CREATE_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_CREATE_SESSION,4,1,1);

insert into xs$priv values (PRIV_CREATE_SESSION,SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to create a light weight user session');
 
-- Create termSession Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('TERMINATE_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_TERM_SESSION,4,1,1);

insert into xs$priv values (PRIV_TERM_SESSION,SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to terminate a light weight user session'
);
 
-- Create attachToSession Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ATTACH_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_ATTACH_SESSION,4,1,1);

insert into xs$priv values (PRIV_ATTACH_SESSION,SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to attach to a light weight user session'
);

-- Create modifySession Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('MODIFY_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_MODIFY_SESSION,4,1,1);

insert into xs$priv values (PRIV_MODIFY_SESSION,SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to modify contents of a light weight user session');

-- Create assignUser Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ASSIGN_USER', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_ASSIGN_USER,4,1,1);

insert into xs$priv values (PRIV_ASSIGN_USER,SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to assign user to an anonymous light weight user session');

-- Create create_trusted_session Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('CREATE_TRUSTED_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_CREATE_TRUSTED_SESSION,4,1,1);

insert into xs$priv values (PRIV_CREATE_TRUSTED_SESSION, SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to create a trusted light weight user session');


-- Create aggregate privilege for session administration
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ADMINISTER_SESSION', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_ADMIN_SESSION,4,1,1);  

insert into xs$priv values (PRIV_ADMIN_SESSION, SC_SESSION_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                           'Privilege for session administration');

-- Add privileges to session admin aggregate privilege
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_CREATE_SESSION);
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_ATTACH_SESSION);
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_TERM_SESSION);
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_MODIFY_SESSION);
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_ASSIGN_USER);

-- Grant ADMINISTER_SESSION to XSSESSIONADMIN and XS_SESSION_ADMIN
select user# into PRIN_SESSION_ADMIN_ROLE from user$ where NAME = 'XS_SESSION_ADMIN';
insert into xs$ace values (ACL_SESSION_SC,1,1,PRIN_SESSION_ADMIN_ROLE,2,0,null,null,3);
insert into xs$ace values (ACL_SESSION_SC,2,1,PRIN_XS_SESSION_ADMIN,1,0,null,null,3);
insert into xs$ace_priv values (ACL_SESSION_SC,1,PRIV_ADMIN_SESSION);
insert into xs$ace_priv values (ACL_SESSION_SC,2,PRIV_ADMIN_SESSION);

-----------------------------------------------------------------------
-- NAMESPACE privileges and system ACL
-----------------------------------------------------------------------
-- Create Namespace Template Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('NSTEMPLATE_SC', DEFAULT_OWNER, DEFAULT_TENANT, 
                   SC_NSTEMPL_SEC,2,1,1);

insert into xs$seccls values (SC_NSTEMPL_SEC,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'Namespace Template Security Class');

-- MODIFY Namespace privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('MODIFY_NAMESPACE', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_MODIFY_NAMESPACE,4,1,1);

insert into xs$priv values (PRIV_MODIFY_NAMESPACE,SC_NSTEMPL_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Modify Namespace Privilege');

-- Modify Attribute privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('MODIFY_ATTRIBUTE', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_MODIFY_ATTRIBUTE,4,1,1);

insert into xs$priv values (PRIV_MODIFY_ATTRIBUTE,SC_NSTEMPL_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Modify Attribute Privilege');

-- Create aggregate privileges for namespace administration
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('ADMIN_NAMESPACE', 'SYS', DEFAULT_TENANT, 
                   PRIV_ADMIN_NAMESPACE,4,1,1); 

insert into xs$priv values (PRIV_ADMIN_NAMESPACE, SC_NSTEMPL_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege for namespace administration');

-- Add privileges to namespace admin aggregate privilege
insert into xs$aggr_priv values (SC_NSTEMPL_SEC,PRIV_ADMIN_NAMESPACE,PRIV_MODIFY_NAMESPACE);
insert into xs$aggr_priv values (SC_NSTEMPL_SEC,PRIV_ADMIN_NAMESPACE,PRIV_MODIFY_ATTRIBUTE);

--Create NS_UNRESTRICTED_ACL on SYS
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('NS_UNRESTRICTED_ACL', 'SYS', DEFAULT_TENANT, 
                   ACL_NS_UNRESTRICTED, 3, 1, 1);

insert into xs$acl values (ACL_NS_UNRESTRICTED,SC_NSTEMPL_SEC,null,0,
                           systimestamp at time zone '00:00',
                           systimestamp at time zone '00:00',
                          'Seeded ACL to grant ADMIN_NAMESPACE privilege to PUBLIC');

insert into xs$ace values (ACL_NS_UNRESTRICTED,1,1,PRIN_DB_PUBLIC, 2,0,null,null,3);
insert into xs$ace values (ACL_NS_UNRESTRICTED,2,1,PRIN_XSPUBLIC,1,0,null,null,3);
insert into xs$ace_priv values (ACL_NS_UNRESTRICTED,1,PRIV_ADMIN_NAMESPACE);
insert into xs$ace_priv values (ACL_NS_UNRESTRICTED,2,PRIV_ADMIN_NAMESPACE);

-- created seeded name space template KZX_NSTEMP_GLONAL_VAR with NLS parameters
insert into xs$obj(name, owner, tenant, ws, id, type, status, flags)
           values('XS$GLOBAL_VAR',DEFAULT_OWNER, DEFAULT_TENANT, 'XS', NSTEMP_GLOBAL_VAR, 7,1,1);

insert into xs$nstmpl(ns#, acl#, ctime, mtime, description) 
            values (NSTEMP_GLOBAL_VAR, ACL_NS_UNRESTRICTED, systimestamp at time zone '00:00',
                   systimestamp at time zone '00:00',  'The seeded GLOBAL_VAR namespace template.');

insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_LANGUAGE');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_TERRITORY');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_SORT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_DATE_LANGUAGE');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_DATE_FORMAT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_CURRENCY');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_NUMERIC_CHARACTERS');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_ISO_CURRENCY');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_CALENDAR');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_TIME_FORMAT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_TIMESTAMP_FORMAT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_TIME_TZ_FORMAT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_TIMESTAMP_TZ_FORMAT');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_DUAL_CURRENCY');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_COMP');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_LENGTH_SEMANTICS');
insert into xs$nstmpl_attr (ns#, attr_name)  values (NSTEMP_GLOBAL_VAR, 'NLS_NCHAR_CONV_EXCP');


-----------------------------------------------------------------------
-- Network ACL security class and privileges
-----------------------------------------------------------------------
-- Create Network Security Class
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('NETWORK_SC', DEFAULT_OWNER, DEFAULT_TENANT, 
                   SC_NETWORK_SEC,2,1,1);

insert into xs$seccls values (SC_NETWORK_SEC,
                              systimestamp at time zone '00:00', 
                              systimestamp at time zone '00:00',
                              'Network Security Class');


-- Add privileges to network security class
-- Create resolve privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('RESOLVE', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_RESOLVE,4,1,1);

insert into xs$priv values (PRIV_RESOLVE,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to resolve a network host name or address');

-- Create connect privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('CONNECT', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_CONNECT,4,1,1);
                  
insert into xs$priv values (PRIV_CONNECT,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to open a connection to a network host');

-- Create use_client_certificates privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('USE_CLIENT_CERTIFICATES', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_USE_CLIENT_CERTS,4,1,1);
                  
insert into xs$priv values (PRIV_USE_CLIENT_CERTS,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to use client certificates in a wallet');

-- Create use_passwords privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('USE_PASSWORDS', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_USE_PASSWORDS,4,1,1);
                  
insert into xs$priv values (PRIV_USE_PASSWORDS,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to use password credentials in a wallet');

-- Create http privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('HTTP', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_HTTP,4,1,1);
                  
insert into xs$priv values (PRIV_HTTP,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to make a HTTP request to a host');

-- Create http_proxy privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('HTTP_PROXY', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_HTTP_PROXY,4,1,1);
                  
insert into xs$priv values (PRIV_HTTP_PROXY,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to make a HTTP request via a proxy');

-- Create smtp privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('SMTP', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_SMTP,4,1,1);

insert into xs$priv values (PRIV_SMTP,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to send SMTP to a host');

-- Create jdwp privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags) 
            values('JDWP', DEFAULT_OWNER, DEFAULT_TENANT, 
                   PRIV_JDWP,4,1,1);

insert into xs$priv values (PRIV_JDWP,SC_NETWORK_SEC,
                            systimestamp at time zone '00:00', 
                            systimestamp at time zone '00:00',
                            'Privilege to connect to a JDWP debugger at a host');
commit;

EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
 END IF;
end;

/*****************************************************************************/
/*   If you add new seeded objects across releases, start a new transaction  */
/*   to add them.                                                            */
/*                                                                           */
/*   Add 12.2.0.1 new seeded objects here.                                   */
/*****************************************************************************/
begin
-- Create 'APPLY_SEC_POLICY' Privileges  - in SYSTEM security class
insert into xs$obj(name, owner, tenant, id, type, status, flags)
            values('APPLY_SEC_POLICY', DEFAULT_OWNER, DEFAULT_TENANT,
                    PRIV_APPLY_SEC_POLICY, 4, 1 ,1);

insert into xs$priv values (PRIV_APPLY_SEC_POLICY, SC_SYSTEM_SEC,
                            systimestamp at time zone '00:00',
                            systimestamp at time zone '00:00',
                            'Privilege for enforcing policies');


-- Create set_dynamic_role Privilege
insert into xs$obj(name, owner, tenant, id, type, status, flags)
            values('SET_DYNAMIC_ROLES', DEFAULT_OWNER, DEFAULT_TENANT,
                   PRIV_SET_DYNAMIC_ROLES,4,1,1);

insert into xs$priv values (PRIV_SET_DYNAMIC_ROLES, SC_SESSION_SEC,
                            systimestamp at time zone '00:00',
                            systimestamp at time zone '00:00',
                           'Privilege to enable or disable dynamic roles in session');
insert into xs$aggr_priv values (SC_SESSION_SEC,PRIV_ADMIN_SESSION,PRIV_SET_DYNAMIC_ROLES);

--create role XSCONNECT
insert into xs$obj(name, owner, tenant, id, type, status, flags)                
values('XSCONNECT', DEFAULT_OWNER, DEFAULT_TENANT, PRIN_XSCONNECT, 1, 1, 1);

insert into xs$prin(prin#, type, enable, ctime, mtime, description)
values(PRIN_XSCONNECT, 1, 1,
       systimestamp at time zone '00:00',
       systimestamp at time zone '00:00',
       'An application role used to grant create session privilege to RAS direct logon user');

commit;

EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
 END IF;
end;
/*****************************************************************************/
/*   Add new seeded objects in a future release here.                        */
/*****************************************************************************/

end;
/
show errors;

/* Added from 12.2 */
grant xs_connect to XSCONNECT CONTAINER=CURRENT;
commit;

-- XS$CACHE_ACTIONS used by Mid-Tier Cache
create table SYS.XS$CACHE_ACTIONS
  (
   ROW_KEY NUMBER(1) UNIQUE,
   TIME_VAL TIMESTAMP(9) NOT NULL
  );
comment on table SYS.XS$CACHE_ACTIONS is
'Timestamps used for Mid-Tier-Cache object invalidation'
/
comment on column SYS.XS$CACHE_ACTIONS.ROW_KEY is
'Type of the TimeStamp value.'
/
comment on column SYS.XS$CACHE_ACTIONS.TIME_VAL is
'Timestamp associated with this key'
/
create or replace public synonym XS$CACHE_ACTIONS for SYS.XS$CACHE_ACTIONS;

Rem add seed values for this table
-- Raise no error if seeded values already exist
BEGIN
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (5, systimestamp);
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (6, systimestamp);
-- The frasec field is used as retension  time. Set to 1 week 
-- Fix bug 7331368
insert into SYS.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) 
                         values (9, TIMESTAMP '2007-10-04 13:02:43.000010080');

EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -00001 THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

Rem now create the Delete table
Rem OBJ_TYPE  will reflect one of the above values
Rem check kzxh.h, KZXHACLMOD, etc for ObJ_TYPE values
create table SYS.XS$CACHE_DELETE
  (
   OBJ_TYPE   NUMBER(2),
   ID NUMBER,
   DEL_DATE TIMESTAMP NOT NULL
  );
comment on table SYS.XS$CACHE_DELETE is
'Table to retain deleted ACLOIDs, SecurityClasses, roles etc'
/
comment on column SYS.XS$CACHE_DELETE.OBJ_TYPE is
'Column to store type of the object deleted'
/
comment on column SYS.XS$CACHE_DELETE.ID is
'Column to store deleted ID'
/
comment on column SYS.XS$CACHE_DELETE.DEL_DATE is
'Column to store the dates of the deleted objects'
/
create or replace public synonym XS$CACHE_DELETE for SYS.XS$CACHE_DELETE;
/

Rem
Rem Create the XS$NULL user. This user represents the state where DB UID
Rem is invalid but the schema ID is valid. Currently used by Fusion since 11gR1
Rem
create user XS$NULL identified by values
'S:000000000000000000000000000000000000000000000000000000000000'
account lock password expire default tablespace system
/

Rem Create Triton Security views
@@rxsviews.sql

Rem Grant privileges to XS_CACHE_ADMIN
grant select on sys.XS$ACE to xs_cache_admin;
grant select on sys.XS$ACE_PRIV to xs_cache_admin;
grant select on sys.XS$ACL to xs_cache_admin;
grant select on sys.XS$AGGR_PRIV to xs_cache_admin;
grant select on sys.XS$OBJ to xs_cache_admin;
grant select on sys.XS$PRIN to xs_cache_admin;
grant select on sys.XS$PRIV to xs_cache_admin;
grant select on sys.XS$SECCLS to xs_cache_admin;
grant select on sys.XS$SECCLS_H to xs_cache_admin;
grant select on sys.XS$CACHE_ACTIONS to xs_cache_admin;
grant select on sys.XS$CACHE_DELETE to xs_cache_admin;
grant select on sys.rxs$sessions to xs_cache_admin;
grant select on sys.dba_xs_session_roles to xs_cache_admin;

Rem Create pre-seeded audit policies

BEGIN
  EXECUTE IMMEDIATE 'CREATE AUDIT POLICY ORA_RAS_POLICY_MGMT
  ACTIONS component=XS CREATE USER, UPDATE USER, DELETE USER, CREATE ROLE, 
  UPDATE ROLE, DELETE ROLE, GRANT ROLE, REVOKE ROLE, ADD PROXY, REMOVE PROXY, 
  SET USER PASSWORD, SET USER VERIFIER, CREATE ROLESET, UPDATE ROLESET, 
  DELETE ROLESET, CREATE SECURITY CLASS, UPDATE SECURITY CLASS, 
  DELETE SECURITY CLASS, CREATE NAMESPACE TEMPLATE, UPDATE NAMESPACE TEMPLATE, 
  DELETE NAMESPACE TEMPLATE, CREATE ACL, UPDATE ACL, DELETE ACL, 
  CREATE DATA SECURITY, UPDATE DATA SECURITY, DELETE DATA SECURITY, 
  ENABLE DATA SECURITY, DISABLE DATA SECURITY, ADD GLOBAL CALLBACK, 
  DELETE GLOBAL CALLBACK, ENABLE GLOBAL CALLBACK, SET USER PROFILE, 
  GRANT SYSTEM PRIVILEGE, REVOKE SYSTEM PRIVILEGE';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -46358 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE AUDIT POLICY ORA_RAS_SESSION_MGMT 
  ACTIONS component=XS CREATE SESSION, DESTROY SESSION, ENABLE ROLE, 
  DISABLE ROLE, SET COOKIE, SET INACTIVE TIMEOUT, SWITCH USER, ASSIGN USER, 
  CREATE SESSION NAMESPACE, DELETE SESSION NAMESPACE, 
  CREATE NAMESPACE ATTRIBUTE, GET NAMESPACE ATTRIBUTE, SET NAMESPACE ATTRIBUTE, 
  DELETE NAMESPACE ATTRIBUTE';
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -46358 THEN NULL; ELSE RAISE; END IF;
END;
/

@?/rdbms/admin/sqlsessend.sql
