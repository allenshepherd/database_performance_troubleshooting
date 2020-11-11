Rem
Rem $Header: rdbms/admin/cdcore_pdbs.sql /st_rdbms_18.0/2 2017/12/03 18:44:57 gravipat Exp $
Rem
Rem cdcore_pdbs.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_pdbs.sql - Catalog DCORE.bsq views for PDB objectS
Rem
Rem    DESCRIPTION
Rem      This script contains the views on PDB dcore.bsq objects
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_pdbs.sql
Rem    SQL_SHIPPED_FILE:rdbms/admin/cdcore_pdbs.sql
Rem    SQL_PHASE:CDCORE_PDBS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ineall      12/03/17 - Bug 25444855: Extend FORCE_LOGGING in DBA_PDBS
Rem    gravipat    12/01/17 - XbranchMerge gravipat_bug-27131802 from main
Rem    gravipat    11/16/17 - Bug 27131802: Add SNAPSHOT_MODE and
Rem                           SNAPSHOT_INTERVAL to dba_pdbs
Rem    gravipat    05/12/17 - Bug 26038923: Add LAST_REFRESH_SCN column to
Rem                           dba_pdbs
Rem    rankalik    05/03/17 - Adding a view for connection_tests$ table
Rem    raeburns    04/23/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    04/23/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  DBA_PDBS
remark
remark  This view will show descriptions of Pluggable Databases
remark  belonging to a given Consolidation Database
remark
create or replace view DBA_PDBS container_data sharing=object
    (PDB_ID, PDB_NAME, DBID, CON_UID, GUID, STATUS, CREATION_SCN, VSN, LOGGING,
     FORCE_LOGGING, FORCE_NOLOGGING, APPLICATION_ROOT, 
     APPLICATION_PDB, APPLICATION_SEED, APPLICATION_ROOT_CON_ID, IS_PROXY_PDB, 
     CON_ID, UPGRADE_PRIORITY, APPLICATION_CLONE, FOREIGN_CDB_DBID, UNPLUG_SCN,
     FOREIGN_PDB_ID, CREATION_TIME, REFRESH_MODE, REFRESH_INTERVAL, TEMPLATE,
     LAST_REFRESH_SCN, TENANT_ID, SNAPSHOT_MODE, SNAPSHOT_INTERVAL)
as
select c.con_id#, o.name, c.dbid, c.con_uid, o.oid$,
 decode(c.status, 0, 'UNUSABLE', 1, 'NEW', 2, 'NORMAL', 3, 'UNPLUGGED',
        5, 'RELOCATING', 6, 'REFRESHING', 7, 'RELOCATED', 8, 'STUB',
        'UNDEFINED'),
c.create_scnwrp*power(2,32)+c.create_scnbas, c.vsn,
decode(bitand(c.flags, 512), 512, 'NOLOGGING', 'LOGGING'),
decode(bitand(c.flags, 1024), 1024, 'YES', 
       decode(bitand(c.flags, 549755813888), 549755813888,
              'STANDBY NOLOGGING FOR LOAD PERFORMANCE',
              decode(bitand(c.flags, 1099511627776), 1099511627776,
                     'STANDBY NOLOGGING FOR DATA AVAILABILITY', 'NO'))),
