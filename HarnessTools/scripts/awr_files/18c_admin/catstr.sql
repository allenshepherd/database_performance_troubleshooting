Rem
Rem $Header: rdbms/admin/catstr.sql /main/70 2014/12/11 22:46:35 skayoor Exp $
Rem
Rem catstr.sql
Rem
Rem Copyright (c) 2001, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catstr.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catstr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catstr.sql
Rem SQL_PHASE: CATSTR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jovillag    11/06/13 - bug 17709106: mark _GV$SXGG* and _V$SXGG* views 
Rem                           as container_data views if they have a CON_ID
Rem                           column
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    huntran     08/14/12 - cast GoldenGate position to varchar
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem     myuin      02/01/12 - added _(G)V$SXGG_TRANSACTION and
Rem                           _(G)V$SXGG_MESSAGE_TRACKING
Rem    lzheng      11/16/11 - move (g)v$xstream/gg_message_tracking,
Rem                           (g)v$xstream/gg_transaction from cdfixed.sql 
Rem                           to here
Rem    yurxu       04/21/11 - Revise all_goldengate_privileges
Rem    yurxu       03/07/11 - Bug-11922716: 2-level privilege model
Rem    yurxu       03/05/10 - Bug-9469148: modify user/dba_goldengate_privileges
Rem    juyuan      12/23/09 - dba_goldengate_privileges
Rem    juyuan      04/15/09 - add v$streams_pool_statistics
Rem    jinwu       11/03/06 - restructure by creating subsidiary catalog
Rem                           views: catstrm.sql, catstrr.sql, catstrt.sql
Rem                           catrse.sql, catcmp.sql and catstrc.sql
Rem    jstamos     06/20/06 - tune dba_comparison_scan 
Rem    jinwu       09/07/06 - split streams advisor
Rem    thoang      06/01/06 - add all_sync_capture_tables
Rem    juyuan      07/07/06 - remove dba_streams_tables view
Rem    jinwu       07/06/06 - add streams$_component_prop_in 
Rem    juyuan      06/27/06 - lrg 2278802 
Rem    jinwu       06/06/06 - add new DBA_STREAMS_TP (topology) views
Rem    juyuan      05/10/06 - add dba_streams_tables view 
Rem    jinwu       05/25/06 - add new columns stream_id and link_level
Rem                           to streams$_component_link_in
Rem    jinwu       04/26/06 - replace dblink with new column 
Rem                           dst_database_name in v$propagation_sender
Rem    rvenkate    04/10/06 - add comparison views 
Rem    jinwu       04/26/06 - replace dblink with new column dst_database_name
Rem                           in v$propagation_sender
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    jinwu       02/14/06 - add Streams Topology per-database views
Rem    juyuan      03/07/06 - add v$streams_message_tracking 
Rem    thoang      08/22/05 - do not ref (streams_name, streams_type) from
Rem                           streams$_message_rules & streams$_rules
Rem    thoang      05/06/05 - support synchronous capture 
Rem    elu         03/09/05 - move apply spilling to catapp.sql 
Rem    alakshmi    03/07/05 - recoverable script views 
Rem    alakshmi    02/28/05 - error recovery for maintain_ apis
Rem    nshodhan    03/04/05 - add v$streams_transaction 
Rem    liwong      02/07/05 - Include custom_type 
Rem    htran       02/01/05 - dba_apply_spill_txn view
Rem    alakshmi    01/28/05 - add streams$_apply_spill_msgs_part 
Rem    htran       01/19/05 - apply spill internal view
Rem    htran       01/06/05 - add scn column for spilled messages
Rem    elu         01/05/05 - streams apply spilling 
Rem    nshodhan    11/24/04 - mark encrypted columns unsupported 
Rem    htran       07/20/04 - create streams$_anydata_array type
Rem    bpwang      06/03/04 - streams$internal_transform.column_type to number
Rem    ksurlake    06/01/04 - reg$ has canonicalized subname
Rem    nshodhan    05/24/04 - support IOTs w/ lobs and overflow 
Rem    bpwang      03/11/04 - Adding internal lcr transformation support 
Rem    htran       03/03/04 - load catfgr.sql
Rem    htran       12/01/03 - change message_consumers for anydata context 
Rem    bpwang      10/24/03 - Bug 2984150: Support urowid type 
Rem    wesmith     07/29/03 - view DBA_STREAMS_MESSAGE_CONSUMERS: 
Rem                           remove join to AQ tables
Rem    nshodhan    08/11/03 - bug : add auto_filtered column
Rem    bpwang      07/15/03 - bug 2771770:  add streams$nv_node and nv_array
Rem    wesmith     06/13/03 - allow MV tables in _DBA_STREAMS_UNSUPPORTED_10_1
Rem    elu         05/27/03 - decode for subsetting_operation
Rem    bpwang      05/19/03 - add "_DBA_STREAMS_QUEUES"
Rem    elu         04/29/03 - fix all_streams_message_consumers 
Rem    nshodhan    04/25/03 - filter out CTXSYS objects from strms unsup. view
Rem    elu         04/22/03 - add dba_streams_rules
Rem    nshodhan    04/22/03 - make context indices unsupported
Rem    nshodhan    04/01/03 - Add support for streams_unsupported bit
Rem    bpwang      02/17/03 - Bug 2785745:  Dropping capture and apply 
Rem                           processes when drop user cascade called on 
Rem                           capture or apply user
Rem    liwong      02/14/03 - Bug 2804918
Rem    liwong      01/23/03 - Add dba_streams_unsupported and its siblings
Rem    htran       01/15/03 - add LOCAL_PRIVILEGES and ACCESS_FROM_REMOTE
Rem                           columns to DBA_STREAMS_ADMINISTRATOR.
Rem                           add _DBA_STREAMS_PRIVILEGED_USER view.
Rem    liwong      12/25/02 - Fix dba_streams_message_consumers
Rem    liwong      12/23/02 - Support Dequeue in dba_streams_table_rules
Rem    apadmana    12/06/02 - Add view for exporting streams$_message_rules
Rem    liwong      10/23/02 - Modify dba_streams_message_consumers
Rem    apadmana    10/18/02 - Add view dba_streams_message_rules
Rem    bpwang      09/27/02 - Adding DBA_STREAMS_TRANSFORM_FUNCTION and 
Rem                         -  ALL_STREAMS_TRANSFORM_FUNCTION views
Rem    apadmana    09/27/02 - Add view dba_streams_administrator
Rem    liwong      07/16/02 - Fix all_streams_global_rules
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    sbalaram    01/25/02 - Fix all_streams_*_rules views
Rem    wesmith     01/09/02 - Streams export/import support
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    12/04/01 - decode subsetting_operation
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    sbalaram    10/29/01 - add views
Rem    apadmana    10/26/01 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem Streams CAPture
@@catcap

