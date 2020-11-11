Rem
Rem $Header: rdbms/admin/catrssch.sql /main/7 2015/02/25 16:17:59 yanxie Exp $
Rem
Rem catrssch.sql
Rem
Rem Copyright (c) 2008, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrssch.sql - catalog row-level security scheduler-dependent objects
Rem
Rem    DESCRIPTION
Rem      RLS dictionary objects that depend on the scheduler
Rem
Rem    NOTES
Rem      These objects are metadata for Static ACL Materialized Views
Rem      Project #23926        
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catrssch.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catrssch.sql
Rem SQL_PHASE: CATRSSCH
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yanxie      01/21/15 - bug 20339390
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    akoeller    01/10/08 - Row-level security objects dependent on schedule
Rem                           objects
Rem    akoeller    01/10/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

------------------------------------------------------------------------
--- Support views for Static ACL Materialized Views (Row-level security)

----------------------------------------------------
--- The xxx_XDS_ACL_REFRESH  views

-- Notes:
-- user_supplied_mv is new

create or replace view DBA_XDS_ACL_REFRESH
(
  schema_name,
  table_name,
  acl_mview_name,
  refresh_mode,
  refresh_ability,
  acl_status,
  user_supplied_mv,
  start_date,
  repeat_interval,
  refresh_count,
  comments
)
as 
select
  b.schema_name,
  b.table_name,
  b.acl_mview_name,
  b.refresh_mode,
  b.refresh_ability,
  b.acl_status,
  b.user_supplied_mv,
  s.start_date,
  s.repeat_interval,
  s.run_count as refresh_count,
  s.comments
from sys.aclmv$_base_view b, dba_scheduler_jobs s
  where b.schema_name = s.owner(+)
  and b.job_name = s.job_name(+);

create or replace public synonym DBA_XDS_ACL_REFRESH for DBA_XDS_ACL_REFRESH
/
grant select on DBA_XDS_ACL_REFRESH to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XDS_ACL_REFRESH','CDB_XDS_ACL_REFRESH');
grant select on SYS.CDB_XDS_ACL_REFRESH to select_catalog_role
/
create or replace public synonym CDB_XDS_ACL_REFRESH for SYS.CDB_XDS_ACL_REFRESH
/

create or replace view ALL_XDS_ACL_REFRESH
as select s.schema_name,
          s.table_name,
          s.acl_mview_name,
          s.refresh_mode,
          s.refresh_ability,
          s.acl_status,
          s.user_supplied_mv,
          s.start_date,
          s.repeat_interval,
          s.refresh_count,
          s.comments
