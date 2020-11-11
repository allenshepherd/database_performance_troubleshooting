Rem
Rem $Header: rdbms/admin/catepg.sql /main/6 2015/11/17 12:58:09 rpang Exp $
Rem
Rem catepg.sql
Rem
Rem Copyright (c) 2004, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catepg.sql - Embedded PL/SQL Gateway related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the tables and views required for supporting the
Rem     the embedded PL/SQL gateway.
Rem
Rem    NOTES
Rem      This script should be run as "SYS".
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catepg.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catepg.sql
Rem SQL_PHASE: CATEPG
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       11/10/15 - Bug 22100322: increase dad_name size
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      01/22/14 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    rpang       02/15/05 - No set echo 
Rem    rpang       10/08/04 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


Rem
Rem DAD authorization information storage
Rem

create table EPG$_AUTH
( DADNAME            varchar2(128) not null,                     /* DAD name */
  USER#              number not null, /* user authorized for use by this DAD */
  constraint epg$_auth_pk primary key (dadname,user#)
)
/

Rem
Rem User DAD authorization view
Rem

create or replace view USER_EPG_DAD_AUTHORIZATION
(DAD_NAME)
as
select ea.dadname
from epg$_auth ea
where ea.user# = userenv('SCHEMAID')
/
create or replace public synonym USER_EPG_DAD_AUTHORIZATION for USER_EPG_DAD_AUTHORIZATION
/
grant read on USER_EPG_DAD_AUTHORIZATION to public
/
comment on table USER_EPG_DAD_AUTHORIZATION is
'DADs authorized to use the user''s privileges'
/
comment on column USER_EPG_DAD_AUTHORIZATION.DAD_NAME is
'Name of DAD'
/

Rem
Rem DBA DAD authorization view
Rem

create or replace view DBA_EPG_DAD_AUTHORIZATION
(DAD_NAME, USERNAME)
as
select ea.dadname, u.name
from epg$_auth ea, user$ u
where ea.user# = u.user#
/
create or replace public synonym DBA_EPG_DAD_AUTHORIZATION for DBA_EPG_DAD_AUTHORIZATION
/
grant select on DBA_EPG_DAD_AUTHORIZATION to select_catalog_role
/
grant select on DBA_EPG_DAD_AUTHORIZATION to xdbadmin
/
comment on table DBA_EPG_DAD_AUTHORIZATION is
'DADs authorized to use different user''s privileges'
/
comment on column DBA_EPG_DAD_AUTHORIZATION.DAD_NAME is
'Name of DAD'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
'Name of the user whose privileges the DAD is authorized to use'
/

execute CDBView.create_cdbview(false,'SYS','DBA_EPG_DAD_AUTHORIZATION','CDB_EPG_DAD_AUTHORIZATION');
grant select on SYS.CDB_EPG_DAD_AUTHORIZATION to select_catalog_role
/
create or replace public synonym CDB_EPG_DAD_AUTHORIZATION for SYS.CDB_EPG_DAD_AUTHORIZATION
/


@?/rdbms/admin/sqlsessend.sql
