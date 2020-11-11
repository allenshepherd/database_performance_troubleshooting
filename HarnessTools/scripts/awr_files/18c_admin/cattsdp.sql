Rem
Rem $Header: rdbms/admin/cattsdp.sql /main/5 2014/02/20 12:45:53 surman Exp $
Rem
Rem cattsdp.sql
Rem
Rem Copyright (c) 2011, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cattsdp.sql - Catalog tables for TSDP
Rem
Rem    DESCRIPTION
Rem      This file will create the catalog tables required for Transparent
Rem      Sensitive Data Protection
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cattsdp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cattsdp.sql
Rem SQL_PHASE: CATTSDP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: ORA-00955
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    dgraj       03/19/12 - ER 13485095: Add tsdp_error$ table
Rem    dgraj       03/13/12 - LRG 6796184: specify level# during registration
Rem                           in impcalloutreg$
Rem    dgraj       09/16/11 - Proj 32079, Transparent Sensitive Data
Rem                           Protection
Rem    dgraj       09/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create table tsdp_source$ (
  source#             number not null,
  name                varchar2(128),
  type                number,                                   /* bit flags */
  ts                  timestamp,
  constraint tsdp_source$pk primary key (source#),
  constraint tsdp_source$uk unique (name, type)
)
/

comment on table tsdp_source$ is
'Stores the Discovery source information'
/

comment on column tsdp_source$.source# is 
'Dictionary number of the source'
/

comment on column tsdp_source$.name is
'Name of the source'
/

comment on column tsdp_source$.type is
'The type of the source - ADM or DB'
/

comment on column tsdp_source$.ts is
'Timestamp when the entry was made'
/

grant select on tsdp_source$ to select_catalog_role
/

grant select on tsdp_sensitive_data$ to select_catalog_role
/

create table tsdp_sensitive_type$ (
  type#               number not null,
  name                varchar2(128),
  user_comment        varchar2(4000),
  source#             number,
  constraint tsdp_sensitive_type$pk primary key (type#),
  constraint tsdp_sensitive_type$fk foreign key (source#) references
             tsdp_source$(source#) on delete cascade,
  constraint tsdp_sensitive_type$uk unique (name)
)
/

comment on table tsdp_sensitive_type$ is
'Stores the Sensitive Type information'
/

comment on column tsdp_sensitive_type$.type# is
'Dictionary number of the Sensitive Type'
/

comment on column tsdp_sensitive_type$.name is
'Name of the sensitive type'
/

comment on column tsdp_sensitive_type$.user_comment is
'User comment on the sensitive type'
/

comment on column tsdp_sensitive_type$.source# is
'Dictionary number of the source of truth for the Sensitive type'
/

grant select on tsdp_sensitive_type$ to select_catalog_role
/

create table tsdp_policy$ (
 policy#            number not null,
 name               varchar2(128), 
 sec_feature        number not null,
 constraint tsdp_policy$pk primary key (policy#),
 constraint tsdp_policy$uk unique (name)
)
/

comment on table tsdp_policy$ is 
'Stores TSDP policy information'
/

comment on column tsdp_policy$.policy# is 
'Dictionary number of the policy'
/

comment on column tsdp_policy$.name is 
'Name of the policy'
/

comment on column tsdp_policy$.sec_feature is
'The security feature associated with the policy'
/

grant select on tsdp_policy$ to select_catalog_role
/

create table tsdp_subpol$ (
  subpol#           number not null,
  policy#           number not null,
  subpolnum         number not null, 
  property          number,                            /* Default condition? */
  constraint tsdp_subpol$pk primary key (subpol#),
  constraint tsdp_subpol$fk foreign key (policy#) references
             tsdp_policy$(policy#) on delete cascade
)
/

comment on table tsdp_subpol$ is 
'Stores Subpolicy information'
/

comment on column tsdp_subpol$.subpol# is 
'Dictionary number of the subpolicy'
/

comment on column tsdp_subpol$.policy# is
'Dictionary number of the parent policy'
/

comment on column tsdp_subpol$.subpolnum is
'The subpolicy number for the policy'
/

comment on column tsdp_subpol$.property is
'Property of the subpolicy - is it a default subpolicy ?'
/

grant select on tsdp_subpol$ to select_catalog_role
/

create table tsdp_condition$ (
 subpol#            number not null,
 property           varchar2(128),
 value              varchar2(128),
 constraint tsdp_condition$fk foreign key (subpol#) references
             tsdp_subpol$(subpol#) on delete cascade
)
/

comment on table tsdp_condition$ is
'Stores conditons for subpolicies'
/

comment on column tsdp_condition$.subpol# is 
'The dictionary number of the parent subpolicy'
/

comment on column tsdp_condition$.property is 
'The property of the condition'
/

comment on column tsdp_condition$.value is 
'The value of the condition'
/

grant select on tsdp_condition$ to select_catalog_role
/

create table tsdp_parameter$ (
 subpol#           number not null,
 parameter         varchar2(128),
 value             varchar2(4000),
 constraint tsdp_parameter$fk foreign key (subpol#) references
             tsdp_subpol$(subpol#) on delete cascade
)
/

comment on table tsdp_parameter$ is 
'Stores subpolicy parameter information'
/

comment on column tsdp_parameter$.subpol# is 
'The dictionary number of the parent subpolicy'
/

comment on column tsdp_parameter$.parameter is
'The parameter for the subpolicy'
/

comment on column tsdp_parameter$.value is 
'The value of the parameter'
/

grant select on tsdp_parameter$ to select_catalog_role
/

create table tsdp_association$ (
 association#      number not null,
 policy#           number not null,
 sensitive_type#   number not null,
 constraint tsdp_association$pk primary key (association#),
 constraint tsdp_association$fkst foreign key (sensitive_type#) references
             tsdp_sensitive_type$(type#) on delete cascade,
 constraint tsdp_association$fkpo foreign key (policy#) references
             tsdp_policy$(policy#) on delete cascade
)
/

comment on table tsdp_association$ is 
'Stores Sensitive Type - Policy association information'
/

comment on column tsdp_association$.association# is
'Dictionary number for the association'
/

comment on column tsdp_association$.policy# is
'Dictionary number of the policy'
/

comment on column tsdp_association$.sensitive_type# is
'Dictionary number of the Sensitive Type'
/

grant select on tsdp_association$ to select_catalog_role
/

create table tsdp_protection$ (
 protection#       number not null,
 sensitive#        number not null,
 subpol#           number not null,
 feature_polname   varchar2(128),
   /* 0x0001 - Policy enabled on the column */
 constraint tsdp_protection$pk primary key (protection#),
 constraint tsdp_protection$fksd foreign key (sensitive#) references
             tsdp_sensitive_data$(sensitive#) on delete cascade,
 constraint tsdp_protection$fkpc foreign key (subpol#) references
             tsdp_subpol$(subpol#) on delete cascade
)
/

comment on table tsdp_protection$ is
'Stores the sensitive column protection information'
/

comment on column tsdp_protection$.protection# is
'Dictionary number for the protection'
/

comment on column tsdp_protection$.sensitive# is
'Dictionary number for the sensitive data'
/

comment on column tsdp_protection$.subpol# is
'Dictionary number of the subpolicy responsible for the protection'
/

comment on column tsdp_protection$.feature_polname is
'Name of the policy for the underlying security feature'
/

grant select on tsdp_protection$ to select_catalog_role
/

create table tsdp_feature_policy$ (
  obj#              number not null,
  feature_polname   varchar2(128),
  sec_feature       number not null,
  constraint tsdp_feature_policy$pk primary key (obj#, feature_polname)
)
/

comment on table tsdp_feature_policy$ is 
'Infomration regarding the security feature policy enabled on the object'
/

comment on column tsdp_feature_policy$.obj# is
'Dictionary number of the object'
/

comment on column tsdp_feature_policy$.feature_polname is
'Policy name of the underlying securit feature'
/

comment on column tsdp_feature_policy$.sec_feature is
'The security feature enabled on the object'
/

grant select on tsdp_feature_policy$ to select_catalog_role
/

create table tsdp_error$ (
  errcode          number not null,
  identifier1      varchar2(128),
  identifier2      varchar2(128),
  identifier3      varchar2(128),
  identifier4      varchar2(128),
  add_info1        varchar2(4000),
  add_info2        varchar2(4000)
)
/

comment on table tsdp_error$ is
'Contains additional data regarding error thrown during execution'
/

comment on column tsdp_error$.errcode is
'The ORA error code'
/

comment on column tsdp_error$.identifier1 is
'Column to hold an identifier name'
/

comment on column tsdp_error$.identifier2 is
'Column to hold an identifier name'
/

comment on column tsdp_error$.identifier3 is
'Column to hold an identifier name'
/

comment on column tsdp_error$.identifier4 is
'Column to hold an identifier name'
/

comment on column tsdp_error$.add_info1 is
'Column to hold additional information'
/

comment on column tsdp_error$.add_info2 is
'Column to hold additional information'
/

grant select on tsdp_error$ to select_catalog_role
/

create sequence tsdp_sensitive$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_source$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_type$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_policy$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_subpol$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_association$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_protection$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/

create sequence tsdp_polname$sequence
   START WITH 1
   INCREMENT BY 1
   CACHE 20
   NOCYCLE
/ 

Rem Create TSDP views
@@tsdpviews.sql

Rem delete TSDP entries from impcalloutreg$ to ensure idempotent behavior
delete from sys.impcalloutreg$ where tag = 'TSDP';

Rem Make impcalloutreg$ entries for TSDP.
Rem LRG 6796184: Specify level# to ensure correct order of import.

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 1, 0,
   'SYS', 'TSDP_SENSITIVE_DATA$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 2, 0,
   'SYS', 'TSDP_SENSITIVE_TYPE$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 3, 0,
   'SYS', 'TSDP_SOURCE$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 4, 0,
   'SYS', 'TSDP_POLICY$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 5, 0,
   'SYS', 'TSDP_SUBPOL$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags, 
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 6, 0, 
   'SYS', 'TSDP_CONDITION$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags, 
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 7, 0, 
   'SYS', 'TSDP_PARAMETER$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags, 
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 8, 0, 
   'SYS', 'TSDP_ASSOCIATION$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags, 
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 9, 0, 
   'SYS', 'TSDP_PROTECTION$', 2 /*table*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 10, 0,
   'SYS', 'DBA_TSDP_POLICY_PROTECTION', 4 /*view*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 11, 0,
   'SYS', 'DBA_SENSITIVE_DATA', 4 /*view*/, 'TSDP tables');

insert into sys.impcalloutreg$
  (package, schema, tag, class, level#, flags,
   tgt_schema, tgt_object, tgt_type, cmnt)
values
  ('TSDP$DATAPUMP','SYS', 'TSDP', 3, 12, 0,
   'SYS', 'TSDP_FEATURE_POLICY$', 2 /*table*/, 'TSDP tables');


@?/rdbms/admin/sqlsessend.sql