from dba_xds_acl_refresh s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.table_name = o.name
  and u.name       = s.schema_name
  and o.type#      = 2                     /* table */
  and ( u.user# in (userenv('SCHEMAID'), 1)
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
       or /* user has system privileges */
         ora_check_sys_privilege(o.owner#, o.type#) = 1
      )
/
create or replace public synonym ALL_XDS_ACL_REFRESH for ALL_XDS_ACL_REFRESH
/
grant read on ALL_XDS_ACL_REFRESH to PUBLIC with grant option
/

create or replace view USER_XDS_ACL_REFRESH
as select s.schema_name,
          s.table_name,
          s.acl_mview_name,
          s.refresh_mode,
          s.refresh_ability,
          s.acl_status,
          s.user_supplied_mv,
          s.start_date,
          s.repeat_interval,
          s.refresh_count,
          s.comments
from dba_xds_acl_refresh s, sys.user$ u
where s.schema_name = u.name
  and u.user# = userenv('SCHEMAID')
/
create or replace public synonym USER_XDS_ACL_REFRESH for USER_XDS_ACL_REFRESH
/
grant read on USER_XDS_ACL_REFRESH to PUBLIC with grant option
/

------------------------------------------------------------------------
--- The xxx_XDS_ACL_REFSTAT  views 

create or replace view DBA_XDS_ACL_REFSTAT
(
  schema_name,
  table_name,
  refresh_mode,
  refresh_ability,
  job_start_time,
  job_end_time,
  row_update_count,
  status,
  error_message
)
as 
select
  a.schema_name,
  a.table_name,
  a.refresh_mode,
  a.refresh_ability,
  s.job_start_time,
  s.job_end_time,
  s.row_update_count,
  s.status,
  s.error_message
from sys.aclmv$_base_view a, sys.aclmvrefstat$ s 
where a.acl_mview_obj# = s.acl_mview_obj#;

create or replace public synonym DBA_XDS_ACL_REFSTAT for DBA_XDS_ACL_REFSTAT
/
grant select on DBA_XDS_ACL_REFSTAT to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_XDS_ACL_REFSTAT','CDB_XDS_ACL_REFSTAT');
grant select on SYS.CDB_XDS_ACL_REFSTAT to select_catalog_role
/
create or replace public synonym CDB_XDS_ACL_REFSTAT for SYS.CDB_XDS_ACL_REFSTAT
/

create or replace view ALL_XDS_ACL_REFSTAT
as select s.schema_name,
          s.table_name,
          s.refresh_mode,
          s.refresh_ability,
          s.job_start_time,
          s.job_end_time,
          s.row_update_count,
          s.status,
          s.error_message
from dba_xds_acl_refstat s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.table_name = o.name
  and u.name       = s.schema_name
  and o.type#      = 2                     /* table */
  and ( u.user# in (userenv('SCHEMAID'), 1)
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
       or /* user has system privileges */
         ora_check_sys_privilege(o.owner#, o.type#) = 1
      )
/
create or replace public synonym ALL_XDS_ACL_REFSTAT for ALL_XDS_ACL_REFSTAT
/
grant read on ALL_XDS_ACL_REFSTAT to PUBLIC with grant option
/

create or replace view USER_XDS_ACL_REFSTAT
as select s.schema_name,
          s.table_name,
          s.refresh_mode,
          s.refresh_ability,
          s.job_start_time,
          s.job_end_time,
          s.row_update_count,
          s.status,
          s.error_message
from dba_xds_acl_refstat s, sys.user$ u
where s.schema_name = u.name
  and u.user# = userenv('SCHEMAID')
/
create or replace public synonym USER_XDS_ACL_REFSTAT for USER_XDS_ACL_REFSTAT
/
grant read on USER_XDS_ACL_REFSTAT to PUBLIC with grant option
/


-----------------------------------------
--- The xxx_XDS_LATEST_ACL_REFSTAT  views


create or replace view DBA_XDS_LATEST_ACL_REFSTAT
(
  schema_name,
  table_name,
  refresh_mode,
  refresh_ability,
  job_start_time,
  job_end_time,
  row_update_count,
  status,
  error_message
)
as 
select
  a.schema_name,
  a.table_name,
  a.refresh_mode,
  a.refresh_ability,
  s.job_start_time,
  s.job_end_time,
  s.row_update_count,
  s.status,
  s.error_message
  from sys.aclmv$_base_view a, sys.aclmvrefstat$ s
where a.acl_mview_obj# = s.acl_mview_obj#
  and s.job_end_time =  (select max(r.job_end_time) as job_end_time
                         from sys.aclmvrefstat$ r
                         where r.acl_mview_obj# = s.acl_mview_obj#)
/   
create or replace public synonym DBA_XDS_LATEST_ACL_REFSTAT for DBA_XDS_LATEST_ACL_REFSTAT
/
grant select on DBA_XDS_LATEST_ACL_REFSTAT to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_XDS_LATEST_ACL_REFSTAT','CDB_XDS_LATEST_ACL_REFSTAT');
grant select on SYS.CDB_XDS_LATEST_ACL_REFSTAT to select_catalog_role
/
create or replace public synonym CDB_XDS_LATEST_ACL_REFSTAT for SYS.CDB_XDS_LATEST_ACL_REFSTAT
/

create or replace view ALL_XDS_LATEST_ACL_REFSTAT
as select s.schema_name,
          s.table_name,
          s.refresh_mode,
          s.refresh_ability,
          s.job_start_time,
          s.job_end_time,
          s.row_update_count,
          s.status,
          s.error_message
from dba_xds_latest_acl_refstat s, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and s.table_name = o.name
  and u.name       = s.schema_name
  and o.type#      = 2                     /* table */
  and ( u.user# in (userenv('SCHEMAID'), 1)
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
       or /* user has system privileges */
         ora_check_sys_privilege(o.owner#, o.type#) = 1
      )
/
create or replace public synonym ALL_XDS_LATEST_ACL_REFSTAT for ALL_XDS_LATEST_ACL_REFSTAT
/
grant read on ALL_XDS_LATEST_ACL_REFSTAT to PUBLIC with grant option
/

create or replace view USER_XDS_LATEST_ACL_REFSTAT
as select s.schema_name,
          s.table_name,
          s.refresh_mode,
          s.refresh_ability,
          s.job_start_time,
          s.job_end_time,
          s.row_update_count,
          s.status,
          s.error_message
from dba_xds_latest_acl_refstat s, sys.user$ u
where s.schema_name = u.name
  and u.user# = userenv('SCHEMAID')
/
create or replace public synonym USER_XDS_LATEST_ACL_REFSTAT for USER_XDS_LATEST_ACL_REFSTAT
/
grant read on USER_XDS_LATEST_ACL_REFSTAT to PUBLIC with grant option
/

---------------------------------------------

@?/rdbms/admin/sqlsessend.sql
