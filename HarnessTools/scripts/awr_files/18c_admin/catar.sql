Rem
Rem $Header: rdbms/admin/catar.sql /main/9 2014/12/11 22:46:34 skayoor Exp $
Rem
Rem catar.sql
Rem
Rem Copyright (c) 1998, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catar.sql - catalog for application role
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for application role
Rem
Rem    NOTES
Rem      Must be run while connected to SYS
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catar.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catar.sql
Rem SQL_PHASE: CATAR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    dmwong      03/11/01 - fix missing and's.
Rem    dmwong      03/01/01 - rename dict vws to be consistent with the rest.
Rem    dmwong      01/15/01 - add comments to columns.
Rem    dmwong      12/19/00 - add public synonyms.
Rem    dmwong      09/22/98 - catalog view for application role                
Rem    dmwong      09/22/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace view DBA_APPLICATION_ROLES
(ROLE, SCHEMA, PACKAGE )
as
select u.name, schema, package  from 
user$ u, approle$ a 
where  u.user# = a.role#
/
comment on column DBA_APPLICATION_ROLES.ROLE is
'Name of Application Role'
/
comment on column DBA_APPLICATION_ROLES.SCHEMA is
'Schema name of authorizing package'
/
comment on column DBA_APPLICATION_ROLES.PACKAGE is
'Name of authorizing package'
/
create or replace public synonym DBA_APPLICATION_ROLES
   for DBA_APPLICATION_ROLES
/
grant select on DBA_APPLICATION_ROLES to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_APPLICATION_ROLES','CDB_APPLICATION_ROLES');
grant select on SYS.CDB_APPLICATION_ROLES to select_catalog_role
/
create or replace public synonym CDB_APPLICATION_ROLES for SYS.CDB_APPLICATION_ROLES
/

create or replace view USER_APPLICATION_ROLES
(ROLE, SCHEMA, PACKAGE )
as
select u.name, schema, package  from 
user$ u, approle$ a 
where  u.user# = a.role#
and u.user# = uid
/
comment on column USER_APPLICATION_ROLES.ROLE is
'Name of Application Role'
/
comment on column USER_APPLICATION_ROLES.SCHEMA is
'Schema name of authorizing package'
/
comment on column USER_APPLICATION_ROLES.PACKAGE is
'Name of authorizing package'
/
create or replace public synonym USER_APPLICATION_ROLES
   for USER_APPLICATION_ROLES
/
grant read on USER_APPLICATION_ROLES to public with grant option
/

@?/rdbms/admin/sqlsessend.sql
