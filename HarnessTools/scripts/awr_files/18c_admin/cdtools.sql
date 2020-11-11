Rem
Rem $Header: rdbms/admin/cdtools.sql /main/4 2014/02/20 12:45:43 surman Exp $
Rem
Rem cdtools.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdtools.sql - Catalog DTOOLS.bsq views
Rem
Rem    DESCRIPTION
Rem      exp_objects, exp_files, etc.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dtools.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdtools.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdtools.sql
Rem SQL_PHASE: CDTOOLS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "EXP_OBJECTS"
remark  Objects that have been incrementally exported.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_OBJECTS
    (OWNER, OBJECT_NAME, OBJECT_TYPE, CUMULATIVE, INCREMENTAL, EXPORT_VERSION)
as
select u.name, o.name,
       decode(o.type#, 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
                      12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
                      22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
                      30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
       o.ctime, o.itime, o.expid
from sys.incexp o, sys.user$ u
where o.owner# = u.user#
/
create or replace public synonym DBA_EXP_OBJECTS for DBA_EXP_OBJECTS
/
grant select on DBA_EXP_OBJECTS to select_catalog_role
/
comment on table DBA_EXP_OBJECTS is
'Objects that have been incrementally exported'
/
comment on column DBA_EXP_OBJECTS.OWNER is
'Owner of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_NAME is
'Name of exported object'
/
comment on column DBA_EXP_OBJECTS.OBJECT_TYPE is
'Type of exported object'
/
comment on column DBA_EXP_OBJECTS.CUMULATIVE is
'Timestamp of last cumulative export'
/
comment on column DBA_EXP_OBJECTS.INCREMENTAL is
'Timestamp of last incremental export'
/
comment on column DBA_EXP_OBJECTS.EXPORT_VERSION is
'The id of the export session'
/

execute CDBView.create_cdbview(false,'SYS','DBA_EXP_OBJECTS','CDB_EXP_OBJECTS');
grant select on SYS.CDB_EXP_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_EXP_OBJECTS for SYS.CDB_EXP_OBJECTS
/

remark
remark  FAMILY "EXP_VERSION"
remark  Version number of last incremental export
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_VERSION
    (EXP_VERSION)
as
select o.expid
from sys.incvid o
/
create or replace public synonym DBA_EXP_VERSION for DBA_EXP_VERSION
/
grant select on DBA_EXP_VERSION to select_catalog_role
/
comment on table DBA_EXP_VERSION is
'Version number of the last export session'
/
comment on column DBA_EXP_VERSION.EXP_VERSION is
'Version number of the last export session'
/

execute CDBView.create_cdbview(false,'SYS','DBA_EXP_VERSION','CDB_EXP_VERSION');
grant select on SYS.CDB_EXP_VERSION to select_catalog_role
/
create or replace public synonym CDB_EXP_VERSION for SYS.CDB_EXP_VERSION
/

remark
remark  FAMILY "EXP_FILES"
remark  Files created by incremental exports.
remark  This family has a DBA member only.
remark
create or replace view DBA_EXP_FILES
     (EXP_VERSION, EXP_TYPE, FILE_NAME, USER_NAME, TIMESTAMP)
as
select o.expid, decode(o.exptype, 'X', 'COMPLETE', 'C', 'CUMULATIVE',
                                  'I', 'INCREMENTAL', 'UNDEFINED'),
       o.expfile, o.expuser, o.expdate
from sys.incfil o
/
create or replace public synonym DBA_EXP_FILES for DBA_EXP_FILES
/
grant select on DBA_EXP_FILES to select_catalog_role
/
comment on table DBA_EXP_FILES is
'Description of export files'
/
comment on column DBA_EXP_FILES.EXP_VERSION is
'Version number of the export session'
/
comment on column DBA_EXP_FILES.FILE_NAME is
'Name of the export file'
/
comment on column DBA_EXP_FILES.USER_NAME is
'Name of user who executed export'
/
comment on column DBA_EXP_FILES.TIMESTAMP is
'Timestamp of the export session'
/

execute CDBView.create_cdbview(false,'SYS','DBA_EXP_FILES','CDB_EXP_FILES');
grant select on SYS.CDB_EXP_FILES to select_catalog_role
/
create or replace public synonym CDB_EXP_FILES for SYS.CDB_EXP_FILES
/


@?/rdbms/admin/sqlsessend.sql