Rem Streams APPly
@@catapp

Rem Streams PRoPagation
@@catprp

Rem File Group Repository
@@catfgr

Rem Streams ADVisor(s) for Performance, Configuration and Error
@@catsadv

Rem STReams Message catalog views
@@catstrm.sql

Rem STReams Rule-related catalog views
@@catstrr.sql

Rem STReams Transformation catalog views
@@catstrt.sql

Rem Recoverable Script Execution catalog views
@@catrse.sql

----------------------------------------------------------------------------
-- V$STREAMS_TRANSACTION
----------------------------------------------------------------------------
create or replace view GV_$STREAMS_TRANSACTION
  as select * from gv$streams_transaction
/
create or replace public synonym GV$STREAMS_TRANSACTION 
  for GV_$STREAMS_TRANSACTION
/
grant select on GV_$STREAMS_TRANSACTION to select_catalog_role
/
----------------------------------------------------------------------------
create or replace view V_$STREAMS_TRANSACTION
  as select * from v$streams_transaction
/
create or replace public synonym V$STREAMS_TRANSACTION 
  for V_$STREAMS_TRANSACTION
/
grant select on V_$STREAMS_TRANSACTION to select_catalog_role
/

----------------------------------------------------------------------------
-- V$XSTREAM_TRANSACTION
----------------------------------------------------------------------------
create or replace view GV_$XSTREAM_TRANSACTION
  as select * from gv$xstream_transaction
/
create or replace public synonym GV$XSTREAM_TRANSACTION
  for GV_$XSTREAM_TRANSACTION
/
grant select on GV_$XSTREAM_TRANSACTION to select_catalog_role
/
----------------------------------------------------------------------------
create or replace view V_$XSTREAM_TRANSACTION
  as select * from v$xstream_transaction
