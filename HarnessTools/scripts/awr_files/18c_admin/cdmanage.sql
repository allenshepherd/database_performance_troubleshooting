Rem
Rem $Header: rdbms/admin/cdmanage.sql /main/8 2014/12/11 22:46:35 skayoor Exp $
Rem
Rem cdmanage.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdmanage.sql - Catalog DMANAGE.bsq views
Rem
Rem    DESCRIPTION
Rem      SQL tuning, SQL text, SQL profile, etc
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dmanage.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdmanage.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdmanage.sql
Rem SQL_PHASE: CDMANAGE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    sankejai    12/28/12 - XbranchMerge sankejai_bug-15988931 from
Rem                           st_rdbms_12.1.0.1
Rem    sankejai    12/20/12 - 16010984: add USER_OBJECT_USAGE
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sankejai    02/14/11 - rename V$OBJECT_USAGE to DBA_OBJECT_USAGE
Rem    schakkap    10/20/06 - move v$object_usage from cdcore.sql
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem Object usage information for all users. 
Rem Currently shows only index usage information.
Rem
create or replace view DBA_OBJECT_USAGE
    (OWNER, INDEX_NAME,
     TABLE_NAME,
     MONITORING,
     USED,
     START_MONITORING,
     END_MONITORING)
as
select u.name, io.name, t.name,
       decode(bitand(i.flags, 65536), 0, 'NO', 'YES'),
       decode(bitand(ou.flags, 1), 0, 'NO', 'YES'),
       ou.start_monitoring,
       ou.end_monitoring
from sys.obj$ io, sys.user$ u, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where io.owner# = u.user#
  and i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
/
create or replace public synonym DBA_OBJECT_USAGE for DBA_OBJECT_USAGE
/
grant select on DBA_OBJECT_USAGE to select_catalog_role
/
comment on table DBA_OBJECT_USAGE is
'Record of index usage'
/
comment on column DBA_OBJECT_USAGE.OWNER is
'Owner of the index'
/
comment on column DBA_OBJECT_USAGE.INDEX_NAME is
'Name of the index'
/
comment on column DBA_OBJECT_USAGE.TABLE_NAME is
'Name of the table upon which the index was build'
/
comment on column DBA_OBJECT_USAGE.MONITORING is
'Whether the monitoring feature is on'
/
comment on column DBA_OBJECT_USAGE.USED is
'Whether the index has been accessed'
/
comment on column DBA_OBJECT_USAGE.START_MONITORING is
'When the monitoring feature is turned on'
/
comment on column DBA_OBJECT_USAGE.END_MONITORING is
'When the monitoring feature is turned off'
/


execute CDBView.create_cdbview(false,'SYS','DBA_OBJECT_USAGE','CDB_OBJECT_USAGE');
grant select on SYS.CDB_OBJECT_USAGE to select_catalog_role
/
create or replace public synonym CDB_OBJECT_USAGE for SYS.CDB_OBJECT_USAGE
/

Rem
Rem Object usage information. Currently shows only index usage information.
Rem
Rem NOTE: This view was previously incorrectly named as v$object_usage, even
Rem though it was not a fixed view. Now there is dummy fixed view named
Rem v$object_usage for backward compatibility, and the catalog view has been
Rem renamed as USER_OBJECT_USAGE.
Rem
create or replace view USER_OBJECT_USAGE
    (INDEX_NAME,
     TABLE_NAME,
     MONITORING,
     USED,
     START_MONITORING,
     END_MONITORING)
as
select io.name, t.name,
       decode(bitand(i.flags, 65536), 0, 'NO', 'YES'),
       decode(bitand(ou.flags, 1), 0, 'NO', 'YES'),
       ou.start_monitoring,
       ou.end_monitoring
from sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where io.owner# = userenv('SCHEMAID')
  and i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
/
create or replace public synonym USER_OBJECT_USAGE for USER_OBJECT_USAGE
/
grant read on USER_OBJECT_USAGE to public with grant option
/
comment on table USER_OBJECT_USAGE is
'Record of index usage'
/
comment on column USER_OBJECT_USAGE.INDEX_NAME is
'Name of the index'
/
comment on column USER_OBJECT_USAGE.TABLE_NAME is
'Name of the table upon which the index was build'
/
comment on column USER_OBJECT_USAGE.MONITORING is
'Whether the monitoring feature is on'
/
comment on column USER_OBJECT_USAGE.USED is
'Whether the index has been accessed'
/
comment on column USER_OBJECT_USAGE.START_MONITORING is
'When the monitoring feature is turned on'
/
comment on column USER_OBJECT_USAGE.END_MONITORING is
'When the monitoring feature is turned off'
/

Rem
Rem For backward compatibility, make V$OBJECT_USAGE a synonym to 
Rem USER_OBJECT_USAGE and V$OBJECT_USAGE is marked as deprecated in 12.1.
Rem This should be removed in 12.2
Rem
create or replace public synonym V$OBJECT_USAGE for USER_OBJECT_USAGE
/


@?/rdbms/admin/sqlsessend.sql