decode(bitand(c.flags, 2048), 2048, 'YES', 'NO'),
decode(bitand(c.flags, 65536), 65536, 'YES', 'NO'),
decode(c.fed_root_con_id#, NULL, 'NO', 'YES'),
decode(bitand(c.flags, 131072), 131072, 'YES', 'NO'),
c.fed_root_con_id#,
decode(bitand(c.flags, 524288), 524288, 'YES', 'NO'),
c.con_id#,
c.upgrade_priority,
decode(bitand(c.flags, 2097152), 2097152, 'YES', 'NO'),
c.f_cdb_dbid,
c.uscn,
c.f_con_id#,
o.ctime,
decode(bitand(c.flags, 134217728 + 268435456),
       134217728, 'MANUAL', 268435456, 'AUTO', 'NONE'),
c.refreshint,
decode(bitand(c.flags, 68719476736), 68719476736, 'YES', 'NO'),
c.lastrcvscn, c.tenant_id,
decode(bitand(c.flags, 137438953472 + 274877906944),
       137438953472, 'NONE', 274877906944, 'AUTO', 'MANUAL'),
c.snapint
 from sys.container$ c, sys.obj$ o
 where o.obj# = c.obj# and c.con_id# > 1 and c.status <> 4
/

comment on table DBA_PDBS is
'Describes all pluggable databases in the consolidated database'
/
comment on column DBA_PDBS.PDB_ID is
'Id of the pluggable database'
/
comment on column DBA_PDBS.PDB_NAME is
'Name of the pluggable database'
/
comment on column DBA_PDBS.DBID is
'Database id of the pluggable database'
/
comment on column DBA_PDBS.CON_UID is
'Unique ID assigned to the PDB at creation time'
/
comment on column DBA_PDBS.GUID is
'Globally unique immutable ID assigned to the PDB at creation time'
/
comment on column DBA_PDBS.STATUS is
'Status of the pluggable database'
/
comment on column DBA_PDBS.CREATION_SCN is
'SCN for when the pluggable database was created/plugged'
/
comment on column DBA_PDBS.VSN is
'Database version of the PDB'
/
comment on column DBA_PDBS.LOGGING is
'Default logging attribute for the PDB'
/
comment on column DBA_PDBS.FORCE_LOGGING is
'Force logging mode for the PDB'
/
comment on column DBA_PDBS.FORCE_NOLOGGING is
'Force nologging mode for the PDB'
/
comment on column DBA_PDBS.APPLICATION_ROOT is
'Is this PDB an Application Root'
/
comment on column DBA_PDBS.APPLICATION_PDB is
'Is this PDB an Application PDB'
/
comment on column DBA_PDBS.APPLICATION_SEED is
'Is this PDB an Application Seed'
/
comment on column DBA_PDBS.APPLICATION_ROOT_CON_ID is
'Container ID of an Application Root to which this Application PDB belongs, if applicable'
/
comment on column DBA_PDBS.IS_PROXY_PDB is
'Is this PDB a proxy PDB'
/
comment on column DBA_PDBS.CON_ID is
'Id of the pluggable database'
/
comment on column DBA_PDBS.UPGRADE_PRIORITY is
'Upgrade priority of the pluggable database'
/
comment on column DBA_PDBS.APPLICATION_CLONE is
'Is this PDB an Application clone'
/
comment on column DBA_PDBS.FOREIGN_CDB_DBID is
'Foreign Container Database DBID'
/
comment on column DBA_PDBS.UNPLUG_SCN is
'SCN at which the pluggable database was unplugged'
/
comment on column DBA_PDBS.FOREIGN_PDB_ID is
'Foreign pluggable database id'
/
comment on column DBA_PDBS.CREATION_TIME is
'Pluggable database creation timestamp'
/

comment on column DBA_PDBS.REFRESH_MODE is
'Pluggable database refresh mode'
/

comment on column DBA_PDBS.REFRESH_INTERVAL is
'Pluggable database refresh interval in minutes'
/

comment on column DBA_PDBS.TEMPLATE is
'Is this PDB a template PDB'
/

comment on column DBA_PDBS.LAST_REFRESH_SCN is
'Until SCN for the last successful refresh'
/

comment on column DBA_PDBS.TENANT_ID is
'Pluggable database tenant key'
/

comment on column DBA_PDBS.SNAPSHOT_MODE is
'Pluggable database snapshot mode'
/

comment on column DBA_PDBS.SNAPSHOT_INTERVAL is
'Pluggable database snapshot interval in minutes'
/

create or replace public synonym DBA_PDBS for DBA_PDBS
/
grant select on DBA_PDBS to select_catalog_role
/


Rem
Rem Create the corresponding cdb view cdb_pdbs
Rem

execute CDBView.create_cdbview(false,'SYS','DBA_PDBS','CDB_PDBS');
grant select on SYS.CDB_PDBS to select_catalog_role
/
create or replace public synonym CDB_PDBS for SYS.CDB_PDBS
/

remark
remark  DBA_PDB_HISTORY
remark
remark  This view will display lineage (all events which lead to 
remark  its present state) of a Pluggable Database to which this view belongs.
remark
create or replace view DBA_PDB_HISTORY
    (PDB_NAME, PDB_ID, PDB_DBID, PDB_GUID, 
     OP_SCNBAS, OP_SCNWRP, OP_TIMESTAMP, OPERATION, DB_VERSION, 
     CLONED_FROM_PDB_NAME, CLONED_FROM_PDB_DBID, CLONED_FROM_PDB_GUID, 
     DB_NAME, DB_UNIQUE_NAME, DB_DBID, CLONETAG, DB_VERSION_STRING)
as
select p.name, p.con_id#, p.dbid, p.guid, p.scnbas, p.scnwrp, p.time,
       p.operation, p.db_version, p.c_pdb_name, p.c_pdb_dbid, p.c_pdb_guid,
       p.c_db_name, p.c_db_uname, p.c_db_dbid, p.clonetag,
       bitand(p.db_version / power(2,24), 255)||'.'||
       bitand(p.db_version / power(2,20),  15)||'.'||
       bitand(p.db_version / power(2,12), 255)||'.'||
       bitand(p.db_version / power(2, 8),  15)||'.'||
       bitand(p.db_version / power(2, 0), 255) db_version_string
  from sys.pdb_history$ p
/

comment on table DBA_PDB_HISTORY is
'Describes lineage of the pluggable database to which it belongs'
/

comment on column DBA_PDB_HISTORY.PDB_NAME is
'Name of this pluggable database in one of its incarnations'
/

comment on column DBA_PDB_HISTORY.PDB_ID is 
'Id of this pluggable database in one of its incarnations'
/

comment on column DBA_PDB_HISTORY.PDB_DBID is 
'Database id of this pluggable database in one of its incarnations'
/

comment on column DBA_PDB_HISTORY.PDB_GUID is 
'Globally unique id of this pluggable database in one of its incarnations'
/

comment on column DBA_PDB_HISTORY.OP_SCNBAS is 
'SCN base when an operation was performed on one of incarnations of this pluggable database'
/

comment on column DBA_PDB_HISTORY.OP_SCNWRP is 
'SCN wrap when an operation was performed on one of incarnations of this pluggable database'
/

comment on column DBA_PDB_HISTORY.OP_TIMESTAMP is 
'Timestamp of an operation performed on one of incarnations of this pluggable database'
/

comment on column DBA_PDB_HISTORY.OPERATION is 
'Operation that was performed on one of incarnations of this pluggable database'
/

comment on column DBA_PDB_HISTORY.DB_VERSION is 
'Database version'
/

comment on column DBA_PDB_HISTORY.CLONED_FROM_PDB_NAME is 
'Name of a pluggable database from which one of incarnations of this pluggable database was cloned'
/

comment on column DBA_PDB_HISTORY.CLONED_FROM_PDB_DBID is 
'Database id of a pluggable database from which one of incarnations of this pluggable database was cloned'
/

comment on column DBA_PDB_HISTORY.CLONED_FROM_PDB_GUID is 
'Globally unique id of a pluggable database from which one of incarnations of this pluggable database was cloned'
/

comment on column DBA_PDB_HISTORY.DB_NAME is 
'Name of a consolidation database in which one of incarnations of this pluggable database was created'
/

comment on column DBA_PDB_HISTORY.DB_UNIQUE_NAME is 
'Unique name of a consolidation database in which one of incarnations of this pluggable database was created'
/

comment on column DBA_PDB_HISTORY.DB_DBID is 
'Database id of a consolidation database in which one of incarnations of this pluggable database was created'
/

comment on column DBA_PDB_HISTORY.CLONETAG is 
'clone tag name for the pdb if the pdb was cloned using snapshot copy mechanism'
/

comment on column DBA_PDB_HISTORY.DB_VERSION_STRING is 
'Database version string'
/

create or replace public synonym DBA_PDB_HISTORY for DBA_PDB_HISTORY
/
grant select on DBA_PDB_HISTORY to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_PDB_HISTORY','CDB_PDB_HISTORY');
grant select on SYS.CDB_PDB_HISTORY to select_catalog_role
/
create or replace public synonym CDB_PDB_HISTORY for SYS.CDB_PDB_HISTORY
/

remark
remark INT$CONTAINER_OBJ$
remark 
remark This is an internal object-linked container_data view which will make 
remark certain attributes from container$ and obj$ rows pertaining to 
remark Containers visible in Application Roots and will be used in the 
remark definition of DBA_CONTAINER_DATA view
create or replace view INT$CONTAINER_OBJ$ container_data sharing=object
  (NAME, CON_ID)
as 
select o.name, c.con_id# 
  from obj$ o, container$ c
  where o.type# = 111
    and c.obj# = o.obj# (+);

remark
remark  DBA_CONTAINER_DATA
remark
remark  This view will display default and object-specific 
remark  CONTAINER_DATA attributes.
remark
remark NOTE: SHARING=NONE is specified because INT$CONTAINER_OBJ$ is a 
remark CONTAINER_DATA view and if a CONTAINER_DATA view is joined with 
remark non-CONTAINER_DATA objects in a definition of an Oracle-supplied 
remark Common View, default CONTAINER_DATA attribute is used regardless 
remark of the CONTAINER_DATA attribute assigned to the owner of the view
remark (which means that only the row pertaining to the current Container 
remark will be fetched from the CONTAINER_DATA view)
remark
create or replace view DBA_CONTAINER_DATA SHARING=NONE
    (USERNAME, DEFAULT_ATTR, OWNER, OBJECT_NAME, 
     ALL_CONTAINERS, CONTAINER_NAME)
as
select attr_u.name, 'N', owner_u.name, obj_o.name,
       decode(cd.con#, 0, 'Y', 'N'), con_o.name
  from sys.condata$ cd, sys."_BASE_USER" attr_u, 
       sys."_CURRENT_EDITION_OBJ" obj_o, sys.int$container_obj$ con_o,
       sys."_BASE_USER" owner_u
  where cd.user# = attr_u.user#
    and cd.obj# != 0
    and cd.obj# = obj_o.obj#
    and obj_o.owner# = owner_u.user#
    and cd.con# = con_o.con_id (+)
    and (cd.con# = 0 or con_o.con_id is not NULL)
union all
select attr_u.name, 'N', 'SYS', obj_o.name,
       decode(cd.con#, 0, 'Y', 'N'), con_o.name
  from sys.condata$ cd, sys."_BASE_USER" attr_u, 
       sys.v$fixed_table obj_o, sys.int$container_obj$ con_o
  where cd.user# = attr_u.user#
    and cd.obj# != 0
    and cd.obj# = obj_o.object_id
    and cd.con# = con_o.con_id (+)
    and (cd.con# = 0 or con_o.con_id is not NULL)
union all
select attr_u.name, 'Y', NULL, NULL, 
       decode(cd.con#, 0, 'Y', 'N'), con_o.name
  from sys.condata$ cd, sys."_BASE_USER" attr_u, 
       sys.int$container_obj$ con_o
  where cd.user# = attr_u.user#
    and cd.obj# = 0
    and cd.con# = con_o.con_id (+)
    and (cd.con# = 0 or con_o.con_id is not NULL)
union all
  select 'SYS', 'Y', NULL, NULL, 'Y', NULL from dual 
    where sys_context('userenv', 'con_id') = 1
       or sys_context('userenv', 'is_application_root') = 'YES'
union all
  select 'SYSBACKUP', 'Y', NULL, NULL, 'Y', NULL from dual 
    where sys_context('userenv', 'con_id') = 1
       or sys_context('userenv', 'is_application_root') = 'YES'
union all
  select 'SYSDG', 'Y', NULL, NULL, 'Y', NULL from dual 
    where sys_context('userenv', 'con_id') = 1
       or sys_context('userenv', 'is_application_root') = 'YES'
union all
  select 'SYSRAC', 'Y', NULL, NULL, 'Y', NULL from dual 
    where sys_context('userenv', 'con_id') = 1
       or sys_context('userenv', 'is_application_root') = 'YES'
/

comment on table DBA_CONTAINER_DATA is
'Describes default and object-specific CONTAINER_DATA attributes'
/

comment on column DBA_CONTAINER_DATA.USERNAME is
'Name of the user whose attribute is described by this row'
/

comment on column DBA_CONTAINER_DATA.DEFAULT_ATTR is
'An indicator of whether the attribute is a default attribute'
/

comment on column DBA_CONTAINER_DATA.OWNER is
'Name of the object owner if the attribute is object-specific'
/

comment on column DBA_CONTAINER_DATA.OBJECT_NAME is
'Name of the object if the attribute is object-specific'
/

comment on column DBA_CONTAINER_DATA.ALL_CONTAINERS is
'An indicator of whether this attribute applies to all Containers'
/

comment on column DBA_CONTAINER_DATA.CONTAINER_NAME is
'Name of a Container included in this attribute if it does not apply to all Containers'
/


create or replace public synonym DBA_CONTAINER_DATA for DBA_CONTAINER_DATA
/
grant select on DBA_CONTAINER_DATA to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CONTAINER_DATA','CDB_CONTAINER_DATA');
grant select on SYS.CDB_CONTAINER_DATA to select_catalog_role
/
create or replace public synonym CDB_CONTAINER_DATA for SYS.CDB_CONTAINER_DATA
/

remark
remark create role which will contain privileges needed to administer a 
remark Consolidated Database
remark
create role cdb_dba;

grant set container to cdb_dba;

remark
remark grant SET CONTAINER to CONNECT role
remark

grant set container to connect;

create role pdb_dba;

remark
remark make it possible for system to see all data in CONTAINER_DATA 
remark objects in the Root
remark
alter user SYSTEM set container_data=all;

remark
remark PDB_PLUG_IN_VIOLATIONS
remark
remark This view will be used to fetch descriptions of reasons why a PDB or 
remark a non-CDB may not be plugged into a given CDB
remark
create or replace view pdb_plug_in_violations container_data sharing=object
  (time, name, cause, type, error_number, line, message, status, action,
   con_id)
as select time, name, cause, 
   decode(type#, 1, 'ERROR', 2, 'WARNING', 'UNDEFINED'), error#, line#, msg$,
   decode(status, 1, 'PENDING', 2, 'RESOLVED', 3, 'IGNORED', 'UNDEFINED'),
   action, con_uid_to_id(decode(con_uid, 0, 1, con_uid)) con_id
   from pdb_alert$ where type# = 1 or type# = 2
order by time, name, status, line#
/

comment on table PDB_PLUG_IN_VIOLATIONS is
'Contains descriptions of reasons for PDB or a non-CDB plug-in violations'
/

comment on column PDB_PLUG_IN_VIOLATIONS.TIME is
'Time the vilation happened'
/

comment on column PDB_PLUG_IN_VIOLATIONS.NAME is
'A name of a non-CDB or a PDB to which this record applies'
/

comment on column PDB_PLUG_IN_VIOLATIONS.CAUSE is
'Number identifying a specific reason why a PDB or a non-CDB violations'
/

comment on column PDB_PLUG_IN_VIOLATIONS.TYPE is
'Type of the violation'
/

comment on column PDB_PLUG_IN_VIOLATIONS.ERROR_NUMBER is
'Oracle error number of this violation'
/

comment on column PDB_PLUG_IN_VIOLATIONS.LINE is
'Line number for the violation message'
/

comment on column PDB_PLUG_IN_VIOLATIONS.MESSAGE is
'An explanation of a reason why a PDB or a non-CDB violations'
/

comment on column PDB_PLUG_IN_VIOLATIONS.STATUS is
'Status of the violation'
/

comment on column PDB_PLUG_IN_VIOLATIONS.ACTION is
'Actions to take to resolve the violations'
/

comment on column PDB_PLUG_IN_VIOLATIONS.CON_ID is
'ID of a Container'
/

create or replace public synonym PDB_PLUG_IN_VIOLATIONS for PDB_PLUG_IN_VIOLATIONS
/

grant select on PDB_PLUG_IN_VIOLATIONS to cdb_dba
/

grant select on PDB_PLUG_IN_VIOLATIONS to pdb_dba
/

remark
remark PDB_ALERTS
remark
remark This view will used for showing all alerts for a PDB 
remark
create or replace view pdb_alerts
  (time, name, cause_no, type_no, error, line, message, status, action)
as select time, name, cause#, type#, error#, line#, msg$, status, action
from pdb_alert$ where type# = 3
order by time, name, status, line#
/

comment on table PDB_ALERTS is
'Contains descriptions of reasons for PDB alerts'
/

comment on column PDB_ALERTS.TIME is
'Time the vilation happened'
/

comment on column PDB_ALERTS.NAME is
'A name of a non-CDB or a PDB to which this record applies'
/

comment on column PDB_ALERTS.CAUSE_NO is
'Number identifying a specific reason for a PDB alerts'
/

comment on column PDB_ALERTS.TYPE_NO is
'Type of the violation'
/

comment on column PDB_ALERTS.ERROR is
'Oracle error if this violation'
/

comment on column PDB_ALERTS.LINE is
'Line number for the violation message'
/

comment on column PDB_ALERTS.MESSAGE is
'An explanation of a reason why a PDB or a non-CDB violations'
/

comment on column PDB_ALERTS.STATUS is
'Status of the violation'
/

comment on column PDB_ALERTS.ACTION is
'Actions to take to resolve the violations'
/

create or replace public synonym PDB_ALERTS for PDB_ALERTS
/

grant select on PDB_ALERTS to cdb_dba
/

grant select on PDB_ALERTS to pdb_dba
/

remark
remark CDB_LOCAL_ADMIN_PRIVS
remark
remark This view will be used to fetch descriptions of local administrative 
remark privileges granted in PDBs which are replicated in the Root to 
remark facilitate checking of administrative privileges when a Container in 
remark which a privilege was granted is closed
remark
create or replace view cdb_local_admin_privs CONTAINER_DATA 
  (con_id, con_name, grantee, 
   sysdba, sysoper, sysasm, sysbackup, sysdg, syskm) as
select c.con_id#, o.name, auth.grantee$, 
       decode(bitand(auth.privileges,    2), 2, 'TRUE', 'FALSE'),
       decode(bitand(auth.privileges,    4), 4, 'TRUE', 'FALSE'),
       decode(bitand(auth.privileges,   32), 32, 'TRUE', 'FALSE'),
       decode(bitand(auth.privileges,  256), 256, 'TRUE', 'FALSE'),
       decode(bitand(auth.privileges,  512), 512, 'TRUE', 'FALSE'),
       decode(bitand(auth.privileges, 1024), 1024, 'TRUE', 'FALSE')
  from obj$ o, cdb_local_adminauth$ auth, container$ c
  where o.obj#=c.obj# and c.con_uid=auth.con_uid;

comment on table CDB_LOCAL_ADMIN_PRIVS is
'Describes local administrative privileges granted in PDBs of a CDB'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.CON_ID is
'ID of a Container in which a privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.CON_NAME is
'Name of a Container in which a privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.GRANTEE is
'Name of a grantee to whom privilege(s) were granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSDBA is
'SYSDBA privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSOPER is
'SYSOPER privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSASM is
'SYSASM privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSBACKUP is
'SYSBACKUP privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSDG is
'SYSDG privilege was granted'
/

comment on column CDB_LOCAL_ADMIN_PRIVS.SYSKM is
'SYSKM privilege was granted'
/

create or replace public synonym CDB_LOCAL_ADMIN_PRIVS 
  for CDB_LOCAL_ADMIN_PRIVS
/
grant select on CDB_LOCAL_ADMIN_PRIVS to cdb_dba
/

remark
remark  DBA_PDB_SAVED_STATES
remark
remark  This view will show any saved states for the pdb's
remark  belonging to a given Consolidation Database
remark
create or replace view DBA_PDB_SAVED_STATES container_data sharing=object
    (CON_ID, CON_NAME, INSTANCE_NAME, CON_UID, GUID, STATE, RESTRICTED)
as
select c.con_id#, o.name, p.inst_name, p.pdb_uid, p.pdb_guid,
decode(p.state, 0, 'CLOSED', 1, 'OPEN', 2, 'OPEN READ ONLY',
       3, 'OPEN_MIGRATE', 'UNDEFINED'), decode(p.restricted, 1, 'YES', 'NO')
 from sys.container$ c, sys.obj$ o, sys.pdbstate$ p
 where o.obj# = c.obj# and c.con_uid = p.pdb_uid
/

comment on table DBA_PDB_SAVED_STATES is
'Shows all saved pluggable database states in the consolidated database'
/
comment on column DBA_PDB_SAVED_STATES.CON_ID is
'Id of the pluggable database'
/
comment on column DBA_PDB_SAVED_STATES.CON_NAME is
'Name of the pluggable database'
/
comment on column DBA_PDB_SAVED_STATES.INSTANCE_NAME is
'name of the instance for which the state is saved'
/
comment on column DBA_PDB_SAVED_STATES.CON_UID is
'Unique ID assigned to the PDB at creation time'
/
comment on column DBA_PDB_SAVED_STATES.GUID is
'Globally unique immutable ID assigned to the PDB at creation time'
/
comment on column DBA_PDB_SAVED_STATES.STATE is
'Open state of the pluggable database'
/
comment on column DBA_PDB_SAVED_STATES.RESTRICTED is
'Restricted mode of the pluggable database'
/

create or replace public synonym DBA_PDB_SAVED_STATES for DBA_PDB_SAVED_STATES
/
grant select on DBA_PDB_SAVED_STATES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_PDB_SAVED_STATES','CDB_PDB_SAVED_STATES');
grant select on SYS.CDB_PDB_SAVED_STATES to select_catalog_role
/
create or replace public synonym CDB_PDB_SAVED_STATES for SYS.CDB_PDB_SAVED_STATES
/

remark
remark  DBA_LOCKDOWN_PROFILES
remark
remark  This view will show descriptions of Pluggable Database Lockdown Profile
remark
create or replace view DBA_LOCKDOWN_PROFILES
    (PROFILE_NAME, RULE_TYPE, RULE, CLAUSE, CLAUSE_OPTION, OPTION_VALUE,
     MIN_VALUE, MAX_VALUE, LIST, STATUS, USERS)
as
select o.name, p.ruletyp, p.ruleval, p.clause, p.option$, p.value$,
       p.minval$, p.maxval$, p.list$,
       decode(p.status, NULL, 'EMPTY', 0, 'ENABLE', 1, 'DISABLE', 2, 'DISABLE',
              3, 'ENABLE', 4, 'DISABLE', 5, 'EMPTY'),
       decode(p.usertyp$, 0, 'ALL', 1, 'LOCAL', 2, 'COMMON')
 from sys.obj$ o left outer join sys.lockdown_prof$ p on o.obj# = p.prof#
 where o.namespace = 132 and o.type# != 10 and p.status != 6
 order by o.name, p.ruletyp, p.ruleval, p.level#, p.ltime, p.clause,
       p.option$
/

comment on table DBA_LOCKDOWN_PROFILES is
'Describes all the rules of all the lockdown profiles'
/
comment on column DBA_LOCKDOWN_PROFILES.PROFILE_NAME is
'Name of the lockdown profile'
/
comment on column DBA_LOCKDOWN_PROFILES.RULE_TYPE is
'Rule type - statement/feature/option'
/
comment on column DBA_LOCKDOWN_PROFILES.RULE is
'Rule to be enabled or disabled'
/
comment on column DBA_LOCKDOWN_PROFILES.CLAUSE is
'Clause of the statement'
/
comment on column DBA_LOCKDOWN_PROFILES.CLAUSE_OPTION is
'Option of the clause'
/
comment on column DBA_LOCKDOWN_PROFILES.OPTION_VALUE is
'Value of the option'
/
comment on column DBA_LOCKDOWN_PROFILES.MIN_VALUE is
'Minimum value allowed for the option'
/
comment on column DBA_LOCKDOWN_PROFILES.MAX_VALUE is
'Maximum value allowed for the option'
/
comment on column DBA_LOCKDOWN_PROFILES.LIST is
'List of allowed values for the option'
/
comment on column DBA_LOCKDOWN_PROFILES.STATUS is
'Status of the lockdown profile'
/
comment on column DBA_LOCKDOWN_PROFILES.USERS is
'User type - common/local/all'
/

create or replace public synonym DBA_LOCKDOWN_PROFILES
  for DBA_LOCKDOWN_PROFILES
/
grant select on DBA_LOCKDOWN_PROFILES to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOCKDOWN_PROFILES','CDB_LOCKDOWN_PROFILES');
grant select on SYS.CDB_LOCKDOWN_PROFILES to select_catalog_role
/
create or replace public synonym CDB_LOCKDOWN_PROFILES for SYS.CDB_LOCKDOWN_PROFILES
/

remark
remark  DBA_PDB_SNAPSHOTS
remark
remark  This view will show descriptions of all the snapshots of a given
remark  Pluggable Database
remark
create or replace view DBA_PDB_SNAPSHOTS container_data sharing=data
    (CON_ID, CON_UID, CON_NAME, SNAPSHOT_NAME, SNAPSHOT_SCN,
     PREVIOUS_SNAPSHOT_SCN, SNAPSHOT_TIME, PREVIOUS_SNAPSHOT_TIME,
     FULL_SNAPSHOT_PATH)
as
select ps.con_id#, ps.con_uid, o.name, ps.snapname, ps.snapscn, ps.prevsnapscn,
       ps.snaptime, ps.prevsnaptime, ps.archivepath
 from sys.pdb_snapshot$ ps, sys.container$ c, sys.obj$ o
 where ps.con_id#=c.con_id# and c.obj#=o.obj#
/

comment on table DBA_PDB_SNAPSHOTS is
'Describes all snapshots for a given pluggable database'
/
comment on column DBA_PDB_SNAPSHOTS.CON_ID is
'Id of the pluggable database'
/
comment on column DBA_PDB_SNAPSHOTS.CON_UID is
'Uid of the pluggable database'
/
comment on column DBA_PDB_SNAPSHOTS.CON_NAME is
'Name of the pluggable database'
/
comment on column DBA_PDB_SNAPSHOTS.SNAPSHOT_NAME is
'Snapshot name of the pluggable database'
/
comment on column DBA_PDB_SNAPSHOTS.SNAPSHOT_SCN is
'SCN at which the snapshot was taken'
/
comment on column DBA_PDB_SNAPSHOTS.PREVIOUS_SNAPSHOT_SCN is
'SCN of the previous snapshot for the pdb was taken'
/
comment on column DBA_PDB_SNAPSHOTS.SNAPSHOT_TIME is
'Timestamp at which the snapshot was taken'
/
comment on column DBA_PDB_SNAPSHOTS.PREVIOUS_SNAPSHOT_TIME is
'Timestamp of the previous snapshot for this pdb'
/
comment on column DBA_PDB_SNAPSHOTS.FULL_SNAPSHOT_PATH is
'full path for the snapshot'
/

create or replace public synonym DBA_PDB_SNAPSHOTS for DBA_PDB_SNAPSHOTS
/
grant select on DBA_PDB_SNAPSHOTS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_PDB_SNAPSHOTS','CDB_PDB_SNAPSHOTS');
grant select on SYS.CDB_PDB_SNAPSHOTS to select_catalog_role
/
create or replace public synonym CDB_PDB_SNAPSHOTS for SYS.CDB_PDB_SNAPSHOTS
/

remark
remark  Planned Maintenance
remark
create or replace view DBA_CONNECTION_TESTS
    (PREDEFINED, CONNECTION_TEST_TYPE, SQL_CONNECTION_TEST, SERVICE_NAME, ENABLED)
as
select decode(predefined, '0','N', '1', 'Y') "PREDEFINED", 
       decode(connection_test_type, '0', 'SQL_TEST', '1', 'PING_TEST', '2', 
              'ENDREQUEST_TEST') "CONNECTION TEST TYPE", 
       SQL_CONNECTION_TEST, service_name, 
       decode(enabled, '0', 'N', '1', 'Y')
from sys.connection_tests$
/
comment on table  DBA_CONNECTION_TESTS is
'Information about Draining rules'
/
comment on column  DBA_CONNECTION_TESTS.PREDEFINED is
'Set if this rule is default'
/
comment on column  DBA_CONNECTION_TESTS.CONNECTION_TEST_TYPE is
'0:SQL test, 1:Ping test, 2:End Request test'
/
comment on column  DBA_CONNECTION_TESTS.SQL_CONNECTION_TEST is
'SQL entry. NA for non-SQL tests'
/
comment on column  DBA_CONNECTION_TESTS.SERVICE_NAME is
'Service associated with the SQL/non-SQL test'
/
comment on column  DBA_CONNECTION_TESTS.ENABLED is
'True if enabled'
/
grant select on  DBA_CONNECTION_TESTS to select_catalog_role
/
create or replace public synonym  DBA_CONNECTION_TESTS for DBA_CONNECTION_TESTS
/
grant select on DBA_CONNECTION_TESTS to select_catalog_role
/
execute CDBView.create_cdbview(false,'SYS','DBA_CONNECTION_TESTS','CDB_CONNECTION_TESTS');
grant select on SYS.CDB_CONNECTION_TESTS to select_catalog_role
/
create or replace public synonym CDB_CONNECTION_TESTS for SYS.CDB_CONNECTION_TESTS
/

@?/rdbms/admin/sqlsessend.sql
 