/
create or replace public synonym V$XSTREAM_TRANSACTION
  for V_$XSTREAM_TRANSACTION
/
grant select on V_$XSTREAM_TRANSACTION to select_catalog_role
/

----------------------------------------------------------------------------
-- V$GOLDENGATE_TRANSACTION
----------------------------------------------------------------------------
create or replace view GV_$GOLDENGATE_TRANSACTION
  as select * from gv$goldengate_transaction
/
create or replace public synonym GV$GOLDENGATE_TRANSACTION
  for GV_$GOLDENGATE_TRANSACTION
/
grant select on GV_$GOLDENGATE_TRANSACTION to select_catalog_role
/
----------------------------------------------------------------------------
create or replace view V_$GOLDENGATE_TRANSACTION
  as select * from v$goldengate_transaction
/
create or replace public synonym V$GOLDENGATE_TRANSACTION
  for V_$GOLDENGATE_TRANSACTION
/
grant select on V_$GOLDENGATE_TRANSACTION to select_catalog_role
/

----------------------------------------------------------------------------
-- "_(G)V$SXGG_TRANSACTION"
--------------------------------------------------------------------------
create or replace view "_V$SXGG_TRANSACTION" container_data
as
select * from v$streams_transaction
union all
select component_name, component_type, xidusn, xidslt, xidsqn,
cumulative_message_count, total_message_count, first_message_time,
first_message_number, last_message_time, last_message_number,
first_message_position, last_message_position, transaction_id,
NULL purpose, con_id
from v$xstream_transaction
union all
select component_name, component_type, xidusn, xidslt, xidsqn,
cumulative_message_count, total_message_count, first_message_time,
first_message_number, last_message_time, last_message_number,
utl_raw.cast_to_raw(first_message_position),
utl_raw.cast_to_raw(last_message_position), transaction_id,
NULL purpose, con_id
from v$goldengate_transaction;

create or replace public synonym "_V$SXGG_TRANSACTION"
for "_V$SXGG_TRANSACTION";
grant select on "_V$SXGG_TRANSACTION" to select_catalog_role;

create or replace view "_GV$SXGG_TRANSACTION" container_data
as
select * from gv$streams_transaction
union all
select inst_id, component_name, component_type, xidusn, xidslt, xidsqn,
cumulative_message_count, total_message_count, first_message_time,
first_message_number, last_message_time, last_message_number,
first_message_position, last_message_position, transaction_id,
NULL purpose, con_id
from gv$xstream_transaction
union all
select inst_id, component_name, component_type, xidusn, xidslt, xidsqn,
cumulative_message_count, total_message_count, first_message_time,
first_message_number, last_message_time, last_message_number,
utl_raw.cast_to_raw(first_message_position),
utl_raw.cast_to_raw(last_message_position), transaction_id,
NULL purpose, con_id
from gv$goldengate_transaction;

create or replace public synonym "_GV$SXGG_TRANSACTION"
for "_GV$SXGG_TRANSACTION";
grant select on "_GV$SXGG_TRANSACTION" to select_catalog_role;

----------------------------------------------------------------------------
-- V$STREAMS_MESSAGE_TRACKING
----------------------------------------------------------------------------
create or replace view GV_$STREAMS_MESSAGE_TRACKING
  as select * from gv$streams_message_tracking
/
create or replace public synonym GV$STREAMS_MESSAGE_TRACKING
  for GV_$STREAMS_MESSAGE_TRACKING
/
grant select on GV_$STREAMS_MESSAGE_TRACKING to select_catalog_role
/

create or replace view V_$STREAMS_MESSAGE_TRACKING
  as select * from v$streams_message_tracking
/
create or replace public synonym V$STREAMS_MESSAGE_TRACKING 
  for V_$STREAMS_MESSAGE_TRACKING
/
grant select on V_$STREAMS_MESSAGE_TRACKING to select_catalog_role
/

----------------------------------------------------------------------------
-- V$XSTREAM_MESSAGE_TRACKING
----------------------------------------------------------------------------
create or replace view GV_$XSTREAM_MESSAGE_TRACKING
  as select * from gv$xstream_message_tracking
/
create or replace public synonym GV$XSTREAM_MESSAGE_TRACKING
  for GV_$XSTREAM_MESSAGE_TRACKING
/
grant select on GV_$XSTREAM_MESSAGE_TRACKING to select_catalog_role
/

create or replace view V_$XSTREAM_MESSAGE_TRACKING
  as select * from v$xstream_message_tracking
/
create or replace public synonym V$XSTREAM_MESSAGE_TRACKING
  for V_$XSTREAM_MESSAGE_TRACKING
/
grant select on V_$XSTREAM_MESSAGE_TRACKING to select_catalog_role
/

----------------------------------------------------------------------------
-- V$GOLDENGATE_MESSAGE_TRACKING
----------------------------------------------------------------------------
create or replace view GV_$GOLDENGATE_MESSAGETRACKING
  as select * from gv$goldengate_message_tracking
/
create or replace public synonym GV$GOLDENGATE_MESSAGE_TRACKING
  for GV_$GOLDENGATE_MESSAGETRACKING
/
grant select on GV_$GOLDENGATE_MESSAGETRACKING to select_catalog_role
/

create or replace view V_$GOLDENGATE_MESSAGE_TRACKING
  as select * from v$goldengate_message_tracking
/
create or replace public synonym V$GOLDENGATE_MESSAGE_TRACKING
  for V_$GOLDENGATE_MESSAGE_TRACKING
/
grant select on V_$GOLDENGATE_MESSAGE_TRACKING to select_catalog_role
/

---------------------------------------------------------------------------
-- "_(G)V$SXGG_MESSAGE_TRACKING
---------------------------------------------------------------------------
create or replace view "_V$SXGG_MESSAGE_TRACKING" container_data
as
select * from v$streams_message_tracking
union all
select tracking_label, tag, component_name, component_type, action,
action_details, timestamp, message_creation_time, message_number,
tracking_id, source_database_name, object_owner, object_name, xid,
command_type, message_position, NULL, con_id
from v$xstream_message_tracking
union all
select tracking_label, tag, component_name, component_type, action,
action_details, timestamp, message_creation_time, message_number,
tracking_id, source_database_name, object_owner, object_name, xid,
command_type, utl_raw.cast_to_raw(message_position), NULL, con_id
from v$goldengate_message_tracking;

create or replace public synonym "_V$SXGG_MESSAGE_TRACKING"
  for "_V$SXGG_MESSAGE_TRACKING";
grant select on "_V$SXGG_MESSAGE_TRACKING" to select_catalog_role;

create or replace view "_GV$SXGG_MESSAGE_TRACKING" container_data
as
select * from gv$streams_message_tracking
union all
select inst_id, tracking_label, tag, component_name, component_type, action,
action_details, timestamp, message_creation_time, message_number,
tracking_id, source_database_name, object_owner, object_name, xid,
command_type, message_position, NULL, con_id
from gv$xstream_message_tracking
union all
select inst_id, tracking_label, tag, component_name, component_type, action,
action_details, timestamp, message_creation_time, message_number,
tracking_id, source_database_name, object_owner, object_name, xid,
command_type, utl_raw.cast_to_raw(message_position), NULL, con_id
from gv$goldengate_message_tracking;

create or replace public synonym "_GV$SXGG_MESSAGE_TRACKING"
  for "_GV$SXGG_MESSAGE_TRACKING";
grant select on "_GV$SXGG_MESSAGE_TRACKING" to select_catalog_role;

----------------------------------------------------------------------------
-- V$STREAMS_POOL_STATISTICS
----------------------------------------------------------------------------
create or replace view GV_$STREAMS_POOL_STATISTICS
  as select * from gv$streams_pool_statistics
/
create or replace public synonym GV$STREAMS_POOL_STATISTICS
  for GV_$STREAMS_POOL_STATISTICS
/
grant select on GV_$STREAMS_POOL_STATISTICS to select_catalog_role
/

create or replace view V_$STREAMS_POOL_STATISTICS
  as select * from v$streams_pool_statistics
/
create or replace public synonym V$STREAMS_POOL_STATISTICS
  for V_$STREAMS_POOL_STATISTICS
/
grant select on V_$STREAMS_POOL_STATISTICS to select_catalog_role
/

create or replace view DBA_GOLDENGATE_PRIVILEGES
  (username, privilege_type, grant_select_privileges, create_time)
as
select username,
       decode(privilege_type, 1, 'CAPTURE',
                              2, 'APPLY',
                              3, '*'),
       decode(privilege_level, 0, 'NO',
                               1, 'YES'),
       create_time
from sys.goldengate$_privileges;

comment on table DBA_GOLDENGATE_PRIVILEGES is
'Details about goldengate privileges'
/
comment on column DBA_GOLDENGATE_PRIVILEGES.USERNAME is
'Name of the user that is granted the privilege'
/
comment on column DBA_GOLDENGATE_PRIVILEGES.PRIVILEGE_TYPE is
'Type of privilege granted'
/
comment on column DBA_GOLDENGATE_PRIVILEGES.GRANT_SELECT_PRIVILEGES is
'Whether to grant select privileges'
/
comment on column DBA_GOLDENGATE_PRIVILEGES.CREATE_TIME is
'Timestamp for the granted privilege'
/
create or replace public synonym DBA_GOLDENGATE_PRIVILEGES for DBA_GOLDENGATE_PRIVILEGES
/
grant select on DBA_GOLDENGATE_PRIVILEGES to select_catalog_role
/



execute CDBView.create_cdbview(false,'SYS','DBA_GOLDENGATE_PRIVILEGES','CDB_GOLDENGATE_PRIVILEGES');
grant select on SYS.CDB_GOLDENGATE_PRIVILEGES to select_catalog_role
/
create or replace public synonym CDB_GOLDENGATE_PRIVILEGES for SYS.CDB_GOLDENGATE_PRIVILEGES
/

create or replace view ALL_GOLDENGATE_PRIVILEGES as
(select gp.*
  from DBA_GOLDENGATE_PRIVILEGES gp, sys.user$ u, dba_role_privs rp
  where ((gp.username = u.name) and  (u.user# = userenv('SCHEMAID')))
union
select gp.*
  from DBA_GOLDENGATE_PRIVILEGES gp, sys.user$ u, dba_role_privs rp
  where (u.name = rp.grantee
        and rp.granted_role = 'SELECT_CATALOG_ROLE'
        and u.user# = userenv('SCHEMAID')))
/

comment on table ALL_GOLDENGATE_PRIVILEGES is
'Details about goldengate privileges for the user'
/
comment on column ALL_GOLDENGATE_PRIVILEGES.USERNAME is
'Name of the user that is granted the privilege'
/
comment on column ALL_GOLDENGATE_PRIVILEGES.PRIVILEGE_TYPE is
'Type of privilege granted'
/
comment on column ALL_GOLDENGATE_PRIVILEGES.GRANT_SELECT_PRIVILEGES is
'Whether to grant select privileges'
/
comment on column ALL_GOLDENGATE_PRIVILEGES.CREATE_TIME is
'Timestamp for the granted privilege'
/
create or replace public synonym ALL_GOLDENGATE_PRIVILEGES for ALL_GOLDENGATE_PRIVILEGES
/
grant select on ALL_GOLDENGATE_PRIVILEGES to select_catalog_role
/


create or replace view USER_GOLDENGATE_PRIVILEGES
  (privilege_type, grant_select_privileges, create_time)
as
select decode(p.privilege_type, 1, 'CAPTURE',
                                2, 'APPLY',
                                3, '*'),
       decode(p.privilege_level, 0, 'NO',
                                 1, 'YES'),
       create_time
from sys.goldengate$_privileges p, user_users u
where p.username = u.username;

comment on table USER_GOLDENGATE_PRIVILEGES is
'Details about goldengate privileges'
/
comment on column USER_GOLDENGATE_PRIVILEGES.PRIVILEGE_TYPE is
'Type of privilege granted'
/
comment on column USER_GOLDENGATE_PRIVILEGES.GRANT_SELECT_PRIVILEGES is
'Whether to grant select privileges'
/
comment on column USER_GOLDENGATE_PRIVILEGES.CREATE_TIME is
'Timestamp for the granted privilege'
/
create or replace public synonym USER_GOLDENGATE_PRIVILEGES for USER_GOLDENGATE_PRIVILEGES
/
grant read on USER_GOLDENGATE_PRIVILEGES to public
/

Rem Data CoMParison catalog views
@@catcmp.sql

Rem STReams Compatibility catalog views
@@catstrc.sql

@?/rdbms/admin/sqlsessend.sql
